-module(sec001).

-export([definition/0, price/2, description/0]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").

%% +type definition()-> pt().
definition() ->
    #pt{duration_pt=sec001, other_parameters=sec001}.

%% +type price(session(), billing_param())-> currency:currency().
%%%% Everything is in francs
%%%% prix de l'entr�e dans une page (taxation � l'acte)
price(Session, enter) ->
    currency:sum(euro, 0);

%% prix de navigation dans la zone
%% duration in milliseconds
price(Session, {duration, Duration}) when integer(Duration) ->
    currency:mult(trunc(Duration/1000)+1,
		  currency:sum(euro,0.001));

%% prix d'envoi de la page au volume
price(Session, {volume, Vol}) ->
    currency:sum(euro, 0);

%% default clause : necessary.
%%price(Profile, _) ->
price(Session, _) ->
    currency:sum(euro,0).

%% +type description()-> string().
description() ->
    "enter -> 0E~nduration -> 0,001E par sec~n, volume = 0E par unite~n".

