-module(test_123_bzh_cmo).
-export([run/0, online/0]).


-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").

-define(DIRECT_CODE,"#123").
-define(imsi,"999000907000001").
-define(niv1,   "100007XXXXXXX1").
-define(niv2,   "100006XXXXXXX2").
-define(niv3,   "100005XXXXXXX3").


-record(cpte_test,{dcl,plan,princ,forf_bzh,cpte_odr,niv,opt_sms}).

-define(LISTE_DES_ETATS,[{?CETAT_AC,"actif"},
			 {?CETAT_EP,"epuise"}]).

-define(LISTE_DES_ETATS_ODR,[{?CETAT_AC,"actif"},
			     {?CETAT_EP,"epuise"},
			     {not_defined,"non defini"}]).


-define(LISTE_PLANS_A_TESTER,[{?PBZH_CMO_MIN,"Plan Minute"},
			      {?PBZH_CMO_SEC,"Plan Seconde"}]).

-define(LISTE_PLANS_A_TESTER2,[{?PBZH_CMO_MIN2,"Plan Minute"},
			      {?PBZH_CMO_SEC2,"Plan Seconde"}]).

-define(LISTE_DES_NIV,   [{?niv1,"Niveau 1"}%,
 		%	  {?niv2,"Niveau 2"},
 		%	  {?niv3,"Niveau 3"}
			  ]).

-define(LISTE_DES_DCL,   [{?bzh_cmo,"bzh_cmo"},
 			  {?bzh_cmo2,"bzh_cmo2"},
 			  {?DCL_BZH_CB1,"DCL_BZH_CB1"},
 			  {?DCL_BZH_CB2,"DCL_BZH_CB2"},
 			  {?DCL_BZH_CB3,"DCL_BZH_CB3"},
 			  {?DCL_BZH_CB4,"DCL_BZH_CB4"}
			  ]).




-define(TOUS_LES_CAS_BZH, [ #cpte_test{dcl=DCL,niv=N,plan=P,princ=S1,forf_bzh=S2,cpte_odr=S3,opt_sms=S4}
			    || 
			       {DCL,_}<- ?LISTE_DES_DCL,
			       {P,_}  <- ?LISTE_PLANS_A_TESTER,
			       {S1,_} <- ?LISTE_DES_ETATS,
			       {S2,_} <- ?LISTE_DES_ETATS,
			       {S3,_} <- ?LISTE_DES_ETATS_ODR,
			       {S4,_} <- ?LISTE_DES_ETATS_ODR,
				   {N,_} <- ?LISTE_DES_NIV]).

plan_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LISTE_PLANS_A_TESTER++?LISTE_PLANS_A_TESTER2),
    Nom.

etat_name(Int) ->
    etat_name(Int,?LISTE_DES_ETATS).

etat_name(Int,List) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, List),
    Nom.

afficher_cpte_test(#cpte_test{dcl=?bzh_cmo,plan=P,princ=E1,forf_bzh=E2,cpte_odr=E3,niv=N,opt_sms=E4}) ->
    "Forfait Bzh 1ère Offre\n" ++
	afficher_cpte_test(P,E1,E2,E3,N,E4);
afficher_cpte_test(#cpte_test{dcl=?bzh_cmo2,plan=P,princ=E1,forf_bzh=E2,cpte_odr=E3,niv=N,opt_sms=E4}) -> 
    "Forfait Bzh 2ère Offre\n" ++
	afficher_cpte_test(P,E1,E2,E3,N,E4);
afficher_cpte_test(#cpte_test{dcl=DCL,plan=P,princ=E1,forf_bzh=E2,cpte_odr=E3,niv=N,opt_sms=E4}) -> 
    "DCL "++integer_to_list(DCL)++"\n" ++
	afficher_cpte_test(P,E1,E2,E3,N,E4).

afficher_cpte_test(P,E1,E2,E3,N,E4) ->
    "IMEI: "++N++" PLAN "++plan_name(P)++" "
	++"PRINCIPAL"++" "++etat_name(E1)++" "
	++"Forf BZH"++" "++etat_name(E2)++" "
	++"Cpte Odr"++" "++etat_name(E3,?LISTE_DES_ETATS_ODR)++" "
	++"Cpte 200 SMS"++" "++etat_name(E4,?LISTE_DES_ETATS_ODR).
%% test_anormalie_3248(Cpte)->
%%     [
%%      {title, "Test anormalie 3249"},
%%       {ussd2,
%%       [ {send, ?DIRECT_CODE++"*#"},
%%         {expect, expected(Cpte)
%% %        ++ "1:recharger" %
%%         },
%%         {send,  "1*12345678912350"++"#"},
%%         {expect, "Rechargement refuse: votre code n'est pas correct.*"}
%%        ]
%%      },
%%      {ussd2,
%%       [ {send, ?DIRECT_CODE++"*#"},
%%         {expect, expected(Cpte)
%% %        ++ "1:recharger" %
%%         },
%%         {send,  "1*12345678912318"++"#"},
%%         {expect, "Rechargement refuse: votre code n'est pas correct.*"}
%%        ]
%%      },
%%      {ussd2,
%%       [ {send, ?DIRECT_CODE++"*#"},
%%         {expect, expected(Cpte)
%% %        ++ "1:recharger" %
%%         },
%%         {send,  "1*12345678912330" ++ "#"},
%%         {expect, "Rechargement refuse: votre code n'est pas correct.*"}
%%        ]
%%      }
%%     ].

consultation_dun_compte(Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++afficher_cpte_test(Cpte)},
     "Test TTK 176",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected(Cpte) 
%	 ++ "1:recharger" %
	},
	{send,  "1*12345678912360"++"#"},
	{expect, "Vous venez de recharger .*EUR"}
       ]
     },
     "Test TTK 177",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected(Cpte) 
%	 ++ "1:recharger" %
	},
	{send,  "1*12345678912361" ++ "#"},
	{expect, "Vous venez de recharger .*EUR"}
       ]
     }
    ].

consultation_dun_compte_tarifs_etrangers(Cpte) ->
    if 
	Cpte#cpte_test.niv == ?niv1 ->
	    [
	     {title, "CONSULTATION D'UN COMPTE: "++afficher_cpte_test(Cpte)},
	     {ussd2,
	      [ {send, ?DIRECT_CODE++"*00#"},
		{expect,"1:Connaitre les tarifs a l'etranger.*0:Retour"},
		{send,"1"},
		{expect,"Les destinations sont classees en 4 zones tarifaires : "
		 "Europe, Suisse.Andorre, Maghreb.Amerique du Nord.Turquie et.*Reste du monde.*1:suite"},
		{send, "1"},
		{expect,"Un seul tarif est applique par zone pour vos appels voix vers la France Metropolitaine ou la zone de votre destination.*Prix/mn des appels emis depuis et.*"},
		{send, "1"},
		{expect,"vers: la zone Europe =0.514E, \\(sauf Suisse-Andorre =1E15\\), la zone Maghreb/Amerique du Nord/Turquie=1.40E, la zone \"Reste du monde\"=3E. Prix/mn des appels"},
		{send, "1"},
		{expect,"recus depuis : la zone Europe = 0.227E, \\(sauf Suisse-Andorre =0.65E\\), la zone Maghreb/Amerique du Nord/Turquie = 0.75E, la zone \"Reste du monde\" = 1.50E."},
		{send, "1"},
		{expect,"En zone UE, vos appels sont decomptes a la sec des la 1ere sec pour la reception, a la sec au-dela de 30sec indivisibles pour les emissions d'appel en UE"},
		{send, "1"},
		{expect,"et vers la France. Dans les autres pays, facturation a la sec au-dela de la 1ere min indivisible. Envoi d'1 SMS vers ou depuis l'etranger: 0.30E \\(0,1315E"},
		{send, "1"},
		{expect,"depuis UE vers UE\\), reception gratuite. Envoi d'1 MMS vers ou depuis l'etranger: 1.10E. Reception d'un MMS: 0.80E. Prix des connexions data depuis"},
		{send,"1"},
		{expect,"l'etranger:0,25E TTC/10ko."}
	       ]}     
	    ];
	true -> []
   end.

tester_tous_les_cas([]) -> [];
tester_tous_les_cas([H|T]) ->
    modif_etat_dun_cpte(H) ++ 
%	test_anormalie_3248(H) ++
	consultation_dun_compte(H) ++ 
	consultation_dun_compte_tarifs_etrangers(H) ++
	 tester_tous_les_cas(T).

ptf_num(?bzh_cmo)->
    129;
ptf_num(?bzh_cmo2)->
    201;
ptf_num(?DCL_BZH_CB1)->
    88;
ptf_num(?DCL_BZH_CB2)->
    90;
ptf_num(?DCL_BZH_CB3)->
    92;
ptf_num(?DCL_BZH_CB4)->
    94.

compte(D,P1,E1,E2,E3,E4) ->
    [#compte{tcp_num=?C_PRINC,
	     unt_num=?EURO,
	     cpp_solde=5255,
	     dlv=pbutil:unixtime(),
	     rnv=0,
	     etat=E1,
	     ptf_num=ptf_num(D)},
     #compte{tcp_num=?C_FORF_BZH,
	     unt_num=?EURO,
	     cpp_solde=13955,
	     dlv=0,
	     rnv=10,
	     etat=E2,
	     ptf_num=P1}]
	++ case E3 of
	       not_defined ->
		    [];
	       _ -> [#compte{tcp_num=?C_FORF_ODR,
			     unt_num=?EURO,
			     cpp_solde=4650,
			     dlv=pbutil:unixtime(),
			     rnv=0,
			     etat=E3,
			     ptf_num=ptf_num(D)}]
		end
	++ case E4 of
	       not_defined ->
		   [];
	       _ -> [#compte{tcp_num=?OPT_SMS_200_BZH_CB,
			     unt_num=?EURO,
			     cpp_solde=5000,
			     dlv=pbutil:unixtime(),
			     rnv=0,
			     etat=E4,
			     ptf_num=96}]
	   end.

modif_etat_dun_cpte(#cpte_test{dcl=D,plan=P,princ=E1,forf_bzh=E2,cpte_odr=E3,niv=IMEI,opt_sms=E4}) ->
    test_util_of:set_imei(?imsi,IMEI)++
    test_util_of:insert(?imsi,D,0,compte(D,P,E1,E2,E3,E4)).

%%% ------------------------------------- CB1_4  ---------------------------------------------------------------

expected(forf,?CETAT_AC) ->
	"Credit: .*E soit .* ou .* SMS.*";
expected(forf,_) ->	
	"Credit epuise.*";	
expected(princ,?CETAT_AC) ->	
	"Compte rechargeable: .*E.*";
expected(odr,?CETAT_AC) ->
	"Autre compte: .*E jusqu'au .*";
expected(sms,?CETAT_AC) ->
	"Encore .* SMS sur votre option.*";
expected(_,_) -> 
	[].

expected(date_menu) ->
	"Mise a jour: .*";
	%"00:menu.*").
	%"1:recharger").
expected(#cpte_test{niv=?niv1,princ=ETAT_PRINC,forf_bzh=ETAT_FORF,cpte_odr=ETAT_ODR,opt_sms=ETAT_SMS}) -> 
	expected(forf,ETAT_FORF)++expected(princ,ETAT_PRINC)++expected(odr,ETAT_ODR)++expected(sms,ETAT_SMS)++expected(date_menu);
	
%% Niveau 2
expected(#cpte_test{forf_bzh=?CETAT_AC,cpte_odr=?CETAT_AC,niv=?niv2}) -> 
    "Votre forfait Breizh Mobile .*EUR valable jusqu'au ../../.. Compte rechargeable .*EUR Autre compte .*EUR jusqu'au ../..";
expected(#cpte_test{forf_bzh=?CETAT_AC,niv=?niv2}) -> 
    "Votre forfait: .*E soit jusqu'a .*min.*sec ou .*SMS a utiliser avant le ../../.. Compte rechargeable: .*E";
expected(#cpte_test{princ=?CETAT_AC,cpte_odr=?CETAT_AC,niv=?niv2}) -> 
    "Votre forfait est epuise, il sera renouvele le ../../.*Compte rechargeable .*EUR Solde autre compte .*EUR jusqu'au ../..";
expected(#cpte_test{princ=?CETAT_AC,niv=?niv2}) -> 
    "Votre forfait est epuise, il sera renouvele le ../../.*Compte rechargeable: .*EUR \\(duree de validite illimitee\\)";
expected(#cpte_test{cpte_odr=?CETAT_AC,niv=?niv2}) -> 
    "Forfait epuise, il sera renouvele le ../... Vous pouvez recharger votre compte au 224.*Solde autre compte .*EUR jusqu'au ../..";
expected(#cpte_test{niv=?niv2}) ->
    "Votre forfait est epuise. Il sera renouvele le ../../... Vous pouvez recharger votre compte en appelant gratuitement le 224.";

%% Niveau 3
expected(#cpte_test{princ=?CETAT_AC,niv=?niv3}) -> "Forfait: .*EUR jusqu'au ../../.. - Cpte rech: .*EUR";
expected(#cpte_test{forf_bzh=?CETAT_AC,niv=?niv3}) -> "Forfait: .*EUR jusqu'au ../../.. - Cpte rech: .*EUR";
expected(#cpte_test{niv=?niv3}) -> "Merci de recharger en appelant gratis le 224 avant le ../../..".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,selfcare()).

selfcare() ->

    [{title, "Test du service selfcare Bzh CMO"}] ++
	test_util_of:connect() ++
	[{msaddr, {subscriber_number, private, ?imsi}}] ++
	test_util_of:init_test(?imsi, "bzh_cmo") ++
	test_util_of:set_in_sachem(?imsi,"bzh_cmo") ++

	tester_tous_les_cas(?TOUS_LES_CAS_BZH) ++
%	tester_tous_les_cas(?TOUS_LES_CAS_BZH2) ++

	test_util_of:close_session() ++
	["Test reussi"] ++
        [].
