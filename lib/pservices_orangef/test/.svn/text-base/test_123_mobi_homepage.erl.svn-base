-module(test_123_mobi_homepage).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid, mobi_user).
-define(Uid_oto, one2one_oe).

pages()->
    [?main_page, ?menu_page, ?bons_plans, ?suivi_conso_plus_menu].
%%%% Definition of links in pages
%%%% static links are those which are always displayed
%%%% dynamic links are those which are displayed in certain conditions
%%%% By default, only static links are displayed
%%%% To display dynamic links, this should be specified when calling access_code
%%%% For each new page defined, its title should be added in function pages()
parent(_)->
    ?MODULE.

links(?main_page) -> 
    [ {?suivi_conso_plus, dyn},
      {?savoir_plus, dyn},
      {?recharger, dyn},
      {?menu_page, static},
      {?aide, static}]; 

links(?menu_page) ->
    [
     {?suivi_conso_plus_menu, dyn},
     {?recharger_menu, static},
     {?foot_variable_x, dyn},
     {?foot_variable_y, dyn},
     {?mobi_bonus, dyn},
     {?bons_plans, static},
     {?variable_y, dyn},
     {?click_bonus, dyn},
     {?'fun', static},
     {?nouveautes, static},
     {?m6_variable_x, dyn}
    ];
links(?bons_plans) ->
    [
     {?soirees, dyn},     
     {?exclusives, dyn},
     {?vos_appels, static},
     {?vos_messages, static},
     {?votre_multimedia, static},
     {?roaming, static},
     {?autres_options, dyn}
    ];
links(?suivi_conso_plus_menu) ->
    [
     {?suivi_plus_bonus, dyn},
     {?suivi_plus_recharge,dyn},
     {?suivi_plus_options, static}
    ];
links(Else) ->
    io:format("~p : links of this page ~p are not defined~n",[?MODULE, Else]).
online() ->
    test_util_of:online(?MODULE,test_mobi_homepage()),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dcl_to_service(?mobi) ->
    "Mobi";
dcl_to_service(?OM_mobile) ->
    "Foot";
dcl_to_service(?m6_prepaid) ->
    "M6 Prepaid";
dcl_to_service(?umobile) -> 
    "UMobi";                
dcl_to_service(?B_phone) -> 
    "Bic phone";                
dcl_to_service(_) ->
    "Click".

test_mobi_homepage() ->
    test_homepage(?DCLNUM_ADFUNDED)++
    	test_homepage(?mobi)++
    	test_homepage(?click_mobi)++
    	test_homepage(?OM_mobile)++
    	test_homepage(?m6_prepaid)++
    	test_homepage(?umobile)++

    	test_main_menu(?mobi)++
    	test_main_menu(?click_mobi)++
    	test_main_menu(?OM_mobile)++
    	test_main_menu(?m6_prepaid)++
    	test_main_menu(?umobile)++

    	test_link_var_Y_decouv_option_sport(?OM_mobile) ++
	test_return_to_Suivi_Conso_menu(?mobi)++
	["Test reussi"].

expect_main_page(with_oto) ->
    "1:Suivi Conso \\+.*Repondez.*2:En savoir \\+.*3:Menu.*4:Aide";
expect_main_page(without_oto_with_promo_mobi) ->
    "label forf.*Repondez.*1:Suivi Conso \\+.*2:Menu.*3:Aide.*";
expect_main_page(without_oto_with_promo) ->
    "label forf.*Repondez.*1:Suivi conso options.*2:Menu.*3:Aide.*";
expect_main_page(without_oto_without_promo) ->
    "label forf.*Appuyez repondre,tapez 1,envoyez.*1:Menu.*2:Aide.*";
expect_main_page(without_oto_without_promo_adfunded) ->
    ".*Repondez.*1:Menu.*2:Aide.*";
expect_main_page(spider_pas_response_sans_menu) ->
    "Service Indisponible. Nous vous invitons a consulter votre compte sur www.orange.fr>espace client.*";
expect_main_page(?mobi)->
    "mobicarte.*Votre credit est epuise.*"
	"Pour conserver votre numero .......... pensez a recharger avant le ../../..";
expect_main_page(?click_mobi) ->
    "Click la mobicarte.*Credit epuise.*"
	"Merci de recharger avant le ../../...*.......... valide jusqu'au ../../...";
expect_main_page(?OM_mobile) ->
    "Carte prepayee clubs de foot.*Credit epuise.*"
	"Merci de recharger avant le ../../...*.......... valide jusqu'au ../../...";
expect_main_page(?m6_prepaid)->
    "M6 Mobile By Orange.*Credit epuise.*"
	"Merci de recharger avant le ../../...*.......... valide jusqu'au ../../...";
expect_main_page(?umobile) ->
    "U mobile.*Votre credit est epuise.*"
	"Pour conserver votre numero ...........*pensez a recharger avant le ../../...";
expect_main_page(?B_phone) ->
    "mobicarte.*Votre credit est epuise.*Vous pouvez recharger.*Appuyez sur repondre,  tapez 1 et envoyez";
expect_main_page(?DCLNUM_ADFUNDED)->
    "M6 mobile.*Votre credit est epuise.Vos avantages sont supendus.*Vous pouvez recharger.*"
	"Appuyez sur repondre,  tapez 1 et envoyez";
expect_main_page(_) ->
    ".*".

expect_menu_page(DCL)
  when DCL==?mobi;DCL==?B_phone; DCL==?DCLNUM_ADFUNDED ->
    "Menu #123#.*1:Suivi Conso \\+.*2:Recharger.*";
expect_menu_page(?OM_mobile)->
    "Menu #123#.*1:Recharger.*2:Activez vos soirees infinies.*3:Decouvrir l'option Sport.*4:Vos bons plans.*";
expect_menu_page(?m6_prepaid)->
    "Menu #123#.*1:Recharger.*2:Gerer vos bons plans.*3:Fun.*4:Nouveautes.*";
expect_menu_page(_)->
    "Menu #123#.*1:Recharger.*2:Vos bons plans.*".

test_homepage(?umobile=DCL) ->
    test_homepage_without_oto(DCL) ++
    	test_homepage_credit_ep(DCL) ++
   	test_homepage_spider_no_response(DCL) ++
	[];

test_homepage(DCL) ->
    test_homepage_with_oto(DCL) ++
      	test_homepage_without_oto(DCL) ++
      	test_homepage_credit_ep(DCL) ++
      	test_homepage_spider_no_response(DCL) ++
	[].

test_homepage_with_oto(?mobi=DCL) ->
    init_test(with_oto)++
	profile_manager:set_default_spider(?Uid_oto,config,[actif,suivi_conso_plus])++
	profile_manager:set_dcl(?Uid_oto,DCL)++
        [{title, "Test Homepage - Avec oto ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},
	 {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
           {expect, expect_main_page(with_oto)},
           {send, "1"},
	   {expect, "label forf: 3h34m11s ou 45SMS.*"
	    "1:Choisir mon Bonus.*"}
          ]
         }
        ]++
        test_util_of:close_session();

test_homepage_with_oto(DCL) ->
    init_test(with_oto)++
	profile_manager:set_default_spider(?Uid_oto,config,[actif,suivi_conso_plus])++
	profile_manager:set_dcl(?Uid_oto,DCL)++
	[{title, "Test Homepage - Avec oto ####\n"
 	  "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n" ++
	  "#### Avec promo/bons plans  ####"
 	 },
 	 {ussd2,
 	  [
 	   {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
 	   {expect, expect_main_page(with_oto)},
 	   {send, "1"},
           {expect, "1:Suivi conso options.*"
	    "2:Menu.*"
	    "3:Aide.*"}
 	  ]
 	 }
 	]++
 	test_util_of:close_session() ++
    init_test(with_oto)++
	profile_manager:update_spider(?Uid_oto,profile,{offerPOrSUid,"3G"})++
        profile_manager:set_dcl(?Uid_oto,DCL)++
        [{title, "Test Homepage - Avec oto ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n" ++
          "#### Avec promo/bons plans  ####\n" ++
	  "#### Produit: 3G - Restitution:  postpaid - Go to Spider pas reponse sans menu page ####"
         },
         {ussd2,
          [
	   {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
           {expect, expect_main_page(spider_pas_response_sans_menu)}
          ]
         }
        ]++
        test_util_of:close_session() ++
	[].

test_homepage_without_oto(?mobi=DCL) ->
    init_test(without_oto)++
	profile_manager:set_dcl(?Uid,DCL)++
        [{title, "Test Homepage - Sans oto ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},

         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
           {expect, expect_main_page(without_oto_with_promo_mobi)},
	   {send, "1"},
           {expect, "label forf:3h34m11s ou 45SMS.*"
            "1:Choisir mon Bonus.*"}
          ]
         }
        ] ++
        test_util_of:close_session();

test_homepage_without_oto(DCL) ->
    init_test(without_oto)++
	profile_manager:set_default_spider(?Uid,config,[actif,suivi_conso_plus])++
	profile_manager:set_dcl(?Uid,DCL)++
	[{title, "Test Homepage - Sans oto ####\n"
	  "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n" ++
	  "#### Avec promo/bons plans  ####"},

	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
	   {expect, expect_main_page(without_oto_with_promo)}
	  ]
	 }
	] ++
	case DCL of
	    ?DCLNUM_ADFUNDED->
		test_util_of:close_session() ++
		    init_test(without_oto)++
		    profile_manager:set_dcl(?Uid,DCL)++
		    [{title, "Test Homepage - Sans oto ####\n"
		      "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n" ++
		      "#### Sans promo/bons plans  ####"},

		     {ussd2,
		      [
		       {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
		       {expect, expect_main_page(without_oto_without_promo_adfunded)}
		      ]
		     }
		    ];
	    _->
		test_util_of:close_session() ++
		    init_test(without_oto)++
		    profile_manager:set_dcl(?Uid,DCL)++
		    [{title, "Test Homepage - Sans oto ####\n"
		      "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n" ++
		      "#### Sans promo/bons plans  ####"},

		     {ussd2,
		      [
		       {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
		       {expect, expect_main_page(without_oto_without_promo)}
		      ]
		     }
		    ]
	end ++
	test_util_of:close_session().

test_homepage_credit_ep(DCL) ->
    init_test(with_oto) ++
	profile_manager:set_default_spider(?Uid_oto,config,[])++
	profile_manager:set_dcl(?Uid_oto,DCL)++
	[{title, "Test Homepage - Credit epuise ####\n"
	  "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
           {expect, expect_main_page(DCL)},
           {send, "2"},
           {expect, expect_menu_page(DCL)}
          ]
         }
        ]++
        test_util_of:close_session() ++
	[].


test_homepage_spider_no_response(DCL)->
    init_test(without_oto)++
	profile_manager:set_dcl(?Uid,DCL)++
	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a302"})++
        [{title, "Test Homepage - Indispo Spider ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"#"},
           {expect, ".*"}
          ]
         }
	]++
	test_util_of:close_session() ++
        [].


test_main_menu(?mobi=DCL) ->
    profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
        profile_manager:init(?Uid)++

	[{title, "Test Main menu #123 ####\n"
	  "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE,?main_page)++"*2#"},
	   {expect, "Menu #123#.*"
	    "1:Suivi Conso \\+.*"
	    "2:Recharger.*"}
	  ]
	 }
	] ++
	test_util_of:close_session();

test_main_menu(DCL)->
    profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
	profile_manager:init(?Uid)++

	[{title, "Test Main menu #123 ####\n"
	  "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n"
	  "#### Sans promo / bon plan  ####"},
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE,?main_page)++"*1#"},
	   {expect, "Menu #123#.*"
	    "1:Recharger.*"}
	  ]
	 }
	] ++
	test_util_of:close_session() ++

	profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
	profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:init(?Uid)++

        [{title, "Test Main menu #123 ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####\n" ++
	  "#### With promo / bon plan  ####"},

         {ussd2,
          [
	   {send, test_util_of:access_code(?MODULE,?main_page)++"*2#"},
	   {expect, "Menu #123#.*"
	    "1:Suivi Conso \\+.*"
	    "2:Recharger.*"}
          ]
         }
        ]++
	[].

test_link_var_Y_decouv_option_sport(DCL) ->
    init_test(with_oto) ++
	profile_manager:set_default_spider(?Uid_oto,config,[])++
	profile_manager:set_dcl(?Uid_oto,DCL)++
        [{title, "Test Homepage - Link variable Y - Decouvrir l'option Sport  ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"*2#"},
           {expect, expect_menu_page(DCL)},
	   {send, "3"},
	   {expect, "Avec l'option Sport, suivez les grands evenements sportifs en illimite 24h/24 7j/7 pr 6E/mois"}
          ]
         }
        ]++
        test_util_of:close_session() ++
        [].

test_return_to_Suivi_Conso_menu(DCL) ->
    init_test(with_oto) ++
	profile_manager:set_default_spider(?Uid_oto,config,[])++
	profile_manager:set_dcl(?Uid_oto,DCL)++
        [{title, "Test Return to Suivi Conso Menu - Reaccess after subcribing an option in Bons Plans link in the same session ####\n"
          "#### "++dcl_to_service(DCL)++"- DCL: "++ integer_to_list(DCL)++"####"},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?main_page)++"*2#"},
           {expect, expect_menu_page(DCL)},
	   {send, "4"},
	   {expect, ".*3:Vos messages.*"},
	   {send, "3"},
	   {expect,"Bons plans messages.*1:Option SMS.*"},
	   {send,"1"},
	   {expect,"Options SMS.*1:30 SMS\\/MMS.2:bon plan SMS quotidien.3:Journee SMS Illimites.4:Soiree SMS illimites.*"},
   	   {send,"1"},
	   {expect,"Decouvrez le bon plan 30 SMS\\/MMS : pour 3E par mois, envoyez 30 SMS ou MMS vers tous les operateurs..*1:Souscrire.*"},
   	   {send,"1"},
	   {expect,".*1:Valider.*"},
   	   {send,"1"},
	   {expect,".*9:Accueil.*"},
	   {send, "9"},
	   {expect, expect_menu_page(DCL)},
	   {send,"1"},
	   {expect, expect_main_page(DCL)}
          ]
         }
        ]++
        test_util_of:close_session() ++
        [].
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Init Config %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_oto()->
    rpc:call(possum@localhost,one2one_offers,csv2mnesia,["test_sample.csv"]),
    PAUSE = 2000,
    ["Activation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost,
			    pcontrol, enable_itfs,
			    [[io_oto_mqseries1,possum@localhost]]]}]},
     "Pause de "++ integer_to_list(PAUSE) ++" Ms",
     {pause, PAUSE}] ++
        test_util_of:set_parameter_for_test(one2one_activated_cmo,true) ++
        test_util_of:set_parameter_for_test(one2one_activated_mobi,true) ++
        test_util_of:set_parameter_for_test(one2one_activated_postpaid,true) ++
        [].

init_test(with_oto)->
    profile_manager:create_default(?Uid_oto,"mobi")++
	profile_manager:init(?Uid_oto)++
	init_oto();

init_test(without_oto)->
    profile_manager:create_default(?Uid,"mobi")++
	profile_manager:init(?Uid).
