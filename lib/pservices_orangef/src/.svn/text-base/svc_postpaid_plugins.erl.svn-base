-module(svc_postpaid_plugins).

-export([init_svc_data/3, service_access/2]
       ).



-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../include/subscr_asmetier.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../include/postpaid.hrl").



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type init_svc_data(session(),string(),URL::string())->
%%                  erlpage_result(). 
%%%% Init svc_data and redirect to URL.
	
init_svc_data(plugin_info, Type, URL) ->
    (#plugin_info
     {help =
      "This command check if the session context contains "
      "spider infos, otherwise init the Postpaid subscription type"
      " (GP or PRO)",
      type = command,
      license = [],
      args =
      [
       {mode, {oma_type, {enum, [gp, pro]}},
	"This parameter specifies the Postpaid subscription type."},
       {urls, {link,[]},
	"This parameter specifies the next page"}
      ]});
init_svc_data(abs,_,URL)->
    [{redirect,abs,URL}];
init_svc_data(#session{prof=Prof}=Session,OF,URL) ->
    Session1 =
	case svc_spider:get_availability(Session) of
	    available -> Session;
	    _ -> svc_util_of:update_user_state(
		       Session#session{prof=Prof#profile{
					      subscription="postpaid"}},
		       #postpaid_user_state{offre=list_to_atom(OF)})
	end,
    {redirect,Session1,URL}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type service_access(session(),Text::string())->
%%                  erlpage_result(). 
%%%% Allow/forbid access to ParenChild Service.
	
service_access(plugin_info, Text) ->
    (#plugin_info
     {help =
      "This function allows access to ParentChild service only if"
      " this service is open and the subscriber msisdn defined",
      type = function,
      license = [],
      args =
      [
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."}
      ]});

service_access(abs, Text) ->
    [#hlink{href="/orangef/selfcare_long/parentChild.xml",contents=[{pcdata,Text}]}];
service_access(Session, Text) ->

    case (Session#session.prof)#profile.msisdn of
	{na, _} -> [];
	_ ->
	    case pbutil:get_env(pservices_orangef, acces_service_parentChild) of
		ouvert -> svc_util_of:add_br("br")++[#hlink{href="/orangef/selfcare_long/parentChild.xml",
				  contents=[{pcdata,Text}]}];
		ferme -> []
	    end
    end.
