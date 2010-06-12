-module(webmin_table_ratio).
-export([show/2,reload/2]).
%% Interface use to print all tasks defined in crontab
-define(COLOR_CAPTION,   "cyan").
-include("../../pservices_orangef/include/ftmtlv.hrl").
show(HTTP_Env, Input) ->
    %% Print a table wich contains all information of crontab
    Ratios=ratio_state(),
    print_ratio(Ratios).

%% +type ratio_state()-> [ratio()].
ratio_state()->
    F=
	fun()->
		Keys=mnesia:all_keys(?RATIO),
		lists:map(fun(Key)->
				  mnesia:read({?RATIO,Key}) end,
			  Keys)
	end,
    {atomic,Res}=mnesia:transaction(F),
    L=lists:map(fun([#ratio{key={DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST},
			    ratio=R}])->
		     {DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST,R} end,
	     Res),
    lists:sort(L).

%% +type print_ratio([ratio()])->html().
print_ratio(Ratios)->			 
    [
     "\r\n\r\n"
     "<html><head><title>Table Ratio OF</title></head><body>"
     "<h1>List of all Ratio used by OF</h1>\n"
     "<h4>Pour mettre a jour"++reload_type()++
     "<a href=webmin_table_ratio:reload>[Reload]</a></h4>",
     io_lib:format("<h4>Nombre de ratio: ~p~n</h4>",[length(Ratios)]),
     "<table border=1>"
     "  <tr bgcolor="?COLOR_CAPTION">"
     "    <td><b>DCL_NUM</b><br/>Offre</td>"
     "    <td><b>TCP_NUM</b><br/>Compte</td>"
     "    <td><b>PTF_NUM</b><br/>Plan tarifaire</td>"
     "    <td><b>UNT_REST</b><br/>unite de restitution</td>"
     "    <td><b>Ratio</b></td>"
     "  </tr>",
     lists:map(fun (Ratio) -> show_ratio(Ratio) end, Ratios),
     "</table><br/>"].

show_ratio({DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST,R})->
    io_lib:format("<tr><td>~p</td><td>~p</td><td>~p</td><td>~p</td>"
		  "<td>~p</td></tr>\n",
		  [DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST,R]).

reload(HTTP_Env, Input) ->
    table_ratio_mnesia:update(),
    webmin:redirect_referer(HTTP_Env).

reload_type()->
    case pbutil:get_env(pservices_orangef,update_ratio) of
	tlv->
	    " par TLV";
	file->
	    " a partir du Fichier";
	_ ->
	    " mise a jour desactiver"
    end.
