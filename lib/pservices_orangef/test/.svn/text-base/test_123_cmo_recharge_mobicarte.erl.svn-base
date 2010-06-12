-module(test_123_cmo_recharge_mobicarte).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").

-define(Uid,cmo_rechaging_mobicarte_user).

-define(code,"#124*").
-define(code_menu,"#123*1").
-define(niv1,"100007XXXXXXX1").
-define(niv2,"100006XXXXXXX2").
-define(niv3,"100005XXXXXXX3").


-define(code_self_cmo,"#123*111").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online()->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()).

test()->
	test_util_of:set_present_period_for_test(commercial_date_cmo,rech_cb) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,appelle_moi) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,rech_pour_moi) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,cmo_tlr) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,recharge_cg) ++
	
  	recharge_cmo_mobicarte()++
	test_error_recharge([
 			 {error_cls_bad_code, "Error Sachem: statut 00 with ETT_NUM = 3, 5, 6, 7, 8"},
 			 {error_cls_tck_deja, "Error Sachem: statut 00 with ETT_NUM = 4"},
 			 {carte_perimee_tr_promo, "Error sachem -57"},
 			 {incident_technique, "Error sachem -99"},
 			 {autres_erreurs_recharge,"Error sachem -62"},
 			 {format_requete_incorrect,"Error sachem -98"},
 			 {ticket_recharge_invalide,"Error sachem -56"},
 			 {ticket_recharge_inconnu,"Error sachem -55"},
 			 {dossier_inaccessible,"Error sachem -78"},
			 {incompatible_offre,"Error sachem -63"},
			 {erreur_options,"Error sachem -86"},
			 {erreur_promo,"Error sachem -87"}
			])++

 	recharge_cmo_pour_moi()++
 	recharge_cmo_appelle_moi()++
	[].

recharge_cmo_mobicarte() ->
    recharge_normal()++
	recharge_sl_out_commercial_date([183,184,185])++
 	recharge_sl([183,184,185])++
	["Test reussi"].

recharge_cmo_pour_moi() ->
    init()++
	[{title, "Test Rechargement CMO - pour moi"},
	 "Menu recharge pour moi",
	 {ussd2,
	  [ 
	    {send, "#123*1*1"},
	    {expect, "Rechargement.*1:Par recharge Mobicarte.*2:Par carte bancaire.*3:Par prelevement sur compte bancaire.*4:Recharge pour moi.*5:Appelle-moi \\(pour etre toujours joint\\)"},
	    {send, "4"},
	    {expect,"Recharge pour moi.*"
	     "5 messages gratuits.mois pour demander a un proche de recharger votre compte mobile.*"
	     "Tapez .126.XXXXXXXXXX.*"}
	   ]}
	]++
	test_util_of:close_session().

recharge_cmo_appelle_moi() ->
    init()++
	[{title, "Test Rechargement CMO - appelle-moi"},
	 "Menu recharge appelle-moi",
	 {ussd2,
	  [ {send, "#123*1*1*5#"},
	    {expect,"Appelle-moi.*"
	     "10 messages gratuits pour demander a etre rappele des que votre compte \\<1euro.*"
	     "Tapez .122.XXXXXXXXXX.*"}
	   ]},
	 "Test reussi"
	]++
	test_util_of:close_session().


serie_limite_20E(Choice,Confirm_Msg,Valid_Msg)->
    [{title, "TEST RECHARGEMENT : Rechargement Serie limite 20E"},
     {ussd2,
      [ {send, "#123*1*1*1*1*12345678912311#"},
        {expect,"Votre compte mobile a bien ete recharge de 20 E.*"
         "1:TV illimitee.*"
         "2:SMS illimites.*"
         "3:Appels illimites vers Orange.*"
         "4:.d'infos"},
        {send,Choice},
        {expect,Confirm_Msg},
        {send,"1"},
        {expect,Valid_Msg}]}].

recharge_normal() ->
    init()++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1,montant=21000},#account{tcp_num=?C_ASMS,montant=50,unit=?SMS}]})++
	[{title, "TEST RECHARGEMENT - Cas classique"},
	 "Test 100% SMS",
	 {ussd2,
	  [ 
	    {send, "#123*1*1*1*12345678912302#"},
	    {expect,
	     "Votre rechargement de .* Euros a reussi.*"
	     "Solde Compte Mobile : .* EUR.*"
	     "Compte SMS : .* SMS.*"
	     "A utiliser avant le ../../..*"
	     "1:Decouvrir options et bons plans.*"},
	    {send, "1"},
            {expect, "L'offre Orange .*"}
	   ]}]++
	test_util_of:close_session().

recharge_sl_out_commercial_date([]) -> [];
recharge_sl_out_commercial_date([Choice|T]) ->
    init()++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=Choice,
								  ctk_num=35,
								  accounts=[#account{tcp_num=1,
										     montant=10000*(Choice-182),
										     dlv=pbutil:unixtime()}]
								 })++

 	test_util_of:set_past_period_for_test(commercial_date_cmo,recharge_sl_cmo) ++
 	[{title, "TEST RECHARGEMENT - Special Edition Limitee "++ recharge_amount(Choice) ++ " - Out of commercial date"},
	 {ussd2,
	  [ {send, "#123*1*1"},
	    {expect,"Rechargement.*"},
	    {send,"1"},
	    {expect,"Saisissez les 14 chiffres.*"},
	    {send,"12345678912354"},
	    {expect,"Rechargement reussi.*Votre compte mobile a bien ete recharge de .* Euros.*Le nouveau solde de votre compte mobile est de .* Euros.*"
	     "1:Decouvrir options et bons plans"}
	   ]}]++
	test_util_of:set_present_period_for_test(commercial_date_cmo,recharge_sl_cmo)++
	test_util_of:close_session()++
	recharge_sl_out_commercial_date(T).

recharge_sl([]) -> [];
recharge_sl([Choice|T]) ->
    init()++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=Choice,
								  ctk_num=35,
								  accounts=[#account{tcp_num=1,
										     montant=10000*(Choice-182),
										     dlv=pbutil:unixtime()}]
								 })++
	[{title, "TEST RECHARGEMENT - Special Edition Limitee - Success"},
	 {ussd2,
	  [ {send, "#123*1*1"},
	    {expect,"Rechargement.*"},
	    {send,"1"},
	    {expect,"Saisissez les 14 chiffres.*"},
	    {send,"12345678912354"},
	    {expect,"Rechargement reussi. Votre compte mobile a bien ete recharge de "++ recharge_amount(Choice) ++". Le nouveau solde de votre compte mobile est de .* euros. Profitez en plus de ..."},
	    {send, "1"},
	    {expect, "...SMS, MMS et d'Orange Messenger en illimite de 21h a minuit jusqu'au .* en France metropolitaine.*"},
	    {send, "1"},
	    {expect,"Telecharger gratuitement Orange Messenger sur http://im.orange.fr et profitez de messages instantanes illimites de 21h a minuit jusqu'au .*"}
	   ]}]++
	test_util_of:close_session()++
	recharge_sl(T).

test_error_recharge([]) -> [];
test_error_recharge([{Error, Text}|T]) ->
    init_error(Error)++
 	[{title, "TEST RECHARGEMENT ERROR : " ++ Text},
 	 {ussd2,
 	  [
 	    {send, "#123*1*1*1*12345678912345#"},
 	    {expect,expect_error(Error)}
	  ]}]++

	test_util_of:close_session()++
	test_error_recharge(T).


prisme_counters() ->
    [{"CM","PRETLRSL", 1},
     {"CM","PRECTRSL", 1},
     {"CM","PRECTR", 1},
     {"CM","PRCBSL", 1}
    ].

recharge_amount(Choice)->
    case Choice of
	183 ->
	    "10 euros";  
	184 ->
	    "20 euros";
	_ ->
	    "30 euros"
    end.

init() ->
    profile_manager:create_default(?Uid,"cmo")++
	profile_manager:init(?Uid)++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=10000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=143}])++
	profile_manager:set_dcl(?Uid,56).

init_error(Error) ->
    init()++
	case Error of
	    error_cls_bad_code ->
		profile_manager:update_sachem(?Uid,"csl_tck",[{"TTK_NUM","300"},
							  {"ETT_NUM","3"}]);
	    error_cls_tck_deja ->
		profile_manager:update_sachem(?Uid,"csl_tck",[{"TTK_NUM","300"},
							      {"ETT_NUM","4"}]);
	    _ ->
		profile_manager:set_sachem_response(?Uid,{?rec_tck,{nok, atom_to_list(Error)}})
	end.

expect_error(Error) ->
    case Error of
	carte_perimee_tr_promo ->
	    "Erreur.*Pour activer cette recharge promo, vous devez avoir du credit sur votre compte rechargeable.*"
		"Nous vous invitons a le recharger prealablement.*1:Menu recharger";
	E1 when E1==incident_technique;E1==autres_erreurs_recharge ->
	    "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*"
		"Nous vous invitons a reessayer plus tard.";
	format_requete_incorrect ->
	    "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*"
		"Pour recharger, nous vous invitons a appeler gratuitement le 740.";
	E2 when E2==error_cls_bad_code;E2==ticket_recharge_invalide ->
	    "Erreur.*Votre ticket n'est pas valide. Pour plus d'informations, veuillez appeler le 700 \\(prix com nat\\).";
	error_cls_tck_deja ->
	    "Erreur.*Votre ticket a deja ete utilise.*"
		"Vous pouvez recharger par carte bancaire, si vous le souhaitez en repondant 1.*1:Recharger";
	E3 when E3==ticket_recharge_inconnu;E3==dossier_inaccessible ->
	    "Erreur.*Rechargement refuse car les caracteres saisis ne sont pas corrects. Veuillez verifier les chiffres et les composer a nouveau. Merci.*"
		"1:Reessayer";
	E4 when E4==incompatible_offre;E4==erreur_options;E4==erreur_promo ->
	    "Erreur.*Rechargement refuse car le ticket utilise n'est pas compatible avec votre offre.*"
		"Merci d'appeler le 700 \\(prix com nat\\) pour plus d'infos, ou...*1:Suite";
	_ ->
	    ""
    end.
