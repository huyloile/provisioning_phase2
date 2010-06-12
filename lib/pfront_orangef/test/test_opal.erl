-module(test_opal).

-export([run/0, online/0]).
-define(msisdn, "0612345678").
-define(TU, "CO").
-define(idRecompense, "40").
-define(prix, "1000").

online() ->
    ok.

run() ->
    test_dossier(),
    test_encode(),
    test_decode().

test_dossier() ->
   "0612345678" = opal:dossier("0612345678"),
   "0612345678" = opal:dossier("+33612345678").

test_encode() ->
    lists:foldl(
      fun({{Env_ns, Body_ns, Body}, Expected}, Count) ->
	      Result = lists:flatten(soaplight:build_xml(Env_ns,Body_ns,Body)),
	      {Count, identical} = {Count, compare(Expected, Result)},
	      Count + 1
      end,
      1,
      [{opal:encode_consult_account(?msisdn), consult_account_xml()},
       {opal:encode_consult_catalogue(?msisdn), consult_catalogue_xml()},
       {opal:encode_consult_catalogue_with_TU(?msisdn,?TU), consult_catalogue_with_TU_xml(?TU)},
       {opal:encode_activate_present(?msisdn, ?idRecompense, ?prix), activate_present_xml()}]).

test_decode() ->
    lists:foldl(
      fun({Body, Expected_term}, Count) ->
	      {Count,Expected_term} = {Count,soaplight:decode_body(Body,opal)},
	      Count + 1
      end,
      1,
      [{consult_account_response_xml("true", "true", "true", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, adherentM5Plus, cible, cibleM5BO]}},
       {consult_account_response_xml("true", "true", "true", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, adherentM5Plus, cible]}},
       {consult_account_response_xml("true", "true", "false", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, adherentM5Plus, cibleM5BO]}},
       {consult_account_response_xml("true", "true", "false", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, adherentM5Plus]}},
       {consult_account_response_xml("true", "false", "true", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, cible, cibleM5BO]}},
       {consult_account_response_xml("true", "false", "true", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, cible]}},
       {consult_account_response_xml("true", "false", "false", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent, cibleM5BO]}},
       {consult_account_response_xml("true", "false", "false", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},adherent]}},
       {consult_account_response_xml("false", "true", "true", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},adherentM5Plus, cible, cibleM5BO]}},
       {consult_account_response_xml("false", "true", "true", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},adherentM5Plus, cible]}},
       {consult_account_response_xml("false", "true", "false", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},adherentM5Plus, cibleM5BO]}},
       {consult_account_response_xml("false", "true", "false", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},adherentM5Plus]}},
       {consult_account_response_xml("false", "false", "true", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},cible, cibleM5BO]}},
       {consult_account_response_xml("false", "false", "true", "false"),
	{consulterSoldeReponse, [{codeRet,"0"},cible]}},
       {consult_account_response_xml("false", "false", "false", "true"),
	{consulterSoldeReponse, [{codeRet,"0"},cibleM5BO]}},
       {consult_account_response_xml("false", "false", "false", "false"),
	{consulterSoldeReponse, [{codeRet,"0"}]}},

       {consult_catalogue_response_xml(),
	{getConsultationCadeauxReponse,
	 [{codeRet,"0"},
	  {solde, "2500", "18/04/2006"},
	  {echeance, "50", "31/01/2007"},
	  {type_usage, ["CO", "AB"]},
	  {recompenses, [{"50","100","","4","CO"},
			 {"51", "50","","4","CO"},
			 {"55", "2000","","5","CO"},
			 {"80", "200","","10","AB"}
			]}]}},

       {activate_present_response_xml(),
	{getActivationPrimeReponse,
	 [{codeRet,"0"},
	  {solde, "2500"}]}}]).

compare(Xs, Ys) ->
    compare(Xs, Ys, []).

compare([X|Xs], [X|Ys], Acc) ->
    compare(Xs, Ys, [X|Acc]);
compare([], [], _) ->
    identical;
compare(Expected, Result, Reversed_buffer) ->
    Buffer = lists:reverse(lists:sublist(Reversed_buffer, 15)),
    {differ,
     Buffer ++ lists:sublist(Expected, 15),
     Buffer ++ lists:sublist(Result, 15)}.

envelope_request_xml(Body) ->
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
    
consult_account_xml() ->
    envelope_request_xml(
    "<consulterSolde>"
      "<dossier>"?msisdn"</dossier>"
      "<canal>USSD</canal>"
      "</consulterSolde>").

consult_catalogue_xml() ->
    envelope_request_xml(
      "<consulterCadeaux>"
      "<dossier>"?msisdn"</dossier>"
      "<canal>USSD</canal>"
      "<indRestitution>3</indRestitution>"
      "</consulterCadeaux>").

consult_catalogue_with_TU_xml(TU) ->
    envelope_request_xml(
      "<consulterCadeaux>"
      "<dossier>"?msisdn"</dossier>"
      "<canal>USSD</canal>"
      "<idTypeUsage>"?TU"</idTypeUsage>"
      "<indRestitution>2</indRestitution>"
      "</consulterCadeaux>").

activate_present_xml() ->
    envelope_request_xml(
      "<activerPrime>"
      "<dossier>"?msisdn"</dossier>"
      "<canal>USSD</canal>"
      "<idRecompense>40</idRecompense>"
      "<prix>1000</prix>"
      "</activerPrime>").

consult_account_response_xml(Is_adherent, Is_adherent_m5plus, Is_cible, Is_cible_m5bO) ->
    "<consulterSoldeReponse>"
	"	<date>18/04/2006</date>"
	"	<heure>15:58:41</heure>"
	"	<codeRet>0</codeRet>"
	"	<messageRet/>"
	"	<requete>"
	"	        <dossier>"?msisdn"</dossier>"
	"	        <canal>USSD</canal>	"
	"		<donneesClient>	"
	"			<idDossierOEE>1234567890 </idDossierOEE>"
	"			<numeroClient>0061295590</numeroClient>"
	"			<codeProduit>6</codeProduit>"
	"			<codeOffre>J03PA</codeOffre>"
	"			<etatDossier>A</etatDossier>"
	"			<codeRecouvrement>00</codeRecouvrement>"
	"			<segment>CUR</segment>"
	"			<indBonus>true</indBonus>"
	"			<indSIRET>false</indSIRET>"
	"		</donneesClient>	"
	"	</requete>"
	"	<resultat>"
	"		<IN1>" ++ Is_adherent ++ "</IN1>"
	"		<IN2>true</IN2>"
	"		<IN3>true</IN3>"
	"		<solde>2500</solde>"
	"		<pointsLimites/>"
	"		<jourLimitePts/>"
	"		<codeEligibleBurn>OK</codeEligibleBurn>"
	"		<causeNonEligibiliteBurn/>"
	"		<isAdherentM5Plus>" ++ Is_adherent_m5plus ++ "</isAdherentM5Plus>"
	"		<isCibleM5Plus>" ++ Is_cible ++ "</isCibleM5Plus>"
	"		<isCibleM5bO>" ++ Is_cible_m5bO ++ "</isCibleM5bO>"
	"		<idFederation/>"
	"		<listeDetailSolde>"
	"			<detailSolde>"
	"				<nbPoints>500</nbPoints>"
	"				<jourLimitePts>31/12/2006</jourLimitePts>"
	"			</detailSolde>"
	"			<detailSolde>"
	"				<nbPoints>2000</nbPoints>"
	"				<jourLimitePts>31/12/2007</jourLimitePts>"
	"			</detailSolde>"
	"		</listeDetailSolde>"
	"		<codeEligibleAdhesion/>"
	"		<isAdherentBonus/>"
	"	</resultat>"
	"</consulterSoldeReponse>".

consult_catalogue_response_xml() ->
    "<getConsultationCadeauxReponse>"
	"  <date>18/04/2006</date>"
	"  <heure>15:58:41</heure>"
	"  <codeRet>0</codeRet>"
	"  <messageRet/>"
	"  <requete>"
	"    <dossier>0663564138</dossier>"
	"    <canal>SWI</canal>"
	"    <idConseiller>CONS1</idConseiller >"
	"    <idTypeUsage>CP</idTypeUsage>"
	"    <idTypeRecompense></idTypeRecompense>"
	"    <indRestitution>1</indRestitution>"
	"    <donneesClient>	"
	"      <idDossierOEE>456421123</idDossierOEE>"
	"      <numeroClient>44444</numeroClient>"
	"      <codeProduit>1</codeProduit>"
	"      <codeOffre>E30W3</codeOffre>"
	"      <etatDossier>A</etatDossier>"
	"      <codeRecouvrement>2</codeRecouvrement>"
	"      <segment>GOLD</segment>"
	"      <indBonus>true</indBonus>"
	"      <indSIRET>false</indSIRET>"
	"    </donneesClient>"
	"  </requete>"
	"  <resultat>"
	"    <IN1>true</IN1>"
	"    <IN2>true</IN2>"
	"    <IN3>true</IN3>"
	"    <solde>2500</solde>"
	"    <pointsLimites>50</pointsLimites>"
	"    <jourLimitePts>31/01/2007</jourLimitePts>"
	"    <codeEligibleBurn>OK</codeEligibleBurn>"
	"    <causeNonEligibiliteBurn/>"
	"    <isAdherentM5Plus>true</isAdherentM5Plus>"
	"    <isCibleM5Plus>true</isCibleM5Plus>"
	"    <idFederation/>"
	"    <listeDetailSolde>"
	"	<detailSolde>"
	"	  <nbPoints>500</nbPoints>"
	"	  <jourLimitePts>31/12/2006</jourLimitePts>"
	"	</detailSolde>"
	"	<detailSolde>"
	"	  <nbPoints>2000</nbPoints>"
	"	  <jourLimitePts>31/12/2007</jourLimitePts>"
	"	</detailSolde>"
	"    </listeDetailSolde>"
	"    <codeEligibleAdhesion>OK</codeEligibleAdhesion>"
	"    <isAdherentBonus/>"
	"    <catalogue>"
	"      <listeTypeUsage>"
	"	  <typeUsage>"
	"	    <idTypeUsage>CO</idTypeUsage>"
	"	    <libelleTypeUsage>Services de communication</libelleTypeUsage>"
	"	    <listeTypeRecompense>"
	"		<typeRecompense>"
	"		  <idTypeRecompense>4</idTypeRecompense>"
	"		  <libelleTypeRecompense>SMS/MMS photos</libelleTypeRecompense>"
	"		  <codeEligibleRecompense>OK</codeEligibleRecompense >"
	"		  <CauseNonEligibiliteRecompense/>"
	"		  <listeRecompense>"
	"		      <recompense>"
	"			<idRecompense>50</idRecompense>"
	"			<libelleLongRecompense>20 SMS / 7 MMS</libelleLongRecompense>"
	"			<libelleCourtRecompense>20SMS/MMS</libelleCourtRecompense>"
	"			<isActivable>true</isActivable>"
	"			<prix>100</prix>"
	"			<prixAvecRemise>83</prixAvecRemise>"
	"			<listeTypeRecompenseBase>"
	"			  <typeRecompenseBase>"
	"			    <typeRecompenseBase>"
	"			      <idTypeRecompense>22</idTypeRecompense>"
	"			      <libelleTypeRecompense>SMS HP</libelleTypeRecompense>"
	"			      <montant>20</montant>"
	"			      <typeUnite>3</typeUnite>"
	"			      <libelleUnite>SMS</libelleUnite>"
	"			    </typeRecompenseBase>"
	"			    <typeRecompenseBase>"
	"			      <idTypeRecompense>23</idTypeRecompense>"
	"			      <libelleTypeRecompense>MMS photos</libelleTypeRecompense>"
	"			      <montant>7</montant>"
	"			      <typeUnite>4</typeUnite>"
	"			      <libelleUnite>MMS</libelleUnite>"
	"			    </typeRecompenseBase>"
	"			  </typeRecompenseBase>"
	"			</listeTypeRecompenseBase>"
	"		      </recompense>"
	"		      <recompense>"
	"			<idRecompense>51</idRecompense>"
	"			<libelleLongRecompense>1 heure etranger / 15 MMS</libelleLongRecompense>"
	"			<libelleCourtRecompense>20SMS/MMS</libelleCourtRecompense>"
	"			<isActivable>false</isActivable>"
	"			<prix>50</prix>"
	"			<prixAvecRemise>40</prixAvecRemise>"
	"			<listeTypeRecompenseBase>"
	"			  <typeRecompenseBase>"
	"			    <typeRecompenseBase>"
	"			      <idTypeRecompense>22</idTypeRecompense>"
	"			      <libelleTypeRecompense>SMS HP</libelleTypeRecompense>"
	"			      <montant>20</montant>"
	"			      <typeUnite>3</typeUnite>"
	"			      <libelleUnite>SMS</libelleUnite>"
	"			    </typeRecompenseBase>"
	"			    <typeRecompenseBase>"
	"			      <idTypeRecompense>23</idTypeRecompense>"
	"			      <libelleTypeRecompense>MMS photos</libelleTypeRecompense>"
	"			      <montant>7</montant>"
	"			      <typeUnite>4</typeUnite>"
	"			      <libelleUnite>MMS</libelleUnite>"
	"			    </typeRecompenseBase>"
	"			  </typeRecompenseBase>"
	"			</listeTypeRecompenseBase>"
	"		      </recompense>"
	"		  </listeRecompense>"
	"		</typeRecompense>"
	"		<!-- 2nd type de recompense -->"
	"		<typeRecompense>"
	"		  <idTypeRecompense>5</idTypeRecompense>"
	"		  <libelleTypeRecompense>Les illimites</libelleTypeRecompense>"
	"		  <codeEligibleRecompense>OK</codeEligibleRecompense >"
	"		  <CauseNonEligibiliteRecompense/>"
	"		  <listeRecompense>"
	"		      <recompense>"
	"			<idRecompense>55</idRecompense>"
	"			<libelleLongRecompense>Tout illimite soir</libelleLongRecompense>"
	"			<libelleCourtRecompense>Tt ill. soir</libelleCourtRecompense>"
	"			<isActivable>true</isActivable>"
	"			<prix>2000</prix>"
	"			<prixAvecRemise>1800</prixAvecRemise>"
	"			<listeTypeRecompenseBase>"
	"			  <typeRecompenseBase>"
	"			    <typeRecompenseBase>"
	"			      <idTypeRecompense>22</idTypeRecompense>"
	"			      <libelleTypeRecompense>SMS HP</libelleTypeRecompense>"
	"			      <montant>20</montant>"
	"			      <typeUnite>3</typeUnite>"
	"			      <libelleUnite>SMS</libelleUnite>"
	"			    </typeRecompenseBase>"
	"			    <typeRecompenseBase>"
	"			      <idTypeRecompense>23</idTypeRecompense>"
	"			      <libelleTypeRecompense>MMS photos</libelleTypeRecompense>"
	"			      <montant>7</montant>"
	"			      <typeUnite>4</typeUnite>"
	"			      <libelleUnite>MMS</libelleUnite>"
	"			    </typeRecompenseBase>"
	"			  </typeRecompenseBase>"
	"			</listeTypeRecompenseBase>"
	"		      </recompense>"
	"		  </listeRecompense>"
	"		</typeRecompense> "
	"	    </listeTypeRecompense>"
	"	  </typeUsage>"
	"	  <typeUsage>"
	"	    <idTypeUsage>AB</idTypeUsage>"
	"	    <libelleTypeUsage>Test</libelleTypeUsage>"
	"	    <listeTypeRecompense>"
	"		<typeRecompense>"
	"		  <idTypeRecompense>10</idTypeRecompense>"
	"		  <libelleTypeRecompense>Acces AB Tele</libelleTypeRecompense>"
	"		  <codeEligibleRecompense>OK</codeEligibleRecompense >"
	"		  <CauseNonEligibiliteRecompense/>"
	"		  <listeRecompense>"
	"		      <recompense>"
	"			<idRecompense>80</idRecompense>"
	"			<libelleLongRecompense>AB Tele</libelleLongRecompense>"
	"			<libelleCourtRecompense>AB Tele</libelleCourtRecompense>"
	"			<isActivable>true</isActivable>"
	"			<prix>200</prix>"
	"			<prixAvecRemise>83</prixAvecRemise>"
	"		      </recompense>"
	"		  </listeRecompense>"
	"		</typeRecompense>"
	"	    </listeTypeRecompense>"
	"	  </typeUsage>"
	"      </listeTypeUsage>"
	"    </catalogue>"
	"  </resultat>"
	"</getConsultationCadeauxReponse>".

activate_present_response_xml() ->
    "<getActivationPrimeReponse>"
	"	<date>18/04/2006</date>"
	"	<heure>15:58:41</heure>"
	"	<codeRet>0</codeRet>"
	"	<messageRet/>"
	"	<requete>"
	"	        <dossier>"?msisdn"</dossier>"
	"	        <canal>USSD</canal>"
	"               <idConseiller>JDGTRA</idConseiller>"
	"	        <idRecompense>40</idRecompense>"
	"	        <prix>1000</prix>"
	"  	        <prixAvecRemise>900</prixAvecRemise>"
	"		<donneesClient>	"
	"			<idDossierOEE>1234567890 </idDossierOEE>"
	"			<numeroClient>0061295590</numeroClient>"
	"			<codeProduit>6</codeProduit>"
	"			<codeOffre>J03PA</codeOffre>"
	"			<etatDossier>A</etatDossier>"
	"			<codeRecouvrement>00</codeRecouvrement>"
	"			<segment>CUR</segment>"
	"			<indBonus>true</indBonus>"
	"			<indSIRET>false</indSIRET>"
	"		</donneesClient>	"
	"	</requete>"
	"	<resultat>"
	"               <solde>2500</solde>"
	"	        <pointsLimites/>"
	"	        <jourLimitePts/>"
	"	        <isAdherentM5Plus>true</isAdherentM5Plus>"
	"	        <isCibleM5Plus>true</isCibleM5Plus>"
	"	        <listeDetailSolde>"
	"		        <detailSolde>"
	"			        <nbPoints>500</nbPoints>"
	"			        <jourLimitePts>31/12/2006</jourLimitePts>"
	"		        </detailSolde>"
	"		        <detailSolde>"
	"			        <nbPoints>2000</nbPoints>"
	"			        <jourLimitePts>31/12/2007</jourLimitePts>"
	"		        </detailSolde>"
	"	        </listeDetailSolde>"
	"	</resultat>"
	"</getActivationPrimeReponse>".
