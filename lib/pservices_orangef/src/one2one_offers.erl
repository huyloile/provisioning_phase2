-module(one2one_offers).

-export([csv2mnesia/0,csv2mnesia/1]).

-include("../include/one2one.hrl").

-define(LASTTABLEHEADER,"\"Code").


%%% table must have been created (make install-devel) %%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Load current database file
%% +type csv2mnesia() -> ok | {error,atom()}. 
csv2mnesia() ->
    csv2mnesia("oto_last.csv").

%%% Load special file
%% +type csv2mnesia(string()) -> ok | {error,atom(),string()}. 
csv2mnesia(FileName) -> 
    BasePath = code:priv_dir(pservices_orangef) ++ "/one2one/",
    slog:event(trace, ?MODULE, csv2mnesia, 
	       [{filename, FileName}, {basepath, BasePath}]),
    {ok, Tab} = csv_util:csv2list(
		  BasePath ++ FileName, 
		  [{unique,string},{mandatory,string},{mandatory,string},
		   {optional,term}], 
		  [{after_line,"Code"}]),
    case Tab of
	[_ |_] ->
	    slog:event(trace, ?MODULE, csv2mnesia, {put_in_mnesia, Tab}),  
	    put_in_mnesia(put_in_record(Tab));
	[] ->
	    slog:event(failure,?MODULE, csv2mnesia, "no_data_in_csv"),
	    {error,csv2mnesia,"no_data_in_csv"};
	Else ->
	    slog:event(failure,?MODULE, csv2mnesia, Else),
	    Else
    end.

%% +type put_in_record([[integer()|atom()|string()]]) -> [one2one_offer()].
put_in_record(Tab) ->
    Line2Record = 
	fun(Line) ->
		#?ONE2ONE_OFFER{code       = lists:nth(1,Line),
				short_desc = gsmcharset:iso2ud(lists:nth(2,Line),ascii), 
				long_desc  = gsmcharset:iso2ud(lists:nth(3,Line),ascii),
				labels     = lists:nth(4,Line)}
	end,
    lists:map(Line2Record,Tab).


%%%% Insert entries in mnesia table
%% +type put_in_mnesia([one2one_offer()]) -> ok | {error,atom(),term()}.
put_in_mnesia(One2one_offer) -> 
    Delete = fun(Entry)->
		     slog:event(trace,?MODULE,delete_o2o_offer,Entry),
		     mnesia:delete_object(Entry) end, 
    Insert = fun(Entry)->
		     slog:event(trace,?MODULE,insert_o2o_offer,Entry),
		     mnesia:write(Entry) end, 

    F = fun() -> 
		%% Delete all entries in the table inside the transaction,
		%% to avoid request on an empty table
		All = mnesia:match_object(#?ONE2ONE_OFFER{_='_'}),
		lists:foreach(Delete,All),
		lists:foreach(Insert,One2one_offer) 
	end,

    case catch mnesia:transaction(F) of
	{atomic,ok} -> 
	    slog:event(trace,?MODULE,put_in_mnesia,
		       {success,length(One2one_offer),processed}),
	    ok;
	Else ->  
	    slog:event(failure,?MODULE,put_in_mnesia,Else),
	    {error,put_in_mnesia,Else}
    end.

