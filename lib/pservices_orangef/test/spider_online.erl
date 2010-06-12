-module(spider_online).
-compile(export_all).

-include("profile_manager.hrl").

request(ResourceType, ResourceRef)->
    Spider=
	case ResourceType of
	    "MSISDN"->
		Msisdn=ResourceRef,
		Msisdn1=
		    case Msisdn of
			"0"++Rest->"+33"++Rest;
			_->Msisdn
		    end,
		Uid=profile_manager:get_uid({msisdn,Msisdn1}),
		profile_manager:retrieve_(Uid,"spider");
	    "IMSI" ->
		Imsi=ResourceRef,
		Uid=profile_manager:get_uid({imsi,Imsi}),
		profile_manager:retrieve_(Uid,"spider")
	end,
    slog:event(trace,?MODULE,{resourceRef,spider_data},{ResourceRef,Spider}),
    case Spider of 
	#spider{}->
	    XMERL_FORM=spider_xmerl(Spider),
	    XML=lists:flatten(xmerl:export_simple(XMERL_FORM, xmerl_xml)),
	    Resp=soaplight:decode_body(XML,spider);
	_->Spider
    end.


%%default_spider/8
default_spider(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, BUNDLETYPE, ERRORS, DCL)->
    Status=#spider_status{statusCode=ERRORS},
    Profile=#spider_profile{
      custImsi=IMSI,
      custMsisdn=MSISDN,
      offerPOrSUid=OFFERPORUID,
      offerType=BILLINGTOOL,
      amounts=AMOUNTS,
      frSpecificPrepaidOfferValue= DCL},
    Bundles=[#spider_bundle{priorityType="A",
			    restitutionType="FORF",
			    bundleType=BUNDLETYPE,
			    bundleDescription="label forf",
			    credits=[#spider_credit{name="balance",unit="TEMPS",value="3h34min11s"},
				     #spider_credit{name="balance",unit="SMS",value="45"}]
			   }],
    #spider{status=Status,
	    profile=Profile,
	    bundles=Bundles}.

%%default_spider/9
default_spider(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, BUNDLETYPE, ERRORS, DCL, CONFIG) ->
    #spider{status=Status,
	    profile=Profile,
	    bundles=Bundles}=
	default_spider(MSISDN, IMSI, BILLINGTOOL, OFFERPORUID, AMOUNTS, BUNDLETYPE, ERRORS, DCL),
    Credit1=#spider_credit{name="balance",unit="TEMPS",value="3h34min11s"},
    Credit2=#spider_credit{name="balance",unit="SMS",value="45"},
    Credit3=#spider_credit{name="rollOver",unit="SMS",value="45"},
    Credit4=#spider_credit{name="balance",unit="TEMPS",value="1000min00s"},
    Credits = 
	case lists:member(actif, CONFIG) of
	    true -> [Credit1,Credit2];
	    _ -> []
	end,
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="PTF",
			   bundleType=BUNDLETYPE,
			   bundleDescription="label forf",
			   credits=Credits},

    BundleD=#spider_bundle{priorityType="D",
			   restitutionType="LCONSO",
			   reinitDate="50",
			   bundleDescription="mobi_niv1",
			   credits=[Credit3]},


    Bundles1 = 
	case lists:member(suivi_conso_plus, CONFIG) of
	    true ->  
		[BundleA, BundleD];
	    _ -> [BundleA]
	end,	    
    #spider{status=Status,
	    profile=Profile,
	    bundles=Bundles1}.


build_spider(IMSI, SUB, DCL) ->
    MSISDN=msisdn_by_imsi(IMSI),
    build_spider(MSISDN, IMSI, SUB, DCL).

build_spider(MSISDN, IMSI, Sub, DCL) when atom(Sub)->
    build_spider(MSISDN, IMSI, atom_to_list(Sub), DCL);

build_spider(MSISDN, IMSI, Sub, DCL) ->
    {BILLINGTOOL, OfferPOSUid, BundleType} =
	case Sub of
	    "postpaid" -> {"postpaid","3G","0005"};
	    "dme"      -> {"entreprise","","0005"};
	    "opim"      -> {"entreprise","","0027"};
	    "enterprise"-> {"entreprise","","0027"};
	    "cmo"      -> {"prepaid","CMO","0005"};
	    "mobi"     -> {"prepaid","MOB","0005"};
	    _          -> exit({spider_default_response, wrong_subscription, Sub})
	end,
   	default_spider(MSISDN, IMSI, BILLINGTOOL, OfferPOSUid, [], BundleType, "a300", DCL).

build_spider(MSISDN, IMSI, Sub, DCL, Config) when atom(Sub)->
    build_spider(MSISDN, IMSI, atom_to_list(Sub), DCL, Config);

build_spider(MSISDN, IMSI, Sub, DCL, Config) when atom(Config)->
    build_spider(MSISDN, IMSI, Sub, DCL, [Config]);

build_spider(MSISDN, IMSI, Sub, DCL, [pas_reponse])->
    XMERL = timeout;

build_spider(MSISDN, IMSI, Sub, DCL, CONFIG)->
    {BILLINGTOOL, OfferPOSUid, BundleType} =
	case Sub of
	   	 	"postpaid" -> {"postpaid","3G","0005"};
	   	 	"dme"      -> {"entreprise","","0005"};
	   	 	"opim"      -> {"entreprise","","0027"};
	   	 	"cmo"      -> {"prepaid","CMO","0005"};
	   	 	"mobi"     -> {"prepaid","MOB","0005"};
	    _          -> exit({spider_default_response, wrong_subscription, Sub})
	end,
    default_spider(MSISDN, IMSI, BILLINGTOOL, OfferPOSUid, [], BundleType, "a300", DCL, CONFIG).



%% +type spider_error_response(string(), string(), string(), integer())
%%   -> spider_response().

spider_error_response(Imsi, Msisdn, Sub, DCL, ErrCode) ->
    {BILLINGTOOL,BundleType}=
	case Sub of
            "postpaid" -> {"postpaid","0005"};
            "dme"      -> {"entreprise","0005"};
            "opim"      -> {"entreprise","0027"};
            "mobi"     -> {"prepaid","0005"};
            "cmo"     -> {"prepaid","0005"};
	    _          -> exit({spider_error_response, wrong_subscription, Sub})
	end,
    default_spider(Msisdn, Imsi, BILLINGTOOL, "",[], BundleType, "a3"++ErrCode, DCL).				    

bundle(Bundle=#spider_bundle{})->
    Credits=Bundle#spider_bundle.credits,
    CRs=credits(Credits),
    New_Bundle=Bundle#spider_bundle{credits=CRs},
    Fields=record_info(fields,spider_bundle),
    oma_util:record_to_pairs(Fields,New_Bundle).

credit(Credit=#spider_credit{})->
    Fields=record_info(fields,spider_credit),
    oma_util:record_to_pairs(Fields,Credit).

status(Status=#spider_status{})->
    Fields=record_info(fields,spider_status),
    Pairs=oma_util:record_to_pairs(Fields,Status),
	[{status,[],Pairs}].

profile(Profile=#spider_profile{})->
    Fields=record_info(fields,spider_profile),
    oma_util:record_to_pairs(Fields,Profile).

credits([])->[];
credits([Credit|T]) when record(Credit,spider_credit)->
    CR=credit(Credit),
    [{credit,CR}]++credits(T).

bundles([])->[];
bundles([Bundle|T]) when record(Bundle,spider_bundle)->
    BD=bundle(Bundle),
	[{bundle,[],BD}]++bundles(T).

spider_xmerl(#spider{status=Status,
		     profile=Profile,
		     bundles=Bundles})
  when record(Status,spider_status), 
       record(Profile,spider_profile)->
		[{getBalanceResponse,[],
			[{statusList,[],status(Status)},
			 {file,[],profile(Profile)},
			 {bundles,[],bundles(Bundles)}]}].

msisdn_by_imsi(Imsi)->
    Last=right:right(Imsi,3),
    "+33900000"++Last.
