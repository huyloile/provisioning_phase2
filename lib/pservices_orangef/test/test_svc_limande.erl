-module(test_svc_limande).
-export([run/0, online/0]).
-include("../../pserver/include/page.hrl").
-include("testlimande.hrl").


run()->
    ok.

online() ->
    rpc:call(possum@localhost, fake_limande_server, start, []),
    init_offers(),
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,test()),
    rpc:call(possum@localhost, fake_limande_server, stop, []).

test()->
    [{title, "Test Limande"}] ++

	test_util_of:set_parameter_for_test(offres_eXclusives,true) ++

	test_util_of:connect()++

	lists:append([test_util_of:init_test({imsi,IMSI},
					     {subscription,SUB},
					     {navigation_level,1},
					     {msisdn,MSISDN}) || 
			 {IMSI,SUB,MSISDN} <- [{?imsi_cmo,"cmo",?msisdn_cmo},
   					       {?imsi_cmo_nok,"cmo",?msisdn_cmo_nok},
  					       {?imsi_cmo_sans_credit,"cmo",?msisdn_cmo_sans_credit},
   					       {?imsi_gp,"postpaid",?msisdn_gp},
  					       {?imsi_gp_nok,"postpaid",?msisdn_gp_nok},
					       {?imsi_mobi,"mobi",?msisdn_mobi},
					       {?imsi_mobi_nok,"mobi",?msisdn_mobi_nok}]]) ++
	
     	test_util_of:spider_test_init(?msisdn_gp,?imsi_gp,"postpaid")++
     	test_util_of:spider_test_init(?msisdn_gp_nok,?imsi_gp_nok,"postpaid")++
   	test_util_of:set_in_spider(?msisdn_mobi,?imsi_mobi,"mobi",0)++
   	test_util_of:set_in_spider(?msisdn_mobi_nok,?imsi_mobi_nok,"mobi",0)++
	
   	test_util_of:set_in_sachem(?imsi_cmo,"cmo")++
   	test_util_of:set_in_sachem(?imsi_cmo_nok,"cmo")++
   	test_util_of:set_in_sachem(?imsi_cmo_sans_credit,"cmo")++
 	test_util_of:set_in_sachem(?imsi_mobi,"mobi")++
 	test_util_of:set_in_sachem(?imsi_mobi_nok,"mobi")++
	test_util_of:insert_list_top_num(?msisdn_mobi_nat, [{"0","S"}]) ++
	test_util_of:insert_list_top_num(?msisdn_mobi_nok_nat, [{"0","S"}]) ++

	test_util_of:set_parameter_for_test(sce_used, true)++	
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true) ++
	
    	lists:append([init_compte(Sub)++setup([Sub,Offre],[])++
    		      test_subscription_limande([Sub,Offre])
   		      || Sub<-[mobi_nok,mobi],Offre<-[avec_offres,sans_offres]])++

%%     	lists:append([init_compte(Sub)++setup([Sub,Offre],[])++
%%     		      test_subscription_limande([Sub,Offre])
%%    		      || Sub<-[cmo_nok,cmo,postpaid,postpaid_nok,mobi_nok,mobi],Offre<-[avec_offres,sans_offres]])++

%%  	setup(cmo_sans_credit,avec_offres)++
%% 	init_compte(cmo_sans_credit)++
%%  	test_subscription_limande([cmo_sans_credit,avec_offres])++

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++

        [].
init_compte(postpaid)->
    [];
init_compte(postpaid_nok)->
    [];
init_compte(cmo_nok)->
     init_data_test(
       ?msisdn_cmo_nok, ?imsi_cmo_nok, "prepaid", "CMO",
       [],
       [{bundle,
   	[{priorityType,"A"},
   	 {restitutionType,"CPTMOB"},
   	 {bundleDescription,"cmo_niv1"},
   	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
   	 {credits,
   	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
   	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
   	  ]}]}]);
init_compte(cmo_sans_credit)->
     init_data_test(
       ?msisdn_cmo_sans_credit, ?imsi_cmo_sans_credit, "prepaid", "CMO",
       [],
       [{bundle,
   	[{priorityType,"A"},
   	 {restitutionType,"CPTMOB"},
   	 {bundleDescription,"cmo_niv1"},
   	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
   	 {credits,
   	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
   	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
   	  ]}]}]);
init_compte(_)->
     init_data_test(
       ?msisdn_cmo, ?imsi_cmo, "prepaid", "CMO",
       [],
       [{bundle,
 	[{priorityType,"A"},
 	 {restitutionType,"CPTMOB"},
 	 {bundleDescription,"cmo_niv1"},
 	 {reactualDate, "2005-06-05T07:08:09.MMMZ"},
 	 {credits,
 	  [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
 	   {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}
 	  ]}]}]).


test_subscription_limande([cmo,Offre])->
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_cmo}},
     {title, "Test subscription CMO "++atom_to_list(Offre)}]++
	script(Offre,ok,?imsi_cmo)++
	[];
test_subscription_limande([cmo_sans_credit,Offre])->
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_cmo_sans_credit}},
     {title, "Test subscription CMO (sans credit) "++atom_to_list(Offre)}]++
	script(Offre,sans_credit,?imsi_cmo_sans_credit)++
	[];
test_subscription_limande([cmo_nok,Offre])->
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_cmo_nok}},
     {title, "Test subscription nok CMO "++atom_to_list(Offre)}]++
	script(Offre,nok,?imsi_cmo_nok)++
	[];

test_subscription_limande([postpaid,Offre]) ->
    test_util_of:asmserv_init(?msisdn_gp,"NOACT")++
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_gp}},
     {title, "Test subscription Postpaid "++atom_to_list(Offre)}]++
	script(Offre,ok,?imsi_gp)++
    test_util_of:asmserv_restore(?msisdn_gp,"NOACT")++
	[];

test_subscription_limande([postpaid_nok,Offre]) ->
    test_util_of:asmserv_init(?msisdn_gp_nok,"NOACT")++
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_gp_nok}},
     test_util_of:set_env(pservices_orangef,offres_eXclusives,true),
     {title, "Test subscription nok Postpaid "++atom_to_list(Offre)}]++
	script(Offre,nok,?imsi_gp_nok)++
    test_util_of:asmserv_restore(?msisdn_gp_nok,"NOACT")++
	[];

test_subscription_limande([mobi,Offre])->
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_mobi}},
     {title, "Test subscription MOBI "++atom_to_list(Offre)}]++
	script(Offre,ok,?imsi_mobi)++
	[];
test_subscription_limande([mobi_nok,Offre])->
    ["Test Limande",
     {msaddr, {subscriber_number,private,?imsi_mobi_nok}},
     {title, "Test subscription nok MOBI "++atom_to_list(Offre)}]++
	script(Offre,nok,?imsi_mobi_nok)++
	[].

script(avec_offres,Success,IMSI)->
    [{ussd2,
      [{send,service_code(IMSI)},
       {expect,"1:SMS illimite.*"},
       {send,"1"},
       {expect,"SMS illimite.*"
	"1:Souscrire.*"
	"2:Description.*"
	"3:Mentions legales.*"},
       {send,"2"},
       {expect,"Descriptions1.*"
	"1:Souscrire.*"
	"2:Mentions legales.*"},
       {send,"2"},
       {expect,".*1:Suite"},
       {send,"1"},
       {expect,"suite.*"},
       {send,"1"},
       {expect,".*Repondre 1 pour confirmer.*"},
       {send,"1"},
       expected(Success)] ++
      offres_suivante(Success,IMSI)
     }];

script(_,Success,IMSI) ->
    [{ussd2,
      [{send,service_code(IMSI)},
       {expect,"Aucune offre disponible"}
      ]}].

service_code(IMSI)when
  IMSI==?imsi_gp;IMSI==?imsi_gp_nok->
    ?service_code++"*1*14#";
service_code(IMSI)when
  IMSI==?imsi_cmo;IMSI==?imsi_cmo_nok;IMSI==?imsi_cmo_sans_credit->
    ?service_code++"*1*24#";
service_code(IMSI)when
  IMSI==?imsi_mobi;IMSI==?imsi_mobi_nok->
    ?service_code++"*2*2*1#".


previous(_) ->
    "8".
expected(ok)->
    {expect,"Votre demande de souscription est en cours.*"};
expected(sans_credit)->
    {expect,"Vous n'avez pas assez de credit sur votre compte mobile.*"};
expected(_) ->
    {expect,"Votre demande de souscription est en cours. Vous allez recevoir un SMS de confirmation"}.


offres_suivante(ok,IMSI)->
    [{send,"1"},
     {expect,"Choisissez une offre:.*"},
     {send,"1"},
     {expect,"SMS illimite 2.*"},
     {send,"1"},
     {expect,"Vous souhaitez souscrire a l'offre SMS illimite 2..*"},
     {send,"1"},
     {expect,"Votre demande de souscription est en cours..*"},
     {send,"1"},
     {expect,"Choisissez une offre:.*"},
     {send,"1"},
     {expect,"SMS illimite 3.*"},
     {send,"1"},
     {expect,"Vous souhaitez souscrire a l'offre SMS illimite 3.*"},
     {send,previous(IMSI)},
     {expect,"Choisissez une offre:.*"},
     {send,previous(IMSI)},
     {expect,"Choisissez une offre:.*"},
     {send,previous(IMSI)},
     {expect,"Choisissez une offre:.*"},
     {send,previous(IMSI)},
     {expect,".*"}
    ];
offres_suivante(_,_)->
    [].

setup([cmo|T],Init_data)->    
    setup(T,Init_data,?msisdn_cmo);
setup([cmo_nok|T],Init_data)->    
    setup(T,Init_data,?msisdn_cmo_nok);
setup([postpaid_nok|T],Init_data)->    
    setup(T,Init_data,?msisdn_gp_nok);
setup([postpaid|T],Init_data)->
    setup(T,Init_data,?msisdn_gp);
setup(cmo_sans_credit,avec_offres)->
    setup([],[doscli(?msisdn_cmo_sans_credit)]++
	  liste_offres(avec_offres),
	  ?msisdn_cmo_sans_credit);
setup([mobi|T],Init_data)->    
    setup(T,Init_data,?msisdn_mobi);
setup([mobi_nok|T],Init_data)->    
    setup(T,Init_data,?msisdn_mobi_nok).
setup([Offre|T],Init_data,MSISDN) when
  Offre==sans_offres;Offre==avec_offres ->
    setup(T,[doscli(MSISDN)]++
	  liste_offres(Offre)++Init_data,
	  MSISDN);
setup([],Init_data,"+"++_MSISDN)->
    [{erlang, 
      [{rpc, call, [possum@localhost,fake_limande_server,init_data,[[{_MSISDN,Init_data}]]]}]
     }].

liste_offres(sans_offres)->
    [{'ListeOffre',[]}];

liste_offres(avec_offres) ->
    [{'ListeOffre',[],
       [{libelleOffre,[],"SMS illimite"},
	{montantOffre,[],"7"},
	{idOffre,[],"LIM1"}]},
      {'ListeOffre',[],
        [{libelleOffre,[],"SMS illimite 2"},
 	{montantOffre,[],"8"},
 	{idOffre,[],"LIM2"}]},
      {'ListeOffre',[],
        [{libelleOffre,[],"SMS illimite 3"},
 	{montantOffre,[],"9"},
 	{idOffre,[],"LIM3"}]}].

doscli(MSISDN) when 
  MSISDN==?msisdn_cmo;MSISDN==?msisdn_cmo_sans_credit ->
    {doscli,[],
     [{'LigneDeMarche',[],"CMO"},
      {'Declinaison',[],"ZAP"},
      {'DossierSachem',[],"1234568790"}
     ]};

doscli(?msisdn_cmo_nok)->
    {doscli,[],
     [{'LigneDeMarche',[],"CMO"},
      {'Declinaison',[],"ZAP"},
      {'DossierSachem',[],"1234568791"}
     ]};

doscli(?msisdn_gp_nok)->
    {doscli,[],
     [{'LigneDeMarche',[],"CMO"},
      {'Declinaison',[],"ZAP"},
      {'DossierSachem',[],"1234568792"}
     ]};

doscli(?msisdn_gp) ->
    {doscli,[],
     [{'LigneDeMarche',[],""},
      {'Declinaison',[],"Autres"},
      {'DossierSachem',[],"1234568793"}
     ]};
doscli(?msisdn_mobi) ->
    {doscli,[],
     [{'LigneDeMarche',[],"MOBI"},
      {'Declinaison',[],"ZAP"},
      {'DossierSachem',[],"1234568790"}
     ]};
doscli(?msisdn_mobi_nok) ->
    {doscli,[],
     [{'LigneDeMarche',[],"MOBI"},
      {'Declinaison',[],"ZAP"},
      {'DossierSachem',[],"1234568791"}
     ]}.

init_offers()->
    _Offres=init_offers(?Offres,[]),
    rpc:call(
      possum@localhost,
      fake_limande_server,
      init_data,
      [_Offres]).

init_offers([],XmlBodyOffres)->
    XmlBodyOffres;

init_offers([{IDOffre,MentionsA,MentionsB,Descriptions}|ListeOffre],XmlBodyOffres) ->
    Offre=#testOffre{idOffre=IDOffre,
		     mentions=[{ecran1,[],MentionsA},{ecran2,[],MentionsB}],
		     description=[{'DescriptionOffre',[],Descriptions}]},
    init_offers(ListeOffre,[{IDOffre,Offre}|XmlBodyOffres]).

init_data_test(MSISDN, IMSI, BILLINGTOOL, AMOUNTS, BUNDLES) ->
    init_data_test(MSISDN, IMSI, BILLINGTOOL, "", AMOUNTS, BUNDLES).
init_data_test(MSISDN, IMSI, BILLINGTOOL, OFFERPORSUID, AMOUNTS, BUNDLES) ->
    init_data_test(MSISDN, IMSI, "2", BILLINGTOOL, OFFERPORSUID, AMOUNTS,
		   BUNDLES).
init_data_test(MSISDN, IMSI, FILESTATE, BILLINGTOOL, OFFERPORSUID, AMOUNTS,
	       BUNDLES) ->
    ["Set imsi="++IMSI++" and msisdn="++MSISDN,
     {msaddr, [{subscriber_number, private,IMSI},
	       {international,isdn,MSISDN} ]}] ++
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

to_national("+99"++M) -> "0"++M;
to_national(M) -> M.
