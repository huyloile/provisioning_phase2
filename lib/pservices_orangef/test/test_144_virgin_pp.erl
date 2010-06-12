-module(test_144_virgin_pp).
-compile(export_all).


-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").
-include("profile_manager.hrl").

-define(Uid,virgin_pp_user).

-define(DIRECT_CODE,"*144").

-define(niv1,   "100007XXXXXXX1").
-define(niv2,   "100006XXXXXXX2").
-define(niv3,   "100005XXXXXXX3").

-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2
-define(PE, ?CETAT_PE). %3
-define(UNDEF, undefined).

-define(LIST_STATES_TO_TEST,[{?AC,"actif"},
			     {?EP,"epuise"}
			    ]).
-define(LIST_STATES_TO_TEST_WITH_UNDEF,[{?AC,"actif"},
					{?EP,"epuise"},
					{?UNDEF,"undefined"}
				       ]).

-define(LIST_STATES_TO_TEST_WITH_PERIME_UNDEF,[{?AC,"actif"},
					       {?EP,"epuise"},
					       {?PE,"perime"},
					       {?UNDEF,"undefined"}
					      ]).

-define(LIST_OPT_TO_TEST,[
 			  {[0,top_num(verylong)],"VeryLong","VeryLong"},
  			  {[0,test_util_of:get_top_num(veryworld_europe,virgin_prepaid)],"VeryWorld","VeryWorld Europe"},
  			  {[0,test_util_of:get_top_num(veryworld_maghreb,virgin_prepaid)],"VeryWorld","VeryWorld Maghreb"}
%% 			  {[0,top_num(verysms)],"VerySMS","VerySMS"}
%% 			  {[0,top_num(veryvoix)],"VeryVoix","VeryVoix"}
                         ]).

-define(LIST_PRINC_RSI_OSI_TO_TEST,
 	[
	 %% cases CP + CO > 0 and one of RSI / OSI OK
         {{?AC,?AC,?EP,?AC},"Cpte recharge actif, cpte optionnel actif, rsi epuise et osi actif "},
	 %% {{?AC,?EP,?EP,?AC},"cpte recharge actif, cpte optionnel epuise, rsi epuise et osi actif"},
	 %% {{?AC,?PE,?EP,?AC},"cpte recharge actif, cpte optionnel perime, rsi epuise et osi actif"},
	 %% {{?AC,?UNDEF,?EP,?AC},"cpte recharge actif, cpte optionnel undefined, rsi epuise et osi actif"},
	 %% {{?UNDEF,?AC,?EP,?AC},"cpte recharge undefined, cpte optionnel actif, rsi epuise et osi actif"},
	 %% {{?EP,?AC,?EP,?AC},"cpte recharge epuise, cpte optionnel actif, rsi epuise et osi actif"},
         {{?AC,?AC,?AC,?EP},"cpte recharge actif, cpte optionnel actif, rsi actif et osi epuise"},
	 %% {{?AC,?EP,?AC,?EP},"cpte recharge actif, cpte optionnel epuise, rsi actif et osi epuise"},
	 %% {{?UNDEF,?AC,?AC,?EP},"cpte recharge undefined, cpte optionnel epuise, rsi actif et osi epuise"},
	 %% {{?AC,?UNDEF,?AC,?EP},"cpte recharge actif, cpte optionnel undefined, rsi actif et osi epuise"},

         %% cases CP + CO > 0 and RSI NOK and OSI NOK
         {{?AC,?AC,?EP,?EP},"cpte recharge actif, cpte optionnel actif, rsi epuise et osi epuise"},
	 %% {{?AC,?EP,?EP,?EP},"cpte recharge actif, cpte optionnel epuise, rsi epuise et osi epuise"},
	 %% {{?AC,?UNDEF,?EP,?EP},"cpte recharge actif, cpte optionnel undefined, rsi epuise et osi epuise"},
	 %% {{?UNDEF,?AC,?EP,?EP},"cpte recharge undefined, cpte optionnel actif, rsi epuise et osi epuise"},

         %% cases CP + CO = 0 and RSI OK
         {{?EP,?EP,?AC,?AC},"cpte echarge epuise, cpte optionnel epuise, rsi actif et osi actif"},
	 %% {{?PE,?PE,?AC,?AC},"cpte echarge perime, cpte optionnel perime, rsi actif et osi actif"},
	 %% {{?UNDEF,?UNDEF,?AC,?AC},"cpte echarge undefined, cpte optionnel undefined, rsi actif et osi actif"},
         {{?EP,?EP,?AC,?EP},"cpte recharge epuise, cpte optionnel epuise, rsi actif et osi epuise"},
	 %% {{?UNDEF,?UNDEF,?AC,?EP},"cpte recharge undefined, cpte optionnel undefined, rsi actif et osi epuise"},

         %% cases CP + CO = 0 and RSI NOK and OSI OK
         {{?EP,?EP,?EP,?AC},"cpte recharge epuise, cpte optionnel epuise, rsi epuise et osi actif"},
	 %% {{?UNDEF,?UNDEF,?EP,?AC},"cpte recharge undefined, cpte optionnel undefined, rsi epuise et osi actif"},

         %% cases CP + CO = 0 and RSI NOK and OSI NOK
         {{?EP,?EP,?EP,?EP},"cpte recharge epuise, cpte optionnel epuise, rsi epuise et osi epuise"}
	 %% {{?PE,?PE,?EP,?EP},"cpte recharge perime, cpte optionnel perime, rsi epuise et osi epuise"},
	 %% {{?UNDEF,?UNDEF,?EP,?EP},"cpte recharge undefined, cpte optionnel undefined, rsi epuise et osi epuise"}
	]).

-define(LIST_LEVELS_TO_TEST,[{?niv1,"Niveau 1"}
			     %% {?niv2,"Niveau 2"}
			     %% {?niv3,"Niveau 3"}
			    ]).

-record(cpte_test,{princ,niv,cpte_odr,cpte_opt,opt_very,cpte_rsi,cpte_osi,cpte_opt_voix,cpte_opt_sms,cpte_data}).

-define(CASES_VIRGIN, [
		       #cpte_test{princ=S1,niv=?niv1,cpte_odr=S3,
				  cpte_opt=S4, opt_very=S5, cpte_rsi=S6,
				  cpte_osi=S7,cpte_opt_voix=S8,cpte_opt_sms=S9,cpte_data=S10}
		       || 
			  {S3,_}   <- ?LIST_STATES_TO_TEST,
			  {S5,_,_} <- ?LIST_OPT_TO_TEST,
			  {{S1,S4,S6,S7},_} <- ?LIST_PRINC_RSI_OSI_TO_TEST,
			  {S8,_}   <- ?LIST_STATES_TO_TEST,
			  {S9,_}   <- ?LIST_STATES_TO_TEST,
			  {S10,_}  <- ?LIST_STATES_TO_TEST]).

%% -define(ALL_CASES_VIRGIN, [
%%                            #cpte_test{princ=S1,niv=?niv1,cpte_odr=S3,
%% 				      cpte_opt=S4, opt_very=S5, cpte_rsi=S6,
%% 				      cpte_osi=S7,cpte_opt_voix=S8,cpte_opt_sms=S9,cpte_data=S10}
%%                            ||
%% 			      {S1,_}   <- ?LIST_STATES_TO_TEST_WITH_PERIME_UNDEF,
%% 			      {S3,_}   <- ?LIST_STATES_TO_TEST_WITH_UNDEF,
%% 			      {S4,_}   <- ?LIST_STATES_TO_TEST_WITH_UNDEF,
%% 			      {S5,_,_} <- ?LIST_OPT_TO_TEST,
%% 			      {S6,_}   <- ?LIST_STATES_TO_TEST_WITH_UNDEF,
%% 			      {S7,_}   <- ?LIST_STATES_TO_TEST_WITH_UNDEF,
%% 			      {S8,_}   <- ?LIST_STATES_TO_TEST_WITH_UNDEF,
%% 			      {S9,_}   <- ?LIST_STATES_TO_TEST_WITH_UNDEF,
%% 			      {S10,_}  <- ?LIST_STATES_TO_TEST]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generic functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

top_num(Opt) -> svc_options:top_num(Opt,virgin_prepaid).

state_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_STATES_TO_TEST_WITH_PERIME_UNDEF),
    Nom.

state_name_opt(Int) ->
    {value,{_,_,Nom}}=lists:keysearch(Int, 1, ?LIST_OPT_TO_TEST),
    Nom.

level_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_LEVELS_TO_TEST),
    Nom.

solde(?AC,Solde)->
    Solde;
solde(_,_) ->
    0.  

date(opt_voix)->
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}});
date(opt_sms)->  
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}});
date(osi)->
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}});
date(sms_ill)->
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}});
date(optionnel)->
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}});
date(data)->
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}});
date(very)->
    svc_util_of:local_time_to_unixtime({{2008,10,11},{8,0,0}});
date(odr)->
    svc_util_of:local_time_to_unixtime({{2008,12,25},{8,0,0}});
date(princ)->
    svc_util_of:local_time_to_unixtime({{2009,10,31},{8,0,0}}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_test_account(#cpte_test{princ=E1,niv=Niv,
                                cpte_odr=E3,cpte_opt=E4,opt_very=E5,
				cpte_rsi=E6,cpte_osi=E7,cpte_opt_voix=E8,cpte_opt_sms=E9,cpte_data=E10}) ->
    "Virgin PP Suivi-conso "++level_name(Niv)
	++"\nPRINCIPAL "++state_name(E1)++ ". "
	++"\nCOMPTE OPTIONEL: "++state_name(E4)++ " et "
        ++"OPTION: "++state_name_opt(E5)++ "."
	++"\nCOMPTE ODR "++state_name(E3)++ ""
        ++"\nRECHARGE SMS ILLIMTES "++state_name(E6)
	++"\nOption SMS ILLIMTES "++state_name(E7)
        ++"\nOPTION VOIX VIRGIN " ++state_name(E8)
	++"\nOPTION SMS VIRGIN " ++state_name(E9)
	++"\nCREDIT DATA " ++state_name(E10)
	.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consult_account(#cpte_test{niv=?niv1}=Cpte) ->
    [{title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [
       {send,?DIRECT_CODE++"*#"}
      ]++
      case lists:flatlength(expected(Cpte)) > 181 of
	  true ->
	      [
	       {expect,lists:sublist(expected(Cpte), 164)++".*1:.*"},
	       {send, "1"},
	       {expect,".*"}
	      ];
	  _ ->
	      [
	       {expect,expected(Cpte)}
	      ]
      end
     }
    ];

consult_account(Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, lists:sublist(expected(Cpte), 164)},
	{send, "1"},
	{expect, ".*"}
       ]}     
    ].

test_all_cases([]) -> [];
test_all_cases([H|T]) ->
    modify_account_state(H) ++
        consult_account(H) ++

        test_all_cases(T).

test_tarifs() ->
    Cpte=#cpte_test{princ=?EP,niv=?niv1,cpte_odr=?EP,
		    cpte_opt=?EP, opt_very=[0,top_num(verylong)], cpte_rsi=?EP,
		    cpte_osi=?EP,cpte_opt_voix=?EP,cpte_opt_sms=?EP,cpte_data=?EP},
    modify_account_state(Cpte) ++
	[{title, "TARIFS A L'ETRANGER: "++display_test_account(Cpte)},
	 {ussd2,
	  [
	   {send,?DIRECT_CODE++"*3#"},
	   {expect, "1:Connaitre les tarifs a l'etranger.*0:Retour au suivi conso"},
	   {send,"1"},
	   {expect,"Les destinations sont classees en 4 zones tarifaires : Europe, Suisse/Andorre, Maghreb/Amerique du Nord/Turquie et \" Reste du monde \".*1:suite"},
	   {send,"1"},
	   {expect,"Un seul tarif est applique par zone pour vos appels voix vers la France Metropolitaine ou la zone de votre destination. Prix/mn des appels emis depuis et.*1:suite"},
	   {send,"1"},
	   {expect,"vers: la zone Europe =0.514E, \\(sauf Suisse-Andorre =1E15\\), la zone Maghreb/Amerique du Nord/Turquie=1.40E, la zone \"Reste du monde\"=3E. Prix/mn des appels.*1:suite"},
	   {send,"1"},
	   {expect,"recus depuis : la zone Europe = 0.227E, \\(sauf Suisse-Andorre =0.65E\\), la zone Maghreb/Amerique du Nord/Turquie = 0.75E, la zone \"Reste du monde\" = 1.50E.*1:suite"},
	   {send,"1"},
	   {expect,"En zone UE, vos appels sont decomptes a la sec des la 1ere sec pour la reception, a la sec au-dela de 30sec indivisibles pour les emissions d'appel en UE.*1:suite"},
	   {send,"1"},
	   {expect,"et vers la France. Dans les autres pays, facturation a la sec au-dela de la 1ere min indivisible. Envoi d'1 SMS vers ou depuis etranger: 0.30E \\(0,1315E.*1:suite"},
	   {send,"1"},
	   {expect,"depuis UE vers UE\\), reception gratuite. Envoi d'1 MMS vers ou depuis etranger: 1.10E. Reception d'un MMS: 0.80E. Prix des connexions data depuis.*1:suite"},
	   {send,"1"},
	   {expect,"etranger:0,30E TTC/10ko."},
	   {send,"0"},
	   {expect,"depuis UE vers UE\\), reception gratuite. Envoi d'1 MMS vers ou depuis etranger: 1.10E. Reception d'un MMS: 0.80E. Prix des connexions data depuis"},
	   {send,"00"},
	   {expect,"Connaitre les tarifs a l'etranger"},
	   {send,"0"},
	   {expect,".*"}
	  ]
	 }].

modify_account_state(#cpte_test{princ=E1,niv=Niv,cpte_odr=E3,
                                cpte_opt=E4,opt_very=E5,cpte_rsi=E6,cpte_osi=E7,
				cpte_opt_voix=E8,cpte_opt_sms=E9,cpte_data=E10}) ->
    profile_manager:set_imei(?Uid,Niv)++
        profile_manager:set_dcl(?Uid,?DCLNUM_VIRGIN_PREPAID)++
 	profile_manager:set_list_options(?Uid, [#option{top_num=Top_num} || Top_num <- E5])++
	profile_manager:set_list_comptes(?Uid, compte(E1,E3,E4,E6,E7,E8,E9,E10)).

compte(E1,E3,E4,E6,E7,E8,E9,E10)->
    %% compte recharge
    make_compte(?C_PRINC,?EURO,solde(E1,10000),date(princ),0,E1,?PTFNUM_VIRGIN_PREPAID) ++
	%% compte recharge
	make_compte(?C_FORF_ODR,?EURO,20000,date(odr),0,E3,?PTF_ODR_VIRGIN_PP) ++
	%% compte optionnel Virgin
	make_compte(?C_OPT_VIRGIN_PP,?EURO,solde(E4,20000),date(optionnel),0,E4,265) ++
	make_compte(?C_RECH_SMS_ILLM,?EURO,solde(E6,20000),date(sms_ill),0,E6,41) ++
	make_compte(?C_OPT_OSI_VIRGIN,?EURO,solde(E7,20000),date(osi),0,E7,41) ++
	make_compte(?C_OPT_VOIX_VIRGIN,?EURO,solde(E8,10000),date(opt_voix),0,E8,216) ++
	make_compte(?C_OPT_SMS_VIRGIN,?SMS,solde(E9,20000),date(opt_sms),0,E9,216) ++
	make_compte(?C_VIRGIN_DATA,?EURO,solde(E10,20000),date(data),0,E10,376) ++
	[].

make_compte(_,_,_,_,_,undefined,_) ->
    [];
make_compte(TCP,UNT,CPP,DLV,RNV,ETAT,PTF) ->
    [#compte{tcp_num=TCP,
	     unt_num=UNT,
	     cpp_solde=CPP,
	     dlv=DLV,
	     rnv=RNV,
	     etat=ETAT,
	     ptf_num=PTF}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define expected results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(TXT_SELFCARE_RECHARGE_MENU,
        "2:recharger."
        "3:menu").

-define(TXT_AC_AC_ONEOFTWO_OK,
	".....E soit ..min..sec jusqu ../..."
	"et .....E jusqu ../...."
	"SMS illimites jusqu ../....").

-define(TXT_AC_AC_EP_EP,
	"Votre magot vaut .....E soit ..min..sec ou ... SMS jusqu ../..."
	"et .....E jusqu ../....").

-define(TXT_AC_EP_ONEOFTWO_OK,
	"Votre cagnotte s'eleve a .....E soit ..min..sec jusqu ../...."
	"SMS illimites jusqu ../....").

-define(TXT_AC_EP_EP_EP,
	"Votre magot vaut .....E soit ..min..sec ou ... SMS jusqu ../....").

-define(TXT_EP_AC_AC_UNDEFINED,
	"Votre cagnotte s'eleve a .....E soit ..min..sec jusqu ../...."
	"SMS illimites jusqu ../....").

-define(TXT_EP_AC_EP_AC,
	"Votre magot vaut .....E soit ..min..sec jusqu ../...."
	"SMS illimites jusqu ../....").

-define(TXT_EP_AC_EP_EP,
	"Votre cagnotte s'eleve a .....E soit ..min..sec jusqu ../....").

-define(TXT_EP_EP_AC_UNDEFINED,
	"SMS illimites jusqu ../....").

-define(TXT_EP_EP_EP_AC,
	"et retrouver les SMS illimites.").

-define(TXT_EP_EP_EP_EP,
	"").

%%%%%%%%%%%%%%%%%%%%%%%% Messages suivi conso plus %%%%%%%%%%%%%%%%%%
-define(TXT_SUIVI_CONSO_PLUS_AC_AC_1,
	"Offert par la maison: ..min..sec jusqu ../.. et .. SMS jusqu ../....").
-define(TXT_SUIVI_CONSO_PLUS_AC_NOAC_1,
	"Offert par la maison: ..min..sec jusqu ../....").
-define(TXT_SUIVI_CONSO_PLUS_NOAC_AC_1,
	"Offert par la maison: .. SMS jusqu ../....").
-define(TXT_SUIVI_CONSO_PLUS_AC_AC_2,
	"Cagnotte: ..min..sec jusqu ../.. et .. SMS jusqu ../.. offert par la maison.."
	"Pour l ettofer, vous pouvez recharger sur virginmobile.fr.").
-define(TXT_SUIVI_CONSO_PLUS_AC_NOAC_2,
	"Cagnotte: ..min..sec jusqu ../.. offert par la maison.."
	"Pour l ettofer, vous pouvez recharger sur virginmobile.fr.").
-define(TXT_SUIVI_CONSO_PLUS_NOAC_AC_2,
	"Cagnotte: .. SMS jusqu ../.. offert par la maison.."
	"Pour l ettofer, vous pouvez recharger sur virginmobile.fr.").
-define(TXT_SUIVI_CONSO_PLUS_NOAC_NOAC_2,
	"Votre credit est a bout. Pas de stress: vous pouvez le recharger 24h/24 et 7j/7 sur virginmobile.fr.").

%%%%%%%%%%%%%%%%%%%%%%%% Messages credit data %%%%%%%%%%%%%%%%%%
-define(TXT_CREDIT_DATA,
	"Godet data: encore .....o jusqu ../....").

%%%%%%%%%%%%%%%%%%%%%%%%% Messages Recharge niv 1 %%%%%%%%%%%%%%%%%%%%
-define(TXT_RECHARGE_TAPER,
	"Tapez sans leur faire mal les 14 chiffres de votre code de rechargement."
	".Appuyez sur . pour annuler. "
	"Attention, vous n.avez que 3 essais.*").
-define(TXT_RECHARGE_REFUSE,
	"Rechargement refuse: votre code n'est pas correct. "
	"Veuillez verifier votre code et renouveler l'operation. Merci.*").

-define(TXT_RECHARGE_SUCCESS_CLASSIQUE,
	"C'est parti! Vous avez effectue un rechargement classique d'un montant de .*E.*"
	"sur le tarif VeryLong. Le solde de votre credit est de .*E valable").

-define(TXT_RECHARGE_SUCCESS_WORLD,
	"C'est parti ! Vous venez de souscrire au tarif international. "
	"Le solde de votre credit est de .*E valable jusqu'au ../../... A bientot").

-define(TXT_RECHARGE_SELECT_TARIF,
	"Selection tarif:."
	"1:VerySMS-SMS a 1 ct.*"
	"2:VeryVoix-appel a 0,27E.*"
	"3:VeryLong-DLV les . longues.*"
	"4:decouvrir tarifs en detail").

-define(TXT_RECHARGE_SUCCESS_VERYSMS,
	"C'est parti ! Vous utilisez VerySMS. Vous avez recharge votre compte Virgin Mobile de.*").

-define(TXT_RECHARGE_SUCCESS_VERYVOIX,
	"C'est parti ! Vous utilisez VeryVoix. Vous avez recharge votre compte Virgin Mobile de.*").

-define(TXT_RECHARGE_SUCCESS_VERYLONG,
	"C'est parti ! Vous utilisez VeryLong. Vous avez recharge votre compte Virgin Mobile de.*").

-define(TXT_RECHARGE_TARIF_DETAIL,
	"1:decouvrir le tarif VerySMS."
	"2:decouvrir le tarif VeryVoix."
	"3:decouvrir le tarif VeryLong."
	"4:menu precedent").

-define(TXT_RECHARGE_VERYSMS_DETAIL,
	"VerySMS: SMS a 1 ct / appel a 42 centimes.."
	"Montants dispo: 10E-15j, 15E-21j, 20E-1 mois, 30E-45 jours, 40E-2 mois..").

-define(TXT_RECHARGE_VERYVOIX_DETAIL,
	"VeryVoix: SMS a 10 cts / appel a 27 centimes.."
	"Montants dispo: 10E-15j, 15E-21j, 20E-1 mois, 30E-45 jours, 40E-2 mois..").

-define(TXT_RECHARGE_VERYGOOD_DETAIL,
	"Very Goodtime: 10mn offertes au-dela des 3 premieres mn"
	".SMS 10cts / appel 42cts"
	".Montants: 10E-15j, 15E-21j, 20E-1 mois, 30E-45 jours, 40E-2 mois.").

-define(TXT_RECHARGE_VERYLONG_DETAIL,
	"VeryLong: SMS a 10 cts / appel a 42 centimes.."
	"Montants dispo: 5E-15j, 10E-1 mois, 15E-2 mois, 20E-3 mois, 30E-4 mois, 40E-5 mois..").

-define(TXT_RECHARGE_VERY_SUITE,
        "1:recharger sur ce tarif."
        "2:menu precedent").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text_opt_very(Opt_very) ->
    {value,{_,Txt_very,_}}=lists:keysearch(Opt_very, 1, ?LIST_OPT_TO_TEST),
    Txt_very++"!.".

text_ac_ac_oneoftwo_ok(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_AC_AC_ONEOFTWO_OK.

text_ac_ac_ep_ep(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_AC_AC_EP_EP.

text_ac_ep_oneoftwo_ok(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_AC_EP_ONEOFTWO_OK.

text_ac_ep_ep_ep(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_AC_EP_EP_EP.

text_ep_ac_ac_undefined(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_EP_AC_AC_UNDEFINED.

text_ep_ac_ep_ac(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_EP_AC_EP_AC.

text_ep_ac_ep_ep(Opt_very) ->
    text_opt_very(Opt_very)++?TXT_EP_AC_EP_EP.

%%% The following part concerns messages to be displayed for suivi conso
expected(#cpte_test{princ=Princ,niv=_,cpte_odr=?AC,cpte_opt=Opt,opt_very=Opt_very,cpte_rsi=RSI,cpte_osi=OSI}=CPTE)
  when (((Princ==?AC) or (Opt==?AC)) and ((RSI==?AC) or (OSI==?AC)))->
    text_ac_ac_oneoftwo_ok(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=?AC,cpte_opt=Opt,opt_very=Opt_very,cpte_rsi=RSI,cpte_osi=OSI}=CPTE)
  when (((Princ==?AC) or (Opt==?AC)) and (RSI=/=?AC) and (OSI=/=?AC))->
    text_ac_ac_ep_ep(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=ODR,cpte_opt=Opt,opt_very=Opt_very,cpte_rsi=RSI,cpte_osi=OSI}=CPTE)
  when ((Princ==?AC) or (Opt==?AC) andalso (ODR=/=?AC) andalso (RSI==?AC) or (OSI==?AC)) ->
    text_ac_ep_oneoftwo_ok(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=ODR,cpte_opt=Opt,opt_very=Opt_very,cpte_rsi=RSI,cpte_osi=OSI}=CPTE)
  when ((Princ==?AC) or (Opt==?AC) andalso (ODR=/=?AC) andalso (RSI=/=?AC) and (OSI=/=?AC))->
    text_ac_ep_ep_ep(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=?AC,cpte_opt=Opt,opt_very=Opt_very,cpte_rsi=?AC,cpte_osi=_}=CPTE) 
  when ((Princ=/=?AC) and (Opt=/=?AC))->
    text_ep_ac_ac_undefined(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=?AC,cpte_opt=_,opt_very=Opt_very,cpte_rsi=_,cpte_osi=?AC}=CPTE) 
  when (Princ=/=?AC)->
    text_ep_ac_ep_ac(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=?AC,cpte_opt=_,opt_very=Opt_very,cpte_rsi=_,cpte_osi=_}=CPTE) 
  when (Princ=/=?AC)->
    text_ep_ac_ep_ep(Opt_very)++expected1(CPTE,case1)++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=_,cpte_opt=_,opt_very=_,cpte_rsi=?AC,cpte_osi=_}=CPTE)
  when (Princ=/=?AC)->
    expected1(CPTE,case2)++?TXT_EP_EP_AC_UNDEFINED++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=_,cpte_opt=_,opt_very=_,cpte_rsi=_,cpte_osi=?AC}=CPTE)
  when (Princ=/=?AC)->
    expected1(CPTE,case2)++?TXT_EP_EP_EP_AC++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU;

expected(#cpte_test{princ=Princ,niv=_,cpte_odr=_,cpte_opt=_,opt_very=_,cpte_rsi=_,cpte_osi=_}=CPTE)
  when (Princ=/=?AC)->
    expected1(CPTE,case2)++?TXT_EP_EP_EP_EP++expected2(CPTE) ++ ?TXT_SELFCARE_RECHARGE_MENU.

%%% The following part concerns messages of suivi conso plus 
expected1(#cpte_test{niv=_,cpte_opt_voix=?AC,cpte_opt_sms=?AC},case1)-> ?TXT_SUIVI_CONSO_PLUS_AC_AC_1;

expected1(#cpte_test{niv=_,cpte_opt_voix=?AC,cpte_opt_sms=_},case1)-> ?TXT_SUIVI_CONSO_PLUS_AC_NOAC_1;

expected1(#cpte_test{niv=_,cpte_opt_voix=_,cpte_opt_sms=?AC},case1)-> ?TXT_SUIVI_CONSO_PLUS_NOAC_AC_1;

expected1(#cpte_test{niv=_,cpte_opt_voix=_,cpte_opt_sms=_},case1)-> [];

expected1(#cpte_test{niv=_,cpte_opt_voix=?AC,cpte_opt_sms=?AC},case2)-> ?TXT_SUIVI_CONSO_PLUS_AC_AC_2;

expected1(#cpte_test{niv=_,cpte_opt_voix=?AC,cpte_opt_sms=_},case2)-> ?TXT_SUIVI_CONSO_PLUS_AC_NOAC_2;

expected1(#cpte_test{niv=_,cpte_opt_voix=_,cpte_opt_sms=?AC},case2)-> ?TXT_SUIVI_CONSO_PLUS_NOAC_AC_2;

expected1(#cpte_test{niv=_,cpte_opt_voix=_,cpte_opt_sms=_},case2)-> ?TXT_SUIVI_CONSO_PLUS_NOAC_NOAC_2.

%% Message of credit data
expected2(#cpte_test{cpte_data=?AC}) -> ?TXT_CREDIT_DATA;
expected2(_) -> [].

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
    test_util_of:online(?MODULE,selfcare()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


selfcare() ->

    [ "Test du service *144# Virgin." ] ++
        test_util_of:set_present_period_for_test(commercial_date_virgin_pp,
 						 [opt1_virg_30j,
 						  opt2_virg_30j,
 						  opt3_virg_30j,
 						  opt4_virg_30j]) ++

	profile_manager:create_default(?Uid,"virgin_prepaid")++
	profile_manager:init(?Uid)++

 	selfcare_test() ++
 	test_tarifs()++
 	selfcare_refill()++

 	test_util_of:close_session() ++
	[ "Test reussi." ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfcare_test() ->
    ["SELFCARE Virgin Prepaid"] ++
 	test_all_cases(?CASES_VIRGIN) ++
	[].
selfcare_refill() ->    
    ["SELFCARE RECHARGE Virgin Prepaid"] ++
	test_recharge(?CASES_VIRGIN) ++
	test_recharge_rsi2(?CASES_VIRGIN)++
        [].

%%%%%%%%%%%%%%%%%%%%%%%%% Test recharge RSI2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_recharge_rsi2([]) -> [];
test_recharge_rsi2([H|T]) ->
    modify_account_state(H)++						  
	[  {title, "Test de rechargement RSI2: " ++display_test_account(H)},
	   "Cas Classique",
	   {ussd2,
	    [ {send, code_recharge(H)},
	      {expect,
	       "Tapez sans leur faire mal les 14 chiffres de votre code de rechargement."
	       ".Appuyez sur . pour annuler. "
	       "Attention, vous n.avez que 3 essais.*"}
	     ]
	   }]++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1, montant=10000}],
                                                                  ttk_num=142})++
	[
	   "Code CG OK - Rechgt Virgin RSI2",
	   {ussd2,
	    [ {send, code_recharge(H)++"*12345678912353#"},
	      {expect,"C'est parti ! Vous venez de souscrire a la recharge SMS illimites."}
	     ]}
	  ]++
	test_recharge_rsi2(T).


%%%%%%%%%%%%%%%%%%%%%%%%%%% Test recharge all cases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_recharge([])-> [];

test_recharge([H|T]) ->
    modify_account_state(H)++
	[
	 {title, "Test de rechargement Suivi-conso: " ++display_test_account(H)},
	 "Cas Classique",
	 {ussd2,
	  [ {send, code_recharge(H)},
	    {expect,?TXT_RECHARGE_TAPER}
	   ]
	 },
	 "Code CG FAUX",
	 {ussd2,
	  [ {send, code_recharge(H)++"*123456#"},
	    {expect,?TXT_RECHARGE_REFUSE}
	   ]
	 }]++

	modify_account_state(H)++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1, montant=10000}],
                                                                  ttk_num=106})++
	[
	 "Code CG OK",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912324#"},
	    {expect,?TXT_RECHARGE_SUCCESS_CLASSIQUE}
	   ]}]++

	modify_account_state(H)++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1, montant=10000}],
                                                                  ttk_num=181})++
        [
         "Code CG OK & Veryworld Europe",
         {ussd2,
          [ {send, code_recharge(H)++"*12345678912324#"},
            {expect,?TXT_RECHARGE_SUCCESS_WORLD}
           ]}]++

	modify_account_state(H)++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1, montant=10000}],
                                                                  ttk_num=182})++
        [
         "Code CG OK & Veryworld Maghreb",
         {ussd2,
          [ {send, code_recharge(H)++"*12345678912324#"},
            {expect,?TXT_RECHARGE_SUCCESS_WORLD}
           ]}]++

	modify_account_state(H)++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1, montant=10000}],
                                                                  ttk_num=113})++
	[ 
	 "Code CG OK >= 10E Menu & VerySMS",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323#"},
	    {expect,?TXT_RECHARGE_SELECT_TARIF},
	    {send, "1"},
	    {expect,?TXT_RECHARGE_SUCCESS_VERYSMS}
	   ]}
	 ]++

	modify_account_state(H)++
	[
	 "Code CG OK >= 10E Menu & VeryVoix",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323#"},
	    {expect,?TXT_RECHARGE_SELECT_TARIF},
	    {send, "2"},
	    {expect,?TXT_RECHARGE_SUCCESS_VERYVOIX}
	   ]}]++

	modify_account_state(H)++
	[
	 "Code CG OK >= 10E Menu & VeryLong",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323#"},
	    {expect,?TXT_RECHARGE_SELECT_TARIF},
	    {send, "3"},
	    {expect,?TXT_RECHARGE_SUCCESS_VERYLONG}
	   ]}]++

	modify_account_state(H)++
	[
	 "Code CG OK >= 10E Menu & Decouvrir Tarif",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323#"},
	    {expect,?TXT_RECHARGE_SELECT_TARIF},
	    {send, "4"},
	    {expect,?TXT_RECHARGE_TARIF_DETAIL}
	   ]},
	 "Code CG OK >= 10E Menu & Decouvrir Tarif: VerySMS",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323*"++"41#"},
	    {expect,?TXT_RECHARGE_VERYSMS_DETAIL++?TXT_RECHARGE_VERY_SUITE}
	   ]},
	 "Code CG OK >= 10E Menu & Decouvrir Tarif: VeryVoix",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323*"++"42#"},
	    {expect,?TXT_RECHARGE_VERYVOIX_DETAIL++?TXT_RECHARGE_VERY_SUITE}
	   ]},
	 "Code CG OK >= 10E Menu & Decouvrir Tarif: VeryLong",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323*"++"43#"},
	    {expect,?TXT_RECHARGE_VERYLONG_DETAIL++?TXT_RECHARGE_VERY_SUITE},
	    {send,"1"},
	    {expect,?TXT_RECHARGE_SUCCESS_VERYLONG}
	   ]}
	]++
	modify_account_state(H)++
	[
	 "Code CG OK >= 10E Menu & Decouvrir Tarif: menu precedent",
	 {ussd2,
	  [ {send, code_recharge(H)++"*12345678912323*"++"44#"},
	    {expect,?TXT_RECHARGE_SELECT_TARIF}
	   ]}
	]++
        test_recharge(T).

code_recharge(Cpte) ->
    case lists:flatlength(expected(Cpte)) > 181 of
        true ->
            ?DIRECT_CODE++"*12";
        _ ->
            ?DIRECT_CODE++"*2"
    end.

