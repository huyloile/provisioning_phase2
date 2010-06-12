-module(mipc_vpbx_webserv).


-export([activerSituation/3,
         consulterInformations/2,
         consulterParametrageReel/2,
         consulterSituation/3,
         listeSituationsParametrees/2,
         situationActive/2]).

-export([decode_by_name/2,
         build_record/2
        ]).
         
-export([slog_info/3]).
-include("../../oma/include/slog.hrl").

-include("../../pfront/include/soaplight.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/include/mipc_vpbx_webserv.hrl").

-define(ACTIVERSITUATION,"activerSituation_Request").
-define(CONSULTERINFORMATIONS,"consulterInformations_Request").
-define(CONSULTERPARAMETRAGEREEL, "consulterParametrageReel_Request").
-define(CONSULTERSITUATION, "consulterSituation_Request").
-define(LISTESITUATIONPARAMETREES, "listeSituationsParametrees_Request").
-define(SITUATIONACTIVE, "situationActive_Request").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% VPBX requests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




activerSituation(Msisdn,IdS,WebService) ->
    Url = get_url(WebService),
    Content_type = pbutil:get_env(pfront_orangef, mipc_vpbx_content_type),
    Req = #soap_req{
      web_service = WebService,
      http_url = Url,
      http_headers = [{"Content-Type",Content_type},
                      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?ACTIVERSITUATION),
      bodynamespaces = [],
      bodycontent = 
      [{'tns1:activerSituation',
        [{numeroLigne, Msisdn},
         {idSituation, IdS}]
       }]},
    slog:event(trace, ?MODULE,activerSituation,{Msisdn,IdS,Req}),
    Response = 
        case pbutil:get_env(pfront_orangef, mipc_vpbx_version) of
            online->
                mipc_vpbx_online:request_activerSituation(Msisdn, atom_to_list(WebService));
            _->
                soaplight_orangef:request(Req)
        end,
    analyse_response(Response,activerSituation_nok).

consulterInformations(Msisdn, WebService) ->
    Url = get_url(WebService),
    Content_type = pbutil:get_env(pfront_orangef, mipc_vpbx_content_type),
    Req = #soap_req{
      web_service = WebService,
      http_url = Url,
      http_headers = [{"Content-Type",Content_type},
		      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?CONSULTERINFORMATIONS),
       bodycontent = 
      [{'tns1:consulterInformations',
        [{numeroLigne, Msisdn}]
       }]
     },
    slog:event(trace, ?MODULE,consulterInformations,{Msisdn,Req}),
    Response = 
        case pbutil:get_env(pfront_orangef, mipc_vpbx_version) of
            online->
                mipc_vpbx_online:request_consulterInformations(Msisdn, atom_to_list(WebService));
            _->
                soaplight_orangef:request(Req)
        end,
    analyse_response(Response,consulterInformations_nok).

consulterParametrageReel(Msisdn, WebService) ->
    Url = get_url(WebService),
    Content_type = pbutil:get_env(pfront_orangef, mipc_vpbx_content_type),
    Req = #soap_req{
      web_service = WebService,
      http_url  = Url,
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
                      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?CONSULTERPARAMETRAGEREEL),
      bodycontent =
      [{'tns1:consulterParametrageReel',
        [{numeroLigne, Msisdn}
        ]
       }
      ]
     },
    slog:event(trace, ?MODULE,consulterParametrageReel,{Msisdn,Req}),
    Response = 
        case pbutil:get_env(pfront_orangef, mipc_vpbx_version) of
            online->
                mipc_vpbx_online:request_consulterParametrageReel(Msisdn, atom_to_list(WebService));
            _->
                soaplight_orangef:request(Req)
        end,
    analyse_response(Response,consulterParametrageReel_nok).

consulterSituation(Msisdn,Ids, WebService) ->
    Url = get_url(WebService),
    Content_type = pbutil:get_env(pfront_orangef, mipc_vpbx_content_type),
    Req = #soap_req{
      web_service = WebService,
      http_url  = Url,
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
                      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?CONSULTERSITUATION),
      bodynamespaces = [],
      bodycontent = 
      [{'tns1:consulterSituation',
        [{numeroLigne, Msisdn},
         {idSituation, Ids}]
       }]},
    slog:event(trace, ?MODULE,consulterSituation,{Msisdn,Req}),
    Response = 
        case pbutil:get_env(pfront_orangef, mipc_vpbx_version) of
            online->
                mipc_vpbx_online:request_consulterSituation(Msisdn, atom_to_list(WebService));
            _->
                soaplight_orangef:request(Req)
        end,
    analyse_response(Response,consulterSituation_nok).

listeSituationsParametrees(Msisdn, WebService) ->
    Url = get_url(WebService),
    Content_type = pbutil:get_env(pfront_orangef, mipc_vpbx_content_type),
    Req = #soap_req{
      web_service = WebService,
      http_url  = Url,
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
                      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?LISTESITUATIONPARAMETREES),
      %%bodynamespaces = [],
      bodycontent = 
      [{'tns1:listeSituationsParametrees',
        [{numeroLigne, Msisdn}]
       }]},
    slog:event(trace, ?MODULE,listeSituationsParametrees,{Msisdn,Req}),
    Response = 
        case pbutil:get_env(pfront_orangef, mipc_vpbx_version) of
            online->
                mipc_vpbx_online:request_listeSituationsParametrees(Msisdn, atom_to_list(WebService));
            _->
                soaplight_orangef:request(Req)
        end,
    analyse_response(Response,listeSituationsParametrees_nok).

situationActive(Msisdn, WebService) ->
    Url = get_url(WebService),
    Content_type = pbutil:get_env(pfront_orangef, mipc_vpbx_content_type),
    Req = #soap_req{
      web_service = WebService,
      http_url  = Url,
      http_headers = [{"Content-Type","text/xml; charset=utf-8"},
                      {"SOAPAction",""}],
      envnamespaces = envNameSpaces(?SITUATIONACTIVE),
      %%bodynamespaces = [],
      bodycontent = 
      [{'tns1:situationActive',
        [{numeroLigne, Msisdn}]
       }]},
    slog:event(trace,?MODULE,situationActive,{Msisdn,Req}),
    Response = 
        case pbutil:get_env(pfront_orangef, mipc_vpbx_version) of
            online->
                mipc_vpbx_online:request_situationActive(Msisdn,atom_to_list(WebService));
            _->
                soaplight_orangef:request(Req)
        end,
    analyse_response(Response,situationActive_nok).

analyse_response(Response,ErrorAtom) when atom(ErrorAtom)->
    case analyse_response_int(Response) of
	{ok,Resp} ->
	    {ok,Resp};
	{nok,CodeRetour,Commentaire} ->
	    slog:event(warning,?MODULE,ErrorAtom,{CodeRetour,Commentaire}),
	    {nok,CodeRetour,Commentaire};
	{bad_response,Else} ->
	    slog:event(failure,?MODULE,ErrorAtom,{Response,Else}),
	    {bad_response,Response}
    end.

analyse_response_int(#activerSituationResponse
		     {resultat=#resultat{codeRetour = CodeRetour,
					 commentaire = Commentaire}} = Resp) ->
    reply(CodeRetour,Commentaire,Resp);
analyse_response_int(#consulterInformationsResponse
		     {resultat=#resultat{codeRetour = CodeRetour,
					 commentaire = Commentaire}} = Resp) ->
    reply(CodeRetour,Commentaire,Resp);
analyse_response_int(#consulterParametrageReelResponse
		     {resultat=#resultat{codeRetour = CodeRetour,
					 commentaire = Commentaire}} = Resp) ->
    reply(CodeRetour,Commentaire,Resp);
analyse_response_int(#consulterSituationResponse
		     {resultat=#resultat{codeRetour = CodeRetour,
					 commentaire = Commentaire}} = Resp) ->
    reply(CodeRetour,Commentaire,Resp);
analyse_response_int(#listeSituationsParametreesResponse
		     {resultat=#resultat{codeRetour = CodeRetour,
					 commentaire = Commentaire}} = Resp) ->
    reply(CodeRetour,Commentaire,Resp);
analyse_response_int(#situationActiveResponse
		     {resultat=#resultat{codeRetour = CodeRetour,
					 commentaire = Commentaire}} = Resp) ->
    reply(CodeRetour,Commentaire,Resp);
analyse_response_int(Else) ->
    {bad_response,Else}.

reply("0",Commentaire,Resp) ->
    {ok,Resp};
reply(CodeRetour,Commentaire,Resp) ->
    {nok,CodeRetour,Commentaire}.

%%% SOAPLIGHT callback
decode_by_name(Name,Value) ->
    {Name,Value}.


build_record(Name,Value) 
  when Name == listeSituationsParametrees ->
    Value;
%% element containing a list of values
build_record(Name,ListValues)
    when Name == listeNumeros;
	 Name == listeSituations;
	 Name == saufAppelsEmisDepuis ->
    {Name,lists:map(fun({_,Num})->Num end,ListValues)};
%% top elements
build_record(Name,Pairs) 
    when Name == activerSituationResponse;
	 Name == consulterInformationsResponse;
	 Name == consulterParametrageReelResponse;
	 Name == consulterSituationResponse;
	 Name == listeSituationsParametreesResponse;
	 Name == situationActiveResponse ->
    pairs_to_record(Name,Pairs);
%% elements to be transformed into a record
build_record(Name,Pairs) 
  when Name == resultat;
       Name == reseau;
       Name == membre;
       Name == situation;
       Name == listeNumeros;
       Name == listeSituations;
       Name == versAssistante;
       Name == parametrageRenvois;
       Name == versNumerosLibres;
       Name == parametrageNumeroUnique;
       Name == saufAppelsEmisDepuis ->
    {Name,pairs_to_record(Name,Pairs)};
build_record(Name,Pairs) 
  when Name == situationActive ->
    {Name,pairs_to_record(situation,Pairs)};    
build_record(Name,Value) ->
    {Name,Value}.


pairs_to_record(RecName, Pairs) ->
    pbutil:pairs_to_record(RecName, rec_inf(RecName), Pairs).

rec_inf(activerSituationResponse) -> 
    record_info(fields,activerSituationResponse);
rec_inf(consulterInformationsResponse) -> 
    record_info(fields,consulterInformationsResponse);
rec_inf(consulterParametrageReelResponse) -> 
    record_info(fields,consulterParametrageReelResponse);
rec_inf(consulterSituationResponse) -> 
    record_info(fields,consulterSituationResponse);
rec_inf(listeSituationsParametreesResponse) -> 
    record_info(fields,listeSituationsParametreesResponse);
rec_inf(situationActiveResponse) -> 
    record_info(fields,situationActiveResponse);

rec_inf(resultat) -> 
    record_info(fields,resultat);
rec_inf(reseau) -> 
    record_info(fields,reseau);
rec_inf(membre) -> 
    record_info(fields,membre);
rec_inf(situation) -> 
    record_info(fields,situation);
rec_inf(versAssistante) -> 
    record_info(fields,versAssistante);
rec_inf(parametrageRenvois) -> 
    record_info(fields,parametrageRenvois);
rec_inf(versNumerosLibres) -> 
    record_info(fields,versNumerosLibres);
rec_inf(parametrageNumeroUnique) -> 
    record_info(fields,parametrageNumeroUnique).

get_url(WebService) ->
    MipcVpbxConfigs = pbutil:get_env(pfront_orangef, mipc_vpbx_config),
    {value,{_,Url}} = lists:keysearch(WebService, 1, 
				      MipcVpbxConfigs),
    Url.

envNameSpaces(WebServiceName) 
  when WebServiceName==?ACTIVERSITUATION;
       WebServiceName==?CONSULTERINFORMATIONS;
       WebServiceName==?CONSULTERPARAMETRAGEREEL;
       WebServiceName==?CONSULTERSITUATION;
       WebServiceName==?LISTESITUATIONPARAMETREES;
       WebServiceName==?SITUATIONACTIVE ->
    [{'xmlns:tns1',"urn:orange:weu:ssi"}];

envNameSpaces(_) ->
    [].

slog_info(warning,?MODULE, ErrorAtom)->
    #slog_info{descr="A response to "++ request(ErrorAtom) ++" was received"
	       " properly, but with an error code.\n",
	       operational="Check in logs, at the end of the trace can"
	       " be found: {CodeRetour,Commentaire}\n"
	       "It can be the case when a user is unknow, error code 101."
	       "Try to identify if this is an error,"
	       " or a simple information.\n"};
slog_info(failure,?MODULE, ErrorAtom)->
    #slog_info{descr="A failure was encountered while decoding the response"
	       " to "++ request(ErrorAtom) ++".\n",
	       operational="Check in logs, at the end of the trace can"
	       " be found: {Response,Else}\n"
	       "Response is what was received / decoded, and Else some "
	       " additional information (contact support).\n"}.

request(situationActive_nok) ->
    ?SITUATIONACTIVE;
request(activerSituation_nok) ->
    ?ACTIVERSITUATION;
request(consulterInformations_nok) ->
    ?CONSULTERINFORMATIONS;
request(consulterParametrageReel_nok) ->
    ?CONSULTERPARAMETRAGEREEL;
request(consulterSituation_nok) ->
    ?CONSULTERSITUATION;
request(listeSituationsParametrees_nok) ->
    ?LISTESITUATIONPARAMETREES.
