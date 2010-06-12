-module(test_plan_tarif_omer).

-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").

-define(imsi,"999000904000001").
-define(msisdn,"+33605000001").

-define(DLV,svc_util_of:local_time_to_unixtime({{2004,12,25},{1,1,1}})).

-record(test,{dcl,plan,etats_sec,solde}). %% gratuites restantes
-define(CAS1, [#test{dcl=?omer,plan=P,etats_sec=E,solde=S} || 
		      P <- [44,
			    45,
			    46,
			    47
			   ],
		      E <- [0,
			    ?SETAT_PT,
			    ?SETAT_PT bor ?SETAT_P2],
		      S <- [5000,
			    2000]
			 ]).

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,test()).

test() ->

    %%Test title
    [{title, "Test de changement de plan tarifaire OMER"}] ++

%%         %%Initialization of OMA configuration parameters
%% 	test_util_of:set_present_period_for_test(commercial_date,[plan_zap]) ++

%%         %%Connection to the USSD simulator (smppasn by default)
%%         test_util_of:connect() ++

%%         %%Initialization of customer data in the local database
%% 	test_util_of:init_test({imsi,?imsi},
%% 			       {subscription,"omer"},
%% 			       {navigation_level,1},
%% 			       {msisdn,?msisdn}) ++

%% 	%%Initialization of customer data in the SACHEM simulator
%% 	test_util_of:set_in_sachem(?imsi,?msisdn,"omer") ++

%% 	%%Test construction
%% 	tester_tous_les_cas(?CAS1) ++

%% 	%%Session closing
%% 	test_util_of:close_session() ++
	
	["CDC OMER CDC V5.3 : Le changement de plan tarifaire n'est plus disponible."] ++

	["Test reussi"] ++

	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tester_tous_les_cas([]) -> [];
tester_tous_les_cas([#test{dcl=?omer,plan=P,etats_sec=E,solde=S}=H|T]) ->
    title_record(H) ++
	init_dossier(H) ++
	before_change(H) ++
	init_dossier(H#test{plan=plan_after_change(P)}) ++
	after_change(H) ++

	tester_tous_les_cas(T) ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

title_record(#test{dcl=?omer,plan=P}) ->
    [{title,"Changement de plan OMER : plan tarifaire numero "++ integer_to_list(P)}].


%%%%%%%%%%%%% clauses pour les configs de test omer niv 1 %%%%%%%%%%%%%%%%%
init_dossier(#test{dcl=?omer,plan=P,etats_sec=E,solde=S}) ->
    test_util_of:insert(?imsi,
			?omer,
			0,
			[#compte{tcp_num=?C_PRINC,
 				 unt_num=?EURO,
 				 cpp_solde=S,
 				 dlv=pbutil:unixtime()+24*60*60,
 				 rnv=0,
 				 etat=?CETAT_AC,
 				 ptf_num=P}
			],
			[{etats_sec,E}])++

	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

before_change(#test{plan=44,solde=5000,etats_sec=0}=T) ->
    [{ussd2,
      [{send,"#123*#"},
       {expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_free()}]}];

before_change(#test{plan=44,solde=5000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_next_free()}]}];

before_change(#test{plan=44,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_price_3EUR()}]}];

before_change(#test{plan=44,solde=2000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_free()}]}];

before_change(#test{plan=44,solde=2000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_next_free()}]}];

before_change(#test{plan=44,solde=2000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,text_not_enough_credit()}]}];

before_change(#test{plan=45,solde=5000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_lanc_change_free()}]}];

before_change(#test{plan=45,solde=5000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_lanc_change_next_free()}]}];

before_change(#test{plan=45,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_lanc_price_3EUR()}]}];

before_change(#test{plan=45,solde=2000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_lanc_change_free()}]}];

before_change(#test{plan=45,solde=2000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_lanc_change_next_free()}]}];

before_change(#test{plan=45,solde=2000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,text_not_enough_credit()}]}];

before_change(#test{plan=46,solde=5000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_free()}]}];

before_change(#test{plan=46,solde=5000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_next_free()}]}];

before_change(#test{plan=46,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_price_3EUR()}]}];

before_change(#test{plan=46,solde=2000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_free()}]}];

before_change(#test{plan=46,solde=2000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique seconde.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_sec_change_next_free()}]}];

before_change(#test{plan=46,solde=2000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,text_not_enough_credit()}]}];

before_change(#test{plan=47,solde=5000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_clas_change_free()}]}];

before_change(#test{plan=47,solde=5000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_clas_change_next_free()}]}];

before_change(#test{plan=47,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"5.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_clas_price_3EUR()}]}];

before_change(#test{plan=47,solde=2000,etats_sec=0}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,"1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_clas_change_free()}]}];

before_change(#test{plan=47,solde=2000,etats_sec=?SETAT_PT}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect, "1:plan classique minute.*00:menu.*0:retour"},
       {send, "1"},
       {expect,text_plan_clas_change_next_free()}]}];

before_change(#test{plan=47,solde=2000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    [{ussd2,
      [{send,"#123*#"},{expect,"2.00EUR"},
       {send,"00*2"},
       {expect,text_not_enough_credit()}]}];

before_change(_)->
    [{ussd2,
      [{send,"#123*#"},{expect,".*enu"}]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

after_change(#test{plan=44,solde=5000,etats_sec=0}=T) ->
    changed_to_second_5EUR();

after_change(#test{plan=44,solde=5000,etats_sec=?SETAT_PT}) ->
    changed_to_second_5EUR();

after_change(#test{plan=44,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    changed_to_second_5EUR();

after_change(#test{plan=44,solde=2000,etats_sec=0}) ->
    changed_to_second_2EUR();

after_change(#test{plan=44,solde=2000,etats_sec=?SETAT_PT}) ->
    changed_to_second_2EUR();

after_change(#test{plan=45,solde=5000,etats_sec=0}) ->
    changed_to_minute_5EUR();

after_change(#test{plan=45,solde=5000,etats_sec=?SETAT_PT}) ->
    changed_to_minute_5EUR();

after_change(#test{plan=45,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    changed_to_minute_5EUR();

after_change(#test{plan=45,solde=2000,etats_sec=0}) ->
    changed_to_minute_2EUR();

after_change(#test{plan=45,solde=2000,etats_sec=?SETAT_PT}) ->
    changed_to_minute_2EUR();

after_change(#test{plan=46,solde=5000,etats_sec=0}) ->
    changed_to_second_5EUR();

after_change(#test{plan=46,solde=5000,etats_sec=?SETAT_PT}) ->
    changed_to_second_5EUR();

after_change(#test{plan=46,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    changed_to_second_5EUR();

after_change(#test{plan=46,solde=2000,etats_sec=0}) ->
    changed_to_second_2EUR();

after_change(#test{plan=46,solde=2000,etats_sec=?SETAT_PT}) ->
    changed_to_second_2EUR();

after_change(#test{plan=47,solde=5000,etats_sec=0}) ->
    changed_to_minute_5EUR();

after_change(#test{plan=47,solde=5000,etats_sec=?SETAT_PT}) ->
    changed_to_minute_5EUR();

after_change(#test{plan=47,solde=5000,etats_sec=?SETAT_PT bor ?SETAT_P2}) ->
    changed_to_minute_5EUR();

after_change(#test{plan=47,solde=2000,etats_sec=0}) ->
    changed_to_minute_2EUR();

after_change(#test{plan=47,solde=2000,etats_sec=?SETAT_PT}) ->
    changed_to_minute_2EUR();

after_change(_)->
    [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plan_after_change(Plan_init) 
  when Plan_init==44 ->
    45;
plan_after_change(Plan_init) 
  when Plan_init==45 ->
    44;
plan_after_change(Plan_init) 
  when Plan_init==46 ->
    47;
plan_after_change(Plan_init) 
  when Plan_init==47 ->
    46.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

changed_to_minute_5EUR() ->
    [{ussd2,
      [{send,"#123#"},{expect,text_continue_session()},
       {send, "1"},
       {expect, "Vous utilisez maintenant le plan classique minute.*"
	"00:menu"},
       {send, "00*0"},
       {expect,"5.00EUR"}]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

changed_to_minute_2EUR() ->
    [{ussd2,
      [{send,"#123#"},{expect,text_continue_session()},
       {send, "1"},
       {expect, "Vous utilisez maintenant le plan classique minute.*"
	"00:menu"},
       {send, "00*0"},
       {expect,"2.00EUR"}]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

changed_to_second_5EUR() ->
    [{ussd2,
      [{send,"#123#"},{expect,text_continue_session()},
       {send, "1"},
       {expect, "Vous utilisez maintenant le plan classique seconde.*"
	"00:menu"},
       {send, "00*0"},
       {expect,"5.00EUR"}]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

changed_to_second_2EUR() ->
    [{ussd2,
      [{send,"#123#"},{expect,text_continue_session()},
       {send, "1"},
       {expect, "Vous utilisez maintenant le plan classique seconde.*"
	"00:menu"},
       {send, "00*0"},
       {expect,"2.00EUR"}]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_sec_change_free() ->
    "Plan seconde: .*euros/s.*"
	"Vos deux premieres modifications de plan tarifaire sont gratuites.*"
	"1:choisir.*00:menu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_sec_change_next_free() ->
    "Plan seconde: .*euros/s.*"
	"Vous pouvez encore changer une fois gratuitement de plan tarifaire.*"
	"1:choisir.*00:menu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_lanc_change_free() ->
    "Plan lancement: les appels sont factures a un tarif unique de "
	".*euros/mn"
	".*Vos deux premieres modifications de "
	"plan tarifaire sont gratuites.*1:choisir".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_lanc_change_next_free() ->
    "Plan lancement: les appels sont factures a un tarif unique de "
	".*euros/mn"
	".*Vous pouvez encore changer une fois gratuitement de plan "
	"tarifaire.*1:choisir".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_clas_change_free() ->
    "Plan classique: les appels emis depuis l'Ouest sont factures a"
	".*euros/mn"
	".*Vos deux premieres modifications de "
	"plan tarifaire sont gratuites.*1:choisir".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_clas_change_next_free() ->
    "Plan classique: les appels emis depuis l'Ouest sont factures a "
	".*euros/mn"
	".*Vous pouvez encore changer une fois gratuitement de plan "
	"tarifaire.*1:choisir".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_not_enough_credit() ->
    "Votre credit est insuffisant pour demander une modification "
	"du plan tarifaire. Veuillez recharger votre compte.*1:recharger.*"
	"00:menu.*".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_sec_price_3EUR() ->
    "Plan seconde: .*euros/s.*"
	"Ce changement vous sera facture 3.00 EUR.*1:choisir.*00:menu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_lanc_price_3EUR() ->
    "Plan lancement: les appels sont factures a un tarif unique de "
	".*euros/mn"
	".*Ce changement vous sera facture 3.00 EUR.*1:choisir.*00:menu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_plan_clas_price_3EUR() ->
    "Plan classique: les appels emis depuis l'Ouest sont factures a "
	".*euros/mn"
	".*Ce changement vous sera facture 3.00 EUR.*1:choisir.*00:menu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_continue_session() ->
    "Plan.*".
