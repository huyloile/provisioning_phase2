-module(test_123_mobi_aide).
-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid, user_mobi_aide).

online() ->
    test_util_of:online(?MODULE,test()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test()->
      test_menu_aide()++
   	test_navigation()++
   	test_recharger()++
   	test_vos_bons_plans()++
   	test_exclusives()++
 	test_fun()++
 	test_votre_bonus() ++
	["Test reussi"].

text_menu_aide(DCL)
  when DCL==?mobi;DCL==?B_phone;DCL==?mobi_janus->
    "Aide.*1:Navigation #123#.*2:Recharger.*3:Votre bonus.*4:Vos bons plans.*5:Offres eXclusives chaque mardi.*6:Fun et Multimedia";
text_menu_aide(?m6_prepaid) ->
    "Aide.*1:Navigation #123#.*2:Recharger.*3:Vos bons plans.*4:Fun et Multimedia";
text_menu_aide(_) ->
    "Aide.*1:Navigation #123#.*2:Recharger.*3:Vos bons plans.*4:Offres eXclusives chaque mardi.*5:Fun et Multimedia".

menu_bons_plans(DCL)
  when DCL==?mobi_janus;
       DCL==?mobi->
    "4";
menu_bons_plans(_) ->
    "3".

menu_eXclusive(DCL)
  when DCL==?mobi_janus;
       DCL==?mobi->
    "5";
menu_eXclusive(_) ->
    "4".

menu_fun_et_multimedia(DCL)
  when DCL==?mobi_janus;
       DCL==?mobi->
    "6";
menu_fun_et_multimedia(?m6_prepaid) ->
    "4";
menu_fun_et_multimedia(_) ->
    "5".

test_menu_aide() ->
    test_menu_aide(?mobi)++
	test_menu_aide(?DCLNUM_ADFUNDED)++
        test_menu_aide(?mobi_janus)++
        test_menu_aide(?B_phone)++
        test_menu_aide(?click_mobi)++
        test_menu_aide(?OM_mobile)++
        test_menu_aide(?m6_prepaid)++
        test_menu_aide(?umobile)++
	[].

test_navigation() ->
    test_navigation(?mobi)++
	test_navigation(?DCLNUM_ADFUNDED)++
	test_navigation(?click_mobi)++
	test_navigation(?OM_mobile)++
	test_navigation(?m6_prepaid)++
	test_navigation(?umobile)++
	[].

test_recharger() ->
    test_recharger(?mobi)++
	test_recharger(?DCLNUM_ADFUNDED)++
	test_recharger(?click_mobi)++
	test_recharger(?OM_mobile)++
	test_recharger(?m6_prepaid)++
	test_recharger(?umobile)++
	[].

test_vos_bons_plans() ->
    test_vos_bons_plans(?mobi)++
	test_vos_bons_plans(?DCLNUM_ADFUNDED)++
	test_vos_bons_plans(?click_mobi)++
	test_vos_bons_plans(?OM_mobile)++
	test_vos_bons_plans(?m6_prepaid)++
	test_vos_bons_plans(?umobile)++
	[].

test_exclusives() ->
    test_exclusives(?mobi)++
	test_exclusives(?DCLNUM_ADFUNDED)++
	test_exclusives(?click_mobi)++
	test_exclusives(?OM_mobile)++
	test_exclusives(?umobile)++
	[].

test_fun() ->
    test_fun(?mobi)++
	test_fun(?DCLNUM_ADFUNDED)++
	test_fun(?click_mobi)++
	test_fun(?OM_mobile)++
	test_fun(?m6_prepaid)++
	test_fun(?umobile)++
	[].

test_votre_bonus() ->
    test_votre_bonus(?mobi) ++
        test_votre_bonus(?B_phone) ++
        test_votre_bonus(?mobi_janus) ++
	[].

test_menu_aide(DCL) ->
    case DCL of
 	?B_phone ->
 	    init_test(DCL) ++
		profile_manager:set_list_options(?Uid,[#option{top_num=0}])++
		profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=1000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
		profile_manager:update_user_state(?Uid,{etats_sec,0}) ++
    		[{title, "#### Menu Aide - Bic phone non identified - DCL="++integer_to_list(DCL)++" ####"},
    		 "Test premiere page - DCL = " ++ integer_to_list(DCL),
    		 {ussd2,
    		  [ {send, "#123#"},
    		    {expect, "3:Aide"},
    		    {send,"3"},
    		    {expect, text_menu_aide(default)}
    		   ]}] ++
     		test_util_of:close_session() ++
		profile_manager:set_list_options(?Uid,[#option{top_num=0}])++
		profile_manager:set_list_comptes(?Uid,[])++
		profile_manager:update_user_state(?Uid,{etats_sec,1}) ++
  		[{title, "#### Menu Aide - Bic phone identified - DCL="++integer_to_list(DCL)++" ####"},
		 "Test premiere page - DCL = " ++ integer_to_list(DCL),
		 {ussd2,
		  [ {send, "#123#"},
		    {expect, "3:Aide"},
		    {send,"3"},
		    {expect,text_menu_aide(?B_phone)}
		   ]}]++
  		test_util_of:close_session();
  	_->
	    init_test(DCL)++
		[{title, "#### Menu Aide - DCL="++integer_to_list(DCL)++"####"},
                 "Test premiere page - DCL = " ++ integer_to_list(DCL),
                 {ussd2,
                  [ {send, "#123#"},
                    {expect, "3:Aide"},
                    {send,"3"},
                    {expect,text_menu_aide(DCL)}
                   ]}]++
                test_util_of:close_session()
    end.

test_navigation(DCL) ->
    init_test(DCL)++
	[{title, "#### Aide - Navigation - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [ {send, "#123#"},
	    {expect, "3:Aide"},
	    {send,"3"},
	    {expect,text_menu_aide(DCL)},
	    {send,"1"},
	    {expect,"La navigation dans le #123# est simple, appuyez d'abord sur \"Repondre\" puis saisissez le chiffre d'une rubrique.Appuyez enfin sur \"Envoyer\".*1:Suite.*9:Accueil"},
	    {send,"1"},
	    {expect,"Ou que vous soyez dans votre navigation, 8 vous permet de revenir a la page precedente et 9 de retourner a l'accueil.*9:Accueil"}
	   ]}]++
	test_util_of:close_session().

test_recharger(DCL) ->
    init_test(DCL)++
	[{title, "#### Aide - Recharger - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [ {send, "#123#"},
	    {expect, "3:Aide"},
	    {send,"3"},
	    {expect,text_menu_aide(DCL)},
	    {send,"2"},
	    {expect,"Avec le #123#,recharger,c'est simple,sur et rapide.Choisir sa recharge et decouvrir les nouvelles series limitees n'a jamais ete aussi facile.*"
	     "1:Suite.*"
	     "2:Recharger"},
	    {send,"1"},
	    {expect,"Vous pouvez recharger par ticket rechargement ou carte bancaire. Aucune inquietude a avoir, vous pouvez revenir a tout moment en arriere..*"
	     "1:Recharger"},
	    {send,"1"},
	    {expect,"Rechargement"}
	   ]}] ++
	test_util_of:close_session().

test_vos_bons_plans(DCL) ->
    init_test(DCL)++
	[{title, "#### Aide - Vos Bons plans - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [ {send, "#123#"},
	    {expect, "3:Aide"},
	    {send,"3"},
	    {expect,text_menu_aide(DCL)},
	    {send, menu_bons_plans(DCL)},
	    {expect,"Decouvrez les bons plans sur tous vos usages mobiles pour telephoner moins cher: Voix,SMS,Messenger,Multimedia et bien d'autres.*"
	     "1:Suite.*"
	     "2:Bons Plans"},
	    {send,"1"},
	    {expect,"Avec le #123#, vous pouvez tres facilement souscrire, supprimer ou bien reactiver un bon plan en quelques minutes!.*"
	     "1:Suite.*"
	     "2:Bons Plans"},
	    {send,"1"},
	    {expect,"Aucune inquietude a avoir, vous pouvez revenir a tout moment en arriere. Le montant du bon plan sera preleve seulement apres confirmation de votre part..*"
	     "1:Bons Plans"},
	    {send,"1"},
	    {expect,".*"}
	   ]}] ++
	test_util_of:close_session().

test_exclusives(DCL) ->
    init_test(DCL)++
	[{title, "#### Aide - Offres eXclusives - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [ {send, "#123#"},
	    {expect, "3:Aide"},
	    {send,"3"},
	    {expect, text_menu_aide(DCL)},
	    {send, menu_eXclusive(DCL)},
	    {expect,"Chaque mardi, Orange vous propose des offres eXclusives: envie d'appeler en illimite ou d'envoyer des SMS a petits prix.*"
	     "1:Suite*"
	     ".2:offres eXclusives de la semaine"},
	    {send,"1"},
	    {expect,"Pensez a les consulter regulierement, il y en a forcement une faite pour vous. Souscrivez en toute tranquillite,.*"
	     "1:Suite.*"
	     "2:offres eXclusives de la semaine"},
	    {send,"1"},
	    {expect,"vous pouvez tres facilement revenir en arriere et le montant de l'offre eXclusive sera preleve apres confirmation de votre part.*"
	     "1:offres eXclusives de la semaine"}
	   ]}]++
	test_util_of:close_session().

test_fun(DCL) ->
    init_test(DCL)++
	[{title, "#### Aide - Fun - DCL="++integer_to_list(DCL)++" ####"},
	 {ussd2,
	  [ {send, "#123#"},
	    {expect, "3:Aide"},
	    {send,"3"},
	    {expect,text_menu_aide(DCL)},
	    {send, menu_fun_et_multimedia(DCL)},
	    {expect,"La rubrique Fun vous permet d'acceder aux services d'orange world. Personnalisez votre mobile avec une nouvelle sonnerie,accedez a l'actualite, au chat....*"
	     "1:Fun"},
	    {send,"1"},
	    {expect,"1:Pass sonneries Hi-Fi"}
	   ]}]++
	test_util_of:close_session().

test_votre_bonus(DCL)->
    init_test(DCL)++
        [{title, "#### Aide - Votre Bonus - DCL="++integer_to_list(DCL)++" ####"},
         {ussd2,
          [ {send, "#123#"},
            {expect, "3:Aide"},
            {send,"3"},
            {expect,text_menu_aide(DCL)},
            {send,"3"},
            {expect,"Choisissez un bonus et profitez d'appels, de sms ou d'internet offerts selon le montant recharge le mois precedent..*"
	     "1:Comment en profiter ?.*"
	     "2:Detail des bonus"},
            {send,"1"},
            {expect,"Si vous avez choisi votre bonus le 15 septembre par exemple, le 15 devient le jour anniversaire de votre bonus..*A partir de 10E recharge,.*"
	     "1:Suite"},
            {send,"1"},
	    {expect, "vous beneficiez automatiquement d'un bonus le mois suivant, disponible a compter du jour anniversaire: le 15 du mois par exemple..*"
	     "1:Suite"},
	    {send, "1"},
	    {expect, "Plus vous rechargez avant le jour anniversaire de votre bonus \\(le 15 de chaque mois par exemple\\), et plus vous gagnez de bonus..*"
	     "1:Detail des bonus"},
	    {send, "1"},
            {expect,"Detail des bonus :.*"
	     "1:Bonus appels.*"
	     "2:Bonus SMS.*"
	     "3:Bonus internet.*"
	     "4:Bonus international"},
            {send,"1"},
            {expect, "De 10E a 19,99E recharges dans le mois, 20mn offertes le mois suivant!.*De 20E a 29,99E, 40mn offertes!.*et pour 30E ou \\+, 80mn offertes!"},
            {send, "82"},
	    {expect, "De 10E a 19,99E recharges dans le mois, 100 SMS offerts le mois suivant!.*De 20E a 29,99E, 200 SMS offerts!.*et pour 30E ou \\+, SMS illimites offerts!"},
	    {send, "83"},
            {expect,"De 10E a 19,99E recharges dans le mois, 1h d'internet offerte le mois suivant!.*De 20E a 29,99E, 2h offertes!.*et pour 30E ou \\+, 4h offertes!"},
            {send,"84"},
            {expect, "De 10E a 19,99E recharges dans le mois, 10 min offertes vers l'Europe ou le Maghreb le mois suivant,.*De 20E a 29,99E, 20 min offertes.*et pour 30E ou \\+, 40 min offertes"}
           ]}] ++
	[].

init_test(DCL)->
    profile_manager:create_default(?Uid,"mobi")++
	profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
	profile_manager:init(?Uid)++
	profile_manager:set_dcl(?Uid,DCL).
