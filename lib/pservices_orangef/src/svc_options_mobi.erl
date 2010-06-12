-module(svc_options_mobi).

%% XML API

-export([is_correct_number/5,
	 redirect_if_numpref_diff/3,
	 redirect_if_kdo/3,
	 redirect_if_modif_allowed/3,
	 redirect_refill_amount/3,
	 redirect_state_opt_cpte/3,
	 redirect_by_validity/3,
	 redirect_state_and_refill/3,
	 redirect_if_option_activated/3]).
-export([do_subscription_request/7,
	 do_register_request_refo/5,
	 do_unsubscription_request/4,
	 redirect_state_opt_cpte/4,
	 print_opt_info_refo/3,
	 print_date_rnv_bonus/2]).

-export([proposer_lien/4,
	 proposer_lien_if_date_correct/3,
	 proposer_lien_si_active/4,
	 proposer_lien_interm/5,
	 enough_credit/2,
	 first_page_kdo/4,
	 first_page/6,
	 first_page/8,
	 first_page_with_init/5,
	 do_subscription/3,
	 do_unsubscription/2,
	 do_unsubscription/3,
	 do_register/3,
	 do_register_request/3,
	 do_register_request/4]).

-export([print_link_options/2,
	 must_we_restitute/2,
	 print_link_option_inactive/4,
	 print_link_option_active/4,
	 get_info_for_option/2,
	 print_opt_info/3]).
-export([restitution/4]).

-export([redirect_if_option_is_activated/3]).


%% API	 
-export([is_option_incomp/2,
	 get_current_option/1,
	 set_current_option/2,
	 print_incomp_opts/2]).


-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pdist_orangef/include/spider.hrl").

-define(dbg(FMT,ARG),
	true%%io:format(?MODULE_STRING" traces: "++FMT,ARG)
	).

-define(DCL_MOBI_FOOT,[39,40,41,42,43,44]).

-define(OPT_XMEDIA, [opt_internet,
		     opt_internet_max_pp,
		     opt_tv_max,
		     opt_tv,
		     opt_musique,
		     opt_surf_mensu,
		     opt_tv_mensu,
		     opt_total_tv_mensu,
		     opt_zap_quoti,
		     opt_musique_mensu,
		     opt_sport_mensu]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDIRECTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_correct_number(session(),Opt::string(),URLok::string(),
%%                         URLNok::string(),Number::string()) ->
%%                         erlpage_result().
%%%% Check that entered number is correct.

is_correct_number(abs,_,URLok,URLNok,Number) ->
    [{"Bad code format",{redirect,abs,URLNok}},
     {"Correct code",{redirect,abs,URLok}}];

is_correct_number(Sess,Opt,URLok,URLNok,Number)
  when Opt=="opt_numprefp" ->
    State = svc_util_of:get_user_state(Sess),
    NumPref = State#sdp_user_state.numero_prefere,
    case (is_list(Number) andalso (length(Number)==10) andalso
	  pbutil:all_digits(Number)) of
	true ->
	    case Number of
		[$0,H|_] when H==$1;H==$2;H==$3;H==$4;H==$5;H==$6;H==$7 ->
		    NumPref2=NumPref#numero_prefere{numero=Number},
		    State_2 = State#sdp_user_state{numero_prefere=NumPref2},
		    {redirect,svc_util_of:update_user_state(Sess, State_2),
		     URLok};
		_ ->
		    {redirect,Sess,URLNok}
	    end;
	false ->
	    {redirect,Sess,URLNok}
    end;

is_correct_number(Sess,Opt,URLok,URLNok,Number)
  when Opt=="opt_illimite_kdo";
       Opt=="opt_illimite_kdo_v2";
       Opt=="opt_ikdo_vx_sms"->
    State = svc_util_of:get_user_state(Sess),
    case (is_list(Number) andalso (length(Number)==10) andalso
	  pbutil:all_digits(Number)) of
	true ->
	    case Number of
		[$0,H|_] when H==$6;H==$7 ->
		    State_2=State#sdp_user_state{c_op_opt_date_souscr=Number,
						 numero_kdo_illimite=Number},
		    {redirect,svc_util_of:update_user_state(Sess, State_2),
		     URLok};
		_ ->
		    {redirect,Sess,URLNok}
	    end;
	false ->
	    {redirect,Sess,URLNok}
    end;
is_correct_number(Sess,Opt,URLok,URLNok,Number)
  when Opt=="opt_sms_illimite"->
    State = svc_util_of:get_user_state(Sess),
    case (is_list(Number) andalso (length(Number)==10) andalso
	  pbutil:all_digits(Number)) of
	true ->
	    case Number of
		[$0,H|_] when H==$6;H==$7 ->
		    State_2=State#sdp_user_state{numero_sms_illimite=Number},
		    {redirect,svc_util_of:update_user_state(Sess, State_2),
		     URLok};
		_ ->
		    {redirect,Sess,URLNok}
	    end;
	false ->
	    {redirect,Sess,URLNok}
    end;
is_correct_number(Sess,Opt,URLok,URLNok,Number)
  when Opt=="opt_st_valentin"->
    State = svc_util_of:get_user_state(Sess),
    case (is_list(Number) andalso (length(Number)==10) andalso
	  pbutil:all_digits(Number)) of
	true ->
	    case Number of
		[$0,H|_] when H==$6;H==$7 ->
		    State_2=State#sdp_user_state{numero_st_valentin=Number},
		    {redirect,svc_util_of:update_user_state(Sess, State_2),
		     URLok};
		_ ->
		    {redirect,Sess,URLNok}
	    end;
	false ->
	    {redirect,Sess,URLNok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_if_numpref_diff(session(),URL_DIFF::string(),
%%                                URL_NO_DIFF::string()) ->
%%                                erlpage_result().
%%%% XML API interface when option numpref. Redirect to corresponding page.

redirect_if_numpref_diff(abs,URL_DIFF,URL_NO_DIFF) ->
    [{redirect,abs,URL_DIFF},{redirect,abs,URL_NO_DIFF}];
redirect_if_numpref_diff(Sess,URL_DIFF,URL_NO_DIFF) ->
    State = svc_util_of:get_user_state(Sess),
    #sdp_user_state{numero_prefere=#numero_prefere{numero=NumP},malin=Malin} =
	State,
    case {Malin,NumP == [$0|Malin]} of
	{"-",_}->
	    {redirect,Sess,URL_NO_DIFF};
	{_,false} ->
	    {redirect,Sess,URL_DIFF};
	{_,true} ->
	    {redirect,Sess,URL_NO_DIFF}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_if_kdo(session(),Opt::string(),URLs::string())->
%%                       erlpage_result().
%%%% Requests the value of field C_OP/OPT_DATE_SOUSCR from Sachem.
%%%% Redirects to corresponding page.

redirect_if_kdo(abs,_,URLs)->
    [Uok,Unok] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},{redirect,abs,Unok}];
redirect_if_kdo(Session,Opt,URLs)->
    Option = list_to_atom(Opt),
    [Uok,Unok] = string:tokens(URLs, ","),
    NewSess = get_info_for_option(Session, Option),
    State = svc_util_of:get_user_state(NewSess),
    case State#sdp_user_state.numero_kdo_illimite of
	not_defined -> 
	    {redirect,NewSess,Unok};
	[]->
	    {redirect,NewSess,Unok};
	_ ->
	    {redirect,NewSess,Uok}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_state_opt_cpte(session(),Opt::string(),URLs::string())->
%%                               erlpage_result().
%%%% Redirects according to the state of the option and the account state.

redirect_state_opt_cpte(abs,_,URLs)->
    [Uok, Unok] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},{redirect,abs,Unok}];
redirect_state_opt_cpte(Session,Opt,URLs)->
    Option = list_to_atom(Opt),
    [Uok, Unok] = string:tokens(URLs, ","),
    case cpte_and_option_state(Session,Option) of
	{cpte_ac,opt_ac} -> {redirect,Session,Uok};
	_                -> {redirect,Session,Unok}
    end.

redirect_by_validity(abs,_,URLs)->
    [Uok, Unok,Uerror] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},{redirect,abs,Unok},{redirect,abs,Uerror}];

redirect_by_validity(Session,Opt,URLs)
when Opt=="opt_illimite_kdo_v2"->
    [Uok, Unok,Uerror] = string:tokens(URLs, ","),
    case svc_util_of:do_consultation(Session, list_to_atom(Opt)) of
        {ok, [Zone70, _, _]} ->
            case Zone70 of
                L_VIDE when L_VIDE==[];
			    L_VIDE==[[]] ->
                    slog:event(trace,?MODULE,zone70,empty),
                    {redirect, Session, Uerror};
                ListOptions ->
                    #session{prof=#profile{subscription=Sub}}=Session,
                    case svc_util_of:search_opt_from_z70(ListOptions,Opt,list_to_atom(Sub)) of
                        [DEB,FIN]->
                            svc_util_of:redirect_option_launched(Session, DEB, FIN, 
                                                                 Uok, Unok);
                        _->
                            slog:event(trace,?MODULE,search_opt_from_z70,unknown_option),
                            {redirect, Session, Uerror}
                    end
            end;
        {ok, {Session_resp, Resp_params}} ->
            State = svc_util_of:get_user_state(Session),
            List_options = svc_util_of:get_param_value("OP_PARAMS", Resp_params),
	    Top_num=svc_options:top_num(list_to_atom(Opt),mobi),
            case svc_sachem:get_option_info(integer_to_list(Top_num), List_options) of                      
                [_,_,DEB,FIN|_] ->
                    svc_util_of:redirect_option_launched(Session, list_to_integer(DEB), list_to_integer(FIN), Uok, Unok);
                _->
                    slog:event(failure,?MODULE,unknown_option, 
                               {list_to_atom(Opt), List_options}),
                    {redirect, Session, Uerror}
            end;
        {nok, Reason} ->
	    slog:event(failure,?MODULE,redirect_by_validity_do_consult, Reason),
            {redirect, Session, Uerror};
        Error ->
            slog:event(trace,?MODULE,do_consultation,Error),
            {redirect, Session, Uerror}
    end.
%%added only for à plugin
redirect_state_opt_cpte(Session,Opt,Uok,Unok)->
    Option = list_to_atom(Opt),
    case cpte_and_option_state(Session,Option) of
	{cpte_ac,opt_ac} -> {redirect,Session,Uok};
	_                -> {redirect,Session,Unok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_if_modif_allowed(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Requests the value of field C_OP/OPT_DATE_DEB_VALID from Sachem.
%%%% Redirects to corresponding page.

redirect_if_modif_allowed(abs,_,URLs)->
    [Uok,Unok] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},{redirect,abs,Unok}];
redirect_if_modif_allowed(Session,Opt,URLs)->
    Option = list_to_atom(Opt),
    [Uok,Unok] = string:tokens(URLs, ","),
    NewSess = get_info_for_option(Session, Option),
    State = svc_util_of:get_user_state(NewSess),
    Now = pbutil:unixtime(),
    {{_, Mo_Now, _}, _} = 
	calendar:now_to_datetime({Now div 1000000,
				  Now rem 1000000,0}),
    DateDebValid = State#sdp_user_state.c_op_opt_date_deb_valid,
    case is_integer(DateDebValid) of
	true ->
	    {{_, Mo_C_OP, _}, _} = 
		calendar:now_to_datetime({DateDebValid div 1000000,
					  DateDebValid rem 1000000,0});
	false ->
	    slog:event(warning,?MODULE,redirect_if_modif_allowed,["State#sdp_user_state.c_op_opt_date_deb_valid",DateDebValid]),
	    Mo_C_OP = 0
    end,
    case Mo_C_OP of
	Mo_Now -> 
	    {redirect,NewSess,Unok};
	_ ->
	    {redirect,NewSess,Uok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_refill_amount(session(),Opt::string(),URLs::string())->
%%                              erlpage_result().
%%%% Checks whether the refill amount of the current month is less, equal or
%%%% more than the limit specified by the configuration parameter
%%%% pservices_orangef / recharge_illimite_kdo_mini, and
%%%% redirects to corresponding page.

redirect_refill_amount(abs,_,URLs)->
    [UlessLimit,UmoreLimit] = string:tokens(URLs, ","),
    [{redirect,abs,UlessLimit},{redirect,abs,UmoreLimit}];
redirect_refill_amount(Session,Opt,URLs)->
    [UlessLimit,UmoreLimit] = string:tokens(URLs, ","),
    Option = list_to_atom(Opt),
    {Result, NewSession} = check_refill_amount(Session,Option),
    case Result of
	true -> 
	    {redirect, NewSession, UlessLimit};
	_ ->
	    {redirect, NewSession, UmoreLimit}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_state_and_refill(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Checks whether the refill amount of the current month is less, equal or
%%%% more than the limit specified by the configuration parameter
%%%% pservices_orangef / recharge_illimite_kdo_mini, and
%%%% redirects to corresponding page.

redirect_state_and_refill(abs,_,URLs)->
    [UOpt_less,UOpt_more,UnoOpt_less,UnoOpt_more] = string:tokens(URLs, ","),
    [{redirect,abs,UOpt_less},{redirect,abs,UOpt_more},
     {redirect,abs,UnoOpt_less},{redirect,abs,UnoOpt_more}];
redirect_state_and_refill(Session,Opt,URLs)->
    [UOpt_less,UOpt_more,UnoOpt_less,UnoOpt_more] = string:tokens(URLs, ","),
    Option = list_to_atom(Opt),
    {Result, NewSession} = check_refill_amount(Session,Option),
    case {cpte_and_option_state(Session,Option), Result} of
	{{cpte_ac,opt_ac}, true} ->
	    {redirect,NewSession,UOpt_less};
	{{cpte_ac,opt_ac}, false} ->
	    {redirect,NewSession,UOpt_more};
	{_, true} ->
	    {redirect,NewSession,UnoOpt_less};
	_ ->
	    {redirect,NewSession,UnoOpt_more}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_if_option_activated(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Checks whether any multimedia option is activated, and
%%%% redirects to corresponding page.

redirect_if_option_activated(abs,_,URLs)->
    [UOpt_activated,UOpt_not_activated] = string:tokens(URLs, ","),
    [{redirect,abs,UOpt_activated},{redirect,abs,UOpt_not_activated}];
redirect_if_option_activated(Session,Opt,URLs)
  when Opt == "option_multimedia" ->
    [UOpt_activated,UOpt_not_activated] = string:tokens(URLs, ","),
    Options = ?OPT_XMEDIA,
    case svc_options:is_any_option_activated(Session,Options) of
	true ->
	    {redirect,Session,UOpt_activated};
	_ ->
	    {redirect,Session,UOpt_not_activated} 
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS RELATED TO SUBSCRIPTION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type proposer_lien(session(),Option::string(),
%%                     PDC_URLs::string(),BR::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.
%%%% Value of BR: "br" or "nobr".
%%%% No options proposed for DCL_NUM atp and deg.

proposer_lien(abs,_,PCD_URLs,BR) ->
    [{PCD,URL}|_] = svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
proposer_lien(Session,Option,PCD_URLs,BR) ->
    State = svc_util_of:get_user_state(Session),
    DCL_NUM = State#sdp_user_state.declinaison,
    proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM).

%% +type proposer_lien(session(),Option::string(),
%%                     PDC_URLs::string(),BR::string(),DCL_NUM::integer()) ->
%%                     hlink().
%%%% Link to subscription with DCL_NUM.

proposer_lien(Session,Option,PCD_URLs,BR, _) 
  when Option=="opt_jinf" ->
    Opt=list_to_atom(Option),
    case (svc_util_of:is_commercially_launched(Session,Opt) and 
	  svc_util_of:is_good_plage_horaire(Opt) and 
	  (calendar:day_of_the_week(date())/=6) and 
	  (calendar:day_of_the_week(date())/=7)) of
	%% Option jinf closed on saturday (day=6) and sunday (day=7)
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _)
 when Option=="opt_appelprixunique" ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    PtfNum=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt)
 	and (PtfNum==2) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _)
  when Option=="opt_afterschool" ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    case (svc_util_of:is_plug(State) or svc_util_of:is_zap(State))
	and svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false -> 
	    []
    end;


proposer_lien(Session,Option,PCD_URLs,BR, _)
  when Option=="opt_msn_mobi"->
    Opt=list_to_atom(Option),
    [{PCD_no_mensu,URL_no_mensu},{PCD_mensu,URL_mensu}]=
	svc_util_of:dec_pcd_urls(PCD_URLs),
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_msn_mensu_mobi) of
	true ->
	    [#hlink{href=URL_mensu,contents=[{pcdata,PCD_mensu}]}]
		++svc_util_of:add_br(BR);
	_ ->
	    [#hlink{href=URL_no_mensu,
		    contents=[{pcdata,PCD_no_mensu}]}]
		++svc_util_of:add_br(BR)
    end;

%%%% is not shown if option opt_sms_mensu is activated
proposer_lien(Session,Option,PCD_URLs,BR, _)
  when Option=="opt_sms_quoti" ->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt)
	and svc_util_of:is_good_plage_horaire(Opt)
	and not svc_options:is_option_activated(Session,opt_sms_mensu) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _)
  when Option=="opt_mms_mensu" ->
    Opt=list_to_atom(Option),
    [{PCD_AC,URL_AC}, {PCD_EP,URL_EP}] = svc_util_of:dec_pcd_urls(PCD_URLs),
    State = svc_util_of:get_user_state(Session),
    case {(svc_options:is_option_activated(Session,Opt) and 
	   svc_util_of:is_commercially_launched(Session,Opt)),
	  svc_compte:etat_cpte(State, svc_options:opt_to_godet(Opt,mobi))} of
	{true, ?CETAT_AC} ->
	    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]++
		svc_util_of:add_br(BR);
	{true, ?CETAT_EP} ->
	    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]++
		svc_util_of:add_br(BR);
	_ -> 
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _)
  when Option=="opt_weinf";
       Option =="opt_sinf";
       Option =="opt_ssms" ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DateActiv = State#sdp_user_state.d_activ,
    case svc_util_of:is_good_plage_horaire(Opt)
	and svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false -> 
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _)
  when Option=="opt_illimite_kdo" ->
    Opt=list_to_atom(Option),
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    [{PCD_IKDO,URL_IKDO}, {PCD_IKDO_VX_SMS,URL_IKD_VX_SMSO}]=
	svc_util_of:dec_pcd_urls(PCD_URLs),
    Comm_Date = pbutil:get_env(pservices_orangef,commercial_date),
    {value,{_,[{Beg,End}]}} = lists:keysearch(opt_ikdo_vx_sms, 1, Comm_Date),
    {PCD, URL} = 
	case is_subscribed(Session_new,opt_ikdo_vx_sms) of
	    true -> 
		{PCD_IKDO_VX_SMS,URL_IKD_VX_SMSO};
	    _ ->		
		{PCD_IKDO,URL_IKDO}
	end,
    case svc_util_of:is_commercially_launched(Session_new,Opt) of
	true ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _) 
  when Option=="opt_vacances"->
    Opt=list_to_atom(Option),
    [{PCD_no_mensu,URL_no_mensu},{PCD_mensu,URL_mensu}]=
	svc_util_of:dec_pcd_urls(PCD_URLs),
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true ->
	    {Session_new,State_} = svc_options:check_topnumlist(Session),
	    case svc_options:is_option_activated(Session_new,opt_sms_mensu) or
		svc_options:is_option_activated(Session_new,opt_mms_mensu) of
		true ->
 		    [#hlink{href=URL_mensu,contents=[{pcdata,PCD_mensu}]}]
 			++svc_util_of:add_br(BR);
		_ ->
		    [#hlink{href=URL_no_mensu,
                            contents=[{pcdata,PCD_no_mensu}]}]
                        ++svc_util_of:add_br(BR)
	    end;
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR, _) 
  when Option=="refill_game"->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    Opt=list_to_atom(Option),
    [PCD,URL,URL_game]=string:tokens(PCD_URLs, ","),
    
    case lists:member(DCL,?DCL_MOBI_FOOT) of
	
	true->[#hlink{href=URL,
		      contents=[{pcdata,PCD}]}]
		  ++svc_util_of:add_br(BR);
	
	_->  
	     case svc_util_of:is_commercially_launched(Session,Opt) of
		 true ->
		     [#hlink{href=URL_game,contents=[{pcdata,PCD}]}]
			 ++svc_util_of:add_br(BR);
		 _ ->
		     [#hlink{href=URL,
			     contents=[{pcdata,PCD}]}]
			 ++svc_util_of:add_br(BR)
	     end
    end;

proposer_lien(Session,Option,PCD_URL,BR, _) 
  when Option=="is_game_activ"->
    Opt=list_to_atom("refill_game"),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,

    case lists:member(DCL,?DCL_MOBI_FOOT) of

	true->[];

	_ -> [PCD,URL]=	string:tokens(PCD_URL, ","),
	     case svc_util_of:is_commercially_launched(Session,Opt) of
		 true ->
		     svc_util_of:add_br(BR) ++
			 [#hlink{href=URL,contents=[{pcdata,PCD}]}];
		 _ ->
		     []
	     end
    end;

%%%% In the main menu, show either:
%%%% Suivi conso de mes bons plans if bons plans
%%%% Suivi conso de mes promos if promos 
%%%% (note the special behavior for showing the promos link in promo functions)
%%%% Suivi conso detaille if both which goes to a sub menu with 2 both links
%%%% Nothing if no bons plans nor promos
proposer_lien(Session, Param, PCD_URLs, BR, _) 
  when Param=="bons_plans_promo" ->
    [{PCD_detaille,  URL_bons_plans_promo},
     {PCD_promo,     URL_promo},
     {PCD_bons_plans,URL_bons_plans}] = svc_util_of:dec_pcd_urls(PCD_URLs),
    Hlink_promo = svc_selfcare:print_first_link_promo(Session, 
						      PCD_promo, URL_promo),
    Hlink_bons_plans = print_link_options(Session,
					  PCD_bons_plans++"="++URL_bons_plans ),    
    case ((Hlink_promo == []) or (Hlink_bons_plans == [])) of 
	true ->
	    Hlink_promo ++ Hlink_bons_plans;
	_ ->
	    [#hlink{href=URL_bons_plans_promo,contents=[{pcdata,PCD_detaille}]}]
		++svc_util_of:add_br(BR)
    end;

proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM)
when Option =="opt_pass_vacances";Option =="opt_pass_vacances_v2";Option =="opt_pass_voyage_6E";
	 Option =="opt_pass_vacances_z2";Option =="opt_pass_voyage_9E" ->
    Opt=list_to_atom(Option),
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]
		++svc_util_of:add_br(BR);		    
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM)
when Option =="opt_10mn_europe" ->
    Opt=list_to_atom(Option),
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    case (svc_util_of:is_commercially_launched(Session,Opt) and 
	(not svc_options:is_option_activated(Session,Opt))) of
	true ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]
		++svc_util_of:add_br(BR);		    
	false ->
	    []
    end;


proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM)
when Option =="opt_pass_voyage_6E" ->
    Opt=list_to_atom(Option),
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),

    case svc_roaming:get_vlr(Session) of 
	{ok, VLR_Number} ->
	    case svc_util_of:is_commercially_launched(Session,Opt) and 
		svc_util_of:is_good_plage_horaire(Opt) of
		true ->
		    case svc_util_of:is_europe_vlr(VLR_Number) of
			true ->
			    [#hlink{href=URL,contents=[{pcdata,PCD}]}]
			       ++svc_util_of:add_br(BR);
			_ ->
			    []
		    end;
		    
		false ->
		   []
	    end;
	A ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM)
  when Option =="eu_dialling_code"->
    case svc_roaming:get_vlr(Session) of 
	{ok, VLR_Number} ->
	    case svc_util_of:is_europe_vlr(VLR_Number) of
		true ->
		    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
		false ->
		    []
	    end;
	_ ->
	    []
    end;

proposer_lien(Session, Param, PCD_URLs, BR, _) 
  when Param=="tranfert_credit" ->
    [{PCD_astuces_credit,  URL_astuces_credit},
     {PCD_transfert_credit,     URL_transfert_credit}] = svc_util_of:dec_pcd_urls(PCD_URLs),
    State = svc_util_of:get_user_state(Session),
    case svc_compte:is_transfert_credit_enable(State) of
	true ->
	    [#hlink{href=URL_transfert_credit,contents=[{pcdata,PCD_transfert_credit}]}] ++svc_util_of:add_br(BR);
	_->
	    [#hlink{href=URL_astuces_credit,contents=[{pcdata,PCD_astuces_credit}]}] ++svc_util_of:add_br(BR)
    end;

proposer_lien(Session, Option, PCD_URLs, BR, _) 
  when Option=="opt_sms_illimite" ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DateActiv = svc_util_of:unixtime_to_local_time(State#sdp_user_state.d_activ),
    case svc_util_of:check_plage_datetimes(DateActiv,pbutil:get_env(pservices_orangef,sms_illimite)) 
	and svc_util_of:is_commercially_launched(Session,Opt) of 
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false -> 
	    []
    end;
proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM) 
  when (Option=="internet_max_journee") or (Option=="internet_max_weekend") 
       or (Option == "musique_mix") or (Option == "musique_collection")->
    Opt=list_to_atom("opt_" ++ Option),
    slog:event(trace, ?MODULE, option,Opt),
    case svc_util_of:is_commercially_launched(Session,Opt) and
        svc_util_of:is_good_plage_horaire(Opt) of
        true ->
            [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
            [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
        false ->
            []
    end;
proposer_lien(Session,Option,PCD_URLs,BR,DCL_NUM) ->
    Opt=list_to_atom(Option),
    slog:event(trace, ?MODULE, ?LINE, [option,Opt]),
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end.

%% +type proposer_lien_si_active(session(),Option::string(),
%%                     PDC_URLs::string(),BR::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.
%%%% Value of BR: "br" or "nobr".
%%%% No options proposed for DCL_NUM atp and deg.

proposer_lien_si_active(abs,_,PCD_URLs,BR) ->
    [{PCD,URL}|_] = svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);

proposer_lien_si_active(Session,Option,PCD_URLs,BR) ->
    Opt=list_to_atom(Option),
    case svc_options:is_option_activated(Session,Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false -> 
	    []
    end.

%% +type proposer_lien_if_date_correct/3(session(),
%%                                       Option::string(),
%%                                       URL::string()) ->
%%                     URL
%%%% Check whether bonus is registered on specific date and 
%%%% redirect to corresponding page

proposer_lien_if_date_correct(abs,_,URLs) ->
    [{redirect,abs,URLs}];

proposer_lien_if_date_correct(#session{prof=Profile}=Session,Option,URLs) 
  when Option=="opt_bonus_appels";
       Option=="opt_bonus_sms";
       Option=="opt_bonus_internet";
       Option=="opt_bonus_europe";
       Option=="opt_bonus_maghreb";
       Option=="opt_bonus_appels_promo";
       Option=="opt_bonus_sms_promo";
       Option=="opt_bonus_internet_promo";
       Option=="opt_bonus_europe_promo";
       Option=="opt_bonus_maghreb_promo" ->
    [Url, Url_with_bonus] = string:tokens(URLs,","),
    Opt = list_to_atom(Option),
    MSISDN = Profile#profile.msisdn,
    NSession = get_opt_info(Session,integer_to_list(svc_options:top_num(Opt,mobi))),

    State = svc_util_of:get_user_state(NSession),
    DateSousc = State#sdp_user_state.c_op_opt_date_souscr,
    case (is_list(DateSousc) andalso DateSousc/=[]) of 
	true ->
	    Dates_bonus = pbutil:get_env(pservices_orangef,recharge_janus_date),
	    {{_,_,JJ},_} =  svc_util_of:unixtime_to_local_time(list_to_integer(DateSousc)),
	    case lists:member(JJ,Dates_bonus) of
		false ->
		    {redirect,NSession,Url_with_bonus};
		_ ->
		    {redirect,NSession,Url}
	    end;
	_ ->
	    []
    end.


%% +type proposer_lien_interm(session(),Conditions::string(),
%%                            Options::string(),PDC_URL::string(),
%%                            BR::string()) ->
%%                            hlink().

proposer_lien_interm(abs,_,_,PCD_URLs,BR) ->
    [{PCD,URL}|_] = svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);

proposer_lien_interm(Session, Conditions, Options, PCD_URL, BR) 
  when Conditions == "opts_comm_launched"->
    List_options = string:tokens(Options, ","),
    List_options_atom = lists:map(fun(E) -> list_to_atom(E) end, List_options),
    Comm_launched = fun(Arg) ->
			    svc_util_of:is_commercially_launched(Session, Arg)
				and svc_util_of:is_good_plage_horaire(Arg)
		    end,
    case lists:member(true, lists:map(Comm_launched, List_options_atom)) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URL),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false ->
	    []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type enough_credit(sdp_user_state(),
%%                     {currency:currency(),Opt::atom()} | currency:currency(),
%%                     ) ->
%%                      bool().
%%%% Indicates whether there is enough credit on the account.

enough_credit(State, {Currency, Opt})
  when Opt==opt_tt_shuss;
       Opt==opt_pack_duo_journee;
       Opt==opt_pass_vacances;
       Opt==opt_pass_vacances_v2;
       Opt==opt_pass_vacances_z2;
       Opt==opt_pass_voyage_6E;
       Opt==opt_pass_voyage_9E;
       Opt==opt_maghreb;
       Opt==opt_europe;
       Opt==opt_pass_dom ->
    enough_credit(State, {Currency, Opt},[cpte_princ,cpte_bons_plans,cpte_credit_offert,cpte_dixit_bons_plans]);
enough_credit(State, {Currency, Opt}) ->
    true.

enough_credit(#sdp_user_state{}=S,{Curr,Opt},[]) ->
    false;
enough_credit(#sdp_user_state{}=S,{Curr,Opt},[Cpte|Tail]) ->
    case currency:is_inf(Curr,svc_compte:solde_cpte(S,Cpte)) of
	true ->
	     true;
	_ ->
	    enough_credit(S,{Curr,Opt},Tail)
    end.
					      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_page_with_init(session(),Opt::string(),
%%                            UInsuf::string(),UGene::string(),Uko::string())->
%%                            erlpage_result(). 
%%%% First page for option numpref.

first_page_with_init(abs,"opt_numprefp",UInsuf,UGene,Uko)->
    [{redirect,abs,UInsuf},{redirect,abs,UGene},{redirect,abs,Uko}];
first_page_with_init(Session,"opt_numprefp",UInsuf,UGene,Uko) ->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case init_options(Session_new,opt_numprefp) of
	{ok,S2}->
	    State_new = svc_util_of:get_user_state(S2),
	    PrixSubscr = svc_util_of:subscription_price(S2, opt_numprefp),
	    case svc_options:enough_credit(State_new,
					   currency:sum(euro,
							PrixSubscr/1000)) of
		false ->
		    {redirect,S2,UInsuf};
		true  ->
		    {redirect,S2,UGene}
	    end;
	{error,_} ->
	    {redirect,Session_new,Uko}
    end.

first_page_kdo(abs,Opt,UAct,UIncomp) ->
    [{redirect,abs,UAct},
     {redirect,abs,UIncomp}
    ];

first_page_kdo(Session,Option,UAct,UIncomp) ->
    Opt = list_to_atom(Option),
    {Session_new,State_New} = svc_options:check_topnumlist(Session),
    PrixSubscr = svc_util_of:subscription_price(Session_new, Opt, without_promo),
    EnoughCredit = enough_credit(State_New,{currency:sum(euro,PrixSubscr/1000),Opt}),
    case {is_subscribed(Session_new,Opt),
	  is_resubscr_allowed(Session_new,Opt)} of
	{true,false} ->
	    case {EnoughCredit,Opt} of 
		%% No options incompatible with sms_quoti.
		%% Redirect to UIncomp for this option when option activated
		%% but no credit available (option suspended).
		{false, opt_sms_quoti} -> 
		    {redirect,svc_util_of:update_user_state(Session_new, State_New), UIncomp};
		{_,_} ->
		    {redirect,svc_util_of:update_user_state(Session_new, State_New), UAct}
	    end;
	_ ->
	    case is_option_incomp(Session_new,Opt) of
		true -> 
		    {redirect,svc_util_of:update_user_state(Session_new, State_New), UIncomp}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_page(session(),Opt::string(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string(),UPromo::string(),UPromoInsuf::string())->
%%                  erlpage_result(). 
%%%% First page for subscription of option.
%%%% Redirect to UAct when option already active,
%%%% redirect to UIncomp when option incompatible with existing options,
%%%% redirect to UInsuf when not enough credit,
%%%% redirect to UGene when subscription proposed.
%%%% redirect to UPromo when subscription proposed.
	
first_page(abs,Opt,UAct,UIncomp,UInsuf,UGene,UPromo,UPromoInsuf) ->
    [{redirect,abs,UAct},
     {redirect,abs,UIncomp},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene},
     {redirect,abs,UPromo},
     {redirect,abs,UPromoInsuf}
    ];

first_page(Session,Option,UAct,UIncomp,UInsuf,UGene,UPromo,UPromoInsuf) ->
    Opt = list_to_atom(Option),
    {Session_new,State_New} = svc_options:check_topnumlist(Session),
    PrixSubscr = svc_util_of:subscription_price(Session_new, Opt, without_promo),
    EnoughCredit = enough_credit(State_New,{currency:sum(euro,PrixSubscr/1000),Opt}),
    case {is_subscribed(Session_new,Opt),
	  is_resubscr_allowed(Session_new,Opt)} of
	{true,false} ->
	    case {EnoughCredit,Opt} of 
		%% No options incompatible with sms_quoti.
		%% Redirect to UIncomp for this option when option activated
		%% but no credit available (option suspended).
		{false, opt_sms_quoti} -> 
		    {redirect, Session_new, UIncomp};
		{_,_} ->
		    {redirect, Session_new, UAct}
	    end;
	_ ->
	    case is_option_incomp(Session_new,Opt) of
		true -> 
		    {redirect, Session_new, UIncomp};
		false ->
		    Curr = currency:sum(euro,PrixSubscr/1000),
		    case {(svc_compte:etat_cpte(State_New,cpte_bons_plans)==?CETAT_AC),
			  svc_options:credit_bons_plans_ac(State_New,{Curr,Opt})} of
			{true,true} ->
			    redirect_promo(Session_new,Opt,UGene,UPromo);
			{_,_} ->
 			    case EnoughCredit of
 				false ->
 				    {redirect, Session_new, UInsuf};
 				    %redirect_promo(svc_util_of:update_user_state(Session_new,State_New),Opt,UInsuf,UPromoInsuf);
 				true  ->
			    {redirect, Session_new, UGene}
 				    %redirect_promo(svc_util_of:update_user_state(Session_new,State_New),Opt,UGene,UPromo)
			    end
		    
		    end

	    end

    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_page(session(),Opt::string(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string())->
%%                  erlpage_result().
%%%% For compatibility with old versions

first_page(abs,Opt,UAct,UIncomp,UInsuf,UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UIncomp},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene}
    ];

first_page(Session,Option,UAct,UIncomp,UInsuf,UGene) ->
    first_page(Session,Option,UAct,UIncomp,UInsuf,UGene,UGene,UInsuf).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription(session(),Opt::string(),URLs::string())->
%%                       erlpage_result().
%%%% XML API Interface to subscription.

do_subscription(abs,"opt_numprefp",URLs) ->
    [Uok,Uinsuff,Unok]=string:tokens(URLs, ","),
    [{redirect,abs,Uinsuff},
     {redirect,abs,Unok},
     {redirect,abs,Uok,["DATE_FIN","NUM_PREF"]}];

do_subscription(abs,_,URLs) ->
    URL2 = string:tokens(URLs, ","),
    lists:map(fun(U) -> {redirect,abs,U} end,URL2);

do_subscription(#session{}=S,Option,URLs) ->
    State = svc_util_of:get_user_state(S),
    Uopt_bloquee =
	case State#sdp_user_state.declinaison of
	    ?RC_LENS_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?ASSE_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?OL_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?OM_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?PSG_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?BORDEAUX_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
            ?CLUB_FOOT->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);

	    ?m6_prepaid ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_m6);
	    ?DCLNUM_ADFUNDED ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_m6);
	    ?click_mobi ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_click);
	    _ ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee)
	end,
    do_subscription_request(S,list_to_atom(Option),URLs,Uopt_bloquee).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS RELATED TO TERMINATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_unsubscription(session(),Opt::string(),URLs::string())->
%%                         erlpage_result().
%%%% XML API Interface to subscription termination.

do_unsubscription(abs,Option,URLs) ->
    [Uok,Unok] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},{redirect, abs, Unok}];

do_unsubscription(#session{}=S,Option,URLs) ->
    do_unsubscription_request(S,list_to_atom(Option),URLs).

%% +type do_unsubscription(session(),Opt::string())->
%%                         erlpage_result().
%%%% XML API Interface to subscription termination for option opt_jinf.

do_unsubscription(#session{}=S,Option) 
  when Option=="opt_jinf" ->
    do_unsubscription_request(S,list_to_atom(Option)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type do_register(session(),Opt::string(),URLs::string())->
%%                   erlpage_result().
%%%% XML API Interface to register no KDO when option illimite KDO.

do_register(abs, _, URLs) ->
    [Uok,UnotOF,Unok] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},
     {redirect,abs,UnotOF},
     {redirect,abs,Unok}];

do_register(Session,Option,URLs) 
  when Option=="opt_illimite_kdo";
       Option=="opt_ikdo_vx_sms"->
    do_register_request(Session, list_to_atom(Option), URLs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS RELATED TO QUERIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_link_options(session(),PCD_URL::string()) ->
%%                          erlpage_result().
%%%% Check whether link to restitution should be proposed in main menu.

print_link_options(abs,PCD_URL) ->
    [{PCD,URL}] = svc_util_of:dec_pcd_urls(PCD_URL),
    [#hlink{href=URL,contents=[{pcdata,PCD},br]}];
print_link_options(Session,PCD_URL) ->
    ListOptRestit = pbutil:get_env(pservices_orangef,restit_options_mobi),
    case must_we_restitute(Session, ListOptRestit) of
	true ->
	    [{PCD,URL}] = svc_util_of:dec_pcd_urls(PCD_URL),
 	    [#hlink{href=URL,contents=[{pcdata,PCD},br]}];
	false ->
	    []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_link_option_active(session(),Opt::string(),
%%                                PCD_URL::string(),BR::string()) ->
%%                                erlpage_result().
%%%% Used to propose link to "refill" page when call me back option is active.

print_link_option_active(abs,OPT,PCD_URL,BR) ->
    [{PCD,URL}] = svc_util_of:dec_pcd_urls(PCD_URL),
    [#hlink{href=URL,contents=[{pcdata,PCD},br]}];
print_link_option_active(Session,OPT,PCD_URL,BR) ->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,list_to_atom(OPT)) of
	true ->
	    [{PCD,URL}] = svc_util_of:dec_pcd_urls(PCD_URL),
 	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	false -> 
	    []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_link_option_inactive(session(),Opt::string(),
%%                                  PCD_URL::string(),BR::string()) ->
%%                                  erlpage_result().
%%%% Used to propose link to "refill" page when call me back option is
%%%% not active.

print_link_option_inactive(abs,OPT,PCD_URL,BR) ->
    [{PCD,URL}] = svc_util_of:dec_pcd_urls(PCD_URL),
    [#hlink{href=URL,contents=[{pcdata,PCD},br]}];
print_link_option_inactive(Session,OPT,PCD_URL,BR) ->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,list_to_atom(OPT)) of
	false ->
	    [{PCD,URL}] = svc_util_of:dec_pcd_urls(PCD_URL),
 	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	true -> 
	    []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_opt_info(session(),Opt::string,Info::string()) ->
%%                      [{pcdata,string()}].
%%%% Print the information defined by Info.

print_opt_info(abs,_,_)->
    [{pcdata,"XX"}];
print_opt_info(Session,Opt,"min_refill") ->
    MinRefill =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_illimite_kdo_mini)),
    Value = currency:round_value(MinRefill),
    Euros = lists:flatten(io_lib:format("~w", [trunc(Value)])),
    [{pcdata,Euros}];

print_opt_info(Session,Opt,"month") ->
    Now=pbutil:unixtime(),
    {{_, Mo, _}, _} = 
	calendar:now_to_datetime({Now div 1000000,
				  Now rem 1000000,0}),
    Date = pbutil:sprintf("%02d/%02d", [1,Mo]),
    [{pcdata, lists:flatten(Date)}]; 

print_opt_info(Session,Opt,"refill_amount") ->
    Option = list_to_atom(Opt),
    State = svc_util_of:get_user_state(Session),
    Amount = State#sdp_user_state.refill_amount,
    Aeuros = Amount/1000,
    IoLibF = case (trunc(Aeuros)*10)==trunc(Aeuros*10) of
		 true  -> io_lib:format("~w", [trunc(Aeuros)]);
		 false -> io_lib:format("~.1f", [Aeuros])
	     end,
    [{pcdata,lists:flatten(IoLibF)}].

print_opt_info_refo(Session,Opt,"min_refill") ->
    MinRefill =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_illimite_kdo_mini)),
    Value = currency:round_value(MinRefill),
    Euros = lists:flatten(io_lib:format("~w", [trunc(Value)])),
    [{pcdata,Euros}];

print_opt_info_refo(Session,Opt,"month") ->
    Now=pbutil:unixtime(),
    {{_, Mo, _}, _} = 
	calendar:now_to_datetime({Now div 1000000,
				  Now rem 1000000,0}),
    Date = pbutil:sprintf("%02d/%02d", [1,Mo]),
    [{pcdata, lists:flatten(Date)}]; 

print_opt_info_refo(Session,Opt,"refill_amount") ->
    Option = list_to_atom(Opt),
    State = svc_util_of:get_user_state(Session),
    Amount = State#sdp_user_state.refill_amount,
    Aeuros = Amount/1000,
    IoLibF = case (trunc(Aeuros)*10)==trunc(Aeuros*10) of
		 true  -> io_lib:format("~w", [trunc(Aeuros)]);
		 false -> io_lib:format("~.1f", [Aeuros])
	     end,
    [{pcdata,lists:flatten(IoLibF)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type restitution(session(),Opt::string(),
%%                   PCD_URL::string(),BR::string()) ->
%%                   [hlink()].
%%%% XML API Interface to restitution ie. information on active options
%%%% and credit.

restitution(abs,_,PCD_URLs,BR) ->
    [{PCD,URL}|_] = svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]++svc_util_of:add_br(BR)}];

restitution(Sess,Option,PCD_URLs,BR) ->
    do_restitution(Sess,list_to_atom(Option),restit,PCD_URLs,BR).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API INTERFACE - EXPORT FUNCTIONS USED BY OTHER MODULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_current_option(session())->
%%                          atom().
%%%% Read the current option stored in {?MODULE, option}.

get_current_option(Session) ->
    variable:get_value(Session, {?MODULE, option}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_current_option(session(), atom())->
%%                          atom().
%%%% Read the current option stored in {?MODULE, option}.

set_current_option(Session,Opt) ->
    Session2 = variable:update_value(Session, {?MODULE, option}, Opt),
    Session2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_info_for_option(session(), Option::atom())->
%%                           session().
%%%% Defines the TOP_NUM which should be used to send c_op request to Sachem.

get_info_for_option(Session, Option)
  when Option==opt_ikdo_vx_sms;Option==opt_illimite_kdo ->
    get_opt_info(Session, {illimite, svc_options:top_num(opt_illimite_kdo,mobi)});
get_info_for_option(Session, Option)
  when Option==opt_illimite_kdo_v2 ->
    get_opt_info(Session, {illimite, svc_options:top_num(opt_ikdo_voix,mobi)});

get_info_for_option(Session, Option) ->
    get_opt_info(Session, svc_options:top_num(Option,mobi)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_opt_info(session(), TOPNUM::integer())->
%%                    session().
%%%% Send c_op request to Sachem server in order to get the fields 
%%%% OPT_DATE_SOUSCR and OPT_DATE_DEB_VALID for the given option.

get_opt_info(#session{prof=Prof}=Session, {illimite,TOP_NUM}) ->
    State = svc_util_of:get_user_state(Session),
    MSISDN = Prof#profile.msisdn,
    Id = {svc_util_of:get_souscription(Session),MSISDN},
    case svc_util_of:consult_account_options(Session, Id, 
                                             "1", MSISDN, TOP_NUM) of
        {ok, [_, [], _]}->
	    NewState =  State#sdp_user_state{numero_kdo_illimite = not_defined},
	    svc_util_of:update_user_state(Session,NewState);
        {ok, [[_,_,OPT_DATE_DEB_VALID,_,_,OPT_INFO2,_,_,_,_],
              [[MSISDN_KDO|TAIL]|MSISDN_rest], _]}->
	    OptInfo2_to_ms = optInfo2_to_ms(OPT_INFO2),
	    NewState =  State#sdp_user_state{numero_kdo_illimite = MSISDN_KDO,
					     c_op_opt_date_deb_valid = OPT_DATE_DEB_VALID,
					     c_op_opt_info2=OptInfo2_to_ms},
	    svc_util_of:update_user_state(Session,NewState);
        %% should be obsolete
        {ok, [[[_,_,OPT_DATE_DEB_VALID,_,_,OPT_INFO2,_,_,_,_]|_],
              [[MSISDN_KDO|TAIL]|MSISDN_rest], _]}->
	    OptInfo2_to_ms = optInfo2_to_ms(OPT_INFO2),
	    NewState =  State#sdp_user_state{numero_kdo_illimite = MSISDN_KDO,
					     c_op_opt_date_deb_valid = OPT_DATE_DEB_VALID,
					     c_op_opt_info2=OptInfo2_to_ms},
	    svc_util_of:update_user_state(Session,NewState);
        {nok, Reason} ->
	    slog:event(failure,?MODULE,get_opt_info_ill_consult_account_options,Reason),
	    Session;
	Error->
	    slog:event(failure,?MODULE,svi_c_op2_ko,Error),
	    Session
    end;

get_opt_info(#session{prof=Prof}=Session, TOPNUM) ->
    State = svc_util_of:get_user_state(Session),
    MSISDN = Prof#profile.msisdn,
    Id = {svc_util_of:get_souscription(Session),MSISDN},
    case svc_util_of:consult_account_options(Session, Id, TOPNUM) of
	{ok,[OPT_DATE_SOUSCR, OPT_DATE_DEB_VALID, _, _, OPT_INFO2]} ->
            OptInfo2_to_ms = optInfo2_to_ms(OPT_INFO2),
            KDO = case OPT_DATE_SOUSCR of
                      0 -> "0";
                      List when list(OPT_DATE_SOUSCR) ->
                          "0"++OPT_DATE_SOUSCR ;
                      _ ->
                          "0"++integer_to_list(OPT_DATE_SOUSCR)
                  end,
            NewState =  
		State#sdp_user_state{c_op_opt_date_souscr=KDO,
						     c_op_opt_date_deb_valid=
						     OPT_DATE_DEB_VALID,
						     c_op_opt_info2=OptInfo2_to_ms},
	    svc_util_of:update_user_state(Session,NewState);
	{nok, Reason} ->
	    slog:event(failure,?MODULE,get_opt_info,
		       {nok, Reason}),
	    Session;
	Error->
	    slog:event(failure,?MODULE,svi_c_op_ko,Error),
	    Session

    end.

optInfo2_to_ms(OPT_INFO2) ->    
    case OPT_INFO2 of
        []  -> 0;
        "-" -> 0;
        _   -> list_to_integer(OPT_INFO2)*1000
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_refill_amount(session(),Option::atom())->
%%                           erlpage_result().
%%%% Checks whether the refill amount of the current month is less, equal or
%%%% more than the limit specified by the configuration parameter
%%%% pservices_orangef / recharge_illimite_kdo_mini.

check_refill_amount(Session,Option=opt_illimite_kdo_v2) ->
    NewSess = get_info_for_option(Session, Option),
    State = svc_util_of:get_user_state(NewSess),
    OptInfo2 = State#sdp_user_state.c_op_opt_info2,
    Cpp_cumul_credit_Princ = 
	case svc_compte:cpte(State,cpte_princ) of
	    #compte{cpp_cumul_credit=CrPr} when is_integer(CrPr) -> CrPr;
	    _ -> 0
	end,
    Cpp_cumul_Illimite = 
	case svc_compte:cpte(State,cpte_illimite_kdo) of
	    #compte{cpp_cumul_credit=CrSMS} when is_integer(CrSMS) -> CrSMS;
	    _ -> 0
	end,
    Cumul = Cpp_cumul_credit_Princ + Cpp_cumul_Illimite,
    MonthRefill = case Cumul >= OptInfo2 of
		      true -> Cumul - OptInfo2;
		      _ -> 0
		  end,
    MinRefill =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_illimite_kdo_mini)),
    Value = currency:round_value(MinRefill)*1000,
    NewState =  State#sdp_user_state{refill_amount=MonthRefill},
    {(MonthRefill < Value),
     svc_util_of:update_user_state(Session,NewState)} ;
check_refill_amount(Session,Option) ->
    NewSess = get_info_for_option(Session, Option),
    State = svc_util_of:get_user_state(NewSess),
    OptInfo2 = State#sdp_user_state.c_op_opt_info2,
    Cpp_cumul_credit_Princ = 
	case svc_compte:cpte(State,cpte_princ) of
	    #compte{cpp_cumul_credit=CrPr} when is_integer(CrPr) -> CrPr;
	    _ -> 0
	end,
    Cpp_cumul_credit_Sms = 
	case svc_compte:cpte(State,cpte_sms) of
	    #compte{cpp_cumul_credit=CrSMS} when is_integer(CrSMS) -> CrSMS;
	    _ -> 0
	end,
    Cumul = Cpp_cumul_credit_Princ + Cpp_cumul_credit_Sms,
    MonthRefill = case Cumul >= OptInfo2 of
		      true -> Cumul - OptInfo2;
		      _ -> 0
		  end,
    MinRefill =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_illimite_kdo_mini)),
    Value = currency:round_value(MinRefill)*1000,
    NewState =  State#sdp_user_state{refill_amount=MonthRefill},
    {(MonthRefill < Value),
     svc_util_of:update_user_state(Session,NewState)} .

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_subscribed(session(),Opt::atom())->
%%                     bool().
%%%% Check whether subscription to option already exists.

is_subscribed(Session,Opt)
  when Opt==opt_tt_shuss;	   
	   Opt==opt_pack_duo_journee;
       Opt==opt_cb_mobi;
       Opt==opt_jinf;
       Opt==opt_roaming;
       Opt==opt_appelprixunique;
       Opt==opt_afterschool;
       Opt==opt_sms_quoti;
       Opt==opt_pass_vacances;
       Opt==opt_pass_vacances_z2;
	   Opt==opt_pass_voyage_9E;
       Opt==opt_pass_vacances_v2;
	   Opt==opt_pass_voyage_6E;	   
       Opt==opt_europe;
       Opt==opt_maghreb;
       Opt==opt_pass_dom;
       Opt==opt_illimite_kdo;
       Opt==opt_illimite_kdo_v2;
       Opt==opt_ikdo_vx_sms;
       Opt==opt_surf_mensu;
       Opt==opt_ow_3E_mobi;
       Opt==opt_ow_6E_mobi;
       Opt==opt_kdo_sinf;
       Opt==opt_sms_illimite;
       Opt==opt_tv_mensu;
       Opt==opt_musique_mensu;
       Opt==opt_sport_mensu;
       Opt==opt_total_tv_mensu;
       Opt==opt_tv;
       Opt==opt_tv_max;
       Opt==opt_internet;
	   Opt==opt_internet_v2_pp;
       Opt==opt_internet_max;
	   Opt==opt_internet_max_pp;
       Opt==opt_internet_max_v3;
       Opt==opt_musique;
       Opt==opt_zap_quoti;
       Opt==opt_cityzi ->
    svc_options:is_option_activated(Session,Opt);

is_subscribed(Session, Opt) ->
    Subscr = svc_util_of:get_souscription(Session),
    State = svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,svc_options:opt_to_godet(Opt,Subscr)) of
	#compte{etat=?CETAT_AC} ->
	    svc_options:is_option_activated(Session,Opt);
	_ ->
	    false
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_resubscr_allowed(session(),Opt::string())->
%%                           bool().
%%%% Check whether resubscription is allowed.

is_resubscr_allowed(Session,Opt)
  when Opt==opt_tt_shuss;Opt==opt_pack_duo_journee ->
    State = svc_util_of:get_user_state(Session),
    (svc_compte:etat_cpte(State,
			  svc_options:opt_to_godet(opt_tt_shuss_sms,
			  mobi))==?CETAT_EP) and
	(svc_compte:etat_cpte(State,
			      svc_options:opt_to_godet(opt_tt_shuss_voix_2,
			      mobi))==?CETAT_EP);
is_resubscr_allowed(Session,Opt)
  when Opt==opt_vacances;
       Opt==opt_pass_dom-> 
    true;
is_resubscr_allowed(Session,Opt)
  when Opt==opt_ow_3E_mobi;
       Opt==opt_ow_6E_mobi ->
    Subscr = svc_util_of:get_souscription(Session),
    State = svc_util_of:get_user_state(Session),
    (svc_compte:etat_cpte(State,
			  svc_options:opt_to_godet(Opt, mobi))==?CETAT_EP);
is_resubscr_allowed(Session,_)->
    false.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type init_options(session(),Opt::string())->
%%                    {ok,session()} | {error, term()}.
%%%% Modify sdp_user_state if necessary.
%%%% Used only for option numpref.

init_options(#session{prof=Prof}=Session, opt_numprefp) ->
    MSISDN = Prof#profile.msisdn,
    State = svc_util_of:get_user_state(Session),
    Id = {svc_util_of:get_souscription(Session),MSISDN},
    Top_num = svc_options:top_num(opt_numprefp,mobi),
    case svc_util_of:consult_account_options(Session, Id, Top_num) of
	{ok,_}->
	    State2=State#sdp_user_state{numero_prefere=
					#numero_prefere{numprefp=true}},
	    {ok,svc_util_of:update_user_state(Session,State2)};
	{nok_opt_not_activated,""} ->
	    State2=State#sdp_user_state{numero_prefere=
					#numero_prefere{numprefp=false}},
	    {ok,svc_util_of:update_user_state(Session,State2)};
        {nok, Reason} ->
            slog:event(failure,?MODULE,init_options_consult_account_options,Reason),
            {error, Reason};
	Error->
	    slog:event(failure,?MODULE,svi_c_op_ko,Error),
	    {error,Error}
    end;

init_options(S,_) ->
    {ok,S}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type cpte_and_option_state(session(),Opt::atom())-> 
%%                              {atom(),atom()}.
%%%% Check account (cpte) state and whether option is activated.

cpte_and_option_state(Session,Opt) ->
    State = svc_util_of:get_user_state(Session),
    IsCpte=(case svc_compte:cpte(State,svc_options:opt_to_godet(Opt,mobi)) of
		#compte{etat=?CETAT_AC} -> cpte_ac;
		#compte{etat=?CETAT_EP} -> cpte_ep;
		#compte{}               -> cpte_pe;
	        _                       -> cpte_undef
	    end),
    IsOpt=(case svc_options:state(Session, Opt) of
	       actived  -> opt_ac;
	       suspend -> opt_nac;
	       not_actived ->opt_nac
	   end),
    {IsCpte,IsOpt}.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type credit_and_option_state(session(),Opt::string())->
%%                               princ_sec | princ_no_sec |
%%                               no_princ_sec | no_princ_no_sec.
%%%% Check account credit and whether option is activated.

credit_and_option_state(Session,Opt)
  when Opt==opt_sms_quoti;
       Opt==opt_sms_mensu;
       Opt==opt_mms_mensu;
       Opt==opt_surf_mensu->
    State = svc_util_of:get_user_state(Session),
    case svc_options:is_option_activated(Session,Opt) of
	false -> opt_nac;
	true -> 
	    {_,_,SoldePrinc} = svc_compte:solde_cpte(State,cpte_princ),
	    {_,_,SoldeSec} =
		svc_compte:solde_cpte(State,
				      svc_options:opt_to_godet(Opt,mobi)),
	    case {SoldePrinc >= svc_util_of:subscription_price(Session, Opt),
		  SoldeSec > 0} of 
		{true, true}   -> princ_sec;
		{true, false}  -> princ_no_sec;
		{false, true}  -> no_princ_sec;
		{false, false} -> no_princ_no_sec
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_incomp(session(),Opt::string())->
%%                        bool().
%%%% Check incompatibilities between options.

is_option_incomp(Session,opt_jinf) ->
    svc_options:is_option_activated(Session,opt_erech_jinf);

is_option_incomp(Session,opt_ssms_illimite) ->
    svc_options:is_option_activated(Session,opt_6sms_quoti);

is_option_incomp(Session,opt_jsms_illimite) ->
    svc_options:is_option_activated(Session,opt_6sms_quoti)
	or svc_options:is_option_activated(Session,opt_tt_shuss_sms);

is_option_incomp(Session,opt_erech_jinf) ->
    svc_options:is_option_activated(Session,opt_jinf);

is_option_incomp(Session,opt_europe) ->
    svc_options:is_option_activated(Session,opt_maghreb)
	or svc_options:is_option_activated(Session,opt_roaming)
	or svc_options:is_option_activated(Session,opt_voyage)
	or svc_options:is_option_activated(Session,opt_pass_vacances)
	or svc_options:is_option_activated(Session,opt_pass_vacances_v2);
    
is_option_incomp(Session,opt_maghreb) ->
    svc_options:is_option_activated(Session,opt_europe)
	or svc_options:is_option_activated(Session,opt_roaming)
	or svc_options:is_option_activated(Session,opt_voyage)
	or svc_options:is_option_activated(Session,opt_pass_vacances)
	or svc_options:is_option_activated(Session,opt_pass_vacances_v2);

is_option_incomp(Session,opt_pass_dom) ->
    svc_options:is_option_activated(Session,opt_pass_voyage_9E)
	or svc_options:is_option_activated(Session,opt_pass_voyage_6E);

is_option_incomp(Session,opt_voyage) ->
    svc_options:is_option_activated(Session,opt_europe)
	or svc_options:is_option_activated(Session,opt_maghreb)
	or svc_options:is_option_activated(Session,opt_roaming)
	or svc_options:is_option_activated(Session,opt_pass_vacances)
	or svc_options:is_option_activated(Session,opt_pass_vacances_v2);

is_option_incomp(Session,opt_pass_vacances) ->
    State = svc_util_of:get_user_state(Session),
    svc_options:is_option_activated(Session,opt_europe)
	or svc_options:is_option_activated(Session,opt_maghreb)
	or svc_options:is_option_activated(Session,opt_roaming)
	or svc_options:is_option_activated(Session,opt_voyage)
	or (svc_compte:etat_cpte(State,roaming_in)==?CETAT_AC);

is_option_incomp(Session,Opt)
when Opt==opt_pass_vacances_z2;Opt==opt_pass_voyage_9E ->
    State = svc_util_of:get_user_state(Session),
    svc_options:is_option_activated(Session,opt_europe)
	or svc_options:is_option_activated(Session,opt_maghreb)
	or svc_options:is_option_activated(Session,opt_roaming)
	or svc_options:is_option_activated(Session,opt_pass_vacances)
	or svc_options:is_option_activated(Session,opt_pass_voyage_6E)
	or svc_options:is_option_activated(Session,opt_voyage)
	or (svc_compte:etat_cpte(State,roaming_in)==?CETAT_AC);

is_option_incomp(Session,Opt)
when Opt==opt_pass_vacances_v2;Opt==opt_pass_voyage_6E ->
    is_option_incomp(Session,opt_pass_vacances) or
	svc_options:is_option_activated(Session,opt_pass_voyage_9E) or
	svc_options:is_option_activated(Session,opt_pass_supporter);

is_option_incomp(Session,Opt)
when Opt==opt_tt_shuss;Opt==opt_pack_duo_journee ->
    svc_options:is_option_activated(Session,opt_vacances);

is_option_incomp(Session,opt_vacances) ->
    svc_options:is_option_activated(Session,opt_pack_duo_journee);

is_option_incomp(Session,opt_tv) ->
    svc_options:is_option_activated(Session,opt_tv_max)
	or svc_options:is_option_activated(Session,opt_tv_mensu)
	or svc_options:is_option_activated(Session,opt_total_tv_mensu)
	or svc_options:is_option_activated(Session,opt_surf)
	or svc_options:is_option_activated(Session,opt_top_num_198);

is_option_incomp(Session,opt_tv_max) ->
    svc_options:is_option_activated(Session,opt_tv)
	or svc_options:is_option_activated(Session,opt_tv_mensu)
	or svc_options:is_option_activated(Session,opt_total_tv_mensu)
	or svc_options:is_option_activated(Session,opt_surf)
	or svc_options:is_option_activated(Session,opt_sport)
	or svc_options:is_option_activated(Session,opt_top_num_198);

is_option_incomp(Session,opt_total_tv) ->
    svc_options:is_option_activated(Session,opt_tv)
	or svc_options:is_option_activated(Session,opt_tv_mensu)
	or svc_options:is_option_activated(Session,opt_total_tv_mensu)
	or svc_options:is_option_activated(Session,opt_top_num_198);

is_option_incomp(Session,opt_sport) ->
    svc_options:is_option_activated(Session,opt_sport_mensu);

is_option_incomp(Session,opt_musique_v0) ->
    svc_options:is_option_activated(Session,opt_musique_mensu);

is_option_incomp(Session,opt_musique_mix) ->
    svc_options:is_option_activated(Session,opt_musique)
	or svc_options:is_option_activated(Session,opt_musique_collection);

is_option_incomp(Session,opt_musique_collection) ->
    svc_options:is_option_activated(Session,opt_musique)
	or svc_options:is_option_activated(Session,opt_musique_mix);

is_option_incomp(Session,opt_musique) ->
    svc_options:is_option_activated(Session,opt_musique_v0)
	or svc_options:is_option_activated(Session,opt_musique_mensu);

is_option_incomp(Session,ow_tv) ->
    svc_options:is_option_activated(Session,opt_tv_mensu);

is_option_incomp(Session,ow_tv1) ->
    svc_options:is_option_activated(Session,opt_tv_mensu);

is_option_incomp(Session,ow_tv2) ->
    svc_options:is_option_activated(Session,opt_tv_mensu);

is_option_incomp(Session,opt_J_illi_Data) ->
    svc_options:is_option_activated(Session,opt_tv_mensu);

is_option_incomp(Session,opt_msn_journee_mobi) ->
    svc_options:is_option_activated(Session,opt_msn_mensu_mobi);

is_option_incomp(Session,opt_tv_mensu) ->
    svc_options:is_option_activated(Session,opt_tv)
	or svc_options:is_option_activated(Session,opt_total_tv)
	or svc_options:is_option_activated(Session,ow_tv)
	or svc_options:is_option_activated(Session,ow_tv1)
	or svc_options:is_option_activated(Session,ow_tv2)
	or svc_options:is_option_activated(Session,opt_J_illi_Data)
	or svc_options:is_option_activated(Session,opt_total_tv_mensu)
	or svc_options:is_option_activated(Session,opt_top_num_198);

is_option_incomp(Session,opt_musique_mensu) ->
    svc_options:is_option_activated(Session,opt_musique);

is_option_incomp(Session,opt_sport_mensu) ->
    svc_options:is_option_activated(Session,opt_sport);

is_option_incomp(Session,opt_total_tv_mensu) ->
    svc_options:is_option_activated(Session,opt_tv)
	or svc_options:is_option_activated(Session,opt_total_tv)
	or svc_options:is_option_activated(Session,opt_tv_mensu)
	or svc_options:is_option_activated(Session,opt_top_num_198);

is_option_incomp(Session,opt_top_num_198) ->
    svc_options:is_option_activated(Session,opt_tv)
	or svc_options:is_option_activated(Session,opt_total_tv)
	or svc_options:is_option_activated(Session,opt_tv_mensu)
	or svc_options:is_option_activated(Session,opt_total_tv_mensu);

is_option_incomp(Session,opt_ow_3E_mobi) ->
    svc_options:is_option_activated(Session,opt_ow_6E_mobi)
	or svc_options:is_option_activated(Session,opt_ow_10E_mobi);

is_option_incomp(Session,opt_ow_6E_mobi) ->
    svc_options:is_option_activated(Session,opt_ow_3E_mobi)
	or svc_options:is_option_activated(Session,opt_ow_10E_mobi);

is_option_incomp(Session,opt_ow_10E_mobi) ->
    svc_options:is_option_activated(Session,opt_ow_6E_mobi)
	or svc_options:is_option_activated(Session,opt_ow_3E_mobi);

is_option_incomp(Session,opt_sinf) ->
    {Date,_} = svc_util_of:local_time(),
    DoW = calendar:day_of_the_week(Date),
    ((DoW == 6) or (DoW == 7)) 
	and svc_options:is_option_activated(Session,opt_weinf);

is_option_incomp(Session,opt_weinf) ->
    {Date,_} = svc_util_of:local_time(),
    svc_options:is_option_activated(Session,opt_sinf)
	and (calendar:day_of_the_week(Date) < 6);

is_option_incomp(Session,opt_illimite_kdo) ->
    {Date,_} = svc_util_of:local_time(),
    svc_options:is_option_activated(Session,opt_temps_plus);

is_option_incomp(Session,Opt)
when Opt==opt_internet;Opt==opt_internet_v2_pp ->
    svc_options:is_option_activated(Session,opt_internet_max_pp)
	or svc_options:is_option_activated(Session,opt_internet_max_v3)
	or svc_options:is_option_activated(Session,opt_surf)
	or svc_options:is_option_activated(Session,opt_ow_3E_mobi);

is_option_incomp(Session,opt_internet_max_journee) ->
    svc_options:is_option_activated(Session,opt_internet_max_weekend);

is_option_incomp(Session,Opt)
when Opt==opt_internet_max;
	 Opt==opt_internet_max_pp->
    svc_options:is_option_activated(Session,opt_internet)
	or svc_options:is_option_activated(Session,opt_surf)
	or svc_options:is_option_activated(Session,opt_ow_3E_mobi);

is_option_incomp(Session,opt_internet_max_v3) ->
    svc_options:is_option_activated(Session,opt_internet_v2_pp)
	or svc_options:is_option_activated(Session,opt_surf)
	or svc_options:is_option_activated(Session,opt_total_tv)
	or svc_options:is_option_activated(Session,ow_tv)
	or svc_options:is_option_activated(Session,ow_tv2)
	or svc_options:is_option_activated(Session,opt_suft_mensu)
	or svc_options:is_option_activated(Session,opt_internet_max_bis)
	or svc_options:is_option_activated(Session,opt_internet_max_pp);

is_option_incomp(_,_) -> false.


%% +type print_incomp_opts(session(),Option::string())-> 
%%                        [{pcdata,string()}].
%%%% Print list of incompatible options.

print_incomp_opts(abs, _)->
    [{pcdata,""}]++get_opt_incomp(abs, [], [""]);
print_incomp_opts(Session, Option)
  when Option == "opt_pass_vacances" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_maghreb", "opt_edition_special","opt_pass_supporter"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option=="opt_pass_vacances_v2";Option=="opt_pass_voyage_6E" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_maghreb", "opt_pass_voyage_9E","opt_pass_supporter","opt_pass_dom"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_europe" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_maghreb", "opt_pass_voyage_6E", "opt_pass_voyage_9E"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_maghreb" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_pass_voyage_6E", "opt_pass_voyage_9E"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_pass_dom" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_pass_voyage_6E", "opt_pass_voyage_9E"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_pass_vacances_z2";Option == "opt_pass_voyage_9E" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_maghreb", "opt_pass_voyage_6E", "opt_pass_dom"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_internet_max_v3" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_total_tv",  
		"ow_tv","ow_tv2",
		"opt_surf","opt_surf_mensu",
		"opt_internet_max_pp","opt_internet_max_bis"],
    get_opt_incomp(Session1, List_opt, "").

%% +type get_opt_incomp(session(),ListOpt::[string()], Accu::[string()])-> 
%%                        [{pcdata,string()}].
%%%% Internal function used to find out all incompatibles
%%%% options with the second argument.
get_opt_incomp(abs, [], [""])->
    [{pcdata,"Any incompatibility found"}];
get_opt_incomp(Session, [Opt|Tail], Accu)
  when Opt == "opt_edition_special" ->
    Option = list_to_atom(Opt),
    State = svc_util_of:get_user_state(Session),
    case (svc_compte:etat_cpte(State,cpte_avoix)==?CETAT_AC) of
	true ->
	 [{pcdata,Name}] = svc_options:print_commercial_name(Session, Opt),
	    NewAccu = lists:concat([Accu,separator(Accu),Name]),
	    get_opt_incomp(Session, Tail,NewAccu);
	_->
	  get_opt_incomp(Session, Tail, Accu)
    end;
get_opt_incomp(Session, [Opt|Tail], Accu)->
    Option = list_to_atom(Opt),
    case svc_options:is_option_activated(Session,Option) of
	true ->
	 [{pcdata,Name}] = svc_options:print_commercial_name(Session, Opt),
	    NewAccu = lists:concat([Accu,separator(Accu),Name]),
	    get_opt_incomp(Session, Tail,NewAccu);
	_->
	  get_opt_incomp(Session, Tail, Accu)
    end;
get_opt_incomp(Session,[],Accu) ->
    [{pcdata,Accu}].

%% +type separator(Accu::[string()])-> [string()].    
separator(Accu)->
    case Accu of
	"" ->
	    Accu;
	_ ->
	    '; '
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TERMINATION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_unsubscription_request(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Terminate subscription to options.

do_unsubscription_request(#session{}=S,Opt,URLs) 
  when Opt==opt_sms_quoti;
       Opt==opt_sms_mensu;
       Opt==opt_temps_plus;
       Opt==opt_illimite_kdo;
       Opt==opt_surf_mensu;
       Opt==opt_mms_mensu;
       Opt==opt_tv_mensu;
       Opt==opt_musique_mensu;
       Opt==opt_sport_mensu;
       Opt==opt_total_tv_mensu;
       Opt==opt_zap_quoti;
       Opt==opt_msn_mensu_mobi;
       Opt==opt_tv;
       Opt==opt_internet_max;
	   Opt==opt_internet_max_pp;
       Opt==opt_internet_max_v3;
       Opt==opt_musique_mix;
       Opt==opt_tv_max;
       Opt==opt_cityzi;
       Opt==opt_unik;
       Opt==opt_sms_illimite ->
    [Uok,Unok] = string:tokens(URLs, ","),
    case svc_options:do_opt_cpt_request(S,Opt,terminate) of
	{Session1,{ok_operation_effectuee,_}} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
	{_,E} ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, S, Unok}
    end;

do_unsubscription_request(#session{}=S,Opt,URLs) 
  when Opt==opt_ikdo_vx_sms ->
    [Uok,Unok] = string:tokens(URLs, ","),
    case svc_options:do_opt_cpt_request(S,opt_illimite_kdo,terminate) of
	{Session1,{ok_operation_effectuee,_}} ->
	    case svc_options:do_opt_cpt_request(Session1,
						opt_ikdo_vx_sms,
						terminate) of
		{Session2,{ok_operation_effectuee,_}} ->
		    {_,Session_}= svc_util_of:reinit_compte(Session2),
		    {redirect,Session_,Uok};
		{_,E} ->
		    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
		    {redirect, S, Unok}
	    end;
	{_,E} ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, S, Unok}
    end;
do_unsubscription_request(#session{}=S,Opt,URLs) 
  when Opt==opt_illimite_kdo_v2 ->
    [Uok,Unok] = string:tokens(URLs, ","),
    case svc_options:do_opt_cpt_request(S,opt_ikdo_voix,terminate) of
	{Session1,{ok_operation_effectuee,_}} ->
	    case svc_options:do_opt_cpt_request(Session1,
						opt_ikdo_sms,
						terminate) of
		{Session2,{ok_operation_effectuee,_}} ->
		    {_,Session_}= svc_util_of:reinit_compte(Session2),
		    {redirect,Session_,Uok};
		{_,E} ->
		    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
		    {redirect, S, Unok}
	    end;
	{_,E} ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, S, Unok}
    end;
do_unsubscription_request(#session{}=Session,Opt,URLs)
  when Opt==opt_pass_vacances; 
       Opt==opt_pass_vacances_v2; 
       Opt==opt_internet;
	   Opt==opt_internet_v2_pp;
       Opt==opt_internet_max;
	   Opt==opt_internet_max_pp;
       Opt==opt_internet_max_v3;
       Opt==opt_tt_shuss;
       Opt==opt_zap_zone;
	   Opt==opt_pack_ado->
    Options = case Opt of
				  opt_pass_vacances ->
					  [opt_pass_vacances_moc,opt_pass_vacances_mtc];
				  opt_pass_vacances_v2 ->
					  [opt_pass_vacances_v2_moc,opt_pass_vacances_v2_mtc,opt_pass_vacances_v2_10_sms];
				  opt_internet ->
					  [opt_internet,opt_internet_bis];
				  opt_internet_max ->
					  [opt_internet_max,opt_internet_max_bis];
				  opt_internet_max_v3 ->
					  [opt_internet_max_v3];
				  opt_tt_shuss ->
					  [opt_tt_shuss_sms,opt_tt_shuss_voix_2];
				  opt_zap_zone->
					  [opt_zap_zone, opt_zap_zone_bis];
				  _ ->
					  Opt
			  end,
    [Uok,Unok] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
	{Session1,Rs} = case is_list(Options) of 
						true -> 
							svc_options:do_nopt_cpt_request(S,Options,terminate,[]);
						_ ->
							svc_options:do_opt_cpt_request(S,Options,terminate)
					end,															
    case Rs of
		{ok_operation_effectuee,_} ->
			{_,Session_}= svc_util_of:reinit_compte(Session1),
			{redirect, Session_,Uok};
		E ->
			slog:event(failure, ?MODULE, bad_response_from_sdp, E),
			{redirect, Session1, Unok}
    end.



%% +type do_unsubscription_request(session(),Opt::string())->
%%                                 erlpage_result().
%%%% Terminate subscription to option opt_jinf.

do_unsubscription_request(#session{}=S,Opt) 
  when Opt==opt_jinf ->
    case svc_options:do_opt_cpt_request(S,Opt,terminate) of
	{Session1,{ok_operation_effectuee,_}} ->
	    svc_util_of:reinit_compte(Session1);
	{_,E} ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E)	    
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODIFICATION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_register_request(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Terminate subscription to options.

do_register_request(#session{}=S,Option,URLs) 
  when list(Option) ->
    do_register_request(S, list_to_atom(Option), URLs);
do_register_request(#session{}=S,Opt,URLs) 
  when Opt==opt_illimite_kdo;
       Opt==opt_ikdo_vx_sms->
    [Uok,UnotOF,Unok] = string:tokens(URLs, ","),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,modify),
    case Result of
	{ok_operation_effectuee,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
	{nok_num_not_Orange,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
        {error, "numero_invalid"} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};        
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end;

do_register_request(#session{prof=Profile}=S,Opt,URLs)
  when Opt==opt_bonus_appels;
       Opt==opt_bonus_sms;
       Opt==opt_bonus_internet;
       Opt==opt_bonus_europe;
       Opt==opt_bonus_maghreb;
       Opt==opt_bonus_appels_promo;
       Opt==opt_bonus_sms_promo;
       Opt==opt_bonus_internet_promo;
       Opt==opt_bonus_europe_promo;
       Opt==opt_bonus_maghreb_promo ->
    [Uok,Unok] = string:tokens(URLs, ","),
    {Session1,Result} = maj_op(S,Opt),
    case Result of 
	{ok_operation_effectuee,_} ->
	    {_,NSession}= svc_util_of:reinit_prepaid(Session1),
	    Subscription = svc_util_of:get_souscription(NSession),
	    Msisdn = Profile#profile.msisdn,
	    PTChangePrice = currency:sum(euro,0),
	    Compte = #compte{ptf_num=svc_options:ptf_num(Opt,mobi),
			     pct=PTChangePrice,
			     d_crea=pbutil:unixtime(),
			     tcp_num=?C_PRINC,
			     ctrl_sec=0},
	    case svc_util_of:change_user_account(NSession, {Subscription, Msisdn},Compte) of
		{ok,{Session_updated,Resp_params}} ->
		    slog:event(trace,?MODULE,do_register_request,ok),
		    {redirect, Session_updated, Uok};
		Error ->
		    slog:event(failure, ?MODULE, bad_response_from_sdp, Error),
		    {redirect, NSession, Unok}
	    end;
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end;


%%%% We need to send the OPT_CPT2 requestion only for
%%%% the TOP_NUM=166::opt_ikdi_voix. CDC 29
do_register_request(#session{}=S,Opt,URLs) 
    when Opt==opt_illimite_kdo_v2 ->
    [Uok,UnotOF,Unok] = string:tokens(URLs, ","),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,opt_ikdo_voix,modify),
    case Result of
	{ok_operation_effectuee,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
	{nok_num_not_Orange,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
        {error, "numero_invalid"} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end.

do_register_request(#session{}=S,"opt_illimite_kdo_v2",Act,URLs) ->
    Action = list_to_atom(Act),
    [Uok,UnotOF,Unok] = string:tokens(URLs, ","),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,opt_ikdo_voix,Action),
    case Result of
	{ok_operation_effectuee,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
	{nok_num_not_Orange,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
        {error, "numero_invalid"} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUBSCRIPTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription_request(session(),Opt::string(),URLs::string(),
%%                               Uopt_bloquee::string())->
%%                               erlpage_result().
%%%% Subscribe to options.

do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee)
  when Opt==opt_weinf;
       Opt==opt_ssms;
       Opt==opt_sinf;
       Opt==opt_jinf;
       Opt==opt_sport;
       Opt==opt_vacances;
       Opt==opt_voyage;
       Opt==opt_appelprixunique;
       Opt==opt_sms_quoti;
       Opt==opt_ow_3E_mobi;
       Opt==opt_ow_6E_mobi;
       Opt==opt_tv;
       Opt==opt_tv_max;
       Opt==opt_total_tv;
       Opt==opt_surf;
       Opt==opt_musique;
       Opt==opt_illimite_kdo;
       Opt==opt_kdo_sinf;
       Opt==opt_sms_illimite;
       Opt==opt_pack_duo_journee;
       Opt==opt_unik ->

    [Uok,UdejaAct,Uinsuff,Unok,Uok_princ,Uok_bp,Uok_tranfert,Uok_dixit] = 
        string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,subscribe),
    case Result of
	{ok_operation_effectuee,[?C_BONS_PLANS, CPP_SOLDE]} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok_bp};
	{ok_operation_effectuee,[?C_DIXIT_BONS_PLANS, CPP_SOLDE]} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok_dixit};
	{ok_operation_effectuee,[?C_OFFERT, CPP_SOLDE]} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok_tranfert};
        %% In Sachem Tuxedo, we do not have account info
	{ok_operation_effectuee,_} ->
		%% reset user account information
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
        Result ->
            svc_options:redirect_update_option(Session1, Result, Uok, UdejaAct, 
                                               Uinsuff, Uopt_bloquee, Unok)
    end;
do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee) 
  when Opt==opt_europe;
       Opt==opt_maghreb;
       Opt==opt_pass_dom->
    [Uok,UdejaAct,Uinsuff,UIncomp,Unok,Uok_bp,Uok_tranfert,Uok_dixit] =
        string:tokens(URLs, ","),
        S = variable:update_value(Session, {?MODULE, option}, Opt),
        {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,subscribe),
        case Result of
        {ok_operation_effectuee,[?C_BONS_PLANS, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
		{redirect,Session_,Uok_bp};
	    {ok_operation_effectuee,[?C_DIXIT_BONS_PLANS, CPP_SOLDE]} ->
		{_,Session_}= svc_util_of:reinit_compte(Session1),
		{redirect,Session_,Uok_dixit};
	    {ok_operation_effectuee,[?C_OFFERT, CPP_SOLDE]} ->
		{_,Session_}= svc_util_of:reinit_compte(Session1),
		{redirect,Session_,Uok_tranfert};
	    %% In Sachem Tuxedo, we do not have account info
	    {ok_operation_effectuee,_} ->
                %% reset user account information
		{_,Session_}= svc_util_of:reinit_compte(Session1),
		{redirect,Session_,Uok};
	    Result ->
		svc_options:redirect_update_option(Session1, Result, Uok, UdejaAct,
						   Uinsuff, UIncomp, Uopt_bloquee, Unok) 
	end;

do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee) 
  when Opt==opt_10mn_europe->
    [Uok,UdejaAct,Uinsuff,UIncomp,Unok] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,subscribe),
    svc_options:redirect_update_option(Session1, Result, Uok, UdejaAct,
                                       Uinsuff,UIncomp,Uopt_bloquee, Unok);
    
do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee)
  when Opt==opt_ikdo_vx_sms ->
    [Uok,UdejaAct,Uinsuff,Unok] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    {Session1,RS} = svc_options:do_opt_cpt_request(S,opt_illimite_kdo,subscribe),
    case RS of
	{ok_operation_effectuee,_} ->
            {Session2,Result} = svc_options:do_opt_cpt_request(Session1,
                                                    opt_ikdo_vx_sms,
                                                    subscribe),
            svc_options:redirect_update_option(Session2, Result, Uok, UdejaAct, 
                                               Uinsuff, Uopt_bloquee, Unok);
        Result_2 ->
            svc_options:redirect_update_option(Session1, Result_2, Uok, UdejaAct, 
                                               Uinsuff, Uopt_bloquee, Unok)
    end;


do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee)
  when Opt==opt_pass_vacances; 
       Opt==opt_pass_vacances_v2;
       Opt==opt_pass_vacances_z2; 
       Opt==opt_internet;
	   Opt==opt_internet_v2_pp;
       Opt==opt_internet_max;
	   Opt==opt_internet_max_pp;
       Opt==opt_internet_max_v3;
       Opt==opt_tt_shuss;
       Opt==opt_zap_zone;
	   Opt==opt_pack_ado;
       Opt==opt_illimite_kdo_v2->
    Options = case Opt of
				  opt_illimite_kdo_v2 ->
					  [opt_ikdo_voix, opt_ikdo_sms];
				  opt_pass_vacances ->
					  [opt_pass_vacances_moc,opt_pass_vacances_mtc];
				  opt_pass_vacances_v2 ->
					  [opt_pass_vacances_v2_moc,opt_pass_vacances_v2_mtc,opt_pass_vacances_v2_10_sms];
				  opt_pass_vacances_z2 ->
					  [opt_pass_vacances_z2_moc,opt_pass_vacances_z2_mtc,opt_pass_vacances_z2_sms];
				  opt_internet ->
					  [opt_internet,opt_internet_bis];
				  opt_internet_max ->
					  [opt_internet_max,opt_internet_max_bis];
				  opt_internet_max_v3 ->
					  [opt_internet_max_v3];
				  opt_tt_shuss ->
					  [opt_tt_shuss_sms,opt_tt_shuss_voix_2];
				  opt_zap_zone->
					  [opt_zap_zone, opt_zap_zone_bis];
				  _ ->
					  Opt
			  end,
    [Uok,UdejaAct,Uinsuff,Unok,Uok_princ,Uok_bp,Uok_tranfert,Uok_dixit] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
	{Session1,Rs} = maj_op(S,Options),
    case Rs of
        {ok_operation_effectuee,[?C_PRINC, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_princ};
        {ok_operation_effectuee,[?C_BONS_PLANS, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_bp};
        {ok_operation_effectuee,[?C_DIXIT_BONS_PLANS, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_dixit};
        {ok_operation_effectuee,[?C_OFFERT, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_tranfert};
        Result ->
            svc_options:redirect_update_option(
              Session1, Result, Uok_princ, UdejaAct, 
              Uinsuff, Uopt_bloquee, Unok)
    end;
do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee)
  when Opt==opt_pass_voyage_6E;
       Opt==opt_pass_voyage_9E->
    [Uok,UdejaAct,Uinsuff, UIncomp, Unok,Uok_princ,Uok_bp,Uok_tranfert,Uok_dixit] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    {Session1,Rs} = maj_op(S,Opt),
    case Rs of
        {ok_operation_effectuee,[?C_PRINC, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_princ};
        {ok_operation_effectuee,[?C_BONS_PLANS, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_bp};
        {ok_operation_effectuee,[?C_DIXIT_BONS_PLANS, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_dixit};
        {ok_operation_effectuee,[?C_OFFERT, CPP_SOLDE]} ->
            {_,Session_}= svc_util_of:reinit_compte(Session1),
            {redirect,Session_,Uok_tranfert};
        Result ->
            svc_options:redirect_update_option(
              Session1, Result, Uok_princ, UdejaAct,
              Uinsuff, UIncomp, Uopt_bloquee, Unok)
    end;
do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee)
 when Opt==opt_erech_jinf;
      Opt==opt_afterschool ->
    [Uok,Unok] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    {Session1,Result} =  svc_options:do_opt_cpt_request(S,Opt,subscribe),
    svc_options:redirect_update_option(Session1, Result, Uok, Unok, Unok, 
                                       Uopt_bloquee, Unok);


%% old option : Ask orange to remove it. use the old request OPT_CPT
do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee)
    when Opt == opt_ow_10E_mobi ->
    [Uok,Uinsuff,Unok] = string:tokens(URLs, ","),
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    case svc_options:do_opt_cpt_request(S,Opt,subscribe) of
	{Session1,{ok_operation_effectuee,_}} ->
            {Session2,Result} = svc_options:do_opt_cpt_request(Session1,opt_bonus_int,subscribe),
            svc_options:redirect_update_option(Session2, Result, Uok, Unok, 
                                               Uinsuff, Uopt_bloquee, Unok);
        {Session1,Result2} ->
            svc_options:redirect_update_option(Session1, Result2, Uok, Unok, 
                                               Uinsuff, Uopt_bloquee, Unok)
    end;

%% The option opt_numprefp use the old request OPT_CPT
do_subscription_request(#session{prof=Prof}=Session,Opt,URLs,Uopt_bloquee) 
  when Opt==opt_numprefp ->
    Sess = variable:update_value(Session, {?MODULE, option}, Opt),
    {{Y,M,D},{H,Mi,S}}=svc_util_of:local_time(),
    %% Position to 12:00 to avoid time difference problems
    {{Yf,Mf,Df},_}=
	svc_util_of:add_seconds_to_datetime({{Y,M,D},{12,0,0}},7*86400),
    State = svc_util_of:get_user_state(Sess),
    NumPref=State#sdp_user_state.numero_prefere,
    Montant=integer_to_list(svc_util_of:subscription_price(Sess, Opt)),
    DateDeb = lists:flatten(pbutil:sprintf("%02d/%02d/%04d",[D,M,Y])),
    HeureDeb = lists:flatten(pbutil:sprintf("%02d:%02d:%02d",[H,Mi,S])),
    DateFin = lists:flatten(pbutil:sprintf("%02d/%02d/%04d",[Df,Mf,Yf])),
    HeureFin = "23:59:59",
    Msisdn=Prof#profile.msisdn,
    [Uok,Uinsuff,Unok]=string:tokens(URLs, ","),
    Now=pbutil:unixtime(),
    V_type = case svc_compte:cpte(State,forf_num_pref) of
		 #compte{dlv=Dlv} when Dlv < Now -> "A";
		 #compte{} -> svc_options:get_modify_action(Session, Opt);
		 _ -> "A"
	     end,		 

    Test2 = svc_options:is_option_activated(Sess,opt_numprefg)
	and 
	  ((case svc_compte:cpte(State,forf_num_pref) of
		#compte{dlv=Dlv_} when Dlv_ < Now -> true;
		#compte{} -> false;
		_ -> true
	    end)
	   or
	   svc_options:is_option_activated(Sess,opt_numprefp)
	  ),
    
    case Test2 of	 
	false ->
	    %% no active option or only toll option active
	    Req=#opt_cpt_request{type_action=V_type,
				 top_num="3",
				 date_deb=DateDeb,
				 heure_deb=HeureDeb,
				 date_fin=DateFin,
				 heure_fin=HeureFin,
				 cout=Montant,
				 tcp_num="24",
				 ptf_num="20",
				 mnt_initial=
				 svc_options:mnt_initial(Opt, mobi),
				 rnv_num="0",
				 msisdn1=NumPref#numero_prefere.numero},
            case svc_options:send_update_account_options(Session, {mobi,Msisdn}, 
                                                    subscribe, Req) of
		{ok_operation_effectuee,_} ->
		    prisme_dump:prisme_count(Session,opt_numprefp),
		    {redirect,Sess,Uok,[{"DATE_FIN",DateFin},
					{"NUM_PREF",
					 NumPref#numero_prefere.numero}]};
		{opt_bloquee_101,_} ->
		    {redirect,Sess,Uopt_bloquee};
		E ->
		    slog:event(failure, ?MODULE,bad_resp_from_sdp,E),
		    {redirect, Sess, Unok}
	    end;
        true ->
	    %% free option active or both free and toll option active
	    Req1=#opt_cpt_request{type_action=svc_options:get_modify_action(
                                                Session, Opt),
				  top_num="3",
				  date_deb=DateDeb,
				  heure_deb=HeureDeb,
				  cout="0",
				  tcp_num="-1",
				  ptf_num="0",
				  mnt_initial="0",
				  rnv_num="0",
				  msisdn1=NumPref#numero_prefere.numero},
            case svc_options:send_update_account_options(Session, 
                                                         {mobi,Msisdn}, 
                                                         subscribe, Req1) of
		{ok_operation_effectuee,_} ->
		    Req2=#opt_cpt_request{type_action=V_type,
					  top_num="36",
					  date_deb=DateDeb,
					  heure_deb=HeureDeb,
					  date_fin=DateFin,
					  heure_fin=HeureFin,
					  cout=Montant,
					  tcp_num="24",
					  ptf_num="20",
					  mnt_initial=
					  svc_options:mnt_initial(Opt, mobi),
					  rnv_num="0"},
                    case svc_options:send_update_account_options(Session, 
                                                                 {mobi,Msisdn}, 
                                                                 subscribe, Req2) of
                        {ok_operation_effectuee,_} ->
			    {redirect,Sess,Uok,
			     [{"DATE_FIN",DateFin},
			      {"NUM_PREF",NumPref#numero_prefere.numero}]};
                        {ok,_} ->
			    {redirect,Sess,Uok,
			     [{"DATE_FIN",DateFin},
			      {"NUM_PREF",NumPref#numero_prefere.numero}]};
			{opt_bloquee_101,_} ->
			    {redirect,Sess,Uopt_bloquee};
			E ->
			    slog:event(failure,?MODULE,bad_resp_from_sdp,E),
			    {redirect, Sess, Unok}
		    end;
		E ->
		    slog:event(failure,?MODULE,bad_response_from_sdp,E),
		    {redirect, Sess, Unok}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RESTITUTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type must_we_restitute(session(),ListOpt::[atom()]) -> bool().
%%%% Check whether selfcare information on option should be displayed.

must_we_restitute(Session, [Opt|T]) ->
    {Sess,State_} = svc_options:check_topnumlist(Session),
    case do_restitution(Sess, Opt, link, "", "") of
	true->
	    true;
	false ->
	    must_we_restitute(Sess, T)
    end;
must_we_restitute(Sess, []) ->
    false.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_restitution(session(),Opt::atom(),Phase::atom(),
%%                      PCD_URLs::string(),BR::string())->
%%                      [hlink()].
%%%% Depending on the parameter Phase:
%%%% WHEN Phase=link, proposes the restitution link in the main menu
%%%% if one of the options defined in configuration parameter
%%%% restit_options_mobi fulfils the restitution conditions.
%%%% WHEN Phase=restit, displays the page corresponding to the option
%%%% and the status.

do_restitution(S,Opt,Phase,PCD_URLs,BR) 
  when Opt==opt_appelprixunique;
       Opt==opt_seminf;
       Opt==opt_illimite_kdo ->
    State = svc_util_of:get_user_state(S),
    case {svc_options:is_option_activated(S,Opt), Phase} of
	{true, link} -> true;
	{_, link} -> false;
	{true, _} -> 
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	_ -> []  
    end;

do_restitution(Session,Opt,Phase,PCD_URLs,BR)
  when Opt==opt_sms_quoti;
       Opt==opt_sms_mensu;
       Opt==opt_mms_mensu;
       Opt==opt_surf_mensu->
    State = svc_util_of:get_user_state(Session),
    case {credit_and_option_state(Session, Opt), Phase} of
	{opt_nac, link} -> false;
	{_, link} -> true;
	{princ_sec, _} ->
	    [{PCD_PrincSec,URL_PrincSec}, _, _, _]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
  	    [#hlink{href=URL_PrincSec},{pcdata,PCD_PrincSec}]
		++svc_util_of:add_br(BR);
	{princ_no_sec, _} ->
	    [_, {PCD_PrincNoSec,URL_PrincNoSec}, _, _]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_PrincNoSec,contents=[{pcdata,PCD_PrincNoSec}]}]
		++svc_util_of:add_br(BR);
	{no_princ_sec, _} ->
	    [_, _, {PCD_NoPrincSec,URL_NoPrincSec}, _]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_NoPrincSec,contents=[{pcdata,PCD_NoPrincSec}]}]
		++svc_util_of:add_br(BR);
	{no_princ_no_sec, _} ->
	    [_, _, _, {PCD_NoPrincNoSec,URL_NoPrincNoSec}]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_NoPrincNoSec,
		    contents=[{pcdata,PCD_NoPrincNoSec}]}]
		++svc_util_of:add_br(BR);
	_ -> []
    end;

do_restitution(S,Opt,Phase,PCD_URLs,BR) 
  when Opt==opt_pack_noel_mms;
       Opt==opt_pack_voeux_smsmms;
       Opt==opt_vacances;
       Opt==opt_erech_smsmms;
       Opt==opt_voyage;
       Opt==opt_roaming;
       Opt==opt_europe;
       Opt==opt_maghreb;
       Opt==opt_we_sms;
       Opt==opt_ssms;
       Opt==opt_easy_voice;
       Opt==opt_illimite_mobi;
       Opt==opt_ow_3E_mobi;
       Opt==opt_ow_6E_mobi;
       Opt==opt_ow_10E_mobi ->
    case {cpte_and_option_state(S,Opt), Phase} of
	{{cpte_ac,opt_ac}, link} -> true;
	{{cpte_ep,opt_ac}, link} -> true;
	{{cpte_pe,opt_ac}, link} -> true;
	{_, link} -> false;
	{{cpte_ac,opt_ac}, _} ->
	    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
		++svc_util_of:add_br(BR);
	{{cpte_ep,opt_ac}, _} ->
	    [_,{PCD_EP,URL_EP}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]
		++svc_util_of:add_br(BR);
	{{cpte_pe,opt_ac}, _} ->
	    [_,{PCD_EP,URL_EP}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]
		++svc_util_of:add_br(BR);
	_ ->
	    []
    end;

do_restitution(S,Opt,Phase,PCD_URLs,BR) 
  when Opt==opt_afterschool;
       Opt==opt_bp_10_mms ->
    case {cpte_and_option_state(S,Opt), Phase} of
	{{cpte_ac,opt_ac}, link} -> true;
	{{cpte_ep,opt_ac}, link} -> true;
	{_, link} -> false;
	{{cpte_ac,opt_ac}, _} ->
	    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
		++svc_util_of:add_br(BR);
	{{cpte_ep,opt_ac}, _} ->
	    [_,{PCD_EP,URL_EP}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]
		++svc_util_of:add_br(BR);
	_ ->
	    []
    end;

do_restitution(S,Opt,Phase,PCD_URLs,BR)
  when Opt==opt_we_ow;
       Opt==opt_weinf;
       Opt==opt_sinf;
       Opt==opt_jinf;
       Opt==opt_tv;
       Opt==opt_tv_max;
       Opt==opt_internet;
	   Opt==opt_internet_v2_pp;
       Opt==opt_internet_max;
	   Opt==opt_internet_max_pp;
       Opt==opt_internet_max_v3;
       Opt==opt_musique;
       Opt==opt_total_tv;
       Opt==opt_sport;
       Opt==opt_surf;
       Opt==opt_musique;
       Opt==opt_msn_mensu_mobi;
       Opt==winning_50sms;
       Opt==opt_msn_journee_mobi ->
    case {cpte_and_option_state(S,Opt), Phase} of
	{{cpte_ac,opt_ac}, link} -> true;
	{_, link} -> false;
	{{cpte_ac,opt_ac}, _} ->
	    [{PCD_AC,URL_AC}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
		++svc_util_of:add_br(BR);
	_ ->
	    []
    end;

do_restitution(Session,Opt,Phase,PCD_URLs,BR) 
  when Opt==opt_pass_vacances ->
    State = svc_util_of:get_user_state(Session),
    case {svc_options:is_option_activated(Session,Opt), Phase} of
	{true, link} -> true;
	{_, link} -> false;
	{true, _} ->
	    PASS_MOC = svc_options:opt_to_godet(opt_pass_vacances_moc,mobi),
	    PASS_MTC = svc_options:opt_to_godet(opt_pass_vacances_mtc,mobi),
	    case {svc_compte:etat_cpte(State,PASS_MOC),
		  svc_compte:etat_cpte(State,PASS_MTC)} of
		{?CETAT_AC,?CETAT_AC} ->
		    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
			++svc_util_of:add_br(BR);
		{?CETAT_AC,_} ->
		    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
			++svc_util_of:add_br(BR);
		{_,?CETAT_AC} ->
		    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
			++svc_util_of:add_br(BR);
		_ ->
		    [_,{PCD_EP,URL_EP}]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]
			++svc_util_of:add_br(BR)
	    end;
	_ ->
	    []
    end;
do_restitution(Session,Opt,Phase,PCD_URLs,BR) 
  when Opt==opt_pass_vacances_v2;
	   Opt==opt_pass_voyage_6E ->
    State = svc_util_of:get_user_state(Session),
    case {svc_options:is_option_activated(Session,Opt), Phase} of
	{true, link} -> true;
	{_, link} -> false;
	{true, _} ->
	    PASS_MOC = svc_options:opt_to_godet(opt_pass_vacances_v2_moc,mobi),
	    PASS_MTC = svc_options:opt_to_godet(opt_pass_vacances_v2_mtc,mobi),
	    case {svc_compte:etat_cpte(State,PASS_MOC),
		  svc_compte:etat_cpte(State,PASS_MTC)} of
		{?CETAT_AC,?CETAT_AC} ->
		    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
			++svc_util_of:add_br(BR);
		{?CETAT_AC,_} ->
		    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
			++svc_util_of:add_br(BR);
		{_,?CETAT_AC} ->
		    [{PCD_AC,URL_AC}, _]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
			++svc_util_of:add_br(BR);
		_ ->
		    [_,{PCD_EP,URL_EP}]=svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]
			++svc_util_of:add_br(BR)
	    end;
	_ ->
	    []
    end;

do_restitution(Session,Opt,Phase,PCD_URLs,BR) 
  when Opt==opt_tt_shuss;Opt==opt_pack_duo_journee ->
    State = svc_util_of:get_user_state(Session),
    case {svc_options:is_option_activated(Session,Opt), Phase} of
	{true, link} -> true;
	{_, link} -> false;
	{true, _} ->
	    TT_SHUSS_SMS = svc_options:opt_to_godet(opt_tt_shuss_sms,mobi),
	    TT_SHUSS_VOIX = svc_options:opt_to_godet(opt_tt_shuss_voix_2,mobi),
	    case
		{svc_compte:etat_cpte(State,TT_SHUSS_SMS),
		  svc_compte:etat_cpte(State,TT_SHUSS_VOIX)} of
		{?CETAT_AC,?CETAT_AC} ->
		    [{PCD_AA,URL_AA}, _, _, _]=
			svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AA,contents=[{pcdata,PCD_AA}]}]
			++svc_util_of:add_br(BR);
		{?CETAT_AC,_} ->
		    [_, {PCD_AE,URL_AE}, _, _]=
			svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_AE,contents=[{pcdata,PCD_AE}]}]
			++svc_util_of:add_br(BR);
		{_,?CETAT_AC} ->
		    [_, _,{PCD_EA,URL_EA}, _]=
			svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_EA,contents=[{pcdata,PCD_EA}]}]
			++svc_util_of:add_br(BR);
		_ ->
		    [_, _, _,{PCD_EE,URL_EE}]=
			svc_util_of:dec_pcd_urls(PCD_URLs),
		    [#hlink{href=URL_EE,contents=[{pcdata,PCD_EE}]}]
			++svc_util_of:add_br(BR)
	    end;
	_ ->
	    []
    end;

do_restitution(Session,Opt,Phase,PCD_URLs,BR)
  when Opt==opt_numprefp ->
    State = svc_util_of:get_user_state(Session),
    case {svc_compte:cpte(State,svc_options:opt_to_godet(Opt,mobi)), Phase} of
	{#compte{etat=?CETAT_AC}, link} -> true;
	{#compte{etat=?CETAT_EP}, link} -> true;
	{#compte{etat=?CETAT_PE}, link} -> true;
	{_, link} -> false;
	{#compte{etat=?CETAT_AC}, _} ->
	    [{PCD_AC,URL_AC}, _, _]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_AC,contents=[{pcdata,PCD_AC}]}]
		++svc_util_of:add_br(BR);
	{#compte{etat=?CETAT_EP}, _} ->
	    [_,{PCD_EP,URL_EP}, _]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_EP,contents=[{pcdata,PCD_EP}]}]
		++svc_util_of:add_br(BR);
	{#compte{etat=?CETAT_PE}, _} ->
	    [_, _,{PCD_PE,URL_PE}]=
		svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL_PE,contents=[{pcdata,PCD_PE}]}]
		++svc_util_of:add_br(BR);
	_ ->
	    []
    end;

do_restitution(Session,Opt,Phase,PCD_URLs,BR) ->
    slog:event(failure,?MODULE,restit_unknown_option,Opt),
    [].

%%%%PROMO MANAGEMENT

redirect_promo(Session,Opt,UrlGene,UrlPromo)->
    case svc_util_of:is_promotion(Session,mobi,Opt) of
	true->
	    {redirect,Session,UrlPromo};
	_ ->
	    {redirect,Session,UrlGene}
    end.


%%%%refonte MOBI
do_subscription_request(#session{prof=Prof}=Session,Opt,Uok,UdejaAct,Uinsuff,Unok,Uopt_bloquee)
  when Opt==opt_illimite_kdo->
    S = variable:update_value(Session, {?MODULE, option}, Opt),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,subscribe),
    svc_options:redirect_update_option(Session1, Result, Uok, UdejaAct, 
                                       Uinsuff, Uopt_bloquee, Unok).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%refonte mobi%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do_register_request_refo(#session{}=S,Opt,Uok,UnotOF,Unok) 
  when Opt==opt_illimite_kdo;
       Opt==opt_ikdo_vx_sms->
    %%[Uok,UnotOF,Unok] = string:tokens(URLs, ","),
    {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,modify),
    case Result of
	{ok_operation_effectuee,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
	{nok_num_not_Orange,_} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
        {error, "numero_invalid"} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,UnotOF};
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end.


%% +type do_unsubscription_request(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Terminate subscription to options.

do_unsubscription_request(#session{}=S,Opt,Uok,Unok) 
  when Opt==opt_pass_vacances; 
       Opt==opt_pass_vacances_v2; 
       Opt==opt_internet;
	   Opt==opt_internet_v2_pp;
       Opt==opt_internet_v3;
       Opt==opt_internet_max;
	   Opt==opt_internet_max_pp;
       Opt==opt_internet_max_v3;
       Opt==opt_tt_shuss;
       Opt==opt_zap_zone;
	   Opt==opt_pack_ado;
       Opt==opt_ikdo_vx_sms->
    Options = case Opt of
		  opt_pass_vacances ->
		      [opt_pass_vacances_moc,opt_pass_vacances_mtc];
		  opt_pass_vacances_v2 ->
		      [opt_pass_vacances_v2_moc,opt_pass_vacances_v2_mtc,opt_pass_vacances_v2_10_sms];
		  opt_internet ->
		      [opt_internet,opt_internet_bis];
		  opt_internet_v3 ->
		      [opt_internet,opt_internet_v3];
		  opt_internet_max ->
		      [opt_internet_max,opt_internet_max_bis];
		  opt_internet_max_v3 ->
		      [opt_internet_max_v3];
		  opt_tt_shuss ->
		      [opt_tt_shuss_sms,opt_tt_shuss_voix_2];
		  opt_zap_zone->
		      [opt_zap_zone, opt_zap_zone_bis];
		  opt_ikdo_vx_sms ->
		      [opt_illimite_kdo, opt_ikdo_vx_sms];
				  _ ->
					  Opt
	      end,
    NewSession = variable:update_value(S, {?MODULE, option}, Opt),
    {Session1,Result} = case is_list(Options) of 
							true ->
								svc_options:do_nopt_cpt_request(NewSession,Options,terminate,[]);
							_ ->
								svc_options:do_opt_cpt_request(NewSession,Options,terminate)
						end,
    case Result of
	{ok_operation_effectuee,_} ->
	    {_,UpdatedSession}= svc_util_of:reinit_compte(Session1),
	    {redirect,UpdatedSession,Uok};

	{opt_bloquee_101,_} ->
	    Uopt_bloquee=svc_of_plugins:get_url_blocked(Session1),
	    NewSession2 = variable:update_value(Session1, 
						{?MODULE, option}, Opt),
	    {redirect,NewSession2,Uopt_bloquee};

        {error, "option_incompatible_sec"} ->
	    Uopt_bloquee=svc_of_plugins:get_url_blocked(Session1),
	    NewSession2 = variable:update_value(Session1, 
						{?MODULE, option}, Opt),
	    {redirect,NewSession2,Uopt_bloquee};

	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end;

do_unsubscription_request(#session{}=S,Opt,Uok,Unok) ->
    {Session1,Result} = svc_options:do_opt_cpt_request(S,Opt,terminate),
    case Result of
	{ok_operation_effectuee,_} ->
	    {_,UpdatedSession}= svc_util_of:reinit_compte(Session1),
	    {redirect,UpdatedSession,Uok};

	{opt_bloquee_101,_} ->
	    Uopt_bloquee=svc_of_plugins:get_url_blocked(Session1),
	    Session2 = variable:update_value(Session1, {?MODULE, option}, Opt),
	    {redirect,Session2,Uopt_bloquee};

        {error, "option_incompatible_sec"} ->
            Uopt_bloquee=svc_of_plugins:get_url_blocked(Session1),
	    Session2 = variable:update_value(Session1, {?MODULE, option}, Opt),
	    {redirect,Session2,Uopt_bloquee};

	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end.

redirect_if_option_is_activated(Session,Option,Urls)->
    [Url_opt_activ,Url_opt_not_activ] = string:tokens(Urls,","),  
    Opt=list_to_atom(Option),
    case svc_options:is_option_activated(Session,Opt) of
	true ->
	    {redirect,Session,Url_opt_activ};
	false -> 
	    {redirect,Session,Url_opt_not_activ}
    end.

%%print_date_rnv_bonus/3
%%print_date_rnv_bonus(Session,Type) where type="next" or "last"
print_date_rnv_bonus(abs,_)->    
    [{pcdata, "JJ/MM"}];
print_date_rnv_bonus(Session,Type) ->
    {Session1,State_} = svc_options:check_topnumlist(Session),
    Opt_checked = fun(Opt) -> 
			    svc_options:check_option_activated_from_list(Session1,Opt)
		    end,
    Opt_activated = case lists:map(Opt_checked, [opt_bonus_appels,
						 opt_bonus_sms,
						 opt_bonus_internet,
						 opt_bonus_appels_etranger]) of 
			[true,_,_,_]->opt_bonus_appels;
			[_,true,_,_]->opt_bonus_sms;
			[_,_,true,_]->opt_bonus_internet;
			_ -> opt_bonus_appels_etranger
		end,
    Session2 = case Type of
		   X when X=="sans_perso"; X=="sans_perso_day"->Session1;
		   _->get_opt_info(Session1,integer_to_list(svc_options:top_num(Opt_activated,mobi)))
	       end,
    NState = svc_util_of:get_user_state(Session2),
    DateSouscr = NState#sdp_user_state.c_op_opt_date_souscr,
    case (is_list(DateSouscr) andalso DateSouscr/=[]) of 
	true ->
	    {{_,_,RNV_NUM},_} =  svc_util_of:unixtime_to_local_time(list_to_integer(DateSouscr)),
	    {{Y,M,D},_}=erlang:localtime(),
	    Date = case Type of
		       "last"->
			   pbutil:sprintf("%02d/%02d/%02d",date_dernier_rnv(RNV_NUM,{Y rem 1000,M,D}));
		       "next"->
			   pbutil:sprintf("%02d/%02d/%02d",date_prochain_rnv(RNV_NUM,{Y rem 1000,M,D}));
		       "sans_perso_day" ->
			   pbutil:sprintf("%02d", [RNV_NUM]);
		       "avec_perso_day" ->
                           pbutil:sprintf("%02d", [RNV_NUM]);
		       _ ->
			   pbutil:sprintf("%02d/%02d", date_perso_rnv(RNV_NUM,M))
		   end,
	    [{pcdata, lists:flatten(Date)}];

	_ -> 
	    slog:event(failure,?MODULE,rnv_undefined),
	    [{pcdata, "XX/XX"}]
    end.

date_perso_rnv(RNV_NUM,M)->    
    case RNV_NUM < 28 of
	true ->
	    case M < 12 of
		true->
		    [RNV_NUM,M+1];
		_-> 
		    [RNV_NUM,1]
	    end;
	_ ->
	    case M of
		11 ->
		    [1,1];
		12 ->
		    [1,2];
		_ ->
		    [1,M+2]
	    end
    end.

date_dernier_rnv(RNV_NUM,{Y,M,D}) ->  
    case D < RNV_NUM of
	true->
	    case M > 1 of
		true ->
		    [RNV_NUM,M-1,Y];
		_ ->
		    [RNV_NUM,12,Y-1]
	    end;
	_->
	    [RNV_NUM,M,Y]
    end.

date_prochain_rnv(RNV_NUM,{Y,M,D}) ->  
    case D < RNV_NUM of
	true->
	    [RNV_NUM,M,Y];
	_->
	    case M <12 of
		true->
		    [RNV_NUM,M+1,Y];
		_ ->
		    [RNV_NUM,1,Y+1]
	    end
    end.

maj_op(S,Opt) ->
    case Opt of 
	O when O==opt_bonus_europe;O==opt_bonus_maghreb ->
            svc_options:do_nopt_cpt_request(S,[Opt,opt_bonus_appels_etranger],subscribe,[]);
	O when O==opt_bonus_europe_promo;O==opt_bonus_maghreb_promo ->
            svc_options:do_opt_cpt_request(S,opt_bonus_appels_etranger_promo,subscribe),
            svc_options:do_opt_cpt_request(S,Opt,subscribe);
	Options when is_list(Options)==true ->
	    svc_options:do_nopt_cpt_request(S,Options,subscribe,[]);		
        _ ->
            svc_options:do_opt_cpt_request(S,Opt,subscribe)			
    end.
