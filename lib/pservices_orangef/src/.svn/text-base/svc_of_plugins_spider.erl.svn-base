-module(svc_of_plugins_spider).

-export([selfcare/3,
	 selfcare_plus/2,
	 proposer_lien_suivi_conso_plus/4,
	 spider_response/3,
	 redirect_by_balance/3,
	 print_spider_error_code/1,
	 redirect_by_suivi_conso_plus/3,
		 proposer_lien/6
	]).

-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/page.hrl").

selfcare(plugin_info, Subscription, Level) ->
     (#plugin_info
     {help =
      "This funtion include the spider selcare.",
      type = function,
      license = [],
      args =
      [{subscription, {oma_type, {enum, [dme,mobi,opim]}},
        "This parameter specifies the subscription."},
       {level, {oma_type, {enum, [long,light,mini]}},
        "This parameter specifies level of selfcare."}]
	});

selfcare(abs, Subscription, Level)->
    Text = "Suivi Conso Souscription : " ++ Subscription,
    [{pcdata, Text}];

selfcare(Session,"mobi",Level) ->
    Link = "/orangef/selfcare_"++Level++"/spider.xml#",
    MultiLink="FORF="++Link++"forfait,AJUST="++Link++"ajustable,ABON="++Link++"abonnement,LIB="++Link++"sans_credit,PTF="++Link++"mobi,CPTMOB="++Link++"cmo,?="++Link++"restitGodetAError",
    selfcare_spider(Session,MultiLink,Link++"restitGodetAError");

selfcare(Session,"dme",Level) ->
    Link = "/orangef/selfcare_"++Level++"/spider.xml#",
    MultiLink="0003="++Link++"id0003,0002="++Link++"id0002,0001="++Link++"id0001,0013="++Link++"id0013,0007="++Link++"id0007,0014="++Link++"id0014,0008="++Link++"id0008,0011="++Link++"id0011,0009="++Link++"id0009,0010="++Link++"id0010,0012="++Link++"id0010,0015="++Link++"id0015,0016="++Link++"id0016,0017="++Link++"id0017,0018="++Link++"id0018,0019="++Link++"id0019,0020="++Link++"id0009,0021="++Link++"id0010,0022="++Link++"id0022,0023="++Link++"id0023,0024="++Link++"id0024,0025="++Link++"id0025,0026="++Link++"id0026,0028="++Link++"id0009,0029="++Link++"id0010,0030="++Link++"id0009,0031="++Link++"id0010,0032="++Link++"id0032,0033="++Link++"id0033,0050="++Link++"id0050,0099="++Link++"id0099,osen="++Link++"osen,?="++Link++"restitGodetAError",
    case svc_spider:get_availability(Session) of
	available ->
 	    svc_spider:redirect_by_identifiant(Session,MultiLink);
 	_ -> 
 	    {redirect, Session, Link++"restitGodetAError"}
    end;    

selfcare(Session,"opim",Level) ->    
    Link = "/orangef/selfcare_"++Level++"/opim_"++Level++".xml#",
    MultiLink="0002="++Link++"id0002,0027="++Link++"forfait,FORF="++Link++"forfait,?="++Link++"restitGodetAError",    
    case svc_spider:get_availability(Session) of
        available ->
            svc_spider:redirect_by_identifiant(Session,MultiLink);
        _ -> 
            {redirect, Session, Link++"restitGodetAError"}
    end.
%%    selfcare_spider(Session,MultiLink,Link++"restitGodetAError").
    
selfcare_spider(Session,MultiLink,LinkError)->    
    case svc_spider:get_availability(Session) of
	available ->
 	    svc_spider:redirect_by_typeRestitution(Session,MultiLink);
 	_ -> 
 	    {redirect, Session, LinkError}
    end.

proposer_lien(plugin_info, Subscription, Option, PCD, URL, BR) ->
     (#plugin_info
     {help =
      "This funtion include the spider selcare.",
      type = function,
      license = [],
      args =
      [{subscription, {oma_type, {enum, [dme]}},
        "This parameter specifies the subscription."},
	   {option, {oma_type, {enum, [no_option]}},
        "This parameter specifies the option."},
	   {pcd, {oma_type, {defval,"",string}},
		"This parameter specifies the text to be displayed."},
       {url, {link,[]},
		"This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr,br_after]}},
		"This parameter specifies br tag."}
	  ]});
	  
proposer_lien(abs, Subscription, _,PCD,URL,_)->
	[#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien(Session, Subscription, Option, PCD, URL, BR)
  when Subscription=="dme" ->
	case BR of 
		"br" ->
			svc_util_of:add_br("BR")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
		"br_after" ->
			[#hlink{href=URL,contents=[{pcdata,PCD}]},br];
		_ ->
			[#hlink{href=URL,contents=[{pcdata,PCD}]}]
	end.

proposer_lien_suivi_conso_plus(plugin_info, Subscription, Pcd, Url) ->
     (#plugin_info
     {help =
      "This plugin function includes the link to the selfcare spider named 'suivi conso plus'.",
      type = function,
      license = [],
      args =
      [{subscription, {oma_type, {enum, [dme,mobi,opim]}},
        "This parameter specifies the subscription."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"}]
	});

proposer_lien_suivi_conso_plus(abs, Subscription,Pcd,Url) -> 
    [#hlink{href=Url,contents=[{pcdata,Pcd}]}];


proposer_lien_suivi_conso_plus(Session, Subscription,Pcd, Url) ->
    svc_spider:lienSiAutresGodets(Session,Pcd,Url).


selfcare_plus(plugin_info, Subscription) ->
       (#plugin_info
     {help =
      "This funtion include the spider selcare plus.",
      type = function,
      license = [],
      args =
      [{subscription, {oma_type, {enum, [dme,mobi,opim]}},
        "This parameter specifies the subscription."}]
	});

selfcare_plus(abs, Subscription)->
    Text = "Suivi Conso + Souscription : " ++ Subscription,
    [{pcdata, Text}];
  

selfcare_plus(Session,"mobi") ->
    case svc_spider:get_godets_miro(Session)/=[] of
	true -> svc_spider:restit_offre_miro(Session,"page1");
	false -> svc_spider:suiviconsodetaille(Session)
    end;
selfcare_plus(Session,"dme") ->
    svc_spider:dme_suiviconsoplus(Session);

selfcare_plus(Session,"opim") ->    
    svc_spider:opim_suiviconsoplus(Session).


spider_response(plugin_info, Url_ok, Url_nok) ->
       (#plugin_info
     {help =
      "This plugin redirect to the page depending on the spider response",
      type = command,
      license = [],
      args =
      [
       {url_ok, {link, []},
	"This parameter specifies the page when the spider consultation is OK"},
       {url_nok, {link, []},
	"This parameter specifies the page when the spider consultation is NOK"}
      ]
     });

spider_response(abs, Url_ok, Url_nok) ->
     [{redirect,abs,Url_ok},
      {redirect,abs,Url_nok}];

spider_response(Session,Url_ok, Url_nok) ->
    case variable:get_value(Session,user_state) of
	not_found->
	    {redirect,Session,Url_nok};
	Value -> case svc_spider:get_availability(Session) of
		     available -> {redirect,Session,Url_ok};
		     _ -> {redirect,Session,Url_nok}
		 end
    end.

redirect_by_balance(plugin_info, Url_null, Url_not_null) ->
       (#plugin_info
     {help =
      "This plugin redirect to the page depending on the spider balance",
      type = command,
      license = [],
      args =
      [
       {url_null, {link, []},
	"This parameter specifies the page when the Balance is empty"},
       {url_not_null, {link, []},
	"This parameter specifies the page when the Balance has credit"}
      ]
     });

redirect_by_balance(abs, Url_null, Url_not_null) ->
     [{redirect,abs,Url_null},
      {redirect,abs,Url_not_null}];

redirect_by_balance(Session,Url_null, Url_not_null) ->
    svc_spider:redir_si_credit_nul(Session, "balance", Url_null, Url_not_null).

redirect_by_suivi_conso_plus(plugin_info, Url_suivi_conso_plus, Url_no_suivi_conso_plus) ->
       (#plugin_info
     {help =
      "This plugin redirect to the page depending on the linl suivi conso plus",
      type = command,
      license = [],
      args =
      [
       {url_suivi_conso_plus, {link, []},
	"This parameter specifies the page when the 'suivi conso plus' exist"},
       {url_no_suivi_conso_plus, {link, []},
	"This parameter specifies the page when there is no 'suivi conso plus'"}
      ]
     });

redirect_by_suivi_conso_plus(abs, Url_suivi_conso_plus, Url_no_suivi_conso_plus) ->
     [{redirect,abs,Url_suivi_conso_plus},
      {redirect,abs,Url_no_suivi_conso_plus}];

redirect_by_suivi_conso_plus(Session,Url_suivi_conso_plus, Url_no_suivi_conso_plus) ->
    case svc_spider:lienSiAutresGodets(Session, "not_used", "not_used") of
	[] -> {redirect,Session,Url_no_suivi_conso_plus};
	_ ->{redirect,Session,Url_suivi_conso_plus}
    end.
print_spider_error_code(plugin_info)->
    (#plugin_info
     {help =
      "This plugin returned appropriate spider with spider indisponible.",
      type = function,
      license = [],
      args = []
     }
    );

print_spider_error_code(abs) ->
     [{pcdata," "}];
print_spider_error_code(Session) ->
    Error = variable:get_value(Session, spider_error),
    Code = case Error of
	       Error_ when Error_==timeout;
			   Error_==tcp_closed->
		   "100";
	       invalid_code ->
		   "101";
	       sachem ->
		   "110";
	       gloria ->
		   "111";
	       dise ->
		   "112";
	       sda ->
		   "113";
	       infranet ->
		   "114";
	       _ ->
		   no_code		   
	       end,
    Error_Code = case Code of
		     no_code->"";
		     _->
			 "ER" ++ Code
		 end,
    [{pcdata, Error_Code}].
