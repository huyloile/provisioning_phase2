-module(unit_test).
-compile(export_all).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").

create_dummy_session(Msisdn, Sub) ->
    State = #sdp_user_state{},
    Session = #session{prof = #profile{msisdn = Msisdn, subscription=atom_to_list(Sub)}, svc_data=State},  
    Dos_numid = svc_sachem:get_dos_numid(Session),
    variable:update_value(Session, user_state, 
                          #sdp_user_state{dos_numid=Dos_numid}).

sachem_subscribe(Msisdn, Sub, Opt) when atom(Sub), atom(Opt)->
    Session = create_dummy_session(Msisdn, Sub),
    State = svc_util_of:get_user_state(Session),
    case svc_sachem:consult_account(Session) of
        {ok, {S, Resp_params}}->
            ReqInit = svc_options:option_params(Opt, Sub, subscribe),
            ReqTypeAction = svc_options:add_type_action(S, Opt, ReqInit, subscribe),
            ReqMntInit = svc_options:add_mnt_initial(S, Opt, ReqTypeAction),
            Request = svc_options:add_msisdn(State, subscribe, ReqMntInit,Opt),
            case svc_sachem:update_account_options(S, Request) of
                {ok, {Session_new, Resp}} -> 
                    {ok, Resp};
                Error_maj_opt->
                    Error_maj_opt
            end;
        Error_consult->
            Error_consult
    end;

sachem_subscribe(Msisdn, Sub, [Opt1|Opts]) when atom(Sub) ->
    Session = create_dummy_session(Msisdn, Sub),
    State = svc_util_of:get_user_state(Session),
    case svc_sachem:consult_account(Session) of
        {ok, {S, Resp_params}}->
            ReqInit = svc_options:option_params(Opt1, Sub, subscribe),
            ReqTypeAction = svc_options:add_type_action(S, Opt1, ReqInit, subscribe),
            ReqMntInit = svc_options:add_mnt_initial(S, Opt1, ReqTypeAction),
            Request = svc_options:add_msisdn(State, subscribe, ReqMntInit,Opt1),
            do_nopt_cpt_request(S,Opts,[Request],Opt1);
        Error_consult->
            Error_consult
    end.

do_nopt_cpt_request(#session{prof=Prof}=S,[],Request,Option)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    case svc_sachem:handle_options(S, Request) of
        {ok, {Session_resp, Resp_params}}->
            {ok, Resp_params};
        Error_maj_nopt->
            Error_maj_nopt
    end;

do_nopt_cpt_request(#session{prof=Prof}=S,[Opt1|Opt],Opt_params,Option)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqInit = svc_options:option_params(Opt1, Sub, subscribe),
    ReqTypeAction = svc_options:add_type_action(S, Opt1, ReqInit, subscribe),
    ReqMntInit = svc_options:add_mnt_initial(S, Opt1, ReqTypeAction),
    Request = svc_options:add_msisdn(State, subscribe, ReqMntInit,Opt1),
    do_nopt_cpt_request(S,Opt, [Request|Opt_params],Option).
