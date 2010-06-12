-module(webuser_orangef).

-export([html/1]).

-export([quick_desc_segment/1]).

-export([edit_webuser/4]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/db.hrl").
-include("../../pservices_orangef/include/cmb.hrl").
-include("../../webuser/include/webuser.hrl").
-include("../../oma_webmin/include/webmin.hrl").

%% +type html(html()) -> html().
html(Content) ->
    [ "Cache-Control: no-cache\r\n",
      "Content-Type: text/html\r\n",
      "\r\n",
      "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n",
      "<html>\n",
      "<head>\n",
      "  <title>Customer Care</title>\n",
      "  <meta http-equiv=\"Pragma\" content=\"no-cache\">\n",
      "  <meta http-equiv=\"Content-Type\""
      " content=\"text/html;charset=utf-8\">\n",
      "  <link rel=\"stylesheet\" type=\"text/css\""
      " href=\"",?WEBUSER_CSS,"\">\n",
      "</head>\n",
      " <body>\n",
      "<table width=\"785\" bgcolor=\"black\">\n",
      " <tr heigth=\"80\">\n",
      " <td width=\"80\" height=\"80\" align=center>\n",
      "  <img src=/icons/logo.gif width=\"40\" height=\"40\">\n"
      " </td>\n",
      " <td width=\"200\">&nbsp;</td>\n",
      " <td align=\"right\">\n",
      " <font face=\"Arial, helvetica, sans-serif\" color=\"#FF6600\""
      " size=\"5\">Site </font><font face=\"Arial, helvetica, sans-serif\""
      " color=\"#FFFFFF\" size=\"5\">service-clients USSD</font>\n",
      " </td></tr></table>\n",
      "<table width=\"785\" height=\"20\" border=\"0\" bgcolor=\"#FF6600\">\n",
      " <tr><td><a href=\"/secure/help.html\">Aide</a>&nbsp;\n"
      " <font color=#FFFFFF>|</font>&nbsp;\n"
      " <a href=\"/secure/erl/webuser_layout:connect\">Page d'accueil</a>"
      " &nbsp;\n"
      " <font color=\"#FFFFFF\">|</font>&nbsp;\n"
      " <a href=\"/secure/erl/webmin_auth:logout\">Logout</a>\n",
      " </td></tr></table>",
      Content,
      " </body>\n",
      "</html>\r\n\r\n"
     ].


%% +type quick_desc_segment(profile()) -> html().
quick_desc_segment(#profile{uid=Uid,msisdn=Msisdn}) ->
    case svc_util_of:query_tech_seg_by_uid(Uid) of
	error ->
	    {ok,"Erreur"};
	TSI ->
	    case ocf_rdp:tech_seg_int_to_code(TSI) of
		not_found ->
		    slog:event(internal,?MODULE,unknown_tech_seg_stored_in_db,
			       {{tech_seg_int, TSI}, {msisdn, Msisdn}}),
		    {ok,"Erreur"};
		TSI_ ->
		    {ok,TSI_}
	    end
    end.


%% +type edit_webuser(profile(),SVC::string(),fields_config(),wu_cb()) -> 
%%                    {ok,html()} | {nok,string()}.
edit_webuser(#profile{uid          = Uid,
		      subscription = Subs}=P,Svc,FieldsConfig,RefreshCB) ->
    Fields = record_info(fields,call_me_back),
    case add_cmb(Subs) of
	true ->
	    webuser_editor:edit_webuser(P,Svc,FieldsConfig,Fields,RefreshCB);
	false ->
	    {nok, "Pas ce Call Me Back pour cette souscription"}
    end.

%% +type add_cmb(string()) -> bool().
add_cmb("mobi")-> true;
add_cmb("cmo") -> true;
add_cmb(_)     -> false.
