-module(pdist_orangef_app).

-behaviour(application).
-export([start/2, stop/1, config_change/3]).

-export([param_info/1]).

-include("../../oma/include/oma.hrl").

%%%% Callbacks for behaviour "application".

%% +type start(Type, Args) -> sup_start_result().

start(Type, Args) ->
    pdist_orangef_sup:start_link(Args).

%% +type stop(State) -> ok.

stop(State) -> ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

config_change(Changed, New, Removed) ->
    lists:foreach(fun config_changed/1, Changed),
    ok.

config_changed({Param, Rout}) 
  when Param==sdp_routing; Param==mwp_routing;
       Param==tlv_routing; Param==mqseries_routing;
       Param==smsinfos_routing; Param==rdp_options_routing->
    pdist_orangef_sup:routing_changed(Param);
config_changed(Param) ->
    io:format("Ignoring new config: ~p~n", [Param]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param_info(sdp_routing) ->
    #param_info
	    {type = pdist_app:generic_route_type(),
	     name = "SDP routing table.",
	     help = pdist_app:generic_routing_info("SDP queries", "servers",
						   "interfaces"),
	     example = [ {default,
			  [ {{io_sdp_test,possum@localhost},
			     [msisdn|""], 10} ]}
			],
	     activation = auto
	    };

param_info(tlv_routing) ->
    #param_info
	    {type = pdist_app:generic_route_type(),
	     name = "TLV routing table.",
	     help = pdist_app:generic_routing_info("TLV queries", "servers",
						   "interfaces"),
	     example = [ {default,
			  [ {{io_tlv_test,possum@localhost},
			     [msisdn|""], 10} ]}
			],
	     activation = auto
	    };

param_info(mwp_routing) ->
    #param_info
	    {type = pdist_app:generic_route_type(),
	     name = "MWP routing table.",
	     help = pdist_app:generic_routing_info("MWP queries", "servers",
						   "interfaces"),
	     example = [ {default,
			  [ {{io_mwp_mem,possum@localhost},
			     [msisdn|""], 10} ]}
			],
	     activation = auto
	    };

param_info(mqseries_routing) ->
    #param_info
	    {type = pdist_app:generic_route_type(),
	     name = "MQSeries routing table.",
	     help = pdist_app:generic_routing_info("MQSeries queries", "servers",
						   "interfaces"),
	     example = [ {default,
			  [ {{io_mqseries,possum@localhost},
			     [dise], [{queue,3}] }]}
			],
	     activation = auto
	    };
param_info(smsinfos_routing) ->
    #param_info
	    {type = pdist_app:generic_route_type(),
	     name = "SMSINFOS routing table.",
	     help = pdist_app:generic_routing_info("SMSINFOS", "servers",
						   "interfaces"),
	     example = [ {default,
			  [ {{io_smsinfos,possum@localhost},
			     [], [{queue,3}] }]}
			],
	     activation = auto
	    };
param_info(rdp_options_routing) ->
    #param_info
	    {type = pdist_app:generic_route_type(),
	     name = "RDP Options routing table.",
	     help = pdist_app:generic_routing_info("RDP Options", "servers",
						   "interfaces"),
	     example = [ {default,
			  [ {{io_rdp_opt0,possum@localhost},
			     [], [{queue,3}] }]}
			],
	     activation = auto
	    };
param_info(spider_prepaidOffer) ->
    (#param_info
     {type = {list, {tuple, "match offerPOrSUid - subcription",
		     [{"offerPOrSUid",string},
		      {"Subcritpion",{enum, ["mobi","cmo"]}}]}},
      name = "Correspondance tableofferPOrSUid - subcription",
      help = "Spider knows 3 subcriptions type dme, postpaid and prepaid. "
      "Cellcube need to know if prepaid is mobicarte subcription or CMO.",      
      example =  [{"MOB", "mobi"},{"CMO", "cmo"}],
      activation = auto,
      level = install
     });   
param_info(spider_entreprise_possible_subscription) ->
    (#param_info
     {type = {list, {enum, ["opim","dme"]}},
      name = "Possible souscriptions for an offerType set to"
      " à \"entreprise\"",
      help = "Cellcube will check that suouscription is in the list when"
      " the offerType received is \"enterprise\".",      
      example =  ["dme", "opim"],
      activation = auto,
      level = install
     });   
param_info(spider_http_url) ->
    (#param_info
     {type = string,
      name = "HTTP URL Spider",
      help = "URL for spider service",
      example = "/spider/services/GetBalance",
      activation = auto,
      level = install
     });   
param_info(asmetier_url_prefix) ->
    (#param_info
     {type = string,
      name = "AS/Metier URL prefix",
      help = "URL prefix for AS/Metier services",
      example = "/asm-ws-8.2.0.1/",
      activation = auto,
      level = install
     });   
param_info(spider_xmlns_url) ->
    (#param_info
     {type = string,
      name = "URL for getBalanceRequest Spider request",
      help = "URL used in the body Spider resquet",
      example =  "http://ws.spider.francetelecom.com",
      activation = auto,
      level = install
     }).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +private.

%% +usedeftype([sup_start_result/0]).
