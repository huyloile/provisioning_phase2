-module(mqseries_router).

-export([start_link/1, 
	 request/2, request/3, request/4,
	 request_no_resp/2, request_no_resp/3, request_no_resp/4]).

-export([pool_get_attrib/1]).

-include("../../pfront/include/pfront.hrl").
-include("../../pfront_orangef/include/mqseries.hrl").

%%%% <h2> Client API </h2>

%% +type start_link([worker()]) -> gs_start_result().

start_link(Workers) ->
    Arg = {{?MODULE,pool_get_attrib}, Workers},
    pool_server:start_link({?MODULE, Workers, fun()-> true end}).

%% +type request(term(),unixmtime()) -> term().
request(Req, Timeout) ->
    request_int(Req,[],Timeout,Timeout,true).

%% +type request(term(),term(),unixmtime()) -> term().
request(Req, Attr, Timeout) ->
    request_int(Req,Attr,Timeout,Timeout,true).

%% +type request(term(),term(),unixmtime(),unixmtime()) -> term().
request(Req, Attr, TimeoutService, TimeoutInterface) ->
    request_int(Req,Attr,TimeoutService,TimeoutInterface,true).

%% +type request_no_resp(term(), unixmtime()) -> term().
request_no_resp(Req, Timeout) ->
    request_int(Req,[],Timeout,Timeout,false).

%% +type request_no_resp(term(),term(),unixmtime()) -> term().
request_no_resp(Req, Attr, Timeout) ->
    request_int(Req,Attr,Timeout,Timeout,false).

%% +type request_no_resp(term(),term(),unixmtime(),unixmtime()) -> term().
request_no_resp(Req, Attr, TimeoutService, TimeoutInterface) ->
    request_int(Req,Attr,TimeoutService,TimeoutInterface,false).

%%%% <h2> Callbacks API </h2>

%% +type request_int(term(),term(),unixmtime(),unixmtime(),true|false) 
%%                  -> term().
request_int(Req,Attr,TimeoutService,TimeoutInterface,Expect) ->
    Req1 = #mqseries_request{send=Req, attr=Attr, 
			     timeout=TimeoutInterface, expect_resp=Expect},
    slog:event(trace, ?MODULE, request, Req1),
    mqseries_server:request(mqseries_router, Req1, TimeoutService).
    

%% +type pool_get_attrib(mqseries_request()) -> [term()].
%%%% Allows pool_server to read the address in a request to a
%%%% ussd_server.

pool_get_attrib(#mqseries_request{attr=Attr}) -> Attr.
