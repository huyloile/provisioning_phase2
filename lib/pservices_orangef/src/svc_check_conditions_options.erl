-module(svc_check_conditions_options).
-compile(export_all).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").


%%% is_possible_subscription/2
%%% Session: session()
%%% Opt: atom() - Option atom
%%% Return: {Session,Boolean()}

is_possible_subscription(Session,Opt)
  when Opt==opt_jsms_ill;
       Opt==opt_ssms_ill->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
         DCL_ when DCL_==?zap_cmo_1h30_ill;
                  DCL_== ?zap_cmo_1h30_v2;
                  DCL_==?DCLNUM_CMO_SL_ZAP_1h30_ILL ->
             {Session,false};
         _ ->
             {Session,true}
     end;
is_possible_subscription(Session,opt_pass_voyage_6E=Opt) ->
    case svc_roaming:get_vlr(Session) of
        {ok, VLR_Number} ->    
	    case svc_util_of:is_commercially_launched(Session,Opt) and
		svc_util_of:is_good_plage_horaire(Opt,cmo) of
		true ->
		    {Session,true};
		_ ->
		    {Session,false}
	    end;
	_ ->
	    {Session,false}
    end.


%%% is_possible_unsubscription/2
%%% Session: session()
%%% Opt: atom() - Option atom
%%% Return: {Session,Boolean()}


%%% is_possible_reactivation/2
%%% Session: session()
%%% Opt: atom() - Option atom
%%% Return: {Session,Boolean()}
