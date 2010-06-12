-module(test_123_cmo_avantages_vacances).

-export([online/0,
 	parent/1
	]).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/recharge_cb_cmo_new.hrl").
-include("profile_manager.hrl").
-include("access_code.hrl").

-define(Uid,cmo_user).

set_present_period(DatesList) ->
    test_util_of:set_present_period_for_test(commercial_date_cmo,DatesList).
set_past_period(DatesList) ->
    test_util_of:set_past_period_for_test(commercial_date_cmo,DatesList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 parent(?avantages_vacances) ->
     test_123_cmo_Homepage.

-define(CODE_AVANTAGES, 
	test_util_of:access_code(parent(?avantages_vacances),
				 ?avantages_vacances,
				 ?avantages_vacances)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop(),
    ok.

test()->
    test_util_of:init_day_hour_range() ++
	test_avantages_vacances([?zap_vacances,
 				 ?zap_cmo_1h30_v2,
 				 ?zap_cmo,
 				 ?ppol2
				])++
    [].

close_session() ->
    test_util_of:close_session().

test_avantages_vacances([])-> ["Test reussi"];
test_avantages_vacances([DCL|T])->
    profile_manager:create_and_insert_default(?Uid,#test_profile{sub="cmo",dcl=DCL})++
	profile_manager:init(?Uid)++
	
	case DCL of
	    X when X==?zap_vacances;X==?zap_cmo_1h30_v2 ->
		test_subscribe_ok(DCL)++
 		    test_change_zone_not_ok(DCL)++	
 		    test_change_zone_ok(DCL);
	    
	    Y when Y==?zap_cmo;Y==?ppol2 ->
		test_heure_zap_vacances(DCL)
	end++
	
	test_avantages_vacances(T)++
	[].

test_subscribe_ok(DCL)->
	[{title,"Test subscribe OK - DCL = "++integer_to_list(DCL)},
	 {ussd2,
	  [ {send, ?CODE_AVANTAGES},
	    {expect, "Avantages Vacances.*Choisissez ci-dessous votre zone academique de vacances:.*"
	     "1:Zone A.*"
	     "2:Zone B.*"
	     "3:Zone C.*"
	    },
	    {send, "1"},
	    {expect, "Declarez votre zone academique: SMS,MMS et messages Orange Messenger by Windows Live illimites 24h/24 7j/7 pdt les vacances scolaires.*"
	     "1:Souscrire.*"
	     "2:Mentions legales.*"},
	    {send, "1"},
	    {expect, "Souscription.*"
	     "Vous allez declarer la Zone A comme etant votre zone academique.*"
	     "1:Valider.*"},
	    {send,"1"},
	    {expect,"Validation.*"
	     "Vous beneficiez maintenant des messages illimites pendant les vacances scolaires .activation sous 24h.. Orange vous remercie de votre appel.*"},
	    {send,"882"},
	    {expect,"Messages illimites sous reserve d'un credit superieur a OE et de disposer d'un mobile compatible.*"
	     "1:Suite.*"
	     "2:Souscrire.*"},
	    {send,"1"},
	    {expect,"Hors SMS/MMS surtaxes et MMS cartes postales et jusqu'a 200 destinataires differents par mois.*"
	     "1:Suite.*"
	     "2:Souscrire.*"},
	    {send,"1"},
	    {expect,"SMS/MMS entre personnes physiques et pour un usage non lucratif direct.*"
	     "1:Suite.*"
	     "2:Souscrire.*"},
	    {send,"1"},
	    {expect,"Possibilite de modifier sa zone academique uniquement en dehors des periodes de vacances scolaires.*"
	     "1:Souscrire.*"}
	   ]}
	]++
	close_session()++
	[].

test_change_zone_not_ok(DCL)->
        profile_manager:set_list_options(?Uid,[#option{top_num=282}])++
	set_present_period([plan_zap])++
	
	[{title,"Change zone not OK(out of commercial days) - DCL = "++integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_AVANTAGES},
	   {expect, "Avantages Vacances.*Desole, vous ne pouvez pas changer de Zone academique pendant les vacances scolaires \\(toutes zones confondues\\).*"}
	  ]}
	]++

	close_session()++
	[].


test_change_zone_ok(DCL)->
    profile_manager:create_and_insert_default(?Uid,#test_profile{sub="cmo",dcl=DCL})++
        profile_manager:set_list_options(?Uid,[#option{top_num=282}])++
	profile_manager:init(?Uid)++
	set_past_period([plan_zap])++		

	[{title,"Change zone OK - DCL = "++integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_AVANTAGES},
	   {expect, "Avantages Vacances.*Choisissez ci-dessous votre nouvelle zone academique de vacances:.*"
	    "1:Zone A.*"
	    "2:Zone B.*"
	    "3:Zone C.*"
	   },
	   {send, "1"},
	   {expect, "Declarez votre nouvelle zone academique: SMS,MMS et Orange Messenger by Windows Live illimites 24h/24 7j/7 pdt les vacances scolaires.*"
	    "1:Souscrire.*"
	    "2:Mentions legales.*"},
	   {send, "1"},
	   {expect,"Souscription.*"
	    "Vous allez declarer la Zone . comme etant votre nouvelle zone academique.*"
	    "1:Valider.*"},
	   {send,"1"},
	   {expect,"Validation.*"
	    "Vous beneficiez maintenant des messages illimites pendant les vacances scolaires .activation sous 24h.. Orange vous remercie de votre appel.*"},
	   {send,"882"},
	   {expect,"Messages illimites sous reserve d'un credit superieur a OE et de disposer d'un mobile compatible.*"
	    "1:Suite.*"
	    "2:Souscrire.*"}
	  ]}
	]++
	close_session()++
	[].


test_heure_zap_vacances(DCL)->
    {PTF_PRINC, TCP_VOIX, PTF_VOIX} = 
	case DCL of
	    ?ppol2 ->
		{?Capri, ?C_VOIX, ?PTF_ZAP_VACANCES_FB1};
	    ?zap_cmo ->
		{?PTF_ZAP_VACANCES_FB2, ?C_VOIX_ZAP, ?PTF_ZAP_VACANCES_FB3}
	end,
    profile_manager:set_list_comptes(?Uid,
				 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=15000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=PTF_PRINC},
					  #compte{tcp_num=TCP_VOIX,
						  unt_num=?EURO,
						  cpp_solde=5000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=PTF_VOIX}
					 ])++
	[{title, "Heure ZAP Vacances - DCL = "++integer_to_list(DCL)},
	 {ussd2,
	  [ 
	    {send, ?CODE_AVANTAGES},
	    {expect, "Heures vacances.*Pour profiter de tarifs reduits 7J/7 24h/24 pendant toutes les vacances sur les appels vers Orange et fixes, les SMS et l'acces a Zap zone.*"
	     "1:Souscrire.*"},
	    {send, "1"},
	    {expect,"Souscription.*"
	     "Vous allez souscrire aux heures vacances.*"
	     "1:Valider.*"},
	    {send,"1"},
	    {expect,"Validation.*"
	     "Vous beneficiez maintenant des heures vacances. Orange vous remercie de votre appel.*"}
	   ]}
	]++
	
	close_session()++
	[].
