-module(test_clean).
-include("../../pserver/include/pserver.hrl").
-include("../../pdatabase/include/mysql.hrl").
-include("../../pdist/include/generic_router.hrl").
-compile(export_all).

online() ->
%%     test_util_of:online(?MODULE,test()).

%% test() ->
    Here="./lib/pservices_orangef/test",
    test_util_of:rset_env(pservices_orangef,ocf_sub_reinit,{1,1}),
    test_util_of:rpc(?MODULE,test_batch_delete_doublons,[Here++"/doublons"]).

test_batch_delete_doublons(Dir) ->
    N=3, %% Number of files
    %% short time, only one file should be done
    clean_data(Dir,N),
    create_data(Dir,N),
    io:format("Created:~p~n",[filelib:wildcard(Dir++"/*.txt")]),
    clean:launch_delete_doublons(Dir,1,10),
    check_remaining(Dir,N-1,N),
    delete_users(N),
    %% faster & longer time, all files should be done
    clean_data(Dir,N),
    create_data(Dir,N),
    io:format("Created:~p~n",[filelib:wildcard(Dir++"/*.txt")]),
    clean:launch_delete_doublons(Dir,10,N*15),
    check_remaining(Dir,0,N),
    delete_users(N).

create_data(Dir,N) ->
    random:seed(pbutil:unixmtime(),
		pbutil:unixutime(),
		0),
    create_files(Dir,N).

create_files(_,0) ->
    ok;
create_files(Dir,N) ->
    StartMSISDN=33600000000+N*10000,
    Created=create_doublons_data(StartMSISDN,10,4),
    File=Dir++"/doublons-test_"++integer_to_list(N)++".txt",
    dump(File,Created),
    create_files(Dir,N-1).

delete_users(0) ->
    ok;
delete_users(N) ->
    StartMSISDN=33600000000+N*10000,
    CommonPrefix=integer_to_list(round(StartMSISDN/1000)),
    Command = [ "SELECT since,uid,imsi,msisdn "
		"FROM users WHERE msisdn like '+"++CommonPrefix++"%'" ],
    Route = localisation_hash:build_route([users], {msisdn,CommonPrefix}),
    {selected,_,Doublons} = ?SQL_Module:execute_stmt(Command, Route,
						    1000),
    clean:delete(uids(Doublons),10),
    delete_users(N-1).
    
uids(Doublons) ->
    lists:map(fun([_,Uid,IMSI,MSISDN])-> {Uid,IMSI,MSISDN} end,Doublons).

clean_data(Dir,N) ->
    delete_users(N),
    filelib:fold_files(Dir,"\.txt",
		      false, %% not recursive
		      fun (F,Acc) -> 
			      case file:delete(F) of
				  ok -> Acc;
				  Else -> [Else|Acc]
			      end
		      end,
		      []),
    filelib:fold_files(Dir++"/log","\.log",
		      false, %% not recursive
		      fun (F,Acc) -> 
			      case file:delete(F) of
				  ok -> Acc;
				  Else -> [Else|Acc]
			      end
		      end,
		      []),
    filelib:fold_files(Dir++"/done","\.txt",
		      false, %% not recursive
		      fun (F,Acc) -> 
			      case file:delete(F) of
				  ok -> Acc;
				  Else -> [Else|Acc]
			      end
		      end,
		      []).
				      
			      
    
create_doublons_data(StartMSISDN,NumberMSISDN,MaxDoublons) ->
    List=make_msisdn_list(StartMSISDN,NumberMSISDN,[]),
    create_doublons(List,MaxDoublons,[]).

make_msisdn_list(_,0,Acc)->
    Acc;
make_msisdn_list(MSISDN,N,Acc)->
    MSISDNs="+"++integer_to_list(MSISDN+N),
    make_msisdn_list(MSISDN,N-1,[MSISDNs|Acc]).

create_doublons([],_,Acc) -> Acc;
create_doublons([H|T],Max,Acc) ->
    N=random:uniform(Max),
    AccPlus=create_doublons_int(H,N,[]),
    create_doublons(T,Max,AccPlus++Acc).

create_doublons_int(_,0,Acc) -> Acc;
create_doublons_int("+"++MSISDN,N,Acc) ->
    IMSI=integer_to_list(1000+N)++MSISDN,
    Profile = #profile{lang     = "fr",
		       msisdn   = "+"++MSISDN,
		       imsi     = IMSI,
		       imei     = "0",
		       subscription = "mobi",
		       barring  = []},
    {ok,#profile{uid=UID}} = db:insert_profile(Profile,1000),
    create_doublons_int("+"++MSISDN,N-1,[[UID,IMSI,"+"++MSISDN]|Acc]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% dump
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dump(File,List) ->
    slog:event(trace,?MODULE,dumping,{filename:absname(File),List}),
    {ok,FD}=file:open(File,[append]),
    dump_to(FD,List).
dump_to(FD,[]) ->
    file:close(FD);
dump_to(FD,[H|T])->
    io:format(FD,"~s\t~s\t~p~n",lists:reverse(H)),
    dump_to(FD,T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_remaining(Dir,N,Max) ->
    FileList1 = filelib:wildcard(Dir++"/*.txt"),
    N = length(FileList1),
    NDone = (Max-N),
    FileList2 = filelib:wildcard(Dir++"/done"++"/*.txt"),
    NDone = length(FileList2),
    FileList3 = filelib:wildcard(Dir++"/log"++"/*.log"),
    NDone = length(FileList3).
