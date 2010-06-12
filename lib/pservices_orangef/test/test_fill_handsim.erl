-module(test_fill_handsim).
-export([run/0,online/0]).

-define(all_subcriptions,[mobi,
			  bzh_gp,
  			  cmo,
 			  dme,
  			  anon,
 			  omer,
  			  postpaid,
  			  bzh_cmo,
  			  tele2_gp,
  			  tele2_pp,
 			  virgin_prepaid,
  			  virgin_comptebloque,
 			  virgin_postpaid,
       			  ten_postpaid,
 			  carrefour_prepaid,
			  monacell_prepaid,
			  monacell_postpaid
			 ]). 
		       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data(imsi,X)->
    test_provisioning_local:data(imsi,X).

online() ->
    test_util_of:reload_config(),
    test_util_of:reload_code(),
    [test_util_of:empty_test_table(Table) || Table <- [sub,sdp_compte,ocf_test]],
    [test_util_of:empty_test_table(Table) || Table <- [sub,sdp_compte,ocf_test]],
    %%Test =test_util_of:connect() ++
    %%test_util_of:init_test(data(imsi,mobi),atom_to_list(mobi)),
    Test = lists:append([test_util_of:connect() ++
			 test_util_of:init_test(data(imsi,SUB),atom_to_list(SUB)) ++
     			 test_util_of:ocf_set(data(imsi,SUB),atom_to_list(SUB)) ++
			 test_provisioning_local:set_in_sachem(SUB) 
			 || SUB <- ?all_subcriptions]),
    test_service:online(Test).

run() ->
    ok.
