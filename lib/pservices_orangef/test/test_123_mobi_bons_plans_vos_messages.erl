-module(test_123_mobi_bons_plans_vos_messages).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

pages() ->
    [?vos_messages, ?option_SMS, ? option_OM_by_WL].

parent(?vos_messages) ->
    test_123_mobi_homepage;
parent(_) ->
    ?MODULE.

links(?vos_messages)->
    [
     {?umobile_soiree_SMS_illimite, dyn},
     {?umobile_soiree_SMS, dyn},
     {?option_SMS, static},
     {?option_MMS , dyn},
     {?option_OM_by_WL, static},
     {?options_SMS_MMS_infos, static}
    ];
links(Else) ->
    io:format("~p : links of this page ~p are not defined~n",[?MODULE, Else]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid, mobi_user).

get_vos_messages_dyn_links(DCL) ->
    case DCL of
	?mobi ->
	    [?recharger, ?suivi_conso_plus_menu, ?mobi_bonus, ?exclusives];
	?OL_mobile ->
	    [?recharger, ?suivi_conso_plus_menu, ?foot_variable_x, ?soirees, ?exclusives];
	?click_mobi ->
	    [?recharger, ?exclusives];
	?m6_prepaid ->
	    [?recharger]
    end.

code_vos_messages(DCL) ->
    Dyn_links = get_vos_messages_dyn_links(DCL),
    test_util_of:access_code(test_123_mobi_homepage, ?vos_messages, Dyn_links).

code_vos_messages_options_sms(DCL)->
    code_vos_messages(DCL)++ "1".

code_vos_messages_options_mms(DCL)->
    code_vos_messages(DCL)++ "2".

code_vos_messages_options_omwl(DCL)->
    code_vos_messages(DCL)++ "2".

code_opt_sms_quoti(DCL) ->
    "2".
code_opt_sms_mensu(DCL) ->
    "5".

code_opt_jsms_ill(DCL) ->
    "3".

code_opt_ssms_ill(DCL) ->
    "4".

code_opt_message_ill(DCL) ->
    "5".

code_opt_journee_OMWL(DCL) ->
    "1".

code_opt_mensu_OMWL(DCL) ->
    "2".

code_opt_30_SMS_MMS(DCL) ->
    "1".

online() ->
    test_util_of:online(?MODULE,test()).
test() ->
    test_vos_messages_menu([?mobi, ?OL_mobile, ?click_mobi, ?m6_prepaid]) ++
  	test_menu_options_sms([?mobi,
     			       ?OL_mobile,
     			       ?click_mobi,
     			       ?m6_prepaid]) ++
	lists:append([test_vos_messages_option(Opt,DCL,Type)||
			 Opt<-[ 
                  {opt_sms_quoti,"Option SMS quotidienne"},
  				{opt_sms_mensu,"Option sms mensuelle"},
  				{opt_jsms_illimite,"Option journee sms illimites"},
  				{opt_ssms_illimite,"Option soiree sms illimites"},
  				{opt_sms_illimite,"Option message illimites"},
  				{opt_mms_mensu,"Option MMS"},
 				{opt_msn_journee_mobi,"Option Journee OM by WL"},
 				{opt_msn_mensu_mobi,"Option Mensuelle OM by WL"},
				{opt_30_sms_mms,"Options 30 SMS/MMS"}
			       ],
			 DCL<-[?mobi,
			       ?OL_mobile,
			       ?click_mobi,
			       ?m6_prepaid],
			 Type<-[souscription,
				suppression,
				reactivation,
				conditions,
				incompatible,
				low_credit,
				heure_fermeture]])++

	["Test reussi"].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_vos_messages_menu([]) -> [];
test_vos_messages_menu([DCL|T]) ->
    init_test(DCL)++
	init_sachem()++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Menu - DCL = " ++integer_to_list(DCL)++" ####</center>"},
 	 "Test Menu vos messages Options MMS not actived",
 	 {ussd2,
 	  [
 	   {send, code_vos_messages(DCL)},
 	   {expect, "Bons plans messages."
 	    "1:Option SMS."
 	    "2:Option OM by WL."
 	    "3:Options SMS/MMS infos.*"}
 	  ]}] 
 	++
	test_util_of:close_session()++

	case DCL of
	    ?m6_prepaid ->
		[];
	    _ ->
		init_sachem(opt_mms_mensu, active)++
		    init_compte(opt_mms_mensu, ?CETAT_AC)++
		    ["Test Menu vos messages Options MMS actived",
		     {ussd2,
		      [
		       {send, code_vos_messages(DCL)},
		       {expect, "Bons plans messages."
			"1:Option SMS."
			"2:Option 10MMS."
			"3:Option OM by WL."
			"4:Options SMS/MMS infos.*"}
		      ]}] 
		    ++
		    test_util_of:close_session()++

		    init_sachem(opt_mms_mensu, suspend)++
		    init_compte(opt_mms_mensu, ?CETAT_AC)++
		    [{title, "Test Menu vos messages Options MMS suspend"},
		     {ussd2,
		      [ 
			{send, code_vos_messages(DCL)},
			{expect,"Bons plans messages."
			 "1:Option SMS."
			 "2:Option 10MMS."
			 "3:Option OM by WL."
			 "4:Options SMS/MMS infos.*"}
		       ]}]++
		    test_util_of:close_session()
	end++

 	init_sachem()++
	init_compte() ++
	[{title, "<center>#### Vos Messages - Options SMS Menu - DCL = " ++integer_to_list(DCL)++" ####</center>"},
	 "Test SMS Menu vos messages",
	 {ussd2,
	  [
	   {send, code_vos_messages_options_sms(DCL)},
	   {expect, "Options SMS."
	    "1:30 SMS/MMS."
	    "2:bon plan SMS quotidien."
	    "3:Journee SMS Illimites."
	    "4:Soiree SMS illimites"}
	  ]}]++
	test_util_of:close_session()++
	test_vos_messages_menu(T).

test_menu_options_sms([]) -> [];
test_menu_options_sms([DCL|T]) ->
    init_test(DCL)++
	init_sachem()++
        init_compte() ++
        [{title, "<center>#### Vos Messages - Options SMS Menu - DCL = " ++integer_to_list(DCL)++" ####</center>"},
         "Test SMS Menu vos messages",
         {ussd2,
          [
           {send, code_vos_messages_options_sms(DCL)},
           {expect, "Options SMS."
            "1:30 SMS/MMS.*"
            "2:bon plan SMS quotidien."
            "3:Journee SMS Illimites."
            "4:Soiree SMS illimites"}
          ]}]++
	test_util_of:close_session()++

	case DCL of
	    ?m6_prepaid ->
		[];
	    _ ->
		init_sachem(opt_sms_mensu, suspend)++
		    init_compte(opt_sms_mensu, ?CETAT_AC)++
		    ["Test Menu vos messages SMS mensu suspendu",
		     {ussd2,
		      [ 
			{send, code_vos_messages_options_sms(DCL)},
			{expect, 
			 "Options SMS."
			 "1:bon plan SMS quotidien."
			 "2:Journee SMS Illimites."
			 "3:Soiree SMS illimites."
                         "4:30 SMS/MMS."
			 "5:Option SMS mensuelle.*"}
		       ]}]++
		    test_util_of:close_session()++

		    init_sachem(opt_sms_mensu, active)++
		    init_compte(opt_sms_mensu, ?CETAT_AC)++
		    ["Test Menu vos messages SMS mensu active",
		     {ussd2,
		      [
		       {send, code_vos_messages_options_sms(DCL)},
		       {expect, 
			 "Options SMS."
			 "1:bon plan SMS quotidien."
			 "2:Journee SMS Illimites."
			 "3:Soiree SMS illimites."
                         "4:30 SMS/MMS."
			 "5:Option SMS mensuelle.*"}
		      ]}]++
		    test_util_of:close_session()++

		    init_sachem(opt_sms_illimite, active)++
		    init_compte(opt_sms_illimite, ?CETAT_AC)++
		    ["Test Menu vos messages Message Illimite active",
		     {ussd2,
		      [ 
			{send, code_vos_messages_options_sms(DCL)},
			{expect,
			 "Options SMS."
                         "1:30 SMS/MMS.*"
			 "2:bon plan SMS quotidien."
			 "3:Journee SMS Illimites."
			 "4:Soiree SMS illimites."
			 "5:Messages illimites"}
		       ]}] ++
		    test_util_of:close_session()++

		    init_sachem(opt_sms_illimite, suspend)++
		    init_compte(opt_sms_illimite, ?CETAT_AC)++
		    ["Test Menu vos messages Message Illimite supendu",
		     {ussd2,
		      [ 
			{send, code_vos_messages_options_sms(DCL)},
			{expect,
			 "Options SMS."
                         "1:30 SMS/MMS.*"
			 "2:bon plan SMS quotidien."
			 "3:Journee SMS Illimites."
			 "4:Soiree SMS illimites."
			 "5:Messages illimites"}
		       ]}]++
		    test_util_of:close_session()
	end++
	test_menu_options_sms(T).

test_vos_messages_option({opt_sms_quoti,_},DCL,souscription)->
    init_test(DCL)++
	init_sachem()++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Options SMS - Option SMS quotidienne - DCL="++integer_to_list(DCL)++" ####</center>"},
	 "Test Option SMS quotidienne - Souscription",
	 {ussd2,
	  [{send,code_vos_messages_options_sms(DCL)},
	   {expect,".*"}, 
	   {send, code_opt_sms_quoti(DCL)},
	   {expect,"Vos SMS a petit prix tous les jours ?"},
	   {send,"1"},
	   {expect,"Vous beneficiez de 6 SMS ou MMS par jour pour seulement 0,50E."},
	   {send,"8"},
	   {expect,"Vos SMS a petit prix tous les jours ?"},
	   {send,"11"},
	   {expect,"Une seule souscription suffit pour profiter simplement de 6 SMS ou MMS"},
	   {send,"1"},
	   {expect,"C'est simple : vous supprimez votre option quand vous le souhaitez"},    	    
	   {send,"1"},
	   {expect,"Vous allez souscrire au bon plan SMS quotidien pour 0,5E"},
	   {send,"1"},
	   {expect,"Vous avez souscrit au bon plan SMS quotidien pour 0,5E. Ce montant a ete preleve de votre compte.*"
	   },
	   {send,"1"},
	   {expect,"Dans quelques instants, votre bon plan SMS quotidien sera active.*"
	   } 
	  ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_quoti,_},DCL,conditions)->
    init_sachem(opt_sms_quoti, active)++
 	init_compte(opt_sms_quoti, ?CETAT_AC)++
 	[{title, "<center>#### Vos Messages - Options SMS - Option SMS quotidienne ACTIVEE - DCL="++integer_to_list(DCL)++" ####</center>"},
	 "TEST MENTIONS LEGALES",
  	 {ussd2,
  	  [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"}, 
	    {send, code_opt_sms_quoti(DCL)},
	    {expect,".*"},
	    {send,"7"},
   	    {expect,"Offre valable en France metropolitaine"},
   	    {send,"1"},
   	    {expect,"...et decomptes sur la base d'1 MMS=1 SMS"},
   	    {send,"1"},
   	    {expect,"..lors du renouvellement quotidien de l'option sous reserve que le credit soit positif"},
   	    {send,"1"},
  	    {expect,"reprend automatiquement des que le credit est a nouveau suffisant"},
   	    {send,"1"},
   	    {expect,"Le renouvellement quotidien de l'option est effectue chaque jour entre 23h00 et 1h00"}
  	   ]
  	 }
  	] ++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_quoti,_},DCL,supression)->
    init_sachem(opt_sms_quoti, active)++
	init_compte(opt_sms_quoti, ?CETAT_AC)++
	["TEST RESILIATION OPTION SMS QUOTIDIEN : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL SUFFISANT\n"
	 "Client:MOBICARTE - Compte principal:actif - Solde=50E - Option existante:SMS quotidien",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"}, 
	    {send, code_opt_sms_quoti(DCL)},
	    {expect,"Votre bon plan SMS quotidien est actuellement active et vous beneficiez de 6 SMS ou MMS par jour pour seulement 0,50E."},
	    {send,"1"},
	    {expect,"Il vous reste .* SMS a utiliser jusqu'au ../... "
	     "Si vous supprimez votre bon plan SMS quotidien maintenant vous ne pourrez pas en beneficier."},  
  	    {send,"1"},
  	    {expect,"Merci de confirmer la suppression de votre bon plan SMS quotidien"}
 	   ]
	 }] ++
	test_util_of:close_session()++

	init_sachem(opt_sms_quoti, active)++
	init_compte(opt_sms_quoti, ?CETAT_EP)++
	["TEST RESILIATION OPTION SMS QUOTIDIEN : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL INSUFFISANT\n"
	 "Client:MOBICARTE - Compte principal:actif - Solde Epuise - Option existante:SMS quotidien",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"}, 
	    {send, code_opt_sms_quoti(DCL)},
 	    {expect,"Votre bon plan SMS quotidien est actuellement active"},	    
	    {send,"11"},
  	    {expect,"La suppression de votre bon plan SMS quotidien a bien ete prise en compte"}
 	   ]
	 }] ++
	test_util_of:close_session()++

	init_sachem(opt_sms_quoti, suspend)++
	init_compte(opt_sms_quoti, ?CETAT_AC)++
	[{title, "<center>#### Vos Messages - Options SMS - Option SMS quotidienne SUSPENDUE - DCL="++integer_to_list(DCL)++" ####</center>"},
	 "TEST RESILIATION OPTION SMS QUOTIDIEN : CAS OPTION SUSPEND\n"
	 "Client:MOBICARTE - Compte principal:suspend - Option existante:SMS quotidien",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"}, 
	    {send, code_opt_sms_quoti(DCL)},
 	    {expect,"Votre bon plan SMS quotidien est actuellement active"},	    
	    {send,"1"},
	    {expect,"Il vous reste .* SMS a utiliser jusqu'au ../... "
	     "Si vous supprimez votre bon plan SMS quotidien maintenant vous ne pourrez pas en beneficier."},
  	    {send,"1"},
  	    {expect,"Merci de confirmer la suppression de votre bon plan SMS quotidien"}
 	   ]
	 }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_mensu,_},?m6_prepaid,_)->
    [];
test_vos_messages_option({opt_sms_mensu,_},DCL,conditions)->
    init_test(DCL) ++
	init_sachem(opt_sms_mensu, active)++
	init_compte(opt_sms_mensu, ?CETAT_AC)++
	[{title, "<center>#### Vos Messages - Options SMS - Option SMS mensuelle ACTIVEE - DCL="++integer_to_list(DCL)++" ####</center>"},
	 "TEST OPTION SMS MENSUELLE : Mentions legales Suppression",
         {ussd2,
          [
           {send,code_vos_messages_options_sms(DCL)},
           {expect,".*"},
	   {send, code_opt_sms_mensu(DCL)},
           {expect,".*"},
           {send,"7"},
	   {expect,"Offre valable en France metropolitaine"},
	   {send,"1"},
	   {expect,"30 SMS valables un mois et utilisables en MMS"},
	   {send,"1"},
	   {expect,"...d'1 MMS=3 SMS"},
	   {send,"1"},
	   {expect,"En cas de credit insuffisant,l'option sera suspendue"},
	   {send,"1"},
	   {expect,"Les SMS non utilises dans le mois ne sont pas reportes sur la periode suivante"},
	   {send,"1"},
	   {expect,"Le client est informe qu'a compter de la resiliation"},
	   {send,"1"},
	   {expect,"Option non compatible avec l'option SMS quotidienne"}
	  ]
         }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_mensu,_},DCL,suppression)->
    init_test(DCL) ++
	init_sachem(opt_sms_mensu, active)++
	init_compte(opt_sms_mensu, ?CETAT_AC)++
	["TEST RESILIATION OPTION SMS MENSUELLE : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL SUFFISANT DCL= "++integer_to_list(DCL)++"\n"
	 "Client:MOBICARTE - Compte principal:actif - Solde=50E - Option existante:SMS mensu",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
            {send,code_opt_sms_mensu(DCL)},
 	    {expect,"Votre option SMS mensuelle est actuellement activee. Vous beneficiez de 30 SMS valables un mois pour 3E"},
	    {send,"1"},
  	    {expect,"Il vous reste .*SMS a utiliser jusqu'au.*Si vous supprimez votre option SMS mensuelle maintenant vous ne pourrez pas beneficier de ces SMS"},
  	    {send,"1"},
  	    {expect,"Merci de confirmer la suppresion de votre option SMS mensuelle"}
 	   ]
	 }] ++
	test_util_of:close_session()++

	init_sachem(opt_sms_mensu, active)++
	init_compte(opt_sms_mensu, ?CETAT_EP)++
	["TEST RESILIATION OPTION SMS MENSUELLE : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL INSUFFISANT\n"
	 "Client:MOBICARTE - Compte principal:actif - Solde epuise - Option existante:SMS mensu",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_sms_mensu(DCL)},
 	    {expect,"Votre option SMS mensuelle est actuellement activee. Vous beneficiez de 30 SMS valables un mois pour 3E"},
	    {send,"1"},
  	    {expect,"Merci de confirmer la suppresion de votre option SMS mensuelle"},
  	    {send,"1"},
  	    {expect,"La suppression de votre option SMS mensuelle a bien ete prise en compte.*"
	    }
 	   ]
	 }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_mensu,_},DCL,reactivation)->
    init_sachem(opt_sms_mensu, suspend)++
	init_compte(opt_sms_mensu, ?CETAT_AC)++
	[{title, "<center>#### Vos Messages - Options SMS - Option SMS mensuelle SUSPENDUE - DCL="++integer_to_list(DCL)++" ####</center>"},
	 "TEST OPTION SMS MENSUELLE : Mentions legales Reactivation",
         {ussd2,
          [{send,code_vos_messages_options_sms(DCL)},
           {expect,".*"},
	   {send, code_opt_sms_mensu(DCL)},
           {expect,".*"},
           {send,"7"},
	   {expect,"Offre valable en France metropolitaine"},
	   {send,"1"},
	   {expect,"30 SMS valables un mois et utilisables en MMS"},
	   {send,"1"},
	   {expect,"...d'1 MMS=3 SMS"},
	   {send,"1"},
	   {expect,"En cas de credit insuffisant,l'option sera suspendue"},
	   {send,"1"},
	   {expect,"Les SMS non utilises dans le mois ne sont pas reportes sur la periode suivante"},
	   {send,"1"},
	   {expect,"Le client est informe qu'a compter de la resiliation"},
	   {send,"1"},
	   {expect,"Option non compatible avec l'option SMS quotidienne"}
	  ]
         }] ++
	test_util_of:close_session()++

	["TEST REACTIVATION OPTION SMS MENSUELLE : CAS OPTION SUSPEND\n"
	 "Client:MOBICARTE - Compte principal:suspend - Option existante:SMS mensu",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_sms_mensu(DCL)},
 	    {expect,"Votre Option SMS mensuelle est suspendue"},	    
	    {send,"1"},
  	    {expect,"Vous allez reactiver votre option SMS mensuelle pour 3E"},  
  	    {send,"1"},
  	    {expect,"La reactivation de votre Option SMS mensuelle a bien ete prise en compte.*"
	    }
 	   ]
	 }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_jsms_illimite,_},DCL,suppression)->
    [];
test_vos_messages_option({opt_jsms_illimite,_},DCL,souscription)->
    init_test(DCL)++
	init_sachem()++
	init_compte() ++
	set_present_period([opt_jsms_illimite])++
	set_in_hour_range([opt_jsms_illimite])++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Journee SMS Illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Journee SMS Illimites Souscription",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_jsms_ill(DCL)},
	    {expect,"Decouvrez le bon plan journee SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 journee de 8h a 20h vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"},
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Journee SMS illimites pour 2,50E.*"
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Vous avez souscrit au bon plan Journee SMS illimites pour 2,50E.*"
	     "1:Suite.*"},
    	    {send,"1"},
    	    {expect,"Dans quelques instants, votre bon plan sera active.*"
	    }
 	   ]
    	 }
    	]++
	test_util_of:close_session()++

	init_sachem()++
        init_compte() ++
	test_util_of:set_parameter_for_test(list_bank_holidays,
					    [{opt_jsms_illimite, [{svc_util_of:local_time(),
								   {svc_options:today_plus_datetime(7),{23,59,59}}}]}])++
	["Test Option Journee SMS Illimites Souscription - List bank holidays",
         {ussd2,
          [{send,code_vos_messages_options_sms(DCL)},
           {expect,".*"},
	   {send, code_opt_jsms_ill(DCL)},
	   {expect,"Decouvrez le bon plan journee SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 journee de 8h a 20h vers tous les operateurs.*"
	    "1:Souscrire.*"
	    "7:Conditions.*" },
	   {send,"1"},
	   {expect,"Vous allez souscrire au bon plan Journee SMS illimites pour 2,50E.*"
	    "1:Valider.*"},
	   {send,"1"},
	   {expect,"Vous avez souscrit au bon plan Journee SMS illimites pour 2,50E.*"
	    "1:Suite.*"},
	   {send,"1"},
	   {expect,"Dans quelques instants, votre bon plan sera active.*"
	   }
	  ]
         }
        ]++
	test_util_of:close_session();

test_vos_messages_option({opt_jsms_illimite,_},DCL,conditions)->
    init_test(DCL)++
        init_sachem()++
        init_compte() ++
	set_present_period([opt_jsms_illimite])++
	[{title, "<center>#### Vos Messages - Options SMS - Option Journee SMS Illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Journee SMS Illimites - Mentions Legales",
	 {ussd2,
	  [{send,code_vos_messages_options_sms(DCL)},
           {expect,".*"},
	   {send, code_opt_jsms_ill(DCL)},
	   {expect, ".*"},
	   {send, "7"},
	   {expect,"SMS/MMS illimites vers les mobiles en France metropolitaine de 8h a 20h dans la limite de 200 destinataires differents par journee.*1:Suite"},
	   {send,"1"},
	   {expect,"Option valable le jour de la souscription. Hors SMS/MMS surtaxes et MMS cartes postales et numeros courts. SMS/MMS entre personnes physiques...*1:Suite"},
	   {send,"1"},
	   {expect,"et pour un usage personnel non lucratif direct. Option valable en France metropolitaine et reservee aux clients mobicarte.*1:Suite"},
	   {send,"1"},
	   {expect, "Le prix de l'option est preleve sur le compte du client sous reserve d'un credit suffisant. Souscription possible le jour meme de 02h a 19h45.*1:Suite"},
	   {send, "1"},
	   {expect, "MMS disponibles entre terminaux compatibles."},
	   {send, "1"},
	   {expect,"Vous allez souscrire au bon plan Journee SMS illimites pour 2,50E"}
	  ]
	 }]++
	test_util_of:close_session();

test_vos_messages_option({opt_jsms_illimite,_},DCL,low_credit)->
    init_test(DCL)++
	init_compte(opt_jsms_illimite, ?CETAT_AC, 2000) ++
	set_present_period([opt_jsms_illimite])++
	set_in_hour_range([opt_jsms_illimite])++
	profile_manager:set_list_options(?Uid, [#option{top_num=0},
					        #option{top_num=391}])++
        profile_manager:set_sachem_response(?Uid,{?maj_op,{error, "solde_insuffisant"}})++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Journee SMS Illimites - DCL = "++integer_to_list(DCL)++"  ####</center>"},
	 "Test Option Journee SMS Illimites - Low credit",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"},

	    {send, code_opt_jsms_ill(DCL)},
	    {expect,"Decouvrez le bon plan journee SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 journee de 8h a 20h vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"
	    },
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Journee SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Bonjour, pour souscrire au bon plan Journee SMS illimites vous devez disposer de 2,50E sur votre compte. Orange vous remercie de votre appel"}
 	   ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_jsms_illimite,_},DCL,heure_fermeture)->
    init_test(DCL)++
	init_sachem()++
	init_compte() ++
	set_present_period([opt_jsms_illimite])++
	set_out_hour_range([opt_jsms_illimite])++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Journee SMS Illimites - DCL = "++integer_to_list(DCL)++"  ####</center>"},
	 "Test Option Journee SMS Illimites - Heure fermeture",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_jsms_ill(DCL)},
	    {expect,"Decouvrez le bon plan journee SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 journee de 8h a 20h vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"
	    },
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Journee SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Desole, la souscription a l'option Journee SMS Illimites est actuellement fermee.*"
	     "Profitez des autres bons plans.*1:Autres bons plans"}
 	   ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_jsms_illimite,_},DCL,incompatible)->
    init_test(DCL)++
        init_compte(opt_jsms_illimite, ?CETAT_AC, 30000) ++
	set_present_period([opt_jsms_illimite])++
	set_in_hour_range([opt_jsms_illimite])++
        profile_manager:set_sachem_response(?Uid,{?maj_op,{error, "option_incompatible_opt"}})++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Journee SMS Illimites - DCL = "++integer_to_list(DCL)++"  ####</center>"},
	 "Test Option Journee SMS Illimites - Options incompatibles",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_jsms_ill(DCL)},
	    {expect,"Decouvrez le bon plan journee SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 journee de 8h a 20h vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"
	    },
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Journee SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Vous disposez d'une option \\(SMS quoti. ou Duo Journee\\) incompatible avec le bon plan Journee SMS illimites. Pour beneficier de celui-ci, supprimez l'option.*Merci de votre appel"}
 	   ]
    	 }
    	]++
	test_util_of:close_session();


test_vos_messages_option({opt_ssms_illimite,_},DCL,souscription)->
    init_test(DCL)++
	init_sachem()++
	init_compte() ++
	set_present_period([opt_ssms_illimite])++
	set_in_hour_range([opt_ssms_illimite])++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Soiree SMS Illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Soiree SMS Illimites Souscription",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
            {send, code_opt_ssms_ill(DCL)},
	    {expect,"Decouvrez le bon plan soiree SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 soiree de 21h a 23h59 vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"
	    },
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Soiree SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Vous avez souscrit au bon plan Soiree SMS illimites pour 2,50E. Ce montant a ete debite de votre compte.*9:Accueil"}
 	   ]
    	 }
    	] ++
	test_util_of:close_session()++

        init_test(DCL)++
	test_util_of:set_parameter_for_test(list_bank_holidays,
					    [{opt_ssms_illimite, [{svc_util_of:local_time(),
								   {svc_options:today_plus_datetime(7),{23,59,59}}}]}])++
        ["Test Option Soiree SMS Illimites Souscription - List bank holiday",
         {ussd2,
          [{send,code_vos_messages_options_sms(DCL)},
           {expect,".*"},
	   {send, code_opt_ssms_ill(DCL)},
	   {expect,"Decouvrez le bon plan soiree SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 soiree de 21h a 23h59 vers tous les operateurs.*"
	    "1:Souscrire.*"
	    "7:Conditions.*"
	   },
	   {send,"1"},
	   {expect,"Vous allez souscrire au bon plan Soiree SMS illimites pour 2,50E.*"
	    "1:Valider.*"

	   },
	   {send,"1"},
	   {expect,"Vous avez souscrit au bon plan Soiree SMS illimites pour 2,50E. Ce montant a ete debite de votre compte.*9:Accueil"}
	  ]
         }
        ]++
	test_util_of:close_session();

test_vos_messages_option({opt_ssms_illimite,_},DCL,conditions)->
    init_test(DCL)++
        init_sachem()++
        init_compte() ++
	set_present_period([opt_ssms_illimite])++
	[{title, "<center>#### Vos Messages - Options SMS -  Option Soiree SMS illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Soiree SMS illimites Mentions Legales",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_ssms_ill(DCL)},
            {expect,".*"},
            {send,"7"},
	    {expect,"SMS/MMS illimites vers les mobiles en France metropolitaine de 21h a 23h59 dans la limite de 200 destinataires differents par soiree.*1:Suite"},
	    {send,"1"},
	    {expect,"Option valable le jour de la souscription. Hors SMS/MMS surtaxes et MMS cartes postales et numeros courts. SMS/MMS entre personnes physiques...*1:Suite"},
	    {send,"1"},
	    {expect,"et pour un usage personnel non lucratif direct. Option valable en France metropolitaine et reservee aux clients mobicarte.*1:Suite"},
	    {send,"1"},
	    {expect, "Le prix de l'option est preleve sur le compte du client sous reserve d'un credit suffisant. Souscription possible le jour meme de 02h a 23h45.*1:Suite"},
	    {send, "1"},
	    {expect, "MMS disponibles entre terminaux compatibles"},
	    {send, "1"},
	    {expect,"Vous allez souscrire au bon plan Soiree SMS illimites pour 2,50E"}
	   ]
	 }]++
	test_util_of:close_session();

test_vos_messages_option({opt_ssms_illimite,_},DCL,suppression)->
    [];
test_vos_messages_option({opt_ssms_illimite,_},DCL,reactivation)->
    [];
test_vos_messages_option({opt_ssms_illimite,_},DCL,low_credit)->
    init_test(DCL)++
	init_compte(opt_ssms_illimite, ?CETAT_AC, 2000) ++
	set_present_period([opt_ssms_illimite])++
        profile_manager:set_sachem_response(?Uid,{?maj_op,{error, "solde_insuffisant"}})++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Soiree SMS Illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Soiree SMS Illimites - Low credit",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_ssms_ill(DCL)},
	    {expect,"Decouvrez le bon plan soiree SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 soiree de 21h a 23h59 vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"
	    },
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Soiree SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Bonjour, pour souscrire au bon plan Soiree SMS illimites vous devez disposer de 2,50E sur votre compte. Orange vous remercie de votre appel"}
 	   ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_ssms_illimite,_},DCL,heure_fermeture)->
    init_test(DCL)++
	init_sachem()++
	init_compte() ++
	set_present_period([opt_ssms_illimite])++
	set_out_hour_range([opt_ssms_illimite])++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Soiree SMS Illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Soiree SMS Illimites - Heure fermeture",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_ssms_ill(DCL)},
	    {expect,"Decouvrez le bon plan soiree SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 soiree de 21h a 23h59 vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"},
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Soiree SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Desole, la souscription a l'option Soiree SMS Illimites est actuellement fermee.*"
	     "Profitez des autres bons plans.*1:Autres bons plans"}
 	   ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_ssms_illimite,_},DCL,incompatible)->
    init_test(DCL)++
        init_compte(opt_ssms_illimite, ?CETAT_AC, 30000) ++
	set_present_period([opt_ssms_illimite]) ++
	set_in_hour_range([opt_ssms_illimite]) ++
        profile_manager:set_sachem_response(?Uid,{?maj_op,{error, "option_incompatible_opt"}})++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Soiree SMS Illimites - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Soiree SMS Illimites - Options incompatibles",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_ssms_ill(DCL)},
	    {expect,"Decouvrez le bon plan soiree SMS illimites: pour 2,50E envoyez des SMS en illimite pendant 1 soiree de 21h a 23h59 vers tous les operateurs.*"
	     "1:Souscrire.*"
	     "7:Conditions.*"},
	    {send,"1"},
	    {expect,"Vous allez souscrire au bon plan Soiree SMS illimites pour 2,50E.*"	 
	     "1:Valider.*"},
	    {send,"1"},
    	    {expect,"Vous disposez de l'option SMS quotidienne qui est incompatible avec le bon plan Soiree SMS illimites"}
 	   ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_illimite,_},?m6_prepaid,_)->
    [];
test_vos_messages_option({opt_sms_illimite,_},DCL,conditions)->
    init_test(DCL)++
	init_sachem(opt_sms_illimite, active)++
	init_compte(opt_sms_illimite, ?CETAT_AC)++
 	[{title, "<center>#### Vos Messages - Options SMS - Option Messages illimites ACTIVEE - DCL = "++integer_to_list(DCL)++" ####</center>"},
 	 "TEST OPTION MESSAGE ILLIMITE : Mentions Legales",
	 {ussd2,
	  [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
	    {send, code_opt_message_ill(DCL)},
	    {expect,".*"},
	    {send,"7"},
	    {expect,"Option a souscrire valable en France metropolitaine"},
	    {send,"1"},
	    {expect,"SMS/MMS et messages orange messenger windows live illimites"},
	    {send,"1"},
	    {expect,"jusqu'a 200 destinataires differents par mois"},
	    {send,"1"},
	    {expect,"Cession des messages et messages emis depuis des boitiers radio interdits"},
	    {send,"1"},
	    {expect,"un mobile compatible"},
	    {send,"1"},
	    {expect,"en telechargement sur http://im.orange.fr et utilisable entre equipements compatibles dotes du service"},
	    {send,"1"},
	    {expect,"Le prix de l'option est preleve chaque jour sur le compte du client sous reserve d'un credit suffisant"},
	    {send,"1"},
	    {expect,"reprend automatiquement des que le credit est de nouveau suffisant. Resiliation possible au 220 ou au #123#..."}
	   ]}
	] ++
	test_util_of:close_session();

test_vos_messages_option({opt_sms_illimite,_},DCL,suppression)->
    init_test(DCL)++
	init_sachem(opt_sms_illimite, active)++
        init_compte(opt_sms_illimite, ?CETAT_AC)++
	["TEST RESILIATION OPTION MESSAGE ILLIMITE : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL SUFFISANT\n"
	 "Client:MOBICARTE - Compte principal:actif - Solde=50E - Option existante:Message illimite",
	 case DCL of
	     ?mobi ->
		 {ussd2,
		  [ {send, code_vos_messages_options_sms(DCL)},
                    {expect,".*"},
                    {send, code_opt_message_ill(DCL)},
		    {expect,"Votre bon plan messages illimites est actif : vous beneficiez chaque jour de messages illimites de 16h a 20h pour 0,5E"},
		    {send,"1"},
		    {expect,"Si vous supprimez votre bon plan,vous perdez immediatement le benefice d'envoi de messages illimites de 16h a 20h"},
		    {send,"1"},
		    {expect,"Merci de confirmer la suppression"},
		    {send,"1"},
		    {expect,"La suppression de votre bon plan messages illimites a bien ete prise en compte.*"
		    } 
		   ]
		 };
	     _ ->
		 {ussd2,
		  [{send, code_vos_messages_options_sms(DCL)},
		   {expect,".*"},
		   {send, code_opt_message_ill(DCL)},
		   {expect,"Votre bon plan messages illimites est actif : vous beneficiez chaque jour de messages illimites de 16h a 20h pour 0,5E"},
		   {send,"1"},
		   {expect,"Tous vos SMS, MMS et messages Windows Live sont en illimite chaque jour de 16h a 20h pour 0,5E seulement"},
		   {send,"1"},
		   {expect,"Si vous supprimez votre bon plan,vous perdez immediatement le benefice d'envoi de messages illimites de 16h a 20h"},
		   {send,"1"},
		   {expect,"Merci de confirmer la suppression"},
		   {send,"1"},
		   {expect,"La suppression de votre bon plan messages illimites a bien ete prise en compte.*"
		   }
		  ]
		 }
	 end
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_mms_mensu,_},?m6_prepaid,_)->
    [];
test_vos_messages_option({opt_mms_mensu,_},DCL,conditions)->
    init_test(DCL) ++
  	init_sachem(opt_mms_mensu, active)++
  	init_compte(opt_mms_mensu, ?CETAT_AC)++
  	[{title, "<center>#### Vos Messages - Options SMS - Option 10MMS ACTIVEE - DCL = "++integer_to_list(DCL)++" ####</center>"},
  	 "OPTION MMS MENSUELLE : Mentions legales",
	 {ussd2,
	  [{send,code_vos_messages_options_mms(DCL)},
	   {expect,".*"},
  	   {send, "7"},
  	   {expect,"Offre valable en France metropolitaine et reservee aux clients mobicarte ayant souscrit a l'offre entre le .* et le .*"},
  	   {send,"1"},
  	   {expect,"10 MMS valables un mois"},
  	   {send,"1"},
  	   {expect,"Les 2E sont preleves chaque mois sur le compte mobicarte du client sous reserve de disposer d'un credit suffisant"},
  	   {send,"1"},
  	   {expect,"l'option sera suspendue et reprendra automatiquement a la date anniversaire si le credit est a nouveau suffisant"},
  	   {send,"1"},
  	   {expect,"...dans le mois ne sont pas reportes sur le mois suivant"},
  	   {send,"1"},
  	   {expect,"Le client est informe qu'a compter de la resiliation les MMS non consommes sont perdus"}
  	  ]
	 }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_mms_mensu,_},DCL,suppression)->
    init_test(DCL) ++
  	init_sachem(opt_mms_mensu, active)++
  	init_compte(opt_mms_mensu, ?CETAT_AC)++
  	["TEST RESILIATION OPTION MMS MENSUELLE : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL SUFFISANT\n"
  	 "Client:MOBICARTE - Compte principal:actif - Solde=50E - Option existante:MMS mensu",
  	 case DCL of
  	     ?click_mobi ->
  		 {ussd2,
  		  [{send,code_vos_messages_options_mms(DCL)},
  		   {expect,"Votre option 10 MMS mensuelle est actuellement activee"},
  		   {send,"1"},
  		   {expect,"Votre option MMS mensuelle est activee et vous avez epuise les 10 MMS mensuels.Chaque mois,vous beneficiez de 10 MMS pour 2E."},
  		   {send,"1"},
  		   {expect,"Il vous reste .*MMS a utiliser jusqu'au.*Si vous supprimez votre option 10MMS mensuelle maintenant vous ne pourrez pas beneficier de ces MMS"},
  		   {send,"1"},
  		   {expect,"Merci de confirmer la suppresion de votre option 10 MMS mensuelle"}
  		  ]
  		 };
  	     _ ->
  		 {ussd2,
  		  [{send,code_vos_messages_options_mms(DCL)},
  		   {expect,"Votre option 10 MMS mensuelle est actuellement activee"},
  		   {send,"1"},
  		   {expect,"Il vous reste .*MMS a utiliser jusqu'au.*Si vous supprimez votre option 10MMS mensuelle maintenant vous ne pourrez pas beneficier de ces MMS"},
  		   {send,"1"},
  		   {expect,"Merci de confirmer la suppresion de votre option 10 MMS mensuelle"}
  		  ]
  		 }
  	 end
  	] ++
	test_util_of:close_session()++

        init_sachem(opt_mms_mensu, active)++
	init_compte(opt_mms_mensu, ?CETAT_EP)++
        ["TEST RESILIATION OPTION MMS MENSUELLE : CAS OPTION DEJA ACTIVEE ET SOLDE DU COMPTE PRINCIPAL INSUFFISANT\n"
         "Client:MOBICARTE - Compte principal:actif - Solde epuise - Option existante:MMS mensu",
	 case DCL of
             ?click_mobi ->
		 {ussd2,
		  [{send,code_vos_messages_options_mms(DCL)},
		   {expect,"Votre option 10 MMS mensuelle est actuellement activee. Vous beneficiez de 10 MMS valables 1 mois pour 2E"},
		   {send,"1"},
                   {expect,"Votre option MMS mensuelle est activee et vous avez epuise les 10 MMS mensuels.Chaque mois,vous beneficiez de 10 MMS pour 2E."},
		   {send,"1"},
		   {expect,"Merci de confirmer la suppresion de votre option 10 MMS mensuelle"},
		   {send,"1"},
		   {expect,"La suppression de votre option 10 MMS mensuelle a bien ete prise en compte.*"
		   }
		  ]};
	     _ ->
		 {ussd2,
		  [{send,code_vos_messages_options_mms(DCL)},
		   {expect,"Votre option 10 MMS mensuelle est actuellement activee. Vous beneficiez de 10 MMS valables 1 mois pour 2E"},
		   {send,"1"},
		   {expect,"Merci de confirmer la suppresion de votre option 10 MMS mensuelle"},
		   {send,"1"},
		   {expect,"La suppression de votre option 10 MMS mensuelle a bien ete prise en compte.*"
		   }
		  ]}
	 end
	]++
	test_util_of:close_session();

test_vos_messages_option({opt_msn_journee_mobi,_},DCL,souscription)->
    init_test(DCL)++
	init_sachem()++	
	init_compte() ++
  	[{title, "<center>#### Vos Messages - Options OM by WL - Option Journee OM by WL - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option Journee OM by WL Souscription",
 	 {ussd2,
	  [{send,code_vos_messages_options_omwl(DCL)},
	   {expect,".*"},
	   {send, code_opt_journee_OMWL(DCL)},
 	   {expect,"Avec l'option journee Orange Messenger by Windows Live envoyez et recevez en illimite pdt toute une journee"},
 	   {send,"1"},
 	   {expect,"vos messages pour 0,9E"},
 	   {send,"1"},
 	   {expect, "...sont illimites de 2h00 a 23h59"},
 	   {send,"1"},
 	   {expect, "..au service sont gratuits ainsi que les eventuelles mises a jour sur http://im.orange.fr"},
 	   {send,"1"},
     	   {expect,"Vous allez souscrire a l'option journee Orange Messenger by Windows Live pour 0,9E"},
     	   {send,"1"},
     	   {expect,"Vous avez souscrit a l'option journee Orange Messenger by Windows Live pour 0,9E.*"
	   },
 	   {send,"1"},
	   {expect,"Dans quelques instants, votre bon plan sera activee.*"
	   } 
	  ]
     	 }
     	]++
	test_util_of:close_session();

test_vos_messages_option({opt_msn_journee_mobi,_},DCL,suppression)->
    [];
test_vos_messages_option({opt_msn_journee_mobi,_},DCL,reactivation)->
    [];
test_vos_messages_option({opt_msn_journee_mobi,_},DCL,conditions)->
    init_test(DCL)++
  	["Test Option Journee OM by WL Mentions Legales",
  	 {ussd2,
  	  [{send,code_vos_messages_options_omwl(DCL)},
           {expect,".*"},
           {send, code_opt_journee_OMWL(DCL)},
           {expect,".*"},
           {send,"7"},
	   {expect,"Option a souscrire le jour meme de 2h00 du matin a 23h00 et valable en France metropolitaine le jour meme pour une utilisation"},
	   {send,"1"},
	   {expect,"jusqu'a 23h59"},
	   {send,"1"},
	   {expect,"disponible en telechargement sur  http://im.orange.fr et utilisable entre entre equipements compatibles dotes du service"},
	   {send,"1"},
	   {expect,"d'utilisation du service sur www.orange.fr onglet mobile.. Envoi gratuit et illimite de messages metropolitains et de fichiers photo"},
	   {send,"1"},
	   {expect,".jpeg ou gif. depuis un mobile en France metropolitaine a compter de la date de souscription. Le prix de l'option sera preleve a la"},
	   {send,"1"},
           {expect,"souscription sur le compte"},
	   {send, "8"},
	   {expect,".peg ou gif. depuis un mobile en France metropolitaine a compter de la date de souscription. Le prix de l'option sera preleve a la"}
	  ]
  	 }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_msn_mensu_mobi,_},DCL,souscription)->
    init_test(DCL)++
	init_sachem()++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Options OM by WL - Option Mensuelle OM by WL - DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option mensuelle OMWL Souscription",
	 {ussd2,
          [ {send,code_vos_messages_options_omwl(DCL)},
	    {expect,".*"},
	    {send, code_opt_mensu_OMWL(DCL)},
	    {expect,"Avec l'option mensuelle Orange Messenger by Windows Live envoyez et recevez en illimite vos messages pendant 1 mois pour 4 euros"},
	    {send,"11111"},
    	    {expect,"Vous avez souscrit a l'option mensuelle Orange Messenger by Windows Live pour 4 euros. Ce montant a ete debite de votre compte.*9:Accueil"} 
 	   ]
    	 }
    	]++
	test_util_of:close_session();

test_vos_messages_option({opt_msn_mensu_mobi,_},DCL,conditions)->
    ["Test Option mensuelle OMWL Mentions Legales",
     {ussd2,
      [{send,code_vos_messages_options_omwl(DCL)},
       {expect,".*"},
       {send, code_opt_mensu_OMWL(DCL)},
       {expect,".*"},
       {send,"7"},
       {expect,"Option valable en France metropolitaine, donnant acces au service de messagerie instantanee Orange Messenger by Windows Live"},
       {send,"1"},
       {expect, "Envoi illimite de messages metropolitains et de fichier"},
       {send,"1"},
       {expect,"du SMS de confirmation de souscription. Souscription de l'option au #123# \\(appel gratuit\\) ou sur internet"},
       {send,"1"},
       {expect,"www.orange.fr > espace client"},
       {send,"8"},
       {expect,"du SMS de confirmation de souscription. Souscription de l'option au #123# \\(appel gratuit\\) ou sur internet"}
      ]
     }] ++
	test_util_of:close_session();

test_vos_messages_option({opt_msn_mensu_mobi,_},DCL,suppression)->
    init_sachem(opt_msn_mensu_mobi, active)++
	init_compte(opt_msn_mensu_mobi, ?CETAT_AC)++
	[{title, "<center>#### Vos Messages - Options OM by WL - Option Mensuelle OM by WL ACTIVEE- DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option mensuelle OMWL Activee",
	 {ussd2,
	  [ {send,code_vos_messages_options_omwl(DCL)},
	    {expect,".*"},
	    {send, code_opt_mensu_OMWL(DCL)},
	    {expect,"Votre option mensuelle Orange Messenger by Windows Live est actuellement activee."}
 	   ]
    	 }
    	] ++
	test_util_of:close_session();

test_vos_messages_option({opt_msn_mensu_mobi,_},DCL,reactivation)->
    init_sachem(opt_msn_mensu_mobi, suspend)++
	init_compte(opt_msn_mensu_mobi, ?CETAT_AC)++
	[{title, "<center>#### Vos Messages - Options OM by WL - Option Mensuelle OM by WL SUSPENDUE- DCL = "++integer_to_list(DCL)++" ####</center>"},
	 "Test Option mensuelle OMWL Suspendue",
	 {ussd2,
	  [ {send,code_vos_messages_options_omwl(DCL)},
	    {expect,".*"},
	    {send, code_opt_mensu_OMWL(DCL)},
	    {expect,"Votre option mensuelle Orange Messenger by Windows Live est actuellement suspendue..1:Reactiver l'option.2:Supprimer l'option"}
 	   ]
    	 }
    	] ++
	test_util_of:close_session();

test_vos_messages_option({opt_30_sms_mms,_},DCL,souscription) ->    
    init_test(DCL)++
	init_sachem()++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Options 30 SMS/MMS-Test Souscription - DCL = "++integer_to_list(DCL)++" ####</center>"},
         {ussd2,
	  [{send,code_vos_messages_options_sms(DCL)},
	   {expect,".*"},
	   {send, code_opt_30_SMS_MMS(DCL)},
	   {expect, "Decouvrez le bon plan 30 SMS/MMS : pour 3E par mois, envoyez 30 SMS ou MMS vers tous les operateurs."},
	   {send, "1"},
	   {expect, "Vous allez souscrire au bon plan 30 SMS/MMS pour 3E par mois. Ce bon plan est renouvele chaque mois a date anniversaire pour 3E par mois."},
	   {send, "1"},
	   {expect, "Vous avez souscrit au bon plan 30 SMS/MMS pour 3E par mois. Ce montant a ete debite de votre compte."},
	   {send, "1"},
	   {expect, "Dans quelques instants, votre bon plan sera active."}
	  ]
         }]++
	test_util_of:close_session();

test_vos_messages_option({opt_30_sms_mms,_},DCL,suppression) ->    
    init_test(DCL)++
	init_sachem(opt_30_sms_mms,active)++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Options 30 SMS/MMS - Test Suppression - DCL = "++integer_to_list(DCL)++" ####</center>"},
         {ussd2,
          [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"},
	    {send, "4"},
            {expect, "Votre bon plan 30 SMS/MMS est actuellement active."},
            {send, "1"},
            {expect, "Merci de confirmer la suppression de votre bon plan 30 SMS/MMS. Si vous supprimez votre bon plan maintenant,"},
            {send, "1"},
            {expect, "vous perdez immediatement le benefice de celui-ci."},
            {send, "1"},
            {expect, "La suppression de votre bon plan 30 SMS/MMS a bien ete prise en compte..*Merci de votre appel."}
           ]
         }]++
	test_util_of:close_session();


test_vos_messages_option({opt_30_sms_mms,_},DCL,reactivation) ->
    init_test(DCL)++
	init_sachem(opt_30_sms_mms,suspend)++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Options 30 SMS/MMS - Test Reactivation - DCL = "++integer_to_list(DCL)++" ####</center>"},    
         {ussd2,
          [ {send,code_vos_messages_options_sms(DCL)},
	    {expect,".*"},
	    {send, "4"},
            {expect, "Votre bon plan 30 SMS/MMS est actuellement suspendu."},
            {send, "1"},
	    {expect, "ous ne beneficiez plus de vos 30 SMS ou MMS pour 3E par mois"},
	    {send, "1"},
            {expect, "Vous allez reactiver le bon plan 30 SMS/MMS pour 3E. Ce bon plan est renouvele chaque mois a date anniversaire pour 3E par mois."},
            {send, "1"},
            {expect, "La reactivation de votre bon plan 30 SMS/MMS a bien ete prise en compte. 3E ont ete debites de votre compte."},
            {send, "1"},
            {expect,".*"}
           ]
         }]++
	test_util_of:close_session();

test_vos_messages_option({opt_30_sms_mms,_},DCL,conditions) ->
    init_test(DCL)++
	init_sachem()++	
	init_compte() ++
 	[{title, "<center>#### Vos Messages - Options 30 SMS/MMS - Test Conditions - DCL = "++integer_to_list(DCL)++" ####</center>"},        
         {ussd2,
          [{send,code_vos_messages_options_sms(DCL)},
	   {expect,".*"},
	   {send, code_opt_30_SMS_MMS(DCL)},
	   {expect,".*"},
	   {send,"7"},
	   {expect,"30 SMS ou MMS  vers les mobiles en France metropolitaine \\(hors SMS/MMS surtaxes, numeros courts et MMS cartes postales\\)..*1:Suite"},
	   {send,"1"},
	   {expect,"Option valable 31 jours en France metropolitaine a compter de la date d'activation et renouvelee tous les mois .*1:Suite"},
	   {send,"1"},
	   {expect,"sous reserve de credit suffisant. Les 3E sont preleves sur le compte principal. Les SMS/MMS non utilises sur la periode ne sont pas reportes .*1:Suite"},
	   {send,"1"},
	   {expect,"sur la periode suivante."}
	  ]
         }]++
	test_util_of:close_session();
test_vos_messages_option({opt_30_sms_mms,_},DCL,incompatible)->
    init_test(DCL)++
        init_compte() ++
        profile_manager:set_sachem_response(?Uid,{?maj_op,{error, "option_incompatible_opt"}})++
        [{title, "<center>#### Vos Messages - Options SMS - Option Journee SMS Illimites - DCL = "++integer_to_list(DCL)++"  ####</center>"},
         "Test Option 30 SMS/MMS - Options incompatibles",
         {ussd2,
          [ {send,code_vos_messages_options_sms(DCL)},
            {expect,".*"},
            {send, code_opt_30_SMS_MMS(DCL)},
	    {expect, "Decouvrez le bon plan 30 SMS/MMS : pour 3E par mois, envoyez 30 SMS ou MMS vers tous les operateurs."},
	    {send, "1"},
           {expect, "Vous allez souscrire au bon plan 30 SMS/MMS pour 3E par mois. Ce bon plan est renouvele chaque mois a date anniversaire pour 3E par mois."},
           {send, "1"},
           {expect, "Vous ne pouvez pas souscrire a l'option 30 SMS/MMS. Pour \\+ d'infos contactez votre service clients Orange mobile au 722 depuis votre mobile \\(0,37 E/min\\). Merci de votre appel.*"}
           ]
         }
        ]++
        test_util_of:close_session();
test_vos_messages_option({Opt,Label},DCL,Type)->
    [].

init_sachem()->
    profile_manager:set_list_options(?Uid, []).

init_sachem(Option, active)->
        profile_manager:set_list_options(?Uid, [])++
    profile_manager:set_list_options(?Uid, [#option{top_num=top_num(Option,mobi)}]);
init_sachem(Option, suspend)->
        profile_manager:set_list_options(?Uid, [])++
    profile_manager:set_list_options(?Uid, [#option{top_num=top_num(Option,mobi), opt_info2="S"}]).

init_oto()->
    rpc:call(possum@localhost,one2one_offers,csv2mnesia,["test_sample.csv"]),
    PAUSE = 2000,
    ["Activation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost,
                            pcontrol, enable_itfs,
                            [[io_oto_mqseries1,possum@localhost]]]}]},
     "Pause de "++ integer_to_list(PAUSE) ++" Ms",
     {pause, PAUSE}] ++
	test_util_of:set_parameter_for_test(one2one_activated_cmo,true) ++
	test_util_of:set_parameter_for_test(one2one_activated_mobi,true) ++
	test_util_of:set_parameter_for_test(one2one_activated_postpaid,true) ++
	[].


init_test(DCL)->
    profile_manager:create_default(?Uid,"mobi")++
	profile_manager:set_dcl(?Uid,DCL)++
	profile_manager:set_default_spider(?Uid,config,[])++
        profile_manager:init(?Uid)++
	init_oto()++
	[].


init_compte()->
    profile_manager:set_list_comptes(?Uid, [#compte{tcp_num=?C_PRINC,
						    unt_num=?EURO,
						    cpp_solde=42000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=?CETAT_AC,
						    ptf_num=?PCLAS_V2}]).
init_compte(Option, Etat)->
    init_compte(Option, Etat, 504).

init_compte(Option, Etat, CPP)->
    profile_manager:set_list_comptes(?Uid, [#compte{tcp_num=svc_options:tcp_num(Option,mobi),
						    unt_num=?EURO,
						    cpp_solde=CPP,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=Etat,
						    ptf_num=svc_options:ptf_num(Option,mobi)}]).

top_num(Opt,Sub) ->
    test_util_of:rpc(option_manager,get_orange_id,[{Opt,Sub},top_num]).

set_present_period([])->    
    [];
set_present_period([H|T]) ->
    test_util_of:set_present_commercial_date(H,mobi)++
        set_present_period(T).

set_past_period([])->
    [];
set_past_period([H|T]) ->
    test_util_of:set_past_commercial_date(H,mobi)++
	set_past_period(T).

set_in_hour_range([]) -> [];
set_in_hour_range([H|T]) ->
    test_util_of:set_open_hour(H,mobi,"always")++
	test_util_of:set_open_day(H,mobi,"always")++
	set_in_hour_range(T).

set_out_hour_range([]) -> [];
set_out_hour_range([H|T]) ->
    test_util_of:set_open_hour(H,mobi,"[{{0,0,0},{0,0,0}}]")++
	test_util_of:set_open_day(H,mobi,"[]")++
	set_out_hour_range(T).
