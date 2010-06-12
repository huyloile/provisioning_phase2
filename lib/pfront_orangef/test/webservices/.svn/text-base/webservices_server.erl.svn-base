-module(webservices_server).

-include_lib("inets/src/httpd.hrl").

%% Starting function called from a Makefile
-export([start/0]).

%% INETS Callback
-export([do/1]).

%% SOAPLight Callbacks
-export([decode_by_name/2,build_record/2]).

-define(ioformat(FMT,ARGs),
	io:format("~p:"?MODULE_STRING++":"++FMT,[self()|ARGs])).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->
    ConfFile = dir()++"/conf/httpd.conf",
    spawn(httpd, start, [ConfFile]).

dir() ->
    code:lib_dir(pfront_orangef)++"/test/webservices".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do(#mod{method="POST", request_uri=R_URI, data=Data, entity_body=Body}) ->
    CB = get_cb_by_url(R_URI),
    SoapResp = CB(Body),
    HttpResp = ["Content-Type: text/xml\r\n",
		"Content-Length: ",
		integer_to_list(httpd_util:flatlength(SoapResp)),
		"\r\n\r\n",SoapResp],
    {proceed,[{response,{200,HttpResp}}|Data]};

do(#mod{method="GET", data=Data}) ->
    Resp = webmin:html(
	     "Fake Spider server",
	     "<h2>Hi there, this is a fake Spider server, "
	     "Perhaps there will be a form for invoking "
	     "the service here...</h2>"),
    {proceed,[{response,{200,Resp}}|Data]}.

get_cb_by_url(URL) ->
    ?ioformat("get_cb_by_url ~p~n", [URL]),
    Serv = case string:tokens(URL, "/") of
	       [] -> URL;
	       L -> lists:last(L)
	   end,
    get_cb_by_serv(Serv).

get_cb_by_serv("ServicesPDR") -> fun pdr/1;
get_cb_by_serv("GetBalance") -> fun spider/1;
get_cb_by_serv("orchideeService") -> fun orchidee/1;
get_cb_by_serv(Serv)
  when Serv=="GetCodeConfidentiel";
       Serv=="CheckCodeConfidentiel";
       Serv=="SetCodeConfidentiel";
       Serv=="CheckRechargementParentChild";
	   Serv=="SetRechargementParentChild"
     -> fun parentChild/1;
get_cb_by_serv(Serv)
  when Serv=="sdaService";
       Serv=="sachemService"
     -> fun parentChild/1;

get_cb_by_serv(Serv) 
  when Serv=="GetIdentification";
       Serv=="identificationService";
       Serv=="GetListServiceOptionnel";
       Serv=="SetServiceOptionnel"
            -> fun postpaid_cmo/1;
get_cb_by_serv(Other) -> 
    fun(_) -> "<error>service "++Other++" is unknown</error>" end.

spider(XmlBody) ->
    {getBalanceQuestion,Elems} = soaplight:decode_body(XmlBody, ?MODULE),
    "MSISDN" = get_pairval(resourceType, Elems),
    MSISDN = get_pairval(resourceValue, Elems),
    File = dir()++"/spider/"++MSISDN++".xml",
    case file:read_file(File) of
	{ok, Bin} -> binary_to_list(Bin);
	_ -> "<file_not_found>"++File++"</file_not_found>"
    end.

orchidee(XmlBody) ->
    slog:event(trace,?MODULE,orchidee,XmlBody),
    Dec = {ReqType,Childs} = soaplight:decode_body(XmlBody, ?MODULE),
    FileName =
	case ReqType of
	    isRechargementParentChildPossible ->
 		"/parentChild/"++"ISRECH_"++get_pairval(numMSISDN,Childs)++"_";
	    isRechargeableParentChild ->
		"/parentChild/"++"ISRECHARGEABLE_"++get_pairval(numMSISDN,Childs);
	    setRechargementParentChild -> 
		"/parentChild/"++"SETRECH_"++get_pairval(msisdnRechargeur,Childs)++"_"++
		    get_pairval(msisdnRecharge,Childs);
	    doRechargementParentChild ->
 		"/parentChild/"++"DORECH_"++get_pairval(numMSISDNRechargeur,Childs)++"_"++
                     get_pairval(numMSISDNRecharge,Childs);
	    getRcod ->
		"/parentChild/"++"GETRCOD_"++get_pairval(msisdn,Childs);
	    getVcod  ->
		"/parentChild/"++"GETVCOD_"++get_pairval(msisdn,Childs)++"_"++get_pairval(codeValeur,Childs);
	    getMcod  ->
		"/parentChild/"++"GETMCOD_"++get_pairval(msisdnRechargeur,Childs)++"_"++
		    get_pairval(msisdnRecharge,Childs);

	    getImpactSouscriptionServiceOptionnel -> 
		"/postpaid_cmo/"++"GETIMPACT_"++get_pairval(idDossier,Childs)++"_"++
		    get_pairval(idServiceOptionnel,Childs);
	    getServicesOptionnels ->
		"/postpaid_cmo/"++"GETSERVOPT_"++get_pairval(idDossier,Childs);
	    doModificationServiceOptionnel -> 
		"/postpaid_cmo/"++"DOMODSERVOPT_"++get_pairval(idDossier,Childs);
	    _ ->
		"unknownService"
	
	end,
    File = dir()++FileName++".xml",
    case file:read_file(File) of
	{ok, Bin} -> binary_to_list(Bin);
	_ ->
	    "<error>File not found: "++File++"</error>"
    end.
    
parentChild(XmlBody) ->    
    slog:event(trace,?MODULE,parentChild,XmlBody),
    Dec = {ReqType,Childs} = soaplight:decode_body(XmlBody, ?MODULE),
    slog:event(trace,?MODULE,parentChild_dec,Dec),
    FileName =
	case ReqType of
	    getCodeConfidentiel -> 
		"GETCODECONF_"++get_pairval(msisdn,Childs);
	    checkCodeConfidentiel -> 
		"CHECKCODECONF_"++get_pairval(msisdn,Childs)++"_"++get_pairval(codeValeur,Childs);
	    setCodeConfidentiel -> 
		"SETCODECONF_"++get_pairval(msisdn,Childs)++"_"++
		    get_pairval(codeValeur,Childs);
	    checkRechargementParentChild -> 
		"CHECKRECH_"++get_pairval(msisdnRechargeur,Childs)++"_"++
		    get_pairval(msisdnRecharge,Childs);
	    isRechargementParentChildPossible ->
 		"ISRECH_"++get_pairval(numMSISDN,Childs)++"_";
	    isRechargeableParentChild ->
		"ISRECHARGEABLE_"++get_pairval(numMSISDN,Childs);
	    setRechargementParentChild -> 
		"SETRECH_"++get_pairval(msisdnRechargeur,Childs)++"_"++
		    get_pairval(msisdnRecharge,Childs);
	    doRechargementParentChild ->
 		"DORECH_"++get_pairval(numMSISDNRechargeur,Childs)++"_"++
                     get_pairval(numMSISDNRecharge,Childs);
	    getRcod ->
		"GETRCOD_"++get_pairval(numDossier,Childs);
	    getVcod  ->
		"GETVCOD_"++get_pairval(numDossier,Childs)++"_"++get_pairval(code,Childs);
	    getMcod  ->
		"GETMCOD_"++get_pairval(msisdnRechargeur,Childs)++"_"++
		    get_pairval(msisdnRecharge,Childs);
	    _ ->
		"unknownService"
	
	end,
    File = dir()++"/parentChild/"++FileName++".xml",
    case file:read_file(File) of
	{ok, Bin} -> binary_to_list(Bin);
	_ ->
	    "<error>File not found: "++File++"</error>"
    end.

pdr(XmlBody) ->
    {ReqType,Childs} = soaplight:decode_body(XmlBody, ?MODULE),
    MSISDN = get_pairval(dossier, Childs),
    FileAbs = 
	case ReqType of
	    getAccesPDR -> 
		"CONSELIG_"++MSISDN;
	    getConsultationSolde -> 
		"CONSSOLDE_"++MSISDN++"_"++get_pairval(restUPC, Childs);
	    getConsultationPrimes -> 
		"CONSPRIME_"++MSISDN++"_"++get_pairval(idUP, Childs);
	    getActivationPrimes -> 
		"ACTIVPRIME_"++MSISDN++"_"++get_pairval(idPalier, Childs);
	    _ ->
		"unknownService"
	end,
    File = dir()++"/pdr/"++FileAbs++".xml",
    case file:read_file(File) of
	{ok, Bin} -> binary_to_list(Bin);
	_ -> %%io:format("parentChild, fichier ~p non trouve~n", [File]),
	    "<error>not_found</error>"
    end.

postpaid_cmo(XmlBody) ->
    slog:event(trace,?MODULE,postpaid_cmo,XmlBody),
    Dec = {ReqType,Childs} = soaplight:decode_body(XmlBody, ?MODULE),
    slog:event(trace,?MODULE,postpaid_cmo_dec,Dec),
    FileName =
	case ReqType of
	    getIdentification -> 
		MSISDN = get_pairval(msisdn,Childs),
		"GETIDENT_"++msisdn_int(MSISDN);
	    getImpactSouscriptionServiceOptionnel -> 
		"GETIMPACT_"++get_pairval(idDossier,Childs)++"_"++
		    get_pairval(idServiceOptionnel,Childs);
	    getListServiceOptionnel -> 
		"GETLIST_"++get_pairval(idDossierOrchidee,Childs);
	    setServiceOptionnel -> 
		"SETSERVOPT_"++get_pairval(idDossierOrchidee,Childs);
	    getServicesOptionnels ->
		"GETSERVOPT_"++get_pairval(idDossier,Childs);
	    doModificationServiceOptionnel -> 
		"DOMODSERVOPT_"++get_pairval(idDossier,Childs);
	    isRechargeableParentChild ->
		"ISRECHARGEABLE_"++get_pairval(numMSISDN,Childs);
	    _ ->
		"unknownService"
	end,
    File = dir()++"/postpaid_cmo/"++FileName++".xml",
    case file:read_file(File) of
	{ok, Bin} -> 
	    binary_to_list(Bin);
	_ -> %%io:format("parentChild, fichier ~p non trouve~n", [File]),
	    "<error>File not found: "++File++"</error>"
    end.

decode_by_name(Name,Txt) -> {Name,Txt}.
build_record(in0,Pairs) -> Pairs;
build_record(Name,Pairs) -> {Name,Pairs}.

% get_pairval(PairN, Pairs, DefVal) ->
%     case get_pairval(PairN, Pairs) of
% 	undef -> DefVal;
% 	V -> V
%     end.
	    
get_pairval(PairN, Pairs) ->
    case lists:keysearch(PairN, 1, Pairs) of
	{value, {_,V}} -> V;
	_-> "_"++atom_to_list(PairN)++"_undef"
    end.
			      
%% +type msisdn_int(string())-> string().
msisdn_int([$0|Msisdn]) -> 
    case Msisdn of
	[$9, $0, $1| _] ->
	    "+99"++Msisdn;
	[$3| _] ->
	    "+99"++Msisdn;
	_ ->
	    "+33"++Msisdn
    end.
