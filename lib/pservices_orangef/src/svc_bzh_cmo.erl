-module(svc_bzh_cmo).

-export([redirect_compte/1]).
-export([redirect_compte_long/1]).
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").


%% +type redirect_compte(session())-> erlpage_result().
redirect_compte(abs)->
    select_home(abs,abs);
redirect_compte(Session)->
    select_home(Session,svc_util_of:get_user_state(Session)).
	
%% +type select_home(session(),sdp_user_state())-> erlpage_result().
select_home(abs,_)->
    [{redirect,abs,"#forf_ac_princ_ac_odr_ac"},
     {redirect,abs,"#forf_ac_princ_ep_odr_ac"},
     {redirect,abs,"#forf_ep_princ_ac_odr_ac"},
     {redirect,abs,"#forf_ep_princ_ep_odr_ac"},
     {redirect,abs,"#forf_ac_princ_ac_odr_ep"},
     {redirect,abs,"#forf_ac_princ_ep_odr_ep"},
     {redirect,abs,"#forf_ep_princ_ac_odr_ep"},
     {redirect,abs,"#forf_ep_princ_ep_odr_ep"},
     {redirect,abs,"#temporary"}
     ];
select_home(S, #sdp_user_state{declinaison=X}=State)
  when X==?bzh_cmo;X==?bzh_cmo2;X==?DCL_BZH_CB1;X==?DCL_BZH_CB2;X==?DCL_BZH_CB3;X==?DCL_BZH_CB4-> 
    case
	{svc_compte:etat_cpte(State,forf_bzh),
	 svc_compte:etat_cpte(State,cpte_princ),
	 svc_compte:etat_cpte(State,cpte_odr)
	 } of
	{?CETAT_AC,?CETAT_AC,?CETAT_AC}->
	    {redirect,S,"#forf_ac_princ_ac_odr_ac"};
	{?CETAT_AC,?CETAT_AC,_}->
	    {redirect,S,"#forf_ac_princ_ac_odr_ep"};
	{?CETAT_AC,?CETAT_EP, ?CETAT_AC}->
	    {redirect,S,"#forf_ac_princ_ep_odr_ac"};
	{?CETAT_AC,?CETAT_EP, _}->
	    {redirect,S,"#forf_ac_princ_ep_odr_ep"};
	{?CETAT_EP,?CETAT_AC,?CETAT_AC}->
	    {redirect,S,"#forf_ep_princ_ac_odr_ac"};
	{?CETAT_EP,?CETAT_AC,_}->
	    {redirect,S,"#forf_ep_princ_ac_odr_ep"};
	{?CETAT_EP,?CETAT_EP,?CETAT_AC}->
	    {redirect,S,"#forf_ep_princ_ep_odr_ac"};
	{_,_,_}->
	    {redirect,S,"#forf_ep_princ_ep_odr_ep"}
    end;
select_home(S,E) ->
    slog:event(internal,?MODULE,select_home_default_clause,E),
    {redirect,S,"#temporary"}.
	
%% +type redirect_compte(session())-> erlpage_result(). (just for selfcare_long)
redirect_compte_long(abs)->
    select_home_long(abs,abs);
redirect_compte_long(Session)->
    select_home_long(Session,svc_util_of:get_user_state(Session)).

%% +type select_home(session(),sdp_user_state())-> erlpage_result(). (for selfcare_long)
select_home_long(abs,_)->
    [{redirect,abs,"#suivi_conso"},
     {redirect,abs,"#temporary"}
     ];
select_home_long(S, #sdp_user_state{declinaison=X}=State)
  when X==?bzh_cmo;X==?bzh_cmo2;X==?DCL_BZH_CB1;X==?DCL_BZH_CB2;X==?DCL_BZH_CB3;X==?DCL_BZH_CB4->
    [Forf_State,Princ_State] =
        lists:map(fun(Account)->svc_compte:etat_cpte(State,Account) end, [forf_bzh,cpte_princ]),

    case {check_etat(Forf_State),check_etat(Princ_State)} of
	{true,true}->
	    {redirect,S,"#suivi_conso"};
	Else -> 
	    slog:event(service_ko,?MODULE,select_home,{Else,S}),
	    {redirect,S,"#temporary"}					 
    end;
select_home_long(S,E) ->
    slog:event(internal,?MODULE,select_home_default_clause,E),
    {redirect,S,"#temporary"}.
	
check_etat(?CETAT_EP) -> true;
check_etat(?CETAT_AC) -> true;
check_etat(_) -> false.
	  
