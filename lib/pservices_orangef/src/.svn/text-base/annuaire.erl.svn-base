-module(annuaire).

-export([install/1]).
-export([csv2mnesia/0,csv2mnesia/1,random_mnesia/0]).

-include("../include/annuaire.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Creates annuaire table (compatibility function for production PF) 
%% +type install([atom()]) ->  ok | {error,atom()}.
install(Nodes) -> 
    TableOpts = [{ram_copies,Nodes},{type,ordered_set},
		 {attributes, record_info(fields,annuaire)}], 
    Res = (catch mnesia:create_table(annuaire,TableOpts)),
    io:format("create_table(annuaire): ~p~n", [Res]),
    WaitRes = mnesia:wait_for_tables([annuaire], 10000),
    case mnesia:table_info(annuaire,active_replicas) of
        [Node] ->
            case catch csv2mnesia() of
                ok->
                    slog:event(trace, ?MODULE, mnesia_table_created);
                Else->
                    slog:event(failure,?MODULE,create_table_error,Else)
            end;
        Nds->
            %% If more than one node is up don't re-load the table
            ok
    end.     

%%% Load current database file
%% +type csv2mnesia() -> ok | {error,atom()}. 
csv2mnesia() ->
    csv2mnesia("current").

%%% Load given file
%% +type csv2mnesia(string()) -> ok | {error,atom()}. 
csv2mnesia(FileName) -> 
    File  = code:priv_dir(pservices_orangef) ++ "/annuaire/" ++ FileName,
    FDesc = [
	     {mandatory,string},   %Name
	     {mandatory,string},   %Number
	     {mandatory,string},   %Theme
	     {optional,string}, %Heading
	     {optional,string}, %New?
	     {optional,string}, %Rules
	     {optional,string}, %Tease multi
	     {mandatory,string},   %Tease uni
	     {mandatory,string},   %Command 1
	     {optional,string}, %Key 1
	     {optional,string}, %Param 1
	     {optional,string}, %Command 2
	     {optional,string}, %Key 2
	     {optional,string}, %Param 2	
	     {optional,string}, %Command 3
	     {optional,string}, %Key 3
	     {optional,string}, %Param 3	
	     {optional,string}, %Command 4
	     {optional,string}, %Key 4
	     {optional,string}, %Param 4
	     {optional,string}, %Command 5
	     {optional,string}, %Key 5
	     {optional,string}, %Param 5
	     {optional,string}],%Selfcare

    TableHeader = pbutil:get_env(pservices_orangef,annuaire_headers),

    Opts = [{after_line,TableHeader}],
    Res  = csv_util:csv2list(File,FDesc,Opts),
    case Res of 
	{ok,CSV} ->
	    post_treat(CSV);
	{error,Else} ->
	    {error,Else}
    end.


%%% Randomize Mnesia every night (crontab)
%% +type random_mnesia() -> ok | {error,atom()}.
random_mnesia() ->
    case catch mnesia:dirty_match_object(#annuaire{_='_'}) of
	Annuaire when length(Annuaire) > 0 -> 
	    Res = put_in_mnesia(random_annuaire(Annuaire)),
	    slog:event(trace,?MODULE,random_mnesia,{result,Res}),
	    Res;
	[] ->
	    {error,random_mnesia,no_db};
	Else ->
	    Else
    end.


%%%% Randomize a list of annuaire(). 
%%%% BUT new services have to be listed first
%% +type random_annuaire([annuaire()]) -> [annuaire()].
random_annuaire(Annuaire) ->
    %% First, keep entries labelled as "new"
    SplitFun  = fun(#annuaire{new=true}=Entry,{NewEntries,OldEntries}) ->
			{[Entry| NewEntries],OldEntries};
		   (#annuaire{new=false}=Entry,{NewEntries,OldEntries}) ->
			{NewEntries,[Entry| OldEntries]}
		end,
    {NewSrvs,Remaining} =
	lists:foldl(SplitFun,{[],[]},Annuaire),

    %% move a random head of list to the tail (this is our randomize algorithm)
    Thr = random:uniform(length(Remaining)),
    {Head,Tail} = pbutil:lsplit(Thr,Remaining),
    WithoutKeys = lists:sort(NewSrvs) ++ Tail ++ Head,

    %% Last step : fill key field to use db order later
    {DB,_} = lists:foldl(fun(A,{DB,I}) -> 
				 {[A#annuaire{key=I}|DB],I+1}
			 end,{[],1},WithoutKeys),
    DB.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Post-treat CSV Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check data and format a [annuaire()]
%% +type post_treat([[term()]]) -> [annuaire()] | {error,term()}.
post_treat(Data) ->
    case catch post_treat(Data,[]) of
	{ok,Annuaire} ->
	    put_in_mnesia(random_annuaire(Annuaire));
	{'EXIT',Reason} ->
	    {error,Reason}
    end.

%% +type post_treat([[term()]],[annuaire()]) -> [annuaire()] | {error,term()}.
post_treat([[Name,Number,Theme,Head,New,Rules,TeaseM,TeaseH | Fields] =Line | 
	    Entries],Acc) ->
    MaxChars = pbutil:get_env(pservices_orangef,annuaire_maxchars),

    Theme1 = printable(Theme),
    io:fwrite("----annuaire:post_treat/2:Theme1=---~p~n",[Theme1]),
    Head1  = printable(Head),

    check_theme_heading_validity(Theme1,Head1,Rules),

    {Services,SelfCare}       = get_services(Fields,MaxChars),
    A = #annuaire{name        = lists:sublist(string:strip(Name),MaxChars),
		  number      = string:strip(Number),
		  heading     = Head1,  
		  theme       = Theme1,
		  new         = (New == "oui") orelse (New=="Oui"),
		  rules       = lists:sublist(printable(Rules),MaxChars),
		  tease_multi = lists:sublist(printable(TeaseM),MaxChars),
		  tease_head  = lists:sublist(printable(TeaseH),MaxChars),
		  services    = Services,
		  cust_care   = lists:sublist(printable(SelfCare),MaxChars)},
    post_treat(Entries,[A | Acc]);

post_treat([],Acc) ->
    {ok,lists:reverse(Acc)}.


%%%% Make it nice on handsets (a few characters to replace)
%% +type printable(string()) -> string().
printable(String) ->
    printable(string:strip(String),"").

%% +type printable(string(),string()) -> string().
printable([164 | String],Acc) -> % euro character
    printable(String,[$E | Acc]);

printable([189 | String],Acc) -> %%e dans l'o
    printable(String,[$e,$o | Acc]);

printable([$° | String],Acc) -> 
    printable(String,[$o | Acc]);

printable([$[ | String],Acc) -> 
    printable(String,[$< | Acc]);

printable([$] | String],Acc) -> 
    printable(String,[$> | Acc]);


printable([Char | String],Acc) ->
    printable(String,[Char | Acc]);

printable([],Acc) ->
    lists:reverse(string:strip(Acc,left)).


%% +type get_services([term()],integer()) -> 
%%       {[annu_service()],string()}.
get_services(Fields,MaxChars) ->
    get_services(Fields,[],MaxChars).

%% +type get_services([term()],[annu_service()],integer()) -> 
%%       {[annu_service()],string()}.
get_services([Selfcare],Acc,MaxChars) ->
    {lists:reverse(Acc),Selfcare};

get_services([Command,Key,Param | Fields],Acc,MaxChars) ->
    %% Let's make sure there is at least ONE command

    Command1 = lists:sublist(printable(Command),MaxChars),

    case Command1 of 

	%% No more services, can not happen for first one as it was mandatory
	"" ->
	    Selfcare = hd(lists:reverse(Fields)),
	    {lists:reverse(Acc),Selfcare};

	_ ->
	    Param1 = lists:sublist(printable(Param),MaxChars),
	    Key1   = lists:sublist(printable(Key),MaxChars),
	    Service = #annu_service{command = Command1,
				    key     = Key1,
				    param   = Param1},
	    get_services(Fields,[Service | Acc],MaxChars)
    end.



%%% Heading/Theme validity has not to be tested, but it's better than check
%%% it by hand
%% +type check_theme_heading_validity(string(),string(),string()) -> ok.
check_theme_heading_validity(Theme,Heading,Rules) ->
    Categories = pbutil:get_env(pservices_orangef,annuaire_categories),
    Themes   = httpd_util:key1search(Categories,Theme),
    case Themes of
        undefined ->
            exit({bad_theme,Theme});
        [] ->
            case Heading of
                "" -> 
                    ok;
                _  -> 
                    exit({heading_should_be_null,Heading})
            end;
        Smth ->
            IsConform = lists:member(Heading,Smth),
            SupLinks  = pbutil:get_env(pservices_orangef,
                                       annuaire_rules_headings),
            IsSupLink = lists:member(Heading,SupLinks),

            case {IsConform,IsSupLink,Rules} of
                {true,true,""} ->
                    exit({no_rules_for_heading,Heading});
                {true,_,_} -> 
                    ok;
                _ ->
                    exit({bad_heading_in_theme,Heading,Theme})
            end
    end.



%%%% Insert entries in mnesia table
%% +type put_in_mnesia([annuaire()]) -> ok | {error,atom()}.
put_in_mnesia(Annuaire) -> 
    Delete = fun(Key)->
		     mnesia:delete({annuaire,Key}) end, 
    Insert = fun(Entry)->
		     mnesia:write(Entry) end, 

    F = fun() -> 
		%% Delete all entries in the table inside the transaction,
		%% to avoid request on an empty table
		Keys = mnesia:all_keys(annuaire),
		lists:foreach(Delete, Keys),
		lists:foreach(Insert,Annuaire) 
	end,

    case catch mnesia:transaction(F) of
	{atomic,ok} -> 
	    slog:event(trace,?MODULE,put_in_mnesia,
		       {success,length(Annuaire),processed}),
	    ok;
	Else ->  
	    slog:event(internal,?MODULE,put_in_mnesia,{failure,Else}),
	    {error,put_in_mnesia,Else}
    end.


