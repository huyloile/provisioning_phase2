-module(webmin_one2one).
-export([show/2,reload/2]).
%% Interface use to print all the offers of One2One
-define(COLOR_CAPTION,    "#FF6600").
-define(BG_COLOR_CAPTION, "#000000").
-define(FONT,             "Arial").

-include("../../pservices_orangef/include/one2one.hrl").

%%%% HTTP Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type show(http_env(),string()) -> html().
show(HTTP_Env, Input) ->
    %% Print a table wich contains all the offers of One2One
    Offers=get_offers(),
    print_offers(Offers).

reload(HTTP_Env, Input) ->
    one2one_offers:csv2mnesia(),
    webmin:redirect_referer(HTTP_Env).

%%%% END : HTTP Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_offers()-> [one2one_offer()].
get_offers()->
    Res = mnesia:dirty_match_object(#?ONE2ONE_OFFER{_='_'}),
    {L,_}=lists:mapfoldr(
	fun(#?ONE2ONE_OFFER{code=Code,
			    short_desc=Short_desc,
			    long_desc=Long_desc,
			    labels=Labels},Acc) ->
		{{Acc,Code,Short_desc,Long_desc,Labels},Acc-1}
	end,
	length(Res),
	Res),
    lists:keysort(2,L).

%% +type print_offers([one2one_offer()])->html().
print_offers(Offers)->			 
    [
     "\r\n\r\n"
     "<html><head><title>Catalogue One To One</title></head>\n"
     "<body bgcolor=\"#FFFFFF\" leftmargin=\"0\" topmargin=\"0\" "
     "      marginwidth=\"0\" marginheight=\"0\" link=\"#003399\" "
     "      vlink=\"#0000CC\" alink=\"#FF9900\" text=\"#000000\" >\n"
     "<table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" "
     "       bgcolor="?BG_COLOR_CAPTION">\n"
     "<tr heigth=80>\n"
     "<td><font color ="?COLOR_CAPTION" face="?FONT" size=5>"
     "     Catalogue des offres One To One"
     "</font></td></tr><br>\n"
     "<tr heigth=60>\n",
     io_lib:format("<td><font color ="?COLOR_CAPTION" face="?FONT" size=3>"
		   "&nbsp;Nombre d'offres : ~p~n "
		   "<a href=webmin_one2one:reload>[Recharger]</a></font>"
		   "</td>\n",
		   [length(Offers)]),
     "</tr></table>"
     "<table width=\"100%\" height=20 border=0 cellspacing=0 "
     "cellpadding=\"0\" "
     "       bgcolor=\"#FF6600\">"
     "<tr><td>&nbsp;</td></tr>"
     "</table>"
     "<p><br><br><br><br><br><br>"
     "<table border=1>"
     " <tr bgcolor="?BG_COLOR_CAPTION">"
     "  <td><font color="?COLOR_CAPTION"><b>#</b></font></td>"
     "  <td><font color="?COLOR_CAPTION"><b>Code</b></font></td>"
     "  <td><font color="?COLOR_CAPTION"><b>Description courte</b></font></td>"
     "  <td><font color="?COLOR_CAPTION"><b>Description Longue</b></font></td>"
     "  <td><font color="?COLOR_CAPTION"><b>Lien Souscrire</b></font></td>"
     " </tr>\n",
     lists:map(fun (Offer) -> show_offer(Offer) end, Offers),
     "</table><br/></body>"].

%% +type show_offer({string(),string(),string(),[string()]}) -> html().
show_offer({Num,Code,Short,Long,undefined})->
    io_lib:format("<tr><td>~p</td><td>~p</td><td>~p</td><td>~p</td>"
		  "<td>~p</td>\n",
		  [Num,Code,Short,Long,""]);
show_offer({Num,Code,Short,Long,Labels})->
    io_lib:format("<tr><td>~p</td><td>~p</td><td>~p</td><td>~p</td>"
		  "<td>~p</td>\n",
		  [Num,Code,Short,Long,Labels]).
