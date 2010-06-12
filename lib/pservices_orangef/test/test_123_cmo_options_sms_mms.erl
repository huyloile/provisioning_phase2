-module(test_123_cmo_options_sms_mms).

-export([online/0,
         pages/0,
         parent/1,
         links/1]).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/recharge_cb_cmo_new.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(Uid, cmo_user).

-define(MSG_PROMO_SMS_MMS, "").

-define(Opt_SMS_MMS, [sms_30,
   		      sms_80,
   		      sms_130,
                      sms_illimite_18E,
		      opt_orange_messenger]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?messenger_page, ?messenger_page_suite].

parent(?messenger_page) ->
    test_123_cmo_Homepage;
parent(?messenger_page_suite) ->
    ?MODULE.

links(?messenger_page) ->
    [{sms_30,    static},
     {sms_80,    static},
     {sms_130,   static},
     {?messenger_page_suite, static}];

links(?messenger_page_suite) ->
    [{sms_illimite_18E,static},
     {opt_orange_messenger, static}].


so_code(Opt) ->
    case Opt of
	opt_orange_messenger -> "OMWL7";
	_  -> "NOACT"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop(),
    ok.

test()->
    test_util_of:init_day_hour_range() ++
	test_options_sms_mms([
  			      ?ppola%% ,
%%  			      ?m6_cmo_fb_1h,
%%   			      ?DCLNUM_CMO_SL_ZAP_1h30_ILL,
%%   			      ?cmo_smart_40min,
%%   			      ?cmo_smart_1h,
%%   			      ?cmo_smart_1h30,
%% 			      ?cmo_smart_2h
			     ]) ++
    [].

test_options_sms_mms([]) -> ["Test reussi"];
test_options_sms_mms([DCL|T]) ->
    init(?Uid, DCL)++
	[{title, "Test Options SMS MMS - DCL = " ++ integer_to_list(DCL)}] ++
   	test_menu_sms_mms()++
	subscribe_Opt_SMS_MMS(?Opt_SMS_MMS) ++
  	sms_mms_mention_legales(?Opt_SMS_MMS)++
 	opt_SMS_MMS_subscribed([opt_orange_messenger])++
   	subscribe_SMS_MMS_incomp()++

  	test_options_sms_mms(T) ++
	[].


test_menu_sms_mms()->
    [{title, "Test MENU SMS/MMS "}]++
	asmserv_init(?Uid, "NOACT")++
	[
	 {ussd2,
	  [
	   {send, test_util_of:access_code(parent(?messenger_page), ?messenger_page)++"#"},
	   {expect,"Options SMS/MMS.*" ++ ?MSG_PROMO_SMS_MMS ++ "1:30 SMS/30MMS a 3E.*2:80 SMS/80MMS a 7,5E.*3:130 SMS/130 MMS a 12E.*4:Suite.*"},
	   {send, "4"},
	   {expect, ".*1:SMS/MMS illimites.*2:Orange Messenger.*"}
	  ]}
	]++
	close_session()++
	[].

subscribe_Opt_SMS_MMS([]) -> [];
subscribe_Opt_SMS_MMS([Media |T]) ->
    [{title, "SUBSCRIPTION SUCCESSFUL "++atom_to_list(Media)}]++
	asmserv_init(?Uid, "NOACT")++
	[
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE, Media)++"*1*1#"},
	   {expect, ".*1:Suite.*"},
	   {send, "1"},
	   {expect, "Votre option sera debitee de votre compte mobile puis de votre forfait si le compte mobile est epuise."}]}
	]++
	close_session()++
	subscribe_Opt_SMS_MMS(T)++
	[].

opt_SMS_MMS_subscribed([]) -> [];
opt_SMS_MMS_subscribed([Media |T]) ->
    [{title, "ALREADY SUBSCRIBED "++atom_to_list(Media)}]++
        asmserv_init(?Uid, so_code(Media))++
        [
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE, Media)++"*1*1#"},
           {expect, "Souscription.*Vous souscrivez deja a.* Les options SMS&MMS ne sont pas cumulables."}
	  ]}
        ]++
        close_session()++
        opt_SMS_MMS_subscribed(T)++
        [].


subscribe_SMS_MMS_incomp()->
    [{title, "Activation d'option CMO: Test Options SMS"}]++
	asmserv_init(?Uid, "FGT25")++
	["SOUSCRIPTION SMS 3E, OPTION A 25E/300 SMS ACTIVE",
	 {ussd2,
	  [
	   {send, test_util_of:access_code(parent(?messenger_page), ?messenger_page)++"#"},
	   {expect,"Options SMS/MMS.*" ++ ?MSG_PROMO_SMS_MMS ++ "1:30 SMS/30MMS a 3E.*2:80 SMS/80MMS a 7,5E.*3:130 SMS/130 MMS a 12E.*4:Suite.*"},
	   {send, test_util_of:link_rank(?MODULE, ?messenger_page, sms_30)},
	   {expect,".*1:Souscrire.*7:Conditions.*"},
	   {send,"1"},
	   {expect,".*Vous allez souscrire .* l'option 30 SMS/30 MMS utilisables.*1:Valider.*"},
	   {send,"1"},
	   {expect,".*Vous avez souscrit.*30 SMS"}
	  ]}
	]++
	close_session()++

	asmserv_init(?Uid, "FGX30")++
	["SOUSCRIPTION SMS 7,5E, OPTION 30 SMS ACTIVE",
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE, sms_80)++"#"},
	   {expect,"80 SMS/80MMS a 7,5E.*1:Souscrire.*7:Conditions.*"},
	   {send,"1"},
	   {expect,".*Vous allez souscrire .* l'option 80 SMS/80 MMS utilisables.*1:Valider.*"},
	   {send,"1"},
	   {expect,".*Vous avez souscrit.*80 SMS"}
	  ]}
	]++
	close_session()++
	asmserv_init(?Uid, "FGX80")++
	["SOUSCRIPTION SMS 12E, OPTION 80 SMS ACTIVE",
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE, sms_130)++"#"},
	   {expect,"130 SMS/130 MMS a 12E.*1:Souscrire.*7:Conditions.*"},
	   {send,"1"},
	   {expect,".*Vous allez souscrire .* l'option 130 SMS/130 MMS utilisables.*1:Valider.*"},
	   {send,"1"},
	   {expect,".*Vous avez souscrit.*130 SMS"}
	  ]}
	]++
	close_session()++

	asmserv_init(?Uid, "FGX30")++
	["SOUSCRIPTION SMS ILLIMITE 18E, OPTION A 3E/30SMS ACTIVE",
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE, sms_illimite_18E)++"#"},
	   {expect,"SMS/MMS illimites.*1:Souscrire.*7:Conditions.*"},
	   {send,"1"},
	   {expect,".*Vous allez souscrire .* l'option SMS/MMS illimites 24h/24 utilisables.*1:Valider.*"},
	   {send,"1"},
	   {expect,".*Vous avez souscrit.*SMS/MMS illimites"}
	  ]}
	]++
	close_session()++

	asmserv_init(?Uid, "FGX80")++
	["SOUSCRIPTION SMS 7,5E, OPTION DEJA ACTIVE",
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE, sms_80)++"#"},
	   {expect,".*Vous souscrivez deja a.*Les options SMS&MMS ne sont pas cumulables."}
	  ]}
	]++
	close_session()++

	[].

sms_mms_mention_legales([]) -> [];
sms_mms_mention_legales([opt_orange_messenger|T]) ->
    [{title, "Test mentions legales for "++atom_to_list(opt_orange_messenger)}]++
	asmserv_init(?Uid, "NOACT")++
	[
	 {ussd2,
	  [
	   {send, test_util_of:access_code(?MODULE, opt_orange_messenger)},
	   {expect, ".*7:Conditions.*"},
	   {send, "7"},
	   {expect,"Option valable en France metropolitaine, donnant acces au service de messagerie instantanee Orange Messenger by Windows Live..*1:Suite"},
            {send, "1"},
            {expect,"Envoi illimite de messages metropolitains et de fichiers photo \\(format peg ou gif\\) depuis un mobile compatible.*1:Suite"},
            {send, "1"},
            {expect,"en France metrop a compter de la reception du SMS de confirmation de souscription.Souscription de l'option au #123# \\(appel gratuit\\).*1:Suite"},
            {send, "1"},
            {expect,"ou sur internet www.orange.fr > espace client, sur l'espace client wap, en PDV France telecom ou service clients."}
	  ]}
	]++
	close_session()++
	sms_mms_mention_legales(T)++
	[];

sms_mms_mention_legales([Media |T]) ->
    [{title, "Test mentions legales for "++atom_to_list(Media)}]++
	asmserv_init(?Uid, "NOACT")++
	[
	 {ussd2,
	  [ 
	    {send, test_util_of:access_code(?MODULE, Media)},
	    {expect, ".*7:Conditions.*"},
	    {send, "7"},
	    {expect, "Options SMS/MMS indiquees en equivalent de SMS ou MMS en France metrop, hors SMS/MMS surtaxes numero courts et MMS carte postale"},
	    {send, "1"},
	    {expect, "Les SMS/MMS non utilises ne sont pas reportes sur le mois suivant. Les options ne sont pas cumulables"}
	   ]}
	]++
	close_session()++
	sms_mms_mention_legales(T)++
	[].

asmserv_init(Uid, Code_so) ->
    profile_manager:set_asm_profile(Uid,#asm_profile{code_so=Code_so}).

close_session() ->
    test_util_of:close_session().
init(Uid, DCL)->
    profile_manager:create_default(Uid,"cmo")++
    profile_manager:set_dcl(Uid,DCL)++
    profile_manager:init(Uid).
