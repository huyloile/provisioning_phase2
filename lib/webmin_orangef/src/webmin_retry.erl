-module(webmin_retry).
-export([show/2]).

-define(COLOR_CAPTION,"cyan").

show(HTTP_Env, Input) ->
    Retries = batch_reset_imei:export(list),
    Retries2 = lists:append(Retries),
    print(Retries2).

print(Retries)->			 
    [
     "\r\n\r\n"
     "<html><head><title>Table des abonnes en retentative</title></head><body>"
     "<h1>Table des abonnes en retentative</h1>\n",
     io_lib:format("<h4>Nombre d'abonnes en retentative: ~p~n</h4>",[length(Retries)]),
     "<table border=1>"
     "  <tr bgcolor="?COLOR_CAPTION">"
     "    <td><b>IMSI</b></td>"
     "    <td><b>Type</b></td>"
     "    <td><b>Date</b></td>"
     "    <td><b>Statut</b></td>"
     "  </tr>",
     lists:map(fun (Retry) -> show(Retry) end, Retries),
     "</table><br/>"].

show([IMSI,TYPE,DATE,STATUT])->
    io_lib:format("<tr><td>~s</td><td>~s</td><td>~s</td><td>~s</td></tr>\n",
	[IMSI,TYPE,DATE,STATUT]).



