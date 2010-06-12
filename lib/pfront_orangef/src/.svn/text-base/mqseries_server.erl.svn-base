-module(mqseries_server).
-export([start_link/1,  start_link_test/2, connect/1]).

%%%%%%%%%%%%%%%%%% API MQSeries %%%%%%%%%%%%%%%%%%%%%%%
%% if applicative ping is different ,functions ping_send/0 and ping_expect/1
%% have to be exported from Module
%% ping_send/0 create text which have to be send
%% ping_expect/1 receive data from gen_server , analyse it and returns ok or 
%% exit with Reason
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([init/1,handle_call/3,handle_cast/2,handle_info/2,code_change/3,
	 terminate/2]).

-export([request/3]).

%% Exports for behaviour gen_server
-behaviour(gen_server).

-define(SERVER_NAME,  mqseries_srv).
-define(INIT_TIMEOUT, 3000).
-define(QUERY_TIMEOUT, 60000).
-define(RECONNECT_TIMEOUT,5000).
%% An ID is used to associate a response to a request, it is sent with the 
%% request and can be found in the response.
%% The DEFAULT_ID defined here, matches all responses, and can therefore 
%% retrieve any message from the queue
-define(DEFAULT_ID,<<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>).

-record(mqseries, {put, get, navail=1, pending ,queue , check}).

-include("../../pfront_orangef/include/mqseries.hrl").
-include("../../pfront/include/pfront.hrl").

%% +type request(atom(),string(),integer()) -> ok | {ok, string()}.
request(Srv, Req, Time) ->
    gen_server:call(Srv,Req,Time).

%% +type start_link(interface()) -> gs_start_result().
start_link(Interface) ->
    gen_server:start_link(?MODULE, Interface, []).

%% +type connect(#mqseries_config{}) -> gs_start_result().
%%%% NOTE : used only for testing
start_link_test(CFG,Name) ->
    gen_server:start_link({local,Name},?MODULE, CFG, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type ping(#mqseries{},nok|module(),int()) -> ok.
ping(_, nok,_) -> ok;
ping(#mqseries{}=State, Module, PingTimeout) ->
    case catch do_ping(State, Module, PingTimeout) of
	{'EXIT',E} ->
	    slog:event(warning,?MODULE,ping_error,E),
	    terminate(ping_error,State),
	    {not_ok, {ping_error,E}};
	ok -> ok;
	Else -> 
	    slog:event(warning,?MODULE,ping_error_unexpected,Else),
	    terminate(ping_error_unexpected,State),
	    {not_ok, {ping_error_unexpected,Else}}
    end.

%% +type do_ping(#mqseries{},nok|module(),int()) -> ok | 
%%                                  exit({queue_not_clean,term()}) |
%%                                  exit({ping_bad_answer,term()}) |
%%                                  exit({bad_ack_from_put,term()}).
do_ping(#mqseries{put=Put, get=Get, check=Check}, Module, PingTimeout) ->
%%%%% clear queue before send new message --> don't clear if queue is sharing
    if Check == false ->
	    Clear = ?DEFAULT_ID,
	    pbutil:send_port(Get,term_to_binary({200,Clear})),
	    case catch recv(Get,any,200) of
		{'EXIT',_} -> ok; %% queue is empty
		Message -> exit({queue_not_clean,Message})
	    end;
       true ->
	    ok
    end,
    Send = apply(Module,ping_send,[]),
    pbutil:send_port(Put, "E"),
    pbutil:send_port(Put, Send),
    case catch recv(Put) of
	{put,0,MsgId} ->
	    Msgid2 = if Check -> MsgId;
			true -> ?DEFAULT_ID
		     end,
	    pbutil:send_port(Get,term_to_binary({PingTimeout,Msgid2})),
	    case catch recv(Get,PingTimeout) of
		{'EXIT',E} -> exit({ping_no_answer,E});
		{get,Expect} -> apply(Module,ping_expect,[Expect]);
		Bad -> exit({ping_bad_answer,Bad})
	    end;
	Recv -> exit({bad_ack_from_put,Recv})
    end.

%%%% init connexion for MQ
%% +type init(mqseries_config()) ->
%%                {ok,state()}|{ok, state(),0} | exit(term()).
%%%% NOTE : used only for testing
init(#mqseries_config{ping=Ping,ping_timeout=PingTimeout}=CFG) ->
    put(interface, #interface{name_node = {test_interface, name@node}}),
    case connect(CFG) of
	{ok, State} = Res->
	    case ping(State,Ping,PingTimeout) of
		ok -> Res;
		Else -> exit(Else)
	    end;
	{stop, Err, _State} ->
	    {stop, Err};
	Error_State ->
	    Error_State
    end;	     

init(I) ->
    put(interface,I),
    {ok, #mqseries{put=connect, get=connect, queue=queue:new(), navail=0},2}.


%% +type connect(mqseries_config()) -> {ok,state()} | {stop, term(),state()}.
connect(#mqseries_config{type=mqseries, navail=Nb, md=Md, check=Check}=CFG) ->
    Cmd = build_put_command(CFG),
    Pid = open_port({spawn,Cmd},
		    [{packet,4},binary,use_stdio,exit_status,
		     {env,[{"LD_ASSUME_KERNEL","2.2.5"}]}]),
    case catch recv(Pid,?INIT_TIMEOUT) of
	{'EXIT',E} -> 
	    {stop, {init_put_error,E},#mqseries{}};
	"ok" -> 
	    connect_get(Pid,Md,CFG,Nb,Check);
	Other -> 
	    {stop, {init_put_error,Other},#mqseries{}}
    end;
%% for tests
connect(#mqseries_config{type=erlang_process, put=Put, get=none}=CFG) ->
    {ok, State =#mqseries{get     = none,
			  put     = pbutil:whereis_name(Put),
			  queue   = queue:new(),
			  navail  = CFG#mqseries_config.navail,
			  check   = false}};
connect(#mqseries_config{type=erlang_process, put=Put, get=Get}=CFG) ->
    case catch pbutil:whereis_name(Get) of
	{'EXIT',_} ->
	    {stop, no_fake, #mqseries{}};
	_ ->
	    State =#mqseries{get     = pbutil:whereis_name(Get),
			     put     = pbutil:whereis_name(Put),
			     pending = queue:new(),
			     queue   = queue:new(),
			     navail  = CFG#mqseries_config.navail,
			     check   = false},
	    {ok,State}
    end.

%% +type connect_get(Pid::pid(),Md::term()) -> {ok,state()} | {stop, term()}.
connect_get(Pid,Md,CFG,Nb,Check) ->
    Add_Md = CFG#mqseries_config.md,
    Fields = record_info(fields, md),
    Md2 = pbutil:update_record(Fields, #md{}, Add_Md),
    %% Send param
    pbutil:send_port(Pid,term_to_binary(Md2)),
    State = #mqseries{put=Pid},
    case CFG#mqseries_config.get of
	{Queue2, Manager2,Option2} ->
	    Cmd2 = build_get_command(CFG),
	    Pid2= open_port({spawn,Cmd2},
			    [{packet,4},binary,use_stdio,exit_status,
			     {env,[{"LD_ASSUME_KERNEL","2.2.5"}]}]),
	    case catch recv(Pid2,?INIT_TIMEOUT) of
		{'EXIT',E} -> {stop, {init_get_error,E}};
		"ok" -> 
		    State1 = 
			State#mqseries{get     = Pid2,
				       pending = queue:new(),
				       queue   = queue:new(),
				       navail  = Nb,
				       check   = Check
				      },
		    {ok,State1}; % request expects response
		Other -> {stop, {init_get_error,Other}, State}
	    end;
	_ ->
	    State1 = 
		State#mqseries{pending = queue:new(),
			       queue   = queue:new(),
			       navail  = Nb,
			       check   = Check
			      },
	    {ok, State1} % request without response
    end.

%% +type handle_call(#mqseries_request{}|stop,pid(),state()) -> 
%% process(state()) | {stop, normal, ok, state()}.
handle_call(#mqseries_request{} = Mq, From, #mqseries{queue=Q}=State) ->
    Req = {Mq, From},
    State1 = State#mqseries{queue=queue:in(Req,Q)},
    process(State1);

handle_call(stop, _, State) ->
    %% Don't kill the port program here; this will be done in terminate/2.
    %% If we send to a dead port, we will get an uncatchable 'epipe' error,
    %% and that could kill the caller (possibly a supervisor init function).
    %% Port = State,
    %% pbutil:send_port(Port, "T"),
    {stop, normal, ok, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% If the window is full, wait for replies from the MQ server.

%% +type process(state()) -> wait_replies() | send_request().
process(#mqseries{pending=P,navail=0}=State) ->
    wait_replies(State, P);

%%%% If the window is not full, check whether we have requests.

process(#mqseries{queue=Q, pending=P, navail=N}=State) ->
    case queue:out(Q) of
	{empty, _} ->
	    wait_replies(State, P);
	{{value,{Req,From}}, Q1} ->
	    Deadline = pbutil:unixmtime() + Req#mqseries_request.timeout,
	    State1 = State#mqseries{queue=Q1, navail=N-1},
	    send_request(State1, Req, From, Deadline)
    end.

%% +type wait_replies(state(), sock(), queue(From)) ->
%%   {noreply, state()} 
%% | {noreply, state(), integer()}
%% | {stop, reply_timeout, state()}.
wait_replies(State, P) ->
    case queue:out(P) of
	{empty, _} ->
	    {noreply, State};
	{{value,{_,Deadline,_,_}}, _} ->
	    case Deadline - pbutil:unixmtime() of
		Timeout when Timeout > 0 ->		    
		    {noreply, State, Timeout};
		_ ->
		    slog:event(warning, ?MODULE, reply_timeout),
		    notify_error(P, timeout),
		    terminate(timeout,State),
		    {stop,reply_timeout,State}
	    end
    end.

%% +type send_request(#mqseries{},#mqseries_request{},pid(),integer()) ->
%% process() | {reply, term(), state()} | 
%% exit({unexpected_data_from_mqseries_port, term()}).
send_request(#mqseries{pending=P, put=Port, navail=N}=State, 
	     #mqseries_request{send=RawReq}=Req, From, Deadline) ->
    T = pbutil:unixmtime(),
    pbutil:send_port(Port, "E"),
    pbutil:send_port(Port, RawReq),
    case catch recv(Port) of
	{put,0,Id} ->
	    State1 = 
		case Req#mqseries_request.expect_resp of
		    true ->
			QueueOut = queue:out(P),
			P1 = queue:in({From,Deadline,Id,T}, P),
			State_ = State#mqseries{pending=P1},
			case QueueOut of
			    {empty,_} ->
				%% no answer is being currently waited for, 
				%% extract the next one
				get_next_resp(State_#mqseries.check,P1,
					      State_#mqseries.get);
			    _ ->
				ok
			end,
			State_;
		    false ->
			gen_server:reply(From, ok),
			State#mqseries{navail = N +1}
		end,
	    process(State1);
	{'EXIT',E} ->
	    P2 = queue:in({From,Deadline,?DEFAULT_ID,T}, P),
	    State2 = State#mqseries{pending=P2},
	    {reply, {error,E}, State2};
	Other ->
	    exit({unexpected_data_from_mqseries_port, Other})
    end.


%% +type handle_cast(term(), state()) -> gs_hcast_result(state()).
handle_cast(Msg, State) ->
    pbutil:badmsg(Msg, ?MODULE),
    {noreply, State}.

%% +type handle_info(term(), state()) -> state().
handle_info(timeout,#mqseries{get=connect, put=connect}=Old) ->
    I = get(interface),
    {Name,_Node} = I#interface.name_node,
    CFG = I#interface.extra,
    slog:event(trace, ?MODULE, {Name,connecting}),
    case connect(CFG) of 
	{ok, State} -> %%%%% have to ping if necessary to register interface
	    case ping(State,CFG#mqseries_config.ping,
		 CFG#mqseries_config.ping_timeout) of
		ok ->
		    pfront_app:interface_up(Name),
		    {noreply, State};
		{not_ok,Error} ->
		    {noreply, State, ?RECONNECT_TIMEOUT};
		Else ->
		    {stop,{ping_error,Else},State}
	    end;
	X -> X
    end;

handle_info(timeout,State) ->
    process(State);

handle_info({Port,{data,Data}},#mqseries{get=Port, pending=P,navail=N}=State)->
    %% We have received a message from MQ
    T1 = pbutil:unixmtime(),
    Data2 = binary_to_term(Data),
    case Data2 of
	{get,Data3} ->
	    case queue:out(P) of
		{empty,_} ->
		    %% but we were not expecting one...
		    exit({reply_without_request,State, Data3});
		{{value,{From,Deadline,_,T0}}, P1} ->
		    I = get(interface),
		    {Name,_Node} = I#interface.name_node,
		    slog:stats(stats, ?MODULE, {response_time, Name}, T1 - T0),
		    gen_server:reply(From, {ok,Data3}),
		    State1 = State#mqseries{pending = P1, 
					    navail  = N +1},
		    get_next_resp(State1#mqseries.check, P1,
				  State1#mqseries.get),
		    process(State1)
	    end;
	{warning,Code} ->
	    slog:event(failure,?MODULE,handle_get_warning,Code),
	    {stop, {handle_get_warning,Code}, State};
	{error,Code} ->
	    slog:event(internal,?MODULE,handle_get_error,Code),
	    {stop, {handle_get_error,Code}, State};	
	Error ->
	    slog:event(internal,?MODULE,unexpected_from_get,Error),
	    {stop, {unexpected_from_get,Error}, State}
    end;

handle_info({Port,{exit_status,Code}}, State) ->
    %% The DB driver just died.
    {stop, {port_exited,Code}, State}.

%% +type code_change(Old, state(), Extra) -> {ok, state()}.
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% +type terminate(term(), state()) -> ok.
terminate(Reason, State) ->
    %%io:format("terminating with state ~p~n",[State]),
    Port_p = State#mqseries.put,
    catch (pbutil:send_port(Port_p, "T")),
    Port_g = State#mqseries.get,
    catch (pbutil:send_port(Port_g, "T")),
    ok.

%% +type recv(pid()) -> term() | exit({port_exited,int()} |
%%                                          {binary_to_term,term()} |
%%                                          {recv_timeout}).
recv(Port) ->
    recv(Port,data,?QUERY_TIMEOUT).

%% +type recv(pid(),TimeOut::int()) -> term() | 
%%                                     exit({port_exited,int()} |
%%                                          {binary_to_term,term()} |
%%                                          {recv_timeout}).
recv(Port,Timeout) ->
    recv(Port,data,Timeout).

%% +type recv(pid(),data|any,TimeOut::int()) -> term() |
%%                                              exit({port_exited,int()} |
%%                                              {binary_to_term,term()} |
%%                                              {recv_timeout}).
%%%% data -> expects a message {data,X} and returns binary_to_term(X) 
%%%% any -> expects any message, and returns it (can be binary)
recv(Port,data,Timeout) ->
    receive
	{Port, {data, X}} -> 
	    case catch binary_to_term(X) of
		{'EXIT',E} -> exit({binary_to_term,E});
		Y -> Y
	    end;
	{Port, {exit_status,Code}} -> exit({port_exited,Code})
    after Timeout -> exit(recv_timeout)
    end;
recv(Port,any,Timeout) ->
    receive
	{Port, Message} -> 
	    Message;
	{Port, {exit_status,Code}} -> exit({port_exited,Code})
    after Timeout -> exit(recv_timeout)
    end.

%% +type notify_error(queue(),term()) -> [true].
notify_error(Q, Error) ->    
    F = fun ({From,Deadline,_,_}) -> 
		catch gen_server:reply(From, {error,Error})
	end,
    lists:foreach(F, queue:to_list(Q)).

%% +type get_next_resp(boolean(),queue(),port()) -> ok | pbutil:send_port().
get_next_resp(Check,Pending, Port) ->
    case queue:out(Pending) of
	{empty,_} ->
	    %%%% No resp waited for, ok
	    ok;
	{{value,{_, Deadline, MsgId, _}},_} ->
	    Interval = Deadline - pbutil:unixmtime(),
	    if Check ->
		    %%%% get resp with specific ID
		    pbutil:send_port(Port,term_to_binary(
					    {Interval,MsgId}));
	       true ->
		    %%%% get resp with any ID
		    pbutil:send_port(Port,term_to_binary(
					    {Interval,?DEFAULT_ID}))
	    end
    end.

%% +type build_command(mqseries_config()) -> string().
build_put_command(#mqseries_config{put={Queue, Manager,Option}}) ->
    Cmd = io_lib:format("~s/~s/mqseries_port.out '~s' '~s' '~s'", 
			[ code:priv_dir(pfront_orangef), pbutil:arch(),
			  Queue, Manager,Option]),
    lists:flatten(Cmd);
build_put_command(#mqseries_config{put={Queue, Manager,Option,User}}) ->
    Cmd = io_lib:format("~s/~s/mqseries_port.out '~s' '~s' '~s' '~s' ", 
			      [ code:priv_dir(pfront_orangef), pbutil:arch(),
				Queue, Manager,Option,User]),
    lists:flatten(Cmd).

build_get_command(#mqseries_config{get={Queue, Manager,Option}}) ->
    Cmd = io_lib:format("~s/~s/mqseries_port_get.out '~s' '~s' '~s'", 
			[ code:priv_dir(pfront_orangef), pbutil:arch(),
			  Queue, Manager,Option]),
    lists:flatten(Cmd).
