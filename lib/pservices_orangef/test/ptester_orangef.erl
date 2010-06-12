-module(ptester_orangef).

-export([test_command/1]).


-define(TIMEOUT, 60000).

%% +deftype service_test_orangef() = [service_test_action_orangef()].
%% +deftype service_test_action_orangef() =
%%      {connect_smppasn, {host::string(), port::integer()}}
%%    | {connect_sdp, unix_command::string()}
%%    | {connect_tlv, unix_command::string()}
%%    | {sdp, [ {send,regexp::string()} | {expect, regexp::string()} ]}
%%    | {tlv, [ {send,regexp::string()} | {expect2, regexp::string()} ].

ussd_handler() ->
    
    Scheduler = self(),
        %% Make the smpp_server look like a ussdloop_server.
    fun (USSD) ->
             Scheduler ! {fake_insert_ussd, USSD} end.

test_command({connect_smppasn, Server}) ->
    case get({interface, smpp}) of
	undefined ->
	    io:fwrite("Connecting SMPPASN~n"),
            SockOpts = [ {active,true}, {packet,asn1}, binary ],
            Pid =  ptester:start_interface({smpp, ptester_smppasn_client,
                                            ussd_handler(), Server,
                                            {smppasn_server, SockOpts}}),

    	    InterfacePID = {{smpp, Server}, Pid},
	    put({interface, smpp}, InterfacePID);
	_ -> already_started
    end;

test_command({connect_sdp, Command}) ->
    case get({interface, sdp}) of
	undefined ->
	    io:fwrite("Connecting SDP (~p)~n", [Command]),
	    Pid = open_port({spawn, lists:flatten(Command)}, [{line,10000}]),
	    receive
		{_, {data, {eol,Reply}}} ->
		    io:fwrite("SDP banner ~p~n", [Reply]), ok
	    after ?TIMEOUT ->
		    exit({timeout, sdp})
	    end,
	    put({interface, sdp}, Pid);
	_ ->
	    already_started
    end;

test_command({connect_tlv, Command}) ->
    case get({interface, tlv}) of
	undefined ->
	    io:fwrite("Connecting TLV (~p)~n", [Command]),
	    Pid = open_port({spawn, lists:flatten(Command)}, [binary]),
	    put({interface, tlv}, Pid);
	_ ->
	    already_started
    end;

test_command({sdp, Sequence}) ->
    Sequence1 = lists:map(fun test_service:subst_command/1, Sequence),
    lists:foreach(fun sdp_command/1, Sequence1);

test_command({tlv, Sequence}) ->
    Sequence1 = lists:map(fun subst_command2/1, Sequence),
    lists:map(fun tlv_command/1, Sequence1).

subst_command2(C)->
    io:fwrite("command ~p~n",[C]),
    C.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sdp_command({send, Request}) ->
    ptester:trace_test({sdp, send, Request}),
    Port = get({interface, sdp}),
    pbutil:send_port(Port, Request);

sdp_command({expect, RegExp}) ->
    Port = get({interface, sdp}),
    receive
	{Port, {data, {eol, Reply}}} ->
	    case regexp:match(Reply, RegExp) of
		{match, _, _} ->
		    ptester:trace_test({sdp, recv, {RegExp, Reply, ok}}),
		    ok;
		_ ->
		    ptester:trace_test({sdp, recv, {RegExp, Reply, nok}}),
		    exit({failed, RegExp, Reply})
	    end
    after ?TIMEOUT ->
	    ptester:trace_test({sdp, recv, {RegExp, timeout, nok}}),
	    exit({timeout, sdp})
    end;

sdp_command(Command) ->
    exit({unknown_sdp_command, Command}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tlv_command({send, Request}) ->
    ptester:trace_test({tlv, send, Request}),
    Port = get({interface, tlv}),
    pbutil:send_port(Port, Request);

tlv_command({expect2, RegExp}) ->
    Port = get({interface, tlv}),
    receive
	{Port,Reply} ->
	    {data,Bin} = Reply,
	    case catch tlv_encodage:decode_packet(Bin) of 
		{ok,Result}->
		    %%ptester:trace_test({tlv, recv, {RegExp,"ok", ok}}),
		    io:fwrite("TLV > ~p~n",[dec_tlv_result(Result)]),
		    ok;
		_ ->
		    tlv_command({expect2, RegExp})
	    end
    after ?TIMEOUT ->
	    ptester:trace_test({tlv, recv, {RegExp, timeout, nok}}),
	    exit({timeout, sdp})
    end;

tlv_command(Command) ->
    exit({unknown_tlv_command, Command}).

dec_tlv_result([0,0]) -> ok;
dec_tlv_result([0,0,0]) -> ok;
dec_tlv_result([_,0,0]) -> ok;
dec_tlv_result([_,_,0,0]) -> ok;
dec_tlv_result([_,_,_,0,0]) -> ok;
dec_tlv_result([_,_,_,0,0,0]) -> ok;
dec_tlv_result([99,0]) -> base_KC;
dec_tlv_result([111,0]) -> le_type_de_compte_nexiste_pas;
dec_tlv_result([127,0]) -> le_dossier_nexiste_pas;
dec_tlv_result([161,0]) -> le_plan_tarifaire_nexiste_pas;
dec_tlv_result([182,0]) -> le_cmpte_a_debiter_nexistepas_ou_napasassezde_solde;
dec_tlv_result(X) -> X.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
