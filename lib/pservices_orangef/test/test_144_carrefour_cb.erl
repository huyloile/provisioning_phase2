-module(test_144_carrefour_cb).
-export([run/0, online/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../include/ftmtlv.hrl").%Main structures used in OF services
-include("../../ptester/include/ptester.hrl").%USSD simulator
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").%OCF/RDP simulator
-include("sachem.hrl").
-include("profile_manager.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(DIRECT_CODE,"*144").
-define(Uid, user_carrefour_cb).

-define(IMEI_NIV1, "100007XXXXXXX1").
-define(IMEI_NIV2, "100006XXXXXXX2").
-define(IMEI_NIV3, "100005XXXXXXX3").
-define(C_PRNC,  1).
-define(TCP_NUM_CPTE_Z1,   126).
-define(PTF_NUM_CPTE_Z1,   250).
-define(TCP_NUM_CPTE_Z2,   127).
-define(PTF_NUM_CPTE_Z2,   251).
-define(TCP_NUM_CPTE_Z3,   128).
-define(PTF_NUM_CPTE_Z3,   252).

%TEXT NIV, CPTE , Z1, Z2, Z3
-define(TEXT_NIV1_PAGE,".*Votre forfait: .*EUR a utiliser avant le  .*Compte rechargeable: .*EUR.*1:Recharger .*2:Vos options.*").
-define(TEXT_NIV1_NO_OPT_PAGE,".*Votre forfait: .*EUR a utiliser avant le  .*Compte rechargeable: .*EUR.*1:Recharger").
-define(TEXT_NIV1_EP_EP_EP_EP_PAGE,".*Votre forfait: .*EUR a utiliser avant le  .*Compte rechargeable: .*EUR.*1:Recharger .*").
-define(TEXT_NIV1_ALL_EP_PAGE,".*Votre forfait est epuise. Il sera renouvele le .*Pensez a nos recharges disponibles en Magasin, carrefour.fr et au 844..*").
-define(TEXT_NIV1_ONLY_CPTE_AC_PAGE,".*Votre forfait est epuise. Il sera renouvele le .*Compte rechargeable: .*EUR.*1:Recharger .*").
-define(TEXT_NIV1_AC_AC_AC_AC_OPT,".*Europe : .* Eur jusqu'au .*Maghreb/Turquie/Amerique du Nord : .* Eur jusqu'au .*Monde : .* Eur jusqu'au .*Recharge SMS illimites.*1:-->").
-define(TEXT_NIV1_AC_AC_AC_EP_OPT,".*Europe : .* Eur jusqu'au .*Maghreb/Turquie/Amerique du Nord : .* Eur jusqu'au .*").
-define(TEXT_NIV1_AC_AC_EP_EP_OPT,".*Europe : .* Eur jusqu'au .*9:Accueil").

-define(TEXT_NIV2_PAGE,".*Votre forfait: .*EUR a utiliser avant le  .*Compte rechargeable: .*EUR.*1:Recharger .*2:Vos options.*").
-define(TEXT_NIV2_ALL_EP_PAGE,".*Forfait epuise, il sera renouvele le .*Pensez a nos recharges disponibles en Magasin, carrefour.fr et au 844.*").
-define(TEXT_NIV2_AC_AC_AC_AC_OPT,".*Europe : .* Eur jusqu'au .*Maghreb/Turquie/Amerique du Nord : .* Eur jusqu'au .*Monde : .* Eur jusqu'au .*").

-define(TEXT_NIV3_PAGE,"Forfait: .*EUR jusqu'au .* - Cpte rech: .*EUR").
-define(TEXT_NIV3_ALL_EP_PAGE,"Votre compte est epuise. Pensez a nos recharges.*").
-define(TEXT_NIV3_ALL_EP_PAGE_SUITE,".*disponibles en Magasin, carrefour.fr et au 844..*").
 
-record(cpte_test,{niv,forf,cpte_princ,cpte_z1,cpte_z2,cpte_z3,cpte_sms_ill,dcl}).
-define(LIST_DCL,[{77,"carrefour_cb"},{78,"carrefour_cb2"},{79,"carrefour_cb3"}]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modify_account_state(DCL,#cpte_test{niv=IMEI,forf=ETAT_CB,cpte_princ=ETAT_CP,cpte_z1=ETAT_CP1,cpte_z2=ETAT_CP2,cpte_z3=ETAT_CP3,cpte_sms_ill=ETAT_RECH_SMS_ILL}) ->
	profile_manager:set_dcl(?Uid,DCL)++
	profile_manager:set_list_comptes(?Uid,
			 [#compte{tcp_num=?C_RECH_SMS_ILLM,unt_num=?EURO,cpp_solde=1000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_RECH_SMS_ILL,ptf_num=41},
			  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
				  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP,ptf_num=?PTF_CARREFOUR_CB1},
			  #compte{tcp_num=?C_FORF_CARREFOUR_CB,unt_num=?EURO,cpp_solde=20000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CB,ptf_num=?PTF_CARREFOUR_CB1},
			  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP,ptf_num=?PTF_CARREFOUR_CB2},
			  #compte{tcp_num=?C_FORF_CARREFOUR_CB,unt_num=?EURO,cpp_solde=20000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CB,ptf_num=?PTF_CARREFOUR_CB2},
			  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP,ptf_num=?PTF_CARREFOUR_CB3},
			  #compte{tcp_num=?C_FORF_CARREFOUR_CB,unt_num=?EURO,cpp_solde=20000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CB,ptf_num=?PTF_CARREFOUR_CB3},
			  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP,ptf_num=?PTF_CARREFOUR_CB4},
			  #compte{tcp_num=?C_FORF_CARREFOUR_CB,unt_num=?EURO,cpp_solde=20000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CB,ptf_num=?PTF_CARREFOUR_CB4},
			  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP,ptf_num=?PTF_CARREFOUR_CB5},
			  #compte{tcp_num=?C_FORF_CARREFOUR_CB,unt_num=?EURO,cpp_solde=20000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CB,ptf_num=?PTF_CARREFOUR_CB5},
			  #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP,ptf_num=?PTF_CARREFOUR_CB6},
			  #compte{tcp_num=?C_FORF_CARREFOUR_CB,unt_num=?EURO,cpp_solde=20000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CB,ptf_num=?PTF_CARREFOUR_CB6},
			  #compte{tcp_num=?TCP_NUM_CPTE_Z1,unt_num=?EURO,cpp_solde=24000,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP1,ptf_num=?PTF_NUM_CPTE_Z1},
			  #compte{tcp_num=?TCP_NUM_CPTE_Z2,unt_num=?EURO,cpp_solde=26500,
                                  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP2,ptf_num=?PTF_NUM_CPTE_Z2},
			  #compte{tcp_num=?TCP_NUM_CPTE_Z3,unt_num=?EURO,cpp_solde=39500,
				  dlv=pbutil:unixtime(),rnv=0,etat=ETAT_CP3,ptf_num=?PTF_NUM_CPTE_Z3}])++
	profile_manager:set_imei(?Uid,IMEI)++
	[].

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,selfcare_with_dcls()).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
niv1_menu_test(DCL)->
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_AC, cpte_z2=?CETAT_AC,cpte_z3=?CETAT_AC,cpte_sms_ill=?CETAT_AC}) ++
    [
     {title, "Test NIV1: ALL ACCOUNT ACTIVE"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_PAGE},
       {send,"2"},
       {expect,?TEXT_NIV1_AC_AC_AC_AC_OPT},
       {send, "1"},
       {expect, ".*9:Accueil.*"}
            ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_AC, cpte_z2=?CETAT_AC,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_AC}) ++
    [
     {title, "Test NIV1: Z3 EP"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_PAGE},
       {send,"2"},
       {expect,?TEXT_NIV1_AC_AC_AC_EP_OPT}
            ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_AC, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_AC}) ++
    [
     {title, "Test NIV1: Z2 Z3 and  EP"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_PAGE},
       {send,"2"},
       {expect,?TEXT_NIV1_AC_AC_EP_EP_OPT}
            ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV1: Z1, Z2, Z3,RECH_SMS_ILL and EP"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_NO_OPT_PAGE}
      ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_AC, cpte_princ=?CETAT_EP, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV1: only FORF ACT"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_EP_EP_EP_EP_PAGE}
      ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV1: all EP"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_ALL_EP_PAGE}
      ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_EP, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV1: only CPTE ACT"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV1_ONLY_CPTE_AC_PAGE}
      ]}]++
    test_util_of:close_session().

niv2_menu_test(DCL)->
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV2,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_AC, cpte_z2=?CETAT_AC,cpte_z3=?CETAT_AC,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV2: ALL ACCOUNT ACTIVE"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV2_PAGE},
       {send,"2"},
       {expect,?TEXT_NIV2_AC_AC_AC_AC_OPT}
            ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV2,forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++	
    [
     {title, "Test NIV2: all EP"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV2_ALL_EP_PAGE}
            ]}]++
    test_util_of:close_session().

niv3_menu_test(DCL)->
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV3,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV3: ACTIVE"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV3_PAGE}
            ]}]++
    test_util_of:close_session() ++
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV3,forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_z1=?CETAT_EP, cpte_z2=?CETAT_EP,cpte_z3=?CETAT_EP,cpte_sms_ill=?CETAT_EP}) ++
    [
     {title, "Test NIV3: EPUISE"},
     "Cas Classique",
     {ussd2,
      [
       {send, ?DIRECT_CODE++"#"},
       {expect,?TEXT_NIV3_ALL_EP_PAGE},
       {send, "1"},
       {expect, ?TEXT_NIV3_ALL_EP_PAGE_SUITE}
            ]}]++
    test_util_of:close_session().

test_refill(DCL)->
    modify_account_state(DCL,#cpte_test{niv=?IMEI_NIV1,forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_z1=?CETAT_AC, cpte_z2=?CETAT_AC,cpte_z3=?CETAT_AC,cpte_sms_ill=?CETAT_EP}) ++
	[
	 {title, "Test refill"},
	 "Cas Classique",
	 {ussd2,
	  [ {send, ?DIRECT_CODE++"*1#"},
	    {expect,"Veuillez saisir le code de rechargement \\(14 chiffres\\).*0:Retour.*00:Menu.*"},
	   {send, "0"},
	   {expect, ".*Recharger.*2:Vos options.*"}]
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
	     " solde est .* Euros.*0:Retour.*00:Menu.*"}	    
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
test_refill_ok(Z)->
    case Z of
	1->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=109,
                                                                      ctk_num=?CTK_CARREFOUR_Z1,
                                                                      accounts=[#account{tcp_num=1, montant=15000,
											 dlv=pbutil:unixtime()}]})++
		["Code CG OK - Compte Z1",
		 {ussd2,
		  [ {send, ?DIRECT_CODE++"*112345678912315#"},
		    {expect,"Votre rechargement a ete pris en compte. Votre nouveau"
		     " solde Compte Europe est 24.00 Euros.*0:Retour.*00:Menu.*"}
		   ]}];
	2 ->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=110,
                                                                      ctk_num=?CTK_CARREFOUR_Z2,
                                                                      accounts=[#account{tcp_num=1, montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
		["Code CG OK - Compte Z2",
		 {ussd2,
		  [ {send, ?DIRECT_CODE++"*112345678912316#"},
		    {expect,"Votre rechargement a ete pris en compte. Votre nouveau"
		     " solde Compte Maghreb/Turquie/Amerique du Nord est 26.50 Euros.*0:Retour.*00:Menu.*"}
		   ]}];
	3 ->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=111,
                                                                      ctk_num=?CTK_CARREFOUR_Z3,
                                                                      accounts=[#account{tcp_num=1, montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
		["Code CG OK - Compte Z3",
		 {ussd2,
		  [ {send, ?DIRECT_CODE++"*112345678912317#"},
		    {expect,"Votre rechargement a ete pris en compte. Votre nouveau"
		     " solde Compte Monde est 39.50 Euros.*0:Retour.*00:Menu.*"}
		   ]}];
	4 ->
	    profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=5,
                                                                      accounts=[#account{tcp_num=1, montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
                ["Code CG OK - Recharge SMS - TTK=5",
                 {ussd2,
                  [ {send, ?DIRECT_CODE++"*112345678912318#"},
                    {expect,"Votre rechargement a ete pris en compte. "
		     "SMS Illimites valable jusqu'au.*0:Retour.*00:Menu.*"}
                   ]}];
	5 ->
            profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=180,
                                                                      accounts=[#account{tcp_num=1, montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
                ["Code CG OK - Recharge SMS - TTK=180",
                 {ussd2,
                  [ {send, ?DIRECT_CODE++"*112345678912318#"},
                    {expect,"Votre rechargement a ete pris en compte. "
		     "SMS Illimites valable jusqu'au.*0:Retour.*00:Menu.*"}
                   ]}];
	6 ->
            profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{ttk_num=178,
                                                                      accounts=[#account{tcp_num=1, montant=15000,
                                                                                         dlv=pbutil:unixtime()}]})++
                ["Code CG OK - Recharge SMS - TTK=178",
                 {ussd2,
                  [ {send, ?DIRECT_CODE++"*112345678912318#"},
                    {expect,"Votre rechargement a ete pris en compte. "
		     "SMS Illimites valable jusqu'au.*0:Retour.*00:Menu.*"}
                   ]}];
	_ ->
	    []
    end.
test_refill_error(Code)->
    profile_manager:set_sachem_response(?Uid,{?rec_tck,{nok,{status, Code}}})++
	[
	 "Code CG NOK - Erreur" ,
	 {ussd2,
	  [ {send, ?DIRECT_CODE++"*112345678912319#"},
	    {expect,"Ce numero est incorrect. Veuillez, de nouveau, entrer les 14 chiffres situes au dos de votre recharge Carrefour Mobile.*0:Retour.*00:Menu.*"}
	   ]}].
selfcare(DCL) ->
    [ "Test du service selfcare Carrefour Compte Bloque." ] ++
	profile_manager:create_default(?Uid,"carrefour_comptebloque")++
	profile_manager:init(?Uid)++
	["####################DCL : "++integer_to_list(DCL)++"############################"]++
 	niv1_menu_test(DCL)++
 	niv2_menu_test(DCL)++
 	niv3_menu_test(DCL)++
	test_refill(DCL)++
	test_util_of:close_session()++
	[ "Test reussi." ].

selfcare_with_dcls()->
     lists:append([selfcare(DCL)||DCL<-[?DCLNUM_CARREFOUR_CB1,
 				       ?DCLNUM_CARREFOUR_CB2,
 				       ?DCLNUM_CARREFOUR_CB3,
 				       ?DCLNUM_CARREFOUR_CB4,
				       ?DCLNUM_CARREFOUR_CB5,
				       ?DCLNUM_CARREFOUR_CB6]]).
