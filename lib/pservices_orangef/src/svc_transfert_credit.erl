%%%% Self care recharge page generator.

-module(svc_transfert_credit).

%% API
-export([select_amount/2,
	 check_msisdn/2,
	 validate_message/2,
	 validate_msisdn_dest/2,
	 do_confirm/1]).

-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/transfert_credit.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").

%% +type select_amount(session(),string())-> erlpage_result().
select_amount(abs, AMOUNT)->
    [   {redirect, abs, "#offrir2"},
	{redirect, abs, "#erreur_montant"}
       ];
select_amount(SESSION, "00")->
    {redirect,SESSION,"#accueil"};

select_amount(SESSION, AMOUNT)->
    case verif_saisie(amount,AMOUNT) of
	{true,NEW_AMOUNT} ->
	    STATE=svc_util_of:get_user_state(SESSION),
	    NUM_DEST=STATE#sdp_user_state.transfert_credit,
	    TRANSFERT_CREDIT=STATE#sdp_user_state{transfert_credit ={NEW_AMOUNT,NUM_DEST}},
	    NEW_SESSION=svc_util_of:update_user_state(SESSION,TRANSFERT_CREDIT),
	    {redirect,NEW_SESSION,"#offrir2"};
	_ ->
	    {redirect,SESSION,"#erreur_montant"}
    end.


%% +type check_msisdn(session(),string())-> erlpage_result().
check_msisdn(abs, MSISDN)->
    [   {redirect, abs, "#offrir3"},
	{redirect, abs, "#erreur_msisdn"}
       ];
check_msisdn(SESSION, MSISDN) 
  when MSISDN=="00";MSISDN=="9"->
    {redirect,SESSION,"#accueil"};
check_msisdn(SESSION, MSISDN)
  when MSISDN=="1"->
    {redirect,SESSION,"file:/mcel/acceptance/mobi/recharge/menu.xml"};
check_msisdn(#session{prof=Profile}=SESSION, MSISDN)->
    State = svc_util_of:get_user_state(SESSION),
    MSISDN_transmetteur = svc_util_of:int_to_nat(State#sdp_user_state.msisdn),    
    case MSISDN==MSISDN_transmetteur of
 	true->
	     {redirect,SESSION,"#erreur_enter_own_msisdn_transmetteur"};
	 _->
	    case verif_saisie(msisdn,MSISDN) of
		true ->
		    Session_receiver = #session{prof=Profile#profile{msisdn=MSISDN},
						svc_data=[{user_state, #sdp_user_state{}}]},
		    case svc_sachem:consult_account(Session_receiver) of 
			{ok, {_, Resp_params}} ->
			    case lists:keysearch("DCL_NUM",1,Resp_params) of 				
			    {value,{_,DCL}} -> 
				    List_DCL_eligible = pbutil:get_env(pservices_orangef,dcl_eligible_offrir_credit),
				    case lists:member(list_to_integer(DCL),List_DCL_eligible) of 
					true -> 
					    STATE=svc_util_of:get_user_state(SESSION),
					    TRANSFERT_CREDIT=STATE#sdp_user_state{transfert_credit=MSISDN},
					    NEW_SESSION=svc_util_of:update_user_state(SESSION,TRANSFERT_CREDIT),
					    {redirect,NEW_SESSION,"#offrir3"};
					_ ->
					    {redirect,SESSION,"#erreur_msisdn"}
				    end;
				_ ->
				    {redirect,SESSION,"#erreur_msisdn"}
			    end;
			Reason ->
			    slog:event(failure, ?MODULE, send_consult_account, Reason),
			    {redirect,SESSION,"#erreur_msisdn"}
		    end;
		{false, wrong_pp_orange} ->
		    {redirect,SESSION,"#erreur_msisdn_pp_orange"};
		_ ->
		    {redirect,SESSION,"#erreur_msisdn_wrong_format"}
	    end
    end.


%% +type validate_message(session(),string()) -> erlinclude_result().
validate_message(abs, Fmt)->
    [{pcdata, Fmt}];

validate_message(SESSION, Fmt)->
    STATE=svc_util_of:get_user_state(SESSION),
    {AMOUNT,MSISDN} = (STATE#sdp_user_state.transfert_credit),
    [{pcdata, lists:flatten(io_lib:format(Fmt, [AMOUNT, svc_util_of:get_msisdn(MSISDN)]))}].

%% +type validate_message(session(),string()) -> erlinclude_result().
validate_msisdn_dest(abs, Fmt)->
    [{pcdata, Fmt}];

validate_msisdn_dest(SESSION, Fmt)->
    STATE=svc_util_of:get_user_state(SESSION),
    MSISDN = STATE#sdp_user_state.transfert_credit,    
    [{pcdata, lists:flatten(io_lib:format(Fmt, [svc_util_of:get_msisdn(MSISDN)]))}].

%% +type do_confirm(session()) -> erlinclude_result().
do_confirm(abs)->
    [   {redirect, abs, "#success"},
	{redirect, abs, "#erreur_sachem"}
       ];

do_confirm(#session{prof=Prof}=SESSION)->
    MSISDN_TRANSMETTER=Prof#profile.msisdn,
    SUB = svc_util_of:get_souscription(SESSION),
    STATE=svc_util_of:get_user_state(SESSION),
    {AMOUNT,MSISDN_RECEIVER} = (STATE#sdp_user_state.transfert_credit),
    case lists:keysearch(AMOUNT, 2, ?LIST_TRC_NUM ) of
	{value, {TRC_NUM,AMOUNT}} -> 
            case transfer_credit(SESSION, {SUB,MSISDN_TRANSMETTER},
                                 MSISDN_RECEIVER, TRC_NUM) of
		{ok_operation_effectuee, RESULT_NTRD} ->
		    NEW_STATE = svc_compte:decode_ntrd(RESULT_NTRD,STATE),
		    NEW_SESSION=svc_util_of:update_user_state(SESSION,NEW_STATE),
		    {redirect,NEW_SESSION,"#success"};
		{ok, {NEW_SESSION, Resp_params}} ->
		    {value,{_,Status}} = lists:keysearch("STATUT",1,Resp_params),
		    case list_to_integer(Status) of 
			0->			    
			    {redirect,NEW_SESSION,"#success"};
			X when X==35;X==-35 ->
			    {redirect,NEW_SESSION,"#erreur_msisdn_inactive"};
			_ ->
			    {redirect,SESSION,"#erreur_sachem"}
		    end;
                {nok, Reason} ->
		    slog:event(failure, ?MODULE, transfer_credit, 
                               {{transmitter, MSISDN_TRANSMETTER},
                                {receiver, MSISDN_RECEIVER},
                                {amount, AMOUNT}}),
		    {redirect,SESSION,"#erreur_sachem"};
                Other ->
		    slog:event(failure, ?MODULE, transfert_failed, 
                               {MSISDN_TRANSMETTER,MSISDN_RECEIVER,AMOUNT}),
		    {redirect,SESSION,"#erreur_sachem"}
	    end;
        _->
	    slog:event(failure,?MODULE,unknown_amount,{MSISDN_TRANSMETTER,MSISDN_RECEIVER,AMOUNT}),
	    {redirect,SESSION,"#erreur_sachem"}
    end.

transfer_credit(Session, {SUB,MSISDN_TRANSMETTER}, MSISDN_RECEIVER, TRC_NUM) ->
    svc_sachem:transfer_credit(Session, MSISDN_RECEIVER, TRC_NUM).

    
verif_saisie(amount,AMOUNT) ->
    case pbutil:all_digits(AMOUNT) of
	true ->
	    case (list_to_integer(AMOUNT) >=1) and(list_to_integer(AMOUNT)=<15) of
		true ->
		    {true, integer_to_list(list_to_integer(AMOUNT))};
		false ->
		    false
	    end;
	_ ->
	    false
    end;

verif_saisie(msisdn,MSISDN)  ->
    case pbutil:all_digits(MSISDN) of
	true ->
	    case length(MSISDN)  of
		10 ->
		    MSISDN_Receiver = svc_util_of:int_to_nat(MSISDN),
		    [$0,H|T]=MSISDN_Receiver,
		    case H of 
			H when H==$6;H==$7 ->
			    MsisdnPattern = "+33"++[H|T],
			     case catch db:lookup_profile({msisdn,MsisdnPattern}) of
			     	Profile when record(Profile,profile) ->
			     	    Subscription = (Profile#profile.subscription),
			     	    case (Subscription=="mobi") of 
			     		false -> 
			     		    {false, wrong_pp_orange}; 
			     		_ ->
			     		    true
			     	    end;
			     	not_found ->
				     case ocf_rdp:getUserInformationByMsisdn(MsisdnPattern) of 
					 {ok,#ocf_info_client{segmentCode=SEG}=Code} ->
					     List_SegCo_Autorise = pbutil:get_env(pservices_orangef,segCo_autorise_offrir_credit),
					     case lists:member(SEG,List_SegCo_Autorise) of 
						 true ->
						     true;
						 _ ->
						     slog:event(failure, ?MODULE, segCode_not_autorise, MSISDN),
						     {false, wrong_pp_orange}
					     end;
					 Error ->
					     slog:event(failure, ?MODULE, msisdn_not_found, {MSISDN,Error}),
					     {false, wrong_pp_orange}
				     end;
				 E ->
				     exit(E)
			     end;
			_ ->
			    slog:event(failure, ?MODULE, msisdn_wrong_beginning_by_06_or_07, MSISDN),
			    {false, wrong_format}
		    end;
		_ -> 
		    slog:event(failure, ?MODULE, msisdn_wrong_length, MSISDN),
		    {false, wrong_format}
	    end;
	_->
	    slog:event(failure, ?MODULE, msisdn_wrong_format, MSISDN),
	    {false, wrong_format}
    end.

