-module(svc_util_of).

-compile(export_all).

%%-export([redirect_by_tac/3]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/db.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../include/dme.hrl").
-include("../include/postpaid.hrl").
-include("../include/opim.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../../pdist/include/generic_router.hrl").
-include("../../pdatabase/include/pdatabase.hrl").

-define(begin_tac,1).
-define(end_tac,8).

%%%% Available functions :
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Environment function :
%%%% - get_env(configuration_parameter)
%%%%
%%%% Time functions :
%%%% - 
%%%%
%%%% Edition functions :
%%%% - add_br("br").
%%%%
%%%%
%%%% Redirection functions :
%%%% - redirect_if_between_datetimes(
%%%% - redirect_to_url

%% +deftype datetime()=
%%   {{Year::integer(),Month::integer(),Day::integer()},
%%    {Hour::integer(),Minute::integer(),Second::integer()}}.

%% +deftype unixtime()=integer().

%% +deftype pcd_urls()=string().
%%%% string with the format "pcd1=url1,pcd2=url2,...,pcdN=urlN"

%% +deftype br()=string().
%%%% can be "br" or *

%% +deftype datetime_str()=string().
%%%% string with the format "{{Y,Mo,D},{H,Mi,S}}"
%% +deftype time_str()=string().
%%%% string with the format "{H,Mi,S}"


%% +deftype url()=string().
%% +deftype uid() = integer().

%% +type get_env(ParamCfg::atom()) -> *.
get_env(ParamCfg) ->
    pbutil:get_env(pservices_orangef,ParamCfg).

%% +type unixtime() -> unix_time().
%%%% UNIX time, seconds since 1/1/1970 00:00:00 UTC (copied from pbutil.erl)
unixtime() -> {MS,S,_} = now(), MS*1000000 + S.

%% +type local_time() -> datetime().
local_time() -> 
    erlang:localtime().

%% +type add_seconds_to_datetime(datetime(),Secs::integer()) -> datetime().
add_seconds_to_datetime(DateTime, SecsToAdd) ->
    Secs=calendar:datetime_to_gregorian_seconds(DateTime)+SecsToAdd,
    calendar:gregorian_seconds_to_datetime(Secs).

%% +type universal_time_to_unixtime(datetime()) -> unixtime().
universal_time_to_unixtime(DateTime) ->
    calendar:datetime_to_gregorian_seconds(DateTime) - 62167219200.

%% +type unixtime_to_universal_time(unixtime()) -> datetime().
unixtime_to_universal_time(UnixTime) ->
    calendar:gregorian_seconds_to_datetime(UnixTime + 62167219200).

%% +type local_time_to_unixtime(datetime()) -> unixtime().
local_time_to_unixtime(LocalTime) -> 
    UT=calendar:local_time_to_universal_time(LocalTime),
    universal_time_to_unixtime(UT).

%% +type unixtime_to_local_time(unixtime()) -> datetime().
unixtime_to_local_time(UnixTime) ->
    UT=unixtime_to_universal_time(UnixTime),
    calendar:universal_time_to_local_time(UT).

%% +type check_plage_datetimes(datetime(),{datetime(),datetime()}) -> bool().
check_plage_datetimes(DT,{DT1,DT2}) ->
    (DT1 < DT) and (DT < DT2).

%% +type check_plage_horaire(time(),{time(),time()}) -> bool().
check_plage_horaire(_,{Ti,Ti}) -> false;
check_plage_horaire(Time,{Ti,Tf}) ->
    case Ti < Tf of
	true ->
	    (Ti=<Time) and (Time=<Tf);
	false ->
	    check_plage_horaire(Time,{{0,0,0},Tf})
		or check_plage_horaire(Time,{Ti,{23,59,59}})
    end.

%% +type add_br(br()) -> *.
add_br("br") -> [br];
add_br(_) -> [].

%% +type print_link_if_between_datetimes(session(),datetime_str(),
%%                        datetime_str(),pcd_urls(),br()) -> [hlink()].
print_link_if_between_datetimes(abs,DateT_Deb,DateT_Fin,PCD_URL,BR) ->
    print_link_if_between_datetimes(0,DateT_Deb,DateT_Fin,PCD_URL,BR);
print_link_if_between_datetimes(_,DateT_Deb,DateT_Fin,PCD_URL,BR) ->
    DT_Deb=pbutil:string_to_term(DateT_Deb),
    DT_Fin=pbutil:string_to_term(DateT_Fin),
    LT = local_time(),
    case (DT_Deb < LT) and (LT < DT_Fin) of
	true ->
	    [{PCD,URL}]=str2tuplist(PCD_URL,",","="),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	false ->
	    []
    end.

%% +type print_link_if_datetime_is_exceeded(session(),datetime_str(),
%%                                       pcd_urls(),br()) -> [hlink()].
print_link_if_datetime_is_exceeded(abs,DateTimeStr,PCD_URLs,BR) ->
    print_link_if_datetime_is_exceeded(0,DateTimeStr,PCD_URLs,BR);
print_link_if_datetime_is_exceeded(_,DateTimeStr,PCD_URLs,BR) ->
    DateTime = pbutil:string_to_term(DateTimeStr),
    case local_time() > DateTime of
	true ->
	    [{PCD,URL}]=str2tuplist(PCD_URLs,",","="),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	false ->
	    []
    end.

%% +type print_link_if_time_slot(session(),time_str(),time_str(),
%%                               pcd_urls(),br())-> [hlink()].
print_link_if_time_slot(abs,TS1,TS2,PCD_URLs,BR) ->
    print_link_if_time_slot(0,TS1,TS2,PCD_URLs,BR);
print_link_if_time_slot(_,TS1,TS2,PCD_URLs,BR) ->
    T1 = pbutil:string_to_term(TS1),
    T2 = pbutil:string_to_term(TS2),
    [{PCD_OP,URL_OP},{PCD_CL,URL_CL}]=str2tuplist(PCD_URLs,",","="),
    case check_plage_horaire(erlang:time(),{T1,T2}) of
	true ->
	    [#hlink{href=URL_OP,contents=[{pcdata,PCD_OP}]}]++add_br(BR);
	false ->
	    [#hlink{href=URL_CL,contents=[{pcdata,PCD_CL}]}]++add_br(BR)
    end.

%% +type redirect_if_between_datetimes(session(),datetime_str(),datetime_str(),
%%    url(),url()) -> erlpage_result().
redirect_if_between_datetimes(abs,DateT_Deb,DateT_Fin,Url_ok,Url_nok) ->
    DT_Deb=pbutil:string_to_term(DateT_Deb),
    DT_Fin=pbutil:string_to_term(DateT_Fin),
    LT = local_time(),
    case (DT_Deb < LT) and (LT < DT_Fin) of
	true ->
	    {redirect,abs,Url_ok};
	false ->
	    {redirect,abs,Url_nok}
    end;
redirect_if_between_datetimes(Sess,DateT_Deb,DateT_Fin,Url_ok,Url_nok) 
  when tuple(DateT_Deb) ->
    LT = local_time(),
    case (DateT_Deb < LT) and (LT < DateT_Fin) of
	true ->
	    {redirect,Sess,Url_ok};
	false ->
	    {redirect,Sess,Url_nok}
    end;
redirect_if_between_datetimes(Sess,DateT_Deb,DateT_Fin,Url_ok,Url_nok) ->
    DT_Deb=pbutil:string_to_term(DateT_Deb),
    DT_Fin=pbutil:string_to_term(DateT_Fin),
    LT = local_time(),
    case (DT_Deb < LT) and (LT < DT_Fin) of
	true ->
	    {redirect,Sess,Url_ok};
	false ->
	    {redirect,Sess,Url_nok}
    end.

%% +deftype char()=string(). %% string of 1 character
%% +deftype symb()=char().   %% e.g. "+" , "=" 
%% +type str2tuplist(string(),symb(),symb()) -> [{string(),string()}].
%%% ex: str2tuplist("a1=b1;...;aN=bN",";","=") = [{a1,b1},...,{aN,bN}].
str2tuplist(Str,Op1,Op2) ->
    lists:map(fun (Elt) -> [S1,S2] = string:tokens(Elt,Op2), {S1,S2} end, 
	      string:tokens(Str, Op1)).


%% +type get_souscription(session())-> sub_of().
get_souscription(#session{prof=#profile{subscription=Sub}})->
    if list(Sub) ->            
            list_to_atom(Sub);
       true ->
            mobi
    end;
get_souscription(_) ->
    mobi.

%% +type dec_pcd_urls(pcd_urls()) -> [{Pcd::string(),url()}].
dec_pcd_urls(PCD_URLs) ->
    Z=string:tokens(PCD_URLs, ","),
    FL = fun (S) -> [PCD,URL] = string:tokens(S,"="), {PCD,URL} end,
    lists:map(FL, Z).


%% +type is_bank_holiday(session()|[{date_time(),date_time()}],
%%           atom()) -> bool().
is_bank_holiday(Opt) ->
    Bank_Date = get_env(list_bank_holidays),
    case lists:keysearch(Opt,1,Bank_Date) of
	{value, {Opt,Dates}}->
	    LT = local_time(),
	    A=lists:foldl(fun({Start,End},Acc)-> 
				  Acc or is_launched(Start,End,LT) end,
			  false,Dates),
	    slog:event(trace,?MODULE,{is_service_in_bank_holiday,Opt},A),
	    A;
	_->
	    slog:event(trace,?MODULE,{is_service_in_bank_holiday,Opt},false),
	    false
    end.


%% +type is_commercially_launched(session()|[{date_time(),date_time()}],
%%           atom()) -> bool().
is_commercially_launched(#session{}=Session, Opt) ->
    svc_option_manager:is_commercially_launched(Session,Opt);
is_commercially_launched(mobi, Opt) ->
    Comm_Date = get_env(commercial_date),
    is_commercially_launched(Comm_Date, Opt);
is_commercially_launched(Comm_Date, Opt) ->
    case lists:keysearch(Opt,1,Comm_Date) of
	{value, {Opt,Dates}}->
	    LT = local_time(),
	    A=lists:foldl(fun({Start,End},Acc)-> 
				  Acc or is_launched(Start,End,LT) end,
			  false,Dates),
	    slog:event(trace,?MODULE,{is_service_open,Opt},A),
	    A;
	_->
	    slog:event(trace,?MODULE,{is_service_open,Opt},false),
	    false
    end.

%% +type is_launched({date(),time()},{date(),time()}, {date(),time()})-> bool().
is_launched(Start,End,LT) ->
    ( Start < LT ) and ( LT < End ).

%% +type is_good_plage_horaire(atom()) -> bool().
is_good_plage_horaire(Opt)->
    case lists:keysearch(Opt,1,get_env(plage_horaire)) of
	false->
	    %% pas de plage horaire/ allways open
	    true;
	{value, {Opt,Plages}}->
	    {Date,Time} = erlang:localtime(),
	    lists:foldl(fun(Plage,Acc)->
				Acc or check_plage_dow(Time,Plage)
			end,false,Plages)
    end.

is_good_plage_horaire(Opt, Sub)->
    svc_option_manager:is_good_plage_horaire(Opt, Sub).

check_plage_dow(_, always, Open_Days) ->
    case Open_Days of
  	always->
  	    true;
  	_-> DOW = dow_atom(date()),
  	    true and lists:member(DOW,Open_Days)
    end;
check_plage_dow(Time, {_,_}=Plage,Open_Days) ->
    case Open_Days of
  	always->
  	    check_plage_horaire(Time,Plage) and true;
  	_->
  	    DOW = dow_atom(date()),
  	    check_plage_horaire(Time,Plage) and lists:member(DOW,Open_Days)
    end.
%% nhung: function check_plage_dow/2 will be removed after finishing option management
check_plage_dow(Time, {_,_}=Plage) ->
    check_plage_horaire(Time, Plage);
check_plage_dow(Time, {H1,H2,Days}) ->
    DOW = dow_atom(date()),
    check_plage_horaire(Time, {H1,H2}) and lists:member(DOW,Days).

dow_atom(Date) ->
    DOWint = calendar:day_of_the_week(Date),
    dow_int2atom(DOWint).

dow_atom2int(lundi)    -> 1;
dow_atom2int(mardi)    -> 2;
dow_atom2int(mercredi) -> 3;
dow_atom2int(jeudi)    -> 4;
dow_atom2int(vendredi) -> 5;
dow_atom2int(samedi)   -> 6;
dow_atom2int(dimanche) -> 7.

dow_int2atom(1) -> lundi;
dow_int2atom(2) -> mardi;
dow_int2atom(3) -> mercredi;
dow_int2atom(4) -> jeudi;
dow_int2atom(5) -> vendredi;
dow_int2atom(6) -> samedi;
dow_int2atom(7) -> dimanche.

mois_int2atom(1) -> janvier;
mois_int2atom(2) -> fevrier;
mois_int2atom(3) -> mars;
mois_int2atom(4) -> avril;
mois_int2atom(5) -> mai;
mois_int2atom(6) -> juin;
mois_int2atom(7) -> juillet;
mois_int2atom(8) -> aout;
mois_int2atom(9) -> septembre;
mois_int2atom(10) -> octobre;
mois_int2atom(11) -> novembre;
mois_int2atom(12) -> decembre.

%% +type redirect_to_url(session(),url()) -> erlpage_result().
redirect_to_url(abs, Url) ->
    [{redirect,abs,Url}];
redirect_to_url(Session, Url) ->
    {redirect,Session,Url}.

redirect_by_param(abs, Parameter) ->
    redirect_by_param(abs, pservices_orangef, Parameter);
redirect_by_param(Session, Parameter) ->
    redirect_by_param(Session, pservices_orangef, Parameter).

redirect_by_param(Session, Application, Parameter) 
  when list(Parameter)->
    redirect_by_param(Session, Application, list_to_atom(Parameter));
redirect_by_param(abs, Application, Parameter) ->
    Url = application:get_env(Application,Parameter),
    {redirect,abs,Url};
redirect_by_param(Session, Application, Parameter) 
  when atom(Application) ->
    case catch application:get_env(Application,Parameter) of
	{ok, Url} when list(Url)->
	    {redirect,Session,Url};
	Else ->
	    slog:event(internal, ?MODULE, redirect_by_param, [Application, Parameter]),
	    {redirect,Session,"#temporary"}
    end.

redirect_by_bool(abs, Bool, Url_True, Url_False)->
    [{redirect,abs,Url_True},
     {redirect,abs,Url_False}];
redirect_by_bool(Session, Bool, Url_True, Url_False)->
    case get_env(list_to_atom(Bool)) of
	true ->
	    {redirect,Session,Url_True};
	Other->
	    {redirect,Session,Url_False}
    end.	    


%% +deftype format()=string(). %% "dmy" | "dm" |"dmhm"
%% +type sprintf_datetime_by_format(datetime(),format()) -> string().
sprintf_datetime_by_format({{Y,M,D},{H,Mi,S}},FMT) ->
    case FMT of
	"dmyy" ->
	    pbutil:sprintf("%02d/%02d/%04d", [D,M,Y]);
	"dmhm" ->
						% displayed as DD/MM HH:MM
	    pbutil:sprintf("%02d/%02d %02d:%02d", [D,M,H,Mi]);
	"dmy" ->
	    pbutil:sprintf("%02d/%02d/%02d", [D,M,Y rem 100]);
	"dm" ->
	    pbutil:sprintf("%02d/%02d", [D,M]);
	"hm" ->
    	    pbutil:sprintf("%02d:%02d", [H,Mi])
    end.

print_last_day_of_the_month(abs,FMT) ->
    [{pcdata,"JJ/MM"}];
print_last_day_of_the_month(Session,FMT) ->
    {{Y,M,D},{H,Mi,S}} = local_time(),
    Date_Time = {{Y,M,calendar:last_day_of_the_month(Y,M)},{H,Mi,S}},    
    S_DateTime=sprintf_datetime_by_format(Date_Time,FMT),  
    [{pcdata,lists:flatten(S_DateTime)}].

%% +type print_today_datetime(session(),format()) -> string().
%%% Dispaly date in format DD/MM HH:MnMn
print_today_datetime(abs,FMT) ->
    [{pcdata,"JJ/MM HH:MM"}];
print_today_datetime(Session,FMT) ->
    Date_Time = local_time(),
    S_DateTime=sprintf_datetime_by_format(Date_Time,FMT),  
    [{pcdata,lists:flatten(S_DateTime)}].


%% +type print_next_week_date(session(),string())-> [{pcdata,string()}].
print_next_week_date(Session,Day)->
    Now=pbutil:unixtime(),
    ToDay=calendar:day_of_the_week(date()),
    N_Day=day_of_the_week(Day),
    Unix=
	case ToDay =< 5 of
	    true ->
		case ToDay=<N_Day of
		    true ->
			Now+(N_Day-ToDay)*24*60*60;
		    _ ->
			Now+(7-(ToDay-N_Day))*24*60*60
		end;
	    _ ->
		Now+(7-(ToDay-N_Day))*24*60*60
	end,
    Date_Time = 
        calendar:now_to_local_time({Unix div 1000000, 
                                    Unix rem 1000000,0}),
    S_Date=sprintf_datetime_by_format(Date_Time,"dm"),  
    [{pcdata,lists:flatten(S_Date)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type today_plus_datetime(X::integer()) ->
%%                           {Year::integer(),Month::integer,Day::integer()}.
%%%% Add X days to current datetime and return the date.

today_plus_datetime(X) when integer(X)->
    DateTime = local_time(),
    {Date,_} = add_seconds_to_datetime(DateTime,X*86400),
    Date.

%% +type next_week_date(string())-> date().
%%% the next date of the day(lundi, mardi) in param.
next_week_date(Day)->
    Now=pbutil:unixtime(),
    ToDay=calendar:day_of_the_week(date()),
    N_Day=day_of_the_week(Day),
    Unix=
        case ToDay<N_Day of
            true->
                Now+(N_Day-ToDay)*24*60*60;
            false->
                Now+(7-(ToDay-N_Day))*24*60*60
        end,
    calendar:now_to_local_time({Unix div 1000000, 
                                Unix rem 1000000,0}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type next_monday_date() -> date().
%%%% Date defined to next monday.

next_monday_date() ->
    {Date,Time} = local_time(),
    DayOWeek = calendar:day_of_the_week(Date),
    IsItSundayAfter23h = ( Time > {23,0,0} ) and (DayOWeek==7),
    DiffToNextMondaySecs =
        (case IsItSundayAfter23h of
             false -> 
                 (8 - DayOWeek)*86400;
             true  ->
                 (8 - DayOWeek + 7)*86400
         end),
    {NextMondayDate,_} =
        svc_util_of:add_seconds_to_datetime({Date,{12,0,0}},
                                            DiffToNextMondaySecs),
    NextMondayDate.

next_Saturday_date()->
    {Date, Time} = local_time(),
    DayOfWeek = calendar:day_of_the_week(Date),
    if DayOfWeek == 6->
	    Date;
       DayOfWeek == 7 ->
	    {Date1, Time1} = add_seconds_to_datetime({Date,Time}, -1*86400),
	    Date1;
       true->
	    {Date2, Time2} = add_seconds_to_datetime({Date, Time}, (6-DayOfWeek)*86400),
	    Date2
    end.
next_Sunday_date()->
    SaturdayDate = next_Saturday_date(),
    {SundayDate, SundayTime} = add_seconds_to_datetime({SaturdayDate,{0,0,0}},86400),
    SundayDate.

%% +type day_of_the_week(string())-> integer().
day_of_the_week("lundi")->
    1;
day_of_the_week("mardi") ->
    2;
day_of_the_week("mercredi") ->
    3;
day_of_the_week("jeudi") ->
    4;
day_of_the_week("vendredi") ->
    5;
day_of_the_week("samedi") ->
    6;
day_of_the_week("dimanche") ->
    7;
day_of_the_week("friday") ->
    5;
day_of_the_week("sunday") ->
    7.

%% +type print_d_activ_plus_days(session(),Days::string(),
%%                               Format::string())-> integer().
print_d_activ_plus_days(abs, _, _) ->
    [{pcdata,"XXX"}];
print_d_activ_plus_days(Session, Days, Format) ->
    DaysI = list_to_integer(Days),
    State = get_user_state(Session),
    Now = pbutil:unixtime(),
    D_Activ = State#sdp_user_state.d_activ,
    NewDate = svc_util_of:unixtime_to_local_time(D_Activ + DaysI*86400),
    Date=svc_util_of:sprintf_datetime_by_format(NewDate, Format),
    [{pcdata, lists:flatten(Date)}].

%% +deftype interval_dt()={Start::datetime(),End::datetime()}. %%with condition
%%%% Start<End
%% +type find_interv_of_localtime([interval_dt()]) -> 
%%  no_interv | {interv,interval_dt()}.
find_interv_of_localtime(Intervs) ->
    find_interv_of_datetime(local_time(),Intervs).

%% +type find_interv_of_datetime(datetime(),[interval_dt()]) ->
%%  no_interv | {interv,interval_dt()}.
find_interv_of_datetime(_,[]) -> no_interv;
find_interv_of_datetime(DT,[{Start,End}=Interv|T]) ->

    case (Start<DT) and (DT<End) of
	true ->
	    {interv,Interv};
	false ->
	    find_interv_of_datetime(DT,T)
    end.

%% +type redir_techno(session(), [tech_seg_code()], string(), string())
%%  -> erlpage_result().
%%%% Redirects to URLYes if the client's technological segment is one
%%%% of those in TSCs, to URLNo otherwise.
redir_techno(abs, TSCs, URLYes, URLNo) ->
    [{redirect, abs, URLYes}, {redirect, abs, URLNo}];
redir_techno(Session, TSCs, URLYes, URLNo) ->
    Session1 = update_tech_seg_int_if_needed(Session),
    TSI = get_tech_seg_int(Session1),
    Code = ocf_rdp:tech_seg_int_to_code(TSI),
    case lists:any(fun (X) -> X == Code end, TSCs) of
	true  -> {redirect, Session1, URLYes};
	false -> {redirect, Session1, URLNo}
    end.

%% +type redir_2g(session(), string(), string()) -> erlpage_result().
redir_2g(Session, URLYes, URLNo) ->
    L = [ocf_rdp:tech_seg_int_to_code(?OCF_NOT_QUERIED_YET),
	 ocf_rdp:tech_seg_int_to_code(?OCF_QUERY_FAILED),
	 ocf_rdp:tech_seg_int_to_code(?OCF_DOES_NOT_KNOW),
	 ocf_rdp:tech_seg_int_to_code(?OCF_NO_FIELD),
	 ocf_rdp:tech_seg_int_to_code(?OCF_UNKNOWN_CODE)],
    redir_techno(Session, L, URLYes, URLNo).

%% +type redir_3g(session(), string(), string()) -> erlpage_result().
redir_3g(Session, URLYes, URLNo) ->
    redir_techno(Session, ["TRM3G", "UMTS1"], URLYes, URLNo).

%% +type update_tech_seg_int_if_needed(session()) -> session().
update_tech_seg_int_if_needed(Session) ->
    case get_tech_seg_int(Session) of
	undefined -> update_tech_seg_int(Session);
	_         -> Session
    end.

%% +type update_tech_seg_int(session()) -> session().
update_tech_seg_int(Session) ->
    Prof = Session#session.prof,
    UID = Prof#profile.uid,
    TSI = query_tech_seg_by_uid(UID),
    set_tech_seg_int(Session, TSI).

%% +type get_tech_seg_int(session()) -> undefined | tech_seg_int().
get_tech_seg_int(Session) ->
    get_tech_seg_int_profile(Session#session.prof).

%% +type get_tech_seg_int_profile(profile()) -> undefined | tech_seg_int().
get_tech_seg_int_profile(Prof) ->
    Prefs = Prof#profile.prefs,
    case lists:keysearch(tech_seg_int, 1, Prefs) of
	false                        -> undefined;
	{value, {tech_seg_int, TSI}} -> TSI
    end.

%% +type set_tech_seg_code(session(), tech_seg_code()) -> session().
set_tech_seg_code(#session{} = Session, TSC) ->
    Prof = Session#session.prof,
    case ocf_rdp:tech_seg_code_to_int(TSC) of
	not_found ->
	    slog:event(internal, ?MODULE,
		       {set_tech_seg_code, unknown_tech_seg_code, TSC}),
	    exit({set_tech_seg_code, unknown_tech_seg_code});
	TSI ->
	    Prof1 = set_tech_seg_int_profile(Prof, TSI),
	    Session#session{prof = Prof1}
    end.

%% +type set_tech_seg_int(session(), tech_seg_int()) -> session().
set_tech_seg_int(#session{} = Session, TSI) ->
    Prof = Session#session.prof,
    Prof1 = set_tech_seg_int_profile(Prof, TSI),
    Session#session{prof = Prof1}.

%% +type set_tech_seg_int_profile(profile(), tech_seg_int()) -> session().
set_tech_seg_int_profile(#profile{} = Prof, TSI) ->
    Prefs = Prof#profile.prefs,
    Prefs1 =
	case lists:keysearch(tech_seg_int, 1, Prefs) of
	    false ->
		[{tech_seg_int, TSI} | Prefs];
	    {value, _} ->
		lists:keyreplace(tech_seg_int, 1, Prefs, {tech_seg_int, TSI})
	end,
    Prof#profile{prefs = Prefs1}.

%% +type query_tech_seg_by_uid(uid()) -> tech_seg_int().
query_tech_seg_by_uid(Uid) ->
    Query = io_lib:format("SELECT tech_segment FROM users_orangef_extra "
			  "WHERE uid = ~p",
			  [Uid]),
    Ident = {uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
    Route = localisation_hash:build_route([Default_Route], Ident),
    case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
	{selected, _, [[TSI]]} ->
	    slog:event(count, ?MODULE, user_found_in_OF_db, Ident),
	    list_to_integer(TSI);
	{selected, _, []} ->
	    slog:event(count, ?MODULE, user_not_in_OF_db, Ident),
	    ?OCF_NOT_QUERIED_YET;
	{selected, _, [[TSI] | _]} -> % should be impossible (uid is a key)
	    slog:event(internal, ?MODULE, several_rows_in_OF_db, Ident),
	    list_to_integer(TSI);
	X ->
	    slog:event(internal, ?MODULE, unexpected_res_OF_db,
		       {ident, {unexpected, X}}),
	    ?OCF_NOT_QUERIED_YET
    end.

%% +type query_tech_seg_by_uid(uid()) -> tech_seg_int().
query_commercial_segment_by_uid(Uid) ->
    Query = io_lib:format("SELECT commercial_segment FROM users_orangef_extra "
			  "WHERE uid = ~p",
			  [Uid]),
    Ident = {uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
    Route = localisation_hash:build_route([Default_Route], Ident),
    case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
	{selected, _, [[Seg_com]]} ->
	    slog:event(count, ?MODULE, commercial_segment_found_in_OF_db, Ident),
	    {ok, Seg_com};
	{selected, _, []} ->
	    slog:event(count, ?MODULE, commercial_segment_not_in_OF_db, Ident),
	    undefined;
	X ->
	    slog:event(internal, ?MODULE, unexpected_commercial_segment_OF_db,
		       {Ident, {unexpected, X}}),
	    undefined
    end.

%% +type insert_extra_profile(profile()) -> ok.
%%%% Inserts the OF extra information found in the profile into the OF
%%%% extra user information table. The profile must contain a valid uid.
insert_extra_profile(Prof) ->
    Uid = Prof#profile.uid,
    TSI =
	case get_tech_seg_int_profile(Prof) of
	    undefined ->
		slog:event(internal, ?MODULE,
			   {insert_extra_profile, no_tech_seg}, {uid, Uid});
	    TSI_ ->
		TSI_
	end,
    insert_extra(Uid, TSI).

%% +type insert_extra(uid(), tech_seg_int()) -> ok.
%%%% TODO create a record containing all the specific OF information to be
%%%% stored in users_orangef_extra table.
insert_extra(Uid, TSI) ->
    Query = io_lib:format("INSERT INTO users_orangef_extra (uid,tech_segment) "
			  "VALUES (~p, ~p)", [Uid, TSI]),
    Ident = {uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
    Route = localisation_hash:build_route([Default_Route], Ident),
    case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
	{updated, 1} ->
	    slog:count(count, ?MODULE, extra_info_inserted_in_db),
	    ok;
	X ->
	    slog:event(failure, ?MODULE, unable_to_insert_extra_info,
		       {Ident, {unexpected, X}}),
	    exit({bad_response_from_db, X})
    end.

%% +type update_extra_profile(profile()) -> ok.
%%%% Updates the OF extra information found in the profile into the OF
%%%% extra user information table. The profile must contain a valid uid
%%%% and the technological segment must be defined.
update_extra_profile(Prof) ->
    Uid = Prof#profile.uid,
    TSI =
	case get_tech_seg_int_profile(Prof) of
	    undefined ->
		slog:event(internal, ?MODULE,
			   {update_extra_profile, no_tech_seg}, {uid, Uid}),
		exit(no_tech_seg_in_profile);
	    TSI_ ->
		TSI_
	end,
    update_extra(Uid, TSI).

%% +type update_extra(uid(), tech_seg_int()) -> ok.
%%%% TODO create a record containing all the specific OF information to be
%%%% stored in users_orangef_extra table.
update_extra(Uid, TSI) ->

    case query_tech_seg_by_uid(Uid) of
        TSI -> ok; %% already up to date
        _ ->
            Query = io_lib:format("UPDATE users_orangef_extra SET tech_segment = '~p' "
                                  "WHERE uid = '~p'", [TSI, Uid]),
            Ident = {uid,Uid},
            Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
            Route = localisation_hash:build_route([Default_Route], Ident),
            case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
                {updated, 1}->
                    slog:count(count, ?MODULE, extra_info_updated_in_db),
                    ok;
                {updated, 0}->
                    %% no update has been made(same value in base) or no client
                    exit(no_update);
                X ->
                    slog:event(count, ?MODULE, unable_to_update_extra_info,
                               {{uid, Uid}, {unexpected, X}}),
                    exit({bad_response_from_db, X})
            end
    end.

update_extra_commercial(Uid, SegCom) ->
    Query = io_lib:format("UPDATE users_orangef_extra SET commercial_segment = '~p' "
			  "WHERE uid = '~p'", [SegCom, Uid]),
    Ident = {uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
    Route = localisation_hash:build_route([Default_Route], Ident),
    case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
	{updated, 1} ->
	    slog:event(trace, ?MODULE, extra_info_updated_in_db),
	    slog:count(count, ?MODULE, extra_info_updated_in_db),
	    ok;
	{updated, 0}->
	    %% no update has been made(same value in base) or no client
	    slog:event(trace, ?MODULE, extra_info_no_update),
	    exit(no_update);
	X ->
	    slog:event(count, ?MODULE, unable_to_update_extra_info,
		       {Ident, {unexpected, X}}),
	    exit({bad_response_from_db, X})
    end.

insert_extra_commercial(Uid, SegCom) ->
    Query = io_lib:format("INSERT INTO users_orangef_extra (uid,commercial_segment) "
			   "VALUES (~p, ~p)", [Uid, SegCom]),
    Ident = {uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
    Route = localisation_hash:build_route([Default_Route], Ident),
    case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
	{updated, 1} ->
	    slog:event(trace, ?MODULE, extra_info_insert_in_db),
	    slog:count(count, ?MODULE, extra_info_updated_in_db),
	    ok;
	X ->
	    slog:event(trace, ?MODULE, bad_response_from_db),
	    slog:event(failure, ?MODULE, unable_to_insert_extra_info,
		       {Ident, {unexpected, X}}),
	    exit({bad_response_from_db, X})
    end.    

%% +type redir_declinaison(session(), Links::string()) -> erlpage_result().
%%%% Redirects depending on #sdp_user_state.declinaison.
%%%% Links must be "decl1=link1,decl2=link2,...,default=linkdefault".
%%%% Unknown declinaison are redirected to the default link.

redir_declinaison(abs, Links) ->
    svc_util:redirect_multi(abs, abs, Links);
redir_declinaison(Session, Links) ->
    State = get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,    
    if integer(DCL) ->
	    svc_util:redirect_multi(Session, integer_to_list(DCL), Links);
       true ->
	    slog:event(warning, ?MODULE, unknown_dcl, Session),
	    Links_list = string:tokens(Links, ","),
	    Last_rule = lists:last(Links_list),
	    [Last_page_title, Last_link] = string:tokens(Last_rule, "="),
	    case Last_page_title of 
		default ->
		    {redirect, Session, Last_link};
		_ ->
		    slog:event(warning, ?MODULE, expected_default_link, Links),
		    {redirect, Session, Last_link}
	    end
    end.

%% +type redirect_if_declinaison(session(), string(), url(), url()) -> erlpage_result().
%%%% Redirect to URL_decl if the current declinaison is Declinaison
%%%% Otherwise, redirects to URL_other

redirect_if_declinaison(abs, Declinaison, URL_decl, URL_other)->   
    [{redirect, abs, URL_decl}, {redirect, abs, URL_other}];
redirect_if_declinaison(Session, Declinaison, URL_decl, URL_other)->
    State = get_user_state(Session),
    case declinaison(State) of
	Declinaison ->
	    {redirect, Session, URL_decl};
	Else ->
	    {redirect, Session, URL_other}
    end.


%% +type redirect_etat_cpte(session(), Cpte::string(), Links::string()) ->
%%         erlpage_result().
%%%% fonction permettant de redirriger en fonction de l'etat d'un compte
redirect_etat_cpte(abs, Cpte,Links) ->
    Links1 = string:tokens(Links, ","), 
    FL = fun (S) -> [K,Link] = string:tokens(S,"="), {redirect,abs,Link} end,
    lists:map(FL, Links1);
redirect_etat_cpte(Session, Cpte, Links)->
    %% ac=URL1,ep=URL2,pe=URL3,default=URL4
    Links1 = string:tokens(Links, ","),
    FL = fun (S) -> [K,Link] = string:tokens(S,"="), 
		    case K of
			"default"-> {default,Link};
			"ac"-> {actif,Link};
			"ep"-> {epuise,Link};
			"pe" -> {perime,Link}
		    end 
	 end,
    Links2 = lists:map(FL,Links1),
    case svc_compte:etat_cpte(get_user_state(Session),list_to_atom(Cpte)) of
	?CETAT_AC->
	    {redirect,Session,get_url(actif,Links2)};
	?CETAT_EP->
	    {redirect,Session,get_url(epuise,Links2)};
	?CETAT_PE->
	    {redirect,Session,get_url(perime,Links2)};
	_ ->
	    {redirect,Session,get_url(default,Links2)}
    end.

%% +type redirect_etat_cpte_second(session(), Links::string()) ->
%%         erlpage_result().
%%%% fonction permettant de redirriger en fonction de l'etat d'un compte
is_identify(Session)->
    State=get_user_state(Session),
    case State#sdp_user_state.etats_sec of
	ET when ET band ?SETAT_ID==?SETAT_ID ->
	    true;
	_ ->
	    false
    end.

%% Verify recharge autorization by 'etat secondaire'
is_recharge_autorized(State) ->
    Etat_sec = State#sdp_user_state.etats_sec,
    DCL = State#sdp_user_state.declinaison,    
    case DCL of
	?mobi_janus ->
	    case Etat_sec of
		X when X band ?SETAT_ID==?SETAT_ID ->
		    true;
		_ ->
		    case Etat_sec of
			Y when Y band ?SETAT_LS == ?SETAT_LS ->
			    false;
			_  ->
			    true
		    end
	    end;
	_  ->
	    true
    end.

redirect_etat_cpte_second(abs, Links) ->
    Links1 = string:tokens(Links, ","), 
    FL = fun (S) -> [K,Link] = string:tokens(S,"="), {redirect,abs,Link} end,
    lists:map(FL, Links1);
redirect_etat_cpte_second(Session, Links)->
    %% ident=URL1,default=URL2
    Links1 = string:tokens(Links, ","),
    FL = fun (S) -> [K,Link] = string:tokens(S,"="), 
		    case K of
			"default"-> {default,Link};
			"ident"-> {identified,Link}
		    end 
	 end,
    Links2 = lists:map(FL,Links1),
    case is_identify(Session) of 
	true  -> {redirect,Session,get_url(identified,Links2)};
	false -> {redirect,Session,get_url(default,Links2)}
    end.
%%     State=get_user_state(Session),
%%     case State#sdp_user_state.etats_sec of
%% 	ET when ET band ?SETAT_ID==?SETAT_ID ->
%% 	    {redirect,Session,get_url(identified,Links2)};
%% 	_ ->
%% 	    {redirect,Session,get_url(default,Links2)}
%%     end.	  

%% +type get_url(atom(),[{atom(),URL::string()}])-> Url::string().
get_url(Value,List)->
    case lists:keysearch(Value,1,List) of
	{value, {_,URL}} -> URL;
	false  -> 
	    case lists:keysearch(default,1,List) of
		{value, {_,URL}} -> URL;
		false -> 
		    slog:event(internal,?MODULE,no_default_url),
		    ""
	    end
    end.

%%%% Fonction Permettant la manipulation du svc_data dans le cas du #123#

%%%% Use associative lists for user states: sdp_user_state, 
%%%% and postpaid_user_state
%% +type get_user_state(session())-> record(). 
get_user_state(#session{svc_data=US,prof=Prof}=S) when list(US)->
    case variable:get_value(S,user_state) of
	not_found->
	    Msisdn = Prof#profile.msisdn,
	    slog:event(warning,?MODULE,user_state_not_found,{Msisdn,US}),
	    US= init_svc_data(S),
	    NewSess = update_user_state(S, US),
	    variable:get_value(NewSess,user_state);
	Value-> 
	    Value
    end;
get_user_state(Session)->
    US= init_svc_data(Session),
    NewSess = update_user_state(Session, US),
    variable:get_value(NewSess,user_state).

get_user_state_simple(#session{svc_data=US,prof=Prof}=S) when list(US)->
    case variable:get_value(S,user_state) of
	not_found->
	    Msisdn = Prof#profile.msisdn,
	    slog:event(trace,?MODULE,user_state_not_found,{Msisdn,US}),
	    not_found;
	Value-> 
	    Value
    end.

%% +type update_user_state(session(), record()) -> session().
update_user_state(#session{svc_data=L}=Session, Record) when list(L) ->
    variable:update_value(Session, user_state, Record);
update_user_state(Session, Other) ->
    Session#session{svc_data=Other}.

get_nb_subs_ocf_failed(#session{prof=#profile{anon=true}}) ->
    -1;
get_nb_subs_ocf_failed(#session{prof=#profile{uid=Uid}}=Session) -> 
    case variable:get_value(Session, nb_subs_ocf_failed) of 
        not_found -> 
            Query = io_lib:format("SELECT nb_subs_ocf_failed FROM users_orangef_extra "
			  "WHERE uid = ~p",
			  [Uid]),
            Ident = {uid,Uid},
            Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
            Route = localisation_hash:build_route([Default_Route], Ident),
            case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
                {selected, _, [[Nb_subs_ocf_failed]]} ->
                    slog:event(count, ?MODULE, nb_subs_ocf_failed_found_in_OF_db, {uid, Uid, Nb_subs_ocf_failed}),
                    list_to_integer(Nb_subs_ocf_failed);
                {selected, _, []} ->
                    slog:event(count, ?MODULE, nb_subs_ocf_failed_not_in_OF_db, {uid, Uid}),
                    undefined;
                X ->
                    slog:event(internal, ?MODULE, unexpected_nb_subs_ocf_failed_in_OF_db,
                               {{uid, Uid}, {unexpected, X}}),
                    undefined
            end;
        Value -> 
            list_to_integer(Value)
    end.

update_nb_subs_ocf_failed(#session{prof=#profile{uid=Uid}}=Session, NbSubsOcfFailed) -> 
    Query = io_lib:format("UPDATE users_orangef_extra SET nb_subs_ocf_failed = '~p' "
			  "WHERE uid = '~p'", [NbSubsOcfFailed, Uid]),
    Ident = {uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef,users_orangef_extra_routing),
    Route = localisation_hash:build_route([Default_Route], Ident),
    case ?SQL_Module:execute_stmt(Query,Route,?SQL_SELECT_TIMEOUT) of
	{updated, _} ->
	    slog:event(trace, ?MODULE, nb_subs_ocf_failed_updated_in_db, NbSubsOcfFailed),
            variable:update_value(Session, nb_subs_ocf_failed, NbSubsOcfFailed);
	X ->
	    slog:event(count, ?MODULE, unable_to_update_nb_subs_ocf_failed,
		       {{uid, Uid}, {unexpected, X}}),
	    exit({bad_response_from_db, X})
    end.



%%%% effectue une mise a jour des informations renvoye par Sachem, DME
%%%% ne supprime pas les autres Champs
%% +type reinit_compte(session())-> {ok,session()} | {nok,session()}.
reinit_compte(#session{prof=#profile{subscription=S}}=Session)
  when S=="mobi" ; S=="cmo";S=="omer";S=="virgin_prepaid";
       S=="virgin_comptebloque" ->
    reinit_prepaid(Session);
reinit_compte(#session{prof=#profile{subscription=S}}=Session) ->
    pbutil:autograph_label(no_read_info),
    slog:event(trace, ?MODULE, {reinit_state, no_prepraid}, S),
    Session.


%% +type consultation_sachem(session(), url(), url()) -> erlpage_result().
consultation_sachem(abs, UrlOK, UrlNOK) ->
    [{redirect, abs, UrlOK}, {redirect, abs, UrlNOK}];
consultation_sachem(Session, UrlOK, UrlNOK) ->
    State = get_user_state(Session),
    case State of
	#sdp_user_state{dos_numid=undefined} ->
	    do_consultation_sachem(Session, State, UrlOK, UrlNOK);
	#sdp_user_state{} ->
	    {redirect, Session, UrlOK};
	_ ->
	    do_consultation_sachem(Session, State, UrlOK, UrlNOK)
    end.

%% +type do_consultation_sachem(session(), sdp_user_state(), url(), url()) ->
%%  erlpage_result().
do_consultation_sachem(Session, State, UrlOK, UrlNOK) ->
    case reinit_prepaid(Session, State) of
	{ok, Session2} ->
	    {redirect, Session2, UrlOK};
	_ ->
	    {redirect, Session, UrlNOK}
    end.

get_top_num_list(Session, Zone70) ->
    svc_sachem:get_top_num_list(Zone70).


%% +type get_options_list(session()) -> list().
%%%% Instead of calling MAJ_OP, we call CSL_DOSCP
%%%% to get the list of options related to the account
get_options_list(#session{prof=Profile}=Session, Id) ->
    Msisdn = Profile#profile.msisdn,
    case svc_sachem:consult_options_list(Session) of
        {UpdatedSession, Top_num_list}  when list(Top_num_list) ->
            {options, Top_num_list, UpdatedSession};
        Else ->
            slog:event(internal, ?MODULE, unexpected_options, 
		       {Msisdn, Else}),
            []                    
    end.    


%% +type consult_account_options(session(), Id, Top_num)
%%                    list().
%%%% Send consult_account_options (CSL_OP) (Soap_tuxedo)
%%%% For both interfaces, it returns the list of :
%%%% [Opt_date_souscr, Opt_date_deb_valid, Opt_date_fin_valid,
%%%%  Opt_info1, Opt_info2] or Error
consult_account_options(Session, Id, Top_num) ->
    case is_list(Top_num) of 
        true ->
            Top_num_LIST=Top_num;
        _ ->
            Top_num_LIST=integer_to_list(Top_num)
    end,
    case svc_sachem:consult_option_info(Session, Top_num) of
        {UpdatedSession,[_, Opt_date_souscr, Opt_date_deb_valid,
			 Opt_date_fin_valid, Opt_info1, Opt_info2|_]} ->
%%%% returns same 5 elements of c_op X25
            {ok, [Opt_date_souscr,
		  Opt_date_deb_valid,
		  Opt_date_fin_valid,
		  Opt_info1,
		  Opt_info2]};

        Error ->
            slog:event(failure,?MODULE,consult_account_options,
		       {Top_num, Error}),
            Error
    end.

%% +type consult_account_options(session(), Id, tuple(), Top_num)
%%                    {ok, list()}.
%%%% Send consult_account_options (CSL_OP) (Soap_tuxedo)
%%%% For both interfaces, it returns the same output
consult_account_options(Session, Id,
			Criteria_type, 
			Criteria_value, Top_num) ->
    case svc_sachem:consult_account_options(Session) of
        {ok, {Session_updated, Resp_params}} ->
            Options_info = svc_sachem:get_options_info(Resp_params),
            MSISDNs_info = svc_sachem:get_msisdns_info(Resp_params),
            OPTs_TG_info = svc_sachem:get_options_tg_info(Resp_params),
            case Top_num of
                "NULL" ->
                    {ok, [format_options(Options_info), MSISDNs_info, OPTs_TG_info]};
                _ ->
                    Option_info = svc_sachem:get_option_info(Top_num, Options_info),
                    {ok, [format_options([Option_info]), MSISDNs_info, OPTs_TG_info]}
            end;
        {nok, Reason} ->
            slog:event(warning, ?MODULE, consult_account_options, 
		       {Id, Criteria_type, Criteria_value,
			Top_num,Reason}),
            {nok, Reason}                    
    end.

format_options([])->
    [];
format_options([[]]) ->
    [[]];
format_options(Lists) ->
    format_options(Lists, []).

format_options([], Acc) ->
    Acc;
format_options([List|Tail], Acc) ->
    case List of
        [Top_num, Date_souscr, Date_deb_valid, Date_fin_valid, Opt_info1, Opt_info2, 
         Tcp_num, Ptf_num, Rnv_num, Cpp_cumul_credit] ->
            List_updated = [svc_sachem:format_to_int(Top_num),
                            svc_sachem:format_to_int(Date_souscr), 
                            svc_sachem:format_to_int(Date_deb_valid), 
                            svc_sachem:format_to_int(Date_fin_valid), 
                            Opt_info1, Opt_info2, 
                            svc_sachem:format_to_int(Tcp_num), 
                            svc_sachem:format_to_int(Ptf_num), 
                            svc_sachem:format_to_int(Rnv_num), 
                            svc_sachem:format_to_int(Cpp_cumul_credit)],
            format_options(Tail, Acc++[List_updated] );
        _ ->
            slog:event(internal, ?MODULE, format_options, List),
            format_options(Tail, Acc++[List] )
    end.            

%% +type change_user_account(session(), Id, compte())
%%                    {ok, _}| {nok, string()}
%%%% Send change_user_account (MOD_CP) (Soap_tuxedo)
change_user_account(Session, {Subscription, Msisdn}, #compte{}=Compte)  ->
    Answer = svc_sachem:change_user_account(Session,Compte),
    case Answer of 
        {ok, _} ->
            Answer;
        Status when Status=={status, [10, 2]};
                    Status=={nok, "solde_insuffisant"} -> 
            {nok, "solde_insuffisant"};
        Status when Status=={status, [10, 3]};
                    Status=={nok, "chg_etat_cpte_impossible"} -> 
            {nok, "chg_etat_cpte_impossible"};
        {status, Status_code} ->
            slog:event(failure, ?MODULE, change_user_account, {status, Status_code}),
            {nok, "other_error"};
        {nok, Status} ->
            {nok, Status}
    end.


%% +type reinit_prepaid(session())-> session().
reinit_prepaid(Session) ->
    State = get_user_state(Session),
    reinit_prepaid(Session, State).

%% +type reinit_prepaid(session(), sdp_user_state())-> session().
reinit_prepaid(#session{prof=Profile}=Session, State) ->
    Identity = case {Profile#profile.msisdn, Profile#profile.imsi} of
		   {{na,_}, {na,_}} ->
		       %% This will cause the SDP request to fail
		       {na,imsi_msisdn_empty};
		   {MSISDN, {na, _}} -> {msisdn, MSISDN};
		   {_, IMSI} -> {imsi,IMSI}
	       end,
    case consult_account_state(Session,
                               list_to_atom(Profile#profile.subscription),
                               Identity,State) of
        {ok, Msisdn, State2} ->
            Session_account = update_user_state(Session,State2),
            case svc_sachem:consult_account_options(Session_account) of
                {ok, {Session_options,Resp_params}} ->
                    US = svc_util_of:get_user_state(Session_options),
                    Bill1_ =  case Session_options#session.bill of
                                  undefined -> #bill{};
                                  TempBill_ -> TempBill_
                              end,
                    Session_bill = Session_options#session{bill=Bill1_#bill{spec_data=US}},
                    {ok, Session_bill};
                Error_csl_op ->
                    slog:event(warning, ?MODULE, reinit_prepaid_csl_op, Error_csl_op),
                    {nok,Session}
            end;

 	Error ->
            slog:event(warning, ?MODULE, reinit_prepaid,Error),
 	    {nok,Session}
    end.	    

%% +type consult_account_state(session(), ) ->
%%                         {ok|nok, msisdn(), sdp_user_state()} 
consult_account_state(#session{prof=Prof}=Session, Subscription, Identity, State) ->
    case svc_sachem:update_sachem_user_state(Session) of
        {ok, State_updated} ->
            Msisdn = Prof#profile.msisdn,                
            {ok, Msisdn, State_updated};
        {nok, _} ->
            {nok, State}
    end.

%% +type is_plug(sdp_user_state()) -> bool().
is_plug(#sdp_user_state{declinaison=D})
  when D==?ppol2; D==?pmu ->
    true;
is_plug(#sdp_user_state{cpte_princ=#compte{ptf_num=Ptf}})
  when Ptf==?PLUGV3;Ptf==?PLUG_NOEL;Ptf==?PLUGV3_SEC;Ptf==?MADRID2->
    true;
is_plug(_) ->
    false.

%% +type is_zap(sdp_user_state()) -> bool().
is_zap(#sdp_user_state{declinaison=D})
  when D==?ppol2; D==?zap_cmo ->
    true;
is_zap(#sdp_user_state{cpte_princ=#compte{ptf_num=Ptf}})
  when Ptf==?MOBI_ZAP;Ptf==?MOBI_ZAP_PROMO->
    true;
is_zap(_) ->
    false.
%% +type godet_principal(integer())-> atom().
godet_principal(DCL) when DCL==?mobi;
			  DCL==?cpdeg;
			  DCL==?ppola->
    cpte_princ;
godet_principal(DCL) when DCL==?ppol1;
			  DCL==?ppol3;
			  DCL==?ppol4 ->
    cpte_forf;
godet_principal(?ppol2) ->
    cpte_voix;
godet_principal(?zap_cmo) ->
    cpte_voix;
godet_principal(?ppolc) ->
    forf_hc;
godet_principal(?pmu) ->
    forf_pmu;
godet_principal(DCL) when DCL==?fmu_18;
			  DCL==?fmu_24 ->
    forf_fmu;
godet_principal(?cmo_sl) ->
    forf_cmosl;
godet_principal(DCL) when DCL==?m6_cmo;DCL==?m6_cmo2;
			  DCL==?m6_cmo3;DCL==?m6_cmo4 ->
    forf_mu_m6;
godet_principal(DCL) when DCL==?m6_cmo_1h;DCL==?m6_cmo_1h20;DCL==?m6_cmo_20h_8h;
			  DCL==?m6_cmo_1h40;DCL==?m6_cmo_2h;DCL==?m6_cmo_3h;DCL==?rsa_cmo ->
    forf_m6_mob;
godet_principal(X) when X==?bzh_cmo;X==?bzh_cmo2->
    forf_bzh;
godet_principal(DCL) when DCL==?m6_cmo_1h_v3;DCL==?m6_cmo_1h30_v3;DCL==?sl_blackberry_1h;
			  DCL==?m6_cmo_2h_v3;DCL==?m6_orange_fixe_1h;DCL==?m6_cmo_ete ->
    cpte_princ;
godet_principal(DCL) when DCL==?big_cmo;DCL==?mobi_new;DCL==?m6_prepaid;
			  DCL==?ASSE_mobile;DCL==?OL_mobile;DCL==?OM_mobile;
			  DCL==?PSG_mobile;DCL==?BORDEAUX_mobile;DCL==?zap_cmo_18E;
			  DCL==?zap_cmo_20E;DCL==?zap_cmo_25E;DCL==?m6_cmo_1h_v2;
			  DCL==?m6_cmo_2h_v2;DCL==?B_phone;DCL==?m6_cmo_1h_sl;
			  DCL==?umobile;DCL==?zap_cmo_1h_v2->
    cpte_princ;
godet_principal(DCL) ->
    slog:event(warning,?MODULE,godet_principal_default,DCL),
    cpte_princ.

%% +type redirect_plug(session(), URL_PLUG::string(),URL_NOT_PLUG::string()) ->
%%         erlpage_result().
redirect_plug(abs, URL_PLUG,URL_NOT_PLUG) ->
    [{redirect,abs,URL_PLUG},
     {redirect,abs,URL_NOT_PLUG}];
redirect_plug(#session{svc_data=State}=Session,URL_Plug,URL_Not_Plug)->
    case is_plug(State) of
	true->
	    {redirect, Session, URL_Plug};
	false->
	    {redirect, Session,URL_Not_Plug}
    end.

%% +type redir_by_spider_recordName(session(),Multilink::string()) ->
%%  erlpage_result().

redir_by_spider_recordName(abs, MultiLink) ->
    lists:map(fun(X) -> 
		      [_,U] = string:tokens(X,"="),
		      {redirect, abs, U} 
	      end,
	      string:tokens(MultiLink,","));
redir_by_spider_recordName(Session, MultiLink) ->
    SPIDER_RECNAME = svc_spider:get_record_name(Session),
    ML = lists:map(fun(X) -> 
			   [R,U] = string:tokens(X,"="),
			   {list_to_atom(R),U} 
		   end,
		   string:tokens(MultiLink,",")),
    URL = find_url(SPIDER_RECNAME, ML),
    {redirect, Session, URL}.

find_url(RecName,[{RecName,Url}|_]) -> Url;
find_url(RecName,[_|T]) -> find_url(RecName, T).

read_spider_commercial_segment(Session)->
    svc_spider:get_offerPOrSUid(Session).


%%% Redirige vers ?URL_SPIDER_NOGODETA si les donnees SPIDER sont presente sans
%%% godet A
-define(URL_SPIDER_NOGODETA, "file:/orangef/selfcare_long/spider.xml#restitGodetAError").
redir_spider_nogodetA(abs, Url) ->
    [{redirect, abs, ?URL_SPIDER_NOGODETA},
     {redirect, abs, Url}];
redir_spider_nogodetA(Session, Url) ->
    case svc_spider:get_availability(Session) of
	available ->
	    case svc_spider:typeRestitution(Session) of
		"" -> {redirect, Session, ?URL_SPIDER_NOGODETA};
		_ ->  {redirect, Session, Url}
	    end;
	_ -> {redirect, Session, Url}
    end.	    

%% Fonction use to get, or update SDP_USER_STATE record
%% don't use another fonction

%%%% Associative list
%%%% !!! A ne pas utiliser pour l'instant hors sms_games
%% +type init_svc_data(session()) -> [term()].
init_svc_data(Session)->
    case Session#session.svc_data of
	X when list(X)->
	    X;
	#sdp_user_state{}=SDP->
	    [{user_state,SDP}];
	#postpaid_user_state{} = UserState ->
	    [{user_state, UserState}];
	#opim_user_state{} = UserState ->
            [{user_state, UserState}];
	_->
	    none
    end.

%% +type update_state(session(), term())-> session().
%%%% Works only with sdp_user_state.
update_state(Session,State) when record(State,sdp_user_state)->
    Session#session{svc_data=State};
update_state(Session,Pairs)->
    State=get_user_state(Session),
    update_user_state(Session,update_field(State,Pairs)).

%% +type update_field(sdp_user_state(),[{atom(),term()}])-> sdp_user_state().
%%%% Works only with sdp_user_state.
update_field(Record,Pairs)->
    Fields=record_info(fields,sdp_user_state),
    oma_util:pairs_to_record(Record, Fields, Pairs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type add_cb(oma_types:mfa(), session()) -> session().
add_cb(MFA, #session{callbacks=CBs}=Session) ->
    Session#session{callbacks=[MFA|CBs]}.



%%%% For each ACL print list of service associate.
%% +type print_acl_info()-> [{ACL::atom(),[SC::string()]}].
print_acl_info()->
    {ok, [{imsi,Imsi_list},{msisdn,Msisdn_list}]} = application:get_env(pservices,auth_list),
    [{imsi,get_sc_acl_info(imsi,Imsi_list)},
     {msisdn,get_sc_acl_info(msisdn,Msisdn_list)}].


get_sc_acl_info(Type,List)->
    {ok, SC_ACL} = application:get_env(pservices,auth_by_sc_acl),
    lists:map(fun(ACL) ->
		      SC_Member=
			  lists:foldl(fun({SC,_,_,_,_,ACLs_SC},Acc)->
					      case lists:member({Type,ACL},ACLs_SC) of
						  true->
						      Acc++[SC];
						  false ->
						      Acc
					      end end,[],SC_ACL),
		      {ACL,SC_Member} end,List).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% + type declinaison(sdp_user_state())->
%%                    string().
%%%% Get the subscription corresponding to the DCL_NUM.

declinaison(#sdp_user_state{}=US)->
    Decl=US#sdp_user_state.declinaison,
    case Decl of
 	?mobi->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte),
 	    "mobi";
	X when X==?BORDEAUX_mobile; X==?PSG_mobile; X==?OM_mobile;
	       X==?OL_mobile; X==?ASSE_mobile; X==?RC_LENS_mobile;
	       X==?CLUB_FOOT->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_club_foot),
 	    "mobi";
 	?mobi_new->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_new_dcl),
 	    "mobi";
	?mobi_janus->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_mobi_janus),
 	    "mobi";
 	?click_mobi->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_click),
 	    "mobi";
 	?m6_prepaid->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_m6),
 	    "mobi";
	?DCLNUM_ADFUNDED->
	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_adfunded),
            "mobi";
	?m6sample->
	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_m6_sample),
	    "mobi";
	?umobile->
 	    slog:event(trace, ?MODULE, self_provisionned_mobicarte_u_mobile),
 	    "mobi";
 	?cpdeg->
 	    slog:event(trace, ?MODULE, self_provisionned_atpdeg),
 	    "mobi";
 	?B_phone->
 	    slog:event(trace, ?MODULE, self_provisionned_b_phone),
 	    "mobi";
	?internet_everywhere ->
	    slog:event(trace, ?MODULE, self_provisionned_internet_everywhere),
	    "mobi";
  	X when X==?pmu;X==?fmu_18;X==?fmu_24;X==?ppolc;X==?ppol4;X==?ppol3;
	       X==?ppol2;X==?ppol1;X==?ppola;X==?cmo_sl;
	       X==?zap_cmo;X==?zap_cmo_v2;X==?m6_cmo;X==?m6_cmo2;X==?cmo_sl_apu;
	       X==?m6_cmo3;X==?m6_cmo4; X==?m6_cmo_1h; X==?m6_cmo_1h20;
	       X==?m6_cmo_1h40; X==?m6_cmo_2h; X==?m6_cmo_3h; X==?big_cmo;
	       X==?m6_cmo_1h_v2;X==?m6_cmo_1h30_v2;X==?m6_cmo_2h_v2;X==?m6_cmo_20h_8h;
	       X==?zap_cmo_18E;X==?zap_cmo_20E;X==?zap_cmo_25E;X==?zap_cmo_1h_v2;X==?zap_cmo_1h30_v2;
	       X==?zap_cmo_1h30_ill;X==?rsa_cmo;
	       X==?parent_cmo;X==?m6_cmo_2h30;X==?m6_cmo_1h_sl;
	       X==?m6_cmo_1h_v3;X==?m6_cmo_1h30_v3;X==?m6_cmo_2h_v3;X==?m6_orange_fixe_1h;
	       X==?m6_cmo_ete;X==?zap_vacances;X==?sl_blackberry_1h;X==?zap_cmo_1h_unik;
	       X==?m6_cmo_onet_1h_20E;X==?m6_cmo_onet_1h_27E;X==?m6_cmo_onet_2h_30E;X==?m6_cmo_fb_1h;
	       X==?DCLNUM_CMO_SL_ZAP_1h30_ILL; X==?cmo_smart_40min; X==?cmo_smart_1h;
	       X==?cmo_smart_1h30; X==?cmo_smart_2h;X==?FB_M6_1H_SMS;X==?FB_M6_1H30 ->
 	    slog:event(trace, ?MODULE, self_provisionned_cmo),
	    "cmo";
 	X when X==?omer;X==?DCLNUM_BREIZH_PREPAID ->
	    slog:event(trace, ?MODULE, self_provisionned_omer),
	    "omer";
	X when X==?bzh_cmo;X==?bzh_cmo2;
	       X ==?DCL_BZH_CB1;
               X ==?DCL_BZH_CB2;
               X ==?DCL_BZH_CB3;
               X ==?DCL_BZH_CB4 ->
	    slog:event(trace, ?MODULE, self_provisionned_bzh_cmo),
	    "bzh_cmo";
	X when X==?tele2_pp;X==?tele2_pp2;X==?casino_pp ->
	    slog:event(trace, ?MODULE, self_provisionned_tele2_pp),
	    "tele2_pp";
	X when X==?DCLNUM_VIRGIN_COMPTEBLOQUE1;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE2;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE3;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE4;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE5;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE6;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE7;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE8;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE9;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE10;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE11;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE12;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE13;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE14;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE15;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE16;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE17;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE18;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE19;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE20;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE24;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE25;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE26;
	       X==?DCLNUM_VIRGIN_COMPTEBLOQUE27->
	    slog:event(trace, ?MODULE, self_provisionned_virgin_comptebloque),
	    "virgin_comptebloque";
	X when X==?DCLNUM_VIRGIN_PREPAID; X==?DCLNUM_VIRGIN_PREPAID2 ->
	    slog:event(trace, ?MODULE, self_provisionned_virgin_prepaid),
	    "virgin_prepaid";
	?DCLNUM_CARREFOUR_PREPAID ->
	    slog:event(trace, ?MODULE, self_provisionned_carrefour_prepaid),
	    "carrefour_prepaid";
	X when X==?DCLNUM_CARREFOUR_CB1;X==?DCLNUM_CARREFOUR_CB2;X==?DCLNUM_CARREFOUR_CB3;
	       X==?DCLNUM_CARREFOUR_CB4;X==?DCLNUM_CARREFOUR_CB5;X==?DCLNUM_CARREFOUR_CB6->
	    slog:event(trace, ?MODULE, self_provisionned_carrefour_comptebloq),
	    "carrefour_comptebloq";
	X when X==?tele2_cb;X==?tele2_cb2;X==?tele2_cb3->
	    slog:event(trace, ?MODULE, self_provisionned_tele2_comptebloque),
	    "tele2_comptebloque";
	X when X==?ten_cb;
	       X==?ten_cb2->
	    slog:event(trace, ?MODULE, self_provisionned_ten_comptebloque),
	    "ten_comptebloque";
						%?nrj_cb->

	X when X==?nrj_cb;X==?nrj_cb1;X==?nrj_cb2;X==?nrj_cb3;X==?nrj_cb4;
	       X==?nrj_cb5;X==?nrj_cb6;X==?nrj_cb7->
	    slog:event(trace, ?MODULE, self_provisionned_nrj_comptebloque),
	    "nrj_comptebloque";
	?nrj_pp ->
	    slog:event(trace, ?MODULE, self_provisionned_nrj_prepaid),
	    "nrj_prepaid";
	?DCLNUM_MONACELL_PREPAID ->
	    slog:event(trace, ?MODULE, self_provisionned_monacell_prepaid),
	    "monacell_prepaid";
        X when X==?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN;
               X==?DCLNUM_MONACELL_COMPTEBLOQUE_1H ->
	    slog:event(trace, ?MODULE, self_provisionned_monacell_comptebloqu),
	    "monacell_comptebloqu";
	?decl_symacom ->
	    slog:event(trace, ?MODULE, self_provisionned_symacom),
	    "symacom";
      	E->
 	    slog:event(failure, ?MODULE, self_provisionned_unknown,E),
 	    "postpaid"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% + type declinaison(sdp_user_state())->
%%                    string().
%%%% Get the subscription corresponding to the DCL_NUM.
get_list_declinaisons(DCL_name) ->
    get_list_declinaisons(DCL_name, 1, []).

get_list_declinaisons(DCL_name, 99, List_DCL) -> 
    List_DCL;
get_list_declinaisons(DCL_name, DCL, List_DCL) -> 
    User_state = #sdp_user_state{declinaison = DCL},
    case declinaison(User_state) of
	DCL_name -> 
	    get_list_declinaisons(DCL_name, DCL + 1, [DCL|List_DCL]);
	_ -> 
	    get_list_declinaisons(DCL_name, DCL + 1, List_DCL)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type subscription_price(Session::session(),Opt::atom())->
%%                          integer().
%%%% Define the subscription price according to the option and the type
%%%% of subscription.

subscription_price(Session, Opt) ->
    Price = case get_souscription(Session) of
		mobi -> 
		    case is_promotion(Session,mobi,Opt) of 
			true->
			    lists:keysearch(Opt, 1, get_env(opt_promo_mobi));
			false->
			    lists:keysearch(Opt, 1,
					    get_env(subscription_price_mobi))
		    end;
		virgin_prepaid ->
		    lists:keysearch(Opt, 1,
				    get_env(subscription_price_virgin_pp));
		virgin_comptebloque ->
		    lists:keysearch(Opt, 1,
				    get_env(subscription_price_virgin_cb));
		cmo -> 
		    lists:keysearch(Opt, 1,
				    get_env(subscription_price_cmo));
		_ -> undefined
	    end,
    case Price of
	{value, {_,"-"}} -> 0;
	{value, {_,V}} -> V;
	_ -> 0
    end.  

subscription_price(Session, Opt,without_promo) ->
    Price = case get_souscription(Session) of
		mobi -> 
		    lists:keysearch(Opt, 1, get_env(subscription_price_mobi));
		_ ->
		    subscription_price(Session, Opt)
	    end,
    case Price of
	{value, {_,V}} -> V;
	_ -> 0
    end.  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type rnv_to_date(RNV::integer())->
%%                   string().
%%%% Translate renewal period (RNV) to date in format DD/MM/YY.

rnv_to_date(RNV) ->
    rnv_to_date(RNV,dmy).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type rnv_to_date(RNV::integer(),Format::atom())->
%%                   string().
%%%% Translate renewal period (RNV) to date.

rnv_to_date(0,_)->
    "inconnu";
rnv_to_date(40,_)->
    "dimanche";
rnv_to_date(41,_) ->
    "lundi";
rnv_to_date(42,_) ->
    "mardi";
rnv_to_date(43,_) ->
    "mercredi";
rnv_to_date(44,_) ->
    "jeudi";
rnv_to_date(45,_) ->
    "vendredi";
rnv_to_date(46,_) ->
    "samedi";
rnv_to_date(50,Format)->
    {Y,M,D} = date(),
    case Format of
	dm->
	    pbutil:sprintf("%02d/%02d",[D,M]);
	_->
	    pbutil:sprintf("%02d/%02d/%02d",[D,M,Y rem 100])
    end;
rnv_to_date(I,Format) when I==28;I==29;I==30;I==31->
    {Y,M,D} = date(),
    D2=calendar:last_day_of_the_month(Y,M),
    case Format of
	dm->
	    pbutil:sprintf("%02d/%02d",[D2,M]);
	_->
	    pbutil:sprintf("%02d/%02d/%02d",[D2,M,Y rem 100])
    end;
rnv_to_date(I,Format) when integer(I)->
    %% le Ieme jour du mois suivant
    {Y,M,D} = date(),
    case D>I of
 	true when M=/=12->
	    case Format of
		dm->
		    pbutil:sprintf("%02d/%02d",[I,M+1]);
		_->
		    pbutil:sprintf("%02d/%02d/%02d",[I,M+1,Y rem 100])
	    end;
 	true->
	    case Format of
		dm->
		    pbutil:sprintf("%02d/%02d",[I,1]);
		_->
		    pbutil:sprintf("%02d/%02d/%02d",[I,1,(Y rem 100)+1])
	    end;
 	false->
	    case Format of
		dm->
		    pbutil:sprintf("%02d/%02d",[I,M]);
		_->
		    pbutil:sprintf("%02d/%02d/%02d",[I,M,Y rem 100])
	    end
    end;
rnv_to_date(_,_)->
    "inconnu".


%% -type interrupt_service(session(), atom(), string(), string())->redirect
interrupt_service(abs, Param, URL_normal, URL_interrupt) ->
    [{redirect,abs,URL_normal},{redirect,abs,URL_interrupt}];
interrupt_service(Session, Param, URL_normal, URL_interrupt) ->
    Param_config = list_to_atom(Param),
    {Beg, End} = pbutil:get_env(pservices_orangef, Param_config),
    redirect_if_between_datetimes(Session, Beg, End, URL_interrupt, URL_normal).

%%%PROMO

%% +type is_promotion(session(),Subscr::atom(),Opt::atom())-> true|false.
is_promotion(Session,mobi,Opt)->
    State = get_user_state(Session),
    %% QUICK SOLUTION FOR UNIVERSAL TIME CONVERSION BUG OF ERLANG BUILT-IN FUNCTION: TO BE REVIEWED
    %%     D_Activ = State#sdp_user_state.d_activ,
    D_Activ = case catch unixtime_to_local_time(State#sdp_user_state.d_activ) of 
                  {'EXIT', Why} -> 
                      slog:event(failure,?MODULE,universal_time_conversion_error,Why);
                  Val -> 
                      Val
              end,
    case svc_compte:cpte(State,svc_options:opt_to_godet(Opt,mobi)) of
	#compte{} -> false;
	_ ->
	    Declinaison=variable:get_value(Session, {"bons_plans","subscription"}),
	    case Declinaison of
		not_found ->
		    List_Type="mobi";
		_ ->
		    List_Type=Declinaison
	    end,
	    List=list_to_atom("opt_promo_"++List_Type),
	    case lists:keysearch(Opt,1,get_env(List)) of
		{value,_}->
		    Comm_Date=get_env(commercial_date),
		    {value,{_,[{Beg,End}]}}=lists:keysearch(Opt,1,Comm_Date),
		    %% QUICK SOLUTION FOR UNIVERSAL TIME CONVERSION BUG OF ERLANG BUILT-IN FUNCTION: TO BE REVIEWED
		    %%                     (local_time_to_unixtime(Beg) =< D_Activ)
		    %%                         and (D_Activ < local_time_to_unixtime(End));
 		    (Beg =< D_Activ) and (D_Activ < End);
		_->
		    false
	    end
    end;
is_promotion(Session,_,Opt) ->
    false.

%% +type br_separate(contents()) -> contents().
%%%% Inserts a br between items of the list (but not at the end).
br_separate(List) ->
    br_separate(List, []).

%% +type br_separate(contents(), contents()) -> contents().
%%%% Inserts a br between items of the list (but not at the end).
br_separate([X, Y | Tail], Acc) ->
    br_separate([Y|Tail], [br, X | Acc]);
br_separate([X], Acc) ->
    lists:reverse([X | Acc]);
br_separate([], []) ->
    [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_recharge_forbidden(State::sdp_user_state()) -> bool().
%%%% Check whether recharge is forbidden for dcl_num.

is_recharge_forbidden(State) -> 
    Forbidden_dcl = pbutil:get_env(pservices_orangef,recharge_dcl_interdit),
    case lists:member(State#sdp_user_state.declinaison, Forbidden_dcl) of
	true ->
	    case is_integer(State#sdp_user_state.etats_sec) of
		true->
		    case State#sdp_user_state.etats_sec band 1 of
			0 ->
			    true;
			_ ->
			    false
		    end;
		_ ->
		    slog:event(warning, ?MODULE, recharge_forbidden, {etat_sec_undefined, State}),
		    true
	    end;
	_ ->
	    false
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type url_recharge_forbidden(State::sdp_user_state()) -> bool().
%%%% Returns the url recharge forbidden depending on dcl_num.

url_recharge_forbidden(State) -> 
    case State#sdp_user_state.declinaison of
	?m6_prepaid ->
	    pbutil:get_env(pservices_orangef,url_recharge_interdit_m6);
	?click_mobi ->
	    pbutil:get_env(pservices_orangef,url_recharge_interdit_click);
	?umobile->
	    pbutil:get_env(pservices_orangef,url_recharge_interdit_umobile);
	_ ->
	    pbutil:get_env(pservices_orangef,url_recharge_interdit)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_valid(CG::string()) ->
%%                {ok,string()} | {nok,only_integer} | {nok,bad_length} |
%%                {nok, not_list}.
%%%% Checks that the entered 14 digit code is correct.

is_valid(CG) when list(CG) ->
    case length(CG) of
	L when L==14 ->
	    case pbutil:all_digits(CG) of
		false -> {nok, only_integer};
		true -> {ok, CG}
	    end;
	_ ->
	    {nok, bad_length}
    end;
is_valid(_) ->
    {nok, not_list}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_code(CODE::string(),Length::integer())-> 
%%               bool().

is_code(Code,Length) when length(Code)=/=Length->
    false;
is_code(Code,Length)->
    pbutil:all_digits(Code).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type imsi_court(string())-> string().
imsi_court("20801"++[H1,H2,V|T])->
    "20801"++[H1,H2|T];
imsi_court(IMSI) ->
    IMSI.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

						%subscription(ID)->
						%    "mobi".
%%%% Not in the test folder in order to pass the xref tests
get_test_subscription(ID)->
    case ets:lookup(sub,ID) of
	[{ID,SUB}]->
	    SUB;
	_->
	    undefined
    end.

%%%%%%%%%%%TOOL to dump files%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Function to write file (append mode) on each node
writeFun(Line) ->
    fun(DN) ->
	    {ok,FD} = file:open(DN,[append]),
	    case io:format(FD,"~s\r\n",[Line]) of
		ok ->
		    file:close(FD);
		Else ->
		    file:close(FD),
		    Else
	    end	       
    end.

%% Function doing the job (transfer + write) for one destination
transferFun(FileName,Line)->
    fun({Node,DestDir}) ->
	    {Y,Mo,D} = date(),
	    Date= pbutil:sprintf("%04d-%02d-%02d",[Y,Mo,D]),
	    Date2= lists:flatten(Date),
	    DestFileName = lists:flatten(pbutil:sprintf("%s-%s.csv",[FileName,Date2])),
	    DestName = filename:join(DestDir,DestFileName),		 
	    Res= rpc:call(Node,erlang,apply,[writeFun(Line),[DestName]]),
	    case Res of
		ok -> 
		    slog:event(trace,?MODULE,transfer_done,{Node,DestName}),
		    true;

		E->
		    slog:event(failure,?MODULE,transfer_failed,{Line,{Node,DestName},E}),
		    false
	    end
    end.

event(DumpParam,FileName,Format,Data)->
    case pbutil:get_env(pservices_orangef,DumpParam) of
	true ->
	    {Y,Mo,D} = date(),
	    Today = pbutil:sprintf("%04d-%02d-%02d",[Y,Mo,D]),
	    Today2= lists:flatten(Today),
	    Data2 = [Today2 | Data],
	    Format2 = "~s," ++ Format,
	    Line = io_lib:format(Format2,Data2),
	    {SuccessCrit,Destinations} = pbutil:get_env(pservices,store_query_result),
	    AllResults = lists:map(transferFun(FileName,Line),Destinations);
	_ ->
	    ok
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEW INTERFACE USED IN TEXT_xxxx FILES:
%% FUNCTIONS TO PRINT INFORMATION IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_opt_name(Opt::atom(),Subscription::atom()) -> string().
%%%% Returns the commercial name of the option.

get_opt_name(Opt, Subscription) ->
    Conf_param = 
	case Subscription of
	    mobi -> 
		opt_commercial_name_mobi;
	    cmo ->
		opt_commercial_name_cmo
	end,
    {ok, Commercial_names} = 
	application:get_env(pservices_orangef, Conf_param),
    case lists:keysearch(Opt,1,Commercial_names) of
	{value,{Opt, CommName}} -> CommName;
	_ -> ""
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_commercial_start_date(Opt::atom(),Subscription::atom(),
%%                                 Format::string()) ->
%%                                 string().
%%%% Returns the start date defined by the configuration parameter
%%%% commercial_date_cmo or commercial_date.

get_commercial_start_date(Opt,Subscription,Format) ->
    svc_option_manager:get_commercial_start_date(Opt,Subscription,Format).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_commercial_end_date(Opt::atom(),Subscription::atom(),
%%                               Format::string()) ->
%%                               string().
%%%% Returns the end date defined by the configuration parameter
%%%% commercial_date_cmo or commercial_date.

get_commercial_end_date(Opt,Subscription,Format)->
    svc_option_manager:get_commercial_end_date(Opt,Subscription,Format).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_option_price(Opt::atom(),Subscription_info::atom()) -> string().
%%%% Print price, unit displayed is "E".

get_option_price(Opt, Subscription_info) ->
    get_option_price(Opt, Subscription_info, "E").

%% +type get_option_price(Opt::atom(),Subscription_info::atom(),
%%                        Txt::string())->
%%                        string().
%%%% Print price, unit displayed is defined by Txt.

get_option_price(Opt, Subscription_info, Txt) ->
    Conf_param_price =
	case Subscription_info of
	    mobi -> 
		subscription_price_mobi;
	    mobi_promo -> 
		opt_promo_mobi;
	    virgin_prepaid ->
		subscription_price_virgin_pp;
	    virgin_comptebloque ->
		subscription_price_virgin_cb;
	    cmo -> 
		subscription_price_cmo;
	    _ ->
		undefined
	end,
    {ok, Price} =
	application:get_env(pservices_orangef, Conf_param_price),
    P = case lists:keysearch(Opt, 1, Price) of
	    {value,{Opt, Price_value}} -> Price_value;
	    _ -> 0
	end,
    Peuros = P/1000,
    Result = case (trunc(Peuros)*10)==trunc(Peuros*10) of
		 true  -> io_lib:format("~w"++Txt, [trunc(Peuros)]);
		 false -> io_lib:format("~.1f"++Txt, [Peuros])
	     end,
    lists:flatten(Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_opt_info(Info::string()) ->
%%                    string().
%%%% Get the information defined by Info.

get_opt_info(min_refill) ->
    MinRefill =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_illimite_kdo_mini)),
    Value = currency:round_value(MinRefill),
    lists:flatten(io_lib:format("~w", [trunc(Value)]));

get_opt_info(month) ->
    Now=pbutil:unixtime(),
    {{_, Mo, _}, _} = 
	calendar:now_to_datetime({Now div 1000000,
				  Now rem 1000000,0}),
    Date = pbutil:sprintf("%02d/%02d", [1,Mo]),
    lists:flatten(Date); 

get_opt_info(Refill_amount) ->
    Aeuros = Refill_amount/1000,
    IoLibF = io_lib:format("~w", [trunc(Aeuros+0.5)]),
    lists:flatten(IoLibF).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_msisdn(Msisdn::string())->
%%                   string().
%%%% Get field MSISDN stored in c_op_opt_date_souscr in sdp_user_state.

get_msisdn(Msisdn) ->
    [D1,D2,D3,D4,D5,D6,D7,D8,D9,D10] = Msisdn,
    [D1,D2]++" "++[D3,D4]++" "++[D5,D6]++" "++[D7,D8]++" "++[D9,D10].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_credit(Opt::string(),State::sdp_user_state(),
%%                  Subscr::atom(),UNT_REST::string())->
%%                  string().
%%%% Get option credit in unit defined by parameter UNT_REST.

get_credit(Opt, State, Subscr, UNT_REST) ->
    svc_compte:get_credit(State, 
			  svc_options:opt_to_godet(Opt,Subscr),
			  UNT_REST).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_end_credit(Opt::string(),State::sdp_user_state(),
%%                      Subscr::atom(),Format::string())->
%%                      string().
%%%% Get credit end date for the option.

get_end_credit(Opt, State, Subscr, Format) ->
    svc_compte:get_end_credit(State, 
			      svc_options:opt_to_godet(Opt,Subscr), 
			      Format).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redir_sce(session(), Url_sce::string(), Url_not_sce::string()) -> 
%%                 erlpage_result().
%%%% Redirects depending on the configuration parameter sce_used.

redir_sce(abs, Url_sce, Url_not_sce) ->
    [{redirect, abs, Url_sce},
     {redirect, abs, Url_not_sce}];

redir_sce(Session, Url_sce, Url_not_sce) ->
    case get_env(sce_used) of
	true -> 
	    {redirect, Session, Url_sce};
	_ ->
	    {redirect, Session, Url_not_sce}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redir_mvno(session(), Mvno::string(), Url_Mvno::string(), Url_Default::string()) -> 
%%                 erlpage_result().
%%%% Redirects depending on the configuration parameter sce_used.

redir_mvno(abs, Mvno, Url_default) ->
    Urls=get_env(mvno_urls),
    [{redirect, abs, X}|| {_,X}<-Urls]++[{redirect, abs, Url_default}];

redir_mvno(Session, Mvno, Url_default) ->
    Urls=get_env(mvno_urls),
    case lists:keysearch(Mvno,1,Urls) of
	{value,{_,Url_mvno}} ->
	    {redirect, Session, Url_mvno};
	_ ->
	    {redirect, Session, Url_default}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redir_menu_dme(session(), Url_menu_dme::string(), Url_not_menu_dme::string()) -> 
%%                 erlpage_result().
%%%% Redirects depending on the configuration parameter sce_used.

redir_menu_dme(abs, Url_menu_dme, Url_not_menu_dme) ->
    [{redirect, abs, Url_menu_dme},
     {redirect, abs, Url_not_menu_dme}];

redir_menu_dme(Session, Url_menu_dme, Url_not_menu_dme) ->
    case is_commercially_launched(Session, menu_dme) of
	true -> 
	    {redirect, Session, Url_menu_dme};
	_ ->
	    {redirect, Session, Url_not_menu_dme}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redir_menu_mobi(session(), Url_new_mobi::string(), Url_old_mobi::string()) -> 
%%                 erlpage_result().
%%%% Redirects depending on the configuration parameter sce_used.

redir_new_mobi(abs, Url_new_mobi, Url_old_mobi) ->
    [{redirect, abs, Url_new_mobi},
     {redirect, abs, Url_old_mobi}];

redir_new_mobi(Session, Url_new_mobi, Url_old_mobi) ->
    case get_env(refonte_ergo_mobi) of
	true -> 
	    {redirect, Session, Url_new_mobi};
	_ ->
	    {redirect, Session, Url_old_mobi}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Functions used for Roaming
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_europe_vlr(Vlr_Number::string()) -> bool().
%%%% Check whether the customer is localized in Europe + 9 countries list.

is_europe_vlr(VLR_Number) ->
    Dial_code_list =  pbutil:get_env(pservices_orangef,
				     europe_dialling_codes),
    S_dialcode_list = lists:sort(Dial_code_list),
    R_dialcode_list = lists:reverse(S_dialcode_list),
    Code_country_list = lists:map(fun(E) -> integer_to_list(E) end, 
				  R_dialcode_list),
    match_key(VLR_Number, Code_country_list).


%% +type match_key(string(),[string()]) -> bool().

match_key(VLRNumber,[CCNDC | Keys]) ->
    lists:prefix(CCNDC,VLRNumber) orelse match_key(VLRNumber, Keys);

match_key(_,[]) ->
    false.


%%%% This function uses Sachem X25. Will soon be obsolete
sachem_request(Subscription,Identity,State)->
    case catch sdp_router:tlv_a4({Subscription,Identity}) of
	{ok,[[],[Msisdn],[[DOSNUMID,DECLI,ETAT_PRINC,ETAT_SEC,OPTION,
			   DATE_ACTIV,DLV,DATE_DER_REC,LNG_NUM,
			   MALIN,TRIBU,ACCES,DMN]]|Z50] =Response} ->
	    pbutil:autograph_label(response_ok),
	    State_ = State#sdp_user_state{msisdn=Msisdn,
					  dos_numid=DOSNUMID,
					  declinaison=DECLI,
					  etats_sec=ETAT_SEC,
					  option= OPTION,
					  d_activ=DATE_ACTIV,
					  dlv=DLV+?OFFSET_TZ,
					  d_der_rec=DATE_DER_REC,
					  langue=LNG_NUM,
					  malin=MALIN,
					  acces=ACCES,
					  dtmn=DMN},
	    State2_ = decode_etat_princ(ETAT_PRINC,State_),
	    State3_ = svc_compte:decode_compte(Z50,State2_),
	    {ok, Msisdn, State3_};
	Else ->
	    Else
    end.

%% +type decode_etat_princ(integer(), sdp_user_state()) ->
%%                         {ok, sdp_user_state()}.
%%%% Decodes value Etat, and update State accordingly
%%%% TODO issue pseudo tax request when user in VA state
decode_etat_princ(Etat, State) ->
    Etat_princ = case Etat of
		     ?ETAT_VA -> ?ETAT_VA;
		     ?ETAT_AC -> ?ETAT_AC;
		     ?ETAT_SI -> ?ETAT_SI;
		     ?ETAT_SF -> ?ETAT_SF;
		     ?ETAT_SV -> ?ETAT_SV;
		     ?ETAT_SA -> ?ETAT_SA; 
		     ?ETAT_SR -> ?ETAT_SR;
		     ?ETAT_RA -> ?ETAT_RA;
		     ?ETAT_RO -> ?ETAT_RO;
		     ?ETAT_TR -> ?ETAT_TR;
		     Else -> 
			 slog:event(failure, ?MODULE, unknown_etat_princ,Else),
			 unknown_etat_princ
		 end,
    State#sdp_user_state{etat_princ=Etat_princ}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_first_recharge(sdp_user_state())-> bool().
is_first_recharge(State) ->
    SECOND_TIME = (?SETAT_CB band (State#sdp_user_state.etats_sec)) == ?SETAT_CB,
    case SECOND_TIME of
	true ->
	    false;
	_ ->
	    true
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_format_date_DD_MM_YYYY(string())-> bool().
is_format_date_DD_MM_YYYY(Date)->
    case regexp:matches(Date,"[0123][0-9]/[01][0-9]/2[0-9][0-9][0-9]") of
	{match,[{1,10}]} ->
	    true;
	_ ->
	    false
    end.


%% +type esc_ampersand(string()) -> string().
esc_ampersand([])->
    [];
esc_ampersand([38|S]) ->
    "%26" ++ esc_ampersand(S);
esc_ampersand([C|S]) ->
    [C | esc_ampersand(S)].


%% +type send_sms_cvf(session(),string(),string(),atom()) 
%%       -> ok| sms_could_not_be_sent.

send_sms_cvf(Session, Text, DestMsisdn,Routing) ->
    slog:event(count, ?MODULE, send_sms_cvf),
    case svc_util:send_sms_mo(Session, Routing, Text, DestMsisdn) of
	true  -> ok;
	false -> throw(sms_could_not_be_sent)
    end.

%%%% Sending a short text to private SMS server in a SMS to MSISDN Target.
%% +type send_smsmt(session(), string(), string(), atom())
%%   -> bool().

send_smsmt(Session, Text, Target,Routing) ->
    Profile = Session#session.prof,
    OA = Profile#profile.msisdn, 
    case catch sms_util:send_sms_mt(oa,Text, Target, OA, no_srr, Routing) of
	{ok,0} ->
	    slog:event(trace, ?MODULE, sms_sent, Routing),
	    {ok,sent};
	{ok,sent} ->
	    slog:event(trace, ?MODULE, sms_sent, Routing),
	    {ok,sent};
	Err ->
	    slog:event(failure, ?MODULE, send_sms, Err),
	    throw(sms_could_not_be_sent)
    end.

%% +type int_to_nat(string())-> string().
int_to_nat("+33"++MSISDN)->
    "0"++MSISDN;
int_to_nat("33"++MSISDN)->
    "0"++MSISDN;
int_to_nat("6"++Rest=MSISDN) when length(MSISDN)==9 ->
    "0" ++ MSISDN;
int_to_nat("06"++Rest=MSISDN) ->
    MSISDN;
int_to_nat("7"++Rest=MSISDN) when length(MSISDN)==9 ->
    "0" ++ MSISDN;
int_to_nat("07"++Rest=MSISDN) ->
    MSISDN;
int_to_nat(Msisdn) ->
    slog:event(warning, ?MODULE, not_french_international_format, Msisdn),
    case length(Msisdn) of
        12 -> "0" ++ string:right(Msisdn, 9);
        11 -> "0" ++ string:right(Msisdn, 9);
        10 -> Msisdn;
        9  -> "0" ++ Msisdn;
        _ -> 
            slog:event(internal, ?MODULE, unexpected_msisdn, Msisdn),
            ""    
    end.

%% +type redirect_option_activated(session(),url_opt_activated(),url_opt_not_activated) -> erlpage_result().
redirect_option_activated(abs, _, Url_activated, Url_not_activated) ->
    [{redirect,abs,Url_activated},
     {redirect,abs,Url_not_activated}];
redirect_option_activated(Session, Option, Url_activated, Url_not_activated) ->
    Opt = list_to_atom(Option),
    case svc_options:is_option_activated(Session, Opt) of
	true ->
	    {redirect,Session,Url_activated};
	_ ->
	    {redirect,Session,Url_not_activated}
    end.

redirect_option_launched(Session, DEB, FIN, Uok, Unok) ->
    BEGIN = svc_util_of:unixtime_to_local_time(DEB),
    END = svc_util_of:unixtime_to_local_time(FIN),
    LT   = svc_util_of:local_time(),
    case svc_util_of:is_launched(BEGIN, END, LT) of
        true ->
            slog:event(trace,?MODULE,validity,ok),
            {redirect, Session, Uok};
        _ ->
            slog:event(trace,?MODULE,validity,nok),
            {redirect, Session, Unok}
    end.

check_sdp_user_state(abs,Url_OK)->
    [{redirect,abs,Url_OK},
     {redirect, abs, "/orangef/home.xml#temporary"}];

check_sdp_user_state(#session{svc_data=US,prof=Prof}=Session,Url_OK) ->
    case variable:get_value(Session,user_state) of
	not_found->
	    Msisdn = Prof#profile.msisdn,
	    slog:event(failure,?MODULE,user_state_not_found,{Msisdn,US}),
	    {redirect, Session, "/orangef/home.xml#temporary"};	
	_->
	    {redirect, Session, Url_OK}
    end.

sql_get_uid(Key) ->
    KeyCmd =
        case Key of
	    {msisdn,MSISDN}->"msisdn='"++MSISDN++"'";
	    {imsi,IMSI} -> "imsi='"++IMSI++"'";
	    E -> exit({bad_key,E})
	end,
    Cmd="SELECT uid FROM users where "++KeyCmd,
    case ?SQL_Module:execute_stmt(Cmd,[],?SQL_SELECT_TIMEOUT) of
        {selected,_,[[UID]]}->
            {ok,UID};
        {selected,_,[]}->
            no_user_in_base;
        Else ->
            slog:event(failure,?MODULE,select_uid_failed,Else),
%%%% multiple entry, Timeout, not_avail
            {error,Else}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% + type foot_declinaison(sdp_user_state())->
%%                    string().
%%%% Get the foot team corresponding to the DCL_NUM.
foot_declinaison(abs)->
    [{pcdata,"Foot"}];

foot_declinaison(Session)->
    State = get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    Text = case DCL of
	       ?BORDEAUX_mobile ->
		   "Girondins";
	       ?PSG_mobile ->
		   "PSG";
	       ?OM_mobile ->
		   "OM";
	       ?OL_mobile ->
		   "OL";
	       ?ASSE_mobile ->
		   "ASSE"; 
	       ?RC_LENS_mobile ->
		   "RC Lens";
	       ?CLUB_FOOT ->
		   "Club foot";
	       _->
		   ""
	   end,
    [{pcdata,Text}].



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% + type redirect_by_tac(sdp_user_state())->
%%                    string().
%%%% redirct by TAC.

redirect_by_tac(Session,Urls)->
    [Url,Url_default] = string:tokens(Urls,","),
    Tac_list = pbutil:get_env(pservices_orangef,tac_list),
    Imei = plugin:get_attrib(Session,"imei"),
    case Imei of
	""->{redirect,Session,Url_default};
	_ ->check_imei(Session,Imei,Tac_list,Url,Url_default)
    end.

check_imei(Session,Imei,Tac_list,Url,Url_default)->
    Imei_rs = string:substr(Imei, ?begin_tac,?end_tac),
    case pbutil:all_digits(Imei_rs) of
	true -> 
	    case lists:member(list_to_integer(Imei_rs),Tac_list) of
		true->
		    {redirect,Session,Url};
		_ ->
		    {redirect,Session,Url_default}
	    end;
	_ ->
	    {redirect,Session,Url_default}
    end.

tac(Session)->
    Imei = plugin:get_attrib(Session,"imei"),
    case Imei of
	""-> undefined;
	_ -> Imei_rs = string:substr(Imei, ?begin_tac,?end_tac),
	     case pbutil:all_digits(Imei_rs) of
		 true -> 
		     {integer, list_to_integer(Imei_rs)};
		 _ ->
		     {not_integer, Imei_rs}
	     end
    end.

is_compatible(opt_unik, Session) ->
    Tac = svc_util_of:tac(Session),
    Tac_list = pbutil:get_env(pservices_orangef,tac_list),
    case Tac of
	{integer, Tac_number} -> 
	    lists:member(Tac_number,Tac_list);
	_ ->
	    false    
    end.

now_to_local_time(Date_UT) ->
    calendar:now_to_local_time({Date_UT div 1000000,
				Date_UT rem 1000000,0}).

%% Get activation date of a profile
get_activation_date(Session,Subscription) ->
    get_activation_date_soap_tuxedo(Session).

get_activation_date_soap_tuxedo(Session) ->
    case svc_sachem:consult_account(Session) of
        {ok, {Session_new, Resp_params}} ->
            DATE_ACTIV = get_param_value("DOS_DATE_ACTIV", Resp_params),
            {ok,list_to_integer(DATE_ACTIV)};
        {nok, Reason} ->
            slog:event(failure, ?MODULE, get_activation_date,
                       {svc_sachem, consult_account_error, Reason}),
            nok
    end.

%% Get the number of day for adding to the activation day
get_date_add_activation({Day=31,Month,Year}) ->    
    calendar:last_day_of_the_month(Year,Month+1);
get_date_add_activation({Day=29,Month=1,_}) ->
    30;
get_date_add_activation({Day=30,Month=1,_}) ->
    29;
get_date_add_activation({_,Month,Year}) ->
    calendar:last_day_of_the_month(Year,Month).

%% Check whether today is activation day or not 
check_activation_day(#session{prof=Profile}=Session, Date_to_modify) ->    
    case get_activation_date(Session,cmo) of
        {ok,DATE_ACTIV} ->	    
            {Dmy_ac,_} = now_to_local_time(DATE_ACTIV),
	    Now = pbutil:unixtime(),
	    {Dmy_now,_} = now_to_local_time(Now),
	    %% Compare with consultation date
            case (Dmy_ac) of
                Dmy_now ->
		    %% Month + 1
                    Day_to_add = get_date_add_activation(Date_to_modify),
		    %% Check case renew_date or end_credit
		    New_date_UT = case (Date_to_modify) of
				      Dmy_now ->
					  DATE_ACTIV + Day_to_add*86400;
				      _ ->
					  DATE_ACTIV + (Day_to_add+1)*86400
				  end,
		    {ok, now_to_local_time(New_date_UT)};
		_ -> nok
            end;
        _ -> nok
    end.

%% +type do_consultation(session(), atom()) -> 
%%              {ok, [list(), list(), list()]}
%%%% sends a consult_account request to Sachem
do_consultation(#session{prof=Profile}=Session, Opt)->
    State = svc_util_of:get_user_state(Session),
    MSISDN = Profile#profile.msisdn,
    Subs = Profile#profile.subscription,
    TopNum = svc_options:top_num(Opt,list_to_atom(Subs)),
    Id = {list_to_atom(Subs),MSISDN},
    consult_account_options(Session, Id, "1", MSISDN, TopNum).

search_opt_from_z70([],Opt,Sub)->
    [];
search_opt_from_z70([[TOPNUM,_,DEB,FIN|_]|T],Opt,Sub)->
    case TOPNUM == svc_options:top_num(list_to_atom(Opt),Sub)  of
	true->[DEB,FIN];
	_-> search_opt_from_z70(T,Opt,Sub)
    end.

%% +type get_param_value(string(),list()) -> 
%%              undefined|string()|list().
%%%% Get Type of Ticket de rechargemen
get_param_value(Key_label, List_tuples) when list(List_tuples)->
    case lists:keysearch(Key_label, 1, List_tuples) of
        false ->
            slog:event(internal, ?MODULE, unexpected_get_param_value, {Key_label, List_tuples}),
            undefined;
        {value,{Key_babel,Value}} ->
            Value
    end;
get_param_value(_, Unexpected) ->
    slog:event(internal, ?MODULE, list_expected, Unexpected),
    undefined.


%%% add this func for migration 3.11.3

%%%% Hexadecimal - binary. 	 

%% +type dig2hex(0..15) -> Hex::char(). 	 
dig2hex(X) when X<0  -> exit(dig2hex); 	 
dig2hex(X) when X<10 -> $0+X; 	 
dig2hex(X) when X<16 -> 55+X. 	 

%% +type hex2dig(Hex::char()) -> 0..15. 	 
hex2dig(X) when X<$0         -> exit(hex2dig); 	 
hex2dig(X) when X>=$0, X=<$9 -> X-$0; 	 
hex2dig(X) when X>=$A, X=<$F -> X-55; 	 
hex2dig(X) when X>=$a, X=<$f -> X-87. 	 

%% +type bin2hex(bytes()) -> Hex::string(). 	 
bin2hex([]) -> []; 	 
bin2hex([HD|TL]) -> [dig2hex(HD bsr 4), 	 
                     dig2hex(HD band 15) | bin2hex(TL)]. 	 

%% +type hex2bin(Hex::string()) -> bytes(). 	 
hex2bin([]) -> []; 	 
hex2bin([H,L|TL]) -> [(hex2dig(H) bsl 4) + hex2dig(L) | hex2bin(TL)].

get_commercial_date(mobi,Opt) ->
    Comm_Date=pbutil:get_env(pservices_orangef,commercial_date),
    case lists:keysearch(Opt,1,Comm_Date) of
	{value,{Opt,Date_list}}->
	    Date_list;%%    [{Begin,End}]
	_ ->
	    []
    end.

	    
add_to_sachem_available(Session,Request,Resp_params)->
    State=get_user_state(Session),
    Available_list=
	case State#sdp_user_state.sachem_available of
	    undefined->
		[{Request,Resp_params}];
	    L when list(L) ->
		case lists:member({Request,Resp_params},L) of
		    true-> L;
		    false->L++[{Request,Resp_params}]
		end
	end,
    NState=State#sdp_user_state{sachem_available=Available_list},
    update_user_state(Session,NState).

remove_from_sachem_available(Session,Request)->
    State=get_user_state(Session),
    Available_list=
	case State#sdp_user_state.sachem_available of
	    undefined->
		[];
	    L when list(L) ->
		proplists:delete(Request,L)
	end,
    NState=State#sdp_user_state{sachem_available=Available_list},
    update_user_state(Session,NState).

get_available_sachem_data(Session,Request)->
    State=get_user_state(Session),
    case State#sdp_user_state.sachem_available of
        undefined->
            undefined;
        L when list(L) ->
            proplists:get_value(Request,L)
    end.

change_sachem_availability(Session,Request,Resp_params)->
    State=get_user_state(Session),
    case Request of
        X when X=="csl_tck";X=="csl_param_gen"->
            Session;
        X when X=="mod_cp";X=="tra_credit";X=="rec_tck"->
            remove_from_sachem_available(Session,"csl_doscp");
        X when X=="maj_op";X=="maj_nopt"->
            Session1=remove_from_sachem_available(Session,"csl_doscp"),
            remove_from_sachem_available(Session1,"csl_op");
        X when X=="csl_doscp";X=="csl_op"->
            add_to_sachem_available(Session,X,Resp_params)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type format_date(date() | undefined) -> string().
%%%% Format date DD/MM/YYYY.

format_date({Y, M, D}) ->
    lists:flatten(pbutil:sprintf("%02d/%02d/%04d", [D,M,Y]));
format_date(undefined) ->
    "-".

%% +type format_date(date() | undefined) -> string().
%%%% Format date DD/MM/YY.
format_date_dmy({Y, M, D}) ->    
    lists:flatten(pbutil:sprintf("%02d/%02d/%02d", [D,M,Y rem 100]));
format_date_dmy(undefined) ->
    "-".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type format_date_dm(date() | undefined) -> string().
%%%% Format date DD/MM.

format_date_dm({_, M, D}) ->
    lists:flatten(pbutil:sprintf("%02d/%02d", [D,M]));
format_date_dm(undefined) ->
    "-".

format_heure({HH,MM,SS}) ->    
    lists:flatten(pbutil:sprintf("%02d:%02d:%02d", [HH,MM,SS]));
format_heure(undefined) ->
    "-".
term_to_string(Term)->
    lists:flatten(io_lib:write(Term)).

display_link(URL, PCD, BR)->
    case BR of
        "br_after"->
            [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br("br");
        "br"->
            add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
        "nobr"->
            [#hlink{href=URL,contents=[{pcdata,PCD}]}]
    end.

display_link(URL, PCD, KEY, BR)->
    case BR of
        "br_after"->
            [#hlink{href=URL, key=KEY, contents=[{pcdata,PCD}]}]++add_br("br");
        "br"->
            add_br("br")++[#hlink{href=URL, key=KEY, contents=[{pcdata,PCD}]}];
        "nobr"->
            [#hlink{href=URL,key=KEY, contents=[{pcdata,PCD}]}]
    end.
