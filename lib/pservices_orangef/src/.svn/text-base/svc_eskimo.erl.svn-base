-module(svc_eskimo).
-define(Limit1,"131").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/page.hrl").

%% XML API
-export([select_home_niv1/1,
	 select_home_niv3/1]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 1 and 2 (niveau 1 & 2) phones.

select_home_niv1(abs)->
    [{redirect,abs,"#ac_niv1"},{redirect,abs,"#ac_niv2"},
     {redirect,abs,"#ep_niv1"},{redirect,abs,"#ep_niv2"}];
select_home_niv1(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home_niv1(S,list_to_atom(Subs)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 3 (niveau 3) phones.

select_home_niv3(abs)->
    [{redirect,abs,"#act_niv3"},{redirect,abs,"#ep_niv3"}];
select_home_niv3(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home_niv3(S,list_to_atom(Subs)). 
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDIRECTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts when
%%%% subscription is carrefour_prepaid.

select_home_niv1(S,Subs) when Subs==symacom ->
    State = svc_util_of:get_user_state(S),
    case svc_compte:etat_cpte(State,cpte_princ) of
 	%% case main account (cpte_princ) active
 	?CETAT_AC ->
 	    svc_util:redirect_size(S,?Limit1,"#ac_niv1","#ac_niv2");
	%% case main account out of credit
 	_ ->
 	    svc_util:redirect_size(S,?Limit1,"#ep_niv1","#ep_niv2")
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the account when
%%%% subscription is carrefour_prepaid.

select_home_niv3(S,Subs)when Subs==symacom->
    State = svc_util_of:get_user_state(S),
    case svc_compte:etat_cpte(State,cpte_princ) of
	?CETAT_AC->
	    {redirect, S, "#act_niv3"};
	_->
	    {redirect, S, "#ep_niv3"}   
	end.

