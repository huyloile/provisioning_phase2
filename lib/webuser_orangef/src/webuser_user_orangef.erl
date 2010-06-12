-module(webuser_user_orangef).

-include("../../pserver/include/pserver.hrl").

-export([show/2]).

-export([make_quick_description/2]).

-define(SESSIONS_PER_PAGE, 6).

%%% HTML handler
%%% gives informations about user and sessions.
%% +type show(http_env(), string()) -> html().
show(Env, Input) ->
    case webuser_util:get_args(["Num","id","time_beg","time_end"],Input) of
	missing_arg ->
	    webuser_orangef:send_code(argument_error);
	[Num,ID,Time_B,Time_E] = Args ->
	    %% Ask DB the user profile
	    case webuser_generic:user(Args, single_operator) of
		{error,Msg} -> webuser_orangef:send_code(Msg);

		%% Multiple entries !
		{choice,ProfilesSince} ->
                    Redirect_to = "/secure/erl/webuser_user_orangef:show",
		    webuser_orangef:choose_profiles
                      (ProfilesSince,Time_B,Time_E, Redirect_to);

		%% We got our profile
		{Profile,Last,Sessions} ->
                    {value, {_,User}} =  lists:keysearch(remote_user, 1, Env),
                    ok = webuser_logs_orangef:write_event
                           (User, Profile#profile.uid, consult_user),
		    try modify_tag(Args,Input,Profile) of
			ModifyTag ->
        		    draw_layout(Env,Input,Profile,Last,Sessions,
					ModifyTag)
		    catch
			_:_ -> webuser_orangef:send_code(argument_error)
		    end
 	    end;
	_ -> webuser_orangef:send_code(argument_error)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% find or generate a tag for "search modify" button
%% +type modify_tag([string()],string(),profile()) -> string() | {error,Reason}
modify_tag([Num,ID,Time_B,Time_E],Input,#profile{imsi=IMSI}) ->
    if Num =:= "msisdn"; Num =:= "imsi" ->
            webuser_orangef:encode_raw_data([{"Num",Num},{"id",ID},
                                             {"time_beg",Time_B},
                                             {"time_end",Time_E}]);
       Num =:= "Uid" ->
            case webuser_util:get_args(["tag"],Input) of
                %% use the existing tag generated from msisdn or imsi
                [Encoded_data] -> Encoded_data;
                missing_arg ->
                    webuser_orangef:encode_raw_data([{"Num","imsi"},{"id",IMSI},
                                                     {"time_beg",Time_B},
                                                     {"time_end",Time_E}]);
                _ ->
                    exit(argument_error)
            end;
       true ->
            exit(argument_error)
    end. 

%% +type draw_layout(http_env(),string(),profile(),Last::[string()],
%%                     Sessions::[[string()]],string()) -> html().
draw_layout(Env,Input,#profile{lang=Lang}=Profile,Last,Sessions,ModifyTag) ->
%%% Store current URL to go back here after profile updates / back buttons
%%% (needs a GET request)

    {value,{_,URL}} = lists:keysearch(script_name,1,Env),
    RedirectCB = fun(Env2,Input2) ->
			 Server = webmin_util:server_of_http_env(Env2),
			 webmin:redirect("http://"++Server++URL)
		 end,
 
%%% We do not want to refresh directly
%%% (by passing new profile to a webmin callback for instance)
%%% since it would display a webmin:execute link with no arguments
%%%  in address bar, thus causing an internal error message when refreshing.

%%% Odds of refreshing in a Customer Care service being high, we use a redirect
%%% Side effect : DB profile is read again 

%%% The CallBack takes a message to be displayed as an argument
%%% It can be a reference to a webuser message or a text message by itself
%%% (to ease operator-specific webuser plugins)

    CB =
	fun(Msg) ->
		Text =
		    if atom(Msg) -> webuser_msgs:text(Msg);
		       list(Msg) -> Msg;
		       true -> []
		    end,	

		Label = webuser_msgs:text(back_profile),
		Button = webmin_callback:wrap_form([],Label,RedirectCB),

		Body =
		    [Text,"<br/>",Button],
                Header = webuser_orangef:session_header
                           (profile_title,ModifyTag),
		webuser_orangef:html([Header, Body])
	end,

    %% Upper left panel : quick description
    T_Info = make_quick_description(Profile,Last),


%%% Tabs creation :
%%% Only allow edition for allowed users
%%% We don't show the form for the others since the action is a
%%%% webmin_callback:execute that can be triggered with normal privileges
%%% (by editing HTML code and posting to /secure/erl instead of 
%%% /secure/edit/erl)
    Opts    = webuser_util:server_directory_opts("/secure/update"),
    {value,{_,RemoteUser}} = lists:keysearch(remote_user,1,Env),
    CanEdit =
	case mod_auth_cookie:list_group_members("update",Opts) of
	    {ok,Members} ->
		lists:member(RemoteUser,Members);
	    _ -> false
	end,

    UpdatePageCB =
        fun(_Env,_Input) ->
		%% The update page layout :
		%% ________________________________
		%%    User Info   |  Update Form 
		%% ____UPT_User_____|_____UPT_Form_
		UPT_User = update_tab_content(Profile,CB),
		UPT_Form = user_setting_form(Profile,CB),
		UPHTML = webuser_orangef:session_header
                           (profile_title,ModifyTag) ++
		    ["<table><tr><td class=\"layout\">",UPT_User,"</td>\n",
		     "<td class=\"layout\">",UPT_Form,"</td></tr>\n",
		     "</table>"],
		webuser_orangef:html(UPHTML)
        end,
    T_User = tabs_user(Profile,Input,CanEdit,CB,UpdatePageCB),

%%% Show sessions : split pages
    [ArgPage] = webuser_util:get_args(["page"],Input),
    T_Session = all_sessions(Sessions,Lang,ArgPage,ModifyTag,Profile),

    %% The Layout :
    %% _________________    ____________
    %% Quick Description|  |User Profile|
    %% ____T_Info________   __T_User____
    %%
    %% __________________________________
    %%             T_Sessions

    %% We user HTML tables, simple divs need some CSS tweaks
    %% in order to be displayed correctly when window is resized
    HTML = profile_header(ModifyTag) ++
        ["<table class=\"main\"><tr><td class=\"layout\">",T_Info,"</td>\n",
	 "<td class=\"layout\">",T_User,"</td></tr>\n",
	 "<tr><td colspan=\"2\">",T_Session,"</td></tr></table>"],
    webuser_orangef:html(HTML).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Quick Description (left panel)

%% +type make_quick_description(profile(),Last::[string()]) -> html().
make_quick_description(Profile,Last) ->
    Fields = pbutil:get_env(webuser,quick_description_fields),
    ["<table class=\"quick_desc\">\n",
     lists:map(fun(Field) ->
		       compute_quick_description(Field,Profile,Last)
	       end,Fields),
     "</table>\n"].


%%% Diplays user profile information and last session date
%% +type compute_quick_description(field_config(),profile(),Last::[string()])->
%%                                 html().

compute_quick_description({imei,Text},#profile{imei=IMEI},Last) ->
    webuser_editor_orangef:print_row(Text,IMEI,{oma_type,string});
compute_quick_description({imsi,Text},#profile{imsi=IMSI},Last) ->
    webuser_editor_orangef:print_row(Text,IMSI,{oma_type,string});
compute_quick_description({msisdn,Text},#profile{msisdn=MSISDN},Last) ->
    webuser_editor_orangef:print_row(Text,MSISDN,{oma_type,string});
compute_quick_description({subscription,Text},
			  #profile{subscription=Subscription},Last) ->
    webuser_editor_orangef:print_row(Text,Subscription,{oma_type,string});
compute_quick_description({language,Text},#profile{lang=Lang},Last) ->
    webuser_editor_orangef:print_row(Text,Lang,{oma_type,string});
compute_quick_description({last,Text},_,Last) ->
    webuser_editor_orangef:print_row(Text,lists:flatten(Last),{oma_type,string});
compute_quick_description({other,Text,{Module,Func}}=Other,Profile,_) ->
    %% Special description item from another module
    %% See test_quick_desc_
    case catch Module:Func(Profile) of
	{ok,Value} when list(Value)->
	    webuser_editor_orangef:print_row(Text,Value,{oma_type,string});
	Else ->
	    slog:event(internal,?MODULE,bad_quick_description_field,
		       {Other,Else}),
	    []
    end;
compute_quick_description(Unknown,P,Last) ->
    slog:event(internal,?MODULE,bad_quick_description_field,Unknown),
    []. 


%%% Test quick_desc
%% +type test_quick_desc(profile()) -> {ok,html()}.
test_quick_desc(_) ->
    {ok,"Test"}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% User Profile (right panel)

%%% Generate tabs row if needed
%% +type tabs_user(profile(),Input::string(),CanEdit::bool(),wu_cb(),wu_cb())->
%%          html().
tabs_user(P,Input,CanEdit,CB,UpdateCB) ->
    ConfigTabs = pbutil:get_env(webuser,profile_tabs),

    case ConfigTabs of
	[] -> [];
	L when list(L) ->
	    Args = webmin:parse_input(Input),
	    {CurrentTab,Args2} =

		%% If a tab is already selected, make it the active one
		case {oma_util:lkdsearch("tab",not_found,Args),ConfigTabs} of
		    %% No current tab : print first one in config
		    %% and initialize a value in list of arguments
		    {not_found,[{TabName,_,_}|_]} ->
			{TabName,Args ++ [{"tab",TabName}]};
		    {TabName,_} ->
			{TabName,Args}
		end,

	    ["<div>\n",
%%	     "<ul id=\"nav\">\n",
%%	     create_tabs(P,ConfigTabs,Args2,CurrentTab),
%%	     " </ul>",
	     tab_content(P,ConfigTabs,CurrentTab,CanEdit,CB,UpdateCB),
	     "</div>\n"]
    end.

%%%%% Tab top layout

%%% First case : drawing as current tab 
%% +type create_tabs(profile(),fields_config(),[{string(),string()}],
%%                   string()) -> html().
create_tabs(P,[{CurrentTab,Name,_}|ConfigTabs],Args,CurrentTab) ->
    [" <li id=\"current_nav\">",webmin:esc_pcdata(Name),"</li>\n"|
     create_tabs(P,ConfigTabs,Args,CurrentTab)];

%%% not current tab : make a borderless button out of it
%%% We do not use a simple link as it breaks the HTML 4.01 transitional
%%% validation if we pass the GET arguments directly
%%% And we want the GET method to ease refreshes
create_tabs(P,[{TabName,Name,_}|ConfigTabs],Args,CurrentTab) ->

    %% "tab" must exist in list (initialized in tabs_user/4)
    Args_Form = lists:keyreplace("tab",1,Args,{"tab",TabName}),
    ["<li>\n",
     "<form method=\"GET\" action=\"webuser_user_orangef:show\">",
     webuser_orangef:hidden_form_args(Args_Form),
     "<input class=\"tab_button\" type=\"submit\" value=\"",
     webmin:esc_pcdata(Name),"\">",
     "</form></li>" |
     create_tabs(P,ConfigTabs,Args,CurrentTab)];

create_tabs(_,[],_,_) ->
    [].


%%% Now, the tab content
%% +type tab_content(profile(),fields_config(),string(),EditMode::bool(),
%%                   wu_cb(),wu_cb()) -> html().
tab_content(P,ConfigTabs,CurrentTab,CanEdit,CB,UpdateCB) ->
    %% There is a match if we are here.
    {value,{_,Name,{Module,FieldsConfig}}} =
	lists:keysearch(CurrentTab,1,ConfigTabs),

    FieldsConfig2 = 
	if not(CanEdit) ->
		SecureFieldFun =
		    fun({FName,FText,Type}) -> {FName,FText,{print,Type}} end,
		lists:map(SecureFieldFun, FieldsConfig);
	   true -> FieldsConfig
	end,

    %% Rely on an external module to display tab content
    Content = 
	case catch Module:edit_webuser(P,CurrentTab,FieldsConfig2,CB) of
	    {ok,HTML} ->
		HTML; 
	    {nok,Msg} ->
		["<tr class=\"tab\"><td colpan=\"2\">",Msg,"</td></tr>"];
	    Error ->
		slog:event(internal,?MODULE,cannot_display_tab,{Error,P}),
		["<tr class=\"tab\"><td colpan=\"2\">",
                 webuser_msgs:text(db_error),
		 "</td></tr>"]
	end,

    Label = webuser_msgs:text(update_button),

    ["<table class=\"tab\">\n",
     Content,
     "<tr align=\"center\"><td>",webmin_callback:wrap_form([],Label,UpdateCB),
     "</td></tr>"
     "</table>\n"].


%%% tab content in user update page
%% +type update_tab_content(profile(),wu_cb()) -> html().
update_tab_content(P,CB) ->
    Fields = pbutil:get_env(webuser_orangef, update_profile_tab_orangef),

    %% Rely on an external module to display tab content
    Content = 
	case catch webuser_edit_profile_orangef:edit_webuser(P,no_tab,
							     Fields,CB) of
	    {ok,HTML} ->
		HTML; 
	    {nok,Msg} ->
		["<tr><td colpan=\"2\">",Msg,"</td></tr>"];
	    Error ->
		slog:event(internal,?MODULE,cannot_display_tab,{Error,P}),
		["<tr><td colpan=\"2\">",webuser_msgs:text(db_error),
		 "</td></tr>"]
	end,


    ["<table class=\"quick_desc\">\n",
     Content,
     "</table>\n"].

%%% user setting form in user update page
%% +type user_setting_form(profile(),wu_cb()) -> html().
user_setting_form(P,CB) ->
    Fields = pbutil:get_env(webuser_orangef, terminal_level_tab),

    %% Rely on an external module to display tab content
    Content = 
	case catch webuser_edit_profile_orangef:edit_webuser(P,no_tab,
							     Fields,CB) of
	    {ok,HTML} ->
		HTML; 
	    {nok,Msg} ->
		["<tr><td colpan=\"2\">",Msg,"</td></tr>"];
	    Error ->
		slog:event(internal,?MODULE,cannot_display_tab,{Error,P}),
		["<tr><td colpan=\"2\">",webuser_msgs:text(db_error),
		 "</td></tr>"]
	end,


    ["<form><table class=\"tab\">\n",
     Content,
     "</table></form>\n"].

%% +type all_sessions([[string()]], string(),
%%                     ArgPage::string() | missing_arg,
%%                     ModifyTag:string(), profile()) ->
%%                     html().
%%%% lists sessions with few details
all_sessions([],_,_,_,_) ->
    [webuser_msgs:text(no_session)];
all_sessions(Result,Lang,ArgPage,ModifyTag,
	     #profile{msisdn=Msisdn,subscription=Subscription}=Profile) ->
    End_Time = lists:nth(3,hd(Result)),
    Beg_Time = lists:nth(3,lists:last(Result)),
    Uid = hd(hd(Result)),
    SessionsNum = length(Result),
    TotalPages = webuser_orangef:sessions_page(SessionsNum,?SESSIONS_PER_PAGE),
    Page = webuser_orangef:security_check_page(ArgPage,TotalPages),
    Index = case (SessionsNum - Page*?SESSIONS_PER_PAGE)+1 of
		X when X > 0 -> X;
		_ -> 1 end,
    PageStart = (Page-1)*?SESSIONS_PER_PAGE+1,
    ResultRange =
	lists:sublist(Result,PageStart,?SESSIONS_PER_PAGE),

    %% The sessions summary
    [_, Table] =  lists:foldr(
		    fun(X,[N,Table1]=Sum)->
			    affich_ligne(X,Lang,Sum,ModifyTag,
					 Msisdn,Subscription) end,
		    [Index,[]], ResultRange),

    [
     "<table class=\"sessions\" >",
     "<tr>\n",
     %% Headers of the big sessions table
     lists:map(fun(X)->
		       ["<td class=\"sessions_header\">",
			webuser_msgs:text(X),
			"</td>\n"] end,
	       [number,
		connection_date,
		connection_time,
		service_code,
		connection_duration,
		phase,
		session_cost,
		source,
		details]),
     "</tr>\n",
     Table,
     "</table>\n",
     sessions_footer(Uid,Beg_Time,End_Time,Page,TotalPages)].

%% +type sessions_footer(string(),string(),string(),int(),int()) -> html().
sessions_footer(Uid,Beg_Time,End_Time,Page,TotalPages) ->
    %% first,prev,next and last buttons
    NavButtons =
	[nav_button(Beg_Time,End_Time,Uid,"1",first),
	 nav_button(Beg_Time,End_Time,Uid,
                    webuser_orangef:dec_num_str(Page),prev),
	 nav_button(Beg_Time,End_Time,Uid,
                    webuser_orangef:inc_num_str(Page, TotalPages),next),
	 nav_button(Beg_Time,End_Time,Uid,integer_to_list(TotalPages),last)],
    ["<div align=\"right\"><table><tr><td class=\"sessions_footer\">",
     webuser_orangef:page_prompt(Page,TotalPages),
     NavButtons,"</td></tr></table></div>"].

%%% Htmlize the navigation buttons
%% +type nav_button(string(),string(),string(),string(),atom()) -> html().
nav_button(BeginT,EndT,Uid,ArgPage,Label) ->
    ["<form method=\"GET\"",
     " action=\"/secure/erl/webuser_user_orangef:show\">",
     "<input type=\"hidden\" name=\"Num\" value=\"Uid\">\n",
     "<input type=\"hidden\" name=\"id\" value=\"",Uid,"\">\n",
     "<input type=\"hidden\" name=\"time_beg\" value=\"",
     BeginT,"\">\n",
     "<input type=\"hidden\" name=\"time_end\" value=\"",
     EndT,"\">\n",
     "<input type=\"hidden\" name=\"page\" value=\"",
     ArgPage,"\">\n",
     "<input type=\"image\" src=\"/icons/oran_arrow_", atom_to_list(Label),
     ".gif\" border=\"0\" name=\"submit\" alt=\"",webuser_msgs:text(Label),
     "\">",
    "</form>"].


%%%% Description of one session
%% +type affich_ligne(SessionData::[string()],Lang::string(),Table::html(),
%%                    ModifyTag:string(),
%%                    Msisdn:string(),Subscription:string()) -> html().
affich_ligne([Uid,Src,Time,Service,Duration,Bearer,Price],
	     Lang,[N,Table],ModifyTag,Msisdn,Subscription) ->
    [Date,Hour] = webuser_util:affich_date_hour(list_to_integer(Time)),
    Class_suffix = integer_to_list(N rem 2),
    N_as_string = integer_to_list(N),
    [N+1,["<tr class=\"sessions"++Class_suffix++"\">",
	  "<td class=\"sessions\">",N_as_string,"</td>",
	  "<td class=\"sessions\">",Date,"</td>",
	  "<td class=\"sessions\">",Hour,"</td>",
	  "<td class=\"sessions\">",webuser_util:affich_code(Service,Bearer),"</td>"
	  "<td class=\"sessions\">",
	  webuser_util:affich_time(list_to_integer(Duration)),"</td>",
	  "<td class=\"sessions\">",webuser_util:affich_bearer(Bearer),"</td>", 
	  "<td class=\"sessions\">",webuser_util:affich_num(Price,100)," ",
	  pbutil:get_env(webuser,currency),"</td>",
	  "<td class=\"sessions\">", Src, "</td>",
	  "<td class=\"sessions\">",
	  "<form method=\"GET\""
          " action=\"/secure/erl/webuser_session_details_orangef:show\">",
	  "<input type=\"hidden\" name=\"uid\" value=\"",Uid,"\">",
	  "<input type=\"hidden\" name=\"time\" value=\"",Time,"\">",
	  "<input type=\"hidden\" name=\"language\" value=\"",Lang,"\">",
	  "<input type=\"hidden\" name=\"modifytag\" value=\"",ModifyTag,"\">",
	  "<input type=\"hidden\" name=\"msisdn\" value=\"",Msisdn,"\">",
	  "<input type=\"hidden\" name=\"subscription\" value=\"",Subscription,"\">",
	  "<input type=\"submit\" value=\"", webuser_msgs:text(details),
	  "\" class=\"bn\"></form></td>",
	  "</tr>\n"|Table]].



%% +type profile_header(fun()) -> html().
profile_header(Tag) ->
    [
     webuser_orangef:top_buttons_bar_full(Tag),
     "<p class=\"search_title\">",webuser_msgs:text(profile_title),"</p>\n"
    ].

