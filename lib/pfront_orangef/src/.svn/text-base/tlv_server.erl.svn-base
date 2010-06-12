-module(tlv_server).

%% Client API


%% Server
-export([start_link/1, init/1]).

-behaviour(gen_server).
-export([init/1, handle_call/3,  handle_info/2, 
	 code_change/3, handle_cast/2, terminate/2]).
-export([request/4]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-include("../include/tlv.hrl").
-include("../../pfront/include/pfront.hrl").

%% +type start_link(interface()) -> gs_start_result().

start_link(#interface{type=tlv, name_node={Name,_Node}}=Interface) ->
    %% We don't register as Name until the connection is established.
    gen_server:start_link(?MODULE, Interface, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Request Use by Services                 %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% module qui envoie et recoie les requêtes tlv
request(SRV,ID,Func,Args)->
    tlv_request(SRV,tlv_encodage:encode_packet(ID,Func,Args)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type tlv_request(pid(), request:binary()) -> [term()].
%%%% Selects a server, sends the request, parses the response.

tlv_request(SRV, Request) ->
    slog:event(trace, ?MODULE, tlv_request, {SRV, Request}),
    case catch tlv_do_request(SRV, Request) of
	{'EXIT', E} -> {error, E};
	Res -> Res
    end.

tlv_do_request(SRV, Request) ->
    T0 = pbutil:unixmtime(),
    %% Twice the TLV server's timeout (covers erlang overhead).
    Timeout = pbutil:get_env(pfront_orangef, tlv_response_timeout) * 2,
    GSReq = {tlv_request, Request},
    {ok, Line} = gen_server:call(SRV, GSReq, Timeout),
    slog:delay(perf, ?MODULE, response_delay, T0),
    %% Now check whether the reply matches one of the expected formats.
    decode_response_tlv(Line).

decode_response_tlv(Line)->
    case catch tlv_encodage:decode_packet(Line) of
	{'EXIT',_} ->
	    error_in_decodage;
	{ok , L }  ->
	    L;
	E ->
	    io:format("Unknow Response in Decode_TLV : ~n~p",[E])
    end.
	    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +deftype item() = { Client::pid(), Prefix::string(), To::unix_mtime() }.

%% +deftype state() =
%%     #state{port::pid(), q::queue(item()), n::integer()}.

-record(state, {port, q, n}).

%% +type init(interface()) -> {ok, state()}.

init(I) ->
    put(interface, I),
    %% init/1 should not block. Therefore we return a special state
    %% with no port yet, and we cause it to timeout immediately.
    {ok, #state{port=connect, q=queue:new(), n=0}, 0}.

connect({x25port, Options, Addr}) ->
    Program = io_lib:format("~s/~s/x25port.out ~s ~s",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr ]),
    open_port({spawn, lists:flatten(Program)}, [binary,exit_status]);

connect({fsx25port, Options, Addr}) ->
    Program = io_lib:format("~s/~s/fsx25port.out ~s ~s",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr ]),
    io:format("Spawning ~s~n", [Program]),
    open_port({spawn, lists:flatten(Program)}, [binary,exit_status]);

connect({tcpport, Options, Addr, Port}) ->
    Program = io_lib:format("~s/~s/tcpport.out ~s ~s ~w",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr, Port ]),
    open_port({spawn, lists:flatten(Program)}, [binary,exit_status]);

connect({port, Program}) ->
    open_port({spawn, lists:flatten(Program)}, [binary,exit_status]);

connect({erlang_process, Name}) ->
    %% Wait a little (for tlv_fake).
    receive after 2000 -> ok end,
    Pid = pbutil:whereis_name(Name),
    Pid ! {self(), connect},
    receive {Pid, connected} -> Pid
    after 1000 -> exit(timeout_while_connecting)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TODOO verify that TLV is effectivement Synchrone
%% Since the TLV protocol is synchronous, the queue size is 1.
%% Actually it is much better to wait for the reply synchronously,
%% than to return "overloaded" when two simultaneous requests are done.

handle_call({tlv_request, Request}, Client, State) ->
    slog:event(trace, ?MODULE, handle_call, Request),
    #state{port=Port} = State,
    pbutil:send_port(Port, Request),
    Timeout = pbutil:get_env(pfront_orangef, tlv_response_timeout),
    Treq = pbutil:unixmtime(),
    %% Expect either Response or {eol, Response}
    %% (compatible with 'stream' and '{line,_}').
    receive
	{Port, {data, {eol, Response}}} ->
	    slog:delay(perf, ?MODULE, port_response_time, Treq),
	    {reply, {ok, Response}, State};
	{Port, {data, Response}} ->
	    slog:delay(perf, ?MODULE, port_response_time, Treq),
	    {reply, {ok, Response}, State};
	{exit_status, Status} ->
	    slog:event(count, ?MODULE, {fsx25_exited_during_request, Status}),
	    exit(tlv_port_exited)
    after Timeout ->
	    slog:event(trace, ?MODULE, response_timeout, Request),
	    exit(timeout_waiting_for_tlv_reply)
    end.


handle_info(timeout, #state{port=connect}=S) ->
    Config = (get(interface))#interface.extra,
    {Name,_Node} = (get(interface))#interface.name_node,
    slog:event(trace, ?MODULE, {Name,connecting}),
    Port = connect(Config#tlv_config.method),
    pfront_app:interface_up(Name),
    put(port, Port),
    {noreply, S#state{port=Port}};

%% The following clauses are now unused: handle_call blocks until the
%% TLV replies.

handle_info({Port, {data, {eol,Response}}}, S) ->
    %% For compatibility between 'stream' and '{line,_}'.
    handle_info({Port, {data, Response}}, S);

handle_info({Port, {data, Response}}, S) ->
    #state{port=Port,q=Q,n=N} = S,
    case queue:out(Q) of
	{empty, _} ->
	    slog:event(failure,?MODULE,reponse_wihtout_request,Response),
	    exit(tlv_sync);
	{{value, {Client,Prefix,_}}, Q1} ->
	    case lists:prefix(Prefix, Response) of
		false ->
		    exit({tlv_sync, response_order});
		true ->
		    io:format( "TLV REPLY: ~p~n", [Response]),
		    gen_server:reply(Client, {ok, Response}),
		    {noreply, S#state{q=Q1, n=N-1}, 0}
	    end
    end;
		  
handle_info({Port, {exit_status, Status}}, S) ->
    slog:event(count, ?MODULE, {fsx25_exited, Status}),
    exit(tlv_port_exited);

handle_info(Msg, S) ->
    pbutil:badmsg(Msg, ?MODULE).

%% +type code_change(Vsn, state(), M) -> {ok, state()}.

code_change(Old, State, Extra) ->
    {ok, State}.

%% +type handle_cast(M, state()) -> gs_hcast_result(state()).

handle_cast(Req, S) ->
    {noreply, S}.

%% +type terminate(R, state()) -> ok.

terminate(Reason, S) ->
    ok.

%% *autograph([
%%     { path, ["../../posutils/src", "."]},
%%     { actions, [ {connect,1} ] },
%%     { inits, [ {init,1} ] }
%%   ]).
