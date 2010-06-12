%%%% Self care pages constants and record definitions


-record(state, {msisdn, nsce, imsi,    %% SDP format ("06..", not "+336..")
		canal, part, 
		monnaie, langue, type_carte, type_num, plan,
		dtl,                   % date validite etat au format unix
		staxe,                 % dans la monnaie
		etat_princ, etats_sec}).

-define(INUSITE,         inusite).
-define(MONNAIE,         2#00000001).
-define(FRANC,           2#00000000).
-define(EURO,            2#00000001).
-define(LANGUE,          2#00000110).
-define(FRANCAIS,        2#00000000).
-define(ANGLAIS,         2#00000010).
-define(TYPE_CARTE,      2#00011000).
-define(JETABLE,         2#00000000).
-define(EVOLUTIVE,       2#00001000).
-define(MOBICARTE,       2#00010000).
-define(TYPE_NUM,        2#00100000).
-define(SVI,             2#00000000).
-define(NG,              2#00100000).
-define(PLAN,            2#11000000).
-define(RECHARGE1H,      2#00000000).
-define(CLASSIQUE,       2#01000000).
-define(JOUR,            2#10000000).
-define(SOIRETWE,        2#11000000).

%% Etats principaux
-define(ETAT_PRINCIPAL,  16#00005BB7).    %% Masque etat principal
-define(CETAT_TE,        16#00000001).
-define(CETAT_PH,        16#00000002).
-define(CETAT_DE,        16#00000004).
-define(CETAT_VA,        16#00000010).
-define(CETAT_AC,        16#00000020).
-define(CETAT_PE,        16#00000080).
-define(CETAT_EP,        16#00000100).
-define(CETAT_RE,        16#00000200).
-define(CETAT_SS,        16#00000800).
-define(CETAT_SR,        16#00001000).
-define(CETAT_SI,        16#00004000).

%% Etats secondaires
-define(ETATS_SEC,       16#07FFA448).      %% Masque etats secondaires
-define(CETAT_PT,        16#00000008).
-define(CETAT_TR,        16#00000040).
-define(CETAT_RC,        16#00000400).
-define(CETAT_ID,        16#00002000).
-define(CETAT_SU,        16#00008000).
-define(CETAT_AR,        16#00010000).
-define(CETAT_TX,        16#00020000).
-define(CETAT_TS,        16#00040000).
-define(CETAT_CV,        16#00080000).
-define(CETAT_CF,        16#00100000).
-define(CETAT_FO,        16#00200000).
-define(CETAT_RA,        16#00400000).
-define(CETAT_RS,        16#00800000).
-define(CETAT_RI,        16#01000000).
-define(CETAT_MA,        16#02000000).
-define(CETAT_TI,        16#04000000).


-define(OK,              2#00000001).
-define(DECLARE,         2#00000010).
-define(NONIDENTIFIE,    2#00000100).
-define(PERIME,          2#00001000).
-define(EPUISE,          2#00010000).
-define(SURSITAIRE,      2#00100000).
-define(SUSPENDU,        2#01000000).
-define(RESILIE,         2#10000000).

-define(REC_STANDARD,  1).
-define(REC_PROMO,     2).
-define(REC_INTENSIVE, 3).

-define(COURSEURO, 6.55957).
