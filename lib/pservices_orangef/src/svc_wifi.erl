-module(svc_wifi).

-export([filter_imsi/1,subscribe_promo/2]).
-export([get_listServiceOptionnel/1]).
-export([password/1,info/1]).

-include("../../pservices_orangef/include/wifi.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/subscr_asmetier.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").

%%%% can make service without imsi
%% +type filter_imsi(session()) -> erlpage_result().
filter_imsi(abs)-> filter_sub(abs,abs) ++ 
		       [{redirect, abs, "#not_identify"}];
filter_imsi(Session) ->
    Prof = Session#session.prof,
    case {Prof#profile.imsi,Prof#profile.msisdn} of
	{{na,_},_} -> {redirect, Session,"#not_identify"};
	{_,{na,_}} -> {redirect, Session,"#not_identify"};
	_ -> filter_sub(Session,Prof#profile.subscription)
    end.


%%%% filter subscription
%% +type filter_sub(session(), term()) -> erlpage_result().
filter_sub(abs,_) ->request_wifi(abs) ++[{redirect, abs, "#bad_subscription"}];
filter_sub(Session, Sub) when Sub == "dme" ;Sub == "postpaid"; Sub == "anon"; Sub=="opim" ->
    request_wifi(Session);
filter_sub(Session, _) ->
    {redirect, Session,"#bad_subscription"}.


%%%% request to OTP WIFI
%% +type request_wifi(session()) -> erlpage_result().
request_wifi(abs) ->
    [{redirect, abs, "#failed"},{redirect, abs, "#ok_long"},
     {redirect, abs, "#ok_mini"},{redirect, abs, "#ok_light"},
     {redirect, abs, "#ok_long_gp"},{redirect, abs, "#ok_mini_gp"},
     {redirect, abs, "#ok_light_gp"},{redirect, abs, "#not_wifi_user"},
     {redirect, abs, "#en_cours"},{redirect, abs, "#gele"},
     {redirect, abs, "#suspendu_flotte"},{redirect, abs, "#suspendu_client"},
     {redirect, abs, "#resilie"},{redirect, abs, "#not_authorized"},
     {redirect, abs, "#wifi_prov_failed"},
     {redirect, abs, "#wifi_prov_failed_light"},{redirect, abs, "#failed"}];
request_wifi(Session) ->
    Prof = Session#session.prof,
    Res = wifi_request:request(Prof),
    case Res of
	{ok,Wifi} ->
	    {Beg, End} = pbutil:get_env(pservices_orangef,promo_wifi),
	    case svc_util_of:is_launched(svc_util_of:local_time_to_unixtime(Beg),
					 svc_util_of:local_time_to_unixtime(End),
					 pbutil:unixtime()) of
		true->
		    case {Wifi#wifi.return, Prof#profile.subscription}  of
			{0, "postpaid"} ->
			    get_identification(Session, Wifi);
			_ ->
			    Url = redirect(Wifi#wifi.return,
					   (Prof#profile.terminal)#terminal.ussdsize,
					   Prof#profile.subscription),
			    {redirect,variable:update_value(Session,wifi,Wifi),Url}
		    end;
		_ ->
		    Url = redirect(Wifi#wifi.return,
				   (Prof#profile.terminal)#terminal.ussdsize,
				   Prof#profile.subscription),
		    {redirect,variable:update_value(Session,wifi,Wifi),Url}
	    end;
	_ ->
	    {redirect,Session,"#failed"}
    end.

%%%% print page function to OTP result and subscription
%% + type redirect(integer(),integer(),string()) -> string().
redirect(0,Size,"postpaid") ->
    if Size >= 181 -> "#ok_long_gp";
       Size >= 130 -> "#ok_light_gp";
       true ->        "#ok_mini_gp"
    end;
redirect(0,Size,_) ->            %%% dme or coriolis (anon)
    if Size >= 181 -> "#ok_long";
       Size >= 130 -> "#ok_light";
       true ->        "#ok_mini"
    end;
redirect(501,_,_) -> "#not_wifi_user";
redirect(502,_,_) -> "#en_cours";
redirect(503,_,_) -> "#gele";
redirect(504,_,_) -> "#suspendu_flotte";
redirect(505,_,_) -> "#suspendu_client";
redirect(506,_,_) -> "#resilie";
redirect(507,_,_) -> "#not_authorized";
redirect(Res,Size,_) when Res == 508; Res == 509; Res == 510 ->
    if Size >= 130 -> "#wifi_prov_failed";
       true -> "#wifi_prov_failed_light"
    end;
redirect(_,_,_) -> "#failed".

%% + type redirect_promo(integer(),string()) -> string().
redirect_promo(Size, Sub) when Sub == "postpaid" ->
    if Size >= 181 -> "#ok_long_gp_promo";
       Size >= 130 -> "#ok_light_gp_promo";
       true ->        "#ok_mini_gp_promo"
    end;
redirect_promo(Size, Sub) ->
    if Size >= 181 -> "#ok_long_promo";
       Size >= 130 -> "#ok_light_promo";
       true ->        "#ok_mini_promo"
    end.

%% +type password(session()) -> [{pcdata, string()}].
password(abs) -> [{pcdata,"Password"}];
password(Session) ->
    Wifi = variable:get_value(Session,wifi),
    Password = Wifi#wifi.password,
    [{pcdata,Password}].

%% +type info(session()) -> [{pcdata, string()}].
info(abs) -> [{pcdata,"Information commerciale"}];
info(Session) ->
    Wifi = variable:get_value(Session,wifi),
    Info = Wifi#wifi.text,
    [{pcdata,Info}].

%% +type subscribe_promo(Session::session(),List::servOpt) -> string().
subscribe_promo(#session{prof=Prof}=Session, List) ->
    case svc_of_plugins:search_subscr_code_opt(wifi_promo,pbutil:get_env(pservices_orangef,
									 asmetier_opt_postpaid)) of
        {ok,Code}->
	    case lists:keysearch(Code, 2, List) of
		{value,WifiPromo}-> % User already has the wifi promo
		    Url = redirect(0,
				   (Prof#profile.terminal)#terminal.ussdsize,
				   Prof#profile.subscription),
		    {redirect, Session, Url};
		false ->
		    set_ServiceOptionnel(Session, Code)
	    end;
        _->
	    {redirect,Session,"#failed_short"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% AS Metier requests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_identification(session(),Wifi::wifi()) ->
%%                          erlpage_result().
get_identification(Session, Wifi) ->
    Msisdn = msisdn_nat(Session),
    URL_Nok = "#ok_mini_gp",
    case Msisdn of
	no_msisdn -> {redirect, Session, "#failed_short"};
	_ ->
            case svc_subscr_webserv:get_identification(Session, "oee") of
		{ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, CodeSegmentCommercial, Session1} ->
		    NewWifi = Wifi#wifi{idDosOrchid = IdDosOrch},
		    NewSession = variable:update_value(Session1,wifi,NewWifi),
		    {redirect, NewSession, "#list_opt"};
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
                               getIdentification_UnknownError, Other),
                    {redirect, Session, URL_Nok}
	    end
    end.

%% +type get_listServiceOptionnel(session()) ->
%%                                erlpage_result().
get_listServiceOptionnel(abs) ->
    [{redirect,abs,"#failed_short"}, 
     {redirect,abs,"#ok_long_gp_promo"},
     {redirect,abs,"#ok_light_gp_promo"},
     {redirect,abs,"#ok_mini_gp_promo"}];
get_listServiceOptionnel(Session) ->
    Wifi = variable:get_value(Session, wifi),
    URL_Nok = "#ok_mini_gp",
    case asmetier_webserv:getListServiceOptionnel(Wifi#wifi.idDosOrchid) of
	{ok, ListServOpt} when list(ListServOpt) ->
	    subscribe_promo(Session, ListServOpt);
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
            {redirect, Session, URL_Nok};
        Other  ->
            slog:event(failure,?MODULE,
                       getListServiceOptionnel_UnknownError,Other),
            {redirect, Session, URL_Nok}

%% 	{asmetier_error, Code} ->
%% 	    Msisdn = msisdn_nat(Session),
%% 	    slog:event(failure,?MODULE,getListServiceOptionnel_statusCode,{Code,Msisdn}),
%% 	    {redirect, Session, "#ok_mini_gp"};
%% 	{asmetier_getListServiceOptionnel_failed, Error} ->
%% 	    slog:event(failure,?MODULE,getListServiceOptionnel),
%% 	    {redirect, Session, "#ok_mini_gp"}	    
    
%% 	#getListServiceOptionnelResponse{statusList=[Status|List],
%% 					 serviceOptionnel=ListServOpt} ->
%% 	    case Status#status.statusCode of
%% 		"00" when list(ListServOpt) ->
%% 		    subscribe_promo(Session, ListServOpt);
%% 		Code->
%% 		    Msisdn = msisdn_nat(Session),
%% 		    slog:event(failure,?MODULE,getListServiceOptionnel_statusCode,
%% 			       {Code,Msisdn}),
%% 		    {redirect, Session, "#ok_mini_gp"}
%% 	    end;
%% 	_ ->
%% 	    slog:event(failure,?MODULE,getListServiceOptionnel),
%% 	    {redirect, Session, "#ok_mini_gp"}
    end.

%% +type set_ServiceOptionnel(session(),CodeServOpt::string()) ->
%%                           erlpage_result().
set_ServiceOptionnel(Session, CodeServOpt) ->
    Prof = Session#session.prof,
    Wifi = variable:get_value(Session, wifi),
    Msisdn = msisdn_nat(Session),
    URL_Nok = "#ok_mini_gp",
    case asmetier_webserv:setServiceOptionnel(
	   Msisdn,
	   Wifi#wifi.idDosOrchid,
	   CodeServOpt, "true", "true", "", "true") of
	ok ->
	    Url = redirect(Wifi#wifi.return,(Prof#profile.terminal)#terminal.ussdsize,Prof#profile.subscription),
	    {redirect, Session, Url};
        #'ECareExceptionTechnique'{}=ECareExceptionTechnique->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ECareexceptionTechnique,
                       ECareExceptionTechnique),	
	    {redirect, Session, URL_Nok};
	#'ExceptionErreurInterne'{}=ExceptionErreurInterne->            
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionErreurInterne,
                       ExceptionErreurInterne),
	    {redirect, Session, URL_Nok};            
        #'ExceptionServiceOptionnelnexistant'{}=ExceptionServiceOptionnelnexistant->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionServiceOptionnelnexistant,
                       ExceptionServiceOptionnelnexistant),
	    {redirect, Session, URL_Nok};            
        #'ExceptionDossierNonTrouve'{}=ExceptionDossierNonTrouve->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionDossierNonTrouve,
                       ExceptionDossierNonTrouve),
	    {redirect, Session, URL_Nok};  
        #'ExceptionDonneesInvalides'{}=ExceptionDonneesInvalides->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionDonneesInvalides,
                       ExceptionDonneesInvalides),          
	    {redirect, Session, URL_Nok};
	#'ExceptionDateFacturationProche'{}=ExceptionDateFacturationProche->            
	    slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionDateFacturationProche,
                       ExceptionDateFacturationProche),
            {redirect, Session, URL_Nok};
        #'ExceptionRegleNonVerifiee'{}=ExceptionRegleNonVerifiee ->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionRegleNonVerifiee,
                       ExceptionRegleNonVerifiee),
            {redirect, Session, URL_Nok};
        #'ExceptionRegleGestionABPRONonVerifiee'{}=ExceptionRegleGestionABPRONonVerifiee ->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionRegleGestionABPRONonVerifiee,
                       ExceptionRegleGestionABPRONonVerifiee),
            {redirect, Session, URL_Nok};
        #'ExceptionCoupleClientDossierInexistant'{}=ExceptionCoupleClientDossierInexistant ->
            slog:event(failure,?MODULE,set_ServiceOptionnel_ExceptionCoupleClientDossierInexistant,
                       ExceptionCoupleClientDossierInexistant),
            {redirect, Session, URL_Nok};
	Other ->
            slog:event(failure,?MODULE,set_ServiceOptionnel_UnknownError,Other),
	    {redirect, Session, URL_Nok} 
%% 	{asmetier_error, Code} ->
%% 	    Msisdn = msisdn_nat(Session),
%% 	    slog:event(failure,?MODULE,setServiceOptionnel_statusCode,{Code,Msisdn}),
%% 	    {redirect, Session, "#ok_mini_gp"};
%% 	{asmetier_setServiceOptionnelResponse, Error} ->
%% 	    slog:event(failure,?MODULE,setServiceOptionnel),
%% 	    {redirect, Session, "#ok_mini_gp"}
    end.

%% 	#setServiceOptionnelResponse{statusList=[Status|List]} ->
%% 	    case Status#status.statusCode of
%% 		"00" ->
%% 		    Url = redirect_promo((Prof#profile.terminal)#terminal.ussdsize,
%% 					 Prof#profile.subscription),
%% 		    {redirect, Session, Url};
%% 		Code ->
%% 		    Msisdn = msisdn_nat(Session),
%% 		    slog:event(failure,?MODULE,setServiceOptionnel_statusCode,
%% 			       {Code,Msisdn}),
%% 		    {redirect, Session, "#ok_mini_gp"}
%% 	    end;
%% 	_ ->
%% 	    slog:event(failure,?MODULE,setServiceOptionnel),
%% 	    {redirect, Session, "#ok_mini_gp"}
%%     end.

%% +type msisdn_nat(session())-> string().
msisdn_nat(#session{prof=#profile{msisdn=[$+, _, _| Msisdn]}}) -> [$0|Msisdn];
msisdn_nat(#session{prof=#profile{msisdn=Msisdn}}) when list(Msisdn)-> Msisdn;
msisdn_nat(_) -> no_msisdn.
