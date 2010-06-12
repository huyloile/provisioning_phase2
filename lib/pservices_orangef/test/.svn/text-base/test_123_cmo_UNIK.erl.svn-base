-module(test_123_cmo_UNIK).

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
-include("access_code.hrl").
-include("profile_manager.hrl").


-define(BACK, "8").
-define(Uid,user_Unik).

-define(code_main_menu,"#123*1#").
-define(IMEI_UNIK,"35185301").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?unik_page].

parent(?unik_page) ->
    test_123_cmo_Homepage.

links(?unik_page) ->
    [{unik_pour_zap, static}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    smsloop_client:start(),
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()),
    smsloop_client:stop(),
    ok.

test()->
	[test_util_of:connect(smppasn)] ++
	test_options_unik([?zap_vacances,
			   ?DCLNUM_CMO_SL_ZAP_1h30_ILL
			  ]) ++
	[].

test_options_unik([]) -> ["Test reussi"];
test_options_unik([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
	[{title, "Test Options UNIK - DCL =" ++ integer_to_list(DCL)}] ++

	test_options_unik(DCL,
			  [Opt||Opt<-["opt_unik_pour_zap_tous_operator"
				     ]])++
	test_options_unik(T)++
	[].


test_options_unik(_,[])->[];
test_options_unik(DCL,[Option|T])->
    ["Test removing option Unik pour Zap, and running option Unik pour Zap tous operateurs"] ++
    	test_options_unik_souscrire(DCL,Option)++
       	test_options_unik_deja_souscrire(DCL,Option)++	
    	test_options_unik_solde_insuff(DCL,Option)++
  	test_options_unik_mention_legs(DCL,Option)++

	test_options_unik(DCL,T) ++
	[].

expect_menu_unik() ->
    "Unik.*"
	"1:Unik Pour Zap.*".
expect_souscrire_option_et_bons_plans_menu2() ->    
    "L'offre Orange.*"
        "1:Offres eXclusives.*"
        "2:A l'etranger.*". 
expect_souscrire_option_et_bons_plans_menu(unik) ->
    expect_souscrire_option_et_bons_plans_menu()++
	".*:Unik".
expect_souscrire_option_et_bons_plans_menu() ->
    "L'offre Orange.*"
	"1:Bons plans.*"
	"2:Options SMS/MMS - Orange Messenger.*"
	"3:Options multimedia.*"
	"4:SMS/MMS Infos.*"
	"5:Options securite.*".

test_options_unik_souscrire(DCL,Option) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",imei=?IMEI_UNIK,dcl=DCL})++
	profile_manager:init(?Uid)++
 	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
 						       unt_num=?EURO,
 						       cpp_solde=5000,
 						       dlv=pbutil:unixtime(),
 						       rnv=0,
 						       etat=?CETAT_AC,
 						       ptf_num=41},
 					       #compte{tcp_num=?C_FORF_ZAP_CMO_20E,
 						       unt_num=?EURO,
 						       cpp_solde=30000,
 						       dlv=pbutil:unixtime(),
 						       rnv=0,
 						       etat=?CETAT_AC,
 						       ptf_num=41},
 					       #compte{tcp_num=?C_BONS_PLANS,
 						       unt_num=?EURO,
 						       cpp_solde=3000,
 						       dlv=pbutil:unixtime(),
 						       rnv=0,
 						       etat=?CETAT_AC,
 						       ptf_num=?PBONS_PLANS}
 					      ])++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"}) ++
        [{title, "Test options Unik souscrire - DCL "++integer_to_list(DCL)++"\n"},
         {ussd2,
          [
	   {send, test_util_of:access_code(parent(?unik_page), ?bons_plans)},
	   {expect, expect_souscrire_option_et_bons_plans_menu(unik)},
	   {send, "7"},
	   {expect, expect_souscrire_option_et_bons_plans_menu2()},
	   {send, "8"},
  	   {expect, expect_souscrire_option_et_bons_plans_menu(unik)},
 	   {send, test_util_of:link_rank(parent(?unik_page), ?bons_plans, ?unik_page)},
	   {expect, expect_menu_unik()},
	   {send, test_util_of:link_rank(?MODULE, ?unik_page, unik_pour_zap)},
	   {expect,"1:Suite.*"
	    "2:Souscrire.*"
	    "7:Mentions legales"},
	   {send,"2"},
	   {expect,"Vous allez souscrire a.*, vous serez facture.*"
	    "1:Valider"},
	   {send,"1"},
	   {expect,"Validation.*"
	    "Souscription enregistree.*"
	    "Vous serez averti de son activation par SMS."}
	  ]}
        ]++
	close_session().


test_options_unik_deja_souscrire(DCL,Option) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",imei=?IMEI_UNIK,dcl=DCL})++
        profile_manager:init(?Uid)++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=1}])++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"}) ++
        [{title, "Test options Unik deja souscrire - DCL "++integer_to_list(DCL)++"\n"},
	  {ussd2,
	   [
	    {send, test_util_of:access_code(?MODULE, unik_pour_zap)},
	    {expect,"1:Suite.*"
	     "2:Souscrire.*"
	     "7:Mentions legales"},
	    {send,"21"},
	    {expect,"Validation.*"
	     "Souscription enregistree. Vous serez averti de son activation par SMS."}
	   ]}
        ]++
	close_session().



test_options_unik_solde_insuff(DCL,Option) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",imei=?IMEI_UNIK,dcl=DCL})++
        profile_manager:init(?Uid)++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
						       unt_num=?EURO,
						       cpp_solde=3000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=1}])++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"}) ++
        [{title, "Test options Unik solde insuffisant - DCL "++integer_to_list(DCL)++"\n"},
	  {ussd2,
	   [
	    {send, test_util_of:access_code(?MODULE, unik_pour_zap)},
	    {expect,"1:Suite.*"
	     "2:Souscrire.*"
	     "7:Mentions legales"},
	    {send,"21"},
	    {expect,"Le service est actuellement indisponible.*"}
	   ]}
	 ]++
	 close_session().


test_options_unik_mention_legs(DCL,Option) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",imei=?IMEI_UNIK,dcl=DCL})++
        profile_manager:init(?Uid)++	
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
                                                   unt_num=?EURO,
                                                   cpp_solde=5000,
                                                   dlv=pbutil:unixtime(),
                                                   rnv=0,
                                                   etat=?CETAT_AC,
                                                   ptf_num=41}])++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"}) ++

        [{title, "Test options Unik mention legs - DCL "++integer_to_list(DCL)++"\n"},
         {ussd2,
          [
	   {send, test_util_of:access_code(?MODULE, unik_pour_zap)},
	   {expect,"1:Suite.*"
	    "2:Souscrire.*"
	    "7:Mentions legales"},
	   {send,"7"},
	   {expect,"Offre Unik valable sous reserve d'abonnement a un forfait bloque Zap.*"},
	   {send, "1"},
	   {expect, "et de disposer d'un acces internet haut debit Orange \\(minimum 1 megamax\\) ou de la fibre Orange, d'une Livebox Wi-Fi"},
	   {send, "1"},
	   {expect, "et d un mobile Unik compatible. liste des mobiles et conditions specifiques a l'option sur www.unik.orange.fr."},
	   {send, "1"},
	   {expect, "Appels voix illimites de 16h a 20h inities avec votre mobile Unik connecte a une Livebox. 3h max/appel, hors n0s speciaux,"},
	   {send,"1"},
	   {expect,"n0s services, n0s IP a tarification specifique et n0s en cours de.*"},
	   {send, "1"},
	   {expect, "de 200 destinataires differents par mois. Appels directs entre personnes physiques et pour un usage.*"},
	   {send, "1"},
	   {expect, "Navigation illimitee de 16h a 20h sur le portail Orange World, Gallery et internet.*"},
	   {send,"1"},
	   {expect,"Consultation illimitee sur le portail Orange World des videos des rubriques actualite, sport et cinema \\(hors matchs en direct\\)."},
	   {send, "1"},
	   {expect, "Le streaming TV, audio, video \\(autres que ceux precites\\), les usages modem, le mail \\(SMTP, POP, IMAP\\), les contenus"},
	   {send, "1"},
	   {expect, "et services payants sont factures en dehors de l option. Voix sur IP, peer to peer et Newsgroups interdits."},
	   {send, "1"},
	   {expect, "Orange pourra limiter le debit au dela d un usage de 500Mo/mois jusqu a la date de facturation."},
	   {send,"1"},
	   {expect,"Services accessibles sur reseaux et depuis un terminal compatible."}
	  ]}
        ]++
	close_session().

so_code(Option)->
    case Option of 
	"opt_unik_pour_zap_tous_operator" ->"UKC60"
    end.

asmserv_init(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_init(MSISDN, ACTIV_OPTs).
insert(IMSI,DCL,OPT,COMPTES) ->
    test_util_of:insert(IMSI,DCL,OPT,COMPTES,[]).

close_session() ->
    test_util_of:close_session().
prisme_counters() ->
    [
     %%       {"CM","MO61", 1},
     %%       {"CM","PO61", 1},
     %%       {"CM","AO61", 1},

     %%       {"CM","AO62", 1},
     %%       {"CM","MO62", 1},
     %%       {"CM","PO62", 1},

     %%        {"CM","AB22", 1},
     %%        {"CM","MB22", 1},
     %%        {"CM","PB22", 1},

     %%        {"CM","MO57", 1},
     %%        {"CM","PO57", 1},
     %%        {"CM","AO57", 2},

     %%        {"CM","MOG3", 1},
     %%        {"CM","POG3", 1},
     %%        {"CM","AOG3", 2}
    ].
