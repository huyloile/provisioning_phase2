-module(asmetier_webserv).

-compile(export_all).

-export([getCodeConfidentiel/1,
 	 checkCodeConfidentiel/2,
 	 setCodeConfidentiel/2,
 	 checkRechargementParentChild/2,
	 getSegCo/2,
 	 setRechargementParentChild/5]).

-export([
	 getIdentification/2,
 	 getImpactSouscriptionServiceOptionnel/3,
 	 getListServiceOptionnel/1,
 	 setServiceOptionnel/7]).
%%sachem service
-export([
	 getRcod/1, getVcod/2, getMcod/2,
	 isRechargementParentChildPossible/2,
	 doRechargementParentChild/5,
	 getServicesOptionnels/1,
	 isRechargeableParentChild/1,
	 doModificationServiceOptionnel/7,
	 doRechargementCBOrchid/7,
	 isRechargeableCB/1
]).

%%edelweiss service
-export([doRechargementCBEdel/7]).

-export([build_secure_IBS/5]).

%% soaplight Callbacks:
-export([decode_by_name/2,build_record/2]).

%%export function for test 
-export([generate_msgid/0]).

%%documentation of events
-export([slog_info/3]).

-include("../../pfront/include/soaplight.hrl").
-include("../include/asmetier_webserv.hrl").
-include("../../oma/include/slog.hrl").

-define(ioformat(FMT,ARGs), true).
	%%io:format("~p:"?MODULE_STRING++" "++FMT,[self()|ARGs])).
-define(EMT_NAME,codeEmetteur).
-define(EMT_VALUE,"USSD").

-define(GET_IDENTIFICATION,"getIdentification").
-define(GET_RCOD,          "getRcod").
-define(GET_VCOD,          "getVcod").
-define(GET_MCOD,          "getMcod").
-define(IS_RECHARGEABLE_PARENT_CHILD, 
	"isRechargeableParentChild").
-define(IS_RECHARGEMENT_PARENT_CHILD_POSSIBLE, 
	"isRechargementParentChildPossible").
-define(DO_RECHARGEMENT_PARENT_CHILD,
	"doRechargementParentChild").
-define(GET_IMPACT_SOUSCRIPTION_SERVICE_OPTIONNEL,
	"getImpactSouscriptionServiceOptionnel").
-define(GET_SERVICES_OPTIONNELS,
	"getServicesOptionnels").
-define(DO_MODIFICATION_SERVICE_OPTIONNEL,
	"doModificationServiceOptionnel").
-define(DO_RECHARGEMENT_CB_ORCHID,
	 "doRechargementCBOrchid").
-define(DO_RECHARGEMENT_CB_EDEL,
	"doRechargementCBEdel").
-define(IS_RECHARGEABLE_CB,
	"isRechargeableCB").

url_by_serv(ServiceName) 
  when ServiceName==?GET_IDENTIFICATION ->
    pbutil:get_env(pdist_orangef,asmetier_url_prefix) 
	++ "identificationService";
url_by_serv(ServiceName) 
  when ServiceName==?GET_RCOD;
       ServiceName==?GET_VCOD;
       ServiceName==?GET_MCOD ->
    pbutil:get_env(pdist_orangef,asmetier_url_prefix) 
	++ "sdaService";
url_by_serv(ServiceName) 
  when ServiceName==?IS_RECHARGEABLE_PARENT_CHILD;
       ServiceName==?IS_RECHARGEABLE_CB
       ->
    pbutil:get_env(pdist_orangef,asmetier_url_prefix) 
	++ "sachemService";
url_by_serv(ServiceName)
  when ServiceName==?DO_RECHARGEMENT_CB_EDEL
       ->
    pbutil:get_env(pdist_orangef,asmetier_url_prefix)
       ++ "edelweissService";
url_by_serv(ServiceName) 
  when ServiceName==?IS_RECHARGEMENT_PARENT_CHILD_POSSIBLE;
       ServiceName==?DO_RECHARGEMENT_PARENT_CHILD;
       ServiceName==?GET_IMPACT_SOUSCRIPTION_SERVICE_OPTIONNEL;
       ServiceName==?GET_SERVICES_OPTIONNELS;
       ServiceName==?DO_MODIFICATION_SERVICE_OPTIONNEL;
       ServiceName==?DO_RECHARGEMENT_CB_ORCHID
       ->
    pbutil:get_env(pdist_orangef,asmetier_url_prefix) 
	++ "orchideeService". 

envNameSpaces(?GET_IDENTIFICATION) ->
    [{'xmlns:tns1',"urn:identification.service.ecare/G8"}];
envNameSpaces(ServiceName) 
  when ServiceName==?GET_RCOD;
       ServiceName==?GET_VCOD;
       ServiceName==?GET_MCOD ->
    [{'xmlns:tns1',"urn:sda.service.ecare/G8"}];
envNameSpaces(ServiceName) 
  when ServiceName==?IS_RECHARGEABLE_PARENT_CHILD;
       ServiceName==?IS_RECHARGEABLE_CB
       ->
    [{'xmlns:tns1',"urn:sachem.service.ecare/G8"}];
envNameSpaces(ServiceName) 
  when ServiceName==?IS_RECHARGEMENT_PARENT_CHILD_POSSIBLE;
       ServiceName==?DO_RECHARGEMENT_PARENT_CHILD;
       ServiceName==?GET_IMPACT_SOUSCRIPTION_SERVICE_OPTIONNEL;
       ServiceName==?GET_SERVICES_OPTIONNELS;
       ServiceName==?DO_MODIFICATION_SERVICE_OPTIONNEL;
       ServiceName==?DO_RECHARGEMENT_CB_ORCHID
       ->
    [{'xmlns:tns1',"urn:orchidee.service.ecare/G8"}];
envNameSpaces(ServiceName)
  when ServiceName == ?DO_RECHARGEMENT_CB_EDEL
       ->
    [{'xmlns:tns1',"urn:edelweiss.service.ecare/G8"}].

%% +deftype msisdn_nat()=string(). %% 06XXXXXXXX
%% +type getCodeConfidentiel(msisdn_nat()) -> getCodeConfidentielResponse().
%% +This API has been obsolete. We use getRCod/1 instead
getCodeConfidentiel(Msisdn) ->
    getRcod(Msisdn).

emt_ele_from_name(Emetteur,Emetteur_value)->
    case Emetteur of
	?EMT_NAME ->
	    Emetteur_ele = [{Emetteur, Emetteur_value}];
	_ ->
	    Emetteur_ele = []
    end.
    
getRcod(Msisdn)->
    getRcod(?EMT_NAME,?EMT_VALUE,Msisdn).

getRcod(Emetteur, Emetteur_value, Msisdn)->
    ServiceName=?GET_RCOD,
    Req = #soap_req
      {
      web_service = parentChild,
      http_url = url_by_serv(ServiceName),
      http_headers = [
		      {"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}
		     ],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent =
      [{'tns1:getRcod',
	emt_ele_from_name(Emetteur,Emetteur_value) ++
	[
	 {numDossier, Msisdn}
	]
       }
      ]
     },
    slog:event(count, ?MODULE, getRcod, Msisdn),
    Resp = soap_req(Req),
    case Resp of
	#getRcodResponse{} ->
	    slog:event(count, ?MODULE, getRcod_OK, Resp),
	    Resp;
	Error ->
            case is_exception(Error) of
                true ->
		    ExceptionName=element(1,Error),    %%we are certain Error here is an Exception,so we get name of record using element
                    slog:event(failure, ?MODULE, {getRcod_NOK,ExceptionName}, {exception,Msisdn,Resp});
                false ->
                    slog:event(failure, ?MODULE, {getRcod_NOK,technical_error}, {error,Msisdn, Error})
            end,
	    Error
    end.
 
%% +type checkCodeConfidentiel(msisdn_nat(), Code::string()) ->
%%  checkCodeConfidentielResponse().
%% +This API has been obsolete. We use getVcod/2 instead
checkCodeConfidentiel(Msisdn,CodeValeur) ->
    getVcod(Msisdn, CodeValeur).

getVcod(Msisdn, CodeValeur)->
    getVcod(?EMT_NAME, ?EMT_VALUE,Msisdn,CodeValeur).

getVcod(Emetteur, Emetteur_value, Msisdn, CodeValeur)->
    ServiceName=?GET_VCOD,
    Req = #soap_req{
      web_service=parentChild,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent=[{'tns1:getVcod',
		    emt_ele_from_name(Emetteur, Emetteur_value) ++
		    [{numDossier,   Msisdn},
		     {codeType,     "N"},
		     {codeLen,      "4"},
		     {code,         CodeValeur},
		     {codeNiveau,   "3"}
		    ]
		   }
		  ]
     },
    slog:event(count, ?MODULE, getVcod, {Msisdn,CodeValeur}),
    case Resp = soap_req(Req) of
	#getVcodResponse{}=Resp ->
	    slog:event(count, ?MODULE, getVcod_OK, Resp),
	    Resp;
	Error ->
            case is_exception(Error) of
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure,?MODULE, {getVcod_NOK,ExceptionName},{exception, Msisdn,Resp});
                false->
                    slog:event(failure,?MODULE, {getVcod_NOK,technical_error}, {error, Msisdn, Error})
            end,
	    Error
    end.

%% +type setCodeConfidentiel(msisdn_nat(),Code::string()) ->
%%  setCodeConfidentielResponse().
%% +This API has been obsolete. We use getMcod/2 instead
setCodeConfidentiel(Msisdn,CodeValeur) ->
    getMcod(Msisdn,CodeValeur).
getMcod(Msisdn,CodeValeur)->
    getMcod(?EMT_NAME,?EMT_VALUE,Msisdn,CodeValeur).
getMcod(Emetteur, Emetteur_value, Msisdn, CodeValeur)->
    ServiceName=?GET_MCOD,
    Req = #soap_req{
      web_service=parentChild,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent=[{'tns1:getMcod',
		    emt_ele_from_name(Emetteur, Emetteur_value) ++
		    [
		     {numDossier, Msisdn},
		     {codeType,   "N"},
		     {codeLen,    "4"},
		     {code,       CodeValeur},
		     {codeNiveau, "3"}
		    ]
		   }
		  ]
     },
    slog:event(count, ?MODULE, getMcod, {Msisdn,CodeValeur}),
    case Resp = soap_req(Req) of
	#getMcodResponse{} ->
	    slog:event(count, ?MODULE, getMcod_OK, Resp),
	    Resp;
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE, {getMcod_NOK,ExceptionName},{exception,Msisdn,Resp});
                false ->
                    slog:event(failure, ?MODULE, {getMcod_NOK,technical_error},{error,Msisdn,Error})
            end,
            Error
    end.

%% +type isRechargeableParentChild(msisdn()) ->
%%  isRechargeableParentChildResponse().
isRechargeableParentChild(Msisdn) ->
    isRechargeableParentChild(?EMT_NAME,?EMT_VALUE,Msisdn).

isRechargeableParentChild(Emetteur, Emetteur_value, Msisdn) ->
    ServiceName=?IS_RECHARGEABLE_PARENT_CHILD,
    Req = #soap_req{
      web_service = parentChild,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent=
        [{'tns1:isRechargeableParentChild',
	  emt_ele_from_name(Emetteur, Emetteur_value) ++
	  [{numMSISDN, Msisdn}]
         }]},
    slog:event(count, ?MODULE, isRechargeableParentChild,
	       {Msisdn}),
    case Resp = soap_req(Req) of
	#isRechargeableParentChildResponse{} ->
	    slog:event(count, ?MODULE,
		       isRechargeableParentChild_OK, Resp),
	    Resp;
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE,{isRechargeableParentChild_NOK,ExceptionName},{exception,Msisdn,Resp});
                false ->
                    slog:event(failure, ?MODULE,{isRechargeableParentChild_NOK,technical_error}, {error,Msisdn,Error})
            end,
	    Error
    end.
    
%% +type checkRechargementParentChild(msisdn_nat(), msisdn_nat()) ->
%%  checkRechargementParentChildResponse().
checkRechargementParentChild(MsisdnRechargeur, MsisdnRecharge) ->
    isRechargementParentChildPossible(MsisdnRechargeur, MsisdnRecharge).

isRechargementParentChildPossible(MsisdnRechargeur, MsisdnRecharge)->
    isRechargementParentChildPossible(?EMT_NAME,?EMT_VALUE, MsisdnRechargeur, MsisdnRecharge).

isRechargementParentChildPossible(Emetteur, Emetteur_value, MsisdnRechargeur, MsisdnRecharge) ->
    ServiceName=?IS_RECHARGEMENT_PARENT_CHILD_POSSIBLE,
    Req = #soap_req{
      web_service = parentChild,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent=
      [{'tns1:isRechargementParentChildPossible',
  	emt_ele_from_name(Emetteur, Emetteur_value) ++
  	[{numMSISDN, MsisdnRechargeur}]
       }]},
    slog:event(count, ?MODULE, isRechargementParentChildPossible,
	       {MsisdnRechargeur, MsisdnRecharge}),
    case Resp = soap_req(Req) of
	#isRechargementParentChildPossibleResponse{}->
	    slog:event(count, ?MODULE,
		       isRechargementParentChildPossible_OK, Resp),
	    Resp;
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure,?MODULE,{isRechargementParentChildPossible_NOK,ExceptionName},{exception,MsisdnRechargeur,MsisdnRecharge,Resp});
                false ->
                    slog:event(failure,?MODULE,{isRechargementParentChildPossible_NOK,technical_error},{error,MsisdnRechargeur,MsisdnRecharge, Error})
            end,
	    Error
    end.

add_nil_true("") -> [{'xsi:nil',"true"}];
add_nil_true(_) -> [].		    

%% +type setRechargementParentChild(string(), string(), string(),
%%                                     msisdn_nat(), msisdn_nat()) ->
%%  setRechargementParentChildResponse().
setRechargementParentChild(CodePrest, IdDossOrch, IdDossSach, MsisdnRecharge,
			   MsisdnRechargeur) ->
     doRechargementParentChild(CodePrest, IdDossOrch, IdDossSach, MsisdnRecharge,
                            MsisdnRechargeur).

doRechargementParentChild(CodePrest, IdDossOrch, IdDossSach, MsisdnRecharge,
                            MsisdnRechargeur) ->
doRechargementParentChild(?EMT_NAME, ?EMT_VALUE, CodePrest, IdDossOrch, IdDossSach, MsisdnRecharge,
                            MsisdnRechargeur).

doRechargementParentChild(Emetteur, Emetteur_value, CodePrest, 
			  IdDossOrch, IdDossSach, MsisdnRecharge,
			  MsisdnRechargeur) ->
    ServiceName=?DO_RECHARGEMENT_PARENT_CHILD,
    Req = #soap_req{
      web_service=parentChild,
      http_url = url_by_serv(ServiceName),
      http_headers=[{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent=
      [{'tns1:doRechargementParentChild',
	emt_ele_from_name(Emetteur, Emetteur_value) ++
	[ 
	  {numMSISDNRechargeur, MsisdnRechargeur},
	  {idDossier,           IdDossOrch},
	  {numMSISDNRecharge,   MsisdnRecharge},
	  {idDossierSachem,     IdDossSach},
	  {codePrestation,      CodePrest}]
	 }]},
    slog:event(count, {?MODULE,?LINE}, doRechargementParentChild,
	       {CodePrest, IdDossOrch, IdDossSach, MsisdnRecharge,
		MsisdnRechargeur}),
    case Resp = soap_req(Req) of
 	#doRechargementParentChildResponse{} ->
 	    slog:event(count, ?MODULE,
 		       doRechargementParentChild_OK, Resp),
 	    Resp;
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure,?MODULE,{doRechargementParentChild_NOK,ExceptionName},{exception,Resp});
                false ->
                    slog:event(failure,?MODULE,{doRechargementParentChild_NOK,technical_error}, {error,Error})
            end,
	    Error
    end.

%% +type getIdentification(Msisdn::string(),Mode::string()) ->
%%  getIdentificationResponse() | {'EXIT',Reason}.

getIdentification(Msisdn, Mode)->
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_getIdent(Msisdn);
	_->
	    getIdentification(?EMT_NAME,?EMT_VALUE,Msisdn, Mode)
    end.

getIdentification(Emetteur, Emetteur_value, Msisdn, Mode) ->
    WebServiceName=?GET_IDENTIFICATION,
    Req = #soap_req{
      web_service = subscr_opt,
      http_url = url_by_serv(WebServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(WebServiceName),
      bodycontent =
      [{'tns1:getIdentification',
	emt_ele_from_name(Emetteur,Emetteur_value)++
	[{msisdn,  Msisdn},
	 {numNsce, ""},    %% unused field, leave empty
	 {mode,    Mode}]
       }
      ]
     },
    slog:event(count, ?MODULE, getIdentification,{Msisdn, Mode}),
    case Resp = soap_req(Req) of
	#getIdentificationResponse{idDossier=IdDosOrch,
				   idUtilisateur=IdUtilisateurEdlws,
				   codeOffreType=CodeOffreType,
				   codeSegmentCommercial=CodeSegmentCommercial} ->
			    
	    slog:event(count, ?MODULE,getIdentification_OK,[IdDosOrch,IdUtilisateurEdlws, CodeOffreType]),
	    {ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, CodeSegmentCommercial};
        Error ->
            case is_exception(Error) of 
                true ->
		     ExceptionName=element(1,Error),
                    slog:event(failure,?MODULE,{getIdentification_NOK,ExceptionName},{exception,Msisdn,Resp});
                false ->
                    slog:event(failure,?MODULE,{getIdentification_NOK,technical_error},{error,Msisdn,Error})
            end,
	    Error
    end.
getSegCo(Msisdn, Mode)->
    getSegCo(?EMT_NAME,?EMT_VALUE,Msisdn, Mode).

getSegCo(Emetteur, Emetteur_value, Msisdn, Mode) ->
    WebServiceName=?GET_IDENTIFICATION,
    Req = #soap_req{
      web_service = subscr_opt,
      http_url = url_by_serv(WebServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(WebServiceName),
      bodycontent =
      [{'tns1:getIdentification',
	emt_ele_from_name(Emetteur,Emetteur_value)++
	[{msisdn,  Msisdn},
	 {numNsce, ""},    %% unused field, leave empty
	 {mode,    Mode}]
       }
      ]
     },
    slog:event(count, ?MODULE, getSegCo,{Msisdn, Mode}),    
    case Resp = soap_req(Req) of
	#getIdentificationResponse{codeSegmentCommercial=CodeSegmentCommercial} ->
	    slog:event(count, ?MODULE,getSegCo_OK,[CodeSegmentCommercial]),
	    {ok, CodeSegmentCommercial};

	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE, {getSegCo_NOK,ExceptionName},{exception,Msisdn,Resp});
                false ->
                    slog:event(failure, ?MODULE, {getSegCo_NOK,technical_error},{error,Msisdn,Error})
            end,
	    Error
    end.


%% +type getImpactSouscriptionServiceOptionnel(IdDossierOrchidee::string(),
%%                                             CodeServiceOptionnel::string(),
%%                                             CodeOffreType::string()) ->
%%  getImpactSouscriptionServiceOptionnelResponse() | {'EXIT',Reason}.

getImpactSouscriptionServiceOptionnel(IdDossierOrchidee,
				      CodeServiceOptionnel,
				      CodeOffreType) ->
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_getImpact(IdDossierOrchidee);
	_->
	    getImpactSouscriptionServiceOptionnel(?EMT_NAME,?EMT_VALUE,
						  IdDossierOrchidee,
						  CodeServiceOptionnel,
						  CodeOffreType)
    end.

getImpactSouscriptionServiceOptionnel(Emetteur,Emetteur_value,IdDossier,
				      IdServiceOptionnel,
				      CodeOffreType) ->
    ServiceName=?GET_IMPACT_SOUSCRIPTION_SERVICE_OPTIONNEL,
    Req = #soap_req{
      web_service = subscr_opt,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent =
      [{'tns1:getImpactSouscriptionServiceOptionnel',
	emt_ele_from_name(Emetteur,Emetteur_value)++
	[{idDossier,          IdDossier},
	 {idServiceOptionnel, IdServiceOptionnel},
	 {codeOffreType,      CodeOffreType}]
       }]},
    slog:event(count, ?MODULE, getImpactSouscriptionServiceOptionnel,
	       {IdDossier, IdServiceOptionnel, CodeOffreType}),
    case Resp = soap_req(Req) of
	#getImpactSouscriptionServiceOptionnelResponse{
			servicesOptionnelsResilies=ListOptResil} ->
	    slog:event(count, ?MODULE,getImpactSouscriptionServiceOptionnel_OK,ListOptResil),
	    {ok, ListOptResil};

	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE,{getImpactSouscriptionServiceOptionnel_NOK,ExceptionName},{exception,IdDossier,Error});
                false ->
                    slog:event(failure, ?MODULE,{getImpactSouscriptionServiceOptionnel_NOK,technical_error},{error,IdDossier,Error})
            end,
	    Error
    end.

%% +type getListServiceOptionnel(IdDossierOrchidee::string()) ->
%%  getListServiceOptionnelResponse() | {'EXIT',Reason}.
%% +This API has been obsolete. We use getServicesOptionnels/1 instead

getListServiceOptionnel(IdDossierOrchidee) ->
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_getServicesOptionnels(IdDossierOrchidee);
	_->
	    getServicesOptionnels(IdDossierOrchidee)
    end.

getServicesOptionnels(IdDossierOrchidee)->
    getServicesOptionnels(?EMT_NAME,?EMT_VALUE,IdDossierOrchidee).

getServicesOptionnels(Emetteur, Emetteur_value, IdDossier)->
    ServiceName=?GET_SERVICES_OPTIONNELS,
    Req = #soap_req{
      web_service = subscr_opt,
      http_url = url_by_serv(?GET_SERVICES_OPTIONNELS),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?GET_SERVICES_OPTIONNELS),
      bodycontent =
      [{'tns1:getServicesOptionnels',
	emt_ele_from_name(Emetteur, Emetteur_value) ++
	[{idDossier, IdDossier}]
       }]},

    slog:event(count, ?MODULE, getServicesOptionnels, IdDossier),
    case Resp = soap_req(Req) of
 	#getServicesOptionnelsResponse{servicesOptionnelsList=ServOpt}->
	    slog:event(count, ?MODULE, getServicesOptionnels_OK, ServOpt),
	    {ok,ServOpt};
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE, {getSerrvicesOptionnels_NOK,ExceptionName},{exception,IdDossier,Resp});
                false ->
                    slog:event(failure, ?MODULE, {getServicesOptionnels_NOK,technical_error},{error,IdDossier,Error})
            end,
            Error	
    end.

%% +type setServiceOptionnel(Msisdn::string(),
%%                           IdDossierOrchidee::string(),
%%                           CodeServiceOptionnel::string(),
%%                           Activation::bool(),
%%                           PriseEnCompteImmediate::bool(),
%%                           DateProchaineFacture::string(),
%%                           ModeAutomatique::bool()) ->
%%  setServiceOptionnelResponse() | {'EXIT',Reason}.
%% +This API has been obsolete. We use setServiceOptionnel/6 instead
setServiceOptionnel(Msisdn,
		    IdDossierOrchidee,
		    CodeServiceOptionnel,
		    Activation,
		    PriseEnCompteImmediate,
		    DateProchaineFacture,
		    ModeAutomatique) -> 
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_doMod(IdDossierOrchidee);
	_->
	    doModificationServiceOptionnel(Msisdn,
					   IdDossierOrchidee,
					   CodeServiceOptionnel,
					   Activation,
					   PriseEnCompteImmediate,
					   DateProchaineFacture,
					   ModeAutomatique)
    end.

doModificationServiceOptionnel(Msisdn,
			       IdDossierOrchidee,
			       CodeServiceOptionnel,
			       Activation,
			       PriseEnCompteImmediate,
			       DateProchaineFacture,
			       ModeAutomatique) ->

    doModificationServiceOptionnel(?EMT_NAME,?EMT_VALUE, 
				   Msisdn,
				   IdDossierOrchidee,				   
				   CodeServiceOptionnel,
				   Activation,
				   PriseEnCompteImmediate,
				   DateProchaineFacture,
				   ModeAutomatique,
				   "",
				   "",
				   "",
				   ""
			      ).

doModificationServiceOptionnel(_,_,Msisdn,undefined, %idDossierOrchidee
			       _,_,_,_,_,_,_,_,_
			      )->
    slog:event(failure, ?MODULE, 
	       doModificationServiceOptionnelResponse_NOK, 
	       {Msisdn, "ID dossier orchidee manquant"}),
    #'ExceptionDossierNonTrouve'{};
doModificationServiceOptionnel(Emetteur, 
			       Emetteur_value,
			       Msisdn,
			       IdDossierOrchidee,
			       CodeServiceOptionnel,
			       Activation,
			       PriseEnCompteImmediate,
			       DateProchaineFacture,
			       ModeAutomatique,
			       CodePDV,
			       DateActivation,
			       DateDeactivation,
			       CodeAlliance
			      )->
    ServiceName=?DO_MODIFICATION_SERVICE_OPTIONNEL,
    Req = #soap_req{
      web_service = subscr_opt,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent =
      [{'tns1:doModificationServiceOptionnel',
	emt_ele_from_name(Emetteur, Emetteur_value) ++ 
	[{idDossier,  IdDossierOrchidee},
	 {numMSISDN,  Msisdn},
	 {codeServiceOption, CodeServiceOptionnel},
	 {flagIndicActivation,  Activation},
	 {flagPriseEnCompteImmediate, PriseEnCompteImmediate},
	 {dateProchaineFacture,       DateProchaineFacture},
	 {modeAutomatique,            ModeAutomatique},
	 {codePdv,                    CodePDV},
	 {dateActivation,             DateActivation},
	 {dateDesactivation,          DateDeactivation},
	 {codeAlliance,               CodeAlliance}
	]
       }]},
    slog:event(count, ?MODULE, doModificationServiceOptionnel,
	       {IdDossierOrchidee, CodeServiceOptionnel, Activation,
		PriseEnCompteImmediate, DateProchaineFacture, ModeAutomatique}),
    case Resp = soap_req(Req) of
	#doModificationServiceOptionnelResponse{} ->
	    slog:event(count, ?MODULE, doModificationServiceOptionnel_OK, Resp),
	    ok;

	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE, {doModificationServiceOptionnel_NOK,ExceptionName},{exception,Msisdn,Resp});
                false->
                    slog:event(failure, ?MODULE, {doModificationServiceOptionnel_NOK,technical_error},{error,Msisdn, Error})
            end,
	    Error
    end.


%% +type doRechargementCBOrchid(idDosOrchid::string(),
%%                              msisdn::string(),
%%                              typeTransfert:short(),
%%                              InfoBank::string(), 
%%                              IdMsg::string(),
%%                              IdDosSach::string(),
%%                              Amount::integer())
%% doRechargementCBOrchidResponse().
doRechargementCBOrchid(IdDosOrchid,MSISDN,TypeTransfert,InfoBank,IdMsg,IdDosSach,Amount)->
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_doRechargeCB(MSISDN);
	_->
            CodeEmetteur = pbutil:get_env(pfront_orangef,asm_codeEmetteur_orchidee),
            doRechargementCBOrchid(?EMT_NAME, CodeEmetteur,IdDosOrchid,MSISDN,TypeTransfert,InfoBank,IdMsg,IdDosSach,Amount)
    end.

doRechargementCBOrchid(Emetteur, Emetteur_value,IdDosOrchid,MSISDN,TypeTransfert,InfoBank,IdMsg,IdDosSach,Amount) ->
    ServiceName = ?DO_RECHARGEMENT_CB_ORCHID,
    Req = #soap_req{
      web_service = rechargementCB,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent =
      [{'tns1:doRechargementCB',
	emt_ele_from_name(Emetteur,Emetteur_value)++
	[{idDossier, IdDosOrchid},
	 {numMSISDN, MSISDN},
	 {typeTransfert ,TypeTransfert},
	 {infosBancaires,InfoBank},
	 {idMessage, IdMsg},
	 {idSachemDossier, IdDosSach},
	 {montant, Amount}]
       }
      ]
     },
    slog:event(count,?MODULE, doRechargementCBOrchid, {IdDosOrchid,MSISDN}),
    case Resp = soap_req(Req) of
	#doRechargementCBResponse{} ->
	    slog:event(count, ?MODULE, doRechargementOrchid_OK, {Resp}),
	    {ok,Resp}; 
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
		    case is_record(Error,'ExceptionPaiement') of 
			true ->
			    EmetteurResp = Error#'ExceptionPaiement'.emetteur,
			    Oper = Error#'ExceptionPaiement'.oper,
			    Ctrl = Error#'ExceptionPaiement'.ctrl,
			    Cret = Error#'ExceptionPaiement'.cret,
			    Etat = Error#'ExceptionPaiement'.etat,
			    slog:event(failure,?MODULE,{doRechargementCBOrchid_NOK,ExceptionName,EmetteurResp,Oper,Ctrl,Cret,Etat},{exception,IdDosOrchid,MSISDN,Resp});
			false ->
			    slog:event(failure, ?MODULE, {doRechargementCBOrchid_NOK,ExceptionName},{exception,IdDosOrchid,MSISDN,Resp})
		    end;
                false ->
                    slog:event(failure, ?MODULE, {doRechargementCBOrchid_NOK,technical_error},{error,IdDosOrchid,MSISDN,Error})
            end,
            Error
    end.
%% +type doRechargementCBEdel (  idDosEdel:string(),
%%                              msisdn::string(),
%%                              typeTransfert:short(),
%%                              InfoBank::string(), 
%%                              IdMsg::string(),
%%                              IdDosSach::string(),
%%                              Amount::integer())
%%  doRechargementCBEdelResponse().
%%
%%
%%

doRechargementCBEdel(IdDosEdel,MSISDN,TypeTransfert,InfoBank,IdMsg,IdDosSach,Amount)->
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_doRechargeCB(MSISDN);
	_->
            CodeEmetteur = pbutil:get_env(pfront_orangef,asm_codeEmetteur_edelweiss),
            doRechargementCBEdel(?EMT_NAME,CodeEmetteur,IdDosEdel,MSISDN,TypeTransfert,InfoBank,IdMsg,IdDosSach,Amount)
    end.

doRechargementCBEdel(Emetteur, Emetteur_value, IdDosEdel, MSISDN, TypeTransfert,InfoBank,IdMsg,IdDosSach,Amount) ->
    ServiceName = ?DO_RECHARGEMENT_CB_EDEL,
    Req = #soap_req{
      web_service = rechargementCB,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent =
      [{'tns1:doRechargementCB',
	emt_ele_from_name(Emetteur,Emetteur_value)++
	[{idUtilisateur, IdDosEdel},
	 {numMSISDN, MSISDN},
	 {typeTransfert ,TypeTransfert},
	 {infosBancaires,InfoBank},
	 {idMessage, IdMsg},
	 {idSachemDossier, IdDosSach},
	 {montant, Amount}]
       }
      ]
     },
    slog:event(count,?MODULE, doRechargementCBEdel, {IdDosEdel,MSISDN}),
    case Resp = soap_req(Req) of 
	#doRechargementCBResponse{} ->
	    slog:event(count, ?MODULE, doRechargementCBEdel_OK, {Resp}),
	    {ok,Resp}; 
	Error ->
            case is_exception(Error) of 
                true ->
		    ExceptionName=element(1,Error),
		    case is_record(Error,'ExceptionPaiement') of
			true ->
			    EmetteurResp = Error#'ExceptionPaiement'.emetteur,
			    Oper = Error#'ExceptionPaiement'.oper,
			    Ctrl = Error#'ExceptionPaiement'.ctrl,
			    Cret = Error#'ExceptionPaiement'.cret,
			    Etat = Error#'ExceptionPaiement'.etat,
			    slog:event(failure,?MODULE,{doRechargementCBEdel_NOK,ExceptionName,EmetteurResp,Oper,Ctrl,Cret,Etat},{exception,IdDosEdel,MSISDN,Resp});
			false ->
			    slog:event(failure, ?MODULE, {doRechargementCBEdel_NOK,ExceptionName},{exception,IdDosEdel,MSISDN,Resp})
		    end;
                false ->
                    slog:event(failure, ?MODULE, {doRechargementCBEdel_NOK,technical_error},{error,IdDosEdel,MSISDN,Error})
            end,
            Error
    end.

isRechargeableCB(MSISDN)->
    case pbutil:get_env(pfront_orangef, asmetier_version) of
	online->
	    asmetier_online:request_isRechargeable(MSISDN);
	_->
            isRechargeableCB(?EMT_NAME,?EMT_VALUE,MSISDN)
    end.

isRechargeableCB(Emetteur, Emetteur_value, MSISDN) ->
    ServiceName = ?IS_RECHARGEABLE_CB,
    Req = #soap_req{
      web_service = rechargementCB,
      http_url = url_by_serv(ServiceName),
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      envnamespaces = envNameSpaces(ServiceName),
      bodycontent =
      [{'tns1:isRechargeableCB',
	emt_ele_from_name(Emetteur,Emetteur_value)++
	[
	 {numMSISDN, MSISDN}]
       }
      ]
     },

    slog:event(count, ?MODULE, isRechargeableCB, {MSISDN}),
    case Resp = soap_req(Req) of 
	#isRechargeableCBResponse{} ->
	    slog:event(count , ?MODULE, isRechargeableCB_OK, {Resp}),
	    {ok,Resp};
	Error ->
            case is_exception(Error) of
                true ->
		    ExceptionName=element(1,Error),
                    slog:event(failure, ?MODULE, {isRechargeableCB_NOK,ExceptionName}, {exception,MSISDN,Resp});
                false ->
                    slog:event(failure, ?MODULE, {isRechargeableCB_NOK,technical_error}, {error,MSISDN, Error})
            end,
	    Error
    end.

%%%% Callbacks needed by soaplight.erl :
%% +type decode_by_name(Tag::atom(),string()) ->
%%  pair().
decode_by_name(mobicarte, "") -> {mobicarte, false};
decode_by_name(mobicarte, Bool) -> {mobicarte, list_to_atom(Bool)};
decode_by_name(nbTentatives,Txt) -> {nbTentatives,list_to_integer(Txt)};
decode_by_name(statusCode,[_,_|T]) -> 
    {statusCode,T};
decode_by_name(Name,Txt) -> 
    {Name,Txt}.

%% +type build_record(Tag::atom(),Pairs::[pair()]) ->
%%  record() | pair().
build_record(Name, _) 
when Name==doModificationServiceOptionnelResponse
->
    #doModificationServiceOptionnelResponse{};
build_record(Name, []) 
when Name== getServicesOptionnelsResponse;
     Name== getRcodResponse;
     Name== getVcodResponse;
     Name== getMcodResponse;
     Name== isRechargementParentChildPossibleResponse;
     Name== doRechargementParentChildResponse
     ->
    {Name, []};    

build_record(Name, [{return,Pairs}])
when Name== getIdentificationResponse;
     Name== getRcodResponse;
     Name== getVcodResponse;
     Name== getMcodResponse;
     Name== isRechargeableParentChildResponse;
     Name== doRechargementParentChildResponse
%%     Name== rechargementsPossibles
  ->
    pairs_to_record(Name, Pairs);

build_record(doRechargementCBResponse, [{return,Pairs}]) ->
    pairs_to_record(doRechargementCBResponse,Pairs);

build_record(isRechargeableCBResponse, [{return,Pairs}])->
    Response = pairs_to_record(isRechargeableCBResponse,Pairs),
    RechargementPossibles = lists:foldl(fun(Item ,Acc) when is_record(Item,rechargementPossible) ->
                                                [Item|Acc];
                                                (_,Acc) ->
                                                Acc
                                        end, [] , Pairs),
    Response#isRechargeableCBResponse{
      rechargementsPossibles = RechargementPossibles
};

%%TODO Possible a bug , tl(Pairs) retrun last element of list , but don't remove
%%element from list , using two time tl(Pairs) return the same item , need to confirm
build_record(getImpactSouscriptionServiceOptionnelResponse, [{return,Pairs}]) 
     ->
    {optionInstantanee, OptionInstantanee} = hd(Pairs),
    ServicesOptionnelsResilies = lists:foldl(
				   fun({servicesOptionnelsResilies,ServOpt},
				       Acc) ->
					   [ServOpt|Acc];
				       (_,Acc) ->
					   Acc
				   end, [], tl(Pairs)),
    ServicesOptionnelsConserves = lists:foldl(
				   fun({servicesOptionnelsConserves,ServOpt},
					Acc) ->
					   [ServOpt|Acc];
				      (_,Acc) ->
					   Acc
				   end, [], tl(Pairs)),
    #getImpactSouscriptionServiceOptionnelResponse
      {optionInstantanee=OptionInstantanee,
       servicesOptionnelsConserves=lists:reverse(ServicesOptionnelsConserves),
       servicesOptionnelsResilies=lists:reverse(ServicesOptionnelsResilies)};

%%TODO same error as previous

build_record(isRechargementParentChildPossibleResponse, [{return,Pairs}]) 
     ->
    Resp = pairs_to_record(isRechargementParentChildPossibleResponse, Pairs),
    PrestationsMobicarte = lists:foldl(
			     fun({prestationsMobicarte,CodeMontant},
				 Acc) ->
				     [CodeMontant|Acc];
				(_,Acc) ->
				     Acc
			     end, [], tl(Pairs)),
    PrestationsCmo = lists:foldl(
			     fun({prestationsCmo,CodeMontant},
				 Acc) ->
				     [CodeMontant|Acc];
				(_,Acc) ->
				     Acc
			     end, [], tl(Pairs)), 
    Resp#isRechargementParentChildPossibleResponse
      {prestationsMobicarte=lists:reverse(PrestationsMobicarte),
       prestationsCmo=lists:reverse(PrestationsCmo)};

build_record(rechargement, Pairs) 
    ->
     Comptes = lists:foldl(
 		fun({comptes,Compte},
 		    Acc) ->
 			[Compte|Acc];
 		   (_,Acc) ->
 			Acc
 		end, [], Pairs),
      Resp = pairs_to_record(rechargement,Pairs),
      {rechargement,Resp#rechargement{comptes=lists:reverse(Comptes)}};


build_record(rechargementsPossibles, Pairs) ->
    pairs_to_record(rechargementPossible,Pairs);



build_record(Name, ItemList) 
when Name== getServicesOptionnelsResponse
     ->
    ServOptList = lists:map(fun({return,ServOpt}) ->
				    pairs_to_record(serviceOptionnel, 
						    ServOpt)
			       end, ItemList),
    {Name, ServOptList};


build_record(Name, ItemList) 
  when Name== servicesOptionnelsResilies;
       Name== servicesOptionnelsConserves
       ->
    case ItemList of 
	[] -> [];
	_ ->
	    {Name,pairs_to_record(serviceOptionnel,ItemList)}
    end;
build_record(Name, ItemList) 
when Name== prestationsCmo;
     Name== prestationsMobicarte
     ->
    case ItemList of 
	[] -> [];
	_ ->
	    {Name,pairs_to_record(code_montant, ItemList)}
    end;

build_record(detail,Items)->
    Items;

build_record(listeRcodItem,Items)->
    {listeRcodItem, pairs_to_record(listeRcodItem,Items)};
build_record(Name, Items)
  when Name==comptes;
       Name==uniteGestion;
       Name==uniteRestitution;
       Name==planTarifaire;
       Name==typeCompte;
       Name==technologie->
    {Name, pairs_to_record(Name,Items)};


%%Build Exception records
build_record(ExceptionName, Pairs) 
when ExceptionName=='Fault'
->pairs_to_record(ExceptionName, Pairs);

build_record(ExceptionName, Pairs) 
  when ExceptionName=='ECareExceptionTechnique';
ExceptionName=='ExceptionOffreTypeInexistante';
ExceptionName=='ExceptionServiceOptionnelImpossible';
ExceptionName=='ExceptionServiceOptionnelnexistant';
ExceptionName=='ExceptionErreurInterne';
ExceptionName=='ExceptionDonneesInvalides';
ExceptionName=='ExceptionDossierNonTrouve';
ExceptionName=='ExceptionDateFacturationProche';
ExceptionName=='ExceptionRegleNonVerifiee';
ExceptionName=='ExceptionRegleGestionABPRONonVerifiee';
ExceptionName=='ExceptionCoupleClientDossierInexistant';
ExceptionName=='ECareExceptionFonctionnelleCodeInhbTemp';
ExceptionName=='ECareExceptionFonctionnelleCodeInhb';
ExceptionName=='ECareExceptionFonctionnelleCodeNotInit';
ExceptionName=='ECareExceptionFonctionnelleCodeLock';
ExceptionName=='ECareExceptionFonctionnelleCodeWrong';
ExceptionName=='ECareExceptionFonctionnelle';
ExceptionName=='ExceptionServiceOptionnelRequis';
ExceptionName=='ExceptionPlanRecouvrementIncorrect';
ExceptionName=='ExceptionTypeClientIncorrect';
ExceptionName=='ExceptionEtatDossierIncorrect';
ExceptionName=='ExceptionServiceOptionnelBloquant';
ExceptionName=='ExceptionEtatRecouvrementIncorrect';
ExceptionName=='ExceptionProduitIncorrect';
ExceptionName=='ExceptionDossierNonOrange';
ExceptionName=='ExceptionPaiement';
ExceptionName=='ExceptionOptionRequise';
ExceptionName=='ExceptionOptionInterdite';
ExceptionName=='ExceptionAncienneteRequise'
->{exception,pairs_to_record(ExceptionName, Pairs)};

build_record(Name,Pairs) when Name==return -> {Name,Pairs};
build_record(Name,[]) -> {Name,[]}.


    
pairs_to_record(RecName, Pairs) ->
    pbutil:pairs_to_record(RecName, rec_inf(RecName), Pairs).

rec_inf(codeConfidentielDetail)               -> record_info(fields,codeConfidentielDetail);
rec_inf(rcodDetail)                           -> record_info(fields,codeConfidentielDetail);
rec_inf(listeRcodItem)                        ->record_info(fields,listeRcodItem);

rec_inf(servOptResilie)                       -> record_info(fields,servOptResilie);

rec_inf(servOpt)                              -> record_info(fields,servOpt);
rec_inf(comptes)                              -> record_info(fields,comptes);
rec_inf(rechargement)                         -> record_info(fields,rechargement);
rec_inf(uniteGestion)                         -> record_info(fields,code_libelle);
rec_inf(uniteRestitution)                     -> record_info(fields,code_libelle);
rec_inf(typeRestitution)                      -> record_info(fields,code_libelle);
rec_inf(planTarifaire)                        -> record_info(fields,code_libelle);
rec_inf(typeCompte)                           -> record_info(fields,code_libelle);

rec_inf(isRechargementParentChildPossibleResponse) -> record_info(fields,isRechargementParentChildPossibleResponse);
rec_inf(isRechargeableParentChildResponse)    -> record_info(fields, isRechargeableParentChildResponse);
rec_inf(doRechargementParentChildResponse)   -> record_info(fields,doRechargementParentChildResponse);
rec_inf(getIdentificationResponse)            -> record_info(fields,getIdentificationResponse);
rec_inf(getImpactSouscriptionServiceOptionnelResponse) -> record_info(fields,getImpactSouscriptionServiceOptionnelResponse);


rec_inf(getRcodResponse) -> record_info(fields, getRcodResponse);
rec_inf(getVcodResponse)-> record_info(fields, getVcodResponse);
rec_inf(getMcodResponse) ->record_info(fields, getMcodResponse);
rec_inf(getServicesOptionnelsResponse) ->record_info(fields, getServicesOptionnelsResponse);
rec_inf(doModificationServiceOptionnelResponse) ->record_info(fields, doModificationServiceOptionnelResponse);
rec_inf(technologie) -> record_info(fields,technologie);
rec_inf(serviceOptionnel) -> record_info(fields,serviceOptionnel);
rec_inf(code_montant) -> record_info(fields,code_montant);
rec_inf(doRechargementCBResponse) -> record_info(fields, doRechargementCBResponse);
rec_inf(isRechargeableCBResponse) -> record_info(fields, isRechargeableCBResponse);
rec_inf(rechargementPossible) ->  record_info(fields, rechargementPossible);

rec_inf('Fault') ->
    record_info(fields,'Fault');
rec_inf('ECareExceptionTechnique') ->
    record_info(fields,'ECareExceptionTechnique');
rec_inf('ExceptionOffreTypeInexistante') ->
    record_info(fields,'ExceptionOffreTypeInexistante');
rec_inf('ExceptionServiceOptionnelImpossible') ->
    record_info(fields,'ExceptionServiceOptionnelImpossible');
rec_inf('ExceptionServiceOptionnelnexistant') ->
    record_info(fields,'ExceptionServiceOptionnelnexistant');
rec_inf('ExceptionErreurInterne') ->
    record_info(fields,'ExceptionErreurInterne');
rec_inf('ExceptionDonneesInvalides') ->
    record_info(fields,'ExceptionDonneesInvalides');
rec_inf('ExceptionDossierNonTrouve') ->
    record_info(fields,'ExceptionDossierNonTrouve');
rec_inf('ExceptionDateFacturationProche') ->
    record_info(fields,'ExceptionDateFacturationProche');
rec_inf('ExceptionRegleNonVerifiee') ->
    record_info(fields,'ExceptionRegleNonVerifiee');
rec_inf('ExceptionRegleGestionABPRONonVerifiee') ->
    record_info(fields,'ExceptionRegleGestionABPRONonVerifiee');
rec_inf('ExceptionCoupleClientDossierInexistant') ->
    record_info(fields,'ExceptionCoupleClientDossierInexistant');
rec_inf('ECareExceptionFonctionnelleCodeInhbTemp') ->
    record_info(fields,'ECareExceptionFonctionnelleCodeInhbTemp');
rec_inf('ECareExceptionFonctionnelleCodeInhb') ->
    record_info(fields,'ECareExceptionFonctionnelleCodeInhb');
rec_inf('ECareExceptionFonctionnelleCodeNotInit') ->
    record_info(fields,'ECareExceptionFonctionnelleCodeNotInit');
rec_inf('ECareExceptionFonctionnelleCodeLock') ->
    record_info(fields,'ECareExceptionFonctionnelleCodeLock');
rec_inf('ECareExceptionFonctionnelleCodeWrong') ->
    record_info(fields,'ECareExceptionFonctionnelleCodeWrong');
rec_inf('ECareExceptionFonctionnelle') ->
    record_info(fields,'ECareExceptionFonctionnelle');
rec_inf('ExceptionServiceOptionnelRequis') ->
    record_info(fields,'ExceptionServiceOptionnelRequis');
rec_inf('ExceptionPlanRecouvrementIncorrect') ->
    record_info(fields,'ExceptionPlanRecouvrementIncorrect');
rec_inf('ExceptionTypeClientIncorrect') ->
    record_info(fields,'ExceptionTypeClientIncorrect');
rec_inf('ExceptionEtatDossierIncorrect') ->
    record_info(fields,'ExceptionEtatDossierIncorrect');
rec_inf('ExceptionServiceOptionnelBloquant') ->
    record_info(fields,'ExceptionServiceOptionnelBloquant');
rec_inf('ExceptionEtatRecouvrementIncorrect') ->
    record_info(fields,'ExceptionEtatRecouvrementIncorrect');
rec_inf('ExceptionProduitIncorrect') ->
    record_info(fields,'ExceptionProduitIncorrect');
rec_inf('ExceptionDossierNonOrange') ->
    record_info(fields,'ExceptionDossierNonOrange');
rec_inf('ExceptionPaiement') ->
    record_info(fields,'ExceptionPaiement');
rec_inf('ExceptionOptionRequise')->
    record_info(fields,'ExceptionOptionRequise');
rec_inf('ExceptionOptionInterdite')->
    record_info(fields,'ExceptionOptionInterdite');
rec_inf('ExceptionAncienneteRequise') ->
    record_info(fields,'ExceptionAncienneteRequise').




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This function generate a unique msgid of 32 character used by 
%% doRechargmentCB.  This id is identique acrosse time and node.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_msgid() ->
    Now = now(),
    Nodes = oma:get_env(nodes),
    generate_msgid(Now,Nodes).
generate_msgid(Now,Nodes) ->
    Node_id = pid_utils:node_index(node() , Nodes),
    Date_time = date_utils:convert(micros,Now),
    Id = string_utils:to_string(Node_id)++string_utils:to_string(Date_time),
    case string:len(Id) =< 26 of 
        true ->
            %%TODO need a new parameter ?  or directly in code
            string:concat("USSDCB" , string:right(Id,26,$0));
        false  ->
            slog:event(internal, ?MODULE, "id generated is longer than 26 character", [Id])
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Build IBS champs , all parameters should be string()
%%Return {ok , Result} or {error,Error}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
build_secure_IBS(Msgid , NumCarte, Court, FinVal, Cvx2) ->
    case verify(Msgid, NumCarte, Court, FinVal, Cvx2) of
        ok ->
            IBS = "<Msgid>"  ++ Msgid    ++ "</Msgid>"  ++
            "<Nucar>"  ++ NumCarte ++  "</Nucar>" ++
            "<Court>"  ++ Court    ++ "</Court>"  ++
            "<Finval>" ++ FinVal   ++ "</Finval>" ++
            "<Cvx2>"   ++ Cvx2     ++ "</Cvx2>"   ++
                  "<Cmc7></Cmc7>", 
	    case catch des3_crypto:encryption_des3(IBS) of
		{ok,Result} ->
		    {ok,Result};
		{'EXIT',Error} ->
		    slog:event(internal, ?MODULE , "Failed to build IBS encryption", [Error]),		
		    {error,Error}
	    end;
        nok ->
            slog:event(internal, ?MODULE , "format error" , [Msgid,NumCarte,Court,FinVal,Cvx2]),
	    {error,"IBS info format error"}
    end.
            

verify(Msgid , NumCarte ,  Court, FinVal , Cvx2 ) ->
    case length(Msgid) of
	32 ->
	    case length(Court) of 
		0 ->
		    case (length(NumCarte)==16) and (string_utils:all_digits(NumCarte)) and (length(FinVal)==4) and (string_utils:all_digits(FinVal)) and ((length(Cvx2)==3) or (length(Cvx2)==4)) of 
                 
			true -> ok;
			false -> nok
            
		    end;
		4 ->
		    case (length(NumCarte)==0) and (length(FinVal)==0) of 
			true -> ok;
			false -> nok
		    end;
		_ ->
		    nok
	    end;
	_ ->
	    nok
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Function to check is variable Response is a known Exception
%%Return true or false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_exception(Response) ->
    Exception_list = ['ECareExceptionTechnique',
		      'ExceptionOffreTypeInexistante',
		      'ExceptionServiceOptionnelImpossible',
		      'ExceptionServiceOptionnelnexistant',
		      'ExceptionErreurInterne',
		      'ExceptionDonneesInvalides',
		      'ExceptionDossierNonTrouve',
		      'ExceptionDateFacturationProche',
		      'ExceptionRegleNonVerifiee',
		      'ExceptionRegleGestionABPRONonVerifiee',
		      'ExceptionCoupleClientDossierInexistant',
		      'ECareExceptionFonctionnelleCodeInhbTemp',
		      'ECareExceptionFonctionnelleCodeInhb',
		      'ECareExceptionFonctionnelleCodeNotInit',
		      'ECareExceptionFonctionnelleCodeLock',
		      'ECareExceptionFonctionnelleCodeWrong',
		      'ECareExceptionFonctionnelle',
		      'ExceptionServiceOptionnelRequis',
		      'ExceptionPlanRecouvrementIncorrect',
		      'ExceptionTypeClientIncorrect',
		      'ExceptionEtatDossierIncorrect',
		      'ExceptionServiceOptionnelBloquant',
		      'ExceptionEtatRecouvrementIncorrect',
		      'ExceptionProduitIncorrect',
		      'ExceptionDossierNonOrange',
		      'ExceptionPaiement',
		      'ExceptionOptionRequise',
		      'ExceptionOptionInterdite',
		      'ExceptionAncienneteRequise'
		     ], 
    lists:any(fun(Elem)->
		      is_record(Response,Elem) end,Exception_list).
    


soap_req(Req) ->
    Resp = soaplight:request(Req),
    case Resp of
	[{'Header',_},Body] ->
	    Body;
	{ok, {ok,_,500,_,_,BodyResp}} ->
 	    Fault=soaplight:decode_body(BodyResp,?MODULE),
	    slog:event(trace, ?MODULE,
		       exception,
		       Fault),
	    Fault#'Fault'.exception;
	Other ->
	    Other
end.



%%count event should be in format (count,?MODULE,atom)
slog_info(count, ?MODULE, Event) when is_atom(Event)->
    Event_str = atom_to_list(Event),
    case string:str(Event_str,"OK") of 
	0 ->
	    request(Event);
	_->
	    response_OK(Event)
    end;

%%failure event should be in format (failure,?MODULE,{atom,term})
slog_info(failure, ?MODULE,{Event,technical_error}) when is_atom(Event) ->
    response_TECH_NOK;
slog_info(failure, ?MODULE,{Event,Error}) when is_atom(Event) ->
    Event_str = atom_to_list(Event),
    case string:str(Event_str,"NOK") of
	0->
	    %%unknown failure  , your failure is not documented here
	    #slog_info{};
	_ ->
	    response_NOK(Event,Error)
    end;
slog_info(failure, ?MODULE,{Event,'ExceptionPaiement',_,_,_,_,_}) ->
    response_NOK(Event,'ExceptionPaiement');
slog_info(_,_,_)  ->
    #slog_info{}.


request(RequestName)->
    #slog_info{descr="A "++atom_to_list(RequestName)++" request was sent to ASMetier."}.
response_OK(ResponseName)->
  #slog_info{descr="A "++atom_to_list(ResponseName)++" response was successfully return by ASMetier."}.
response_NOK(ResponseName,Error)->
        #slog_info{descr="A "++atom_to_list(ResponseName)++" response was received with the following Exception:"++atom_to_list(Error)++"." ,
	       operational = "1. Check the Counters & Statistics to see if occurrence is high,\n"++
               "2. Check the Logs to identify the Exception and MSISDN,\n"++
               "3. Eventually verify with ASMetier"}.
response_TECH_NOK(ResponseName,Error)->
     #slog_info{descr="This event: "++atom_to_list(ResponseName)++" indicates a technical problem. Either Cellcube did not receive a response (timeout) or Cellcube could not interpret the response." ,
	       operational = "1. Check the Counters & Statistics to see if occurrence is high,\n"++
               "2. Check the Logs to identify the technical problem and MSISDN,\n"++
               "3. Eventually verify with ASMetier"}.






