%%%% Self care recharge page generator.

-module(svc_recharge_cmo).

-export([start/1,process_code/2]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").

-define(selfcare_cmo,"/orangef/selfcare_long/selfcare_cmo.xml").

-define(Tvalid_SMS_CMO,31).
-define(TCK_KEY_TYPE, "2").
-define(TTK_RECH_20E, 13).
-define(TTK_20E_messages, 124).
-define(CHOICE_20E_messages, 4).

% Checks state, and creates service data.
%% idem start_selfcare, except for state EP
%% +type start(session())-> erlpage_result().
start(abs) ->
    continue_recharge(abs) ++
	[ {redirect, abs, ?selfcare_cmo++"#temporary"} ];

start(#session{prof=Profile}=Session) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    continue_recharge(Session1);
	{stop, Session1, Reason} ->
	    {redirect, Session1, ?selfcare_cmo++"#temporary"}
    end.

%% +type continue_recharge(session())-> erlpage_result().
continue_recharge(abs)->
    determine_homepage(abs,"") ++
	[{redirect,abs,"#badprofil"},
	 {redirect,abs,?selfcare_cmo++"#temporary"}];

continue_recharge(#session{prof=#profile{subscription=S}=Profile}=Session) 
  when S=="cmo";S=="bzh_cmo";S=="virgin_comptebloque"->
    case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, State}  ->
	    NewSession=svc_util_of:update_user_state(Session_,State),
	    determine_homepage(NewSession, State);
	Error ->
	    %% This should not happen because we have already gone
	    %% through provisioning in svc_home.
	    {redirect, Session, ?selfcare_cmo++"#temporary"}
    end;
continue_recharge(Session) ->
    slog:event(trace, ?MODULE, not_cmo),
    {redirect, Session, "#badprofil"}.

%% +type determine_homepage(session(),sdp_user_state())-> erlpage_result().
determine_homepage(abs,State) ->
    [   {redirect, abs, "#ussd1cag"},
	{redirect, abs, "#cag"}
     ];
determine_homepage(#session{bearer={ussd,1}}=Session,State) ->
    {redirect, Session, "#ussd1cag"};
determine_homepage(#session{}=Session,State)->
     {redirect, Session, "#cag"}.

%% +type process_code(session(),CG::string())-> erlpage_result().
process_code(abs,_) ->
    do_recharge(abs,abs)++
	[{"cg_not_valid",{redirect, abs, "#bad_code"}},
	 {"user_entry_not_valid",{redirect, abs, "#bad_code_ph1"}},
	 {"user_entry_not_valid",{redirect, abs, "#bad_code_ph2"}}];
process_code(#session{prof=Profile}=Session,CG) ->
    case svc_util_of:is_valid(CG) of
	{nok, _} ->
	    case Session#session.bearer=={ussd,1} of
		true->{redirect, Session, "#bad_code_ph1"};
		false->{redirect, Session, "#bad_code_ph2"}
	    end;
	{ok, Code}  ->
	    do_recharge(Session,Code)
    end.

%%%% Do request of Rechargement
%% +type do_recharge(session(),string())-> erlpage_result().
do_recharge(abs,Code)->
    success_page(abs,"")++svc_recharge:recharge_error(abs,"");
do_recharge(#session{prof=Profile}=Session, Code)->
    Msisdn = Profile#profile.msisdn,
    State =svc_util_of:get_user_state(Session),
    State2 =State#sdp_user_state{tmp_code=Code},
    Session2 = svc_util_of:update_user_state(Session,State2),
    case svc_recharge:send_consult_rech_request(Session2, {mobi,Msisdn}, 
                                                ?TCK_KEY_TYPE, Code) of        
	{ok, Answer_tck} ->
	    case svc_recharge:get_ttk(Session, c_tck, Answer_tck) of
		?TTK_RECH_20E ->
		    slog:event(trace, ?MODULE, ticket_rech_20E),
		    {redirect,Session2,"#rech_20E_limitee"};
		?TTK_20E_messages ->
		    slog:event(trace, ?MODULE, ticket_rech_20E_messages),
		    svc_recharge:recharge_d6_and_redirect(
                      Session2,?CHOICE_20E_messages,"#rech_20E_messages");
		Else ->
		    Default_choice = 0,
		    case do_recharge_d6(Session2, Default_choice) of
			{ok, Session_new, Answer_d6} ->
			    success_page(Session_new, Answer_d6);
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			_ ->
			    {redirect, Session, "#system_failure"}
		    end
	    end;
	Else ->
            slog:event(failure, ?MODULE, do_recharge_error, {Else,Msisdn}),
	    {redirect, Session, "#system_failure"}
    end.
                    

%%%% Do request of Rechargement
%% +type do_recharge_d6(session(),string())-> tuple().
do_recharge_d6(#session{prof=Profile}=Session, Choice) ->
    Profile = Session#session.prof,
    Msisdn = Profile#profile.msisdn,
    Choice1 = if list(Choice) -> list_to_integer(Choice);
		 true -> Choice
	      end,
    State =svc_util_of:get_user_state(Session),
    Code = State#sdp_user_state.tmp_code,
    svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                                       pbutil:unixtime(),Choice1).

%%%%%%%%%%%%%%%%% VERSION WITH REQUEST D4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type success_page(session(),term())-> erlpage_result().
success_page(abs,"")->
    [{redirect,abs,"#sucess_cpte"},
     {redirect,abs,"#sucess_erech_europe"},
     {redirect,abs,"#sucess_erech_maghreb"},
     {redirect,abs,"#sucess_erech_smsmms"},
     {redirect,abs,"#sucess_sms"},
     {redirect,abs,"#sucess_cpte_sms"},
     {redirect,abs,"recharge.xml#success_vacances"}
]++do_weinf_souscription(abs);
success_page(#session{prof=Prof}=Session,
		[DLV, TTK_NUM, CTK_NUM,TTK_VAL,Zones60]=Infos)->
    % Recup TCP_NUM of Cpte Recharged to redirect
    TCPs = lists:sort(lists:map(fun([TCP_NUM|T])-> TCP_NUM end, Zones60)),
    send_success_page(Session, TCPs, CTK_NUM);
success_page(#session{prof=Prof}=Session,Resp_params) ->
    CTK_NUM = svc_util_of:get_param_value("CTK_NUM", Resp_params),
    COMPTES = svc_util_of:get_param_value("CPT_PARAMS", Resp_params),
    % Recup TCP_NUM of Cpte Recharged to redirect
    TCPs = lists:sort(lists:map(fun([TCP_NUM|T])-> list_to_integer(TCP_NUM) end, COMPTES)),
    send_success_page(Session, TCPs, list_to_integer(CTK_NUM)).

send_success_page(#session{prof=Prof}=Session2, TCPs, CTK_NUM) ->
    %% en fonction des cpte MAJ retourner un page spécifique
    case {TCPs,CTK_NUM,Prof#profile.subscription} of
	{_,?RECHARGE_WEINF,"cmo"}->
	    do_weinf_souscription(Session2);
	{_,?RECHARGE_EUROPE,"cmo"}->
	    {redirect,Session2,"#sucess_erech_europe"};
	{_,?RECHARGE_MAGHREB,"cmo"}->
	    {redirect,Session2,"#sucess_erech_maghreb"};
	{_,?RECHARGE_SMSMMS,"cmo"}->
	    {redirect,Session2,"#sucess_erech_smsmms"};
	{_,?RECHARGE_VACANCES,_}->
	    {redirect,Session2,"#success_vacances"};
	{[?C_PRINC],_,_}->
	    {redirect,Session2,"#sucess_cpte"};
	{[?C_ASMS],_,_}->
	    {redirect,Session2,"#sucess_sms"};
	{[?C_PRINC,?C_ASMS],_,_}->
	    {redirect,Session2,"#sucess_cpte_sms"};
	{[?C_PRINC,?C_SMS],_,_}->
	    {redirect,Session2,"#sucess_cpte_sms"};
	{A,_,_}->
	    %% By Default return Only cpte Princ 
	    slog:event(warning,?MODULE,unknown_recharge_type,A),
	    {redirect,Session2,"#sucess_cpte"}
    end.

%% +type do_weinf_souscription(session())-> erlpage_result().
do_weinf_souscription(abs)->
    [{redirect,abs,"#weinf_deja_actif"},
     {redirect,abs,"#succes_weinf"},
     {redirect,abs,"#succes_weinf_ss_souscription"}];
do_weinf_souscription(Session)->
    State = svc_options:check_topnumlist(Session),
    Session_new = svc_util_of:update_user_state(Session,State),
    case svc_options:is_option_activated(Session_new,opt_weinf) of
	true->
	    {redirect,Session_new,"#weinf_deja_actif"};
	false->
	    {Session2,Result} = svc_options:do_opt_cpt_request(Session_new,opt_weinf,subscribe),
	    case Result of
		{ok_operation_effectuee,_} ->
		    %% mettre a jour le compte princ
		    %% retirer 10E du compte principal
		    {redirect,Session2,"#succes_weinf"}; %% #success ferme la session
		{nok_opt_deja_existante,""} ->
		    {redirect,Session2,"#weinf_deja_actif"};
                {error, "option_deja_existante"} ->
		    {redirect,Session2,"#weinf_deja_actif"};
		_ ->
		  {redirect, Session2, "#succes_weinf_ss_souscription"}
	    end
    end.
