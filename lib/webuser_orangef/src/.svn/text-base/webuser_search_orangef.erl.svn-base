-module(webuser_search_orangef).

-export([show/2]).

-export([print_date_list/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HTTP handlers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% page to select date , imsi | msisdn ,....
%% +type show(Env::http_env(),Input::string()) -> html().
show(Env, Input) ->
    {Time_B,Time_E} = webuser_orangef:compute_begin_and_end_dates(),
    select_page(Time_B,Time_E,Input).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% create identifier/period selection
%% +type select_page([tuple()],[tuple()],string()) -> html().
select_page(Envoi_Beg,Envoi_End,Input) ->
    Body =
	[
         webuser_orangef:top_buttons_bar_light(),
         webuser_orangef:top_status(),
         "<p class=\"search_title\">",webuser_msgs:text(search_title),"</p>\n"
         "<form class=\"center\" method=\"GET\""
         " action=\"/secure/erl/webuser_user_orangef:show\">\n",
         "<table class=\"select_user\" cellpadding=\"20\">",
         "<tr>\n"
         "<td class=\"identifier\">",
         webuser_msgs:text(choose_identifier),"</td>\n",
         "<td align=\"left\">",
         "<input type=\"radio\" id=\"msisdn_type\" name=\"Num\"",
         " value=\"msisdn\" onclick=\"fill_id()\" checked>",
	  webuser_msgs:text(friendly_msisdn),
	  "<br><input type=\"radio\" id=\"imsi_type\"",
	  " name=\"Num\" value=\"imsi\" onclick=\"fill_id()\">",
	  webuser_msgs:text(friendly_imsi),
	  "</td></tr>\n",
	  "<tr>&nbsp</tr>",
	  "<tr><td class=\"identifier\">",
	  webuser_msgs:text(enter_identifier),"</td>\n",
	  "<td align=\"left\">",
	  "<input type=\"text\" id=\"text_id\" name=\"id\"",
	  " size=\"17\" maxlength=\"17\">",
	  "</td></tr>\n",
	  "<tr>&nbsp</tr>",
	  "<tr><td class=\"identifier\" colspan=\"2\">",
	  webuser_msgs:text(period_from),
	  "&nbsp;<select id=\"select_time_beg\" name=\"time_beg\">",
	  lists:map(fun print_date_list/1,Envoi_Beg),"</select>&nbsp;",
	  webuser_msgs:text(to),
	  "&nbsp;<select id=\"select_time_end\" name=\"time_end\">",
	  lists:map(fun print_date_list/1,Envoi_End),"</select>",
	  "</td></tr>",
	  "<tr>&nbsp</tr></table>",
	  "<input type=\"hidden\" name=\"page\" value=\"1\">\n",
	  "<p><input type=\"submit\" value=",
	  webuser_msgs:text(select),
	  " class=\"bn\"></p>\n",
	  "</form>\n"
	 ],

    case webuser_util:get_args(["Num","id","time_beg","time_end"],Input) of
	missing_arg ->
            %% new search
            webuser_orangef:html(body_on_load,"load()",Body);
    	[Num,ID,Time_B,Time_E] = Args ->
            %% modify search
            webuser_orangef:html(body_on_load,load_function_name(Args),Body)
    end.



%% +type load_function_name([string()]) -> string()
load_function_name([Num,ID,Time_B,Time_E]) ->
    "load_with_args("++quote(Num)++","++quote(ID)++","
	++quote(Time_B)++","++quote(Time_E)++")".

%% +type quote(string()) -> string().
quote(L) when is_list(L) ->
    "'"++L++"'".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Id / period selection

%%%% Construction of the available periods HTML
%% +type print_date_list({Value::string(),Date::string()}) -> [string()].
print_date_list({Value,Date}) ->
    ["<option value=\"",Value,"\">",Date,"\n"].
