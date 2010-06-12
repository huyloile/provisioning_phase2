-module(test_133_cmo_direct_callback).
-export([run/0,online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("test_util_of.hrl").

-define(MING_VLR,    "21698000000").
-define(MING_VLR2,   "11111000000").
-define(BAD_MING_VLR,"21622002341").
-define(NOCAMEL_VLR, "21699000000").

-define(IMSI_OK, imsi_ok).
-define(IMSI_INACC, imsi_inacc).
-define(IMSI_CREDIT, imsi_credit).
-define(IMSI_NOACC, imsi_noacc).
-define(IMSI_EPUISE, imsi_epuise).

-define(DIRECT_CALLBACK_CODE, "#133").

-define(DIRECT_CALLBACK_FORM, "Callback.*Vous pouvez taper directement #133\\*00XXXXXXXXXXX# \\(n0 appele  format international\\) depuis votre mobile.*Sinon taper repondre puis le numero de votre choix").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,test()).

test() ->
    %%Connection to the PRISM simulator
    switch_smpp_interface(enabled) ++

	test_cmo_access() ++
  	test_cmo_direct_callback() ++

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++
	[].

init(Subscription,IMSI_UID,VLR) ->
    profile_manager:create_default(IMSI_UID, Subscription)++
	profile_manager:init(IMSI_UID, smpp)++
	%%Initialization of OMA configuration parameters
	test_util_of:set_parameter_for_test(vlr_prefixes_direct_callback,["21622","21698","11111"]) ++
	test_util_of:set_vlr(VLR)++
	[].


%% test_cmo_access() ->
%%     [{title, "CMO Direct Callback from non CAMEL country (adn also  not a MING country)"}] ++
%% 	%% SUCCESS
%% 	init("cmo",?IMSI_OK,?NOCAMEL_VLR) ++
%% 	test_util_of:set_parameter_for_test(roaming_camel_codes,[]) ++
%% 	test_direct_callback(with_dest,
%% 			     "PRISM OK: succes",
%% 			     "0012345678901",
%% 			     "Vous allez bientot recevoir un appel et etre mis en relation avec votre correspondant au bout de quelques secondes.")++
%% 	[].

test_cmo_access() ->
    [{title, "CMO Access Direct Callback no roaming"}] ++
        init("cmo",?IMSI_OK,"") ++
        [
         "Connect to #133# - CMO, direct callback whith destination number -> NO ROAMING: not allowed",
         {ussd2,
          [
           {send, ?DIRECT_CALLBACK_CODE++"*0012345678901"},
           {expect, "Vous n'avez pas acces a ce service."}
          ]
         }
        ]++

        [
         "Connect to #133# - CMO, direct callback whithout destination number -> NO ROAMING: not allowed",
         {ussd2,
          [
           {send, ?DIRECT_CALLBACK_CODE},
           {expect, "Vous n'avez pas acces a ce service."}
          ]
         }
        ]++


    [{title, "CMO Access Direct Callback with roaming"}] ++
        %% SUCCESS
        init("cmo",?IMSI_OK,?NOCAMEL_VLR) ++
        test_util_of:set_parameter_for_test(roaming_camel_codes,[]) ++
        test_direct_callback(with_dest,
                             "PRISM OK: succes",
                             "0012345678901",
                             "Vous allez bientot recevoir un appel et etre mis en relation avec votre correspondant au bout de quelques secondes.")++
        test_direct_callback(without_dest,
                             "PRISM OK: succes",
                             "0012345678901",
                             "Vous allez bientot recevoir un appel et etre mis en relation avec votre correspondant au bout de quelques secondes.")++
        [].


test_cmo_direct_callback() ->
    [{title, "CMO Direct Callback"}] ++

	%% SUCCESS
	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM OK: succes",
			     "0012345678901",
			     "Vous allez bientot recevoir un appel et etre mis en relation avec votre correspondant au bout de quelques secondes.")++

	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM OK: succes",
			     "0012345678901",
			     "Vous allez bientot recevoir un appel et etre mis en relation avec votre correspondant au bout de quelques secondes.")++

	%% ERROR2 : epuise
	init("cmo",?IMSI_EPUISE,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR2: epuise",
			     "0012345678901",
			     "Votre credit est epuise/insuffisant.Pour pouvoir appeler veuillez recharger votre compte.")++

	init("cmo",?IMSI_EPUISE,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR2: epuise",
			     "0012345678901",
			     "Votre credit est epuise/insuffisant.Pour pouvoir appeler veuillez recharger votre compte.")++

	%% ERROR3 : inaccessible
	init("cmo",?IMSI_INACC,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR3: numero injoignable",
			     "0012345678901",
			     "Le service est momentanement indisponible. Veuillez renouveler votre appel au #133# ulterieurement.") ++

	init("cmo",?IMSI_INACC,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR3: numero injoignable",
			     "0012345678901",
			     "Le service est momentanement indisponible. Veuillez renouveler votre appel au #133# ulterieurement.") ++

	%% ERROR4 : pb crédit
	init("cmo",?IMSI_CREDIT,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR4: erreur credit",
			     "0012345678901",
			     "Votre credit est epuise/insuffisant.Pour pouvoir appeler veuillez recharger votre compte.") ++

	init("cmo",?IMSI_CREDIT,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR4: erreur credit",
			     "0012345678901",
			     "Votre credit est epuise/insuffisant.Pour pouvoir appeler veuillez recharger votre compte.") ++

	%% ERROR5 : non appelable
	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR5: numero non appelable",
			     "0012345678910",
			     "Nous ne pouvons pas donner suite a votre appel.Ce numero est inaccessible depuis l'etranger.") ++

	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR5: numero non appelable",
			     "0012345678910",
			     "Nous ne pouvons pas donner suite a votre appel.Ce numero est inaccessible depuis l'etranger.") ++

	%% ERROR6
	init("cmo",?IMSI_NOACC,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR6: pas acces",
			     "0012345678901",
			     "Vous n'avez pas acces a ce service.") ++

	init("cmo",?IMSI_NOACC,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR6: pas acces",
			     "0012345678901",
			     "Vous n'avez pas acces a ce service.") ++

	%% ERROR7
	init("cmo",?IMSI_OK,?BAD_MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR7: VLR non autorise",
			     "0012345678901",
			     "Vous n'avez pas acces a ce service.") ++

	init("cmo",?IMSI_OK,?BAD_MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR7: VLR non autorise",
			     "0012345678901",
			     "Vous n'avez pas acces a ce service.") ++

	%% ERROR8 pays connu
	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR8: VLR acces restreint, pays connu",
			     "0098765432190",
			     "Vous ne pouvez passer d'appels que vers les pays suivants : France et Tunisie") ++

	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR8: VLR acces restreint, pays connu",
			     "0098765432190",
			     "Vous ne pouvez passer d'appels que vers les pays suivants : France et Tunisie") ++

	%% ERROR8 pays inconnu
	init("cmo",?IMSI_OK,?MING_VLR2) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR8: VLR acces restreint, pays inconnu",
			     "0098765432190",
			     "Vous ne pouvez passer d'appels que vers la France et le pays visite") ++

	init("cmo",?IMSI_OK,?MING_VLR2) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR8: VLR acces restreint, pays inconnu",
			     "0098765432190",
			     "Vous ne pouvez passer d'appels que vers la France et le pays visite") ++

	%% ERROR9
	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM ERROR9: appel n'aboutissant pas",
			     "0011111111111",
			     "Le service est momentanement indisponible. Veuillez renouveler votre appel au #133# ulterieurement.") ++

	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM ERROR9: appel n'aboutissant pas",
			     "0011111111111",
			     "Le service est momentanement indisponible. Veuillez renouveler votre appel au #133# ulterieurement.") ++


	%% ERREUR INCONNUE
	init("cmo",?IMSI_OK,?MING_VLR2) ++
	test_direct_callback(without_dest,
			     "PRISM: erreur inconnue",
			     "TEST",
			     "Ce service est temporairement indisponible") ++

	init("cmo",?IMSI_OK,?MING_VLR2) ++
	test_direct_callback(with_dest,
			     "PRISM: erreur inconnue",
			     "TEST",
			     "Ce service est temporairement indisponible") ++

	%% Interface down
	switch_smpp_interface(disabled) ++ 
	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(without_dest,
			     "PRISM: interface to PRISM down",
			     "0012345678901",
			     "Ce service est temporairement indisponible") ++

	init("cmo",?IMSI_OK,?MING_VLR) ++
	test_direct_callback(with_dest,
			     "PRISM: interface to PRISM down",
			     "0012345678901",
			     "Ce service est temporairement indisponible") ++
	switch_smpp_interface(enabled) ++ 	   

	test_util_of:close_session() ++
	[].

test_direct_callback(with_dest, Title, Dest, Expect) ->
    [
     "Connect to #133# - CMO, direct callback whith destination number -> "++Title,
     {ussd2,
      [
       {send, ?DIRECT_CALLBACK_CODE++"*"++Dest++"#"},
       {expect,Expect}
      ]
     }
    ];

test_direct_callback(without_dest, Title, Dest, Expect) ->
    [
     "Connect to #133# - CMO, direct callback whithout destination number -> "++Title,
     {ussd2,
      [
       {send, ?DIRECT_CALLBACK_CODE},
       {expect, ?DIRECT_CALLBACK_FORM},
       {send, Dest},
       {expect,Expect}
      ]
     }
    ].

switch_smpp_interface(enabled) ->
    [
     "Enabling SMPP interface to Cellgate",
     {erlang,
      [    
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost, pcontrol, enable_itfs, 
			[[io_ussd_cellgate_pullinit,possum@localhost]]]}
	  ]
     },
     {erlang,
      [    
	   {erlang, spawn,[prism,start,[]]}
	  ]
     },
     {pause, 6000}
    ];

switch_smpp_interface(disabled) ->
    [
     "Disabling SMPP interface to Cellgate",
     {erlang,
      [  
	 {net_adm, ping,[possum@localhost]},	
	 {rpc, call, [possum@localhost, pcontrol, disable_itfs, 
		      [[io_ussd_cellgate_pullinit,possum@localhost]]]}
	]
     },
     {pause, 10000}
    ].
