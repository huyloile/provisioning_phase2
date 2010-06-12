-module(svc_recharge_cb_cmo).


%%%% XML API CB CMO
-export([start/1]).
%% authentification
-export([verif_code_acces/2,verif_code_contrat_client/2]).
-export([creation_code_acces/2,modification_code_acces/2,do_mcod/2]).
%% paiement
-export([info/1,verif_code_CB/2,verif_datevalid/2]).
-export([saisie_montant/2,paiement/2]).
%% Verfi code court
-export([verif_code_cvx2/2,dmd_code_court/1]).
%%%% XML API CMO TLR
-export([start_tlr/1,verif_tlr/2]).
%%%% EXPORT FOR CB MOBI
%%gene
-export([is_code/2,is_cle_luhn/1,print/2,reinit_compteur/3,
	is_date_ok/1,imsi_court/1]).
%% export function use for CB MOBI
-export([is_cle_luhn/1,int_to_nat/1]).

-export([error_return/4]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/recharge_cb_cmo.hrl").

%%% CONFIG STATIQUE DDES VERSION DE REQUÊTES
-define(rcod_version,1).
-define(vcod_version,1).
-define(mcod_version,1).
-define(info_version,2).
-define(dmcc_version,1).
-define(mcc_version,1).
-define(pay_version,2).
-define(sub,cmo).

%%%%% Checks state, and creates service data.
%%%%%% idem start_selfcare, except for state EP
%% +type start(session())-> erlpage_result().
start(abs) ->
    authentifier_client(abs) ++
	[ {redirect, abs, "#temporary"},
	  {redirect, abs, "#not_cmo"}];

start(#session{prof=Profile}=Session) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    continue_recharge(Session1);
	{redirect, Session1, URL} ->
	    {redirect, Session1, URL}
    end.

%% +type continue_recharge(session())-> erlpage_result().
continue_recharge(#session{prof=#profile{subscription=S}}=Session)
  when S=/="cmo" ->
    slog:event(trace, ?MODULE, not_cmo),
    {redirect, Session, "#notcmo"};
continue_recharge(#session{prof=Profile}=Session) ->
    case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, State}  ->
	    %% Reinit recharge_cb_cmo.
	    NState=State#sdp_user_state{tmp_recharge=#recharge_cb_cmo{}},
	    NewSession=svc_util_of:update_user_state(Session_,NState),
	    
	    authentifier_client(NewSession);
	Error ->
	    %% This should not happen because we have already gone
	    %% through provisioning in svc_home.
	    {redirect, Session, "#temporary",
	     [{"ERR_INFO","??"}]}
    end.

%% +type start_tlr(session())-> erlpage_result().
start_tlr(abs) ->
    info(abs,tlr) ++
	[ {redirect, abs, "#not_cmo"}];
start_tlr(#session{prof=#profile{subscription=S}}=Session)
  when S=/="cmo" ->
    slog:event(trace, ?MODULE, not_cmo),
    {redirect, Session, "#notcmo"};
start_tlr(#session{prof=Profile}=Session) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    State1=svc_util_of:get_user_state(Session1),
	    State2=State1#sdp_user_state{tmp_recharge=#recharge_cb_cmo{}},
	    Session2=svc_util_of:update_user_state(Session1,State2),
	    info(Session2,tlr);
	{redirect, Session1, URL} ->
	    {redirect, Session1, URL}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% AUTHENTIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type authentifier_client(session())-> erlpage_result().
authentifier_client(abs)->
    [{redirect,abs,"#system_failure"}]++
	etat_code_acces(abs,0) ++ info(abs,cb);
authentifier_client(Session)->
    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
    case catch cbhttp:rcod(MSISDN,?rcod_version,?sub) of
	{ok,[MSISDN,_,NADV,NB_TENTATIVE,_,NUM_CLIENT]}->
	    %% enregistrer NADV, NUM_CLIENT, NB_TENTATIVE
	    NSession=update_recharge_cb(Session,
				      [{nadv,NADV},
				       {code_client,NUM_CLIENT},
				       {c_code_acces,NB_TENTATIVE}]),
    %% Check si debrayage de vco et mco
	    case {pbutil:get_env(pservices_orangef,debrayage_vco_mco_actif),
		  NB_TENTATIVE} of
		{_,-3} ->
		    etat_code_acces(NSession,NB_TENTATIVE);
		{true,_} ->
		    % Cas -2,-1,0 et >0 ===> debrayage des phases vcod et mcod
		    info(Session);
		{false,_} ->
		    etat_code_acces(NSession,NB_TENTATIVE)
	    end;
	Else->
	    error_return(Session,Else,rcod)
    end.

%% +type etat_code_acces(session(),NB_TENTA::integer())-> 
%%                      erlpage_result().
etat_code_acces(abs,_)->
    [{">0 ok",{redirect,abs,"#form_code_acces"}},
     {"-3-> incident SDA",{redirect,abs,"#rcod_sda_error"}},
     {"-2,0=> ecrasé CC/inhibé",{redirect,abs,"#form_reinit_code"}},
     {"-1=> écrasé initial",{redirect,abs,"#creation_code_acces"}}];
etat_code_acces(Session,X) when X>0->
    %% Code Valide
    {redirect,Session,"#form_code_acces"};
etat_code_acces(Session,-3)->
    %% incident SDA
    {redirect,Session,"#rcod_sda_error"};
etat_code_acces(Session,X) when X==0;X==-2 ->
    %% 0 inihibé
    %% -2 écrasé CC
    %% -> Msg 2010: dmd reinit code avec code contrat client
    {redirect,Session,"#form_reinit_code"};
etat_code_acces(Session,-1)->
    %% -1: Ecrasé initial
    {redirect,Session,"#creation_code_acces"}.

%% +type verif_code_acces(session(),CODE::string())-> 
%%                      erlpage_result().
verif_code_acces(abs,_)->
    [{redirect,abs,"#verif_code_ok"},
     {redirect,abs,"#form_reinit_code_nok"},
     {redirect,abs,"#creation_code_acces"},
     {redirect,abs,"#system_failure"}]++
	verif_code_acces_nok(abs)++error_return(abs,"",vcod);
verif_code_acces(#session{}=Session,Code)->
    case is_code(Code,4) of
	false->
	    %% il ne s'agit pas de chiffre
	    %% doit-on traduire le donnée en chiffre ?!
	    verif_code_acces_nok(Session);
	true->
	    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
	    IMSI=imsi_court((Session#session.prof)#profile.imsi),
	    case cbhttp:vcod(MSISDN,IMSI,Code,?vcod_version,?sub) of
		{ok,[MSISDN,IMSI]}->
		    NSession=update_recharge_cb(Session,[{code_acces,Code}]),
		    {redirect,NSession,"#verif_code_ok"};
		{statut,156}->
		    %% code erroné
		   verif_code_acces_nok(Session);
		{statut,X} when X==158;X==159->
		    %% 156 Code Ecrasé CC
		    %% 158 Code inhibé
		    {redirect,Session,"#form_reinit_code_nok"};
		{statut,157} ->
		    %% 157 Code ecrasé initial
		    {redirect,Session,"#creation_code_acces"};
		Else ->
		    %% gestion PB SDA ???!!!
		    error_return(Session,Else,vcod)
	    end
    end.

%% +type verif_code_acces_nok(session())-> erlpage_result().
verif_code_acces_nok(abs)->
    [{redirect,abs,"#wrong_code_acces"},
     {redirect,abs,"#wrong_code_acces_last"},
     {redirect,abs,"#form_reinit_code_nok"}];
verif_code_acces_nok(Session)->
    NB_ten=(cast(Session))#recharge_cb_cmo.c_code_acces,
    NSession=update_recharge_cb(Session,
				[{c_code_acces,NB_ten-1}]),
    case NB_ten-1 of
	X when X>1->
	    {redirect,NSession,"#wrong_code_acces"};
	X when X==1->
	    {redirect,NSession,"#wrong_code_acces_last"};
	X when X<1->
	    {redirect,NSession,"#form_reinit_code_nok"}
    end.

%% +type verif_code_contrat_client(session(),CODE::string())-> 
%%                      erlpage_result().
%%%%% mise à 3 de tentative
verif_code_contrat_client(abs,_)->
    [{redirect,abs,"#wrong_code_contrat"},
     {redirect,abs,"#code_contrat_nok"},
     {redirect,abs,"#creation_code_acces"}];
verif_code_contrat_client(#session{}=Session,Code)->
    Rech_CB=cast(Session),
    Code_contrat=Rech_CB#recharge_cb_cmo.code_client,
    case {is_code(Code,10),Code_contrat==Code} of
	{true,true}->
	    {redirect,Session,"#creation_code_acces"};
	_->
	    F_TENTA=Rech_CB#recharge_cb_cmo.c_code_client,
	    case F_TENTA of
		X when X>1->
		    NSession=update_recharge_cb(Session,
						[{c_code_client,F_TENTA-1}]),
		    {redirect,NSession,"#wrong_code_contrat"};
		X when X==1->
		    {redirect,Session,"#code_contrat_nok"}
	    end
    end.

%% +type creation_code_acces(session(),CODE::string())-> 
%%                      erlpage_result().
creation_code_acces(abs,Code)->
    [{redirect,abs,"#code_acces_creation_ok",["CODE"]},
     {redirect,abs,"#wrong_acces_creation"},
     {redirect,abs,"#saisie_nok"}];
creation_code_acces(Session,Code)->
    Rech_CB=cast(Session),
    F_TENTA=Rech_CB#recharge_cb_cmo.c_create_code,
    case is_code(Code,4) of
	true->
	    NSession=update_recharge_cb(Session,[{new_code_acces,Code}]),
	    %% store the code
	    {redirect,NSession,"#code_acces_creation_ok",[{"CODE",Code}]};
	false->
	    case F_TENTA of
		X when X>1->
		    NSession=update_recharge_cb(Session,
						[{c_create_code,F_TENTA-1}]),
		    {redirect,NSession,"#wrong_acces_creation"};
		X when X==1->
		    {redirect,Session,"#saisie_nok"}
	    end
    end.


%% +type do_mcod(session(),string())-> erlpage_result().
do_mcod(abs,"create")->
    [{redirect,abs,"#verif_create_code_ok"}]++
	error_return(abs,abs,abs);
do_mcod(abs,"modif")->
    [{redirect,abs,"#verif_modif_code_ok"}]++
	error_return(abs,abs,abs);
do_mcod(Session,CreateOrModif)->
    NCODE=(cast(Session))#recharge_cb_cmo.new_code_acces,
    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
    IMSI=imsi_court((Session#session.prof)#profile.imsi),
    case cbhttp:mcod(MSISDN,IMSI,NCODE,?mcod_version,?sub) of
	{ok,[MSISDN,IMSI]}->
	    NSession=update_recharge_cb(Session,
				      [{code_acces,NCODE}]),
	    %%code_acces=NCODE
	    case CreateOrModif of
		"create"->
		    {redirect,NSession,"#verif_create_code_ok"};
		"modif"->
		     {redirect,NSession,"#verif_modif_code_ok"}
	    end;
	Else ->
	    error_return(Session,Else,mcod)
    end.

%% +type modification_code_acces(session(),CODE::string())-> 
%%                      erlpage_result().
modification_code_acces(abs,Code)->
    [{redirect,abs,"#code_acces_modif_ok",["CODE"]},
     {redirect,abs,"#wrong_acces_modif"},
     {redirect,abs,"#saisie_nok"}];
modification_code_acces(Session,Code)->
    Rech_CB=cast(Session),
    F_TENTA=Rech_CB#recharge_cb_cmo.c_modif_code,
    case is_code(Code,4) of
	true->
	    NSession=update_recharge_cb(Session,
				      [{new_code_acces,Code}]),
	    %% store the new code acces
	    {redirect,NSession,"#code_acces_modif_ok",[{"CODE",Code}]};
	false->
	     case F_TENTA of
		X when X>1->
		    NSession=update_recharge_cb(Session,
						[{c_modif_code,F_TENTA-1}]),
		    {redirect,NSession,"#wrong_acces_modif"};
		X when X==1->
		    {redirect,Session,"#saisie_nok"}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% PAIEMENT %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type info(session())-> erlpage_result().
info(Session)->
    info(Session,cb).

%% +type info(session(),atom)-> erlpage_result().
info(abs,Type)->
    [{"plafond=0",{redirect,abs,"#plafond_depasse"}},
     {"plafond>0",{redirect,abs,"#info_ok"}}]++
	error_return(abs,abs,info,Type);
info(Session,Type)->
    State = svc_util_of:get_user_state(Session),
    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
    case cbhttp:info(MSISDN,?info_version,?sub) of
	{ok, [_,MSISDN,_,EPR_NUM,ESC_NUM,DOS_CUMUL_REC,DATEDER,
	      UNT_NUM,PLAFOND_E,SOLDE_E,VALID24,NB_CPT,BONUS,MOBI_OPT,
	      DOS_DATE_DER_REC,DOS_MONTANT_REC]}->
	    %% MAJ solde compte princ SOLDE_E
	    %% MAJ Bonus ???
	    PLF_E=currency:sum(euro,PLAFOND_E/1000),
	    MONTANT_MOIS=currency:sum(euro,DOS_CUMUL_REC/1000),
	    REST= currency:sub(PLF_E,MONTANT_MOIS),
	    RECH_MINI =currency:sum(pbutil:get_env(pservices_orangef,
						   recharge_cb_cmo_mini)),
	    case currency:is_infeq(REST,RECH_MINI) of
		true->
		    {redirect,Session,"#plafond_depasse"};
		false ->
		    %% Mettre à zéro le plafond de rechargement
		    NSession=update_recharge_cb(Session,[{plafond,REST}]),
		    {redirect,NSession,"#info_ok"}
	    end;
	Else->
	    error_return(Session,Else,info,Type)
    end.

%% +type verif_code_CB(session(),string())-> erlpage_result().	    
verif_code_CB(abs,Code)->
    code_court_ok(abs,Code)++
	verif_cle_luhn(abs,Code)++
	wrong_code_cb(abs);
verif_code_CB(Session,CB) when length(CB)>=16,length(CB)=<19->
    case pbutil:all_digits(CB) of
	true->
	    verif_cle_luhn(Session,CB);
	false->
	    wrong_code_cb(Session)
    end;
verif_code_CB(Session,Code)->
    case is_code(Code,4) of
	true->
	    code_court_ok(Session,Code);
	false->
	    wrong_code_cb(Session)
    end.

%% +type verif_cle_luhn(session(),CB::string())-> erlpage_result().
verif_cle_luhn(abs,_)->
    [{redirect,abs,"#form_date_valid"}]++
	wrong_code_cb(abs);
verif_cle_luhn(Session,CB)->	
    State =svc_util_of:get_user_state(Session),
    case is_cle_luhn(CB) of
	true->
	    NSession=update_recharge_cb(Session,[{no_carte_cb,CB}]),
	    {redirect,NSession,"#form_date_valid"};
	false->
	    wrong_code_cb(Session)
    end.

%% +type wrong_code_cb(session())-> erlpage_result().
wrong_code_cb(abs)->
    [{redirect,abs,"#wrong_code_CB"},
     {redirect,abs,"#saisie_nok"}];
wrong_code_cb(Session)->
    F_TENTA=(cast(Session))#recharge_cb_cmo.c_code_CB,
    case F_TENTA of
	X when X>1->
	     NSession=update_recharge_cb(Session,[{c_code_CB,F_TENTA-1}]),
	    {redirect,NSession,"#wrong_code_CB"};
	1 ->
	    {redirect,Session,"#saisie_nok"}
    end.

%% +type verif_datevalid(session(),CODE::string())-> 
%%                      erlpage_result().
verif_datevalid(abs,Code)->
    [{redirect,abs,"#saisie_nok"},
     {redirect,abs,"#wrong_date_valid"}]++
	dmd_cvx2_avant_phase_versement(abs);
verif_datevalid(Session,Date)->
    C_DATE=(cast(Session))#recharge_cb_cmo.c_date_valid,
    case {(is_code(Date,4) and is_date_ok(Date)),C_DATE} of
	{true,_}->
	    NSession=update_recharge_cb(Session,
					[{date_valid_cb,Date}]),
		    %%update recharge_cb
	    dmd_cvx2_avant_phase_versement(NSession);
	{false,C_DATE} when C_DATE>1->
	    NSession=update_recharge_cb(Session,
					[{c_date_valid,C_DATE-1}]),
	    {redirect,NSession,"#wrong_date_valid"};
	{false,1} ->
	    NSession=update_recharge_cb(Session,
					[{c_date_valid,0}]),
	    {redirect,NSession,"#saisie_nok"}
    end.
%% +type is_date_ok(string())-> bool().
is_date_ok(Date)->
    case catch pbutil:sscanf("%02d%02d",Date) of
	{[M,A],[]}->	
	    is_date_ok(M,A);
	_ ->
	    false
    end.
%% +type is_date_ok(Month::integer(),Year::integer())-> bool().
is_date_ok(M,A) when M>12;
		     M=<0 ->
    false;
is_date_ok(M,A)->
    {Year,Month,Day}=date(),
    Y2 = Year - Year rem 100,
    {2000+A,M,Day}>date().

%% +type dmd_cvx2_avant_phase_versement(session())-> erlpage_result().
dmd_cvx2_avant_phase_versement(abs)->
    [{redirect,abs,"#saisie_cvx2"},
     {redirect,abs,"#phase_de_versement"}];
dmd_cvx2_avant_phase_versement(Session)->
    case pbutil:get_env(pservices_orangef,dmd_cvx2_avt_versement) of
	true->
	    {redirect,Session,"#saisie_cvx2"};
	false->
	    {redirect,Session,"#phase_de_versement"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Verification Code Court de Rechargment%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type code_court_ok(session(),string())-> erlpage_result().
code_court_ok(abs,Code)->
    [{redirect,abs,"#saisie_cvx2"},
     {redirect,abs,"#phase_de_versement"}]++
	error_return(abs,"",dmcc);
code_court_ok(Session,Code)->
    NSession=update_recharge_cb(Session,[{code_court,Code}]),
    case pbutil:get_env(pservices_orangef,verif_cc_cvx2) of
	true->
	    %% on vérifie la validité du code présent en base
	    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
	    case cbhttp:dmcc(MSISDN,Code,?dmcc_version,?sub) of
		{ok,[MSISDN]}->
		    %% si ecrase_cc is actif on demande un code cvx2
		    {redirect,NSession,"#saisie_cvx2"};	
		{statut,152}->
		    %% couple non présent
		    {redirect,NSession,"#phase_de_versement"};
		Else ->
		    error_return(Session,Else,dmcc)
	    end;
	false ->
	    {redirect,NSession,"#phase_de_versement"}
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Demande Code Court de Rechargment%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type dmd_code_court(session())-> erlpage_result().
dmd_code_court(abs)->
    [{redirect,abs,"#dmd_code_court_ok"}]++
	error_return(abs,"",mcc);
dmd_code_court(Session)->
    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
    IMSI=imsi_court((Session#session.prof)#profile.imsi),
    CB=(cast(Session))#recharge_cb_cmo.no_carte_cb,
    FIN_DATE_CB=(cast(Session))#recharge_cb_cmo.date_valid_cb,
    case cbhttp:mcc(MSISDN,IMSI,CB,FIN_DATE_CB,?mcc_version,?sub) of
	{ok,[MSISDN,IMSI,Code]}->
	    %% store code court
	    NSession = update_recharge_cb(Session,[{code_court,Code}]),
	    {redirect,NSession,"#dmd_code_court_ok"};	
	Else ->
	    error_return(Session,Else,mcc)
    end.

%% +type verif_code_cvx2(session(),CODE::string())-> 
%%                      erlpage_result().
verif_code_cvx2(abs,Code)->
    [{redirect,abs,"#phase_de_versement"},
     {redirect,abs,"#wrong_cvx2"},
     {redirect,abs,"#saisie_nok"}];
verif_code_cvx2(Session,Code)->
    F_TENTA=(cast(Session))#recharge_cb_cmo.c_cvx2,
    case {is_code(Code,3),F_TENTA} of
	{true,_}->
	    %% store cvx2
	    NSession=update_recharge_cb(Session,[{cvx2,Code}]),
	    {redirect,NSession,"#phase_de_versement"};
	{false,X} when X>1->
	    NSession=update_recharge_cb(Session,[{c_cvx2,F_TENTA-1}]),
	    {redirect,NSession,"#wrong_cvx2"};
	{false,1}->
	    {redirect,Session,"#saisie_nok"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Verification Code TLR %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type verif_tlr(session(),CODE::string())-> 
%%                      erlpage_result().
verif_tlr(abs,Code)->
    [{redirect,abs,"#wrong_tlr"},
     {redirect,abs,"#saisie_nok"}]++paiement(abs,tlr);
verif_tlr(Session,Code)->
    F_TENTA=(cast(Session))#recharge_cb_cmo.c_tlr,
    case {is_code(Code,4),F_TENTA} of
	{true,_}->
	    %% store TLR
	    NSession=update_recharge_cb(Session,[{tlr,Code}]),
	    paiement(NSession,tlr);
	{false,X} when X>1->
	    NSession=update_recharge_cb(Session,[{c_tlr,F_TENTA-1}]),
	    {redirect,NSession,"#wrong_tlr"};
	{false,1}->
	    {redirect,Session,"#saisie_nok"}
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Versement CB Montants %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type saisie_montant(session(),MNT::string())-> erlpage_result().
saisie_montant(abs,Montant)->
    [{redirect,abs,"#confirm_recharge"}]
	++wrong_montant(abs,abs);
saisie_montant(Session,Montant)->
    %% gestion des 3 tentatives
    State =svc_util_of:get_user_state(Session),
    case pbutil:all_digits(Montant) of
	true->
	    Plf=(cast(Session))#recharge_cb_cmo.plafond,
	    Mont=currency:sum(euro,list_to_integer(Montant)),
	    Mini=currency:sum(
		   pbutil:get_env(pservices_orangef,recharge_cb_cmo_mini)),
	    case {currency:is_infeq(Mini,Mont),currency:is_inf(Mont,Plf)} of
		{true,true}->
		    %% store montant
		    NSession=update_recharge_cb(Session,[{montant,Mont}]),
		    {redirect,NSession,"#confirm_recharge"};
		{true,false}->
		    %%montant > rechargement Max
		    wrong_montant(Session,sup);
		{false,_}->
		    %% montant inférieur au solde minimum
		    wrong_montant(Session,inf)
	    end;
	false->
	    wrong_montant(Session,nok)
    end.

%% +type wrong_montant(session,sup|inf|nok)-> erlpage_result().	
wrong_montant(abs,_)->
    [ {redirect,abs,"#montant_saisie_sup_plfd"},
      {redirect,abs,"#montant_saisie_inf_mini"},
      {redirect,abs,"#wrong_montant_saisie"},
      {redirect,abs,"#montant_saisie_sup_plfd_nok"},
      {redirect,abs,"#montant_saisie_inf_mini_nok"},
      {redirect,abs,"#saisie_nok"}
     ];
wrong_montant(Session,SupOrInf)->
    C_Montant=(cast(Session))#recharge_cb_cmo.c_montant,
    case {C_Montant,SupOrInf} of
	{X,sup} when X>1->
	     NSession=update_recharge_cb(Session,[{c_montant,C_Montant-1}]),
	    {redirect,NSession,"#montant_saisie_sup_plfd"};
	{X,inf} when X>1->
	     NSession=update_recharge_cb(Session,[{c_montant,C_Montant-1}]),
	    {redirect,NSession,"#montant_saisie_inf_mini"};
	{X,nok} when X>1->
	     NSession=update_recharge_cb(Session,[{c_montant,C_Montant-1}]),
	    {redirect,NSession,"#wrong_montant_saisie"};
	{_,inf}->
	    NSession=update_recharge_cb(Session,[{c_montant,0}]),
	    {redirect,NSession,"#montant_saisie_inf_mini_nok"};
	{_,sup}->
	    NSession=update_recharge_cb(Session,[{c_montant,0}]),
	    {redirect,NSession,"#montant_saisie_sup_plfd_nok"};
	{_,nok} ->
	    NSession=update_recharge_cb(Session,[{c_montant,0}]),
	    {redirect,NSession,"#saisie_nok"}
    end.
					
%% +type paiement(session(),atom()| string())-> erlpage_result().    
paiement(abs,tlr)->
    [{redirect,abs,"#rechargement_reussi"}]++
	error_return(abs,"",pay,tlr);
paiement(abs,_)->
    [{redirect,abs,"#rechargement_reussi_cc"},
     {redirect,abs,"#rechargement_reussi_cb"}]++
	error_return(abs,"",pay);
paiement(Session,tlr)->		
    case do_paiement(Session,?pay_version,?sub) of
	%%{ok,[Msisdn,_,SOLDE,UNT_NUM,BON_PCT,BONUS_MONTANT]}->  %%%%V1
	{ok,Session1}->
	    {redirect,Session1,"#rechargement_reussi"};
	Else ->
	    %% Ajouter les erreur du type CTRL KO:302, Erreur CVX2:301
	    error_return(Session,Else,pay,tlr)
    end;
paiement(Session,_)->		
    case do_paiement(Session,?pay_version,?sub) of
	%%{ok,[Msisdn,_,SOLDE,UNT_NUM,BON_PCT,BONUS_MONTANT]}->  %%%%V1
	{ok,Session1}->
	    Rech_CB=cast(Session1),
	    case Rech_CB#recharge_cb_cmo.no_carte_cb of
		undefined->
		    %% avec code court
		    {redirect,Session1,"#rechargement_reussi_cc"};
		_->
		    %% avec carte bleue
		    {redirect,Session1,"#rechargement_reussi_cb"}
	    end;
	Else ->
	    %% Ajouter les erreur du type CTRL KO:302, Erreur CVX2:301
	    error_return(Session,Else,pay,cb)
    end.

%% +type do_paiement(session(),integer(),sub_of())-> {ok, session()} | term().
do_paiement(Session,?pay_version,?sub)->
    State = svc_util_of:get_user_state(Session),
    Rech_CB=cast(Session),
    Msisdn=int_to_nat((Session#session.prof)#profile.msisdn),
    IMSI=imsi_court((Session#session.prof)#profile.imsi),
    Dosnum=State#sdp_user_state.dos_numid,
    case catch cbhttp:pay(Msisdn,IMSI,Dosnum,Rech_CB,?pay_version,?sub) of
	%%{ok,[Msisdn,_,SOLDE,UNT_NUM,BON_PCT,BONUS_MONTANT]}->  %%%%V1
	{ok,[Msisdn,_,NB_CPT,TCP_NUM,CPP_DATE_LV,SOLDE,UNT_NUM,BON_PCT,
	     BONUS_MONTANT]=Resp}->
	    %% update compte
	    NSession=update_session_after_recharge(Session,SOLDE,UNT_NUM),
	    %% mettre a jour le plafond
	    Plafond=Rech_CB#recharge_cb_cmo.plafond,
	    Montant=Rech_CB#recharge_cb_cmo.montant,
	    slog:avg(trace,?MODULE,montant_recharge,currency:round_value(Montant)),
	    NSession2=update_recharge_cb(NSession,[{plafond,currency:sub(Plafond,Montant)},
						   {bonus_montant,currency:sum(euro,BONUS_MONTANT/1000)}]),
	    {ok,NSession2};
	Else ->
	    Else
    end.
	    
%% +type update_session_after_recharge(session(),Solde::integer(),UNT::integer())->
%%      erlpage_result().
update_session_after_recharge(Session,Solde,UNT_NUM)->
    OldState = svc_util_of:get_user_state(Session),
    Compte = OldState#sdp_user_state.cpte_princ,
    NewSolde = currency:sum(euro, Solde/1000),
    NewCompte = Compte#compte{cpp_solde=NewSolde,
			      etat=?CETAT_AC},
    svc_util_of:update_user_state(Session,
				  OldState#sdp_user_state{cpte_princ=NewCompte}).	       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% FONCTIONS GENERIQUE %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type print(session(),string())-> [{pcdata,string()}].
print(abs,_)->
    [{pcdata,"XX"}];
print(Session,"plafond")->
    Plf=(cast(Session))#recharge_cb_cmo.plafond,
    [{pcdata,currency:print(Plf)}];
print(Session,"recharge_mini") ->
    RECH_MINI =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_cb_cmo_mini)),
    [{pcdata,currency:print(RECH_MINI)}];
print(Session,"code_court") ->
    Code=(cast(Session))#recharge_cb_cmo.code_court,
    [{pcdata,Code}];
print(Session,"montant") ->
    Mnt=(cast(Session))#recharge_cb_cmo.montant,
    Int_Mnt=trunc(currency:round_value(Mnt)),
    [{pcdata,integer_to_list(Int_Mnt)}];
print(Session,"bonus_montant") ->
    Mnt=(cast(Session))#recharge_cb_cmo.bonus_montant,
    Int_Mnt=trunc(currency:round_value(Mnt)),
    [{pcdata,integer_to_list(Int_Mnt)}].

%% +type reinit_compteur(session(),Cpt::string(),URL::string())->
%%           erlpage_result().
reinit_compteur(abs,Cpt,URL)->
    [{redirect,abs,URL}];
reinit_compteur(Session,Compteur,URL)->
    NSession=update_recharge_cb(Session,
				[{list_to_atom(Compteur),?NB_tentative}]),
    {redirect,NSession,URL}.
%% +type is_code(CODE::string(),Length::integer())-> 
%%                      bool().
is_code(Code,Length) when length(Code)=/=Length->
    false;
is_code(Code,Length)->
    pbutil:all_digits(Code).

%% +type error_return(session(),term(),atom())-> erlpage_result().
error_return(Session,Error,Req_Name)->
    %% backward compatibility
    error_return(Session,Error,Req_Name,cb).

%% +type error_return(session(),term(),atom(),atom())-> erlpage_result().
error_return(abs,Error,Req_Name,cb)->
    [{redirect,abs,"#system_failure"},
     {redirect,abs,"#not_cmo"},
     {redirect,abs,"#error_cvx2"},
     {redirect,abs,"#wrong_cc"},
     {redirect,abs,"#anomalie_cb"},
     {redirect,abs,"#paiement_refuse"}];
error_return(abs,Error,Req_Name,tlr)->
    [{redirect,abs,"#system_failure"},
     {redirect,abs,"#not_cmo"},
     {redirect,abs,"#erreur_reseau"},
     {redirect,abs,"#erreur_300"},
     {redirect,abs,"#erreur_304"}];
error_return(Session,{statut,152},Request_name,_)->
    %% Dossier inconnu
    MSISDN=(Session#session.prof)#profile.msisdn,
    {redirect,Session,"#not_cmo"};
error_return(Session,{statut,X},Request_name,_) when X==296;X==297->  
    %% PB Sachem: Dossier inconnu:297 ou on unique:296
    slog:event(internal,?MODULE,{error_dossier,Request_name},X),
    {redirect,Session,"#not_cmo"};
error_return(Session,{statut,X},Request_name,_) when X==298;299->  
    %% PB Sachem: Request Error:298 , Sachem Indisponible:299
    {redirect,Session,"#system_failure"};
error_return(Session,{statut,301},Request_name,cb)->  
    %% PB ADP: Erreur CVX2
    {redirect,Session,"#error_cvx2"};
error_return(Session,{statut,302},Request_name,cb)-> 
    %% PB ADP: Code court faux
    {redirect,Session,"#wrong_cc"};
error_return(Session,{statut,303},Request_name,cb)->  
    %% PB ADP: Anomalie CB
    {redirect,Session,"#anomalie_cb"};
error_return(Session,{statut,314},Request_name,cb)->  
    %% PB ADP: Paiement Refusé
    {redirect,Session,"#paiement_refuse"};
error_return(Session,{statut,401},Request_name,cb)->  
    %% PB dans l'encodage de la requete
    slog:event(internal,?MODULE,{format_error,Request_name}),
    {redirect,Session,"#system_failure"};
error_return(Session,{statut,499},Request_name,cb)->  
    %% Refus CVF: PB technique Interne
    {redirect,Session,"#system_failure"};
error_return(Session,{statut,302},Request_name,tlr)->  
    %% Code TLR faux
    verif_tlr(Session,"ab");
error_return(Session,{statut,300},Request_name,tlr)->  
    %% Non Inscrit au rechargement TLR
    {redirect,Session,"#erreur_300"};
error_return(Session,{statut,304},Request_name,tlr)->  
    %% PB ADP: Authorisation TLR refuse
    {redirect,Session,"#erreur_304"};
error_return(Session,{status,timeout},Request_name,_)->  
    %% timeout
    Class = pbutil:get_env(pservices_orangef,alarm_class_rech_cb),
    {redirect,Session,"#system_failure"};
error_return(Session,Else,pay,tlr)->  
    %% PB ADP: PAIEMENT TLR KO
    Class = pbutil:get_env(pservices_orangef,alarm_class_rech_cb),
    slog:event(Class,?MODULE,{default_error,pay},Else),
    {redirect,Session,"#erreur_reseau"};
error_return(Session,Else,Request_name,_)->  
    %% erreur http, ou encodage/decodage
    Class = pbutil:get_env(pservices_orangef,alarm_class_rech_cb),
    {redirect,Session,"#system_failure"}.
    
%% +type update_recharge_cb(session(),[{Name::atom(),Value::term()}])->
%%                  sdp_user_state().
update_recharge_cb(Session,Values)->
    State = svc_util_of:get_user_state(Session),
    Fields = record_info(fields, recharge_cb_cmo),
    %% Read the default permissions.
    RCB1=
	case cast(Session) of
	    #recharge_cb_cmo{}=RC->
		RC;
	    Else->
		#recharge_cb_cmo{}
	end,
    RCB2=pbutil:update_record(Fields, RCB1, Values),
    svc_util_of:update_user_state(Session,
				  State#sdp_user_state{tmp_recharge=RCB2}).

%% +type cast(session())-> recharge_cb_cmo().
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#sdp_user_state.tmp_recharge.

%% +type int_to_nat(string())-> string().
int_to_nat("+33"++MSISDN)->
    "0"++MSISDN;
int_to_nat("+99"++MSISDN)->
    "0"++MSISDN;
int_to_nat("06"++Rest=MSISDN) ->
    MSISDN;
int_to_nat("07"++Rest=MSISDN) ->
    MSISDN.

%% +type imsi_court(string())-> string().
imsi_court("20801"++[H1,H2,V|T])->
    "20801"++[H1,H2|T];
imsi_court(IMSI) ->
    IMSI.

%% +type is_cle_luhn(string())-> bool().
is_cle_luhn(CB)->
    Cle=lists:last(CB)-$0,    
    {Luhn_1,_}=
	lists:foldl(
	  fun(H,{Luh,M})->
		  N=H-$0,
		  N1=N*M,
		  N2=
		      case N1>9 of
			  true->
			      N1-9;
			  false ->
			      N1
		      end,
		  {Luh+N2,3-M}
	  end,{-Cle,2},CB),
    Luhn=Luhn_1 rem 10,
    Luhn2= case Luhn of
	       0->0;
	       _-> 10 -Luhn
	   end,
    Luhn2==Cle.
