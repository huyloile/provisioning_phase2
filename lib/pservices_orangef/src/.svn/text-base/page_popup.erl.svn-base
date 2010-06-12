%% TODO lists:reverse partout

-module(page_popup).
-export([page2script/3]).

-include("../include/smspopup.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type page2script(session(), page(), [Subst::term()]) ->
%%     {Script::term(), responseformat()}.
%%%% Converts a page() into a Popup script.
%%%% Outputs both a script and a description of the response that the
%%%% SIM will generate.

%% +deftype responseformat() = [responseitem()].
%% +deftype responseitem() = {var,string()} | {form,Url::string()}
%%                         | {hooks,[hook]} | {tid,integer()}.
%% +deftype hook() = {integer(), Url::string()}.

page2script(Session, P, Subst) ->
    {Items,ContentInfo} = pageutil:eval_includes(Session, Subst, P#page.items),
    IsDyn=page_sms:is_dyn(ContentInfo),
    Profile = Session#session.prof,
    {Script, RF} = page2script(Profile, Items, [], []),
    {{Script, [{tid,Session#session.seq_num}|RF]}, IsDyn}.

page2script(Profile, [], Actions, RF) ->
    %% If the scripts contains inputs or choices, add a mo_sm action
    Acts = case RF of 
	       [] -> 
		   %% add the back link
		   [{choice,"",use,
		     [{pageutil:contents2text(
			 Profile,
			 [{pcdata,"<--"}]),"#0"}
		     ]} | Actions]; 
	       [{hooks,H}|RF1] -> 
		   [mo_sm|Actions];
	       _ ->
		   [mo_sm|Actions]
	   end,
    Script = {no_notif, lists:reverse(Acts)},
    {Script, lists:reverse(RF)};

page2script(Profile, [#hlink{}|_]=Items, Actions, RF) ->
    %% Collect links
    {Links, Rest} = pageutil:get_links(Items),
    Hooks = lists:map(fun ({Index,Url,C}) -> {Index, Url} end, Links),
    Choices = lists:map(fun ({Index,Url,C}) ->
				{pageutil:contents2text(Profile,C),
				 "#"++Index}
			end, Links),
    %% add return link
    Choices1 = lists:append(Choices, 
			    [{pageutil:contents2text(
				Profile,[{pcdata, "<--"}]),"#0"}]),

    %% Can't have stuff after a set of links in a popup
    case Rest of
	[] -> ok;
	_ -> exit({data_after_links, Rest})
    end,
    Actions1 = [{choice,"",use,Choices1} | Actions],
    RF1 = [ {hooks,Hooks} | RF ],
    page2script(Profile, Rest, Actions1, RF1);

page2script(Profile, [#form{}=Form|Items], Actions, RF) ->
    Url = Form#form.action,
    Entries = pageutil:get_entries(Form#form.contents),
    RF0 = lists:foldl(fun ({Var,P,D,K},F) -> [{var,Var}|F] end, RF, Entries),
    RF1  = [{form,Url} | RF0],
    EntryToInput =
	fun ({Var,Prompt,Default,Kind}) ->
		{input, 0,16,
		 {Kind,visible,storage,no_pause,sharp},
		 lists:sublist(pageutil:contents2text(Profile, Prompt),
			       ?POPUP_PROMPT_MAX),
		 lists:sublist(pageutil:contents2text(Profile, Default),
			       ?POPUP_DEFAULT_MAX)}
	end,
    %% Add Popup actions to the current list.
    %% foldl is faster than map+concat.
    Actions1 = lists:foldl(fun (E, A) -> [EntryToInput(E) | A] end,
			   Actions, lists:reverse(Entries)),
    %% Can't have stuff after a form
    case Items of
	[] -> ok;
	_ -> exit({data_after_form, Items})
    end,
    page2script(Profile, Items, Actions1, RF1);

page2script(Profile, [C|_]=Items, Actions, RF) ->
    {Contents, Rest} = pageutil:get_contents(Items),
    case Contents of [] -> exit({unknown_item, C}); _ -> ok end,
    Act = {display, pageutil:contents2text(Profile, Contents)},
    page2script(Profile, Rest, [Act|Actions], RF).
