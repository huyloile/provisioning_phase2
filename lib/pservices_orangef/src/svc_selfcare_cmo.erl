%%%% Self care page generator.

-module(svc_selfcare_cmo).

-export([check_state/2, start/2, start_light/2,select_home/1,
         select_home_niv3/1]).
-export([msisdn/1]).
-export([next_promo/1,print_first_link_promo/3,print_next_link_promo/1]).
-export([next_options/1,print_first_link_options/3,print_next_link_options/1]).
-export([bonus/1,promo_infini/1,menu/2]).
-export([redirect_opt/2,redirect_date/4,redirect_credit/4,redirect_credit/6]).
-export([redirect_dcl_cmo/6]).
-export([include_sv_130/1]).

-export([lienSiPromo/4]).
-export([proposer_lien/5,activ_plan_zap/3]).
-import(svc_util_of, [dec_pcd_urls/1]).

%% Export for online tests
-export([do_activ_plan_zap/3]).


-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

%% +deftype url() = string().

%% +type start(session(),url())-> erlpage_result().
start(abs,URL) ->
    continue_selfcare(abs,URL) ++
	[ {redirect,abs,"#notcmo"},
	  {redirect, abs, "#temporary"} ];
start(#session{prof=#profile{subscription=S}}=Session,URL)
  when S=/="cmo" ->
    slog:event(trace, ?MODULE, not_cmo),
    {redirect, Session, "#notcmo"};
start(#session{prof=Profile}=Session,URL) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    pbutil:autograph_label(dump_billing_ok),
	    continue_selfcare(Session1,URL);
	{stop, Session1, Reason} ->
	    pbutil:autograph_label(dump_billing_stop),
	    {redirect, Session1, "#temporary"}
    end.

%% +type continue_selfcare(session(),url())-> erlpage_result().
continue_selfcare(abs,URL) ->
    filter(abs, abs,URL) ++
	[{failure, {redirect,abs,"#temporary"}}];
continue_selfcare(#session{prof=Profile}=Session,URL) ->
    case provisioning_ftm:reset_sdp_state(Session) of
	{ok,Session_,State}  ->
	    slog:event(count, ?MODULE, read_state_ok, State),
	    NewSession= svc_util_of:update_user_state(Session_,State),
	    filter(NewSession, State,URL);
	Error ->
	    slog:event(count, ?MODULE, read_state_error, Error),
	    {redirect, Session, "#temporary"}
    end.

%% +type filter(session(),sdp_user_state(),url())-> erlpage_result().
filter(abs,_,URL)->
      svc_home:filter_pathological_cmo(abs,abs) ++
	[{redirect,abs,URL}];
filter(#session{}=Session,State,URL) ->
    case catch svc_home:filter_pathological_cmo(Session,State) of
	{continue, Session1} ->
	    {redirect,Session1, URL};
	{redirect, Session1, FilterURL}=Redirect ->
	    Redirect;
	{redirect, Session1, FilterURL, Subst}=Redirect ->
	    Redirect
    end.

%% +type check_state(session(),url())-> erlpage_result().
check_state(abs,URL) ->
    start(abs,URL);
check_state(Session0,URL)->
    {_, Session} = svc_util_of:reinit_prepaid(Session0),
    %% record incorrect or AssocList-> init
    case svc_util_of:get_user_state(Session) of
	#sdp_user_state{}=State->
	    case State#sdp_user_state.topNumList of
		undefined ->
		    Session1 = svc_util_of:update_user_state(Session,State),
		    case svc_options:activ_options(Session1) of
			{Session2,Activ_opts} ->
                            State1=svc_util_of:get_user_state(Session2),
			    US = State1#sdp_user_state{topNumList=Activ_opts}, %%TopNumList
			    Session3 = svc_util_of:update_user_state(Session2,US),
			    filter(Session3,US,URL);
			Error ->
			    {redirect, Session, "#menu_indisp"}
		    end;
		_ ->
		    Session3 = svc_util_of:update_user_state(Session,State),
		    filter(Session3,State,URL)
	    end;
	_ -> start(Session,URL)
    end.

%% +type start_light(session(),url())-> erlpage_result().
start_light(abs,URL)->
    [{redirect,abs,URL}]++start(abs,URL);
start_light(Session,URL)->
    case svc_util_of:get_user_state(Session) of
	#sdp_user_state{}=US -> {redirect, Session, URL};
	_ -> 
	    %% record incorrect -> init
	    start(Session,URL)
    end.

%% +type select_home(session())-> erlpage_result().
select_home(abs) ->
    [ {redirect, abs, "#olan"},
      {redirect, abs, "#olan_epuise"},
      
      {redirect, abs, "#olax"},
      {redirect, abs, "#olax_forfait"},
      {redirect, abs, "#olax_cpte"},
      {redirect, abs, "#olax_epuise"},
 
      {redirect,abs,"#ola2_voix"},
      {redirect,abs,"#ola2_wap"},

      {redirect,abs,"#zap_ac"},
      {redirect,abs,"#zap_ep"},  

      {redirect, abs, "#olac"},
      {redirect, abs, "#olac_ep"},

      {redirect, abs, "#pmu_sv"},
 
      {redirect, abs, "#fmu"},
      {redirect, abs, "#fmu_ep"},
      {redirect, abs, "#m6_ac"},
      {redirect, abs, "#m6_ep"},
      {redirect, abs, "#m6_mobile_ac"},
      {redirect, abs, "#m6_mobile_ep"},

      {failure, {redirect, abs, "#temporary"}}
     ];
select_home(#session{}=Session)->
    State=svc_util_of:get_user_state(Session),
    select_home(Session,State).
%% +type select_home(session(),sdp_user_state())-> erlpage_result().
%%%% OLAN
select_home(Session,#sdp_user_state{declinaison=?ppola}=State)
  when (State#sdp_user_state.cpte_princ)#compte.etat == ?CETAT_EP->
    {redirect, Session, "#olan_epuise"};
select_home(Session,#sdp_user_state{declinaison=?ppola}=State)
  when (State#sdp_user_state.cpte_princ)#compte.etat == ?CETAT_PE->
    {redirect, Session, "#olan_epuise"};
select_home(Session,#sdp_user_state{declinaison=?ppola}=State)->
    {redirect,Session,"#olan"};
%%%% OLAX
select_home(S, #sdp_user_state{declinaison=D}=State) when D==?ppol1;
							  D==?ppol3->
    case {svc_compte:etat_cpte(State,cpte_princ),
	  svc_compte:etat_cpte(State,cpte_forf)} of
	%%%% before 03/11/02 no cpte SMS exist
	{?CETAT_AC,?CETAT_AC}->
	    {redirect, S, "#olax"};
	{?CETAT_AC,?CETAT_EP}->
	    {redirect, S, "#olax_cpte"};
	{?CETAT_AC,?CETAT_PE}->
	    {redirect, S, "#olax_cpte"}; 
	{?CETAT_EP,?CETAT_AC}->
	    {redirect, S, "#olax_forfait"};
	{?CETAT_EP,?CETAT_EP}->
	    {redirect, S, "#olax_epuise"};
	{?CETAT_EP,?CETAT_PE}->
	    {redirect, S, "#olax_epuise"};
	{?CETAT_PE,?CETAT_PE}->
            {redirect, S, "#olax_epuise"};
	{?CETAT_PE,?CETAT_EP}->
            {redirect, S, "#olax_epuise"};
	{?CETAT_PE,?CETAT_AC}->
            {redirect, S, "#olax_forfait"};
	{E,F}->
	  slog:event(warning, ?MODULE, olax_unexpected_cpte_state, 
		     {State,E,F}),	  {redirect, S, "#temporary"}
  end;
%% Capri
%%%% OLA2
select_home(S, #sdp_user_state{declinaison=?ppol2}=State)->
    case
	{svc_compte:cpte(State,forf_wap234),
	 svc_compte:cpte(State,forf_sms),
	 svc_compte:etat_cpte(State,cpte_voix)} of
	{#compte{cpp_solde={sum,euro,X}},_,_} when X>0->
	    %%CAS D
	    {redirect, S, "#ola2_wap"};
	{_,#compte{cpp_solde={sum,euro,X}},_} when X>0->
	    %%CAS A
	    {redirect, S, "#ola2_voix"};
	{_,_,?CETAT_AC}->
	    {redirect, S, "#zap_ac"};
	{_,_,X}  when X==?CETAT_EP;X==?CETAT_PE->
	    {redirect, S, "#zap_ep"};
	{E,F,G}->
	    slog:event(warning, ?MODULE, ola2_unexpected_cpte_state,
		       {State,E,F,G}),
	    {redirect, S, "#temporary"}
    end;
%%% ZAP CMO
select_home(S, #sdp_user_state{declinaison=D}=State)
  when D==?zap_cmo;D==?zap_cmo_1h30_v2;D==?zap_cmo_v2;D==?zap_cmo_18E;D==?zap_cmo_20E;
       D==?zap_cmo_25E;D==?zap_cmo_1h30_ill;D==?zap_cmo_1h_v2 ->
    case {svc_compte:etat_cpte(State,cpte_voix),
	  svc_compte:etat_cpte(State,cpte_princ)} of
	{?CETAT_AC,?CETAT_AC} ->
	    {redirect, S, "#zap_ac"};
        {?CETAT_AC,_} ->
	    {redirect, S, "#zap_forfait"};
	{_,?CETAT_AC}->
	    {redirect, S, "#zap_cpte"};
        {?CETAT_EP,_} ->
	    {redirect, S, "#zap_ep"};
	{?CETAT_PE,_} ->
	    {redirect, S, "#zap_ep"};
	_->
	    slog:event(warning, ?MODULE, zap_unexpected_cpte_state, 
		       State),	  
	    {redirect, S, "#temporary"}
    end;

%%%% FORF HC
select_home(S, #sdp_user_state{declinaison=D}=State) when D==?ppolc->
    case svc_compte:etat_cpte(State,forf_hc) of
	%% heures creuses / temps libre
	%%"epuise" and "perime" have the same redirection, 
	%%but are treated separately in case of future improvement
	?CETAT_AC->
	    {redirect, S, "#olac"};
	?CETAT_EP-> %% EP
	    {redirect, S, "#olac_ep"};
	?CETAT_PE-> %% PE
	    {redirect, S, "#olac_ep"};
	E->
	    slog:event(warning, ?MODULE, ppolc_unexpected_cpte_state, 
		     {State,E}),	  
	    {redirect, S, "#temporary"}
  end;
%%%% FORF CMO Plug Multi-Usages
select_home(S, #sdp_user_state{declinaison=D}=State) when D==?pmu  ->
    case {svc_compte:etat_cpte(State,forf_pmu),
	  svc_compte:etat_cpte(State,forf_webwap)} of
	{undefined,undefined}->
	    slog:event(warning, ?MODULE, pmu_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"};
	_->
	    {redirect, S, "#pmu_sv"}
    end;
select_home(S, #sdp_user_state{declinaison=D}=State) when D==?fmu_18;
							       D==?fmu_24->
    case svc_compte:etat_cpte(State,forf_fmu) of
	?CETAT_AC->
	    {redirect, S, "#fmu"};
	?CETAT_EP->
	    {redirect, S, "#fmu_ep"};
	?CETAT_PE->
	    {redirect, S, "#fmu_ep"};
	_ ->
	    slog:event(warning, ?MODULE, fmu_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;
select_home(S, #sdp_user_state{declinaison=D}=State) when D==?cmo_sl->
    case {svc_compte:etat_cpte(State,forf_cmosl),
	  svc_compte:etat_cpte(State,cpte_princ)} of
	{?CETAT_AC,?CETAT_AC} ->
	    {redirect, S, "#cmo_sl"};
        {?CETAT_AC,_} ->
	    {redirect, S, "#cmo_sl_forfait"};
	{_,?CETAT_AC}->
	    {redirect, S, "#cmo_sl_cpte"};
        {?CETAT_EP,_} ->
	    {redirect, S, "#cmo_sl_ep"};
	{?CETAT_PE,_} ->
	    {redirect, S, "#cmo_sl_ep"};
	_ ->
	    slog:event(warning, ?MODULE, cmo_sl_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;
select_home(S, #sdp_user_state{declinaison=D}=State) when D==?cmo_sl_apu->
    case {svc_compte:etat_cpte(State,forf_cmoslapu),
	  svc_compte:etat_cpte(State,cpte_princ)} of
	{?CETAT_AC,?CETAT_AC} ->
	    {redirect, S, "#cmo_sl_apu"};
        {?CETAT_AC,_} ->
	    {redirect, S, "#cmo_sl_apu_forfait"};
	{_,?CETAT_AC}->
	    {redirect, S, "#cmo_sl_apu_cpte"};
        {?CETAT_EP,_} ->
	    {redirect, S, "#cmo_sl_apu_ep"};
	{?CETAT_PE,_} ->
	    {redirect, S, "#cmo_sl_apu_ep"};
	_ ->
	    slog:event(warning, ?MODULE, cmo_sl_apu_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home(S, #sdp_user_state{declinaison=D}=State) when D==?m6_cmo;
                                D==?m6_cmo2;D==?m6_cmo3;D==?m6_cmo4->
    case svc_compte:etat_cpte(State,forf_mu_m6) of
	?CETAT_AC->
	    {redirect, S, "#m6_ac"};
	?CETAT_EP->
	    {redirect, S, "#m6_ep"};
	?CETAT_PE->
	    {redirect, S, "#m6_ep"};
	_ ->
	    slog:event(warning, ?MODULE, m6_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home(S, #sdp_user_state{declinaison=D}=State) when D==?m6_cmo_1h;D==?m6_cmo_fb_1h;
							  D==?m6_cmo_1h20;D==?m6_cmo_1h40;D==?m6_cmo_2h;D==?m6_cmo_3h;
							  D==?m6_cmo_2h_v3;D==?m6_cmo_1h30_v3;D==?m6_cmo_1h_v3;
							  D==?m6_orange_fixe_1h;D==?m6_cmo_20h_8h;D==?rsa_cmo;
							  D==?m6_cmo_ete;D==?sl_blackberry_1h;D==?m6_cmo_onet_1h_20E;
							  D==?m6_cmo_onet_1h_27E;D==?m6_cmo_onet_2h_30E;
							  D==?FB_M6_1H_SMS;D==?FB_M6_1H30->
    case {svc_compte:etat_cpte(State,forf_m6_mob),
	  svc_compte:etat_cpte(State,cpte_princ)} of
	{?CETAT_AC,?CETAT_AC} ->
            {redirect, S, "#m6_mobile"};
        {?CETAT_AC,_} ->
            {redirect, S, "#m6_mobile_forfait"};
	{_,?CETAT_AC}->
            {redirect, S, "#m6_mobile_cpte"};
        {?CETAT_EP,_} ->
            {redirect, S, "#m6_mobile_epuise"};
	{?CETAT_PE,_} ->
            {redirect, S, "#m6_mobile_epuise"};
	_ ->
	    slog:event(warning, ?MODULE, m6_mobile_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home(S, #sdp_user_state{declinaison=?big_cmo}=State)->
    case svc_compte:etat_cpte(State,big_forf_cmo) of
	?CETAT_AC->
	    {redirect, S, "#big_ff_cmo_ac"};
	?CETAT_EP->
	    {redirect, S, "#big_ff_cmo_ep"};
	?CETAT_PE->
	    {redirect, S, "#big_ff_cmo_ep"};
	_ ->
	    slog:event(warning, ?MODULE, big_cmo_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home(S, State) ->
    slog:event(failure, ?MODULE, unexpected_declinaison, State),
    {redirect, S, "#temporary"}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% redirect in function of stats's compte %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type select_home_niv3(session())-> erlpage_result().
select_home_niv3(abs) ->
    [ {redirect, abs, "#olan"},
      {redirect, abs, "#olan_epuise"},
      {redirect, abs, "#olax"},
      {redirect, abs, "#olac"},
      {redirect, abs, "#olac_ep"},
      {redirect, abs, "#ola2_wap"},
      {redirect, abs, "#ola2_voix"},
      {redirect, abs, "#zap_ac"},
      {redirect, abs, "#zap_ep"},
      {redirect, abs, "#pmu_sv"},
      {redirect, abs, "#fmu"},
      {redirect, abs, "#fmu_ep"},
      {redirect, abs, "#m6_ac"},
      {redirect, abs, "#m6_ep"},
      {redirect, abs, "#m6_mobile_ac"},
      {redirect, abs, "#m6_mobile_ep"},
      {redirect, abs, "#temporary"}
     ];
select_home_niv3(#session{}=Session)->
    State = svc_util_of:get_user_state(Session),
    select_home_niv3(Session,State).
%% +type select_home_niv3(session(),sdp_user_state())-> erlpage_result().
%%%% OLAN
select_home_niv3(Session,#sdp_user_state{declinaison=?ppola}=State)
  when (State#sdp_user_state.cpte_princ)#compte.etat == ?CETAT_EP->
    {redirect, Session, "#olan_epuise"};
select_home_niv3(Session,#sdp_user_state{declinaison=?ppola}=State)
  when (State#sdp_user_state.cpte_princ)#compte.etat == ?CETAT_PE->
    {redirect, Session, "#olan_epuise"};
select_home_niv3(Session,#sdp_user_state{declinaison=?ppola}=State)->
    {redirect,Session,"#olan"};
%%%% OLAX
select_home_niv3(Session, #sdp_user_state{declinaison=D}=State) when D==?ppol1;
							       D==?ppol3->
    {redirect, Session, "#olax"};

%%%% OLAX
select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?ppolc->
    case svc_compte:etat_cpte(State,forf_hc) of
	%% heures creuses / temps libre
	%%"epuise" and "perime" have the same redirection, 
	%%but are treated separately in case of future improvement
	?CETAT_AC->
	    {redirect, S, "#olac"};
	?CETAT_EP-> %% EP
	    {redirect, S, "#olac_ep"};
	?CETAT_PE-> %% PE
	    {redirect, S, "#olac_ep"};
	E->
	    slog:event(warning, ?MODULE, ppolc_unexpected_cpte_state_niv3, 
		     {State,E}),	  
	    {redirect, S, "#temporary"}
  end;
select_home_niv3(S, #sdp_user_state{declinaison=?ppol2}=State)->
    case
	{svc_compte:cpte(State,forf_wap234),
	 svc_compte:cpte(State,forf_sms),
	 svc_compte:etat_cpte(State,cpte_voix)} of
	{#compte{cpp_solde={sum,euro,X}},_,_} when X>0->
	    %%CAS D
	    {redirect, S, "#ola2_wap"};
	{_,#compte{cpp_solde={sum,euro,X}},_} when X>0->
	    %%CAS A
	    {redirect, S, "#ola2_voix"};
	{_,_,?CETAT_AC}->
	    {redirect, S, "#zap_ac"};
	{_,_,X}  when X==?CETAT_EP;X==?CETAT_PE->
	    {redirect, S, "#zap_ep"};
	{E,F,G}->
	    slog:event(warning, ?MODULE, ola2_unexpected_cpte_state,
		       {State,E,F,G}),
	    {redirect, S, "#temporary"}
    end;
select_home_niv3(S, #sdp_user_state{declinaison=D}=State)
when D==?zap_cmo;D==?zap_cmo_1h30_v2;D==?zap_cmo_v2;D==?zap_cmo_18E;D==?zap_cmo_20E;
     D==?zap_cmo_25E;D==?zap_cmo_1h30_ill;D==?zap_cmo_1h_v2 ->
    case svc_compte:etat_cpte(State,cpte_voix) of
	?CETAT_AC->
	    {redirect, S, "#zap_ac"};
	E when E==?CETAT_EP;E==?CETAT_PE->
	    {redirect, S, "#zap_ep"};
	E->
	    slog:event(warning, ?MODULE, zap_unexpected_cpte_state, 
		       {State,E}),	  
	    {redirect, S, "#temporary"}
    end;

%%%% FORF CMO Plug Multi-Usages
select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?pmu  ->
    case {svc_compte:etat_cpte(State,forf_pmu),
	  svc_compte:etat_cpte(State,forf_webwap)} of
	{undefined,undefined}->
	    slog:event(warning, ?MODULE, pmu_unexpected_cpte_state_niv3, 
		       State),
	    {redirect, S, "#temporary"};
	_->
	    {redirect, S, "#pmu_sv"}
    end;
select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?fmu_18;
							       D==?fmu_24->
    case svc_compte:etat_cpte(State,forf_fmu) of
	?CETAT_AC->
	    {redirect, S, "#fmu"};
	?CETAT_EP->
	    {redirect, S, "#fmu_ep"};
	?CETAT_PE->
	    {redirect, S, "#fmu_ep"};
	_ ->
	    slog:event(warning, ?MODULE, fmu_unexpected_cpte_state_niv3, 
		       State),
	    {redirect, S, "#temporary"}
    end;
select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?cmo_sl->
    case svc_compte:etat_cpte(State,forf_cmosl) of
	?CETAT_AC->
	    {redirect, S, "#cmo_sl"};
	?CETAT_EP->
	    {redirect, S, "#cmo_sl_ep"};
	?CETAT_PE->
	    {redirect, S, "#cmo_sl_ep"};
	_ ->
	    slog:event(warning, ?MODULE, cmo_sl_unexpected_cpte_state_niv3, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?cmo_sl_apu ->
    case svc_compte:etat_cpte(State,forf_cmoslapu) of
        ?CETAT_AC ->
	    {redirect, S, "#cmo_sl_apu"};
        E when E==?CETAT_EP;E==?CETAT_PE ->
	    {redirect, S, "#cmo_sl_apu_ep"};
	_ ->
	    slog:event(warning, ?MODULE, cmo_sl_apu_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?m6_cmo;
                                     D==?m6_cmo2;D==?m6_cmo3;D==?m6_cmo4->
    case svc_compte:etat_cpte(State,forf_mu_m6) of
	?CETAT_AC->
	    {redirect, S, "#m6_ac"};
	?CETAT_EP->
	    {redirect, S, "#m6_ep"};
	?CETAT_PE->
	    {redirect, S, "#m6_ep"};
	_ ->
	    slog:event(warning, ?MODULE, m6_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;
select_home_niv3(S, #sdp_user_state{declinaison=D}=State) when D==?m6_cmo_1h;D==?m6_cmo_fb_1h;
							       D==?m6_cmo_1h20;D==?m6_cmo_1h40;D==?m6_cmo_2h;D==?m6_cmo_3h;
							       D==?m6_cmo_2h_v3;D==?m6_cmo_1h30_v3;D==?m6_cmo_1h_v3;
							       D==?m6_orange_fixe_1h;D==?m6_cmo_20h_8h;D==?rsa_cmo;
							       D==?m6_cmo_ete;D==?sl_blackberry_1h;D==?m6_cmo_onet_1h_20E;
							       D==?m6_cmo_onet_1h_27E;D==?m6_cmo_onet_2h_30E;
							       D==?FB_M6_1H_SMS;D==?FB_M6_1H30 ->
    case svc_compte:etat_cpte(State,forf_m6_mob) of
	?CETAT_AC->
	    {redirect, S, "#m6_mobile_ac"};
	?CETAT_EP->
	    {redirect, S, "#m6_mobile_ep"};
	?CETAT_PE->
	    {redirect, S, "#m6_mobile_ep"};
	_ ->
	    slog:event(warning, ?MODULE, m6_mobile_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;
select_home_niv3(S, #sdp_user_state{declinaison=?big_cmo}=State)->
    case svc_compte:etat_cpte(State,big_forf_cmo) of
	?CETAT_AC->
	    {redirect, S, "#big_ff_cmo_ac"};
	?CETAT_EP->
	    {redirect, S, "#big_ff_cmo_ep"};
	?CETAT_PE->
	    {redirect, S, "#big_ff_cmo_ep"};
	_ ->
	    slog:event(warning, ?MODULE, big_cmo_unexpected_cpte_state, 
		       State),
	    {redirect, S, "#temporary"}
    end;

select_home_niv3(S, State) ->
    slog:event(failure, ?MODULE, unexpected_declinaison_niv3, State),
    {redirect, S, "#temporary"}.	

%% +type include_sv_130(session()) -> [{pcdata,string()}].
include_sv_130(abs) ->
    [{pcdata,"suivi-conso 130 caracteres"}];
include_sv_130(#session{}=S) ->
    case svc_spider:get_availability(S) of
	available ->
	    [{include,{relurl,"file:/orangef/selfcare_light/spider.xml#prepaid"}}];
	_ ->
	    {redirect,_,Page} = svc_selfcare_cmo:select_home(S),
	    [{include,{relurl,"file:/orangef/selfcare_light/selfcare_cmo.xml" ++ Page}}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compte Promotionel                     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type menu(session(),url())-> erlpage_result().
menu(abs,Url)->
    [{redirect,abs,Url}];
menu(#session{}=Session,Url)->
    %% initialisation d'un besoin pour le service promo.
    {Sess_new,State} = svc_options:check_topnumlist(Session),
    List_Promo=pbutil:get_env(pservices_orangef,promo_link),
    List_Options=get_options_list(State),
    State_=State#sdp_user_state{tmp_promo=get_next_promo(List_Promo,State),
				tmp_options=get_next_options(List_Options,
							     Sess_new)},
    Session2 = svc_util_of:update_user_state(Sess_new,State_),
    {redirect,Session2,Url}.

%% +type print_next_link_promo(session())-> [hlink()].	
%%%% on affiche le lien suivant si il y a une promo supplémentaires
print_next_link_promo(abs)->
    [#hlink{href="erl://svc_selfcare_cmo:next_promo", 
	    contents=[{pcdata, "suite"}]},br];
print_next_link_promo(Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.tmp_promo of
	{Url,T}->
	    [#hlink{href="erl://svc_selfcare_cmo:next_promo", 
		    contents=[{pcdata, "suite"}]},br];
	no_link->
	    []
    end.

%% +type print_first_link_promo(session(),PCDATA::string(),
%%                              URL::string())-> 
%%                              [hlink()].	
print_first_link_promo(abs,PCDATA,URL)->
    [#hlink{href=URL,contents=[{pcdata, PCDATA}]}];
print_first_link_promo(Session,PCDATA,URL)->
    State = svc_util_of:get_user_state(Session),
    List_Promo=pbutil:get_env(pservices_orangef,promo_link),
    case get_next_promo(List_Promo,State) of
	{Url,T}->
	    [#hlink{href=URL,contents=[{pcdata, PCDATA}]}];
	no_link->
	    []
    end.

%% +type next_promo(session())-> erlpage_result().	
%%%% on met a jour les données utiles dans tmp_serv
%%%% pour la suite des données de promo
%%%% puis on redirige sur la promo suivante
next_promo(abs)->
    List_Promo=pbutil:get_env(pservices_orangef,promo_link),
    lists:flatten(lists:map(fun({C,Url})->
		      {redirect,abs,Url};
		 ({C,Url_A,Url_B})->
		      [{redirect,abs,Url_A},{redirect,abs,Url_B}];
		 ({C,Url_A,Url_B,Url_C})->
		      [{redirect,abs,Url_A},{redirect,abs,Url_B},
		       {redirect,abs,Url_C}]
	      end,List_Promo));
next_promo(Session)->
    State = svc_util_of:get_user_state(Session),
    {State_, Url_} = case State#sdp_user_state.tmp_promo of
			no_link -> 
			    slog:event(warning,?MODULE,no_next_promo_url),
			    {State,"#temporary"};
			{Url,T} -> 
			    {State#sdp_user_state{tmp_promo=get_next_promo(T,State)},Url}
		    end,
    {redirect,svc_util_of:update_user_state(Session,State_),Url_}.

%% +deftype promo() = {atom(),url()}.
%% +type get_next_promo([promo()],sdp_user_state())-> {url(),[promo()]} | nolink.
get_next_promo([{bonus,Url}|T],State)->
    D_Activ = State#sdp_user_state.d_activ,
    D_Reference = svc_util_of:local_time_to_unixtime({{2006,1,19},{0,0,0}}),
    case {D_Activ > D_Reference,State#sdp_user_state.declinaison} of 
	{true,?ppol2} ->
	    get_next_promo(T,State);
	{true,zap_cmo} ->
	    get_next_promo(T,State);
	{_,X} when X==?ppol3;X==?ppolc;X==?ppol1;X==?ppol2;
		   X==?pmu;X==?fmu_18;X==?fmu_24;X==?cmo_sl;
		   X==?zap_cmo;X==?cmo_sl_apu;X==?ppola ->
	    Etat_Bonus= anciennete(State),
	    case Etat_Bonus of
		undefined->
		    get_next_promo(T,State);
		_->
		    {Url,T}
	    end;
	{_,_} ->
	    get_next_promo(T,State)
    end;
get_next_promo([{Compte,Url}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url,T};
	_->
	    get_next_promo(T,State)
    end;
get_next_promo([{Compte,Url_AC,Url_EP}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url_AC,T};
	?CETAT_EP->
	    {Url_EP,T};
	_->
	    get_next_promo(T,State)
    end;
get_next_promo([{Compte,Url_AC,Url_EP,Url_PE}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url_AC,T};
	?CETAT_EP->
	    {Url_EP,T};
	?CETAT_PE->
	    {Url_PE,T};
	_->
	    get_next_promo(T,State)
    end;
get_next_promo(L,S) ->
    no_link.

%% +type redirect_opt(session(), Links::string()) ->
%%         erlpage_result().
redirect_opt(abs, Links) ->
    Links1 = string:tokens(Links, ","), 
    FL = fun (S) -> [K,Link] = string:tokens(S,"="), {redirect,abs,Link} end,
    lists:map(FL, Links1);
redirect_opt(Session,Links)->
    State = svc_util_of:get_user_state(Session),
    Links1 = string:tokens(Links, ","),
    {Session_new,State_New} = svc_options:check_topnumlist(Session),
    FL = fun (S) -> [K,Link] = string:tokens(S,"="), 
		    case K of
			"default"-> {default,Link};
			_->
			    {svc_options:is_option_activated(Session_new,
							     list_to_atom(K)),
			     Link}
		    end 
	 end,
    Links2 = lists:map(FL,Links1),
    case catch pbutil:assoc(true, Links2) of
	{'EXIT', _} -> {redirect, Session_new, pbutil:assoc(default,Links2)};
	Link -> {redirect, Session_new, Link}
    end.

%% +type redirect_date(session(),Opt::string(),
%%                     Url_A::string(),Url_B::string()) ->
%%                     erlpage_result().
redirect_date(abs, Opt, Url_A, Url_B) ->
    [{redirect,abs,Url_A},{redirect,abs,Url_B}];
redirect_date(Session, Opt, Url_A, Url_B)->
    Link = case calendar:day_of_the_week(date()) of
	       N when N==6; N==7 -> Url_A;
	       _ -> Url_B
	   end,
    {redirect, Session, Link}.

%% +type redirect_credit(session(), Opt::string(), Url_A::string(), Url_B::string()) ->
%%         erlpage_result().
redirect_credit(abs, Opt, Url_A, Url_B) ->
    [{redirect,abs,Url_A},{redirect,abs,Url_B}];
redirect_credit(Session, Opt, Url_A, Url_B)->
    State = svc_util_of:get_user_state(Session),
    Link = case svc_compte:cpte(State,svc_options:opt_to_godet(list_to_atom(Opt),cmo)) of
	       #compte{etat=?CETAT_AC} -> 
		   Url_A;
	       _ ->
		   Url_B
	   end,
    {redirect, Session, Link}.
%% +type redirect_credit(session(), Opt::string(), URL_PrincSec::string(), URL_PrincNoSec::string(),URL_NoPrincSec::string(),URL_NoPrincNoSec::string()) ->
%%         erlpage_result().
%%%%Si options sms quotidien, on examine les comptes principaux et secondaires
redirect_credit(abs, Opt, URL_PrincSec, URL_PrincNoSec, URL_NoPrincSec,URL_NoPrincNoSec) ->
     [{redirect,abs,URL_PrincSec},{redirect,abs,URL_PrincNoSec},{redirect,abs,URL_NoPrincSec},{redirect,abs,URL_NoPrincNoSec}];
redirect_credit(Session, Option, URL_PrincSec, URL_PrincNoSec, URL_NoPrincSec,URL_NoPrincNoSec)
  when Option=="opt_sms_quoti"->
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    {Session1,State_New} = svc_options:check_topnumlist(Session),
    TopNumList = State_New#sdp_user_state.topNumList,
    {_,_,SoldePrinc} = svc_compte:solde_cpte(State_New,cpte_princ),
    {_,_,SoldeSec} = svc_compte:solde_cpte(State_New,svc_options:opt_to_godet(Opt,cmo)),
    {value, {_,Price}}= lists:keysearch(Opt, 1, pbutil:get_env(pservices_orangef,subscription_price_cmo)),
    %On met 10 pour le solde secondaire car le montant initial (504) est supérieur au coût (500)
    Link = case {SoldePrinc >= Price,SoldeSec >= 10} of
	       {true, true}   -> URL_PrincSec;
	       {true, false}  -> URL_PrincNoSec;
	       {false, true}  -> URL_NoPrincSec;
	       {false, false} -> URL_NoPrincNoSec
	   end,
    {redirect, Session1, Link}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_dcl_cmo(session(),Opt::string(), string(),
%%                        string(),string(),string()) ->
%%                        erlpage_result().
redirect_dcl_cmo(abs, Opt, URL_14_18, URL_22_31, URL_30_31, URL_32_33) ->
     [{redirect,abs,URL_14_18},{redirect,abs,URL_22_31},
      {redirect,abs,URL_30_31},{redirect,abs,URL_32_33}];

redirect_dcl_cmo(Session, Option, URL_14_18, URL_22_31, URL_30_31, URL_32_33)
    when Option == "opt_m6_smsmms" ->	
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DCL_NUM = State#sdp_user_state.declinaison,
    Link = if (DCL_NUM == 14) or (DCL_NUM == 18) ->
		   URL_14_18;
	      (DCL_NUM == 22) or (DCL_NUM == 23) ->
		   URL_22_31;
	      (DCL_NUM == 30) or (DCL_NUM == 31) ->
		   URL_30_31;
	      (DCL_NUM == 32) or (DCL_NUM == 33) ->
		   URL_32_33;
	      true ->
		   slog:event(failure,?MODULE, redirect_dcl_cmo, DCL_NUM),
		   "#temporary"
	   end,
    {redirect, Session, Link}.
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Bonus                                  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type bonus(session())-> erlpage_result().
bonus(abs)->
    [
     {redirect,abs,"#ola_bonus_first"},
     {redirect,abs,"#ola_bonus_inter"},
     {redirect,abs,"#ola_bonus_teasing_2"},
     {redirect,abs,"#ola_bonus_teasing_1"},
     {redirect,abs,"#olax_bonus_first"},
     {redirect,abs,"#olax_bonus_inter"},
     {redirect,abs,"#olax_bonus_teasing_2"},
     {redirect,abs,"#olax_bonus_teasing_1"}];

%  1) Les clients ZAP en acquisition pour lesquels on arrete le bonus à partir du 19/01/2006 sont les déclinaison 6 et 13.
%  2) La restitution du bonus sur le rechargement est seulement valable pour la déclinaison 1.
%  3) La restitution du bonus sur le forfait est valable pour les déclinaisons 2, 3, 5, 6, 7, 8, 9, 10, 13, 15
%  4) Les autres déclinaisons (notamment la 14 et 18) ne doivent pas avoir de restitution de bonus.
bonus(Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.declinaison of
	% Cas du bonus forfait
 	X when X==?ppol3;X==?ppolc;X==?ppol1;X==?ppol2;
 	       X==?pmu;X==?fmu_18;X==?fmu_24;X==?cmo_sl;
 	       X==?zap_cmo;X==?cmo_sl_apu ->
	    case(anciennete(State)) of
 	        Y when Y=<5 ->
 		    {redirect,Session,"#olax_bonus_first"};
 		Y when Y==16;Y==28->
 		    {redirect,Session,"#olax_bonus_teasing_2"};
 		Y when Y==17;Y==29->
 		    {redirect,Session,"#olax_bonus_teasing_1"};
 		_ ->
 		    {redirect,Session,"#olax_bonus_inter"}
 	    end;
	% Cas du bonus rechargement  
 	X when X==?ppola ->
	    case(anciennete(State)) of
 		Y when Y=<5 ->
 		    {redirect,Session,"#ola_bonus_first"};
 		Y when Y==16;Y==28->
 		    {redirect,Session,"#ola_bonus_teasing_2"};
 		Y when Y==17;Y==29->
 		    {redirect,Session,"#ola_bonus_teasing_1"};
 		_ ->
 		    {redirect,Session,"#ola_bonus_inter"}
 	    end
     end.
% bonus(Session)->
%     State = svc_util_of:get_user_state(Session),
%     case {State#sdp_user_state.declinaison,
% 	  anciennete(State)} of
% 	{?m6_cmo,_}->
% 	    slog:event(failure,?MODULE,m6_cmo_access_bonus),
% 	    {redirect,Session,"#temporary"};
% 	{?m6_cmo2,_}->
% 	    slog:event(failure,?MODULE,m6_cmo_access_bonus),
% 	    {redirect,Session,"#temporary"};
% 	{?ppola,X} when X=<5->
% 	    {redirect,Session,"#ola_bonus_first"};
% 	{?ppola,X} when X==16;X==28->
% 	    {redirect,Session,"#ola_bonus_teasing_2"};
% 	{?ppola,X} when X==17;X==29->
% 	    {redirect,Session,"#ola_bonus_teasing_1"};
% 	{?ppola,X} ->
% 	    {redirect,Session,"#ola_bonus_inter"};
% 	%% capri
% 	{?ppol2,X} when X=<5->
% 	    {redirect,Session,"#ola_bonus_first"};
% 	{?ppol2,X} when X==16;X==28->
% 	    {redirect,Session,"#ola_bonus_teasing_2"};
% 	{?ppol2,X} when X==17;X==29->
% 	    {redirect,Session,"#ola_bonus_teasing_1"};
% 	{?ppol2,X} ->
% 	    {redirect,Session,"#ola_bonus_inter"};
% 	%% ELSE PPOL1 ,PPOL3, PPOLC, et PMU
% 	{_,X} when X=<5->
% 	    {redirect,Session,"#olax_bonus_first"};
% 	{_,X} when X==16;X==28->
% 	    {redirect,Session,"#olax_bonus_teasing_2"};
% 	{_,X} when X==17;X==29->
% 	    {redirect,Session,"#olax_bonus_teasing_1"};
% 	{_,X} ->
% 	    {redirect,Session,"#olax_bonus_inter"}
%     end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% promo_infini                           %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%used for the "we et mercredi infini" promo
%%%% according to the DCL_num, goes to the "mercredi" or "we" infini
%% +type promo_infini(session())-> erlpage_result().
promo_infini(abs)->
    [
     {redirect,abs,"#we_infini"},
     {redirect,abs,"#mercredi_infini"}];
promo_infini(Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.declinaison of
	X when X==?ppol2;X==?pmu ->
	    {redirect,Session,"#mercredi_infini"};
	_ ->
	    {redirect,Session,"#we_infini"}
    end.

%% +type anciennete(sdp_user_state())-> integer().
anciennete(State)->   
    Cpte_Ref=
	case State#sdp_user_state.declinaison of
 	    X when X==?mobi;X==?cpdeg;X==?ppola;X==?ppol2->
		svc_compte:cpte(State,cpte_princ);
	    X when X==?ppol1;X==?ppol3->
		svc_compte:cpte(State,cpte_forf);
	    ?pmu ->
		svc_compte:cpte(State,forf_pmu);
	    ?ppolc ->
		svc_compte:cpte(State,forf_hc);
	    X when X==?fmu_18;X==?fmu_24 ->
		svc_compte:cpte(State,forf_fmu);
	    ?cmo_sl ->
		svc_compte:cpte(State,forf_cmosl);
 	    _->
 		svc_compte:cpte(State,cpte_princ)
 	end,
    Cpte_Ref#compte.anciennete.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Options                                %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% on affiche le lien suivant si il y a une promo supplémentaires
%% +deftype option() = {{option,atom()},url()} | {Compte::atom(), url()} |
%%                     {Cpte::atom(),url(),url()}.
%% +type get_options_list(session())-> [option()].
get_options_list(_) ->
    pbutil:get_env(pservices_orangef,options_link).

%% +type print_next_link_options(session())-> [hlink()].
print_next_link_options(abs)->
    [#hlink{href="erl://svc_selfcare_cmo:next_options", 
	    contents=[{pcdata, "suite"}]},br];
print_next_link_options(Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.tmp_options of
	{Url,T}->
	    [#hlink{href="erl://svc_selfcare_cmo:next_options", 
		    contents=[{pcdata, "suite"}]},br];
	no_link->
	    []
    end.

%% +type print_first_link_options(session(),Descr::string(),
%%                                URL::string()) ->
%%                                [hlink()].
 
print_first_link_options(abs,Descr,URL)->
    [#hlink{href=URL, 
	    contents=[{pcdata, Descr}]}];
print_first_link_options(Session,Descr,URL)->
    {Sess_new,State} = svc_options:check_topnumlist(Session),
    L_Options=pbutil:get_env(pservices_orangef,options_link),
    case get_next_options(L_Options,Sess_new) of
	{Url,T}->
	    [#hlink{href="options_cmo.xml", 
		    contents=[{pcdata, "Vos options"}]},br];
	no_link->
	    []
    end.
%% +type next_options(session())-> erlpage_result().
%%%% on met a jour les données utiles dans tmp_options
%%%% pour la suite des données de promo
%%%% puis on redirige sur la promo suivante
next_options(abs)->
    O_def=pbutil:get_env(pservices_orangef,options_link),
    Options=[{"default",O_def}],
    Redir=lists:map(fun({S,Opts})->
			    expand_abs_options(Opts,S)
		    end,Options),
    lists:flatten(Redir);

next_options(Session)->
    {Sess_new,State} = svc_options:check_topnumlist(Session),
    %%{Url,T}=State#sdp_user_state.tmp_options,
    {State_,Url_}=
	case State#sdp_user_state.tmp_options of
	    no_link->
		slog:event(warning,?MODULE,no_next_options_url),
		{State,"#temporary"};
	    {Url,T} -> 
		{State#sdp_user_state{tmp_options=
				      get_next_options(T,Sess_new)},
		 Url}
	end,
    {redirect,svc_util_of:update_user_state(Sess_new,State_),Url_}.


%% +type get_next_options([option()],session())-> 
%%                        {url(), [option()]} | no_link.
get_next_options([{{option,OPT},Url}|T],Session)
  when OPT == opt_illimite_cmo; 
       OPT == opt_we_voix_ill ->
    State = svc_util_of:get_user_state(Session),
    case svc_options:is_option_activated(Session,OPT) of
	true ->
	    case svc_compte:etat_cpte(State,
				      svc_options:opt_to_godet(OPT,cmo)) of
		?CETAT_AC->
		    {Url,T};
		_ ->
		    get_next_options(T,Session)
	    end;
	_ -> get_next_options(T,Session)
    end;
get_next_options([{{option,OPT},Url}|T],Session)->
    case svc_options:is_option_activated(Session,OPT) of
	false-> 
	    get_next_options(T,Session);
	true-> 
	    {Url,T}
    end;
get_next_options([{cpte_five_min,Url}|T],Session)->
    State = svc_util_of:get_user_state(Session),
    case  {svc_compte:etat_cpte(State,cpte_five_min),
	   svc_util_of:is_plug(State),
	   svc_util_of:is_zap(State)}of
	{?CETAT_AC,true,_} ->
	    {Url,T};
	{?CETAT_AC,_,true}->
	    {Url,T};
	_-> get_next_options(T,Session)
    end;
get_next_options([{forf_sms_promo,URL_ETU,URL_HEBDO}|T],Session)->
    State = svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,forf_sms_promo) of
	#compte{etat=?CETAT_AC,ptf_num=130}->
	    {URL_ETU,T};
	#compte{etat=?CETAT_AC,ptf_num=118}->
	    {URL_HEBDO,T};
	_->
	    get_next_options(T,Session)
    end;
get_next_options([{OPT, URL_ac, URL_ep}|T],Session)
   when OPT == media_decouvrt ; OPT == media_internet ; OPT == media_internet_plus->
     case svc_options:is_option_activated(Session,OPT) of
 	false-> 
 	    get_next_options(T,Session);
 	true-> 
	     State = svc_util_of:get_user_state(Session),
	     case svc_compte:etat_cpte(State,forf_orangex) of
		 ?CETAT_AC->
		     {URL_ac,T};
		 ?CETAT_EP->
		     {URL_ep,T};
		 _ ->
		     get_next_options(T,Session)
	     end;
	 _ ->
	     get_next_options(T,Session)
     end;
get_next_options([{{Compte,Option},Url}|T],Session)
   when Option == journee_ow_zap;Option == journee_ow_cmo->
    State = svc_util_of:get_user_state(Session),
    case {Option,svc_compte:etat_cpte(State,Compte),
	  svc_util_of:is_zap(State)}of
	{journee_ow_zap,?CETAT_AC,true}->
	    {Url,T};
	{journee_ow_cmo,?CETAT_AC,false}->
	    {Url,T};
	{_,_,_} ->
	    get_next_options(T,Session)
    end;
get_next_options([{{Compte,Opt},Url}|T],Session)->
    State = svc_util_of:get_user_state(Session),
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url,T};
	?CETAT_EP->
	    {Url,T};
	_ ->
	    get_next_options(T,Session)
    end;
get_next_options([{Compte,Url}|T],Session)
    when Compte == cpte_3num_kdosms->
    State = svc_util_of:get_user_state(Session),
    case  {svc_compte:etat_cpte(State,Compte),
	   svc_util_of:is_zap(State)}of
	{?CETAT_AC,true} ->
	    {Url,T};
	{_,_}-> get_next_options(T,Session)
    end;
get_next_options([{Compte,Url}|T],Session)->
    State = svc_util_of:get_user_state(Session),
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url,T};
	_ ->
	    get_next_options(T,Session)
    end;
get_next_options([{Compte,Url_AC,Url_EP}|T],Session) 
  when Compte == cpte_easy_voice ->
    State = svc_util_of:get_user_state(Session),
    case svc_options:is_option_activated(Session,opt_illimite_cmo) of
	true -> 
	    get_next_options(T,Session);
	_ ->
	    case svc_compte:etat_cpte(State,Compte) of
		?CETAT_AC->
		    {Url_AC,T};
		?CETAT_EP->
		    {Url_EP,T};
		_ ->
		    get_next_options(T,Session)
	    end
    end;
get_next_options([{Compte,Url_AC,Url_EP}|T],Session) 
  when Compte == forf_orangex ->
    State = svc_util_of:get_user_state(Session),
    case svc_options:is_option_activated(Session,media_decouvrt) or
	svc_options:is_option_activated(Session,media_internet) or
	svc_options:is_option_activated(Session,media_internet_plus) of
	true -> 
	    get_next_options(T,Session);
	_ ->
	    case svc_compte:etat_cpte(State,Compte) of
		?CETAT_AC->
		    {Url_AC,T};
		?CETAT_EP->
		    {Url_EP,T};
		_ ->
		    get_next_options(T,Session)
	    end
    end;
get_next_options([{Compte,Url_AC,Url_EP}|T],Session) when atom(Compte)->
    State = svc_util_of:get_user_state(Session),
    case svc_compte:etat_cpte(State,Compte) of
		 ?CETAT_AC->
		     {Url_AC,T};
		 ?CETAT_EP->
		     {Url_EP,T};
		 _ -> get_next_options(T,Session)
    end;
get_next_options(L,S) ->
    no_link.


%% +type expand_abs_options(option(),string())-> [{string(),erlpage_result()}].
expand_abs_options(Opts,S)->
    lists:foldl(fun(X,Acc)->
			case X of
			    {C,Url}->
				Acc++[{S,{redirect,abs,Url}}];
			    {C,Url_a,Url_b}->
				Acc++[{S,{redirect,abs,Url_a}},
				      {S,{redirect,abs,Url_b}}]
			end end,[],Opts).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Activation Plan Vacances ZAP          %%%%%%%%%%%%%%%%%%%%%%%%
%% +type proposer_lien(session(),string(),Url::string(),string(),string())-> hlink().
proposer_lien(abs,"forf_mu_m6",PCD_URLs,BR,Key) ->
    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
proposer_lien(abs,Opt,PCD,URL,BR)->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
proposer_lien(Session,"plan_zap",PCD,URL,BR)->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_commercially_launched(Session,plan_zap) and
	((svc_compte:dcl(State)==?ppol2) or (svc_compte:dcl(State)==?zap_cmo)) and
	(svc_compte:ptf_num(State,cpte_princ) =/= ?CMO_ZAP_PROMO) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	false->
	    []
    end;
proposer_lien(Session,"forf_mu_m6",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
   case svc_compte:etat_cpte(State,forf_mu_m6) of
	X when X== ?CETAT_AC;X== ?CETAT_EP;X== ?CETAT_PE->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
	_-> 
	    []
    end.

%% +type activ_plan_zap(session(),URL_OK::string(),URL_KO::string())->
%%   erlpage_result().
activ_plan_zap(abs,URL_OK,URL_KO)->
    [{redirect,abs,URL_OK},
     {redirect,abs,URL_KO}];
activ_plan_zap(#session{prof=Profile}=S,URL_OK,URL_KO)->
   
    State = svc_util_of:get_user_state(S),
    Msisdn = Profile#profile.msisdn,
    DCL = svc_compte:dcl(State),
    %% do 2 g2 requests or change_user_account
    case do_activ_plan_zap(S,Msisdn,DCL) of
	{ok,_} when DCL==?zap_cmo->
	    %% TODO : do MAJ #compte ?!
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = svc_util_of:update_state(S,
					  [{cpte_princ,C_PRINC#compte{ptf_num=?CMO_ZAP_PROMO}},
					    {cpte_voix,C_VOIX#compte{ptf_num=?CMO_ZAP_PROMO}}]),
	    {redirect,S2,URL_OK};
	{ok,_} when DCL==?ppol2->
	    %% TODO : do MAJ #compte ?!
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = svc_util_of:update_state(S,
					  [{cpte_princ,C_PRINC#compte{ptf_num=?CMO_ZAP_PROMO_PPOL2}},
					    {cpte_voix,C_VOIX#compte{ptf_num=?CMO_ZAP_PROMO_PPOL2}}]),
	    prisme_dump:prisme_count(S,plan_zap),
	    {redirect,S2,URL_OK};
	{ok,_} when DCL==?zap_vacances->
	    %% TODO : do MAJ #compte ?!
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = svc_util_of:update_state(S,
					  [{cpte_princ,C_PRINC#compte{ptf_num=?CMO_ZAP_PROMO}},
					    {cpte_voix,C_VOIX#compte{ptf_num=?CMO_ZAP_PROMO}}]),
	    prisme_dump:prisme_count(S,plan_zap),
	    {redirect,S2,URL_OK};
	{ok,_} when DCL==?zap_cmo_1h30_v2->
	    %% TODO : do MAJ #compte ?!
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = svc_util_of:update_state(S,
					  [{cpte_princ,C_PRINC#compte{ptf_num=?CMO_ZAP_PROMO}},
					    {cpte_voix,C_VOIX#compte{ptf_num=?CMO_ZAP_PROMO}}]),
	    prisme_dump:prisme_count(S,plan_zap),
	    {redirect,S2,URL_OK};
	_ ->
	    {redirect,S,URL_KO}
    end.

%% +type do_activ_plan_zap(Msisdn::string()|session(),DCL::integer())-> 
%%                        {ok, term()} | {error, term()}.
do_activ_plan_zap(Session, Msisdn, DCL)->
    PTChangePrice = currency:sum(euro,0),
    Compte_princ = #compte{ptf_num=zap_ptf_from_dcl(DCL), 
                           pct=PTChangePrice, 
                           d_crea=pbutil:unixtime(),
                           tcp_num=?C_PRINC, 
                           ctrl_sec=0},
    Compte_new = #compte{ptf_num=zap_ptf_from_dcl(DCL), 
                         pct=PTChangePrice, 
                         d_crea=pbutil:unixtime(),
                         tcp_num=zap_tcp_from_dcl(DCL), 
                         ctrl_sec=0},
    case svc_util_of:change_user_account(Session, {cmo,Msisdn}, 
                                         Compte_princ) of        
        {ok, _} ->
            svc_util_of:change_user_account(Session, {cmo,Msisdn}, 
                                            Compte_new);
        Else ->
	    slog:event(failure,?MODULE,do_activ_plan_zap,
                       {Msisdn,dcl,DCL,Else}),
	    {error,Else}
    end.

zap_ptf_from_dcl(?zap_cmo) ->        ?CMO_ZAP_PROMO;
zap_ptf_from_dcl(?ppol2) ->          ?CMO_ZAP_PROMO_PPOL2;
zap_ptf_from_dcl(?zap_vacances) ->   ?CMO_ZAP_PROMO;
zap_ptf_from_dcl(?zap_cmo_1h30_v2) ->?CMO_ZAP_PROMO;
zap_ptf_from_dcl(?zap_cmo_25E) ->    ?CMO_ZAP_PROMO;
zap_ptf_from_dcl(_) -> {[],[]}.

zap_tcp_from_dcl(?zap_cmo) ->        ?C_VOIX_ZAP;
zap_tcp_from_dcl(?ppol2) ->          ?C_VOIX;
zap_tcp_from_dcl(?zap_vacances) ->   ?C_FORF_ZAP_CMO_25E_v3;
zap_tcp_from_dcl(?zap_cmo_1h30_v2) ->?C_FORF_ZAP_CMO_1h30_v3;
zap_tcp_from_dcl(?zap_cmo_25E) ->    ?C_FORF_ZAP_CMO_25E;
zap_tcp_from_dcl(_) -> {[],[]}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Functions use in XML                   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type msisdn(session())-> [{pcdata,string()}].
%%%% Returns user's msisdn
msisdn(abs) -> [ {pcdata, "06 12 34 56 78"} ];
msisdn(#session{prof=#profile{msisdn="+33"++National}}) ->
    [C1,C2,C3,C4,C5,C6,C7,C8,C9]=National,
    Print=[$0,C1,32,C2,C3,32,C4,C5,32,C6,C7,32,C8,C9],
    [{pcdata, Print}];
msisdn(#session{prof=#profile{msisdn="+99"++National}}) ->
    
    [{pcdata, "0"++National}];
msisdn(#session{prof=#profile{msisdn={na, _}}}) ->
    slog:event(internal, ?MODULE, msisdn_not_available),
    %% This should not be allowed to happen, but continue anyway.
    [{pcdata, "?"}];
msisdn(#session{prof=#profile{msisdn=Msisdn}}) ->
    [{pcdata, Msisdn}].

%% *autograph([
%%     { path, ["../../posutils/src", "."]},
%%     { actions, [ 
%%                ] },
%%     { inits, [ {start,1},
%%                {start_light,1}
%%              ] }
%%   ]).

%% +type lienSiPromo(session(),Pcdata::string(),url(),string()) -> erlpage_result().
lienSiPromo(abs,PcData,Url,BR) ->
    [#hlink{href=Url, contents=[{pcdata, PcData}]}]++add_br(BR);
lienSiPromo(Session,PcData,Url,BR) ->
    State = svc_util_of:get_user_state(Session),
    case is_promo(State) of
	true  -> [#hlink{href=Url, contents=[{pcdata, PcData}]}]++add_br(BR);
	false -> []
    end.

is_promo(State) ->
    List_Promo=pbutil:get_env(pservices_orangef,promo_link),
    case get_next_promo(List_Promo,State) of
	no_link -> false;
	{_,_} -> true
    end.

add_br(X) -> svc_util_of:add_br(X).


%% *autograph([
%%     { path, ["../../posutils/src", "."]},
%%     { actions, [ 
%%                ] },
%%     { inits, [ {start,1},
%%                {start_light,1}
%%              ] }
%%   ]).
