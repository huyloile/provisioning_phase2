-module(test_123_cmo_Homepage).

-export([online/0]).
-export([run/0]).
-export([pages/0, parent/1, links/1]).

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?main_page, ?menu_page, ?bons_plans].

parent(_) ->
    ?MODULE.

links(?main_page) -> 
    [{?savoir_plus, dyn},
     {?suivi_conso_detaille, dyn},
     {?menu_page, static},
     {?suivi_conso_plus, dyn},
     {?aide, dyn}]; 

links(?menu_page) ->
    [{?quik_silver, dyn},
     {?recharger, static},
     {?bons_plans, static},
     {?suivi_conso, static},
     {?roxy, dyn},
     {?avantages_vacances, dyn},
     {?zap_zone, dyn},
     {?'fun', static},
     {?en_ce_moment, static},
     {?davantage, static}];

links(?bons_plans) ->
    [{?bons_plans_page,static},
     {?messenger_page, static},
     {?multimedia_page,static},
     {?sms_mms_page,   static},
     {?securite,       static},
     {?unik_page,  static},
     {?exclusive_page, static},
     {?etranger_page,  static},
     {precedent,  static},
     {acceuil,  static}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UNIT TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    link_rank(),
    access_code().

%%%%%% access_code unit tests
access_code() ->
    "#123"   = test_util_of:access_code(?MODULE, ?main_page),
    "#123*1" = test_util_of:access_code(?MODULE, ?menu_page),
    "#123*1*1" = test_util_of:access_code(?MODULE, ?recharger),
    "#123*1*2" = test_util_of:access_code(?MODULE, ?bons_plans),
    "#123*1*2*1" = test_util_of:access_code(?MODULE, ?bons_plans_page),
    "#123*1*2" = test_util_of:access_code(?MODULE, ?recharger, ?quik_silver),
    "#123*1*2" = test_util_of:access_code(?MODULE, ?recharger, ?quik_silver),
    "#123*1*7" = test_util_of:access_code(?MODULE, ?en_ce_moment,[?quik_silver, ?roxy]),
    ok.


%%%%%% link_rank unit tests
link_rank(Element) ->
    test_util_of:link_rank(?MODULE, ?menu_page, Element).

link_rank(Element, Dynamic_links) ->
    test_util_of:link_rank(?MODULE, ?menu_page, Element, Dynamic_links).

link_rank() ->
    "1" = test_util_of:link_rank(?MODULE, ?main_page, ?menu_page),
    %% Direct code 
    "1" = link_rank(?recharger),
    "2" = link_rank(?bons_plans),
    "3" = link_rank(?suivi_conso),
    "4" = link_rank(?'fun'),
    "5" = link_rank(?en_ce_moment),
    "6" = link_rank(?davantage),
    %% Static links with dynamic link Quik_silver
    "2" = link_rank(?recharger,   [?quik_silver]),
    "3" = link_rank(?bons_plans,  [?quik_silver]),
    "4" = link_rank(?suivi_conso, [?quik_silver]),
    "5" = link_rank(?'fun',       [?quik_silver]),
    "6" = link_rank(?en_ce_moment,[?quik_silver]),
    "7" = link_rank(?davantage,   [?quik_silver]),
    %% Static links with dynamic link Roxy
    "1" = link_rank(?recharger,   [?roxy]),
    "2" = link_rank(?bons_plans,  [?roxy]),
    "3" = link_rank(?suivi_conso, [?roxy]),    
    "5" = link_rank(?'fun',       [?roxy]),
    "6" = link_rank(?en_ce_moment,[?roxy]),
    "7" = link_rank(?davantage,   [?roxy]),    
    %% Static links with dynamic links Quik_silver and Roxy
    "2" = link_rank(?recharger,   [?quik_silver, ?roxy]),
    "3" = link_rank(?bons_plans,  [?quik_silver, ?roxy]),
    "4" = link_rank(?suivi_conso, [?quik_silver, ?roxy]),    
    "6" = link_rank(?'fun',       [?quik_silver, ?roxy]),
    "7" = link_rank(?en_ce_moment,[?quik_silver, ?roxy]),
    "8" = link_rank(?davantage,   [?quik_silver, ?roxy]),
    %% Static links with dynamic links Quik_silver and Roxy
    "2" = link_rank(?recharger,   [?quik_silver, ?roxy, ?zap_zone]),
    "3" = link_rank(?bons_plans,  [?quik_silver, ?roxy, ?zap_zone]),
    "4" = link_rank(?suivi_conso, [?quik_silver, ?roxy, ?zap_zone]),    
    "7" = link_rank(?'fun',       [?quik_silver, ?roxy, ?zap_zone]),
    "8" = link_rank(?en_ce_moment,[?quik_silver, ?roxy, ?zap_zone]),
    "9" = link_rank(?davantage,   [?quik_silver, ?roxy, ?zap_zone]),
    %% Static links with dynamic links Quik_silver and Roxy
    "2" = link_rank(?recharger,   [?quik_silver, ?avantages_vacances, ?zap_zone]),
    "3" = link_rank(?bons_plans,  [?quik_silver, ?avantages_vacances, ?zap_zone]),
    "4" = link_rank(?suivi_conso, [?quik_silver, ?avantages_vacances, ?zap_zone]),    
    "7" = link_rank(?'fun',       [?quik_silver, ?avantages_vacances, ?zap_zone]),
    "8" = link_rank(?en_ce_moment,[?quik_silver, ?avantages_vacances, ?zap_zone]),
    "9" = link_rank(?davantage,   [?quik_silver, ?avantages_vacances, ?zap_zone]),
    %% Dynamic link Quik_silver
    "1" = link_rank(?quik_silver,   [?quik_silver]),
    "1" = link_rank(?quik_silver,   [?quik_silver, ?zap_zone]),
    %% Dynamic link Roxy
    "4" = link_rank(?roxy,          [?roxy]),
    "4" = link_rank(?roxy,          [?roxy, ?zap_zone]),
    %% Dynamic link Zap_zone
    "4" = link_rank(?zap_zone,      [?zap_zone]),
    "5" = link_rank(?zap_zone,      [?zap_zone, ?roxy]),
    %% Dynamic link Avantages_vacances
    "4" = link_rank(?avantages_vacances,[?avantages_vacances]),
    "5" = link_rank(?avantages_vacances,[?avantages_vacances, ?quik_silver]),
    "5" = link_rank(?avantages_vacances,[?avantages_vacances, ?quik_silver, ?zap_zone]).



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

	test_homepage_menu([
			    ?cmo_smart_40min,
 			    ?cmo_smart_1h,
 			    ?cmo_smart_1h30,
 			    ?cmo_smart_2h,
 			    ?ppola,
   			    ?rsa_cmo,
			    ?m6_cmo_3h,
			    ?m6_cmo_20h_8h,
			    ?zap_vacances,
 			    ?zap_cmo_20E,
 			    ?zap_cmo_1h_unik,
			    ?m6_cmo_fb_1h,
			    ?DCLNUM_CMO_SL_ZAP_1h30_ILL,
			    ?FB_M6_1H_SMS,
			    ?FB_M6_1H30,
			    ?m6_cmo_onet_2h_30E
       			   ])++

 	test_menu_souscrire_options([
 				     ?cmo_smart_40min,
 				     ?cmo_smart_1h,
 				     ?cmo_smart_1h30,
 				     ?cmo_smart_2h,
  				     ?rsa_cmo,
 				     ?ppola,
 				     ?m6_cmo_3h,
 				     ?m6_cmo_20h_8h,
 				     ?zap_vacances,
 				     ?zap_cmo_20E,
 				     ?zap_cmo_1h_unik,
 				     ?m6_cmo_fb_1h,
 				     ?DCLNUM_CMO_SL_ZAP_1h30_ILL,
 				     ?FB_M6_1H_SMS,
 				     ?FB_M6_1H30,
 				     ?m6_cmo_onet_2h_30E])++

   	test_menu_en_ce_moment([
     				?cmo_smart_40min,
     				?cmo_smart_1h,
     				?cmo_smart_1h30,
     				?cmo_smart_2h,
     				?rsa_cmo,
     				?m6_cmo_3h,
     				?m6_cmo_20h_8h,
     				?zap_vacances,
    				?zap_cmo_20E,
    				?zap_cmo_1h_unik,
    				?m6_cmo_fb_1h,
    				?DCLNUM_CMO_SL_ZAP_1h30_ILL,
    				?FB_M6_1H_SMS,
    				?FB_M6_1H30,
    				?m6_cmo_onet_2h_30E
			       ])++

 	test_avantage_decouverte_zap_zone([
 					   ?cmo_smart_40min,
 					   ?cmo_smart_1h,
 					   ?cmo_smart_1h30,
 					   ?cmo_smart_2h,
 					   ?zap_vacances,
 					   ?zap_cmo_20E,
 					   ?zap_cmo_1h_unik,
 					   ?DCLNUM_CMO_SL_ZAP_1h30_ILL
 					  ])++
      	test_menu_aide([
      			?cmo_smart_40min,
      			?cmo_smart_1h,
      			?cmo_smart_1h30,
      			?cmo_smart_2h,
      			?rsa_cmo,
      			?m6_cmo_3h,
      			?m6_cmo_20h_8h,
      			?zap_vacances,
      			?zap_cmo_20E,
      			?zap_cmo_25E,
      			?zap_cmo_1h_unik,
      			?m6_cmo_fb_1h,
      			?DCLNUM_CMO_SL_ZAP_1h30_ILL,
      			?FB_M6_1H_SMS,
      			?FB_M6_1H30,
      			?m6_cmo_onet_2h_30E
   		       ])++

	["Test reussi"].

expect_homepage_menu(DCL)
  when DCL==?zap_vacances;DCL==?zap_cmo_1h30_v2 ->
    "Menu #123#.*"
	"1:Recharger.*"
	"2:Options et .ons plans.*"
	"3:Suivi Conso.*"
	"4:Avantages Vacances.*"
 	"5:Avantage Decouverte Zap zone.*"
 	"6:Fun.*"
 	"7:En ce moment!.*"
	"Davantage & changer de mobile.*";

expect_homepage_menu(DCL)
  when DCL==?m6_cmo_3h; DCL==?m6_cmo_20h_8h; DCL==?rsa_cmo; DCL==?m6_cmo_fb_1h;
       DCL==?FB_M6_1H_SMS; DCL==?FB_M6_1H30; DCL==?m6_cmo_onet_2h_30E ->
    "Menu #123#.*"
	"1:Recharger.*"
	"2:Souscrire options et nouveaux .ons plans.*"
	"3:Suivi Conso.*"
	"4:Fun.*"
 	"5:En ce moment!.*"
 	"6:Davantage & changer de mobile.*";

expect_homepage_menu(_) ->
    "Menu #123#.*"
	"1:Recharger.*"
	"2:Souscrire options et nouveaux .ons plans.*"
	"3:Suivi Conso.*"
	"4:Avantage Decouverte Zap zone.*"
 	"5:Fun.*"
 	"6:En ce moment!.*"
 	"7:Davantage & changer de mobile".


test_homepage_menu([]) -> [];
test_homepage_menu([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
	profile_manager:init(?Uid)++

	case DCL of
	    ?zap_cmo_20E ->
		profile_manager:set_list_options(?Uid,[#option{top_num=316}]);
	    _ ->
		profile_manager:set_list_options(?Uid,[])
	end++

	set_present_period([teasing_jkdo_bp]) ++
	[{title, "Homepage Menu CMO  - "++user_subscription(DCL)++"\n"++
	  "#### In period 'Journee KDO Bons plans' teasing\n"++
	  "#### DCL = "++integer_to_list(DCL)}]++
	%%check KDO for M6 Mobile
	case DCL of
            X  when X==?m6_cmo_3h; X==?m6_cmo_20h_8h; X==?m6_cmo_fb_1h;
                    X==?FB_M6_1H_SMS; X==?FB_M6_1H30; X==?m6_cmo_onet_2h_30E ->
		[
		 {ussd2,
		  [{send, test_util_of:access_code(?MODULE, ?main_page)},
		   {expect,"Restant:.*Repondre.*1:Menu"},
		   {send, test_util_of:link_rank(?MODULE, ?main_page, ?menu_page)},
		   {expect, "Menu #123#.*"
		    "Pour feter ses 5 ans, M6 Mobile vous offre un Bon plan : le mercredi 16 Juin, le bon plan de votre choix est gratuit !.*"	
		    "1:En savoir plus sur cette offre.*"
		    "2:Menu"},
		   {send, "2"},
		   {expect, expect_homepage_menu(DCL)},
		   %% Test link "Decouvrir les Bons plans"
		   {send, "8"},
		   {expect, "1:En savoir plus sur cette offre.*"},
		   {send, "1"},
		   {expect, "Le 16/06 uniquement, le bon plan de votre choix est gratuit : Journee ou Soiree appels / SMS / Internet / TV.*"
		    "1:Decouvrir les bons plans.*"
		    "2:Menu"},
		   {send, "2"},
		   {expect, expect_homepage_menu(DCL)}
		  ]}];
	    _->
		[
		 {ussd2,
		  [{send, test_util_of:access_code(?MODULE, ?menu_page)},
		   {expect, expect_homepage_menu(DCL)}
		  ]}]
	end++
	close_session()++

	set_past_period([teasing_jkdo_bp])++	
	[{title, "Homepage Menu CMO - "++user_subscription(DCL)++"\n"++
	  "#### Out period 'Journee KDO Bons plans' teasing\n"++
	  "#### DCL = "++integer_to_list(DCL)}]++
	[
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, ?menu_page)},
	   {expect, expect_homepage_menu(DCL)}
	  ]}]++
 	close_session()++

  	case DCL of
  	    X  when X==?m6_cmo_3h; X==?m6_cmo_20h_8h; X==?rsa_cmo; X==?m6_cmo_fb_1h;
  		    X==?FB_M6_1H_SMS; X==?FB_M6_1H30; X==?m6_cmo_onet_2h_30E ->
  		[];
  	    _->
		set_past_period([teasing_jkdo_bp]) ++
		    profile_manager:set_list_options(?Uid, [#option{top_num=svc_options:top_num(opt_avan_dec_zap_zone,cmo)}])++

		    [{title, "Homepage Menu CMO  - "++user_subscription(DCL)++"\n"++
		      "#### Without 'Journee KDO Bons plans'and without teasing - without 'Avantage Decouverte Zap zone'\n"++
		      "#### DCL = "++integer_to_list(DCL)},
  		     {ussd2,
  		      [{send, test_util_of:access_code(?MODULE, ?menu_page)},
  		       case DCL of
  			   X when X==?zap_vacances;X==?zap_cmo_1h30_v2 ->
  			       {expect,
  				"Menu #123#.*"
  				"1:Recharger.*"
  				"2:Options et .ons plans.*"
  				"3:Suivi Conso.*"
  				"4:Avantages Vacances.*"
  				"5:Fun.*"
  				"6:En ce moment!.*"
  				"Davantage & changer de mobile.*"};
  			   _->
  			       {expect,
  				"Menu #123#.*"
  				"1:Recharger.*"
  				"2:Souscrire options et nouveaux .ons plans.*"
  				"3:Suivi Conso.*"
  				"4:Fun.*"
  				"5:En ce moment!.*"
  				"6:Davantage & changer de mobile"}
  		       end
  		      ]}]
  	end++
 	close_session()++


	test_homepage_menu(T).

test_menu_souscrire_options([]) -> [];
test_menu_souscrire_options([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
	profile_manager:init(?Uid)++

        [{title, "Menu Souscrire Options et nouveaux bons plans -"++user_subscription(DCL)++"\n"++
          "#### DCL = "++integer_to_list(DCL)}]++
        [
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?bons_plans)},
           {expect, "L'offre Orange.*"
	    "1:Bons plans.*"
	    "2:Options SMS\\/MMS - Orange Messenger.*"
	    "3:Options multimedia.*"
            "4:SMS\\/MMS Infos.*"
	    "5:Options securite.*"
	    "6:Suite"
	   },
	   {send, "6"},
	   {expect,
	    "1:Offres eXclusives.*"
	    "2:A l'etranger"}
          ]},

	 user_subscription(DCL)++" - Option securite",
	 {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?bons_plans)++"5"},
           {expect, "Securite.*3 options pour assurer votre mobile en cas de vol,casse,perte : Securite 3E, 6E et 9E.*Souscription au 740 \\(appel gratuit\\) ou sur www.orange.fr>espace client.*"}
	  ]
	 }
	]++
        close_session()++

        test_menu_souscrire_options(T).
test_avantage_decouverte_zap_zone([])->
    [];
test_avantage_decouverte_zap_zone([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
	profile_manager:init(?Uid)++

	test_conditions_avan_dec_zap_zone(DCL)++
	test_souscrire_avan_dec_zap_zone(DCL)++

	test_avantage_decouverte_zap_zone(T).

test_souscrire_avan_dec_zap_zone(DCL)->
    [{title, "Test avantage decouverte zap zone - souscrire\nDCL = "++integer_to_list(DCL)++":"++user_subscription(DCL)},
     {ussd2,
      [ {send, test_util_of:access_code(?MODULE, ?menu_page)},
	{expect, ".*"},
	{send, code_zap_zone(DCL)},
	{expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"},
	{send, "1"},
	{expect,"Vous allez souscrire a l'Avantage Decouverte Zap zone..*1:Confirmer"},
	{send,"1"},
	{expect,"Vous avez souscrit a l'Avantage Decouverte Zap Zone."}
       ]}
    ]++
	close_session().

test_conditions_avan_dec_zap_zone(DCL)->    
    [{title, "Test avantage decouverte zap zone - conditions\nDCL = "++integer_to_list(DCL)++":"++user_subscription(DCL)},
     {ussd2,
      [ {send, test_util_of:access_code(?MODULE, ?menu_page)},
	{expect, ".*"},
	{send, code_zap_zone(DCL)},
	{expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"},
	{send, "2"},
	{expect,"Avantage reserve aux clients mobile Orange dont l'utilisateur de la ligne est age de moins de 18 ans et non encore inscrit au portail Zapzone..*1:Suite"},
	{send,"1"},
	{expect,"Usages en France metropolitaine.Valable sur reseau et depuis un terminal compatible..*1:Suite"},
	{send,"1"},
	{expect,"Navigation illimitee sur le portail Zap zone pendant 7 jours a compter de la souscription de l'avantage decouverte Zap zone."}
       ]}
    ]++
	close_session().

test_menu_en_ce_moment([]) -> [];
test_menu_en_ce_moment([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
	profile_manager:init(?Uid)++

	case DCL of
            ?zap_cmo_20E ->
                profile_manager:set_list_options(?Uid,[#option{top_num=316}]);
            _ ->
                profile_manager:set_list_options(?Uid,[])
        end++
	set_past_period([teasing_jkdo_bp]) ++

	[{title, "Test menu en ce moment\n"++
	  "DCL "++integer_to_list(DCL)++":"++user_subscription(DCL)++"\n"++
	  "### Not subscribed opt_11_18"}]++
 	[
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, ?menu_page)},
 	    {expect, expect_homepage_menu(DCL)},
 	    {send, code_menu_en_ce_moment(DCL)},
 	    {expect,text_menu_en_ce_moment(DCL,not_subscribed)}
 	   ]}
	]++

 	case DCL of
 	    D when D==?rsa_cmo;D==?m6_cmo_3h;D==?m6_cmo_20h_8h;D==?m6_cmo_fb_1h;
 		   D==?FB_M6_1H_SMS;D==?FB_M6_1H30;D==?m6_cmo_onet_2h_30E ->
 		[];
 	    _ ->
 		[
 		 user_subscription(DCL)++"-"++"Avantage Decouverte Zap zone",
 		 {ussd2,
 		  [ {send, test_util_of:access_code(?MODULE, ?menu_page)++code_menu_en_ce_moment(DCL)++"#"},
 		    {expect,text_menu_en_ce_moment(DCL,not_subscribed)},
 		    {send, "4"},
		    {expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2\:Conditions"}
 		   ]}
 		]
 	end++
 	close_session()++

 	[{title, user_subscription(DCL)++"\n"++"#### Subscribed opt_11_18" }]++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="PADO2"})++

 	[
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, ?menu_page)},
 	    {expect, ".*"},
 	    {send, code_menu_en_ce_moment(DCL)},
 	    {expect, text_menu_en_ce_moment(DCL, subscribed)}
 	   ]},

 	 user_subscription(DCL)++"-"++" Les bons plans",
 	 {ussd2,
 	  [{send, test_util_of:access_code(?MODULE, ?menu_page) },
 	   {expect, ".*"},
 	   {send, code_menu_en_ce_moment(DCL)},
 	   {expect, text_menu_en_ce_moment(DCL, subscribed)},
 	   {send, "2"},
 	   {expect, "Envie d'illimite pour une journee ou une soiree.  Appels vers tous les operateurs, SMS, Internet ou TV. Profitez en !.1:Bons plans"},
 	   {send, "1"},
 	   {expect, "Bons plans.*"}]},

 	 user_subscription(DCL)++"-"++" Promos du moment"++"\n"++"Promo options multimedia",
 	 {ussd2,
 	  [{send, test_util_of:access_code(?MODULE, ?menu_page)},
 	   {expect, ".*"},
 	   {send, code_menu_en_ce_moment(DCL)},
 	   {expect, text_menu_en_ce_moment(DCL, subscribed)},
 	   {send, "1"},
           {expect, ".*Promos options multimedia.*"
	    "Pour toute premiere souscription a une option multimedia, 2 mois a -50% .sauf pour option Mes donnees . 30 Go...1:Voir options multimedia"},
	   {send,"1"},
  	   {expect, "Options multimedia.*1:Option Internet.*2:Option Musique mix.*3:Option TV.*4:Option Sport"}
	  ]}
        ]++	

  	case DCL of
 	    X when X==?m6_cmo_3h; X==?m6_cmo_20h_8h; X==?m6_cmo_fb_1h;
 		   X==?FB_M6_1H_SMS; X==?FB_M6_1H30; X==?m6_cmo_onet_2h_30E ->
 		[
 		 user_subscription(DCL)++"-"++" Inside M6 mobile",
 		 {ussd2,
 		  [{send, test_util_of:access_code(?MODULE, ?menu_page)},
 		   {expect, ".*"},
 		   {send, code_menu_en_ce_moment(DCL)},
 		   {expect, text_menu_en_ce_moment(DCL, subscribed)},
 		   {send, "4"},
 		   {expect, "Inside M6 mobile est accessible en exclusivite via Orange World et vous permet de beneficier de nombreux avantages et plein de contenus exlusifs.*1:Suite"},
 		   {send, "1"},
 		   {expect, "Beneficiez de reductions exclusives sur vos marques favorites grace a votre Pass VIP, assistez aux emissions M6, rencontrez vos stars preferees,.*1:Suite"},
 		   {send, "1"},
 		   {expect, "accedez aux chaines TV ainsi qu'a toutes les videos M6 a volonte... et profitez de nombreux jeux-concours!.*"}
 		  ]}
 		];
 	    _ ->
 		[]
 	end ++
 	close_session()++

	[{title, user_subscription(DCL)++"\n"++"#### Kdo" }]++
	[
	 user_subscription(DCL)++"-"++" Nuite Kdo SMS",
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, ?menu_page)},
	   {expect, ".*"},
	   {send, code_menu_en_ce_moment(DCL)},
	   {expect, text_menu_en_ce_moment(DCL, subscribed)},
	   case DCL of
	       X when   X==?rsa_cmo;
			X==?zap_vacances;
			X==?zap_cmo_20E;
			X==?zap_cmo_25E;
			X==?zap_cmo_1h_unik;
			X==?zap_cmo_1h30_ill;
			X==?DCLNUM_CMO_SL_ZAP_1h30_ILL;
			X==?cmo_smart_40min;
			X==?cmo_smart_1h;
			X==?cmo_smart_1h30;
			X==?cmo_smart_2h ->
		   {send, "4"};
	       _-> {send, "5"}
	   end,
	   {expect, ".*1:Nuit Kdo du 21/06"
	    ".*2:Journee Kdo du 14/07"},
	   {send, "1"},
	   {expect, ".*Nuit Kdo SMS : Le 21 juin 2010, profitez de SMS illimites vers tous les mobiles et fixes de 21h30 au lendemain 8h !.*1:Mention legale"},
	   {send, "1"},
	   {expect, "SMS interpersonnels emis depuis un mobile en France metropolitaine hors SMS surtaxes, n. courts, sous reserve d'un credit > a 0E.*"}
	  ]},
	 user_subscription(DCL)++"-"++" Journee Kdo SMS",
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?menu_page)},
           {expect, ".*"},
           {send, code_menu_en_ce_moment(DCL)},
           {expect, text_menu_en_ce_moment(DCL, subscribed)},
           case DCL of
               X when   X==?rsa_cmo;
                        X==?zap_vacances;
                        X==?zap_cmo_20E;
                        X==?zap_cmo_25E;
                        X==?zap_cmo_1h_unik;
                        X==?zap_cmo_1h30_ill;
                        X==?DCLNUM_CMO_SL_ZAP_1h30_ILL;
                        X==?cmo_smart_40min;
                        X==?cmo_smart_1h;
                        X==?cmo_smart_1h30;
                        X==?cmo_smart_2h ->
                   {send, "4"};
               _-> {send, "5"}
           end,
           {expect, ".*1:Nuit Kdo du 21/06"
            ".*2:Journee Kdo du 14/07"},
	   {send, "2"},
	   {expect, ".*Journee Kdo MMS : Le 14 juillet 2010, tous vos MMS sont offerts et illimites vers tous les mobiles et adresses e-mail de 8h a 21h.*1:Mention legale"},
	   {send, "1"},
           {expect, ".*MMS interpersonnels emis d'un mobile en France metrop. Jusqu'a 600ko, hors MMS surtaxes, n0 courts et MMS carte postale, sous reserve d'un credit > a 0E"}
	  ]}	 
	]++
        close_session()++

	test_menu_en_ce_moment(T).

test_menu_aide([]) ->
    [];
test_menu_aide([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
	profile_manager:init(?Uid)++
	case DCL of
            ?zap_cmo_20E ->
                profile_manager:set_list_options(?Uid,[#option{top_num=316}]);
            _ ->
                profile_manager:set_list_options(?Uid,[])
        end++

	set_past_period([teasing_jkdo_bp]) ++
	[{title, "Menu Aide CMO - "++user_subscription(DCL)++"\n"++
          "#### Access from Main page"++
          "#### DCL = "++integer_to_list(DCL)}]++
        [
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?main_page)},
           {expect, ".*"},
           {send,"3"},
           {expect,"Aide.*Pour naviguer dans le #123#, il faut d'abord appuyer sur \"Repondre\" puis saisir le chiffre de la rubrique souhaitee, et appuyer sur \"Envoyer\"..1:Suite.9:Accueil"},
	   {send,"1"},
	   {expect,"Aide.*Ou que vous soyez dans votre navigation, 8 vous permet de revenir a la page precedente et 9 de retourner a l'accueil..9:Accueil"}
          ]}]++

        [{title, "Menu Aide CMO - "++user_subscription(DCL)++"\n"++
          "#### Access from Menu page"++
          "#### DCL = "++integer_to_list(DCL)}]++
        [
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?menu_page)},
           {expect, expect_homepage_menu(DCL)},
           {send,"9"},
           {expect,"Aide.*Pour naviguer dans le #123#, il faut d'abord appuyer sur \"Repondre\" puis saisir le chiffre de la rubrique souhaitee, et appuyer sur \"Envoyer\"..1:Suite.9:Accueil"},
	   {send,"1"},
           {expect,"Aide.*Ou que vous soyez dans votre navigation, 8 vous permet de revenir a la page precedente et 9 de retourner a l'accueil..9:Accueil"}
          ]}]++
        close_session()++

	test_menu_aide(T).

user_subscription(?zap_vacances) ->
    " SL Zap Vacances et Zap V3 ";
user_subscription(?zap_cmo_20E) ->
    " SL Roxy ";
user_subscription(?zap_cmo_25E) ->
    " SL Zap Vacances et Zap V3 ";
user_subscription(?ppola) ->
    " PPOLA ";
user_subscription(?m6_cmo_3h)->
    " M6 FB 3h ";
user_subscription(?m6_cmo_20h_8h)->
    " M6 FB 1h O&f 20h - 8h ";
user_subscription(?FB_M6_1H_SMS)->
    " FB M6 1h SMS 19.99E ";
user_subscription(?FB_M6_1H30)->
    " FB M6 1h30 25.99E ";
user_subscription(?m6_cmo_onet_2h_30E)->
    " M6 ONET 2h 29.99E ";
user_subscription(?rsa_cmo)->
    " FB Special RSA";
user_subscription(?zap_cmo_1h_unik) ->
    "SL Zap 1h avec Unik";
user_subscription(?zap_cmo_1h30_ill) ->
    "SL Zap 1h30 Ill";
user_subscription(?DCLNUM_CMO_SL_ZAP_1h30_ILL) ->
    "SL Zap 1h30 Msg 24/7";
user_subscription(?m6_cmo_fb_1h) ->
    "M6 FB 1h";
user_subscription(?cmo_smart_40min) ->
    "SMART 40MIN";
user_subscription(?cmo_smart_1h) ->
    "SMART 1H";
user_subscription(?cmo_smart_1h30) ->
    "SMART 1H30";
user_subscription(?cmo_smart_2h) ->
    "SMART 2H";
user_subscription(_) ->
    "UNKOWN DECLICAISON".

code_zap_zone(DCL) ->
    case DCL of 
	X when X==?zap_vacances;
	       X==?zap_cmo_25E ->
	    link_rank(?zap_zone,[?avantages_vacances, ?zap_zone]);
	_ ->
	    link_rank(?zap_zone, [?zap_zone])
    end.


code_menu_en_ce_moment(DCL) ->
    case DCL of 
	?zap_cmo_20E ->  link_rank(?en_ce_moment,[?zap_zone]);
	?zap_vacances -> link_rank(?en_ce_moment,[?avantages_vacances, ?zap_zone]);
	?zap_cmo_25E ->  link_rank(?en_ce_moment,[?avantages_vacances, ?zap_zone]);
	X when X==?zap_cmo_1h_unik;
	       X==?zap_cmo_1h30_ill;
	       X==?DCLNUM_CMO_SL_ZAP_1h30_ILL;
	       X==?cmo_smart_40min;
	       X==?cmo_smart_1h;
	       X==?cmo_smart_1h30;
	       X==?cmo_smart_2h->
	    link_rank(?en_ce_moment,[?zap_zone]);
	_ -> link_rank(?en_ce_moment)
    end.

code_promos_du_moment(DCL) ->
    case DCL of
        X when X==?zap_vacances;
	       X==?zap_cmo_20E;
               X==?zap_cmo_25E;
               X==?rsa_cmo;
	       X==?zap_cmo_1h_unik;
	       X==?zap_cmo_1h30_ill;
	       X==?DCLNUM_CMO_SL_ZAP_1h30_ILL;
	       X==?cmo_smart_40min;
               X==?cmo_smart_1h;
               X==?cmo_smart_1h30;
               X==?cmo_smart_2h->
            "2";
        _->
            "3"
    end.

code_kdo(DCL) ->
    case DCL of
        X when X==?zap_vacances;
	       X==?zap_cmo_20E;
               X==?zap_cmo_25E;
               X==?rsa_cmo;
	       X==?zap_cmo_1h_unik;
	       X==?DCLNUM_CMO_SL_ZAP_1h30_ILL->
            "3";
        _->
            "4"
    end.


text_menu_en_ce_moment(DCL, Activated) ->
    case {DCL, Activated} of 
	{D, _} when D==?rsa_cmo ->
	    ".*En ce moment !"
		".*1:Promos du moment"
                ".*2:Decouvrez les Bons Plans : 1 jour ou 1 soir d'illimite a choisir"
		".*3:Nouveau : option Sport"
		".*4:Kdo";
	{D, _} when D==?m6_cmo_3h;D==?m6_cmo_20h_8h;D==?m6_cmo_fb_1h;
		    D==?FB_M6_1H_SMS;D==?FB_M6_1H30;D==?m6_cmo_onet_2h_30E ->
	    ".*En ce moment !"
		".*1:Promos du moment"
                ".*2:Decouvrez les Bons Plans : 1 jour ou 1 soir d'illimite a choisir"
		".*3:Nouveau : option Sport"
		".*4:Inside M6 mobile"
		".*5:Kdo";
	{X, subscribed} when X==?zap_vacances;
			     X==?zap_cmo_20E;
			     X==?zap_cmo_25E;
			     X==?zap_cmo_1h_unik;
			     X==?zap_cmo_1h30_ill;
			     X==?DCLNUM_CMO_SL_ZAP_1h30_ILL;
			     X==?cmo_smart_40min;
			     X==?cmo_smart_1h;
			     X==?cmo_smart_1h30;
			     X==?cmo_smart_2h->
	    ".*En ce moment !"
		".*1:Promos du moment"
                ".*2:Decouvrez les Bons Plans : 1 jour ou 1 soir d'illimite a choisir"
		".*3:Nouveau : option Sport"
		".*4:Kdo";

	{_, not_subscribed} -> 
	    ".*En ce moment !"
		".*1:Promos du moment"
                ".*2:Decouvrez les Bons Plans : 1 jour ou 1 soir d'illimite a choisir"
		".*3:Nouveau : option Sport"
                ".*4:Decouverte Zap zone"
		".*5:Kdo"
    end.    

%% set_present_period(DatesList) ->
%%     test_util_of:set_present_period_for_test(commercial_date_cmo,DatesList).
%% set_past_period(DatesList) ->
%%     test_util_of:set_past_period_for_test(commercial_date_cmo,DatesList).
set_present_period([])->
    [];
set_present_period([H|T]) ->
    test_util_of:set_present_commercial_date(H,cmo)++
        set_present_period(T).
set_past_period([])->
    [];
set_past_period([H|T]) ->
    test_util_of:set_past_commercial_date(H,cmo)++
	set_past_period(T).

asmserv_restore(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_restore(MSISDN, ACTIV_OPTs).
asmserv_init(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_init(MSISDN, ACTIV_OPTs).

close_session() ->
    test_util_of:close_session().
