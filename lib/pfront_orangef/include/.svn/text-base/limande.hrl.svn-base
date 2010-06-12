%% +deftype offre()=
%%          #offre{
%%                 libelleOffre::string(),
%%                 montantOffre::integer(),
%%                 idOffre     ::string()}.
-record(offre,{libelleOffre,montantOffre,idOffre}).

%% +deftype getOffresSouscriptiblesResponse()=
%%             #getOffresSouscriptiblesResponse{
%%                          doscli    ::dossierLimande(),
%%                          listeOffre::[offre()]}.
-record(offresSouscriptibles,{doscli,listeOffre}).

%% +deftype dossierLimande()=
%%          #dossierLimande{
%%                          ligneDeMarche::string(),
%%                          declinaison  ::string(),
%%                          dossierSachem::string()}.			   
-record(dossierLimande,{'LigneDeMarche'=[],'Declinaison'=[],'DossierSachem'=[]}).

%% +deftype getOffresSouscriptiblesResponse()=
%%             #getOffresSouscriptiblesResponse{
%%                          ecran1::string(),
%%                          ecran2::string()}.
-record(mentionsLegalesOffre,{ecran1,ecran2=[]}).

%% +deftype getDescriptionOffreResponse()=
%%             #getDescriptionOffreResponse{
%%                          description::string(),
-record(getDescriptionOffreResponse,{description}).

-define(SENDER,"USSD").
