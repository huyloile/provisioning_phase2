-module(test_144_monacell_cb).
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

-define(LIST_DCL_TO_TEST,[?DCLNUM_MONACELL_COMPTEBLOQUE_1H, 
                          ?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN]).

-define(LIST_STATES_TO_TEST,[{?AC,"actif"},
                             {?EP,"epuise"}
                            ]).

-define(LIST_LEVELS_TO_TEST,[{1,"Niveau 1"},
			     {2,"Niveau 2"},
			     {3,"Niveau 3"}]).

-record(cpte_test,{dcl,plan,princ,forfait,niv}).

-define(ALL_CASES_MONACELL, [
                              #cpte_test{dcl=DCL,plan=?PTF_MONACELL_CB_40MIN,princ=S1,forfait=S2,niv=N} || 
                               DCL <- ?LIST_DCL_TO_TEST,
                               {S1,_} <- ?LIST_STATES_TO_TEST,
                               {S2,_} <- ?LIST_STATES_TO_TEST,
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

display_test_account(#cpte_test{dcl=DCL,plan=P,princ=E1,forfait=E2,niv=Niv}) ->
    "Monacell FB Suivi-conso "++level_name(Niv)++
    " COMPTE PRINCIPAL"++" "++state_name(E1)++
    " COMPTE FORFAIT MONACO FB"++" "++state_name(E2)++" ".

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


modify_account_state(#cpte_test{dcl=DCL,plan=P,princ=E1,forfait=E2,niv=Niv},Solde) ->
    test_util_of:change_navigation_to_niv(Niv, ?imsi)++
    test_util_of:insert(?imsi,DCL,0,
                        [#compte{tcp_num=?C_PRINC,
                                 unt_num=?EURO,
                                 cpp_solde=Solde*1000,
                                 dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(31),{0,0,0}}),
                                 rnv=0,
                                 etat=E1,
                                 ptf_num=?PTF_MONACELL_CB_1H},
                         #compte{tcp_num=?C_FORF_MONACO_FB,
                                 unt_num=?EURO,
                                 cpp_solde=Solde*1000,
                                 dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(31),{0,0,0}}),
                                 rnv=0,
                                 etat=E2,
                                 ptf_num=?PTF_MONACELL_CB_1H}
                         ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define expected results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(TXT_DATE, "../../...*").

-define(TXT_NIV1_AC_AC, "Monaco Telecom Bonjour, au .* a .* il vous reste .* sur votre forfait principal. Solde compte rechargeable = .* euros.*1:Recharger").
-define(TXT_NIV1_EP_AC, "Monaco Telecom Bonjour, au .* a .* votre forfait principal est epuise. Solde compte rechargeable = .* euros.*1:Recharger").
-define(TXT_NIV1_AC_EP, "Monaco Telecom Bonjour, au .* a .* il vous reste .* sur votre forfait principal. Votre compte rechargeable est epuise.*1:Recharger").
-define(TXT_NIV1_EP, "Votre compte principal est epuise merci de le recharger.*1:Recharger").

-define(TXT_NIV2_AC_AC, "Au .* a .* il vous reste .* sur votre forfait principal. Solde compte rechargeable = .* euros.").
-define(TXT_NIV2_EP_AC, "Au .* a .* votre forfait principal est epuise. Solde compte rechargeable = .* euros.").
-define(TXT_NIV2_AC_EP, "Au .* a .* il vous reste .* sur votre forfait principal. Votre compte rechargeable est epuise.").
-define(TXT_NIV2_EP, "Votre compte principal est epuise merci de le recharger.").

-define(TXT_NIV3_AC_AC, "Au .* il vous reste .* et .* euros de recharge").
-define(TXT_NIV3_EP_AC, "Au .* votre forfait est epuise .* euros de recharge").
-define(TXT_NIV3_AC_EP, "Au .* il vous reste .* et 0 euros de recharge").
-define(TXT_NIV3_EP, "Votre compte principal est epuise merci de le recharger.").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expected(#cpte_test{princ=?AC,forfait=?AC,niv=1}) -> 
    ?TXT_NIV1_AC_AC;
expected(#cpte_test{princ=?AC,forfait=?EP,niv=1}) -> 
    ?TXT_NIV1_EP_AC;
expected(#cpte_test{princ=?EP,forfait=?AC,niv=1}) ->
    ?TXT_NIV1_AC_EP;
expected(#cpte_test{princ=?EP,niv=1}) ->
    ?TXT_NIV1_EP;
expected(#cpte_test{princ=?AC,forfait=?AC,niv=2}) -> 
    ?TXT_NIV2_AC_AC;
expected(#cpte_test{princ=?AC,forfait=?EP,niv=2}) -> 
    ?TXT_NIV2_EP_AC;
expected(#cpte_test{princ=?EP,forfait=?AC,niv=2}) -> 
    ?TXT_NIV2_AC_EP;
expected(#cpte_test{princ=?EP,niv=2}) ->
    ?TXT_NIV2_EP;
expected(#cpte_test{princ=?AC,forfait=?AC,niv=3}) ->
    ?TXT_NIV3_AC_AC;
expected(#cpte_test{princ=?AC,forfait=?EP,niv=3}) ->
    ?TXT_NIV3_EP_AC;
expected(#cpte_test{princ=?EP,forfait=?AC,niv=3}) ->
    ?TXT_NIV3_AC_EP;
expected(#cpte_test{princ=?EP,niv=3}) -> 
    ?TXT_NIV3_EP.

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
    test_util_of:change_subscription(?imsi,"monacell_comptebloqu")++
    test_util_of:ocf_set(?imsi,"monacell_comptebloqu")++
    test_util_of:set_in_sachem(?imsi,"monacell_comptebloqu")++ 
    selfcare_test() ++
    test_refill() ++ 
    test_bons_plans()++
    test_util_of:close_session()++
    [ "Test reussi." ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfcare_test() ->
    ["SELFCARE Monacell Forfait bloques"] ++
    test_all_cases(?ALL_CASES_MONACELL) ++ 
    [].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_refill()->
    modify_account_state(#cpte_test{dcl=?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN,princ=?AC,forfait=?AC,plan=?PTF_MONACELL_CB_40MIN,niv=1},0)++
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
        {expect,"Monaco Telecom Bonjour"}
       ]}
   ]. 

test_bons_plans() ->
    modify_account_state(#cpte_test{dcl=?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN,princ=?AC,forfait=?AC,plan=?PTF_MONACELL_CB_40MIN,niv=1},6)++
    test_util_of:insert_list_top_num_and_c_op_fields(?msisdn,
                                                     [0,442],
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
       {expect,"Monaco Telecom Bonjour.*"
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
        "Bon plan 1 numero SMS illimite : pour 5 euros, envoyez des SMS en illimite 24H/24, 7J/7 vers un numero pendant 31 jours.*"
        "1:Souscrire.*"
        "2:Plus d'infos.*"
        "3:Mentions legales"}
      ]
      },
     "Souscrire",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*21#"},
        {expect,"Merci de bien vouloir taper les 10 chiffres du numero de votre choix. C'est a vous !.*"},
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
        {send, "0737043744"},
        {expect, "Le numero que vous venez de choisir est le 0737043744.*1:Confirmer.*2:Recommencer"},
        {send, "2"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*"},
        {send, "0666666666"},
        {expect, "Le numero saisi n'est pas reconnu comme un numero mobile.*1:Recommencer"},
        {send, "1"},
        {expect, "Merci de bien vouloir taper les 10 chiffres du numero de votre choix.*0:Retour.*00:Menu"},
        {send, "0626437411"},
        {expect, "Le numero que vous venez de choisir est le 0626437411.*1:Confirmer.*2:Recommencer"},
        {send, "1"},
        {expect, "Forfait Bloque Monaco Telecom : vous beneficiez des a present de SMS illimite vers le 0626437411.*"},
        {send, "00"},
        {expect, "Monaco Telecom Bonjour.*"}]
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
        {expect, "Le prix de l'option est preleve sur le compte rechargeable du client sous reserve d'un credit suffisant.*0:Retour"},
        {send, "0*0*0"},
        {expect, "Bon plan 1 numero SMS illimite : pour 5 euros.*"}
       ]}
   ]++
    modify_account_state(#cpte_test{dcl=?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN,princ=?AC,forfait=?AC,plan=?PTF_MONACELL_CB_40MIN,niv=1},4)++
    test_util_of:insert_list_top_num_and_c_op_fields(?msisdn,
                                                     [0,442],
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
        {expect, "Monaco Telecom Bonjour.*"}
       ]
      }]
    . 

