-module(test_123_cmo_options_multimedia).

-export([online/0,
	 pages/0,
         parent/1,
         links/1]).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/recharge_cb_cmo_new.hrl").

-define(Uid,cmo_multimedia_user).
-define(Opt_XMedia, [opt_tv,
		     opt_tv_max,
		     opt_internet,
		     opt_internet_max,
		     opt_orange_maps,
		     opt_mes_donnees,
		     opt_mail,
		     opt_orange_sport,
		     opt_lyon,
		     opt_marseille,
		     opt_paris,
		     opt_bordeaux,
		     opt_lens,
		     opt_saint_etienne,
		     opt_musique_mix,
		     opt_musique_collection
		    ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?multimedia_page, ?multimedia_page_suite1, ?multimedia_page_suite2, ?multimedia_page_suite3].

parent(?multimedia_page) ->
    test_123_cmo_Homepage;
parent(_) ->
    ?MODULE.

links(?multimedia_page) ->
    [{opt_internet,     static},
     {opt_musique_mix,  static},
     {opt_tv,           static},
     {opt_orange_sport,  static},
     {?multimedia_page_suite1, static}];

links(?multimedia_page_suite1) ->
    [{opt_internet_max, static},
     {opt_orange_maps,  static},
     {opt_mail,         static},
     {opt_musique_collection, static},
     {?multimedia_page_suite2, static}];

links(?multimedia_page_suite2) ->
    [{opt_tv_max,       static},
     {opt_paris,        static},
     {opt_marseille,    static},
     {opt_lyon,         static},
     {?multimedia_page_suite3, static}];

links(?multimedia_page_suite3) ->
    [{opt_lens,         static},
     {opt_saint_etienne,static},
     {opt_bordeaux,     static},
     {opt_mes_donnees,  static}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop(),
    ok.

test()->
%    test_util_of:init_day_hour_range() ++
	profile_manager:create_default(?Uid,"cmo")++
	profile_manager:init(?Uid)++

     	test_menu_multimedia()++
	test_options_multimedia([?ppola,
    	  			 ?m6_cmo_fb_1h,
    	  			 ?DCLNUM_CMO_SL_ZAP_1h30_ILL,
    	  			 ?cmo_smart_40min,
    	  			 ?cmo_smart_1h,
    	  			 ?cmo_smart_1h30,
  	  			 ?cmo_smart_2h
				 ]) ++

	[].
test_menu_multimedia()->
	[{title, " TEST MENU MULTIMEDIA "},
         {ussd2,
          [ {send,test_util_of:access_code(parent(?multimedia_page), ?multimedia_page,[?suivi_conso_plus])},
            {expect, "Options multimedia.*"
	     "1:Option Internet.*"
	     "2:Option Musique mix.*"
	     "3:Option TV.*"
	     "4:Option Sport.*"
	     "5:Suite.*"
	     "8:Precedent.*"
	     "9:Accueil.*"},
            {send, "5"},
            {expect, "Options multimedia.*"
	     "1:Option Internet max.*"
	     "2:Option Orange Maps.*"
	     "3:Option Mail.*"
	     "4:Musique collection.*"
	     "5:Suite.*"
	     "8:Precedent.*"
	     "9:Accueil.*"},
            {send, "5"},
            {expect, "Options multimedia.*"
	     "1:Option TV max.*"
	     "2:Option PSG Mobile.*"
	     "3:Option OM Mobile.*"
	     "4:Option OL Mobile.*"
	     "5:Suite.*"
	     "8:Precedent.*"
	     "9:Accueil.*"},
            {send, "5"},
            {expect, "Options multimedia.*"
	     "1:Option RCL Mobile.*"
	     "2:Option ASSE Mobile.*"
	     "3:Opt Girondins Mobile.*"
	     "4:Mes donnees \\+30Go.*"
	     "8:Precedent.*"
	     "9:Accueil.*"}]}
        ]++
        close_session()++
	[].

test_options_multimedia([]) -> ["Test reussi"];
test_options_multimedia([DCL|T]) ->
    profile_manager:set_dcl(?Uid,DCL)++

	[{title, "TEST OPTIONS MULTIMEDIA - DCL =" ++ integer_to_list(DCL)}] ++
  	subscribe_Opt_XMedia(?Opt_XMedia)++
   	subscribe_XMedia_incomp() ++

	test_options_multimedia(T) ++
	[].

subscribe_Opt_XMedia([]) -> [];
subscribe_Opt_XMedia([Media |T]) ->
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
	[{title, "TEST SUBSCRIPTION SUCCESSFUL "++atom_to_list(Media)}]++
	[
	 {ussd2,
	  [ {send, test_util_of:access_code(?MODULE, Media)},
	    {expect, expect_text(description, Media)},
	    {send, "1"},
	    {expect, expect_text(souscription, Media)},
	    {send, "1"},
	    {expect, expect_text(validation_1, Media)},
        {expect,".*"},
	    {send, "1"},
            {expect, expect_text(validation_2, Media)}
	   ]}
	]++
	close_session()++

	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
	[{title, "TEST LEGAL MENTION "++atom_to_list(Media)},
	 {ussd2,
	  
	  [{send, test_util_of:access_code(?MODULE, Media) ++ "*7#"}]++ %% Link to Conditions
	  test_mention_leg(Media) %% Test Mentions legales

	 }
	]++
	close_session()++

	subscribe_Opt_XMedia(T)++
	[].

test_mention_leg(opt_tv) ->
    [
     {expect, "Option TV a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\).Navigation.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange World et/ou l'application orange TV player.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de plus de 20 chaines de TV et de toutes les videos proposees sur le portail Orange World \\(hors rubrique mes communautes et.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange cinema series\\). Liste des chaines TV susceptible d'evolution.Ne sont pas compris dans l'option, les evenements sportifs en.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "direct, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit au\\-dela.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "un terminal compatibles. Chaines TV accessibles sur terminaux iPhone sous reserve de telechargement aux tarifs en vigueur de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "l'application correspondante. Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_tv_max) ->
    [
     {expect, "Option TV max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "offres Internet everywhere\\). Option incompatible avec l'option Orange foot. Navigation illimitee sur le portail Orange World.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Consultation illimitee sur le portail Orange World et/ou l'application Orange TV player de \\+ de 60 chaines TV, sur le portail Orange.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "World et/ou l'application Ligue 1 de 8 matchs de Ligue 1 en direct par journee de championnat et de toutes les videos proposees.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur le portail Orange World \\(hors rubrique mes communautes et Orange cinema series\\). Liste des chaines TV susceptible d'evolution..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ne sont pas compris dans l'option, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "accessibles sur reseaux et depuis un terminal compatibles. Chaines TV et Matchs en direct accessibles sur terminaux iPhone sous.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "reserve de telechargement aux tarifs en vigueur des applications correspondantes. Voir details de l'option, conditions specifiques.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et liste des terminaux compatibles sur www.orange.fr. Les 2 premiers mois a \\-50% pour toute premiere.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_internet) ->
    [
     {expect, "Option Internet a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Navigation illimitee sur le portail Orange World.Consultation illimitee des videos des rubriques actualite,cinema\\(hors Orange cinema.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "series\\), sport \\(hors evenements sportifs en direct\\) sur le portail Orange World. De 20h a 8h, navigation illimitee sur Gallery,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "internet et consultation illimitee des videos de la rubrique mes communautes.Ne sont pas compris dans l'option,les usages mail \\(smtp,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pop, imap\\), modem, les contenus et services payants.Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_internet_max) ->
    [
     {expect, "Option Internet max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "offres Internet everywhere\\). Navigation illimitee sur le portail Orange World, Gallery et internet. Consultation illimitee.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "des videos des rubriques actualite, cinema \\(hors Orange cinema series\\), sport \\(hors evenements sportifs en direct\\) et mes communautes.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur le portail Orange World.Ne sont pas compris dans l'option, les usages mail \\(smtp, pop, imap\\), les usages modem, les contenus.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et services payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une qualite de service optimale.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option, conditions specifiques.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et liste des terminaux compatibles sur www.orange.fr. Les 2 premiers mois a \\-50% pour toute premiere.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_orange_maps) ->
    [
     {expect, "Option valable en France metropolitaine et a souscrire pour tout client forfait mobile Orange \\(hors mobicarte\\),.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "valables sur reseaux et depuis un terminal compatible \\(liste des mobiles compatibles sur gps.orange.fr\\). Avec le service de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "navigation Orange maps: Itineraires illimites avec data inclus \\(telechargements en data GPRS, 3G ou 3G\\+ des itineraires, des requetes.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de mise a jour de l'information trafic ou des trajets inclus dans l'option Orange maps dans la limite de 10 Mo/mois,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "en France metropolitaine\\), info trafic \\(trajets optimises sur Paris/Ile-de-France, evenements sur toute la France,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "accidents, fermetures, travaux, bouchons, etc\\) opere par Mediamobile/ V-Trafic, guidage routier et pieton et.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "cartographie de 26 pays d'Europe mise ajour automatiquement \\(Allemagne, Andorre, Autriche, Belgique,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Danemark, Espagne, Estonie, Finlande, France, Gibraltar, Grece, Irlande, Italie, Liechtenstein, Luxembourg, Monaco, Norvege,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Pays-Bas, Portugal, Republique Tcheque, Royaume-Uni, San-Marin, Slovaquie, Suede, Suisse, Vatican\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_mes_donnees) ->
    [
     {expect, "Option mes donnees \\+30 Go a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors Fnac Mobile\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Augmentation de l'espace de stockage sur le service mes donnees, de 30 Go supplementaires, permettant aux souscripteurs de passer de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "10 a 40 Go de stockage pour les clients mobile ou de 20 a 50 Go pour les clients mobiles ayant active l'option gratuite.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "mes services unifies. Service accessible depuis tout compte Orange disposant d'une facture. Sont factures en dehors de l'option les.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "couts de connexions lies a l'acces au service depuis son terminal. Cette option peut etre interrompue a tout.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "moment par l'utilisateur. Usages en France metropolitaine. Service accessible sur reseaux et depuis un terminal compatible..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr"}
    ];

test_mention_leg(opt_mail) ->
    [
     {expect, "Option Mail a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\). Option.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "incompatible avec l'option Mail pour BlackBerryTM. Reception et envoi illimite de mails et de PJ a partir du client e\\-mail du mobile..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Service accessible depuis tt compte mail utilisant les protocoles IMAP,POP&SMTP \\(hors services payants\\) ou Nokia messaging avec.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange. Ne sont pas compris dans l'option, les services de messagerie Microsoft.* ExchangeTM et les applications de messagerie.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "utilisant le protocole de navigation http.Pour 1 qualite service optimale sur son reseau,Orange pourra limiter le debit au dela d'1.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis un.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "terminal compatibles. Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.Les 2.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010"}
    ];

test_mention_leg(opt_orange_sport) ->
    [
     {expect, "Option Sport a souscrire et valable pour des usages en France metrop pour tt client mobile Orange \\(hors offres Internet everywhere\\).*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur reseaux et depuis 1 terminal compatibles.Option incompatible avec l'option TV max et l'avantage OM. Navigation illimitee sur le.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "portail Orange World. Consultation illimitee sur le portail Orange World et/ou l'application Orange correspondante de 8 matchs de.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ligue 1 en direct par journee de championnat,de tous les evenements sportifs en direct proposes sur l'espace sport\\(hors directs TV\\),.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "des chaines TV Orange sport et Orange sport info et des videos des rubriques actualite, sport et cinema \\(hors Orange cinema series\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines susceptible d'evolution. Ne sont pas compris les contenus et services payants. Pour 1 qualite de service optimale.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr. Usages en France metropolitaine..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Services accessibles sur reseaux et depuis un terminal compatibles. Matchs de Ligue 1 en direct et chaines TV.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "accessibles sur terminaux iPhone sous reserve de telechargement aux tarifs en vigueur de l'application correspondante..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Autres evenements sportifs en direct sous reserve de disponibilite de l'application correspondante..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(Media)
  when Media==opt_lyon;Media==opt_marseille;
       Media==opt_paris;Media==opt_bordeaux;
       Media==opt_lens;Media==opt_saint_etienne ->
    [
     {expect, "Options PSG mobile, OM mobile, OL mobile, ASSE mobile, RCL mobile, Girondins mobile a souscrire et valables en France metropolitaine.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pour tout client mobile Orange \\(hors offres Internet everywhere\\). Option incompatible avec les autres options clubs mobile..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Reception des sms info du club choisi, des alertes sms buts et des sms buts et resumes de match du club en.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Ligue 1 en video \\(sous reserve de disposer d'un mobile compatible video\\). De 10 a 30 SMS metropolitains \\(hors.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "SMS surtaxes\\) offerts chaque mois calendaire \\(selon les resultats du club au cours du mois precedent\\). Activation des SMS possible.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "pendant 15 jours a compter de la date de reception du SMS de confirmation. SMS valables 30 jours a compter de l'activation et non.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "cumulables d'un mois sur l'autre. Navigation et consultation illimitees des services et videos du portail du club choisi.Ne sont pas.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compris dans l'option,la navigation et la consultation de videos sur le portail Orange World, les contenus et services payants..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Pour une qualite de service optimale sur son reseau, Orange pourra limiter le.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "reseaux et depuis un terminal compatibles. Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "www.orange.fr.Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_musique_mix) ->
    [
     {expect, "Option Musique mix a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Orange incluant le.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "telechargement d'au moins 10 titres et offres Internet everywhere\\).Option incompatible avec l'option Musique collection..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Telechargement de 10 titres musicaux par mois parmi le catalogue de titres eligible a l'option \\(hors rubriques classique et jazz\\)..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Nombre de titres decomptes en mois calendaire.Titres supplementaires et hors catalogue proposes a l'achat a 0.99E/titre.Titres.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "telechargeables depuis mobile et ordinateur \\(PC/Mac\\).Titres telecharges sur le mobile non transferables. Navigation illimitee sur le.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "portail Orange World. Consultation illimitee sur le portail Orange World des videos des rubriques musique, actualite, sport \\(hors.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "evenements sportifs en direct\\) et cinema \\(hors Orange cinema series\\). Consultation illimitee des chaines TV musicales \\(NRJ Hit,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "MCM top,MCM pop,M6 Music,M6 Black,M6 Music club,Trace TV,Trace Tropical\\). Ecoute illimitee des radios sur le portail Orange World..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Liste des chaines TV musicales et radios susceptible d'evolution.Ne sont pas compris dans l'option,les contenus et services payants..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Pour une qualite de service optimale sur son reseau,Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "la date de facturation.Usage en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles..*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Telechargements et ecoute des radios non accessibles sur terminaux iPhone. Titres telecharges depuis un ordinateur lisibles.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et transferables sur terminaux iPhone. Voir details de l'option, conditions specifiques et liste des terminaux.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "compatibles sur www.orange.fr. Les 2 premiers mois a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ];

test_mention_leg(opt_musique_collection) ->
    [
     {expect, "Option Musique collection a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Internet everywhere\\).Option incompatible avec l'option Musique mix.Telechargement de 25 titres musicaux par mois parmi le catalogue.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "de titres eligible a l'option \\(hors rubriques classique et jazz\\).Nombre de titres decomptes en mois calendaire.Titres supplementaires.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "et hors catalogue proposes a l'achat a 0.99E/titre. Titres telechargeables depuis mobile et ordinateur \\(PC/Mac\\). Titres.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "telecharges sur le mobile non transferables. Navigation illimitee sur le portail Orange World. Consultation illimitee sur le portail.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Orange World des videos des rubriques musique, actualite, sport \\(hors evenements sportifs en direct\\) et cinema \\(hors Orange.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "cinema series\\). Consultation illimitee des chaines TV musicales \\(NRJ Hit,MCM top,MCM pop,M6 Music,M6 Black,M6 Music club,Trace TV,.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "Trace Tropical\\). Ecoute illimitee des radios sur le portail Orange World.Liste des chaines TV musicales et radios susceptible.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "d'evolution.Ne sont pas compris dans l'option, les contenus et services payants. Pour une qualite de service optimale sur son.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "metropolitaine.Services accessibles sur reseaux et depuis un terminal compatibles. Telechargements et ecoute des radios.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "non accessibles sur terminaux iPhone.Titres telecharges depuis un ordinateur lisibles et transferables sur terminaux iPhone.Voir.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "details de l'option,conditions specifiques et liste des terminaux compatibles sur www.orange.fr.Les 2 premiers mois.*1:Suite.*2:Souscrire"},
     {send, "1"},
     {expect, "a \\-50% pour toute premiere souscription du 10/06/2010 au 18/08/2010.*1:Souscrire"}
    ].

expect_text(description, Media) ->
    case Media of
	opt_tv ->
	    "Option TV.*Regardez \\+ de 20 chaines TV et 3.500 videos et surfez sur Orange World en illimite pour 6E/mois";
	opt_tv_max ->
	    "Option TV max.*Regardez \\+de 60 chaines TV et 3500 videos, toute la Ligue1 et Orange World en illimite pour 9E/mois";
	opt_internet ->
	    "Option Internet.*Surfez en illimite sur internet de 20h a 8h et sur Orange World 24h/24 pour 6E/mois";
	opt_internet_max ->
	    "Option Internet max.*Surfez en illimite sur internet, Gallery et Orange World pour 12E/mois";
	opt_orange_maps ->
	    "Orange Maps.*Faites-vous guider par votre mobile grace a ce service complet de navigation embarquee pour 5E/mois";
	opt_mes_donnees ->
	    "Mes donnees \\+30Go.*Beneficiez de 30Go supplementaires pour stocker,partager vos fichiers multimedias pour 5E par mois";
	opt_mail ->
	    "Option mail.*Vos mails, avec vos pieces jointes, en illimite 24H/24, 7J/7 pour 9E/mois";
	opt_orange_sport ->
	    "Suivez les grands evenements sportifs en illimite 24h/24 7j/7 pr 6E/mois avec l'option Sport";
	opt_lyon ->
	    "Option OL Mobile.*Suivez l'actu de l'OL:SMS infos,alertes buts &resumes des matchs de votre club en Ligue 1 en video";
	opt_marseille ->
	    "Option OM Mobile.*Suivez l'actu de l'OM:SMS infos,alertes buts &resumes des matchs de votre club en Ligue 1 en video";
	opt_paris ->
	    "Option PSG Mobile.*Suivez l'actu du PSG:SMS infos,alertes buts & resumes des matchs de votre club en Ligue 1 en video";
	opt_bordeaux ->
	    "Opt Girondins Mobile.*Suivez l'actu des Girondins:SMS infos,alertes buts&resumes des matchs du club en Ligue 1 en video";
	opt_lens ->
	    "Option RCL Mobile.*Suivez l'actu du RCL:SMS infos,alertes buts &resumes des matchs de votre club en Ligue 1 en video";
	opt_saint_etienne ->
	    "Option ASSE Mobile.*Suivez l'actu de l'ASSE:SMS infos,alertes buts&resumes des matchs du club en Ligue 1 en video";
	opt_musique_mix ->
	    "Option Musique mix.*10 titres a telecharger parmi le catalogue eligible. Navigation illimitee sur Orange World pour 6E/mois";
	opt_musique_collection ->
	    "Musique collection.*25 titres a telecharger parmi le catalogue eligible. Navigation illimitee sur Orange World pour 12E/mois"
    end++
	".*1:Souscrire.*7:Conditions";

expect_text(souscription, Media) ->
    "Souscription.*Vous allez souscrire a "++
	case Media of
	    opt_tv ->
		"l'option TV. Vous serez facture de 6E/mois.";
	    opt_tv_max ->
		"l'option TV max. Vous serez facture de 9E/mois.";
	    opt_internet ->
		"l'option Internet. Vous serez facture de 6E/mois.";
	    opt_internet_max ->
		"l'option internet max a 12E/mois.";
	    opt_orange_maps ->
		"l'option Orange maps.Vous serez facture 5E/mois.";
	    opt_mes_donnees ->
		"l'option Mes donnees \\+30Go pour 5E";
	    opt_mail ->
		"l'option mail. Vous serez facture de 9E/mois.";
	    opt_orange_sport ->
		"l'option Sport. Vous serez facture de 6E/mois.";
	    opt_lyon ->
		"l'option OL mobile. Vous serez facture de 5E/mois.";
	    opt_marseille ->
		"l'option OM mobile. Vous serez facture de 5E/mois.";
	    opt_paris ->
		"l'option PSG mobile. Vous serez facture de 5E/mois.";
	    opt_bordeaux ->
		"l'opt Girondins mobile. Vous serez facture de 5E/mois.";
	    opt_lens ->
		"l'option RCL mobile. Vous serez facture de 5E/mois.";
	    opt_saint_etienne ->
		"l'option ASSE mobile. Vous serez facture de 5E/mois.";
	    opt_musique_mix ->
		"l'option Musique mix. Vous serez facture de 6E/mois.";
	    opt_musique_collection ->
		"Musique collection.Vous serez facture de 12E/mois."
	end++
	".*1:Valider";

expect_text(validation_1, Media) ->
    "Validation.*Souscription enregistree.*" ++
	case Media of
	    opt_tv ->
		"Les 2 premiers mois seront a 3E, au dela vous serez facture de 6E/mois.";
	    opt_tv_max ->
		"Les 2 premiers mois vous seront factures 4.5E, puis 9E/mois";
	    opt_internet ->
		"Les 2 premiers mois seront a 3E, au dela a 6E/mois.";
	    opt_internet_max ->
		"Les 2 premiers mois seront a 6E, au dela a 12E/mois.";
	    opt_orange_maps ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_mes_donnees ->
		"Vous serez facture 5E/mois.";
	    opt_mail ->
		"Les 2 premiers mois seront a 4,5E, au dela a 9E/mois.";
	    opt_orange_sport ->
		"Les 2 premiers mois seront a 3E, au dela vous serez facture de 6E/mois.";
	    opt_lyon ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_marseille ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_paris ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_bordeaux ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_lens ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_saint_etienne ->
		"Les 2 premiers mois seront a 2,5E, au dela a 5E/mois.";
	    opt_musique_mix ->
		"Les 2 premiers mois seront a 3E, au dela a 6E/mois.";
	    opt_musique_collection ->
		"Les 2 premiers mois seront a 6E, au dela a 12E/mois."
	end++
	".*Vous serez averti de son activation par SMS.*1:Suite"
	".*8:Precedent";
%%  	".*9:Accueil";

expect_text(validation_2, _) ->
    "Votre option sera debitee de votre compte mobile puis de votre forfait si le compte mobile est epuise.".

subscribe_XMedia_incomp()->
    %% OPTION ORANGE SPORT
    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="PORFT"}])++

	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
	 "SOUSCRIPTION OPTION Orange Sport, OPTION Orange foot ACTIVE",
	 {ussd2,
	  [ {send, test_util_of:access_code(?MODULE, opt_orange_sport)},
	    {expect,"Option Sport.*Attention.*Option Orange foot.*resiliee.*1:Souscrire.*"},
	    {send,"1"},
	    {expect,"Souscription.*1:Valider"}
	   ]}
	]++
	close_session()++

 	%% OPTION OL MOBILE
 	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
 	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="OCF02"}])++

 	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
 	 "SOUSCRIPTION OPTION OL Mobile, OPTION OM Mobile ACTIVE",
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, opt_lyon)},
 	    {expect,"Option OL Mobile.*Attention.*Option OM Mobile.*resiliee.*1:Souscrire.*"},
 	    {send,"1"},
 	    {expect,"Souscription.*1:Valider"}
 	   ]}
 	]++
 	close_session()++


 	%% OPTION OM MOBILE
 	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
 	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="OCF03"}])++

 	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
 	 "SOUSCRIPTION OPTION OM Mobile, OPTION PSG Mobile ACTIVE",
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, opt_marseille)},
 	    {expect,"Option OM Mobile.*Attention.*Option PSG Mobile.*resiliee.*1:Souscrire.*"},
 	    {send,"1"},
 	    {expect,"Souscription.*1:Valider"}
 	   ]}
 	]++
 	close_session()++


 	%% OPTION PSG MOBILE
 	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
 	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="OCF04"}])++
 	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
 	 "SOUSCRIPTION OPTION PSG Mobile, OPTION Girondins Mobile ACTIVE",
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, opt_paris)},
 	    {expect,"Option PSG Mobile.*Attention.*Opt Girondins Mobile.*resiliee.*1:Souscrire.*"},
 	    {send,"1"},
 	    {expect,"Souscription.*1:Valider"}
 	   ]}
 	]++
 	close_session()++


 	%% OPT GIRONDINS MOBILE
 	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
 	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="OCF05"}])++
 	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
 	 "SOUSCRIPTION OPTION Girondins Mobile, OPTION RCL Mobile ACTIVE",
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, opt_bordeaux)},
 	    {expect,"Opt Girondins Mobile.*Attention.*Option RCL Mobile.*resiliee.*1:Souscrire.*"},
 	    {send,"1"},
 	    {expect,"Souscription.*1:Valider"}
 	   ]}
 	]++
 	close_session()++ 


 	%% OPT RCL MOBILE
 	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
 	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="OCF06"}])++
 	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
 	 "SOUSCRIPTION OPTION RCL Mobile, OPTION ASSE Mobile ACTIVE",
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, opt_lens)},
 	    {expect,"Option RCL Mobile.*Attention.*Option ASSE Mobile.*resiliee.*1:Souscrire.*"},
 	    {send,"1"},
 	    {expect,"Souscription.*1:Valider"}
 	   ]}
 	]++
 	close_session()++ 

 	%% OPT ASSE MOBILE
 	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"})++
 	profile_manager:set_asm_impact_options(?Uid,[#asm_option{code_so="OCF01"}])++
 	[{title, "Activation d'option CMO: TEST OPTIONS MULTIMEDIA"},
 	 "SOUSCRIPTION OPTION ASSE Mobile, OPTION OL Mobile ACTIVE",
 	 {ussd2,
 	  [ {send, test_util_of:access_code(?MODULE, opt_saint_etienne)},
 	    {expect,"Option ASSE Mobile.*Attention.*Option OL Mobile.*resiliee.*1:Souscrire.*"},
 	    {send,"1"},
 	    {expect,"Souscription.*1:Valider"}
 	   ]}
 	]++
 	close_session()++

	[].

close_session() ->
    test_util_of:close_session().
