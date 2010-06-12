-module(test_mipc_vpbx_webserv).

-export([run/0, online/0]).

-include("../include/mipc_vpbx_webserv.hrl").

online()->
    ok.

run()->
    dec_getCodeConfidentielResponse(),
    ok.

get_xml(FileName) ->
    File = code:lib_dir(pfront_orangef)++"/test/webservices/mipc_vpbx/"++
	FileName,
    {ok, Bin} = file:read_file(File),
    binary_to_list(Bin).

dec_getCodeConfidentielResponse() ->
    test(
      [{"activerSituationResponse.xml",
	#activerSituationResponse{resultat=#resultat
				 {codeRetour = "0",
				  commentaire = "Succès"}}},
       {"consultation_information_VPBX_4situations.xml",
	#consulterInformationsResponse{resultat=#resultat
				       {codeRetour = "0",
					commentaire = "Succès"},
				       reseau=#reseau
				       {codeReseau="AlyoRes7",
					nomReseau="AlyoRes7"},
				       membre=#membre
				       {nom="alyoNomM07",
					prenom="alyoPrenomM07",
					manager="false"},
				       nbSituationsParametrees="4",
				       typeOffre="VPBx"}},
       {"consultation_information_MIPC_3situations.xml",
	#consulterInformationsResponse{resultat=#resultat
				       {codeRetour = "0",
					commentaire = "Succès"},
				       reseau=#reseau
				       {codeReseau="AlyoRes7",
					nomReseau="AlyoRes7"},
				       membre=#membre
				       {nom="alyoNomM07",
					prenom="alyoPrenomM07",
					manager="false"},
				       nbSituationsParametrees="3",
				       typeOffre="MIPC"}},
       {"consulterParametrageReelResponse_RC_premierETliste.xml",
	#consulterParametrageReelResponse{resultat=#resultat
					  {codeRetour = "0",
					   commentaire = "Succès"},
					  parametrageNumeroUnique=
					  #parametrageNumeroUnique{},
				    parametrageRenvois=#parametrageRenvois{
				      typeRenvoi="RC",
				      versNumerosLibres=#versNumerosLibres{
					premierNumero="33660007002",
					listeNumeros=["33260002001",
						      "33260002002"],
					boiteVocale="8"},
				      versAssistante=#versAssistante{},
				      saufAppelsEmisDepuis=[]}}
       },
       {"consulterSituationResponse_I_premierETsauf.xml",
	#consulterSituationResponse{resultat=#resultat
				    {codeRetour="0",
				     commentaire="Succès"},
				    parametrageNumeroUnique=
				    #parametrageNumeroUnique{},
				    parametrageRenvois=#parametrageRenvois{
				      typeRenvoi="I",
				      versNumerosLibres=#versNumerosLibres{
					premierNumero="33260002001",
					listeNumeros=[],
					boiteVocale=[]},
				      versAssistante=#versAssistante{},
				      saufAppelsEmisDepuis=["33260002002",
							    "33260002003",
							    "33260002004"]}}
       },
       {"listeSituationsParametreesResponse_4situations.xml",
	#listeSituationsParametreesResponse{
	  resultat=#resultat
	  {codeRetour="0",
	   commentaire="Succès"},
	  listeSituations=[#situation{idSituation="49",
				      libelleSituation="à mon bureau"},
			   #situation{idSituation="50",
				      libelleSituation="en réunion"},
			   #situation{idSituation="51",
				      libelleSituation="en déplacement"},
			   #situation{idSituation="52",
				      libelleSituation="en congés"}]
	 }},
       {"consulter_situation_no_assistante.xml",
	#consulterSituationResponse
	{resultat = #resultat
	 {codeRetour = "0",
	  commentaire = "Succès"},
	 parametrageNumeroUnique= #parametrageNumeroUnique{},
	 parametrageRenvois = #parametrageRenvois{
	   typeRenvoi = "C",
	   versNumerosLibres = #versNumerosLibres{
	     premierNumero = "0155228306",
	     listeNumeros = [],
	     boiteVocale = []},
	   versAssistante = #versAssistante{},
	   saufAppelsEmisDepuis = []
	  }}},
       {"consulter_situation_no_assistanteVPBX.xml", 
	%% field parametrageNumeroUnique is not in the XML
	%% in this case value is undefined and not default !
	#consulterSituationResponse
	{resultat = #resultat
	 {codeRetour = "0",
	  commentaire = "Succès"},
	 parametrageNumeroUnique= undefined,
	 parametrageRenvois = #parametrageRenvois{
	   typeRenvoi = "C",
	   versNumerosLibres = #versNumerosLibres{
	     premierNumero = "0155228306",
	     listeNumeros = [],
	     boiteVocale = []},
	   versAssistante = #versAssistante{},
	   saufAppelsEmisDepuis = []
	  }}},
       {"consulter_situation_no_assistante2.xml",
	#consulterSituationResponse
	{resultat = #resultat
	 {codeRetour = "0",
	  commentaire = "Succès"},
	 parametrageNumeroUnique= #parametrageNumeroUnique{},
	 parametrageRenvois = #parametrageRenvois{
	   typeRenvoi = "I",
	   versNumerosLibres = #versNumerosLibres{
	    premierNumero = "33260002001",
	     listeNumeros = [],
	     boiteVocale = []},
	   versAssistante = #versAssistante{},
	   saufAppelsEmisDepuis = ["33260002002",
				   "33260002003",
				   "33260002004"]
	  }}},
      {"situationActiveResponse.xml",
       #situationActiveResponse
       {resultat = #resultat
	 {codeRetour = "0",
	  commentaire = "Succès"},
	situationActive = #situation
	{idSituation = "29",
	 libelleSituation = "à mon bureau"}}}]).

test(Cases) ->
    test(Cases,[]).

test([],[]) ->
    io:format("Success for "?MODULE_STRING"~n");
test([],Errors) ->
    io:format("Failure for "?MODULE_STRING
	      "~nNumber of failures:~p~n",
	      [length(Errors)]),
    io:format("Failed cases:~n~p~n",[lists:reverse(Errors)]),
    exit(failed);
test([H|T],Errors) ->
    case test_unit(H) of
	ok ->
	    test(T,Errors);
	{error,Error} ->
	    test(T,[Error|Errors])
    end.

test_unit({File,Expect}) ->
    Xml = get_xml(File),
    Dec = soaplight:decode_body(Xml, mipc_vpbx_webserv),
    case Dec of
	Expect ->
	    ok;
	_ ->
	    io:format("~nFor~p~n"
		      "expected:~n~p~n"
		      "Got:~n~p~n", [File,Expect,Dec]),
	    {error,File}
    end.

