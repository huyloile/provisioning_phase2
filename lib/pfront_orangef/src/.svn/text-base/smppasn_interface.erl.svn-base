-module(smppasn_interface).

%%%% A SMPPASN socket that listens for connections.
%%%% The actual sessions are handled by smppasn_server.

-export([start_link/1]).


-include("../../pfront/include/pfront.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("../../pfront/include/tcp_listener.hrl").

start_link(#interface{type=ussd,
		      name_node={Name,_Node},
		      handler=Handler,
		      extra=Extra}) ->
    {Port, Configs} = decode_extra(Name, Handler, Extra),
    %% Here we tell tcp_listener how to configure the socket
    %% after it has been accepted.
    SockOpts = [ {packet,asn1}, {keepalive,true}, {active,true}, binary ],
    TCPLConfig = #tcpl_config{port=Port,
			      module=smppasn_server,
			      config=Configs,
			      options=SockOpts},
    gen_server:start_link({local,Name}, tcp_listener, TCPLConfig, []).

%%%% The Extra field may be either {Port, SMPPConfig}
%%%% or {Port, MaxClients, SMPPConfig}.

decode_extra(Name, Handler, {Port, SMPPConfig}) ->
    Configs = [ SMPPConfig#smpp_config{name=Name, handler=Handler} ],
    {Port, Configs};

decode_extra(Name, Handler, {Port, Max, SMPPConfig}) ->
    SMPPConfig1 = SMPPConfig#smpp_config{handler=Handler},
    {Port, enum_configs(Name, SMPPConfig1, Max-1)}.

%% +type enum_configs(Name::atom(), smpp_config(), integer()) ->
%%           [smpp_config()].
%%%% Generates configs for children of the tcp_listener with
%%%% names Name:0, Name:1, ...

enum_configs(Name, Config, N) when N < 0 ->
    [];
enum_configs(Name, Config, N) ->
    NameN = list_to_atom(lists:flatten(io_lib:format("~p:~p", [Name, N]))),
    [ Config#smpp_config{name=NameN} | enum_configs(Name, Config, N-1) ].
