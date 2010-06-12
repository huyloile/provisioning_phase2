%%%% Self care recharge page generator.

-module(svc_recharge).
-export([is_open/3,is_forbidden/2,process_code/2,process_code/4]).
-export([start_recharge/1,determine_homepage/1]).
-export([recharge_form/1]).
-export([nb_sms/1,print_solde/2,montant_recharge/1,montant_recharge/2,is_lucky_number/2]).
-export([recharge_d6_and_redirect/3,do_recharge_d6/2, send_recharge_request/5]).
-export([send_consult_rech_request/4]).
-export([type_ticket_rech/2, get_ttk/3, get_ett_num/1]).
%% API
-export([recharge_error/2,  recharge_error/9, recharge_error/7]).
-export([slog_info/3]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include_lib("oma/include/slog.hrl").


-define(selfcare_mobi,"/orangef/selfcare_long/selfcare.xml").
-define(new_selfcare_mobi,"/mcel/acceptance/mobi/Home_page_mobi.xml").
-define(TCK_KEY_TYPE, "2").
-define(TTK_RECH_20E, 172).
-define(TTK_RECH_SL_10E, 2).
-define(TTK_RECH_SL_20E, 3).
-define(TTK_RECH_SL_30E, 4).
-define(TTK_20E_messages, 124).
-define(TTK_RECH_5E,106).
-define(TTK_RECH_25E,142).
-define(TTK_20E_musique, 163).
-define(TTK_SL_7E_MessgIllim, 168).
-define(TTK_BZH_MOBI_5E_15J, 176).
-define(TTK_BZH_MOBI_25E_93J, 177).
-define(TTK_RECH_SMS_ILL_5, 5).
-define(TTK_RECH_SMS_ILL_6, 180).
-define(TTK_RECH_SMS_ILL_178, 178).
-define(DEFAULT_CHOICE, 0).
-define(CHOICE_SL_7E_MessgIllim, 3).
-define(CHOICE_20E_messages, 4).
-define(CHOICE_20E_musique, 5).
-define(CHOICE_RECH_SL, 1).


%% +type is_open(session(),string(),string())-> erlpage_result().
is_open(abs,URL_OK,URL_CLOSED)->
    [{redirect,abs,URL_OK},
     {redirect,abs,URL_CLOSED}];
is_open(Session,URL_OK,URL_CLOSED)->
    case svc_util_of:is_commercially_launched(Session,recharge_cg) of
	true->
	    {redirect,Session,URL_OK};
	false->
	    {redirect,Session,URL_CLOSED}
    end.

%% +type is_forbidden(session(),string())-> erlpage_result().
is_forbidden(abs,URL_OK)->
    [{redirect,abs,URL_OK}];
is_forbidden(Session,URL_OK)->
    State =svc_util_of:get_user_state(Session),
    case svc_util_of:is_recharge_forbidden(State) of
	true ->
	    URL_redir =svc_util_of:url_recharge_forbidden(State),
	    {redirect, Session, URL_redir};
	_ -> 
	    {redirect,Session,URL_OK}
    end.

%% +type start_recharge(session())-> erlpage_result().
%%%% Checks state, and creates service data.
%%%% idem start_selfcare, except for state EP
start_recharge(abs) ->
    continue_recharge(abs) ++
	[ {redirect, abs, ?selfcare_mobi++"#temporary"} ];
start_recharge(#session{prof=Profile}=Session) ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session1} ->
	    continue_recharge(Session1);
	{stop, Session1, Reason} ->
	    {redirect, Session1, ?selfcare_mobi++"#temporary"}
    end.

%%%% Read user state in case of direct access, acces via service =/= SV 
%% +type continue_recharge(session())-> erlpage_result().
continue_recharge(abs)->
    filter(abs,"") ++
	[{redirect,abs,"#badprofil"},
	 {redirect,abs,?selfcare_mobi++"#temporary"}];
continue_recharge(#session{prof=#profile{subscription=S}=Profile}=Session) 
    when S=="mobi";S=="virgin_prepaid";S=="carrefour_prepaid";S=="omer";
	 S=="monacell_prepaid";S=="monacell_comptebloqu"->
     case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, State}  ->
	     NewSession=
		 svc_util_of:update_user_state(Session_,State),
	     filter(NewSession,State);
	 Error ->
	     slog:event(failure,?MODULE,error_in_read_sdp_state,Error),
	     {redirect, Session, ?selfcare_mobi++"#temporary"}
     end;
continue_recharge(#session{prof=#profile{subscription=S}}=Session)->
    slog:event(trace, ?MODULE, not_mobi),
    {redirect, Session, "#badprofil"}.


%%%% filter pathological State
%% +type filter(session(),sdp_user_state())-> erlpage_result().
filter(abs,_)->
      svc_home:filter_pathological_mobi(abs,abs) ++
	determine_homepage(abs);
filter(Session,State) ->
    case catch svc_home:filter_pathological_mobi(Session,State) of
	{continue, Session1} ->
	    determine_homepage(Session1);
	{redirect, Session1, URL}=Redirect ->	    Redirect;
	{redirect, Session1, URL, Subst}=Redirect ->
	    Redirect
    end.


%%%% determine first page
%% +type determine_homepage(session())-> erlpage_result(). 
determine_homepage(abs) ->
    [ {redirect, abs, "/orangef/selfcare_long/recharge.xml#start_plug"}
     ]++recharge_form(abs);
determine_homepage(Session)->
    State = svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,cpte_princ) of
	#compte{ptf_num=?MADRID2}->
	    {redirect, Session,"/orangef/selfcare_long/recharge.xml#start_plug"};
	#compte{ptf_num=?PLUG_NOEL}->
	    {redirect, Session,"/orangef/selfcare_long/recharge.xml#start_plug"};
	_->
	    recharge_form(Session)
    end.

%%%% Swith to Formulary Phase1 and Phase 2
%% +type recharge_form(session())-> erlpage_result().
recharge_form(abs) ->
    [   {redirect, abs, "#ussd1cag"},
	{redirect, abs, "#cag"}
     ];
recharge_form(#session{bearer={ussd,1}}=Session) ->
    {redirect, Session, "#ussd1cag"};
recharge_form(#session{}=Session)->
     {redirect, Session, "#cag"}.

%%%% verify CG code and after do recharge
%% +type process_code(session(),string())-> erlpage_result().
process_code(abs, _) ->
    do_recharge(abs, abs) ++
    [ {"MENU SV", 
       {redirect,abs,?selfcare_mobi++"#mainmenu"}},
      {redirect, abs, "#bad_code_ph1"},
      {redirect, abs, "#bad_code_ph2"}
     ];
process_code(#session{service_code=SC,prof=#profile{subscription="mobi"}}=Session,"00") 
  when SC=="#124";SC=="#144";SC=="#147";SC=="#123"->
    {redirect, Session,?selfcare_mobi++"#mainmenu"};
process_code(#session{service_code="#123",prof=#profile{subscription="mobi"}}=Session,"8") ->
    {redirect, Session,"/mcel/acceptance/mobi/recharge/menu.xml"};
process_code(#session{service_code="#123",prof=#profile{subscription="mobi"}}=Session,"9") ->
    {redirect, Session,?new_selfcare_mobi++"#sachem_consultation"};
process_code(#session{service_code=SC,prof=#profile{subscription="omer"}}=Session,"00") 
  when SC=="#124";SC=="#144";SC=="#147";SC=="#123"->
    {redirect, Session,"/orangef/selfcare_long/selfcare_omer.xml#mainmenu"};
process_code(#session{service_code=SC,prof=#profile{subscription="carrefour_prepaid"}}=Session,"00")
  when SC=="#124";SC=="#144";SC=="*144";SC=="#147";SC=="#123"->
    {redirect, Session,"/orangef/carrefour/selfcare_carrefour_pp.xml"};
process_code(#session{service_code=SC,prof=#profile{subscription="carrefour_prepaid"}}=Session,"0")
  when SC=="#124";SC=="#144";SC=="*144";SC=="#147";SC=="#123"->
    {redirect, Session,"/orangef/carrefour/selfcare_carrefour_pp.xml"};
process_code(#session{service_code=SC,prof=#profile{subscription=Subscription}}=Session,CG)
  when Subscription=="mobi" ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_recharge_autorized(State) of
        true ->
	    case svc_util_of:is_valid(CG) of
		{nok, _} ->
		    case Session#session.bearer=={ussd,1} of
			true->{redirect, Session, "#bad_code_ph1"};
			false->
			    State =svc_util_of:get_user_state(Session),
			    Recharge = State#sdp_user_state.tmp_recharge,
			    case is_record(Recharge, recharge) of
				true ->
				    Nb_tentative=Recharge#recharge.tentative,
				    case Nb_tentative of
					2 ->
					    {redirect, Session, "#bad_code_2_ph2"};
					_ ->
					    NewRecharge = Recharge#recharge{tentative=Nb_tentative+1},
					    NewState = State#sdp_user_state{tmp_recharge=NewRecharge},
					    NewSession = svc_util_of:update_user_state(Session,NewState),
					    {redirect, Session, "#bad_code_ph2"}
				    end;
				_ ->
				    NewRecharge = #recharge{tentative=1},
				    NewState = State#sdp_user_state{tmp_recharge=NewRecharge},
				    NewSession = svc_util_of:update_user_state(Session,NewState),
				    {redirect, NewSession, "#bad_code_ph2"}
			    end
		    end;
		{ok, Code}  ->
		    do_recharge(Session,Code)
	    end;
        _ ->
	    {redirect, Session, "#error_not_allowed"}
    end;
process_code(#session{service_code=SC,prof=#profile{subscription=Subscription}}=Session,CG)->
    case svc_util_of:is_valid(CG) of
        {nok, _} ->
            case Session#session.bearer=={ussd,1} of
                true->{redirect, Session, "#bad_code_ph1"};
                false->
                    State =svc_util_of:get_user_state(Session),
                    Recharge = State#sdp_user_state.tmp_recharge,
                    case is_record(Recharge, recharge) of
                        true ->
                            Nb_tentative=Recharge#recharge.tentative,
                            case Nb_tentative of
                                1 -> {redirect, Session, "#bad_code_2_ph2"};
                                _ ->
                                    NewRecharge = Recharge#recharge{tentative=1},
                                    NewState = State#sdp_user_state{tmp_recharge=NewRecharge},
                                    NewSession = svc_util_of:update_user_state(Session,NewState),
                                    {redirect, Session, "#bad_code_ph2"}
                            end;
                        _ ->
                            NewRecharge = #recharge{tentative=1},
                            NewState = State#sdp_user_state{tmp_recharge=NewRecharge},
                            NewSession = svc_util_of:update_user_state(Session,NewState),
                            {redirect, NewSession, "#bad_code_ph2"}
                    end
            end;
        {ok, Code}  ->
            do_recharge(Session,Code)
    end.

process_code(#session{prof=#profile{subscription=Subscription}}=Session, Url_back, Url_menu, CG)->
    case CG of 
	"0" -> 
	    {redirect, Session, Url_back};
	"00" ->
	    {redirect, Session, Url_menu};
	_ ->
	    case svc_util_of:is_valid(CG) of
		{nok, _} ->
		    case Session#session.bearer=={ussd,1} of
			true->{redirect, Session, "#bad_code_ph1"};
			false->
			    State =svc_util_of:get_user_state(Session),
			    Recharge = State#sdp_user_state.tmp_recharge,
			    case Recharge of
				undefined ->
				    NewRecharge = #recharge{tentative=1},
				    NewState = State#sdp_user_state{tmp_recharge=NewRecharge},
				    NewSession = svc_util_of:update_user_state(Session,NewState),
				    {redirect, NewSession, "#bad_code_ph2"};
				_ ->
				    Nb_tentative=Recharge#recharge.tentative,
				    case Nb_tentative of
					1 -> {redirect, Session, "#bad_code_2_ph2"};
					_ ->
					    NewRecharge = Recharge#recharge{tentative=1},
					    NewState = State#sdp_user_state{tmp_recharge=NewRecharge},
					    NewSession = svc_util_of:update_user_state(Session,NewState),
					    {redirect, Session, "#bad_code_ph2"}
				    end
		    end
		    end;
		{ok, Code}  ->
		    do_recharge(Session,Code)
	    end
    end.

%%%% Do request of Rechargement
%% +type do_recharge(session(),string())-> erlpage_result().
do_recharge(abs,Code)->
    success_page(abs,"")++recharge_error(abs,"");
do_recharge(#session{prof=Profile}=Session,Code)->
    Service_code = Session#session.service_code,
    Msisdn = Profile#profile.msisdn,
    State =svc_util_of:get_user_state(Session),
    State2 =State#sdp_user_state{tmp_code=Code},
    Session2 = svc_util_of:update_user_state(Session,State2),   
    case send_consult_rech_request(Session2, {mobi,Msisdn}, ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    STATUS = proplists:get_value("STATUT",Answer_tck),
	    slog:event(trace,?MODULE,status,STATUS),
	    if (STATUS=/=undefined) -> 
		    case list_to_integer(STATUS) of
			0 -> 
			    slog:event(trace,?MODULE,status,STATUS),
			    case get_ett_num(Answer_tck) of 
				undefined -> 
                                    {redirect, Session, "#system_failure"};
				ETT_NUM when ETT_NUM==3;ETT_NUM==5;ETT_NUM==6;ETT_NUM==7;ETT_NUM==8 -> 
				    {redirect, Session, "#bad_code_56"};
				4 -> 
				    {redirect, Session, "#ticket_deja_utilise"};
				_ ->
				    case get_ttk(Session, c_tck, Answer_tck) of
					?TTK_20E_messages ->
					    slog:event(trace, ?MODULE, ticket_rech_20E_messages),
					    recharge_d6_and_redirect(Session2,?CHOICE_20E_messages,
								     "#sucess_cpte");
					?TTK_20E_musique ->
					    slog:event(trace, ?MODULE, ticket_20E_musique),
					    recharge_d6_and_redirect(Session2,?CHOICE_20E_musique,
								     "#sucess_cpte");
					?TTK_SL_7E_MessgIllim ->
					    slog:event(trace, ?MODULE, ticket_SL_7E_MessgIllim),
					    recharge_d6_and_redirect(Session2,?CHOICE_SL_7E_MessgIllim,
								     "#sucess_cpte");
					?TTK_RECH_SL_10E ->
					    case svc_util_of:is_commercially_launched(Session,recharge_sl_mobi) of
						true ->
						    slog:event(trace, ?MODULE, ticket_SL_10E),
						    recharge_d6_and_redirect(Session2,?CHOICE_RECH_SL,"#rech_SL_10E");
						_ ->
						    recharge_d6_and_redirect(Session2,?DEFAULT_CHOICE,"#sucess_cpte")
					    end;
					?TTK_RECH_SL_20E ->
					    case svc_util_of:is_commercially_launched(Session,recharge_sl_mobi) of
						true ->
						    slog:event(trace, ?MODULE, ticket_SL_20E),
						    recharge_d6_and_redirect(Session2,?CHOICE_RECH_SL,"#rech_SL_20E");
						_ ->
						    recharge_d6_and_redirect(Session2,?DEFAULT_CHOICE,"#sucess_cpte")
					    end;
					?TTK_RECH_SL_30E ->
					    case svc_util_of:is_commercially_launched(Session,recharge_sl_mobi) of
						true ->
						    slog:event(trace, ?MODULE, ticket_SL_30E),
						    recharge_d6_and_redirect(Session2,?CHOICE_RECH_SL,"#rech_SL_30E");
						_ ->
						    recharge_d6_and_redirect(Session2,?DEFAULT_CHOICE,"#sucess_cpte")
					    end;
					TTK_RECH_SMS_IIL when
					TTK_RECH_SMS_IIL == ?TTK_RECH_SMS_ILL_5;
					TTK_RECH_SMS_IIL == ?TTK_RECH_SMS_ILL_6;
					TTK_RECH_SMS_IIL == ?TTK_RECH_SMS_ILL_178->
					    recharge_d6_and_redirect(Session2, ?DEFAULT_CHOICE, "#sucess_rech_sms_ill");
					Else ->
					    Choice = ?DEFAULT_CHOICE,
					    case do_recharge_d6(Session2, Choice) of
						{ok, Session_new, Answer_d6} ->
						    case Service_code of
							"#124" ->
							    [];
							_ ->
							    prisme_dump:prisme_count_v1(Session,"PRECTR")
						    end,
						    success_page(Session_new, Answer_d6);
						{error, Error} ->
						    slog:event(warning, ?MODULE, do_recharge_d6_error, Error),
						    recharge_error(Session,Error);
						Error ->
						    slog:event(failure, ?MODULE, do_recharge_d6, Error),
						    {redirect, Session, "#system_failure"}
					    end
				    end
				end;
			_ ->
			    {redirect, Session, "#system_failure"}
		    end;
	       true ->
		    {redirect, Session, "#system_failure"}
	    end;
	Else ->
 	    {redirect, Session2, "#system_failure"}
    end.

%%%% Do request of Rechargement with D6 and redirect to #page
%% +type recharge_d6_and_redirect(session(),string(), string())-> erlpage_result().
recharge_d6_and_redirect(Session, Choice, Redirection) ->
    Service_code = Session#session.service_code,
    State= svc_util_of:get_user_state(Session),
    case do_recharge_d6(Session, Choice) of
	{ok, Session_new, Answer} ->
            case get_ttk(Session, d6, Answer) of
		Ticket when Ticket==?TTK_RECH_20E; Ticket==?TTK_20E_messages;Ticket==?TTK_20E_musique;
			    Ticket==?TTK_SL_7E_MessgIllim;Ticket==?TTK_RECH_5E; Ticket==?TTK_RECH_25E;
		            Ticket==?TTK_BZH_MOBI_5E_15J; Ticket==?TTK_BZH_MOBI_25E_93J;
			    Ticket==?TTK_RECH_SMS_ILL_5;Ticket==?TTK_RECH_SMS_ILL_6;Ticket==?TTK_RECH_SMS_ILL_178;
                            Ticket==?TTK_RECH_SL_10E; Ticket==?TTK_RECH_SL_20E; Ticket==?TTK_RECH_SL_30E ->
		    case Service_code of
			"#124" ->
			    [];
			_ ->
			    prisme_dump:prisme_count_v1(Session,"PRECTRSL")
                    end,
		    {redirect,Session_new, Redirection};
		{error, Error} ->
 		    {redirect,Session, "#system_failure"};
		Else ->
		    slog:event(warning, ?MODULE, unexpected_rech_ticket_type, Else),
		    {redirect,Session, "#system_failure"}
	    end;
	{error, Error} ->
	    slog:event(warning, ?MODULE, do_recharge_d6_error, Error),
	    recharge_error(Session,Error)
    end.

%%%% Do request of Rechargement
%% +type do_recharge_d6(session(),string())-> tuple().
do_recharge_d6(Session, Choice) ->
    Choice1 = if list(Choice) -> list_to_integer(Choice);
		 true -> Choice
	      end,
    Profile = Session#session.prof,
    Msisdn = Profile#profile.msisdn,
    State =svc_util_of:get_user_state(Session),
    Code = State#sdp_user_state.tmp_code,
    send_recharge_request(Session, {mobi,Msisdn}, Code, 
                                      pbutil:unixtime(),Choice1).

%% +type send_recharge_request(session(),{atom(),msisdn()},
%%                             string(), string(), string())->
%%                             {ok, tuple()|list()}.
%%%% Send recharge request
%%%% We should deal error codes here
send_recharge_request(Session, {Sub,Msisdn}, Code,
    Date,Default_choice) ->
    case svc_sachem:recharge_ticket(Session, Code, Default_choice) of
        {ok, {Session_new, Resp_params}} ->
            {ok, Session_new, Resp_params};
        {nok, {error, Status}} ->
            slog:event(trace, ?MODULE, bad_resp_status_from_sachem,
                [recharge_ticket,
                    {nok, {error, Status}},
                    Msisdn]),
            {error, Status};
        {nok, Error} ->
            slog:event(trace, ?MODULE, bad_response_from_sachem,
                [recharge_ticket,
                    {nok, Error},
                    Msisdn]),
            {error, Error};
        Error ->
            slog:event(failure, ?MODULE,bad_response_from_sachem,
                [recharge_ticket,Error,Msisdn]),
            {error, Error}
    end.

%% +type send_consult_rech_request(session(),{atom(),msisdn()},
%%                             string(), string(), string())-> tuple().
%%                             tuple()
%%%% Send consult recharge request
send_consult_rech_request(Session, {Sub,Msisdn}, TCK, Code) ->
    case svc_sachem:consult_recharge_ticket(Session, Code) of
        {ok, {Session_new, Resp_params}} ->
            {ok, Resp_params};
        Error ->
            slog:event(failure, ?MODULE,bad_response_from_sachem,
                [consult_recharge_ticket,Error,Msisdn]),
            Error
    end.

%% +type get_ttk(session(), atom(),string()) -> 
%%              tuple().
%%%% Get Type of Ticket de rechargement 
%%%% of from REC_TCK or CSL_TCK Soap_tuxedo
get_ttk(Session, Type, Answer) ->
    case proplists:get_value("TTK_NUM", Answer) of
        undefined ->	    
            {error, unexpected_answer};
        TTK_NUM ->
            list_to_integer(TTK_NUM)
    end.

get_ett_num(CSL_TCK) ->
    case proplists:get_value("ETT_NUM",CSL_TCK) of 
	undefined ->    
            undefined;
	ETT_NUM  -> 
	    list_to_integer(ETT_NUM)
    end.

%%%% Get Type of Ticket de rechargement from c_tck and d6 answers
%% +type type_ticket_rech(atom(),string())-> tuple().
type_ticket_rech(Req_id, Answer) when Req_id == c_tck ->
    case Answer of 
	[C_TCKVALEUR_CLE, TTK_NUM | Rest ] ->
	    TTK_NUM;
	Else ->
	    slog:event(internal, ?MODULE, unexpected_format_c_tck, Answer),
	    {error, Else}
    end;
type_ticket_rech(Req_id, Answer) when Req_id == d6 ->
    case Answer of 
	[DLV, TTK_NUM | Rest ] ->
	    TTK_NUM;
	Else ->
	    slog:event(internal, ?MODULE, unexpected_format_d6, Answer),
	    {error, Else}
    end.


%%%% Redirection according to error codes
%% +type recharge_error(session(), tuple(),
%%                      string(), string(), 
%%                      string(), string(), string())
%%                      -> erlpage_result().
%%%% 10   -97 Default
%%%% 10 1  -  Incompatible
%%%% 10 2  -  Promo
%%%% 10 3  -  Incompatible
%%%% 10 4 -62 Bad_code
%%%% 10 5 -62 Bad_code
%%%% 10 6 -55 Bad_code
%%%% 10 7 -56 Bad_code
%%%% 10 8 -62 Bad_code
%%%% 10 9 -57 Promo
%%%% 11   -98 Default
%%%% 12   -98 Default
%%%% 14   -86 Incompatible
%%%% 15   -87 Incompatible
%%%% 98       Bad_code
%%%% 99   -99 System_errror
%%%% 99 3 -63 Incompatible_Offre

%%recharge_error/9
recharge_error(#session{prof=Profile}=Session, Error, 
               Default, System_error, Bad_code_55,Bad_code_56,
               Incompatible, Incompatible_Offre, Promo) ->
    Msisdn = Profile#profile.msisdn,
    slog:event(trace, ?MODULE, recharge_error, Error),
    case Error of 
	Status when Status=={status, [10,1]};
                    Status=={status, [10,3]};
                    Status=={status, [14]};
                    Status=={status, [15]};
                    Status=="erreur_options";
                    Status=="erreur_promo" ->                    
	    slog:event(service_ko, ?MODULE, recharge_error_incompatible, 
                       {Status, Msisdn}),
	    {redirect, Session, Incompatible};
         Status when Status=={status, [99,3]};
		     Status=="incompatible_offre"->
            slog:event(service_ko, ?MODULE, recharge_error_incompat_3, 
                       {Status, Msisdn}),
            {redirect, Session, Incompatible_Offre};                     
	Status when Status=={status, [10,2]};
                    Status=={status, [10,9]};
                    Status=="carte_perimee_tr_promo" ->                    
	    slog:event(service_ko, ?MODULE, recharge_error_promo, 
                       {Status,Msisdn}),
	    {redirect, Session, Promo};
	Status when Status=={status, [10,6]};
		    Status=="dossier_inaccessible";
		    Status=="ticket_recharge_inconnu" -> 
	    {redirect, Session, Bad_code_55};
	Status when Status=={status, [10,7]};
		    Status=="ticket_recharge_invalide" ->
	    {redirect, Session, Bad_code_56};
	Status when Status=={status, [10]};
                    Status=={status, [11]};
                    Status=={status, [12]};
		    Status=={status, [98]};
                    Status=="dossier_inconnu";
                    Status=="format_requete_incorrect" ->
	    slog:event(warning, ?MODULE, recharge_error_default, 
                       {Status, Msisdn}),
	    {redirect, Session, Default};
	Status when Status=={status, [99]};
		    Status=={status, [10,4]};
                    Status=={status, [10,5]};
		    Status=={status, [10,8]};
		    Status=="autres_erreurs_recharge";
                    Status=="incident_technique" ->
	    slog:event(failure, ?MODULE, recharge_error, 
                       {Status, Msisdn}),
	    {redirect, Session, System_error};
	Else ->	    
	    slog:event(failure, ?MODULE, recharge_error_unknown, {Else, Msisdn}),
	    {redirect, Session, System_error}
    end.


recharge_error(Session, Error, Default, System_error, 
               Bad_code, Incompatible, Promo) ->
    recharge_error(Session, 
                   Error, Default, System_error, Bad_code, 
                   Bad_code, Incompatible, Default, Promo).

recharge_error(Session,Error)->
    Subs = svc_util_of:get_souscription(Session),
    case Subs of 
	mobi -> 
	    recharge_error(Session, Error, "#badprofil", "#system_failure", 
               "#bad_code_55", "#bad_code_56", "#incompatible", "#incompatible_offre", "#promo");
	_Sub when _Sub==virgin_comptebloque;
		  _Sub==tele2_pp;
		  _Sub==tele2_comptebloque-> 
	    recharge_error(Session, Error, "#badprofil", "#system_failure", 
			   "#bad_code", "#bad_code", "#incompatible", "#system_failure", "#promo");
	_ ->
	    recharge_error(Session, Error, "#badprofil", "#system_failure", 
			   "#bad_code", "#bad_code", "#incompatible", "#incompatible_offre", "#promo")
    end.

%%%% Removed "#already_used" because obsolete with new Sachem
%% 	{status, [10,5]} ->
%% 	    #session{prof=#profile{subscription=S}=Profile}=Session,
%% 	    slog:event(service_ko, ?MODULE,response_error_10_5),
%% 	    case S of
%% 		"carrefour_prepaid" -> {redirect, Session, "#already_used"};
%% 		_ -> {redirect, Session, "#bad_code"}
%% 	    end;


%%%%%%%%%%%%%%%%% VERSION WITH REQUEST D4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type success_page(session(),string())-> erlpage_result().
success_page(abs,"")->
    [{redirect,abs,"#sucess_cpte"},
     {redirect,abs,"#sucess_sms"},
     {redirect,abs,"#sucess_cpte_sms"},
     {redirect,abs,"#succes_erech_smsmms"},
     {redirect,abs,"#sucess_promo_sms"},
     {redirect,abs,"#sucess_cpte_promo_sms"},
     {redirect,abs,"#recharge_limite_7"},
     {redirect,abs,"#success_vacances"}
    ]++
	do_souscription(abs,opt_weinf)++
	do_souscription(abs,opt_europe)++
	do_souscription(abs,opt_maghreb);
success_page(#session{prof=Prof}=Session, Req_answer) ->
    %% MAJ sdp_user_state
    State = svc_util_of:get_user_state(Session),
    Comptes = svc_util_of:get_param_value("CPT_PARAMS", Req_answer),
    CTK_NUM = svc_util_of:get_param_value("CTK_NUM", Req_answer),
    DLV = svc_util_of:get_param_value("DOS_DATE_LV", Req_answer),
    State3 =State#sdp_user_state{dlv=list_to_integer(DLV)},
    % Recup TCP_NUM of Cpte Recharged to redirect
    TCPs = lists:sort(lists:map(fun([TCP_NUM|T])-> 
                                        list_to_integer(TCP_NUM) 
                                end, 
                                Comptes)),
    Session2=svc_util_of:update_user_state(Session,State3),
    send_success_page(Session2, TCPs, CTK_NUM).

send_success_page(#session{prof=Prof}=Session2, TCPs, CTK_NUM) ->
    case {TCPs,list_to_integer(CTK_NUM),Prof#profile.subscription} of
	{_,?RECHARGE_JINF,"mobi"}->
	    do_souscription(Session2,opt_erech_jinf);
	{_,?RECHARGE_SMSMMS,"mobi"}->
	    {redirect,Session2,"#succes_erech_smsmms"};
	{_,?RECH_LIMITE_NOEL,"mobi"}->
	    slog:event(failure, ?MODULE, old_offer_not_supported, recharge_limite_noel),
	    {redirect,Session2,"#system_failure"};
	{_,?RECHARGE_SL,"mobi"}->
	    do_souscription(Session2,opt_surf_unlimit);
	{_,?CTK_CARREFOUR_Z1,_}->
	    {redirect,Session2,"#sucess_cpte_z1"};
	{_,?CTK_CARREFOUR_Z2,_}->
	    {redirect,Session2,"#sucess_cpte_z2"};
	{_,?CTK_CARREFOUR_Z3,_}->
	    {redirect,Session2,"#sucess_cpte_z3"};
	{_,?RECHARGE_VACANCES,_}->
	    {redirect,Session2,"#success_vacances"};
%% 	{[?C_RECH_SMS_ILLM],_,_}->
%% 	    {redirect,Session2,"#sucess_rech_sms_ill"};
	{[?C_PRINC],_,_}->
	    {redirect,Session2,"#sucess_cpte"};
	{[?C_SMS],_,_}->
	    {redirect,Session2,"#sucess_sms"};
	{X,_,_} when X==[?C_PRINC,?C_SMS];X==[?C_SMS,?C_PRINC]->
	    {redirect,Session2,"#sucess_cpte_sms"};
	{[?C_SMS_NOEL],_,_}->
	    {redirect,Session2,"#sucess_promo_sms"};
	{[?C_PRINC,?C_SMS_NOEL],_,_}->
	    {redirect,Session2,"#sucess_cpte_promo_sms"};
	{A,_,_}->
	    %% By Default return Only cpte Princ 
	    slog:event(warning,?MODULE,unknown_recharge_type,A),
	    {redirect,Session2,"#sucess_cpte"}
    end.

%% +type do_souscription(session(),Opt::atom())-> erlpage_result().
do_souscription(abs,opt_erech_jinf)->
    [{redirect,abs,"#succes_jinf_avec_souscription"},
     {redirect,abs,"#succes_jinf_sans_souscription"}];
do_souscription(abs,opt_weinf)->
    [{redirect,abs,"#weinf_deja_actif"},
     {redirect,abs,"#succes_weinf"},
     {redirect,abs,"#succes_weinf_ss_souscription"}];
do_souscription(abs,opt_europe)->
    [{redirect,abs,"#europe_deja_actif"},
     {redirect,abs,"#maghreb_deja_actif"},
     {redirect,abs,"#succes_europe"},
     {redirect,abs,"#succes_europe_ss_souscription"}];
do_souscription(abs,opt_maghreb)->
    [{redirect,abs,"#europe_deja_actif"},
     {redirect,abs,"#maghreb_deja_actif"},
     {redirect,abs,"#succes_maghreb"},
     {redirect,abs,"#succes_maghreb_ss_souscription"}];
do_souscription(abs,opt_surf_unlimit)->
    [{redirect,abs,"#recharge_limite_7"}];

do_souscription(Session,opt_erech_jinf)->
    %Si la l'option journee infinie standard est activee, on la desactive
    %On active l'option journee infinie version erecharge
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_jinf) of
	true->
	    svc_options_mobi:do_unsubscription(Session_new,"opt_jinf");
	false->
	    ok
    end,
    svc_options_mobi:do_subscription(Session_new,"opt_erech_jinf",
				     "#succes_jinf_avec_souscription,#succes_jinf_sans_souscription");
 
do_souscription(Session,opt_weinf)->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_weinf) of
	true->
	    {redirect,Session_new,"#weinf_deja_actif"};
	false->
            {Session2,Result} = svc_options:do_opt_cpt_request(Session_new,
                                                    opt_weinf,
                                                    subscribe),
            svc_options:redirect_update_option(Session2, Result,
                                               "#succes_weinf", 
                                               "#weinf_deja_actif", 
                                               "#succes_weinf_ss_souscription",
                                               "#succes_weinf_ss_souscription",
                                               "#succes_weinf_ss_souscription")
    end;
do_souscription(Session,opt_europe) ->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_europe) of
	true -> 
	    {redirect,Session_new,
	     "#europe_deja_actif"};
	false ->
	    case svc_options_mobi:is_option_incomp(Session_new,opt_europe) of
		true ->
		    {redirect,Session_new,
		     "#maghreb_deja_actif"};
		false->
                    {Session2,Result} = svc_options:do_opt_cpt_request(Session_new, 
                                                            opt_europe,subscribe),
                    svc_options:redirect_update_option(Session2, Result, 
                                                       "#succes_europe", 
                                                       "#europe_deja_actif",
                                                       "#succes_europe_ss_souscription",
                                                       "#succes_europe_ss_souscription",
                                                       "#succes_europe_ss_souscription")              
	    end
     end;
do_souscription(Session,opt_maghreb) ->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_maghreb) of
	true -> 
	    {redirect,Session_new, "#maghreb_deja_actif"};
	false ->
	    case svc_options_mobi:is_option_incomp(Session_new,opt_maghreb) of
		true -> 
		    {redirect,Session_new,
		     "#europe_deja_actif"};
		false->
                    {Session2,Result} = svc_options:do_opt_cpt_request(Session_new,
                                                           opt_maghreb,
                                                           subscribe),
                    svc_options:redirect_update_option(Session2, Result, 
                                                       "#succes_maghreb", 
                                                       "#maghreb_deja_actif", 
                                                       "#succes_maghreb_ss_souscription",
                                                       "#succes_maghreb_ss_souscription",
                                                       "#succes_maghreb_ss_souscription")
	    end
     end;
do_souscription(Session,opt_surf_unlimit)->
    {Session_new,State_} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_surf_unlimit) of
	true->
	    slog:event(warning, ?MODULE, do_souscription, 
		       opt_surf_unlimit_deja_activee),
	    {redirect,Session_new,"#recharge_limite_7"};
	false->
            {Session2,Result} = svc_options:do_opt_cpt_request(Session_new,
                                                    opt_surf_unlimit,
                                                    subscribe),
            svc_options:redirect_update_option(Session2, Result, 
                                               "#recharge_limite_7", 
                                               "#recharge_limite_7", 
                                               "#temporary",
                                               "#temporary",
                                               "#temporary")
    end.

%% Refill GAME
%% +type is_lucky_number(session(),string())-> erlpage_result().
is_lucky_number(abs,LN)->
    svc_recharge_cb_mobi:is_lucky_number(abs,LN);
is_lucky_number(Session, Lucky_number)->
    svc_recharge_cb_mobi:is_lucky_number(Session,Lucky_number).


%%%%%%%%%%%% include functions CAN BE USED IN XML PAGE %%%%%%%%%%%%%%%%%%%
%% +type nb_sms(session()) -> [{pcdata,string()}].
nb_sms(abs) -> [ {pcdata, "999"} ];
nb_sms(Session)->
    State = svc_util_of:get_user_state(Session),
    Nb_SMS= (State#sdp_user_state.tmp_recharge)#recharge.nb_sms,
    CRNbSMS = integer_to_list(Nb_SMS),
    [{pcdata, CRNbSMS}].

%% +type print_solde(session())-> [{pcdata,string()}].
print_solde(abs, _) -> [ {pcdata, "99"} ];
print_solde(Session,Cpte) -> 
    State = svc_util_of:get_user_state(Session),
    Montant= (State#sdp_user_state.tmp_recharge)#recharge.montant,
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
        #compte{cpp_solde=SOLDE,mnt_bonus=BONUS}=Compte->
            Rech25 = currency:sum(euro, 25), 
            case currency:is_infeq(Rech25, Montant) of 
                true -> 
                    [{pcdata,lists:flatten(currency:print(currency:to_euro(currency:sub(Montant,BONUS))))++"E + "++
                             lists:flatten(currency:print(currency:to_euro(BONUS)))++"E offerts"}];
                false -> 
                    [{pcdata,lists:flatten(currency:print(currency:to_euro(Montant)))++"E"}]
            end;
        undefined ->
            slog:event(internal,?MODULE,undefined_print_solde,Cpte),
            [{pcdata,"inconnu"}];
        _ ->
            slog:event(failure,?MODULE,unknown_cpte,Cpte),
            [{pcdata,"inconnu"}]
    end.
%% +type montant_recharge(session())-> [{pcdata,string()}].
montant_recharge(abs) -> [ {pcdata, "99"} ];
montant_recharge(Session)->
    State = svc_util_of:get_user_state(Session),
    Montant= (State#sdp_user_state.tmp_recharge)#recharge.montant,
    [{pcdata, currency:print(Montant)}].

%% +type montant_recharge(session(),string())-> [{pcdata,string()}].
montant_recharge(abs,_) -> [ {pcdata, "99"} ];
montant_recharge(Session,"xx")->
    State = svc_util_of:get_user_state(Session),
    Montant= (State#sdp_user_state.tmp_recharge)#recharge.montant,
    Mt = trunc(currency:round_value(Montant)),
    [{pcdata, integer_to_list(Mt)}].

slog_info(service_ko,?MODULE,recharge_error_code) ->
        #slog_info{descr="Bad code used to recharge",
               operational="Check whether the code used to recharge is in right format and valid."}.
    
