-module(ocf_rdp).

%% subscription
-export([subscribeByMsisdn/1,subscribeByImsi/1,unsubscribeByMsisdn/1,
	 unsubscribeByImsi/1]).
%% consultation
-export([getUserInformationByMsisdn/1,getUserInformationByImsi/1,
	 getSubscriptionInformationByMsisdn/2,
	 getSubscriptionInformationByImsi/2]).
%% interogation
-export([isMsisdnOrange/1,getOptionalServicesByMsisdn/1]).

-export([segco_to_subscription/1,
	 translate_tech_seg/1,
	 tech_seg_int_to_code/1,
	 tech_seg_code_to_int/1]).
-export([slog_info/3]).

-include_lib("oma/include/slog.hrl").
-include("../include/ocf_rdp.hrl").

%% +deftype imsi() = string().
%% +deftype msisdn() = string().
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Subscription %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_time_out(Type)->

    Parameter = case Type of
		    sub -> ocf_sub_time_out;
		    get -> ocf_get_time_out;
		    is_orange -> ocf_is_orange_time_out
		end,
    
    pbutil:get_env(pfront_orangef,Parameter).
	     
%% +type subscribeByMsisdn(msisdn())->{ok, ocf_info_client()} | {error,term()}.
subscribeByMsisdn(MSISDN)->
    slog:event(trace, ?MODULE,subscribeByMsisdn, MSISDN),
    slog:event(count, ?MODULE,subscribe),
    Call= {call, 'OrangeAPI.SubscribeByMsisdn', [login(),
						 format_msisdn(MSISDN),
						 {struct,[]}]},
    case send(Call,get_time_out(sub)) of
	{ok, [{struct,[{'SubscriptionResult',true},
		       {'CustomerData',{struct,Resp}}]}]}->
	    {ok, decode_info_client(Resp)};
        {ok, [{struct,[{'CustomerData',{struct,Resp}},
                       {'SubscriptionResult',true}]}]}->
           {ok, decode_info_client(Resp)};
	{ok, false}->
	    slog:event(count, ?MODULE,subscribe_failed),
	    {error, subscription_false};
	Else ->
	    slog:event(count, ?MODULE,subscribe_failed,Else),
	    error_ocf(Else, subscribeByMsisdn, MSISDN)
    end.   
	  
%% +type subscribeByImsi(imsi())-> {ok, ocf_info_client()} | {error,term()}.
subscribeByImsi(IMSI)->
    slog:event(trace, ?MODULE,subscribeByImsi, IMSI),
    slog:event(count, ?MODULE,subscribe),
    Call= {call, 'OrangeAPI.subscribeByImsi', [login(),IMSI,{struct,[]}]},
     case send(Call,get_time_out(sub)) of
         {ok, [{struct,[{'SubscriptionResult',true},
                        {'CustomerData',{struct,Resp}}]}]}->
             {ok, decode_info_client(Resp)};
	 {ok, [{struct,[{'CustomerData',{struct,Resp}},
		        {'SubscriptionResult',true}]}]}->
	     {ok, decode_info_client(Resp)};
	 {ok, false}->
	     slog:event(count, ?MODULE,subscribe_failed),
	     {error, subscription_false};
	 Else ->
	     slog:event(count, ?MODULE,subscribe_failed,Else),
	     error_ocf(Else, subscribeByImsi,IMSI)
    end.

%% +type unsubscribeByMsisdn(msisdn())-> bool() | {error,term()}.
unsubscribeByMsisdn(MSISDN)->
    slog:event(trace, ?MODULE,unSubscribeByMsisdn,MSISDN),
    slog:event(count, ?MODULE,unsubscribe),
    Call= {call, 'OrangeAPI.unSubscribeByMsisdn', [login(),
						   format_msisdn(MSISDN)]},
    case send(Call) of
	{ok,[Resp]} when Resp==true;Resp==false->
	    Resp; %% true or false
	Else->
	    slog:event(count, ?MODULE,unsubscribe_failed),
	    error_ocf(Else,unSubscribeByMsisdn,MSISDN)
    end.

%% +type unsubscribeByImsi(imsi())-> bool() | {error,term()}.
unsubscribeByImsi(IMSI)->
    slog:event(trace, ?MODULE,unSubscribeByImsi,IMSI),
    slog:event(count, ?MODULE,unsubscribe),
    Call= {call, 'OrangeAPI.unSubscribeByImsi', [login(),IMSI]},
    case send(Call) of
	{ok,[Resp]} when Resp==true;Resp==false->
	    Resp; %% true or false
	Else->
	    slog:event(count, ?MODULE,unsubscribe_failed),
	    error_ocf(Else,unSubscribeByImsi,IMSI)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Consultation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type getUserInformationByMsisdn(msisdn())-> 
%%                    {ok, ocf_info_client()} | {error,term()}.
getUserInformationByMsisdn(MSISDN)->
    slog:event(trace, ?MODULE,getUserInformationByMsisdn,MSISDN),
    slog:event(count, ?MODULE,getUserInformation),
    Call= {call, 'OrangeAPI.getUserInformationByMsisdn', 
	   [login(), format_msisdn(MSISDN)]},
    case send(Call,get_time_out(get)) of
	{ok, [{struct,Resp}]}->
	    {ok, decode_info_client(Resp)};
	Else ->
	    slog:event(count, ?MODULE,getUserInformation_failed),
	    error_ocf(Else,getUserInformationByMsisdn,MSISDN)
    end.
%% +type getUserInformationByImsi(imsi())-> 
%%                    {ok, ocf_info_client()} | {error,term()}.
getUserInformationByImsi(IMSI)->
    slog:event(trace, ?MODULE,getUserInformationByImsi, IMSI),
    slog:event(count, ?MODULE,getUserInformation),
    Call= {call, 'OrangeAPI.getUserInformationByImsi', [login(),IMSI]},
    case send(Call,get_time_out(get)) of
	{ok, [{struct,Resp}]}->
	    {ok, decode_info_client(Resp)};
	Else ->
	    %%io:format("Error get user:~p~n",[Else]),
	    slog:event(count, ?MODULE,getUserInformation_failed),
	    error_ocf(Else,getUserInformationByImsi,IMSI)
    end.
%% +type getSubscriptionInformationByMsisdn(VasID::string(),msisdn())-> 
%%                    {ok, ocf_info_client(), ocf_subscription()} | 
%%                    {error,term()}.
getSubscriptionInformationByMsisdn(VasID,MSISDN)->
    slog:event(trace, ?MODULE,getSubscriptionInformationByMsisdn,MSISDN),
    slog:event(count, ?MODULE,getSubscriptionInformation),
    Call= {call, 'OrangeAPI.getSubscriptionInformationByMsisdn', 
	   [login(),VasID,format_msisdn(MSISDN)]},
    case send(Call,get_time_out(get)) of
	{ok, [{struct,[{'CustomerData',{struct,InfoClient}},
		       {'SubscriptionInfo',{struct,Sub_Info}}]}]}->
	    {ok, decode_info_client(InfoClient),decode_subscription(Sub_Info)};
	Else ->
	    slog:event(count, ?MODULE,getSubscriptionInformation_failed),
	    error_ocf(Else,getSubscriptionInformationByMsisdn,MSISDN)
    end.

%% +type getSubscriptionInformationByImsi(VasID::string(),imsi())-> 
%%                    {ok, ocf_info_client(), ocf_subscription()} | 
%%                     {error,term()}.
getSubscriptionInformationByImsi(VasID,IMSI)->
    slog:event(trace, ?MODULE,getSubscriptionInformationByImsi,IMSI),
    slog:event(count, ?MODULE,getSubscriptionInformation),
    Call= {call, 'OrangeAPI.getSubscriptionInformationByImsi', 
	   [login(),VasID,IMSI]},
    case send(Call,get_time_out(get)) of
	{ok, [{struct,[{'CustomerData',{struct,InfoClient}},
		       {'SubscriptionInfo',{struct,Sub_Info}}]}]}->
	    {ok, decode_info_client(InfoClient),decode_subscription(Sub_Info)};
	Else ->
	    slog:event(count, ?MODULE,getSubscriptionInformation_failed),
	    error_ocf(Else,getSubscriptionInformationByImsi,IMSI)
    end.

%% +type isMsisdnOrange(msisdn())-> bool() | {error,term()}.
isMsisdnOrange(MSISDN)->
    slog:event(trace, ?MODULE,isMsisdnOrange,MSISDN),
    slog:event(count, ?MODULE,isMsisdnOrange),
    Call= {call, 'OrangeAPI.isMsisdnOrange', [login(),format_msisdn(MSISDN)]},
    case send(Call,get_time_out(is_orange)) of
	{ok,[Bool]} when Bool==true;Bool==false->
	    Bool; %% true or false
	Else->
	    slog:event(count, ?MODULE,isMsisdnOrange_failed),
	    error_ocf(Else,isMsisdnOrange,MSISDN)
    end.

%% +type getOptionalServicesByMsisdn(msisdn())-> {ok, [ocf_option()]} | {error,term()}.
getOptionalServicesByMsisdn(MSISDN)->
    slog:event(trace, ?MODULE,getOptionalServicesByMsisdn,MSISDN),
    slog:event(count, ?MODULE,getOptionalServices),
    Call= {call, 'OrangeAPI.getOptionalServicesByMsisdn', [login(),format_msisdn(MSISDN)]},
    case send(Call,get_time_out(get)) of
	{ok,[{array,Resp}]}->
	    slog:event(trace,?MODULE,getOptionalServicesByMsisdn_res,Resp),
	    {ok, decode_options(Resp)};
	Else->
	    slog:event(count, ?MODULE,getOptionalServices_failed),
	    error_ocf(Else,getOptionalServicesByMsisdn,MSISDN)
    end.
%%%%%%%%%%%%%%%%%%%%%%%% GENRIC FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type login()-> term().
login()->
   {Login,Passwd}= pbutil:get_env(pfront_orangef,ocf_rdp_login),
   {struct, [{username,Login},{password,Passwd}]}.

%% +deftype xmlrpc_result() =
%%         {fault, F_C::integer(),F_S::string()} |
%%         {ok, term()} |
%%         {error, timeout} |
%%         {error, term()}.

%% +type send(term())-> xmlrpc_result().
send(Call)->
    T0 = oma:unixmtime(),
    Result=
       case catch pbutil:get_env(pfront_orangef, ocfrdp_version) of
            online->
			 	slog:event(trace,?MODULE,ocfrdp_version,online),
              	catch ocfrdp_online:request(Call);
		     _-> 
			 	slog:event(trace,?MODULE,ocfrdp_version,ocfrdp_G2R0),
               	catch xmlrpc_fep:request(Call,ocf_rdp)
       end,
    case Result of
	{ok, {response, {fault, F_C, F_Str}}}->
            slog:event(count,?MODULE,response_ok),
	    slog:delay(perf, ?MODULE, response_delay, T0),
	    {fault, F_C, F_Str};
	{ok, {response, Resp}}->
            slog:event(count,?MODULE,response_ok,Resp),
	    slog:delay(perf, ?MODULE, response_delay, T0),
	    {ok, Resp}; 
	{'EXIT',{timeout,_}}->
            slog:event(count,?MODULE,response_ko),
	    {error,timeout};	
	Else ->
	    %io:format("Else:~p~n",[Else]),
            slog:event(count,?MODULE,response_ko,Else),
	    {error,Else}
    end.

%% +type send(term(),TO::integer())-> xmlrpc_result().
send(Call,Timeout)->
    T0 = oma:unixmtime(),
    Result=
	case catch pbutil:get_env(pfront_orangef, ocfrdp_version) of
		online->
			 slog:event(trace,?MODULE,ocfrdp_version,online),
             catch ocfrdp_online:request(Call);
        _->
			 slog:event(trace,?MODULE,ocfrdp_version,ocfrdp_G2R0),
             catch xmlrpc_fep:request(Call,ocf_rdp,Timeout)
    end,
    case Result of
	{ok, {response, {fault, F_C, F_Str}}}->
	    slog:delay(perf, ?MODULE, response_delay, T0),
            slog:event(count,?MODULE,response_ok),
	    {fault, F_C, F_Str};
	{ok, {response, Resp}}->
            slog:event(count,?MODULE,response_ok,Resp),
	    slog:delay(perf, ?MODULE, response_delay, T0),
	    {ok, Resp}; 
	{'EXIT',{timeout,_}}->
            slog:event(count,?MODULE,response_ko),
	    {error,timeout};	
	Else ->
	    %io:format("Else:~p~n",[Else]),
            slog:event(count,?MODULE,response_ko,Else),
	    {error,Else}
    end.

%%%%%%%%%%%%% ERROR NOTIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type error_ocf(xmlrpc_result()) -> {error, term()}.
error_ocf({fault,Fault_Code,Fault_String}) when integer(Fault_Code)->
    decode_fault_code(Fault_Code),
    %io:format("FAULT code:~p~n",[Fault_String]),
    {error,Fault_Code};
error_ocf({fault,Fault_S,Fault_C}) when integer(Fault_C)->
    decode_fault_code(Fault_C),
    %io:format("FAULT code:~p~n",[Fault_S]),
    {error,Fault_C};
error_ocf({error,timeout})->
    %slog:event(failure,?MODULE, timeout_ocf),
    {error,timeout};
error_ocf({error,Reason}) ->
    %slog:event(failure,?MODULE, wrong_response,Else),
    {error,Reason};
error_ocf(Else) ->
    {error,Else}.


%% FAULT CODE ALARMs Generation
%% +type decode_fault_code(integer())-> ok.
decode_fault_code(-3) ->
    slog:event(warning,?MODULE,class_cast_error);
decode_fault_code(-2) ->
    slog:event(warning,?MODULE,method_name_unknown);
decode_fault_code(-1) ->
    slog:event(internal,?MODULE,xml_not_well_formed);
decode_fault_code(1)->
    slog:event(internal,?MODULE,login_failed);
decode_fault_code(2) ->
    slog:event(warning,?MODULE,service_unavailable);
decode_fault_code(4) ->
    slog:event(failure,?MODULE,no_such_service);
decode_fault_code(5) ->
    slog:event(internal,?MODULE,invalid_argument);
decode_fault_code(10) ->
    slog:event(warning,?MODULE,api_technical_error);
decode_fault_code(11) ->
    slog:event(warning,?MODULE,unknow_imsi);
decode_fault_code(12) ->
    slog:event(warning,?MODULE,unknown_vas);
decode_fault_code(13) ->
    slog:event(warning,?MODULE,multiple_subscription);
decode_fault_code(14) ->
    slog:event(internal,?MODULE,unauthorised_subscription);
decode_fault_code(15) ->
    slog:event(internal,?MODULE,parameter_missing);
decode_fault_code(16) ->
    slog:event(warning,?MODULE,invalid_request);
decode_fault_code(20) ->
    slog:event(warning,?MODULE,inactif_user);
decode_fault_code(21) ->
    slog:event(failure,?MODULE,consult_error);

decode_fault_code(X) ->
    slog:event(failure,?MODULE,unknown_fault_code,X).


%%%%%%%%%%%%% ERROR NOTIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type error_ocf(xmlrpc_result()) -> {error, term()}.
error_ocf({fault,Fault_Code,Fault_String},Request, Number) when integer(Fault_Code)->
    decode_fault_code(Fault_Code,Request, Number),
    {error,Fault_Code};
error_ocf({fault,Fault_S,Fault_C},Request, Number) when integer(Fault_C)->
    decode_fault_code(Fault_C,Request, Number),
    {error,Fault_C};
error_ocf({error,timeout},Request, Number)->
    slog:event(failure,?MODULE, timeout_ocf,{Request, Number}),
    {error,timeout};
error_ocf({error,Reason},Request, Number) ->
    slog:event(failure,?MODULE, wrong_response,{Reason,Request, Number}),
    {error,Reason};
error_ocf(Else,Request, Number) ->
    slog:event(failure,?MODULE, unexpected_answer,{Else,Request, Number}),
    {error,Else}.

%% FAULT CODE ALARMs Generation
%% +type decode_fault_code(integer())-> ok.
decode_fault_code(-3, Request, Number) ->
    slog:event(warning,?MODULE,-3,{class_cast_error,Request, Number});
decode_fault_code(-2, Request, Number) ->
    slog:event(warning,?MODULE,-2,{method_name_unknown,Request, Number});
decode_fault_code(-1, Request, Number) ->
    slog:event(internal,?MODULE,-1,{xml_not_well_formed,Request, Number});
decode_fault_code(1, Request, Number)->
    slog:event(internal,?MODULE,1,{login_failed,Request, Number});
decode_fault_code(2, Request, Number) ->
    slog:event(warning,?MODULE,2,{service_unavailable,Request, Number});
decode_fault_code(4, Request, Number) ->
    slog:event(failure,?MODULE,4,{no_such_service,Request, Number});
decode_fault_code(5, Request, Number) ->
    slog:event(internal,?MODULE,5,{invalid_argument,Request, Number});
decode_fault_code(10, Request, Number) ->
    slog:event(warning,?MODULE,10,{api_technical_error,Request, Number});
decode_fault_code(11, Request, Number) ->
    slog:event(warning,?MODULE,11,{unknow_imsi,Request, Number});
decode_fault_code(12, Request, Number) ->
    slog:event(warning,?MODULE,12,{unknown_vas,Request, Number});
decode_fault_code(13, Request, Number) ->
    slog:event(warning,?MODULE,13,{multiple_subscription,Request, Number});
decode_fault_code(14, Request, Number) ->
    slog:event(internal,?MODULE,14,{unauthorised_subscription,Request, Number});
decode_fault_code(15, Request, Number) ->
    slog:event(internal,?MODULE,15,{parameter_missing,Request, Number});
decode_fault_code(16, Request, Number) ->
    slog:event(warning,?MODULE,16,{invalid_request,Request, Number});
decode_fault_code(20, Request, Number) ->
    slog:event(warning,?MODULE,20,{inactif_user,Request, Number});
decode_fault_code(21, Request, Number) ->
    slog:event(failure,?MODULE,21,{consult_error,Request, Number});

decode_fault_code(X, Request, Number) ->
    slog:event(failure,?MODULE,X,{unknown_fault_code,Request, Number}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type segco_to_subscription(SegCo::string())-> 
%%                             sub_of() | unknown_sub.

segco_to_subscription(SegCo) ->
    ListSegCoToSub = pbutil:get_env(pfront_orangef, segco_to_subscr),
    subscr_is(SegCo, ListSegCoToSub).

subscr_is(SegCo, []) ->
    slog:event(failure,?MODULE,unknown_subscription,SegCo),
    unknown_sub;

subscr_is(SegCo, [{ListSegCo, Sub}|T]) ->
    case lists:member(SegCo, ListSegCo) of
	true -> Sub;
	_ -> subscr_is(SegCo, T)
    end.

%% +type decode_info_client([{Label::atom(),Val::string()}])-> 
%%            ocf_info_client().
decode_info_client(INFOS)->
    OIC = decode_info_client(INFOS,#ocf_info_client{}),
    case OIC#ocf_info_client.tech_seg of
	undefined ->
	    OIC#ocf_info_client{
	      tech_seg = ocf_rdp:tech_seg_int_to_code(?OCF_NO_FIELD)};
	_ ->
	    OIC
    end.

%% + type decode_info_client([{Label::atom(),Val::string()}],
%%                 ocf_info_client())->    ocf_info_client().
decode_info_client([{'Msisdn',MSISDN}|T],OCF)->
    decode_info_client(T,OCF#ocf_info_client{msisdn=msisdn(MSISDN)});
decode_info_client([{'Imsi',IMSI}|T],OCF) ->
    decode_info_client(T,OCF#ocf_info_client{imsi=IMSI});
decode_info_client([{'CreationDate',{date,Date}}|T],OCF)->
    decode_info_client(T,
		       OCF#ocf_info_client{creationDate=decode_iso8601(Date)});
decode_info_client([{'LastUpdate',{date,Date}}|T],OCF)->
     decode_info_client(T,
			OCF#ocf_info_client{lastUpdate= decode_iso8601(Date)});
decode_info_client([{'USSDLevel',Level}|T],OCF)->
     decode_info_client(T,
			OCF#ocf_info_client{
			  ussd_level=Level});
decode_info_client([{'TACCode',TAC}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{tac=TAC});
decode_info_client([{'IMEI',TAC}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{imei=TAC});
decode_info_client([{'TechnologicalSegment',SEG}|T],OCF)->
    TSC = translate_tech_seg(SEG),
    decode_info_client(T,OCF#ocf_info_client{tech_seg=TSC});
decode_info_client([{'SegmentCode',SEG}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{segmentCode=SEG});
decode_info_client([{'FileState',SEG}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{filestate=SEG});
decode_info_client([{'CustomerId',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{customerId=Val});
decode_info_client([{'Nsc',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{nsc=Val});
decode_info_client([{'Nsce',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{nsce=Val});
decode_info_client([{'DataOrigin',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{dataorigin=Val});
decode_info_client([{'DeltaT1Date',Val}|T],OCF)->
    decode_info_client(T,OCF#ocf_info_client{deltaT1Date=
					     decode_iso8601(Val)});
decode_info_client([{'UARadio',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{uaRadio=Val});
decode_info_client([{'UAProf',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{uaProf=Val});
decode_info_client([{'PrepaidFlag',Val}|T],OCF)->
      decode_info_client(T,OCF#ocf_info_client{prepaidFlag=Val});
decode_info_client([{'MMSCompatibilityTAC',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{mmscompatibilityTAC=Val});
decode_info_client([{'JavaEnabled',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{java_enabled=Val});
decode_info_client([{'SachemServices',Val}|T],OCF)->
     decode_info_client(T,OCF#ocf_info_client{sachemServices=
					      decode_sachem_options(Val)});
decode_info_client([{Name,V}|T],OCF) when Name=='Name';
					  Name=='Adress';
					  Name=='ZipCode';
					  Name=='BirthDate';
					  Name=='SaleOulet';
					  Name=='UAPeripherial'->
    %% shadow unused parameters
    decode_info_client(T,OCF);
decode_info_client([{Name,V}|T],OCF)->
    io:format("WARNIG UKNOWN NAME:~p~n",[Name]),
    decode_info_client(T,OCF);
decode_info_client([],OCF) ->
    OCF;
decode_info_client(Else,OCF)->
    io:format("WARNIG UKNOWN FORMAT:~p~n",[Else]),
    {error,unknow_format,Else}.

%% +type decode_iso8601(Date::string()) -> {date(),time()} | no_date.
decode_iso8601(Date)->
    case catch pbutil:sscanf("%4d%2d%2dT%2d:%2d:%2d",Date) of
	{[Y,Mo,D,H,Mi,S],_}->
	    {{Y,Mo,D},{H,Mi,S}};
	E ->
	    io:format("~p~n",[E]),
	    no_date
    end.

%% +type decode_sachem_options(Val::term())-> no_options.
decode_sachem_options(Val)->
    io:format("Val:~p~n",[Val]),
    no_options.

%% +type decode_subscription([{Label::atom(),Val::string()}])-> 
%%       ocf_subscription().
decode_subscription(Subscriptions)->
    decode_sub(Subscriptions,#ocf_subscription{}).

%% +type decode_sub([{Label::atom(),Val::string()}],ocf_subscription())->
%%       ocf_subscription().   
decode_sub([{'Email1',Email}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{email1=Email});
decode_sub([{'Email2',Email}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{email2=Email});
decode_sub([{'Email3',Email}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{email3=Email});
decode_sub([{'MailboxStatus',MB}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{mailBoxStatus=MB});
decode_sub([{'ActivePortal',AP}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{activePortal=AP});
decode_sub([{'MMSBlacklist',MMS}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{mmsBlacklist=MMS});
decode_sub([{'SMSInfo',SMS}|T],OCF_SUB)->
    decode_sub(T,OCF_SUB#ocf_subscription{smsInfo=SMS});
decode_sub([{Name,V}|T],OCF_SUB)->
    io:format("WARNIG UKNOWN NAME:~p~n",[Name]),
    decode_sub(T,OCF_SUB);
decode_sub([],OCF_SUB) ->
    OCF_SUB;
decode_sub(Else,OCF_SUB)->
    io:format("WARNIG UKNOWN FORMAT:~p~n",[Else]),
    {error,unknow_format,Else}.

%% +type msisdn(string())-> string().
msisdn("99"++T=M)->
    "+"++M;
msisdn("33"++T=M) ->
    "+"++M;
msisdn(Else) ->
    "".

%% +type format_msisdn(string())-> string().
format_msisdn("06"++X)->
    "336"++X;
format_msisdn("07"++X)->
    "337"++X;
format_msisdn("33"++X=M) ->
    M;
format_msisdn("09"++X) ->
    "999"++X;
format_msisdn("+336"++X) ->
    "336"++X;
format_msisdn("+337"++X) ->
    "337"++X;
format_msisdn("+33"++X) ->
    "33"++X;
format_msisdn("+99"++X) ->
    "99"++X.


%% +type decode_options([{Label::atom(),Val::string()}])-> 
%%            [ocf_option()].
decode_options(INFOS)->
    lists:map(fun({struct,Opt_Value})->
			decode_options(Opt_Value,#ocf_option{})
		end,INFOS).

%% +type decode_options(term(),ocf_option())-> ocf_option().
decode_options([{'EndSubscriptionDate',{date,Date}}|T],OCF)->
    %%io:format("Date: ~p~n",[decode_iso8601(Date)]),
    decode_options(T,OCF#ocf_option{end_date=decode_iso8601(Date)});
decode_options([{'PrestationCode',PSC}|T],OCF) ->
    %%io:format("Prestation Code: ~p~n",[PSC]),
    decode_options(T,OCF#ocf_option{prest_code=PSC});
decode_options(NameVal,OCF) ->
    %%io:format("Rest~p~n",[NameVal]),
    OCF.

%% +type translate_tech_seg(null | string()) -> string().
translate_tech_seg(Empty) when Empty == null; Empty == "" ->
    ocf_rdp:tech_seg_int_to_code(?OCF_DOES_NOT_KNOW);
translate_tech_seg(SEG) ->
    SEG.

%% +type tech_seg_int_to_code(tech_seg_int())
%%  -> not_found | tech_seg_code().
tech_seg_int_to_code(TSI) ->
    TSM = pbutil:get_env(pfront_orangef, tech_segs_mapping),
    case lists:keysearch(TSI, 1, TSM) of
	false                -> not_found;
	{value, {TSI, Code}} -> Code
    end.

%% +type tech_seg_code_to_int(string())
%%  -> not_found | tech_seg_int().
tech_seg_code_to_int(Code) ->
    TSM = pbutil:get_env(pfront_orangef, tech_segs_mapping),
    case lists:keysearch(Code, 2, TSM) of
	false                -> not_found;
	{value, {TSI, Code}} -> TSI
    end.



slog_info(internal,?MODULE, invalid_argument)->
    #slog_info{descr="Bad argument used in RDP request",
               operational="Check the arguments used to send RDP request\n"};
slog_info(failure,?MODULE, timeout_ocf)->
 #slog_info{descr="Timeout from OCF_RDP",
               operational="Check the value of the Timeout,Check on OCF RDP side\n"};
slog_info(failure,?MODULE, wrong_response) ->
 #slog_info{descr="An unexpected answer has been sent by OCF RDP to Cellcube",
               operational="Check on OCF RDP side  and check in the logs the arguments used to send RDP request\n"};
slog_info(failure,?MODULE, unexpected_answer)->
 #slog_info{descr="An unexpected answer has been sent by OCF RDP to Cellcube",
               operational="Check on OCF RDP side  and check in the logs the arguments used to send RDP request\n"};
slog_info(internal,?MODULE, -3)-> 
 #slog_info{descr="Error code -3 returned by OCF RDP (Class cast error)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(internal,?MODULE, -2)->
 #slog_info{descr="Error code -2 returned by OCF RDP (method name unknown)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(internal,?MODULE, -1)->
 #slog_info{descr="Error code -1 returned by OCF RDP (xml not well formatted)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(internal,?MODULE,  1)->
 #slog_info{descr="Error code 1 returned by OCF RDP (login failed)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(failure,?MODULE,   2)->
 #slog_info{descr="Error code 2 returned by OCF RDP (service unavailable)",
               operational="Check on OCF RDP side \n"};
slog_info(failure,?MODULE,   4)->
 #slog_info{descr="Error code 4 returned by OCF RDP (No such service)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(internal,?MODULE,  5)->
 #slog_info{descr="Error code 5 returned by OCF RDP (Bad argument used in RDP request)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(failure,?MODULE,  10)->
 #slog_info{descr="Error code 10 returned by OCF RDP (API technical error)",
               operational="Check on OCF RDP side\n"};
slog_info(warning,?MODULE,  11)->
 #slog_info{descr="Error code 11 returned by OCF RDP (Unknwon IMSI)",
               operational="Check on OCF RDP side\n"};
slog_info(failure,?MODULE,  12)->
 #slog_info{descr="Error code 12 returned by OCF RDP (Unknown VAS)",
               operational="Check on OCF RDP side\n"};
slog_info(warning,?MODULE,  13)->
 #slog_info{descr="Error code 13 returned by OCF RDP (Multiple Subscription)",
               operational="Check on OCF RDP side\n"};
slog_info(failure,?MODULE, 14)->
 #slog_info{descr="Error code 14 returned by OCF RDP (Unauthorised subscription)",
               operational="Check on OCF RDP side\n"};
slog_info(internal,?MODULE, 15)->
 #slog_info{descr="Error code 15 returned by OCF RDP (Parameter missing)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(warning,?MODULE,  16)->
 #slog_info{descr="Error code 16 returned by OCF RDP (Invalid request)",
               operational="Check the arguments used to send RDP request\n"};
slog_info(warning,?MODULE,  20)->
 #slog_info{descr="Error code 20 returned by OCF RDP (Inactive user)",
               operational="Check on OCF RDP side\n"};
slog_info(failure,?MODULE,  21)->
 #slog_info{descr="Error code 21 returned by OCF RDP (Consultation error)",
               operational="Check on OCF RDP side\n"};
slog_info(failure,?MODULE,  X)->
 #slog_info{descr="Error code " ++ integer_to_list(X) ++ " returned by OCF RDP.(Unknown service code)",
               operational="Check on OCF RDP side and check the arguments used to send RDP request\n"}.
