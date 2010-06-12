-module(soaplight_orangef).

-include("../../pfront/include/soaplight.hrl").
-include("../../pfront/include/httpclient.hrl").
-include("../../xmerl/include/xmerl.hrl").
-include("../../pdist/include/generic_router.hrl").

%% Main APIs
-export([request/1]).

%% Fun needed by tests
-export([build_xml/3,decode_body/2]).

-export([dump_xml/3]).

%% +type request(soap_req()) -> {ok, Response::deeplist(tuple())} | Error.
request(#soap_req{web_service=Web_serv,
		  http_url=Url,
		  http_headers=HTTPHeaders,
		  envnamespaces=EnvNameSpaces,
		  bodynamespaces=BodyNameSpaces,
		  bodycontent=BodyContent,
		  callbacks_module=CBMod}) ->
    #web_service{routing=Routing,
 		 timeout=Timeout,
 		 trace_xml=TraceXml} = route_to_conf(Web_serv),
    [ _, Host, PortS, URI, _ ] = xmlhttp:parse(Url),
    Port = case PortS of "" -> 80; [$:|Port_] -> list_to_integer(Port_) end,
    HttpBody = build_xml(EnvNameSpaces, BodyNameSpaces, BodyContent),
    HttpReq = #http_request{routing=Routing,
			    host=Host,
			    port=Port,
			    method=post, 
			    url=URI,
			    version="1.1",
			    headers=HTTPHeaders,
			    body=HttpBody,
			    timeout=Timeout},    

    Resp = generic_router:routing_request(?HTTPClient_Module, HttpReq,
				       Timeout),
    do_trace_xml(TraceXml, Web_serv, Resp),
    case Resp of
	{ok,_,200,_,_,BodyResp} ->
	    %% old clause needed for 3.10 Migration.
 	    decode_body(BodyResp,CBMod);
 	{ok, {ok,_,200,_,_,BodyResp}} ->
 	    decode_body(BodyResp,CBMod);
 	Err ->
 	    Err
    end.

%% +type do_trace_xml(trace_xml(), atom(), HttpResponse) -> ok.
do_trace_xml(false, WS, Resp) -> ok;
do_trace_xml({true,Node,Dir}, WS, {ok,_,_,_,_,Xml}) ->
    rpc:call(Node, ?MODULE, dump_xml, [WS, Dir, Xml]);
do_trace_xml(_, _, _) -> ok.

dump_xml(WS, Dir, Xml) ->
    UX = pbutil:unixmtime(),
    File = string:strip(Dir, right, $/) ++ "/" ++ atom_to_list(WS) ++ "_"
	++ integer_to_list(UX) ++ ".xml",
    file:write_file(File, list_to_binary(Xml)).
	    

%% +type route_to_conf(WebServiceName::atom()) -> web_service().
route_to_conf(WebServiceName) ->
    WebServices = pbutil:get_env(pfront, web_services),
    {value,WebService} = lists:keysearch(WebServiceName, #web_service.name, 
					 WebServices),
    WebService.

%% +deftype ns_list() = [{atom(), Url::string()}].
%% +type build_xml(ns_list(),ns_list(),XmerlSimpleForm::deeplist(tuple())) ->
%%  deeplist(xmerl:xml()).
build_xml(EnvNameSpaces, BodyNameSpaces, BodyContent) ->
    XMLSimple =
	{'SOAP-ENV:Envelope', defaultEnvNameSpaces() ++ EnvNameSpaces,
	 [{'SOAP-ENV:Body', BodyNameSpaces,BodyContent}] },
    xmerl:export_simple(XMLSimple, xmerl_xml).%%2nd arg is the callback module

%% +type defaultEnvNameSpaces() -> ns_list().
defaultEnvNameSpaces() ->
    [{'xmlns:xsi',"http://www.w3.org/2001/XMLSchema-instance"},
     {'xmlns:SOAP-ENC',"http://schemas.xmlsoap.org/soap/encoding/"},
     {'xmlns:SOAP-ENV',"http://schemas.xmlsoap.org/soap/envelope/"},
     {'xmlns:xsd',"http://www.w3.org/2001/XMLSchema"},
     {'SOAP-ENV:encodingStyle', "http://schemas.xmlsoap.org/soap/encoding/"}].

%% +type decode_body(Xml,Module::atom()) -> deeplist(tuple()).
decode_body(Xml,CBMod) ->
    XmerlOpts = [{space,normalize},
		 {hook_fun,fun hook/2},
		 {user_state,CBMod}],
    {_XmerlScanner, Dec} = xmerl_scan:string(Xml,XmerlOpts),
    case Dec of
	[OneElem] -> OneElem;
	L -> L
    end.

hook(#xmlElement{expanded_name={_,'Envelope'},content=EnvContent},Scanner) ->
    {flat_rm_xtxts(EnvContent),Scanner};
hook(#xmlElement{expanded_name={_,'Body'},content=BodyContent},Scanner) ->
    {flat_rm_xtxts(BodyContent),Scanner};
hook(#xmlElement{expanded_name=EN,content=C},Scanner) ->
    Name = expname2name(EN),
    C2 = flat_rm_xtxts(C),
    CBMod = xmerl_scan:user_state(Scanner),
    Dec = case C2 of
	      [#xmlText{}|_] -> 
		  Txt = xmlTxts2string(C2),
		  CBMod:decode_by_name(Name,Txt);
	      List -> 
		  CBMod:build_record(Name,C2)
	  end,
    {Dec, Scanner};
hook(Other,Scanner) -> {Other,Scanner}.

expname2name({_,Name}) -> Name;
expname2name(Name) -> Name.

flat_rm_xtxts(Elts) ->
    lists:flatten(rm_xtxts(Elts)).

rm_xtxts([]) -> [];
rm_xtxts([#xmlText{value=" "}|T]) -> rm_xtxts(T);
rm_xtxts([H|T]) -> [H|rm_xtxts(T)].

xmlTxts2string([]) -> [];
xmlTxts2string([#xmlText{value=V}|T]) -> V++xmlTxts2string(T).
