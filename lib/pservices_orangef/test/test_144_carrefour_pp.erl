-module(test_144_carrefour_pp).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").
-include("profile_manager.hrl").

-define(DIRECT_CODE,"*144").
-define(END_UNIX,1091746939).
-define(Uid, user_carrefour_pp).

-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2
-define(PE, ?CETAT_PE). %3

-define(LIST_STATES_TO_TEST,[{?AC,"actif"},
                             {?EP,"epuise"}
                            ]).

-define(LIST_LEVELS_TO_TEST,[{1,"Niveau 1"},
			     {2,"Niveau 2"},
			     {3,"Niveau 3"}]).

-define(IMEI_NIV1,    "35061310100006").
-define(IMEI_NIV2,    "100006XXXXXXX2").
-define(IMEI_NIV3,    "100005XXXXXXX3").

-define(LIST_PTF_TO_TEST,[{?PTF_CARREFOUR_PP, "default PTF"},
                          {?PTF_CARREFOUR_PP2,"PTF Soir & Weekend"},
                          {?PTF_CARREFOUR_PP3,"PTF No Prefere Cross Net"},
                          {?PTF_CARREFOUR_PP4,"PTF Cross Net"}]).

-record(cpte_test,{plan,princ,niv}).


-define(ALL_CASES_CARREFOUR, [#cpte_test{plan=P,princ=S1,niv=N} || 
                                 {P, _} <- ?LIST_PTF_TO_TEST,
                                 {S1,_} <- ?LIST_STATES_TO_TEST,
                                 {N,_}  <- ?LIST_LEVELS_TO_TEST]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generic functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

state_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_STATES_TO_TEST),
    Nom.

level_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_LEVELS_TO_TEST),
    Nom.

ptf_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_PTF_TO_TEST),
    Nom.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_test_account(#cpte_test{plan=P,princ=E1,niv=Niv}) ->
    "Carrefour PP Suivi-conso "++level_name(Niv)++ 
    " COMPTE PRINCIPAL"++" "++state_name(E1)++
    " COMPTE RECH SMS ILLIMITE " ++ state_name(E1)++
    "Plan Tarifaire: "++ptf_name(P)++" ".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
link_home_1(1)->
    "1";
link_home_1(2) ->
    "1";
link_home_1(3) ->
    "11".

link_home_2(1)->
    "2";
link_home_2(2) ->
    "2";
link_home_2(3) ->
    "12".

link_expect_1(1)->
    "0";
link_expect_1(2) ->
    "0";
link_expect_1(3) ->
    "1*0".

link_expect_2(1)->
    "1";
link_expect_2(2) ->
    "1";
link_expect_2(3) ->
    "11".
consult_account(#cpte_test{niv=3}=Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
        {expect, expected_home(Cpte)},
        {send, link_home_1(3)},
        {expect, expected_1(Cpte)},
        {send, link_expect_1(3)},
        {expect, expected_home(Cpte)},
        {send, link_home_2(3)},
        {expect, expected_2(Cpte)},
        {send, link_expect_2(3)},
        {expect, ".*"},
	{send, "1"},
	{expect, ".*"},
	{send, "1"},
	{expect, ".*"}
       ]}
    ];
consult_account(#cpte_test{niv=Niv}=Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected_home(Cpte)},
	{send, link_home_1(Niv)},
	{expect, expected_1(Cpte)},
	{send, link_expect_1(Niv)},
	{expect, expected_home(Cpte)},
	{send, link_home_2(Niv)},
	{expect, expected_2(Cpte)},
	{send, link_expect_2(Niv)},
	{expect, ".*"}
       ]}     
    ].

test_all_cases([]) -> [];
test_all_cases([H|T]) ->
    modify_account_state(H,15) ++ consult_account(H) ++ test_all_cases(T).


modify_account_state(#cpte_test{plan=P,princ=E1,niv=Niv},Solde) ->
    profile_manager:set_dcl(?Uid,?DCLNUM_CARREFOUR_PREPAID)++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_RECH_SMS_ILLM,unt_num=?EURO,cpp_solde=Solde*1000,
                                                  dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(31),{0,0,0}}),
                                                  rnv=0,etat=E1,ptf_num=P},
					  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=Solde*1000,
						  dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(31),{0,0,0}}),
						  rnv=0,etat=E1,ptf_num=P},
					  #compte{tcp_num=?C_CARREFOUR_Z1,unt_num=?EURO,cpp_solde=24000,
						  dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(15),{0,0,0}}),
						  rnv=0,etat=?AC,ptf_num=?PTF_CARREFOUR_Z1},
					  #compte{tcp_num=?C_CARREFOUR_Z2,unt_num=?EURO,cpp_solde=26500,
						  dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(14),{0,0,0}}),
						  rnv=0,etat=?AC,ptf_num=?PTF_CARREFOUR_Z2},
					  #compte{tcp_num=?C_CARREFOUR_Z3,unt_num=?EURO,cpp_solde=39500,
						  dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(13),{0,0,0}}),
						  rnv=?AC,etat=?AC,ptf_num=?PTF_CARREFOUR_Z3}])++
	case Niv of
	    1->
		profile_manager:set_imei(?Uid,?IMEI_NIV1);
	    2->
		profile_manager:set_imei(?Uid,?IMEI_NIV2);
	    3->
		profile_manager:set_imei(?Uid,?IMEI_NIV3)
	end ++
        [].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define expected results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(TXT_DATE, "../../...*").

-define(TXT_NIV1_AC, "Bienvenue sur Carrefour Mobile.*Au .* Vous disposez "
"d'un solde de .* euros sur votre compte rechargeable.*1:Recharger.*2:Suivi conso+").
-define(TXT_NIV1_EP, "Votre compte est epuise merci de le recharger").

-define(TXT_NIV2_AC, "Au .* Vous disposez d'un solde de .* euros sur votre "
"compte rechargeable..*1:Recharger.*2:Suivi conso+").
-define(TXT_NIV2_EP, "Votre compte est epuise merci de le recharger.*").

-define(TXT_NIV3_AC, "Au .* Solde compte rechargeable = .* euros.*1:-->").
-define(TXT_NIV3_EP, "Votre compte est epuise merci de le recharger").

-define(TXT_NEXT, "Veuillez saisir le code de rechargement "
"\\(14 chiffres\\).*").

-define(TXT_CONSO, "Compte Europe : 24.00 euros jusqu'au .*"
"Compte Maghreb/Turquie/Amerique du Nord : 26.50 euros jusqu'au .*"
"Compte Monde : 39.50 euros jusqu'au .*").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expected_home(#cpte_test{princ=?AC,niv=1}) -> 
    ?TXT_NIV1_AC;
expected_home(#cpte_test{princ=?EP,niv=1}) ->
    ?TXT_NIV1_EP;
expected_home(#cpte_test{princ=?AC,niv=2}) -> 
    ?TXT_NIV2_AC;
expected_home(#cpte_test{princ=?EP,niv=2}) ->
    ?TXT_NIV2_EP;
expected_home(#cpte_test{princ=?AC,niv=3}) ->
    ?TXT_NIV3_AC;
expected_home(#cpte_test{princ=?EP,niv=3}) -> 
    ?TXT_NIV3_EP.

expected_1(#cpte_test{princ=?AC,niv=1}) ->
    ?TXT_NEXT;
expected_1(#cpte_test{princ=?EP,niv=1}) ->
    ?TXT_NEXT;
expected_1(#cpte_test{princ=?AC,niv=2}) ->
    ?TXT_NEXT;
expected_1(#cpte_test{princ=?EP,niv=2}) ->
    ?TXT_NEXT;
expected_1(#cpte_test{princ=?AC,niv=3}) ->
    ".*";
expected_1(#cpte_test{princ=?EP,niv=3}) ->
    ".*";
expected_1(_) ->
    ".*".

expected_2(#cpte_test{niv=1}) ->
    ?TXT_CONSO;
expected_2(#cpte_test{niv=2}) ->
    ".*";
expected_2(#cpte_test{niv=3}) ->
    ".*".


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
    [ "Test du service *144# Carrefour." ] ++
	profile_manager:create_default(?Uid,"carrefour_prepaid")++
        profile_manager:init(?Uid)++
	selfcare_test() ++
	test_refill() ++
	test_util_of:close_session()++
	[ "Test reussi." ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfcare_test() ->
    ["SELFCARE Carrefour Prepaid"] ++
    test_all_cases(?ALL_CASES_CARREFOUR) ++
    [].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_refill_ok(Z)->
    case Z of
	1->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ctk_num=?CTK_CARREFOUR_Z1,
								      accounts=[#account{tcp_num=1, montant=15000,
								      dlv=pbutil:unixtime()}]})++
	    [
	     "Code CG OK - Compte Z1",
	     {ussd2,
	      [ {send, ?DIRECT_CODE++"*112345678912315#"},
		{expect,"Votre rechargement a ete pris en compte. Votre nouveau"
                 " solde Compte Europe est 24.00 Euros.*0:Retour.*00:Menu.*"},
		{send, "00"},
		{expect,"Bienvenue sur Carrefour Mobile"}
	       ]}
	    ];
	2 ->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ctk_num=?CTK_CARREFOUR_Z2,
								      accounts=[#account{tcp_num=1, montant=15000,
                                                                      dlv=pbutil:unixtime()}]})++
	    ["Code CG OK - Compte Z2",
	     {ussd2,
	      [ {send, ?DIRECT_CODE++"*112345678912316#"},
		{expect,"Votre rechargement a ete pris en compte. Votre nouveau"
                " solde Compte Maghreb/Turquie/Amerique du Nord est 26.50 Euros.*0:Retour.*00:Menu.*"},
		{send, "00"},
		{expect,"Bienvenue sur Carrefour Mobile"}
	       ]}
	    ];
	3 ->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ctk_num=?CTK_CARREFOUR_Z3,
								      accounts=[#account{tcp_num=1, montant=15000,
								      dlv=pbutil:unixtime()}]})++
	    ["Code CG OK - Compte Z3",
	     {ussd2,
	      [ {send, ?DIRECT_CODE++"*112345678912317#"},
		{expect,"Votre rechargement a ete pris en compte. Votre nouveau"
		 " solde Compte Monde est 39.50 Euros.*0:Retour.*00:Menu.*"},
		{send, "00"},
		{expect,"Bienvenue sur Carrefour Mobile"}
	       ]}
	    ];
	4 ->
	    
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=5,
						   accounts=[#account{tcp_num=?C_RECH_SMS_ILLM, 
											 montant=15000,
											 dlv=pbutil:unixtime()}]})++
            ["Code CG OK - RECH SMS ILL - TTK=5",
             {ussd2,
              [ {send, ?DIRECT_CODE++"*112345678912318#"},
                {expect,"Votre rechargement a ete pris en compte. SMS Illimites valable jusqu'au.*0:Retour.*00:Menu.*"},
                {send, "00"},
                {expect,"Bienvenue sur Carrefour Mobile"}
               ]}
            ];
	5 ->
            profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=180,
                                                   accounts=[#account{tcp_num=?C_RECH_SMS_ILLM,
                                                                                         montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
            ["Code CG OK - RECH SMS ILL - TTK=180",
             {ussd2,
              [ {send, ?DIRECT_CODE++"*112345678912318#"},
                {expect,"Votre rechargement a ete pris en compte. SMS Illimites valable jusqu'au.*0:Retour.*00:Menu.*"},
                {send, "00"},
                {expect,"Bienvenue sur Carrefour Mobile"}
               ]}
            ];
	6 ->  
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=178,
                                                   accounts=[#account{tcp_num=?C_RECH_SMS_ILLM,
                                                                                         montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
            ["Code CG OK - RECH SMS ILL - TTK=178",
             {ussd2,
              [ {send, ?DIRECT_CODE++"*112345678912318#"},
                {expect,"Votre rechargement a ete pris en compte. SMS Illimites valable jusqu'au.*0:Retour.*00:Menu.*"},
                {send, "00"},
                {expect,"Bienvenue sur Carrefour Mobile"}
               ]}
            ];
	_ ->
	    []
    end.
	    
test_refill_error(Code)->
    profile_manager:set_sachem_response(?Uid,{?rec_tck,{nok,{status, Code}}})++
    [
     "Code CG NOK - Erreur ",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*112345678912319#"},
        {expect,"Ce numero est incorrect. Veuillez, de nouveau, entrer les 14 chiffres situes au dos de votre recharge Carrefour Mobile.*0:Retour.*00:Menu.*"}
       ]}].

test_refill()->
    modify_account_state(#cpte_test{princ=?AC,plan=?PTF_CARREFOUR_PP,niv=1},0)++
    [
    {title, "Test de rechargement Suivi-conso"},
    "Cas Classique",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*1#"},
       {expect,"Veuillez saisir le code de rechargement \\(14 chiffres\\).*0:Retour.*00:Menu.*"}]
      },
     "BAD LENGTH CODE",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*123456#"},
        {expect,"Ce numero est incorrect. Veuillez, de nouveau, entrer les "
         "14 chiffres situes au dos de votre recharge Carrefour Mobile.*0:Retour.*00:Menu.*"}]
     },
     "CODE WITHOUT DIGITS",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*123DEFGH8912341#"},
        {expect,"Ce numero est incorrect. Veuillez, de nouveau, entrer les "
         "14 chiffres situes au dos de votre recharge Carrefour Mobile.*0:Retour.*00:Menu.*"}]
     },
     "Code CG OK",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*112345678912341#"},
        {expect,"Votre rechargement a ete pris en compte. Votre nouveau"
                " solde est .* Euros.*0:Retour.*00:Menu.*"},
        {send, "00"},
        {expect,"Bienvenue sur Carrefour Mobile"}
       ]}
    ] ++
	test_refill_ok(1)++
 	test_refill_ok(2)++
 	test_refill_ok(3)++
	test_refill_ok(4)++
	test_refill_ok(5)++
	test_refill_ok(6)++
 	test_refill_error([10,5])++
	test_refill_error([10])++
	[]. 
