%%%% Unit tests for smppasn_server.
%%%% Some functions are also used for esme_simu and ussdc_simu.

%%%% - func_test: Simple functional test.
%%%%
%%%%   Runs a SMPP server and a SMPP client in parallel, simulating
%%%%   traffing between an USSD-C and an ESME.
%%%%   Simulates USSD1 and USSD2 sessions.
%%%%   Does not try to simulate incorrect behaviour.
%%%%   Fails when encountering unexpected behaviour.
%%%%   Clients may interrupt a USSD2 session before receiving pssr_response.
%%%%
%%%%   Reports success is a sufficient number of ussd sessions have
%%%%   been completed after a few seconds.

%%%% This version does not test the following features:
%%%% - OUTBIND (password)
%%%% - BIND (password)
%%%% - session_init_timer
%%%% - ENQUIRE_LINK
%%%% - INACTIVITY_TIMEOUT.

-module(test_smppasn_server).

%% Test profiles.
-export([run/0, run_slow/0, run_fast/0, run_overload/0,online/0]).
%% Utilities.
-export([config/1, config/2, config_from_env/1, config_from_env/2,
	 smpp_config_from_env/0]).

%% Exports for spawns.
-export([server_enter_loop/0]).
-export([client/1, server/1]).
-export([client_session/1, server_reply_aux/2]).

%% Includes with implicit paths, so that we can compile it in simu/.
-include("../../pgsm/include/ussd.hrl").
-include("../../pfront/include/smpp_server.hrl").

-define(USSD_REQUEST,        "#123#12345").
-define(USSD_REQUEST_PACKED, [163,152,108,54,138,201,102,180,26]).
-define(USSD_REQUEST_LENGTH, 10).

-define(USSD_REPLY,        "--echo--").
-define(USSD_REPLY_PACKED, [173,86,121,140,126,183,90]).
-define(USSD_REPLY_LENGTH, 8). %% 8 chars (7 bytes) can be used as a prefix.

%%%% SMPP port (overriden by esme_simu and ussd_simu).
-define(SMPP_PORT, 7434).

%%%% Server module to test.
-define(SMPP_SERVER_MODULE, smppasn_server).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test profiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Default

run() -> run_fast().

online() ->
    ok.

%% Load test: Regulated only by the number of simultaneous sessions.

run_fast() ->
    config(port, ?SMPP_PORT),
    config(host, "localhost"),
    config(test_duration, 2000),
    config(server_reply_delay, 0),
    config(server_reply_timeout, 3000),
    config(ussd2_ratio, 50),
    config(client_reply_delay, 0),
    config(session_rate, 1000),
    config(simultaneous_clients, 19),
    config(queue_length, 20),
    config(min_sessions, 20),
    config(ussr_ratio, 50),
    config(ussn_ratio, 20),
    config(noreply_ratio, 0),
    run_configured().

%% Overload: Same as run_fast, but overflows the SMPP queue.

run_overload() ->
    config(port, ?SMPP_PORT),
    config(host, "localhost"),
    config(test_duration, 10000),
    config(server_reply_delay, 0),
    config(server_reply_timeout, 3000),
    config(ussd2_ratio, 50),
    config(client_reply_delay, 0),
    config(session_rate, 1000),
    config(simultaneous_clients, 30),
    config(queue_length, 10),
    config(min_sessions, 100),
    config(ussr_ratio, 50),
    config(ussn_ratio, 20),
    config(noreply_ratio, 0),
    run_configured().
    
%% Slow test: Independent sessions, slow reply delays.

run_slow() ->
    config(port, ?SMPP_PORT),
    config(host, "localhost"),
    config(test_duration, 10000),
    config(server_reply_delay, 500),
    config(server_reply_timeout, 3000),
    config(ussd2_ratio, 50),
    config(client_reply_delay, 1000),
    config(session_rate, 100),
    config(simultaneous_clients, 1),
    config(queue_length, 10),
    config(min_sessions, 5),
    config(ussr_ratio, 50),
    config(ussn_ratio, 20),
    config(noreply_ratio, 0),
    run_configured().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Config (shared by all processes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

config(Param, Value) ->
    catch ets:new(config_parameters, [named_table, public, set]),
    ets:insert(config_parameters, {Param, Value}).

config(Param) ->
    case ets:lookup(config_parameters, Param) of
	[{_,Value}] -> Value;
	_ -> trace("Config parameter missing: ~p~n", [Param]),
	     exit({config, Param})
    end.

config_from_env(Param) -> config(Param, do_get_env(Param)).

config_from_env(Param, Default) -> config(Param, opt_get_env(Param, Default)).

do_get_env(Param) ->
    case application:get_env(Param) of
	{ok, Value} -> Value;
	undefined -> io:format("Configuration parameter ~p missing.", [Param]),
		     exit({config_missing, Param})
    end.

opt_get_env(Param, Default) ->
    case application:get_env(Param) of
	{ok, Value} -> Value;
	undefined -> Default
    end.

%% +type smpp_config_from_env() -> smpp_config().
%%%% Fills a SMPP configuration from the application environment,
%%%% except 'name' and 'handler'.

smpp_config_from_env() ->
    #smpp_config{outbind         = opt_get_env(outbind, no),
		 bind            = opt_get_env(bind, no),
		 init_timeout    = opt_get_env(session_init_timeout, 3000),
		 resp_timeout    = opt_get_env(response_timeout, 2000),
		 enquire_timeout = opt_get_env(enquire_link_timeout, 10000),
		 inact_timeout   = opt_get_env(inactivity_timeout, infinity),
		 queue_length    = opt_get_env(queue_length, 10),
		 async_resp      = opt_get_env(async_resp, no),
		 initial_seq     = opt_get_env(initial_seq, 1),
		 trace           = opt_get_env(trace_smpp, false)
		}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test suites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Runs the tests.
%%%% Assumes that test parameters have been set (e.g. by run_slow/0).

run_configured() ->
    %% process_flag(trap_exit, false),
    simple_protocol(),
    %% full_protocol(),
    %% full_protocol_outbind(),
    %% outbind_password(),
    %% bind_password(),
    ok.

%%%% Timeout for internal synchronization stuff (shutting down, etc).
-define(CONTROL_TIMEOUT, 1000).

simple_protocol() ->
    ServerConfig = #smpp_config{outbind=no,
				bind=no,
				init_timeout=2000,
				name=smpp_test_server,
				resp_timeout=1000,
				enquire_timeout=infinity,
				inact_timeout=infinity,
				queue_length=config(queue_length),
				initial_seq=1000
			       },
    ClientConfig = #smpp_config{outbind=no,
				bind=no,
				init_timeout=2000,
				name=smpp_test_client,
				resp_timeout=1000,
				enquire_timeout=infinity,
				inact_timeout=infinity,
				queue_length=config(queue_length)
			       },
    func_test("simple test", ServerConfig, ClientConfig).

%% +type func_test(string(), Srv::smpp_config(), Cln::smpp_config()) -> *.

func_test(Info, ServerConfig, ClientConfig) ->
    io:format("Starting test: ~s~n", [Info]),
    {listening, Server} = proc_lib:start_link(?MODULE, server, [ServerConfig],
					      ?CONTROL_TIMEOUT),
    {ok, Client} = proc_lib:start_link(?MODULE, client, [ClientConfig]),
    receive after config(test_duration) -> ok end,
    trace("Stopping test~n"),
    Client ! {self(), stop},
    Server ! {self(), stop},
    ResultC = receive {Client, RC} -> RC
	      after 1000 -> exit(client_stop_timeout) end,
    ResultS = receive {Server, RS} -> RS
	      after 1000 -> exit(server_stop_timeout) end,
    %% Check the absolute number of sessions.
    MinSessions = config(min_sessions),
    case ResultC of
	{ok, _, SessDone} when SessDone < MinSessions ->
	    exit({test_failed, not_enough_sessions_completed});
	_ -> ok
    end,
    %% Check whether the server replied to all messages.
    QueueLength = config(queue_length),
    case {ResultC, ResultS} of
	{{ok,MsgC,_}, {ok,MsgS,_}} when abs(MsgS-MsgC) > QueueLength ->
	    exit({test_failed, messages_not_answered});
	_ -> ok
    end,
    %% Check a weak agreement on the number of sessions.
    SimultSessions = config(simultaneous_clients),
    case {ResultC, ResultS} of
	{{ok,_,SessC}, {ok,_,SessS}} when abs(SessC-SessS) > SimultSessions ->
	    exit({test_failed, sessions_lost});
	_ -> ok
    end,
    io:format("########## Test successful~n"),
    unlink(Server),
    unlink(Client),
    catch exit(Server, kill),
    catch exit(Client, kill),
    io:format("Ending test: ~s~n", [Info]),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smppasn_sockopts() -> [ {active,true}, {packet,asn1}, binary ].

%% +type client(smpp_config()) -> *.

client(Config) ->
    %% Make sure SMPP37.beam is loaded before starting the timer.
    %% In native mode, it takes 4 seconds to load it.
    code:ensure_loaded('SMPP37'),
    code:ensure_loaded(?SMPP_SERVER_MODULE),
    Host = config(host),
    Port = config(port),
    trace("client: connecting to ~s:~p~n", [Host, Port]),
    {ok, Sock} = gen_tcp:connect(Host, Port, smppasn_sockopts()),
    trace("client: connected~n"),
    Client = self(),
    Handler = fun (USSD) -> %% trace("Sending ~w to client~n", [USSD]),
			    Client ! USSD end,
    Config1 = Config#smpp_config{handler=Handler},
    {ok, Srv} = ?SMPP_SERVER_MODULE:start_link({Config1,Sock}),
    erlang:monitor(process, Srv),
    wait_name(Config1#smpp_config.name,
	      Config1#smpp_config.init_timeout*2),
    %% Signal to our parent that everything is OK so far.
    proc_lib:init_ack({ok, self()}),
    random:seed(),
    put(count, 0),
    put(count_msg, 0),
    put(avail, config(simultaneous_clients)),
    put(start_time, unixmtime()),
    register(client_scheduler, self()),
    client_loop(unixmtime()).

wait_name(Name, Timeout) when Timeout < 0 ->
    exit({timeout_waiting_for, Name});

wait_name(Name, Timeout) ->
    case whereis(Name) of
	undefined ->
	    receive after 100 -> ok end,
	    wait_name(Name, Timeout-100);
	_ -> ok
    end.
			    
%% +type client_loop(unix_mtime()) -> *.

client_loop(Next) ->
    Timeout = case get(avail) of
		  0 -> infinity;
		  _ -> lists:max([Next-unixmtime(), 0])
	      end,
    receive
	{'DOWN', Mref, _, Pid, Info} ->
	    exit({smpp_down, Info});
	#ussd_msg{info=Info}=USSD ->
	    Pid = case lists:keysearch(receipted_message_id, 1, Info) of
		      {value, {_,Pid_}} -> Pid_;
		      false -> exit(missing_receipted_message_id, Info)
		  end,
	    catch list_to_pid(Pid) ! USSD,
	    client_loop(Next);
	{Pid, stop} ->
	    Messages = get(count_msg),
	    Sessions = get(count),
	    Time = unixmtime() - get(start_time),
	    io:format("##### client: sent ~p messages "
		      "and completed ~p sessions in ~p seconds~n",
		      [Messages, Sessions, Time/1000]),
	    Pid ! {self(), {ok, Messages, Sessions}},
	    %% The tester should kill us now.
	    receive after 10000 -> ok end;
	session_done ->
	    put(count, get(count)+1),
	    put(avail, get(avail)+1),
	    client_loop(Next);
	sent_message ->
	    put(count_msg, get(count_msg)+1),
	    client_loop(Next);
	unsent_message ->
	    server_loop();
	M ->
	    io:format("Unexpected message to client: ~p~n", [M]),
	    server_loop()

    after Timeout ->
	    spawn_link(?MODULE, client_session, [random:uniform(10000)]),
	    put(avail, get(avail)-1),
	    client_loop(Next + trunc(1000/config(session_rate)))
    end.

%% +type random_address() -> gsm_addr().

random_address() ->
    %% MSISDN = io_lib:format("06~8..0w", [random:uniform(99999999)]),
    %% {national, isdn, lists:flatten(MSISDN)}.
    IMSI = io_lib:format("~8..0w", [random:uniform(99999999)]),
    {subscriber_number, private, lists:flatten(IMSI)}.
    
%% +type client_session(Seed::integer()) -> *.

client_session(RandomSeed) ->
    random:seed(RandomSeed, RandomSeed, RandomSeed),
    MSADDR = random_address(),
    %% Prepare a request (don't set 'op').
    Request = #ussd_msg{msaddr=MSADDR,
			dcs=default_alphabet,
			data=?USSD_REQUEST_PACKED},
    %% Choose USSD1 or USSD2.
    case random:uniform(100) > config(ussd2_ratio) of
	true ->
	    trace("client: spawning ussd1~n"),
	    client_send(Request#ussd_msg{op=pssd}),
	    receive
		#ussd_msg{} ->
		    client_scheduler ! session_done,
		    trace("client: finished ussd1~n~n"),
		    stop;
		M -> exit({client_unexpected, M})
	    after config(server_reply_timeout) ->
		    exit(client_ussd1_timeout)
	    end;
	false ->
	    trace("client: spawning ussd2~n"),
	    client_send(Request#ussd_msg{op=pssr}),
	    client_session2()
    end.

%% +type client_session2() -> *.

client_session2() ->
    %% Decide to interrupt the session with probability 1 in 5.
    case random:uniform(5) of
	1 -> client_scheduler ! session_done,
	     trace("client: finished ussd2 (interrupted)~n~n"),
	     stop;
	_ -> receive
		 #ussd_msg{op=pssr_response}=USSD ->
		     client_scheduler ! session_done,
		     trace("client: finished ussd2~n~n"),
		     stop;
		 #ussd_msg{op=ussr}=USSD ->
		     client_reply2(USSD, ussr_response);
		 #ussd_msg{op=ussn}=USSD ->
		     client_reply2(USSD, ussn_response);
		 M -> exit({client_unexpected, M})
	     after config(server_reply_timeout) ->
		     exit(client_ussd2_timeout)
	     end
    end.

%% +type client_reply2(ussd_msg()) -> *.

client_reply2(USSD, ReplyOp) ->
    Delay = random:uniform(1+config(client_reply_delay)*2) - 1,
    receive after Delay -> ok end,
    client_send(USSD#ussd_msg{data="1", op=ReplyOp}),
    client_session2().

%% +type client_send(ussd_msg()) -> *.

client_send(USSD) ->
    trace("client: sending ~p~n", [USSD#ussd_msg.op]),
    Info = [ {receipted_message_id, pid_to_list(self())} ],
    USSD1 = USSD#ussd_msg{info=Info},
    case catch ussd_server:send_ussd(smpp_test_client, USSD1) of
	{ok, _} -> client_scheduler ! sent_message, ok;
	{rejected, Status}=Result ->
	    io:format("client: message not sent (~p)~n", [Status]),
	    client_scheduler ! unsent_message,
	    Result;
	{full, T} ->
	    receive after T div 2 -> ok end,
	    trace("client: SMPP full~n");
	%% client_send(USSD1);
	{'EXIT', E} ->
	    io:format("client: SMPP error ~p~n", [E]),
	    client_scheduler ! unsent_message,
	    ok
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type server(smpp_config()) -> *.
	    
server(Config) ->
    Opts = [ {reuseaddr,true}, {keepalive,true}, {active,false} ],
    Port = config(port),
    trace("server: listening on port ~p~n", [Port]),
    {ok, LSock} = gen_tcp:listen(Port, Opts),
    %% Signal to our parent that we are ready to accept connections.
    proc_lib:init_ack({listening, self()}),
    {ok, Sock} = gen_tcp:accept(LSock, 5000),
    trace("server: accepted~n"),
    Server = self(),
    Handler = fun (USSD) -> %% trace("Sending ~w to server~n", [USSD]),
			    Server ! USSD end,
    Config1 = Config#smpp_config{handler=Handler},
    ok = inet:setopts(Sock, smppasn_sockopts()),
    {ok, Srv} = ?SMPP_SERVER_MODULE:start_link({Config1,Sock}),
    erlang:monitor(process, Srv),
    ok = gen_tcp:close(LSock),
    server_enter_loop().

%% +type server_enter_loop() -> *.
%%%% Runs the server, assuming we are already connected to a SMPP
%%%% process called smpp_test_server.

server_enter_loop() ->
    random:seed(),
    put(start_time, unixmtime()),
    put(count, 0),
    put(count_msg, 0),
    register(server_loop, self()),
    server_loop().

%% +type server_loop() -> *.

server_loop() ->
    receive
	{'DOWN', Mref, _, Pid, Info} ->
	    exit({smpp_down, Info});
	#ussd_msg{dcs=DCS, op=Op, data=Data}=Request ->
	    %% Prepare a reply.
	    Reply = make_reply(Request),
	    trace("server: received ~p~n", [Op]),
	    server_process(Op, Reply),
	    server_loop();
	sent_message ->
	    put(count_msg, get(count_msg)+1),
	    server_loop();
	unsent_message ->
	    server_loop();
	{Pid, stop} ->
	    Messages = get(count_msg),
	    Sessions = get(count),
	    Time = unixmtime() - get(start_time),
	    io:format("##### server: sent ~p messages "
		      "and received ~p sessions in ~p seconds~n",
		      [Messages, Sessions, Time/1000]),
	    Pid ! {self(), {ok, Messages, Sessions}},
	    %% The tester should kill us now.
	    receive after 10000 -> ok end;
	M ->
	    io:format("Unexpected message to server: ~p~n", [M]),
	    server_loop()
    end.

%% +type make_reply(ussd_msg()) -> ussd_msg().
%%%% Builds a reply. "Hello" -> "--echo--Hello".
%%%% Recognizes default_alphabet. Anything else is decoded as 8bit.
%%%% Also handles "#129*XYZ#": predefined messages and data codings.

make_reply(#ussd_msg{dcs=_,
		     data=("#129*"++[DCSd,MSGhi,MSGlo,$#])=Data}=Request) ->
    DCS = case DCSd of
	      $0 -> default_alphabet;
	      $1 -> ascii;
	      $2 -> eightbit_data;
	      $3 -> latin1;
	      _ ->  ascii
	  end,
    Message = special_message((MSGhi-$0)*10+(MSGlo-$0)),
    Request#ussd_msg{dcs=DCS, data=gsmcharset:iso2ud(Message, DCS)};

make_reply(#ussd_msg{dcs=DCS, data=Data}=Request) ->
    case DCS of
	default_alphabet ->
	    Request#ussd_msg{data=?USSD_REPLY_PACKED ++ Data};
	_ ->
	    Request#ussd_msg{data=?USSD_REPLY ++ Data}
    end.

special_message_help() ->
    "Messages de test: #129*XYZ#\n"
	"X=data-coding=0..3\n"
	"YZ=message=00..05,10..14,20..24".

special_message(00) -> "40car:  10........20........30........40";
special_message(01) -> "160car: 10........20........30........40"
			  "........50........60........70........80"
			  "........90.......100.......110.......120"
			  ".......130.......140.......150.......160";
special_message(02) -> "180car: 10........20........30........40"
			  "........50........60........70........80"
			  "........90.......100.......110.......120"
			  ".......130.......140.......150.......160"
			  ".......170.......180";
special_message(03) -> "182car: 10........20........30........40"
			  "........50........60........70........80"
			  "........90.......100.......110.......120"
			  ".......130.......140.......150.......160"
			  ".......170.......18012";
special_message(04) -> "183car: 10........20........30........40"
			  "........50........60........70........80"
			  "........90.......100.......110.......120"
			  ".......130.......140.......150.......160"
			  ".......170.......180123";
special_message(05) -> "200car: 10........20........30........40"
			  "........50........60........70........80"
			  "........90.......100.......110.......120"
			  ".......130.......140.......150.......160"
			  ".......170.......180.......190.......200";
special_message(06) -> "201car: 10........20........30........40"
			  "........50........60........70........80"
			  "........90.......100.......110.......120"
			  ".......130.......140.......150.......160"
			  ".......170.......180.......190.......2001";

special_message(10) -> "Ligne 1\nLigne 2\n";
special_message(11) -> "Ligne 1\nLigne 2\nLigne 3\nLigne 4\nLigne 5";
special_message(12) -> "Ligne 01\nLigne 02\nLigne 03\nLigne 04\n"
			   "Ligne 05\nLigne 06\nLigne 07\nLigne 08\n"
			   "Ligne 09\nLigne 10\nLigne 11\nLigne 12\n"
			   "Ligne 13\nLigne 14\nLigne 15\nLigne 16\n"
			   "Ligne 17\nLigne 18";
special_message(13) -> "Essai 123456CR7:\n123456\r7";
special_message(14) -> "Majuscules: ABCDEF\n"
			   "Minuscules: abcdef";
special_message(20) -> "GSM: (a)=@ L=£ S=$ Y=¥ 'e=è e'=é "
			   "'u=ù 'i=ì 'o=ò C,=Ç O=Ø o=ø Ao=Å ao=å AE=Æ "
			   "ae=æ B=ß E'=É x=¤ i=¡ A\"=Ä O\"=Ö N\"=Ñ "
			   "U\"=Ü S=§ ?=¿ a\"=ä o\"=ö n\"=ñ u\"=ü 'a=à";
special_message(21) -> "ASCII: S=$ (a)=@ (=[ /=\\ )=] \"=^ "
			   "'=` (={ !=| )=} \"=~";
special_message(22) -> message_enum(32, 127, []);
special_message(23) -> "ISO8859-1: S=$ (a)=@ c,=ç 123:¹²³ A:ÀÁÂÃÄÅ "
			   "E:ÈÉÊË I:ÌÍÎÏ O:ÒÓÔÕÖ U:ÙÚÛÜ a:àáâãäå e:èéêë "
			   "i:ìíîï o:òóôõö u:ùúûü y:ýÿ N=Ñ n=ñ";
special_message(24) -> message_enum(128, 256, []);
special_message(30) -> "LF\n1234";
special_message(31) -> "CR\r1234";
special_message(32) -> "LFCR\n\r1234";
special_message(33) -> "CRLF\r\n1234";
special_message(_) -> special_message_help().

%% +type message_enum(First::integer(), Last::integer(),
%%                    Exclude::[integer()]) -> [integer()].
%%%% Enumerates characters from First to Last.
%%%% Characters in Exclude are replaced with '.'.
%%%% Exclude must be a sorted list.

message_enum(End, End, _Excl) -> [];
message_enum(C, End, [C|Excl]) -> [$. | message_enum(C+1, End, Excl)];
message_enum(C, End, Excl) -> [C | message_enum(C+1, End, Excl)].

%% +type server_process(ussd_op(), Partial_reply::ussd_msg()) -> *.

server_process(pssd, Reply) ->
    put(count, get(count)+1),
    server_reply(Reply#ussd_msg{op=pssd_response});

server_process(pssr, Reply) ->
    put(count, get(count)+1),
    server_process(ussr_response, Reply);

server_process(ussr_response, Reply) ->
    Rand = random:uniform(100),
    Threshold_resp = config(ussr_ratio) + config(ussn_ratio),
    Threshold_ussn = config(ussr_ratio),
    if Rand > Threshold_resp ->
	    server_reply(Reply#ussd_msg{op=pssr_response});
       Rand > Threshold_ussn ->
	    server_reply(Reply#ussd_msg{op=ussn});
       true ->
	    server_reply(Reply#ussd_msg{op=ussr})
    end;

server_process(ussn_response, Reply) ->
    %% Same as ussr_response
    server_process(ussr_response, Reply);

server_process(hangup,  _) -> ok;
server_process(failure, _) -> ok;
server_process(reject,  _) -> ok;

server_process(M, _) ->
    exit({server_unexpected, M}).

%% +type server_reply(ussd_msg()) -> *.
%%%% Sends a reply asynchronously.

server_reply(Reply) ->
    case random:uniform(100) > config(noreply_ratio) of
	true -> 
	    Delay = random:uniform(1+config(server_reply_delay)*2) - 1,
	    spawn_link(?MODULE, server_reply_aux, [Delay, Reply]),
	    ok;
	false ->
	    discard
    end.

%% +type server_reply_aux(Ms::integer(), ussd_msg()) -> ok.
%%%% Actually delays then sends the reply.

server_reply_aux(Delay, Reply) ->
    receive after Delay -> ok end,
    trace("server: sending reply ~p~n", [Reply#ussd_msg.op]),
    case catch ussd_server:send_ussd(smpp_test_server, Reply) of
	{ok, _} -> server_loop ! sent_message, ok;
	{rejected, Status}=Result ->
	    io:format("server: message not sent (~p)~n", [Status]),
	    server_loop ! unsent_message,
	    Result;
	{full, T} -> 
	    receive after T div 2 -> ok end,
	    trace("server: full~n"),
	    ok;
	    % trace("server: retrying~n"),
	    % server_reply_aux(0, Reply);
	{'EXIT', E} ->
	    io:format("server: SMPP error ~p~n", [E]),
	    server_loop ! unsent_message,
	    ok
    end.

unixmtime() -> {MS,S,US} = now(), (MS*1000000+S)*1000 + US div 1000.

trace(S) -> trace(S, []).
trace(FMT, Args) -> io:format("~p: "++FMT, [self()|Args]).
