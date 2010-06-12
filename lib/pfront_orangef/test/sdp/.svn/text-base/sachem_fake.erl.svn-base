%% Simulation (très approximative) de l'interface Sachem MUSS.
%% Behaves like a port process with an additional connection
%% establishment phase.

-module(sachem_fake).
-export([run/0, run_reliable/0]).
-export([start/0, start_reliable/0]).
-export([request/1]).
-export([make_a4_resp/1]).
-export([debug/2,xdebug/2]).
-export([debug/2,xdebug/2]).
-export([make_z60/4,make_z60/3]).
-export([type_ticket_rech/1]).

-export([update_z80/1]).
-import(sachem_cmo_fake,[get_info/1]).
    
-define(BANNER, "FTMREADY01").
%% COMPTE
-define(FORF,6).
-define(WAP,3).
-define(SMS_PROMO,17).
%% ETAT COMPTE
-define(AC,1).
-define(EP,2).
-define(PE,3).
-include("../../../../lib/pservices_orangef/include/ftmtlv.hrl").
start() -> proc_lib:start(?MODULE, run, []).

start_reliable() -> proc_lib:start(?MODULE, run_reliable, []).
     
run() ->
    global:register_name(sachem_fake, self()),
    io:format("registered ~p~n", [global:whereis_name(sachem_fake)]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 100),
    subscription_init(),
    available().

run_reliable() ->
    global:register_name(sachem_fake, self()),
    io:format("registered ~p~n", [global:whereis_name(sachem_fake)]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true),
    random:seed(),
    put(random_range, 50),
    subscription_init(),
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
    io:format("SACHEM_FAKE answer: ~p ~n~n",[Line]),
    Client ! {self(), {data,{eol,Line}}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% "B" requests (taxation).
request(("B "++_)=Req) ->
    io:format("Request B appel....~n"),
    {[MSISDN, DATE, Duree, Cratio, Crtc, Num, N1, Montant], ""} =
	pbutil:sscanf("B %s %x %d %d %d %19s %d %d", Req),
    case random:uniform(get(random_range)) of
	X when X>90 ->
	    pbutil:sprintf("B%s 99",[MSISDN]);
	_ ->
	    pbutil:sprintf("B%s 00",[MSISDN])
    end;

%%%% "D" requests (reload).

request(("D "++_)=Req) ->
    {[MSISDN, CG, DTA], ""} = pbutil:sscanf("D %s %s %x", Req),
    case random:uniform(get(random_range)) of
	X when X>98 -> pbutil:sprintf("D%s 10 1", [MSISDN]);
	X when X>96 -> pbutil:sprintf("D%s 10 2", [MSISDN]);
	X when X>94 -> pbutil:sprintf("D%s 10 3", [MSISDN]);
	X when X>92 -> pbutil:sprintf("D%s 10 4", [MSISDN]);
	X when X>90 -> pbutil:sprintf("D%s 10 5", [MSISDN]);
	X when X>88 -> pbutil:sprintf("D%s 10 6", [MSISDN]);
	X when X>86 -> pbutil:sprintf("D%s 10 7", [MSISDN]);
	X when X>84 -> pbutil:sprintf("D%s 10 8", [MSISDN]);
	X when X>82 -> pbutil:sprintf("D%s 10 9", [MSISDN]);
	X when X>80 -> pbutil:sprintf("D%s 99 4", [MSISDN]);
	X when X>78 -> pbutil:sprintf("D%s 99 3", [MSISDN]);
	X when X>76 -> pbutil:sprintf("D%s 99 2", [MSISDN]);
	X when X>74 -> pbutil:sprintf("D%s 99 1", [MSISDN]);
	X when X>72 -> pbutil:sprintf("D%s 99 0", [MSISDN]);
	_ ->
	    L=lists:nthtail(12,CG),
	    {ValF,Tvalid,S2,Trec}={10854,31,15854,1},
	    Statut = 0,
	    Canal = "MOBI",
	    Part = 39,
	    Type = 16,
	    Valid = 30,
	    %% Simuler cartes valides et périmées.
	    DTL = pbutil:unixtime() + random:uniform(3600*24*60)-50,
	    S1 = 0,
	    %S2 = 4000,
	    Etat = 16#00000021,
	    DTU = DTL - random:uniform(3600*24*60),
	    ValD = "0",
	    %ValF = 15000,
	    %Tvalid = 60,
	    %Trec = 1,
	    pbutil:sprintf(
	      "D%s %02d %4s %d %d %d %x %d %d %d %s %d %d %d",
	      [MSISDN, Statut, Canal, Part, Type, Valid,
	       DTL, S1, S2, Etat, ValD, ValF, Tvalid, Trec])
    end;
request(("D4 "++_)=Req) ->
    {[MSISDN, CG, DTA, CX], ""} = pbutil:sscanf("D4 %s %s %x %d", Req),
    L=lists:nthtail(12,CG),
    {TTK_V,CTK_N,Zones60}=do_rech_D4(L,CX),
    DOS_DATE_LV=pbutil:unixtime() + random:uniform(3600*24*60),
    pbutil:sprintf("D4%s 00 %d %d %x ",
		   [MSISDN,TTK_V,CTK_N,DOS_DATE_LV])++Zones60;

request(("D5 "++_)=Req) ->
    {[MSISDN, CG, DTA, CX, CL], ""} = pbutil:sscanf("D5 %s %s %x %s %d", Req),
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
	    slog:event(trace, ?MODULE, d4_request, {TTK_V, CTK_N, Zones60}),
	    DOS_DATE_LV=pbutil:unixtime() + random:uniform(3600*24*60),
	    TTK_NUM = type_ticket_rech(L),
	    pbutil:sprintf("D6%s 00 %d %d %d %x ",[MSISDN,TTK_V,CTK_N,TTK_NUM,DOS_DATE_LV])++Zones60;
	{STATUS, ERREUR} ->
	    pbutil:sprintf("D6%s %d %d",[MSISDN,STATUS,ERREUR]);
	{STATUS} ->
	    pbutil:sprintf("D6%s %d",[MSISDN,STATUS]);
	Else ->
	    slog:event(internal, ?MODULE, unexpected_do_rech_D4, Else),
	    Else    
    end;

%%%% "G2" requests (plan tarifaire change).
request(("G2 "++_)=Req) ->
    %% We don't bother handling currency.....
    {[MSISDN, PT, Cout, DTA,Cu,TCP,CTRL], Rest} = 
	pbutil:sscanf("G2 %s %d %d %x %d %d %d", Req),
    case MSISDN of
	"99"++[_,_,_,_,_,_,_,$2]-> pbutil:sprintf("G2%s 10 1", [MSISDN]);
	_ ->
	    pbutil:sprintf("G2%s 00",[MSISDN])
    end;

%%%% "G" requests (plan tarifaire change).
request(("G "++_)=Req) ->
    %% We don't bother handling currency.....
    {[MSISDN, PT, Cout, DTA,Cu], Rest} = 
	pbutil:sscanf("G %s %d %d %x %d", Req),
    case random:uniform(get(random_range)) of
	X when X>90 -> pbutil:sprintf("G%s 10 1", [MSISDN]);
	X when X>80 -> pbutil:sprintf("G%s 10 2", [MSISDN]);
	X when X>70 -> pbutil:sprintf("G%s 10 3", [MSISDN]);
	_ ->
	    pbutil:sprintf("G%s 00",[MSISDN])
    end;


%%%% "H" requests (acces a la reco vocale change).
request(("H "++_)=Req) ->
    {[MSISDN, Option,DTA], ""} = pbutil:sscanf("H %10d %d %x", Req),
    case random:uniform(get(random_range)) of
	X when X>90 -> pbutil:sprintf("H%s 10", [MSISDN]);
	X when X>80 -> pbutil:sprintf("H%s 98", [MSISDN]);
	X when X>70 -> pbutil:sprintf("H%s 99", [MSISDN]);
	_ ->
	    pbutil:sprintf("H%10d 00",[MSISDN])
    end;

%%%% "I" requests (e-care access code change).
request(("I "++_)=Req) ->
    {[MSISDN, Type, Code], ""} = pbutil:sscanf("I %s %c %4d", Req),
    case random:uniform(get(random_range)) of
	X when X>90 -> pbutil:sprintf("I%s 10", [MSISDN]);
	X when X>80 -> pbutil:sprintf("I%s 98", [MSISDN]);
	X when X>70 -> pbutil:sprintf("I%s 99", [MSISDN]);
	_ ->
	    pbutil:sprintf("I%s 00",[MSISDN])
    end;

%%%% "J" requests (e-care access code change).
request(("J "++_)=Req) ->
    {[MSISDN, Type, Code], ""} = pbutil:sscanf("J %s %c %4d", Req),
    case random:uniform(get(random_range)) of
	X when X>95 -> pbutil:sprintf("J%s 10 1", [MSISDN]);
	X when X>90 -> pbutil:sprintf("J%s 10 2", [MSISDN]);
	X when X>85 -> pbutil:sprintf("J%s 10 3", [MSISDN]);
	X when X>80 -> pbutil:sprintf("J%s 10 4", [MSISDN]);
	X when X>75 -> pbutil:sprintf("J%s 10 5", [MSISDN]);
	_ ->
	    pbutil:sprintf("J%s 00",[MSISDN])
    end;
%%%% "ACCESGPRS" requests (OSL active request).
request(("ACCESGPRS "++_)=Req) ->
    {[MSISDN], ""} = pbutil:sscanf("ACCESGPRS %s", Req),
    case MSISDN of
	"99"++[_,_,_,_,_,_,_,$2]-> pbutil:sprintf("ACCESGPRS%s 10", [MSISDN]);
	"99"++[_,_,_,_,_,_,_,$3] -> pbutil:sprintf("ACCESGPRS%s 90", [MSISDN]);
	_ ->
	    pbutil:sprintf("ACCESGPRS%s 00",[MSISDN])
    end;
%%%% "MNS2" requests (Active SMS infos Rubrique).
request(("MNS2 "++_)=Req) ->
    {[MSISDN,Rub,Price,Devise], ""} = pbutil:sscanf("MNS2 %s %d %d %s", Req),
    {Y,M,D}=date(),
    case MSISDN of
	"99"++[_,_,_,_,_,_,_,$2]-> pbutil:sprintf("MNS2%s 10", [MSISDN]);
	"99"++[_,_,_,_,_,_,_,$3] -> pbutil:sprintf("MNS2%s 91", [MSISDN]);
	"99"++[_,_,_,_,_,_,_,$4] -> pbutil:sprintf("MNS2%s 92", [MSISDN]);
	"99"++[_,_,_,_,_,_,_,$5] -> pbutil:sprintf("MNS2%s 99", [MSISDN]);
	"99"++[_,_,_,_,_,_,_,$6] -> pbutil:sprintf("MNS2%s 11", [MSISDN]);
	_ ->
	    pbutil:sprintf("MNS2%s 00 %d %d %x %d",
			   [MSISDN,Rub,10000,pbutil:unixtime(),1])
    end;

%%%%%% A3 request : consultation de Compte Mobicarte Et CMO
request(("A4 "++_)=Req) ->
    {[Critere, IMSI], ""} = pbutil:sscanf("A4 %d %s", Req),
    io:format("SACHEM_FAKE request ~p~n", [Req]),
    make_a4_resp(IMSI);


%%% REQUESTE DE PRICE D'OPTIONS
request(("OPT_CPT "++_)=Req) ->
    io:format("SACHEM_FAKE request :~p ~n",[Req]),
    L = string:tokens(Req," "),
    [Request,Msisdn,Action,TOP_NUM,_,_,FIN,H_F,TOP_COUT,TCP_NUM,
       PTF,_,_,MNT_INIT,RNV_NUM,_,_,_,_,_]=L,
    case lists:last(Msisdn) of
	$7->
	    %% option blocked, return code 101
	    "OPT_CPT"++Msisdn++" 101";
	$8->
	    %% opt deja active
	    "OPT_CPT"++Msisdn++" 96";
	$9->
	    %% solde insuffisant
	    "OPT_CPT"++Msisdn++" 95";
	_->
	    %%ok_operation_effectuee
	    "OPT_CPT"++Msisdn++" 0"
    end;


%%% REQUEST NOP_CPT
request(("NOPT_CPT "++_)=Req) ->
    io:format("SACHEM_FAKE request :~p ~n",[Req]),
    L = string:tokens(Req," "),
    [Request,Msisdn,Action,NB_OPTION,_]=L,
    CPP_SOLDE="50",
    TCP_NUM="1",
    TOP_NUM="100",
    case lists:last(Msisdn) of

	$5->
	    %% option dependente du doosier non presente
	    "NOPT_CPT"++Msisdn++" 105 "++TCP_NUM++" "++CPP_SOLDE++" "++TOP_NUM;
	$6->
	    %% option deja existante
	    "NOPT_CPT"++Msisdn++" 93 "++TCP_NUM++" "++CPP_SOLDE++" "++TOP_NUM;
	$7->
	    %% option incompatible, return code 101
	    "NOPT_CPT"++Msisdn++" 101 "++TCP_NUM++" "++CPP_SOLDE++" "++TOP_NUM;
	$8->
	    %% opt incompatible
	    "NOPT_CPT"++Msisdn++" 96 "++TCP_NUM++" "++CPP_SOLDE++" "++TOP_NUM;
	$9->
	    %% solde insuffisant
	    "NOPT_CPT"++Msisdn++" 95 "++TCP_NUM++" "++CPP_SOLDE++" "++TOP_NUM;
	_->
	    %%ok_operation_effectuee
	    "NOPT_CPT"++Msisdn++" 0 "++TCP_NUM++" "++CPP_SOLDE++" 0"
    end;


%%% REQUESTE DE PRICE D'OPTIONS
request(("OPT_CPT2 "++_)=Req) ->
    io:format("SACHEM_FAKE request :~p ~n",[Req]),
    L = string:tokens(Req," "),
    io:fwrite("sachem_fake:request/2:L=~p~n",[L]),
    [Request,Msisdn,Action,TOP_NUM,_,_,FIN,H_F,TOP_COUT,TCP_NUM,
     PTF,MNT_INIT,RNV_NUM|Tail]=L,
    %%%% We are supposed to receive :
    %%     PTF,INFO1,INFO2,MNT_INIT,RNV_NUM,MSISDN_KDO,_,_,_,_,_,_,_|Tail]=L,
    %%%% With new Sachem Tuxedo, it was required to set some 
    %%%% values to "" instead of "0" in sdp.hrl
    %%%% which disturbed the scanning of the token extraction 
    MSISDN_KDO = case Tail of
                     [] -> [];
                     [MSISDN_KDO_1|KDOs] ->
                         MSISDN_KDO_1
                 end,                    
    CPP_SOLDE=solde(TOP_NUM),
    TCP_NUM_DEST=tcp_num_dest(TOP_NUM,TOP_COUT),
    io:format("~p:request/1 --> Line:~p & Msisdn=~p & MSISDN_KDO=~p~n",
              [?MODULE,?LINE,Msisdn,MSISDN_KDO]),
    case MSISDN_KDO of
	"0666666666" ->
	    %% option blocked, return code 101
	    "OPT_CPT2"++Msisdn++" 87 "++TCP_NUM++" "++CPP_SOLDE;
	_ ->
	    case lists:last(Msisdn) of
		$7->
		    %% option blocked, return code 101
		    "OPT_CPT2"++Msisdn++" 101 "++TCP_NUM++" "++CPP_SOLDE;
		$8->
		    %% opt deja active
		    "OPT_CPT2"++Msisdn++" 96 "++TCP_NUM++" "++CPP_SOLDE;
		$9->
		    %% solde insuffisant
		    "OPT_CPT2"++Msisdn++" 95 "++TCP_NUM++" "++CPP_SOLDE;
		$6->
		    %% solde insuffisant
		    "OPT_CPT2"++Msisdn++" 0 "++"1"++" "++CPP_SOLDE;
 		$5->
		    %% opt incompatible
		    "OPT_CPT2"++Msisdn++" 90 "++TCP_NUM++" "++CPP_SOLDE;
		_->
		    %%ok_operation_effectuee
		    "OPT_CPT2"++Msisdn++" 0 "++TCP_NUM_DEST++" "++CPP_SOLDE
	    end
    end;

%% IS OBSOLETE SINCE 19 sept 2008. C_OP2 has replaced it	
request(("C_OP "++_)=Req) ->
    io:format("SACHEM FAKE: C_OP request:~p~n",[Req]),
    [Request,Msisdn,TOP_NUM]=string:tokens(Req," "),
    case {TOP_NUM,lists:last(Msisdn)} of
	{"NULL",_}->
	    case get_info({top_num_list,Msisdn}) of
		TOP_NUMs when list(TOP_NUMs)->
		    %% encode les champs binaire
		    "C_OP"++Msisdn++" 00 "++encode_top(TOP_NUMs,0,31)++" "++
			encode_top(TOP_NUMs,32,64)++" "++
			encode_top(TOP_NUMs,64,96)++" "++
			encode_top(TOP_NUMs,96,128)++" "++
			encode_top(TOP_NUMs,128,160)++" "++
			encode_top(TOP_NUMs,160,192)++" "++
			encode_top(TOP_NUMs,192,224)++" "++
			encode_top(TOP_NUMs,224,236);
		{TOP_NUMs,_,_,_,_,_} when list(TOP_NUMs)->
		    %% encode les champs binaire
		    "C_OP"++Msisdn++" 00 "++encode_top(TOP_NUMs,0,31)++" "++
			encode_top(TOP_NUMs,32,64)++" "++
			encode_top(TOP_NUMs,64,96)++" "++
			encode_top(TOP_NUMs,96,128)++" "++
			encode_top(TOP_NUMs,128,160)++" "++
			encode_top(TOP_NUMs,160,192)++" "++
			encode_top(TOP_NUMs,192,224)++" "++
			encode_top(TOP_NUMs,224,236);
		E->	
		    io:format("Default: ~p~n",[E]),
		    %% aucune option active
		    "C_OP"++Msisdn++" 00 0 0 0 0 0 0 0 0"
	    end;
	{_,$8}->
	    %% opt deja active
	    "C_OP"++Msisdn++" 96";
	{_,$9}->
	    %% solde insuffisant
	    "C_OP"++Msisdn++" 95";
	_->
	    case get_info({top_num_list,Msisdn}) of
		TOP_NUMs when list(TOP_NUMs)->
		    io:format("INFO C_OP:~p  TP? ~p~n",[TOP_NUMs,TOP_NUM]),
		    case lists:member(list_to_integer(TOP_NUM),TOP_NUMs) of
			true->		
			    %% option active
			    Now= pbutil:unixtime(),
			    Day= 24*3600,
			    pbutil:sprintf("C_OP"++Msisdn++" 00 %d %d %d 0 ",[Now-Day,Now,Now+Day]);
			false->
			    %% option inactive
			    "C_OP"++Msisdn++" 97"
		    end;
		{TOP_NUMs,SOUSCR,DEB,FIN,OPT_INFO_1,OPT_INFO_2} when list(TOP_NUMs)->
		    io:format("INFO C_OP:~p  TP? ~p ~p ~n",[TOP_NUMs,TOP_NUM,OPT_INFO_2]),
		    case lists:member(list_to_integer(TOP_NUM),TOP_NUMs) of
			true->		
			    %% option active
			    pbutil:sprintf("C_OP"++Msisdn++" 00 %d %d %d %d %d",
					   [SOUSCR,DEB,FIN,OPT_INFO_1,OPT_INFO_2]);
			false->
			    %% option inactive
			    "C_OP"++Msisdn++" 97"
		    end;
		E ->
		    io:format("no info:~p~n",[E]),
		    "C_OP"++Msisdn++" 97   "
	    end    
    end;
request(("C_OP2 "++_)=Req) ->
    [Request,CRITERIA_TYPE, Msisdn, TOP_NUM]=string:tokens(Req," "),
    %%1. Check account of client Otherwise => Error 10 %% HOW to check this without the IMSI ?
    %% Check the options of the client
	    case get_info({top_num_list,Msisdn}) of
		%% If the client does not have an option, zone 70 is not displayed
		no_compte ->  %% no associated top_num_list
		    "C_OP2" ++ Msisdn ++ " 0 ";	  
		LIST_TOP_NUM_AND_STATE = [{_, _}| _] ->
		    ZONE_70 = lists:foldl(
				fun({TOP_NUM_ELEMENT,STATE},ACC)-> 
					case TOP_NUM of
					    "NULL" ->
						ACC++"70 "++
						    TOP_NUM_ELEMENT++
						    ";2;3;4;five;"++STATE++";7;8;9;10 ";
					    TOP_NUM_ELEMENT ->
						ACC++"70 "++
						    TOP_NUM_ELEMENT++
						    ";2;3;4;five;"++STATE++";7;8;9;10 ";
					    _ -> ACC
					end
				end,
				"",
				LIST_TOP_NUM_AND_STATE),
		    "C_OP2" ++ Msisdn ++ " 0 "++ZONE_70;
		LIST_TOP_NUM = [_ |_ ]->
		    STATE = "-",
		    ZONE_70 = lists:foldl(
				fun(TOP_NUM_ELEMENT,ACC)-> 
					TOP_NUM_ELEMENT_STRING = integer_to_list(TOP_NUM_ELEMENT),
					case TOP_NUM of
					    "NULL" ->
						ACC++"70 "++
						    integer_to_list(TOP_NUM_ELEMENT)++
						    ";2;3;4;five;"++STATE++";7;8;9;10 ";
					    TOP_NUM_ELEMENT_STRING->
						ACC++"70 "++
						    integer_to_list(TOP_NUM_ELEMENT)++
						    ";2;3;4;five;"++STATE++";7;8;9;10 ";
					    _ -> ACC
					end
				end,
				"",
				LIST_TOP_NUM),
		    "C_OP2" ++ Msisdn ++ " 0 "++ZONE_70;
		{TOP_NUMs,Msisdn_kdo,DEB,FIN,_,OPT_INFO_2} when list(TOP_NUMs) ->
		    case OPT_INFO_2 of
			" " -> OPT_INFO = OPT_INFO_2;
			"-" -> OPT_INFO = OPT_INFO_2;
			_   -> OPT_INFO = integer_to_list(OPT_INFO_2)
		    end,
		    Zone_70 = case lists:member(135,TOP_NUMs) of
				  true -> 
				      case TOP_NUM of
					  "135" -> "70 135;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
					       ";five;6;7;8;9;10";
					  "127" -> "70 127;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
					       ";five;"++OPT_INFO++";7;8;9;10";
					  _   -> "70 127;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
					     ";five;"++OPT_INFO++";7;8;9;10" ++
					     " 70 135;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
					     ";five;"++OPT_INFO++";7;8;9;10"
			      end;
				  false -> 
				      case lists:member(166,TOP_NUMs) of
					  true ->
					      case TOP_NUM of
						  "166" -> "70 166;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
							       ";five;"++OPT_INFO++";7;8;9;10";
						  _   -> "70 166;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
							     ";five;"++OPT_INFO++";7;8;9;10" ++
							     " 70 167;2;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
							     ";five;"++OPT_INFO++";7;8;9;10"
					      end;
					  false ->
					      "70 127;1250632800;"++integer_to_list(DEB)++";"++integer_to_list(FIN)++
						  ";five;"++OPT_INFO++";7;8;9;10"
				      end
			      end,
%% 		    Zone_80 = case Msisdn_kdo of
%% 			  0 -> "";
%% 			  _ -> " 80 0"++integer_to_list(Msisdn_kdo)++";2;3;4;5;6"
%% 		      end,		      
		    Zone_80 = case Msisdn_kdo of
				  0 -> "";
				  _ ->
				      case is_list(Msisdn_kdo) of 
					  true ->
					      update_z80(Msisdn_kdo);
					  _ -> " 80 0"++integer_to_list(Msisdn_kdo)++";2;3;4;5;6"
				      end					 
			      end,
		    "C_OP2" ++ Msisdn ++ " 0 "++Zone_70++Zone_80;
		Top_num_actual -> 
		    io:format("SACHEM FAKE: C_OP2, Top_num_actual:~p~n",[Top_num_actual]),
		    ZONE_70 = "70 0;2;3;4;five;-;7;8;9;10 ",
		    "C_OP2" ++ Msisdn ++ " 0 "++ZONE_70
    end;

request(("NTRD "++_)=Req) ->
    [Request, Sender, Receiver, Transfer_ID]=string:tokens(Req," "),  
    case Transfer_ID of
	"101" ->
	    "NTRD" ++ " 1 121 10230 93 111 5000 12";
	"103" ->
	    "NTRD" ++ " 1 121 10230 93 111 5000 35";
	"118" ->
	    "NTRD" ++ " 1 121 45000 93 111 5000 0";
	"102" ->
	    "NTRD" ++ " 1 121 42000 93 111 5000 0";
	_ ->
	    "NTRD" ++ " 1 121 10230 93 111 5000 0"
    end;
request(("C_TCK "++_)=Req) ->
    [Request, C_tck_key_type, C_tck_key_value, Msisdn]=string:tokens(Req," "),  
    slog:event(trace, ?MODULE, c_tck_request, {Req,Request, C_tck_key_type, C_tck_key_value, Msisdn}),
    case C_tck_key_type of
	%%R: C_TCKVALEUR_CLE STATUT TTK_NUM CTK_NUM ETT_NUM TCK_NSCR TCK_NE 
	%%   TCK_DATE_LIMITE TCK_DATE_ETAT UTL_DATE UTL_DOSSIER OFR_NUM
	"1" ->
	    slog:event(trace, ?MODULE, c_tck_req, {c_tck_key_type, "2" }),
	    L=lists:nthtail(12,C_tck_key_value),
	    case L of
		[$1,$1] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_13 }),
		    %% TTK = 106 for Recharge 5E Limite
		    "C_TCK" ++ C_tck_key_value  ++ " 00 106 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$1,$2] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_124 }),
		    %% TTK = 113 for Recharge 10E Limite
		    "C_TCK" ++ C_tck_key_value  ++ " 00 113 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		Else ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk, Else }),
		    %% TTK = 0 arbitrairement
		    "C_TCK" ++ C_tck_key_value  ++ " 00 116 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1"
 	    end;
%% 	    slog:event(trace, ?MODULE, c_tck_req_error, {c_tck_key_type_1_not_used_yet, Req }),
%% 	    "C_TCK" ++ C_tck_key_value  ++ " 11 1 1 2 2526 890 1234567890 123457891 1234567892 0680829041 0";
	"2" ->
	    slog:event(trace, ?MODULE, c_tck_req, {c_tck_key_type, "2" }),
	    L=lists:nthtail(12,C_tck_key_value),
	    case L of
		[$1,$1] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_13 }),
		    %% TTK = 13 for Recharge 20E Limite
		    "C_TCK" ++ C_tck_key_value  ++ " 00 13 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$1,$2] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_124 }),
		    %% TTK = 124 for Recharge 20E Limite
		    "C_TCK" ++ C_tck_key_value  ++ " 00 124 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$2,$4] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_106 }),
		    %% TTK = 106 for Recharge 5E Limite
		    "C_TCK" ++ C_tck_key_value  ++ " 00 106 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$2,$3] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_113 }),
		    %% TTK = 113 for Recharge 10E Limite
		    "C_TCK" ++ C_tck_key_value  ++ " 00 113 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$2,$5] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_163 }),
		    %% TTK = 163 for Recharge 20E musique
		    "C_TCK" ++ C_tck_key_value  ++ " 00 163 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$2,$6] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_162 }),
		    %% TTK = 162 for Recharge Roaming Casion
		    "C_TCK" ++ C_tck_key_value  ++ " 00 162 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$2,$7] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_161 }),
		    %% TTK = 161 for Recharge SMS illimites Casion
		    "C_TCK" ++ C_tck_key_value  ++ " 00 161 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$2,$9] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_1 }),
                    %% TTK = 1 for Recharge SL 15E Casino
                    "C_TCK" ++ C_tck_key_value  ++ " 00 1 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$3,$3] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_168 }),
		    %% TTK = 168 for Recharge SL 7E messages illimites
		    "C_TCK" ++ C_tck_key_value  ++ " 00 168 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$4,$1] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_143 }),
		    %% TTK = 143 for Recharge Symacom
		    "C_TCK" ++ C_tck_key_value  ++ " 00 143 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$4,$2] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_149 }),
		    %% TTK = 149 for Recharge Symacom
		    "C_TCK" ++ C_tck_key_value  ++ " 00 149 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$4,$3] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_155}),
		    %% TTK = 155 for Recharge Symacom
		    "C_TCK" ++ C_tck_key_value  ++ " 00 155 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		
		[$5,$1] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_169}),
		    %% TTK = 169 for Recharge Breizh
		    "C_TCK" ++ C_tck_key_value  ++ " 00 169 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1"; 
		
		[$5,$2] ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk_170}),
		    %% TTK = 170 for Recharge Breizh
		    "C_TCK" ++ C_tck_key_value  ++ " 00 170 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$3] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_142}),
                    %% TTK = 142 for Recharge Virgin RSI2
                    "C_TCK" ++ C_tck_key_value  ++ " 00 142 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$4] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_172}),
                    %% TTK = 172 for Recharge MobiCMO tous canaux
                    "C_TCK" ++ C_tck_key_value  ++ " 00 172 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$5] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_174}),
                    %% TTK = 174 for Recharge MobiCMO tous canaux
                    "C_TCK" ++ C_tck_key_value  ++ " 00 174 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$6] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_116}),
                    %% TTK = 116 for Recharge Breizh/Virgin
                    "C_TCK" ++ C_tck_key_value  ++ " 00 116 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$7] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_95}),
                    %% TTK = 95 for Recharge Breizh/Virgin
                    "C_TCK" ++ C_tck_key_value  ++ " 00 95 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$8] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_114}),
                    %% TTK = 114 for Recharge Breizh/Virgin
                    "C_TCK" ++ C_tck_key_value  ++ " 00 114 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$5,$9] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_115}),
                    %% TTK = 115 for Recharge Breizh/Virgin
                    "C_TCK" ++ C_tck_key_value  ++ " 00 115 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$6,$0] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_176}),
                    %% TTK = 176 for Recharge Breizh Mobile 5E 15J
                    "C_TCK" ++ C_tck_key_value  ++ " 00 176 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$6,$1] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_177}),
                    %% TTK = 177 for Recharge Breizh Mobile 25E 93J
                    "C_TCK" ++ C_tck_key_value  ++ " 00 177 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$6,$2] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_2}),
                    %% TTK = 2 for Recharge MobiCMO tous canaux
                    "C_TCK" ++ C_tck_key_value  ++ " 00 2 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$6,$3] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_3}),
                    %% TTK = 3 for Recharge MobiCMO tous canaux
                    "C_TCK" ++ C_tck_key_value  ++ " 00 3 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		[$6,$4] ->
                    slog:event(trace, ?MODULE, c_tck_req, {ttk_4}),
                    %% TTK = 4 for Recharge MobiCMO tous canaux
                    "C_TCK" ++ C_tck_key_value  ++ " 00 4 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1";
		Else ->
		    slog:event(trace, ?MODULE, c_tck_req, {ttk, Else }),
		    %% TTK = 0 arbitrairement
		    "C_TCK" ++ C_tck_key_value  ++ " 00 120 2 2 16228 0 50D8EC80 47302B34 4381F272 0680070009 1"
	    end;
	_ ->
	    slog:event(trace, ?MODULE, c_tck_req_error, {c_tck_key_type_should_be_1_or_2,C_tck_key_type, Req }),
	    "C_TCK" ++ "99"  ++ " 00 0 0 0 0000 000 0000000000 000000000 0000000000 0000000000 0"
    end;
request(Req) ->
    slog:event(internal, ?MODULE, unknown_request, Req),
    sachem_fake_error.

encode_top(TOP_LIST,MIN,MAX)->
    BIT_FIELD=lists:foldl(fun(TOP,Acc)->
				  case (TOP<MAX) and (TOP>=MIN) of
				      false->
					  Acc;
				      true->
					  Acc+(1 bsl (TOP-MIN))
				  end end,0,TOP_LIST),
    integer_to_list(BIT_FIELD).
				  
%%%%%%%%%%%%%%%%%%%%%%%% CONSULTATION REQUESTION FUNCTIONS %%%%%%%%%%%%%%%%%%% 
make_a4_resp(IMSI) ->
    sachem_cmo_fake:make_a4_resp(IMSI,mobi).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  RECHARGEMENT SIMULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


do_rech_D4(_,123)->
    %% utilise par D6
    %% {TTK_V,CTK_N,TTK_NUM,Zones60}
    {45000, 1,  make_z60(?C_PRINC,?AC,45000)};
do_rech_D4([$1,$1],_) ->
    %% 20 Euros Rechgt
    {20000, 1, make_z60(?C_PRINC,?AC,21000)};
%%%%%%%%%%% PASSAGE A D4
do_rech_D4([$0,$1],_)->
    %% 70 FF
    {10854,1,make_z60(?C_PRINC,?AC,10854)};
do_rech_D4([$0,$2],_) ->
    %% 140 F
    {21709,1,make_z60(?C_PRINC,?AC,21709)++make_z60(?C_SMS,?AC,5000)};
do_rech_D4([$0,$3],_) ->
    %% 15 Euros
    {15000,1,make_z60(?C_SMS,?AC,15000)};
do_rech_D4([$0,$4],_)->
    %% 100% SMS 100SMS
    {15000,4, make_z60(?C_SMS_NOEL,?AC,15000)};
do_rech_D4([$0,$5],_)->
    %% 100% SMS 10SMS
    {1500,4, make_z60(?C_SMS_NOEL,?AC,7500)++make_z60(?C_PRINC,?AC,7500)};
do_rech_D4([$0,$6],_) ->
    %% 10 Euros WE infini
    {10000,?RECHARGE_WEINF,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$7],_) ->
    %% 10 Euros Europe
    {10000,?RECHARGE_EUROPE,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$8],_) ->
     %% 10 Euros Maghreb
    {10000,?RECHARGE_MAGHREB,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$0,$9],_) ->
     %% 5 Euros ERech SMS/MMS
    {5000,?RECHARGE_SMSMMS,make_z60(?C_PRINC,?AC,15000)};
do_rech_D4([$1,$0],_) ->
     %% 45 Euros ERech Journee infinie
    {45000,?RECHARGE_JINF,make_z60(?C_PRINC,?AC,15000)};
%% do_rech_D4([$1,$1],_) ->
%%      %% 20 Euros Rechgt Limitee Noel: TV Illimitee
%%     {20000,?RECH_LIMITE_NOEL,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$1,$2],_) ->
    %% 20 Euros SL Rechgt Messages ilLimitee
    {20000,2,make_z60(?C_PRINC,?AC,21000)};
%% do_rech_D4([$1,$3],_) ->
%%      %% 20 Euros Rechgt Limitee Noel: SMS Illimitee
%%     {20000,?RECH_LIMITE_NOEL,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$1,$4],_) ->
     %% 7 Euros Rechgt Limitee : Surf Illimitee 7 jours
    {7000,?RECHARGE_SL,make_z60(?C_PRINC,?AC,21000)};
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
do_rech_D4([$2,$1],_) ->
    % 20 Euros Rechgt Special Vacances
    {36000,?RECHARGE_VACANCES,[make_z60(?C_PRINC,?AC,24000),make_z60(?C_ROAMING_IN,?AC,20000,?PTF_ROAMING_IN),make_z60(?C_ROAMING_OUT,?AC,15000,?PTF_ROAMING_OUT)]};
do_rech_D4([$2,$2],_) ->
    % Erreur technique 99
    {98};
do_rech_D4([$2,$4],_) ->
    %% 20 Euros SL Rechgt Messages ilLimitee
    {20000,2,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$2,$5],_) ->
    %% 20 Euros SL Rechgt Messages ilLimitee
    {20000,2,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$2,$6],_) ->
    %% 20 Euros SL Rechgt Messages ilLimitee
    {20000,2,make_z60(?C_RECH_ROAMING_TELE2,?AC,21000)};
do_rech_D4([$2,$7],_) ->
    %% 20 Euros Rechgt SMS ilLimites
    {20000,2,make_z60(?C_RECH_SMS_ILLM,?AC,21000)};
do_rech_D4([$2,$9],_) ->
    %% 15E + 8,5E Euros Rechgt Casino Tele2
    {15000,2,make_z60(?C_PRINC,?AC,23500)};
do_rech_D4([$3,$3],_) ->
    %% 20 Euros SL Rechgt Messages ilLimitee
    {7000,2,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$5,$1],_) ->
    %% 10 Euros Breizh
    {10000,2,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$5,$2],_) ->
    %% 5 Euros Breizh
    {5000,2,make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$5,$3],_) ->
    %% 25 Euros Rechgt Virgin RSI2
    {25000,2,make_z60(?C_RECH_SMS_ILLM,?AC,21000)};
do_rech_D4([$5,$4],_) ->
    %% 20 Euros Rechgt MobiCMO Tous Canaux
    {20000, 1, make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$5,$5],_) ->
    %% 20 Euros Rechgt MobiCMO Tous Canaux
    {20000, ?RECHARGE_20E_SL, make_z60(?C_PRINC,?AC,21000)};
do_rech_D4([$6, $0],_)->
    {5000, 1, make_z60(?C_PRINC, ?AC,5000)};
do_rech_D4([$6, $1],_) ->
    {25000, 1, make_z60(?C_PRINC, ?AC, 25000)};
do_rech_D4([$3,Error],_) ->
    % TR erreur 10 X
    {10,list_to_integer([Error])};

do_rech_D4([$5,$0],_) ->
    % TR erreur 99 X
    {99,3};

do_rech_D4([$4,LAST_NUMBER],[CHOIX]) -> % Recharge avec Choix client TR erreur 10 X
    case LAST_NUMBER of
	CHOIX -> {15000,1,make_z60(?C_PRINC,?AC,15000)};
	_ ->{10,list_to_integer([CHOIX])}
    end;
do_rech_D4(_,_) ->
    {15000,1,make_z60(?C_PRINC,?AC,15000)}.

type_ticket_rech([$1,$1]) ->
    %% 20 Euros Rechgt
    13;
type_ticket_rech([$1,$2]) ->
    %% 20 Euros Rechgt
    124;
type_ticket_rech([$1,$5]) ->
    %% 24 Euros Rechg Z1
    109;
type_ticket_rech([$1,$6]) ->
    %% 24 Euros Rechg Z2
    110;
type_ticket_rech([$1,$7]) ->
    %% 24 Euros Rechg Z3
    111;
type_ticket_rech([$2,$4]) ->
    %% 5 Euros Rechg Virgin VeryLong
    106;
type_ticket_rech([$2,$5]) ->
    %% 20 Euros Rechgt
    163;
type_ticket_rech([$2,$6]) ->
    %% 20 Euros Rechgt
    162;
type_ticket_rech([$2,$7]) ->
    %% 20 Euros Rechgt
    161;
type_ticket_rech([$2,$9]) ->
    %% 15 Euros Rechgt Casino
    1;
type_ticket_rech([$3,$3]) ->
    %% 7 Euros Rechgt
    168;

type_ticket_rech([$5,$1]) ->
    %% 10 Euros Rechgt
    169;

type_ticket_rech([$5,$2]) ->
    %% 10 Euros Rechgt
    170;
type_ticket_rech([$5,$3]) ->
    %% 25 Euros Rechgt Virgin RSI2
    142;
type_ticket_rech([$5,$4]) ->
    %% 20 Euros Rechgt MobiCMO
    172;
type_ticket_rech([$5,$5]) ->
    %% 20 Euros Rechgt MobiCMO
    174;
type_ticket_rech([$6,$0]) ->
     %% 5 Euros Rechgt Breizh Mobi
     176;
type_ticket_rech([$6, $1]) ->
     %% 25 Euros Rechgt Breizh Mobi
     177;
type_ticket_rech([$6, $2]) ->
     %% 10E+10E SL Mobi
     2;
type_ticket_rech([$6, $3]) ->
     %% 20E+20E SL Mobi
     3;
type_ticket_rech([$6, $4]) ->
     %% 30E+30E SL Mobi
     4;
type_ticket_rech(Else) ->
    0.

make_z60(TCP_NUM,ECP,CPP_SOLDE)->
    PTF_NUM=39,
    make_z60(TCP_NUM,ECP,CPP_SOLDE,PTF_NUM).

make_z60(TCP_NUM,ECP,CPP_SOLDE,PTF_NUM)->
    UNT_NUM=1,
    DLV=pbutil:unixtime(),
    RNV=0,
    ECP_NUM=ECP,
    CPP_CUMUL_CREDIT= 25000,
    PCT=ANC=MNT_INIT=TOP_NUM=MNT_BON=0,
    pbutil:sprintf("60 %d;%d;%d;%x;%d;%d;%d;%d;%d;%d;%d;%d;%d ",
		   [TCP_NUM,UNT_NUM,CPP_SOLDE,DLV,RNV,ECP_NUM,PTF_NUM,
		    CPP_CUMUL_CREDIT,PCT,ANC,MNT_INIT,TOP_NUM,MNT_BON]).

debug(_, _) -> ok.

xdebug(Format, Args) ->
    io:format("~p: "++Format, [?MODULE | Args]),
    ok.


subscription_init()->
    case ets:info(sub,name) of
	sub->
	    ok;
	_->
	    ets:new(sub,[set,public,named_table])
    end,
    ets:insert(sub,{"208010900000001","mobi"}),
    ets:insert(sub,{"208010901000001","cmo"}),
    ets:insert(sub,{"208010902000001","postpaid"}).    


tcp_num_dest("35","0")->
    "215";
tcp_num_dest(_,_)->
    "59".
solde("35")->
    "0";
solde(_)->
    "50".

update_z80([]) -> "";
update_z80([0])-> "";
update_z80([0|Tail]) ->
    update_z80(Tail);
update_z80([Head|Tail]) ->    
    " 80 0"++integer_to_list(Head)++";2;3;4;5;6"++update_z80(Tail).
