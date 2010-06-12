-module(test_123_cmo_bons_plans).

-export([online/0,
	 pages/0,
	 parent/1,
	 links/1]).

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
-define(BP_OPTS, [opt_j_app_ill,
		  opt_s_app_ill,
		  opt_jsms_ill,
		  opt_ssms_ill,
		  opt_j_mm_ill,
		  opt_s_mm_ill,
		  opt_j_omwl,
		  opt_j_tv_max_ill,
		  opt_s_tv_max_ill]).
-define(BP_OPTS_KDO, [ opt_j_app_ill_kdo_bp,
 		      opt_s_app_ill_kdo_bp,
 		      opt_j_mm_ill_kdo_bp,
 		      opt_s_mm_ill_kdo_bp,
 		      opt_ssms_ill_kdo_bp,
 		      opt_jsms_ill_kdo_bp,
 		      opt_j_omwl_kdo_bp,
		      opt_j_tv_max_ill_kdo_bp,
		      opt_s_tv_max_ill_kdo_bp]).
-define(BP_OPTS_JEU, [opt_jsms_ill_jeu,
		      opt_ssms_ill_jeu,
		      opt_j_mm_ill_jeu,
		      opt_s_mm_ill_jeu]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?bons_plans_page, bons_plans_page_suite].

parent(?bons_plans_page) -> 
    test_123_cmo_Homepage;
parent(bons_plans_page_suite) ->
    ?MODULE.

links(?bons_plans_page) ->
    [{j_appels_ill, static},
     {s_appels_ill, static},
     {j_sms_mms_ill, static},
     {s_sms_mms_ill, static},
     {j_surf_tv_ill, static},
     {bons_plans_page_suite, static}];

links(bons_plans_page_suite) ->
    [{s_surf_tv_ill, static},
     {j_omwl,static},
     {j_tv_max_ill, static},
     {s_tv_max_ill, static}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop(),
    ok.

test()->
    [test_util_of:connect(smppasn)] ++

   	test_teasing_out_jkdo_bp_date([?m6_cmo_20h_8h])++
	test_jkdo_bp_bon_plan_actived([?m6_cmo_20h_8h, ?cmo_smart_40min])++
	test_jkdo_bp_journee_OMWL_actived([?m6_cmo_20h_8h, ?cmo_smart_40min]) ++

	test_journee_kdo_bons_plans([ ?m6_cmo_20h_8h])++
	test_bons_plans([?m6_cmo_20h_8h, ?cmo_smart_40min])++
	test_bons_plans_jeu_disney([?m6_cmo_20h_8h, ?cmo_smart_40min])++

	["Test reussi"].

init_test(DCL) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
        profile_manager:init(?Uid)++
	[].

test_teasing_out_jkdo_bp_date([]) -> [];
test_teasing_out_jkdo_bp_date([DCL|T]) ->
    init_test(DCL)++
	set_present_period(?BP_OPTS) ++
        set_present_period([teasing_jkdo_bp]) ++
        set_past_period([journee_kdo_bp]) ++

	[{title, "#### Journee KDO Bons plans - Teasing / NOT in 'Journee KDO Bons plans' date - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [
	   {send, test_util_of:access_code(parent(?bons_plans_page), ?menu_page)++"#"},		   
	   {expect , "Pour feter ses 5 ans, M6 Mobile vous offre un Bon plan : le mercredi 16 Juin, le bon plan de votre choix est gratuit !.*"
	    "1:En savoir plus sur cette offre.*"
	    "2:Menu"},
	   {send, "1"},
	   {expect, "Le 16/06 uniquement, le bon plan de votre choix est gratuit : Journee ou Soiree appels / SMS / Internet / TV.*"
	    "1:Decouvrir les bons plans"},
	   {send, "1"},	   
	   {expect,expect_bons_plans_menu(page1)},
	   {send,"6"},
	   {expect,"1:Soiree Internet illimite.*"},
	   {send,"1"},
	   {expect, expect_text(description1, opt_s_mm_ill)}	       
	  ]
	 }]++
	close_session() ++
	test_teasing_out_jkdo_bp_date(T).

test_jkdo_bp_bon_plan_actived([]) -> [];
test_jkdo_bp_bon_plan_actived([DCL|T]) ->
    init_test(DCL)++
	set_present_period(?BP_OPTS) ++
        set_present_period([teasing_jkdo_bp, journee_kdo_bp]) ++

	profile_manager:set_list_options(?Uid,[#option{top_num=top_num(opt_s_tv_max_ill, cmo)}])++
        [{title, "#### Journee KDO Bons plans - 'Journee KDO Bons plans' date / One 'bon plan' actived - DCL="++integer_to_list(DCL)++" ####"},
         {ussd2,
          [{send, code_menu_bons_plans(DCL)},
	   {expect,expect_bons_plans_menu(page1)},
           {send,"6"},
	   {expect,"1:Soiree Internet illimite.*"},
	   {send,"1"},
           {expect, expect_text(description1, opt_s_mm_ill)}
          ]}]++
        close_session() ++
        test_jkdo_bp_bon_plan_actived(T).

test_jkdo_bp_journee_OMWL_actived([]) -> [];
test_jkdo_bp_journee_OMWL_actived([DCL|T]) ->
    init_test(DCL)++
        profile_manager:set_list_options(?Uid,[#option{top_num=157}])++
	set_present_period(?BP_OPTS_KDO) ++
	set_present_period([teasing_jkdo_bp]) ++
	set_present_period([journee_kdo]) ++

	[{title, "#### Journee KDO Bons plans - 'Journee KDO Bons plans' date / 'Bon plan' Journee OM by WL actived - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [{send, code_menu_bons_plans(DCL)},
	   {expect,expect_bons_plans_menu(page1)},
	   {send,"1"},
	   case DCL of
	       ?m6_cmo_20h_8h-> 
		   {expect, expect_text(description1, opt_j_app_ill_kdo_bp)};
	       _-> {expect, expect_text(description1, opt_j_app_ill)}
	   end
	  ]}]++
	close_session() ++
	test_jkdo_bp_journee_OMWL_actived(T).

test_journee_kdo_bons_plans([]) -> [];
test_journee_kdo_bons_plans([DCL|T]) ->
    test_journee_kdo_bp_menu(DCL) ++
 	test_bon_plan(DCL, ?BP_OPTS_KDO, journee_kdo) ++

	test_journee_kdo_bons_plans(T)++
	[].

test_journee_kdo_bp_menu(DCL) ->
    init_test(DCL)++
	set_present_period(?BP_OPTS_KDO) ++
        set_present_period([teasing_jkdo_bp]) ++
	set_present_period([journee_kdo]) ++
	[{title, "#### Journee KDO Bons plans - Menu - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [{send, code_menu_bons_plans(DCL)},
	   {expect,expect_bons_plans_menu(page1)},
	   {send,"6"},
	   {expect,expect_bons_plans_menu(page2)},
	   {send, "1"},
	   {expect, ".*"}
	  ]}]++
   	[{title,"###Test Journee KDO Bons plans - Access from MENU ###"},
	 {ussd2,
	  [{send, test_util_of:access_code(parent(?bons_plans_page), ?menu_page)++"#"},
	   {expect,"Menu #123#.*Pour feter ses 5 ans, M6 Mobile vous offre un Bon plan : le mercredi 16 Juin, le bon plan de votre choix est gratuit.*1:En savoir plus sur cette offre.*2:Menu.*"},
	   {send,"2"},
	   {expect,"Menu #123#.*.*2:Souscrire options et nouveaux Bons plans.*3:Suivi Conso.*"},
	   {send, "2"},
	   {expect, ".*Bons plans.*"},
	   {send,"1"},		
	   {expect,expect_bons_plans_menu(page1)},
	   {send, "6"},
	   {expect,expect_bons_plans_menu(page2)},
	   {send, "1"},
	   {expect, ".*5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement de Surf sur tout l'Internet en illimite aujourd'hui de 20h a minuit.*"}
	  ]}]++

	[{title,"###Test Journee KDO Bons plans - Test other link on Menu page ###"},
         {ussd2,
          [{send, test_util_of:access_code(parent(?bons_plans_page), ?menu_page)++"#"},
           {expect,"Menu #123#.*Pour feter ses 5 ans, M6 Mobile vous offre un Bon plan : le mercredi 16 Juin, le bon plan de votre choix est gratuit !.*1:En savoir plus sur cette offre.*2:Menu.*"},
           {send,"2"},
           {expect,"Menu #123#.*.*2:Souscrire options et nouveaux Bons plans.*3:Suivi Conso.*5:En ce moment.*"},
           {send, "5"},
           {expect, ".*En ce moment.*"}
	  ]}]++
	close_session()++
	[].

test_bons_plans([]) -> [];
test_bons_plans([DCL|T]) ->
    test_bons_plans_menu(DCL) ++
 	test_bon_plan(DCL, ?BP_OPTS, not_journee_kdo) ++

	test_bons_plans(T).

test_bons_plans_menu(DCL) ->
    init_test(DCL)++
        set_past_period([teasing_jkdo_bp, journee_kdo_bp]) ++
	set_present_period(?BP_OPTS) ++
	set_in_hour_range(?BP_OPTS) ++
        set_out_bank_holidays(?BP_OPTS) ++

	[{title, "#### Bons plans - Menu - DCL="++integer_to_list(DCL)++" ####"},
	 "TEST BONS PLANS MENU",
	 {ussd2,
	  [{send, test_util_of:access_code(parent(?bons_plans_page), ?bons_plans_page)++"#"},
	   {expect,expect_bons_plans_menu(page1)},	  
	   {send,"6"},
	   {expect,expect_bons_plans_menu(page2)}
	  ]}]++

	set_past_period(?BP_OPTS) ++
	set_in_hour_range(?BP_OPTS) ++
        set_out_bank_holidays(?BP_OPTS) ++
	["TEST BONS PLANS MENU: Case not commercially launched",
	 {ussd2,
	  [{send, test_util_of:access_code(parent(?bons_plans_page), ?bons_plans_page)++"#"},
	   {expect,"Bons plans.*"
	    "[Journee appels illimites.*"
 	    "Soiree appels illimites.*"
 	    "Journee SMS/MMS illimites.*"
 	    "Soiree SMS/MMS illimites.*"
 	    "Journee Internet illimite.*]"
	    "1:Suite.*"},
	   {send,"1"},
	   {expect,"[Soiree Internet illimite.*"
	    "Journee OM by WL.*]"}
	  ]}]++

	set_present_period(?BP_OPTS) ++
	set_out_hour_range(?BP_OPTS) ++
        set_out_bank_holidays(?BP_OPTS) ++
        ["TEST BONS PLANS MENU: Case not in hour range",
         {ussd2,
          [{send, test_util_of:access_code(parent(?bons_plans_page), ?bons_plans_page)++"#"},
           {expect, "Bons plans.*"
            "[Journee appels illimites.*"
            "Soiree appels illimites.*"
            "Journee SMS/MMS illimites.*"
            "Soiree SMS/MMS illimites.*"
            "Journee Internet illimite.*]"
            "1:Suite.*"},
           {send,"1"},
           {expect,"[Soiree Internet illimite.*"
            "Journee OM by WL.*]"}
          ]}]++

	set_present_period(?BP_OPTS) ++
        set_in_hour_range(?BP_OPTS) ++
        set_in_bank_holidays(?BP_OPTS) ++
        ["TEST BONS PLANS MENU: Case in bank holliday and the day before",
         {ussd2,
          [{send, test_util_of:access_code(parent(?bons_plans_page), ?bons_plans_page)++"#"},
           {expect,"Bons plans.*"
            "[Journee appels illimites.*"
            "Soiree appels illimites.*"
            "Journee SMS/MMS illimites.*"
            "Soiree SMS/MMS illimites.*"
            "Journee Internet illimite.*]"
            "1:Suite.*"},
           {send,"1"},
           {expect,"[Soiree Internet illimite.*"
            "Journee OM by WL.*]"}
          ]}]++

	close_session()++	
        [].

test_bons_plans_jeu_disney([]) ->
    [];
test_bons_plans_jeu_disney([DCL|T]) ->
    test_bon_plan(DCL, ?BP_OPTS_JEU, jeu_disney) ++

        test_bons_plans(T).

test_bon_plan(_, [], _) ->
    [];
test_bon_plan(DCL, [Option | T], PARAM) ->
    init_test(DCL)++
	case PARAM of
	    journee_kdo ->
		set_present_period(?BP_OPTS_KDO) ++
		    set_present_period([teasing_jkdo_bp, journee_kdo_bp]);
	    _ ->
		set_present_period(?BP_OPTS) ++
		    set_in_hour_range(?BP_OPTS) ++
		    set_out_bank_holidays(?BP_OPTS) ++
		    set_past_period([teasing_jkdo_bp, journee_kdo_bp]) ++

		    %% set account TCP_NUM333 for bons plans jeu Disney
		    case PARAM of
			jeu_disney ->
			    profile_manager:set_list_comptes(?Uid,
							     [
							      #compte{tcp_num=?C_PRINC,
								      unt_num=?EURO,
								      cpp_solde=1000,
								      dlv=pbutil:unixtime(),
								      rnv=0,
								      etat=?CETAT_AC},
							      #compte{tcp_num=?ADFUNDED,
								      unt_num=?EURO,
								      cpp_solde=3000,
								      dlv=pbutil:unixtime(),
								      rnv=0,
								      etat=?CETAT_AC}
							     ]);
			_ ->
			    []
		    end
	end++

	[{title, "#### Bons plans - "++bon_plan_label(Option)++" - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,

	  [{send, code_bon_plan(Option)},
	   {expect, expect_text(description1, Option)}
	  ] ++

 	  case Option of
 	      X when X==opt_j_omwl_kdo_bp;
 		     X==opt_jsms_ill_jeu; X==opt_ssms_ill_jeu;
 		     X==opt_j_mm_ill_jeu; X==opt_s_mm_ill_jeu ->
 		  [{send, "1"},
 		   {expect, expect_text(description2, Option)}
 		  ];
 	      _ ->
 		  []
 	  end++

 	  [{send, "2"}]++ %% Link to Mentions legales of the options
 	  test_men_leg(Option) ++ %% Test Mentions Legales

 	  [{send, "1"},
 	   {expect, expect_text(souscription, Option)},
 	   {send, "1"},
 	   {expect, expect_text(validation1, Option)}
 	  ]++

 	  case Option of
 	      X when X==opt_j_omwl; X==opt_j_omwl_kdo_bp;
 		     X==opt_j_app_ill; X==opt_s_app_ill; X==opt_jsms_ill;
 		     X==opt_ssms_ill; X==opt_ssms_ill_kdo_bp;
 		     X== opt_j_mm_ill; X==opt_s_mm_ill; X==opt_j_tv_max_ill; X==opt_s_tv_max_ill;
 		     X==opt_jsms_ill_jeu; X==opt_ssms_ill_jeu;
		     X==opt_j_mm_ill_jeu; X==opt_s_mm_ill_jeu ->
 		  [ {send, "1"},
 		    {expect, expect_text(validation2, Option)}
 		   ];
 	      _  ->
 		  []
 	  end

 	 }] ++
	close_session()++
	test_bon_plan(DCL, T, PARAM).

expect_bons_plans_menu(page1) ->
    "Bons plans.*"
	"1:Journee appels illimites.*"
	"2:Soiree appels illimites.*"
	"3:Journee SMS/MMS illimites.*"
	"4:Soiree SMS/MMS illimites.*"
	"5:Journee Internet illimite.*"
	"6:Suite";
expect_bons_plans_menu(page2) ->
    "1:Soiree Internet illimite.*"
	"2:Journee OM by WL.*"
	"3:Journee TV Max illimite.*"
	"4:Soiree TV Max illimite".

expect_text(description1, opt_j_omwl_kdo_bp) ->
    "Journee Orange Messenger by Windows Live.*Ce bon plan ne beneficie pas de l'operation Journee KDO..*Pour 0,90E, envoyez et recevez en illimite"
	".*1:Suite";

expect_text(description2, opt_j_omwl_kdo_bp) ->
    "vos messages depuis un mobile compatible jusqu'a minuit"
	".*1:Souscrire"
	".*2:Conditions";

expect_text(description1, Opt)
  when Opt==opt_jsms_ill_jeu; Opt==opt_ssms_ill_jeu;
       Opt==opt_j_mm_ill_jeu; Opt==opt_s_mm_ill_jeu ->
    "Grace au jeu Disney, vous avez gagne 3 euros de bons plans offerts."
	".*1:Suite"
        ".*2:Conditions"
	".*8:Precedent";

expect_text(description2, Opt) ->
    case Opt of
	opt_jsms_ill_jeu ->
	    "Avec la Journee SMS/MMS illimites \\(d'une valeur de 2E\\),beneficiez de SMS et de MMS illimites vers tous les operateurs de 8h a 20h.";
	opt_ssms_ill_jeu ->
	    "Avec la Soiree SMS/MMS illimites \\(d'une valeur de 2,5E\\), profitez de SMS et MMS illimites vers tous les operateurs de 20h a minuit";
	opt_j_mm_ill_jeu ->
	    "Avec la Journee Internet illimite \\(d'une valeur de 2E\\), surfez sur tout l'Internet mobile en illimite aujourd'hui de 8h a 20h";
	opt_s_mm_ill_jeu ->
	    "Avec la Soiree Internet illimite \\(d'une valeur de 2,50E\\),surfez sur tout l'Internet mobile en illimite aujourd'hui de 20h a minuit"
    end++
	".*1:Souscrire"
        ".*2:Conditions"
	".*8:Precedent";

expect_text(description1, Option) ->
    case Option of
	opt_j_omwl ->
	    "Journee Orange Messenger by Windows Live.*Pour 0,90E, envoyez et recevez en illimite vos messages depuis un mobile compatible jusqu'a minuit";
	opt_j_app_ill ->
	    "Journee appels illimites.*Appels illimites aujourd'hui de 8h a 20h vers tous les operateurs pour 3 euros ! Disponible jusqu'au ../...";
	opt_j_app_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement d'appels illimites aujourd'hui de 8h a 20h vers tous les operateurs.*";
	opt_s_app_ill ->
	    "Appels illimites aujourd'hui de 20 h a minuit vers tous les operateurs pour 4 euros seulement ! Disponible jusqu'au ../...";
	opt_s_app_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement d'appels illimites aujourd'hui de 20h a minuit vers tous les operateurs.*";
	opt_jsms_ill ->
	    "SMS/MMS et Orange Messenger illimites aujourd'hui de 8h a 20h vers tous operateurs pour 2 euros seulement ! Disponible jusqu'au ../...";
	opt_jsms_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement de SMS/MMS/Messenger illimites aujourd'hui de 8h a 20h vers tous operateurs.*";
	opt_ssms_ill ->
	    "SMS/MMS/Orange Messenger illimites aujourd'hui de 20h a minuit vers tous operateurs pour 2,5 euros seulement ! Disponible jusqu'au ../...";
	opt_ssms_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement de SMS/MMS/Messenger illimites aujourd'hui de 20h a 0h vers tous operateurs.*";
	opt_j_mm_ill ->
	    "Surf sur tout l'Internet \\+ Orange World, Zap zone et Inside M6 Mobile en illimite aujourd'hui de 8h a 20h";
	opt_j_mm_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement de Surf sur tout l'Internet en illimite aujourd'hui de 8h a 20h.*";
	opt_s_mm_ill ->
	    "Surf sur tout l'Internet \\+ Orange World, Zap zone et Inside M6 Mobile en illimite aujourd'hui de 20h a minuit";
	opt_s_mm_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Beneficiez gratuitement de Surf sur tout l'Internet en illimite aujourd'hui de 20h a minuit.*";
	opt_j_tv_max_ill ->
	    "Accedez a plus de 60 chaines TV en illimite aujourd'hui de 8h a 20h";
	opt_j_tv_max_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Accedez a plus de 60 chaines TV gratuitement aujourd'hui de 8h a 20h.*";
	opt_s_tv_max_ill ->
	    "Accedez a plus de 60 chaines TV en illimite aujourd'hui de 20h a minuit";
	opt_s_tv_max_ill_kdo_bp ->
	    "5 ans M6 Mobile : un bon plan offert. Accedez a plus de 60 chaines TV gratuitement aujourd'hui de 20h a minuit.*"
    end ++
	".*1:Souscrire"
	".*2:Conditions";

expect_text(souscription, Option) ->
    "Souscription.*" ++
	case Option of
	    X when X==opt_j_omwl;
		   X==opt_j_omwl_kdo_bp ->
		"Vous allez souscrire a la journee OMWL. Votre compte sera debite de 0,90E. L'option sera valable jusqu'a minuit.";
	    opt_j_app_ill ->
		"Vous allez souscrire a une journee appels illimites valable aujourd'hui de 8h a 20h. Votre compte sera debite de 3 euros.";
	    opt_j_app_ill_kdo_bp ->
		"Vous allez souscrire a une Journee appels illimites GRATUITE valable aujourd'hui de 8h a 20h.";
	    opt_s_app_ill ->
		"Vous allez souscrire a une Soiree appels illimites valable aujourd'hui de 20h a minuit.Votre compte sera debite de 4 euros.";
	    opt_s_app_ill_kdo_bp ->
		"Vous allez souscrire a une Soiree appels illimites GRATUITE valable aujourd'hui de 20h a minuit.";
	    opt_jsms_ill ->
		"Vous allez souscrire a une journee SMS/MMS/Messenger illimites valable aujourd'hui de 8h a 20h. Votre compte sera debite de 2 euros.";
	    opt_jsms_ill_kdo_bp ->
		"Vous allez souscrire a une Journee SMS/MMS/Messenger illimites GRATUITE valable aujourd'hui de 8h a 20h.";
	    opt_ssms_ill ->
		"Vous allez souscrire 1 soiree SMS/MMS/Messenger illimite valable aujourd'hui de 20h a 0h.Votre compte sera debite de 2,5 EUR";
	    opt_ssms_ill_kdo_bp ->
		"Vous allez souscrire a une Soiree SMS/MMS/Messenger illimites GRATUITE valable aujourd'hui de 20h a minuit.";
	    opt_j_mm_ill ->
		"Vous allez souscrire a une journee Internet illimite valable aujourd'hui de 8h a 20h. Votre compte sera debite de 2 euros.";
	    opt_j_mm_ill_kdo_bp ->
		"Vous allez souscrire a une Journee Internet illimite GRATUITE valable aujourd'hui de 8h a 20h.";
	    opt_s_mm_ill ->
		"Vous allez souscrire a une soiree Internet illimite valable aujourd'hui de 20h a minuit. Votre compte sera debite de 2,5 EUR.";
	    opt_s_mm_ill_kdo_bp ->
		"Vous allez souscrire a une Soiree Internet illimite GRATUITE valable aujourd'hui de 20h a minuit.";
	    opt_j_tv_max_ill ->
		"Vous allez souscrire a une journee TV Max illimite valable aujourd'hui de 8h a 20h. Votre compte sera debite de 2 euros.";
	    opt_j_tv_max_ill_kdo_bp ->
		"Vous allez souscrire a une Journee TV Max illimite GRATUITE valable aujourd'hui de 8h a 20h.";
	    opt_s_tv_max_ill ->
		"Vous allez souscrire a une Soiree TV Max illimite valable aujourd'hui de 20h a minuit. Votre compte sera debite de 2,5 EUR.";
	    opt_s_tv_max_ill_kdo_bp ->
		"Vous allez souscrire a une Soiree TV Max illimite GRATUITE valable aujourd'hui de 20h a minuit.";
	    opt_jsms_ill_jeu ->
		"Vous allez souscrire gratuitement au bon plan Journee SMS/MMS illimites \\(d'une valeur de 2E\\).";
	    opt_ssms_ill_jeu ->
		"Vous allez souscrire gratuitement au bon plan Soiree SMS/MMS illimites \\(d'une valeur de 2,50E\\).";
	    opt_j_mm_ill_jeu ->
		"Vous allez souscrire gratuitement au bon plan Journee Internet \\(d'une valeur de 2E\\).";
	    opt_s_mm_ill_jeu ->
		"Vous allez souscrire gratuitement au bon plan Soiree Internet \\(d'une valeur de 2,50E\\)."
	end ++
	".*1:Valider";

expect_text(validation1, Option) ->
    "Validation.*" ++
	case Option of
	    X when X==opt_j_omwl;
		   X==opt_j_omwl_kdo_bp ->
		"Vous disposez de la journee OMWL. Vous pouvez envoyer et recevoir en illimite vos messages depuis un mobile compatible jusqu'a minuit";
	    opt_j_app_ill ->
		"Vous avez souscrit a une journee appels illimites. Vos appels vers tous les operateurs sont illimites aujourd'hui entre 8h et 20h";
	    opt_j_app_ill_kdo_bp ->
		"Vous avez souscrit a 1 Journee appels illimites gratuite.Vos appels vers tous les operateurs sont illimites aujourd'hui entre 8h et 20h.";
	    opt_s_app_ill ->
		"Vous avez souscrit a une Soiree appels illimites. Vos appels vers ts les operateurs sont illimites aujourd'hui entre 20h et minuit";
	    opt_s_app_ill_kdo_bp ->
		"Vous avez souscrit a 1 Soiree appels illimites gratuite.Vos appels vers tous les operateurs sont illimites aujourd'hui entre 20h et minuit.";
	    opt_jsms_ill ->
		"Vous avez souscrit a une journee SMS/MMS/Messenger illimites. Messages illimites vers ts les operateurs aujourd'hui entre 8h et 20h";
	    opt_jsms_ill_kdo_bp ->
		"Vous avez souscrit a 1 Journee SMS/MMS/Messenger illimites gratuite. Messages illimites vers ts les operateurs aujourd'hui entre 8h et 20h.";
	    opt_jsms_ill_jeu ->
		"Vous avez souscrit au bon plan Journee SMS illimites pour 2E. Ce montant a ete debite de votre compte offert.";
	    opt_ssms_ill ->
		"Vous avez souscrit a une soiree SMS/MMS/Messenger illimites. Messages illimites vers tous les operateurs aujourd'hui...";
	    opt_ssms_ill_kdo_bp ->
		"Vous avez souscrit a une Soiree SMS/MMS/Messenger illimites gratuite. Messages illimites vers tous les operateurs...";
	    opt_ssms_ill_jeu ->
		"Vous avez souscrit au bon plan Soiree SMS/MMS illimites pour 2,50E. Ce montant a ete debite de votre compte offert.";
	    opt_j_mm_ill ->
		"Vous avez souscrit a une journee Internet illimite. Connexions et acces illimites aujourd'hui entre 8h et 20h";
	    opt_j_mm_ill_kdo_bp ->
		"Vous avez souscrit a une Journee Internet illimite gratuite. Connexions et acces illimites aujourd'hui entre 8h et 20h.";
	    opt_j_mm_ill_jeu ->
		"Vous avez souscrit au bon plan Journee Internet pour 2E. Ce montant a ete debite de votre compte offert.";
	    opt_s_mm_ill ->
		"Vous avez souscrit a une Soiree Internet illimite. Connexions illimites aujourd'hui entre 20h et minuit";
	    opt_s_mm_ill_kdo_bp ->
		"Vous avez souscrit a une Soiree Internet illimite gratuite. Connexions et acces illimites aujourd'hui entre 20h et minuit.";
	    opt_s_mm_ill_jeu ->
		"Vous avez souscrit au bon plan Soiree Internet pour 2,50E. Ce montant a ete debite de votre compte offert.";
	    opt_j_tv_max_ill ->
		"Vous avez souscrit a une journee TV Max illimite. Connexions et acces illimites aujourd'hui entre 8h et 20h";
	    opt_j_tv_max_ill_kdo_bp ->
		"Vous avez souscrit a une Journee TV Max illimite gratuite. Connexions et acces illimites aujourd'hui entre 8h et 20h.";
	    opt_s_tv_max_ill ->
		"Vous avez souscrit a une soiree TV Max illimite. Connexions illimites aujourd'hui entre 20h et minuit";
	    opt_s_tv_max_ill_kdo_bp ->
		"Vous avez souscrit a une Soiree TV Max illimite gratuite. Connexions et acces illimites aujourd'hui entre 20h et minuit."
	end ++
	case Option of
	    X when X==opt_j_omwl; X==opt_j_omwl_kdo_bp;
		   X==opt_j_app_ill; X==opt_s_app_ill; X==opt_jsms_ill;
		   X==opt_ssms_ill; X==opt_ssms_ill_kdo_bp;
		   X== opt_j_mm_ill; X==opt_s_mm_ill; X==opt_j_tv_max_ill; X==opt_s_tv_max_ill;
		   X==opt_jsms_ill_jeu; X==opt_ssms_ill_jeu;
		   X==opt_j_mm_ill_jeu; X==opt_s_mm_ill_jeu ->
		".*1:Suite";
	    _  ->
		""
	end;

expect_text(validation2, Option) ->
    case Option of
        X when X==opt_j_omwl;
	       X==opt_j_omwl_kdo_bp ->
            "Votre option sera debitee de votre compte mobile puis de votre forfait si le compte mobile est epuise.";
        Y when Y==opt_j_app_ill; Y==opt_s_app_ill;
	       Y==opt_jsms_ill; Y==opt_j_mm_ill; Y== opt_s_mm_ill; 
	       Y==opt_j_tv_max_ill; Y==opt_s_tv_max_ill ->
            "Votre bon plan sera debite de votre compte mobile puis de votre forfait si le compte mobile est epuise.";
        opt_ssms_ill ->
            "...entre 20h et minuit. Votre bon plan sera debite de votre compte mobile puis de votre forfait si le compte mobile est epuise.";
        opt_ssms_ill_kdo_bp ->
            "...aujourd'hui entre 20h et minuit.";
	opt_jsms_ill_jeu ->
	    "Dans quelques instants, votre bon plan journee SMS/MMS illimites sera activee.";
	opt_ssms_ill_jeu ->
	    "Dans quelques instants, votre bon plan soiree SMS/MMS illimites sera activee.";
	opt_j_mm_ill_jeu ->
	    "Dans quelques instants, votre bon plan journee Internet sera activee.";
	opt_s_mm_ill_jeu ->
	    "Dans quelques instants, votre bon plan soiree Internet sera activee.";
        _ ->
            ""
    end.

test_men_leg(Option)
  when Option==opt_j_omwl; Option==opt_j_omwl_kdo_bp ->
    [
     {expect, "Option a souscrire le jour meme de 2h00 du matin a 23h00 et valable en France metropolitaine le jour meme pour une utilisation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "jusqu'a 23h59. Option donnant acces au service de messagerie instantanee Orange messenger by Windows Live.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "reserve aux clients d'Orange France, disponible en telechargement sur http://im.orange.fr et utilisable entre equipements.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compatibles dotes du service \\(cf Conditions Generales d'utilisation du service sur www.orange.fr onglet mobile\\) Envoi gratuit.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et illimite de messages metropolitains depuis un mobile en France metropolitaine a compter de la date de souscription preleve.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "a la souscription sur le compte rechargeable du client sous reserve que le credit dudit compte soit suffisant..*1:Souscrire"}
    ];

test_men_leg(opt_j_app_ill) ->
    [
     {expect, "Appels voix illimites en France metropolitaine vers tous les operateurs \\(3h maximum par appel, hors n0 speciaux.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et n0 de services et n0 en cours de portabilite\\) le jour meme de la souscription de 8h00 a 20h00..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Cession des appels et appels emis depuis des boitiers radio interdits. Appels directs entre personnes physiques,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour un usage personnel non lucratif direct. Souscription possible le jour meme, de 2h00 a 19h45..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 3E sont preleves a la souscription du bon plan sur le compte principal puis sur le compte recharge..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(opt_j_app_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL...*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Appels voix illimites en France metropolitaine vers tous les operateurs \\(3h maximum par appel, hors n0 speciaux.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et n0 de services et n0 en cours de portabilite\\) le jour meme de la souscription de 8h00 a 20h00..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Cession des appels et appels emis depuis des boitiers radio interdits. Appels directs entre personnes physiques,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour un usage personnel non lucratif direct. Souscription possible le jour meme, de 2h00 a 19h45..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(opt_s_app_ill) ->
    [
     {expect, "Appels voix illimites en France metropolitaine vers tous les operateurs \\(3h maximum par appel, hors n0 speciaux et n0 de services\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "le jour meme de la souscription de 20h a 00h. Cession des appels et appels emis depuis des boitiers radio interdits..*"},
     {send, "1"},
     {expect, "Appels directs entre personnes physiques, pour un usage personnel non lucratif direct. Souscription possible le jour.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "meme, de 2h00 a 23h45. Les 4E sont preleves a la souscription du bon plan sur le compte principal puis sur le compte recharge.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Bon plan non disponible les jours feries et veilles de jours feries.*1:Souscrire"}
    ];

test_men_leg(opt_s_app_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Appels voix illimites en France metropolitaine vers tous les operateurs \\(3h maximum par appel, hors n0 speciaux et n0 de services\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "le jour meme de la souscription de 20h a 00h. Cession des appels et appels emis depuis des boitiers radio interdits..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Appels directs entre personnes physiques, pour un usage personnel non lucratif direct. Souscription possible le jour.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "meme, de 2h00 a 23h45. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(Opt)
  when Opt==opt_jsms_ill; Opt==opt_jsms_ill_jeu ->
    [
     {expect, "Hors sms/mms surtaxes, n0s courts et mms cartes postales. sms/mms entre personnes physiques.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour un usage personnel non lucratif direct. SMS/MMS/Messenger vers tous les mobiles en France metropolitaine a utiliser.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "entre 08h00 et 20h00. Souscription possible le jour meme, de 2h00 a 19h45..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service Orange Messenger by Windows Live disponible en telechargement sur http://im.orange.fr et utilisable entre.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "equipements compatibles. Les 2 euros sont preleves a la souscription de l'option sur le compte.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "principal puis sur le compte recharge. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(opt_jsms_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Hors sms/mms surtaxes, n0s courts et mms cartes postales. sms/mms entre personnes physiques.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour un usage personnel non lucratif direct. SMS/MMS/Messenger vers tous les mobiles en France metropolitaine a utiliser.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "entre 08h00 et 20h00. Souscription possible le jour meme, de 2h00 a 19h45..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service Orange Messenger by Windows Live disponible en telechargement sur http://im.orange.fr et utilisable entre.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "equipements compatibles. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(Opt)
  when Opt==opt_ssms_ill; Opt==opt_ssms_ill_jeu ->
    [
     {expect, "Hors sms/mms surtaxes, n0s courts et mms cartes postales. sms/mms entre personnes physiques.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour un usage personnel non lucratif direct. SMS/MMS/Messenger vers tous les mobiles en France metropolitaine a utiliser.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "entre 20h00 et 00h00. Souscription possible le jour meme, de 2h00 a 23h45..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service Orange Messenger by Windows Live disponible en telechargement sur http://im.orange.fr et utilisable entre.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "equipements compatibles. Les 2,5 euros sont preleves a la souscription de l'option sur le compte.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "principal puis sur le compte recharge. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(opt_ssms_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Hors sms/mms surtaxes, n0s courts et mms cartes postales. sms/mms entre personnes physiques.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour un usage personnel non lucratif direct. SMS/MMS/Messenger vers tous les mobiles en France metropolitaine a utiliser.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "entre 20h00 et 00h00. Souscription possible le jour meme, de 2h00 a 23h45..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service Orange Messenger by Windows Live disponible en telechargement sur http://im.orange.fr et utilisable entre.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "equipements compatibles. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(Opt)
  when Opt==opt_j_mm_ill; Opt==opt_j_mm_ill_jeu ->
    [
     {expect, "Entre 8h et 20h le jour de la souscription : Navigation illimite sur le portail Orange World, Internet, Gallery et du portail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Zap zone ou Inside M6 Mobile en fonction de l'offre forfait bloque. Consultation illimitee des videos des rubriques actualite,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "cinema \\(hors Orange Cinema Series\\),sport \\(hors evenements sportifs en direct\\) et mes communautes sur le portail Orange World..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ne sont pas compris dans le Bon Plan les usages mail \\(SMTP, POP, IMAP\\), modem, les contenus et services payants..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les services de Voix sur IP, Peer to Peer et Newsgroup sont interdits. Pour une qualite de service optimale sur son reseau,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement du forfait..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Souscription possible le jour meme, de 2h00 a 19h45. Les 2 euros sont preleves a la souscription de l'option sur le compte.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "principal puis sur le compte recharge. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(opt_j_mm_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Entre 8h et 20h le jour de la souscription : Navigation illimite sur le portail Orange World, Internet, Gallery et du portail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Zap zone ou Inside M6 Mobile en fonction de l'offre forfait bloque. Consultation illimitee des videos des rubriques actualite,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "cinema \\(hors Orange Cinema Series\\),sport \\(hors evenements sportifs en direct\\) et mes communautes sur le portail Orange World..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ne sont pas compris dans le Bon Plan les usages mail \\(SMTP, POP, IMAP\\), modem, les contenus et services payants..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les services de Voix sur IP, Peer to Peer et Newsgroup sont interdits. Pour une qualite de service optimale sur son reseau,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement du forfait..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Souscription possible le jour meme, de 2h00 a 19h45. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(Opt)
  when Opt==opt_s_mm_ill; Opt==opt_s_mm_ill_jeu ->
    [
     {expect, "Entre 20h et 0h le jour de la souscription : Navigation illimitee sur le portail Orange World, Internet, Gallery et du portail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Zap zone ou Inside M6 Mobile en fonction de l'offre forfait bloque..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Consultation illimitee des videos des rubriques actualite, cinema \\(hors Orange Cinema Series\\),.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sport \\(hors evenements sportifs en direct\\) et mes communautes sur le portail Orange World..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ne sont pas compris dans le Bon Plan les usages mail \\(SMTP, POP, IMAP\\), modem, les contenus et services payants..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les services de Voix sur IP, Peer to Peer et Newsgroup sont interdits. Pour une qualite de service optimale sur son reseau,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement du forfait..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Souscription possible le jour meme, de 2h00 a 23h45. Les 2,5 euros sont preleves a la souscription de l'option sur le compte.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "principal puis sur le compte recharge. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];

test_men_leg(opt_s_mm_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Entre 20h et 0h le jour de la souscription : Navigation illimitee sur le portail Orange World, Internet, Gallery et du portail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Zap zone ou Inside M6 Mobile en fonction de l'offre forfait bloque. Consultation illimitee des videos des rubriques actualite,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "cinema \\(hors Orange Cinema Series\\), sport \\(hors evenements sportifs en direct\\) et mes communautes sur le portail Orange World..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ne sont pas compris dans le Bon Plan les usages mail \\(SMTP, POP, IMAP\\), modem, les contenus et services payants..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les services de Voix sur IP, Peer to Peer et Newsgroup sont interdits. Pour une qualite de service optimale sur son reseau,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement du forfait..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Souscription possible le jour meme, de 2h00 a 23h45. Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];
test_men_leg(opt_j_tv_max_ill) ->
    [
     {expect, "Entre 8h et 20h le jour de la souscription : acces et connexions illimitees a plus de 60 chaines de television.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et a toutes les videos proposees sur Orange World \\(hors contenus payants\\) en France Metropolitaine. Pour une qualite de service.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "du forfait.Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines TV susceptible d'evolution. Souscription possible le jour meme, de 2h00 a 19h45. Les 2 euros sont.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "preleves a la souscription du Bon plan sur le compte recharge puis sur le compte principal..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];    
test_men_leg(opt_j_tv_max_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Acces et connexions illimitees a plus de 60 chaines de television.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et a toutes les videos proposees sur Orange World \\(hors contenus payants\\) en France Metropolitaine. Pour une qualite de service.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "du forfait.Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines TV susceptible d'evolution. Souscription possible le jour meme, de 2h00 a 19h45..*1:Souscrire"}
    ];
test_men_leg(opt_s_tv_max_ill) ->
    [
     {expect, "Entre 20h et minuit le jour de la souscription : acces et connexions illimitees a plus de 60 chaines de television.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et a toutes les videos proposees sur Orange World \\(hors contenus payants\\) en France Metropolitaine. Pour une qualite de service.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "du forfait. Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines TV susceptible d'evolution. Souscription possible le jour meme, de 2h00 a 23h45. Les 2,5 euros sont.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "preleves a la souscription du Bon plan sur le compte recharge puis sur le compte principal..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Bon plan non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
    ];
test_men_leg(opt_s_tv_max_ill_kdo_bp) ->
    [
     {expect, "Offre anniversaire M6 Mobile valable le 16/06/2010 uniquement en Fr Metrop. Le 1er bon plan souscrit durant la journee est gratuit..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Choix parmi les 8 Bons Plans suivants \\(Journee ou Soiree\\) Appels illimites, SMS, Internet ou TV. Offre reservee aux clients.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "forfaits bloques M6 Mobile by Orange. Information et souscription via le 220 et le #123# \\(appels gratuits\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "L'operation Bon plan offert du 16/06/2010 ne concerne pas les bons plans Europe / Maghreb et OMWL..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Acces et connexions illimitees a plus de 60 chaines de television.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et a toutes les videos proposees sur Orange World \\(hors contenus payants\\) en France Metropolitaine. Pour une qualite de service.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500 Mo/mois jusqu'a la date de renouvellement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "du forfait.Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines TV susceptible d'evolution. Souscription possible le jour meme, de 2h00 a 23h45..*1:Souscrire"}
    ].

bon_plan_label(Option) ->
    case Option of
	opt_j_app_ill->
	    "Journee appels illimites";
	opt_j_app_ill_kdo_bp ->
	    "Journee appels illimites - KDO BP";
	opt_s_app_ill->
	    "Soiree appels illimites";
	opt_s_app_ill_kdo_bp ->
	    "Soiree appels illimites - KDO BP";
	opt_jsms_ill->
	    "Journee SMS/MMS illimites";
	opt_jsms_ill_kdo_bp ->
	    "Journee SMS/MMS illimites - KDO BP";
	opt_jsms_ill_jeu->
            "Journee SMS/MMS illimites - Jeu Disney";
	opt_ssms_ill->
	    "Soiree SMS/MMS illimites";
	opt_ssms_ill_kdo_bp ->
	    "Soiree SMS/MMS illimites - KDO BP";
	opt_ssms_ill_jeu->
            "Soiree SMS/MMS illimites - Jeu Disney";
	opt_j_mm_ill->
	    "Journee Internet illimite";
	opt_j_mm_ill_kdo_bp ->
	    "Journee Internet illimite - KDO BP";
	opt_j_mm_ill_jeu->
            "Journee Internet illimite - Jeu Disney";
	opt_s_mm_ill->
	    "Soiree Internet illimite";
	opt_s_mm_ill_kdo_bp ->
	    "Soiree Internet illimite - KDO BP";
	opt_s_mm_ill_jeu->
            "Soiree Internet illimite - Jeu Disney";
	opt_j_omwl->
	    "Journee OM by WL";
	opt_j_omwl_kdo_bp ->
	    "Journee OM by WL - KDO BP";
	opt_j_tv_max_ill ->
	    "Journee TV Max illimite";
	opt_j_tv_max_ill_kdo_bp ->
	    "Journee TV Max illimite - KDO BP";
	opt_s_tv_max_ill ->
	    "Soiree TV Max illimite";
	opt_s_tv_max_ill_kdo_bp->
	    "Soiree TV Max illimite - KDO BP"    
    end.


code_bon_plan(Option) ->
    case lists:member(Option,?BP_OPTS++?BP_OPTS_JEU) of
	true ->
	    Link = case Option of
		       opt_j_app_ill ->
			   j_appels_ill;
		       opt_s_app_ill ->
			   s_appels_ill;
		       J_SMS when J_SMS==opt_jsms_ill;
				  J_SMS==opt_jsms_ill_jeu ->
			   j_sms_mms_ill;
		       S_SMS when S_SMS==opt_ssms_ill;
				  S_SMS==opt_ssms_ill_jeu ->
			   s_sms_mms_ill;
		       J_MM when J_MM==opt_j_mm_ill;
				 J_MM==opt_j_mm_ill_jeu ->
			   j_surf_tv_ill;
		       S_MM when S_MM==opt_s_mm_ill;
				 S_MM==opt_s_mm_ill_jeu ->
			   s_surf_tv_ill;
		       opt_j_omwl ->
			   j_omwl;
		       opt_j_tv_max_ill->
			   j_tv_max_ill;
		       opt_s_tv_max_ill ->
			   s_tv_max_ill
		   end,
	    test_util_of:access_code(?MODULE, Link)++"#";

	_  ->
	    test_util_of:access_code(parent(?bons_plans_page), ?menu_page)++"11" ++
		case Option of
		    opt_j_app_ill_kdo_bp ->
			"1";
		    opt_s_app_ill_kdo_bp ->
			"2";
		    opt_jsms_ill_kdo_bp ->
			"3";
		    opt_ssms_ill_kdo_bp ->
			"4";
		    opt_j_mm_ill_kdo_bp ->
			"5";
		    opt_s_mm_ill_kdo_bp ->
			"61";
		    opt_j_omwl_kdo_bp ->
			"62";
		    opt_j_tv_max_ill_kdo_bp ->
			"63";
		    opt_s_tv_max_ill_kdo_bp ->
			"64"
		end++
		"#"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set_in_bank_holidays(Options) ->
    BankHolidays = lists:map(fun(Opt) ->
				     {Opt,[{svc_util_of:local_time(),
					    {svc_options:today_plus_datetime(7),{23,59,59}}}]}
			     end,
			     Options),
    test_util_of:set_parameter_for_test(list_bank_holidays, BankHolidays).

set_out_bank_holidays(Options) ->
    BankHolidays = lists:map(fun(Opt) ->
				     {Opt,[]}
			     end,
			     Options),
    test_util_of:set_parameter_for_test(list_bank_holidays, BankHolidays).

code_menu_bons_plans(DCL) ->
    case DCL of
	D when D==?m6_cmo_3h;D==?m6_cmo_20h_8h;D==?m6_cmo_fb_1h;
               D==?FB_M6_1H_SMS;D==?FB_M6_1H30;D==?m6_cmo_onet_2h_30E ->
	    test_util_of:access_code(parent(?bons_plans_page), ?menu_page)++"11#";
	_ ->
	     test_util_of:access_code(parent(?bons_plans_page), ?bons_plans_page)
    end.


close_session() ->
    test_util_of:close_session().

top_num(Opt,Sub) ->
    test_util_of:rpc(option_manager,get_orange_id,[{Opt,Sub},top_num]).

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

set_in_hour_range([]) -> [];    
set_in_hour_range([H|T]) ->
    test_util_of:set_open_hour(H,cmo,"always")++
       test_util_of:set_open_day(H,cmo,"always")++
       set_in_hour_range(T).

set_out_hour_range([]) -> [];
set_out_hour_range([H|T]) ->
    test_util_of:set_open_hour(H,cmo,"[{{0,0,0},{0,0,0}}]")++
       test_util_of:set_open_day(H,cmo,"[]")++
       set_out_hour_range(T).
