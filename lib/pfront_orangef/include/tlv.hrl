%% +deftype tlv_config() =
%%     #tlv_config { method::connect_method()
%% 		   }.

-record(tlv_config, {method}).


%% +deftype connect_method() =
%%     {x25, Options::string(), Addr::string()}      % Linux X.25 API
%%   | {fsx25, Options::string(), Addr::string()}    % FarSite card driver
%%   | {erlang_process, Global_name::atom()}.

%%%% TLV Parameters.
-define(INV_NULL,4294967295).
-define(VERSION,1).
-define(NO_CLIENT,9).
-define(DEBUT,255).
-define(Val_ACI_NUM,-2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   HEADER                           %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Appli
-define(id_all,0).
-define(id_mobi,1).
-define(id_cmo,2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   PROCEDURE                           %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% request type
-define(int_id01,11).
-define(int_id02,12).
-define(int_id03,13).
-define(int_id04,14).
-define(int_id05,15).
-define(int_id06,16).
-define(int_id07,17).
-define(int_id08,18).
-define(int_id09,19).
-define(int_id10,20).
-define(int_id11,21).
-define(int_id12,22).
-define(int_id13,23).
-define(int_id14,24).
-define(int_id15,25).
-define(int_id16,26).
-define(int_id17,27).
-define(int_id18,28).
-define(int_id19,29).
-define(int_id20,30).
-define(int_id21,31).
-define(int_id22,32).
-define(int_id23,33).
-define(int_id24,34).
-define(int_id27,37).
-define(PROC,10).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   PARAMETRE                           %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% param type
-define(PS_NAME,                   1).
-define(PS_ROW,                    2).
-define(PS_TINY,                   3).
-define(PS_INT,                    4).
-define(PS_SMALL,                  5).
-define(PS_CHAR,                   6).
-define(PS_NUM,                    7).
-define(PS_STATUS,                 8).
-define(TLV_STATUT_CR,             9).
-define(PS_STRING,                10).

-define(ACI_NUM,                  20).
-define(ADV_NUM,                  21).
-define(COLONNE_FILTRE,           22).
-define(COLONNE_TRI,              23).
-define(CPP_CUMUL_CREDIT,         24).
-define(CPP_DATE_CREA,            25).
-define(CPP_DATE_LV,              26).
-define(CPP_DATE_MODIF,           27).
-define(ENC_VALEUR,               28).
-define(CPP_SOLDE,                29).
-define(DCL_NUM,                  30).
-define(DIRECTION,                31).
-define(DOS_ABONNEMENT,           32).
-define(DOS_CUMUL_MOIS,           33).
-define(DOS_DATE_ACTIV,           34).
-define(DOS_DATE_CREATION,        35).
-define(DOS_DATE_DER_REC,         36).
-define(DOS_DATE_LV,              37).
-define(DOS_ID,                   38).
-define(DOS_IMEI,                 39).
-define(DOS_IMSI,                 40).
-define(DOS_MONTANT_REC,          41).
-define(DOS_MSISDN,               42).
-define(DOS_NSCE,                 43).
-define(DOS_NUMID,                44).
-define(DOS_PLAFOND_REC,          45).
-define(DOS_TYPE,                 46).
-define(ECP_LIBELLE,              47).
-define(ECP_NUM,                  48).
-define(EPR_NUM,                  49).
-define(ESC_NUM,                  50).
-define(ESC_NUM_BIN,              51).
-define(ETT_LIBELLE,              52).
-define(ETT_NUM,                  53).
-define(HST_DATE,                 54).
-define(HST_DUREE,                55).
-define(HST_INFOS,                56).
-define(HST_MONTANT,              57).
-define(HST_SOLDE,                58).
-define(KIT_NUM,                  59).
-define(LNG_NUM,                  60).
-define(NB_LIGNE,                 61).
-define(NUM_COURT,                62).
-define(NUMERO_APPEL,             63).
-define(NUMERO_COURT,             64).
-define(OFR_LIBELLE,              65).
-define(OFR_NUM,                  66).
-define(OPD_NUM,                  67).
-define(OPT_DATE_DEB_VALID,       68).
-define(OPT_DATE_FIN_VALID,       69).
-define(OPT_DATE_SOUSCR,          70).
-define(OPT_DUREE_NUM,            71).
-define(OPT_INFO1,                72).
-define(OPT_INFO2,                73).
-define(OPT_INFO3,                74).
-define(OPT_INFO4,                75).
-define(OPT_INFO5,                76).
-define(OPT_INFO6,                77).
-define(PCT_MONTANT,              78).
-define(PCT_NBJOUREX,             79).
-define(PLA_LIBELLE,              80).
-define(PLA_MONTANT,              81).
-define(PLA_NUM,                  82).
-define(POSITION,                 83).

-define(PSC_LIBELLE,              91).
-define(PSC_NUM,                  92).
-define(PTF_NUM,                  93).
-define(REC_ID,                   94).
-define(REC_NE,                   95).
-define(REC_TYPE,                 96).
-define(RNV_NUM,                  97).
-define(TCD_NUM,                  98).
-define(TCD_LIBELLE,              99).
-define(TCK_DATE_ETAT,           100).
-define(TCK_DATE_LIMITE,         101).
-define(TCK_NE,                  102).
-define(TCK_NSCR,                103).
-define(TCK_NSTE,                104).
-define(TCP_LIBELLE,             105).
-define(TCP_MONTANT_INITIAL,     106).
-define(TCP_NUM,                 107).
-define(TOP_LIBELLE,             108).
-define(TOP_NUM,                 109).
-define(TRB_NUM,                 110).
-define(TTK_LIBELLE,             111).
-define(TTK_NUM,                 112).
-define(TYPE_COMPTE,             113).
-define(TYPE_OPERATION,          114).
-define(TYPE_PRESTATION,         115).
-define(TYPE_REPONSE,            116).
-define(UNT_LIBELLE,             117).
-define(UNT_NUM,                 118).
-define(UTL_DATE,                119).
-define(UTL_DOSSIER,             120).
-define(VALEUR_FILTRE,           121).
-define(TRC_NUM,                 123).



