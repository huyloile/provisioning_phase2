%% Simulation (très approximative) de l'interface Sachem MUSS.
%% Behaves like a port process with an additional connection
%% establishment phase.

-module(smsinfos_fake).
-export([start/0,run/0]).
-export([request/1]).

-define(BANNER, "FTMREADY01").
%%use fro A3
-include("../../../../lib/pservices_orangef/include/mmsinfos.hrl").

start() -> proc_lib:start(?MODULE, run, []).
    
run() ->
    init_test(),
    global:register_name(smsinfos_fake, self()),
    io:format("registered ~p~n", [global:whereis_name(smsinfos_fake)]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 100),
     init_test(),
    available().

available() ->
    receive
	{Client, connect} ->
	    link(Client),
	    Client ! {self(), connected},
	    io:format("~p connected~n", [Client]),
	    connected(Client);
	M -> pbutil:badmsg(M, ?MODULE),
	     available()
    after 1000 ->
	     available()
    end.

connected(Client) ->
    receive
	{'EXIT', Client, E} ->
	    io:format("~p crashed : ~p~n", [Client, E]),
	    ?MODULE:available();
	{Client, {command, Req}} ->
	    %% Requests may be deeplists.
	    Request = lists:flatten(Req),
	    xdebug("~p > \"~s\"~n", [Client, Request]),
	    case catch request(Request) of
		{'EXIT', E} ->
		    xdebug("Error: ~p~n", [E]),
		    %% Let the client timeout
		    connected(Client);
		Reply ->
		    xdebug("~p < \"~s\"~n", [Client, lists:flatten(Reply)]),
		    %% Flatten and send the reply
		    send_line(Client, lists:flatten(Reply)),
		    connected(Client)
	    end;
	{Client, close} ->
	    unlink(Client),
	    Client ! {self(), closed},
	    available();
	M -> pbutil:badmsg(M, ?MODULE)
    end.

xdebug(Format, Args) ->
    io:format("~p: "++Format, [?MODULE | Args]),
    ok.

%%%% Sends an ascii line, simulating the behaviour of a port process.

send_line(Client, Line) ->
    Client ! {self(), {data,{eol,Line}}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% "B" requests (taxation).
request(("ORAINFdprofMediaSVI "++Data)=Req) ->
    io:format("Test....~n"),
    [MSISDN, Media,Flux] = string:tokens(Data,";"),
    case lists:last(MSISDN) of
	$X ->
	    %% 93 no profile
	    pbutil:sprintf("ORAINFdprofMediaSVI %s;93",[MSISDN]);
	$9 ->
	    %% 99 Unknown Error 
	    pbutil:sprintf("ORAINFdprofMediaSVI %s;99",[MSISDN]);
	_->
	    {_,Fact,List}= info(MSISDN),
	    pbutil:sprintf("ORAINFdprofMediaSVI %s;90;%d;%s;%s;%s",
			   [MSISDN,1000,"123456",Fact,format_list(List)])
    end;

request(("ORAINFdprofFactSVI "++Data)=Req) ->
    io:format("Test....~n"),
    [MSISDN, Media] = string:tokens(Data,";"),
    case lists:last(MSISDN) of
	$1 ->
	    %% 93 no profile
	    pbutil:sprintf("ORAINFdprofFactSVI %s;93",[MSISDN]);
	_->
	    {_,_,List}= info(MSISDN),
	    io:format("Liste: ~p~n",[List]),
	    pbutil:sprintf("ORAINFdprofFactSVI %s;90;%d;%s;%s",
			   [MSISDN,1000,"TERMNR",format_list_fact(List)])
    end;
request(("ORAINFmodprofSVI "++Data)=Req) ->
    io:format("Test....~n"),
    [MSISDN,Ids,Comp1,Comp2,Comp3,Sub,Fact,"USSD",CompOffre] = tokens(Data,$;,[]),
    {Y,M,D} =date(),
    pbutil:sprintf("ORAINFmodprofSVI %s;90;%04d%02d%02d",
			   [MSISDN,Y,M,D]);

request(("ORAINFtarifSVI "++Data)=Req) ->
    io:format("TarfiSVI....~n"),
    [MSISDN, ID, FactType] = string:tokens(Data,";"),
    P=
	case lists:last(MSISDN) of
	    $1 ->
		%% No profile exists
		0;
	    _  ->
		%% The subscriber has already used one of media
		%% SMS Infos( or OL1), MMS Infos and MMMS Vidéo
		1500
    end,

% 	case ets:lookup(smsinfos,MSISDN) of
% 	    [{_,Fact,Liste}]->
% 		2000;
% 	    E->
% 		io:format("tarif :~p~n",[E]),
% 		0
% 	end,
    case FactType of
	"A"->
	    pbutil:sprintf("ORAINFtarifSVI %s;90;%d;%d",
			   [MSISDN,P,2000]);
	"M" ->
	    pbutil:sprintf("ORAINFtarifSVI %s;90;%d;%d",[MSISDN,P,100]);
	"J" ->
	    pbutil:sprintf("ORAINFtarifSVI %s;90;%d;%d",[MSISDN,P,100])
    end;
request(("ORAINFdprofrub "++Data)=Req) ->
    io:format("dprof RUB....~n"),
    [MSISDN, ID, Media] = tokens(Data,$;,[]),
    {Y,M,D} =date(),
    case ID of
	"10011"->
	    %% meteo
	    pbutil:sprintf("ORAINFdprofrub %s;90;%d;%s;%s;%04d%02d%02d;0;SMS",
			   [MSISDN,3219,"","",Y,M,D]); %% 3219 = Marseille
	"30020"->
	    %% horoscope
	    pbutil:sprintf("ORAINFdprofrub %s;90;%d;%s;%s;%04d%02d%02d;0;SMS",
			   [MSISDN,1,"","",Y,M,D]); %% BELIER
	"50120"->
	    %% horoscope
	    pbutil:sprintf("ORAINFdprofrub %s;90;%d;%s;%s;%04d%02d%02d;0;SMS",
			   [MSISDN,1,"1","",Y,M,D]); %% BELIER
	_->
	    pbutil:sprintf("ORAINFdprofrub %s;99",[MSISDN])
    end;
request(("ORAINFdprofforfait "++Data)=Req) ->
    io:format("dprof Forfait....~n"),
    [MSISDN, ID, Media] = tokens(Data,$;,[]),
    {Y,M,D} =date(),
    case ID of %%TypeForfait, Comp, DateFin, ListRub]
	"20006"->
	    %% actu locale
	    pbutil:sprintf("ORAINFdprofforfait %s;90;%s;%d;%04d%02d%02d;%s",
			   [MSISDN,"T",59,Y,M,D,"20004 20005"]); %% NORD
	"33005"->
	    %% ligue1
	    pbutil:sprintf("ORAINFdprofforfait %s;90;%s;%s;%04d%02d%02d;%s",
			   [MSISDN,"T","09",Y,M,D,"33005 33004"]); %% LYON
	_->
	    pbutil:sprintf("ORAINFdprofforfait %s;99",[MSISDN])
    end;
request(("ORAINFdterm "++Data)=Req) ->
    io:format("Dterm....~n"),
    [MSISDN] = string:tokens(Data,";"),
    case lists:last(MSISDN) of
	$3 ->
	    %% 93 no profile
	    pbutil:sprintf("ORAINFdterm %s;93;TER;1;0",[MSISDN]);
	$5 ->
	    %% 94 terminal no renseigné
	    pbutil:sprintf("ORAINFdterm %s;94",[MSISDN]);
	$6 ->
	    %% 95 terminal rensei c etant inconnu
	    pbutil:sprintf("ORAINFdterm %s;95",[MSISDN]);
 	$+ ->
 	    %% 96 terminal ss capacite MMS
 	    pbutil:sprintf("ORAINFdterm %s;96;NONMMS;1;0",[MSISDN]);
	$7 ->
	    %% 91 non compatible MMS VDO
	    pbutil:sprintf("ORAINFdterm %s;90;123456;1;0",[MSISDN]);
	$8 ->
	    %% 91 non compatible MMS
	    pbutil:sprintf("ORAINFdterm %s;90;123456;0;1",[MSISDN]);
	$9 ->
	    %% 99 Service Indisponible
	    pbutil:sprintf("ORAINFdterm %s;99;UNKNOWN;0;0",[MSISDN]);
	_ ->
	    %% OK terminal MMS and MMS VIDEO
	    pbutil:sprintf("ORAINFdterm %s;90;MMS_V_OK;1;1",[MSISDN])
    end;
request(("ORAINFterm "++Data)=Req) ->
    [MSISDN,TAC] = string:tokens(Data,";"),
    case lists:last(MSISDN) of
	$8 ->
	    %% 91 non compatible profile
	    pbutil:sprintf("ORAINFterm %s;91",[MSISDN]);
	$9->
	    %% 99 Service indisponible
	    pbutil:sprintf("ORAINFterm %s;99",[MSISDN]);
	_->
	    %% OK terminal MMS
	    pbutil:sprintf("ORAINFterm %s;90",[MSISDN])
    end;
request(("ORAINFmodterm "++Data)=Req) ->
    [MSISDN,TAC] = string:tokens(Data,";"),
    case lists:last(MSISDN) of
	$7 ->
	    %% 91 non compatible MMS VDO
	    pbutil:sprintf("ORAINFmodterm %s;90;1;0",[MSISDN]);
	$8 ->
	    %% 91 non compatible MMS
	    pbutil:sprintf("ORAINFmodterm %s;90;0;1",[MSISDN]);
	$9->
	    %% 99 Service indisponible
	    pbutil:sprintf("ORAINFmodterm %s;99",[MSISDN]);
	_->
	    %% OK terminal MMS
	    pbutil:sprintf("ORAINFmodterm %s;90;1;1",[MSISDN])

    end;
request(("ORAINFFiltreClient "++Data)=Req) ->
    [MSISDN] = string:tokens(Data,";"),
    case lists:last(MSISDN) of
	$2->
	    %% Blockage total
	    pbutil:sprintf("ORAINFFiltreClient %s;90;%d",[MSISDN,0]);
	$3->
	    %% 99 Service indisponible
	    pbutil:sprintf("ORAINFFiltreClient %s;99",[MSISDN]);
	$4->
	     {B_Type,List} = {1,[?meteo,?humour]},
	    pbutil:sprintf("ORAINFFiltreClient %s;90;%d;%s",[MSISDN,B_Type,
							    format_list(List)]);
	_->
	    %% Aucun filtrage actif
	    {B_Type,List} = {1,[]},
	    pbutil:sprintf("ORAINFFiltreClient %s;91",[MSISDN])
    end;
request(("ORAINFresSVI "++Data)=Req) ->
    io:format("Req:~p~n",[Data]),
    [MSISDN,ID,_,Fact,Media] = string:tokens(Data,";"),
    pbutil:sprintf("ORAINFresSVI %s;90",[MSISDN]).


init_test()->
    case ets:info(smsinfos,name) of
	smsinfos->
	    ok;
	_->
	    ets:new(smsinfos,[set,public,named_table])
    end,
    ets:insert(smsinfos,{"208010900000001","A",[20006,30010,30005]}),
    ets:insert(smsinfos,{"208010901000001","M",[20006]}),
    ets:insert(smsinfos,{"208010902000001","T",[]}).

info(ID)->
    case ets:lookup(smsinfos,ID) of
	[{ID,Fact,Liste}]->
	    {ID,Fact,Liste};
	_->
	    io:format("Default ID:~p~n",[ID]),
	    {ID,"T",[]}
    end.


format_list([])-> " ";
format_list(L)->
    format_list(L,[]).

format_list([],Acc)-> Acc;
format_list([H|T],Acc)-> format_list(T,integer_to_list(H)++" "++Acc).	 
    
format_list_fact([])-> " ";
format_list_fact(L)->
    format_list_fact(L,[]).

format_list_fact([],Acc)-> Acc;
format_list_fact([{H,F}|T],Acc)-> format_list_fact(T,integer_to_list(H)++" "++F++" "++Acc);	 
format_list_fact([H|T],Acc) -> format_list_fact(T,integer_to_list(H)++" "++"A "++Acc).

tokens([],_,Acc)->
    Acc;
tokens(Args,Char,Acc)->
    case pbutil:split_at(Char,Args) of
	{Arg,Rest}->
	    tokens(Rest,Char,Acc++[Arg]);
	E->
	    Acc++[Args]
    end.
