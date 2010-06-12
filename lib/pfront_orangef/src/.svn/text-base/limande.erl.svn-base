-module(limande).

%% Limande API
-export([getOffresSouscriptibles/4,getDescriptionOffre/2]).
-export([getMentionsLegalesOffre/2,doSouscriptionOffre/4]).

%% Encoding functions 
-export([encode_getOffresSouscriptibles/4,encode_getDescriptionOffre/2]).
-export([encode_getMentionsLegalesOffre/2,encode_doSouscriptionOffre/4]).

%% soaplight Callbacks:
-export([decode_by_name/2, build_record/2]).

-include("../../pfront/include/soaplight.hrl").
-include("../include/limande.hrl").

limande_request(Message,TypeReq,Info,Record)->
    Http_url = pbutil:get_env(pfront_orangef, limande_http_url),
    Content_type = pbutil:get_env(pfront_orangef, limande_content_type),
    Req = #soap_req{
      web_service=pbutil:get_env(pfront_orangef,limande_webserv),
      http_url = Http_url, %"/LimSOAPGen/services/LimandeSouscriptionOffre",
      http_headers = [{"Content-Type",Content_type},
		      {"SOAPAction",""}],
      envnamespaces = [],
      bodynamespaces = [],
      bodycontent = Message},
    slog:event(trace, ?MODULE, TypeReq,Info),
    Current_time = oma:unixmtime(),
    Resp = soaplight:request(Req),
    slog:delay(perf, ?MODULE, response_time, Current_time),
    case Resp of
	{Record,_} ->
	    slog:event(trace, ?MODULE, limande_request_OK, Resp),
	    Resp;
	{Record,_,_} ->
	    slog:event(trace, ?MODULE, limande_request_OK, Resp),
	    Resp;
	{'EXIT',{timeout,TimeoutR}}->
	    slog:event(failure, ?MODULE, limande_timeout, TimeoutR),
	    {error,timeout};
	Other ->
	    slog:event(failure, ?MODULE, limande_request_NOK, {Info, Other}),
	    Other
    end.	    
	    

%%API
getOffresSouscriptibles(Sender,InfoLigneDeMarche,Msisdn,Dosclient)->
    Message=encode_getOffresSouscriptibles(Sender,InfoLigneDeMarche,
					   Msisdn,Dosclient),
    limande_request(Message,getOffresSouscriptibles,Msisdn,offresSouscriptibles).

getDescriptionOffre(Sender,IDOffre)->
    Message=encode_getDescriptionOffre(Sender,IDOffre),
    limande_request(Message,getDescriptionOffre,IDOffre,getDescriptionOffreResponse).

getMentionsLegalesOffre(Sender,IDOffre)->
    Message=encode_getMentionsLegalesOffre(Sender,IDOffre),
    limande_request(Message,getMentionsLegalesOffre,IDOffre,mentionsLegalesOffre).

doSouscriptionOffre(Sender,Msisdn,IDOffre,Dosclient)->
    Message=encode_doSouscriptionOffre(Sender,Msisdn,IDOffre,Dosclient),
    limande_request(Message,doSouscriptionOffre,Msisdn,ok).

%%ENCODING 
encode_getOffresSouscriptibles(Sender,InfoLigneDeMarche,
			       "+"++_Msisdn,Dosclient)->    
    [{getOffresSouscriptibles,
      [{xmlns,"http://limande.orange.fr/services/souscriptionOffreV1"}],
      [{sender,[],Sender},
       {'InfoLigneDeMarche',[],InfoLigneDeMarche},
       {msisdn,[],_Msisdn},
       {doscli,[],dossier(Dosclient)}
      ]}].

encode_getDescriptionOffre(Sender,IDOffre)->
      [{getDescriptionOffre,
       [{xmlns,"http://limande.orange.fr/services/souscriptionOffreV1"}],
       [{sender,[],Sender},
	{'IDOffre',[],IDOffre}
       ]}].

encode_getMentionsLegalesOffre(Sender,IDOffre)->
      [{getMentionsLegalesOffre,
        [{xmlns,"http://limande.orange.fr/services/souscriptionOffreV1"}],
	[{sender,[],Sender},
	 {'IDOffre',[],IDOffre}
	 ]}].

encode_doSouscriptionOffre(Sender,"+"++_Msisdn,IDOffre,Dosclient)->
    Basile = pbutil:get_env(pfront_orangef,limande_msisdn_balise),
      [{doSouscriptionOffre,
        [{xmlns,"http://limande.orange.fr/services/souscriptionOffreV1"}],
	[{sender,[],Sender},
	 {Basile,[],_Msisdn},
	 {'IDOffre',[],IDOffre},
	 {doscli,[],dossier(Dosclient)}
	 ]}].

dossier([])->
    [{'ns1:LigneDeMarche',
      [{'xmlns:ns1',"http://limande.orange.fr/services/dataModelV1"}],
      []},
     {'ns2:Declinaison',
      [{'xmlns:ns2',"http://limande.orange.fr/services/dataModelV1"}],
      []},
     {'ns3:DossierSachem',
      [{'xmlns:ns3',"http://limande.orange.fr/services/dataModelV1"}],
      []}
     ];
dossier(#dossierLimande{'LigneDeMarche'=LigneDeMarche,'Declinaison'=Declinaison,
			'DossierSachem'=DossierSachem})->
    [{'ns1:LigneDeMarche',
      [{'xmlns:ns1',"http://limande.orange.fr/services/dataModelV1"}],
      LigneDeMarche},
     {'ns2:Declinaison',
      [{'xmlns:ns2',"http://limande.orange.fr/services/dataModelV1"}],
      Declinaison},
     {'ns3:DossierSachem',
      [{'xmlns:ns3',"http://limande.orange.fr/services/dataModelV1"}],
      DossierSachem}
     ].
    
%% SOAPLIGHT callback
decode_by_name(Name,Value)->
    {Name,Value}.

build_record(getDescriptionOffreResponse,Value)->
    {value,{_,DescriptionOffre}}=lists:keysearch('DescriptionOffre',1,Value),
    {getDescriptionOffreResponse,DescriptionOffre};
      
build_record(getOffresSouscriptiblesResponse,Value) ->
    {value,{_,Pairs}}=lists:keysearch(doscli,1,Value),
    case Pairs of 
	[LigneDeMarche, Declinaison, DossierSachem] ->
	    Dosclient=pbutil:update_record(record_info(fields,dossierLimande),
					   #dossierLimande{},Pairs);
	[LigneDeMarche, Declinaison, DossierSachem, TypeFact] ->
	    Dosclient=pbutil:update_record(record_info(fields,dossierLimande),
					   #dossierLimande{},[LigneDeMarche, Declinaison, DossierSachem])
    end,	    
    ListeOffres = lists:filter(fun({'ListeOffre',_}) -> true;
				  (_) -> false
			      end, Value),  
    case ListeOffres of
	
	[{'ListeOffre',[]}]->  {offresSouscriptibles,Dosclient,[]};

	_ ->  ListeOffreRecord=
 		 lists:map(fun({_,[{_,Libelle},{_,Montant},{_,ID}]})->
 				   {offre,Libelle,Montant,ID}
 			   end,ListeOffres),
 	     {offresSouscriptibles,Dosclient,ListeOffreRecord}
    end;

build_record(getMentionsLegalesOffreResponse,Value)->
     [{'MentionsLegalesOffre',Value2}]=Value,
     {value,{ecran1,EcranA}}=lists:keysearch(ecran1,1,Value2),
     {value,{ecran2,EcranB}}=lists:keysearch(ecran2,1,Value2),
     {mentionsLegalesOffre,EcranA,EcranB};

build_record(doSouscriptionOffreResponse,Value) ->
     {value,{_,RespCode}}=lists:keysearch('TXID',1,Value),
     {ok,RespCode};

build_record('Header',Value)->
    [];
build_record('Fault',Value)->
    {value,{_,Detail}}=lists:keysearch(detail,1,Value),
    case lists:keysearch('LimandeException',1,Detail) of
	{value,{_,LimandeException}}->
	    {value,{_,ErrMessage}}=
		lists:keysearch(errorMessage,1,LimandeException),
	    {value,{_,ErrCode}}=lists:keysearch(errorCode,1,LimandeException),
	    {limandeException,ErrMessage,ErrCode};
	false->
	    {value,{_,InvalidInputException}}=
                lists:keysearch('InvalidInputException',1,Detail),
	    {value,{_,Message}}=
		lists:keysearch(message,1,InvalidInputException),
	    {invalidInputException,Message}
    end;	    
build_record(Name,Value) ->
    {Name,Value}.
