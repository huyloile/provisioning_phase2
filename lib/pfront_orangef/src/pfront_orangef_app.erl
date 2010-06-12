-module(pfront_orangef_app).

-behaviour(application).
-export([start/2, stop/1, config_change/3]).
-export([param_info/1]).
-export([interface_up/1, interface_down/2, interface_die/2]).

-include("../../oma/include/oma.hrl").
-include("../include/ocf_rdp.hrl").
-include("../include/cbhttp.hrl").
%%%% Callbacks for behaviour "application".

%% +type start(Type, Args) -> sup_start_result().

start(Type, Args) ->
    %% Use active_env to store the configuration parameters that we
    %% need to diff in config_change.
    Interfaces = pbutil:get_env(pfront_orangef, interfaces),
    ets:insert(active_env, {{pfront_orangef,interfaces}, Interfaces}),
    pfront_orangef_sup:start_link(Args).

%% +type stop(State) -> ok.

stop(State) -> ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type interface_up(Name::atom()) -> *.
%% +type interface_die(Name::atom(), Info) -> *.
%%%% Interfaces can use these functions in order to avoid handling
%%%% alarms and logging themselves.
%%%% Since the starting rate of interfaces is limited by
%%%% connection timeouts and rsupervisors, it is safe to
%%%% send alarms direcly to eva.

interface_up(Name) ->
    register(Name, self()),
    slog:event(interface_state, ?MODULE, {interface_up,{Name,node()}}),
    BaseName = interface_basename(Name),
    catch eva:aclear_alarm({interface, {BaseName,node()}}).

interface_down(Name, Info) ->
    slog:event(interface_state, ?MODULE, {interface_down,{Name,node()}}, Info),
    BaseName = interface_basename(Name),
    catch eva:asend_alarm(interface_down, {interface, {BaseName,node()}},
			  self(), Info, []).

interface_die(Name, Info) ->
    interface_down(Name, Info),
    exit(Info).

%% +type interface_basename(atom()) -> atom().
%%%% Maps 'io_smppasn:1' to 'io_smppasn', etc.
interface_basename(Name) ->
    case pbutil:split_at($:, atom_to_list(Name)) of
	{BaseName,Ext} -> list_to_atom(BaseName);
	not_found -> Name
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

config_change(Changed, New, Removed) ->
    lists:foreach(fun config_changed/1, Changed),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

config_changed({interfaces, NewInterfaces}) ->
    [{_,OldInterfaces}] = ets:lookup(active_env, {pfront_orangef,interfaces}),
    pfront_sup:interfaces_changed(OldInterfaces, NewInterfaces),
    ets:insert(active_env, {{pfront_orangef,interfaces}, NewInterfaces});

config_changed({sdp_response_timeout, V}) ->
    ok;

config_changed({sdp_connect_timeout, V}) ->
    ok;

config_changed({sdp_queue_size, V}) ->
    io:format("sdp_queue_size will be updated when interfaces restart.~n"),
    ok;

config_changed({sdp_interface_version, V}) ->
    ok;

config_changed(PV) ->
    io:format("Ignoring new config: ~p~n", [PV]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param_info(interfaces) ->
    #param_info{
	    type = {list, {print_raw, interface_type_gene()}},
	    name = "List of interfaces",
	    help = "Specifies all interfaces and their configuration.",
	    example = [],
	    activation = auto
	   };

param_info(sdp_connect_timeout) ->
    #param_info{
	    type = oma_types:timeout(),
	    name = "SDP Connect Timeout",
	    help = "Specifies how long we should wait for the SDP banner.",
	    example = 3000,
	    activation = restart
	   };

param_info(sdp_response_timeout) ->
    #param_info{
	    type = oma_types:timeout(),
	    name = "SDP Response Timeout",
	    help = "Specifies how long we should wait for "
	    "replies to SDP requests.",
	    example = 2000,
	    activation = restart
	   };

param_info(sdp_queue_size) ->
    #param_info{
	    type = int,
	    name = "SDP Queue Size",
	    help = "Specifies how many pending requests the SDP supports. "
	    "Currently all SDPs support only one pending request.",
	    example = 1,
	    activation = restart
	   };

param_info(sdp_interface_version) ->
    #param_info{
	    type = int,
	    name = "SDP Interface Version",
	    help = "Specifies which SDP protocol should be used "
	    "(1:no currency, 2:EUR/FRF). "
	    "As of 11/2001, version 2 should be used.",
	    example = 2,
	    activation = auto
	   };
param_info(d5_canal_num) ->
    #param_info{
	    type = int,
	    name = "D5 parameter Canal Num",
	    help = "Parameter Canal Num used in D5 request.",
	    example = 38,
	    activation = auto
	   };
param_info(tlv_connect_timeout) ->
    #param_info{
	    type = oma_types:timeout(),
	    name = "SDP Connect Timeout",
	    help = "Specifies how long we should wait for the TLV banner.",
	    example = 3000,
	    activation = restart
	   };

param_info(tlv_response_timeout) ->
    #param_info{
	    type = oma_types:timeout(),
	    name = "SDP Response Timeout",
	    help = "Specifies how long we should wait for "
	    "replies to TLV requests.",
	    example = 2000,
	    activation = restart
	   };

param_info(tlv_queue_size) ->
    #param_info{
	    type = int,
	    name = "TLV Queue Size",
	    help = "Specifies how many pending requests the TLV supports. "
	    "Currently all LTVs support only one pending request.",
	    example = 1,
	    activation = restart
	   };
param_info(limande_webserv) ->
    #param_info{
            type = atom,
            name = "Limande Webservices",
            help = "Specifies which Limande webservices interferface is used"
	    " (SSL or not)",
            example = "limande or limande_ssl",
            activation = auto
           };
param_info(mipc_vpbx_config) ->
    #param_info{
	    type = {list, {tuple,"MIPC VPBX Config",
			   [{web_service,atom,
			     "should also be found in pfront::web_services"},
			    {url,string,"The URL to use"}]}},
	    name = "Config used for MIPC VPBX Web Services Interfaces "
	    "(SOAP Protocol over HTTP)",
	    help = "Check each web_service is also declared in"
	    " pfront::web_services",
	    example = [
		       {mipc,"/RubisWSG2R2_MIPC/services/ServicesSimplifies"},
		       {vpbx,"/RubisWSG2R2_VPBX/services/ServicesSimplifies"}],
	    activation = auto
	   };
param_info(mipc_vpbx_content_type) ->
    #param_info{
            type = string,
            name = "MIPC VPBX content type",
            help = "Specifies the content type for MIPC VPBX Web service",
            example = "application/xml+soap; charset=utf-8",
            activation = auto
           };
param_info(sms_mms_infos_webserv) ->
    #param_info{
            type = atom,
            name = "sms_mms_infos Webservices",
            help = "Specifies which  webservices interface is used",
            example = "sms_mms_infos",
            activation = auto
           };


param_info(sms_mms_infos_http_url) ->
    #param_info{
            type = string,
            name = "sms_mms_infos URL",
            help = "Specifies which URL is used for SMS MMS infos service",
            example = "sms_mms_infos",
            activation = auto
           };


param_info(sms_mms_infos_content_type) ->
    #param_info{
            type = string,
            name = "sms_mms_infos Webservices",
            help = "Specifies which contenet type for SMS MMS infos service",
            example = "sms_mms_infos",
            activation = auto
           };


param_info(smsinfos_connect_timeout) ->
    #param_info{
	    type = oma_types:timeout(),
	    name = "SMSINFOS Connect Timeout",
	    help = "Specifies how long we should wait for the SMSINFO banner.",
	    example = 3000,
	    activation = restart
	   };

param_info(smsinfos_response_timeout) ->
    #param_info{
	    type = oma_types:timeout(),
	    name = "SMSINFOS Response Timeout",
	    help = "Specifies how long we should wait for "
	    "replies to SMSINFOS requests.",
	    example = 2000,
	    activation = restart
	   };

param_info(smsinfos_queue_size) ->
    #param_info{
	    type = int,
	    name = "SMS INFOS Queue Size",
	    help = "Specifies how many pending requests the SMSINFO supports. "
	    "Currently all SMSINFOs support only one pending request.",
	    example = 1,
	    activation = restart
	   };

param_info(cbhttp_config)->
    {ok, Ex}=application:get_env(pfront_orangef, cbhttp_config),
    #param_info{
	    type=cbhttp_config(),
	    name = "Config Options use for CBHTTP Interface",
	    help = "Routing, Host and Port use for CBHTTP",
	    example=Ex,
	    activation = auto};
param_info(transfert_nodes) ->
    #param_info{
	    type = {list,string},
	    name = "Transfert Node use for CRA",
	    help = "This list of loginAtNode is used to transfert CRA files"
	    "in nod euse to send this files in CE OF",
	    example = ["cft@io0"],
	    activation = restart
	   };
param_info(ocf_rdp_login) ->
     #param_info{
	    type = {tuple, "LOGIN" , [{"login",string},
				      {"passwd",string}]},
	    name = "Login/Passwd use to XMLRPC/OCF",
	    help = "Login adn pasword use for each OCF/XMLRPC request",
	    example = {"login","passwd"},
	    activation = auto
	   };
param_info(batch_dir) ->
    #param_info{
	    type = string,
	    name = "Repertory use for batch files",
	    help = "Specifies directory suer to store report , files ,..."
	    "use by batch execution",
	    example = "/home/clcm/batch/",
	    activation = auto
	   };
param_info(cdr_transfer_directory)->
     #param_info{
            type = string,
            name = "Directory for cdr files to be sent by cft",
            help = "Specifies directory where file to be sent to be sent by cft are stored,"
	    "The absolute path should be given",
            example = "/home/cft/cra/",
            activation = auto
           };
param_info(batch_ocf_config) ->
    {ok,Ex}=application:get_env(pfront_orangef, batch_ocf_config),
    #param_info{type = type_batch_ocf_config(),
		name = "Batch OCF configuration parameter",
		help = "1:RexFile -> use to select RDP files\n"
		"3:Max delete: limitation of SQL Delete\n"
		"4:Delete Pause: time in ms between echa deletion",
		example= Ex,
		activation = auto
	    };
param_info(batch_ocf_updates_check_period) ->
    #param_info{
	    type = {int, [{gt, 0}]},
	    name = "Interval in seconds between two update files "
	    "presence checks",
	    help = "When no updates are being performed, update files "
	    "presence is checked every batch_ocf_updates_check_period "
	    "seconds. When changed, the new value is taken into account after "
	    "the current pause expires.",
	    example = 300,
	    activation = restart
	   };
param_info(batch_ocf_updates_rates) ->
    #param_info{
	    type = {list, {tuple, "range start",
			   [{"time", {tuple, "time",
				      [{"hour", {int, [{ge,0}, {le,23}]}},
				       {"minute", {int, [{ge,0}, {le,59}]}}]}},
			    {"rate", float}
			   ]}},
	    name = "Rates at which the updates should be performed according "
	    "to the time of the day",
	    help = "Each tuple {T, R} in the list indicates the time "
	    "T from which the rate R should apply. The hours should be "
	    "comprised between 0 and 23. The rate is expressed in updates "
	    "per second. If the first time is not midnight, "
	    "a 0 rate is assumed between midnight and the first time in the "
	    "list (up to the end of the day if the list is empty). The last "
	    "rate in the list applies between the specified time and the end "
	    "of the day. "
	    "Changes are taken into account after the current file processing "
	    "is complete."
	    "The example specifies the following rates: 0h00 -> 2h00: 0 u/s, "
	    "2h00 -> 6h00: 3 u/s, 6h00 -> 13h00: 2 u/s, 13h00 -> 0h00: 0 u/s.",
	    example = [{{2, 00}, 3.0}, {{6, 00}, 2.0}, {{13, 00}, 0.0}],
	    activation = auto,
	    related = [batch_ocf_config]
	   };
param_info(authorized_ul_down) ->
    #param_info{
	    type = bool,
	    name = "Auhtorize update of ussd level lower than it exsits",
	    help = "use only for batch_ocfrdp...",
	    example = true,
	    activation = auto
	    };
param_info(rdp_transfer_directory) ->
    #param_info{
	    type = string,
	    name = "RDP Transfer Directory",
	    help = "",
	    example = "/tmp",
	    activation = auto
	   };
param_info(tech_segs_mapping) ->
    #param_info{
	    type = {list, {tuple, "", [{"integer", int}, {"code", string}]}},
	    name = "Technological segments mapping",
	    help = "The technological segments are stored as integers in the "
		   "database. This list establishes the correspondance "
		   "between the codes and the integers.",
	    example = [{20, "TRM3G"}, {21, "UMTS1"}],
	    activation = auto
	   };
param_info(segco_to_subscr) ->
    #param_info{
	    type = {list, {tuple, "SegCo/Souscription",
			   [{"SegCo", {list, term}},
			    {"Souscription", string}
			   ]}},
	    name = "Correspondence between commercial segment"
	    " and subscription.",
	    help = "",
	    example = [{["ABBOX","ABFLO"], "dme"},
		       {["30JOU"], "postpaid"}],
	    activation = auto
	   };
param_info(url_opal) ->
    #param_info{
	    type = string,
	    name = "Url for Opal service",
	    help = "no help",
	    example = "/pdrsw_G03R04/services/ServicesPDR",
	    activation = auto
	   };
param_info(limande_http_url) ->
    #param_info{
	    type = string,
	    name = "Url the Limande service",
	    help = "no help",
	    example = "/LimSOAPGen/services/LimandeSouscriptionOffre",
	    activation = auto
	   };
param_info(limande_msisdn_balise) ->
    #param_info{
	    type = atom,
	    name = "Balise for the request doSouscriptionOffre for the Limande service",
	    help = "no help",
	    example = 'MSISDN',
	    activation = auto
	   };
param_info(mipc_http_url) ->
    #param_info{
	    type = string,
	    name = "Url of the MIPC service",
	    help = "no help",
	    example = "/mipc",
	    activation = auto
	   };

param_info(vpbx_http_url) ->
    #param_info{
	    type = string,
	    name = "Url of the VPBX service",
	    help = "no help",
	    example = "/vpbx",
	    activation = auto
	   };

param_info(sachem_xml_generic_path) ->
    #param_info{
	    type = string,
	    name = "sachem_xml_generic_path",
	    help = "Specifies directory xml templates stored, relative path",
	    example = "conf/xml_generic/",
	    activation = auto
	   };

param_info(sachem_xml_generic_route) ->
    #param_info{
	    type = string,
	    name = "sachem_xml_generic_route",
	    help = "Specifies routing label when sending a xml_generic request",
	    example = "custom_info",
	    activation = auto
	   };

param_info(sachem_xml_generic_url) ->
    #param_info{
	    type = string,
	    name = "sachem_xml_generic_url",
	    help = "Specifies url of the web service",
	    example = "/xml_generic",
	    activation = auto
	   };

param_info(sachem_xml_generic_timeout) ->
    #param_info{
	    type = string,
	    name = "sachem_xml_generic_timeout",
	    help = "Specifies timeout in ms",
	    example = "1000",
	    activation = auto
	   };

param_info(sachem_version) ->
    #param_info{
	    type = atom,
	    name = "sachem_version",
	    help = "Either sachem_G3R2 or online or offline",
	    example = "sachem_G3R2",
	    activation = auto
	   };
param_info(spider_version) ->
    #param_info{
	    type = atom,
	    name = "spider_version",
	    help = "Either spider_G4R3 or online",
	    example = "spider_G4R3",
	    activation = auto
	   };

param_info(asmetier_version) ->
    #param_info{
	    type = atom,
	    name = "asmetier_version",
	    help = "Either asmetier_G8R3 or online",
	    example = "asmetier_G8R3",
	    activation = auto
	   };
param_info(ocfrdp_version) ->
    #param_info{
	    type = atom,
	    name = "ocfrdp_version",
	    help = "Either ocfrdp_G2R0 or online",
	    example = "ocfrdp_G2R0",
	    activation = auto
	   };

param_info(mipc_vpbx_version) ->
    #param_info{
	    type = atom,
	    name = "mipc_vpbx_version",
	    help = "Either mipc_vpbx_G2R3 or online",
	    example = "mipc_vpbx_G2R3",
	    activation = auto
	   };

param_info(des3_encryption_keys)->
    #param_info{
            type = {list,string},
            name = "DES3_encryption_keys",
            help = "Specifies the key files used by encryption DES3 , cellcube
will choose randomly one file from this list. Attention: Please don't use a
clear-text key directly. Instead use des3_crypto:replace_orange_key/1 to encrypt
the key file",
            example = "conf/ssl/key1.chiper",
            activation = auto
            };
param_info(asm_codeEmetteur_orchidee)->
    #param_info{
	    type = string,
	    name = "asm_codeEmetteur_orchidee",
	    help = "Code Emetteur in ASM doRechargementCBorchidee request for CB CMO",
	    example = "USSD",
	    activation = auto
	    };
param_info(asm_codeEmetteur_edelweiss)->
    #param_info{
	    type = string,
	    name = "asm_codeEmetteur_edelweiss",
	    help = "Code Emetteur in ASM doRechargementCBEdelweiss request for CB Mobicarte",
	    example = "USSDM",
            activation = auto
            }.




interface_type_gene() ->
    InterfaceFields =
	[ {"type", type_interface_type()},
	  {"admin_state", {enum,[enabled,disabled]}},
	  {"Name Node", {tuple, "NameNode", 
			 [{"Name",atom},{"Node",nodeAtHost}]}},
	  {"Descr", string},
	  {handler, type_handler(),
	   "This parameter specifies how incoming events are handled."},
	  {module, type_interface_module(),
	   "This parameter specifies the protocol module for this interface."},
	  {config, type_interface_config(),
	   "This parameter specifies the configuration for this interface.\n"
	   "The type of configuration must match the type of protocol."
	  }],
    {record, "Interface", interface, InterfaceFields}.


type_interface_type() ->
    {enum, [sdp,tlv,smsinfos,rdp,mqseries,httpclient, '$allow_any' ]}.

type_handler() ->
    {enum, [ no_handler,'$allow_any']}.

type_interface_module() ->
    {enum, [mqseries_server,tlv_server,sachem_server,
	    proxyclient_interface,'$allow_any']}.

type_interface_config() ->
    {alt, [ {mqseries_interface,type_mqseries_config()},
	    {sdp_config, type_sdp_config()},
	    {proxyclient_interface,type_proxyclient_config()},
	    {other,term}
	   ]}.

type_mqseries_config()->
    {named_type, "MQ Interface configuration", "",
     {record, "MQ Configuration", mqseries_config,
      [{type,{alt,[{mqseries, {const,mqseries}},
		   {erlang_process, {const,erlang_process}}]},
	"set 'mqseries' for Production, 'erlang_process' for Test "},       
       {put,type_mq_put_method(),
	"Put Function"},
       {get,type_mq_get_method(),
	"Get Function"},
       {ping,{const,nok},
	"Not used, set to nok, nok or Module name "},
       {ping_timeout,{defval,5000,int},
	"Ping Timeout : integer in Ms"},
       {navail,{defval,1,int},
	""},
       {md,  {list,
	      {alt,
	       [{replytoq, {tuple, "Reply to Queue", 
			    [{hidden_const,replytoq},
			     {value,string, ""}
			     ]}
		},
		{expiry, {tuple, "Expiry", 
			    [{hidden_const,expiry},
			     {value,int,
			      ""}
			     ]}
		},
		{persistence, {tuple, "Persistence", 
			       [{hidden_const,persistence},
				{value,int,
				 ""
				}]}
		}
	       ]}
	     },
	"HELP"},
       {check,{alt,[{true, {const,true}},
		    {false,{const,false}}]},
	"Not used: true or false"}
      ]}
    }.

type_sdp_config()->
    {named_type, "Sachem Interface configuration", "",
     {record, "Sachem Configuration", sdp_config,
      [
       {variable,string,
	""},
       {variable2,string,
	""},
       {"type", {alt, 
		 [ 
		  {fsx25port, 
		   {tuple, "X25 port",
		    [ {hidden_const,fsx25port},
		      {"param1", string},
		      {"param2", string}
		     ]}},
		   {fake_config, 
		   {tuple, "Fake",
		    [ {hidden_const,erlang_process},
		      {"fake", {enum,[sachem_fake,sachem_cmo_fake]}}
		     ]}}

% 		   {erlang_process,% {const,mqseries}},
% 		    {tuple, "Erlang process",
% 		     [ {hidden_const,erlang_process},
% 		       {fake_file,{const,sachem_fake}}]
% 		    }}
		  ]}
       }
      ]}}.

type_mq_put_method() ->
    {alt, [ {test_interface, {const,wifi_put_fake}},
	    {production_interface, {tuple, "MQ PUT QUEUE",
				    [ {"Queue", string},
				      {"Queue Manager", string},
				      {"Option", string},
				      {"Option2", string}
				     ]}}
	   ]}.

type_mq_get_method() ->
    {alt, [ {test_interface, {const,wifi_get_fake}},
	    {production_interface, {tuple, "MQ GET QUEUE",
				    [ {"Queue", string},
				      {"Queue Manager", string},
				      {"Option", string}
				     ]}}
	   ]}.

type_proxyclient_config() ->
    {named_type, "ProxyClient configuration", "",
     {record, "ProxyClient configuration", proxyclient_config,
      [ {host, string,
	 "This parameter specifies the remote host name"
	 " or the actual IP address.\n"
	 "It is used for routing purposes only. "},
	{hidden_const, undefined}, %%virtual host
	{port,{defval, 9999, oma_types:port()},
	 "This parameter specifies the remote port."},
	{opt_tcp, {list, term},
	 "Specifies the type of connection"},
	{decoder, type_decoder(),
	 "This parameter specifies the module used to decode ans encode"
	 "the exchanged data with the proxy.\n"
	 "default : default decoder is applied\n"
	 "transparent : no decoding/encoding is applied"},
	{hidden_const, undefined}, %%callback
	{"connect_timeout", {defval, 1000,oma_types:timeout_ms()}}
       ]}
    }.
type_decoder() ->
    {enum, [ {proxy_decoder, "default"},
	     {transparent, "transparent"},
	     '$allow_any' ]}.

type_batch_ocf_config() ->
    Fields = record_info(fields, batch_ocf_config),
    {ok, {batch_ocf_config,DefaultPairs}} =
	application:get_env(pfront_orangef, batch_ocf_config),
    Default = oma_util:pairs_to_record(#batch_ocf_config{}, 
				       Fields, DefaultPairs),
    {pairs, Default, Fields, {defval,Default,type_batch_ocf()}}.

type_batch_ocf() ->
    Fields =
	[ {"file_regexp",   string},
	  {"delete_regexp", string},
	  {"dir",           string},
	  {"backup_dir",    string},
	  {"max_delete",    {int, [ {ge,1}, {le,50000} ]}},
	  {"delete_pause",  int}, %% in ms
	  {"limite_hours",  term}, 
	  {"nodes",         {list, nodeAtHost}},
	  {"read",          {const, 0}},
	  {"update",        {const, 0}},
	  {"delete",        {const, 0}}
	 ],
    {named_type, "Batch RDP Config",
     {record, "Batch RDP Config", batch_ocf_config, Fields}}.

cbhttp_config()->
    {list,{tuple, "CBHTTP CONFIG", [{"SUB_OF",{enum,[mobi,cmo]}},
				    {"CONFIG",{list,term}}]}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +private.

%% +usedeftype([sup_start_result/0]).
