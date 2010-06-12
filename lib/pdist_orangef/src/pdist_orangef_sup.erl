-module(pdist_orangef_sup).
-behaviour(supervisor).

-export([start_link/1, init/1, check_routes/0]).
-export([routing_changed/1]).

%% +type start_link(Arg) -> sup_start_result().

start_link(Arg) ->
    rsupervisor:start_link({local,pdist_orangef_sup}, ?MODULE, Arg).

%% +type init(Args) -> sup_init_result().

init(Args) ->
    %% Start ussd_router on server and admin nodes.
    ChildSpec = {{one_for_one, 2, 10}, children()},
    {ok, ChildSpec}.

%% +type children() -> [child_spec()].
%%%% Determines which routers must be started on this node.

children() ->
    ServerRouters =
	case lists:keysearch(pserver, 1, application:loaded_applications()) of
	    {value, _} -> server_routers();
	    _ ->
		%% ussd_router,etc are started on the admin node too.
		Here = node(),
		case pbutil:get_env(posmon, master_node) of
		    Here -> server_routers();
		    _ -> []
		end
	end,
    %% Start call_router on IO nodes.
    IORouters =
	case lists:keysearch(pfront_orangef, 
			     1, application:loaded_applications()) of
	    {value, _} -> io_routers();
	    _ -> []
	end,
    %% Done.
    ServerRouters++IORouters.


%% +type server_routers() -> [child_spec()].

server_routers() ->
    %% Routing of outgoing SDP requests to sdp_server processes.

    SDP_Workers = generic_router:get_workers(pdist_orangef, sdp_routing),
    SDPR = {sdp_router, {sdp_router, start_link, [SDP_Workers]},
	    permanent, 5000, worker, dynamic},
    TLV_Workers = generic_router:get_workers(pdist_orangef, tlv_routing),
    TLVR = {tlv_router, {tlv_router, start_link, [TLV_Workers]},
	    permanent, 5000, worker, dynamic},
    SMSI_Workers = generic_router:get_workers(pdist_orangef, smsinfos_routing),
    SMSI = {smsinfos_router, {smsinfos_router, start_link, [SMSI_Workers]},
	    permanent, 5000, worker, dynamic},
    MQ_Workers = generic_router:get_workers(pdist_orangef, mqseries_routing),
    MQCR = {mqseries_router,{mqseries_router,start_link,[MQ_Workers]},
	    permanent, 5000, worker, dynamic},

    RDP_Workers = generic_router:get_workers(pdist_orangef, rdp_options_routing),
    RDPR = {rdp_options_router,{rdp_options_router,start_link,[RDP_Workers]},
	    permanent, 5000, worker, dynamic},
    [SDPR, TLVR, MQCR, SMSI, RDPR].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% When routing tables change, restart the routers.
%%%% TODO This should be done incrementally.

routing_changed(sdp_routing) ->
    restart_child(sdp_router);
routing_changed(tlv_routing) ->
    restart_child(tlv_router);
routing_changed(mwp_routing) ->
    restart_child(mwp_router);
routing_changed(mqseries_routing) ->
    restart_child(mqseries_router);
routing_changed(smsinfos_routing) ->
    restart_child(smsinfos_router);
routing_changed(rdp_options_routing) ->
    restart_child(rdp_options_router);
routing_changed(Param) ->
    io:format("## Ignoring ~p~n", [Param]).

restart_child(Name) ->
    rsupervisor:terminate_child(pdist_orangef_sup, Name),
    rsupervisor:delete_child(pdist_orangef_sup, Name),
    case lists:keysearch(Name, 1, children()) of
	{value, Child} -> rsupervisor:start_child(pdist_orangef_sup, Child);
	_ -> ok
    end.

%% +type io_routers() -> [child_spec()].

io_routers() ->
    %% Routing of incoming calls to 
    [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +private.

%% +usedeftype([child_spec/0, sup_shutdown/0, mfa/0]).
%% +usedeftype([sup_start_result/0, sup_init_result/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%Tool to determine all the routes which are connected to valid interfaces

%Useful for the TCP listeners
format({X,Tail})->
     X2 = atom_to_list(X),
     [X3|_] = string:tokens(X2,":"),
     {list_to_atom(X3),Tail}.

filter(Interface_name_list,Routing) ->
fun({Interface_name,_,_})->
	First_filter = lists:member(format(Interface_name),Interface_name_list) == false,
	Second_filter = case Routing of
			    httpclient_routing_no_proxy ->
				lists:sublist(atom_to_list(element(1,Interface_name)),1,5) /= "proxy";
			    httpclient_routing_proxy ->
				lists:sublist(atom_to_list(element(1,Interface_name)),1,5) == "proxy";
			    sms_routing ->
				case string:rstr(atom_to_list(element(1,Interface_name)),"cvf") of 
				    0 -> true;
				    _ -> false
				end;
			    _ ->
				true
			end,
	First_filter and Second_filter
end.

check_route(Routing)->
	{Pdist_module,Pfront_module} =  case Routing of
	     R  when R == cdr_routing;
	             R == httpclient_routing_no_proxy;
	             R == sms_routing;
	             R == sql_routing;
                     R == ussd_routing ->
		     {pdist,pfront};
	     R  when R == mqseries_routing;
                     R == rdp_options_routing;
                     R == sdp_routing;
                     R == smsinfos_routing;
		     R == tlv_routing->
		     {pdist_orangef,pfront_orangef};
	     R  when R == httpclient_routing_proxy->
		    {pdist,pfront_orangef}
	end,

	Env_routing = case Routing of
	     R2 when R2 == httpclient_routing_proxy;
                    R2 == httpclient_routing_no_proxy ->
             	httpclient_routing;
             R2 -> 
		Routing
	end,

	Interface_name_list = [Name || {_,_,_,Name,_,_,_,_} <- pbutil:get_env(Pfront_module,interfaces)],
	[{default,Routes_list}] = pbutil:get_env(Pdist_module,Env_routing), 

	lists:filter(filter(Interface_name_list,Routing), Routes_list).

check_routes() ->
Result = [check_route(Routing) || Routing <- [cdr_routing,
					httpclient_routing_no_proxy,
					sms_routing,
					sql_routing,
					ussd_routing,
					mqseries_routing,
					rdp_options_routing,
					sdp_routing,
					smsinfos_routing,
					tlv_routing,
					httpclient_routing_proxy]].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

