-module(svc_annuaire).

%%% Annuaire service main module

%%% Four main sections :
%%% 1. Navigation by heading
%%% 2. Navigation be editor
%%% 3. Misc. utilities functions

%%% Session logs :
%%% Following tags are added :

%%% * annuaire2|"T"|Theme
%%% * annuaire2|"T"|Theme|Heading
%%% * annuaire2|"T"|Theme(|Heading)?|Editor|sX : 1<=X<=5 (command number)  
%%% * annuaire2|"T"|Theme(|Heading)?|Editor|i  : more infos
%%% * annuaire2|"T"|Theme(|Heading)?|Editor|r  : rules (for games)
%%% * annuaire2|"T"|Theme(|Heading)?|Editor|c  : customer care (unused)
%%% * annuaire2|"T"|Theme(|Heading)?|Editor|d  : trigger SMS

%%% * annuaire2|"E"|Editor
%%% * annuaire2|"E"|Editor|Theme(|Heading)?|sX
%%% * annuaire2|"E"|Editor|Theme(|Heading)?|i
%%% * annuaire2|"E"|Editor|Theme(|Heading)?|r
%%% * annuaire2|"E"|Editor|Theme(|Heading)?|c
%%% * annuaire2|"E"|Editor|Theme(|Heading)?|d

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([guide_to_themes/1,themes/1,theme_to_editors_or_headings/2,
	 t_headings/1,heading_to_editor/2,t_editors/1,editor_to_services/2,
	 get_headings/1]).

-export([editors/3,e_list/1,editor_to_headings/2, e_headings/1,
	 heading_to_services/2]).

-export([log_service/2,display_service/2,ask_sms_param/4,send_sms/4,
	 sms_param/1,pre_more_info/3,more_info/1,rules/2]).


-include("../include/annuaire.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").

-define(SMODULE,atom_to_list(?MODULE)).
-define(SEP,$|).
-define(STATID,"annuaire2").
-define(COMMANDSLIMIT,5).

%%% Counters in OMA pages
-define(THEMEMODE,"T").
-define(EDITORMODE,"E").
-define(RULES,"r").
-define(MOREINFO,"i").
-define(SERVICES,"s").
-define(TRIGGERSMS,"d").

-define(ROUTINGATTR,"smsc_cg").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Funs dealing with navigation by theme
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type guide_to_themes(session()) -> erlpage_result().
guide_to_themes(abs) ->
    [{"DB contains some elements",{redirect,abs,"#themes"}},
     {"DB Empty",{redirect,abs,"#error"}}];

guide_to_themes(#session{log=Logs}=Session) ->

    %% Get all the themes
    case catch mnesia:dirty_match_object(#annuaire{_='_'}) of
	L when length(L) > 0 ->
	    %% Get list of unique themes in L
	    Themes   = extract_themes_links(L),
	    %% new record : get ready for a navigation by theme
	    %% clean unnecessary variables (if we come from a 0:menu link)
	    Data  = #next_page{mode           = ?THEMEMODE,
			       number         = '_',
			       themes_links   = Themes,
			       theme          = "",
			       headings_links = [],
			       heading        = "", 
			       editors_links  = [],
			       editor         = "",
			       tease_multi    = "",
			       results        = [],
			       end_info       = []},
	    New1Sess = variable:update_value(Session,annuaire_data,Data),
	    {redirect,New1Sess,"#themes"};

	Error ->
	    slog:event(internal,?MODULE,guide_to_themes,{db_error,Error}), 
	    {redirect,Session,"#error"}
    end.


%% +type themes(session()) -> erlinclude_result().
themes(abs) ->
    [#hlink{href="erl://"++?SMODULE++":theme_to_editors_or_headings?Themes",
	    contents=[{pcdata,"thematiques"}]}];

themes(Session) ->
    State = variable:get_value(Session,annuaire_data),
    Links = State#next_page.themes_links,
    display_links(Links,theme_to_editors_or_headings).  



%% +type theme_to_editors_or_headings(session(),string()) -> erlpage_result().
theme_to_editors_or_headings(abs,_) ->
    [{"Theme Mismatched",{redirect,abs,"#error"}} | 
     is_empty_headings(abs,abs)];

theme_to_editors_or_headings(Session,CodedTheme) ->
    Theme = svc_util_of:hex2bin(CodedTheme),
    case catch mnesia:dirty_match_object(#annuaire{theme=Theme,_='_'}) of

	%% All the services for a theme
	%% check if this theme is without headings (eg : chat)
	Annuaire when length(Annuaire) > 0 ->
	    is_empty_headings(Session,Annuaire);
	Error ->
	    slog:event(internal,?MODULE,theme_to_editors_or_headings,
		       {db_error,Error}),
	    {redirect,Session,"#error"}
    end.



%% +type is_empty_headings(session(),[annuaire()]) -> erlpage_result().
is_empty_headings(abs,_) ->
    [{"Theme matched - no headings",{redirect,abs,"#direct_theme_editors"}},
     {"Theme matched - normal",{redirect,abs,"#t_headings"}}];

is_empty_headings(#session{log=Logs}=Session, Annuaire) ->
    Data = variable:get_value(Session,annuaire_data),
%%% We test first item of list to see if this theme has some headings
%%% If not : go to editor choice 
%%% If so, go to headings selection

    [#annuaire{theme=Theme,heading=Heading }|_]=(Annuaire), 

    %% Log chosen theme for stats
    LoggedSession = Session#session{log=[{?DM,?STATID++[?SEP|?THEMEMODE] ++ 
					  [?SEP|Theme]} | Logs]},
    
    case Heading of 
	"" ->
	    %% No heading (chat) : extract editors in db order
	    Names   = extract_editors_links(Annuaire,db),
	    NewData = Data#next_page{theme          = Theme,
				     noheadings     = true,
				     headings_links = [],
				     editors_links  = Names},
	    Sess_no_head =
		variable:update_value(LoggedSession,annuaire_data,NewData),
	    {redirect, Sess_no_head, "#direct_theme_editors"};
	_  -> 
	    %% There are headings : extract them
	    Headings = extract_headings_links(Annuaire),
	    NewData  = Data#next_page{theme          = Theme,
				      noheadings     = false,
				      headings_links = Headings,
				      editors_links  = []},
	    Sess_head = 
		variable:update_value(LoggedSession,annuaire_data,NewData),
	    {redirect, Sess_head, "#t_headings"}
    end.



%% +type t_editors(session()) -> erlinclude_result().
t_editors(abs) ->
    [#hlink{href="erl://"++?SMODULE++":editor_to_services?Editors",
	    contents=[{pcdata,"editeurs"}]}];

t_editors(Session) ->
    State = variable:get_value(Session,annuaire_data),
    Links = State#next_page.editors_links,
    display_links(Links,editor_to_services).



%% +type t_headings(session()) -> erlinclude_result().
t_headings(abs) ->
    [#hlink{href="erl://"++?SMODULE++":heading_to_editor?Headings",
	    contents=[{pcdata,"rubriques"}]}];

t_headings(Session) -> 
    State = variable:get_value(Session,annuaire_data),
    Links = State#next_page.headings_links,
    display_links(Links,heading_to_editor).



%% +type heading_to_editor(session(),string()) -> erlpage_result().
heading_to_editor(abs,_) ->
    [{"Editor(s) found",{redirect,abs,"#t_editors"}},
     {"Editor not found",{redirect,abs,"#error"}}];

heading_to_editor(#session{log=Logs}=Session, CodedHeading) ->
    Data = variable:get_value(Session,annuaire_data),
    Theme = Data#next_page.theme,
    %%% Heading may contain some replaced characters to pass it as an argument
    %%% (eg : $&)
    Heading = svc_util_of:hex2bin(CodedHeading),

    %% Get all editors providing a heading
    case catch mnesia:dirty_match_object(
		 #annuaire{theme=Theme,heading=Heading,_='_'}) of
	L when length(L) > 0 ->
	    #next_page{theme=Theme} = Data,
	    Names    = extract_editors_links(L,db),
	    NewData  = Data#next_page{heading       = Heading,
				      editors_links = Names},
	    LoggedSession = 
		Session#session{log=[{?DM,?STATID ++ [?SEP|?THEMEMODE] ++ 
				      [?SEP|Theme] ++ [?SEP|Heading]}|Logs]},
	    Sess_new =
		variable:update_value(LoggedSession,annuaire_data,NewData),
	    {redirect, Sess_new, "#t_editors"};

	Error ->
	    slog:event(internal,?MODULE,theme_to_editors_or_headings,
		       {db_error,Error,Data}),
	    {redirect,Session,"#error"}
    end.



%% +type editor_to_services(session(),string()) -> erlpage_result().
editor_to_services(abs,_) ->
    [{"To Service",{redirect,abs,"erl://" ++ ?SMODULE ++":log_service?1"}},
     {"DB Error",{redirect,abs,"#error"}}];

editor_to_services(#session{log=Logs}=Session, CodedEditor) ->
    Data = variable:get_value(Session,annuaire_data),
    Editor  = svc_util_of:hex2bin(CodedEditor),

    #next_page{noheadings = NoHeadings,
	       theme      = Theme,
	       heading    = Heading} = Data,

    %% Get services of theme/heading from an editor
    Res = get_theme_editor(NoHeadings,Theme,Heading,Editor),

    case Res of
	[_|_] -> 
	    %% Cache results
	    NewData = Data#next_page{editor=Editor,number='_',results=Res},
	    Sess_new =
		variable:update_value(Session,annuaire_data,NewData),
	    log_service(Sess_new, "1");
	Error -> 
	    slog:event(internal,?MODULE,editor_to_service,
		       {db_error,Error,Data}),
	    {redirect,Session,"#error"}
    end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Funs dealing with navigation by editor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type editors(session(),From::string(),To::string()) -> erlpage_result().
editors(abs,_,_) -> 
    [{"Editor(s) found",{redirect,abs,"#editors_list"}},
     {"Editor not found",{redirect,abs,"#error"}}];

editors(#session{log=Logs} = Session,[From],[To]) ->   

    %% Get editors by blocks of letters
    case catch mnesia:dirty_match_object(#annuaire{_='_'}) of
	L when length(L) > 0 ->
	    GetName  = fun (#annuaire{name=Name}) -> Name end,
	    AllNames = lists:map(GetName,L),
	    Names    = sort_upper(extract_editors(From,To,AllNames)),

	    %% Creating new record
	    Data     = #next_page{mode           = ?EDITORMODE,	 
				  number         = '_',
				  themes_links   = [],
				  theme          = "",
				  headings_links = [],
				  heading        = "", 
				  editors_links  = Names,
				  editor         = "",
				  tease_multi    = "",
				  results        = [],
				  end_info       = [] },

	    %% Log for stats : Is this page interesting ?	 
	    %%   LoggedSession = 
	    %%	Session#session{log=[{?DM,?STATID ++ [?SEP|?EDITORMODE] ++
	    %%			      [?SEP|From]++[$a|To]}
	    %%			     | Logs]},
	    Sess_new =
		variable:update_value(Session,annuaire_data,Data),
	    {redirect,Sess_new, "#editors_list"};

	Error ->
	    slog:event(internal,?MODULE,editors,{db_error,Error}),
	    {redirect,Session,"#error"}
    end.



%% +type extract_editors(integer(),integer(),[string()]) -> [string()].
extract_editors(From,To,List) ->
    extract_editors(From,To,List,[]).


%% +type extract_editors(integer(),integer(),[string()],[string()]) ->
%%       [string()].
extract_editors(From,To,[[FC | _] = Name | Names],Acc) ->
    UpChar = pbutil:upcase(FC), 
    if
	((UpChar >= From) and (UpChar =<To)) ->
	    extract_editors(From,To,Names,[Name | Acc]);
	true -> 
	    extract_editors(From,To,Names,Acc)
    end;

extract_editors(_,_,[],Acc) -> 
    lists:reverse(Acc).



%% +type e_list(session()) -> erlinclude_result().
e_list(abs) ->
    [#hlink{href="erl://" ++ ?SMODULE ++":editor_to_headings?Editors",
	    contents=[{pcdata,"editeurs"}]}];

e_list(Session) -> 
    State = variable:get_value(Session,annuaire_data),
    Links = State#next_page.editors_links,
    display_links(Links,editor_to_headings).



%% +type editor_to_headings(session(),string()) -> erlpage_result().
editor_to_headings(abs,_) ->
    [{"Only one heading",{redirect,abs,"erl://"++?SMODULE++":log_service?1"}},
     {"Several headings",{redirect,abs,"#e_headings"}},
     {"No headings found",{redirect,abs,"#error"}}];		   

editor_to_headings(#session{log=Logs}=Session, CodedEditor) ->
    Data = variable:get_value(Session,annuaire_data),
    Editor  = svc_util_of:hex2bin(CodedEditor),
    NewData = Data#next_page{editor=Editor},

    %% Log for stats
    LoggedSession = 
	Session#session{log=[
			     {?DM,?STATID++[?SEP|?EDITORMODE] ++ 
			      [?SEP|Editor]}| Logs]},

    case catch mnesia:dirty_match_object(#annuaire{name=Editor,_='_'}) of

	[#annuaire{heading     = Heading,
		   theme       = Theme,
		   tease_multi = TeaseMulti} = A|Tail] = L ->
	    
	    %% Check if all the services from this editor have same heading
	    case has_one_head(Heading,Tail) of
		true ->	
		    %% Editor has only one kind of services : check if it has 
		    %% headings and go to services
		    NewData2 = check_empty_headings(A,NewData),
		    NewData3 = NewData2#next_page{results = L},
		    Sess_head = 
			variable:update_value(LoggedSession,annuaire_data,
					      NewData3),
		    log_service(Sess_head, "1");
		false ->
		    %% Editor has plenty of services : displays list of 
		    %% all headings + theme without headings
		    Headings = extract_themesheadings_links(L),
		    NewData2 = NewData#next_page{headings_links = Headings,
						 tease_multi    = TeaseMulti},
		    Sess_no_head = 
			variable:update_value(LoggedSession,annuaire_data,
					      NewData2),
		    {redirect, Sess_no_head, "#e_headings"}
	    end;

	Error ->
	    slog:event(internal,?MODULE,editor_to_headings,
		       {db_error,Error,Data}),
	    {redirect,Session,"#error"}
    end.



%% +type has_one_head(string(),[annuaire()]) -> bool().
has_one_head(OneHead,[#annuaire{heading=OneHead}|Annuaire]) ->
    has_one_head(OneHead,Annuaire);
has_one_head(_,[]) ->
    true;
has_one_head(_,_) ->
    false.


%% +type e_headings(session()) -> erlinclude_result().
e_headings(abs) ->
    [{pcdata,"Heading Teasers"},br,
     #hlink{href="erl://"++?SMODULE++":heading_to_services?Headings",
	    contents=[{pcdata,"rubriques"}]}];

e_headings(Session) ->
    Data = variable:get_value(Session,annuaire_data),
    #next_page{tease_multi=Teaser,headings_links=Links} = Data,

    [{pcdata,Teaser},br] ++
	display_links(lists:usort(Links), heading_to_services).



%%% When a precise category has been chosen, redirect to service page
%%% (Editor mode & Number mode)
%% +type heading_to_services(session(),string()) -> erlpage_result().
heading_to_services(abs,_) ->
    [{"Found Services",{redirect,abs,"erl://"++?SMODULE++":log_service?1"}},
     {"Service not found",{redirect,abs,"#error"}}];

heading_to_services(#session{log=Logs}=Session, CodedCategory) ->
    Data = variable:get_value(Session,annuaire_data),
    %% Category = theme (chat) or heading (other)
    Category = svc_util_of:hex2bin(CodedCategory),
    #next_page{mode=Mode,number=Number,editor=Editor} = Data,  

    MatchHead = case Mode of
		    "E" ->
			#annuaire{name    = Editor,
				  theme   = '$1',
				  heading = '$2',
				  _       = '_'};
		    "N" ->
			#annuaire{number  = Number,
				  theme   = '$1',
				  heading = '$2',
				  _       = '_'}
		end,
    Guard = {'orelse',{'=:=', '$2', Category},
	     {'andalso',{'=:=', '$2', ""},{'=:=', '$1', Category}}},

%%% Get asked services (even if without headings) 
    case catch mnesia:dirty_select(annuaire,
				   [{MatchHead,[Guard], ['$_']}]) of

	[#annuaire{heading=Heading,theme=Theme} = Annuaire| _ ]  = Res->
	    #next_page{noheadings=NH} = NewData_temp = 
		check_empty_headings(Annuaire,Data),
	    Log = case NH of
		      true ->
			  Theme ++ [?SEP];
		      _ ->
			  Theme ++ [?SEP|Heading]
		  end,  
	    NewData = 
		case Mode of
		    "E" ->
      			 NewData_temp#next_page{number='_',results=Res};
		    "N" ->
			 NewData_temp#next_page{editor='_',results=Res}
		end,
	    Sess_new = 
		variable:update_value(Session,annuaire_data,NewData),
	    log_service(Sess_new, "1");

	%% Basically, this case may happen because of a DB update
	Error -> 
	    slog:event(internal,?MODULE,heading_to_services,
		       {db_error,Error,Data}),
	    {redirect,Session,"#error"}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Funs dealing with services (last pages)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% We want the back link to work properly. As we have a maximum of 5 services
%%% per editor/heading, each one will be displayed using a different tag,
%%% thus allowing back link to work.
%% +type log_service(session(),string()) -> erlpage_result().
log_service(abs,_) ->
    [{"Log Service 1 access",{redirect,abs,"#service1"}},
     {"Log Service 2 access",{redirect,abs,"#service2"}},
     {"Log Service 3 access",{redirect,abs,"#service3"}},
     {"Log Service 4 access",{redirect,abs,"#service4"}},
     {"Log Service 5 access",{redirect,abs,"#service5"}}];

log_service(Session,Number) ->
    Session1 = log_browsing(Session,?SERVICES ++ Number),
    {redirect,Session1,"#service" ++ Number}.


%%%% Display service by number (corresponds to tag number in xml file)
%% +type display_service(session(),string()) -> erlinclude_result().
display_service(abs,NUM) ->
    NextNum = integer_to_list(
		case list_to_integer(NUM)+1 of
		    ?COMMANDSLIMIT+1 -> ?COMMANDSLIMIT;
		    Else -> Else
		end),
    Next = pbutil:get_env(pservices_orangef,annuaire_next_tag),
    [{pcdata,"Service Command"},br,
     #hlink{href="erl://" ++ ?SMODULE ++ ":send_sms?NUMBER&KEY&NOPARAM",
	    contents=[{include,{relurl,"#send_sms_link"}}]},{pcdata," OR "},
     #hlink{href="erl://" ++ ?SMODULE ++ ":ask_sms_param?NUMBER&KEY&PARAM",
	    contents=[{include,{relurl,"#send_sms_link"}},{pcdata,"(PARAM)"}]},
     br,
     #hlink{href="erl://"++?SMODULE++":pre_more_info?RULES&TEASER",
	    contents=[{include,{relurl,"#more_info_link"}}]},br,
     #hlink{href="#service"++NextNum,
	    contents=[{pcdata,Next}]}];

display_service(Session, String_N) ->
    Data = variable:get_value(Session,annuaire_data),
    Unsorted = Data#next_page.results,
    %% Be sure to put newer services first (needed for R8B0)
    Annuaire = lists:sort(fun (#annuaire{key=Key1_},#annuaire{key=Key2_}) -> 
				  Key1_ < Key2_ end,Unsorted),

    N = list_to_integer(String_N),
    {#annuaire{number       = Number,
	       services     = Services,
	       rules        = Rules,
	       tease_head   = Teaser},M,Last} = 
	get_nth_service(Annuaire,N),

    #annu_service{command=Command,key=Key,param=Param} = lists:nth(M,Services),

    %% The text for the link to next number
    Next = pbutil:get_env(pservices_orangef,annuaire_next_tag),
       
    %% Tests whether we reached the limit of services 
    OverLimit =  N >= ?COMMANDSLIMIT, 
    Next_Link = case (Last or OverLimit) of
		    true ->
			[];
		    false ->
			NextN = integer_to_list(N+1),
			[br,#hlink{href="erl://svc_annuaire:log_service?" ++ 
				   NextN,
				   contents=[{pcdata,Next}]}]
		end,
    Send_Link_Text = {include,{relurl,"#send_sms_link"}},
    Send_Link = case Param of
		    "" ->  
			#hlink{href="erl://" ++ ?SMODULE ++ ":send_sms?" ++ 
			       Number ++ "&" ++ Key ++ "&",
			       contents=[Send_Link_Text]};
		    _ ->
			#hlink{href="erl://"++?SMODULE++":ask_sms_param?" ++ 
			       Number ++ "&" ++ Key ++ "&" ++  
			       svc_util_of:bin2hex(Param),
			       contents=[Send_Link_Text]}
		end,
    [{pcdata,Command},br,
     Send_Link,br, 
     #hlink{href="erl://"++?SMODULE++":pre_more_info?" ++
	    svc_util_of:bin2hex(Rules) ++ "&" ++ svc_util_of:bin2hex(Teaser),
	    contents=[{include,{relurl,"#more_info_link"}}]}] ++ Next_Link.


%% +type send_sms(session(),string(),string(),string()) ->  
%%       erlpage_result().
send_sms(abs,_,_,_) ->
    [{"SMS successfully sent",{redirect,abs,"#sms_ok"}}];
%%     {"SMS failed to be sent",{redirect,abs,"#sms_nok"}}];
	 
send_sms(#session{log=Log}=Session,Number,Key,Param) ->
    Arg = case {Key,Param} of
	      {"",_} -> Param;
	      {_,""} -> Key;
	      {_,_} -> Key ++ [32 | Param]
	  end,
    Session1 = log_browsing(Session,?TRIGGERSMS),
    
    %% We do not test whether sms-mo was successfully sent
    svc_util:send_sms_mo(Session1,?ROUTINGATTR,Arg,Number),
    {redirect,Session1,"#sms_ok"}.

%% +type ask_sms_param(session(),string(),string(),string()) -> 
%%       erlpage_result().
ask_sms_param(abs,_,_,_) -> 
    [{"Ask SMS Parameter",{redirect,abs,"#sms_param"}}];

ask_sms_param(Session,Number,Key,CParam) ->
    Data = variable:get_value(Session,annuaire_data),
    Param = svc_util_of:hex2bin(CParam),
    NewData = Data#next_page{end_info = [Key,Number,Param]},
    Sess_new = 
	variable:update_value(Session,annuaire_data,NewData),
    {redirect, Sess_new, "#sms_param"}.


%% +type sms_param(session()) -> erlinclude_result().
sms_param(abs) ->
    [#form{action="erl://"++?SMODULE++":send_sms?NUMBER&KEY",
	   contents = [#entry{prompt=[{pcdata,"PARAM"}],type=text}]}];

sms_param(Session) -> 
    Data = variable:get_value(Session,annuaire_data),
    [Key,Number,Param] = Data#next_page.end_info,
    [#form{action="erl://"++?SMODULE++":send_sms?" ++ Number ++ "&" ++ Key,
	   contents = [#entry{prompt=[{pcdata,Param}],type=text}]}].


%%%% Load more info text from session (an include is following)
%% +type pre_more_info(session(),string(),string()) -> erlinclude_result().
pre_more_info(abs,_,_) ->
    [{"Fill fields",{redirect,abs,"#more_info"}}];
     
pre_more_info(Session, CRules, CTeaser) ->
    Data = variable:get_value(Session,annuaire_data),
    NewData = Data#next_page{end_info = [CRules,CTeaser]},
    Sess_new = 
	variable:update_value(Session,annuaire_data,NewData),
    {redirect, Sess_new, "#more_info"}.

%% +type more_info(session()) -> erlinclude_result().
more_info(abs) ->
    [{pcdata,"Teaser"},br,
     #hlink{href="erl://"++?SMODULE++":rules?Rules",
	    contents=[{include,{relurl,"#text_rules_jeux"}}]}];

more_info(Session)->
    Data = variable:get_value(Session,annuaire_data),
    Heading = Data#next_page.heading,
    [CRules,CTeaser] = Data#next_page.end_info,
    Teaser = svc_util_of:hex2bin(CTeaser),

    RulesHeadings = pbutil:get_env(pservices_orangef,annuaire_rules_headings),
    
    %% If service is a game, then display rules information
    ExtraLink = 
	case lists:member(Heading,RulesHeadings) of
	    true -> 
		[br,#hlink{href="erl://"++?SMODULE++":rules?"++
			   CRules,
			   contents=[
				     {include,{relurl,"#text_rules_"++Heading}}
				    ]}];
	    _ -> 
		[]
	end,
    [{pcdata,Teaser}] ++ ExtraLink.



%% +type rules(session(),string()) -> erlpage_result().
rules(abs,_) ->
    [{"To rules",{redirect,abs,"#rules",["RULES"]}}];

rules(Session,CRules) -> 
    Rules = svc_util_of:hex2bin(CRules),
    LoggedSession = log_browsing(Session,?RULES),
    {redirect,LoggedSession,"#rules",[{"RULES",Rules}]}.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UTILS
%%%%%%%%%%%%%%%%%%%%%%

%%% Given a list of strings and a function, make links out of this list
%%% towards this function
%% +type display_links([string()],string()) -> erlinclude_result().
display_links(Links,Fun) -> 
    Function   = atom_to_list(Fun), 
    ModFun     = ?SMODULE ++ [$: | Function],
    display_links(Links,[],ModFun).

%% +type display_links([string()],erlinclude_result(),string()) ->
%%       erlinclude_result().
display_links([Text],Acc,ModFun) ->
    Link = #hlink{href="erl://" ++ ModFun ++ [$? | svc_util_of:bin2hex(Text)], 
		  contents=[{pcdata,Text}]},
    lists:reverse([Link | Acc]);

display_links([Text | Texts],Acc,ModFun) ->
    Link = #hlink{href="erl://" ++ ModFun ++ [$? | svc_util_of:bin2hex(Text)],
		  contents=[{pcdata,Text},br]},
    display_links(Texts,[Link | Acc],ModFun);

display_links([],_,_) -> 
    slog:event(internal,?MODULE,display_links,no_texts),
    [].



%%% Fun used to print preposition + category of a page, checking good 
%%% preposition to use (vowel or consonant) :
%%% "de divertissement" | "d'horoscope"
%% +type get_headings(session()) -> erlinclude_result().
get_headings(abs) ->
    [{pcdata,"(de | d') <nom de rubrique>"}];

get_headings(Session) ->
    Data = variable:get_value(Session,annuaire_data),
    Theme = Data#next_page.theme,
    case Theme of
	[] -> [];
	_ ->
	    case lists:member(hd(Theme),[$a,$e,$i,$o,$u,$y,$h]) of
		true ->
		    [{include,{relurl,"#pre_vowel"}},{pcdata,Theme}];
		_-> 
		    [{include,{relurl,"#pre_consonant"}},{pcdata,Theme}]
	    end
    end.


%%%% Get ultimate results
%% +type get_theme_editor(bool(),string(),string(),string()) -> [annuaire()].
get_theme_editor(true, Theme, _, Editor) ->
    catch mnesia:dirty_match_object(#annuaire{theme = Theme,
					      name  = Editor,
					      _     = '_'});

get_theme_editor(false, Theme, Heading, Editor) ->
    catch mnesia:dirty_match_object(#annuaire{theme   = Theme,
                                              heading = Heading,
					      name    = Editor,
					      _       = '_'}).

%%%% Fun saying if a theme has some headings (chat has not)
%% +type check_empty_headings(annuaire(),next_page()) -> next_page().
check_empty_headings(#annuaire{heading="",theme=Theme},Data) ->
    Data#next_page{noheadings=true,theme=Theme};

check_empty_headings(#annuaire{heading=Heading,theme=Theme},Data) ->
    Data#next_page{noheadings=false,theme=Theme,heading=Heading}.



%%% Log a page once service has been found
%% +type log_browsing(session(),string()) -> session().
log_browsing(#session{log=Logs}=Session, Kind) -> 
    Data = variable:get_value(Session,annuaire_data),
    #next_page{mode       = Mode,
	       noheadings = NoHeadings,
	       theme      = Theme,
	       heading    = Heading,
	       number     = Number,
	       editor     = Editor} = Data,

    Common =  [?SEP | Kind],

    Log = case {Mode,NoHeadings} of
	      {?THEMEMODE,true} -> 
		  ?THEMEMODE ++ [?SEP | Theme] ++ [?SEP,?SEP | Editor] ++
		      Common ;
	      {?THEMEMODE,false} -> 
		  ?THEMEMODE ++ [?SEP | Theme] ++ [?SEP | Heading] ++ 
		      [?SEP | Editor] ++ Common;
	      {?EDITORMODE,true} ->
		  ?EDITORMODE ++ [?SEP | Editor] ++ [?SEP | Theme] ++
		      [?SEP | Common]; 
	      {?EDITORMODE,false} ->
		  ?EDITORMODE ++ [?SEP | Editor] ++ [?SEP | Theme] ++
		      [?SEP | Heading] ++ Common 
	  end,
    Session#session{log=[{?DM,?STATID ++ [?SEP|Log]} | Logs]}.



%% +type sort_upper([string()]) -> bool().
sort_upper(List) ->
    List2 = lists:sort(fun(A,B) -> 
			       httpd_util:to_upper(A) < httpd_util:to_upper(B)
		       end,List),
    %% lists:usort/2 should handle this, but creates duplicatas
    lists:usort(List2).



%%% Create editors links
%% +type extract_editors_links([annuaire()],Order::atom()) -> [string()].
extract_editors_links(Annuaire,alpha) ->
    GetEditor = fun (#annuaire{name=Name}) -> Name end,
    AllNames  = lists:map(GetEditor,Annuaire),
    sort_upper(AllNames);

extract_editors_links(Annuaire,db) ->				 
    %% Preliminary step needed for R8B0 
    SortEditor = fun (#annuaire{key=Key1_},#annuaire{key=Key2_}) -> 
			Key1_ < Key2_ end,
    SortedAnnuaire = lists:usort(SortEditor,Annuaire),

    %% Extract editors name
    GetEditor = fun (#annuaire{name=Name}) -> Name end,
    CompleteList = lists:map(GetEditor,SortedAnnuaire),
    
    %% Does a list of unique editors 
    %% Reversed left fold so that "new" services are printed first, 
    %% even if the same editor has an entry at the end of the list
    lists:reverse(lists:foldl(fun(E,AccIn) ->
				      case lists:member(E,AccIn) of
					  true  ->
					      AccIn;
					  false ->
					      [E|AccIn]
				      end
			      end,[], CompleteList)).



%%% Create themes links
%% +type extract_themes_links([annuaire()]) -> [string()].
extract_themes_links(Annuaire) ->
    GetThemes = fun (#annuaire{theme=Theme}) -> Theme end,
    AllThemes = lists:map(GetThemes,Annuaire), 
    lists:usort(AllThemes).


%%% Create headings links
%% +type extract_headings_links([annuaire()]) -> [string()].
extract_headings_links(Annuaire) ->
    GetHeadings  = fun (#annuaire{heading=Heading}) -> Heading end,
    AllHeadings = lists:map(GetHeadings,Annuaire),
    lists:usort(AllHeadings).



%%% Create headings + themes without headings links
%% +type extract_themesheadings_links([annuaire()]) -> [string()].
extract_themesheadings_links(Annuaire) ->
    GetHeadings = fun (#annuaire{theme=Theme,heading=Heading})->
			  case Heading of 
			      "" -> Theme;
			      _ -> Heading
			  end end,
    ThemesHeadings = lists:map(GetHeadings,Annuaire),
    lists:usort(ThemesHeadings).



%% +type get_nth_service(annuaire(),integer()) -> 
%%       {annuaire(),integer(),bool()}.
get_nth_service([#annuaire{number=Number,services=Services}=A | Annuaire],N) ->
    Total = length(Services), 
    if
	(Total < N) ->
	    get_nth_service(Annuaire,N - Total);
	true ->
	    %% returns the number, service, and if this is the last service or
	    %% not (to know if we have to display the "Next" link
	    {A,N,(Annuaire == [] andalso Total == N)}
    end.
