-module(fake_limande_server).

-export([start/0, loop/1, stop/0]).

%%httpserver_server callback func
-export([handle_request/2]).

%%SOAPLIGHT callback
-export([decode_by_name/2,build_record/2]).

-export([init_data/1]).

-include("testlimande.hrl").

handle_request(Env,Input)->
    fake_limande_server!{self(),Input},
    {Http_code, Response_xml} =
	receive
	    {fake_limande_server,""}->
		{500,soaplight:build_xml([],[],invalidInputException())};
	    {fake_limande_server,[{'SOAP-ENV:Fault',[],Values}]=Response}->
		{500,soaplight:build_xml([],[],Response)};
	    {fake_limande_server,Response}->
		io:format("fake limande response:~n~p~n",[Response]),
		{200,soaplight:build_xml([],[],Response)}
	end,
    {Http_code, "application/xml+soap", Response_xml}.    
    

start() ->
    stop,
    timer:sleep(500),
    register(fake_limande_server, proc_lib:spawn(?MODULE,loop, [dict:new()])).

stop(undefined) ->
    ok;
stop(Pid) when is_pid(Pid) ->
    Pid ! stop.
stop() ->
    stop(whereis(fake_limande_server)).

loop(Accounts)->
    receive
	{init_data,Data}->
	    New_accounts=
		lists:foldl(fun({Key,Value},Acc)->
				    dict:store(Key,Value,Acc)
			    end,Accounts,Data),
	    loop(New_accounts);
	{Pid,Http_body} ->
	    {New_accounts,Response}=response(Accounts,Http_body),
	    Pid! {fake_limande_server,Response},
	    loop(New_accounts);
	stop ->
	    bye
    end.

response(Accounts,XmlBody) when is_list(XmlBody)->
    DecodedBody=soaplight:decode_body(XmlBody,?MODULE),
    response(Accounts,DecodedBody);

response(Accounts,{getOffresSouscriptibles,[_,_,{msisdn,MSISDN},_]})->
    OffreSouscriptibleResp=dict:fetch(MSISDN,Accounts),
    {Accounts,[{getOffresSouscriptiblesResponse,
		[],OffreSouscriptibleResp}]};

response(Accounts,{getDescriptionOffre,[_,{_,IDOffre}]})->
    #testOffre{description=Description}=dict:fetch(IDOffre,Accounts),
    {Accounts,[{getDescriptionOffreResponse,[],Description}]};

response(Accounts,{getMentionsLegalesOffre,[_,{_,IDOffre}]})->
    #testOffre{mentions=Mentions}=dict:fetch(IDOffre,Accounts),
    {Accounts,[{getMentionsLegalesOffreResponse,[],[{'MentionsLegalesOffre',[],Mentions}]}]};

response(Accounts,{doSouscriptionOffre,[_,{_,MSISDN},{_,IDOffre},_]})->
    Response=response_by_msisdn("+"++MSISDN),
    ListeOffre=dict:fetch(MSISDN,Accounts),
    Func = remove_offer(IDOffre),
    NewListeOffre = lists:foldl(Func,
				[],
				ListeOffre),
    NewAccount=dict:store(MSISDN,NewListeOffre,Accounts),
    {NewAccount,Response};

response(Accounts,Request) ->
    io:format("fake_limande_server>>> Bad Request:~p~n",[Request]),
    {Accounts,""}.

remove_offer("LIM1")->
    fun({'ListeOffre',[],[{_,_,_},{_,_,_},{idOffre,[],"LIM1"}]},Acc) -> Acc;
       (Other,Acc) -> Acc++[Other] end;
remove_offer("LIM2")->
    fun({'ListeOffre',[],[{_,_,_},{_,_,_},{idOffre,[],"LIM2"}]},Acc) -> Acc;
       (Other,Acc) -> Acc++[Other] end;
remove_offer("LIM3")->
    fun({'ListeOffre',[],[{_,_,_},{_,_,_},{idOffre,[],"LIM3"}]},Acc) -> Acc;
       (Other,Acc) -> Acc++[Other] end.

  
decode_by_name(Name,Text) -> {Name,Text}.
build_record(Name,Elements) -> {Name,Elements}.

init_data([])->
    ok;
init_data(Data)->
    fake_limande_server!{init_data,Data}.

xmlBodySubscr()->
      [{doSouscriptionOffreResponse,[],
	[{'TXID',[],"0"}]}].

invalidInputException()->
    [{'SOAP-ENV:Fault',[],
      [{faultcode,[],"SOAP-ENV:Server.generalException"},
       {faultstring,[],""},
       {detail,[],
	[{invalidInputException,[],
	  [{errorMessage,[],"Invalid Input Error"}]},
	 {exceptionName,[],"invalidInputException"}]}]}].

xmlError50() ->
    [{'SOAP-ENV:Fault',[],
      [{faultcode,[],"soapenv:Server.generalException"},
       {faultstring,[],""},
       {detail,[],
	[{'LimandeException',[],
	  [{errorMessage,[],"Solde Insuffisant"},
	   {errorCode,[],"50"}]},
	 {exceptionName,[],"fr.orange.limande.services.exception.LimandeException"}]}]}].


limandeException()->
    [{'SOAP-ENV:Fault',[],
      [{faultcode,[],"SOAP-ENV:Server.generalException"},
       {faultstring,[],""},
       {detail,[],
	[{'LimandeException',[],
	  [{errorMessage,[],"Souscription impossible"},
	   {errorCode,[],"89"}]},
	 {exceptionName,[],"LimandeException"}]}]}].

response_by_msisdn(MSISDN) when 
  MSISDN==?msisdn_cmo;MSISDN==?msisdn_gp;MSISDN==?msisdn_mobi->
    xmlBodySubscr();
response_by_msisdn(?msisdn_cmo_sans_credit) ->
    xmlError50();
response_by_msisdn(_)->
    limandeException().


