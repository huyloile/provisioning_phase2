-module(postpaid_fake).

-export([selfcare/1]).
-include("../../../../lib/pserver/include/pserver.hrl").

selfcare(#session{prof=Profile}=Session)->
    IMSI=Profile#profile.imsi,
    redir_imsi(IMSI,Session).

redir_imsi([$9,$9,$9,$0,$0,$0,$9,$2|T]=IMSI,Session)->
    {redirect,Session,"#postpaid"};
redir_imsi([$9,$9,$9|T]=IMSI,Session) ->
    {redirect,Session,"#not_postpaid"};
redir_imsi(IMSI,Session) ->
    case sachem_cmo_fake:get_test_subscription(IMSI) of
	"postpaid"->
	    {redirect,Session,"#postpaid"};
	_->
	     {redirect,Session,"#not_postpaid"}
    end.
	
