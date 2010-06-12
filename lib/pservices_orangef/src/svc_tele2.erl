-module(svc_tele2).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/tele2.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../pfront_orangef/include/sdp.hrl").


-define(TCK_KEY_TYPE, "2").
-define(TTK_num_prefere,  173).
-define(Max_nums_preferes, 10).
%%%% This function is the equivalent of proposer_lien in mobi and cmo.
%%%% It gives the link if commercially launched
%% +type redirect_if_comm_launched(session(),string(),string())-> 
%%               hlink().
redirect_if_comm_launched(abs,_,PCD_URLs) ->
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),    
    svc_util_of:add_br("br") ++ [#hlink{href=URL,contents=[{pcdata,PCD}]}];
redirect_if_comm_launched(Session,Type_recharg,PCD_URLs) ->
    case svc_util_of:is_commercially_launched(Session,
					      list_to_atom(Type_recharg)) of
	true ->    
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    svc_util_of:add_br("br") ++ [#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false ->
	    []
    end.

print_link_by_account_state(abs, _Account, PCD_URLs) ->
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),    
    svc_util_of:add_br("br") ++ [#hlink{href=URL,contents=[{pcdata,PCD}]}];
print_link_by_account_state(Session, Account, PCD_URLs) ->
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    Account_name = list_to_atom(Account),
    case svc_compte:etat_cpte(svc_util_of:get_user_state(Session), Account_name) of
	?CETAT_AC->
	    svc_util_of:add_br("br") ++ [#hlink{href=URL,contents=[{pcdata,PCD}]}];
	?CETAT_EP->
	    svc_util_of:add_br("br") ++ [#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
	    []
    end.

print_if_single_account(abs,Text) ->
    [{pcdata,Text}];
print_if_single_account(Session,Text) ->
    Roaming_state = 
        svc_compte:etat_cpte(svc_util_of:get_user_state(Session),cpte_roaming),
    SMS_illm_state = 
        svc_compte:etat_cpte(svc_util_of:get_user_state(Session),cpte_sms_ill),
    Num_prefere_state =
        svc_compte:etat_cpte(svc_util_of:get_user_state(Session),cpte_num_prefere),
    
    case (Roaming_state == ?CETAT_AC) or (Roaming_state == ?CETAT_EP) or
        (SMS_illm_state == ?CETAT_AC) or (SMS_illm_state == ?CETAT_EP) or 
	(Num_prefere_state == ?CETAT_AC) or (Num_prefere_state == ?CETAT_EP) of
        true -> [];
        false ->[{pcdata,Text}]
    end.



%%%%% get sdp_user_state in assoclist 
%% +type init_svc_data(session(),URL::string())->erlpage_result().
init_svc_data(abs,URL)->
    [{redirect,abs,URL}];
init_svc_data(#session{svc_data=#sdp_user_state{}=US}=S,URL)->
    S1=variable:update_value(S#session{svc_data=none},user_state,US),
    {redirect,S1,URL};
init_svc_data(S,URL) ->
    {redirect,S,URL}.

%% +type enter_rech(session(),URL::string())-> erlpage_result().
enter_rech(abs,URL)->
    [{redirect,abs,URL}];
enter_rech(Session,URL) ->
    %% get config
    #recharge_tele2_cfg{tentative=N}=get_config(recharge_tele2),
    %% initialisation recharge_pp
    %% stockage dans svc_data.
    Session2=variable:update_value(Session,
				   recharge_tele2,
				   #recharge_pp{c_code_secret=N}),
    {redirect,Session2,URL}.

%% +type inc_choix_montant(session())-> [hlink()].
inc_choix_montant(_)->
    Rech_cfg=get_config(recharge_tele2),
    List_Montant=Rech_cfg#recharge_tele2_cfg.liste_montant,
    lists:map(fun({Val,Bonus}) -> 
		      Prix=integer_to_list(trunc(Val/1000)),
		      Contents = Prix++" EUR",
		      HREF = "erl://"++?MODULE_STRING++":saisie_montant?"++
			  integer_to_list(Val)++"&"++integer_to_list(Bonus), 
		      #hlink{href=HREF,contents=[{pcdata,Contents},br]} end,
	      List_Montant).

%% +type saisie_montant(session(),MNT::string(),BNS::string())-> erlpage_result().
saisie_montant(abs,Montant,Bonus)->
    [{redirect,abs,"#confirm_recharge"},
     {redirect,abs,"#temporary"}];
saisie_montant(Session,Montant,Bonus)->
    case pbutil:all_digits(Montant) of
	true->
	    %% stocker montant et bonus
	    NSession=update_info(Session,recharge_tele2,
				 [{montant,list_to_integer(Montant)},
				  {bonus,list_to_integer(Bonus)}]),
	    {redirect,NSession,"#confirm_recharge"};
	false->
	    slog:event(service_ko,?MODULE,montant_incorrect,Montant),
	    {redirect,Session,"#temporary"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Verification Code TLR %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type verif_code_secret(session(),CODE::string())-> 
%%                      erlpage_result().
verif_code_secret(abs,Code)->
    [{redirect,abs,"#format_cs_nok"}]
	++recharge(abs);
verif_code_secret(Session,Code)->
    %% get tentative
    Rech_cfg=get_info(Session,recharge_tele2),
    F_TENTA=Rech_cfg#recharge_pp.c_code_secret,
    case {is_code(Code,4),F_TENTA} of
	{_,0}->
	    {redirect,Session,"#cs_blocked"};
	{true,_}->
	    %% store TLR
	    NSession=update_info(Session,recharge_tele2,
				 [{code_secret,Code}]),
	    recharge(NSession);
	{false,_}->
	    %% updat tentative
	    NSession=update_info(Session,recharge_tele2,
				 [{c_code_secret,F_TENTA-1}]),
	    {redirect,NSession,"#format_cs_nok"}
    end.

%% +type is_code(CODE::string(),Length::integer())-> 
%%                      bool().
is_code(Code,Length) when length(Code)=/=Length->
    false;
is_code(Code,Length)->
    pbutil:all_digits(Code).

%% +type recharge(session())-> erlpage_result().
recharge(abs)->
    [{"succes",{redirect,abs,"#success"}},
     {"invalid",{redirect,abs,"#cs_invalid"}},
     {"blocked",{redirect,abs,"#cs_blocked"}},
     {"timeout",{redirect,abs,"#timeout"}},
     {"inactif",{redirect,abs,"#cl_inactif"}},
     {"temporary",{redirect,abs,"#temporary"}}];
recharge(Session)->
    %% Config 
    #recharge_tele2_cfg{url=URL,host=V_Host,origine=ORI,
			port=Port,routing=Routing,timeout=Timeout}=
	get_config(recharge_tele2),
    #recharge_pp{montant=Montant,code_secret=CS}=
	get_info(Session,recharge_tele2),
    P_ENCODE=[{"ORDRE","RECHARGE"},{"VERSION","1"},
	      {"ORIGINE",ORI},
	      {"MSISDN",value_of_session(Session,"msisdn")},
	      {"IMSI",value_of_session(Session,"imsi")},
	      {"MONTANT",Montant},{"CODE_CONFIDENTIEL",CS}],
    P_DECODE=[{"MSISDN","%s"},{"IMSI","%s"},{"SOLDE","%d"},{"DLV","%d"}],
    %% check status and print solde in #success
    case catch ascii_over_http:request(URL, V_Host, Port, Routing, 
				       P_ENCODE, P_DECODE, Timeout) of
	{ok,[_,_,Solde,DLV]}->
	    %% update compte Principal
	    {redirect,update_compte(Session,Solde,DLV),"#success"};
	{statut,?er_cs_invalid} ->
	    %% error Case
	    Rech_cfg=get_info(Session,recharge_tele2),
	    F_TENTA=Rech_cfg#recharge_pp.c_code_secret,
	    NSession=update_info(Session,recharge_tele2,
				 [{c_code_secret,F_TENTA-1}]),
	    {redirect,NSession,"#cs_invalid"};
	{statut,?er_cs_blocked} ->
	    {redirect,Session,"#cs_blocked"};
	{statut,timeout}->
	    {redirect,Session,"#timeout"};
	{statut,?er_inactif_user}->
	    {redirect,Session,"#cl_inactif"};
	E ->
	    slog:event(failure,?MODULE,recharge_failed,E),
	    {redirect,Session,"#temporary"}
    end.

%% +type value_of_session(session(),string())-> string().
value_of_session(Session,"imsi")->
    (Session#session.prof)#profile.imsi;
value_of_session(Session,"msisdn")->
    case (Session#session.prof)#profile.msisdn of
	"+"++MS->
	    MS;
	_->
	    ""
    end.

%% +type print_info(session(),string())-> [{pcdata,string()}].
print_info(abs,_)->
    [{pcdata,"XXX"}];
print_info(Session,"montant")->
    Rech=get_info(Session,recharge_tele2),
    #recharge_pp{montant=Montant}=Rech,
    Prix=integer_to_list(trunc(Montant/1000)),
    [{pcdata,Prix}];
print_info(Session,"bonus") ->
    Rech=get_info(Session,recharge_tele2),
    #recharge_pp{bonus=Bonus}=Rech,
    Prix=io_lib:format("~.1f", [Bonus/1000]),
    [{pcdata,lists:flatten(Prix)}].


%% +type get_config(atom())-> recharge_tele2_cfg().
get_config(recharge_tele2) ->
    Fields = record_info(fields, recharge_tele2_cfg),
    HH = #recharge_tele2_cfg{}, %%%% Uses default values
    %%%% Read the default permissions.
    {_,Config} = pbutil:get_env(pservices_orangef, recharge_tele2),
    pbutil:update_record(Fields, HH, Config).

%% +type get_info(session(),atom())-> recharge_pp().
get_info(Session,recharge_tele2)->
    variable:get_value(Session,recharge_tele2).

%% +type update_info(session(),atom(),term())-> term().
update_info(Session,recharge_tele2,Updates)->
    Rech=get_info(Session,recharge_tele2),
    Fields = record_info(fields, recharge_pp),
    Rech2=pbutil:update_record(Fields, Rech, Updates),
    variable:update_value(Session,recharge_tele2,Rech2).

update_info_numpref(Session,Value)->
    Rech_cfg=get_info(Session,recharge_tele2),
    NSession=update_info(Session,recharge_tele2,
			 [{c_no_prefere,Value}]).
    

%% +type update_compte(session(),Solde::integer(),DLV::integer())-> session().
update_compte(Session,Solde,DLV)->
    State=svc_util_of:get_user_state(Session),
    Compte= svc_compte:cpte(State,cpte_princ),
    Compte2=Compte#compte{dlv=DLV,
			  cpp_solde=
			  svc_compte:calcul_solde(Solde,?EURO)},
    State2=svc_util_of:update_field(State,[{cpte_princ,Compte2}]),
    variable:update_value(Session,user_state,State2).

select_numpref_home(abs, _, Link_ok_numpref1, Link_ok_numpref5, Link_ok_numpref10, Link_nok)->
    [{redirect, abs, Link_ok_numpref1},
     {redirect, abs, Link_ok_numpref5},
     {redirect, abs, Link_ok_numpref10},
     {redirect, abs, Link_nok}
    ];
    
select_numpref_home(Session, Service, Link_ok_numpref1, Link_ok_numpref5, Link_ok_numpref10, Link_nok) 
  when Service=="tele2";Service=="casino"->
    NState = svc_recharge_tele2:update_user_state_numpref_list(Session),
    List = NState#sdp_user_state.numpref_list,
    case List of 
	undefined ->
	    {redirect, Session, Link_nok};
	_ ->
	    case svc_compte:etat_cpte(NState,cpte_num_prefere) of 
		?CETAT_AC -> 
		    case length(List) of
			1 ->
			    {redirect, Session, Link_ok_numpref1};
			X when X >1, X =< 5 ->
			    {redirect, Session, Link_ok_numpref5};
			X when X > 5, X =<10  ->
			    {redirect, Session, Link_ok_numpref10};
			_ ->
			    {redirect, Session, "#temporary"}
		    end;
		_ ->
		    {redirect, Session, Link_nok}
	    end
    end.
    
redir_by_ttk_numerof(plugin_info,Url_ok_numerof, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on ttk",
      type = command,
      license = [],
      args =
      [
       {url_ok_numerof, {link,[]},
	"This parameter specifies the page if ttk=173"},
       {url_ok, {link,[]},
	"This parameter specifies the page if ttk # 173."},
       {url_nok, {link,[]},
	"This parameter specifies the error page"}
      ]
     }
    );
	  
redir_by_ttk_numerof(abs,Url_ok_numerof,Url_ok,Url_nok)->
    [
     {redirect, abs, Url_ok_numerof},
     {redirect,abs,  Url_ok},
     {redirect,abs, Url_nok}
    ];
redir_by_ttk_numerof(#session{prof=Profile}=Session,Url_ok_numerof,Url_ok,Url_nok)->    
    Msisdn = Profile#profile.msisdn,
    Sub = Profile#profile.subscription,
    Code = variable:get_value(Session, {recharge,"code"}),		
    case svc_recharge:send_consult_rech_request(Session, 
                                                {list_to_atom(Sub),Msisdn}, 
                                                ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    case svc_recharge:get_ttk(Session, c_tck, Answer_tck) of
		?TTK_num_prefere ->
		    case svc_util_of:is_commercially_launched(Session,recharge_numpref) of
			true->
			    {redirect, Session, Url_ok_numerof};
			_->
			    {redirect, Session, Url_nok}
		    end;
		TTK -> 
		    {redirect, Session, Url_ok}
	    end;
	_ ->
	    {redirect, Session, Url_nok}
    end.
	
print_numero_prefere(plugin_info)->
    (#plugin_info
     {help = 
      "This plugin print favourite number.",
      type = function,
      license = [],
      args = []
	  });
print_numero_prefere(abs)->    
    [{pcdata,"XXXXXXXXXX"}];
print_numero_prefere(Session) ->
    State = svc_util_of:get_user_state(Session),
	[{pcdata,State#sdp_user_state.numero_prefere}].
	
redir_by_numpref_list(plugin_info,Url_credit_null,Url_one_number,Url_up_to_five,Url_more_than_five,Url_system_failure)->
    (#plugin_info
     {help = 
      "This plugin redirect by length of favourite numbers list.",
      type = command,
      license = [],
      args = [
	      {url_credit_null, {link,[]},
	       "This parameter specifies the page when credit = 0 "},
	      {url_one_number, {link,[]},
	       "This parameter specifies the page when there is one favourite number."},
	      {url_up_to_five, {link,[]},
	       "This parameter specifies the page when there are less than 5 favourite numbers"},
	      {url_more_than_five, {link,[]},
	       "This parameter specifies the page when there are more than 5 favourite numbers"},
	      {url_system_failure, {link,[]},
	       "This parameter specifies the system failure page"}
	     ]
     }
    );	
	  
redir_by_numpref_list(abs,Url_credit_null,Url_one_number,Url_up_to_five,Url_more_than_five, Url_system_failure)->        
    [
     {redirect,abs, Url_credit_null},
     {redirect,abs, Url_one_number},
     {redirect,abs, Url_up_to_five},
     {redirect,abs, Url_more_than_five},
     {redirect,abs, Url_system_failure}
    ];
	
redir_by_numpref_list(Session,Url_credit_null,Url_one_number,Url_up_to_five,Url_more_than_five, Url_system_failure) ->
    NState =  svc_recharge_tele2:update_user_state_numpref_list(Session),
    List = NState#sdp_user_state.numpref_list,
    case List of 
	undefined ->
	    {redirect, Session, Url_credit_null};
	_ ->
	    case svc_compte:etat_cpte(NState,cpte_num_prefere) of 
		?CETAT_AC -> 
		    case length(List) of
			1 ->
			    {redirect, Session, Url_one_number};
			X when X >1, X =< 5 ->
			    {redirect, Session, Url_up_to_five};
			X when X > 5, X =<10  ->
			    {redirect, Session, Url_more_than_five};
			_ ->
			    {redirect, Session, Url_credit_null}
		    end;
		_ ->
		    {redirect, Session, Url_credit_null}
	    end
    end.

print_numpref_list(plugin_info)->
    (#plugin_info
     {help = 
      "This plugin print list of favourite numbers.",
      type = function,
      license = [],
      args = []
     }
    );	
	  
print_numpref_list(abs)->        
    [{pcdata,"06XXXXXXXX, 06XXXXXXXX,..."}];
print_numpref_list(Session) ->
    State = svc_recharge_tele2:update_user_state_numpref_list(Session),
    List = State#sdp_user_state.numpref_list,
    case List of
	undefined ->
            [{pcdata,"inconnu"}];
	_->
	    case length(List) of
		undefined ->
		    [{pcdata,"inconnu"}];
		1 ->
		    [{pcdata,lists:last(List)}];
		_ ->
		    [{pcdata, get_numpref(List)}]
	    end
    end.

is_correct_number(Number)->
    case (is_list(Number) andalso (length(Number)==10) andalso
          pbutil:all_digits(Number)) of
        true ->
	    [$0,H1,H2|_] = Number,
	    Valid = lists:member(H1,[$6,$1,$2,$3,$4,$5,$7,$9]) or ((H1==$8) and (H2==$7)),
	    case Valid of
		true->
		    {ok, Number};
                _ ->
                    {nok,invalid_number}
            end;
        false ->
            {nok,invalid_number}
    end.

	
redir_if_correct_number(plugin_info, Subscription, Uok, Ucode_incorrect,
		       Ucode_incorrect_last, Number_try, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether on the correctness of the entered code.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [tele2_comptebloque]}},
        "This parameter specifies the subscription."},

       {uok, {link,[]},
	"This parameter specifies the next page when the entered code"
	" is correct."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when first trial for code"
	" ended in format incorrect."},
       {ucode_incorrect_last, {link,[]},
	"This parameter specifies the next page when second trial for code"
	" ended in format incorrect."},
       {number_try, {oma_type, {enum, [1,2,3,4,5]}},
        "This parameter specifies the number of try."},
       {number, form_data,
        "This parameter specifies the 10 digit number to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

redir_if_correct_number(abs,_, Uok, Ucode_incorrect, Ucode_incorrect_last,
		       Number_try, Code) ->
    [{redirect, abs, Uok},
     {redirect, abs, Ucode_incorrect},
     {redirect, abs, Ucode_incorrect_last}];

redir_if_correct_number(Session, Subscription, Uok, Ucode_incorrect,
		       Ucode_incorrect_last, Number_try, Code) ->
    case is_correct_number(Code) of
	{nok, _} ->
	    case X=variable:get_value(Session,{recharge_tele2,"nb_code_trials"}) of
		not_found->
		    Session_nok = variable:update_value(Session,{recharge_tele2,"nb_code_trials"},"1"),
		    {redirect, Session_nok, Ucode_incorrect};
		_ ->		     
		    Session_nok =variable:update_value(Session,{recharge_tele2,"nb_code_trials"},
						      integer_to_list(list_to_integer(X)+1)),
		    case variable:get_value(Session_nok,{recharge_tele2,"nb_code_trials"}) of
			Number_try-> 
			    {redirect, Session, Ucode_incorrect_last};
			_ ->
			    {redirect, Session_nok, Ucode_incorrect}
		    end
	    end;
	{ok, Number}  ->
	    State = svc_util_of:get_user_state(Session),
	    State_2 = State#sdp_user_state{numero_prefere=Number},
	    Session2=svc_util_of:update_user_state(Session, State_2),
	    {redirect,Session2,Uok}
    end.

get_numpref([]) -> "";
get_numpref([H|T]) ->
    H++", "++get_numpref(T).
	
update_sdp_user_state([Number|TAIL],State,Number,ACC)->    
    State#sdp_user_state{numpref_list=ACC++Number++TAIL};
update_sdp_user_state([CURRENT|TAIL],State,Number,ACC)->
    update_sdp_user_state(TAIL,State,Number,ACC++[CURRENT]);
update_sdp_user_state([],State,Number,ACC) ->
    State#sdp_user_state{numpref_list=ACC++Number}.
	
do_confirm(plugin_info,Opt, Uok,U_sys_failure, U_bad_profil, U_incompatible, U_promo,U_bad_code) ->
    (#plugin_info
     {help =
      "This plugin command do recharge confirm",
      type = command,
      license = [],
      args =
      [
	{opt, {oma_type, {enum, [opt_numpref_tele2]}},
	"This parameter specifies the option"},
        {uok, {link,[]},
	"This parameter specifies the success page"},
        {u_sys_failure, {link,[]},
	"This parameter specifies the success page"},
        {u_bad_profil, {link,[]},
	"This parameter specifies the success page"},
        {u_incompatible, {link,[]},
	"This parameter specifies the success page"},
        {u_promo, {link,[]},
	"This parameter specifies the success page"},
	{u_bad_code, {link,[]},
	"This parameter specifies the bad profile page"}
      ]
     }
    );
do_confirm(abs, _, Uok, U_sys_failure, U_bad_profil, U_incompatible, U_promo,U_bad_code)->
    [
     {redirect,abs, Uok},
     {redirect,abs, U_sys_failure},
     {redirect,abs, U_bad_profil},
     {redirect,abs, U_incompatible},
     {redirect,abs, U_promo},
     {redirect,abs, U_bad_code}
    ];
	
do_confirm(#session{prof=Profile}=Session, Opt,Uok,U_sys_failure, 
           U_bad_profil, U_incompatible, U_promo,U_bad_code)->
      case svc_util_of:do_consultation(Session,list_to_atom(Opt)) of
          {ok,[Zone70, Zone80, _]}->
	      State = svc_util_of:get_user_state(Session),
	      NZone80 = svc_recharge_tele2:update_z80(Zone80, Session, list_to_atom(Opt)),
	      StateZ80 = svc_compte:decode_z80(NZone80,State),
	      NewSession = svc_util_of:update_user_state(Session,StateZ80),
	      {Session_1,Result} = svc_recharge_tele2:do_opt_cpt_request(NewSession,list_to_atom(Opt),subscribe),
	      case Result of 
		  {ok_operation_effectuee,_,_} ->
		      do_recharge_D6(Session_1,Uok,U_sys_failure, U_bad_profil, 
                                     U_incompatible, U_promo,U_bad_code, Zone80);
                  {nok_msisdn_inconnu,_} ->
		      {redirect, NewSession, U_bad_profil};	
                  {error, "msisdn_inconnu"} ->
		      {redirect, NewSession, U_bad_profil};	
		  _ ->
		      {redirect, NewSession,U_sys_failure}
	      end;
          {ok, {Session_new, Resp_params}} ->
              Zone80 = svc_sachem:get_msisdns_info(Resp_params),
              NewSession = svc_recharge_tele2:update_decode_z80(
                             Session, Resp_params, Zone80,list_to_atom(Opt)),
	      {Session_1,Result} = svc_recharge_tele2:do_opt_cpt_request(NewSession,
                                                         list_to_atom(Opt),
                                                         subscribe),
	      case Result of 
		  {ok_operation_effectuee,_,_} ->
		      do_recharge_D6(Session_1,Uok,U_sys_failure, U_bad_profil, 
                                     U_incompatible, U_promo,U_bad_code, Zone80);
		  {nok_msisdn_inconnu,_} ->
		      {redirect, NewSession, U_bad_profil};			   
                  {error, "msisdn_inconnu"} ->
		      {redirect, NewSession, U_bad_profil};	
		  _ ->
		      {redirect, NewSession,U_sys_failure}
	      end;
	  {nok_opt_inexistante_dossier,_} ->
	      State = svc_util_of:get_user_state(Session),
	      NSession = svc_util_of:update_user_state(Session,State),
	      {Session_1,Result} = svc_recharge_tele2:do_opt_cpt_request(
                     NSession,list_to_atom(Opt),subscribe),
	      case Result of
                  {ok_operation_effectuee,_,_} ->
                      do_recharge_D6(Session_1,Uok,U_sys_failure, U_bad_profil, 
                                     U_incompatible, U_promo,U_bad_code, []);
                  {nok_msisdn_inconnu,_} ->
                      {redirect, NSession, U_bad_profil};
                  {nok, msisdn_inconnu} ->
		      {redirect, NSession, U_bad_profil};	
                  Error ->
                      slog:event(failure, ?MODULE, do_opt_cpt, Error),
                      {redirect, NSession, U_sys_failure}
              end;
          Error ->
              slog:event(failure, ?MODULE, do_consultation, Error),
              {redirect, Session, U_sys_failure}
      end. 

%%%% Do request of rechargement D6
%% +type do_recharge_D6(session(),Opt::string())-> erlpage_result().    
do_recharge_D6(Session,Uok,U_sys_failure, U_bad_profil, U_incompatible, U_promo,U_bad_code, Zone80) ->    
    Profile = Session#session.prof,
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 1,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code,
                                            pbutil:unixtime(), Default_choice) of
        {ok, Session_new, Answer} ->
            {redirect,Session_new, Uok};
        {error, Error} ->
            treat_numpref(Session, Zone80),
            svc_recharge:recharge_error(Session, Error, U_bad_profil, U_sys_failure, 
                           U_bad_code, U_incompatible, U_promo);
%%%% redirected to bad_code
%%                 {status, [10,5]} ->
%%                     {redirect, Session, U_promo};
%%%% redirected to bad_code
%%                 {status, [99,X]} when X>=0, X<5 ->
%%                     slog:event(warning, ?MODULE,bad_response_from_sdp,[svi_d6,99,X,Msisdn]),
%%                     {redirect, Session,U_sys_failure}; 
        {nok, Reason} ->
            slog:event(warning, ?MODULE,bad_response_from_sachem,Reason),
            {redirect, Session,U_sys_failure};
        Else ->
            slog:event(failure, ?MODULE,bad_response_from_sdp,[recharge_req,Else,Msisdn]),
            {redirect, Session,U_sys_failure}
    end.

treat_numpref(Session, Zone80) ->
    State = svc_util_of:get_user_state(Session),
    List = State#sdp_user_state.numpref_list,
    case List of
        undefined ->
            svc_recharge_tele2:do_opt_cpt_request(Session,opt_numpref_tele2,terminate);
        _ ->
            case length(List) of
                ?Max_nums_preferes ->
                    NumPref =  State#sdp_user_state.numero_prefere,
                    IsFirstPos = (NumPref==lists:nth(1,List)),
                    case IsFirstPos of
                        true ->
                            [[Msisdn|_]|_] = Zone80,
                            [NumPref|Tail] = List,
                            NList = [Msisdn]++Tail,
                            NState = State#sdp_user_state{numpref_list = NList},
                            NSession = svc_util_of:update_user_state(Session, NState),
                            svc_recharge_tele2:do_opt_cpt_request(NSession,opt_numpref_tele2,modify);
                        _ ->
                            svc_recharge_tele2:do_opt_cpt_request(Session,opt_numpref_tele2,terminate)
                    end;
                _ ->
                    svc_recharge_tele2:do_opt_cpt_request(Session,opt_numpref_tele2,terminate)
            end
    end.

