-module(test_svc_check_access).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("test_util_of.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(IMSI,"999000900000001").
-define(MSISDN,"9900000001").
-define(msisdn_leo_gourou,"+33604100001").
-define(imsi_leo_gourou,"208010904100001").

online() ->
    test_util_of:online(?MODULE,test_access()),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_access() ->
    test_access(?mobi, "#123", "mobicarte")++
 	test_access(?click_mobi, "#123", "Click la mobicarte")++
 	test_access(80, "#123", "Vous n'avez pas acces a ce service.")++
 	test_access(80, "#111", "Vous n'avez pas acces a ce service.")++
 	test_access(80, "#121", "Vous n'avez pas acces a ce service.")++
 	test_access(80, "#144", "Vous n'avez pas acces a ce service.")++

	test_access_leo_gourou() ++
	["Test reussi"].

test_access(DCL, USSD_CODE, Expect_txt) ->
    init_test(DCL)++
	test_util_of:insert(?IMSI,
                            DCL,
                            0,
                            [#compte{tcp_num=?C_PRINC,
                                     unt_num=?EURO,
                                     cpp_solde=42000,
                                     dlv=pbutil:unixtime(),
                                     rnv=0,
                                     etat=?CETAT_AC,
                                     ptf_num=?PCLAS_V2}])++
	["Desactivation de l'interface one2one",
	 {erlang, [{rpc, call, [possum@localhost,
				pcontrol, disable_itfs,
				[[io_oto_mqseries1,possum@localhost]]]}]}] ++

	[{title, "<center>#### Test Access to service "++USSD_CODE++ " - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 {ussd2,
	  [
	   {send, USSD_CODE++"#"},
	   {expect, Expect_txt}
	  ]
	 }
	]++
	test_util_of:close_session() ++
	[].

test_access_leo_gourou()->
    test_util_of:connect() ++
        test_util_of:init_test({imsi,?imsi_leo_gourou},
                               {subscription,"leo_gourou"},
                               {navigation_level,1},
                               {msisdn,?msisdn_leo_gourou}) ++
        test_util_of:ocf_set(?imsi_leo_gourou, "leo_gourou") ++
	test_util_of:set_in_sachem(?imsi_leo_gourou,"leo_gourou") ++
	lists:append([test_access_leo_gourou(DIRECT_CODE)||DIRECT_CODE <-["#111#","#123#","#144#"]]).

test_access_leo_gourou(DIRECT_CODE) ->
    [
     {title, "Test Accessing Leo Gourou with access code: "++DIRECT_CODE},
     {ussd2,
      [{send, DIRECT_CODE},
       {expect, "Vous n'avez pas acces a ce service. Utilisez plutot le \\*149\\#."}]
         }
        ]++test_util_of:close_session().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Init Config %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_connection() ->    
    [test_util_of:connect(smppasn)]++
	[{msaddr, {subscriber_number, private, ?IMSI}}].

init_config_cc() ->    
    test_util_of:reload_config_for_test() ++
	test_util_of:set_parameter_for_test(sce_used,true)++
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true).

init_test(DCL_NUM)->
    [{erlang,
      [{rpc, call, [possum@localhost,ets,
  		    insert,[ocf_test,{"9"++?MSISDN,#ocf_test{options=undefined}}]]}]}]
  	++
  	init_connection() ++
   	test_util_of:init_test(?IMSI,"mobi",1)++
   	test_util_of:set_in_spider(?IMSI,"mobi",[],DCL_NUM) ++
   	test_util_of:set_in_sachem(?IMSI,"mobi")++
  	init_config_cc().
