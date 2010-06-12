-module(test_plan_tarif_bzh_cmo).

-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").

-define(imsi,"208066000002003").

-define(POSSUM_ENV_VARS, [{pservices_orangef, commercial_date}]).
-define(DLV,svc_util_of:local_time_to_unixtime({{2004,12,25},{1,1,1}})).

-record(test,{dcl,plan,etats_sec,solde}). %% gratuites restantes
-define(CAS1, [#test{dcl=?bzh_cmo,plan=P,etats_sec=E,solde=S} || 
		 P <- [?PBZH_CMO_MIN, ?PBZH_CMO_SEC],
		 E <- [?SETAT_ID, ?SETAT_PT, ?SETAT_PT+?SETAT_P2],
		 S <- [5000,1000]
			 ]).
-define(CAS2, [#test{dcl=?bzh_cmo2,plan=P,etats_sec=E,solde=S} || 
		 P <- [?PBZH_CMO_MIN2, ?PBZH_CMO_SEC2],
		 E <- [?SETAT_ID, ?SETAT_PT, ?SETAT_PT+?SETAT_P2],
		 S <- [5000,1000]
			 ]).


run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,test()).

test() ->
%%     test_util_of:connect()++
%% 	test_util_of:set_present_period_for_test(commercial_date,[plan_zap]) ++
%% 	test_util_of:init_test(?imsi, "bzh_cmo", 1) ++
%% 	tester_tous_les_cas(?CAS1) ++
%% 	tester_tous_les_cas(?CAS2) ++
%% 	test_util_of:close_session() ++
	["CDC Bzh CDC V5.3 : Le changement de plan tarifaire n'est plus disponible."] ++
	[].

tester_tous_les_cas([]) -> [];
tester_tous_les_cas([H|T]) ->
    title_record(H) ++
	init_dossier(H) ++
	rendre_service_ussd(H) ++
	tester_tous_les_cas(T) ++
	[].

title_record(#test{dcl=?bzh_cmo,plan=P}) ->
    [{title,"Changement de plan BZH CMO: 1ère Offre\n"
      "Cas avec plan tarif "++integer_to_list(P)}
    ];
title_record(#test{dcl=?bzh_cmo2,plan=P}) ->
    [{title,"Changement de plan BZH CMO: 2ème Offre\n"
      "Cas avec plan tarif "++integer_to_list(P)}
    ].


%%%%%%%%%%%%% clauses pour les configs de test omer niv 1 %%%%%%%%%%%%%%%%%
init_dossier(#test{dcl=?bzh_cmo,plan=P,etats_sec=E,solde=S}) ->
    [{erlang_no_trace,
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[sub,{?imsi,"bzh_cmo"}]]}
     ]}
       ]++
   test_util_of:insert(?imsi,?bzh_cmo,0,[#compte{tcp_num=?C_FORF_BZH,
						   unt_num=?EURO,
						   cpp_solde=5000,
						   dlv=0,
						   rnv=10,
						   etat=?CETAT_AC,
						   ptf_num=P},
					 #compte{tcp_num=?C_PRINC,
						   unt_num=?EURO,
						   cpp_solde=S,
						   dlv=pbutil:unixtime()+24*60*60,
						   rnv=0,
						   etat=?CETAT_AC,
						   ptf_num=129}],[{etats_sec,E}])++
	[];
init_dossier(#test{dcl=?bzh_cmo2,plan=P,etats_sec=E,solde=S}) ->
    [{erlang_no_trace,
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[sub,{?imsi,"bzh_cmo"}]]}
     ]}
       ]++
   test_util_of:insert(?imsi,?bzh_cmo2,0,[#compte{tcp_num=?C_FORF_BZH2,
						   unt_num=?EURO,
						   cpp_solde=5000,
						   dlv=0,
						   rnv=10,
						   etat=?CETAT_AC,
						   ptf_num=P},
					 #compte{tcp_num=?C_PRINC,
						   unt_num=?EURO,
						   cpp_solde=S,
						   dlv=pbutil:unixtime()+24*60*60,
						   rnv=0,
						   etat=?CETAT_AC,
						   ptf_num=129}],[{etats_sec,E}])++
	[].


%%%%%%%%  clauses expected pour les configs de test omer niv 3  %%%%%%%%%%%%%
expected(#test{plan=?PBZH_CMO_MIN,etats_sec=E,solde=5000}) ->
    [{expect,".*enu"},
     {send,"00*2"},
     {expect,"1:Forfait a la seconde des la premiere seconde.*"++msg(E)},
     {send,"1"},
     {expect,"Forfait a la s des la 1ere s.*1:Choisir ce plan"},
     {send,"1"},
     {expect,"Vous utilisez maintenant.*Forfait a la seconde"}];
expected(#test{plan=?PBZH_CMO_SEC,etats_sec=E,solde=5000}) ->
    [{expect,".*enu"},
     {send,"00*2"},
     {expect,"1:Forfait a la seconde apres la premiere mn indivisible.*"++msg(E)},
     {send,"1"},
     {expect,"Forfait a la s apres la 1ere mn indivisible"},
     {send,"1"},
     {expect,"Vous utilisez maintenant.*Forfait a la seconde"}];
expected(#test{plan=?PBZH_CMO_MIN2,etats_sec=E,solde=5000}) ->
    [{expect,".*enu"},
     {send,"00*2"},
     {expect,"1:Forfait a la seconde des la premiere seconde.*"++msg(E)},
     {send,"1"},
     {expect,"Forfait a la s des la 1ere s.*1:Choisir ce plan"},
     {send,"1"},
     {expect,"Vous utilisez maintenant.*Forfait a la seconde"}];
expected(#test{plan=?PBZH_CMO_SEC2,etats_sec=E,solde=5000}) ->
    [{expect,".*enu"},
     {send,"00*2"},
     {expect,"1:Forfait a la seconde apres la premiere mn indivisible.*"++msg(E)},
     {send,"1"},
     {expect,"Forfait a la s apres la 1ere mn indivisible"},
     {send,"1"},
     {expect,"Vous utilisez maintenant.*Forfait a la seconde"}];
expected(#test{etats_sec=?SETAT_PT+?SETAT_P2,solde=1000}) ->
    [{expect,".*enu"},
     {send,"00*2"},
     {expect,"Votre credit est insuffisant"}];

expected(_)->
    [{expect,".*enu"}].

msg(?SETAT_ID)->
    "Vos deux premieres modifications de plan tarifaire";
msg(?SETAT_PT)->
    "Vous pouvez encore changer une fois gratuitement";
msg(?SETAT_PT+?SETAT_P2)->
    "Ce changement vous sera facture".

rendre_service_ussd(H) ->
    [{ussd2,
      [{send,"#123*#"}] ++ expected(H)     
     }].
