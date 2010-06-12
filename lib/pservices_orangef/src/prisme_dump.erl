-module(prisme_dump).
-export([init/1,handle_event/2,handle_info/2]).
-export([type_prisme_cfg/0]).   %% OMA_WEBMIN
-export([prisme_count/1,
        prisme_count/2,
        prisme_count/3,
        prisme_count/4,
        prisme_count_v1/2,
        prisme_count_v1/3]).
-export([slog_info/3]).
-include("../../oma/include/slog.hrl").
-include("../include/prisme.hrl").
-include("../../pserver/include/pserver.hrl").

-record(prisme_cfg, {nodes, listOfloginAtHostDestFile, 
		     listOfloginAtHostDestFileAdditional, version}).

-define(TEMPORARY_DUMP_DIR, "/tmp").

type_prisme_cfg() ->
    {record,"config prisme",prisme_cfg,
     [{nodes, {defval, oma:get_env(nodes), {list,nodeAtHost}},
       "Liste des noeuds o&ugrave; lancer le process. Le fichier sera "
       "g&eacute;n&eacute;r&eacute; dans le r&eacute;pertoire temporaire "
       ?TEMPORARY_DUMP_DIR++" et effac&eacute; apr&egrave;s transfert"},
      {listOfloginAtHostDestFile,
       {defval, ["cft@io0:/home/cft/prisme", "cft@io1:/home/cft/prisme"],
	{list,string}}, "Liste de LOGIN@NODE:PATH pour indiquer o&ugrave; "
       "transf&eacute;rer le fichier g&eacute;n&eacute;r&eacute;."},
      {listOfloginAtHostDestFileAdditional,
       {defval, ["cft@io0:/home/cft/kenobi", "cft@io1:/home/cft/kenobi"],
	{list,string}}, "Liste de LOGIN@NODE:PATH pour indiquer o&ugrave; "
       "transf&eacute;rer le fichier g&eacute;n&eacute;r&eacute;.~n"
       "OPTIONNEL."},
      {version,
      {defval, "prisme",
	string}, "Version des compteurs prismes prisme / IBU"}]}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init(Arg) ->
    {ok,no_state}.

handle_event({slog_period_complete,{day,1}=P},State)->
    do_by_node(P),
    {ok,State};

handle_event(Msg, State) ->
    {ok, State}.

handle_info(Msg, State) ->
    {ok, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_by_node({atom(), integer()}) -> term().
do_by_node(Periode) ->
    Nodes = (prisme_cfg())#prisme_cfg.nodes,
    case lists:member(node(), Nodes) of
	true -> do(Periode);
	false -> ok
    end.

%% +type do({atom(), integer()}) -> ok | transfert_hs.
do(Periode) ->
    case catch build_file(Periode) of
	{'EXIT', Reason} ->
	    slog:event(internal, ?MODULE, build_file_failed, Reason);
	File ->
	    transfert_and_delete_file(File)
    end.

%% +type build_file({atom(), integer()}) -> ok | transfert_hs.
build_file(Periode) ->
    Pos = pbutil:lpos(Periode,oma:get_env(ranges)),
    PrismeCounters = recup_counters(),
    {Y,M,D} = yesterday_date(),
    Dir = ?TEMPORARY_DUMP_DIR,
    Path = io_lib:format("~s/USSDSC_~w~2..0w~2..0w_01.trc", [Dir,Y,M,D]),
    {ok, FD} = file:open(Path, [append]),
    lists:foreach(fun(C) -> drop_line(Pos,FD,C) end, PrismeCounters),
    ok = file:close(FD),
    Path.

yesterday_date() ->
    {D,T} = svc_util_of:add_seconds_to_datetime(erlang:localtime(), -86400),
    D.

%% +type recup_counters() -> term().
recup_counters() ->
    AllKeys=mnesia:dirty_all_keys(slog_row),
    slog_handler:select_pattern([{count,prisme_counter,'_'}],[],AllKeys).

%% +type drop_line(RangeIndex::integer(), file_descr(), Key::integer()) ->
%%                 string().
drop_line(Pos,FD,Key) ->
    [#slog_row{op=slog_count,ranges=R}] = mnesia:dirty_read(slog_row, Key),
    {_,#slog_data{count=C}} = lists:nth(Pos, R),
    case C of
 	0 -> "";
 	_ -> 
 	    {count,prisme_counter,{Code,CounterN}} = Key,
 	    Line = "7;"++Code++";123#;"++CounterN ++";;"++ integer_to_list(C)
		++";0",
 	    io:format(FD, "~s\n", [Line])
    end.

%% +type transfert_and_delete_file(File::string()) -> ok | transfert_hs.
transfert_and_delete_file(File) ->
    #prisme_cfg{listOfloginAtHostDestFile=LAHs,
		listOfloginAtHostDestFileAdditional=LAHsOpt} = prisme_cfg(),
    case do_scp(File, LAHs) of
	ok -> slog:event(trace, ?MODULE, scp_succeed),
	      ok;
	Other1 -> 
	    slog:event(internal, ?MODULE, transfer_failed,Other1)
    end,
    case LAHsOpt of
	[] ->
	    slog:event(trace, ?MODULE, opt_empty_scp_succeed),
	    file:delete(File),
	    ok;
	_ ->
	    case do_scp(File, LAHsOpt) of
		ok -> slog:event(trace, ?MODULE, opt_scp_succeed),
		      file:delete(File),
		      ok;
		Other2 -> 
		    slog:event(internal, ?MODULE, opt_transfer_failed,Other2)
	    end
    end.

do_scp(SrcFileName,[LoginAtNodeDestFile|T])->
    %% -B batch mode and -p preserve modification times , access
    Cmd = "scp -B -p -q "++SrcFileName++" "++LoginAtNodeDestFile,
    case os:cmd(Cmd) of
	[]->
	    slog:event(trace, ?MODULE, transfer_succeed, Cmd),
	    ok;

	"Article 323-1 du code penal\nLe fait d'acceder ou de se maintenir, frauduleusement, dans tout ou partie d'un systeme de traitement automatise de donnees est puni de deux ans d'emprisonnement et de 30000 euros d'amende (150 000 euros pour les personnes morales)\n"->
	    slog:event(trace, ?MODULE, transfer_succeed, Cmd),
	    ok;

	E->
	    slog:event(failure, ?MODULE, transfer_failed, E),
	    do_scp(SrcFileName,T)
    end;
do_scp(SrcFileName,[]) ->
    transfert_hs.

%% +type prisme_cfg() -> term().
prisme_cfg() -> pbutil:get_env(pservices_orangef, prisme_cfg).

prisme_count("SCONIN") -> 
    slog:event(count, prisme_counter, {"**","SCONIN"}).

get_type(description) -> 
    "A";
get_type({subscribe, souscription}) -> 
    "M";
get_type({subscribe, validation}) ->
    "P".

%prisme_count(Session::session(),Option::atom()) ->
%    slog:event(count, prisme_counter, {CodeD,Counter}).
%prisme_count(Session::session(),Option::atom(),Action::Atom()) ->
%    slog:event(count, prisme_counter, {CodeD,Counter}).

prisme_count(Session, Option) ->
    prisme_count(Session, Option, {subscribe,validation}).

prisme_count(Session, Option, Type)
  when Type==description;Type=={subscribe, souscription};Type=={subscribe, validation}->
    Subscr = svc_util_of:get_souscription(Session), 
    CodeD = svc_spider:get_codedomaine(Session),
    case CodeD of
	"**" -> 
	    MSISDN=(Session#session.prof)#profile.msisdn,
	    slog:event(service_ko,?MODULE,unknown_codedomaine_description,
                       {MSISDN,Option});
	_->
	    ok
    end,
    Version = (prisme_cfg())#prisme_cfg.version,

    case Version of
	"IBU" -> 
	    CODE_WITH_SUB=lists:keysearch({Subscr,Option}, 2, ?LIST_OPT_CODE),
	    CODE= lists:keysearch(Option, 2, ?LIST_OPT_CODE),
	    case {CODE_WITH_SUB,CODE} of
		{{value, {no_counter,{Subscr,Option}}},_}->[];
		{{value, {Counter,{Subscr,Option}}},_}->
		    NewCounter = get_type(Type) ++ Counter,
		    slog:event(count, prisme_counter, {CodeD,NewCounter});
		{false,{value, {no_counter,Option}}}->[];
		{false,{value, {Counter,Option}}}->
		    NewCounter = get_type(Type) ++ Counter,
		    slog:event(count, prisme_counter, {CodeD,NewCounter});
		{false,false}->
		    slog:event(service_ko,?MODULE,unknown_option, {CodeD, Option})
	    end;
	_->[]
    end;

prisme_count(Session, Option, Type)->
    [].

prisme_count(Session, Option, Type, sachem)->
    Sub = svc_util_of:get_souscription(Session),
    case Sub of
        mobi->
            case svc_option_manager:state(Session, Option) of
                {NSession,not_actived}->
                    prisme_count(NSession, Option, Type);
                _->[]
            end;
        _->
            case svc_option_manager:is_subscribed(Session, Option) of
                {_, false}->
                    prisme_count(Session, Option, Type);
                _->
                    []
            end
    end.

slog_info(internal,?MODULE, build_file_failed)->
    #slog_info{descr="Could not build the file",
	       operational="Check prisme_cfg (Prisme, Meteor, IBU, Kenobi)"};
slog_info(internal,?MODULE, transfer_failed)->
    #slog_info{descr="Could not transfer the file",
	       operational="Check prisme_cfg (Prisme, Meteor, IBU, Kenobi)"};
slog_info(internal,?MODULE, opt_transfer_failed)->
    #slog_info{descr="Could not transfer the file to additional dest",
	       operational="Check prisme_cfg (Prisme, Meteor, IBU, Kenobi)"};
slog_info(service_ko,?MODULE,unknown_codedomaine_description) ->
    #slog_info{descr="Unknown Code Domain Description from Spider's answer",
	       operational="Check Spider's answer to get_codedomaine "
               "request for this MSISDN"};
slog_info(service_ko,?MODULE,unknown_option) ->
    #slog_info{descr="Unknown Option",
	       operational="Check definition of this option in "
               "record LIST_OPT_CODE in prisme.hrl"}.

prisme_count_v1(Session,Counter) ->
    CodeD = svc_spider:get_codedomaine(Session),
    slog:event(count, prisme_counter, {CodeD,Counter}).

prisme_count_v1(Session,parentChild,Montant) ->
    CodeD = svc_spider:get_codedomaine(Session),
    CODE=lists:keysearch({parentChild,Montant}, 2, ?LIST_PARENTCHILD_CODE),
    case CODE of 
	{value, {Counter,{parentChild,Montant}}} -> 
	    slog:event(count, prisme_counter, {CodeD,Counter});
	_ ->
	     exit({prisme_count_v1,?MODULE,montant_not_found,{parentChild,Montant}})
    end.
