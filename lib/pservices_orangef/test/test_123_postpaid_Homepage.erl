-module(test_123_postpaid_Homepage).
-export([run/0,online/0,
	 pages/0,
	 links/1,
	 parent/1
	]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(Uid, postpaid_user).

-define(DIRECT_CODE, test_util_of:access_code(?MODULE, ?main_page) ++ "*").

pages()->
    [?main_page, ?postpaid_menu_page].

parent(_) ->
    ?MODULE.

links(?main_page) ->
    [ {?savoir_plus, dyn},
      {?bons_plans_tarif, dyn},
      {?suivi_conso_detaille, dyn},
      {?utiliser_votre_mesage, dyn},
      {?quel_tarif_dans_quel_pays_abroad, dyn},
      {?page_accuiel_France, dyn},
      {?postpaid_menu_page, static},
      {?postpaid_suivi_conso_plus, dyn},
      {?aide, dyn}];
links(?postpaid_menu_page) ->
    [{?postpaid_bons_plans, static},
     {?postpaid_multimedia, static},
     {?postpaid_sms_mms, static},
     {?postpaid_sms_mms_info, static},
     {?postpaid_davantage, static},
     {?postpaid_recharge, static},
     {?postpaid_parent_child, static},
     {?postpaid_fun, static}
    ].
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
        test_postpaid("GP")++
        test_postpaid("PRO")++
        %%Session closing
        test_util_of:close_session() ++
        ["Test reussi"].
test_postpaid(Type) ->    
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType="0005",
			   bundleDescription="label forf",
			   bundleAdditionalInfo="I1|I2|I3",
			   credits=[#spider_credit{name="balance",unit="MMS",value="40"},
				    #spider_credit{name="rollOver", unit="SMS", value="18"},
				    #spider_credit{name="bonus", unit="TEMPS", value="2h18min48s"}]},
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
             {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    profile_manager:create_default(?Uid,"postpaid")++
        profile_manager:set_bundles(?Uid,[BundleA])++
        profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
        profile_manager:update_spider(?Uid,profile,{offerPOrSUid,Type})++
        profile_manager:init(?Uid)++
	test_menu(Type)++	
	[].

test_menu(Type)->
    [
     "MENU PAGE - POSTPAID Profile "++Type ,
     "MENU Sans OTO",
     {ussd2,
      [
       {send, ?DIRECT_CODE},
       {expect, ".*Menu.*2:Suivi conso+.*3:Aide.*"}
      ]
     }
    ] ++
	test_util_of:close_session() ++
	%% Test menu Fun
	[ "MENU FUN -  Fun tones",
	  "MENU Sans OTO",
	  {ussd2,
	   [ {send,  test_util_of:access_code(?MODULE,?postpaid_menu_page,?postpaid_fun)++"165#"},
	     {expect,"Tonalites d'appel - Fun tones ! Ceux qui vous appellent entendent votre musique preferee quand votre mobile sonne.*"
	      "1:Accedez a Tonalites.8:Precedent.9:Accueil.*"
	     }
	    ]
	  }
	 ]++
        test_util_of:close_session()++

%	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a302"})++
        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304",
								 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SACHEM"})++
        [{title, "#### Test Menu #123 - Indispo Spider ####\n"},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
           {expect, "Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*1:Menu.*"},
           {send, "1"},
           {expect, "Menu #123#.*"}
          ]
         }
        ]++

        test_util_of:close_session() ++	
	["postpaid niv1 avec oto"] ++
        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a300"})++
	profile_manager:update_spider(?Uid,profile,{offerPOrSUid,"OLA"})++

 	init_oto()++
 	[
 	 "MENU PAGE - POSTPAID Profile "++Type ,
 	 "MENU Avec OTO",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},
 	   {expect, ".*En savoir.*2:Suivi conso.*3:Menu.*"}
 	  ]
 	 }
 	] ++
	[].

init_oto()->
    rpc:call(possum@localhost,one2one_offers,csv2mnesia,["test_sample.csv"]),
    PAUSE = 2000,
    ["Activation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost,
                            pcontrol, enable_itfs,
                            [[io_oto_mqseries1,possum@localhost]]]}]},
     "Pause de "++ integer_to_list(PAUSE) ++" Ms",
     {pause, PAUSE}] ++
        test_util_of:set_parameter_for_test(one2one_activated_postpaid,true) ++
        [].
