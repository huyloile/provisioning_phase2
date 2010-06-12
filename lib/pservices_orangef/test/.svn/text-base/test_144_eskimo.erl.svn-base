-module(test_144_eskimo).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").

-define(DIRECT_CODE,"*144").
-define(APPLLE_MOI_CODE,"#122").
-define(msisdn, "9905000001").
-define(imsi,     "999000905000001").
-define(msisdn_ko, "9905000007").
-define(imsi_ko,     "999000905000007").

-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2
-define(PE, ?CETAT_PE). %3

-define(top_num_frais_maint, 84).

-define(LIST_STATES_TO_TEST,[{?AC,"actif"},
                             {?EP,"epuise"}
                            ]).

-define(LIST_LEVELS_TO_TEST,[{1,"Niveau 1"},
			     {2,"Niveau 2"},
			     {3,"Niveau 3"}]).


-record(cpte_test,{plan,princ,niv}).

-define(ALL_CASES_ESKIMO, [
			   #cpte_test{plan=?PTF_symacom,princ=S1,niv=N} || 
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
    "SYMACOM PP Suivi-conso "++level_name(Niv)++
       " COMPTE PRINCIPAL"++" "++state_name(E1)++" ".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consult_account(Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected(Cpte)},
	{send,"1"},
	{expect, expected2(Cpte)}
       ]}     
    ].

test_all_cases([]) -> [];
test_all_cases([H|T]) ->
    modify_account_state(H,15) ++ consult_account(H) ++ test_all_cases(T).


modify_account_state(#cpte_test{plan=P,princ=E1,niv=Niv},Solde) ->
    test_util_of:change_navigation_to_niv(Niv, ?imsi)++ 
    modify_account_state(?imsi,#cpte_test{plan=P,princ=E1,niv=Niv},Solde).
modify_account_state(IMSI,#cpte_test{plan=P,princ=E1,niv=Niv},Solde) ->
    test_util_of:insert(IMSI,?decl_symacom,0,
                        [#compte{tcp_num=?C_PRINC,
                                 unt_num=?EURO,
                                 cpp_solde=Solde*1000,
                                 dlv=svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(31),{0,0,0}}),
                                 rnv=0,
                                 etat=E1,
                                 ptf_num=?PTF_symacom}]).

selfcare() ->
    [ "Test du service *144# Symacom." ] ++
    test_util_of:connect() ++
    test_util_of:insert_imsi_db(?imsi) ++
    test_util_of:change_subscription(?imsi,"symacom")++
    test_util_of:ocf_set(?imsi,"symacom")++
    test_util_of:set_in_sachem(?imsi,"symacom")++ 
    selfcare_test()++
    test_refill() ++
    [ "Test reussi." ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfcare_test() ->
    ["SELFCARE Symacom Prepaid"] ++
    test_all_cases(?ALL_CASES_ESKIMO) ++
    [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define expected results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(TXT_DATE, "../../...*").

-define(TXT_NIV1_AC, "Symacom Mobile bonjour. Votre credit est de 15.00"
                     " euros a utiliser avant le .*Recharger.*Connaitre" 
                    " les tarifs vers l'etranger.*").
-define(TXT_NIV1_EP, "Votre credit est epuise. Vous pouvez recharger votre compte avant "
	             "le .*et conserver ainsi votre numero.*Recharger.*Connaitre "
	             "les tarifs vers l'etrange.*").

-define(TXT_NIV2_AC, "Votre credit Symacom Mobile est de 15.00 euros a utiliser avant le .*").
-define(TXT_NIV2_EP, "Votre credit est epuise.*Recharger votre compte en appelant le 224 avant le .*pour conserver votre numero.*").

-define(TXT_NIV3_AC, "15.00 euros.* a utiliser avant le .*").
-define(TXT_NIV3_EP, "Merci de recharger au 224 avant le .*").

-define(TXT_NEXT, "Symacom Mobile.*Si vous disposez d'un code de rechargement, tapez 1 et valider.*Sinon, tapez 2 et valider.*Recharger.*Infos.*").

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


test_refill()->
    lists:append([test_refill(Code,Expect,Comment) ||  {Code,Expect,Comment} <- [{"12345678912341","Vous venez de recharger","1"},
  										 {"12345678912342","Vous venez de recharger","2"},
  										 {"12345678912343","Vous venez de recharger","3"},
  										 {"12345678912344","Suite a une erreur technique","0 Message d'erreur"}
  										]])++
    test_refill_ko().

test_refill(Code,Expect,Comment)->
    modify_account_state(#cpte_test{princ=?AC,plan=?PTF_symacom,niv=1},0)++
    change_top_num(?msisdn,"S")++
    [
    {title, "Test de rechargement Suivi-conso - Choix client positionné à " ++ Comment},
    "Cas Classique",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*1#"},
       {expect,"Symacom Mobile.*Si vous disposez d'un code de rechargement, "
        "tapez 1 et valider.*Sinon, tapez 2 et valider.*Recharger.*Infos"},
       {send, "1"},
       {expect,".*Symacom Mobile.*Pour recharger, "
        "tapez les 14 chiffres de votre code de rechargement puis validez"},
       {send, Code},
       {expect, Expect}
      ]}
   ]. 

test_refill_ko()->
    test_util_of:init_test(?imsi_ko,"symacom",1,"100008XXXXXXX1")++
    modify_account_state(?imsi_ko,#cpte_test{princ=?AC,plan=?PTF_symacom,niv=1},0)++
    change_top_num(?msisdn_ko,"S")++
    [{msaddr, {subscriber_number, private, ?imsi_ko}},
    {title, "Test de rechargement Suivi-conso - Echec envoi OPT_CPT2 - Rechargement NOK"},
    "Cas Classique",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*1*1#"},
       {expect,".*Symacom Mobile.*Pour recharger, "
        "tapez les 14 chiffres de votre code de rechargement puis validez"},
       {send, "12345678912341"},
       {expect, "Suite a une erreur technique"}
      ]}
    ]++
    change_top_num(?msisdn_ko,"")++
    [{msaddr, {subscriber_number, private, ?imsi_ko}},
    {title, "Test de rechargement Suivi-conso - Pas envoi OPT_CPT2 - Rechargement OK"},
    "Cas Classique",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*1*1#"},
       {expect,".*Symacom Mobile.*Pour recharger, "
        "tapez les 14 chiffres de votre code de rechargement puis validez"},
       {send, "12345678912341"},
       {expect, "Vous venez de recharger"}
      ]}
    ]. 


change_top_num(MSISDN,State)->
    test_util_of:insert_list_top_num(MSISDN,[{integer_to_list(svc_options:top_num(opt_frais_maint,symacom)),State}]).
