%%%% Rechargement Eskimo

-module(svc_recharge_eskimo).
-export([process_code/4]).
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").

-define(TCK_KEY_TYPE, "2").
-define(CHOICE_LIST,[{143,1},
		     {144,1},
		     {145,1},
		     {146,1},
		     {147,1},
		     {148,1},
		     {149,2},
		     {150,2},
		     {151,2},
		     {152,2},
		     {153,2},
		     {154,2},
		     {155,3},
		     {156,3},
		     {157,3},
		     {158,3},
		     {159,3},
		     {160,3}]
       ).


process_code(abs,Link_ok,Link_ko,_)->
    [{redirect, abs, Link_ok},
     {redirect, abs, Link_ko}];

process_code(#session{prof=Profile}=Session,Link_ok, Link_ko, Code) ->
    case svc_util_of:is_valid(Code) of
	{nok, Reason} ->
	    case Session#session.bearer=={ussd,1} of
		true -> {redirect, Session, Link_ko};
		false-> {redirect, Session, Link_ko}
	    end;
	{ok, Code}  ->
	    do_recharge(Session,Code,Link_ok, Link_ko)
    end.

check_option(Session, Infos, Link_ok, Link_ko)->
    case svc_sachem:consult_account_options(Session) of
        {nok, _} ->
            {redirect, Session, Link_ko};
        {ok, {OkSession, Resp_params}} ->
            case svc_options:state(OkSession,opt_frais_maint) of
                suspend ->
                    subscribe_opt(OkSession,opt_frais_maint, Infos, Link_ok);
                _ ->
                    {redirect, OkSession, Link_ok}
            end
    end.

check_ttk_num_value(TTK_NUM) ->
    case lists:keysearch(TTK_NUM, 1, ?CHOICE_LIST) of
        {value, {TTK_NUM, Choice}} -> 
            {ok, Choice};
        _ ->
            slog:event(failure,?MODULE,unknown_ttk_num,{TTK_NUM}),
            {nok, undefined}
    end.

%% +type do_recharge(session(),Code::string(), Link_ok::string())
%%                  -> {nok, undefined}|{ok, string()}.
%%%% Do request of Rechargement
do_recharge(abs, _, Link_ok, Link_ko)->
    [{redirect,abs, Link_ok}];
do_recharge(#session{prof=Profile}=Session, Code, Link_ok, Link_ko)->
    Msisdn = Profile#profile.msisdn,
    Sub = Profile#profile.subscription,
    case svc_recharge:send_consult_rech_request(Session, 
                                                {list_to_atom(Sub),Msisdn}, 
                                                ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} -> 
            TTK_NUM = svc_recharge:get_ttk(Session, c_tck, Answer_tck),
            case check_ttk_num_value(TTK_NUM) of
                {ok, Choice} ->
                    case svc_recharge:send_recharge_request(Session, 
                                                            {list_to_atom(Sub),Msisdn}, 
                                                            Code, pbutil:unixtime(), Choice) of
                        {ok, Session_new, Infos} ->
                            check_option(Session_new, Infos, Link_ok,Link_ko);
                        {error, {status, [10,X]}} when X>=4,  X<10 ->
                            {redirect, Session, "#bad_code1"};
                        {error, Status} when Status=="autres_erreurs_recharge";
                                             Status=="ticket_recharge_inconnu";
                                             Status=="ticket_recharge_invalide" ->
                            slog:event(service_ko, ?MODULE, recharge_error_code, 
                                       Status),
                            {redirect, Session, "#bad_code1"};
                        Error ->
                            slog:event(failure, ?MODULE, send_recharge_req, Error),
                            {redirect, Session, "#system_failure"}                        
                    end;
                _ ->
                    {redirect, Session, "#system_failure"}
            end;
	Error ->
            slog:event(failure, ?MODULE, do_recharge_error, {Error, Msisdn}),
	    {nok, undefined}
    end.

%%%%Update the solde in Z60
%% +type update_solde(Zones60::list())->Zones60_1::list().
update_solde([[TCP_NUM,UNT_NUM,CPP_SOLDE,DLV,RNV,ECP_NUM,
	       PTF_NUM,CPP_CUMUL,PCT,ANC,MNT_INIT,TOP_NUM,MNT_BON]|T]=Zones60)->
    {value,{_,FraisMaint}}=lists:keysearch(opt_frais_maint, 1,
			       svc_util_of:get_env(subscription_price_symacom)),
    [[TCP_NUM,UNT_NUM,CPP_SOLDE-FraisMaint,DLV,RNV,ECP_NUM,
	       PTF_NUM,CPP_CUMUL,PCT,ANC,MNT_INIT,TOP_NUM,MNT_BON]|T];    
update_solde(Else) ->
    slog:event(service_ko,?MODULE,cannot_update_solde,Else),
    Else.
subscribe_opt(Session,opt_frais_maint, Infos, Link_ok)->
    case  svc_options:do_opt_cpt_request(Session,opt_frais_maint,subscribe) of
        {Session1,{ok_operation_effectuee,_}}->
            {redirect, Session1, Link_ok};
        {Session1,E} ->
            slog:event(service_ko,?MODULE,opt_frais_maint_nok,E),
            {redirect, Session1, "#probleme_souscription"}
    end.
	
