-module(webuser_logs_orangef).

%%%% DB Interfaces for stats / history

%%% The table ?TABLE_NAME has to be created by executing script in priv
%%% directory

-export([write_event/3]).

-include("../../pdatabase/include/pdatabase.hrl").
-include("../../pdist/include/generic_router.hrl").
-include("../../oma/include/slog.hrl").

-export([
         consultations_on_each_day/2,
         consultations_in_a_period/2,
         number_of_representatives_on_each_day/2,
         number_of_representatives_in_period/2
        ]).

-export([customer_history/2]).

-export([delete_old_logs/1]). %% crontab

-export([slog_info/3]).


-define(TABLE_NAME, "webuser_of_logs").
-define(ROUTING, [webuser_of]).
-define(TIME_OUT, 5000).
-define(ER_NO_SUCH_TABLE, 1146).

-define(ACTION_CONSULT_USER, "1").
-define(ACTION_CONSULT_SESSION, "2").
-define(ACTION_UPDATE_USER, "3").

-define(HISTORY_DAYS, 30).

%% deftype actions() = consult_user | {consult_session, Beg_time:string()}
%%                                  | {update, what:string()}.

%% +type write_event(string(), UID::integer(), actions()) -> ok | error.
write_event(User, UID, Action) ->
    Unixtime = integer_to_list(pbutil:unixtime()),
    String_UID = integer_to_list(UID),
    {SQLAction, SQLDetails} = mk_sql_action(Action),
    SQLCommand = ["INSERT INTO ", ?TABLE_NAME,
                  " (login, uid, unixtime, action, details) VALUES ",
                  " ('",User,"','", String_UID, "','", Unixtime, "','",
                  SQLAction, "','", SQLDetails,"')"],   

    case
	catch generic_router:routing_request(?SQL_Module,
					     #sql_query{request=SQLCommand}, 
					     ?TIME_OUT,
					     ?ROUTING) of
	{ok,{updated, 1}} ->
            ok;
        E ->
            slog:event(failure, ?MODULE, write_event, {E, User, UID, Action}),
            error
    end.

mk_sql_action(consult_user) ->
    {?ACTION_CONSULT_USER, ""};
mk_sql_action({consult_session, Begin_time}) ->
    {?ACTION_CONSULT_SESSION, Begin_time};
mk_sql_action({update_profile, Details}) ->
    {?ACTION_UPDATE_USER, Details}.

from_sql_action_details(?ACTION_CONSULT_USER, _) ->
    consult_user;
from_sql_action_details(?ACTION_CONSULT_SESSION, Begin_time) ->
    {consult_session, list_to_integer(Begin_time)};
from_sql_action_details(?ACTION_UPDATE_USER, Details) ->
    {update_profile, Details}.


%% +type consultations_on_each_day(integer(), integer()) ->
%%        [{Date::string(), integer()}].
consultations_on_each_day(BTime,ETime) ->
    DaysList=get_days(BTime,ETime),
    lists:foldr(
      fun(Date,Acc) ->
	      Number=number_of_consultations_done_on(Date),
	      [{Date, Number} | Acc]
      end,[],DaysList).

number_of_consultations_done_on(Date) ->
    {StartUnix, EndUnix} = start_and_end_unixtime_from_date(Date),
    consultations_in_a_period(integer_to_list(StartUnix),
                              integer_to_list(EndUnix)).

start_and_end_unixtime_from_date(Date) ->
    Midnight = {0, 0, 0},
    Seconds=calendar:datetime_to_gregorian_seconds({Date, Midnight}),
    UnixSeconds=calendar:datetime_to_gregorian_seconds({{1970,1,1}, Midnight}),
    StartUnix = Seconds - UnixSeconds,
    {StartUnix, StartUnix + 24*3600}.

consultations_in_a_period(StartUnix_as_string, EndUnix_as_string) ->
    SQLCommand=[
                "SELECT COUNT(*) FROM ", ?TABLE_NAME,
                " WHERE unixtime>='", StartUnix_as_string,
                " ' AND unixtime<'", EndUnix_as_string,
                " ' AND action='",?ACTION_CONSULT_USER, "'"
                ],
    case
	catch generic_router:routing_request(?SQL_Module,
					     #sql_query{request=SQLCommand}, 
					     ?TIME_OUT,?ROUTING) of
	{ok, {selected, C_, [[Count]]}} -> list_to_integer(Count);
	Other ->
	    slog:event(failure, ?MODULE, sql, {SQLCommand, Other}),
	    exit(Other)
    end.

%% +type stats_representatives_on_each_day(integer(),integer())-> 
%%        list()
number_of_representatives_on_each_day(BTime,ETime) ->
    DaysList=get_days(BTime,ETime),
    lists:foldr(
      fun(Date,Acc) ->
              Number=number_of_representatives_on(Date),
	      [{Date, Number} | Acc]
      end,[],DaysList).

number_of_representatives_on(Date) ->
    {StartUnix, EndUnix} = start_and_end_unixtime_from_date(Date),
    number_of_representatives_in_period(StartUnix, EndUnix).

number_of_representatives_in_period(StartUnix, EndUnix) ->
    SQLCommand=
        [
         "SELECT COUNT(DISTINCT login) "
         "FROM ", ?TABLE_NAME, " where unixtime>='",
         integer_to_list(StartUnix),
         "' and unixtime<'", integer_to_list(EndUnix), "'"
	],
    case generic_router:routing_request(?SQL_Module,
					#sql_query{request=SQLCommand}, 
					?TIME_OUT,
					?ROUTING) of
	{ok, {selected, _, [[Count]]}} -> list_to_integer(Count);
	Other ->
	    slog:event(failure, ?MODULE, sql, {SQLCommand, Other}),
	    exit(Other)
    end.


get_days(BDateTime,EDateTime) ->
    get_days(BDateTime,EDateTime,[]).

get_days(BDateTime,EDateTime,DaysList) when BDateTime =< EDateTime ->
    {Date,_}= calendar:now_to_local_time({0, BDateTime, 0}),
    NextDateTime = BDateTime + 3600 * 24,
    get_days(NextDateTime,EDateTime,DaysList++[Date]);
get_days(_,_,DaysList) ->
    DaysList.

%%%%%%%%%%%%%%%%%%% HISTORY %%%%%%%%%%%%%%%%%

customer_history(UID, History_begin) ->
    Now = pbutil:unixtime(),

%%% Normally, the table is truncated by crontab
%%% webuser_logs:delete_old_logs
    After_date = Now - ?HISTORY_DAYS * 3600 * 24,
    After_date_as_string = integer_to_list(After_date),

    UID_string = integer_to_list(UID),
    History_command =
        [
         "SELECT * FROM ", ?TABLE_NAME, " WHERE uid=\'",
         UID_string, "\' and unixtime >='", After_date_as_string,
         "' ORDER BY unixtime DESC",
         " LIMIT 500"
        ],
    case generic_router:routing_request(?SQL_Module,
					#sql_query{request=History_command}, 
					?TIME_OUT,
					?ROUTING) of
        {ok, {selected, _, Entries}} ->
            [ history_entry(Entry) || Entry <- Entries ];            
	Other ->
            Event_details = {History_command, Other}, 
	    slog:event(failure, ?MODULE, sql, Event_details),
	    exit({sql_failure, Other})
    end.

history_entry([Login, UID, Unixtime, Action, Details]) ->
    {Login, UID, Unixtime, from_sql_action_details(Action, Details)}.


%%% CLEANUP

delete_old_logs(Days) ->
    Time_threshold = pbutil:unixtime() - Days * 24 * 3600,
    Delete_command =
        [
         "DELETE FROM ", ?TABLE_NAME, " WHERE unixtime<'",
         integer_to_list(Time_threshold),"'"
        ],

    case generic_router:routing_request(?SQL_Module,
					#sql_query{request=Delete_command}, 
					?TIME_OUT,
					?ROUTING) of
        {ok, {updated, N}} ->
            slog:event(trace, ?MODULE, deleted_logs, N),
            ok;
        Error ->
            slog:event(failure, ?MODULE, failed_to_delete, Error),
            nok
    end.

slog_info(failure, ?MODULE, failed_to_delete) ->
    #slog_info{descr="Webuser logs could not be deleted",
               operational="The webuser_of_logs table may be unreachable\n"
               "1. Check pdist::sql_routing\n"
               "2. Ensure webuser_of_logs table has been created"};

slog_info(failure, ?MODULE, sql) ->
    #slog_info{descr="Webuser logs could not be fetched",
               operational="The webuser_of_logs table may be unreachable\n"
               "1. Check pdist::sql_routing\n"
               "2. Ensure webuser_of_logs table has been created"}.
