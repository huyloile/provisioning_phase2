-module(proxyclient_server).
-behaviour(gen_server).

-export([start/1, start_link/1, request/3]).

-export([init/1, handle_call/3,  handle_info/2, 
	 code_change/3, handle_cast/2, terminate/2]).

-include("../include/proxyclient.hrl").

-record(router_req,
        {fep_req,
         routing_attr,
         timeout_if}).

%% +deftype requester() = {From,call} | {From,cast}.

%% +deftype state() = 
%%     #state { sock    :: sock(),
%%              conn    :: not_connected | connected,
%%              pending :: queue(requester()),
%%              buf     :: buffer()
%%             }.
-record(state, { sock, conn, pending, buf}).


%% +deftype buffer()  = term() | binary().
%% +deftype request() = term().

%% +behaviour gen_server(proxyclient_config(), state(), term(), Result).

%% +type start(proxyclient_config()) -> {ok, atom()}.
start(CFG) ->
    gen_server:start(?MODULE, CFG, []).

%% +type start_link(proxyclient_config()) -> {ok, atom()}.
start_link(CFG) ->
    gen_server:start_link(?MODULE, CFG, []).

%% +type request(pid(),term(),integer()) ->  term().
request(Srv, Req, Timeout) ->
    gen_server:call(Srv, Req, Timeout).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init(CFG) ->
    put(cfg, CFG),
    State = #state{pending=[], conn=not_connected},
    {ok, State, 1}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_info(timeout, #state{conn=not_connected}=State) ->
    {Host, Port, Opt}=get_config_cnx(),    
    slog:event(trace, ?MODULE, connecting),
    {ok, CSock}=gen_tcp:connect(Host, Port, Opt),
    CB = (get(cfg))#proxyclient_config.callback,
    CB(up),
    slog:event(trace, ?MODULE, connected),
    State1=State#state{sock=CSock, conn=connected},
    {noreply, State1};

handle_info({tcp_closed,Sock}, #state{pending=P, sock=Sock}=State) ->
    %% The TCP connection was closed.
    notify_error(P, tcp_closed),
    slog:event(trace, ?MODULE, tcp_closed),    
    CB = (get(cfg))#proxyclient_config.callback,
    CB(down),
    gen_tcp:close(Sock),
    {Host, Port, Opt}=get_config_cnx(),
    slog:event(trace, ?MODULE, connecting),
    {ok, CSock}=gen_tcp:connect(Host, Port, Opt),
    CB(up),
    slog:event(trace, ?MODULE, connected),
    State1=State#state{sock=CSock, pending=[]},
    {noreply, State1};

%%%receive reply from proxy
handle_info({tcp,Sock,Data},#state{pending=P, buf=Buf}=State)->    
    CFG = get(cfg),
    case decode(CFG#proxyclient_config.decoder, Data, Buf) of 
	{error, Error} ->
	    slog:event(failure, ?MODULE, error_decode, Error),
	    {stop,Error,State};
	{[], NewBuf} ->
	    {noreply,State#state{buf=NewBuf}};
	{ListReply, NewBuf} ->
            slog:event(trace, ?MODULE, decoded_list_reply,pbutil:unixmtime()),
	    P1=reply(ListReply, P),
	    {noreply,State#state{buf= NewBuf, pending=P1}}
    end;

handle_info(Msg, State) ->
    slog:event(warning, ?MODULE, unexpected_msg, Msg),
   {noreply, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_call(Req, From, #state{pending=P, sock=Sock}=State) ->
    Extracted_req = extract_req(Req),
    T=pbutil:unixmtime(),
    Ref=make_ref(),
    SendRes=send_request({Ref,Extracted_req}, Sock),
    P1=add_pending_or_notify(SendRes, P,{Ref,{From, call}, T}),
    slog:event(trace, ?MODULE, send, {SendRes,T}),
    State1=State#state{pending=P1},
    {noreply, State1}.

handle_cast({From, Req}, #state{pending=P, sock=Sock}=State) ->
    Extracted_req = extract_req(Req),
    SendRes=send_request(Extracted_req, Sock),
    P1=add_pending_or_notify(SendRes, P, {From, cast}),
    State1=State#state{pending=P1},
    {noreply, State1}.


code_change(Old, State, Extra) ->
    {ok, State}.


terminate(Reason, S) ->
    Reason.

%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------

extract_req(#router_req{fep_req=Req}) -> Req;
extract_req(Req) -> Req.

%% +type decode(undefined | atom(), Data::binary(), buffer()) ->
%%     {Data::binary(), buffer()} |  {[term()], buffer()}.
decode(undefined, Data, Buf) ->
    {Data, Buf};
decode(tranparent, Data, Buf) ->
    {Data, Buf};
decode(Decoder, Data, Buf) ->
    Decoder:decode(Data, Buf).

%% +type encode(undefined | atom(), Data::term()) -> term() | binary().
encode(undefined, Data) ->
    Data;
encode(tranparent, Data) ->
    Data;
encode(Decoder, Data) ->
    Decoder:encode(Data).

%% +type get_config_cnx() -> {host(), Port::integer, Opt::[tcp_option()]}.
get_config_cnx() ->
    CFG = get(cfg),
    Host=CFG#proxyclient_config.host,
    Port=CFG#proxyclient_config.port,
    Opt=CFG#proxyclient_config.opt_tcp,
    {Host, Port, Opt}.

%% +type send_request(request(), sock()) -> ok | {error, inet_error::atom()}.
send_request(Req, Sock) -> 
    CFG = get(cfg),
    Req1=encode(CFG#proxyclient_config.decoder, Req),
    gen_tcp:send(Sock, Req1).

%%This function checks the result of the sending 
%%and adds to the pending queue or notifies the requester with the error

%% +type add_pending_or_notify(ok | {error, inet_error::atom()},
%%     queue:queue(requester()), requester()) -> queue().
add_pending_or_notify(SendRes, P, {Ref, Requester, T}) ->
    case SendRes of
	ok ->   [{Ref, Requester, T}|P];
	Else -> notify(Requester, Else),
		P
    end.

%% +type notify_error(queue(requester()), Error::term()) -> ok.
notify_error(Q, Error) ->
    F = fun ({_,X,_}) -> notify(X, {error,Error}) end,
    lists:foreach(F, Q).

%% +type reply([term()], queue(requester())) -> queue(requester()).
reply([],P) ->
    P;

%%% NT : XMPP diff
reply([{nosync,RoutingAttr,Msg}|Rest],P) ->
    slog:event(trace, ?MODULE, nosync_reply),
    event_router:route(RoutingAttr,Msg),
    reply(Rest,P);

reply([{Ref,Reply}|Rest],P) ->
   {{Requester,T}, P1}=get_requester(P, Ref),
    T1=pbutil:unixmtime(),
    slog:stats(perf,?MODULE,proxy_resp_time, T1-T),
    notify(Requester, Reply),
    slog:event(trace, ?MODULE, reply),
    reply(Rest,P1).

%% +type notify(requester(), Notif::term()) -> ok | {exit, Error::term()}.
notify({From, call}, Notif) -> catch gen_server:reply(From, notif(Notif));
notify({PidFrom, cast}, Notif) -> PidFrom ! notif(Notif).

notif({error, Error}) ->
    {error, Error};
notif(Notif) ->
    {ok, Notif}.

%% +type get_requester(queue:queue(requester())) ->
%%                     {requester(), queue:queue(requester())}.
get_requester(P, Ref)->
    %%lookup Ref in pending list
    case lists:keysearch(Ref, 1, P) of
	false -> 
	    %%not fount exit
	    exit(reply_without_request);
	{value,{_, R, T}} -> 
	    %%found, remove it from pending list
	    {{R,T}, lists:keydelete(Ref,1,P)}
    end.
    



