-module(svc_recharge_cb_mobi).

%%%% Phase 1, 2 et 3
-export([start/2]).
%%%% Phase 4
-export([saisie_montant/3,montant_confirme/1,montant_confirme/2,verif_no_cb/2,verif_no_choix/3,
	verif_date_valid/2,verif_cvx2/2,verif_cvx2_or_cb/2,
	tentative_de_paiement/1,check_first_recharge/3,show_choix_montant_suite/3,
	is_lucky_number/2,send_sms/10,do_confirm/4]).
%%%% Fonction d'affichage
-export([choix_special_edition/1,inc_choix_montant/2,print/2,inc_choix_montant_rechargeU/1]).
%%%% IMPORT FUNCTION FROM SVC_RECHARGE_CB_CMO
-import(svc_recharge_cb_cmo, [is_cle_luhn/1,int_to_nat/1,is_date_ok/1,
			     imsi_court/1]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/recharge_cb_mobi.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").

%%% CONFIG STATIQUE DES VERSION DE REQUETES
-define(rcod_version,1).
-define(ident40_version,1).
-define(info_version,2).
-define(pay_version,3).
-define(sub,mobi).
-define(MONTH_IN_SEC,    31*86400).

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% PHASE 1 %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Vérification de l'inscription au service sur SACHEM
%%%% Envoie requetes A4 si necessaire
%%%% Verification segment commercial/Option Active (31ème bit)
%%%%% Checks state, and creates service data.
%%%%%% idem start_selfcare, except for state EP
%% +type start(session(),URL::string())-> erlpage_result().
start(abs,URL) ->
    authentify_client(abs) ++
	[ {redirect, abs, "#temporary"},
	  {redirect, abs, "#not_mobi"}];

start(#session{prof=Profile}=Session,URL) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    continue_recharge(Session1,URL);
	_ ->
	    {redirect, Session, "#temporary"}
    end.

%% +type continue_recharge(session(),URL::string())-> erlpage_result().
continue_recharge(#session{prof=#profile{subscription=S}}=Session,URL)
  when S=/="mobi" ->
    slog:event(trace, ?MODULE, not_mobi),
    {redirect, Session, "#not_mobi"};
continue_recharge(#session{prof=Profile}=Session,URL) ->
    case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, State}  ->
	    case svc_util_of:is_recharge_forbidden(State) of
		true ->
		    URL_redir =svc_util_of:url_recharge_forbidden(State),
		    {redirect, Session_, URL_redir};
		_ -> 
		    %% Reinit recharge_cb_mobi.
		    NState=
			State#sdp_user_state{tmp_recharge=#recharge_cb_mobi{}},
		    NewSession= 
			svc_util_of:update_user_state(Session_,NState),
		    is_option_activate(NewSession,URL)
	    end;
	Error ->
	    %% This should not happen because we have already gone
	    %% through provisioning in svc_home.
	    {redirect, Session, "#temporary"}
    end.

%% +type is_option_activate(session(),URL::string())-> erlpage_result().
is_option_activate(abs,URL)->
    [{"non actif",{redirect,abs,URL}}]++
	authentify_client(abs);
is_option_activate(Session,URL) ->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case (not(svc_options:is_option_activated(Session_new,opt_cb_mobi))) of
	true->
	    authentify_client(Session_new);
	false ->
	    {redirect,Session_new,URL}
    end.

authentify_client(abs) -> 
    [{redirect,abs,"#system_failure"},
     {redirect,abs,"#choix_montant"},
     {redirect,abs,"#error_no_mssidn"},
     {redirect,abs,"#error_identification"}];
authentify_client(Session) ->
    case svc_subscr_asmetier:get_identification(Session, "edl") of 
        {ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, _, Session1} ->
	    State = svc_util_of:get_user_state(Session1),
	    case svc_util_of:is_recharge_autorized(State) of
		true ->
		    case svc_subscr_asmetier:is_rechargeable_cb(Session1) of 
			{ok, PlafondStr, MontantMaxStr, Session2} -> 
			    List_to_number = fun(X) -> 
						     case string:to_float(X) of
							 {error, _} -> 
							     list_to_integer(X);
							 {Number, _} ->
							     Number
						     end
					     end,
			    Plafond = currency:sum(euro, List_to_number(PlafondStr)),
			    MontantMax = currency:sum(euro, List_to_number(MontantMaxStr)),
			    NewSession = update_recharge_cb(Session2, [{first_recharge, 
									svc_util_of:is_first_recharge(State)},
								       {plafond, Plafond}, 
								       {montant_max, MontantMax}]),
			    {redirect, NewSession, "#choix_montant"};
			
			{nok, Exception} ->
			    case Exception of
				#'ExceptionEtatDossierIncorrect'{}=E ->
				    {redirect, Session, "#error_not_allowed"};
				#'ExceptionOptionInterdite'{}=E ->
				    {redirect, Session, "#error_not_allowed"};
				_ ->
				    {redirect, Session, "#error_identification"}
			    end;
			Else -> 
			    {redirect, Session1, "#error_identification"}
		    end;
		_ ->
		    {redirect, Session, "#error_not_allowed"}
	    end;
	{nok,error,no_msisdn}->
	    {redirect, Session, "#error_no_msisdn"};
	_ ->
	    {redirect, Session, "#error_identification"}
    end.


%%%% Phase de Paiement
%%%% a-récupération de la saisie du montant
%%%% b-confirmation montant (avec bonus et date de validite)
%%%% c-saisie no CB/Date Valid/CVX2 si 1er rechargement CB
%%%% c bis- saisie CVX2 uniquement si DOS_MONTANT_REC>1
%%%% d- envoie de la requêtes de paiement

%% +type saisie_montant(session(),Montant::string())-> erlpage_result().
saisie_montant(abs,Montant,Type)->
    [{"CHOIX KDO ILLIMTES",{redirect,abs,"#confirm_montant"}},
     {"AFFICHAGE MONTANT RECH",{redirect,abs,"#redir_recharge_limite_7"}},
     {"AFFICHAGE RECHARGE VACANCES",{redirect,abs,"#recharge_vacances"}},
     {"ILLIMITE MEDIA",{redirect,abs,"#recharge_illimite_media"}}];
saisie_montant(Session,Montant,Type) ->
    Rech_cb= cast(Session),
    L_Mont= pbutil:get_env(pservices_orangef,list_montant_rech_cb_mobi),
    case Type of
	"normal" ->
            {value, {Val,Bonus,Descr_Duree}}= lists:keysearch(list_to_integer(Montant),1,L_Mont),
            NSession=update_recharge_cb(Session,[{montant,currency:sum(euro,Val)},
                                                 {bonus,currency:sum(euro,Bonus)},
                                                 {duree,Descr_Duree}]),
            {redirect,NSession,"#confirm_montant"};
	_ -> case list_to_integer(Montant) of
                 ?RECH_10E -> 
                     NSession = update_recharge_cb(Session,[{montant,currency:sum(euro,10)}]),
                     {redirect,NSession,"#rech_sl_10E"};
		 ?RECH_20E -> 
                     NSession = update_recharge_cb(Session,[{montant,currency:sum(euro,20)}]),
                     {redirect,NSession,"#rech_sl_20E"};
		 ?RECH_30E -> 
                     NSession = update_recharge_cb(Session,[{montant,currency:sum(euro,30)}]),
                     {redirect,NSession,"#rech_sl_30E"};
		 ?RECH_15E -> 
                     {value, {Val,Bonus,Descr_Duree}}= lists:keysearch(list_to_integer(Montant),1,L_Mont),
                     NSession=update_recharge_cb(Session,[{montant,currency:sum(euro,Val)},
                                                         {bonus,currency:sum(euro,Bonus)},
                                                         {duree,Descr_Duree}]),
                     {redirect,NSession,"#recharge_15E_Europe"};
		 ?RECH_7E ->  
                     {value, {Val,Bonus,Descr_Duree}}= lists:keysearch(list_to_integer(Montant),1,L_Mont),
                     NSession=update_recharge_cb(Session,[{montant,currency:sum(euro,Val)},
                                                         {bonus,currency:sum(euro,Bonus)},
                                                         {duree,Descr_Duree}]),
                     {redirect,NSession,"#recharge_7E_mms"}
	     end 
    end.

%% +type montant_confirme(session())-> erlpage_result().
%%%% renvoie vers saisie no Cb si 1er rechargement
%%%% renvoie vers Saisie CVX2 sinon
montant_confirme(abs)->
    [{"1er rechargement",{redirect,abs,"#saisie_no_cb"}},
     {"else",{redirect,abs,"#saisie_cvx2_cb"}}];
montant_confirme(Session) ->
    #recharge_cb_mobi{first_recharge=F_R} = cast(Session),
    case F_R of
	true->
	    %% Cas c: Pahse de paiement complete
	    {redirect,Session,"#saisie_no_cb"};
	false ->
	    %% Cas C bis: saisie CVX2 uniquement
	    {redirect,Session,"#saisie_cvx2_cb"}
    end.
% Recharging of RECH_20E euros, receive one of the following
% presents : 0 unlimited voice, 1 unlimited sms and 2 unlimited TV
montant_confirme(abs,Media_choice)->
    montant_confirme(abs);
montant_confirme(Session,"none") ->
    New_session=update_recharge_cb(Session,[{trc_num,"0"}]),
    #recharge_cb_mobi{trc_num=Choix} = cast(New_session),
    montant_confirme(New_session);
montant_confirme(Session,Media_choice) ->
    New_session=update_recharge_cb(Session,[{trc_num,Media_choice}]),
    #recharge_cb_mobi{trc_num=Choix} = cast(New_session),
    montant_confirme(New_session).

%% +type verif_no_cb(session(),string())-> erlpage_result().
verif_no_cb(abs,_)->
    [{"erreur saisie",{redirect,abs,"#saisie_no_cb_nok"}},
     {"nb tentative depasse",{redirect,abs,"#erreur_saisie_end_1"}},
     {"conditions",{redirect,abs,"#condition_cb_recharge_1"}},
     {"NO CB OK",{redirect,abs,"#saisie_date_valid"}}];
verif_no_cb(Session,"1")->
    {redirect,Session,"#condition_cb_recharge_1"};
verif_no_cb(Session,NO_CB)->
    case verif_saisie(NO_CB,no_cb) of
	true->
	    %% enregistrer NO_CB
	    %% passer au montant a confirmer
	    Session1_=update_recharge_cb(Session,[{no_cb,NO_CB}]),
	    {redirect,Session1_,"#saisie_date_valid"};
	false->
	    Rech_CB=#recharge_cb_mobi{c_no_cb=NB_TENT}=cast(Session),
	    case NB_TENT>1 of
		true->
		    Session1_=update_recharge_cb(Session,
						 [{c_no_cb,NB_TENT-1}]),
		    {redirect,Session1_,"#saisie_no_cb_nok"};
		false->
		    %% pas de reinit compteur
		    {redirect,Session,"#erreur_saisie_end_1"}
	    end
    end.

%% +type verif_no_choix(session(),string())-> erlpage_result().
verif_no_choix(Session, Opt, Number)->
    case verif_saisie_no_choix(Number,number) of
        true->
	    [$0,H|_] = Number,
	    %% numero de mobile de choix commence par 06
	    case H of 
		$6 -> 
		    %% enregistrer Number
		    %% passer au montant a confirmer avec choix client = 3
		    State  = svc_util_of:get_user_state(Session),
		    NState = State#sdp_user_state{numero_st_valentin=Number},
		    NSession = svc_util_of:update_user_state(Session,NState),
		    {redirect, NSession, "erl://svc_recharge_cb_mobi:montant_confirme?3"};
		_ ->
		    NB_Essai = (cast(Session))#recharge_cb_mobi.c_no_mobile_choix,
		    case NB_Essai > 1 of 
			true ->
			    NSession = update_recharge_cb(Session,[{c_no_mobile_choix, NB_Essai -1}]),
			    {redirect,NSession,"#saisie_no_choix_nok"};
			_ ->
			    {redirect,Session,"#erreur_saisie_no_choix_end"}
		    end
	    end;
	_->
	    NB_Essai = (cast(Session))#recharge_cb_mobi.c_no_mobile_choix,
	    case NB_Essai > 1 of 
		true ->
		    NSession = update_recharge_cb(Session,[{c_no_mobile_choix, NB_Essai -1}]),
		    {redirect,NSession,"#saisie_no_choix_nok"};
		_ ->
		    {redirect,Session,"#erreur_saisie_no_choix_end"}	    
	    end
    end.

%% +type verif_date_valid(session(),DATE::string())-> erlpage_result().
verif_date_valid(abs,_)->
    [{"erreur saisie",{redirect,abs,"#saisie_date_valid_nok"}},
     {"nb tentative depasse",{redirect,abs,"#erreur_saisie_end_2"}},
     {"DATE OK",{redirect,abs,"#saisie_cvx2"}}];
verif_date_valid(Session,DATE)->
    case verif_saisie(DATE,date_valid) of
	true->
	    %% enregistrer la date de validite
	    %% passer a la saise du CVX2
	    Session1_=update_recharge_cb(Session,[{date_valid,DATE}]),
	    {redirect,Session1_,"#saisie_cvx2"};
	false->
	    Rech_CB=#recharge_cb_mobi{c_date_valid=NB_TENT}=cast(Session),
	    case NB_TENT>1 of
		true->
		    Session1_=update_recharge_cb(Session,
						 [{c_date_valid,NB_TENT-1}]),
		    {redirect,Session1_,"#saisie_date_valid_nok"};
		false->
		    %% pas de reinit compteur
		    {redirect,Session,"#erreur_saisie_end_2"}
	    end
    end.

%% +type verif_cvx2(session(),CVX2::string())-> erlpage_result().
verif_cvx2(abs,_)->
    [{"erreur saisie",{redirect,abs,"#saisie_cvx2_nok"}},
     {"nb tentative depasse",{redirect,abs,"#erreur_saisie_end_3"}},
     {"info 1er rech",{redirect,abs,"#info_first"}}];
verif_cvx2(Session,CVX2)->
    case verif_saisie(CVX2,cvx2) of
	true->
	    %% enregistrer la date de validite
	    %% passer a la saise du CVX2
	    Session1_=update_recharge_cb(Session,[{cvx2,CVX2}]),
            tentative_de_paiement(Session1_);
	false->
	    Rech_CB=#recharge_cb_mobi{c_cvx2=NB_TENT}=cast(Session),
	    case NB_TENT>1 of
		true->
		    Session1_=update_recharge_cb(Session,
						 [{c_cvx2,NB_TENT-1}]),
		    {redirect,Session1_,"#saisie_cvx2_nok"};
		false->
		    %% pas de reinit compteur
		    {redirect,Session,"#erreur_saisie_end_3"}
	    end
    end.

%% +type verif_cvx2_or_cb(session(),string())-> erlpage_result().
verif_cvx2_or_cb(abs,_)->
    [{"erreur saisie",{redirect,abs,"#saisie_cvx2_cb_nok"}},
     {"nb tentative depasse",{redirect,abs,"#erreur_saisie_end_4"}}]++
	tentative_de_paiement(abs);
verif_cvx2_or_cb(Session,CVX2) when length(CVX2)==3->
    case verif_saisie(CVX2,cvx2) of
	true->
	    %% enregistrer la date de validite
	    %% passer a la saise du CVX2
	    Session1_=update_recharge_cb(Session,[{cvx2,CVX2}]),
	    tentative_de_paiement(Session1_);
	false->
	    Rech_CB=#recharge_cb_mobi{c_cvx2_cb=NB_TENT}=cast(Session),
	    case NB_TENT>1 of
		true->
		    Session1_=update_recharge_cb(Session,
						 [{c_cvx2_cb,NB_TENT-1}]),
		    {redirect,Session1_,"#saisie_cvx2_cb_nok"};
		false->
		    %% pas de reinit compteur
		    {redirect,Session,"#erreur_saisie_end_4"}
	    end
    end;
verif_cvx2_or_cb(Session,NO_CB)->
    case verif_saisie(NO_CB,no_cb) of
	true->
	    %% enregistrer NO_CB
	    %% passer a la saise de la date de validite
	    Session1_=update_recharge_cb(Session,[{no_cb,NO_CB}]),
	    {redirect,Session1_,"#saisie_date_valid"};
	false->
	    Rech_CB=#recharge_cb_mobi{c_cvx2_cb=NB_TENT}=cast(Session),
	    case NB_TENT>1 of
		true->
		    Session1_=update_recharge_cb(Session,
						 [{c_cvx2_cb,NB_TENT-1}]),
		    {redirect,Session1_,"#saisie_cvx2_cb_nok"};
		false->
		    %% pas de reinit compteur
		    {redirect,Session,"#erreur_saisie_end_4"}
	    end
    end.


%% +type tentative_de_paiement(session())-> erlpage_result().
tentative_de_paiement(abs)->
    [{"succes cpte princ",{redirect,abs,"#succes_princ"}},
     {"succes 50/50",{redirect,abs,"#succes_princ_sms"}}]++
	error_return(abs,"",pay);
tentative_de_paiement(Session)->
    State = svc_util_of:get_user_state(Session),
    Rech_CB=cast(Session),
    GetStr = fun(X) -> 
                case X of
                    undefined -> 
                        "";
                    _ -> X
                end
            end,
    NumCarte = GetStr(Rech_CB#recharge_cb_mobi.no_cb),
    FinVal = GetStr(Rech_CB#recharge_cb_mobi.date_valid),
    Cvx2 = GetStr(Rech_CB#recharge_cb_mobi.cvx2),
    Choice = GetStr(Rech_CB#recharge_cb_mobi.trc_num),
    Amount = trunc(currency:round_value(Rech_CB#recharge_cb_mobi.montant)),
    Court = case NumCarte of 
                "" -> 
                    "0000";
                _ -> 
                    ""
            end,
    case svc_subscr_asmetier:do_recharge_cb(Session, mobi,
                                            Choice, NumCarte, Court, FinVal, Cvx2, Amount) of 
        {ok, Resp} -> 
            %% update comptes
	    %% detecté si un ou plusiers compte de rechargement.
	    %% renvoie d'une url en fonction
            URL = url_succes([?C_PRINC], Choice, Amount),
	    case URL of 
	        X when X=="#succes_sl_20E_jour";X=="#succes_sl_20E_soir";X=="#succes_sl_20E_we";
		       X=="#succes_sl_10E";X=="#succes_sl_20E";X=="#succes_sl_30E";
		       X=="#succes_sl_7E";X=="#succes_sl_15E" ->
		    prisme_dump:prisme_count_v1(Session,"PRCBSL"),
		    URL;
		_ ->
		    prisme_dump:prisme_count_v1(Session,"PRECCB"),
		    URL
	    end,
	    %% mettre a jour le plafond
	    %% mettre a true first_recharge
	    Plf=Rech_CB#recharge_cb_mobi.plafond,
	    Montant=Rech_CB#recharge_cb_mobi.montant,
	    Session1=update_recharge_cb(Session,
					[{first_recharge,false},
					 {plafond,currency:sub(Plf,Montant)}]),
	    slog:event(trace, ?MODULE, tentative_de_paiement_amount, [Montant]),
            Session2 = svc_util_of:remove_from_sachem_available(Session1,"csl_doscp"),
	    State2 = svc_util_of:get_user_state(Session1),
	    svc_util_of:do_consultation_sachem(Session2,State2,URL,"#erreur_sachem");
        Else -> 
	    error_return(Session,Else,pay)
    end.

%% +type check_first_recharge(session(),URL::string(),URL2::string())-> erlpage_result().
%%%% en cas de back apres rechargement résussi renvoie vers le menu
%%%% pour eviter deux rechargement de suite
check_first_recharge(abs,URL_ok,URL_nok)->
    [{redirect,abs,URL_ok},
     {redirect,abs,URL_nok}];
check_first_recharge(Session,URL_ok,URL_nok)->
    Rech_CB=cast(Session),
    case Rech_CB#recharge_cb_mobi.first_recharge of
	true->
	    {redirect,Session,URL_ok};
	false->
	    {redirect,Session,URL_nok}
    end.

%%%%%%%%%% PRINT FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(MONTANT_PIVOT,50).%Les montants strictement inférieurs sont affichés dans la première page
                          %Les autres sont affichés dans la deuxième page
-define(MONTANT_MAX,100).
                          
%% +type get_plafond_montant(session())-> currency:sum().
get_plafond_montant(abs) ->
    currency:sum(euro,?MONTANT_MAX + 1);
get_plafond_montant(Session) ->
    case pbutil:get_env(pservices_orangef,rech_cb_mobi_controle_plf) of
	true->
	    #recharge_cb_mobi{plafond=Plf_}=cast(Session),
	    Plf_;
	false->
            %%%Mettre un plafond supérieur au rechargement maximum
	    currency:sum(euro,?MONTANT_MAX + 1)
    end.

%% +type show_choix_montant_suite(session(),string(),string())-> [hlink()].
show_choix_montant_suite(abs,URL,Label) ->
    [#hlink{href=URL,contents=[{pcdata,Label}]}];
show_choix_montant_suite(Session,URL,Label) ->
    PLF= get_plafond_montant(Session),
    case currency:is_infeq(currency:sum(euro,?MONTANT_PIVOT),PLF) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,Label}]}];
	false->
	    []
    end.

%% +type choix_special_edition(session())-> [hlink()].
choix_special_edition(Session) -> 
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,    
    case DCL of 
        ?click_mobi -> 
            [];
        _ -> 
 	    case svc_util_of:is_commercially_launched(Session,recharge_sl_mobi) of
 		true ->
		    [#hlink{href="#edition_speciale",contents=[{pcdata,"EDITION SPECIALE"},br]}];
 		_ ->
 		    []
 	    end
    end.

%% +type inc_choix_montant(session(),string())-> [hlink()].
inc_choix_montant_rechargeU(Session)->
    List_montant=pbutil:get_env(pservices_orangef,list_rechargeU_cb),
    lists:map(fun({Val,Bonus,Duree}) ->
		      Contents =case Bonus of
				    0 -> 
					integer_to_list(Val)++" EUR";
				    _->
					integer_to_list(Val)++" EUR + "++integer_to_list(Bonus)++" E offerts"
				end,
		      HREF = "erl://svc_recharge_cb_mobi:saisie_montant?"++
 			  integer_to_list(Val)++"&normal", 
 		      #hlink{href=HREF,contents=[{pcdata,Contents},br]} end,
 	      List_montant).

inc_choix_montant(abs,Page)->
    List_montant=pbutil:get_env(pservices_orangef,list_montant_rech_cb_mobi),
    lists:map(fun({Val,Bonus,Duree}) -> 
 		      Contents = integer_to_list(Val)++" EUR",
 		      HREF = "erl://svc_recharge_cb_mobi:saisie_montant?"++
 			  integer_to_list(Val)++"&normal", 
 		      #hlink{href=HREF,contents=[{pcdata,Contents},br]} end,
 	      List_montant);

%inc_choix_montant(abs,Page)->
%    List_montant=[{7,0,"7 jours"}],    
%    lists:map(fun({Val,Bonus,Duree}) -> 
% 		      Contents = integer_to_list(Val)++" EUR",
% 		      HREF = "erl://svc_recharge_cb_mobi:saisie_montant?"++
% 			  integer_to_list(Val)++"&normal", 
% 		      #hlink{href=HREF,contents=[{pcdata,Contents},br]} end,
% 	      List_montant);

inc_choix_montant(Session,"messg_illim") ->
%%%% ne pas afficher les montants supérieurs au plafond autorisé (débrayable)
    PLF= get_plafond_montant(Session),
    export_saisie_montant(Session,PLF,[{7,rech_7E_cb_mobi,"MESSAGES ILLIMITES"}],    
			  messg_illim,[]);

inc_choix_montant(Session,"special_edition") ->
%%%% ne pas afficher les montants supérieurs au plafond autorisé (débrayable)
    PLF= get_plafond_montant(Session),
    export_saisie_montant(Session,PLF,[{20, opt_rech_sl_20E, "20 EUR + appels illimites"}], special_edition,[]);

inc_choix_montant(Session,Page) ->
    %%%% ne pas afficher les montants supérieurs au plafond autorisé (débrayable)
    PLF= get_plafond_montant(Session),
    LIST_MONTANT=pbutil:get_env(pservices_orangef,list_montant_rech_cb_mobi),    
    %%     Acc = case pbutil:get_env(pservices_orangef,limited_recharging_line) of
    %% 	      true ->	    
    %% 		   [#hlink{href="#edition_speciale",contents=[{pcdata,"Edition speciale"},br]}];
    %% 	      _ ->
    %% 		  []
    %% 	  end,		  
    Acc = [],
    export_saisie_montant(Session,PLF,LIST_MONTANT,Page,Acc).

%% +type export_saisie_montant(session(),currency:currency(),[integer()],term(),
%%       [hlink()])->  [hlink()].
export_saisie_montant(_,_,[],Page,Acc)->
    slog:event(trace,?MODULE,saisie_montant,Acc),
    Acc;
%Christmas offer:for mobi,display recharging menu + media choice
export_saisie_montant(Session,PLF,[{AMOUNT,Option,Contents}|T],special_edition,Acc) ->
    case svc_util_of:is_commercially_launched(Session,Option) and currency:is_infeq(currency:sum(euro, AMOUNT),PLF) of
	false ->
	    export_saisie_montant(Session,PLF,T,special_edition,Acc);
	true ->
	    HREF = "erl://svc_recharge_cb_mobi:saisie_montant?"++integer_to_list(AMOUNT)++"&special_edition",
	    Acc_= Acc++[#hlink{href=HREF,contents=[{pcdata,Contents},br]}],  
	    export_saisie_montant(Session,PLF,T,special_edition,Acc_)
    end;

export_saisie_montant(Session,PLF,[{AMOUNT,Option,Contents}|T],messg_illim,Acc) ->
    case svc_util_of:is_commercially_launched(Session,Option) and currency:is_infeq(currency:sum(euro, AMOUNT),PLF) of
	false ->
	    export_saisie_montant(Session,PLF,T,messg_illim,Acc);
	true ->
	    HREF = "erl://svc_recharge_cb_mobi:saisie_montant?"++integer_to_list(AMOUNT)++"&messg_illim",
	    Acc_= Acc++[#hlink{href=HREF,contents=[{pcdata,Contents},br]}],  
	    export_saisie_montant(Session,PLF,T,messg_illim,Acc_)
    end;
	
	
export_saisie_montant(Session,PLF,[{AMOUNT,BONUS,_}|T],Page,Acc) ->
    IncludeFirstPage = (Page=="page1") and (currency:is_inf(currency:sum(euro, AMOUNT),currency:sum(euro,taking_pivot()))),
    IncludeSecondPage = (Page=="page2") and (currency:is_infeq(currency:sum(euro,taking_pivot()),currency:sum(euro,AMOUNT))),
    IncludeSomething = IncludeFirstPage or IncludeSecondPage,
    IncludeSomething2 = IncludeSomething and currency:is_infeq(currency:sum(euro, AMOUNT),PLF),
    case export_line_montant(Session,IncludeSomething2,pbutil:get_env(pservices_orangef,limited_recharging_line),{AMOUNT,BONUS}) of
	no_line ->
	    export_saisie_montant(Session,PLF,T,Page,Acc);
	Contents ->
	    HREF = "erl://svc_recharge_cb_mobi:saisie_montant?"++integer_to_list(AMOUNT)++"&normal", 
	    Acc_= Acc++[#hlink{href=HREF,contents=[{pcdata,Contents},br]}],
	    export_saisie_montant(Session,PLF,T,Page,Acc_)
    end.

export_line_montant(Session,true,Limited_recharging_line,{?RECH_20E,BONUS})->
    no_line;
export_line_montant(Session,true,Limited_recharging_line,{?RECH_7E,BONUS}) ->
    no_line;
export_line_montant(Session,true,Limited_recharging_line,?RECH_7E_MessgIllim) ->
    no_line;
export_line_montant(_,true,_,{AMOUNT,BONUS}) ->
    case BONUS of
	0->
	    integer_to_list(AMOUNT)++" EUR";
	_->
	    integer_to_list(AMOUNT)++" EUR"++" +" ++ integer_to_list(BONUS) ++ " EUR offerts"
    end;
export_line_montant(A,B,C,D) ->
    no_line.

%% +type print(session(),string())-> [{pcdata,string()}].
print(abs,S) when S=="plafond";S=="montant";S=="bonus"->
    [{pcdata,"XX"}];
print(abs,S) when S=="montant_bonus"->
    [{pcdata,"XX + XX offerts"}];
print(abs,S) when S=="duree"->
    [{pcdata,"XX jours"}];
print(Session,"plafond")->
    Plf=(cast(Session))#recharge_cb_mobi.plafond,
    [{pcdata,currency:print(Plf)}];
print(Session,"montant") ->
    Mnt=(cast(Session))#recharge_cb_mobi.montant,
    Int_Mnt=trunc(currency:round_value(Mnt)),
    [{pcdata,integer_to_list(Int_Mnt)}];
print(Session,"bonus") ->
    Bonus=(cast(Session))#recharge_cb_mobi.bonus,
    Int_Bon=trunc(currency:round_value(Bonus)),
    [{pcdata,integer_to_list(Int_Bon)}];
print(Session,"montant_bonus") ->
    Bonus=(cast(Session))#recharge_cb_mobi.bonus,
    Int_Bon=trunc(currency:round_value(Bonus)),
    Mnt=(cast(Session))#recharge_cb_mobi.montant,
    Int_Mnt=trunc(currency:round_value(Mnt)),
    Data = case Int_Bon of
	       0->
		   integer_to_list(Int_Mnt)++" euros";
	       _->
		   integer_to_list(Int_Mnt)++" euros + "++integer_to_list(Int_Bon)++
		       " euros offerts"
	   end,
  [{pcdata,lists:flatten(Data)}];

print(Session,"duree") ->
    Duree=(cast(Session))#recharge_cb_mobi.duree,
    [{pcdata,Duree}].

%%%%%%%%%%%%%%%%%% ERROR RETURN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type error_return(session(),term(),atom())-> erlpage_result().
error_return(abs,Error,Req_Name)->
    [{redirect,abs,"#system_failure"},
     {redirect,abs,"#erreur_banque_14"},
     {redirect,abs,"#erreur_banque_40"},
     {redirect,abs,"#erreur_banque_44"},
     {redirect,abs,"#erreur_banque_45"},
     {redirect,abs,"#erreur_technique"},
     {redirect,abs,"#erreur_fonctionnelle"},
     {redirect,abs,"#erreur_banque"},
     {redirect,abs,"#erreur_cb"}];
error_return(Session, {nok_banque_01, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_banque_01,Else),
    {redirect,Session,"#erreur_banque"};
error_return(Session, {nok_banque_14, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_banque_14,Else),
    {redirect,Session,"#erreur_banque_14"};
error_return(Session, {nok_banque_40, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_banque_40,Else),
    {redirect,Session,"#erreur_banque"};
error_return(Session, {nok_banque_44, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_banque_44,Else),
    {redirect,Session,"#erreur_banque_44"};
error_return(Session, {nok_banque_45, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_banque,Else),
    {redirect,Session,"#erreur_banque_45"};
error_return(Session, {nok_banque, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_banque,Else),
    {redirect,Session,"#erreur_banque"};
error_return(Session, {nok_cb, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_cb,Else),
    {redirect,Session,"#erreur_cb"};
error_return(Session, {nok_technique, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_technique,Else),
    {redirect,Session,"#erreur_technique"};
error_return(Session, {nok_fonctionnelle, Else}, pay) ->
    slog:event(trace,?MODULE,error_return_nok_fonctionnelle,Else),
    {redirect,Session,"#erreur_fonctionnelle"};
error_return(Session,Else,Request_name)->  
    %% timeout or erreur http, ou encodage/decodage
    slog:event(trace,?MODULE,error_return_default,{Else,Request_name}),
    Class = pbutil:get_env(pservices_orangef,alarm_class_rech_cb),
    {redirect,Session,"#system_failure"}.

%%%%%%%%% GENERIC FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type update_recharge_cb(session(),[{Name::atom(),Value::term()}])->
%%                  session().
update_recharge_cb(Session,Values)->
    State = svc_util_of:get_user_state(Session),
    Fields = record_info(fields, recharge_cb_mobi),
    %% Read the default permissions.
    RCB1=
	case cast(Session) of
	    #recharge_cb_mobi{}=RC->
		RC;
	    Else->
		#recharge_cb_mobi{}
	end,
    RCB2=pbutil:update_record(Fields, RCB1, Values),
    svc_util_of:update_user_state(Session,
				  State#sdp_user_state{tmp_recharge=RCB2}).

%% +type cast(session())-> recharge_cb_mobi().
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#sdp_user_state.tmp_recharge.

%% +deftype saisie_type()= no_cb | date_valid | cvx2.
%% +type verif_saisie(string(),saisie_type())-> bool().
verif_saisie(NO_CB,no_cb) when length(NO_CB)>=16,length(NO_CB)=<19->
    pbutil:all_digits(NO_CB) and is_cle_luhn(NO_CB);
verif_saisie(CVX2,cvx2) when length(CVX2)==3->
    pbutil:all_digits(CVX2);
verif_saisie(DATE,date_valid) when length(DATE)==4->
    is_date_ok(DATE);
verif_saisie(Lucky_Nb,refill_game) ->
    case pbutil:all_digits(Lucky_Nb) of
	true ->
	    (list_to_integer(Lucky_Nb) >=1)
		and(list_to_integer(Lucky_Nb)=<7);
	_ ->
	    false
    end;
verif_saisie(_,_)->
    false.
    
verif_saisie_no_choix(Number,number) 
  when is_list(Number), length(Number)==10 ->    
    pbutil:all_digits(Number);
verif_saisie_no_choix(_,_) ->
    false.


%% update comptes
%% mettre a jour le plafond
%% detecté si un ou plusiers compte de rechargement.
%% renvoie d'une url en fonction
%% +type update_session_af_rech(session(),[integer()],
%%                              [pbutil:unixtime()],[integer()],[integer()],
%%                              [integer()],[integer()])-> 
%%     {URL::string(),session()}.
update_session_af_rech(Session,
		       TCP_NUM,CPP_DATE_LV,
		       SOLDE,UNT_NUM,BONUS_PCT,BON_MNT)->

    #recharge_cb_mobi{montant=Montant} = cast(Session),
    #recharge_cb_mobi{trc_num=Choix} = cast(Session),
    State = svc_util_of:get_user_state(Session),
    State1=decode_compte(TCP_NUM,CPP_DATE_LV,SOLDE,UNT_NUM,BONUS_PCT,BON_MNT,State),
    [Amount]=io_lib:format("~p",[trunc(currency:round_value(Montant))]),
    
    {url_succes(TCP_NUM,Choix,list_to_integer(Amount)),svc_util_of:update_user_state(Session,State1)}.

%% +type decode_compte([integer()],[pbutil:unixtime()],[integer()],[integer()],
%%                     [integer()],[integer()],sdp_user_state())-> 
%%   sdp_user_state().
decode_compte([],_,_,_,_,_,State)->
    State;
decode_compte([?C_PRINC|TCP_NUM],[C1|CPP_DATE_LV],
	      [S1|SOLDE],[U1|UNT_NUM],[B1|BONUS_PCT],[BN1|BON_MNT],State)->
    Compte=#compte{}=svc_compte:cpte(State,cpte_princ),
    Cpte1=Compte#compte{cpp_solde=svc_compte:calcul_solde(S1,U1),
			dlv=C1,
			etat=?CETAT_AC},
    %% mnt_bonus=svc_compte:calcul_solde(BN1,?EURO)
    decode_compte(TCP_NUM,CPP_DATE_LV,SOLDE,UNT_NUM,BONUS_PCT,BON_MNT,
		  State#sdp_user_state{cpte_princ=Cpte1});
decode_compte([T1|TCP_NUM],[C1|CPP_DATE_LV],
	      [S1|SOLDE],[U1|UNT_NUM],[B1|BONUS_PCT],[BN1|BON_MNT],State)->
    Cpte = svc_compte:search_cpte(T1, undefined),
    AccountInfo = case svc_compte:cpte(State,Cpte) of
		undefined->
		    #compte{};
		no_cpte_found->
		    #compte{};
		#compte{}=CPT->
		    CPT
	    end,
    NewAccountInfo=AccountInfo#compte{tcp_num=T1,
				      unt_num=U1,
				      cpp_solde=svc_compte:calcul_solde(S1,U1),
				      dlv=C1,
				      etat=?CETAT_AC,
				      mnt_bonus=svc_compte:calcul_solde(BN1,?EURO)},
    List = State#sdp_user_state.cpte_list,
    case List of
	undefined ->
	    decode_compte(TCP_NUM,CPP_DATE_LV,SOLDE,UNT_NUM,BONUS_PCT,BON_MNT,
			  State#sdp_user_state{cpte_list=[{Cpte,NewAccountInfo}]});
	_ ->
	    State2=svc_compte:update_sdp_user_state(List,State,Cpte,NewAccountInfo,[]),
	    decode_compte(TCP_NUM,CPP_DATE_LV,SOLDE,UNT_NUM,BONUS_PCT,BON_MNT, State2)
    end.

%% +type url_succes([integer()])-> URL::string().
url_succes([?C_PRINC,?C_SL_7E],"0",_)->
    "#redir_success_limite_7";
url_succes([?C_PRINC,?C_ILLIMITE_KDO],"0",_)->
    "#success_unlimited_20";	    
url_succes([?C_PRINC,?C_SMS],"0",_)->
    "#succes_princ_sms";
url_succes([?C_PRINC],"0",_) ->
   "#succes_princ";
url_succes(LIST,"0",_) ->
    case (lists:member(?C_ROAMING_OUT, LIST) and
	  lists:member(?C_ROAMING_IN, LIST)) of
	true ->
	    "recharge.xml#success_vacances";
	_ ->
	    slog:event(failure, ?MODULE, unexpected_respond, LIST),
	    "recharge.xml#system_failure"
    end;
%% url_succes(_,"5",?RECH_20E) ->
%%     "#succes_sl_20E";

url_succes([?C_PRINC],"1",?RECH_10E) ->
    "#succes_sl_10E";
url_succes([?C_PRINC],"1",?RECH_20E) ->
    "#succes_sl_20E";
url_succes([?C_PRINC],"1",?RECH_30E) ->
    "#succes_sl_30E";
url_succes([?C_PRINC],"1",?RECH_7E) ->
    "#succes_7E_mms_v2";
url_succes([?C_PRINC],"3",?RECH_15E) ->
    "#succes_15E_Europe_1";
url_succes(_,"3",?RECH_15E) ->
    "#succes_sl_15E";
url_succes(_,"0",?RECH_7E) ->
    "#succes_sl_7E".
% Change Pivot value in case of unlimited recharging
% in order to display :Suite in first page.
taking_pivot()->
    case pbutil:get_env(pservices_orangef,unlimited_recharging) or 
	pbutil:get_env(pservices_orangef,recharge_vacances) of
	true ->
	    25;
	false ->
	    ?MONTANT_PIVOT
    end.
%% Check if the customer is available for CB recharging service.
%% +type is_recharging_avail([sdp_user_state()])-> bool().
is_recharging_avail(State)->
    Activ_date = State#sdp_user_state.d_activ,
    Today_date = pbutil:unixtime(),
    case (Today_date - Activ_date) >= ?MONTH_IN_SEC of
	true ->
	    true;
	_ ->
	    false
    end.

do_souscription(abs,Option) ->
    [{"Subscription "++atom_to_list(Option)++
      " successful",{redirect,abs,"#success_"++atom_to_list(Option)}},
     {"Subscription "++atom_to_list(Option)++
      " failure",{redirect,abs,"#temporary"}}];
  
do_souscription(Session,Option) when Option == mobile_prize;
				     Option == opt_sinf_kdo;
				     Option == mobile_prize_2 ->
    {Session_new,State} = svc_options:check_topnumlist(Session),
    case svc_options:do_opt_cpt_request(Session_new,
					Option,
					subscribe) of
	{Session2,{ok_operation_effectuee,_}} ->
	    slog:event(trace, ?MODULE, do_souscription, 
		       list_to_atom("opt_" ++ atom_to_list(Option))),
	    {redirect,Session2,"#success_"++atom_to_list(Option)};
	{Session2,Else} ->
	    slog:event(service_ko, ?MODULE, do_souscription, 
		       {Option, 
			State#sdp_user_state.msisdn,				
			Else}),
	    {redirect, Session2, "#temporary"}
    end.


%% +type is_lucky_number(session(),string())-> erlpage_result().
is_lucky_number(abs,_)->
    	[{redirect,abs,"#loosing_case"},
	{redirect,abs,"#temporary"},
    	do_souscription(abs,mobile_prize) ++
	do_souscription(abs,opt_sinf_kdo) ++
	do_souscription(abs, mobile_prize_2)];	

is_lucky_number(#session{prof=#profile{msisdn=Msisdn}}=Session, Lucky_number)->
    %% Check client entered one digit between 1 and 7.
    case verif_saisie(Lucky_number,refill_game) of 
	true->
	    {Date,Hours}=svc_util_of:local_time(),
	    Key =svc_util_of:local_time_to_unixtime({Date,Hours}),
	    case lookup_winnings(Key, Msisdn, refill_game) of
		{atomic,#refill_game{}=Resp} ->
		    winner_infos(Msisdn, Resp),
		    case Resp#refill_game.winnings of
			mobile_prize ->
			    slog:event(trace,?MODULE,mobile_prize_won,Msisdn),
			    do_souscription(Session, mobile_prize);
			opt_sinf ->
			    slog:event(trace,?MODULE,sinf_won,Msisdn),
			    do_souscription(Session, opt_sinf_kdo)
 		    end;
		{atomic, []} ->
		    do_souscription(Session, mobile_prize_2)
	    end;
	false->
	    {redirect,Session,"#loosing_case"}
    end.

%%% look up winnings on refill_game/logo_table mnesia table according to
%%% to date and hour of refill operation.
%% +type lookup_winnings(Mnesia_table::string(),Key::string())-> Mnesia_table::record().
lookup_winnings(Key, Msisdn, refill_game)->
    Fun =
	fun() ->
		Guard     = {'<', '$1', Key}, %% $1::Date in table < Key::local_time()
		Result    = '$1',
		MatchHead = #refill_game{winnings_date  ='$1',
					 winnings       ='$2', %% the prize
					 winnings_state =true, %% prize not
					 %% attribued yet
					 winning_msisdn =undefined},
		    case mnesia:select(refill_game,
					 [{MatchHead, [Guard], [Result]}],write) of
			%% no available prizes
			[] -> [];
			%% associate MSISDN to the prize
			Key_list ->
			    Key_lastWinning = lists:min(Key_list),
			    case mnesia:read(refill_game, Key_lastWinning, write) of
				[#refill_game{}=Row] ->
				    New_Row = 
					Row#refill_game{winnings_state= false,
							winning_msisdn= list_to_integer(Msisdn)},
				    mnesia:write(New_Row),
				    New_Row;
				Empty_list ->
				    Empty_list
			    end
		    end
		end,
    mnesia:transaction(Fun);
lookup_winnings(Key, Msisdn, logo_table)->
    Fun =
	fun() ->
		case mnesia:read(logo_table, Key, write) of
		    [#logo_table{}=Row] ->
			case Row#logo_table.daily_winnings_nb of
			    0 ->
				[];
			    Count ->
				New_count = Count - 1,
				New_Row = Row#logo_table{daily_winnings_nb=New_count},
				mnesia:write(New_Row),
				%dump_msisdn_on_disc(Msisdn, New_count),
				New_Row
			end;
		    Empty_list ->
			Empty_list
		end
	end,
    mnesia:transaction(Fun).


%%% Check if it's a winning logo date.
%% +type lookup_winnings(session(), Key::string(), Msisdn::string())-> Mnesia_table::record().
check_logo_table(abs, Key, Msisdn)->
    [{"Pas de chance: PERDU!",{redirect,abs,"#loosing_case"}},
     {"GAIN LOGO",{redirect,abs,"#logo_winner"}}];
check_logo_table(Session, Key, Msisdn) ->
    case lookup_winnings(Key, Msisdn, logo_table) of
	{atomic,#logo_table{}=Resp} ->
	    winner_infos(Msisdn, Resp),
	    svc_core:redir_handset(Session,
				   "wap_push",
				   "equal",
				   "indication=#wap_push,?=#sms_clickable");
	{atomic, []} ->
		    {redirect,Session,"#loosing_case"}
    end.

%%% Send sms wap or sms clickable.
%% +type send_sms(session(), Key::string(), Msisdn::string())-> erl_page().
send_sms(#session{prof=#profile{msisdn=Msisdn}}=Session,Type,
	 Message,Sms_url,Encoding, Origin, 
	 Routing, Receipt,Url_ok,Url_nok) ->
    Function = list_to_existing_atom(Type),
    svc_wap_push:Function(Session,
			  Message,
			  Sms_url,
			  Encoding,
			  Origin,
			  Msisdn,
			  Routing,
			  Receipt,
			  Url_ok,
			  Url_nok).
  
%%% Display traces about customer profile.
%% +type winner_infos(session(),refill_game:record())-> erlpage_result().
winner_infos(Msisdn, Refill_game)->
    slog:event(trace, ?MODULE,refill_game_winner_infos, 
		       {Msisdn, Refill_game}).

do_confirm(#session{prof=Profile}=Session, Opt, URL, URL_Nok) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:do_consultation(Session, list_to_atom(Opt)) of 
	{ok,[Zone70,Zone80,_]} ->
	    StateZ70 = svc_compte:decode_z70(Zone70,State),
	    NSession = svc_util_of:update_user_state(Session, StateZ70),
	    {redirect, NSession, URL};
        {ok, {Session_resp, Resp_params}} ->
%%             Zone70 = svc_util_of:get_param_value("OP_PARAMS", Resp_params),
%% 	    NewState =  svc_compte:decode_z70(Zone70,State),
%% 	    NewSession = svc_util_of:update_user_state(Session,NewState),
            {redirect, Session_resp, URL};
	{nok_opt_inexistante_dossier, Else} ->
	    slog:event(warning, ?MODULE, nok_opt_inexistante_dossier, Else),
	    {redirect, Session, URL};
        {nok, Reason} ->
	    slog:event(warning, ?MODULE, do_confirm_do_consultation, Reason),
	    {redirect, Session, URL};
	Error ->
	    slog:event(warning, ?MODULE, do_confirm_ko, Error),
	    {redirect, Session, URL_Nok}	    
    end.
