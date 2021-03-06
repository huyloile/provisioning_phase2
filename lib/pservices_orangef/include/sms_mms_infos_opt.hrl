-define(TENTATIVE,4).




-record(smsinfos, {
	  portemonnaie,
	  imeitac,
	  listerubrique=[],
	  en_cours,
	  first_acces=false,
	  tmp_links}
       ).


%% +deftype rubrique() =
%%     #rubrique{ id::         integer(),
%%                facturation::'A' | 'M' | 'T',
%%                active::     boll(),
%%                datefin::    date(),
%%                comp1::      string(),
%%                comp2::      string(),
%%                comp3::      string(),
%%                prix::       currency:currency(),
%%                prix_no_promo::currency:currency(),
%%                saisie::     string(),
%%                tentative::  integer(),
%%                descr_rub::      string(),
%%                descr_comp::      string()
%%                   }.
-record(rubrique, 
	{id,
	 facturation,
	 active,
	 datefin,
	 comp1,
	 comp2,
	 comp3,
	 prix,
	 prix_no_promo,
	 saisie,
	 tentative=?TENTATIVE,
	 descr_rub="",
	 descr_comp=""}).

%% +deftype smsinfos() =
%%     #smsinfos{ portemonnaie::   currency:currency(),
%%                imeitac::        string(),
%%                listerubrique::  [integer()],
%%                en_cours::       atom(),
%%                first_acces::    bool(),
%%                tmp_links::      term()}. 

-record(sms_mms_option_params, 
	{idOption,
	 tarif,
	 idTarif,
	 tarifHorsPromo,
	 idtarifHorsPromo,
	 renouvellement,
	 uniteRenouvellement,
	 typeFacturation,
	 typeFacturationHorsPromo,
	 ordre,
	 libOption,
	 descOption,
	 presOption,
	 flagOptionSouscrite,
	 idCompOption,
	 lidCompOption,
	 codeCompOption,
	 ordreComOption
}).


-define(LISTE_OPTS_SMS_INFOS,[{meteo,     "Meteo",                "10011"},
			      {actu,      "Actualites",           "20006"},
			      {actu_gene, "Actualites generales", "20006"},
			      {tv,        "Programme TV",         "30010"},
			      {sport,     "Sport",                "30000"},
			      {horoscope, "Horo",                 "30020"},
			      {cine,      "Cinema",               "30005"},
%%			      {stars,     "Stars",                "30025"},
			      {people,    "People",               "30025"},
			      {loto,      "Loto",                 "45005"},
			      {quinte,    "Quinte",               "45004"},
			      {blague,    "Blagues",              "30090"},
			      {ligue1,    "Ligue1",               "33005"}]).




%% liste horoscope
-define(LIST_SIGN, [{belier,    "BELIER",     1},
		    {taureau,   "TAUREAU",    2},
		    {gemeaux,   "GEMEAUX",    3},
		    {cancer,    "CANCER",     4},
		    {lion,      "LION",       5},
		    {vierge,    "VIERGE",     6},
		    {balance,   "BALANCE",    7},
		    {scorpion,  "SCORPION",   8},
		    {sagitaire, "SAGITAIRE",  9},
		    {capricorne,"CAPRICORNE",10},
		    {verseau,   "VERSEAU",   11},
		    {poisson,   "POISSON",   12}]).


-define(LIST_LOTO,
	[{"1","Loto"},
	 {"2","Keno"},
	 {"3","Loto et Keno"}]).

-define(LISTE_LOCALE,
	[
	{"0","nationale seule"},
	{"00","nationale seule"},
	{"01", "Ain"},
	{"02", "Aisne"},
	{"03", "Allier"},
	{"04", "Alpes-de-Haute-Provence"},
	{"05", "Hautes-Alpes"},
	{"06", "Alpes-Maritimes"},
	{"07", "Ardeche"},
	{"08", "Ardennes"},
	{"09", "Ariege"},
	{"10", "Aube"},
	{"11", "Aude"},
	{"12", "Aveyron"},
	{"13", "Bouches-du-Rhone"},
	{"14", "Calvados"},
	{"15", "Cantal"},
	{"16", "Charente"},
	{"17", "Charente-Maritime"},
	{"18", "Cher"},
	{"19", "Correze"},
	{"200", "Corse du Sud"},
	{"201", "Corse du Nord"},
	{"21", "Cote-d'Or"},
	{"22", "Cotes d'Armor"},
	{"23", "Creuse"},
	{"24", "Dordogne"},
	{"25", "Doubs"},
	{"26", "Drome"},
	{"27", "Eure"},
	{"28", "Eure-et-Loire"},
	{"29", "Finistere"},
	{"30", "Gard"},
	{"31", "Haute-Garonne"},
	{"32", "Gers"},
	{"33", "Gironde"},
	{"34", "Herault"},
	{"35", "Ile-et-Vilaine"},
	{"36", "Indre"},
	{"37", "Indre-et-Loire"},
	{"38", "Isere"},
	{"39", "Jura"},
	{"40", "Landes"},
	{"41", "Loir-et-Cher"},
	{"42", "Loire"},
	{"43", "Haute-Loire"},
	{"44", "Loire-Atlantique"},
	{"45", "Loiret"},
	{"46", "Lot"},
	{"47", "Lot-et-Garonne"},
	{"48", "Lozere"},
	{"49", "Maine-et-Loire"},
	{"50", "Manche"},
	{"51", "Marne"},
	{"52", "Haute-Marne"},
	{"53", "Mayenne"},
	{"54", "Meurthe-et-Moselle"},
	{"55", "Meuse"},
	{"56", "Morbihan"},
	{"57", "Moselle"},
	{"58", "Nievre"},
	{"59", "Nord"},
	{"60", "Oise"},
	{"61", "Orne"},
	{"62", "Pas-de-Calais"},
	{"63", "Puy-de-Dome"},
	{"64", "Pyrenees-Atlantique"},
	{"65", "Hautes-Pyrenees"},
	{"66", "Pyrenees-Orientales"},
	{"67", "Bas-Rhin"},
	{"68", "Haut-Rhin"},
	{"69", "Rhone"},
	{"70", "Haute-Saone"},
	{"71", "Saone-et-Loire"},
	{"72", "Sarthe"},
	{"73", "Savoie"},
	{"74", "Haute-Savoie"},
	{"75", "Paris"},
	{"76", "Seine-Maritime"},
	{"77", "Seine et Marne"},
	{"78", "Yvelines"},
	{"79", "Deux-sevres"},
	{"80", "Somme"},
	{"81", "Tarn"},
	{"82", "Tar-et-Garonne"},
	{"83", "Var"},
	{"84", "Vaucluse"},
	{"85", "Vendee"},
	{"86", "Vienne"},
	{"87", "Haute-Vienne"},
	{"88", "Vosges"},
	{"89", "Yonne"},
	{"90", "Teritoire de Belfort"},
	{"91", "Essone"},
	{"92", "Hauts de Seine"},
	{"93", "Seine St Denis"},
	{"94", "Val de Marne"},
	{"95", "Val d'Oise"}]).


-define(LISTE_CLUB,
	[{"RES","Resultats",       "00"},
	 {"LOR","Lorient",         "01"},
	 {"AUX","Auxerre",         "02"},
	 {"NAN","Nancy",           "03"},
	 {"BOR","Bordeaux",        "04"},
	 {"LEM","Le Mans",         "05"},
	 {"MAN","Le Mans",         "05"},
	 {"LIL","Lille",           "08"},
	 {"LYO","Lyon",            "09"},
	 {"MAR","Marseille",       "10"},
	 {"MON","Monaco",          "11"},
	 {"SAI","Saint-Etienne",   "12"},
     {"STE","Saint-Etienne",   "12"},
     {"ETI","Saint-Etienne",   "12"},
	 {"NIC","Nice",            "14"},
	 {"PSG","PSG",             "15"},
	 {"PAR","PSG",             "15"},
	 {"REN","Rennes",          "16"},
	 {"GRE","Grenoble",        "17"},
	 {"SOC","Sochaux",         "18"},
	 {"VAL","Valenciennes",    "19"},
	 {"TOU","Toulouse",        "20"},
	 {"LEN","Lens",            "21"},
	 {"BOU","Boulogne",        "24"},
	 {"MON","Montpellier",     "25"},
	 {"MOT","Montpellier",     "25"}]).
	 
-define(LIST_METEO, [
	{1, "Ain", "Bourg-en-Bresse", 706},
	{2, "Aisne","Laon", 2612},
	{3, "Allier","Moulins", 3618},
	{4, "Alpes de Hautes-Provence", "Digne", 1539},
	{5, "Hautes-Alpes", "Gap", 1939},
	{6, "Alpes-Maritimes", "Nice", 3731},
	{7, "Ardeche", "Privas", 4259},
	{8, "Ardennes", "Charleville-Mezieres", 1101},
	{9, "Ariege", "Foix", 1833},
	{10,"Aube", "Troyes", 5597},
	{11,"Aude", "Carcassonne", 913},
	{12,"Aveyron", "Rodez", 4433},
	{13,"Bouches-du-Rhone", "Marseille", 3219},
	{14,"Calvados","Caen", 857},
	{15,"Cantal", "Aurillac", 288},
	{16,"Charente","Angouleme",136},
	{17,"Charente-Maritime","La Rochelle",2496},
	{18,"Cher","Bourges",714},
	{19,"Correze","Tulle",5603},
	{200,"Corse-du-Sud","Ajaccio",56},
	{201,"Haute-Corse","Bastia", 403},
	{21,"Cote-d'Or","Dijon", 1541},
	{22,"Cotes d'Armor","Saint-Brieuc",4608},
	{23,"Creuse", "Gueret", 2095},
	{24,"Dordogne","Perigueux",3982},
	{25,"Doubs","Besancon", 532},
	{26,"Drome","Valence", 5646},
	{27,"Eure","Evreux",1744},
	{28,"Eure-et-Loir","Chartres",1112},
	{29,"Finistere","Quimper",4307},
	{30,"Gard","Nimes", 3740},
	{31,"Haute-Garonne","Toulouse",5535},
	{32,"Gers","Auch",258},
	{33,"Gironde","Bordeaux", 657},
	{34,"Herault","Montpellier", 3544},
	{35,"Ille-et-Vilaine","Rennes",4360},
	{36,"Indre","Chateauroux",1158},
	{37,"Indre-et-Loire","Tours",5555},
	{38,"Isere","Grenoble",2065},
	{39,"Jura","Lons-le-Saunier",3018},
	{40,"Landes","Mont-de-Marsan",3445},
	{41,"Loir-et-Cher","Blois",606},
	{42,"Loire","Saint-Etienne",4680},
	{43,"Haute-Loire","Le Puy-en-Velay",2834},
	{44,"Loire-Atlantique","Nantes",3673},
	{45,"Loiret","Orleans",3846},
	{46,"Lot","Cahors",862},
	{47,"Lot-et-Garonne","Agen",18},
	{48,"Lozere","Mende",3301},
	{49,"Maine-et-Loire","Angers",129},
	{50,"Manche","Saint-L%G�%@",4870},
	{51,"Marne","Chalons-en-Champagne",1047},
	{52,"Haute-Marne","Chaumont",1187},
	{53,"Mayenne","Laval",2649},
	{54,"Meurthe-et-Moselle","Nancy",3668},
	{55,"Meuse","Bar-le-Duc",374},
	{56,"Morbihan","Vannes",5674},
	{57,"Moselle","Metz",3341},
	{58,"Nievre","Nevers",3728},
	{59,"Nord","Lille",2948},
	{60,"Oise","Beauvais",462},
	{61,"Orne","Alencon",69},
	{62,"Pas-de-Calais","Arras",203},
	{63,"Puy-de-Dome","Clermont-Ferrand",1267},
	{64,"Pyrenes-Atlantiques","Pau",3955},
	{65,"Hautes-Pyrenees","Tarbes",5442},
	{66,"Pyrenees-Orientales","Perpignan",3989},
	{67,"Bas-Rhin","Strasbourg",5417},
	{68,"Haut-Rhin","Colmar",1296},
	{69,"Rhone","Lyon",3090},
	{70,"Haute-Saoe","Vesoul",5787},
	{71,"Saine-et-Loire","Macon",3104},
	{72,"Sarthe","Le Mans",2742},
	{73,"Savoie","Chambery",1052},
	{74,"Haute-Savoie","Annecy",141},
	{75,"Paris","Paris",3903},
	{76,"Seine-Maritime","Rouen",4482},
	{77,"Seine-et-Marne","Melun",3299},
	{78,"Yvelines","Versailles",5772},
	{79,"Deux-Sevres","Niort",3742},
	{80,"Somme","Amiens",108},
	{81,"Tarn","Albi",65},
	{82,"Tarn-et-Garonne","Montauban",3465},
	{83,"Var","Toulon",5530},
	{84,"Vaucluse","Avignon",313},
	{85,"Vendee","La Roche-sur-Yon",2494},
	{86,"Vienne","Poitiers",4140},
	{87,"Haute-Vienne","Limoges",2954},
	{88,"Vosges","Epinal",1673},
	{89,"Yonne","Auxerre",300},
	{90,"Territoire-de-Belfort","Belfort",483},
	{91,"Essonne","Evry",1746},
	{92,"Hauts-de-Seine","Nanterre", 3672},
	{93,"Seine-Saint-Denis","Bobigny",610},
	{94,"Val-de-Marne","Creteil",1441},
	{95,"Val-d'Oise","Cergy",1004}]).

%% Avoir avec SMSINFOS
%% +deftype mmsinfos() =
%%     #mmsinfos{ portemonnaie    :: currency(),
%%                imeitac         :: string(),
%%                facturation     :: 'A' | 'T',
%%                listerubrique   ::[int()],
%%                listrub_blocked ::[int()],
%%                en_cours        ::atom(),
%%                first_acces     ::bool(),
%%                mms_compat      ::integer(),
%%                vdo_compat      ::integer(),
%%                meteo           :: rubrique(),
%%                horoscope       :: rubrique(),
%%                actu            :: rubrique(),
%%                cine            :: rubrique(),
%%                ligue1          :: rubrique(),
%%                humour          :: rubrique(),
%%                coquin          :: rubrique(),
%%                people          :: rubrique(),
%%                tv              :: rubrique(),
%%                ligue1_vdo      :: rubrique(),
%%                humour_vdo      :: rubrique(),
%%                coquin_vdo      :: rubrique(),
%%                tmp_links :: term()
%%                   }.

-record(mmsinfos, {
	  portemonnaie,
	  imeitac,
	  facturation,
	  listerubrique=[],
	  listrub_blocked=[],
	  en_cours,
	  first_acces=false,
	  mms_compat=0,
	  vdo_compat=0,
	  meteo=#rubrique{id=meteo,descr_rub="Meteo"},
	  horoscope=#rubrique{id=horoscope,descr_rub="Horoscope"},
	  actu=#rubrique{id=actu,descr_rub="Actualites"},
	  cine=#rubrique{id=cine,descr_rub="Cinema"},
	  ligue1=#rubrique{id=ligue1,descr_rub="Orange Ligue 1"},
	  humour=#rubrique{id=humour,descr_rub="Humour"},
	  coquin=#rubrique{id=coquin,descr_rub="Charme"},
	  people=#rubrique{id=people,descr_rub="People"},
	  tv=#rubrique{id=tv,descr_rub="TV"},
	  ligue1_vdo=#rubrique{id=ligue1_vdo,descr_rub="video Orange Ligue 1"},
	  humour_vdo=#rubrique{id=humour_vdo,descr_rub="video Humour"},
	  coquin_vdo=#rubrique{id=coquin_vdo,descr_rub="video Charme"},
	  tmp_links}
       ).


%%%% ERROR CODE
-define(no_profile,93).
-define(terminal_unknown,94).
-define(terminal_unknown2,95).
-define(terminal_no_mms,91).
-define(request_error,99).
-define(mms_not_compatible,0).


-define(f,"feminin").
-define(m,"masculin").
%%% Horoscope
-define(LIST_SIGN_MMS, [{{belier,f},    {"BELIER",?f},     1},
		    {{taureau,f},   {"TAUREAU",?f},    2},
		    {{gemeaux,f},   {"GEMEAUX",?f},    3},
		    {{cancer,f},    {"CANCER",?f},     4},
		    {{lion,f},      {"LION", ?f},      5},
		    {{vierge,f},    {"VIERGE",?f},     6},
		    {{balance,f},   {"BALANCE",?f},    7},
		    {{scorpion,f},  {"SCORPION",?f},   8},
		    {{sagitaire,f}, {"SAGITAIRE",?f},  9},
		    {{capricorne,f},{"CAPRICORNE",?f},10},
		    {{verseau,f},   {"VERSEAU", ?f},  11},
		    {{poisson,f},   {"POISSON",?f},   12},
		    {{belier,h},    {"BELIER",?m},    13},
		    {{taureau,h},   {"TAUREAU",?m},   14},
		    {{gemeaux,h},   {"GEMEAUX",?m},   15},
		    {{cancer,h},    {"CANCER",?m},    16},
		    {{lion,h},      {"LION", ?m},     17},
		    {{vierge,h},    {"VIERGE",?m},    18},
		    {{balance,h},   {"BALANCE",?m},   19},
		    {{scorpion,h},  {"SCORPION",?m},  20},
		    {{sagitaire,h}, {"SAGITAIRE",?m}, 21},
		    {{capricorne,h},{"CAPRICORNE",?m},22},
		    {{verseau,h},   {"VERSEAU", ?m},  23},
		    {{poisson,h},   {"POISSON", ?m},  24}]).

%%%% FILTER CODE
-define(parental_control,1).
-define(pro_control,2).

-define(total_block,0).
-define(partial_block,1).

-define(LISTE_OPTS_MMS_INFOS,
	[{meteo,     "Meteo",        "50111"},
	 {actu,      "Actualites",   "50140"},
	 {tv,        "Programme TV", "50141"},
	 {people,    "People",       "50142"},
	 {horoscope, "Horo",         "50120"},
	 {cine,      "Cinema",       "50150"},
	 {humour,    "Humour",       "50200"},
	 {charme,    "Charme",       "50900"},
	 {ligue1,    "Orange Ligue 1",       "50130"}
	]).

-define(LISTE_OPTS_MMS_INFOS_V,
	[{ligue1_vdo,"Video Orange Ligue 1", "54130"},
	 {coquin_vdo,"Video Charme", "54900"},
	 {humour_vdo,"Video Humour", "54200"}
	 ]).
