-module(svc_option_manager).

-export([get_top_num/2,
	 get_ptf_num/2,
	 get_tcp_num/2,
	 get_list_SO/2,
	 get_dlv_opt/2,
	 get_commercial_name/2,
	 get_commercial_dates/2,
	 get_open_hour/2,
	 get_open_day/2,
	 get_list_incompatible_opts/2,
	 is_compatible/2,
	 is_possible_subscription/2,
	 is_possible_unsubscription/2,
	 is_possible_reactivation/2,
	 is_subscribed/2,
	 state/2,
	 get_kenobi_code/2,
	 get_SO_code_by_type/3,
	 get_opt_by_SO_code/3,
	 get_list_opts_activated/2,
	 do_opt_cpt_request/3,
	 do_nopt_cpt_request/4,
	 is_commercially_launched/2,
	 is_good_plage_horaire/2,
	 get_commercial_start_date/3,
	 get_commercial_end_date/3
	 ]).

-include("../include/ftmtlv.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/include/sdp.hrl").


get_top_num(Opt,Sub) ->
    option_manager:get_orange_id({Opt,Sub},top_num).

get_ptf_num(Opt,Sub) ->
    option_manager:get_orange_id({Opt,Sub},ptf_num).

get_tcp_num(Opt,Sub) -> 
    option_manager:get_orange_id({Opt,Sub},tcp_num).

get_mnt_initial(Opt,Sub) ->
    option_manager:get_opt_param({Opt,Sub},mnt_initial).

get_dlv_opt(Opt,Sub) ->    
    option_manager:get_opt_param({Opt,Sub},date_fin).

get_list_SO(Opt,Sub)->
    option_manager:get_orange_id({Opt,Sub,asmetier}).

get_SO_code_by_type(Opt,Sub,Type)->
    SO_code=option_manager:get_orange_id({Opt,Sub,asmetier,Type}),
    case SO_code of
	Error when Error == not_found;
		   Error == closed;
		   Error == []->
	    Config_param_name=case Sub of
				  cmo->
				      asmetier_opt_cmo;
				  postpaid->
				      asmetier_opt_postpaid;
				  _->
				      slog:event(warning, ?MODULE, subscription_not_supported, Sub),
				      asmetier_opt_postpaid
			      end,
	    case svc_of_plugins:search_subscr_code_opt(Opt,pbutil:get_env(pservices_orangef, Config_param_name)) of
                {ok,Code}->
                    [Code];
		_ ->
		    ""
	    end;
	_ ->
	    SO_code
    end.

get_opt_by_SO_code(SoCode,Subscription,Type)->
    option_manager:get_opt_by_SOCode({Subscription,SoCode},Type).

get_commercial_name(Opt,Sub)->
    Commercial_name=option_manager:get_commercial_name({Opt,Sub}),
    case Commercial_name of
	Error when Error == not_found;
		   Error == closed;
		   Error == []->
	    Config_param_name=case Sub of
				  mobi->
				      opt_commercial_name_mobi;
				  cmo->
				      opt_commercial_name_cmo;
				  postpaid->
				      opt_commercial_name_postpaid;
				  _ ->
				      slog:event(warning, ?MODULE, wrong_config_param_name, Sub),
				      opt_commercial_name_mobi
			      end,
	    Commercial_names=pbutil:get_env(pservices_orangef, Config_param_name),
	    case lists:keysearch(Opt,1,Commercial_names) of
		{value,{Opt, Name}}->
		    Name;
		false->
		    []
	    end;
	_ ->
	    Commercial_name
    end.
	
	    
get_commercial_dates(Opt,Sub)->
    Commercial_date=option_manager:get_commercial_dates({Opt,Sub}),
    case Commercial_date of
	Error when Error == not_found;
		   Error == closed;
                   Error == []->
            Conf_param_date =
                case Sub of
                    postpaid ->
                        commercial_date_postpaid;
                    cmo -> 
                        commercial_date_cmo;
		    virgin_prepaid -> 
			commercial_date_virgin_pp;
		    virgin_comptebloque -> 
			commercial_date_virgin_cb;
		    carrefour_prepaid -> 
			commercial_date_carrefour_pp;
		    tele2_pp -> 
			commercial_date_tele2_pp;
		    tele2_comptebloque -> 
			commercial_date_tele2_cb;
		    dme -> 
			commercial_date_dme;
		    monacell_prepaid -> 
			commercial_date_monacell_pp;
		    _ -> 
			commercial_date
                end,
            {ok, Commercial_date_psv} =
                application:get_env(pservices_orangef, Conf_param_date),
            Comm_Date_Opt=
                case lists:keysearch(Opt, 1, Commercial_date_psv) of
                    {value,{Opt, CommDate}} -> 
			slog:event(trace, ?MODULE, found_commercial_date,[pservices_orangef,Opt,CommDate]),
                        CommDate;
                    _ ->
			slog:event(trace, ?MODULE, not_found_commercial_date,[pservices_orangef,Opt]),
			""
                end,
	    Comm_Date_Opt;
	Comm_date->
	    slog:event(trace, ?MODULE, found_commercial_date,[option_manager,Opt,Comm_date]),
	    Comm_date
    end.
				      

get_open_hour(Opt,Sub)->
    Open_hours=option_manager:get_open_hour({Opt,Sub}),
    case Open_hours of
	Error when Error==[];
		   Error==closed;
		   Error==not_found->
	    case lists:keysearch(Opt,1,svc_util_of:get_env(plage_horaire)) of
		false->
		    always;
		{value, {Opt,Plages}}->
		    case Plages of
			[{Start_hour1, End_hour1,_}]->
			    [{Start_hour1, End_hour1}];
			[{Start_hour2, End_hour2}]->
			    [{Start_hour2, End_hour2}];
			Others->
			    slog:event(trace, ?MODULE, unexpected_format_open_hours,[Opt, Others]),
			    [{{0,0,0},{0,0,0}}]
		    end			
	    end;
	_ ->
	    Open_hours
    end.
	    

get_open_day(Opt,Sub)->
    Open_days=option_manager:get_open_day({Opt,Sub}),
    case Open_days of
	Error when Error==[];
		   Error==closed;
		   Error==not_found->
            case lists:keysearch(Opt,1, svc_util_of:get_env(plage_horaire)) of
                false->
                    always;
                {value, {Opt,Plages}}->
                    case Plages of
			[{_, _,Open_day}]->
                            Open_day;			
			Others->
                            slog:event(trace, ?MODULE, unexpected_format_open_days,[Opt, Others]),
                            []
                    end
            end;
	_ ->
	    Open_days
    end.

get_list_incompatible_opts(Opt,Sub) ->
    option_manager:get_incompatible_options({Opt,Sub}).

get_kenobi_code(Session,Opt) ->
    Sub = svc_util_of:get_souscription(Session),
    option_manager:get_kenobi_code({Sub,Opt}).

is_compatible(Session,Opt) ->
    Sub = svc_util_of:get_souscription(Session),
    L = get_list_incompatible_opts(Opt,Sub),
    is_subscribed(Session,L).

is_commercially_launched(Session,Opt)->
    Sub=svc_util_of:get_souscription(Session),
    Comm_Date= get_commercial_dates(Opt, Sub),
    LT = svc_util_of:local_time(),
    A=lists:foldl(fun(X,Acc)->
			  case X of
			      {Start,End}->
				  slog:event(trace, ?MODULE, start_Start, Start),
				  slog:event(trace, ?MODULE, end_End, End),
				  Acc or svc_util_of:is_launched(Start,End,LT) ;
			      _->
				  slog:event(trace, ?MODULE, error_X,X)
			  end
		  end,
		  false, Comm_Date),
    slog:event(trace,?MODULE,{is_service_open,Opt},A),
    A.

is_good_plage_horaire(Opt,Sub)->
    Open_Hours = get_open_hour(Opt,Sub),
    Open_Days = get_open_day(Opt,Sub),
    case Open_Hours of
        Error when Error==[{{0,0,0},{0,0,0}}]->
            false;
        always->
            svc_util_of:check_plage_dow(none,always,Open_Days);
        _ ->
            case Open_Days of
                []->
                    false;
                _->
                    {_,Time} = erlang:localtime(),
                    lists:foldl(fun(Open_Hour,Acc)->
                                        X = case Open_Hour of
                                                _->
                                                    Acc
                                            end,
                                        X or svc_util_of:check_plage_dow(Time,Open_Hour,Open_Days)
                                end,false,Open_Hours)
            end
    end.

get_commercial_start_date(Opt,Subscription,Format)->
    Commercial_date=get_commercial_dates(Opt,Subscription),
    Start_date=get_start_date(Commercial_date),
    case Start_date of
	"" ->
	    slog:event(internal, ?MODULE, Subscription, unexpected_format1),
	    "";
	Value1 when tuple(Start_date) ->
	    Date = svc_util_of:sprintf_datetime_by_format(Start_date,Format),
	    lists:flatten(Date);
	Value2 ->
	    slog:event(internal, ?MODULE, Value2, unexpected_format2),
	    ""
    end.

get_commercial_end_date(Opt,Subscription,Format)->
    Commercial_date=get_commercial_dates(Opt,Subscription),
    End_date=get_end_date(Commercial_date),
    case End_date of
	"" ->
	    slog:event(internal, ?MODULE, Subscription, unexpected_format1),
	    "";
	Value1 when tuple(End_date) ->
	    Date = svc_util_of:sprintf_datetime_by_format(End_date,Format),
	    lists:flatten(Date);
	Value2 ->
	    slog:event(internal, ?MODULE, Value2, unexpected_format2),
	    ""
    end.

%% +type get_end_date(list) -> tuple().                                                                                                                     
%%%% Returns the end date for dates in the format :                                                                                                        
%%%% :[{{{2006,7,5},{0,0,0}},{{2006,9,3},{23,59,59}}},                                                                                                     
%%%%   {{{2007,1,2},{0,0,0}},{{2007,2,7},{23,59,59}}}]                                                                                                     
%%%% For this example returns {{2007,2,7},{23,59,59}}                                                                                                      
get_end_date([{_,End}])->
     End;
get_end_date([{_,_}|LaterCommDate]) -> get_end_date(LaterCommDate);
get_end_date(CommDate) -> 
    slog:event(internal, ?MODULE, CommDate, unexpected_format_date),
    "".

%% +type get_start_date(list) -> tuple().                                                                                                                   
%%%% Returns the start date for dates in the format :                                                                                                      
%%%% :[{{{2006,7,5},{0,0,0}},{{2006,9,3},{23,59,59}}},                                                                                                     
%%%%   {{{2007,1,2},{0,0,0}},{{2007,2,7},{23,59,59}}}]                                                                                                     
%%%% For this example returns {{2007,1,2},{0,0,0}}                                                                                                         
get_start_date([{Start,_}])-> 
    Start;
get_start_date([{_,_}|LaterCommDate]) -> get_start_date(LaterCommDate);
get_start_date(CommDate) -> 
    slog:event(internal, ?MODULE, CommDate, unexpected_format_date),
    "".

is_good_default_conditions(Session,Opt,default)->    
    Sub=svc_util_of:get_souscription(Session),
        Is_good_Comm_date=is_commercially_launched(Session,Opt),
        Is_good_hour=is_good_plage_horaire(Opt,Sub),
        Is_good_bank_holiday=(svc_util_of:is_bank_holiday(Opt)==false),
        Is_good_Comm_date and Is_good_hour and Is_good_bank_holiday;

is_good_default_conditions(Session,Opt,{Check_comm_dates,Check_hour,Check_bank_holiday}) ->
    Sub=svc_util_of:get_souscription(Session),
    Is_good_Comm_date=if (Check_comm_dates==true)->
			      is_commercially_launched(Session,Opt);
                        true->
                             true
                     end,
    Is_good_hour=if (Check_hour==true)->
                         is_good_plage_horaire(Opt,Sub);
                    true ->
                         true
                 end,
    Is_good_bank_holiday=if (Check_bank_holiday==true)->
                                 svc_util_of:is_bank_holiday(Opt)==false;
                            true ->
                                 true
                         end,
    Is_good_Comm_date and Is_good_hour and Is_good_bank_holiday.

is_possible_subscription(Session,Opt)->
    Sub=svc_util_of:get_souscription(Session),
    Result = option_manager:get_condition({Opt,Sub},subscribe),
    case Result of
	not_found->
	    {Session, false,not_found};
	closed -> 
	    {Session,false,closed};
	none ->
	    {Session,true};
	default ->
	    {Session,is_good_default_conditions(Session,Opt,default)};
	{default_and_custom,{Module,Function}} ->
	    X = is_good_default_conditions(Session,Opt,default),
	    {Session1,Y} = Module:Function(Session,Opt),
	    {Session1,(X and Y)};
	{custom,{Module,Function}} ->
	    %function Module:Function always return true/false
	    %usualy be implemented in svc_check_conditions_options Module
	    Module:Function(Session,Opt)
    end.

is_possible_unsubscription(Session,Opt)->    
    Sub=svc_util_of:get_souscription(Session),
    Result = option_manager:get_condition({Opt,Sub},unsubscribe),
    case Result of
        not_found->
	    {Session, false,not_found};
	closed ->
            {Session, false,closed};
        none ->
            {Session,true};
        default ->
            {Session, is_good_default_conditions(Session,Opt,default)};
        {default_and_custom,{Module,Function}} ->
            X = is_good_default_conditions(Session,Opt,default),
            {Session1,Y} = Module:Function(Session,Opt),
            {Session1,(X and Y)};
        {custom,{Module,Function}} ->
            %function Module:Function always return true/false
            %usualy be implemented in svc_check_conditions_options Module
            Module:Function(Session,Opt)
    end.


is_possible_reactivation(Session,Opt)->
    Sub=svc_util_of:get_souscription(Session),
        Result = option_manager:get_condition({Opt,Sub},reactivate),
        case Result of
	    not_found->
		{Session,false,not_found};
	    closed ->
		{Session, false,closed};
	    none ->
		{Session,true};
	    default ->
		{Session,is_good_default_conditions(Session,Opt,default)};
	    {default_and_custom,{Module,Function}} ->
		X = is_good_default_conditions(Session,Opt,default),
		{Session1,Y} = Module:Function(Session,Opt),
		{Session1,(X and Y)};
	    {custom,{Module,Function}} ->
            %function Module:Function always return true/false
            %usualy be implemented in svc_check_conditions_options Module
		Module:Function(Session,Opt)
    end.

is_subscribed(Session,Opt) when is_atom(Opt) ->    
    Subs = svc_util_of:get_souscription(Session),
    {_,Records} = option_manager:get_open_record({Opt,Subs}),
    case Records of 
	not_found -> 
	    not_found;
	[] ->
	    closed;
	_ ->	    
	    case Subs of 
		Subs when Subs==mobi;Subs==symacom -> 
		    case state(Session,Opt) of 
			{UpdatedSession,not_actived} ->
			    {UpdatedSession,false};
			{UpdatedSession,_} ->
			    {UpdatedSession,true}
		    end;
		Subs when (((Subs==virgin_prepaid) or (Subs==virgin_comptebloque)) and
			   ((Opt/=opt_sms_200) and (Opt/=opt_sms_ill))) ->
		    State = svc_util_of:get_user_state(Session),
		    case svc_compte:cpte(State,opt_to_godet(Opt,Subs)) of
			#compte{etat=?CETAT_AC} ->
			    TOP_NUM = get_top_num(Opt,Subs),
			    {NewSession,NewState} = check_topnumlist(Session),
			    {NewSession,lists:member(TOP_NUM,NewState#sdp_user_state.topNumList)};
			_ ->
			    {Session,false}
		    end;
		_ ->		    
		    TOP_NUM = get_top_num(Opt,Subs),
		    {NewSession,NewState} = check_topnumlist(Session),
		    {NewSession,lists:member(TOP_NUM, NewState#sdp_user_state.topNumList)}
	    end
    end;
is_subscribed(Session,[]) ->  {Session,false};
is_subscribed(Session,[Opt|T]=Opts) when is_list(Opts) ->
    case is_subscribed(Session,Opt) of 
	{UpdatedSession,false} -> 
	    is_subscribed(UpdatedSession,T);
	Else ->
	    Else
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO HANDLE ACTIVE OPTIONS VIA TOP_NUM LISTS AND FLAGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_topnumlist(session())-> sdp_user_state().
%%%% If TOP_NUM list not yet defined in sdp_user_state, request information from Sachem.
check_topnumlist(Session)->
    State = svc_util_of:get_user_state(Session),
    UpdatedState=
        case State#sdp_user_state.topNumList of
            undefined -> 
                TopNumList = case activ_options(Session) of 
                                 {UpdatedSession,Activ_opts} ->
                                     Activ_opts;
                                 Error ->
                                     []
                             end,
                State#sdp_user_state{topNumList=TopNumList};
            _ -> 
                State
        end,
    {svc_util_of:update_user_state(Session,UpdatedState),UpdatedState}.

%%% +type check_options(session())-> sdp_user_state().
%%%%% If OPTIONS list not yet defined in sdp_user_state, request information from Sachem.
check_options(#session{prof=Prof}=Session)->
    State = svc_util_of:get_user_state(Session),
    UpdatedState= 
	case State#sdp_user_state.options of
	    undefined ->
		case svc_sachem:consult_account_options(Session) of
		    {ok, {OkSession, Resp_params}} -> 
			svc_util_of:get_user_state(OkSession);
		    {nok, _} -> 
			State
		end;
	    _ -> State
	end,
    {svc_util_of:update_user_state(Session,UpdatedState),UpdatedState}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type state(session(),Opt::atom()) -> atom().
%%%% Function used is option activated to check whether the option is activated.
%%%% The TOP_NUM of the option is used to check this except for option numprefp.

state(Session, Opt) ->
    Subscr = svc_util_of:get_souscription(Session),
    case Subscr of
	Subscr when Subscr==mobi;Subscr==symacom ->
	    {NewSession,State} = check_options(Session),
	    TOP_NUM = get_top_num(Opt,Subscr),
	    Status = case lists:keysearch(TOP_NUM, 1,State#sdp_user_state.options) of
			 {value,{TOP_NUM,actived}}->
			     actived;
			 {value,{TOP_NUM,suspend}}->
			     suspend;		
			 false ->
			     not_actived
		     end,
	    {NewSession,Status};
	_ ->
	    slog:event(internal,?MODULE,subscription_not_supported,Subscr),    
	    {Session, undefined}    
    end.

%% +type activ_options(session())-> [integer()] | undefined | error.
%%%% Send request to Sachem server in order to get the list of active options.
activ_options(#session{prof=Prof}=Session)->
    MSISDN = Prof#profile.msisdn,
    Id = {svc_util_of:get_souscription(Session),MSISDN},
    case svc_util_of:get_options_list(Session, Id) of
	{options, TopNumList, UpdatedSession}->
	    {UpdatedSession, TopNumList}; 
	Error->
	    slog:event(failure,?MODULE,svi_c_op_ko,Error),
	    Error
    end.

opt_to_godet(Option,Subscription)
  when list(Option) ->
    G_atom=opt_to_godet(list_to_atom(Option), Subscription),
    atom_to_list(G_atom);

opt_to_godet(Option,Subscription) ->
    svc_compte:search_cpte(get_tcp_num(Option,Subscription), Subscription).

%% + type get_list_opts_activated(session(),Opts::[atom()]) -> [atom()] | []
%%%% Function used to get list of activated options

get_list_opts_activated(Session,Opts) when is_list(Opts) ->
    F = fun(Opt,Acc) ->
		case is_subscribed(Session,Opt) of
		    {_,true} ->
			[Opt|Acc];
		    _ ->
			Acc
		end
	end,
    lists:foldr(F,[],Opts).
			
do_opt_cpt_request(#session{prof=Prof}=S,Opt,Action)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqMntInit = option_manager:get_request_record({Opt,Sub},Action),
    Request = add_msisdn(State,Action,ReqMntInit,Opt),
    Result = case send_update_account_options(S, {Sub,Msisdn},Action,Request) of
		 {ok_operation_effectuee,Session_resp,""} -> 
		     prisme_dump:prisme_count(S,Opt, {subscribe, validation}, sachem),
		     {ok_operation_effectuee,Session_resp,""};
		 {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]} ->
		     prisme_dump:prisme_count(S,Opt, {subscribe, validation}, sachem),
		     {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]};
		 {error, Reason} ->
		     {error, Reason};
		 {OtherCPT2Respond, [TCP_NUM, CPP_SOLDE]} ->
		     {OtherCPT2Respond, ""};
		 Other -> 
		     slog:event(failure, ?MODULE, unknown_nopt, Other),
		     Other    
	     end,
    do_return_opt_cpt_request(S, Result).

do_return_opt_cpt_request(Session, Result)->		 
    case Result of
        {ok_operation_effectuee, Session_resp, Resp_params} ->			 
            {Session_resp,{ok_operation_effectuee,Resp_params}};
        _ ->    
            {Session,Result}
    end.

%%%% Temporary function to send request via
%%%% Either sachem X25 : opt_cpt req
%%%% or sachem Tuxedo  : update_account_options
send_update_account_options(#session{prof=Profile}=Session, 
                            {Sub,Msisdn}, Action, Request) ->
    slog:event(trace, ?MODULE, send_update_account_options, 
               Request),
    Msisdn = Profile#profile.msisdn,
            case svc_sachem:update_account_options(Session, Request) of
                {ok, {Session_resp, Resp}} -> 
                    slog:event(trace, ?MODULE, update_account_options,
                               {ok, Resp}),
                    %%CPP_SOLDE = proplists:get_value("CPP_SOLDE", Resp_params),
                    %%{ok_operation_effectuee, [[], CPP_SOLDE]};
                    {ok_operation_effectuee,Session_resp,""};
                {nok, {error, Reason}} 
                when Reason == "numero_invalid";
                     Reason == "solde_insuffisant";
                     Reason == "option_inexistante";
                     Reason == "option_deja_existante";
                     Reason == "operation_irrealisable";
                     Reason == "msisdn_inconnu";
                     Reason == "option_incompatible_dcl";
                     Reason == "option_incompatible_ptf";
                     Reason == "option_incompatible_opt";
                     Reason == "option_incompatible_sec";
                     Reason == "option_incompatible_solde";
                     Reason == "option_incompatible_date_activ";
                     Reason == "option_incompatible_date_rech";
                     Reason == "option_dependante_absente";
                     Reason == "reactivation_ko" ->
                    slog:event(service_ko, ?MODULE, update_account_options,
                               {Msisdn, Reason}),
                    {error, Reason};
                {nok, {error, Reason}} 
                when Reason == "une_option_souscrite" ->
                    slog:event(warning, ?MODULE, update_account_options,
                               {Msisdn, Reason}),
                    {error, Reason};
                {nok, {error, Reason}} 
                when Reason == "type_ACTION_incorrect" ->            
                    slog:event(warning, ?MODULE, update_account_options,
                               {Msisdn, Reason}),
                    {nok, {error, Reason}};
                {nok, {error, Reason}} 
                when Reason == "erreur_technique";
                     Reason == "other_error" -> 
                    slog:event(failure, ?MODULE, update_account_options,
                               {Msisdn, Reason, Request}),
                    {nok, {error, Reason}};
                Else ->
                    slog:event(failure, ?MODULE, update_account_options,
                               {Msisdn, Else, Request}),
                    {nok, Else}
    end.

do_nopt_cpt_request(#session{prof=Prof}=S,[Opt1|Opt],Action,Opt_params)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqMntInit = option_manager:get_request_record({Opt,Sub},Action),
    Request = add_msisdn(State, Action, ReqMntInit,Opt1),
    do_nopt_cpt_request(S,Opt,Action,[Request|Opt_params],Opt1).


do_nopt_cpt_request(#session{prof=Prof}=S,[],Action,Request,Option)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    Result = case send_NOPT_request(S, {Sub,Msisdn},Action,Request) of
		 {ok_operation_effectuee,Session_resp,""} -> 
		     prisme_dump:prisme_count(S,Option,{Action, validation}, sachem),
		     {ok_operation_effectuee,Session_resp,""};
		 {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]} ->
		     prisme_dump:prisme_count(S,Option,{Action, validation}, sachem),
		     {ok_operation_effectuee,Session_resp, [TCP_NUM, CPP_SOLDE]};
		 {OtherCPT2Respond, [TCP_NUM, CPP_SOLDE]} ->
		     {OtherCPT2Respond, ""};
		 {error, Reason} ->
		     {error, Reason};
		 Other -> 
		     Other    
	     end,
    do_return_opt_cpt_request(S, Result);

do_nopt_cpt_request(#session{prof=Prof}=S,[Opt1|Opt],Action,Opt_params,Option)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqMntInit = option_manager:get_request_record({Opt,Sub},Action),
    Request = add_msisdn(State, Action, ReqMntInit,Opt1),
    do_nopt_cpt_request(S,Opt,Action,[Request|Opt_params],Option).

send_NOPT_request(#session{prof=Prof}=Session, {Sub,Msisdn},Action,Request) ->
    slog:event(trace, ?MODULE, send_NOPT_request,Request),
    Msisdn = Prof#profile.msisdn,
    case svc_sachem:handle_options(Session, Request) of
	{ok, {Session_resp, Resp_params}} ->                  
	    TCP_NUM = proplists:get_value("TCP_NUM", Resp_params),
	    CPP_SOLDE = proplists:get_value("CPP_SOLDE", Resp_params),
	    {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]};
	{nok, {error, Reason}} 
	when Reason == "solde_insuffisant";
	     Reason == "option_inexistante";
	     Reason == "option_deja_existante";
	     Reason == "operation_irrealisable";
	     Reason == "msisdn_inconnu";
	     Reason == "option_incompatible_dcl";
	     Reason == "option_incompatible_ptf";
	     Reason == "option_incompatible_opt";
	     Reason == "option_incompatible_sec";
	     Reason == "option_incompatible_solde";
	     Reason == "option_incompatible_date_activ";
	     Reason == "option_incompatible_date_rech";
	     Reason == "option_dependante_absente";
	     Reason == "reactivation_ko" ->
	    slog:event(service_ko, ?MODULE, handle_options,
		       {Msisdn, Reason}),
	    {error, Reason};
	{nok, {error, Reason}} 
	when Reason == "type_ACTION_incorrect" ->            
	    slog:event(warning, ?MODULE, handle_options,
		       {Msisdn, Reason}),
	    {error, Reason};
	{nok, {error, Reason}} 
	when Reason == "erreur_technique";
	     Reason == "other_error" -> 
	    slog:event(failure, ?MODULE, handle_options,
		       {Msisdn, Reason, Request}),
	    {nok, {error, Reason}};
	Else ->
	    slog:event(failure, ?MODULE, handle_options,
		       {Msisdn, Else, Request}),
	    {nok, Else}
    end.

add_msisdn(State, Action, Req,Opt=opt_sms_illimite) ->
    case Action of
	terminate ->
	    Req;
	_ ->
	    MSISDN1 = State#sdp_user_state.numero_sms_illimite,
	    Req#opt_cpt_request{msisdn1 = MSISDN1}
    end;
add_msisdn(State, Action, Req,Opt)
  when Opt==opt_num_prefere;
       Opt==opt_numpref_tele2 ->
    MSISDN1 = State#sdp_user_state.numero_prefere,
    Req#opt_cpt_request{msisdn1 = MSISDN1};
    
add_msisdn(_,_,Req,_) ->
    Req.
