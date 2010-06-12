-module(asmetier_online).
-compile(export_all).
-include("profile_manager.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").

request_getIdent(Msisdn)->
    Msisdn1= 
	case Msisdn of
	    "0"++Rest->"+33"++Rest;
	    _->Msisdn
	end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Asmetier_data=profile_manager:retrieve_(Uid,?asmetier),
    proplists:get_value(?getIdent,Asmetier_data).
%   {ok, IdDossierOrch, IdUtilisateurEdlws, CodeOffreType,Seg_co};

request_getImpact(IdDossierOrchidee)->
    Msisdn=get_msisdn(IdDossierOrchidee),
    Uid=profile_manager:get_uid({msisdn,Msisdn}),
    Asmetier_data=profile_manager:retrieve_(Uid,?asmetier),
    proplists:get_value(?getImpact,Asmetier_data).
%   {ok, ListImpacts};

request_getServicesOptionnels(IdDossierOrchidee)->
    Msisdn=get_msisdn(IdDossierOrchidee),
    Uid=profile_manager:get_uid({msisdn,Msisdn}),
    Asmetier_data=profile_manager:retrieve_(Uid,?asmetier),
    proplists:get_value(?getServicesOptionnels,Asmetier_data).
%   {ok, ListServOpts};

request_doMod(IdDossierOrchidee)->
    Msisdn=get_msisdn(IdDossierOrchidee),
    Uid=profile_manager:get_uid({msisdn,Msisdn}),
    Asmetier_data=profile_manager:retrieve_(Uid,?asmetier),
    proplists:get_value(?doMod,Asmetier_data).
%   ok;

request_isRechargeable(Msisdn) ->
    Msisdn1= 
	case Msisdn of
	    "0"++Rest->"+33"++Rest;
	    _->Msisdn
	end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Asmetier_data=profile_manager:retrieve_(Uid,?asmetier),
    Sub=profile_manager:retrieve_(Uid,"subscription"),
    case Sub of 
        "mobi" -> 
            proplists:get_value(?isRechargeableMobi,Asmetier_data);
        "cmo" -> 
            proplists:get_value(?isRechargeableCmo,Asmetier_data)
    end.

request_doRechargeCB(Msisdn) -> 
    Msisdn1= 
	case Msisdn of
	    "0"++Rest->"+33"++Rest;
	    _->Msisdn
	end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Asmetier_data=profile_manager:retrieve_(Uid,?asmetier),
    proplists:get_value(?doRechargeCB,Asmetier_data).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_msisdn(IdDossierOrchidee)->
    Msisdn_CodeSO=string:sub_string(IdDossierOrchidee,5),
    Index_=string:index(Msisdn_CodeSO,"_"),
    string:left(Msisdn_CodeSO,Index_-1).

get_default_data(Msisdn) ->
    Msisdn1= 
	case Msisdn of
	    "0"++Rest->"+99"++Rest;
	    _->Msisdn
	end,
    IdDossier="oee_"++Msisdn1++"_NOACT",
    IdUtilisateur = "edl_"++Msisdn1++"_NOACT",
    [{?getIdent,{ok, IdDossier,IdUtilisateur,"",""}},
     {?doMod,ok},
     {?getImpact,{ok, []}},
     {?getServicesOptionnels,{ok,[]}},
     {?isRechargeableMobi,{ok, #isRechargeableCBResponse{
                                  idDossier="0123", 
                                  mobicarte=true,
                                  montantMaxRechargeable="40", 
                                  plafond="80", 
                                  rechargementsPossibles=[]}}},
     {?isRechargeableCmo,{ok, #isRechargeableCBResponse{
                                  idDossier="0123", 
                                  mobicarte=false,
                                  montantMaxRechargeable="40.00", 
                                  plafond="80.00", 
                                  rechargementsPossibles=[]}}},
     {?doRechargeCB,{ok, #doRechargementCBResponse{
                                  numAutorisationPaiement="0000",
                                  rechargement=[],
                                  tracage=true}}}].

list_service_optionels([])->[];
list_service_optionels([#asm_option{code_so=Code_so,
				    option_name=Label,
				    dateActivation=DateA,
				    dateDesactivation=DateD}|T])->
    [{serviceOptionnel,
      Code_so,
      "0",  %%inclusDansOffreType
      Label, %%libelle
      "",   %%codeCategoriePreferentielle
      "",   %%codePere
      "",   %%codeType
      DateA,   %%dateActivation
      DateD,   %%dateDesactivation
      "",   %%etat
      "",   %%libelleCategoriePreferentielle
      "",   %%libellePere 
      "",   %%libelleType
      "3",  %%nbChangements
      "3",  %%nombreMaximumNumerosPreferentiels
      "3",  %%numerosPreferentiels
      "",   %%optionInstantanee
      "",   %%ponctuelle
      "1",  %%resiliable

      {technologie,Code_so,Label,"true"}   %%technologie{code,libele,true}
     }]++
	list_service_optionels(T).
