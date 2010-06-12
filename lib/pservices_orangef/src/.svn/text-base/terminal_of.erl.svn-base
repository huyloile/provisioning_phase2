-module(terminal_of).
-export([info/1,info/3,ussd_level/1,imei/2,tac/1]).

-include("../../pserver/include/pserver.hrl").

%% +deftype ussd_level() =  1 | 2 | 3 | 4.
%% +deftype ussd_end_size() =  181 | 130 | 64 | 63.

%% +type info(terminal())-> terminal().
info(#terminal{imei=IMEI}=Term) when list(IMEI)->
    case lists:member($X,IMEI) of
	true->
	    U_L=lists:last(IMEI)-$0,
	    Term#terminal{ussdsize=ussd_size(U_L)};
	false->
	    Term
    end;
info(Term)->
    Term.

%% +type info(string(),ussd_level(),terminal())-> terminal().
info(TAC,USSD_LEVEL,#terminal{imei=IMEI}=Terminal)->
    case {pbutil:all_digits(TAC),IMEI} of
	{true,_}->
	    Terminal#terminal{imei=imei(TAC,USSD_LEVEL),
			      ussdsize=ussd_size(USSD_LEVEL)};
	{false,IMEI} when list(IMEI)->
	    %% TAC inconnu, on garde l'IMEI precedent
	    Terminal;
	{false,{na,_}} ->
	    %% TAC inconnu et IMEI a NULL
	     Terminal#terminal{imei="",
			      ussdsize=181}
    end.

%% +type imei(string(),ussd_level())-> string().
imei(TAC,USSD_LEVEL) when length(TAC)==6->
    TAC++"XXXXXXX"++integer_to_list(USSD_LEVEL);
imei(TAC,USSD_LEVEL) when length(TAC)==8->
    TAC++"XXXXX"++integer_to_list(USSD_LEVEL).

%% +type tac(string() | null | undefined | {na,Reason::atom()})-> default | string().
tac(IMEI) when is_list(IMEI), length(IMEI) > 6 ->
    case pbutil:split_at($X,IMEI) of
	{TAC,Rest}->
	    TAC;
	not_found->
	    lists:sublist(IMEI, 6)
    end;
tac(_) ->
    default.

%% +type ussd_size(ussd_level()) -> ussd_end_size().
ussd_size(1)->
    181;
ussd_size(2) ->
    130;
ussd_size(3) ->
    64;
ussd_size(4) ->
    63;
ussd_size(0)->
    181.

%% +type ussd_level(Length::integer()) -> ussd_level().
ussd_level(X) when X>130->
    1;
ussd_level(X) when X>64->
    2;
ussd_level(X) when X==64->
    3;
ussd_level(X) when X<64->
    4.
