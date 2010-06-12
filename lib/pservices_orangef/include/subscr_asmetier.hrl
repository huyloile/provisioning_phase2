%% +deftype opt_act()= sms_30 | sms_80 | sms_130 | sms_210 | sms_300 |
%%       ow_3 |ow_6 | ow_10 | ow_20 | ow_30 | ow_tv1 | ow_tv2 | ow_spo | 
%%       one_of_sms | one_of_ow | all_sms | all_ow.

%% +deftype activ_opt() =
%%     #activ_opt{ 
%%     en_cours     :: opt_act(),           %% option en cours d'activation
%%     idDosOrchid  :: string(),            %% id dossier Orchidee   
%%     codeOffreType:: string(),            %% code offre type        
%%     listServOpt  :: [servOpt()],         %% liste services optionnels
%%     listOptResil :: [servOptResilie()]}. %% liste service optionnels resiliees
%%%% Record used in svc_activ_opt_postpaid and svc_activ_opt_cmo
%%%% to store data used to interface the webservices server asmetier.

-record(activ_opt,{en_cours,
		   idDosOrchid,
                   idUtilisateurEdlws,
                   idDosSach,
		   codeOffreType,
                   codeSegCo,
		   listServOpt,
		   listOptResil}).
