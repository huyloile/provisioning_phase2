-module(test_123_dme).
-export([run/0, online/0]).
-include("../../ptester/include/ptester.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("profile_manager.hrl").

-define(BR," ").
-define(BACK, "8").
-define(ACCUEIL, "9").

-define(Uid,dme_user).
-define(Uid_anon,anon_user).

-define(DIRECT_CODE,"#123*2#").
-define(NOT_SPLITTED, ".*[^>]\$").

-define(MENU_PRINC,
	"Sommaire"
	".*1:Manipulations mobile"
	".*2:A l'etranger"
	".*7:Aide").

run() ->
    ok.

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test() ->
		test_util_of:set_present_period_for_test(commercial_date_dme,[menu_dme]) ++
   		test_prepaidFlag_ocf()++
   		test_suivi_conso() ++
    		test_avec_sommaire()++
    		test_manipulation_mobile() ++
    		test_etranger() ++
    		test_aide() ++
    		test_anomalie()++
    		%%test_wap() ++ %% can't run this test by GCS side
    		spider_nonresponse() ++
		test_util_of:close_session().


test_avec_sommaire() ->
	profile_manager:create_default(?Uid,"dme")++
	profile_manager:init(?Uid)++
	profile_manager:set_default_spider(?Uid, config, [actif,suivi_conso_plus])++
	["Test avec Sommaire",
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},
	   {expect,?MENU_PRINC}
	  ]
	 }].

test_suivi_conso() ->
     [{title, "TEST SUIVI CONSO"}]++
	profile_manager:create_default(?Uid,"dme")++
	profile_manager:init(?Uid)++

 	test_suivi_conso("entreprise","0001")++
   	test_suivi_conso("entreprise","0002")++
  	test_suivi_conso("entreprise","0003")++
   	test_suivi_conso("entreprise","0007")++
   	test_suivi_conso("entreprise","0008")++
   	test_suivi_conso("entreprise","0009")++
   	test_suivi_conso("entreprise","0010")++
   	test_suivi_conso("entreprise","0011")++
   	test_suivi_conso("entreprise","0012")++
 	test_suivi_conso("entreprise","0013")++
   	test_suivi_conso("entreprise","0014")++
   	test_suivi_conso("entreprise","0015")++
   	test_suivi_conso("entreprise","0016")++
   	test_suivi_conso("entreprise","0017")++
   	test_suivi_conso("entreprise","0018")++
   	test_suivi_conso("entreprise","0019")++
   	test_suivi_conso("entreprise","0020")++
   	test_suivi_conso("entreprise","0021")++
   	test_suivi_conso("entreprise","0022")++
   	test_suivi_conso("entreprise","0023")++
   	test_suivi_conso("entreprise","0024")++
   	test_suivi_conso("entreprise","0025")++
   	test_suivi_conso("entreprise","0026")++
   	test_suivi_conso("entreprise","0028")++
   	test_suivi_conso("entreprise","0029")++
   	test_suivi_conso("entreprise","0030")++
   	test_suivi_conso("entreprise","0031")++
   	test_suivi_conso("entreprise","0032")++
   	test_suivi_conso("entreprise","0033")++
    	test_suivi_conso("entreprise","0050")++
   	test_suivi_conso("entreprise","0099")++

 	[{title, "TEST SUIVI CONSO WITH bundleType UNDEFINED (CASE OSEN)"}]++
	test_suivi_conso("entreprise","undefined")++
	[].


test_suivi_conso(Subscription,BundleType)
  when BundleType=="0001";BundleType=="0013" ->
  	BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="00h29min10s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
  	Bundles=[BundleA],
	Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"200"}]}],
	profile_manager:update_spider(?Uid,profile, [{amounts,Amounts},{offerType,Subscription}])++
	profile_manager:set_bundles(?Uid,Bundles)++
	
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect,"Vous disposez d'un abonnement.*Au ../.. a .*:.*, vous aviez consomme depuis votre derniere facture.*"}
	  ]}]++
	test_util_of:close_session()++
	profile_manager:update_spider(?Uid,profile, [{amounts,[]}])++
  	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
           {ussd2,
            [
             {send, "#123#"},
             {expect,"Vous disposez d'un abonnement .*A cette date, vous n'aviez pas consomme sur votre abo depuis votre derniere facture"}
            ]}]++
	test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0002" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="consumed", unit="MMS", value="40"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="00h29min10s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,{offerType,Subscription})++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect,"../.. .*:.*Meilleur choix optima:forfait .*"}
	  ]}]++test_util_of:close_session()++
	  profile_manager:set_bundles(?Uid,Bundles0)++
   ["Lien Suivi Conso avec BundleType = "++BundleType++ " & etat = epuise",
         {ussd2,
          [
           {send, "#123#"},
           {expect,"A cette date, aucune conso optima.*Meilleur choix optima: .*"}
          ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0003" ->
  	 BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="00h29min10s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	 BundleA_no_balance=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
  	Bundles = [BundleA],	
	Bundles0= [BundleA_no_balance],

	profile_manager:set_bundles(?Uid,Bundles)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Au .*/.* a .*:.*, forfait .*Solde forfait: .*Validite: ../.. inclus"}
	  ]}]++test_util_of:close_session()++
 	
	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Au ../.. a .*:.*, forfait .*Renouvellement le ../.."}
	  ]}]++test_util_of:close_session();

 test_suivi_conso(Subscription,BundleType)
   when BundleType=="0007";BundleType=="0014"->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="consumed", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="00h29min10s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},

    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"500"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid, profile, {amounts,Amounts})++
 	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
 	 {ussd2,
 	  [
 	   {send, "#123#"},
 	   {expect,"Au .*/.* a .*:.*, conso nationale: .*Autre Conso: .*EUR"}
 	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
 	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
 	 {ussd2,
 	  [
 	   {send, "#123#"},
 	   {expect, "A cette date, aucune conso"}
 	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0008" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="consumed", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="00h29min10s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"500"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid, profile, [{amounts,Amounts},{durationHf,"OBDD"}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect,".*/.* a .*:.*conso optima: .*Dont OBDD en visiophonie.*Hors forfait: .*EUR.*Meilleur choix: .*"}
	  ]}]++test_util_of:close_session()++
 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType,
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, aucune conso"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0009";BundleType=="0020";BundleType=="0028";BundleType=="0030" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="consumed", unit="TEMPS", value="1h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"500"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect,".*/.*Votre conso:.*h.*m.*s.*Hors forf:.*Forfait partage:.*Meilleur choix: forfait .*"}
	  ]}]++test_util_of:close_session()++
 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, aucune conso"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0010";BundleType=="0012";BundleType=="0021";BundleType=="0029";BundleType=="0031" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="consumed", unit="TEMPS", value="1h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Au ../.. a .*:.*Vous aviez consomme .* de communication nationale.*Conso hors forfait: .*EUR"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, nous n'avons enregistre aucune communication nationale"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0011" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_balance=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_balance],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "../.., .*:.*Solde forfait partage mobiles .*"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "../.., .*:.*Solde forf partage mobile .* epuise"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0015";BundleType=="0016" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="consumed", unit="TEMPS", value="1h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, ".*/.*a .*:.*conso .*Conso hors forfait: .*EUR.*Meilleur choix optima.* forfait .*"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, aucune conso"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0018"->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="consumed", unit="TEMPS", value="1h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, ".*/.*a .*:.*conso .*Conso hors forfait: .*EUR.*Meilleur choix optima.* forfait .*"}
	  ]}]++test_util_of:close_session()++
 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, aucune conso"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0017" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_balance=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_balance],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "../.. a .* forfait heures .*Solde forfait: .*Validite: ../.. inclus"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, ".*/.* a .*:.* forfait heures Business Everywhere .*Renouvellement le .*/.*Conso hors forf:.* EUR"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0019" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="TEMPS", value="3h30min50s"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_balance=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_balance],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Au ../.. a .*:.*Solde credit .* Wi-Fi roaming: .*"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Au .*/.* a .*:.*, votre forfait indiquait un depassement de Hors forfait: .*EUR"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0022";BundleType=="0023";BundleType=="0024";BundleType=="0025" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="VALEU", value="50"},
						 #spider_credit{name="consumed", unit="VALEU", value="20"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, ".*/.*Votre conso.*EUR.*Hors forf.*EUR"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, aucune conso"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0026" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="VALEU", value="10"},
						 #spider_credit{name="consumed", unit="VALEU", value="20"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	   BundleA_no_consumed=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="VALEU", value="10"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
		Bundles0= [BundleA_no_consumed],
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
		profile_manager:update_spider(?Uid,profile,[{amounts,Amounts}])++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = non epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, ".*/.*a .*:.*conso .*Conso hors forfait: .*EUR.*Meilleur choix optima.* forfait .*"}
	  ]}]++test_util_of:close_session()++

 	profile_manager:set_bundles(?Uid,Bundles0)++
	["Lien Suivi Conso avec BundleType = "++BundleType++" & etat = epuise",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "A cette date, aucune conso"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0032";BundleType=="0033" ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="VALEU", value="10"},
						 #spider_credit{name="consumed", unit="VALEU", value="20"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
 		profile_manager:set_bundles(?Uid,Bundles)++
	["Lien Suivi Conso avec BundleType = "++BundleType,
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Bienvenu sur votre suivi conso, pour plus de detail sur votre consommation veuillez taper 1"}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0050"->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="VALEU", value="10"},
						 #spider_credit{name="consumed", unit="VALEU", value="20"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
 		profile_manager:set_bundles(?Uid,Bundles)++
	["Lien Suivi Conso avec BundleType = "++BundleType,
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect, "Votre dernier appel date du ../.. a .*:.*Le suivi Conso pourra vous renseigner sur vos consommations a partir du ../.."}
	  ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType)
  when BundleType=="0099"->
          BundleA=#spider_bundle{
                                priorityType="A",
                                restitutionType="FORF",
                                bundleType=BundleType,
                                bundleDescription="forfait",
                                credits=[#spider_credit{name="standard", unit="VALEU", value="10"},
                                                 #spider_credit{name="consumed", unit="VALEU", value="20"},
                                                 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
                                },
        Bundles = [BundleA],
                Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"50"}]}],
                profile_manager:set_bundles(?Uid,Bundles)++
        ["Lien Suivi Conso avec BundleType = "++BundleType,
         {ussd2,
          [
           {send, "#123#"},
           {expect, "Le suivi conso n'est pas compatible avec l'offre detenue.*"}
          ]}]++test_util_of:close_session();

test_suivi_conso(Subscription,BundleType="undefined") ->
	  BundleA=#spider_bundle{
				priorityType="A",
				restitutionType="FORF",
				bundleType=BundleType,
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="balance", unit="VALEU", value="20"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
    	Bundles = [BundleA],	
  		Amounts=[{amount,[{name,"hfDise"},{allTaxesAmount,"200"}]}],
		profile_manager:create_default(?Uid,"anon")++
		profile_manager:init(?Uid)++
 		profile_manager:set_bundles(?Uid,Bundles)++
		[{title, "TEST SUIVI CONSO"}]++
		empty_data()++
		["Lien Suivi Conso avec undefined BundleType & undefined subscription",
		 {ussd2,
		  [
		   {send, "#123#"},
		   {expect,"Service Indisponible. Nous vous invitons a consulter votre compte"}
		  ]}]++
	test_util_of:close_session().

test_manipulation_mobile() ->
	profile_manager:create_default(?Uid,"dme")++
	profile_manager:init(?Uid)++
	profile_manager:set_default_spider(?Uid, config, [actif,suivi_conso_plus])++
	["lien manipulation mobile",
	 {ussd2,
	  [{send, "#123*2*1#"},
	   {expect,"1:Messagerie vocale.*2:Double appel.*3:Renvoi appel systematique.*4:Fonction SMS.*5:Modifier code PIN.*"
	    "6: Votre Service Clients.*7:Site Internet Orange.*"}
	  ]}].

test_etranger() ->
	profile_manager:create_default(?Uid,"dme")++
	profile_manager:init(?Uid)++
	profile_manager:set_default_spider(?Uid, config, [actif,suivi_conso_plus])++
	["lien etranger",
	 {ussd2,
	  [{send, "#123*2*2#"},
	   {expect, "1:Avant de partir.*"
	    "2:Pour communiquer.*"
	    "3:Connexions data.*"
	    "4:Messagerie vocale.*"
	    "5:Assistance.*"
	    "6:Numeros courts.*"},
	   %% Avant de partir
	   {send, "1"},
	   {expect,"1: Mode international"
	    ".2: Code messagerie"}, 
	   {send, "1"},
	   {expect,"Le mode international est-il actif sur votre ligne\\? Le gestionnaire du parc mobile de votre entreprise peut le demander jusqu'a 48h avant le depart.*"},
	   {send,?BACK++"*2"},
	   {expect,"N'oubliez pas de definir un code de messagerie pour pouvoir la consulter de l'etranger \\(888 choix 2 puis choix 2\\).*"},
	   {send,?ACCUEIL},
	   {expect,"Sommaire.1:Manipulations mobile.2:A l'etranger.*7:Aide "},
	   {send,"2"},
	   {expect,"1:Avant de partir.2:Pour communiquer.3:Connexions data.4:Messagerie vocale.5:Assistance.6:Numeros courts"},
	   %% Pour communiquer
	   {send,"2"},       
	   {expect,"Pour appeler de l'etranger ou des DOM composez \\+ puis indicatif du pays \\(France metro : \\+33\\) puis num sans 0"},
	   %% Connexions data
	   {send,?ACCUEIL},
	   {expect,"Sommaire.1:Manipulations mobile.2:A l'etranger.*7:Aide "},
	   {send,"2"},
	   {expect,"1:Avant de partir.2:Pour communiquer.3:Connexions data.4:Messagerie vocale.5:Assistance.6:Numeros courts"},
	   {send,"3"},
	   {expect,"1: La couverture.*"
	    "2: Usage intensif.*"},
	   {send,"1"},
	   {expect,"Connectez-vous de l'etranger ou des DOM grace aux accords GPRS, EDGE, 3G, 3G\\+ et Wi-Fi .*"},
	   {send,?BACK++"*2"},
	   {expect,"Pour un usage intensif de la data hors France metropolitaine, consultez le gestionnaire du parc mobile pour souscrire une option data Orange Travel.*"},
	   %% Messagerie vocale
	   {send,?ACCUEIL},
	   {expect, ".*"},
	   {send,"2*4"},
	   {expect,"Votre messagerie est accessible au 888 ou au \\+33 608 08 08 08 grace a votre code secret.*"},
	   %% Assistance
	   {send,?BACK ++"*5"},
	   {expect, "En cas de perte, casse, vol, panne de votre mobile, composez le 706 ou le \\+33 675 05 2000 \\(accessible 24h/24 7j/7 au tarif d'un appel vers la France metro\\).*"},
	   %% Numeros courts
	   {send,?BACK ++"*6"},
	   {expect,"888.: Messagerie vocale.*"
	    "898.: Messagerie visio.*"
	    "706.: Service clients.*"
	    "756.: Suivi conso.*"
	    "840.: Mail Orange.*"
	    "711.: Infos \\& services.*"},
	   {send,"1"},
	   {expect,"112/911: Numeros d'urgence.*"
	    "8294.: Taxi.*"
	    "811.: Finance.*"
	    "\\(Tarif d'un appel vers la France metropolitaine sauf pour le 112 qui est gratuit au sein de l'UE\\).*"}
	  ]},
	 {ussd2,
	  [
	   {send, "#123*2*2#"},
	   {expect, "1:Avant de partir.*"
	    "2:Pour communiquer.*"
	    "3:Connexions data.*"
	    "4:Messagerie vocale.*"
	    "5:Assistance.*"
	    "6:Numeros courts.*"},
	   {send, "6"},
	   {expect, ".*711 : Infos & services.*"},
	   {send, "1"},
	   {expect, "\\(Tarif d'un appel vers la France metropolitaine sauf pour le 112 qui est gratuit au sein de l'UE\\)"}
	  ]}].

test_aide() ->
	profile_manager:create_default(?Uid,"dme")++
	profile_manager:init(?Uid)++
    ["Aide",
     {ussd2,
      [{send,"#123*7#"},
       {expect,".*"},
       {send,"6"},
       {expect,".*"}
      ]
     }].

test_anomalie() ->
		["OK"].

test_wap()->
    lists:append([test_wap(Code,String) ||
		     {Code,String} <- [{"#123*2171#"," Client Orange Mobilite"},
				       {"#123*22311#","connexions data"}]]).

test_wap(Code,String)->
%    test_util_of:init_test(?IMSI, "dme", 1, "100008XXXXXXX1") ++
	["lien wap push",
	 {ussd2,
	  [{send, Code},
	   {expect,"Dans quelques instants, vous allez etre rediriger vers le site "++String}]},
	 test_util_of:check_wap_push_sent(first),
	 test_util_of:check_wap_push_sent(last)].

spider_nonresponse()->
    ["TEST PROVISIONNING - SERVICE NON RESPONSE OCF"]++
	profile_manager:create_default(?Uid,"dme")++
	profile_manager:init(?Uid)++
	profile_manager:update_spider(?Uid,data,time_out)++
	[{ussd2,
	  [{send,"#123*#"},
	   {expect,"Service indisponible. Merci de vous reconnecter ulterieurement"}
	  ]}]++
	test_util_of:close_session().

test_prepaidFlag_ocf()->
    ["TEST OCF RESPONSE WITH DIFFERENT PAIEMENTMODE"]++
	lists:append([test_prepaidFlag(Flag)||Flag <-[
 						      "OFR",
 						      "SCS",
 						      "ENT"]])++
	[].
test_prepaidFlag(Flag) ->
	 BundleA=#spider_bundle{ %%This bundle doesn't have credit balance
				priorityType="A",
				restitutionType="FORF",
				bundleType="0003",
				bundleDescription="forfait",
				credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
						 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
				},
	Test_profile=#test_profile{tac="012345",prepaidFlag=Flag,sub="anon",imei="100008XXXXXXX1"},
	["Test prepaidFlag in Ocf response with paiementmode = "++Flag]++
	profile_manager:create_and_insert_default(?Uid_anon,Test_profile)++
	profile_manager:init(?Uid_anon)++
	profile_manager:set_default_spider(?Uid_anon, sub, "dme")++
	profile_manager:set_bundles(?Uid_anon,[BundleA])++
	test_util_of:set_parameter_for_test(pfront_orangef,segco_prepaidFlag_checklist,["UNKNOW"])++
	["Test prepaidFlag in Ocf response",
	 {ussd2,
	  [
	   {send, "#123#"},
	   {expect,"Renouvellement"}
	  ]}]++
	test_util_of:close_session().


empty_data() ->	
    ["Empty data",
     {shell,
      [ {send,"mysql -upossum -ppossum -B -e \"delete FROM users WHERE subscription='entreprise'\" mobi"}
        ]}].

