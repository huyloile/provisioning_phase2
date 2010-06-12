-module(fake_opal_server).

-export([start/0, loop/1, stop/0, handle_request/2]).
-export([decode_by_name/2, build_record/2]).
-export([init_customer/2]).
-export([current_date_string/0, current_time_string/0]).

-define(registered_name, ?MODULE).

start() ->
    stop(),
    timer:sleep(500),
    register(?registered_name, proc_lib:spawn(?MODULE, loop, [dict:new()])).

loop(Accounts) ->
    receive
	{init, Msisdn, Data} ->	
	    loop(dict:store(Msisdn, Data, Accounts));
	{Pid, Http_body} ->
	    {New_accounts, Response} = response(Accounts, Http_body),
	    Pid ! {?registered_name, Response},
	    loop(New_accounts);
	stop ->
	    bye
    end.

stop(undefined) ->
    pass;
stop(Pid) when is_pid(Pid) ->
    Pid ! stop.

stop() ->
    stop(whereis(?registered_name)).

init_customer(Msisdn, Data) when length(Msisdn) == 10 ->
    ?registered_name ! {init, Msisdn, Data}.

handle_request(Header, Body)->
    ?registered_name ! {self(), Body},
    {Http_code, Response_xml} =
	receive
	    {?registered_name, exception} ->
		{500, exception_xml()};
	    {?registered_name, Response} ->
		io:fwrite(">>>>> fake response received: ~p~n", [Response]),
		{200, soaplight:build_xml([], [], Response)}
	end,
    {Http_code, "application/xml+soap", Response_xml}.
    
decode_by_name(Name,Text) -> {Name,Text}.
build_record(Name,Elements) -> {Name,Elements}.

response(Accounts, XmlBody) when is_list(XmlBody) ->
    response(Accounts, soaplight:decode_body(XmlBody, ?MODULE));
response(Accounts, {consulterSolde,[{dossier,Msisdn},{canal,"USSD"}]}) ->
    Data = dict:fetch(Msisdn, Accounts),
    IN1 = atom_to_list(lists:member(adherent, Data)),
    AdherentM5Plus = atom_to_list(lists:member(adherentM5Plus, Data)),
    Cible = atom_to_list(lists:member(cible, Data)),
    CibleM5BO = atom_to_list(lists:member(cibleM5BO, Data)),
    Elements = [{consulterSoldeReponse, [],
		 [{date, [], current_date_string()},
		  {heure, [], current_time_string()},
		  {codeRet, [], "0"},
		  {messageRet, [], []},
		  {requete, [], [{dossier,[],Msisdn},{canal,[],"USSD"}]},
		  {resultat, [],
		   [{'IN1',[],IN1}, 
		    {isAdherentM5Plus,[],AdherentM5Plus},
		    {isCibleM5Plus,[],Cible},
		    {isCibleM5bO,[],CibleM5BO}]}]}],
    {Accounts, Elements};

response(Accounts, {consulterCadeaux, [{dossier,Msisdn} | Tail]}) ->
    Data = dict:fetch(Msisdn, Accounts),
    {value, {solde, Solde}} = lists:keysearch(solde, 1, Data),
    {value, {echeance, Points, Date_limite}} = lists:keysearch(echeance, 1, Data),
    {value, {pointsCB, PointsCB}} = lists:keysearch(pointsCB, 1, Data),
    {value, {type_usage, Usage_data}} = lists:keysearch(type_usage, 1, Data),
    {value, {recompenses, Recompense_data}} = lists:keysearch(recompenses, 1, Data),
    {value, {delaiActivation, Delai}} = lists:keysearch(delaiActivation, 1, Data),    
    {value, {idTypeRecompense, TypeRecompense}} = lists:keysearch(idTypeRecompense, 1, Data),    
    Recompense_elements =
	[{recompense,[],[{idRecompense,[],Id}, {prix,[],Prix}]} || {Id, Prix} <- Recompense_data],
    Usage_elements = [{idTypeUsage, [], Id} || Id <- Usage_data],
    Delai_Activation = [{delaiActivation, [], Delai}],
    Id_Type_Recompense = [{idTypeRecompense, [], TypeRecompense}],
    Catalogue = Usage_elements++Delai_Activation++Id_Type_Recompense++Recompense_elements,
    Elements = [{getConsultationCadeauxReponse, [],
		 [{date, [], current_date_string()},
		  {heure, [], current_time_string()},
		  {codeRet, [], "0"},
		  {messageRet, [], []},
		  {requete, [], [{dossier,[],Msisdn},{canal,[],"USSD"}]},
		  {resultat, [],
		   [{solde, [], Solde},
		    {pointsCB, [], PointsCB},
		    {pointsLimites, [], Points},
		    {jourLimitePts, [], Date_limite},
		    {catalogue,[], Catalogue}
		   ]}]}],
    io:fwrite(">>>>> fake response: ~p~n", [Elements]),
    {Accounts, Elements};

response(Accounts, {activerPrime, [{dossier,Msisdn},
				   {canal,"USSD"},
				   {idRecompense, Present},
				   {prix, Price}]}) ->
    Data = dict:fetch(Msisdn, Accounts),
    {value, {solde, Solde}} = lists:keysearch(solde, 1, Data),
    Elements = [{getActivationPrimeReponse, [],
		 [{date, [], current_date_string()},
		  {heure, [], current_time_string()},
		  {codeRet, [], "0"},
		  {messageRet, [], []},
		  {requete, [], [{dossier,[],Msisdn},{canal,[],"USSD"}]},
		  {resultat, [],
		   [{solde, [], Solde}
		   ]}]}],
    io:fwrite(">>>>> fake response: ~p~n", [Elements]),
    {Accounts, Elements}.

exception_xml() ->
    "".

current_date_string() ->
    {{Y,M,D}, _} = erlang:localtime(),
    lists:flatten(io_lib:fwrite("~2.2.0w/~2.2.0w/~w", [D, M, Y])).

current_time_string() ->
    {_, {H, Min, S}} = erlang:localtime(),
    lists:flatten(io_lib:fwrite("~2.2.0w:~2.2.0w:~2.2.0w", [H, Min, S])).
