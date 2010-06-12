-module(test_123_postpaid_aide).
-export([run/0,online/0,
	 parent/1
	]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("test_util_of.hrl").

-define(IMSI, "999000900000001").
-define(IMSI_REFILL,"999000901000001").
-define(MSISDN,"+33900000001").
-define(MSISDN_NAT,"0900000001").

-define(DIRECT_CODE, test_util_of:access_code(?MODULE, ?main_page) ++ "*").
-define(AIDE_CODE,  test_util_of:access_code(parent(?aide), ?aide, [?aide, ?postpaid_suivi_conso_plus])).


parent(_) ->
    test_123_postpaid_Homepage.

asmserv_restore(MSISDN, ACTIV_OPTs)->
    test_util_of:asmserv_restore(MSISDN, ACTIV_OPTs).
asmserv_init(MSISDN, ACTIV_OPTs)->
    test_util_of:asmserv_init(MSISDN, ACTIV_OPTs).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run()->
    ok.
online() ->
    test_util_of:online(?MODULE,test()).


test() ->
    

    %%Test title
    [{title, "Test POSTPAID HOMEPAGE"}] ++

        [test_util_of:connect(smpp)] ++
        test_spider:set_navigation_keywords("postpaid")++
        test_util_of:set_parameter_for_test(sce_used, true)++
        test_postpaid("GP")++
        test_postpaid("PRO")++
        %%Session closing
        test_util_of:close_session() ++
        ["Test reussi"] ++
        [].
test_postpaid(Type) ->
    
        %% Initialisation of the accounts for the different IMSIs
        %% used in the tests
        test_spider:init_data_test(
          ?MSISDN_NAT, ?IMSI, "postpaid",Type,
          [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
           {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
          [{bundle,
            [{priorityType,"A"},
             {restitutionType,"FORF"},
             {bundleType,"0005"},
             {bundleDescription,"label forf"},
             {reactualDate, "2005-06-05T07:08:09.MMMZ"},
             {bundleAdditionalInfo, "I1|I2|I3"},
             {credits,
              [{credit,[{name,"balance"},{unit,"MMS"},{value,"40"}]},
               {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
               {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}])++
        lists:append([test_util_of:init_test(IMSI,"postpaid",1,"100008XXXXXXX1") ||
                         IMSI <- [?IMSI,?IMSI_REFILL]]) ++

        test_util_of:change_msisdn(?IMSI,?MSISDN) ++

        asmserv_init(?MSISDN, "NOACT")++
	test_aide(Type)++
        asmserv_restore(?MSISDN, "NOACT").
test_aide(Type)->
    init_test()++
        deactive_oto()++
     asmserv_init(?MSISDN, "NOACT")++
     [
      "AIDE PAGE - POSTPAID Profile "++Type ,
      {ussd2,
       [
        {send, ?AIDE_CODE},
        {expect, "Aide.*Suite.*"},
 	{send, "1"},
 	{expect, "Aide.*Ou que vous soyez dans votre navigation, 8 vous permet de revenir a la page precedente et 9 de retourner a l'accueil.*"}
       ]
      }
     ] ++
	test_util_of:close_session() ++
	[].
init_connection() ->
    [test_util_of:connect(smppasn)]++
	[{msaddr, {subscriber_number, private, ?IMSI}}].

init_config_cc() ->    
    test_util_of:reload_config_for_test() ++
	test_util_of:set_parameter_for_test(sce_used,true).

init_test()->
  	init_connection() ++
  	test_util_of:init_test(?IMSI,"postpaid",1)++
  	test_util_of:spider_test_init(?MSISDN, ?IMSI, "postpaid")++
  	init_config_cc().

deactive_oto()->
    ["Desactivation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost,
			    pcontrol, disable_itfs,
			    [[io_oto_mqseries1,possum@localhost]]]}]}].
