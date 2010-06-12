-module(wifi_request).

-export([request/1]).

-export([ping_send/0,ping_expect/1]).   %%%%% For interface MQSeries

-include("../../pservices_orangef/include/wifi.hrl").
-include("../../pserver/include/pserver.hrl").

%%%% make request to WIFI
%% +type request(profile())->{ok,wifi()}| nok | exit().
request(Prof) ->
    {{Y,M,D},{Ho,Mi,Se}} = calendar:now_to_local_time(now()),
    Request = 
	pbutil:sprintf("USSD%3s%04d%02d%02d%02d%02d%02d% 12s% 15s% 9s% 103s",
		       [type(Prof#profile.subscription),
			Y,M,D,Ho,Mi,Se,Prof#profile.msisdn,
			Prof#profile.imsi,"",""]),
    Request2 = lists:flatten(Request),
    case catch(mqseries_router:request(Request2,[wifi],5000)) of
	{ok,Result} ->
	    slog:event(trace,?MODULE,wifi_result,Result),
	    decrypt_result(Result);
	{'EXIT',Err} ->
	    slog:event(failure,?MODULE,wifi_exit,Err),
	    nok;
	{error,Reason} ->
	    slog:event(failure,?MODULE,wifi_exit,Reason),
	    nok;
	Other ->
	    slog:event(internal,?MODULE,wifi_unexpected,Other),
	    nok	    
    end.


%%%% decrypt data from WIFI OTP
%% +type decrypt_result(Result::string()) -> exit() | {ok, wifi()} | nok.
decrypt_result(Result) ->
    case pbutil:sscanf("%57s%3d%4s%40s",Result) of
	{[_,Return,Pass,Info],_} ->
	    decrypt(Return,Pass,Info);
	Res ->
	    exit({unexpected_format,Result})
    end.

%%%%  decrypt data from WIFI and first chech about result.
%% +type decrypt(string(),string(),string()) ->  {ok,wifi()} | nok.
decrypt(Return,Pass,Info) when Return < 600 ->
    if Return == 401 ->
	    slog:event(internal,?MODULE,decrypt,401),
	    nok;
       Return == 402 ->
	    slog:event(failure,?MODULE,decrypt,402),
	    analyse(0,Pass,Info); %%%%% Error but service should be done
       true ->
	    analyse(Return,Pass,Info)
    end;

decrypt(Other,_,_) ->
    slog:event(failure,?MODULE,decrypt,Other),
    nok.

%% +type analyse(int(), string(), string()) -> {ok,wifi()}.
analyse(Return,Pass,Info) ->
    Wifi = #wifi{return = Return,
		 password = Pass,
		 text = string:strip(Info,right,$ )},
    {ok,Wifi}.

%%%% defines type of request function to subscription
%% +type type(string()) -> string().
type("dme") -> "OTP";
type("opim") -> "OTP";
type("anon") -> "OTP"; %%% Coriolis
type("postpaid") -> "IPO".
    
%%%%%%%%%% MQSeries API PING%%%%%%%%%%%%%%%%%%%%
%%%%%%% No GSM number --> response with code 1
%% +type ping_send() -> term().
ping_send() -> 
    {{Y,M,D},{Ho,Mi,Se}} = calendar:now_to_local_time(now()),
    Request = pbutil:sprintf("USSDOTP%04d%02d%02d%02d%02d%02d% 139s",
			     [Y,M,D,Ho,Mi,Se,""]),
    lists:flatten(Request).

%% +type ping_expect(Data::string()) -> ok | exit(Reason).
ping_expect(Data) -> 
    case pbutil:sscanf("%57s%3d",Data) of
	{[_,401],_} -> ok;
	Other -> exit({bad_ping,1,Other})
    end.
    
