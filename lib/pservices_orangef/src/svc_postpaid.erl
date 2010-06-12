-module(svc_postpaid).

-export([store_msisdn/3,init_svc_data/3,redirect_by_offre/2]).

-include("../../pserver/include/pserver.hrl").
-include("../include/postpaid.hrl").

%% +type store_msisdn(session(), MSISDN::string(), Url::string()) -> erlpage_result().
%%%% Store into profile new msisdn
    
store_msisdn(abs, MSISDN, URL) -> [ {redirect,abs,URL} ];
store_msisdn(Session, [$ |MSISDN], URL) ->
    %% Problem: "+" is " " escaped in "store_msisdn?+33612345678'.
    store_msisdn(Session, [$+|MSISDN], URL);
store_msisdn(Session, MSISDN, URL) ->
    Profile = Session#session.prof,
    Profile1 = Profile#profile{msisdn=MSISDN},
    Session1 = Session#session{prof=Profile1},
    {redirect, Session1, URL}.

%% +type init_svc_data(abs,string(),URL::string())-> erlpage_result().
init_svc_data(abs,_,URL)->
    [{redirect,abs,URL}];
init_svc_data(#session{prof=Prof}=Session,OF,URL) ->
    %% subscription=postpaid
    %% init svc_data
    Session1 =
	case svc_spider:get_availability(Session) of
	    available -> Session;
	    _ -> svc_util_of:update_user_state(
		       Session#session{prof=Prof#profile{
					      subscription="postpaid"}},
		       #postpaid_user_state{offre=list_to_atom(OF)})
	end,
    {redirect,Session1,URL}.

%% +type redirect_by_offre(session(),string()) -> erlpage_result().
redirect_by_offre(abs,REDIR_OFs) ->
    lists:map(fun(X) -> [OF,U] = string:tokens(X,"="), {redirect,abs,U} end,
	      string:tokens(REDIR_OFs,","));
redirect_by_offre(Sess,REDIR_OFs) ->
    State = svc_util_of:get_user_state(Sess),
    OF=State#postpaid_user_state.offre,
    FL = fun (S) -> [Plan,PCD] = string:tokens(S,"="), {Plan,PCD} end,
    L=lists:map(FL, string:tokens(REDIR_OFs, ",")),
    OffreURL=(case lists:keysearch(OF,1,L) of
		  {value, {_,URL1}} -> 
		      URL1;
		  false  -> 
		      case lists:keysearch("default",1,L) of
			  {value, {_,URL2}} -> 
			      URL2;
			  false -> 
			      slog:event(internal,?MODULE,bad_postpaid_of,
					 REDIR_OFs),
			      "#temporary"
		      end
	      end),
    {redirect,Sess,OffreURL}.
