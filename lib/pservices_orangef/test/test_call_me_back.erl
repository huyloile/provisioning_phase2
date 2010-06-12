-module(test_call_me_back).
-export([run/0, online/0,switch_interface_status/2]).

-export([sms_queue_init/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../include/cmb.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(USSD_COMMAND_START, "#122*").
-define(VLRN,"38900000000"). %%Macédoine
-define(ORANGE_CLIENT,"612345670").
-define(ORANGE_CLIENT_LONG,"+33612345670").
-define(NON_ORANGE_CLIENT,"612345678").
-define(NON_ORANGE_CLIENT_LONG,"+33612345678").
-define(ORANGE_CLIENT1,"712345670").
-define(ORANGE_CLIENT_LONG1,"+33712345670").
-define(NON_ORANGE_CLIENT1,"712345678").
-define(NON_ORANGE_CLIENT_LONG1,"+33712345678").
-define(NUM_END,"12345678").
-define(FORMAT_1,"0").
-define(FORMAT_2,"33").
-define(FORMAT_3,"0033").
-define(FORMAT_INV_1,"").
-define(FORMAT_INV_2,"+").
-define(FORMAT_INV_3,"+33").
-define(ONE_WEEK,7*24*60*60).
%% format donnant accès à svc_profile dans sachem_cmo_fake
%% 999000901YYYYYY
-define(IMSI_CMO,"999000901222222"). 
-define(MSISDN_CMO,"+99901222222").
-define(MSISDN_CMO_SMS,"0901222222").
-define(IMEI_DEF_CMO,"012345XXXXXXX1").
%% format donnant accès à svc_profile dans sachem_fake
%% 999000900YYYYYY
-define(IMSI_MOBI,"999000900111111"). 
-define(MSISDN_MOBI,"+99900111111").
-define(MSISDN_MOBI_SMS,"0900111111").
-define(IMEI_DEF_MOBI,"123456XXXXXXX1").

%%symacom 
-define(IMSI_SYMACOM,"999000905000001").
-define(MSISDN_SYMACOM,"+99905000001").
-define(MSISDN_SYMACOM_SMS,"0905000001").
-define(IMEI_DEF_SYMACOM,"100008XXXXXXX1").
%% other
-define(imsi_post,"208010902000001").
-define(imsi_dme, "208010903000001").
-define(imsi_vi,  "208010904000001").
-define(imsi_omer,  "208010905000001").
-define(imsi_bzh_gp,  "208010906000001").

-define(OK_NIV1,"Votre correspondant va etre prevenu.*1:Recharger").
-define(OK_NIV1_SYMACOM,"Un SMS lui.*Rechargez.*144#").
-define(OK_NIV2_3,"Un SMS lui.*Rechargez.*#123#").
-define(OK_NIV2_3_SYMACOM,"Un SMS lui.*Rechargez.*144#").
-define(NOK_NIV1_2,"Le service est temporairement indisponible.*Veuillez").
-define(NOK_NIV3,"Le service est temporairement indisponible.\$").
-define(NOK_ROAMER,"Ce service n'est pas disponible a l'etranger. Merci").
-define(NOK_DECL,"Vous n'avez pas acces a ce service").
-define(NOK_FORMAT,"Veuillez reformuler votre demande.*"
	"#122\\*numero_du_destinataire#").
-define(NOK_NUM,"Ce service ne fonctionne que vers les no Mobiles. Merci").
-define(NOK_BALANCE_MOBI1_2,"Vous n'avez pas acces au service : "
	"votre solde est superieur a 1 EUR").
-define(NOK_BALANCE_MOBI3,"Vous n'avez pas acces au service car votre "
	"solde est > a 1EUR").
-define(NOK_DATE_MOBI1_2,"La semaine de validite du service est depassee. "
	"Il sera a nouveau accessible le mois prochain").
-define(NOK_DATE_MOBI3,"La semaine de validite du service est depassee").
-define(NOK_COUNT_MOBI1_2,"Vous avez utilise tous vos messages pour ce "
	"mois-ci. Pour appeler a nouveau rechargez votre compte sur le "
	"#123#").
-define(NOK_COUNT_MOBI3,"Vous avez utilise tous vos messages").

-define(NOK_BALANCE_CMO1_2,?NOK_BALANCE_MOBI1_2).
-define(NOK_BALANCE_CMO3,?NOK_BALANCE_MOBI3).
-define(NOK_DATE_CMO1_2,?NOK_DATE_MOBI1_2).
-define(NOK_DATE_CMO3,?NOK_DATE_MOBI3).
-define(NOK_COUNT_CMO1_2,?NOK_COUNT_MOBI1_2).
-define(NOK_COUNT_CMO3,?NOK_COUNT_MOBI3).

-define(NOK_BALANCE_SYMACOM1_2,?NOK_BALANCE_MOBI1_2).
-define(NOK_BALANCE_SYMACOM3,?NOK_BALANCE_MOBI3).
-define(NOK_DATE_SYMACOM1_2,?NOK_DATE_MOBI1_2).
-define(NOK_DATE_SYMACOM3,?NOK_DATE_MOBI3).
-define(NOK_COUNT_SYMACOM1_2,"Vous avez utilise tous vos messages. "
	"Pour appeler a nouveau rechargez votre compte sur le "
	"\\*144#").
-define(NOK_COUNT_SYMACOM3,?NOK_COUNT_MOBI3).

-define(EXPECTEDSMS,
	[
  	 %% roamer filter
	 {sms_mo,{"Roamer Filter 1",?MSISDN_MOBI,?NON_ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mo,{"Roamer Filter 2",?MSISDN_CMO,?NON_ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 %% sub_decl_filter
	 {sms_mt,{"Filter Sub 1",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 2",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 3",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 4",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 5",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 6",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 7",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 8",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 9",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 10",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 11",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 12",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 13",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Filter Sub 14",?MSISDN_SYMACOM,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_SYMACOM_SMS++".*vous joindre et souhaiterait"}},
	 %% format_filter
	 {sms_mo,{"Format Filter 1",?MSISDN_MOBI,?NON_ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mo,{"Format Filter 2",?MSISDN_MOBI,?NON_ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mo,{"Format Filter 3",?MSISDN_MOBI,?NON_ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mo,{"Format Filter 4",?MSISDN_SYMACOM,?NON_ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_SYMACOM_SMS++".*vous joindre et souhaiterait"}},
	 %% count_filter
	 {sms_mt,{"Count Filter 1",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Count Filter 2",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Count Filter 3",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Count Filter 4",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Count Filter 5",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Count Filter 6",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Count Filter 7",?MSISDN_SYMACOM,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_SYMACOM_SMS++".*vous joindre et souhaiterait"}},
	 %% date_reset
	 {sms_mt,{"Date Reset 1",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Date Reset 2",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"Date Reset 3",?MSISDN_SYMACOM,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_SYMACOM_SMS++".*vous joindre et souhaiterait"}},
	 %% end_message
	 {sms_mt,{"End Msg 1",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"End Msg 2",?MSISDN_MOBI,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_MOBI_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"End Msg 3",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"End Msg 4",?MSISDN_CMO,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_CMO_SMS++".*vous joindre et souhaiterait"}},
	 {sms_mt,{"End Msg 5",?MSISDN_SYMACOM,?ORANGE_CLIENT_LONG,
		  "\\"++?MSISDN_SYMACOM_SMS++".*vous joindre et souhaiterait"}}
	]).

-record(cpte_test,{imsi,sub,dcl,balance=0,d_der_rec=0,level=1,rnv=10}).

online() ->
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,call_me_back()).
  %  sms_stop_client(QueuePid).

switch_interface_status(Name, Status) ->
    OldEnv = application_controller:prep_config_change(),
    {value, {pfront,PfrontOldConfig}} = lists:keysearch(pfront,1,OldEnv),
    {value, {interfaces,OldInterfaces}} = 
	lists:keysearch(interfaces, 1, PfrontOldConfig),
    {value, OldInterface} =
	lists:keysearch({Name,possum@localhost},4,OldInterfaces),
    NewInterface = OldInterface#interface{admin_state=Status},
    %% This is needed because we don't really update application parameters...
    RealOldInterface = case Status of
			   disabled ->
			       OldInterface#interface{admin_state=enabled};
			   enabled ->
			       OldInterface#interface{admin_state=disabled}
		       end,
    NewInterfaces = lists:keyreplace({Name,possum@localhost},4,
				     OldInterfaces,NewInterface),
    RealOldInterfaces = lists:keyreplace({Name,possum@localhost},4,
					 OldInterfaces,RealOldInterface),
    pfront_sup:interfaces_changed(RealOldInterfaces,NewInterfaces).

call_me_back() ->

    %%Test title
    [{title, "Test suite for Call Me Back."}] ++

	%%Connection to the USSD simulator (smpp because of roaming)
	[test_util_of:connect(smpp)] ++
	sms_start_client() ++
    	switch(enabled,httpclient_ocfrdp) ++
   	switch(enabled,io_sms_smpp_datasm ) ++

    	reset_svc_profiles() ++
     	init_db() ++
	check_date_der_rec()++
   	roamer_filter() ++
       	dest_msisdn_in_black_list() ++
	symacom_dest_msisdn_in_black_list() ++
 	sub_decl_filter() ++
 	reset_svc_profiles()++
	refill_link()++
      	format_filter() ++
	mobile_num_filter() ++
	symacom_num_filter() ++
	balance_filter() ++
	count_filter() ++
%	THIS TEST FAILED
% 	date_filter() ++
 	end_message()++
      	reset_svc_profiles() ++
     	test_util_of:set_imei(?IMSI_MOBI,?IMEI_DEF_MOBI) ++
     	test_util_of:set_imei(?IMSI_CMO,?IMEI_DEF_CMO) ++
     	test_util_of:set_imei(?IMSI_SYMACOM,?IMEI_DEF_SYMACOM) ++
	[].

check_date_der_rec()->
    test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	["- SYMACOM "] ++
        set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),0,pbutil:unixtime()) ++
        ["Check case date_der_rec = 0 Num count = 0"]++
        init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=0}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1_SYMACOM)++
        set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),1,pbutil:unixtime()) ++
        ["Check case date_der_rec = 0 Num count = 1"]++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_COUNT_SYMACOM1_2)++
        set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),1,pbutil:unixtime()-100) ++
        init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()}) ++
        ["Check case date_der_rec > last_cmb Num count = 1"]++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1_SYMACOM)++
	
	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),0,pbutil:unixtime()) ++
        ["Check case date_der_rec = 0 Num count = 0"]++
        init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=0}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?OK_NIV1_SYMACOM)++
        set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),1,pbutil:unixtime()) ++
        ["Check case date_der_rec = 0 Num count = 1"]++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?NOK_COUNT_SYMACOM1_2)++
        set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),1,pbutil:unixtime()-100) ++
        init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()}) ++
        ["Check case date_der_rec > last_cmb Num count = 1"]++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?OK_NIV1_SYMACOM)
.

dest_msisdn_in_black_list() ->
    DestMsisdn = "612354678",
    BlackListName = rpc_call(pbutil, get_env, 
			     [pservices_orangef,call_me_back_black_list_name]),
    erlang_rpc_call(acl, add, [BlackListName, "0"++DestMsisdn, ""]) ++
	test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
 	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++

	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_1,DestMsisdn,"Desole, votre correspondant ne souhaite pas recevoir de message du service Orange-Appelle moi, merci de votre comprehension") ++

	erlang_rpc_call(acl, delete, [BlackListName, "0"++DestMsisdn]) ++

	[].

symacom_dest_msisdn_in_black_list() ->
    DestMsisdn = "712354678",
    BlackListName = rpc_call(pbutil, get_env, 
			     [pservices_orangef,call_me_back_black_list_name]),
    erlang_rpc_call(acl, add, [BlackListName, "0"++DestMsisdn, ""]) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_1,DestMsisdn,"Desole, votre correspondant ne souhaite pas recevoir de message du service Orange-Appelle moi, merci de votre comprehension") ++

	erlang_rpc_call(acl, delete, [BlackListName, "0"++DestMsisdn]) ++

	[].

roamer_filter() ->
    test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?mobi,balance=0,d_der_rec=pbutil:unixtime()}) ++
%%	THIS TEST FAILED
%% 	["Modify the Lang in the profiles lang=fr",
%% 	 "we use the page lang configuration",
%% 	 {ussd2,
%% 	  [ {send, "#128*999952#"},
%% 	    {expect, "en francais*"}	
%% 	   ]}] ++
	%% set imsi, close session, langue = français, create account, tell ocf
	["do a normal successful MOBI session :"
	 "- destinataire Non Orange,"
	 "- format 1" ] ++
	cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT,?OK_NIV1) ++
	["do same session, but roaming"] ++
	init_roamer_session(?VLRN,1) ++
	cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT,?NOK_ROAMER) ++
	init_roamer_session(undefined,1) ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime()}) ++
%%	THIS TEST FAILED
%% 	["Modify the Lang in the profiles lang=fr",
%% 	 "we use the page lang configuration",
%% 	 {ussd2,
%% 	  [ {send, "#128*999952#"},
%% 	    {expect, "en francais*"}	
%% 	   ]}] ++
	%% set imsi, close session, langue = français, create account, tell ocf
	["do a normal successful CMO session :"
	 "- destinataire Non Orange,"
	 "- format 1" ] ++
	cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT,?OK_NIV1) ++
	["do same session, but roaming"] ++
	init_roamer_session(?VLRN,1) ++
	cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT,?NOK_ROAMER) ++
	init_roamer_session(undefined,1) ++

	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?mobi,balance=0,d_der_rec=pbutil:unixtime()}) ++
	["do a normal successful MOBI session :"
         "- destinataire Non Orange,"
         "- format 1" ] ++
        cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT1,?OK_NIV1) ++
        ["do same session, but roaming"] ++
        init_roamer_session(?VLRN,1) ++
        cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT1,?NOK_ROAMER) ++
        init_roamer_session(undefined,1) ++
        init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	["do a normal successful CMO session :"
         "- destinataire Non Orange,"
         "- format 1" ] ++
        cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT1,?OK_NIV1) ++
        ["do same session, but roaming"] ++
        init_roamer_session(?VLRN,1) ++
        cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT1,?NOK_ROAMER) ++
        init_roamer_session(undefined,1)
	.

sub_decl_filter() ->
    sub_decl_filter_int(?IMSI_MOBI,"mobi",?mobi,ok) ++
	sub_decl_filter_int(?IMSI_MOBI,"mobi",?cpdeg,ok) ++
	sub_decl_filter_int_symacom(?IMSI_SYMACOM,"symacom",?decl_symacom,ok)++
	sub_decl_filter_int(?IMSI_CMO,"cmo",?ppol3,ok) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?ppolc,ok) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?ppol1,ok) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?ppol2,ok) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?ppol4,ok) ++
	sub_decl_filter_int(?IMSI_CMO,"cmo",?fmu_18,ok) ++
	sub_decl_filter_int(?IMSI_CMO,"cmo",?fmu_24,ok) ++
	sub_decl_filter_int(?IMSI_CMO,"cmo",?cmo_sl,ok) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?m6_cmo,ok) ++ 
	reset_svc_profiles()++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?m6_cmo2,ok) ++ %% Max CMB reached
	set_svc_profiles(?IMSI_CMO,pbutil:unixtime(),?CMO_MAX_CMB-2,
			 pbutil:unixtime()) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?m6_cmo3,ok) ++
 	sub_decl_filter_int(?IMSI_CMO,"cmo",?m6_cmo4,ok) ++
	sub_decl_filter_int(?IMSI_CMO,"cmo",?ppola,nok) ++
	sub_decl_filter_int(?IMSI_CMO,"omer",?omer,nok) ++
	sub_decl_filter_int1(?imsi_post,"postpaid") ++
	sub_decl_filter_int1(?imsi_dme,"dme") ++
	sub_decl_filter_int1(?imsi_vi,"postpaid") ++
	sub_decl_filter_int1(?imsi_bzh_gp,"bzh_gp") ++
	sub_decl_filter_int1(?imsi_vi,"anon").

sub_decl_filter_int_symacom(Imsi,SUB,Decl,ok) ->
    ["Accept "++SUB++", decl : "++ integer_to_list(Decl)] ++
	init(#cpte_test{imsi=Imsi,sub=SUB,dcl=Decl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	%% set imsi, close session, langue = français, create account, tell ocf
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1_SYMACOM) ++
	
	init(#cpte_test{imsi=Imsi,sub=SUB,dcl=Decl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?OK_NIV1_SYMACOM).

sub_decl_filter_int(Imsi,SUB,Decl,ok) ->
    ["Accept "++SUB++", decl : "++ integer_to_list(Decl)] ++
	init(#cpte_test{imsi=Imsi,sub=SUB,dcl=Decl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	%% set imsi, close session, langue = français, create account, tell ocf
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1) ++
	
	init(#cpte_test{imsi=Imsi,sub=SUB,dcl=Decl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?OK_NIV1);

sub_decl_filter_int(Imsi,SUB,Decl,nok) ->
    ["Refuse "++SUB++", decl : "++ integer_to_list(Decl)] ++
	init(#cpte_test{imsi=Imsi,sub=SUB,dcl=Decl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	%% set imsi, close session, langue = français, create account, tell ocf
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_DECL) ++

	init(#cpte_test{imsi=Imsi,sub=SUB,dcl=Decl,balance=0,d_der_rec=pbutil:unixtime()}) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?NOK_DECL).

sub_decl_filter_int1(Imsi,SUB) ->
    ["Refuse "++SUB] ++
	init(Imsi,1) ++
	new_client(Imsi,SUB) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_DECL) ++

	init(Imsi,1) ++
        new_client(Imsi,SUB) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?NOK_DECL).

format_filter() ->
    ["MOBI, accept Format1"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT,?OK_NIV1) ++
	["MOBI, accept Format2"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_2,?NON_ORANGE_CLIENT,?OK_NIV1) ++
	["MOBI, accept Format3"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_3,?NON_ORANGE_CLIENT,?OK_NIV1) ++
	["MOBI, refuse Format invalide 1"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_INV_1,?NON_ORANGE_CLIENT,?NOK_FORMAT) ++
	["MOBI, refuse Format invalide 2"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_INV_2,?NON_ORANGE_CLIENT,?NOK_FORMAT) ++
	["MOBI, refuse Format invalide 3"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_INV_3,?NON_ORANGE_CLIENT,?NOK_FORMAT) ++
	
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
        cmb_session(?FORMAT_1,?NON_ORANGE_CLIENT1,?OK_NIV1) ++
        ["MOBI, accept Format2"] ++
        init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
        cmb_session(?FORMAT_2,?NON_ORANGE_CLIENT1,?OK_NIV1) ++
        ["MOBI, accept Format3"] ++
        init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
        cmb_session(?FORMAT_3,?NON_ORANGE_CLIENT1,?OK_NIV1) ++
        ["MOBI, refuse Format invalide 1"] ++
        init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
        cmb_session(?FORMAT_INV_1,?NON_ORANGE_CLIENT1,?NOK_FORMAT) ++
        ["MOBI, refuse Format invalide 2"] ++
        init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
        cmb_session(?FORMAT_INV_2,?NON_ORANGE_CLIENT1,?NOK_FORMAT) ++
        ["MOBI, refuse Format invalide 3"] ++
        init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
        cmb_session(?FORMAT_INV_3,?NON_ORANGE_CLIENT1,?NOK_FORMAT).


mobile_num_filter() ->
    mobile_num_filter_nok("0") ++
    mobile_num_filter_nok("1") ++
    mobile_num_filter_nok("2") ++
    mobile_num_filter_nok("3") ++
    mobile_num_filter_nok("4") ++
    mobile_num_filter_nok("5") ++
    %% 7 now accepted (PC Nov 2008)
    mobile_num_filter_nok("9").

mobile_num_filter_nok(Pre) ->
    ["MOBI, Format1, non mobile "++Pre] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,level=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_1,Pre++?NUM_END,?NOK_NUM).
symacom_num_filter() ->
    symacom_num_filter_nok("0") ++
    symacom_num_filter_nok("1") ++
    symacom_num_filter_nok("2") ++
    symacom_num_filter_nok("3") ++
    symacom_num_filter_nok("4") ++
    symacom_num_filter_nok("5") ++
    symacom_num_filter_nok("8") ++
    symacom_num_filter_nok("9").

symacom_num_filter_nok(Pre)->
    ["SYMACOM, Format1, non mobile "++Pre] ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,level=0,d_der_rec=pbutil:unixtime()}) ++ 
	cmb_session(?FORMAT_1,Pre++?NUM_END,?NOK_NUM).

balance_filter() ->
    ["Balance filter niv 1"] ++
	test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	balance_filter(?NOK_BALANCE_MOBI1_2,?NOK_BALANCE_CMO1_2,?NOK_BALANCE_SYMACOM1_2,1) ++
	["Balance filter niv 2"] ++
	test_util_of:change_navigation_to_niv2(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv2(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv2(?IMSI_SYMACOM) ++
	balance_filter(?NOK_BALANCE_MOBI1_2,?NOK_BALANCE_CMO1_2,?NOK_BALANCE_SYMACOM1_2,2) %++
%%	THIS TEST FAILED
%% 	["Balance filter niv 3"] ++
%% 	test_util_of:change_navigation_to_niv3(?IMSI_MOBI) ++
%% 	test_util_of:change_navigation_to_niv3(?IMSI_CMO) ++
%% 	test_util_of:change_navigation_to_niv3(?IMSI_SYMACOM) ++
%% 	balance_filter(?NOK_BALANCE_MOBI3,?NOK_BALANCE_CMO3,?NOK_BALANCE_SYMACOM3,3)
	.

balance_filter(NokMobi,NokCmo,NokSymacom,Level) ->
    ["- MOBI"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=1001,d_der_rec=pbutil:unixtime(),level=Level}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokMobi) ++
	["- CMO"] ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=1001,d_der_rec=pbutil:unixtime(),level=Level}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokCmo)++
	["- SYMACOM"] ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=1001,d_der_rec=pbutil:unixtime(),level=Level}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokSymacom) ++

	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=1001,d_der_rec=pbutil:unixtime(),level=Level}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,NokMobi) ++
        ["- CMO"] ++
        init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=1001,d_der_rec=pbutil:unixtime(),level=Level}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,NokCmo)++
        ["- SYMACOM"] ++
        init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=1001,d_der_rec=pbutil:unixtime(),level=Level}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,NokSymacom)
.

count_filter() ->
    ["Count filter niv 1"] ++
	test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	count_filter_int(?OK_NIV1,?NOK_COUNT_MOBI1_2,?NOK_COUNT_CMO1_2,?NOK_COUNT_SYMACOM1_2,1) ++
	["Count filter niv 2"] ++
	test_util_of:change_navigation_to_niv2(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv2(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv2(?IMSI_SYMACOM) ++
	count_filter_int(?OK_NIV2_3,?NOK_COUNT_MOBI1_2,?NOK_COUNT_CMO1_2,?NOK_COUNT_SYMACOM1_2,2) %++
%%	THIS TEST FAILED
%% 	["Count filter niv 3"] ++
%% 	test_util_of:change_navigation_to_niv3(?IMSI_MOBI) ++
%% 	test_util_of:change_navigation_to_niv3(?IMSI_CMO) ++
%% 	test_util_of:change_navigation_to_niv3(?IMSI_SYMACOM) ++
%% 	count_filter_int(?OK_NIV2_3,?NOK_COUNT_MOBI3,?NOK_COUNT_CMO3,?NOK_COUNT_SYMACOM3,3)
	.

count_filter_int(Ok,NokMobi,NokCmo,NokSymacom,Level) ->
    ["- MOBI"] ++
	set_svc_profiles(?IMSI_MOBI,pbutil:unixtime(),?MOBI_MAX_CMB-1,pbutil:unixtime()) ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,Ok) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokMobi) ++
	["- CMO"] ++
	set_svc_profiles(?IMSI_CMO,pbutil:unixtime(),?CMO_MAX_CMB-1,pbutil:unixtime()) ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,Ok) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokCmo)++
	["- SYMACOM"] ++
	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),?SYMACOM_MAX_CMB-1,pbutil:unixtime()) ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}) ++ 
	%cmb_session(?FORMAT_1,?ORANGE_CLIENT,Ok) ++	
	case Ok of
	    ?OK_NIV2_3 ->
		cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3_SYMACOM);
	    _ ->
		cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1_SYMACOM)
	end
    ++ cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokSymacom) ++
	
	set_svc_profiles(?IMSI_MOBI,pbutil:unixtime(),?MOBI_MAX_CMB-1,pbutil:unixtime()) ++
        init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,Ok) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,NokMobi) ++
        ["- CMO"] ++
        set_svc_profiles(?IMSI_CMO,pbutil:unixtime(),?CMO_MAX_CMB-1,pbutil:unixtime()) ++
        init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,Ok) ++
        cmb_session(?FORMAT_1,?ORANGE_CLIENT1,NokCmo)++
        ["- SYMACOM"] ++
        set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),?SYMACOM_MAX_CMB-1,pbutil:unixtime()) ++
        init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}) ++
        case Ok of
            ?OK_NIV2_3 ->
                cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?OK_NIV2_3_SYMACOM);
            _ ->
                cmb_session(?FORMAT_1,?ORANGE_CLIENT1,?OK_NIV1_SYMACOM)
        end
    ++ cmb_session(?FORMAT_1,?ORANGE_CLIENT1,NokSymacom)
.

date_filter() ->
    set_svc_profiles(?IMSI_MOBI,pbutil:unixtime() - ?ONE_WEEK - 60,1,pbutil:unixtime()) ++
	set_svc_profiles(?IMSI_CMO,pbutil:unixtime() - ?ONE_WEEK - 60,1,pbutil:unixtime()) ++
	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime() - ?ONE_WEEK - 60,1,pbutil:unixtime()) ++
	["Date filter niv 1"] ++
	test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	date_filter_int(?NOK_DATE_MOBI1_2,?NOK_DATE_CMO1_2,?NOK_COUNT_SYMACOM1_2,1) ++
	["Date filter niv 2"] ++
	test_util_of:change_navigation_to_niv2(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv2(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv2(?IMSI_SYMACOM) ++
	date_filter_int(?NOK_DATE_MOBI1_2,?NOK_DATE_CMO1_2,?NOK_COUNT_SYMACOM1_2,2) ++
	["Date filter niv 3"] ++
	test_util_of:change_navigation_to_niv3(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv3(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv3(?IMSI_SYMACOM) ++
	date_filter_int(?NOK_DATE_MOBI3,?NOK_DATE_CMO3,?NOK_COUNT_SYMACOM3,3) ++
	date_reset().

date_filter_int(NokMobi,NokCmo,NokSymacom,Level) ->
    ["- MOBI"] ++
	%% Stored Date 1 week 1 min. old
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,
			d_der_rec=pbutil:unixtime()-?ONE_WEEK-120,level=Level}) ++ 
	%% Date_Der_Rec 1 week 2 min. old
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokMobi) ++
	["- CMO"] ++
	%% Stored Date 1 week 1 min. old
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,
			d_der_rec=pbutil:unixtime()-?ONE_WEEK-120,level=Level}) ++ 
	%% Date_Der_Rec 1 week 2 min. old
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokCmo) ++
	["- SYMACOM"] ++
	%% Stored Date 1 week 1 min. old
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,
			d_der_rec=pbutil:unixtime()-?ONE_WEEK-120,level=Level}) ++ 
	%% Date_Der_Rec 1 week 2 min. old
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,NokSymacom)
.

date_reset() ->
    ["Date reset"] ++
	test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	["- MOBI, reset date (date dernier CMB<Date dernier rechargement)"] ++
	set_svc_profiles(?IMSI_MOBI,pbutil:unixtime()-60,?MOBI_MAX_CMB,pbutil:unixtime()-60) ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++ 
	%% Stored Date older than date_der_rec, should be reseted
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1) ++
	["- MOBI, don't reset date (date premier CMB+1 semaine>Date dernier rechargement)"] ++
	set_svc_profiles(?IMSI_MOBI,pbutil:unixtime()-60,?MOBI_MAX_CMB,pbutil:unixtime()-1) ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=0}) ++ 
	%% default value for date_der_rec, client has never "recharger"d
	%% should not reset
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_COUNT_MOBI1_2) ++
	["- CMO, reset date(date dernier CMB Aujourd'hui(D/M/Y)-31J < 01/M/YY < Aujourd'hui"] ++
	set_svc_profiles(?IMSI_CMO,pbutil:unixtime()-31*24*3600,?CMO_MAX_CMB,pbutil:unixtime()-31*24*3600) ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=0,rnv=1}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1) ++
	["- CMO, no reset date(date du jour > date historise plus 1 semaine"] ++
	set_svc_profiles(?IMSI_CMO,pbutil:unixtime()-60,?CMO_MAX_CMB,pbutil:unixtime()) ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=0}) ++ 
	%% default value for date_der_rec, client has never "recharger"d
	%% should not reset
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_COUNT_CMO1_2) ++

	["- SYMACOM, reset date(date dernier CMB Aujourd'hui(D/M/Y)-31J < 01/M/YY < Aujourd'hui"] ++
	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime()-31*24*3600,?SYMACOM_MAX_CMB,pbutil:unixtime()-31*24*3600) ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=0,rnv=1}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV1_SYMACOM) ++
	["- SYMACOM, no reset date(date du jour > date historise plus 1 semaine"] ++
	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime()-60,?SYMACOM_MAX_CMB,pbutil:unixtime()) ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=0}) ++ 
	%% default value for date_der_rec, client has never "recharger"d
	%% should not reset
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_COUNT_SYMACOM1_2) ++

	reset_svc_profiles().

end_message() ->
    %% OK niv 1 already tested
    ["MOBI, Format1, Niv 2"] ++
	test_util_of:change_navigation_to_niv2(?IMSI_MOBI) ++
 	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime(),level=3}) ++ 
 	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3) ++
 	["MOBI, Format1, Niv 3"] ++
 	test_util_of:change_navigation_to_niv3(?IMSI_MOBI) ++
 	new_client(?IMSI_MOBI,"mobi",3) ++
 	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3) ++
 	["CMO, Format1, Niv 2"] ++
 	test_util_of:change_navigation_to_niv2(?IMSI_CMO) ++
 	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime(),level=2}) ++ 
 	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3) ++
 	["CMO, Format1, Niv 3"] ++
 	test_util_of:change_navigation_to_niv3(?IMSI_CMO) ++
 	new_client(?IMSI_CMO,"cmo",3) ++
 	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3) ++

 	["SYMACOM, Format1, Niv 2"] ++
 	test_util_of:change_navigation_to_niv2(?IMSI_SYMACOM) ++
 	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime(),level=2}) ++ 
 	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3_SYMACOM) ++
 	["SYMACOM, Format1, Niv 3"] ++
	symacom_reset(3) ++
 	test_util_of:change_navigation_to_niv3(?IMSI_SYMACOM) ++
 	new_client(?IMSI_SYMACOM,"symacom",3) ++
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?OK_NIV2_3_SYMACOM) ++
% 	switch(disabled,httpclient_ocfrdp) ++
% 	switch(disabled,io_sms_smpp_datasm) ++
%  	test_nok() ++
	switch(enabled,httpclient_ocfrdp) ++
	switch(enabled,io_sms_smpp_datasm).


test_nok() ->
    set_svc_profiles(?IMSI_MOBI,pbutil:unixtime(),1,pbutil:unixtime()) ++
	set_svc_profiles(?IMSI_CMO,pbutil:unixtime(),1,pbutil:unixtime()) ++
	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),1,pbutil:unixtime()) ++
	test_util_of:change_navigation_to_niv1(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv1(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv1(?IMSI_SYMACOM) ++
	["- MOBI, Niv 1, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime(),level=1}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV1_2) ++
	["- CMO, Niv 1, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime(),level=1}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV1_2) ++
	["- SYMACOM, Niv 1, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime(),level=1}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV1_2) ++

	test_util_of:change_navigation_to_niv2(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv2(?IMSI_CMO) ++	
	test_util_of:change_navigation_to_niv2(?IMSI_SYMACOM) ++

	["- MOBI, Niv 2, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime(),level=2}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV1_2) ++
	["- CMO, Niv 2, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime(),level=2}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV1_2) ++
	["- SYMACOM, Niv 2, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime(),level=2}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV1_2) ++

	test_util_of:change_navigation_to_niv3(?IMSI_MOBI) ++
	test_util_of:change_navigation_to_niv3(?IMSI_CMO) ++
	test_util_of:change_navigation_to_niv3(?IMSI_SYMACOM) ++
	["- MOBI, Niv 3, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime(),level=3}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV3) ++
	["- CMO, Niv 3, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?cmo_sl,balance=0,d_der_rec=pbutil:unixtime(),level=3}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV3) ++
	["- SYMACOM, Niv 3, OCF down"] ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime(),level=3}) ++ 
	cmb_session(?FORMAT_1,?ORANGE_CLIENT,?NOK_NIV3).


refill_link() ->
    ["CMO : Link refill"]++
    init(#cpte_test{imsi=?IMSI_CMO,sub="cmo",dcl=?ppol3,balance=0,d_der_rec=pbutil:unixtime()}) ++
    [
     {ussd2,
      [ {send, ?USSD_COMMAND_START ++ ?FORMAT_1 ++ ?ORANGE_CLIENT ++ "#"},
	{expect,?OK_NIV1},
	{send,"1"},
	{expect,"Rechargement"}
       ]}]++
    ["Mobi : Link refill"]++
    init(#cpte_test{imsi=?IMSI_MOBI,sub="mobi",dcl=?cpdeg,balance=0,d_der_rec=pbutil:unixtime()}) ++
    [
     {ussd2,
      [ {send, ?USSD_COMMAND_START ++ ?FORMAT_1 ++ ?ORANGE_CLIENT ++ "#"},
	{expect,?OK_NIV1},
	{send,"1"},
	{expect,"Rechargement"}
       ]}].

switch(How,What) ->
    ["Switching " ++ atom_to_list(What) ++ " to " ++ atom_to_list(How),
     {erlang_no_trace,
      [ {net_adm, ping,[possum@localhost]},
	{rpc, call, [possum@localhost,code,
		     load_abs,
		     ["lib/pservices_orangef/test/test_call_me_back"]]},
	{rpc, call, [possum@localhost,test_call_me_back,
		     switch_interface_status,
		     [What,How]]}]
     },
     {pause, 5000}
    ].

cmb_session(FORMAT,Dest,Expect) ->
    [
     {ussd2,
      [ {send, ?USSD_COMMAND_START ++ FORMAT ++ Dest ++ "#"},
	{expect,Expect}
       ]}].

init(#cpte_test{imsi=IMSI,level=Level,sub=SUB}=CPTE_TEST) ->
    init(IMSI,Level) ++
	new_client(IMSI,SUB,Level) ++
	build_test_account(CPTE_TEST).

init(IMSI,Level) ->
    [
     "Set imsi="++IMSI,
     {msaddr, {subscriber_number, private, IMSI}}
    ] ++ 
	close_session(Level).


new_client(IMSI,SUB) ->
    new_client(IMSI,SUB,1).

new_client(IMSI,SUB,Level) ->
    [{erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[sub,{IMSI,SUB}]]},
       {rpc, call, [possum@localhost,ets,
		    insert,[ocf_test,{IMSI,#ocf_test{tac="012345",
						     ussd_level=Level,
						     sub=SUB}}]]}]}].
build_test_account(#cpte_test{imsi=Imsi,dcl=?cmo_sl,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV}) ->
    test_util_of:insert(
      Imsi, ?cmo_sl, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_CMOSL,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=DCL,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV}) 
  when DCL==?ppol4;DCL==?ppol3;DCL==?ppol1->
    test_util_of:insert(
      Imsi, DCL, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?pmu,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?pmu, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_PMU,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?ppol2,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?ppol2, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_VOIX,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?ppolc,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?ppolc, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_HC,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?fmu_18,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?fmu_18, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_FMU_18,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?fmu_24,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?fmu_24, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_FMU_24,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?bzh_cmo,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?bzh_cmo, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_BZH,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?zap_cmo,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?zap_cmo, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_VOIX_ZAP,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?m6_cmo,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?m6_cmo, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_MU_M6,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=?PM6_CMO_MIN3}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?m6_cmo2,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?m6_cmo2, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_MU_M6_V2,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=?PM6_CMO_MIN}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?m6_cmo3,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?m6_cmo3, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_MU_M6_V3,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=?PM6_CMO_MIN5}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=?m6_cmo4,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
    test_util_of:insert(
      Imsi, ?m6_cmo4, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_MU_M6_V4,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=?PM6_CMO_MIN6}
      ],
      [{d_der_rec,DateDerRec}]
     );
build_test_account(#cpte_test{imsi=Imsi,dcl=DCL,balance=Balance,
			      d_der_rec=DateDerRec,level=Level}) when DCL==?cpdeg;DCL==?mobi;
								      DCL==?ppola;DCL==?omer;DCL==?decl_symacom->
    test_util_of:insert(
      Imsi, DCL, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=Balance,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?MCLAS}],
      [{d_der_rec,DateDerRec}]
     ).

%% to test a roamer's session
init_roamer_session(VLRN,Level) ->
    close_session(Level) ++
	case VLRN of 
	    undefined -> [test_util_of:connect(smpp)];
	    _ -> [test_util_of:connect(smppasn)]
	end ++
	["Start a session with vlr number"] ++
	test_util_of:set_vlr(VLRN).

close_session(3) ->
    [
     "Ensure that the session is closed.",
     {ussd2, [ {send, "#128*133#"}, {expect, "Closing"} ]},
     {pause, 500}
    ];
close_session(_) ->
    test_util_of:close_session().

%% Profiles !

%% reset
reset_svc_profiles() ->
    ["Reset svcprofiles.",
     {shell,
      [ {send, "mysql -u possum -ppossum -B "
	 "-e \"DELETE FROM svcprofiles "
	 "WHERE svc='"++?SVC_NAME++"'\" mobi"},
	{send, "mysql -u possum -ppossum -B "
	 "-e \"SELECT COUNT(*) FROM svcprofiles "
	 "WHERE svc='"++?SVC_NAME++"'\" mobi"},
	{expect, "0"}
       ]}].

init_db() ->
     test_util_of:init_test({imsi,?IMSI_CMO},
 			   {subscription,"cmo"},
 			   {navigation_level,1},
 			   {msisdn,?MSISDN_CMO}) ++ 
	
 	test_util_of:init_test({imsi,?IMSI_MOBI},
 			       {subscription,"mobi"},
 			       {navigation_level,1},
 			       {msisdn,?MSISDN_MOBI}) ++
 	test_util_of:init_test({imsi,?IMSI_SYMACOM},
 			       {subscription,"symacom"},
 			       {navigation_level,1},
 			       {msisdn,?MSISDN_SYMACOM}) ++

 	test_util_of:init_test(?imsi_post,"postpaid") ++ 
 	test_util_of:init_test(?imsi_dme,"dme") ++ 
 	test_util_of:init_test(?imsi_vi,"anon") ++ 
 	test_util_of:init_test(?imsi_omer,"omer") ++ 
 	test_util_of:init_test(?imsi_bzh_gp,"bzh_gp") ++
	[].

%% works only if profile exists
set_svc_profiles(Imsi,Date,Num,Last_CMB) ->
    Data = #call_me_back{date=Date,num=Num,last_cmb=Last_CMB},
    DataHex = convert_utils:binary2hex(term_to_binary(Data)),
    Now = pbutil:unixtime(),
    
    Update = lists:flatten(io_lib:format(
			     "SELECT @u := uid FROM users WHERE imsi = '~s';"
			     "DELETE FROM svcprofiles where uid = @u AND svc='~s';"
			     "INSERT INTO svcprofiles VALUES (@u,'~s','~p','~p','~s')",
			     [Imsi,?SVC_NAME,?SVC_NAME,Now,Now,DataHex])),

    [io_lib:format("set svcprofiles with ~p, ~p.",[Date,Num]),
     {shell_no_trace,
      [ {send, "mysql -u possum -ppossum -B -vv "
	 "-e \""++Update++"\" mobi"},
	{expect, "1 row affected"}
       ]}].

%%%% Fun dealing with SMSs

%%% Starts a sms queue, defined as a client for smsloop_server
sms_start_client() ->
     [
       {title, "Connect SMSC (SMPP, DATA-SM)"},
       {erlang, [ {test_sms_mt, start_smpp_smsc,
  		 [fake_smsc_7434, "localhost", 7434, data_sm]} ]},
       %% Allow sms_router to discover the interfaces.
       {pause, 6000}].



%%% Register the queue as a smsloop_client
sms_queue_init(Parent) ->
    proc_lib:init_ack(self()),
    pong = net_adm:ping(possum@localhost), 
    ptester:start_interface(loop),
    sms_queue_loop(Parent,?EXPECTEDSMS).

%%% Main queue loop
sms_queue_loop(Parent,[{sms_mo,{Test,From,To,RegExp}=SMSMO} | SMSs]) ->
    receive 
	{fake_incoming_mo,
	 #sms_incoming{da      = To,
		       deliver = #sms_deliver{dcs = DCS,
					      oa  = From,
					      ud  = UD}}}=Data ->
	    Text = gsmcharset:ud2iso(DCS, UD),
	    case regexp:match(Text,RegExp) of
		{match,_,_} -> 
		    sms_queue_loop(Parent,SMSs);
		_ ->
		    exit({smsmo_badmatch,Text,RegExp})
	    end;

	{fake_incoming_mo,INC} -> 
	    exit({smsmo_unexpected,INC,instead_of,SMSMO});

	sms_stop -> Parent ! {error,{smsmo_still_awaiting,[SMSMO|SMSs]}}

    end;

sms_queue_loop(Parent,[{sms_mt,{Test,From,To,RegExp}=SMSMT} | SMSs]) ->
    receive 
	{fake_insert_sms,
	 #sms_insert{sa  = From,
		     submit = #sms_submit{da  = To,
					  dcs = DCS,
					  ud  = UD}}}=Data ->
	    Text = gsmcharset:ud2iso(DCS, UD),
	    case regexp:match(Text,RegExp) of
		{match,_,_} -> 
		    sms_queue_loop(Parent,SMSs);
		_ ->
		    exit({smsmo_badmatch,Text,RegExp})
	    end;

	{fake_insert_sms,INS} -> 
	    exit({smsmt_unexpected,INS,instead_of,SMSMT});

	sms_stop -> Parent ! {error,{smsmt_still_awaiting,[SMSMT|SMSs]}}

    end;

sms_queue_loop(Parent,[]) ->
    receive
	sms_stop -> Parent ! ok;
	{fake_incoming_mo,INC} ->
	    Parent ! {error,{smsmo_unexpected,INC}};
	{fake_insert_sms,INS} -> 
	    Parent ! {error,{smsmt_unexpected,INS}}
    end.

erlang_rpc_call(M, F, A) ->
    [{erlang, [{rpc, call, [possum@localhost, M, F, A]}]}].

rpc_call(M, F, A) ->
    rpc:call(possum@localhost, M, F, A).

symacom_reset(Level)->
    	set_svc_profiles(?IMSI_SYMACOM,pbutil:unixtime(),?SYMACOM_MAX_CMB-1,pbutil:unixtime()) ++
	init(#cpte_test{imsi=?IMSI_SYMACOM,sub="symacom",dcl=?decl_symacom,balance=0,d_der_rec=pbutil:unixtime()-100,level=Level}).
