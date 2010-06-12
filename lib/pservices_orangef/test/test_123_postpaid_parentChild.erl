-module(test_123_postpaid_parentChild).

-export([run/0, online/0]).

-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("test_util_of.hrl").

-define(NOT_SPLITTED, ".*[^>]\$").
-define(BR, " ").

-define(PATH, "lib/pfront_orangef/test/webservices/postpaid_cmo/").
-define(CODE, test_util_of:access_code(test_123_postpaid_Homepage, ?postpaid_recharge) ++ "#").

run() ->
     dec_getCodeConfidentielResponse(),
     dec_checkCodeConfidentielResponse(),
     dec_setCodeConfidentielResponse(),    
     dec_checkRechargementParentChildResponse("ISRECH_0612345678_.xml"),
     dec_checkRechargementParentChildResponse("CHECKRECH_0612345678_.xml"),
     dec_checkRechargementParentChildResponse("CHECKRECH_0688888888_.xml"),
    ok.

get_xml(FileName) ->
    File = code:lib_dir(pfront_orangef)++"/test/webservices/parentChild/"++
	FileName,
    {ok, Bin} = file:read_file(File),
    binary_to_list(Bin).

dec_getCodeConfidentielResponse() ->
    Xml = get_xml("GETRCOD_0612345678.xml"),
    Dec = soaplight:decode_body(Xml, asmetier_webserv),
    io:format("Dec ~p~n", [Dec]),
    (#getRcodResponse{listeRcodItem=#listeRcodItem{nbTentatives=3}}
     )=Dec.

dec_checkCodeConfidentielResponse() ->
    Xml = get_xml("GETVCOD_0612345678_1234.xml"),
    Dec = soaplight:decode_body(Xml, asmetier_webserv),
    io:format("Dec ~p~n", [Dec]),
    (#getVcodResponse
     {
     %statusList=[#status{statusCode="00"}],
      nbTentatives=3})=Dec.

dec_setCodeConfidentielResponse() ->
    Xml = get_xml("GETMCOD_0612345680_1234.xml"),
    Dec = soaplight:decode_body(Xml, asmetier_webserv),
     io:format("Dec: ~p~n",[Dec]),
    %%io:format("Dec ~p~n", [Dec]),
    (#getMcodResponse
     {%statusList=[#status{statusCode="00"}],
      nbTentatives=3})=Dec.

dec_checkRechargementParentChildResponse(Filename) ->
     Xml = get_xml(Filename),
     Dec = soaplight:decode_body(Xml, asmetier_webserv),
    io:format("Dec: ~p~n",[Dec]),
    (#isRechargementParentChildPossibleResponse
      {dateProchainRechargementCmo=undefined,
       dateProchainRechargementMobicarte="2015-04-25T09:13:37.23",
       idDossier="8198060",       
       prestationsMobicarte=[],
       prestationsCmo=[#code_montant{code="1GM12",
				     montant="5"}|_]
      })=Dec.

%% dec_checkRechargementParentChildResponse(Filename) ->
%%      Xml = get_xml(Filename),
%%      Dec = soaplight:decode_body(Xml, asmetier_webserv),
%%     (#checkRechargementParentChildResponse
%%       {statusList=[#status{statusCode="00"}],
%%        idDossierOrchidee="8198055",
%%        idDossierSachem=[],
%%        mobicarte=[],
%%        rechargement=[#recharg
%%  		    {dateProchainRechargement=[],
%%  		     mobicarte=true,
%%  		     prestation=[#code_montant{code="1GM00",
%%  					       montant="5"}|_]}|_]
%%       })=Dec.

online() ->
    process_flag(trap_exit, false),
    testreport:start_link_logger("../doc/"?MODULE_STRING".html"),

    check_interf(httpclient_spider),
    check_interf(httpclient_webserv_of),

    init_cellcube_config(),

    case catch online2() of
	{'EXIT',E} ->
	    reload_cellcube_config(),
	    exit(E);
	X -> 
	    reload_cellcube_config(),
	    X
    end.    

check_interf(InterName) ->
    case rpc:call(possum@localhost,erlang,whereis,[InterName]) of
	Proc when pid(Proc) -> ok;
	_ -> exit({no_proc,InterName})
    end.

init_cellcube_config() ->
    Params = 
	[{pservices_orangef, acces_service_parentChild, ouvert}],
    lists:foreach(fun rpc_call_change_param/1, Params).    

rpc_call_change_param({App,P,NewV}) ->
    ok = rpc:call(possum@localhost,oma_config,change_param,[App,P,NewV]).

reload_cellcube_config() ->
    ok = rpc:call(possum@localhost, oma_config, reload_config, []).

online2() ->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_service:online(test()),
    test_util_of:test_kenobi(prisme_counters()),
    testreport:stop_logger(),
    ok.

test() ->
    connect() ++
	["Desactivation de l'interface one2one",
	 {erlang, [{rpc, call, [possum@localhost,
				pcontrol, disable_itfs,
				[[io_oto_mqseries1,possum@localhost]]]}]}]++
  	test_non_rep_asm() ++
    	test_init_codeconf_ecrase() ++
 	test_codeconf_bloque() ++
 	test_init_codeconf() ++
	test_rechargement() ++
	[].

test_non_rep_asm() ->
    init_test("+33612345677") ++
	asmserv_init("+33612345677", "NOACT")++
	[{ussd2, 
	  send_exp(?CODE,
		   "Le service \"recharge pour un proche\" est indisponible. "
		   "Orange vous remercie de votre appel") }]++
	asmserv_restore("+33612345677", "NOACT").

test_init_codeconf_ecrase() ->
    init_test("+33612345681") ++
	asmserv_init("+33612345681", "NOACT")++
	[{ussd2, 
	  send_exp(?CODE,
		   "Votre code confidentiel a ete supprime. Composez votre "
		   "nouveau code confidentiel a 4 chiffres, puis validez")
	 }]++
	asmserv_restore("+33612345681", "NOACT").

test_codeconf_bloque() ->
    init_test("+33612345679") ++
	asmserv_init("+33612345679", "NOACT")++
	[{ussd2, 
	  send_exp(?CODE,
		   "Votre code d'acces a ete invalide. Pour beneficier a nouveau de ce "
		   "service, nous vous invitons a contacter votre service client en "
		   "composant le 700 depuis votre mobile Orange")
	 }]++
	asmserv_restore("+33612345679", "NOACT").

test_init_codeconf() ->
    init_test("+33612345680") ++
	asmserv_init("+33612345680", "NOACT")++
	[{ussd2, 
	  send_exp(?CODE,
		   "Pour creer votre code confidentiel, veuillez saisir les 4 chiffres "
		   "de votre choix, puis validez") ++
	  send_exp("11111", 
		   "Nous n'avons pas reconnu votre code confidentiel. Pour "
		   "creer votre code confidentiel, veuillez saisir les 4 "
		   "chiffres de votre choix, puis validez") ++
	  send_exp("22222", 
		   "Nous n'avons pas reconnu votre code confidentiel. Pour "
		   "creer votre code confidentiel, veuillez saisir les 4 "
		   "chiffres de votre choix, puis validez") ++
	  send_exp("33333", 
		   "Nous n'avons toujours pas reconnu votre code "
		   "confidentiel")
	 }]++
	asmserv_restore("+33612345680", "NOACT").

test_rechargement() ->
    init_test("+33612345678") ++
	asmserv_init("+33612345678", "NOACT")++
	[{ussd2, 
	  send_exp(?CODE,
		   "Ce service est securise. Pour y acceder composez votre "
		   "code confidentiel a 4 chiffres, puis validez") ++
	  send_exp("1234", "Pour effectuer un rechargement, veuillez saisir "
		   "les 10 chiffres du numero mobile Orange a recharger, puis "
		   "validez") ++
	  send_exp("06111", "Attention le numero saisi n'est pas valide ou "
		   "comporte trop de chiffres. Composez a nouveau le numero "
		   "de mobile Orange a recharger, puis validez") ++
	  send_exp("0611223344", 
		   "Vous avez compose le 0611223344"?BR
		   "1:valider"?BR
		   "2:modifier") ++
	  send_exp("2",".*")++
	  send_exp("0711223344", 
		   "Vous avez compose le 0711223344"?BR
		   "1:valider"?BR
		   "2:modifier") ++
	  [{send, "1"},
	   {expect, "Veuillez selectionner le montant de votre recharge dans "
	    "la liste suivante, puis validez"
	    ".*1:5 E"
	    ".*2:10 E"
	    ".*3:15 E"
	    ".*4:25 E \\+ bonus 5 E"
	    ".*5:35 E \\+ bonus 10 E"
	    ".*6:50 E \\+ bonus 15 E"
%%	    ".*7:-->"
	    },
	   {send, 7},
	   {expect, 
	    "7:75 E \\+ bonus 25 E"},
	   {send, "7"},
	   {expect, "Vous avez selectionne la recharge .*"
%%	    "75 E \\+ bonus 25 E valables 4 mois"?BR
	    "1:Confirmer"?BR
	    "2:Modifier"}] ++
	  send_exp("1", "Votre rechargement a bien ete effectue. Nous vous "
		   "remercions.") ++
	  []
	 }]++
	asmserv_restore("+33612345678", "NOACT").

send_exp(S,E) -> [{send, S},
		  {expect, ?NOT_SPLITTED},
		  {expect, E}].

connect() ->
    [{connect_smpp, {"localhost", 7431}}].


init_test(MSISDN) ->
    MSISDN_NAT = int_to_nat(MSISDN),
    IMSI = "20801"++MSISDN_NAT,

    %% INITIALISATION DANS SPIDER:
    test_util_spider:build_and_insert_xml(MSISDN_NAT, IMSI, "postpaid","3G","0") ++
	
	%% INITIALISATION DANS PTESTER:
	[{msaddr, [{subscriber_number, private,IMSI},
		   {international,isdn, MSISDN} ]}] ++
	
	%% INITIALISATION DANS USERS:
	reinit_in_users(IMSI, MSISDN, "", "postpaid", "fr").

int_to_nat("+33"++T) -> "0"++T.

reinit_in_users(IMSI, MSISDN, IMEI, Subscription, Language) ->
    MYSQL_CMD = 
	"DELETE FROM users WHERE imsi='"++IMSI++"' or msisdn='"
	++MSISDN++"' ; "++
	
	"INSERT INTO users " ++
	"(uid, msisdn, imsi, imei, subscription, language, since) " ++
	"VALUES (NULL," ++
	"'"++MSISDN++"'"++ "," ++
	"'"++IMSI++"'"++ "," ++
	"'"++IMEI++"'"++ "," ++
	"'"++Subscription++"'"++ "," ++
	"'"++Language++"'"++ "," ++
	"'"++integer_to_list(pbutil:unixtime())++"'" ++ ")",
    [{shell,
      [ {send, "mysql -B -u possum -ppossum -e \""++MYSQL_CMD++"\""++" mobi"}
       ]}
    ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
asmserv_init(MSISDN, ACTIV_OPTs)->
    %% Redirect to the appropriate webservices_server/postpaid_cmo file 
     [
      {erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost, file,
			copy, [?PATH++"GETIDENT_"++MSISDN++"_"++ACTIV_OPTs++".xml", 
				 ?PATH++"GETIDENT_"++MSISDN++".xml"]]}
	   ]}
     ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
asmserv_restore(MSISDN, ACTIV_OPTs)->
    %% Restore the webservices_server/postpaid_cmo file 
     [
      {erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost, file,
			delete, [?PATH++"GETIDENT_"++MSISDN++".xml"]]}
	   ]}
     ].
prisme_counters() ->
    [{"3G","DACT075", 1}
    ].
