-define(USSD,"USSD").
-define(USSD_CANAL,"50"). 

-define(TypeOffre, {'TypeOffre', [{"0","FAPRO"},
				  {"1","MOB"},
				  {"2","CMO"},
				  {"3","MVNO"},
				  {"4","ENT"}]}).

-define(ClasseAlertVideo, {'ClasseAlertVideo', [{"0",not_compatible},
						{"1",compatible}]}).

-define(RESPONSE_OK, "90").
-define(Status, [{"90",all_request,ok},
		 {"91",'SMIFiltreResponse',{ok,all_options_available}},
		 {"91",'SMITarifResponse',{ok,max_subcribers_number_reached}},
		 {"91",'SMISouscriptionResponse',{ok,max_subcribers_number_reached}},
		 {"91",'SMIModificationResponse',{ok,max_subcribers_number_reached}},
		 %% L'utilisateur est MVNO ou INCONNU pour OCF/RDP
		 {"91",all_request,{error,unknown_user}}, 
		 {"92",all_request,{ok,insufficient_user_balance}},
		 %% L'abonne est connu mais n'a pas souscrit a aucune option
		 {"93",all_request,{ok,heading_unregistred_user}}, 
		 {"94",all_request,ok},
		 %%internal Error: Le canal de souscription appelant n'est pas USSD ou SVI
		 {"95",'SMIListeOptionsResponse',{error,idCanalSouscription_should_be_ussd}}, 
		 {"96",all_request,{error, sachem_technical_problem}},
		 %% Probleme de communication avec OCF/RDP ou msisdn inconnu d'Orange
		 {"97",'SMIListeOptionsResponse',{error,pb_communication_with_ocf_rdp_or_unknown_user}},
		 {"97",all_request,{error, sms_mms_infos_technical_problem}},
		 {"98",all_request,{error, ocf_rdp_technical_problem}},
		 %% Probleme technique SMS-MMS Infos
		 {"99",'SMIListeOptionsResponse',{error, ocf_rdp_technical_problem}},
		 {"99",all_request,{error, unknown_error}}]).

-record('SMIIdentification',{typeOffre,compOffre,imei,classeImage,classeVideo,classeAlertVideo}).
-record('SMIListOptions',{options}).
-record('SMIoption',{id,complement_1=[],complement_2=[],complement_3=[],facturation=[],
		     promo=[],duration=[],libelle=[],typeRub=[]}).
-record('SMITarif',{facturation_type,promotion_price,price,promotion_type,promotion_duration}).
-record('SMISouscription',{dateEffet,tarifFacture,dateFinValidite}).
-record('SMIModification',{dateEffet}).
-record('SMIProlongation',{tarifFacture,dateFinValidite}).
