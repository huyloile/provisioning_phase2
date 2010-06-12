-module(test_125_wifi).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").

-define(direct_code,"#125#").
-define(INIT_RESPONSE_TIME,120).
-define(WAIT,2000).

-define(OUT_FILE_PREFIX,"test_125_wifi").
-define(TITLE_PREFIX,"Mobi Plugin: ").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


online() ->
    test_util_of:online(?MODULE,test()).
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Tests.

%% +type selfcare() -> service_test().

test() ->
    wifi_long()++
    	wifi_light() ++
    	wifi_mini() ++
  	operation_wifi() ++
 	[ "Test wifi reussi." ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_long_imei() ->
    ["Change profile into Level 1",
     {shell,
      [ {send,"mysql -upossum -ppossum -B -e \"update users set imei=\"10000899999999\" where msisdn like '+9930920%'\" mobi"},
	{send,"mysql -upossum -ppossum -B -e \"update users set imei=\"10000899999999\" where msisdn like '+9930930%'\" mobi"}]}].
change_light_imei() ->
    ["Change profile into Level 2",
     {shell,
      [{send,"mysql -upossum -ppossum -B -e\"update users set imei=\"10000699999999\" where msisdn like '+9930920%'\" mobi"},
       {send,"mysql -upossum -ppossum -B -e\"update users set imei=\"10000699999999\" where msisdn like '+9930930%'\" mobi"}]}].

change_mini_imei() ->
    ["Change profile into Level 3",
     {shell,
      [{send, "mysql -upossum -ppossum -B -e \"update users set imei=\"10000599999999\" where msisdn like '+9930920%'\" mobi"},
       {send, "mysql -upossum -ppossum -B -e \"update users set imei=\"10000599999999\" where msisdn like '+9930930%'\" mobi"}]}].   

asmserv_init(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_init(MSISDN, ACTIV_OPTs).

asmserv_restore(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_restore(MSISDN, ACTIV_OPTs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wifi_long() ->
    lists:append([wifi_long(Sub)||Sub <- 
				      ["postpaid",
				       "dme",
				       "opim"]]).

wifi_long(Subscription) ->
    init_data(Subscription)++
	test_util_of:set_past_period_for_test(promo_wifi) ++
        test_util_of:set_past_period_for_test(operation_wifi) ++
	change_long_imei()++
	[{title,"CAS SANS PROMOTION"}] ++
        ["Test du service wifi profil 181 - Subscription = "++Subscription] ++
	["Set msisdn=+99309200010",
	 {msaddr, [{international,isdn,"+99309200010"},{subscriber_number, private,"999000939200010"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Bienvenue sur le reseau Orange.*Votre mot de passe est: 1234.*Test pour OTP Password"}]},
	 
	 "Set msisdn=+99309200001",
	 {msaddr, [{international,isdn,"+99309200001"},{subscriber_number, private,"999000939200001"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Sur demande de votre gestionnaire vous n.*avez pas acces au #125#"}]},
	 
	 "Set msisdn=+99309200002",
	 {msaddr, [{international,isdn,"+99309200002"},{subscriber_number, private,"999000939200002"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Vous etes deja en cours de communication WIFI"}]},
	 
	 "Set msisdn=+99309200003",
	 {msaddr, [{international,isdn,"+99309200003"},{subscriber_number, private,"999000939200003"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Par securite attendez 15 mn avant de renouveler votre demande"}]},
	 
	 "Set msisdn=+99309200004",
	 {msaddr, [{international,isdn,"+99309200004"},{subscriber_number, private,"999000939200004"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Compte suspendu.*Merci de contacter votre gestionnaire de flotte"}]},
	 
	 "Set msisdn=+99309200005",
	 {msaddr, [{international,isdn,"+99309200005"},{subscriber_number, private,"999000939200005"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Compte suspendu.*Appelez le 700 .*prix d'1 com nat"}]},
	 
	 "Set msisdn=+99309200006",
	 {msaddr, [{international,isdn,"+99309200006"},{subscriber_number, private,"999000939200006"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Votre compte est resilie"}]},
	 
	 "Set msisdn=+99309200007",
	 {msaddr, [{international,isdn,"+99309200007"},{subscriber_number, private,"999000939200007"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Mauvaises saisies de vos codes.*merci de rappeler ulterieurement"}]},
	 
	 "Set msisdn=+99309200011",
	 {msaddr, [{international,isdn,"+99309200011"},{subscriber_number, private,"999000939200011"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*Merci de renouveler votre appel ulterieurement"}]},
	 
	 "Set msisdn=+99309200012",
	 {msaddr, [{international,isdn,"+99309200012"},{subscriber_number, private,"999000939200012"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Bienvenue sur le reseau Orange.*Votre mot de passe est: 1234.*Test pour OTP Password"}]},
	 
	 
	 "Set msisdn=+99309200013",
	 {msaddr, [{international,isdn,"+99309200013"},{subscriber_number, private,"999000939200013"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*Merci de renouveler votre appel ulterieurement"}]},
	 
	 "Set msisdn=+99309200014",
	 {msaddr, [{international,isdn,"+99309200014"},{subscriber_number, private,"999000939200014"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*Merci de renouveler votre appel ulterieurement"}]}].

wifi_light() ->
    lists:append([wifi_light(Sub)||Sub <-
				       ["postpaid",
					"dme",
					"opim"]]).

wifi_light(Subscription) ->
    init_data(Subscription)++
	test_util_of:set_past_period_for_test(promo_wifi) ++
        test_util_of:set_past_period_for_test(operation_wifi) ++
	change_light_imei () ++
	["Test du service wifi profil 130 - Subscription = "++Subscription] ++
	[
	 "Set msisdn=+99309200010",
	 {msaddr, [{international,isdn,"+99309200010"},{subscriber_number, private,"999000939200010"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Bienvenue sur le reseau Orange.*Votre mot de passe est: 1234"}]},
	 
	 "Set msisdn=+99309200001",
	 {msaddr, [{international,isdn,"+99309200001"},{subscriber_number, private,"999000939200001"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Sur demande de votre gestionnaire vous n.*avez pas acces au #125#"}]},
	 
	 "Set msisdn=+99309200002",
	 {msaddr, [{international,isdn,"+99309200002"},{subscriber_number, private,"999000939200002"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Vous etes deja en cours de communication WIFI"}]},
	 
	 "Set msisdn=+99309200003",
	 {msaddr, [{international,isdn,"+99309200003"},{subscriber_number, private,"999000939200003"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Par securite attendez 15 mn avant de renouveler votre demande"}]},
	 
	 "Set msisdn=+99309200004",
	 {msaddr, [{international,isdn,"+99309200004"},{subscriber_number, private,"999000939200004"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Compte suspendu.*Merci de contacter votre gestionnaire de flotte"}]},
	 
	 "Set msisdn=+99309200005",
	 {msaddr, [{international,isdn,"+99309200005"},{subscriber_number, private,"999000939200005"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Compte suspendu.*Appelez le 700 .*prix d'1 com nat"}]},
	 
	 "Set msisdn=+99309200006",
	 {msaddr, [{international,isdn,"+99309200006"},{subscriber_number, private,"999000939200006"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Votre compte est resilie"}]},
	 
	 "Set msisdn=+99309200007",
	 {msaddr, [{international,isdn,"+99309200007"},{subscriber_number, private,"999000939200007"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Mauvaises saisies de vos codes.*merci de rappeler ulterieurement"}]},
	 
	 "Set msisdn=+99309200011",
	 {msaddr, [{international,isdn,"+99309200011"},{subscriber_number, private,"999000939200011"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*Merci de renouveler votre appel ulterieurement"}]},
	 
	 "Set msisdn=+99309200012",
	 {msaddr, [{international,isdn,"+99309200012"},{subscriber_number, private,"999000939200012"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Bienvenue sur le reseau Orange.*Votre mot de passe est: 1234.*"}]},
	 
	 
	 "Set msisdn=+99309200013",
	 {msaddr, [{international,isdn,"+99309200013"},{subscriber_number, private,"999000939200013"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*Merci de renouveler votre appel ulterieurement"}]},
	 
	 "Set msisdn=+99309200014",
	 {msaddr, [{international,isdn,"+99309200014"},{subscriber_number, private,"999000939200014"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*Merci de renouveler votre appel ulterieurement"}]}].

wifi_mini() ->
    lists:append([wifi_mini(Sub)||Sub <-
				      ["postpaid",
				       "dme",
				       "opim"]]).


wifi_mini(Subscription) ->
    init_data(Subscription)++
	test_util_of:set_past_period_for_test(promo_wifi) ++
        test_util_of:set_past_period_for_test(operation_wifi) ++
	change_mini_imei ()  ++
        [ "Test du service wifi profil 64"] ++
	[
	 
	 "Set msisdn=+99309200010",
	 {msaddr, [{international,isdn,"+99309200010"},{subscriber_number, private,"999000939200010"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Bienvenue sur le reseau Orange.*Votre mot de passe est: 1234"}]},
	 
	 "Set msisdn=+99309200001",
	 {msaddr, [{international,isdn,"+99309200001"},{subscriber_number, private,"999000939200001"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Sur demande de votre gestionnaire vous n.*avez pas acces au #125#"}]},
	 
	 "Set msisdn=+99309200002",
	 {msaddr, [{international,isdn,"+99309200002"},{subscriber_number, private,"999000939200002"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Vous etes deja en cours de communication WIFI"}]},
	 
	 "Set msisdn=+99309200003",
	 {msaddr, [{international,isdn,"+99309200003"},{subscriber_number, private,"999000939200003"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Par securite attendez 15 mn avant de renouveler votre demande"}]},
	 
	 "Set msisdn=+99309200004",
	 {msaddr, [{international,isdn,"+99309200004"},{subscriber_number, private,"999000939200004"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Compte suspendu.*Merci de contacter votre gestionnaire de flotte"}]},
	 
	 "Set msisdn=+99309200005",
	 {msaddr, [{international,isdn,"+99309200005"},{subscriber_number, private,"999000939200005"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Compte suspendu.*Appelez le 700 .*prix d'1 com nat"}]},
	 
	 "Set msisdn=+99309200006",
	 {msaddr, [{international,isdn,"+99309200006"},{subscriber_number, private,"999000939200006"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Votre compte est resilie"}]},
	 
	 "Set msisdn=+99309200007",
	 {msaddr, [{international,isdn,"+99309200007"},{subscriber_number, private,"999000939200007"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Mauvaises saisies de vos codes.*merci de rappeler ulterieurement"}]},
	 
	 "Set msisdn=+99309200011",
	 {msaddr, [{international,isdn,"+99309200011"},{subscriber_number, private,"999000939200011"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible"}]},
	 
	 "Set msisdn=+99309200012",
	 {msaddr, [{international,isdn,"+99309200012"},{subscriber_number, private,"999000939200012"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Bienvenue sur le reseau Orange.*Votre mot de passe est: 1234.*"}]},
	 
	 
	 "Set msisdn=+99309200013",
	 {msaddr, [{international,isdn,"+99309200013"},{subscriber_number, private,"999000939200013"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible"}]},
	 
	 "Set msisdn=+99309200014",
	 {msaddr, [{international,isdn,"+99309200014"},{subscriber_number, private,"999000939200014"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible"}]}].

operation_wifi() ->
    lists:append([operation_wifi(Sub)||Sub <-
                                      ["postpaid",
                                       "dme",
                                       "opim"]]).

operation_wifi(Subscription) ->
    init_data(Subscription)++
	test_util_of:set_present_period_for_test(operation_wifi) ++
	change_long_imei()++
	[{title,"INTERRUPTION DE SERVICE"}] ++	
	["Set msisdn=+99309200010",
	 {msaddr, [{international,isdn,"+99309200010"},{subscriber_number, private,"999000939300001"}]},
	 {ussd2,
	  [{send,?direct_code},
	   {expect,"Ce service est momentanement indisponible.*"}]}].

init_data(Subscription) ->
    test_util_of:connect()++
    lists:append([test_util_of:init_test({imsi,IMSI},
					 {subscription,Subscription},
					 {navigation_level,1},
					 {msisdn,imsi2msisdn(IMSI)})||
		     IMSI <- ["999000939300010",
			      "999000939300001",
			      "999000939300002",
			      "999000939300003",
			      "999000939300004",
			      "999000939300005",
			      "999000939300006",
			      "999000939300007",
			      "999000939300011",
			      "999000939300012",
			      "999000939300013",
			      "999000939300014"]]).


imsi2msisdn(IMSI) ->
    "+9930"++lists:sublist(IMSI,9,7).

	
