-module(webmin_of_params).

-export([show/2]).

-export([ change_save_param/2, % RPC
	  param_edit/2]).

-include("../../oma_webmin/include/webmin.hrl").
-include("../../oma/include/oma.hrl").

-include_lib("kernel/include/file.hrl").

show(HTTP_Env, Input) ->    
    BootEnv = oma_config:read_config(),
    AppParams = pbutil:get_env(webmin_orangef, editable_parameters),

    SHOWAPPs = lists:map(fun({App,Params}) ->
				 Fun=fun(P) -> {P,pbutil:get_env(App, P)} end,
				 AppEnv = lists:map(Fun, Params),
				 show_app(App, BootEnv, AppEnv)
			 end, AppParams),

    webmin:html("Configuration Orange France", SHOWAPPs).

show_app(App, BootEnv, AppEnv) ->
    BootParams = case lists:keysearch(App, 1, BootEnv) of
		     {value, {_,BootParams_}} -> BootParams_;
		     _ -> []
		 end,
    [ %%"Yellow lines indicate unsaved changes.<br>",
      "<table border=1 cellspacing=0 cellpadding=2>\n"
      "<tr bgcolor="?COLOR_CAPTION">"
      " <td><b>Nom du param&egrave;tre</b></td>"
      " <td><b>Valeur</b></td>"
      "</tr>\n",
      lists:map(fun (Param) -> show_param(App, BootParams, Param) end, AppEnv),
      "</table>"
     ].

show_param(App, BootParams, {Name,CurValue}=NV) ->
    {Info, ParamLevel} =
	case catch oma_config:get_param_info(App, Name) of
	    {'EXIT', _} -> {undefined, internal};
	    Info_       -> {Info_,     Info_#param_info.level}
	end,
    do_show_param(App, BootParams, NV, Info).

do_show_param(App, BootParams, {Name,CurValue}, Info) ->
    BootValue = case lists:keysearch(Name, 1, BootParams) of
		    {value, {_,BootValue_}} -> BootValue_;
		    _ -> undefined
		end,
    Color = if CurValue =/= BootValue -> ?COLOR_HIGHLIGHT;
	       true -> ?COLOR_DISABLED
	    end,
    {Mod, Data} = get_editor(Info),
    ValueHTML =
	case catch Mod:print(Data, CurValue) of
	    {'EXIT', _} -> "<font color=red>Invalid value</font>";
	    ValueHTML_  -> ValueHTML_
	end,
    [ "<tr bgcolor=",Color,">",
      io_lib:format("<td><a target=info href=./"?MODULE_STRING":param_edit?"
		    "app=~p&param=~p>~p</a></td>",
		    [App, Name, Name]),
      "<td>", ValueHTML, "</td>",
      "</tr>\n"
     ].

param_edit(Env, Input) ->
    Vars = webmin:parse_input(Input),
    {value, {_,AppL}} = lists:keysearch("app", 1, Vars),
    App = list_to_atom(AppL),
    {value, {_,ParamL}} = lists:keysearch("param", 1, Vars),
    Param = list_to_atom(ParamL),
    Info = (catch oma_config:get_param_info(App, Param)),
    {ok, CurValue} = application:get_env(App, Param),
    param_editor(App, Param, Info, CurValue).


param_editor(App, Param, Info, CurValue) ->
    Help = case Info#param_info.help of
	       Nothing when Nothing == undefined; Nothing == "" ->
		   "Pas d'aide disponible";
	       _ -> Info#param_info.help
	   end,
    webmin:html(io_lib:format("Edition du param&egrave;tre: ~p", [Param]),
		[ "<hr>",
		  "<pre>\n",webmin:uni2pcdata8(Help), "\n</pre>",
		  "<hr>",
		  param_edit(App, Param, Info, CurValue)%,
		 ]).

param_edit(App, Param, Info, CurValue) ->
    case catch do_param_edit(App, Param, Info, CurValue) of
	{'EXIT', E} ->
	    [ "<p><font color=red>",
	      "Impossible d'afficher cette valeur dans l'&eacute;diteur.",
	      " Elle est peut-&ecirc;tre invalide",
	      "</font>"
	     ];
	HTML ->
	    HTML
    end.

do_param_edit(App, Param, Info, CurValue) ->
    %% Use #param_info.editor if present. Otherwise select an editor
    %% according to #param_info.type.
    {Mod, Data} = get_editor(Info),
    RefreshCB =  fun (HTTP_Env, Vars, NewValue) ->
			 param_editor(App, Param, Info, NewValue)
		 end,
    {EdHTML,EdParser} = Mod:edit(Data, CurValue, RefreshCB),
    Callback = fun (HTTP_Env, Input) ->
		       {ok, NewValue} = EdParser(HTTP_Env, Input),
		       Result = rpc:multicall(oma:get_env(nodes), 
					      ?MODULE, change_save_param, 
					      [App, {Param,NewValue}]),
		       
		       webmin:html("R&eacute;sultat de la mise &agrave; jour",
				   webmin:format_rpcresult(Result)++
				   "<br>"
				   "<a href=./" ++ ?MODULE_STRING ++
				   ":show>Retour</a>")
	       end,
    webmin_callback:wrap_form(EdHTML, "Mettre &agrave; jour", Callback).

change_save_param(App, {N, V}=NV) ->
    Node = node(),
    HTML =
	case catch oma_config:change_param(App, N, V) of
	    ok -> 
		"Mise &agrave; jour r&eacute;ussie";
	    Error ->
		slog:event(internal, ?MODULE, param_not_changed,{App,N,Error}),
		"<strong>La mise &agrave; jour a &eacute;chou&eacute;</strong>"
	
	end ++ 
	" et " ++
	case save_param(App, NV) of
	    ok -> 
		"sauvegarde r&eacute;ussie";
	    Err ->
		slog:event(internal, ?MODULE, param_not_saved, {App,N,Err}),
		"<strong>la sauvegarde a &eacute;chou&eacute;</strong>"
	end ++
	" sur " ++ atom_to_list(Node) ++ "<br>",
    {Node, HTML}.

save_param(App, {Name, Value}=NV) ->  
    Path = "conf/boot.config",
    PathTmp = Path++".tmp1234",
    Mtime_1 = mtime(Path),
    {ok, [BootE]} = file:consult(Path),
    BootE2 = merge_param_env(App, NV, BootE),
    BootE2S = io_lib:format("~p.~n", [BootE2]),
    BootE2B = list_to_binary(BootE2S),
    case file:write_file(PathTmp, BootE2B) of
	ok -> 
	    Mtime_2 = mtime(Path),
	    case Mtime_2 == Mtime_1 of
		true -> 
		    file:rename(PathTmp, Path);
		false ->
		    file:delete(PathTmp),
		    {error, boot_file_creation}
	    end;
	Error -> 
	    Error
    end.

merge_param_env(App, {Name, Value}=NV, Env) ->
    case lists:keysearch(App, 1, Env) of
	false ->
	    [{App,[NV]}|Env];
	{value, {_,ApplEnv}} ->
	    ApplEnv2 = merge_param_applenv(NV, ApplEnv),
	    lists:keyreplace(App, 1, Env, {App,ApplEnv2})
    end.

merge_param_applenv({Name, Value}=NV, ApplEnv) ->
    case lists:keysearch(Name, 1, ApplEnv) of
	false -> [NV|ApplEnv];
	{value,_}-> lists:keyreplace(Name, 1, ApplEnv, NV)
    end.

mtime(Path) ->
    {ok, #file_info{mtime=Mtime}} = file:read_file_info(Path),
    Mtime.

get_editor(#param_info{editor=undefined, type=Type}) ->
    webmin:editor_of_type(Type);
get_editor(#param_info{editor=ModData}) -> ModData;
get_editor(_) -> {webmin_edit_default,[]}.
