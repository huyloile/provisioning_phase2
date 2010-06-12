-module(test_util_spider).
-compile(export_all).

-include("../../pdist_orangef/include/spider.hrl").


fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, ERRORS, DCL) ->
    fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, "0005", ERRORS, DCL).


fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, BUNDLETYPE, ERRORS, DCL) ->
    XMERL_FORM =
	[{getBalanceResponse,[],
	  [{statusList,[],
	    [{status,[],
	      [{statusCode,ERRORS},
	       {statusType,"0"},
	       {statusName,"BalanceGetSuccess"},
	       {statusDescription,"Successful get Invocation"}]}]},
	   {file,[],
	    [{custImsi,IMSI},
	     {custMsisdn,MSISDN},
	     {offerPOrSUid,OFFERPORUID},
	     {offerType,BILLINGTOOL},
	     {invoiceDate,"2005-01-01T07:08:00.MMMZ"},
	     {nextInvoice,"2006-02-02T07:08:00.MMMZ"},
	     {validityDate,"2007-03-08T07:08:00.MMMZ"},
	     {amounts, AMOUNTS},
	     {frSpecificPrepaidOfferValue, DCL}
	    ]},
	   {bundles,[],
	    [{bundle,[],
	      [{bundleLevel,"1"},
	       {priorityType,"A"},
	       {restitutionType,"FORF"},
	       {bundleType,BUNDLETYPE},
	       {bundleDescription,"label forf"},
	       {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	       {bundleType,"1"},
	       {bundleStatus,"-"}
	      ]}]}]}],
    lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)).

fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, BUNDLETYPE, ERRORS,suivi_conso_plus, DCL) ->
    XMERL_FORM =
	[{getBalanceResponse,[],
	  [{statusList,[],
	    [{status,[],
	      [{statusCode,ERRORS},
	       {statusType,"0"},
	       {statusName,"BalanceGetSuccess"},
	       {statusDescription,"Successful get Invocation"}]}]},
	   {file,[],
	    [{custImsi,IMSI},
	     {custMsisdn,MSISDN},
	     {offerPOrSUid,OFFERPORUID},
	     {offerType,BILLINGTOOL},
	     {invoiceDate,"2005-01-01T07:08:00.MMMZ"},
	     {nextInvoice,"2006-02-02T07:08:00.MMMZ"},
	     {validityDate,"2007-03-08T07:08:00.MMMZ"},
	     {amounts, AMOUNTS},
	     {frSpecificPrepaidOfferValue, DCL}]},
	   {bundles,[],
	    [{bundle,[],
	      [{bundleLevel,"1"},
	       {priorityType,"A"},
	       {restitutionType,"FORF"},
	       {bundleType,BUNDLETYPE},
	       {bundleDescription,"label forf"},
	       {reactualDate, "2005-06-05T07:08:09.MMMZ"},
	       {bundleType,"1"},
	       {bundleStatus,"-"}
	      ]},
	     {bundle,[],
	      [ {priorityType,"D"},
		{restitutionType,"LCONSO"},
		{reinitDate,"50"},
		{bundleDescription,"mobi_niv1"},
		{reactualDate, "2005-06-05T07:08:09.MMMZ"},
		{desactivationDate, "2005-06-05T07:08:09.MMMZ"},
		{credits,
		 [{credit,[{name,"rollOver"},{unit,"SMS"},{value,"45"}]}]},
		{bundleStatus,"-"}
	       ]}]}]}],
    lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml));

fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, BUNDLETYPE, ERRORS, CONFIG, DCL) ->
    Credit = case lists:member(actif, CONFIG) of
		 true -> [{credit,[{name,"balance"},{unit,"TEMPS"},{value,"3h34min11s"}]},
			  {credit,[{name,"balance"},{unit,"SMS"},{value,"45"}]}];
		 _ -> []
	     end,
    Conso = case lists:member(suivi_conso_plus, CONFIG) of
		true ->  
		    case lists:member(godetF, CONFIG) of
			true ->
			    [{bundle,[],
			       [{priorityType,"A"},
				{restitutionType,"PTF"},
				{bundleType,BUNDLETYPE},
				{bundleDescription,"label forf"},
				{reactualDate, "2005-06-05T07:08:09.MMMZ"},
				{desactivationDate, "2006-07-06T07:08:09.MMMZ"},
				{bundleType,"1"},
				{credits,Credit},
				{bundleStatus,"-"}]},
			      {bundle,[],
			       [{priorityType,"D"},
				{restitutionType,"LCONSO"},
				{reinitDate,"50"},
				{bundleDescription,"mobi_niv1"},
				{reactualDate, "2005-06-05T07:08:09.MMMZ"},
				{desactivationDate, "2005-06-05T07:08:09.MMMZ"},
				{credits,
				 [{credit,[{name,"rollOver"},{unit,"SMS"},{value,"45"}]}]},
				{bundleStatus,"-"}
			      ]},
			     {bundle,[],
			      [{priorityType,"F"},
			       {restitutionType,"SOLDE"},
			       {reinitDate,"300"},
			       {bundleDescription,"Bonus Usages|Solde Bonus Usages"},
			       {credits,
				[{credit,[{name,"balance"},{unit,"TEMPS"},{value,"1000min00s"}]}]},
			       {firstUseDate,"2005-06-05T07:08:09.MMMZ"},
			       {lastUseDate,"2009-08-13T07:08:09.MMMZ"},
			       {bundleStatus,"-"}]}
			      ];
			_ ->
			    [{bundle,[],
                              [{priorityType,"A"},
                               {restitutionType,"PTF"},
                               {bundleType,BUNDLETYPE},
                               {bundleDescription,"label forf"},
                               {reactualDate, "2005-06-05T07:08:09.MMMZ"},
                               {desactivationDate, "2006-07-06T07:08:09.MMMZ"},
                               {bundleType,"1"},
                               {credits,Credit},
                               {bundleStatus,"-"}]},
                             {bundle,[],
                              [{priorityType,"D"},
                               {restitutionType,"LCONSO"},
                               {reinitDate,"50"},
                               {bundleDescription,"mobi_niv1"},
                               {reactualDate, "2005-06-05T07:08:09.MMMZ"},
                               {desactivationDate, "2005-06-05T07:08:09.MMMZ"},
                               {credits,
                                [{credit,[{name,"rollOver"},{unit,"SMS"},{value,"45"}]}]},
                               {bundleStatus,"-"}]}
			    ]
		    end;
		    _ -> [{bundle,[],
			   [{priorityType,"A"},
			    {restitutionType,"PTF"},
			    {bundleType,BUNDLETYPE},
			    {bundleDescription,"label forf"},
			    {reactualDate, "2005-06-05T07:08:09.MMMZ"},
			    {desactivationDate, "2006-07-06T07:08:09.MMMZ"},
			    {bundleType,"1"},
			    {credits,Credit},
			    {bundleStatus,"-"}]}]
	    end,	    
    XMERL_FORM =
	[{getBalanceResponse,[],
	  [{statusList,[],
	    [{status,[],
	      [{statusCode,ERRORS},
	       {statusType,"0"},
	       {statusName,"BalanceGetSuccess"},
	       {statusDescription,"Successful get Invocation"}]}]},
	   {file,[],
	    [{custImsi,IMSI},
	     {custMsisdn,MSISDN},
	     {offerPOrSUid,OFFERPORUID},
	     {offerType,BILLINGTOOL},
	     {invoiceDate,"2005-01-01T07:08:00.MMMZ"},
	     {nextInvoice,"2006-02-02T07:08:00.MMMZ"},
	     {validityDate,"2007-03-08T07:08:00.MMMZ"},
	     {amounts, AMOUNTS},
	     {frSpecificPrepaidOfferValue, DCL}]},
	   {bundles,[],Conso}]}],
    lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)).
    


build_and_insert_xml(IMSI, SUB, DCL) ->
    MSISDN = "+9"++sachem_cmo_fake:make_msisdn(IMSI),
    build_and_insert_xml(MSISDN, IMSI, SUB, DCL).

build_and_insert_xml(IMSI, SUB=mobi, CONFIG, DCL)
  when is_list(CONFIG)->
    MSISDN = "+9"++sachem_cmo_fake:make_msisdn(IMSI),
    build_and_insert_xml(MSISDN, IMSI, SUB, CONFIG, DCL);
build_and_insert_xml(IMSI, SUB,pas_reponse, DCL) ->
    MSISDN = "+9"++sachem_cmo_fake:make_msisdn(IMSI),
    build_and_insert_xml(MSISDN, IMSI, SUB,pas_reponse, DCL);
build_and_insert_xml(IMSI, SUB,suivi_conso_plus, DCL) ->
    MSISDN = "+9"++sachem_cmo_fake:make_msisdn(IMSI),
    build_and_insert_xml(MSISDN, IMSI, SUB,suivi_conso_plus, DCL);
build_and_insert_xml(MSISDN, IMSI, postpaid, DCL) ->
    build_and_insert_xml(MSISDN, IMSI, "postpaid", "3G", DCL);
build_and_insert_xml(MSISDN, IMSI, mobi, DCL) ->
    build_and_insert_xml(MSISDN, IMSI, "prepaid", "MOB", DCL);
build_and_insert_xml(MSISDN, IMSI, dme, DCL) ->
    build_and_insert_xml(MSISDN, IMSI, "entreprise", "", DCL);
build_and_insert_xml(MSISDN, IMSI, cmo, DCL) ->
    build_and_insert_xml(MSISDN, IMSI, "prepaid", "CMO", DCL).

build_and_insert_xml(MSISDN, IMSI, mobi, CONFIG, DCL) 
  when is_list(CONFIG)->
    XML = fake_xml_resp(MSISDN, IMSI, "prepaid", "MOB", [],"0005", "a300", CONFIG, DCL),
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }];

build_and_insert_xml(MSISDN, IMSI, mobi, pas_reponse, DCL)  ->
    io:format("~n~nICI~n~n"),
    XML = timeout,
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }];

build_and_insert_xml(MSISDN, IMSI, mobi, suivi_conso_plus, DCL)->
    XML = fake_xml_resp(MSISDN, IMSI, "prepaid", "MOB", [],"0005", "a300", suivi_conso_plus, DCL),
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }];

build_and_insert_xml(MSISDN, IMSI, BILLINGTOOL="entreprise", OFFERPORSUID, DCL) ->
    XML = fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORSUID, [], "0003", "a300", DCL),
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }];
build_and_insert_xml(MSISDN, IMSI, BILLINGTOOL, OFFERPORSUID, DCL) ->
    XML = fake_xml_resp(MSISDN, IMSI, BILLINGTOOL, OFFERPORSUID, [], "a300", DCL),
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }].

build_and_insert_error_xml(MSISDN, IMSI, mobi, DCL) ->
    XML = spider_error_response(IMSI, MSISDN, "mobi", "a303", DCL),
    [{erlang,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,mod_spider,insert,[MSISDN, IMSI, XML]]}]
     }].

%% +type spider_default_response(string(), string(), string())
%%   -> spider_response().
spider_default_response(Imsi, Msisdn, Sub, DCL) ->
    {Sub1, OfferPOSUid} =
	case Sub of
	    "postpaid" -> {"postpaid",commercial_segment(postpaid)};
	    "dme"      -> {"entreprise",commercial_segment(dme)};
	    "cmo"      -> {"prepaid",commercial_segment(cmo)};
	    "mobi"      -> {"prepaid",commercial_segment(mobi)};
	    _          -> exit({spider_default_response, wrong_subscription, Sub})
	end,

    Msisdn1 =
	case Msisdn of
	    "+33"++M -> "0"++M;
	    _        -> Msisdn
	end,

    fake_xml_resp(Msisdn1, Imsi, Sub1, OfferPOSUid,[], "a300", DCL).


%% +type spider_error_response(string(), string(), string(), integer())
%%   -> spider_response().

spider_error_response(Imsi, Msisdn, Sub, ErrCode, DCL) ->
    Sub1 =
	case Sub of
	    "postpaid" -> "postpaid";
	    "dme"      -> "entreprise";
	    "mobi"     -> "prepaid";
	    _          -> exit(
			    {spider_error_response, wrong_subscription, Sub})
	end,
    Msisdn1 =
	case Msisdn of
	    "+33"++M -> "0"++M;
	    _        -> Msisdn
	end,
    
    fake_xml_resp(Msisdn1, Imsi, Sub1, "",[], "a3"++ErrCode, DCL).				    
    
online()->
    ["OK"].
run()->
    ["OK"].

commercial_segment(postpaid) ->
    "";
commercial_segment(dme) ->
    "";
commercial_segment(mobi) ->
    "MOB";
commercial_segment(cmo) ->
    "CMO";
commercial_segment(_) ->
    "".
