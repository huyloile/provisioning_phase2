-module(test_123_cmo_recharge_cb).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").
-define(Uid,cmo_recharging_user).
%% -define(code_refill_by_cb,"#123*1*1*2*1").
-define(code_refill_by_cb,"#123*1*1*2").
-define(code,"#123*0012#").
-define(closed,"#128*13#").


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
    profile_manager:rpc_for_test(crypto, start, [])++
	test_util_of:set_present_period_for_test(commercial_date_cmo,rech_cb) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,appelle_moi) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,rech_pour_moi) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,cmo_tlr) ++
	test_util_of:set_present_period_for_test(commercial_date_cmo,recharge_cg) ++
	test_util_of:set_parameter_for_test(pfront_orangef,des3_encryption_keys,["lib/pfront_orangef/test/keys/key.cipher"])++
	[{title, "Test rechargement CB pour CMO"}] ++


   	test_premier_rechargement() ++
  	lists:append([test_rech_edition_special({Test, Amount}) || {Test, Amount} <- [
  										      {"7 jours", 10},
  										      {"31 jrs", 20},
  										      {"45 jrs", 30}
  										     ]])++

  	lists:append([test_rech_edition_special_error(Amount_error) || Amount_error <- ["8","12"]])++
  	test_rechargement_short() ++
  	test_short_code() ++

    	test_errors_access_recharge_cb([
   					{dossier_incorrect,"isrechargeableCB - ExceptionEtatDossierIncorrect"},
   					{option_interdite,"isrechargeableCB - ExceptionOptionInterdite"},
   					{no_msisdn,"Getidentification - dossier MSISDN non trouve"},
   					{getIdent_nok,"Erreur Getidentification"},
   					{isRech_func,"isrechargeableCB - EcareExceptionFonctionnelle"},
   					{isRech_tech,"isrechargeableCB - EcareExceptionTechnique"}
   				       ])++

   	test_errors_recharge_cb([
  				 {paiement_refuse_14,"DoRechargementCB - ExceptionPaiement - Refus du centre d'autorisation (Banques) (code : 14)"},
  				 {paiement_refuse_40,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (code :40)"},
  				 {donnees_invalides,"DorechargementCB - ExceptionDonneesInvalides"},
  				 {erreur_technique,"DorechargementCB - EcareExceptionTechnique"},
  				 {erreur_func,"DorechargementCB - EcareExceptionFonctionnelle"},
  				 {other_error,"Other errors"}
  				])++
	test_rech_error([
			 {paiement_refuse_14,"DoRechargementCB - ExceptionPaiement - Refus du centre d'autorisation (Banques) (code : 14)"},
			 {paiement_refuse_40,"DoRechargementCB - ExceptionPaiement - Refus bancaire GTAA (code :40)"},
			 {donnees_invalides,"DorechargementCB - ExceptionDonneesInvalides"},
			 {erreur_technique,"DorechargementCB - EcareExceptionTechnique"},
			 {erreur_func,"DorechargementCB - EcareExceptionFonctionnelle"},
			 {other_error,"Other errors"}
			])++


	profile_manager:rpc_for_test(crypto, stop, [])++
	["Test reussi"] ++
	[].

test_rech_edition_special_error(Montant_max) ->
    init()++
	profile_manager:set_asm_response(?Uid,"isRechargeableCmo",{ok, #isRechargeableCBResponse{
								     idDossier="0123",
								     mobicarte=true,
								     montantMaxRechargeable=Montant_max,
								     plafond="80",
								     rechargementsPossibles=[]}})++

	[
	 {title, "Test Rechargement Edition Special Error with Montant max " ++ Montant_max ++" Euros"},
	 "Test error recharge with amount over Montant max",
	 {ussd2,
	  [ {send, ?code_refill_by_cb},
	    {expect, "Saisissez les 16 chiffres de votre carte bancaire suivis de # puis validez.*Conditions.*"},
	    {send,"1"},
	    {expect,"Le service de rechargement par CB est accessible aux clients forfaits bloques.*"
	     "Rechargement d'un montant entre 8 et 80E. Plafond mensuel de 80E.*"
	     "1:Suite.*"},
	    {send,"1"},
	    {expect,"Vos coordonnees bancaires seront conservees pour vos rechargements ulterieurs.*"
	     "Il vous suffira de saisir votre code court \\(4 derniers chiffres de votre CB\\).*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"4974991547039275"},
	    {expect,"date de validite"}, %% test date de validité
	    {send,"0490"}, %% dat ok
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature \\(s'ils sont illisibles, contactez votre banque\\)"},
	    {send, "194"},
	    {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
             "Sinon, tapez un montant libre entre 8 et .*"},
	    {send,"1"},
	    {expect,"Profitez de SMS, MMS et Orange Messenger by Windows Live en illimite de 21h a minuit avec les recharges EDITION SPECIALE du moment:.*"},
	    case list_to_integer(Montant_max)>10 of
		false->
		    {send, "1"};
		_ ->
		    {send, "2"}
	    end,
	    case list_to_integer(Montant_max)>10 of
		false->
		    {expect, "Votre demande depasse le plafond autorise qui est de 8.00 EUR..*Pour recharger, RDV dans votre point de vente habituel."};
		_->
		    {expect, "Votre demande depasse le plafond autorise qui est de 12.00 EUR. Choisissez une autre recharge en tapant 1"}

	    end
 	   ]}] ++
	[].
test_rech_error([]) -> [];
test_rech_error([{Error,Text}|T]) ->
    init_error(Error)++
	[
	 {title, "Test Rechargement Edition Special with errors: " ++ Text},
	 {ussd2,
	  [ {send, ?code_refill_by_cb},
	    {expect, "Saisissez les 16 chiffres de votre carte bancaire suivis de # puis validez.*Conditions.*"},
	    {send,"1"},
	    {expect,"Le service de rechargement par CB est accessible aux clients forfaits bloques.*"
	     "Rechargement d'un montant entre 8 et 80E. Plafond mensuel de 80E.*"
	     "1:Suite.*"},
	    {send,"1"},
	    {expect,"Vos coordonnees bancaires seront conservees pour vos rechargements ulterieurs.*"
	     "Il vous suffira de saisir votre code court \\(4 derniers chiffres de votre CB\\).*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"4974991547039275"},
	    {expect,"date de validite"}, %% test date de validité
	    {send,"0490"}, %% dat ok
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature \\(s'ils sont illisibles, contactez votre banque\\)"},
	    {send, "194"},
	    {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
             "Sinon, tapez un montant libre entre 8 et .*"},
	    {send,"1"},
	    {expect,"Profitez de SMS, MMS et Orange Messenger by Windows Live en illimite de 21h a minuit avec les recharges EDITION SPECIALE du moment:.*"},
	    {send, "1"},
	    {expect, "Vous souhaitez recharger 10E de credit \\+ SMS, MMS et Orange Messenger en illimite de 21h a minuit pendant 7 jours en France metro.*"},
	    {send, "1"},
	    {expect, expect_error(Error)}
           ]}
	]++
        test_util_of:close_session()++
	test_rech_error(T).	    

test_rech_edition_special({Test, Amount}) ->
    init()++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=15000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=113}])++
	[
	 {title, "Test Rechargement Edition Special " ++ integer_to_list(Amount) ++ " Euros"},
	 "Balance before recharge: 15E",
	 {ussd2,
	  [ {send, ?code_refill_by_cb},
	    {expect, "Saisissez les 16 chiffres de votre carte bancaire suivis de # puis validez.*Conditions.*"},
	    {send,"1"},
	    {expect,"Le service de rechargement par CB est accessible aux clients forfaits bloques.*"
	     "Rechargement d'un montant entre 8 et 80E. Plafond mensuel de 80E.*"
	     "1:Suite.*"},
	    {send,"1"},
	    {expect,"Vos coordonnees bancaires seront conservees pour vos rechargements ulterieurs.*"
	     "Il vous suffira de saisir votre code court \\(4 derniers chiffres de votre CB\\).*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"4974991547039275"},
	    {expect,"date de validite"}, %% test date de validité
	    {send,"0490"}, %% dat ok
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature \\(s'ils sont illisibles, contactez votre banque\\)"},
	    {send, "194"},
	    {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
             "Sinon, tapez un montant libre entre 8 et .*"},
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
	    {expect,"Vous souhaitez recharger " ++ integer_to_list(Amount) ++ "E de credit \\+ SMS, MMS et Orange Messenger en illimite de 21h a minuit pendant " ++ Test ++" en France metro.*"}
	   ]}] ++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=15000 + (Amount * 1000),
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=113}])++
        [{ussd2,
          [ {send, "#123#"},
	    {send, "1"},
	    {expect, "Rechargement reussi.*"},
	    {send, "1"},
	    {expect, "...SMS, MMS et d'Orange Messenger en illimite de 21h a minuit jusqu'au .* en France metropolitaine..*"
	     "1:Suite"},
	    {send, "1"},
	    {expect, "Telecharger gratuitement Orange Messenger sur http://im.orange.fr et profitez de messages instantanes illimites de 21h a minuit jusqu'au .*"}
	   ]}] ++
	[].

test_premier_rechargement() ->
    init()++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=23000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=113}])++
	[
	 {title, "Test Rechargement Condition premiere fois OK - Pour le 1er rechargement"},
	 "Balance before recharge: 15E",
	 {ussd2,
	  [ {send, ?code_refill_by_cb},
	    {expect, "Saisissez les 16 chiffres de votre carte bancaire suivis de # puis validez.*Conditions.*"},
	    {send,"1"},
	    {expect,"Le service de rechargement par CB est accessible aux clients forfaits bloques.*"
	     "Rechargement d'un montant entre 8 et 80E. Plafond mensuel de 80E.*"
	     "1:Suite.*"},
	    {send,"1"},
	    {expect,"Vos coordonnees bancaires seront conservees pour vos rechargements ulterieurs.*"
	     "Il vous suffira de saisir votre code court \\(4 derniers chiffres de votre CB\\).*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"8"},
	    {expect, ".*"},
	    {send,"4974991547039275"},
	    {expect,"date de validite"}, %% test date de validité
	    {send,"0490"}, %% dat ok
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature \\(s'ils sont illisibles, contactez votre banque\\)"},
	    {send, "194"},
	    {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
             "Sinon, tapez un montant libre entre 8 et.*"},
	    {send,"8"},
	    {expect,"compte mobile de 8 Euros"},
	    {send,"1"},
	    {expect,"Rechargement reussi.*"}
	   ]}] ++
	[].

test_errors_access_recharge_cb([]) -> [];
test_errors_access_recharge_cb([{Error,Text}|T]) ->
    init_error(Error)++
        [
         {title, "Test Access Rechargement CB with error : "++Text},
         {ussd2,
          [
           {send, ?code_refill_by_cb},
	   {expect, expect_error(Error)}
          ]
         }]++
	test_util_of:close_session()++
	test_errors_access_recharge_cb(T).

test_errors_recharge_cb([]) -> [];
test_errors_recharge_cb([{Error,Text}|T]) ->
    init_error(Error)++
        ["Test Rechargement CB with error : "++Text,
         {ussd2,
          [
	   {send, ?code_refill_by_cb},
	   {expect, "Saisissez les 16 chiffres de votre carte bancaire suivis de # puis validez.*Conditions.*"},
	   {send,"1"},
	   {expect,"Le service de rechargement par CB est accessible aux clients forfaits bloques.*"
	    "Rechargement d'un montant entre 8 et 80E. Plafond mensuel de 80E.*"
	    "1:Suite.*"},
	   {send,"1"},
	   {expect,"Vos coordonnees bancaires seront conservees pour vos rechargements ulterieurs.*"
	    "Il vous suffira de saisir votre code court \\(4 derniers chiffres de votre CB\\).*"},
	   {send,"8"},
	   {expect, ".*"},
	   {send,"8"},
	   {expect, ".*"},
	   {send,"4974991547039275"},
	   {expect,"date de validite"}, %% test date de validité
	   {send,"0490"}, %% dat ok
	   {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature.*"},
	   {send, "194"},
	   {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
	    "Sinon, tapez un montant libre entre 8 et.*"},
	   {send,"8"},
	   {expect,"compte mobile de 8 Euros"},
	   {send,"1"},
	   {expect, expect_error(Error)}

	  ]}
        ]++
	test_util_of:close_session()++
	test_errors_recharge_cb(T).


test_rechargement_short() ->
    init()++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=23000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=113}])++
	[
	 {title, "Test Rechargement - Short code"},
	 "Balance before recharge: 15E",
	 {ussd2,
	  [ {send, ?code_refill_by_cb},
	    {expect, "Saisissez les 16 chiffres de votre carte bancaire suivis de # puis validez.*Conditions.*"},
	    {send,"1234"},
	    {expect,"Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature \\(s'ils sont illisibles, contactez votre banque\\)"},
	    {send, "194"},
	    {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
             "Sinon, tapez un montant libre entre 8 et .*"},
	    {send,"8"},
	    {expect,"compte mobile de 8 Euros"},
	    {send,"1"},
	    {expect,"Rechargement reussi.*"}
	   ]}] ++
	[].


test_short_code() ->
    init()++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=23000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=113}])++
	profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_CB})++
	[
	 {title, "Test Rechargement Condition - A partir du 2eme rechargement"},
	 "Balance before recharge: 15E",
	 {ussd2,
	  [ {send, ?code_refill_by_cb},
	    {expect, "Saisissez votre code court \\(les 4 derniers chiffres de votre carte bancaire\\) suivi de # ou les 16 chiffres de votre CB suivis de #.*Conditions.*"},
	    {send,"1234"},
	    {expect,"Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature \\(s'ils sont illisibles, contactez votre banque\\)"},
	    {send, "194"},
	    {expect,"Pour decouvrir les recharges EDITION SPECIALE du moment, tapez 1.*"
	     "Sinon, tapez un montant libre entre 8 et .*"},
	    {send,"8"},
	    {expect,"compte mobile de 8 Euros"},
	    {send,"1"},
	    {expect,"Rechargement reussi.*1:Decouvrir options et bons plans.*"},
	    {send,"1"}, 
	    {expect,".*"}
	   ]}] ++
	profile_manager:update_user_state(?Uid,{etats_sec,0})++
	[].

init() ->
    profile_manager:create_default(?Uid,"cmo")++
	profile_manager:set_dcl(?Uid,?ppol2)++
        profile_manager:init(?Uid).

init_error(Error) ->
    init()++
	case Error of
	    dossier_incorrect -> 
		profile_manager:set_asm_response(?Uid,"isRechargeableCmo",#'ExceptionEtatDossierIncorrect'{});
	    option_interdite -> 
		profile_manager:set_asm_response(?Uid,"isRechargeableCmo",#'ExceptionOptionInterdite'{});
	    no_msisdn ->
		profile_manager:set_asm_response(?Uid,"getIdent",#'ExceptionDossierNonTrouve'{});
	    getIdent_nok ->
		profile_manager:set_asm_response(?Uid,"getIdent",#'ECareExceptionTechnique'{});
	    isRech_func ->
		profile_manager:set_asm_response(?Uid,"isRechargeableCmo",#'ECareExceptionFonctionnelle'{});
	    isRech_tech ->
		profile_manager:set_asm_response(?Uid,"isRechargeableCmo",#'ECareExceptionTechnique'{});
	    other_error ->
		profile_manager:set_asm_response(?Uid,"doRechargeCB",#'ExceptionPaiement'{});
            paiement_refuse_40 -> 
		profile_manager:set_asm_response(?Uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="40"});
            paiement_refuse_14 ->
                profile_manager:set_asm_response(?Uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="14"});
            donnees_invalides -> 
                profile_manager:set_asm_response(?Uid,"doRechargeCB",#'ExceptionDonneesInvalides'{});
            erreur_technique -> 
                profile_manager:set_asm_response(?Uid,"doRechargeCB",#'ECareExceptionTechnique'{});
            erreur_func -> 
                profile_manager:set_asm_response(?Uid,"doRechargeCB",#'ECareExceptionFonctionnelle'{});
            _ ->
                []
        end.

expect_error(Error) ->
    case Error of
	E when E==dossier_incorrect;E==option_interdite -> 
	    "Vous n'etes pas autorise a utiliser ce service.*Vous pouvez appeler .*";
	no_msisdn ->
	    "Vous n'etes pas encore autorise a utiliser ce service. Veuillez appeler votre service clients au 722 \\(0,37EUR\\/min\\)";
	E1 when E1==getIdent_nok;E1==isRech_func;E1==isRech_tech ->
	    "Erreur.*Suite a un probleme technique, le service est momentanement indisponible.*"
		"Nous vous invitons a reessayer ulterieurement.";
	paiement_refuse_40 ->
	    "Echec rechargement.*Votre carte bancaire presente une anomalie. Nous vous invitons a contacter .*";
	paiement_refuse_14 -> 
	    "Echec rechargement.*L'autorisation de paiement a ete refusee par votre banque.Veuillez contacter votre .*";
	donnees_invalides -> 
	    "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*Pour .*";
	erreur_technique -> 
	    "Erreur.*Suite a un probleme technique, le service est momentanement .*";
	erreur_func ->
	    "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*"
		"Nous vous invitons a reesayer ou a appeler gratuitement le 740.";
	_ -> 
	    "Probleme technique.*Le service est momentanement interrompu. Veuillez recommencer ulterieurement. Vous allez quitter le #123#..*"
    end.
