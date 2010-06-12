

-record(listeRcodItem,
	{codeNiveau,nbTentatives}).
-record(getRcodResponse,
	{codPlanTarifaire,
	libPlanTarifaire,
	listeRcodItem,
	nombreServicesOptionnelsContentBilling,
	numAdv,
	numClient,
	numImsi}).

%% +deftype codeConfidentielDetail()=
%%  #codeConfidentielDetail{
%%   codeNiveau   :: string(),
%%   nbTentatives :: integer()
%%  }.
-record(codeConfidentielDetail,
	{codeNiveau,
	 nbTentatives
	}).

%% +deftype rcodDetail()=
%%  #rcodDetail{
%%   codeNiveau   :: string(),
%%   nbTentatives :: integer()
%%  }.
-record(rcodDetail,
	{codeNiveau,
	 nbTentatives
	}).

-record(getVcodResponse,
	{dateDerniereModification,
	 dateDerniereVerification,
	 nbTentatives,
	 resultat 
	}).

%% +deftype getMcodResponse()=
%%  #getMcodResponse{
%%   nbTentatives :: integer()
%%  }.
-record(getMcodResponse,
	{ nbTentatives}).


%%% Records du service isRechargementParentChildPossible :
%% +deftype isRechargementParentChildPossibleResponse()=
%%  #isRechargementParentChildPossibleResponse{
%%   idDossier                                 :: string(),
%%   dateProchainRechargementCmo               :: string(),
%%   dateProchainRechargementMobicarte         :: string(),
%%   prestationsCmo                            :: [code_montant()]
%%   prestationsMobicarte                      :: [code_montant()]
%%  }.
-record(isRechargementParentChildPossibleResponse,
 	{idDossier,
 	 dateProchainRechargementCmo,
 	 dateProchainRechargementMobicarte,
 	 prestationsCmo=[],
 	 prestationsMobicarte=[]
 	 }).

%%% Records du service isRechargeableParentChild :
%% +deftype isRechargeableParentChildResponse()=
%%  #isRechargeableParentChildResponse{
%%   idDossier      :: string(),
%%   mobicarte      :: string()]
%%  }.
-record(isRechargeableParentChildResponse,
	{idDossier,
	 mobicarte}).

%%% Records du service isRechargeableCBResponse
%% +deftype isRechargeableCBResponse () = 
%%  #isRechargeableCBResponse{
%%     idDossier ::string(),
%%     mobicarte ::string(),
%%     montantMaxRechargeable :: string(),
%%     plafond ::string(),
%%     rechargementPossibles :: rechargementPossible
%% }.

-record(isRechargeableCBResponse,
	{idDossier,
	 mobicarte,
	 montantMaxRechargeable,
	 plafond,
	 rechargementsPossibles=[]
	 }).
%%% Rechord of rechargementPossible 
-record(rechargementPossible,
	{dureeValidite,
	 montantOffert,
	 montantPaye}).
	

%%% Records du service doRechargementCB( same response for Orchidee and edelweiss):
%% +deftype doRechargementCBResponse:
%% #doRechargementCBResponse()={
%%      numAutorisationPaiement :: string(),
%%      rechargement :: rechargment(),
%%      tracage ::boolean()
%%  }.
-record(doRechargementCBResponse,
	{numAutorisationPaiement,
	 rechargement,
	 tracage}).


%%% Records du service doRechargementParentChild :
%% +deftype doRechargementParentChildResponse()=
%%  #doRechargementParentChildResponse{
%%   activationPrestation  :: string()
%%   rechargement          :: recharg_parentChild()
%%  }.
-record(doRechargementParentChildResponse, 
	{activationPrestation,
	 rechargement}).

%% +deftype code_montant()=
%%  #code_montant{
%%    code    :: string(),
%%    montant :: string()
%%  }.
-record(code_montant,{code,
		      montant}).

%% +deftype recharg()=
%%  #recharg{
%%   dateProchainRechargement :: string(),
%%   mobicarte  :: bool(),
%%   prestation :: [code_montant()]
%%  }.
-record(recharg,{dateProchainRechargement,
 		 mobicarte,
 		 prestation}).

%% +deftype recharg_parentChild()=
%%  #recharg_parentChild{
%%   comptes                     :: [comptes()],
%%   dateLimiteValiditeDossier   :: string()
%%  }.
-record(rechargement,
   {comptes,
    dateLimiteValiditeDossier}).

%% +deftype comptes()=
%%  #comptes{
%%   credit                      :: string(),
%%   dateLimiteValidite          :: string(),
%%   montantFidelisation         :: string(), 
%%   pourcentageFidelisation     :: string(),
%%   uniteRestitution            :: [code_libelle()],
%%   uniteGestion                :: [code_libelle()], 
%%   planTarifaire               :: [code_libelle()],
%%   typeCompte                  :: [code_libelle()] 
%%  }.
-record(comptes,
   {credit, 
    dateLimiteValidite,
    montantFidelisation,
    pourcentageFidelisation,
    uniteRestitution,
    uniteGestion,
    planTarifaire,
    typeCompte}).

%% +deftype code_libelle()=
%%  #code_libelle{
%%   
%%   identifiant      :: string()
%%  }.
-record(code_libelle,	
   {code,
    identifiant,
    libelle}).

%% +deftype getIdentificationResponse() =
%%     #getIdentificationResponse{
%%      numClient         :: string(),
%%      idDossierOrchidee :: string(),
%%      codeOffreType     :: string()
%%     }.
-record(getIdentificationResponse, 
 	{
 	  adresseIpClient,
 	  adresseIpClient2,
 	  civiliteClient,
 	  codPlanTarifaire,
 	  codeEtatDossier,
 	  codeOffreType,
 	  codeProduit,
 	  codeSegmentCommercial,
 	  codesServicesOptionnels,
 	  derniereEtapeRecouvrement,
 	  descEtatDossier,
 	  idDossier,
 	  idSCS,
 	  idUtilisateur,
 	  indicateurClientEntreprise,
 	  libSiteRattachement,
 	  montantMoyenFacture,
 	  naturePortage,
 	  nomPrenomClient,
 	  numAdv,
 	  numCarteSim,
 	  numClient,
 	  numIMSI,
 	  segmentClient,
 	  statutPortage,
 	  typeDossier,
 	  typeOffre
 	 }).

%% +deftype getImpactSouscriptionServiceOptionnelResponse() =
%%     #getImpactSouscriptionServiceOptionnelResponse{
%%      optionInstantanee :: boolean(),
%%      servicesOptionnelsConserves :: [servOpt()],
%%      servicesOptionnelsResilies :: [servOpt()]
%%     }.
-record(getImpactSouscriptionServiceOptionnelResponse,
	{optionInstantanee,
	 servicesOptionnelsConserves=[],
	 servicesOptionnelsResilies=[]
	 }).

%% +deftype getListServiceOptionnelResponse() =
%%     #getListServiceOptionnelResponse{
%%      statusList       :: [status()],
%%      serviceOptionnel :: [servOpt()]
%%     }.
-record(getListServiceOptionnelResponse, {statusList,
					  serviceOptionnel}).

%% +deftype getServicesOptionnelsResponse() =
%%     #getServicesOptionnelsResponse{
%%      servicesOptionnelsList :: [servOpt()]
%%     }.
-record(getServicesOptionnelsResponse, {servicesOptionnelsList=[]}).

%% +deftype setServiceOptionnelResponse() =
%%     #setServiceOptionnelResponse{
%%      statusList     :: [status()]
%%     }.
-record(setServiceOptionnelResponse, {statusList}).

%% +deftype doModificationServiceOptionnelResponse() =
%%     #doModificationServiceOptionnelResponse{
%%      statusList     :: [status()]
%%     }.
-record(doModificationServiceOptionnelResponse, {}).

%% +deftype servOptResilie() =
%%     #servOptResilie{
%%      code             :: string(),
%%      libelle          :: string()
%%     }.
-record(servOptResilie, {code,
			 libelle}).

%% +deftype servOpt() =
%%     #servOpt{
%%      code             :: string(),
%%      libelle          :: string()
%%     }.
-record(servOpt, {code,
		  libelle}).

%% +deftype servOpt() =
%%     #servOpt{
%%      code             :: string(),
%%      libelle          :: string()
%%     }.
-record('Fault', {faultcode,
		  faultstring,
		  faultactor,
		  exception
		  }).

%% +deftype eCareExceptionTechnique() =
%%     #eCareExceptionTechnique{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),      
%%    param3             :: string()
%%     }.
-record('ECareExceptionTechnique',	
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3}).

%% +deftype eCareExceptionFonctionnelle() =
%%     #eCareExceptionFonctionnelle{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ECareExceptionFonctionnelle',
        {nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionDonneesInvalides() =
%%     #exceptionDonneesInvalides{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionDonneesInvalides',
        {nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionServiceOptionnelRequis() =
%%     #exceptionServiceOptionnelRequis{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionServiceOptionnelRequis',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionPlanRecouvrementIncorrect() =
%%     #exceptionPlanRecouvrementIncorrect{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionPlanRecouvrementIncorrect',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionTypeClientIncorrect() =
%%     #exceptionTypeClientIncorrect{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionTypeClientIncorrect',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionEtatDossierIncorrect() =
%%     #exceptionEtatDossierIncorrect{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionEtatDossierIncorrect',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionServiceOptionnelBloquant() =
%%     #exceptionServiceOptionnelBloquant{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionServiceOptionnelBloquant',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionEtatRecouvrementIncorrect() =
%%     #exceptionEtatRecouvrementIncorrect{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionEtatRecouvrementIncorrect',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionProduitIncorrect() =
%%     #exceptionProduitIncorrect{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionProduitIncorrect',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

%% +deftype exceptionDossierNonOrange() =
%%     #exceptionDossierNonOrange{
%%    nomComposant       :: string(),
%%    nomFamille         :: string(),
%%    codeMessage        :: string(),
%%    nomClasse          :: string(),
%%    dateException      :: string(),
%%    gravite            :: date(),
%%    param1             :: string(),
%%    param2             :: string(),
%%    param3             :: string()
%%     }.
-record('ExceptionDossierNonOrange',
	{nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

-record(serviceOptionnel, {code,
	                   inclusDansOffreType,
                           libelle,
                           codeCategoriePreferentielle,
                           codePere,
                           codeType,
                           dateActivation,
                           dateDesactivation,
                           etat,
                           libelleCategoriePreferentielle,
                           libellePere,
                           libelleType,
                           nbChangements,
                           nombreMaximumNumerosPreferentiels,
                           numerosPreferentiels,
			   optionInstantanee,
			   ponctuelle,
                           resiliable,
                           technologie}).
-record(servicesOptionnelsResilies, {code,
	                   inclusDansOffreType,
                           libelle,
                           codeCategoriePreferentielle,
                           codePere,
                           codeType,
                           dateActivation,
                           dateDesactivation,
                           etat,
                           libelleCategoriePreferentielle,
                           libellePere,
                           libelleType,
                           nbChangements,
                           nombreMaximumNumerosPreferentiels,
                           numerosPreferentiels,
                           resiliable,
                           technologie}).
-record(servicesOptionnelsConserves, {code,
	                   inclusDansOffreType,
                           libelle,
                           codeCategoriePreferentielle,
                           codePere,
                           codeType,
                           dateActivation,
                           dateDesactivation,
                           etat,
                           libelleCategoriePreferentielle,
                           libellePere,
                           libelleType,
                           nbChangements,
                           nombreMaximumNumerosPreferentiels,
                           numerosPreferentiels,
                           resiliable,
                           technologie}).

-record(technologie, {code,
                      libelle,
                      troisG}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Exception records definitions
-record('ExceptionOffreTypeInexistante',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).
-record('ExceptionServiceOptionnelImpossible',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ExceptionServiceOptionnelnexistant',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).
-record('ExceptionErreurInterne',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ExceptionDossierNonTrouve',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).
-record('ExceptionDateFacturationProche',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).
-record('ExceptionRegleNonVerifiee',
	{codeRegle,
	 messageRegle,
	 nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).
-record('ExceptionRegleGestionABPRONonVerifiee',
	{codeRegle,
	 messageRegle,
	 nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).
-record('ExceptionCoupleClientDossierInexistant',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ECareExceptionFonctionnelleCodeWrong',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ECareExceptionFonctionnelleCodeLock',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ECareExceptionFonctionnelleCodeNotInit',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ECareExceptionFonctionnelleCodeInhb',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}
).

-record('ECareExceptionFonctionnelleCodeInhbTemp',
	{nomComposant,
	 nomFamille,
	 codeMessage,
	 nomClasse,
	 dateException,
	 gravite,
	 param1,
	 param2,
	 param3
	}).
-record('ExceptionPaiement',
        {numClient,
          emetteur ,
          oper ,
          ctrl ,
          cret ,
          etat ,
          msgid ,
          nomComposant ,
          nomFamille ,
          codeMessage ,
          nomClasse ,
          dateException ,
          gravite ,
          param1 ,
          param2 ,
          param3 }).
-record('ExceptionOptionRequise',
        {nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).

-record('ExceptionOptionInterdite',
        {nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).
-record('ExceptionAncienneteRequise',
        {nomComposant,
         nomFamille,
         codeMessage,
         nomClasse,
         dateException,
         gravite,
         param1,
         param2,
         param3}).
