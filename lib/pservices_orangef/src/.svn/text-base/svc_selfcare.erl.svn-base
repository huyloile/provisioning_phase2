
%first%% Selfcare page generator.

-module(svc_selfcare).
-export([start_light/2,check_state/2,select_home_niv2/1,select_home_niv3/1]).
-export([select_home_niv1/1]).
-export([start_selfcare/2, msisdn/1]).
-export([fin_validite/1]).
-export([print_sum/2]).
-export([plan/1,descr_plan/1,descr_wap/1]).

-export([include_plug/1]).

%% Promo and Options Export
-export([print_first_link_promo/3,
	 promo_start/2]).
-export([print_next_link_options/1,print_first_link_options/1,
	next_options/1,next_promo/1,print_next_link_promo/1,odr_ort/1]).
%% Option SMS service
-export([options_sms_souscription/1,options_sms_start/1]).

-export([omer_select_home/1]).

-export([print_by_plan/2,
	 redirect_by_plan/2]).
-export([ptfnum_int2str/1]).

-include("../../pgsm/include/sms.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").

-define(DAY_IN_SEC, 86400).

start_selfcare(abs,URL) ->
	continue_selfcare(abs,URL) ++ 
	[ {redirect, abs, "#notmobi"} ];
start_selfcare(#session{prof=#profile{subscription=S}}=Session,URL)
  when S=/="mobi" ->
    slog:event(trace, ?MODULE, not_mobi),
    {redirect, Session, "#notmobi"};
start_selfcare(#session{prof=Profile}=Session,URL) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    pbutil:autograph_label(dump_billing_ok),
	    continue_selfcare(Session1,URL);
	{stop, Session1, Reason} ->
	    pbutil:autograph_label(dump_billing_error),
	    {redirect, Session1, "#temporary"}
    end.

continue_selfcare(abs,URL) ->
      filter(abs,abs,URL) ++
	[ {failure, {redirect,abs,"#temporary"}} ];
continue_selfcare(#session{prof=Profile}=Session,URL) ->
    case provisioning_ftm:reset_sdp_state(Session) of
	{ok, Session_,State}  ->
	    slog:event(count, ?MODULE, read_state_ok, State),
	    NewSession=svc_util_of:update_user_state(Session_,State),
	    filter(NewSession,State,URL);
	Error ->
	    slog:event(count, ?MODULE, read_state_error, Error),
	    {redirect, Session, "#temporary"}
    end.

filter(abs,abs,URL)->
      svc_home:filter_pathological_mobi(abs,abs) ++
	[{redirect,abs,URL}];
filter(Session,State,URL) ->
    case catch svc_home:filter_pathological_mobi(Session,State) of
	{continue, Session1} ->
	    {redirect,Session1,URL};
	{redirect, Session1, URL}=Redirect ->
	    Redirect;
	{redirect, Session1, URL, Subst}=Redirect ->
	    Redirect
    end.

start_light(abs,URL) ->
    [{redirect,abs,URL}]++start_selfcare(abs,URL);
start_light(Session,URL)->
    case svc_util_of:get_user_state(Session) of
	#sdp_user_state{}=State->
	    %% record correct -> go on
	    {redirect,Session,URL};
	_->
	    start_selfcare(Session,URL)
    end.

check_state(abs, Dest) ->
    [{redirect, abs, Dest}]++ start_selfcare(abs,Dest);
check_state(Session,Dest)->
    %% record correct -> go on
    case svc_util_of:get_user_state(Session) of
	#sdp_user_state{}=State->
	    %% record correct -> go on
	    {redirect,Session,Dest};
	_->
	    start_selfcare(Session,Dest)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% redirect in function of state's  compte for niv 1 and 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
select_home_niv2(abs) ->
    L=lists:map(
	fun(PTF) ->
		[{"Cas A",
		  {redirect, abs, "#princ_ac_sms_ac_wap_ac_promo_ac"}},
		 {"Cas C",
		  {redirect, abs, "#princ_ac_sms_ac_wap_ac_promo_ep"}},
		 {"Cas I",
		  {redirect, abs, "#princ_ac_sms_ac_wap_ep_promo_ac"}},
		 {"Cas F",
		  {redirect, abs, "#princ_ac_sms_ep_wap_ac_promo_ac"}},
		 {"Cas L",
		  {redirect, abs, "#princ_ep_sms_ac_wap_ac_promo_ac"}},
		 {"Cas E",
		  {redirect, abs, "#princ_ac_sms_ep_wap_ep_promo_ep"}},
		 {"Cas D",
		  {redirect, abs, "#princ_ac_sms_ac_wap_ep_promo_ep"}},
		 {"Cas H",
		  {redirect, abs, "#princ_ac_sms_ep_wap_ac_promo_ep"}},
		 {"Cas G",
		  {redirect, abs, "#princ_ac_sms_ep_wap_ep_promo_ac"}},
		 {"Cas M",
		  {redirect, abs, "#princ_ep_sms_ac_wap_ep_promo_ep"}},
		 {"Cas P",
		  {redirect, abs, "#princ_ep_sms_ep_wap_ac_promo_ep"}},
		 {"Cas N",
		  {redirect, abs, "#princ_ep_sms_ac_wap_ac_promo_ep"}},
		 {"Cas K",
		  {redirect, abs, "#princ_ep_sms_ep_wap_ac_promo_ac"}},
		 {"Cas O",
		  {redirect, abs, "#princ_ep_sms_ac_wap_ep_promo_ac"}},
		 {"Cas J",
		  {redirect, abs, "#princ_ep_sms_ep_wap_ep_promo_ac"}}]
	end, ?LISTE_PLANS_SUPPORTES),
    lists:flatten(L ++ 
		  [{"Cas B",{redirect, abs, "#epuise"}},
		   {"Cas B'",{redirect, abs, "#perime"}}]);

select_home_niv2(S) ->
    State= svc_util_of:get_user_state(S),
    PTF=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    case {svc_compte:etat_cpte(State,cpte_princ),
	  svc_compte:etat_cpte(State,cpte_sms),
	  svc_compte:etat_cpte(State,cpte_wap),
	  svc_compte:etat_cpte(State,cpte_sms_noel)} of
	
	%% les 4 Godets actifs:
	{?CETAT_AC,?CETAT_AC,?CETAT_AC,?CETAT_AC} -> %% cas A
	    {redirect, S, "#princ_ac_sms_ac_wap_ac_promo_ac"};

	%% 3 Godets actfis:
	{?CETAT_AC,?CETAT_AC,?CETAT_AC,_} -> %% cas C
	    {redirect, S, "#princ_ac_sms_ac_wap_ac_promo_ep"};
	{?CETAT_AC,?CETAT_AC,_,?CETAT_AC} -> %% cas I
	    {redirect, S, "#princ_ac_sms_ac_wap_ep_promo_ac"};
	{?CETAT_AC,_,?CETAT_AC,?CETAT_AC} -> %% cas F
	    {redirect, S, "#princ_ac_sms_ep_wap_ac_promo_ac"};
	{_,?CETAT_AC,?CETAT_AC,?CETAT_AC} -> %% cas L
	    {redirect, S, "#princ_ep_sms_ac_wap_ac_promo_ac"};
	
	%% 2 Godets actifs:
	{?CETAT_AC,?CETAT_AC,_,_} -> %% cas D
	    {redirect, S, "#princ_ac_sms_ac_wap_ep_promo_ep"};
	{?CETAT_AC,_,?CETAT_AC,_} -> %% cas H
	    {redirect, S, "#princ_ac_sms_ep_wap_ac_promo_ep"};
	{_,?CETAT_AC,?CETAT_AC,_} -> %% cas N
            {redirect, S, "#princ_ep_sms_ac_wap_ac_promo_ep"};
	{?CETAT_AC,_,_,?CETAT_AC} -> %% cas G
	    {redirect, S, "#princ_ac_sms_ep_wap_ep_promo_ac"};
	{_,?CETAT_AC,_,?CETAT_AC} -> %% cas O
	    {redirect, S, "#princ_ep_sms_ac_wap_ep_promo_ac"};
	{_,_,?CETAT_AC,?CETAT_AC} -> %% cas K
	    {redirect, S, "#princ_ep_sms_ep_wap_ac_promo_ac"};
	
	%% 1 seul Godet actif:
	{?CETAT_AC,_,_,_} -> %% cas E
	    {redirect, S, "#princ_ac_sms_ep_wap_ep_promo_ep"};
	{_,?CETAT_AC,_,_} -> %% cas M
            {redirect, S, "#princ_ep_sms_ac_wap_ep_promo_ep"};
	{_,_,?CETAT_AC,_} -> %% cas P
            {redirect, S, "#princ_ep_sms_ep_wap_ac_promo_ep"};
	{_,_,_,?CETAT_AC} -> %% cas J
	    {redirect, S, "#princ_ep_sms_ep_wap_ep_promo_ac"};

	%% Aucun Godet n'est actif
	{?CETAT_PE,_,_,_} -> %% cas B
            {redirect, S, "#perime"};
	{?CETAT_EP,_,_,_} -> %% cas B
	    {redirect, S, "#epuise"};
	{E,F,G,H} ->
	  slog:event(warning, ?MODULE, mobi_unexpected_cpte_state, 
		     {State,E,F,G,H}),
	  {redirect, S, "#temporary"}
  end.

%% +type print_by_plan(session(),string()) -> [{pcdata,string()}].
print_by_plan(abs,DESCR_PLANs) ->
    FL = fun (S) -> [Plan,PCD] = string:tokens(S,"="), {Plan,PCD} end,
    [{_,FIRST_PCD}|_]=lists:map(FL, string:tokens(DESCR_PLANs, ",")),
    [{pcdata,FIRST_PCD}];

print_by_plan(Session,DESCR_PLANs) ->
%%  DESCR_PLANs must have the following format : 
%% "plan1=pcdata1,plan2=pcdata2,...,planN=pcdataN,default=pcdataDef"
%% 'default' can be omitted
    State = svc_util_of:get_user_state(Session),
    PTF=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    PTF_STR=ptfnum_int2str(PTF),
    FL = fun (S) -> [Plan,PCD] = string:tokens(S,"="), {Plan,PCD} end,
    L=lists:map(FL, string:tokens(DESCR_PLANs, ",")),
    PCDATA=(case lists:keysearch(PTF_STR,1,L) of
		{value, {_,PCD1}} -> PCD1;
		false  -> 
		    case lists:keysearch("default",1,L) of
			{value, {_,PCD2}} -> PCD2;
			false -> ""
		    end
	    end),
    [{pcdata,PCDATA}].

%% +type redirect_by_plan(session(),string()) ->
%%                        {redirect,session(),Url::string()}.
redirect_by_plan(abs,REDIR_PLANs) ->
    lists:map(fun(X) -> [Plan,U] = string:tokens(X,"="), {redirect,abs,U} end,
	      string:tokens(REDIR_PLANs,","));
redirect_by_plan(Sess,REDIR_PLANs) ->
    State = svc_util_of:get_user_state(Sess),
    PTF=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    PTF_STR=ptfnum_int2str(PTF),
    FL = fun (S) -> [Plan,PCD] = string:tokens(S,"="), {Plan,PCD} end,
    L=lists:map(FL, string:tokens(REDIR_PLANs, ",")),
    PTFURL=(case lists:keysearch(PTF_STR,1,L) of
		{value, {_,URL1}} -> 
		    URL1;
		false  -> 
		    case lists:keysearch("default",1,L) of
			{value, {_,URL2}} -> 
			    URL2;
			false ->
			    slog:event(internal,?MODULE,
				       bad_plan_tarifaire,REDIR_PLANs),
			    "#temporary"
		    end
	    end),
    {redirect,Sess,PTFURL}.

%% +type ptfnum_int2str(integer()) -> string().
ptfnum_int2str(?MCLAS) -> "classique";
ptfnum_int2str(?PSMM) -> "smm";
ptfnum_int2str(?PSMAM) -> "smam";
ptfnum_int2str(?PSMS) -> "smsoir";
ptfnum_int2str(?PSMN) -> "smn";
ptfnum_int2str(?MADRID2) -> "madrid2";
ptfnum_int2str(?PLUG_NOEL) -> "plug_noel";
ptfnum_int2str(?PCLAS_V2) -> "classiquev2";
ptfnum_int2str(?PSOIR_WE) -> "soir_we";
ptfnum_int2str(?PLUGV3) -> "plugv3";
ptfnum_int2str(?PLUGV3_SEC) -> "plugv3sec";
ptfnum_int2str(?PCLAS_SEC) -> "classique_sec";
ptfnum_int2str(?PTF_CLAS_SEC_V2) -> "classique_sec";
ptfnum_int2str(?MSMM2) ->     "classique_sec"; %% meme suivi conso que ptf 2
ptfnum_int2str(?PSOIR_WE_SEC) -> "soir_we_sec";
ptfnum_int2str(?MOBI_ZAP) -> "zap";
ptfnum_int2str(?MOBI_ZAP_PROMO) -> "zap_promo";
ptfnum_int2str(?M6_PREPAID) -> "m6_prepaid";
ptfnum_int2str(?ADFUNDED) -> "m6_prepaid";
ptfnum_int2str(?PTF_MOBI_BONUS) -> "mobi_janus";
ptfnum_int2str(?PTF_MOBI_BONUS_APPELS) -> "mobi_janus";
ptfnum_int2str(?PTF_MOBI_BONUS_SMS) -> "mobi_janus";
ptfnum_int2str(?PTF_MOBI_BONUS_INTERNET) -> "mobi_janus";
ptfnum_int2str(?PTF_MOBI_BONUS_ETRANGER) -> "mobi_janus";

ptfnum_int2str(P)->
    slog:event(internal, ?MODULE, plan_is_not_supported, P),
    not_supported.
    
% Fonction reciproque
% ptfnum_str2int("classique") -> ?MCLAS;
% ptfnum_str2int("smm") -> ?PSMM;
% ptfnum_str2int("smam") -> ?PSMAM;
% ptfnum_str2int("smsoir") -> ?PSMS;
% ptfnum_str2int("smn") -> ?PSMN;
% ptfnum_str2int("madrid2") -> ?MADRID2;
% ptfnum_str2int("plug_noel") -> ?PLUG_NOEL;
% ptfnum_str2int("classiquev2") -> ?PCLAS_V2;
% ptfnum_str2int("soir_we") -> ?PSOIR_WE;
% ptfnum_str2int("plugv3") -> ?PLUGV3;
% ptfnum_str2int("plugv3sec") -> ?PLUGV3_SEC;
% ptfnum_str2int("classique_sec") -> ?PCLAS_SEC;
% ptfnum_str2int("soir_we_sec") -> ?PSOIR_WE_SEC;
% ptfnum_str2int(P) ->
%     slog:event(internal, ?MODULE, plan_is_not_supported, P),
%     not_supported.
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% redirect in function of state's  compte for niv 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

select_home_niv1(abs)->
    L=lists:map(fun(PTF) -> [{"Cas C",
			      {redirect, abs, "#princ_ac_sms_ac_wap_ac"}},
			     {"Cas D",
			      {redirect, abs, "#princ_ac_sms_ac_wap_ep"}},
			     {"Cas H",
			      {redirect, abs, "#princ_ac_sms_ep_wap_ac"}},
			     {"Cas N",
			      {redirect, abs, "#princ_ep_sms_ac_wap_ac"}},
			     {"Cas E",
			      {redirect, abs, "#princ_ac_sms_ep_wap_ep"}},
			     {"Cas M",
			      {redirect, abs, "#princ_ep_sms_ac_wap_ep"}},
			     {"Cas P",
			      {redirect, abs, "#princ_ep_sms_ep_wap_ac"}}]
		end, ?LISTE_PLANS_SUPPORTES),
    lists:flatten(L++[{"Cas B epuise",
		       {redirect, abs, "#epuise"}},
		      {"Cas B perime",
		       {redirect, abs, "#perime"}}]);
select_home_niv1(S) ->
    State = svc_util_of:get_user_state(S),
    PTF=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    case {svc_compte:etat_cpte(State,cpte_princ),
	  svc_compte:etat_cpte(State,cpte_sms),
	  svc_compte:etat_cpte(State,cpte_wap)} of
	
	{?CETAT_AC,?CETAT_AC,?CETAT_AC} ->
	    {redirect, S, "#princ_ac_sms_ac_wap_ac"}; %% cas C
	{?CETAT_AC,?CETAT_AC,_} ->        
	    {redirect, S, "#princ_ac_sms_ac_wap_ep"}; %% cas D
	{?CETAT_AC,_,?CETAT_AC} ->        
	    {redirect, S, "#princ_ac_sms_ep_wap_ac"}; %% cas H
	{_,?CETAT_AC,?CETAT_AC} ->        
	    {redirect, S, "#princ_ep_sms_ac_wap_ac"}; %% cas N
	{?CETAT_AC,_,_} ->                
	    {redirect, S, "#princ_ac_sms_ep_wap_ep"}; %% cas E
	{_,?CETAT_AC,_} ->
	    {redirect, S, "#princ_ep_sms_ac_wap_ep"}; %% cas M
	{_,_,?CETAT_AC} ->
	    {redirect, S, "#princ_ep_sms_ep_wap_ac"}; %% cas P
	{?CETAT_PE,_,_} ->                
	    {redirect, S, "#perime"};
	{?CETAT_EP,_,_} ->         
	    {redirect, S, "#epuise"}    
    end.
	       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% redirect in function of state's  compte for niv 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
select_home_niv3(abs) ->
   	[ {redirect, abs, "#epuise"},
	  {redirect, abs, "#perime"},
	  {redirect, abs, "#temporary"},
	  {redirect, abs, "#princ_ac_sms_ac_wap_ac"},
	  {redirect, abs, "#princ_ac_sms_ac_wap_ep"},      
	  {redirect, abs, "#princ_ac_sms_ep_wap_ac"},
	  {redirect, abs, "#princ_ep_sms_ac_wap_ac"},
	  {redirect, abs, "#princ_ac_sms_ep_wap_ep"},
	  {redirect, abs, "#princ_ep_sms_ac_wap_ep"},
	  {redirect, abs, "#princ_ep_sms_ep_wap_ac"}
	 ];
select_home_niv3(S) ->
    State = svc_util_of:get_user_state(S),
    case {svc_compte:etat_cpte(State,cpte_princ),
	  svc_compte:etat_cpte(State,cpte_sms),
	  svc_compte:etat_cpte(State,cpte_wap)} of
	%% no cpte wap 
	{?CETAT_AC,?CETAT_AC,?CETAT_AC} ->
	    {redirect, S, "#princ_ac_sms_ac_wap_ac"}; %% cas C
	{?CETAT_AC,?CETAT_AC,_} ->        
	    {redirect, S, "#princ_ac_sms_ac_wap_ep"}; %% cas D
	{?CETAT_AC,_,?CETAT_AC} ->        
	    {redirect, S, "#princ_ac_sms_ep_wap_ac"}; %% cas H
	{_,?CETAT_AC,?CETAT_AC} ->        
	    {redirect, S, "#princ_ep_sms_ac_wap_ac"}; %% cas N
	{?CETAT_AC,_,_} ->                
	    {redirect, S, "#princ_ac_sms_ep_wap_ep"}; %% cas E
	{_,?CETAT_AC,_} ->               
	    {redirect, S, "#princ_ep_sms_ac_wap_ep"}; %% cas M
	{_,_,?CETAT_AC} ->                
	    {redirect, S, "#princ_ep_sms_ep_wap_ac"}; %% cas P
	{?CETAT_PE,_,_} ->                
	    {redirect, S, "#perime"};
	{?CETAT_EP,_,_} ->                
	    {redirect, S, "#epuise"};
	{E,F,G} ->
	  slog:event(warning, ?MODULE, mobi_unexpected_cpte_state_niv3, 
		     {State,E,F,G}),
	  {redirect, S, "#temporary"}
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% function use to print compte info in xml (include)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% Returns user's msisdn
msisdn(abs) -> [ {pcdata, "0612345678"} ];
msisdn(#session{prof=#profile{msisdn="+33"++National}}) ->
    [{pcdata, "0"++National}];
msisdn(#session{prof=#profile{msisdn="+99"++National}}) ->
    [{pcdata, "0"++National}];
msisdn(#session{prof=#profile{msisdn={na, _}}}) ->
    slog:event(warning, ?MODULE, msisdn_not_available),
    %% This should not be allowed to happen, but continue anyway.
    [{pcdata, "?"}];
msisdn(#session{prof=#profile{msisdn=Msisdn}}) ->
    [{pcdata, Msisdn}].

%% returns the end of phone number validity
fin_validite(abs) -> [ {pcdata, "31/12/99"} ];
fin_validite(#session{}=Session) ->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.etat_princ of
	?CETAT_AC ->    
	    %% in this case, dtl = fin_credit, we have to add periode de grace
	    Fin_valid = State#sdp_user_state.dlv + 
		periode_de_grace()*24*3600,
	    {{Y,Mo,D},{H,Mi,S}} = 
		calendar:now_to_datetime({Fin_valid div 1000000,
					  Fin_valid rem 1000000,0}),
	    Date=pbutil:sprintf("%02d/%02d/%02d", [D,Mo,Y rem 100]),
	    [{pcdata, lists:flatten(Date)}];
	_ ->
	    %% in all cases, return dtl directly
	    Fin_valid = State#sdp_user_state.dlv,
	    {{Y,Mo,D},{H,Mi,S}} = 
		calendar:now_to_datetime({Fin_valid div 1000000,
					  Fin_valid rem 1000000,0}),
	    Date=pbutil:sprintf("%02d/%02d/%02d", [D,Mo,Y rem 100]),
	    [{pcdata, lists:flatten(Date)}]
    end;
fin_validite(_) ->
    [{pcdata, "**inconnu**"}].

periode_de_grace() ->
    pbutil:get_env(pservices_orangef, periode_de_grace).

%% Returns the current plan description
plan(abs) -> [ {include,{relurl,"#inconnu"}}];
plan(S)->
    State= svc_util_of:get_user_state(S),
    Compte_P=State#sdp_user_state.cpte_princ,
    Plan = case Compte_P#compte.ptf_num of
	       X when X==?MCLAS;X==?PCLAS_V2;X==?PCLAS_SEC->
		   "#classique";
	       ?PSMM ->
		   "#matin";
	       ?PSMAM ->
		   "#apresmidi";
	       ?PSMS ->
		   "#soir";
	       ?PSMN ->
		   "#nuit";
	       ?MADRID2 ->
		   "#plug";
	       ?MOBI_ZAP ->
		   "#zap";
	        ?MOBI_ZAP_PROMO ->
		   "#zap_promo";
	       ?PLUG_NOEL ->
		   "#plug_noel";
	       X when X==?PSOIR_WE;X==?PSOIR_WE_SEC->
		   "#soir_we";
	       ?PLUGV3->
		   "#plug_noel";
	       ?PLUGV3_SEC ->
		   "#plug_noel"
	   end,
    [{include,{relurl,Plan}}].

%% Returns the description of current plan
descr_plan(abs) -> [ {include,{relurl,"#descr_inconnu"}}
	      ];

descr_plan(S) ->
    State = svc_util_of:get_user_state(S),
    Compte_P=State#sdp_user_state.cpte_princ,
    case Compte_P#compte.ptf_num of
	?PSMM ->
	    [{include,{relurl,"#descr_matin"}}];
	?PSMAM ->
	    [{include,{relurl,"#descr_apresmidi"}}];
	?PSMS ->
	    [{include,{relurl,"#descr_soir"}}];
	?PSMN ->
	    [{include,{relurl,"#descr_nuit"}}];
	?MADRID2 ->
	    [{include,{relurl,"#descr_plug"}}];
	?MOBI_ZAP ->
	    [{include,{relurl,"#descr_zap"}}];
	?MOBI_ZAP_PROMO ->
	    [{include,{relurl,"#descr_zap_promo"}}];
	?PLUG_NOEL ->
	    [{include,{relurl,"#descr_plug_noel"}}];
	X when X==?PSOIR_WE;X==?PSOIR_WE_SEC ->
	    [{include,{relurl,"#descr_soir_we"}}];
	_ ->
	    %% classique V1, V2, TAS
	    [{pcdata, ""}]
    end.

%% Returns the description of current plan
descr_wap(abs) -> [{include,{relurl,"#descr_wap"}}];
descr_wap(S)->
    State = svc_util_of:get_user_state(S),
    Compte_P=State#sdp_user_state.cpte_princ,
    Plan = case Compte_P#compte.ptf_num of
	       ?MADRID2 ->
		   "#descr_wap_plug";
	       ?PLUG_NOEL ->
		   "#descr_wap_plug_noel";
	       ?PLUGV3 ->
		   "#descr_wap_plug_noel";
	       _ ->
		   "#descr_wap"
	   end,
    [{include,{relurl,Plan}}].

%% Returns a string with sum expressed in the user's currency 
%% Sum = {eur, X} or Sum = {frf, X}
print_sum(?EURO, Sum) ->
    currency:print(currency:to_euro(Sum))++" EUR";
print_sum(?FRANC, Sum) ->
    currency:print(currency:to_frf(Sum))++" FRF";
print_sum(E1,E2) ->
    slog:event(internal, ?MODULE, bad_param_to_print_sum, {E1, E2}).


%% +type include_plug(session()) -> erlinclude_result().
include_plug(abs) ->
    [#hlink{href="#plug_vacances"},br,{pcdata,"OU"},
     #hlink{href="#mercredi_sms"}];

include_plug(Session) ->
    #sdp_user_state{d_activ=Activation}=svc_util_of:get_user_state(Session),
    Thr   = pbutil:universal_time_to_unixtime({{2004,1,22},{0,0,0}}),
    End_Mercredi = pbutil:universal_time_to_unixtime({{2004,4,15},{0,0,0}}),
    End_Vac =  pbutil:universal_time_to_unixtime({{2004,3,8},{0,0,0}}),
    Now   = pbutil:unixtime(),
    case (Activation < Thr) of
	true ->
         case (Now < End_Vac) of
	     true ->
		 [#hlink{href="#plug_vacances",
			 contents=[{pcdata,"Plan Orange Plug Vacances"}]},br];
	     false -> []
	 end;
	false ->
	    case (Now < End_Mercredi) of
		true -> 
		    [#hlink{href="#mercredi_sms",
			    contents=[{pcdata,"Les mercredi SMS"}]},br];
		_ -> []
	    end
    end.
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Service Options et Promotions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% on met a jour les données utiles dans tmp_serv
%% pour la suite des données de promo
%% puis on redirige sur la promo suivante
promo_start(abs,Url)->
    [{redirect,abs,Url}];
promo_start(Session,Url)->
    State = svc_util_of:get_user_state(Session),
    List_Promo=pbutil:get_env(pservices_orangef,promo_link_mobi),
    State_=State#sdp_user_state{tmp_promo=get_next_promo(List_Promo,State)},
    {redirect,svc_util_of:update_user_state(Session,State_),Url}.

%% +type print_first_link_promo(session(),PCDATA::string(),URL::string())->
%%                              [hlink()].	
print_first_link_promo(abs,PCDATA,URL)->
    [#hlink{href=URL,contents=[{pcdata, PCDATA}]}];
print_first_link_promo(Session,PCDATA,URL)->
    State = svc_util_of:get_user_state(Session),
    
    case odr_ort(Session) of
	{_ , _,"#odr_ort_no_rech"}->
	    List_Promo1_=pbutil:get_env(pservices_orangef,promo_link_mobi),
	    List_Promo=lists:delete({odr_ort,"#odr_ort_main"},List_Promo1_);
	
	{_, _, _} -> 
	    List_Promo=pbutil:get_env(pservices_orangef,promo_link_mobi)
    end,
    
    case get_next_promo(List_Promo,State) of
	{Url,T}->
	    [#hlink{href=URL,contents=[{pcdata, PCDATA}, br]}];
	no_link->
	    []
    end.

%% +type next_promo(session())-> erlpage_result().	
%%%% on met a jour les données utiles dans tmp_serv
%%%% pour la suite des données de promo
%%%% puis on redirige sur la promo suivante
next_promo(abs)->
    List_Promo=pbutil:get_env(pservices_orangef,promo_link_mobi),
    lists:flatten(lists:map(fun({C,Url})->
				    {redirect,abs,Url};
			       ({C,Url_A,Url_B})->
				    [{redirect,abs,Url_A},
				     {redirect,abs,Url_B}];
			       ({C,Url_A,Url_B,Url_C})->
				    [{redirect,abs,Url_A},{redirect,abs,Url_B},
				     {redirect,abs,Url_C}]
			    end,List_Promo));
next_promo(Session)->
    State = svc_util_of:get_user_state(Session),
    {State_, Url_} = case State#sdp_user_state.tmp_promo of
			 no_link -> 
			     slog:event(warning,?MODULE,no_next_promo_url),
			     {State,"#temporary"};
			 {Url,T} -> 			
			     {State#sdp_user_state{tmp_promo=
						   get_next_promo(T,State)},
			      Url}
		     end,
    {redirect,svc_util_of:update_user_state(Session,State_),Url_}.

%% +deftype promo() = {atom(),string()}.
%% +type get_next_promo([promo()],sdp_user_state())->
%%                      {string(),[promo()]} | nolink.
get_next_promo([{odr_ort,Url}|T],State)->
    case (((State#sdp_user_state.etats_sec band ?SETAT_AT)==0) and
	 ((State#sdp_user_state.etats_sec band ?SETAT_DE)==0)) of
	true ->
	    {Url,T};
	  
	_ -> get_next_promo(T,State)
    end;
  
get_next_promo([{Compte,Url}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url,T};
	_->
	    get_next_promo(T,State)
    end;

get_next_promo([{Compte,Url_AC,Url_EP}|T],State)
  when Compte==cpte_we_sms_illimite;Compte==cpte_we_mms_illimite->
    NextWeekend=
	case calendar:day_of_the_week(date()) < 6 of
	    true->
		svc_util_of:local_time_to_unixtime(
	  	  svc_util_of:next_week_date("samedi"))+7*86400;
	    false->
		svc_util_of:local_time_to_unixtime(
		  svc_util_of:next_week_date("samedi"))
	end,
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    #compte{dlv=DLV} = svc_compte:cpte(State,Compte),
	    case NextWeekend < DLV of
		true->
		    {Url_AC,T};
		_ ->{Url_EP,T}
	    end;
	Else->
	    get_next_promo(T,State)
    end;
get_next_promo([{Compte,Url_AC,Url_EP}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url_AC,T};
	?CETAT_EP->
	    {Url_EP,T};
	_->
	    get_next_promo(T,State)
    end;
get_next_promo([{Compte,Url_AC,Url_EP,Url_PE}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url_AC,T};
	?CETAT_EP->
	    {Url_EP,T};
	?CETAT_PE->
	    {Url_PE,T};
	_->
	    get_next_promo(T,State)
    end;
get_next_promo(L,S) ->
    no_link.

%% +type print_next_link_options(session())-> [hlink()].
print_next_link_promo(abs)->
    [#hlink{href="erl://svc_selfcare:next_promo", 
	    contents=[{pcdata, "suite"}]},br];
print_next_link_promo(Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.tmp_promo of
	{Url,T}->
	    [#hlink{href="erl://svc_selfcare:next_promo", 
		    contents=[{pcdata, "suite"}]},br];
	no_link->
	    []
    end.

%% +type activ_odr_ort(session())-> atom().
activ_odr_ort(Session)->
    {Session_new,State} = svc_options:check_topnumlist(Session),
    OPT_ODR_ACTIV = svc_options:is_option_activated(Session_new,opt_odr),
    OPT_ORT_ACTIV = svc_options:is_option_activated(Session_new,opt_ort),
    case {OPT_ODR_ACTIV, OPT_ORT_ACTIV} of
	{true, true} ->
	    NewSess = 
		get_opt_info2(Session_new,svc_options:top_num(opt_odr,mobi)),
	    {opt_odr_ort, NewSess};
	{false, false} ->
	    {no_opt, Session_new};
	{true, false} -> 
	    NewSess = 
		get_opt_info2(Session_new,svc_options:top_num(opt_odr,mobi)),
	    {opt_odr, NewSess};
	{false, true} ->
	    NewSess = 
		get_opt_info2(Session_new,svc_options:top_num(opt_ort,mobi)),
	    {opt_ort, NewSess}
    end.
	    
%% +type get_opt_info2(session(),TOPNUM::integer())-> 
%%                     session().
get_opt_info2(#session{prof=Prof}=Session, TOPNUM)->
    State = svc_util_of:get_user_state(Session),
    MSISDN = Prof#profile.msisdn,
    Id = {svc_util_of:get_souscription(Session),MSISDN},
    case svc_util_of:consult_account_options(Session, Id, TOPNUM) of
	{ok,[_, _, _, _, OPT_INFO2]} when OPT_INFO2=="1";
					  OPT_INFO2=="2";
					  OPT_INFO2=="3" ->
	    NewState = 
		State#sdp_user_state{c_op_opt_info2=
				     list_to_integer(OPT_INFO2)},
	    svc_util_of:update_user_state(Session,NewState);
	{ok,[_, _, _, _, OPT_INFO2]} ->
	    Session;
        {nok, Reason} ->
            slog:event(failure,?MODULE,get_opt_info2,
                       {nok, Reason}),
            Session;
	Error->
            slog:event(failure,?MODULE,get_opt_info2,Error),
	    Session
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Bonus                                  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type odr_ort(session())-> erlpage_result().
odr_ort(abs)->
    [
     {redirect,abs,"#no_opt_odr_inf_30"},
     {redirect,abs,"#no_opt_odr_sup_32"},
     {redirect,abs,"#opt_odr_r1_1ere_periode"},
     {redirect,abs,"#opt_odr_r1_2eme_periode"},
     {redirect,abs,"#opt_odr_r1_apres_periode2"},
     {redirect,abs,"#opt_odr_r2_2eme_periode"},
     {redirect,abs,"#opt_odr_r2_3eme_periode"},
     {redirect,abs,"#opt_odr_r2_apres_periode3"},
     {redirect,abs,"#opt_odr_r3_3eme_periode"},
     {redirect,abs,"#opt_odr_r3_apres_periode3"},
     {redirect,abs,"#opt_ort_r1_1ere_periode"},
     {redirect,abs,"#opt_ort_r1_2eme_periode"},
     {redirect,abs,"#opt_ort_r1_apres_periode2"},
     {redirect,abs,"#opt_ort_r2_2eme_periode"},
     {redirect,abs,"#opt_ort_r2_3eme_periode"},
     {redirect,abs,"#opt_ort_r2_apres_periode3"},
     {redirect,abs,"#opt_ort_r3_3eme_periode"},
     {redirect,abs,"#opt_ort_r3_apres_periode3"},
     {redirect,abs,"#odr_ort_no_rech"}];

odr_ort(Session)->
    {Opt, NewSession} = activ_odr_ort(Session),
    State = svc_util_of:get_user_state(NewSession),
    Now = pbutil:unixtime(),
    D_Activ = State#sdp_user_state.d_activ, 
    Opt_Info2 = State#sdp_user_state.c_op_opt_info2,
    case {Now-D_Activ, Opt, Opt_Info2} of
	%% Option ODR (TOP_NUM=103) not active
	{X, no_opt, _} when X =< 31*?DAY_IN_SEC ->
	    {redirect,Session,"#no_opt_odr_inf_30"};
	%% Option ORT (TOP_NUM=104) active, reload during first period
	{X, opt_ort, 1} when X =< 31*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_ort_r1_1ere_periode"};
	{X, opt_ort, 1} when X =< 62*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_ort_r1_2eme_periode"};
	%% Option ORT (TOP_NUM=104) active, reload during second period
	{X, opt_ort, 2} when X =< 62*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_ort_r2_2eme_periode"};
	{X, opt_ort, 2} when X =< 93*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_ort_r2_3eme_periode"};
	%% Option ORT (TOP_NUM=104) active, reload during third period
	{X, opt_ort, 3} when X =< 93*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_ort_r3_3eme_periode"};
	%% Option ODR (TOP_NUM=103) active, reload during first period
	%% or both ODR and ORT (TOP_NUM=104) active
	{X, _, 1} when X =< 31*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_odr_r1_1ere_periode"};
	{X, _, 1} when X =< 62*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_odr_r1_2eme_periode"};
	%% Option ODR (TOP_NUM=103) active, reload during second period
	%% or both ODR and ORT (TOP_NUM=104) active
	{X, _, 2} when X =< 62*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_odr_r2_2eme_periode"};
	{X, _, 2} when X =< 93*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_odr_r2_3eme_periode"};
	%% Option ODR (TOP_NUM=103) active, reload during third period
	%% or both ODR and ORT (TOP_NUM=104) active
	{X, _, 3} when X =< 93*?DAY_IN_SEC ->
	    {redirect,Session,"#opt_odr_r3_3eme_periode"};
	{X, _, _} ->
	    {redirect,Session,"#odr_ort_no_rech"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Options                                %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% on affiche le lien suivant si il y a une promo supplémentaires
print_next_link_options(abs)->
    [#hlink{href="erl://svc_selfcare:next_options", 
	    contents=[{pcdata, "suite"}]},br];
print_next_link_options(Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.tmp_options of
	{Url,T} ->
	    [#hlink{href="erl://svc_selfcare:next_options", 
		    contents=[{pcdata, "suite"}]},br];
	no_link->
	    []
    end.

print_first_link_options(abs)->
    [#hlink{href="erl://svc_selfcare:next_options", 
	    contents=[{pcdata, "Suivi Conso de mes options"}]},br];
print_first_link_options(Session)->
    State =svc_util_of:get_user_state(Session),
    case State#sdp_user_state.tmp_options of
	{Url,T} ->
	    [#hlink{href="erl://svc_selfcare:next_options", 
		    contents=[{pcdata, "Suivi Conso de mes options"}]},br];
	no_link->  
	    []
    end.
%% on met a jour les données utiles dans tmp_options
%% pour la suite des données de promo
%% puis on redirige sur la promo suivante
next_options(abs)->
    O_def=pbutil:get_env(pservices_orangef,options_link_mobi),
    Options=[{"default",O_def}],
    Redir=lists:map(fun({S,Opts})->
			    expand_abs_options(Opts,S)
		    end,Options),
    lists:flatten(Redir);

next_options(Session)->
    State =svc_util_of:get_user_state(Session),
    {Url,T}=State#sdp_user_state.tmp_options, 
    State_=State#sdp_user_state{tmp_options=get_next_options(T,State)},
    Session2 = svc_util_of:update_user_state(Session,State_),
    {redirect,Session2,Url}.

options(osl)->
    ?OETAT_KI;
options(vx_week)->
   ?OETAT_VWE;
options(_) ->
    0.

get_next_options([{{option,OPT},Url}|T],#sdp_user_state{option=Option}
		 =State)->
    case options(OPT) of
	undefined->
	    get_next_options(T,State);
	X when (Option band X)==X->
	    {Url,T};
	_->
	    get_next_options(T,State)
    end;
get_next_options([{Compte,Url}|T],State)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url,T};
	_ ->
	    get_next_options(T,State)
    end;
get_next_options([{Compte,Url_AC,Url_EP}|T],State) when atom(Compte)->
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {Url_AC,T};
	?CETAT_EP->
	    {Url_EP,T};
	_ ->
	    get_next_options(T,State)
    end;
get_next_options([{Compte,URL_AC,URL_EP,URL_EP_END}|T],
		 State) when atom(Compte)->
    %% cas godet renouvele periodiquement pendant un période determiné
    case svc_compte:etat_cpte(State,Compte) of
	?CETAT_AC->
	    {URL_AC,T};
	?CETAT_EP->
	    %% verifier si la date de fin de credit du godet dlv est depasse
            %% ou non
	    #compte{dlv=Dlv} = svc_compte:cpte(State,Compte),
	    {End_Options,_} =
                calendar:now_to_local_time({Dlv div 1000000,
                                            Dlv rem 1000000,0}),
	    case date()> End_Options of
		true->
		    {URL_EP_END,T};
		false->
		    {URL_EP,T}
	    end;
	_ ->
	    get_next_options(T,State)
    end;
get_next_options(L,S) ->
    no_link.


expand_abs_options(Opts,S)->
    lists:foldl(fun(X,Acc)->
			case X of
			    {C,Url} ->
				Acc++[{S,{redirect,abs,Url}}];
			    {C,Url_a,Url_b} ->
				Acc++[{S,{redirect,abs,Url_a}},
				      {S,{redirect,abs,Url_b}}];
			      {C,Url_a,Url_b,Url_c} ->
				Acc++[{S,{redirect,abs,Url_a}},
				      {S,{redirect,abs,Url_b}},
				      {S,{redirect,abs,Url_c}}]
			end end,[],Opts).

%%%%%%%%%%%%%%%%%%%% GESTION de L'options SMS %%%%%%%%%%%%%%%%%%%%%%%%%%%
options_sms_start(abs)->
    [{"deja active",{redirect,abs,"#is_active"}},
     {"non active",{redirect,abs,"#no_active"}},
     {"solde insuffisant",{redirect,abs,"#solde_insuffisant"}}];
options_sms_start(Session) ->
    %% cas etat_compte
    %% cas verif solde cpte princ
    State =svc_util_of:get_user_state(Session),
    Min_Price = pbutil:get_env(pservices_orangef,option_sms_min_balance),
    Now = pbutil:unixtime(),
    case currency:is_inf(svc_compte:solde_cpte(State,cpte_princ),
			 currency:sum(Min_Price)) of
	true->
	    {redirect,Session,"#solde_insuffisant"};
	false->
	    case svc_compte:cpte(State,cpte_rdl_sms) of		
		#compte{dlv=DLV} when DLV>Now->
		    %% actif
		    {redirect,Session,"#is_active"};
		_ ->
		    {redirect,Session,"#no_active"}
	    end
    end.

options_sms_souscription(abs)->
    [{"success",{redirect,abs,"#success"}},
     {"failed",{redirect,abs,"#failure"}}];
options_sms_souscription(#session{}=Session)->
    %% 2 tlv request
    % 1-> Requete de transfert
    #sdp_user_state{dos_numid=DOSNUMID} =svc_util_of:get_user_state(Session),
    case catch tlv_router:mk_INT_ID27(mobi,DOSNUMID,43) of
	[CPP_SOLDE,0,0]->
	    %% PSC_NUM=36 cout=7 EURO, NB JOUR=0
	    case catch tlv_router:mk_INT_ID14(mobi,DOSNUMID,36,7000,?EURO,
					      0,?C_PRINC) of
		[CPP_SOLDE2,0,0]->
		    %%ok => Success
		    %% update compte principal
		    {redirect,Session,"#success"};
		Error->
		    slog:event(failure, ?MODULE, options_sms_tlv_int_id14,
			       Error),   
		    {redirect,Session,"#failure"}
	    end;
	Error->
	    slog:event(failure, ?MODULE, options_sms_tlv_int_id27,
		       Error),   
	    {redirect,Session,"#failure"}
    end.

%% *autograph([
%%     { path, ["../../posutils/src", "."]},
%%     { actions, [ 
%%                ] },
%%     { inits, [ {start_selfcare,1}
%%                
%%              ] }
%%   ]).


%%%%%%%

omer_select_home(abs) ->
    [{redirect, abs, "#principal_ac_odr_ac"},
     {redirect, abs, "#principal_ep_odr_ac"},
     {redirect, abs, "#principal_pe_odr_ac"},
     {redirect, abs, "#principal_ac_odr_ep"},
     {redirect, abs, "#principal_ep_odr_ep"},
     {redirect, abs, "#principal_pe_odr_ep"},
     {redirect, abs, "#system_failure"}];

omer_select_home(#session{}=S) ->
    State= svc_util_of:get_user_state(S),
    case {svc_compte:etat_cpte(State,cpte_princ),
	  svc_compte:etat_cpte(State,cpte_odr)}of
	{?CETAT_AC,?CETAT_AC} ->
	    {redirect, S, "#principal_ac_odr_ac"};
	{?CETAT_AC, _} ->
	    {redirect, S, "#principal_ac_odr_ep"};
	{?CETAT_EP, ?CETAT_AC}  ->
	    {redirect, S, "#principal_ep_odr_ac"};
	{?CETAT_EP, _}  ->
	    {redirect, S, "#principal_ep_odr_ep"};
	{?CETAT_PE,?CETAT_AC} ->
	    {redirect, S, "#principal_ep_odr_ac"};
	{?CETAT_PE, _} ->
	    {redirect, S, "#principal_ep_odr_ep"};
	Else ->
	    slog:event(service_ko,?MODULE,omer_select_home,{Else,S}),
	    {redirect, S, "#system_failure"}    
    end.
