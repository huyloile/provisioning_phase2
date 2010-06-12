-module(spider).

-export([getBalance/4]).

%% soaplight Callbacks:
-export([decode_by_name/2,build_record/2]).

-import(pbutil, [pairs_to_record/3]).

-include("../../pfront/include/soaplight.hrl").
-include("../include/spider.hrl").

%% +deftype resourceType()=string().  %% "IMSI"|"MSISDN".
%% +deftype resourceValue()=string(). %% "208XXXXXXXXXXXX"|"0XXXXXXXX" 
%% +deftype offerType()=string().   %% "postpaid"|"entreprise"|"".
%% +deftype ussdLevel()=string().     %% "1"|"2"|"3"|"".
%% +type getBalance(resourceType(),resourceValue(),offerType(),ussdLevel())
%%  -> spider_response().
getBalance(ResourceType, ResourceRef, OfferType, UssdLevel) ->
    WebServ = case OfferType of
		  "postpaid" -> spider_postpaid;
		  "entreprise" -> spider_entreprise;
		  "prepaid" -> spider_prepaid;
		  "" -> spider_unknown_sub
	      end,
    Http_url = pbutil:get_env(pdist_orangef, spider_http_url),
    Xmlns_url = pbutil:get_env(pdist_orangef, spider_xmlns_url),
    Req = #soap_req{
      web_service=WebServ,
						%      http_url="/spider/services/GetBalance",
      http_url = Http_url,
      http_headers=[{"Content-Type","text/xml; charset=utf-8"},
		    {"SOAPAction",""}],
      bodycontent=[{getBalanceRequest, 
						%		    [{xmlns,"http://localhost:8080/SPIDER/services"}],
		    [{xmlns, Xmlns_url}],
		    [{uuid, "123456"},
		     {lang, "fr_FR"},
		     {channel, "01"},
		     {resourceType, ResourceType},
		     {resourceRef, ResourceRef},
		     {source, "USSD"}] ++
		    optpair({offerType, OfferType}) ++
		    optpair({restitutionLevel, UssdLevel})
		   }] },
    Current_time = oma:unixmtime(),
    Resp =
	case catch pbutil:get_env(pfront_orangef, spider_version) of
	    online->
		slog:event(trace,?MODULE,spider_version,online),
		spider_online:request(ResourceType, ResourceRef);
	    _->
		slog:event(trace,?MODULE,spider_version,spider_G4R3),
		try soaplight:request(Req)
                catch Class:Error -> {error,{Class,Error}}
		end
	end,
    slog:delay(perf, ?MODULE, response_time, Current_time),
    slog:event(trace, ?MODULE, {WebServ, getBalance},
	       {ResourceType, ResourceRef, OfferType, UssdLevel}),
    case Resp of
        #spider_response{statusList=[#status{statusCode=[_,_,$0,$0]}|_],
			 file=F,bundles=Bundles} ->
            slog:event(trace, ?MODULE, {WebServ, response_ok}, Resp),
  	    List_Offertype = pbutil:get_env(pservices_orangef, list_Offertype),	    
	    case lists:member(list_to_atom(F#file.offerType), List_Offertype) of
		true ->
		    case F#file.offerType of
			"entreprise" ->
			    %% spider does not allow identification of MVNOs (ex OPIM)
			    %% from dme...
			    case Bundles of 
				[#bundle{bundleType=BundleType}|_] -> 
				    case BundleType of
					BundleType when BundleType=="undefined";BundleType==[];
							BundleType=="0002"->
					    {ok, "entreprise", Resp};
					BundleType when BundleType=="0027" -> 
					    {ok, "opim", Resp};
					_ -> 
					    {ok, "dme", Resp}
				    end;
				_ ->
				    {ok, "entreprise",Resp}
			    end;
			"postpaid"   ->
			    {ok, "postpaid", Resp};
			"prepaid" ->
			    List = pbutil:get_env(pservices_orangef, codeOffre_codeDomaine_souscription_packageOTO),
			    OfferPOrSUid=F#file.offerPOrSUid,    
			    case lists:keysearch(OfferPOrSUid, 1, List) of 
				{value, {Offer,_,Restitution,_}} 
				when Restitution=="cmo";
				     Restitution=="mobi"->
				    {ok, Restitution, Resp};
				{value, {Offer,_,"postpaid",_}}->
				    slog:event(warning, ?MODULE, {WebServ, is_not_prepaid_offre},
					       {ResourceType,ResourceRef,OfferPOrSUid}),
				    unknown_user;
				{value, {Offer,_,Restitution,_}}->
				    Subs_mvno = pbutil:get_env(pservices_orangef,subscription_mvno),
				    case lists:member(Restitution, Subs_mvno) of
					true ->
					    slog:event(failure, ?MODULE, {WebServ, failure_subs_mvno_in_spider},
						       {ResourceType,ResourceRef,OfferPOrSUid}),
					    unknown_user;
					_->
					    slog:event(failure, ?MODULE, {WebServ, unknown_prepaid_offer},
						       {ResourceType,ResourceRef,OfferPOrSUid}),
					    unknown_user
				    end;
				_ ->
				    slog:event(failure, ?MODULE, {WebServ, unknown_prepaid_offer},
					       {ResourceType,ResourceRef,OfferPOrSUid}),
				    unknown_user
			    end
		    end;
		_->    
		    slog:event(failure, ?MODULE, {WebServ, unknown_offertype}, Resp),
		    unknown_user
	    end;

	#spider_response{statusList=[#status{statusCode=[_,_|Code],statusDescription=Description}|_]} ->
	    case Code of
		?DOSSIER_INCONNU ->
		    slog:event(failure, ?MODULE, {WebServ, dossier_inconnu}, ResourceRef),
		    unknown_user;
		?PROBLEME_TECHNIQUE ->
		    IndexSubStatus = string:str(Description, "240"),
		    Module = case IndexSubStatus of 
				 0->
				     no_module;
				 _->
				     IndexModuleSachem=string:str(Description, "SACHEM"),
				     IndexModuleGloria=string:str(Description, "GLORIA"),
				     IndexModuleDise=string:str(Description, "DISE"),
				     IndexModuleSda=string:str(Description, "SDA"),
				     IndexModuleInfranet=string:str(Description, "INFRANET"),
				     if 
					 IndexModuleSachem > 0 ->
					     sachem;
					 IndexModuleGloria > 0 ->
					     gloria;
					 IndexModuleDise > 0 ->
					     dise;
					 IndexModuleSda > 0 ->
					     sda;
					 IndexModuleInfranet > 0 ->
					     infranet;
					 true->
					     no_module
				     end
			     end,
		    slog:event(failure, ?MODULE, {WebServ, probleme_technique}, ResourceRef),
		    {spider_error, {Code, Module}};		
		Code_ when Code_==?SERVICE_INDISPONIBLE;
			   Code_==?ACCES_REFUSE->
		    {spider_error, Code};
		_ ->
		    slog:event(failure, ?MODULE, {WebServ, Code}, ResourceRef),
		    {spider_error, {Code, invalid_code}}
	    end;
	{'EXIT',{timeout,TimeoutR}} ->
	    slog:event(failure, ?MODULE, {WebServ,timeout}, TimeoutR),
	    {spider_error, {no_resp, timeout}};
	{error,tcp_closed} ->
	    slog:event(failure, ?MODULE, {WebServ,tcp_closed},ResourceRef),
	    {spider_error, {no_resp, tcp_closed}};
	Other ->
	    slog:event(failure, ?MODULE, {WebServ,no_resp}, Other),
	    {spider_error, no_resp}
    end.

%% +type optpair(Pair) -> [Pair].
optpair({_,""}) -> [];
optpair(Pair) -> [Pair].




%%%% Callbacks needed by soaplight.erl :

-define(xsd_dateTime(N),
	N==reactualDate;
	N==nextInvoice;
	N==desactivationDate;
	N==invoiceDate;
	N==validityDate;
	N==previousPeriodLastUseDate;
	N==firstUseDate;
	N==lastUseDate).

%% +type decode_by_name(atom(),string()) -> {atom(),string()}.
decode_by_name(Name,Txt) when ?xsd_dateTime(Name) ->
    {Name,dec_xsd_dateTime(Txt)};
decode_by_name(fileState,Txt) -> 
    {fileState,Txt};
decode_by_name(Name,Txt) -> {Name,Txt}.

%% +type dec_xsd_dateTime(string()) -> calendar:datetime().
dec_xsd_dateTime(Date) ->
    {[Y,M,D,H,Mi,S],_}=pbutil:sscanf("%d-%d-%dT%d:%d:%d",Date),
    calendar:universal_time_to_local_time({{Y,M,D},{H,Mi,S}}).

%% +type build_record(TagName::atom(),Pairs) ->
%%  record() | {TagName,record()} | {TagName,Pairs}.
build_record(credit,Pairs) -> 
    pairs_to_record(credit,record_info(fields,credit),Pairs);
build_record(bundle,Pairs) -> 
    pairs_to_record(bundle,record_info(fields,bundle),Pairs);
build_record(amount,Pairs) -> 
    pairs_to_record(amount,record_info(fields,amount),Pairs);
build_record(file,Pairs) -> 
    {file,pairs_to_record(file,record_info(fields,file),Pairs)};
build_record(getBalanceResponse,Pairs) -> 
    pairs_to_record(spider_response,record_info(fields,spider_response),Pairs);
build_record(status,Pairs) ->
    pairs_to_record(status,record_info(fields,status),Pairs);
build_record(Name,Pairs) -> {Name,Pairs}.
