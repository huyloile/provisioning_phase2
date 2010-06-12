%% +deftype one2one_offer()= #one2one_offer {  
%%                         code          :: string(),
%%                         short_desc    :: string(),
%%                         long_desc     :: string(),
%%                         labels        :: [string()]}.
%%%
%% +deftype time() = {integer(),integer(),integer()}.
%%%
%% +deftype day() = 
%%             {on | off,
%%              time(),
%%              time()}.
%%%
%% +deftype week_schedule() = #week_schedule {
%%                                monday    :: day(),
%%                                tuesday   :: day(),
%%                                wednesday :: day(),
%%                                thursday  :: day(),
%%                                friday    :: day(),
%%                                saturday  :: day(),
%%                                sunday    :: day()}.
%%%
%% +deftype process_event_resp() = # process_event_resp {
%%                 code      :: string(), %% Offer Code
%%                 numdossier:: string(), %% MSISDN
%%                 idsession :: string(), %% session ID of OTO
%%                 codeerreur:: string    %% "00" | "01" | "02" | "03"
%%                 }.
%%%
%% +deftype remontee_stat() = #remontee_stat {
%%                 idsession     :: string(),  %% sent by OTO, never modified
%%                 numdossier    :: string(),  %% MSISDN
%%                 code          :: string(),  %% Offer Code
%%                 heureecoute   :: string(),  %% 2004-08-31 14:30:00
%%                 indecoute     :: string(),  %% "T" | "P"
%%                 dureemessage  :: integer(), %% nb of pages for complete msg
%%                 dureeecoute   :: integer(), %% nb of seen pages
%%                 canalabout    :: string(),  %% unused
%%                 indactivation :: string(),  %% "" | "O"
%%                 param1        :: string(),  %% unused
%%                 param2        :: string(),  %% unused
%%                 param3        :: string()   %% unused
%%                 }.
%%%
%% +deftype o2o_data() = #o2o_data {
%%                 offer         :: string(),
%%                 numdossier    :: string(),
%%                 idsession     :: string(),
%%                 success_page  :: string()
%%                 }.

-define(ONE2ONE_OFFER,one2one_offer).
-define(PROCESS_EVENT_TAG,     'ProcessEvent').
-define(PROCESS_EVENT_RESP_TAG,'ProcessEventResponse').
-define(EVENT_TAG,             'event').
-define(PACKAGE_TAG,           'package').
-define(FIELDS_TAG,            'fields').
-define(FIELD_TAG,             'field').
-define(NAME_TAG,              'name').
-define(VALUE_TAG,             'value').

-define(DEMANDE_DE_CALCUL,     "DemandeCalcul").
-define(REMONTEE_STAT,         "RemonteeStat").
-define(IDCANAL_NAME,          "IDCANAL").
-define(IDCANAL_VALUE,         "USSD").

-define(CODERETOUR_NAME,       "CODERETOUR").
-define(NUMDOSSIER_NAME,       "NUMDOSSIER").
-define(IDSESSION_NAME,        "IDSESSION").
-define(ID_OFFRE_NAME,         "IDOFFRE").
-define(HEURE_ECOUTE_NAME,     "HEUREECOUTE").
-define(INDECOUTE_NAME,        "INDECOUTE").
-define(DUREE_MESSAGE_NAME,    "DUREEMESSAGE").
-define(DUREE_ECOUTE_NAME,     "DUREEECOUTE").
-define(CANAL_ABOUT_NAME,      "CANALABOUT").
-define(CANAL_ABOUT_VALUE,     "USSD").
-define(INDACTIVATION_NAME,    "INDACTIVATION").
-define(PARAM1_NAME,           "PARAM1").
-define(PARAM2_NAME,           "PARAM2").
-define(PARAM3_NAME,           "PARAM3").
-define(ATTRIBUTE_TAG,         'attribute').

-record(?ONE2ONE_OFFER,{code,short_desc,long_desc,labels}).

%%% week_schedule example
%%		{monday,    {on, {07,30,00},{22,30,00}}},
%%		{tuesday,   {on, {07,30,00},{22,30,00}}},
%%		{wednesday, {on, {07,30,00},{22,30,00}}},
%%		{thursday,  {on, {07,30,00},{22,30,00}}},
%%		{friday,    {on, {07,30,00},{22,30,00}}},
%%		{saturday,  {on, {07,30,00},{22,30,00}}},
%%		{sunday,    {off, {07,30,00},{22,30,00}}}}
-record(week_schedule,{monday,tuesday,wednesday,thursday,friday,
		       saturday,sunday}).
-record(process_event_resp,{code,numdossier,idsession,codeerreur}).
-record(remontee_stat,{idsession,numdossier,code,heureecoute,indecoute,
		       dureemessage,dureeecoute,canalabout="",
		       indactivation="",param1="",param2="",param3=""}).

-record(o2o_data,{offer=undefined,numdossier,idsession,success_page}).

%% +deftype date() = 
%%                   {{integer(),integer(),integer()},
%%                    {integer(),integer(),integer()}}.
