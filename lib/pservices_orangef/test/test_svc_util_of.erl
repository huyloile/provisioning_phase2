-module(test_svc_util_of).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    format_options(),
    consult_account_options().

online()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Unit tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

format_options() ->
    [[95,1248213600,1248213600,
      2147483647,"0000000000",
      "S", 66, 68, 50, 504],
     [166, 1251324000, 1251324000,
      2147483647, "0000472383",
      "646", 0, 0, 0, 0]] 
        = svc_util_of:format_options([["95","1248213600","1248213600",
                                       "2147483647","0000000000",
                                       "S", "66", "68", "50", "504"],
                                      ["166", "1251324000", "1251324000",
                                       "2147483647", "0000472383",
                                       "646", "0", "0", "0", "0"]]),
    [[95,1248213600,1248213600,
      2147483647,"0000000000",
      "S", 66, 68, 50, 504]] 
        = svc_util_of:format_options([["95","1248213600","1248213600",
                                       "2147483647","0000000000",
                                       "S", "66", "68", "50", "504"]]).

consult_account_options() ->
    test_util_of:set_tux_params(),
    Session = test_util_of:create_session_tux(),
    %% Zone70 can be [],[L] or [L|Tail]
    {ok, [[_|_],[_|_],_]} = svc_util_of:consult_account_options(
                  Session, {mobi, "0612345678"}, "1",
                  "+33612345678", "NULL"),    
    %% Zone70 can be [],[L] only where TOP_num of L is 166
    Top_num = 166,
    {ok, [[[Top_num|_]|_],[_|_],_]} = svc_util_of:consult_account_options(
                                       Session, {mobi, "0612345678"}, "1",
                                       "+33612345678", Top_num).
