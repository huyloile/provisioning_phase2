-module(clean).
-include("../../pdatabase/include/mysql.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pdist/include/generic_router.hrl").
-export([launch_delete_doublons/3,
	 batch_delete_doublons/3,
         launch_delete_imsis/3,
	 batch_run/5,
	 delete/2,delete/1,delete_and_unsubscribe/1,
	 batch_update_rdp/3]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% doublons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  This function should be used to start deleting the doublons. 
%% It will run through Dir to find the files (*.txt)containing the MSISDNs that
%% have more than one IMSI. For each file a log is created in Dir/log simply 
%% changing the suffix in .log, and when done the file is moved to Dir/done/
%%  Dir is the directory where doublons list files can be found. Make sure the
%% files are not too big as a started file goes to its end. File extensions
%% should be .txt. Subdirs done/ and log/ must exist
%%  Duration is the number of seconds during which a new file can be started
%%  DeleteFrequency is the frequency of deletes 
%%     => a value of 10 means 10 deletes per second
launch_delete_doublons(Dir,DeleteFrequency,Duration) ->
    ok=filelib:ensure_dir(Dir),
    FileList = filelib:wildcard(Dir++"/*.txt"),
    launch_delete_doublons_int(FileList,DeleteFrequency,
			       pbutil:unixtime()+Duration).

launch_delete_doublons_int([],_,_) ->
    done;
launch_delete_doublons_int([Doublons_Filename | T],DeleteFrequency,End) ->
    case End < pbutil:unixtime() of
	true -> 
	    slog:event(trace,?MODULE,times_up),
	    ok;
	_ ->
	    LogFile = log_filename(Doublons_Filename),
	    batch_delete_doublons(Doublons_Filename,LogFile,DeleteFrequency),
	    case catch move(Doublons_Filename) of
                ok -> ok;
                Else -> slog:event(failure,?MODULE,could_not_move_file,
                                   {Doublons_Filename,Else})
            end,
	    launch_delete_doublons_int(T,DeleteFrequency,End)
    end.

log_filename(File) ->
    AbsName=filename:absname(File),
    case filename:extension(AbsName) of
	".log" ->
	    exit({filename_extension,AbsName});
	_ ->
	    filename:dirname(AbsName)
		++"/log/"
		++filename:rootname(filename:basename(AbsName))
		++".log"
    end.

move(File) ->
    AbsName=filename:absname(File),
    ok = file:rename(File,
		     filename:dirname(AbsName)
		     ++"/done/"
		     ++filename:basename(AbsName)).
		
    
%% +type batch_delete_doublons(Filename::string(),EL::string(),Frequency::integer())-> ok.
%%%% allow to delete oldest doublons with a flat text file.

batch_delete_doublons(Filename,LogFilename,Frequency) ->
    put(doublons_frequency,Frequency),
    {ok, FD} = file:open(LogFilename,[append]),
    put(delete_doublons_log,FD),
    log(delete_doublons_log,Filename,starttime,calendar:local_time()),
    Res = file_util:execute_by_line_ignore_err(Filename," ","\n",
					       fun do_batch_delete_doublons/1),
    log(delete_doublons_log,Filename,result,Res),
    log(delete_doublons_log,Filename,endtime,calendar:local_time()),
    file:close(FD).

%% +type do_batch_delete_doublons([string()],prov_proto()) -> ok.
do_batch_delete_doublons([Entry]) ->
    [MSISDN,IMSI,N]=string:tokens(Entry,"\t"),
    Fq = get(doublons_frequency),
    Time = trunc(1000/Fq),
    case catch get_old_doublons(MSISDN) of
	%% expected format:[{uid,imsi,msisdn}]
	[] ->     
	    log(delete_doublons_log,MSISDN,no_doublon,"");
	{error,Error} ->
	    log(delete_doublons_log,MSISDN,failed,term_to_string(Error)),
	    {nok,MSISDN};
	Doublons ->
	    log(delete_doublons_log,MSISDN,list,print(doublons,Doublons)),
	    delete(Doublons,Time)
    end.

%% find all entries for the MSISDN, remove the most recent from the list 
%%returned
get_old_doublons(MSISDN) ->
    Command = [ "SELECT since,uid,imsi,msisdn "
		"FROM users WHERE msisdn='"++MSISDN++"'" ],
    Route = localisation_hash:build_route([orangef,users], {msisdn,MSISDN}),
    case catch ?SQL_Module:execute_stmt(Command, Route, 1000) of
	{selected,_,Doublons} ->
	    remove_most_recent(Doublons);
	Else ->
	    {error,Else}
    end.
    
remove_most_recent([]) ->
    [];
remove_most_recent([H|T]) ->
    remove_most_recent(T,H,[]).
remove_most_recent([],_,Acc) ->
    Acc;
remove_most_recent([[Since,UID,IMSI,MSISDN]=H|T],
		   [SinceRef,UIDRef,IMSIRef,MSISDNRef]=Ref,
		   Acc) ->
    case list_to_integer(Since) > list_to_integer(SinceRef) of
	true ->
	    remove_most_recent(T,
			       H,
			       [{UIDRef,IMSIRef,MSISDNRef}|Acc]);
	_ ->
	    remove_most_recent(T,
			       Ref,
			       [{UID,IMSI,MSISDN}|Acc])
    end.
    
print(doublons,[]) ->
    "";
print(doublons,Doublons) ->
    print(doublons,Doublons,[]).

print(doublons,[{UID,_,_}],String) ->
    String++UID;
print(doublons,[{UID,_,_} | T ],String) ->
    print(doublons,T,String++UID++",");
print(doublons,[Else | T ],String) ->
    print(doublons,T,String++term_to_string(Else)++",").

term_to_string(Term) ->
    "FAILED:"++lists:flatten(io_lib:write(Term)).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mass deletion with delay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  This function should be used to start the mass deletion
%% It will run through Dir to find the files (*) containing the IMSIs to
%% be deleted. For each file a log is created in Dir/log simply 
%% adding a suffix in .log, and when done the file is moved to Dir/done/
%%  Dir is the directory where IMSI list files can be found. Make sure the
%% files are not too big as a started file goes to its end. 
%% IMSI file prefix 'imsis', no file extensions.
%% each line should contain one IMSI
%% Subdirs done/ and log/ must exist.
%%  Duration is the number of seconds during which a new file can be started
%%     => no new file will be started after start+Duration
%%  DeleteFrequency is the frequency of deletes 
%%     => a value of 10 means 10 deletes per second
launch_delete_imsis(Dir,DeleteFrequency,Duration) ->
    ok=filelib:ensure_dir(Dir),
    FileList = filelib:wildcard(Dir++"/imsis*"),
    launch_batch(imsis,fun do_batch_delete_imsi/1,FileList,
                 DeleteFrequency,
                 pbutil:unixtime()+Duration).

launch_batch(_,_,[],_,_) ->
    done;
launch_batch(Key,Fun,[Filename | T],DeleteFrequency,End) ->
    case End < pbutil:unixtime() of
	true -> 
	    slog:event(trace,?MODULE,times_up),
	    ok;
	_ ->
	    LogFile = log_filename(Filename),
	    batch_run(Key,Fun,Filename,
                      LogFile,DeleteFrequency),
	    case catch move(Filename) of
                ok -> ok;
                Else -> slog:event(failure,?MODULE,could_not_move_file,
                                   {Filename,Else})
            end,
	    launch_batch(Key,Fun,T,DeleteFrequency,End)
    end.

%% +type batch_run(Key::atom(),Fun::fun(),Filename::string(),
%%                 LogFilename::string(),Frequency::integer())-> ok.
%%%% allow to run Fun on each line of Filename, 
%%%% Frequency and LogFilename are stored in process dictionary with the keys
%%%%   {Key,frequency} and {Key,log}, that can be used in Fun

batch_run(Key,Fun,Filename,LogFilename,Frequency) ->
    put({Key,frequency},Frequency),
    {ok, FD} = file:open(LogFilename,[append]),
    put({Key,log},FD),
    log({Key,log},Filename,starttime,calendar:local_time()),
    Res = file_util:execute_by_line_ignore_err(Filename," ","\n", Fun),
    log({Key,log},Filename,result,Res),
    log({Key,log},Filename,endtime,calendar:local_time()),
    file:close(FD).

%% +type do_batch_delete_doublons([string()],prov_proto()) -> ok.
do_batch_delete_imsi([IMSI]) ->
    Key=imsis,
    Fq = get({Key,frequency}),
    Time = pbutil:unixmtime()+trunc(1000/Fq),
    Res = case catch get_uid(IMSI) of
	{ok,UID} ->     
            try delete(UID) of
                ok -> ok;
                Else ->
                    log({Key,log},IMSI,failed,term_to_string(Else)),
                    {nok,IMSI}
            catch Tag:Value ->
                    log({Key,log},IMSI,failed,term_to_string({Tag,Value})),
                    {nok,IMSI}
            end;
        Else ->
            log({Key,log},IMSI,failed_to_get_uid,term_to_string(Else)),
	    {nok,IMSI}
    end,
    Remains = Time - pbutil:unixmtime(),
    case Remains > 0 of
        true ->
            receive after Remains -> Res end;
        _ ->
            Res
    end.

get_uid(IMSI)->
    try db:lookup_profile({imsi,IMSI}) of
	#profile{uid=UID} ->
	    {ok,UID};
	not_found ->
	    not_found
    catch Tag:Value ->
	    {get_uid_failed,{Tag,Value}}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% update RDP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

batch_update_rdp(Filename, LogFilename,Frequency) ->
    put(rdp_frequency,Frequency),
    {ok, FD} = file:open(LogFilename,[append]),
    put(update_rdp_log,FD),
    file_util:execute_by_line_ignore_err(Filename," ","\n",fun do_batch_update_rdp/1).

%% +type do_batch_update_rdp([string()],prov_proto()) -> ok.
do_batch_update_rdp([MSISDN]) ->
    Fq = get(rdp_frequency),
    Time = trunc(1000/Fq),
    case catch update_rdp(MSISDN,Time) of
	{ok,Info} ->
	    log(update_rdp_log,MSISDN,ok,Info),
	    ok;
	{nok,Reason} ->
	    add_in_retry(MSISDN,subscribe,update_rdp),
	    log(update_rdp_log,MSISDN,error,Reason);
	Else ->
	    add_in_retry(MSISDN,subscribe,update_rdp),
	    log(update_rdp_log,MSISDN,error,Else)
    end.

update_rdp(MSISDN,Time)->
    okTODO.

add_in_retry(MSISDN,What,Why) ->
    IMSI=get_imsi(MSISDN),
    batch_reset_imei:add(IMSI,What,Why,pbutil:unixtime()).

get_imsi(MSISDN) ->
    okTODO.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% delete users
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delete(Doublons,Time) ->
    delete(Doublons,Time,[]).

delete([],Time,[]) ->
    ok;
delete([],Time,Acc) ->
    Acc;
delete([{UID,IMSI,MSISDN}|Doublons],Time,Acc) ->
    Ret = try catch delete(UID) of
	      ok -> [];
	      Else -> 
		  log(delete_doublons_log,UID,delete_uid_failed,Else),
		  [{nok,MSISDN,UID}]
	  catch Error->
	      log(delete_doublons_log,UID,delete_uid_failed,Error),
	      [{nok,MSISDN,UID}]
	  end,
    receive after Time -> ok end,
    delete(Doublons,Time,Acc++Ret).


delete_and_unsubscribe(UID) when list(UID) ->
    delete_and_unsubscribe(list_to_integer(UID));
delete_and_unsubscribe(UID) ->
    %% force badmatch to make sure it is not deleted without being unsubscribed
    %%or at least in retry table
    ok=ocfrdp_unsubscribe(integer_to_list(UID)), 
    delete(UID).

delete(UID) when list(UID) ->
    delete(list_to_integer(UID));
delete(UID) ->
    true=db:delete_user(UID,["svcprofiles","users","stats"],1000),
    db:delete_user_table(UID,"users_orangef_extra",1000),
    ok.
    
ocfrdp_unsubscribe(UID)->
    Cmd="SELECT imsi FROM users where uid='"++UID++"'",
    case catch ?SQL_Module:execute_stmt(Cmd,[users],10000) of
	{selected,_,[[IMSI]]}->
	    %% delete in OCFRDP the subscription of this mobile
	    batch_reset_imei:unsubscribe_imsi(IMSI);
	Else ->
	    {error,Else}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% log
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
log(Log,MSISDN,Info1,Info2) ->
    FD=get(Log),
    io:format(FD,"~s;~p;\"~p\"~n",[MSISDN,Info1,Info2]).
