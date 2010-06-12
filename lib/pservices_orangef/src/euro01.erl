-module(euro01).

-export([definition/0, price/2, description/0]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").


definition() ->
    #pt{duration_pt=euro01, other_parameters=euro01}.

%% Everything is in francs
%% prix de l'entrée dans une page (taxation à l'acte)
price(Profile, enter) ->
    currency:sum(frf, 0);

%% prix de navigation dans la zone
%% duration in milliseconds
price(Profile, {duration, Duration}) when integer(Duration), Duration<60000 ->
    currency:sum(euro,0.1);
price(Profile, {duration, Duration}) when integer(Duration) ->
    currency:add(currency:sum(euro,0.1),
                 currency:mult(trunc((Duration-60000)/15000)+1,
                               currency:sum(euro,0.025)));

%% prix d'envoi de la page au volume
price(Profile, {volume, Vol}) ->
    currency:sum(frf, 0);

%% default clause : necessary.
%%price(Profile, _) ->
price(Profile, t) ->
    currency:sum(frf,0).

description() ->
    "enter -> 0E~nduration -> 0,1E par min puis 0,025E par 15s~n,"
	" volume = 0E par unite~n".

