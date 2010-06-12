%%%% Rechargement Tele2, similaire a OrangeF

-module(svc_recharge_tele2).

-compile(export_all).
%-export([process_code/8,verif_no_prefere/2,do_confirm/2,print_numpref/1,print_numpref_list/1]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/tele2.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

-define(TCK_KEY_TYPE, "2").
-define(TTK_sl_15E_casino, 1).
-define(TTK_sms_illm, 161).
-define(TTK_roaming,  162).
-define(Max_nums_preferes, 10).


%%%% function checking the code format and validity
%% +type process_code(session(),Service::string(), 
%%                    Link_ok::string(), Link_ko::string(), 
%%                    Link_ok_sms::string(), Code::string())
%%                    -> erlpage_result().
process_code(abs,_,Link_ok, Link_ok_roaming, Link_ok_sms, Link_ko,_) ->
    [{redirect, abs, Link_ok},
     {redirect, abs, Link_ok_roaming},
     {redirect, abs, Link_ok_sms},
     {redirect, abs, Link_ko}];
process_code(#session{prof=Profile}=Session, Service, Link_ok, 
             Link_ok_roaming, Link_ok_sms,  Link_ko, Code)
  when Service == "tele2" ->
    case svc_util_of:is_valid(Code) of
	{nok, Reason} ->
	    case Session#session.bearer=={ussd,1} of
		true -> {redirect, Session, Link_ko};
		false-> {redirect, Session, Link_ko}
	    end;
	{ok, Code}  ->
	    do_recharge(Session,Code, Link_ok, Link_ok_roaming, Link_ok_sms)
    end;
process_code(Session, Service, Link_ok, Link_ok_roaming, Link_ok_sms,
             Link_ko, Code) ->
    slog:event(internal, ?MODULE, unknown_service, Service),
    {redirect, Session, Link_ko}.

%%%% function checking the code format and validity
%% +type process_code(session(),Service::string(), 
%%                    Link_ok::string(), Link_ko::string(), 
%%                    Link_ok_sms::string(), Code::string())
%%                    -> erlpage_result().
process_code(abs,_,Link_ok, Link_ok_roaming, Link_ok_sms, Link_ok_casino, Link_ko,_) ->
    [{redirect, abs, Link_ok},
     {redirect, abs, Link_ok_roaming},
     {redirect, abs, Link_ok_sms},
     {redirect, abs, Link_ok_casino},
     {redirect, abs, Link_ko}];
process_code(#session{prof=Profile}=Session, Service, Link_ok, 
             Link_ok_roaming, Link_ok_sms, Link_ok_casino, Link_ko, Code)
  when Service == "tele2" ->
    case svc_util_of:is_valid(Code) of
	{nok, Reason} ->
	    case Session#session.bearer=={ussd,1} of
		true -> {redirect, Session, Link_ko};
		false-> {redirect, Session, Link_ko}
	    end;
	{ok, Code}  ->
	    do_recharge(Session,Code, Link_ok, Link_ok_roaming, Link_ok_sms, Link_ok_casino)
    end;
process_code(Session, Service, Link_ok, Link_ok_roaming, Link_ok_sms, Link_ok_casino,
             Link_ko, Code) ->
    slog:event(internal, ?MODULE, unknown_service, Service),
    {redirect, Session, Link_ko}.


%%%% Do request of Rechargement
%%do_recharge/7
%% +type do_recharge(session(),Code::string(), Link_ok::string(),
%%                   Link_ok_sms::string())
%%                  -> erlpage_result().
do_recharge(abs, _, Link_ok, Link_ok_roaming, Link_ok_sms)->
    [{redirect,abs, Link_ok},
     {redirect, abs, Link_ok_roaming},
     {redirect, abs, Link_ok_sms}];
do_recharge(#session{prof=Profile}=Session,Code, Link_ok,
            Link_ok_roaming, Link_ok_sms)->
    Msisdn = Profile#profile.msisdn,
    Sub = Profile#profile.subscription,
    case svc_recharge:send_consult_rech_request(Session, {list_to_atom(Sub),Msisdn}, 
                                   ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    case svc_recharge:get_ttk(Session, c_tck, Answer_tck) of
		?TTK_roaming ->
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),0) of
                        {ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok_roaming};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request_roaming, 
                                       Error),
                            {redirect, Session, "#system_failure"}
		    end;
		?TTK_sms_illm ->
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),0) of
			{ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok_sms};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request_sms_ill, 
                                       Error),
                            {redirect, Session, "#system_failure"}
		    end;
		_ -> 
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),0) of
			{ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request, 
                                       Error),
                            {redirect, Session, Link_ok_sms}
		    end
	    end;
	Else ->
	    slog:event(failure, ?MODULE, do_recharge, Else),
	    {redirect, Session, "#system_failure"}
    end.


%%%% Do request of Rechargement
%%do_recharge/7
%% +type do_recharge(session(),Code::string(), Link_ok::string(),
%%                   Link_ok_sms::string())
%%                  -> erlpage_result().
do_recharge(abs, _, Link_ok, Link_ok_roaming, Link_ok_sms, Link_ok_casino)->
    [{redirect,abs, Link_ok},
     {redirect, abs, Link_ok_roaming},
     {redirect, abs, Link_ok_sms},
     {redirect, abs, Link_ok_casino}];
do_recharge(#session{prof=Profile}=Session,Code, Link_ok,
            Link_ok_roaming, Link_ok_sms, Link_ok_casino)->
    Msisdn = Profile#profile.msisdn,
    Sub = Profile#profile.subscription,
    case svc_recharge:send_consult_rech_request(Session, {list_to_atom(Sub),Msisdn}, 
                                   ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    case svc_recharge:get_ttk(Session, c_tck, Answer_tck) of
		?TTK_roaming ->
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),0) of
                        {ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok_roaming};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request_roaming, 
                                       Error),
                            {redirect, Session, "#system_failure"}
		    end;
		?TTK_sms_illm ->
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),0) of
			{ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok_sms};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request_sms_ill, 
                                       Error),
                            {redirect, Session, "#system_failure"}
		    end;
		?TTK_sl_15E_casino ->
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),1) of
			{ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok_casino};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request_sl_15E_casino, 
                                       Error),
                            {redirect, Session, "#system_failure"}
		    end;
		_ -> 
                    case svc_recharge:send_recharge_request(
                           Session, 
                           {list_to_atom(Sub),Msisdn}, Code, pbutil:unixtime(),0) of
			{ok, Session_new, Infos} ->
                            {redirect, Session_new, Link_ok};
			{error, Error} ->
			    svc_recharge:recharge_error(Session,Error);
			Error ->
                            slog:event(failure, ?MODULE, 
                                       send_recharge_request, 
                                       Error),
                            {redirect, Session, Link_ok_sms}
		    end
	    end;
	Else ->
	    slog:event(failure, ?MODULE, do_recharge, Else),
	    {redirect, Session, "#system_failure"}
    end.

update_decode_z80(Session, Resp_params, Zone80, Opt) when atom(Opt) ->
    case Zone80 of
        [] -> Session;
        undefined -> Session;
        List when list(Zone80) ->
            State = svc_util_of:get_user_state(Session),
            NZone80 = update_z80(Zone80, Session, Opt),
            StateZ80 = svc_compte:decode_z80(NZone80,State),
            svc_util_of:update_user_state(Session,StateZ80)
    end.


update_z80(Zone80, #session{prof=Profile}=Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    Subs = Profile#profile.subscription,
    NumPref = State#sdp_user_state.numero_prefere,
    MSISDN_MEMBER = NumPref,
    OPTL_RANG = 0,
    MSISDN_TOP_NUM = svc_options:top_num(Opt, list_to_atom(Subs)),
    MSISDN_TCP_NUM = svc_options:tcp_num(Opt, list_to_atom(Subs)),
    MSISDN_PTF_NUM = svc_options:ptf_num(Opt, list_to_atom(Subs)),
    MSISDN_RNV_NUM = 0,
    NZone80 =[[MSISDN_MEMBER,OPTL_RANG,MSISDN_TOP_NUM,MSISDN_TCP_NUM,MSISDN_PTF_NUM,MSISDN_RNV_NUM]],
    case length(Zone80) of 
	?Max_nums_preferes ->
	    [[Msisdn_sousr|_]|Tail]= Zone80,
	    NZone80++Tail;
	_ ->
	    Zone80++NZone80
    end.

do_opt_cpt_req_numpref(Session, Zone80) ->
    State = svc_util_of:get_user_state(Session),
    List = State#sdp_user_state.numpref_list,
    case List of 
        undefined -> 
            do_opt_cpt_request(Session,opt_numpref_tele2,terminate);
        _ ->
            case length(List) of
                ?Max_nums_preferes -> 
                    NumPref =  State#sdp_user_state.numero_prefere,
                    IsFirstPos = (NumPref==lists:nth(1,List)),
                    case IsFirstPos of 
                        true -> 
                            [[Msisdn|_]|_] = Zone80,
                            [NumPref|Tail] = List,
                            NList = [Msisdn]++Tail,
                            NState = State#sdp_user_state{numpref_list = NList},
                            NSession = svc_util_of:update_user_state(Session, NState),
                            do_opt_cpt_request(NSession,opt_numpref_tele2,modify);
                        _ ->
                            do_opt_cpt_request(Session,opt_numpref_tele2,terminate)
                    end;
                _ ->
                    do_opt_cpt_request(Session,opt_numpref_tele2,terminate)
            end
    end.
    
update_user_state_numpref_list(Session)->
    case svc_util_of:do_consultation(Session, opt_numpref_tele2) of
	{ok,[Zone70, Zone80, _]} ->
	    State = svc_util_of:get_user_state(Session),
	    NState = case Zone80 of 
			 L_VIDE when L_VIDE==[];L_VIDE==[[]] -> State;
			 _ ->
			     svc_compte:decode_z80(Zone80,State)
		     end;
        {ok, {Session_new, Resp_params}} ->
            Zone80 = svc_sachem:get_msisdns_info(Resp_params),
	    State = svc_util_of:get_user_state(Session),
	    NState = case Zone80 of 
			 L_VIDE when L_VIDE==[];L_VIDE==[[]] -> State;
			 _ ->
			     svc_compte:decode_z80(Zone80,State)
		     end;
        {nok, Reason} ->
	    slog:event(failure,?MODULE,do_consultation_numpref,Reason),
	    State = svc_util_of:get_user_state(Session);
	Error ->
	    slog:event(failure,?MODULE,update_user_state_numpref_list,Error),
	    State = svc_util_of:get_user_state(Session)
    end.

print_numpref(abs)->
    [{pcdata,"06XXXXXXXX"}];
print_numpref(Session) ->
    State = svc_util_of:get_user_state(Session),
    List = State#sdp_user_state.numpref_list,
    case length(List) of
	undefined ->
	    [{pcdata,"inconnu"}];
	_ ->
	    [{pcdata, lists:last(List)}]
    end.

print_numpref_list(abs)->        
    [{pcdata,"06XXXXXXXX, 06XXXXXXXX,..."}];
print_numpref_list(Session) ->
    State = update_user_state_numpref_list(Session),
    List = State#sdp_user_state.numpref_list,
    case List of
	 undefined ->
            [{pcdata,"inconnu"}];
	_->
	    case length(List) of
		undefined -> 
		    [{pcdata,"inconnu"}];
		1 ->
		    [{pcdata,lists:last(List)}];
		_ ->
		    [{pcdata, get_numpref(List)}]
	    end
    end.

get_numpref([]) -> "";
get_numpref([H|T]) ->
    H++", "++get_numpref(T).
    
do_opt_cpt_request(#session{prof=Prof}=S,Opt,Action)
  when Opt==opt_numpref_tele2->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqInit = svc_options:option_params(Opt, Sub, Action),
    ReqCout = svc_options:add_cout(S, Opt, ReqInit),
    ReqTypeAction = svc_options:add_type_action(S, Opt, ReqCout, Action),    
    ReqMntInit = svc_options:add_mnt_initial(S, Opt, ReqTypeAction),
    Request = add_msisdn(State, Action, ReqMntInit, Opt),
    Result = svc_options:send_update_account_options(S, {Sub,Msisdn},
                                            Action, Request),
    NewSession = case Result of
                     {ok_operation_effectuee,Session_resp,_} ->
			 Session_resp;
                     _ ->
                         S
                 end,
    {NewSession,Result}.

add_msisdn(State, Action, Req,Opt=opt_numpref_tele2) ->    
    List = State#sdp_user_state.numpref_list,    
    case List of 
	undefined -> 
	    NumPref = State#sdp_user_state.numero_prefere,
	    Req#opt_cpt_request{msisdn1 = NumPref};
	_ ->
	    case length(List) of
		1 ->
		    Req#opt_cpt_request{msisdn1 = lists:nth(1,List)};
		2 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List)};
		3 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List)};
		4 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List)};
		5 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List),
		      msisdn5 = lists:nth(5,List)};
		6 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List),
		      msisdn5 = lists:nth(5,List),
		      msisdn6 = lists:nth(6,List)};
		7 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List),
		      msisdn5 = lists:nth(5,List),
		      msisdn6 = lists:nth(6,List),
		      msisdn7 = lists:nth(7,List)};
		8 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List),
		      msisdn5 = lists:nth(5,List),
		      msisdn6 = lists:nth(6,List),
		      msisdn7 = lists:nth(7,List),
		      msisdn8 = lists:nth(8,List)};
		9 ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List),
		      msisdn5 = lists:nth(5,List),
		      msisdn6 = lists:nth(6,List),
		      msisdn7 = lists:nth(7,List),
		      msisdn8 = lists:nth(8,List),
		      msisdn9 = lists:nth(9,List)};
		_ ->
		    Req#opt_cpt_request{
		      msisdn1 = lists:nth(1,List),
		      msisdn2 = lists:nth(2,List),
		      msisdn3 = lists:nth(3,List),
		      msisdn4 = lists:nth(4,List),
		      msisdn5 = lists:nth(5,List),
		      msisdn6 = lists:nth(6,List),
		      msisdn7 = lists:nth(7,List),
		      msisdn8 = lists:nth(8,List),
		      msisdn9 = lists:nth(9,List),
		      msisdn10 = lists:nth(10,List)}
	    end
    end.

