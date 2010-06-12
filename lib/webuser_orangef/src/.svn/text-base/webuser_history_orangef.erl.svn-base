-module(webuser_history_orangef).

-export([show/2]).

-include("../../pserver/include/pserver.hrl").

-define(HISTORY_LINES, 6).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% History Pages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Query Page
%% +type show(http_env(), string()) -> html().
show(Env,Input) ->
    case webuser_util:get_args(["Num", "id", "time_beg", "time_end",
                                "modify_tag", "history_start"], Input) of
        missing_arg ->
            webuser_orangef:send_code(argument_error);
        [Num, ID, Time_B, Time_E, ModifyTag, History_start] ->
            %% Ask DB the user profile
            Content =
                case webuser_generic:user([Num,ID,Time_B,Time_E],
                                          single_operator) of
                    {error,Msg} -> webuser_orangef:send_code(Msg);
                    
                    %% We got our profile
                    %% (we have only one : selected previously)
                    {Profile,Last,Sessions} ->
                        Relay_arguments = [Num, ID, Time_B, Time_E, ModifyTag],
                        history_layout(Env, Relay_arguments, Profile, Last,
                                       History_start)
                end,
            Top = webuser_orangef:top_buttons_bar_full(ModifyTag),
            webuser_orangef:html([Top, Content]);
        _ ->
            webuser_msgs:send_code(argument_error)
    end.

%%%%%%%%%%%%%%%%%% End of HTML handlers

history_layout(Env, Relay_arguments, #profile{uid=Uid}=Profile, Last,
               History_start) ->
    Start_as_int = list_to_integer(History_start),

    Whole_customer_history =
        webuser_logs_orangef:customer_history(Uid, History_start),
    Count = length(Whole_customer_history),
    End_as_int = Start_as_int + ?HISTORY_LINES - 1,
    Customer_history = lists:sublist(Whole_customer_history, Start_as_int,
                                     End_as_int),

    Page_number = Start_as_int div ?HISTORY_LINES + 1,
    Total_pages = (Count - 1) div ?HISTORY_LINES + 1,
    Nav_buttons = browsing_buttons(Relay_arguments, Start_as_int, Count),
    
    First_line_id = lists:max([Count - End_as_int + 1, 1]),

    [
     "<p class=\"search_title\">",webuser_msgs:text(history_actions),"</p>\n",
     webuser_user_orangef:make_quick_description(Profile,Last),
     "<table class=\"sessions\">",
     "<tr class=\"sessions_header\">\n", history_header(),"</tr>\n",
     history_body(Customer_history, Relay_arguments, Profile,
                  First_line_id),
     "</tr></table>\n",
     "<div align=\"right\"><table><tr><td class=\"sessions_footer\">",
     webuser_orangef:page_prompt(Page_number,Total_pages),
     Nav_buttons,"</td></tr></table></div>"
    ].

history_header() ->
    [ "<td class=\"sessions_header\">" ++ webuser_msgs:text(X) ++ "</td>"
      || X <- [ number, user, date, hour, consulted_session, action ] ].

history_body(Entries, Relay_arguments, Profile, First_entry_id) ->
    {_, HTML} = 
        lists:foldr(fun(Entry, Acc) ->
                            make_history_entry(Entry, Relay_arguments,
                                               Profile, Acc)
                    end, {First_entry_id, []}, Entries),
    HTML.

make_history_entry({Login, UID, Unixtime, Action_details}, Relay_arguments,
                   Profile, {Index, HTML}) ->
    [Day, Time] = webuser_util:affich_date_hour(list_to_integer(Unixtime)),
    Class_suffix = integer_to_list(Index rem 2),
    {Index + 1,
     [
      "<tr class=\"sessions", Class_suffix, "\">",
      "<td class=\"sessions\">", integer_to_list(Index), "</td>\n",
      "<td class=\"sessions\">", Login, "</td>\n",
      "<td class=\"sessions\">", Day, "</td>\n",
      "<td class=\"sessions\">", Time, "</td>\n",
      "<td class=\"sessions\">", consulted_session(Action_details,
                                                  Relay_arguments,
                                                  Profile),
      "</td>\n",
      "<td class=\"sessions\">", action(Action_details),"</td>\n",
      "</tr>"
      | HTML]}.
    
    
browsing_buttons(Arguments, History_start, Count) ->
    Prev_history = lists:max([History_start - ?HISTORY_LINES, 1]),
    Last_history = lists:max([Count - ?HISTORY_LINES + 1,
                              Count - ((Count - 1) rem ?HISTORY_LINES)]),

    Next_history = lists:min([History_start + ?HISTORY_LINES, Last_history]),
    [ browsing_button(Arguments, first, 1),
      browsing_button(Arguments, prev, Prev_history),
      browsing_button(Arguments, next, Next_history),
      browsing_button(Arguments, last, Last_history)
     ].

browsing_button([Num, ID, Time_B, Time_E, ModifyTag], Label, Start) ->
      [
       "<form method=\"GET\" action=\"webuser_history_orangef:show\">\n",
       "<input type=\"hidden\" name=\"Num\" value=\"",Num,"\">\n",
       "<input type=\"hidden\" name=\"id\" value=\"",ID,"\">\n",
       "<input type=\"hidden\" name=\"time_beg\" value=\"",Time_B,"\">\n",
       "<input type=\"hidden\" name=\"time_end\" value=\"",Time_E,"\">\n",
       "<input type=\"hidden\" name=\"history_start\" value=\"", integer_to_list(Start), "\">\n",
       "<input type=\"hidden\" name=\"modify_tag\" value=\"",ModifyTag,"\">\n",
       "<input type=\"image\" src=\"/icons/oran_arrow_", atom_to_list(Label),
     ".gif\" border=\"0\" name=\"submit\" alt=\"",webuser_msgs:text(Label),
     "\">",
    "</form>"].

consulted_session(consult_user, _, _) ->
    "-";
consulted_session({consult_session, Begin_time},
                  [_, _, _, _, ModifyTag],
                  #profile{uid = UID,
                           msisdn = MSISDN,
                           lang = Language,
                           subscription = Subscription}) ->
    [
     webuser_util:affich_date_hour(Begin_time),
     "<form action=\"webuser_session_details_orangef:show\">",
     "<input type=\"hidden\" name=\"uid\" value=\"", integer_to_list(UID), "\">\n",
     "<input type=\"hidden\" name=\"time\" value=\"", integer_to_list(Begin_time), "\">\n",
     "<input type=\"hidden\" name=\"language\" value=\"", Language,"\">\n",
     "<input type=\"hidden\" name=\"modifytag\" value=\"", ModifyTag, "\">\n",
     "<input type=\"hidden\" name=\"msisdn\" value=\"", MSISDN,"\">\n",
     "<input type=\"hidden\" name=\"subscription\" value=\"", Subscription,"\">\n",
     "<input type=\"submit\" class=\"bn\" value=\"", webuser_msgs:text(view),"\">",
     "</form>"
     ];
consulted_session({update_profile, Details}, _, _) ->
    "-".

action({update_profile, What}) ->
    action(update_profile) ++ ": " ++ What;
action({X, _}) ->
    action(X);
action(X) ->
    webuser_msgs:text(X).
