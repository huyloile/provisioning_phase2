-module(test_svc_sachem).
-compile(export_all).
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/tlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/pserver.hrl").
-include("sachem.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% These offline functions use sachem_offline.erl
%%%% You need to set pfront_orangef:sachem_version= offline and compile
%%%% The aim of these tests are to validate input parameters
%%%% They do not validate output parameters!
run() ->    
    application:start(pservices_orangef),
    application:start(pfront_orangef),
    %% currently uses Sachem_fake

    %%%% functions related to consult_account request
    %%%% OK
    consult_account(),     
    update_sachem_user_state(),
    get_options_list(),          
    get_dos_numid(),

    %%%% functions related to consult_account_options request
    consult_account_options(), 
    consult_options_list(),
    consult_options_info(),
    consult_option_info(), 
    consult_msisdn_list(),

    %%%% functions related to Ticket recharge
    consult_recharge_ticket(), 
    recharge_ticket(),  

    %%%% functions related to change_user_account request
    change_user_account(),

    %%%% functions related to update_account_options request
    update_account_options(),

    %%%% functions related to handle_options request
    handle_options(),

    %%%% functions related to transfert_credit request
    transfer_credit(), %% We have to fill the answer

    %%%% NOT EXPORTED FUNCTIONS
%%    filled_opt_cpt(),
%%    update_optional_values(),

    ok.

create_dummy_session() ->
    Session = #session{prof = #profile{msisdn = "0612345678"}},  
    variable:update_value(Session, user_state, 
                          #sdp_user_state{dos_numid=123456789}).

create_dummy_session(Msisdn) ->
    Session = #session{prof = #profile{msisdn = Msisdn}},  
    Dos_numid = svc_sachem:get_dos_numid(Session),
    variable:update_value(Session, user_state, 
                          #sdp_user_state{dos_numid=Dos_numid}).


%% How to test Crash cases ?
consult_account() ->
    io:format("~n*** test_svc_sachem:consult_account()~n"),
    Session = create_dummy_session(),
    {ok, {Session_resp1, Resp_params1}} = 
        svc_sachem:consult_account(Session),
    {ok, {Session_resp2, Resp_params2}} = 
        svc_sachem:consult_account(Session, "0"),    
    {ok, {Session_resp3, Resp_params3}} = 
        svc_sachem:consult_account(Session, {"1", "999000900000001"}),
    {ok, {Session_resp4, Resp_params4}} = 
        svc_sachem:consult_account(Session, {"1", "999000900000001"}, "0"),
    check_different(Session_resp1, Session).
    

%   svc_sachem:consult_account(Session, "0", "5", hola). %% Crashes OK

update_sachem_user_state() ->
    io:format("~n*** test_svc_sachem:update_sachem_user_state()~n"),
    Session = create_dummy_session(),
    State = svc_util_of:get_user_state(Session), 
    State1 = svc_sachem:update_sachem_user_state(Session),
    erlang:is_record(State1, sdp_user_state),
    check_different(State, State1),        
    
    {ok, {Session_resp, Resp_params}} = svc_sachem:consult_account(Session),
    State2 = svc_sachem:update_sachem_user_state(Session, Resp_params),
    erlang:is_record(State2, sdp_user_state), 
    check_different(State, State2).

%%%% Obsolete function
get_options_list() ->
    ok.
%%     Session = create_dummy_session(),
%%     {options, List}  = svc_sachem:get_options_list(Session).

get_dos_numid()->
    Session = create_dummy_session(),
    Dos_numid = svc_sachem:get_dos_numid(Session),
    integer_to_list(Dos_numid). %% to check that it returns an integer
           
consult_account_options()->
    io:format("~n*** test_svc_sachem:consult_account_options()~n"),
    Session = create_dummy_session(),
    {ok, {Session1, Resp_param1}} = 
        svc_sachem:consult_account_options(Session),
    {ok, {Session2, Resp_param2}} = 
        svc_sachem:consult_account_options(Session,12345678987),
    {ok, {Session3, Resp_param3}} = 
        svc_sachem:consult_account_options(Session, {"25", "5"}),
    {ok, {Session4, Resp_param4}} = 
        svc_sachem:consult_account_options(Session, 12345678987, {"25", "5"}).  

consult_options_list() ->
    io:format("~n*** test_svc_sachem:consult_options_list()~n"),
    Session = create_dummy_session(),
    {Session_,Answer} = svc_sachem:consult_options_list(Session),
    if list(Answer) -> ok end.
            

consult_options_info() ->
    io:format("~n*** test_svc_sachem:consult_options_info()~n"),
    Session = create_dummy_session(),
    List_options = svc_sachem:consult_options_info(Session),
    is_list(List_options).

consult_option_info() ->
    io:format("~n*** test_svc_sachem:consult_option_info()~n"),
    Session = create_dummy_session(),
    svc_sachem:consult_option_info(Session, "5").   

consult_msisdn_list() ->
    io:format("~n*** test_svc_sachem:consult_msisdn_list()~n"),
    Session = create_dummy_session(),
    List_msisdn = svc_sachem:consult_msisdn_list(Session),
    is_list(List_msisdn).

%% get_options_info() ->
%%     Session = create_dummy_session(),
%%     List_msisdn = svc_sachem:get_options_info(Session),
%%     is_list(List_msisdn).

consult_recharge_ticket() ->
    io:format("~n*** test_svc_sachem:consult_recharge_ticket()~n"),
    Session = create_dummy_session(),
    {ok, {_, Resp_params}}  = 
        svc_sachem:consult_recharge_ticket(Session, "12345678901234"),
    {ok, {_, Resp_params2}} = 
        svc_sachem:consult_recharge_ticket(Session, "12345678901234", "0612345678").

%%%% REC_TCK
recharge_ticket() ->
    io:format("~n*** test_svc_sachem:recharge_ticket()~n"),
    Session = create_dummy_session(),

    %% Consult_account to get the initial accounts state
    {ok, State_CSL_DOSCP} = 
        svc_sachem:update_sachem_user_state(Session),
    Session_CSL_DOSCP = svc_util_of:update_user_state(Session, State_CSL_DOSCP),
    Compte_princ_CSL_DOSCP = State_CSL_DOSCP#sdp_user_state.cpte_princ,
    Compte_list_CSL_DOSCP  = State_CSL_DOSCP#sdp_user_state.cpte_list,
    Etat_compte_princ_CSL_DOSCP = Compte_princ_CSL_DOSCP#compte.etat,

    %% Refill accounts
    {ok, {Session_REC_TCK,Resp_REC_TCK}} = 
        svc_sachem:recharge_ticket(Session_CSL_DOSCP, "12345678901234"),
    {ok, {Session_REC_TCK,Resp_REC_TCK}} = 
        svc_sachem:recharge_ticket(Session_CSL_DOSCP, "12345678901234","1"),
    {ok, {Session_REC_TCK,Resp_REC_TCK}} = 
        svc_sachem:recharge_ticket(Session_CSL_DOSCP, "12345678901234", 1),

    State_REC_TCK = svc_util_of:get_user_state(Session_REC_TCK),
    Compte_princ_REC_TCK = State_REC_TCK#sdp_user_state.cpte_princ,
    Compte_list_REC_TCK  = State_REC_TCK#sdp_user_state.cpte_list,
    Etat_compte_princ_REC_TCK = Compte_princ_REC_TCK#compte.etat,

    %% Check that the compte Principale has changed after Refill
    check_different(Compte_princ_REC_TCK, Compte_princ_CSL_DOSCP),
    %% in sachem_offline we decided to refill cpte_princ only
    Compte_list_REC_TCK = Compte_list_CSL_DOSCP,
    %% As we started with an Active State, it should be the same after the refill
    Etat_compte_princ_CSL_DOSCP = Etat_compte_princ_REC_TCK,
    %% Check that the PCT and MONT_BONUS have been updated from REC_TCK
    check_different(Compte_princ_CSL_DOSCP#compte.pct,
                    Compte_princ_REC_TCK#compte.pct),
    check_different(Compte_princ_CSL_DOSCP#compte.mnt_bonus,
                    Compte_princ_REC_TCK#compte.mnt_bonus).

change_user_account() ->
    io:format("~n*** test_svc_sachem:change_user_account()~n"),
    Session = create_dummy_session(),
    Compte = #compte{tcp_num="200"},
    svc_sachem:change_user_account(Session, Compte).

update_account_options() ->
    io:format("~n*** test_svc_sachem:update_account_options()~n"),
    Session = create_dummy_session(),
    %%State#sdp_user_state.dos_numid
    Opt_cpt = #opt_cpt_request{type_action = "A", top_num=5},
    svc_sachem:update_account_options(Session, Opt_cpt).    

handle_options() ->
    io:format("~n*** test_svc_sachem:handle_options()~n"),
    Session = create_dummy_session(),
    Opt_cpt = #opt_cpt_request{type_action = "A", 
                               top_num="5"},
    {ok, {Session_resp, Resp_params}} = 
        svc_sachem:handle_options(Session,[Opt_cpt]),
    {ok, {Session_resp, Resp_params}} = 
        svc_sachem:handle_options(Session,[Opt_cpt,Opt_cpt]),
    {ok, {Session_resp, Resp_params}} = 
        svc_sachem:handle_options(Session,[Opt_cpt,Opt_cpt,[]]).

transfer_credit() ->
    io:format("~n*** test_svc_sachem:transfer_credit()~n"),
    Session = create_dummy_session(),    
    Compte = #compte{},
    Session_cpte = variable:update_value(Session, user_state, 
                                         #sdp_user_state{cpte_princ=Compte}),
    {ok, {Session_resp, Resp_params}} = 
        svc_sachem:transfer_credit(Session_cpte, "0612345678", "0698765432").    
    
filled_opt_cpt() ->
    Opt_cpt = #opt_cpt_request{},
    [#opt_cpt_request{}] = svc_sachem:filled_opt_cpt([Opt_cpt]),    
    [#opt_cpt_request{}] = svc_sachem:filled_opt_cpt([Opt_cpt,[]]),
    [#opt_cpt_request{}, #opt_cpt_request{}] = svc_sachem:filled_opt_cpt([Opt_cpt,Opt_cpt,[]]).

update_optional_values() ->
    Compte = #compte{etat="", dlv=undefined, cpt_dest="-", ptf_num=5},
    %% cmo expect DLV = "-1"
    State_cmo = #sdp_user_state{cpte_princ=Compte, declinaison=?m6_cmo},

    Result = svc_sachem:update_optional_values(State_cmo, Compte),
    [ECP_NUM, CPP_DATE_LV_CMO | Remain] = Result,
    io:format("test_svc_sachem:Result:~p~nDLV_CMO:~p~n",[Result, CPP_DATE_LV_CMO]),
    CPP_DATE_LV_CMO = "-1",
    %% mobi expect DLV = "-1"
    State_mobi = #sdp_user_state{cpte_princ=Compte, declinaison=?mobi},
    [ECP_NUM, CPP_DATE_LV_MOBI | Remain] = 
        svc_sachem:update_optional_values(State_mobi, Compte),
    io:format("test_svc_sachem:Result:~p~nDLV_Mobi:~p~n",[Result, CPP_DATE_LV_MOBI]),
    CPP_DATE_LV_MOBI = "-1".
    

check_different(Param1, Param2) ->
    case Param1 of
        Param1 when Param1 /= Param2 ->
            ok
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    io:format("Online test_svc_sachem~n~n"),
     test_util_of:online(?MODULE,test()).


%%% SACHEM x25
test() ->
    [{title, "Online Test for Sachem queries"}] ++ %%THESE TESTS DO NO CRASH WHEN ERROR!!!!
        
	[].

