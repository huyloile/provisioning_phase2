-module(test_chat).

-export([run/0, online/0]).
-export([sms_receiver/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pgsm/include/sms.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(DIRECT_CODE, "##140").
-define(EXPECTED_SMSs,
	[{sms_mo, "MOI Tarzan"},
	 {sms_mo, "LISTE"}%,
	 %{sms_mo, "+GP Tarzan"}
	]).

-define(MY_MSISDN,"+99100000005").
-define(MY_IMSI,"999000901000000").

online() ->
    Pid = spawn_link(?MODULE, sms_receiver, [?EXPECTED_SMSs]),
    receive after 2000 -> ok end,
    Pid ! start,
    test_util_of:online(?MODULE,test_spec()),
    Pid ! stop.

sms_receiver(L) ->
    pong = net_adm:ping(possum@localhost),
    receive start -> ok end,
    smsloop_server:register_client(),
    receive_msgs(L).

receive_msgs([]) ->
    receive
	stop -> ok;
	X    -> exit({remaining_message, X})
    end;
receive_msgs([{sms_mo, Text}|T]) ->
    receive
	{fake_incoming_mo, #sms_incoming{deliver = D}} ->
	    #sms_deliver{dcs = DCS, udl = UDL, ud = UD} = D,
	    Dec = gsmcharset:ud2iso(DCS, UDL, UD),
	    case Text == Dec of
		true  -> ok;
		false -> exit({mismatch, Dec, {sms_mo, Text}})
	    end,
	    receive_msgs(T);
	M ->
	    exit({receive_msgs, M, {sms_mo, Text}})
    end;
receive_msgs([{sms_mt, Text}|T]) ->
    receive
	{fake_insert_sms, _X} ->
	    receive_msgs(T);
	M ->
	    exit({receive_msgs, M, {sms_mt, Text}})
    end.


-define(FIRST_PAGE,
	"Bienvenue sur le Chat Orange ! Toutes les infos sur ce "
	"service dans nos rubriques : "
	"1:Inscription "
	"2:Au programme "
	"3:Commandes SMS "
	"4:Recherche "
	"5:Plus d'infos").

test_spec() ->
    [
     {title, "Test suite for the USSD interface to Orange's Chat"},
     {connect_smpp, {"localhost", 7431}}] ++

	test_util_of:init_test({imsi,?MY_IMSI},
			       {subscription,"postpaid"},
			       {navigation_level,1},
			       {msisdn,?MY_MSISDN}) ++

	[{msaddr, {subscriber_number, private, ?MY_IMSI}}] ++

	test_util_of:close_session() ++

	[{ussd2,[
		 {send, ?DIRECT_CODE++"#"},
		 {expect, ?FIRST_PAGE},
		 {send, "1"},
		 {expect, "=Inscription - Etape 1/2= "
		  "Pour consulter les infos legales et les tarifs du Chat, appelez "
		  "gratuitement le 239 depuis votre mobile Orange. "
		  "1:Accepter "
		  "0:Refuser"},

		 {send, "1"},
		 {expect, "=Inscription - Etape 2/2= "
		  "Pour finaliser votre inscription au Chat, entrez le pseudo de "
		  "votre choix \\(prix d'un SMS \\+ 0,05 EUR TTC\\)\\. "
		  "Exemple : TARZAN "
		 }%,

		 %%{send, "Tarzan"},
		 %%{expect, "SMS envoye"}
		]},

	 {ussd2,[
		 {send, ?DIRECT_CODE++"*#"},
		 {expect, ?FIRST_PAGE},
		 {send, "3"},
		 {expect, "=Commandes SMS= Selectionnez la commande de votre choix "
		  "\\(prix d'un SMS \\+ 0,05 EUR TTC\\) : "
		  "1:Choisir un canal.*"
		  "2:Liste de pseudos.*"
		  "3:Lire les messages du canal.*"
		  "4:-->"}%,

		 %%{send, "2"},
		 %%{expect, "SMS envoye"}
		]},

	 {ussd2,[
		 {send, ?DIRECT_CODE++"*#"},
		 {expect, ?FIRST_PAGE},

		 {send, "3"},
		 {expect, "=Commandes SMS= Selectionnez la commande de votre choix "
		  "\\(prix d'un SMS \\+ 0,05 EUR TTC\\) : "
		  "1:Choisir un canal.*"
		  "2:Liste de pseudos.*"
		  "3:Lire les messages du canal.*"
		  "4:-->"},

		 {send , "4"},
		 {expect,"4:Envoyer un message sur le canal.*"
		  "5:Autres commandes.*"
		  "9:Accueil.*"},

		 {send, "5"},
		 {expect, "=Toutes les commandes=.*"
		  "1:Principales.*"
		  "2:Canaux.*"
		  "3:Infos perso.*"
		  "4:Groupes.*"
		  "5:Amis.*"
		  "6:Liste noire.*"
		  "7:Recherche.*"
		  "8:DUO.*"
		  "9:Quitter.*"
		  "9:Accueil"},

		 {send, "4"},
		 {expect, 
		  "=Groupes= "
		  "GP : recevoir la liste des pseudos de son groupe "
		  "\\+GP ou INVITE \\+ 'pseudo' : ajouter un pseudo dans son groupe "
		  "-GP ou KICK \\+'pseudo' ou : effacer un pseudo de son \\.\\.\\. "
		  "1:-->"
		 }

		]}] ++

	test_util_of:close_session().
