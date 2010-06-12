%% +deftype dme_user_state() =
%%       #dme_user_state{
%%               msisdn           :: string(), 
%%		 script           :: int(),
%%		 compte           :: string(),
%%		 confident        :: string(),
%%		 d_last_call      :: string(),
%%		 h_last_call      :: string(),
%%		 d_begin_period   :: string(),
%%		 d_end_period     :: string(),
%%		 ab_dur           :: string(),
%%		 ab_mount         :: string(),
%%		 rest_dur         :: string(),
%%		 cons_dur         :: string(),
%%		 dep_dur          :: string(),
%%		 dep_mount        :: string(),
%%		 hf_dur           :: string(),
%%		 hf_mount         :: string(),
%%		 init_dur         :: string(),
%%		 init_report      :: string(),
%%		 rest_report      :: string(),
%%		 init_bonus       :: string(),
%%		 rest_bonus       :: string(),
%%		 godet            :: lists(godet()),
%%               spider           :: undefined | getBalanceResponse()
%%		}.

-record(dme_user_state, {msisdn, 
			 script,
			 compte,
			 confident,
			 d_last_call,
			 h_last_call,
			 d_begin_period,
			 d_end_period,
			 ab_dur,
			 ab_mount,
			 rest_dur,
			 cons_dur,
			 dep_dur,
			 dep_mount,
			 hf_dur,
			 hf_mount,
			 init_dur,
			 init_report,
			 rest_report,
			 init_bonus,
			 rest_bonus,
			 godet,
			 spider
			}).


%% +deftype godet() = 
%%       #godet{
%%             group ::  int(), 
%%	       init  ::  string(),
%%	       unit  ::  string(),
%%	       start ::  string(),
%%	       stop  ::  string(),
%%	       rest  ::  string()
%%             }.

-record(godet,{group, 
	       init,
	       unit,
	       start,
	       stop,
	       rest}).

%%%% TYPE SCRIPT
-define(SCRIPT_FORMULE,1).
-define(SCRIPT_OPTIMA,2).
-define(SCRIPT_FORF_ORANGE,3).
-define(SCRIPT_FORF_JOURN,4).
-define(SCRIPT_FORF_LIG_PLUS,5).
-define(SCRIPT_FORF_PARTAGE,6).
-define(SCRIPT_VOLUME,7).
-define(SCRIPT_UMTS,8).
-define(SCRIPT_TPE_OPT_LIG_PRINC,9).
-define(SCRIPT_TPE_OPT_UTILI,10).
-define(SCRIPT_TPE_FORF_LIG_PRINC,11).
-define(SCRIPT_TPE_FORF_UTILI,12).
-define(SCRIPT_ABO_DATA,13).
-define(SCRIPT_TPS_REEL,14).
-define(SCRIPT_ORANGE_INTENSE_OPTIMA,15).
-define(SCRIPT_BIZ_EVERYWHERE_OPTIMA,16).
-define(SCRIPT_BIZ_EVERYWHERE_FORF,17).


%%%% GODET
-define(GODET_TPS_OFFERT,1).
-define(GODET_3_NUM,2).
-define(GODET_SMS_FORF,3).
-define(GODET_GPRS_FORF,4).
-define(GODET_VALENTIN_H,5).
-define(GODET_VALENTIN_SMS,6).
-define(GODET_GPRS_OPT,7).
-define(GODET_SMS_OPT,8).
-define(GODET_MULTI_WAP,9).
-define(GODET_MULTI_SMS,10).
-define(GODET_GESTE_TPS_OFFERT,11).
-define(GODET_GESTE_SMS,12).
-define(GODET_GESTE_3_NUM,13).
-define(GODET_PREF_712,14).
-define(GODET_OPTION_CE,15).
-define(GODET_BUSINESS_UMTS,16).
-define(GODET_OR_SS_LIM_DUR,17).
-define(GODET_OR_SS_LIM_VOL,18).
-define(GODET_OFF_RENTREE_WE,20).
-define(GODET_OFF_RENTREE_SMS,21).
-define(GODET_DATA_HEURE,22).
-define(GODET_DATA_MO,23).
-define(GODET_OFF_NOEL_WE,24).
-define(GODET_OFF_NOEL_SMS,25).
-define(GODET_OFF_ROAMING_SF,26).
-define(RATIO_GODET_OFF_ROAMING_SF, 0.85).
-define(GODET_VPN_NET,27).
-define(GODET_VPN_PRO,28).
-define(GODET_NAV_UMTS,30).
-define(GODET_MMS_OPT,31).
-define(GODET_BUSINESS_GPRS,32).
-define(GODET_BUSINESS_WIFI,33).
-define(GODET_SMS_PACK_RECH,34).
-define(GODET_MMS_OR_INT,35).
-define(GODET_SMS_OR_INT,36).
-define(GODET_DATA_OR_INT,37).
-define(GODET_BLACKBERRY,38).
-define(GODET_BLACKBERRY_ROAMING,39).
-define(GODET_HEURES_PERSO,40).
-define(GODET_HEURES_PERSO_OPTIMA,41).
-define(GODET_DATA_EDGE,42).
-define(GODET_OPTIMA_3G_EDGE_GPRS,43).
-define(GODET_BUSINESS_SF_20,44).
-define(RATIO_GODET_BUSINESS_SF_20, 0.8).
-define(GODET_BUSINESS_SF_DATA,45).


-define(NO_CUMUL,["A","C","E","G","I","K"]).


-define(USER_UNKNOWN,2).
-define(USER_RE,4).
