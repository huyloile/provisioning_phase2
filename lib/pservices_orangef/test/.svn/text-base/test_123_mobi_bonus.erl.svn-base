-module(test_123_mobi_bonus).
-compile([export_all]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid,mobi_janus_user).
-define(Uid_classic,mobi_classic_user).

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



online() ->
    smsloop_client:start(),
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()),
    smsloop_client:stop().

prisme_counters() ->    
    [{"MO","SCACOK", 11},
     {"MO","SCONOK", 13}
    ].


test()->
    %% TEST FOR DCL != 110
    test_decouvrir(cible)++
	test_menu(sans_bonus)++

  	%%TEST FOR DCL = 110 (MOBI JANUS)
  	profile_manager:create_default(?Uid,"mobi")++
  	profile_manager:set_dcl(?Uid,?mobi_janus)++
  	profile_manager:init(?Uid)++

	test_menu(avec_bonus) ++
	test_changer()++
	test_choisir()++
	test_choisir_promo()++

	test_suivi_conso_plus(avec_perso)++
   	test_suivi_conso_plus(sans_perso)++
	test_util_of:close_session() ++
	["Test reussi"].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Text menu suivi conso plus %%%%%%%%%%%%%%%%%%%%

text_sv_conso_plus_menu(avec_perso) ->
    "1:Mon Bonus en cours.*"
	"2:Suivi recharge.*"
	"3:Options.*";
text_sv_conso_plus_menu(_) ->
    "1:Choisir mon Bonus.*"
	"2:Options/Promo.*".

mon_bonus(avec_perso) ->
    "en cours - avec perso";
mon_bonus(_) ->
    "choisir - sans perso".
text_mon_bonus(avec_perso) ->
    "Il vous reste .*";
text_mon_bonus(_) ->
    "".

text_menu(Mobi,Opt,Credit) ->
    "1:Suivi Conso \\+.*2:Recharger.*"++
	case {Mobi,Opt,Credit < 45} of 
	    {classique,no_option,true} ->
		"3:decouvrir les bonus.*4:Vos bons plans.*5:Fun.*6:Nouveautes";
	    {classique,no_option,_} ->
		"3:decouvrir les bonus.*4:Vos bons plans.*5:Offrir du credit.*6:Fun.*7:Nouveautes";
	    {classique,_,true} -> 
		"3:Illimite KDO.*4:Vos bons plans.*5:Fun.*6:Nouveautes";
	    {classique,_,_} ->
		"3:Illimite KDO.*4:Vos bons plans.*5:Offrir du credit.*6:Fun.*7:Nouveautes";
	    {janus,choisir_bonus,true} ->
		"3:choisir Bonus.*4:Vos bons plans.*5:Fun.*6:Nouveautes";
	    {janus,choisir_bonus,_} ->
		"3:choisir Bonus.*4:Vos bons plans.*5:Offrir du credit.*6:Fun.*7:Nouveautes";
	    {janus,changer_bonus,true} ->
		"3:changer bonus.*4:Vos bons plans.*5:Fun.*6:Nouveautes";
	    {janus,_,_} ->
		"3:changer bonus.*4:Vos bons plans.*5:Offrir du credit.*6:Fun.*7:Nouveautes"
	end.

test_menu(sans_bonus) ->
    Credits = [40, 60],
    profile_manager:create_default(?Uid_classic,"mobi")++
	profile_manager:init(?Uid_classic)++
	lists:append([test_link_ikdo(opt_illimite_kdo,Credit)||Credit <- Credits])++
	lists:append([test_link_ikdo(opt_ikdo_vx_sms,Credit)||Credit <- Credits])++
	lists:append([test_link_ikdo(opt_illimite_kdo_v2,Credit)||Credit <- Credits])++
	[];

test_menu(avec_bonus) ->
    Credits = [20, 70],    
    lists:append([test_link_choisir(no_option,Credit)||Credit <- Credits])++
	lists:append([test_link_changer(no_option,Credit)||Credit <- Credits])++
	[].

test_link_choisir(no_option,Credit) ->
    set_list_comptes(?Uid,[compte(?C_PRINC,Credit,0)])++
	set_list_options(?Uid,[])++
        [ "MENU Mobicarte bonus - Prepaid JANUS"++"\n"++
	  "#### case X = choisir bonus and credit = "++integer_to_list(Credit)] ++
        [ {ussd2,
	   [
	    {send, "#123*2#"},
	    {expect,text_menu(janus,choisir_bonus,Credit)}
	   ]}]++test_util_of:close_session() ++
	[].
test_link_changer(no_option,Credit) ->
    set_list_comptes(?Uid,[compte(?C_PRINC,Credit,0)])++
	set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_bonus_appels,mobi)}])++
        [ "MENU Mobicarte bonus - Prepaid JANUS"++"\n"++
	  "#### case X = changer bonus and credit = "++integer_to_list(Credit)] ++
        [ {ussd2,
	   [
	    {send, "#123*2#"},
            {expect,text_menu(janus,changer_bonus,Credit)}
           ]}]++
	test_util_of:close_session()++
	[].

test_link_ikdo(Opt,Credit) ->
    set_list_comptes(?Uid_classic,[compte(?C_PRINC,Credit,0)])++
	set_list_options(?Uid_classic,[#option{top_num=svc_options:top_num(Opt,mobi)}])++
	test_util_of:set_parameter_for_test(type_decouvrir_bonus,"non") ++
        [ "MENU Mobicarte classique - Prepaid non JANUS"++"\n"++
	  "#### case X = "++atom_to_list(Opt)++" and credit = "++integer_to_list(Credit)] ++
        [ {ussd2,
	   [
	    {send, "#123*2#"},
            {expect,text_menu(classique,Opt,Credit)}
           ]}]++
	test_util_of:close_session()++
	[].

test_suivi_conso_plus(Type) ->
    test_sv_conso_plus_menu(Type)++
	test_mon_bonus(Type)++
	test_sv_recharge(Type)++
	test_options_promo(Type)++
	[].

test_sv_conso_plus_menu(Type) ->
    set_list_comptes(?Uid,[compte(?C_PRINC,15,01),compte(?C_BONS_PLANS,15,01)])++
	profile_manager:set_default_spider(?Uid, config, [actif,suivi_conso_plus])++
	case Type of 
	    avec_perso ->
		set_list_options(?Uid,[#option{top_num=435}]);
	    _ ->
		set_list_options(?Uid,[])
	end++	
 	[ "Test Suivi conso + Homepage - " ++atom_to_list(Type)] ++
  	[ {ussd2,
 	   [ {send, "#123*2*1#"},
 	     {expect, text_sv_conso_plus_menu(Type)}
 	    ]}]++
	[].


test_mon_bonus(avec_perso) ->
    [ "#### Test Bonus actif - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=435}])++
	init_cumul_rechargement(42)++
        [ "Test Mon Bonus voix - "++mon_bonus(avec_perso)] ++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous beneficiez d'appels offerts ce mois-ci. Il vous reste .* a utiliser avant le .*"}
	   ]}]++

	set_list_options(?Uid,[#option{top_num=436}])++
        [ "Test Mon Bonus sms - "++mon_bonus(avec_perso)] ++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous beneficiez de SMS offerts ce mois-ci. Il vous reste .*SMS"}
	   ]}]++

        %% Ano 3671 - was leading to "error_technique"
        init_cumul_rechargement(6)++
        [ "Test Mon Bonus sms - "++mon_bonus(avec_perso) ++
	  " - Cumul 6 - Ano 3671" ] ++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous beneficiez de SMS offerts ce mois-ci. Il vous reste .*SMS"}
	   ]}]++

	init_cumul_rechargement(42)++
	set_list_options(?Uid,[#option{top_num=437}])++
        [ "Test Mon Bonus internet - "++mon_bonus(avec_perso)] ++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous beneficiez de temps de connexion a l'internet mobile offert ce mois-ci.*"}
	   ]}]++

	set_list_options(?Uid,[#option{top_num=438},#option{top_num=439}])++
        [ "Test Mon Bonus europe - "++mon_bonus(avec_perso)] ++
        [ {ussd2,
           [ 
	     {send, "#123*2*1*1#"},
             {expect, "Vous beneficiez d'appels offerts vers et depuis l'Europe ce mois-ci"}
            ]}]++

	set_list_options(?Uid,[#option{top_num=438},#option{top_num=440}])++
        [ "Test Mon Bonus maghreb - "++mon_bonus(avec_perso)] ++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous beneficiez d'appels offerts vers et depuis le Maghreb ce mois-ci"}
	   ]}]++

        [ "#### Test Option presente mais Bonus non present - "++mon_bonus(avec_perso)] ++
	set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
				       unt_num=?EURO,
				       cpp_solde=52518,
				       dlv=pbutil:unixtime(),
				       rnv=0,
				       etat=?CETAT_PE,
				       ptf_num=?PCLAS_V2}])++

        [ "Test Mon Bonus Voix non present - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=435}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
            {expect, "Pas d'appels offerts ce mois-ci.*"
	     "Rechargez minimum 10E avant le ../../.. pour profiter d'au moins 20min d'appels offerts le mois prochain..*"
	     "1:Recharger"}
           ]}]++

        [ "Test Mon Bonus SMS non present - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=436}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
            {expect, "Pas de SMS offerts ce mois-ci..*"
	     "Rechargez minimum 10E avant le ../../.. pour profiter d'au moins 100 SMS offerts le mois prochain..*"
	     "1:Recharger"}
           ]}]++

        [ "Test Mon Bonus Internet non present - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=437}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
            {expect, "Pas d'internet mobile offert ce mois-ci..*"
	     "Rechargez minimum 10E avant le ../../.. pour profiter d'au moins 1h offerte d'internet mobile le mois prochain..*"
	     "1:Recharger"}
           ]}]++

        [ "Test Mon Bonus Europe non present - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=438},#option{top_num=439}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
            {expect, "Pas d'appels offerts vers et depuis l'Europe ce mois-ci.*"
	     "Rechargez minimum 10E avant le ../../.. pour profiter d'appels offerts le mois prochain..*"
	     "1:Recharger"}
           ]}]++

        [ "Test Mon Bonus Maghreb non present - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=438},#option{top_num=440}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
            {expect, "Pas d'appels offerts vers et depuis le Maghreb ce mois-ci..*"
	     "Rechargez minimum 10E avant le ../../.. pour profiter d'appels offerts le mois prochain..*"
	     "1:Recharger"}
           ]}]++

        [ "#### Test Bonus consumed - "++mon_bonus(avec_perso)] ++
	set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
				       unt_num=?EURO,
				       cpp_solde=52518,
				       dlv=pbutil:unixtime(),
				       rnv=0,
				       etat=?CETAT_PE,
				       ptf_num=?PCLAS_V2},
			       #compte{tcp_num=300,
				       unt_num=?EURO,
				       cpp_solde=111820,
				       dlv=pbutil:unixtime(),
				       rnv=0,
				       etat=?CETAT_PE,
				       ptf_num=?PCLAS_V2}])++

        [ "Test Mon Bonus Voix consumed - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=435}])++
        [ {ussd2,
           [ 
	     {send, "#123*2*1*1#"},
             {expect, "Vous avez totalement consomme votre bonus voix ce mois-ci.*"}
            ]}]++

        [ "Test Mon Bonus sms consumed - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=436}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
            {expect, "Vous avez totalement consomme votre bonus SMS ce mois-ci.*"}
           ]}]++

        [ "Test Mon Bonus Internet consumed - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=437}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous avez totalement consomme votre bonus internet ce mois-ci.*"}
	   ]}]++

        [ "Test Mon Bonus Europe consumed - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=438},#option{top_num=439}])++
        [ {ussd2,
           [
	    {send, "#123*2*1*1#"},
	    {expect, "Vous avez totalement consomme votre bonus d'appels "
	     "vers et depuis l'Europe ce mois-ci.*"}
	   ]}]++

        [ "Test Mon Bonus Maghreb consumed - "++mon_bonus(avec_perso)] ++
	set_list_options(?Uid,[#option{top_num=438},#option{top_num=440}])++
        [ {ussd2,
           [ {send, "#123*211#"},
             {expect, "Vous avez totalement consomme votre bonus d'appels "
              "vers et depuis le Maghreb ce mois-ci.*"}
            ]}]++
        [];

test_mon_bonus(sans_perso) ->
    test_util_of:set_parameter_for_test(
      commercial_date,[{mobi_janus_promo,[test_util_of:get_present_period()]},
		       {user_janus_promo,[test_util_of:get_present_period()]}])++
	set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
				       unt_num=?EURO,
				       cpp_solde=10000,
				       dlv=pbutil:unixtime(),
				       rnv=21,
				       etat=?CETAT_AC,
				       ptf_num=?PCLAS_V2}])++
	profile_manager:update_user_state(?Uid,{d_activ,lt2unixt({date(),{0,0,0}})})++
        [ "Test Mon Bonus sans perso: choisir bonus"] ++
        [ {ussd2,
           [ 
	     {send, "#123*2*1#"},
	     {expect,"1:Choisir mon Bonus.2:Options.Promo"},
	     {send,"1"},
             {expect, "Envie d'appels offerts, de SMS ou d'internet?.*Choisissez votre bonus:.*"}
            ]}]++
	set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
				       unt_num=?EURO,
				       cpp_solde=10000,
				       dlv=pbutil:unixtime(),
				       rnv=21,
				       etat=?CETAT_AC,
				       ptf_num=?PCLAS_V2}])++
	profile_manager:update_user_state(?Uid,{d_activ,lt2unixt({date(),{23,59,59}})})++
	[ "Test Mon Bonus sans perso: choisir bonus promo"] ++
        [ {ussd2,
           [
	    {send, "#123*2*3#"},
	    {expect, "Promo: choisissez avant le 13/02 et beneficiez le 1er mois du bonus MAX"}
	   ]}]++
	[];

test_mon_bonus(_) ->[].

test_sv_recharge(avec_perso) ->
     init_cumul_rechargement(6)++
 	set_list_options(?Uid,[#option{top_num=435}])++
  	[ "Test Suivi Conso recharge - avec perso cumul des rechargements < 10E",
	  "Cpp_cumul_credit = 6.00E, Opt_info2 = 0.00E",
	  {ussd2,
  	   [
 	    {send, "#123*2*1*2#"},
 	    {expect,"Rechargements cumules depuis le ../../..: .*E.*1:Suite"},
 	    {send, "1"},
 	    {expect, "Pour beneficier du bonus: .* a compter du ../../.., il vous manque .*E. "}
 	   ]}]++

  	init_cumul_rechargement(62)++
 	set_list_options(?Uid,[#option{top_num=435,
				       opt_info2="50"}])++
  	[ "Test Suivi Conso recharge - avec perso cumul des rechargements < 30 E and >= 10E",
	  "Cpp_cumul_credit = 12.00E, Opt_info2 = 50.00E",
	  {ussd2,
  	   [ 
 	     {send, "#123*2*1*2#"},
 	     {expect,"Rechargements cumules depuis le ../../..: .*12.00E. Au ../../.. vous beneficierez du bonus:.*1:Suite"},
	     {send, "1"},
	     {expect, "Il vous manque 8.0E pour beneficier du bonus.*"}
  	    ]}]++

  	init_cumul_rechargement(40)++
 	set_list_options(?Uid,[#option{top_num=435,
				       opt_info2="10"}])++
  	[ "Test Suivi Conso recharge - avec perso cumul des rechargements >= 30E",
	  "Cpp_cumul_credit = 40.00E, Opt_info2 = 10.00E",
	  {ussd2,
  	   [
 	    {send, "#123*2*1*2#"},
 	    {expect,"Rechargements cumules depuis.*30.00E"}
 	   ]}]++
	[];
test_sv_recharge(_) ->["OK"].

test_options_promo(Type) ->
    set_list_comptes(?Uid,[compte(?C_PRINC,15,01),compte(?C_BONS_PLANS,15,01)])++
	set_list_options(?Uid,[#option{top_num=435}])++
 	[ "Test options/promo - "++atom_to_list(Type)] ++
  	[ {ussd2,
 	   [
	    {send, "#123*2*2*1"},
	    {expect, ".*"}
	   ]}]++
 	[].

test_choisir() ->
    {Y,M,Day}=date(),
    set_list_comptes(?Uid,[compte(?C_PRINC,50,27)])++
	set_list_options(?Uid,[])++
	test_util_of:set_parameter_for_test(recharge_janus_date,[Day+1])++
	["MENU choisir bonus"] ++
	[{ussd2,
	  [ 
	    {send, "#123*2*3#"},
	    {expect,"Envie d'appels offerts, de SMS ou d'internet?.*"
	     "Choisissez votre bonus:.*"
	     "1:Bonus appels.*"
	     "2:Bonus SMS.*"
	     "3:Bonus internet.*"
	     "4:Bonus international.*"
	     "5:Conditions.*"}
	   ]}]++
	[ "Choisir Bonus Appels"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*1#"},
	     {expect,"Avec le bonus appels.*beneficiez de 20 a 80 min d'appels offerts.*"
	      "1:S'inscrire.*"
	      "2:\\+d'infos.*"},
	     {send, "1"},
	     {expect, "Vous avez choisi le Bonus appels.*1:Confirmer"},
	     {send, "1"},
	     {expect, "Bonus appels enregistre..*"
	      "La date anniversaire de votre bonus est le .. de chaque mois..*"
	      "Prochain bonus a partir du ../.. si vous rechargez au moins 10E avant cette date..*"
	      "1:Suite"},
	     {send, "1"},
	     {expect, "C'est automatique : a partir de 10E de recharges cumulees jusqu'au .. de chaque mois, vous beneficiez de 20 a 80 mn d'appels offerts le mois suivant..*"
	      "1:Suite"},
	     {send, "1"},
	     {expect, "De 10E a 19,99E recharges dans le mois, 20mn offertes le mois suivant!.*"
	      "De 20E a 29,99E, 40mn offertes!.*"
	      "et pour 30E ou \\+, 80mn offertes!.*"
	      "Usages en France metrop"}
	    ]}]++
	set_list_options(?Uid,[])++
	[ "Choisir Bonus SMS"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*2#"},
	     {expect,"Avec le bonus SMS, a partir de 10E recharges dans le mois, beneficiez de, au minimum.*"
	      "100 SMS offerts.*1:S'inscrire.*2:\\+d'infos.*"},
	     {send, "1"},
	     {expect, "Vous avez choisi le Bonus SMS.*1:Confirmer"},
	     {send, "1"},
	     {expect, "Bonus SMS enregistre..*"
	      "La date anniversaire de votre bonus est le .. de chaque mois..*"
	      "Prochain bonus a partir du ../.. si vous rechargez au moins 10E avant cette date..*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "C'est automatique : a partir de 10E de recharges cumulees jusqu'au .. de chaque mois, vous beneficiez de 100 SMS au minimum offerts le mois suivant..*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "De 10E a 19,99E recharges dans le mois, 100 SMS offerts le mois suivant!.*"
	      "De 20E a 29,99E, 200 SMS offerts!.*"
	      "30E ou \\+, SMS illimites offerts!.*"
	      "Usages en France metrop"}
	    ]}]++

	set_list_options(?Uid,[])++
	[ "Choisir Bonus Internet"] ++
	[ {ussd2,
	   [
	    {send, "#123*2*1*1*3"},
	    {expect,"Avec le bonus internet : a partir de 10E recharges beneficiez de 1h a 4h d'internet.*"
             "1:S'inscrire.*"
	     "2:\\+d'infos.*"},
	    {send, "1"},
	    {expect, "Vous avez choisi le Bonus internet..*1:Confirmer"},
	    {send, "1"},
	    {expect, "Bonus internet enregistre..*"
	     "La date anniversaire de votre bonus est le .. de chaque mois..*"
	     "Prochain bonus a partir du ../.. si vous rechargez au moins 10E avant cette date..*"
	     "1:Suite"},
	    {send, "1"},
	    {expect, "C'est automatique: a partir de 10E de recharges cumulees jusqu'au .. de chaque mois,vous beneficiez de 1h a 4h d'internet mobile offertes le mois suivant..*"
	     "1:Suite"},
	    {send, "1"},
	    {expect, "De 10E a 19,99E recharges dans le mois, 1h d'internet offerte le mois suivant!.*"
	     "De 20E a 29,99E, 2h offertes!.*"
	     "et pour 30E ou \\+, 4h offertes!.*"
	     "Usages en France metrop"}
	   ]}]++

	set_list_options(?Uid,[])++
	[ "Choisir Bonus International"] ++
	[ {ussd2,
	   [ {send, "#123*2*1*1*4#"},
	     {expect,"Avec le bonus international.*"
	      "1:Europe.*"
	      "2:Maghreb.*"},
	     {send, "1"},
	     {expect, "Vous avez choisi le Bonus international : Europe.*"
	      "1:Confirmer.*"
	      "2:Liste des pays.*"
	      "3:\\+d'infos"},
	     {send, "1"},
	     {expect, "Bonus Europe enregistre..*"
	      "La date anniversaire de votre bonus est le .. de chaque mois..*"
	      "Prochain bonus a partir du ../.. si vous rechargez au moins 10E avant cette date..*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "C'est automatique: a partir de 10E de recharges cumulees jusqu'au .. de chaque mois,vous beneficiez de 10 a 40 min offertes....*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "...d'appels vers et depuis l'Europe  le mois suivant..*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "De 10E a 19,99E recharges dans le mois, 10 min d'appels offertes le mois suivant!.*"
	      "De 20E a 29,99E, 20 min offertes!.*"
	      "et pour 30E ou \\+, 40 min offertes!"},
	     {send, "88882"},
	     {expect, "Allemagne, Andorre, Autriche, Baleares, Belgique, Bulgarie, Canaries, Chypre, Danemark.*1:Suite"},
	     {send, "1"},
	     {expect, "Italie, Luxembourg, Martinique, Norvege, Pays-Bas, Pologne, Portugal, Reunion, Roumanie, Royaume-Uni"},
	     {send, "883"},
	     {expect, "Bonus decompte a la seconde apres une 1ere minute indivisible. Appels depuis.*1:Suite"},
	     {send, "1"},
	     {expect, "...et depuis les pays de la zone Europe vers la France Metro et vers les pays de la zone choisie"},
	     {send, "8882"},
	     {expect, "Vous avez choisi le bonus international : Maghreb \\(Maroc, Algerie et Tunisie\\).*"
	      "1:Confirmer.*"
	      "2:\\+d'infos"},
	     {send,"1"},
	     {expect, "Bonus Maghreb enregistre..*"
	      "La date anniversaire de votre bonus est le .. de chaque mois..*"
	      "Prochain bonus a partir du ../.. si vous rechargez au moins 10E avant cette date..*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "C'est automatique: a partir de 10E de recharges cumulees jusqu'au .. de chaque mois,vous beneficiez de 10 a 40 min offertes....*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "d'appels vers et depuis le Maghreb le mois suivant..*"
	      "1:Suite"},
	     {send, "1"},
             {expect, "De 10E a 19,99E recharges dans le mois, 10 min d'appels offertes le mois suivant!.*"
	      "De 20E a 29,99E, 20 min offertes!.*"
	      "et pour 30E ou \\+, 40 min offertes!"},
	     {send,"88882"},
	     {expect, "Bonus decompte a la seconde apres une 1ere minute indivisible.*1:Suite"},
	     {send, "1"},
	     {expect, ". et depuis les pays du Maghreb vers la France Metro et vers les pays de la zone choisie"}
	    ]}]++

	set_list_options(?Uid,[])++
	[ "Choisir Conditions"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*5#"},
	     {expect,"A chacun ses envies, a chacun son bonus! Choisissez votre bonus et chaque mois, profitez-en selon.*"
	      "le montant recharge le mois precedent.*" 
	      "1:Suite"},
	     {send, "1"},
	     {expect, "A partir de 10E recharges, beneficiez d'appels en France ou a l'etranger, de SMS, ou d'internet.*"
	      "selon le bonus choisi"}
	    ]}]++
        [].

%% Test choisir bonus will be invalid from 14/02/2010 
test_choisir_promo() ->
    {Y,M,Day}=date(),
    test_util_of:set_parameter_for_test(
      commercial_date,[{mobi_janus_promo,[test_util_of:get_present_period()]},
 		       {user_janus_promo,[test_util_of:get_present_period()]}])++
 	test_util_of:set_parameter_for_test(recharge_janus_date,[Day+1])++
 	set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
 				       unt_num=?EURO,
 				       cpp_solde=0,
 				       dlv=pbutil:unixtime(),
 				       rnv=21,
 				       etat=?CETAT_EP,
 				       ptf_num=?PCLAS_V2}])++
 	profile_manager:update_user_state(?Uid,{d_activ,lt2unixt({date(),{23,59,59}})})++
 	["Choisir bonus promo: account epuise"] ++
	[ {ussd2,
 	   [
 	    {send, "#123*2#"},
 	    {expect,"3:choisir bonus promo"},
 	    {send,"3"},
 	    {expect,"Votre credit doit etre >0E pour choisir votre bonus et beneficier de votre promotion"}
 	   ]}]++
 	set_list_comptes(?Uid,[compte(?C_PRINC,50,27)])++
 	[ "MENU choisir bonus promo"] ++
 	[ {ussd2,
  	   [ {send, "#123*2#"},
  	     {expect,"3:choisir bonus promo"},
  	     {send,"3"},
  	     {expect,"Promo: choisissez avant le 13/02 et beneficiez le 1er mois du bonus MAX.."
  	      "1:Bonus appels."
  	      "2:Bonus SMS."
  	      "3:Bonus internet."
  	      "4:Bonus international."
  	      "5:Conditions"}
  	    ]}]++
 	set_list_options(?Uid,[])++
 	[ "Choisir Bonus Appels promo"] ++
 	[ {ussd2,
  	   [ {send, "#123*2*3*1#"},
  	     {expect,"80mn offertes le 1er mois! puis a partir de 10E recharges dans le mois beneficiez de 20 a 80mn d'appels offerts le mois suivant.."
  	      "1:S'inscrire."
  	      "2:.d'infos"
  	      ""},
  	     {send, "1"},
  	     {expect, "Vous avez choisi le Bonus appels.*1:Confirmer"},
  	     {send, "1"},
  	     {expect, "Votre inscription a bien ete prise en compte."}
  	    ]}]++
 	set_list_options(?Uid,[])++
  	[ "Choisir Bonus SMS promo"] ++
  	[ {ussd2,
  	   [ {send, "#123*2*3*2#"},
  	     {expect,"SMS illimites le 1er mois! puis a partir de 10E recharges dans le mois beneficiez au minimum de 100 SMS offerts le mois suivant.."
  	      "1:S'inscrire."
  	      "2:.d'infos"},
  	     {send, "1"},
  	     {expect, "Vous avez choisi le Bonus SMS.*1:Confirmer"},
  	     {send, "1"},
  	     {expect, "Votre inscription a bien ete prise en compte."}
  	    ]}]++
 	set_list_options(?Uid,[])++
  	[ "Choisir Bonus Internet promo"] ++
  	[ {ussd2,
  	   [ {send, "#123*2*3*3#"},
  	     {expect,"4h d'internet mobile offertes le 1er mois! puis a partir de 10E recharges beneficiez de 1h a 4h offertes le mois suivant.."
	      "1:S'inscrire.*"
  	      "2:\\+d'infos.*"},
  	     {send, "1"},
  	     {expect, "Vous avez choisi le Bonus internet..*1:Confirmer"},
  	     {send, "1"},
  	     {expect, "Votre inscription a bien ete prise en compte."}
  	    ]}]++
 	set_list_options(?Uid,[])++
  	[ "Choisir Bonus International promo"] ++
  	[ {ussd2,
  	   [ {send, "#123*2*3*4#"},
  	     {expect,"40mn offertes le 1er mois! puis a partir de 10E recharges, de 10 a 40mn d'appels offerts.*"
  	      "1:Europe.*"
  	      "2:Maghreb.*"},
  	     {send, "1"},
  	     {expect, "Vous avez choisi le Bonus international : Europe.*"
  	      "1:Confirmer.*"
  	      "2:Liste des pays.*"
  	      "3:\\+d'infos"},
  	     {send, "1"},
  	     {expect, "Votre inscription a bien ete prise en compte"},
  	     {send, "82"},
  	     {expect, "Allemagne, Andorre, Autriche, Baleares, Belgique, Bulgarie, Canaries, Chypre, Danemark.*1:Suite"},
  	     {send, "1"},
  	     {expect, "Italie, Luxembourg, Martinique, Norvege, Pays-Bas, Pologne, Portugal, Reunion, Roumanie, Royaume-Uni"},
  	     {send, "883"},
  	     {expect, "Bonus decompte a la seconde apres une 1ere minute indivisible. Appels depuis.*1:Suite"},
  	     {send, "1"},
  	     {expect, "...et depuis les pays de la zone Europe vers la France Metro et vers les pays de la zone choisie"},
  	     {send, "8882"},
  	     {expect, "Vous avez choisi le bonus international : Maghreb \\(Maroc, Algerie et Tunisie\\).*"
  	      "1:Confirmer.*"
  	      "2:\\+d'infos"},
  	     {send,"1"},
  	     {expect, "Votre inscription a bien ete prise en compte.*"
 	      "Rechargez des maintenant 10E ou \\+ et beneficiez de 10 a 40min d'appels"
 	      " vers et depuis le Maghreb a partir du ../...*"},
  	     {send,"82"},
  	     {expect, "Bonus decompte a la seconde apres une 1ere minute indivisible.*1:Suite"},
  	     {send, "1"},
  	     {expect, ". et depuis les pays du Maghreb vers la France Metro et vers les pays de la zone choisie"}
  	    ]}]++
 	set_list_options(?Uid,[])++
  	[ "Choisir Condition promo"] ++
  	[ {ussd2,
  	   [ {send, "#123*2*3*5#"},
  	     {expect,"A chacun ses envies, a chacun son bonus! Choisissez votre bonus et chaque mois, profitez-en selon.*"
  	      "le montant recharge.*" 
  	      "1:Suite"},
  	     {send, "1"},
  	     {expect, "A partir de 10E recharges, beneficiez d'appels en France ou a l'etranger, de SMS, ou d'internet.*"
  	      "selon le bonus choisi"}
  	    ]}]++
 	set_list_options(?Uid,[#option{top_num=435}])++
 	[ "Promo noel: Changer without resiliation"] ++
	[ {ussd2,
	   [ {send, "#123*2*3#"},
	     {expect,"1:Bonus appels."
 	      "2:Bonus SMS."
 	      "3:Bonus internet."
 	      "4:Bonus international."
 	      "5:Conditions"}
	    ]}]++
	[].

test_changer() ->
    test_changer([opt_bonus_appels,
  		  opt_bonus_sms,
  		  opt_bonus_internet,
  		  opt_bonus_europe,
  		  opt_bonus_maghreb
		 ])++
 	test_resilier_bonus([opt_bonus_appels,
 			     opt_bonus_sms,
 			     opt_bonus_internet,
 			     opt_bonus_europe,
 			     opt_bonus_maghreb
 			    ])++
	[].

test_changer([])->[];
test_changer([Opt|T]) ->
    set_list_comptes(?Uid,[compte(?C_PRINC,50,01),compte(?C_MOBI_BONUS_SMS,50,01)])++
	case Opt of
	    opt_bonus_appels->
		set_list_options(?Uid,[#option{top_num=435}]);
	    opt_bonus_sms ->
		set_list_options(?Uid,[#option{top_num=436}]);
	    opt_bonus_internet ->
		set_list_options(?Uid,[#option{top_num=437}]);
	    opt_bonus_europe ->
		set_list_options(?Uid,[#option{top_num=438},#option{top_num=439}]);
	    _ ->
		set_list_options(?Uid,[#option{top_num=438},#option{top_num=440}])
	end++
	test_util_of:set_past_period_for_test(commercial_date,[user_janus_promo])++

	["Test changing to bonus " ++ atom_to_list(Opt)]++
 	[ {ussd2,
	   [ 
	     {send, "#123*2#"},
	     {expect,"3:changer bonus"},
	     {send,"3"},
	     {expect,"1:Bonus appels.*"
	      "2:Bonus SMS.*"
	      "3:Bonus internet.*"
	      "4:Bonus international.*"
	      "5:Resilier votre bonus.*"
	      "6:Conditions"},
	     {send,link_to_bonus(Opt)},
	     {expect,expect_text(Opt, 1)},

	     case Opt of
		 opt_bonus_maghreb ->
		     {send, "2"};
		 _ ->
		     {send, "1"}
	     end,

	     {expect,expect_text(Opt, 2)},
	     {send,"1"},
	     {expect,expect_text(Opt, 3)},
             {send,"1"},
	     {expect,expect_text(Opt, 4)},
             {send,"1"},
	     {expect,expect_text(Opt, 5)}
	    ]}]++
	test_changer(T)++
	[].
%% From 19/11/2009 - link resilier bonus was not proposed
test_resilier_bonus([Opt|T]) ->
    case Opt of
	opt_bonus_sms->
	    set_list_comptes(?Uid,[compte(?C_PRINC,50,01),compte(?C_MOBI_BONUS_SMS,50,01)]);
	_->
	    set_list_comptes(?Uid,[compte(?C_PRINC,50,01),compte(?C_MOBI_BONUS,50,01)])
    end++
	case Opt of
	    X when X==opt_bonus_appels;opt_bonus_sms;opt_bonus_internet->
		set_list_options(?Uid,[#option{top_num=svc_options:top_num(Opt,mobi)}]);
	    _ ->
		set_list_options(?Uid,[#option{top_num=438},#option{top_num=svc_options:top_num(Opt,mobi)}])
	end++
	test_util_of:set_past_period_for_test(commercial_date,[user_janus_promo])++

	["Test resilier bonus " ++ atom_to_list(Opt)]++
 	[ {ussd2,
	   [ 
	     {send, "#123*2#"},
	     {expect,"3:changer bonus"},
	     {send,"3"},
	     {expect,"1:Bonus appels.*"
	      "2:Bonus SMS.*"
	      "3:Bonus internet.*"
	      "4:Bonus international.*"
	      "5:Resilier votre bonus.*"
	      "6:Conditions"},
	     {send,"5"},
	     {expect,"1:Confirmer"},
	     {send,"1"},
	     {expect,"Votre desinscription a bien ete prise en compte."}
	    ]}]++
	test_changer(T)++
	[].

link_to_bonus(Opt)->
    case Opt of
	opt_bonus_appels->"1";
	opt_bonus_sms->"2";
	opt_bonus_internet->"3";
	opt_bonus_europe->"4";
	opt_bonus_maghreb->"4"
    end.

expect_text(Opt, 1)->
    case Opt of
        opt_bonus_appels->
            "Avec le Bonus appels: a partir de 10E recharges dans le mois, beneficiez de 20 a 80 min d'appels offerts le mois suivant.*"
		"1:S'inscrire.*"
		"2:\\+d'infos";
	opt_bonus_sms->
            "Avec le Bonus SMS: a partir de 10E recharges dans le mois, beneficiez de, au minimum, 100 SMS offerts le mois suivant.*"
		"1:S'inscrire.*"
		"2:\\+d'infos";
        opt_bonus_internet->
            "Avec le Bonus internet: a partir de 10E recharges, de 1h a 4h d'internet mobile offertes le mois suivant.*"
		"1:S'inscrire.*"
		"2:\\+d'infos";
        X when X==opt_bonus_europe;X==opt_bonus_maghreb->
            "Avec le Bonus international: a partir de 10E recharges, de 10 a 40mn d'appels offerts le mois suivant vers et depuis ... au choix :.*"
		"1:Europe.*"
		"2:Maghreb"
    end;

expect_text(Opt, 2)->
    case Opt of
        opt_bonus_europe->
	    "Vous avez choisi le bonus Europe. Votre bonus en cours sera perdu et le compteur de rechargements du bonus remis a 0..*"
		"1:Confirmer.*"
		"2:Liste des pays.*"
		"3:\\+d'infos";
        opt_bonus_maghreb->
	    "Vous avez choisi le bonus Maghreb. Votre bonus en cours sera perdu et le compteur de rechargements du bonus remis a 0..*"
		"1:Confirmer.*"
                "2:Liste des pays.*"
                "3:\\+d'infos";
	_  ->
	    "Vous allez changer votre bonus..*"
                "Votre bonus en cours sera perdu et le compteur de rechargements du bonus remis a 0..*"
                "Faites Suite pour confirmer le changement..*"
                "1:Suite"
    end;

expect_text(_, 3)->
    "Vos 2 premiers changements de bonus sont gratuits, les suivants seront factures 3E par changement..*"
	"1:Confirmer maintenant votre changement";

expect_text(Opt, 4)->
    case Opt of
        opt_bonus_appels->
	    "Bonus appels enregistre..*";
	opt_bonus_sms->
	    "Bonus SMS enregistre..*";
        opt_bonus_internet->
	    "Bonus internet enregistre..*";
        opt_bonus_europe->
	    "Bonus Europe enregistre..*";
        opt_bonus_maghreb->
	    "Bonus Maghreb enregistre..*"
    end ++
	"La nouvelle date anniversaire de votre bonus est le .. de chaque mois..*"
	"Prochain bonus a partir du ../.. pour 10E recharges avant cette date..*"
	"1:Suite";

expect_text(Opt, 5)->
    case Opt of
        opt_bonus_appels->
	    "Bonus appels:.*"
		"De 10E a 19,99E recharges dans le mois, 20mn offertes le mois suivant!.*"
		"De 20E a 29,99E, 40mn offertes!.*"
		"30E ou\\+, 80mn offertes!.*"
		"Usages en France metrop";
	opt_bonus_sms->
	    "Bonus SMS:.*"
		"De 10E a 19,99E recharges dans le mois, 100 SMS offerts le mois suivant!.*"
		"De 20E a 29,99E, 200 SMS offerts!.*"
		"30E ou\\+, SMS illimites!.*"
		"Usages en France metro";
        opt_bonus_internet->
	    "Bonus internet:.*"
		"De 10 a 19,99E recharges dans le mois, 1h d'internet offerte le mois suivant!.*"
		"De 20 a 29,99E, 2h offertes!.*"
		"30E ou\\+, 4h offertes!.*"
		"Usage metropolitain";
        opt_bonus_europe->
	    "Bonus Europe :.*"
		"De 10E a 19,99E recharges dans le mois, 10 min d'appels offertes le mois suivant!.*"
		"De 20E a 29,99E, 20 min offertes!.*"
		"et pour 30E ou \\+, 40 min offertes!";
        opt_bonus_maghreb->
	    "Bonus Maghreb :.*"
		"De 10E a 19,99E recharges dans le mois, 10 min d'appels offertes le mois suivant!.*"
		"De 20E a 29,99E, 20 min offertes!.*"
		"et pour 30E ou \\+, 40 min offertes!"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Message used for X = decouvrir bonus menu %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text(cible) ->
    "En \\+ des bonus, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	"En vous inscrivant, vous renoncez a votre plan tarifaire actuel.*";
text(_) ->
    "Nous ne pouvons repondre a votre demande. Nous vous invitons a appeler le 220 \\(appel gratuit\\)".
test_s_inscrire_decouvir_bonus_kdo([])->    
    [];
test_s_inscrire_decouvir_bonus_kdo([TOP_NUM|T])->
    profile_manager:create_default(?Uid_classic,"mobi")++
	profile_manager:init(?Uid_classic)++
	set_list_comptes(?Uid_classic,[compte(?C_PRINC,40,0)])++
	set_list_options(?Uid_classic,[#option{top_num=TOP_NUM}])++
	[ "MENU decouvrir bonus - TOP_NUM =" ++ integer_to_list(TOP_NUM)] ++
	[ {ussd2,
	   [
	    {send, "#123#"},
	    {expect, ".*"},
	    {send, "2"},
	    {expect, ".*"},
	    {send, "5"},
	    {expect,"Envie d'un bonus appels, sms, internet ou international\\? Confirmez votre inscription et vous.*"
	     "pourrez choisir gratuitement votre bonus.*"
	     "1:S'inscrire.*"
	     "2:Plus d'infos.*"},
	    {send,"1"},
	    {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	     "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a l'illimite KDO.*"},
	    {send, "952"},
	    {expect, "decouvrez les bonus.*"
	     "1:Bonus appels.*"
	     "2:Bonus SMS.*"
	     "3:Bonus internet.*"
	     "4:Bonus international.*"
	     "5:Conditions"}
	   ]}]++
	[ "Decouvrir bonus appels"] ++
	[
	 {ussd2,
	  [
	   {send, "#123*2*5*2*1#"},
	   {expect, "Avec le Bonus appels: a partir de 10E recharges dans le mois.*"
	    "1:S'inscrire.*"
	    "2:\\+d'infos.*"},
	   {send, "1"},
	   {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	    "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a l'illimite KDO.*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "95212"},
	   {expect, "Bonus offert hors numeros speciaux, de services et en cours de portabilite.*"
	    "Appels directs entre personnes physiques et pour usage perso non lucratif"}]
	 }]++
	[ "Decouvrir bonus sms"] ++
	[ {ussd2,
	   [ {send, "#123*2*5*2*2#"},
	     {expect,"Avec le Bonus SMS: a partir de 10E recharges dans le mois, beneficiez de.*"
	      "au minimum, 100 SMS offerts.*"
	      "1:S'inscrire.*"
	      "2:\\+d'infos.*"},
	     {send, "1"},
	     {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	      "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a l'illimite KDO.*"},
	     {send, "1"},
	     {expect, ".*"},
	     {send, "95222"},
	     {expect, "SMS/MMS offerts en France Metro, hors sms/mms surtaxes, numeros courts et "
	      "MMS cartes postales.*1:Suite"},
	     {send, "1"},
	     {expect, "SMS/MMS entre personnes physiques et pour usage personel non lucratif, jusqu'a 200.*"
	      "destinataires differents"}
	    ]}]++
	[ "Decouvrir bonus internet"] ++
	[ {ussd2,
	   [ {send, "#123*2*5*2*3#"},
	     {expect,"Avec le Bonus internet: a partir de 10E recharges, de 1h a 4h d'internet mobile offertes.*"
	      "le mois suivant.*1:S'inscrire.*2:\\+d'infos.*"},
	     {send, "1"},
	     {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	      "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a l'illimite KDO.*"},
	     {send, "1"},
	     {expect, ".*"},
	     {send, "95232"},
	     {expect, "Bonus internet decompte a la min indivisible pour navigation sur portail OW, Gallery et internet.*"
	      "consultation videos, rubriques actualite, cinema, sport.*1:Suite"},
	     {send, "1"},
	     {expect, "et mes communautes sur le portail OW. Les usages mail \\(smtp, pop, imap\\) et modem, contenus.*"
	      "et les services payants non inclus. Usages en France metro....*1:Suite"},
	     {send, "1"},
	     {expect, "Services de Voix surIP, P2P, Newsgroups interdits. Services sur reseaux et terminal compatibles.*"
	      "Le piratage nuit a la creation artistique. \\+d'infos sur orange.fr.*"}
	    ]}]++
	[ "Decouvrir Bonus International"] ++
	[ {ussd2,
	   [ {send, "#123*2*5*2*4#"},
	     {expect,"a partir de 10E recharges, de 10 a 40mn d'appels offerts le mois suivant vers.*"
	      "et depuis l'Europe ou le Maghreb.*1:S'inscrire.*2:\\+d'infos"},
	     {send, "1"},
	     {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	      "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a l'illimite KDO.*"},
	     {send, "1"},
	     {expect, ".*"},
	     {send, "95242"},
	     {expect, "Bonus decompte a la seconde apres une 1ere minute indivisible. Appels depuis la France Metro.*"
	      "vers la zone.*1:Suite"},
	     {send, "1"},
	     {expect, "et depuis les pays de la zone Europe vers la France Metro et vers les pays de la zone choisie.*"
	      "Les autres com. decomptees du compte principal au tarif en vigueur"}
	    ]}]++
	[ "Decouvrir Bonus Conditions"] ++
	[ {ussd2,
	   [ {send, "#123*2*5*2*5#"},
	     {expect,"Beneficiez du bonus choisi tous les mois en fonction de votre cumul recharge \\(a partir "
	      "de 10E, hors credit offert\\) le mois precedent"}
	    ]}]++
	test_s_inscrire_decouvir_bonus_kdo(T) ++
	[].


test_s_inscrire_decouvir_bonus_dte()->
    profile_manager:create_default(?Uid_classic,"mobi")++
	profile_manager:init(?Uid_classic)++
	set_list_comptes(?Uid_classic,[compte(?C_PRINC,40,0)])++
	set_list_options(?Uid_classic,[#option{top_num=7}])++
	[ "MENU decouvrir bonus -DTE"] ++
	[ {ussd2,
	   [
	    {send, "#123#"},
	    {expect, ".*"},
	    {send, "2"},
	    {expect, ".*"},
	    {send, "3"},
	    {expect,"Envie d'un bonus appels, sms, internet ou international\\? Confirmez votre inscription et vous.*"
	     "pourrez choisir gratuitement votre bonus.*"
	     "1:S'inscrire.*"
	     "2:Plus d'infos.*"},
	    {send, "1"},
	    {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	     "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a du Temps en Plus.*"},
	    {send, "932"},
	    {expect, "decouvrez les bonus.*"
	     "1:Bonus appels.*"
	     "2:Bonus SMS.*"
	     "3:Bonus internet.*"
	     "4:Bonus international.*"
	     "5:Conditions"}
	   ]}]++
	[ "Decouvrir bonus appels"] ++
	[
	 {ussd2,
	  [
	   {send, "#123*2*3*2*1#"},
	   {expect, "Avec le Bonus appels: a partir de 10E recharges dans le mois.*"
	    "1:S'inscrire.*"
	    "2:\\+d'infos.*"},
	   {send, "1"},
	   {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	    "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a du Temps en Plus.*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "93212"},
	   {expect, "Bonus offert hors numeros speciaux, de services et en cours de portabilite.*"
	    "Appels directs entre personnes physiques et pour usage perso non lucratif"}]
	 }]++
	[ "Decouvrir bonus sms"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*2*2#"},
	     {expect,"Avec le Bonus SMS: a partir de 10E recharges dans le mois, beneficiez de.*"
	      "au minimum, 100 SMS offerts.*"
	      "1:S'inscrire.*"
	      "2:\\+d'infos.*"},
	     {send, "1"},
	     {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	      "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a du Temps en Plus.*"},
	     {send, "1"},
	     {expect, ".*"},
	     {send, "93222"},
	     {expect, "SMS/MMS offerts en France Metro, hors sms/mms surtaxes, numeros courts et "
	      "MMS cartes postales.*1:Suite"},
	     {send, "1"},
	     {expect, "SMS/MMS entre personnes physiques et pour usage personel non lucratif, jusqu'a 200.*"
	      "destinataires differents"}
	    ]}]++
	[ "Decouvrir bonus internet"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*2*3#"},
	     {expect,"Avec le Bonus internet: a partir de 10E recharges, de 1h a 4h d'internet mobile offertes.*"
	      "le mois suivant.*1:S'inscrire.*2:\\+d'infos.*"},
	     {send, "1"},
	     {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	      "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a du Temps en Plus.*"},
	     {send, "1"},
	     {expect, ".*"},
	     {send, "93232"},
	     {expect, "Bonus internet decompte a la min indivisible pour navigation sur portail OW, Gallery et internet.*"
	      "consultation videos, rubriques actualite, cinema, sport.*1:Suite"},
	     {send, "1"},
	     {expect, "et mes communautes sur le portail OW. Les usages mail \\(smtp, pop, imap\\) et modem, contenus.*"
	      "et les services payants non inclus. Usages en France metro....*1:Suite"},
	     {send, "1"},
	     {expect, "Services de Voix surIP, P2P, Newsgroups interdits. Services sur reseaux et terminal compatibles.*"
	      "Le piratage nuit a la creation artistique. \\+d'infos sur orange.fr.*"}
	    ]}]++
	[ "Decouvrir Bonus International"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*2*4#"},
	     {expect,"a partir de 10E recharges, de 10 a 40mn d'appels offerts le mois suivant vers.*"
	      "et depuis l'Europe ou le Maghreb.*1:S'inscrire.*2:\\+d'infos"},
	     {send, "1"},
	     {expect, "En \\+, profitez de vos appels a 0,50E/min et du SMS a 0,12E.*"
	      "En vous inscrivant, vous renoncez a votre plan tarifaire actuel et a du Temps en Plus.*"},
	     {send, "1"},
	     {expect, ".*"},
	     {send, "93242"},
	     {expect, "Bonus decompte a la seconde apres une 1ere minute indivisible. Appels depuis la France Metro.*"
	      "vers la zone.*1:Suite"},
	     {send, "1"},
	     {expect, "et depuis les pays de la zone Europe vers la France Metro et vers les pays de la zone choisie.*"
	      "Les autres com. decomptees du compte principal au tarif en vigueur"}
	    ]}]++
	[ "Decouvrir Bonus Conditions"] ++
	[ {ussd2,
	   [ {send, "#123*2*3*2*5#"},
	     {expect,"Beneficiez du bonus choisi tous les mois en fonction de votre cumul recharge \\(a partir "
	      "de 10E, hors credit offert\\) le mois precedent"}
	    ]}]++
	[].

test_decouvrir(Type) ->
    test_util_of:set_parameter_for_test(type_decouvrir_bonus, atom_to_list(Type)) ++
	case Type of 
	    non -> 
		["OK"];
	    _ ->
		test_s_inscrire_decouvir_bonus_kdo([127,135,166]) ++
		    test_s_inscrire_decouvir_bonus_dte()++
		    []
	end.

set_list_comptes(Uid,Comptes)->
    profile_manager:set_list_comptes(Uid,Comptes).

set_list_options(Uid,Options)->
    profile_manager:set_list_options(Uid,Options).

compte(Compte,CPP_SOLDE,RNV_NUM)->
    #compte{tcp_num=Compte, 	 
	    unt_num=?EURO, 	 
	    cpp_solde=1000*CPP_SOLDE, 	 
	    dlv=pbutil:unixtime(), 	 
	    rnv=RNV_NUM, 	 
	    etat=?CETAT_AC, 	 
	    ptf_num=?PCLAS_V2}.
lt2unixt(LT) -> test_util_of:lt2unixt(LT).

init_cumul_rechargement(CUMUL)->
    set_list_comptes(?Uid,
		     [#compte{tcp_num=?C_PRINC,
			      unt_num=?EURO,
			      cpp_solde=1000,
			      cpp_cumul_credit=CUMUL*500,
			      dlv=pbutil:unixtime(),
			      rnv=0,
			      etat=?CETAT_AC,
			      ptf_num=328},
 		      #compte{tcp_num=?C_E_RECHARGE,
			      unt_num=?EURO,
			      cpp_solde=1000,
			      cpp_cumul_credit=CUMUL*500,
			      dlv=pbutil:unixtime(),
			      rnv=0,
			      etat=?CETAT_AC,
			      ptf_num=328},
		      #compte{tcp_num=?C_MOBI_BONUS,
			      unt_num=?EURO,
			      cpp_solde=10000,
			      dlv=pbutil:unixtime(),
			      rnv=0,
			      etat=?CETAT_AC,
			      ptf_num=328}]).
