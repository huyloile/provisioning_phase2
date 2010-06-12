-module(test_123_mobi_nouveautes).
-compile(export_all).
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages()->
    [?nouveautes].
parent(?nouveautes)->
    test_123_mobi_homepage.

links(?nouveautes) ->
    [
     {les_bonus,             dyn}, %% mobi
     {rech_edit_spec_m6,     dyn}, %% m6
     {decouvrir_bonus_click, dyn}, %% click
     {orange_foot,           dyn}, %% foot
     {internet_mobile,       dyn}, %% all
     {offre_renouv_mobile,   dyn}, %% mobi, click, m6
     {rech_edit_spec,        dyn}, %% mobi, click, foot
     {jeu_recharge,          dyn},
     {journee_kdo_mms,       dyn}, %% mobi, click
     {zap_zone_30sms,        dyn}, %% mobi, click, foot
     {opt_orange_foot,       dyn}, %% m6
     {avantage_zap_zone,     dyn}  %% mobi, click, foot
    ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid, user_nouveautes_mobi).
-define(CODE_MAIN_MENU,
	test_util_of:access_code(parent(?nouveautes),
				 ?menu_page,[?recharger])).
-define(CODE_LES_BONUS,
	test_util_of:link_rank(?MODULE,
			       ?nouveautes,
			       les_bonus,
			       get_dyn_for_menu_mouv(?mobi))).
-define(CODE_DECOUVRIR_BONUS_CLICK,
        test_util_of:link_rank(?MODULE,
                               ?nouveautes,
                               decouvrir_bonus_click,
			       get_dyn_for_menu_mouv(?click_mobi))).
-define(CODE_AVANTAGE_ZAP_ZONE,"4").

online() ->
    test_util_of:online(?MODULE,test_nouveautes()),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

top_num(Opt) ->
    svc_options:top_num(Opt,mobi).

test_nouveautes() ->    
    test_menu_nouveaute_bic_phone_not_identify() ++

  	test_menu_nouveaute(?mobi)++
	test_menu_nouveaute(?mobi_new)++
	test_menu_nouveaute(?cpdeg)++
	test_menu_nouveaute(?mobi_janus)++
	test_menu_nouveaute(?B_phone)++
	test_menu_nouveaute(?m6_prepaid)++
	test_menu_nouveaute(?OL_mobile)++
	test_menu_nouveaute(?click_mobi)++

      	test_nouv_bonus(?mobi)++

      	test_nouv_decouvrir_bonus(?click_mobi)++

      	test_nouv_internet_mobile(?mobi)++
      	test_nouv_internet_mobile(?mobi_janus)++
      	test_nouv_internet_mobile(?B_phone)++
      	test_nouv_internet_mobile(?m6_prepaid)++
      	test_nouv_internet_mobile(?click_mobi)++
      	test_nouv_internet_mobile(?OL_mobile)++

       	test_nouv_ODR(?mobi)++
       	test_nouv_ODR(?mobi_janus)++
       	test_nouv_ODR(?B_phone)++
	test_nouv_ODR(?m6_prepaid)++
	test_nouv_ODR(?click_mobi)++

       	test_nouv_rech_edit_spec(?mobi)++
       	test_nouv_rech_edit_spec(?mobi_janus)++
       	test_nouv_rech_edit_spec(?m6_prepaid)++
      	test_nouv_rech_edit_spec(?click_mobi)++
       	test_nouv_rech_edit_spec(?OL_mobile)++
  	test_nouv_rech_edit_spec(?DCLNUM_ADFUNDED)++

 	test_avantage_decouverte_zap_zone(?mobi)++
 	test_avantage_decouverte_zap_zone(?click_mobi)++
 	test_decouverte_zap_zone_bic_phone_not_identify(?B_phone)++

	test_nuit_kdo_sms(?mobi)++
        test_nuit_kdo_sms(?mobi_janus)++
	test_nuit_kdo_sms(?m6_prepaid)++
	test_nuit_kdo_sms(?click_mobi)++
	test_nuit_kdo_sms(?OL_mobile)++
	test_nuit_kdo_sms(?DCLNUM_ADFUNDED)++

	test_journee_kdo_mms(?mobi)++
	test_journee_kdo_mms(?mobi_janus)++
	test_journee_kdo_mms(?m6_prepaid)++
	test_journee_kdo_mms(?click_mobi)++
	test_journee_kdo_mms(?OL_mobile)++
	test_journee_kdo_mms(?DCLNUM_ADFUNDED)++

% 	test_nouv_jeu_recharge(?DCLNUM_ADFUNDED)++ %%close this link in PC Jun 10
	["Test reussi"].

test_menu_nouveaute(DCL) ->
    init_test(DCL)++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
	[{title, "<center>#### Test Nouveautes - Menu ####</center>"},
	 "Test Menu Nouveaute DCL="++integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, ?CODE_MAIN_MENU },
	   {expect, "Nouveautes"},
	   {send,menu_link_nouveautes(DCL)},
	   {expect, menu_nouveautes(DCL)}
	  ]}]++

	test_util_of:close_session()++
 	profile_manager:set_list_options(?Uid, [#option{top_num=svc_options:top_num(opt_avan_dec_zap_zone,mobi),
 							opt_info2="S"
 						       }])++
	case DCL of
	    X when X==?mobi;X==?click_mobi ->
		[{title, "<center>#### Test Nouveautes - Menu - Without link ####</center>"},
		 "Test Menu Nouveaute DCL="++integer_to_list(DCL),
		 {ussd2,
		  [
		   {send, ?CODE_MAIN_MENU },
		   {expect, "Nouveautes"},
		   {send,menu_link_nouveautes(DCL)},
		   case DCL of 
		       ?mobi ->
			   {expect,
			    "1:Les Bonus.*"
			    "2:Recharges Edition Speciale.*"
			    "3:Nuit Kdo du 21/06.*"
			    "4:Journee Kdo du 14/07.*"
			    "5:Renouvellement de mobile.*"
			    "6:Internet mobile.*"};
		       ?click_mobi ->
			   {expect,
			    "1:Les bonus.*"
			    "2:Recharges Edition Speciale.*"
                            "3:Nuit Kdo du 21/06.*"
                            "4:Journee Kdo du 14/07.*"
			    "5:Renouvellement de mobile.*"
			    "6:Internet mobile.*"};
		       ?m6_prepaid  ->
			   {expect,
			   "1:Option Sport.*"
			   "2:Recharges Edition Speciale.*"
			   "3:Nuit Kdo du 21/06.*"
			   "4:Journee Kdo du 14 juillet.*"
			   "5:Offre de renouvellement de mobile.*"
			   "6:Internet mobile.*"};
		       ?OL_mobile ->
			   {expect,
			    "1:Option Sport.*"
			    "2:Recharges Edition Speciale.*"
			    "3:Nuit Kdo du 21/06.*"
			    "4:Journee Kdo du 14/07.*"
			    "5:Internet mobile.*"}
		   end
		  ]}];
	    _ ->
		[]
	end++

	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
	[].
test_menu_nouveaute_bic_phone_not_identify()->
    init_test(?B_phone)++

	profile_manager:update_user_state(?Uid,{etats_sec,0}) ++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Menu - Not identify ####</center>"},
         "Test Menu Nouveaute DCL="++integer_to_list(?B_phone),
         {ussd2,
          [
	   {send, ?CODE_MAIN_MENU },
	   {expect, "Nouveautes"},
	   {send, test_util_of:link_rank(parent(?nouveautes), ?menu_page, ?nouveautes, [?suivi_conso_plus_menu])},
	   {expect, 
	    "1:Recharges Edition Speciale.*"
	    "2:Nuit Kdo du 21/06.*"
	    "3:Journee Kdo du 14/07.*"
	    "4:Decouverte Zap zone.*"
	    "5:Offre Renouvellement de Mobile.*"
	    "6:Internet mobile.*"}
	  ]}]++
	test_util_of:close_session()++
 	profile_manager:set_list_options(?Uid, [#option{top_num=svc_options:top_num(opt_avan_dec_zap_zone,mobi),
 							opt_info2="S"
 						       }])++
        [{title, "<center>#### Test Nouveautes - Menu - Not identify - Without link ####</center>"},
         "Test Menu Nouveaute DCL="++integer_to_list(?B_phone),
         {ussd2,
          [
	   {send, ?CODE_MAIN_MENU },
	   {expect, "Nouveautes"},
	   {send, test_util_of:link_rank(parent(?nouveautes), ?menu_page, ?nouveautes, [?suivi_conso_plus_menu])},
	   {expect, 
	    "1:Recharges Edition Speciale.*"
            "2:Nuit Kdo du 21/06.*"
            "3:Journee Kdo du 14/07.*"
	    "4:Offre Renouvellement de Mobile.*"
	    "5:Internet mobile.*"}
	  ]}]++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
	[].

test_nouv_bonus(DCL) ->
    init_test(DCL)++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Les Bonus ####</center>"},
         "Test Menu Nouveautes - Les Bonus - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, "1:Les Bonus"},
            {send, ?CODE_LES_BONUS},
            {expect, "Envie d'appels offerts en France ou a l'etranger, de SMS ou d'internet mobile ?.*"
             "A chacun ses envies, a chacun son bonus.*1:Gerer votre Bonus"},
            {send, "1"},
            {expect, ".*"}
           ]}]++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
	test_util_of:close_session()++
        [].

test_nouv_decouvrir_bonus(DCL) ->
    init_test(DCL)++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Decouvrir les Bonus ####</center>"},
         "Test Menu Nouveautes - Decouvrir les Bonus - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, "1:Les bonus"},
            {send, "1"},
            {expect, "Envie d'appels offerts en France ou a l'etranger, de SMS ou d'internet mobile ?.*"
             "A chacun ses envies, a chacun son bonus.*1:Decouvrir les Bonus"},
            {send, "1"},
            {expect, ".*"}
           ]}]++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
	test_util_of:close_session()++
        [].

test_nouv_internet_mobile(DCL) ->
    init_test(DCL)++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Internet mobile ####</center>"},
         "Test Menu Nouveautes - Internet mobile - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, "Internet mobile"},
            {send, menu_link_internet_mobile(DCL)},
            case DCL of
                X when X==?m6_prepaid; X==?OL_mobile ->
                    {expect, "Les connexions a Orange World, Gallery ou internet sans option mutimedia se decomptent desormais de votre credit : 0,50E par minute indivisible.*1:Suite"};
		?click_mobi ->
                    {expect, "Avec mobicarte, les connexions a Orange World, Gallery ou internet sans option mutimedia se decomptent desormais de votre credit : 0,50E par minute indivisible.*1:Suite"};
                _ ->
                    {expect, "Avec les cartes prepayees, les connexions a Orange mobile, Gallery ou internet sans option mutimedia se decomptent de votre credit : 0,50E par minute indivisible.*1:Suite"}
            end,

            {send, "1"},
            {expect, "Tarification a la minute, hors usages clients mail et GPS. Les usages mail \\(smtp, pop ou imap\\) et GPS sont factures au Ko"}
           ]}]++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
        [].

test_avantage_decouverte_zap_zone(DCL) when DCL==?click_mobi; DCL==?mobi ->
    init_test(DCL)++
	test_conditions_avan_dec_zap_zone(DCL)++
	test_souscrire_avan_dec_zap_zone(DCL)++
        [].

test_souscrire_avan_dec_zap_zone(DCL)->
    [{title, "Test avantage decouverte zap zone - souscrire\nDCL = "++integer_to_list(DCL)},
     {ussd2,
      [ 
	{send, code_nouveautes(DCL)},                                                                                                   
	{expect, menu_nouveautes(DCL)},
	{send,"5"},
	{expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"},
	{send, "1"},
	{expect,"Vous allez souscrire a l'Avantage Decouverte Zap zone..*1:Confirmer"},
	{send,"1"},
	{expect,"Vous avez souscrit a l'Avantage Decouverte Zap Zone."}
       ]}
    ]++
	test_util_of:close_session().

test_conditions_avan_dec_zap_zone(DCL)->
    [{title, "Test avantage decouverte zap zone - conditions\nDCL = "++integer_to_list(DCL)},
     {ussd2,
      [ 
	{send, code_nouveautes(DCL)},
	{expect, menu_nouveautes(DCL)},
	{send,"5"},
	{expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"},
	{send, "2"},
	{expect,"Avantage reserve aux clients mobile Orange dont l'utilisateur de la ligne est age de moins de 18 ans et non encore inscrit au portail Zapzone..*1:Suite"},
	{send,"1"},
	{expect,"Usages en France metropolitaine.Valable sur reseau et depuis un terminal compatible..*1:Suite"},
	{send,"1"},
	{expect,"Navigation illimitee sur le portail Zap zone pendant 7 jours a compter de la souscription de l'avantage decouverte Zap zone."}
       ]}
    ]++
        test_util_of:close_session().

test_nuit_kdo_sms(DCL)->
    init_test(DCL)++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Nuit Kdo MMS ####</center>"},
         "Test Menu Nouveautes - Nuit Kdo MMS - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, "Nuit Kdo du.*"},
            {send, code_nuit_kdo_mms(DCL)},
            {expect, "Nuit Kdo SMS : Le 21 juin 2010, profitez de SMS illimites vers tous les mobiles et fixes de 21h30 au lendemain 8h.*1:Mention legale.*"},
	    {send, "1"},
	    {expect,"SMS interpersonnels emis depuis un mobile en France metropolitaine hors SMS surtaxes, n0 courts, sous reserve d'un credit > a 0E."}
           ]}]++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
        [].
test_journee_kdo_mms(DCL)->
    init_test(DCL)++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Journee Kdo SMS ####</center>"},
         "Test Menu Nouveautes - Journee Kdo SMS - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, "Journee Kdo du.*"},
            {send, code_journee_kdo_sms(DCL)},
            {expect, "Journee Kdo MMS : Le 14 juillet 2010, tous vos MMS sont offerts et illimites vers tous les mobiles et adresses e-mail de 8h a 21h.*1:Mention legale.*"},
	    {send, "1"},
	    {expect,"MMS interpersonnels emis d'un mobile en France metrop. jusqu'a 600ko, hors MMS surtaxes, n0 ourts et MMS carte postale, sous reserve d'un credit > a 0E.*"}
           ]}]++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
        [].

test_decouverte_zap_zone_bic_phone_not_identify(DCL)->
    init_test(DCL)++
 	profile_manager:update_user_state(?Uid,{etats_sec,0}) ++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Menu -decouverte zap zone bic phone Not identify ####</center>"},
         "Test Menu Nouveaute DCL="++integer_to_list(?B_phone),
         {ussd2,
          [
	   {send, ?CODE_MAIN_MENU++test_util_of:link_rank(parent(?nouveautes), ?menu_page, ?nouveautes, [?suivi_conso_plus_menu])},
	   {expect, 
	    "1:Recharges Edition Speciale.*"
	    "2:Nuit Kdo du 21/06.*"
            "3:Journee Kdo du 14/07.*"
	    "4:Decouverte Zap zone.*"
	    "5:Offre Renouvellement de Mobile.*"
	    "6:Internet mobile.*"},
	   {send, "4"},
	   {expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"}
	  ]}]++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
	[].


test_nouv_ODR(DCL) ->
    init_test(DCL)++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Offre de Renouvellement du Mobile ####</center>"},
         "Test Menu Nouveautes - Offre de Renouvellement du Mobile - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, ".*enouvellement de mobile"},
            {send, menu_link_ODR(DCL)},
            {expect, "NOUVEAU : avec mobicarte, changez de mobile sans changer de numero et beneficiez de 15 euros de credit offert pour tout rechargement..*Infos en point de vente."}
           ]}]++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
        [].

test_nouv_rech_edit_spec(DCL) ->
    init_test(DCL)++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Les Recharge Edition Specialee ####</center>"},
         "Test Menu Nouveautes - Les Recharge Edition Speciale - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, ".echarges Edition Speciale"},
            {send, menu_link_rech_edition_special(DCL)},
            {expect, "A partir de 10E, profitez de SMS, MMS et Orange Messenger en illimite de 21h a minuit avec les recharges EDITION SPECIALE du moment..*1:Recharger"},
            {send, "1"},
	    {expect, ".*"}
	   ]}]++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
        [].
test_nouv_jeu_recharge(DCL) ->
    init_test(DCL)++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "cible") ++
        [{title, "<center>#### Test Nouveautes - Jeu au rechargement ####</center>"},
         "Test Menu Nouveautes - Jeu au rechargement - DCL="++integer_to_list(DCL),
         {ussd2,
          [ {send, code_nouveautes(DCL)},
            {expect, "....eu au rechargement"},
            {send, menu_link_jeu_rech(DCL)},
            {expect, "Rechargez, jouez, gagnez. Participez au jeu Disneyland Paris et tentez de remporter, suite a votre rechargement, 1 sejour aux Parcs Disney.*1:Recharger.*"},
            {send, "1"},
            {expect, ".*"}
           ]}]++
        test_util_of:set_parameter_for_test(type_decouvrir_bonus, "non") ++
        [].

get_dyn_links_nouv(DCL) ->
    case DCL of
	X when X==?mobi;
	       X==?mobi_new;X==?cpdeg ->
	    [?recharger,?suivi_conso_plus_menu, ?mobi_bonus];
	?DCLNUM_ADFUNDED->
	    [?recharger,?suivi_conso_plus_menu];
	?mobi_janus->
	    [?recharger,?suivi_conso_plus_menu, ?mobi_bonus];
	?B_phone->
	    [?recharger,?suivi_conso_plus_menu, ?mobi_bonus];
	?m6_prepaid ->
	    [?recharger,?suivi_conso_plus_menu];
	?click_mobi ->
	    [?recharger,?suivi_conso_plus_menu,?click_bonus];
	?OL_mobile ->
	    [?recharger,?suivi_conso_plus_menu, ?foot_variable_x, ?foot_variable_y]
    end.

menu_link_nouveautes(DCL)->
    Dyn_links = get_dyn_links_nouv(DCL),
    test_util_of:link_rank(parent(?nouveautes), ?menu_page, ?nouveautes, Dyn_links).

code_nouveautes(DCL)->
    Dyn_links = get_dyn_links_nouv(DCL),
    test_util_of:access_code(parent(?nouveautes), ?nouveautes, Dyn_links).

get_dyn_for_menu_mouv(DCL) ->
    case DCL of
	X when X==?mobi; X==?mobi_janus; X==?B_phone->
	    [les_bonus, jeu_recharge,rech_edit_spec, avantage_zap_zone, internet_mobile, offre_renouv_mobile];
	?click_mobi ->
	    [jeu_recharge, rech_edit_spec, decouvrir_bonus_click,avantage_zap_zone, internet_mobile, offre_renouv_mobile];
	?m6_prepaid ->
	    [rech_edit_spec_m6, internet_mobile, offre_renouv_mobile, opt_orange_foot];
	?OL_mobile ->
	    [orange_foot, internet_mobile, rech_edit_spec, zap_zone_30sms, avantage_zap_zone];
	?DCLNUM_ADFUNDED ->
	    [rech_edit_spec, jeu_recharge]
    end.


menu_link_internet_mobile(DCL)->
    case DCL of
        X when X==?mobi;X==?mobi_janus;X==?mobi_new;X==?B_phone;X==?click_mobi->"7";
	?m6_prepaid->"6";
	?OL_mobile->"5";
        _->"4"
    end.

menu_link_ODR(DCL)->
    case DCL of
        X when X==?mobi;X==?mobi_janus;X==?mobi_new;X==?B_phone;X==?click_mobi->"6";
        _->"5"
    end.

menu_link_jkdo_mms(DCL)->
    Dyn_links = get_dyn_for_menu_mouv(DCL),
    test_util_of:link_rank(?MODULE, ?nouveautes, journee_kdo_mms, Dyn_links).

menu_link_rech_edition_special(DCL)->
    case DCL of
        X when X==?mobi;X==?mobi_janus;X==?OL_mobile;X==?mobi_new;X==?B_phone;X==?m6_prepaid->"2";
        ?DCLNUM_ADFUNDED->"1";
        _->"2"
    end.

menu_link_jeu_rech(DCL)->
    Dyn_links = get_dyn_for_menu_mouv(DCL),
    test_util_of:link_rank(?MODULE, ?nouveautes, jeu_recharge, Dyn_links).

menu_link_zap_zone_30_SMS(DCL)->
    Dyn_links = get_dyn_for_menu_mouv(DCL),
    test_util_of:link_rank(?MODULE, ?nouveautes, zap_zone_30sms, Dyn_links).

code_nuit_kdo_mms(DCL)
  when (DCL==?DCLNUM_ADFUNDED)->
    "2";
code_nuit_kdo_mms(DCL)->
    "3".
code_journee_kdo_sms(DCL)
  when (DCL==?DCLNUM_ADFUNDED)->
    "3";
code_journee_kdo_sms(DCL) ->
    "4".

menu_nouveautes(DCL) ->
    case DCL of
        X when X==?mobi;X==?cpdeg;
	       X==?mobi_new;X==?mobi_janus;X==?B_phone->
	    "1:Les Bonus.*"
		"2:Recharges Edition Speciale.*"
		"3:Nuit Kdo du 21/06.*"
		"4:Journee Kdo du 14/07.*"
		"5:Decouverte Zap zone.*"
		"6:Renouvellement de mobile.*"
		"7:Internet mobile.*";
	?m6_prepaid ->
            "1:Option Sport.*"
		"2:Recharges Edition Speciale.*"
                "3:Nuit Kdo du 21/06.*"
                "4:Journee Kdo du 14 juillet.*"
		"5:Offre de renouvellement de mobile.*"
		"6:Internet mobile.*";
        ?click_mobi ->
		"1:Les bonus.*"
		"2:Recharges Edition Speciale.*"
                "3:Nuit Kdo du 21/06.*"
                "4:Journee Kdo du 14/07.*"
		"5:Decouverte Zap zone.*"
		"6:Renouvellement de mobile.*"
		"7:Internet mobile.*";
        ?OL_mobile ->
            "1:Option Sport.*"
		"2:Recharges Edition Speciale.*"
                "3:Nuit Kdo du 21/06.*"
                "4:Journee Kdo du 14/07.*"
		"5:Internet mobile.*"
    end.
init_test(DCL)->
    profile_manager:create_default(?Uid,"mobi")++
	profile_manager:init(?Uid)++
        profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:set_list_comptes(?Uid,[])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[#option{top_num=0}]).
