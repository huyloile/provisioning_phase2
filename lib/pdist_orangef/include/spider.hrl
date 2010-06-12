
%% to store in Session variables
-define(SPIDER_KEY,spider_info).

%% +deftype spider_response()=
%%  #spider_response{ file       :: file(),
%%                         bundles    :: [bundle()],
%%                         statusList :: [status()] }.
%%                         availability:: not_available/available/out_of_date/request_failed
%%                         version    :: string()

-record(spider_response,{file,bundles,statusList,
			 availability=available,
			 version="G4R3"}).


%% +deftype bundle()=
%%  #bundle{
%%	  bundleLevel          :: string(),
%%	  priorityType         :: string(),
%%	  restitutionType      :: string(),
%%	  bundleType           :: string(),
%%	  bundleDescription    :: string(),
%%	  exhaustedLabel       :: string(),
%%	  desactivationDate    :: string(),
%%	  reactualDate         :: string(),
%%        reinitDate           :: string(),
%%	  bundleAdditionalInfo :: string(),
%%	  credits              :: string(),
%%	  previousPeriodLastUseDate :: string(),
%%	  thresholdFlag        :: string(),
%%	  firstUseDate         :: string(),
%%        lastUseDate          :: string(),
%%        bundleStatus         :: string()}.
%%

-record(bundle, {
	  bundleLevel,
	  priorityType,
	  restitutionType,
	  bundleType,
	  bundleDescription,
	  exhaustedLabel,
	  desactivationDate,
	  reactualDate,
	  reinitDate,
	  bundleAdditionalInfo,
	  credits,
	  previousPeriodLastUseDate,
	  thresholdFlag,
	  firstUseDate,
	  lastUseDate,
          bundleStatus
	 }).

%% +deftype credit()=
%%  #credit{ name           :: string(),
%%           unit           :: string(),
%%           value          :: string(),
%%           additionalInfo :: string() }.

-record(credit, {name,      %% "balance"|"consumed"|"rollOver"|"bonus"
		 unit,
		 value,
		 additionalInfo}).


%% +deftype amount()=
%%  #amount{ name           :: string(),
%%           currency       :: string(),
%%           allTaxesAmount :: string() }.

-record(amount, {name,
		 currency,
		 allTaxesAmount}).

%% +deftype file()=
%%  #file{ 
%%         custName      :: string(),
%%         custMsisdn    :: string(),
%%         custImsi      :: string(),
%%         fileState     :: string(),
%%         nextInvoice   :: string(),
%%         invoiceDate   :: string(),
%%         validityDate   :: string(),
%%         durationHf    :: string(),
%%         offerType     :: string(),
%%         amounts       :: [amount()],
%%         offerPOrSUid  :: string(),
%%         fileRestitutionType :: string(),
%%         frSpecificPrepaidOfferValue :: string() }.

-record(file,{custName,
	      custMsisdn,
	      custImsi,
	      fileState,
	      nextInvoice,
	      invoiceDate,
	      validityDate,
	      durationHf,
	      offerType,
	      amounts,
	      offerPOrSUid,
	      fileRestitutionType,
              frSpecificPrepaidOfferValue
	     }).

%% +deftype status()=
%%  #status{ statusCode        :: integer(),
%%           statusName        :: string(),
%%           statusDescription :: string()}.
-record(status, {statusCode,
		 statusName,
		 statusDescription}).

%% +deftype unite()=
%%  #unite{ nom     :: string(),
%%          libelle :: string()
%%        }.
-record(unite, {nom,
		libelle}).

%% Error codes.
-define(SERVICE_INDISPONIBLE, "02").
-define(ACCES_REFUSE, "03").
-define(PROBLEME_TECHNIQUE, "04").
-define(DOSSIER_INCONNU, "05").
