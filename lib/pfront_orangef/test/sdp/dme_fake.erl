%% Simulation (très approximative) de l'interface Sachem MUSS.
%% Behaves like a port process with an additional connection
%% establishment phase.

-module(dme_fake).
-export([run/0]).
-export([start/0, start_reliable/0]).


-export([put_fake/0,get_fake/0]).

start() -> proc_lib:start(?MODULE, run, []).

start_reliable() -> proc_lib:start(?MODULE, run_reliable, []).
     
run() ->
    spawn(?MODULE,put_fake,[]),
    spawn(?MODULE,get_fake,[]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true).



put_fake() ->
    global:register_name(dme_put_fake, self()),
    io:format("put_fake registered~n"),
    available_put().

get_fake() ->
    global:register_name(dme_get_fake, self()),
    io:format("get_fake registered~n"),
    available_get().


available_get() ->
    receive
	{_, {command,_}} ->
	    %%%% md structure not used for erlang_process !!!
	    available_get();
	{From,Message} ->
	    Message2 = term_to_binary({get,Message}),
	    From!{self(),{data,Message2}},
	    available_get();
	X ->
	    io:format("X message get ~p~n",[X])
    after 1000 ->
	    available_get()
    end.

available_put() ->
    receive
	{_,{command,"E"}} ->
	    receive
		{From,{command,Message}} ->
		    From!{self(),{data,term_to_binary({put,0,"null"})}}, %%%% ack
		    Resp = response(Message),
		    Resp2 = lists:flatten(Resp),
		    pbutil:whereis_name(dme_get_fake)!{From,Resp2},
		    available_put()
	    after 1000 ->
		    exit(no_message_after_E)
	    end;
	{_,{command,Dict}} ->
	    erase(),
	    io:format("DME_FAKE ~p~n",[Dict]),
	    {dictionnary, List}  = binary_to_term(Dict),
	    lists:foreach(fun({Get,Value}) -> put(Get,Value) end, List),
	    available_put()
    after 2000 ->
	    erase(), %%%% delete all value stored for test
	    available_put()
    end.



response(("503"++_) = Req) ->
    case pbutil:sscanf("%3s%10s",Req) of
	{[_,MSISDN],_} ->  
	    case catch(create_data(MSISDN)) of
		{'EXIT',Error} -> 
		    slog:event(internal,?MODULE,response,Error),
		    "00001" ++ lists:duplicate(514,"/");
		Res -> Res
	    end;
	_  -> 
	    slog:event(internal,?MODULE,bad_format,Req),
	    "00001" ++ lists:duplicate(514," ")
    end;
response(Other) ->
    slog:event(internal,?MODULE,response,Other),
    "00001" ++ lists:duplicate(514," ").


create_data([$9,$3,$0,$9,$2,$0|Rest]=MSISDN) ->
    {[_,I_Script],[]} = pbutil:sscanf("%2d%2d",Rest),
    case info_script(I_Script,MSISDN) of 
	{Header,Princ}	->
	    I_Godet = default(1,nb_godet),
	    Godet = godet(I_Godet),
	    Godet2 = lists:flatten(Godet),
	    create_data2(Header,Princ,Godet2);
	Data ->
	    Data
    end;
create_data([$0|Next]=MSISDN) ->
    io:format("Msisnd:~p~n",[MSISDN]),
    case sachem_cmo_fake:get_test_subscription("+33"++Next) of
	"dme"->
	    [_,_,_,_,_,_|Rest]=MSISDN,
	    {[_,I_Script],[]} = pbutil:sscanf("%2d%2d",Rest),
	    case info_script(I_Script,MSISDN) of 
		{Header,Princ}	->
		    I_Godet = default(1,nb_godet),
		    Godet = godet(I_Godet),
		    Godet2 = lists:flatten(Godet),
		    create_data2(Header,Princ,Godet2);
		Data ->
		    Data
	    end;
	_->
	    io:format("~p NOT DME~n",[?MODULE]),
	    %% MSISND inconnu  
	    H = ["2",MSISDN,"","3","OSEN",[],"compte","","2810","121620","0311","0312"],
	    P = ["","","","","","","","","","","","","","",""],
	    create_data2(H,P,"")
    end.

create_data2(Header,Princ,Godet) ->
    Header2 = pbutil:sprintf("%05s%10s% 8s% 4s%4s% 10s% 8s% 4s%4s%6s%4s%4s",Header),
    Princ2 = pbutil:sprintf("% 6s+%12s%6s%6s%6s+%12s%6s+%12s%6s%6s%6s%6s%6s%6s%6s",Princ),
    Godet2 =  pbutil:sprintf("%246s",[Godet]),
    Header2 ++ lists:duplicate(52," ") ++ Princ2 ++ lists:duplicate(39," ") ++ Godet2 ++ lists:duplicate(10," ").
  
godet(0) -> "";
godet(1) ->
    G = default(["GRP001","001500","C","","","001300"],godet),
    pbutil:sprintf("%6s%13s%1s%4s%4s%13s",G);
godet(2) ->
    G = get(godet),
    pbutil:sprintf("%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s",G);
godet(3) ->
    G = get(godet),
    pbutil:sprintf("%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s",G);
godet(4) ->
    G = get(godet),
    pbutil:sprintf("%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s"
		   "%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s",G);
godet(5) ->
    G = get(godet),
    pbutil:sprintf("%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s"
		   "%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s",G);
godet(6) ->
    G = get(godet),
    pbutil:sprintf("%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s"
		   "%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s%6s%13s%1s%4s%4s%13s",G).

%%%%% Basic
info_script(1,MSISDN) ->
    H = ["0",MSISDN,"","1","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000","000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(2,MSISDN) ->
    H = ["0",MSISDN,"","2","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","990000009950",default("015900",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	     "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(3,MSISDN) ->
    H = ["0",MSISDN,"","3","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000" ,"000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(4,MSISDN) ->
    H = ["0",MSISDN,"","4","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	  "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(5,MSISDN) ->
    H = ["0",MSISDN,"","5","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	    "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(6,MSISDN) ->
    H = ["0",MSISDN,"","6","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000" ,"000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(7,MSISDN) ->
    H = ["0",MSISDN,"","7","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000" ,"000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(8,MSISDN) ->
    H = ["0",MSISDN,"","8","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(9,MSISDN) ->
    H = ["0",MSISDN,"","9","OSEN",[],"compte","","2810","121620","0311","0312"],   
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};


info_script(10,MSISDN) ->
    H = ["0",MSISDN,"","10","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","0000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(11,MSISDN) ->
    H = ["0",MSISDN,"","11","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	  "000000" ,"000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(12,MSISDN) ->
    H = ["0",MSISDN,"","12","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(13,MSISDN) ->
    H = ["0",MSISDN,"","13","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"000000000075",default("001025",hf_dur),default("900000000075",hf_mount),"030000", %%% Info forfait
	   "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};

info_script(14,MSISDN) ->
    H = ["0",MSISDN,"","14","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),default("000000",dep_dur),"00000000075",default("001025",hf_dur),default("000000000975",hf_mount),"030000", %%% Info forfait
	 "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P};
info_script(15,MSISDN) ->
    H = ["0",MSISDN,"","15","OSEN","","compte","","2810","121620",
	 "0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),
	 default("000100",cons_dur),default("000000",dep_dur),"00000000075",
	 default("001025",hf_dur),default("000000000975",hf_mount),
	 "030000", %%% Info forfait
	 "000000","000000","000000","000000",default("000000",init_bonus),
	 "000000"],
    {H,P};
info_script(16,MSISDN) ->
    H = ["0",MSISDN,"","16","OSEN","","compte","","2810","121620",
	 "0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),
	 default("000100",cons_dur),default("000000",dep_dur),"00000000075",
	 default("001025",hf_dur),default("000000000975",hf_mount),
	 "030000", %%% Info forfait
	 "000000","000000","000000","000000",default("000000",init_bonus),
	 "000000"],
    {H,P};
info_script(17,MSISDN) ->
    H = ["0",MSISDN,"","17","OSEN","","compte","","2810","121620",
	 "0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),
	 default("000100",cons_dur),default("000000",dep_dur),"00000000075",
	 default("001025",hf_dur),default("000000000975",hf_mount),
	 "030000", %%% Info forfait
	 "000000","000000","000000","000000",default("000000",init_bonus),
	 "000000"],
    {H,P};
info_script(18,_) ->
    pbutil:sprintf("%05s% 514s",["16",""]);
info_script(19,_) ->
    pbutil:sprintf("%05s% 514s",["32",""]);
info_script(20,MSISDN) ->
    H = ["64",MSISDN,"","14","OSEN",[],"compte","","2810","121620","0311","0312"],
    P = ["030000","000000009950",default("020000",rest_dur),default("000100",cons_dur),"000000","00000000075",default("001025",hf_dur),default("000000000975",hf_mount),"030000", %%% Info forfait
	 "000000","000000","000000","000000",default("000000",init_bonus),"000000"],
    {H,P}.



default(Value,Search) ->
    case get(Search) of 
	undefined -> Value;
	Get -> Get
    end.
	    
