%% +deftype getAccesPDRReponse() =
%%     #getAccesPDRReponse{
%%      date       :: string(),
%%      heure      :: string(),
%%      codeRet    :: integer(),
%%      messageRet :: string()
%%     }.
-record(getAccesPDRReponse, {date,
			     heure,
			     codeRet,
			     messageRet}).

%% +deftype getConsultationSoldeReponse() =
%%     #getConsultationSoldeReponse{
%%      date       :: string(),
%%      heure      :: string(),
%%      codeRet    :: integer(),
%%      messageRet :: string(),
%%      resultat   :: resultat()
%%     }.
-record(getConsultationSoldeReponse, {date,
				      heure,
				      codeRet,
				      messageRet,
				      resultat}).

%% +deftype getActivationPrimesReponse() =
%%     #getActivationPrimesReponse{
%%      date       :: string(),
%%      heure      :: string(),
%%      codeRet    :: integer(),
%%      messageRet :: string(),
%%      resultat   :: resultat()
%%     }.
-record(getActivationPrimesReponse, {date,
				     heure,
				     codeRet,
				     messageRet,
				     resultat}).

%% +deftype getConsultationPrimesReponse() =
%%     #getConsultationPrimesReponse{
%%      date       :: string(),
%%      heure      :: string(),
%%      codeRet    :: integer(),
%%      messageRet :: string(),
%%      resultat   :: resultat()
%%     }.
-record(getConsultationPrimesReponse, {date,
				       heure,
				       codeRet,
				       messageRet,
				       resultat}).

%% +deftype resultat() =
%%     #resultat{
%%      codeProduit      :: string(),
%%      listeUPEs        :: [descUPE()],
%%      codeMessage      :: string(),
%%      priseEnCompteTh  :: string(),
%%      dateActivationTh :: string(),
%%      listePaliers     :: [descPalier()],
%%      priseEnCompte    :: string(),
%%      dateActivation   :: string(),
%%      solde            :: solde()
%%     }.
-record(resultat, {codeProduit,
		   listeUPEs,
		   codeMessage,
		   priseEnCompteTh,
		   dateActivationTh,
		   listePaliers,
		   priseEnCompte,
		   dateActivation,
		   solde}).

%% +deftype descUPE() =
%%     #descUPE{
%%      idUP      :: string(),
%%      libelleUP :: string(),
%%      indUPC    :: string(),
%%      cumul     :: string(),
%%      listeUPs  :: [descUP()]
%%     }.
-record(descUPE, {idUP,
		  libelleUP,
		  indUPC,
		  cumul,
		  listeUPs}).

%% +deftype descPalier() =
%%     #descPalier{
%%      idPalier      :: string(),
%%      indActivation :: string(),
%%      typeConso     :: string(),
%%      listeUPs  :: [descUP()]
%%     }.
-record(descPalier, {idPalier,
		     indActivation,
		     typeConso,
		     listeUPs}).

%% +deftype descUP() =
%%     #descUP{
%%      idUP         :: string(),
%%      libelleUP    :: string(),
%%      montant      :: string(),
%%      typeUnite    :: string(),
%%      libelleUnite :: string()
%%     }.
-record(descUP, {idUP,
		 libelleUP,
		 montant,
		 typeUnite,
		 libelleUnite}).

%% +deftype solde() =
%%     #solde{
%%      idUP      :: string(),
%%      libelleUP :: string(),
%%      listeUPs  :: [descUP()]
%%     }.
-record(solde, {idUP,
		libelleUP,
		listeUPs}).

