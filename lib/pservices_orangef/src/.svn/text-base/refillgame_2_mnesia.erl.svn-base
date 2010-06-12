-module(refillgame_2_mnesia).

-export([csv_2_mnesia/4]).

-include("../include/ftmtlv.hrl").

%%% table must have been created (make install-devel) %%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Load special file
%% +type csv_2_mnesia(string()) -> ok | {error,atom(),string()}. 
csv_2_mnesia(RecordName, FileName, After_line, Separator) ->
    io:format("FileName : ~p~n",[FileName]),
    BasePath = code:priv_dir(pservices_orangef) ++ "/one2one/",
    io:format("BasePasth : ~p~n",[BasePath]),
    {ok, Tab} = case RecordName of
		    ?REFILL_GAME ->
			csv_util:csv2list(
			  BasePath ++ FileName,
			  [{mandatory,string},{unique,string},{mandatory,string},
			   {mandatory,string},{mandatory,string}],[{after_line,After_line},{separator,Separator}]);
		    ?LOGO_TABLE ->
			csv_util:csv2list(
			  BasePath ++ FileName,
			  [{mandatory,string},{unique,string},{mandatory,string}],
			  [{after_line,After_line},{separator,Separator}])
		end,

    case Tab of
	[_ |_] ->
	    io:format("Moving Ahead ! ~p~n",[Tab]),
	    put_in_mnesia(RecordName,put_in_record(RecordName, Tab));
	[] ->
	    {error,csv_2_mnesia,"no_data_in_csv"};
	Else ->
	    Else
    end.

%% +type put_in_record(record(),[[string()|string()|string()]]) -> [record_fields()].
put_in_record(?REFILL_GAME, Tab) ->
    Line2Record =
	fun(Line) ->
		#refill_game{winnings_date  = list_to_integer(lists:nth(2,Line)),
			     winnings       = list_to_atom(lists:nth(3,Line)), 
			     winnings_state = list_to_atom(lists:nth(4,Line)),
			     winning_msisdn = list_to_atom(lists:nth(5,Line))}
	end,
    lists:map(Line2Record,Tab);

put_in_record(?LOGO_TABLE, Tab) ->
    Line2Record =
	fun(Line) ->
		#logo_table{winnings_date  = list_to_integer(lists:nth(2,Line)),
			    daily_winnings_nb = list_to_integer(lists:nth(3,Line))}
	end,
    lists:map(Line2Record,Tab).


%%%% Insert entries in mnesia table
%% +type put_in_mnesia([refillgame_fields()]) -> ok | {error,atom(),term()}.
put_in_mnesia(RecordName, Refillgame_fields) -> 
    Delete = fun(Entry)->
		     slog:event(trace,?MODULE,
		      list_to_atom("delete_" ++
				   atom_to_list(RecordName)++
				   "_fields"),Entry),
		     mnesia:delete_object(Entry) end, 
    Insert = fun(Entry)->
		     slog:event(trace,?MODULE, 
		      list_to_atom("insert_"++
				   atom_to_list(RecordName)++
				   "_fields"),Entry),
		     mnesia:write(Entry) end, 

    F = fun() -> 
		%% Delete all entries in the table inside the transaction,
		%% to avoid request on an empty table
		All = mnesia:match_object(recordname(RecordName)),
		lists:foreach(Delete,All),
		lists:foreach(Insert,Refillgame_fields) 
	end,

    case catch mnesia:transaction(F) of
	{atomic,ok} -> 
	    slog:event(trace,?MODULE,put_in_mnesia,
		       {success,length(Refillgame_fields),processed}),
	    ok;
	Else ->  
	    slog:event(error,?MODULE,put_in_mnesia,{failure,Else}),
	    {error,put_in_mnesia,Else}
    end.

%%% transform record to match condition
%% +type recordname(Recordname::string()) -> Recordname::record().
recordname(RecordName) 
  when RecordName == ?REFILL_GAME ->
    #?REFILL_GAME{_='_'};
recordname(RecordName)
  when RecordName == ?LOGO_TABLE ->
    #?LOGO_TABLE{_='_'}.    
