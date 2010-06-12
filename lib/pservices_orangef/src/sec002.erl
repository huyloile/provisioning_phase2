-module(sec002).

-export([definition/0, price/2, description/0]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").

%% +type definition()-> pt().
definition() ->
    #pt{duration_pt=sec002, other_parameters=sec002}.

%% +type price(session(), billing_param())-> currency:currency().
%%%% Everything is in francs
%%%% prix de l'entrée dans une page (taxation à l'acte)
price(Session, enter) ->
    currency:sum(euro, 0);

%% prix de navigation dans la zone
%% duration in milliseconds
price(Session, {duration, Duration}) when integer(Duration), Duration<30000 ->
    currency:sum(euro,0.06);
price(Session, {duration, Duration}) when integer(Duration) ->
    currency:add(currency:sum(euro,0.06),
                 currency:mult(trunc((Duration-30000)/1000)+1,
                               currency:sum(euro,0.002)));

%% prix d'envoi de la page au volume
price(Session, {volume, Vol}) ->
    currency:sum(euro, 0);

%% default clause : necessary.
%%price(Profile, _) ->
price(Session, t) ->
    currency:sum(euro,0).

%% +type description()-> string().
description() ->
    "enter -> 0E~nduration -> 0,06 pour 30 premieres secs,"
	" puis 0,002E par sec~n, volume = 0E par unite~n".

