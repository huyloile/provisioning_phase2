%% Simulation (très approximative) de l'interface DME WIFI
%% Behaves like a port process with an additional connection
%% establishment phase.

-module(wifi).
-export([run/0]).
-export([start/0, start_reliable/0]).


-export([put_fake/0,get_fake/0]).

-define(PASSWORD,"1234").

start() -> proc_lib:start(?MODULE, run, []).

start_reliable() -> proc_lib:start(?MODULE, run_reliable, []).
     
run() ->
    spawn(?MODULE,put_fake,[]),
    spawn(?MODULE,get_fake,[]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true).



put_fake() ->
    global:register_name(wifi_put_fake, self()),
    io:format("put wifi registered~n"),
    available_put().

get_fake() ->
    global:register_name(wifi_get_fake, self()),
    io:format("get wifi registered~n"),
    available_get().


available_get() ->
    receive
	{_, {command,_}} ->
	    %%%% md structure not used for erlang_process !!!
	    available_get();
	{From,Message} ->
	    Message2 = term_to_binary({get,Message}),
	    From!{self(),{data,Message2}},
	    available_get();
	X ->
	    io:format("X message get WIFI ~p~n",[X])
    after 1000 ->
	    available_get()
    end.

available_put() ->
    receive
	{_,{command,"E"}} ->
	    receive
		{From,{command,Message}} ->
		    From!{self(),{data,term_to_binary({put,0,"null"})}}, %%%% ack mqseries
		    Resp = response(Message),
		    Resp2 = lists:flatten(Resp),
		    pbutil:whereis_name(wifi_get_fake)!{From,Resp2},
		    available_put()
	    after 1000 ->
		    exit(no_message_after_E)
	    end;
	{_,{command,Dict}} ->
	    erase(),
	    io:format("WIFI_FAKE ~p~n",[Dict]),
	    {dictionnary, List}  = binary_to_term(Dict),
	    lists:foreach(fun({Get,Value}) -> put(Get,Value) end, List),
	    available_put()
    after 2000 ->
	    erase(), %%%% delete all value stored for test
	    available_put()
    end.


header() ->
    "USSD" ++ lists:duplicate(53," ").

body(Return, Code, Text) ->
    Text2 = lists:reverse(Text),
    Text3 = lists:flatten(pbutil:sprintf("% 40s",[Text2])),
    Text4 = lists:reverse(Text3),
    lists:flatten(pbutil:sprintf("%03d%04s%s",[Return,Code,Text4])).


response(Req) ->
    case pbutil:sscanf("%4s%3s%14s%12s%15s",Req) of
	{["USSD",Service,_,Msisdn,Imsi],_} ->
	    case catch (create_data(Imsi,Service)) of
		{'EXIT',Error} ->
		    slog:event(internal,?MODULE,response,Error),
		    header() ++ "200" ++ lists:duplicate(100," ");
		Res -> header() ++ Res
	    end;
	_  -> 
	    slog:event(internal,?MODULE,bad_format,Req),
	    Text = body(200,"","Test pour OTP Password"),
	    header() ++ Text
    end.

create_data([$9,$9,$9,$0,$0,$0,$9,$3,$9,$2,$0|Rest]=Imsi,"OTP") -> %% DME
    {[_,I_Script],[]} = pbutil:sscanf("%2d%2d",Rest),
    Return = info_script(I_Script),
    Text = body(Return,?PASSWORD,"Test pour OTP Password"),
    Text ++ lists:duplicate(56," ");

create_data([$9,$9,$9,$0,$0,$0,$9,$3,$9,$3,$0|Rest]=Imsi,"IPO") -> %% GP
    {[_,I_Script],[]} = pbutil:sscanf("%2d%2d",Rest),
    Return = info_script(I_Script),
    Text = body(Return,?PASSWORD,"Test pour OTP Password"),
    Text ++ lists:duplicate(56," ");

create_data([$9,$9,$9,$0,$0,$0,$9,$0,$0,$0,$0|Rest]=Imsi,"OTP") -> %% OPIM
    {[_,I_Script],[]} = pbutil:sscanf("%2d%2d",Rest),
    Return = info_script(I_Script),
    Text = body(Return,?PASSWORD,"Test pour OTP Password"),
    Text ++ lists:duplicate(56," ");
create_data([$2,$0,$8,$0,$1,$0,$6,$1,$3,$0,$0|Rest]=Imsi,"OTP") -> %% OPIM
    {[_,I_Script],[]} = pbutil:sscanf("%2d%2d",Rest),
    Return = info_script(I_Script),
    Text = body(Return,?PASSWORD,"Test pour OTP Password"),
    Text ++ lists:duplicate(56," ").


%%%%  return code
%% +type info_script(integer()) -> integer().
info_script(1) -> 501;
info_script(2) -> 502;
info_script(3) -> 503;
info_script(4) -> 504;
info_script(5) -> 505;
info_script(6) -> 506;
info_script(7) -> 507;
info_script(11) -> 401;
info_script(12) -> 402;
info_script(13) -> 601;
info_script(14) -> 602;
info_script(_) -> 000.
