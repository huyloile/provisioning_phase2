-module(test_svc_mipc).
-export([run/0, online/0]).
-include("../../pserver/include/page.hrl").
-include("profile_manager.hrl").
-include("../../pfront_orangef/include/mipc_vpbx_webserv.hrl").

-define(Uid,mipc_vpbx_user).

-define(service_code, "#147").
-define(ServiceName,"mipcvpbx").
-define(menu_2,
	"1:a mon bureau.*2:en deplacement.*3:en reunion.*4:en conges").

run()->
    ok.

online() ->
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,test()),
    [].

test()->
    [{title, "Test MIPC/VPBx"}] ++
        init_test(?Uid)++
   	test_homepage()++

	%% MIPC
 	empty_data()++
  	modify_response_identification(error_101,vpbx)++
  	modify_response_identification(success,mipc)++
       	test_get_situation_active(mipc)++
       	test_activate_situation(mipc)++
 	test_consulter_situation(mipc)++
 
 	%% VPBX
   	empty_data()++
   	modify_response_identification(error_101,mipc)++
   	modify_response_identification(success,vpbx)++
     	test_get_situation_active(vpbx)++
     	test_activate_situation(vpbx)++
   	test_consulter_situation(vpbx)++
	%%Session closing
	test_util_of:close_session() ++
	["Test reussi"] ++

        [].
test_homepage()->
    empty_data()++
	["Test Home page MIPC/VPBx"]++
 	[{title, "VPBX error"}]++
 	modify_response_identification(other_error,mipc)++
 	modify_response_identification(other_error,vpbx)++
 	[{ussd2,
           [{send,?service_code},
            {expect,homepage_text(failure)}]}]++

        init_test(?Uid)++
         modify_response_identification(error_101,mipc)++
         modify_response_identification(error_101,vpbx)++
 	[{title,"VPBX ERROR 101"}]++
         [{ussd2,
           [{send,?service_code},
            {expect,homepage_text(no_access)}]}]++

 	[{title,"VPBX NO SITUATION"}]++
 	modify_response_identification(no_situation,vpbx)++
 	[{ussd2,
           [{send,?service_code},
            {expect,homepage_text(no_situation)}]}]++
	test_util_of:close_session()++

 	[{title,"VPBX REQUEST SUCCESS"}]++
         modify_response_identification(success,vpbx)++
         [{ussd2,
           [{send,?service_code},
            {expect,homepage_text(success)}]}]++
	test_util_of:close_session()++

 	[{title,"VPBX PROFILE EXISTS"}]++
         [{ussd2,
           [{send,?service_code},
            {expect,homepage_text(success)}]}]++
	test_util_of:close_session()++

	[{title,"MIPC ERROR"}]++
	empty_data()++
	modify_response_identification(other_error,mipc)++
        [{ussd2,
          [{send,?service_code},
           {expect,homepage_text(failure)}]}]++
	test_util_of:close_session()++

	[{title,"MIPC NO SITUATION"}]++
        modify_response_identification(no_situation,mipc)++
        [{ussd2,
          [{send,?service_code},
           {expect,homepage_text(no_situation)}]}]++
	test_util_of:close_session()++

	[{title,"MIPC REQUEST SUCCESS"}]++
        modify_response_identification(success,mipc)++
        [{ussd2,
          [{send,?service_code},
           {expect,homepage_text(success)}]}]++
	test_util_of:close_session()++

	[{title,"MIPC PROFILE EXISTS"}]++
        [{ussd2,
          [{send,?service_code},
           {expect,homepage_text(success)}]}]++
	test_util_of:close_session()++
	[].

test_get_situation_active(Server)->
    [{title,"MIPC/VPBx get situation active ok"}]++
	modify_response_identification(success,Server)++
	[{ussd2,
	  [{send,?service_code},
	   {expect,"Ma joignabilite.*Votre situation active est: a mon bureau"}]
	 }]++
	test_util_of:close_session()++
 	modify_response_get_situation_active(success_with_accent,Server)++
 	[{ussd2,
 	  [{send,?service_code},
 	   {expect,"Ma joignabilite.*Votre situation active est: a mon beau libelle"}]
 	 }]++
	test_util_of:close_session()++
	modify_response_get_situation_active(error,Server)++
	[{title,"MIPC/VPBx get situation active nok"}]++
	[{ussd2,
	  [{send,?service_code},
	   {expect,"Ma joignabilite.*Aucune situation active"}]
	 }]++
        test_util_of:close_session()++
	[].

test_activate_situation(Server)->
        test_util_of:close_session()++
	modify_response_identification(success,Server)++
	[{title,"MIPC/VPBx afficher criteres"}]++
	[{ussd2,
 	  [{send,?service_code++"*1"},
           {expect,?menu_2},
           {send,"7"},
           {expect,"en formation"},
           {send,"8"},
           {expect,?menu_2},
           {send,"7"},
           {expect,"en formation"},
           {send,"1"},
           {expect,"Vous avez choisi la situation en formation"},
           {send,"2"},
           {expect,"Renvoi immediat vers 33611221124"}
	  ]}]++
	[{title,"MIPC/VPBx activate a situation ok"}]++
 	[{ussd2,
 	  [{send,?service_code++"*1"},
 	   {expect,?menu_2},
 	   {send,"7"},
 	   {expect,"en formation"},
 	   {send,"1"},
 	   {expect,"Vous avez choisi la situation en formation"},
 	   {send,"1"},
 	   {expect,"Votre situation active est: en formation"}
 	  ]
 	 }]++
	[{title,"MIPC/VPBx activate a situation nok"}]++
	modify_response_activate_situation(error,Server)++
	[{ussd2,
	  [{send,?service_code++"*1"},
	   {expect,?menu_2},
	   {send,"7"},
	   {expect,"en formation"},
	   {send,"1"},
	   {expect,"Vous avez choisi la situation en formation"},
	   {send,"1"},
	   {expect,"Service actuellement indisponible"}
	  ]
	 }]++
	[{title,"MIPC/VPBx activate a situation - Accueil"}]++
	modify_response_identification(success,Server)++
	[{ussd2,
	  [{send,?service_code++"*1"},
	   {expect,?menu_2},
	   {send,"9"},
	   {expect,"Ma joignabilite"}
	  ]
	 }]++
	[{title,"MIPC/VPBx activate a situation - Choice non disponible"}]++
	modify_response_activate_situation(error,Server)++
	[{ussd2,
	  [{send,?service_code++"*1"},
	   {expect,?menu_2},
	   {send,"7"},
	   {expect,".*"},
	   {send,"5"},
	   {expect,"Choix non disponible"}
	  ]
	 }]++
	modify_response_activate_situation(success,Server)++
        test_util_of:close_session()++
	[].

test_consulter_situation(Server)->
    [{title, "Homepage critere situation MIPC/VPBx "}]++
	empty_data()++
	modify_response_identification(success,Server)++	
	[{ussd2,
	  [{send,?service_code++"*2#"},
	   {expect,".*"},
	   {send, "2"},
	   {expect, "Renvoi immediat vers.*"},
	   {send, "1"},
	   %% verify that activation works from here too!
	   {expect, "Votre situation active est.*en deplacement"}
	  ]}]++
	modify_response_identification(success,Server)++	
        modify_response_consult_situation("I", Server)++
	[{ussd2,
	  [{send,?service_code++"*2#"},
	   {expect,".*"},
	   {send, "2"},
	   {expect, "Renvoi immediat vers assistant\\(e\\).*"
	    "Frederique.*Frederic.*interne"},
	   {send, "1"},
	   {expect,"Sauf"},
	   {send, "1"},
	   %% verify that activation works from here too!
	   {expect, "Votre situation active est.*en deplacement"}
	  ]}]++
        test_util_of:close_session()++
	modify_response_identification(success,Server)++	
        modify_response_consult_situation("RC", Server)++
	["Recherche contact"]++
	[{ussd2,
	  [{send,?service_code++"*2#"},
	   {expect,".*"},
	   {send, "3"},
	   {expect, "Recherche contact vers.*"
	    "0611221123.*"
	    "0111221124.*"
	    "0211221125.*"
	    "33311221126"},
	   {send, "1"},
	   %% verify that activation works from here too!
	   {expect, "Votre situation active est.*en reunion"}
	  ]}]++
        test_util_of:close_session()++
	modify_response_identification(success,Server)++	
        modify_response_consult_situation("C", Server)++
	["Renvoi conditionnel"]++
	[{ussd2,
	  [{send,?service_code++"*2#"},
	   {expect,".*"},
	   {send, "3"},
	   {expect, "Renvoi conditionnel vers.*"},
	   {send, "1"},
	   %% verify that activation works from here too!
	   {expect, "Votre situation active est.*en reunion"}
	  ]}]++
        test_util_of:close_session()++
	modify_response_identification(success,Server)++	
	["Renvoi conditionnel vers assistant(e)"]++
	[{ussd2,
	  [{send,?service_code++"*2#"},
	   {expect,".*"},
	   {send, "4"},
	   {expect, "Renvoi conditionnel vers.*"},
	   {send, "1"},
	   %% verify that activation works from here too!
	   {expect, "Votre situation active est.*en conges"}
	  ]}]++
        test_util_of:close_session()++
        modify_response_consult_situation("O", Server)++
        ["Renvoi occupation vers assistant(e)"]++
        [{ussd2,
          [{send,?service_code++"*2#"},
           {expect,".*"},
           {send, "3"},
           {expect, "Renvoi sur occupation vers.*"},
	   {send, "1"},
	   %% verify that activation works from here too!
	   {expect, "Votre situation active est.*en reunion"}
          ]}]++
        test_util_of:close_session()++
        modify_response_consult_situation("NR", Server)++
        ["Renvoi non response vers assistant(e)"]++
        [{ussd2,
          [{send,?service_code++"*2#"},
           {expect,".*"},
           {send, "7"},
	   {expect, "1:en formation"},
	   {send, "1"},
           {expect, "Renvoi sur non reponse vers.*"}
          ]}]++
	test_util_of:close_session()++
	["OK"].

-define(menu, 
 	"Ma joignabilite.*"
 	"1:Activer une situation.*"
 	"2:Criteres d'une situation.*"
 	"3:Aide").

homepage_text(Type)->
    case Type of
	no_situation ->
	    "Aucune situation parametree, parametrez vos situations depuis votre interface utilisateur.";
	no_access->
	    "Vous n'avez pas acces a ce service.";
	success ->
	    ?menu;
	failure ->
	    "Le service est momentanement interrompu. Veuillez recommencer ulterieurement.Merci."
    end.

modify_response_activate_situation(Param, Server)->
    Init_data=case Param of
		  success ->
                      #activerSituationResponse{
                          resultat=#resultat{codeRetour="0",commentaire="succes"}
                      };
		  _ ->
                      #activerSituationResponse{
                          resultat=#resultat{codeRetour="102",commentaire="Donne non trouvee: situation"}
                      }
	      end,
    setup(init_activate_situation,Init_data,Server).

modify_response_get_situation_active(Param, Server)->
    Init_data=case Param of
		  success ->
                      #situationActiveResponse{
                          resultat=#resultat{codeRetour="0",commentaire="succes"},
                          situationActive=#situation{idSituation="5",libelleSituation="a mon bureau"}
                      };
		  success_with_accent ->
                      #situationActiveResponse{
                          resultat=#resultat{codeRetour="0",commentaire="succes"},
                          situationActive=#situation{idSituation="5",libelleSituation="a mon beau libelle"}
                      };
		  _ ->
                      #situationActiveResponse{
                          resultat=#resultat{codeRetour="102",commentaire="Donne non trouvee: situation"},
                          situationActive=#situation{idSituation="5",libelleSituation="a mon bureau"}
                      }
	      end,
    setup(init_get_situation_active,Init_data,Server).
    
modify_response_identification(Param, Server)->
    TypeOffre=case Server of
		  mipc->"MIPC";
		  vpbx->"VPBX"
	      end,
    Init_data=case Param of
		  no_situation->
                      #consulterInformationsResponse{
                          resultat=#resultat{codeRetour="0",commentaire="Succes"},
                          reseau=#reseau{codeReseau="1",nomReseau="Orange"},
                          membre=#membre{nom="Simon",prenom="Roger", manager="true"},
                          nbSituationsParametrees="0",
                          typeOffre=TypeOffre};
		  success ->
                      #consulterInformationsResponse{
                          resultat=#resultat{codeRetour="0",commentaire="Succes"},
                          reseau=#reseau{codeReseau="1",nomReseau="Orange"},
                          membre=#membre{nom="Simon",prenom="Roger", manager="true"},
                          nbSituationsParametrees="4",
                          typeOffre=TypeOffre};
		  error_101 ->
                      #consulterInformationsResponse{
                          resultat=#resultat{codeRetour="101",commentaire="Donnee non trouvee"},
                          reseau=#reseau{codeReseau="1",nomReseau="Orange"},
                          membre=#membre{nom="Simon",prenom="Roger", manager="true"},
                          nbSituationsParametrees="0",
                          typeOffre=TypeOffre};
		  other_error ->
                      #consulterInformationsResponse{
                          resultat=#resultat{codeRetour="102",commentaire="Donnee trouvee mais pas de resultat"},
                          reseau=#reseau{codeReseau="1",nomReseau="Orange"},
                          membre=#membre{nom="Simon",prenom="Roger", manager="true"},
                          nbSituationsParametrees="0",
                          typeOffre=TypeOffre}
	      end,
    setup(init_identification,Init_data,Server).

modify_response_consult_situation(TypeRenvoi, Server)->
    TypeOffre=case Server of
		  mipc->"MIPC";
		  vpbx->"VPBX"
	      end,
     VersAssistante=#versAssistante{
         nom="Frederic",
         prenom="Frederique",
         numero="98434",
         typeAppel="I"},
     VersNumerosLibres_Obj=#versNumerosLibres{premierNumero="0611221123",listeNumeros=[{numero,"0111221124"},{numero,"0211221125"}],boiteVocale="33311221126"},
    Init_data=
    #consulterSituationResponse{
        resultat=#resultat{codeRetour="0",commentaire="Succes"},
        parametrageNumeroUnique=#parametrageNumeroUnique{active="0",typeSonnerie="simul",presentationNoFixe="true"},
        parametrageRenvois=#parametrageRenvois{typeRenvoi=TypeRenvoi,
            versNumerosLibres=VersNumerosLibres_Obj,
            versAssistante=VersAssistante,
            saufAppelsEmisDepuis=[
                {numero,"33611221126"},
                {numero,"33611221127"},
                {numero,"33611221128"},
                {numero,"33611221129"}]}
    },
    setup(init_consult_situation,Init_data,Server).

setup(Init,Init_data,Server)->
    RequestName=
        case Init of
            init_identification->"consulterInformations";
            init_activate_situation->"activerSituation";
            init_consult_situation->"consulterSituation";
            init_get_situation_active->"situationActive"
        end,
    case Server of
	mipc->
            profile_manager:set_mipc(?Uid,RequestName,Init_data);
	vpbx ->
            profile_manager:set_vpbx(?Uid,RequestName,Init_data)
    end.
init_test(Uid)->
    profile_manager:create_default(Uid,"dme")++
    profile_manager:init(Uid).

empty_data() ->
    ["Empty data",
     {shell,
      [ {send,"mysql -upossum -ppossum -B -e \"delete FROM svcprofiles WHERE svc='mipcvpbx'\" mobi"},
	{send,"mysql -upossum -ppossum -B -e \"delete FROM svcprofiles_v2_mipcvpbx\" mobi"}
        ]}].

rpc(Mod,Fun,Params)->
    rpc:call(possum@localhost, Mod,Fun, Params).

rpc_for_test(Mod, Fun, Arg)->
    [{erlang_no_trace,
         [{rpc, call, [possum@localhost,Mod, Fun,Arg]}
          ]}].

