%% Creation de 100 cartes sur le SDP de test (pour DMR).

-module(create100).
-export([run/0]).
%% {ok,_}=c:c(create100), create100:run().

run() ->
    Command =
	"rsh io0 -l clcm /home/clcm/avril/cellicium/possum/lib/pgsm/"
	"priv/i386-redhat-linux/fsx25port.out -c FTM 176184943730601",
    Pid = open_port({spawn, lists:flatten(Command)}, []),
    receive
	{Port, {data, Reply}} ->
	    io:format("TEST:  SDP banner ~p~n", [Reply])
    after 5000 ->
	    exit({timeout, sdp})
    end,
    put(sdp, Pid),
    run(40000).

run(40101) ->
     ok;
run(N) ->
    create(N, 0),
    receive after 2000 -> ok end,
    run(N+1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create(N, 10) ->
    io:format("FAIL ~p~n", [N]);

create(N, L) ->
    Req = io_lib:format("FTM05 06089~p 2006089~p~p 2080130089~p "
			"MOBI 112 0 31 3600 144000 16",
			[N, N, L, N]),
    case sdp_req(Req) of
	[$F,$T,$M,$0,$5,$ ,_,_,_,_,_,_,_,_,_,_, $ ,$0,$0 | _] ->
	    io:format("OK ~p ~p~n", [N, L]),
	    validate(N);
	[$F,$T,$M,$0,$5,$ ,_,_,_,_,_,_,_,_,_,_, $ ,$9,$7|_] ->
	    io:format("DUP ~p ~p~n", [N, L]),
	    validate(N);
	_ ->
	    io:format("BAD ~p ~p~n", [N, L]),
	    create(N, L+1)
    end.

validate(N) ->
    Req = io_lib:format("B 06089~p 00000000 0 0 0 0 0", [N]),
    case sdp_req(Req) of
	[$B,_,_,_,_,_,_,_,_,_,_, $ ,$0,$0 | _] ->
	    io:format("VALID ~p~n", [N]);
	_ ->
	    io:format("INVAL ~p~n", [N])
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sdp_req(Request) ->
    SDP = get(sdp),
    Request1 = lists:flatten(Request),
    io:format("OUT ~p~n", [Request1]),
    SDP ! {self(), {command, Request1}},
    receive
	{SDP, {data, Reply}} -> io:format("IN ~p~n", [Reply]),
				Reply
    after 5000 -> io:format("TIMEOUT~n"),
		  timeout
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
