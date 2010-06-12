-module(content015).

-export([definition/0, price/2, description/0]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").


definition() ->
    #pt{duration_pt=sec001, other_parameters=content015}.

%% Everything is in francs
%% prix de l'entrée dans une page (taxation à l'acte)
price(Profile, enter) ->
    currency:sum(euro, 0.15);

%% prix d'envoi de la page au volume
price(Profile, {volume, Vol}) ->
    currency:sum(frf, 0);

%% default clause : necessary.
%%price(Profile, _) ->
price(Profile, t) ->
    currency:sum(frf,0).

description() ->
    "enter -> 0.15E~nduration -> sec001~n, volume = 0E par unite~n".

