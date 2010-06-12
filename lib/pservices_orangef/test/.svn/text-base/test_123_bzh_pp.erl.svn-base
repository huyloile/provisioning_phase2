-module(test_123_bzh_pp).

-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").

-define(DIRECT_CODE,"#123").
-define(P_MOBI,1).
-define(IMSI,"999000904001006").
-define(MSISDN,"+99904001006").
-define(UNDEFINED, not_defined).
-define(CAS_OMER, [{Princ, Odr}
		   ||
		      Princ <- [?CETAT_AC,?CETAT_EP,?CETAT_PE,not_defined],
		      Odr <- [?CETAT_AC,?CETAT_EP,?CETAT_PE,not_defined]] ).

-record(cpte_test,{dcl,princ,forf_virgin,niv,cpte_odr,opt_sms,nb_sms}).
run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,test()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
top_num(Opt) ->
     svc_options:top_num(Opt,bzh_cmo).
tcp_num(Opt) ->
    svc_options:tcp_num(Opt,bzh_cmo).
ptf_num(Opt)->
    svc_options:ptf_num(Opt,bzh_cmo).

top_num_list(?CETAT_EP,_Nb_SMS)->    
    [0, 86];
top_num_list(_,Nb_SMS) ->
    [0, 86, top_num(Nb_SMS)].

test() ->

    [{title, "Tests OMER"}] ++

	[] ++
        test_util_of:connect() ++
	test_util_of:connect_sachem_fake(omer) ++
	test_util_of:init_test(?IMSI,"omer", 1) ++
	[{msaddr, {subscriber_number, private, ?IMSI}}] ++
	test_util_of:set_in_sachem(?IMSI,"omer") ++	
	test_util_of:insert_list_top_num(?MSISDN,[0, top_num(opt_sms_200)])++
   	%test_omer_niv3(?omer) ++   
    	%test_omer_niv2(?omer) ++   
    	test_omer_niv1(?omer) ++
	%test_omer_niv3(?DCLNUM_BREIZH_PREPAID) ++   
    	%test_omer_niv2(?DCLNUM_BREIZH_PREPAID) ++   
    	test_omer_niv1(?DCLNUM_BREIZH_PREPAID) ++
	["Test reussi"] ++

	[].

test_omer_niv3(DCL) ->
    change_navigation_to_niv3() ++
	tester_tous_les_cas(?CAS_OMER,niv3,DCL) ++
	[].

test_omer_niv2(DCL) ->
    change_navigation_to_niv2() ++
	tester_tous_les_cas(?CAS_OMER,niv2,DCL) ++
	[].

test_omer_niv1(DCL) ->
    change_navigation_to_niv1() ++
	tester_tous_les_cas(?CAS_OMER,niv1,DCL) ++
	[].
%
test_omer_niv1_multi_DCL([])->
    [];
test_omer_niv1_multi_DCL([H|T]) ->
    test_omer_niv1(H) ++
	test_omer_niv1_multi_DCL(T).
%
tester_tous_les_cas([],_,_) -> [];
tester_tous_les_cas([H|T],Niveau,DCL) ->
    if
	Niveau == niv1 ->
%		modif_etat_princ(H,DCL) ++
%		rendre_service_ussd(H,Niveau,DCL) ++
		rendre_service_ussd_recharge(H,Niveau) ++
%		rendre_service_ussd_etranger(H,Niveau) ++
		tester_tous_les_cas(T,Niveau,DCL) ++   
		[];
		    
	true ->
		modif_etat_princ(H,DCL) ++
		rendre_service_ussd(H,Niveau,DCL) ++
		tester_tous_les_cas(T,Niveau,DCL) ++   
		[]
    end.

%%%%%%%%  clauses expected pour les configs de test omer niv 3  %%%%%%%%%%%%%
expected({?CETAT_AC, _}, niv3,DCL) -> 
    if 
	DCL==?omer ->
	    [{expect,
	      "soit jusqu'a .* de com. avant le.*"
	     }];
	true->
	    [{expect,"Breizh Mobile: .*E a utiliser avant le ../../.."}]
    end;
expected({_, _}, niv3,DCL) -> 
    [{expect,"Merci de recharger au 224 avant le ../../.."}];

expected({?CETAT_AC, ?CETAT_AC}, niv2,DCL)->
    if
	DCL==?omer->
	    [{expect,
	      "Breizh Mobile bonjour.*"
	      "Credit: .* soit jusqu'a .* jusqu'au .*"
	      "Autre compte: .* jusqu'au .*"
	     }];
	true->
	    [{expect,
	      "Votre credit Breizh Mobile est de.*"
	      "6.00E a utiliser avant le ../../...*"
	      "Autre compte: 42.00E jusqu'au ../../.."}]
    end;
expected({?CETAT_AC, _}, niv2,DCL)->
    if 
	DCL==?omer->
	    [{expect,
	      "Votre credit Breizh Mobile est de .* soit jusqu'a .* de communications ou .* SMS a utiliser avant le .*"
	     }];
	true->
	    [{expect,"Votre credit Breizh Mobile est de  6.00E a utiliser avant le  ../../...*"
	      "Votre tarif : 19cts/mn et 9cts/SMS."}]
    end;
expected({_, ?CETAT_AC}, niv2,DCL) ->
    if 
	DCL==?omer->
	    [{expect,
	      "Jusqu'au .* il reste .*"
	      "Vous pouvez recharger au 224 avant le .* pour garder votre numero."
	     }];
	true->
	    [{expect,"Jusqu'au ../../.., il vous reste  42.00E.*"
	      "Vous pouvez recharger sur breizhmobile.com avant le ../../.. pour garder votre numero."}]
    end;
expected({_, _}, niv2,DCL) ->
    if
	DCL==?omer->
	    [{expect,
	      "Votre credit est epuise.*"
	      "Recharger votre compte en appelant gratuitement le 224 avant le .* pour conserver votre numero"
	     }];
	true->
	     [{expect,"Credit epuise.*Vous pouvez recharger sur breizhmobile.com avant le ../../.. pour garder votre numero."}]
    end;

expected({?CETAT_AC, ?CETAT_AC}, niv1,DCL) ->
    if
	DCL==?omer->
	    [{expect,
	      "Breizh Mobile bonjour.*"
	      "Votre credit est de.*"
	      "Autre compte:.*"
	      "1:Recharger.*"
	      "2:Menu"
	     }];
	true->
	    [{expect,"Breizh Mobile bonjour.*"
	      "Votre credit est de.*"
	      "a utiliser avant le.*"
	      "Votre tarif : 19cts/mn et 9cts/SMS.*"
	      "Autre compte:.*"
	      "1:Recharger.*"
	      "2:Menu"}]
   end;

expected({?CETAT_AC, _}, niv1,DCL) ->
    if
	DCL==?omer->
	    [{expect,
	      "Breizh Mobile bonjour.*"
	      "Votre credit est de.*"
	      "a utiliser avant le.*"
	      "1:Recharger.*"
	      "2:Menu"
	     }];
	true->
	    [{expect,"Breizh Mobile bonjour.*"
	      "Votre credit est de.*"
	      "a utiliser avant le.*"
	      "Votre tarif : 19cts/mn et 9cts/SMS.*"
	      "1:Recharger.*"
	      "2:Menu"}]
    end;

expected({_, ?CETAT_AC}, niv1,DCL) ->
    if
	DCL==?omer->
	    [{expect,
	      "Votre credit principal est epuise.*"
	      "Autre compte: il vous reste.*"
	      "Vous pouvez recharger avant le .*"
	      "et conserver ainsi votre numero.*"
	      "1:Recharger.*"
	      "2:Menu"
	     }];
	true->
	    [{expect,"Credit epuise.*"
	      "Recharger votre compte et conserver votre numero: menu 1 ou breizhmobile.com avant .*"
	      "Autre compte: il vous reste.*"
	      "1:Recharger.*"
	      "2:Menu"}]
    end;

expected({_, _}, niv1,DCL) ->
    if
	DCL==?omer->
	    [{expect,
	      "Votre credit est epuise.*"
	      "Vous pouvez recharger votre compte avant le .*"
	      "et conserver ainsi votre numero.*"
	      "1:Recharger.*"
	      "2:Menu"}];
	true->
	    [{expect,"Credit epuise.*"
	      "Recharger votre compte et conserver votre numero: menu 1 ou breizhmobile.com avant le.*"
	      "1:Recharger.*"
	      "2:Menu"}]
     end.


test_failure(Text) ->
    ["Test failure case, "++Text,
     {ussd2,
      [
       {send,"#123*#"},
       {expect, "Desole mais ce service est convalescent pour le moment"}
      ]}].

rendre_service_ussd(H,Niveau,DCL) ->
    case H of 
	{not_defined,niv1} ->
	    test_failure("rendre service");
	{not_defined,_} ->
	    [];
	_ ->
	    [{ussd2,
	      [
	       {send,"#123*#"}] ++ expected(H,Niveau,DCL)     
	     }]
    end.

rendre_service_ussd_recharge(H,Niveau) ->
    case H of 
	{not_defined,niv1} ->
	    test_failure("recharge");
	{not_defined,_} ->
	    [];
	_ ->
	    ["TEST SELFCARE OMER - RECHARGE"] ++
		[
		 "TTK 176",
		 {ussd2,
		  [{send,"#123*1#"},
		   {expect, "Tapez sans leur faire mal les 14 chiffres de votre code de rechargement..*"
		    "Appuyez sur . pour annuler. Attention, vous n.avez que 3 essais.*"},
		   {send, "12345678912360"++"#"},
		   {expect,"C'est parti ! Vous avez effectue un rechargement d'un montant de .*E. "
		    "Le solde de votre credit est de .*E valable jusqu'au .* A bientot.*"}
		  ]
		 },
		 "TTK 177",
		 {ussd2,
		  [{send,"#123*1#"},
		   {expect, "Tapez sans leur faire mal les 14 chiffres de votre code de rechargement..*"
		    "Appuyez sur . pour annuler. Attention, vous n.avez que 3 essais.*"},
		   {send, "12345678912361"++"#"},
		   {expect,"C'est parti ! Vous avez effectue un rechargement d'un montant de .*E. "
		    "Le solde de votre credit est de .*E valable jusqu'au .* A bientot.*"}
		  ]
		 }
		]	    
    end.

rendre_service_ussd_etranger(H,Niveau) ->
    case H of 
	{not_defined,niv1} ->
	    test_failure("tarif a l'etranger");
	{not_defined,_} ->
	    [];
	_ ->
	    ["TEST SELFCARE OMER - TARIF A L'ETRANGER"]++
		[{ussd2,
		  [{send,"#123*2#"},
		   {expect,
		    "1:Connaitre les tarifs a l'etranger.*00:Menu.*"},
		   {send,"1"},
		   {expect,"Les destinations sont classees en 4 zones tarifaires : Europe, Suisse/Andorre, "
		    "Maghreb/Amerique du Nord/Turquie et .*Reste du monde"},
		   {send,"1"},
		   {expect,"Un seul tarif est applique par zone pour vos appels voix vers la France Metropolitaine ou la zone de votre destination.*Prix/mn des appels emis depuis et.*"},
		   {send,"1"},
		   {expect,"vers: la zone Europe =0.514E, \\(sauf Suisse-Andorre =1E15\\), la zone Maghreb/Amerique du Nord/Turquie=1.40E, la zone \"Reste du monde\"=3E. Prix/mn des appels.*"},
		    {send,"1"},
 		   {expect,"recus depuis : la zone Europe = 0.227E, \\(sauf Suisse-Andorre =0.65E\\), la zone Maghreb/Amerique du Nord/Turquie = 0.75E, la zone.*"},
 		   {send,"1"},
 		   {expect,"En zone UE, vos appels sont decomptes a la sec des la 1ere sec pour la reception, a la sec au-dela de 30sec indivisibles pour les emissions d'appel en UE.*"},
 		   {send,"1"},
 		   {expect,"et vers la France. Dans les autres pays, facturation a la sec au-dela de la 1ere min indivisible. Envoi d'1 SMS vers ou depuis l'etranger:.*0.30E \\(0,1315E"},
 		   {send,"1"},
 		   {expect,"depuis UE vers UE\\), reception gratuite. Envoi d'1 MMS vers ou depuis l'etranger: 1.10E. Reception d'un MMS: 0.80E. Prix des connexions data depuis.*"},
		   {send,"1"},
		   {expect,"l'etranger:0,25E TTC/10ko.*"}
		  ]
		 }]
    end.

%%%%%%%%%%%%%%%%% APIs de sachem_test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etat_int_to_str(?CETAT_AC) -> "actif";
etat_int_to_str(?CETAT_EP) -> "epuise";
etat_int_to_str(?CETAT_PE) -> "perime";
etat_int_to_str(?UNDEFINED) -> "not defined".
    

modif_etat_princ({Principal,Odr},DCL) ->
    ["Changement etat du {compte principal, Odr} -> {"++etat_int_to_str(Principal)++", "++etat_int_to_str(Odr)++"}"] ++     
     test_util_of:insert(?IMSI,
			 DCL,%?omer, ?DCLNUM_BREIZH_PREPAID,
			 0,
			 compte(Principal,Odr),[]).

compte(Principal,Odr) ->
    make_compte(?C_PRINC,?EURO,5000,Principal,47)++
	 make_compte(?C_FORF_ODR,?EURO,42000,Odr,?PTF_ODR_OMER)++
	[].

make_compte(_,_,_,not_defined,_) ->
    [];
make_compte(TCP,UNT,CPP,ETAT,PTF) ->
     [#compte{tcp_num=TCP,
	      unt_num=UNT,
	      cpp_solde=CPP,
	      dlv=pbutil:unixtime(),
	      rnv=0,
	      etat=ETAT,
	      ptf_num=PTF}].

change_navigation_to_niv1()->
    test_util_of:change_navigation_to_niv(1, ?IMSI).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_navigation_to_niv2()->
    test_util_of:change_navigation_to_niv(2, ?IMSI).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_navigation_to_niv3()->
    test_util_of:change_navigation_to_niv(3, ?IMSI).

