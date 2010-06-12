-module(svc_virgin).
-define(Limit1,"131").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

%% XML API
-export([select_home/1,
	 select_home_niv1/1,
	 select_home_niv3/1,
	 select_suivi_conso_plus/1,
	 do_subscription/3,
	 first_page/5,
	 print_if_act_opt/4,
	 print_tarif/1,
	 print_tarif_very/1,
	 print_dlv/1,
	 print_dlv_max/1,
	 print_dlv_max/2,
	 print_dlv_max2/1,
	 print_dlv_max2/2,
	 print_solde/2,
	 redirect_compte_bonus/2,
	 redirect_compte_data/1,
	 create_restitution_state/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_if_act_opt(session(),Option::string(),
%%                        PCD_URLs::string(),BR::string())-> 
%%                        hlink().
%%%% Propose link to option if:
%%%% 1 - option is commercially launched
%%%% 2 - option is active and no incompatible options are active, or
%%%% 3 - no options are active

print_if_act_opt(abs,_,PCD_URLs,BR) ->
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);

print_if_act_opt(Session,Option,PCD_URLs,BR)->
    Opt=list_to_atom(Option),
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    case svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    case is_subscr_possible(Session,Opt) of
		true -> 
		    [#hlink{href=URL,contents=[{pcdata,PCD}]}]
			++svc_util_of:add_br(BR);
		_ ->
		    []
	    end;
	_ -> []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home(session()) ->%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for all levels 1 and 2 (niveau 1 & 2) phones.

select_home(abs)->
     [
      {redirect,abs,"#ac_ac_oneoftwo_ok"},
      {redirect,abs,"#ac_ac_ep_ep"},
      {redirect,abs,"#ac_ep_oneoftwo_ok"},
      {redirect,abs,"#ac_ep_ep_ep"},
      {redirect,abs,"#ep_ac_ac_undefined"},
      {redirect,abs,"#ep_ac_ep_ac"},
      {redirect,abs,"#ep_ac_ep_ep"},
      {redirect,abs,"#ep_ep_ac_undefined"},
      {redirect,abs,"#ep_ep_ep_ac"},  
      {redirect,abs,"#ep_ep_ep_ep"}];

select_home(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home(S,list_to_atom(Subs)).

select_home(S,Subs) when Subs==virgin_prepaid ->
    NewState = create_restitution_state(S),
    NewSession =svc_util_of:update_user_state(S,NewState),
    CR_CO_state = 
 	case {svc_compte:etat_cpte(NewState,cpte_princ),svc_compte:etat_cpte(NewState,cpte_opt_very)} of 
 	    {?CETAT_AC,_} ->
 		?CETAT_AC;
 	    {_,?CETAT_AC} ->
		?CETAT_AC;
 	    {_,_} -> 
 		?CETAT_EP
 	end,
    Etat = {CR_CO_state,
            svc_compte:etat_cpte(NewState,cpte_odr),
	    svc_compte:etat_cpte(NewState,cpte_sms_ill),
	    svc_compte:etat_cpte(NewState,cpte_osi)},
    case Etat of 
	%% in the order of Scripts Referentiel Pp VM, Nov, 10.3
  	{?CETAT_AC, ?CETAT_AC, ?CETAT_AC, _} ->
 	    {redirect, NewSession,"#ac_ac_oneoftwo_ok"};
 	{?CETAT_AC, ?CETAT_AC, _, ?CETAT_AC} ->
 	    {redirect, NewSession,"#ac_ac_oneoftwo_ok"};

 	{?CETAT_AC, ?CETAT_AC, _, _} ->
            {redirect, NewSession,"#ac_ac_ep_ep"};

 	{?CETAT_AC, _, ?CETAT_AC, _} ->
            {redirect, NewSession,"#ac_ep_oneoftwo_ok"};
 	{?CETAT_AC, _, _, ?CETAT_AC} ->
            {redirect, NewSession,"#ac_ep_oneoftwo_ok"};

	{?CETAT_AC,_,_,_} ->
	    {redirect, NewSession,"#ac_ep_ep_ep"};
	{_,?CETAT_AC,?CETAT_AC,_} ->
            {redirect, NewSession,"#ep_ac_ac_undefined"};
	{_,?CETAT_AC,_,?CETAT_AC} ->
            {redirect, NewSession,"#ep_ac_ep_ac"};
	{_,?CETAT_AC,_,_} ->
            {redirect, NewSession,"#ep_ac_ep_ep"};
	{_,_,?CETAT_AC,_} ->
            {redirect, NewSession,"#ep_ep_ac_undefined"};
	{_,_,_,?CETAT_AC} ->
            {redirect, NewSession,"#ep_ep_ep_ac"};
	{_,_,_,_} ->	   
	    slog:event(trace, ?MODULE, home_page_epuise, {Etat, NewState}),   
            {redirect, NewSession,"#ep_ep_ep_ep"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type select_suivi_conso_plus(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.

select_suivi_conso_plus(abs)->
    [
      {redirect,abs,"#ac_ac_ac"},
      {redirect,abs,"#ac_ac_ep"},
      {redirect,abs,"#ac_ep_ac"},
      {redirect,abs,"#ep_ac_ac"},
      {redirect,abs,"#ac_ep_ep"},
      {redirect,abs,"#ep_ac_ep"},
      {redirect,abs,"#ep_ep_ac"},
      {redirect,abs,"#ep_ep_ep"}];

select_suivi_conso_plus(#session{prof=Prof}=S) ->
    Subs=Prof#profile.subscription,
    select_suivi_conso_plus(S,list_to_atom(Subs)).

select_suivi_conso_plus(S,Subs) when Subs==virgin_prepaid ->
    NewState = create_restitution_state(S),
    NewSession =svc_util_of:update_user_state(S,NewState),
    Etat = {svc_compte:etat_cpte(NewState,cpte_opt_virg),
	    svc_compte:etat_cpte(NewState,cpte_opt_voix_virgin),
	    svc_compte:etat_cpte(NewState,cpte_opt_sms_virgin)},

    case Etat of
	{?CETAT_AC,?CETAT_AC,?CETAT_AC}->
	    {redirect, NewSession,"#ac_ac_ac"};
	{?CETAT_AC,?CETAT_AC,_}->
	    {redirect, NewSession,"#ac_ac_ep"};
	{?CETAT_AC,_,?CETAT_AC}->
            {redirect, NewSession,"#ac_ep_ac"};
	{_,?CETAT_AC,?CETAT_AC}->
	    {redirect, NewSession,"#ep_ac_ac"};
	{?CETAT_AC,_,_}->
            {redirect, NewSession,"#ac_ep_ep"};
	{_,?CETAT_AC,_}->
            {redirect, NewSession,"#ep_ac_ep"};
	{_,_,?CETAT_AC}->
            {redirect, NewSession,"#ep_ep_ac"};
	_ ->
	    {redirect, NewSession,"#ep_ep_ep"}
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 1 and 2 (niveau 1 & 2) phones.

select_home_niv1(abs)->
    [{redirect,abs,"#ac_ac_ac_niv1"},{redirect,abs,"#ac_ac_ac_niv2"},
     {redirect,abs,"#ac_ac_ep_niv1"},{redirect,abs,"#ac_ac_ep_niv2"},
     {redirect,abs,"#ac_ep_ac_niv1"},{redirect,abs,"#ac_ep_ac_niv2"},
     {redirect,abs,"#ac_ep_ep_niv1"},{redirect,abs,"#ac_ep_ep_niv2"},
     {redirect,abs,"#ep_ac_ac_niv1"},{redirect,abs,"#ep_ac_ac_niv2"},
     {redirect,abs,"#ep_ac_ep_niv1"},{redirect,abs,"#ep_ac_ep_niv2"},
     {redirect,abs,"#ep_ep_ac_niv1"},{redirect,abs,"#ep_ep_ac_niv2"},
     {redirect,abs,"#ep_ep_ep_niv1"},{redirect,abs,"#ep_ep_ep_niv2"}] ++
        redirect_by_rsi_state(abs, "", "", "", "");

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
create_restitution_state(Session) ->
    {Session1,State}=svc_options:check_topnumlist(Session),
    Subs = svc_util_of:get_souscription(Session1),
    TOP_NUM_SMS = svc_options:top_num(verysms,Subs),
    TOP_NUM_VOIX = svc_options:top_num(veryvoix,Subs),
    TOP_NUM_GOOD = svc_options:top_num(very4,Subs),
    Compte_Princ = svc_compte:cpte(State,cpte_princ),
    Compte_Very = svc_compte:cpte(State,cpte_opt_very),
    State_accounts = {Compte_Very, Compte_Princ},
    case State_accounts of
	{undefined, undefined} ->
	    slog:event(failure, ?MODULE, create_restitution_state_NOK, State_accounts),
	    Solde = 0,
	    PTF = 0,
	    Compte_restitution = undefined;
	{no_cpte_found, undefined} ->
	    slog:event(failure, ?MODULE, create_restitution_state_NOK, State_accounts),
	    Solde = 0,
	    PTF = 0,
            Compte_restitution = undefined;
	{no_cpte_found, _} ->
	    Solde = Compte_Princ#compte.cpp_solde,
            PTF = Compte_Princ#compte.ptf_num,
            Compte_restitution = Compte_Princ;
	{_, undefined} ->
	    Solde = Compte_Very#compte.cpp_solde,
	    PTF = Compte_Very#compte.ptf_num,
	    Compte_restitution = Compte_Very;		
	{_,_} ->
	    Solde = currency:add(Compte_Princ#compte.cpp_solde,Compte_Very#compte.cpp_solde),
	    PTF = Compte_Princ#compte.ptf_num,
	    Compte_restitution = Compte_Princ
	    end,
		      
    {PTF_NUM_SMS,PTF_NUM_MIN} = case {
				  lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
				  lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
				  lists:member(TOP_NUM_GOOD, State#sdp_user_state.topNumList)} of
				    {false,false,false}->
					{216,216};
				    {false,true,false} ->
					{216,187};
				    {true,false,false} ->
					{187,216};
				    {false,false,true} ->
					{265,265};
				    _ ->
					{216,216}				
				end,

    create_restitution_state(State, Solde, Compte_restitution, [{cpte_restit_solde,PTF},{cpte_restit_sms,PTF_NUM_SMS},{cpte_restit_min,PTF_NUM_MIN},{cpte_restit, Compte_restitution}]).

create_restitution_state (State, _, undefined, _) ->
    slog:event(failure, ?MODULE, create_restitution_state_NOK, State),
    State;

create_restitution_state (State,Solde, Compte_Princ, [{Cpte_Name,PTF_NUM}|T]) ->
    Compte = Compte_Princ#compte{etat=?CETAT_AC,tcp_num=?C_OPT_VIRGIN_PP,cpp_solde=Solde,ptf_num=PTF_NUM},
    NewState = svc_compte:set_cpte_to_list(State, Cpte_Name, Compte),
    create_restitution_state(NewState, Solde, Compte_Princ, T);	    

create_restitution_state (State, Solde, Compte_restitution, [{cpte_restit, Compte_restitution}|T]) ->
    NewState = svc_compte:set_cpte_to_list(State, cpte_restit, Compte_restitution),
    create_restitution_state(NewState, Solde, Compte_restitution, T);

create_restitution_state (State, _, _, []) ->
    State.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDIRECTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts when
%%%% subscription is virgin_prepaid.

select_home_niv1(S,Subs) when Subs==virgin_prepaid ->
    NewState = create_restitution_state(S),
    NewSession =svc_util_of:update_user_state(S,NewState),
    RSI_state =  svc_compte:etat_cpte(NewState,cpte_sms_ill),
    case {svc_compte:etat_cpte(NewState,cpte_princ),
 	  svc_compte:etat_cpte(NewState,cpte_opt_virg),
	  svc_compte:etat_cpte(NewState,cpte_odr),
	  svc_compte:etat_cpte(NewState,cpte_opt_very)} of
 
 	{?CETAT_AC,?CETAT_AC,?CETAT_AC,?CETAT_AC} ->
 	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ac_ac_ac_niv1","#ac_ac_ac_ac_niv2");

	{?CETAT_AC,?CETAT_AC,?CETAT_AC,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ac_ac_ep_niv1","#ac_ac_ac_ep_niv2");

	{?CETAT_AC,?CETAT_AC,_,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ac_ep_ac_niv1","#ac_ac_ep_ac_niv2");

	{?CETAT_AC,?CETAT_AC,_,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ac_ep_ep_niv1","#ac_ac_ep_ep_niv2");

	{?CETAT_AC,_,?CETAT_AC,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ep_ac_ac_niv1","#ac_ep_ac_ac_niv2");

	{?CETAT_AC,_,?CETAT_AC,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ep_ac_ep_niv1","#ac_ep_ac_ep_niv2");

	{?CETAT_AC,_,_,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ep_ep_ac_niv1","#ac_ep_ep_ac_niv2");

	{?CETAT_AC,_,_,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ac_ep_ep_ep_niv1","#ac_ep_ep_ep_niv2");

	{_,?CETAT_AC,?CETAT_AC,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ac_ac_ac_niv1","#ep_ac_ac_ac_niv2");

	{_,?CETAT_AC,?CETAT_AC,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ac_ac_ep_niv1","#ep_ac_ac_ep_niv2");

	{_,?CETAT_AC,_,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ac_ep_ac_niv1","#ep_ac_ep_ac_niv2");

	{_,?CETAT_AC,?CETAT_EP,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ac_ep_ep_niv1","#ep_ac_ep_ep_niv2");

	{_,_,?CETAT_AC,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ep_ac_ac_niv1","#ep_ep_ac_ac_niv2");

	{_,_,?CETAT_AC,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ep_ac_ep_niv1","#ep_ep_ac_ep_niv2");

	{_,_,_,?CETAT_AC} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ep_ep_ac_niv1","#ep_ep_ep_ac_niv2");

	{_,_,_,_} ->
	    redirect_by_rsi_state(NewSession,?Limit1, RSI_state,
                                  "#ep_ep_ep_ep_niv1","#ep_ep_ep_ep_niv2");
	_ ->
	    undefined

    end.


%% +type redirect_by_rsi_state(session(), ,Subs::atom(), integer(), string(),
%%                             string()) ->  erlpage_result().
%%% Redirect according to RSI (Recharge SMS Illimites) account state

redirect_by_rsi_state(abs, _, _, _, _) ->
    [{redirect, abs,"#ac_ac_ac_rsi_niv1"},{redirect, abs,"#ac_ac_ac_rsi_niv2"},
     {redirect, abs,"#ac_ac_ep_rsi_niv1"},{redirect, abs,"#ac_ac_ep_rsi_niv2"},
     {redirect, abs,"#ac_ep_ac_rsi_niv1"},{redirect, abs,"#ac_ep_ac_rsi_niv2"},
     {redirect, abs,"#ac_ep_ep_rsi_niv1"},{redirect, abs,"#ac_ep_ep_rsi_niv2"},
     {redirect, abs,"#ep_ac_ac_rsi_niv1"},{redirect, abs,"#ep_ac_ac_rsi_niv2"},
     {redirect, abs,"#ep_ep_ac_rsi_niv1"},{redirect, abs,"#ep_ep_ac_rsi_niv2"}];

redirect_by_rsi_state(Session, Limit, ?CETAT_AC, Url_niv1, Url_niv2) ->
    case {Url_niv1, Url_niv2} of
        {"#ac_ac_ac_ac_niv1","#ac_ac_ac_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ac_ac_rsi_niv1", "#ac_ac_ac_rsi_niv2");
        {"#ac_ac_ac_ep_niv1","#ac_ac_ac_ep_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ac_ac_rsi_niv1", "#ac_ac_ac_rsi_niv2");
        {"#ac_ac_ep_ac_niv1","#ac_ac_ep_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ac_ep_rsi_niv1", "#ac_ac_ep_rsi_niv2");
        {"#ac_ac_ep_ep_niv1","#ac_ac_ep_ep_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ac_ep_rsi_niv1", "#ac_ac_ep_rsi_niv2"); 
        {"#ac_ep_ac_ac_niv1","#ac_ep_ac_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ep_ac_rsi_niv1", "#ac_ep_ac_rsi_niv2");
        {"#ac_ep_ac_ep_niv1","#ac_ep_ac_ep_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ep_ac_rsi_niv1", "#ac_ep_ac_rsi_niv2");  
        {"#ac_ep_ep_ac_niv1","#ac_ep_ep_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ep_ep_rsi_niv1", "#ac_ep_ep_rsi_niv2");
        {"#ac_ep_ep_ep_niv1","#ac_ep_ep_ep_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ep_ep_rsi_niv1", "#ac_ep_ep_rsi_niv2"); 
        {"#ep_ac_ac_ac_niv1","#ep_ac_ac_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ac_ac_rsi_niv1", "#ac_ac_ac_rsi_niv2");
        {"#ep_ac_ac_ep_niv1","#ep_ac_ac_ep_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ep_ac_ac_rsi_niv1", "#ep_ac_ac_rsi_niv2"); 
        {"#ep_ep_ac_ac_niv1","#ep_ep_ac_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ep_ac_rsi_niv1", "#ac_ep_ac_rsi_niv2");
        {"#ep_ep_ac_ep_niv1","#ep_ep_ac_ep_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ep_ep_ac_rsi_niv1", "#ep_ep_ac_rsi_niv2");
        {"#ep_ep_ep_ac_niv1","#ep_ep_ep_ac_niv2"} ->
            redirect_by_rsi_state(Session, Limit, "",
                                  "#ac_ep_ep_rsi_niv1", "#ac_ep_ep_rsi_niv2"); 
        _ -> 
            redirect_by_rsi_state(Session, Limit, "", Url_niv1, Url_niv2)
    end;
        
redirect_by_rsi_state(Session, Limit, _, Url_niv1, Url_niv2) ->
    svc_util:redirect_size(Session, Limit, Url_niv1, Url_niv2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the account when
%%%% subscription is virgin_prepaid.

select_home_niv3(S,Subs)when Subs==virgin_prepaid->
    State = svc_util_of:get_user_state(S),
    case svc_compte:etat_cpte(State,cpte_princ) of
	?CETAT_AC->
	    {redirect, S, "#act_niv3"};
	_->
	    {redirect, S, "#ep_niv3"}   
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_subscr_possible(session(),Opt::atom())-> 
%%                          bool().
%%%% Subscription to the option is possible if option active and
%%%% no incompatible options are active, or if no options are active.
%%%% Returns true if subscription is possible, otherwise false.

is_subscr_possible(Session,Opt) ->
    {Session_new,State}=svc_options:check_topnumlist(Session),
    case svc_compte:cpte(State,svc_options:opt_to_godet(Opt,virgin_prepaid)) of
	#compte{} ->
	    case State#sdp_user_state.topNumList of
		undefined -> true;
		"" -> true;
		[0] -> true;
		_ ->
		    case is_option_incomp(Session_new,Opt) and
			(svc_compte:etat_cpte(State,Opt)==?CETAT_AC) of
			true -> false;
			_ -> true
		    end
	    end;
	_ -> true
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUBSCRIPTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription_request(session(),Opt::string(),URLs::string())->
%%                               erlpage_result().
%%%% Subscribe to options via opt_cpt_request.

do_subscription_request(Session,Opt,URLs)->
    [Uok,UdejaAct,Uinsuff,Unok] = string:tokens(URLs, ","),
    {Session1,Result} = svc_options:do_opt_cpt_request(Session,Opt,subscribe),
    svc_options:redirect_update_option(Session1, Result, Uok, UdejaAct, 
                                       Uinsuff, Unok, Unok).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_incomp(sdp_user_state(),Opt::string())->
%%                        bool().
%%%% Check incompatibilities between options.

is_option_incomp(Session,opt1_virg_30j)->
    svc_options:is_option_activated(Session,opt2_virg_30j)
	or svc_options:is_option_activated(Session,opt3_virg_30j)
	or svc_options:is_option_activated(Session,opt4_virg_30j);
is_option_incomp(Session,opt2_virg_30j) ->
    svc_options:is_option_activated(Session,opt1_virg_30j)
	or svc_options:is_option_activated(Session,opt3_virg_30j)
	or svc_options:is_option_activated(Session,opt4_virg_30j);
is_option_incomp(Session,opt3_virg_30j)->
    svc_options:is_option_activated(Session,opt1_virg_30j)
	or svc_options:is_option_activated(Session,opt2_virg_30j)
	or svc_options:is_option_activated(Session,opt4_virg_30j);
is_option_incomp(Session,opt4_virg_30j) ->
    svc_options:is_option_activated(Session,opt1_virg_30j)
	or svc_options:is_option_activated(Session,opt2_virg_30j)
	or svc_options:is_option_activated(Session,opt3_virg_30j);
is_option_incomp(_, _) ->
    false.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_tarif_very(abs) ->
    [{pcdata, "VeryLong"},
     {pcdata, "VeryVoix"},
     {pcdata, "VerySMS"},
     {pcdata, "VeryGood"},
     {pcdata, "VeryWorld"}
    ];

print_tarif_very(#session{prof=Prof}=S) ->
    Subs =Prof#profile.subscription,
    print_tarif_very(S,list_to_atom(Subs)).

print_tarif_very(S,Subs) when Subs==virgin_prepaid  ->
    NewState = create_restitution_state(S), 
    NewSession =svc_util_of:update_user_state(S,NewState), 
    {NewSession1,State}=svc_options:check_topnumlist(NewSession),
    TOP_NUM_SMS = svc_options:top_num(verysms,Subs),
    TOP_NUM_VOIX = svc_options:top_num(veryvoix,Subs),
    TOP_NUM_GOOD = svc_options:top_num(very4,Subs),
    TOP_NUM_WORLD1 = svc_option_manager:get_top_num(veryworld_europe,Subs),
    TOP_NUM_WORLD2 = svc_option_manager:get_top_num(veryworld_maghreb,Subs),
    Etat = {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
	    lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
	    lists:member(TOP_NUM_GOOD, State#sdp_user_state.topNumList),
	    lists:member(TOP_NUM_WORLD1, State#sdp_user_state.topNumList),
	    lists:member(TOP_NUM_WORLD2, State#sdp_user_state.topNumList)
	   },
    case Etat of
	{false,false,false,false,false}->
	    [{pcdata,"VeryLong"}];
	E when E=={false,false,false,true,false};
	       E=={false,false,false,false,true} ->
	    [{pcdata,"VeryWorld"}];
	{false,false,true,false,false}->
	    [{pcdata, "VeryGood"}];
	{false,true,false,false,false} ->
	    [{pcdata, "VeryVoix"}];
	{true,false,false,false,false} ->
	    [{pcdata, "VerySMS"}];
	_ ->
	    [{pcdata, "VeryLong"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_tarif(session())->
%%                        tuple().
%%%% Retrieves the Very|Long option
%%%%                   |SMS
%%%%                   |Voix

print_tarif(abs) ->
    [{pcdata, "VeryLong"},
     {pcdata, "VeryVoix"},
     {pcdata, "VerySMS"},
     {pcdata, "VeryGood"}
    ];

print_tarif(Session) ->
    {Session1,State}=svc_options:check_topnumlist(Session),
    Subs = virgin_prepaid,
    TOP_NUM_SMS = svc_options:top_num(verysms,Subs),
    TOP_NUM_VOIX = svc_options:top_num(veryvoix,Subs),
    %%case {svc_options:is_option_activated(Session, verysms),svc_options:is_option_activated(Session, veryvoix)} of
    case {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList)} of
	{false,false} ->
	    [{pcdata, "VeryLong"}];
	{false,true} ->
	    [{pcdata, "VeryVoix"}];
	{true,false} ->
	    [{pcdata, "VerySMS"}];
	_ ->
	    [{pcdata, "VeryLong"}]
    end.

print_dlv_max(abs)->
    [{pcdata,"JJ/MM/AAAA"}];

print_dlv_max(#session{prof=#profile{msisdn=MSISDN}}=Session) ->
    print_dlv_max(Session,"dmy").

print_dlv_max(abs,_)->
    [{pcdata,"JJ/MM"}];

print_dlv_max(#session{prof=#profile{msisdn=MSISDN}}=Session,Format) ->
    NewState = create_restitution_state(Session),
    NewSession =svc_util_of:update_user_state(Session,NewState),
    Etat = {svc_compte:etat_cpte(NewState,cpte_sms_ill),
            svc_compte:etat_cpte(NewState,cpte_osi)},    
    case Etat of 
        {?CETAT_AC,?CETAT_AC} ->
	    [{_,DLV_RSI}] = svc_compte:print_fin_credit_default(NewSession,"cpte_sms_ill",Format),
	    [{_,DLV_OSI}] = svc_compte:print_fin_credit_default(NewSession,"cpte_osi",Format),
	    case max_dlv(DLV_RSI,DLV_OSI) of 
		DLV_RSI ->
		    svc_compte:print_fin_credit_default(NewSession,"cpte_sms_ill",Format);
		_ ->
		    svc_compte:print_fin_credit_default(NewSession,"cpte_osi",Format)
	    end;
	{?CETAT_AC,_} ->	    
            svc_compte:print_fin_credit_default(NewSession,"cpte_sms_ill",Format);
	{_,?CETAT_AC} ->
	    svc_compte:print_fin_credit_default(NewSession,"cpte_osi",Format);
        _ ->
            svc_compte:print_fin_credit_default(NewSession,"cpte_princ",Format)
    end.

print_dlv_max2(abs)->
    [{pcdata,"JJ/MM/AAAA"}];

print_dlv_max2(#session{prof=#profile{msisdn=MSISDN}}=Session) ->    
    print_dlv_max(Session,"dmy").

print_dlv_max2(abs,_)->
    [{pcdata,"JJ/MM"}];

print_dlv_max2(#session{prof=#profile{msisdn=MSISDN}}=Session,Format) ->
    NewState = create_restitution_state(Session),
    NewSession =svc_util_of:update_user_state(Session,NewState),
    Etat = {svc_compte:etat_cpte(NewState,cpte_opt_voix_virgin),
            svc_compte:etat_cpte(NewState,cpte_opt_sms_virgin)},
    case Etat of
        {?CETAT_AC,?CETAT_AC} ->
            [{_,DLV_MN}] = svc_compte:print_fin_credit_default(NewSession,"cpte_opt_voix_virgin",Format),
            [{_,DLV_SMS}] = svc_compte:print_fin_credit_default(NewSession,"cpte_opt_sms_virgin",Format),
            case max_dlv(DLV_MN,DLV_SMS) of
                DLV_MN ->
                    svc_compte:print_fin_credit_default(NewSession,"cpte_opt_voix_virgin",Format);
                _ ->
                    svc_compte:print_fin_credit_default(NewSession,"cpte_opt_sms_virgin",Format)
            end;
        {?CETAT_AC,_} ->
            svc_compte:print_fin_credit_default(NewSession,"cpte_opt_voix_virgin",Format);
        {_,?CETAT_AC} ->
            svc_compte:print_fin_credit_default(NewSession,"cpte_opt_sms_virgin",Format);
        _ ->
            svc_compte:print_fin_credit_default(NewSession,"cpte_opt_voix_virgin",Format)
    end.

print_dlv(abs)->
    [{pcdata,"JJ/MM/AAAA"}];

print_dlv(#session{prof=#profile{msisdn=MSISDN}}=Session)->
    {Session1,State}=svc_options:check_topnumlist(Session),
    Subs = svc_util_of:get_souscription(Session1),
    TOP_NUM_SMS = svc_options:top_num(verysms,Subs),
    TOP_NUM_VOIX = svc_options:top_num(veryvoix,Subs),
    
    
    case {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList)} of
	{false,false} ->
	    svc_compte:print_fin_credit_default(Session1,"cpte_princ","dmy");
	{false,true} ->
	    print_end_opt(Session1, {Subs,MSISDN},TOP_NUM_VOIX);
	{true,false} ->
	    print_end_opt(Session1, {Subs,MSISDN},TOP_NUM_SMS);
	_ ->
	    svc_compte:print_fin_credit_default(Session1,"cpte_princ","dmy")
    end.

print_end_opt(Session, SVIKey,TOP_NUM)->
    case svc_util_of:consult_account_options(Session, SVIKey, TOP_NUM) of
	{ok,[_,_,Date_End,_,_]}->
	    DateTime = calendar:now_to_local_time({Date_End div 1000000, 
						   Date_End rem 1000000,0}),
	    Date = svc_util_of:sprintf_datetime_by_format(DateTime,"dmy"),
	    [{pcdata, Date}];
        {nok, Reason} ->
            slog:event(failure, ?MODULE, print_end_opt, {nok, Reason}),

            [{pcdata, []}];
	Error ->
            slog:event(failure,?MODULE, print_end_opt, Error),
	    [{pcdata, []}]
    end.

max_dlv(Date1,Date2)->
    D1 = convert_date(string:tokens(Date1,"/")),
    D2 = convert_date(string:tokens(Date2,"/")),
    case list_to_tuple(D1) > list_to_tuple(D2) of
	true ->
	    Date1;
	_ ->
	    Date2
    end.

convert_date(Date)->
    convert_date(Date,[]).

convert_date([H|T],Date) ->             
     Element = list_to_integer(H),
     convert_date(T,[Element|Date]);
convert_date([],Date)->
     Date.

print_solde(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->    
    State=create_restitution_state(Session),
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
        #compte{}=Compte ->	    
            slog:event(trace,?MODULE,cpte,{?LINE,Compte}),
	    [{pcdata,svc_compte:print_cpte(Compte)}];
	undefined ->
            slog:event(internal,?MODULE,undefined_print_solde,Cpte),
	    [{pcdata,"inconnu"}];
        _ ->
            slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
            [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_compte_bonus(session()) ->%%                        erlpage_result().
%%%% Redirect according to the state of the bonus accounts (Voice account and SMS account).

redirect_compte_bonus(abs,Case)->
    [
     {redirect,abs,"#ac_ac_case1"},
     {redirect,abs,"#ac_ep_case1"},
     {redirect,abs,"#ep_ac_case1"}
    ];

redirect_compte_bonus(#session{prof=Prof}=S, Case) 
  when Case == "case1"->    
    State = svc_util_of:get_user_state(S),
    Cpte_voix = svc_compte:etat_cpte(State,cpte_opt_voix_virgin),
    Cpte_sms = svc_compte:etat_cpte(State,cpte_opt_sms_virgin),				     
    case {Cpte_voix,Cpte_sms} of
	{?CETAT_AC,?CETAT_AC} ->
	    {redirect,S,"#ac_ac_case1"};
	{?CETAT_AC,_} ->
	    {redirect,S,"#ac_ep_case1"};
	{_,?CETAT_AC} ->
	    {redirect,S,"#ep_ac_case1"};
	_ ->
	    []
    end;

redirect_compte_bonus(#session{prof=Prof}=S, Case) 
  when Case == "case2"->    
    State = svc_util_of:get_user_state(S),
    Cpte_voix = svc_compte:etat_cpte(State,cpte_opt_voix_virgin),
    Cpte_sms = svc_compte:etat_cpte(State,cpte_opt_sms_virgin),				     
    case {Cpte_voix,Cpte_sms} of
	{?CETAT_AC,?CETAT_AC} ->
	    {redirect,S,"#ac_ac_case2"};
	{?CETAT_AC,_} ->
	    {redirect,S,"#ac_ep_case2"};
	{_,?CETAT_AC} ->
	    {redirect,S,"#ep_ac_case2"};
	_ ->
	    {redirect,S,"#ep_ep_case2"}
    end.

redirect_compte_data(abs)->
    [
     {redirect,abs,"#credit_data"}
    ];

redirect_compte_data(#session{prof=Prof}=S) ->
    State = svc_util_of:get_user_state(S),
    case svc_compte:etat_cpte(State,cpte_data_virgin) of
	?CETAT_AC ->
	    {redirect,S,"#credit_data"};
	_ ->
	    []
    end.
