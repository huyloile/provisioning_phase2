-module(svc_plan_tarif_free).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").

-export([print_link_first_menu/3, souscrire/3]).
-export([link_if_allowed/3]).

%% +type print_link_first_menu(session(),string(),URL::string())-> hlink().
print_link_first_menu(abs, Name_Plan, URL) ->
    [#hlink{href=URL, contents=[{pcdata,Name_Plan},br]}];
print_link_first_menu(Session, "zap_promo", URL) ->
    State = svc_util_of:get_user_state(Session),
    Ptf = svc_compte:ptf_num(State,cpte_princ),
    case (svc_util_of:is_commercially_launched(Session,plan_zap) and
	  (svc_compte:ptf_num(State,cpte_princ) == ?MOBI_ZAP)) of
	true->
	    case lists:keysearch(zap_promo, 1, ?PT_POSSIBLE_LINKS) of
		{value, {_, PtfLink, TextLink}} -> 
		    case Ptf == PtfLink of
			true ->
			    [];
			false ->
			    [#hlink{href=URL, contents=[{pcdata,TextLink}]}]
		    end;
		_->
		    []
	    end;
	false->
	    []
    end;

print_link_first_menu(Session, "class_sec_v2", URL) ->
    case svc_util_of:is_commercially_launched(Session,class_sec_v2) of
	true->
	    State = svc_util_of:get_user_state(Session),
	    Ptf = svc_compte:ptf_num(State,cpte_princ),
	    case lists:keysearch(class_sec_v2, 1, ?PT_POSSIBLE_LINKS) of
		{value, {_, PtfLink, TextLink}} -> 
		    case Ptf == PtfLink of
			true ->
			    [];
			false ->
			    [#hlink{href=URL, contents=[{pcdata,TextLink}]}]
		    end;
		false -> []
	    end;
	_ ->
	    []
    end;

print_link_first_menu(Session, ToWhichPlan, URL) ->
    State = svc_util_of:get_user_state(Session),
    Ptf = svc_compte:ptf_num(State,cpte_princ),
    case lists:keysearch(list_to_atom(ToWhichPlan), 1, ?PT_POSSIBLE_LINKS) of
	{value, {_, PtfLink, TextLink}} -> 
	    case Ptf == PtfLink of
		true ->
		    [];
		false ->
		    [#hlink{href=URL, contents=[{pcdata,TextLink}]}]
	    end;
	false -> []
    end.

%% +type souscrire(session(),string(),Url::string())-> erlpage_result().
souscrire(abs, _, Url) ->
     [{redirect, abs, Url},
      {redirect, abs, "#not_enough_credit_pt"},
      {redirect, abs, "#mobirecharge_change_pt"},
      {redirect, abs, "#change_pt_error"}
     ];
souscrire(#session{prof=Profile} = Session, To_PtStr, Url) ->
   
    State = svc_util_of:get_user_state(Session),
    Msisdn = Profile#profile.msisdn,
    NewPTatom = list_to_atom(To_PtStr),
    {value, {_, NewPT, _}} = lists:keysearch(NewPTatom, 1, ?PT_POSSIBLE_LINKS),
    PTChangePrice = currency:sum(euro,0),
    Time = pbutil:unixtime(),
    Compte = #compte{ptf_num=NewPT, pct=PTChangePrice, d_crea=Time,
                     tcp_num=?C_PRINC,  ctrl_sec=0},
    Answer = svc_util_of:change_user_account(Session, {mobi, Msisdn},
                                             Compte),
    case Answer of
        {ok, _} ->
            prisme_dump:prisme_count(Session,NewPTatom),
            Compte_P=svc_compte:cpte(State,cpte_princ),
            Compte_P2=Compte_P#compte{ptf_num=NewPT},
            NewSession = svc_util_of:update_state(Session,[{cpte_princ,Compte_P2}]),
            {redirect,NewSession,Url};
        {nok, "solde_insuffisant"} ->
            slog:event(service_ko, ?MODULE, solde_insuffisant, Msisdn),
            {redirect, Session, "#not_enough_credit_pt"};
        {nok, "chg_etat_cpte_impossible"} ->
            slog:event(service_ko, ?MODULE, chg_etat_cpte_impossible, Msisdn),
            {redirect, Session, "#mobirecharge_change_pt"};
        {nok, Reason} ->
            slog:event(failure, ?MODULE, change_user_account_failure, {Reason,Msisdn}),
            {redirect, Session, "#change_pt_error"};
        E ->
            slog:event(failure, ?MODULE, bad_response_from_sachem, {Msisdn,E}),
            {redirect, Session, "#change_pt_error"}
    end.

%% +type link_if_allowed(session(),string(),string())-> hlink().
link_if_allowed(abs,TextLink,Url)->
    [#hlink{href=Url, contents=[{pcdata,TextLink}]}];
link_if_allowed(Session, TextLink, Url) ->
    case ptf24_or_flag64(Session) of
	true -> [];
	false -> [#hlink{href=Url, contents=[{pcdata,TextLink}]}]
    end.

ptf24_or_flag64(Session) ->
    {Session_new,State} = svc_options:check_topnumlist(Session),
    PtfNum=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    (PtfNum==24) 
	or svc_options:is_option_activated(Session_new,opt_appelprixunique).

