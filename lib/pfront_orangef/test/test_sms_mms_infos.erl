-module(test_sms_mms_infos).
-export([run/0,online/0]).
-compile(export_all).

-include("../include/sms_mms_infos.hrl").
-define(MSISDN,"+33674821521").
-define(_MSISDN,"33674821521").

%%%% This file contains the unit tests for the sms_mms_infos

run()->
    test_encode(),
    test_decode(),
    ok.

online()->    
    ok.


test_encode()->
    io:format("~n************Test Encode*************~n",[]),
     Tests=[ 
	    {'SMIListeOptions_xml'(),  sms_mms_infos:encode('SMIListeOptions',?USSD_CANAL,?MSISDN,?USSD)},
	    {'SMIIdentification_xml'(),sms_mms_infos:encode('SMIIdentification',?USSD_CANAL,?MSISDN,?USSD)},
	    {'SMIProfil_xml'(),        sms_mms_infos:encode('SMIProfil',?USSD_CANAL,?MSISDN,?USSD,"SMS")},
	    {'SMIFiltre_xml'(),        sms_mms_infos:encode('SMIFiltre',?USSD_CANAL,?MSISDN,?USSD)},
	    {'SMIListeOptionSouscriptibles_xml'(),
	     sms_mms_infos:encode('SMIListeOptionSouscriptibles',?USSD_CANAL,?MSISDN,?USSD,"SMS")},
	    {'SMITarif_xml'(),sms_mms_infos:encode('SMITarif',?USSD_CANAL,?MSISDN,?USSD,"30005","0","OFFRE3G")},
	    {'SMISouscription_xml'(),
	     sms_mms_infos:encode('SMISouscription',?USSD_CANAL,?MSISDN,?USSD,"30020","2","","","1","null")},
	    {'SMIModification_xml'(),sms_mms_infos:encode('SMIModification',?USSD_CANAL,?MSISDN,?USSD,"30020","2","","")},
	    {'SMIProlongation_xml'(),sms_mms_infos:encode('SMIProlongation',?USSD_CANAL,?MSISDN,?USSD,"30020")},
	    {'SMIResiliation_xml'(), sms_mms_infos:encode('SMIResiliation',?USSD_CANAL,?MSISDN,?USSD,"30020")}
	  ],
    lists:foldl(fun({Expected,Result},Counter)->
			Result2=lists:flatten(soaplight:build_xml([],[],Result)),
			io:format("Encoded xml: ~n~p~n~n",[Result2]),
			Expected2=envelope_request_xml(Expected),
			io:format("Expected: :~n~p~n~n~n~n",[Expected2]),
			{Counter, Expected2} = {Counter, Result2},
			Counter+1
		end,
		0,Tests).
 
test_decode()->
     io:format("~n************Test Decode*************~n",[]),
     Tests=[
%	    {'SMIListeOptionsResponse'(),soaplight:decode_body('SMIListeOptionsResponseXML'(),sms_mms_infos)},
%	    {{error,pb_communication_with_ocf_rdp_or_unknown_user},
%	     soaplight:decode_body('SMIListeOptionsResponseXML_Status_97'(),sms_mms_infos)},

	    {'SMIIdentificationResponse'(),soaplight:decode_body('SMIIdentificationResponseXML'(),sms_mms_infos)},
	    {'SMIIdentificationResponseError'(),soaplight:decode_body('SMIIdentificationResponseXML_Status_91'(),sms_mms_infos)},

	    %% SMI_Liste_Options_Souscrites
	    {'SMIProfilResponse'(),soaplight:decode_body('SMIProfilResponseXML'(),sms_mms_infos)},
	    {'SMIProfilResponseError'(),soaplight:decode_body('SMIProfilResponseXML_Status_93'(),sms_mms_infos)},

	    {'SMIFiltreResponse'(),soaplight:decode_body('SMIFiltreResponseXML'(),sms_mms_infos)},
	    {{ok,all_options_available},
	     soaplight:decode_body('SMIFiltreResponseXML_Status_91'(),sms_mms_infos)},

	    {'SMIListeOptionSouscriptiblesResponse'(),
	     soaplight:decode_body('SMIListeOptionSouscriptiblesResponseXML'(),sms_mms_infos)},
	    {{ok, {'SMIListOptionSouscriptibles', []}},
	     soaplight:decode_body('SMIListeOptionSouscriptiblesResponseXML_Status_94'(),sms_mms_infos)},

	    {'SMITarifResponse'(),soaplight:decode_body('SMITarifResponseXML'(),sms_mms_infos)},
	    {{ok,max_subcribers_number_reached},
	     soaplight:decode_body('SMITarifResponseXML_Status_91'(),sms_mms_infos)},

	    {'SMISouscriptionResponse'(),soaplight:decode_body('SMISouscriptionResponseXML'(),sms_mms_infos)},
	    {{ok,max_subcribers_number_reached},
	     soaplight:decode_body('SMISouscriptionResponseXML_Status_91'(),sms_mms_infos)},
	    {{ok,insufficient_user_balance},
	     soaplight:decode_body('SMISouscriptionResponseXML_Status_92'(),sms_mms_infos)},

	    {'SMIModificationResponse'(),soaplight:decode_body('SMIModificationResponseXML'(),sms_mms_infos)},
	    {{ok,max_subcribers_number_reached},
	     soaplight:decode_body('SMIModificationResponseXML_Status_91'(),sms_mms_infos)},

	    {'SMIProlongationResponse'(),soaplight:decode_body('SMIProlongationResponseXML'(),sms_mms_infos)},
	    {{ok,insufficient_user_balance},
	     soaplight:decode_body('SMIProlongationResponseXML_Status_92'(),sms_mms_infos)},

	    {'SMIResiliationResponse'(),soaplight:decode_body('SMIResiliationResponseXML'(),sms_mms_infos)},
	    {{ok,heading_unregistred_user},
	     soaplight:decode_body('SMIResiliationResponseXML_Status_93'(),sms_mms_infos)}
	   ],
     lists:foldl(fun({Expected,Result},Counter)->
 			io:format("Decoded result: ~n~p~n~n",[Result]),
 			io:format("Expected: ~n~p~n~n~n~n",[Expected]),
 			{Counter, Expected} = {Counter, Result},
 			Counter+1
 		end,
 		0,Tests),
     ok.

envelope_request_xml(Body)->
    "<?xml version=\"1.0\"?>"
	"<SOAP-ENV:Envelope"
	" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
	" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\""
	" xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\""
	" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
	" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
	"<SOAP-ENV:Body>" ++ Body ++
	"</SOAP-ENV:Body>"
	"</SOAP-ENV:Envelope>".

'SMIListeOptions_xml'() ->
    "<SMIListeOptions>"
	"<idCanalSouscr>"++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>" ++ ?_MSISDN ++ "</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
        "</SMIListeOptions>".   

'SMIIdentification_xml'()->
         "<SMIIdentification>"
            "<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
            "<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
         "</SMIIdentification>".

'SMIProfil_xml'() ->
    "<SMIProfil xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<TypeOption>SMS</TypeOption>"
	"</SMIProfil>".

'SMIFiltre_xml'()->
    "<SMIFiltre>"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"</SMIFiltre>".

'SMIListeOptionSouscriptibles_xml'()->
        "<SMIListeOptionSouscriptibles xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<TypeOption>SMS</TypeOption>"
	"</SMIListeOptionSouscriptibles>".

'SMITarif_xml'()->
    "<SMITarif xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<IdOption>30005</IdOption>"
	"<TypeOffre>0</TypeOffre>"
	"<CompOffre>OFFRE3G</CompOffre>"
	"</SMITarif>".

'SMISouscription_xml'()->
    "<SMISouscription xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<IdOption>30020</IdOption>"
	"<CompOption1>2</CompOption1>"
	"<TypeOffre>1</TypeOffre>"
	"<CompOffre>null</CompOffre>"
	"</SMISouscription>".

'SMIModification_xml'()->
    "<SMIModification xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<IdOption>30020</IdOption>"
	"<CompOption1>2</CompOption1>"
	"</SMIModification>".

'SMIProlongation_xml'()->
    "<SMIProlongation xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<IdOption>30020</IdOption>"
	"</SMIProlongation>".

'SMIResiliation_xml'()->
    "<SMIResiliation xmlns=\"http://...\">"
	"<idCanalSouscr>" ++ ?USSD_CANAL ++ "</idCanalSouscr>"
	"<msisdn>33674821521</msisdn>"
	"<groupe>" ++ ?USSD ++ "</groupe>"
	"<IdOption>30020</IdOption>"
	"</SMIResiliation>".

%% A refaire
'SMIListeOptionsResponse'() ->
    {ok,{'SMIListeOptions',?RESPONSE_OK,?_MSISDN, "ENT", "N", "123456121234561", "N", "2", "6", "N"}}.

'SMIIdentificationResponse'()->
{'SMIIdentificationResponse',[{msisdn,"33674821521"},
                              {status,"90"},
                              {'TypeOffre',"0"},
                              {'CompOffre',"OFFRE3G"},
                              {'Imei',"3550930112345678"},
                              {'ClasseImage',"5"},
                              {'ClasseVideo',"7"},
                              {'ClasseAlertVideo',"1"}]}.

'SMIIdentificationResponseError'()->
{'SMIIdentificationResponse',[{msisdn,"33674821521"},{status,"91"}]}.


'SMIProfilResponse'() ->
{'SMIProfilResponse',[{msisdn,"33674821521"},
                      {status,"90"},
                      {'ListeOption',[{'IdOption',"30010"},
                                      {'CompOption1',[]},
                                      {'CompOption2',[]},
                                      {'CompOption3',[]},
                                      {'Facturation',"A"},
                                      {'Promo',[]},
                                      {'DureePromo',[]}]},
                      {'ListeOption',[{'IdOption',"30020"},
                                      {'CompOption1',"9"},
                                      {'CompOption2',[]},
                                      {'CompOption3',[]},
                                      {'Facturation',"A"},
                                      {'Promo',"TRY"},
                                      {'DureePromo',"30"}]}]}.


'SMIProfilResponseError'() ->
{'SMIProfilResponse',[{msisdn,"33674821521"},{status,"93"}]}.

%% Why returns SMIListOptions and not FiltreResponse ?
'SMIFiltreResponse'() ->
    {ok, {'SMIListOptions', [{'SMIoption',"50900","","","","","","","",""},
			     {'SMIoption',"60010","","","","","","","",""}]}}.

'SMIListeOptionSouscriptiblesResponse'() ->
    {ok, {'SMIListOptionSouscriptibles', [{'SMIoption',"30090","","","","","","","SMSBlague","SMS"},
					  {'SMIoption',"30020","","","","","","","SMSHoroscope","SAS"}]}}.

'SMITarifResponse'()->
    {ok, {'SMITarif',"A",0,2000,"PACKSPORT",30}}.

'SMISouscriptionResponse'()->
    {ok, {'SMISouscription',"20080113",2000,"20080213"}}.

'SMIModificationResponse'()->
    {ok, {'SMIModification',"20080113"}}.

'SMIProlongationResponse'()->
    {ok, {'SMIProlongation',2000,"20080213"}}.

'SMIResiliationResponse'()->
    {ok, {'SMIResiliation'}}.

'SMIListeOptionsResponseXML'() ->
        header()++
	"<SMIlisteOptionsResponse xmlns=\"http://...\">"
         "<status>"++ ?RESPONSE_OK ++ "</status>"
         "<msisdn>"++ ?_MSISDN ++ "</msisdn>"
         "<codeOffre>ENT</codeOffre>"
         "<controleParental>N</controleParental>"
         "<codeTac>123456121234561</codeTac>"
         "<abonneConnu>N</abonneConnu>"
         "<classeImage>2</classeImage>"
         "<classeVideo>6</classeVideo>"
         "<compatAlertVideo>N</compatAlertVideo>"
         "<nbOptionsSouscrites>0</nbOptionsSouscrites>"
         "<suspEnvoiMms>N</suspEnvoiMms>"
         "<listSouscrOption>"
            "<souscOption>"
               "<idOption>10011</idOption>"
               "<tarif>0</tarif>"
               "<idTarif>1900</idTarif>"
               "<tarifHorsPromo>2000</tarifHorsPromo>"
               "<idTarifHorsPromo>1100</idTarifHorsPromo>"
               "<renouvellement>30</renouvellement>"
               "<uniteRenouvellement>J</uniteRenouvellement>"
               "<typeFacturation>PROMBASE</typeFacturation>"
               "<typeFacturationHorsPromo>MENSUEL</typeFacturationHorsPromo>"
               "<ordre>0</ordre>"
               "<libOption>SMS Météo</libOption>"
               "<descOption></descOption>"
               "<presOption></presOption>"
               "<flagOptionSouscrite>0</flagOptionSouscrite>"
               "<idCompOption>0</idCompOption>"
               "<ordreComOption>0</ordreComOption>"
            "</souscOption>"
            "<souscOption>"
               "<idOption>20006</idOption>"
               "<tarif>0</tarif>"
               "<idTarif>1901</idTarif>"
               "<tarifHorsPromo>2000</tarifHorsPromo>"
               "<idTarifHorsPromo>1101</idTarifHorsPromo>"
               "<renouvellement>30</renouvellement>"
               "<uniteRenouvellement>J</uniteRenouvellement>"
               "<typeFacturation>PROMBASE</typeFacturation>"
               "<typeFacturationHorsPromo>MENSUEL</typeFacturationHorsPromo>"
               "<ordre>0</ordre>"
               "<libOption>SMS Actualité</libOption>"
               "<descOption></descOption>"
               "<presOption></presOption>"
               "<flagOptionSouscrite>0</flagOptionSouscrite>"
               "<idCompOption>0</idCompOption>"
               "<ordreComOption>0</ordreComOption>"
            "</souscOption>"
         "</listSouscrOption>"
      "</SMIlisteOptionsResponse>" ++
	footer().

'SMIListeOptionsResponseXML_Status_97'() ->
        header()++
	"<SMIlisteOptionsResponse xmlns:ns1=\"http://www.orange.fr/smsmmsinfos/\">"
	"<status>97</status>"
	"<msisdn>"++ ?_MSISDN ++"</msisdn>"
	"<classeImage>0</classeImage>"
	"<classeVideo>0</classeVideo>"
	"<nbOptionsSouscrites>0</nbOptionsSouscrites>"
	"</SMIlisteOptionsResponse>" ++
	footer().


'SMIIdentificationResponseXML_Status_91'()->
    header()++
	"<SMIIdentificationResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>91</status>"   
	"</SMIIdentificationResponse>"++
	footer().

'SMIIdentificationResponseXML'()->
    header()++

	"<SMIIdentificationResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<TypeOffre>0</TypeOffre>"
	"<CompOffre>OFFRE3G</CompOffre>"
	"<Imei>3550930112345678</Imei>"
	"<ClasseImage>5</ClasseImage>"
	"<ClasseVideo>7</ClasseVideo>"
	"<ClasseAlertVideo>1</ClasseAlertVideo>"
	"</SMIIdentificationResponse>"++
	footer().

'SMIProfilResponseXML'()->
    header()++
	"<SMIProfilResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<ListeOption>"
	"<IdOption>30010</IdOption>"
	"<CompOption1></CompOption1>"
	"<CompOption2></CompOption2>"
	"<CompOption3></CompOption3>"
	"<Facturation>A</Facturation>"
	"<Promo></Promo>"
	"<DureePromo></DureePromo>"
	"</ListeOption>"
	"<ListeOption>"
	"<IdOption>30020</IdOption>"
	"<CompOption1>9</CompOption1>"
	"<CompOption2></CompOption2>"
	"<CompOption3></CompOption3>"
	"<Facturation>A</Facturation>"
	"<Promo>TRY</Promo>"
	"<DureePromo>30</DureePromo>"
	"</ListeOption>"
	"</SMIProfilResponse>"++
	footer().

'SMIProfilResponseXML_Status_93'()->
    header()++
	"<SMIProfilResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>93</status>"
	"</SMIProfilResponse>"++
	footer().

'SMIFiltreResponseXML'()->
    header()++
     "<SMIFiltreResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<ListeOption>"
	   "<IdOption>50900</IdOption>"
	"</ListeOption>"
	"<ListeOption>"
	   "<IdOption>60010</IdOption>"
	"</ListeOption>"
     "</SMIFiltreResponse>"++
	footer().

'SMIFiltreResponseXML_Status_91'()->
    header()++
	"<SMIFiltreResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>91</status>"
	"</SMIFiltreResponse>"++
	footer().

'SMIListeOptionSouscriptiblesResponseXML'()->
    header()++
	"<SMIListeOptionSouscriptibles xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<ListeOption>"
	"<IdOption>30090</IdOption>"
	"<Libelle>SMSBlague</Libelle>"
	"<TypeRub>SMS</TypeRub>"
	"</ListeOption>"
	"<ListeOption>"
	"<IdOption>30020</IdOption>"
	"<Libelle>SMSHoroscope</Libelle>"
	"<TypeRub>SAS</TypeRub>"
	"</ListeOption>"
	"</SMIListeOptionSouscriptibles>"++
	footer().


'SMIListeOptionSouscriptiblesResponseXML_Status_94'()->
    header()++
	"<SMIListeOptionSouscriptibles xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>94</status>"
	"</SMIListeOptionSouscriptibles>"++
	footer().

'SMITarifResponseXML'()->
    header()++
	"<SMITarifResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<Facturation>A</Facturation>"
	"<TarifAFacturer>0</TarifAFacturer>"
	"<TarifHorsPromo>2000</TarifHorsPromo>"
	"<TypePromo>PACKSPORT</TypePromo>"
	"<DureePromo>30</DureePromo>"
	"</SMITarifResponse>"++
	footer().

'SMITarifResponseXML_Status_91'()->
    header()++
	"<SMITarifResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>91</status>"
	"</SMITarifResponse>"++
	footer().

'SMISouscriptionResponseXML'()->
    header()++
	"<SMISouscriptionResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<DateEffet>20080113</DateEffet>"
	"<TarifFacture>2000</TarifFacture>"
	"<DateFinValidite>20080213</DateFinValidite>"
	"</SMISouscriptionResponse>"++
	footer().

'SMISouscriptionResponseXML_Status_91'()->
    header()++
	"<SMISouscriptionResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>91</status>"
	"</SMISouscriptionResponse>"++
	footer().

'SMISouscriptionResponseXML_Status_92'()->
    header()++
	"<SMISouscriptionResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>92</status>"
	"</SMISouscriptionResponse>"++
	footer().

'SMIModificationResponseXML'()->
    header()++
	"<SMIModificationResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<DateEffet>20080113</DateEffet>"
	"</SMIModificationResponse>"++
	footer().

'SMIModificationResponseXML_Status_91'()->
    header()++
	"<SMIModificationResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>91</status>"
	"</SMIModificationResponse>"++
	footer().

'SMIProlongationResponseXML'()->
    header()++
	"<SMIProlongationResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"<TarifFacture>2000</TarifFacture>"
	"<DateFinValidite>20080213</DateFinValidite>"
	"</SMIProlongationResponse>"++
	footer().

'SMIProlongationResponseXML_Status_92'()->
    header()++
	"<SMIProlongationResponse xmlns=\"http://...\">"
	"<msisdn>33674821521</msisdn>"
	"<status>92</status>"
	"</SMIProlongationResponse>"++
	footer().

'SMIResiliationResponseXML'()->
    header()++
	"<SMIResiliationResponse xmlns=\"http://\">"
	"<msisdn>33674821521</msisdn>"
	"<status>90</status>"
	"</SMIResiliationResponse>"++
	footer().

'SMIResiliationResponseXML_Status_93'()->
    header()++
	"<SMIResiliationResponse xmlns=\"http://\">"
	"<msisdn>33674821521</msisdn>"
	"<status>93</status>"
	"</SMIResiliationResponse>"++
	footer().

header()->
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\""
	"xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
	"xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
	"<soapenv:Body>".
footer()->
	"</soapenv:Body>"
	"</soapenv:Envelope>".

