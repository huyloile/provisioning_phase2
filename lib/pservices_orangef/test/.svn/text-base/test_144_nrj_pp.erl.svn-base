-module(test_144_nrj_pp).
-export([run/0, online/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../include/ftmtlv.hrl").%Main structures used in OF services
-include("../../ptester/include/ptester.hrl").%USSD simulator
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").%OCF/RDP simulator
-include("profile_manager.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(Uid, user_nrj_pp).
-define(IMEI_NIV1,    "35061310100006").
-define(IMEI_NIV2,    "100006XXXXXXX2").
-define(IMEI_NIV3,    "100005XXXXXXX3").

-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2

-define(CODE_SERVICE_MENU,"*144#").

-define(LIST_STATES_TO_TEST,[{?AC,"actif"},
                             {?EP,"epuise"}
                            ]).

-define(LIST_LEVELS_TO_TEST,[{1,"Niveau 1"},
			     {2,"Niveau 2"},
                             {3,"Niveau 3"}
                            ]).

-define(LIST_PTF_TO_TEST,[{?PTF_NEPTUNE_PP,"case classique"},
			  {?PTF_NEPTUNE_PP_DOUBLE_JEU,"case double jeu"}
			 ]).

-record(cpte_test,{forf, niv, cpte_princ, cpte_sms, cpte_data, cpte_europe, cpte_maghreb, cpte_afrique, plan}).

-define(ALL_CASES_NEPTUNE, [
			#cpte_test{plan=P, cpte_princ=S1, niv=N, cpte_sms=?EP, cpte_data=?EP, cpte_europe=?EP, cpte_maghreb=?EP, cpte_afrique=?EP}
			||
			   {P,_}  <- ?LIST_PTF_TO_TEST,
			   {S1,_} <- ?LIST_STATES_TO_TEST,
			   {N,_}  <- ?LIST_LEVELS_TO_TEST]).

-define(CASES_SUITE,[
		     #cpte_test{plan=P, cpte_princ=?AC, niv=N, cpte_sms=S2, cpte_data=S3, cpte_europe=S4, cpte_maghreb=S5, cpte_afrique=S6}
		     ||
			{P,_}  <- ?LIST_PTF_TO_TEST,
			{N,_}  <- [{1,"Niveau 1"},{2,"Niveau 2"}],
			{S2,_} <- [{?AC,"actif"}],
			{S3,_} <- [{?AC,"actif"}],
			{S4,_} <- [{?AC,"actif"}],
			{S5,_} <- [{?AC,"actif"}],
			{S6,_} <- [{?AC,"actif"}]
			]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() -> 
    test_util_of:online(?MODULE,test()).

test()->
    ["TEST NRJ Prepaid"] ++
        test_all_cases(?ALL_CASES_NEPTUNE) ++
        test_cases_suite(?CASES_SUITE) ++
	test_menu_nrj_actu()++
        [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generic functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ptf_name(Int) ->  
    {value,{_,Nom}}=
        lists:keysearch(Int, 1, ?LIST_PTF_TO_TEST),
    Nom.

state_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_STATES_TO_TEST),
    Nom.

level_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_LEVELS_TO_TEST),
    Nom.

display_test_account(#cpte_test{plan=P, cpte_princ=S1, niv=N, cpte_sms=S2, cpte_data=S3,
			        cpte_europe=S4, cpte_maghreb=S5, cpte_afrique=S6})->
    "Neptune PP Suivi-conso "++level_name(N)++
        "  PLAN "++ptf_name(P)++"\n"
        ++"PRINCIPAL "++state_name(S1)++ ". "
        ++"\nCompte SMS "++state_name(S2)
        ++"\nCompte DATA "++state_name(S3)
        ++"\nCompte EUROPE "++state_name(S4)
	++"\nCompte MAGHREB "++state_name(S5)
	++"\nCompte AFRIQUE "++state_name(S6)
        .

modify_account_state(#cpte_test{plan=P, cpte_princ=S1, niv=N, cpte_sms=S2, cpte_data=S3,
			        cpte_europe=S4, cpte_maghreb=S5, cpte_afrique=S6})->
        profile_manager:set_dcl(?Uid,?nrj_pp)++
        profile_manager:set_list_comptes(?Uid,
                                         [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=10000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=S1,ptf_num=P},
                                          #compte{tcp_num=?C_OPT_SMS_NRJ,unt_num=?EURO,cpp_solde=20000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=S2,ptf_num=?PTF_NEPTUNE_MINI_SMS},
                                          #compte{tcp_num=?C_OPT_DATA_NRJ,unt_num=?EURO,cpp_solde=30000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=S3,ptf_num=?PTF_NEPTUNE_DATA},
					  #compte{tcp_num=?C_NRJ_INT_EUROPE,unt_num=?EURO,cpp_solde=30000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=S4,ptf_num=?PTF_NEPTUNE_ZONES},
					  #compte{tcp_num=?C_NRJ_INT_MAGHREB,unt_num=?EURO,cpp_solde=30000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=S5,ptf_num=?PTF_NEPTUNE_ZONES},
					  #compte{tcp_num=?C_NRJ_INT_AFRIQUE,unt_num=?EURO,cpp_solde=30000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=S6,ptf_num=?PTF_NEPTUNE_ZONES}
					 ])++
	
        case N of
            1->
                profile_manager:set_imei(?Uid,?IMEI_NIV1);
            2->
                profile_manager:set_imei(?Uid,?IMEI_NIV2);
            3->
                profile_manager:set_imei(?Uid,?IMEI_NIV3)
        end ++
        [].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_test()->
        profile_manager:create_default(?Uid,"nrj_prepaid")++
        profile_manager:init(?Uid).
close_test()->
	test_util_of:close_session() .

consult_account(Cpte) ->    
    init_test()++    
	modify_account_state(Cpte)++
	[
	 {title, "CONSULTATION D'UN COMPTE: " ++display_test_account(Cpte)},
	 {ussd2,
	  [ {send, ?CODE_SERVICE_MENU},
	    {expect, expected(Cpte)}
	   ]}
	]++close_test().

test_all_cases([]) ->
     [];
test_all_cases([H|T]) ->    
    consult_account(H) ++ test_all_cases(T).


consult_account_suite(Cpte) ->
    init_test()++
        modify_account_state(Cpte)++
        [
         {title, "CONSULTATION SUITE D'UN COMPTE: " ++display_test_account(Cpte) },
	  "RECH DATA",
         {ussd2,
          [ {send, ?CODE_SERVICE_MENU++"*1"},
            {expect, expected_suite(Cpte)},
	    {send, "1"},
	    {expect, "Vous disposez de .*E de credit surf utilisable jusqu'au.*inclus.*"}
           ]}
        ]++
	 [
         {title, "CONSULTATION SUITE D'UN COMPTE: " ++display_test_account(Cpte) },
	  "RECH MMS",
         {ussd2,
          [ {send, ?CODE_SERVICE_MENU++"*1"},
            {expect, expected_suite(Cpte)},
	    {send, "2"},
	    {expect, "Vous disposez de .*EUR de credit.* soit .*MMS metropolitains non surtaxes,"
	     " utilisable.* inclus."}
           ]}
        ]++
	 [
         {title, "CONSULTATION SUITE D'UN COMPTE: " ++display_test_account(Cpte) },
	  "RECH EUROPE",
         {ussd2,
          [ {send, ?CODE_SERVICE_MENU++"*1"},
            {expect, expected_suite(Cpte)},
	    {send, "3"},
	    {expect, "Vous disposez de .*EUR, soit .* de credit de communication.* utilisable jusqu'au .*inclus."}
           ]}
        ]++
	 [
         {title, "CONSULTATION SUITE D'UN COMPTE: " ++display_test_account(Cpte) },
	  "RECH MAGHREB",
         {ussd2,
          [ {send, ?CODE_SERVICE_MENU++"*1"},
            {expect, expected_suite(Cpte)},
	    {send, "4"},
	    {expect, "Vous disposez de .*EUR, soit .*de credit de communication.* utilisable jusqu'au .*inclus."}

           ]}
        ]++
	 [
         {title, "CONSULTATION SUITE D'UN COMPTE: " ++display_test_account(Cpte) },
	  "RECH AFRIQUE",
         {ussd2,
          [ {send, ?CODE_SERVICE_MENU++"*1"},
            {expect, expected_suite(Cpte)},
	    {send, "5"},
	    {expect, "Vous disposez de .*EUR, soit .*de credit de communication.* utilisable jusqu'au .*inclus."}
           ]}
        ]++
	close_test().

test_cases_suite([]) ->
    [];
test_cases_suite([H|T]) ->
    consult_account_suite(H) ++ test_cases_suite(T).


test_menu_nrj_actu()->
    init_test()++
    modify_account_state(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_princ=?AC, niv=1, cpte_sms=?EP, cpte_data=?EP,
				    cpte_europe=?EP, cpte_maghreb=?EP, cpte_afrique=?EP})++
        [
         {title, "Test Menu NRJ Actu"},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*9"},
           {expect,expected(menu9)},
           {send, "1"},
           {expect,expected(menu91)},
           {send, "3"},
           {expect,expected(menu913)},
           {send, "0"},
           {expect,expected(menu91)},
           {send, "00"},
           {expect,expected(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_princ=?AC, niv=1, cpte_sms=?EP, cpte_data=?EP,
				       cpte_europe=?EP, cpte_maghreb=?EP, cpte_afrique=?EP})}
                ]}]++close_test().


%% expected niveau 3
expected(#cpte_test{cpte_princ=?AC, niv=3})->
    "Credit: .*EUR soit .* en com nat.*Jsq .* inclus";
expected(#cpte_test{cpte_princ=_, niv=3}) ->
    "Credit: epuise.*Validite de votre numero:.*inclus";

%% expected niveau 2
expected(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_princ=?AC, niv=2}) ->
    "NRJ Mobile.*"
	"Formule Classicall.*EUR soit .* de com.nat. jsq .* inclus.*"
	"Numero valide jsq.*inclus";
expected(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_princ=_, niv=2}) ->
    "Info conso NRJ Mobile.*"
	"Votre credit est epuise.*"
	"Rechargez votre ligne au 675300.*"
	"Numero valide jsq.*inclus.*";
expected(#cpte_test{plan=_, cpte_princ=?AC, niv=2}) ->
    "NRJ Mobile.*"
	"Formule Double Jeu : .*EUR soit.* de com.nat. jsq .* inclus.*"
	"Numero valide jsq .* inclus";
expected(#cpte_test{plan=_, cpte_princ=_, niv=2}) ->
    "Info conso NRJ Mobile.*"
	"Votre credit est epuise.*"
	"Rechargez votre ligne au 675300.*"
	"Numero valide jsq.*inclus.*";

%% expected niveau 1
expected(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_princ=?AC}) ->
    "Bienvenue dans votre info conso.*"
	"Formule Classicall.*EUR soit .* de com.nat. jsq .* inclus.*"
	"Numero valide jsq.* inclus.";
expected(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_princ=_}) ->
    "Bienvenue dans votre info conso.*"
	"Votre credit est epuise.*"
	"Rechargez en appelant le 675300.*"
	"Numero est valide jsq.*inclus.";
expected(#cpte_test{plan=_, cpte_princ=?AC}) ->
    "Bienvenue dans votre info conso.*"
	"Formule Double Jeu : .*EUR soit .* de com.nat. . SMS illimites jsq .* inclus.*"
	"Numero valide jsq .* inclus";
expected(#cpte_test{plan=_, cpte_princ=_}) ->
    "Bienvenue dans votre info conso.*"
	"Votre credit est epuise.*"
	"Rechargez en appelant le 675300 pour profiter des SMS illimites.*"
	"Numero est valide jsq.*inclus.*";
expected(menu9)->
    "Menu .144.*"
	"1:Actu NRJ Mobile.*"
	"2:Aide.*"
	"00:Info conso";
expected(menu91)->
    "Decouvrez toutes les astuces NRJ Mobile :.*"
	"1:Comment Recharger.*"
	"2:Formule Double Jeu.*"
	"3:Credit de secours.*"
	"4:Comment parametrer votre mobile \\(WAP.MMS\\)";
expected(menu913) ->
    "Meme si votre credit est epuise, vous pourrez appeler vos proches en cas "
	"de besoin : NRJ Mobile met a votre disposition un credit de secours de 1EUR ".

%Expected text suite
%% -define(TEXT_CLAS_SMS_AC,
%% 	"Credit SMS.MMS : .*EUR utilisables jsq .* inclus.*").
%% -define(TEXT_DJ_SMS_AC,
%% 	"Credit MMS : .*EUR utilisables jsq .* inclus.*").
%% -define(TEXT_DATA_AC,
%% 	"Credit Surf : .*EUR utilisables jsq .* inclus.*").
%% -define(TEXT_DATA_EP,
%% 	"Credit Surf : epuise.*").

%% expected_suite(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_sms=?AC, cpte_data=?AC, 
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_CLAS_SMS_AC++?TEXT_DATA_AC;
%% expected_suite(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_sms=?AC, cpte_data=_,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_CLAS_SMS_AC++?TEXT_DATA_EP;
%% expected_suite(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_sms=_, cpte_data=?AC,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_DATA_AC;
%% expected_suite(#cpte_test{plan=?PTF_NEPTUNE_PP, cpte_sms=_, cpte_data=_,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_DATA_EP;
%% expected_suite(#cpte_test{plan=_, cpte_sms=?AC, cpte_data=?AC,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_DJ_SMS_AC++?TEXT_DATA_AC;
%% expected_suite(#cpte_test{plan=_, cpte_sms=?AC, cpte_data=_,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_DJ_SMS_AC++?TEXT_DATA_EP;
%% expected_suite(#cpte_test{plan=_, cpte_sms=_, cpte_data=?AC,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_DATA_AC;
%% expected_suite(#cpte_test{plan=_, cpte_sms=_, cpte_data=_,
%% 			  cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
%%     ?TEXT_DATA_EP.
expected_suite(#cpte_test{plan=_, cpte_sms=_, cpte_data=_,
                        cpte_europe=_, cpte_maghreb=_, cpte_afrique=_}) ->
    ".*".
