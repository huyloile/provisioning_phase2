-module(svc_virgin_cb).
-define(Limit1,"131").

-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

%% XML API
-export([select_home_niv1/1,
	 select_home_niv3/1,
	 redirect_compte/1,
	 do_subscription/3,
	 first_page/5]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 1 and 2 (niveau 1 & 2) phones.

select_home_niv1(abs)->
    [{redirect,abs,"#ac_ind_ep_niv1"},{redirect,abs,"#ac_ind_ep_niv2"},
     {redirect,abs,"#ac_ind_ac_niv1"},{redirect,abs,"#ac_ind_ac_niv2"},
     {redirect,abs,"#ep_ac_ac_niv1"},{redirect,abs,"#ep_ac_ac_niv2"},
     {redirect,abs,"#ep_ac_ep_niv1"},{redirect,abs,"#ep_ac_ep_niv2"},
     {redirect,abs,"#ep_ep_ac_niv1"},{redirect,abs,"#ep_ep_ac_niv2"},
     {redirect,abs,"#ep_ep_ep_niv1"},{redirect,abs,"#ep_ep_ep_niv2"},
     {redirect,abs,"#ac_ind_ac_niv1_cb4"},{redirect,abs,"#ac_ind_ac_niv2_cb4"},
     {redirect,abs,"#ac_ind_ep_niv1_cb4"},{redirect,abs,"#ac_ind_ep_niv2_cb4"},
     {redirect,abs,"#ep_ac_ac_niv1_cb4"},{redirect,abs,"#ep_ac_ac_niv2_cb4"},
     {redirect,abs,"#ep_ac_ep_niv1_cb4"},{redirect,abs,"#ep_ac_ep_niv2_cb4"},
     {redirect,abs,"#ep_ep_ac_niv1_cb4"},{redirect,abs,"#ep_ep_ac_niv2_cb4"},
     {redirect,abs,"#ep_ep_ep_niv1_cb4"},{redirect,abs,"#ep_ep_ep_niv2_cb4"},
     {redirect,abs,"#ac_ep_ep_niv1_cb4"},{redirect,abs,"#ac_ep_ep_niv2_cb4"}];

select_home_niv1(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home_niv1(S,list_to_atom(Subs)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 3 (niveau 3) phones.

select_home_niv3(abs)->
    [{redirect,abs,"#ac_niv3"},{redirect,abs,"#ep_niv3"},
     {redirect,abs,"#ac_niv3_cb4"},{redirect,abs,"#ep_niv3_cb4"}];
select_home_niv3(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home_niv3(S,list_to_atom(Subs)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription(session(),Opt::string(),URLs::string())->
%%                       erlpage_result().
%%%% XML API Interface to subscription.

do_subscription(abs,Opt,URLs) ->
    [Uok,UdejaAct,Uinsuff,Unok]=string:tokens(URLs, ","),
    [{redirect,abs,Uinsuff},
     {redirect,abs,Unok},
     {redirect,abs,UdejaAct},
     {redirect,abs,Uok}];

do_subscription(#session{}=S,Option,URLs) ->
    do_subscription_request(S,list_to_atom(Option),URLs).  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_page(session(),Opt::string(),
%%                  UAct::string(),UInsuf::string(),
%%                  UGene::string())->
%%                  erlpage_result(). 
%%%% First page for subscription of option.
%%%% Redirect to UAct when option already active,
%%%% redirect to UIncomp when option incompatible with existing options,
%%%% redirect to UInsuf when not enough credit,
%%%% redirect to UGene when subscription proposed.
	
first_page(abs,Opt,UAct,UInsuf,UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene}];   
first_page(Session,Option,UAct,UInsuf,UGene) ->
    Opt = list_to_atom(Option),
    PrixSubscr = svc_util_of:subscription_price(Session, Opt),
    {Session_new,State_New} = svc_options:check_topnumlist(Session),
    EnoughCredit = 
	currency:is_infeq(currency:sum(euro,PrixSubscr/1000),
			  svc_compte:solde_cpte(State_New,cpte_princ)),
    Subscription = svc_util_of:get_souscription(Session_new),
    case svc_options:is_option_activated(Session_new,Opt) of
	true -> {redirect,Session_new,UAct};
	false ->
	    case EnoughCredit of 
		true->
		    {redirect,Session_new,UGene};
		false ->
		    {redirect,Session_new,UInsuf}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDIRECTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts when
%%%% subscription is virgin_comptebloque.


select_home_niv1(S,Subs) 
  when Subs==virgin_comptebloque ->

    State = svc_util_of:get_user_state(S),
    case State#sdp_user_state.declinaison of

	?DCLNUM_VIRGIN_COMPTEBLOQUE1 -> 
	    select_home_niv1(S,Subs,virgin_cb1);
	?DCLNUM_VIRGIN_COMPTEBLOQUE2 ->  
	    select_home_niv1(S,Subs,virgin_cb2);
	?DCLNUM_VIRGIN_COMPTEBLOQUE3 ->
	    select_home_niv1(S,Subs,virgin_cb3);
	?DCLNUM_VIRGIN_COMPTEBLOQUE4 ->
	    select_home_niv1(S,Subs,virgin_cb4);
	?DCLNUM_VIRGIN_COMPTEBLOQUE5 ->
	    select_home_niv1(S,Subs,virgin_cb5);
	?DCLNUM_VIRGIN_COMPTEBLOQUE6 ->
	    select_home_niv1(S,Subs,virgin_cb6);
	?DCLNUM_VIRGIN_COMPTEBLOQUE7 ->
	    select_home_niv1(S,Subs,virgin_cb7);
	?DCLNUM_VIRGIN_COMPTEBLOQUE8 ->
	    select_home_niv1(S,Subs,virgin_cb8);
	?DCLNUM_VIRGIN_COMPTEBLOQUE9 ->
	    select_home_niv1(S,Subs,virgin_cb9);
	?DCLNUM_VIRGIN_COMPTEBLOQUE10->
	    select_home_niv1(S,Subs,virgin_cb10);
	?DCLNUM_VIRGIN_COMPTEBLOQUE11->
	    select_home_niv1(S,Subs,virgin_cb11);
	?DCLNUM_VIRGIN_COMPTEBLOQUE12->
	    select_home_niv1(S,Subs,virgin_cb12);
	?DCLNUM_VIRGIN_COMPTEBLOQUE13->
	    select_home_niv1(S,Subs,virgin_cb13);
	?DCLNUM_VIRGIN_COMPTEBLOQUE14->
	    select_home_niv1(S,Subs,virgin_cb14);
	?DCLNUM_VIRGIN_COMPTEBLOQUE15->
	    select_home_niv1(S,Subs,virgin_cb15);
	?DCLNUM_VIRGIN_COMPTEBLOQUE16->
	    select_home_niv1(S,Subs,virgin_cb16)
    end.

select_home_niv1(S,Subs, Forf)
  when ( (Forf==virgin_cb1) or
	 (Forf==virgin_cb2) or
	 (Forf==virgin_cb3) or
	 (Forf==virgin_cb5) or
	 (Forf==virgin_cb6) or
	 (Forf==virgin_cb7) or
	 (Forf==virgin_cb8) or
	 (Forf==virgin_cb9) or
	 (Forf==virgin_cb10) or
	 (Forf==virgin_cb11) or
	 (Forf==virgin_cb12) or
	 (Forf==virgin_cb13) or
	 (Forf==virgin_cb14) or
	 (Forf==virgin_cb15) or
	 (Forf==virgin_cb16)
	) ->
    
    State = svc_util_of:get_user_state(S),
    
    [Princ_State,Forf_State,Odr_State] =
	lists:map(fun(Account)->svc_compte:etat_cpte(State,Account) end, [forf_virgin,cpte_princ,cpte_odr]),
    
    [Is_Opt_200,Is_Opt_Ill]=
	lists:map(fun(Option)->svc_options:is_option_activated(S,Option) end, [opt_sms_200,opt_sms_ill]),

    case {Is_Opt_200,Is_Opt_Ill} of
	{true,false} ->
	    select_home_option(S,Princ_State,Forf_State,Odr_State,"sms_200");
	{false,true} ->
	    select_home_option(S,Princ_State,Forf_State,Odr_State,"sms_ill");
	{false,false} ->
	    select_home_option(S,Princ_State,Forf_State,Odr_State,"sms_no")
    end;

select_home_niv1(S,Subs, Forf)
  when Forf==virgin_cb4->

 State = svc_util_of:get_user_state(S),

     case {svc_compte:etat_cpte(State,forf_virgin),
  	   svc_compte:etat_cpte(State,cpte_princ),
	   svc_compte:etat_cpte(State,cpte_odr)} of

	{?CETAT_AC,_,?CETAT_AC} ->
           svc_util:redirect_size(S,?Limit1,"#ac_ind_ac_niv1_cb4","#ac_ind_ac_niv2_cb4");

        {?CETAT_AC,_,_} ->
           svc_util:redirect_size(S,?Limit1,"#ac_ind_ep_niv1_cb4","#ac_ind_ep_niv2_cb4");

        {_,?CETAT_AC,?CETAT_AC} ->
           svc_util:redirect_size(S,?Limit1,"#ep_ac_ac_niv1_cb4","#ep_ac_ac_niv2_cb4");

        {_,?CETAT_AC,_} ->
           svc_util:redirect_size(S,?Limit1,"#ep_ac_ep_niv1_cb4","#ep_ac_ep_niv2_cb4");

        {_,_,?CETAT_AC} ->
           svc_util:redirect_size(S,?Limit1,"#ep_ep_ac_niv1_cb4","#ep_ep_ac_niv2_cb4");

        {_,_,_} ->
           svc_util:redirect_size(S,?Limit1,"#ep_ep_ep_niv1_cb4","#ep_ep_ep_niv2_cb4")

      end.

select_home_option(Session,Princ_State,Forf_State,Odr_State,Opt) ->
    case {Princ_State,Forf_State,Odr_State} of
	
	{?CETAT_AC,_,?CETAT_AC} ->
	    svc_util:redirect_size(Session,?Limit1,"#ac_ind_ac_niv1_"++Opt,"#ac_ind_ac_niv2_"++Opt);
	
	{?CETAT_AC,_,_} ->
	    svc_util:redirect_size(Session,?Limit1,"#ac_ind_ep_niv1_"++Opt,"#ac_ind_ep_niv2_"++Opt);

	{?CETAT_EP,?CETAT_AC,?CETAT_AC} ->
	    svc_util:redirect_size(Session,?Limit1,"#ep_ac_ac_niv1_"++Opt,"#ep_ac_ac_niv2_"++Opt);

	{_,?CETAT_AC,_} ->
	    svc_util:redirect_size(Session,?Limit1,"#ep_ac_ep_niv1_"++Opt,"#ep_ac_ep_niv2_"++Opt);

	{_,_,?CETAT_AC} ->
	    svc_util:redirect_size(Session,?Limit1,"#ep_ep_ac_niv1_"++Opt,"#ep_ep_ac_niv2_"++Opt);

	{_,_,_} ->
	    slog:event(warning, ?MODULE, princ_forf_odr_accounts_states, [Princ_State,Forf_State,Odr_State]),
	    svc_util:redirect_size(Session,?Limit1,"#ep_ep_ep_niv1_"++Opt,"#ep_ep_ep_niv2_"++Opt)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the account when
%%%% subscription is virgin_comptebloque.

select_home_niv3(S,Subs) when Subs==virgin_comptebloque->
    State = svc_util_of:get_user_state(S),
    case (svc_compte:etat_cpte(State,cpte_princ)==?CETAT_AC) or
	(svc_compte:etat_cpte(State,forf_virgin)==?CETAT_AC) of

	true->
	    case State#sdp_user_state.declinaison of
		?DCLNUM_VIRGIN_COMPTEBLOQUE4 -> 
		    {redirect, S, "#ac_niv3_cb4"};
		_ ->
		    {redirect, S, "#ac_niv3"}
	    end;

	false->
	    case State#sdp_user_state.declinaison of
		?DCLNUM_VIRGIN_COMPTEBLOQUE4 -> 
		    {redirect, S, "#ep_niv3_cb4"};
		_ ->
		    {redirect, S, "#ep_niv3"}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUBSCRIPTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription_request(session(),Opt::string(),URLs::string())->
%%                               erlpage_result().
%%%% Subscribe to options via opt_cpt_request.

do_subscription_request(Session,Opt,URLs)->
    svc_virgin:do_subscription_request(Session,Opt,URLs).

%% +type redirect_compte(session())-> erlpage_result().
redirect_compte(abs)->
    select_home(abs,abs);
redirect_compte(Session)->
    {NewSess,State} = svc_options:check_topnumlist(Session),
    select_home(NewSess,State).

%% +type select_home(session(),sdp_user_state())-> erlpage_result().
select_home(abs,_)->
    [{redirect,abs,"#suivi_conso"},     
     {redirect,abs,"#temporary"}
     ];

    
select_home(S, #sdp_user_state{declinaison=X}=State)
  when X==?DCLNUM_VIRGIN_COMPTEBLOQUE1;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE2;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE3;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE4;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE5;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE6;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE7;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE8;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE9;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE10;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE11;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE12;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE13;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE14;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE15;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE16;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE17;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE18;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE19;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE20;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE24;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE25;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE26;
       X==?DCLNUM_VIRGIN_COMPTEBLOQUE27
 ->
    
    [Forf_State,Princ_State,Odr_State] =
        lists:map(fun(Account) ->
                          svc_compte:etat_cpte(State,Account) 
                  end, 
                  [forf_virgin,cpte_princ,cpte_odr]),
    slog:event(trace,?MODULE,select_home,[Forf_State,Princ_State,Odr_State]),

    case {check_etat(Forf_State),check_etat(Princ_State)} of
	{true,true}->
	    case (X) of
		?DCLNUM_VIRGIN_COMPTEBLOQUE4 ->
		    {redirect,S,"#suivi_conso4"};
		_ ->
		    {redirect,S,"#suivi_conso"}
	    end;
	Else -> 
	    slog:event(service_ko,?MODULE,select_home,{Else,S}),
	    {redirect,S,"#temporary"}					 
	
    end;

select_home(S,E) ->
    slog:event(internal,?MODULE,select_home_default_clause,E),
    {redirect,S,"#temporary"}.

check_etat(?CETAT_EP) -> true;
check_etat(?CETAT_AC) -> true;
check_etat(_) -> false.
