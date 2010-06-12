-module(test_123_callback).
-export([run/0,online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("profile_manager.hrl").

%%IMSI for MOBI
-define(MOBI_IMSI_OK, imsi_ok).
-define(MOBI_IMSI_INACC, imsi_inacc).
-define(MOBI_IMSI_CREDIT, imsi_credit).
-define(MOBI_IMSI_NOACC, imsi_noacc).
-define(MOBI_IMSI_EPUISE, imsi_epuise).

%% IMSI for CMO
-define(CMO_IMSI_OK,imsi_ok).

-define(CODE_RECHARGE, "2*1*1").
%% Refill by Mobicarte
-define(code_ok_default,"*12345678912301").
-define(code_ok_sms_princ,"*12345678912302").
-define(code_ok_sms_no_princ,"*12345678912303").
-define(code_ok_no_sms_princ,"*12345678912301").
-define(code_ok_weinf,"*12345678912304").
-define(code_ok_weinf_act,"*12345678912308").
-define(code_ok_europe,"*12345678912305").
-define(code_ok_maghreb,"*12345678912306").
-define(code_ok_sms_mms,"*12345678912307").
-define(code_ok_sl,"*12345678912309").
-define(code_ok_20_sl,"*12345678912312").
-define(incorrect_refill_code,"*1111").
-define(incorrect_code_after_retry,"*1*1234567890123a").
-define(msisdn_sl_actif,"9901000008").
-define(GOOD_VLR,    "38900000000"). %%Macédoine-
-define(GOOD_VLR2,   "10000000000"). %%Inconnu en Amérique
-define(BAD_VLR,     "22689002341"). %%???
-define(MING_VLR,    "21698000000").
-define(DIRECT_CODE, "#123*#").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%  Callback service is an extension of #123# for roaming users in non
%%  camel countries.
%%  In order for this service to work, we need to pass a vlr_number
%%  in the SMPP message.
%%  As we cannot do this using ptester, we use our own shortcut to 
%%  create the connection
%%  Decoding of vlr_number via smppasn_server is not tested here 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,test()).

test() ->
    %%Test title
    [{title, "Test suite for Callback."}] ++

	%%Initialization of OMA configuration parameters
 	test_util_of:set_parameter_for_test(roaming_ansi_codes,["11","10"]) ++

	%%Connection to the PRISM simulator
	switch_smpp_interface(enabled) ++

 	mobi(2) ++
   	mobi_ming(2)++

	%% enable nav keywords 8:Acceuil 9:Precedent
	test_util_of:set_parameter_for_test(sce_used, true) ++

    	cmo(2) ++
 	cmo_ming(2)++

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++
	[].

init(Subscription,IMSI_UID,VLR) ->
    profile_manager:create_default(IMSI_UID, Subscription)++
        profile_manager:init(IMSI_UID, smpp)++
	%%Initialization of OMA configuration parameters
        test_util_of:set_vlr(VLR)++
        [].

mobi(Phase) ->
    [{title, "Mobicarte Callback"}]

  	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++

	%% SUCCESS
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM OK Messagerie",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "0033777"},callback_ok()
  	  ]
  	 }
  	] ++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM OK Service client",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "+33722"},callback_ok()
  	  ]
  	 }
  	] 

    %% ERROR2 : épuisé
  	++ init("mobi",?MOBI_IMSI_EPUISE,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM: épuisé",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "1234567890"},{expect,"epuise.+recharger"},
  	   {send,"1"},{expect,"rechar"}
  	  ]
  	 }
  	]

    %% ERROR3 : inaccessible
  	++ init("mobi",?MOBI_IMSI_INACC,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM: numéro injoignable",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "1234567890"},{expect,"indisponible.+renouveler"}
  	  ]
  	 }
  	]

    %% ERROR4 : pb crédit
  	++ init("mobi",?MOBI_IMSI_CREDIT,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM: erreur crédit",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "1234567890"},{expect,"credit.+recharger"},
  	   {send, "1"},{expect,"rechar"}
  	  ]
  	 }
  	]

    %% ERROR5 : non appelable
  	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM : "
  	 "numéro non appelable",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "1234567891"},{expect,"ne pouvons pas donner suite"}
  	  ]
  	 }
  	]

    %% ERROR6
  	++ init("mobi",?MOBI_IMSI_NOACC,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM : pas acces",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "1234567890"},{expect,"pas acces"}
  	  ]
  	 }
  	]

    %% ERROR7
  	++ init("mobi",?MOBI_IMSI_OK,?BAD_VLR) ++
  	[
  	 "Connect to #123# - Mobicarte, callback -> PRISM : VLR non autorise",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "1234567890"},{expect,"pas acces"}
  	  ]
  	 }
  	]

    %% ERROR8 pays connu
   	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
   	[
   	 "Connect to #123# - Mobicarte, callback -> PRISM : acces restreint",
   	 {ussd2,
   	  [
   	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
   	   {send, "1*1"},callback_form(Phase),
   	   {send, "0987654321"},
   	   {expect,"France et Ex-Republique yougoslave de Macedoine"}
   	  ]
   	 }
   	]

    %% ERROR8 pays inconnu
 	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR2) ++
 	[
 	 "Connect to #123# - Mobicarte, callback from an ANSI network -> "
 	 "PRISM : acces restreint, pays inconnu",
 	 {ussd2,
 	  [
  	   {send, ?DIRECT_CODE},
 	   suivi_conso_mobi(Phase),
 	   {send, "1*1"},callback_form(Phase),
 	   {send, "0987654321"},{expect,"pays visité"}
 	  ]
 	 }
 	] 

%%% ERROR9
 	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR2) ++
 	[
 	 "Connect to #123# - Mobicarte, ANSI callback -> "
 	 "PRISM : appel n'aboutissant pas",
 	 {ussd2,
 	  [
	   {send, ?DIRECT_CODE},
 	   suivi_conso_mobi(Phase),
 	   {send, "1*1"},callback_form(Phase),
 	   {send, "1111111111"},{expect,"indisponible"}
 	  ]
 	 }]

    %% ERREUR INCONNUE
 	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR2) ++
 	[
 	 "Connect to #123# - Mobicarte, ANSI callback ->"
 	 " PRISM : erreur inconnue",
 	 {ussd2,
 	  [
	   {send, ?DIRECT_CODE},
 	   suivi_conso_mobi(Phase),
 	   {send, "1*1"},callback_form(Phase),
 	   {send, "TEST"},{expect,"indisponible"}
 	  ]
 	 }
 	] 

    %% Interface down
 	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR2) ++
 	[
 	 "Connect to #123# - Mobicarte, callback -> interface to PRISM down"
	] ++ 
 	switch_smpp_interface(disabled) ++ 
 	init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
 	[
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
 	   {send, "1*1"},callback_form(Phase),
 	   {send, "00330999999999"},{expect,"temporairement indisponible"}
 	  ]}
 	] ++ switch_smpp_interface(enabled) ++ 	   


	%% Interface up
 	init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
 	[
 	 "Connect to #123# - Mobicarte, callback -> PRISM OK",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
 	   {send, "1*1"},callback_form(Phase),
 	   {send, "00330999999999"},callback_ok()
 	  ]
 	 }
 	]

    %% Browsing service
 	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
 	[
 	 "Connect to #123# - Mobicarte, menu Callback -> rechargement",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
 	   {send, "2"},{expect,"recharg"}, %% should appear in all scripts
 	   {send, "9"},suivi_conso_mobi(Phase)
 	  ]
 	 }
 	] ++ test_messagerie_mobi(Phase) 
 	++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
 	[
 	 "Connect to #123# - Mobicarte, menu Callback -> Menu",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
 	   {send, "9"},suivi_conso_mobi(Phase),
  	   {send, "3"}, {expect,"Au ../.. a ..:.*"},
 	   {send, "9*9"},{send, "4"},
 	   {expect,"Pour consulter votre messagerie vocale "
 	    ": composez le 888 depuis votre mobile ou le \\+ \\(ou 00\\)"
 	    " 33608080808  depuis votre mobile ou..."}] ++
	  page_accueil_france("6",Phase)
	 }]
	++test_infos_tarifs(mobi,Phase)++ 
	init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
	[
	 "Connect to #123# - Mobicarte, menu Callback -> Messagerie",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
	   {send, "1*2"},callback_ok()
	  ]
	 }
	] ++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
	[
	 "Connect to #123# - Mobicarte, menu Callback -> Service Clients",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
	   {send, "1"},{expect,"service client"},
	   {send, "3"},callback_ok()
	  ]
	 }
	] ++ init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++
	[

	 "Connect to #123# - Mobicarte, menu Callback -> Aide",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
	   {send, "1"}
	  ] ++ aide("4",Phase)
	 }] ++

	test_util_of:close_session() ++

	["Mobicarte, Direct Callback",
	 {ussd2, [ {send, "#100*888#"},callback_ok()]},
	 {ussd2, [ {send, "#100*887#"},{expect,"composez le #100.888#"}]}
	].

mobi_ming(Phase)->
    [{title, "Mobicarte Callback"}]++
	switch_smpp_interface(enabled)++
        init("mobi",?MOBI_IMSI_OK,?MING_VLR) ++
	%% SUCCESS
        [
         "Connect to #123# - Mobicarte, callback -> PRISM OK Messagerie",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
	   {send, "1*1"},callback_form(Phase),
	   {send, "0033777"},callback_ok()
          ]
         }
        ] ++ init("mobi",?MOBI_IMSI_OK,?MING_VLR) ++
        [
         "Connect to #123# - Mobicarte, callback -> PRISM OK Service client",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send, "+33722"},callback_ok()
          ]
         }
        ]++
						%ERROR 2: equise
	init("mobi",?MOBI_IMSI_EPUISE,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> PRISM: equise",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
	   {send,"1234567890"},{expect,"epuise.+rechar"},
	   {send,"1"},{expect,"rechar"}
	  ]
         }
        ]++
	%% ERROR3 : inaccessible
	init("mobi",?MOBI_IMSI_INACC,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> PRISM: numero injoignable",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"1234567890"},{expect,"indisponible.+renouveler"}
          ]
         }
        ]++
	%% ERROR4 : pb credit
	init("mobi",?MOBI_IMSI_CREDIT,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> PRISM: erreur credit",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"1234567890"},{expect,"credit.+recharger"},
	   {send,"1"},{expect,"rechar"}
          ]
         }
        ]++
	%% ERROR5 : non appelable
	init("mobi",?MOBI_IMSI_OK,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> PRISM: numero non appelable",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"1234567891"},{expect,"ne pouvons pas donner suite"}
          ]
         }
        ]++
	%% ERROR6
	init("mobi",?MOBI_IMSI_NOACC,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> PRISM: pas acces",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"1234567890"},{expect,"pas acces"}
          ]
         }
        ]++
	%% Interface down
	switch_smpp_interface(disabled) ++
	init("mobi",?MOBI_IMSI_OK,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> interface to PRISM down",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"00330999999999"},{expect,"temporairement indisponible"}
          ]
         }
        ]++
	%% Interface up
	switch_smpp_interface(enabled) ++
	init("mobi",?MOBI_IMSI_OK,?MING_VLR) ++
	[
         "Connect to #123# - Mobicarte, callback -> PRISM OK",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"00330999999999"},callback_ok()
          ]
         }
        ]++

	[].
cmo_ming(Phase)->
    [{title, "CMO Callback"}]++
	switch_smpp_interface(enabled)++
        init("cmo",?CMO_IMSI_OK,?MING_VLR) ++

	%% SUCCESS
        [
         "Connect to #123# - CMO, callback -> PRISM OK Messagerie",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
	   {send, "1*1"},callback_form(Phase),
	   {send, "0033777"},callback_ok()
          ]
         }
        ] ++ init("cmo",?CMO_IMSI_OK,?MING_VLR) ++
        [
         "Connect to #123# - CMO, callback -> PRISM OK Service client",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send, "+33722"},callback_ok()
          ]
         }
        ]++

						%ERROR 2: equise
 	init("mobi",?MOBI_IMSI_EPUISE,?MING_VLR) ++
 	[
	 "Connect to #123# - Mobicarte, callback -> PRISM: equise",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},
 	   {expect, "1:Appeler.*"},
	   {send, "1*1"},callback_form(Phase),
 	   {send,"1234567890"},{expect,"epuise.+rechar"},
 	   {send,"1"},{expect,"rechar"}
 	  ]
	 }
	]++
 	%% ERROR3 : inaccessible
 	init("mobi",?MOBI_IMSI_INACC,?MING_VLR) ++
 	[
	 "Connect to #123# - Mobicarte, callback -> PRISM: numero injoignable",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},
 	   {expect, "1:Appeler.*"},
	   {send, "1*1"},callback_form(Phase),
	   {send,"1234567890"},{expect,"indisponible.+renouveler"}
	  ]
	 }
	]++
 	%% ERROR4 : pb credit
 	init("mobi",?MOBI_IMSI_CREDIT,?MING_VLR) ++
 	[
	 "Connect to #123# - Mobicarte, callback -> PRISM: erreur credit",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
	   {send, "1*1"},callback_form(Phase),
	   {send,"1234567890"},{expect,"credit.+recharger"},
 	   {send,"1"},{expect,"rechar"}
	  ]
	 }
	]++

	%% ERROR5 : non appelable
	init("cmo",?CMO_IMSI_OK,?MING_VLR) ++
	[
         "Connect to #123# - CMO, callback -> PRISM: numero non appelable",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"1234567891"},{expect,"ne pouvons pas donner suite"}
          ]
         }
        ]++
 	%% ERROR6
 	init("mobi",?MOBI_IMSI_NOACC,?MING_VLR) ++
 	[
	 "Connect to #123# - Mobicarte, callback -> PRISM: pas acces",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},
	   {expect, "1:Appeler.*"},
	   {send, "1*1"},callback_form(Phase),
	   {send,"1234567890"},{expect,"pas acces"}
	  ]
	 }
	]++
	%% Interface down
	switch_smpp_interface(disabled) ++
	init("cmo",?CMO_IMSI_OK,?MING_VLR) ++
	[
         "Connect to #123# - CMO, callback -> interface to PRISM down",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"00330999999999"},{expect,"temporairement indisponible"}
          ]
         }
        ]++
	%% Interface up
	switch_smpp_interface(enabled) ++
	init("cmo",?CMO_IMSI_OK,?MING_VLR) ++
	[
         "Connect to #123# - CMO, callback -> PRISM OK",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect, "1:Appeler.*"},
           {send, "1*1"},callback_form(Phase),
           {send,"00330999999999"},callback_ok()
          ]
         }
        ]++

	[].

cmo(Phase) ->
    switch_smpp_interface(enabled) ++
 	init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++
  	[
  	 {title, "CMO Callback"},  

  	 "Connect to #123# - CMO, callback -> PRISM OK",
  	 {ussd2, 
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "00330999999999"},callback_ok()
  	  ]
  	 }
  	] ++ init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - CMO, callback -> PRISM OK Messagerie",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "0033777"},callback_ok()
  	  ]
  	 }
  	] ++ init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++
  	[
  	 "Connect to #123# - CMO, callback -> PRISM OK Service client",
  	 {ussd2,
  	  [
  	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
  	   {send, "1*1"},callback_form(Phase),
  	   {send, "+33722"},callback_ok()
  	  ]
  	 }
  	] ++ 
	init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++ 
  	test_rechargement_cmo(Phase) ++
 	test_messagerie_cmo(Phase) ++ 
 	test_infos_tarifs(cmo,Phase) ++ 

 	init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++ 
 	[
 	 "Connect to #123# - CMO, menu Callback -> Menu browsing",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
 	   {send, "9"},suivi_conso_cmo(Phase),
 	   {send, "1"},{expect,"Appeler.*ma mess.*service client"},
 	   {send, "8"},{expect,"Appeler"},
 	   {send, "1*1"},callback_form(Phase),
 	   {send, "9"},{expect,"Recharger"},
 	   {send, "2"},{expect,"rechar"},
 	   {send, "9"},suivi_conso_cmo(Phase), 
 	   {send, "1"},{expect,"mess"},
 	   {send, "2"},callback_ok()
 	  ]
 	 }
 	] ++  init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++ 
 	[
 	 "Connect to #123# - CMO, menu Callback -> Service client",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
 	   {send, "1"},{expect, "service client"},
 	   {send, "3"},callback_ok()
 	  ]
 	 }
 	] ++ 

 	init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++ 

 	[
 	 "Connect to #123# - CMO, menu Callback -> Aide",
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
 	   {send, "1"},{expect, "Aide"}
 	  ] ++ aide("4",Phase)
 	 }] ++

 	test_util_of:close_session() ++

 	["CMO, Direct Callback",
 	 {ussd2,[{send, "#100*88#"},{expect,"mobicarte"}]}
 	] ++

 	init("cmo",?CMO_IMSI_OK,?GOOD_VLR2) ++
 	[
 	 "Connect to #123# - CMO, roaming from an ANSI network."
 	 " Normal roaming page is displayed",
 	 {ussd2,
 	  [{send, ?DIRECT_CODE},suivi_conso_cmo(Phase)]
 	 }
 	].       


test_infos_tarifs(mobi,2)->
    [
     "Connect to #123# - Mobicarte, menu Callback -> Infos tarifs",
     {ussd2,
      [{send, ?DIRECT_CODE},suivi_conso_mobi(2),
       {send, "9"},{expect,".*"},
       {send, "5"},
       {expect,".*"},
       {send,"111111"},
       {expect,"./*"},
       {send, "111"},
       {expect, ".*"}]
     }];
test_infos_tarifs(mobi,1) ->
    [];
test_infos_tarifs(cmo,2) ->
    [
     "Connect to #123# - Cmo, menu Callback -> Infos tarifs",
     {ussd2, 
      [
       {send, ?DIRECT_CODE},suivi_conso_cmo(2),
       {send, "6"},
       {expect,".*"},
       {send,"111111"},
       {expect,".*"},
       {send, "111"},
       {expect, ".*"}]
     }];

test_infos_tarifs(cmo,1) ->
    [].
page_accueil_france(Code,2) ->
    [{send, "9"},{expect,".*"},
     {send, Code},
     {expect,"Menu #123#.*1:Suivi Conso +.*2:Recharger.*3:decouvrir les bonus.*4:Vos bons plans.*5:Fun.*6:Nouveautes"}];
page_accueil_france(Code,1) ->
    [].

suivi_conso_mobi(2) ->
    {expect,"Vos services a l'etranger"
     ".*1:Appeler.*2:Recharger.*3:Suivi conso"
     ".*4:Utiliser votre messagerie"
     ".*5:Quel tarif dans quel pays"
     ".*6:Page accueil France"};

suivi_conso_mobi(1) ->
    {expect,"Vos services a l'etranger"
     ".*1#:Appeler.*2#:Recharger.*3#:Suivi conso"
     ".*4#:Utiliser votre messagerie.*"
     ".*5#:Quel tarif dans quel pays"}.

suivi_conso_cmo(2) ->
    {expect,"Vos services a l'etranger"
     ".*1:Appeler.*2:Recharger.*3:Suivi conso"
     ".*4:Nos services sur place"
     ".*5:Utiliser votre messagerie"
     ".*6:Quel tarif dans quel pays"
     ".*7:Page accueil France"};

suivi_conso_cmo(1) ->
    {expect,"Vos services a l'etranger"
     ".*1#:Appeler.*2#:Recharger.*3#:Suivi conso"
     ".*4#:Nos services sur place"
     ".*5#:Utiliser votre messagerie"}.

callback_ok() ->
    {expect,"mis en relation"}.


callback_form(2) ->
    {expect,"Pour appeler en France faites le 0033[+]le no "
     "de votre correspondant. Pour appeler dans le pays visite faites le "
     "00[+]indicatif pays[+]no de votre correspondant"};

callback_form(1) ->
    {expect,"Vous pouvez:."
     "Appeler en France en renvoyant le #12[*]0033[+]LeNoFrancais#."
     "Appeler un No du pays ou vous etes en renvoyant le "
     "#12[*]00[+]IndicatifDuPays[+]LeNoDuCorrespondant#"}.

test_rechargement_cmo(2=Phase) ->
    [
     "Incorrect CG code format once",
     {ussd2,
      [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
        {send, ?CODE_RECHARGE++?incorrect_refill_code++"#"},
        {expect,"Rechargement refuse"}]
     },
     "Incorrect CG code format twice",
     {ussd2,
      [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
        {send, ?CODE_RECHARGE++?incorrect_refill_code++?incorrect_code_after_retry++"#"},
        {expect,"code saisi n'est pas valide"}]
     }]++
	profile_manager:set_sachem_recharge(?CMO_IMSI_OK,#sachem_recharge{accounts=[#account{tcp_num=1,montant=21000},#account{tcp_num=?C_ASMS,montant=50,unit=?SMS}]})++
	[
	 "CG code OK, 100% SMS, SMS, PRINC",
	 {ussd2,
	  [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
	    {send, ?CODE_RECHARGE++?code_ok_sms_princ++"#"},
	    {expect,"Solde Compte Mobile.*Compte SMS"}
	   ]}]++
	profile_manager:set_sachem_recharge(?CMO_IMSI_OK,#sachem_recharge{accounts=[#account{tcp_num=1,montant=21000}]})++
	[
	 "CG code OK, 100% SMS, no SMS, PRINC",
	 {ussd2,
	  [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
	    {send, ?CODE_RECHARGE++?code_ok_no_sms_princ++"#"},
	    {expect,"Rechargement reussi.*solde de votre compte mobile"}
	   ]}]++
	profile_manager:set_sachem_recharge(?CMO_IMSI_OK,#sachem_recharge{accounts=[#account{tcp_num=?C_ASMS,montant=50,unit=?SMS}]})++
	[
	 "CG code OK, 100% SMS, SMS, no PRINC",
	 {ussd2,
	  [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
	    {send, ?CODE_RECHARGE++?code_ok_sms_no_princ++"#"},
	    {expect,"Rechargement reussi.*solde de votre compte mobile"}
	   ]}]++
	profile_manager:set_sachem_recharge(?CMO_IMSI_OK,#sachem_recharge{ttk_num=2,
									  ctk_num=35,
									  accounts=[#account{tcp_num=1,
											     montant=10000*1,
											     dlv=pbutil:unixtime()}]
									 })++
	[
	 "CG code OK, Serie Limitee, successful subscription",
	 {ussd2,
	  [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
	    {send, ?CODE_RECHARGE++?code_ok_sl++"#"},
	    {expect,"Rechargement reussi.*solde de votre compte mobile"}
	   ]}]++
	profile_manager:set_sachem_recharge(?CMO_IMSI_OK,#sachem_recharge{ttk_num=3,
                                                                          ctk_num=35,
                                                                          accounts=[#account{tcp_num=1,
                                                                                             montant=10000*2,
                                                                                             dlv=pbutil:unixtime()}]
                                                                         })++
	[
	 "CG code OK, 20 Serie Limitee, successful subscription",
	 {ussd2,
	  [ {send, ?DIRECT_CODE},suivi_conso_cmo(2),
	    {send, ?CODE_RECHARGE++?code_ok_20_sl++"#"},
	    {expect,"Rechargement reussi.*"}
	   ]}]++
	[];

test_rechargement_cmo(1) ->
    [].

test_messagerie_mobi(1) ->
    [];

test_messagerie_mobi(2 = Phase) ->
    init("mobi",?MOBI_IMSI_OK,?GOOD_VLR) ++ 
	[
	 "Connect to #123# - Mobicarte, menu Callback -> "
	 "Messagerie vocale(Phase2)",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},suivi_conso_mobi(Phase),
	   {send, "1*2"},callback_ok()
	  ]
	 }
	].



test_messagerie_cmo(1) ->
    [];

test_messagerie_cmo(2 = Phase) ->
    init("cmo",?CMO_IMSI_OK,?GOOD_VLR) ++ 
	[
	 "Connect to #123# - CMO, menu Callback -> "
	 "Messagerie vocale(Phase2)",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},suivi_conso_cmo(Phase),
	   {send, "1*2"},callback_ok()
	  ]
	 }
	].

aide(Index,2) ->
    [
     {expect,"Aide"},
     {send, Index},{expect,"Pour appeler un fixe ou un mobile francais"
		    " : composez le \\+ \\(ou 00\\) 33 et le No de votre correspondant"
		    " sans le 0 du debut."},
     {send, "1"},{expect,"Ex : mobile : \\+ \\(ou 00\\) 33 6 XX XX XX XX, fixe"
		  " : \\+ \\(ou 00\\) 33 1 XX XX XX XX. Pour appeler un fixe ou un mobile"
		  " etranger : composez le..."},
     {send, "1"},{expect,"...\\+ \\(ou 00\\) \\+ l'indicatif international"
		  " et le No de votre correspondant. Ex : pour appeler le : "
		  "07951 240 075 \\(Royaume-Uni\\),..."}
    ];

aide(_,1) ->
    [].

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
