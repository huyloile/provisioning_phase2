-module(pdr).

-compile(export_all).

-include("../../pfront/include/soaplight.hrl").
-include("../include/pdr.hrl").

-define(PDR_NS, "http://localhost/pdr/services/").
-define(IDENTIFIANT_CANAL,"USSD").

%% +type getAccesPDR(MSISDN::string()) ->
%%  getAccesPDRReponse() | {'EXIT',Reason}.
getAccesPDR(MSISDN) ->
    Req = #soap_req{
      web_service=pdr,
      http_headers=[{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      bodycontent=[{'impl:getAccesPDR', [{'xmlns:impl',?PDR_NS}],
		    [{dossier,MSISDN},
		     {canal,?IDENTIFIANT_CANAL}]}]},
    case soaplight:request(Req) of
	Resp when record(Resp,getAccesPDRReponse) -> Resp;
	{'EXIT',{timeout,_}} ->
	    slog:event(count,?MODULE,getAccesPDRReponse_timeout),
	    {error,getAccesPDRReponse_timeout};
	Else ->
	    slog:event(failure,?MODULE,Else),
	    {error,Else}
    end.
    
%% +type getConsultationSolde(MSISDN::string()) ->
%%  getConsultationSoldeReponse() | {'EXIT',Reason}.
getConsultationSolde(MSISDN) ->
    Req = #soap_req{
      web_service=pdr,
      http_headers=[{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      bodycontent=[{'impl:getConsultationSolde',[{'xmlns:impl',?PDR_NS}],
		    [{dossier,MSISDN},
		     {canal,?IDENTIFIANT_CANAL},
		     {restUPC,"N"}]}]},
    case soaplight:request(Req) of
	Resp when record(Resp,getConsultationSoldeReponse) -> Resp;
	{'EXIT',{timeout,_}} ->
	    slog:event(count,?MODULE,getConsultationSolde_timeout),
	    {error,getConsultationSolde_timeout};
	Else ->
	    slog:event(failure,?MODULE,Else),
	    {error,Else}
    end.

%% +type getConsultationPrimes(MSISDN::string(),IDUP::string()) ->
%%  getConsultationPrimesReponse() | {'EXIT',Reason}.
getConsultationPrimes(MSISDN,IDUP) ->
    Req = #soap_req{
      web_service=pdr,
      http_headers=[{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      bodycontent=[{'impl:getConsultationPrimes', [{'xmlns:impl',?PDR_NS}],
		    [{dossier,MSISDN},
		     {canal,?IDENTIFIANT_CANAL},
		     {idUP,IDUP}]}]},
    case soaplight:request(Req) of
	Resp when record(Resp,getConsultationPrimesReponse) -> Resp;
	{'EXIT',{timeout,_}} ->
	    slog:event(count,?MODULE,getConsultationPrimes_timeout),
	    {error,getConsultationPrimes_timeout};
	Else ->
	    slog:event(failure,?MODULE,Else),
	    {error,Else}
    end.

%% +type getActivationPrimes(MSISDN::string(),IDPALIER::string()) -> 
%%  getActivationPrimesReponse() | {'EXIT',Reason}.
getActivationPrimes(MSISDN,IDPALIER) ->
    Req = #soap_req{
      web_service=pdr,
      http_headers=[{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      bodycontent=[{'impl:getActivationPrimes',[{'xmlns:impl',?PDR_NS}],
		    [{dossier,MSISDN},
		     {canal,?IDENTIFIANT_CANAL},
		     {idPalier,IDPALIER}]}]},
    case soaplight:request(Req) of
	Resp when record(Resp,getActivationPrimesReponse) -> Resp;
	{'EXIT',{timeout,_}} ->
	    slog:event(count,?MODULE,getActivationPrimes_timeout),
	    {error,getActivationPrimes_timeout};
	Else ->
	    slog:event(failure,?MODULE,Else),
	    {error,Else}
    end.

%% +deftype pair()=tuple().

%% +type decode_by_name(Tag::atom(),string()) ->
%%  pair().
decode_by_name(codeRet,Txt) -> {codeRet,list_to_integer(Txt)};
decode_by_name(Name,Txt) -> {Name,Txt}.

%% +type build_record(Tag::atom(),Pairs::[pair()]) ->
%%  record() | pair().
%build_record(requete,Pairs) -> no_tasks;
build_record(getAccesPDRReponse,Pairs) ->
    pbutil:pairs_to_record(getAccesPDRReponse,
			   record_info(fields,getAccesPDRReponse),Pairs);
build_record(getActivationPrimesReponse,Pairs) ->
    pbutil:pairs_to_record(getActivationPrimesReponse,
			   record_info(fields,getActivationPrimesReponse),
			   Pairs);
build_record(getConsultationSoldeReponse,Pairs) ->
    pbutil:pairs_to_record(getConsultationSoldeReponse,
			   record_info(fields,getConsultationSoldeReponse),
			   Pairs);
build_record(getConsultationPrimesReponse,Pairs) ->
    pbutil:pairs_to_record(getConsultationPrimesReponse,
			   record_info(fields,getConsultationPrimesReponse),
			   Pairs);
build_record(resultat,Pairs) -> 
    {resultat,
     pbutil:pairs_to_record(resultat,record_info(fields,resultat),Pairs)};
build_record(descUP,Pairs) -> 
    pbutil:pairs_to_record(descUP,record_info(fields,descUP),Pairs);
build_record(descUPE,Pairs) -> 
    pbutil:pairs_to_record(descUPE,record_info(fields,descUPE),Pairs);
build_record(descPalier,Pairs) ->
    pbutil:pairs_to_record(descPalier,record_info(fields,descPalier),Pairs);
build_record(solde,Pairs) ->
    {solde,pbutil:pairs_to_record(solde,record_info(fields,solde),Pairs)};
build_record(Name,Pairs) -> {Name,Pairs}.
