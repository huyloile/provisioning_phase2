-module(svc_activ_opt_postpaid).

%% redirect
-export([get_profile/2,resilier/3,souscrire/3]).
%% include
-export([proposer_lien/4,print_if_actif/4,print_if_inactif/4,print_opt/1,
	 proposer_lien/5]).

-import(svc_util_of,[local_time/0,local_time_to_unixtime/1,
		     is_good_plage_horaire/1,dec_pcd_urls/1]).
		     
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/postpaid.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/include/rdp_options.hrl").

-define(all_ow_gp,[ow_6_gp,ow_10_gp,ow_20_gp,ow_30_gp]).
-define(all_ow_pro,[ow_6_pro,ow_10_pro,ow_20_pro,ow_30_pro]).
-define(all_sms_gp,[sms_30_gp,sms_80_gp,sms_130_gp,sms_210_gp,sms_300_gp]).
-define(all_sms_pro,[sms_30_pro,sms_80_pro,sms_130_pro,
		     sms_210_pro,sms_300_pro]).
-define(nb_act_allowed, 2).

%% +deftype opt_act_postpaid()= opt_bsf | sms_30 | 
%%       sms_80 | sms_130 | sms_210 | sms_300 | one_of_sms |
%%       ow_6 | ow_10 | ow_20 | ow_30 |one_of_ow | all_sms | all_ow.

%% +deftype activ_opt_postpaid() =
%%     #activ_opt_postpaid{ 
%%     en_cours   :: opt_act_postpaid(),
%%     list       :: [ocf_option()]}.
-record(activ_opt_postpaid,{en_cours,
			    list}).


%% +type get_profile(session(),URL::string())-> erlpage_result().
%%%% recup ADV options list via OCF/RDP
get_profile(abs,URL)->
    [{redirect,abs,URL}];
get_profile(#session{prof=Prof}=Session,URL)->
    State = svc_util_of:get_user_state(Session),
    case catch ocf_rdp:getOptionalServicesByMsisdn(Prof#profile.msisdn) of
	{ok, List} when list(List)->
	    State1=State#postpaid_user_state{opt_activ=
					     #activ_opt_postpaid{list=List}},
	    Session_New = svc_util_of:update_user_state(Session,State1),
	    {redirect,Session_New,URL};
	E ->
	    slog:event(warning,?MODULE,getOptionalServicesByMsisdn_failed,E),
	    {redirect,Session,URL}
    end.

%% +type souscrire(abs,Opt::string(),URL::string())-> erlpage_result().
souscrire(abs,_,URLs)->
    URLS=string:tokens(URLs,","),
    lists:map(fun(URL)->
		      {redirect,abs,URL}
	      end,URLS)++
	[{redirect,abs,"#system_failure"}];
souscrire(#session{}=S,Option,URLs) ->
    do_souscrire(S,list_to_atom(Option),URLs).

do_souscrire(#session{prof=Prof}=Session,Opt,URLs)
  when Opt==sms_30_gp;Opt==sms_80_gp;Opt==sms_130_gp;
       Opt==sms_210_gp;Opt==sms_300_gp ->
    State = svc_util_of:get_user_state(Session),
    [URL_Ok,URL_Nok] = string:tokens(URLs, ","),
    case catch ajout(Prof#profile.msisdn,State,Opt) of
	ok->
	    slog:event(count,?MODULE,{souscription,Opt}),
	    OPT_POSTPAID=cast(Session),
	    OPT_POSTPAID1=
		OPT_POSTPAID#activ_opt_postpaid{en_cours=Opt},
	    case is_opt_above_activated(Opt,State,?all_sms_gp) of
		true ->
		    {redirect,update_session(Session,OPT_POSTPAID1),URL_Nok};
		false ->
		    {redirect,update_session(Session,OPT_POSTPAID1),URL_Ok}
	    end;
	E->
	    slog:event(failure,?MODULE,rdp_option_souscription_ko,E),
	    {redirect,Session,"#system_failure"}
    end;
do_souscrire(#session{prof=Prof}=Session,Opt,URLs)
  when Opt==sms_30_pro;Opt==sms_80_pro;Opt==sms_130_pro;
       Opt==sms_210_pro;Opt==sms_300_pro->
    State = svc_util_of:get_user_state(Session),
    [URL_Ok,URL_Nok] = string:tokens(URLs, ","),
    case catch ajout(Prof#profile.msisdn,State,Opt) of
	ok->
	    slog:event(count,?MODULE,{souscription,Opt}),
	    OPT_POSTPAID=cast(Session),
	    OPT_POSTPAID1=
		OPT_POSTPAID#activ_opt_postpaid{en_cours=Opt},
	    case is_opt_above_activated(Opt,State,?all_sms_pro) of
		true ->
		    {redirect,update_session(Session,OPT_POSTPAID1),URL_Nok};
		false ->
		    {redirect,update_session(Session,OPT_POSTPAID1),URL_Ok}
	    end;
	E->
	    slog:event(failure,?MODULE,rdp_option_souscription_ko,E),
	    {redirect,Session,"#system_failure"}
    end;
do_souscrire(#session{prof=Prof}=Session,Opt,URL) ->
    State = svc_util_of:get_user_state(Session),
    case catch ajout(Prof#profile.msisdn,State,Opt) of
	ok->
	    slog:event(count,?MODULE,{souscription,Opt}),
	    OPT_POSTPAID=cast(Session),
	    OPT_POSTPAID1=
		OPT_POSTPAID#activ_opt_postpaid{en_cours=Opt},
	    {redirect,update_session(Session,OPT_POSTPAID1),URL};
	E->
	    slog:event(failure,?MODULE,rdp_option_souscription_ko,E),
	    {redirect,Session,"#system_failure"}
    end.

%% +type ajout(Msisdn::string(),postpaid_user_state(),opt_act_postpaid())->
%%             ok | term.
ajout(Msisdn,State,Opt)
  when Opt==sms_30_gp;Opt==sms_80_gp;Opt==sms_130_gp;
       Opt==sms_210_gp;Opt==sms_300_gp->
    case get_option(sms_gp,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,Opt}),
	    rdp_options_router:event(
	      #opt_event{msisdn=Msisdn,
			 cso=code_option(PSC),
			 or_pos='SUPSO',
			 date_retrait=pbutil:unixtime()},[arsm])
    end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[arsm]);
ajout(Msisdn,State,Opt)
  when Opt==sms_30_pro;Opt==sms_80_pro;Opt==sms_130_pro;
       Opt==sms_210_pro;Opt==sms_300_pro->
    case get_option(sms_pro,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,Opt}),
	    rdp_options_router:event(
	      #opt_event{msisdn=Msisdn,
			 cso=code_option(PSC),
			 or_pos='SUPSO',
			 date_retrait=pbutil:unixtime()},[arsm])
    end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[arsm]);
ajout(Msisdn,State,Opt)
  when Opt==ow_6_gp;Opt==ow_10_gp;
			     Opt==ow_20_gp;Opt==ow_30_gp->
    case get_option(ow_gp,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,opt_atom(PSC)}),
	    rdp_options_router:event(
	      #opt_event{msisdn=Msisdn,
			 cso=code_option(PSC),
			 or_pos='SUPSO',
			 date_retrait=pbutil:unixtime()},[arsm])
	
	end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[arsm]);
ajout(Msisdn,State,Opt) 
  when Opt==ow_6_pro;Opt==ow_10_pro;
       Opt==ow_20_pro;Opt==ow_30_pro->
    case get_option(ow_pro,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,opt_atom(PSC)}),
	    rdp_options_router:event(
	      #opt_event{msisdn=Msisdn,
			 cso=code_option(PSC),
			 or_pos='SUPSO',
			 date_retrait=pbutil:unixtime()},[arsm])
	
	end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[arsm]);
ajout(Msisdn,State,Opt) ->
    case get_option(Opt,State) of
	no_value->
	    %% nothing todo
	    ok;
	#ocf_option{prest_code=PSC}->
	    %% resilier l'option SMS active
	    slog:event(count,?MODULE,{resil_avant_souscription,opt_atom(PSC)}),
	    rdp_options_router:event(
	      #opt_event{msisdn=Msisdn,
			 cso=code_option(PSC),
			 or_pos='SUPSO',
			 date_retrait=pbutil:unixtime()},[arsm])
    end,
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=code_option(prest_code(Opt)),
			 or_pos='AJTSO',
			 date_activ=pbutil:unixtime()},
    rdp_options_router:event(OPT_EVENT,[arsm]).


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
    [{PCD,URL}|_]=dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
proposer_lien(S,"if_profile_sms_gp",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    case svc_util_of:is_commercially_launched(S,opt_forf_sms) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt_postpaid{list=List} ->
		    case is_other_opt_activated(?all_sms_gp,State,List,0) of
			false ->
			    [_,{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]
				++add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(S,"if_profile_sms_pro",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    case svc_util_of:is_commercially_launched(S,opt_forf_sms) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt_postpaid{list=List} ->
		    case is_other_opt_activated(?all_sms_pro,State,List,0) of
			false ->
			    [_,{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]
				++add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(S,"if_profile_ow_gp",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    case svc_util_of:is_commercially_launched(S,opt_ow) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt_postpaid{list=List} ->
		    %% only options above activated ones are proposed
		    %% ie if last not active, link proposed
		    case is_option_activated(ow_30_gp,State) of
			false ->
			    [_,{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]
				++add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(S,"if_profile_ow_pro",PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    case svc_util_of:is_commercially_launched(S,opt_ow) of
	true->
	    case State#postpaid_user_state.opt_activ of
		#activ_opt_postpaid{list=List} ->
		    %% only options above activated ones are proposed
		    %% ie if last not active, link proposed
		    case is_option_activated(ow_30_pro,State) of
			false ->
			    [_,{PCD,URL}]=dec_pcd_urls(PCD_URLs),
			    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]
				++add_br(BR);
			_ ->
			    []
		    end;
		_ ->
		    []
	    end;
	false->
	    []
    end;
proposer_lien(S,Option,PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(S),
    Opt=list_to_atom(Option),
    case not is_option_activated(Opt,State) and
	svc_util_of:is_commercially_launched(S,Opt) of
	true ->
	    [{PCD,URL}]=dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++add_br(BR);
	false ->
	    []
    end.    

%% +type print_if_inactif(session(),Opt::string(),URL::string(),
%%                        BR::string())-> hlink().
print_if_inactif(abs,Opt,URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,Opt}]}]++add_br(BR);
print_if_inactif(Session,Option,URL,BR)
  when Option=="sms_30_gp"; Option=="sms_80_gp"; Option=="sms_130_gp";
       Option=="sms_210_gp"; Option=="sms_300_gp";
       Option=="sms_30_pro"; Option=="sms_80_pro"; Option=="sms_130_pro";
       Option=="sms_210_pro"; Option=="sms_300_pro" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    PCD = print_link(Opt),
    case is_option_activated(Opt,State) of
	false ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	true ->
	    []
    end;
print_if_inactif(Session,Option,URL,BR)
  when Option=="ow_6_gp"; Option=="ow_10_gp"; 
       Option=="ow_20_gp"; Option=="ow_30_gp" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    PCD = print_link(Opt),
    case {is_option_activated(Opt,State),
	  is_opt_above_activated(Opt,State,?all_ow_gp)} of
	{false,false} ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	{false,true} ->
	    [];
	{true,_} ->
	    []
    end;
print_if_inactif(Session,Option,URL,BR)
  when Option=="ow_6_pro"; Option=="ow_10_pro";
       Option=="ow_20_pro"; Option=="ow_30_pro" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    PCD = print_link(Opt),
    case {is_option_activated(Opt,State),
	  is_opt_above_activated(Opt,State,?all_ow_pro)} of
	{false,false} ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++add_br(BR);
	{false,true} ->
	    [];
	{true,_} ->
	    []
    end;
print_if_inactif(Session,Option,URL,BR) ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    PCD = print_link(Opt),
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
print_opt(abs)-> [{pcdata,"300 SMS"}];
print_opt(Session)->
    Opt=cast(Session),
    [{pcdata,print(Opt#activ_opt_postpaid.en_cours)}].

%% +type print(atom())-> string().
print(Sms) when Sms==sms_30_gp; Sms==sms_30_pro ->
    "30 SMS";
print(Sms) when Sms==sms_80_gp; Sms==sms_80_pro ->
    "80 SMS";
print(Sms) when Sms==sms_130_gp; Sms==sms_130_pro ->
    "130 SMS";
print(Sms) when Sms==sms_210_gp; Sms==sms_210_pro ->
    "210 SMS";
print(Sms) when Sms==sms_300_gp; Sms==sms_300_pro ->
    "300 SMS";
print(Ow) when Ow==ow_6_gp; Ow==ow_6_pro ->
    "OW 6E:(10Mo de connexion GPRS (ou 10H de connexion CSD)";
print(Ow) when Ow==ow_10_gp; Ow==ow_10_pro ->
    "OW 10E: 25Mo de connexion GPRS ou 25H de connexion CSD";
print(Ow) when Ow==ow_20_gp; Ow==ow_20_pro ->
    "OW 20E: 60Mo de connexion GPRS + TV/Video illimitees"
	" le WE (TV sur mobile 3G/Edge)";
print(Ow) when Ow==ow_30_gp; Ow==ow_30_pro ->
    "OW 30E: 150Mo de connexion GPRS + TV/Video illimitees"
	" le WE (TV sur mobile 3G/Edge)".

print_link(Sms) when Sms==sms_30_gp; Sms==sms_30_pro ->
    "pour le forfait 30SMS";
print_link(Sms) when Sms==sms_80_gp; Sms==sms_80_pro ->
    "pour le forfait 80SMS";
print_link(Sms) when Sms==sms_130_gp; Sms==sms_130_pro ->
    "pour le forfait 130SMS";
print_link(Sms) when Sms==sms_210_gp; Sms==sms_210_pro ->
    "pour le forfait 210SMS";
print_link(Sms) when Sms==sms_300_gp; Sms==sms_300_pro ->
    "pour le forfait 300SMS";
print_link(Ow) when Ow==ow_6_gp; Ow==ow_6_pro ->
    "OW 6E/10Mo";
print_link(Ow) when Ow==ow_10_gp; Ow==ow_10_pro ->
    "OW 10E/25Mo + WE TV/Video";
print_link(Ow) when Ow==ow_20_gp; Ow==ow_20_pro ->
    "OW 20E/60Mo + WE TV/Video";
print_link(Ow) when Ow==ow_30_gp; Ow==ow_30_pro ->
    "OW 30E/150Mo + WE TV/Video";
print_link(Opt) ->
    "undefined".

%%%%%%%%%%%%%%%%%%%%%%%%% COMMON FUNTION %%%%%%%%%%%%%%%%%%%%
%% +type cast(session())-> activ_opt_postpaid().
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#postpaid_user_state.opt_activ.

%% +type update_session(session(),activ_opt_postpaid())-> session().
update_session(Session,OPT_POSTPAID)->
    State = svc_util_of:get_user_state(Session),
    State1 = State#postpaid_user_state{opt_activ=OPT_POSTPAID},
    svc_util_of:update_user_state(Session,State1).

%% +type is_option_activated(opt_act_postpaid(),postpaid_user_state())->
%%                           bool().
%%is_option_activated(all_ow_gp,State)->
%%    Fun = fun(Opt,Res)-> Res and is_option_activated(Opt,State) end,
%%    lists:foldl(Fun,true,?all_ow_gp);
%%is_option_activated(all_ow_pro,State)->
%%    Fun = fun(Opt,Res)-> Res and is_option_activated(Opt,State) end,
%%    lists:foldl(Fun,true,?all_ow_pro);
is_option_activated(all_sms_gp,State) ->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Opt,State) end,
    lists:foldl(Fun,true,?all_sms_gp);
is_option_activated(all_sms_pro,State) ->
    Fun = fun(Opt,Res)-> Res and is_option_activated(Opt,State) end,
    lists:foldl(Fun,true,?all_sms_pro);
is_option_activated(one_of_sms_gp,State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,?all_sms_gp);
is_option_activated(one_of_sms_pro,State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,?all_sms_pro);
is_option_activated(one_of_ow_gp,State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,?all_ow_gp);
is_option_activated(one_of_ow_pro,State) ->
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,?all_ow_pro);
is_option_activated(Opt,State) ->
    case get_option_value(Opt,State) of
	{ok,_}->
	    true;
	Else ->
	    false
    end.

%% +type is_opt_above_activated(atom(),postpaid_user_state(),string())->
%%                              bool().
is_opt_above_activated(Option,State,List) ->
    Range_opt = range_in_list(Option,List,1),
    List_above_opt = lists:sublist(List,Range_opt,length(List)-Range_opt+1),
    Fun = fun(Opt,Res)-> Res or is_option_activated(Opt,State) end,
    lists:foldl(Fun,false,List_above_opt).

%% +type is_other_opt_activated(atom(),postpaid_user_state(),
%%                              ListActiv::string(),
%%                              N::integer())-> bool().
is_other_opt_activated([],State,ListActiv,_) -> false;
is_other_opt_activated([First|ListSMS],State,ListActiv,N) ->
    OptFirst = case get_option_value(First,State) of
		   {ok, Value} -> Value;
		   _ -> not_found
	       end,
    Nb_activ = case lists:member(OptFirst,ListActiv) of
		   true -> N+1;
		   false -> N
	       end,
    case (Nb_activ < ?nb_act_allowed) of
	true -> is_other_opt_activated(ListSMS,State,ListActiv,Nb_activ);
	_ -> true
    end.

%% +type range_in_list(atom(),string(),N::integer())-> 
%%                     integer().
range_in_list(Opt, [], _) -> 0;
range_in_list(Opt, [F|T], N) ->
    case F==Opt of
	true -> N;
	false -> range_in_list(Opt,T,N+1)
    end.

%% +type get_option(atom(),postpaid_user_state())-> no_value | ocf_option().
get_option(sms_gp,State)->
    get_values(?all_sms_gp,State);
get_option(sms_pro,State)->
    get_values(?all_sms_pro,State);
get_option(ow_gp,State) ->
    get_values(?all_ow_gp,State);
get_option(ow_pro,State) ->
    get_values(?all_ow_pro,State);
get_option(Opt,State) ->
    get_values([Opt],State).

%% +type get_values([opt_act_postpaid()],postpaid_user_state())->
%%                   no_value | ocf_option().
get_values(OPT_LIST,State)->
    lists:foldl(fun(X,Acc)->
			case get_option_value(X,State) of
			    {ok,Val}->
				Val;
			    _ ->
				Acc
			end end, no_value, OPT_LIST).
%% +type get_option_value(opt_act_postpaid(),postpaid_user_state())-> 
%%                        false | {ok, ocf_option()}.
get_option_value(Opt,State)->
    case lists:keysearch(prest_code(Opt),
			 2,
			 (State#postpaid_user_state.opt_activ)
			 #activ_opt_postpaid.list) of
	{value,E}->
	    {ok,E};
	false ->
	    false
    end.

%% +type prest_code(opt_act_postpaid())-> string().
prest_code(Opt)->
    case lists:keysearch(Opt,1,
			 pbutil:get_env(pservices_orangef,
					activ_opt_postpaid_code)) of
	{value, {Opt,Val,_}}->
	    Val;
	false->
	    exit({?MODULE,unknown_option,Opt})
    end.

%% +type code_option(string())-> string().
code_option(PSC_NUM)->
    case lists:keysearch(PSC_NUM,2,
			 pbutil:get_env(pservices_orangef,
					activ_opt_postpaid_code)) of
	{value, {Opt,PSC,Val}}->
	    Val;
	false->
	    exit({?MODULE,unknown_option,PSC_NUM})
    end.

%% +type opt_atom(string())-> opt_act_postpaid().
opt_atom(PSC)->
    case lists:keysearch(PSC,2,
			 pbutil:get_env(pservices_orangef,
					activ_opt_postpaid_code)) of
	{value, {Opt,PSC,_}}->
	    Opt;
	false->
	    exit({?MODULE,unknow_psc,PSC})
    end.

%%%%%%%%%%%%%  GENERIC FUNCTIONS %%%%%%%%%%%%%%%%
%% +type add_br(string())-> [br].
add_br("br") -> [br];
add_br(_) -> [].
