-module(test_123_mobi_recharge_umobile).
-compile(export_all).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../include/recharge_cb_mobi.hrl").

-define(uid, recharge_mobicarte_user).
%% gene
-define(back,"0").
-define(menu,"00").

-define(code_direct,"#124*").
-define(code_menu,"#123*1").

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
    	test_util_of:init_day_hour_range()++
     	test_recharge_umobile() ++
	["Test reussi"].

%% -define(code_self_mobi,"#123*111").
-define(code_self_umobile,"#123*11").

test_recharge_umobile() ->
    test_recharge_par_ticket()++
	test_recharge_par_cb()++
	["OK"].

test_recharge_par_ticket() ->
    test_recharge_success()++
	lists:append([test_errors(Error) || Error <- [ {error,"carte_perimee_tr_promo"},
						       {error,"incident_technique"},
						       {error,"autres_erreurs_recharge"},
						       {error,"format_requete_incorrect"},
						       {error,"ticket_recharge_invalide"},
						       {error,"ticket_deja_utilise"},
						       {error,"ticket_recharge_inconnu"},
						       {error,"erreur_options"},
						       {error,"erreur_promo"},
						       {error,"incompatible_offre"}]])++
	[].

test_recharge_success() ->
    init()++
	[
	 {title, "Test Rechargement MOBI Niv1 - DCL = Umobile"},
	 "Pas de CG entree apr le client",
	 {ussd2,
	  [ 
	    {send, ?code_self_umobile++"#"},
	    {expect, "Saisissez les 14 chiffres de votre code de rechargement situes sur votre ticket de rechargement puis validez.*"}
	    ]
	 },
	 "Code CG OK",
	 {ussd2,
	  [ {send, ?code_self_umobile++"*12345678912301#"},
	    {expect,"Rechargement reussi.*de 11.00 Euros.*Vos bons plans.*"},
	    {send, "1"},
	    {expect, ".*Vos appels.*Vos SMS.*Votre multimedia.*Vos appels internationaux.*"}
	   ]}
	]++
	[].

test_errors(Error) ->
    init()++
	case element(2,Error) of 
	    "ticket_deja_utilise" ->
		profile_manager:update_sachem(?uid,"csl_tck",[{"TTK_NUM","300"},
							      {"ETT_NUM","4"}])++
		    profile_manager:set_sachem_response(?uid, {"rec_tck",Error});
	    _ -> 
		profile_manager:set_sachem_response(?uid, {"rec_tck",Error})
	end++
	["Test recharge umobile par ticket with error: " ++ element(2,Error)]++
	[
	 {ussd2,
	  [ {send, ?code_self_umobile++"#"},
	    {expect, ".*"},
	    {send, "12345678912301"},
	    case element(2,Error) of 
		"carte_perimee_tr_promo" -> 
		    {expect, "Erreur.*Pour activer cette recharge promo, vous devez avoir du credit sur votre compte rechargeable.*Nous vous invitons a le recharger prealablement"};
		Err when Err=="incident_technique";
			 Err=="autres_erreurs_recharge" -> 
		    {expect, "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*Nous vous invitons a reessayer plus tard."};
		"format_requete_incorrect" -> 
		    {expect, "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*Pour recharger, nous vous invitons a appeler gratuitement le 224."};
		"ticket_recharge_invalide" -> 
		    {expect, "Erreur.*Votre ticket n'est pas valide. Pour plus d'informations, veuillez appeler le 722 \\(0,37E\\/min\\)"};		    
		"ticket_deja_utilise" -> 
		    {expect, "Erreur.*Votre ticket a deja ete utilise.*Vous pouvez recharger par carte bancaire, si vous le souhaitez en repondant 1"};
		"ticket_recharge_inconnu" -> 
		    {expect, "Erreur.*Rechargement refuse car les caracteres saisis ne sont pas corrects. Veuillez verifier les chiffres et les composer a nouveau. Merci.*1:Reessayer"};
		_ ->
		    {expect,"Erreur.*Rechargement refuse car le ticket utilise n'est pas compatible avec votre offre Umobile.*Merci d'appeler le 722 \\(0,37E\\/min\\) pour plus d'infos, ou...*1:Suite"}
	    end
	   ]}
	]++test_util_of:close_session().

test_recharge_par_cb() ->
     test_recharge_success_cb()++
     	lists:append([test_errors_cb(Error) || Error <- [ {error,"dossier_incorrect"},
     							  {error,"option_interdite"},
     							  {error,"no_msisdn"},
     							  {error,"paiement_refuse_14"},
     							  {error,"paiement_refuse_40"},
     							  {error,"paiement_refuse_44"},
     							  {error,"paiement_refuse_45"},
     							  {error,"donnees_invalides"},
     							  {error,"erreur_technique"},
     							  {error,"erreur_saisie_16_chiffres"},
     							  {error,"erreur_saisie_4_chiffres"},
     							  {error,"erreur_saisie_3_chiffres"}
     							 ]])++
	test_autre_rechargement()++
	[].

test_recharge_success_cb() ->
    init()++
	[
	 {title, "Test Rechargement MOBI par carte bancaire - DCL = Umobile"},
	 "Pas de CG entree apr le client",
	 {ussd2,
	  [ 
	    {send, "#123*12#"},
	    {expect, "Bienvenue sur le service de rechargement par CB. Choisissez votre recharge :.*"
	     "1:5 EUR.*"
	     "2:10 EUR.*"
	     "3:15 EUR.*"
	     "4:25 EUR \\+ 5 E offerts.*"
	     "5:35 EUR \\+ 10 E offerts.*"}
	    ]
	 },
	 "Code CG OK",
	 {ussd2,
	  [ {send, "#123*12*11#"},
	    {expect,".*"},
	    {send, "4974991547039275"},
	    {expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	     "1:conditions"},
	    {send, "0690"},
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature .s'ils sont illisibles, contactez votre banque."},
	    {send, "123"},
	    {expect, "Vous avez recharge votre compte de .*Votre nouveau credit est de .* euros a utiliser avant le .*"}
	   ]}
	]++test_util_of:close_session().

test_autre_rechargement() ->
    init()++
	["Test autre rechargement par CB for Umobile"]++
	[{ussd2,
	  [ {send, "#123*12#"},
	    {expect,".*"},
	    {send, "11"},
	    {expect, ".*"},
	    {send, "4974991547039275"},
	    {expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	     "1:conditions"},
	    {send, "0690"},
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature .s'ils sont illisibles, contactez votre banque."},
	    {send, "123"},
	    {expect, "Vous avez recharge votre compte de .*Votre nouveau credit est de .* euros a utiliser avant le .*"},
	    {send, "911"},
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre carte bancaire. Si vous avez change de CB, saisissez les 16 chiffres de votre nouvelle CB"},
	    {send, "123a"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez saisir les 3 derniers chiffres au dos de votre CB ou les 16 chiffres de votre nouvelle CB"},
	    {send, "1234"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez saisir les 3 derniers chiffres au dos de votre CB ou les 16 chiffres de votre nouvelle CB"},
	    {send, "1235"},
	    {expect, "Vous avez fait 3 erreurs dans les informations saisies. Veuillez appeler votre Service Clients au 722 \\(0,37EUR\\/min\\). Pour recharger, RDV dans les magasins U participants."}
	   ]}
	]++test_util_of:close_session().

test_errors_cb({_,Error}) 
  when Error=="dossier_incorrect";
       Error=="option_interdite";
       Error=="no_msisdn" ->
    init()++
	case Error of 
	    "dossier_incorrect" -> 
		profile_manager:set_asm_response(?uid,"isRechargeableMobi",#'ExceptionEtatDossierIncorrect'{});
	    "option_interdite" -> 
		profile_manager:set_asm_response(?uid,"isRechargeableMobi",#'ExceptionOptionInterdite'{});
	    "no_msisdn" ->
		profile_manager:set_asm_response(?uid,"getIdent",#'ExceptionDossierNonTrouve'{});
	    _ ->
		[]
	end++		    
	[
	 {title, "Test Rechargement MOBI par carte bancaire with error :"++Error},
	 {ussd2,
	  [ 
	    {send, "#123*12#"},
	    case Error of 
		E when E=="dossier_incorrect";
		       E=="option_interdite" -> 
		    {expect, "Vous n'etes pas autorise a utiliser ce service.*Vous pouvez appeler le 722 \\(0,37E\\/min\\) ou vous procurer une recharge dans les magasins U participants."};
		"no_msisdn" ->
		    {expect, "Vous n'etes pas encore autorise a utiliser ce service. Veuillez appeler votre service clients au 722 \\(0,37EUR\\/min\\)"};
		_ ->
		    {expect, ".*"}
	    end
	   ]
	  }]++test_util_of:close_session();

test_errors_cb({_,Error}) 
when Error=="paiement_refuse_14";
     Error=="paiement_refuse_40";
     Error=="paiement_refuse_44";
     Error=="paiement_refuse_45";
     Error=="donnees_invalides";
     Error=="erreur_technique" ->
    init()++
	case Error of 
	    "paiement_refuse_40" -> 
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="40"});
	    "paiement_refuse_14" ->
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="14"});
	    "paiement_refuse_44" ->
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="44"});
	    "paiement_refuse_45" ->
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionPaiement'{codeMessage="45"});
	    "donnees_invalides" -> 
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ExceptionDonneesInvalides'{});
	    "erreur_technique" -> 
		profile_manager:set_asm_response(?uid,"doRechargeCB",#'ECareExceptionTechnique'{});
		
	    _ ->
		[]
	end++	
    ["Test Rechargement MOBI par carte bancaire with error :"++Error]++
	[
	 {ussd2,
	  [ {send, "#123*12*11#"},
	    {expect,".*"},
	    {send, "4974991547039275"},
	    {expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	     "1:conditions"},
	    {send, "0690"},
	    {expect, "Veuillez saisir les 3 derniers chiffres au dos de votre CB a cote de votre signature .s'ils sont illisibles, contactez votre banque."},
	    {send, "123"},
	    case Error of
		"paiement_refuse_40" ->
		    {expect, "Echec rechargement.*Votre carte bancaire presente une anomalie. Nous vous invitons a contacter votre banque.*Pour recharger, RDV dans les magasins U participants."};
		"paiement_refuse_14" -> 
		    {expect, "Echec rechargement.*L'autorisation de paiement a ete refusee par votre banque.Veuillez contacter votre banque.*Pour recharger, RDV dans les magasins U participants."};
		"paiement_refuse_44" ->
		   {expect, "Erreur.*Vous avez atteint le nombre de rechargements maximum autorise sur le mois.*Pour recharger, rendez-vous dans les magasins U participants."};
		"paiement_refuse_45" ->
		    {expect, "Votre demande depasse le plafond maximum autorise. Choisissez un montant inferieur.*1:Recommencer"};
		"donnees_invalides" -> 
		    {expect, "Erreur.*Suite a un probleme technique, votre rechargement n'a pas pu etre effectue.*Pour recharger, nous vous invitons a appeler gratuitement le 224."};
		"erreur_technique" -> 
		    {expect, "Erreur.*Suite a un probleme technique, le service est momentanement indisponible.*Nous vous invitons a reesayer ou a appeler gratuitement le 224."};
		_ -> 
		    {expect, ".*"}
	    end
	   ]}
	]++test_util_of:close_session();

test_errors_cb({_,Error}) when Error=="erreur_saisie_16_chiffres" ->
    init()++
    ["Test Rechargement MOBI par carte bancaire with error :"++Error]++
	[
	 {ussd2,
	  [ {send, "#123*12*11#"},
	    {expect,".*"},
	    {send, "49749915470392756"},
	    {expect, "Les informations saisies sont incorrectes.*Veuillez saisir les 16 chiffres de votre carte bancaire"},
	    {send, "49749915470392757"},
            {expect, "Les informations saisies sont incorrectes.*Veuillez saisir les 16 chiffres de votre carte bancaire"},
	    {send, "49749915470392758"},
            {expect, "Les informations saisies sont incorrectes. Veuillez appeler votre Service Clients au 722 \\(0,37EUR\\/min\\)."}
	   ]}
	]++test_util_of:close_session();

test_errors_cb({_,Error}) when Error=="erreur_saisie_4_chiffres" ->
    init()++
    ["Test Rechargement MOBI par carte bancaire with error :"++Error]++
	[
	 {ussd2,
	  [ {send, "#123*12*11#"},
	    {expect, ".*"},
	    {send, "4974991547039275"},
	    {expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	     "1:conditions"},
	    {send, "01245"},	    
	    {expect,"Les informations saisies sont incorrectes. Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire..*"},
	    {send, "012a"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire..*"},
	    {send, "123c"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez appeler votre Service Clients au 722 \\(0,37EUR\\/min\\).*Pour recharger, RDV dans les magasins U participants."}
	   ]}
	]++test_util_of:close_session();

test_errors_cb({_,Error}) when Error=="erreur_saisie_3_chiffres" ->
    init()++
    ["Test Rechargement MOBI par carte bancaire with error :"++Error]++
	[
	 {ussd2,
	  [ {send, "#123*12*11#"},
	    {expect, ".*"},
	    {send, "4974991547039275"},
	    {expect, "Veuillez saisir les 4 chiffres de la date de validite de votre carte bancaire.."
	     "1:conditions"},
	    {send, "0124"},	    
	    {expect,".*"},
	    {send, "012a"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez saisir les 3 derniers chiffres au dos de votre CB \\(si c'est illisible, contacter votre banque"},
	    {send, "012b"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez saisir les 3 derniers chiffres au dos de votre CB \\(si c'est illisible, contacter votre banque"},
	    {send, "123c"},
	    {expect, "Les informations saisies sont incorrectes. Veuillez appeler votre Service Clients au 722 \\(0,37EUR\\/min\\).*Pour recharger, RDV dans les magasins U participants."}
	   ]}
	]++test_util_of:close_session().
     
init() ->
    profile_manager:create_default(?uid, "mobi")++
	profile_manager:set_dcl(?uid, ?umobile)++
	profile_manager:set_list_options(?uid, [])++
	profile_manager:set_list_comptes(?uid, [#compte{tcp_num=?C_PRINC,
							unt_num=?EURO,
							cpp_solde=1000,
							dlv=pbutil:unixtime(),
							rnv=0,etat=?CETAT_AC,
							ptf_num=?PCLAS_V2}])++
	profile_manager:set_bundles(?uid,[])++
	profile_manager:init(?uid)++
	test_util_of:set_past_period_for_test(commercial_date,[refill_game]) ++
	test_util_of:set_present_period_for_test(commercial_date,[recharge_cg]) ++
	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=124,ctk_num=35,accounts=[#account{tcp_num=1,montant=10000,dlv=pbutil:unixtime()}]})++
    test_util_of:set_parameter_for_test(pfront_orangef,des3_encryption_keys,["lib/pfront_orangef/test/keys/Key1"]).
	
prisme_counters() ->
    [{"MO","PRECTRSL", 12},
     {"MO","PRECTR", 20}
    ].
