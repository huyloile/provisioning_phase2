-module(test_123_cmo_recharge_prelevement).
-export([run/0,
	 online/0,
         pages/0,
         parent/1,
         links/1]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(Uid,cmo_recharge_prev_user).

-define(closed,"#128*13#").
-define(imsi_rcod_2,      "999000901000002").
-define(imsi_rcod_1,      "999000901000003").
-define(imsi_inhibe,      "999000901000004").
-define(imsi_ecrase,      "999000901000005").
-define(imsi_cc,          "999000901000006").
-define(imsi_rcod_sda,    "999000901000007").
-define(imsi_rcod_inconnu,"999000901000008"). %% erreur 152
-define(imsi_rcod_cbhttp_error,"999000901000009").
-define(imsi_vcod_inconnu,"999000901000011").
-define(imsi_vcod_inhib,  "999000901000012").
-define(imsi_vcod_ecrase, "999000901000013").
-define(imsi_vcod_cc,     "999000901000014").
-define(imsi_mcod_inconnu,"999000901000020").
-define(imsi_ok_cc,       "999000901000061").
-define(imsi_erreur_401,  "999000901000062").
-define(imsi_erreur_499,  "999000901000063").
-define(imsi_plafond,     "999000901000064").

-define(PB_TECHNIQUE, "Le service est momentanement interrompu. Veuillez recommencer ulterieurement.").
-define(SDA_ERROR, "Suite a un incident technique veuillez renouveler votre demande de rechargement").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?recharger].

parent(?recharger) ->
    test_123_cmo_Homepage.

links(?recharger) ->
    [{recharger_mobicarte, static},
     {recharger_cb,        static},
     {prelevement_cb,      static},
     {recharge_moi,        static},
     {appelle_moi,         static}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    %% test cle de lutn
    true=svc_recharge_cb_cmo:is_cle_luhn("4973019746587653"),
    true=svc_recharge_cb_cmo:is_cle_luhn("5132760007368516"),
    true=svc_recharge_cb_cmo:is_cle_luhn("4974991547039275"),
    false=svc_recharge_cb_cmo:is_cle_luhn("4974991547039276"),
    ok.

online()->
    test_util_of:online(?MODULE,recharge_cb()).

recharge_cb() ->
    [{title, "Test rechargement Prelevement pour CMO"}] ++
	test_util_of:set_parameter_for_test(dmd_cvx2_avt_versement,false) ++
	test_util_of:set_parameter_for_test(debrayage_vco_mco_actif,false) ++
	test_util_of:set_parameter_for_test(verif_cc_cvx2,false) ++
        test_util_of:set_present_period_for_test(commercial_date_cmo,rech_cb) ++
        test_util_of:set_present_period_for_test(commercial_date_cmo,appelle_moi) ++
        test_util_of:set_present_period_for_test(commercial_date_cmo,rech_pour_moi) ++
        test_util_of:set_present_period_for_test(commercial_date_cmo,cmo_tlr) ++
        test_util_of:set_present_period_for_test(commercial_date_cmo,recharge_cg)++

	profile_manager:create_default(?Uid,"cmo")++
	profile_manager:init(?Uid,smpp)++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=113}])++
	profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_CB}) ++


	test_prelevement_cmo()++ 

	["Test reussi"] ++

        [].

test_prelevement_cmo()->
     cas_classique_prelevement() ++
	lists:append([test_prelevement_rech_edition_special({Test, Amount}) || {Test, Amount} <- [{"7 jours", 10}, {"31 jrs", 20}, {"45 jrs", 30}]])++
	cas_classique_prelevement_erreur_3_saisie()++
	[].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cas_classique_prelevement()->
    [
     {title, "Test Rechargement Prelevement OK"},
     "Test rechargement par Code Court",
     {ussd2,
      [ {send, test_util_of:access_code(parent(?recharger), ?recharger)},
	{expect, "3:Par prelevement sur compte bancaire"},
	{send, test_util_of:link_rank(?MODULE, ?recharger, prelevement_cb)},
	{expect,"code confidentiel"},
	{send,"1234"},
	{expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
	 "Sinon, tapez un montant libre entre 8 et 80 euros et validez..*"},
	{send,"9"},
	{expect,"Rechargement reussi"},
        {send, "1"}, 
        {expect, "Tentez de remporter 1 sejour aux parcs Disney, l'un des 100 mobiles W595 ou encore l'un des 100000 bons plans en jeu!.*1:Je participe.*2:Les dotations.*3:Reglement"}
       ]}]++
	test_util_of:close_session().

test_prelevement_rech_edition_special({Test, Amount}) ->
    profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
						   unt_num=?EURO,
						   cpp_solde=15000 + (Amount*1000),
						   dlv=pbutil:unixtime(),
						   rnv=0,
						   etat=?CETAT_AC,
						   ptf_num=113}])++
    [
     {title, "Test Rechargement Prelevement OK"},
     "Test rechargement rech edition special " ++ integer_to_list(Amount) ++ "Euros",
     {ussd2,
      [ {send, test_util_of:access_code(parent(?recharger), ?recharger)},
	{expect, "3:Par prelevement sur compte bancaire"},
	{send, test_util_of:link_rank(?MODULE, ?recharger, prelevement_cb)},
	{expect,"code confidentiel"},
	{send,"1234"},
	{expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
	 "Sinon, tapez un montant libre entre 8 et 80 euros et validez..*"},
	{send,"1"},
	{expect,"Profitez de SMS, MMS et Orange Messenger by Windows Live en illimite de 21h a minuit avec les recharges EDITION SPECIALE du moment:.*"},
	case Amount of
	    10 ->
		{send,"1"};
	    20 ->
		{send,"2"};
	    _->
		{send,"3"}
	end,
	{expect,"Vous souhaitez recharger " ++integer_to_list(Amount)++ "E de credit \\+ SMS, MMS et Orange Messenger en illimite de 21h a minuit pendant " ++ Test ++ " en France metro.*"},
 	{send, "1"},
	{expect, "Rechargement reussi.*"},
	{send, "1"},
	{expect, "...SMS, MMS et d'Orange Messenger en illimite de 21h a minuit jusqu'au .* en France metropolitaine..*"
	 "1:Suite"},
	{send, "1"},
	{expect, "Telecharger gratuitement Orange Messenger sur http://im.orange.fr et profitez de messages instantanes .*"}	
       ]}]++
	test_util_of:close_session().

cas_classique_prelevement_erreur_3_saisie()->
    [
     {title, "Test Rechargement Prelevement Erreur 3 saisie"},
     "Test rechargement par Code Court",
     {ussd2,
      [ {send, test_util_of:access_code(parent(?recharger), ?recharger)},
        {expect, "3:Par prelevement sur compte bancaire"},
        {send, test_util_of:link_rank(?MODULE, ?recharger, prelevement_cb)},
        {expect,"code confidentiel"},
        {send,"1234"},
	{expect, "Pour decouvrir les recharges EDITION SPECIALE du moment"},
        {send,"7"}, 
        {expect,"au minimum de"},
        {send,"3"},
        {expect,"au minimum de"},
        {send,"4"},
        {expect,"Apres 3 erreurs dans votre saisie, nous vous conseillons .*"}
       ]}]++
	test_util_of:close_session().

