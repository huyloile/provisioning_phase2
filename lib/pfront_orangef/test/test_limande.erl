-module(test_limande).
-export([run/0,online/0]).

-include("../../pservices_orangef/test/testlimande.hrl").
-define(msisdn_test,"+33666602368").

run()->
    test_encode(),
    test_decode(),
    ok.

online()->    
    ok.


test_encode()->
    %io:format("~n************Test Encode*************~n",[]),
     Tests=[
	   {getDescriptionOffre_xml(),limande:encode_getDescriptionOffre("USSD","7")},
	   {getOffresSouscriptibles_xml(),
	    limande:encode_getOffresSouscriptibles("USSD","MOB",?msisdn_test,[])},
	   {getMentionsLegalesOffre_xml(),
 	    limande:encode_getMentionsLegalesOffre("USSD","7")},
	   {doSouscriptionOffre_xml(),
	     limande:encode_doSouscriptionOffre("USSD",?msisdn_test,"jinf",[])}
	  ],
    lists:foldl(fun({Expected,Result},Counter)->
			Expected2=envelope_request_xml(Expected),
			Result2=lists:flatten(soaplight:build_xml([],[],Result)),
			%io:format("Encoded xml: ~n~n~p~n~n~n~n",[Result2]),
			%io:format("Expected: ~n~n~p~n~n~n~n",[Expected2]),
			{Counter, Expected2} = {Counter, Result2},
			Counter+1
		end,
		0,Tests).
 
test_decode()->
    %%io:format("~n************Test DEcode*************~n",[]),
    Tests=[{getOffresSouscriptiblesResponse(),
 	    soaplight:decode_body(getOffresSouscriptiblesResponseXML(),limande)},
	   {getMentionsLegalesOffreResponse(),
 	    soaplight:decode_body(getMentionsLegalesOffreResponseXML(),limande)},
	   {getDescriptionOffreResponse(),
 	    soaplight:decode_body(getDescriptionOffreResponseXML(),limande)},
	   {doSouscriptionOffreResponse(),
 	    soaplight:decode_body(doSouscriptionOffreResponseXML(),limande)}
	  ],
    
    lists:foldl(fun({Expected,Result},Counter)->
			%%io:format("Decoded result: ~n~n~p~n~n~n~n",[Result]),
			%%io:format("Expected: ~n~n~p~n~n~n~n",[Expected]),
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

getDescriptionOffre_xml()->
	"<getDescriptionOffre xmlns=\"http://limande.orange.fr/services/souscriptionOffreV1\">"
	"<sender>USSD</sender>"
	"<IDOffre>7</IDOffre>"
	"</getDescriptionOffre>".

getOffresSouscriptibles_xml()->
	"<getOffresSouscriptibles xmlns=\"http://limande.orange.fr/services/souscriptionOffreV1\">"
	"<sender>USSD</sender>"
	"<InfoLigneDeMarche>MOB</InfoLigneDeMarche>"
	"<msisdn>33666602368</msisdn>"
	"<doscli>"
        "<ns1:LigneDeMarche xmlns:ns1=\"http://limande.orange.fr/services/dataModelV1\"/>"
        "<ns2:Declinaison xmlns:ns2=\"http://limande.orange.fr/services/dataModelV1\"/>"
	"<ns3:DossierSachem xmlns:ns3=\"http://limande.orange.fr/services/dataModelV1\"/>"
        "</doscli>"
	"</getOffresSouscriptibles>".

getMentionsLegalesOffre_xml()->
	"<getMentionsLegalesOffre xmlns=\"http://limande.orange.fr/services/souscriptionOffreV1\">"
	"<sender>USSD</sender>"
	"<IDOffre>7</IDOffre>"
	"</getMentionsLegalesOffre>".

doSouscriptionOffre_xml()->    
    "<doSouscriptionOffre xmlns=\"http://limande.orange.fr/services/souscriptionOffreV1\">"
    	"<sender>USSD</sender>"
	"<MSISDN>33666602368</MSISDN>"
	"<IDOffre>jinf</IDOffre>"
	"<doscli>"
        "<ns1:LigneDeMarche xmlns:ns1=\"http://limande.orange.fr/services/dataModelV1\"/>"
        "<ns2:Declinaison xmlns:ns2=\"http://limande.orange.fr/services/dataModelV1\"/>"
	"<ns3:DossierSachem xmlns:ns3=\"http://limande.orange.fr/services/dataModelV1\"/>"
        "</doscli>"
	"</doSouscriptionOffre>".

getDescriptionOffreResponse()->
	{getDescriptionOffreResponse,
  	  "Pendant vos vacances en Union Europeenne, pour seulement 5 euros vous disposez " 
	  "de 10 minutes de communications vers la France ou l'Union Europeenne ainsi que de "
	  "10 minutes gratuites pour recevoir vos appels !"}.
getDescriptionOffreResponseXML()->
	"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        "<soapenv:Envelope "
        "xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\""
        "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
	"<soapenv:Body>"
	"<getDescriptionOffreResponse>"
        "<DescriptionOffre>" 
  	  "Pendant vos vacances en Union Europeenne, pour seulement 5 euros vous disposez " 
	  "de 10 minutes de communications vers la France ou l'Union Europeenne ainsi que de "
	  "10 minutes gratuites pour recevoir vos appels !"
         "</DescriptionOffre>"
         "</getDescriptionOffreResponse>"
	"</soapenv:Body>"
	"</soapenv:Envelope>".

	
getMentionsLegalesOffreResponse()->
	{mentionsLegalesOffre,"Texte du 1e ecran de mentions legales","texte du 2e ecran de mentions legales"}.

getMentionsLegalesOffreResponseXML()->
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	"<soapenv:Envelope "
	"xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" 
	"xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
	"xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
	"<soapenv:Body>"
        "<getMentionsLegalesOffreResponse xmlns=\"http://limande.orange.fr/services/souscriptionOffreV1\">"
            "<MentionsLegalesOffre>"
               "<ecran1>Texte du 1e ecran de mentions legales</ecran1>"
               "<ecran2>texte du 2e ecran de mentions legales</ecran2>"
           "</MentionsLegalesOffre>"
        "</getMentionsLegalesOffreResponse>"
        "</soapenv:Body>"
   "</soapenv:Envelope>".


getOffresSouscriptiblesResponse()->
    {offresSouscriptibles,{dossierLimande,"PRO","FRPRO","0"},
     [{offre,"SMS illimite","1500","LIM1"},
      {offre,"WE infini","2500","LIM2"}]}.

getOffresSouscriptiblesResponseXML()->
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	"<soapenv:Envelope "
	"xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" 
	"xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
	"xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
	"<soapenv:Header></soapenv:Header>"
	"<soapenv:Body>"
         "<getOffresSouscriptiblesResponse xmlns=\"http://\">"
            "<ListeOffre>"
               "<LibelleOffre>SMS illimite</LibelleOffre>"
               "<MontantOffre>1500</MontantOffre>"
               "<IDOffre>LIM1</IDOffre>"
            "</ListeOffre>"
            "<ListeOffre>"
               "<LibelleOffre>WE infini</LibelleOffre>"
               "<MontantOffre>2500</MontantOffre>"
               "<IDOffre>LIM2</IDOffre>"
            "</ListeOffre>"
            "<doscli>"
               "<LigneDeMarche>PRO</LigneDeMarche>"
               "<Declinaison>FRPRO</Declinaison>"
               "<DossierSachem>0</DossierSachem>"
               "<typeFact>CMO</typeFact>"
            "</doscli>"
         "</getOffresSouscriptiblesResponse>"
      "</soapenv:Body>"
   "</soapenv:Envelope>".

doSouscriptionOffreResponse()->
    {ok,"erad6o0249"}.
doSouscriptionOffreResponseXML()->
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        "<soapenv:Envelope "
        "xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\""
        "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
        "<soapenv:Body>"
        "<doSouscriptionOffreResponse "
                "xmlns=\"http://limande.orange.fr/services/souscriptionOffreV1\">"
                "<TXID>erad6o0249</TXID>"
         "</doSouscriptionOffreResponse>"
        "</soapenv:Body>"
        "</soapenv:Envelope>".
