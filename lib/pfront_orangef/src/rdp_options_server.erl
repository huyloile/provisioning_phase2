-module(rdp_options_server).

-behaviour(gen_server).

-export([start_link/1]).
-export([dump_file/1]).
-export([event/3]).
-export([do_dump_file/2, close_file/1, timer_set/2]).

-export([transfer_file/1]).

-export([init/1, handle_call/3,  handle_info/2, 
	 code_change/3, handle_cast/2, terminate/2]).

-include("../include/rdp_options.hrl").
-include("../../pfront/include/pfront.hrl").
%% +deftype state() = term().

%% Must be enough to handle periods when SCSI is busy flushing buffers.
-define(WRITE_TIMEOUT, 5000).

%%%% API
%% +type event(SRC::atom(),opt_event(),term())-> term().
event(SRV, EVT, Profile) ->
    catch gen_server:call(SRV, {event, EVT, Profile}, ?WRITE_TIMEOUT).


start_link(#interface{name_node={Name, _Node}, 
		      extra = #rdp_options_config{}=Cfg}) ->
    io:format("RDP OPTIONS starting with config ~p~nName ~p, Module ~p~n",
	      [Cfg, Name, ?MODULE]),
    gen_server:start_link({local, Name}, ?MODULE, {Name, Cfg}, []).

%% +type init({Srv_name::atom(),rdp_options_config()})->
%%  {ok , {Srv_name::atom(),rdp_options_config()}}.
init({SrvName, Config}) ->
    %% io:format("RDP OPT SERVER starting with config ~p~n", [Config]),
    File = Config#rdp_options_config.files_root,
    Size = {Config#rdp_options_config.files_size,
	    Config#rdp_options_config.files_no},
    LogName=log_name(SrvName),
    case disk_log:open([{name, LogName},
			{file, File},
			{type, wrap},
			{format, external},
			{size, Size},
			{mode, read_write},
			{head_func, {?MODULE, dump_file, [SrvName]}},
			{notify, true}]) of
	{error, Reason} ->
	    slog:event(failure, ?MODULE, unable_to_open_file, Config),
	    exit(nok);
	Else ->
	    ok
    end,
    %% if current file not empty (i.e we are recovering from a crash)
    %% -> dump file
    close_file(SrvName),
    timer_set(SrvName, Config#rdp_options_config.max_duration),
    {ok, {SrvName, Config}}.

%% +type handle_call({event,opt_event(),term()}, pid(), 
%%              {Srv_name::atom(),rdp_options_config()})-> 
%%  {reply, term(), {Srv_name::atom(),rdp_options_config()}}.
handle_call({event, #opt_event{}=OPT, _Profile}, From, {SrvName, Config}) ->
    BCDR = list_to_binary(format_event(OPT)),
    LogName = log_name(SrvName),
    Rep = disk_log:blog(LogName, BCDR),
    {reply, Rep, {SrvName, Config}}.

%% +type handle_cast(atom(),{Srv_name::atom(),rdp_options_config()})->
%%    {noreply, state()}.
handle_cast(close_file, {SrvName, Config}) ->
    close_file(SrvName),
    {noreply, {SrvName, Config}};
handle_cast(dump_file, {SrvName, Config}) ->
    do_dump_file(SrvName, Config),
    {noreply, {SrvName, Config}};
handle_cast(Request, State) ->
    {noreply, State}.

%% +type handle_info(term(),{Srv_name::atom(),rdp_options_config()})->
%%    {noreply, state()}.
handle_info(Info, State) ->
    {noreply, State}.

%% + type terminate(term(),state())-> ok.
terminate(Reason, State) ->
    ok.

%% +type code_change(integer(),state(),term())-> {ok,state()}.
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% +type timer_set(SrvName::atom(), integer())-> ok.
timer_set(SrvName, MaxDuration) ->
    unset_previous_timer(),
    {ok, Tref} = timer:apply_interval(MaxDuration, 
				      gen_server, cast,
				      [SrvName, close_file]),
    put(file_timer, Tref).

%% +type unset_previous_timer()-> ok.
unset_previous_timer() ->
    case get(file_timer) of
	undefined -> ok;
	Tref ->
	    timer:cancel(Tref)
    end.

%% +type close_file(string())-> ok.
close_file(SrvName) ->
    LogName=log_name(SrvName),
    LogInfos = disk_log:info(LogName),
    case lists:keysearch(no_current_bytes, 1 , LogInfos) of
	  {value, {no_current_bytes, 0}}->
	    %% io:format("~p: TIMER TICK: DONT CLOSE FILE: EMPTY~n", [time()]);
	    ok;
	_ ->
	    %% io:format("~p: TIMER TICK: CLOSE FILE~n", [time()]),
	    disk_log:inc_wrap_file(LogName)
    end.

%% +type do_dump_file(atom(),rdp_options_config())-> {ok,string()}.
do_dump_file(SrvName, Config) ->
    timer_set(SrvName,
	      Config#rdp_options_config.max_duration),
    LogName = log_name(SrvName),
    case disk_log:info(LogName) of
	{error, _} ->
	    %% log does not exist for the moment: we're in the middle of
	    %% creating the first file: nothing to dump
	    ok;
	LogInfos ->
	    No_MAX=Config#rdp_options_config.files_no,
	    FilePref = Config#rdp_options_config.files_root,
	    {value, {current_file, FileIndex}} = 
		lists:keysearch(current_file, 1, LogInfos),
	    FileName = FilePref++"."++integer_to_list(prec(FileIndex,No_MAX)),
	    apply(Config#rdp_options_config.transfer_fn, [FileName]),
	    slog:event(trace, ?MODULE, dump_cdr_file, {time(), FileName})
    end,
    {ok, ""}.

%%%% index 1 to No_MAX
%% +type prec(Index::integer(),No_Max::integer())-> integer().
%%%% return precedent sequence number of a file
prec(1,No_MAX)->
    No_MAX;
prec(Index,No_MAX) when Index>1->
    Index-1.

%% +type dump_file(atom())-> {ok,string()}.
%%%% This is called by disk log when opening a new file
%%%% Send msg "dump_file" to cdr_server
dump_file(SrvName) ->
    %%    io:format("In dump file~n"),
    gen_server:cast(SrvName, dump_file),
    {ok, ""}.

%% Called by cdr_server when a file is closed
%% +type transfer_file(string())-> ok.
transfer_file(FileName) ->
    Nodes = pbutil:get_env(pfront_orangef, transfert_nodes),
    DestFileName = format_dest_name(FileName),
    R=transfert_of_cra:do_transfert(FileName,Nodes,DestFileName),
    case R of
	[]->
	    %%%% no transfert 
	    ok;
	Nds->
	    transfert_of_cra:log_transfert(R,Nds,FileName,DestFileName)
    end.

%% +type format_dest_name(string())-> string().
format_dest_name(FileName)->
    DestDir = pbutil:get_env(pfront_orangef, rdp_transfer_directory),
    [Name,Seq_Number]= string:tokens(FileName,"."),
    FName=lists:last(string:tokens(Name,"/")),
    SourceFileName=filename:absname(FileName),
    {{Y,Mo,D},{H,M,S}}={date(),time()},
    Part2=pbutil:sprintf("%04d%02d%02d%02d%02d%02d",[Y,Mo,D,H,M,S]),
    DestName=io_lib:format("~s_~s.txt",[FName,Part2]),
    filename:join(DestDir, DestName).

%% +type log_name(atom())-> string().
log_name(Name) ->
    atom_to_list(Name)++"_log".


%%% Format Event
-define(SEP,";").
-define(END,"\r\n").

%% +type format_event(opt_event())-> string().
format_event(#opt_event{msisdn=MSISDN,cso=CSO,or_pos=OR_POS,
			date_activ=DATE_ACT,date_retrait=DATE_RET})->
    
    pbutil:sprintf("%s"++?SEP++"%s"++?SEP++"%s"++?SEP++"%s"++?SEP++"%s"++?END,
			  [format_msisdn(MSISDN), CSO, atom_to_list(OR_POS),
			   "",
			   ""]).

%% +type format_msisdn(string())-> string().
format_msisdn([$+|T])->
    T;
format_msisdn([$0|T]) ->
    "+33"++T;
format_msisdn(T) ->
    T.
