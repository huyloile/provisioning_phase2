-module(test_sms_games).
-export([run/0, online/0]).
-export([smsmo_queue_init/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pgsm/include/emi.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(IMSI,"208010900000001").
-define(MSISDN,"+99100000005").
-define(IMSI_ANSI,"999000900000014").
-define(IMSI_LESS_181,"208010901000001").
-define(MSISDN_LESS_181,"+99100000006").
-define(IMSI_NO_CREDIT,"999000900000009").
-define(DIRECT_CODE, "#101#").
-define(INCOMPLETE_DIRECT_CODE, "#101*").
-define(END_CODE,"#").

%BEGINNING OF MONTHLY MODIFICATION ZONE
-define(SHORT_ID_1,"23030").
-define(SHORT_ID_2,"20555").
-define(SHORT_ID_3,"20666").
-define(SHORT_ID_4,"20239").
-define(SHORT_ID_5,"20333").
-define(SHORT_ID_6, "20774").
-define(SHORT_ID_7, "20775").
-define(CONCOURS,"1").
-define(REFLEXION,"1").
-define(LUDIQUE,"2").
-define(ACTION,"3").
-define(CASINO,"4").
-define(TARIF,"5").
-define(ACCUEIL,"Gagnez.*Reflexion.*Ludique.*Action.*Casino.*Tarif").
-define(EXPECT_TARIF,
	"Pour jouer, chaque SMS sera facture.*"
 	"Le Boxeur, Mafiosi\\: 0.05E\\+cout d'envoi d'un SMS.*"
 	"Fermland, Meli Melo, My Girl, My Boy.*"
	"0.20E\\+cout d'envoi d'un SMS.*"
	"1.Suite.*").
-define(EXPECT_TARIF_SUITE, 
	"Compatibilite Astro \\& numerologie: 0.35E\\+cout d'envoi d'un SMS.*"
	"Autres jeux: 0.10E\\+cout d'envoi d'un SMS.*").
-define(KDOS_KICKDONC_BLONDES, 
	"Les Kdos\\!.*"
 	"Du 15/06/06 au 18/07/06.*"
 	"1er au 3eme prix\\: Lecteur MP"
	" a disque dur Sony NWA1000..*"
 	"Valeur\\: 210E TTC.*"
	"Du 4eme au 10eme prix\\: Un coffret DVD special blondes.*"
       ).
-define(KDOS_KICDONC,"kdos.*01/12/05.*31/12/05.*lecteur DVD.*"
	".*coffret integral.*").
-define(KDOS_LABY,"kdos.*01/01/06.*31/01/06.*1er prix; Un Ipod Nano 2Go et sa housse d'une valeur de 250E TTC.*").
-define(KDOS_BLACKJACK,"kdos.*01/11/05.*30/11/05.*Un mini Apple Ipod.*Un DVD du film.*Casino.*").
-define(KDOS_MYGIRL,"kdos.*08/02/06.*28/02/06.*WE a Prague.*").
-define(KDOS_TRIVIAL, ".*Kdos.*15/05/06 au 15/06/06.*appareil photo numerique.*mini TV LCD.*").
-define(KDOS_CHIFUMI,"").
-define(KDOS_FERMLAND,"kdos.*05/03/06.*15/04/06.*appareil photo.*").
-define(KDOS_MELIMEMO,"").
-define(KDOS_MAFIOSI,"kdos.*01/12/05.*31/12/05.*coffret DVD.*prix.*").
-define(KDOS_MYBOY,"kdos.*08/02/06.*28/02/06.*WE a Prague.*").
-define(KDOS_MARVELB,"kdos.*1 PSP.*jeu Spider-man.*").
-define(KDOS_BOXEUR,"kdos.*01/07/05.*31/07/05.*Boxeur.*Rocky.*gants de boxe.*").
-define(KDOS_AFFINITE,"kdos.*15/03/06.*17/04/06.*camescope.*mini chaine.*").
-define(KDOS_PENDU,"Kdos.*14/04/06.*15/05/06.*Ipod Nano.*console PSP.*").
-define(KDOS_PETIT_BAC, ".*Kdos.*15/05/06.*15/06/06.*appareil photo numerique.*DvD portable.*").
-define(INSC_DEF,"Veuillez saisir votre pseudo").
-define(INSC_CHIFUMI,"Pour participer.*envoyez votre pseudo").
-define(INSC_MAFIOSI,"Mafiosi.*Pour participer.*envoyez votre pseudo").
-define(INSC_BOXEUR, "Le Boxeur.*Pour participer.*envoyez votre pseudo").
-define(PSEUDO,"toto").

%%Concours
goto(kicdonc_blondes,concours) ->
    ?INCOMPLETE_DIRECT_CODE++?CONCOURS++"1"++?END_CODE;
goto(petit_bac,concours) ->
    ?INCOMPLETE_DIRECT_CODE++?CONCOURS++"1"++?END_CODE;
goto(trivial,concours) ->
    ?INCOMPLETE_DIRECT_CODE++?CONCOURS++"2"++?END_CODE;
%%Reflexion
goto(kicdonc_blondes,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?REFLEXION++"1"++?END_CODE;
goto(petit_bac,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?REFLEXION++"2"++?END_CODE;
goto(trivial,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?REFLEXION++"3"++?END_CODE;
goto(pendu,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?REFLEXION++"4"++?END_CODE;
goto(melimemo,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?REFLEXION++"5"++?END_CODE;
%%Ludique
goto(astro,standard) ->
     ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"1"++?END_CODE;
goto(numerologie,standard) ->
     ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"2"++?END_CODE;
goto(affiniteprenoms,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"3"++?END_CODE;
goto(fermland,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"4"++?END_CODE;
goto(mygirl,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"5"++?END_CODE;
goto(myboy,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"6"++?END_CODE;
goto(laby,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?LUDIQUE++"7"++?END_CODE;
%%Action
goto(marvelbattle,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?ACTION++"1"++?END_CODE;
goto(mafiosi,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?ACTION++"2"++?END_CODE;
goto(boxeur,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?ACTION++"3"++?END_CODE;
%%Casino
goto(blackjack,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?CASINO++"1"++?END_CODE;
goto(chifumi,standard) ->
    ?INCOMPLETE_DIRECT_CODE++?CASINO++"2"++?END_CODE.

sms_games_test(Mode)->

	[{msaddr, {subscriber_number, private, ?IMSI}}] ++
	
	%% En concours
	%%test_simple_ok(Mode,standard,kicdonc_blondes,"KiCdonc Special Blondes",?KDOS_KICKDONC_BLONDES,"",?SHORT_ID_2,"KIC") ++
 	%% Refexion
        test_simple_ok(Mode,standard,kicdonc_blondes,"KiCdonc Special Blondes","","",?SHORT_ID_2,"KIC") ++
  	test_simple_ok(Mode,standard,petit_bac,"Petit Bac","","",?SHORT_ID_2,"BAC") ++
	test_simple_ok(Mode,standard,trivial,"Trivial","",?INSC_DEF,?SHORT_ID_4,"TP") ++
  	test_simple_ok(Mode,standard,pendu,"Pendu","","",?SHORT_ID_2,"PEN") ++
  	test_simple_ok(Mode,standard,melimemo,"Meli Memo","","",?SHORT_ID_1,"MOT") ++
 	%% Ludique/Simulation
 	test_simple_ok(Mode,standard,astro,"Compatibilite Astro","","",?SHORT_ID_7,"COMP") ++
 	test_simple_ok(Mode,standard,numerologie,"Numerologie","","",?SHORT_ID_6,"NUM") ++
 	test_simple_ok(Mode,standard,affiniteprenoms,"Affinite Prenoms","","",?SHORT_ID_1,"LOVE") ++
 	test_simple_ok(Mode,standard,fermland,"Fermland","","",?SHORT_ID_1,"FER") ++
 	test_simple_ok(Mode,standard,mygirl,"Mygirl","","",?SHORT_ID_1,"GIRL") ++
 	test_simple_ok(Mode,standard,myboy,"My Boy","","",?SHORT_ID_1,"BOY") ++
 	test_simple_ok(Mode,standard,laby,"Laby Music","","",?SHORT_ID_2,"LABY") ++
 	%% Action
 	test_simple_ok(Mode,standard,marvelbattle,"Marvel Battle","","",?SHORT_ID_5,"BMJEU") ++
 	test_2steps_ok(Mode,standard,mafiosi,"Mafiosi","",?INSC_MAFIOSI,?SHORT_ID_3,"MAF") ++
 	test_2steps_ok(Mode,standard,boxeur,"Le Boxeur","",?INSC_BOXEUR,?SHORT_ID_3,"BOX") ++
	%% Casino/Strategie
	test_simple_ok(Mode,standard,blackjack,"Black Jack","","",?SHORT_ID_2,"BJK") ++
	test_2steps_ok(Mode,standard,chifumi,"Chi Fu Mi","",?INSC_CHIFUMI,?SHORT_ID_2,"CHI INS").

%END OF MONTHLY MODIFICATION ZONE

test(DCL,Subs) ->

    %%Test title
    [{title, "Test suite for SMS games."}] ++

        %%Connection to the USSD simulator
	[test_util_of:connect(smpp)] ++

        %%Initialization of customer data in ptester
	[{msaddr, {subscriber_number, private, ?IMSI}}] ++
  
	%%Initialization of customer data in the local database
	test_util_of:init_test({imsi,?IMSI},
			       {subscription,Subs},
			       {navigation_level,1},
			       {msisdn,?MSISDN}) ++

	test_util_of:init_test({imsi,?IMSI_LESS_181},
			       {subscription,Subs},
			       {navigation_level,3},
			       {msisdn,?MSISDN_LESS_181}) ++

	test_util_of:init_test(?IMSI_ANSI) ++
	
	test_util_of:init_test(?IMSI_NO_CREDIT) ++

        %%Initialization of customer data in the SACHEM simulator
	test_util_of:insert(?IMSI,DCL,0,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,
						   cpp_solde=2000,
						   dlv=pbutil:unixtime(),
						   rnv=0,etat=?CETAT_AC,
%						   rnv=0,etat=?CETAT_EP,
						   ptf_num=?PCLAS_V2}]) ++

	test_util_of:insert(?IMSI_LESS_181,DCL,0,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,
							  cpp_solde=2000,
							  dlv=pbutil:unixtime(),
						%	  rnv=0,etat=?CETAT_AC,
							  rnv=0,etat=?CETAT_EP,
							  ptf_num=?PCLAS_V2},
						 #compte{tcp_num=?C_FORF_ZAP_CMO_25E_v3,
							 unt_num=?EURO,
							 cpp_solde=5000,
							 dlv=pbutil:unixtime(),
							 rnv=0,
							 etat=?CETAT_AC,
							 ptf_num=?CMO_ZAP_PROMO}]) ++

	test_util_of:insert(?IMSI_ANSI,DCL,0,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,
							cpp_solde=2000,
							dlv=pbutil:unixtime(),
%							rnv=0,etat=?CETAT_AC,
						        rnv=0,etat=?CETAT_EP,
							ptf_num=?PCLAS_V2}])++
%% 					     #compte{tcp_num=?C_FORF,
%% 						     unt_num=?EURO,
%% 						     cpp_solde=5000,
%% 						     dlv=pbutil:unixtime(),
%% 						     rnv=0,
%% 						     etat=?CETAT_EP,
%% 						     ptf_num=?CMO_ZAP_PROMO}]) ++

	test_util_of:insert(?IMSI_NO_CREDIT,DCL,0,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,
							     cpp_solde=0,
							     dlv=pbutil:unixtime(),
							     rnv=0,etat=?CETAT_EP,
							     ptf_num=?PCLAS_V2}]) ++
        %%Test construction
   	ansi() ++ 
   	test_home_page() ++
  	test_cas_refuses() ++
 	switch_smsmo_interface(enabled) ++
 	sms_games_test(test) ++
 	switch_smsmo_interface(disabled) ++
 	sms_games_test(test)++
 	switch_smsmo_interface(enabled) ++

 	%%Session closing
 	test_util_of:close_session() ++

	["Test reussi"] ++

        [].

online() ->
    QueuePid = smsmo_start_client(),
    application:start(pservices_orangef),
    test_util_of:online(?MODULE, test(?pmu,"cmo")),
    smsmo_stop_client(QueuePid).

test_home_page() ->

    test_util_of:set_parameter_for_test(roaming_ansi_codes,[]) ++

    [
     "Test homepage",
     {ussd2,
      [ {send, ?DIRECT_CODE},
	{expect,?ACCUEIL},
	{send,?TARIF},
	{expect,?EXPECT_TARIF},
	{send, "1"},
	{expect,?EXPECT_TARIF_SUITE},
	{send,"9"},
	{expect,?ACCUEIL}
       ]}] ++
	test_util_of:close_session().

test_cas_refuses() ->
    ["Test avec moins de 181 caracteres"],
    [{msaddr, {subscriber_number, private, ?IMSI_LESS_181}},
     {ussd2,
      [ {send, ?DIRECT_CODE},
	{expect, "Votre terminal ne vous permet pas d'acceder a ce service"}
       ]
     }],

    ["Test avec solde nul"] ++
	[{msaddr, {subscriber_number, private, ?IMSI_NO_CREDIT}},
	 {ussd2,
	  [ {send, ?DIRECT_CODE},
	    {expect, "Ce service est inacessible.*epuise.*recharger avant"}
	   ]
	 }],

    [{msaddr, {subscriber_number, private, ?IMSI}},
     {pause, 2000}
    ].

test_simple_ok(Mode,How,Name,NameS,KdoExpect,InscExpect,Short_id,Smsmo) ->
    case Mode of
	init->
	    [{?MSISDN,Short_id,Smsmo}];
	_->
	    ["Test "++NameS,
	     {ussd2,
	      [ {send, goto(Name,How)},
		{expect, NameS},
		{send,"1"}
	       ] ++ 
	      test_simple_kdo(NameS,KdoExpect) ++
	      test_simple_insc(NameS,InscExpect) ++
	      [
	       {expect, "Le SMS est en cours d'envoi."}
	      ]}
	    ]
    end.

test_simple_kdo(_,"") ->
    [];
test_simple_kdo(NameS,KdoExpect) ->
    [
     {expect, KdoExpect},
     {send,"0"},
     {expect, NameS},
     {send, "2"}
    ].

test_simple_insc(_,"") ->
    [];
test_simple_insc(NameS,InscExpect) ->
    [
     {expect, InscExpect},
     {send,?PSEUDO}
    ].

test_2steps_ok(Mode,How,Name,NameS,KdoExpect,InscExpect,Short_id,Smsmo) ->
    case Mode of
	init->
	    [{?MSISDN,Short_id,Smsmo ++ " " ++ ?PSEUDO},{?MSISDN,Short_id,Smsmo}];
	_->
	    test_simple_ok(Mode,How,Name,NameS,KdoExpect,InscExpect,Short_id,Smsmo) ++
		[ {ussd2,
		   [ {send, goto(Name,How)},
		     {expect, NameS}
		    ] ++
		   test_step2(NameS,KdoExpect) ++
		   [ {expect, "Le SMS est en cours d'envoi."}
		    ]}
		 ]
    end.

test_step2(NameS,"") ->
    [ {send,"2"} ];
test_step2(NameS,KdoExpect) ->
    [ {send,"3"} ].

ansi() ->
    test_util_of:set_parameter_for_test(roaming_ansi_codes,["22","11"]) ++
	[
	 {title, "Checking ANSI Access."},
	 "Set imsi=" ++ ?IMSI_ANSI ++ " (a provisioned french user)"]++
	test_util_of:init_test(?IMSI_ANSI) ++
	
	[{vlr_number,"1111111111"}] ++
	
	test_util_of:close_session() ++
	test_util_of:insert(?IMSI_ANSI,?pmu,0,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,
						       cpp_solde=2000,
						       dlv=pbutil:unixtime(),
						       rnv=0,etat=?CETAT_EP,
						       ptf_num=?PCLAS_V2},
					       #compte{tcp_num=?C_FORF,
						       unt_num=?EURO,
						       cpp_solde=5000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_EP,
						       ptf_num=?CMO_ZAP_PROMO},
					      #compte{tcp_num=?C_FORF_FMU_24,
                                                       unt_num=?EURO,
                                                       cpp_solde=10000,
                                                       dlv=pbutil:unixtime(),
                                                       rnv=0,
                                                       etat=?CETAT_EP,
                                                       ptf_num=?CMO_ZAP_PROMO},
					      #compte{tcp_num=?C_VOIX,
                                                       unt_num=?EURO,
                                                       cpp_solde=10000,
                                                       dlv=pbutil:unixtime(),
                                                       rnv=0,
                                                       etat=?CETAT_EP,
                                                       ptf_num=?CMO_ZAP_PROMO}]) ++
	["ANSI network cannot access",
	 {ussd2,
	  [ {send,?DIRECT_CODE},
	    {expect,"Ce service est inacessible car votre credit est epuise.*"
	     "Merci de recharger avant le ../../.."}
	   ]}] ++
	test_util_of:close_session() ++

	test_util_of:insert(?IMSI_ANSI,?pmu,0,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,
						       cpp_solde=2000,
						       dlv=pbutil:unixtime(),
						       rnv=0,etat=?CETAT_EP,
						       ptf_num=?PCLAS_V2},
					       #compte{tcp_num=?C_FORF,
						       unt_num=?EURO,
						       cpp_solde=5000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?CMO_ZAP_PROMO}]) ++
	["Try from an ANSI network",
	 {ussd2,
	  [ {send,?DIRECT_CODE},{expect,"puis 1"},
	    {send,"1"},{expect,?ACCUEIL}
	   ]}] ++

	test_util_of:close_session().

switch_smsmo_interface(enabled) ->
    [
     "Enabling SMSMOs",
     {erlang,
      [    
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost, pcontrol, enable_itfs, 
			[[io_sms_loop,possum@localhost]]]}
	  ]
     },
     {pause, 8000}
    ];

switch_smsmo_interface(disabled) ->
    [
     "Disabling SMSMOs",
     {erlang,
      [  
	 {net_adm, ping,[possum@localhost]},
	 {rpc, call, [possum@localhost, pcontrol, disable_itfs, 
		      [[io_sms_loop,possum@localhost]]]}
	]
     },
     {pause, 8000}
    ].


%%%% Fun dealing with SMSMOs

%%% Starts a smsmo queue, defined as a client for smsloop_server
smsmo_start_client() ->
    proc_lib:start_link(?MODULE, smsmo_queue_init, [self()]).

%%% Sync with the queue
smsmo_stop_client(Pid) ->
    Pid ! smsmo_stop,
    receive
	ok -> ok;
	{error,Else} -> exit(Else)
    after 3000 -> ok
    end.

%%% Register the queue as a smsloop_client
smsmo_queue_init(Parent) ->
    proc_lib:init_ack(self()),
    pong = net_adm:ping(possum@localhost), 
    ptester:start_interface(loop),
    Expected_smsmos = sms_games_test(init),
    io:format("EXPECTED SMSO ~p ~nParent:~p~n",[Expected_smsmos,Parent]),
    smsmo_queue_loop(Parent,Expected_smsmos).

%%% Main queue loop
smsmo_queue_loop(Parent,[{From,To,RegExp}=SMSMO | SMSMOs]) ->
    receive 
 	{fake_incoming_mo,#sms_incoming{da      = To,
 					deliver = #sms_deliver{dcs = DCS,
 							       oa  = From,
 							       ud  = UD}}} ->
 	    Text = gsmcharset:ud2iso(DCS, UD),
 	    case regexp:match(Text,RegExp) of
 		{match,_,_} -> 
 		    io:format("SMS-MO ~p : ok~n",[SMSMO]),
 		    smsmo_queue_loop(Parent,SMSMOs);
 		_ -> exit({smsmo_badmatch,Text,RegExp})
 	    end;

 	{fake_incoming_mo,INC} -> 
 	    exit({smsmo_unexpected,INC,instead_of,SMSMO});

 	smsmo_stop -> Parent ! {error,{smsmo_still_awaiting,[SMSMO|SMSMOs]}}

    end;

smsmo_queue_loop(Parent,[]) ->
    receive
 	smsmo_stop -> Parent ! ok;
 	{fake_incoming_mo,INC} ->
 	    Parent ! {error,{smsmo_unexpected,INC}}
    end.
