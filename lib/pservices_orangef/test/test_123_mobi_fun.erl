-module(test_123_mobi_fun).
-compile([export_all]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(PARENT, test_123_mobi_homepage).
-define(CODE_MENU, "#123*2#").
-define(Uid, user_mobi_fun).
code_fun(DCL) ->
    case DCL of
        ?OM_mobile->
            test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu,?foot_variable_x,?foot_variable_y]);
	?ASSE_mobile->
            test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu,?foot_variable_x,?foot_variable_y]);
	?m6_prepaid ->
            test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu]);
        ?umobile ->
            test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu]);
        ?click_mobi ->
	    test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu,?foot_variable_y]);
        ?mobi ->
            test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu,?foot_variable_x]);
        _ ->
            test_util_of:link_rank(?PARENT, ?menu_page, ?'fun',[?suivi_conso_plus_menu])
    end.

text_menu_fun()->
    "1:Pass sonneries Hi-Fi."
	"2:Pass Jeux."
	"3:Tonalites."
	"4:Service Chat."
	"5:Jeux par SMS."
	"6:Cartes Postales MMS".
text_menu_fun(sonneries)->
    "Avec le pass sonneries Hi-Fi, beneficiez de 30% de reduction et telechargez 1 sonnerie par mois pour 2E au lieu de 3E.*"
	"1:Suite."
	"2:Accedez au pass sonneries."
	"3:Conditions";
text_menu_fun(jeux)->
    "Decouvrez le pass jeux,pour seulement 3E par mois,telechargez un nouveau jeu par mois \\(dans la selection de la.*"
	"1:Suite."
	"2:Accedez au pass jeux."
	"3:Conditions";
text_menu_fun(funtones)->
    "Decouvrez le service Tonalites!Ceux qui vous appellent entendent votre musique preferee qd votre mobile sonne."
	"1:Suite."
	"2:Accedez a Tonalites.".

text_fin(sonneries)->
    "Dans quelques instants, vous allez etre redirige vers Orange World sur la page du pass Sonneries Hi-Fi.*";
text_fin(jeux)->
    "Dans quelques instants, vous allez etre redirige vers Orange World sur la page du pass Jeux.*";
text_fin(chat) ->
    "Bienvenue sur le Chat Orange ";
text_fin(sms_games) ->
    "Ce service est actuellement ferme..*";
text_fin(funtones) ->
    "Dans quelques instants, vous allez etre redirige vers Orange World sur le service Tonalites";
text_fin(carte_postale) ->
    "".

menu_link(sonneries)->
    "1";
menu_link(jeux)->
    "2";
menu_link(funtones)->
    "3";
menu_link(chat)->
    "4";
menu_link(sms_games)->
    "5";
menu_link(carte_postale)->
    "6".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop().

test()->
	test_util_of:set_present_period_for_test(commercial_date,[menu_fun]) ++

	menu_fun(sonneries, ?mobi) ++
 	menu_fun(sonneries, ?click_mobi) ++
 	menu_fun(sonneries, ?m6_prepaid) ++
 	menu_fun(sonneries, ?OM_mobile) ++
 	menu_fun(sonneries, ?umobile) ++

	menu_fun(jeux, ?mobi) ++
 	menu_fun(jeux, ?click_mobi) ++
 	menu_fun(jeux, ?m6_prepaid) ++
 	menu_fun(jeux, ?OM_mobile) ++
 	menu_fun(jeux, ?umobile) ++

	menu_fun(funtones, ?mobi) ++
 	menu_fun(funtones, ?click_mobi) ++
 	menu_fun(funtones, ?m6_prepaid) ++
 	menu_fun(funtones, ?OM_mobile) ++
 	menu_fun(funtones, ?umobile) ++

      	menu_fun_conditions(sonneries, ?mobi) ++
  	menu_fun_conditions(sonneries, ?click_mobi) ++
  	menu_fun_conditions(sonneries, ?m6_prepaid) ++
  	menu_fun_conditions(sonneries, ?OM_mobile) ++
  	menu_fun_conditions(sonneries, ?umobile) ++

     	menu_fun_conditions(jeux, ?mobi) ++
      	menu_fun_conditions(jeux, ?click_mobi) ++
   	menu_fun_conditions(jeux, ?m6_prepaid) ++
      	menu_fun_conditions(jeux, ?OM_mobile) ++
  	menu_fun_conditions(jeux, ?umobile) ++
	%% Close this test case in PC Jun 2010
%%      	menu_fun_conditions(funtones, ?mobi) ++
%%       	menu_fun_conditions(funtones, ?click_mobi) ++
%%    	menu_fun_conditions(funtones, ?m6_prepaid) ++
%%       	menu_fun_conditions(funtones, ?OM_mobile) ++
%%   	menu_fun_conditions(funtones, ?umobile) ++

     	menu_fun_redirect(chat, ?mobi) ++
     	menu_fun_redirect(sms_games, ?mobi) ++
     	menu_fun_redirect(carte_postale, ?mobi) ++

 	test_util_of:close_session() ++
	["Test reussi"].

menu_fun_redirect(Type, DCL) ->
	profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
        profile_manager:init(?Uid)++

	[ {title, "MENU FUN Mobicarte " ++ atom_to_list(Type)}] ++
 	[ {ussd2,
	   [ 
	     {send, ?CODE_MENU},
	     {expect,"Fun"},
	     {send, code_fun(DCL)},
	     {expect, text_menu_fun()},
	     {send,menu_link(Type)},
	     {expect, text_fin(Type)}
	    ]}] ++
 	test_util_of:close_session() ++
	[].

expect_text(Type, 1, DCL) ->
    case Type of
	sonneries ->
	    "Avec le pass sonneries Hi-Fi, beneficiez de 30% de reduction et telechargez 1 sonnerie par mois pour 2E au lieu de 3E..*"
		"1:Suite."
		"2:Accedez au pass sonneries."
		"3:Condition";
	jeux ->
	    "Decouvrez le pass jeux,pour seulement 3E par mois,telechargez un nouveau jeu par mois \\(dans la selection de la....*"
		"1:Suite."
		"2:Accedez au pass jeux."
		"3:Conditions";
        funtones ->
	    "Decouvrez le service Tonalites!Ceux qui vous appellent entendent votre musique preferee qd votre mobile sonne."
		"1:Suite."
		"2:Accedez a Tonalites."
    end;

expect_text(Type, 2, DCL) ->
    case Type of
	sonneries ->
	    case DCL of
		?mobi->
		    "Le pass est renouvele chaque mois. Attention, le cout de connexion au portail Orange World est a votre charge ou inclus dans les options multimedia: internet,.*1:Suite";
		X when X==?OM_mobile;X==?m6_prepaid->
		    "Le pass est renouvele chaque mois. Attention, le cout de connexion au portail Orange World est a votre charge ou inclus dans les options multimedia:.*1:Suite";
		?click_mobi->
		    "Le pass est renouvele chaque mois. Attention, le cout de connexion au portail Orange World est a votre charge ou inclus dans les options.*1:Suite";
		?umobile->
		    "Le pass est renouvele chaque mois. Le cout de connexion au portail Orange World est inclus dans les options multimedia: internet, internet max, musique, TV,.*1:Suite"
	    end;
	jeux ->
	    "zone 'pass jeux 3 euros'\\). Beneficiez aussi de 0,5E sur tous les autres jeux. Le pass est renouvele chaque mois. Attention le cout de connexion a.*1:Suite";
	funtones ->
	    "Le cout de connexion au portail Orange World est inclus dans les options multimedia: internet, internet max, musique, TV, TV max....*1:Suite"
    end;

expect_text(Type, 3, DCL) ->
    case Type of
	sonneries ->
	    case DCL of 
		?mobi->
		    "internet max, musique, TV, TV max. Mobiles compatibles necessaires..*1:Accedez au pass sonneries Hi-Fi";
		X when X==?OM_mobile;X==?m6_prepaid->
		    "internet, internet max, musique, TV, TV max. Mobiles compatibles necessaires.*1:Accedez au pass sonneries Hi-Fi";
		?click_mobi->
		    "multimedia: internet, internet max, musique, TV, TV max. Mobiles compatibles necessaires.*1:Accedez au pass sonneries Hi-Fi";
		?umobile->
		    "TV max ou reste a votre charge si vous n'avez pas ces options. Mobiles compatibles necessaires..*1:Accedez au pass sonneries Hi-Fi"
	    end;
	jeux ->
	    case DCL of
		X when X==?click_mobi;X==?OM_mobile;X==?m6_prepaid ->
		    "Orange World est a votre charge. Cout de connexion inclus dans les options multimedia: internet, internet max, musique,.*1:Accedez au pass jeux";
		?mobi ->
		    "Orange World est a votre charge. Cout de connexion inclus dans les options multimedia: internet, internet max,.*1:Accedez au pass jeux";
		?umobile ->"...Orange World est inclus dans les options multimedia: internet, internet max, musique, TV, TV max ou....*1:Suite"
	    end;
	funtones ->
	    "...ou est a votre charge si vous ne possedez pas une option \\(debite du compte principal dans ce cas\\). Mobiles compatibles necessaires.*1:Accedez a Tonalites"
    end;

expect_text(jeux, 4, ?umobile) ->
    "...est a votre charge si vous ne possedez pas une option \\(debite du compte principal dans ce cas\\). Mobiles compatibles Java necessaires..*1:Accedez au pass jeux".

menu_fun(Type, DCL) ->
	profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
	profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:init(?Uid)++

	[ {title, "MENU FUN - " ++ atom_to_list(Type) ++ " - DCL= " ++ integer_to_list(DCL)}] ++
	[ {ussd2,
	   [
	    {send, ?CODE_MENU},
	    {expect,"Fun"},
	    {send, code_fun(DCL)},
	    {expect, text_menu_fun()},
	    {send, menu_link(Type)},
	    {expect, expect_text(Type, 1, DCL)},
	    {send, "1"},
	    {expect, expect_text(Type, 2, DCL)},
	    {send, "1"},
	    {expect, expect_text(Type, 3, DCL)}
	   ] ++

	   case DCL of
	       ?umobile when Type==jeux ->
		   [
		    {send, "1"},
		    {expect, expect_text(Type, 4, DCL)}
		   ];
	       _ ->
		   []
	   end

	  }
	 ] ++
	test_util_of:close_session() ++
	[].


menu_fun_conditions(Type=sonneries, DCL) ->
	profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
	profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:init(?Uid)++

	[ {title, "MENU FUN Mobicarte - Conditions " ++ atom_to_list(Type)++ " - DCL= " ++ integer_to_list(DCL)}] ++
        [ {ussd2,
	   [
	    {send, ?CODE_MENU},
            {expect,"Fun"},
	    {send, code_fun(DCL)},
            {expect, text_menu_fun()},
            {send, menu_link(Type)},
            {expect, text_menu_fun(Type)},
	    {send, "3"},
            {expect,"Pass a souscrire et a utiliser en France metropolitaine sur le portail Orange World.1 sonnerie Hifi pour 2E/mois \\(hors couts de connexion au portail.*1:Suite"},
            {send, "1"},
            {expect,"Orange World\\). Pass reconduit chaque mois sauf a y mettre fin a tout moment sur le portail Orange World rubrique Mon compte.Credit preleve sur le.*1:Suite"},
	    {send, "1"},
            {expect,"le compte du client sous reserve d'un credit suffisant. Le pass sera suspendu dans le cas contraire. Le piratage nuit a la creation artistique."}
	   ]}
         ] ++
        test_util_of:close_session() ++
        [];

menu_fun_conditions(Type=jeux, DCL) ->
	profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
	profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:init(?Uid)++

	[ {title, "MENU FUN Mobicarte - Conditions " ++ atom_to_list(Type)++ " - DCL= " ++ integer_to_list(DCL)}] ++
        [ {ussd2,
	   [ 
	     {send, ?CODE_MENU},
	     {expect,"Fun"},
	     {send, code_fun(DCL)},
	     {expect, text_menu_fun()},
	     {send, menu_link(Type)},
	     {expect, text_menu_fun(Type)},
	     {send, "3"},
	     {expect,"Pass a souscrire et a utiliser en France metropolitaine sur le portail Orange World.Pour 3E \\(hors couts de connexion au portail,qui sont indiques sur.*1:Suite"},
	     {send, "1"},
	     {expect,"la fiche tarifaire en vigueur\\), vous avez le droit a 1 jeu par mois a choisir dans la rubrique \\\"Pass Jeux 3 euros\\\" ainsi qu'a 0,5E de reduction.*1:Suite"},
	     {send, "111"},
	     {expect,"L'option sera suspendue dans le cas contraire. Le piratage nuit a la creation artistique"}
	    ]}
         ] ++
        test_util_of:close_session() ++
        [];

menu_fun_conditions(Type=funtones, DCL) ->
	profile_manager:create_and_insert_default(?Uid,#test_profile{sub="mobi",dcl=DCL})++
	profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:init(?Uid)++
	
	[ {title, "MENU FUN Mobicarte - Conditions " ++ atom_to_list(Type)++ " - DCL= " ++ integer_to_list(DCL)}] ++
        [ {ussd2,
	   [
	    {send, ?CODE_MENU},
            {expect,"Fun"},
	    {send, code_fun(DCL)},
            {expect, text_menu_fun()},
            {send, menu_link(Type)},
            {expect, text_menu_fun(Type)},
            {send, "3"},
            {expect,"Achat de tonalite a l'acte \\(3E\\) avec validite de 6 mois. En cas d'inactivite durant 6 mois, le service sera desactive"}
           ]}
         ] ++
        test_util_of:close_session() ++
        [].
