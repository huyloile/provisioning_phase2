-module(test_123_postpaid_suivi_conso).
-export([run/0, online/0, pages/0, parent/1, links/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").
-define(Uid,postpaid_suiviconso_user).

-define(BR,".*").
-define(Suivi_conso,
        "Au "?BR
        "label forf:40MMS"?BR
        "Jsq .* inclus"?BR
        "Hors forfait:2.50 EUR"?BR
        "Solde : 2.00EUR a utiliser jusqu'au .* inclus"?BR
        "Repondre.*1:Menu.2:Suivi conso+.*3:Aide").
-define(Menu_suivi_conso_plus,
        "1:Suivi conso detaille"?BR
        "2:Suivi conso options"?BR
        "3:Gerer mes options").

-define(SO_CODES, [
		   "OSP21" %% Option Sport
		  ]).

pages()->
    [?postpaid_suivi_conso_plus].

parent(?postpaid_suivi_conso_plus)->
    test_123_postpaid_Homepage.
links(?postpaid_suivi_conso_plus)->
    [{?postpaid_suivi_conso_detaille, static},
     {?postpaid_suivi_conso_option, static},
     {?postpaid_gerer_mes_option, static}];
links(Else) ->
    io:format("~p : links of this page ~p are not defined~n",[?MODULE, Else]).   

asmserv_init(Uid, Code_so)->profile_manager:set_asm_profile(Uid, #asm_profile{code_so=Code_so}).

run() ->
    "#123*2*2" = test_util_of:access_code(?MODULE,?postpaid_suivi_conso_option, ?postpaid_suivi_conso_plus),
    ok.

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test() ->
    test_util_of:set_present_period_for_test(commercial_date_postpaid,[m5])++
	test_util_of:set_parameter_for_test(offres_eXclusives, true) ++
	test_util_of:set_present_period_for_test(commercial_date_postpaid,[opt_ow,
									   opt_forf_sms,
									   m5,
									   opt_pass_vacances]) ++    
	profile_manager:create_default(?Uid,"postpaid")++
	test_postpaid("GP") ++
	test_postpaid("PRO") ++

	test_util_of:set_parameter_for_test(offres_eXclusives, true) ++
	[].

test_postpaid(Type) ->
    Amounts=
	[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	 {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],

	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	profile_manager:update_spider(?Uid,profile,{offerPOrSUid,Type})++
	profile_manager:init(?Uid)++

	asmserv_init(?Uid, "NOACT")++
	[{title, "TEST POSPAID - SUIVI CONSO - "++ Type}]++

	%%Menu Bons plans  - POSTPAID
 	test_suivi_conso(Type)++
 	test_restit_LIB_solde_not_available(Type)++
 	test_restit_LIB_solde_ac(Type)++
 	test_restit_LIB_solde_ep(Type)++
	test_gerer_mes_options(Type, ?SO_CODES)++
	test_util_of:close_session()++
	[].


option_label(SO_code) ->
    case SO_code of
	"OSP21" ->
	    "Option Sport";
	_  ->
	    ""
    end.

test_suivi_conso(Type)->
    profile_manager:set_bundles(?Uid,[bundleA("1"),bundleB("1"),bundleC("1"),
				      bundleA("2"),bundleB("2"),bundleC("2")
				     ])++

    [{title, "Test Suivi conso detaille with godet C "++Type},
     {ussd2,
      [
       {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_detaille, ?postpaid_suivi_conso_plus)},
       {expect,"Au .*label forf : 40MMS"},
       {send,"1"},
       {expect,".*"},
       {send,"1"},
       {expect,".*"},
       {send,"1"},
       {expect,"jusqu'au .* inclus"}
      ]}]++
  	[{title, "Test suivi conso option with godet C "++Type},
  	 {ussd2,
  	  [
	   {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_option, ?postpaid_suivi_conso_plus)},
  	   {expect,".*"},
  	   {send,"1"},
  	   {expect,".*"},
  	   {send,"1"},
  	   {expect,"jusqu'au .* inclus"},
  	   {send,"9"},
  	   {expect,?Suivi_conso}
  	  ]}]++
   	[{title, "Test gerer mes option case no option subscribed "++Type},
   	 {ussd2,
   	  [
	   {send, test_util_of:access_code(?MODULE,?postpaid_gerer_mes_option, ?postpaid_suivi_conso_plus)},
   	   {expect,"Gerer mes options.*Vous n'avez souscrit a aucune option pour le moment.*"
   	    "De nombreuses options sont disponibles dans l'offre Orange.*"
   	    "1:SMS/MMS.*"
   	    "2:Multimedia.*"},
   	   {send,"1"},
   	   {expect,"Options SMS/MMS.*"}
   	  ]}]++
	test_without_godetC(Type)++
	[].

test_without_godetC(Type) ->
    profile_manager:set_bundles(?Uid,[bundleA("1"),bundleB("1")])++
	asmserv_init(?Uid, "NOACT")++
  	[{title, "Test suivi conso detaille without godet C "++Type},
  	 {ussd2,
  	  [
	   {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_detaille, ?postpaid_suivi_conso_plus)},
  	   {expect,"inclus....Retour"}
  	  ]}]++

        [{title, "Test suivi conso options without godet C "++Type},
         {ussd2,
          [
	   {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_option, ?postpaid_suivi_conso_plus)},
           {expect,"Suivi conso options.*Vous n'avez souscrit a aucune option pour le moment.*De nombreuses options sont disponibles dans l'offre Orange."},
	   {send, "1"},
	   {expect, "1:Option 30 SMS/MMS.*"},
	   {send, "1"},
           {expect, "Option 30 SMS/MMS.*30 SMS/30 MMS  utilisables en SMS ou MMS  pour 3E seulement par mois.*1:Souscrire"}
          ]}]++
        [].

test_gerer_mes_options(_, []) ->
    [];
test_gerer_mes_options(Type, [SO_code|T]) ->
    profile_manager:set_bundles(?Uid,[bundleA("1"),bundleB("1"),bundleC("1"),
				      bundleA("2"),bundleB("2"),bundleC("2")
				     ])++

    profile_manager:set_asm_profile(?Uid, #asm_profile{code_so=SO_code}) ++
    [{title, "Test gerer mes option with option "++option_label(SO_code)++" subscribed "++Type},
     {ussd2,
      [
       {send, test_util_of:access_code(?MODULE,?postpaid_gerer_mes_option, ?postpaid_suivi_conso_plus)},
       {expect,"Gerer mes options.*Vous pouvez modifier chaque option.*"},
       {send,"1"},
       {expect,"1:Souscrire une autre option de la gamme.*"
	"2:Supprimer cette option.*"},
       {send,"2"},
       {expect, "Etes-vous sur de vouloir supprimer votre .*Vous perdrez le benefice de celle-ci."},
       {send,"1"},
       {expect,"Votre demande a bien ete prise en compte. Vous recevrez sous 48 heures un SMS vous informant de la suppression de votre option"},
       {send, "1"},
       {expect, ".*"}
      ]}]++
	test_util_of:close_session()++
        test_gerer_mes_options(Type, T)++
	[].

test_restit_LIB_solde_not_available(Type) ->
    BundleC=#spider_bundle{
      priorityType="C",
      restitutionType="LIB",
      bundleType="0005",
      bundleDescription="Internet Max|Vous disposez de l'option Internet Max active avant le$$date ",
      exhaustedLabel="Internet Max|Votre option Internet Max est suspendue ou ",
      bundleAdditionalInfo="||si a cette date vous disposez de 9E sur votre compte",
      bundleLevel="1",
      credits=[]
     },
    profile_manager:set_bundles(?Uid,[bundleA("1"),bundleB("1"),BundleC])++
	asmserv_init(?Uid, "NOACT")++
	[{title, "Test Suivi conso detaille with restitutionType=LIB - Solde not available - "++Type},
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_detaille, ?postpaid_suivi_conso_plus)},
	   {expect,"Au .*label forf : 40MMS"},
	   {send,"1"},
	   {expect,"Vous disposez de l'option Internet Max active avant le .* inclus.*"}
	  ]}].

test_restit_LIB_solde_ac(Type) ->
    BundleC=#spider_bundle{
      priorityType="C",
      restitutionType="LIB",
      bundleType="0005",
      bundleDescription="Internet Max|Vous disposez de l'option Internet Max active avant le$$date ",
      exhaustedLabel="Internet Max|Votre option Internet Max est suspendue ou ",
      bundleAdditionalInfo="||si a cette date vous disposez de 9E sur votre compte",
      bundleLevel="1",
      credits=[#spider_credit{name="balance",unit="SMS",value="10"},
	       #spider_credit{name="rollOver",unit="SMS",value="5"}]
     },
    profile_manager:set_bundles(?Uid,[bundleA("1"),bundleB("1"),BundleC])++
	asmserv_init(?Uid, "NOACT")++
        [{title, "Test Suivi conso detaille with restitutionType=LIB - Solde > 0 - "++Type},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_detaille, ?postpaid_suivi_conso_plus)},
           {expect,"Au .*label forf : 40MMS"},
           {send,"1"},
           {expect,"Vous disposez de l'option Internet Max active avant le .* inclus.*"}
          ]}].

test_restit_LIB_solde_ep(Type) ->
    BundleC=#spider_bundle{
      priorityType="C",
      restitutionType="LIB",
      bundleType="0005",
      bundleDescription="Internet Max|Vous disposez de l'option Internet Max active avant le$$date ",
      exhaustedLabel="Internet Max|Votre option Internet Max est suspendue ou ",
      bundleAdditionalInfo="||si a cette date vous disposez de 9E sur votre compte",
      bundleLevel="1",
      credits=[#spider_credit{name="balance",unit="SMS",value="0"}]
     },
    profile_manager:set_bundles(?Uid,[bundleA("1"),bundleB("1"),BundleC])++
        [{title, "Test Suivi conso detaille with restitutionType=LIB - Solde = 0 - "++Type},
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE,?postpaid_suivi_conso_detaille, ?postpaid_suivi_conso_plus)},
           {expect,"Au .*label forf : 40MMS"},
           {send,"1"},
           {expect,"Votre option Internet Max est suspendue ou si a cette date vous disposez de 9E sur votre compte"}
          ]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bundleA(BundleLebel)->
    #spider_bundle{
	 priorityType="A",
	 restitutionType="FORF",
	 bundleType="0005",
	 bundleDescription="label forf",
	 bundleAdditionalInfo="I1",
	 bundleLevel=BundleLebel,
	 credits=[#spider_credit{name="balance",unit="MMS",value="40"}]
	}.
bundleB(BundleLebel)->
    #spider_bundle{
	 priorityType="B",
	 restitutionType="SOLDE",
	 bundleType="1",
	 bundleDescription="Solde",
	 exhaustedLabel="Solde",
	 bundleLevel=BundleLebel,
	 credits=[#spider_credit{name="balance",unit="VALEU",value="2"}]
	}.
bundleC(BundleLebel)->
    #spider_bundle{
	 priorityType="C",
	 restitutionType="SOLDE",
	 bundleType="0005",
	 bundleDescription="TITREC|C_LIB filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling",
	 bundleLevel=BundleLebel,
	 credits=[#spider_credit{name="balance",unit="SMS",value="10"},
		  #spider_credit{name="rollOver",unit="SMS",value="5"}]
	}.
