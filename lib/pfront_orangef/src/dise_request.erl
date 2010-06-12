-module(dise_request).

-export([request/1]).

-export([ping_send/0,ping_expect/1]).   %%%%% For interface MQSeries

-include("../../pservices_orangef/include/dme.hrl").
-include("../../pserver/include/pserver.hrl").
-define(ID_REQUEST, "503").

%%%% make request to DISE
%% +type request(MSISDN::string())->{ok,dme_user_state()}| {nok,int} | exit().
request(MSISDN) ->
    MSISDN2 = case MSISDN of
		  [$0,$6|_] -> MSISDN;
		  [$0,$7|_] -> MSISDN;
		  [$+,$3,$3|Rest] -> "0" ++ Rest;     %%%% Obsolete
		  [$3,$3|Rest] -> "0" ++ Rest;
		  [$+,$9,$9|Rest] -> "9" ++ Rest; %%%% For test
		  False -> exit({bad_msisdn_format,False})
	      end,
    Len = length(MSISDN2),
    M_Send = MSISDN2 ++ lists:duplicate(18-Len," "),
    Request = lists:flatten(?ID_REQUEST ++ M_Send),
    case catch mqseries_router:request(Request,[dise],5000) of
	{ok,Result} ->
	    slog:event(trace,?MODULE,dise_result,Result),
	    decrypt_result(Result,MSISDN2);
	{'EXIT',Err} ->
	    slog:event(failure,?MODULE,dise_exit,Err),
	    exit(Err);
	{error,Reason} ->
	    slog:event(failure,?MODULE,dise_exit,Reason),
	    exit(Reason);
	Other ->
	    slog:event(internal,?MODULE,dise_unexpected,Other),
	    exit(unexpected)	    
    end.


%%%% decrypt data from DISE
%% decrypt_result(Result::string(), string()) -> exit() | decrypt_result().
decrypt_result(Result,C_Msisdn) ->
    case pbutil:sscanf("%71s%52s%111s%39s",Result) of
        {[Header,_,Princ,_],Godets} ->
            decrypt(Header,Princ,Godets,C_Msisdn);
        Res ->
            exit({unexpected_format,Res})
    end.

%%%%  decrypt data from DISE and first chech about result.
%% +type decrypt(Header::string(),Princ::string(),Godets::string()) 
%%                            ->  {ok,dme_user_state()} | {nok,Reason::int()}.
decrypt(Header,Princ,Godets,C_Msisdn) ->
    {Elements,_} = 
        pbutil:sscanf("%5d%18s%4s%4s%10s%8s%4s%4s%6s%4s%4s",Header),
    case Elements of
        [Int,GSM|_] when Int == 0; Int == 16; Int == 64->
	    Res = study_princ(Elements,Princ,GSM),
	    Godet = decrypt_godet(Godets),
	    Res1 = Res#dme_user_state{godet=Godet},
	    {ok,Res1};
        [Result|_] ->
            {nok,Result}
    end.

%%%% create structure about DME conso 
%% +type study_princ(Elements::lists(term()), Princ::lists(term())) -> 
%%                                                           dme_user_state().
study_princ(Elements,Princ,GSM) ->
    [_,_,Script, GP, _, Compte, Confident, D_last_call, H_last_call,
     D_begin_period, D_end_period] = Elements,
    {[Ab_dur, Ab_mount, Rest_dur, Cons_dur, Dep_dur, Dep_mount,Hf_dur,Hf_mount,
      Init_dur, _, _, Init_report, Rest_report, Init_bonus, Rest_bonus],[]}
	= pbutil:sscanf("%6s%13s%6s%6s%6s%13s%6s%13s%6s%6s%6s%6s%6s%6s%6s",
			Princ),
    #dme_user_state{msisdn = GSM, 
		    script = list_to_integer(Script),
		    compte = Compte,
		    confident  = Confident,
		    d_last_call = D_last_call,
		    h_last_call = H_last_call,
		    d_begin_period = D_begin_period,
		    d_end_period = D_end_period,
		    ab_dur = Ab_dur,
		    ab_mount  = Ab_mount,
		    rest_dur  = Rest_dur,
		    cons_dur  = Cons_dur,
		    dep_dur  = Dep_dur,
		    dep_mount  = Dep_mount,
		    hf_dur  = Hf_dur,
		    hf_mount  = Hf_mount,
		    init_dur = Init_dur,
		    init_report = Init_report,
		    rest_report = Rest_report,
		    init_bonus = Init_bonus,
		    rest_bonus = Rest_bonus
		   }.

%%%% parse data from DISE and return a list of godets.    
%% +type decrypt_godet(Godets::string()) -> lists(godet()).
decrypt_godet(Godets) ->
    case pbutil:sscanf("%41s%41s%41s%41s%41s%41s",Godets) of
	{Godets2,_} ->
	    lists:foldl(fun store_godet/2,  [], Godets2);
	Err ->
	    slog:event(internal,?MODULE,bad_length_godets,Godets),
	    []
    end.

%%%% decrypt string to create info about each godet.
%% +type store_godet(string(), lists(godet())) -> lists(godet()).
store_godet([$G,$R,$P|_] = Godet, Acc) ->
    case catch pbutil:sscanf("GRP%3d%13s%1s%4s%4s%13s",Godet) of
	{Args,[]} -> 
	    Args2 = [godet] ++ Args,
	    [list_to_tuple(Args2)|Acc];
	_  ->
	    slog:event(internal,?MODULE,bad_format_godet,Godet),
	    Acc
    end;
store_godet(_,Acc) ->
    Acc.


%%%%%%%%%% MQSeries API PING%%%%%%%%%%%%%%%%%%%%
%%%%%%% No GSM number --> response with code 1
%% +type ping_send() -> term().
ping_send() -> 
     slog:event(trace,?MODULE,do_ping),
     ?ID_REQUEST ++ lists:duplicate(18," ").

%% +type ping_send(Data::string()) -> ok | exit(Reason).
ping_expect(Data) -> 
    case pbutil:sscanf("%5d",Data) of
	{[1],_} -> ok;
	Other -> exit({bad_ping,1,Other})
    end.
    
