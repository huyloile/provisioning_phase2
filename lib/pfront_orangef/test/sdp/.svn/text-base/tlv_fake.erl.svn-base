-module(tlv_fake).
-compile(export_all).

-include("../../../../lib/pfront/include/pfront.hrl").
-include("../../../../lib/pfront_orangef/include/tlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start() -> proc_lib:start(?MODULE, run, []).
start_reliable() -> proc_lib:start(?MODULE, run_reliable, []).
     
run() ->
    global:register_name(tlv_fake, self()),
    io:format("registered ~p~n", [global:whereis_name(tlv_fake)]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 100),
    available().

run_reliable() ->
    global:register_name(tlv_fake, self()),
    proc_lib:init_ack({ok, self()}),
    io:format("registered ~p~n", [global:whereis_name(tlv_fake)]),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 50),
    available().

available() ->
    receive
	{Client, connect} ->
	    link(Client),
	    Client ! {self(), connected},
	    io:format("~p connected~n", [Client]),
	    connected(Client);
	M -> pbutil:badmsg(M, ?MODULE),
	     available()
    after 1000 ->
	    available()
    end.

connected(Client) ->
    receive
	{'EXIT', Client, E} ->
	    io:format("~p crashed : ~p~n", [Client, E]),
	    available();
	{Client, {command, Req}} ->
	    %% Requests may be deeplists.
	    %%Request = lists:flatten(Req)
	    xdebug("~p > \"~s\"~n", [Client, Req]),
	    case catch request(Req) of
		{'EXIT', E} ->
		    xdebug("Error: ~p~n", [E]),
		    %% Let the client timeout
		    connected(Client);
		Reply ->
		    xdebug("~p < \"~s\"~n", [Client, Reply]),
		    %% Flatten and send the reply
		    send_line(Client, Reply),
		    connected(Client)
	    end;
	{Client, close} ->
	    unlink(Client),
	    Client ! {self(), closed},
	    debug("~p disconnected~n", [Client]),
	    available();
	M -> pbutil:badmsg(M, ?MODULE)
    end.

%%%% Sends an ascii line, simulating the behaviour of a port process.

send_line(Client, Line) ->
    Client ! {self(), {data,Line}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


request(Req)->
    L=tlv_encodage:decode_packet(Req),
    io:format("Req =~p~n",[L]),
    %tlv_encodage:encode_packet(?id_all,1,{?PS_CHAR,"12345678\r"}).
    tlv_encodage:encode_packet(?id_all,?int_id27,
		      [{?CPP_SOLDE,10000},{?PS_STATUS,0},
		       {?TLV_STATUT_CR,0}]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debug(_) -> ok.
debug(_, _) -> ok.

xdebug(Format) ->
    debug(Format, []).
xdebug(Format, Args) ->
    %io:format("~p: "++Format, [?MODULE | Args]),
    ok.
