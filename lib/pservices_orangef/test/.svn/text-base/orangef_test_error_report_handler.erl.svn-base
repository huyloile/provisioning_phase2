-module(orangef_test_error_report_handler).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2,
	 terminate/2, code_change/3]).

init(Arg)->
    {ok,[]}.

handle_event(Event, Acc) ->
    {ok, [Event | Acc]}.

handle_info(Msg, State) ->
    {ok, State}.

handle_call(purge, State) ->
    {ok, State, []};
handle_call(Request, State) ->
    {ok, unexpected, State}.

terminate(Arg, State) ->
    ok.

code_change(_, State, _) ->
    {ok, State}.
