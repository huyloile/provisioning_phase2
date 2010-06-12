-module(dico_tlv).
-include("../include/tlv.hrl").
-export([dico/1]).

%% +type dico(Tag::integer()) -> string | int | short | dcb | octet.

dico(?PS_NAME)->
    string;
dico(?PS_ROW)->
    string;
dico(?PS_TINY)->
    octet;
dico(?PS_INT)->
    int;
dico(?PS_SMALL)->
    short;
dico(?PS_CHAR)->
    string;
dico(?PS_NUM)->
    dcb;
dico(?PS_STATUS)->
    int;
dico(?TLV_STATUT_CR)->
    octet;
dico(?PS_STRING)->
    string;
dico(?ACI_NUM)->
    int;
dico(?ADV_NUM)->
    octet;
dico(?COLONNE_FILTRE)->
    octet;
dico(?COLONNE_TRI)->
    octet;
dico(?CPP_CUMUL_CREDIT)->
    int;
dico(?CPP_DATE_CREA)->
    int;
dico(?CPP_DATE_LV)->
    int;
dico(?CPP_DATE_MODIF)->
    int;
dico(?CPP_SOLDE)->
    int;
dico(?DCL_NUM)->
    octet;
dico(?DIRECTION)->
    octet;
dico(?DOS_ABONNEMENT)->
    dcb;
dico(?DOS_CUMUL_MOIS)->
    int;
dico(?DOS_DATE_ACTIV)->
    int;
dico(?DOS_DATE_DER_REC)->
    int;
dico(?DOS_DATE_LV)->
    int;
dico(?DOS_ID)->
    string;
dico(?DOS_IMEI)->
    string;
dico(?DOS_IMSI)->
    string;
dico(?DOS_MONTANT_REC)->
    int;
dico(?DOS_MSISDN)->
    string;
dico(?DOS_NSCE)->
    string;
dico(?DOS_NUMID)->
    int;
dico(?DOS_PLAFOND_REC)->
    int;
dico(?DOS_TYPE)->
    octet;
dico(?ECP_LIBELLE)->
    string;
dico(?ECP_NUM)->
    octet;
dico(?ENC_VALEUR)->
    int;
dico(?EPR_NUM)->
    octet;
dico(?ESC_NUM)->
    short;
dico(?ESC_NUM_BIN)->
    int;
dico(?ETT_LIBELLE)->
    string;
dico(?ETT_NUM)->
    octet;
dico(?HST_DATE)->
    int;
dico(?HST_INFOS)->
    string;
dico(?HST_MONTANT)->
    int;
dico(?HST_SOLDE)->
    int;
dico(?KIT_NUM)->
    octet;
dico(?LNG_NUM)->
    octet;
dico(?NB_LIGNE)->
    octet;
dico(?NUM_COURT)->
    octet;
dico(?NUMERO_APPEL)->
    octet;
dico(?NUMERO_COURT)->
    octet;
dico(?OFR_LIBELLE)->
    string;
dico(?OFR_NUM)->
    octet;
dico(?OPD_NUM)->
    octet;
dico(?OPT_DATE_DEB_VALID)->
    int;
dico(?OPT_DATE_FIN_VALID)->
    int;
dico(?OPT_DATE_SOUSCR)->
    int;
dico(?OPT_DUREE_NUM)->
    int;
dico(?OPT_INFO1)->
    string;
dico(?OPT_INFO2)->
    string;
dico(?OPT_INFO3)->
    string;
dico(?OPT_INFO4)->
    string;
dico(?OPT_INFO5)->
    string;
dico(?OPT_INFO6)->
    string;
dico(?PCT_MONTANT)->
    int;
dico(?PCT_NBJOUREX)->
    int;
dico(?PLA_LIBELLE)->
    string;
dico(?PLA_MONTANT)->
    int;
dico(?PLA_NUM)->
    octet;
dico(?POSITION)->
    string;

dico(?PSC_LIBELLE)->
    string;
dico(?PSC_NUM)->
    short;
dico(?PTF_NUM)->
    octet;
dico(?REC_ID)->
    dcb;
dico(?REC_NE)->
    int;
dico(?REC_TYPE)->
    octet;
dico(?RNV_NUM)->
    octet;
dico(?TCD_NUM)->
    octet;
dico(?TCD_LIBELLE)->
    string;
dico(?TCK_DATE_ETAT)->
    int;
dico(?TCK_DATE_LIMITE)->
    int;
dico(?TCK_NE)->
    octet;
dico(?TCK_NSCR)->
    dcb;
dico(?TCK_NSTE)->
    dcb;
dico(?TCP_LIBELLE)->
    string;
dico(?TCP_MONTANT_INITIAL)->
    int;
dico(?TCP_NUM)->
    octet;
dico(?TOP_LIBELLE)->
    string;
dico(?TOP_NUM)->
    octet;
dico(?TRB_NUM)->
    int;
dico(?TTK_LIBELLE)->
    string;
dico(?TTK_NUM)->
    octet;
dico(?TYPE_COMPTE)->
    octet;
dico(?TYPE_OPERATION)->
    octet;
dico(?TYPE_PRESTATION)->
    octet;
dico(?TYPE_REPONSE)->
    octet;
dico(?UNT_LIBELLE)->
    string;
dico(?UNT_NUM)->
    octet;
dico(?UTL_DATE)->
    int;
dico(?UTL_DOSSIER)->
    dcb;
dico(?VALEUR_FILTRE)->
    string;
dico(?TRC_NUM) ->
    int.
