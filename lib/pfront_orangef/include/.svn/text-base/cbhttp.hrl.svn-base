%%%% <h2> Client API </h2>
-define(TIMEOUT,5000).
-define(PAY_TIMEOUT,20000).
-define(MCC_TIMEOUT,20000).


%% +deftype cbhttp_config() =
%%     #cbhttp_config{
%%        routing      :: [atom()],
%%        method       :: post | get,
%%        host         :: string(),
%%        port         :: integer(),
%%        origine      :: string()}.
-record(cbhttp_config,{
	  routing=[cb_http],
	  method=post,
	  host="cb_http.cvf",
	  port=8998,
	  origine="USSDCMO"}).
