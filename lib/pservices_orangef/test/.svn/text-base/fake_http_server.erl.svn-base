-module(fake_http_server).
-export([process/2, process_status/2]).
-export([create_table/0]).
-export([set_response_list/1]).
-export([create_ets/0,delete_ets/1]).

-include("../../pfront/include/httpserver.hrl").

-define(HTTP_REPLY, http_reply).
-define(NODE, possum@localhost).
-define(HTTP, fake_http_server).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% httpserver_server handler
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type process(httpserver_request_info(),[ustring()]) -> httpserver_reply().
process(#httpserver_request_info{method = post}=Req, Body) ->
    log({receiving, Req, Body}),
    {200, "text/html", reply()}.

process_status(#httpserver_request_info{method = post}=Req, Body) ->
    log({receiving, Req, Body}),
    reply_with_status().
    %%{406, "text/html", reply_wi()}.

reply_with_status()->
    [{?HTTP_REPLY, [Status|Rest]}] = ets:lookup(?HTTP,?HTTP_REPLY),
    [HTML|T] = Rest,
    ets:insert(?HTTP, {?HTTP_REPLY, T}),
    {Status, "text/html", HTML}.

reply() ->
    [{?HTTP_REPLY, [HTML|T]}] = ets:lookup(?HTTP,?HTTP_REPLY),
    ets:insert(?HTTP, {?HTTP_REPLY, T}),
    slog:event(trace,?MODULE,html_reply_server,[HTML]),
    HTML.


%% +type log(term()) -> ok.
log(Event) ->
    slog:event(trace,
           ?MODULE,
           Event),
    io:format("[EAI SIMULATOR] : ~p~n",[Event]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% ets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create_ets() ->
    proc_lib:start_link(?MODULE,create_table,[]).

create_table() ->
    proc_lib:init_ack({ok,self()}),
    (catch ets:new(?HTTP,[named_table,public,set])),
    receive
        stop -> ok
    end.

delete_ets(Pid) ->
    Pid ! stop.

set_response_list(List) ->
    ets:insert(?HTTP,{?HTTP_REPLY,List}).


