-module(webuser_stats_orangef).

-export([show/2, stats_result/2]).

-define(STATS_PER_PAGE, 6).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Statistics Pages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Query Page
%% +type show(http_env(), string()) -> html().
show(Env,Input) ->
    case webuser_util:get_args(["modify_tag"], Input) of
        missing_arg ->
            webuser_orangef:send_code(argument_error);
        [Tag] ->
            {Time_B,Time_E} = webuser_orangef:compute_begin_and_end_dates(),
            Time_Begin_Options =
                lists:map(fun webuser_search_orangef:print_date_list/1,Time_B),
            Time_End_Options =
                lists:map(fun webuser_search_orangef:print_date_list/1,Time_E),
            Content =
                [
                 webuser_orangef:top_buttons_bar_full(Tag),
                 "<p class=\"search_title\">",
                 webuser_msgs:text(statistics),"</p>\n",
                 "<table class=\"sessions\" >",
                 "<tr class=\"sessions_header\">\n",
                 stats_tab_header(),"<td></td></tr>\n",
                 stats_tab_body(Tag, Time_Begin_Options,Time_End_Options)
                ],
            webuser_orangef:html(Content)
    end.


%% +type stats_result(http_env(), string()) -> html().
stats_result(Env,Input) ->
    Per_day = case webuser_util:get_args(["per_day"], Input) of
                  ["Y"] -> true;
                  _ -> false
              end,
    Content =
        case webuser_util:get_args(["page", "tag", "type",
                                    "time_beg","time_end"],Input) of
            [Page, Tag, "consultations_num", Time_B,Time_E] when not Per_day ->
                [webuser_orangef:top_buttons_bar_full(Tag),
                 stats_result_page_consultations(Time_B,Time_E)];
            [Page, Tag, "consultations_num",Time_B,Time_E]=Args when Per_day ->
                [webuser_orangef:top_buttons_bar_full(Tag),
                 stats_result_page_consultations_per_day(Args)];
            [Page, Tag, "users_num",Time_B,Time_E] when not Per_day ->
                [webuser_orangef:top_buttons_bar_full(Tag),
                 stats_result_page_users(Time_B,Time_E)];
            [Page, Tag, "users_num",Time_B,Time_E] = Args when Per_day ->
                [webuser_orangef:top_buttons_bar_full(Tag),
                 stats_result_page_users_per_day(Args)];
            _ ->
                webuser_msgs:text(argument_error)
	end,
    webuser_orangef:html(Content).

%%%%%%%%%%%%%%%%%% End of HTML handlers

%% +type selection_per_day() -> html()
selection_per_day() ->
    "<input type=\"checkbox\" name=\"per_day\", value=\"Y\">".

%% +type make_cell(string()|atom()) -> html()
make_cell(X) when is_atom(X) ->
    "<td class=\"sessions\">" ++ webuser_msgs:text(X) ++ "</td>";
make_cell(X) when is_list(X) ->
    "<td class=\"sessions\">" ++ X ++ "</td>".

%% +type stats_tab_header() -> html()
stats_tab_header() ->
    make_cells([ label, period_from, to, per_day ]).

%% +type stats_tab_body(string(),[string()],[string()]) -> html()
stats_tab_body(Tag, Time_Begin_Options,Time_End_Options) ->
    lists:map(
      fun({Label, Row_color})->
	      [
	       "<form method=\"GET\" "
	       "action=\"/secure/erl/webuser_stats_orangef:stats_result\">",
	       "<tr class=\"sessions", Row_color,"\">\n",
	       make_cell(Label),
	       "<td class=\"sessions\"><select name=\"time_beg\">",
	       Time_Begin_Options,"</select></td>",
	       "<td class=\"sessions\"><select name=\"time_end\">",
	       Time_End_Options,"</select></td>",
               "<td class=\"sessions\">",
	       selection_per_day(),
               "</td><td class=\"sessions\">",
	       "<input type=\"submit\" value=\"",webuser_msgs:text(view),
	       "\" class=\"bn\">",
	       "<input type=\"hidden\" name=\"type\" value=\"",
               atom_to_list(Label),
	       "\">",
               "<input type=\"hidden\" name=\"tag\" value=\"",Tag,"\">",
               "<input type=\"hidden\" name=\"page\" value=\"1\">",
               "</td>",
	       "</tr>\n",
	       "</form>\n"
	      ] end,
      [{consultations_num, "0"}, {users_num, "1"}]).

%%%% Result Pages

%% +type stats_result_page_consultations(string(), string()) -> html()
stats_result_page_consultations(Time_B,Time_E) ->
    Begin_Date = unixtime_to_date(Time_B),
    End_Date = unixtime_to_date(Time_E),
    Consultations =
        webuser_logs_orangef:consultations_in_a_period(Time_B,Time_E),
    ["<p class=\"search_title\">",webuser_msgs:text(stats_consultations_num),
     "</p>\n",
     "<table class=\"center\" >",
     "<tr>\n", stats_result_header(), "</tr>\n",
     "<tr>\n",
     stats_result_body(Begin_Date, End_Date, integer_to_list(Consultations)),
     "</tr>\n",
     "</table>"
    ].

%% +type stats_result_page_consultations_per_day([string()]) -> html()
stats_result_page_consultations_per_day(Args) ->
    Fun = fun webuser_logs_orangef:consultations_on_each_day/2,
    stats_result_page_per_day(Args, Fun, stats_consultations_num).

%% +type stats_result_page_users_per_day([string()]) -> html()
stats_result_page_users_per_day(Args) ->
    Fun = fun webuser_logs_orangef:number_of_representatives_on_each_day/2,
    stats_result_page_per_day(Args, Fun, stats_users_num).

%% +type stats_result_page_per_day([string()], fun(), atom()) -> html()
stats_result_page_per_day([Page_number, Tag, _, Time_B, Time_E] = Args,
                          Query_fun, Title) ->
    Query_Result = Query_fun(list_to_integer(Time_B), list_to_integer(Time_E)),

    Num = length(Query_Result),
    Total_Pages = webuser_orangef:sessions_page(Num,?STATS_PER_PAGE),
    Page = webuser_orangef:security_check_page(Page_number,Total_Pages),
    Page_Start = (Page-1)*?STATS_PER_PAGE+1,
    Result_Range =
	lists:sublist(Query_Result,Page_Start,?STATS_PER_PAGE),

    Content =
	["<p class=\"search_title\">",
         webuser_msgs:text(Title),
	 "</p>\n",
	 "<table class=\"center\" >",
	 "<tr>\n", stats_result_header_per_day(), "</tr>\n",
	 "<tr>\n", 
	 stats_result_body_per_day(Result_Range),
	 "</tr>\n",
	 "</table>"
	],
    Content ++ stats_footer(tl(Args), Page, Total_Pages).

%% + stats_result_page_users(integer(), integer()) -> html()
stats_result_page_users(Time_B,Time_E) ->
    Begin_Date = unixtime_to_date(Time_B),
    End_Date = unixtime_to_date(Time_E),
    Consultations =
        webuser_logs_orangef:number_of_representatives_in_period
          (list_to_integer(Time_B),list_to_integer(Time_E)),
    ["<p class=\"search_title\">",webuser_msgs:text(stats_users_num),
     "</p>\n",
     "<table class=\"center\" >",
     "<tr>\n", stats_result_header(), "</tr>\n",
     "<tr>\n", 
     stats_result_body(Begin_Date, End_Date, integer_to_list(Consultations)),
     "</tr>\n",
     "</table>"
    ].


%%% Htmlize the navigation buttons
%% +type stats_nav_button(string(), string(), atom()) -> html().
stats_nav_button(Args, ArgPage, Label) ->
    ["<form method=\"GET\"",
     " action=\"/secure/erl/webuser_stats_orangef:stats_result\">",
     Args,
     "<input type=\"hidden\" name=\"page\" value=\"",
     ArgPage,"\">\n",
     "<input type=\"image\" src=\"/icons/oran_arrow_", atom_to_list(Label),
     ".gif\" border=\"0\" name=\"submit\" alt=\"", webuser_msgs:text(Label),
     "\">",
     "</form>"].

%% +type stats_bypass_arguments([string()]) -> html()
stats_bypass_arguments(Args) ->
    Args_Pair =
        lists:zip(["tag","type","time_beg","time_end","per_day"],
                  Args ++ ["Y"]),
    lists:map(
      fun({Name,Value}) ->
              ["<input type=\"hidden\" name=\"",Name,"\" value=\"",
               Value,"\">\n"] end, Args_Pair).

%% +type stats_footer([string()], int(), int()) -> html()
stats_footer(Args,Page,TotalPages) ->
    PassArgs = stats_bypass_arguments(Args),
    %% first,prev,next and last buttons
    NavButtons =
	[stats_nav_button(PassArgs,"1",first),
	 stats_nav_button(PassArgs,webuser_orangef:dec_num_str(Page),prev),
	 stats_nav_button(PassArgs,
                          webuser_orangef:inc_num_str(Page, TotalPages),next),
	 stats_nav_button(PassArgs,integer_to_list(TotalPages),last)],
    ["<div align=\"right\"><table><tr><td class=\"sessions_footer\">",
     webuser_orangef:page_prompt(Page,TotalPages),
     NavButtons,"</td></tr></table></div>"].

%% +type unixtime_to_date(string()) -> date()
unixtime_to_date(T) ->
    {Date,_} = calendar:gregorian_seconds_to_datetime(list_to_integer(T)+
                                                      62167219200),
    Date.

%% +type stats_result_header() -> html()
stats_result_header() ->
    [
     "<tr class=\"sessions_header\">", 
     "<td class=\"sessions_header\">", webuser_msgs:text(period_from),"</td>",
     "<td class=\"sessions_header\">", webuser_msgs:text(to),"</td>",
     "<td class=\"sessions_header\">", webuser_msgs:text(volume),"</td></tr>"
    ].

%% +type stats_result_header_per_day() -> html()
stats_result_header_per_day() ->
    [
     "<tr class=\"sessions_header\">", 
     "<td class=\"sessions_header\">", webuser_msgs:text(date),"</td>",
     "<td class=\"sessions_header\">", webuser_msgs:text(volume),"</td></tr>"
    ].

%% +type make_cells(list()) -> html()
make_cells(L) ->
    lists:map(fun make_cell/1, L ).

%% +type stats_result_body(date(), date(), string()) -> html()
stats_result_body(Begin_Date,End_Date,Consultations) ->
    L = [webuser_orangef:format_the_date(Begin_Date, "/"), 
	 webuser_orangef:format_the_date(End_Date, "/"),
	 Consultations],
    make_cells(L).

%% stats_result_body_per_day([{date(),integer()}]) -> html()
stats_result_body_per_day(Content) ->
    lists:foldr(
      fun({{Y,M,D},V},Acc) ->
              Formatted_date = io_lib:format("~2..0w-~2..0w-~4..0w ",[D,M,Y]),
	      ["<tr>", make_cells([Formatted_date,integer_to_list(V)]),
               "</tr>" | Acc]
      end,
      [], Content
     ).
