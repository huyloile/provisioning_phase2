%%%%------------------------------------------------------------------------
%%%% Service "Portabilite des numeros" :
%%%% The correspondence between msisdn (with the shape 0ZABPQMCDU) and
%%%% an operator, could be found with the for first number of the
%%%% msisdn (ie : 0ZAB).
%%%% (ServiceCode = *146#).
%%%%------------------------------------------------------------------------

-module(svc_msisdn_operator).
%% creation of the permanent table ozab_operator.
-export([start_link/0, init_table/0, keep_table/0]).
%% service.
-export([input_or_empty/1, verify_msisdn_operator/2,
	is_msisdn_orange/2]).
-include("../../pserver/include/pserver.hrl").

%%%% This part implement the creation of ets table ozab_operator. %%%%%%%%%

%% +deftype tid() = pid() | atom().
%% +type start_link() -> {ok, pid()}.
%%
%%%% For supervision.
start_link() ->
    {ok, spawn_link(?MODULE, init_table, [])}.

%% +type init_table() -> tid().
%%
%%%%
init_table() ->
    OZAB_Operator_Tid =
	ets:new(ozab_operators, [set, protected, named_table, {keypos, 1}]),
    case catch load_table(OZAB_Operator_Tid) of
	ok->
	    slog:event(trace, ?MODULE, ets_table_created, OZAB_Operator_Tid),
	    keep_table();
	Else->
	    slog:event(failure,?MODULE,create_table_error,Else)
    end.

%% +type load_table(tid()) -> ok.
%%%%
load_table(OZAB_Operator_Tid) ->
    {ok, [List_OZAB_Operator]} =
	file:consult("lib/pservices_orangef/priv/list_0zab.txt"),
    ets:insert(OZAB_Operator_Tid, List_OZAB_Operator),
    ok.

%% +type keep_table() -> tid().
%%%%
keep_table() ->
    receive
	Msg -> pbutil:badmsg(Msg, ?MODULE) 
    after 1000 ->
	    svc_msisdn_operator:keep_table()
    end.

%%%% This part implement the service. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type input_or_empty(session) -> erlpage_result().
%%
%%%% Differents redirections if the service is initialy called with
%%%% an argument(input) or not.
input_or_empty(abs) ->
    [{redirect, abs, "#help"},
     {redirect, abs, "#input"}];
input_or_empty(#session{mode_data=#mdata{nav_buffer=[]}}=Session) ->
    {redirect, Session, "#help"};
input_or_empty(#session{}=Session) ->
    {redirect, Session, "#input"}.

%% +type verify_msisdn_operator(session, string()) -> erlpage_result().
%%
%%%%
verify_msisdn_operator(abs, _) ->
    [{redirect, abs, "#help"}] ++
	redirect_result(abs, abs, abs);
verify_msisdn_operator(Session, Msisdn) when length(Msisdn) < 4 ->
    {redirect, Session, "#help"};
verify_msisdn_operator(Session, [O,Z,A,B|_]=Msisdn) ->
    case pbutil:all_digits(Msisdn) of
	true ->
	    Result = ets:lookup(ozab_operators, [O,Z,A,B]),
	    redirect_result(Session, [O,Z,A,B], Result);
	false ->
	    {redirect, Session, "#help"}
    end.

%% +type redirect_result(session, string(), string()) ->
%%    erlpage_result().
%%%%
redirect_result(abs, _, _) ->
    [{redirect, abs, "#not_metropole"},
     {redirect, abs, "#ozab_orangef", ["OZAB"]},
     {redirect, abs, "#ozab_not_orangef", ["OZAB"]}];
redirect_result(Session, Ozab, []) ->
    {redirect, Session, "#not_metropole"};
redirect_result(Session, Ozab, [{_, orangef}]) ->
    {redirect, Session, "#ozab_orangef", [{"OZAB", Ozab}]};
redirect_result(Session, Ozab, [{_, _}]) ->
    {redirect, Session, "#ozab_not_orangef", [{"OZAB", Ozab}]}.

%% +type is_msisdn_orange(session(),string())-> erlpage_result().
is_msisdn_orange(abs,_)->
    [{redirect, abs, "#not_metropole"},
     {redirect, abs, "#ozab_orangef"},
     {redirect, abs, "#ozab_not_orangef"},
     {redirect, abs, "#system_failure"}];
is_msisdn_orange(Session,MSISDN)->
    case verify_msisdn(MSISDN) of
	mobile->
	    case catch ocf_rdp:isMsisdnOrange(MSISDN) of
		true->
		    {redirect, Session, "#ozab_orangef"};
		false->
		    {redirect, Session, "#ozab_not_orangef"};
		Else ->
		    {redirect, Session, "#system_failure"}
	    end;
	wrong_number->
	    {redirect, Session, "#not_metropole"};
	wrong_format->
	    {redirect, Session, "#help"}
    end.

%% +type verify_msisdn(Msidn::string())-> mobile | wrong_format | wrong_number.
verify_msisdn("+336"++T=Msisdn) when length(Msisdn)==11->
    case pbutil:all_digits(Msisdn) of true-> mobile; false-> wrong_format end;
verify_msisdn("336"++T=Msisdn) when length(Msisdn)==11->
    case pbutil:all_digits(Msisdn) of true-> mobile; false-> wrong_format end;
verify_msisdn("06"++T=Msisdn) when length(Msisdn)==10->
    case pbutil:all_digits(Msisdn) of true-> mobile; false-> wrong_format end;
verify_msisdn("+337"++T=Msisdn) when length(Msisdn)==11->
    case pbutil:all_digits(Msisdn) of true-> mobile; false-> wrong_format end;
verify_msisdn("337"++T=Msisdn) when length(Msisdn)==11->
    case pbutil:all_digits(Msisdn) of true-> mobile; false-> wrong_format end;
verify_msisdn("07"++T=Msisdn) when length(Msisdn)==10->
    case pbutil:all_digits(Msisdn) of true-> mobile; false-> wrong_format end;
verify_msisdn(Msisdn) ->
    case pbutil:all_digits(Msisdn)of 
	true-> wrong_number; 
	false-> wrong_format 
    end.

	     
