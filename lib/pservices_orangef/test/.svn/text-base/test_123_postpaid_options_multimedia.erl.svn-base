-module(test_123_postpaid_options_multimedia).
-export([run/0, online/0, pages/0, links/1, parent/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").
-define(Uid,multimedia_user).
-define(TEXT_PROMO, "\\-50% pendant 2 mois.*").
-define(OPTS_MULTI, [opt_mail,
 		     opt_orange_sport,
 		     opt_musique_collection,
  		     opt_musique_mix,
  		     opt_tv,
 		     opt_tv_max,
 		     opt_internet_max,
 		     opt_internet,
 		     opt_mail_MMS,
 		     opt_giga_mail,
 		     opt_orange_maps,
 		     opt_mes_donnees,
 		     opt_iphone_3g,
 		     opt_mail_blackberry,
 		     opt_lyon,
 		     opt_marseille,
 		     opt_paris,
 		     opt_bordeaux,
 		     opt_lens,
 		     opt_saint_etienne
		    ]).
-define(OPTS_MULTI_WITH_PROMO, [opt_mail,
				opt_orange_sport,
				opt_musique_collection,
				opt_musique_mix,
				opt_tv,
				opt_tv_max,
				opt_internet_max,
				opt_internet,
				opt_mail_MMS,
				opt_giga_mail,
				opt_orange_maps,
				opt_mail_blackberry,
				opt_lyon,
				opt_marseille,
				opt_paris,
				opt_bordeaux,
				opt_lens,
				opt_saint_etienne]).

pages()->
    [?postpaid_multimedia, ?postpaid_internet_mail, ?postpaid_internet_mail_suite, ?postpaid_musique_tv, ?postpaid_sport, ?postpaid_sport_suite, ?postpaid_gps].

parent(?postpaid_multimedia) ->
    test_123_postpaid_Homepage;
parent(_) ->
    ?MODULE.

links(?postpaid_multimedia)->
    [{?postpaid_internet_mail, static},
     {?postpaid_musique_tv, static},
     {?postpaid_sport, static},
     {?postpaid_gps, static}
    ];
links(?postpaid_internet_mail)->
    [{?postpaid_internet_max, static},
     {?postpaid_mail, static},
     {?postpaid_mail_mms, static},
     {?postpaid_internet, static},
     {?postpaid_internet_mail_suite, static}
    ]; 
links(?postpaid_internet_mail_suite)->
    [{?postpaid_giga_mail, static},
     {?postpaid_iphone_3g, static},
     {?postpaid_mail_blackberry, static},
     {?postpaid_mes_donnees, static}
    ];
links(?postpaid_musique_tv)->
    [{?postpaid_musique_collection, static},
     {?postpaid_musique_mix, static},
     {?postpaid_tv_max, static},
     {?postpaid_tv, static}
    ];
links(?postpaid_sport)->
    [{?postpaid_orange_sport, static},
     {?postpaid_paris, static},
     {?postpaid_marseille, static},
     {?postpaid_lyon, static},
     {?postpaid_sport_suite, static}
    ];
links(?postpaid_sport_suite)->
    [{?postpaid_lens, static},
     {?postpaid_saint_etienne, static},
     {?postpaid_bordeaux, static}
    ];
links(?postpaid_gps)->
    [{?postpaid_orange_map, static}
    ].

run() ->
    ok.

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test() ->
    test_postpaid("GP") ++
 	test_postpaid("PRO") ++

	test_util_of:close_session() ++
        ["Test reussi"] ++
	[].

test_postpaid(Type) ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType="0005",
			   bundleDescription="label forf",
			   bundleAdditionalInfo="I1",
			   credits=[#spider_credit{name="balance",unit="MMS",value="40"}]},
    BundleB=#spider_bundle{priorityType="B",
			   restitutionType="SOLDE",
			   bundleType="1",
			   bundleDescription="Solde",
			   exhaustedLabel="Solde",
			   credits=[#spider_credit{name="balance",unit="VALEU",value="2"}]},
    BundleC=#spider_bundle{priorityType="C",
			   restitutionType="SOLDE",
			   bundleType="0005",
			   bundleDescription="TITREC|C_LIB|",
			   credits=[#spider_credit{name="balance",unit="SMS",value="10"},
				    #spider_credit{name="rollOver",unit="SMS",value="5"}
				   ]},
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],

    profile_manager:create_default(?Uid,"postpaid")++
	profile_manager:set_bundles(?Uid,[BundleA,BundleB,BundleC])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	profile_manager:update_spider(?Uid,profile,{offerPOrSUid,Type})++
	profile_manager:init(?Uid)++
	[{title, "TEST "++ Type}]++

 	test_options_multimedia_menu(Type)++
 	test_options_multimedia_incomp_souhaitee(Type)++

      	[{title, "Test Options Multimedia sans options activees "++Type}] ++
    	test_opts_multi(?OPTS_MULTI, Type)++

      	[{title, "Test Options Multimedia - option incompatible - "++Type}] ++
	test_opts_multi_incomp([opt_orange_sport], Type) ++
	[].

test_options_multimedia_menu(Type)->
    [{title, "Test MENU OPTION MULTIMEDIA - Menu Option Internet/Mail - " ++ Type},
     {ussd2,
      [{send, test_util_of:access_code(parent(?postpaid_multimedia), ?postpaid_multimedia)},
       {expect, expect_menu(opts_multi)},
       {send,"1"},
       {expect, expect_menu(internet_mail_1)},
       {send,"5"},
       {expect, expect_menu(internet_mail_2)}
      ]}
    ]++

	[{title, "Test MENU OPTION MULTIMEDIA - Menu Option Musique/TV - " ++ Type},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, ?postpaid_musique_tv)},
	   {expect, expect_menu(tv_musique)}
	  ]}
	]++

	[{title, "Test MENU OPTION MULTIMEDIA - Menu Option Sport - " ++ Type},
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?postpaid_sport)},
           {expect, expect_menu(sport_1)},
	   {send, "5"},
	   {expect, expect_menu(sport_2)}
          ]}
        ]++

	[{title, "Test MENU OPTION MULTIMEDIA - Menu Option GPS - " ++ Type},
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?postpaid_gps)},
           {expect, expect_menu(gps)}
          ]}
        ]++
	[].

test_options_multimedia_incomp_souhaitee(Type)->
    profile_manager:set_asm_response(?Uid,?getImpact,#'ExceptionServiceOptionnelImpossible'{codeMessage="004"})++
	[{title, "Test Incompatibilite de l'option Mes donnees +30Go - " ++ Type},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, ?postpaid_mes_donnees)},
	   {expect, ".*est incompatible avec votre offre, vous ne pouvez pas y souscrire.*Decouvrez les autres options.*1:Autres options.*"},
	   {send, "1"},
	   {expect, expect_menu(internet_mail_1)}
	  ]}
	]++

	[{title, "Test Incompatibilite de l'option TV - " ++ Type},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, ?postpaid_tv)},
	   {expect, ".*est incompatible avec votre offre, vous ne pouvez pas y souscrire.*Decouvrez les autres options.*1:Autres options.*"},
	   {send, "1"},
	   {expect, expect_menu(tv_musique)}
	  ]}
	]++

	[{title, "Test Incompatibilite de l'option Girondins Mobile - " ++ Type},
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?postpaid_bordeaux)},
	   {expect, ".*est incompatible avec votre offre, vous ne pouvez pas y souscrire.*Decouvrez les autres options.*1:Autres options.*"},
	   {send, "1"},
	   {expect, expect_menu(sport_1)}
          ]}
        ]++

	[{title, "Test Incompatibilite de l'option Orange maps - " ++ Type},
         {ussd2,
          [{send, test_util_of:access_code(?MODULE, ?postpaid_orange_map)},
	   {expect, ".*est incompatible avec votre offre, vous ne pouvez pas y souscrire.*Decouvrez les autres options.*1:Autres options.*"},
	   {send, "1"},
	   {expect, "Options GPS.*"
            ++?TEXT_PROMO++
            "1:Orange maps.*"}
          ]}
        ]++
	profile_manager:set_asm_response(?Uid,?getImpact,{ok, []})++
	[].

test_opts_multi([], Type) ->
    [];
test_opts_multi([Opt|T], Type) ->
    ["TEST "++option_label(Opt)++" - "++Type,
     {ussd2,
      [{send, test_util_of:access_code(?MODULE, option_link(Opt))++"#"},
       {expect, expect_text(description, Opt)},
       {send, "7"}]++

      test_men_leg(Opt)++ %% TEST MENTIONS LEGALES

      [{send, "1"},
       {expect, expect_text(souscription, Opt)},
       {send, "1"},
       {expect, expect_text(validation, Opt)}
      ]}
    ]++
	test_opts_multi(T, Type).

test_opts_multi_incomp([], Type) ->
    [];
test_opts_multi_incomp([Opt|T], Type) ->
    profile_manager:set_asm_impact_options(?Uid, [#asm_option{code_so=so_code_opt_incomp(Opt)}]) ++
    ["TEST "++option_label(Opt)++"- Option incompatible  - "++Type,
     {ussd2,
      [{send, test_util_of:access_code(?MODULE, option_link(Opt))++"#"},
       {expect, expect_text(incompatible, Opt)},
       {send, "1"},
       {expect, expect_text(souscription, Opt)}
      ]}
    ]++
	test_util_of:close_session()++
	test_opts_multi(T, Type).

expect_menu(opts_multi) ->
    ".*1:Options Internet / Mail.*"
        "2:Options Musique / TV.*"
        "3:Options Sport.*"
        "4:Option GPS*";
expect_menu(internet_mail_1) ->
    "Options Internet/Mail.*"
        "1:Option Internet max.*"
        "2:Option Mail.*"
        "3:Option Mail MMS.*"
        "4:Option Internet.*"
        "5:Suite.*";
expect_menu(internet_mail_2) ->
    "Options Internet/Mail.*"
        "1:Option Giga Mail.*"
        "2:Option Iphone 3G.*"
        "3:Mail Blackberry.*"
        "4:Mes donnees \\+30Go.*";
expect_menu(tv_musique) ->
    "Options TV/Musique.*"
	++?TEXT_PROMO++
	"1:Musique collection.*"
	"2:Option Musique mix.*"
	"3:Option TV max.*"
	"4:Option TV.*";
expect_menu(sport_1) ->
    "Options Sport.*"
	++?TEXT_PROMO++
	"1:Option Sport.*"
	"2:Option PSG Mobile.*"
	"3:Option OM Mobile.*"
	"4:Option OL Mobile.*"
	"5:Suite.*";
expect_menu(sport_2) ->
    "Options Sport.*"
            ++?TEXT_PROMO++
	"1:Option RCL Mobile.*"
	"2:Option ASSE Mobile.*"
	"3:Opt Girondins Mobile.*";
expect_menu(gps) ->
    "Options GPS.*"
            ++?TEXT_PROMO++
            "1:Orange maps.*".

test_men_leg(opt_orange_sport)->
    [
     {expect, "Option Sport a souscrire et valable pour des usages en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur reseaux et depuis 1 terminal compatibles. Option incompatible avec l'option TV max et l'avantage OM. Navigation illimitee sur le.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "portail Orange World. Consultation illimitee sur le portail Orange World et/ou l'application Orange correspondante de 8 matchs de Ligue 1.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "en direct par journee de championnat, de tous les evenements sportifs en direct proposes sur l'espace sport \\(hors directs TV\\),.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "des chaines TV Orange sport et Orange sport info et des videos des rubriques actualite, sport et cinema \\(hors Orange cinema series\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines susceptible d'evolution. Ne sont pas compris les contenus et services payants. Pour 1 qualite de service optimale.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr. Usages en France metropolitaine..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Services accessibles sur reseaux et depuis un terminal compatibles. Matchs de Ligue 1 en direct et chaines TV accessibles sur terminaux iPhone.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sous reserve de telechargement aux tarifs en vigueur de l'application correspondante. Autres evenements sportifs en direct sous reserve.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de disponibilite de l'application correspondante.Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_men_leg(opt_tv) ->
    [
     {expect, "Option TV a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\). Navigation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange World et/ou l'application orange TV player de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "plus de 20 chaines de TV et de toutes les videos proposees sur le portail Orange World \\(hors rubrique mes communautes et Orange cinema.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "series\\). Liste des chaines TV susceptible d'evolution.Ne sont pas compris dans l'option, les evenements sportifs en direct, les.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compatibles. Chaines TV accessibles sur terminaux iPhone sous reserve de telechargement aux tarifs en vigueur de l'application correspondante.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.Les 2 premiers mois a.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "\\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_tv_max) ->
    [
     {expect, "Option TV max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Internet everywhere\\). Option incompatible avec l'option Orange foot. Navigation illimitee sur le portail Orange World. Consultation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "illimitee sur le portail Orange World et/ou l'application Orange TV player de plus de 60 chaines TV, sur le portail Orange World.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et/ou l'application Ligue 1 de 8 matchs de Ligue 1 en direct par journee de championnat et de toutes les videos proposees sur le.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "portail Orange World \\(hors rubrique mes communautes et Orange cinema series\\). Liste des chaines TV susceptible d'evolution.Ne sont pas.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compris dans l'option, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "reseaux et depuis un terminal compatibles. Chaines TV et Matchs en direct accessibles sur terminaux iPhone sous reserve de telechargement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "aux tarifs en vigueur des applications correspondantes. Voir details de l'option, conditions specifiques et liste des terminaux.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compatibles sur www.orange.fr.Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_internet_max) ->
    [
     {expect, "Option Internet max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "offres Internet everywhere\\). Navigation illimitee sur le portail Orange World, Gallery et internet. Consultation illimitee des.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "videos des rubriques actualite, cinema \\(hors Orange cinema series\\), sport \\(hors evenements sportifs en direct\\) et mes communautes sur.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "le portail Orange World.Ne sont pas compris dans l'option, les usages mail \\(smtp, pop, imap\\), les usages modem, les contenus et services.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une qualite de service optimale sur son reseau,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option, conditions specifiques et liste des.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "terminaux compatibles sur www.orange.fr.Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_internet) ->
    [
     {expect, "Option Internet a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Navigation illimitee sur le portail Orange World. Consultation illimitee des videos des rubriques actualite, cinema \\(hors Orange cinema.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "series\\), sport \\(hors evenements sportifs en direct\\) sur le portail Orange World. De 20h a 8h, navigation illimitee sur Gallery,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "internet et consultation illimitee des videos de la rubrique mes communautes.Ne sont pas compris dans l'option, les usages mail \\(smtp,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pop, imap\\), modem, les contenus et services payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "conditions specifiques et liste des terminaux compatibles sur www.orange.fr. Les 2 premiers mois a \\-50% pour toute premiere souscription.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_mail) ->
    [
     {expect,"Option Mail a souscrire et valable en France metropolitaine pour tt client mobile Orange \\(hors offres Internet everywhere\\).Option incompatible.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"avec l'option Mail pour BlackBerryTM. Reception et envoi illimite de mails et de PJ a partir du client e-mail du mobile. Service accessible.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"depuis tt compte mail utilisant les protocoles IMAP,POP et SMTP \\(hors services payants\\) ou du service Nokia Messaging avec Orange.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"Ne sont pas compris dans l'option,les services de messagerie Microsoft ExchangeTM et les applications de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"messagerie utilisant le protocole de navigation http.Pour 1 qualite de service optimale sur son reseau,Orange pourra limiter le debit au dela.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"d'1 usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"compatibles.Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.Les 2 premiers mois a \\-50%.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect,"pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_mail_MMS) ->
    [
     {expect, "Le service mail MMS est disponible en France metropolitaine sur reseaux compatibles et depuis un terminal compatible MMS..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service reserve aux clients forfait mobile Orange \\(hors forfaits Orange pour iPhone et Ten\\) disposant d'une messagerie Internet compatible..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service limite au mail Orange mobile et a deux autres messageries Internet en France metropolitaine maximum. Tarif mensuel valable.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour 40 MMS par mois. Au dela la reception de MMS sera facturee 0.30E/MMS. Tarification hors cout de connexion Orange World.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "ou Internet permettant l'inscription et le parametrage du service. La reception de MMS a l'etranger sera facture au tarif en vigueur..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a -50% pour toute premiere souscription entre du 10/06/2010 au 18/08/2010.*1:Souscrire.*"}
    ];

test_men_leg(opt_giga_mail) ->
    [
     {expect, "L'envoi de mails d'une taille allant jusqu'a 20 Mo et la creation de filtres supplementaires sont disponibles lorsque vous utilisez votre.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "messagerie sur orange.fr. illimite : sans utilisation ABUSIVE du service.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a -50% pour toute souscription entre du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_men_leg(opt_orange_maps) ->
    [
     {expect, "Option valable en France metropolitaine et a souscrire pour tout client forfait mobile Orange.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "valables sur reseaux et depuis un terminal compatible \\(liste des mobiles compatibles sur gps.orange.fr\\). Avec le service de navigation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange maps: Itineraires illimites avec data inclus \\(telechargements en data GPRS, 3G ou 3G\\+ des itineraires, des requetes de mise a jour.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de l'information trafic ou des trajets inclus dans l'option Orange maps dans la limite de 10 Mo/mois, en France metropolitaine\\),.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "info trafic \\(trajets optimises sur Paris/Ile-de-France, evenements sur toute la France, accidents, fermetures, travaux, bouchons, etc\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "opere par Mediamobile/ V-Trafic, guidage routier et pieton et cartographie de 26 pays d'Europe mise a jour automatiquement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "\\(Allemagne, Andorre, Autriche, Belgique, Danemark, Espagne, Estonie, Finlande, France, Gibraltar, Grece, Irlande, Italie, Liechtenstein,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Luxembourg, Monaco, Norvege, Pays-Bas, Portugal, Republique Tcheque, Royaume-Uni, San-Marin, Slovaquie, Suede, Suisse, Vatican\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_mes_donnees) ->
    [
     {expect, "Option mes donnees \\+30 Go a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors Fnac Mobile\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Augmentation de l'espace de stockage sur le service mes donnees de 30 Go supplementaires, permettant aux souscripteurs de passer de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "10 a 40 Go de stockage pour les clients mobile ou de 20 a 50 Go pour les clients mobiles ayant active l'option gratuite mes services unifies..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service accessible depuis tout compte Orange disposant d'une facture. Sont factures en dehors de l'option les couts de connexions.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "lies a l'acces au service depuis son terminal. Cette option peut etre interrompue a tout moment par l'utilisateur..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Usages en France metropolitaine. Service accessible sur reseaux et depuis un terminal compatible. Voir details de l'option,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "conditions specifiques et liste des terminaux compatibles sur www.orange.fr..*1:Souscrire"}
    ];

test_men_leg(opt_musique_collection) ->
    [
     {expect, "Option Musique collection a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Option incompatible avec l'option Musique mix.Telechargement de 25 titres musicaux par mois parmi le catalogue de titres eligible.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "a l'option \\(hors rubriques classique et jazz\\). Nombre de titres decomptes en mois calendaire. Titres supplementaires et hors catalogue.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "proposes a l'achat a 0.99E/titre. Titres telechargeables depuis mobile et ordinateur \\(PC/Mac\\). Titres telecharges sur le mobile.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "non transferables. Navigation illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange World des videos.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "des rubriques musique, actualite, sport \\(hors evenements sportifs en direct\\) et cinema \\(hors Orange cinema series\\). Consultation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "illimitee des chaines TV musicales \\(NRJ Hit, MCM top, MCM pop, M6 Music, M6 Black, M6 Music club, Trace TV, Trace Tropical\\). Ecoute.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "illimitee des radios sur le portail Orange World. Liste des chaines TV musicales et radios susceptible d'evolution. Ne sont pas compris.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "dans l'option, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "au dela d'un usage de 500Mo/mois jusqu'a la date de facturation. Usages en France metropolitaine. Services accessibles sur reseaux et.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "depuis un terminal compatibles. Telechargements et ecoute des radios non accessibles sur terminaux iPhone.Titres telecharges depuis.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "un ordinateur lisibles et transferables sur terminaux iPhone. Voir details de l'option, conditions specifiques et liste des terminaux.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compatibles sur www.orange.fr.Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_musique_mix) ->
    [
     {expect, "Option Musique mix a souscrire et valable en France metropolitaine pour tout client mobile Orange\\(hors offres Orange incluant le telechargement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "d'au moins 10 titres et offres Internet everywhere\\). Option incompatible avec l'option Musique collection.Telechargement.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de 10 titres musicaux par mois parmi le catalogue de titres eligible a l'option \\(hors rubriques classique et jazz\\). Nombre de titres.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "decomptes en mois calendaire. Titres supplementaires et hors catalogue proposes a l'achat a 0.99E/titre. Titres telechargeables depuis.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "mobile et ordinateur \\(PC/Mac\\). Titres telecharges sur le mobile non transferables Navigation illimitee sur le portail Orange World.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Consultation illimitee sur le portail Orange World des videos des rubriques musique, actualite, sport \\(hors evenements sportifs en.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "direct\\) et cinema \\(hors Orange cinema series\\). Consultation illimitee des chaines TV musicales \\(NRJ Hit, MCM top, MCM pop, M6 Music,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "M6 Black, M6 Music club, Trace TV, Trace Tropical\\). Ecoute illimitee des radios sur le portail Orange World. Liste des chaines TV.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "musicales et radios susceptible d'evolution. Ne sont pas compris dans l'option, les contenus et services payants. Pour une qualite de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usage.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Telechargements et ecoute des radios.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "non accessibles sur terminaux iPhone. Titres telecharges depuis un ordinateur lisibles et transferables sur terminaux iPhone. Voir.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ];

test_men_leg(opt_iphone_3g) ->

    [
     {expect, "Option a souscrire et valable en France metropolitaine pour tout client mobile Orange disposant d'un forfait mobile Orange \\(hors.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Origami star, first, offres Internet everywhere\\). Navigation illimitee sur internet, le portail Orange.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "World et Gallery. Consultation illimitee des videos des rubriques actualite, cinema \\(hors Orange cinema series\\) et sport \\(hors matchs.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "en direct\\) et mes communautes sur le portail Orange World. Reception et envoi illimite de mails et de pieces jointes a partir du.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "client e-mail du mobile \\(smtp, pop et imap\\). Service Messagerie Vocale Visuelle \\(avec mobiles compatibles\\). Le client peut toutefois.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "continuer a appeler le 888 pour consulter la messagerie vocale traditionnelle. Connexion illimitee aux hotspots Wifi Access en France.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "metropolitaine \\(liste sur orange-wifi.com\\), hors forfaits bloques.Ne sont pas compris dans l'option, les usages modem, les contenus et.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "services payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une qualite de service optimale sur.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "son reseau, Orange pourra limiter le debit au dela d'un usage de 1 Go/mois jusqu'a la date de facturation.Usages en France metropolitaine.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option, conditions specifiques et liste des.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "terminaux compatibles sur www.orange.fr..*1:Souscrire"}
    ];

test_men_leg(opt_mail_blackberry) ->

    [
     {expect, "Option Mail BlackBerry a souscrire et valable en France metropolitaine dans les zones de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour le service  BlackBerry pour tout client mobile Orange. Option incompatible avec l'option Mail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Reception et envoi illimite de mails et de pieces jointes a partir du service BlackBerry. Service accessible depuis tout compte mail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "utilisant les protocoles IMAP, POP et SMTP .hors voila.fr.. Conversation avec d'autres utilisateurs de terminaux BlackBerry dans un format de.*2:Souscrire"},
     {send, "1"},
     {expect, "messagerie instantanee avec le service BlackBerry Messenger .ou BlackBerry PIN.*disponible pour les seuls terminaux BlackBerry sous Java.*2:Souscrire"},
     {send, "1"},
     {expect, "Pour 1 qualite de service optimale sur son reseau.*2:Souscrire"},
     {send, "111"},
     {expect, "Les 2 premiers mois a -50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_men_leg(Opt)
  when Opt==opt_lyon;Opt==opt_marseille;Opt==opt_paris;
       Opt==opt_bordeaux;Opt==opt_lens;Opt==opt_saint_etienne ->
    [
     {expect, "Options PSG mobile, OM mobile, OL mobile, ASSE mobile, RCL mobile, Girondins mobile a souscrire et valables en France metropolitaine.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour tout client mobile Orange \\(hors Fnac mobile by Orange et offres Internet everywhere\\). Option incompatible.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, ".*avec les autres options clubs mobile.Reception des sms info du club choisi, des alertes sms buts et des resumes de match du club en.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ligue 1 en video \\(sous reserve de disposer d'un mobile compatible video\\). De 10 a 30 SMS metropolitains \\(hors SMS surtaxes\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "offerts chaque mois calendaire \\(selon les resultats du club au cours du mois precedent\\). Activation des SMS possible pendant 15 jours.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "a compter de la date de reception du SMS de confirmation. SMS valables 30 jours a compter de l'activation et non cumulables d'un mois.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur l'autre. Navigation et consultation illimitees des services et videos du portail du club choisi.Ne sont pas compris dans l'option,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "la navigation et la consultation de videos sur le portail Orange World. les contenus et services payants.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compatibles. Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.Les 2 premiers mois.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010..*1:Souscrire"}
    ].

option_label(Opt) ->
    case Opt of
	opt_mail ->
	    "Option Mail";
	opt_orange_sport ->
            "Option Sport";
	opt_musique_collection ->
            "Musique Collection";
	opt_musique_mix ->
            "Option Musique Mix";
	opt_tv ->
            "Option TV";
	opt_tv_max ->
            "Option TV max";
	opt_internet_max ->
            "Option Internet max";
	opt_internet ->
            "Option Internet";
	opt_mail_MMS ->
            "Option Mail MMS";
	opt_giga_mail ->
            "Option Giga mail";
	opt_orange_maps ->
            "Orange maps";
	opt_mes_donnees ->
            "Mes donnees \\+30Go";
	opt_iphone_3g ->
            "Option iPhone 3G";
	opt_mail_blackberry ->
            "Mail BlackBerry";
        opt_lyon ->
            "Option OL Mobile";
        opt_marseille ->
            "Option OM Mobile";
        opt_paris ->
            "Option PSG Mobile";
        opt_bordeaux ->
            "Opt Girondins Mobile";
        opt_lens ->
            "Option RCL Mobile";
        opt_saint_etienne ->
            "Option ASSE Mobile"
    end.

option_link(Opt) ->
    case Opt of
	opt_mail ->
	    ?postpaid_mail;
	opt_orange_sport ->
            ?postpaid_orange_sport;
	opt_musique_collection ->
            ?postpaid_musique_collection;
	opt_musique_mix ->
            ?postpaid_musique_mix;
	opt_tv ->
            ?postpaid_tv;
	opt_tv_max ->
            ?postpaid_tv_max;
	opt_internet_max ->
            ?postpaid_internet_max;
	opt_internet ->
            ?postpaid_internet;
	opt_mail_MMS ->
            ?postpaid_mail_mms;
	opt_giga_mail ->
            ?postpaid_giga_mail;
	opt_orange_maps ->
            ?postpaid_orange_map;
	opt_mes_donnees ->
            ?postpaid_mes_donnees;
	opt_iphone_3g ->
            ?postpaid_iphone_3g;
	opt_mail_blackberry ->
            ?postpaid_mail_blackberry;
        opt_lyon ->
            ?postpaid_lyon;
        opt_marseille ->
            ?postpaid_marseille;
        opt_paris ->
            ?postpaid_paris;
        opt_bordeaux ->
            ?postpaid_bordeaux;
        opt_lens ->
            ?postpaid_lens;
        opt_saint_etienne ->
            ?postpaid_saint_etienne
    end.

expect_text(description, Opt) ->
    option_label(Opt)++".*"++
	case Opt of
	    opt_mail ->
		"Emission et reception de mails, avec pieces jointes, en illimite 24h/24, 7J/7 pour 9E/mois";
	    opt_orange_sport ->
		"Suivez les grands evenements sportifs en illimite 24h/24 7j/7 pr 6E/mois";
	    opt_musique_collection ->
		"Telechargez 25 titres sur mobile&PC,transferables a volonte & surfez sur Orange World pour 12E/mois";
	    opt_musique_mix ->
		"Telechargez 10 titres sur mobile&PC,transferables a volonte & surfez sur Orange World pour 6E/mois";
	    opt_tv ->
		"Regardez \\+de 20 chaines TV et 3.500 videos et surfez sur Orange World en illimite pour 6E/mois";
	    opt_tv_max ->
		"Regardez \\+de 60 chaines TV et 3.500 videos et surfez sur Orange World en illimite pour 9E/mois";
	    opt_internet_max ->
		"Surfez en illimite sur internet, Orange World et Gallery pour 12E/mois";
	    opt_internet ->
		"Surfez en illimite sur internet de 20h a 8h et sur Orange World 24h/24 pour 6E/mois";
	    opt_mail_MMS ->
		"Receptionnez vos mails par MMS pour 4E/mois";
	    opt_giga_mail ->
		"Stockez en illimite sur votre boite aux lettres Orange et envoyez des mails jsq 20 Mo pour 2E/mois";
	    opt_orange_maps ->
		"Faites-vous guider par votre mobile grace a ce service complet de navigation embarquee pour 5E/mois";
	    opt_mes_donnees ->
		"30Go pour stocker, partager, acceder a encore \\+ de photos,videos,musiques,documents pour 5E/mois";
	    opt_iphone_3g ->
		"internet, mails, Messagerie Vocale Visuelle, Wi-Fi en illim. pour profiter au mieux de votre Iphone";
	    opt_mail_blackberry ->
		"envoyez et recevez vos e.mails, avec PJ, en temps reel et en illimite sur votre BlackBerry";
	    opt_lyon ->
		"Suivez l'actu de l'OL:SMS infos,alertes buts &resumes des matchs de votre club en Ligue 1 en video";
	    opt_marseille ->
		"Suivez l'actu de l'OM:SMS infos,alertes buts &resumes des matchs de votre club en Ligue 1 en video";
	    opt_paris ->
		"Suivez l'actu du PSG:SMS infos,alertes buts & resumes des matchs de votre club en Ligue 1 en video";
	    opt_bordeaux ->
		"Suivez l'actu des Girondins:SMS infos,alertes buts&resumes des matchs du club en Ligue 1 en video";
	    opt_lens ->
		"Suivez l'actu du RCL:SMS infos,alertes buts &resumes des matchs de votre club en Ligue 1 en video";
	    opt_saint_etienne ->
		"Suivez l'actu de l'ASSE:SMS infos,alertes buts&resumes des matchs du club en Ligue 1 en video"
	end ++
	".*" ++
	case lists:member(Opt, ?OPTS_MULTI_WITH_PROMO) of
	    true ->
		?TEXT_PROMO;
	    _ ->
		""
	end++
	"1:Souscrire.*7:Conditions";

expect_text(souscription, Opt) ->
    "Souscription.*"++
	case Opt of
	    opt_mail ->
		"Vous allez souscrire a l'option mail. Vous serez facture de 9E/mois.";
	    opt_orange_sport ->
		"Vous allez souscrire a l'option sport. Vous serez facture de 6E/mois";
	    opt_musique_collection ->
		"Vous allez souscrire a musique collection. Vous serez facture de 12E/mois.";
	    opt_musique_mix ->
		"Vous allez souscrire a musique mix. Vous serez facture de 6E/mois.";
	    opt_tv ->
		"Vous allez souscrire a l'option TV. Vous serez facture de 6E/mois.";
	    opt_tv_max ->
		"Vous allez souscrire a l'option TV Max. Vous serez facture de 9E/mois.";
	    opt_internet_max ->
		"Vous allez souscrire a l'option Internet max.Vous serez facture de 12E/mois.";
	    opt_internet ->
		"Vous allez souscrire a l'option Internet. Vous serez facture de 6E/mois.";
	    opt_mail_MMS ->
		"Vous allez souscrire a l'option mail MMS. Vous serez facture de 4E/mois.";
	    opt_giga_mail ->
		"Vous allez souscrire a l'option Giga mail. Vous serez facture de 2E/mois.";
	    opt_orange_maps ->
		"Vous allez souscrire a l'option Orange maps.Vous serez facture de 5E/mois.";
	    opt_mes_donnees ->
		"Vous allez souscrire a l'option Mes donnees \\+30Go pour 5E.";
	    opt_iphone_3g ->
		"Vous allez souscrire a l'option pour Iphone 3G pour 25E";
	    opt_mail_blackberry ->
		"Vous allez souscrire a l'option Mail Blackberry pour 9E";
	    opt_lyon ->
		"Vous allez souscrire a l'option OL mobile. Vous serez facture de 5E/mois.";
	    opt_marseille ->
		"Vous allez souscrire a l'option OM mobile. Vous serez facture de 5E/mois.";
	    opt_paris ->
		"Vous allez souscrire a l'option PSG mobile. Vous serez facture de 5E/mois.";
	    opt_bordeaux ->
		"Vous allez souscrire a l'opt Girondins mobile. Vous serez facture de 5E/mois.";
	    opt_lens ->
		"Vous allez souscrire a l'option RCL mobile. Vous serez facture de 5E/mois.";
	    opt_saint_etienne ->
		"Vous allez souscrire a l'option ASSE mobile. Vous serez facture de 5E/mois."
	end++
	".*1:Valider"
	".*8:Precedent"
	".*9:Accueil";

expect_text(validation, Opt) ->
    "Validation.*Souscription enregistree."++
	case Opt of
	    opt_mail ->
		" Les 2 premiers mois seront a 4,5E, au-dela vous serez facture 9E. ";
	    opt_orange_sport ->
		" Les 2 premiers mois seront a 3E, au-dela vous serez facture 6E. ";
	    opt_musique_collection ->
		" Les 2 premiers mois seront a 6E, au dela vous serez facture de 12E/mois.";
	    opt_musique_mix ->
		" Les 2 premiers mois seront a 3E, au dela vous serez facture de 6E/mois.";
	    opt_tv ->
		" Les 2 premiers mois seront a 3E, au dela vous serez facture de 6E/mois.";
	    opt_tv_max ->
		" Les 2 premiers mois seront a 4,5E,au dela vous serez facture de 9E/mois.";
	    opt_internet_max ->
		" Les 2 premiers mois seront a 6E,au dela vous serez facture de 12E/mois.";
	    opt_internet ->
		" Les 2 premiers mois seront a 3E,au dela vous serez facture de 6E/mois.";
	    opt_mail_MMS ->
		" Les 2 premiers mois seront a 2E,au dela vous serez facture de 4E/mois.";
	    opt_giga_mail ->
		" Les 2 premiers mois seront a 1E,au dela vous serez facture de 2E/mois.";
	    opt_orange_maps ->
		"Les 2 premiers mois seront a 2,5E, au dela vous serez facture de 5E/mois.";
	    opt_mes_donnees ->
		" Vous serez facture 5E/mois. ";
	    opt_iphone_3g ->
		" Vous serez facture 25E/mois. ";
	    opt_mail_blackberry ->
		" Les 2 premiers mois seront a 4,5E, au-dela vous serez facture 9E. ";
	    opt_lyon ->
		" Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_marseille ->
		" Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_paris ->
		" Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_bordeaux ->
		" Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_lens ->
		" Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_saint_etienne ->
		" Les 2 premiers mois seront a 2,5E, au dela a 5E/mois."
	end ++
	"Vous serez averti de son activation par SMS."
	".*8:Precedent"
	".*9:Accueil";

expect_text(incompatible, Opt) ->
    option_label(Opt)++".*Attention, votre option "++
	case Opt of
	    opt_orange_sport ->
		"Option Totale TV";
	    _ ->
		""
	end ++" sera resiliee"
	".*1:Souscrire".

so_code_opt_incomp(Opt) ->
    case Opt of
	opt_orange_sport ->
	    "CTD03";
	_  ->
	    ""
    end.
