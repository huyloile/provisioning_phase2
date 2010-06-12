%%%% The Short Message Peer to Peer Protocol, version 3.4.
%%%% With ASN.1 encoding.

%%%% This gen_server handles a single SMPP session, and exits afterwards.
%%%% It expects a TCP socket that has just been accept()ed or connect()ed.
%%%% The socket must be already configured {active,true}, {packet,asn1}
%%%% and binary.
%%%%
%%%% The server signals that it is ready to send and receive messages
%%%% by registering under the name specified in its configuration.
 
%%%% Supported features:
%%%% - OUTBIND, BIND_TRANSCEIVER
%%%% - session_init_timer
%%%% - DATA_SM with a USSD payload
%%%% - RESP
%%%% - resp_timer
%%%% - enquire_link_timer
%%%% - inactivity_timer
%%%% - UNBIND
%%%%
%%%% Limitations:
%%%% - USSD only (ussd-service-op required)
%%%% - Does not send UNBIND when the inactivity_timer expires.
%%%% - ENQUIRE_LINK must be acknowledged by ENQUIRE_LINK_RESP.
%%%% - Ignores adress ranges in BIND PDUs.

-module(smppasn_server).

-export([start_link/1]).

-behaviour(gen_server).
-export([init/1, handle_call/3,  handle_info/2, 
	 code_change/3, handle_cast/2, terminate/2]).

%% Internal exports for spawn.
-export([send_resp_aux/3]).

%% Version of the ASN.1 specification (both lines must match).
-include("SMPP37.hrl").
-define(ASN1_MODULE, 'SMPP37').

-include("../../pdist/include/generic_router.hrl").

-include("../../pfront/include/smpp_server.hrl").
-include("../../pfront/include/smpp_constants.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("../../pgsm/include/sms.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% start_link
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type start_link({smpp_config(), socket()}) -> gs_start_result().
%%%% Starts a SMPP session on an already-open TCP socket.
%%%% Attaches the socket to the child process.
%%%% Closes the socket in case of failure.

start_link({#smpp_config{}, Sock}=Arg) ->
    case gen_server:start_link(?MODULE, Arg, []) of
	{ok,Pid}=Res -> ok=gen_tcp:controlling_process(Sock,Pid), Res;
	Error -> gen_tcp:close(Sock), Error
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +deftype st() = {expect_outbind, smpp_outbind_config()}
%%               | {expect_bind, smpp_bind_config()}
%%               | {expect_bind_resp, smpp_bind_config()}
%%               | bound_trx
%%               | expect_unbind_resp.

%% +deftype state() =
%%   #state{ start_time :: unix_mtime(),
%%           st :: st(),
%%           seq :: integer(),
%%           queue :: queue(pending()),
%%           free :: integer(),
%%           last_alive :: unix_mtime(),   %% Last time we heard from the peer
%%           last_active :: unix_mtime()   %% Last PDU (not enquire_link)
%%         }.

%% Resetting the enquire_link_timer is done by updating last_alive :
%% - whenever a valid PDU is received
%% - when we send ENQUIRE_LINK.

%% Resetting the inactivity_timer is done by updating last_active :
%% - when receiving a PDU other than ENQUIRE_LINK or ENQUIRE_LINK_RESP
%% - when sending a command other than OUTBIND and ENQUIRE_LINK
%%   (we could reset it when sending RESPs other than ENQUIRE_LINK_RESP too).

-record(state, {start_time, st, seq, queue, free, last_alive, last_active}).

%% +deftype pending() = { seq :: integer(),     %% Sequence number
%%                        type :: atom(),       %% 'data-sm-resp', ...
%%                        time :: unix_mtime(), %% Deadline for the RESP msg
%%                        from :: From          %% gen_server client
%%                      }.

-record(pending, {seq, type, time, from}).

%% Note: In addition to state(), some constant parameters are stored
%% in the process dictionary:
%%   get(sock) :: socket()
%%   get(config) :: smpp_config()
%%   

%% +type init({smpp_config(), socket()}) -> gs_init_result(state()).

init({Config, Sock}) ->
    %% trace/2 doesn't work before put(config, Config).
    do_trace("Starting with ~1000p~n", [Config]),
    check_config(Config),
    check_asn_spec(),
    put(config, Config),
    put(sock, Sock),
    random:seed(),   % For async_resp
    check_bor_bug(), % Check for the OTB R7B-1 large integer bug
    Now = util_unixmtime(),
    %% #state.st will be initialized in prepare_outbind.
    State = #state{start_time=Now,
		   seq=Config#smpp_config.initial_seq,
		   queue=queue:new(),
		   free=Config#smpp_config.queue_length,
		   last_alive=Now, last_active=Now},
    %% Now send outbind or bind if required.
    State1 = prepare_outbind(State),
    %% Return Timeout=1 so that do_timeouts will be called.
    {ok, State1, 1}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Functions for checking configuration parameters.

%% +type check_config(smpp_config()) -> *.

check_config(Config) ->
    case Config#smpp_config.outbind of
	no -> ok;
	{send,Outbind} -> check_outbind_config(Outbind);
	{expect,Outbind} -> check_outbind_config(Outbind);
	Outbind -> exit({invalid_outbind_config, Outbind})
    end,
    case Config#smpp_config.bind of
	no -> ok;
	{send,Bind} -> check_bind_config(Bind);
	{expect,Bind} -> check_bind_config(Bind);
	Bind -> exit({invalid_bind_config, Bind})
    end.

%% +type check_outbind_config(smpp_outbind_config()) -> *.

check_outbind_config(#smpp_outbind_config{system_id=SysID, password=Pwd}) ->
    warn_if_blank("OUTBIND", SysID, "system id"),
    warn_if_blank("OUTBIND", Pwd, "password");

check_outbind_config(Outbind) ->
    exit({invalid_outbind_config, Outbind}).

%% +type check_bind_config(smpp_bind_config()) -> *.

check_bind_config(#smpp_bind_config{system_id=SysID,
				    password=Pwd,
				    system_type=SysType,
				    interface_version=IV,
				    resp_system_id=SysIDR,
				    resp_interface_version=IVR
				   }) ->
    warn_if_blank("BIND", SysID, "system id"),
    warn_if_blank("BIND", Pwd, "password"),
    warn_if_blank("BIND", SysType, "system type"),
    warn_if_blank("BIND", IV, "interface version"),
    warn_if_blank("BIND", SysIDR, "system id"),
    warn_if_blank("BIND", IVR, "interface version");

check_bind_config(Bind) ->
    exit({invalid_bind_config, Bind}).

%% +type warn_if_blank(string(), asn1_NOVALUE|term(), string()) -> *.

warn_if_blank(Where, asn1_NOVALUE, What) ->
    do_trace("Warning: ~s: Blank ~s (not sent / not checked)~n",
	     [Where, What]);
warn_if_blank(Where, Value, What) ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% This fixes a bug in Erlang OTP R7B-1.

%% +type check_bor_bug() -> *.
%%%% TODO remove this after Ericsson have fixed the bug.

check_bor_bug() ->
    X = (-1) bsl 31,
    case X - (X bor 0) of
	0 -> ok;
	65536 ->
	    do_trace("OTP 'bor' fix enabled.~n"),
	    put(has_bor_bug, true);
        _ -> exit({unidentified_arith_bug, please_contact_support})
    end.

%% +type workaround_bor_bug(smpp_pdu()) -> smpp_pdu().

workaround_bor_bug(PDU) ->
    case get(has_bor_bug) of
	true ->
	    ID = PDU#'SMPP-PDU'.'command-id',
	    if ID < -16#80000000 -> PDU#'SMPP-PDU'{'command-id'=ID+16#10000};
	       true -> PDU
	    end;
	_ -> PDU
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Internal consistency checks.

%%%% In order to use pattern-matching on 'command-id', we must refer
%%%% to SMPP constants as ?GENERIC_NACK instead of
%%%% 'SMPP37':'generic-nack'().
%%%% Here we check that the constants in smpp_constants.hrl match
%%%% those in SMPP37.erl.

%% +type check_asn_spec() -> *.
%%%% Calls do_check_asn_spec/0 and formats the error message, if any.

check_asn_spec() ->
    case catch do_check_asn_spec() of
	{'EXIT', E} -> exit({mismatched_smpp_constants, E});
	_ -> ok
    end.

%% +type do_check_asn_spec() -> *.

do_check_asn_spec() ->
    ?GENERIC_NACK          = ?ASN1_MODULE:'generic-nack'(),
    ?BIND_RECEIVER         = ?ASN1_MODULE:'bind-receiver'(),
    ?BIND_RECEIVER_RESP    = ?ASN1_MODULE:'bind-receiver-resp'(),
    ?BIND_TRANSMITTER      = ?ASN1_MODULE:'bind-transmitter'(),
    ?BIND_TRANSMITTER_RESP = ?ASN1_MODULE:'bind-transmitter-resp'(),
    ?QUERY_SM              = ?ASN1_MODULE:'query-sm'(),
    ?QUERY_SM_RESP         = ?ASN1_MODULE:'query-sm-resp'(),
    ?SUBMIT_SM             = ?ASN1_MODULE:'submit-sm'(),
    ?SUBMIT_SM_RESP        = ?ASN1_MODULE:'submit-sm-resp'(),
    ?DELIVER_SM            = ?ASN1_MODULE:'deliver-sm'(),
    ?DELIVER_SM_RESP       = ?ASN1_MODULE:'deliver-sm-resp'(),
    ?UNBIND                = ?ASN1_MODULE:'unbind'(),
    ?UNBIND_RESP           = ?ASN1_MODULE:'unbind-resp'(),
    ?REPLACE_SM            = ?ASN1_MODULE:'replace-sm'(),
    ?REPLACE_SM_RESP       = ?ASN1_MODULE:'replace-sm-resp'(),
    ?CANCEL                = ?ASN1_MODULE:'cancel'(),
    ?CANCEL_RESP           = ?ASN1_MODULE:'cancel-resp'(),
    ?BIND_TRANSCEIVER      = ?ASN1_MODULE:'bind-transceiver'(),
    ?BIND_TRANSCEIVER_RESP = ?ASN1_MODULE:'bind-transceiver-resp'(),
    ?OUTBIND               = ?ASN1_MODULE:'outbind'(),
    ?ENQUIRE_LINK          = ?ASN1_MODULE:'enquire-link'(),
    ?ENQUIRE_LINK_RESP     = ?ASN1_MODULE:'enquire-link-resp'(),
    ?SUBMIT_MULTI          = ?ASN1_MODULE:'submit-multi'(),
    ?SUBMIT_MULTI_RESP     = ?ASN1_MODULE:'submit-multi-resp'(),
    ?ALERT_NOTIFICATION    = ?ASN1_MODULE:'alert-notification'(),
    ?DATA_SM               = ?ASN1_MODULE:'data-sm'(),
    ?DATA_SM_RESP          = ?ASN1_MODULE:'data-sm-resp'(),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type prepare_outbind(state()) -> state().
%%%% Handles the OUTBIND phase.

prepare_outbind(State) ->
    Config = get_config(),
    case Config#smpp_config.outbind of
	{send, Outbind} ->
	    %% Send the OUTBIND PDU.
	    %% Does not return a new state because we don't queue OUTBIND.
	    send_outbind(Outbind),
	    prepare_bind(State);
	{expect, Outbind} -> 
	    State#state{st={expect_outbind, Outbind}};
	no ->
	    prepare_bind(State)
    end.

%% +type prepare_bind(state()) -> state().
%%%% Handles the BIND phase.

prepare_bind(State) ->
    Config = get_config(),
    case Config#smpp_config.bind of
	{send, Bind} ->
	    case send_bind(State, Bind) of
		{queued, State1} ->
		    State1#state{st={expect_bind_resp,Bind}};
		{ok, State1} ->
		    %% Not queued: this means we are configured with
		    %% resp_timeout=no. Move to bound_trx directly.
		    prepare_bound(State1)
	    end;
	{expect, Bind} ->
	    State#state{st={expect_bind, Bind}};
	no -> prepare_bound(State)
    end.

%% +type prepare_bound(state()) -> state().

prepare_bound(State) ->
    %% Ignore when pfront_app is missing (simulator).
    Name = (get_config())#smpp_config.name,
    case catch pfront_app:interface_up(Name) of
	{'EXIT', _} ->
	    register(Name, self());
	_           -> ok
    end,
    State#state{st=bound_trx}.

%% +type get_config() -> smpp_config().
%%%% A dummy function to help the typechecker.

get_config() -> get(config).

%% +type get_sock() -> socket().
%%%% A dummy function to help the typechecker.

get_sock() -> get(sock).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% handle_info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type handle_info(Msg, state()) -> gs_hinfo_result(state()).

handle_info(timeout, State) ->
    do_timeouts(State);

handle_info({tcp, _Port, MSG}, State) ->
    trace("Incoming PDU ~w~n", [MSG]),
    case asn1ct:decode(?ASN1_MODULE, 'SMPP-PDU', MSG) of
	{ok, PDU_bug} ->
	    PDU = workaround_bor_bug(PDU_bug),
	    trace("Decoded PDU ~p~n", [PDU]),
	    check_command_id(PDU),
	    Now = util_unixmtime(),
	    %% Note that the peer is alive and than the session is
	    %% active.
	    State1 = case PDU#'SMPP-PDU'.'command-id' of
			 ?ENQUIRE_LINK -> State#state{last_alive=Now};
			 ?ENQUIRE_LINK_RESP -> State#state{last_alive=Now};
			 _ -> State#state{last_alive=Now, last_active=Now}
		     end,
	    handle_pdu(State1, PDU);
	{error, E} ->
	    %% Report that we can't decode the PDU.
	    opt_send_resp('esme-rinvmsglen', 0,
			  {'generic-nack', asn1_NOVALUE}),
	    %% The ASN.1 data stream is probably desynchronized, so it
	    %% is safer to close the connection.
	    exit({invalid_asn, E, MSG})
    end;

handle_info({tcp_closed, _}, State) ->
    slog:event(warning, ?MODULE, {interface_shutdown, tcp_connection_closed}),
    {stop, shutdown, State};

handle_info(M, State) ->
    do_trace("Unexpected: ~p~n", [M]),
    do_timeouts(State).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% handle_pdu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type handle_pdu(state(), smpp_pdu()) -> gs_hinfo_result(state()).

%%%%%%%%%% OUTBIND

handle_pdu(#state{st={expect_outbind,Outbind}}=State,
	   #'SMPP-PDU'{body={outbind,Body}}) ->


    #smpp_outbind_config{system_id=SysID_cfg, password=Pwd_cfg} = Outbind,
    #'OUTBIND-BODY'{'system-id'=SysID, password=Pwd} = Body,
    %% Authenticate the peer.
    if SysID_cfg == asn1_NOVALUE -> ok;
       SysID =/= SysID_cfg -> exit({wrong_outbind_system_id, SysID});
       true -> ok
    end,
    if Pwd_cfg == asn1_NOVALUE -> ok;
       Pwd =/= Pwd_cfg -> exit({wrong_outbind_password, Pwd});
       true -> ok
    end,
    State1 = prepare_bind(State),
    do_timeouts(State1);

%%%%%%%%%% BIND_TRANSCEIVER

handle_pdu(#state{st={expect_bind,Bind}}=State,
	   #'SMPP-PDU'{'command-id'=?BIND_TRANSCEIVER,
		       'command-sequence'=Seq,
		       body={'bind-transceiver',Body}}) ->


    #smpp_bind_config{system_id=SysID_cfg,
		      password=Pwd_cfg,
		      system_type=SysType_cfg,
		      interface_version=IV_cfg,
		      resp_system_id=SysIDR,
		      resp_interface_version=IVR} = Bind,
    #'BIND-TRANSCEIVER-BODY'{'system-id'=SysID,
			     password=Pwd,
			     'system-type'=SysType,
			     'interface-version'=IV} = Body,
    %% %% Check Pwd-SysID-IV-SysType, combining results in this
    %% order, so that we leak as little information as possible.
    Status = 
	if Pwd_cfg == asn1_NOVALUE -> 'esme-rok';
	   Pwd =/= Pwd_cfg -> 'esme-rinvpaswd';
	   true -> 'esme-rok'
	end,
    Status1 =
	if SysID_cfg == asn1_NOVALUE -> Status;
	   SysID =/= SysID_cfg -> 'esme-rinvsysid';
	   true -> Status
	end,
    Status2 =
	if IV_cfg == asn1_NOVALUE -> Status1;
	   IV =/= IV_cfg -> 'esme-rinvsysid';
	   true -> Status1
	end,
    Status3 =
	if SysType_cfg == asn1_NOVALUE -> Status2;
	   SysType =/= SysType_cfg -> 'esme-rinvsystyp';
	   true -> Status2
	end,
    %% Authenticate ourselves (only if the peer is authenticated).
    RespBody = case Status3 of
		   'esme-rok' ->
		       #'BIND-TRANSCEIVER-RESP-BODY'{'system-id'=SysIDR,
						     'interface-version'=IVR};
		   _ ->
		       #'BIND-TRANSCEIVER-RESP-BODY'{'system-id'="(hidden)"}
	       end,
    opt_send_resp('esme-rok', Seq, {'bind-transceiver-resp',RespBody}),
    %% Next state.
    case Status3 of
	'esme-rok' -> State1 = prepare_bound(State),
		      do_timeouts(State1);
	_ -> exit({received_invalid_bind, Status3})
    end;

%%%%%%%%%% BIND_TRANSCEIVER_RESP

handle_pdu(#state{st={expect_bind_resp,
		      #smpp_bind_config{resp_system_id=SysID_cfg,
					resp_interface_version=IV_cfg}}
		 }=State,
	   #'SMPP-PDU'{'command-status'=Status,
		       body={'bind-transceiver-resp', Body}}=PDU) ->


    #'BIND-TRANSCEIVER-RESP-BODY'{'system-id'=SysID,
				  'interface-version'=IV} = Body,
    %% Check whether our bind was accepted.
    case Status of
	'esme-rok' -> ok;
	_ -> exit({bind_rejected_by_peer, Status})
    end,
    %% Authenticate the peer. In case of failure, just exit.
    if SysID_cfg == asn1_NOVALUE -> ok;
       SysID =/= SysID_cfg -> exit({wrong_bind_resp_system_id, SysID});
       true -> ok
    end,
    if IV_cfg == asn1_NOVALUE -> ok;
       IV =/= IV_cfg -> exit({wrong_bind_resp_interface_version, IV});
       true -> ok
    end,
    State1 = prepare_bound(State),
    %% Remove from the queue.
    handle_resp(State1, PDU);
	  
%%%%%%%%%% DATA_SM

handle_pdu(#state{st=ST}=State,
	   #'SMPP-PDU'{'command-id'=?DATA_SM,
		       'command-sequence'=Seq,
		       body={'data-sm', DataSM}}=PDU)
  when ST==bound_trx; ST==expect_unbind_resp ->



    Now = util_unixmtime(),
    %% Parse the body.
    %% Try to reply something even if an error occurs.
    {USSD, Status, ErrorInfo} =
	case catch parse_data_sm(DataSM) of
	    {_U, _Stat, _Inf} = Parsed_ -> Parsed_;
	    {'EXIT', E} ->
		do_trace("parse_data_sm failed: ~p~n", [E]), %%REQFAILED
		{no_message, 'esme-rsyserr', "parse_data_sm_failed"}
	end,
    %% Update: SIReS expects message-id = receipted-message-id.
    %% TODO This should be removed in a generic SMPP stack.
    ContextID = DataSM#'DATA-SM-BODY'.'receipted-message-id',
    %% We must handle asn1_NOVALUE because receipted-message-id is
    %% optional but message-id is not.
    MessageID = case ContextID of
		    asn1_NOVALUE -> [0]; % OTP-R7B-4 forbids [] here.
		    _ -> ContextID
		end,
    Resp = {'data-sm-resp',
	    #'DATA-SM-RESP-BODY'{'message-id'=MessageID,
				 'additional-status-info-text'=ErrorInfo}},
    case USSD of
	no_message ->
	    opt_send_resp(Status, Seq, Resp);
	#ussd_msg{} ->
	    Handler = (get_config())#smpp_config.handler,
	    case ussd_server:deliver(Handler, USSD) of
		ok -> 
		    opt_send_resp(Status, Seq, Resp);
		{error, license} ->
		    %% Note this log is redundant with the oma_lc alarm.
		    slog:event(warning, ?MODULE, license_reject_ussd_msg),
		    Resp1 = #'DATA-SM-RESP-BODY'{
		      'message-id'=MessageID,
		      'additional-status-info-text'="trafic regulation"},
		    opt_send_resp('esme-rsyserr', Seq, Resp1);
		_ ->
		    Resp1 = #'DATA-SM-RESP-BODY'{
		      'message-id'=MessageID,
		      'additional-status-info-text'=""},
		    opt_send_resp('esme-rsyserr', Seq, Resp1)
	    end
    end,
    do_timeouts(State);

%%%%%%%%%% DATA_SM_RESP

handle_pdu(#state{st=bound_trx}=State,
	   #'SMPP-PDU'{'command-id'=?DATA_SM_RESP,
		       body={'data-sm-resp', Body}}=PDU) ->

    %% Remove from the queue.
    handle_resp(State, PDU);

%%%%%%%%%% ENQUIRE_LINK

handle_pdu(State,
	   #'SMPP-PDU'{'command-id'=?ENQUIRE_LINK,
		       'command-sequence'=Seq,
		       body={'enquire-link', Body}}=PDU) ->


    opt_send_resp('esme-rok', Seq, {'enquire-link-resp',asn1_NOVALUE}),
    do_timeouts(State);

%%%%%%%%%% UNBIND

handle_pdu(#state{st=bound_trx}=State,
	   #'SMPP-PDU'{'command-id'=?UNBIND,
		       'command-sequence'=Seq}=PDU) ->

    opt_send_resp('esme-rok', Seq, {'unbind-resp',asn1_NOVALUE}),
    State1 = State#state{st=unbound},
    {stop, unbound_by_peer, State1};

%%%%%%%%%% UNBIND_RESP

handle_pdu(#state{st=expect_unbind_resp}=State,
	   #'SMPP-PDU'{'command-id'=?UNBIND_RESP,
		       body={'unbind-resp', Body}}=PDU) ->

    State1 = State#state{st=unbound},
    {stop, unbound, State1};

%%%%%%%%%% Other PDUs.

handle_pdu(State, #'SMPP-PDU'{'command-id'=CommandID,
			      'command-sequence'=Seq}=PDU) ->

    if CommandID == ?OUTBIND ->
	    do_timeouts(State); % No need to ack OUTBIND.
       CommandID band 16#80000000 == 0 ->
	    %% Unsupported command. Send a GENERIC_NACK.
	    do_trace("Unexpected PDU: ~p~nin state: ~p~n", [PDU, State]),
	    opt_send_resp('esme-rinvcmdid',Seq,{'generic-nack',asn1_NOVALUE}),
	    do_timeouts(State);
       true ->
	    %% The PDU is a RESP. No need to ack it.
	    do_trace("Unexpected RESP PDU: ~p~n", [PDU]),
	    handle_resp(State, PDU)
    end.

%% +type handle_resp(state(), smpp_pdu()) -> gs_hinfo_result(state()).

handle_resp(#state{st=_, queue=Q, free=Free}=State,
	    #'SMPP-PDU'{'command-sequence'=Seq,
			'command-status'=Status,
			body={Type, DataSMResp}}=PDU) ->


    Result = case Status of
		 'esme-rok' -> {ok, Status};
		 _ -> {rejected, Status}
	     end,
    case queue:out(Q) of
	%% If the peer acknowledges commands in the same order that
	%% they are sent, this pattern will match. This leads to
	%% efficient behaviour (FIFO).
	{{value, #pending{seq=Seq, type=TypeQ, from=From, time=Time}}, Q1} when
	      Type==TypeQ; Type=='generic-nack' ->
	    TimeSent = Time - (get_config())#smpp_config.resp_timeout,
	    catch slog:delay(perf, ?MODULE, ack_delay, TimeSent),
	    catch ussd_server:gen_reply(From, Result),
	    State1 = State#state{queue=Q1, free=Free+1},
	    do_timeouts(State1);
	%% Otherwise we need to filter the whole queue (slower). TODO
        %% If required, we can manage a hashtable in addition to the
        %% queue to avoid this.
	{{value, _}, _} ->
	    case remove_pending(Seq, Type, Q) of
		{ok, Q1, #pending{from=From, time=Time}} ->
		    do_trace("Out-of-order reply~n"),
		    TimeSent = Time - (get_config())#smpp_config.resp_timeout,
		    catch slog:delay(perf, ?MODULE, ack_delay_ooo, TimeSent),
		    catch ussd_server:gen_reply(From, Result),
		    State1 = State#state{queue=Q1, free=Free+1},
		    do_timeouts(State1);
		_ ->
		    %% TODO Provide an option to ignore this ?
		    {stop, {unexpected_resp, PDU}, State}
	    end
    end.

%% +type tcp_send_pdu(smpp_pdu()) -> ok.
%%%% Encodes and sends a PDU.
%%%% Does some consistency checks first.

tcp_send_pdu(PDU) ->
    check_command_id(PDU), %% TODO DEBUG ONLY
    case asn1ct:encode(?ASN1_MODULE, 'SMPP-PDU', PDU) of
	{ok, Stream} ->
	    %% Here Stream is a deeplist(binary()|byte()).
	    %% Call list_to_binary/1 (costly) only if trace is enabled.
	    case (get_config())#smpp_config.trace of
		true -> trace("Encoded PDU ~w~n", [list_to_binary(Stream)]);
		false -> ok
	    end,
	    ok = gen_tcp:send(get_sock(), Stream),
	    ok;
	{error, E} ->
	    exit({asn1_encoding, E, PDU})
    end.

%% +type check_command_id(smpp_pdu()) -> ok.
%%%% Exits if the PDU has inconsistent or unsupported command_id and
%%%% body types.
%%%% This function must be updated whenever support for a new PDU type
%%%% is added.

check_command_id(#'SMPP-PDU'{'command-id'=CID, body={Tag,_}}=PDU) ->
    case {CID, Tag} of
	{?GENERIC_NACK, 'generic-nack'} -> ok;
	{?OUTBIND, 'outbind'} -> ok;
	{?BIND_TRANSCEIVER, 'bind-transceiver'} -> ok;
	{?BIND_TRANSCEIVER_RESP, 'bind-transceiver-resp'} -> ok;
	{?DATA_SM, 'data-sm'} -> ok;
	{?DATA_SM_RESP, 'data-sm-resp'} -> ok;
	{?ENQUIRE_LINK, 'enquire-link'} -> ok;
	{?ENQUIRE_LINK_RESP, 'enquire-link-resp'} -> ok;
	{?UNBIND, 'unbind'} -> ok;
	{?UNBIND_RESP, 'unbind-resp'} -> ok;
	_ -> exit({bug, command_id, PDU})
    end.

%% +type remove_pending(integer(), atom(), queue(pending())) ->
%%   {ok, queue(pending()), pending()} | error.
%%%% Removes pending request number Seq from a queue.

remove_pending(Seq, Type, Q) ->
    remove_pending(Seq, Type, Q, queue:new()).

%% +type remove_pending(integer(), atom(),queue(pending()),queue(pending())) ->
%%   {ok, queue(pending()), pending()} | error.

remove_pending(Seq, Type, Q, NewQ) ->
    case queue:out(Q) of
	{{value, #pending{seq=Seq, type=TypeQ}=Removed}, Q1} when
	      Type==TypeQ; Type=='generic-nack' ->
	    Q2 = lists:foldl({queue,in}, NewQ, queue:to_list(Q1)),
	    {ok, Q2, Removed};
	{{value,V}, Q1} ->
	    remove_pending(Seq, Type, Q1, queue:in(V, NewQ));
	{empty, _} ->
	    error
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% handle_call
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type handle_call(Request, From, state()) -> gs_hinfo_result(state()).
handle_call({insert, #sms_insert{}=SMS}, From, #state{st=bound_trx}=State) ->


    %% TODO We could check whether State#state.free>0 here
    DataSM = make_data_sm(SMS),
    PDU = #'SMPP-PDU'{body={'data-sm', DataSM}},
    case send_command(State, From, PDU) of
	{ok, State1} ->
	    do_timeouts(State1);
	{queued, State1} ->
	    do_timeouts(State1);
	E ->
	    do_timeouts(State)
    end;
handle_call(#router_req{fep_req=USSD}, From, #state{st=bound_trx}=State) ->

    %% TODO We could check whether State#state.free>0 here
    DataSM = make_data_sm(USSD),
    PDU = #'SMPP-PDU'{body={'data-sm', DataSM}},
    case send_command(State, From, PDU) of
	{ok, State1} ->
	    do_timeouts(State1);
	{queued, State1} ->
	    do_timeouts(State1);
	E ->
	    do_timeouts(State)
    end;
handle_call({insert, USSD}, From, State) ->

    ussd_server:gen_reply(From, {error, not_bound}),
    do_timeouts(State);

handle_call(Request, From, State) ->
    ussd_server:gen_reply(From, {error, invalid_request}),
    do_timeouts(State).
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type make_data_sm(ussd_msg()) -> DATA_SM_BODY. % TODO
make_data_sm(#sms_insert{sa=SA,sca=SCA,
			 submit=#sms_submit{rd=RD,vp=VP,ddt=DDT,srr=SRR,
					   udhi=UDHI,rp=RP,mr=MR,da=DA,
					   pid=PID,dcs=DCS,udl=UDL,ud=UD}}) ->
    DCSCode = case DCS of
		  default_alphabet       -> [0,0,0,0,0,0,0,0];
		  ascii                  -> [0,0,0,0,0,0,0,1];
		  eightbit_data          -> [0,0,0,0,0,0,1,0];
		  {eightbit_data,_Class} -> [0,0,0,0,0,0,1,0];
		  latin1                 -> [0,0,0,0,0,0,1,1]
	      end,
    #'DATA-SM-BODY'{'service-type'="",
		    'source-addr-ton'=international,
		    'source-addr-npi'=isdn,
		    'source-addr'="100", 
		    'dest-addr-ton'=asn1_NOVALUE,
		    'dest-addr-npi'=asn1_NOVALUE,
		    'destination-addr'=DA,
		    'esm-class'=[0,0,0,0,0,0,0,0],
		    'registered-delivery'=[0,0,0,0,0,0,0,0],
		    'data-coding'=DCSCode,
		    'message-payload'=UD};

make_data_sm(#ussd_msg{msaddr=MSADDR,dcs=DCS,op=Op,data=Data,info=Info}) ->
    DCSCode = case DCS of
		  default_alphabet       -> [0,0,0,0,0,0,0,0];
		  ascii                  -> [0,0,0,0,0,0,0,1];
		  eightbit_data          -> [0,0,0,0,0,0,1,0];
		  {eightbit_data,_Class} -> [0,0,0,0,0,0,1,0];
		  latin1                 -> [0,0,0,0,0,0,1,1];
		  ucs2                   -> [0,0,0,0,1,0,0,0]
	      end,
    OpCode = encode_ussd_op(Op),
    %% Put the MSISDN is either in source-addr or dest-addr, depending
    %% on the USSD op.
    S_NONE = {asn1_NOVALUE, asn1_NOVALUE, asn1_NOVALUE},
    D_NONE = {asn1_NOVALUE, asn1_NOVALUE, asn1_NOVALUE}, % dest now optional
    I_NONE = asn1_NOVALUE,
    IMSI = case lists:keysearch(msaddr, 1, Info) of
	       {value, {_,{subscriber_number,private,IMSI_}}} ->
		   [160 | IMSI_];
	       _ ->
		   asn1_NOVALUE
	   end,
    {{S_TON,S_NPI,S_ADDR},S_SUBADDR, {D_TON,D_NPI,D_ADDR},D_SUBADDR} =
	case Op of
	    pssd -> {MSADDR,IMSI, D_NONE,I_NONE};
	    pssr -> {MSADDR,IMSI, D_NONE,I_NONE};
	    ussr -> {S_NONE,I_NONE, MSADDR,IMSI};
	    ussn -> {S_NONE,I_NONE, MSADDR,IMSI};
	    pssd_response -> {S_NONE,I_NONE, MSADDR,IMSI};
	    pssr_response -> {S_NONE,I_NONE, MSADDR,IMSI};
	    ussr_response -> {MSADDR,IMSI, D_NONE,I_NONE};
	    ussn_response -> {MSADDR,IMSI, D_NONE,I_NONE};
	    hangup  -> {MSADDR,IMSI, D_NONE,I_NONE};
	    failure -> {MSADDR,IMSI, D_NONE,I_NONE};
	    reject  -> {MSADDR,IMSI, D_NONE,I_NONE}
	end,
    RMID = case lists:keysearch(receipted_message_id, 1, Info) of
	       {value, {_,RMID_}} -> RMID_;
	       false -> asn1_NOVALUE
	   end,
    %% TODO This warning is mostly for debugging.
    case RMID of
	asn1_NOVALUE -> ok; %% io:format("SMPPASN: USSD-C ID not sent~n");
	_ -> ok
    end,
    %% TODO should we encode source/dest-addr in swapped BCD ?
    #'DATA-SM-BODY'{'service-type'="USSD",
		    'source-addr-ton'=opt_encode_ton(S_TON),
		    'source-addr-npi'=S_NPI,
		    'source-addr'=S_ADDR,
		    'source-subaddress'=S_SUBADDR,
		    'dest-addr-ton'=opt_encode_ton(D_TON),
		    'dest-addr-npi'=D_NPI,
		    'destination-addr'=D_ADDR,
		    'dest-subaddress'=D_SUBADDR,
		    'esm-class'=[0,0,0,0,0,0,0,1],
		    'registered-delivery'=[0,0,0,0,0,0,0,1],
		    'data-coding'=DCSCode,
		    'message-payload'=Data,
		    'receipted-message-id'=RMID,
		    'ussd-service-op'=[OpCode]}.

%% +type encode_ussd_op(ussd_op()) -> byte().

encode_ussd_op(pssd)          -> ?PSSD_INDICATION;
encode_ussd_op(pssr)          -> ?PSSR_INDICATION;
encode_ussd_op(ussr)          -> ?USSR_REQUEST;
encode_ussd_op(ussn)          -> ?USSN_REQUEST;
encode_ussd_op(pssd_response) -> ?PSSD_RESPONSE;
encode_ussd_op(pssr_response) -> ?PSSR_RESPONSE;
encode_ussd_op(ussr_response) -> ?USSR_CONFIRM;
encode_ussd_op(ussn_response) -> ?USSN_CONFIRM;
encode_ussd_op(hangup)        -> ?USSD_HANGUP;
encode_ussd_op(failure)       -> ?USSD_FAILURE;
encode_ussd_op(reject)        -> ?USSD_REJECT.

%% +type opt_encode_ton(ton()|asn1_NOVALUE) -> smpp_ton()|asn1_NOVALUE.

opt_encode_ton(asn1_NOVALUE=N) -> N;
opt_encode_ton(subscriber_number) -> subscriberNumber;
opt_encode_ton(network_specific) -> networkSpecific;
opt_encode_ton(TON) -> TON.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type send_outbind(smpp_outbind_config()) -> *.
%%%% Sends OUTBIND. Note: OUTBIND is not queued.

send_outbind(#smpp_outbind_config{system_id=SystemID,password=Password}) ->
    Body = #'OUTBIND-BODY'{'system-id'=SystemID, 'password'=Password},
    PDU = #'SMPP-PDU'{'command-id'=?OUTBIND,
		      'command-sequence'=0,
		      %% TODO should be optional
		      'command-status'='esme-rok',
		      body={outbind, Body}},
    tcp_send_pdu(PDU).

%% +type send_bind(state(), smpp_bind_config()) -> async_send_result().

send_bind(State, #smpp_bind_config{system_id=SystemID, password=Password,
				   system_type=SystemType,
				   interface_version=Version,
				   addr_ton=TON, addr_npi=NPI,
				   address_range=AddrRange}) ->
    Body = #'BIND-TRANSCEIVER-BODY'{'system-id'=SystemID, 'password'=Password,
				    'system-type'=SystemType,
				    'interface-version'=Version,
				    'addr-ton'=opt_encode_ton(TON),
				    'addr-npi'=NPI,
				    'address-range'=AddrRange},
    PDU = #'SMPP-PDU'{body={'bind-transceiver', Body}},
    send_command(State, no_client, PDU).

%% +type send_enquire_link(state()) -> async_send_result().

send_enquire_link(State) ->
    PDU = #'SMPP-PDU'{body={'enquire-link', 'NULL'}},
    send_command(State, no_client, PDU).

%% +type send_command(state(), From, smpp_pdu()) -> async_send_result().
%%%% Sets 'command-id', 'command-sequence' and 'command-status'.
%%%% Sends the encoded PDU on the TCP link
%%%% Queues the PDU if #smpp_config{resp_timeout=Int}.
%%%% If not queued, replies to the gen_server client.

%% +deftype async_send_result() = {queued, state()}
%%                              | {ok, state()}
%%                              | {full, timeout_time()}.

send_command(#state{queue=Q, free=0}=State, From, PDU) ->
    %% free=0 means the SMPP queue is full.
    {{value, #pending{time=Deadline}}, _} = queue:out(Q),
    %% Report an error. Indicate in how long the queue will decrease.
    Timeout = case Deadline - util_unixmtime() of
		  T when T>0 -> T;
		  _ -> 1
	      end,
    Error = {full, Timeout},
    catch ussd_server:gen_reply(From, Error),
    Error;

send_command(#state{queue=Q, free=Free, seq=Seq}=State, From,
	     #'SMPP-PDU'{body={Tag,Body}}=PDU) ->
    Now = util_unixmtime(),
    {CommandID, RespType} = command_id_of_tag(Tag),
    SeqPDU = Seq,
    PDU1 = PDU#'SMPP-PDU'{'command-sequence'=SeqPDU, 'command-id'=CommandID },
						% , 'command-status'='esme-rok'
    tcp_send_pdu(PDU1),
    %% Update seq and last_active
    Seq1 = (Seq+1) band 16#7FFFFFFF,
    State1 = case PDU1#'SMPP-PDU'.body of
		 {'enquire-link', _} ->
		     %% enquire-link does not reset the inactivity_timer.
		     State#state{seq=Seq1};
		 _ -> State#state{seq=Seq1, last_active=Now}
	     end,
    case (get_config())#smpp_config.resp_timeout of
	no ->
	    %% RESP not used. Reply directly to the client.
	    catch ussd_server:gen_reply(From, {ok, sent}),
	    {ok, State1};
	RespTimeout ->
	    %% The reply will be sent to the client when the RESP is received.
	    Pending = #pending{seq=SeqPDU, type=RespType,
			       time=Now+RespTimeout, from=From},
	    Q1 = queue:in(Pending, Q),
	    {queued, State1#state{queue=Q1, free=Free-1}}
    end.

%% +type command_id_of_tag(command::atom()) -> {integer(), resp::atom()}.

command_id_of_tag('bind-transceiver') -> {?BIND_TRANSCEIVER,
					  'bind-transceiver-resp'};
command_id_of_tag('data-sm') ->          {?DATA_SM, 'data-sm-resp'};
command_id_of_tag('enquire-link') ->     {?ENQUIRE_LINK, 'enquire-link-resp'};
command_id_of_tag('unbind') ->           {?UNBIND, 'unbind-resp'};
command_id_of_tag(Tag) -> exit({unsupported_message_type, Tag}).

%% +type opt_send_resp(status::atom(), integer(), {atom(),Body}) -> *.
%%%% Sends a RESP pdu (if configured for using RESP).

opt_send_resp(Status, Seq, {Tag, _}=Body) ->
    Config = get_config(),
    case Config#smpp_config.resp_timeout of
	no -> resp_not_used;
	_Timeout -> 
	    PDU = #'SMPP-PDU'{'command-id'=resp_id_of_tag(Tag),
			      'command-sequence'=Seq,
			      'command-status'=Status,
			      body=Body},
	    %% Send RESP (possibly out-of-order, for debugging)
	    case Config#smpp_config.async_resp of
		no -> tcp_send_pdu(PDU);
		Delay -> spawn_link(?MODULE, send_resp_aux,
				    [random:uniform(Delay), get_sock(), PDU])
	    end
    end.

%% +type send_resp_aux(ms::integer(), socket(), smpp_pdu()) -> *.

send_resp_aux(Delay, Sock, PDU) ->
    receive after Delay -> ok end,
    put(sock, Sock),
    tcp_send_pdu(PDU).

%% +type resp_id_of_tag(resp::atom()) -> integer().

resp_id_of_tag('bind-transceiver-resp') -> ?BIND_TRANSCEIVER_RESP;
resp_id_of_tag('data-sm-resp') ->          ?DATA_SM_RESP;
resp_id_of_tag('enquire-link-resp') ->     ?ENQUIRE_LINK_RESP;
resp_id_of_tag('unbind-resp') ->           ?UNBIND_RESP;
resp_id_of_tag('generic-nack') ->          ?GENERIC_NACK;
resp_id_of_tag(Tag) -> exit({unsupported_message_type, Tag}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_timeouts(state()) -> gs_hinfo_result(state()).
%%%% Check and compute response_timer and enquire_link_timer.

do_timeouts(State) ->
    catch do_timeouts1(State).

%% +type do_timeouts1(state()) -> gs_hinfo_result(state()).
%%%% Same as do_timeouts. May throw {stop, ...}.

do_timeouts1(#state{st={expect_outbind,_}}=State) ->
    check_init_timeout(State);

do_timeouts1(#state{st={expect_bind,_}}=State) ->
    check_init_timeout(State);

do_timeouts1(#state{queue=Q, last_alive=LastAlive,
		   last_active=LastActive}=State) ->
    Now = util_unixmtime(),
    Config = get_config(),
    %% Compute the next inactivity timeout.
    %% Stop if it has already expired.
    InactTimeout =
	case Config#smpp_config.inact_timeout of
	    infinity -> infinity;
	    IT when Now >= LastActive+IT ->
		trace("Inactivity_timeout~n"),
		throw({stop, inactivity_timeout, State});
	    IT -> LastActive + IT - Now
	end,
    %% Compute the next 'enquire_link' expiration.
    %% Send it if already expired. In this case we need to return a
    %% new state with a new queue.
    {State1, LinkTimeout} =
	case Config#smpp_config.enquire_timeout of
	    infinity -> {State, infinity};
	    ET when Now >= LastAlive+ET ->
		case send_enquire_link(State) of
		    {queued, St1} ->
			%% Set last_alive to Now, so that we won't
			%% enquire_link again.
			{St1#state{last_alive=Now}, infinity};
		    {ok, St1} ->
			exit({bug, config_enquire_link_without_resp});
		    {full, _Timeout} ->
			%% This should not happen unless resp_timeout
			%% is close to enquire_timeout, which is stupid.
			exit({bug, enquire_link_while_busy,
			     enquire_timeout_too_small})
		end;
	    ET -> {State, LastAlive+ET-Now}
	end,
    %% Compute the next 'resp_timer' expiration.
    %% Exit if a resp_timer has already expired.
    RespTimeout = 
	case queue:out(Q) of
	    {{value, #pending{time=Deadline}}, Q1} when Now >= Deadline ->
		%% Expired.
		slog:event(warning, ?MODULE, {interface_shutdown,
						 resp_timeout}),
		throw({stop, shutdown, State1});
	    {{value, #pending{time=Deadline}}, Q1} ->
		RT = Deadline - Now,
		util_min_time(LinkTimeout, RT);
	    {empty, Q1} ->
		infinity
	end,
    Timeout = util_min_time(util_min_time(LinkTimeout, InactTimeout),
			    RespTimeout),
    {noreply, State1, Timeout}.

%% +type check_init_timeout(state()) -> gs_hinfo_result(state()).

check_init_timeout(#state{start_time=StartTime}=State) ->
    Deadline = StartTime + (get_config())#smpp_config.init_timeout,
    case Deadline - util_unixmtime() of
	T when T > 0 ->
	    {noreply, State, T};
	_ -> {stop, {error,session_init_timeout}, State}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type code_change(Vsn, state(), M) -> {ok, state()}.

code_change(Old, State, Extra) ->
    {ok, State}.

%% +type handle_cast(M, state()) -> gs_hcast_result(state()).

handle_cast(Req, S) ->
    {noreply, S}.

%% +type terminate(R, state()) -> ok.

terminate(Reason, S) -> % TODO
    gen_tcp:close(get_sock()),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type parse_data_sm(DATA_SM_BODY) ->
%%         {ussd_msg()|no_message,
%%          command_status(), error_info::string()|asn1_NOVALUE}.
%%%% This function may also exit or throw
%%%% {no_message, command_status(), info_max255::string()}.

parse_data_sm(#'DATA-SM-BODY'{'service-type'=ServiceType,
			      'data-coding'=DCSCode,
			      'message-payload'=Data,
			      'receipted-message-id'=RMID,
			      'vlr-number'=VLRNumber,
			      'ussd-service-op'=[OpCode]}=PDU) ->
    case ServiceType of
	"USSD" -> ok;
 	_ -> throw({no_message, 'esme-rsyserr', "Expected service-type=USSD"})
    end,
    %% Decode the ussd-service-op (may exit with an error).
    Op = decode_ussd_op(OpCode),
    %% Now identify the mobile terminal.
    {{TON,NPI,ADDR}, OptAddrs} = get_ms_addr(Op, PDU),
    %% The 3 checks below should not fail since get_ms_addr already
    %% reports problems.
    check_asn_opt(TON, 'esme-rinvsrcadr', "TON missing"),
    check_asn_opt(NPI, 'esme-rinvsrcadr', "NPI missing"),
    check_asn_opt(ADDR, 'esme-rinvsrcadr', "ADDR missing"),
    %% Now the Data Coding Scheme.
    DCS = case DCSCode of
	      [0,0,0,0,0,0,0,0] -> default_alphabet;
	      [0,0,0,0,0,0,0,1] -> ascii;
	      [0,0,0,0,0,0,1,0] -> eightbit_data;
	      [0,0,0,0,0,0,1,1] -> latin1;
	      [0,0,0,0,1,0,0,0] -> ucs2;
	      [] ->
		  %% TODO This matches SIReS's implementation,
		  %% but should not be in the final version.
		  do_trace("Warning: empty data-coding, using ascii~n"),
		  ascii;
	      _ -> ErrInfo = io_lib:format("Unsupported DCS ~w~n", [DCSCode]),
		   throw({no_message, 'esme-rsyserr', lists:flatten(ErrInfo)})
	  end,
    check_asn_opt(Data, 'esme-rsyserr', "message-payload missing"),
    Info =
	OptAddrs ++
	case RMID of
	    asn1_NOVALUE -> [];
	    _ -> [ {receipted_message_id, RMID} ]
	end ++
	case VLRNumber of
	    asn1_NOVALUE -> [];
	    _ -> 
		case catch pbutil:bin2dial(VLRNumber) of
		    DecodedVLR when list(DecodedVLR) ->  
			%% Removing padding bits 
			SessionVLR = string:strip(DecodedVLR,right,$F),
			[ {vlr_number, SessionVLR} ];
		    _ -> []
		end
	end ++
	[ {interface, self()} ],
    USSD = #ussd_msg{ msaddr={TON,NPI,ADDR}, op=Op,
		      dcs=DCS, data=Data,
		      info=Info},
    {USSD, 'esme-rok', asn1_NOVALUE}.

%% +type get_ms_addr(ussd_op(), DATA_SM_BODY) -> {gsm_addr(),[OptAddr]}.
%%%% This function may also exit or throw
%%%% {no_message, command_status(), info_max255::string()}.

get_ms_addr(Op, #'DATA-SM-BODY'{'source-addr-ton'=S_TON,
				'source-addr-npi'=S_NPI,
				'source-addr'=S_ADDR,
				'source-subaddress'=S_SUBADDR,
				'dest-addr-ton'=D_TON,
				'dest-addr-npi'=D_NPI,
				'destination-addr'=D_ADDR,
				'dest-subaddress'=D_SUBADDR}) ->
    %% The MS address is either in source-addr or dest-addr,
    %% depending on the USSD operation.
    {SMPPTON, NPI, ADDR, SUBADDR} =
	case Op of
	    pssd -> {S_TON, S_NPI, S_ADDR, S_SUBADDR};
	    pssr -> {S_TON, S_NPI, S_ADDR, S_SUBADDR};
	    ussr -> {D_TON, D_NPI, D_ADDR, D_SUBADDR};
	    ussn -> {D_TON, D_NPI, D_ADDR, D_SUBADDR};
	    pssd_response -> {D_TON, D_NPI, D_ADDR, D_SUBADDR};
	    pssr_response -> {D_TON, D_NPI, D_ADDR, D_SUBADDR};
	    ussr_response -> {S_TON, S_NPI, S_ADDR, S_SUBADDR};
	    ussn_response -> {S_TON, S_NPI, S_ADDR, S_SUBADDR};
	    hangup  -> {S_TON, S_NPI, S_ADDR, S_SUBADDR};
	    failure -> {S_TON, S_NPI, S_ADDR, S_SUBADDR};
	    reject  -> {S_TON, S_NPI, S_ADDR, S_SUBADDR}
	end,
    if true ->
	    %% Special case for SIReS: Use IMSI in SUBADDR as the main address.
	    %% Also transmit the MSISDN in #ussd_msg.info.
	    Sub = 
		case SUBADDR of
		    asn1_NOVALUE -> undefined;
		    [160|IMSI] -> {subscriber_number,private,IMSI};
		    IMSI ->
			case length(IMSI) of
			    15 -> {subscriber_number,private,IMSI};
			    _  -> throw({no_message, 'esme-rsyserr',
					 "Invalid subaddr"})
			end
		end,
	    Main =
		if SMPPTON==asn1_NOVALUE;
		   NPI==asn1_NOVALUE;
		   ADDR==asn1_NOVALUE -> undefined;
		   true ->{decode_ton(SMPPTON),NPI,decode_addr(ADDR)}
		end,
	    case {Sub, Main} of
		{undefined, undefined} -> 
		    throw({no_message, 'esme-rsyserr', "Address missing"});
		{undefined, _} -> {Main, []};
		{_, undefined} -> {Sub, []};
		_ -> {Sub, [{msaddr,Main}]}
	    end;
       true ->
	    %% Normal case
	    if SMPPTON==asn1_NOVALUE;
	       NPI==asn1_NOVALUE;
	       ADDR==asn1_NOVALUE ->
		    throw({no_message, 'esme-rsyserr', "Address missing"});
	       true ->
		    {{decode_ton(SMPPTON),NPI,ADDR}, []}
	    end
    end.

%% +type decode_ussd_op(byte()) -> ussd_op().

decode_ussd_op(?PSSD_INDICATION) -> pssd;
decode_ussd_op(?PSSR_INDICATION) -> pssr;
decode_ussd_op(?USSR_REQUEST)    -> ussr;
decode_ussd_op(?USSN_REQUEST)    -> ussn;
decode_ussd_op(?PSSD_RESPONSE)   -> pssd_response;
decode_ussd_op(?PSSR_RESPONSE)   -> pssr_response;
decode_ussd_op(?USSR_CONFIRM)    -> ussr_response;
decode_ussd_op(?USSN_CONFIRM)    -> ussn_response;
decode_ussd_op(?USSD_HANGUP)     -> hangup;
decode_ussd_op(?USSD_FAILURE)    -> failure;
decode_ussd_op(?USSD_REJECT)     -> reject;
decode_ussd_op(OpCode) -> exit({"USSD-OP not implemented", OpCode}).

%% +type decode_ton(smpp_ton()) -> ton().
%%%% Maps ASN.1 TON atoms to ours.

decode_ton(subscriberNumber) -> subscriber_number;
decode_ton(networkSpecific) -> network_specific;
decode_ton(TON) -> TON.

%% +type decode_addr(gsm_addr()) -> gsm_addr().
%%%% update msisdn format.

decode_addr("33" ++ Msisdn) ->
    "+33" ++ Msisdn;
decode_addr(Msisdn) ->
    Msisdn.

%% +type check_asn_opt(asn1_NOVALUE|term(), command_status(), string()) -> *.
%%%% Throws {no_message, Status, Info} if the first argument is NULL.

check_asn_opt(asn1_NOVALUE, Status, Info) ->
    throw({no_message, Status, Info});
check_asn_opt(Value, Status, Info) -> ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% The following function are copied from other modules.
%%%% This allows smppasn_server to be exported standalone.

%% +type util_unixmtime() -> milliseconds::integer().

util_unixmtime() -> {MS,S,US} = now(), (MS*1000000+S)*1000 + US div 1000.

%% +type util_min_time(timeout_time(), timeout_time()) -> timeout_time().

util_min_time(infinity, T) -> T;
util_min_time(T, infinity) -> T;
util_min_time(T1, T2) when T1 < T2 -> T1;
util_min_time(T1, T2) -> T2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trace(S) -> trace(S, []).

trace(FMT, Args) ->
    case (get_config())#smpp_config.trace of
	  true -> do_trace(FMT, Args);
	  false -> ok
    end.

do_trace(S) -> do_trace(S, []).

do_trace(FMT, Args) ->
    {H,M,S} = time(),
    io:format("SMPPASN ~p:~p:~p ~p: "++FMT, [H,M,S,self()|Args]).

%% +private.

%% +deftype 'SMPP-PDU'() = #'SMPP-PDU'{
%%     'command-id' :: integer(),
%%     'command-status' :: command_status(),
%%     'command-sequence' :: integer(),
%%     body :: Body
%% }.
%% +deftype smpp_pdu() = 'SMPP-PDU'().
%%
%% +deftype smpp_ton() = unknown
%% 		       | international
%% 		       | national
%% 		       | networkSpecific
%% 		       | subscriberNumber
%% 		       | alphanumeric
%% 		       | abbreviated.
%%
%% +deftype command_status() = 
%%     	 'esme-rok'
%%     | 'esme-rinvmsglen'
%%     | 'esme-rinvcmdlen'
%%     | 'esme-rinvcmdid'
%%     | 'esme-rinvbndsts'
%%     | 'esme-ralybnd'
%%     | 'esme-rinvprtflg'
%%     | 'esme-rinvregdlvflg'
%%     | 'esme-rsyserr'
%%     | 'esme-rinvsrcadr'
%%     | 'esme-rinvdstadr'
%%     | 'esme-rinvmsgid'
%%     | 'esme-rbindfail'
%%     | 'esme-rinvpaswd'
%%     | 'esme-rinvsysid'
%%     | 'esme-rcancelfail'
%%     | 'esme-rreplacefail'.

%% +usedeftype([timeout_time/0, unix_mtime/0]).
%% +usedeftype([now/0, string/0, io_format/0]).
%% +usedeftype([byte/0, bytes/0, long/0, short/0, hexchar/0, hexstring/0]).
%% +usedeftype([gs_start_result/0, gs_init_result/1]).
%% +usedeftype([gs_hinfo_result/1, gs_hcast_result/1]).
%% +usedeftype([smpp_ton/0]).
%% +usedeftype([smpp_pdu/0, smpp_send_result/0]).
%% +usedeftype([smpp_config/0, smpp_bind_config/0, smpp_outbind_config/0]).
%% +usedeftype([gsm_addr/0, ton/0, npi/0]).
%% +usedeftype([sms_dcs/0]).
%% +usedeftype([ussd_msg/0, ussd_op/0]).


