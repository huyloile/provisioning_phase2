%% Simulation (très approximative) du SDP Sachem CMO.
%% Référence : "Spécifications de l'interface de l'application Sachem",
%% Prosodie, 1.2, 14/09/2001.
%% Behaves like a port process with an additional connection
%% establishment phase.

-module(sachem_cmo_fake).
-export([run/0, run_reliable/0,get_test_subscription/1]).
-export([start/0, start_reliable/0]).
-export([request/1,generation_dossier/3,generation_dossier/4,
	 generation_compte/1,get_info/1,make_a4_resp/2]).

-export([random_ext/0,debug/1,xdebug/2,make_imsi/1,make_msisdn/1,xdebug/1]).
-include("../../../../lib/pservices_orangef/include/ftmtlv.hrl").
-define(BANNER, "FTMREADY01").
%% ETAT COMPTE
-define(AC,1).
-define(EP,2).
-define(PE,3).
-define(DEFAULT_OPT_LIST,
	[{etat_princ,?ETAT_AC},
	 {etats_sec,?SETAT_ID},
	 {option,0},
	 {d_activ,pbutil:unixtime()},
	 {dlv,pbutil:unixtime()},
	 {d_der_rec,pbutil:unixtime()},
	 {langue,?FRANCAIS},
	 {malin,"-"},
	 {tribu,"-"},
	 {acces,0},
	 {dtmn,0}]).

start() -> proc_lib:start(?MODULE, run, []).
start_reliable() -> proc_lib:start(?MODULE, run_reliable, []).
     
run() ->
    global:register_name(sachem_cmo_fake, self()),
    io:format("registered ~p~n", [global:whereis_name(sachem_cmo_fake)]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 100),
    init_compte(),
    available().

run_reliable() ->
    global:register_name(sachem_cmo_fake, self()),
    io:format("registered ~p~n", [global:whereis_name(sachem_cmo_fake)]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 50),
    init_compte(),
    available().

available() ->
    receive
	{Client, connect} ->
	    link(Client),
	    Client ! {self(), connected},
	    io:format("~p connected~n", [Client]),
	    send_line(Client, ?BANNER),
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
	    available();
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
		    xdebug("~p < \"~s\"~n", [Client, Reply]),
		    %% Flatten and send the reply
		    send_line(Client, lists:flatten(Reply)),
		    connected(Client)
	    end;
	{Client, close} ->
	    unlink(Client),
	    Client ! {self(), closed},
	    debug("~p disconnected~n", [Client]),
	    available();
	M -> pbutil:badmsg(M, ?MODULE)
    end.

%%%% Sends an ascii line, simulating the behaviour of a port process.

send_line(Client, Line) ->
    Client ! {self(), {data,{eol,Line}}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% "B" requests (taxation).
request(("B "++_)=Req) ->
    {[MSISDN, Dta, V1, V21, V22, Num, N1, N2], ""} =
	pbutil:sscanf("B %d %x %d %d %d %19s %d %d", Req),
    case random:uniform(get(random_range)) of
	X when X>90 ->
	    pbutil:sprintf("B%d 99",[MSISDN]);
	_ ->
	    pbutil:sprintf("B%d 00",[MSISDN])
    end;

%%%% "D" requests (reload).

request(("D "++_)=Req) ->
    sachem_fake:request(Req);

request(("D4 "++_)=Req) ->
    {[MSISDN, CG, DTA, CX], ""} = pbutil:sscanf("D4 %s %s %x %d", Req),
    L=lists:nthtail(12,CG),
    case do_rech_D4(L,CX) of
	{TTK_V,CTK_N,Zones60} ->
	    DOS_DATE_LV=pbutil:unixtime() + random:uniform(3600*24*60),
	    pbutil:sprintf("D4%s 00 %d %d %x ",[MSISDN,TTK_V,CTK_N,DOS_DATE_LV])++Zones60;
	{STATUS, ERREUR} ->
	    pbutil:sprintf("D4%s %d %d",[MSISDN,STATUS,ERREUR]);
	{STATUS} ->
	    pbutil:sprintf("D4%s %d",[MSISDN,STATUS])
    end;
request(("D5 "++_)=Req) ->
    {[MSISDN, CG, DTA, CX, CL], ""} = pbutil:sscanf("D5 %s %s %x %d %d", Req),
    L=lists:nthtail(12,CG),
    case do_rech_D4(L,CX) of
	{TTK_V,CTK_N,Zones60} ->
	    DOS_DATE_LV=pbutil:unixtime() + random:uniform(3600*24*60),
	    pbutil:sprintf("D5%s 00 %d %d %x ",[MSISDN,TTK_V,CTK_N,DOS_DATE_LV])++Zones60;
	{STATUS, ERREUR} ->
	    pbutil:sprintf("D5%s %d %d",[MSISDN,STATUS,ERREUR]);
	{STATUS} ->
	    pbutil:sprintf("D5%s %d",[MSISDN,STATUS])
    end;
request(("D6 "++_)=Req) ->
    %%D6 MSISDN TICKET DATE CHOIX CANAL_NUM
    slog:event(trace, ?MODULE, d6_request, Req),
    {[MSISDN, CG, DTA, CX, CL], ""} = pbutil:sscanf("D6 %s %s %x %d %d", Req),
    L=lists:nthtail(12,CG),
    case do_rech_D4(L,CX) of
	{TTK_V, CTK_N, Zones60} ->
	    DOS_DATE_LV=pbutil:unixtime() + random:uniform(3600*24*60),
	    TTK_NUM = sachem_fake:type_ticket_rech(L),
	    pbutil:sprintf("D6%s 00 %d %d %d %x ",[MSISDN,TTK_V,CTK_N,TTK_NUM,DOS_DATE_LV])++Zones60;
	{STATUS, ERREUR} ->
	    pbutil:sprintf("D6%s %d %d",[MSISDN,STATUS,ERREUR]);
	{STATUS} ->
	    pbutil:sprintf("D6%s %d",[MSISDN,STATUS]);
	Else ->
	    slog:event(internal, ?MODULE, unexpected_do_rech_D4, Else),
	    Else    
    end;
%%%%%%% A3 request : consultation de Compte Mobicarte Et CMO
request(("A4 "++_)=Req) ->
    {[Critere, ID], ""} = pbutil:sscanf("A4 %d %s", Req),
    make_a4_resp(ID);

request(Req) ->
    sachem_fake:request(Req).

make_imsi("9"++T) -> "999000"++T;
make_imsi(MSISDN) -> "20801"++MSISDN.

%%%%%%%%%%%%%%%%%%%%%%%% CONSULTATION REQUEST FUNCTIONS %%%%%%%%%%%%%%%%%%% 
get_test_subscription(ID)->
    case rpc:call(possum@localhost, ets, lookup, [sub,ID]) of
	[{ID,SUB}]->
	    SUB;
	_->
	    undefined
    end.

make_msisdn("999"++[_,_,_|T]) -> "9"++T;
make_msisdn("20801"++[A,B|ID]) -> "06"++ID;
make_msisdn("20801"++ID) -> ID;
make_msisdn(IMSI) -> "0612345678".

make_a4_resp(IMSI) ->
    make_a4_resp(IMSI,cmo).

make_a4_resp(IMSI,Sachem_type) ->
    MSISDN=make_msisdn(IMSI),
    case get_info(IMSI) of
	no_compte ->
	    Subscription = case get_test_subscription(IMSI) of
			       undefined -> "";
			       Else -> list_to_atom(Else)
			   end,
	    case lists:member(Subscription,sachem_subscriptions(Sachem_type)) of
		true ->
		    "A4"++pbutil:sprintf("%s %02d ",[MSISDN,0])++
			generation_dossier(IMSI,dcl_num(Subscription),0)++
			generation_compte(default_comptes(Subscription));
		false ->
		    pbutil:sprintf("A4"++"%s 10", [IMSI])
		end;
	{DCL,OPT,Comptes} ->
	    "A4"++pbutil:sprintf("%s %02d ",[MSISDN,0])++
		generation_dossier(IMSI,DCL,OPT)++
		generation_compte(Comptes);
	{{DCL,OPT,Comptes},Opts}->
	    "A4"++pbutil:sprintf("%s %02d ",[MSISDN,0])++
		generation_dossier(IMSI,DCL,OPT,Opts)++
		generation_compte(Comptes)
    end.

sachem_subscriptions(mobi) ->
    [monacell_prepaid,carrefour_prepaid,virgin_prepaid,tele2_pp,omer,mobi,nrj_prepaid];
sachem_subscriptions(cmo) ->
    [cmo,bzh_cmo,monacell_comptebloqu,virgin_comptebloque,tele2_comptebloque,ten_comptebloque,nrj_comptebloque,carrefour_comptebloq].

ptf_num(carrefour_prepaid)-> ?PTFNUM_VIRGIN_PREPAID;
ptf_num(monacell_prepaid)-> ?PTF3_MONACELL_PP;
ptf_num(virgin_prepaid) -> ?PTFNUM_VIRGIN_PREPAID;
ptf_num(nrj_prepaid) -> ?PTF_NEPTUNE_PP;
ptf_num(tele2_pp) -> ?PTELE2_PP;
ptf_num(omer) -> 46;
ptf_num(mobi) -> ?PCLAS_V2;
ptf_num(cmo) -> 113;
ptf_num(bzh_cmo) -> 129;
ptf_num(virgin_comptebloque) -> 113;
ptf_num(tele2_comptebloque) -> ?PTF_TELE2_CB_PP;
ptf_num(ten_comptebloque) -> ?PTF_TEN_CB_PP ;
ptf_num(carrefour_comptebloq) -> ?PTF_CARREFOUR_CB1;
ptf_num(nrj_comptebloque)-> ?PTF_NEPTUNE_CB_PP.

dcl_num(carrefour_prepaid)-> ?DCLNUM_CARREFOUR_PREPAID;
dcl_num(monacell_prepaid)-> ?DCLNUM_MONACELL_PREPAID;
dcl_num(virgin_prepaid) -> ?DCLNUM_VIRGIN_PREPAID;
dcl_num(nrj_prepaid) -> ?nrj_pp;
dcl_num(tele2_pp) -> ?tele2_pp;
dcl_num(omer) -> ?omer;
dcl_num(mobi) -> ?mobi;
dcl_num(cmo) -> ?ppola;
dcl_num(bzh_cmo) -> ?bzh_cmo;
dcl_num(virgin_comptebloque) -> ?DCLNUM_VIRGIN_COMPTEBLOQUE1;
dcl_num(tele2_comptebloque) -> ?tele2_cb;
dcl_num(nrj_comptebloque) ->?nrj_cb;
dcl_num(carrefour_comptebloq) ->?DCLNUM_CARREFOUR_CB1;
dcl_num(ten_comptebloque) ->?ten_cb.
      
generation_dossier(IMSI,DCL,OPT)->
    generation_dossier(IMSI,DCL,OPT,[]).
generation_dossier(IMSI,DCL,OPT,Opts)->
    pbutil:sprintf("40 %d;%d;%d;%d;%d;%x;%x;%d;%d;%s;%s;%x;%x",
		   [123456,DCL] ++
		    build_opt_list(
		      [{option,OPT}]++Opts,
		      ?DEFAULT_OPT_LIST)).

default_comptes(Subscription)->
    Comptes_list = [#compte{tcp_num=?C_PRINC,
				unt_num=?EURO,
				cpp_solde=1000,%10000 si sachem_cmo ?
				dlv=pbutil:unixtime(),
				rnv=0,
				etat=?AC,
				ptf_num=ptf_num(Subscription)}],

    case Subscription of
	mobi ->
	    Comptes_list ++
		[#compte{tcp_num=?C_RDL_WAP,unt_num=?EURO,cpp_solde=1000,
			 dlv=pbutil:unixtime(),rnv=0,etat=?AC,ptf_num=?PCLAS_V2},
		 #compte{tcp_num=?P_WAP,unt_num=?EURO,cpp_solde=1000,
			 dlv=pbutil:unixtime(),rnv=0,etat=?AC,ptf_num=?PCLAS_V2}];
	bzh_cmo ->
	    Comptes_list ++ 
		[#compte{tcp_num=?C_FORF_BZH,unt_num=?EURO,cpp_solde=10000,
			 dlv=0,rnv=12,etat=?AC,ptf_num=?PBZH_CMO_MIN}];
	Else ->
	    Comptes_list
    end.

generation_compte(Comptes)->
    lists:foldl(fun(#compte{}=CPT,Acc)-> Acc++print_compte(CPT) end,
		"",Comptes).

print_compte(#compte{tcp_num=TCP,unt_num=UN,
		     cpp_solde=CPP,dlv=DLV,
		     rnv=RNV,etat=ET,ptf_num=PTF,cpp_cumul_credit=CCC,pct=PCT,anciennete=AN})->
    " "++pbutil:sprintf("50 %d;%d;%d;%x;%d;%d;%d;%d;%d;%d",
		   [TCP,UN,CPP,DLV,RNV,ET,PTF,print(CCC),print(PCT),print(AN)]).


print(undefined)->
    0;
print(X) ->
    X.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

random_ext() ->
    case random:uniform(4) of
	1 -> {$0, "-", "-"};
	2 -> {$1, io_lib:format("~w", random:uniform(1000000000)), "-"};
	3 -> {$1, "-", io_lib:format("~w", random:uniform(1000000000))};
	4 -> {$1, io_lib:format("~w", random:uniform(1000000000)),
	      io_lib:format("~w", random:uniform(1000000000))}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debug(_) -> ok.
debug(_, _) -> ok.

xdebug(Format) ->
    debug(Format, []).
xdebug(Format, Args) ->
    io:format("~p: "++Format, [?MODULE | Args]),
    ok.


init_compte()->
    case ets:info(sdp_compte,name) of
	sdp_compte->
	    ok;
	_->
	    ets:new(sdp_compte,[set,public,named_table])
    end.

get_info(ID)->
    case ets:lookup(sdp_compte,ID) of
	[{ID, INFO}]->
	    io:format("info:~p~n",[INFO]),
	    INFO;
	Result ->
	    io:format("no_compte :~p~p~n",[ID,Result]),
	    no_compte
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  RECHARGEMENT SIMULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% PASSAGE A D4
do_rech_D4("33",3) ->
    %% 7 Euros SL Rechgt Messages ilLimitee
    {7000,2,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$5,$1],_)->
    %% 10 Euros Rechgt Breizh
    {10000,2,make_z60(?C_PRINC,?AC,10000)};
do_rech_D4([$5,$2],_)->
    %% 5 Euros Rechgt Breizh
    {5000,2,make_z60(?C_PRINC,?AC,5000)};
do_rech_D4([$0,$1],_)->
    %% 70 FF
    {10854,?REC_STANDARD,make_z60(?C_PRINC,?AC,10854)};
do_rech_D4([$0,$2],_) ->
    %% 140 F
    {21709,?REC_STANDARD,make_z60(?C_PRINC,?AC,21709)++make_z60(?C_ASMS,?AC,5000)};
do_rech_D4([$0,$3],_) ->
    %% 15 Euros
    {15000,?REC_STANDARD,make_z60(?C_ASMS,?AC,15000)};
do_rech_D4([$0,$4],_) ->
    %% 10 Euros WE infini
    {10000,?RECHARGE_WEINF,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$5],_) ->
    %% 10 Euros Europe
     {10000,?RECHARGE_EUROPE,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$6],_) ->
    %% 10 Euros Maghreb
    {10000,?RECHARGE_MAGHREB,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$7],_) ->
    %% 10 Euros erech SMS/MMS
    {5000,?RECHARGE_SMSMMS,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$8],_) ->
    %% 10 Euros WE infini
    {10000,?RECHARGE_WEINF,make_z60(?C_PRINC,?AC,15000)++
	make_z60(?C_ESP_VOIX,?AC,5000)};
do_rech_D4([$0,$9],_) ->
    %% 15 Euros erech SL
    {5000,?RECHARGE_SL,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$1,$5],_) ->
    % 24 Euros Rechgt Carrefour Z1
    {24000,?CTK_CARREFOUR_Z1,[make_z60(?C_PRINC,?AC,24000),make_z60(?C_CARREFOUR_Z1,?AC,24000,?PTF_CARREFOUR_Z1)]};
do_rech_D4([$1,$6],_) ->
    % 24 Euros Rechgt Carrefour Z2
    {24000,?CTK_CARREFOUR_Z2,[make_z60(?C_PRINC,?AC,24000),make_z60(?C_CARREFOUR_Z2,?AC,26500,?PTF_CARREFOUR_Z1)]};
do_rech_D4([$1,$7],_) ->
    % 24 Euros Rechgt Carrefour Z3
    {36000,?CTK_CARREFOUR_Z3,[make_z60(?C_PRINC,?AC,24000),make_z60(?C_CARREFOUR_Z3,?AC,39500,?PTF_CARREFOUR_Z1)]};
do_rech_D4([$1,$8],_) ->
    % Erreur technique 99
    {99};
do_rech_D4([$1,$9],_) ->
    % TR déjà utilisée 10 5 
    {10,5};
do_rech_D4([$2,$0],_) ->
    % TR Erreur non déterminée 10 
    {10};
do_rech_D4([$5,$0],_) ->
    % TR Erreur incompatible with client's offer 
    {99,3};
do_rech_D4([$2,$1],_) ->
    % 20 Euros Rechgt Special Vacances
    {36000,?RECHARGE_VACANCES,[make_z60(?C_PRINC,?AC,24000),make_z60(?C_ROAMING_IN,?AC,20000,?PTF_ROAMING_IN),make_z60(?C_ROAMING_OUT,?AC,15000,?PTF_ROAMING_OUT)]};
do_rech_D4([$2,$2],_) ->
    % Erreur technique 99
    {98};
do_rech_D4([$3,Error],_) ->
    % TR erreur 10 X
    Code = list_to_integer([Error]),
    {10,Code};
do_rech_D4([$2,$6],_) ->
    %% 20 Euros SL Rechgt Messages ilLimitee
    {20000,2,make_z60(?C_RECH_ROAMING_TELE2,?AC,21000)};
do_rech_D4([$2,$7],_) ->
    %% 20 Euros Rechgt SMS ilLimites
    {20000,2,make_z60(?C_RECH_SMS_ILLM,?AC,21000)};
do_rech_D4([$5,$5],_) ->
    %% 20 Euros Rechgt SMS ilLimites
    {20000,?RECHARGE_20E_SL, make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$5,$4],_) ->
    %% 20 Euros Rechgt ilLimites
    {20000,?RECHARGE_20E_SL, make_z60(?C_PRINC,?AC,20000)};
do_rech_D4(_,_) ->
    {15000,1,make_z60(?C_PRINC,?AC,15000)}.

make_z60(TCP_NUM,ECP,CPP_SOLDE,PTF_NUM) ->
    sachem_fake:make_z60(TCP_NUM,ECP,CPP_SOLDE,PTF_NUM).

make_z60(TCP_NUM,ECP,CPP_SOLDE) ->
    sachem_fake:make_z60(TCP_NUM,ECP,CPP_SOLDE).


build_opt_list(Opts,DefOpts) ->
    build_opt_list(Opts,DefOpts,[]).

build_opt_list(_,[],Acc) ->
    lists:reverse(Acc);
build_opt_list([],[{T,V}|Tail],Acc) ->
    build_opt_list([],Tail,[V|Acc]);
build_opt_list(Opts,[{T,V}|Tail],Acc) ->
    Value = case catch lists:keysearch(T,1,Opts) of
		{value,{_,Val}} ->
		    Val;
		Else ->
		    V
	    end,
    build_opt_list(Opts,Tail,[Value|Acc]).

    
