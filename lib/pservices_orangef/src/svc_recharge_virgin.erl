%%%%% Rechargement Virgin
-module(svc_recharge_virgin).

-export([process_code/2,select_rech/2]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").

-define(selfcare_mobi,"/orangef/selfcare_long/selfcare.xml").
-define(TCK_KEY_TYPE, "2").
-define(TTK_RECH_20E, 13).
-define(TTK_RECH_5E, 106).
-define(TTK_RECH_10E, 113).
-define(TTK_RECH_15E, 114).
-define(TTK_RECH_20E_virgin, 95).
-define(TTK_RECH_30E, 115).
-define(TTK_RECH_25E,142).
-define(TTK_RECH_40E, 116).
-define(TTK_RECH_50E, 97).
-define(TTK_RECH_WORLD1, 181).
-define(TTK_RECH_WORLD2, 182).
-define(CHOIX_VERYLONG,0).
-define(CHOIX_VERYVOIX,1).
-define(CHOIX_VERYSMS,2).
-define(CHOIX_VERYGOODTIME,3).
-define(CHOIX_VERYWORLD1,4).
-define(CHOIX_VERYWORLD2,5).


%%%% function checking the code format and validity

%%%% verify CG code and after do recharge
%% +type process_code(session(),string())-> erlpage_result().
process_code(abs, _) ->
    do_recharge(abs, abs) ++
	[ {"MENU SV", 
	   {redirect,abs,?selfcare_mobi++"#mainmenu"}},
	  {redirect, abs, "#bad_code_ph1"},
	  {redirect, abs, "#bad_code_ph2"}
	 ];
process_code(#session{service_code=SC,prof=#profile{subscription="mobi"}}=Session,"00") 
  when SC=="#124";SC=="#144";SC=="#147";SC=="#123"->
    {redirect, Session,?selfcare_mobi++"#mainmenu"};
process_code(#session{service_code=SC,prof=#profile{subscription="omer"}}=Session,"00") 
  when SC=="#124";SC=="#144";SC=="#147";SC=="#123"->
    {redirect, Session,"/orangef/selfcare_long/selfcare_omer.xml#mainmenu"};
process_code(#session{prof=#profile{subscription=Subscription}}=Session,CG)->
    case svc_util_of:is_valid(CG) of
	{nok, _} ->
	    case Session#session.bearer=={ussd,1} of
		true->{redirect, Session, "#bad_code_ph1"};
		false->{redirect, Session, "#bad_code_ph2"}
	    end;
	{ok, Code}  ->
	    State = svc_util_of:get_user_state(Session),
	    DCL = State#sdp_user_state.declinaison,
	    case DCL of
		114->
		    do_recharge2(Session,Code);
		_->
	    do_recharge(Session,Code)
	    end
    end.

do_recharge(#session{prof=Profile}=Session,Code)->
    Msisdn = Profile#profile.msisdn,
    Subs = Profile#profile.subscription,
    State =svc_util_of:get_user_state(Session),
    State2 =State#sdp_user_state{tmp_code=Code},
    Session2 = svc_util_of:update_user_state(Session,State2),
    case svc_recharge:send_consult_rech_request(Session2, {mobi,Msisdn}, ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    case svc_recharge:get_ttk(Session, c_tck, Answer_tck) of
		?TTK_RECH_5E ->
		    slog:event(trace, ?MODULE, ticket_rech_5E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new");
		?TTK_RECH_10E ->
		    slog:event(trace, ?MODULE, ticket_rech_10E),
		    {redirect,Session2,"#selection_tarif"};
		?TTK_RECH_15E ->
		    slog:event(trace, ?MODULE, ticket_rech_15E),
		    {redirect,Session2,"#selection_tarif"};
		?TTK_RECH_20E_virgin ->
		    slog:event(trace, ?MODULE, ticket_rech_20E),
		    {redirect,Session2,"#selection_tarif"};		
		?TTK_RECH_25E ->
                    slog:event(trace, ?MODULE, ticket_rech_25E),
                    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_rsi2");
		?TTK_RECH_30E ->
		    slog:event(trace, ?MODULE, ticket_rech_30E),
		    {redirect,Session2,"#selection_tarif"};
		?TTK_RECH_40E ->
		    slog:event(trace, ?MODULE, ticket_rech_40E),
		    {redirect,Session2,"#selection_tarif"};
		?TTK_RECH_WORLD1 ->
		    slog:event(trace, ?MODULE, ticket_rech_veryworld_europe),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYWORLD1,"#success_veryworld");
		?TTK_RECH_WORLD2 ->
		    slog:event(trace, ?MODULE, ticket_rech_veryworld_maghreb),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYWORLD2,"#success_veryworld");
		Else ->
		    slog:event(trace, ?MODULE, unexpected_rech_ticket_type,Else),
		    {redirect,Session2,"#system_failure"}
	    end;
	Else ->
	    slog:event(failure, ?MODULE, do_recharge_error, Else),
	    {redirect, Session, "#system_failure"}
    
    end.

do_recharge2(#session{prof=Profile}=Session,Code)->
    Msisdn = Profile#profile.msisdn,
    Subs = Profile#profile.subscription,
    State =svc_util_of:get_user_state(Session),
    State2 =State#sdp_user_state{tmp_code=Code},
    Session2 = svc_util_of:update_user_state(Session,State2),
    case svc_recharge:send_consult_rech_request(Session2, {mobi,Msisdn}, ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    case svc_recharge:get_ttk(Session2, c_tck, Answer_tck) of
		?TTK_RECH_5E ->
		    slog:event(trace, ?MODULE, ticket_rech_5E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_10E ->
		    slog:event(trace, ?MODULE, ticket_rech_10E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_15E ->
		    slog:event(trace, ?MODULE, ticket_rech_15E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_20E_virgin ->
		    slog:event(trace, ?MODULE, ticket_rech_20E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_25E ->
		    slog:event(trace, ?MODULE, ticket_rech_25E),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_rsi2");
		?TTK_RECH_30E ->
		    slog:event(trace, ?MODULE, ticket_rech_30E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_40E ->
		    slog:event(trace, ?MODULE, ticket_rech_40E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_50E ->
		    slog:event(trace, ?MODULE, ticket_rech_50E),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYLONG,"#sucess_cpte_new2");
		?TTK_RECH_WORLD1 ->
		    slog:event(trace, ?MODULE, ticket_rech_veryworld_europe),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYWORLD1,"#success_veryworld");
		?TTK_RECH_WORLD2 ->
		    slog:event(trace, ?MODULE, ticket_rech_veryworld_maghreb),
		    check_and_delete_very(Session),
		    send_d6(Session2,list_to_atom(Subs),Msisdn,Code,?CHOIX_VERYWORLD2,"#success_veryworld");
		Else ->
		    slog:event(trace, ?MODULE, unexpected_rech_ticket_type,Else),
		    {redirect,Session2,"#system_failure"}
            end;
	{'EXIT', Error} ->
	    slog:event(failure, ?MODULE, sdp_c_tck, Error),
	    {redirect, Session, "#system_failure"};
	Else ->
	    slog:event(failure, ?MODULE, sdp_c_tck, Else),
	    {redirect, Session, "#system_failure"}

    end.
%% select_rech(abs,Opt)->
%%     [{redirect,abs,"#menu_1_verysms"},{redirect,abs,"#menu_1_verysms"},
%%      {redirect,abs,"#menu_2_veryvoix"},{redirect,abs,"#menu_2_veryvoix"},
%%      {redirect,abs,"#menu_3_verylong"},{redirect,abs,"#menu_3_verylong"}];
select_rech(#session{prof=Prof}=S,Opt)->
    Subs=Prof#profile.subscription,
    Msisdn = Prof#profile.msisdn,
    select_rech(S,list_to_atom(Subs),Opt,Msisdn).

select_rech(S,Subs,Opt,Msisdn) when Subs==virgin_prepaid ->
    {US,State}=svc_options:check_topnumlist(S),
    Code= State#sdp_user_state.tmp_code,
    TOP_NUM_SMS = svc_options:top_num(verysms,Subs),
    TOP_NUM_VOIX = svc_options:top_num(veryvoix,Subs),
    TOP_NUM_GOODTIME = svc_options:top_num(very4,Subs),
    TOP_NUM_LONG = svc_options:top_num(verylong,Subs),
    Accounts=lists:foldl(fun(X, L) -> L ++ [svc_compte:etat_cpte(State,X)] end,
				      [],
				      [cpte_princ,cpte_opt_very,cpte_odr]),
    Choice = 
    case Opt of
	"verysms"-> 
                Etat = {lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_GOODTIME, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_LONG, State#sdp_user_state.topNumList)},
                check_and_delete_very(US,Subs,Etat,veryvoix,very4,verylong),
		?CHOIX_VERYSMS;
 	"veryvoix"->
                Etat = {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_GOODTIME, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_LONG, State#sdp_user_state.topNumList)},
		check_and_delete_very(US,Subs,Etat,verysms,very4,verylong),
		?CHOIX_VERYVOIX;
	"very4"->
                Etat = {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_LONG, State#sdp_user_state.topNumList)},
		check_and_delete_very(US,Subs,Etat,verysms,veryvoix,verylong),
		?CHOIX_VERYGOODTIME;
	    "verylong"->
                Etat = {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_GOODTIME, State#sdp_user_state.topNumList)},
		check_and_delete_very(US,Subs,Etat,verysms,veryvoix,very4),
		?CHOIX_VERYLONG;
	_ ->
                Etat = {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
                        lists:member(TOP_NUM_GOODTIME, State#sdp_user_state.topNumList)},
		check_and_delete_very(US,Subs,Etat,verysms,veryvoix,very4),
		?CHOIX_VERYLONG
    end,
    send_d6(US,Subs,Msisdn,Code,Choice,"#ep_ep_"++Opt).

send_d6(S,Subs,Msisdn,Code,Nopt,Url) ->    
    case svc_recharge:send_recharge_request(S, {Subs,Msisdn}, Code, 
                                            pbutil:unixtime(), Nopt) of
        {ok, Session_new, Infos} ->
            {redirect,Session_new, Url};
        Error ->
            slog:event(failure, ?MODULE, send_recharge_request, Error),
            {redirect,S,"#recharge_failure"}
    end.

check_and_delete_very(#session{prof=Profile}=Session) ->
    Subs = Profile#profile.subscription,
    {UpdatedSession,State} = svc_options:check_topnumlist(Session),
    TOP_NUM_SMS = svc_options:top_num(verysms,list_to_atom(Subs)),
    TOP_NUM_VOIX = svc_options:top_num(veryvoix,list_to_atom(Subs)),
    TOP_NUM_GOODTIME = svc_options:top_num(very4,list_to_atom(Subs)),
    TOP_NUM_LONG = svc_options:top_num(verylong,list_to_atom(Subs)),
    Etat = {lists:member(TOP_NUM_SMS, State#sdp_user_state.topNumList),
            lists:member(TOP_NUM_VOIX, State#sdp_user_state.topNumList),
            lists:member(TOP_NUM_GOODTIME, State#sdp_user_state.topNumList),
            lists:member(TOP_NUM_LONG, State#sdp_user_state.topNumList)},
    case Etat of 
	{true,true,true,true}->
	    %% supprime option verysms, veryvoix and very4, verylong
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{true,true,true,false}->
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate);
	{true,true,false,true}->
	    %% supprime option verysms and veryvoix, verylong
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{true,true,false,false}->
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate);
	{true,false,true,true}->
	    %% supprime option verysms and very4, verylong
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{true,false,true,false}->
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate);
	{false,true,true,true}->
	    %% supprime option veryvoix and verysms, verylong
            svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{false,true,true,true}->
            svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate);
	{false,false,true,true}->
	    %% supprime option very4 and verylong
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{false,false,true,false}->
            svc_options:do_opt_cpt_request(UpdatedSession,very4,terminate);
	{false,true,false,true}->
	    %% supprime option veryvoix and verylong
	    svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate),
	    svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{false,true,false,false}->
	    svc_options:do_opt_cpt_request(UpdatedSession,veryvoix,terminate);
	{true,false,false,true}->
            %% supprime option verysms and verylong
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate),
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	{true,false,false,false}->
            svc_options:do_opt_cpt_request(UpdatedSession,verysms,terminate);
	{false,false,false,true}->
            svc_options:do_opt_cpt_request(UpdatedSession,verylong,terminate);
	_ ->
	    % aucune suppresion
	    faire_rien
    end.

check_and_delete_very(Session,Subs,Etat,Opt1,Opt2,Opt3)
  when Subs==virgin_prepaid ->
    case Etat of
	{true,false,true} ->
	    svc_options:do_opt_cpt_request(Session,Opt1,terminate),
	    svc_options:do_opt_cpt_request(Session,Opt3,terminate);
	{true,false,false} ->
	    svc_options:do_opt_cpt_request(Session,Opt1,terminate);
	{false,true,false} ->
	    svc_options:do_opt_cpt_request(Session,Opt2,terminate);
	{false,false,true} ->
	    svc_options:do_opt_cpt_request(Session,Opt3,terminate);
	{false,true,true} ->
	    svc_options:do_opt_cpt_request(Session,Opt2,terminate),
	    svc_options:do_opt_cpt_request(Session,Opt3,terminate);
	{true,true,false} ->
	    svc_options:do_opt_cpt_request(Session,Opt1,terminate),
	    svc_options:do_opt_cpt_request(Session,Opt2,terminate);
	{true,true,true} ->
	    svc_options:do_opt_cpt_request(Session,Opt1,terminate),
	    svc_options:do_opt_cpt_request(Session,Opt2,terminate),
	    svc_options:do_opt_cpt_request(Session,Opt3,terminate);
	_ ->
	    faire_rien
    end.

