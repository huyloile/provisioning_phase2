-module(test_123_mobi_recharge_mobicarte).
-compile(export_all).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").

-define(uid, recharge_mobicarte_user).
%% gene
-define(back,"0").
-define(menu,"00").

-define(code_self_mobi,"#123*1*1").
-define(code_direct,"#124").
-define(code_menu,"#123*1").
-define(imsi_mobi,"999000900000001").
-define(msisdn_mobi,"9900000001").
-define(msisdn_mobi_int,"+99900000001").
-define(niv1,"100007XXXXXXX1").
-define(niv2,"100006XXXXXXX2").
-define(niv3,"100005XXXXXXX3").


top_num(Opt) -> svc_options:top_num(Opt,mobi).
ptf_num(Opt) -> svc_options:ptf_num(Opt,mobi).
tcp_num(Opt) -> svc_options:tcp_num(Opt,mobi).

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
    init()++
	test_util_of:set_present_period_for_test(commercial_date,[recharge_cg]) ++
   	recharge_mobi_mobicarte()++
    	test_errors([
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
 	test_error_rech_not_allowed()++
	["Test reussi"].

recharge_mobi_mobicarte() ->
     test_normal_recharge()++
    test_recharge_SL([
		      {10000, 2, "10"},
		      {20000, 3, "20"},
		      {30000, 4, "30"}
		     ])++
 	[].



test_normal_recharge() -> 
    init()++
	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=124,ctk_num=35,accounts=[#account{tcp_num=1,montant=10000,dlv=pbutil:unixtime()+7*86400}]})++
	[{title, "Test MOBI Rechargement mobicarte"},
 	 "Pas de CG entree apr le client",
 	 {ussd2,
 	  [ {send, "#123*1*1"},
 	    {expect,"Saisissez les 14 chiffres de votre code de rechargement"}
	   ]},
 	 "Code CG FAUX",
 	 {ussd2,
 	  [ {send, ?code_self_mobi++"*123456#"},		
 	    {expect,"Rechargement refuse"}
	   ]},
	 "Code CG OK - Balance before recharge 10E - Recharge amount 10E",
 	 {ussd2,
 	  [ {send, ?code_self_mobi++"*12345678901234#"},
 	    {expect,"Vous avez recharge votre compte de 10.00E. Votre nouveau credit est de 20 euros 00 a utiliser avant le .*"
	     "1:Decouvrir les options et bons plans"}
	   ]}
	]++
	test_util_of:close_session()++

	init()++
	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=124,ctk_num=35,accounts=[#account{tcp_num=1,montant=25000,dlv=pbutil:unixtime()+7*86400}]})++
 	[{title, "Test MOBI Rechargement 124"},
 	 "Pas de CG entree apr le client",
 	 {ussd2,
 	  [ {send, ?code_direct++"#"},
 	    {expect,"Saisissez #124.Code_a_14_chiffres# pour recharger"}
	   ]},
 	 "Code CG FAUX",
 	 {ussd2,
 	  [ {send, ?code_direct++"*123456#"},		
 	    {expect,"Saisissez #124.Code_a_14_chiffres# pour recharger"}
	   ]},
	 "Code CG OK - Balance before recharge 10E - Recharge amount 25E",
 	 {ussd2,
 	  [ {send, ?code_direct++"*12345678901234#"},
 	    {expect,"Vous avez recharge votre compte de 25.00E \\+ 0.00E offerts. Votre nouveau credit est de 35 euros 00 a utiliser avant le .*"
	     "1:Decouvrir les options et bons plans"}
	   ]}
 	]. 


test_errors([]) -> [];
test_errors([{Error,Text}|T]) ->
    init_error(Error)++
        ["Test recharge par ticket with error: " ++ Text]++
	[
         {ussd2,
          [ {send, "#123*11"},
            {expect, ".*"},
            {send, "12345678912301"},
	    {expect, expect_error(Error)}
           ]}
        ]++

	test_util_of:close_session()++
	test_errors(T).

test_error_rech_not_allowed() ->
    profile_manager:create_default(?uid, "mobi")++
        profile_manager:set_list_options(?uid, [])++
        profile_manager:set_list_comptes(?uid, [#compte{tcp_num=?C_PRINC,
                                                        unt_num=?EURO,
                                                        cpp_solde=1000,
                                                        dlv=pbutil:unixtime(),
                                                        rnv=0,etat=?CETAT_AC,
                                                        ptf_num=?PCLAS_V2}])++
        profile_manager:set_bundles(?uid,[])++
	profile_manager:set_dcl(?uid,?mobi_janus)++
	profile_manager:update_user_state(?uid,{etats_sec,?SETAT_LS})++
        profile_manager:init(?uid)++
	["Test recharge par ticket with error: \'Etat secondaire' controle: JANUS not identified, \'Libre Service\'"]++
	[
         {ussd2,
          [ {send, "#123*11"},
            {expect, ".*"},
            {send, "12345678912301"},
	    {expect, expect_error(not_allowed)}
           ]}
        ]++

	test_util_of:close_session().

test_recharge_SL([]) -> [];
test_recharge_SL([{Amount,Ttk_num,Text}|T]) -> 
    init()++
	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=Ttk_num,ctk_num=35,accounts=[#account{tcp_num=1,montant=Amount,dlv=pbutil:unixtime()}]})++ 
	test_util_of:set_past_period_for_test(commercial_date,[recharge_sl_mobi]) ++
	[ {title, "Test Rechargement  - Special Editions "++Text++"E - Out of commercial date"},
	  "Balance before recharge = 10E",
	  {ussd2,
	   [ {send, ?code_self_mobi++"*12345678912362#"},
	     {expect,"Vous avez recharge votre compte de "++Text++".00E.*. Votre nouveau credit est de .* a utiliser avant le .*Decouvrir les options et bons plans"}
	    ]}]++
	test_util_of:close_session()++

 	init()++
	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=Ttk_num,ctk_num=35,accounts=[#account{tcp_num=1,montant=Amount,dlv=pbutil:unixtime()}]})++ 
 	test_util_of:set_present_period_for_test(commercial_date,[recharge_sl_mobi]) ++
 	[ {title, "Test Rechargement - Special Editions "++Text++"E - Success"},
	  "Balance before recharge = 10E",
 	  {ussd2,
 	   [
	    {send, ?code_self_mobi++"*12345678912362#"},
	    {expect,"Vous avez recharge votre compte de "++Text++"E. Votre nouveau credit est de .* a utiliser avant le .* Profitez en plus de..."
	     ".*1:Suite"},
 	    {send,"1"},
 	    {expect,"...SMS, MMS et d'Orange Messenger en illimite de 21h a minuit jusqu'au .* en France metropolitaine..*1:Suite.*"},
 	    {send, "1"},
 	    {expect, "Telecharger gratuitement Orange Messenger sur http://im.orange.fr et profitez de messages instantanes illimites de 21h a minuit jusqu'au .*"}
 	    ]
	  }]++
 	test_util_of:close_session()++

  	init()++
  	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=Ttk_num,ctk_num=35,accounts=[#account{tcp_num=1,montant=Amount,dlv=pbutil:unixtime()}]})++
   	test_util_of:set_past_period_for_test(commercial_date,[recharge_sl_mobi]) ++
   	[ {title, "Test Rechargement 124 - Special Editions "++Text++"E - Out of commercial date "},
 	  "Balance before recharge = 10E",
   	  {ussd2,
   	   [ {send, ?code_direct++"12345678912362#"},
   	     {expect,"Vous avez recharge votre compte de "++Text++".00E.*. Votre nouveau credit est de .* a utiliser avant le .*Decouvrir les options et bons plans"}
   	    ]}]++
  	test_util_of:close_session()++

  	init()++
  	profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=Ttk_num,ctk_num=35,accounts=[#account{tcp_num=1,montant=Amount,dlv=pbutil:unixtime()}]})++
   	test_util_of:set_present_period_for_test(commercial_date,[recharge_sl_mobi]) ++
   	[ {title, "Test Rechargement 124 - Special Editions "++Text++"E - Success "},
 	  "Balance before recharge = 10E",
             {ussd2,
              [ {send, ?code_direct++"12345678912362#"},
                {expect,"Vous avez recharge votre compte de "++Text++"E. Votre nouveau credit est de .*euros a utiliser avant le .* Profitez en plus de..."
                 ".*1:Suite"},
                {send,"1"},
                {expect,"Profitez en \\+ de vos 20 minutes d'appels offerts de 7h a 17h vers tous les operateurs jusqu'au .* en France metropolitaine"}
               ]}]++
  	test_util_of:close_session()++

	test_recharge_SL(T).

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
		"Pour recharger, nous vous invitons a appeler gratuitement le 224.";
	E2 when E2==error_cls_bad_code;E2==ticket_recharge_invalide ->
            "Erreur.*Votre ticket n'est pas valide. Pour plus d'informations, veuillez appeler le 722 \\(0,37E/min\\).";
	error_cls_tck_deja ->
            "Erreur.*Votre ticket a deja ete utilise.*"
		"Vous pouvez recharger par carte bancaire, si vous le souhaitez en repondant 1.*1:Recharger";
	E3 when E3==ticket_recharge_inconnu;E3==dossier_inaccessible ->
            "Erreur.*Rechargement refuse car les caracteres saisis ne sont pas corrects. Veuillez verifier les chiffres et les composer a nouveau. Merci.*"
                "1:Reessayer";
        E4 when E4==incompatible_offre;E4==erreur_options;E4==erreur_promo ->
            "Erreur.*Rechargement refuse car le ticket utilise n'est pas compatible avec votre offre.*"
                "Merci d'appeler le 722 \\(0,37E/min\\) pour plus d'infos, ou...*1:Suite";
	not_allowed ->
	    "Vous n'etes pas autorise a utiliser ce service..*Pour plus d'informations, veuillez appeler le 722 \\(0,37E/min\\)";
        _ ->
	    "Erreur.*Rechargement refuse car le ticket utilise n'est pas compatible avec votre offre.*Merci d'appeler le 722 \\(0,37E\\/min\\) pour plus d'infos, ou...*1:Suite"
    end.

init() ->
    profile_manager:create_default(?uid, "mobi")++
        profile_manager:set_list_options(?uid, [])++
        profile_manager:set_list_comptes(?uid, [#compte{tcp_num=?C_PRINC,
                                                        unt_num=?EURO,
                                                        cpp_solde=10000,
                                                        dlv=pbutil:unixtime(),
                                                        rnv=0,etat=?CETAT_AC,
                                                        ptf_num=?PCLAS_V2}])++
        profile_manager:set_bundles(?uid,[])++
        profile_manager:init(?uid)++
	[].

init_error(Error) ->
    init()++
	case Error of
	    error_cls_bad_code ->
                profile_manager:update_sachem(?uid,"csl_tck",[{"TTK_NUM","300"},
                                                          {"ETT_NUM","3"}]);
            error_cls_tck_deja ->
                profile_manager:update_sachem(?uid,"csl_tck",[{"TTK_NUM","300"},
                                                              {"ETT_NUM","4"}]);
	    _ ->
                profile_manager:set_sachem_response(?uid,{?rec_tck,{nok, atom_to_list(Error)}})
        end.

prisme_counters() ->
    [{"MO","PRECTRSL", 12},
     {"MO","PRECTR", 20}
    ].
