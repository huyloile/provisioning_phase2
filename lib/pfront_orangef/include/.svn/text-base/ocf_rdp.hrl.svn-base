%% +deftype ocf_info_client() =
%%     #ocf_info_client{
%%        msisdn       :: string(), %%%% 336.....
%%        imsi         :: string(),
%%        creationDate :: date(),
%%        lastUpdate   :: date(),
%%        ussd_level   :: 1 | 2 | 3 | 4 ,  
%%        tac          :: string(),
%%        terminalCommercialName :: string(),
%%        imei         :: string(),
%%        tech_seg     :: undefined | string(),
%%        segmentCode  :: string(),
%%        filestate    :: string(),
%%        customerId   :: integer(),
%%        nsc          :: string(),
%%        nsce         :: string(),
%%        dataorigin   :: string(),
%%        deltaT1Date  :: date(),
%%        uaRadio      :: string(),
%%        uaProf       :: string(),
%%        prepaidFlag :: string(),
%%        saleOutlet   :: string(),
%%        mmscompatibilityTAC:: 0 | 1,
%%        java_enabled  :: 0 | 1,
%%        sachemServices :: term}.

-record(ocf_info_client,{
	  msisdn,
	  imsi,
	  creationDate,
	  lastUpdate,
	  ussd_level,
	  tac,
	  terminalCommercialName,
	  imei,
	  tech_seg,
	  segmentCode,
	  filestate,
	  customerId,
	  nsc,
	  nsce,
	  dataorigin,
	  deltaT1Date,
	  uaRadio,
	  uaProf,
	  prepaidFlag,
	  saleOutlet,
	  mmscompatibilityTAC,
	  java_enabled,
	  sachemServices}).

%% +deftype ocf_subscription() =
%%     #ocf_subscription{
%%        email1       :: string(), %% xxx@yyy.zzz
%%        email2       :: string(),
%%        email3       :: string(),
%%        mailBoxStatus:: integer(),
%%        activePortal :: bool(),
%%        mmsBlacklist :: bool(),
%%        smsInfo      :: string()}.

-record(ocf_subscription,{
	  email1,
	  email2,
	  email3,
	  mailBoxStatus,
	  activePortal,
	  mmsBlacklist,
	  smsInfo}).

%% error code
-define(IMSI_UNKNOW,11).
-define(MULTIPLE_SOUSCRIPTION,13).
-define(INACTIF_USER,20).
-define(INVALID_REQUEST,16).

%% +deftype tech_seg_int() = integer().
%% +deftype tech_seg_code() = string().
%% +deftype tech_seg() = {tech_seg_int(), string()}.

%% Technological segments special values.
-define(OCF_NOT_QUERIED_YET, 0).
%% Network problem, decoding failed, multiple subscription...
-define(OCF_QUERY_FAILED, 1).
%% OCF returned an empty TechnologicalSegment tag.
-define(OCF_DOES_NOT_KNOW, 2).
%% OCF did not give a TechnologicalSegment tag at all.
-define(OCF_NO_FIELD, 3).
%% OCF indicated a code which is not in ocf_rdp::tech_segs_mapping.
-define(OCF_UNKNOWN_CODE, 4).

%% +deftype batch_ocf_config() =
%%     #batch_ocf_config{
%%        file_regexp  :: string(),
%%        delete_regexp:: string(),
%%        dir          :: string(),
%%        backup_dir   :: string(),
%%        max_delete   :: integer(),
%%        delete_pause :: integer(), %% in ms
%%        limite_hours :: time(), 
%%        nodes        :: [NodeAtHost::atom()],
%%        read         :: integer(),
%%        update       :: integer(),
%%        delete       :: integer()}.

-record(batch_ocf_config,
	{file_regexp="USSD[0-9][0-9][0-9]*",
	 delete_regexp="delete_imsi.[a-z]",
	 dir="lib/pfront_orangef/priv",
	 backup_dir="lib/pfront_orangef/priv",
	 max_delete=10000, 
	 delete_pause=500, %% in ms
	 limite_hours={5,0,0}, %%% heure local
	 nodes=[possum@localhost],
	 read=0,
	 update=0,
	 delete=0}).


%% +deftype sub_of() = string(). %%("mobi" | "cmo" | "dme" |
%%                               %% "postpaid" | "omer" | "virgin_prepaid" |
%%                               %% "virgin_comptebloque").

%% +deftype client() =
%%     #client{
%%        uid          :: string(),
%%        imsi         :: string(),
%%        msisdn       :: string(),
%%        tac          :: string(),
%%        level        :: integer(),
%%        etat_dossier :: string(),
%%        subscription :: sub_of(),
%%        old_imsi     :: string(), 
%%        old_msisdn   :: string(),
%%        imei         :: string(),
%%        tech_seg     :: string()}.
-record(client,{uid,imsi,msisdn,tac,level,etat_dossier,subscription,old_imsi,
		old_msisdn,imei,tech_seg,segCo,paiementMode}).


%% +deftype ocf_option() =
%%     #ocf_option{
%%       prest_code     ::string(),
%%       end_date       ::date()}.

-record(ocf_option,{
	  prest_code,
	  end_date}).
