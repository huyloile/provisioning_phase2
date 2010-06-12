-module(test_svc_sondage).
-export([run/0, online/0]).
-include("../../pserver/include/page.hrl").

-define(IMSI, "999000900000001").
-define(msisdn,"+33900000001").
-define(MSISDN_NAT,"0900000001").
-define(service_code, "#128").

run()->
    ok.

online() ->
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,test()),
    [].

test()->
    [{title, "Test SONDAGE"}] ++
	test_util_of:connect()++
	test_service_access(?service_code)++
	test_util_of:close_session() ++
	["Test reussi"] ++
        [].

test_service_access(Service_code) ->
    [{title,"TEST SERVICE ACCESS"}]++
	init("virgin")++
	["Access not allowed"]++
        [{ussd2,
          [{send,Service_code},
           {expect,"Vous n'avez pas acces a ce service.*"}
          ]}]++
	init("cmo")++
	init_config("212.99.5.28","80")++ %% itwprojets1.123interview.com	
	["Access ok - Response not available"]++
        [{ussd2,
          [{send,Service_code},
           {expect,"A propos de la qualite d'ecoute du conseiller, etes-vous ....*"
	    "1:Tres satisfait.*"
	    "2:Satisfait.*"
	    "3:Peu satisfait.*"
	    "4:Pas du tout satisfait.*"}
          ]}]++
        test_util_of:close_session()++
	["ok"].


init(Subs) ->
    ["Subscription: "++Subs]++
    test_util_of:init_test(?IMSI, Subs, 1, "100008XXXXXXX1") ++
        test_util_of:change_msisdn(?IMSI,?msisdn).
	
    
init_config(Host,Port) ->
	Value = [{xh_host,
	      [
	       {host,Host},
	       {port,list_to_integer(Port)},
	       {allow,true},
	       {http_version,"1.1"},
	       {routing,sondage},
	       {send_profile,[lang,msisdn,imsi,addr_msisdn,addr_imsi]},
	       {allow_cookies,true},
	       {allow_private_cache,true},
	       {allow_public_cache,true},
	       {trace,true}]}],
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
		    set_env,[pserver,xmlhttp_hosts,Value]]}
      ]}].


