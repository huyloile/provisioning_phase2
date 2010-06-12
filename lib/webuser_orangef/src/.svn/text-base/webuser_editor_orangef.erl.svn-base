-module(webuser_editor_orangef).

-include("../../pserver/include/pserver.hrl").
-include("../../oma_webmin/include/webmin.hrl").
-include("../../webuser/include/webuser.hrl").

-export([print_row/3,edit_row/4]).

-export([edit_webuser/5]).

-export([wrap_form/4]).

%%%% This module implements Webuser editors using oma_webmin callbacks
%%%% It fits with Webuser layout.

-define(TERMINAL_SIZES,[any,182,181,160,130,64]).
-define(TERMINAL_UCSSIZES,[any,80,64,32]).

%%%% DOCUMENTATION
-export([slog_info/3]).
-include("../../oma/include/slog.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Print & Edit equivalent of OMA webmin, formated as rows
%%% Used for quick desc & tabs

%% +type print_row(ustring(),string(),webuser_field_type()) -> html().
print_row(Text,Value,Type) ->

    %% Do not show a row without information
    case print(Value,Type) of
	[] ->
	    [];
	Else ->
	    ["<tr><td>",webmin:esc_pcdata(Text),"</td>\n",
	     "<td>",Else,"</td></tr>"]
    end.


%%%% Displays Text in the left cell, and form in the right one
%% +type edit_row(ustring(),term(),webuser_field_type(),wu_cb()) -> html().
edit_row(Text,Value,{print,Type},CB) ->
    print_row(Text,Value,Type);
%%%% Orange France display imei setting in a different layout
edit_row(Text,Value,{webuser_type,{imei_setting,_}}=Type,CB) ->
    {HTML,ParseCB} = edit(Value,Type,CB),
    CB2 = fun(Env,Input) -> CB(Env,Input,ParseCB(Env,Input)) end,
    Label = webuser_msgs:text(confirm),
    HTML2 = wrap_form([], Label, Type, CB2),

    [HTML,"<tr align=\"right\"><td>",HTML2,"</td></tr>"];

edit_row(Text,Value,Type,CB) ->
    {HTML,ParseCB} = edit(Value,Type,CB),
    HTML2 = 
	case ParseCB of
	    no_parser -> HTML;
	    _ ->
		CB2 =
		    fun(Env,Input) ->
			    CB(Env,Input,ParseCB(Env,Input))
		    end,
		Label = webuser_msgs:text(update),

		wrap_form(HTML, Label, Type, CB2)
	end,

    ["<tr><td class=\"tab_label\">",webmin:esc_pcdata(Text),"</td>\n",
     "<td class=\"tab_edit\">",HTML2,"</td></tr>"].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Common editor. Can be used for svcprofiles records whose fields are
%%%  standard types
%%%% RefreshCB is defined in webuser_layout:show_sessions/5

%% +type edit_webuser(profile(),Svc::string(),fields_config(),
%%                    Fields::[tuple()],wu_cb()) -> {ok,html()} | {nok,string}.
edit_webuser(P,Svc,FieldsConf,Fields,CB) ->

%%% Retrieve service information from database
    FakeSession = #session{prof=P},
    case db:lookup_svc_profile(FakeSession,Svc) of
	{ok,Data} ->
	    Pairs = oma_util:record_to_pairs(Fields,Data),
	    {ok,edit_webuser_tab(P,Svc,Data,FieldsConf,Fields,Pairs,CB)}; 
	not_found ->
	    {nok,webuser_msgs:text(no_profile)};
	Else -> exit(Else)
    end.



%%%%%% Webuser replacement for webmin_callback:wrap_form/3
%%%%%% - POST url is different
%%%%%% - Do not print the update button if list
%%%%%% 
%% +type wrap_form(html(), string(), term(), http_callback()) -> html().
wrap_form(Entries,Label,{oma_type,{list,_}},Callback) ->
    Tag = webmin_callback:create(Callback),
    [ "<form class=\"left\" method=\"POST\" action=\""?UPDATE_URL"\">\n",
      Entries,
      "</form>"
     ];
wrap_form(Entries,Label,Type,Callback) ->
    Tag = webmin_callback:create(Callback),
    [ "<form method=\"POST\" action=\""?UPDATE_URL"\">\n",
      Entries,
      "<input type=\"submit\" name=\"act", Tag, "\" value=\"", Label, "\">",
      "</form>"
     ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Print %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Displays a value. Result should be some escaped unicode 
%% +type print(term(), webuser_field_type()) -> html().
print(Value,{print,Type}) ->
    print(Value,Type);

%%% No Value cases
print({na,_},Type) ->
    print_undef(undefined);
print(undefined,Type) ->
    print_undef(undefined);

%%% Something from OMA
print(Value,{oma_type,Type}) ->
    {Module,Options} = webmin:editor_of_type(Type),	    
    Module:print(Options,Value);

%%% Barring
print([],{webuser_type,barring}) ->
    webuser_msgs:text(no_barring);
print(Value,{webuser_type,barring}) ->
    lists:flatmap(fun(ACL) -> atom_to_list(ACL) ++ " " end,Value);

%%% Unixtime
print(Value,{webuser_type,unixtime}) when integer(Value)->
    [webuser_util:affich_date_hour(Value)];
print(Value,{webuser_type,unixtime}) when list(Value)->
    case catch list_to_integer(Value) of
	{'EXIT',_} -> print(undefined,{webuser_type,unixtime});
	Int -> print(Int,{webuser_type,unixtime})
    end;
print(Value,{webuser_type,unixtime}) when atom(Value) ->
    print(undefined,{webuser_type,unixtime});

%%% Handset
print(Terminal,{webuser_type,handset_select}) ->
    #terminal{manufac=Manuf,model=Model} = Terminal,
    [print_undef(Manuf),"/", print_undef(Model)];

print(Terminal,{webuser_type,handset_manufac}) ->
    #terminal{manufac=Manuf} = Terminal,
    [print_undef(Manuf)];

print(Terminal,{webuser_type,handset_model}) ->
    #terminal{model=Model} = Terminal,
    [print_undef(Model)];

print(Terminal,{webuser_type,{handset_editor,Fields}}) ->
    ["<table class=\"list_left\">",
     lists:map(fun(Field) ->
		       ["<tr><td>",webuser_msgs:text(Field),
			":</td><td>",print_handset_field(Field,Terminal),
			"</td></tr>\n"]
	       end,Fields),
     "</table>"];

print(Terminal,{webuser_type,handset_phase}) ->
    #terminal{human_ph=HumanPH,ussd15=USSD15} = Terminal,
    [terminal_to_phase(HumanPH,USSD15)];

print(Terminal,{webuser_type,handset_size}) ->
    #terminal{ussdsize=S} = Terminal,
    [integer_to_list(S)];

%%% What is the point ?
print(Terminal,{webuser_type,handset_reset}) ->
    "-";

print(#terminal{ussdsize=USSD_size},{webuser_type,{handset_choose_imei,_}}) ->
    Level = 
        case catch integer_to_list(terminal_of:ussd_level(USSD_size)) of
            {'EXIT', _} -> "inconnu";
            Integer -> Integer
        end,
    webmin_edit_string:print([],"Niveau " ++ Level);

print(#terminal{imei=IMEI},{webuser_type,handset_imei}) ->
    webmin_edit_string:print([],IMEI).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Edit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type edit(term(),webuser_field_type(),wu_cb()) -> {html(),parse_wu_cb()}.

%%% No edition mode (useless since clause should have matched in edit_row ?)
edit(Value,{print,Type},_) ->
    {print(Value,Type),no_parser};

%%% Standard OMA
edit(Value,{oma_type,Type},RefreshCB) ->
    {Mod, Data} = webmin:editor_of_type(Type),
    Mod:edit(Data, Value, RefreshCB);

%%% Barring
%%% Special editor that opens another page
edit(Barring,{webuser_type,barring}=T,RefreshCB) ->
    Label = webuser_msgs:text(select),
    CallBack = fun(Env,Input) ->
		       select_barring(RefreshCB,Barring)
	       end,
    Entries = print(Barring,{webuser_type,barring}),

    {wrap_form(Entries,Label,T,CallBack),no_parser};

%%% Unixtime
%%% TODO : Lack of a country-dependant date format
edit(UnixTime,{webuser_type,unixtime},RefreshCB) ->
    CurrentDate = lists:flatten(print(UnixTime,{webuser_type,unixtime})),
    {HTMLDate,HTMLTime} =
	case catch string:tokens(CurrentDate," ") of
	    [D,T] -> {D,T};
	    _ -> {"DD-MM-YYYY","HH:MM:SS"}
	end,

    Parser =
	fun(Env,Vars) ->
		GetString = 
		    fun(Name, Format) ->
			    {value, {_, V}} = lists:keysearch(Name, 1, Vars),
			    {ok, R, []} = io_lib:fread(Format, V),
			    R
		    end,

		case catch {GetString("date","~d-~d-~d"),
			    GetString("time","~d:~d:~d")} of
		    {[DD,MM,YY],[HH,MN,SS]} ->
			DT = {{YY,MM,DD},{HH,MN,SS}},
			case catch %%% localtime -> UT -> Unixtime
			    pbutil:universal_time_to_unixtime(
			      oma:local_time_to_universal_time(DT)) of
			    {'EXIT',Reason} ->
				{nok,bad_time_format};
			    Result ->
				{ok,Result}
			end;
		    Else ->
			{nok,bad_time_format}
		end
	end,

    HTML =
	[
	 "<input type=\"text\" name=\"date\" maxlength=\"10\" size=\"10\" "
	 "value=\"", HTMLDate, "\"></input>",
	 "&nbsp;&nbsp;\n",
	 "<input type=\"text\" name=\"time\" maxlength=\"8\" size=\"8\" "
	 "value=\"",HTMLTime,"\"></input>\n"
	],
    {HTML,Parser};

%%% Handset editors.
%%% We edit the terminal imei field, as #profile.imei is not updated
%%% with db:update_profile

%% First editor : choose handset in a list (not implemented yet)
edit(Terminal,{webuser_type,handset_select}=T,RefreshCB) ->
    Label = webuser_msgs:text(select_handset),

%%% We do not want to read the whole mnesia table terminal if not needed
%%% => trigger a special edition mode instead (same as barring)

    CallBack = fun(Env,Input) ->
		       select_handset(RefreshCB,Terminal)
	       end,

    Entries = print(Terminal,{webuser_type,handset_select}),
    
    {wrap_form(Entries,Label,T,CallBack),no_parser};

%% Second editor : select handset features in mnesia DB
edit(Terminal,{webuser_type,{handset_editor,Fields}},RefreshCB) ->
    HTMLCBs = 
	lists:foldr(fun(Field,Acc) ->
			    [edit_handset_field(Field,Terminal) | Acc]
		    end,[],Fields),
    
    ParseCB = 
	fun(Env,Vars) ->
		InitTerm =  #terminal{_ = '_'},
		RequestFun =
		    fun({handset_phase,{_,CB}},CurrentTerm) ->
			    {ok,AtomPhase} = CB(Env,Vars),
			    {NewHuman,NewUSSD15} =
				case AtomPhase of
				    phase_2  -> {2,false};
				    phase_15 -> {2,true};
				    phase_1  -> {1,false}
				end,
			    CurrentTerm#terminal{human_ph = NewHuman,
						 ussd15   = NewUSSD15};
		       ({handset_size,{_,CB}},CurrentTerm) ->
			    {ok,NewSize} = CB(Env,Vars),		       
			    CurrentTerm#terminal{ussdsize=any_ize(NewSize)};
		       ({handset_endsize,{_,CB}},CurrentTerm) ->
			    {ok,NewEndSize} = CB(Env,Vars),		       
			    CurrentTerm#terminal{
			      end_ussdsize=any_ize(NewEndSize)};
		       ({handset_ucs,{_,CB}},CurrentTerm) ->
			    {ok,NewUCS} = CB(Env,Vars),		       
			    CurrentTerm#terminal{allow_ucs=NewUCS};
		       ({handset_ucs_size,{_,CB}},CurrentTerm) ->
			    {ok,NewUCSSize} = CB(Env,Vars),		       
			    CurrentTerm#terminal{ucs_size=any_ize(NewUCSSize)};
		       ({handset_ucs_endsize,{_,CB}},CurrentTerm) ->
			    {ok,NewUCSEndSize} = CB(Env,Vars),		       
			    CurrentTerm#terminal{
			      ucs_endsize=any_ize(NewUCSEndSize)}
		    end,
		
		RequestTerm = lists:foldl(RequestFun,InitTerm,HTMLCBs),
		
		case RequestTerm of
		    Terminal ->
			%% no change
			{nok,update_not_necessary};
		    _ ->
			process_terminal_change(RequestTerm)		
		end
	end,


    {["<table class=\"list\">\n",
      lists:map(fun({Field,{HTMLField,_}}) ->
			["<tr><td>",webuser_msgs:text(Field),
			 " :</td><td class=\"right\">",HTMLField,"</td></tr>"]
		end,HTMLCBs),
      "</table>\n"],ParseCB};

%% Third one : reset to NULL
edit(Terminal,{webuser_type,handset_reset},RefreshCB) ->
    ParseCB = 
	fun(Env,Vars) ->
		{ok,#terminal{imei="NULL"}}
	end,
    {[],ParseCB};

%% Fourth : IMEI Select
edit(#terminal{imei=IMEI},
     {webuser_type,{handset_choose_imei,Choices}},RefreshCB) ->
    {HTML, ParseCB} =
	webmin_edit_popup:edit(Choices,IMEI,no_refresh),
    ParseCB2 = 
	fun(Env,Vars) ->
		case catch ParseCB(Env,Vars) of
		    {ok,NewIMEI} ->
			{ok,#terminal{imei=NewIMEI}};
		    _ ->
			{nok,update_not_done}
		end
	end,
    {HTML,ParseCB2};

%% Fifth : Enter IMEI
edit(#terminal{imei=IMEI},{webuser_type,handset_imei},RefreshCB) ->
    {HTML, ParseCB} =
	webmin_edit_string:edit([{cols,15}],IMEI,no_refresh),
    ParseCB2 = 
	fun(Env,Vars) ->
		case catch ParseCB(Env,Vars) of
		    {ok,NewIMEI} ->
			case {length(NewIMEI)>=6,pbutil:all_digits(NewIMEI)} of
			    {true,true} ->
				NewIMEI2 = string:left(NewIMEI,15,$0),
				{ok,#terminal{imei=NewIMEI2}};
			    _ ->
				{nok,bad_imei_format}
			end;
		    _ ->
			{nok,update_not_done}
		end
	end,
    {HTML,ParseCB2};

%% imei setting form (OF specific)
edit(#terminal{imei=IMEI},
     {webuser_type,{imei_setting,[{webuser_imei,Actions},
                 {handset_choose_imei,Choices}]}},RefreshCB) ->
    HTML_Radio = lists:map(fun imei_action/1, Actions),
    {HTML_Select, ParseCB} =
	webmin_edit_popup:edit(Choices,IMEI,no_refresh),
    ParseCB2 = 
    fun(Env,Vars) ->
        case lists:keysearch("imei_action", 1, Vars) of
            {value, {_,"reset"}} ->
                {ok,#terminal{imei="NULL"}};
            {value, {_,"level_orange_ocf"}} ->
                case catch ParseCB(Env,Vars) of
                    {ok,NewIMEI} ->
                        {ok,#terminal{imei=NewIMEI}};
                    _ ->
                        {nok,update_not_done}
                end;
            _ ->
                {nok,update_not_done}
            end
    end,
    {[HTML_Radio,HTML_Select,"</td></tr>"],ParseCB2}.

imei_action({Value,{Desc}}) -> 
    ["<tr><td><input type=\"radio\" name=\"imei_action\" value=\"",
        Value,"\">",Desc,"</td></tr>"];
%% a select list will be followed
imei_action({Value,{Desc,Attr}}) -> 
    ["<tr><td><input type=\"radio\" name=\"imei_action\" value=\"",
        Value,"\" ",Attr,">",Desc,"</td><td>"].

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Terminal Search %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type terminal_to_phase(integer(),bool()) -> string.
terminal_to_phase(2,false) -> "2";
terminal_to_phase(_,true)  -> "1.5";
terminal_to_phase(1,false) -> "1".

%% +type print_handset_field(atom(),terminal()) -> html().
print_handset_field(handset_phase,#terminal{human_ph = HumanPH,
					    ussd15   = USSD15}) ->
    terminal_to_phase(HumanPH,USSD15);
print_handset_field(handset_size,#terminal{ussdsize=Size}) ->
    integer_to_list(Size);
print_handset_field(handset_endsize,#terminal{end_ussdsize=EndSize}) ->
    integer_to_list(EndSize);
print_handset_field(handset_ucs,#terminal{allow_ucs=UCS}) ->
    atom_to_list(UCS);
print_handset_field(handset_ucs_size,#terminal{ucs_size=Size}) ->
    integer_to_list(Size);
print_handset_field(handset_ucs_endsize,#terminal{ucs_endsize=EndSize}) ->
    integer_to_list(EndSize).

%% +type edit_handset_field(atom(),terminal()) ->
%%                         {atom(),{html(),http_callback()}}.
edit_handset_field(handset_phase,#terminal{human_ph = HumanPH,
					   ussd15   = USSD15}) ->
    AtomValue =
	case {HumanPH,USSD15} of
	    {2,false} -> phase_2;
	    {_,true}  -> phase_15;
	    {1,false} -> phase_1
	end,
    Choices = [{phase_2,"2"},{phase_15,"1.5"},{phase_1,"1"}],
    {handset_phase,webmin_edit_popup:edit(Choices,AtomValue,no_refresh)};

edit_handset_field(handset_size,#terminal{ussdsize=Size}) ->
    {handset_size,webmin_edit_popup:edit(?TERMINAL_SIZES,Size,no_refresh)};

edit_handset_field(handset_endsize,#terminal{end_ussdsize=EndSize}) ->
    {handset_endsize,
     webmin_edit_popup:edit(?TERMINAL_SIZES,EndSize,no_refresh)};

edit_handset_field(handset_ucs,#terminal{allow_ucs=AllowUCS}) ->
    {Mod,Data} = webmin:editor_of_type(bool),
    {handset_ucs,Mod:edit(Data,AllowUCS,no_refresh)};

edit_handset_field(handset_ucs_size,#terminal{ucs_size=Size}) ->
    {handset_ucs_size,
     webmin_edit_popup:edit(?TERMINAL_UCSSIZES,Size,no_refresh)};

edit_handset_field(handset_ucs_endsize,#terminal{ucs_endsize=EndSize}) ->
    {handset_ucs_endsize,
     webmin_edit_popup:edit(?TERMINAL_UCSSIZES,EndSize,no_refresh)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Terminal Change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type process_terminal_change(terminal()) ->
%%                               {ok,terminal()} | {error,atom()}.
process_terminal_change(Request) ->
    case mnesia:dirty_match_object(Request) of
        [#terminal{tac=TAC} = T|_] ->
	    {ok,T#terminal{imei=string:left(TAC,15,$9)}};
	[] ->
	    {nok,no_such_handset};
	Err ->
	    slog:event(internal,?MODULE,cannot_update_imei,Err),
	    {nok,update_not_done}
    end.

%% +type any_ize(any | string()) -> string().
any_ize(any) -> '_';
any_ize(Else) -> Else.

%% +type select_handset(wu_cb(),terminal()) -> html().
select_handset(RefreshCB,Terminal) ->
    webmin:html("Select Handset","Editor is unavailable").

%%%%%%%%%%%%%%%%%%%%%%%%%%% Barring Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Some fancy editor with some javascript checkboxes for barring
%% +type select_barring(wu_cb(), [atom()]) -> html().
select_barring(RefreshCB,Barring) ->
    ParamBarrings = pbutil:get_env(pservices,barring_acl_code),
    ACLs = lists:map(fun({_,Name}) -> Name end,ParamBarrings),
    AllChecked = case ACLs -- Barring of
		     [] -> "checked";
		     _ -> ""
		 end,
    CallBack =
	fun(Env,Args) ->
		NewBarring =
		    lists:foldl(fun({"barring",ACL},Acc) ->
					[list_to_atom(ACL)|Acc];
				   (_,Acc)               -> Acc
				end,[],Args),
		RefreshCB(Env,Args,{ok,NewBarring})
	end,

    Tag = webmin_callback:create(CallBack),
    Label = webuser_msgs:text(update),
    HTML =

	[
	 "<h2>",webuser_msgs:text(select_user_barring),"</h2>",
	 "<form id=\"barring_form\" action=\""?UPDATE_URL"\">\n",
	 "<table class=\"barring\"><tr><td>",

%%% 'all' checkbox
	 "<input type=\"checkbox\" name=\"all_barring\" value=\"all\"",
	 "onClick=\""

%%% Javascript select/unselect all
	 " for (i = 0; i < barring.length; i++) {"
	 " barring_form.barring[i].checked=this.checked;} \"",
	 AllChecked ++">\n",
	 webuser_msgs:text(select_unselect_all),
	 "</td><td>",

%%% ACLs checkboxes
	 lists:flatmap(
	   fun(X) ->
		   Checked =
		       case lists:member(X,Barring) of
			   true -> "checked";
			   _ -> ""
		       end,
		   Name =  atom_to_list(X),
		   "<input type=\"checkbox\" name=\"barring\" value=\""
		       ++ Name ++ "\" onClick=\"all_barring.checked=false\" "
		       ++ Checked ++">" ++ Name ++"<br/>\n"
	   end,
	   ACLs),
	 "</td></tr></table>",
	 " <input type=\"submit\" name=\"act",Tag,"\" value=\"",Label,"\">\n",
	 "</form>\n"],
    webuser_layout:html(HTML).

%%%%%

%%% Print something even if the value seems unprintable
%% +type print_undef(term()) -> string().
print_undef(Value) when list(Value)-> webmin:esc_pcdata(Value);
print_undef(_) -> webuser_msgs:text(no_value).



%%%%%%%%%%%%%%%%%%%%%%% Standard Editor Implementation %%%%%%%%%%%%%%%%%%%%

%% +type edit_webuser_tab(profile(),Svc::string(),tuple(),fields_config(),
%%                        Fields::[tuple()],[{atom(),term()}],
%%                        wu_cb()) -> webmin::html().

edit_webuser_tab(P,Svc,Data,[{Name,Descr,Type} | FieldsConf], Fields,
		 Pairs,CB) ->
    Value = case catch lists:keysearch(Name,1,Pairs) of
		{value,{_,V}} -> V;
		_ -> exit({cannot_find,Name,in,Pairs})
	    end,

    %% Callback commiting update to database 
    CB_Field =
	fun(HTTP_Env, Vars, {nok,Msg}) ->
		CB(Msg);
	   (HTTP_Env, Vars, {'EXIT',Reason}) ->
		slog:event(failure,?MODULE,could_not_edit_value,
			   {Svc,Name,Reason}),
		CB(update_nok);
	   (HTTP_Env, Vars, {ok,NewValue}) ->
		update(P,Svc,Data,Name,Fields,Pairs,NewValue,CB);
	   %% Some editors directly return the result...
	   %% (such as webmin_edit_list).   
	   (HTTP_Env, Vars, NewValue) ->
		update(P,Svc,Data,Name,Fields,Pairs,NewValue,CB)
		    
	end,

    %% Process next record field
    [edit_row(Descr,Value,Type,CB_Field) |
     edit_webuser_tab(P,Svc,Data,FieldsConf,Fields,Pairs,CB)];

edit_webuser_tab(_,_,_,[],_,_,_) ->
    [].



%% +type update(profile(),string(),tuple(),string() | atom(), [atom()],
%%              [tuple()],term(),wu_cb()) -> html().
update(Profile,Svc,Data,Name,Fields,Pairs,NewValue,CB) ->
    NewPairs = lists:keyreplace(Name,1,Pairs,{Name,NewValue}),
    NewRecord = oma_util:update_record(Fields,Data,NewPairs),
    FakeSession = #session{prof=Profile},
    case catch db:update_svc_profile(FakeSession,Svc,NewRecord) of
	ok ->
	    CB(update_ok);
	Else ->
	    slog:event(internal,?MODULE,could_not_update,{Svc,NewRecord,Else}),
	    CB(update_not_done)
    end.



%%%% DOCUMENTATION
%% +type slog_info(Class::atom(),Module::atom(),SLog::term()) -> slog_info().
slog_info(internal,?MODULE,could_not_update) ->
    #slog_info{descr="A service could not be updated in the database",
	       operational=?MYSQL_FAILURE};

slog_info(failure,?MODULE,could_not_edit_value) ->
    #slog_info{descr="An invalid value was entered while updating some"
	       " service data",
	       operational="1. Check that Customer Representative has"
	       " entered a correct value\n"
	       "2. Check the value of webuser::profile_tabs and update"
	       " the editor for this value"};

slog_info(internal,?MODULE,cannot_update_imei) ->
    #slog_info{descr="Requested handset could not be fetched from terminal"
	       " database.",
	       operational=?CALL_HOTLINE}.

