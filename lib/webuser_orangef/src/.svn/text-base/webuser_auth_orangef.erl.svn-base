-module(webuser_auth_orangef).

-export([show/2]).


show(_, _) ->
    Body =
        [
         webuser_orangef:top_buttons_bar_light(),
         webuser_orangef:top_status(),
         auth_form(),
         webuser_orangef:common_tail()
        ],
    webuser_orangef:html(Body).

auth_form() ->
    [
     "<form method=\"POST\" action=\"/erl/webmin_auth:login\">\n",
     "<p align=\"center\"><b>Veuillez vous identifier</b></p>\n",
     "<table border=\"0\" cellspacing=\"50\" cellpadding=\"10\"",
     " align=\"center\" width=\"257\">\n",
     "<tr>\n",
     "<td><b><span class=orange>",
     webuser_msgs:text(access_code),"</span></b></td>\n",
     "<td><input type=\"text\" name=\"username\" size=\"10\"",
     " maxlength=\"10\"></td></tr>\n",
     "<tr><td><b><span class=orange>", webuser_msgs:text(password),
     "</span></b></td>\n",
     "<td><input type=\"password\" name=\"password\" size=\"10\"",
     " maxlength=\"10\"></td></tr>\n",
     "<tr><td colspan=\"2\" align=\"center\">",
     "<input type=\"SUBMIT\" value=\"", webuser_msgs:text(enter),
     "\" class=\"bn\"></td></tr>\n",
     "</table>\n",
     "</form>"
     "</body>"].
