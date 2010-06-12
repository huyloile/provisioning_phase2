-module(svc_sms_pre).

-export([send_sms/2, check_sms/3,redirect_by_subcription/3]).
-export([reset/1]).

-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/smspre.hrl").
-include("../../pgsm/include/sms.hrl").



%% +type redirect_by_subcription(
%%   session(), string(), string())
%%  -> erlpage_result().
redirect_by_subcription(abs, Url_ok, Url_nok) ->
    [{redirect, abs, Url_ok}, 
     {redirect, abs, Url_nok}];

redirect_by_subcription(Session, Url_ok, Url_nok)->
    case svc_util_of:get_souscription(Session) of
	mobi -> {redirect, Session, Url_ok};
	_ ->{redirect, Session, Url_nok}
    end.

%% +type send_sms(
%%   session(), string(), string(), string(), string(), string(), string(),
%%   string())
%%  -> erlpage_result().

send_sms(abs, Url_Ok) ->
    [{redirect, abs, Url_Ok}, 
     {redirect, abs, ?URL_UNAVAIL}];
send_sms(Session, Url_Ok)->
    case catch send_sms_and_update(Session) of
	ok->
	    {redirect, Session, Url_Ok};
	Else->
	    slog:event(failure,?MODULE,send_sms_failed,Else),
	    {redirect, Session, ?URL_UNAVAIL}
    end.

%% +type get_num_sms(session()) -> integer()| {nok, Reason}.
get_num_sms(#session{prof=#profile{msisdn=Msisdn}}=Session)->
    case db:lookup_svc_profile(Session,?SVC_NAME) of
	{ok,#sms_pre{num=NumSms}}->
	    NumSms;
	not_found -> 
	    0;			     
	Error->
	    {nok,Error}
    end.
  
%% +type check_sms(session(),string(),string()) -> ok.
check_sms(abs, Url_Ok, Url_Nok) ->
    [{redirect, abs, Url_Ok},
     {redirect, abs, Url_Nok}, 
     {redirect, abs, ?URL_UNAVAIL}];
check_sms(Session,Url_Ok,Url_Nok) ->
    MaxSms=pbutil:get_env(pservices_orangef, max_sms_preetabli),
    case get_num_sms(Session) of
	{nok,E}->
	    slog:event(failure,?MODULE,retrieve_sms_pre_data,E),
	    {redirect, Session, ?URL_UNAVAIL};	   
	NumSms when NumSms==MaxSms-> 
	    {redirect, Session, Url_Nok};
	NumSms->
	    Session1=variable:update_value(Session,{?MODULE,"num_sms"},NumSms),
	    {redirect, Session1, Url_Ok}	
    end.
  

%% +type send_sms_and_update(session()) -> ok| Error.

send_sms_and_update(Session) ->
    case send_sms(Session) of
	ok ->
	    NumSms=variable:get_value(Session,{?MODULE,"num_sms"}),
	    update_data(Session, #sms_pre{num=NumSms+1});
	{ok, _} ->
	    NumSms=variable:get_value(Session,{?MODULE,"num_sms"}),
	    update_data(Session, #sms_pre{num=NumSms+1});
	E->
	    E
    end.

%% +type update_data(session(), sms_pre()) -> ok.

update_data(Session, SmsData) ->
    case db:update_svc_profile(Session, ?SVC_NAME, SmsData) of
	ok ->
	    ok;
	Err ->
	    slog:event(failure, ?MODULE, svc_profile_update_failed, Err),
	    throw(svc_profile_update_failed)
    end.

%% +type send_sms(session(), string()) -> ok.

send_sms(#session{prof=#profile{msisdn=Msisdn}}=Session) ->
    DestMsisdn=variable:get_value(Session,{?SVC_NAME,"msisdnB"}),
    "0" ++ Rest = DestMsisdn,
    SrcMsisdn=svc_util_of:int_to_nat(Msisdn),
    OcfDestMsisdn = "33" ++ Rest,
    IntlDestMsisdn = "+33" ++ Rest,
    Nom=variable:get_value(Session,{?SVC_NAME,"nom"}),
    Prenom=variable:get_value(Session,{?SVC_NAME,"prenom"}),
    FormatString = pbutil:get_env(pservices_orangef, sms_preetabli_texte),
    #sdp_user_state{declinaison=DCL}=svc_util_of:get_user_state(Session),
    Text = lists:flatten(io_lib:format(FormatString, [Nom,Prenom,type_carte(DCL),SrcMsisdn])),
    case catch ocf_rdp:isMsisdnOrange(OcfDestMsisdn) of
	true ->
	    Routing = pbutil:get_env(pservices_orangef, sms_preetabli_routing),
	    svc_util_of:send_smsmt(Session, Text, IntlDestMsisdn,[Routing]);
	false ->
	    Routing = pbutil:get_env(pservices_orangef, sms_preetabli_cvf_routing),
	    svc_util_of:send_sms_cvf(Session, Text, IntlDestMsisdn,Routing);
	X ->
	    slog:event(failure, ?MODULE, ocf_rdp_no_answer, X),
	    throw(ocf_failure)
    end.

type_carte(?m6_prepaid) ->
    "La carte prepayee m6 mobile by orange";
type_carte(DCL_NUM) when DCL_NUM==?RC_LENS_mobile;DCL_NUM==?ASSE_mobile;
			 DCL_NUM==?OL_mobile;DCL_NUM==?OM_mobile;
			 DCL_NUM==?PSG_mobile;DCL_NUM==?BORDEAUX_mobile;
			 DCL_NUM==?CLUB_FOOT; DCL_NUM==?DCLNUM_ADFUNDED->
    "carte prepayee club de foot";
type_carte(_)->
    "mobicarte".

reset(Key)->
    case svc_util_of:sql_get_uid(Key) of
	{ok,UID}->
	    Session=#session{prof=#profile{uid=UID}},
	    db:update_svc_profile(Session, ?SVC_NAME, #sms_pre{num=0});
	Err ->
	    {reset_failed,Err}
    end.
