-module(svc_of_mvno).

%% XML export

-export([selfcare_mvno/5,
	 check_cpte/5,
	 print_dlv_dossier/1,
	 selfcare_mvno_niv/8,
	 print_credit_forf/2,option_active/4,
	 proposer_lien/3,
	 proposer_lien/5,
	 print_sms_forfait/2,
	 print_sms_forfait/3,
         print_nrj_bonus_text/1,
	 print_active_account/4
	]).


-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../include/subscr_asmetier.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLUGINS RELATED TO TELE2 AND TEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type selfcare_mvno(session(),Subscription::string(), Forf_act::string(), 
%%                      Forf_ep_cpte_ac::string(), Forf_ep_cpte_ep::string())->
%%                      erlpage_result(). 
%%%% Redirect according to the state of the accounts

selfcare_mvno(plugin_info, Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the credit",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [tele2_comptebloque,
				 carrefour_comptebloq,
				 nrj_comptebloque,
				 ten_comptebloque]}},
        "This parameter specifies the subscription."},
       {forf_act, {link,[]},
	"This parameter specifies the next page when cpte principal is active."},
       {forf_ep_cpte_ac, {link,[]},
	"This parameter specifies the next page when the cpte principal is out"
	" of credit, and the refill cpte is still active"},
       {forf_ep_cpte_ep, {link,[]},
	"This parameter specifies the next page when the cpte principal is out"
	" of credit, and the refill cpte is out of credit too"}
      ]});

selfcare_mvno(abs,Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep) ->
    [{redirect, abs, Forf_act},
     {redirect, abs, Forf_ep_cpte_ac},
     {redirect, abs, Forf_ep_cpte_ep}
    ];

selfcare_mvno(Session,Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep)
  when Subscription=="tele2_comptebloque" ->
    
    State = svc_util_of:get_user_state(Session),

    case {svc_compte:etat_cpte(State,forf_tele2_cb),
	  svc_compte:etat_cpte(State,cpte_princ)} of
	
	{?CETAT_AC,_} ->{redirect, Session, Forf_act};	
	{_,?CETAT_AC} ->{redirect, Session,  Forf_ep_cpte_ac};
	{_,_} -> {redirect, Session, Forf_ep_cpte_ep} 
    
    end;

selfcare_mvno(Session,Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep)
  when Subscription=="ten_comptebloque" ->
    
    State = svc_util_of:get_user_state(Session),

    case {svc_compte:etat_cpte(State,forf_ten_cb),
	  svc_compte:etat_cpte(State,cpte_princ)} of
	
	{?CETAT_AC,_} ->{redirect, Session, Forf_act};	
	{_,?CETAT_AC} ->{redirect, Session,  Forf_ep_cpte_ac};
	{_,_} -> {redirect, Session, Forf_ep_cpte_ep} 
    
    end;

selfcare_mvno(Session,Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep)
 when Subscription=="ten_comptebloque" ->

    State = svc_util_of:get_user_state(Session),

    case {svc_compte:etat_cpte(State,forf_nrj_cb),
          svc_compte:etat_cpte(State,cpte_princ)} of

        {?CETAT_AC,_} ->{redirect, Session, Forf_act};
        {_,?CETAT_AC} ->{redirect, Session,  Forf_ep_cpte_ac};
        {_,_} -> {redirect, Session, Forf_ep_cpte_ep}

    end;

selfcare_mvno(Session,Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep)
 when Subscription=="nrj_comptebloque" ->

    State = svc_util_of:get_user_state(Session),

    case {svc_compte:etat_cpte(State,forf_nrj_cb),
          svc_compte:etat_cpte(State,cpte_princ)} of

        {?CETAT_AC,_} ->{redirect, Session, Forf_act};
        {_,?CETAT_AC} ->{redirect, Session,  Forf_ep_cpte_ac};
        {_,_} -> {redirect, Session, Forf_ep_cpte_ep}

    end;

selfcare_mvno(Session,Subscription, Forf_act, Forf_ep_cpte_ac, Forf_ep_cpte_ep)
 when Subscription=="carrefour_comptebloq" ->

    State = svc_util_of:get_user_state(Session),

    case {svc_compte:etat_cpte(State,forf_carrefour_cb),
          svc_compte:etat_cpte(State,cpte_princ)} of

        {?CETAT_AC,_} ->{redirect, Session, Forf_act};
        {_,?CETAT_AC} ->{redirect, Session,  Forf_ep_cpte_ac};
        {_,_} -> {redirect, Session, Forf_ep_cpte_ep}

    end.
check_cpte(plugin_info, Subscription, Compte, Forf_act, Forf_ep) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the credit",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [nrj_comptebloque,nrj_prepaid]}},
        "This parameter specifies the subscription."},
       {compte, {oma_type, {enum, [forf_nrj_cb,cpte_princ,cpte_forf_nrj_sms,cpte_forf_nrj_data,cpte_forf_nrj_sms_bonus]}},
        "This parameter specifies the account's type."},
       {forf_act, {link,[]},
	"This parameter specifies the next page when cpte principal is active."},
       {forf_ep, {link,[]},
	"This parameter specifies the next page when the cpte principal is out"
	" of credit"}
      ]});

check_cpte(abs, Subscription, Compte, Forf_act, Forf_ep) ->
    [{redirect, abs, Forf_act},
     {redirect, abs, Forf_ep}
    ];

check_cpte(Session,Subscription,Compte, Forf_act, Forf_ep) ->
    State = svc_util_of:get_user_state(Session),
    Cpt=list_to_atom(Compte),
    case svc_compte:etat_cpte(State,Cpt) of         
        ?CETAT_AC ->{redirect, Session, Forf_act};
        _ -> {redirect, Session, Forf_ep}
    end.


selfcare_mvno_niv(plugin_info, Subscription, Forf_act_opt_act, Forf_act_opt_ep, Forf_ep_cpte_ac_opt_act,Forf_ep_cpte_ac_opt_ep, Forf_ep_cpte_ep_opt_act, Forf_ep_cpte_ep_opt_ep) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the credit",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [carrefour_comptebloq]}},
        "This parameter specifies the subscription."},
       {forf_act_opt_act, {link,[]},
        "This parameter specifies the next page when cpte principal is active."},
       {forf_act_opt_ep, {link,[]},
        "This parameter specifies the next page when cpte principal is active."},
       {forf_ep_cpte_ac_opt_act, {link,[]},
        "This parameter specifies the next page when the cpte principal is out"
        " of credit, and the refill cpte is still active"},
       {forf_ep_cpte_ac_opt_ep, {link,[]},
        "This parameter specifies the next page when the cpte principal is out"
        " of credit, and the refill cpte is still active"},
       {forf_ep_cpte_ep_opt_act, {link,[]},
        "This parameter specifies the next page when the cpte principal is out"
        " of credit, and the refill cpte is still active"},
       {forf_ep_cpte_ep_opt_ep, {link,[]},
        "This parameter specifies the next page when the cpte principal is out"
        " of credit, and the refill cpte is out of credit too"}
      ]});

selfcare_mvno_niv(Session, Subscription, Forf_act_opt_act, Forf_act_opt_ep, Forf_ep_cpte_ac_opt_act,Forf_ep_cpte_ac_opt_ep, Forf_ep_cpte_ep_opt_act, Forf_ep_cpte_ep_opt_ep)
 when Subscription=="carrefour_comptebloq" ->

    State = svc_util_of:get_user_state(Session),

    case {svc_compte:etat_cpte(State,forf_carrefour_cb),
	  svc_compte:etat_cpte(State,cpte_princ),
          svc_compte:etat_cpte(State,cpte_opt_carrefour)} of

        {?CETAT_AC,_,?CETAT_AC} ->{redirect, Session, Forf_act_opt_act};
        {?CETAT_AC,_,?CETAT_EP} ->{redirect, Session, Forf_act_opt_ep};
        {?CETAT_EP,?CETAT_AC,?CETAT_AC} ->{redirect, Session, Forf_ep_cpte_ep_opt_act};
        {?CETAT_EP,?CETAT_AC,?CETAT_EP} ->{redirect, Session, Forf_ep_cpte_ep_opt_ep};
        {?CETAT_EP,?CETAT_EP,?CETAT_AC} ->{redirect, Session, Forf_ep_cpte_ep_opt_act};
        {?CETAT_EP,?CETAT_EP,?CETAT_EP} ->{redirect, Session, Forf_ep_cpte_ep_opt_ep}

    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_credit_forf(session(),Subscription::string())-> 
%%                   [{pcdata,string()}].
%%%% Print account credit

print_credit_forf(plugin_info,Subscription) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit of the rechargeable account.",
      type = function,
      license = [],
      args = [
       {subscription, {oma_type, {enum, [tele2_comptebloque,
					 carrefour_comptebloq,
					 nrj_comptebloque,
					 ten_comptebloque]}},
        "This parameter specifies the subscription."}]});

print_credit_forf(abs,Subscription)->
    [{pcdata,"YYY.YY"}];

print_credit_forf(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,
		Subscription)
  when Subscription=="tele2_comptebloque" ->
    
State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,forf_tele2_cb) of
 	#compte{}=Compte->
 	    [{pcdata,svc_compte:print_cpte(Compte)}];
 	_ ->
 	    case svc_compte:cpte(State,forf_tele2_cb2) of
		#compte{}=Compte->
		    [{pcdata,svc_compte:print_cpte(Compte)}];
		Error->
		    slog:event(internal,?MODULE,error_in_print_main_credit,
			       {Error, MSISDN}),
		    [{pcdata,"inconnu"}]
	    end

    end;

print_credit_forf(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,
		Subscription)
  when Subscription=="ten_comptebloque" ->
    
State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,forf_ten_cb) of
 	#compte{}=Compte->
 	    [{pcdata,svc_compte:print_cpte(Compte)}];
 	Error ->
 	    slog:event(internal,?MODULE,error_in_print_main_credit,
		       {Error, MSISDN}),
 	    [{pcdata,"inconnu"}]
    end;

print_credit_forf(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,
                Subscription)
  when Subscription=="nrj_comptebloque" ->

State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,forf_nrj_cb) of
        #compte{}=Compte->
            [{pcdata,svc_compte:print_cpte(Compte)}];
        Error ->
            slog:event(internal,?MODULE,error_in_print_main_credit,
                       {Error, MSISDN}),
            [{pcdata,"inconnu"}]
    end;

print_credit_forf(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,
                Subscription)
  when Subscription=="carrefour_comptebloq" ->

State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,forf_carrefour_cb) of
        #compte{}=Compte->
            [{pcdata,svc_compte:print_cpte(Compte)}];
        Error ->
            slog:event(internal,?MODULE,error_in_print_main_credit,
                       {Error, MSISDN}),
            [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type proposer_lien(session(),Subscription::string(),URL::string())-> 
%%                   hlink().
%%%% Check whether link to subscription should be proposed in main menu.


proposer_lien(plugin_info,Subscription,URL) ->
    (#plugin_info
     {help =
      "This plugin function includes he link to the defined sub manu.",
      type = function,
      license = [],
      args = [
       {subscription, {oma_type, {enum, [ten_comptebloque,carrefour_comptebloq]}},
        "This parameter specifies the subscription."},
       {urls, {link,[]},
	"This parameter specifies the next page"}
       ]});

proposer_lien(abs, _, URL) ->
    [#hlink{href=URL,contents=[{pcdata,"Vos Options"}]}];

proposer_lien(Session,"carrefour_comptebloq",URL) ->
    State=svc_util_of:get_user_state(Session),
    case (svc_compte:etat_cpte(State,forf_carrefour_z1)==?CETAT_AC)or
     (svc_compte:etat_cpte(State,forf_carrefour_z2)==?CETAT_AC)or
     (svc_compte:etat_cpte(State,forf_carrefour_z3)==?CETAT_AC)or
     (svc_compte:etat_cpte(State,cpte_opt_carrefour)==?CETAT_AC)
	 of
     	true->
            [#hlink{href=URL,contents=[{pcdata,"Vos options"}]}];
        _ -> []
    end;

proposer_lien(Session,Subscription,URL) ->
    State=svc_util_of:get_user_state(Session),
%    Decl=State#sdp_user_state.declinaison,
    case svc_compte:cpte(State,cpte_ten_sms) of
	#compte{tcp_num=TCP_NUM}=Compte ->
	    [#hlink{href=URL,contents=[{pcdata,"Vos Options"}]}]++svc_util_of:add_br("br");
	_ -> []
    end.

proposer_lien(plugin_info, Subscription, Compte, PCD, URL) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [nrj_comptebloque,
					 nrj_prepaid]}},
        "This parameter specifies the subscription."},
       {compte, {oma_type, {enum, [forf_nrj_cb,
				   cpte_princ,
                                   cpte_forf_nrj_bonus,
				   cpte_forf_nrj_sms,
				   cpte_forf_nrj_data,
				   cpte_forf_nrj_wap,
				   cpte_nrj_europe,
				   cpte_nrj_maghreb,
				   cpte_nrj_afrique
				  ]}},

        "This parameter specifies the compte."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"}
      ]});

proposer_lien(abs, _, _, PCD, URL) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien(Session, Subscription, Compte, PCD, URL)
  when (Subscription =="nrj_comptebloque") and (Compte=="cpte_forf_nrj_wap")->		
    State = svc_util_of:get_user_state(Session),
    Cpt=list_to_atom(Compte),
    case (svc_compte:etat_cpte(State,Cpt)==?CETAT_AC)of
		true ->   
		    svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
		_ ->   
		    []
    end;

proposer_lien(Session0, Subscription, Compte, PCD, URL)
  when (Subscription =="nrj_comptebloque") and (Compte=="cpte_forf_nrj_bonus")->		
    {_,Session1}=svc_util_of:reinit_prepaid(Session0),
    {Session,State} = svc_options:check_topnumlist(Session1),
    C1=svc_options:is_option_activated(Session, opt_nrj_data_illimite),
    C2=(svc_compte:etat_cpte(State,cpte_nrj_mini_ff_voix)==?CETAT_AC),
    C3=(svc_compte:etat_cpte(State,cpte_nrj_mini_ff_sms_mms)==?CETAT_AC),
    case {C1, C2, C3} of
        {true,_,_}->
            svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
        {_,true,_}->
            svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
        {_,_,true}->
            svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
        {_,_,_}->
            []
    end;

proposer_lien(Session, Subscription, Compte, PCD, URL)
  when Subscription =="nrj_comptebloque";
       Subscription =="nrj_prepaid"->				  
    State = svc_util_of:get_user_state(Session),
    Cpt=list_to_atom(Compte),
    case (svc_compte:etat_cpte(State,Cpt)==?CETAT_AC)of
        true -> 
	    slog:event(trace,{?MODULE,?LINE},check_etat_cpte,{Cpt,actif}),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br("br");
	 _ ->
	    slog:event(trace,{?MODULE,?LINE},check_etat_cpte,{Cpt,not_actif}),
	    []
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type print_active_account(session(),Subscription::string(), Account::string(), URL::string())-> 
%%                   Url::hlink().
%%%% Check whether link to subscription should be proposed in main menu.


print_active_account(plugin_info,Subscription, Account, URL) ->
    (#plugin_info
     {help =
      "This plugin function includes he link to the defined sub manu.",
      type = function,
      license = [],
      args = [
       {subscription, {oma_type, {enum, [carrefour_comptebloq]}},
        "This parameter specifies the subscription."},
	      {account, {oma_type, {enum, [forf_carrefour_z1,
					   forf_carrefour_z2,
					   forf_carrefour_z3,
					   cpte_sms_ill,
					   forf_opt_carrefour,
					   opt_carrefour_sms_ill]}},
        "This parameter specifies account."},
       {url, {link,[]},
	"This parameter specifies the next page when account is active."}
       ]});

print_active_account(abs,Subscription, Account, Url)->
%%     [{pcdata,"Europe jusqu'au JJ/MM"}]++
%% 	[{pcdata,"Maghreb jusqu'au JJ/MM"}]++
%% 	[{pcdata,"Monde jusqu'au JJ/MM"}]++
%% 	[{pcdata,"Recharge SMS Illimites jusqu'au JJ/MM"}]++
%% 	[{pcdata,"SMS Illimites"}];
    {redirect, abs, Url};
print_active_account(Session,Subscription, "opt_carrefour_sms_ill", Url) ->
    State=svc_util_of:get_user_state(Session),
    Decl=State#sdp_user_state.declinaison,
    case Decl of
	_Decl when _Decl==135;
		   _Decl==136 ->
	    {redirect,Session, Url};
	_ ->
	    []
    end;
print_active_account(Session,Subscription, Account, Url)->
    State=svc_util_of:get_user_state(Session),
    Etat_cpte =svc_compte:etat_cpte(State,list_to_atom(Account)), 
    case Etat_cpte of
	1 ->
	    {redirect,Session, Url};
	_ -> 
	    []
    end.
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_sms_forfait(session(),Subscription::string())-> 
%%                   [{pcdata,string()}].
%%%% display the SMS forfait 


print_sms_forfait(plugin_info,Subscription) ->
    (#plugin_info
     {help =
      "This plugin function includes the number of the SMS option.",
      type = function,
      license = [],
      args = [
       {subscription, {oma_type, {enum, [ten_comptebloque]}},
        "This parameter specifies the subscription."}]});

print_sms_forfait(abs,_) ->
    [{pcdata,"YY"}];


print_sms_forfait(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Subscription) ->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,cpte_ten_sms) of
	#compte{tcp_num=TCP_NUM}=Compte ->
	    case TCP_NUM of
		?C_FORF_TEN_CB_20_SMS ->[{pcdata,"20"}];
		?C_FORF_TEN_CB_50_SMS ->[{pcdata,"50"}];
		?C_FORF_TEN_CB_100_SMS ->[{pcdata,"100"}]
	    end;
	Error ->
 	    slog:event(internal,?MODULE,error_in_print_sms_forfait,
		       {Error, MSISDN}),
 	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_sms_forfait(session(),Subscription::string(), Level::string())-> 
%%                   [{pcdata,string()}].
%%%% Display SMS formait


print_sms_forfait(plugin_info,Subscription,Level) ->
    (#plugin_info
     {help =
      "This plugin function includes the number of the SMS option.",
      type = function,
      license = [],
      args = 
      [
       {subscription, {oma_type, {enum, [ten_comptebloque]}},
	"This parameter specifies the subscription."},
       {level, {oma_type, {enum, [level_2,level_3]}},
	"This parameter specifies the handsim level"}
      ]});

print_sms_forfait(abs,_,Level) ->
    case Level of
	level_2 ->
	    [{pcdata,"Opt:XX SMS jusqu'au JJ/MM"}];
	level_3 -> 
	    [{pcdata,"YY"}]
    end;

print_sms_forfait(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Subscription,"level_3") ->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,cpte_ten_sms) of
	#compte{tcp_num=TCP_NUM}=Compte ->
	    case TCP_NUM of
		?C_FORF_TEN_CB_20_SMS ->[{pcdata,"20"}];
		?C_FORF_TEN_CB_50_SMS ->[{pcdata,"50"}];
		?C_FORF_TEN_CB_100_SMS ->[{pcdata,"100"}]
	    end;
	Error ->
 	    slog:event(internal,?MODULE,error_in_print_sms_forfait,
		       {Error, MSISDN}),
 	    [{pcdata,"inconnu"}]
    end;
print_sms_forfait(Session,Subscription,"level_2") ->
    State=svc_util_of:get_user_state(Session),
    Decl=State#sdp_user_state.declinaison,
    case Decl of 
	?ten_cb2 -> [{pcdata,"Opt:"}] ++
			svc_of_plugins:print_credit(Session,Subscription,"opt_sms_ten","sms") ++
			[{pcdata," SMS jusqu'au "}] ++
			svc_of_plugins:print_end_credit(Session,"opt_sms_ten","dm");
	_ -> []
    end.

option_active(plugin_info, Opt, UAct, UNotAct) ->
    (#plugin_info
     {help = 
      "This plugin command redirects to the corresponding page depending on"
      " whether the option is activated or not",
      type = command,
      license = [],
      args = [{option, {oma_type, {enum, [opt1_tele2_cb_25sms,
					  opt1_tele2_cb_50sms,
					  opt1_tele2_cb_100sms,
					  opt1_tele2_cb_illimite
					  ]}},
	       "This parameter specifies the option."},
	      {uact, {link,[]},
	       "This parameter specifies the next page when the option"
	       " is activated."},
	      {unotact, {link, []},
	       "This paramter specifies the next page when the option"
	       " is not activated"}
	     ]});
option_active(abs,_,UAct,UNotAct) ->
    [{redirect,abs,UAct},
     {redirect,abs,UNotAct}];
option_active(Session,Opt,UAct,UNotAct) ->
    case svc_options:is_option_activated(Session,list_to_atom(Opt)) of
	true -> 
	    {redirect,Session,UAct}; 
	false ->
	    {redirect,Session,UNotAct}
    end. 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_dlv_dossier(session())-> 
%%                         hlink().
%%%%
print_dlv_dossier(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes the validating date of profile.",
      type = function,
      license = [],
      args = [
       ]});

print_dlv_dossier(abs) ->
    [{pcdata,"DD/MM/YY"}];

print_dlv_dossier(Session) ->
    svc_selfcare:fin_validite(Session).
print_nrj_bonus_text(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin print nrj bonus",
      type = function,
      license = [],
      args = [
       ]});

print_nrj_bonus_text(abs) ->
    [{pcdata,""}];
print_nrj_bonus_text(Session0)->
    {_,Session1}=svc_util_of:reinit_prepaid(Session0),
    {Session,State} = svc_options:check_topnumlist(Session1),
    C1=svc_options:is_option_activated(Session, opt_nrj_data_illimite),
    C2=svc_compte:etat_cpte(State,cpte_nrj_mini_ff_voix),
    C3=svc_compte:etat_cpte(State,cpte_nrj_mini_ff_sms_mms),
    Text0="Vous disposez de :\n",
    Text1= case C1 of
        true->
            "Bonus Internet: illimite\n";
        _->
            []
        end,
    Text2= case C2 of
        ?CETAT_AC->
            Solde_voix=svc_compte:solde_cpte(State,cpte_nrj_mini_ff_voix), 
            Money_voix=currency:print(currency:to_euro(Solde_voix)),
            [N1,N2]=string:tokens(Money_voix,"."),
            "Bonus Appels: "++N1++","++N2++"E\n";
        _->
            []
        end,
    Text3= case C3 of
        ?CETAT_AC->
            Solde_sms=svc_compte:solde_cpte(State,cpte_nrj_mini_ff_sms_mms), 
            Money_sms=currency:print(currency:to_euro(Solde_sms)),
            [Num1,Num2]=string:tokens(Money_sms,"."),
            "Bonus SMS/MMS: "++Num1++","++Num2++"E";
        _->
            []
        end,
   [{pcdata,Text0++Text1++Text2++Text3}].
