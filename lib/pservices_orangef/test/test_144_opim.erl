-module(test_144_opim). 

-include("../../pdist_orangef/include/spider.hrl").
-include("../include/ftmtlv.hrl").
-include("../../oma/include/slog.hrl").
-include("profile_manager.hrl").


-compile(export_all).
-export([run/0,online/0]).

-define(Uid,opim).
-define(USSD_CODE, "*144").
-define(WIFI_USSD_CODE, "#125").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%% Definition des parametres Cellcube necessaires au test

online() ->
    test_util_of:online(?MODULE,spec()).


init(Sub) ->
    profile_manager:create_default(?Uid,Sub)++
	profile_manager:init(?Uid).


spec() ->
    test_sv_conso() ++
	test_wifi()++
	test_anomalie()++
	["TESTS OK"].

test_sv_conso() ->
    test_opim_niv1() ++
	test_opim_niv2() ++
	test_opim_niv3() ++
	[].

test_wifi() ->
    ["TEST WIFI"]++
	access_wifi_opim_niv1() ++
	[].

test_opim_niv1() ->
    test_forf_ac_niv1() ++
	test_forf_epuise_niv1() ++
	[].

test_forf_ac_niv1() ->
    lists:append([test_forf_ac_niv1(BundleType) || BundleType <- ["0027",
								  "0002"]]).

test_forf_ac_niv1(BundleType) when BundleType=="0027" ->
    BundleA=#spider_bundle{priorityType="A",
			   bundleLevel="1",
			   restitutionType="FORF",
			   bundleType=BundleType,
			   bundleDescription="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="00h29min10s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="1h30min50s"}
				   ]
			  },
    BundleC=#spider_bundle{priorityType="C",
			   bundleLevel="1",
			   restitutionType="LIB",
			   bundleType="0005",
			   bundleDescription="C_LIB",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   desactivationDate="2008-12-12T07:08:09.MMMZ",
			   credits=[#spider_credit{name="balance",unit="SMS",value="0"},
				    #spider_credit{name="rollOver",unit="SMS",value="1"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
	profile_manager:set_bundles(?Uid,[BundleA,BundleC])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	[{title,"Suivi conso forfait actif \n###offerType = entreprise + bundleType="++BundleType++ "=> opim" },
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 30/09 a .*, votre forfait 2h \\+report de 1h30m50s indiquait:.*Solde forfait: 00h29m10s.*Valable jusqu'au: 02/02 inclus.*Conso hors forfait: 2.50EUR.*1:suivi conso\\+"},
	   {send,"1"},
	   {expect,"C_LIB : .*SMS"}
	  ] }]++
	test_util_of:close_session();
test_forf_ac_niv1(BundleType="0002") ->
    BundleA=#spider_bundle{priorityType="A",
			   bundleLevel="1",
			   restitutionType="FORF",
			   bundleType="0002",
			   bundleDescription="forfait",
			   credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
				    #spider_credit{name="consumed", unit="TEMPS", value="1h28m13s"},
				    #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
			  },

    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]},
	     {amount,[{name,"hfDise"},{allTaxesAmount,"16.73"}]}
	    ],
    init("opim")++
	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
 	[{title,"Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise => opim"},
 	 {ussd2,
 	  [
 	   {send, ?USSD_CODE"*#"},
 	   {expect,"../.. .*:.*Meilleur choix:forfait .*"}
 	  ]}]++test_util_of:close_session().

access_wifi_opim_niv1() ->
    BundleA=#spider_bundle{priorityType="A",
      			   bundleLevel="1",
      			   restitutionType="FORF",
      			   bundleType="0027",
      			   bundleDescription="forfait",
      			   reactualDate="2008-09-30T07:08:09.MMMZ",
      			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
      				    #spider_credit{name="balance",unit="TEMPS",value="00h29min10s"},
      				    #spider_credit{name="rollOver",unit="TEMPS",value="1h30min50s"}
       				   ]
      			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
      	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("opim")++
       	profile_manager:set_bundles(?Uid,[BundleA])++
      	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
      	test_util_of:change_navigation_to_niv1(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"Test Orange Wifi Access"},
	 {ussd2,
	  [{send,?WIFI_USSD_CODE"*#"},
	   {expect,"Bienvenue sur Orange Wifi Access.*Votre mot de passe est: 1234.*Test pour OTP Password"}
	  ]}]++
	test_util_of:close_session().

test_forf_epuise_niv1() ->
    lists:append([test_forf_epuise_niv1(BundleType) || BundleType <- ["0027","0002"]]).

test_forf_epuise_niv1(BundleType) when BundleType=="0027" ->
    BundleA=#spider_bundle{priorityType="A",
			   bundleLevel="1",
			   restitutionType="FORF",
			   bundleType=BundleType,
			   bundleDescription="forfait",
			   exhaustedLabel="votre forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h00min00s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="2h30min50s"},
				    #spider_credit{name="excess",unit="TEMPS",value="00h30min50s"}
				   ]
			  },
    BundleB=#spider_bundle{priorityType="B",
			   bundleLevel="1",
			   restitutionType="SOLDE",
			   bundleType="0005",
			   bundleDescription="Solde",
			   exhaustedLabel="Solde",
			   reactualDate="2007-02-28T09:48:56.844Z",
			   desactivationDate="2006-08-11T07:08:09.MMMZ",
			   credits=[#spider_credit{name="balance",unit="MMS",value="2"},
				    #spider_credit{name="rollOver",unit="SMS",value="18"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA,BundleB])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	[{title,"Suivi conso FORF EP - OPIM NIV1\n#### bundleType = "++BundleType++"+ offerType = entreprise => opim"},
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 30/09 a .*,votre forfait 2h \\+report de 2h30m50s indiquait:.*Depassement de: 00h30m50s.*Renouvellement forfait le 03/02.*Conso hors forfait: 2.50EUR.*1:suivi conso\\+"},
	   {send,"1"},
	   {expect,"Solde : .*MMS"}
	  ]}]++
	test_util_of:close_session();

test_forf_epuise_niv1(BundleType="0002") ->
    BundleA_no_consumed=#spider_bundle{
      priorityType="A",
      restitutionType="FORF",
      bundleType=BundleType,
      bundleDescription="forfait",
      credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
 	       #spider_credit{name="balance", unit="TEMPS", value="00h29min10s"},
 	       #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
     },
    Bundles0= [BundleA_no_consumed],
    init("opim")++
	profile_manager:set_bundles(?Uid,Bundles0)++
 	[{title,"Lien Suivi Conso avec BundleType = "++BundleType++ " & etat = epuise => opim"},
	 {ussd2,
	  [
	   {send, ?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso.*Meilleur choix: .*"}
	  ]}]++test_util_of:close_session().
test_opim_niv2() ->
    test_forf_ac_niv2() ++
	test_forf_epuise_niv2() ++
	[].

test_forf_ac_niv2() ->
    lists:append([test_forf_ac_niv2(BundleType) || BundleType <- ["0027","0002"]]).

test_forf_ac_niv2(BundleType) when BundleType=="0027" ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType=BundleType,
			   bundleDescription="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h29min10s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="1h30min50s"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	test_util_of:change_navigation_to_niv2(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"Suivi conso FORF AC - OPIM NIV2\n###bundleType = "++BundleType++" - offerType = entreprise"},
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 30/09 a .*, votre forfait 2h.* \\+report de 1h30m50s.*Solde forfait:0h29m10s.*Validite:02/02 inclus.*Conso hors forfait: 2.50EUR"}
	  ]}]++
	test_util_of:close_session();
test_forf_ac_niv2(BundleType="0002") ->
    test_forf_ac_niv1(BundleType).

test_forf_epuise_niv2() ->
    lists:append([test_forf_ep_niv2(BundleType) || BundleType <- ["0027","0002"]]).

test_forf_ep_niv2(BundleType) when BundleType=="0027" ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType=BundleType,
			   bundleDescription="forfait",
			   exhaustedLabel="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h00min00s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="2h30min50s"},
				    #spider_credit{name="excess",unit="TEMPS",value="00h30min50s"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	test_util_of:change_navigation_to_niv2(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"Suivi conso FORF EP - OPIM NIV2\n#### bundleType = "++BundleType++" - offerType = entreprise"},
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"30/09 a 09:08, forfait 2h.* \\+report de 2h30m50s.*Depassement de 00h30m50s.*Renouvellement le 03/02.*Conso hors forfait: 2.50EUR"}
	  ]}]++
	test_util_of:close_session();
test_forf_ep_niv2(BundleType="0002") ->
    test_forf_epuise_niv1(BundleType).

test_opim_niv3() ->
    test_forf_ac_niv3() ++
	test_forf_epuise_niv3() ++
	[].


test_forf_ac_niv3() ->
    lists:append([test_forf_ac_niv3(BundleType) || BundleType <- ["0027"]]).

test_forf_ac_niv3(BundleType) when BundleType=="0027" ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType=BundleType,
			   bundleDescription="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h29min10s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="1h30min50s"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	test_util_of:change_navigation_to_niv3(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"Suivi conso FORF AC - NIV3\n#### bundleType = "++BundleType++" + offerType = entreprise => opim"},
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"30/09 solde forfait 2h:0h29m10s.*Conso hors forfait:2.50EUR"}
	  ]}]++
	test_util_of:close_session().

test_forf_epuise_niv3() ->
    lists:append([test_forf_ep_niv3(BundleType) || BundleType <- ["0027"]]).

test_forf_ep_niv3(BundleType) when BundleType=="0027" ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType=BundleType,
			   exhaustedLabel="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h00min00s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="2h30min50s"},
				    #spider_credit{name="excess",unit="TEMPS",value="00h30min50s"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	test_util_of:change_navigation_to_niv3(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"Suivi conso FORF EP - NIV3\n#### bundleType = "++BundleType++" - offerType = entreprise"},
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 30/09 forfait 2h depasse de 00h30m50s.*Hors forfait:2.50EUR"}
	  ]}]++
	test_util_of:close_session().

test_anomalie() ->
    test_numero_non_attribue()++
	test_provisionning()++ 	
	[].

test_numero_non_attribue() ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType="0027",
			   exhaustedLabel="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h00min00s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="2h30min50s"},
				    #spider_credit{name="excess",unit="TEMPS",value="00h30min50s"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	test_util_of:change_navigation_to_niv1(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"TEST ANOMALIE - NUMERO NON ATTRIBUE"},	
	 {ussd2,
          [{send,"*145#"},
           {expect,"Vous n'avez pas acces a ce service."}
          ]}]++test_util_of:close_session().

test_provisionning()->
    test_access_interdit()++
	test_nonresponse_spider()++
	[].

test_access_interdit()->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType="0005",
			   exhaustedLabel="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="0h29min10s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="1h30min50s"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    init("enterprise")++
     	profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	test_util_of:change_navigation_to_niv1(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"TEST PROVISIONNING - SERVICE INTERDIT"},
	 {ussd2,
	  [{send,?USSD_CODE++"*#"},
	   {expect,"Vous n'avez pas acces a ce service"}
	  ]}]
	++test_util_of:close_session().

test_nonresponse_spider()->    	
    init("opim")++
	profile_manager:update_spider(?Uid,data, {spider_error, no_resp})++
	test_util_of:change_navigation_to_niv1(profile_manager:imsi_by_uid(?Uid)) ++
	[{title,"TEST PROVISIONNING - SERVICE NON RESPONSE Spider"},
	 {ussd2,
	  [{send,?USSD_CODE++"*#"},
	   {expect,"Service Indisponible. Nous vous invitons a consulter votre compte sur www.orange.fr\\>espace client"}
	  ]}]++
	test_util_of:close_session().

msisdn2imsi(MSISDN) ->
    MSISDN_NAT = sachem_server:intl_to_nat(MSISDN),
    "20801"++MSISDN_NAT.

empty_data() ->	
    ["Empty data",
     {shell,
      [ {send,"mysql -upossum -ppossum -B -e \"delete FROM users WHERE subscription='opim'\" mobi"}
       ]}].




