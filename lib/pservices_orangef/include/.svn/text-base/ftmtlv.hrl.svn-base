%%%% FTM SDP constants

%% +deftype sdp_user_state() =
%%     #sdp_user_state{     msisdn     :: msisdn(),
%%                          dos_numid  :: integer(),
%%                          imsi       :: imsi(),
%%                          declinaison:: string(),
%%                          langue     :: langue(),
%%                          dlv        :: unix_time(),
%%                          d_activ    :: unix_time(),
%%                          d_der_rec  :: unix_time(), %% date dernier rechg mobi
%%                          etat_princ :: integer(),
%%                          etats_sec  :: integer(),
%%                          option     :: integer(),
%%                          cpte_princ :: compte(),
%%                          cpte_list  :: [{atom(),compte()}],
%%                          malin      :: msisdn(),     %% suppressed in CSL_DOSCP
%%                          acces      :: unix_time(),  %% suppressed in CSL_DOSCP
%%                          dtmn       :: unix_time(),  %% suppressed in CSL_DOSCP
%%%% Added parameters in CSL_DOSCP
%%                          nsce       :: string(),
%%                          abonn_cmo  :: string()
%%                          kit_num    :: string(),
%%                          d_creation :: unix_time(),
%%                          d_chg_etat :: unix_time(),
%%                          err_rechg  :: integer(),
%%                          imei       :: string(),
%%                          ofr_num    :: string(),
%%                          code_rechg :: string(),
%%                          cumul_mois :: string(),
%%                          plaf_rechg :: string(),
%%                          mnt_rechg  :: string(),
%%                          d_der_rec_cmo:: string(),
%%                          d_deb_fidel:: string(),
%%                          bon_pct_fid:: string(),
%%%%
%%                          tmp_recharge :: integer(),
%%                          tmp_code   :: integer(),
%%                          tmp_smsinfo_offer :: integer(),
%%                          tmp_ptfnum :: term(),
%%                          tmp_options:: term(),
%%                          tmp_promo  :: term(),
%%                          mmsinfos   :: term(),
%%                          o2o_data   :: record(),
%%                          opt_activ  :: record(),
%%                          numero_prefere::record(),
%%                          topNumList :: [integer()],
%%                          options :: [{integer(),atom()}],
%%                          spider :: undefined | spider_response(),
%%                          c_op_opt_info2 :: integer(),
%%                          c_op_opt_date_souscr :: string(),
%%                          c_op_opt_date_deb_valid :: unix_time(),
%%                          refill_amount :: integer(),
%%                          transfert_credit :: {integer(), msisdn(),
%%                          numero_sms_illimite ::  msisdn(),
%%                          numero_st_valentin ::  msisdn()}
%%%% for o2o_data, see one2one.hrl

-record(sdp_user_state, {msisdn, 
			 dos_numid, 
			 imsi, 
			 declinaison,  
			 langue, 
			 dlv,        % date validite etat au format unix
			 d_activ,
			 d_der_rec,
			 etat_princ, 
			 etats_sec,
			 option,
			 cpte_princ,
			 cpte_list,
			 malin,     %% suppressed in CSL_DOSCP
			 acces,     %% suppressed in CSL_DOSCP
			 dtmn,      %% suppressed in CSL_DOSCP
                         nsce,
                         abonn_cmo,
                         kit_num,
                         d_creation,
                         d_chg_etat,
                         err_rechg,
                         imei,
                         ofr_num,
                         code_rechg,
                         cumul_mois,
                         plaf_rechg, 
                         mnt_rechg,
                         d_der_rec_cmo,
                         d_deb_fidel,
                         bon_pct_fid,
			 tmp_recharge,
			 tmp_code,  %% code de rechargement
			 tmp_smsinfo_offer,
			 tmp_ptfnum,
			 tmp_options,
			 tmp_promo,
			 mmsinfos,
			 o2o_data,
			 opt_activ,
			 numero_prefere,
			 numpref_list,
                         c_no_prefere,
			 topNumList,
			 options,
                         spider,
                         sachem_available,
			 c_op_opt_info2,
			 c_op_opt_date_souscr,
			 c_op_opt_date_deb_valid,
			 refill_amount,
			 transfert_credit,
			 numero_kdo_illimite,
			 numero_sms_illimite,
			 numero_st_valentin}).
%% +deftype godet() = atom().
%%%% atom représentant l'un des comptes de la structure ci-dessus.
%% +deftype godet_str() = string().
%%%% String représentant le nom d'un des comptes de la structure ci-dessus.

%% +deftype compte() =
%%     #compte{             tcp_num    :: integer(),
%%                          unt_num    :: integer(),
%%                          cpp_solde  :: integer() | curency(),
%%                          dlv        :: unix_time(),
%%                          rnv        :: integer(),
%%                          etat       :: integer(),
%%                          ptf_num    :: integer(),
%%                          cpp_cumul_credit :: integer() | currency(),
%%                          pct:: integer(),
%%                          anciennete::integer(),
%%                          mnt_init :: currency() | integer(),
%%                          top_num  :: integer(),
%%                          mnt_bonus:: currency() | integer()},
%%                          d_crea   :: string(),
%%                          d_modif  :: string(),
%%                          cpt_dest :: string(),
%%                          dlv_type :: string(),
%%                          opt_tcp  :: string()
%%                          ctrl_sec :: string()}
-record(compte, {tcp_num, %% type de compte
		 unt_num, %% unité utilisée
		 cpp_solde,
		 dlv,     %% date de validité
		 rnv,
		 etat,
		 ptf_num, %% plan tarifaire
		 cpp_cumul_credit,
		 pct,
		 anciennete,
		 mnt_init,
		 top_num,
		 mnt_bonus,
                 d_crea,
                 d_modif,
                 cpt_dest,
                 dlv_type,
                 opt_tcp,
                 ctrl_sec %% controle ou pas sur les etats secondaires
                }).

%% +deftype numero_prefere() =
%%     #numero_prefere{numero      :: string(),     %% no mobile ou fixe
%%                     numprefp:: bool()}.       %% etat de l'option payante
-record(numero_prefere,
	{ numero,
	  numprefp}).

%% +deftype opt_act_mobi()= visio.

%% +deftype activ_opt_mobi() =
%%     #activ_opt_mobi{ 
%%     en_cours   :: opt_act_mobi(),
%%     list       :: [ocf_option()]}.
-record(activ_opt_mobi,{en_cours,
			list}).

%% +deftype ratio() =
%%     #ratio{
%%                key::   {DCL_NUM::integer(),TCP_NUM::integer(),
%%                         PTF_NUM::integer(),UNT_NUM::integer()},
%%                ratio:: integer()}.      
-record(ratio, {key, ratio}).

%%% Record use for OPT_SMS_200_VIRGIN_CBrangef Game Instant Gagnant.
%%% A mnesia table with same name is created in
%%% order to retrieve date et presents for winners.

%% +deftype refill_game() =
%%     #refill_game{
%%         winning_date  :: unixtime(),
%%         winnings  :: string()|atom(),
%%         winnings_state :: bool(),
%%         winning_msisdn :: string()|atom()
%%     }.

-record(refill_game,{winnings_date = undefined,
		     winnings      = undefined,
		     winnings_state= false,
		     winning_msisdn= undefined}).

%%% Record use for Orangef Game Instant Gagnant.
%%% A mnesia table with same name is created in
%%% order to retrieve date et specific presents
%%% named LOGO.

%% +deftype logo_table() =
%%     #logo_table{
%%         winning_date  :: unixtime(),
%%         winnings_state :: bool(),
%%         winning_msisdn :: string()|atom()
%%     }.

-record(logo_table,{winnings_date     = undefined,
		    daily_winnings_nb = 3220}).


-define(RATIO,ratio).
-define(REFILL_GAME,refill_game).
-define(LOGO_TABLE,logo_table).

%% +deftype sub_of() = cmo | mobi | bzh_gp | bzh_cmo | omer | tele2_gp 
%%                         | postpaid | dme | anon. 
-define(OFFSET_TZ,0).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% define use for compatibility TLV and SDP Values
%% +deftype monnaie() = 2#00000000 | 2#00000001.
-define(MONNAIE,         2#00000001).

%% +deftype unt_rest()= franc|euro|sec|mms|sms|ko|min.
%% +deftype unt_num()=  1|2|3|4|5|6.
-define(FRANC,          0).
-define(EURO,           1).
-define(SEC,            2).
-define(MMS,            3).
-define(SMS,            4).
-define(KO,             5).
-define(MIN,            6).
-define(MO,             7).
-define(SMS_P,          8). %% SMS Plein
-define(MIN_P,          9). %% Min en heure pleine
-define(NBAPPELS,      10).
%% +deftype langue() = 0 | 1.
-define(FRANCAIS,        0).
-define(ANGLAIS,         1).


-define(RATIO_FOOT_SOIREE, 3).
-define(RATIO_M6_SOIREE, 2).

-define(ALL_SUBSCRIPTIONS,
	[
	 %%Orange France
	 mobi,
	 cmo,
	 postpaid,
	 dme,
	 %% Omer / Breizh
	 omer,
	 bzh_cmo,
	 bzh_gp,
	 %% MVNOs
	 carrefour_prepaid,
	 carrefour_comptebloque,
	 monacell_prepaid,monacell_comptebloque,leo_gourou,
	 nrj_comptebloque,nrj_prepaid,
	 opim,
	 symacom,
	 tele2_pp,
	 tele2_comptebloque,
	 ten_postpaid,
	 ten_comptebloque,
	 virgin_prepaid,
	 virgin_comptebloque,
	 virgin_postpaid,
	 %% anonymous
	 anon]).

%% +deftype dcl_num() = integer(). 
%%%%     DCL_NUM
%%%%     When a new DCL_NUM has to be added, please update svc_util_of:declinaison()
-define(mobi,          0).
-define(ppola,         1).  %OLAN
-define(ppol3,         2).  %CMO 1h 20E
-define(ppolc,         3).  %CMO Forfaits HC
-define(cpdeg,         4).
-define(ppol1,         5).  %CMO 1h 18E
-define(ppol2,         6).  %CAPRI
-define(pmu,           7).  %CMO Plug Multi Usage
-define(fmu_18,        8).  %forfait Multi 18 Euros
-define(fmu_24,        9).  %forfait Multi 24 Euros
-define(cmo_sl,        10). %Multimedia Kiwi
-define(omer,          11). %bzh MOBI
-define(bzh_cmo,       12).
-define(zap_cmo,       13).
-define(m6_cmo,        14).
-define(cmo_sl_apu,    15).
-define(bzh_cmo2,      16).
-define(DCL_BZH_CB1,   59).
-define(DCL_BZH_CB2,   62).
-define(DCL_BZH_CB3,   63).
-define(DCL_BZH_CB4,   64).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE1, 17).
-define(m6_cmo2,       18).
-define(DCLNUM_VIRGIN_PREPAID,       19).
-define(tele2_pp,      20).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE2, 21).
-define(m6_cmo3,       22).
-define(m6_cmo4,       23).
-define(big_cmo,       24).
-define(ppol4,         25).%CMO 1h 15E
-define(tele2_cb3,     26).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE3, 27).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE4, 28).
-define(DCLNUM_CARREFOUR_PREPAID, 29).
-define(DCLNUM_MONACELL_PREPAID, 36).
-define(m6_cmo_1h,     30).
-define(m6_cmo_1h20,   31).
-define(m6_cmo_1h40,   32).
-define(m6_cmo_2h,     33).
-define(m6_cmo_3h,     95).
-define(m6_cmo_20h_8h, 97).
-define(mobi_new,      34).
-define(m6_prepaid,    35).
-define(tele2_cb,      37).
-define(ten_cb,        38).
-define(RC_LENS_mobile,39).
-define(ASSE_mobile,   40).
-define(OL_mobile,     41).
-define(OM_mobile,     42).
-define(PSG_mobile,    43).
-define(BORDEAUX_mobile,44).
-define(CLUB_FOOT,      87).
-define(tele2_cb2,     45).
-define(ten_cb2,       46).
-define(zap_cmo_v2,    47).
-define(zap_cmo_18E,   48). %%Zap CMO 1h
-define(zap_cmo_20E,   49).
-define(zap_cmo_25E,   50). %%Zap CMO 1h30
-define(click_mobi,    51).
-define(m6_cmo_2h30,   52).
-define(tele2_pp2,     53).
-define(casino_pp,     54).
-define(parent_cmo,    55).
-define(m6_cmo_1h_v2,  56).
-define(m6_cmo_1h30_v2,57).
-define(m6_cmo_2h_v2,  58).
-define(m6_cmo_1h_v3,  82).
-define(m6_cmo_1h30_v3,83).
-define(m6_cmo_2h_v3,  84).
-define(m6_orange_fixe_1h, 96). %%SL M6 Orange&Fixe 1h
-define(DCLNUM_VIRGIN_COMPTEBLOQUE5, 60).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE6, 61).
-define(B_phone,       65).
-define(decl_symacom,  66).
-define(nrj_pp,        67).
-define(nrj_cb,        68).
-define(nrj_cb1,        90).
-define(nrj_cb2,        91).
-define(nrj_cb3,        92).
-define(nrj_cb4,        93).
-define(nrj_cb5,       125).
-define(nrj_cb6,       126).
-define(nrj_cb7,       127).
-define(m6_cmo_1h_sl,  69).
-define(umobile,       70).
-define(zap_vacances,  71).
-define(m6sample,      72).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE7,  73).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE8,  74).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE9,  75).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE10, 76).
-define(DCLNUM_CARREFOUR_CB1,         77).
-define(DCLNUM_CARREFOUR_CB2,         78).
-define(DCLNUM_CARREFOUR_CB3,         79).
-define(internet_everywhere,          80).
-define(DCLNUM_BREIZH_PREPAID,        85).

-define(zap_cmo_1h30_ill, 86).
-define(zap_cmo_1h_v2, 88).  %% Zap CMO 1h v2 (dcl num v1=49)
-define(zap_cmo_1h30_v2, 89).  %% Zap CMO 1h30 v2 (dcl num v1=50)
-define(FB_M6_1H_SMS,    98).  %% FB M6 1h SMS 19,99E
-define(FB_M6_1H30,      99).  %% FB M6 1h30 25,99E

-define(cmo_smart_40min, 100).
-define(rsa_cmo,        101).
-define(sl_blackberry_1h, 102).
-define(m6_cmo_ete,     103). %% Nouveau forfait bloque serie limitee M6 de l'ete
-define(DCLNUM_VIRGIN_COMPTEBLOQUE11,        104).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE12,        105).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE13,        106).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE14,        107).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE15,        108).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE16,        109).
-define(mobi_janus,                          110).   
-define(zap_cmo_1h_unik,                     111).   
-define(DCLNUM_MONACELL_COMPTEBLOQUE_40MIN,  112).
-define(DCLNUM_MONACELL_COMPTEBLOQUE_1H,     113).
-define(DCLNUM_VIRGIN_PREPAID2,              114).
-define(DCLNUM_ADFUNDED,                     115).
-define(m6_cmo_onet_1h_20E,                  116).
-define(m6_cmo_onet_1h_27E,                  117).
-define(m6_cmo_onet_2h_30E,                  118).
-define(m6_cmo_fb_1h,                        121).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE17,        122).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE18,        123).
-define(DCLNUM_CMO_SL_ZAP_1h30_ILL,          128).
-define(cmo_smart_1h,                        129).
-define(cmo_smart_1h30,                      130).
-define(cmo_smart_2h,                        131).
-define(DCLNUM_VIRGIN_COMPTEBLOQUE19,        132). %% Nouveau FB Virgin PC Feb 10
-define(DCLNUM_VIRGIN_COMPTEBLOQUE20,        133). %% Nouveau FB Virgin PC Feb 10
-define(DCLNUM_CARREFOUR_CB4,                134).
-define(DCLNUM_CARREFOUR_CB5,                135).
-define(DCLNUM_CARREFOUR_CB6,                136).
-define(DCLNUM_EDITION_QUIKSILVER,           144). %% Nouveau FB Edition Speciale Quiksilver PC June 10
-define(DCLNUM_VIRGIN_COMPTEBLOQUE24,        146). %% Nouveau FB Virgin PC Jun 10
-define(DCLNUM_VIRGIN_COMPTEBLOQUE25,        147). %% Nouveau FB Virgin PC Jun 10
-define(DCLNUM_VIRGIN_COMPTEBLOQUE26,        148). %% Nouveau FB Virgin PC Jun 10
-define(DCLNUM_VIRGIN_COMPTEBLOQUE27,        149). %% Nouveau FB Virgin PC Jun 10

%% Etats principaux - Val du PCS - Ref SACPF01 
-define(ETAT_VA,        1). % compte valide
-define(ETAT_AC,        2). % compte active
-define(ETAT_SI,        3). 
-define(ETAT_SF,        4).
-define(ETAT_SV,        5).
-define(ETAT_SA,        6).
-define(ETAT_SR,        7).
-define(ETAT_RA,        8).
-define(ETAT_RO,        9).
-define(ETAT_TR,        10).

%% Etats Secondaire - Ref SACPF01 
-define(SETAT_ID,       2#0000000000000001). %% Identifié:1
-define(SETAT_TE,       2#0000000000000010). %% Test: 2
-define(SETAT_RC,       2#0000000000000100). %% Rechargé:4
-define(SETAT_SM,       2#0000000000001000). %% SMS: 8
-define(SETAT_BS,       2#0000000000010000). %% Barré SMS: 16
-define(SETAT_PT,       2#0000000000100000). %% Plan tarifaire: 32

-define(SETAT_MG,       2#0000000010000000). %% Montée en Gamme: 128
-define(SETAT_NP,       2#0000000100000000). %% Numéros Préférés: 256
-define(SETAT_GP,       2#0000001000000000). %% GPRS: 512
-define(SETAT_BG,       2#0000010000000000). %% Barré GPRS 1024
-define(SETAT_P2,       2#0000100000000000). %% Plan tarifiare 2
-define(SETAT_PR,       2#0001000000000000). %% Promo 1errechargment
-define(SETAT_AT,       2#0010000000000000). %% auto-transferer vers prepaye
-define(SETAT_DE,       2#0100000000000000). %% descendu de gamme

-define(SETAT_CB,  2#100000000000000000000). %% rechargement CB : 1048576

-define(SETAT_LS, 2#100000000000000000000000000000). %% mobicarte en libre service

%%%% Options - ref SACPF01 tableau TYPE_OPTION 
-define(OETAT_MV,     2#00000000000000000000001).  %% Mess Vocal
-define(OETAT_OF,     2#00000000000000000000010).  %% Orange SF
-define(OETAT_TR,     2#00000000000000000000100).  %% Tribu
-define(OETAT_MA,     2#00000000000000000001000).  %% Malin/Mon Num Prf
-define(OETAT_IN,     2#00000000000000000010000).  %% Num pref
-define(OETAT_MN,     2#00000000000000000100000).  %% SMS Infos
-define(OETAT_EUROPE, 2#00000000000000001000000).  %% Option Europe
-define(OETAT_BO,     2#00000000000000010000000).  %% Temps en plus

-define(OETAT_SX,     2#00000000000000100000000). %%SMS X
-define(OETAT_SY,     2#00000000000001000000000). %%SMS Y : forfait 30 SMS
-define(OETAT_KI,     2#00000000000010000000000). %%KIWI <-> OSL
-define(OETAT_M1,     2#00000000000100000000000). %%Multimedia 0,5Mo/45mn
-define(OETAT_M2,     2#00000000001000000000000). %%Multimedia 5Mo/5h
-define(OETAT_M3,     2#00000000010000000000000). %%Multimedia 10Mo/10h
-define(OETAT_SM,     2#00000000100000000000000). %%Messages 12,09
-define(OETAT_OW2,    2#00000001000000000000000). %%Or World 2

-define(OETAT_OW3,    2#00000010000000000000000). %%Or World 3
-define(OETAT_VWE,    2#00000100000000000000000). %%Vx Week end
-define(OETAT_VOYAGE, 2#00001000000000000000000). %% voyage
-define(OETAT_MAGHREB,2#00010000000000000000000). %% Maghreb
-define(OETAT_MME,    2#00100000000000000000000). %%Message Mercredi
-define(OETAT_DWE,    2#01000000000000000000000). %%Data Week  end
-define(OETAT_DME,    2#10000000000000000000000). %%Data Mercredi
%% 17-30.
-define(OETAT_CB,     2#01000000000000000000000000000000).

%%%% Etats Compte - ECP_NUM
-define(CETAT_AC,       1).
-define(CETAT_EP,       2).
-define(CETAT_PE,       3).

%%%% Type Compte  - TCP_NUM
-define(C_PRINC,        1).
-define(C_JINF_VOIX,    2).
-define(C_WAP,          3).
-define(C_SMS,          4).
-define(C_FORF_PMU,     5). %%CMO PMU
-define(C_FORF,         6).
-define(C_FORF_SMS,     7).
-define(C_KDO,          8).
-define(C_FORF_WEBWAP,  9). %%CMO PMU
-define(C_FORF_WAP,     10).
-define(C_SMSX,         11).
-define(C_SMSY,         12).
-define(K_WAP,          13). %% OSL Durée
-define(K_GPRS,         14). %% OSL Volume
-define(C_VOIX,         15). %% Godet voix plug
-define(P_VOIX,         16).
%% Promo noel godet 100SMS
-define(C_SMS_NOEL,     17).
-define(P_WAP,          18).
-define(C_AEUROS,       20).
-define(C_AVOIX,	21).%% C_AVOIX en euros // Spécial Vancaces - Roaming entrant 
-define(C_ASMS,         22). 
-define(C_AWAP,         23).%% en euros
-define(C_NUM_PREF,     24).%% cpte numéro préféré
-define(C_FORF_HC,      25).%% Forfait HC
-define(C_ORANGEX,      26).%% Godet Option Orange-X
-define(C_FORF_FMU_18,  27).%% Forfait Plug Mult Usages 18E
-define(C_FORF_FMU_24,  28).%% Forfait Plug Mult Usages 20E
-define(C_FORF_CMOSL,   29).%% Forfait CMO Série Limitée
-define(C_ESP_VOIX,     30).%% Espadons Voix 
-define(C_ESP_MUL,      31).%% Espadons Multimedia
-define(C_ESP_SMS,      32).%% Espadons SMS/MMS
-define(C_RDL_VOIX,     33).%% RDL Voix 
-define(C_RDL_MUL,      34).%% RDL Multimedia
-define(C_RDL_SMS,      35).%% RDL SMS/MMS
-define(C_RDL_VOIX_MOBI,36).%% RDL Voix
-define(C_WE_VOIX,      36).%% Weekend voix
-define(C_FORF_SMS_PROMO,37).
-define(C_RDL_SMS_MOBI, 37).%% RDL SMS/MMS
-define(C_RDL_WAP,      38).%% Godet pour l'option Orange World
-define(C_FORF_BZH,     39).%% forfait Bzh CMO
-define(C_VOIX_ZAP,     40).%% forfait voix ZAP CMO
-define(C_FORF_MU_M6,   41).%% Forfait Multi M6
-define(C_SURPRISE_VOIX,42).
-define(C_DUO_JOURNEE, 144).
-define(TCPNUM_PACKNOEL,43).
-define(C_FORF_CMOSLAPU,45).%% Forf CMO Série Limitée avec appels à prix unique
-define(C_FORF_BZH2,    46).
-define(C_FORF_VIRGIN1, 47). %% Forfait Virgin CB1
-define(C_FORF_MU_M6_V2,   48).%% Forfait Multi M6 version 2
-define(C_OPT_VIRGIN_PP, 49). %%Compte Optionnel VIRGIN
-define(TCP_AFTERSCH_CMO,  51).
-define(TCP_AFTERSCH_MOBI, 52).
-define(C_E_RECHARGE,      53).
-define(C_EASY_VOICE,      55).
-define(C_BZH_CB1_4_FORF,  56).%% BZH Compte Bloques 1 à 4 - forfait
-define(C_BONS_PLANS,      59). %% Cpte Bons Plans PTF_NUM = 1
-define(C_JILLI_OW,        65).%% Journee OW Mobi 
                               %% et CMO,M6 et ZAP,ptf=41,top_num=142
-define(C_SMS_QUOTIDIEN,   66).
-define(C_ZAP_MMS,         67).
-define(C_OPT_M6_MMSMS_NET,68).%% Option M6 SMS/MMS on-net illimites
-define(C_FIVE_MIN,        71). %%Encore 5min 
-define(C_PROMO_BASE_SMS,  72).%% Promo base SMS, offres Janvier 2006
                              %% TOP_NUM=90, PTF_NUM=5
-define(C_FORF_VIRGIN2,    73). %% Forfait Virgin CB2
-define(C_OPTION_VIRGIN,   74).%% Options multi usages (1 à 4) de l'offre Virgin
-define(C_FORF_MU_M6_V3,   75).%% Forfait Multi M6 version 3,PTF_NUM =226
                               %% DCL_NUM = 22
-define(C_FORF_MU_M6_V4,   76).%% Forfait Multi M6 version 4,PTF_NUM =227
                               %% DCL_NUM = 23
-define(C_BIG_FORF_CMO,    77). %% GROS FORF CMO DCL_NUM=24
-define(C_2NUM_PREF,       78). %% 2 NUM Pref
-define(C_OW_DECO,         79). %% Decouverte OW CMO
-define(C_M5_KDO_VX_NET,   80). %% Kdo voix on net M5
-define(C_M5_KDO_VX_INTERNAT,81). %% Kdo voix international M5
-define(C_FORF_VIRGIN3,    82). %% Forfait Virgin CB3
-define(C_FORF_VIRGIN4,    83). %% Forfait Virgin CB4
-define(OPT_SMS_200_VIRGIN_CB, 138).%% Option 200 SMS Virgin CB
-define(OPT_SMS_200_BZH_CB, 138).%% Option 200 SMS Breizh CB
-define(OPT_SMS_ILL_VIRGIN_CB, 179).%% Option SMS Illimites Virgin CB
-define(C_M5_MNT_VOIX,     84).
-define(C_FORF_TELE2_CB3,  85).%% Forfait Tele2 CB3
-define(C_PASS_MTC,        86). %% Pass vacances MTC
-define(C_OPT_TV,          87). %% Option TV
-define(C_OPT_TOTAL_TV,    88). %% Option Total TV(ptf_num=41,top_num=111)
-define(C_SPORT,           89). %% Forfait Sport
-define(C_MUSIQUE,         90). %% Option Musique
-define(C_SURF,            91). %% Option Surf illimite
-define(C_ILLIMITE_KDO,    92). %% Option illimite KDO
-define(C_OFFERT,          93). %% Compte Tranfert de Credit
-define(C_M5_WE_VOIX_ILL,  94). %% Option M5 WE voix illimite
-define(C_PROMO_CONTENU,   95). %% Option 3 euros contenu
-define(C_WE_ILLIMITE_MMS, 96). %% Option 4 WE illimite MMS
-define(C_WE_ILLIMITE_SMS, 97). %% Option 4 WE illimite SMS
%% 4 forfaits M6 bloques illimites WE
-define(C_FORF_M6_MOB_1H_V3,181).
-define(C_FORF_M6_MOB_1H30_V3,182).
-define(C_FORF_M6_MOB_2H_V3,183).
-define(C_FORF_M6_MOB_1,   98). %% M6 Mobile 1h
-define(C_FORF_M6_MOB_1H20,99). %% M6 Mobile 1h20
-define(C_M5_20_SMS,       100).%% Option prime M5 20 SMS
-define(C_M5_VX_ROAMING,   101).%% Option prime M5 voix roaming
-define(C_FORF_M6_MOB_1H40,102).%% M6 Mobile 1h40
-define(C_FORF_M6_MOB_2,   103).%% M6 Mobile 2h
-define(C_FORF_M6_MOB_3,   228).%% M6 Mobile 3h
-define(C_FORF_M6_USAGES_COMMUNAULT,292). %% M6 Usages communault
-define(C_BZH_CB1_4_SMS,   104).%% BZH Compte Bloques 1 à 4 - cpte_sms
-define(C_3NUM_KDOSMS,     105).%% 3 numéros KDO SMS,ptf=41,top_num=132
-define(C_IKDO_VX_SMS,     106).%% Option illimite KDO voix + SMS
-define(C_SURF_MENSU,      107).%% Option surf avec renouvellement
-define(C_KDO_VOIX,        109).%% Illico serie limitee noel KDO voix
-define(C_BONUS_VOIX_SOIREE, 109).%% Illico serie limitee bonus voix soiree 15/01/2009
-define(C_KDO_SMS,         110).%% Illico serie limitee noel KDO SMS
-define(C_KDO_TV,          111).%% Illico serie limitee noel KDO TV
-define(C_MMS_MENSU,       112).%% Option MMS mensuelle
%For 5218 Godet sur PCM (PC Juin 09)
%-define(C_MMS_MENSU,       226).%% Option MMS mensuelle
-define(C_SL_7E,           113).%% Option serie limitee 7E
-define(C_UNIK_FIXE,       114).%% Option unik et fixe
-define(C_TS_RESEAUX,      115).%% Option 1h tous reseaux
-define(C_FORF_TELE2_CB1 ,  116).%% Forfait Tele2 CB1
-define(C_FORF_TEN_CB1,    117).%% Forfait Ten CB1
-define(C_MSN_MENSU_CMO,   119).%% Option OWL Mensuel CMO
-define(C_MSN_JOURNEE_CMO, 120).%% Option Journee OMWL CMO
-define(C_MSN_MOBI,        120).%% Option Journee et mensu OMWL MOBI
-define(C_MSN_OMWL_MOBI,   145).%% Option mensu OMWL MOBI
-define(C_50SMS_WINNING,   122).%% Instant Gagnant Game: 50SMS winning
-define(C_50SMS_WINNING_CMO,122).%% Instant Gagnant Game: 50SMS winning CMO
-define(C_FORF_TELE2_CB2,  123).%% Forfait Tele2 CB2
-define(C_FORF_TELE2_CB_25_SMS,  124).%% Option Tele2 25 SMS
-define(C_FORF_TELE2_CB_50_SMS,  125).%% Option Tele2 50 SMS
-define(C_FORF_TELE2_CB_100_SMS, 138).%% Option Tele2 100 SMS
-define(C_FORF_TELE2_CB_ILL_SMS, 179).%% Option Tele2 SMS ILLIMITES
-define(C_CARREFOUR_Z1,         126).%% Compte Carrefour Z1 = Europe
-define(C_CARREFOUR_Z2,         127).%% Compte Carrefour Z2 = Maghreb / Turquie / Amérique du Nord
-define(C_CARREFOUR_Z3,         128).%% Compte CarrefourZ3 = Monde
-define(C_FORF_TEN_CB2,         130).%% Forfait Ten CB2
-define(C_ROAMING_OUT,          140).%% Spécial Vancaces - Roaming sortant
-define(C_ROAMING_IN,           141).%% Spécial Vancaces - Roaming entrant
-define(C_FORF_TEN_CB_20_SMS,   131).%% Option Ten 20 SMS
-define(C_FORF_TEN_CB_50_SMS,   125).%% Option Ten 50 SMS
-define(C_FORF_ZAP_CMO_18E,     135).%% Cmo ZAP 18E
-define(C_FORF_ZAP_CMO_20E,     136).%% Cmo ZAP 20E
-define(C_FORF_ZAP_CMO_25E,     137).%% Cmo ZAP 25E
-define(C_FORF_ZAP_CMO_25E_v3,  139).%% Cmo ZAP 25E DCL=71
-define(C_FORF_TEN_CB_100_SMS,  138).%% Option Ten 100 SMS
-define(C_FORF_ODR,             143).%% Odr Bzh et Omer et VIRGIN
-define(C_DIXIT_BONS_PLANS,     147). %% Cpte Dixit Bons Plans
-define(C_OPT_SMS_ILL,          153). %% Cpte SMS ILLIM (journee+soiree)
-define(C_FORF_SMS_ILL,         155).%% Odr Bzh et Omer et VIRGIN
-define(C_FORF_SMS_ILL_CMO,     155).%% Opt 1 Numéro SMS Illimité
-define(C_FORF_NRJ_CB,          162).%% Compte Bloque NRJ
-define(C_FORF_NRJ_CB1,         168).%% Compte Bloque NRJ 90m
-define(C_FORF_NRJ_CB2,         169).%% Compte Bloque NRJ 120m
-define(C_FORF_NRJ_CB3,         209).%% Compte Bloque NRJ 30m
-define(C_FORF_NRJ_CB4,         218).%% Compte Bloque NRJ 45m
-define(C_FORF_NRJ_CB5,         312).%% Compte Bloque NRJ illimite
-define(C_NRJ_DATA_ILL,         313).%% Compte Bloque NRJ data illimitee
-define(C_NRJ_SMS_ILL,          285).%% Compte nrj prepaid/forfait sms illimites (for option double jeu pp)
-define(C_NRJ_PP_LIGHT,         284).%% Compte nrj prepaid light (for option nrj light)
-define(C_NRJ_PP_RESERVES_DAPPELS, 231).%% Compte nrj prepaid reserves d'appels
-define(C_NRJ_MINI_FF_VOIX,     342).
-define(C_NRJ_MINI_FF_SMS_MMS,  343).
-define(C_NRJ_MINI_FF_DATA,     344).
-define(C_OPT_MULTIMEDIA,       185).%% Cpte Opt Multimedia Musique hits
-define(C_OPT_20E_SSMS_ILLIM,   190).%% Cpte Opt 20E soiree SMS illimite
-define(C_FORF_VIRGIN5,         191). %% Forfait Virgin CB5
-define(C_FORF_VIRGIN6,         192). %% Forfait Virgin CB6
-define(C_OPT_INTERNET_MAX,     194). %% Cpte Opt Multimedia Internet max 
-define(C_OPT_SMS_ILLIMITE,     195). %% Cpte SMS ILLIM (journee+soiree)
-define(C_OPT_INTERNET,         197). %% Cpte Opt Multimedia Internet 
-define(C_OPT_BONUS_MULTIMEDIA_M6,184). %% Cpte Opt Bonus multimedia M6 (for DCL SL M6 Orange & Fixe 1h)
-define(C_OPT_SMS_ILL_SOIR,     198). %% Cpte Opt SMS Illimite soir (for DCL SL M6 Orange & Fixe 1h)
-define(C_RECH_SL_15E,          199). %% Serie Spécial 15E 06/2008
-define(C_RECH_SL_7E_1,         200). %% Serie Spécial 7E 06/2008
-define(C_RECH_SL_7E_2,         201). %% Serie Spécial 7E 06/2008
-define(C_RECH_ROAMING_TELE2,   205). %% Roaming Tele2 Casino 06/2008
-define(C_PASS_VACANCES_SMS_Z2, 207). %% Pass Vacances SMS Zone 2 (USA Canada Maghreb Turquie)
-define(C_PROMO_SURF_TELE2,     208). %%
-define(C_M6P_SMS_DISPO,        215). %%
-define(C_M6P_SMS_RECHARGE,     216). %%
-define(C_FORF_ZAP_CMO_1h30_v3, 219). %% Cmo ZAP DCL=89
-define(C_RECH_SL_20E,          220). %% Serie Spécial 20E 06/2008
-define(C_FORF_CARREFOUR_CB,    222). %% Compte bloque Carrefour
-define(C_FORF_ZAP_CMO_1h_v2,   227). %% Cmo ZAP 1h v2
-define(C_FORF_ZAP_CMO_1h30_v2, 137). %% Cmo ZAP 1h30 v2 = Cmo ZAP 25E
-define(C_FORF_ZAP_CMO_1h30_ill,137).
-define(C_FOOT_LIGUE1,          217). %% Cmo Foot Ligue1
-define(C_RECH_SMS_ILLM,        256). %% TELE2 and CASINO SMS ILLIMTE ACCOUNT 08/2008
-define(C_TELE2_NUM_PREFERE,    276). %% Compte NUMERO PREFERE TELE2 12/2008
-define(C_BONUS_VOIX_JOURNEE,   259). %% Bonus voix journee 15/01/2009
-define(C_BONUS_VOIX_WE,        260). %% Bonus voix weekend 15/01/2009
-define(C_FORF_CARREFOUR_CB_ILL_SMS, 262).%% Option Carrefour SMS ILLIMITES
-define(C_OPT_TV_SURF_ILL,      268). %% Cpte Bon plans TV SURF ILLIM (journee+soiree)
-define(C_OPT_OSI_VIRGIN,       271). %% Cpte Opt OSI Virgin PC Nov 2008
-define(C_OPT_SMS_VIRGIN,       272). %% Cpte Opt SMS Virgin PC Nov 2008
-define(C_OPT_VOIX_VIRGIN,      273). %% Cpte Opt Voix Virgin PC Nov 2008
-define(C_OPT_DATA_NRJ,         163). %% Cpte Opt Data (For Neptune)
-define(C_OPT_SMS_NRJ,          164). %% Cpte Opt SMS (For Neptune)
-define(C_NRJ_INT_EUROPE,       326). %% Cpte Europe (For Neptune)
-define(C_NRJ_INT_MAGHREB,       327). %% Cpte Maghreb (For Neptune)
-define(C_NRJ_INT_AFRIQUE,       328). %% Cpte Afrique (For Neptune)
-define(C_OPT_SMS_NRJ_BONUS,    166). %% Cpte Opt SMS Bonus (For Neptune)
-define(C_FORF_NRJ_DATA,        269). %% Cpte Opt Data NRJ New
-define(C_ORANGE_MAPS,          261). %% Cpte Opt Orange Maps
-define(C_VIRGIN_BONUS_SMS_CB,     272). %% Cpte Forfait virgin bonus sms
-define(C_VIRGIN_BONUS_VOIX_CB,    273). %% Cpte Forfait virgin bonus voix
-define(C_OPT_TV_MAX_V3,            230). %% Cpte for option tv max version 3
%For 5218 Godet sur PCM (PC Juin 09)
%-define(C_OPT_TV_MAX_V3,            265). %% Cpte for option tv max version 3
-define(C_OPT_INTERNET_SOIR_MOBI_V3,282). %% Cpte for option internet soir mobi version 3
-define(C_OPT_INTERNET_SOIR_CMO_V3, 188). %% Cpte for option internet soir cmo version 3
-define(C_OPT_INTERNET_MAX_V3,      286). %% Cpte for option internet max version 3
-define(C_40SMS_SPECIAL_RSA,    309). %% Cpte for option 40SMS FB Special RSA
-define(C_UNIK_DATA_POUR_ZAP,    277).
-define(C_FORF_MONACO_FB,          296).%% Compte forfait Monaco FB
-define(C_JOURNEE_UNIK_TT_OP,    266). %% Compte forfait journee unik tt op
-define(C_MOBI_BONUS,             300).
-define(C_MOBI_BONUS_SMS,          301).
-define(C_sms_mensuel,             302).
-define(C_sms_cumul,             303).
-define(C_OPT_5N_PREFERES_VIRGIN_CB, 311).%% Option 5N Preferes Virgin CB
-define(C_VIRGIN_DATA,               341). %% Credit data Virgin
-define(C_OPT_VOIX_APPELS,                329).
-define(C_FORF_VIRGIN27, 350). %% Forfait Virgin CB27


%%%% Plan Tarifaire - PTF_NUM
-define(PCLAS_V2,      1).  % plan classique
-define(PBONS_PLANS,   1). 
-define(PSOIR_WE,      3).
-define(PCLAS_SEC,     2).  % <- NEW : Plan classique à la seconde
-define(PSOIR_WE_SEC,  4).  % <- NEW : Plan soir et we à la seconde
-define(PTF_PASS_VAC_SMS_Z2,5).% Plan tarifaire Pass Vacances Zone 2 (novembre 2008)
-define(MCLAS,         13). %% classique
-define(MCLA2,         14).
-define(DWAP,          17).
-define(DWAP2,         18).
-define(MTRIB,         21).
-define(MTRIB2,        22).
-define(PSMM,          23). %% matin
-define(MSMM2,         24).
-define(PSMAM,         25). %% ap midi
-define(PSMA2,         26).
-define(PSMS,          27). %% soir
-define(PSMS2,         28).
-define(PSMN,          29). %% nuit
-define(PSMN2,         30).
-define(MADRID2,       33). %%plug
-define(PLUGV3,        34). % <- NEW : Plan plug v3
-define(MOBI_ZAP,      37).
-define(MOBI_ZAP_PROMO,35). % ZAP Plage vacacanes
-define(PLUGV3_SEC,    36). % <- NEW : Plan plug v3 à la seconde
-define(PLUG_NOEL,     39).
-define(CMO_ZAP_PROMO, 39). % CMO ZAP vacances
-define(IKDO_VX_SMS,   41). % Mobi: Option illimite KDO voix + SMS
-define(PTF_BONUS_VOIX, 41). % Mobi: Option bonus offert 15/01/2009 
-define(PTF_CARREFOUR_PP,71).
-define(M5_VX_ROAMING,   72).  % prime M5 voix roaming
-define(PTF_ROAMING_OUT, 55).  % Recharge Special Vacances
-define(PTF_ROAMING_IN,  137). % Recharge Special Vacances
-define(PTF_ODR_OMER,  47).
-define(PTF_ZAP_VACANCES_FB1,  127).
-define(PTF_ZAP_VACANCES_FB2,  131).
-define(PTF_ZAP_VACANCES_FB3,  135).
-define(PTF_ODR_BZH1,  129).
-define(PTF_ODR_BZH2,  143).
-define(PTF_symacom,    152).
-define(PTF_ODR_VIRGIN_PP, 216).
-define(PTF_CARREFOUR_PP2,219).
-define(PTF_CARREFOUR_PP3,256).
-define(PTF_CARREFOUR_PP4,257).
-define(PTF_FIVE_MIN,     50).
-define(PTF_CMO_ZAP,      267).
-define(PTF_CMO_ZAP_1H,   268).
-define(PTF_PASS_VAC_Z2,  273).
-define(PTF_CLAS_SEC_V2,  307).
-define(PTF_MOBI_BONUS,  327).
-define(PTF_MOBI_BONUS_PROMO,  328).
-define(PTF_MOBI_BONUS_APPELS, 329).
-define(PTF_MOBI_BONUS_SMS,  330).
-define(PTF_MOBI_BONUS_INTERNET,  331).
-define(PTF_MOBI_BONUS_ETRANGER,  332).
-define(PTF_CMO_ZAP_PRINC,        343).
-define(PTF_CMO_SL_M6_1H,         353).
-define(PTF_CMO_SL_M6_1H_PRINC,   354).
-define(PTF_CMO_SL_ZAP_1H30_ILL,  355).





%% 4 forfaits M6 bloques illimites WE
-define(M6_MOBILE_1,   73). % MOBILE 1h
-define(M6_MOBILE_1H20,74). % MOBILE 1h20
-define(M6_MOBILE_1H40,75). % MOBILE 1h40
-define(M6_MOBILE_2,   76). % MOBILE 2h
-define(M6_MOBILE_3,   275).% MOBILE 3h
-define(M6_PREPAID,    77). % M6 Mobile Prepaid
-define(ADFUNDED,     333). % Adfunded
-define(PM6_CMO_PRINC, 266).% Compte principal M6 CMO
-define(PTF_M6_1h_OF_20h_8h_WE, 283). % M6 1h O&F 20h-8h+WE
-define(PTF_M6_CPT_PRINC, 285). % M6 compte principal
-define(PTF_M6_1h_OF_20h_8h_FORF,287).
-define(PTF_M6_1h_OF_20h_8h_PRINC,288).
-define(PTF_M6_ORANGE_FIXE_1h, 316).
-define(PTF_M6_ORANGE_FIXE_1h_PRINC, 317).
-define(PTF1_MONACELL_PP, 78).
-define(PTF2_MONACELL_PP, 79).
-define(PTF3_MONACELL_PP, 80).
-define(M5_20_SMS,    137). % prime M5 20 sms
-define(CMO_ZAP_PROMO_PPOL2, 121). % CMO ZAP vacances PPOL2
-define(MMS_MENSU,    139). % Option MMS mensuelle

-define(PM6_CMO_SMS,  41).%% Option M6 SMS/MMS on-net illimites TOP_NUM = 80
-define(POMER_CLAS,   44).
-define(POMER_CLAS_SEC,45).
-define(PBZH_CMO_MIN, 142).
-define(PBZH_CMO_SEC, 134).
-define(PBZH_CMO_MIN2,205).
-define(PTF_BZH_MIN_CB1,  88).
-define(PTF_BZH_SEC_CB1,  89).
-define(PTF_BZH_MIN_CB2,  90).
-define(PTF_BZH_SEC_CB2,  91).
-define(PTF_BZH_MIN_CB3,  92).
-define(PTF_BZH_SEC_CB3,  93).
-define(PTF_BZH_MIN_CB4,  94).
-define(PTF_BZH_SEC_CB4,  95).
-define(PM6_CMO_MIN,  207).
-define(PBZH_CMO_SEC2,132).
-define(PM6_CMO_MIN2, 213).%Trois nouveaux PTF_NUM (213,214,215)
-define(PM6_CMO_MIN3, 214).%Pour M6 Mobile by Orange DCL_NUM=14.
-define(PM6_CMO_MIN4, 215).
-define(PTF_FORF_FB_M6_ONET_2H, 340). %% FB M6 ONET 2H 29,99E
-define(PTF_PRINC_FB_M6_ONET_2H,341). %% FB M6 ONET 2H 29,99E
-define(PTF_FORF_FB_M6_1H_SMS,  363). %% FB M6 1H SMS 19,99E
-define(PTF_PRINC_FB_M6_1H_SMS, 364). %% FB M6 1H SMS 19,99E
-define(PTF_FORF_FB_M6_1H30,    365). %% FB M6 1H30
-define(PTF_PRINC_FB_M6_1H30,   366). %% FB M6 1H30

%% MVNO MONACO TELECOM FORFAIT BLOQUE
-define(PTF_MONACELL_CB_40MIN, 325).
-define(PTF_MONACELL_CB_1H, 326).
-define(PTF_MONACELL_CB_PRINC, 324).

%% MVNO TELE2
-define(PTELE2_PP,    70).
-define(PTELE2_PP2,   180).
-define(PTF_CASINO_PP,181).
-define(PTELE2_NUM_PREFERE,  276). % PTF Numero prefere Tele2
%% NEW PLAN 01/07
-define(P_TS_RESEAUX, 242).

%% PTF VIRGIN 
-define(PTF_VIRGIN_PP_GPRS, 208).
-define(PTF_VIRGIN_CB_GPRS, 208).
-define(PTF_VIRGIN_PP_OPT1, 209).
-define(PTF_VIRGIN_PP_OPT2, 210).
-define(PTF_VIRGIN_PP_OPT3, 211).
-define(PTF_VIRGIN_PP_OPT4, 212).
-define(PTFNUM_VIRGIN_PREPAID, 216).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE1, 206).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE2, 202).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE3, 233).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE4, 234).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE5, 188).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE6, 189).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE11, 310).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE12, 311).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE13, 312).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE14, 313).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE15, 314).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE16, 315).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE17, 344).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE18, 345).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE19, 367).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE20, 368).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE24, 384).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE25, 385).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE26, 386).
-define(PTFNUM_VIRGIN_COMPTEBLOQUE27, 387).
-define(PTFNUM_VIRGIN_OPT_CB_200_SMS, 96).
-define(PTFNUM_VIRGIN_OPT_CB_5N_PREFERES, 346).
-define(PTF_VIRGIN_BONUS_VOIX, 286).
-define(PTFNUM_VIRGIN_OPT_CB_SMS_ILL, 41).
-define(PM6_CMO_MIN5, 226).%M6 Mobile by Orange v3 DCL_NUM=22.
-define(PM6_CMO_MIN6, 227).%M6 Mobile by Orange v4 DCL_NUM=23.
-define(PTF_SL_BLACKBERRY_1H_FB, 318).
-define(PTF_SL_BLACKBERRY_1H_PRINC, 319).

-define(PTF_TELE2_CB_PP, 243).
-define(PTF_TELE2_CB1, 245).
-define(PTF_TEN_CB_PP,  244).
-define(PTF_TEN_CB2_PP, 253).
-define(PTF_TELE2_CB_PP2,247).
-define(PTF_TELE2_CB2, 248).
-define(PTF_TELE2_25_SMS,249).
-define(PTF_TELE2_50_SMS,249).
-define(PTF_TELE2_100_SMS,249).

-define(PTF_TEN_20_SMS,254).
-define(PTF_TEN_50_SMS,254).
-define(PTF_TEN_100_SMS,254).

%%  PTF CARREFOUR
-define(PTF_CARREFOUR_Z1,250).
-define(PTF_CARREFOUR_Z2,251).
-define(PTF_CARREFOUR_Z3,252).
-define(PTF_CARREFOUR_CB1,179).
-define(PTF_CARREFOUR_CB2,191).
-define(PTF_CARREFOUR_CB3,192).
-define(PTF_CARREFOUR_CB4,377).
-define(PTF_CARREFOUR_CB5,378).
-define(PTF_CARREFOUR_CB6,379).
-define(PTFNUM_CARREFOUR_OPT_CB_SMS_ILL, 258).

%% PTF NRJ PP
-define(PTF_NEPTUNE_PP, 153).
-define(PTF_NEPTUNE_PP_DOUBLE_JEU, 294).

%% PTF NRJ CB
-define(PTF_NEPTUNE_CB_1 ,159).
-define(PTF_NEPTUNE_CB_PP ,160).
-define(PTF_NEPTUNE_CB_PRINC,282).
-define(PTF_NEPTUNE_MINI_SMS,162).
-define(PTF_NEPTUNE_FF1,164).
-define(PTF_NEPTUNE_FF2,165).
-define(PTF_NEPTUNE_FF3,262).
-define(PTF_NEPTUNE_FF4,263).
-define(PTF_NEPTUNE_DATA,156).
-define(PTF_NEPTUNE_SMS,154).
-define(PTF_NEPTUNE_ZONES,371).
-define(PTF_NRJ_FB_SL1,347).
-define(PTF_NRJ_FB_SL2,348).
-define(PTF_NRJ_FB_SL3,349).
-define(PTF_NRJ_FB_SL4,350).
-define(PTF_NRJ_MINI_FB,374).

%% +deftype pt_tab() = [pt_tuple()].
%% +deftype pt_tuple() = { 
%%                      atom(), %% atom servant au passage erlang <-> page xml
%%                      integer(), %% valeur du plan tarifaire
%%                      string()   %% texte de lien affiché dans le menu
%%                       }.
%%% TODO ?:Rajouter un champs contenant le texte a afficher apres souscription?
%%%         ex:
-define(OMER_LISTEPLANS,[]).

%% Liste des plans que l'on supporte :
-define(LISTE_PLANS_SUPPORTES, [?MCLAS,
				?PSMM,
				?PSMAM,
				?PSMS,
				?PSMN,
				?MADRID2,
				?PLUG_NOEL,
				?PCLAS_V2,
				?PSOIR_WE,
				?PLUGV3,
				?PLUGV3_SEC,
				?PCLAS_SEC,
				?PSOIR_WE_SEC,
				?MOBI_ZAP,
				?MOBI_ZAP_PROMO,
				?M6_PREPAID]).

-define(PT_POSSIBLE_LINKS,
	[{class_v2,    ?PCLAS_V2,     "Plan Classique\n"},
	 {soir_we,     ?PSOIR_WE,     "Plan Soir et WE\n"},
	 {zap,         ?MOBI_ZAP,     "Plan Orange 11-18 a la seconde\n"},
	 {zap_promo,   ?MOBI_ZAP_PROMO,"Vos Heures 11-18 Vacances\n"},
%%	 {plug,        ?PLUGV3,       "Plan Orange Plug\n"}, %%
	 {class_sec,   ?PCLAS_SEC,    "Plan classique seconde\n"},
	 {soir_we_sec, ?PSOIR_WE_SEC, "Plan Soir et Week-end\n"},
	 {class_sec_v2,?PTF_CLAS_SEC_V2,"Nouveau Plan classique seconde 2009"}
	 %%{plug_sec,    ?PLUGV3_SEC,   "Plan Orange Plug a la seconde\n"}%%
	]).

%% PTF CMO
-define(OX1,          102).
-define(OX2,          104).
-define(OX3,          106).
-define(FOR1,         111).
-define(FOR2,         112).
-define(CMO1,         113).
-define(CMO2,         114).
-define(Capri,        115).
-define(wap1,         125).


%% Carte de Rechargment CTK_NUM
-define(REC_STANDARD,  1). 
-define(REC_PROMO,     2).
-define(REC_INTENSIVE, 3).
-define(REC_SMS, 4).
-define(RECHARGE_WEINF,7).
-define(RECHARGE_EUROPE,11).
-define(RECHARGE_MAGHREB,9).
-define(RECHARGE_SMSMMS,5).
-define(RECHARGE_JINF,13).
-define(RECH_LIMITE_NOEL,15).
-define(RECHARGE_SL,17).
-define(RECHARGE_20E_SL,35).
-define(CTK_CARREFOUR_Z1,19).
-define(CTK_CARREFOUR_Z2,21).
-define(CTK_CARREFOUR_Z3,23). 
-define(RECHARGE_VACANCES,25). 

%%TRC_NUM
-define(SMS_ALL,16).
-define(TR_10SMS,17).
-define(SMS_ALL_CMO,18).

%%% TYPE RECHARGE
-define(TYPE_10SMS,29).

%% +deftype recharge() =
%%     #recharge{      montant    :: integer(),     %% milième d'euros
%%                     day_valid  :: integer(),     %% nb of validity
%%                     nb_sms     :: integer(),     %% nb_sms if transfert
%%                     tra_num    :: integer(),     %% no du transfert
%%                     tentative  :: integer()}.    %% no de tentative
-record(recharge,
	{montant,
	 day_valid,
	 nb_sms,
	 tra_num,
	 tentative}).


-define(TB_PTF,table_ratio_of).

%%NUMEROS DE TRANSFERT (REQUETE DE TRANSFERT DE SOLDE)
-define(NUMTRANS_SINF_MOBI,41). %%Soiree D'Ete mobi
-define(NUMTRANS_SINF_CMO, 42). %%Soiree D'Ete mobi


-define(NUMTRANS_VOY_MOBI,45). %%Voyage
-define(NUMTRANS_VOY_CMO, 46). %%Voyage

-define(NUMTRANS_OW,47). %%Orange World (n existe qu en mobi)

-define(NUMTRANS_SSMS_CMO,51).
-define(NUMTRANS_AFTER_CMO,49).

%%NUMEROS DE PRESTATIONS (REQUETE DE PRESTATION CLIENTE)
-define(NUMPREST_SINF_MOBI,31). %%Soiree D'Ete mobi
-define(NUMPREST_SINF_CMO,146). %%Soiree D'Ete mobi

-define(NUMPREST_VOY_MOBI,24). %%Voyage
-define(NUMPREST_VOY_CMO, 25). %%Voyage

-define(NUMPREST_OW,30). %%Orange World (n existe qu en mobi)

-define(NUMPREST_SSMS_CMO,147). %%Soiree SMS CMO
-define(NUMPREST_AFTER_CMO,254).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correspondence between tcp_num and cpte.

-define(TCPNUM_CPTE,[{?C_PRINC,cpte_princ,all_subscriptions},
		     {?C_JINF_VOIX,cpte_jinf_voix,all_subscriptions},
		     {?C_WAP,cpte_wap,all_subscriptions},
		     {?C_SMS,cpte_sms,all_subscriptions},
		     {?C_FORF_PMU,forf_pmu,all_subscriptions},
		     {?C_FORF,cpte_forf,all_subscriptions},
		     {?C_FORF_SMS,forf_sms,all_subscriptions},
		     {?C_FORF_WEBWAP,forf_webwap,all_subscriptions},
		     {?C_FORF_WAP,forf_wap234,all_subscriptions},
		     {?C_SMSX,forf_smsx,all_subscriptions},
		     {?C_SMSY,forf_smsy,all_subscriptions},
		     {?K_WAP,cpte_wap,all_subscriptions},
		     {?C_VOIX,cpte_voix,all_subscriptions},
		     {?P_VOIX,promo_voix,all_subscriptions},
		     {?C_SMS_NOEL,cpte_sms_noel,all_subscriptions},
		     {?C_AEUROS,cpte_aeuros,all_subscriptions},
		     {?C_AVOIX,cpte_avoix,all_subscriptions},
		     {?ADFUNDED,cpte_bons_plans_jeu,all_subscriptions},
		     {?C_ASMS,cpte_asms,all_subscriptions},
		     {?C_AWAP,cpte_awap,all_subscriptions},
		     {?C_NUM_PREF,forf_num_pref,all_subscriptions},
		     {?C_FORF_HC,forf_hc,all_subscriptions},
		     {?C_ORANGEX,forf_orangex,all_subscriptions},
		     {?C_FORF_FMU_18,forf_fmu,all_subscriptions},
		     {?C_FORF_FMU_24,forf_fmu,all_subscriptions},
		     {?C_FORF_CMOSL,forf_cmosl,all_subscriptions},
		     {?C_ESP_VOIX,cpte_esp_voix,all_subscriptions},
		     {?C_ESP_MUL,cpte_esp_mult,all_subscriptions},
		     {?C_ESP_SMS,cpte_esp_sms,all_subscriptions},
		     {?C_RDL_VOIX,cpte_rdl_voix,all_subscriptions},
		     {?C_RDL_MUL,cpte_rdl_mult,all_subscriptions},
		     {?C_RDL_SMS,cpte_rdl_sms,all_subscriptions},
		     {?C_RDL_VOIX_MOBI,cpte_rdl_voix,mobi},
		     {?C_WE_VOIX,cpte_we_voix,cmo},
		     {?C_RDL_SMS_MOBI,cpte_rdl_sms,mobi},
		     {?C_FORF_SMS_PROMO,forf_sms_promo,cmo},
		     {?C_RDL_WAP,cpte_rdl_wap,all_subscriptions},
		     {?C_FORF_BZH,forf_bzh,all_subscriptions},
		     {?C_VOIX_ZAP,cpte_voix,all_subscriptions},
		     {?C_FORF_ZAP_CMO_1h30_v3,cpte_voix,all_subscriptions},
		     {?C_FORF_ZAP_CMO_25E_v3,cpte_voix,all_subscriptions},
		     {?C_FORF_MU_M6,forf_mu_m6,all_subscriptions},
		     {?C_SURPRISE_VOIX,cpte_surprise_voix,all_subscriptions},
		     {?TCPNUM_PACKNOEL,cpte_packnoel,all_subscriptions},
		     {?C_FORF_CMOSLAPU,forf_cmoslapu,all_subscriptions},
		     {?C_FORF_BZH2,forf_bzh,all_subscriptions},
		     {?C_BZH_CB1_4_FORF,forf_bzh,all_subscriptions},
		     {?C_BZH_CB1_4_SMS,cpte_sms,all_subscriptions},
		     {?C_FORF_VIRGIN1,forf_virgin,all_subscriptions},
		     {?C_FORF_MU_M6_V2,forf_mu_m6,all_subscriptions},
		     {?TCP_AFTERSCH_CMO,cpte_aftersch_cmo,all_subscriptions},
		     {?TCP_AFTERSCH_MOBI,cpte_aftersch_mobi,all_subscriptions},
		     {?C_E_RECHARGE,cpte_e_recharge,all_subscriptions},
		     {?C_EASY_VOICE,cpte_easy_voice,all_subscriptions},
		     {?C_BONS_PLANS,cpte_bons_plans,all_subscriptions},
		     {?C_DIXIT_BONS_PLANS,cpte_dixit_bons_plans,all_subscriptions},
		     {?C_JILLI_OW,cpte_jilli_ow,all_subscriptions},
		     {?C_SMS_QUOTIDIEN,cpte_sms_quotidien,all_subscriptions},
		     {?C_ZAP_MMS,cpte_zap_mms,all_subscriptions},
		     {?C_OPT_M6_MMSMS_NET,cpte_m6_mmsms,all_subscriptions},
		     {?C_FIVE_MIN,cpte_five_min,all_subscriptions},
		     {?C_PROMO_BASE_SMS,cpte_promo_base_sms,all_subscriptions},
		     {?C_FORF_VIRGIN2,forf_virgin,all_subscriptions},
		     {?C_OPTION_VIRGIN,cpte_opt_virg,all_subscriptions},
		     {?C_FORF_MU_M6_V3,forf_mu_m6,all_subscriptions},
		     {?C_FORF_MU_M6_V4,forf_mu_m6,all_subscriptions},
		     {?C_BIG_FORF_CMO,big_forf_cmo,all_subscriptions},
		     {?C_2NUM_PREF,cpte_two_numpref,all_subscriptions},
		     {?C_OW_DECO,cpte_deco,all_subscriptions},
		     {?C_M5_KDO_VX_NET,cpte_m5_kdo_vx_net,all_subscriptions},
		     {?C_M5_KDO_VX_INTERNAT,cpte_m5_kdo_vx_internat,all_subscriptions},
		     {?C_FORF_VIRGIN3,forf_virgin,all_subscriptions},
		     {?C_FORF_VIRGIN4,forf_virgin,all_subscriptions},
		     {?C_M5_MNT_VOIX,cpte_m5_mnt_voix,all_subscriptions},
		     {?C_PASS_MTC,cpte_pass_mtc,all_subscriptions},
		     {?C_OPT_TV,cpte_opt_tv,all_subscriptions},
		     {?C_OPT_TOTAL_TV,cpte_total_tv,all_subscriptions},
		     {?C_OPT_TV_MAX_V3,cpte_total_tv,all_subscriptions},
		     {?C_SPORT,cpte_sport,all_subscriptions},
		     {?C_MUSIQUE,cpte_musique,all_subscriptions},
		     {?C_SURF,cpte_surf,all_subscriptions},
		     {?C_ILLIMITE_KDO,cpte_illimite_kdo,all_subscriptions},
		     {?C_M5_WE_VOIX_ILL,cpte_we_voix_ill,all_subscriptions},
		     {?C_PROMO_CONTENU,cpte_promo_contenu,all_subscriptions},
		     {?C_WE_ILLIMITE_MMS,cpte_we_mms_illimite,all_subscriptions},
		     {?C_WE_ILLIMITE_SMS,cpte_we_sms_illimite,all_subscriptions},
		     {?C_FORF_M6_MOB_1H_V3,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_MOB_1H30_V3,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_MOB_2H_V3,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_MOB_1,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_MOB_1H20,forf_m6_mob,all_subscriptions},
		     {?C_OPT_BONUS_MULTIMEDIA_M6,forf_m6_mob,all_subscriptions},
		     {?C_OPT_SMS_ILL_SOIR,forf_m6_mob,all_subscription},
		     {?C_M5_20_SMS,cpte_m5_20_sms,all_subscriptions},
		     {?C_M5_VX_ROAMING,cpte_m5_vx_rmg,all_subscriptions},
		     {?C_FORF_M6_MOB_1H40,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_MOB_2,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_MOB_3,forf_m6_mob,all_subscriptions},
		     {?C_FORF_M6_USAGES_COMMUNAULT,forf_m6_usage_communault,all_subscriptions},
		     {?C_3NUM_KDOSMS,cpte_3num_kdosms,all_subscriptions},
		     {?C_IKDO_VX_SMS,cpte_ikdo_vx_sms,all_subscriptions},
		     {?C_SURF_MENSU,cpte_surf_mensu,all_subscriptions},
		     {?C_KDO_VOIX,cpte_kdo_voix,all_subscriptions},
		     {?C_KDO_SMS,cpte_kdo_sms,all_subscriptions},
		     {?C_KDO_TV,cpte_kdo_tv,all_subscriptions},
		     {?C_MMS_MENSU,cpte_mms_mensu,all_subscriptions},
		     {?C_SL_7E,cpte_kdo_surf,mobi},
		     {?C_SL_7E,forf_SL_7E,cmo},
		     {?C_UNIK_FIXE,forf_unik_fixe,all_subscriptions},
		     {?C_TS_RESEAUX,forf_ts_reseaux,all_subscriptions},
		     {?C_MSN_MENSU_CMO,cpte_msn_mensu_cmo,all_subscriptions},
		     {?C_MSN_JOURNEE_CMO,cpte_msn_journee_cmo,all_subscriptions},
		     {?C_FORF_TELE2_CB1,forf_tele2_cb,tele2_comptebloque},
		     {?C_FORF_TELE2_CB2,forf_tele2_cb,tele2_comptebloque},
		     {?C_FORF_TELE2_CB3,forf_tele2_cb,tele2_comptebloque},
		     {?C_FORF_TELE2_CB_25_SMS,cpte_opt_tele2,tele2_comptebloque},
		     {?C_FORF_TELE2_CB_50_SMS,cpte_opt_tele2,tele2_comptebloque},
		     {?C_FORF_TELE2_CB_100_SMS,cpte_opt_tele2,tele2_comptebloque},
		     {?C_FORF_TEN_CB1,forf_ten_cb,all_subscriptions},
		     {?C_FORF_TEN_CB2,forf_ten_cb,all_subscriptions},
		     {?C_FORF_TEN_CB_20_SMS,cpte_ten_sms,ten_comptebloque},
		     {?C_FORF_TEN_CB_50_SMS,cpte_ten_sms,ten_comptebloque},
		     {?C_FORF_TEN_CB_100_SMS,cpte_ten_sms,ten_comptebloque},
		     {?C_NRJ_MINI_FF_VOIX,cpte_nrj_mini_ff_voix,nrj_comptebloque},
		     {?C_NRJ_MINI_FF_SMS_MMS,cpte_nrj_mini_ff_sms_mms,nrj_comptebloque},
		     {?C_NRJ_MINI_FF_DATA,cpte_nrj_mini_ff_data,nrj_comptebloque},
		     {?C_FORF_NRJ_CB,forf_nrj_cb,nrj_comptebloque},
		     {?C_FORF_NRJ_CB1,forf_nrj_cb,nrj_comptebloque},
		     {?C_FORF_NRJ_CB2,forf_nrj_cb,nrj_comptebloque},
		     {?C_FORF_NRJ_CB3,forf_nrj_cb,nrj_comptebloque},
		     {?C_FORF_NRJ_CB4,forf_nrj_cb,nrj_comptebloque},		
		     {?C_FORF_NRJ_CB5,forf_nrj_cb,nrj_comptebloque},
		     {?C_OPT_DATA_NRJ,cpte_forf_nrj_data,all_subscriptions},
		     {?C_OPT_SMS_NRJ,cpte_forf_nrj_sms,all_subscriptions},
		     {?C_NRJ_INT_EUROPE, cpte_nrj_europe, nrj_prepaid},
		     {?C_NRJ_INT_MAGHREB, cpte_nrj_maghreb, nrj_prepaid},
		     {?C_NRJ_INT_AFRIQUE, cpte_nrj_afrique,nrj_prepaid},
                     {?C_NRJ_INT_EUROPE, cpte_nrj_europe, nrj_comptebloque},
                     {?C_NRJ_INT_MAGHREB, cpte_nrj_maghreb, nrj_comptebloque},
                     {?C_NRJ_INT_AFRIQUE, cpte_nrj_afrique,nrj_comptebloque},
		     {?C_OPT_SMS_NRJ_BONUS,cpte_forf_nrj_sms_bonus,nrj_comptebloque},
		     {?C_FORF_NRJ_DATA,cpte_forf_nrj_wap,nrj_comptebloque},
		     {?C_CARREFOUR_Z1,forf_carrefour_z1,all_subscriptions},
		     {?C_CARREFOUR_Z2,forf_carrefour_z2,all_subscriptions},
		     {?C_CARREFOUR_Z3,forf_carrefour_z3,all_subscriptions},
		     {?C_FORF_CARREFOUR_CB,forf_carrefour_cb,carrefour_comptebloque},
		     {?C_FORF_CARREFOUR_CB_ILL_SMS,cpte_opt_carrefour,carrefour_comptebloque},
		     {?C_50SMS_WINNING_CMO,refillgame_50sms,all_subscriptions},
		     {?C_ROAMING_OUT,roaming_out,all_subscriptions},
		     {?C_ROAMING_IN,roaming_in,all_subscriptions},
		     {?C_FORF_ZAP_CMO_18E,forf_zap,all_subscriptions},
		     {?C_FORF_ZAP_CMO_20E,forf_zap,all_subscriptions},
		     {?C_FORF_ZAP_CMO_25E,forf_zap,all_subscriptions},
		     {?C_FORF_ZAP_CMO_1h_v2,forf_zap,all_subscriptions},
		     {?C_FORF_ZAP_CMO_1h30_v2,forf_zap,all_subscriptions},
		     {?C_FORF_ZAP_CMO_1h30_ill,forf_zap,all_subscriptions},
		     {?C_FORF_ODR,cpte_odr,all_subscriptions},
		     {?C_OFFERT,cpte_credit_offert,all_subscriptions},
		     {?C_OPT_VIRGIN_PP,cpte_opt_very,virgin_prepaid},
		     {?C_OPT_OSI_VIRGIN,cpte_osi,virgin_prepaid},
		     {?C_FORF_VIRGIN5,forf_virgin,all_subscriptions},
		     {?C_FORF_VIRGIN6,forf_virgin,all_subscriptions},
		     {?C_FORF_VIRGIN27,forf_virgin,all_subscriptions},
		     {?OPT_SMS_200_VIRGIN_CB,opt_sms,virgin_comptebloque},
		     {?C_VIRGIN_BONUS_SMS_CB,virgin_bonus_sms_cb,virgin_comptebloque},
		     {?C_VIRGIN_BONUS_VOIX_CB,virgin_bonus_voix_cb,virgin_comptebloque},
		     {?C_OPT_5N_PREFERES_VIRGIN_CB,opt_5n_preferes,virgin_comptebloque},
		     {?C_RECH_SL_15E,cpte_sl_15E,all_subscriptions},
		     {?C_RECH_SL_7E_1,cpte_sl_7E_1,all_subscriptions},
		     {?C_RECH_SL_7E_2,cpte_sl_7E_2,all_subscriptions},
		     {?C_RECH_SL_20E,cpte_sl_20E,all_subscriptions},
		     {?C_M6P_SMS_DISPO,cpte_m6_soiree_sms_dispo,all_subscriptions},
		     {?C_M6P_SMS_RECHARGE,cpte_m6_soiree_sms_recharge,all_subscriptions},
		     {?C_RECH_ROAMING_TELE2,cpte_roaming,all_subscriptions},
		     {?C_RECH_SMS_ILLM,cpte_sms_ill,all_subscriptions},
		     {?C_TELE2_NUM_PREFERE,cpte_num_prefere,all_subscriptions},
		     {?C_PROMO_SURF_TELE2,cpte_promo_surf,all_subscriptions},
                     {138,opt_sms,bzh_cmo},		     
		     {?C_OPT_MULTIMEDIA,cpte_opt_multim,all_subscriptions},
		     {?C_OPT_INTERNET,cpte_opt_internet,all_subscriptions},
		     {?C_OPT_INTERNET_SOIR_MOBI_V3,cpte_opt_internet_soir,all_subscriptions},
		     {?C_OPT_INTERNET_SOIR_CMO_V3,cpte_opt_internet_soir,all_subscriptions},
		     {?C_FOOT_LIGUE1,cpte_foot_ligue1,cmo},
		     {?C_MOBI_BONUS,cpte_mobi_bonus,mobi},
		     {?C_MOBI_BONUS_SMS,cpte_mobi_bonus_sms,mobi},
		     {?C_OPT_INTERNET_MAX,cpte_opt_internet_max,all_subscriptions},
		     {?C_OPT_INTERNET_MAX_V3,cpte_opt_internet_max,all_subscriptions},
		     {?OPT_SMS_200_BZH_CB,opt_sms,bzh_cmo}, %% option SMS 200
		     {?C_OPT_TV_SURF_ILL,cpte_opt_tv_surf_ill,all_subscriptions},
		     {?C_OPT_SMS_ILL,cpte_opt_sms_ill,all_subscriptions},
		     {?C_OPT_SMS_ILLIMITE,cpte_opt_sms_illimite,all_subscriptions},
		     {?C_OPT_SMS_VIRGIN,cpte_opt_sms_virgin,virgin_prepaid},
		     {?C_OPT_VOIX_VIRGIN,cpte_opt_voix_virgin,virgin_prepaid},
		     {?C_ORANGE_MAPS,cpte_orange_maps,all_subscriptions},
		     {?C_NRJ_SMS_ILL,cpte_nrj_sms_ill,nrj_prepaid},
		     {?C_NRJ_SMS_ILL,cpte_nrj_sms_ill,nrj_comptebloque},
		     {?C_NRJ_PP_LIGHT,cpte_nrj_pp_light,nrj_prepaid},
		     {?C_NRJ_PP_RESERVES_DAPPELS,cpte_nrj_pp_reserves_dappels,nrj_prepaid},
		     {?C_40SMS_SPECIAL_RSA,cpte_sms_special_rsa,all_subscriptions},
		     {?C_FORF_MONACO_FB,cpte_forf_monaco_fb,all_subscriptions},
		     {?C_sms_mensuel, cpte_sms_mensuel, all_subcriptions},
		     {?C_sms_cumul, cpte_sms_cumul, all_subcriptions},
		     {?C_VIRGIN_DATA, cpte_data_virgin, virgin_prepaid},
		     {?C_OPT_VOIX_APPELS, cpte_opt_voix_appels, all_subscriptions}
		    ]).


-define(CMO_OPTIONS,[opt_foot_ligue1,
		     osl,
		     opt_report,
		     opt_m6_smsmms,
		     opt_five_min,
		     opt_2numpref,
		     media_decouvrt,
		     media_internet,
		     media_internet_plus,
		     ow_tv,
		     ow_tv2,
		     ow_spo,
		     ow_surf,
		     ow_musique,
		     opt_we_voix,
		     opt_we_sms,
		     opt_tt_shuss_voix,
		     opt_tt_shuss_sms,
		     opt_ssms,
		     opt_sms_quoti,
		     opt_sinf,
		     opt_seminf,
		     opt_pass_vacances_mtc,
		     opt_pass_vacances_moc,
		     opt_pass_vacances_v2_mtc,
		     opt_pass_vacances_v2_moc,
		     opt_pass_vacances_v2_10_sms,
		     opt_pass_vacances_z2_mtc,
		     opt_pass_vacances_z2_moc,
		     opt_pass_vacances_z2_sms,
		     opt_maghreb,
		     opt_jinf,
		     opt_j_app_ill,
		     opt_s_app_ill,
		     opt_j_mm_ill,
		     opt_s_mm_ill,
		     opt_ssms_ill,
		     opt_jsms_ill,
		     opt_j_tv_max_ill,
		     opt_s_tv_max_ill,
		     opt_europe,
		     opt_weinf,
		     opt_sms_3,
		     opt_sms_7_5,
		     opt_sms_12,
		     opt_sms_18,          
		     opt_sms_25,
		     opt_weinf_OW_TV,
		     opt_3num_kdo,
		     opt_OW_10E,
		     opt_OW_30E,
		     sms_opt_OW,
		     opt_etudiante,
		     opt_3num_kdo_sms,
		     opt_J_illi_Data,
		     opt_WE_OW,
		     opt_sl_7E,
		     opt_1h_ts_reseaux,
		     opt_vacances,
		     opt_orange_messenger,
		     opt_j_omwl,
		     opt_tv,
		     opt_tv_max,
		     opt_musique_collection,
		     opt_musique_hits,
		     opt_internet,
		     opt_internet_max,
		     opt_unik_pour_zap_tous_operator,
		     winning_50sms]).

-define(CMO_PROMOS,[opt_credit_voix_of,
		    opt_credit_sms_of,
		    opt_credit_OW_of,
		    opt_cadeau_orange_MMS,
		    opt_bons_plans]).	

-define(CPTE_FORFAIT_VOIX, [forf_pmu,
			    cpte_forf,
			    cpte_voix,
			    forf_hc,
			    forf_fmu,
			    forf_cmosl,
			    forf_mu_m6,
			    forf_cmoslapu,
			    big_forf_cmo,
			    forf_m6_mob,
			    forf_zap]).

-define(OPT_NUM_PREF,[
                      opt_numpref_tele2,
                      opt_2numpref]).
        
 %% -define(Modified_Opts,[%%option CMO
 %% 		       teasing_jkdo_bp,
 %% 		       journee_kdo_bp,
 %%                        opt_internet,
 %%                        opt_musique_mix,
 %%                        opt_tv,
 %%                        opt_orange_sport,
 %%                        opt_internet_max,
 %%                        opt_orange_maps,
 %%                        opt_mail,
 %%                        opt_musique_collection,
 %%                        opt_tv_max,
 %%                        opt_paris,
 %%                        opt_marseille,
 %%                        opt_lyon,
 %%                        opt_lens,
 %%                        opt_saint_etienne,
 %%                        opt_bordeaux,
 %%                        opt_mes_donnees,
 %% 		       opt_j_app_ill,
 %% 		       opt_s_app_ill,
 %% 		       opt_jsms_ill,
 %% 		       opt_ssms_ill,
 %% 		       opt_j_mm_ill,
 %% 		       opt_s_mm_ill,
 %% 		       opt_j_omwl,
 %% 		       opt_j_tv_max_ill,
 %% 		       opt_s_tv_max_ill,
 %% 		       opt_j_app_ill_kdo_bp,
 %% 		       opt_s_app_ill_kdo_bp,
 %% 		       opt_j_mm_ill_kdo_bp,
 %% 		       opt_s_mm_ill_kdo_bp,
 %% 		       opt_ssms_ill_kdo_bp,
 %% 		       opt_jsms_ill_kdo_bp,
 %% 		       opt_j_omwl_kdo_bp,
 %% 		       opt_j_tv_max_ill_kdo_bp,
 %% 		       opt_s_tv_max_ill_kdo_bp,
 %% 		       opt_jsms_ill_jeu,
 %% 		       opt_ssms_ill_jeu,
 %% 		       opt_j_mm_ill_jeu,
 %% 		       opt_s_mm_ill_jeu,
 %% 		       opt_30_sms_mms,
 %% 		       opt_80_sms_mms,
 %% 		       opt_130_sms_mms,
 %% 		       opt_sms_mms_illimites,
 %% 		       opt_orange_messenger,
 %% 		       opt_pass_voyage_6E,
 %% 		       opt_pass_voyage_9E,
 %% 		       opt_europe,
 %% 		       opt_maghreb,
 %% 		       opt_pass_dom,
 %%                        %Option Postpaid
 %% 		       opt_internet_max_gpro,
 %% 		       opt_mail_gpro,
 %% 		       opt_mail_MMS_gpro,
 %% 		       opt_internet_gpro,
 %% 		       opt_giga_mail_gpro,
 %% 		       opt_iphone_3g_gpro,
 %% 		       opt_mail_blackberry_gpro,
 %% 		       opt_mes_donnees_gpro,
 %% 		       opt_musique_collection_gpro,
 %% 		       opt_musique_mix_gpro,
 %% 		       opt_tv_max_gpro,
 %% 		       opt_tv_gpro,
 %% 		       opt_orange_sport_gpro,
 %% 		       opt_paris_gpro,
 %% 		       opt_marseille_gpro,
 %% 		       opt_lyon_gpro,
 %% 		       opt_lens_gpro,
 %% 		       opt_saint_etienne_gpro,
 %% 		       opt_bordeaux_gpro,
 %% 		       opt_orange_maps_gpro,
 %% 		       opt_30_sms_mms_gpro,
 %% 		       opt_80_sms_mms_gpro,
 %% 		       opt_130_sms_mms_gpro,
 %% 		       opt_sms_mms_ill_gpro,
 %%                        opt_10min_europe_gpro,
 %%                        opt_tarif_jour_zone_europe_gpro,
 %%                        opt_pass_internet_int_jour_2E_gpro,
 %%                        opt_pass_internet_int_jour_5E_gpro,
 %%                        opt_pass_internet_int_5E_gpro,
 %%                        opt_pass_internet_int_20E_gpro,
 %%                        opt_pass_internet_int_35E_gpro,
 %%                        opt_tarif_jour_zone_europe_gpro,
 %%                        opt_pass_voyage_15min_europe_gpro,
 %%                        opt_pass_voyage_30min_europe_gpro,
 %%                        opt_pass_voyage_60min_europe_gpro,
 %%                        opt_pass_voyage_15min_maghreb_gpro,
 %%                        opt_pass_voyage_30min_maghreb_gpro,
 %%                        opt_pass_voyage_60min_maghreb_gpro,
 %%                        opt_pass_voyage_15min_rdm_gpro,
 %%                        opt_pass_voyage_30min_rdm_gpro,
 %%                        opt_pass_voyage_60min_rdm_gpro,
 %% 		       opt_orange_messenger_gpro
 %% 		      ]).
