-module(smsinfos_server).

%% Client API
%% API %%
-export([dprofMediaSVI/4,modprofSVI/8]).
-export([tarifSVI/4,dprofrub/4,dprofforfait/4,resSVI/5]).
-export([info/2,dterm/2,term/3,filtreClient/3,dprofFactSVI/3]).
-export([modterm/3]).
%% Server
-export([start_link/1, init/1]).

-behaviour(gen_server).
-export([init/1, handle_call/3,  handle_info/2, 
	 code_change/3, handle_cast/2, terminate/2]).

-define(SEP,";").

%% +deftype smsinfos_config() =
%%     #smsinfos_config { method::term(),
%%	                  banner::string()}.

-record(smsinfos_config, {method,banner}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-include("../../pfront/include/pfront.hrl").
%% +type start_link(interface()) -> {ok, Pid} |
%%                                  {error, {already_started, Pid}} |
%%                                  {error, Reason}.

start_link(#interface{type=smsinfos, name_node={Name,_Node}}=Interface) ->
    %% We don't register as Name until the connection is established.
    gen_server:start_link(?MODULE, Interface, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SMSINFOS API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +deftype msisdn() = string().
%% +deftype subscription() = mobi | cmo | postpaid.
%% +deftype facturationtype() = string(). %%%% "A"(abo) or "M"(factu au MT).
%% +deftype media() = sms | mms.
%% +deftype smsinfos_error() =  {status, ErrorCode::integer()} |
%%                              {status, atom()}               |
%%                              {error,{badresponse,term()}}.
%% +deftype typeflux() = all | img | vid.

%% +type dprofMediaSVI(atom(),msisdn(),media(),typeflux())->
%%            {ok, [Result::term()]} |
%%            smsinfos_error().
%%%% Requête d'interrogation du profile d'un client

dprofMediaSVI(SRV, Msisdn, Media, TypeFlux) ->
    case request(SRV, "ORAINFdprofMediaSVI", [msisdn(Msisdn),media(Media),typeflux(TypeFlux)]) of
	{ok, [_,"93",_,_,_,_]}->
	    {status, no_profile}; 
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	{ok, [_,"90",PM,IMEI,Fact_Type,ListeRub]}->
	    {ok, [prix(PM),IMEI,Fact_Type,liste_rubrique(ListeRub)]};
	Else->
	    error(Else)
    end.

%% +type dprofFactSVI(atom(),msisdn(),media())->
%%            {ok, [Result::term()]} |
%%            smsinfos_error().
%%%% Requête d'interrogation du profile d'un client

dprofFactSVI(SRV, Msisdn, Media) ->
    case request(SRV, "ORAINFdprofFactSVI", [msisdn(Msisdn),media(Media)]) of
	{ok, [_,"93",_,_,_]}->
	    {status, no_profile}; 
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	{ok, [_,"90",PM,IMEI,ListeRub_Fact]}->
	    {ok, [prix(PM),IMEI,liste_rub_fact(ListeRub_Fact)]};
	Else->
	    error(Else)
    end.

%% +type modprofSVI(atom(),msisdn(),IdServ::integer(),string(),string(),string(),
%%                  subscription(),facturationtype())-> {ok, date()} | smsinfos_error().
%%%% modif de profile
modprofSVI(SRV,Msisdn,Idservice,Comp_1,Comp_2,Comp_3,Sub,TypeFact) ->
    case request(SRV, "ORAINFmodprofSVI", 
		 [msisdn(Msisdn),integer_to_list(Idservice),
		  to_list(Comp_1),to_list(Comp_2),to_list(Comp_3),
		  subscription(Sub),TypeFact,"USSD",to_list(undefined)]) of
	{ok, [_,"91"]}->
	    {status, max_subscriber}; 
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	{ok, [_,"90",DateEffet]}->
	    {ok, decode_date(DateEffet)};
	Else->
	    error(Else)
    end.

%% +type tarifSVI(atom(),msisdn(),Idservice::integer(),facturationtype())-> 
%%            {ok, Prix_PROMO::currency:currency(),PRIX_MAX::currency:currency()} |
%%            smsinfos_error().
%%%% demande de tarifs
tarifSVI(SRV,Msisdn,Idservice,TypeFact) ->
    case request(SRV, "ORAINFtarifSVI", 
		 [msisdn(Msisdn),integer_to_list(Idservice),TypeFact]) of
	{ok, [_,"93"]}->
	    {status, user_not_subcribe}; 
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	{ok, [_,"90",Tarif,Tarif_Max]}->
	    {ok, prix(Tarif),prix(Tarif_Max)};
	Else->
	    error(Else)
    end.

%% +type dprofrub(atom(),msisdn(),Idrub::integer(),media())-> {ok, Result::term()} | smsinfos_error().
%%%% demande d'infos sur la rubrique
%%%% Result= [Comp1::string(),Comp2::string(),Comp3::string(),date(),term(),Media2::media()]
dprofrub(SRV,Msisdn,Idrub,Media) ->
    case request(SRV, "ORAINFdprofrub", [msisdn(Msisdn),
					 integer_to_list(Idrub),
					 media(Media)]) of
	{ok, [_,"93"]}->
	    {status, not_subcribe}; 
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	{ok, [_,"90",Comp_1,Comp_2,Comp_3,DateValid,ProfModified,Media2]}->
	    {ok, [Comp_1,Comp_2,Comp_3,decode_date(DateValid),ProfModified,
		  Media2]};
	Else->
	    error(Else)
    end.

%% +type dprofforfait(atom(),msisdn(),Idrub::integer(),media())-> {ok, Result::term()} | smsinfos_error().
%%%% deman,de d'infos sur les forfaits souscripts
%%%% Result = [TypeForfait::facturationtype(),Comp::string(), date(),[RubId::integer()]].
dprofforfait(SRV,Msisdn,Idrub,Media) ->
     case request(SRV, "ORAINFdprofforfait", 
		  [msisdn(Msisdn), integer_to_list(Idrub),  media(Media)]) of
	{ok, [_,"93"]}->
	    {status, not_subcribe}; 
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	{ok, [_,"90",TypeForfait, Comp, DateFin, ListRub]}->
	    {ok, [TypeForfait,Comp, decode_date(DateFin), 
		  liste_rubrique(ListRub)]};
	Else->
	    error(Else)
    end.

%% +type resSVI(atom(),msisdn(),RubID::integer(),facturationtype(),media())-> ok | smsinfos_error().
%%%% resiliation de profile
resSVI(SRV,Msisdn,IdRub,FactType,Media) ->
    case request(SRV, "ORAINFresSVI", 
		  [msisdn(Msisdn), integer_to_list(IdRub), "SVI",
		   FactType,media(Media)]) of
	{ok, [_,"93"]}->
	    {status, not_subcribe}; 
	{ok, [_,"90"]}->
	    ok;
	{ok, [_,X]} ->
	    {status, decode_status(X)};
	Else->
	    error(Else)
    end.

%% +deftype liste_service() = string(). %%%% "LISTESMS" or "LISTEMMS".
%% +type info(atom(),liste_service())-> {ok , [term()]} | smsinfos_error().
%%%% liste des service SMS ou MMS (NOT USED).
info(SRV,Liste) ->
    case request(SRV, "ORAINFinfo",[Liste]) of
	{ok, ["90"|ListRub]}->
	    {ok,ListRub};
	{ok, [X]}->
	    {status,decode_status(X)};
	Else ->
	    error(Else)
    end.

%% +type dterm(atom(),msisdn())-> {ok, TAC::string()} | smsinfos_error().
%%%% demande d'infos terminal
dterm(SRV,MSISDN) ->
    case request(SRV, "ORAINFdterm",[msisdn(MSISDN)]) of
	{ok, [_,"90",IMEI,ClImg,ClVideo]}->
	    {ok,IMEI,list_to_integer(ClImg),list_to_integer(ClVideo)};
	{ok, X}->
	    {status,X};
	Else ->
	    error(Else)
    end. 

%% +type term(atom(),msisdn(),TAC::string())-> ok | smsinfos_error().
%%%% Ce Terminal est t'il compatible MMS ?
term(SRV,MSISDN,TAC) ->
    case request(SRV, "ORAINFterm",[msisdn(MSISDN),TAC]) of
	{ok, [_,"90"]}->
	    ok;
	{ok, [_,X]}->
	    {status,decode_status(X)};
	Else ->
	    error(Else)
    end. 

%% +type modterm(atom(),msisdn(),TAC::string())-> 
%%         {ok,integer(),integer()} | smsinfos_error().
%%%% Ce Terminal est t'il compatible MMS ou/et MMS Video ?
modterm(SRV,MSISDN,TAC) ->
    case request(SRV, "ORAINFmodterm",[msisdn(MSISDN),TAC]) of
	{ok, [_,"90",ClImg,ClVideo]}->
	    {ok,list_to_integer(ClImg),list_to_integer(ClVideo)};
	{ok, X}->
	    {status,X};
	Else ->
	    error(Else)
    end.

%% +type filtreClient(atom(),msisdn(),FilterType::integer())-> 
%%                         {ok, Type::integer(), [RubId::integer()]} |
%%                         smsinfos_error().
%%%% Renvoie la liste des rubrqieus interdite d'accès pour un client donné
filtreClient(SRV,MSISDN,FiltreType) ->
    case request(SRV, "ORAINFFiltreClient",[msisdn(MSISDN)]) of
	{ok, [_,"90","0"]}->
	    {ok, filtre_total};
	{ok, [_,"90",BlockType,IdLists]}->
	    {ok,list_to_integer(BlockType),liste_rubrique(IdLists)};
	{ok, [_,"91"]}->
	    {ok, aucun_filtre};
	Else ->
	    error(Else)
    end. 

%%%%%%%%%%%%%%%% ENCODING/ DECODONG FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type msisdn(string())-> msisdn().
msisdn("+33"++T)->
    "33"++T;
msisdn("+99"++T) ->
    "99"++T;
msisdn("06"++T) ->
    "336"++T;
msisdn("07"++T) ->
    "337"++T.

%% +type media(media())-> string().
media(sms)->
    "SMS";
media(mms) ->
    "MMS".

%% +type typeflux(typeflux())-> string().
typeflux(all)->
    "ALL";
typeflux(img) ->
    "IMG";
typeflux(vid) ->
    "VID".

%% +type decode_status(string())-> atom | integer().
decode_status("10")->
    no_client;
decode_status("99") ->
    error_in_request;
decode_status("93") ->
    no_profile;
decode_status(E) ->
    list_to_integer(E).

%% +type subscription(subscription())-> string().
subscription(mobi)->
    "1";
subscription(cmo) ->
    "2";
subscription(_) ->
    %%postpayé
    "0".

%% +type decode_date(string())-> date().
decode_date(Date)->
    {[Y,Mo,D],_}=pbutil:sscanf("%04d%02d%02d",Date),
    {Y,Mo,D}.

%% +type liste_rubrique(string())-> [integer()].
liste_rubrique(Liste)->
    lists:map(fun(X)->
		      list_to_integer(X) end,string:tokens(Liste," ")).

%% +type liste_rub_fact(string())-> [{RubId::integer(),string()}].
liste_rub_fact(Liste)->
   decode_rub_fact(string:tokens(Liste," "),[]).

%% +type decode_rub_fact(string(),string())-> [{integer(),string()}].
decode_rub_fact([Rub,Fact|H],Acc) ->
    decode_rub_fact(H,[{list_to_integer(Rub),Fact}]++Acc);
decode_rub_fact(_,Acc) ->
    Acc.
 
%% +type prix(string())-> currency:currency().
prix(PM)->
    currency:sum(euro,list_to_integer(PM)/1000).

%% +type to_list(term())-> string().
to_list(X) when list(X)->
    X;
to_list(X) when integer(X)->
    integer_to_list(X);
to_list(undefined)->
    "nul".

%% +type error(term())-> {error,term()}.
error({error,{timeout,_}})->
    {error,timeout};
error({error,E})->
    {error,E};
error(E) ->
    {error,E}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type request(atom(), Req::string(), Args::string()) -> [term()].
%%%% Selects a server, sends the request, parses the response.
request(SRV, Req, Args) ->
    case catch do_request(SRV, Req, Args) of
	{'EXIT', E} -> 
	    {error, E};
	Res -> Res
    end.

%% +type do_request(atom(), Prefix::string(), Args::term()) -> [term()].
do_request(SRV, Req, Args) ->
    %% Format the SMSINFOS request.
    Request = Req++" "++args_to_request(Args),
    %%io:format("SMSINFO>~s~n",[Request]),
    % Twice the SMSINFOS server's timeout (covers erlang overhead).
    Timeout = pbutil:get_env(pfront_orangef, smsinfos_response_timeout) * 2,
    GSReq = {smsinfos_request, [], Req, Request},
    {S, Line} = gen_server:call(SRV, GSReq, Timeout),
    %%io:format("S = ~p Line~p~n",[S,Line]),
    response_to_args(Req,Line).
    %% Now check whether the reply matches one of the expected formats.

%% +type args_to_request([string()])-> string().
args_to_request([H|[]]) ->
    H;
args_to_request([H|T])->
    H++?SEP++args_to_request(T).

%% +type response_to_args(string(),string())-> 
%%           {ok,[string()]} | {error, {bad_format,term()}}. 
response_to_args(Req,Response) when list(Response)->
    case pbutil:split_at($ ,Response) of
	{Req,Args}->
	    {ok, tokens(Args,$;,[])};
	E ->
	    %%io:format("Test:~p~n",[E]),
	    {error,{bad_format,E}}
    end;
response_to_args(Req,Response)->
    {error,Response}.

%% +type tokens([string()],char(),[string()])-> [string()].
tokens(Args,Char,Acc)->
    case pbutil:split_at(Char,Args) of
	{Arg,Rest}->
	    %%io:format("Arg:~p Rest:~p~n",[Arg,Rest]),
	    tokens(Rest,Char,Acc++[Arg]);
	E->
	    Acc++[Args]
    end.
    
		  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +deftype queue() = {[term()],[term()]}.
%% +deftype state() = #state{port::pid(), q::queue(), n::integer()}.

-record(state, {port, q, n}).

%% +type init(interface()) -> *.

init(I) ->
    put(interface, I),
    %% init/1 should not block. Therefore we return a special state
    %% with no port yet, and we cause it toimeout immediately.
    {ok, #state{port=connect, q=queue:new(), n=0}, 0}.

connect({x25port, Options, Addr}) ->
    Program = io_lib:format("~s/~s/x25port.out ~s ~s",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr ]),
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({fsx25port, Options, Addr}) ->
    Program = io_lib:format("~s/~s/fsx25port.out ~s ~s",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr ]),
    io:format("Spawning ~s~n", [Program]),
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({tcpport, Options, Addr, Port}) ->
    Program = io_lib:format("~s/~s/tcpport.out ~s ~s ~w",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr, Port ]),
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({port, Program}) ->
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({erlang_process, Name}) ->
    %% Wait a little (for sdp_fake).
    receive after 2000 -> ok end,
    Pid = pbutil:whereis_name(Name),
    Pid ! {self(), connect},
    receive {Pid, connected} -> Pid
    after 1000 -> exit(timeout_while_connecting)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Since the SDP protocol is synchronous, the queue size is 1.
%% Actually it is much better to wait for the reply synchronously,
%% than to return "overloaded" when two simultaneous requests are done.
handle_call({smsinfos_request, _Attr, Prefix, Request}, Client, State) ->
    slog:event(trace, ?MODULE, handle_call, {Request, Prefix}),
    #state{port=Port} = State,
    pbutil:send_port(Port, Request),
    Timeout = pbutil:get_env(pfront_orangef, smsinfos_response_timeout),
    Treq = pbutil:unixmtime(),
    %% Expect either Response or {eol, Response}
    %% (compatible with 'stream' and '{line,_}').
    receive
	{Port, {data, {eol, Response}}} ->
	    slog:delay(perf, ?MODULE, port_response_time, Treq),
	    handle_sync_response(State, Request, Prefix, Response);
	{Port, {data, Response}} ->
	    slog:delay(perf, ?MODULE, port_response_time, Treq),
	    handle_sync_response(State, Request, Prefix, Response);
	{Port, {exit_status, Status}} ->
	    slog:event(count, ?MODULE, {fsx25_exited_during_request, Status}),
	    exit(smsinfos_port_exited)
    after Timeout ->
	    slog:event(trace, ?MODULE, response_timeout),
	    exit(timeout_waiting_for_smsinfos_reply)
    end.

handle_sync_response(State, Request, Prefix, Response) ->    
    case lists:prefix(Prefix, Response) of
	false ->
	    slog:event(trace, ?MODULE, response_nok),
	    exit({smsinfos_sync, response_order});
	true ->
	    slog:event(trace, ?MODULE, response_ok),
	    {reply, {ok, Response}, State}
    end.


handle_info(timeout, #state{port=connect}=S) ->
    Config = (get(interface))#interface.extra,
    {Name,_Node} = (get(interface))#interface.name_node,
    slog:event(trace, ?MODULE, {Name,connecting}),
    Port = connect(Config#smsinfos_config.method),
    check_banner(Config#smsinfos_config.banner, Port),
    pfront_app:interface_up(Name),
    put(port, Port),
    {noreply, S#state{port=Port}};

handle_info(timeout, #state{q=Q, n=N}=S) ->
    case queue:out(Q) of
	{empty, _} ->
	    {noreply, S};
	{{value,{Client,_,Tmax}}, Q1} ->
	    Timeout = Tmax - pbutil:unixmtime(),
	    case Timeout > 0 of
		false -> gen_server:reply(Client, {error, timeout}),
			 {noreply, S#state{q=Q1, n=N-1}, 0};
		true -> {noreply, S, Timeout}
	    end
    end;

%% The following clauses are now unused: handle_call blocks until the
%% SDP replies.

handle_info({Port, {data, {eol,Response}}}, S) ->
    %% For compatibility between 'stream' and '{line,_}'.
    handle_info({Port, {data, Response}}, S);

handle_info({Port, {data, Response}}, S) ->
    #state{port=Port,q=Q,n=N} = S,
    case queue:out(Q) of
	{empty, _} ->
	    slog:event(failure,?MODULE,reponse_wihtout_request,Response),
	    exit(smsinfos_sync_response_without_request);
	{{value, {Client,Prefix,_}}, Q1} ->
	    case lists:prefix(Prefix, Response) of
		false ->
		    exit({smsinfos_sync, response_order});
		true ->
		    %%io:format("SMSI REPLY: ~p~n", [Response]),
		    gen_server:reply(Client, {ok, Response}),
		    {noreply, S#state{q=Q1, n=N-1}, 0}
	    end
    end;
		  
handle_info({Port, {exit_status, Status}}, S) ->
    slog:event(count, ?MODULE, {fsx25_exited, Status}),
    exit(smsinfos_port_exited);

handle_info(Msg, S) ->
    pbutil:badmsg(Msg, ?MODULE).

%% +type code_change(Vsn, state(), M) -> {ok, state()}.

code_change(Old, State, Extra) ->
    {ok, State}.

%% +type handle_cast(M, state()) -> {noreply, state()}.

handle_cast(Req, S) ->
    {noreply, S}.


%% +type terminate(R, state()) -> ok.

terminate(Reason, S) ->
    ok.

check_banner(undefined, Port) -> ok;
check_banner(no_banner, Port) -> ok;
check_banner(Banner, Port) ->
    Timeout = pbutil:get_env(pfront_orangef, smsinfos_connect_timeout),
    %% Note: do not match other messages here.
    receive
	%% Expect either Response or {eol, Response}
	%% (compatible with 'stream' and '{line,_}').
	{Port, {data,{eol,Banner}}} -> ok;
	{Port, {data,Banner}} -> ok;
	{Port, {data,{eol,B}}} -> exit({wrong_banner_from_sdp, B, Banner});
	{Port, {data,B}} -> exit({wrong_banner_from_sdp, B, Banner})
    after Timeout ->
	    exit(timeout_waiting_for_sdp_banner)
    end.
%% *autograph([
%%     { path, ["../../posutils/src", "."]},
%%     { actions, [ {connect,1} ] },
%%     { inits, [ {init,1} ] }
%%   ]).
