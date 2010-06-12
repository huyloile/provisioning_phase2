-module(billing_standard_of).

%%%% This module implements the standard billing behaviour used by billing.erl
%%%% Module used when advanced billing option is not active

-export([start/1, enter/4, finish/3,reinit/2, total_price/2]).
-export([current_price/2, acte/3]).
-export([taxed_price/2,duration/2]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/billing.hrl").
-include("../include/dme.hrl").
-include("../../pdist/include/generic_router.hrl").

-define(TIMEOUT, timeout_todo).
-define(SEP,",").
-define(END,"\r\n").
%% +deftype seconds() = integer().

%% +type start(session()) -> billing:bill_mod_result().
start(Session) ->
    Bill = billing_standard:start_bill(Session),
    {ok, Bill, ?TIMEOUT}.

%% +type reinit(session(),bill()) -> billing:bill_mod_result().
reinit(Session,Bill) -> {ok,Bill, ?TIMEOUT}.

%% +type finish(session(), bill(),bool()) -> billing:bill_mod_result().
finish(Session, Bill,CLI) ->
    case catch write_cdr(Session,Bill,CLI) of
	{ok,Bill2_}->
	    {ok,Bill2_, ?TIMEOUT};
	E->
	    E
    end.

%% +type enter(session(), bill(), page_cost(), [billing_param()]) ->
%%       billing:billmod_result().
enter(Session, Bill, PageCost, OtherParameters) -> 
    billing_standard:enter(Session, Bill, PageCost, OtherParameters).

%% +type current_price(session(), bill()) -> {ok, currency:currency_sum()}.
current_price(Session, Bill) ->
    {ok, Bill#bill.current_price}.

%% +type total_price(session(), bill()) -> {ok, currency:currency_sum()}.
total_price(Session, Bill) ->
    {ok, Bill#bill.total_price}.

%% +type acte(session(), bill(), currency:currency_sum()) -> billing:billmod_result().
acte(Session, Bill, Sum) ->  
    {ok, Bill#bill{current_price = 
		   currency:add(Bill#bill.current_price, Sum)},
     ?TIMEOUT}.

%% +type taxed_price(session(), bill()) -> {ok, currency:currency_sum()}.
%%%% Returns total price since the start of this session.
taxed_price(Session, Bill) ->
    billing_standard:taxed_price(Session, Bill).

%% +type duration(session(), bill()) -> seconds().
%%%% Returns total price since the start of this session.

duration(Session, Bill) ->
    billing_standard:duration(Session, Bill).

%% +type write_cdr(session(), bill(),bool()) ->  ok | {'EXIT',term()}.
%%%% Write CDR
write_cdr(#session{bearer={sms,_}}=Session,Bill,CLI) ->
    %% don't generate cra for SMS
    NewBill=billing_standard:update_end_session(Session,Bill,CLI),
    {ok,NewBill};
write_cdr(Session,Bill,CLI)->
    Profile = Session#session.prof,
    SC=Session#session.service_code,
    US=variable:get_value(Session,user_state),
    IMSI = Profile#profile.imsi,
    NewBill=billing_standard:update_end_session(Session,Bill,CLI),
    case {Profile#profile.subscription,SC,US,IMSI} of
	{"mobi",X,undefined,_} when X=="#123";X=="*#123"->
	    %% dont generate CRA SV non restitué
	    {ok,NewBill};
	{"cmo",X,undefined,_} when X=="#123";X=="*#123"->
	    %% dont generate CRA SV non restitué
	    {ok,NewBill};
	{"dme",X,undefined,_} when X=="#123";X=="*#123" ->
	    %% dont generate CRA SV non restitué
	    slog:event(count,?MODULE,cdr_dme_not_sent),
	    {ok,NewBill};
	{"dme",X,undefined,_} when X=="#123";X=="*#123" ->
	    %% dont generate CRA SV non restitué
	    slog:event(count,?MODULE,cdr_dme_sent),
	    do_write_cdr(Session,NewBill,CLI);
	{"omer",X,undefined,_} when X=="#123";X=="*#123" ->
	    %% dont generate CRA SV non restitué
	    {ok,NewBill};
	{_,_,_,"999"++_} ->
	    %% dont generate CRA for PING QOSMON
	    {ok,NewBill};
	{_,[A|Rest],_,_} when A=/=$#,length(Rest)<3->
           %% dont generate CRA for SC=/=#1XY
	    {ok,NewBill};
	{_,[A|Rest],_,_} when A=/=$*,length(Rest)<3->
           %% dont generate CRA for SC=/=*1XY
	    {ok,NewBill};
	{_,_,_,_} ->
	    %% By default => generate CRA
	    do_write_cdr(Session,NewBill,CLI)
    end.
%% +type do_write_cdr(session(), bill(),bool()) ->  ok | {'EXIT',term()}.
do_write_cdr(Session,Bill,CLI)->
    TP=Bill#bill.total_price,
    LTP=Bill#bill.last_total_price,
    FinalPrice = trunc(currency:round_value(
		   currency:to_euro(Bill#bill.last_total_price))*1000),
    Profile = Session#session.prof,
    MSISDN = Profile#profile.msisdn,
    IMSI = Profile#profile.imsi,
    DTA = Session#session.start,
    Duration = duration(Session,Bill),
    NUM="Q99"++Session#session.service_code,
    VLR_NUM="",
    Cdr = ((case MSISDN of
	       {na, _} -> "";
	       _ -> pbutil:sprintf("%s", [MSISDN])
	   end)
	++?SEP++
	(case IMSI of
	     {na, _} -> "";
	     _ -> pbutil:sprintf("%s",[IMSI])
	 end) 
	++?SEP++
	   pbutil:sprintf("%x"++?SEP++"%d"++?SEP++"%s"++?SEP++"%s"++?END,
			  [DTA, Duration, NUM,VLR_NUM])),
    NewBill=billing_standard:update_end_session(Session,Bill,CLI),
    case ?CDR_Module:write_cdr(Cdr, Session, [standard_of, Profile#profile.subscription]) of
	ok ->
	    slog:event(count,?MODULE,cdr_generated),
	    {ok,NewBill#bill{total_price=currency:add(TP,LTP)}};
	E ->
	    slog:event(failure, ?MODULE, unable_to_bill, E),
	    exit(unable_to_dump_cdr_to_cdr_server)
    end.
