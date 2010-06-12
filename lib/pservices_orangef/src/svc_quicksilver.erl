-module(svc_quicksilver).

-export([in_which_period/2,
	 get_quicksilver_code/0,
	 store_quicksilver_info/2,
	 get_quicksilver_info/1,
	 check_threshold/0,
	 check_right_access_quicksilver/3,
	 redirect_quicksilver/5,
         extract_users/1]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/db.hrl").
-include("../../pdist/include/generic_router.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/subscr_asmetier.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/quicksilver.hrl").

in_which_period(_,[]) ->
    out;

in_which_period(Date,[P1|Periods]) ->
    {StartPeriod, EndPeriod} = P1,
    case ( StartPeriod < Date ) and ( Date < EndPeriod ) of
	true ->
	    {in, P1};
	false ->
	    in_which_period(Date,Periods)
    end.

get_quicksilver_code() ->
    Commands = [ "SELECT id,promo_code "
		 "FROM quicksilver limit 1",
		 "DELETE FROM quicksilver limit 1"],

    case ?SQL_Module:execute_stmt({atomic,Commands}, [orangef,users], ?SQL_SELECT_TIMEOUT) of
	{committed,[{selected, _,[[Id,Code]]},{updated, 1}]} ->
	    Code;
	RES ->
	    {not_found, RES}
    end.

store_quicksilver_info(Session,Quicksilver) ->
    db:update_svc_profile(Session,"quicksil",Quicksilver).

get_quicksilver_info(Session) ->
    case db:lookup_svc_profile(Session, "quicksil") of
	{ok, Data} ->
	    {ok, Data};
	Else ->
	    {not_found, Else}
    end.

check_threshold() ->
    Threshold = pbutil:get_env(pservices_orangef,quicksilver_threshold),
    
    ComCount = ["SELECT COUNT(*) FROM quicksilver"],
    case ?SQL_Module:execute_stmt(ComCount, [orangef,users], ?SQL_SELECT_TIMEOUT) of
	{selected, _, [[Number]]} ->
	    Num = list_to_integer(Number),
	    if 
		Num > Threshold ->
		    ok;
		true ->
		    slog:event(internal,?MODULE,quicksilver_threshold_reached,{{threshold,Threshold},{records_number,Num}})
	    end;
	Else ->
	    {error, Else}
    end.

%% +type check_right_access_quicksilver(session(),UrlOk::string(),UrlNok::string()) ->
%%                     hlink().
%%%% Check right access to quicksilver menu according the value of asmetier codeOffreType
check_right_access_quicksilver(plugin_info,UrlOk,UrkNok) ->
    (#plugin_info
     {help =
      "This plugin function check right access to quicksilver menu according the value of"
      " asmetier \"codeOffreType\"",
      type = command,
      license = [],
      args = [
              {urlok, {link,[]},
               "This parameter specifies the next page in case having access right to quicksilver menu"},
              {urlnok, {link,[]},
               "This parameter specifies the next page in case not having access right to quiclsilver menu ."}
             ]
     });
check_right_access_quicksilver(abs,UrlOk,UrlNok) ->
    [{redirect,abs,UrlOk},
     {redirect,abs,UrlNok}];
check_right_access_quicksilver(Session,UrlOk,UrlNok) ->
    case svc_subscr_asmetier:get_identification(Session,"oee") of
        {ok,IdDosOrId,IdUtilisateurEdlws,CodeOffre,_,Session1} ->
	    case lists:member(CodeOffre,?QuicksilverCodes) of
		true ->
		    {redirect,Session1,UrlOk};
		_ ->
		    {redirect,Session1,UrlNok}
	    end;
        _ ->
            {redirect,Session,UrlNok}
    end.


%% +type redirect_quicksilver(session(),UrlOffPeriod::string(),UrlFirstTime::string(),UrlNthTime::string()) ->
%%                     erlpage_result()..
%%%% Includes the quicksilver link according the value of asmetier codeOffreType
redirect_quicksilver(plugin_info,UrlOffPeriod,UrlFirstTime,UrlNthTime,UrlError) ->
    (#plugin_info
     {help =
      "This plugin command redirects towards 4 possible Urls."
      "\n1. offperiod: Today is not in holidays period."
      "\n2. firsttime: Today is in holidays period and customer asks for the quicksilver code for the first time."
      "\n3. nthtime:   Today is in holidays period and customer asks for the quicksilver code for the Nth time."
      "\n4. error:   An error occured.",
      type = command,
      license = [],
      args = [
	      {offperiod, {link,[]},
	       "This parameter specifies the page when we are off period time."},
	      {firsttime, {link,[]},
	       "This parameter specifies the page when customer asks for the quicksilver code for the first time."},
	      {nthtime, {link,[]},
	       "This parameter specifies the page when customer asks for the quicksilver code for the Nth time."},
	      {error, {link,[]},
	       "This parameter specifies the page when customer asks for the quicksilver code for the Nth time."}
	     ]
     });

redirect_quicksilver(abs,UrlOffPeriod,UrlFirstTime,UrlNthTime,UrlError) ->
    [{redirect,abs,UrlOffPeriod},
     {redirect,abs,UrlFirstTime},
     {redirect,abs,UrlNthTime},
     {redirect,abs,UrlError}];

redirect_quicksilver(Session, UrlOffPeriod,UrlFirstTime,UrlNthTime,UrlError) ->
    case application:get_env(pservices_orangef,commercial_date_cmo) of
	{ok, AllPeriods} ->
	    case lists:keysearch(plan_zap,1,AllPeriods) of
		{value,{plan_zap,Periods}} ->
		    case in_which_period(erlang:localtime(),Periods) of
			out ->
			    {redirect,Session,UrlOffPeriod};
			{in, CurrentPeriod} ->
			    continue_redirect_quicksilver(Session,UrlFirstTime,UrlNthTime,UrlError,Periods,CurrentPeriod)
		    end;
		_ ->
		    slog:event(internal,?MODULE,parameter_plan_zap_not_found),
		    {redirect,Session,UrlError}
	    end;
	_ ->
	    slog:event(internal,?MODULE,parameter_commercial_date_cmo_not_found),
	    {redirect,Session,UrlError}
    end.

continue_redirect_quicksilver(Session,UrlFirstTime,UrlNthTime,UrlError,Periods,CurrentPeriod) ->
    %% check if code not already recovered previously during the session
    case variable:get_value(Session, {quicksilver,code}) of
	not_found ->
	    case get_quicksilver_info(Session) of
		{ok, Data} ->
		    case in_which_period(Data#quicksilver.date_extraction,
                                         Periods) of
			{in, CurrentPeriod} ->
                            %% same period, same code to be shown
                            Session1 = variable:update_value(Session, {"quicksilver","code"}, Data#quicksilver.code_promo),
                            {redirect,Session1,UrlNthTime};
                        _ ->
                            provide_quicksilver_code(Session,UrlFirstTime,UrlError)
		    end;
		{not_found, not_found} ->
		    provide_quicksilver_code(Session,UrlFirstTime,UrlError);
		Else ->
		    slog:event(internal,?MODULE,get_quicksilver_info,Else),
		    {redirect,Session,UrlError}
	    end;
	_ ->
	    {redirect,Session,UrlNthTime}
    end.

provide_quicksilver_code(Session,UrlFirstTime,UrlError) ->
    case get_quicksilver_code() of
	{not_found, Else} ->
	    slog:event(internal,?MODULE,get_quicksilver_code,Else),
	    {redirect,Session,UrlError};
	Code ->
	    Quicksilver = #quicksilver{code_promo = Code,
				       date_extraction = erlang:localtime()},
	    case store_quicksilver_info(Session,Quicksilver) of
		ok ->
		    Session1 = variable:update_value(Session, {"quicksilver","code"}, Code),
		    send_sms(Session1,Code),
		    prisme_dump:prisme_count_v1(Session,"CQSL"),
		    {redirect,Session1,UrlFirstTime};
		Error ->
		    slog:event(internal,?MODULE,store_quicksilver_info,Error),
		    {redirect,Session,UrlError}
	    end
    end.

send_sms(Session,Code)->
    Text = lists:flatten(io_lib:format(?QuickSmsText, [Code])),
    Target = (Session#session.prof)#profile.msisdn,
    Routing = pbutil:get_env(pservices_orangef, call_me_back_routing),
    case catch svc_util_of:send_smsmt(Session, Text, Target,[Routing]) of
	{ok, _} -> true;
	Err -> slog:event(failure, ?MODULE, send_sms, Err),
	       false
    end.

%%%% DO NOT USE IN PRODUCTION
%%%% Extract users having received a quicksilver code.
%%%% CSV format: MSISDN;date

extract_users(File) ->
    CMD="SELECT UID FROM svcprofiles_v2_quicksil'",
    UIDs = try ?SQL_Module:execute_stmt(CMD,[orangef,svcprofiles_v2],100000) of
               {selected,_,UIDs_}->
                   slog:event(trace,?MODULE,uids_length,length(UIDs_)),
                   UIDs_;
               Else1 ->
                   slog:event(trace,?MODULE,request_quicksilver_uids_failed,
                              Else1),
                   []
           catch Tag1:Value1->
                   slog:event(failure,?MODULE,request_quicksilver_uids_exited,
                              {Tag1,Value1}),
                   []
           end,
    {ok, FD} = file:open(File,[append]),
    try dump_uids(UIDs,FD) of
        ok -> 
            ok;
	Else2 ->
	    slog:event(trace,?MODULE,dump_failed,Else2)
    catch Tag2:Value2->
	    slog:event(failure,?MODULE,dump_exited,{Tag2,Value2})
    after
        file:close(FD)
    end.

dump_uids(Uids,FD) ->
    lists:all(fun([Uid]) -> dump_uid(Uid,FD) end, Uids).

dump_uid(UID,FD) ->
    MSISDN = try db:lookup_profile({uid,list_to_integer(UID)}) of
                 #profile{msisdn=MSISDN_} ->
                     MSISDN_;
                 not_found ->
                     msisdn_unknown
             catch Tag1:Value1 ->
                     {msisdn_failed,{UID,{Tag1,Value1}}}
             end,
    Date = try db:lookup_svc_profile_uid(list_to_integer(UID), "quicksil") of
               {ok, #quicksilver{date_extraction=Date_}} ->
                   Date_;
               Else ->
                   {date_not_found, Else}
           catch Tag2:Value2 ->
                   {date_failed,{UID,{Tag2,Value2}}}
           end,
    DUMP = io_lib:format("~p;~p~n",[MSISDN,Date]),
    file:write(FD,DUMP),
    true.

