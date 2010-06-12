-module(mipc_vpbx_online).
-include("../../pfront_orangef/include/mipc_vpbx_webserv.hrl").
%% fake to be used for MIPC and VPBX
-compile(export_all).
-define(debug,false).

request_activerSituation(Msisdn, Server)->
    Msisdn1=
        case Msisdn of
            "0"++Rest->"+33"++Rest;
            "33"++Rest->"+33"++Rest;
            _->Msisdn
        end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Data=profile_manager:retrieve_(Uid, Server), %%"mipc" or "vpbx"
    Resp_data=proplists:get_value("activerSituation",Data),
    case Resp_data of 
        #activerSituationResponse{}->
            slog:event(trace,?MODULE,result_activerSituation,{Msisdn1, Server, Uid,Resp_data}),
            XMERL_FORM=activerSituationResponse(Resp_data),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    soaplight:decode_body(XML,mipc_vpbx_webserv);
	_->Resp_data
    end.

request_consulterInformations(Msisdn, Server)->
    Msisdn1=
        case Msisdn of
            "0"++Rest->"+33"++Rest;
            "33"++Rest->"+33"++Rest;
            _->Msisdn
        end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Data=profile_manager:retrieve_(Uid, Server), %%"mipc" or "vpbx"
    Resp_data=proplists:get_value("consulterInformations",Data),
    case Resp_data of 
        #consulterInformationsResponse{}->
            slog:event(trace,?MODULE,result_consulterInformations,{Msisdn1,Server, Uid,Resp_data}),
            XMERL_FORM=consulterInformationsResponse(Resp_data),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    soaplight:decode_body(XML,mipc_vpbx_webserv);
	_->Resp_data
    end.

request_consulterParametrageReel(Msisdn, Server)->
    Msisdn1=
        case Msisdn of
            "0"++Rest->"+33"++Rest;
            "33"++Rest->"+33"++Rest;
            _->Msisdn
        end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Data=profile_manager:retrieve_(Uid, Server), %%"mipc" or "vpbx"
    Resp_data=proplists:get_value("consulterParametrageReel",Data),
    case Resp_data of 
        #consulterParametrageReelResponse{}->
            slog:event(trace,?MODULE,result_consulterParametrageReel,{Msisdn1, Server, Uid,Resp_data}),
            XMERL_FORM=consulterParametrageReelResponse(Resp_data),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    soaplight:decode_body(XML,mipc_vpbx_webserv);
	_->Resp_data
    end.
request_consulterSituation(Msisdn, Server)->
    Msisdn1=
        case Msisdn of
            "0"++Rest->"+33"++Rest;
            "33"++Rest->"+33"++Rest;
            _->Msisdn
        end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Data=profile_manager:retrieve_(Uid, Server), %%"mipc" or "vpbx"
    Resp_data=proplists:get_value("consulterSituation",Data),
    case Resp_data of 
        #consulterSituationResponse{}->
            slog:event(trace,?MODULE,result_consulterSituation,{Msisdn1, Server,Uid,Resp_data}),
            XMERL_FORM=consulterSituationResponse(Resp_data),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    soaplight:decode_body(XML,mipc_vpbx_webserv);
	_->Resp_data
    end.

request_listeSituationsParametrees(Msisdn, Server)->
    Msisdn1=
        case Msisdn of
                 "0"++Rest->"+33"++Rest;
            "33"++Rest->"+33"++Rest;
            _->Msisdn
        end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Data=profile_manager:retrieve_(Uid, Server), %%"mipc" or "vpbx"
    Resp_data=proplists:get_value("listeSituationsParametrees",Data),
    case Resp_data of 
        #listeSituationsParametreesResponse{}->
            slog:event(trace,?MODULE,result_listeSituationsParametrees,{Msisdn1,Server, Uid,Resp_data}),
            XMERL_FORM=listeSituationsParametreesResponse(Resp_data),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    soaplight:decode_body(XML,mipc_vpbx_webserv);
	_->Resp_data
    end.

request_situationActive(Msisdn, Server)->
    Msisdn1=
        case Msisdn of
            "0"++Rest->"+33"++Rest;
            "33"++Rest->"+33"++Rest;
            _->Msisdn
        end,
    Uid=profile_manager:get_uid({msisdn,Msisdn1}),
    Data=profile_manager:retrieve_(Uid, Server), %%"mipc" or "vpbx"
    Resp_data=proplists:get_value("situationActive",Data),
    case Resp_data of 
        #situationActiveResponse{}->
            slog:event(trace,?MODULE,result_situationActive,{Msisdn1, Server, Uid,Resp_data}),
            XMERL_FORM=situationActiveResponse(Resp_data),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    soaplight:decode_body(XML,mipc_vpbx_webserv);
	_->Resp_data
    end.


default_data(Server, MSISDN)->
    Resultat_Obj=#resultat{codeRetour="0",commentaire="succes"},
    Reseau_Obj=#reseau{codeReseau="1",nomReseau="Orange"},
    Membre_Obj=#membre{nom="Simon",prenom="Rogre",manager="true"},
    TypeOffre = 
        case Server of
            "mipc"-> "MIPC";
            "vpbx" -> 
                case lists:nthtail(length(MSISDN)-1,MSISDN) of 
                    "1" -> "VPBx";
                    _  -> "VPBX"
                end
        end,

    ActiverSituation_Obj=#activerSituationResponse{resultat=Resultat_Obj},
    ConsulterInformations_Obj=#consulterInformationsResponse{
        resultat=Resultat_Obj,
        reseau=Reseau_Obj,
        membre=Membre_Obj,
        nbSituationsParametrees="0",
        typeOffre=TypeOffre },

    ParametrageNumeroUnique_Obj=#parametrageNumeroUnique{active="0",typeSonnerie="simul",presentationNoFixe="true"},
    VersNumerosLibres_Obj=#versNumerosLibres{premierNumero="98432",listeNumeros=[{numero,"33611221124"}],boiteVocale="BoiteVocale"},
    VersAssistante=#versAssistante{
        nom="Frederic",
        prenom="Frederique",
        numero="98434",
        typeAppel="I"},

    ParametrageRenvois_Obj=#parametrageRenvois{typeRenvoi="I",versNumerosLibres=VersNumerosLibres_Obj},
    ConsulterParametrageReel_Obj=#consulterParametrageReelResponse{
        resultat=Resultat_Obj,
        parametrageNumeroUnique=ParametrageNumeroUnique_Obj,
        parametrageRenvois=ParametrageRenvois_Obj},

    ConsulterSituation_Obj=#consulterSituationResponse{
        resultat=Resultat_Obj,
        parametrageNumeroUnique=ParametrageNumeroUnique_Obj,
        parametrageRenvois=ParametrageRenvois_Obj#parametrageRenvois{
            saufAppelsEmisDepuis=[
                {numero,"33611221126"},
                {numero,"33611221127"},
                {numero,"33611221128"},
                {numero,"33611221129"}
            ]}
    },

    ListeSituationsParametrees_Obj=#listeSituationsParametreesResponse{
        resultat=Resultat_Obj,
        listeSituations=[
            #situation{idSituation="1",libelleSituation="a mon bureau"},
            #situation{idSituation="2",libelleSituation="en deplacement"},
            #situation{idSituation="3",libelleSituation="en reunion"},
            #situation{idSituation="4",libelleSituation="en conges"},
            #situation{idSituation="5",libelleSituation="en formation"},
            #situation{idSituation="6",libelleSituation="a la maison"},
            #situation{idSituation="132",libelleSituation="en formation"}]
        },

    SituationActive_Obj=#situationActiveResponse{
        resultat=Resultat_Obj,
        situationActive=#situation{idSituation="5",libelleSituation="a mon bureau"}
    },

    ActiverSituation=[{"activerSituation",ActiverSituation_Obj}],
    ConsulterInformations=[{"consulterInformations",ConsulterInformations_Obj}],
    ConsulterParametrageReel=[{"consulterParametrageReel", ConsulterParametrageReel_Obj}],
    ConsulterSituation=[{"consulterSituation", ConsulterSituation_Obj}],
    SituationActive=[{"situationActive", SituationActive_Obj}],
    ListeSituationsParametrees=[{"listeSituationsParametrees", ListeSituationsParametrees_Obj}],

    ActiverSituation ++ConsulterInformations ++ ConsulterParametrageReel++ 
    ConsulterSituation ++ ListeSituationsParametrees ++ SituationActive.    


activerSituationResponse(
    #activerSituationResponse{
        resultat=Resultat
        })->

    Pairs=resultat(Resultat),
    [{activerSituationResponse,[],Pairs}].

consulterInformationsResponse(
    #consulterInformationsResponse{
        resultat=Resultat,
        reseau=Reseau,
        membre=Membre,
        nbSituationsParametrees=NbSituationsParametrees,
        typeOffre=TypeOffre
        })->
    Pairs=resultat(Resultat)++reseau(Reseau)++membre(Membre)++
      [{nbSituationsParametrees, [], NbSituationsParametrees}, {typeOffre, [], TypeOffre}],
    [{consulterInformationsResponse,[],Pairs}].

consulterParametrageReelResponse(
    #consulterParametrageReelResponse{
        resultat=Resultat,
        parametrageNumeroUnique=ParametrageNumeroUnique,
        parametrageRenvois=ParametrageRenvois})->

    Pairs=resultat(Resultat)++parametrageNumeroUnique(ParametrageNumeroUnique)++
        parametrageRenvois(ParametrageRenvois),

    [{consulterParametrageReelResponse,[],Pairs}].

consulterSituationResponse(
    #consulterSituationResponse{
        resultat=Resultat,
        parametrageNumeroUnique=ParametrageNumeroUnique,
        parametrageRenvois=ParametrageRenvois})->

    Pairs=resultat(Resultat)++parametrageNumeroUnique(ParametrageNumeroUnique)++parametrageRenvois(ParametrageRenvois),
    [{consulterSituationResponse,[],Pairs}].

listeSituationsParametreesResponse(
    #listeSituationsParametreesResponse{
        resultat=Resultat,
        listeSituations=ListeSituations})->

    Pairs=resultat(Resultat)++[{listeSituations,[],situations(ListeSituations)}],
    [{listeSituationsParametreesResponse,[],Pairs}].

situationActiveResponse(
    #situationActiveResponse{
        resultat=Resultat, 
        situationActive=SituationActive})->
    #situation{idSituation=Id,libelleSituation=Label}=SituationActive,
    SActive=[{idSituation,[],Id},{libelleSituation,[],Label}],
    Pairs=resultat(Resultat)++
        [{situationActive,[], SActive}],
    [{situationActiveResponse,[],Pairs}].


resultat(Resultat=#resultat{
        codeRetour=Code,
        commentaire=Comment})->
    Pairs=[{codeRetour,[],Code},
           {commentaire,[],Comment}],
    [{resultat,[],Pairs}];

resultat(_)-> [].

reseau(Reseau=#reseau{
        codeReseau=Code,
        nomReseau=Nom})->
    Pairs=[{codeReseau,[],Code},{nomReseau,[],Nom}],
    [{reseau,[],Pairs}];

reseau(_)->[].

membre(Membre=#membre{
        nom=Nom,
        prenom=Prenom,
        manager=Manager})->
    Pairs=[{nom,[],Nom},{prenom,[],Prenom},{manager,[],Manager}],
    [{membre,[],Pairs}];

membre(_)->[].

situation(Situation=#situation{
        idSituation=Id,
        libelleSituation=Label})->
    Pairs=[{idSituation,[],Id},{libelleSituation,[],Label}],
    [{situation,[],Pairs}];

situation(_)->[].

situations(Situations) when list(Situations)->
    lists:append([situation(S) || S <-Situations]).

versAssistante(VersAssistante=#versAssistante{
        nom=Nom,
        prenom=Prenom,
        numero=Numero,
        typeAppel=Type})->
    Pairs=[{nom,[],Nom},
           {prenom,[],Prenom},
           {numero,[],Numero},
           {typeAppel,[],Type}], 
    [{versAssistante,[], Pairs}];

versAssistante(_)-> [].

parametrageRenvois(ParametrageRenvois=#parametrageRenvois{
        typeRenvoi=Type,
        versNumerosLibres=VersNumerosLibres,
        versAssistante=VersAssistante,
        saufAppelsEmisDepuis=SaufAppelsEmisDepuis})->
    Pairs=[{typeRenvoi, [], Type}] ++ 
            versNumerosLibres(VersNumerosLibres)++ 
            versAssistante(VersAssistante)++
            [{saufAppelsEmisDepuis,[], SaufAppelsEmisDepuis}], 
    [{parametrageRenvois, [], Pairs}];

parametrageRenvois(_)-> [].

versNumerosLibres(VersNumerosLibres=#versNumerosLibres{
        premierNumero=Premier,
        listeNumeros=ListeNumeros,
        boiteVocale=BoiteVocale})->
    Pairs=[{premierNumero, [], Premier},
           {listeNumeros, [], ListeNumeros},
           {boiteVocale, [], BoiteVocale}],
    [{versNumerosLibres,[], Pairs}];

versNumerosLibres(_)-> [].

parametrageNumeroUnique(ParametrageNumeroUnique=#parametrageNumeroUnique{
        active=Active,
        typeSonnerie=Type,
        presentationNoFixe=Presentation})->
    Pairs=[{active, [], Active},
           {typeSonnerie, [], Type},
           {presentationNoFixe, [], Presentation}],
    [{parametrageNumeroUnique,[],Pairs}];

parametrageNumeroUnique(_)-> [].
