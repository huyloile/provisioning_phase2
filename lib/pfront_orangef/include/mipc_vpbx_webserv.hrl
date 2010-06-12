%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%code retour activerSituation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(CODE_OK, "0").

%%% Record du service activerSituationResponse :
%% -deftype activerSituation()=
%% -record(activerSituation  
%%        {resultat    :: resultat(),
%%}).



-record(activerSituationResponse,
        {resultat}).


%%% Record du service consulterInformationsResponse :
%% -deftype consulterInformationsResponse()=
%% -record(consulterInformationsResponse
%%        {resultat    :: resultat()
%%         resau       :: resau()
%%         membre      :: membre()
%%         nbSituationsParametrees :: integer()
%%         typeOffre               :: string()
%%})

-record(consulterInformationsResponse,
        {resultat,
         reseau,
         membre,
         nbSituationsParametrees,
         typeOffre
        }).


%%% Record du service consulterParametrageReelResponse :
%%  -deftype consulterParametrageReelResponse()=
%%  -record(consulterParametrageReelResponse
%%         {resultat     :: resultat()
%%          parametrageNumeroUnique :: parametrageNumeroUnique()
%%          parametrageRenvois :: parametrageRenvois()
%%}) 

-record(consulterParametrageReelResponse,
        {resultat,
         parametrageNumeroUnique,
         parametrageRenvois
        }).


%%% Record du service consulterSituationResponse :
%%  -deftype consulterSituationResponse()=
%%  -record(consulterSituationResponse
%%         {resultat     :: resultat()
%%          parametrageNumeroUnique :: parametrageNumeroUnique()
%%          parametrageRenvois :: parametrageRenvois()
%%}) 

-record(consulterSituationResponse,
        {resultat,
         parametrageNumeroUnique,
         parametrageRenvois
        }).

%%% Record du service listeSituationsParametreesResponse :
%%  -deftype listeSituationsParametreesResponse()=
%%  -record(listeSituationsParametreesResponse
%%         {resultat     :: resultat()
%%          listeSituations:: listeSituations()
%%}) 

-record(listeSituationsParametreesResponse,
        {resultat,
	 listeSituations
        }).


%%% Record du service situationsActiveResponse :
%%  -deftype situationActiveResponse()=
%%  -record(situationActiveResponse
%%         {resultat     :: resultat()
%%          situationActive :: Situation()
%%}) 

-record(situationActiveResponse,
        {resultat,
         situationActive
        }).


%% Basic type

-record(resultat, {codeRetour,
		 commentaire}).

-record(reseau, {codeReseau,
                 nomReseau}).

-record(membre, {nom,
                 prenom,
                 manager}).

-record(situation,
         {idSituation,
          libelleSituation
         }).

-record(versAssistante,
       {nom,
        prenom,
        numero,
        typeAppel
       }).

-record(parametrageRenvois,
        {typeRenvoi,
         versNumerosLibres,
         versAssistante,
         saufAppelsEmisDepuis
        }).

-record(versNumerosLibres, 
        {premierNumero,
         listeNumeros,
         boiteVocale
        }).

-record(parametrageNumeroUnique,
        {active,
         typeSonnerie,
         presentationNoFixe
        }).
