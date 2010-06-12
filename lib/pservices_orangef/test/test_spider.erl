-module(test_spider). 

-include("../../pdist_orangef/include/spider.hrl").
-include("../include/ftmtlv.hrl").
-include("../../oma/include/slog.hrl").

-compile(export_all).
-export([run/0,online/0]).

-export([decode/0,decode/1]).

-export([perf/5]).

-export([dme/0]).
-export([check_prisme_counters_local/0, reset_prisme_counters_local/0,
	set_navigation_keywords/0, reset_navigation_keywords/0,
	set_navigation_keywords/1]).

-define(BR,".").
-define(MSISDN,"0612345678").
-define(IMSI,msisdn2imsi(?MSISDN)).
-define(USSD_CODE, "#123").
-define(USSD_CODE_DME_Niv1, "#123*2*1").
-define(NOT_SPLITTED, ".*[^>]\$").
-define(UNP, ".*:").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% check that the DCL_NUM is properly identified in all cases:
    %% defined
    D1=decode("79"), 
    79=svc_spider:get_declinaison(D1),
    io:format("D ~p~n",[D1]),
    %% empty
    D2=decode(""), 
    undefined=svc_spider:get_declinaison(D2),
    %% field absent (backward compatibility with previous version).
    D3=decode(undefined), 
    undefined=svc_spider:get_declinaison(D3),
    perf(10000,"",?MODULE, decode, []),
    ok.

decode() ->
    decode("79").

decode(DCL) ->    
    HTTPBODY = "
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">
	<soapenv:Body>
	<getBalanceResponse xmlns=\"http://localhost:8080/SPIDER/services\">
	<uuid>123456</uuid>
	<lang>fr_FR</lang>
	<channel>01</channel>
	<statusList>
	<status>
	<statusCode>a200</statusCode>
	<statusType>0</statusType>
	<statusName>BalanceGetSuccess</statusName>
	<statusDescription></statusDescription>
	</status>
	</statusList>
	<file>
	<billingAccountUid>0062021727</billingAccountUid>
	<custName>MLE PIERROT Julie</custName>
	<custMsisdn>0607000001</custMsisdn>
	<custImsi>20801500994177</custImsi>
	<nextInvoice>2005-12-30T23:00:00.000Z</nextInvoice>
	<invoiceDate>2004-05-05T22:00:00.000Z</invoiceDate>
	<billingFrequency>1</billingFrequency>
	<itemizedBill>77777</itemizedBill>
	<offerPOrSUid>PRO</offerPOrSUid>
	<offerType>postpaid</offerType>
	<vatRate>19.60</vatRate>"++insert(DCL)++"
	<amounts>
	<amount>
	<name>lastBill</name>
	<allTaxesAmount>2.0000</allTaxesAmount>
	<currency>EUR</currency>
	</amount>
	</amounts>
	</file>
	<bundles>
	<bundle>
	<priorityType>A</priorityType>
	<restitutionType>FORF1</restitutionType>
	<bundleType>ES180</bundleType>
	<bundleDescription>forfait pro 43 EUR</bundleDescription>
	<historyLabel>Forfait pro 43 EUR</historyLabel>
	<reactualDate>2004-12-31T11:12:12.000Z</reactualDate>
        <thresholdFlag>0</thresholdFlag>
	<bundleAdditionalInfo>003</bundleAdditionalInfo>
	<historyAmount>O</historyAmount>
	<credits>
	<credit>
	<name>standard</name>
	<unit>TEMPS</unit>
	<value>2000h00min00s</value>
	</credit>
	<credit>
	<name>start</name>
	<unit>TEMPS</unit>
	<value>2000h00min00s</value>
	</credit>
	<credit>
	<name>start</name>
	<unit>TEMPS</unit>
	<value>2000h00min00s</value>
	</credit>
	<credit>
	<name>balance</name>
	<unit>TEMPS</unit>
	<value>12h00min23s</value>
	</credit>
	<credit>
	<name>balance</name>
	<unit>TEMPS</unit>
	<value>1998h33min23s</value>
	</credit>
	<credit>
	<name>rollOver</name>
	<unit>VALEU</unit>
	<value>3.919</value>
	</credit>
	<credit>
	<name>consumed</name>
	<unit>TEMPS</unit>
	<value>1h26min38s</value>
	</credit>
	</credits>
        <bundleStatus>00</bundleStatus>
	</bundle>
	<bundle>
	<priorityType>C</priorityType>
	<restitutionType>SOLDE1</restitutionType>
	<bundleType>SMSE3</bundleType>
	<bundleDescription>forfait SMS/MMS 7,5 EUR</bundleDescription>
	<historyLabel>Forfait SMS/MMS 7,5 EUR</historyLabel>
	<firstUseDate>2002-05-03T22:00:00.000Z</firstUseDate>
	<reactualDate>2004-05-10T03:07:07.000Z</reactualDate>
	<historyAmount>N</historyAmount>
	<credits>
	<credit>
	<name>standard</name>
	<unit>VOLUM</unit>
	<value>5120</value>
	</credit>
	<credit>
	<name>standard</name>
	<unit>MINUT</unit>
	<value>90min</value>
	</credit>
	<credit>
	<name>start</name>
	<unit>ACTE</unit>
	<value>30</value>
	</credit>
	<credit>
	<name>balance</name>
	<unit>ACTE</unit>
	<value>0</value>
	</credit>
	<credit>
	<name>balance</name>
	<unit>SMS</unit>
	<value>0</value>
	</credit>
	<credit>
	<name>consumed</name>
	<unit>ACTE</unit>
	<value>30</value>
	</credit>
	</credits>
        <bundleStatus>01</bundleStatus>
	</bundle>
	</bundles>
	</getBalanceResponse>
	</soapenv:Body>
	</soapenv:Envelope>",
    soaplight:decode_body(HTTPBODY, spider).

insert(undefined) ->
    [];
insert(DCL) ->
    "<frSpecificPrepaidOfferValue>"++DCL++"</frSpecificPrepaidOfferValue>".


perf(N, String, M, F, A) ->
    T0 = unixmtime(),
    repeat(N, M, F, A),
    DT = unixmtime() - T0,
    io:format("~s: ~p in ~pms (~p/s)~n", [String, N, DT, N*1000 div DT]).

unixmtime() ->
    {MS,S,US} = now(), (MS*1000000+S)*1000 + US div 1000.

repeat(0, M, F, A) ->
    ok;
repeat(N, M, F, A) ->
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    apply(M, F, A),
    repeat(N-10, M, F, A).


%%sleep(X) -> receive after X -> ok end.    

%% Définition des paramètres Cellcube nécessaires au test

online() ->
    testreport:start_link_logger("../doc/"?MODULE_STRING".html"),
    check_interf(httpclient_spider),
    init_config(),
    reset_prisme_counters(),
    test_service:online(spec()),
    testreport:stop_logger(),
    check_prisme_counters(),
    ok.

check_interf(InterName) ->
    case rpc:call(possum@localhost,erlang,whereis,[InterName]) of
	Proc when pid(Proc) -> io:format("interf ~p ~p~n", [InterName, Proc]);
	_ -> exit({no_proc,InterName})
    end.

init_config() ->
    rpc:call(possum@localhost, oma_config, reload_config, []),
    Params = 
	[{pservices,prov_type_by_sc, [{?USSD_CODE,"#selfcare_user"}]},
	 {pservices,auth_by_sc_acl, [{?USSD_CODE,"/orangef/home.xml##123",
				      [],"/orangef/auth.xml#auth_preprod",
				      whitelist, []},
				     {"#128","/test/index.xml",
				      "test en ligne","/system/home.xml#auth_preprod",
				      blacklist,[]}
				    ]},
	 {oma, sasl_dump_class, all}],
    lists:foreach(fun rpc_call_change_param/1, Params).

rpc_call_change_param({App,P,NewV}) ->
    ok = rpc:call(possum@localhost,oma_config,change_param,[App,P,NewV]).

reload_config() ->
    ok = rpc:call(possum@localhost, oma_config, reload_config, []).

prisme_counters() ->
     [{{count,prisme_counter,{"**","SCONOK"}}, 19},
      {{count,prisme_counter,{"**","SCAVOK"}}, 2},
      {{count,prisme_counter,{"**","SCACOK"}}, 2}].

reset_prisme_counters() ->
    Res = rpc:call(possum@localhost, ?MODULE, reset_prisme_counters_local, []),
    io:format("Res ~p~n", [Res]).
    

reset_prisme_counters_local() ->
    lists:foreach(fun({Key, _}) -> mnesia:dirty_delete(slog_row, Key) end,
		  prisme_counters()).

check_prisme_counters() ->
    Res = rpc:call(possum@localhost, ?MODULE, check_prisme_counters_local, []),
    io:format("Res ~p~n", [Res]).
			  
check_prisme_counters_local() ->
    lists:map(fun check_prisme_counter/1, prisme_counters()).

check_prisme_counter({Key, ExpectCounted}) ->
    [#slog_row{ranges=Ranges}] = mnesia:dirty_read(slog_row, Key),
    {#slog_data{count=Count}, _} = lists:last(Ranges),
    io:format("~p ~p ~p~n", [Key, Count, ExpectCounted ]),
    Count=ExpectCounted,
    ok.
	     
spec() ->
    connect() ++
	test_util_of:init_test(?IMSI) ++
    	postpaid() ++
%    	dme() ++
 	prepaid() ++
 	o2o() ++
	["TESTS OK"].

postpaid() ->
    ["postpaid"] ++
	test_util_of:change_subscription(?IMSI,"postpaid") ++
 	postpaid_niv1() ++
  	postpaid_niv2() ++
  	postpaid_niv3() ++
	[].


postpaid_niv1_avec_o2o() ->
    ["postpaid niv1 avec oto"] ++
	test_util_of:set_parameter_for_test(sce_used,true)++
	test_util_of:change_navigation_to_niv1(?IMSI) ++
	init_data_test(
	  ?MSISDN, ?IMSI, "postpaid","OLA",
	  [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	   {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
	  [{bundle,
	    [{priorityType,"A"},
	     {restitutionType,"FORF"},
	     {bundleType,"0005"},
	     {bundleDescription,"label forf"},
	     {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	     {lastUseDate,"2005-06-05T07:08:09.MMMZ"},
	     {bundleAdditionalInfo, "I1|I2|I3"},
	     {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"40"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++
	
	["FORF ac"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06.*label forf : 40MMS.*Jsq 24/01 inclus.*I1 I2.*Hors forf: 2.50 EUR.*le meilleur tarif pour les sms.*1:En savoir +.*2:Suivi conso detaille.*3:Menu"},
	   {send,"2"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label forf \\+report 18SMS \\+bonus 2h18m48s : 40MMS"?BR
	    "Validite: 24/01 inclus"?BR
	    "I1 I2"?BR
	    "Hors forfait: 2.50 EUR"?BR?BR
	    "1:notre conseil.*2:Menu"}, %anomalie 1727
	   {send,"1"},
	   {expect,""},
	   {send,"9"},
	  {expect,"Menu #123#"}]}] ++
	test_util_of:set_parameter_for_test(sce_used,false).

postpaid_niv1() ->
    ["postpaid niv1"] ++
	test_util_of:change_navigation_to_niv1(?IMSI) ++
      	postpaid_forf_niv1() ++
  	postpaid_forf_epuise_niv1() ++
   	postpaid_ajust_niv1() ++
   	postpaid_abon_niv1() ++
 	postpaid_abon_niv1_avec_godet_solde() ++
   	postpaid_lib_niv1() ++
 	postpaid_restit_svcdetaille_avec_sousmenu() ++
 	postpaid_restit_svcdetaille_sans_sousmenu() ++
 	postpaid_restit_boost_exemple1() ++
 	postpaid_restit_boost_exemple2() ++
	[].

postpaid_forf_niv1() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid","FNAC",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0005"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "I1|I2|I3"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"40"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++

	["FORF ac"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label forf \\+report 18SMS \\+bonus 2h18m48s:40MMS"?BR
	    "Jsq 24/01 inclus"?BR
	    "I1 I2"?BR
	    "Hors forfait:2.50 EUR"?BR},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

acces_menu() ->
    acces_menu_sce().
%    [{send, "00"}, {expect, "1:.*2:.*"}].  
acces_menu_sce() ->
    [{send, "9"}, {expect, "1:.*2:.*"}].    
acces_menu_cmo() ->
    [{send, "1"}, {expect, "1:.*2:.*"}].    

postpaid_forf_epuise_niv1() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid", "3G",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0005"},
	 {bundleDescription,"label forf"},
	 {exhaustedLabel,"label_ep"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "I1|I2|I3"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++

	["FORF EP"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label_ep \\+report 18SMS \\+bonus 2h18m48s:epuise"?BR
	    "Renouvele:25/01"?BR
	    "I1 I3"?BR
	    "Hors forfait:2.50 EUR.*"
	    "1:Menu"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

postpaid_abon_niv1() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid", "OLA",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"ABON"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Abon"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["ABON"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Montant consomme:2.50 EUR"?BR
	    "Prochaine fact:24/01.*"
	    "1:Menu"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

postpaid_abon_niv1_avec_godet_solde() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid", "OLA",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"ABON"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Abon"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"SOLDE"},
		{bundleType,"1"},
		{bundleDescription,"Solde"},
		{exhaustedLabel,"Solde"},
		{reactualDate, "2007-02-28T09:48:56.844Z"},
		{desactivationDate, "2006-08-11T07:08:09.MMMZ"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"VALEU"},{value,"2"} ]},
		  {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]}]}]}]) ++
	["ABON + SOLDE"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Montant consomme:2.50 EUR"?BR
	    "Prochaine fact:24/01"?BR
	    "Solde \\+report 18SMS : 2.00EUR a utiliser jusqu'au 11/08 inclus.*"
	    "1:Menu"}] ++ acces_menu()}].

postpaid_ajust_niv1() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid", "ORA",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"AJUST"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Ajust"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["AJUST"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label Ajust:40MMS"?BR
	    "Prochaine fact:24/01"?BR
	    "Hors forfait:2.50 EUR.*"
	    "1:Menu"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

postpaid_lib_niv1() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid", "PRO",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.550"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.550"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"LIB"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["LIB"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label Lib"?BR
	    "Prochaine fact:24/01"?BR
	    "Hors forfait:3.10 EUR.*"
	    "1:Menu"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

postpaid_restit_svcdetaille_sans_sousmenu() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid", "OTHER",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [
       {bundle,
	[{priorityType,"A"},
	 {restitutionType,"LIB"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]},
       {bundle,
 	[
 	 {priorityType,"C"},
  	 {restitutionType,"LIB"},
  	 {bundleType,"0005"},
  	 {bundleDescription,"C_LIB"},
  	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
  	 {desactivationDate, "2005-12-12T07:08:09.MMMZ"},
  	 {credits,
  	  [{credit,[{name,"balance"},{unit,"SMS"},{value,"0"}]},
  	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"1"}]}
  	  ]}]}
      ]) ++
	["Postpaid suivi conso detaillé sans sous menu"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "2:Suivi conso\\+"},
	   {send, "2*1*1"},
	   {expect, "C_LIB.*8:Precedent.*9:Accueil"}
	  ] ++ acces_menu()}].

postpaid_restit_svcdetaille_avec_sousmenu() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [
       {bundle,
	[{priorityType,"A"},
	 {restitutionType,"AJUST"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]},
	   {credit,[{name,"bonus"},{unit,"SMS"},{value,"17"}]}
	  ]}]},
       {bundle,
 	[
 	 {priorityType,"C"},
  	 {restitutionType,"LIB"},
  	 {bundleType,"0005"},
  	 {bundleDescription,"C_LIB"},
  	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
  	 {desactivationDate, "2005-12-12T07:08:09.MMMZ"},
  	 {credits,
  	  [{credit,[{name,"balance"},{unit,"SMS"},{value,"0"}]},
  	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"1"}]}
  	  ]}]}
      ]) ++
	["Postpaid suivi conso detaillé avec sous menu"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "2:Suivi conso\\+"},
	   {send, "2"},
	   {expect, "1:Suivi conso"},
 	   
	   %{send, "1"},
	   %{expect, ""},
 	   %{send, "1"},
	   %{expect, ".*"},
           %{send, "1"},
	   %{expect, "a cd"},
	   {send, "1*1*1"},
	   {expect, "C_LIB.*8:Precedent.*9:Accueil"}
	  ] ++ acces_menu()}].


postpaid_restit_boost_exemple1() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"LIB"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]},
       {bundle,
	[{priorityType,"E"},
	 {restitutionType,"AVTG"},
	 {bundleType,"0005"},
	 {bundleDescription,"Conso option Boost SMS"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {lastUseDate, "2005-12-12T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"counter"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"advantage"},{unit,"SMS"},{value,"1"},
		    {additionalInfo, "1"}]}
	  ]}]}       
      ]) ++
	["Postpaid offre boost exemple 1"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,".*2:Suivi conso\\+.*"}, {expect, ?NOT_SPLITTED},
	   {send, "2*1*1"},
	   {expect, "Conso option Boost SMS :."
	    "18SMS offrant 1SMS  nationales a utiliser jusqu'au 12/12.*"}]}].

postpaid_restit_boost_exemple2() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"LIB"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]},
       {bundle,
	[{priorityType,"E"},
	 {restitutionType,"AVTG"},
	 {bundleType,"0005"},
	 {bundleDescription,"Conso option Boost Visio"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {firstUseDate,"2005-12-13T07:08:09.MMMZ"},
	 {lastUseDate, "2006-12-12T07:08:09.MMMZ"},
	 {previousPeriodLastUseDate,"2005-12-12T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"previousCounter"},{unit,"TEMPS"},{value,"1h12min13s"}]},
	   {credit,[{name,"counter"},{unit,"TEMPS"},{value,"4h13min10s"}]},
	   {credit,[{name,"previousAdvantage"},{unit,"SMS"},{value,"3"}]},
	   {credit,[{name,"previousAdvantage"},{unit,"MMS"},{value,"1"}]},
	   {credit,[{name,"advantage"},{unit,"SMS"},{value,"28"}]},
	   {credit,[{name,"advantage"},{unit,"MMS"},{value,"9"}]}
	  ]}]}
      ]) ++
	["Postpaid offre boost exemple 2"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,".*2:Suivi conso\\+.*"}, {expect, ?NOT_SPLITTED},
	   {send, "2*1*1"},
	   {expect, "Conso option Boost Visio :"?BR
	    "1h12m13s offrant 3SMS ou 1MMS a utiliser jusqu'au 12/12"?BR?BR
	    "4h13m10s offrant 28SMS ou 9MMS a utiliser du 13/12 au 12/12"},
	   {expect, ?NOT_SPLITTED}]}].


postpaid_niv2() ->
    ["postpaid niv2"] ++
	test_util_of:change_navigation_to_niv2(?IMSI) ++
    	postpaid_forf_niv2() ++
	postpaid_forf_epuise_niv2() ++
	postpaid_ajust_niv2() ++
	postpaid_abon_niv2_avec_godet_solde() ++
	postpaid_abon_niv2() ++
	postpaid_lib_niv2().

postpaid_forf_niv2() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0005"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"40"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++

	["FORF ac"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label forf \\+report 18SMS \\+bonus 2h18m48s:40MMS"?BR
	    "Jsq 24/01 inclus"?BR
	    "Hors forfait:2.50 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_forf_epuise_niv2() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0005"},
	 {bundleDescription,"label forf"},
	 {exhaustedLabel,"label_ep"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++

	["FORF ep"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label_ep \\+report 18SMS \\+bonus 2h18m48s:epuise"?BR
	    "Renouvele:25/01"?BR
	    "Hors forfait:2.50 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_abon_niv2() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"ABON"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Abon"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["ABON"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Montant consomme:2.50 EUR"?BR
	    "Prochaine fact:24/01"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_abon_niv2_avec_godet_solde() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"ABON"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Abon"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"SOLDE"},
		{bundleType,"1"},
		{bundleDescription,"Solde"},
		{exhaustedLabel,"Solde"},
		{reactualDate, "2007-02-28T09:48:56.844Z"},
		{desactivationDate, "2006-08-11T07:08:09.MMMZ"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"VALEU"},{value,"2"} ]},
		  {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]}]}]}]) ++
	["ABON + SOLDE"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Montant consomme:2.50 EUR"?BR
	    "Prochaine fact:24/01"?BR
	    "Solde \\+report 18SMS : 2.00EUR a utiliser jusqu'au 11/08 inclus"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_ajust_niv2() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"AJUST"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Ajust"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++
	["AJUST"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label Ajust:40MMS"?BR
	    "Prochaine fact:24/01"?BR
	    "Hors forfait:2.50 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_lib_niv2() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"2.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"2.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"LIB"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["LIB"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "label Lib"?BR
	    "Prochaine fact:24/01"?BR
	    "Hors forfait:4.50 EUR"?BR
	   },
	   {expect, ?NOT_SPLITTED}]}].



postpaid_niv3() ->
    ["postpaid niv3"] ++
	test_util_of:change_navigation_to_niv3(?IMSI) ++
    	postpaid_forf_niv3() ++
	postpaid_forf_epuise_niv3() ++
	postpaid_ajust_niv3() ++
	postpaid_abon_niv3() ++
	postpaid_lib_niv3().


postpaid_forf_niv3() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0005"},
	 {bundleDescription,"label"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"40"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++

	["FORF ac"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06"?BR
	    "label : 40MMS"?BR
	    "Jsq 24/01 inclus"?BR
	    "Hors forf: 2.50 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_forf_epuise_niv3() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0005"},
	 {bundleDescription,"lab"},
	 {exhaustedLabel,"lep"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]) ++

	["FORF ep"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06"?BR
	    "lep : epuise"?BR
	    "Renouvele: 25/01"?BR
	    "Hors forf: 2.50 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_abon_niv3() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"ABON"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Abon"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["ABON"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06"?BR
	    "Montant consomme: 2.50 EUR"?BR
	    "Prochaine fact: 24/01"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_ajust_niv3() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"AJUST"},
	 {bundleType,"0005"},
	 {bundleDescription,"label"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["AJUST"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06"?BR
	    "label : 40MMS"?BR
	    "Fact: 24/01"?BR
	    "Hors forfait: 2.50 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

postpaid_lib_niv3() ->
    init_data_test(
      ?MSISDN, ?IMSI, "postpaid",
      [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
       {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"LIB"},
	 {bundleType,"0005"},
	 {bundleDescription,"label Lib"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"40"}]}]}]}]) ++

	["LIB"] ++
	[{ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06"?BR
	    "label Lib"?BR
	    "Fact: 24/01"?BR
	   "Hors forfait: 2.50 EUR"?BR},
	   {expect, ?NOT_SPLITTED}]}].


dme() ->
    test_util_of:init_test(?IMSI,"mobi") ++

	dme_niv1() ++
   	dme_niv2() ++
   	dme_niv3() ++
	[].

dme_niv1() ->
    test_util_of:change_navigation_to_niv1(?IMSI) ++
	dme_ano_4349()++
       	dme_niv1_id3_ac() ++
       	dme_niv1_id3_ep() ++
 	dme_niv1_id2_ac() ++
 	dme_niv1_id2_ep() ++
 	dme_niv1_id1_ac() ++
 	dme_niv1_id1_ep() ++
 	dme_niv1_id13_ac() ++
 	dme_niv1_id13_ep() ++
 	dme_niv1_id7_ac() ++
 	dme_niv1_id7_ep() ++
 	dme_niv1_id14_ac() ++
 	dme_niv1_id14_ep() ++
 	dme_niv1_id8_ac() ++
 	dme_niv1_id8_ep() ++
 	dme_niv1_id11_ac() ++
 	dme_niv1_id11_ep() ++
	dme_niv1_id9_ac() ++
	dme_niv1_id9_ep() ++
	dme_niv1_id10_ac() ++
	dme_niv1_id10_ep() ++
	dme_niv1_id12_ac() ++
	dme_niv1_id12_ep() ++
      	dme_niv1_id15_ac() ++
       	dme_niv1_id15_ep() ++
       	dme_niv1_id16_ac() ++
       	dme_niv1_id16_ep() ++
       	dme_niv1_id17_ac() ++
       	dme_niv1_id17_ep() ++
       	dme_niv1_id18_ac() ++
       	dme_niv1_id18_ep() ++
      	dme_niv1_id19_ac() ++
      	dme_niv1_id19_ep() ++
 	lists:append([dme(Niv, Statut, Id) || Niv <- [niv1],
 					      Statut <- [vide, non_vide],
					      Id <- ["0022", "0023", "0024", "0025", "0026"]]) ++
	[].


dme_ano_4349()->    
    init_data_test(
      ?MSISDN, ?IMSI, "dme",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"XXhYYminZZs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]},
	{firstUseDate,"2005-06-05T07:08:09.MMMZ"},
	{lastUseDate,"2005-06-05T07:08:09.MMMZ"}]}])++
	["dme_prod",
	 {ussd2,
	  [
%	  {send,?USSD_CODE_DME_Niv1++"#"},
	  {send,"#123#"},
	   {expect, "Service indisponible. Merci de vous reconnecter ulterieurement."}
	%   {expect, "Vous n'avez pas acces a ce service."}
	   ]}].

dme_niv1_id3_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "enterprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"XXhYYminZZs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"FORF"},
		{bundleType,"0003"},
		{bundleDescription,"label forf"},
		{updateDate,"05/06/AAAA"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{updateHour,"07:08:SS"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
		  {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"} ]}]}]}]) ++

	["dme_niv1_id3_ac",
	 {ussd2,
	  [
	   %%{send,?USSD_CODE_DME_Niv1++"#"},
	   {send, "#123#"},
	   {expect,".*1:suivi conso\\+"},
	   {send,"1"},
	   {expect,"label forf : HHhMMmSSs"},
	   {send,"9*1"},
	   {expect,"Au 05/06 a 09:08,votre forfait xxh \\+bonus de "
	    "XXhYYmZZs indiquait:"?BR
	    "Solde forfait: HHhMMmSSs Valable jusqu'au: 24/01 inclus"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED},
	 {send,"1"},
	 {expect,"label forf : HHhMMmSSs"}]}].

dme_niv1_id3_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"FORF"},
		{bundleType,"0003"},
		{bundleDescription,"label forf"},
		{updateDate,"05/06/AAAA"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{updateHour,"07:08:SS"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
		  {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id3_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08,votre forfait xxh \\+bonus de 2h18m48s "
	    "indiquait:"?BR
	    "Depassement de: 7h58m48s"?BR
	    "Renouvellement forfait le 24/01"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id2_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0002"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"FORF"},
		{bundleType,"0003"},
		{bundleDescription,"label forf"},
		{updateDate,"05/06/AAAA"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{updateHour,"07:08:SS"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
		  {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id2_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06 a 09:08"?BR
	    "votre conso optima indiquait: 1h54m34s"?BR
	    "Dont 2h18m48s de bonus Orange"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id2_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0002"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"FORF"},
		{bundleType,"0003"},
		{bundleDescription,"label forf"},
		{updateDate,"05/06/AAAA"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{updateHour,"07:08:SS"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
		  {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id2_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,
	    "A cette date, aucune conso sur votre forfait optima"?BR
	    "Bonus Orange: 2h18m48s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id1_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0001"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"FORF"},
		{bundleType,"0003"},
		{bundleDescription,"label forf"},
		{updateDate,"05/06/AAAA"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{updateHour,"07:08:SS"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
		  {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id1_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Vous disposez d'un abonnement Orange."?BR
	    "Au 05/06 a 09:08, le montant de vos communications depuis "
	    "votre derniere facture s'elevait a 10000.00 EUR"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id1_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"0"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0001"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"FORF"},
		{bundleType,"0003"},
		{bundleDescription,"label forf"},
		{updateDate,"05/06/AAAA"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{updateHour,"07:08:SS"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
		  {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id1_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Vous disposez d'un abonnement Orange."?BR
	    "A cette date, nous n'avons enregistre aucune communication "
	    "sur votre abo depuis votre derniere facture"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id13_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0013"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id13_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Vous disposez d'un abonnement Data."?BR
	    "Au 05/06 a 09:08, le montant de vos communications depuis "
	    "votre derniere facture s'elevait a 10000.00 EUR"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id13_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"0"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0013"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id13_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Vous disposez d'un abonnement Data."?BR
	    "A cette date, nous n'avons enregistre aucune communication "
	    "sur votre abo depuis votre derniere facture"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id7_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0007"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id7_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08, vous aviez consomme 1h54m34s de "
	    "communications nationales"?BR
	    "Autre Conso: 10000.00 EUR \\(international, numeros speciaux, "
	    "roaming, SMS\\)"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id7_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0007"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id7_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, nous n'avons enregistre aucune "
	    "communication nationale"?BR
	    "Autre Conso: 10000.00 EUR \\(international, numeros speciaux, "
	    "roaming, SMS\\)"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id14_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0014"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"VALEU"},{value,"18"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id14_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08, vous aviez consomme 1h54m34s de "
	    "communications nationales"?BR
	    "Autre Conso: 10000.00 EUR \\(SMS, roaming, etc\\)"?BR
	    "Renouvellement forfait le 25/01"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id14_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0014"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id14_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, nous n'avons enregistre aucune "
	    "communication nationale"?BR
	    "Autre Conso: 10000.00 EUR \\(international, numeros speciaux, "
	    "roaming, SMS\\)"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id8_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0008"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id8_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "conso forfait optima: 1h54m34s"?BR
	    "Dont OBDD de visiophonie"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id8_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0008"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id8_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, aucune conso sur votre forfait optima et visiophonie"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: xxh \\+7h58m48s"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id11_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0011"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min33s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id11_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06 a 09:08"?BR
	    "Votre conso: 1h54m34s"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Votre forfait partage mobiles xxh "
	    "\\+ 2h18m48s de bonus: 1h54m33s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id11_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0011"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h30min01s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"VALEU"},{value,"50"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id11_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06 a 09:08"?BR
	    "Votre conso: 0h30m01s"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Votre forfait partage mobiles xxh "
	    "\\+ 2h18m48s de bonus est epuisee. "
	    "Depassement de: 50.00EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id9_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0009"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"2h54min34s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id9_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06, 09:08"?BR
	    "Votre conso: 2h54m34s"?BR
	    "Hors forf: 10000.00 EUR"?BR
	    "Conso du forfait partage mobiles \\+ bonus: 1h54m34s"?BR
	    "Meilleur choix: forfait xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id9_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0009"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id9_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, aucune conso"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Conso du forfait partage mobiles \\+ bonus: epuise"?BR
	    "Meilleur choix: forfait xxh \\+7h58m48s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id10_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0010"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id10_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Vous aviez consomme 1h54m34s de communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id10_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0010"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id10_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, nous n'avons enregistre aucune communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id12_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0012"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id12_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Vous aviez consomme 1h54m34s de communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id12_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0012"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id12_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, nous n'avons enregistre aucune communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id15_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0015"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id15_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06, a 09:08"?BR
	    "Votre conso forfait Intense Entreprises indiquait: 1h54m34s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id15_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0015"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id15_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, vous n'avez pas consomme sur votre forfait Intense Entreprises"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh \\+7h58m48s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id16_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0016"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id16_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06 a 09:08"?BR
	    "Votre conso forfait heures Business Everywhere optima indiquait: 1h54m34s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id16_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0016"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id16_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"A cette date, vous n'avez pas consomme sur votre forfait heures Business Everywhere"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh \\+7h58m48s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv1_id17_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0017"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id17_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08, "
	    "votre forfait heures Business Everywhere xxh indiquait: "
	    "Solde forfait: 1h54m34s"?BR
	    "Valable jusqu'au: 24/01 inclus Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id17_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0017"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id17_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08, votre forfait heures Business Everywhere xxh indiquait "
	    "Depassement de: 0h00m59s"?BR
	    "Renouvellement forfait le 24/01"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id18_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0018"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"XXhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"balance"},{unit,"TEMPS"},{value,"6h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id18_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"05/06, a 09:08"?BR
	    "Votre conso Optima Europe indiquait: xxhYYmZZs"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima : forfait xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id18_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0018"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"balance"},{unit,"TEMPS"},{value,"6h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id18_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,
	    "A cette date, vous n'avez pas consomme sur votre option Optima Europe"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima : forfait xxh \\+0h00m59s"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id19_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0019"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id19_ac",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Votre forfait Business Everywhere International indiquait:"?BR
	    "Solde credit 2H Wi-Fi roaming: 1h54m34s"?BR
	    "Conso Hors Forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv1_id19_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0019"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]},
       {bundle,
	[{priorityType,"B"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv1_id19_ep",
	 {ussd2,
	  [{send,?USSD_CODE_DME_Niv1++"#"},

	   {expect,"Au 05/06 a 09:08, votre forfait Business Everywhere "
	    "International indiquait un depassement de 0h00m59s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "1:suivi conso\\+"
	   },
	   {expect, ?NOT_SPLITTED}]}].


%% DME NIV 2

dme_niv2() ->
    test_util_of:change_navigation_to_niv2(?IMSI) ++
     	dme_niv2_id3_ac() ++
     	dme_niv2_id3_ep() ++
      	dme_niv2_id2_ac() ++
       	dme_niv2_id2_ep() ++
       	dme_niv2_id1_ac() ++
       	dme_niv2_id1_ep() ++
       	dme_niv2_id13_ac() ++
       	dme_niv2_id13_ep() ++
       	dme_niv2_id7_ac() ++
       	dme_niv2_id7_ep() ++
       	dme_niv2_id14_ac() ++
       	dme_niv2_id14_ep() ++
       	dme_niv2_id8_ac() ++
       	dme_niv2_id8_ep() ++
       	dme_niv2_id11_ac() ++
       	dme_niv2_id11_ep() ++
      	dme_niv2_id9_ac() ++
      	dme_niv2_id9_ep() ++
      	dme_niv2_id10_ac() ++
      	dme_niv2_id10_ep() ++
      	dme_niv2_id12_ac() ++
      	dme_niv2_id12_ep() ++
     	dme_niv2_id15_ac() ++
     	dme_niv2_id15_ep() ++
     	dme_niv2_id16_ac() ++
     	dme_niv2_id16_ep() ++
     	dme_niv2_id17_ac() ++
     	dme_niv2_id17_ep() ++
     	dme_niv2_id18_ac() ++
     	dme_niv2_id18_ep() ++
    	dme_niv2_id19_ac() ++
    	dme_niv2_id19_ep() ++
 	lists:append([dme(Niv, Statut, Id) || Niv <- [niv2],
 					      Statut <- [vide, non_vide],
					      Id <- ["0022", "0023", "0024", "0025", "0026"]]) ++
	[].

dme_niv2_id3_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv2_id3_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08, forfait xxh \\+bonus de "
	    "2h18m48s"?BR
	    "Solde forfait: HHhMMmSSs Validite: 24/01 inclus"?BR
	    "Conso hors forfait: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id3_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}]) ++

	["dme_niv2_id3_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08, forfait xxh \\+bonus de 2h18m48s"?BR
	    "Depassement de 7h58m48s"?BR
	    "Renouvellement le 24/01"?BR
	    "Conso hors forfait: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id2_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0002"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id2_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 09:08"?BR
	    "Conso optima:1h54m34s"?BR
	    "Dont bonus:2h18m48s"?BR
	    "Hors forfait:10000.00 EUR"?BR
	    "Meilleur choix optima:forfait xxh \\+0h00m59s"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id2_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0002"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id2_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso optima"?BR
	    "Votre Bonus: 2h18m48s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait xxh"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id1_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0001"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id1_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Vous disposez d'un abonnement Orange."?BR
	    "Au 05/06 a 09:08, Vous aviez consomme depuis votre derniere facture 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id1_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"0"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0001"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id1_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Vous disposez d'un abonnement Orange."?BR
	    "A cette date, vous n'aviez pas consomme sur votre abo depuis votre derniere facture"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id13_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0013"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id13_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Vous disposez d'un abonnement Data."?BR
	    "Au 05/06 a 09:08, vous aviez consomme depuis votre derniere facture 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id13_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"0"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0013"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id13_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Vous disposez d'un abonnement Data."?BR
	    "A cette date, vous n'aviez pas consomme sur votre abo depuis votre derniere facture"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id7_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0007"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id7_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08, conso nationale: 1h54m34s"?BR
	    "Autre Conso: 10000.00 EUR \\(international, numeros speciaux, "
	    "roaming, SMS\\)"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id7_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0007"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id7_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso nationale"?BR
	    "Autre Conso: 10000.00 EUR \\(international, numeros speciaux, "
	    "roaming, SMS\\)"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id14_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0014"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"VALEU"},{value,"18"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id14_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08, conso nationale: 1h54m34s, soit 18.00EUR Autre Conso: 10000.00 EUR \\(SMS, roaming, etc\\)"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id14_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0014"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id14_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso nationale"?BR
	    "Autre Conso: 10000.00 EUR \\(international, numeros speciaux, "
	    "roaming, SMS\\)"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id8_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 
      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0008"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id8_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08"?BR
	    "conso optima: 1h54m34s"?BR
	    "Dont OBDD en visiophonie"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix: xxh \\+0h00m59s"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id8_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0008"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id8_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso sur votre forfait optima et visiophonie"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix: xxh \\+7h58m48s"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id11_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0011"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min33s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id11_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06, 09:08"?BR
	    "Votre conso: 1h54m34s"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Solde forfait partage mobiles xxh \\+ 2h18m48s de bonus: 1h54m33s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id11_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0011"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h30min01s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"VALEU"},{value,"50"}]}]}]}]) ++

	["dme_niv2_id11_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06, 09:08"?BR
	    "Votre conso:0h30m01s"?BR
	    "Hors forf:10000.00 EUR"?BR
	    "Solde forf partage mobile xxh \\+bonus 2h18m48s epuise "
	    "Depassement:50.00EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id9_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0009"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"2h54min34s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id9_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06"?BR
	    "Votre conso:2h54m34s"?BR
	    "Hors forf:10000.00 EUR"?BR
	    "Forfait partage:1h54m34s"?BR
	    "Meilleur choix: forfait xxh \\+0h00m59s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id9_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0009"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id9_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso"?BR
	    "Hors forfait: 10000.00 EUR"?BR
	    "Conso du forfait: 0h00m00s"?BR
	    "Meilleur choix: forfait xxh \\+7h58m48s"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id10_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0010"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id10_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Vous aviez consomme 1h54m34s de communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id10_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0010"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id10_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, nous n'avons enregistre aucune communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id12_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0012"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id12_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Vous aviez consomme 1h54m34s de communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id12_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0012"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id12_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, nous n'avons enregistre aucune communication nationale"?BR
	    "Conso hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id15_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0015"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"50h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id15_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06, a 09:08"?BR
	    "conso forfait Intense: 1h54m34s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait 50h \\+0h00m59s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id15_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0015"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"50h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id15_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso forf Intense Entreprises"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait 50h \\+7h58m48s"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id16_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0016"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"30h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id16_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08"?BR
	    "conso forfait heures BE: 1h54m34s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait 30h \\+0h00m59s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id16_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0016"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"45h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv2_id16_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso forfaits heures BE"?BR
	    "Conso hors forfait:10000.00 EUR"?BR
	    "Meilleur choix optima: forfait 45h \\+7h58m48s"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv2_id17_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0017"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id17_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08 "
	    "forfait heures Business Everywhere 10h "
	    "Solde forfait: 1h54m34s"?BR
	    "Validite: 24/01 inclus"?BR
	    "Conso hors forf: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id17_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0017"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id17_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08 forfait heures Business Everywhere 10h "
	    "Depassement de: 0h00m59s"?BR
	    "Renouvellement le 24/01"?BR
	    "Conso hors forf:10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id18_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0018"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"balance"},{unit,"TEMPS"},{value,"6h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id18_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "05/06, a 09:08"?BR
	    "conso Optima Europe: 10h12m12s"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima : forfait 10h \\+0h00m59s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id18_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0018"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"balance"},{unit,"TEMPS"},{value,"6h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id18_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "A cette date, aucune conso Optima Europe"?BR
	    "Conso hors forfait: 10000.00 EUR"?BR
	    "Meilleur choix optima: forfait 10h \\+0h00m59s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id19_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0019"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id19_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Solde credit 2H Wi-Fi roaming: 1h54m34s"?BR
	    "Conso Hors Forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv2_id19_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0019"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv2_id19_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08, votre forfait indiquait un depassement "
	    "de 0h00m59s"?BR
	    "Hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

%%%%%%%%%%%%%%%%%%%%
%% DME NIV 2

dme_niv3() ->
    test_util_of:change_navigation_to_niv3(?IMSI) ++
     	dme_niv3_id3_ac() ++
     	dme_niv3_id3_ep() ++
      	dme_niv3_id2_ac() ++
       	dme_niv3_id2_ep() ++
       	dme_niv3_id1_ac() ++
       	dme_niv3_id1_ep() ++
       	dme_niv3_id13_ac() ++
       	dme_niv3_id13_ep() ++
       	dme_niv3_id7_ac() ++
       	dme_niv3_id7_ep() ++
       	dme_niv3_id14_ac() ++
       	dme_niv3_id14_ep() ++
       	dme_niv3_id8_ac() ++
       	dme_niv3_id8_ep() ++
       	dme_niv3_id11_ac() ++
       	dme_niv3_id11_ep() ++
      	dme_niv3_id9_ac() ++
      	dme_niv3_id9_ep() ++
      	dme_niv3_id10_ac() ++
      	dme_niv3_id10_ep() ++
      	dme_niv3_id12_ac() ++
      	dme_niv3_id12_ep() ++
     	dme_niv3_id15_ac() ++
     	dme_niv3_id15_ep() ++
     	dme_niv3_id16_ac() ++
     	dme_niv3_id16_ep() ++
     	dme_niv3_id17_ac() ++
     	dme_niv3_id17_ep() ++
     	dme_niv3_id18_ac() ++
     	dme_niv3_id18_ep() ++
    	dme_niv3_id19_ac() ++
    	dme_niv3_id19_ep() ++
 	lists:append([dme(Niv, Statut, Id) || Niv <- [niv3],
 					      Statut <- [vide, non_vide],
					      Id <- ["0022", "0023", "0024", "0025", "0026"]]) ++
	[].

dme_niv3_id3_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]}]}]}]) ++

	["dme_niv3_id3_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 solde forfait 10h:HHhMMmSSs"?BR
	    "Conso hors forfait:10000.00EUR"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id3_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"99.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0003"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]}]}]}]) ++

	["dme_niv3_id3_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 forfait 10h depasse de 7h58m48s"?BR
	    "Hors forfait:100.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id2_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0002"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"1h29min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id2_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08"?BR
	    "Conso optima: 1h54m34s"?BR
	    "Hors forfait: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id2_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0002"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id2_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso optima"?BR
	    "Hors forfait: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id1_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0001"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"1h29min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id1_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08 conso sur abonnement Orange 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id1_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"0"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0001"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id1_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso sur votre abonnement Orange"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id13_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0013"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"1h29min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id13_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08 conso sur votre abonnement Data: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id13_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"0"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0013"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id13_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso sur abonnement Data"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id7_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0007"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"1h29min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id7_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08 conso nationale: 1h54m34s"?BR
	    "Autre Conso:10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id7_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0007"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id7_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso nationale"?BR
	    "Autre Conso:10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id14_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0014"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"VALEU"},{value,"18"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id14_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08 conso nationale: 18.00EUR Autre conso:10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id14_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0014"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id14_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso nationale"?BR
	    "Autre Conso:10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id8_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 
      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0008"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id8_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08"?BR
	    "conso optima: 1h54m34s"?BR
	    "Hors forfait: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id8_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0008"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id8_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso optima"?BR
	    "Hors forfait: 10000.00 EUR"},
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id11_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0011"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min33s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"50h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id11_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06"?BR
	    "Conso:1h54m34s"?BR
	    "Hors forf:10000.00EUR"?BR
	    "Forfait 50h:1h54m33s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id11_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"99.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0011"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h30min01s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"60h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"VALEU"},{value,"50"}]}]}]}]) ++

	["dme_niv3_id11_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06"?BR
	    "Conso:0h30m01s"?BR
	    "Hors forfait:100.00EUR"?BR
	    "forfait 60h:epuisee"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id9_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0009"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"2h54min34s"}]},
	   {credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id9_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06"?BR
	    "Conso:2h54m34s"?BR
	    "Hors forf:10000.00E"?BR
	    "Forf partage:1h54m34s"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id9_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0009"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id9_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Aucune conso"?BR
	    "Hors forfait:10000.00 EUR"?BR
	    "Forf partage:0h00m00s"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id10_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"99.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0010"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id10_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Votre conso:1h54m34s"?BR
	    "Hors forfait:100.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id10_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"99.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0010"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id10_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso nationale"?BR
	    "Hors forfait:100.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id12_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0012"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id12_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Au 05/06 a 09:08"?BR
	    "Votre conso:1h54m34s"?BR
	    "Hors forfait:10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id12_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"99.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0012"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id12_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso nationale"?BR
	    "Hors forfait:100.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id15_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0015"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id15_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06, a 09:08"?BR
	    "conso optima:1h54m34s"?BR
	    "Hors forfait:10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id15_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0015"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id15_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso optima"?BR
	    "Hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id16_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 

      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0016"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min01s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id16_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08"?BR
	    "Conso optima: 1h54m34s"?BR
	    "Hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id16_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0016"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"MMS"},{value,"0"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"0h00min02s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"7h58min48s"}]}]}]}]) ++

	["dme_niv3_id16_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"A cette date, aucune conso Optima"?BR
	    "Hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].


dme_niv3_id17_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0017"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id17_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 solde forfait 10h: 1h54m34s"?BR
	    "Hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id17_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0017"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id17_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 forfait 10h"?BR
	    "depasse de 0h00m59s"?BR
	    "Hors forfait:10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id18_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, 
      %%	
      "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0018"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"balance"},{unit,"TEMPS"},{value,"6h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id18_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "05/06, a 09:08"?BR
	    "conso optima: 10h12m12s"?BR
	    "Hors forfait:10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id18_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0018"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"consumed"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"balance"},{unit,"TEMPS"},{value,"6h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id18_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "A cette date, aucune conso optima"?BR
	    "Hors forfait: 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id19_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0019"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1h54min34s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id19_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 a 09:08"?BR
	    "Solde forfait 1h54m34s"?BR
	    "Hors Forfait 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

dme_niv3_id19_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "entreprise",
      [{amount,[{name,"hfDise"},{allTaxesAmount,"9999.999"}]}],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"FORF"},
	 {bundleType,"0019"},
	 {bundleDescription,"label forf"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]},
	   {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]},
	   {credit,[{name,"standard"},{unit,"TEMPS"},{value,"10h12min12s"}]},
	   {credit,[{name,"excess"},{unit,"TEMPS"},{value,"0h00min59s"}]}]}]}]) ++

	["dme_niv3_id19_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"05/06 forfait depasse de 0h00m59s"?BR
	    "hors forfait 10000.00 EUR"
	   },
	   {expect, ?NOT_SPLITTED}]}].

prepaid() ->
    test_util_of:set_parameter_for_test(refonte_ergo_mobi,true) ++
     	init_in_sachem_fake("mobi", ?mobi) ++
     	mobi() ++
   	init_in_sachem_fake("cmo", ?ppol3) ++
   	cmo() ++
    	cmo_sce()++
 	init_in_sachem_fake("mobi", ?mobi) ++
	
    	pathos("CMO",1) ++
    	pathos("CMO",2) ++
    	pathos("CMO",3) ++
	
    	pathos("MOB",1) ++
    	pathos("MOB",2) ++
    	pathos("MOB",3) ++

	[].

init_in_sachem_fake(Sub,DCL_NUM) ->
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, 
	[possum@localhost,ets,
	 insert,[sdp_compte,{?IMSI,{{DCL_NUM,0,[#compte{tcp_num=?C_PRINC,
						      unt_num=?EURO,
						      cpp_solde=50000,
						      dlv=pbutil:unixtime(),
						      rnv=0,
						      etat=?CETAT_AC,
						      ptf_num=?PCLAS_V2},
						#compte{tcp_num=?C_FORF,
						      unt_num=?EURO,
						      cpp_solde=50000,
						      dlv=pbutil:unixtime(),
						      rnv=0,
						      etat=?CETAT_AC,
						      ptf_num=?PCLAS_V2}
					     ]},[]}}]]},
       {rpc, call, [possum@localhost, ets, insert, [sub, {?IMSI, Sub}]]}
      ]}
    ].


mobi() ->
    test_util_of:change_subscription(?IMSI,"mobi") ++
	mobi_niv1_sans_o2o() ++
 	new_product() ++
       	mobi_niv2() ++
       	mobi_niv3() ++
	[].

pathos(SUB, Niv) ->
    test_util_of:change_navigation_to_niv(Niv, ?IMSI) ++
	patho(Niv, SUB,?ETAT_SI) ++
	patho(Niv, SUB,?ETAT_SF) ++
	patho(Niv, SUB,?ETAT_SV) ++
	patho(Niv, SUB,?ETAT_SA) ++
	patho(Niv, SUB,?ETAT_SR) ++
	patho(Niv, SUB,?ETAT_RA) ++
	[].

patho(Niv,SUB,ETAT_PATHO) ->
    ["test "++SUB++" niv "++integer_to_list(Niv)++
     " patho etat_patho_spider="++integer_to_list(ETAT_PATHO)] ++
    init_data_test(
      ?MSISDN, ?IMSI, integer_to_list(ETAT_PATHO), "prepaid", SUB,
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]}       
      ]) ++
	["mobi_patho",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, patho_expect(SUB,ETAT_PATHO,Niv)}]}].

patho_expect("MOB",?ETAT_SI, 1) -> 
    "Mobicarte suspendue: merci de vous rendre dans un point de vente "
	"mobicarte avec une pi.ce d'identit.";
patho_expect("MOB",?ETAT_SF, 1) -> 
    "la mobicarte.*Compte mobicarte suspendu : vos appels sont bloqu.s..*"
	"Veuillez contacter le service-clients mobicarte.";
patho_expect("MOB",?ETAT_SV, 1) -> 
    "la mobicarte.*Compte mobicarte suspendu : vos appels sont bloqu.s..*"
	"Veuillez contacter le service-clients mobicarte.";
patho_expect("MOB",?ETAT_SA, 1) ->
    "la mobicarte.*Compte mobicarte suspendu : vos appels sont bloqu.s..*"
	"Veuillez contacter le service-clients mobicarte.";
patho_expect("MOB",?ETAT_SR, 1) ->
    "la mobicarte.*La date limite de rechargement est d.pass.e..*Votre "
	"mobicarte est d.finitivement inutilisable.";
patho_expect("MOB",?ETAT_RA, 1) ->
    "la mobicarte.*La date limite de rechargement est d.pass.e..*Votre "
	"mobicarte est d.finitivement inutilisable.";

patho_expect("MOB",?ETAT_SI, 2) -> 
    "Mobicarte suspendue: merci de vous rendre dans un point de vente "
	"mobicarte avec une pi.ce d'identit.";
patho_expect("MOB",?ETAT_SF, 2) -> 
    "la mobicarte.*Compte mobicarte suspendu : vos appels sont bloqu.s..*"
	"Veuillez contacter le service-clients mobicarte.";
patho_expect("MOB",?ETAT_SV, 2) -> 
    "la mobicarte.*Compte mobicarte suspendu : vos appels sont bloqu.s..*"
	"Veuillez contacter le service-clients mobicarte.";
patho_expect("MOB",?ETAT_SA, 2) -> 
    "la mobicarte.*Compte mobicarte suspendu : vos appels sont bloqu.s..*"
	"Veuillez contacter le service-clients mobicarte.";
patho_expect("MOB",?ETAT_SR, 2) -> 
    "la mobicarte.*La date limite de rechargement est d.pass.e..*Votre "
	"mobicarte est d.finitivement inutilisable.";
patho_expect("MOB",?ETAT_RA, 2) -> 
    "la mobicarte.*La date limite de rechargement est d.pass.e..*Votre "
	"mobicarte est d.finitivement inutilisable.";

patho_expect("MOB",?ETAT_SI, 3) -> 
    "Mobicarte suspendue: votre identit. ne nous est pas parvenue.";
patho_expect("MOB",?ETAT_SF, 3) -> 
    "votre mobicarte est suspendu : vos appels sont bloqu.s.";
patho_expect("MOB",?ETAT_SV, 3) -> 
    "votre mobicarte est suspendu : vos appels sont bloqu.s.";
patho_expect("MOB",?ETAT_SA, 3) -> 
    "votre mobicarte est suspendu : vos appels sont bloqu.s.";
patho_expect("MOB",?ETAT_SR, 3) -> 
    "Votre mobicarte est d.finitivement inutilisable.";
patho_expect("MOB",?ETAT_RA, 3) -> 
    "la mobicarte.*Votre mobicarte est d.finitivement inutilisable.";

patho_expect("CMO",?ETAT_SI, 1) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SF, 1) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SV, 1) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SA, 1) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SR, 1) -> 
    "La date limite de rechargement est d.pass.e..*Votre Compte Mobile est "
	"d.finitivement inutilisable.";
patho_expect("CMO",?ETAT_RA, 1) ->
    "Votre compte mobile est r.sili.. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";

patho_expect("CMO",?ETAT_SI, 2) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SF, 2) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SV, 2) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SA, 2) -> 
    "Votre compte mobile est suspendu. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";
patho_expect("CMO",?ETAT_SR, 2) -> 
    "La date limite de rechargement est d.pass.e..*Votre Compte Mobile est "
	"d.finitivement inutilisable.";
patho_expect("CMO",?ETAT_RA, 2) -> 
    "Votre compte mobile est r.sili.. Vous ne pouvez pas acc.der . ce "
	"service. Contactez votre service-clients Orange.";


patho_expect("CMO",?ETAT_SI, 3) -> "Votre compte mobile est suspendu.";
patho_expect("CMO",?ETAT_SF, 3) -> "Votre compte mobile est suspendu.";
patho_expect("CMO",?ETAT_SV, 3) -> "Votre compte mobile est suspendu.";
patho_expect("CMO",?ETAT_SA, 3) -> "Votre compte mobile est suspendu.";
patho_expect("CMO",?ETAT_SR, 3) -> "Votre compte mobile est d.finitivement "
				       "inutilisable.";
patho_expect("CMO",?ETAT_RA, 3) -> "Votre compte mobile est r.sili..".


mobi_niv1_avec_o2o() ->
    test_util_of:change_navigation_to_niv1(?IMSI) ++
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true) ++
	mobi_niv1_ac_avec_o2o() ++
	mobi_niv1_ep_avec_o2o() ++
	[].

mobi_niv1_ac_avec_o2o() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate,"2006-07-08T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
       {bundle,
	[{priorityType,"C"},
	 {restitutionType,"SOLDE"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]}
      ]) ++
	["mobi_niv1_solde_ac_avec_o2o",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "mobi_niv1: 3h34m11s ou 45SMS.*Jsq 08/07 inclus.*1:Suivi conso +.*le meilleur tarif pour les sms.*2:En savoir +.*3:Menu.*4:Aide"}, %%Anomalie 1663
	   {send, "2"},
	   {expect, "250\\+50 SMS a 25E 250SMS utilisables en SMS ou MMS \\+ 50SMS \\(1MMS=3SMS\\) Orange pour 25E par mois !.*1:Souscrire.*9:Menu.*8:Precedent"},
	   {send,"9"},
	   {expect,"Menu #123#"}
	   ]}] ++
	["mobi_niv1_solde_ac_avec_o2o",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "mobi_niv1: 3h34m11s ou 45SMS.*Jsq 08/07 inclus.*1:Suivi conso +.*le meilleur tarif pour les sms.*2:En savoir +.*3:Menu.*4:Aide"}, %%Anomalie 1663
	   {send, "1"},
	   {expect, "[^Choix non disponible]"},
	   {send,"2"},
	   {expect,"Menu #123#"}
	   ]}].

mobi_niv1_ep_avec_o2o() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["mobi_niv1_solde_ep_avec_o2o",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "mobicarte.*"
	    "Votre credit est epuise.*"
	    "Pour conserver votre numero .*"
	    "pensez a recharger avant le 18/03/05.*1:Recharger.2:Menu.3:Aide"}]}].


%%%%%%

mobi_niv1_sans_o2o() ->
    ["Desactivation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost, 
			    pcontrol, disable_itfs, 
			    [[io_oto_mqseries1,possum@localhost]]]}]}] ++
    test_util_of:change_navigation_to_niv1(?IMSI) ++
       	mobi_dossier_inconnu() ++
      	mobi_erreur_spider() ++
	mobi_niv1_ac_sans_o2o() ++
	mobi_niv1_ep_sans_o2o() ++
	mobi_niv1_ac_avec_godet_solde() ++ 
	mobi_niv1_ac_sans_o2o_LCONSO() ++
 	mobi_niv1_bundleDescription() ++
  	mobi_miro_aucun_palier_avec_date() ++
  	mobi_miro_aucun_palier_sans_date() ++
  	mobi_miro_un_palier() ++
  	mobi_miro_dernier_palier() ++	
	[].

mobi_dossier_inconnu() ->
    delete_data_test(?MSISDN, ?IMSI) ++
	["mobi_dossier_inconnu",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
%	  {expect,"Service indisponible. Merci de vous reconnecter ulterieurement."}]
	 {expect,"Service Indisponible. Nous vous invitons a consulter votre compte sur www.orange.fr>espace client"}]
	  %{expect,"Service Indisponible."}]

	  
	 }].

mobi_erreur_spider() ->
    delete_data_test(?MSISDN, ?IMSI) ++
	test_util_spider:build_and_insert_error_xml(?MSISDN, ?IMSI, mobi, 
						    "0") ++
	["mobi_erreur_spider",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Service indisponible. Merci de vous reconnecter ulterieurement."}]
	 }].

mobi_niv1_ac_sans_o2o() ->
     init_data_test(
       ?MSISDN, ?IMSI, "prepaid", "MOB",
       [],
       [{bundle,
 	[{priorityType,"A"},
 	 {restitutionType,"PTF"},
 	 {bundleDescription,"mobi_niv1"},
 	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
 	 {desactivationDate,"2006-07-08T07:08:09.MMMZ"},
 	 {credits,
 	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
 	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
 	  ]}]}]) ++
	["mobi_niv1_solde_ac_sans_o2o",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"mobi_niv1: 3h34m11s ou 45SMS"?BR
	    "Jsq 08/07/06 inclus"?BR
	    "Appuyez repondre,tapez 1,envoyez"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

mobi_niv1_ac_sans_o2o_LCONSO() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
      {bundle,
	[{priorityType,"D"},
	 {restitutionType,"LCONSO"},
	 {reinitDate,"50"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"rollOver"},{unit,"SMS"},{value,"45"}]}
	  ]}]}]) ++
	["mobi_niv1_solde_ac_sans_o2o_LCONSO",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"mobi_niv1: 3h34m11s ou 45SMS"?BR
	    "Jsq 05/06/05 inclus.*"
	    "1:Suivi conso \\+"?BR
	    "2:Menu"},
	   {expect, ?NOT_SPLITTED},
	   {send, "2"},
	   {expect,".*"},
	   {send, "1*1"},
	   {expect, "mobi_niv1 \\+report 45SMS utilisable jusqu'au 05/06 inclus Renouvele tous les jours jusqu'au 5 juin 2005 inclus.*8:Precedent.*9:Accueil"}] 
	  ++ acces_menu()}].

mobi_niv1_bundleDescription() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
      {bundle,
	[{priorityType,"D"},
	 {restitutionType,"LCONSO"},
	 {reinitDate,"50"},
	 {bundleDescription,"TITRED|mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"rollOver"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
      {bundle,
	[{priorityType,"C"},
	 {restitutionType,"SOLDE"},
	 {bundleType,"0005"},
	 {bundleDescription,"TITREC|C_LIB|"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-12-12T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"SMS"},{value,"10"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"5"}]}]}]}
      ]) ++
	["mobi_niv1_bundleDescription",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"mobi_niv1: 3h34m11s ou 45SMS"?BR
	    "Jsq 05/06/05 inclus.*"
	    "1:Suivi conso \\+"?BR
	    "2:Menu"},
	   {expect, ?NOT_SPLITTED},
	   {send, "1"},
	   {expect,"1:TITREC.2:TITRED"},
	   {send,"2"},
	   {expect, "mobi_niv1 \\+report 45SMS utilisable jusqu'au 05/06 inclus Renouvele tous les jours jusqu'au 5 juin 2005 inclus.*8:Precedent.*9:Accueil"},
	   {send,"81"},
	   {expect, "C_LIB.*8:Precedent.*9:Accueil"}] ++ acces_menu()}].

mobi_niv1_ac_avec_godet_solde() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"SOLDE"},
		{bundleType,"1"},
		{bundleDescription,"Solde"},
		{exhaustedLabel,"Solde"},
		{reactualDate, "2007-02-28T09:48:56.844Z"},
		{desactivationDate, "2006-08-11T07:08:09.MMMZ"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"VALEU"},{value,"2"} ]},
		  {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]}]
		}]}]) ++
	["TEST :mobi_niv1_ac_sans_godet_solde",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"mobi_niv1: 3h34m11s ou 45SMS"?BR
	    "Jsq 05/06/05 inclus"?BR
	    "Solde .*report 18SMS : 2.00EUR a utiliser jusqu'au 11/08 inclus.*"
	    "2:Menu"}] ++ acces_menu()}].

mobi_niv1_ep_sans_o2o() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv1"},
	 {exhaustedLabel,"mobi_niv1 mobicarte"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["mobi_niv1_solde_ep_sans_o2o",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	  % {expect, "mobi_niv1 mobicarte: epuise"?BR
	  %  "Votre numero est valide jsq: 18/03/05."?BR
	  %  "1:Recharger"?BR
	  %  "2:Menu"},
	  {expect,"mobicarte.Votre credit est epuise..Pour conserver votre numero 0612345678.pensez a recharger avant le 18/03/05..1:Recharger.2:Menu.3:Aide." },
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].

mobi_niv2() ->
    test_util_of:change_navigation_to_niv2(?IMSI) ++
	%mobi_dossier_inconnu() ++
	mobi_erreur_spider() ++
	mobi_niv2_ac() ++
	mobi_niv2_ac_avec_godet_solde() ++
	mobi_niv2_ep().

mobi_niv2_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv2"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2006-07-06T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]}]) ++
	["mobi_niv2_solde_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "mobi_niv2: 3h34m11s ou 45SMS"?BR
	    "Jsq 06/07/06"},
	   {expect, ?NOT_SPLITTED}]}].

mobi_niv2_ac_avec_godet_solde() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv2"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"SOLDE"},
		{bundleType,"1"},
		{bundleDescription,"Solde"},
		{exhaustedLabel,"Solde"},
		{reactualDate, "2007-02-28T09:48:56.844Z"},
		{desactivationDate, "2006-08-11T07:08:09.MMMZ"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"VALEU"},{value,"2"} ]},
		  {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]}]}]}]) ++
	["TEST :mobi_niv2_ac_sans_godet_solde",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "mobi_niv2: 3h34m11s ou 45SMS"?BR
	    "Jsq 05/06/05.*"
	    "Solde .*report 18SMS : 2.00EUR jusqu'au 11/08"},
	   {expect, ?NOT_SPLITTED}]}].

mobi_niv2_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv2"},
	 {exhaustedLabel,"mobi_niv2 mobicarte"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["mobi_niv2_solde_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	  % {expect, "mobi_niv2 mobicarte: epuise"?BR
	  %  "Votre numero est valide jsq: 18/03/05."},
	  {expect, "mobicarte.Votre credit est epuise..Pour conserver votre numero 0612345678.pensez a recharger avant le 18/03/05."},
	   {expect, ?NOT_SPLITTED}]}].

mobi_niv3() ->
    test_util_of:change_navigation_to_niv3(?IMSI) ++
%	mobi_dossier_inconnu() ++
	mobi_erreur_spider() ++
	mobi_niv3_ac() ++
	mobi_niv3_ac_avec_godet_solde() ++
	mobi_niv3_ep().

mobi_niv3_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv3"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2006-07-06T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]}]) ++
	["mobi_niv3_solde_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "mobi_niv3: 3h34m11s ou 45SMS"?BR
	    "Jsq 06/07"},
	   {expect, ?NOT_SPLITTED}]}].

mobi_niv3_ac_avec_godet_solde() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv3"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
       {bundle,[{priorityType,"B"},
		{restitutionType,"SOLDE"},
		{bundleType,"1"},
		{bundleDescription,"Solde"},
		{exhaustedLabel,"Solde"},
		{reactualDate, "2007-02-28T09:48:56.844Z"},
		{desactivationDate, "2006-08-11T07:08:09.MMMZ"},
		{credits,
		 [{credit,[{name,"balance"},{unit,"VALEU"},{value,"2"} ]},
		  {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]}]}]}]) ++
	["TEST :mobi_niv3_ac_sans_godet_solde",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "mobi_niv3: 3h34m11s ou 45SMS"?BR
	    "Jsq 05/06.*"},
	   {send,"1"},
	   {expect,"Solde .*report 18SMS : 2.00EUR a utiliser jusqu'au 11/08 inclus"}]}].

mobi_niv3_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"mobi_niv3"},
	 {exhaustedLabel,"mobi_niv3 mobicarte"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["mobi_niv3_solde_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "mobi_niv3 mobicarte: epuise"?BR
	    "Validite numero: 18/03."},
	   {expect, ?NOT_SPLITTED}]}].




mobi_miro_aucun_palier_avec_date() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"Mobi"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "AdditionalInfo"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]}
	  ]}]},
       {bundle,
	[{priorityType,"C"},
	 {restitutionType,"SOLDE"},
	 {bundleType,"0005"},
	 {bundleDescription,"C_LIB"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-12-12T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"SMS"},{value,"10"}]},
	   {credit,[{name,"rollOver"},{unit,"SMS"},{value,"5"}]}]}]},
      {bundle,
	[{priorityType,"F"},
	 {restitutionType,"TG"},
	 {reinitDate,"50"},
	 {bundleDescription,"Mira"},
	 {thresholdFlag,"0"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {lastUseDate, "2007-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "aucun palier"},
	 {credits,
	  [{credit,[{name,"counter"},{unit,"EURO"},{value,"5.300"},{additionalInfo, "1"}]},
	   {credit,[{name,"toNextStage"},{unit,"EURO"},{value,"6.202"},{additionalInfo, "1"}]},
	   {credit,[{name,"nextGain"},{unit,"%"},{value,"42"},{additionalInfo, "1"}]},
	   {credit,[{name,"nextReducedPrice"},{unit,"EURO"},{value,"10.004"},{additionalInfo, "1"}]}
	  ]}]}]) ++
	["mobi_miro Aucun palier Avec Date",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Mobi: 3h34m11s"?BR
	    "Jsq 05/06/05 inclus.*"
	    "1:Suivi conso \\+"?BR
	    "2:Menu"},
	   {expect, ?NOT_SPLITTED},
	   {send, "1"},
	   {expect, "Mira:"?BR
	    "Vous avez consomme 5.30 EUR  nationales"
	    " Il vous reste a consommer 6.20 EUR  nationales avant le 05/06/07 "
	    "pour beneficier de 42  nationales soit 10.00 EUR  nationales."},
	   {send,"11"},
	   {expect,"C_LIB .report 5SMS : 10SMS a utiliser jusqu'au 12/12 inclus.*"}
	   ] }].

mobi_miro_aucun_palier_sans_date() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"Mobi"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "AdditionalInfo"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]}
	  ]}]},
      {bundle,
	[{priorityType,"F"},
	 {restitutionType,"TG"},
	 {reinitDate,"50"},
	 {bundleDescription,"Mira"},
	 {thresholdFlag,"0"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "aucun palier"},
	 {credits,
	  [{credit,[{name,"counter"},{unit,"EURO"},{value,"5.300"},{additionalInfo, "1"}]},
	   {credit,[{name,"toNextStage"},{unit,"EURO"},{value,"6.202"},{additionalInfo, "1"}]},
	   {credit,[{name,"nextGain"},{unit,"%"},{value,"42"},{additionalInfo, "1"}]},
	   {credit,[{name,"nextReducedPrice"},{unit,"EURO"},{value,"10.004"},{additionalInfo, "1"}]}
	  ]}]}]) ++
	["mobi_miro Aucun palier Sans Date",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Mobi: 3h34m11s"?BR
	    "Jsq 05/06/05 inclus.*"
	    "1:Suivi conso \\+"?BR
	    "2:Menu"},
	   {expect, ?NOT_SPLITTED},
	   {send, "1"},
	   {expect, "Mira:"?BR
	    "Vous avez consomme 5.30 EUR  nationales Il vous reste a consommer 6.20 EUR  nationales "
	    "pour beneficier de 42  nationales soit 10.00 EUR  nationales.*"}
	   ] }].

mobi_miro_un_palier() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"Mobi"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "AdditionalInfo"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]}
	  ]}]},
      {bundle,
	[{priorityType,"F"},
	 {restitutionType,"TG"},
	 {reinitDate,"50"},
	 {bundleDescription,"Miru"},
	 {thresholdFlag,"0"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {lastUseDate, "2007-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "aucun palier"},
	 {credits,
	  [{credit,[{name,"counter"},{unit,"EURO"},{value,"5.300"},{additionalInfo, "1"}]},
	   {credit,[{name,"toNextStage"},{unit,"EURO"},{value,"6.202"},{additionalInfo, "1"}]},
	   {credit,[{name,"gain"},{unit,"%"},{value,"71"},{additionalInfo, "1"}]},
	   {credit,[{name,"nextGain"},{unit,"%"},{value,"42"},{additionalInfo, "1"}]},
	   {credit,[{name,"reducedPrice"},{unit,"EURO"},{value,"15.004"}]},
	   {credit,[{name,"nextReducedPrice"},{unit,"EURO"},{value,"10.004"},{additionalInfo, "1"}]}
	  ]}]}]) ++
	["mobi_miro Un palier",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Mobi: 3h34m11s"?BR
	    "Jsq 05/06/05 inclus.*"
	    "1:Suivi conso \\+"?BR
	    "2:Menu"},
	   {expect, ?NOT_SPLITTED},
	   {send, "1"},
	   {expect, "Miru:"?BR
	    "Vous avez consomme 5.30 EUR  nationales, "
	    "vous beneficiez actuellement d'une reduction de 15.00 EUR"?BR
	    "1:Suite.*"},
	   {send, "1"},
	   {expect, "Il vous reste a consommer 6.20 EUR  nationales avant le 05/06/07 "
	   "pour beneficier de 42  nationales soit 10.00 EUR  nationales.*"}
	  ] }].

mobi_miro_dernier_palier() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "MOB",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"PTF"},
	 {bundleDescription,"Mobi"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "AdditionalInfo"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]}
	  ]}]},
      {bundle,
	[{priorityType,"F"},
	 {restitutionType,"TG"},
	 {reinitDate,"50"},
	 {bundleDescription,"Mire"},
	 {thresholdFlag,"1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {lastUseDate, "2007-06-05T07:08:09.MMMZ"},
	 {bundleAdditionalInfo, "aucun palier"},
	 {credits,
	  [{credit,[{name,"counter"},{unit,"EURO"},{value,"5.300"},{additionalInfo, "1"}]},
	   {credit,[{name,"toNextStage"},{unit,"EURO"},{value,"6.202"},{additionalInfo, "1"}]},
	   {credit,[{name,"gain"},{unit,"%"},{value,"71"},{additionalInfo, "1"}]},
	   {credit,[{name,"nextGain"},{unit,"%"},{value,"42"},{additionalInfo, "1"}]},
	   {credit,[{name,"reducedPrice"},{unit,"EURO"},{value,"15.004"}]},
	   {credit,[{name,"nextReducedPrice"},{unit,"EURO"},{value,"10.004"},{additionalInfo, "1"}]}
	  ]}]}]) ++
	["mobi_miro Dernier palier",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Mobi: 3h34m11s"?BR
	    "Jsq 05/06/05 inclus.*"
	    "1:Suivi conso \\+"?BR
	    "2:Menu"},
	   {expect, ?NOT_SPLITTED},
	   {send, "1"},
	   {expect, "Mire:"?BR
	    "Vous avez consomme plus de 5.30 EUR  nationales, "
	    "vous beneficiez actuellement d'une reduction de 15.00 EUR valable jusqu'au 05/06/07."}
	  ] }].


%%%%%%%%%%%
cmo() ->
    test_util_of:change_subscription(?IMSI,"cmo") ++
	cmo_niv2() ++
	cmo_niv3() ++
	[].

cmo_sce() ->
    test_util_of:change_subscription(?IMSI,"cmo") ++
	test_util_of:set_parameter_for_test(sce_used,true)++
  	cmo_niv1_sce() ++
  	cmo_niv2() ++
 	cmo_niv3() ++
	[].


cmo_niv1_sce() ->
    test_util_of:change_navigation_to_niv1(?IMSI) ++
	cmo_niv1_dossier_inconnu() ++
	cmo_niv1_ac_sce() ++
	cmo_niv1_ep_sce().

cmo_niv1_dossier_inconnu() ->
    delete_data_test(?MSISDN, ?IMSI) ++
	["cmo_niv1_solde_ac_sans_o2o",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	%   {expect,"Service indisponible. Merci de vous reconnecter ulterieurement."}]
	 {expect,"Forfait: 50min0sec communications nationales, soit 50.00 EUR valables jusqu'au"}]
	 }].
    
cmo_niv1_sce_avec_o2o()->
    test_util_of:set_parameter_for_test(sce_used,true)++
	["cmo niv1 avec oto"] ++
	init_data_test(
	  ?MSISDN, ?IMSI, "prepaid", "CMO",
	  [],
	  [{bundle,
	    [{priorityType,"A"},
	     {restitutionType,"CPTMOB"},
	     {bundleDescription,"cmo_niv1"},
	     {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	     {credits,
	      [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	       {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	      ]}]}]) ++
	["cmo_niv1_solde_ac with oto by SCE",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "cmo_niv1: 3h34m11s ou 45SMS.*Fact.: 25/01.*le meilleur tarif pour les sms.*1:En savoir +.*2:suivi conso.*9:Menu"},
	   {send, "1"},
	   {expect,"250\\+50 SMS a 25E 250SMS utilisables en SMS ou MMS \\+ 50SMS \\(1MMS=3SMS\\) Orange pour 25E par mois !.*1:Souscrire"},
	   {send,"9"},
	   {expect,"Menu #123#"}]}]++
	["cmo_niv1_solde_ac with oto by SCE : Test Internal error fix",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "cmo_niv1: 3h34m11s ou 45SMS.*Fact.: 25/01.*le meilleur tarif pour les sms.*1:En savoir +.*2:suivi conso.*9:Menu"},
	   {send, "2"},
	   {expect,"cmo_niv1: 3h34m11s ou 45SMS.*Prochaine fact.: 25/01.*1:notre conseil.*9:Menu"},
	   {send,"9"},
	   {expect,"Menu #123#"}]}].

cmo_niv1_ac_sce() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "CMO",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"CPTMOB"},
	 {bundleDescription,"cmo_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]},
      {bundle,
	[{priorityType,"D"},
	 {restitutionType,"LCONSO"},
	 {reinitDate,"50"},
	 {bundleDescription,"TITRED|cmo_niv1"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"rollOver"},{unit,"SMS"},{value,"45"}]}
	  ]}]}
       ]) ++
	["cmo_niv1_solde_ac by SCE",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, ".*ppuyez sur repondre, tapez 1 et envoyez.*1:Menu"},
	   {send, "1"},
	   {expect,".*"},	   
	   {send, "3"},
	   {expect,"1:Suivi conso detaille.*"},
	   {send, "1"},
	   {expect, 
	    "cmo_niv1: 3h34m11s ou 45SMS"?BR
	    "Prochaine fact.: 25/01"?BR
	    "1:Suivi conso.."?BR?BR
	    "9:Accueil"},
	   {send,"1"},
	   {expect,"cmo_niv1 .report 45SMS"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu_sce()}].

cmo_niv1_ep_sce() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "CMO",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"CPTMOB"},
	 {bundleDescription,"cmo_niv1"},
	 {exhaustedLabel,"cmo_niv1_ep"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["cmo_niv1_solde_ep by SCE",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   %{expect, "tapez repondre puis.*1:Suivi detaille"},
	   {expect, ".*epuise.*Choix 1 du Menu pour recharger.*ppuyez sur repondre, tapez 1 et envoyez.*1:Menu"},
	   {send, "1"},
	   {expect,".*"},	   
	   {send, "3"},
	   {expect,"1:Suivi conso detaille.*"},
	   {send, "1"},
	   {expect,
	    "cmo_niv1_ep: epuise"?BR
	    "Prochaine fact.: 25/01.*"
	    "9:Accueil"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu_sce()}].


cmo_niv2() ->
    test_util_of:change_navigation_to_niv2(?IMSI) ++
	cmo_niv2_ac() ++
	cmo_niv2_ep().

cmo_niv2_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "CMO",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"CPTMOB"},
	 {bundleDescription,"cmo_niv2"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]}]) ++
	["cmo_niv2_solde_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "cmo_niv2: 3h34m11s ou 45SMS"?BR
	    "Prochaine fact.: 25/01"},
	   {expect, ?NOT_SPLITTED}]}].

cmo_niv2_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "CMO",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"CPTMOB"},
	 {bundleDescription,"cmo_niv2"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["cmo_niv2_solde_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    ": epuise"?BR
	    "Prochaine fact.: 25/01"},
	   {expect, ?NOT_SPLITTED}]}].

cmo_niv3() ->
    test_util_of:change_navigation_to_niv3(?IMSI) ++
	cmo_niv3_ac() ++
	cmo_niv3_ep().

cmo_niv3_ac() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "CMO",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"CPTMOB"},
	 {bundleDescription,"cmo_niv3"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	  ]}]}]) ++
	["cmo_niv3_solde_ac",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    "cmo_niv3: 3h34m11s ou 45SMS"?BR
	    "Fact.: 25/01"},
	   {expect, ?NOT_SPLITTED}]}].

cmo_niv3_ep() ->
    init_data_test(
      ?MSISDN, ?IMSI, "prepaid", "CMO",
      [],
      [{bundle,
	[{priorityType,"A"},
	 {restitutionType,"CPTMOB"},
	 {bundleDescription,"cmo_niv3"},
	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	 {credits,
	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"0h00min00s"}]}
	  ]}]}]) ++
	["cmo_niv3_solde_ep",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,
	    ": epuise"?BR
	    "Fact.: 25/01"?BR
	   },
	   {expect, ?NOT_SPLITTED}]}].

init_oto()->
    rpc:call(possum@localhost,one2one_offers,csv2mnesia,["test_sample.csv"]),
    PAUSE = 2000,
    ["Activation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost, 
			    pcontrol, enable_itfs, 
			    [[io_oto_mqseries1,possum@localhost]]]}]},
     "Pause de "++ integer_to_list(PAUSE) ++" Ms",
     {pause, PAUSE}] ++
	test_util_of:set_parameter_for_test(one2one_activated_cmo,true) ++
	test_util_of:set_parameter_for_test(one2one_activated_mobi,true) ++
	test_util_of:set_parameter_for_test(one2one_activated_postpaid,true) ++
	[].

o2o() ->
    init_oto() ++
  	test_util_of:change_subscription(?IMSI,"postpaid") ++
  	postpaid_niv1_avec_o2o() ++
 	init_in_sachem_fake("cmo", ?ppol3) ++
      	cmo_niv1_sce_avec_o2o() ++
   	init_in_sachem_fake("mobi", ?mobi) ++
 	mobi_niv1_avec_o2o().


%%%%%
% New product
%%%%%

new_product() ->
    ["Desactivation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost, 
			    pcontrol, disable_itfs, 
			    [[io_oto_mqseries1,possum@localhost]]]}]}] ++
	test_util_of:change_navigation_to_niv1(?IMSI) ++
	init_data_test(
	  ?MSISDN, ?IMSI, "prepaid", "M6P",
	  [],
	  [{bundle,
	    [{priorityType,"A"},
	     {restitutionType,"PTF"},
	     {bundleDescription,"mobi_niv1"},
	     {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	     {desactivationDate,"2006-07-08T07:08:09.MMMZ"},
	     {credits,
	      [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
	       {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
	      ]}]}]) ++
	["new product",
	 {ussd2,
	  [{send,?USSD_CODE"*#"}, 
	   {expect,"mobi_niv1: 3h34m11s ou 45SMS"?BR
	    "Jsq 08/07/06 inclus.*"
	    "1:Menu"},
	   {expect, ?NOT_SPLITTED}] ++ acces_menu()}].


connect() ->
    [{connect_smpp, {"localhost", 7431}}].

dme(Niveau,Statut_credit_consomme,Id) ->

    Libelle = "dme_" ++ atom_to_list(Niveau) ++ "_id" ++ Id ++ "_cc_" ++ atom_to_list(Statut_credit_consomme),
    Valeur_credit_consomme = case Statut_credit_consomme of
				 vide -> "0";
				 _ -> "3.00"
			     end,
    case Niveau of
	niv1 -> test_util_of:change_navigation_to_niv(1, ?IMSI);
	niv2 -> test_util_of:change_navigation_to_niv(2, ?IMSI);
	niv3 -> test_util_of:change_navigation_to_niv(3, ?IMSI)
    end,

    init_data_test(?MSISDN,
		   ?IMSI,
		   "entreprise",
		   [{amount,[{name,"hfDise"},{allTaxesAmount,"9.999"}]}],%montant hf dise

		   case Niveau of 
		       niv1 ->
			   [{bundle,
			     [{priorityType,"A"},
			      {restitutionType,"FORF"},
			      {bundleType,Id},
			      {bundleDescription,"label forf"},
			      {reactualDate,"2005-06-05T07:08:09.MMMZ"},
			      {credits,
			       [{credit,[{name,"consumed"},{unit,"VALEU"},{value,Valeur_credit_consomme}]},%crédit consommé
				{credit,[{name,"totalConsumed"},{unit,"VALEU"},{value,"7"}]},%crédit consommé total
				{credit,[{name,"standard"},{unit,"VALEU"},{value,"18"}]}]}]},%abonnement montant
			    {bundle,
			     [{priorityType,"B"},
			      {restitutionType,"FORF"},
			      {bundleType,"0022"},
			      {bundleDescription,"label forf"},
			      {reactualDate,"2005-06-05T07:08:09.MMMZ"},
			      {credits,
			       [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"HHhMMminSSs"}]},
				{credit,[{name,"standard"},{unit,"TEMPS"},{value,"xxhYYminZZs"}]}]}]}];
		       _ ->
			   [{bundle,
			     [{priorityType,"A"},
			      {restitutionType,"FORF"},
			      {bundleType,Id},
			      {bundleDescription,"label forf"},
			      {reactualDate,"2005-06-05T07:08:09.MMMZ"},
			      {credits,
			       [{credit,[{name,"consumed"},{unit,"VALEU"},{value,Valeur_credit_consomme}]},%crédit consommé
				{credit,[{name,"totalConsumed"},{unit,"VALEU"},{value,"7"}]},%crédit consommé total
				{credit,[{name,"standard"},{unit,"VALEU"},{value,"18"}]}]}]}]%abonnement montant
		   end
) ++
		      
	[Libelle,
	 {ussd2,
	  [case Niveau of
	       niv1 -> 
		   {send,?USSD_CODE_DME_Niv1++"#"};
	       _ ->
		   {send,?USSD_CODE++"*#"}
	   end,

	   case {Niveau,Statut_credit_consomme,Id} of

	       {niv1,vide,"0022"} ->

		   {expect,"A cette date, aucune conso"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    "Conso du forfait partage mobiles: 7.00EUR"?BR
		    "Meilleur choix: forfait 18.00EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,_,"0022"} ->

		   {expect,"05/06, 09:08"?BR
		    "Votre conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forf: 10.00 EUR"?BR
		    "Conso du forfait partage mobiles: 7.00EUR"?BR
		    "Meilleur choix: forfait 18.00EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,vide,"0023"} ->

		   {expect,"A cette date, aucune conso sur votre forfait partage mobiles"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,_,"0023"} ->

		   {expect,"05/06 a 09:08"?BR
		    "Votre conso du forfait partage mobiles: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,vide,"0024"} ->

		   {expect,"A cette date, aucune conso"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    "Conso du forfait fixes-mobiles: 7.00EUR"?BR
		    "Meilleur choix: forfait 18.00EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,_,"0024"} ->

		   {expect,"05/06, 09:08"?BR
		    "Votre conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    "Conso du forfait fixes-mobiles: 7.00EUR"?BR
		    "Meilleur choix: forfait 18.00EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,vide,"0025"} ->

		   {expect,"A cette date, aucune conso sur votre forfait fixes-mobiles"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,_,"0025"} ->

		   {expect,"05/06 a 09:08"?BR
		    "Votre conso forfait fixes-mobiles: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,vide,"0026"} ->

		   {expect,"A cette date, vous n'avez pas consomme sur votre forfait Intense Entreprises"?BR
		    "Conso hors forfait: 10.00 EUR"?BR
		    "Meilleur choix optima: forfait 18.00EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

	       {niv1,_,"0026"} ->

		   {expect,"05/06, a 09:08"?BR
		    "Votre conso forfait Intense Entreprises indiquait: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Conso hors forfait: 10.00 EUR"?BR
		    "Meilleur choix optima: forfait 18.00EUR"?BR
		    ?UNP"suivi conso\\+"
		   };

 	       {niv2,vide,"0022"} ->

 		   {expect,"A cette date, aucune conso"?BR
 		    "Hors forfait: 10.00 EUR"?BR
 		    "Conso forfait partage mobiles: 7.00EUR"?BR
 		    "Meilleur choix: forfait 18.00EUR"
 		   };

 	       {niv2,_,"0022"} ->

 		   {expect,"05/06, 09:08"?BR
 		    "Votre conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
 		    "Hors forf: 10.00 EUR"?BR
 		    "Forf partage mobiles: 7.00EUR"?BR
 		    "Meilleur choix: forfait 18.00EUR"
 		   };

	       {niv2,vide,"0023"} ->

		   {expect,"A cette date, aucune conso sur votre forf partage mobiles"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv2,_,"0023"} ->

		   {expect,"05/06 a 09:08"?BR
		    "Votre conso du forfait partage mobiles: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv2,vide,"0024"} ->

		   {expect,"A cette date, aucune conso"?BR
		    "Hors forfait: 10.00 EUR"?BR
		    "Conso du forf fixes-mobiles: 7.00EUR"?BR
		    "Meilleur choix: forfait 18.00EUR"
		   };

	       {niv2,_,"0024"} ->

		   {expect,"05/06, 09:08"?BR
		    "Votre conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forf: 10.00 EUR"?BR
		    "Forfait fixes-mobiles: 7.00EUR"?BR
		    "Meilleur choix: forfait 18.00EUR"
		   };

	       {niv2,vide,"0025"} ->

		   {expect,"A cette date, aucune conso sur votre forfait fixes-mobiles"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv2,_,"0025"} ->

		   {expect,"05/06, 09:08"?BR
		    "Votre conso forfait fixes-mobiles: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv2,vide,"0026"} ->

		   {expect,"A cette date, aucune conso forf Intense Entreprises"?BR
		    "Conso hors forfait: 10.00 EUR"?BR
		    "Meilleur choix optima: forfait 18.00EUR"
		   };

	       {niv2,_,"0026"} ->

		   {expect,"05/06, a 09:08"?BR
		    "conso forfait Intense: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Conso hors forfait: 10.00 EUR"?BR
		    "Meilleur choix optima: forfait 18.00EUR"
		   };

 	       {niv3,vide,"0022"} ->

 		   {expect,"Aucune conso"?BR
 		    "Hors forfait: 10.00 EUR"?BR
 		    "Forf partage: 7.00EUR"
 		   };

 	       {niv3,_,"0022"} ->

 		   {expect,"05/06"?BR
 		    "Conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
 		    "Hors forf: 10.00 EUR"?BR
 		    "Forf partage: 7.00EUR"
 		   };

	       {niv3,vide,"0023"} ->

		   {expect,"Aucune conso"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv3,_,"0023"} ->

		   {expect,"05/06"?BR
		    "votre conso forf partage: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv3,vide,"0024"} ->

		   {expect,"Aucune conso"?BR
		    "Hors forf: 10.00 EUR"?BR
		    "Fixes-mobiles: 7.00EUR"
		   };

	       {niv3,_,"0024"} ->

		   {expect,"05/06"?BR
		    "Conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forf: 10.00 EUR"?BR
		    "Fixes-mobiles: 7.00EUR"
		   };

	       {niv3,vide,"0025"} ->

		   {expect,"Aucune conso forfait fixes-mobiles"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv3,_,"0025"} ->

		   {expect,"05/06, 09:08"?BR
		    "Conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv3,vide,"0026"} ->

		   {expect,"A cette date, aucune conso"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       {niv3,_,"0026"} ->

		   {expect,"05/06, a 09:08"?BR
		    "conso: " ++ Valeur_credit_consomme ++ "EUR"?BR
		    "Hors forfait: 10.00 EUR"
		   };

	       _ ->
		   []
	   end,

	   {expect, ?NOT_SPLITTED}]}].

delete_data_test(MSISDN, IMSI)->
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,delete,[{imsi, IMSI}]]}]
     }],
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,delete,[{msisdn, MSISDN}]]}]
     }].
    
    

init_data_test(MSISDN, IMSI, BILLINGTOOL, AMOUNTS, BUNDLES) ->
    init_data_test(MSISDN, IMSI, BILLINGTOOL, "", AMOUNTS, BUNDLES).
init_data_test(MSISDN, IMSI, BILLINGTOOL, OFFERPORSUID, AMOUNTS, BUNDLES) ->
    init_data_test(MSISDN, IMSI, "2", BILLINGTOOL, OFFERPORSUID, AMOUNTS,
		   BUNDLES).
init_data_test(MSISDN, IMSI, FILESTATE, BILLINGTOOL, OFFERPORSUID, AMOUNTS,
	       BUNDLES) ->
    ["Set imsi="++IMSI++" and msisdn="++MSISDN,
     {msaddr, [{subscriber_number, private,IMSI},
	       {international,isdn,to_international(MSISDN)} ]}] ++
	build_and_insert_xml(MSISDN, IMSI, FILESTATE, BILLINGTOOL,
			     OFFERPORSUID, AMOUNTS, BUNDLES,
			     [{status, [{statusCode, "a200"}]}]).

build_and_insert_xml(MSISDN, IMSI, FILESTATE, BILLINGTOOL, OFFERPORSUID,
		     AMOUNTS, BUNDLES, STATUSLIST) ->
    XML = xml_resp(MSISDN, IMSI, FILESTATE, BILLINGTOOL, OFFERPORSUID,
			AMOUNTS, BUNDLES, STATUSLIST),
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }].

xml_resp(MSISDN, IMSI, FILESTATE, BILLINGTOOL, OFFERPORSUID, AMOUNTS,
	      BUNDLES, STATUSLIST) ->
    XMERL_FORM =
	[{getBalanceResponse,[],
	  [{file,[],
	    [{offerType,BILLINGTOOL},
	     {durationHf, "OBDD"},
	     {invoiceDate,"2005-02-24T07:08:00.MMMZ"},
	     {custImsi,IMSI},
	     {custMsisdn,MSISDN},
	     {fileState, FILESTATE},
	     {nextInvoice,"2005-01-24T07:08:00.MMMZ"},
	     {validityDate,"2005-03-18T07:08:00.MMMZ"},
	     {amounts, AMOUNTS},
	     {offerPOrSUid, OFFERPORSUID}]},
	   {bundles,[], BUNDLES},
	   {statusList, STATUSLIST}]}],
    lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)).

to_international("0"++M) -> "+33"++M.

msisdn2imsi(MSISDN) ->
    MSISDN_NAT = sachem_server:intl_to_nat(MSISDN),
    "20801"++MSISDN_NAT.

change_msidn_to_niv1(MSISDN) -> change_imei_by_msisdn(MSISDN,"").
change_msidn_to_niv2(MSISDN) -> change_imei_by_msisdn(MSISDN,"100006XXXXXXX2").
change_msidn_to_niv3(MSISDN) -> change_imei_by_msisdn(MSISDN,"100005XXXXXXX3").

change_imei_by_msisdn(MSISDN, IMEI) ->
    [{shell_no_trace,
      [ {send, "mysql -B -u possum -ppossum -e "
	 "\"UPDATE users SET imei='"++IMEI++"'"
	 " WHERE msisdn='"++MSISDN++"'\" mobi"}
       ]}].


ins_spider_acct(FILE) ->
    F=code:lib_dir(pservices_orangef)++"/test/spider_files/"++FILE,
    case file:read_file(F) of
	{ok, Bin} ->
	    String = binary_to_list(Bin),
	    MSISDN = get_msisdn(String),
	    IMSI = "20801"++MSISDN,
	    true = mod_spider:insert(MSISDN, IMSI, String),
	    add_in_handsim(MSISDN, IMSI, String);

	_ -> {cant_read, F}
    end.

nat2int("0"++T) -> "+33"++T.    

get_msisdn([]) -> "";
get_msisdn("<custMsisdn>"++T) -> get_msisdn1(T);
get_msisdn([H|T]) -> get_msisdn(T).

get_msisdn1("</custMsisdn>"++_) -> "";
get_msisdn1([H|T]) -> [H|get_msisdn1(T)].

add_in_handsim(MSISDN, IMSI, String) ->
    [{user,"system",L}|IT] = pbutil:get_env(handsim,identities),
    L2 = [[{msisdn,nat2int(MSISDN)},{imsi,IMSI}]|L],
    Ident2 = [{user,"system",L2}|IT],
    oma_config:change_param(handsim,identities,Ident2).

set_navigation_keywords()->
    Value = [{menu,
		     [{[{"subscription","cmo"},{"ussd_code","#123"}],
		       {"9","Accueil"}}],
		     {"00","menu"}},
		    {back,
		     [{[{"subscription","cmo"},{"ussd_code","#123"}],
		       {"8","Precedent"}},
		      {[{"language","fr"}],{"0","retour"}},
		      {[{"language","en"}],{"0","back"}}],
		     {"0","<--"}},
		    {next,[],{"1","-->"}},
		    {help,[],{"99999",no_printed}},
		    {home,[],{"000",no_printed}}],
    [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,test_util_of,
 		    set_env,[pserver,navigation_keywords,Value]]}
       ]}].
set_navigation_keywords(Subscription)->
    Value = [{menu,
	      [{[{"subscription",Subscription},{"ussd_code","#123"}],
		{"9","Accueil"}}],
	      {"00","menu"}},
	     {back,
	      [{[{"subscription",Subscription},{"ussd_code","#123"}],
		{"8","Precedent"}},
	       {[{"language","fr"}],{"0","retour"}},
	       {[{"language","en"}],{"0","back"}}],
	      {"0","<--"}},
	     {next,[],{"1","-->"}},
	     {help,[],{"99999",no_printed}},
	     {home,[],{"000",no_printed}}],
    [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,test_util_of,
 		    set_env,[pserver,navigation_keywords,Value]]}
       ]}].

reset_navigation_keywords()->
    Value = [{menu,[],{"00","menu"}},
	     {back,
	      [{[{"language","fr"}],{"0","retour"}},
	       {[{"language","en"}],{"0","back"}}],
	      {"0","<--"}},
	     {next,[],{"1","-->"}},
	     {help,[],{"99999",no_printed}},
	     {home,[],{"000",no_printed}}],
    [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,test_util_of,
 		    set_env,[pserver,navigation_keywords,Value]]}
       ]}].




