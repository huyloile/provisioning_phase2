-module(test_mqseries).
-export([run/0,online/0,send/3]).

-export([ping_send/0,ping_expect/1]).

-define(QMNGR, "test.queue.manager").
-define(QUEUE_IN, "TEST_QUEUE_IN").
-define(QUEUE_OUT,"TEST_QUEUE_OUT").
-define(CLEAR_TIME, 10000).
-define(TABLE,ping).
-define(MESSAGE,"Test message longueur 150                                                                                                                          Fin                                                                                                                                                                                                                                                                                                            ").

-define(TIMEOUT, 5000).
-include("../../pfront_orangef/include/mqseries.hrl").
-include("../../pfront/include/pfront.hrl").

ping_send() ->
    [[{Send,_}]] = ets:match(?TABLE,'$1'),
    Send.

ping_expect(Text) -> 
    case ets:match(?TABLE,'$1') of
	[[{_,Text}]] -> ok;
	_ -> exit({ping,{expect,"no_ping"},{preceive,{get,"ping"}}})
    end.

online() ->
    ok.


run() ->
    case file:read_file_info("/opt/mqm/inc/cmqc.h") of
	{error,enoent}  ->
	    io:format("MQSeries is not installed: No test can be running");
	_ ->
	    make_test()
    end.


make_test() ->
    init_mq(),
    PWD = os:cmd("pwd"),
    PWD2 = string:substr(PWD,1,length(PWD) -1 ),
    os:cmd("runmqsc " ++ ?QMNGR ++ " < " ++ PWD2 ++ "/mqseries/init.txt"),
    ets:new(?TABLE,[ordered_set,public,{keypos,1},named_table]),
    clear_queue(),
    Default_CFG = #mqseries_config{type=mqseries,
				   put={?QUEUE_OUT,?QMNGR,"8208"},
				   get={?QUEUE_IN,?QMNGR,"8193"},
				   navail=2
				  } ,
    bad_mngr_put(),
    io:format("ok for bad mngr put~n"),
    bad_mngr_get(),
    io:format("ok for bad mngr get~n"),
    bad_queue_put(),
    io:format("ok for bad queue put~n"),
    bad_queue_get(),
    io:format("ok for bad queue get~n"),
    {ok,_}  = connect(Default_CFG,mq1),
    ok = no_response(),
    io:format("ok for no response ~n"),
    mqseries_server:request(mq1,stop,1000),
    clear_queue(),
%%% loop on the same queue	
    CFG2 = #mqseries_config{type=mqseries,
			    put={?QUEUE_OUT,?QMNGR,"8208"},
			    get={?QUEUE_OUT,?QMNGR,"8193"},
			    navail=2
			   },
    {ok,_} = connect(CFG2,mq2),
    ok = response(),
    io:format("ok for response~n"),
    mqseries_server:request(mq2,stop,1000),
    clear_queue(),
    {ok,Id}  = connect(Default_CFG,mq1),
    ok = asynchronous_request(Id),
    io:format("ok for asynchronous ~n"),
    mqseries_server:request(mq1,stop,1000),
    clear_queue(),
    {ok,_}  = connect(CFG2,mq2),
    ok = big_message(),
    io:format("ok for big_message, terminate with warning 2079 ~n"),
%%%% big truncated message was deleted from queue but no send to erlang (see option truncated)
%%%% ---> so no need cleaning
    ok = good_ping(),
    io:format("ok for ping ~n"),
    clear_queue(),
    ok = bad_ping(),
    io:format("ok for bad ping ~n"),
    wait(6000),
    ok = not_clean(),
    io:format("ok for clean on ping ~n"),

    %% testing without reponse requests %%
    %% in/out interface
    {ok,_}  = connect(Default_CFG,mq4),
    ok = request_no_resp(),
    io:format("ok for request_no_resp ~n"),
    mqseries_server:request(mq4,stop,1000),
    clear_queue(),
    %% in only interface, no_resp request
    CFG3 = #mqseries_config{type=mqseries,
			    put={?QUEUE_OUT,?QMNGR,"8208"},
			    navail=1
			   },
    {ok,_}  = connect(CFG3,mq4),
    ok = request_no_resp(),
    ok = request_no_resp(),
    io:format("ok for 2 request_no_resp ~n"),
    mqseries_server:request(mq4,stop,1000),
    clear_queue(),

    charge(),
    quiescing(),
    ok.



init_mq() ->
    os:cmd("crtmqm -q " ++ ?QMNGR),
    os:cmd("strmqm "++ ?QMNGR).

wait(Time) ->
    receive
	nothing -> ok
    after Time ->
	    ok
    end.

bad_mngr_put() ->
    CFG = #mqseries_config{type=mqseries,
			   put={?QUEUE_OUT,"no_valid","8208"},
			   get={?QUEUE_IN,?QMNGR,"8193"},
			   navail=1},
    {error,{init_put_error,Error}} = connect(CFG,mq1),
    case Error of
	{error,2058} -> ok;
	Err -> exit({bad_return_value_for_put,Err})
    end.

bad_mngr_get() ->
    CFG = #mqseries_config{type=mqseries,
			   put={?QUEUE_OUT,?QMNGR,"8208"},
			   get={?QUEUE_IN,"no_valid","8193"},
			   navail=1},
    {error,{init_get_error,Error}} = connect(CFG,mq1),
    case Error of
	{error,2058} -> ok;
	Err -> exit({bad_return_value_for_get,Err})
    end.

bad_queue_put() ->
    CFG = #mqseries_config{type=mqseries,
			   put={"no valid",?QMNGR,"8208"},
			   get={?QUEUE_IN,?QMNGR,"8193"},
			   navail=1},
    {error,{init_put_error,Error}} = connect(CFG,mq1),
    case Error of
	{error,2085} -> ok;
	Err -> exit({bad_return_value_for_put,Err})
    end.

bad_queue_get() ->
    CFG = #mqseries_config{type=mqseries,
			   put={?QUEUE_OUT,?QMNGR,"8208"},
			   get={"no_valid",?QMNGR,"8193"},
			   navail=1},
    {error,{init_get_error,Error}} = connect(CFG,mq1),
    case Error of
	{error,2085} -> ok;
	Err -> exit({bad_return_value_for_get,Err})
    end.

connect(CFG,Name) ->
    mqseries_server:start_link_test(CFG,Name).


no_response() ->
    Req = #mqseries_request{send="test3"},
    case catch (mqseries_server:request(mq1,Req,1000)) of
	{'EXIT',{timeout,{gen_server,call,_}}} -> ok;
	Err -> exit({bad_from_no_response,Err})
    end,
    ok.

response() ->
    Req = #mqseries_request{send="test2"},
    {ok,"test2"} = mqseries_server:request(mq2,Req,1000),
    ok.

asynchronous_request(Id) ->
    Req_1 = "test1",
    Req_2 = "test2",
    spawn(?MODULE,send,[self(),Req_1,Id]),
    spawn(?MODULE,send,[self(),Req_2,Id]),
    wait(3000),
    os:cmd("/opt/mqm/samp/bin/amqsput " ++ ?QUEUE_IN++" " ++ ?QMNGR ++ " < mqseries/test1.txt"),
    os:cmd("/opt/mqm/samp/bin/amqsput " ++ ?QUEUE_IN++ " " ++ ?QMNGR ++ " < mqseries/test2.txt"),
    ok.

send(From,Message,Server) ->
    Req = #mqseries_request{send=Message},
    {ok,Message} = mqseries_server:request(Server,Req,5000).


big_message() ->
    Message = lists:duplicate(10000,"a"),
    Req = #mqseries_request{send=Message},
    case catch mqseries_server:request(mq2,Req,20000) of
	{'EXIT',Err2} -> ok;
	Err -> Err
    end.

good_ping() ->
    CFG3 = #mqseries_config{type=mqseries,
			    put={?QUEUE_OUT,?QMNGR,"8208"},
			    get={?QUEUE_OUT,?QMNGR,"8193"},
			    navail=2,
			    ping=?MODULE},
    ets:delete_all_objects(?TABLE),
    ets:insert(?TABLE,{"ping","ping"}),
    {ok,_} = connect(CFG3,mq2),
    mqseries_server:request(mq2,stop,1000),
    ok.


bad_ping() ->
    CFG3 = #mqseries_config{type=mqseries,
			    put={?QUEUE_OUT,?QMNGR,"8208"},
			    get={?QUEUE_OUT,?QMNGR,"8193"},
			    navail=2,
			    ping=?MODULE},
    ets:delete_all_objects(?TABLE),
    ets:insert(?TABLE,{"ping","no_ping"}),
    {error,{not_ok,{ping_error,
		   {ping,{expect,"no_ping"},{preceive,{get,"ping"}}}}}} =
	connect(CFG3,mq3),
    ok.

not_clean() ->
    X = os:cmd("/opt/mqm/samp/bin/amqsput " ++ ?QUEUE_OUT  ++ " " ++ ?QMNGR ++ " < mqseries/test1.txt"),
    Res = os:cmd("runmqsc " ++ ?QMNGR ++ " < mqseries/state.txt"),
    CFG3 = #mqseries_config{type=mqseries,
			    put={?QUEUE_OUT,?QMNGR,"8208"},
			    get={?QUEUE_OUT,?QMNGR,"8193"},
			    navail=2,
			    ping=?MODULE},
    ets:delete_all_objects(?TABLE),
    ets:insert(?TABLE,{"ping","ping"}),
    {error,{not_ok,{ping_error,{queue_not_clean,R}}}} = connect(CFG3,mq3),
    ok.

quiescing() ->
%%% tue mq
    os:cmd("endmqm -i "++ ?QMNGR),
    CFG = #mqseries_config{type=mqseries,
			   put={?QUEUE_IN,?QMNGR,"8208"},
			   get={?QUEUE_IN,?QMNGR,"8193"},
			   navail=1},


    {error,{init_put_error,Error}} = connect(CFG,mq2),
    case Error of
	{error,2059} -> ok;
	Err -> exit({bad_return_value_for_put,Err})
    end.



clear_queue() ->
    wait(?CLEAR_TIME),  %%%% waiting to really clean queue, else "In Use"
    X = os:cmd("runmqsc " ++ ?QMNGR ++ " < mqseries/clear_queue.txt"),
    io:format("X ~p\n",[X]),
    ok.


charge() ->
%%%% 100 000 requests in 30/40 seconds
    CFG = #mqseries_config{type=mqseries,
			   put={?QUEUE_OUT,?QMNGR,"8208"},
			   get={?QUEUE_OUT,?QMNGR,"8193"},
			   navail=1,
			   ping=nok},
    {ok,_} = connect(CFG,mq3),
    Time = pbutil:unixmtime(),
    request(100000),
    Diff = pbutil:unixmtime() - Time,
    io:format("100 000 requests in ~p milliseconds\n",[Diff]).


request(0) -> ok;
request(N) ->
    TEST = ?MESSAGE,
    Req = #mqseries_request{send=TEST},
    {ok,TEST} =  mqseries_server:request(mq3,Req,3000),
    request(N-1).

request_no_resp() ->
    Req = #mqseries_request{send="no_resp",expect_resp=false},
    mqseries_server:request(mq4,Req,3000).
