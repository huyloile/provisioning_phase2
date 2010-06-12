-module(opal).
-export([consult_account/1, encode_consult_account/1]).
-export([consult_catalogue/1, encode_consult_catalogue/1]).
-export([consult_catalogue_with_TU/2, encode_consult_catalogue_with_TU/2]).
-export([activate_present/3, encode_activate_present/3]).
-export([dossier/1]).

%% soaplight Callbacks:
-export([decode_by_name/2, build_record/2]).

-include("../../pfront/include/soaplight.hrl").

dossier(Msisdn) when length(Msisdn) == 10 ->
    Msisdn;
dossier(Msisdn) ->
    [$0 | lists:nthtail(length(Msisdn) - 9, Msisdn)].

opal_request(Message, Trace_signature, Trace_data) ->
    Http_url = pbutil:get_env(pfront_orangef, url_opal),
    {Env_namespace, Body_namespace, Body} = Message,
    Req = #soap_req{
      web_service=opal,    
      http_url = Http_url,
%      http_url = "/pdrsw_G03R04/services/ServicesPDR",
      http_headers = [{"Content-Type","application/xml+soap; charset=utf-8"},
		      {"SOAPAction",""}],
      envnamespaces = Env_namespace,
      bodynamespaces = Body_namespace,
      bodycontent = Body},
    slog:event(trace, ?MODULE, Trace_signature, Trace_data),
    soaplight:request(Req).

consult_account(Msisdn) ->
    opal_request(
      encode_consult_account(Msisdn),
      consult_account,
      Msisdn).
    
encode_consult_account(Msisdn) ->
    encode_request(Msisdn, consulterSolde, []).

consult_catalogue(Msisdn) ->
    opal_request(
      encode_consult_catalogue(Msisdn),
      consult_catalogue,
      Msisdn).

encode_consult_catalogue(Msisdn) ->
    encode_request(Msisdn, consulterCadeaux, [{indRestitution, [], "3"}]).

consult_catalogue_with_TU(Msisdn, TU) ->
    opal_request(
      encode_consult_catalogue_with_TU(Msisdn, TU),
      consult_catalogue_with_TU,
      Msisdn).

encode_consult_catalogue_with_TU(Msisdn, TU) ->
    encode_request(Msisdn, consulterCadeaux, [{idTypeUsage, [], TU},
					      {indRestitution, [], "2"}]).

activate_present(Msisdn, Present_id, Price) ->
    opal_request(
      encode_activate_present(Msisdn, Present_id, Price),
      activate_present,
      Msisdn).

encode_activate_present(Msisdn, Present_id, Price) ->
    encode_request(Msisdn, activerPrime, [{idRecompense, [], Present_id},
					  {prix, [], Price}]).

encode_request(Msisdn, Request, Tail) ->
    {[], [], [{Request, [], [{dossier,[],Msisdn},{canal,[],"USSD"}|Tail]}]}.
    
decode_by_name(Key, Value) ->
    {Key, Value}.

build_record(getConsultationCadeauxReponse, Data) ->
    {value, {date, Date}} = lists:keysearch(date, 1, Data),
    {value, {codeRet, CodeRet}} = lists:keysearch(codeRet, 1, Data),
    case CodeRet of
	"0" ->
	    {value, {resultat, Result}} = lists:keysearch(resultat, 1, Data),
	    Solde = case lists:keysearch(solde, 1, Result) of
			{value, {solde, SoldeCadeaux}} ->
			    SoldeCadeaux;
			_ ->
			    "0"
		    end,
	    Points = case lists:keysearch(pointsLimites, 1, Result) of
			 {value, {pointsLimites, PointsLim}} -> 
			     PointsLim;
			 _ ->
			     "0"
		     end,
	    PointsCB = case lists:keysearch(pointsCB, 1, Result) of
			 {value, {pointsCB, PCB}} -> 
			     PCB;
			 _ ->
			     ""
		     end,
	    Date_limite = case lists:keysearch(jourLimitePts, 1, Result) of
			      {value, {jourLimitePts, DateLim}} ->
				  DateLim;
			      _ ->
				  ""
			  end,
	    {getConsultationCadeauxReponse,
	     [{codeRet, CodeRet},
	      {solde, Solde, PointsCB, Date},
	      {echeance, Points, Date_limite},
 	      usage(Result, []),
	      presents(Result, "","","",[])]};
	ErrorCode ->
	    ErrorCode
    end;
	
build_record(consulterSoldeReponse, Data) ->
    {value, {codeRet, CodeRet}} = lists:keysearch(codeRet, 1, Data),
    case CodeRet of
	"0" ->
	    {value, {resultat, Result}} = lists:keysearch(resultat, 1, Data),
	    {value, Member} = lists:keysearch('IN1', 1, Result),
	    Member_M5plus = case lists:keysearch(isAdherentM5Plus, 1, Result) of
				{value, M5plus} ->
				    M5plus;
				_ ->
				    {isAdherentM5Plus, "false"}
			    end,
	    Target = case lists:keysearch(isCibleM5Plus, 1, Result) of
			 {value, Cible} ->
			     Cible;
			 _ ->
			     {isCibleM5Plus, "false"}
		     end,
	    Target_M5BO = case lists:keysearch(isCibleM5bO, 1, Result) of
			      {value, M5BO} ->
				  M5BO;
			      _ ->
				  {isCibleM5bO, "false"}
			  end,
	    {consulterSoldeReponse, [{codeRet, CodeRet}] ++ accumulate([Member,
							  Member_M5plus,
							  Target,
							  Target_M5BO], [])};
	ErrorCode ->
	    ErrorCode
    end;

build_record(getActivationPrimeReponse, Data) ->
    {value, {codeRet, CodeRet}} = lists:keysearch(codeRet, 1, Data),
    case CodeRet of
        "0" ->
	    {value, {resultat, Result}} = lists:keysearch(resultat, 1, Data),
	    {value, {solde, Solde}} = lists:keysearch(solde, 1, Result),
	    {getActivationPrimeReponse,
	     [{codeRet, CodeRet},
	      {solde, Solde}]};
	ErrorCode ->
	    ErrorCode
    end;

build_record(Key, Value) ->
    {Key, Value}.

accumulate([{'IN1', "true"} | Tail], Acc) ->
    accumulate(Tail, [adherent, Acc]);
accumulate([{isAdherentM5Plus, "true"} | Tail], Acc) ->
    accumulate(Tail, [adherentM5Plus, Acc]);
accumulate([{isCibleM5Plus, "true"} | Tail], Acc) ->
    accumulate(Tail, [cible, Acc]);
accumulate([{isCibleM5bO, "true"} | Tail], Acc) ->
    accumulate(Tail, [cibleM5BO, Acc]);
accumulate([_|T], Acc) ->
    accumulate(T, Acc);
accumulate([], Acc) ->
    lists:reverse(lists:flatten(Acc)).

%presents([{recompense, [{recompense,_} | _]=Presents} | Tail], Acc) ->
%    presents(Presents ++ Tail, Acc);
presents([{recompense, Present} | Tail], Delay, Type, Usage, Acc) ->
    presents(Tail, Delay, Type, Usage, [{Present,Delay,Type,Usage}|Acc]);

presents([{delaiActivation, Value} | Tail], Delay, Type, Usage, Acc) when is_list(Value) ->
    presents(Tail, Value, Type, Usage, Acc);
presents([{idTypeRecompense, Value} | Tail], Delay, Type, Usage, Acc) when is_list(Value) ->
    presents(Tail, Delay, Value, Usage, Acc);
presents([{idTypeUsage, Value} | Tail], Delay, Type, Usage, Acc) when is_list(Value)->
    presents(Tail, Delay, Type, Value, Acc);
presents([{_, Value} | Tail], Delay, Type, Usage, Acc) when is_list(Value) ->
    presents(Value ++ Tail, Delay, Type, Usage, Acc);
presents([_|Tail], Delay, Type, Usage, Acc) ->
    presents(Tail, Delay, Type, Usage, Acc);
presents([], Delay, Type, Usage, Acc) ->
    presents_relevant_data(Acc, []).


presents_relevant_data([{Present,Delay,Type,Usage}|Presents], Acc) ->
    {value, {idRecompense, Id}} = lists:keysearch(idRecompense, 1, Present),
    {value, {prix, Price}} = lists:keysearch(prix, 1, Present),
    presents_relevant_data(Presents, [{Id, Price, Delay, Type, Usage}|Acc]);
presents_relevant_data([], Acc) ->
    {recompenses, Acc}.
    
%usage()[{idTypeUsage, [{idTypeUsage,_} | _]=Presents} | Tail], Acc) ->
%    usage(Presents ++ Tail, Acc);
usage([{idTypeUsage, Present} | Tail],[Present|Acc])->
    usage(Tail, [Present|Acc]);
usage([{idTypeUsage, Present} | Tail],Acc)->
    usage(Tail, [Present|Acc]);
usage([{_, Value} | Tail], Acc) when is_list(Value) ->
    usage(Value ++ Tail, Acc);
usage([_|Tail], Acc) ->
    usage(Tail, Acc);
usage([],Acc)->
    {type_usage, lists:reverse(Acc)}.
