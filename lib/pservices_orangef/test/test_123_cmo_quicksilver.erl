-module(test_123_cmo_quicksilver).

%% TO DO (20091027):
%%  * "really" check alarm on threashold -> check product test utilities ?
%%  * test SMSs that are sent / not sent -> see pls_call_me
%%  * why do Kenobi tests work sometimes only... ?

-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../eva/include/eva.hrl").
-include("../../oma/include/slog.hrl").
-include("../include/quicksilver.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").
-include("access_code.hrl").

-define(Uid,cmo_quicksilver_user).

-define(NbPs,10).
-define(SQL_SELECT_TIMEOUT, 5000).
-define(SQL_Module, sql_specific).
-define(QCODE,"FIRST01").
-define(QCODE2,"NEXT001").


-record(sql_config, {host, port="", database, 
		     login="possum", 
		     password="possum",
		     module=mysql,
		     options=[]}).

init_period(PeriodNumber,Date) ->
    GregToday = calendar:date_to_gregorian_days(Date),
    Offset = 30,
    
    case PeriodNumber of
	in_first ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - 10),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday + 20),
	    
	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday + Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday + 2 * Offset),
	    
	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + 3 * Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 4 * Offset);
	
	in_second ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - 2 * Offset),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday - Offset),
	    
	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday - 10),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday + 20),
	    
	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 2 * Offset);
	in_third ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - 4 * Offset),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday - 3 * Offset),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday - 2 * Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday - Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday - 10),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 20);
	before_first ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday + 10),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday + Offset + 10 ),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday + 2 * Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday + 3 * Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + 4 * Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 5 * Offset);
	between_1_2 ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - 2 * Offset),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday - Offset ),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday + 10),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday + Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + 2 * Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 3 * Offset);
	between_2_3 ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - 4 * Offset),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday - 3 * Offset ),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday - 2 * Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday - Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 2 * Offset);
	after_last ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - 6 * Offset),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday - 5 * Offset ),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday - 4 * Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday - 3 *Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday - 2 * Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday - Offset);
	period_eve ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday + 1),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday + Offset ),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday + 2 * Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday + 3 *Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + 4 * Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 5 * Offset);
	period_next_day ->
	    StartPeriod11 = calendar:gregorian_days_to_date(GregToday - Offset),
	    EndPeriod11 = calendar:gregorian_days_to_date(GregToday - 1 ),

	    StartPeriod12 = calendar:gregorian_days_to_date(GregToday + 2 * Offset),
	    EndPeriod12 = calendar:gregorian_days_to_date(GregToday + 3 *Offset),

	    StartPeriod13 = calendar:gregorian_days_to_date(GregToday + 4 * Offset),
	    EndPeriod13 = calendar:gregorian_days_to_date(GregToday + 5 * Offset)
    end,
    
    [{{StartPeriod11, {0,0,0}}, {EndPeriod11,    {23,59,59}}},
     {{StartPeriod12, {0,0,0}}, {EndPeriod12,    {23,59,59}}},
     {{StartPeriod13, {0,0,0}}, {EndPeriod13,    {23,59,59}}}].

%% UNIT TESTS
run() ->
    %%%%%%%%% BEGIN CALENDAR MANAGEMENT %%%%%%%%
    test_period(1),
    test_period(2),
    test_period(3),
    
    %%%%%%%%% END CALENDAR MANAGEMENT %%%%%%%%

    %%%%%%%%% BEGIN DATABASE REQUESTS %%%%%%%%
    %% THESE TESTS ASSUME THAT
    %% MYSQL TABLE quicksilver IS CREATED

    test_mysql(unique_codes),
    test_mysql(no_more_codes),

    test_mysql(store_quicksilver_info),
    test_mysql(get_quicksilver_info),

    test_mysql(check_threshold),

    %%%%%%%%%  END DATABASE REQUESTS  %%%%%%%%

    ok.

test_period(1) ->
    {Today,Time} = erlang:localtime(),

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Today's date can be found in the different periods lists.
    %% In the first period only
    Periods1 = 
	[{{StartPeriod11, {0,0,0}}, {EndPeriod11,    {23,59,59}}},
	 {{StartPeriod12, {0,0,0}}, {EndPeriod12,    {23,59,59}}},
	 {{StartPeriod13, {0,0,0}}, {EndPeriod13,    {23,59,59}}}] = init_period(in_first,Today),
    
    %% In the second period only
    Periods2 =
	[{{StartPeriod21, {0,0,0}}, {EndPeriod21,    {23,59,59}}},
	 {{StartPeriod22, {0,0,0}}, {EndPeriod22,    {23,59,59}}},
	 {{StartPeriod23, {0,0,0}}, {EndPeriod23,    {23,59,59}}}] = init_period(in_second,Today),

    %% In the third and last period only
    Periods3 =
	[{{StartPeriod31, {0,0,0}}, {EndPeriod31,    {23,59,59}}},
	 {{StartPeriod32, {0,0,0}}, {EndPeriod32,    {23,59,59}}},
	 {{StartPeriod33, {0,0,0}}, {EndPeriod33,    {23,59,59}}}] = init_period(in_third,Today),

    ListCases1 = [{{Today,Time},Periods1},{{Today,Time},Periods2},{{Today,Time},Periods3},{{Today,Time},[]}],
    ListExpect1 = [{in,{{StartPeriod11, {0,0,0}}, {EndPeriod11,    {23,59,59}}}},
		  {in,{{StartPeriod22, {0,0,0}}, {EndPeriod22,    {23,59,59}}}},
		  {in,{{StartPeriod33, {0,0,0}}, {EndPeriod33,    {23,59,59}}}},
		  out],
    io:format("~n******~nTest svc_quicksilver:in_which_period~nToday's date is present in a given period~n"),
    test(svc_quicksilver,in_which_period,ListCases1,ListExpect1,{0,0});

test_period(2) ->
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% The date can't be found in the different period lists.
    %% It is before the first period of Periods
    {Today,Time} = erlang:localtime(),
    Periods4 = init_period(before_first,Today),
    
    %% It is after the first period, before second period
    Periods5 = init_period(between_1_2,Today),
    
    %% It is after first and second periods, before third period
    Periods6 = init_period(between_2_3,Today),
    
    %% It is after all periods
    Periods7 = init_period(after_last,Today),

    ListCases2 = [{{Today,Time},Periods4},{{Today,Time},Periods5},{{Today,Time},Periods6},{{Today,Time},Periods7}],
    ListExpect2 = [out,out,out,out],
    io:format("~n******~nTest svc_quicksilver:in_which_period~nToday's date is NOT present in any period~n"),
    test(svc_quicksilver,in_which_period,ListCases2,ListExpect2,{0,0});

test_period(3) ->
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Particular cases:
    %% Today is a period's eve
    %% Today is a period's next day
    {Today,Time} = erlang:localtime(),

    %% Eve
    Periods8 = init_period(period_eve,Today),

    %% Next Day
    Periods9 = init_period(period_next_day,Today),

    ListCases3 = [{{Today,Time},Periods8},{{Today,Time},Periods9}],
    ListExpect3 = [out,out],
    io:format("~n******~nTest svc_quicksilver:in_which_period~nToday's date is eve or next day of a period~n"),
    
    test(svc_quicksilver,in_which_period,ListCases3,ListExpect3,{0,0}).

test(Module,Function,[],[], {OK,NOK}=Acc) ->
    Info = atom_to_list(Module)++":"++atom_to_list(Function),
    if NOK>0 ->
           io:format("~p~nFailed, nb of failure ~p~n",[Info,NOK]),
           exit({Info,NOK});
       true ->
           io:format("~nSUCCESS:~n~p~n******~n",[Info]),
           ok
    end;
test(svc_quicksilver,in_which_period,[{Date,Periods}=H1 | ListCases],[H2 | ListExpect], {OK,NOK}=Acc) ->
    case test_unit("svc_quicksilver:in_which_period", H2, svc_quicksilver:in_which_period(Date,Periods)) of
       ok -> test(svc_quicksilver,in_which_period,ListCases,ListExpect, {OK+1,NOK});
       nok -> 
	    io:format("~nParameters:~n~p~n",[{Date,Periods}]),
	    test(svc_quicksilver,in_which_period,ListCases,ListExpect, {OK,NOK+1})
    end.

test_unit(_,A,A) -> ok;
test_unit(Info,A,B) ->
    io:format("~p~nExpected:~n~p~nGot:~n~p~n",[Info,A,B]),
    nok.

test_mysql(unique_codes)->
   io:format("~n******~nTest svc_quicksilver:get_quicksilver_code~n"),
    io:format("Test that each code is unique.~n"),
    dbg(false),
    application:start(pdist),
    application:start(pserver),
    {Pool, Worker} = start_router(users),

    Command1 = ["TRUNCATE TABLE quicksilver"],
    case ?SQL_Module:execute_stmt(Command1, [users], ?SQL_SELECT_TIMEOUT) of
	{updated, _} ->
	    ok;
	RES ->
	    exit({RES})
    end,
     %%INSERT 10 CODES IN DATABASE
    InsertedCodes = ["QS007BT",
		     "QS007C1",
		     "QS007CJ",
		     "QS0088V",
		     "QS008B4",
		     "QS008CT",
		     "QS008DM",
		     "QS008QP",
		     "QS009FG",
		     "QS009KP"
		    ],
    
    FunInsert = fun(Code) ->
		  Command2 = ["INSERT INTO quicksilver "
			     "(id,promo_code) "
			     " VALUES (\"\",\""++Code++"\")"],
		  case insert_code(Command2) of
		      true ->
			  ok;
		      Else ->
			  exit({Else})
		  end
	  end,
    io:format("~nInserting 10 Codes in Database~n"),
    lists:foreach(FunInsert,InsertedCodes),

    io:format("~nLooking forward 10 Codes in Database~n"),
    Pids = launch_ps(?NbPs),
    Codes = receive_response(?NbPs,[]),
    SortedCodes = lists:sort(Codes),
    case verify_codes(SortedCodes) of
	true ->
	    io:format("~nSUCCESS~n******~n"),
	    ok;
	false ->
	    exit({same_code,SortedCodes})
    end,

    FunSelect = fun(Code) ->
		  Command = ["SELECT * FROM quicksilver "
			     "WHERE promo_code = '"++Code++"'"],
		  case select_code(Command) of
		      true ->
			  ok;
		      Else ->
			  exit({Else})
		  end
	  end,
    io:format("~nThose 10 Codes must not be in Database anymore~n"),
    lists:foreach(FunSelect,InsertedCodes),
    io:format("~nSUCCESS~n******~n"),

    stop_router(Pool, Worker);

test_mysql(no_more_codes)->
    io:format("~n******~nTest svc_quicksilver:get_quicksilver_code~n"),
    io:format("Try to get a code, but there is not any in database.~n"),

    application:start(pdist),
    application:start(pserver),
    {Pool, Worker} = start_router(users),

    Command = ["TRUNCATE TABLE quicksilver"],
    case ?SQL_Module:execute_stmt(Command, [users], ?SQL_SELECT_TIMEOUT) of
	{updated, _} ->
	    ok;
	RES ->
	    exit({RES})
    end,
    case svc_quicksilver:get_quicksilver_code() of
	{not_found, Reason} ->
	    io:format("~nNot Found:~n~p~n",[Reason]),
	    ok;
	Else ->
	    exit({Else})
    end,
    io:format("~nSUCCESS~n******~n"),
    stop_router(Pool, Worker);

test_mysql(store_quicksilver_info) ->
    io:format("~n******~nTest svc_quicksilver:store_quicksilver_info~n"),
    io:format("Store information into svcprofiles table.~n"),
    
    application:start(pdist),
    application:start(pserver),
    {Pool, Worker} = start_router([svcprofiles,quicksil]),

    Uid=890000000,

    Session = #session{prof=#profile{uid=Uid}},
    Quicksilver = #quicksilver{code_promo="QS008DM"},

    Command = ["DELETE FROM svcprofiles "
	       "WHERE uid = '"++integer_to_list(Uid)++"' "
	       "AND svc = 'quicksil'"],
    case ?SQL_Module:execute_stmt(Command, [svcprofiles,quicksil], ?SQL_SELECT_TIMEOUT) of
	{updated, _} ->
	    ok;
	RES1 ->
	    exit({RES1})
    end,

    case svc_quicksilver:store_quicksilver_info(Session,Quicksilver) of
	ok ->
	    ok;
	Else ->
	    exit({Else})
    end,
    
    %VERIFY IN SVC_PROFILES TABLE THAT RECORD IS PRESENT.
    case db:lookup_svc_profile(Session, "quicksil") of
	{ok, Data} ->
	    io:format("~nDATA:~n~p~n",[Data]),
 	    ok;
	RES2 ->
	    exit({RES2})
    end,

    io:format("~nSUCCESS~n******~n"),
    stop_router(Pool, Worker);

test_mysql(get_quicksilver_info) ->
    io:format("~n******~nTest svc_quicksilver:get_quicksilver_info~n"),
    io:format("Get information from svcprofile table.~n"),
    
    application:start(pdist),
    application:start(pserver),
    {Pool, Worker} = start_router([svcprofiles,quicksil]),
    
    Uid=890000000,
    Session = #session{prof=#profile{uid=Uid}},
    Quicksilver = #quicksilver{code_promo="QS008DM",
			       date_extraction = erlang:localtime()},
    
    case db:update_svc_profile(Session, "quicksil", Quicksilver) of
	ok ->
	    ok;
	RES ->
	    exit({RES})
    end,
    
    case svc_quicksilver:get_quicksilver_info(Session) of
	{not_found, Error} ->
	    exit({Error});
	{ok, Data} ->
	    io:format("~nDATA:~n~p~n",[Data]),
	    ok
    end,
    io:format("~nSUCCESS~n******~n"),
    stop_router(Pool, Worker);

test_mysql(check_threshold) ->
    io:format("~n******~nTest svc_quicksilver:get_quicksilver_info~n"),
    io:format("Threshold management.~n"),
    
    application:start(pdist),
    application:start(pserver),
    {Pool, Worker} = start_router(users),

    InsertedCodes = ["QS117BT",
		     "QS117C1",
		     "QS117CJ",
		     "QS1188V",
		     "QS118B4",
		     "QS118CT",
		     "QS118DM",
		     "QS118QP",
		     "QS119FG",
		     "QS119KP"
		    ],
    
    FunInsert = fun(Code) ->
		  Command = ["INSERT INTO quicksilver "
			     "(id,promo_code) "
			     " VALUES (\"\",\""++Code++"\")"],
		  case insert_code(Command) of
		      true ->
			  ok;
		      Else ->
			  exit({Else})
		  end
	  end,
    io:format("~nInserting 10 Codes in Database~n"),
    lists:foreach(FunInsert,InsertedCodes),

    ComCount = ["SELECT COUNT(*) FROM quicksilver"],
    case ?SQL_Module:execute_stmt(ComCount, [users], ?SQL_SELECT_TIMEOUT) of
	{selected, _, [[Number]]} ->
	    Num = list_to_integer(Number),
	    Alarm = Num + 5,
	    NoAlarm = Num - 5,

	    standalone_oma:start(),
	    ets:insert(ac_tab, {{env,oma,slog_flush_mode}, mnesia}),
	    ets:insert(ac_tab, {{env,oma,slog_flush_period}, 1000}),

	    %%ALARM WILL BE SENT: THRESHOLD VALUE IS EXCEEDED
	    application:set_env(pservices_orangef,quicksilver_threshold,Alarm),
	    io:format("~nNumber of records in table quicksilver: ~p.~nParameter \"quicksilver_threshold\" equals: ~p~nAlarm will be sent.~n",[Num,Alarm]),
	    svc_quicksilver:check_threshold(),

	    timer:sleep(5000),

	    [{slog_row,{internal,svc_quicksilver,quicksilver_threshold_reached},_,_}] = 
		mnesia:dirty_read(slog_row,{internal,svc_quicksilver,quicksilver_threshold_reached}),
	    %AlarmsE = mnesia:dirty_all_keys(slog_row),
	    %io:format("~n~p~n",[AlarmsE]),
	    io:format("~nAlarm 1 sent OK~n"),

	    ok = mnesia:dirty_delete(slog_row,{internal,svc_quicksilver,quicksilver_threshold_reached}),

	    %%ALARM WILL BE SENT: THRESHOLD VALUE IS REACHED
	    application:set_env(pservices_orangef,quicksilver_threshold,Num),
	    io:format("~nNumber of records in table quicksilver: ~p.~nParameter \"quicksilver_threshold\" equals: ~p~nAlarm will be sent.~n",[Num,Num]),
	    svc_quicksilver:check_threshold(),

	    timer:sleep(5000),

	    [{slog_row,{internal,svc_quicksilver,quicksilver_threshold_reached},_,_}] = 
		mnesia:dirty_read(slog_row,{internal,svc_quicksilver,quicksilver_threshold_reached}),
	    io:format("~nAlarm 2 sent OK~n"),
	    
	    %%ALARM WILL NOT BE SENT: THRESHOLD VALUE IS NOT REACHED
	    application:set_env(pservices_orangef,quicksilver_threshold,NoAlarm),
	    io:format("~nNumber of records in table quicksilver: ~p.~nParameter \"quicksilver_threshold\" equals: ~p~nAlarm will NOT be sent.~n",[Num,NoAlarm]),
	    ok = svc_quicksilver:check_threshold();
	Other ->
	    exit({Other})
    end,

    io:format("~nSUCCESS~n******~n"),
    stop_router(Pool, Worker).

insert_code(Command) ->
    case ?SQL_Module:execute_stmt(Command, [users], ?SQL_SELECT_TIMEOUT) of
	{updated, 1} ->
	    true;
	RES ->
	    RES
    end.

select_code(Command) ->
    case ?SQL_Module:execute_stmt(Command, [users], ?SQL_SELECT_TIMEOUT) of
	{selected, _, []} ->
	    true;
	Else ->
	    Else
    end.

start_router(RouteLabel) when is_atom(RouteLabel)->
    {ok, Pool} = pool_server:start_link({?SQL_Module, [], fun () -> true end}),
    Cfg = #sql_config{host="localhost", port="", database="mobi",
                      login="possum", password="possum"},
    {ok,Worker}=mysql:start_link({sql, Cfg}),
    ok = pool_server:register_worker(?SQL_Module, Worker,
				     [RouteLabel], [{queue, 10}]),
    {Pool, Worker};

start_router(RouteLabel) when is_list(RouteLabel)->
    {ok, Pool} = pool_server:start_link({?SQL_Module, [], fun () -> true end}),
    Cfg = #sql_config{host="localhost", port="", database="mobi",
                      login="possum", password="possum"},
    {ok,Worker}=mysql:start_link({sql, Cfg}),
    ok = pool_server:register_worker(?SQL_Module, Worker,
				     RouteLabel, [{queue, 10}]),
    {Pool, Worker}.

stop_router(Pool, Worker)->
    exit(Pool, kill),
    gen_server:call(Worker, stop, 5000).

launch_ps(0) ->
    [];

launch_ps(Number) when integer(Number) , Number > 0 ->
    Rest = Number - 1,
    Pid = spawn(?MODULE, processus, [self(),0]),
    [Pid]++launch_ps(Rest).

receive_response(0,CodeList) ->
    CodeList;

receive_response(Number,CodeList) when integer(Number), Number > 0 ->
    Rest = Number - 1,
    receive
	{_,Code,_} = Message ->
	    io:format("~n~p~n",[Message]),
	    receive_response(Rest,CodeList++[Code])
    end.

processus(ParentId,ReceivedCode) ->
    timer:sleep(10000),
    {A1,A2,A3} = now(),
    random:seed(A1, A2, A3),
    Rand = round(random:uniform()*10000),
    L1 = integer_to_list(Rand),
    L2 = lists:reverse(L1),
    Time = list_to_integer(L2),
    receive
    after 
	Time ->
	    Code = svc_quicksilver:get_quicksilver_code(),
	    ParentId!{self(),Code,Time}
    end.

verify_codes([]) ->
    true;

verify_codes([Code1|CodesN] = Codes) ->
    case lists:member(Code1,CodesN) of
	true ->
	    false;
	false ->
	    verify_codes(CodesN)
    end.

dbg(true) ->
    dbg:tracer(),
    dbg:p(all,c),
    dbg:tpl(db,[{'_',[],[{return_trace}]}]),
    dbg:tpl(db,build_route,[{'_',[],[{return_trace}]}]),
    dbg:tpl(sql_specific,[{'_',[],[{return_trace}]}]),
    dbg:tpl(test_db,[{'_',[],[{return_trace}]}]),
    ok;
dbg(false) ->
    ok.

%% ONLINE TESTS
-define(DIRECT_CODE,"#123").

online() ->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()),
    [].

test() ->
    [{title, "Test Quicksilver"}] ++
	profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=?ppola})++
        profile_manager:init(?Uid)++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
	test_home_page() ++
	[].

test_home_page() ->
    ["Test Home page QUICKSILVER"]++
   	test_menu()++
  	test_off_period()++
   	test_no_code_available()++
   	test_first_time()++    
  	test_nth_time()++
  	test_next_holiday_period()++
	[].

prisme_counters() ->    
    [{"CM","CQSL", 2}
     ].

test_menu() ->
    lists:append([test_menu(DCL)||DCL <- [?zap_cmo_1h30_v2,?ppola,?DCLNUM_EDITION_QUIKSILVER]]).

test_menu(DCL) ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
	profile_manager:set_dcl(?Uid,DCL)++
	[{title, "Menu Code QuikSilver with DCL : "++ integer_to_list(DCL)}]++
	case DCL of 
	    DCL when DCL==?zap_cmo_1h30_v2 ->
		[{ussd2,
		  [ {send, ?DIRECT_CODE++"*#"},
		    {expect, ".*"},
		    {send,"1"},
		    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger.3:Souscrire options et Bons plans.4:Suivi Conso.5:Avantages Vacances.6:Avantage Decouverte Zap zone.7:Fun.*"}
		   ]}]++test_util_of:close_session();
	    _ ->
		[{ussd2,
		  [ {send, ?DIRECT_CODE++"*#"},
		    {expect, ".*"},
		    {send,"1"},
		    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger.3:Souscrire options et Bons plans.4:Suivi Conso.5:Avantage Decouverte Zap zone.6:Fun.7:Suite.9:Aide"},
		    {send,"7"},
		    {expect,"Menu #123#.1:En ce moment!.2:Davantage & changer de mobile.8:Precedent.9:Aide"},
		    {send,"8"},
		    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger.3:Souscrire options et Bons plans.4:Suivi Conso.5:Avantage Decouverte Zap zone.6:Fun.7:Suite.9:Aide"}
		   ]}]
	end.

test_off_period() ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
    set_period(init_period(before_first,date()))++
	["Date is Off Period"]++
	[{ussd2,
	  [ {send, ?DIRECT_CODE++"*#"},
	    {expect, ".*"},
	    {send,"1"},
	    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger"},
	    {send,"1"},
	    {expect, "Bonjour,.Vous ne pouvez beneficier de votre code de reduction en dehors des periodes de vacances scolaires..1:Mentions legales"},
	    {send,"1"},
	    {expect,"Offre valable sur tous les produits de la marque Quiksilver..Offre valable 2 ans a compter de la souscription du forfait, une seule fois.*1:Suite"},
	    {send,"1"},
	    {expect,"par periode de vacances scolaires et dans la limite de 200E par achat avant reduction..Offre valable sur www.quiksilver-store.com.1:Suite"},
	    {send,"1"},
	    {expect,"et dans les magasins Quiksilver participants \\(liste sur http://quiksilver-europe.com/orange/\\) avec le code promotionnel communique a l'abonne"
	     "..1:Suite"},
	    {send,"1"},
	    {expect,"Offre non cumulable avec toute autre promotion en cours..Offre valable sous reserve de rester abonne au forfait bloque Zap 1h30."}
	   ]}]++
	[].

test_no_code_available() ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
    set_period(init_period(in_first,date()))++
	empty_svcprofile()++
	empty_quicksilver()++
	["No code available"]++
	[{ussd2,
	  [ {send, ?DIRECT_CODE++"*#"},
	    {expect, ".*"},
	    {send,"1"},
	    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger"},
 	    {send,"1"},
 	    {expect, "Service indisponible..Merci de vous reconnecter ulterieurement."}
	   ]}]++
	[].

test_first_time() ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
    set_period(init_period(in_first,date()))++
	empty_svcprofile()++
        insert_one_code(?QCODE)++
	["First time asking for code"]++
	[{ussd2,
	  [ {send, ?DIRECT_CODE++"*#"},
	    {expect, ".*"},
	    {send,"1"},
	    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger"},
 	    {send,"1"},
 	    {expect, "Le code pour beneficier de 20% de reduction sur Quiksilver.fr et dans les boutiques participantes est le : "++?QCODE},
	    {send,"1"},
	    {expect, "Ce code reste disponible a chaque fois que vous vous connectez. Vous allez recevoir un SMS avec la liste des boutiques."}
	   ]}]++
	[].

test_nth_time() ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
%% 	set_period(init_period(in_first,date()))++
%%  	update_profile(date(),?QCODE)++
	["Nth time asking for code"]++
	[{ussd2,
	  [ {send, ?DIRECT_CODE++"*#"},
	    {expect, ".*"},
	    {send,"1"},
	    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger"},
 	    {send,"1"},
 	    {expect, "Le code pour beneficier de 20% de reduction sur Quiksilver.fr et dans les boutiques participantes est le :."++?QCODE++".1:Mentions legales"}
	   ]}]++
	[].
test_next_holiday_period() ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="2011P"})++
    set_period(init_period(in_first,date()))++
	update_profile("NOTSHOW",remove3months({date(),time()}))++
        insert_one_code(?QCODE2)++
	["Asking for code on next holiday period"]++
	[{ussd2,
	  [ {send, ?DIRECT_CODE++"*#"},
	    {expect, ".*"},
	    {send,"1"},
	    {expect, "Menu #123#.1:Code Quicksilver.2:Recharger"},
 	    {send,"1"},
 	    {expect, "Le code pour beneficier de 20% de reduction sur Quiksilver.fr et dans les boutiques participantes est le : "++?QCODE2},
	    {send,"1"},
	    {expect, "Ce code reste disponible a chaque fois que vous vous connectez. Vous allez recevoir un SMS avec la liste des boutiques."}
	   ]}]++
	[].
set_period(Periods)->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,application,
  		    set_env,[pservices_orangef,commercial_date_cmo,[{plan_zap,Periods}]]]}
      ]}].

empty_svcprofile() ->
    [{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM svcprofiles_v2_quicksil\""}]}].
empty_quicksilver() ->
    [{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM quicksilver\""}]}].

insert_one_code(Code) ->
[{shell, [{send, "mysql -u possum -ppossum mobi -B -e "
           "\"INSERT INTO quicksilver (id,promo_code) "
           " VALUES ('','"++Code++"')\""}]}].

update_profile() ->
    update_profile("QSTOTO1",erlang:localtime()).

update_profile(Code,Date) ->
    [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,?MODULE,
		     update_profile_rpc,[profile_manager:imsi_by_uid(?Uid),Code,Date]]}
       ]}].

update_profile_rpc(IMSI,Code,Date) ->
    Prof=db:lookup_profile({imsi,IMSI}),
    db:update_svc_profile(#session{prof=Prof},
                          "quicksil",
                          #quicksilver{code_promo = Code,
                                       date_extraction=Date}).

remove3months(Date) ->
    TodaySec=calendar:datetime_to_gregorian_seconds(Date),
    WasSec=TodaySec-60*60*24*31*3,
    {DateWas,_} = calendar:gregorian_seconds_to_datetime(WasSec),
    DateWas.
