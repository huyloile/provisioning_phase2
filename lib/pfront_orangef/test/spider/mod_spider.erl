-module(mod_spider).

%% Starting function called from a Makefile
-export([start/0]).

%% tests
-export([insert/3, delete/1]).

%% SOAPLight Callbacks
-export([decode_by_name/2,build_record/2]).

%% spawned fun
-export([create_ets/0]).

%% httpserver_server callback:
-export([request/2]).

-define(TABLE_ETS_NAME, spider_table).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() -> spawn(?MODULE, create_ets, []).

create_ets() ->
    Tid = ets:new(?TABLE_ETS_NAME,[named_table,public]),
    loop_sup_ets(Tid).

loop_sup_ets(Tid) ->
     receive
     after 2000 ->
 	    true = ( ets:info(Tid) /= undefined ),
 	    loop_sup_ets(Tid)
     end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

insert(MSISDN, IMSI, XML) ->
    ets:insert(?TABLE_ETS_NAME,{IMSI,MSISDN,XML}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delete({imsi,IMSI}) ->
    ets:delete(?TABLE_ETS_NAME, IMSI);
delete({msisdn,MSISDN}) -> 
    ets:match_delete(?TABLE_ETS_NAME, {'_', MSISDN, '_'}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lookup({"IMSI",IMSI}) ->
    case ets:lookup(?TABLE_ETS_NAME, IMSI) of
	[] -> not_found;
	[{_, _, V}] -> V
    end;
lookup({"MSISDN",MSISDN}) -> 
    case ets:match(?TABLE_ETS_NAME, {'_', MSISDN, '$1'}) of
	[] -> not_found;
	[[V]] -> V
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

request(_,Body) ->
    SoapDec = soaplight:decode_body(Body,?MODULE),
    Resp = build_resp(SoapDec),
    {200,"text/xml",Resp}.

build_resp(Req) -> 
    Id = get_client_id(Req),
    io:format("~n~n~p~n~n",[lookup(Id)]),
    case lookup(Id) of
	not_found -> 
	    "<getBalanceResponse>"
		"<statusList>"
		"<status>"
		"<statusCode>a305</statusCode>"
		"<statusType>1y</statusType>"
		"<statusName>BalanceGetSuccess</statusName>"
		"<statusDescription>Successful get Invocation</statusDescription>"
		"</status>"
		"</statusList>"
		"</getBalanceResponse>";
	timeout -> timeout;
	XML -> XML
    end.

%% +type get_client_id(tuple()) -> {string(),string()}.
get_client_id({getBalanceQuestion, 
	       [_,{resourceType,RT},{resourceValue,Val}|_]}) -> {RT,Val};
get_client_id({getBalanceRequest,Pairs}) ->
    {get_pair_val(resourceType, Pairs), get_pair_val(resourceRef, Pairs)}.

get_pair_val(PairName, []) -> not_found;
get_pair_val(PairName, [{PairName, V}|T]) -> V;
get_pair_val(PairName, [H|T]) -> get_pair_val(PairName, T).    


decode_by_name(Name,Txt) -> {Name,Txt}.
build_record(Name,Pairs) -> {Name,Pairs}.
