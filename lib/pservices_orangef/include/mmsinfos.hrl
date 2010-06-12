-define(TENTATIVE,4).

-define(meteo,        50111).
-define(cine,         50150).
-define(humour,       50200).
-define(coquin,       50900).
-define(actu,         50140).
-define(horoscope,    50120).
-define(ligue1,       50130).
-define(tv,           50141).
-define(people,       50142).
-define(ligue1_vdo,   54130).
-define(coquin_vdo,   54900).
-define(humour_vdo,   54200).


-define(LISTE_RUBRIQUE,
	[{meteo, ?meteo},
	 {cine, ?cine},
	 {humour, ?humour},
	 {coquin, ?coquin},
	 {actu, ?actu},
	 {horoscope, ?horoscope},
	 {ligue1, ?ligue1},
	 {tv,?tv},
	 {people,?people},
	 {ligue1_vdo,?ligue1_vdo},
	 {coquin_vdo,?coquin_vdo},
	 {humour_vdo,?humour_vdo}]).

-define(LISTE_RUB_MODIF,
	[{horoscope, ?horoscope}]).

%% +deftype rubrique() =
%%     #rubrique{ id::integer(),
%%                datefin:: date(),
%%                comp1::string(),
%%                comp2::string(),
%%                comp3::string(),
%%                prix::currency(),
%%                prix_no_promo::currency(),
%%                saisie::string(),
%%                tentative::integer(),
%%                descr::string()
%%                   }.
-record(rubrique, 
	{id,
	 datefin,
	 comp1,
	 comp2,
	 comp3,
	 prix,
	 prix_no_promo,
	 saisie,
	 tentative=?TENTATIVE,
	 descr=""}).

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
	  meteo=#rubrique{id=?meteo,descr="Meteo"},
	  horoscope=#rubrique{id=?horoscope,descr="Horoscope"},
	  actu=#rubrique{id=?actu,descr="Actualites"},
	  cine=#rubrique{id=?cine,descr="Cinema"},
	  ligue1=#rubrique{id=?ligue1,descr="Orange Ligue 1"},
	  humour=#rubrique{id=?humour,descr="Humour"},
	  coquin=#rubrique{id=?coquin,descr="Charme"},
	  people=#rubrique{id=?people,descr="People"},
	  tv=#rubrique{id=?tv,descr="TV"},
	  ligue1_vdo=#rubrique{id=?ligue1_vdo,descr="video Orange Ligue 1"},
	  humour_vdo=#rubrique{id=?humour_vdo,descr="video Humour"},
	  coquin_vdo=#rubrique{id=?coquin_vdo,descr="video Charme"},
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
-define(LIST_SIGN, [{{belier,f},    {"BELIER",?f},     1},
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
