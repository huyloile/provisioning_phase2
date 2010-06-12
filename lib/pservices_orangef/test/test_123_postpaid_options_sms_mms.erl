-module(test_123_postpaid_options_sms_mms).
-export([run/0, online/0, pages/0, links/1, parent/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").

-define(Uid, sms_mms_user).

pages()->
    [?postpaid_sms_mms, ?sms_mms_suite1].

parent(?postpaid_sms_mms) ->
    test_123_postpaid_Homepage;
parent(_) ->
    ?MODULE.

links(?postpaid_sms_mms)->
    [{?sms_30, static},
     {?sms_80, static},
     {?sms_130, static},
     {?sms_illimite, static},
     {?sms_mms_suite1, static}
    ];
links(?sms_mms_suite1)->
    [{?msn_mensuelle, static}
    ].

run() ->
    ok.
    
online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test() ->
    test_postpaid("GP") ++
	test_postpaid("PRO") ++
    
	test_util_of:close_session() ++
        ["Test reussi"] ++
    [].

test_postpaid(Type) ->
    BundleA=#spider_bundle{priorityType="A",
                           restitutionType="FORF",
                           bundleType="0005",
                           bundleDescription="label forf",
                           bundleAdditionalInfo="I1",
                           credits=[#spider_credit{name="balance",unit="MMS",value="40"}]},
    BundleB=#spider_bundle{priorityType="B",
                           restitutionType="SOLDE",
                           bundleType="1",
                           bundleDescription="Solde",
                           exhaustedLabel="Solde",
                           credits=[#spider_credit{name="balance",unit="VALEU",value="2"}]},
    BundleC=#spider_bundle{priorityType="C",
                           restitutionType="SOLDE",
                           bundleType="0005",
                           bundleDescription="TITREC|C_LIB|",
                           credits=[#spider_credit{name="balance",unit="SMS",value="10"},
                                    #spider_credit{name="rollOver",unit="SMS",value="5"}
                                   ]},
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
             {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],

    profile_manager:create_default(?Uid,"postpaid")++
        profile_manager:set_bundles(?Uid,[BundleA,BundleB,BundleC])++
        profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
        profile_manager:update_spider(?Uid,profile,{offerPOrSUid,Type})++
        profile_manager:init(?Uid)++	
	[{title, "TEST "++ Type}]++
     	[{title, "Test OPTIONS SMS/MMS - MENU"},
     	 {ussd2,
     	  [
     	   {send, test_util_of:access_code(parent(?postpaid_sms_mms), ?postpaid_sms_mms)},
     	   {expect, "Options SMS/MMS.*"
     	    "1:Option 30 SMS/MMS.*"
     	    "2:Option 80 SMS/MMS.*"
     	    "3:Option 130 SMS/MMS.*"
     	    "4:SMS/MMS illimites.*"
     	    "5:Suite.*"},
     	   {send,"5"},
     	   {expect, "Options SMS/MMS.*"
     	    "1:Orange Messenger.*"}
     	  ]}
     	]++

	test_sms_30() ++
	test_sms_80() ++
	test_sms_130() ++
	test_sms_illimite() ++
 	test_orange_messenger() ++
	[].
test_options_sms_mms_incomp_souhaitee(Code, Option)->
    profile_manager:set_asm_response(?Uid,?getImpact,#'ExceptionServiceOptionnelImpossible'{codeMessage="004"})++
	["Test " ++ Option ++ " with case Incompatibilite de l'option souhaitee avec le forfait du client",
         {ussd2,
          [{send, Code++"#"},
           {expect, ".*est incompatible avec votre offre, vous ne pouvez pas y souscrire.*Decouvrez les autres options.*1:Autres options.*."},
	   {send, "1"},
	   {expect, "Option"}
          ]}
        ]++
	profile_manager:set_asm_response(?Uid,?getImpact,{ok, []})++
	[].
test_sms_30()->
    profile_manager:set_asm_profile(?Uid,#asm_profile{code_so="NOACT"})++
 	[{title, "Test Option SMS 30"},
 	 {ussd2,
 	  [{send, test_util_of:access_code(?MODULE,?sms_30)++"#"},
 	   {expect, "30 SMS/30 MMS utilisables en SMS ou MMS pour 3E seulement par mois !.*1:Souscrire.*7:Conditions"},
 	   {send, "7"},
 	   {expect,"Options SMS/MMS indiquees en equivalent de SMS ou MMS en France metrop, hors SMS/MMS surtaxes numero courts et MMS carte postale..*1:Suite.*2:Souscrire"},
 	   {send, "1"},
 	   {expect,"Les SMS/MMS non utilises ne sont pas reportes sur le mois suivant. Deux options identiques ne se cumulent pas..*1:Suite.*2:Souscrire"},
 	   {send, "1"},
 	   {expect,"Les SMS/MMS envoyes depuis ou vers l'international ne sont pas decomptes des options SMS/MMS..*1:Souscrire"},
 	   {send, "1"},
 	   {expect, "Souscription.*Vous allez souscrire a l'option 30 SMS/30 MMS utilisables en SMS ou MMS. Vous serez facture de 3E par mois..*1:Valider"},
 	   {send, "1"},
 	   {expect, "Validation.*Vous avez souscrit a l'option 30 SMS/30 MMS a 3E/mois utilisables en SMS ou MMS. Vous serez averti de son activation par SMS."}
 	  ]}
 	] ++
	test_options_sms_mms_incomp_souhaitee(test_util_of:access_code(?MODULE,?sms_30), "Option SMS 30")++
	profile_manager:set_asm_list_options(?Uid,[#asm_option{code_so="FGR32",option_name="Option 30 SMS/MMS"}])++
	["Test Option SMS 30 - Already subscribed",
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE,?sms_30)++"#"},
	   {expect, "Souscription.*Vous souscrivez deja a Option SMS/MMS 3 euros. 2 options SMS / MMS identiques ne sont pas cumulables."}
	  ]}
	]++

	[].

test_sms_80()->
    profile_manager:set_asm_profile(?Uid,#asm_profile{code_so="NOACT"})++
	[{title, "Test Option SMS 80"},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE,?sms_80)++"#"},
	   {expect, "80 SMS/80 MMS utilisables en SMS ou MMS pour 7,5E seulement par mois !.*1:Souscrire.*7:Conditions"},
	   {send, "7"},
	   {expect,"Options SMS/MMS indiquees en equivalent de SMS ou MMS en France metrop, hors SMS/MMS surtaxes numero courts et MMS carte postale..*1:Suite.*2:Souscrire"},
	   {send, "1"},
	   {expect,"Les SMS/MMS non utilises ne sont pas reportes sur le mois suivant. Deux options identiques ne se cumulent pas..*1:Suite.*2:Souscrire"},
	   {send, "1"},
	   {expect,"Les SMS/MMS envoyes depuis ou vers l'international ne sont pas decomptes des options SMS/MMS..*1:Souscrire"},
	   {send, "1"},
	   {expect, "Souscription.*Vous allez souscrire a l'option 80 SMS/80 MMS utilisables en SMS ou MMS. Vous serez facture de 7,5E par mois..*1:Valider"},
	   {send, "1"},
	   {expect, "Validation.*Vous avez souscrit a l'option 80 SMS/80 MMS a 7,5E/mois utilisables en SMS ou MMS. Vous serez averti de son activation par SMS."}
	  ]}
	]++
	test_options_sms_mms_incomp_souhaitee( test_util_of:access_code(?MODULE,?sms_80), "Option SMS 80")++
	profile_manager:set_asm_list_options(?Uid,[#asm_option{code_so="FJ080",option_name="Option 80 SMS/MMS"}])++
        ["Test Option SMS 80 - Already subscribed",
         {ussd2,
          [{send, test_util_of:access_code(?MODULE,?sms_80)++"#"},
           {expect, "Souscription.*Vous souscrivez deja a Option SMS/MMS 7.5 euros. 2 options SMS / MMS identiques ne sont pas cumulables."}
          ]}
        ]++

	[].

test_sms_130()->
        profile_manager:set_asm_profile(?Uid,#asm_profile{code_so="NOACT"})++
	[{title, "Test Option SMS 130"},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE,?sms_130)++"#"},
	   {expect, "130 SMS/130 MMS utilisables en SMS ou MMS pour 12E seulement par mois !.*1:Souscrire.*7:Conditions"},
	   {send, "7"},
	   {expect,"Options SMS/MMS indiquees en equivalent de SMS ou MMS en France metrop, hors SMS/MMS surtaxes numero courts et MMS carte postale..*1:Suite.*2:Souscrire"},
	   {send, "1"},
	   {expect,"Les SMS/MMS non utilises ne sont pas reportes sur le mois suivant. Deux options identiques ne se cumulent pas..*1:Suite.*2:Souscrire"},
	   {send, "1"},
	   {expect,"Les SMS/MMS envoyes depuis ou vers l'international ne sont pas decomptes des options SMS/MMS..*1:Souscrire"},
	   {send, "1"},
	   {expect, "Souscription.*Vous allez souscrire a l'option 130 SMS/130 MMS utilisables en SMS ou MMS. Vous serez facture de 12E par mois..*1:Valider"},
	   {send, "1"},
	   {expect, "Validation.*Vous avez souscrit a l'option 130 SMS/130 MMS a 12E/mois utilisables en SMS ou MMS. Vous serez averti de son activation par SMS."}
	  ]}
	]++
	test_options_sms_mms_incomp_souhaitee( test_util_of:access_code(?MODULE,?sms_80), "Option SMS 130") ++
	profile_manager:set_asm_list_options(?Uid,[#asm_option{code_so="FJ130",option_name="Option 130 SMS/MMS"}])++
        ["Test Option SMS 130 - Already subscribed",
         {ussd2,
          [{send, test_util_of:access_code(?MODULE,?sms_130)++"#"},
           {expect, "Souscription.*Vous souscrivez deja a Option SMS/MMS 12 euros. 2 options SMS / MMS identiques ne sont pas cumulables."}
          ]}
        ]++

	[].

test_sms_illimite()->
    profile_manager:set_asm_profile(?Uid,#asm_profile{code_so="NOACT"})++
	[{title, "Test Option SMS illimite"},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE,?sms_illimite)++"#"},
	   {expect, "SMS/MMS illimites 24h/24 utilisables en SMS ou MMS pour 18E par mois !.*1:Souscrire.*7:Conditions"},
	   {send, "7"},
	   {expect,"Options SMS/MMS indiquees en equivalent de SMS ou MMS en France metrop, hors SMS/MMS surtaxes numero courts et MMS carte postale..*1:Suite.*2:Souscrire"},
	   {send, "1"},
	   {expect,"Les SMS/MMS envoyes depuis ou vers l'international ne sont pas decomptes des options SMS/MMS..*1:Souscrire"},
	   {send, "1"},
	   {expect, "Souscription.*Vous allez souscrire a l'option SMS/MMS illimites 24h/24 utilisables en SMS ou MMS. Vous serez facture de 18E par mois..*1:Valider"},
	   {send, "1"},
	   {expect, "Validation.*Vous avez souscrit a l'option SMS/MMS illimites 24h/24 a 18E/mois utilisables en SMS ou MMS. Vous serez averti de son activation par SMS."}
	  ]}
	]++
	test_options_sms_mms_incomp_souhaitee(test_util_of:access_code(?MODULE,?sms_illimite),"Option SMS Illimites")++
	profile_manager:set_asm_list_options(?Uid,[#asm_option{code_so="SMMS4",option_name="Option SMS Illimite"}])++
        ["Test Option SMS Illimites - Already subscribed",
         {ussd2,
          [{send, test_util_of:access_code(?MODULE,?sms_illimite)++"#"},
           {expect, "Souscription.*Vous souscrivez deja a Option SMS/MMS illimites. 2 options SMS / MMS identiques ne sont pas cumulables."}
          ]}
        ]++

	[].

test_orange_messenger()->
     profile_manager:set_asm_profile(?Uid,#asm_profile{code_so="NOACT"})++
 	[{title, "Test Option Orange Messenger"},
 	 {ussd2,
 	  [{send, test_util_of:access_code(?MODULE,?msn_mensuelle)++"#"},
 	   {expect, "OM by Windows Live.*Envoyez, recevez en illimite vos mess. depuis un mobile compatible pour 4E / mois.*1:Souscrire.*7:Conditions"},
 	   {send, "7"},
 	   {expect,"Option valable en France metropolitaine, applicable au service de messagerie instantanee Orange Messenger by Windows Live..*1:Suite.*2:Souscrire"},
 	   {send, "1"},
 	   {expect,"Envoi illimite de messages metropolitains et de fichiers photo \\(format peg ou gif\\) depuis un mobile en France metropolitaine a compter.*1:Suite.*2:Souscrire"},
 	   {send, "1"},
 	   {expect,"de la reception du sms de confirmation de souscription. Souscription de l'option au #123# \\(appel gratuit\\) ou sur internet,.*1:Suite.*2:Souscrire"},
 	   {send, "1"},
 	   {expect,"www.orange.fr >espace client >mon compte mobile > mes options, sur l'espace client wap, en point de vente.*1:Suite.*2:Souscrire"},
 	   {send, "1"},
 	   {expect,"France Telecom ou par appel au service clients. Option non disponible pour les clients mobicarte,Ten by Orange et Internet Everywhere.*1:Souscrire"},
 	   {send, "1"},
 	   {expect, "Souscription.*Vous allez souscrire a l'option mensuelle Orange Messenger by Windows Live . Vous serez facture de 4E par mois.*1:Valider"},
 	   {send, "1"},
 	   {expect, "Validation.*Vous avez souscrit a l'option mensuelle Orange Messenger by Windows Live. Vous serez averti de son activation par SMS."}
 	  ]}
 	]++
 	test_options_sms_mms_incomp_souhaitee(test_util_of:access_code(?MODULE,?msn_mensuelle), "Orange Messenger")++
 	profile_manager:set_asm_list_options(?Uid,[#asm_option{code_so="OMWL6",option_name="Orange Messenger"}])++
        ["Test Option Orange Messenger - Already subscribed",
         {ussd2,
          [{send, test_util_of:access_code(?MODULE,?msn_mensuelle)++"#"},
           {expect, "Souscription.*Vous souscrivez deja a Orange Messenger. 2 options SMS / MMS identiques ne sont pas cumulables."}
          ]}
        ]++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

