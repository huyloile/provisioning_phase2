-module(test_144_monacell_pp).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").

-define(DIRECT_CODE,"*144").
-define(msisdn, "9905000001").
-define(imsi,     "999000905000001").
-define(END_UNIX,1091746939).

-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2
-define(PE, ?CETAT_PE). %3

-define(LIST_STATES_TO_TEST,[{?AC,"actif"},
                             {?EP,"epuise"}
                            ]).

-define(LIST_LEVELS_TO_TEST,[{1,"Niveau 1"},
			     {2,"Niveau 2"},
			     {3,"Niveau 3"}]).


-record(cpte_test,{plan,princ,niv}).


-define(ALL_CASES_MONACELL, [#cpte_test{plan=?PTF1_MONACELL_PP,princ=S1,niv=N} || 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_test_account(#cpte_test{plan=P,princ=E1,niv=Niv}) ->
    "Monacell PP Suivi-conso "++level_name(Niv)++
    " COMPTE PRINCIPAL"++" "++state_name(E1)++" ".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consult_account(Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected(Cpte)}
       ]}     
    ].

test_all_cases([]) -> [];
test_all_cases([H|T]) ->
    modify_account_state(H,15) ++ consult_account(H) ++ test_all_cases(T).


modify_account_state(#cpte_test{plan=P,princ=E1,niv=Niv},Solde) ->
    test_util_of:change_navigation_to_niv(Niv, ?imsi)++
    test_util_of:insert(?imsi,?DCLNUM_MONACELL_PREPAID,0,
			    [#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=Solde*1000,
				     dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(31),{0,0,0}}),
				     rnv=0,
				     etat=E1,
				     ptf_num=?PTF2_MONACELL_PP}]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define expected results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(TXT_DATE, "../../...*").

-define(TXT_NIV1_AC, "Bienvenue sur Monaco Telecom.*Au .* Vous disposez "
"d'un solde de .* euros sur votre compte rechargeable.*1:Recharger").
-define(TXT_NIV1_EP, "Votre compte est epuise merci de le recharger").

-define(TXT_NIV2_AC, "Au .* Vous disposez d'un solde de .* euros sur votre "
"compte rechargeable..*").
-define(TXT_NIV2_EP, "Votre compte est epuise merci de le recharger.*").

-define(TXT_NIV3_AC, "Au .* Solde compte rechargeable = .* euros.*").
-define(TXT_NIV3_EP, "Votre compte est epuise merci de le recharger").

-define(TXT_NEXT, "Veuillez saisir le code de rechargement "
"\\(14 chiffres\\).*").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expected(#cpte_test{princ=?AC,niv=1}) -> 
    ?TXT_NIV1_AC;
expected(#cpte_test{princ=?EP,niv=1}) ->
    ?TXT_NIV1_EP;
expected(#cpte_test{princ=?AC,niv=2}) -> 
    ?TXT_NIV2_AC;
expected(#cpte_test{princ=?EP,niv=2}) ->
    ?TXT_NIV2_EP;
expected(#cpte_test{princ=?AC,niv=3}) ->
    ?TXT_NIV3_AC;
expected(#cpte_test{princ=?EP,niv=3}) -> 
    ?TXT_NIV3_EP.

expected2(#cpte_test{princ=?AC,niv=1}) ->
    ?TXT_NEXT;
expected2(#cpte_test{princ=?EP,niv=1}) ->
    ?TXT_NEXT;
expected2(_) ->
    ".*".

today_plus_datetime(Days) ->
    svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(Days),{0,0,0}}).
    

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
    [ "Test du service *144# Monacell." ] ++
    test_util_of:connect() ++
    test_util_of:insert_imsi_db(?imsi) ++
    test_util_of:change_subscription(?imsi,"monacell_prepaid")++
    test_util_of:ocf_set(?imsi,"monacell_prepaid")++
    test_util_of:set_in_sachem(?imsi,"monacell_prepaid")++ 
    selfcare_test() ++
    test_refill() ++ 
    test_bons_plans()++
    test_util_of:close_session()++
    [ "Test reussi." ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfcare_test() ->
    ["SELFCARE Monacell Prepaid"] ++
    test_all_cases(?ALL_CASES_MONACELL) ++
    [].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_refill()->
    modify_account_state(#cpte_test{princ=?AC,plan=?PTF3_MONACELL_PP,niv=1},0)++
    [
    {title, "Test de rechargement Suivi-conso"},
    "Cas Classique",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*1#"},
       {expect,"Veuillez saisir le code de rechargement \\(14 chiffres\\).*"},
       {send, "00"},
       {expect,".*"}
      ]
      },
     "BAD LENGTH CODE",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*123456#"},
        {expect,"Rechargement refuse: votre code n'est pas correct."
        " Veuillez verifier votre code et renouveler l'operation. Merci."}]
     },
     "CODE WITHOUT DIGITS",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*123DEFGH8912341#"},
        {expect,"Rechargement refuse: votre code n'est pas correct."
        " Veuillez verifier votre code et renouveler l'operation. Merci."}]
     },
     "Code CG OK",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*112345678912341#"},
        {expect,"Votre rechargement a ete pris en compte. Votre nouveau"
                " solde est .* Euros.*00:Menu"},
        {send, "00"},
        {expect,"Bienvenue sur Monaco Telecom"}
       ]}
   ]. 

test_bons_plans() ->
    modify_account_state(#cpte_test{princ=?AC,plan=?PTF3_MONACELL_PP,niv=1},8)++
    test_util_of:set_present_period_for_test(commercial_date_monacell_pp,opt_sms_illimite)++
    test_util_of:insert_list_top_num_and_c_op_fields(?msisdn,
                                                     [0,394],
                                                     0625043749,
                                                     pbutil:unixtime(),
                                                     today_plus_datetime(31),
                                                     0,0
                                                    )++
    [
    {title, "Test de Monacel Bons plans"},
    "Bonus deja souscrit - Compte principal actif",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*2#"},
       {expect,"Vous beneficiez deja du bonus pour le mois en cours.*00:Menu"},
       {send, "00"},
       {expect,"Bienvenue sur Monaco Telecom.*"
        "1:Recharger.*2:Bons plans"}
       ]
      }]++
    test_util_of:insert_list_top_num_and_c_op_fields(?msisdn,
                                                     [0],
                                                     0625043749,
                                                     pbutil:unixtime(),
                                                     pbutil:unixtime(),
                                                     0,0
                                                    )++
    [
    {title, "Test de Monacel Bons plans"},
    "Menu bons plans",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*2#"},
       {expect,
        "1:Souscrire.*"
        "2:Plus d'infos.*"
        "3:Mentions legales"}
      ]
      },
     "Souscrire",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*21#"},
        {expect,"Merci de bien vouloir taper les 10 chiffres du numero de votre choix. "
         "C'est a vous !.*"},
        {send, "0512345678"},
        {expect, "Le numero saisi n'est pas reconnu comme un numero mobile Monaco Telecom.*1:Recommencer"},
        {send, "1"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*0:Retour.*00:Menu"},
        {send, "0"},
        {expect, "Bon plan 1 numero SMS illimite.*"},
        {send, "1"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*0:Retour.*00:Menu"},
        {send, "0427043779"},
        {expect, "Le numero saisi n'est pas reconnu comme un numero mobile Monaco Telecom.*1:Recommencer"},
        {send, "1"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*0:Retour.*00:Menu"},
        {send, "0637043744"},
        {expect, "Le numero que vous venez de choisir est le 0637043744.*1:Confirmer.*2:Recommencer"},
        {send, "2"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*"},
        {send, "0737043744"},
        {expect, "Le numero que vous venez de choisir est le 0737043744.*1:Confirmer.*2:Recommencer"},
        {send, "2"},
        {send, "0666666666"},
        {expect, "Le numero saisi n'est pas reconnu comme un numero mobile.*1:Recommencer"},
        {send, "1"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*0:Retour.*00:Menu"},
        {send, "0626437411"},
        {expect, "Le numero que vous venez de choisir est le 0626437411.*1:Confirmer.*2:Recommencer"},
        {send, "1"},
        {expect, "Prepaye Monaco Telecom : vous beneficiez des a present de SMS illimite vers le 0626437411.*"},
        {send, "00"},
        {expect, "Bienvenue.*"}]
     },
     "Plus d'info",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*22#"},
        {expect,"Nouveau ! Avec le bon plan 1 no SMS illimite, envoyez des SMS.*1:Suite"},
        {send, "1"},
        {expect, "Le numero choisi est valable 31 jours.*0:Retour"},
        {send, "0"},
        {expect, "Nouveau ! Avec le bon plan.*"},
        {send, "0"},
        {expect, "Bon plan 1 numero SMS illimite.*"}
        ]
     },
     "Mentions legales",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*23#"},
        {expect,"Option valable a Monaco et en France metropolitaine.*1:Suite.*0:Retour"},
        {send, "1"},
        {expect,"SMS illimites vers 1 seul et meme no.*1:Suite.*0:Retour"},
        {send, "1"},
        {expect, "Le prix de l'option est preleve sur le compte du client sous reserve d'un credit suffisant.*0:Retour"},
        {send, "0*0*0"},
        {expect, "Bon plan 1 numero SMS illimite : pour 5 euros.*"}
       ]}
    ]++
    modify_account_state(#cpte_test{princ=?AC,plan=?PTF3_MONACELL_PP,niv=1},6)++
    test_util_of:set_present_period_for_test(commercial_date_monacell_pp,opt_sms_illimite)++
    test_util_of:insert_list_top_num_and_c_op_fields(?msisdn,
                                                     [0,394],
                                                     0625043749,
                                                     pbutil:unixtime(),
                                                     pbutil:unixtime(),
                                                     0,0
                                                    )++
    [
    {title, "Test de Monacel Bons plans"},
    "Bonus - Compte principal Actif & Credit insuffisant",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*2#"},
       {expect,"Bon plan 1 numero SMS illimite.*"},
       {send, "1"},
       {expect,"Merci de bien vouloir taper les 10 chiffres du numero de votre choix. "
         "C'est a vous !.*"},
        {send, "0637043744"},
        {expect, "Le numero que vous venez de choisir est le 0637043744.*1:Confirmer.*2:Recommencer"},
        {send, "1"},
        {expect, "Le solde de votre compte ne permet pas la souscription a ce bonus.*00:Menu"},
        {send, "00"},
        {expect, "Bienvenue"}
       ]
      }]
    . 
