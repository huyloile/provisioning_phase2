-module(rapport).

-export([import/3,start/1,calculate/2]).
-define(FILEREG,"all-1day-").
-define(FILEREG_HOUR,"all-1hour-").
-define(FILEREG2,"all_1day_").
-define(FILEREG_HOUR2,"all_1hour_").

-define(SEP_ORI,"\t").
-define(SEP_EXP,";").
-define(SEP_NUM,".").
-define(ETS_TAB,counter).
-define(STATS_DIR,"/home/clcm/orangef/of_prod/cellicium/possum/run/stats").

-define(FILTER,"compteur.csv").
-define(EXPORT,"rapport").

-record(event, {name,val_old=0,val_new=0,list=[],result=0}).
-record(counter, {regexp,name,type}).


start([Year,Month])->
    create_ets(),
    Year1=list_to_integer(Year),
    Month1=list_to_integer(Month),
    count_stats_day(Year1,Month1),
    count_stats_hourly(Year1,Month1),
    ok.

count_stats_day(Y_I,M_I)->
    Files_M_new = get_files_of_this_month(Y_I,M_I),
    Files_M_old = get_files_of_last_month(Y_I,M_I),
    io:format("get_compteur new ~n"),
    lists:map(fun(File)-> get_compteur(File,new) end, Files_M_new),
    io:format("get_compteur old ~n"),
    lists:map(fun(File)-> get_compteur(File,old) end, Files_M_old),
    io:format("finish get_compteur~n"),
    P_Y = integer_to_list(Y_I),
    P_M = print(M_I),
    io:format("rapport_interface.csv~n"),
    import(P_Y,P_M,"rapport_interface.csv"),
    io:format("d_rapport_qos.csv~n"),
    import_daily(P_Y,P_M,"d_rapport_qos.csv"),
    io:format("d_code.csv~n"),
    import_daily(P_Y,P_M,"d_code.csv"),
    io:format("finish count_stats_day~n"),
    ok.

get_files_of_this_month(Y_I,M_I)->
    M =print(M_I),
    Y =integer_to_list(Y_I),
    {Y_Next,M_Next} = month_next(Y_I,M_I),
    Files_M_new1=get_files(?STATS_DIR,lists:flatten(?FILEREG2++Y++"-"++M)),
    %% get file for first day of next month
    Files_M_new2 = Files_M_new1++get_files(?STATS_DIR,lists:flatten(?FILEREG2++Y_Next++"-"++M_Next++"-01")),
    %% delete file for first day of this month
    io:format("delete: ~p~n",[lists:flatten(?FILEREG2++Y++"-"++M++"-01")]),
    Files_M_new3 = prefix_delete(Files_M_new2,lists:flatten(?FILEREG2++Y++"-"++M++"-01"),[]),
    io:format("New :~p~n",[Files_M_new3]),
    Files_M_new3.

get_files_of_last_month(Y_I,M_I)->
    M =print(M_I),
    Y =integer_to_list(Y_I),
    {Y_Prec,M_Prec} = month_prec(Y_I,M_I),
    %% get files for last month
    Files_M_old1=get_files(?STATS_DIR,lists:flatten(?FILEREG2++Y_Prec++"-"++M_Prec)),
    %% get file for first day of this month
    Files_M_old2=Files_M_old1++get_files(?STATS_DIR,lists:flatten(?FILEREG2++Y++"-"++M++"-01")),
    %% delete file for first day of last month
    Files_M_old3 = prefix_delete(Files_M_old2,lists:flatten(?FILEREG2++Y_Prec++"-"++M_Prec++"-01"),[]),
    io:format("Old :~p~n",[Files_M_old3]),
    Files_M_old3.

count_stats_hourly(Y_I,M_I)->
    P_Y = integer_to_list(Y_I),
    P_M = print(M_I),
    ets:delete_all_objects(?ETS_TAB),
    Files_new=get_files(?STATS_DIR,lists:flatten(?FILEREG_HOUR2++P_Y++"-"++P_M)),
    lists:map(fun(File)-> get_compteur_h(File,new) end, Files_new),
    import_daily(P_Y,P_M,"d_licence.txt"),
    import_daily(P_Y,P_M,"d_prisme.txt").    

create_ets()->
    case ets:info(?ETS_TAB,size) of
	X when integer(X)->
	    ets:delete_all_objects(?ETS_TAB),
	    ok;
	_ ->
	    ets:new(?ETS_TAB,[set,named_table,{keypos,2}])
    end.

import(Year,Month,IMPORT_FILENAME)->
    io:format("~nStep 1/4 import : ~p",[IMPORT_FILENAME]),
    Acc=get_compteur_to_dump(IMPORT_FILENAME),
    io:format(" - Step 2/4"),
    STATS=regexp_count_in_ets(Acc),
    io:format(" - Step 3/4"),
    [EXPORT|T]=string:tokens(IMPORT_FILENAME,"."),
    io:format(" - Step 4/4"),
    dump_counter_in_file(STATS,EXPORT++"-"++Year++"-"++Month++".csv"),
    io:format("finish import~n"),
    ok.

%% +type month_prec(Year::integer(),Month::integer()) -> {Y::string(),M::string()}.
month_prec(Y,1)->
    {integer_to_list(Y-1),"12"};
month_prec(Y,X) ->
    {integer_to_list(Y),print(X-1)}.

%% +type month_next(Year::integer(),Month::integer()) -> {Y::string(),M::string()}.
month_next(Y,12)->
    {integer_to_list(Y+1),print(1)};
month_next(Y,X) ->
    {integer_to_list(Y),print(X+1)}.

print(X) when integer(X)->
    pbutil:sprintf("%02d",[X]).

prefix_delete([],_,Acc)->
    Acc;
prefix_delete([H|T],Prefix,Acc)->
    case lists:prefix(Prefix,H) of
	true->
	    prefix_delete(T,Prefix,Acc);
	false->
	    prefix_delete(T,Prefix,Acc++[H])
    end.

%% +type get_files(node(),FILES_REG::string(),DIR::string())->
%%        [{node(),File::string()}].
get_files(DIR,FILES_REG)->
    io:format("Files:~p/~p~n", [DIR,FILES_REG]),
    case file:list_dir(DIR) of
	{ok,Dir}->
	    %%io:format("DIR:~p~n",[Dir]),
	    lists:sort(regexp(Dir,FILES_REG,[]));
	E->
	    io:format("Error:~p~n",[E]),
	    []
    end.

regexp([String|T],REG,Acc)->
    case regexp:match(String,REG) of
	{match,S,L}->
	    regexp(T,REG,Acc++[String]);
	E ->
	    regexp(T,REG,Acc)
    end;
regexp([],_,Acc)->
    Acc.

%%%%%%%%%%%%%%%%%%%%%%% Recuperation Compteur Cas Fichier Daily %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_compteur(?FILEREG++_=File,X) when list(File)->
    {ok, FD} = file:open(?STATS_DIR++"/"++File,[read]),
    {[Y,M,D,H,_],_}=pbutil:sscanf(?FILEREG++"%04d-%02d-%02d %02d:%s",File),
    get_compteurs(FD,X,{day_prec(Y,M,D),H}),
    file:close(FD);
get_compteur(?FILEREG2++_=File,X) when list(File)->
    {ok, FD} = file:open(?STATS_DIR++"/"++File,[read]),
    {[Y,M,D,H,_],_}=pbutil:sscanf(?FILEREG2++"%04d-%02d-%02d_%02d-%s",File),
    get_compteurs(FD,X,{day_prec(Y,M,D),H}),
    file:close(FD).


get_compteur_h(?FILEREG_HOUR++_=File,X) when list(File)->
    {ok, FD} = file:open(?STATS_DIR++"/"++File,[read]),
    {[Y,M,D,H,_],_}=pbutil:sscanf(?FILEREG_HOUR++"%04d-%02d-%02d %02d:%s",File),
    get_compteurs(FD,X,{D,H}),
    file:close(FD);
get_compteur_h(?FILEREG_HOUR2++_=File,X) when list(File)->
    {ok, FD} = file:open(?STATS_DIR++"/"++File,[read]),
    {[Y,M,D,H,_],_}=pbutil:sscanf(?FILEREG_HOUR2++"%04d-%02d-%02d_%02d-%s",File),
    get_compteurs(FD,X,{D,H}),
    file:close(FD).

day_prec(Year,1,1)->
    calendar:last_day_of_the_month(Year-1, 12);
day_prec(Year,Month,1) ->
    Prec_Month = 
	case Month of
	    1->
		12;
	    M->
		M-1
	end,
    calendar:last_day_of_the_month(Year, Prec_Month);
day_prec(Y,Month,D)->
    D-1.

get_compteurs(FD,X,D)->
    case io:get_line(FD,"") of
	eof->
	    ok;
	Text->
	    T = lists:delete($\n,Text),
	    A=string:tokens(lists:flatten(T),";"),
	    filter2(A,X,D),
	    get_compteurs(FD,X,D)
    end.

filter2([Name,Val],X,D)->
    add({Name,export_val(Val)},X,D),
    %%io:format("Name:~p Count:~p~n",[Name,list_to_integer(Val)]),
    ok;
filter2([Name,Val,Min,Max],X,D) ->
     %%io:format("Name:~p:~p:~p:~p~n",[Name,Val,Min,Max]),
     add({Name,export_val(Val),Min,Max},X,D),
     %%io:format("Name:~p Avg:~p~n",[Name,list_to_float(Val)]),
     ok;
filter2(E,_,_) ->
    %%io:format("Error:~p~n",[E]),
    ok.

export_val("undefined")->
    0;
export_val(Val)->
    case catch list_to_integer(Val) of
	{'EXIT',_}->
	    list_to_float(Val);
	Val_ ->
	    Val_
    end.

add({Name,Val},old,D)->
    case ets:lookup(?ETS_TAB,Name) of
	[#event{name=Name,val_old=Val_old}=E]->
	    %%match
	    %%io:format("M:~p",[Name]),
	    %% io:format("add 1:~p ~p ~n",[Val,Val_old]),
	    ets:insert(?ETS_TAB,[E#event{val_old=Val+Val_old}]);
	_ ->
	    ets:insert(?ETS_TAB,[#event{name=Name,val_old=Val,val_new=0,list=[]}])
    end;
add({Name,Val},new,D) ->
    case ets:lookup(?ETS_TAB,Name) of
	[#event{name=Name,val_new=Val_Old,list=L}=E]->
	    %%match
	    %%io:format("add 2:~p ~p ~p~n",[Val,Val_Old,L]),
	    ets:insert(?ETS_TAB,[E#event{val_new=Val+Val_Old,list=[{D,Val}|L]}]);
	_ ->
	    ets:insert(?ETS_TAB,[#event{name=Name,val_new=Val,list=[{D,Val}]}])
    end;
add({Name,Val,Min,Max},old,D) ->
    case ets:lookup(?ETS_TAB,Name) of
	[#event{name=Name,val_old=Val_old}=E]->
	    %%match
	    %%io:format("M:~p",[Name]),
	    %% io:format("add 1:~p ~p ~n",[Val,Val_old]),
	    ets:insert(?ETS_TAB,[E#event{val_old=Val+Val_old}]);
	_ ->
	    ets:insert(?ETS_TAB,[#event{name=Name,val_old=Val,val_new=0,list=[]}])
    end;
add({Name,Val,Min,Max},new,D) ->
    case ets:lookup(?ETS_TAB,Name) of
	[#event{name=Name,val_new=Val_Old,list=L}=E]->
	    %%match
	    %%io:format("M:~p",[Name]),
	    %% io:format("add 2:~p ~p ~p ~n",[Val,Val_Old,L]),
	    ets:insert(?ETS_TAB,[E#event{val_new=Val+Val_Old,list=[{D,Val}|L]}]);
	_ ->
	    ets:insert(?ETS_TAB,[#event{name=Name,val_new=Val,list=[{D,Val}]}])
    end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type get_compteur_to_dump(string())-> [{RegExp::string(),Name::string()}].
get_compteur_to_dump(FILENAME)->
    {ok,FD}=file:open(FILENAME,[read]),
    Acc=get_regexp(FD,[]),
    file:close(FD),
    Acc.
    
get_regexp(eof,Acc)->
    Acc;
get_regexp(FD,Acc)->
    case io:get_line(FD,"") of
	eof->
	    Acc;
	[$#|T]->
	    get_regexp(FD,Acc);
	Text->
	    T = string:tokens(Text,"\n"),
	    A = string:tokens(lists:flatten(T),?SEP_EXP),
	    Acc_= acc_regexp(A,Acc),
	    get_regexp(FD,Acc_)
    end.

acc_regexp([Type,Reg,Name],Acc)->
    Acc++[#counter{regexp=Reg,name=Name,type=list_to_atom(Type)}];
acc_regexp([Reg,Name],Acc)->
    Acc++[#counter{regexp=Reg,name=Name,type=count}];
acc_regexp(_,Acc) ->
    Acc.

%% +type regexp_count_in_ets([{RegExp::string(),Name::string()}]) -> [{Name::string(),Val::integer()}].
regexp_count_in_ets(Acc)->
    L=ets:tab2list(?ETS_TAB),
    lists:map(fun(#counter{regexp=RegExp,name=Name,type=Type})->
		      R=regexp_counter(L,RegExp,Type,#event{name=Name}),
		      R#event{result=calculate(R,Type)}
	      end,Acc).

regexp_counter([#event{name=Counter,val_old=Value1,val_new=Value_new,list=L}|T],
	       REG,
	       Type,
	       #event{name=Name,val_old=V1,val_new=V2}=Acc)->
    case regexp:match(Counter,REG) of
	{match,_,_}->
	    %%io:format("test regexp1: Match~n"),
	    regexp_counter(T,REG,Type,Acc#event{name=Name,val_old=V1+Value1,val_new=V2+Value_new,
						list=L});
	E ->
	    %%io:format("test Regexp2 REG ~p:~p~n",[Counter,REG]),
	    regexp_counter(T,REG,Type,Acc)
    end;
regexp_counter([],_,_,Acc)->
    Acc.

calculate(#event{val_old=V1,val_new=V2},max) when V1>V2->
    V1;
calculate(#event{val_old=V1,val_new=V2},max)->
    V2;
calculate(#event{val_old=0,val_new=V2},count) ->
    V2;
calculate(#event{val_old=V1,val_new=V2},sum) ->
    V2+V1;
calculate(#event{val_old=V1,val_new=V2},count) ->
    trunc((V2-V1)*100/V1);
calculate(#event{list=[{_,V1}|T]=Val_List},avg) when length(Val_List)>0->
    %% cas aucune valeur précedent
    lists:foldl(fun({_,V},I_V)-> (V+I_V)/2 end, V1,T); 
calculate(#event{val_old=V1,val_new=V2},avg)->
    (V1+V2)/2;
calculate(_,avg)->
    0.
%%%%%%%%%%%%%%%%%%%%%
%% +type dump_counter_in_file([{Name::string(),Val::integer()}],File::string())-> ok.
dump_counter_in_file(DUMP_STATS,FILENAME)->
    %% open the file
    {ok,FD}=file:open(FILENAME,[write]),
    lists:foreach(fun(#event{name=Name,val_old=Val1,val_new=Val_new,result=R})->
			  io:fwrite(FD,"~s;~p;~p;~p %~n",[Name,Val_new,Val1,R]) end,
		  DUMP_STATS),
    file:close(FD).

    
%%%%%%%%%%%%%%%%%% Generate File with day pby evolution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import_daily(Year,Month,IMPORT_FILENAME)->
    io:format("Step 1/4 import_daily : ~p",[IMPORT_FILENAME]),
    Acc=get_compteur_to_dump(IMPORT_FILENAME),
    io:format(" - Step 2/4"),
    STATS=regexp_count_in_ets_daily(Acc),
    io:format(" - Step 3/4"),
    %%io:format("Result:~p~n",[STATS]),
    [EXPORT|T]=string:tokens(IMPORT_FILENAME,"."),
    io:format(" - Step 4/4"),
    dump_counter_in_file_daily(STATS,Acc,EXPORT++"-"++Year++"-"++Month++".csv"),
    io:format("finish import~n"),
    %%io:format("Liste:~p~n",[Lists]),
    %% import configuration file
    %% search and export to new file
    ok.

%% +type regexp_count_in_ets([{RegExp::string(),Name::string()}]) -> [{Name::string(),Val::integer()}].
regexp_count_in_ets_daily(Acc)->
    L=ets:tab2list(?ETS_TAB),
    lists:map(fun(#counter{regexp=RegExp,name=Name})->
		      regexp_counter_daily(L,RegExp,[])
	      end,Acc).

regexp_counter_daily([#event{name=Counter,list=L}|T],REG,Acc)->
    case regexp:match(Counter,REG) of
	{match,_,_}->
	    %%io:format("Match ~n"),
	    %L;
	    regexp_counter_daily(T,REG,Acc++L);
	E ->
	    %%io:format("nomatch ~p:~p ~p ~n",[Counter,REG,E]),
	    regexp_counter_daily(T,REG,Acc)
    end;
regexp_counter_daily([],_,Acc)->
    Acc.

dump_counter_in_file_daily(DUMP_STATS,COUNTERS,FILENAME)->
    %% open the file
    {ok,FD}=file:open(FILENAME,[write]),
    Head= lists:foldl(fun(#counter{name=Name},Acc)-> Acc++";"++Name end,"Date",COUNTERS),
    io:fwrite(FD,"~s~n",[Head]),
    prepare_value(FD,DUMP_STATS,COUNTERS),
    file:close(FD).

prepare_value(FD,List,Counters)->
    lists:map(fun(D) -> 
		      get_value_of_day(FD,D,0,List,Counters) end,
	      lists:seq(1,31)).

get_value_of_day(FD,D,Ho,L,Cs)->
    Line=get_value_of_day_count(D,Ho,L,Cs,integer_to_list(D)),
    %%io:format("Line:~p~n",[lists:flatten(Line)]),
    io:fwrite(FD,"~s~n",[lists:flatten(Line)]).

get_value_of_day_count(D,Ho,[H|T],[#counter{type=Type}|T_C],Acc)->
    Value=get_calulated_value_of_day({D,Ho},H,Type,0),
    get_value_of_day_count(D,Ho,T,T_C,Acc++";"++io_lib:format("~p",[Value]));
get_value_of_day_count(_,_,[],_,Acc) ->
    Acc.


get_calulated_value_of_day({D,Ho},[{{D,_},V}|T],Type,Val)->
    V2=compute(Val,V,Type),
    %%io:format("R:~p V1:~p V2:~p~n",[V2,V,Val]),
    get_calulated_value_of_day({D,Ho},T,Type,V2);
get_calulated_value_of_day({D,Ho},[H|T],Type,Val) ->
    get_calulated_value_of_day({D,Ho},T,Type,Val);
get_calulated_value_of_day(_,[],_,Val) ->
    Val.



compute(V1,V2,max) when V1>V2->
    V1;
compute(V1,V2,max)->
    V2;
compute(0,V2,count) ->
    V2;
compute(V1,V2,sum) ->
    V2+V1;
compute(V1,V2,count) ->
    trunc((V2-V1)*100/V1);
compute(0,V2,avg)->
    %% cas aucune valeur précedent
    V2;
compute(V1,V2,avg)->
    (V1+V2)/2.
