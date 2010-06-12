-module(svc_parentChild).

-export([acces_service/2,
	 auth/1,
	 tester_validite_saisie_codeconf/2,
	 check_code_conf/1,
	 check_eligib_rechargeur/1,
	 print_field/2,
	 tester_validite_init_codeconf/2,
	 set_code_conf/1,
	 redir_saisie_msisdn/2,
	 reinit_and_redir_saisi_msisdn/1,
	 check_eligib_recharge/1,
	 redir_recharg/1,
	 print_liens_montant/1,
	 print_validite/1,
	 svg_choix_redir/4,
	 set_rechargement/1,
	 type_catalogue/0]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../include/postpaid.hrl").


-record(bonus,{montant, bonus_mobi, validite_mobi, bonus_cmo}).

-record(pChild,{
	  idDossier,
	  dateProchainRechargementCmo,
	  dateProchainRechargementMobicarte,
	  prestationsCmo,
	  prestationsMobicarte,
	  nbSaisiesCode,
	  codeSaisi,
	  nbSaisiesMsisdn,
	  msisdnRecharge,
	  idDossierOrchidee,
	  idDossierSachem,
	  mobicarte,
	  rechargement,
	  dateProchRecharg,
	  prestation,
	  code,
	  montant,
	  recharge
	 }).

read_pc_field(idDossier,                             #pChild{idDossier=V})                         -> V;
read_pc_field(dateProchainRechargementCmo,           #pChild{dateProchainRechargementCmo=V})       -> V;
read_pc_field(dateProchainRechargementMobicarte,     #pChild{dateProchainRechargementMobicarte=V}) -> V;
read_pc_field(prestationsCmo,                        #pChild{prestationsCmo=V})                    -> V;
read_pc_field(prestationsMobicarte,                  #pChild{prestationsMobicarte=V})              -> V;
read_pc_field(nbSaisiesCode,     #pChild{nbSaisiesCode=V})     -> V;
read_pc_field(nbSaisiesMsisdn,   #pChild{nbSaisiesMsisdn=V})   -> V;
read_pc_field(msisdnRecharge,    #pChild{msisdnRecharge=V})    -> V;
read_pc_field(codeSaisi,         #pChild{codeSaisi=V})         -> V;
read_pc_field(idDossierOrchidee, #pChild{idDossierOrchidee=V}) -> V;
read_pc_field(idDossierSachem,   #pChild{idDossierSachem=V})   -> V;
read_pc_field(rechargement,      #pChild{rechargement=V})      -> V;
read_pc_field(dateProchRecharg,  #pChild{dateProchRecharg=V})  -> V;
read_pc_field(prestation,        #pChild{prestation=V})        -> V;
read_pc_field(code,              #pChild{code=V})              -> V;
read_pc_field(recharge,          #pChild{recharge=V})          -> V;
read_pc_field(mobicarte,         #pChild{mobicarte=V})         -> V;
read_pc_field(montant,           #pChild{montant=V})           -> V.

write_pc_field({idDossier,                         V}, PC) -> PC#pChild{idDossier=V};
write_pc_field({dateProchainRechargementCmo,       V}, PC) -> PC#pChild{dateProchainRechargementCmo=V};
write_pc_field({dateProchainRechargementMobicarte, V}, PC) -> PC#pChild{dateProchainRechargementMobicarte=V};
write_pc_field({prestationsCmo,                    V}, PC) -> PC#pChild{prestationsCmo=V};
write_pc_field({prestationsMobicarte,              V}, PC) -> PC#pChild{prestationsMobicarte=V};
write_pc_field({nbSaisiesCode,     V}, PC) -> PC#pChild{nbSaisiesCode=V};
write_pc_field({nbSaisiesMsisdn,   V}, PC) -> PC#pChild{nbSaisiesMsisdn=V};
write_pc_field({msisdnRecharge,    V}, PC) -> PC#pChild{msisdnRecharge=V};
write_pc_field({codeSaisi,         V}, PC) -> PC#pChild{codeSaisi=V};
write_pc_field({idDossierOrchidee, V}, PC) -> PC#pChild{idDossierOrchidee=V};
write_pc_field({idDossierSachem,   V}, PC) -> PC#pChild{idDossierSachem=V};
write_pc_field({rechargement,      V}, PC) -> PC#pChild{rechargement=V};
write_pc_field({dateProchRecharg,  V}, PC) -> PC#pChild{dateProchRecharg=V};
write_pc_field({prestation,        V}, PC) -> PC#pChild{prestation=V};
write_pc_field({code,              V}, PC) -> PC#pChild{code=V};
write_pc_field({recharge,          V}, PC) -> PC#pChild{recharge=V};
write_pc_field({mobicarte,         V}, PC) -> PC#pChild{mobicarte=V};
write_pc_field({montant,           V}, PC) -> PC#pChild{montant=V}.

type_catalogue() ->
    {list, type_record_bonus()}.
type_record_bonus() ->
    {record, "", bonus,
     [{montant, string, "Montant"},
      {bonus_mobi, string, ""},
      {validite_mobi, string, ""},
      {bonus_cmo, string, ""}]}.

%% +type read_field(FieldN::atom(), session()) -> term().
%%% Lecture d'un champ de #pChild
read_field(FieldN, Session) ->
    read_pc_field(FieldN, read_pc(Session)).

%% +type read_pc(session()) -> term().
%%% Lecture du #pChild
read_pc(Session) ->
    State = svc_util_of:get_user_state(Session),
    State#postpaid_user_state.parentChild.

%% +type write_fields([{FieldN::atom(),term()}], session()) -> session().
%%% Ecriture de plusieurs champs dans le record #pChild
write_fields(Pairs,Session) ->
    PC = read_pc(Session),
    slog:event(trace,?MODULE,?LINE,[read_pc, PC]),
    X = write_pc(Session, write_pc_fields(Pairs,PC)),
    slog:event(trace,?MODULE,?LINE,[write_pc,X]),
    X.

%% +type write_field({FieldN::atom(),term()}, session()) -> session().
%%% Ecriture d'un champ dans le record #pChild
write_field(Pair,Session) ->
    PC = read_pc(Session),
    write_pc(Session, write_pc_field(Pair,PC)).

%% +type write_pc(session(), term()) -> session(). 
%%% Ecriture du pChild dans la session
write_pc(Session, PC) ->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,
				  State#postpaid_user_state{parentChild=PC}).

write_pc_fields(Pairs, PC) -> lists:foldl(fun write_pc_field/2, PC, Pairs).



acces_service(abs, Text) ->
    [#hlink{href="selfcare_long/parentChild.xml",contents=[{pcdata,Text}]}];
acces_service(Session, Text) ->
    case (Session#session.prof)#profile.msisdn of
	{na, _} -> [];
	_ ->
	    case get_env(acces_service_parentChild) of
		ouvert -> [#hlink{href="selfcare_long/parentChild.xml",
				  contents=[{pcdata,Text}]}];
		ferme -> []
	    end
    end.

auth(abs) ->
    [ {redirect, abs, "#PC_saisie_codeconf"},
      {redirect, abs, "#PC_codeconf_bloque"},
      {redirect, abs, "#PC_init_codeconf"},
      {redirect, abs, "#PC_codeconf_ecrase"},
      {redirect, abs, "#PC_nonrepASM"} ];
auth(Session) ->
    Msisdn = msisdn_nat(Session),
    case asmetier_webserv:getCodeConfidentiel(Msisdn) of
	#getRcodResponse
	{listeRcodItem=
	 #listeRcodItem{nbTentatives=NBT}} when integer(NBT) ->
	    Session2 = write_pc(Session, #pChild{}),
	    analyse_nbtent_and_redir(Session2, NBT);
	#'ECareExceptionTechnique'{} = Exception -> 
	    slog:event(failure, ?MODULE, auth_eCareExceptionTechnique, Exception),
	    {redirect, Session, "#PC_nonrepASM"};
	{error,timeout} ->
	    slog:event(failure,?MODULE, getRcod_timeout),
	    {redirect,Session,"#PC_nonrepASM"};
	Other ->
	    slog:event(failure, ?MODULE, auth_UnknownError, Other),
	    {redirect, Session, "#PC_nonrepASM"}
    end.

analyse_nbtent_and_redir(Session, NBT) ->
    case NBT of
	X when X>0 ->
	    Session2 = write_field({nbSaisiesCode, NBT}, Session),
	    {redirect, Session2, "#PC_saisie_codeconf"};
	0 ->
	    {redirect, Session, "#PC_codeconf_bloque"};
	-1 ->
	    Session2 = write_field({nbSaisiesCode, 3}, Session),
	    {redirect, Session2, "#PC_init_codeconf"};
	-2 ->
	    Session2 = write_field({nbSaisiesCode, 3}, Session),
	    {redirect, Session2, "#PC_codeconf_ecrase"}
    end.
    

msisdn_nat(#session{prof=#profile{msisdn=[$+,$3,$3|Msisdn]}}) -> [$0|Msisdn].

tester_validite_saisie_codeconf(abs, CodeSaisie) ->
    [{redirect, abs, "erl://"?MODULE_STRING":check_code_conf"},
     {redirect, abs, "#PC_saisie_codeconf_erreur"},
     {redirect, abs, "#PC_saisie_codeconf_epuise"}];
tester_validite_saisie_codeconf(Session, CodeSaisie) ->
    NbTent = read_field(nbSaisiesCode, Session)-1,
    case is_four_digits(CodeSaisie) of
	true -> 
	    Session2 = write_field({codeSaisi, CodeSaisie}, Session),
	    {redirect, Session2, "erl://"?MODULE_STRING":check_code_conf"};
	false -> 
	    case (NbTent > 0) of
		true -> 
		    Session2 = write_field({nbSaisiesCode,NbTent}, Session),
		    {redirect, Session2, "#PC_saisie_codeconf_erreur"};
		false -> 
		    {redirect, Session, "#PC_saisie_codeconf_epuise"}
	    end
    end.

is_four_digits(CodeSaisie) ->
    pbutil:all_digits(CodeSaisie) and (length(CodeSaisie) == 4).    

check_code_conf(abs) ->
    [{redirect, abs, "erl://"?MODULE_STRING":check_eligib_rechargeur"},
     {redirect, abs, "#PC_nonrepASM"}];
check_code_conf(Session) ->
    #pChild{codeSaisi=CodeSaisie,
	    nbSaisiesCode=NbTent} = read_pc(Session),
    Msisdn = msisdn_nat(Session),
    case asmetier_webserv:checkCodeConfidentiel(Msisdn, CodeSaisie) of
	#getVcodResponse{resultat="0000"} ->
	    {redirect, Session,"erl://"?MODULE_STRING":check_eligib_rechargeur"};
        #'ECareExceptionFonctionnelleCodeWrong'{}=ECareExceptionFonctionnelleCodeWrong ->
	    Session2 = write_field({nbSaisiesCode,NbTent-1}, Session),
	    slog:event(failure,?MODULE, checkCodeConf_ECareExceptionFonctionnelleCodeWrong,ECareExceptionFonctionnelleCodeWrong),
            {redirect, Session2, "#PC_saisie_codeconf_erreur"};
        #'ECareExceptionFonctionnelleCodeLock'{}=ECareExceptionFonctionnelleCodeLock ->
	    slog:event(failure,?MODULE, checkCodeConf_ECareExceptionFonctionnelleCodeLock,ECareExceptionFonctionnelleCodeLock),
	    analyse_nbtent_and_redir(Session, 0);
        #'ECareExceptionFonctionnelleCodeNotInit'{}=ECareExceptionFonctionnelleCodeNotInit ->
	    slog:event(failure,?MODULE, checkCodeConf_ECareExceptionFonctionnelleCodeNotInit,ECareExceptionFonctionnelleCodeNotInit),
	    analyse_nbtent_and_redir(Session, -1);
        #'ECareExceptionFonctionnelleCodeInhb'{}=ECareExceptionFonctionnelleCodeInhb ->
	    slog:event(failure,?MODULE, checkCodeConf_ECareExceptionFonctionnelleCodeInhb,ECareExceptionFonctionnelleCodeInhb),
	    analyse_nbtent_and_redir(Session, -2);
        #'ECareExceptionFonctionnelleCodeInhbTemp'{}=ECareExceptionFonctionnelleCodeInhbTemp ->
	    slog:event(failure,?MODULE, checkCodeConf_ECareExceptionFonctionnelleCodeInhbTemp,ECareExceptionFonctionnelleCodeInhbTemp),
	    analyse_nbtent_and_redir(Session, -2);
        #'ECareExceptionTechnique'{}=ECareExceptionTechnique ->
	    slog:event(failure,?MODULE, checkCodeConf_ECareExceptionTechnique,ECareExceptionTechnique),
	    {redirect,Session,"#PC_nonrepASM"};
	{error,timeout} ->
	    slog:event(failure,?MODULE, checkCodeConf_timeout),
	    {redirect,Session,"#PC_nonrepASM"};
	Other ->
	    slog:event(failure,?MODULE, checkCodeConf_UnknownError,Other),
	    {redirect, Session, "#PC_nonrepASM"}
    end.

check_eligib_rechargeur(abs) ->
    [{redirect, abs, "#PC_eligi_plafond"},
     {redirect, abs, "#PC_saisie_MSISDN"},
     {redirect, abs, "#PC_eligi_noninscrit"},
     {redirect, abs, "#PC_eligi_erreur"}];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PC Janvier 2009 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AsMetier G8R2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_eligib_rechargeur(Session) ->
    Msisdn = msisdn_nat(Session),
     case asmetier_webserv:checkRechargementParentChild(Msisdn, "") of
	 #isRechargementParentChildPossibleResponse
	 {idDossier=IdDossier,
	  dateProchainRechargementCmo=DPRCmo,
	  dateProchainRechargementMobicarte=DPRMobicarte,
	  prestationsCmo=PCmo,
	  prestationsMobicarte=PMobicarte} ->
	     Session2 = write_fields([{nbSaisiesMsisdn, 3},
				      {idDossierOrchidee, IdDossier},
				      {dateProchainRechargementCmo, DPRCmo},
				      {dateProchainRechargementMobicarte, DPRMobicarte},
				      {prestationsCmo, PCmo},
				      {prestationsMobicarte, PMobicarte}
				     ], Session),
	     {redirect, Session2, "#PC_saisie_MSISDN"};
	 
	 #'ExceptionServiceOptionnelRequis'{} ->
	     {redirect, Session, "#PC_eligi_noninscrit"};
	 Error when 
	 Error==#'ExceptionErreurInterne'{};
	 Error==#'ExceptionRegleNonVerifiee'{};
	 Error==#'ExceptionPlanRecouvrementIncorrect'{};
	 Error==#'ECareExceptionTechnique'{};
	 Error==#'ExceptionDossierNonTrouve'{};
	 Error==#'ExceptionTypeClientIncorrect'{};
	 Error==#'ExceptionEtatDossierIncorrect'{};
	 Error==#'ExceptionServiceOptionnelBloquant'{};
	 Error==#'ExceptionEtatRecouvrementIncorrect'{};
	 Error==#'ExceptionProduitIncorrect'{};
	 Error==#'ExceptionDonneesInvalides'{} ->	 
	     slog:event(failure, ?MODULE, checkEligibRechargeur_case_clause,
			{Msisdn, Error}),
	     {redirect, Session, "#PC_eligi_erreur"};
	 {error,timeout} ->
	     slog:event(failure,?MODULE, checkEligibRechargeur_timeout),
	     {redirect, Session, "#PC_nonrepASM"};
	 _ ->
	     {redirect, Session, "#PC_nonrepASM"}
     end.

get_date(Date) ->
    {[Y,M,D,_],[]} = pbutil:sscanf("%d-%d-%d%s", Date),
    {Y,M,D}.

print_field(abs, "recharge") -> 
    [#hlink{contents=[PCDATA|_]}|_] = print_liens_montant(abs),
    [PCDATA];
print_field(abs, FieldN) -> [{pcdata, FieldN}];
print_field(Session, "dateProchRecharg") ->
    {Y,M,D} = read_field(dateProchRecharg, Session),
    [{pcdata, lists:flatten(io_lib:format("~2..0w/~2..0w/~4..0w", [D,M,Y]))}];
print_field(Session, FieldN) ->
    FieldV = read_field(list_to_atom(FieldN), Session),
    [{pcdata, fieldval2string(FieldV)}].

fieldval2string(Val) when integer(Val) -> integer_to_list(Val);
fieldval2string(Val) when list(Val) -> Val.

tester_validite_init_codeconf(abs, CodeSaisie) ->
    [{redirect, abs, "#PC_init_codeconf_confirm"},
     {redirect, abs, "#PC_init_codeconf_erreur"},
     {redirect, abs, "#PC_init_codeconf_epuise"}];
tester_validite_init_codeconf(Session, CodeSaisie) ->
    NbTent = read_field(nbSaisiesCode, Session)-1,
    case is_four_digits(CodeSaisie) of
	true ->
	    Session2 = write_field({codeSaisi, CodeSaisie}, Session),
	    {redirect, Session2, "#PC_init_codeconf_confirm"};
	false -> 
	    case (NbTent > 0) of
		true -> 
		    Session2 = write_field({nbSaisiesCode, NbTent}, Session),
		    {redirect, Session2, "#PC_init_codeconf_erreur"};
		false -> 
		    {redirect, Session, "#PC_init_codeconf_epuise"}
	    end
    end.

set_code_conf(abs) ->
    [{redirect, abs, "#PC_init_codeconf_succes"},
     {redirect, abs, "#PC_nonrepASM"}];
set_code_conf(Session) ->
    CodeSaisie = read_field(codeSaisi, Session),
    Msisdn = msisdn_nat(Session),
    case asmetier_webserv:setCodeConfidentiel(Msisdn, CodeSaisie) of
	#getMcodResponse{nbTentatives=NBT}
	when integer(NBT),NBT>0 ->
	    {redirect, Session, "#PC_init_codeconf_succes"};
	#getMcodResponse{}=Resp ->
	    slog:event(failure, ?MODULE, setCodeConfResp_case_clause, Resp),
	    {redirect, Session, "#PC_nonrepASM"};
	#'ECareExceptionTechnique'{}=Exception ->
	    slog:event(failure, ?MODULE, setCodeConfResp_ECareExceptionTechnique, Exception),
	    {redirect, Session, "#PC_nonrepASM"};
	{error,timeout} ->
	    slog:event(failure,?MODULE, setCodeConfResp_timeout),
	    {redirect,Session,"#PC_nonrepASM"};
	Other ->
	    slog:event(failure, ?MODULE, set_code_conf_UnknownError, Other),
	    {redirect, Session, "#PC_nonrepASM"}
    end.

redir_saisie_msisdn(abs, MsisdnSaisi) ->
    [{redirect, abs, "#PC_saisie_MSISDN_confirm"},
     {redirect, abs, "#PC_saisie_MSISDN_erreur1"},
     {redirect, abs, "#PC_saisie_MSISDN_erreur2"},
     {redirect, abs, "#PC_saisie_MSISDN_erreur3"},
     {redirect, abs, "#PC_saisie_MSISDN_epuise"}];
redir_saisie_msisdn(Session, MsisdnSaisi) ->
    NbTent = read_field(nbSaisiesMsisdn, Session),
    case NbTent > 0 of
	true ->
	    Session2 = write_field({nbSaisiesMsisdn, NbTent-1}, Session),
	    redir_saisie_msisdn1(Session2, MsisdnSaisi);
	false -> 
	    {redirect, Session, "#PC_saisie_MSISDN_epuise"}
    end.

redir_saisie_msisdn1(Session, MsisdnSaisi) ->
    case MsisdnSaisi of
	[$0,H|_] when H==$6;H==$7 -> 
	    case length(MsisdnSaisi) of
		10 ->
		    case pbutil:all_digits(MsisdnSaisi) of
			true -> 
			    Sess2 = write_field({msisdnRecharge, MsisdnSaisi},
						Session),
			    {redirect, Sess2, "#PC_saisie_MSISDN_confirm"};
			false -> 
			    {redirect, Session, "#PC_saisie_MSISDN_erreur3"}
		    end;
		_ -> {redirect, Session, "#PC_saisie_MSISDN_erreur2"}
	    end;
	_ -> {redirect, Session, "#PC_saisie_MSISDN_erreur1"}
    end.

reinit_and_redir_saisi_msisdn(abs) ->
    [{redirect, abs, "#PC_saisie_MSISDN"}];
reinit_and_redir_saisi_msisdn(Session) ->
    Session2 = write_field({nbSaisiesMsisdn, 3}, Session),
    {redirect, Session2, "#PC_saisie_MSISDN"}.

check_eligib_recharge(abs) ->
    [{redirect, abs, "#PC_select_montant"},
     {redirect, abs, "#PC_saisie_MSISDN_erreur3"},
     {redirect, abs, "#PC_saisie_MSISDN_NOK"},
     {redirect, abs, "#PC_nonrepASM"}];    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   PC Janvier 2009   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%    Asmetier G8R2    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_eligib_recharge(Session) ->
    MSISDN_RECHARGE = read_field(msisdnRecharge, Session),
    case asmetier_webserv:isRechargeableParentChild(MSISDN_RECHARGE) of 
	#isRechargeableParentChildResponse
	{idDossier=IdDossier,
	 mobicarte=Mob} ->
	    Session2 = write_fields([{idDossierSachem, IdDossier},
				     {mobicarte, Mob}], Session),
           {redirect, Session2, "erl://"?MODULE_STRING":redir_recharg"};
	#'ExceptionDossierNonOrange'{} ->
	    NbT = read_field(nbSaisiesMsisdn, Session),
	    Session2 = write_field({nbSaisiesMsisdn, NbT+1}, Session),
	    {redirect, Session2, "#PC_saisie_MSISDN_erreur3"};
	Resp when 
	      Resp==#'ECareExceptionTechnique'{};
	      Resp==#'ExceptionEtatDossierIncorrect'{};
	      Resp==#'ECareExceptionFonctionnelle'{} ->
	    slog:event(failure, ?MODULE, checkEligibRecharge_case_clause,
		       {MSISDN_RECHARGE, Resp}),
	    {redirect, Session, "#PC_saisie_MSISDN_NOK"};
	{error,timeout} ->
	    slog:event(failure,?MODULE, checkEligibRecharge_timeout),
	    {redirect,Session,"#PC_nonrepASM"};
	 _ ->	    
           {redirect, Session, "#PC_nonrepASM"}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PC Janvier 2009 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Asmetier G8R2  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
redir_recharg(Session) ->
     #pChild{dateProchainRechargementCmo=DPRCmo,
	     dateProchainRechargementMobicarte=DPRMobicarte,
	     prestationsCmo=PCmo,
	     prestationsMobicarte=PMobicarte,
	     mobicarte=Mob} = read_pc(Session),
    case {DPRMobicarte, PMobicarte, DPRCmo, PCmo, Mob} of 
	 {_,_,DPRCmo, PCmo, false} ->
	    case DPRCmo of 
		DPRCmo when (DPRCmo =/="" andalso DPRCmo =/= undefined) ->
		    D2 = get_date(DPRCmo),
		    Session2 = write_field({dateProchRecharg, D2}, Session),
		    {redirect, Session2, "#PC_eligi_plafond"};
		_ ->
		    case PCmo of 
			PCmo when (PCmo =/="" andalso PCmo =/= undefined) ->
			     Session2 = write_field({prestation, PCmo}, Session),
			    {redirect, Session2, "#PC_select_montant"};
			_ ->
			    {redirect, Session, "#PC_echec_choix_montant"}
		    end
	    end;
	{DPRMobicarte, PMobicarte,_,_,true} ->
	    case DPRMobicarte of
		DPRMobicarte when (DPRMobicarte =/="" andalso DPRMobicarte =/= undefined) ->
		    D2 = get_date(DPRMobicarte),
		    Session2 = write_field({dateProchRecharg, D2}, Session),
		    {redirect, Session2, "#PC_eligi_plafond"};
		_ ->
		    case PMobicarte of 
			PMobicarte when (PMobicarte =/="" andalso PMobicarte =/=undefined) -> 
			    Session2 = write_field({prestation, PMobicarte}, Session),
			    {redirect, Session2, "#PC_select_montant"};
			_ ->
			    {redirect, Session, "#PC_echec_choix_montant"}
		    end
	    end;
	_ ->
	    {redirect, Session, "#PC_echec_choix_montant"}
    end.


fun_sort_cm(#code_montant{montant=M1},#code_montant{montant=M2}) ->
    list_to_integer(M1)<list_to_integer(M2).
    
get_recharg([#recharg{mobicarte=Mob}=R|_], Mob) -> R;
get_recharg([H|T], Mob) -> get_recharg(T, Mob);
get_recharg([], _) -> not_found.


print_liens_montant(abs) ->
    HREF = "#PC_confirm_montant",
    [ #hlink{href=HREF, contents=[{pcdata,"X1 E bonus : Y1 E"}, br]},
      #hlink{href=HREF, contents=[{pcdata,"X2 E bonus : Y2 E"}, br]}];
print_liens_montant(Session) ->
    #pChild{prestation=Prest,
	    mobicarte=Mobi} = read_pc(Session),
    CATALOGUE = get_env(catalogue_parentChild),
    FunHlink = 
	fun(#code_montant{code=C, montant=M}) ->
		PCDATA = M++" E" ++ bonus(Mobi, M, CATALOGUE),
		% Define a new PCDATA to display "+"(%2B) into XML page
		New_PCDATA =case string:tokens(PCDATA, "+") of
		    [Left,Right] -> Left++"%2B"++Right;
		    _ -> PCDATA
		end,
		HREF = "erl://"?MODULE_STRING":svg_choix_redir?"++C++"&"++M
		    ++"&"++New_PCDATA,
		#nbblock{contents=[#hlink{href=HREF, 
					  contents=[{pcdata, PCDATA}, br]}]}
	end,  
    lists:map(FunHlink, Prest).

bonus(true, Montant, CATALOGUE) ->
    case lists:keysearch(Montant, #bonus.montant, CATALOGUE) of
	{value, #bonus{bonus_mobi=B}} when B/="" -> " "++B;
	_ -> ""
    end;	    
bonus(false, Montant, CATALOGUE) ->
    case lists:keysearch(Montant, #bonus.montant, CATALOGUE) of
	{value, #bonus{bonus_cmo=B}} when B/="" -> " "++B;
	_ -> ""
    end.    

print_validite(abs) ->
    [{pcdata, " valables ZZ jours"}];
print_validite(Session) ->
    #pChild{mobicarte=Mob, montant=Montant} = read_pc(Session),
    [{pcdata, validite(Mob, Montant)}].

validite(true, Montant) ->
    CATALOGUE = get_env(catalogue_parentChild),
    case lists:keysearch(Montant, #bonus.montant, CATALOGUE) of
	{value, #bonus{validite_mobi=V}} when V/="" -> " "++V;
	_ -> ""
    end;	    
validite(_,_) -> "".
    
svg_choix_redir(Session, Code, Montant, Recharge) ->
    Session2 = write_fields([{code, Code},
			     {montant, Montant},
			     {recharge, Recharge}], Session),
    {redirect, Session2, "#PC_confirm_montant"}.


set_rechargement(abs) ->
    [{redirect, abs, "#PC_Succes"},
     {redirect, abs, "#PC_echec_rechargement"}];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PC Jan 2009 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AS/Metier G8R2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_rechargement(#session{log=Logs}=Session) ->
    MsisdnRechargeur = msisdn_nat(Session),
    #pChild{msisdnRecharge=MsisdnRecharge,
	    montant=Montant,
	    code=Code,
	    idDossierOrchidee=IdOrch,
	    idDossierSachem=IdSach} = read_pc(Session),
    slog:event(trace, {?MODULE, set_rechargement}, ?LINE, 
	       [msisdnRecharge,MsisdnRecharge,
		montant,Montant,
		code,Code,
		idDossierOrchidee,IdOrch,
		idDossierSachem,IdSach]),
    Session_2 = Session#session{log= [{?DM,"pc|montant|"++Montant} | Logs]},
    case asmetier_webserv:setRechargementParentChild
	(Code, IdOrch, IdSach,MsisdnRecharge, MsisdnRechargeur) of
	#doRechargementParentChildResponse{} ->
	    prisme_dump:prisme_count_v1(Session_2,parentChild,Montant),
	    {redirect, Session_2, "#PC_Succes"};
	Resp when Resp==#'ECareExceptionTechnique'{};
		  Resp==#'ECareExceptionFonctionnelle'{};
		  Resp==#'ExceptionDonneesInvalides'{} ->
	    slog:event(failure, ?MODULE, setRechPChildResp_case_clause, Resp),
	    {redirect, Session, "#PC_echec_rechargement"};
	{error,timeout} ->
	    slog:event(failure,?MODULE, setRechChild_timeout),
	    {redirect,Session,"#PC_nonrepASM"};
	_ ->
	    {redirect, Session, "#PC_nonrepASM"}
    end.

get_env(POF_PARAM) ->
    pbutil:get_env(pservices_orangef, POF_PARAM).
