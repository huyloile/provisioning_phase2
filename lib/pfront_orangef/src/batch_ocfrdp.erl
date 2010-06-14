-module(batch_ocfrdp).

-export([start_link_updates_supervisor/0,
	 updates_supervisor/0,
	 updates/0,
	 suspend_updates/0,
	 resume_updates/0,
	 daily/0,
	 get_batch_ocf_config/0]).
-export([read_text_file/1]).

%% For module upgrades.
-export([updates_supervisor_aux/0,
	 updates_aux/0,
	 updates_aux2/0]).

%%%% rpc:call
-export([read_xml_file/2,
	 delete_users/2, delete_old_user/2]).
-export([sql_delete_imsi/1]).

%% for tests
-export([check_ranges/1,
	 range_rate/2,
	 day_time/1]).

-export([slog_info/3]).

-include("../../xmerl/include/xmerl.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ocf_rdp.hrl").
-include("../../pdatabase/include/pdatabase.hrl").
-include("../../pdist/include/generic_router.hrl").
-include("../../oma/include/slog.hrl").

-define(DOSSIER_CLOT,"70").

%% +type start_link_updates_supervisor() -> {ok, pid()}.

start_link_updates_supervisor() ->
    Pid = proc_lib:start_link(?MODULE, updates_supervisor, []),
    {ok, Pid}.

%% +type updates_supervisor() -> *.
%%%% Some kind of dist_ac replacement. Must always be running on the
%%%% chosen Nodes.  Tries to keep exactly one update process running
%%%% inside the cluster.  Manages network partitioning and
%%%% re-establishement of the fully connected network.
%%%%   Principle: the updates process registers itself globally as ocf_updates.
%%%% - When the node running the ocf_updates process goes down or the
%%%%   network gets partitioned, the updates_supervisor notices there is
%%%%   no process registered as ocf_updates and spawns one.
%%%% - When two sub-networks running an updates process get connected, the
%%%%   `global' module chooses a process to keep the registered name and
%%%%   sends a notification message to the other one.  This process will
%%%%   stop when done with the file being processed.

updates_supervisor() ->
    Ranges = pbutil:get_env(pfront_orangef, batch_ocf_updates_rates),
    case catch check_ranges(Ranges) of
	ok ->
	    proc_lib:init_ack(self());
	{'EXIT', {Reason, Extra} = Info} ->
	    slog:event(internal, ?MODULE, Reason, Extra),
	    exit(Info)
    end,
    net_kernel:monitor_nodes(true),
    updates_supervisor_aux().

%% +type updates_supervisor_aux() -> *.

updates_supervisor_aux() ->
    case global:whereis_name(ocf_updates) of
	undefined -> proc_lib:spawn_link(?MODULE, updates, []);
	Pid       -> ok
    end,
    receive
	{nodeup, N}   -> ok;
	{nodedown, N} -> ok
    end,
    ?MODULE:updates_supervisor_aux().

%% +type updates() -> *.
%%%% Main loop for updates files processing. Runs until it receives a
%%%% {global_name_conflict, ocf_updates} message (because two bits of a
%%%% partitioned network got together again and the local node has not
%%%% been elected to keep the process running).

updates() ->
    register(ocf_updates, self()),
    RN = {global, random_notify_name},
    case global:register_name(ocf_updates, self(), RN) of
	yes -> ok;
	no  -> exit(already_registered)
    end,
    case catch updates_aux() of
	stop -> slog:event(count, ?MODULE, updates_process_stopped)
    end.

%% +type updates_aux() -> *.
updates_aux() ->
    updates_aux2(),
    ?MODULE:updates_aux().

updates_aux2() ->
    Now = pbutil:unixtime(),
    Per = pbutil:get_env(pfront_orangef, batch_ocf_updates_check_period),
    Ranges = pbutil:get_env(pfront_orangef, batch_ocf_updates_rates),
    case range_rate(Ranges, Now) of
	Zero when Zero == 0 ->
	    slog:event(trace, ?MODULE, no_updates_in_current_range),
	    sleep(Now + Per),
	    sleep_rate_zero;
	Rate ->
	    case get_update_files() of
		[] ->
		    slog:event(trace, ?MODULE, no_updates_files),
		    sleep(Now + Per),
		    sleep_no_file;
		[{File, Node} | _] ->
		    slog:event(trace, ?MODULE, processing_updates_file,
			       {File, Rate}),
		    {ok, Read, Updates} = do_updates(File, Node, Rate),
		    slog:sum(count, ?MODULE, read, Read),
		    slog:sum(count, ?MODULE, update, Updates),
		    {ok, Read, Updates}
	    end
    end.

%% +type sleep(unix_time()) -> ok.
%%%% Sleeps until Time. Can be suspended and resumed. Throws stop if the
%%%% global module indicates that there is a name conflict.

sleep(Time) ->
    receive
	suspend ->
	    wait_for_resume_msg(),
	    sleep(Time);
	resume ->
	    sleep(Time); % ignore resume messages when not suspended
	{global_name_conflict, Name} ->
	    throw(stop)
    after lists:max([0, (Time - pbutil:unixtime()) * 1000]) ->
	    ok
    end.

%% +type wait_for_resume_msg() -> ok.

wait_for_resume_msg() ->
    receive
	resume                       -> ok;
	{global_name_conflict, Name} -> throw(stop);
	Any                          -> wait_for_resume_msg()
    end.

%% +type suspend_updates() -> *.

suspend_updates() ->
    global:whereis_name(ocf_updates) ! suspend.

%% +type resume_updates() -> *.

resume_updates() ->
    global:whereis_name(ocf_updates) ! resume.

%% +type get_update_files() -> [{filename(), node()}].
%%%% Sorted by file name.

get_update_files() ->
    OcfCfg = get_batch_ocf_config(),
    #batch_ocf_config{nodes=Nodes,file_regexp=RE,dir=Dir} = OcfCfg,
    get_files(Nodes, RE, Dir).

%% +deftype hour_minute() = {integer(), integer()}.
%% +deftype hour_minute_second() = {integer(), integer(), integer()}.
%% +deftype ranges() = [{hour_minute(), hertz()}].

%% +type check_ranges(ranges()) -> ok.
%%%% Throws an exit if Ranges has an incorrect type, if the times are not
%%%% sorted in increasing order, if the times are incorrect (-1h00, 25h00...)
%%%% or if a rate is negative.

check_ranges(Ranges) ->
    check_ranges_aux(Ranges, {-1, -1}).

%% +type check_ranges_aux(ranges(), hour_minute()) -> ok.

check_ranges_aux([], _Prev) ->
    ok;
check_ranges_aux([{{H, M}, Rate} | T], Prev)
  when integer(H), integer(M), number(Rate) ->
    case (0 =< H) and (H =< 23) and (0 =< M) and (M =< 59) of
	true  -> ok;
	false -> exit({incorrect_time, {H, M}})
    end,
    case Rate >= 0 of
	true  -> ok;
	false -> exit({negative_rate, Rate})
    end,
    case Prev < {H, M} of
	true  -> ok;
	false -> exit({elts_not_sorted, {Prev, {H, M}}})
    end,
    check_ranges_aux(T, {H, M});
check_ranges_aux([X | T], Prev) ->
    exit({malformed_elt, X}).

%% +type range_rate(ranges(), unix_time()) -> Rate::hertz().
%%%% Returns the range rate (specified by
%%%% pfront_orangef::batch_ocf_updates_rates) in which Time is.

range_rate(Ranges, Time) ->
    Ranges1 = [{day_time(T), R} || {T, R} <- Ranges],
    range_rate_aux(lists:reverse(Ranges1), unixtime_to_day_time(Time)).

%% +type range_rate_aux([{second(), hertz()}], unix_time()) -> hertz().

range_rate_aux([], Time) ->
    %% The range starting from midnight is assumed to have rate 0 if not
    %% specified
    0;
range_rate_aux([{Beg, Rate} | T], Time) ->
    case Time >= Beg of
	true  -> Rate;
	false -> range_rate_aux(T, Time)
    end.

%% +type day_time(hour_minute() | hour_minute_second()) -> second().

day_time({H, M}) ->
    H * 60 * 60 + M * 60;
day_time({H, M, S}) ->
    H * 60 * 60 + M * 60 + S.

%% +type unixtime_to_day_time(unix_time()) -> second().

unixtime_to_day_time(Time) when integer(Time) ->
    {_, {H, M, S}} = unixtime_to_datetime(Time),
    day_time({H, M, S}).

%% +type unixtime_to_datetime(unix_time()) -> date_time().

unixtime_to_datetime(T) ->
    calendar:gregorian_seconds_to_datetime(62167219200+T).

%% +type daily() -> {ok,Delete::integer()}.

daily()->
    TO= oma:unixmtime(),
    OCF_CONFIG=get_batch_ocf_config(),
    #batch_ocf_config{nodes=Nodes,dir=DIR,delete_regexp=DEL_REG}=OCF_CONFIG,
    D_Nd_Files = get_files(Nodes,DEL_REG,DIR),
    {ok,Del}=do_delete(D_Nd_Files,OCF_CONFIG),
%%%% suppressions
%%%% on effectue les delete des clients inactifs
    {MONTH_INAC,MAX_DELETE}= pbutil:get_env(pfront_orangef,delete_old_user),
    delete_old_user(MONTH_INAC,MAX_DELETE),
    slog:stats(count,?MODULE,delete,Del),
    slog:delay(perf,?MODULE, execute_time,TO),
    {ok, Del}.

%% +type get_batch_ocf_config() -> batch_ocf_config().

get_batch_ocf_config() ->
    {batch_ocf_config,Pairs} = pbutil:get_env(pfront_orangef,batch_ocf_config),
    Fields = record_info(fields, batch_ocf_config),
    oma_util:pairs_to_record(#batch_ocf_config{}, Fields, Pairs).

%% +type get_files([node()], FilesRegExp::string(), Dir::string()) ->
%%   [{File::string(), node()}].
%%%% Returns the list of the files in Dir matching FilesRegExp on each node
%%%% in Nodes, sorted by file name.

get_files(Nodes, FilesRegExp, Dir)->
    F = fun (Node) ->
		case rpc:call(Node,file,list_dir,[Dir]) of
		    {ok, Files} ->
			[{F, Node} || F <- regexp(Files, FilesRegExp, [])];
		    E ->
			slog:event(warning,?MODULE,get_files_failed,{Node, E}),
			[]
		end
	end,
    Files = lists:flatmap(F, Nodes),
    lists:sort(Files).

%% +type do_updates(filename(), node(), hertz())
%%   -> {ok,Read::int(),Update::int()}.

do_updates(File, Node, Rate) ->
    OcfCfg = get_batch_ocf_config(),
    #batch_ocf_config{dir=Dir, backup_dir=BDir} = OcfCfg,
    case rpc:call(Node,?MODULE,read_xml_file, [Dir++"/"++File, Rate]) of
	{ok, N_Read, N_Update} ->
	    case rpc:call(Node,file,rename,[Dir++"/"++File,BDir++"/"++File]) of
		ok ->
                    slog:event(trace,?MODULE,do_updates,{ok, N_Read, N_Update}),
		    {ok, N_Read, N_Update};
		{error,Reason} ->
		    slog:event(warning, ?MODULE, ocf_updates_file_removing_failed, {Node, File, Reason}),
		    exit({ocf_updates_file_removing_failed, Node, {erlang:localtime(),file:get_cwd(),Dir,BDir,File,Reason}})
	    end;
	Else ->
	    slog:event(warning, ?MODULE, ocf_updates_file_processing_failed, {Node, File, Else}),
	    exit({ocf_updates_file_processing_failed, Node, File})
    end.

%% +type regexp([string()],RegExp::string(),Result::[string()])-> [string()].
regexp([String|T],REG,Acc)->
    case regexp:match(String,REG) of
	{match,S,L}->
	    regexp(T,REG,[String | Acc]);
	E ->
	    regexp(T,REG,Acc)
    end;
regexp([],_,Acc)->
    Acc.

%% +deftype hook_state() = #hook_state{
%%   next_update_time::unix_time(),
%%   interval::millisecond()
%% }.

-record(hook_state, {next_update_time, interval}).

%% +type read_xml_file(string(), hertz()) -> {ok, int(), int()}.
%%%% Process XML RDP file

read_xml_file(FILE, Rate)->
    TimeB=pbutil:unixtime(),
    put(read,0),   %%%% client read in XML
    put(update,0), %%%% SQL update 
    put(delete,0), %%%% delete entrie in USER
    put(error,[]), %%%% list of Error to print in rapport file
    put(warning,[]),%%%% list of warning to print in rapport file
    put(no_update,[]),
    Now = pbutil:unixmtime(),
    Int = round(1000 / Rate),
    HS = #hook_state{next_update_time = Now, interval = Int},
    XML=xmerl_eventp:file(FILE,[{directory,"./"},
				{hook_fun, fun hook/2, HS},
				{acc_fun, fun acc/3},
				{validation,false}
			       ]),
    TimeE=pbutil:unixtime(),
    print_rapport(TimeE-TimeB),
    {ok, get(read), get(update)}.

%% +type read_text_file(term())-> {ok, {int(),int(),int()}}.
read_text_file(FD)->
    TimeB=pbutil:unixtime(),
    put(update,0), %%%% SQL update 
    put(delete,0), %%%% delete entrie in USER
    put(read,0),   %%%% client read in XML
    put(error,[]), %%%% list of Error to print in rapport file
    do_read_text_file(FD),
    TimeE=pbutil:unixtime(),
    print_rapport(TimeE-TimeB).

%% +type do_read_text_file(FD::term())-> ok.
do_read_text_file(FD)->
    do_read_text_file(FD,get_client(FD)).

%% +type do_read_text_file(term(), eof | client())-> ok.
do_read_text_file(FD,eof)->
    ok;
do_read_text_file(FD,#client{}=CL) ->
    do_request(CL),
    do_read_text_file(FD,get_client(FD)).

%%%%%%%%%%%%%%% DELETE ORDERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Next file ,si aucun fichier sur le noeuds on passe au noeuds suivant
%% +type do_delete([{File::string(),node()}],batch_ocf_config()) ->
%%         {ok,Delete::int()}.
do_delete([{FILE,Node}|T],#batch_ocf_config{max_delete=MAX,
					    limite_hours=E_TIME,
					    dir=DIR,
					    backup_dir=B_DIR,
					    delete=Del}=OCF)->

    case (Del>=MAX) or (time()>E_TIME) of
	true->
	    slog:event(warning,?MODULE,batch_ocf_limitation_stop,delete),
	    {ok,Del};
	false->
	    {ok,Delete} = rpc:call(Node,?MODULE,delete_users,[FILE,OCF]),
	    N_OCF=OCF#batch_ocf_config{delete=Del+Delete},
	    do_delete(T,N_OCF)
    end;
do_delete([],#batch_ocf_config{delete=Del}) ->
    {ok,Del}.

%% +type delete_users(FileName::string(),batch_ocf_config())-> 
%%      {ok, Del::int()}.
%%%% execution en local
delete_users(File,#batch_ocf_config{dir=DIR,
				    delete_regexp=FILES_REG,
				    delete=Del,
				    delete_pause=PAUSE
				   })->

    TimeB=pbutil:unixtime(),
    put(read,0),   %%%% client read in XML
    put(update,0), %%%% SQL update
    put(delete,0), %%%% delete entrie in USER
    put(error,[]), %%%% list of Error to print in rapport file
    put(warning,[]), %%%% list of warning to print in rapport file
    {ok,FD}=file:open(DIR++"/"++File,[read]),
    delete_user_in_file(FD,PAUSE),
    TimeE=pbutil:unixtime(),
    print_rapport(TimeE-TimeB),
    file:close(FD),
    ok = file:delete(DIR++"/"++File),
    {ok, get(delete)}.

%% +type delete_user_in_file(FD::term(),PAUSE::int())-> ok.
delete_user_in_file(FD,PAUSE)->
    case get_next_imsi(FD) of
	eof->
	    ok;
	IMSI ->
	    delete_imsi(IMSI),
            %% PAUSE BETWEEN DELETE (ie delete block the users base)
	    receive after PAUSE -> ok end,
	    delete_user_in_file(FD,PAUSE)
    end.

%% +type get_next_imsi(FD::term())-> IMSI::string().
get_next_imsi(FD) ->
    case file:read(FD,16) of
	{ok,Result}->
	    case string:tokens(Result,"\n") of
		[IMSI]->
		    IMSI;
		[[]]->
		    get_next_imsi(FD);
		E ->
		    slog:event(internal,?MODULE,decoding_imsi_failure,
			       {batch_rdp,E}),
		    exit(1)
	    end;
	eof ->
	    eof
    end.

%% +type print_rapport(seconds())-> {ok,{R::int(),U::int(),D::int()}}.
print_rapport(Time)->
    {Y,Mo,D}=date(),
    {H,M,S} =time(),
    Dir = pbutil:get_env(pfront_orangef,batch_dir),
    Date = pbutil:sprintf("%04d/%02d/%02d %02d:%02d:%02d", [Y,Mo,D,H,M,S]),
    ReportFN = filename:join(Dir, "rapport_batchocf.txt"),
    ErrorFN = filename:join(Dir, "error_batchocf.txt"),
    ReportUpdate = filename:join(Dir, "rapport_updatefailure.txt"),
    {ok,FD_T}=file:open(ReportFN, [append]),
    {ok,FD_E}=file:open(ErrorFN, [append]),
    {ok,FD_U}=file:open(ReportUpdate, [append]),
    Tmp=io_lib:format("~s ~ps R:~p U:~p D:~p~n",
		      [Date,
		       Time,get(read),get(update),get(delete)]),
    file:write(FD_T,Tmp),
    %% Ajouter la gestion des erreurs.
    print_error(Date,get(error),FD_E),
    print_log(Date,get(warning),FD_U),
    file:close(FD_T),
    file:close(FD_E),
    file:close(FD_U),
    {ok, {get(read),get(update),get(delete)}}.

%% print_log(Date,[{no_update,XML}|T],FD_U)->
%%     Tmp=io_lib:format("~s~n~p~n",[Date,XML]),
%%     file:write(FD_U,Tmp),
%%     print_error(Date,[],FD_U);
print_log(Date,[{no_update,XML}|T],FD_U)->
    Tmp = io_lib:format("~s~n~p~n",[Date,XML]),
    file:write(FD_U,Tmp),
    print_error(Date,T,FD_U);
print_log(_,[],_) ->
     ok.

    
    

%% client_xml(Cl) -> 
%%     Prolog = ["<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"],
%%     Data = [#xmlElement{name='ListeClient',attributes=[],
%% 			content=[Cl]}],
%%     lists:flatten(xmerl:export_simple(Data, xmerl_xml,[{prolog,Prolog}])).


%% +type print_error(date(),[term()],FD::term())-> ok.
print_error(Date,[{cannot_update_user,CMD,Reason}|T],FD)->
    Tmp=io_lib:format("~s ~p ~s ~p~n",[Date,cannot_update_user,
				       CMD,Reason]),
    file:write(FD,Tmp),
    print_error(Date,T,FD);
print_error(Date,[{sql_error_in_deletion,IMSI,Reason}|T],FD) ->
    %%Tmp=io_lib:format("~s ~p ~s ~p~n",[Date,sql_error_in_deletion,IMSI,Reason]),
    %%file:write(FD,Tmp),
    %% SB Patch don't print this
    %% IMSI can be changed or deleted before
    print_error(Date,T,FD);
print_error(Date,[{no_client_in_base,IMSI,Reason}|T],FD) ->
    Tmp=io_lib:format("~s ~p ~s ~p~n",[Date,no_client_in_base,IMSI,Reason]),
    file:write(FD,Tmp),
    print_error(Date,T,FD);
print_error(Date,[{no_client_in_base,IMSI}|T],FD) ->
    Tmp=io_lib:format("~s ~p ~s~n",[Date,no_client_in_base,IMSI]),
    file:write(FD,Tmp),
    print_error(Date,T,FD);
print_error(Date,[{insert_ofe_failed,IMSI,Err}|T],FD) ->
    Tmp=io_lib:format("~s ~p ~s ~p~n",[Date,insert_ofe_failed,IMSI,Err]),
    file:write(FD,Tmp),
    print_error(Date,T,FD);
print_error(Date,[{update_ofe_failed,{Uid,TSI},Err}|T],FD) ->
    Tmp=io_lib:format("~s ~p ~p ~p ~p~n",[Date,update_ofe_failed,Uid,TSI,Err]),
    file:write(FD,Tmp),
    print_error(Date,T,FD);
print_error(_,[],FD)->
    ok;
print_error(Date,[H|T],FD) ->
    Tmp=io_lib:format("~s ~p ~s~n",[Date,unknow_error,H]),
    file:write(FD,Tmp),
    print_error(Date,T,FD).

%%%% Event functions    
%% +type hook(XmlElement::term(), GlobalState::term()) -> {ok, term()}.
hook(#xmlElement{name='Client'}=Ret, GS)->
    #hook_state{next_update_time = Next, interval = Int} =
	xmerl_scan:hook_state(GS),
    Now = pbutil:unixmtime(),
    receive after lists:max([Next - Now, 0]) -> ok end,
    put(read,get(read)+1),
    CL=decode_client(Ret),
    do_request(CL),
    write_log(Ret),
    NHS = #hook_state{next_update_time = Next + Int, interval = Int},
    NGS = xmerl_scan:hook_state(NHS, GS),
    {ok, NGS};
hook(Ret,S) ->
    {Ret,S}.

%%%%%%%%%%%% XML DECODING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type acc(term(),[term()],term())-> {[term()],term()}.
%%%% don't accumulate xmlElement 
%%%% hook function is used to execute MAJ 
acc(ok,Acc,S)->
    {[],S};
acc(X,Acc,S)->
    {[X|Acc],S}.

write_log(#xmlElement{name='Client',
		      attributes=[#xmlAttribute{name=etatDossier,value=Val}|_],
		      content=[#xmlElement{name='AttributClient',
		       			   attributes=[Attr],content=[C]}|T]}=Ret) ->
    io:format("~p etat dossier is :~p~n",[?LINE,Val]),
    Warning = fun(X) -> 		      
		      case X of 
			  [{no_update,#client{etat_dossier=Val}}|T] -> 
			      put(warning,get(warning)++[{no_update,client_xml(Ret)}]),
			      ok;
			  Else ->
			      io:format("X is :~p~n",[Else]),
			      ok
		      end
	      end,
    lists:foreach(Warning,get(no_update));
write_log(_) ->
    ok.

client_xml(Element) -> 
    Prolog = ["<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"],
    Data = [#xmlElement{name='ListeClient',attributes=[],
			content=[Element]}],
    lists:flatten(xmerl:export_simple(Data, xmerl_xml,[{prolog,Prolog}])).


%% +type decode_client(xmlElement())-> client().
decode_client(#xmlElement{name='Client',attributes=Attr,content=Contents})->
    Cl1=decode_attribute(#client{},Attr),
    Cl2=decode_contents(Cl1,Contents),    
    Cl2.
%% +type decode_attribute(client(),[term()])-> client().
decode_attribute(CL,[#xmlAttribute{name=etatDossier,value=Val}|T])->
     CL#client{etat_dossier=Val};
decode_attribute(CL,[]) ->
    CL;
decode_attribute(CL,[H,T]) ->
    decode_attribute(CL,T).

%% +type decode_contents(client(),[term()])-> client().
decode_contents(CL,[#xmlElement{name='AttributClient',
				attributes=[Attr],content=[C]}|T])->
    CL2=update_client(CL,Attr#xmlAttribute.value,C#xmlText.value),
    decode_contents(CL2,T);
decode_contents(CL,[#xmlElement{name='AttributClient',
				attributes=[Attr],content=[]}|T])->
    CL2=update_client(CL,Attr#xmlAttribute.value,null),
    decode_contents(CL2,T);
decode_contents(CL,[]) ->
    CL;
decode_contents(CL,[H|T]) ->
    decode_contents(CL,T).

%% +type update_client(client(),string(),Val::string())-> client().
update_client(Cl,"TAC",Val)->
    case pbutil:all_digits(Val) of
	true->
	    Cl#client{tac=Val};
	_->
	    Cl
    end;
update_client(Cl,"tacUssdLevel",Val) when Val=="1";Val=="2";Val=="3";Val=="4"->
    Cl#client{level=list_to_integer(Val)};
update_client(Cl,"IMSI",Val) ->
    Cl#client{imsi=Val};
update_client(Cl,"TechnologicalSegment",Val) ->
    Cl#client{tech_seg=ocf_rdp:translate_tech_seg(Val)};


%% Cl#client.subscription is initialized by either segCo or PaiementMode (whichever comes first).
%% Then with the second value, the real subscription is defined.
update_client(Cl,"segCo",Val) ->
    NewCl = Cl#client{segCo=Val},
    case NewCl#client.subscription of
	undefined->
	    NewCl#client{subscription=Val};
	PaiementMode->
	    Sub=get_client_subscription(Val,PaiementMode),
	    NewCl#client{subscription=Sub}
    end;
update_client(Cl,"paiementMode",Val) ->
    NewCl = Cl#client{paiementMode=Val},
    case NewCl#client.subscription of
	undefined->
	    NewCl#client{subscription=Val};
	SegCo->
	    Sub=get_client_subscription(SegCo,Val),
	    NewCl#client{subscription=Sub}
    end;
update_client(Cl,"MSISDN",Val) ->
    Cl#client{msisdn=format_msisdn(Val)};
update_client(Cl,"ancienMSISDN",Val) ->
    Cl#client{old_msisdn=format_msisdn(Val)};
update_client(Cl,"ancienIMSI",Val) ->
    Cl#client{old_imsi=Val};
update_client(Cl,"State",Val) when Val=="10";Val=="60";Val=="70"->
    Cl#client{etat_dossier=Val};
update_client(Cl,Else,Val) ->
    Cl.
get_client_subscription(SegmentCode,PaiementMode)->
    case PaiementMode of 
	X when X=="OFR";X=="SCS";X=="ENT"->"dme";
	_ ->	    
            ocf_rdp:segco_to_subscription(SegmentCode)
    end.
%%%%%%%%%%% TEXT DECODING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type get_client(term())-> eof | client().
get_client(FD)-> 
    case io:get_line(FD,"\n") of
	L when list(L)->
	    L2=tokens(L,$;,[]),
	    case L2 of
		[IMSI,MSISDN,STATE,SegCO,Tac,UL,_]->
		    put(read,get(read)+1),
		    Cl = update_client(#client{},"IMSI",IMSI),
		    Cl2= update_client(Cl,"MSISDN",MSISDN),
		    Cl3= update_client(Cl2,"State",STATE),
		    Cl4= update_client(Cl3,"segCo",SegCO),
		    Cl5= update_client(Cl4,"TAC",Tac),
		    update_client(Cl5,"tacUssdLevel",UL);
		E->
		    put(error,get(error)++[{error_in_text_decoding,E}])
	    end;
	eof ->
	    eof
    end.

%% +type tokens(L::string(),Cut::integer(),[string()])-> [string()].
tokens(L,Cut,Acc) ->
    case pbutil:split_at(Cut,L) of
	{[],Rest}->
	    tokens(Rest,Cut,Acc++[undefined]);
	{El,Rest} ->
	    tokens(Rest,Cut,Acc++[El]);
	not_found->
	    Acc
    end.

%%%%%%%%%%% CHOOSE REQUEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% la modification se fait a partir de l'uid récup a partir de old_imsi 
%%%% si existant , imsi sinon 
%%%% du coup modif msisdn ou imsi se font de manière transparente
%%%% modif souscription : souscription inconnu => pas d'update soucription
%%%% 
%% +type do_request(client())-> ok.
do_request(#client{etat_dossier=ETAT_DOSSIER,imsi=IMSI}) 
when ETAT_DOSSIER=="60";
     ETAT_DOSSIER=="70" ->
    delete_imsi(IMSI),
    ok;

do_request(#client{imsi=IMSI,msisdn=MSISDN,subscription=SUB,tac=TAC,
		   level=UL}=Cl) when list(TAC),integer(UL)->
    %% update pur
    Old_imsi = Cl#client.old_imsi,
    Old_msisdn = Cl#client.old_msisdn,
    io:format("do_request/1 (Line: ~p) =>  Old imsi(~p) & old msisdn(~p)~n",[?LINE,Old_imsi,Old_msisdn]),
    Cl1 = case generate_imei(Cl) of
	      {error,ignore_client}->
		  Cl;
	      Cl_updated->
		  Cl_updated
	  end,
    update_users(Cl1);

do_request(#client{imsi=IMSI,msisdn=MSISDN,subscription=SUB,
 		   old_imsi=O_IMSI}=Cl) ->
     IMSI2 = case O_IMSI of undefined -> IMSI; _ -> O_IMSI end, 
     io:format("Old imsi :~p~n",[IMSI2]),
     case select_imei(IMSI2) of
 	{UID,IMEI}->
 	    Cl2=Cl#client{uid=UID,imei=IMEI},
 	    update_users(Cl2);
 	no_client_in_base ->
 	    ok
     end.

%% +type generate_imei(client())-> client().
generate_imei(#client{imsi=IMSI,tac=TAC,level=UL,old_imsi=O_IMSI}=Cl)->
    IMSI2 = case O_IMSI of undefined -> IMSI; _ -> O_IMSI end, 
    case select_imei(IMSI2) of
	{UID,IMEI}->
            %% cas migration old IMEI
	    Term=db:terminal_info(IMEI),
            %% gestion Nouveau format OF de l'IMEI
	    Term2 = terminal_of:info(Term),
            %% TODO possibilité de désactivé cette fonctionalité
	    USSD_LEVEL=
		case pbutil:get_env(pfront_orangef,authorized_ul_down) of
		    true->
			UL;
		    false->
			case terminal_of:ussd_level(Term2#terminal.ussdsize) of
			    Old_UL when UL<Old_UL->
				UL;
			    Old_UL->Old_UL
			end
		end,
	    IMEI2=terminal_of:imei(TAC,USSD_LEVEL),
	    Cl#client{uid=UID,imei=IMEI2};
	no_client_in_base ->
	    {error,ignore_client}
    end.

%% +type select_imei(IMSI::string()) -> {UID::integer(),IMEI::string()} |
%%                                      no_client_in_base.
select_imei(IMSI)-> 
    try db:lookup_profile({imsi,IMSI}) of
	#profile{uid=UID,imei=IMEI} ->
	    {integer_to_list(UID),IMEI};
	not_found ->
	    put(error,get(error)++[{no_client_in_base,[IMSI]}]),
	    no_client_in_base
    catch Tag:Value ->
	    slog:event(failure,?MODULE,select_imei_failed,{IMSI,{Tag,Value}}),
%%%% pb de plusiseurs entrée en base ???
%%%% return error in rapport
	    Er=get(error),
	    put(error,Er++[{no_client_in_base,IMSI,{Tag,Value}}]),
	    no_client_in_base
    end.

%%%% Now MSISDN is stored +33....
%% +type format_msisdn(string())-> string().
format_msisdn("33"++Rest)->
    "+33"++Rest.
%%%% in future we sotre msisdn in this format
%%%%format_msisdn("33"++Rest)->
%%%%    "33"++Rest.
%%%%%%%%%%%% SQL request %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% delete profile in users
%% +type delete_imsi(IMSI::string())-> ok.
delete_imsi(IMSI)->
%%%%% ordre de supression sont à présent bufferiser
    case sql_delete_imsi(IMSI) of
	{true,N} ->
	    put(delete,get(delete)+1);
	Reason ->
	    put(error,get(error)++[{sql_error_in_deletion,IMSI,Reason}])
    end.

%% +type sql_delete_imsi(IMSI::string())-> term().
sql_delete_imsi(IMSI)->
    case sql_get_uid(IMSI) of
	no_client_in_base->
	    no_client_in_base;
	UID when list(UID)->
	    case db:delete_user(list_to_integer(UID)) of
		true -> 
		    case db:delete_user_table(list_to_integer(UID),"users_orangef_extra" ,10000) of
			true -> {true,1};
			false ->{nok,delete_extra_failed}
		    end;
		false->
                    %% delete failed for users, do not delete in 
                    %% users_orangef_extra, this should be done in a retry
                    {nok,delete_failed}
	    end
    end.


sql_get_uid(IMSI)->
    try db:lookup_profile({imsi,IMSI}) of
	#profile{uid=UID} ->
	    integer_to_list(UID);
	not_found ->
	    no_client_in_base
    catch Tag:Value ->
	    slog:event(failure,?MODULE,sql_get_uid,{IMSI,{Tag,Value}}),
	    no_client_in_base
    end.

%% +type delete_old_user(integer(),integer())-> ok.
delete_old_user(Month,MAX)->
    %% no session since now-N_MONTH*31*24*3600
    Time=pbutil:unixtime()-Month*31*24*3600,
    CMD="SELECT UID FROM stats WHERE latest<'"++
	integer_to_list(Time)++"' and latest>0 limit "++integer_to_list(MAX),

    try ?SQL_Module:execute_stmt(CMD,[orangef,stats],10000) of
        {selected,_,UIDs}->
	    lists:all(fun([Uid])-> 
                              db:delete_user(list_to_integer(Uid),
                                             ["users","stats","svcprofiles",
                                              "svcprofiles_v2","users_orangef_extra"],
                                             10000) 

                      end,
		      UIDs),
	    slog:event(count,?MODULE,deleted_old_users,length(UIDs)),
	    ocfrdp_unsubscribe(UIDs);
	Else ->
	    slog:event(trace,?MODULE,no_old_users,Else),
            false
    catch Tag:Value->
	    slog:event(failure,?MODULE,failed_to_delete_old_users,{Tag,Value}),
	    false
    end.

ocfrdp_unsubscribe([])-> ok;

ocfrdp_unsubscribe([UID|Tail]) when list(UID) ->
    ocfrdp_unsubscribe([list_to_integer(UID)|Tail]);
ocfrdp_unsubscribe([UID|Tail])->
    try db:lookup_profile({uid,UID}) of
	#profile{imsi=IMSI} ->
            %% delete in OCFRDP the subscription of this mobile
	    batch_reset_imei:add(IMSI,unsubscribe),
	    ocfrdp_unsubscribe(Tail);
	not_found ->
	    ocfrdp_unsubscribe(Tail)
    catch Tag:Value ->
	    slog:event(failure,?MODULE,ocfrdp_unsubscribe,{UID,{Tag,Value}}),
	    ocfrdp_unsubscribe(Tail)
    end.

%% %% +type update_users(client())-> ok.
update_users(#client{old_imsi=O_IMSI,imsi=N_IMSI}=Cl) when list(O_IMSI)->
     %% verify if new client does not exist  
     try db:lookup_profile({imsi,N_IMSI}) of
 	#profile{uid=UID} ->
             %% don't update old profile 
             %% to avoid doublons
             %% maybe delete later ....
	     io:format("update_users/1 (Line :~p) => new imsi(~p) (found in db)~n",[?LINE,N_IMSI]),
	     slog:event(warning,?MODULE,doublons_msisdn,{O_IMSI,N_IMSI}),
	     io:format("deleting this imsi~n"),
	     clean:delete(UID),
	     io:format("OK~n"),
	     update_users(Cl#client{old_imsi=undefined});
	 not_found ->
             %% no doubons we can update users.
	     io:format("new imsi (not found in db) :~p~n",[N_IMSI]),
	     update_users(Cl#client{old_imsi=undefined})
     catch Tag:Value ->
	     slog:event(internal,?MODULE,update_user_failed,
			{O_IMSI,{Tag,Value}})
     end;

%% update_users(#client{old_imsi=O_IMSI,imsi=N_IMSI}=Cl) when list(O_IMSI)->
%%      %% verify if new client does not exist  
%%      try db:lookup_profile({imsi,N_IMSI}) of
%%  	#profile{uid=UID} ->
%%              %% don't update old profile 
%%              %% to avoid doublons
%%              %% maybe delete later ....
%%  	    io:format("new imsi (found in db) :~p~n",[N_IMSI]),
%%  	    slog:event(warning,?MODULE,doublons_msisdn,{O_IMSI,N_IMSI}),
%%  	    slog:event(count,?MODULE,delete_to_prevent_doublon,{O_IMSI,N_IMSI}),
%%  	    clean:delete(UID),
%%  	    ok;
%%  	not_found ->
%%              %% no doubons we can update users.
%%  	    io:format("new imsi (not found in db) :~p~n",[N_IMSI]),
%%  	    update_users(Cl#client{old_imsi=undefined})
%%      catch Tag:Value ->
%%  	    slog:event(internal,?MODULE,update_user_failed,
%%  		       {O_IMSI,{Tag,Value}})
%%      end;
    
update_users(#client{uid=undefined}=Cl)->
    slog:event(warning,?MODULE,no_uid_in_update_users,Cl#client.imsi),
    io:format("insert users directly into db :~p~n",[Cl#client.msisdn]),
    insert_users(Cl);

update_users(#client{old_imsi=undefined,uid=Uid}=Cl) when list(Uid) ->    
    try db:lookup_profile({uid,list_to_integer(Uid)}) of
        #profile{}=OldProfile ->
	    Old_msisdn = OldProfile#profile.msisdn,
	    Old_imsi = OldProfile#profile.imsi,
	    io:format("update_users/1 (Line :~p) => old imsi(~p) & old msisdn(~p) (found in db)~n",[?LINE,Old_imsi,Old_msisdn]),
            case update_profile(OldProfile,Cl) of
                {ok,NewProfile} ->
		    N_msisdn = NewProfile#profile.msisdn,
		    N_imsi = NewProfile#profile.imsi,
		    io:format("update_users/1 (Line :~p) => new imsi(~p) & new msisdn(~p) (to update)~n",[?LINE,N_imsi,N_msisdn]),
                    case catch update_user_int(Cl,OldProfile,NewProfile) of
                        ok -> 
			    Msisdn = NewProfile#profile.msisdn,
			    io:format("Msisdn (was updated successfully): ~p~n~n",[Msisdn]),
			    put(update,get(update)+1);
                        no_update -> ok;
                        {nok,Else} ->
                            put(error,get(error)++
                                [{cannot_update_user,Uid,Else}]);
			Error ->
                            put(error,get(error)++
                                [{cannot_update_user,Uid,Error}])

                    end;
                no_update ->
		    io:format("No-update user :~p~n~n",[Cl#client.msisdn]),
		    put(no_update,get(no_update)++[{no_update,Cl}]),
                    ok
            end;
        not_found ->
	    insert_users(Cl)
    catch Tag:Value ->
            put(error,get(error)++
                [{cannot_update_user,Uid,{Tag,Value}}])
    end,
    ok.

update_user_int(#client{uid=Uid}=Cl,
		#profile{msisdn=Msisdn}=OldProfile,
		#profile{msisdn=Msisdn}=NewProfile) ->
    io:format("~p:update_user_int/3 => msisdn(old=new): ~p~n",[?LINE,Msisdn]),
    update_user_int_do(Cl,OldProfile,NewProfile);

update_user_int(#client{uid=Uid}=Cl,
		#profile{msisdn=Old_msisdn}=OldProfile,
		#profile{msisdn=New_msisdn}=NewProfile) ->
    slog:event(warning,?MODULE,new_profile,{Cl,OldProfile,NewProfile}),
    io:format("~p:update_user_int/3 => old msisdn(~p) & new msisdn(~p)~n",[?LINE,Old_msisdn,New_msisdn]),
    %% check if a potential doublon can exist
     try db:lookup_profile({msisdn,New_msisdn}) of
	 #profile{uid=Old_Uid}=Profile ->
 	    Old_Uid_String = integer_to_list(Old_Uid),
	     New_msisdn = Profile#profile.msisdn,
	     New_imsi = Profile#profile.imsi,
	     io:format("update_user_int/1 (Line :~p) => new imsi(~p) & new msisdn(~p) (found in db)~n",[?LINE,New_imsi,New_msisdn]),     io:format("~p:update_user_int/3 => profile uid(~p) & client uid(~p)~n",[?LINE,Old_Uid_String,Uid]),
	     if (Old_Uid_String =/= Uid) ->
 		    %% Old profile found: remove it
 		    %%                    clean:delete(Uid);
 		    slog:event(count,?MODULE,delete_to_prevent_doublon,
 			       {Old_Uid,OldProfile}),
		      io:format("deleting profile uid: ~p~n",[Old_Uid]),
 		    clean:delete(Old_Uid);
	       
 	       true  ->
 		    ok
 	    end,
	     update_user_int_do(Cl,OldProfile,NewProfile);
	 not_found ->
             slog:event(trace,?MODULE,no_doublon,continue),
	     io:format("update_user_int/1 (Line :~p) => new msisdn(~p) not found in db~n",[?LINE,New_msisdn]),
             update_user_int_do(Cl,OldProfile,NewProfile);
	 Else ->
             slog:event(failure,?MODULE,unexpected_resp,[Else]),
	     {nok,Else}
     catch Tag:Value ->
	     slog:event(failure,?MODULE,unexpected_error,[{Tag,Value}]),
	     {nok,{Tag,Value}}
     end.

update_user_int_do(#client{uid=Uid}=Cl,OldProfile,NewProfile) ->    
	    try db:update_profile(NewProfile,OldProfile) of
		ok ->
		    update_user_extra(Cl),
		    %% even if extra failed, consider insertion is OK
		    ok;
		E ->
		    {nok,E}
	    catch T:V ->
		    {nok,{T,V}}
    end.

update_user_extra(#client{uid=Uid}=Cl) ->
    #client{tech_seg = TSC} = Cl,
    TSI =
	case TSC of
	    undefined ->
		?OCF_NO_FIELD;
	    _ ->
		case ocf_rdp:tech_seg_code_to_int(TSC) of
		    TSI_ when integer(TSI_)->
					TSI_;
				    not_found ->
			slog:event(warning, ?MODULE,
				   {no_such_tech_seg_code, TSC}),
			?OCF_UNKNOWN_CODE
		end
	end,
    case catch svc_util_of:update_extra(list_to_integer(Uid), TSI) of
	{'EXIT', no_update}->
	    try_to_insert_extra(list_to_integer(Uid),TSI,Cl);
	{'EXIT', {bad_response_from_db, X}} ->
	    {nok,{update_ofe_failed,{Uid,TSI},X}};
	ok ->
	    ok
    end.

update_profile(OldProfile,Cl) ->
    update_profile_fields(OldProfile,Cl,OldProfile,
			  [imsi,msisdn,subscription,imei]).

update_profile_fields(OldProfile,Cl,OldProfile,[]) ->
    no_update;
update_profile_fields(OldProfile,Cl,NewProfile,[]) ->
    {ok,NewProfile};
update_profile_fields(OldProfile,Cl,NewProfile,[H|T]) ->
    NewProfile1=opt_update_profile_field(Cl,NewProfile,H),
    update_profile_fields(OldProfile,Cl,NewProfile1,T).

opt_update_profile_field(#client{imsi=IMSI}=Cl,NewProfile,
			 imsi) when list(IMSI) ->
    NewProfile#profile{imsi=IMSI};
opt_update_profile_field(#client{msisdn=MSISDN}=Cl,NewProfile,
			 msisdn) when list(MSISDN) ->
    NewProfile#profile{msisdn=MSISDN};
opt_update_profile_field(#client{subscription=Subscription}=Cl,NewProfile,
			 subscription) when list(Subscription) ->
    NewProfile#profile{subscription=Subscription};
opt_update_profile_field(#client{imei=IMEI}=Cl,
                         #profile{terminal=Terminal}=NewProfile,
			 imei) when list(IMEI) ->
    NewProfile#profile{imei=IMEI,terminal=Terminal#terminal{imei=IMEI}};
opt_update_profile_field(_,NewProfile,_) ->
    NewProfile.

insert_users(#client{msisdn=Msisdn,imsi=Imsi}=Cl)->
    Profile = db:create_anon([{msisdn,Msisdn},{imsi,Imsi}]),
    Profile1 = db:unanon_profile(Profile),
    case db:insert_profile(Profile1) of 	
	{ok, #profile{uid=Uid}} ->
	    io:format("new imsi(~p) & new msisdn (~p) (inserted)~n~n",[Imsi,Msisdn]),
	    update_user_extra(Cl#client{uid=integer_to_list(Uid)}),
	    put(update,get(update)+1);
 	Else ->
 	    put(error,get(error)++
 		[{cannot_insert_user,{Imsi,Msisdn},Else}])
    end.

%% +type try_to_insert_extra(Uid::integer(),TSI::string(),Cl::client())-> ok.
try_to_insert_extra(Uid,TSI,Cl)->
    case is_client_in_extra_of_base(Uid) of
	true->
	    %% nothing todo
	    ok;
	false->
	    case catch svc_util_of:insert_extra(Uid, TSI) of
                {'EXIT', {bad_response_from_db, Y}} ->
                    {nok,{insert_ofe_failed,Cl#client.imsi,Y}};
                ok ->
                    ok
            end
    end.


%% +type is_client_in_extra_of_base(integer()) -> bool().
is_client_in_extra_of_base(Uid)-> 
    Query = io_lib:format("SELECT tech_segment FROM users_orangef_extra "
			  "WHERE uid = ~p",
			  [Uid]),
    Ident={uid,Uid},
    Default_Route = pbutil:get_env(pservices_orangef, users_orangef_extra_routing),
    Route=localisation_hash:build_route([Default_Route],Ident),
    case  ?SQL_Module:execute_stmt(Query,Route,10000) of
	{selected, _, [[TSI]]} ->
	    true;
	{selected, _, []} ->
	    slog:event(count, ?MODULE, user_not_in_OF_db, {uid, Uid}),
	    false;
	{selected, _, [[TSI] | _]} -> % should be impossible (uid is a key)
	    slog:event(internal, ?MODULE, several_rows_in_OF_db, {uid, Uid}),
	    true;
	X ->
	    %% by default
	    true
    end.

%% +type format([string()]) -> string().
format([H]) -> H;
format([H|T]) -> H ++ ", " ++ format(T).


%%%% SLOG INFO %%%%%%%
slog_info(count,?MODULE,deleted_old_users)->
    #slog_info{descr="Accounting of old profiles deleted.",
	       operational="For the purpose of statistics only."}.
