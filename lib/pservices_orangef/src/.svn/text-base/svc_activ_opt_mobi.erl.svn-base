-module(svc_activ_opt_mobi).

%% redirect
-export([get_profile/2,souscrire/3]).
%% include
-export([proposer_lien/4,proposer_lien/5,redir_by_opt_status/4]).

-import(svc_util_of,[dec_pcd_urls/1]).
		     
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/include/rdp_options.hrl").

%% +type get_profile(session(),URL::string())-> erlpage_result().
%%%% recup ADV options list via OCF/RDP
get_profile(abs,URL)->
    [{redirect,abs,URL}];
get_profile(#session{prof=Prof}=Session,URL)->
    State = svc_util_of:get_user_state(Session),
    case catch ocf_rdp:getOptionalServicesByMsisdn(Prof#profile.msisdn) of
	{ok, List} when list(List)->
	    State1=State#sdp_user_state{opt_activ=#activ_opt_mobi{list=List}},
	    Session1 = svc_util_of:update_user_state(Session,State1),
	    {redirect,Session1,URL};
	E ->
	    slog:event(warning,?MODULE,getOptionalServicesByMsisdn_failed,E),
	    {redirect,Session,URL}
    end.

%% +type souscrire(abs,Opt::string(),URL::string())-> erlpage_result().
souscrire(abs,_,URL)->
    [{redirect,abs,URL},
     {redirect,abs,"#failure"}];
souscrire(#session{prof=Prof}=Session,Opt,URL)->
    State = svc_util_of:get_user_state(Session),
    case catch ajout(Prof#profile.msisdn,State,list_to_atom(Opt)) of
	ok->
	    slog:event(count,?MODULE,{souscription,list_to_atom(Opt)}),
	    OPT_MOBI=cast(Session),
	    OPT_MOBI_en_cours=
		OPT_MOBI#activ_opt_mobi{en_cours=list_to_atom(Opt)},
	    {redirect,update_session(Session,OPT_MOBI_en_cours),URL};
	E->
	    slog:event(failure,?MODULE,rdp_option_souscription_ko,E),
	    {redirect,Session,"#failure"}
    end.

%% +type ajout(Msisdn::string(),sdp_user_state(),opt_act_mobi())-> ok | term.
ajout(Msisdn,State,Opt) ->
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=pbutil:get_env(pservices_orangef,code_opt_visio),
			 or_pos='AJTSO'},
    rdp_options_router:event(OPT_EVENT,[]).

%%%%%%%%%%%%%% PRINT FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% +type proposer_lien(session(),Opt::string(),string(),string())-> hlink().
%%%% proposer lien si mobile compatible visio

proposer_lien(Session,OPT,PCD_URLs,BR)->
    proposer_lien(Session,OPT,PCD_URLs,BR,"").

%% +type proposer_lien(session(),Opt::string(),string(),string(),string())-> 
%%               hlink().
proposer_lien(abs,_,PCD_URLs,BR,Key) ->
    [{PCD_Ok,URL_Ok}]=dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL_Ok,key=Key,contents=[{pcdata,PCD_Ok}]}]
	++add_br(BR);
proposer_lien(#session{prof=#profile{msisdn=MSISDN,terminal=Term}=Prof}=S,
	      Opt,PCD_URLs,BR,Key) 
  when Opt=="opt_visio" ->
    Option = list_to_atom(Opt),
    State = svc_util_of:get_user_state(S),
    case svc_util_of:is_commercially_launched(S,Option) of
	true ->
	    case State#sdp_user_state.opt_activ of
		#activ_opt_mobi{}->
		    [{PCD_Ok,URL_Ok}]=dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_Ok,key=Key,contents=[{pcdata,PCD_Ok}]}]
			++add_br(BR);
		_ ->
		    []
	    end;
	false->
	    []
    end;

proposer_lien(S,Option,PCD_URLs,BR,Key) ->
    [].

%% +type redir_by_opt_status(session(),Opt::string(),
%%                           UAct::string(),UGene::string()) ->
%%                           erlpage_result().
redir_by_opt_status(abs,Opt,UAct,UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UGene}];

redir_by_opt_status(Session, Option, UAct, UGene) ->
    State = svc_util_of:get_user_state(Session),
    CodeOpt =  pbutil:get_env(pservices_orangef,code_act_visio),
    case lists:keysearch(CodeOpt,
			 2,
			 (State#sdp_user_state.opt_activ)#activ_opt_mobi.list) of
	{value,E}->
	    {redirect, Session, UAct};
	false ->
	    {redirect, Session, UGene}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%% COMMON FUNTION %%%%%%%%%%%%%%%%%%%%

%% +type cast(session())-> activ_opt_mobi().
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#sdp_user_state.opt_activ.

%% +type update_session(session(),activ_opt_mobi())-> session().
update_session(Session,OPT_MOBI)->
    State = svc_util_of:get_user_state(Session),
    State1 = State#sdp_user_state{opt_activ=OPT_MOBI},
    svc_util_of:update_user_state(Session,State1).

%%%%%%%%%%%%%  GENERIC FUNCTIONS %%%%%%%%%%%%%%%%
%% +type add_br(string())-> [br].
add_br("br") -> [br];
add_br("nobr") -> [];
add_br(_) -> [].
