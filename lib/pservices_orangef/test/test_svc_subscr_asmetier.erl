-module(test_svc_subscr_asmetier).
-include("../../pserver/include/pserver.hrl").
-include("../include/subscr_asmetier.hrl").
-include("../include/ftmtlv.hrl").
-compile(export_all).

run() ->
    test_format_date().

online() ->
    Res= test_util_of:rpc(?MODULE,test_do_recharge_cb,[]),
    io:format("testRes:~p~n",[Res]),
    ok=Res,
    test_util_of:rpc(crypto,stop,[]),
    ok.

%% unitary tests %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_format_date() ->
    TestList=
    [
     {["2009-01-13T00:00:00+01:00"], {{2009,1,13},{0,0,0}}},
     {["2009-01-13T00:00:00"], {{2009,1,13},{0,0,0}}},
     {["2006-05-14T03:02:01+01:00"], {{2006,5,14},{3,2,1}}},
     {["209-01-13T00:00:00+01:00"], undefined},
     {["2009-1-13T00:00:00+01:00"], undefined},
     {["2009-01-3T00:00:00+01:00"], undefined},
     {["2009-01-1300:00:00+01:00"], undefined},
     {["2009-01-13T0:00:00+01:00"], undefined},
     {["2009-01-13T00:0:00+01:00"], undefined},
     {["2009-01-13T00:00:0+01:00"], undefined},
     {[undefined], undefined},
     {[2009], {'EXIT',{function_clause,[{svc_subscr_asmetier,format_date,[2009]},
                          {test_util_of,unit_test,4},
                          {test_svc_subscr_asmetier,run,0},
                          {erl_eval,do_apply,5},
                          {erl_eval,expr,5},
                          {erl_eval,expr,5},
                          {escript,code_handler,4},
                          {erl_eval,local_func,5}
                          ]}}}
    ],
    test_util_of:unit_test(svc_subscr_asmetier,format_date,TestList).
    
test_do_recharge_cb() ->
    io:format("test~n"),
    test_util_of:rpc(crypto,start,[]),
    io:format("test~n"),
    test_util_of:set_env(pfront_orangef,des3_encryption_keys,["lib/pfront_orangef/test/keys/key.cipher"]),
    io:format("test~n"),
    DummySession = create_dummy_session(),
    io:format("test~n"),
    test_util_of:rpc(
      svc_subscr_asmetier,
      do_recharge_cb,
      [DummySession, mobi, 
       "0", "1234567890123456", "", "1212", "123", "10"]).

create_dummy_session() ->
create_dummy_session("+33612345678").

create_dummy_session(Msisdn) ->
    Session = #session{prof = #profile{msisdn = Msisdn}},  
    variable:update_value(
      Session, user_state, 
      #sdp_user_state{opt_activ=
                      #activ_opt{idDosSach="12",idDosOrchid="123",idUtilisateurEdlws="1234"}
                     }).
