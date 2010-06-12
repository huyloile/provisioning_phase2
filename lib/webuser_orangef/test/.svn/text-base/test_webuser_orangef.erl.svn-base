-module(test_webuser_orangef).

-export([run/0, online/0]).
-include("../../pdatabase/include/pdatabase.hrl").
-include("../../pdist/include/generic_router.hrl").

run() ->
  ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type online() -> ok
online() ->
  init(),
  %%% Initially, no data in the database
  [{"28/01/2008","0"},
   {"29/01/2008","0"},
   {"30/01/2008","0"},
   {"31/01/2008","0"},
   {"01/02/2008","0"}]
   =rpc:call(possum@localhost,webuser_orangef,stat_consultation_on_each_day,[{2008,1,28},{2008,2,1}]),
  0=rpc:call(possum@localhost,webuser_orangef,stat_consultation_in_a_period,[{2008,1,28},{2008,2,1}]),
  0=rpc:call(possum@localhost,webuser_orangef,stat_consultation_in_a_period,[{2008,1,28},{2008,1,28}]),
  [{"28/01/2008","0"},
   {"29/01/2008","0"},
   {"30/01/2008","0"},
   {"31/01/2008","0"},
   {"01/02/2008","0"}]
   =rpc:call(possum@localhost,webuser_orangef,stat_reprentative_on_each_day,[{2008,1,28},{2008,2,1}]),
  0=rpc:call(possum@localhost,webuser_orangef,stat_reprentative_in_a_period,[{2008,1,28},{2008,2,1}]),

  %%% Add data
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,28},"XXX"]),
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,28},"YYY"]),
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,28},"ZZZ"]),
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,28},"VVV"]),

  %%% Now, there is data in database
  [{"28/01/2008","4"},
   {"29/01/2008","0"},
   {"30/01/2008","0"},
   {"31/01/2008","0"},
   {"01/02/2008","0"}]
   =rpc:call(possum@localhost,webuser_orangef,stat_consultation_on_each_day,[{2008,1,28},{2008,2,1}]),
  4=rpc:call(possum@localhost,webuser_orangef,stat_consultation_in_a_period,[{2008,1,28},{2008,2,1}]),
  4=rpc:call(possum@localhost,webuser_orangef,stat_consultation_in_a_period,[{2008,1,28},{2008,1,28}]),
  [{"28/01/2008","4"},
   {"29/01/2008","0"},
   {"30/01/2008","0"},
   {"31/01/2008","0"},
   {"01/02/2008","0"}]
   =rpc:call(possum@localhost,webuser_orangef,stat_reprentative_on_each_day,[{2008,1,28},{2008,2,1}]),
  4=rpc:call(possum@localhost,webuser_orangef,stat_reprentative_in_a_period,[{2008,1,28},{2008,2,1}]),


  %%% Add data
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,29},"XXX"]),
  %%% Reprentative XXX does another consultation on 2008.1.29
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,29},"XXX"]),
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,30},"YYY"]),
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,1,31},"ZZZ"]),
  ok=rpc:call(possum@localhost,webuser_orangef,update_number_of_consulations_done_by_add_1,[{2008,2,1},"VVV"]),

  %%% Now, there is data in database
  [{"28/01/2008","4"},
   {"29/01/2008","2"},
   {"30/01/2008","1"},
   {"31/01/2008","1"},
   {"01/02/2008","1"}]
   =rpc:call(possum@localhost,webuser_orangef,stat_consultation_on_each_day,[{2008,1,28},{2008,2,1}]),
  %%% 9=4+2+1+1+1
  9=rpc:call(possum@localhost,webuser_orangef,stat_consultation_in_a_period,[{2008,1,28},{2008,2,1}]),
  4=rpc:call(possum@localhost,webuser_orangef,stat_consultation_in_a_period,[{2008,1,28},{2008,1,28}]),
  [{"28/01/2008","4"},
   {"29/01/2008","1"},
   {"30/01/2008","1"},
   {"31/01/2008","1"},
   {"01/02/2008","1"}]
   =rpc:call(possum@localhost,webuser_orangef,stat_reprentative_on_each_day,[{2008,1,28},{2008,2,1}]),
  %%% 8=4+1+1+1+1
  8=rpc:call(possum@localhost,webuser_orangef,stat_reprentative_in_a_period,[{2008,1,28},{2008,2,1}]),

  io:format("Test Pass!",[]),
  ok.

init() ->
  SQLCommand="DROP TABLE customer_care_28_01_2008,"++
                        "customer_care_29_01_2008,"++
                        "customer_care_30_01_2008,"++
                        "customer_care_31_01_2008,"++
                        "customer_care_01_02_2008",

    rpc:call(possum@localhost,generic_router,routing_request,[?SQL_Module,#sql_query{request=SQLCommand},10000],[srv0]).
