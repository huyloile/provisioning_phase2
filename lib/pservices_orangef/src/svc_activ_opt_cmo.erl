-module(svc_activ_opt_cmo).

%% redirect
-export([get_profile/2,resilier/3,souscrire/3]).
%% include
-export([proposer_lien/4,print_if_actif/4,print_if_inactif/5,print_opt/1,
	 proposer_lien/5]).

-import(svc_util_of,[local_time/0,local_time_to_unixtime/1,
		     is_good_plage_horaire/1,dec_pcd_urls/1]).
		     
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/include/rdp_options.hrl").

-define(all_ow,[ow_6,ow_10,ow_10_new,ow_20,ow_30]).
-define(all_sms,[sms_30,sms_80,sms_130]).

%% +deftype opt_act_cmo()= ow_6 | ow_10 | sms_30 | sms_80 | sms_130 | one_of_sms |
%%     one_of_ow | all_sms | all_ow | ow_10_new | ow_20 | ow_30.

%% +deftype activ_opt_cmo() =
%%     #activ_opt_cmo{ 
%%     en_cours   :: opt_act_cmo(),
%%     list       :: [ocf_option()]}.
-record(activ_opt_cmo,{en_cours,
		       list}).


%% +type get_profile(session(),URL::string())-> erlpage_result().
%%%% recup ADV options list via OCF/RDP
get_profile(abs,URL)->
    [{redirect,abs,URL}];
get_profile(#session{prof=Prof}=Session,URL)->
    State = svc_util_of:get_user_state(Session),
    case catch ocf_rdp:getOptionalServicesByMsisdn(Prof#profile.msisdn) of
	{ok, List} when list(List)->
	    State1=State#sdp_user_state{opt_activ=#activ_opt_cmo{list=List}},
	    Session1 = svc_util_of:update_user_state(Session,State1),
	    {redirect,Session1,URL};
	E ->
	    slog:event(warning,?MODULE,getOptionalServicesByMsisdn_failed,E),
	    {redirect,Session,URL}
    end.

%% +type souscrire(abs,Opt::string(),URL::string())-> erlpage_result().
souscrire(abs,_,URL)->
    [{redirect,abs,URL},
     {redirect,abs,"#system_failure"}];
souscrire(#session{prof=Prof}=Session,Opt,URL)->
    State = svc_util_of:get_user_state(Session),
    case catch ajout(Prof#profile.msisdn,State,list_to_atom(Opt)) of
	ok->
	    slog:event(count,?MODULE,{souscription,list_to_atom(Opt)}),
	    OPT_CMO=cast(Session),
	    OPT_CMO1=
		OPT_CMO#activ_opt_cmo{en_cours=list_to_atom(Opt)},
	    {redirect,update_session(Session,OPT_CMO1),URL};
	E->
	    slog:event(failure,?MODULE,rdp_option_souscription_ko,E),
	    {redirect,Session,"#system_failure"}
    end.

%% +type ajout(Msisdn::string(),sdp_user_state(),opt_act_cmo())-> ok | term.
ajout(Msisdn,State,Opt) when Opt==sms_30;Opt==sms_80;Opt==sms_130->
    case get_option(sms,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,Opt}),
	    rdp_options_router:event(#opt_event{msisdn=Msisdn,
						cso=code_option(PSC),
						or_pos='SUPSO',
						date_retrait=pbutil:unixtime()},[])
	
	end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[]);
ajout(Msisdn,State,Opt) when Opt==ow_6;Opt==ow_10;Opt==ow_10_new;Opt==ow_20;Opt==ow_30->
    case get_option(ow,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,opt_atom(PSC)}),
	    rdp_options_router:event(#opt_event{msisdn=Msisdn,
						cso=code_option(PSC),
						or_pos='SUPSO',
						date_retrait=pbutil:unixtime()},[])
	
	end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[]).


%% +type resilier(abs,Opt::string(),URL::string())-> erlpage_result().
resilier(abs,_,URL)->
    [{redirect,abs,URL},
     {redirect,abs,"#system_failure"}];
resilier(#session{prof=Prof}=Session,Opt,URL)->
    State = svc_util_of:get_user_state(Session),
    case get_option(list_to_atom(Opt),State) of
	#ocf_option{prest_code=PSC}->
	    OPT_EVENT=#opt_event{msisdn=Prof#profile.msisdn,
				 cso=PSC,
				 or_pos='SUPSO',
				 date_retrait=pbutil:unixtime()},
	    case catch rdp_options_router:event(OPT_EVENT,[]) of
		ok->
		    slog:event(count,?MODULE,{resiliation,list_to_atom(Opt)}),
		    %% suppression Pres_code de la liste des options actives
		    {redirect,Session,URL};
		E->
		    slog:event(failure,?MODULE,rdp_option_resiliation_ko,E),
		    {redirect,Session,"#system_failure"}
	    end;
	E ->
	    slog:event(internal,?MODULE,rdp_option_get_value_failed,E),
	    {redirect,Session,"#system_failure"}
    
    end.

%%%%%%%%%%%%%% PRINT FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% +type proposer_lien(session(),Opt::string(),string(),string())-> hlink().
%%%% proser les liens d'acces au service uniquement si OCF a repondu

proposer_lien(Session,OPT,PCD_URLs,BR)->
    proposer_lien(Session,OPT,PCD_URLs,BR,"").

%% +type proposer_lien(session(),Opt::string(),string(),string(),string())-> 
%%               hlink().
proposer_lien(abs,_,PCD_URLs,BR,Key) ->
    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
proposer_lien(S,"if_profile_sms",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    case svc_util_of:is_commercially_launched(S,opt_forf_sms) of
	true->
	    case State#sdp_user_state.opt_activ of
		#activ_opt_cmo{}->
		    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(S,"if_profile_ow",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    Opt=State#sdp_user_state.opt_activ,
    case svc_util_of:is_commercially_launched(S,opt_ow_cmo) of
	true->
	    case State#sdp_user_state.opt_activ of
		#activ_opt_cmo{}->
		    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(S,Option,PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    Opt=list_to_atom(Option),
    case is_option_activated(Opt,State) and svc_util_of:is_commercially_launched(S,Opt) of
	true ->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
	false ->
	    []
    end.

%% +type print_if_inactif(session(),Opt::string(),string(),string(),string())-> hlink().
print_if_inactif(abs,_,PCD,URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
print_if_inactif(Session,Option,PCD,URL,BR) ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case is_option_activated(Opt,State) of
	false ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	true ->
	    []
    end.

%% +type print_if_actif(session(),Opt::string(),string(),string())-> hlink().
print_if_actif(abs,_,PCD_URLs,BR) ->
    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
print_if_actif(Session,Option,PCD_URLs,BR) ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case is_option_activated(Opt,State) of
	true ->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	false ->
	    []
    end.

%% +type print_opt(session())-> [{pcdata,string()}].
print_opt(abs)-> [{pcdata,"130 SMS"}];
print_opt(Session)->
    Opt=cast(Session),
    [{pcdata,print(Opt#activ_opt_cmo.en_cours)}].

%% +type print(atom())-> string().
print(sms_30)->
    "30 SMS";
print(sms_80) ->
    "80 SMS";
print(sms_130) ->
    "130 SMS";
print(ow_6) ->
    "OW 6E : 10 Mo de connexion GPRS (ou 10 H de connexion CSD)";
print(ow_10_new) ->
    "OW 10E: 25 Mo de connexion GPRS + TV/Video illimitees le WE (TV sur mobile 3G/Edge)";
print(ow_20) ->
    "OW 20E: 60 Mo de connexion GPRS + TV/Video illimitees le WE (TV sur mobile 3G/Edge)";
print(ow_30) ->
    "OW 30E: 150 Mo de connexion GPRS + TV/Video illimitees le WE (TV sur mobile 3G/Edge)".

%%%%%%%%%%%%%%%%%%%%%%%%% COMMON FUNTION %%%%%%%%%%%%%%%%%%%%
%% +type cast(session())-> activ_opt_cmo().
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#sdp_user_state.opt_activ.

%% +type update_session(session(),activ_opt_cmo())-> session().
update_session(Session,OPT_CMO)->
    State = svc_util_of:get_user_state(Session),
    State1 = State#sdp_user_state{opt_activ=OPT_CMO},
    svc_util_of:update_user_state(Session,State1).

%% +type is_option_activated(opt_act_cmo(),sdp_user_state())-> bool().
is_option_activated(all_ow,State)->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Opt,State) end,
    lists:foldl(Fun,true,?all_ow);
is_option_activated(all_sms,State) ->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Opt,State) end,
    lists:foldl(Fun,true,?all_sms);
is_option_activated(one_of_sms,State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,?all_sms);
is_option_activated(one_of_ow,State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,?all_ow);
is_option_activated(Opt,State) ->
    case get_option_value(Opt,State) of
	{ok,_}->
	    true;
	Else ->
	    false
    end.


%% +type get_option(atom(),sdp_user_state())-> no_value | ocf_option().
get_option(sms,State)->
    get_values(?all_sms,State);
get_option(ow,State) ->
    get_values(?all_ow,State).

%% +type get_values([opt_act_cmo()],sdp_user_state())-> no_value | ocf_option().
get_values(OPT_LIST,State)->
    lists:foldl(fun(X,Acc)->
			case get_option_value(X,State) of
			    {ok,Val}->
				Val;
			    _ ->
				Acc
			end end, no_value, OPT_LIST).
%% +type get_option_value(opt_act_cmo(),sdp_user_state())-> false | {ok, ocf_option()}.
get_option_value(Opt, #sdp_user_state{opt_activ=undefined})->
     false;
get_option_value(Opt,State)->
    case lists:keysearch(prest_code(Opt),
			 2,
			 (State#sdp_user_state.opt_activ)#activ_opt_cmo.list) of
	{value,E}->
	    {ok,E};
	false ->
	    false
    end.

%% +type prest_code(opt_act_cmo())-> string().
prest_code(Opt)->
    case lists:keysearch(Opt,1,
			 pbutil:get_env(pservices_orangef,activ_opt_cmo_code)) of
	{value, {Opt,Val,_}}->
	    Val;
	false->
	    exit({?MODULE,unknown_option,Opt})
    end.

%% +type code_option(string())-> string().
code_option(PSC_NUM)->
    case lists:keysearch(PSC_NUM,2,
			 pbutil:get_env(pservices_orangef,activ_opt_cmo_code)) of
	{value, {Opt,PSC,Val}}->
	    Val;
	false->
	    exit({?MODULE,unknown_option,PSC_NUM})
    end.

%% +type opt_atom(string())-> opt_act_cmo().
opt_atom(PSC)->
    case lists:keysearch(PSC,2,
			 pbutil:get_env(pservices_orangef,
					activ_opt_cmo_code)) of
	{value, {Opt,PSC,_}}->
	    Opt;
	false->
	    exit({?MODULE,unknow_psc,PSC})
    end.

%%%%%%%%%%%%%  GENERIC FUNCTIONS %%%%%%%%%%%%%%%%
%% +type add_br(string())-> [br].
add_br("br") -> [br];
add_br(_) -> [].
