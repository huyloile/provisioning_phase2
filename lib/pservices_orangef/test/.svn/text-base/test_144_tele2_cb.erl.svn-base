-module(test_144_tele2_cb).
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
-define(Uid,tele2_user).
-define(CODE_SERVICE_MENU,"*144").
%% -define(msisdn, "9907000001").
%% -define(imsi,"999000907000001").

-define(niv1,   "100007XXXXXXX1").
-define(niv2,   "100006XXXXXXX2").
-define(niv3,   "100005XXXXXXX3").

-record(cpte_test,{forf,cpte_princ,cpte_numpref,cpte_sms,nb_sms,niv,dcl}).


-define(LIST_STATES_TO_TEST,[{?CETAT_AC,"actif"},
			     {?CETAT_EP,"epuise"}
 			    ]).

-define(LIST_LEVELS_TO_TEST,   [{?niv1,"Niveau 1"},
 				{?niv2,"Niveau 2"},
 				{?niv3,"Niveau 3"}]).

-define(LIST_DCL,[{45,"tele2_cb2"},{37,"tele2_cb"},{26,"tele2_cb3"}]).

-define(ALL_CASES_TELE2,  [ #cpte_test{forf=ETAT_CB,cpte_princ=ETAT_CP,cpte_numpref=ETAT_NP,cpte_sms=ETAT_OPT,nb_sms=25,niv=IMEI,dcl=DCL}
			    || 
			      {ETAT_CP, _} <- ?LIST_STATES_TO_TEST,
				  {ETAT_NP, _} <- ?LIST_STATES_TO_TEST,
			      {ETAT_CB, _} <- ?LIST_STATES_TO_TEST,
			      {ETAT_OPT,_} <- ?LIST_STATES_TO_TEST,
			      {IMEI,    _}  <- ?LIST_LEVELS_TO_TEST,
			      {DCL,_} <- ?LIST_DCL]).

-define(ALL_CASES_NIV2,  [ #cpte_test{forf=ETAT_CB,cpte_princ=ETAT_CP,cpte_numpref=ETAT_NP,cpte_sms=ETAT_OPT,nb_sms=illimite,niv=?niv2,dcl=DCL}
			   || 
			     {ETAT_CP, _} <- ?LIST_STATES_TO_TEST,
				 {ETAT_NP, _} <- ?LIST_STATES_TO_TEST,
			     {ETAT_CB, _} <- ?LIST_STATES_TO_TEST,
			     {ETAT_OPT,_} <- ?LIST_STATES_TO_TEST,
			     {DCL,_} <- ?LIST_DCL
			    ]).

-define(OPTIONS_SMS, [#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,cpte_numpref=?CETAT_EP,cpte_sms=?CETAT_AC,nb_sms=Nb_SMS,niv=?niv1,dcl=DCL}
		      ||
			 Nb_SMS <- [25,50,100],
			 {DCL,_} <- ?LIST_DCL]).

-define(OPTIONS_SMS_ILL, [#cpte_test{forf=ETAT_CB,cpte_princ=ETAT_CP,cpte_numpref=?CETAT_EP,cpte_sms=ETAT_OPT,nb_sms=illimite,niv=IMEI,dcl=DCL}
		      ||
			     {ETAT_CP, _} <- ?LIST_STATES_TO_TEST,
			     {ETAT_CB, _} <- ?LIST_STATES_TO_TEST,
			     {ETAT_OPT,_} <- ?LIST_STATES_TO_TEST,
			     {IMEI,    _}  <- ?LIST_LEVELS_TO_TEST,
			     {DCL,_} <- ?LIST_DCL
			    ]).

top_num(illimite) ->
    217;
top_num(25) ->
    162;
top_num(50) ->
    163;
top_num(100) ->
    168;
top_num(numpref) ->
	376.
tcp_num(illimite) ->
    179;
tcp_num(25) ->
    ?C_FORF_TELE2_CB_25_SMS;
tcp_num(50) ->
    ?C_FORF_TELE2_CB_50_SMS;
tcp_num(numpref) ->
    ?C_TELE2_NUM_PREFERE;
tcp_num(100) ->
    ?C_FORF_TELE2_CB_100_SMS.
ptf_num(numpref) ->
    276;
ptf_num(_) ->
    249.
top_num_list(?CETAT_EP,_Nb_SMS)->
    [0, 111];
top_num_list(_,Nb_SMS) ->
    [0, 111, top_num(Nb_SMS)].

sms_to_list(illimite)->
    "illimite";
sms_to_list(NbSms)->
    integer_to_list(NbSms).


-define(TXT_NIV1_AC_AC_EP, "Tele2Mobile.*Votre forfait:.*EUR a utiliser avant le .* Compte rechargeable:.*EUR.*0:Recharger.*").
-define(TXT_NIV1_AC_EP_EP, "Tele2Mobile.*Votre forfait:.*EUR a utiliser avant le .* Compte rechargeable:.*EUR.*0:Recharger.*").
-define(TXT_NIV1_EP_AC_EP, "Tele2Mobile.*Votre forfait est epuise. Il sera renouvele le .*. Compte rechargeable:.*E.*0:Recharger.*").
-define(TXT_NIV1_EP_EP_EP, "Votre forfait est epuise. Il sera renouvele le .*. Appelez gratuitement le 430 pour recharger par CB.*").
-define(TXT_NIV1_AC_AC_AC, "Tele2Mobile.*Votre forfait:.*EUR a utiliser avant le .* Compte rechargeable:.*EUR.*0:Recharger.1:Vos options.*").
-define(TXT_NIV1_AC_EP_AC, "Tele2Mobile.*Votre forfait:.*EUR a utiliser avant le .* Compte rechargeable:.*EUR.*0:Recharger.1:Vos options.*").
-define(TXT_NIV1_EP_AC_AC, "Tele2Mobile.*Votre forfait est epuise. Il sera renouvele le .*. Compte rechargeable:.*E.*0:Recharger.1:Vos options.*").
-define(TXT_NIV1_EP_EP_AC, "Votre forfait est epuise. Il sera renouvele le .*. Appelez gratuitement le 430 pour recharger par CB.*").

-define(TXT_NIV2_AC_AC_ILL, "Forfait: [0-9]*\\.[0-9]*E a utiliser avant ../../...Compte rechargeable: [0-9]*\\.[0-9]*E.Opt: SMS illimites \\(metrop. hors SMS surtaxes\\) jsq'au ../..").
-define(TXT_NIV2_AC_AC, "Votre forfait dispose de .* E a utiliser avant le .* Compte rechargeable: .* E.*").

-define(TXT_NIV2_AC_EP_ILL, "Forfait: [0-9]*\\.[0-9]*E a utiliser avant ../../...Compte rechargeable: [0-9]*\\.[0-9]*E Opt: SMS illimites \\(metrop. hors SMS surtaxes\\) jsq'au ../..").
-define(TXT_NIV2_AC_EP, "Votre forfait dispose de .* E a utiliser avant le .* Compte rechargeable: .* E.*").

-define(TXT_NIV2_EP_AC_ILL, "Forfait epuise..Renouvele le ../...Compte rechargeable: [0-9]*\\.[0-9]*EUR.Opt: SMS illimites \\(metrop. hors SMS surtaxes\\).jusqu'au ../..").
-define(TXT_NIV2_EP_AC_EP, "Votre forfait est epuise, il sera renouvele le .*. Compte rechargeable:.*EUR").
-define(TXT_NIV2_EP_AC_AC, "Votre forfait est epuise, il sera renouvele le .*. Compte rechargeable:.*EUR.Opt:[0-9]* SMS jusqu'au ../..").

-define(TXT_NIV2_EP_EP_ILL, "Forfait epuise, il sera renouvele le .*. Vous pouvez recharger votre compte au 430\\..SMS illimites \\(metrop. hors SMS surtaxes\\)").
-define(TXT_NIV2_EP_EP, "Forfait epuise, il sera renouvele le .*. Vous pouvez recharger votre compte au 430\\.").

-define(TXT_NIV3_AC_AC, "Forfait: .*EUR jusqu\\'au .* - Cpte rech: .*").
-define(TXT_NIV3_AC_EP, "Forfait: .*EUR jusqu\\'au .* - Cpte rech: .*").
-define(TXT_NIV3_EP_AC, "Forfait: .*EUR jusqu\\'au .* - Cpte rech: .*").
-define(TXT_NIV3_EP_EP, "Merci de recharger en appelant gratuitement le 430").


-define(RECHARGEMENT_REFUSE, "rechargement refuse:votre code n'est pas correct. Veuillez verifier votre code et renouveler l'operation. Merci ").
-define(FILL_CODE,"Tapez les 14 chiffres de votre code de rechargement. Attention, 3 essais seulement").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_all_cases([]) ->  [] ;
test_all_cases([H|T]) ->
    modify_account_state(H) ++ 
	consult_account(H) ++
	test_all_cases(T).

modify_account_state(#cpte_test{forf=ETAT_CB,cpte_princ=ETAT_CP,cpte_numpref=ETAT_NP,cpte_sms= ETAT_SMS,
				nb_sms = Nb_SMS,
				niv=IMEI,dcl=DCL}) ->
    profile_manager:set_imei(?Uid,IMEI)++
       profile_manager:set_dcl(?Uid,dcl)++
         profile_manager:set_list_options(?Uid, [#option{top_num=0},#option{top_num=111}, #option{top_num=top_num(Nb_SMS)}])++

    profile_manager:set_list_comptes(?Uid, [
					    #compte{tcp_num=?C_PRINC,
						    unt_num=?EURO,
						    cpp_solde=2000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=ETAT_CP,
						    ptf_num=?PTF_TELE2_CB_PP},
					    #compte{tcp_num=?C_FORF_TELE2_CB2,
						    unt_num=?EURO,
						    cpp_solde=20000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=ETAT_CB,
						    ptf_num=?PTF_TELE2_CB2},
					    #compte{tcp_num=tcp_num(Nb_SMS),
						    unt_num=?SMS,
						    cpp_solde=50000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=ETAT_SMS,
						    ptf_num=ptf_num(Nb_SMS)},
					    #compte{tcp_num=tcp_num(numpref),
						    unt_num=?EURO,
						    cpp_solde=20000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=ETAT_NP,
						    ptf_num=ptf_num(numpref)}

                                           ])++
        [].

%%     test_util_of:set_imei(?imsi,IMEI)++
%% 	test_util_of:insert_list_top_num(?msisdn,top_num_list(ETAT_SMS,Nb_SMS))++
%% 	test_util_of:insert(?imsi,DCL,top_num(Nb_SMS),
%% 			    [#compte{tcp_num=?C_PRINC,
%% 				     unt_num=?EURO,
%% 				     cpp_solde=2000,
%% 				     dlv=pbutil:unixtime(),
%% 				     rnv=0,
%% 				     etat=ETAT_CP,
%% 				     ptf_num=?PTF_TELE2_CB_PP},
%% 			     #compte{tcp_num=?C_FORF_TELE2_CB2, 
%% 				     unt_num=?EURO,
%% 				     cpp_solde=20000,
%% 				     dlv=pbutil:unixtime(),
%% 				     rnv=0,
%% 				     etat=ETAT_CB,
%% 				     ptf_num=?PTF_TELE2_CB2},
%% 			     #compte{tcp_num=tcp_num(Nb_SMS),
%% 				     unt_num=?SMS,
%% 				     cpp_solde=50000,
%% 				     dlv=pbutil:unixtime(),
%% 				     rnv=0,
%% 				     etat=ETAT_SMS,
%% 				     ptf_num=ptf_num(Nb_SMS)},
%% 				 #compte{tcp_num=tcp_num(numpref),
%% 				     unt_num=?EURO,
%% 				     cpp_solde=20000,
%% 				     dlv=pbutil:unixtime(),
%% 				     rnv=0,
%% 				     etat=ETAT_NP,
%% 				     ptf_num=ptf_num(numpref)}
%% 					 ]).					 

modif_etat_roaming() ->
    test_util_of:insert(?imsi,45,0,
			[#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=50000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=1},
			#compte{tcp_num=?C_RECH_ROAMING_TELE2,
				     unt_num=?EURO,
				     cpp_solde=30000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=171}]).

update_refill_sms_account() ->
    test_util_of:insert(?imsi,45,0,
			[#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=40000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=1},
			#compte{tcp_num=?C_RECH_SMS_ILLM,
				     unt_num=?EURO,
				     cpp_solde=30000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=41}]).
    
	
consult_account(Cpte) ->
	[
     {title, "CONSULTATION D'UN COMPTE: "++ display_test_account(Cpte)},
     {ussd2,
      [ {send, ?CODE_SERVICE_MENU++"*#"},
	{expect,expected(Cpte)},
	{send, "1"},
	{expect,expected_sms(Cpte)}
       ]}     
    ].


display_test_account(#cpte_test{forf=ETAT_CB, cpte_princ=ETAT_CP,
				cpte_numpref=ETAT_NP,
				cpte_sms= ETAT_SMS,
				nb_sms = Nb_SMS,
				niv=IMEI,dcl=DCL}) ->
    "Forfait TELE2 CB\n" ++
	"IMEI: "++IMEI++"CPTE_PRINCIPAL"++" "++state_name(ETAT_CP)++" "
	++"Numero prefere"++" "++state_name(ETAT_NP)++" "
	++"Forf "++type_compte(DCL)++" "++" "++state_name(ETAT_CB)++" "
	++"Option " ++ sms_to_list(Nb_SMS) ++
	" SMS"++" "++state_name(ETAT_SMS)++" ".

state_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_STATES_TO_TEST),
    Nom.
type_compte(DCL)->
    {value,{_,Nom}}=lists:keysearch(DCL, 1, ?LIST_DCL),
    Nom.

expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_AC,niv=?niv1}) ->
    ?TXT_NIV1_AC_AC_AC;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,cpte_sms=?CETAT_AC,niv=?niv1})-> 
    ?TXT_NIV1_AC_EP_AC;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_AC,niv=?niv1}) ->
    ?TXT_NIV1_EP_AC_AC;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,cpte_sms=?CETAT_AC,niv=?niv1}) -> 
    ?TXT_NIV1_EP_EP_AC;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_EP,niv=?niv1}) ->
    ?TXT_NIV1_AC_AC_EP;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,cpte_sms=?CETAT_EP,niv=?niv1})-> 
    ?TXT_NIV1_AC_EP_EP;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_EP,niv=?niv1}) ->
    ?TXT_NIV1_EP_AC_EP;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,cpte_sms=?CETAT_EP,niv=?niv1}) -> 
    ?TXT_NIV1_EP_EP_EP;

expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_EP,nb_sms=illimite,niv=?niv2}) ->
    ?TXT_NIV2_AC_AC;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,nb_sms=illimite,niv=?niv2}) ->
    ?TXT_NIV2_AC_AC_ILL;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,niv=?niv2}) ->
    ?TXT_NIV2_AC_AC;

expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,cpte_sms=?CETAT_EP,nb_sms=illimite,niv=?niv2})-> 
     ?TXT_NIV2_AC_EP;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,nb_sms=illimite,niv=?niv2})-> 
     ?TXT_NIV2_AC_EP_ILL;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,niv=?niv2})-> 
     ?TXT_NIV2_AC_EP;

expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_EP,nb_sms=illimite,niv=?niv2})->
    ?TXT_NIV2_EP_AC_EP;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,nb_sms=illimite,niv=?niv2})-> 
    ?TXT_NIV2_EP_AC_ILL;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,cpte_sms=?CETAT_EP,niv=?niv2}) ->
    ?TXT_NIV2_EP_AC_EP;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,niv=?niv2}) ->
    ?TXT_NIV2_EP_AC_AC;

expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,cpte_sms=?CETAT_EP,nb_sms=illimite,niv=?niv2})->
    ?TXT_NIV2_EP_EP;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,nb_sms=illimite,niv=?niv2})-> 
    ?TXT_NIV2_EP_EP_ILL;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,niv=?niv2}) -> 
    ?TXT_NIV2_EP_EP;

expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_AC,niv=?niv3}) ->
    ?TXT_NIV3_AC_AC;
expected(#cpte_test{forf=?CETAT_AC,cpte_princ=?CETAT_EP,niv=?niv3})-> 
     ?TXT_NIV3_AC_EP;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_AC,niv=?niv3}) ->
    ?TXT_NIV3_EP_AC;
expected(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,niv=?niv3}) -> 
    ?TXT_NIV3_EP_EP.

%% expected_sms(#cpte_test{forf=?CETAT_EP,cpte_princ=?CETAT_EP,niv=?niv1}) -> 
%%     ".*";
expected_sms(#cpte_test{cpte_sms=?CETAT_AC,nb_sms=illimite,niv=?niv1}) -> 
    "Option SMS illimite";
expected_sms(#cpte_test{cpte_sms=?CETAT_AC,nb_sms=Nb_SMS,niv=?niv1}) -> 
    "SMS restant sur votre option "++
	integer_to_list(Nb_SMS) ++
	" SMS: 50 SMS jusqu'au ../..";
expected_sms(_)->
    ".*".

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
    [ "Test du service selfcare Tele2 Compte Bloque." ] ++
	%% test_util_of:connect() ++
%% 	test_util_of:init_test(?imsi, "tele2_comptebloque", 1, null, "") ++ 
%% 	test_util_of:ocf_set(?imsi,"tele2_comptebloque")++
%% 	test_util_of:set_in_sachem(?imsi,"tele2_comptebloque")++

	profile_manager:create_default(?Uid,"tele2_comptebloque")++
        profile_manager:init(?Uid)++

%%     	test_promo_surf_wap()++
%%  	test_all_cases(?ALL_CASES_TELE2)++
%%     	test_all_cases(?ALL_CASES_NIV2)++
%%     	test_all_cases(?OPTIONS_SMS)++
%%    	test_all_cases(?OPTIONS_SMS_ILL)++
%     	test_refill()++
	test_numpref_normal()++
	test_numpref_anomalie()++
%%	recharge_roaming() ++
%%      refill_sms_illimites()++
	test_util_of:close_session()++
	[ "Test reussi." ].



recharge_roaming()->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_numpref=?CETAT_EP,cpte_sms=?CETAT_AC,nb_sms=25,niv=?niv1,dcl=?tele2_cb2}) ++
 	[
	 {title, "Test de rechargement par ticket de rechargement des compte"},
	 "Cas Classique",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"1:Vos options"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912326"},
	   {expect,"Rechargement confirme."
	    " Vous disposez de 21.00E de credit pour appeler depuis les Etats-Unis, le Maroc, l'Algerie, la Tunisie et la Turquie, "
	    "Credit valable jusqu'au ../../20.."}]}] ++
	modif_etat_roaming() ++
 	[
	 {title, "Test de selfcare roaming Tele2"},
	 "Cas Classique",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},	
	   {expect,"2:Credit recharge Maghreb"},
	   {send,"2"},
	   {expect,"TELE2 MOBILE"
	    " Vous disposez de .*E de credit pour appeler depuis les Etats-Unis, le Maroc, l'Algerie, la Tunisie et la Turquie,"
	    " valables jusqu'au ../../20..."}]}].


test_numpref_normal()->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC,cpte_numpref=?CETAT_AC,cpte_sms=?CETAT_AC,nb_sms=25,niv=?niv1,dcl=?tele2_cb2}) ++
	profile_manager:update_sachem(?Uid, "csl_tck", {"TTK_NUM","173"})++
	test_util_of:set_present_period_for_test(commercial_date_tele2_cb,[recharge_numpref])++
 	[
	 {title, "Test de rechargement par ticket de rechargement des compte"},
	 "Cas d'un seul numero",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"Numero prefere"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"0743000123"},
	   {expect,"Votre numero prefere est le 0743000123.*"},
	   {send,"1"},
	   {expect,"Rechargement confirme."},
	   {send,"00"},
	   {expect,"1:Numero prefere"},
	   {send,"1"},
	   {expect,"TELE2 Mobile.*Vous disposez de .* de communications vers votre numero prefere.*jusqu'au.*"}
	   ]},
	 "Cas plus d'un numero",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"Numero prefere"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"0643000123"},
	   {expect,"Votre numero prefere est le 0643000123.*"},
	   {send,"1"},
	   {expect,"Rechargement confirme."},
	   {send,"00*0*12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"0123456781"},
	   {expect,"Votre numero prefere est le 0123456781.*"},
	   {send,"1"},
	   {expect,"Rechargement confirme."}
	   ]},
	 "Cas plus de 5 numeros",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"Numero prefere"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"0643000123"},
	   {expect,"Votre numero prefere est le 0643000123.*"},
	   {send,"1"},
	   {expect,"Rechargement confirme."},
	   {send,"00*0*12345678912328*0123456782*1"},
	   {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456783*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456784*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456785*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456786*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456787*1"},
           {expect,"Rechargement confirme."}
	   ]},
	 "Cas plus de 11 numeros",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"Numero prefere"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"0643000123"},
	   {expect,"Votre numero prefere est le 0643000123.*"},
	   {send,"1"},
	   {expect,"Rechargement confirme."},
	   {send,"00*0*12345678912328*0123456782*1"},
	   {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456783*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456784*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456785*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456786*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456787*1"},
           {expect,"Rechargement confirme."}, 
	   {send,"00*0*12345678912328*0123456788*1"},
	   {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456789*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456790*1"},
           {expect,"Rechargement confirme."},
           {send,"00*0*12345678912328*0123456791*1"},
           {expect,"Rechargement confirme."},
	   {send,"00*0*12345678912328*0123456792*1"},
           {expect,"Rechargement confirme."}
	   ]}
	] ++
	["Test numero prefere normal reussi"].

test_numpref_anomalie()->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC,cpte_numpref=?CETAT_AC,cpte_sms=?CETAT_AC,nb_sms=25,niv=?niv1,dcl=?tele2_cb2}) ++	
	test_util_of:set_present_period_for_test(commercial_date_tele2_cb,[recharge_numpref])++
	[
	{title, "Test rechargement numero prefere - Anomalie "},
	"Message d'erreur - 3 essais & failed",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"Numero prefere"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"064300012"},
	   {expect,"incorrect"},
	   {send,"064300012"},
	   {expect,"incorrect"},
	   {send,"064300012"},
	   {expect,"incorrect"},
	   {send,"0"},
	   {expect,".*"}
	  ]},
	 "Message d'erreur - 2 essais & OK",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"Numero prefere"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
	   {send, "12345678912328"},
	   {expect,"Veuillez entrer les 10 chiffres"},
	   {send,"064300012"},
	   {expect,"incorrect"},
	   {send,"0643000122*1"},
           {expect,"Rechargement confirme."}
          ]}	 
	] ++
	["Test d'anomalie reussi"].
     

send_numrecharge() ->
    {send, "12345678912328"}.
expected_recharge() ->
	{expect, "Veuillez entrer les 10 chiffres de votre numero prefere. Uniquement numeros fixes et mobiles en France metropolitaine"}.
	
refill_sms_illimites()->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_numpref=?CETAT_EP, cpte_sms=?CETAT_AC,nb_sms=25,niv=?niv1,dcl=?tele2_cb2}) ++
 	[
	 {title, "Test de rechargement par ticket de rechargement des compte"},
	 "Cas Classique",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,"1:Vos options"},
	   {send,"0"},
	   {expect,"les 14 chiffres"},
           {send,"15456516"},
           {expect,"rechargement refuse:votre code n'est pas correct"},
           {send,"15456516"},
           {expect,"rechargement refuse:votre code n'est pas correct"},
	   {send, "12345678912327"},
	   {expect,"Rechargement confirme.*"
	    "Vous disposez de SMS illimites en France metropolitaine vers tous"
            " les operateurs \\(hors no speciaux\\) jusqu'au ../../20.."}]}] ++
	update_refill_sms_account() ++
 	[
	 {title, "Selfcare Recharge SMS Illimites Tele2 TEST"},
	 "Usual case",
	 {ussd2,
	  [{send, ?CODE_SERVICE_MENU++"*#"},	
	   {expect,"2:SMS illimites"},
	   {send,"2"},
	   {expect,"TELE2 MOBILE.*"
	    "Recharge SMS illimites : vos SMS sont illimites vers tous les"
            " operateurs en France metropolitaine, hors no speciaux, 24h/24"
            " et 7j/7 jusqu'au ../../0."}]}].


test_refill()->
    test_util_of:insert_list_top_num(?msisdn,
					 [0, 111])++
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_numpref=?CETAT_EP, cpte_princ=?CETAT_AC,cpte_sms=?CETAT_AC,nb_sms=25,niv=?niv1,dcl=?tele2_cb2}) ++

	[
	 {title, "Test de rechargement Suivi-conso: "},
 	"Cas Classique",
	 {ussd2,
	  [ {send, ?CODE_SERVICE_MENU++"*"},
	    {expect, ?TXT_NIV1_AC_EP_AC}
             ]}, 

	 {ussd2,
	  [ {send, ?CODE_SERVICE_MENU++"*0#"},
	    {expect,?FILL_CODE}
             ]},   

	 "Code CG FAUX",
	 {ussd2,
	  [ {send,?CODE_SERVICE_MENU++"*0a1234567890123"},
	    {expect,?RECHARGEMENT_REFUSE}
	   ]},
	 "Code CG OK",
	 {ussd2,
	  [ {send, ?CODE_SERVICE_MENU++"*012345678912311#"},
	    {expect,"Vous venez de recharger .*"
	     "Nouveau solde de votre compte:.*"}
	   ]}
	].

test_promo_surf_wap() ->
    test_util_of:set_imei(?imsi,?niv1)++
	test_util_of:insert(?imsi, ?tele2_cb, 0,
                        [#compte{tcp_num=?C_PRINC,
                                 unt_num=?EURO,
                                 cpp_solde=30000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=?CETAT_AC,
                                 ptf_num=?PTF_TELE2_CB1},
			#compte{tcp_num=?C_PROMO_SURF_TELE2,
                                 unt_num=?EURO,
                                 cpp_solde=3000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=?CETAT_AC,
                                 ptf_num=?PTF_TELE2_CB1}
			])++
	[{title, "Test promo Surf wap : "},
	 {ussd2,
	  [ {send, ?CODE_SERVICE_MENU++"*"},
	    {expect, "Vos promos en cours"},
	    {send, "1"},
	    {expect,"Promotion surf sur le wap : nombre de ko restant sur les 200ko offerts : "
	     ".*Ko. Utilisable 24/24 7j/7 jusqu'au 27/04/08 hors telechargements de contenus"}
	   ]}
	].
