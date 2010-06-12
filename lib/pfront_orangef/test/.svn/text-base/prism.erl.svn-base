%% Simulateur de traitement de requêtes envoyées à PRISM pour le callback OF
%% Utilisation de l'interface SMPP pour simuler le couple Cellgate-Prism

%% Les réponses dépendent du triplet 
%% {MSISDN appelant,VLR Number,MSISDN appelé}

-module(prism).

-export([start/0,run/1]).

-include("../../pfront/include/smpp_server.hrl").
-include("../../pgsm/include/ussd.hrl").

-define(GOOD_VLR,    "38900000000"). %%"20475000000").
-define(GOOD_VLR2,   "10000000000").
-define(BAD_VLR,     "22689002341").
-define(MING_VLR,    "21698000000").
-define(MING_VLR2,   "11111000000").
-define(BAD_MING_VLR,"21622002341").
-define(NOCAMEL_VLR, "21699000000").

-define(MSISDN_OK,"+33900000747").
-define(MSISDN_INACC,  "+33900000039").
-define(MSISDN_CREDIT, "+33900000164").
-define(MSISDN_NOACC,  "+33900000045").
-define(MSISDN_EPUISE, "+33900000180").


%%%%%%%%%%%%%%%%%%%%%%%%% Starting the gen_server %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->
    proc_lib:start_link(?MODULE,run,[{"localhost",7435}]),
    wait().

wait() ->
    receive
	Other ->  
	    log({stop,Other})

    end.    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

run(Args) ->
    register(prism,self()),
    proc_lib:init_ack({ok,self()}),
    log(starting),
    connect(Args).

connect({Host,Port}) ->
    log({connecting,Host,Port}),
    Connect = (catch gen_tcp:connect(Host,Port, [{active,true}, binary])),
    case Connect of
	{ok,Sock} -> 
	    Handler = fun(USSD) -> prism!{fake_insert_ussdcallback, USSD} end,
	    %% Now start a client on this TCP connection.
	    Conf = #smpp_config{name            = smpp_callback_client,
				handler         = Handler,
				enquire_timeout = infinity,
				inact_timeout   = infinity}, 
	    {ok, Pid} = smpp_server:start_link({Conf,Sock}),
	    log({connected,Host,Port}),
	    handle_loop();
	_ ->
	    log({could_not_connect,Host,Port}),
	    %% Let's wait for the interface to go up
	    receive after 5000 -> ok end,
	    exit(unable_to_connect)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_loop() ->
    receive
	{fake_insert_ussdcallback, 
	 #ussd_msg{msaddr = {international, isdn, MSISDN},
		   op     = pssr,
		   info   = Info} = USSD}-> 
	    %%log({prism_receiving,USSD}),
 	    Reply = reply_to(USSD),
	    ReplyDATA = gsmcharset:iso2ud(Reply,default_alphabet),
	    ReplyUSSD =  
		#ussd_msg{msaddr = {international, isdn, MSISDN},
			  dcs     = default_alphabet,
			  op      = pssr_response,
			  data    = ReplyDATA,
			  info    = Info},
	    Toto = gen_server:call(smpp_callback_client,{insert,ReplyUSSD}),
	    handle_loop();
	Else ->
	    log({unexpected_receipt,Else}),
	    handle_loop()
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Misc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reply_to(#ussd_msg{msaddr = {international, isdn, MSISDN},
		   dcs     = DCS,
		   data    = Data,
		   info    = Info}) ->
    [$#,S1,S2,S3,$* | Text] =  gsmcharset:ud2iso(DCS,Data),
    VLRNumber = case lists:keysearch(vlr_number, 1, Info) of
		    {value, {_,V}} -> V;
		    false          -> "0"
		end,

    %% Treats service code
    SC_CMO  = pbutil:get_env(pservices_orangef,callback_cmo_sc),
    SC_MOBI = pbutil:get_env(pservices_orangef,callback_mobi_sc),

    SC = [$#,S1,S2,S3],
    Subs = case SC of
	       SC_CMO  -> "CMO";
	       SC_MOBI -> "MOBI";
	       _ -> exit({bad_service_code_for_prism,SC})
	   end,    

    NumberToCall = case Text of
		       N when list(N) -> N;
		       _ -> ""
		   end,
    log({Subs,MSISDN,VLRNumber,NumberToCall}),
    %% First test user status
    make_reply(Subs,MSISDN,VLRNumber,NumberToCall).

%% succès messagerie vocale Mobi
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR,"777#") ->
    "SUCCESS";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"777#") ->
    "SUCCESS";
%% succès messagerie vocale CMO
make_reply("CMO",?MSISDN_OK,?MING_VLR,"888#") ->
    "SUCCESS";
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR,"888#") ->
    "SUCCESS";

%% succès service clients
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR,"722#") ->
    "SUCCESS";
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR,"722#") ->
    "SUCCESS";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"722#") ->
    "SUCCESS";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"722#") ->
    "SUCCESS";

%% épuisé
make_reply("MOBI",?MSISDN_EPUISE,?GOOD_VLR,_) ->
    "ERROR 2";
make_reply("CMO",?MSISDN_EPUISE,?GOOD_VLR,_) ->
    "ERROR 2";
make_reply("MOBI",?MSISDN_EPUISE,?MING_VLR,_) ->
    "ERROR 2";
make_reply("CMO",?MSISDN_EPUISE,?MING_VLR,_) ->
    "ERROR 2";

%% inaccessible (non déclaré)
make_reply("MOBI",?MSISDN_INACC,?GOOD_VLR,_) ->
    "ERROR 3";
make_reply("CMO",?MSISDN_INACC,?GOOD_VLR,_) ->
    "ERROR 3";
make_reply("MOBI",?MSISDN_INACC,?MING_VLR,_) ->
    "ERROR 3";
make_reply("CMO",?MSISDN_INACC,?MING_VLR,_) ->
    "ERROR 3";
%% pas assez de crédit(sursis)
make_reply("MOBI",?MSISDN_CREDIT,?GOOD_VLR,_) ->
    "ERROR 4";
make_reply("CMO",?MSISDN_CREDIT,?GOOD_VLR,_) ->
    "ERROR 4";
make_reply("MOBI",?MSISDN_CREDIT,?MING_VLR,_) ->
    "ERROR 4";
make_reply("CMO",?MSISDN_CREDIT,?MING_VLR,_) ->
    "ERROR 4";
%% numéro non appelable"
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR,"1234567891#") ->
    "ERROR 5";
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR,"1234567891#") ->
    "ERROR 5";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"1234567891#") ->
    "ERROR 5";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"1234567891#") ->
    "ERROR 5";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"0012345678910#") ->
    "ERROR 5";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"0012345678910#") ->
    "ERROR 5";
%% pas accès au service (résilié)
make_reply("MOBI",?MSISDN_NOACC,?GOOD_VLR,_) ->
    "ERROR 6";
make_reply("CMO",?MSISDN_NOACC,?GOOD_VLR,_) ->
    "ERROR 6";
make_reply("MOBI",?MSISDN_NOACC,?MING_VLR,_) ->
    "ERROR 6";
make_reply("CMO",?MSISDN_NOACC,?MING_VLR,_) ->
    "ERROR 6";
%% VLR non autorisé
make_reply("MOBI",?MSISDN_OK,?BAD_VLR,_) ->
    "ERROR 7";
make_reply("CMO", ?MSISDN_OK,?BAD_VLR,_) ->
    "ERROR 7";
make_reply("MOBI",?MSISDN_OK,?BAD_MING_VLR,_) ->
    "ERROR 7";
make_reply("CMO", ?MSISDN_OK,?BAD_MING_VLR,_) ->
    "ERROR 7";

%% Accès restreint, pays connu
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR,"0987654321#")  ->
    "ERROR 8";
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR,"0987654321#") ->
    "ERROR 8";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"0987654321#")  ->
    "ERROR 8";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"0987654321#") ->
    "ERROR 8";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"0098765432190#")  ->
    "ERROR 8";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"0098765432190#") ->
    "ERROR 8";

%% Accès restreint, pays inconnu
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR2,"0987654321#") ->
    "ERROR 8";
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR2,"0987654321#") ->
    "ERROR 8";
make_reply("MOBI",?MSISDN_OK,?MING_VLR2,"0098765432190#") ->
    "ERROR 8";
make_reply("CMO", ?MSISDN_OK,?MING_VLR2,"0098765432190#") ->
    "ERROR 8";

%% Appel n'aboutissant pas
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR,"1111111111#") ->
    "ERROR 9";
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR,"1111111111#") ->
    "ERROR 9";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"1111111111#") ->
    "ERROR 9";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"1111111111#") ->
    "ERROR 9";
make_reply("MOBI",?MSISDN_OK,?MING_VLR,"0011111111111#") ->
    "ERROR 9";
make_reply("CMO", ?MSISDN_OK,?MING_VLR,"0011111111111#") ->
    "ERROR 9";

%% succès du callback
make_reply("MOBI",?MSISDN_OK,?GOOD_VLR,[_ | Number]) ->
    success(Number);
make_reply("CMO", ?MSISDN_OK,?GOOD_VLR,[_ | Number]) ->
    success(Number);
make_reply("MOBI",?MSISDN_OK,?MING_VLR,[_ | Number]) ->
    success(Number);
make_reply("CMO", ?MSISDN_OK,?MING_VLR,[_ | Number]) ->
    success(Number);
make_reply("MOBI",?MSISDN_OK,?NOCAMEL_VLR,[_ | Number]) ->
    success(Number);
make_reply("CMO", ?MSISDN_OK,?NOCAMEL_VLR,[_ | Number]) ->
    success(Number);
    
%% cas non prévu
make_reply(_,_,_,_) ->
    "ERROR X".
    

success(Number) ->
    case lists:reverse(Number) of
	[$#|DIGITS] ->
	    case pbutil:all_digits(DIGITS) of
		true -> "SUCCESS";
		_ -> "ERROR X"
	    end;
	_ -> "ERROR X"
    end.

	
log(Event) ->	
    io:format("** PRISM : ~p **~n",[Event]).
	
	    
