-module(test_annuaire).
-export([run/0, online/0,smsmo_queue_init/1,fill_db/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../include/annuaire.hrl").
-include("../../pgsm/include/sms.hrl").

-define(IMSI,"999000900000015").
-define(IMSI_ANSI,"999000900000014").
-define(IMSI_LEVEL_2_3,"208010900000001").
-define(MSISDN,"+99900000015").
-define(DIRECT_CODE, "#111#").
-define(STAR_CODE, "#111*").
-define(CODE_DIVERTISSEMENT, "2").
-define(CODE_EDITOR_BLOCK, "5").
-define(CODE_INFO, "3").
-define(CODE_SONNERIES_LOGOS, "4").
-define(CODE_HELP, "6").

-define(EXPECTEDSMSMOS,[
			{?MSISDN,"71717","HOR BEL"},
			{?MSISDN,"73321","724"},   
			{?MSISDN,"61020","QI"},
			{?MSISDN,"61500","RANDOM"},
			{?MSISDN,"61265","MAIL PSE PASS"}]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
   %% No unit tests.
   ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%% %% Checked out :
%%
%% CSV File (most checks done in csv_util):
%%  - Bad theme %%  - Heading in a no-heading Theme
%%  - No rules for games
%%  - Heading not in theme
%%
%% Service use :
%%  - DB Problem (update) - content is computed before page to sent:
%%         * theme/*update*
%%         * theme/noheading/*update*
%%         * theme/headings/*update*
%%         * theme/headings/heading/*update*
%%         * editor/block/*update*
%%         * editor/block/editor/*update*
%%         * editor/block/editor/heading/*update*
%%
%%  - Search by themes (use of back link to check reverse navigation)
%%         * Chat (no heading)
%%         * Horoscope (parameter to send with SMS)
%%         * Humour (syntaxic sugar in CSV)
%%         * Jeux -> "reglement"
%%         * Rings (browse all five services)
%%
%%  - Search by editors
%%         * Only one heading -> do not display teaser_multi, go to service
%%         * Several headings
%%
%%  - Help texts
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



online() ->
   application:start(pservices_orangef),
   QueuePid = smsmo_start_client(),
   test_db_loading(),
   test_util_of:online(?MODULE,test()).
   %%smsmo_stop_client(QueuePid).

test()->
    %%Test title
    [{title, "Tests annuaire"}] ++
	[test_util_of:connect(smpp)] ++
	test_util_of:init_test(?IMSI, "mobi", 1, null, "") ++
	test_util_of:init_test(?IMSI_ANSI, "mobi", 1, null, "") ++
	test_util_of:init_test(?IMSI_LEVEL_2_3, "mobi", 2, null, "") ++
	[{msaddr, {subscriber_number, private, ?IMSI}}] ++
	switch_smsmo_interface(enabled) ++
	test_annuaire() ++
	empty_db() ++
	test_util_of:close_session() ++
	["Test reussi"] ++
	[].
test_orange_jeux_SMS()->
        empty_db() ++
        fill_db() ++
        [
         "Reconnect to #111# - DB Update after multi-headings theme selection",
         {ussd2,
          [
           {send, ?DIRECT_CODE},
	   {expect,".*chat.*divertissement"},
	   {send, "2"},
	   {expect, ".*jeux"},
	   {send, "3"},
	   {expect, ".*"}
          ]}] ++
    [].
test_annuaire() ->
    SequencePh_2 = test_orange_jeux_SMS(),
	%misc_tests(2) ++ by_heading(2) ++ by_editor(2) ++ help(2),
%    SequencePh_1 = misc_tests(1) ++ by_heading(1) ++ by_editor(1) ++ help(1) ++ ansi(1),
    Phase_2  = SequencePh_2,
%    application:set_env(ptester,service_code,"#11*"),
%    Phase_1  = test_service:phase2_to_phase1(SequencePh_1),
%    Phase_2 ++ Phase_1,
%    Phase_1.
    Phase_2.

%%%% Do a few tests when loading CSV files (do not test csv2list errors)
test_db_loading() ->
   Sequence = [          %% Bad theme
         {"badtheme.csv",{error,{bad_theme,"Chat"}}},

         %% Heading in a no-heading Theme
         {"noheading.csv",
          {error,{heading_should_be_null,"chat"}}},

         %% No rules for games
         {"norules.csv",
          {error,{no_rules_for_heading,"jeux"}}},

         %% Heading not in theme
         {"badthemeheading.csv",
          {error,{bad_heading_in_theme,"Games",
              "divertissement"}}}
        ], 
   Test = fun({File,Awaiting}) ->
           case catch rpc:call(possum@localhost,annuaire,csv2mnesia,
                       ["../../test/data/"++File]) of
               Awaiting -> ok;
               Else ->                exit({badmatch,{{awaiting,Awaiting},{got,Else}}})
           end,
           io:format("~s : ok~n",[File])        end,

   lists:foreach(Test,Sequence).

%% Often used pages
welcome_first(2) ->
   {expect,"Bienvenue sur le guide Orange des services SMS/MMS."
    "Choisissez une rubrique en tapant le No correspondant:."
    ".+:chat"
    ".+:divertissement"
    ".+:info"
    ".+:sonneries/logos.+"};

welcome_first(1) ->
   {expect,"Bienvenue sur le guide Orange des services SMS/MMS."
    "Choisissez une rubrique en tapant le No correspondant:."
    ".+:chat"
    ".+:divertissement"
    ".+:info"}.

welcome(2) ->
   [welcome_first(2),{send,"5"},welcome_split(2)];

welcome(1) ->
   [welcome_first(1),{send,"4"},welcome_split(1)].

welcome_split(2) ->
   {expect,
    ".+:rech. par editeur."
    ".+:aide"};
welcome_split(1) ->
   {expect,
    ".+:sonneries/logos.+"
    ".+:rech. par editeur."
    ".+:aide"}.

divertissement() ->
   {expect,
    "Recherchez un service de divertissement en tapant le No correspondant:.*"
    ".*horoscope.*"
    ".*humour.*"
    ".*jeux.*"
    ".*radio/TV/presse.*"}.

info() ->
   {expect,
    "Recherchez un service d'info en tapant le No correspondant:"
    ".+:actu"
    ".+:finance"
    ".+:meteo"
    ".+:pratique."}.

horoscope() ->
   {expect,
    "Consultez les services offerts par les editeurs en tapant "
    "le No correspondant:"
    ".+:NIOKI"}. %% classified as new

pratique() ->
   {expect,
    "Consultez les services offerts par les editeurs en tapant "
    "le No correspondant:"
    ".+:TOPSMS"}. %% classified as new

editor_block_select() ->
   {expect,     "Recherchez les services de l'editeur de votre choix en tapant "
    "le No correspondant a son nom:"
    ".+:A a C"
    ".+:D a I"
    ".+:J a M"
    ".+:N a R"
    ".+:S a Z"}.

ba_c() ->
   {expect,
    "Consultez les services de l'editeur de votre choix en tapant "
    "le No correspondant:"
    ".+:AOL"
    ".+:Aerosms"
    ".+:Banque Populaire"
    ".+:CIC - FILBANQUE.+"}.

bS_Z() ->
   {expect,
    "Consultez les services de l'editeur de votre choix en tapant "
    "le No correspondant:"
    ".+:SMS Express"
    ".+:TOPSMS."
    ".+:Z6."}.

edM6() ->
   {expect,
    "Tous les services de la chaine de television M6: sonneries/logos, "
    "jeux, tests, chat et annuaire inverse."
    ".+:jeux"
    ".+:pratique"
    ".+:sonnerie."}.

horos_srv() ->
   {expect,"Pour recevoir ton horoscope hebdo, "
    "envoie HOR <esp> les 3 premieres lettres de ton signe au 71717 "
    "[(]0,50E [+] prix d'un SMS[)]"
    ".+:envoi du SMS"
    ".+:[+]d'infos."}.

sms_param_horos() ->
   {expect,"Pour acceder au service, veuillez preciser les 3 premieres "
    "lettres de votre signe."}.

sms_param_aero() ->
   {expect,"Pour acceder au service, veuillez preciser votre No de "
    "vol."}.

error() ->
   {expect,"Le service est en cours de maintenance.+"}.

%% we do not test if smsmo was successfully sent. %% Howewer, we might do so one day.
sms_nok() ->
   sms_ok().

sms_ok() ->
   {expect,"Le SMS est en cours d'envoi.."}.

%% Online tests

misc_tests(Phase) ->
    empty_db() ++
	[
	 {title, "Service interruption tests"},

	 "Connect to #111# - DB Update while connecting",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},error()
	  ]}] ++
	fill_db() ++
	[
	 "Reconnect to #111# - DB Update after noheading-theme selection",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},welcome_first(Phase)
	  ]}
	] ++
	empty_db() ++
	[
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},welcome_first(Phase),
	   {send,"2"},error()
	  ]}] ++
	fill_db() ++
	[
	 "Reconnect to #111# - DB Update after multi-headings theme selection",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},welcome_first(Phase)
	  ]}] ++
	empty_db() ++
	[
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},welcome_first(Phase),
	   {send,"2"},error()
	  ]}] ++

	fill_db() ++
	[
	 "Reconnect to #111# - DB Update before selecting editor block",
	 {ussd2,
	  [{send, ?DIRECT_CODE} | welcome(Phase)] ++
	  [
	   {send,?CODE_EDITOR_BLOCK},editor_block_select()
	  ]}] ++
	empty_db() ++
	[
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},editor_block_select(),
	   {send,"1"},error()
	  ]}] ++

	fill_db() ++
	[
	 "Reconnect to #111# - DB Update before editor selection",
	 {ussd2,
	  [{send, ?DIRECT_CODE}|welcome(Phase)] ++
	  [
	   {send,?CODE_EDITOR_BLOCK},editor_block_select(),
	   {send,"1"}
	  ]}] ++
	empty_db() ++
	[
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},ba_c(),
	   {send,"1"},error()
	  ]}] ++
	fill_db() ++
	[
	 "Reconnect to #111# - DB Update after editor's heading selection",
	 {ussd2,
	  [{send, ?DIRECT_CODE}|welcome(Phase)] ++
	  [
	   {send,?CODE_EDITOR_BLOCK},editor_block_select(),
	   {send,"5"},bS_Z(),
	   {send,"3"}
	  ]}] ++
	empty_db() ++
	[
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},edM6(),
	   {send,"1"},error()
	  ]}] ++

	fill_db() ++
	[
	 "Test with no 181 characters",
	 {msaddr, {subscriber_number, private,?IMSI_LEVEL_2_3}},
	 {ussd2,
	  [ {send, ?DIRECT_CODE},
	    {expect, "Votre mobile ne vous permet pas d'acceder a ce service"}
	   ]
	 },
	 {msaddr, {subscriber_number, private,?IMSI}}
	].

by_heading(Phase) ->

    %% WORKING TEST SUITE
    %% Fill DB and disable SMSMO interface
    NextLink = pbutil:get_env(pservices_orangef,annuaire_next_tag),

    fill_db() ++ switch_smsmo_interface(enabled) ++
	[
	 {title, "Navigation by headings"},
	 "Horoscope with parameter to send along with SMS - SMSMO enabled",
	 {ussd2,
 	  [{send, ?DIRECT_CODE}|welcome(Phase)] ++	  
  	  [
	   {send, ?DIRECT_CODE},
 	   {send,?CODE_DIVERTISSEMENT}, divertissement(),
 	   {send,"1"}, horoscope(),
  	   {send,"1"}, horos_srv(),
  	   {send,"1"}, sms_param_horos(),
  	   {send,"BEL"},sms_ok()
  	  ]
	 },

 	 "Horoscope with parameter to send along with SMS - SMSMO disabled"] ++
 	switch_smsmo_interface(disabled) ++
 	[
 	 {ussd2,
 	  [
 	   {send, ?DIRECT_CODE},sms_ok(),
 	   {send, "8*TAU"}, sms_nok(),
	   {send,"8*8*8*8*8"}
 	  ]
 	 },

	 "Navigate to humour service",
	 {ussd2,
	  [
	   {send,?CODE_DIVERTISSEMENT},
	   divertissement(),
	   %% Humour
	   {send,"2"},
	   {expect,"Consultez les services offerts par les editeurs en tapant "
	    "le No correspondant:"
	    ".+NIOKI"},
	   {send,"1"},

	   %% Keep double quotes from CSV  (""BLAGUE"")
	   {expect,"Pour recevoir une de nos blagues, envoie \"BLAGUE\" "
	    "au 71717 [(]0,50E [+] prix d'un SMS[)]."
	    ".+:envoi du SMS"
	    ".+:[+]d'infos."},
	   {send,"2"}, %% Check if there is no rules link
	   {expect,"Envie de t'eclater ou d'amuser la galerie [?] "
	    "Avec ce service, 1 SMS = 1 blague mortelle !."},
	   {send, "8*8*8*3"}
	  ]
	 },


	 "A Games Service",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},
	   {expect,"Consultez les services offerts par les editeurs "
	    "en tapant le No correspondant:"
	    ".+:Z6"
	    ".+:FHM.FR"
	    ".+:Aerosms."},
	   {send,"3"},
	   {expect,"Tapez votre numero de vol puis envoyez-le par SMS au "
	    "73321 [(]0,50E par envoi [+] prix d'un SMS[)].Service complet "
	    "par envoi de 2 SMS max"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos"},
	   {send,"2"},
	   {expect,"Londres, Rome ou Madrid[?]partez dans la ville de vos "
	    "reves ! Testez AeroSMS et gagnez un sejour ! Quand vous envoyez "
	    "un SMS au 73321, vous participez AUTOMATIQUEMENT"},
	   {send,"1"},
	   {expect,"tirage au sort qui designera les 3 gagnants d'un voyage "
	    "a Londres, Rome ou Madrid pour 2 personnes pendant 3 jours."
	    ".+reglement."}, %% Check for rules link
	   {send,"1"},
	   {expect,"Jeu gratuit, sans obligation d'achat organise par ADP "
	    "Telecom, valable jusqu'au 31/12/2003. 3 week-ends pour 2 "
	    "personnes. reglement disponible gratuitement a"},
	   {send,"1"},
	   {expect,"jeu: jeu Aero SMS - Cedex 2244 - 99224 PARIS CONCOURS. "
	    "reglement depose a l'etude Hauguel, Louail, Schambourg, "
	    "14 rue du Faubourg St Honore - 75008 Paris."},
	   {send,"8*8*1"}
	  ]
	 },
	 "Send SMS to AeroSMS - SMSMO disabled",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},sms_param_aero(),
	   {send,"724"},sms_nok()
	  ]
	 },

	 "Sends SMS to AeroSMS - SMSMO enabled"] ++
	switch_smsmo_interface(enabled) ++
	[
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},sms_nok(),
	   {send,"8*724"},sms_ok()

	  ]
	 },

	 "More Browsing",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE},sms_ok(),
	   {send,"8*8*8*8*8"}|welcome(Phase)] ++
	  [
	   {send,?CODE_INFO},info(),
	   {send,"4"},pratique(),
	   {send,"1"},

	   {expect,"Tester votre Q.I: envoyez QI au 61020 [(]0,35E [+] prix "         "d'un SMS[)]"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos"
	    ".+:" ++ NextLink},
	   {send,"2"},
	   {expect,"Avec TOP SMS, retrouvez le nom de la personne qui vous "
	    "a appelle, recevez les conseils de nos specialistes, participez "
	    "a des tests....*"},%% no rules link
	   {send,"8*1"}
	  ]
	 },

	 "Send SMS to TOPSMS - SMSMO enabled",
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},sms_ok()
	  ]
	 },

	 "Send SMS to TOPSMS - SMSMO disabled"] ++
	switch_smsmo_interface(disabled) ++
	[
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},sms_ok(),
	   {send,"8*1"}, sms_nok()
	  ]
	 },

	 "To rings : test 5 services. One more in CSV ; has to be ignored",
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},sms_nok(),
	   {send,"8*8*8*8"}|welcome(Phase)] ++
	  [
	   {send,?CODE_SONNERIES_LOGOS},
	   {expect,"Recherchez un service de sonneries/logos en tapant le No "
	    "correspondant:"
	    ".+:logo"
	    ".+:sonnerie."},
	   {send,"1" },
	   {expect,"Consultez les services offerts par les editeurs en tapant "
	    "le No correspondant:"
	    ".+:SMS Express."},
	   {send,"1"},
	   {expect,"Pour recevoir le top des fond d'ecran du moment, "
	    "envoie FOND au 61500 [(]0,35E[+] prix d'un SMS[)]"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos"
	    ".+:" ++ NextLink},
	   {send,"3"},
	   {expect,"Pour recevoir le top des logos couleurs envoie COUL au "
	    "61500 [(]0,35E[+] prix d'un SMS[)]"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos"
	    ".+:" ++ NextLink},
	   {send,"3"},
	   {expect,"Logos noir et blanc"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos"
	    ".+:" ++ NextLink},
	   {send,"3"},
	   {expect,"Logos Haute Definition"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos"
	    ".+:" ++ NextLink},
	   {send,"3"},
	   {expect,"Logos aleatoires"
	    ".+:envoi du SMS"
	    ".+:[+]d'infos."},
	   {send,"2"},
	   {expect,"Envie d'un logo ou d'un super fond d'ecran pour ton "
	    "mobile[?] ne cherche plus, ton bonheur est ici."},
	   {send,"8*1"}
	  ]
	 },

	 "Trying to send SMS of fifth service - SMSMO disabled",
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},sms_nok()       ]
	 },

	 "Trying to send SMS of fifth service - SMSMO enabled"] ++
	switch_smsmo_interface(enabled) ++
	[
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},sms_nok(),
	   {send,"8*1"},sms_ok()
	  ]
	 },

	 "Attempts to get back to main Accueil (without 00 link)",
	 {ussd2,
	  [
	   {send,?DIRECT_CODE},sms_ok(),
	   {send,"8*8*8*8*8*8*8*8*8"}
	  ]
	 }].

by_editor(Phase) ->
   [
    {title, "Navigation by editors"},
    "An editor with only one service -> navigation shortcut",
    {ussd2,
     [
      {send,?DIRECT_CODE}|welcome(Phase)] ++
     [
      {send,?CODE_EDITOR_BLOCK},editor_block_select(),

      %% First block

      {send,"1"},
      ba_c(),


      %% AOL has only one service : check if we go there rather than
      %% printing the list of all the services

      {send,"1"},
      {expect,"Checkmail: envoyez MAIL [(]espace[)] votre Pseudonyme "
       "[(]espace[)] votre mot de passe au 61265 [(]0,35E [+] prix d'un "
       "SMS[)]"
       ".+:envoi du SMS"
       ".+:[+]d'infos."},
      {send,"1"},
      {expect,"Pour acceder au service, veuillez preciser votre Pseudo "
       "[(]espace[)] votre mot de passe."},
      {send,"PSE PASS"}
     ]
    },

    "Try to send AOL SMS (with param) - SMSMO enabled",
    {ussd2,
     [
      {send,?DIRECT_CODE},sms_ok()
     ]
    },

    "Try to send AOL SMS (with param) - SMSMO disabled"] ++
    switch_smsmo_interface(disabled) ++
    [
     {ussd2,
      [
       {send,?DIRECT_CODE},sms_ok(),
       {send,"8*PSE PASS"},sms_nok(),
       {send,"8*8*8*8*5"}
      ]
     },

     "To S-Z block, an editor with several themes - SMSMO disabled",
     {ussd2,
      [
       {send,?DIRECT_CODE},bS_Z(),
       bS_Z(),
       {send,"3"},
       edM6(),
       {send,"8*8*8*8*3"}
      ]
     }
    ].

help(Phase) ->
   [
    {title,"Help"},
    {ussd2,
     [
      {send,?DIRECT_CODE}|welcome(Phase)] ++
     [
      {send,?CODE_HELP},
      {expect,"Selectionnez votre rubrique d'aide en tapant le No "
       "correspondant:"
       ".+mots clefs"
       ".+infos legales."},
      {send,"1"},
      {expect,"Pour obtenir les coordonnees d'un editeur, "
       "envoyez CONTACT au No court du service.+"
       "Pour ne plus recevoir de message en provenance d'un No court, "
       "envoyez STOP.+"},
      {send,"1"},
      {expect,".+L'envoi de ces mots cles est facture selon le palier "
       "surtaxe du No court auquel ils sont adresses[+] prix d'un SMS.."},
      {send,"8*2"},
      {expect,"Orange propose gratuitement et sans engagement un annuaire "
       "des services SMS a certains de ses clients. L'annuaire permet "
       "d'acceder a des services payants fournis par.+"},
      {send,"1"},
      {expect,".+ou par des tiers .services SMS.+Orange n'exerce "
       "aucun controle ou n'a aucune maitrise sur la nature ou la qualite "
       "du contenu des services SMS. proposes.+"},
      {send,"1"},
      {expect,".+Toute reclamation relative au service est a "
       "adresser a l'editeur concerne. Pour ce faire, le client enverra "
       "CONTACT par SMS au No court de cet editeur"}
     ]}
   ].

ansi(Phase) ->
    
    fill_db() ++

	test_util_of:set_parameter_for_test(roaming_ansi_codes,["22","11"]) ++
	[
	 {title, "Checking ANSI Access."},
	 "Set imsi=" ++ ?IMSI_ANSI ++ " (a provisioned french user)"]++
	test_util_of:init_test(?IMSI_ANSI) ++

	[{msaddr, {subscriber_number, private, ?IMSI_ANSI}}] ++
	[{vlr_number,"1111111111"}] ++

	test_util_of:close_session() ++

	["Try from an ANSI network",
	 {ussd2,
	  [ {send,?DIRECT_CODE},{expect,"puis 1"},
	    {send,"1"}] ++ welcome(Phase)
	 }
	].

%% System funs (rpc calls)

empty_db() ->
    [
     "Cleaning database",
     {erlang,
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mnesia,clear_table,[annuaire]]}
      ]
     }
    ].   
fill_db() ->
   [
    "Filling database",
    {erlang,
     [
      {net_adm, ping,[possum@localhost]},
      {rpc, call, [possum@localhost,annuaire,csv2mnesia,
            ["../../test/data/ok.csv"]]}
     ]}
   ].
switch_smsmo_interface(enabled) ->
    [
     "Enabling SMSMOs",
     {erlang,
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,
		    pcontrol,
		    enable_itfs,
		    [[io_sms_loop,possum@localhost]]]}
      ]
     },
     {pause, 8000}
    ];

switch_smsmo_interface(disabled) ->
    [
     "Disabling SMSMOs",
     {erlang,
      [       {net_adm, ping,[possum@localhost]},
	      {rpc, call, [possum@localhost,
			   pcontrol,
			   disable_itfs,
			   [[io_sms_loop,possum@localhost]]]}
	     ]
     },
     {pause, 8000}
    ].

%%%% Fun dealing with SMSMOs

%%% Starts a smsmo queue, defined as a client for smsloop_server
smsmo_start_client() ->
   proc_lib:start_link(?MODULE, smsmo_queue_init, [self()]).

%%% Sync with the queue
smsmo_stop_client(Pid) ->
   Pid ! smsmo_stop,
   receive
    ok -> ok;
    {error,Else} ->
        io:format("An error occured. "
              "If ptester simulator is running, close it"),
        exit(Else)
   end.


%%% Register the queue as a smsloop_client
smsmo_queue_init(Parent) ->
   proc_lib:init_ack(self()),
   pong = net_adm:ping(possum@localhost),    ptester:start_interface(loop),
   %% SMS-MOs received during both phases
   smsmo_queue_loop(Parent,?EXPECTEDSMSMOS).

%%% Main queue loop
smsmo_queue_loop(Parent,[{From,To,RegExp}=SMSMO | SMSMOs]) ->
    receive     
        {fake_incoming_mo,#sms_incoming{da      = To,
                                        deliver = #sms_deliver{dcs = DCS,
                                                               oa  = From,
                                                               ud  = UD}}} ->
            Text = gsmcharset:ud2iso(DCS, UD),
            case regexp:match(Text,RegExp) of
                {match,_,_} ->             io:format("SMS-MO ~p : ok~n",[SMSMO]),
                                           smsmo_queue_loop(Parent,SMSMOs);
                _ -> exit({smsmo_badmatch,Text,RegExp})
            end;
        
        {fake_incoming_mo,INC} ->         exit({smsmo_unexpected,INC,instead_of,SMSMO});
        
        smsmo_stop -> ptester:stop() 
%%            Parent ! {error,{smsmo_still_awaiting,[SMSMO|SMSMOs]}}
    
    end;

smsmo_queue_loop(Parent,[]) ->
   receive
    smsmo_stop -> Parent ! ok;
    {fake_incoming_mo,INC} ->
        Parent ! {error,{smsmo_unexpected,INC}}
   end.
  
