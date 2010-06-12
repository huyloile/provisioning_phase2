-module(test_144_tele2_pp).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").
-include("profile_manager.hrl").

-define(Uid,tele2_user).
-define(DIRECT_CODE,"*144").
%% -define(imsi,     "999000900000001").
-define(END_UNIX,1091746939).
%% -define(Msisdn, "9900000001").
-define(DCL_CASINO, 54).
-define(DCL_TELE2_PP, 20).
-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2
-define(PE, ?CETAT_PE). %3

%% For main account.
-define(LISTE_DES_ETATS1,[{?AC,"actif"},
			 {?EP,"epuise"}
                         ]).

-define(LISTE_DES_ETATS2,[{?EP,"epuise"},
                          {?AC,"actif"},
                          {?PE,"perime"}
                         ]).

-define(LISTE_PLANS_A_TESTER,[{?PTELE2_PP,     "classique"},
			      {?PTELE2_PP2,    "plan du 15/11/07"},
			      {?PTF_CASINO_PP, "MVNO Casino"}]).

-define(LISTE_NIV,[{1,"Niveau 1"},
		   {2,"Niveau 2"},
		   {3,"Niveau 3"}]).

-record(cpte_test,{plan, princ, niv, cpt_second}).
%% cpt_second is a list of 3 elements: elmt1 %state of ?C_RECH_ROAMING_TELE2
%%                                     elmt2 %state of ?C_RECH_SMS_ILLM

-define(TOUS_LES_CAS, [#cpte_test{plan=P, princ=S1, niv=1,
                                  cpt_second=[S2,S3]} ||
                          {P,_}  <- ?LISTE_PLANS_A_TESTER,
			  {S1,_} <- ?LISTE_DES_ETATS1,
			  {S2,_} <- ?LISTE_DES_ETATS2,
			  {S3,_} <- lists:reverse(?LISTE_DES_ETATS2),
			  {N,_}  <- ?LISTE_NIV]).

dcl_num(?PTELE2_PP) ->
    ?tele2_pp;
dcl_num(?PTELE2_PP2) ->
    ?tele2_pp2;
dcl_num(?PTF_CASINO_PP) ->
    ?casino_pp.

plan_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LISTE_PLANS_A_TESTER),
    Nom.

etat_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LISTE_DES_ETATS2),
    Nom.


niv_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LISTE_NIV),
    Nom.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% afficher_cpte_test(#cpte_test{plan=P,princ=E1,niv=Niv, cpt_second=[E2,E3]}) ->
%%     "Tele2 PP Suivi-conso " ++
%% 	niv_name(Niv) ++ " PLAN " ++ plan_name(P) ++ "\n" ++
%% 	" PRINCIPAL " ++ etat_name(E1) ++ "\n" ++
%% 	" Cpte Roaming " ++ etat_name(E2) ++ "\n" ++
%% 	" Cpte SMS illimtes " ++ etat_name(E3).

afficher_cpte_test(#cpte_test{plan=P,princ=E1,niv=Niv, cpt_second=[E2,E3]}) ->    
    "Tele2 PP Suivi-conso " ++
        niv_name(Niv) ++ " PLAN " ++ plan_name(P) ++ "\n" ++
        " PRINCIPAL " ++ etat_name(E1) ++ "\n" ++
        " Cpte Roaming " ++ etat_name(E2) ++ "\n" ++
        " Cpte SMS illimtes " ++ etat_name(E3) ++ "\n".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Cpte::cpte().
%% +deftype cpte()= cpte_test_niv1()|cpte_test_niv2()|cpte_test_niv1().
consultation_dun_compte(Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: " ++ afficher_cpte_test(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected(Cpte)}
       ]}     
    ].

tester_tous_les_cas([]) -> [];
tester_tous_les_cas([H|T]) ->
    modif_etat_dun_cpte(H) ++ 
	consultation_dun_compte(H) ++ 
	tester_tous_les_cas(T).


%% modif_etat_dun_cpte(#cpte_test{plan=P, princ=E1, niv=Niv,
%%                                cpt_second=E}) ->
%%     test_util_of:change_navigation_to_niv(Niv, ?imsi) ++
%%         build_accounts(P, E1, E).

modif_etat_dun_cpte(#cpte_test{plan=P, princ=E1, niv=Niv,
                               cpt_second=E}) ->    
%%     test_util_of:change_navigation_to_niv(Niv, ?imsi) ++
        build_accounts(P, E1, E)++
	[].

build_accounts(P, E1, [E2, E3]) ->
    profile_manager:set_list_comptes(?Uid, [
					    #compte{tcp_num=?C_PRINC,
						    unt_num=?EURO,
						    cpp_solde=50000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=E1,
						    ptf_num=P},
					    #compte{tcp_num=?C_RECH_ROAMING_TELE2,
						    unt_num=?EURO,
						    cpp_solde=30000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=E2,
						    ptf_num=171},
					    #compte{tcp_num=?C_RECH_SMS_ILLM,
						    unt_num=?EURO,
						    cpp_solde=1000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=E3,
						    ptf_num=41} 
                                           ]);
%%     test_util_of:insert(?imsi,dcl_num(P),0,
%%                         [#compte{tcp_num=?C_PRINC,
%%                                  unt_num=?EURO,
%%                                  cpp_solde=50000,
%%                                  dlv=pbutil:unixtime(),
%%                                  rnv=0,
%%                                  etat=E1,
%%                                  ptf_num=P},
%%                          #compte{tcp_num=?C_RECH_ROAMING_TELE2,
%%                                  unt_num=?EURO,
%%                                  cpp_solde=30000,
%%                                  dlv=pbutil:unixtime(),
%%                                  rnv=0,
%%                                  etat=E2,
%%                                  ptf_num=171},
%%                          #compte{tcp_num=?C_RECH_SMS_ILLM,
%%                                  unt_num=?EURO,
%%                                  cpp_solde=1000,
%%                                  dlv=pbutil:unixtime(),
%%                                  rnv=0,
%%                                  etat=E3,
%%                                  ptf_num=41}
%% 			]);


build_accounts(P, E1, _) ->
    profile_manager:set_list_comptes(?Uid, [
					    #compte{tcp_num=?C_PRINC,
						    unt_num=?EURO,
						    cpp_solde=50000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=E1,
						    ptf_num=P},
					    #compte{tcp_num=?C_RECH_ROAMING_TELE2,
						    unt_num=?EURO,
						    cpp_solde=30000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=?PE,
						    ptf_num=171},
					    #compte{tcp_num=?C_RECH_SMS_ILLM,
						    unt_num=?EURO,
						    cpp_solde=1000,
						    dlv=pbutil:unixtime(),
						    rnv=0,
						    etat=?PE,
						    ptf_num=41}
                                           ]).

%%     test_util_of:insert(?imsi,dcl_num(P),0,
%%                         [#compte{tcp_num=?C_PRINC,
%%                                  unt_num=?EURO,
%%                                  cpp_solde=50000,
%%                                  dlv=pbutil:unixtime(),
%%                                  rnv=0,
%%                                  etat=E1,
%%                                  ptf_num=P},
%%                          #compte{tcp_num=?C_RECH_ROAMING_TELE2,
%%                                  unt_num=?EURO,
%%                                  cpp_solde=30000,
%%                                  dlv=pbutil:unixtime(),
%%                                  rnv=0,
%%                                  etat=?PE,
%%                                  ptf_num=171},
%%                          #compte{tcp_num=?C_RECH_SMS_ILLM,
%%                                  unt_num=?EURO,
%%                                  cpp_solde=1000,
%%                                  dlv=pbutil:unixtime(),
%%                                  rnv=0,
%%                                  etat=?PE,
%%                                  ptf_num=41}
%% 			]).


modif_etat_roaming(P) ->
    test_util_of:insert(?imsi,dcl_num(P),0,
			[#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=50000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?AC,
				     ptf_num=1},
			#compte{tcp_num=?C_RECH_ROAMING_TELE2,
				     unt_num=?EURO,
				     cpp_solde=30000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?AC,
				     ptf_num=171}]).


-define(TXT_EURO, "EUR.*").
-define(TXT_DATE, "../../...*").
-define(TXT_EP, "Votre credit.*epuise.*").
-define(TXT_LIEN_MENU, "1:Recharger.*").

%% Expression regulieres pour les niv1,niv2 et niv3 :

expected(#cpte_test{plan=?PTELE2_PP,princ=?AC,niv=1}) ->
    ?TXT_EURO++?TXT_DATE++?TXT_LIEN_MENU;
expected(#cpte_test{plan=?PTELE2_PP,princ=?EP, niv=1}) ->
    ?TXT_EP++?TXT_LIEN_MENU;
expected(#cpte_test{plan=?PTELE2_PP,princ=?AC,niv=_}) -> ?TXT_EURO++?TXT_DATE;
expected(#cpte_test{plan=?PTELE2_PP,princ=?EP,niv=_}) -> ?TXT_EP;
expected(#cpte_test{plan=?PTELE2_PP,princ=?PE,niv=_}) -> ?TXT_EP;

%% Expression regulieres pour les niv1,niv2 et niv3 du second compte:
expected(#cpte_test{plan=?PTELE2_PP2,princ=?AC,niv=3}) -> 
    "Credit : .*EUR soit jsqu'a .*min valables jsqu'au ../../.*";
expected(#cpte_test{plan=?PTELE2_PP2,princ=?EP,niv=3}) ->
    "Credit epuise. Merci de recharger en appelant le 224 \\(gratuit\\)";

expected(#cpte_test{plan=?PTELE2_PP2,princ=?AC,niv=2}) -> 
    "Credit : .*EUR soit jusqu'a.* valables jusqu'au ../../... "
        "Votre ligne est valable jusqu'au ../../.*";
expected(#cpte_test{plan=?PTELE2_PP2,princ=?EP,niv=2}) ->
    "Votre credit est epuise.*Votre ligne est valable jusqu'au ../../.*Pour "
        "recharger, appelez le 224 \\(gratuit\\).";

expected(#cpte_test{plan=?PTELE2_PP2,princ=?AC,niv=1,
                    cpt_second=[?PE,?PE]}) ->
    "TELE2 MOBILE.*Credit : .*EUR soit jusqu'a.*valables jusqu'au ../../..."
        ".*Votre ligne est valable jusqu'au ../../.*Pour recharger, tapez 1 et validez";
expected(#cpte_test{plan=?PTELE2_PP2,princ=?AC,niv=1}) ->
    "TELE2 MOBILE.*Credit : .*EUR soit jusqu'a.*valables jusqu'au ../../..."
        " Votre ligne est valable jusqu'au ../../.*1:Recharger";
expected(#cpte_test{plan=?PTELE2_PP2,princ=?EP,niv=1,
                    cpt_second=[?PE,?PE]}) ->
    "TELE2 MOBILE.*Votre credit est epuise. Votre ligne est valable jusqu'au"
        " ../../.*Pour recharger, tapez 1 et validez.";
expected(#cpte_test{plan=?PTELE2_PP2,princ=?EP,niv=1}) ->
    "TELE2 MOBILE.*Votre credit est epuise. Votre ligne est valable jusqu'au"
        " ../../.*1:Recharger";

%% Expression regulieres pour les niv1,niv2 et niv3 pour le MVNO Casino:
expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?AC,niv=3}) -> 
    "Credit : .*EUR soit jsqu'a .*min valables jsqu'au ../../.*";
expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?EP,niv=3}) ->
    "Credit epuise. Merci de recharger en appelant le 224 \\(gratuit\\)";

expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?AC,niv=2}) -> 
    "Credit : .*EUR soit jusqu'a.* valables jusqu'au ../../... Votre ligne "
        "est valable jusqu'au ../../.*";
expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?EP,niv=2}) ->
    "Votre credit est epuise.*Votre ligne est valable jusqu'au ../../.*Pour "
        "recharger, appelez le 224 \\(gratuit\\).";

expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?AC,niv=1,
                    cpt_second=[?PE,?PE]}) ->
    "TELE2 MOBILE.*Credit : .*EUR soit jusqu'a.*valables jusqu'au ../../..."
        " Votre ligne est valable jusqu'au ../../.*Pour recharger, tapez 1 "
        "et validez.*1:Recharger";
expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?AC,niv=1}) ->
    "TELE2 MOBILE.*Credit : .*EUR soit jusqu'a.*valables jusqu'au ../../..."
        " Votre ligne est valable jusqu'au ../../.*1:Recharger";
expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?EP,niv=1,
                    cpt_second=[?PE,?PE]}) ->
    "TELE2 MOBILE.*Votre credit est epuise. Votre ligne est valable jusqu'au"
        " ../../.*Pour recharger, tapez 1 et validez.*1:Recharger";
expected(#cpte_test{plan=?PTF_CASINO_PP,princ=?EP,niv=1}) ->
    "TELE2 MOBILE.*Votre credit est epuise. Votre ligne est valable jusqu'au"
        " ../../.*1:Recharger".

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

    %%Test title
    [{title, "Test du service *144# Tele2"}] ++

         %%Connection to the USSD simulator
         test_util_of:connect() ++

%%         %%Initialization of customer data in the local database
%% 	test_util_of:insert_imsi_db(?imsi) ++

%%         %%Initialization of customer data in the OCF simulator
%% 	test_util_of:ocf_set(?imsi,"tele2_pp")++

%%         %%Initialization of customer data in the SACHEM simulator
%% 	test_util_of:set_in_sachem(?imsi,"tele2_pp")++

	profile_manager:create_and_insert_default(?Uid, #test_profile{sub="tele2_pp",dcl=?DCL_TELE2_PP})++
        profile_manager:init(?Uid)++

        %%Test construction
 	selfcare_test() ++
 	recharge_ticket_pp2() ++
	recharge_ticket_casino() ++

	recharge_roaming() ++
	recharge_sms_illimites()++
 	recharge_casino_15E()++
	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++

        [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfcare_test() ->
    ["SELFCARE Tele2 Prepaid"] ++
	tester_tous_les_cas(?TOUS_LES_CAS) ++
	[].
call_refill_others_accounts(Account="casino")->
     lists:append([refill_others_accounts(PTF_NUM, Account, Operator, Comment) ||
                         {PTF_NUM, Account, Operator, Comment} <-
                             [
                              {?PTF_CASINO_PP, Account, "Casino Mobile", "Casino"}
]]);
call_refill_others_accounts(Account) ->
     lists:append([refill_others_accounts(PTF_NUM, Account, Operator, Comment) ||
                         {PTF_NUM, Account, Operator, Comment} <-
                             [
                              {?PTF_CASINO_PP, Account, "Casino Mobile", "Casino"},
                               {?PTELE2_PP, Account, "TELE2 Mobile", "Tele2 PP DCL 20"},
                              {?PTELE2_PP2, Account, "TELE2 Mobile", "Tele2 PP DCL 54"}
]]).
recharge_roaming()->
    refill_others_accounts("roaming").

recharge_sms_illimites()->
    refill_others_accounts("sms illimites").

recharge_casino_15E()->
    refill_others_accounts("casino").    

refill_others_accounts(Account)->
    test_util_of:set_past_period_for_test(commercial_date_tele2_pp,
                                          [recharge_code]) ++
	call_refill_others_accounts(Account).
refill_others_accounts(PTF_NUM, Account, Operator, Comment)->
    test_util_of:set_present_period_for_test(commercial_date_tele2_pp,[recharge_tr]) ++
	modif_etat_dun_cpte(#cpte_test{princ=?AC,plan=PTF_NUM,niv=1,cpt_second=[?PE,?PE]})++
	case Account of 
	    "roaming" -> 
		profile_manager:update_sachem(?Uid, "csl_tck", {"TTK_NUM","162"});
            "sms illimites" ->  
		profile_manager:update_sachem(?Uid, "csl_tck", {"TTK_NUM","161"});
	    _ -> []

	end 	     
	++
	[
	{title, "Test de rechargement par ticket de rechargement des compte "++Comment},
	"Cas Classique",
	 {ussd2,
	  [{send, ?DIRECT_CODE++"*#"},
            refill_text1(PTF_NUM),
            refill_text2(PTF_NUM),
 	   {expect,"les 14 chiffres"},
            refill_text3(Account),
            refill_text4(Account),
 	    {send, "0872345689"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "9"},
 	   refill_text1(PTF_NUM),
             refill_text2(PTF_NUM),
            {expect,"les 14 chiffres"},
             refill_text3(Account),
             refill_text4(Account),
 	   {send, "0672345689"},
 	   {expect, ".*"},
 	   {send, "1"},
            {expect, ".*"},
	   {send, "9"},
	   refill_text1(PTF_NUM),
             refill_text2(PTF_NUM),
            {expect,"les 14 chiffres"},
             refill_text3(Account),
             refill_text4(Account),
            {send, "0352345689"},
            {expect, ".*"},
            {send, "1"},
            {expect, ".*"},
	   {send, "9"},
	   refill_text1(PTF_NUM),
             refill_text2(PTF_NUM),
            {expect,"les 14 chiffres"},
             refill_text3(Account),
             refill_text4(Account),
            {send, "0400345689"},
            {expect, ".*"},
            {send, "1"},
            {expect, ".*"},
	   {send, "9"},
	   refill_text1(PTF_NUM),
             refill_text2(PTF_NUM),
            {expect,"les 14 chiffres"},
             refill_text3(Account),
             refill_text4(Account),
            {send, "0628345689"},
            {expect, ".*"},
            {send, "1"},
            {expect, ".*"},
	   {send, "9"},
	   refill_text1(PTF_NUM),
             refill_text2(PTF_NUM),
            {expect,"les 14 chiffres"},
             refill_text3(Account),
             refill_text4(Account),
            {send, "0600345689"},
            {expect, ".*"},
            {send, "1"},
            {expect, ".*"},
	   {send, "9"},
 	    refill_text1(PTF_NUM),
             refill_text2(PTF_NUM),
            {expect,"les 14 chiffres"},
             refill_text3(Account),
             refill_text4(Account),
            {send, "0652345689"},
            {expect, ".*"},
            {send, "1"},
            {expect, ".*"},
	   {send, "9"},
	   {expect, ".*"}
	  ]}] ++
        activate_sec_account(Account, PTF_NUM) ++
	[].
refill_text1(?PTELE2_PP) ->
    {expect, "1:Recharger"};
refill_text1(_) ->
    {expect, "1:Recharger"}.
refill_text2(?PTELE2_PP) ->
    {send,"11"};
refill_text2(_) ->
    {send,"11"}.
refill_text3("roaming") ->
    {send, "12345678912326"};
refill_text3("sms illimites") ->
    {send, "12345678912327"};
refill_text3("casino") ->
    {send, "12345678912329"}.

refill_text4("roaming") ->
    	   {expect,"Rechargement confirme. "
	    %% "Vous disposez de 21.00E de credit pour appeler depuis les "
	    "Vous disposez de .*E de credit pour appeler depuis les "
            "Etats-Unis, le Maroc, l'Algerie, la Tunisie et la Turquie. "
	    "Credit valable jusqu'au ../../20.."};
refill_text4("sms illimites") ->
    {expect, "Vous venez de recharger.*"
    "Nouveau solde de votre compte.*"
    "valables jusqu'au.*"};
refill_text4("casino") ->
%%     {expect, "Vous venez de recharger 15EUR.*"}.
  {expect, "Vous venez de recharger .*EUR.*"}.

activate_sec_account("roaming", PTF_NUM) ->    
        modif_etat_dun_cpte(#cpte_test{princ=?AC,plan=PTF_NUM,niv=1,
                                       cpt_second=[?AC,?PE]});
activate_sec_account("sms illimites", PTF_NUM) ->
    modif_etat_dun_cpte(#cpte_test{princ=?AC,plan=PTF_NUM,niv=1,
                                       cpt_second=[?PE,?AC]});
activate_sec_account("casino", PTF_NUM) ->
    modif_etat_dun_cpte(#cpte_test{princ=?AC,plan=PTF_NUM,niv=1,
                                       cpt_second=[?PE,?AC]}).

recharge_ticket_pp2()->
    test_util_of:set_present_period_for_test(commercial_date_tele2_pp,[recharge_tr]) ++
    modif_etat_dun_cpte(#cpte_test{princ=?AC,plan=?PTELE2_PP2,niv=1})++
       [
	{title, "Test de rechargement par ticket de rechargement second compte"},
	"Cas Classique",
	{ussd2,
	 [ {send, ?DIRECT_CODE++"*#"},
	   {expect, "1:Recharger"},
	   {send, "1"},
	   {expect, "TELE2 MOBILE.*Si vous disposez d'un code de rechargement, tapez 1 puis validez Sinon, tapez 2 puis validez.*"},
	   {send, "2"},  
	   {expect, "TELE2 MOBILE.*Vous pouvez acheter des recharges chez votre revendeur habituel ou sur www.tele2mobile.fr.*"
	    "Pour recharger immediatement par carte bancaire, appelez le 430.*0:Retour"},
	   {send, "0"},
	   {expect, "1:Recharger"},
	   {send,"11"},
	   {expect, "TELE2 MOBILE.*Pour recharger, tapez les 14 chiffres de votre code de rechargement puis validez.*"},
	   {send, "1234"},  
	   {expect, "Ce code n'est pas valide.."
	    "Merci de retaper votre code et validez.*"},
	   {send, "12345678912351"},
	   {expect, "Vous venez de recharger .*EUR sur votre compte.*"
	    "Nouveau solde de votre compte:.*EUR "
	    "soit jusqu'a .*valables jusqu'au .*"}
	  ]}	
    ]. 

recharge_ticket_casino()->
    test_util_of:set_present_period_for_test(commercial_date_tele2_pp,[recharge_tr]) ++
    modif_etat_dun_cpte(#cpte_test{princ=?AC,plan=?PTF_CASINO_PP,niv=1,cpt_second=[?PE,?AC]})++
    profile_manager:set_dcl(?Uid, ?DCL_CASINO)++
     
       [
	{title, "Test de rechargement par ticket de rechargement des compte Casino"},
	"Cas Classique",
	{ussd2,
	 [ {send, ?DIRECT_CODE++"*#"},
	   {expect, "1:Recharger"},
	   {send, "1"},
	   {expect, "Casino Mobile.*Si vous disposez d'un code de rechargement, tapez 1 et validez.*Sinon, tapez 2 et validez.*"},
	   {send, "2"},  
	   {expect, "Casino Mobile.*Vous pouvez acheter des recharges chez votre magasin Casino ou sur le site www.casino.fr.*"
	    "Pour recharger immediatement par carte bancaire, appelez le 430.*0:Retour"},
	   {send, "0"},
	   {expect, "1:Recharger"},
	   {send,"11"},
	   {expect, "Casino Mobile.*Pour recharger, tapez les 14 chiffres de votre code de rechargement puis validez.*"},
	   {send, "1234"},  
	   {expect, "Rechargement refuse : votre code n'est pas correct.*"
	    "Merci de verifier votre code et de renouveler l'operation.*"
	    "Attention vous n'avez droit qu'a 3 essais.*"},
 	   {send, "12345678912351"},
 	   {expect, "Vous venez de recharger .*EUR sur votre compte.*"
 	    "Nouveau solde de votre compte:.*EUR "
 	    "soit jusqu'a .*valables jusqu'au .*"}
	  ]}] ++
       [
	{title, "Test de rechargement par ticket de rechargement des compte Casino Erreur"},
	"Cas Classique - NOK",
	{ussd2,
	 [ {send, ?DIRECT_CODE++"*1*1#"},
	   {expect, "Casino Mobile.*Pour recharger, tapez les 14 chiffres de votre code de rechargement puis validez.*"},
%% 	   {send, "12345678912334"},  
	   {send, "1234567891233"},
	   {expect, "Rechargement refuse : votre code n'est pas correct. Merci de verifier votre code et de renouveler l'operation"}
	  ]}]++	
	%% Revert DCL to Tele_pp dcl
	profile_manager:set_dcl(?Uid, ?DCL_TELE2_PP)++
	[]
. 

