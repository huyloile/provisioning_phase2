-module(pt_test_of1).

-export([definition/0, price/2, description/0]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").

%% +type definition()-> pt().
definition() ->
    #pt{duration_pt=pt_test_of1, other_parameters=pt_test_of1}.

%% +type price(session(), billing_param())-> currency:currency().
%%%% Everything is in francs
%%%% prix de l'entrée dans une page (taxation à l'acte)
price(#session{prof=Prof}, enter) ->
    case Prof#profile.subscription of
	"mobi"->
	    currency:sum(euro, 0.2);
	"cmo"->
	    currency:sum(euro, 0.1);
	_->
	    currency:sum(euro, 0)
    end;

	
%%%% prix de navigation dans la zone
%%%% duration in milliseconds
price(Session, {duration, Duration}) when integer(Duration) ->
   currency:sum(euro, 0);

%% prix d'envoi de la page au volume
price(Session, {volume, Vol}) ->
    currency:sum(euro, 0);

%% default clause : necessary.
%%price(Profile, _) ->
price(Session, _) ->
    currency:sum(euro,0).

%% +type description()-> string().
description() ->
    "enter -> 0.2E pour mobi~n0.1E pour CMO gratuit pour postpaid".

