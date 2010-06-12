%% This module is very similar to oma_webmin/src/webmin_stats (dec 2007)
%% It is specific to Orange France platform
%% and uses the parameter webmin_orangef::stats_views_of

-module(webmin_of_stats).
-export([show/2, autorefresh/2]).

-include("../../oma_webmin/include/webmin.hrl").
-include("../../oma/include/slog.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(TABLE, slog_row).

%% -define(RESET, "Reset selected counters").
%% -define(RESET_ALL, "Reset all counters").

%% Interface use to print all tasks defined in crontab
-include("../../pservices_orangef/include/ftmtlv.hrl").

show(HTTP_Env, Input) ->
    Data = "<a href=./webmin_of_stats:autorefresh>Start Auto Refresh</a><br/>",
    print_stats(HTTP_Env, Input, "", Data, show).

%% +type autorefresh(http_env(), string()) -> html().

autorefresh(HTTP_Env, Input) ->
    {ok,Period} = application:get_env(webmin_orangef, stats_refresh_period_of),
    Data = 
	["<font size=-1>Statistics are refreshed every",
	 io_lib:format(" ~p seconds",[Period]),"</font><br>\n",
	 "<a href=./webmin_of_stats:show>Stop Auto Refresh</a><br/>"],
    Meta = io_lib:format("<meta http-equiv='refresh' content='~p'>",[Period]), 
    print_stats(HTTP_Env, Input, Meta, Data, refresh).

%% +type print_stats(http_env(), string(), string(), string(), atom()) -> html().

print_stats(HTTP_Env, Input, Meta, Data, Type) ->
    Vars = webmin:parse_input(Input),
    {ViewName, Keys} = select_keys(Vars),
    Table = make_table(HTTP_Env, ro, Keys),
    webmin:html_css
      ("Counters and statistics - Orange France", Meta,
       [ Data, "Views: ", link_views(ViewName, Type),
	 "<p>",
	 "First line: Latest completed interval (ending at the timestamp).",
	 "<br>",
	 "Second line: Current interval (started at the timestamp).<br>",
	 "<hr>",
	 Table, 
	 "</form>"
	]).

%% +type select_keys([{string(),string()}]) -> {View::string() ,Key}.

select_keys(Vars) ->
    AllKeys = mnesia:dirty_all_keys(?TABLE), %% This function returns a list of all keys in the table named Tab : slog_row
    {ViewName, IncludePat, ExcludePat} =
	case lists:keysearch("view", 1, Vars) of
	    {value, {_,ViewName_}} ->
		%% Show only keys from a named list.
		{ok,Views}= application:get_env(webmin_orangef, stats_views_of),
		case lists:keysearch(ViewName_, 1, Views) of
		    {value, View} -> View;
		    false         -> exit({unknown_stats_view, ViewName_})
		end;
	    false ->
		%% Default: Use the first view.
		{ok,[View|_]}= application:get_env(webmin_orangef, stats_views_of),
		View
	end,
    Keys = slog_handler:select_pattern(IncludePat, ExcludePat, AllKeys),
    {ViewName, lists:sort(Keys)}.

%% +type link_views(string(), atom()) -> string().

link_views(CurrentView, Type) ->
    BaseURL = stats_url(Type),
    F = fun ({ViewName, IncludePattern, ExcludePattern}) ->
		case ViewName == CurrentView of
		    true  -> io_lib:format(" [~s]", [ViewName]);
		    false -> io_lib:format(" <a href=~s?view=~s>~s</a>",
					   [BaseURL, ViewName, ViewName])
		end
	end,
    {ok,Views}= application:get_env(webmin_orangef, stats_views_of),
    lists:map(F, Views).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_stats_table(HTTP_Env, RWFlag, Pred) ->
    AllKeys = mnesia:dirty_all_keys(?TABLE),
    Keys = lists:filter(Pred, lists:sort(AllKeys)),
    make_table(HTTP_Env, RWFlag, Keys).

make_table(HTTP_Env, RWFlag, Keys) ->
    StatsHTML = lists:map(fun (K) -> show_stat(RWFlag, K) end, Keys),
    [ "<table>",
      "<tr align=center>",
      %% Optional "select" checkbox
      case RWFlag of rw -> " <th>&nbsp;</th>"; ro -> "" end,
      " <th>Interval<br>Timestamp</th>",
      lists:map(fun show_column/1, oma:get_env(ranges)),
      "</tr>",
      StatsHTML,
      "</table>" 
     ].

show_column(P) ->
    Label = case get({time_complete,P}) of
		undefined -> "-";
		T -> webmin:format_unixtime_loc(T)
	    end,
    io_lib:format("<th>~p<br>~s</th>", [P, Label]).

show_stat(RWFlag, Key) ->
    case mnesia:dirty_read(?TABLE, Key) of
	[Stat] -> show_stat(RWFlag, Stat, Key);
	_ -> []
    end.

show_stat(RWFlag, Row, {_,global,CounterName}) ->
    %% Hide {class,module}, print only the name.
    show_stat(RWFlag, Row, CounterName);

show_stat(RWFlag, #slog_row{key=Key, op=Op, ranges=Ranges}, CounterName) ->
    [ "<tr>",
      case RWFlag of
	  rw -> KeyS = lists:flatten(io_lib:write(Key)),
		[ "<td><input type=checkbox name=select value=\"",
		  webmin:esc_pcdata(KeyS), "\"></td>" ];
	  ro -> ""
      end,
      "<td><b>", io_lib:format("~p", [CounterName]), "</b><br><i>",
      case Op of
	  slog_count -> "freq (count)";
	  slog_sum -> "rate (total)";
	  slog_avg -> "avg";
	  slog_stats -> "avg stddev [min,max]";
	  _ -> "?"
      end, 
      "</i></td>",
      show_ranges(Op, Ranges, oma:get_env(ranges)),
      "</tr>"
     ].

%% +type show_ranges(atom(), [{slog_data(),slog_data()}], [period()]) ->
%%     html().

show_ranges(Op, [{Current,Latest}|Ranges], [P|Defs]) ->
    %% Here we are overwriting {time_complete,P} once per row,
    %% hoping that all values are the same.
    DumpDate = Latest#slog_data.time,
    case get({time_complete,P}) of
	undefined -> put({time_complete,P}, DumpDate);
	DumpDate -> ok;
	X -> io:format("*** mismatched_dump_dates ~p ~p~n", [DumpDate,X])
    end,
    [ "<td>",show_data(Op,Latest),"<br><b>",show_data(Op,Current),"</b></td>"
      | show_ranges(Op, Ranges, Defs) ];
show_ranges(Op, Ranges, Defs) ->
    [].

%% +type show_data(atom(), slog_data()) -> html().

show_data(slog_count, #slog_data{count=C, rate=R}) ->
    io_lib:format("~s (~p)", [format_num(R), C]);
show_data(slog_sum, #slog_data{sum=S, rate=R}) ->
    io_lib:format("~s (~p)", [format_num(R), S]);
show_data(slog_avg, #slog_data{avg=A}) ->
    io_lib:format("~s", [format_num(A)]);
show_data(slog_stats, #slog_data{min=Min, max=Max, avg=A, stddev=D}) ->
    io_lib:format("~s ~s [~s,~s]", [ format_num(A), format_num(D),
				     format_num(Min), format_num(Max) ]);
show_data(_, _) ->
    "?".

format_num(undefined) -> "?";
format_num(X) when integer(X) -> io_lib:format("~p", [X]);
format_num(X) when X < 0.0 -> "-"++format_num(-X);
format_num(0.0) -> "0";
format_num(X) when X >= 1000.0 -> io_lib:format("~p~n", [X]);
format_num(X) when X >= 10.0 -> io_lib:format("~.1f~n", [X]);
format_num(X) when X >= 0.01 -> io_lib:format("~.2f~n", [X]);
format_num(X) -> io_lib:format("~.2g~n", [X]).

%% +type stats_url(atom()) -> string().
stats_url(show) ->    "./webmin_of_stats:show";
stats_url(refresh) -> "./webmin_of_stats:autorefresh".
