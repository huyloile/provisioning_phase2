-module(test_sachem).
-compile(export_all).
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/tlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("sachem.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run() ->
    %% Currently sachem_server is not built in a way where we can
    %% make unit tests.
    %% it always calls sdp_router.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
     application:start(pservices_orangef),
     application:start(pfront_orangef),
     test_util_of:online(?MODULE,test()).

test() ->
    [{title, "Online Test for Sachem queries"}] ++ %%THESE TESTS DO NO CRASH WHEN ERROR!!!!
 	test_ntrd() ++  
	test_c_op_test(mobi)  ++
%	test_c_op(cmo)  ++
% 	test_c_op2() ++
% 	test_c_tck() ++
%	test_svi_d6() ++
	[].

test_c_op_test(Subscription) ->
    test_util_of:insert(?IMSI_GLOBAL,
			?mobi,
			0,
			[#compte{tcp_num=?C_PRINC,
				 unt_num=?EURO,
				 cpp_solde=42000,
				 dlv=pbutil:unixtime(),
				 rnv=0,
				 etat=?CETAT_AC,
				 ptf_num=?PCLAS_V2}
			])++
	%% Case no options
	[{title, "C_OP query to get the list of top nums : Case no options"}] ++ 
	[{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc,call, [possum@localhost, 
		       sdp_router, svi_c_op, [{Subscription,?MSISDN_INTL}]]}
	  ]}].

test_c_op(Subscription) ->
    test_util_of:insert(?IMSI_GLOBAL,
			?mobi,
			0,
			[#compte{tcp_num=?C_PRINC,
				 unt_num=?EURO,
				 cpp_solde=42000,
				 dlv=pbutil:unixtime(),
				 rnv=0,
				 etat=?CETAT_AC,
				 ptf_num=?PCLAS_V2}
			])++
	%% Case no options
	[{title, "C_OP query to get the list of top nums : Case no options"}] ++ 
	[{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc,call, [possum@localhost, 
		       sdp_router, svi_c_op, [{Subscription,?MSISDN_INTL}]]}
	  ]}]++
	%% Case options
 	test_util_of:insert_list_top_num(?MSISDN_NAT,[100,110]) ++
 	[{title, "C_OP query to get the list of top nums : Case options"}] ++ 
 	[{erlang, 
 	  [
 	   {net_adm, ping,[possum@localhost]},
 	   {rpc,call, [possum@localhost, 
 		       sdp_router, svi_c_op, [{Subscription,?MSISDN_INTL}]]}
 	  ]}] ++
	%% Result [pong,"nd"]
	%% Better receive 100,110 than nd ???

	%% Info for one option
	[{title, "C_OP query to get the information for one option"}] ++ 
	[{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc,call, [possum@localhost, 
		       sdp_router, svi_c_op, [{Subscription,?MSISDN_INTL}, 100]]}
	  ]}] ++
	%% Info for an option which is not activated
	[{title, "C_OP query to get the information for an option which is not activated"}] ++ 
	[{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc,call, [possum@localhost, 
		       sdp_router, svi_c_op, [{Subscription,?MSISDN_INTL}, 120]]}
	  ]}].

test_c_op2() ->
    Sub = mobi,
    NUMID_code = "0",
    NUMID = "45",
    MSISDN_code = "1",
    MSISDN = "+33600000001",
    NSCE_code = "2",
    NSCE = "454545",
    IMSI_code = "3",
    IMSI = "",
    TOP_NUM = "100", 
    %%
    [{title, "C_OP2 query to get the detailed information about the options of this client"}] ++ 
    [{erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc,call, [possum@localhost, 
		   sdp_router, svi_c_op2, [{Sub,MSISDN}, MSISDN_code, MSISDN, "NULL"]]}
      ]}]++
    %%	
    [{title, "C_OP2 query to get the information about the option with TOP num: "++ TOP_NUM}] ++ 
     [{erlang, 
       [
        {net_adm, ping,[possum@localhost]},
        {rpc,call, [possum@localhost, 
 		   sdp_router, svi_c_op2, [{Sub,MSISDN}, MSISDN_code, MSISDN, TOP_NUM]]}
       ]}].
%% We cannot use 'expect' to check the answer
%% Because the format is {ussd2, [{send,"#123"},{expect,"answer"}]}

test_ntrd() ->
    Sub = mobi,
    Msisdn_receiver= "+33600000001",
    Msisdn_transmetter = "+33600000002",
    [{title, "NTRD query"}] ++
    [{erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc,call, [possum@localhost, 
		   sdp_router, svi_ntrd, [ {Sub,Msisdn_receiver},Msisdn_transmetter, "0"]]}
      ]}].

test_c_tck() ->
    %%Q: C_TCK TYPE_CLE VALEUR_CLE MSISDN    
    Sub = mobi,
    C_tck_key_value = "12345678901234",
    Msisdn = "+33600000001",
    [{title, "C_TCK query"}] ++
    [{erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc,call, [possum@localhost, 
		   sdp_router, c_tck, [{Sub,Msisdn}, "1", C_tck_key_value ]]},
       {rpc,call, [possum@localhost, 
		   sdp_router, c_tck, [{Sub,Msisdn}, "2", C_tck_key_value ]]}
      ]}].

test_svi_d6() ->
    %% Q : D6 MSISDN   TICKET DATE CHOIX CANAL_NUM
    Sub=mobi,
    Msisdn = "+33600000001",
    Ticket="12345678901234",
    Choix=123,
    [{title, "D6 query"}] ++
    [{erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc,call, [possum@localhost, 
		   sdp_router, svi_d6, [{Sub,Msisdn}, Ticket, pbutil:unixtime()+500, Choix]]}
      ]}].

recup_var(L)->
    Command= "rsh -l sb io0  /home/sb/install-20011115/cellicium/possum/"
	"lib/pgsm/priv/i386-redhat-linux/fsx25port.out"
	" -l -c MUSS -g 2 "++?X25_MOBI,
    io:format("Connecting test (~p)~n", [Command]),
    Pid = open_port({spawn, lists:flatten(Command)}, [{line,10000}]),
    receive
	{Port, {data, {eol,Reply}}} ->
		    io:format("SDP banner ~p~n", [Reply]), ok
    after 1000 ->
	    exit({timeout, sdp})
    end,
    info(L,Pid).

recup_var_cmo(L)->
    Command= "rsh -l sb io0 /home/sb/install-20011115/cellicium/possum/"
	"lib/pgsm/priv/i386-redhat-linux/fsx25port.out"
	" -l -c CUSS -g 2 "++?X25_CMO,
    io:format("Connecting test (~p)~n", [Command]),
    Pid = open_port({spawn, lists:flatten(Command)}, [{line,10000}]),
    receive
	{Port, {data, {eol,Reply}}} ->
		    io:format("SDP banner ~p~n", [Reply]), ok
    after 1000 ->
	    exit({timeout, sdp})
    end,
    info(L,Pid).

info(L,Pid)->
    info(L,Pid,[]).
info([ID|T],Pid,Acc)->
    Request=
	case ID of
	    {imsi,IMSI}->
		"A4 3 "++IMSI;
	    {msisdn,MSISDN}->
		"A4 1 "++MSISDN
	end,
    {ok,R}=send(Request,Pid),
    case catch decode(R) of
	{ok,L}->
	    io:format("Att=~p",[L]),
	    info(T,Pid,Acc++L);
	E ->
	 exit({error, E})
    end;
info([],Pid,Acc)->    Acc.

send(Request,Pid)->
    pbutil:send_port(Pid, Request),
    receive
	{Pid, {data, {eol, Reply2}}} ->
	    io:format("ReQ>>~p·~n",[Request]),
	    io:format("Rep>>~p·~n",[Reply2]),
	    {ok,Reply2}
    after 10000 ->
	 exit({timeout, sdp})
    end.

decode(Request)->
    Format="A4%s 00 40 %s;%d;%d;%d;%d;%x;%x;%x;%d;%s;%s;%x;%x",
    case catch check_semicolon_response(Format, Request) of
	{'EXIT', E} -> 
	    io:format("EXIT ~p~n",[E]);
	{Attributes, Rest} ->
	    [MSISDN,DOSNUMID,ETAT_PRINC|T]=Attributes,
	    {ok,[{MSISDN,DOSNUMID,ETAT_PRINC}]}
    end.

check_semicolon_response(Format, Response) ->
    do_check_semicolon_response(Format, Response, []).

do_check_semicolon_response(Format, Response, Acc) ->
    case pbutil:split_at($;, Format) of
	not_found ->
	    %% last item to be matched
	    {Attributes, Rest} = pbutil:sscanf(Format, Response),
	    {Acc++Attributes, Rest};
	{FItem, FormatRest} ->
	    %% this will exit if no ";" found
	    {RespItem, ResponseRest} = pbutil:split_at($;, Response),
	    {Attributes, Rest} = pbutil:sscanf(FItem, RespItem),
	    do_check_semicolon_response(FormatRest, ResponseRest,
					Acc++Attributes)
    end.
  
etat_change(SEtat,Band,et)->
    {ok,[Etat],[]}=io_lib:fread("~d",SEtat),
    NewETAT=Etat band Band,
    integer_to_list(NewETAT);
etat_change(SEtat,Band,ou)->
    {ok,[Etat],[]}=io_lib:fread("~d",SEtat),
    NewETAT=Etat bor Band,
    integer_to_list(NewETAT).

solde_change(Solde,Prix_euro)->
    N_solde=list_to_integer(Solde)-Prix_euro,
    integer_to_list(N_solde).
to_sms(Solde,Prix)->
    Nb=list_to_integer(Solde) div Prix,
    integer_to_list(Nb).
print_solde(Solde)->
    S=(round(list_to_integer(Solde)*100/1000))/100,
    [Psol]=io_lib:format("~.2f",[S]),
    Psol.
print_date()->
    pbutil:sprintf("%x",[pbutil:unixtime()]).

%% Modif etat secondaire
mk_int_id12(ID,DOSNUMID,ETAT_SEC)->
    tlv_encodage:encode_packet(ID,?int_id12,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?ESC_NUM_BIN,ETAT_SEC}]).
%% Modif Etat Principale
mk_int_id23(ID,DOSNUMID,ETAT_PRINC)->
    tlv_encodage:encode_packet(ID,?int_id23,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?EPR_NUM,ETAT_PRINC}]).

%% Suppression compte d'un dossier
mk_int_id08(ID,DOSNUMID,TCP_NUM)->
    tlv_encodage:encode_packet(ID,?int_id08,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?TCP_NUM,TCP_NUM}]).

%% Création d'un compte secondaire
mk_int_id06(ID,DOSNUMID,TCP_NUM,ECP_NUM,CPP_SOLDE,CPP_DATE_LV,RNV_NUM)->
    tlv_encodage:encode_packet(ID,?int_id06,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?TCP_NUM,TCP_NUM},
			{?ECP_NUM,ECP_NUM},
			{?CPP_SOLDE,CPP_SOLDE},
			{?CPP_DATE_LV,CPP_DATE_LV},
			{?RNV_NUM,RNV_NUM}
		       ]).

mk_int_id06(ID,DOSNUMID,TCP_NUM,ECP_NUM,CPP_SOLDE,CPP_DATE_LV,RNV_NUM,PTF_NUM)->
    tlv_encodage:encode_packet(ID,?int_id06,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?TCP_NUM,TCP_NUM},
			{?ECP_NUM,ECP_NUM},
			{?PTF_NUM,PTF_NUM},
			{?CPP_SOLDE,CPP_SOLDE},
			{?CPP_DATE_LV,CPP_DATE_LV},
			{?RNV_NUM,RNV_NUM}
		       ]).

%% Modification d'un compte 
mk_int_id07(ID,DOSNUMID,TCP_NUM,PTF_NUM,ECP_NUM,CPP_DATE_LV,RNV_NUM)->
    tlv_encodage:encode_packet(ID,?int_id07,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?TCP_NUM,TCP_NUM},
			{?PTF_NUM,PTF_NUM},
			{?ECP_NUM,ECP_NUM},
			{?CPP_DATE_LV,CPP_DATE_LV},
			{?RNV_NUM,RNV_NUM}
		       ]).

%% desactivation d'un option
mk_int_id18(ID,DOSNUMID,TOP_NUM)->
    tlv_encodage:encode_packet(ID,?int_id18,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?TOP_NUM,TOP_NUM}]).

%% activation d'une option
mk_int_id19(ID,DOSNUMID,TOP_NUM,OPD_NUM)->
    tlv_encodage:encode_packet(ID,?int_id19,
		       [{?ACI_NUM,?Val_ACI_NUM},
			{?DOS_NUMID,list_to_integer(DOSNUMID)},
			{?TOP_NUM,TOP_NUM},
		        {?OPD_NUM,OPD_NUM},
		        {?OPT_INFO1,"0"},
			{?OPT_INFO2,"0"},
			{?OPT_INFO3,"0"},
			{?OPT_INFO4,"0"},
			{?OPT_INFO5,"0"},
			{?OPT_INFO6,"0"}
		       ]).

int_to_list(I)->
    integer_to_list(I).
