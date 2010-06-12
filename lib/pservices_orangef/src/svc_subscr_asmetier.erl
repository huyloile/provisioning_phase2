-module(svc_subscr_asmetier).

%% include
-export([proposer_lien/4,proposer_lien/5,print_if_inactif/4,
	 print_opt_incomp/1, print_opt/1, print_success_msg/1,msisdn_nat/1,get_segCo/2,
	 print_opt_incomp/2,print_opt_txt/2]).

%% redirect
-export([get_identification/2,get_identification/3, get_listServiceOptionnel/2, get_listServiceOptionnel/1,
         is_rechargeable_cb/1,do_recharge_cb/8,
         get_dateDesactivation/1,
         is_commercially_launched/3,
         check_client_forfait_date/1,
	 get_impactSouscrServiceOpt/3, set_ServiceOptionnel/3,set_ServiceOptionnel/4, code_opt/2,
	 get_option_incomp/3,get_impactSouscrServiceOpt/7,
	 control_solde/4,is_option_activated/3,
	 redir_by_roaming_option_activated/3,
	 redir_by_segCo/2]).

-export([souscrire/3,cast/1]).

%% unit tests
-export([format_date/1]).

-import(svc_util_of,[dec_pcd_urls/1,get_env/1]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/subscr_asmetier.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/postpaid.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").



-define(all_sms_gpro,[opt_sms_130_sms_mms_gpro,opt_80_sms_mms_gpro,opt_130_sms_sms_mms_gpro,opt_orange_messenger_gpro]).
-define(all_ow,[ow_musique,ow_tv,ow_surf,ow_spo, ow_tv_mus_surf]).
-define(all_ow_gp,[ow_musique_gp, ow_musique_hits_gp, ow_tv_gp, ow_surf_gp, ow_spo_gp, ow_tv_mus_surf_gp]).
-define(all_ow_pro,[ow_musique_pro, ow_musique_hits_pro, ow_tv_pro, ow_surf_pro, ow_spo_pro, ow_tv_mus_surf_pro]).
-define(all_media, [media_decouvrt, media_internet, media_internet_plus]).
-define(all_sms,[sms_30,sms_80,sms_130,sms_210,sms_300]).
-define(all_roaming_gp, [opt_pass_voyage_6E_gpro,
                          opt_pass_voyage_9E_gpro,
						  opt_maroc_v037_gpro,
                          opt_algerie_v037_gpro,
                          opt_suisse_v037_gpro,
                          opt_luxembourg_v037_gpro,
                          opt_italie_v037_gpro,
                          opt_portugal_v037_gpro,
                          opt_espagne_v037_gpro,
                          opt_belgique_v037_gpro,
                          opt_royaumeuni_v037_gpro,
                          opt_allemagne_v037_gpro,
                          opt_dom_v037_gpro,
						  opt_maroc_v038_gpro,
                          opt_algerie_v038_gpro,
                          opt_suisse_v038_gpro,
                          opt_luxembourg_v038_gpro,
                          opt_italie_v038_gpro,
                          opt_portugal_v038_gpro,
                          opt_espagne_v038_gpro,
                          opt_belgique_v038_gpro,
                          opt_royaumeuni_v038_gpro,
                          opt_allemagne_v038_gpro,
                          opt_dom_v038_gpro,
                          opt_destination_europe_v037_gpro,
                          opt_destination_europe_v038_gpro,
                          opt_pass_internet_int_35E_gpro,
                          opt_pass_internet_int_20E_gpro,
                          opt_pass_internet_int_5E_gpro,
                          opt_pass_internet_int_iphone_gpro]).
-define(all_roaming_pro, [opt_pass_voyage_6E_gpro,
                          opt_pass_voyage_9E_gpro,
						  opt_maroc_v037_gpro,
                          opt_algerie_v037_gpro,
                          opt_suisse_v037_gpro,
                          opt_luxembourg_v037_gpro,
                          opt_italie_v037_gpro,
                          opt_portugal_v037_gpro,
                          opt_espagne_v037_gpro,
                          opt_belgique_v037_gpro,
                          opt_royaumeuni_v037_gpro,
                          opt_allemagne_v037_gpro,
                          opt_dom_v037_gpro,
						  opt_maroc_v038_gpro,
                          opt_algerie_v038_gpro,
                          opt_suisse_v038_gpro,
                          opt_luxembourg_v038_gpro,
                          opt_italie_v038_gpro,
                          opt_portugal_v038_gpro,
                          opt_espagne_v038_gpro,
                          opt_belgique_v038_gpro,
                          opt_royaumeuni_v038_gpro,
                          opt_allemagne_v038_gpro,
                          opt_dom_v038_gpro,
                          opt_destination_europe_v037_gpro,
                          opt_destination_europe_v038_gpro,
                          opt_pass_internet_int_35E_gpro,
                          opt_pass_internet_int_20E_gpro,
                          opt_pass_internet_int_5E_gpro,
                          opt_pass_internet_int_iphone_gpro]).
-define(all_roaming_mobi, [opt_pass_voyage_6E,opt_pass_voyage_9E]).
-define(all_roaming_umobile, [opt_pass_voyage_6E,opt_pass_voyage_9E]).
-define(all_roaming_cmo, [opt_pass_voyage_6E,opt_pass_voyage_9E]).
-define(List_SO_instant,["MM072","MM074","MM076"]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% AS Metier requests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Interface to get identification from asmetier. The only place query to 
%% asmetier_webserv:getIdentification and no other place in pservices can 
%% query  asmetier_webserv:getIdentification  directly. In order  to  get 
%% identification, other place MUST call this API function.  
%% This API assures that the Asmetier getIdentification requests is query
%% only one time in each session. 

%% +type get_identification(session(),Mode::string()) ->
get_identification(Session, Mode) ->
    OptActiv = cast(Session),
    IdDosOrId= OptActiv#activ_opt.idDosOrchid,
    IdUtiEdlw= OptActiv#activ_opt.idUtilisateurEdlws,
    CodeOffre= OptActiv#activ_opt.codeOffreType,
    CodeSegCo= OptActiv#activ_opt.codeSegCo,
    Msisdn = msisdn_nat(Session),
    case Msisdn of 
        no_msisdn ->
            slog:event(trace,?MODULE,error_no_msisdn),
            {nok, error, no_msisdn};
        _ -> 
            IdentList = [{"oee", IdDosOrId}, {"edl", IdUtiEdlw}],
            {_, {_, IdentifyID}} = lists:keysearch(Mode, 1, IdentList),
            %% check whether GetIdentification request is called or not
            case IdentifyID of 
                undefined->  
		    case asmetier_webserv:getIdentification(Msisdn, Mode) of
			{ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, CodeSegmentCommercial} ->
			    slog:event(trace,?MODULE,identify,{IdDosOrch,IdUtilisateurEdlws}),
			    NewOptions = OptActiv#activ_opt{idDosOrchid=IdDosOrch,
                                                            idUtilisateurEdlws=IdUtilisateurEdlws,
                                                            codeOffreType=CodeOffreType,
                                                            codeSegCo=CodeSegmentCommercial},
			    NewSession=update_session(Session, NewOptions),
			    {ok,IdDosOrch,IdUtilisateurEdlws,CodeOffreType,CodeSegmentCommercial,NewSession};
			#'ExceptionDossierNonTrouve'{}=Exception ->
                            slog:event(trace,?MODULE,error,{getIdentification,Exception}),
                            {nok,error,no_msisdn};
			Else->
			    slog:event(trace,?MODULE,error,{getIdentification,Else}),
			    Else
		    end;
                _ -> 
                    slog:event(trace,?MODULE,identify_id_exist,{IdDosOrId,IdUtiEdlw}),
                    {ok,IdDosOrId,IdUtiEdlw,CodeOffre,CodeSegCo,Session}
            end
    end.

%% +type get_identification(session(),Mode::string(),URLs::string()) ->
%%                          erlpage_result().
get_identification(abs, Mode, URLs) ->
    URLS=string:tokens(URLs,","),
    lists:map(fun(URL)->
		      {redirect,abs,URL}
	      end,URLS);
get_identification(#session{prof=Prof}=Session, Mode, URLs) ->
    [URL_Ok,URL_Nok] = string:tokens(URLs, ","),
    case get_identification(Session, Mode) of
        {ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, CodeSegmentCommercial, NewSession} ->
            {redirect, NewSession, URL_Ok};
        #'ExceptionErreurInterne'{}=ExceptionErreurInterne ->
            slog:event(failure,?MODULE,
                       getIdentification_ExceptionErreurInterne,
                       ExceptionErreurInterne),
            {redirect, Session, URL_Nok};
        #'ExceptionDossierNonTrouve'{}=ExceptionDossierNonTrouve ->
            slog:event(failure,?MODULE,
                       getIdentification_ExceptionDossierNonTrouve,
                       ExceptionDossierNonTrouve),
            {redirect, Session, URL_Nok};
        #'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides->
            slog:event(failure,?MODULE,
                       getIdentification_ExceptionDonneesInvalides,
                       ExceptionDonneesInvalides),
            {redirect, Session, URL_Nok};
        #'ECareExceptionTechnique'{}=ECareExceptionTechnique ->
            slog:event(failure,?MODULE,
                       getIdentification_ECareExceptionTechnique,
                       ECareExceptionTechnique),
            {redirect, Session, URL_Nok};
        {error,timeout} ->
            slog:event(failure,?MODULE,
                       getIdentification_timeout),
            {redirect, Session, URL_Nok};
        Other ->   
            slog:event(failure,?MODULE,
                       getIdentification_unknownError, Other),
            {redirect, Session, URL_Nok}    
    end.

get_segCo(#session{prof=Prof}=Session, Mode) ->
    OptActiv = cast(Session),
    CodeSegCo= OptActiv#activ_opt.codeSegCo,
    case CodeSegCo of
        undefined ->
            case get_identification(Session, Mode) of
                {ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, CodeSegmentCommercial, NewSession} -> 
                    slog:event(trace,?MODULE,getSegCo_ok,ok),
                    {ok, CodeSegmentCommercial, NewSession};
                _->
                    slog:event(trace,?MODULE,getSegCo_nok,nok),
                    nok
            end;
        _ -> 
            {ok, CodeSegCo, Session}
    end.

get_dateDesactivation(Session) ->
    OptActiv = cast(Session),
    case asmetier_webserv:getListServiceOptionnel(OptActiv#activ_opt.idDosOrchid) of
	{ok, ListServOpt} when list(ListServOpt) ->
	    ListServOpt1=lists:map(fun(#serviceOptionnel{code=Code,dateDesactivation=Date}) -> 
					   {Code,format_date(Date)}
				  end, ListServOpt),
	    slog:event(trace,?MODULE,list_dateDesactivation,ListServOpt1),
	    {ok, ListServOpt1};
	_->
	    slog:event(trace,?MODULE,get_dateDesactivation,error),
	    {nok,[]}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type is_rechargeable_cb(session()) ->
is_rechargeable_cb(Session) ->
    Msisdn = msisdn_nat(Session),
    OptActiv = cast(Session),
    case asmetier_webserv:isRechargeableCB(Msisdn) of
        {ok, Resp} when is_record(Resp, isRechargeableCBResponse) -> 
            IdDosSach = Resp#isRechargeableCBResponse.idDossier,
            Plafond = Resp#isRechargeableCBResponse.plafond,
            MontantMax = Resp#isRechargeableCBResponse.montantMaxRechargeable,
            NewOptions = OptActiv#activ_opt{idDosSach=IdDosSach},
            NewSession=update_session(Session, NewOptions),
            {ok, Plafond, MontantMax, NewSession};
        Exception -> 
	    slog:event(trace,?MODULE, is_not_rechargeable_cb, Exception),
            {nok, Exception}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type do_recharge_cb(session(), 
%%                      Subscription::atom(), 
%%                      TypeTransfert::string(), 
%%                      NumCarte::string(), 
%%                      Court::string(), 
%%                      FinVal::string(), 
%%                      Cvx2::string(), 
%%                      Amount) ->
do_recharge_cb(Session, 
               Sub, TypeTransfert, NumCarte, Court, FinVal, Cvx2, Amount) ->
    Msisdn = msisdn_nat(Session),
    OptActiv = cast(Session),
    IdMessage = asmetier_webserv:generate_msgid(),
    {ok,InfoBank} = asmetier_webserv:build_secure_IBS(IdMessage, NumCarte, Court, FinVal, Cvx2),
    IdDosSach = OptActiv#activ_opt.idDosSach,
    AmountStr = 
        case Amount of
            AmountInt when integer(AmountInt) -> integer_to_list(AmountInt);
            AmountFloat when float(AmountFloat) -> float_to_list(AmountFloat);
            AmountStr_ when list(AmountStr_) -> AmountStr_;
            AmountElse -> exit({invalid_amount,AmountElse})
        end,
    do_recharge_cb_int(Session, Sub, 
                       TypeTransfert, AmountStr,
                       Msisdn, IdMessage, InfoBank, IdDosSach).

do_recharge_cb_int(Session, cmo,
                   TypeTransfert, Amount,
                   Msisdn, IdMessage, InfoBank, IdDosSach) ->
    OptActiv = cast(Session),
    IdDossier = OptActiv#activ_opt.idDosOrchid,
    case asmetier_webserv:doRechargementCBOrchid(IdDossier, Msisdn, TypeTransfert, InfoBank, IdMessage, IdDosSach, Amount) of 
        {ok, Resp} when is_record(Resp, doRechargementCBResponse) -> 
            {ok, Resp};
        #'ExceptionPaiement'{codeMessage = "40"}=Exception ->
            {nok_banque_40, Exception};
	#'ExceptionPaiement'{codeMessage = "14"}=Exception ->
	    {nok_banque_14, Exception};
        #'ExceptionDonneesInvalides'{}=Exception ->
            {nok_cb, Exception};
	#'ECareExceptionTechnique'{}=Exception ->
	    {nok_technique, Exception};
	#'ECareExceptionFonctionnelleCodeInhbTemp'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeInhb'{}=Exception->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeNotInit'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeLock'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeWrong'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelle'{}=Exception ->
	    {nok_fonctionnelle, Exception};
        Else -> 
            {nok, Else}
    end;

do_recharge_cb_int(Session, 
                   mobi, TypeTransfert, Amount,
                   Msisdn, IdMessage, InfoBank, IdDosSach) ->
    OptActiv = cast(Session),
    IdDossier = OptActiv#activ_opt.idUtilisateurEdlws,
    case asmetier_webserv:doRechargementCBEdel(IdDossier, Msisdn, TypeTransfert, InfoBank, IdMessage, IdDosSach, Amount) of 
        {ok, Resp} when is_record(Resp, doRechargementCBResponse) -> 
            {ok, Resp};
	#'ExceptionPaiement'{codeMessage="01"}=ExceptionPaiement_01 ->
            {nok_banque_01, ExceptionPaiement_01};
	#'ExceptionPaiement'{codeMessage="14"}=ExceptionPaiement_14 ->
            {nok_banque_14, ExceptionPaiement_14};
        #'ExceptionPaiement'{codeMessage="40"}=ExceptionPaiement_40 ->
            {nok_banque_40, ExceptionPaiement_40};
	#'ExceptionPaiement'{codeMessage="44"}=ExceptionPaiement_44 ->
            {nok_banque_44, ExceptionPaiement_44};
	#'ExceptionPaiement'{codeMessage="45"}=ExceptionPaiement_45 ->
            {nok_banque_45, ExceptionPaiement_45};
	#'ExceptionPaiement'{}=ExceptionPaiement ->
            {nok_banque, ExceptionPaiement};
        #'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides ->
            {nok_cb, ExceptionDonneesInvalides};
	#'ECareExceptionTechnique'{}=Exception ->
	    {nok_technique, Exception};
	#'ECareExceptionFonctionnelleCodeInhbTemp'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeInhb'{}=Exception->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeNotInit'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeLock'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelleCodeWrong'{}=Exception ->
	    {nok_fonctionnelle, Exception};
	#'ECareExceptionFonctionnelle'{}=Exception ->
	    {nok_fonctionnelle, Exception};
        Else -> 
            {nok, Else}
    end.


%% use to extract date from AS metier response, something like: 
%% "2009-01-13T00:00:00+01:00" -> {{2009,1,13},{0,0,0}} | undefined
format_date(undefined) -> undefined;
format_date(Date) when list(Date) ->
    case gregexp:groups(Date,
			"\\\([0-9][0-9][0-9][0-9]\\\-[0-9][0-9]\\\-[0-9][0-9]\\\)"
			"T"
			"\\\([0-9][0-9]\\\:[0-9][0-9]\\\:[0-9][0-9]\\\).*") of
	{match,[Day,Hour]} -> 
	    case catch {string:tokens(Day,"-"),string:tokens(Hour,":")} of
		{[YYYY,MM,DD],[HH,Min,SS]} -> 
		    {{list_to_integer(YYYY),
		      list_to_integer(MM),
		      list_to_integer(DD)},
		     {list_to_integer(HH),
		      list_to_integer(Min),
		      list_to_integer(SS)}};
		Else1 ->
		    slog:event(failure,?MODULE,asmetier_date_format,
			       {Date,Else1}),
		    undefined
	    end;
	Else2 ->
	    slog:event(failure,?MODULE,asmetier_date_format,
		       {Date,Else2}),
	    undefined
    end.
    

get_listServiceOptionnel(Session) ->
    OptActiv = cast(Session),
    case asmetier_webserv:getListServiceOptionnel(OptActiv#activ_opt.idDosOrchid) of
	{ok, ListServOpt} when list(ListServOpt) ->
	    ListServOpt1=lists:map(fun(#serviceOptionnel{code=Code,
							 libelle=Libelle}) -> 
					   {undefined,Code,Libelle}
				  end, ListServOpt),
	    slog:event(trace,?MODULE,listServiceOptionnel,ListServOpt1),
	    NewOptions = OptActiv#activ_opt{listServOpt = ListServOpt1},
	    NewSession=update_session(Session, NewOptions),
	    {ok, ListServOpt1,NewSession};
	_->
	    slog:event(trace,?MODULE,get_listServiceOptionnel,error),
	    {nok,[],Session}
    end.

%% +type get_listServiceOptionnel(session(),URLs::string()) ->
%%                                erlpage_result().
get_listServiceOptionnel(abs, URLs) ->
    URLS=string:tokens(URLs,","),
    lists:map(fun(URL)->
		      {redirect,abs,URL}
	      end,URLS);
get_listServiceOptionnel(Session, URLs) ->
    [URL_Ok,URL_Nok] = string:tokens(URLs, ","),
    OptActiv = cast(Session),
    case asmetier_webserv:getListServiceOptionnel(OptActiv#activ_opt.idDosOrchid) of
	{ok, ListServOpt} when list(ListServOpt) ->
	    ListServOpt1=lists:map(fun(#serviceOptionnel{code=Code,
							 libelle=Libelle}) -> 
					   %% used to be a record
					   {undefined,Code,Libelle}
				  end, ListServOpt),
	    slog:event(trace,?MODULE,listServiceOptionnel,ListServOpt1),
	    NewOptions = OptActiv#activ_opt{listServOpt = ListServOpt1},
	    {redirect, update_session(Session, NewOptions), URL_Ok};
	#'ExceptionDossierNonTrouve'{}=ExceptionDossierNonTrouve   ->
	    slog:event(failure,?MODULE, 
		       getListServiceOptionnel_ExceptionDossierNonTrouve,
		       ExceptionDossierNonTrouve),
	    {redirect, Session, URL_Nok};
	#'ExceptionErreurInterne'{}=ExceptionErreurInterne   ->
	    slog:event(failure,?MODULE, 
		       getListServiceOptionnel_ExceptionErreurInterne,
		       ExceptionErreurInterne),
	    {redirect, Session, URL_Nok};
        #'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides ->
	    slog:event(failure,?MODULE, 
		       getListServiceOptionnel_ExceptionDonneesInvalides,
		       ExceptionDonneesInvalides),
	    {redirect, Session, URL_Nok};
        #'ECareExceptionTechnique'{}=ECareExceptionTechnique ->
	    slog:event(failure,?MODULE, 
		       getListServiceOptionnel_ExceptionExceptionTechnique,
		       ECareExceptionTechnique),
	    {redirect,Session, URL_Nok};    
	{error,timeout} ->
	    slog:event(failure,?MODULE,
		       getListServiceOptionnel_timeout),
	    {redirect, Session, URL_Nok};
	Other  ->
	    slog:event(failure,?MODULE, 
		       getListServiceOptionnel_UnknownError,Other),
	    {redirect, Session, URL_Nok}
    end.

%% +type get_impactSouscrServiceOpt(session(),Option::string(),
%%                                  URLs::string()) ->
%%                                  erlpage_result().
get_impactSouscrServiceOpt(abs, Option, URLs) ->
    URLS=string:tokens(URLs,","),
    lists:map(fun(URL)->
		      {redirect,abs,URL}
	      end,URLS)++
	[{redirect,abs,"/orangef/home.xml#as_metier_failure"}];
get_impactSouscrServiceOpt(Session, Option, URLs) ->
    Opt=list_to_atom(Option), 
    Test = code_opt(Session, Opt), %%%only for test
    [URL_Ok,URL_Nok] = string:tokens(URLs, ","),
    OptActiv = cast(Session),
    CodeOffreType = case verify_subscr_offre_type(Session) of
			true -> 
			    case OptActiv#activ_opt.codeOffreType of
				undefined ->
				    "null";
				Value ->
				    Value
			    end;
			_ -> "null"
		    end,
    Code_opt = code_opt(Session, Opt),
    if (Code_opt == "") ->
	    slog:event(service_ko,?MODULE,unknown_code_in_list),
	    {redirect, Session, URL_Nok};
       true ->
    case asmetier_webserv:getImpactSouscriptionServiceOptionnel(
	   OptActiv#activ_opt.idDosOrchid, 
		   Code_opt, CodeOffreType) of
	{ok, ListOptResil} ->
	    ListOptResil1=lists:map(fun(#serviceOptionnel{code=Code,
							   libelle=Libelle})-> 
					     {undefined,Code,Libelle}
				     end, ListOptResil),
	    case check_code_known(Session, ListOptResil1) of
		true ->
		    NewOptions = OptActiv#activ_opt{listOptResil=
						    ListOptResil1},
		    {redirect, update_session(Session, NewOptions),
		     URL_Ok};
		_ ->
		    slog:event(service_ko,?MODULE,unknown_code_in_list,
			       ListOptResil1),
		    {redirect, Session, URL_Nok}
	    end;    
	#'ExceptionErreurInterne'{} = ExceptionErreurInterne ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionErreurInterne,
		       ExceptionErreurInterne),
 	    {redirect, Session, URL_Nok};
	#'ExceptionServiceOptionnelImpossible'{}=ExceptionServiceOptionnelImpossible ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionServiceOptionnelImpossible,
		       ExceptionServiceOptionnelImpossible),
 	    {redirect, Session, URL_Nok};
	#'ExceptionDossierNonTrouve'{}=ExceptionDossierNonTrouve ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionDossierNonTrouve,
		       ExceptionDossierNonTrouve),
 	    {redirect, Session, URL_Nok};
	#'ExceptionOffreTypeInexistante'{}=ExceptionOffreTypeInexistante ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionOffreTypeInexistante,
		       ExceptionOffreTypeInexistante),
 	    {redirect, Session, URL_Nok};
	#'ExceptionServiceOptionnelnexistant'{}=ExceptionServiceOptionnelnexistant  -> 
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionServiceOptionnelInexistant,
		       ExceptionServiceOptionnelnexistant),
 	    {redirect, Session, URL_Nok};
	#'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionDonneesInvalides,
		       ExceptionDonneesInvalides),
 	    {redirect, Session, URL_Nok};
	#'ECareExceptionTechnique'{} = ECareExceptionTechnique ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ECareExceptionTechnique,
		       ECareExceptionTechnique),
 	    {redirect, Session, URL_Nok};
	{error,timeout} ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_timeout),
	    {redirect, Session, URL_Nok};
	Other ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_UnknowError,
		       Other),
 	    {redirect, Session, URL_Nok}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_impactSouscrServiceOpt(session(),Option::atom(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string(),Error_msg::bool())->
%%                  erlpage_result(). 
%%%% Internal function used by plugin redirect_OptASM_state.

get_impactSouscrServiceOpt(abs,Sub,Option,UAct,UIncomp,ErrorMsg,UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UIncomp},
     {redirect,abs,ErrorMsg},
     {redirect,abs,UGene}];
get_impactSouscrServiceOpt(Session,Sub,Option,UAct,UIncomp,ErrorMsg,UGene) ->
    Opt=list_to_atom(Option),
    OptActiv = cast(Session),
    CodeOffreType = case verify_subscr_offre_type(Session) of
			true ->
			    case OptActiv#activ_opt.codeOffreType of
                                undefined ->
                                    "null";
                                Value ->
                                    Value
                            end;
			_ -> "null"
		    end,
     Code_opt = code_opt(Session, Opt),
     if (Code_opt == "") ->
 	     slog:event(trace,?MODULE,unknown_code_in_list),
             {redirect, Session, ErrorMsg};
        true ->
    case asmetier_webserv:getImpactSouscriptionServiceOptionnel(
	   OptActiv#activ_opt.idDosOrchid, 
		   Code_opt, CodeOffreType) of
	{ok, ListOptResil} ->
	    ListOptResil1=lists:map(fun(#serviceOptionnel{code=Code,
							  libelle=Libelle})-> 
					     {undefined,Code,Libelle}
				     end, ListOptResil),
	    case check_code_known(Session, ListOptResil1) of
		true ->
		    NewOptions = OptActiv#activ_opt{listOptResil=
						    ListOptResil1},
		    case ListOptResil1 of
			undefined -> 
			    {redirect, 
			     update_session(Session,NewOptions), UGene};
			" " -> 
			    {redirect, 
			     update_session(Session,NewOptions), UGene};
			[] ->  
			    {redirect,
			     update_session(Session,NewOptions), UGene};
			List_incomp ->
			    {redirect,
			     update_session(Session,NewOptions), UIncomp}
		    end;
		_ ->
		    slog:event(service_ko,?MODULE,unknown_code_in_list,
			       ListOptResil1),
		    {redirect, Session, ErrorMsg}
	    end;
	#'ExceptionServiceOptionnelImpossible'{codeMessage=CodeMessage}=ExceptionServiceOptionnelImpossible ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionServiceOptionnelImpossible,
		       ExceptionServiceOptionnelImpossible),
	    Session1=variable:update_value(Session,exceptionServiceOptionnelImpossible,CodeMessage),
 	    {redirect, Session1, ErrorMsg};
	#'ExceptionErreurInterne'{} = ExceptionErreurInterne ->
	    slog:event(warning,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionErreurInterne,
		       ExceptionErreurInterne),
 	    {redirect, Session, ErrorMsg};

	#'ExceptionDossierNonTrouve'{}=ExceptionDossierNonTrouve ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionDossierNonTrouve,
		       ExceptionDossierNonTrouve),
 	    {redirect, Session, ErrorMsg};
	#'ExceptionOffreTypeInexistante'{}=ExceptionOffreTypeInexistante ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionOffreTypeInexistante,
		       ExceptionOffreTypeInexistante),
 	    {redirect, Session, ErrorMsg};
	#'ExceptionServiceOptionnelnexistant'{}=ExceptionServiceOptionnelnexistant  -> 
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionServiceOptionnelInexistant,
		       ExceptionServiceOptionnelnexistant),
 	    {redirect, Session, ErrorMsg};
	#'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ExceptionDonneesInvalides,
		       ExceptionDonneesInvalides),
 	    {redirect, Session, ErrorMsg};
	#'ECareExceptionTechnique'{} = ECareExceptionTechnique ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_ECareExceptionTechnique,
		       ECareExceptionTechnique),
 	    {redirect, Session, ErrorMsg};
	{error,timeout} ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_timeout),
	    {redirect, Session, ErrorMsg};
	Other ->
	    slog:event(failure,?MODULE,
		       getImpactSouscriptionServiceOptionnel_UnknowError,
		       Other),
 	    {redirect, Session, ErrorMsg}
	 end
    end.



%% +type set_ServiceOptionnel(session(),CodeServOpt::string(), Opt::atom()) ->
%%                           erlpage_result().
set_ServiceOptionnel(Session, CodeServOpt, Opt) ->
    set_ServiceOptionnel(Session, CodeServOpt, "true", Opt).


%%+type set_ServiceOptionnel(session(),CodeServOpt::string(), Activation::string(), Opt::atom()) ->
%%                           erlpage_result().
set_ServiceOptionnel(Session, CodeServOpt, Activation, Opt)->
    OptActiv = cast(Session),
    Msisdn = msisdn_nat(Session),
    {IdDosOrch, Session1} = case get_identification(Session, "oee") of
                                {ok, IdDossierOrchidee, _, _, _, Session_} ->
                                    {IdDossierOrchidee, Session_};
                                _->{undefined,Session}
                            end,
    DateProchaineFacture=
	case lists:member(CodeServOpt,?List_SO_instant) of
	    true->
		svc_util_of:term_to_string(svc_spider:read_field(nextInvoice, Session1));
	    _->
		""
	end,
    case asmetier_webserv:setServiceOptionnel(
	   Msisdn,
	   IdDosOrch,%OptActiv#activ_opt.idDosOrchid,
	   CodeServOpt, 
	   Activation,%"true"
	   "true", 
	   DateProchaineFacture, 
	   "true") of
	ok ->
	    case Activation of
		"true" ->
                    prisme_dump:prisme_count(Session1, Opt, {subscribe, validation});
		_  -> []
	    end,
	    slog:event(trace,?MODULE,set_ServiceOptionnel,ok),
	    {ok,Session1};

	#'ECareExceptionTechnique'{}=ECareExceptionTechnique->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ECareexceptionTechnique,
		       ECareExceptionTechnique),
	    system_failure;
	#'ExceptionErreurInterne'{}=ExceptionErreurInterne->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionErreurInterne,
		       ExceptionErreurInterne),
	    error_msg;
	#'ExceptionServiceOptionnelnexistant'{}=ExceptionServiceOptionnelnexistant->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionServiceOptionnelnexistant,
		       ExceptionServiceOptionnelnexistant),
	    error_msg;
	#'ExceptionDossierNonTrouve'{}=ExceptionDossierNonTrouve->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionDossierNonTrouve,
		       ExceptionDossierNonTrouve),
	    error_msg;
	#'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionDonneesInvalides,
		       ExceptionDonneesInvalides),
	    error_msg;
	#'ExceptionDateFacturationProche'{}=ExceptionDateFacturationProche->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionDateFacturationProche,
		       ExceptionDateFacturationProche),
	    error_msg;
	#'ExceptionRegleNonVerifiee'{}=ExceptionRegleNonVerifiee ->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionRegleNonVerifiee,
		       ExceptionRegleNonVerifiee),
	    code_7;
	#'ExceptionRegleGestionABPRONonVerifiee'{}=ExceptionRegleGestionABPRONonVerifiee ->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionRegleGestionABPRONonVerifiee,
		       ExceptionRegleGestionABPRONonVerifiee),
	    code_8;
	#'ExceptionCoupleClientDossierInexistant'{}=ExceptionCoupleClientDossierInexistant ->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionCoupleClientDossierInexistant,
		       ExceptionCoupleClientDossierInexistant),
	    error_msg;
	{error,timeout} ->
	    slog:event(failure,?MODULE,
		       set_ServiceOptionnel_timeout),
	    error_msg;
	Other ->
	    slog:event(failure,?MODULE,set_ServiceOptionnel_UnknownError,Other),
	    system_failure
    end.

%% +type log_event(Err::term(),Request_failed::atom(),Id::string()) ->
%%                 erlpage_result().
log_event(Err, Request_failed, Id) ->
    case Err of
	{_, _, HttpCode, Error, _, _} ->
	    slog:event(failure,?MODULE,Request_failed,{Id,HttpCode,Error});
	_ ->
	    slog:event(failure,?MODULE,Request_failed,Err)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Subscription
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type souscrire(session(),Opt::string(),URLs::string())->
%%                 erlpage_result().
souscrire(abs,_,URLs)->
    URLS=string:tokens(URLs,","),
    lists:map(fun(URL)->
		      {redirect,abs,URL}
	      end,URLS)++
	[{redirect,abs,"/orangef/home.xml#as_metier_failure"}];
souscrire(#session{}=S,Option,URL) ->
    slog:event(trace,?MODULE,{souscription_0,Option}),
    do_souscrire(S,list_to_atom(Option),URL).

%% +type do_souscrire(session(),Opt::string(),URLs::string())->
%%                    erlpage_result().
do_souscrire(Session, Opt, URLs) 
  when Opt== sms_30_gp; Opt== sms_80_gp; Opt== sms_130_gp; Opt== sms_210_gp; Opt== sms_300_gp; 
       Opt== sms_30_pro; Opt== sms_80_pro; Opt== sms_130_pro; Opt== sms_210_pro; Opt== sms_300_pro;
       Opt== orange_messenger_gp; Opt== orange_messenger_pro ->
    State = svc_util_of:get_user_state(Session),
    [URL_success, URL_fail_promo, URL_fail_fonct] = string:tokens(URLs, ","),
    case set_ServiceOptionnel(Session, code_opt(Session, Opt), Opt) of
	{ok,NewSess} ->
	    slog:event(trace,?MODULE,{souscription_1,Opt}),
	    OptActiv = cast(Session),
	    NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
	    {redirect,update_session(NewSess,NewOptActiv),URL_success};
	code_7 ->
	    {redirect, Session, URL_fail_fonct};
	code_8 ->
	    {redirect, Session, URL_fail_promo};
	error_msg -> 
	    {redirect,Session,"#error_msg"};
	E -> 
	    {redirect,Session,"#error_msg"}
    end;
do_souscrire(Session, Opt, URLs) ->
    State = svc_util_of:get_user_state(Session),
    URL = is_opt_first(Session, Opt, State, URLs),
    case set_ServiceOptionnel(Session, code_opt(Session, Opt), Opt) of
	{ok,NewSess} ->
	    slog:event(trace,?MODULE,{souscription_1,Opt}),
	    OptActiv = cast(Session),
	    NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
	    {redirect,update_session(NewSess,NewOptActiv),URL};
	error_msg -> 
	    {redirect,Session,"#error_msg"};
	E -> 
	    {redirect,Session,"#error_msg"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Print functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type proposer_lien(session(),Opt::string(),string(),string())-> hlink().
%%%% proposer liens si options autorisées

proposer_lien(Session, OPT, PCD_URLs, BR)->
    proposer_lien(Session,OPT,PCD_URLs,BR,"").

%% +type proposer_lien(session(),Opt::string(),PCD_URLs::string(),
%%                     BR::string(),Key::string()) -> 
%%                     hlink().
proposer_lien(abs, _, PCD_URLs, BR, Key) ->
    [{PCD,URL}|_]=dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
proposer_lien(Session, "if_profile_sms_gp", PCD_URLs, BR, Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session, opt_forf_sms) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt{}->
		    %% only options above activated ones are proposed
		    %% ie if last not active, link proposed
		    case is_option_activated(Session, sms_300_gp,State) of
			false ->
			    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,
				    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(Session, "if_profile_sms_pro", PCD_URLs, BR, Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session, opt_forf_sms) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt{}->
		    %% only options above activated ones are proposed
		    %% ie if last not active, link proposed
		    case is_option_activated(Session, sms_300_pro,State) of
			false ->
			    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,
				    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(Session, "if_profile_ow_gp", PCD_URLs, BR, Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session, opt_ow) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt{}->
		    %% only options above activated ones are proposed
		    %% ie if last not active, link proposed
		    case is_option_activated(Session, ow_30_gp,State) of
			false ->
			    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,
				    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,"abroad")
  when Option == "opt_10mn_europe";
       Option == "opt_pass_voyage_6E_gpro";Option == "opt_pass_voyage_9E_gpro";
       Option == "opt_pass_voyage_6E";Option == "opt_pass_voyage_9E"->
    case svc_roaming:get_vlr(Session) of 
 	{ok, VLR_Number} ->
 	    case svc_util_of:is_europe_vlr(VLR_Number) of
 		true ->
 		    proposer_lien(Session, Option, PCD_URLs, BR,"");
 		_ ->
 		    []
 	    end;
 	_ ->
 	    []
    end;


proposer_lien(Session,Option,PCD_URLs,BR,VLR)
  when  Option=="opt_suisse_v037_gpro";
    Option=="opt_suisse_v038_gpro";
	Option=="opt_italie_v037_gpro";
    Option=="opt_italie_v038_gpro";
	Option=="opt_portugal_v037_gpro";
    Option=="opt_portugal_v038_gpro";
	Option=="opt_luxembourg_v037_gpro";
    Option=="opt_luxembourg_v038_gpro";
	Option=="opt_espagne_v037_gpro";
    Option=="opt_espagne_v038_gpro";
	Option=="opt_belgique_v037_gpro";
    Option=="opt_belgique_v038_gpro";
	Option=="opt_royaumeuni_v037_gpro";
    Option=="opt_royaumeuni_v038_gpro";
	Option=="opt_allemagne_v037_gpro";
    Option=="opt_allemagne_v038_gpro";
	Option=="opt_dom_v037_gpro";
    Option=="opt_dom_v038_gpro";
	Option=="opt_destination_v037_europe";
	Option=="opt_destination_v038_europe";
	Option=="opt_maroc_v037_gpro";
     Option=="opt_maroc_v038_gpro";
	Option=="opt_algerie_v037_gpro";
    Option=="opt_algerie_v038_gpro" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case {is_commercially_launched(Session,Opt,State), is_option_activated(Session, Opt, State)} of
	{true,false} ->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,
		    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	{true,true} ->
	    [];
	{false,_} ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,Key)
  when Option == "opt_10mn_europe";
       Option == "opt_pass_vacances";Option == "opt_pass_vacances_z2";
       Option == "opt_pass_blackberry";
       Option == "opt_pass_internet_int_5E_gpro";Option == "opt_pass_internet_int_20E_gpro";
       Option == "opt_pass_internet_int_35E_gpro";Option == "opt_pass_internet_int_iphone_gpro"->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) of
	true->
 	    case State#postpaid_user_state.opt_activ of
 		#activ_opt{}->
		    case is_option_activated(Session, Opt, State) of
			false ->
			    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,
				    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
			_ ->
			    []
		    end;
 		_ ->
 		    []
 	    end;
	false->
	    []
    end;

proposer_lien(Session, "if_profile_ow_pro", PCD_URLs, BR, Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session, opt_ow) of
 	true->
 	    case State#postpaid_user_state.opt_activ of
 		#activ_opt{}->
 		    %% only options above activated ones are proposed
		    %% ie if last not active, link proposed
 		    case is_option_activated(Session, ow_30_pro,State) of
 			false ->
 			    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
 			    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
 			_ ->
 			    []
 		    end;
 		_ ->
 		    []
 	    end;
 	false->
 	    []
    end;
proposer_lien(Session,"if_profile_sms",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session,opt_forf_sms) and
	not is_option_activated(Session, all_sms, State) of
	true->
	    case State#sdp_user_state.opt_activ of
		#activ_opt{}->
		    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL,key=Key,
			    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(Session,"if_profile_ow",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session,opt_ow_cmo) and
	not is_option_activated(Session, all_ow, State) of
	true->
	    case State#sdp_user_state.opt_activ of
		#activ_opt{}->
		    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL,key=Key,
			    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(Session,"if_profile_media",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session,opt_media_cmo) and
	not is_option_activated(Session, all_media, State) of
	true->
	    case State#sdp_user_state.opt_activ of
		#activ_opt{}->
		    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL,key=Key,
			    contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(Session,"opt_m6_smsmms",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    proposer_lien_m6(Session,State,"opt_m6_smsmms",PCD_URLs,BR,Key);

proposer_lien(#session{prof=#profile{imsi=IMSI}}=Session,"m5",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session,m5) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,"kdo_smsmms",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session,kdo_smsmms) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,"kdo",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    [{PCD_s_kdo,URL_s_kdo},{PCD_m_kdo,URL_m_kdo},{PCD_n_kdo,URL_n_kdo}]
	= svc_util_of:dec_pcd_urls(PCD_URLs),
    KDO = lists:map(fun(Element) ->
			    svc_util_of:is_commercially_launched(Session, Element)
		    end, [s_kdo, m_kdo, n_kdo]),
    
    case KDO of
	[true, _, _] ->	
	    [#hlink{href=URL_s_kdo,key=Key,contents=[{pcdata,PCD_s_kdo}]}];
	[_, true, _] ->	
	    [#hlink{href=URL_m_kdo,key=Key,contents=[{pcdata,PCD_m_kdo}]}];
	[_, _, true] ->	
	    [#hlink{href=URL_n_kdo,key=Key,contents=[{pcdata,PCD_n_kdo}]}];
	_ ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) and
	not is_option_activated(Session, Opt, State) of
	true ->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end.

%% +type proposer_lien_m6(session(),State::record,
%%                        Opt::string(),PCD_URLs::string(),
%%                        BR::string(),Key::string()) -> 
%%                        hlink().
proposer_lien_m6(abs,State,Option,PCD_URLs,BR,Key)->
    proposer_lien(abs,Option,PCD_URLs,BR,Key);

proposer_lien_m6(Session,#sdp_user_state{declinaison=D}=State,
		 Option,PCD_URLs,BR,Key) 
when D==?m6_cmo;D==?m6_cmo2->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) and
	not is_option_activated(Session, Opt, State) of
	true ->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end;
proposer_lien_m6(Session,#sdp_user_state{declinaison=D}=State,
		 Option,PCD_URLs,BR,Key)->    
    [].

%% +type print_if_inactif(session(),Opt::string(),URL::string(),
%%                        BR::string())-> 
%%                        hlink().
print_if_inactif(abs,Opt,URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,Opt}]}]++svc_util_of:add_br(BR);
print_if_inactif(Session, Option, URL, BR)
  when Option=="opt_30_sms_mms_gpro"; Option=="opt_80_sms_mms_gpro"; Option=="opt_130_sms_mms_gpro";
       Option=="opt_orange_messenger_gpro" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    PCD = print_link(Opt),
    Is_option_activated = is_option_activated(Session, Opt,State),
    Is_option_above_activated = 
	is_opt_above_activated(Session, Opt, State, ?all_sms_gpro),
    case {Is_option_activated,Is_option_above_activated} of
	{false,false} ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	{_,_} ->
	    []
    end;

print_if_inactif(Session, Option, URL, BR) ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    PCD = print_link(Opt),
    case is_option_activated(Session, Opt, State) of
	false ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	true ->
	    []
    end.

%% +type print_link(atom())-> string().
print_link(Sms) when Sms==sms_30_gp; Sms==sms_30_pro ->
    "L'option 30SMS";
print_link(Sms) when Sms==sms_30 ->
    "option 30SMS a 3E";
print_link(Sms) when Sms==sms_80_gp; Sms==sms_80_pro ->
    "L'option 80SMS";
print_link(Sms) when Sms==sms_80 ->
    "option 80SMS a 7,5E";
print_link(Sms) when Sms==sms_130_gp; Sms==sms_130_pro ->
    "L'option 130SMS";
print_link(Sms) when Sms==sms_130 ->
    "option 130SMS a 12E";
print_link(Sms) when Sms==sms_210_gp; Sms==sms_210_pro ->
    "L'option 210SMS";
print_link(Sms) when Sms==sms_210 ->
    "option 180 + 30SMS a 18E";
print_link(Sms) when Sms==sms_300_gp; Sms==sms_300_pro ->
    "L'option 300SMS";
print_link(Sms) when Sms==sms_300 ->
    "option 250 + 50SMS a 25E";
print_link(Sms) when Sms==orange_messenger_gp ->
    "Orange Messenger";

print_link(Ow) when Ow==ow_3 ->
    "OW 3E/5Mo";
print_link(Ow) when Ow==ow_6 ->
    "OW 6E/10Mo";
print_link(Ow) when Ow==ow_10 ->
    "OW 10E/25Mo + WE TV/Video";
print_link(Ow) when Ow==ow_20 ->
    "OW 20E/60Mo + WE TV/Video";
print_link(Ow) when Ow==ow_30 ->
    "OW 30E/150Mo + WE TV/Video";
print_link(Ow) when Ow==ow_tv1->
    "Option TV+Surf";
print_link(Ow) when Ow==ow_tv2->
    "Option Totale TV";
print_link(Ow) when Ow==ow_spo->
    "Option Sport";
print_link(Ow) when Ow==ow_musique->
    "Option Musique";
print_link(Ow) when Ow==ow_tv->
    "Option TV";
print_link(Ow) when Ow==ow_surf->
    "Option Surf";
print_link(Ow) when Ow==ow_tv_mus_surf->
    "Option TV - Musique - Surf";
print_link(Ow) when Ow==ow_tv1_gp ->
    "Option TV + Surf illimite a 6E/mois";
print_link(Ow) when Ow==ow_tv2_gp;Ow==ow_tv2_pro ->
    "Option Totale TV";
print_link(Ow) when Ow==ow_tv_gp; Ow==ow_tv_pro ->
    "Option TV";
print_link(Ow) when Ow==ow_musique_gp; Ow==ow_musique_pro ->
    "Option Musique";
print_link(Ow) when Ow==ow_musique_hits_gp; Ow==ow_musique_hits_pro ->
    "Option Musique hits";
print_link(Ow) when Ow==ow_surf_gp; Ow==ow_surf_pro ->
    "Option Surf";
print_link(Ow) when Ow==ow_spo_gp; Ow==ow_spo_pro ->
    "Option Sport";
print_link(Ow) when Ow==ow_tv_mus_surf_gp; Ow==ow_tv_mus_surf_pro ->
    "Option TV-musique-surf";
print_link(Pass) when Pass==opt_pass_vacances ->
    "Option Pass Vacances";
print_link(Media) when Media==media_decouvrt ->
    "Option decouverte multimedia 3E";
print_link(Media) when Media==media_internet ->
    "Option internet 6E";
print_link(Media) when Media==media_internet_plus ->
    "Option plus d'internet 20E";


print_link(Opt) ->
    "".

%% +type print_opt_incomp(session()) ->
%%                        [{pcdata,string()}].
print_opt_incomp(abs) ->
    "";
print_opt_incomp(Session) ->
    OptActiv = cast(Session),
    case OptActiv#activ_opt.listOptResil of
	undefined ->  [{pcdata, ""}];
	[] ->  [{pcdata, ""}];
	" " ->  [{pcdata, ""}];
	[OptResiliee] ->
	    TXT = "Attention, votre option " 
		++ print_libelle(Session,[OptResiliee])
		++ "sera resiliee.",
		    [{pcdata,TXT}];
	[ListOptResiliees|T] ->
	    TXT = "Attention, vos options " 
		++ print_libelle(Session,[ListOptResiliees|T])
		++ "seront resiliees.",
		    [{pcdata,TXT}]
    end.

%% +type print_opt_incomp(session(), Option()::string()) ->
%%                        [{pcdata,string()}].
print_opt_incomp(abs, Option) ->
    "";
print_opt_incomp(Session, Option) ->
    OptActiv = cast(Session),
    case OptActiv#activ_opt.listOptResil of
	undefined ->  [{pcdata, ""}];
	[] ->  [{pcdata, ""}];
	" " ->  [{pcdata, ""}];
	ListOptResiliees ->
	    TXT = "Cette option n'est pas compatible avec votre option " 
		++ print_libelle(Session,ListOptResiliees),
		    [{pcdata,TXT}]
    end.

%% +type print_libelle(session(),ListOptResilie::[string()]) ->
%%                     string().
print_libelle(Session, [{_, Code, Default_Lib}]) ->
    libelle_opt(Session, Code, Default_Lib)++" ";
print_libelle(Session, [{_, Code, Default_Lib}|List]) ->
    libelle_opt(Session, Code, Default_Lib)++ ", "++ print_libelle(Session, List);
print_libelle(Session, []) -> "".

%% +type print_opt(session())-> [{pcdata,string()}].
print_opt(abs)-> [{pcdata,"300 SMS"}];
print_opt(Session)->
    Opt=cast(Session),
    Sub = (Session#session.prof)#profile.subscription,
    [{pcdata,print(list_to_atom(Sub),Opt#activ_opt.en_cours)}].

%% +type print(atom(),atom())-> string().
print(postpaid,Sms) when Sms==sms_30; Sms==sms_30_gp; Sms==sms_30_pro ->
    "30 SMS/10 MMS";
print(postpaid,Sms) when Sms==sms_80; Sms==sms_80_gp; Sms==sms_80_pro ->
    "80 SMS/26 MMS";
print(postpaid,Sms) when Sms==sms_130; Sms==sms_130_gp; Sms==sms_130_pro ->
    "130 SMS/43 MMS";
print(postpaid,Sms) when Sms==sms_210; Sms==sms_210_gp; Sms==sms_210_pro ->
    "210 SMS/60 MMS";
print(postpaid,Sms) when Sms==sms_300; Sms==sms_300_gp; Sms==sms_300_pro ->
    "300 SMS/83 MMS";
print(cmo,Sms) when Sms==sms_30; Sms==sms_30_gp; Sms==sms_30_pro ->
    "30 SMS";
print(cmo,Sms) when Sms==sms_80; Sms==sms_80_gp; Sms==sms_80_pro ->
    "80 SMS";
print(cmo,Sms) when Sms==sms_130; Sms==sms_130_gp; Sms==sms_130_pro ->
    "130 SMS";
print(cmo,Sms) when Sms==sms_210; Sms==sms_210_gp; Sms==sms_210_pro ->
     "180 + 30 SMS";
print(cmo,Sms) when Sms==sms_300; Sms==sms_300_gp; Sms==sms_300_pro ->
     "250 + 50 SMS";
print(cmo,Media) when Media==media_decouvrt ->
    "decouverte multimedia";
print(cmo,Media) when Media==media_internet ->
    "internet 10 Mo";
print(cmo,Media) when Media==media_internet_plus ->
    "internet 60 Mo";
print(_,Ow) when Ow==ow_3 ->
    "OW 3E: 5 Mo de connexion GPRS (ou 10 H de connexion CSD)";
print(_,Ow) when Ow==ow_6 ->
    "OW 6E: 10 Mo de connexion GPRS (ou 10 H de connexion CSD)";
print(_,Ow) when Ow==ow_10 ->
    "OW 10E: 25 Mo de connexion GPRS + TV/Video illimitees le WE (TV sur mobile 3G/Edge)";
print(_,Ow) when Ow==ow_20 ->
    "OW 20E: 60 Mo de connexion GPRS + TV/Video illimitees le WE (TV sur mobile 3G/Edge)";
print(_,Ow) when Ow==ow_30 ->
    "OW 30E: 150 Mo de connexion GPRS + TV/Video illimitees le WE (TV sur mobile 3G/Edge)";
print(_,Ow) when Ow==ow_tv1;Ow==ow_tv1_gp->
    "TV+Surf";
print(_,Ow) when Ow==ow_tv2;Ow==ow_tv2_gp->
    "Totale TV";
print(_,Ow) when Ow==ow_spo;Ow==ow_spo_gp;Ow==ow_spo_pro->
    "Sport";
print(_,Ow) when Ow==ow_musique ->
    "Musique";
print(_,Ow) when Ow==ow_surf ->
    "Surf";
print(_,Ow) when Ow==ow_tv ->
    "TV";
print(_,Ow) when Ow==ow_tv_mus_surf ->
    "TV - Musique - Surf".

%% +type print_opt_txt(session(),atom())-> string().
print_opt_txt(_,Opt) when Opt == "ow_tv_gp"; Opt == "ow_tv_pro" ->
    [{pcdata,"TV"}];
print_opt_txt(_,Opt) when Opt == "ow_musique_gp"; Opt == "ow_musique_pro" ->
    [{pcdata,"Musique"}];
print_opt_txt(_,Opt) when Opt == "ow_musique_hits_gp"; Opt == "ow_musique_hits_pro" ->
    [{pcdata,"Musique hits"}];
print_opt_txt(_,Opt) when Opt == "ow_surf_gp"; Opt == "ow_surf_pro" ->
    [{pcdata,"Surf"}];
print_opt_txt(_,Opt) when Opt == "ow_spo_gp"; Opt == "ow_spo_pro" ->
    [{pcdata,"Sport"}];
print_opt_txt(_,_) ->
    "".

%% +type print_success_msg(session())-> [{pcdata,string()}].
print_success_msg(abs)-> [{pcdata,"Vous beneficiez de:"}];
print_success_msg(Session)->
    Opt=cast(Session),
    Sub = (Session#session.prof)#profile.subscription,
    [{pcdata,print_success_msg(list_to_atom(Sub),Opt#activ_opt.en_cours)}].

%% +type print_success_msg(atom(),atom())->string().
print_success_msg(_,Ow)when Ow==ow_tv1_gp;Ow==ow_tv1_pro ->
    "Vous beneficiez de l'acces illimite a pres de 20 chaines TV et au portail Orange World";
print_success_msg(_,Ow)when Ow==ow_tv2_gp;Ow==ow_tv2_pro ->
    "Vous beneficiez de l'acces illimite a plus de 50 chaines TV";
print_success_msg(_,Ow)when Ow==ow_spo_gp;Ow==ow_spo_pro ->
    "Vous pouvez suivre tous les evenements sportifs en direct et en illimite";
print_success_msg(_,_) ->
    "".
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Functions to control solde
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% +type control_solde(session(),Opt::string(),SoldeOK::string(),
%%                     SoldeNOK::string())->
%%                     erlpage_result().
control_solde(abs, Opt, SoldeOK, SoldeNOK) ->
    [{redirect, abs, SoldeOK},
     {redirect, abs, SoldeNOK}];
control_solde(Session, Option, SoldeOK, SoldeNOK) ->
    State = svc_util_of:get_user_state(Session),
    Opt = list_to_atom(Option),
    SubscrPrice = svc_util_of:subscription_price(Session, Opt),
    case svc_options:enough_credit(State,
				   currency:sum(euro,SubscrPrice/1000)) of
	false ->
	    {redirect, Session, SoldeNOK};
	true  ->
	    {redirect, Session, SoldeOK}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Functions to read/update svc_date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type cast(session())-> activ_opt().
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    case element(1,State) of
	postpaid_user_state ->
	    case State#postpaid_user_state.opt_activ of
		undefined -> #activ_opt{};
		OptActiv -> OptActiv
	    end;
	sdp_user_state ->
	    case State#sdp_user_state.opt_activ of
		undefined -> #activ_opt{};
		OptActiv -> OptActiv
	    end;
	_ -> undefined
    end.

%% +type update_session(session(),activ_opt())-> session().
update_session(#session{prof=#profile{subscription=Sub}}=Session,
	       Options)
  when Sub=="postpaid" ->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,
				  State#postpaid_user_state{opt_activ=Options});
update_session(#session{prof=#profile{subscription=Sub}}=Session,
	       Options)
  when Sub=="cmo";
       Sub=="mobi"->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,
				  State#sdp_user_state{opt_activ=Options});
update_session(Session,Options) ->
    Session.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% COMMON FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_activated(session(),opt_act(),
%%                           postpaid_user_state()|sdp_user_state())->
%%                           bool().
is_option_activated(Session, all_media, State)->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,true,?all_media);
is_option_activated(Session, all_ow, State)->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,true,?all_ow);
is_option_activated(Session, all_sms, State) ->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,true,?all_sms);
is_option_activated(Session, one_of_sms, State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,false,?all_sms);
is_option_activated(Session, one_of_ow, State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,false,?all_ow);
is_option_activated(Session, one_of_sms_gp, State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,false,?all_sms_gpro);

is_option_activated(Session, one_of_sms_pro, State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Session, Opt,State) end,
    lists:foldl(Fun,false,?all_sms_gpro);
is_option_activated(Session, Opt, State) ->
    case get_option_value(Session, Opt, State) of
	{ok,_}->
	    true;
	error ->
	    true;
	Else ->
	    false
    end.

%% +type is_opt_first(session(),opt_act(),
%%                    postpaid_user_state()|sdp_user_state(),
%%                    URLs::string())->
%%                    bool().
is_opt_first(Session, Opt, State, URLs)
  when Opt==sms_30_gp; Opt==sms_80_gp; Opt==sms_130_gp;
       Opt==sms_210_gp; Opt==sms_300_gp ->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    case is_option_activated(Session, one_of_sms_gp, State) of
	true -> URL_actif;
	_ -> URL_first
    end;
is_opt_first(Session, Opt, State, URLs)
  when Opt==sms_30_pro; Opt==sms_80_pro; Opt==sms_130_pro;
       Opt==sms_210_pro; Opt==sms_300_pro->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    case is_option_activated(Session, one_of_sms_pro, State) of
	true -> URL_actif;
	_ -> URL_first
    end;
is_opt_first(Session, Opt, State, URLs)
  when Opt==sms_30; Opt==sms_80; Opt==sms_130 ->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    case is_option_activated(Session, one_of_sms, State) of
	true -> URL_actif;
	_ -> URL_first
    end;

is_opt_first(Session, Opt, State, URLs)
  when Opt==ow_3; Opt==ow_6; Opt==ow_10; Opt==ow_20; Opt==ow_30 ->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    case is_option_activated(Session, one_of_ow, State) of
	true -> URL_actif;
	_ -> URL_first
    end;
is_opt_first(Session, Opt, State, URLs)
  when Opt==media_decouvrt; Opt==media_internet; Opt==media_internet_plus ->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    case is_option_activated(Session, all_media, State) of
	true -> URL_actif;
	_ -> URL_first
    end;
is_opt_first(Session, Opt, State, URLs)
  when Opt==opt_pass_vacances ->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    case is_option_activated(Session, Opt, State) of
	true -> 
	    URL_actif;
	_ ->
	    URL_first
    end;
is_opt_first(Session, Opt, State, URLs) ->
    [URL_actif,URL_first] = string:tokens(URLs, ","),
    URL_first.

%% +type is_opt_above_activated(session(),atom(),postpaid_user_state(),
%%                              string())-> 
%%                              bool().
is_opt_above_activated(Session, Option, State, List) ->
    Range_opt = range_in_list(Option,List,1),
    List_above_opt = lists:sublist(List,Range_opt,length(List)-Range_opt+1),
    Fun = fun(Opt,Res)-> Res or is_option_activated(Session, Opt, State) end,
    lists:foldl(Fun,false,List_above_opt).

%% +type range_in_list(atom(),atom(),integer())-> integer().
range_in_list(Opt, [], _) -> 0;
range_in_list(Opt, [F|T], N) ->
    case F==Opt of
	true -> N;
	false -> range_in_list(Opt,T,N+1)
    end.

%% +type get_option_value(session(),opt_act(),
%%                        postpaid_user_state()|sdp_user_state()) ->
%%                        false | {ok, atom()}.
get_option_value(#session{prof=#profile{subscription=Sub}}=Session, Opt, State)
  when Sub=="postpaid", list((State#postpaid_user_state.opt_activ)#activ_opt.listServOpt) ->
    case lists:keysearch(code_opt(Session, Opt),
			 2,
			 (State#postpaid_user_state.opt_activ)#activ_opt.listServOpt) of
	{value,ServOpt}->
	    {ok,ServOpt};
	false ->
	    false
    end;
get_option_value(#session{prof=#profile{subscription=Sub}}=Session, Opt, State)
  when Sub=="cmo", list((State#sdp_user_state.opt_activ)#activ_opt.listServOpt) ->
    case lists:keysearch(code_opt(Session, Opt),
			 2,
			 (State#sdp_user_state.opt_activ)#activ_opt.listServOpt) of
	{value,ServOpt}->
	    {ok,ServOpt};
	false ->
	    false
    end;
get_option_value(Session, Opt, State) ->
    error.

%% +type get_option_incomp(session(),opt_act(),URLs::string()) ->
%%                         erlpage_result().
get_option_incomp(abs, Opt, URLs) ->
    [URL_ok, URL_incomp, URL_error]=string:tokens(URLs,","),
    [{redirect,abs,"#temporary"},
     {redirect,abs,URL_error},
     {redirect,abs,URL_ok},
     {redirect,abs,URL_incomp}];
get_option_incomp(#session{prof=#profile{subscription=Sub}}=Session, Opt, URLs)
  when Sub == "postpaid" -> 
    [URL_ok, URL_incomp, URL_error]=string:tokens(URLs,","),
    OptActiv = cast(Session),
    case OptActiv#activ_opt.listOptResil of
	undefined -> {redirect, Session, URL_error};
	" " -> {redirect, Session, URL_error};
	[] ->  
	    {redirect, Session, URL_ok};
	List_incomp ->
	    {redirect, Session, URL_incomp}
    end;
get_option_incomp(Session, Opt, URLs) ->
    {redirect,abs,"#temporary"}.
		 

%% +type code_opt(session(),opt_act())-> string().
code_opt(#session{prof=#profile{subscription=Sub}}=Session, Opt)->
    svc_of_plugins:code_opt(Session,Opt).

%% +type libelle_opt(session(),Code::string())-> string().
libelle_opt(#session{prof=#profile{subscription=Sub}}, Code, Default_Lib)
  when Sub=="postpaid"->
    case lists:keysearch(Code,1,
			 pbutil:get_env(pservices_orangef,asmetier_so_incomp_postpaid)) of
	{value, {_, Lib}}->
	    Lib;
	false->
	    slog:event(trace,?MODULE,unknown_code_in_list_postpaid,Code),
	    Default_Lib
    end;
libelle_opt(#session{prof=#profile{subscription=Sub}}, Code, Default_Lib)
  when Sub=="cmo"->
    case lists:keysearch(Code,1,
			 pbutil:get_env(pservices_orangef,asmetier_so_incomp_cmo)) of
	{value, {_, Lib}}->
	    Lib;
	false->
	    slog:event(trace,?MODULE,unknown_code_in_list_cmo,Code),
	    Default_Lib
    end.

%% +type libelle_found(session(),Code::string()) ->
%%                     bool().
libelle_found(Session, {_, Code, Libelle}) ->
    Ret = libelle_opt(Session, Code, Libelle),
    case Ret of
	"" -> false;
	_ -> true
    end.

%% +type check_code_known(session(),ListOptResilie::[string()]) ->
%%                        bool().
check_code_known(Session, " ") -> true;
check_code_known(Session, ListOpt) ->
    Fun = fun(Opt, Res) -> 
		  Res and libelle_found(Session, Opt) 
	  end,
    Ret = lists:foldl(Fun, true, ListOpt),
    Ret
.

%% +type verify_subscr_offre_type(session())-> string().
verify_subscr_offre_type(#session{prof=#profile{subscription=Sub}})
  when Sub=="postpaid"->
    Verify = pbutil:get_env(pservices_orangef,asmetier_verif_subscr_postpaid),
    Verify;
verify_subscr_offre_type(#session{prof=#profile{subscription=Sub}})
  when Sub=="cmo"->
    Verify = pbutil:get_env(pservices_orangef,asmetier_verif_subscr_cmo),
    Verify.

%% +type msisdn_nat(session())-> string().
msisdn_nat(#session{prof=#profile{msisdn=[$+, _, _| Msisdn]}}) -> [$0|Msisdn];
msisdn_nat(#session{prof=#profile{msisdn=Msisdn}}) when list(Msisdn)-> Msisdn;
msisdn_nat(_) -> no_msisdn.

%%% Redirect by option actived (opt_pass_vacances, opt_esf, opt_suisse, ....)
%% +type redir_roaming_network(session(),Links::string()) -> erlpage_result().
redir_by_roaming_option_activated(abs, Type, Links) ->
    svc_util:redirect_multi(abs, abs, Links);
    
redir_by_roaming_option_activated(Session,"gp",Links) ->
    redir_by_roaming_option_activated(Session,?all_roaming_gp,Links);
redir_by_roaming_option_activated(Session,"pro",Links) ->
    redir_by_roaming_option_activated(Session,?all_roaming_pro,Links);
redir_by_roaming_option_activated(Session,"mobi",Links) ->
    Roaming_Option = lists:map(fun(Option) ->
                                      {Option, svc_options:is_option_activated(Session, Option)}
                               end, ?all_roaming_mobi),
    case catch lists:keysearch(true, 2, Roaming_Option) of
        {value, {Activated_Option,true}} ->
            svc_util:redirect_multi(Session, atom_to_list(Activated_Option), Links);
        _ ->
            svc_util:redirect_multi(Session, "no_option", Links)
    end;
redir_by_roaming_option_activated(Session,"umobile",Links) ->
    Roaming_Option = lists:map(fun(Option) ->
                                      {Option, svc_options:is_option_activated(Session, Option)}
                               end, ?all_roaming_umobile),
    case catch lists:keysearch(true, 2, Roaming_Option) of
        {value, {Activated_Option,true}} ->
            svc_util:redirect_multi(Session, atom_to_list(Activated_Option), Links);
        _ ->
            svc_util:redirect_multi(Session, "no_option", Links)
    end;
redir_by_roaming_option_activated(Session,"cmo",Links) ->
    Roaming_Option = lists:map(fun(Option) ->
                                      {Option, svc_options:is_option_activated(Session, Option)}
                               end, ?all_roaming_cmo),
    case catch lists:keysearch(true, 2, Roaming_Option) of
        {value, {Activated_Option,true}} ->
            svc_util:redirect_multi(Session, atom_to_list(Activated_Option), Links);
        _ ->
            svc_util:redirect_multi(Session, "no_option", Links)
    end;

redir_by_roaming_option_activated(Session,All_Options,Links) ->    
    State = svc_util_of:get_user_state(Session),
    List_Links = string:tokens(Links,","),
    Options = get_options_to_link(List_Links),
    Roaming_Option = lists:map(fun(Option) ->
				       {Option, is_option_activated(Session, Option, State)}
                               end, All_Options),
    case catch lists:keysearch(true, 2, Roaming_Option) of
        {value, {Activated_Option,true}} -> 
	    case lists:member(atom_to_list(Activated_Option),Options) of 
		true -> 
		    svc_util:redirect_multi(Session, atom_to_list(Activated_Option), Links);
		_ ->
		    svc_util:redirect_multi(Session, "default", Links)
	    end;
        _ ->
            svc_util:redirect_multi(Session, "default", Links)
    end.

redir_by_segCo(#session{prof=#profile{imsi=Imsi}}=Session,URL) ->
    case check_client_forfait_date(Session) of 
	{true,Value} -> 
	    NSession=variable:update_value(Session,segCo,{Imsi,Value}),
	    {redirect, NSession, URL};
	_ -> 
	    NSession=variable:update_value(Session,segCo,{Imsi,undefined}),
	    {redirect, NSession, URL}
    end.


get_options_to_link([]) -> [];
get_options_to_link([Head|Tail]) ->
    [Opt,Link] = string:tokens(Head,"=#"),
    [Opt|get_options_to_link(Tail)].
    
    
is_europe_vlr(Session) ->
    case svc_roaming:get_vlr(Session) of 
 	{ok, VLR_Number} ->
 	    svc_util_of:is_europe_vlr(VLR_Number);
	_ ->
	    false
    end.
    
is_commercially_launched(Session,Opt,State) ->
    case svc_util_of:is_commercially_launched(Session,Opt) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt{}->
		    true;
		_ ->
		    false
	    end;
	false ->
	    false
    end.

check_client_forfait_date(Session) ->
    case get_segCo(Session,"oee") of 
	{ok, SEG, _} -> 
	    List_SegCo_des_offres = pbutil:get_env(pservices_orangef,segCo_offre_postpaid),
            {lists:member(SEG,List_SegCo_des_offres),SEG};
	Error ->
	    {false,Error}
    end.

