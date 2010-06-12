-module(create50_test).
-export([run/0]).
%% {ok,_}=c:c(create100), create100:run().

run() ->
    Command =
	"rsh io0 -l clcm /home/clcm/install-20011115/cellicium/possum/lib/"
	"pgsm/priv/i386-redhat-linux/fsx25port.out -c FTM 176184943730601",
    % Command = "echo FTMREAD; cat",
    Pid = open_port({spawn, lists:flatten(Command)}, []),
    receive
	{Port, {data, Reply}} ->
	    io:format("TEST:  SDP banner ~p~n", [Reply])
    after 5000 ->
	    exit({timeout, sdp})
    end,
    put(sdp, Pid),
    loop().

loop() ->
    Line = io:get_line(""),
    {ok, [_NSC, NSCE, IMSI, MSISDN], Left} = io_lib:fread("~s ~s ~s ~s", Line),
    create(NSCE, IMSI, MSISDN),
    receive after 1000 -> ok end,
    loop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create(NSCE, IMSI, MSISDN) ->
    create(NSCE, IMSI, MSISDN, 0).
    
create(NSCE, IMSI, MSISDN, 10) ->
    io:format("FAIL ~p~n", [IMSI]);

create(NSCE, IMSI, MSISDN, L) ->
    Req = io_lib:format("FTM05 0~s ~s~p ~s TEST 112 0 31 3600 144000 16",
			[MSISDN, NSCE, L, IMSI]),
    case sdp_req(Req) of
	[$F,$T,$M,$0,$5,$ ,_,_,_,_,_,_,_,_,_,_, $ ,$0,$0 | _] ->
	    io:format("OK ~s ~p~n", [IMSI, L]),
	    validate(IMSI, MSISDN);
	[$F,$T,$M,$0,$5,$ ,_,_,_,_,_,_,_,_,_,_, $ ,$9,$7|_] ->
	    io:format("DUP ~s ~p~n", [IMSI, L]),
	    validate(IMSI, MSISDN);
	_ ->
	    io:format("BAD ~s ~p~n", [IMSI, L]),
	    create(NSCE, IMSI, MSISDN, L+1)
    end.

validate(IMSI, MSISDN) ->
    Req = io_lib:format("B 0~s 00000000 0 0 0 0 0", [MSISDN]),
    case sdp_req(Req) of
	[$B,_,_,_,_,_,_,_,_,_,_, $ ,$0,$0 | _] ->
	    io:format("VALID ~s~n", [IMSI]);
	_ ->
	    io:format("INVAL ~s~n", [IMSI])
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sdp_req(Request) ->
    SDP = get(sdp),
    Request1 = lists:flatten(Request),
    io:format("OUT ~p~n", [Request1]),
    SDP ! {self(), {command, Request1}},
    receive
	{SDP, {data, Reply}} -> io:format("IN ~p~n", [Reply]), Reply
    after 5000 -> io:format("TIMEOUT~n"), timeout
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
