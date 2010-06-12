-module(test_123_mobi_recharge_cb).
-export([run/0, online/0, assert_received/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").


-define(code_rech,"#123*1").
-define(code_1er,"#123*1*2*1").
-define(code_2eme,"#123*1*2*2*1").

-define(back,"8").
-define(menu,"9").

-define(uid, recharge_mobi_cb).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online()->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,recharge_cb()),
    test_util_of:test_kenobi(prisme_counters()).

recharge_cb() ->
    [{title, "Test rechargement CB et TLR pour MOBICARTE"}] ++
	test_util_of:set_parameter_for_test(pfront_orangef,des3_encryption_keys,["lib/pfront_orangef/test/keys/key.cipher"])++
	profile_manager:rpc_for_test(crypto, start, [])++

	test_menu_recharge() ++
	test_menu_recharge_cb()++
	test_error_access_recharge_cb()++
	test_saisie_montant()++
	test_1er_rechargement()++
	test_2eme_rechargement()++
	test_rechgt_serie_limitee() ++
 	test_errors_mobi_recharge_cb([
				      {paiement_refuse,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (other code)"},
				      {paiement_refuse_14,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (code :14)"},
				      {paiement_refuse_40,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (code :40)"},
				      {paiement_refuse_44,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (code :44)"},
				      {paiement_refuse_45,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (code :45)"},
				      {donnee_invalid,"DoRechargementCB - ExceptionDonneesInvalides"},
				      {error_rech_fonc,"DorechargementCB - EcareExceptionFonctionnelle"},
				      {error_rech_tech,"DoRechargementCB - EcareExceptionTechnique"}
				     ])++

	profile_manager:rpc_for_test(crypto, stop, [])++
	["Test reussi"].

init()->
    profile_manager:create_default(?uid, "mobi")++
	profile_manager:set_list_comptes(?uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	profile_manager:set_bundles(?uid,[])++
	profile_manager:init(?uid).

change_param(PARAM,VALUE)->
    test_util_of:set_parameter_for_test(PARAM, VALUE).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_menu_recharge()->
    init()++
	[
	 {title, "MOBI Test Menu Rechargement"},
	 {ussd2,
	  [ {send, ?code_rech},
	    {expect, "1:par recharge mobicarte.2:par carte bancaire.3:Recharge pour moi.*4:Appelle.moi"},
	    {send, "3"},
	    {expect, "Recharge pour moi 5 messages gratuits"},
	    {send, "8"},
	    {expect, "1:par recharge mobicarte.2:par carte bancaire.3:Recharge pour moi.*4:Appelle-moi"},
	    {send, "4"},
	    {expect, "Appelle-moi.*10 messages gratuits pour demander.*1euro.*"}
	   ]}
	]++
	test_util_of:close_session().

test_menu_recharge_cb()->
    init()++
     	[{title, "MOBI Test Menu Recharge CB"},
     	 {ussd2,
     	  [ {send, ?code_rech++"2"},
     	    {expect,"Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge :"
     	     ".1:EDITION SPECIALE"
     	     ".2:5 EUR"
     	     ".3:10 EUR"
     	     ".4:15 EUR"
     	     ".5:Suite"}
     	   ]}
     	]++
     	test_util_of:close_session().

test_error_access_recharge_cb() ->
    test_error_access_recharge_cb([
				   {dossier_incorrect,"isrechargeableCB - ExceptionEtatDossierIncorrect"},
				   {option_interdite,"isrechargeableCB - ExceptionOptionInterdite"},
				   {no_msisdn,"getIdentification - no MSISDN"},
				   {error_fonc,"isrechargeableCB - EcareExceptionFonctionnelle"},
				   {error_tech,"isrechargeableCB - EcareExceptionTechnique"}
				  ])++
	test_janus_not_allowed_recharge_cb().


test_error_access_recharge_cb([]) -> [];
test_error_access_recharge_cb([{Error,Text}|T]) ->
    init_error(Error)++
        [
         {title, "MOBI Test Error Access Rechargement CB - ERROR : "++Text},
         {ussd2,
          [
	   {send, ?code_rech++"2"},
	   {expect, expect_error(Error)}
	  ]
	 }]++
	test_util_of:close_session()++
	test_error_access_recharge_cb(T).

test_janus_not_allowed_recharge_cb() ->
    profile_manager:create_default(?uid, "mobi")++
	profile_manager:set_dcl(?uid, ?mobi_janus)++
	profile_manager:set_list_comptes(?uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	profile_manager:set_bundles(?uid,[])++
	profile_manager:update_user_state(?uid,{etats_sec,?SETAT_LS})++
	profile_manager:init(?uid)++
	[
         {title, "MOBI Test Error Access Rechargement CB - ERROR : \'Etat secondaire control\': JANUS not identified, \'Libre Service\'"},
         {ussd2,
          [
	   {send, ?code_rech++"2"},
           {expect, expect_error(not_allowed)}
          ]
         }]++
	test_util_of:close_session().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_saisie_montant()->
    init()++
	%% 1-sans controle de plafond
	%% test pas de limitation dans la liste des montants
	%% test retour changement de montant ok
	%% test =/= montant et bonus associe
	%% 2-controle plafond
	%% test limitation dans la liste des montants
	profile_manager:set_list_comptes(?uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	[ {title, "Test Menu Choix du Montant"},
	  "Cas classique: saisie differents montant + verification bonus",
	  {ussd2,
	   [ {send, "#123*1*2"},
	     {expect,"Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge :.*5 EUR.*10 EUR.*15 EUR.*Suite"},
	     {send,"2"},
	     {expect,"5 euros.*"},
	     {send,?back},
	     {expect,"Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge :.*5 EUR.*10 EUR.*15 EUR.*Suite"},
	     {send,"3"},
	     {expect,"10 euros.*"},
	     {send,?back},
	     {expect,"Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge :.*5 EUR.*10 EUR.*15 EUR.*Suite"},
	     {send,"4"},
	     {expect,"15 euros .*"},
	     {send,?back},
	     {expect,"Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge :.*5 EUR.*10 EUR.*15 EUR.*Suite"},
	     {send, "5"},
	     {expect,"Choisissez le montant de votre rechargement :.*25 EUR.*35 EUR.*50 EUR.*75 EUR.*100 EUR"},
	     {send,"1"},
	     {expect,"25 euros . 5 euros.*"},
	     {send,?back},
	     {expect,"Choisissez le montant de votre rechargement :.*25 EUR.*35 EUR.*50 EUR.*75 EUR.*100 EUR"},
	     {send,"2"}, 
	     {expect,"35 euros . 10 euros.*"},
	     {send,?back},
	     {expect,"Choisissez le montant de votre rechargement :.*25 EUR.*35 EUR.*50 EUR.*75 EUR.*100 EUR"},
	     {send,"3"}, 
	     {expect,"50 euros . 15 euros.*"},
	     {send,?back},
	     {expect,"Choisissez le montant de votre rechargement :.*25 EUR.*35 EUR.*50 EUR.*75 EUR.*100 EUR"},
	     {send,"4"}, 
	     {expect,"75 euros . 25 euros.*"},
	     {send,?back},
	     {expect,"Choisissez le montant de votre rechargement :.*25 EUR.*35 EUR.*50 EUR.*75 EUR.*100 EUR"},
	     {send,"5"},
	     {expect,"100 euros . 50 euros.*"}
	    ]}
	 ].

test_1er_rechargement()->
    init()++
	profile_manager:set_list_comptes(?uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	[{title, "Test 1er rechargement"},
	 %% test saisie CB
	 %% CB longuer =/=16
	 %% CB avec lettre
	 %% CB non luhn
	 %% verif fin de saisie apres la troisieme tentative
	 "Saisie differents no CB",
	 {ussd2,
	  [ {send, ?code_1er++"21#"},
	    {expect,"Veuillez saisir les 16 chiffres de votre carte bancaire pour "
	     "confirmer votre versement et accepter les conditions du service illico.*"
	     "1:conditions.*"},
	    {send,"1"},
	    {expect,"Service dispo pour les clients mobicarte ayant au moins 1 mois "
	     "d'anciennete. 10 rechargements max sur 4 comptes et plafond 150E sur 30j glissants.*"
	     "1:Suite.*"},
	    {send,"1"},
	    {expect,"Vos coordonnees bancaires seront conservees pour vos futurs rechargements. "
	     "Vous n'aurez plus qu'a saisir les 3 derniers chiffres au dos de votre CB.*"},
	    {send,"8*8"},
	    {expect,"Veuillez saisir les 16 chiffres"},
	    {send,"123456"},
	    {expect,"Les informations saisies sont incorrectes.*"
	     "Veuillez saisir les 16 chiffres"},
	    {send,"123456a146789456"},
	    {expect,"Les informations saisies sont incorrectes.*"
	     "Veuillez saisir les 16 chiffres"},
	    {send,"4974991547039276"},
	    {expect,"Informations saisies invalides.*"}]}]++
	test_util_of:close_session()++

	[
	 %% testr saisie date
	 %% date inf date du jour
	 %% date fictive Mois> 12
	 %% date fictive Mois<1
	 %% verif fin de saisie apres la troisieme tentative
	 "Saisie differents Date de validite",
	 {ussd2,
	  [ {send, ?code_1er++"21#"},
	    {expect,"Veuillez saisir les 16 chiffres"},
	    {send,"4973019746587653"},
	    {expect,"Veuillez saisir les 4 chiffres de la date de validite"},
	    {send,"0804"},
	    {expect,"Les informations saisies sont incorrectes. "
	     "Veuillez saisir les 4 chiffres de la date"},
	    {send,"1304"},
	    {expect,"Les informations saisies sont incorrectes. "
	     "Veuillez saisir les 4 chiffres de la date"},
	    {send,"0004"},
	    {expect,"La date saisie n'est pas valide.*"}
	   ]}]++
	test_util_of:close_session()++

	[
	 %% test sasie cvx2
	 %% cvx2 length =/=3
	 %% saisie avec lette
	 %% saisie vide
	 %% verif fin de saisie apres la 3eme tentative
	 "Saisie differents CVX2",
	 {ussd2,
	  [ {send, ?code_1er++"21#"},
	    {expect,"Veuillez saisir les 16 chiffres"},
	    {send,"4973019746587653"},
	    {expect,"Veuillez saisir les 4 chiffres de la date de validite"},
	    {send,"1210"},
	    {expect,"Veuillez saisir les 3 derniers chiffres au dos de"},
	    {send,"abc"},
	    {expect,"Les informations saisies sont incorrectes. "
	     "Veuillez saisir les 3 derniers chiffres"},
	    {send,"1234"},
	    {expect,"Les informations saisies sont incorrectes. "
	     "Veuillez saisir les 3 derniers chiffres"},
	    {send,"1a"},
	    {expect,"Le code saisi n'est pas valide.*"}
	   ]}]++
	test_util_of:close_session()++

	[
	 %%test rechargement ok + messsage information
	 "Verif Message d'information",
	 {ussd2,
	  [ {send, "#123*1*2"},
	    {expect,"Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge :.*5 EUR.*10 EUR.*15 EUR.*Suite"},
	    {send, "2"}, 
	    {expect, "5 euros"},
	    {send, "1"},
	    {expect,"Veuillez saisir les 16 chiffres"},
	    {send,"4973019746587653"},
	    {expect,"Veuillez saisir les 4 chiffres de la date de validite"},
	    {send,"1210"},
	    {expect,"Veuillez saisir les 3 derniers chiffres au dos de"}]}]++
	profile_manager:set_list_comptes(?uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=20000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	[{ussd2,
	  [ {send, "#123#"},
	    {send,"123"},
	    {expect, "Vous avez recharge votre compte.*"}
	   ]}
	].

test_2eme_rechargement()->
    init()++
	%% test sasie cvx2+
	%% cvx2 length =/=3
	%% saisie avec lette
	%% saisie vide
	%% verif fin de saisie apres la 3eme tentative    
	profile_manager:set_list_comptes(?uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	profile_manager:update_user_state(?uid,{etats_sec,?SETAT_CB})++
	[{title, "Test autre rechargement"},
	 "Saisie differents no CVX2",
	 {ussd2,
	  [ 
	    {send, ?code_2eme},
	    {expect,"Veuillez saisir les 3 derniers chiffres au dos de.*"
	     "les 16 chiffres de votre nouvelle CB"},
	    {send,"12"},
	    {expect,"Les informations saisies sont incorrectes.*3 derniers chiffres.*16 chiffres"},
	    {send,"abs"},
	    {expect,"Les informations saisies sont incorrectes.*3 derniers chiffres.*16 chiffres"},
	    {send,"1ab"},
	    {expect,"Vous avez fait 3 erreurs dans les informations saisies.*Pour recharger, RDV dans votre point de vente habituel.*"}	 
	   ]},
	 %% test saisie cvx2 ko
	 %% saisie CB ok
	 %% rechargement ok
	 "Saisie CVX2 KO puis CB OK",
	 {ussd2,
	  [
	   {send, ?code_2eme},
	   {expect,"Veuillez saisir les 3 derniers chiffres au dos de.*"
	    "les 16 chiffres de votre nouvelle CB"},
	   {send,"12"},
	   {expect,"Les informations saisies sont incorrectes.*3 derniers chiffres.*16 chiffres"},
	   {send,"4973019746587653"},
	   {expect,"Veuillez saisir les 4 chiffres de la date de validite"},
	   {send,"1210"},
	   {expect,"Veuillez saisir les 3 derniers chiffres au dos"},
	   {send,"123"},
	   {expect, "Vous avez recharge votre compte de.*"}
	  ]},
	 %% test saisie CB
	 %% CB longuer =/=16
	 %% CB avec lettre
	 %% CB non luhn
	 %% verif fin de saisie apres la troisieme tentative
	 {ussd2,
	  [
	   {send,?code_2eme},
	   {expect,"16 chiffres"},
	   {send,"123456"},
	   {expect,"Les informations saisies sont incorrectes.*"
	    "16 chiffres"},
	   {send,"123456a146789456"},
	   {expect,"Les informations saisies sont incorrectes.*"
	    "16 chiffres"},
	   {send,"4974991547039276"},
	   {expect,"Vous avez fait 3 erreurs dans les informations saisies.*Pour recharger, RDV dans votre point de vente habituel.*"}]},
	 %% test rechargement ok CVX2
	 "Saisie CVX2 OK Rech OK",
	 {ussd2,
	  [
	   {send,?code_2eme},
	   {expect,"Veuillez saisir les 3 derniers chiffres au dos.*"
	    "les 16 chiffres de votre nouvelle CB"},
	   {send,"123"},
	   {expect, "Vous avez recharge votre compte de.*" }
	  ]}
	].

test_rechgt_serie_limitee() ->
    init()++
	test_link_recharge_edition_speciale()++
	test_recharge_SL([
			  {"1","10","10E"},
			  {"2","20","20E"},
			  {"3","30","30E"}
			 ]).

test_link_recharge_edition_speciale() ->
    test_util_of:set_past_period_for_test(commercial_date,[recharge_sl_mobi]) ++

	[{title, "TEST RECHARGEMENT SERIE LIMITEE - NO LINK EDITION SPECIALE"},
	 {ussd2,
	  [ {send, ?code_rech},
	    {expect, "1:par recharge mobicarte.2:par carte bancaire"},
	    {send, "2"},
	    {expect,"Bienvenue sur le service de rechargement illico par CB. "
	     "Choisissez votre recharge :.*"
	     "1:5 EUR.*"
	     "2:10 EUR.*"
	     "3:15 EUR.*"
	     "4:Suite.*"}]}]++

	test_util_of:set_present_period_for_test(commercial_date,[recharge_sl_mobi]) ++
	[{title, "TEST RECHARGEMENT EDITIONS SPECIALES - WITH LINK EDITION SPECIALE"},
	 {ussd2,
	  [ {send, ?code_rech},
	    {expect, "1:par recharge mobicarte.2:par carte bancaire"},
	    {send, "2"},
	    {expect,"Bienvenue sur le service de rechargement illico par CB. "
	     "Choisissez votre recharge :.*"
	     "1:EDITION SPECIALE.*"
	     "2:5 EUR.*"
	     "3:10 EUR.*"
	     "4:15 EUR.*"
	     "5:Suite.*"}]}]++
	[].

test_recharge_SL([]) -> [];
test_recharge_SL([{Link, Value, Messg}|T]) ->
    [{title, "TEST RECHARGEMENT EDITIONS SPECIALES : "++ Messg},
     "Test rechargement CB 1er rechargement",
     {ussd2,
      [ {send, ?code_rech++"21"},
	{expect,"Profitez de SMS, MMS et Orange Messenger by Windows Live en illimite de 21h a minuit avec les recharges EDITION SPECIALE du moment:"},
	{send, Link},
	{expect, "Vous souhaitez recharger "++Value++"E de credit .*"},
	{send, "1"},
	{expect,"Veuillez saisir les 16 chiffres de votre carte bancaire pour confirmer votre versement et accepter les conditions du service illico."
	 "1:conditions"},
	{send, "4974991547039275"},
	{expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	 "1:conditions"},
	{send, "0690"},
	{expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature .s'ils sont illisibles, contactez votre banque."},
	{send, "123"},
	{expect, "Vous avez recharge votre compte de "++Value++"E. Votre nouveau credit est de .* a utiliser avant le .*"},
	{send, "1"},
	{expect, "...SMS, MMS et d'Orange Messenger en illimite de 21h a minuit jusqu'au .*"},
	{send, "1"},	
	{expect, "Telecharger gratuitement Orange Messenger sur http://im.orange.fr et profitez de messages instantanes illimites de 21h a minuit jusqu'au .*"}
       ]}]++

	test_util_of:close_session()++
	test_recharge_SL(T).

test_errors_mobi_recharge_cb([]) -> [];
test_errors_mobi_recharge_cb([{Error,Text}|T]) ->
    init_error(Error)++
	["Test Rechargement MOBI par carte bancaire with error :"++Text,
         {ussd2,
          [ {send, ?code_rech++"2*1*1*1"},
            {expect,".*"},
            {send, "4974991547039275"},
            {expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	     "1:conditions"},
            {send, "0690"},
            {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature .s'ils sont illisibles, contactez votre banque."},
            {send, "123"},
	    {expect, expect_error(Error)}
           ]}
        ]++

	test_util_of:close_session()++
	test_errors_mobi_recharge_cb(T).

init_error(Error) ->
    init()++
	case Error of
	    dossier_incorrect -> 
		profile_manager:set_asm_response(?uid,"isRechargeableMobi",#'ExceptionEtatDossierIncorrect'{});
	    option_interdite -> 
		profile_manager:set_asm_response(?uid,"isRechargeableMobi",#'ExceptionOptionInterdite'{});
	    no_msisdn ->
		profile_manager:set_asm_response(?uid,"getIdent",#'ExceptionDossierNonTrouve'{});
	    error_fonc ->
		profile_manager:set_asm_response(?uid,"isRechargeableMobi",#'ECareExceptionFonctionnelle'{});
	    error_tech ->
		profile_manager:set_asm_response(?uid,"isRechargeableMobi",#'ECareExceptionTechnique'{});
	    paiement_refuse ->        
                profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{});
	    paiement_refuse_14 ->        
                profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="14"});
	    paiement_refuse_40 ->        
                profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="40"});
	    paiement_refuse_44 ->        
                profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="44"});
	    paiement_refuse_45 ->        
                profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="45"});
	    donnee_invalid ->
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionDonneesInvalides'{});
	    error_rech_fonc ->
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ECareExceptionFonctionnelle'{});
	    error_rech_tech ->
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ECareExceptionTechnique'{});
	    _ ->
		[]
	end.

expect_error(Error) ->
    case Error of
	E when E==dossier_incorrect;E==option_interdite;E==not_allowed ->
	    "Vous n'etes pas autorise a utiliser ce service.*Pour plus d'informations, veuillez appeler le 722 \\(0,37E/min\\).";
	no_msisdn ->
	    "Vous n'etes pas encore autorise a utiliser ce service. Veuillez appeler votre service clients au 722 \\(0,37EUR\\/min\\)";
	EP when EP==paiement_refuse;EP==paiement_refuse_40 ->
	    "Echec rechargement.*Votre carte bancaire presente une anomalie. Nous vous invitons a contacter votre banque.*"
		"Pour recharger, RDV dans votre point de vente habituel.";
	paiement_refuse_14 ->
	    "Echec rechargement.*L'autorisation de paiement a ete refusee par votre banque.Veuillez contacter votre banque.*"
		"Pour recharger, RDV dans votre point de vente habituel.";
	paiement_refuse_44 ->
	    "Erreur.*Vous avez atteint le nombre de rechargements maximum autorise sur le mois.*"
		"Pour recharger, rendez-vous dans votre boutique France Telecom.";
	paiement_refuse_45 ->
	    "Votre demande depasse le plafond maximum autorise. Choisissez un montant inferieur.*"
		"1:Recommencer";
	donnee_invalid ->
	    "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*"
		"Pour recharger, nous vous invitons a appeler gratuitement le 224";
	error_rech_fonc ->
	    "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*"
		"Nous vous invitons a reesayer ou a appeler gratuitement le 224";
	error_rech_tech ->
	    "Erreur.*Suite a un probleme technique, le service est momentanement indisponible.*"
		"Nous vous invitons a reesayer ou a appeler gratuitement le 224.";
	_ ->
	    "Erreur.*"
		"Suite a un probleme technique, le service est momentanement indisponible..*"
		"Nous vous invitons a reessayer ulterieurement."
    end.

expect_info(link,?m6_prepaid) ->
    "speciale M6.*";
expect_info(link,X) 
  when X==?BORDEAUX_mobile; X==?PSG_mobile; X==?OM_mobile;
       X==?OL_mobile; X==?ASSE_mobile; X==?RC_LENS_mobile->
    "speciale OM / RC Lens / Girondins / OL / PSG / ASSE mobile.*";
expect_info(link,_)->
    "\\+ 1h vers fixes.*";
expect_info(type_recharge,?m6_prepaid)->
    "Vous souhaitez recharger 7E de credit valable 7j et beneficiez d'un acces illimite au portail Inside M6 mobile pendant 7j.*";
expect_info(type_recharge,X)
  when X==?BORDEAUX_mobile; X==?PSG_mobile; X==?OM_mobile;
       X==?OL_mobile; X==?ASSE_mobile; X==?RC_LENS_mobile->
    "Vous souhaitez recharger 7E de credit valable 7j et beneficiez de MMS illimites offerts, pendant 7j, en France metropolitaine.*"; 
expect_info(type_recharge,_)->
    "Vous souhaitez recharger 7E de credit valable 7j et beneficiez d'1h vers fixes offerte valable 7 jrs.*"; 
expect_info(info_plus,?m6_prepaid) ->
    "Contenus payants non compris dans l'offre. Services accessibles sur reseaux et depuis terminal compatible. Details de l'offre et conditions sur orange.fr.*";
expect_info(info_plus,X)
  when X==?BORDEAUX_mobile; X==?PSG_mobile; X==?OM_mobile;
       X==?OL_mobile; X==?ASSE_mobile; X==?RC_LENS_mobile->
    "Hors MMS surtaxes et MMS cartes postales. Details de l'offre et conditions sur orange.fr.*";
expect_info(info_plus,_)->
    "Credit de 7E et 1h de voix vers fixes offerte valable 7 jours en France metropolitaine. Details de l'offre et conditions sur orange.fr.*";
expect_info(success,?m6_prepaid) ->
    "Vous avez recharge votre compte de 7 euros. Nouveau credit :.* a utiliser avant le.*Surfez sur le portail Inside M6 mobile en illimite jusqu'au .*";
expect_info(success,X)
  when X==?BORDEAUX_mobile; X==?PSG_mobile; X==?OM_mobile;
       X==?OL_mobile; X==?ASSE_mobile; X==?RC_LENS_mobile->
    "Vous avez recharge votre compte de 7 euros. Votre nouveau credit est de .* a utiliser avant le .*Profitez de vos MMS en illimite jusqu'au .*";
expect_info(success,_)->
    "Vous avez recharge votre compte de 7 euros.*Nouveau credit :.* euros a utiliser avant le ../../.*Profitez d'1h vers fixes offerte a utiliser avant le ../..";
expect_info(_,_) ->
    "".

assert_received() ->
    [_] = smsloop_client:purge(),
    ok.

prisme_counters() ->
    [{"MO","PRCBSL", 2}
    ].

