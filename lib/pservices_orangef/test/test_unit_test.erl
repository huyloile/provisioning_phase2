-module(test_unit_test).
-compile(export_all).
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/tlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/pserver.hrl").


run() ->    
    application:start(pservices_orangef),
    application:start(pfront_orangef),

    lists:append([subscribe(Msisdn, Sub, Option)||
            Msisdn<-["+33900000609", 
                "+33900000798"],
            Sub<-[mobi],
            Option<-[opt_bonus_sms,
                [opt_bonus_europe, opt_bonus_appels_etranger],
                [opt_bonus_maghreb, opt_bonus_appels_etranger]
            ]]), 

    ok.

subscribe(Msisdn, Sub, Option)->
    case catch unit_test:sachem_subscribe(Msisdn, Sub, Option) of
        {ok, Resp}->
            io:format("ok, {~p, ~p, ~p}~n",[Msisdn,Sub,Option]);
        Reason ->
            io:format("nok, {~p, ~p, ~p, ~p}~n",[Msisdn,Sub,Option,Reason])
    end,
    [].


online() ->
    io:format("Online unit_test~n~n"),
    test_util_of:online(?MODULE,test()).


test() ->
    [{title, "Online Test for Sachem subscribe"}] ++ 
	[].

