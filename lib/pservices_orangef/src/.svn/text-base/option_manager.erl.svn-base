-module(option_manager).

%%% API table initialisation
-export([init/0,
	 load/1,
	 load_table/1]).

%%% API for calling out from external module
-export([get_orange_id/1,
	 get_commercial_dates/1,
	 get_open_hour/1,
	 get_open_day/1,
	 get_open_record/1,
	 get_kenobi_code/1,
	 get_open_record/2,
         set_open_hour/2,
         set_open_day/2,
	 get_condition/2,
	 get_incompatible_options/1,
	 get_commercial_name/1,
	 set_present_commercial_date/1,
         set_past_commercial_date/1,
	 reset_commercial_date/1,
	 get_orange_id/2,
	 get_opt_param/2,
	 get_opt_by_SOCode/2,	 
	 get_request_record/2,
	 set_commercial_date/2
	]).

-include("../include/qlc.hrl").
-include("../include/option.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

-define(PATH,"lib/pservices_orangef/priv/").
-define(File_sachem,"sachem_options.csv").
-define(File_asmetier,"asmetier_options.csv").
-define(SEP,$;).
-define(Key,"key").
-define(Present,svc_util_of:term_to_string([test_util_of:get_present_period()])).
-define(Past,svc_util_of:term_to_string([test_util_of:get_past_period()])).
-define(Present_Hour,"[{0,0,0},{23,59,59}]").
-define(Present_Day,"[lundi, mardi, mercredi,jeudi, vendredi, samedi, dimanche]").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init() ->
    load(sachem),
    load(asmetier).

rpc_call(Func,Arg) ->
    rpc:call(possum@localhost,?MODULE,Func,Arg).

load(Table) ->
    rpc_call(load_table,[Table]).

load_table(sachem=Table) ->
    Result = csv_util:csv2list(?PATH++?File_sachem,
				[{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},
				 {mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},
				 {mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},
				 {mandatory,string},{mandatory,string},{mandatory,string}],			       
			       [{after_line,?Key},{separator,?SEP}]),
    case Result of 
	{ok,T} ->
	    update_table(T,Table);
	Else ->
	    {load_table_failed,Else}
    end;

load_table(asmetier=Table) ->
    Result = csv_util:csv2list(?PATH++?File_asmetier,
				[{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},
				 {mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},
				 {mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string},{mandatory,string}
				],			       
			       [{after_line,?Key},{separator,?SEP}]),
    case Result of 
	{ok,T} ->
	    update_table(T,Table);
	Else ->
	    {load_table_failed,Else}
    end.

update_table(T,Table) ->
    Records = build_record(T,Table),
    make_db(Records,Table).

make_db(OptFields,Table) -> 
    Delete = fun(Entry)->
		     mnesia:delete_object(Entry)
	     end, 
    Insert = fun(Entry)->
		     mnesia:write(Entry)
	     end, 

    F = fun() -> 
		Record = case Table of 
			     sachem -> 
				 #option_sachem{_='_'};
			     asmetier -> 
				 #option_asmetier{_='_'}
			 end,
		All = mnesia:match_object(Record),
		lists:foreach(Delete,All),
		lists:foreach(Insert,OptFields) 
	end,    
    case catch mnesia:transaction(F) of
	{atomic,ok} -> 
	    ok;
	Else ->  
	    {make_db_failed,Else}
    end.

build_record(Tab,sachem) ->
    Line2Record =
	fun(Line) ->
		#option_sachem{key=list_to_atom(lists:nth(1,Line)),
			       id_orange=pbutil:string_to_term(lists:nth(2,Line)),
			       subscription=pbutil:string_to_term(lists:nth(3,Line)),
			       commercial_name=lists:nth(4,Line),
			       status=list_to_atom(lists:nth(5,Line)),
			       comments=lists:nth(6,Line),
			       subscribe_parameters=build_req_record(subscribe,{Line,7}),
			       unsubscribe_parameters=build_req_record(terminate,{Line,8}),
			       reactivation_parameters=build_req_record(reactivate,{Line,9}),
			       incompatible_options=pbutil:string_to_term(lists:nth(10,Line)),
			       commercial_dates=lists:nth(11,Line),
			       open_hours=lists:nth(12,Line),
			       open_days=lists:nth(13,Line),
			       bank_holidays_closure=lists:nth(14,Line),
			       statistics_id=lists:nth(15,Line),
			       subscribe_conditions=pbutil:string_to_term(lists:nth(16,Line)),
			       unsubscribe_conditions=pbutil:string_to_term(lists:nth(17,Line)),
			       reactivate_conditions=pbutil:string_to_term(lists:nth(18,Line))}
	end,
    lists:map(Line2Record,Tab);
build_record(Tab,asmetier) ->
    Line2Record =
	fun(Line) ->
		#option_asmetier{key=list_to_atom(lists:nth(1,Line)),
				 subscribe_SO=lists:nth(2,Line),
				 terminate_SO=lists:nth(3,Line),			    
				 subscription=list_to_atom(lists:nth(4,Line)),
				 commercial_name=lists:nth(5,Line),
				 status=list_to_atom(lists:nth(6,Line)),
				 comments=lists:nth(7,Line),
				 incompatible_options=pbutil:string_to_term(lists:nth(8,Line)),
				 commercial_dates=lists:nth(9,Line),
				 open_hours=lists:nth(10,Line),
				 open_days=lists:nth(11,Line),
				 bank_holidays_closure=lists:nth(12,Line),
				 statistics_id=lists:nth(13,Line),
				 subscribe_conditions=pbutil:string_to_term(lists:nth(14,Line)),
				 unsubscribe_conditions=pbutil:string_to_term(lists:nth(15,Line))}
	end,
    lists:map(Line2Record,Tab).

build_req_record(TypeRequest,{Line,N}) when TypeRequest==subscribe;
					    TypeRequest==terminate;
					    TypeRequest==reactivate ->
    
    L = pbutil:string_to_term(lists:nth(N,Line)),
    if is_list(L) ->
	    TypeAction = case TypeRequest of 
			     subscribe -> "A";
			     terminate -> "S";
			     reactivate ->
				 case lists:keysearch(type_action,1,L) of 
				     {value,_} -> 
					 "M";
				     _ ->
					 "A" %% default value
				 end
			 end,
	    F =  fun(Element) ->
			 case lists:keysearch(Element,1,L) of 
			     {value,{_,Val}} ->
				 case Element of 
				     Element when Element==cout;Element==mnt_initial;Element==rnv_num ->
					 integer_to_list(Val);
				     _ ->
					 Val
				 end;
			     _->
				 default_value(Element,pbutil:string_to_term(lists:nth(2,Line)))
			 end
		 end,
	    [Date_Deb,Heure_Deb,Date_Fin,Heure_Fin,TOP_NUM,PTF,TCP,Cout,Mnt_Intial,RNV] = 
		lists:map(F,[date_debut,heure_debut,date_fin,heure_fin,top_num,ptf_num,tcp_num,cout,mnt_initial,rnv_num]),		
	    #request_param{type_action=TypeAction,
			   top_num=integer_to_list(TOP_NUM),
			   date_deb = Date_Deb,
			   heure_deb = svc_util_of:format_heure(Heure_Deb),
			   date_fin = Date_Fin,
			   heure_fin = svc_util_of:format_heure(Heure_Fin),
			   ptf_num=integer_to_list(PTF),
			   tcp_num=integer_to_list(TCP),
			   cout = Cout,
			   mnt_initial = Mnt_Intial,
			   rnv_num = RNV
			  };
       true ->
	    L
    end.
   
build_opt_cpt_request(Record) ->
    #opt_cpt_request{type_action = Record#request_param.type_action,
		     top_num = Record#request_param.top_num,
		     date_deb = process_date(Record#request_param.date_deb),
		     heure_deb = Record#request_param.heure_deb,
		     date_fin = process_date(Record#request_param.date_fin),
		     heure_fin = Record#request_param.heure_fin,
		     ptf_num = Record#request_param.ptf_num,
		     tcp_num = Record#request_param.tcp_num,
		     cout = Record#request_param.cout,
		     mnt_initial = Record#request_param.mnt_initial,
		     rnv_num = Record#request_param.rnv_num
		    }.
    
default_value(Element,L) ->
    case Element of 
	Element when Element==date_debut;
		     Element==heure_debut;
		     Element==date_fin;
		     Element==heure_fin ->
	    undefined;
	top_num ->
	    element(1,L);
	ptf_num ->
	    element(2,L);
	tcp_num -> 
	    element(3,L);
	cout ->
	    "-";
	mnt_initial ->
	    "-1";
	rnv_num ->
	    "-1"
    end.    
    
%%%% Process date %%%%%%%%%%%%%%%%%% 
process_date(Date) ->    
    case Date of 
	today -> date();
	{add_days_to_now,[{dm,Value}]} ->
	    Date_plus = svc_util_of:today_plus_datetime(Value),	    
	    svc_util_of:format_date_dm(Date_plus);
	{add_days_to_now,[{dmy,Value}]} ->
	    Date_plus = svc_util_of:today_plus_datetime(Value),	    
	    svc_util_of:format_date_dmy(Date_plus);
	{add_days_to_now,[Value]} ->
	    Date_plus = svc_util_of:today_plus_datetime(Value),
	    svc_util_of:format_date(Date_plus);
	next_monday ->
	    svc_util_of:next_monday_date();
	next_Saturday ->
	    svc_util_of:next_Saturday_date();
	next_Sunday ->
	    svc_util_of:next_Sunday_date();
	_ ->
	    undefined
    end.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% API to db access %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% +type get_open_record({Key,Sub}) -> tuple of {Table::atom(),Records::[tuple()]}
%%% Returns a tuple of 2 elements : table and records with status "open" filtered by Key and Sub 
%%%%% Key::atom() -> option name 
%%%%% Sub::atom() -> subscription
get_open_record({Key,Sub}) ->
    Result = get_open_record(?Opt_sachem,{Key,Sub}),
    case Result of 
	{_,not_found}->
	    get_open_record(?Opt_asm,{Key,Sub});
	{_,[]}->
	    get_open_record(?Opt_asm,{Key,Sub});
	_ -> 
	    Result
    end.
    

%%% +type get_open_record(Table,{Key,Sub}) -> Records::[tuple()] | []
%%% Returns the option records filtered by Key with status "open" in defined table 
%%%%% Table::atom() -> option_sachem | option_asmetier
%%%%% Key::atom() -> option name
%%%%% Sub::atom() -> subscription
get_open_record(Table,{Key,Sub}) ->
    Result = case Table of 
		 ?Opt_sachem -> 
		     Rs_sachem = 
			 case catch mnesia:dirty_match_object(#option_sachem{key=Key,subscription=Sub,_='_'}) of 
			     Rc_sachem when is_list(Rc_sachem) -> 
				 Rc_sachem;
			     _ ->
				 []
			 end,
		     {?Opt_sachem,Rs_sachem};
		 _ ->
		     Rs_asm =
			 case catch mnesia:dirty_match_object(#option_asmetier{key=Key,subscription=Sub,_='_'}) of 
			     Rc_asm when is_list(Rc_asm) -> 
				 Rc_asm;
			     _ ->
				 []
			 end,
		     {Table,Rs_asm}
	     end,
    case Result of 
	{_,[]} ->
	    {Table,not_found};
	{Table,_} ->
	    {_,Records} = Result,
	    get_open_record(Table,Records)	    
    end;
get_open_record(Table,Records) when is_list(Records)->
    F = fun(Record,Acc) ->
		Status = case Table of 
			     ?Opt_sachem -> Record#option_sachem.status;
			     ?Opt_asm -> Record#option_asmetier.status
			 end,
		case Status of 
		    closed ->
			[];
		    _ ->
			[Record|Acc]
		end
	end,
    {Table,lists:foldr(F,[],Records)}.

%%% +get_open_request(Records,Type) -> Records::[tuple()]
%%% Gives the request record in table option_sachem with status "open" according to action type
%%%%% Recordss::[tuple()] -> 
%%%%% Type::atom() -> subscribe | terminate | modify
get_open_request(Records,Type) ->
    F = fun(Record,Acc) ->
		Status = case Type of 
			     subscribe -> Record#option_sachem.subscribe_parameters;
			     terminate -> Record#option_sachem.unsubscribe_parameters;
			     _ ->
				 Record#option_sachem.reactivation_parameters 
			 end,
		case Status of 
		    closed ->
			[];
		    _ ->
			[Record|Acc]
		end
	end,
    lists:foldr(F,[],Records).
    
get_open_record_by_sub(Sub) ->
    Records = case catch mnesia:dirty_index_read(?Opt_asm,Sub,#option_asmetier.subscription) of 
		  Rc_asm when is_list(Rc_asm) ->
		      Rc_asm;
		  _ ->
		      []
	      end,
    case Records of 
	[] -> 
	    not_found;
	_ ->
	    F = fun(Record,Acc) ->
			case Record#option_asmetier.status of 
			    closed ->
				[];
			    _ ->
				[Record|Acc]
			end
		end,
	    lists:foldr(F,[],Records)
    end.

%%% get_orange_id({Key,Sub}) -> {TOP_NUM, PTF_NUM, TCP_NUM} | List of SO codes | not_found | closed
%%% Key::atom() => option name
%%% Sub::atom() => subscription
get_orange_id({Key,postpaid=Sub}) ->
    get_orange_id({Key,Sub,asmetier});    
get_orange_id({Key,Sub}) ->
    Id = get_orange_id({Key,Sub,sachem}),
    case Id of 
	closed -> 
	    closed;
	not_found ->
	    get_orange_id({Key,Sub,asmetier});
	_ ->
	    Id
    end;

%%% get_orange_id({Key,Sub,Table}) -> {TOP_NUM,PTF_NUM,TCP_NUM} | not_found | closed
%%% Key::atom() => option name
%%% Sub::atom() => subscription
%%% Table::atom() => sachem
get_orange_id({Key,Sub,sachem}) ->
    {_,Records} = get_open_record(?Opt_sachem,{Key,Sub}),
    case Records of 
	not_found -> 
	    not_found;
	[] -> 
	    closed;
	_ ->
	    Record = lists:last(Records),
	    Record#option_sachem.id_orange
    end;

%%% get_orange_id({Key,Sub,Table}) -> SO codes::[string()] | not_found | closed
%%% Key::atom() => option name
%%% Sub::atom() => subscription
%%% Table::atom() => asmetier
get_orange_id({Key,Sub,asmetier}) ->
    {_,Records} = get_open_record(?Opt_asm,{Key,Sub}),
    case Records of 
	not_found -> 
            not_found;
	[] -> 
	    closed;
	_  ->
	    Record = lists:last(Records),
	    List_SO_subscribe = get_SOCode_by_type(Record,subscribe),
	    List_SO_terminate = get_SOCode_by_type(Record,terminate),
	    F = fun(E,Acc) -> 
			case lists:member(E,Acc) of 
			    true -> 
				Acc;
			    _ -> 
				[E|Acc]
			end
		end,
	    lists:foldr(F,List_SO_terminate,List_SO_subscribe)
    end;
%%% get_orange_id({Key,Sub,Table}) -> SO codes::[string()] | not_found | closed
%%% Key::atom() => option name
%%% Sub::atom() => subscription
%%% Table::atom() => asmetier
%%% Type::atom()=> subscribe | teminate
get_orange_id({Key,Sub,asmetier,Type}) ->
    {_,Records} = get_open_record(?Opt_asm,{Key,Sub}),
    case Records of
	not_found -> 
            not_found;
        [] ->
	    closed;
	_  ->
	    Record = lists:last(Records),
	    get_SOCode_by_type(Record,Type)
    end.

	    
%%% get_orange_id({Key,Sub},Param) -> integer() | not_found | closed
%%% Key::atom() => option name 
%%% Sub::atom() => subscription
%%% Param::atom() -> top_num|ptf_num|tcp_num
get_orange_id({Key,Sub},Param) 
  when Param==top_num;
       Param==ptf_num;
       Param==tcp_num ->
    Result = get_orange_id({Key,Sub,sachem}),
    if (is_tuple(Result)) ->
	    case Param of 
		top_num -> element(1,Result);
		ptf_num -> element(2,Result);
		tcp_num -> element(3,Result)
	    end;
       true -> 
	    Result
    end.

%%% get_opt_param({Key,Sub},Param) -> string() | not_found | closed
%%% Key::atom() => option name 
%%% Sub::atom() => subscription
%%% Param::atom() -> cout|mnt_initial|rnv_num|date_fin
get_opt_param({Key,Sub},Param)
  when Param==cout;
       Param==mnt_initial;
       Param==rnv_num;
       Param==date_fin->
    {_,Records} = get_open_record(?Opt_sachem,{Key,Sub}),
    case Records of 
	not_found -> 
	    not_found;
	[] -> 
	    closed;
	_  ->
	    Record = lists:last(Records),
	    ReqRecord = Record#option_sachem.subscribe_parameters,
	    if is_record(ReqRecord,opt_cpt_request) ->
		    case Param of
			cout ->
			    ReqRecord#opt_cpt_request.cout;
			mnt_initial ->
			    ReqRecord#opt_cpt_request.mnt_initial;
			rnv_num ->
			    ReqRecord#opt_cpt_request.rnv_num;
			date_fin ->
			    ReqRecord#opt_cpt_request.date_fin
		    end;
	       true ->
		    ReqRecord
	    end
    end;
get_opt_param(_,_) ->
    undefined.

%%% get_request_record({Key,Sub},Param) -> record request::tuple() | not_found::atom() | closed::atom()
%%% Key::atom() => option name 
%%% Sub::atom() => subscription
%%% TypeAction::atom() -> subscribe|terminate|modify
get_request_record({Key,Sub},TypeAction) 
  when TypeAction==subscribe;
       TypeAction==terminate;
       TypeAction==modify ->
    {_,Records} = get_open_record(?Opt_sachem,{Key,Sub}),
    case Records of 
	not_found -> 
	    not_found;
	[] -> 
	    closed;
	_ ->
	    Open_Requests = get_open_request(Records,TypeAction),
	    case Open_Requests of 
		[] ->
		    not_found;
		_ ->
		    Record = lists:last(Open_Requests),		    
		    RequestRecord = case TypeAction of 
					subscribe ->						
					    Record#option_sachem.subscribe_parameters;
					terminate ->
					    Record#option_sachem.unsubscribe_parameters;
					_ ->
					    Record#option_sachem.reactivation_parameters
				    end,
		    build_opt_cpt_request(RequestRecord)
	    end
    end.

%%% get_commercial_name({Key,Sub}) -> [tuple()] | not_found::atom()
%%% Key::atom() => option name
%%% Sub::atom() => subscription
%%% Seach on sachem option table, if not found, search on asmetier option table.
get_commercial_name({Key,Sub})->
    {Table,Records} = get_open_record({Key,Sub}),
    case Records of
	not_found -> 
	    not_found;
	[]->
	    closed;
        _ ->
	    Record = lists:last(Records),
	    case Table of
		?Opt_sachem->
		    Record#option_sachem.commercial_name;
		?Opt_asm->
		    Record#option_asmetier.commercial_name
	    end
    end.

%%% get_commercial_dates({Key,Sub}) -> [tuple()] | not_found::atom() | closed::atom() | always::atom()
%%% Key::atom() => option name 
%%% Sub::atom() => subscription
get_commercial_dates({Key,Sub}) ->
    {Table,Records} = get_open_record({Key,Sub}),
    case Records of 
	not_found -> 
	    not_found;
	[] -> 
	    closed;
	_ -> 
	    Record = lists:last(Records),
	    List_commercial_dates=case Table of 
				      ?Opt_sachem ->  
					  Record#option_sachem.commercial_dates;
				      _ ->
					  Record#option_asmetier.commercial_dates
				  end,
	    pbutil:string_to_term(List_commercial_dates)
    end.

%%% get_open_hour({Key,Sub}) -> [tuple()] | not_found::atom() | closed::atom() | always::atom()
%%% Key::atom() => option name
%%% Sub::atom() => subscription

get_open_hour({Key,Sub})->
    {Table,Records} = get_open_record({Key,Sub}),
    case Records of
	not_found -> 
	    not_found;
        [] ->
	    closed;
	_ ->
            Record = lists:last(Records),
	    List_open_hour=case Table of
				      ?Opt_sachem ->
                                          Record#option_sachem.open_hours;
                                      _ ->
                                          Record#option_asmetier.open_hours
                                  end,
            pbutil:string_to_term(List_open_hour)
    end.

%%% get_open_day({Key,Sub}) -> [tuple()] | not_found::atom() | closed::atom() | always::atom()
%%% Key::atom() => option name
%%% Sub::atom() => subscription

get_open_day({Key,Sub})->
    {Table,Records} = get_open_record({Key,Sub}),
    case Records of
	not_found -> 
	    not_found;
        [] ->
	    closed;
	_ ->
            Record = lists:last(Records),
            List_open_day=case Table of
                                      ?Opt_sachem ->
                                          Record#option_sachem.open_days;
                                      _ ->
                                          Record#option_asmetier.open_days
                                  end,
            pbutil:string_to_term(List_open_day)
    end.
%%% +type get_opt_by_SOCode(({Sub,SOCode},Type) -> [option::atom()]|closed::atom() | []
%%% Sub::atom() => subscription
%%% SOCode::string() => SO code
%%% Type::atom() => subscribe | terminate 
get_opt_by_SOCode({Sub,SOCode},Type) ->
    Records = get_open_record_by_sub(Sub),
    case Records of 
	not_found -> 
	    not_found;
	[] -> 
	    closed;
	_ ->
	    F = fun(Record,Acc) ->
			List_SO = get_SOCode_by_type(Record,Type),
			if (List_SO==[]) ->
				Acc;
			   true ->
				case lists:member(SOCode,List_SO) of 
				    true ->
					[Record#option_asmetier.key|Acc];
				    _ ->
					Acc
				end
			end
		end,
	    lists:foldr(F,[],Records)		    
    end.

%%% +type get_SOCode_by_type(Record,Type) -> List of SO Code
%%% Record::record()=>option_asmetier
%%% Type::atom() => subscribe | terminate
get_SOCode_by_type(Record,Type) ->
    case Type of 			       
	subscribe -> 
	    X = string:tokens(Record#option_asmetier.subscribe_SO,"[]"),
	    SO_subscribe = if (X==[]) ->
				   X;
			      true ->
				   lists:last(X)
			   end,
	    string:tokens(SO_subscribe,",");
	_ ->
	    Y = string:tokens(Record#option_asmetier.terminate_SO,"[]"),
	    SO_terminate = if (Y==[]) ->
				   Y;
			      true ->
				   lists:last(Y)
			   end,
	    string:tokens(SO_terminate,",")
    end.

%%% get_kenobi_code({Key,Sub}) -> string() | not_found::atom() | closed::atom() | no_counter
%%% Key::atom() => option name
%%% Sub::atom() => subscription

get_kenobi_code({Key,Sub})->
    {Table,Records} = get_open_record({Key,Sub}),
    case Records of
	not_found -> 
	    not_found;
        [] ->
	    closed;
	_ ->
            Record = lists:last(Records),
            Kenobi_code = case Table of
                                      ?Opt_sachem ->
                                          Record#option_sachem.statistics_id;
                                      _ ->
                                          Record#option_asmetier.statistics_id
                                  end,
	    Kenobi_code
    end.

%%% +type set_present_commercial_date({Opt,Sub}) -> not_found | closed | ok | {aborted,Reason}
%%% Set the commercial date of an option key at present time
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
set_present_commercial_date({Opt,Sub}) ->
    set_commercial_date({Opt,Sub},?Present).

%%% +type set_past_commercial_date({Opt,Sub}) -> not_found | closed | ok | {aborted,Reason}
%%% Set the commercial date of an option key at past time
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
set_past_commercial_date({Opt,Sub}) ->
    set_commercial_date({Opt,Sub},?Past).

%%% +type set_commercial_date({Opt,Sub},Value) -> not_found | closed | ok | {aborted,Reason}
%%% Set the commercial date of an option key at a specific value 
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
%%%%% Value::[tuple()] => value of commercial date
set_commercial_date({Opt,Sub},Value) ->    
    {Table,Records} = get_open_record({Opt,Sub}),
    case Records of 
	not_found -> 
	    not_found;
	[] ->
	    closed;
	[Record] ->
	    update_record(Table,Record,Value);
	_  ->
	    Record = lists:last(Records),
	    case catch mnesia:dirty_delete_object(Record) of 
		ok -> 
		    update_record(Table,Record,Value);
		Error ->
		    {set_commercial_date_failed,Error}
	    end
    end.

%%% +type reset_commercial_date({Opt,Sub}) -> not_found | closed | ok | {aborted,Reason}
%%% Return the default value of commercial date for an option key
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
reset_commercial_date({Opt,Sub}) ->
    {Table,Records} = get_open_record({Opt,Sub}),
    case Records of
	not_found -> 
	    not_found;
	[] ->
	    closed;
	_  ->
	    if (length(Records) > 1) -> 
		    Record = lists:last(Records),		    
		    case catch mnesia:dirty_delete_object(Record) of 
			ok -> 
			    ok;
			Error ->
			    {reset_commercial_date_failed,Error}
		    end;    
	       true -> 
		    ok
	    end
    end.

%%% +type set_present_open_hour({Opt,Sub}) -> not_found | closed | ok | {aborted,Reason}
%%% Set a present time value of open hour for an option key
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
set_present_open_hour({Opt,Sub}) ->
    set_open_hour({Opt,Sub},?Present_Hour).

%%% +type set_open_hour({Opt,Sub},Value) -> not_found | closed | ok | {aborted,Reason}
%%% Set a specific value of open hour for an option key 
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
%%%%% Value::[tuple()] => value of open hour
set_open_hour({Opt,Sub},Value) ->
    {Table,Records} = get_open_record({Opt,Sub}),
    case Records of
	not_found -> 
	    not_found;
	[] ->
	    closed;
	[Record] ->
	    update_record(Table,Record,Value,open_hour);
	_  ->
	    Record = lists:last(Records),
	    case catch mnesia:dirty_delete_object(Record) of 
		ok -> 
		    update_record(Table,Record,Value,open_hour);
		Error ->
		    {set_open_hour,Error}
	    end
    end.

%%% +type set_present_open_day({Opt,Sub}) -> not_found | closed | ok | {aborted,Reason}
%%% Set a present time value of open day for an option key
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
set_present_open_day({Opt,Sub}) ->
    set_open_hour({Opt,Sub},?Present_Day).

%%% +type set_open_day({Opt,Sub},Value) -> not_found | closed | ok | {aborted,Reason}
%%% Set a specific value of open day for an option key 
%%%%% Opt::atom() => option name
%%%%% Sub::atom() => subscription
%%%%% Value::[tuple()] => value of open day
set_open_day({Opt,Sub},Value) ->
    {Table,Records} = get_open_record({Opt,Sub}),
    case Records of
	not_found -> 
	    not_found;
	[] ->
	    closed;
	[Record] ->
            update_record(Table,Record,Value,open_day);
        _  ->
            Record = lists:last(Records),
            case catch mnesia:dirty_delete_object(Record) of 
		ok -> 
		    update_record(Table,Record,Value,open_day);
		Error ->
		    {set_open_day_failed,Error}
	    end
    end.

%%% +type get_condition({Opt,Sub},Type) -> not_found | closed | default | {custom,mfa()} | {custom_and_default, mfa()}
%%% Return the condition of an option with given subscription depending on its type either subscribe or unsubscribe or reactivate 
%%%%%% Opt::atom() => option name
%%%%%% Sub::atom() => subscription
%%%%%% Type::atom() => subscribe | unsubscribe | reactivate
get_condition({Opt,Sub},Type) ->
    {Table,Records} = get_open_record({Opt,Sub}),
    case Records of
	not_found -> 
	    not_found;
	[]->
	    closed;
	_ -> 
	    Record = lists:last(Records),
	    Result= case Table of
			?Opt_sachem ->
			    case Type of
				subscribe ->
				    Record#option_sachem.subscribe_conditions;
				unsubscribe ->
				    Record#option_sachem.unsubscribe_conditions;
				reactivate ->
				    Record#option_sachem.reactivate_conditions;
				Other ->
				    slog:event(trace, ?MODULE, sachem_unknow_type_conditions, Other),
				    not_found
			    end;
			_ ->
			    case Type of
				subscribe ->
				    Record#option_asmetier.subscribe_conditions;
				unsubscribe ->
				    Record#option_asmetier.unsubscribe_conditions;
				Other ->
				    slog:event(trace, ?MODULE, asmetier_unknow_type_conditions, Other),
				    not_found
			    end
		    end,
	    Result

    end.

%%% +type get_incompatible_options({Opt,Sub}) -> not_found | closed | [] | [atom()]		  
%%% Return the list of incompatible options with the given option
%%%%%% Opt::atom() => option name
%%%%%% Sub::atom() => subscription                                                                                                
get_incompatible_options({Opt,Sub})->
    {Table,Records} = get_open_record({Opt,Sub}),
    case Records of
	not_found -> 
	    not_found;
        []->
            closed;
        _ ->
            Record = lists:last(Records),    
	    case Table of
		?Opt_sachem ->
		    Record#option_sachem.incompatible_options;
		_ ->
		    Record#option_asmetier.incompatible_options
	    end
    end.

update_record(Table,Record,Value) ->
    update_record(Table,Record,Value,commercial_dates).

update_record(Table,Record,Value,Column) 
  when Column==open_hour;
       Column==open_day;
       Column==commercial_dates->    
    NewRecord = case Table of
                    ?Opt_sachem ->
			case Column of
			    commercial_dates ->
				Record#option_sachem{commercial_dates=Value};
			    open_hour ->
				Record#option_sachem{open_hours=Value};
			    open_day ->
				Record#option_sachem{open_days=Value}
			end;
		    _ ->
			case Column of
			    commercial_dates ->
				Record#option_asmetier{commercial_dates=Value};
			    open_hour ->
				Record#option_asmetier{open_hours=Value};
			    open_day ->
				Record#option_asmetier{open_days=Value}
			end
                end,
    case catch mnesia:dirty_write(NewRecord) of 
	ok ->
	    ok;
	Else ->
	    {update_record_failed,Else}
    end.

    
	    


    
    
		     
    
