-module(table_ratio_mnesia).
%% creation of the permanent table table_ratio.
-export([init_table/0]).
-export([update/0,generate_cvs_files/2,update_file/0,delete/4,write/5]).
%% service.
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-define(SEP,",").
-define(NB,60).
-define(DIR,"lib/pservices_orangef/priv/").
-define(T_FILE,"tableratio.csv").
%% +deftype tid() = pid() | atom().
%% +type init_table() -> tid().
%%
init_table() ->
    case mnesia:table_info(?RATIO,active_replicas) of
	Nds when length(Nds)<2->
	    case catch load_table() of
		ok->
		    update(),
		    slog:event(trace, ?MODULE, mnesia_table_created);
		Else->
		    slog:event(failure,?MODULE,create_table_error,Else)
	    end;
	Nds->
	    %% If one node is up don't re-load the table
	    ok
    end.     

%% +type load_table()-> ok.
load_table()->
    {ok, FD_read} =
	file:open(?DIR++?T_FILE,[read]),
    %% fisrt line is name cols.
    Tmp=io:get_line(FD_read,"\n"),
    insert_in_table(read_line(FD_read),FD_read),
    file:close(FD_read),
    ok.

%% +type insert_in_table(term(),FD::term())-> ok.
insert_in_table(end_of_file,FD_read)->
    ok;
insert_in_table({Key,Ratio},FD_read)->
    insert(#ratio{key=Key,ratio=Ratio}),
    insert_in_table(read_line(FD_read),FD_read).

%%+type delete(dcl_num(),TCP::integer(),PTF::integer(),unt_num())-> ok.
delete(DCL,TCP,PTF,UNT)->
    mnesia:dirty_delete(?RATIO,{DCL,TCP,PTF,UNT}).

%%+type delete(dcl_num(),TCP::integer(),PTF::integer(),unt_num())-> ok.
write(DCL,TCP,PTF,UNT,Ratio)->
    mnesia:dirty_write(?RATIO,#ratio{key={DCL,TCP,PTF,UNT},ratio=Ratio}).

%% +type insert(ratio())-> ok.
insert(Ratio)->
    slog:event(trace, ?MODULE, insert_ratio, Ratio),
    F = fun () -> mnesia:write(Ratio) end,
    {atomic,_} = mnesia:transaction(F),
    ok.

%%%%"DCL_NUM","TCP_NUM","PTF_NUM","UNT_GESTION",
%%%%"UNT_RESTITUTION","RATIO_CREUX"
%% +type read_line(FD::term())->
%%    end_of_file |
%%    {{dcl_num(),TCP::integer(),PTF::integer(),unt_num()},R::integer()}.
read_line(FD_read)->
    Format="%d"++?SEP++"%d"++?SEP++"%d"++?SEP++"%d"++?SEP++"%d"++?SEP
	++"%d\n",
    case io:get_line(FD_read,"\n") of
	eof->
	    end_of_file;
	L when list(L)->
	    %%io:format("L:~p~n",[L]),
	    {[DCL_N,TCP_N,PTF_N,UNT_G,UNT_R,Ratio_C]=Attributes, 
	     Rest}=pbutil:sscanf(Format,L),
	    %%io:format("Attributes:~p~n",[Attributes]),
	    {{DCL_N,TCP_N,PTF_N,UNT_R},Ratio_C}
    end.


%% +type update() -> ok | error.
update()->
    %% We update the table only if update by tlv is active
    case pbutil:get_env(pservices_orangef,update_ratio) of
	tlv->
	    update(10);
	file->
	    load_table();
	no ->
	    ok
    end.

%% +type update(integer())-> ok | error.
update(X) when X>0->
    case update_table() of
	ok->
	    ok;
	error->
	    update(X-1)
    end;
update(0)->
    error.

%% +type update_table() -> ok | error.
update_table()->
    update_table(0).
%% +type update_table(integer())-> ok | error.
update_table(I)->
    case do_request_tlv(I) of
	[200,LAST_RATIO_NUM]->
	    update_table(I+?NB);
	[0,J] ->
	    slog:event(trace,?MODULE,table_updated_by_tlv,J),
	    io:format("end of update by tlv :~p~n",[I]),
	    ok;
	[X,J] when X==99->
	    slog:event(warning,?MODULE,error_99_with_tlv_IG31_iter,X),
	    error;
	error ->
	    error
    end.


%% +type do_request_tlv(integer())-> error | [integer()].
do_request_tlv(RATIO_NUM)->
    io:format("TLV Ratio NUM:~p~n",[RATIO_NUM]),
    case catch tlv_router:mk_INT_IG31ter(all,RATIO_NUM,?NB) of
	L when list(L)->
	    decode(L,0);
	Else ->
	    slog:event(failure,?MODULE,error_with_INT_IG31ter,Else),
	    error
    end.

%% +type decode([integer()],integer())-> error | [integer()].
decode([[48,0],RATIO_NUM,DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST,RATIO|H],Ratio)->
    %%io:format("insert:~p~n",[{{DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST},RATIO}]),
    insert(#ratio{key={DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST},ratio=RATIO}),
    decode(H,RATIO_NUM);
decode([PS_STATUS,I],RATIO_NUM) ->
    io:format("~p:~p",[PS_STATUS,I]),
    [PS_STATUS,RATIO_NUM];
decode(Else,Ratio) ->
    io:format("Decode Else~p~n",[Else]),
    error.

%% +type update_file()-> ok.
%%%% erase tableratio.csv with the latest value in mnesia
update_file()->
    generate_cvs_files(?DIR,"tableratio").
%%%% generate cvs files of all ratio > tableratio.csv
%% +type generate_cvs_files(DIR::string(),REP::string())-> [ok].
generate_cvs_files(DIR,FILE)->
    {ok,FD}=file:open(DIR++FILE++".csv",[write]),
    io:format(FD,
	      "DCL_NUM"++?SEP++"TCP_NUM"++?SEP++"PTF_NUM"++?SEP++"UNT_GESTION"++?SEP++
	      "UNT_RESTITUTION"++?SEP++"RATIO_PLEIN~n",[]),
    generate_content(FD),
    file:close(FD).

%% +type generate_content(FD::term())-> ok.
generate_content(FD)->
    Elts = lists:sort(mnesia:dirty_all_keys(?RATIO)),
    write_line(Elts,FD).

%% +type write_line('end_of_table',FD::term())-> ok.
write_line([],_)->
    ok;
write_line([Key|T],FD)->
    [#ratio{key={DCL,TCP,PTF,UNT},ratio=RATIO}]=mnesia:dirty_read({?RATIO, Key}),
    io:format(FD,"~p"++?SEP++"~p"++?SEP++"~p"++?SEP++"1"++?SEP++"~p"++?SEP++"~p\n",
	       [DCL,TCP,PTF,UNT,RATIO]),
    write_line(T,FD).
