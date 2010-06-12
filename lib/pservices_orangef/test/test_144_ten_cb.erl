-module(test_144_ten_cb).
-export([run/0, online/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../include/ftmtlv.hrl").%Main structures used in OF services
-include("../../ptester/include/ptester.hrl").%USSD simulator
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").%OCF/RDP simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(CODE_SERVICE_MENU,"*144").
-define(imsi_cb,"999000907000001").
-define(imsi_cb2_20_SMS,"999000907000002").
-define(imsi_cb2_50_SMS,"999000907000003").
-define(imsi_cb2_100_SMS,"999000907000004").
-define(imsi_cb1_20_SMS,"999000907000005").

-define(niv1,   "100007XXXXXXX1").
-define(niv2,   "100006XXXXXXX2").
-define(niv3,   "100005XXXXXXX3").

-record(cpte_test,{forf, cpte_princ, niv}).


-define(LIST_IMSI, [?imsi_cb,?imsi_cb2_20_SMS]).
-define(LIST_IMSI_CB_SMS, [?imsi_cb2_20_SMS,?imsi_cb2_50_SMS,?imsi_cb2_100_SMS, ?imsi_cb1_20_SMS]).

-define(LIST_STATES_TO_TEST,[{?CETAT_AC,"actif"},
			     {?CETAT_EP,"epuise"}
			    ]).

-define(LIST_LEVELS_TO_TEST,   [{?niv1,"Niveau 1"},
				{?niv2,"Niveau 2"},
				{?niv3,"Niveau 3"}]).

-define(ALL_CASES_TEN,  [ {IMSI,#cpte_test{forf=ETAT_CP,cpte_princ=ETAT_CB, niv=IMEI}} ||
 			    IMSI <- ?LIST_IMSI,
 			    {ETAT_CP, _} <- ?LIST_STATES_TO_TEST,
 			    {ETAT_CB, _} <- ?LIST_STATES_TO_TEST,
 			    {IMEI,    _} <- ?LIST_LEVELS_TO_TEST]).

-define(TXT_NIV1_AC_AC, "Ten Mobile.*Votre forfait:.*EUR a utiliser avant le .* Compte rechargeable:.*EUR.*1:Recharger.*").
-define(TXT_NIV1_AC_EP, "Ten Mobile.*Votre forfait:.*EUR a utiliser avant le .* Compte rechargeable:.*EUR.*1:Recharger.*").
-define(TXT_NIV1_EP_AC, "Ten Mobile.*Votre forfait est epuise. Il sera renouvele le .*. Compte rechargeable:.*E.*1:Recharger.*").
-define(TXT_NIV1_EP_EP, "Votre forfait est epuise. Il sera renouvele le .*. En rechargeant, vous pourrez continuer a communiquer jusqu'a la mise a jour de votre forfait..*1:Recharge.*").

-define(TXT_NIV2_AC_AC, "Votre forfait dispose de .* EUR a utiliser avant le .* Compte rechargeable: .* EUR.*").
-define(TXT_NIV2_AC_EP, "Votre forfait dispose de .* EUR a utiliser avant le .* Compte rechargeable: .* EUR.*").
-define(TXT_NIV2_EP_AC, "Votre forfait est epuise, il sera renouvele le .*. Compte rechargeable: .* EUR \\(duree de validite illimitee\\).").
-define(TXT_NIV2_EP_EP, "Forfait epuise, renouvele le .*. Pour recharger, appelez votre Service Client Ten au 0 820 36 00 15 \\(0,12EUR\\/min\\)").

-define(TXT_NIV3_AC_AC, "Forfait: .*EUR jusqu\\'au .* - Cpte rechargeable:.*").
-define(TXT_NIV3_AC_EP, "Forfait: .*EUR jusqu\\'au .* - Cpte rechargeable:.*").
-define(TXT_NIV3_EP_AC, "Forfait: .*EUR jusqu\\'au .* - Cpte rechargeable:.*").
-define(TXT_NIV3_EP_EP, "Credit epuise. Pour recharger appelez votre Service Client Ten").

-define(RECHARGEMENT_REFUSE, "rechargement refuse:votre code n'est pas correct. Veuillez verifier votre code et renouveler l'operation. Merci ").
-define(FILL_CODE,"Veuillez saisir le code de rechargement").

get_dcl(?imsi_cb1_20_SMS)->
    ?ten_cb;
get_dcl(?imsi_cb2_20_SMS) ->
    ?ten_cb2;
get_dcl(?imsi_cb2_50_SMS) ->
    ?ten_cb2;
get_dcl(?imsi_cb2_100_SMS) ->
    ?ten_cb2.

get_tcp_num(c_sms,?imsi_cb2_20_SMS) ->
    ?C_FORF_TEN_CB_20_SMS;
get_tcp_num(c_sms,?imsi_cb2_50_SMS) ->
    ?C_FORF_TEN_CB_50_SMS;
get_tcp_num(c_sms,?imsi_cb2_100_SMS) ->
    ?C_FORF_TEN_CB_100_SMS;
get_tcp_num(c_sms,?imsi_cb1_20_SMS) ->
    ?C_FORF_TEN_CB_20_SMS;
get_tcp_num(c_forf,?imsi_cb1_20_SMS) ->
    ?C_FORF_TEN_CB1;
get_tcp_num(c_forf,_) ->
    ?C_FORF_TEN_CB2.

get_ptf_num(c_sms,?imsi_cb2_20_SMS) ->
    ?PTF_TEN_20_SMS;
get_ptf_num(c_sms,?imsi_cb2_50_SMS) ->
    ?PTF_TEN_50_SMS;
get_ptf_num(c_sms,?imsi_cb2_100_SMS) ->
    ?PTF_TEN_100_SMS;
get_ptf_num(c_sms,?imsi_cb1_20_SMS) ->
    ?PTF_TEN_20_SMS;
get_ptf_num(c_forf,?imsi_cb1_20_SMS) ->
    ?PTF_TEN_CB_PP;
get_ptf_num(c_forf,_) ->
    ?PTF_TEN_CB2_PP.

get_nb_sms(?imsi_cb2_20_SMS) ->
    "20";
get_nb_sms(?imsi_cb2_50_SMS) ->
    "50";
get_nb_sms(?imsi_cb2_100_SMS) ->
    "100";
get_nb_sms(?imsi_cb1_20_SMS) ->
    "20".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_all_cases([]) -> [];
test_all_cases([{Imsi,H}|T]) ->
    test_util_of:init_test(Imsi, "ten_comptebloque", 1, null, "") ++ 
    test_util_of:ocf_set(Imsi,"ten_comptebloque")++
    test_util_of:set_in_sachem(Imsi,"ten_comptebloque")++
    modify_account_state(Imsi,H) ++ 
    consult_account(Imsi,H) ++
    test_all_cases(T).

modify_account_state(Imsi=?imsi_cb,#cpte_test{forf=ETAT_CB, cpte_princ=ETAT_CP,
			       niv=IMEI}) ->
    test_util_of:set_imei(Imsi,IMEI)++
    test_util_of:insert(Imsi,?ten_cb,0,
                        [#compte{tcp_num=?C_PRINC,
                                 unt_num=?EURO,
                                 cpp_solde=50000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=ETAT_CP,
                                 ptf_num=?PTF_TEN_CB_PP},
                         #compte{tcp_num=?C_FORF_TEN_CB1,
                                 unt_num=?EURO,
                                 cpp_solde=10000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=ETAT_CB,
                                 ptf_num=?PTF_TEN_CB_PP}
                        ]);
modify_account_state(Imsi,#cpte_test{forf=ETAT_CB, cpte_princ=ETAT_CP,
			       niv=IMEI}) ->
    test_util_of:set_imei(Imsi,IMEI)++
    test_util_of:insert(Imsi,get_dcl(Imsi),0,
                        [#compte{tcp_num=?C_PRINC,
                                 unt_num=?EURO,
                                 cpp_solde=50000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=ETAT_CP,
                                 ptf_num=get_ptf_num(c_forf,Imsi)},
                         #compte{tcp_num=get_tcp_num(c_forf,Imsi),%?C_FORF_TEN_CB2,
                                 unt_num=?EURO,
                                 cpp_solde=10000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=ETAT_CB,
                                 ptf_num=get_ptf_num(c_forf,Imsi)},%?PTF_TEN_CB2_PP},
                         #compte{tcp_num=get_tcp_num(c_sms,Imsi),
                                 unt_num=?SMS,
                                 cpp_solde=10000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=ETAT_CB,
                                 ptf_num=get_ptf_num(c_sms,Imsi)}
                        ]).

consult_account(Imsi,Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++ display_test_account(Cpte)},
     {ussd2,
      [ {send, ?CODE_SERVICE_MENU++"*#"},
	{expect,expected(Imsi,Cpte)}
             ]}     
    ].

display_test_account(#cpte_test{cpte_princ=ETAT_CP,
				 forf=ETAT_CB,niv=IMEI}) ->
    "Forfait TEN CB\n" ++
    "IMEI: "++IMEI++"PRINCIPAL"++" "++state_name(ETAT_CP)++" "
    ++"Forf TEN CB"++" "++state_name(ETAT_CB)++" ".


state_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_STATES_TO_TEST),
    Nom.

expected_vos_options(Imsi,Level) ->
    case {Imsi,Level} of 
	{?imsi_cb2_20_SMS,?niv1} -> "2:Vos Options";
	{?imsi_cb2_20_SMS,?niv2} -> "Opt:.*SMS jusqu'au.*";
	_ -> ""
    end.

expected(Imsi,#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,niv=?niv1}) ->
    ?TXT_NIV1_AC_AC ++
	expected_vos_options(Imsi,?niv1);
expected(Imsi,#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,niv=?niv1})-> 
    ?TXT_NIV1_EP_AC ++
	expected_vos_options(Imsi,?niv1);
expected(Imsi,#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP,niv=?niv1}) ->
    ?TXT_NIV1_AC_EP ++
	expected_vos_options(Imsi,?niv1);
expected(Imsi,#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,niv=?niv1}) -> 
    ?TXT_NIV1_EP_EP ++
	expected_vos_options(Imsi,?niv1);

expected(Imsi,#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,niv=?niv2}) ->
    ?TXT_NIV2_AC_AC ++
	expected_vos_options(Imsi,?niv2);
expected(Imsi,#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,niv=?niv2})-> 
     ?TXT_NIV2_EP_AC;
expected(Imsi,#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,niv=?niv2}) ->
    ?TXT_NIV2_AC_EP ++
	expected_vos_options(Imsi,?niv2);
expected(Imsi,#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,niv=?niv2}) -> 
    ?TXT_NIV2_EP_EP;
expected(_,#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,niv=?niv3}) ->
    ?TXT_NIV3_AC_AC;
expected(_,#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,niv=?niv3})-> 
     ?TXT_NIV3_EP_AC;
expected(_,#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,niv=?niv3}) ->
    ?TXT_NIV3_AC_EP;
expected(_,#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,niv=?niv3}) -> 
    ?TXT_NIV3_EP_EP.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->  
    test_util_of:online(?MODULE,selfcare()).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selfcare() ->
    [ "Test du service selfcare Ten Compte Bloque." ] ++
    test_util_of:connect() ++
    test_all_cases(?ALL_CASES_TEN)++
    test_refill(?imsi_cb)++
    test_refill(?imsi_cb2_20_SMS)++
    test_options(?LIST_IMSI_CB_SMS) ++
    test_util_of:close_session() ++
    [ "Test reussi." ].

test_refill(IMSI)->
    test_util_of:init_test(IMSI, "ten_comptebloque", 1, null, "") ++ 
    test_util_of:ocf_set(IMSI,"ten_comptebloque")++
    test_util_of:set_in_sachem(IMSI,"ten_comptebloque")++
    modify_account_state(IMSI,#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP,niv=?niv1}) ++
    [
     {title, "Test de rechargement Suivi-conso: "},
    "Cas Classique",
     {ussd2,
      [ {send, ?CODE_SERVICE_MENU++"*"},
        {expect, ?TXT_NIV1_AC_EP}
         ]}, 

     {ussd2,
      [ {send, ?CODE_SERVICE_MENU++"*1#"},
        {expect,?FILL_CODE}
         ]},   

     "Code CG FAUX",
     {ussd2,
      [ {send,?CODE_SERVICE_MENU++"*1a1234567890123"},
        {expect,?RECHARGEMENT_REFUSE}
       ]},
     "Code CG OK",
     {ussd2,
      [ {send, ?CODE_SERVICE_MENU++"*112345678912311#"},
        {expect,"Votre rechargement a ete pris en compte." 
         " Votre nouveau solde est .* Euros.*"}
       ]}
    ].


test_options([])->
    [];
test_options([IMSI|T])->
    test_util_of:init_test(IMSI, "ten_comptebloque", 1, null, "") ++ 
    test_util_of:ocf_set(IMSI,"ten_comptebloque")++
    test_util_of:set_in_sachem(IMSI,"ten_comptebloque")++
    modify_account_state(IMSI,#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC,niv=?niv1}) ++
    [
     {title, "CONSULTATION DES OPTIONS: "},
     {ussd2,
      [ {send, ?CODE_SERVICE_MENU++"#"},
        {expect, ".*2:Vos Options.*"},
        {send, "2"},
        {expect, "SMS restant sur votre option "++get_nb_sms(IMSI) ++" SMS : 10 SMS jusqu'au.*"},
        {send, "00"}
       ]}
    ] ++
    test_options(T).
