-module(batch_reset_imei).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/db.hrl").

-export([add/2,do_reset/0,do_reset_seq/0,init/0]).
-export([do_subscribe/0,do_unsubscribe/0,do_retry/0]).
-export([unsubscribe_imsi/1]).
%% EXPLOITATION API
-export([export/1,export_dets/1,size/0,transform_table/0]).
%% TEMPORARY EXPORT
-export([match_object/2]).
-export([slog_info/3]).

-include_lib("oma/include/slog.hrl").

-define(UPDATE_TIMEOUT,5000).

%%% DETS VERSION
-define(OCF_REPAIR,ocf_repair).

%% +deftype date() = pbutil:unixtime().
%% +deftype ocf_repair() =
%%     #ocf_repair   { imsi :: string(),
%%                     type :: subscribe | get_user,
%%                     date :: pbutil:unixtime(),
%%                     error:: atom() | integer}.
%% +deftype ocf_action() = get_user | subscribe | unsubscribe.
-record(ocf_repair, {
	  imsi,
	  type,
	  date,
	  error}).


-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pdatabase/include/pdatabase.hrl").
-include("../../pdist/include/generic_router.hrl").


%% +type init() -> ok.
init()->
    {ok,_} = dets:open_file(?OCF_REPAIR,[{type,set},{keypos,2},{file,"run/ocf_repair"}]).
    

%% +type add(Imsi::string(),ocf_action())-> ok.
add("999"++_,_)-> ok; 
add(IMSI,get_user)->
    %%%% Attention les table ets sont local
    %%%% il est nécessaire d'effectuer un match sur tous les noeuds
    case match_object(IMSI,subscribe) of
	[]->
	    dets:insert(?OCF_REPAIR,[#ocf_repair{imsi=IMSI,type=get_user,
						date=pbutil:unixtime()}]);
	L when list(L)->
	    %% stay with a subscribe entry
	    %% evite de remplacer une entrée de type subscribe par un get_user
	    ok
    end;
add(IMSI,Type) when Type==subscribe;Type==unsubscribe->
    add(IMSI,Type,undefined,pbutil:unixtime()).

%% +type add(IMSI::string(),ocf_action(),pbutil:unixtime(), term())-> ok.
add(IMSI,Type,Error,Date)->
    dets:insert(ocf_repair,[#ocf_repair{imsi=IMSI,type=Type,
					date=Date,error=Error}]).
%% +type delete(string())-> ok.
delete(IMSI)->
    rpc:multicall(oma:get_env(nodes),dets,delete,[?OCF_REPAIR,IMSI]).


%% +type  match_object(IMSI::string(),ocf_action())-> [ocf_repair()].
match_object(IMSI,Type)->
    {Matchs,_}=rpc:multicall(oma:get_env(nodes),dets,match_object,[?OCF_REPAIR,
							#ocf_repair{imsi=IMSI,type=Type,date='_',
								   error='_'}]),
    R=lists:foldl(fun(Match,Total) when list(Match)->
		       [Match|Total];
		   (_,T)-> T end,[],Matchs),
    lists:append(R).

%% +type export(term())-> ok.
%%%% export all entries in a csv file (Export_type = string) or into a list (Export_type = list)
export(Export_type)->
    {Acc,_}=rpc:multicall(oma:get_env(nodes),
			  batch_reset_imei,
			  export_dets,
			  [Export_type]),
    case Export_type of
	string ->
	    {ok,Fd}=file:open("ocf_repair.csv",[write]),
	    %% filtrer les réponses : cas node down
	    Acc2 = lists:map(fun(X) when list(X)-> file:write(Fd,lists:flatten(X));
				(_)-> ok end,
			     Acc),
	    file:close(Fd),
	    ok;
	_ ->
	    Acc
    end.

%% +type export_dets(term())-> string().
export_dets(Export_type)->
    Fun = fun(X,Acc) when record(X,ocf_repair)-> export_ocf_repair(Export_type,X,Acc);
	(_,Acc)->Acc end,
    Acc = dets:foldl(Fun,[],?OCF_REPAIR),
    Acc.

-define(SEP,";").
-define(END,"\n").

%% +type export_ocf_repair(term(),ocf_repair(),string())-> [string()].
export_ocf_repair(string,#ocf_repair{imsi=IMSI,type=TYPE,date=DATE,error=ERROR},Acc)->
    pbutil:sprintf("%s"++?SEP++"%s"++?SEP++"%s"++?SEP++"%s"++?END,
		   [IMSI,atom_to_list(TYPE),format_date(DATE),format_error(ERROR)])++Acc;
export_ocf_repair(list,#ocf_repair{imsi=IMSI,type=TYPE,date=DATE,error=ERROR},Acc)->
    [[IMSI,atom_to_list(TYPE),format_date(DATE),format_error(ERROR)] | Acc].

%% +type format_date(pbutil:unixtime())-> string().
format_date(UnixTime)->
    {{Y,Mo,D},{H,Mi,S}} =
	calendar:now_to_local_time({UnixTime div 1000000,
				    UnixTime rem 1000000,0}),
    lists:flatten(pbutil:sprintf("%02d/%02d/%02d", [D,Mo,Y rem 100])).

%% +type format_error(term())-> string().
format_error(Er) when integer(Er)->
    integer_to_list(Er);
format_error(undefined)->
    "1ere execution en attente";
format_error(Er) when atom(Er)->
    atom_to_list(Er);
format_error({error,{error,timeout}})->
    %% temporary workaround 20100121, diff in pfront_orangef/ocf_rdp comited at
    %% same time should change this case into the previous
    "timeout";
format_error(Er) ->
    "unexpected:"++lists:flatten(io_lib:write(Er)).

%% +type do_reset_seq()-> [ok].
do_reset_seq()->
    lists:map(fun(Node)->
                     rpc:call(Node,?MODULE,do_reset,[])
	       end, pbutil:get_env(pserver,active_nodes)).

%% +type do_reset()-> ok.
%%%% read file reset_imei.txt and reset all imsi in this file
%%%% after move file to reset_imei.txt.old
do_reset()->
    case dets:match_object(?OCF_REPAIR,#ocf_repair{imsi='_',type=get_user,
						   date='_',error='_'}) of
	[]->
	    io:format("nothing to reset~n"),
	    ok;
	L when list(L)->
	    lists:map(fun(#ocf_repair{imsi=IMSI})->
			      reset_imei(IMSI),
			      receive after 50 -> ok end,
			      delete(IMSI) end,
		      L)
    end.

%% +type reset_imei(string())-> ok.
reset_imei(IMSI)->
    SQL_CMD=io_lib:format("update users set imei=null where imsi='~s'",
			  [IMSI]),
    case catch generic_router:routing_request(?SQL_Module,
				      #sql_query{request=SQL_CMD}, 
				      ?UPDATE_TIMEOUT,
				      [orangef,users]) of

	{ok, {updated,I}}->
	    slog:event(trace,?MODULE,reset_imei);
	Else ->
	    slog:event(failure,?MODULE,imei_not_reset,IMSI)
    end.

-define(N_DAY_RETRY_MAX,92). %% 3 mois
%% +type do_retry()-> ok.
do_retry()-> do_retry(dets:lookup(?OCF_REPAIR,dets:first(?OCF_REPAIR))).

%% +type do_retry(ocf_repair())-> ok.
do_retry([#ocf_repair{imsi=IMSI,type=get_user}=Key])->
    reset_imei(IMSI),
    delete(IMSI),
    do_retry(dets:lookup(?OCF_REPAIR,dets:next(?OCF_REPAIR,IMSI))); 
do_retry('$end_of_table') ->
    %% uniquement si table vide
    ok;
do_retry([#ocf_repair{imsi=IMSI,type=subscribe,date=Date}=Key]) ->
    Max_Diff = ?N_DAY_RETRY_MAX*24*3600, 
    case (pbutil:unixtime()-Date) > Max_Diff of
	true->
	    case is_client_actif(IMSI) of
		%% verifier si le client a effectue une session depuis 15 jours
		%% si oui supprimer le client en base et en retry
		client_actif->
		    subscribe_imsi(IMSI,Date);
		client_inactif->
		    slog:event(count,?MODULE,delete_inactif_client),
		    batch_ocfrdp:sql_delete_imsi(IMSI),
		    delete(IMSI);
		client_inconnu->
		    delete(IMSI);
		Else ->
		    slog:event(failure,?MODULE,is_client_actif,IMSI),
		    %% cant do much more...
		    ok
	    end;
	false ->
	    subscribe_imsi(IMSI,Date)
    end,
    do_retry(dets:lookup(?OCF_REPAIR,dets:next(?OCF_REPAIR,IMSI)));
do_retry([#ocf_repair{imsi=IMSI,type=unsubscribe,date=Date}=Key]) ->
    Max_Diff = ?N_DAY_RETRY_MAX*24*3600, 
    case (pbutil:unixtime()-Date) > Max_Diff of
	true->
	    %% le retry date de plus d'1 mois
	    %% On supprime le retry du client
	    delete(IMSI);
	false ->
	    unsubscribe_imsi(IMSI,Date)
    end,
    do_retry(dets:lookup(?OCF_REPAIR,dets:next(?OCF_REPAIR,IMSI)));
do_retry([])->
    ok;
do_retry(E) -> 
    slog:event(failure,?MODULE,do_retry_failed,E),
    delete(E),
    do_retry(dets:lookup(?OCF_REPAIR,dets:next(?OCF_REPAIR,E))).
    

%% +type is_client_actif(IMSI::string)-> integer().
is_client_actif(IMSI)->
    %% on recupere la date unix de la dernière session du client
    Time=pbutil:unixtime()-?N_DAY_RETRY_MAX*24*3600,
    try db:lookup_profile({imsi,IMSI}) of
	#profile{uid=UID} ->
	    try db:lookup_stats(UID) of
		{ok, #stats{latest=Latest}} when Latest>Time ->
		    client_actif;
		{ok, #stats{latest=0}} ->
		    %% unexisting entry in stats...
		    client_actif;
		{ok,_} ->
		    client_inactif
	    catch Tag1:Val1 ->
		    {error,{Tag1,Val1}}
	    end;
	not_found ->
	    client_inconnu
    catch Tag2:Val2 ->
	    {error,{Tag2,Val2}}
    end.

%% +type do_subscribe()-> ok.
%%%% read file ocf_subscribe_imsi.txt , do subscribe request X time
%%%% and update file
do_subscribe()->
    case dets:match_object(?OCF_REPAIR,#ocf_repair{imsi='_',type=subscribe,date='_',error='_'}) of
	[]->ok;
	L when list(L)->
	    lists:map(fun(#ocf_repair{imsi=IMSI,date=Date})->
			      subscribe_imsi(IMSI,Date)
		      end,
		      L)
    end.

%% +type subscribe_imsi(string(),date())-> ok.
subscribe_imsi("999"++_=IMSI,Date)->
    delete(IMSI);
subscribe_imsi(IMSI,Date) when length(IMSI) == 14 ->
    slog:event(internal, ?MODULE, subscribe_imsi_14_digits, IMSI),
    delete(IMSI);
subscribe_imsi(IMSI,Date)->
    %% nbre de tentative
    %% timeout à régler
    %% si réponse mise à jour du client
    %% sinon réinscription dans fichier SRC
    {Pause,Retentative} = pbutil:get_env(pservices_orangef,ocf_sub_reinit),
    case catch do_ocf_subscribe(IMSI,Date,Retentative) of
	subscribe_failed->
	    ok;
	{ok,#ocf_info_client{ussd_level=UL,tac=Tac,msisdn=Msisdn,
			     imsi=Imsi}}->
	    %% update client in base
	    update_client(Imsi,Msisdn,Tac,UL),
	    delete(IMSI);
	E->
	    slog:event(warning,?MODULE,batch_subscribe,E)
    end,
    %% temporiser le prochain traitement
    %% Param de config au minimum
    %% gestion auto-adaptative à voir !!
    %% si X non réponse relancer la tache dans X minutes.
    receive after Pause-> ok end.


%% +type do_ocf_subscribe(string(),date(),integer())-> 
%%     {ok,ocf_info_client()} |
%%      subscribe_failed      |
%%      term().			 
do_ocf_subscribe(IMSI,Date,X) when X>=1->
    case catch ocf_rdp:subscribeByImsi(IMSI) of
	{ok, #ocf_info_client{}=Infos}->
	    {ok,Infos};
	{error,overload}->
	     subscribe_failed;
	{error,Reason} when atom(Reason)->
	    %% limiter a timeout, not_handled, .. echec RDP
	    add(IMSI,subscribe,Reason,Date),
	    do_ocf_subscribe(IMSI,Date,X-1);
	{error, ?IMSI_UNKNOW}->
	    %% try after daily between integration in OCFRDP ...
	    add(IMSI,subscribe,imsi_unknown,Date),
	    subscribe_failed;
	{error,?MULTIPLE_SOUSCRIPTION}->
	    case catch ocf_rdp:getUserInformationByImsi(IMSI) of
		{ok, #ocf_info_client{}=Infos}->
		    {ok,Infos};	
		E->
		    %% subscribe not usefull
		    delete(IMSI),
		    add(IMSI,get_user,souscription_mult,Date),
		    E
	    end;
	{error, Cause} when integer(Cause)->
	    add(IMSI,subscribe,Cause,Date),
	    subscribe_failed;
	Else->
	    add(IMSI,subscribe,Else,Date),
	    Else
    end;
do_ocf_subscribe(IMSI,_,_)->
    subscribe_failed.

%% +type update_client(IMSI::string(),MSISDN::string(),TAC::string(),integer())->
%%      ok.
update_client(Imsi,_,Tac,UL)->
    IMEI= case pbutil:all_digits(Tac) of
	      true->
		  terminal_of:imei(Tac,UL);
	      false->
		  %% cas Tac=#NA IMEI par défaut.
		  ""
	  end,
    Req = io_lib:format("update users set imei='~s' where imsi='~s'",
			[IMEI,Imsi]),
    case catch generic_router:routing_request(?SQL_Module,#sql_query{request=Req},?UPDATE_TIMEOUT,[orangef,users]) of
	{ok, {updated,_}}->
	    slog:event(trace,?MODULE,subscribe_success),
	    ok;
	E->
	    slog:event(failure,?MODULE,imei_not_update,E) 
    end.

%% +type do_unsubscribe()-> ok.
%%%% read file ocf_subscribe_imsi.txt , do subscribe request X time
%%%% and update file
do_unsubscribe()->
    case dets:match_object(?OCF_REPAIR,#ocf_repair{imsi='_',type=unsubscribe,date='_'}) of
	[]->ok;
	L when list(L)->
	    lists:map(fun(#ocf_repair{imsi=IMSI,date=Date})->
			      unsubscribe_imsi(IMSI,Date)
		      end,
		      L)
    end.

unsubscribe_imsi(IMSI)->
    unsubscribe_imsi(IMSI,pbutil:unixtime()).

%% +type unsubscribe_imsi(string(),date())-> ok.
unsubscribe_imsi("999"++_=IMSI,Date)->
    delete(IMSI);
unsubscribe_imsi(IMSI,Date)->
    %% nbre de tentative
    %% timeout à régler
    %% si réponse mise à jour du client
    %% sinon réinscription dans fichier SRC
    {Pause,Retentative} = pbutil:get_env(pservices_orangef,ocf_sub_reinit),
    case catch do_ocf_unsubscribe(IMSI,Date,Retentative) of
	failed->
	    ok;
	ok->
	    delete(IMSI);
	E->
	    slog:event(warning,?MODULE,batch_unsubscribe,E)
    end,
    %% temporiser le prochain traitement
    %% Param de config au minimum
    %% gestion auto-adaptative à voir !!
    %% si X non réponse relancer la tache dans X minutes.
    receive after Pause-> ok end.


%% +type do_ocf_unsubscribe(string(),date(),integer())-> 
%%     {ok,ocf_info_client()} |
%%      subscribe_failed      |
%%      term().			 
do_ocf_unsubscribe(IMSI,Date,X) when X>=1->
    case catch ocf_rdp:unsubscribeByImsi(IMSI) of
	ok->
	    ok;
	{error,overload}->
	    failed;
	{error,Reason} when atom(Reason)->
	    %% limiter a timeout, not_handled, .. echec RDP
	    add(IMSI,unsubscribe,Reason,Date),
	    do_ocf_unsubscribe(IMSI,Date,X-1);
	{error, X} when X==?IMSI_UNKNOW; X==?INACTIF_USER; X==?INVALID_REQUEST->
	   %% don't try again
	    ok;
	{error, Cause} when integer(Cause)->
	    add(IMSI,unsubscribe,Cause,Date);
	Else->
	    add(IMSI,unsubscribe,Else,Date)
    end;
do_ocf_unsubscribe(IMSI,_,_)->
    failed.


%% +type size()-> integer().
%%%% retourne le nombre d'entré dans toutes les tables ocf_repair du cluster.
size()->
    {S_L,_}=rpc:multicall(oma:get_env(nodes),dets,info,[ocf_repair,size]),
    lists:foldl(fun(X,Total) when integer(X)->
		       Total+X;
		   (_,T)-> T end,0,S_L).



%%%%% transform_table
%%%% modification de toutes les entrée de la table
%%%% dans le cas d'une modification de la structure record
%% +type transform_table()-> ok.
transform_table()->
    L=dets:match_object(?OCF_REPAIR,{ocf_repair,'_','_','_'}),
    L_T=lists:map(fun({ocf_repair,IMSI,Type,Date})->
		      #ocf_repair{imsi=IMSI,type=Type,date=Date}
	      end,L),
    dets:insert(ocf_repair,L_T).
		      
slog_info(internal,?MODULE, subscribe_imsi_14_digits)->
    #slog_info{descr="IMSI subscribed have 14 digits",
               operational="Check the IMSI used to subscribe\n"}.
