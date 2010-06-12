-module(webuser_session_orangef).

%%% Module handling session details display

-export([session2/9]).

-include("../../posmon/include/posmon.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../oma_webmin/include/webmin.hrl").


%%%% DOCUMENTATION
-export([slog_info/3]).
-include("../../oma/include/slog.hrl").

-define(NUM_ITEMS_PER_PAGE, 6).
-import(webuser_orangef, [to_int/1,dec_num_str/1,inc_num_str/2,
        sessions_page/2,page_prompt/2]).

%% +deftype row() =
%%  #row{c1 :: string(),
%%       c2 :: string(),
%%       c3 :: string(),
%%       c4 :: string(),
%%       c5 :: string(),
%%       c6 :: string(),
%%       c7 :: string(),
%%       c8 :: string()}.

-record(row,{c1,c2,c3,c4,c5,c6,c7,c8}).

%% +deftype webuser() =
%%    #webuser{nb       :: integer(),
%%         page_no  :: string(), %%for page split
%%	       ref      :: integer(),
%%	       acc      :: row(),
%%	       bearer   :: {ussd, 1}|{ussd, 2}|{ussd, 15}|
%%                         {ussdpush, 2} | {sms,txt} | unknown,
%%	       session  :: session(),
%%	       choice   :: [integer()],
%%	       info     :: {string(),string(),string(),string()},
%%	       uid      :: string(),
%%         msisdn   :: string(),
%%         subscription   :: string(),
%%	       page     :: row(),      %%%% handle the last page
%%	       prev     :: row()}.

-record(webuser,{nb,
                 page_no,
		 ref,
		 acc,
		 bearer,
		 session,
		 choice,
		 info,
		 uid,
                 msisdn,
                 subscription,
		 page,                       %%%% handle the last page
		 prev=#row{}}).


%%%%%%%%%%%%%%%% nombre de colonne total : soit 4 soit 8.

%%%% parses request and prints result
%% +type session2(DBResult::[string()],Time::string(),Lang::string(),
%%  Choice::string(),Uid::string(),ModifyTag::string(),
%%  Msisdn::string(),Subscrption::string(),PageNo::string) -> html().
session2([Action_p,Duration_p,Bearer,Price],Time,Lang,Choice,Uid,
    ModifyTag,Msisdn,Subscription,PageNo) ->
    %% Should we print additional billing columns ?
    %% EnabledAdvBilling = pbutil:get_env(webuser,enable_advanced_billing),
    %% Nb = case {EnabledAdvBilling,Price} of
	%%     {_,"0"} -> 6;
	%%     {false,_} -> 6;
	%%     {true,_} -> 8
	%% end,

    %% disable advanced billing temporarily because no info is specified in WS
    Nb = 6,
    Action_P2 = dbutil:sql_unescape(pbutil:string_to_term(Action_p)),
    Action= compression:gestion_uncomp(Action_P2),
    Time_I = list_to_integer(Time),
    Duration  = list_to_integer(Duration_p),
    End_Time = Duration + Time_I,
    Enc_Action = httpd_util:encode_base64(Action_p),
    Info = {Duration_p,Price,Time,Enc_Action},
    Bearer_1 = case Bearer of
		   "U1" -> {ussd, 1};
		   "U2" -> {ussd, 2};
		   "UP" -> {ussdpush, 2};
		   "UE" -> {ussd, 15};
		   "SM" -> {sms, text};
		   _ -> unknown
	       end,
    Session = #session{prof=#profile{lang= Lang,
				     terminal = #terminal{}}, 
		       bearer=Bearer_1},
    [Date, Hour] = webuser_util:affich_date_hour(Time_I),
    Date2 = affich_date(Time_I),
    HourStr = lists:flatten(Hour), 
    Webuser = #webuser{info=Info, ref=0, acc=[] ,session=Session,
        choice=Choice, bearer=Bearer,
        uid=Uid,msisdn=Msisdn,subscription=Subscription, nb=Nb,
        page=#row{c5=Date2,c6=HourStr},page_no=PageNo},
    {Webuser2,TotalPage,Acc_2} = affich_page1(Webuser, Action,ModifyTag),

    Header = header(Nb),
    Footer = [], %%if Nb == 6 -> []; Nb == 8 -> taxation_info() end,
    [
     "<a name=\"top\"></a>\n",
     "<div align=\"center\">"
     "<table class=\"quick_desc\">\n",
     "<tr><td>",webuser_msgs:text(friendly_msisdn),"</td>",
     "<td>",Msisdn,"</td></tr>\n",
     "<tr><td>",webuser_msgs:text(subscription),"</td>",
     "<td>",Subscription,"</td></tr>\n",
     "<tr><td>",webuser_msgs:text(connection_date),"</td>",
     "<td>",lists:flatten(io_lib:format("~s ~s",[Date, Hour])),
     "</td></tr>\n",
     "</table>\n",
     "</div>\n",
     
     "<table class=\"sessions\">",
     "<tr>",Header,"</tr>\n",
     %lists:reverse(Acc_2),
     Acc_2,
     "</table>",
     session_logs_footer(Webuser2,TotalPage,ModifyTag),
     "<hr>",
     Footer].

session_logs_footer(#webuser{info=Info, choice=Choice, 
				   session=Session, bearer=Bearer,
				   uid=Uid, msisdn=Msisdn, subscription=Subscription,
                   page_no=Page},TotalPages,ModifyTag) ->
    %% first,prev,next and last buttons
    {Duration,Price,Time,Detail} = Info,
    List = webuser_layout:create_enum(Choice,""),
    Lang = (Session#session.prof)#profile.lang,
    Code = Session#session.service_code,
    FixedArgs = [Detail,Duration,Price,Time,Lang,Code,Bearer,List,Uid,
        Msisdn,Subscription,ModifyTag],
    NavButtons =
    [nav_button(FixedArgs,"1",first),
        nav_button(FixedArgs,dec_num_str(to_int(Page)),prev),
        nav_button(FixedArgs,inc_num_str(to_int(Page),TotalPages),next),
        nav_button(FixedArgs,integer_to_list(TotalPages),last)],
    ["<div
        align=\"right\"><table class=\"sessions_footer\"><tr><td
        class=\"sessions_footer\">",page_prompt(Page,TotalPages),
        NavButtons,"</td></tr></table></div>"].

nav_button([Detail,Duration,Price,Time,Lang,Code,Bearer,List,Uid,
        Msisdn,Subscription,ModifyTag],PageNo,Label) ->
    [
        "<form method=\"POST\" action=\"webuser_session_details_orangef:detail_ask\">\n",
        "<input type=\"hidden\" name=\"a\" value=\"",Detail,"\">\n",
        "<input type=\"hidden\" name=\"b\" value=\"",Duration,"\">\n",
        "<input type=\"hidden\" name=\"c\" value=\"",Price,"\">\n",
        "<input type=\"hidden\" name=\"d\" value=\"",Time,"\">\n",
        "<input type=\"hidden\" name=\"e\" value=\"",Lang,"\">\n",
        "<input type=\"hidden\" name=\"f\" value=\"",Code,"\">\n",
        "<input type=\"hidden\" name=\"g\" value=\"",Bearer,"\">\n",
        "<input type=\"hidden\" name=\"h\" value=\"",List,"\">\n",
        "<input type=\"hidden\" name=\"i\" value=\"\">\n",
        "<input type=\"hidden\" name=\"j\" value=\"",Uid,"\">\n",
        "<input type=\"hidden\" name=\"modifytag\" value=\"",ModifyTag,"\">\n",
        "<input type=\"hidden\" name=\"msisdn\"  value=\"",Msisdn,"\">\n",
        "<input type=\"hidden\" name=\"subscription\" value=\"",Subscription,"\">\n",
        "<input type=\"hidden\" name=\"page\" value=\"",PageNo,"\">\n",
     "<input type=\"image\" src=\"/icons/oran_arrow_", atom_to_list(Label),
     ".gif\" border=\"0\" name=\"submit\" alt=\"",webuser_msgs:text(Label),
     "\">",
    "</form>"].

%%%% checks the non-redondance between INTERPRET and USER, parse Action
%% +type affich_page1(webuser(),[tuple()],string()) -> 
%%      {webuser(),int(),string()}.
affich_page1(Web, [{?USER,Data},{?MENU,Data}|Action],Tag) ->
    affich_page1(Web, [{?USER,Data}|Action],Tag);
affich_page1(Web, [{?USER,Data},{?ENTRY,Data}|Action],Tag) ->
    affich_page1(Web, [{?USER,Data}|Action],Tag);
%%%% To handle old version of next page and logs of page
affich_page1(Web, [{?MENU,"Next Page"},{Tag,B}|Action],Tag)
  when Tag == ?USER ; Tag == ?SERV->
    affich_page1(next_page_old(Web),[{Tag,B}|Action],Tag);
affich_page1(Web, [X|Action],Tag) ->
    affich_page1(affich_page(X,Web,Tag),Action,Tag);

affich_page1(#webuser{prev=Prev,nb=Nb,page=Page,acc=Acc,page_no=PageNo}=Web, 
        [],Tag)->
    Acc2 = [Prev] ++ Acc,
    Acc3 = replace(Acc2,Page),
    Acc4 = lists:filter(fun is_show_line/1,Acc3),
    TotalItems = length(Acc4),
    [_,_,Acc5] = lists:foldr(fun(X,_Acc) -> create_line(X,_Acc)
        end, [Nb,TotalItems,[]], Acc4),
    PageStart = (to_int(PageNo)-1)*?NUM_ITEMS_PER_PAGE+1,
    ResultRange = lists:sublist(lists:reverse(Acc5),PageStart,
        ?NUM_ITEMS_PER_PAGE),
    TotalPage = sessions_page(TotalItems, ?NUM_ITEMS_PER_PAGE),
    {Web,TotalPage,ResultRange}.


%% +type is_show_line(row()) -> bool()
is_show_line(#row{c1=A,c2=A,c3=A,c4=A}) when A == undefined -> false;
is_show_line(_) -> true.


%%%% creates a resum and a navigation of the session
%% +type affich_page({atom(),term()},webuser(),string()) -> webuser().
affich_page({?PAGE,"un"},Web,_) ->
    unknown_page(Web);
affich_page({?PAGE,Nom_Page},Web,Tag) ->
    affich_page_data("page_data",Nom_Page,Web,Tag);
affich_page({?NOPAGE,"un"},Web,_) -> unknown_page(Web);
affich_page({?NOPAGE,Nom_Page},Web,Tag)->
    affich_page_data("shortcut",Nom_Page,Web,Tag);
affich_page({?USER,Input},#webuser{prev=Row}=Web,_) ->
    Insert2 = ["<td class=\"user\">",
	       webmin:uni2pcdata8(Input),
	       "</td>\n"],
    Row1 = Row#row{c1=Insert2},
    Web#webuser{prev=Row1};

affich_page({?MENU,"resend"},#webuser{prev=Row}=Web,_) ->
    Row1 = Row#row{c2=message("resend",resumption)},
    Web#webuser{prev=Row1};

affich_page({?MENU,"Next Page"},#webuser{prev=Row}=Web,_)->
    Row1 = Row#row{c2=message("next_page",next_page)},
    Web#webuser{prev=Row1};

affich_page({?MENU,Input},#webuser{prev=Row}=Web,_) ->
    Input2 =  case length(Input) of
		  1 -> alpha_to_num(Input);
		  _ -> Input
	      end,
    Row1 = Row#row{c2 = message2("menu",Input2)},
    Web#webuser{prev = Row1};

affich_page({?ENTRY,Input},#webuser{prev=Row}=Web,_) ->
    Row1 = Row#row{c2 = message2("entry",Input)},
    Web#webuser{prev = Row1};

affich_page({?SERV,"code_"++Code}, #webuser{session=Session,prev=Row}=Web,_) ->
    Text = webuser_msgs:text(service),
    Message = io_lib:format("~s ~s#",[Text,Code]),
    Row1 = Row#row{c2=message2("server",Message)},
    Web#webuser{prev=Row1, session=Session#session{service_code=Code}};

affich_page({?SERV,"us_"++Code}, Web,Tags) ->
    affich_page({?SERV,"code_"++Code}, Web,Tags);

affich_page({?SERV,"up_"++Code}, #webuser{session=Session, prev=Row}=Web,_) ->
    Message = io_lib:format("Push ~s",[Code]),
    Row1 = Row#row{c2=message2("server",Message)},
    Web#webuser{prev=Row1, session=Session#session{service_code=Code}};

affich_page({?SERV,"un"}, #webuser{prev=Row}=Web,_) ->
    Row1 = Row#row{c2= message("server",unknown_service_code)},
    Web#webuser{prev= Row1};

affich_page({?SERV,Message}, #webuser{acc=Acc, prev=Row}=Web,_) ->
    {Color,Message_2} = affich_page_service(Message),
    Row1 = if Message == "hangup"; Message == "failure"; Message == "reject" ->
		   Row#row{c1=undefined,c3=message(Color,Message_2)};
	      true ->
		   Row#row{c3=message(Color,Message_2)}   
	   end,
    Web#webuser{acc=[Row1|Acc],prev=#row{}};

affich_page({Tariff,Plan}, #webuser{page=Row}=Web,_)
  when Tariff==?PT; Tariff==?OT->
    Message = make_link_taxation(Plan),
    Row1=Row#row{c5=["<td class=\"",webuser_msgs:text(tariff),"\">",Message,
		     "</td>"]},
    Web#webuser{page=Row1};

affich_page({?DURATION,Time}, #webuser{page=Row}=Web,_) ->
    Time2 = list_to_integer(Time) div 1000,
    Message = io_lib:format("~s",[integer_to_list(Time2)]),
    Row1=Row#row{c7=["<td class=\"",webuser_msgs:text(tariff),"\">",Message,
		     "</td>"]},
    Web#webuser{page=Row1};

affich_page({?CURRENCY,Price}, #webuser{page=Row}=Web,_) ->
    Message = io_lib:format("~s",[Price]),
    Row1=Row#row{c8=["<td class=\"",webuser_msgs:text(tariff),"\">",
		     Message,"</td>"]},
    Web#webuser{page=Row1};

affich_page({?ACTE,Price}, #webuser{acc=Acc, prev=Row}=Web,_) ->
    Message = io_lib:format("~s : ~s",[webuser_msgs:text(billing_act),Price]),
    Row1 = Row#row{c3= message2("tariff",Message)},
    Web#webuser{acc=[Row1|Acc],prev=#row{}};

affich_page({?DM,_}, Web,_) ->
    Web;

affich_page(Pbl, #webuser{acc=Acc, prev=Row }=Web,_) ->
    Text = webuser_msgs:text(error),
    Message = io_lib:format("~s : ~p",[Text,Pbl]),
    Row1 = Row#row{c3= message2("server",Message)},
    Web#webuser{acc=[Row1|Acc],prev=#row{}}.

%%% handle old version of next_page (no log tag page--> new line)
%% +type next_page_old(webuser()) -> webuser().
next_page_old(#webuser{acc=Acc, prev=Row}=Web)->
    Row1 = Row#row{c2=message("menu",next_page)},
    Web#webuser{acc=[Row1|Acc],prev=#row{}}.

%% +type unknown_page(webuser()) -> webuser().
unknown_page(#webuser{ref=Ref, prev=Row}=Web) ->
    Ref_S = Ref + 1,
    Acc2 = ["<td class=\"sessions\#>",
            io_lib:format("<a name=\"~p\"></a>",[Ref_S]),
	    webuser_msgs:text(not_referenced),"</td>\n"],
    Row1 = Row#row{c3=Acc2},
    Web#webuser{prev=Row1, ref=Ref_S}.

%% +type affich_page_data(CSS::string(),URL::string(),webuser(),
%%                        ModifyTag::string()) -> webuser().
affich_page_data(CSS,Page,#webuser{info=Info, ref=Ref, choice=Choice, 
				   acc=Acc, session=Session, bearer=Bearer,
				   uid=Uid, msisdn=Msisdn, subscription=Subscription,
                   prev=Row, page=Old, page_no=PageNo} = Web,
		 ModifyTag) ->
    {Duration,Price,Time,Detail} = Info,
    Ref_S = Ref + 1,
    {Pagelog,Session1} = custom_serv:affich_log(Page,Session),
    PageRef = webmin:esc_pcdata(Pagelog),
    List = webuser_layout:create_enum(Choice,""),
    Lang = (Session1#session.prof)#profile.lang,
    Code = Session1#session.service_code,
    Form = 
	[
	 %% POST this, as it is ugly in the address bar
	 "<form method=\"POST\" action=\"webuser_session_details_orangef:detail_ask\">\n",
	 "<input type=\"hidden\" name=\"a\" value=\"",Detail,"\">\n",
	 "<input type=\"hidden\" name=\"b\" value=\"",Duration,"\">\n",
	 "<input type=\"hidden\" name=\"c\" value=\"",Price,"\">\n",
	 "<input type=\"hidden\" name=\"d\" value=\"",Time,"\">\n",
	 "<input type=\"hidden\" name=\"e\" value=\"",Lang,"\">\n",
	 "<input type=\"hidden\" name=\"f\" value=\"",Code,"\">\n",
	 "<input type=\"hidden\" name=\"g\" value=\"",Bearer,"\">\n",
	 "<input type=\"hidden\" name=\"h\" value=\"",List,"\">\n",
	 "<input type=\"hidden\" name=\"i\" value=\"",
	 integer_to_list(Ref_S),"\">\n",
	 "<input type=\"hidden\" name=\"j\" value=\"",Uid,"\">\n",
	 "<input type=\"hidden\" name=\"modifytag\" value=\"",ModifyTag,"\">\n",
	 "<input type=\"hidden\" name=\"msisdn\" value=\"",Msisdn,"\">\n",
	 "<input type=\"hidden\" name=\"subscription\" value=\"",Subscription,"\">\n",
	 "<input type=\"hidden\" name=\"page\" value=\"",PageNo,"\">\n",
	 "<input type=\"submit\" class=\"bn\" value=\"",
	 webuser_msgs:text(details),
	 "\"></form>"],

    Bool = pbutil:get_env(webuser,unfold_pages) orelse
	lists:member(Ref_S,Choice),
    {N_Session,Page_af} = 
	case Bool of
	    true ->
		case custom_serv:affich(Page,Session1) of 
		    {error,Message} ->
			slog:event(warning,?MODULE,display_page_data,Message),
			{Session1,
			 ["<div class=\"page_data_error\">",
			  io_lib:format("<a name=\"~p\"></a>~p</div>",
					[Ref_S,Page])]};
		    {Result,Session2} ->
			{Session2,
 			 lists:flatten(
 			   ["<div class=\"",CSS,"\">",
			    io_lib:format("<a name=\"~p\"></a>",[Ref_S]),
			    oma_utf8:uni2utf8(lists:flatten(Result)),
			    "</div>"])}		
		end;
	    _ -> {Session1,""}
	end,
    %% every line has the same "Date" and "Hour"
    Row1=Row#row{c3=PageRef, c4=Form++"</br>"++Page_af,c5=Old#row.c5,c6=Old#row.c6},
    New_acc = replace(Acc,Old),
    Web#webuser{acc=[{replace,page}|New_acc],ref=Ref_S,
		session=N_Session, prev=#row{}, page=Row1}.

%% +type replace([{term(),term()}], undefined| {term(),term()}) ->
%%               [{term(),term()}].
replace(Acc,undefined) -> Acc;
replace(Acc,Page) -> lists:keyreplace(replace, 1, Acc, Page).

%%%% 
%% +type affich_page_service(string()) -> {string(),atom}.
affich_page_service("resend") -> {"resend",resumption};    
affich_page_service("timeout") -> {"error",end_timeout};
affich_page_service("end") -> {"end",end_software};
affich_page_service("billing") -> {"error",billing_error};
affich_page_service("hangup") -> {"server",end_user};
affich_page_service("bug") -> {"error",internal_platform_problem};
affich_page_service("bearer") -> {"server",handset_error};
affich_page_service("failure") -> {"error",end_network};  %%%%% generalisation
affich_page_service("forc_nav") -> {"server",force_nav};
affich_page_service("push_success") -> {"push",push_success};
affich_page_service("push_failed") -> {"push",push_failure};
affich_page_service(_) -> {"server",unknown_tag}.

%%%% prints a field of the table
%% +type message(CSS::string(), atom()) -> html().
message(CSS,Message) ->
    Mes2 = webuser_msgs:text(Message),
    message2(CSS,Mes2).

%% +type message2(CSS::string(), string()) -> html().
message2(CSS,Mes) ->
    ["<td class=\"",CSS,"\">",Mes,"</td>\n"].


%% +type create_line(integer(), row()) -> html().
create_line(6,#row{c1=A,c2=A,c3=A,c4=A}) when A == undefined -> [];
create_line(6,Row) ->
    %% The display order of the columns is adjustable on
    %% the customer's demand
    ["<tr class=\"sessions\">",
     print(Row#row.c2),
     print(Row#row.c1),
     print_tab(Row#row.c3),
     print_tab(Row#row.c5),
     print_tab(Row#row.c6),
     print_tab(Row#row.c4,"received"),
     "</tr>\n"];
create_line(8,#row{c1=A,c2=A,c3=A,c4=A,
		   c5=A,c6=A,c7=A,c8=A}) when A == undefined-> [];
create_line(8,Row) ->
    ["<tr class=\"sessions\">",
     print(Row#row.c1),print(Row#row.c2),
     print5(Row#row.c5),print5(Row#row.c6),
     print5(Row#row.c7),print5(Row#row.c8),
     print(Row#row.c3),print(Row#row.c4),
     "</tr>\n"];

%% +type create_line(row(), [integer(),integer(),list()]) -> html().
create_line(#row{c1=A,c2=A,c3=A,c4=A},[6,N,Acc]) when A == undefined -> 
    [6,N,Acc];
create_line(Row,[6,N,Acc]) ->
    Class_suffix = integer_to_list(N rem 2),
    %% The display order of the columns is adjustable on
    %% the customer's demand
    [6,N-1,[
    ["<tr class=\"sessions"++Class_suffix++"\">",
        print_tab(integer_to_list(N)),
     print(Row#row.c2),
     print(Row#row.c1),
     print_tab(Row#row.c3),
     print_tab(Row#row.c5),
     print_tab(Row#row.c6),
     print_tab(Row#row.c4,"received"),
     "</tr>\n"]|Acc]].

%% +type print(undefined | html()) -> html().
print(undefined) -> "<td class=\"sessions\"></td>";
print(X) -> X.

%% +type print_tab(string()) -> html().
print_tab(M)when is_list(M) -> "<td class=\"sessions\">"++M++"</td>";
print_tab(_) -> "<td class=\"sessions\"></td>".

%% +type print_tab_css(string(),string()) -> html().
print_tab(M,CSS)when is_list(M) -> "<td class="++CSS++">"++M++"</td>";
print_tab(_,_) -> "<td class=\"sessions\"></td>".

%% +type print5(undefined | html()) -> html().
print5(undefined) -> "<td class=\"empty_page\"></td>\n";
print5(X) -> X.

%%%% converted alphanumeric inout into numeric choice
%% +type alpha_to_num(string()) -> string().
alpha_to_num("+") -> "0";
alpha_to_num(" ") -> "1";
alpha_to_num("a") -> "2";
alpha_to_num("A") -> "2";
alpha_to_num("d") -> "3";
alpha_to_num("D") -> "3";
alpha_to_num("g") -> "4";
alpha_to_num("G") -> "4";
alpha_to_num("j") -> "5";
alpha_to_num("J") -> "5";
alpha_to_num("m") -> "6";
alpha_to_num("M") -> "6";
alpha_to_num("p") -> "7";
alpha_to_num("P") -> "7";	      
alpha_to_num("t") -> "8";
alpha_to_num("T") -> "8";
alpha_to_num("w") -> "9";
alpha_to_num("W") -> "9";	     
alpha_to_num(Else) ->   Else.




%% +type taxation_info() -> html().
taxation_info() ->
    File = pbutil:get_env(webuser,billing_file_path),
    case file:read_file(File) of
	{ok,Info} -> binary_to_list(Info);
	Error -> slog:event(internal, ?MODULE, failed_to_open_file, Error),
		 webuser_msgs:text(not_available)
    end.

%%%%
%% +type make_link_taxation([string()]) -> html().
make_link_taxation(Tarif) ->
    case pbutil:get_env(webuser,handled_billing) of
	undefined -> Tarif;
	List_Taxation ->
	    case lists:keysearch(Tarif,1,List_Taxation) of
		{value,{_,Name,Ref}} ->
		    io_lib:format("<a href=~s>~s</a>",[Ref,Name]);
		false -> Tarif
	    end
    end.

%% +type header(integer()) -> html().
header(6) ->
    headerize([number,int_server,customer_input,received_page,date,hour,details]);

header(8) ->
    headerize([customer_input,int_server,tariff_plan,others,duration,credit,
	       received_page,details]).


%% +type headerize([atom()]) -> html().
headerize(Headers) ->
    lists:map(fun(X) ->
		      ["<td class=\"sessions_header\">",
		       webuser_msgs:text(X),"</td>\n"]
	      end,Headers).

%% +type affich_date(integer())-> string().
affich_date(Seconds) ->
  {{Y,M,D},_} = calendar:now_to_local_time({0,Seconds,0}),
  lists:flatten(io_lib:format("~2..0w/~2..0w/~4..0w ",[D,M,Y])).


%%%% DOCUMENTATION
%% +type slog_info(Class::atom(),Module::atom(),SLog::term()) -> slog_info().
slog_info(internal, ?MODULE, failed_to_open_file) ->
    #slog_info{descr="Failed to open the file which contains the description "
	       "of the rating behaviour used by the customer care tool.\n"
	       "The text file is the one defined by"
	       " the parameter webuser::billing_file_path.",
	       operational="Check file permissions / existence."};
slog_info(warning,?MODULE,display_page_data) ->
    #slog_info{descr="Failed to open the page seen by the customer. It may"
	       " have been removed",
	       operational="Check the XML file"}.
