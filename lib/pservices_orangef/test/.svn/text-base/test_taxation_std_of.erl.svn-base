-module(test_taxation_std_of).
-compile(export_all).
-export([run/0,online/0]).

-include("../../pserver/include/pserver.hrl").

-define(imsi,"999000100000005").
-define(uid,"100000005").

-define(TEST_STD,test_taxation_standard).
-define(USER_TIMEOUT,30).
%%% TODO test with reprise de session.....
run()->
    ok.


online() ->

    [[N_S,T_T,NbP]] = case ?TEST_STD:load_stats_data() of 
			  [] ->
			      [["0","0","0"]];
			  Else ->
			      Else 
		      end,

    Starting_test_time = integer_to_list(pbutil:unixtime()),
    N_Session=list_to_integer(N_S),
    TotalTime=list_to_integer(T_T),
    Nb_page=list_to_integer(NbP),

    testreport:start_link_logger("../doc/test_stdbill_nb_pages.html"),
    test_service:online(start() ++
			?TEST_STD:test_nb_pages(Nb_page)),
    testreport:stop_logger(),

    testreport:start_link_logger("../doc/test_stdbill_end_appli.html"),
    test_service:online(start() ++
			?TEST_STD:end_applicatif(Starting_test_time)),
    testreport:stop_logger(),

    testreport:start_link_logger("../doc/test_stdbill_end_timeout.html"),
    test_service:online(start() ++ 
 			?TEST_STD:end_timeout(Starting_test_time)),
    testreport:stop_logger(),

    testreport:start_link_logger("../doc/test_stdbill_end_hangup.html"),
    test_service:online(start() ++ 
 			?TEST_STD:end_hangup(Starting_test_time)),
    testreport:stop_logger(),

    testreport:start_link_logger("../doc/test_stdbill_sess_resump.html"),
    test_service:online(start() ++ 
 			?TEST_STD:session_resumption(Starting_test_time) ++
 			?TEST_STD:end_test()),
    testreport:stop_logger(),

    ok.


start() ->
    [
     {erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,application,
		    set_env,
		    [pserver,max_user_response_time,?USER_TIMEOUT]]},
       {rpc, call, [possum@localhost,application,
		    set_env, 
		    [pserver, billing_module_default, billing_standard_of]]}
      ]},

     {connect_smpp, {"localhost", 7431}},
     {msaddr, {subscriber_number, private, ?imsi}}
    ].
