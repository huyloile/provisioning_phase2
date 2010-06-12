-module(test_prov_selfcare_local).
-compile(export_all).

-export([run/0, online/0]).

-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../../pservices_orangef/include/ftmtlv.hrl").
-include("test_provisioning.hrl").
-include("profile_manager.hrl").


%% variables
-define(CODE,"#103*#").

-define(uid, selfcare_user).
-define(selfcare_user_imsi, "999000900000379").
-define(selfcare_user_msisdn, "+33900000379").
-define(wrongimsi, wrongimsi).
-define(user_wrongimsi, "2080109000000029").
-define(IMSIs_CONFIG,
	[{"208010000000001", "+33600000001", "000001XXXXXXX1"},
	 {"208010000000002", "+33600000002", "33219800000483"},
	 {"208010000000003", "+33600000003", "000001XXXXXXX1"},
	 {"208010000000004", "+33600000004", "000001XXXXXXX1"},
	 {"208010000000005", "+33600000005", "000001XXXXXXX1"},
	 {"208010000000006", "+33600000006", "000001XXXXXXX1"},
	 {"208010000000007", "+33600000007", "000001XXXXXXX1"},
	 {"208010000000008", "+33600000008", "000001XXXXXXX1"},
	 {"208010000000009", "+33600000009", "000001XXXXXXX1"},
	 {"208010000000010", "+33600000010", "000001XXXXXXX1"}
	].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,test()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initialize(Sub) -> 
    Default_profile = #test_profile{tac="012345", sub=atom_to_list(Sub)},
    initialize(?uid, Sub, Default_profile).

initialize(Uid, Sub) ->
    Default_profile = #test_profile{tac="012345", sub=atom_to_list(Sub)},
    initprofile(Uid, Sub, Default_profile).

initialize(Uid, Sub, Test_profile) ->
    [{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM users_orangef_extra\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM stats\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM svcprofiles\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM users\""}]}] ++
	initprofile(Uid, Sub, Test_profile) ++ 
	[].

initprofile(Sub) ->
    Default_profile = #test_profile{tac="012345", sub=atom_to_list(Sub)},
    initprofile(?uid, Sub, Default_profile).

initprofile(Uid, Sub, Test_profile) ->
    profile_manager:create_and_insert_default(Uid, Test_profile, false)++
	profile_manager:init(Uid)++

	%%Initialization of OMA configuration parameters
	test_util_of:set_parameter_for_test(access_services,
					    [{"#102",[all_and_anon]},
					     {"#103",[all_and_anon]},
					     {"#128",[all_and_anon]}]) ++
	test_util_of:set_parameter_for_test(level_database_by_service_code,
					    [{"#102",niveau1,?all_subscriptions},
					     {"#103",{niveau2,spider},?all_subscriptions},
					     {"#128",{niveau2,spider},?all_subscriptions}]) ++
	test_util_of:set_parameter_for_test(
	  pservices,
	  auth_by_sc_acl,
	  [{"#103",
	    "/orangef/test_self_prov.xml",
	    "test provisioning",
	    "/orangef/auth.xml#auth_preprod",
	    blacklist,
	    []},
	   {"#128",
	    "/test/index.xml",
	    "test en ligne",
	    "/system/home.xml#auth_preprod",
	    blacklist,
	    []}]) ++
	test_util_of:set_parameter_for_test(url_not_postpaid,
					    "file:/orangef/test_self_prov.xml#123_bzh_gp_130") ++
	test_util_of:set_parameter_for_test(spider_url_service_indisponible,
					    "file:/orangef/test_self_prov.xml#spider_service_indisponible") ++
	test_util_of:set_parameter_for_test(spider_url_acces_refuse,
					    "file:/orangef/test_self_prov.xml#spider_acces_refuse") ++
	test_util_of:set_parameter_for_test(spider_url_probleme_technique,
					    "file:/orangef/test_self_prov.xml#spider_probleme_technique") ++
	test_util_of:set_parameter_for_test(spider_url_dossier_inconnu,
					    "file:/orangef/test_self_prov.xml#spider_dossier_inconnu") ++
	test_util_of:set_parameter_for_test(store_commercial_segment, true)++
	[].

test() ->

    %%Test title
    [{title,"Test du provisioning"}] ++

	initialize(mobi) ++
	imei_not_set(mobi)++

	test_ocf_failed(mobi)++
 	test_api_write_to_file()++
	initialize(?wrongimsi, mobi) ++
	user_self_provisionning_check_imsi(mobi)++ 
	initialize(mobi) ++
	user_self_provisionning(mobi)++ 
	user_changing_msisdn(mobi)++ 
	user_reuse_msisdn(mobi)++        
	user_change_to(mobi,postpaid)++          
	user_change_to(mobi,cmo)++          
	user_change_to(mobi,dme)++   
	user_change_to(mobi,omer)++ 
	user_change_to(mobi,bzh_cmo)++ 
	user_spider_out_of_order(mobi,?DOSSIER_INCONNU)++ 

	initialize(cmo) ++
	user_self_provisionning(cmo) ++ 
	user_changing_msisdn(cmo) ++ 
	user_reuse_msisdn(cmo) ++        
	user_change_to(cmo,postpaid) ++       
	user_change_to(cmo,mobi) ++ 
	user_change_to(cmo,dme) ++ 
	user_change_to(cmo,omer) ++ 
	user_change_to(cmo,bzh_cmo) ++ 
	user_spider_out_of_order(cmo,?DOSSIER_INCONNU) ++   

	initialize(postpaid) ++
	user_self_provisionning(postpaid) ++ 
	user_changing_msisdn(postpaid)++ 
	user_reuse_msisdn(postpaid)++        
	user_change_to(postpaid,cmo) ++      
	user_change_to(postpaid,mobi) ++
	user_change_to(postpaid,dme) ++
	user_change_to(postpaid,omer) ++
	user_change_to(postpaid,bzh_cmo) ++
	user_spider_out_of_order(postpaid,?DOSSIER_INCONNU) ++
	user_spider_out_of_order(postpaid,?SERVICE_INDISPONIBLE) ++ 
	user_spider_out_of_order(postpaid,?ACCES_REFUSE) ++ 
	user_spider_out_of_order(postpaid,?PROBLEME_TECHNIQUE) ++ 

	initialize(dme) ++
	user_self_provisionning(dme) ++ 
	user_change_to(dme,cmo) ++      
	user_change_to(dme,mobi) ++
	user_change_to(dme,postpaid) ++
	user_change_to(dme,omer) ++
	user_change_to(dme,bzh_cmo) ++
	user_spider_out_of_order(dme,?DOSSIER_INCONNU) ++  

	initialize(opim) ++
	user_self_provisionning(opim) ++ 
	user_change_to(opim,cmo) ++      
	user_change_to(opim,mobi) ++
	user_change_to(opim,postpaid) ++
	user_change_to(opim,omer) ++
	user_change_to(opim,bzh_cmo) ++
	user_spider_out_of_order(opim,?DOSSIER_INCONNU) ++  

	initialize(anon) ++
	user_self_provisionning(anon) ++

	initialize(omer) ++
	user_self_provisionning(omer) ++ 
	user_changing_msisdn(omer) ++  
	user_reuse_msisdn(omer) ++     
	user_change_to(omer,cmo) ++      
	user_change_to(omer,mobi) ++
	user_change_to(omer,dme) ++
	user_change_to(omer,postpaid) ++
	user_change_to(omer,bzh_cmo) ++
	user_sachem_out_of_order(omer) ++

	initialize(symacom) ++
	user_self_provisionning(symacom) ++ 
	user_changing_msisdn(symacom) ++  
	user_reuse_msisdn(symacom) ++     
	user_change_to(symacom,cmo) ++      
	user_change_to(symacom,mobi) ++
	user_change_to(symacom,dme) ++
	user_change_to(symacom,postpaid) ++
	user_change_to(symacom,bzh_cmo) ++
	user_sachem_out_of_order(symacom) ++

	initialize(bzh_gp) ++
	user_self_provisionning(bzh_gp) ++ 
	user_reuse_msisdn(bzh_gp)++        

	initialize(bzh_cmo) ++
	user_self_provisionning(bzh_cmo) ++ 
	user_changing_msisdn(bzh_cmo) ++ 
	user_reuse_msisdn(bzh_cmo) ++  
	user_change_to(bzh_cmo,cmo) ++      
	user_change_to(bzh_cmo,mobi) ++
	user_change_to(bzh_cmo,dme) ++
	user_change_to(bzh_cmo,postpaid) ++
	user_change_to(bzh_cmo,omer) ++

	initialize(carrefour_prepaid) ++
	user_self_provisionning(carrefour_prepaid) ++ 
	user_changing_msisdn(carrefour_prepaid) ++  
	user_reuse_msisdn(carrefour_prepaid) ++     
	user_change_to(carrefour_prepaid,cmo) ++      
	user_change_to(carrefour_prepaid,mobi) ++
	user_change_to(carrefour_prepaid,dme) ++
	user_change_to(carrefour_prepaid,postpaid) ++
	user_change_to(carrefour_prepaid,bzh_cmo) ++
	user_sachem_out_of_order(carrefour_prepaid) ++

        initialize(carrefour_comptebloq) ++
        user_self_provisionning(carrefour_comptebloq) ++ 
        user_changing_msisdn(carrefour_comptebloq) ++  
        user_reuse_msisdn(carrefour_comptebloq) ++     
        user_change_to(carrefour_comptebloq,cmo) ++      
        user_change_to(carrefour_comptebloq,mobi) ++
        user_change_to(carrefour_comptebloq,dme) ++
        user_change_to(carrefour_comptebloq,postpaid) ++
        user_change_to(carrefour_comptebloq,bzh_cmo) ++
        user_sachem_out_of_order(carrefour_comptebloq) ++

        initialize(monacell_prepaid) ++
        user_self_provisionning(monacell_prepaid) ++ 
        user_changing_msisdn(monacell_prepaid) ++  
        user_reuse_msisdn(monacell_prepaid) ++     
        user_change_to(monacell_prepaid,cmo) ++      
        user_change_to(monacell_prepaid,mobi) ++
        user_change_to(monacell_prepaid,dme) ++
        user_change_to(monacell_prepaid,postpaid) ++
        user_change_to(monacell_prepaid,bzh_cmo) ++
        user_sachem_out_of_order(monacell_prepaid) ++

        initialize(monacell_comptebloqu) ++
        user_self_provisionning(monacell_comptebloqu) ++ 
        user_changing_msisdn(monacell_comptebloqu) ++  
        user_reuse_msisdn(monacell_comptebloqu) ++     
        user_change_to(monacell_comptebloqu,cmo) ++      
        user_change_to(monacell_comptebloqu,mobi) ++
        user_change_to(monacell_comptebloqu,dme) ++
        user_change_to(monacell_comptebloqu,postpaid) ++
        user_change_to(monacell_comptebloqu,bzh_cmo) ++
        user_sachem_out_of_order(monacell_comptebloqu) ++

        initialize(monacell_postpaid) ++
        user_self_provisionning(monacell_postpaid) ++ 
        user_reuse_msisdn(monacell_postpaid) ++     

        initialize(nrj_prepaid) ++
        user_self_provisionning(nrj_prepaid) ++ 
        user_changing_msisdn(nrj_prepaid) ++  
        user_reuse_msisdn(nrj_prepaid) ++     
        user_change_to(nrj_prepaid,cmo) ++      
        user_change_to(nrj_prepaid,mobi) ++
        user_change_to(nrj_prepaid,dme) ++
        user_change_to(nrj_prepaid,postpaid) ++
        user_change_to(nrj_prepaid,bzh_cmo) ++
        user_sachem_out_of_order(nrj_prepaid) ++

        initialize(nrj_comptebloque) ++
        user_self_provisionning(nrj_comptebloque) ++ 
        user_changing_msisdn(nrj_comptebloque) ++  
        user_reuse_msisdn(nrj_comptebloque) ++     
        user_change_to(nrj_comptebloque,cmo) ++      
        user_change_to(nrj_comptebloque,mobi) ++
        user_change_to(nrj_comptebloque,dme) ++
        user_change_to(nrj_comptebloque,postpaid) ++
        user_change_to(nrj_comptebloque,bzh_cmo) ++
        user_sachem_out_of_order(nrj_comptebloque) ++

        initialize(tele2_pp) ++
        user_self_provisionning(tele2_pp) ++ 
        user_changing_msisdn(tele2_pp) ++  
        user_reuse_msisdn(tele2_pp) ++     
        user_change_to(tele2_pp,cmo) ++      
        user_change_to(tele2_pp,mobi) ++
        user_change_to(tele2_pp,dme) ++
        user_change_to(tele2_pp,postpaid) ++
        user_change_to(tele2_pp,bzh_cmo) ++
        user_sachem_out_of_order(tele2_pp) ++

        initialize(tele2_comptebloque) ++
        user_self_provisionning(tele2_comptebloque) ++ 
        user_changing_msisdn(tele2_comptebloque) ++  
        user_reuse_msisdn(tele2_comptebloque) ++     
        user_change_to(tele2_comptebloque,cmo) ++      
        user_change_to(tele2_comptebloque,mobi) ++
        user_change_to(tele2_comptebloque,dme) ++
        user_change_to(tele2_comptebloque,postpaid) ++
        user_change_to(tele2_comptebloque,bzh_cmo) ++
        user_sachem_out_of_order(tele2_comptebloque) ++

        initialize(tele2_gp) ++
        user_self_provisionning(tele2_gp) ++ 
        user_reuse_msisdn(tele2_gp) ++     

        initialize(ten_comptebloque) ++
        user_self_provisionning(ten_comptebloque) ++ 
        user_changing_msisdn(ten_comptebloque) ++  
        user_reuse_msisdn(ten_comptebloque) ++     
        user_change_to(ten_comptebloque,cmo) ++      
        user_change_to(ten_comptebloque,mobi) ++
        user_change_to(ten_comptebloque,dme) ++
        user_change_to(ten_comptebloque,postpaid) ++
        user_change_to(ten_comptebloque,bzh_cmo) ++
        user_sachem_out_of_order(ten_comptebloque) ++

        initialize(ten_postpaid) ++
        user_self_provisionning(ten_postpaid) ++ 
        user_reuse_msisdn(ten_postpaid) ++     

        initialize(virgin_prepaid) ++
        user_self_provisionning(virgin_prepaid) ++ 
        user_changing_msisdn(virgin_prepaid) ++  
        user_reuse_msisdn(virgin_prepaid) ++     
        user_change_to(virgin_prepaid,cmo) ++      
        user_change_to(virgin_prepaid,mobi) ++
        user_change_to(virgin_prepaid,dme) ++
        user_change_to(virgin_prepaid,postpaid) ++
        user_change_to(virgin_prepaid,bzh_cmo) ++
        user_sachem_out_of_order(virgin_prepaid) ++

        initialize(virgin_comptebloque) ++
        user_self_provisionning(virgin_comptebloque) ++ 
        user_changing_msisdn(virgin_comptebloque) ++  
        user_reuse_msisdn(virgin_comptebloque) ++     
        user_change_to(virgin_comptebloque,cmo) ++      
        user_change_to(virgin_comptebloque,mobi) ++
        user_change_to(virgin_comptebloque,dme) ++
        user_change_to(virgin_comptebloque,postpaid) ++
        user_change_to(virgin_comptebloque,bzh_cmo) ++
        user_sachem_out_of_order(virgin_comptebloque) ++

        initialize(virgin_postpaid) ++
        user_self_provisionning(virgin_postpaid) ++ 
        user_reuse_msisdn(virgin_postpaid) ++     

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++

	[].


%% +type reset_local_db(atom()) -> test_service().
reset_local_db() ->
    ["Deleting profiles in local database",
     {shell_no_trace,
      [{send,
 	"mysql -u possum -ppossum mobi -Be "
 	"\"SELECT @u := uid FROM users WHERE imsi = '" ++ ?new_imsi ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""},
       {send,
	"mysql -u possum -ppossum mobi -Be "
 	"\"SELECT @u := uid FROM users WHERE msisdn = '" ++ ?new_msisdn ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""},
       {send,
 	"mysql -u possum -ppossum mobi -Be "
 	"\"SELECT @u := uid FROM users WHERE imsi = '" ++ ?selfcare_user_imsi ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""},
       {send,
	"mysql -u possum -ppossum mobi -Be "
	"\"SELECT @u := uid FROM users WHERE msisdn = '" ++ ?selfcare_user_msisdn ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""}
      ]}
    ].


%% +type do_self_provisioning(atom()) -> test_service().
do_self_provisioning(SUB) ->
    do_self_provisioning(SUB, atom_to_list(SUB)).

%% +type do_self_provisioning(atom(), string()) -> test_service().
%%%% ExpPage == "postpaid default", for instance.

do_self_provisioning(Sub, ExpPage) ->
    ["Connexion a Cellcube pour realisation du self provisionning.",
     {ussd2,
      [{send, ?CODE},
       {expect, ExpPage}
      ]}     
    ]++
	test_util_of:close_session().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type imei_not_set() 
imei_not_set(SUB) ->
    [{title,"PROCEDURE DE PROVISIONNING D'UN NOUVEAU CLIENT " ++ atom_to_list(SUB)}] ++
	reset_local_db() ++
	new_user(SUB)++
	["Changement du imei dans la base locale",
	 {shell,
	  [ {send, "mysql -u possum -ppossum -Bs -e \"UPDATE users "
	     "SET imei='""' WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"}
	   ]}
	]++
	do_self_provisioning(SUB)++
	["Verification du profil dans la base de donnees locale",
	 {shell,
	  [ {send, "mysql -u possum -ppossum -Bs -e \"SELECT msisdn,imsi,imei,subscription FROM users "
	     "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
	    {expect, rmplus(?selfcare_user_msisdn) ++ ".*" ++ ?selfcare_user_imsi ++ ".*012345.*" ++ atom_to_list(SUB)},
	    {send, "mysql -u possum -ppossum -Bs -e \"SELECT COUNT(*) FROM users "
	     "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
	    {expect, "1"},
	    {send, "mysql -u possum -ppossum -Bs -e \"SELECT COUNT(*) FROM users "
	     "WHERE msisdn='+" ++ rmplus(?selfcare_user_msisdn) ++ "'\" mobi"},
	    {expect, "1"},
	    {send, "mysql -u possum -ppossum -Bs -e \"SELECT COUNT(*) FROM users "
	     "WHERE msisdn='+" ++ rmplus(?new_msisdn) ++ "'\" mobi"},
	    {expect, "0"}
	   ]}     
	].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                                      %% Test invalid imsi.  
user_self_provisionning_check_imsi(SUB) ->    
    [{title,"PROCEDURE DE PROVISIONNING D'UN NOUVEAU CLIENT " ++ atom_to_list(SUB)}] ++
	["Check imsi error", 
	 {shell,
	  [{send,
	    "mysql -u possum -ppossum -Bs -e "
	    "\"SELECT COUNT(*) FROM users WHERE imsi = '" ++ ?user_wrongimsi ++ "'\" mobi" },
	   {expect, "1"}
	  ]}]++
	do_self_provisioning(SUB).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_self_provisionning() -> service_test().

user_self_provisionning(SUB) ->
    [{title,"PROCEDURE DE PROVISIONNING D'UN NOUVEAU CLIENT " ++ atom_to_list(SUB)}] ++
	reset_local_db() ++
	new_user(SUB).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type new_user(atom()) -> service_test().
commercial_segment(mobi)->
						%test_util_spider:commercial_segment(mobi);
    "";
commercial_segment(_)->
    "".
new_user(SUB) ->
    [{shell,count_by_imsi(?selfcare_user_imsi,"0")}] ++
	do_self_provisioning(SUB) ++
	["Verification du profil dans la base de donnees locale"] ++
	[{shell,
	  [{send, "mysql -u possum -ppossum -Bs -e \"SELECT msisdn,imsi,subscription FROM users "
	    "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
	   {expect,case SUB of
		       S1 when S1==postpaid;S1==dme;S1==anon ->
			   ?selfcare_user_imsi ++ ".*" ++ atom_to_list(SUB);
		       _ -> 
			   rmplus(?selfcare_user_msisdn) ++ ".*" ++ ?selfcare_user_imsi ++ ".*" ++ atom_to_list(SUB)
		   end}]}] ++
	[{shell,count_by_imsi(?selfcare_user_imsi,"1")}] ++
	[{shell,count_by_msisdn(?selfcare_user_msisdn,
				case SUB of 
				    anon -> "1"; %% 20090807: now that MSISDN is set in the initial USSD req, it ends up in the DB...
				    _ -> "1"
				end)}] ++
	check_commercial_segment(commercial_segment(SUB), SUB) ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_changing_msisdn() -> service_test().

user_changing_msisdn(SUB) ->
    [{title,"CHANGEMENT DE MSISDN D'UN CLIENT " ++ atom_to_list(SUB)}] ++
	reset_local_db() ++
	new_user(SUB) ++
	["Changement du msisdn dans la base locale",
	 {shell,
	  [ {send, "mysql -u possum -ppossum -Bs -e \"UPDATE users "
	     "SET msisdn='" ++ ?new_msisdn ++ "' WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"}
	   ]}
	]++
						% need two session
	do_self_provisioning(anon)++
	do_self_provisioning(SUB)++
	["Verification du profil dans la base de donnees locale",
	 {shell,
	  [ {send, "mysql -u possum -ppossum -Bs -e \"SELECT msisdn,imsi,subscription FROM users "
	     "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
	    {expect, rmplus(?selfcare_user_msisdn) ++ ".*" ++ ?selfcare_user_imsi ++ ".*" ++ atom_to_list(SUB)},
	    {send, "mysql -u possum -ppossum -Bs -e \"SELECT COUNT(*) FROM users "
	     "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
	    {expect, "1"},
	    {send, "mysql -u possum -ppossum -Bs -e \"SELECT COUNT(*) FROM users "
	     "WHERE msisdn='+" ++ rmplus(?selfcare_user_msisdn) ++ "'\" mobi"},
	    {expect, "1"},
	    {send, "mysql -u possum -ppossum -Bs -e \"SELECT COUNT(*) FROM users "
	     "WHERE msisdn='+" ++ rmplus(?new_msisdn) ++ "'\" mobi"},
	    {expect, "0"}
	   ]}     
	].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type mobicarte_user_reuse_msisdn() -> service_test().
user_reuse_msisdn(SUB) ->
    [{title,"REUTILISATION DU MSISDN PAR UN NOUVEAU CLIENT " ++ atom_to_list(SUB)}]++
	reset_local_db() ++
	new_user(SUB) ++
	["Changement de l'imsi dans la base locale",
	 {shell_no_trace,
	  [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
	     "SET imsi='" ++ ?new_imsi ++ "' WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"}
	   ]}
	] ++
	do_self_provisioning(SUB) ++
	["Verification du profil dans la base de donnees locale",
	 {shell,
	  lists:append([select_by_subscription(SUB),
			count_by_msisdn(?selfcare_user_msisdn,
					case SUB of
					    anon -> "1";%%If anon, do_self_provisionning() empties the database
					    _ ->"1" %%20090807: update to prevent doublons
					end)])
	 }     
	].

%% +type user_change_to(string()) -> service_test().
user_change_to(Origin,Target) ->
    [{title, "CLIENT " ++ atom_to_list(Origin) ++ " DEVIENT " ++ atom_to_list(Target)}] ++
	initialize(Origin) ++
	reset_local_db() ++
	new_user(Origin) ++
	initprofile(Target) ++
	[ "Connexion a Cellcube pour realisation du prov selfcare.",
	  {ussd2,
	   [ {send, ?CODE},
	     {expect, atom_to_list(Target)}
	    ]}
	 ]++
	[ " Verification du profil dans la base locale",
	  {shell_no_trace,
	   [ {send, "mysql -u possum -ppossum -B -e \"SELECT imsi,subscription FROM users "
	      "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
	     {expect, ?selfcare_user_imsi ++ ".*" ++ atom_to_list(Target)}
	    ]}
	 ] ++
	initprofile(Origin) ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_sachem_out_of_order() -> service_test().
user_sachem_out_of_order(SUB) ->
    [{title,
      "CONNEXION D'UN CLIENT " ++ atom_to_list(SUB) ++ " ALORS QUE SACHEM EST HS"
     }
    ] ++
	reset_local_db() ++
	new_user(SUB) ++
	profile_manager:set_sachem_response(?uid, {"csl_doscp", {nok,{callCsl_doscp_response_ko,exit}}})++
	["Connexion a Cellcube pour realisation du self provisionning.",
	 {ussd2,
	  [{send, ?CODE},
	   case lists:member(SUB, ?sachem_subscriptions) of
	       true -> 
		   {expect, "anon"};
	       _ -> 
		   {expect, atom_to_list(SUB)}
	   end
	  ]
	 }
	] ++
	["Verification du profil dans la base de donnees locale",
	 {shell,select_by_subscription(anon)}
	] ++
	profile_manager:set_sachem_response(?uid, {"csl_doscp", ok})++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type test_ocf_failed() -> service_test().
test_ocf_failed(SUB) ->
    initialize(SUB)++
	profile_manager:set_ocf_response(?uid,'OrangeAPI.subscribeByImsi',{ok,{response, {fault, ?IMSI_UNKNOW, "IMSI unknow"}}})++
	[{title,
	  "CONNEXION D'UN CLIENT " ++ atom_to_list(SUB) ++ " ALORS QUE OCFRDP EST HS"
	 }
	] ++
	reset_local_db() ++
	["Connexion a Cellcube pour realisation du self provisionning.",
	 {ussd2,
	  [{send, ?CODE},
	   {expect, atom_to_list(SUB)}
	  ]}     
	]++
	check_nb_subs_ocf_failed("1", SUB)++

	["Connexion a Cellcube pour realisation du self provisionning.",
	 {ussd2,
	  [{send, ?CODE},
	   {expect, atom_to_list(SUB)}
	  ]}     
	]++
	check_nb_subs_ocf_failed("2", SUB)++
	profile_manager:set_ocf_response(?uid,'OrangeAPI.subscribeByImsi',{ok,{response, {fault, 13, "Multiple souscription"}}})++ 
	["Connexion a Cellcube pour realisation du self provisionning.",
	 {ussd2,
	  [{send, ?CODE},
	   {expect, atom_to_list(SUB)}
	  ]}     
	]++
	check_nb_subs_ocf_failed("0", SUB)++
	profile_manager:set_ocf_response(?uid,'OrangeAPI.subscribeByImsi',default)++
	["Connexion a Cellcube pour realisation du self provisionning.",
	 {ussd2,
	  [{send, ?CODE},
	   {expect, atom_to_list(SUB)}
	  ]}     
	]++
	check_nb_subs_ocf_failed("0", SUB)++
	[].

test_api_write_to_file() ->
    [{title,"TEST API for CRONTAB Write to a file"}]++
	initialize(mobi)++
	profile_manager:set_ocf_response(?uid,'OrangeAPI.subscribeByImsi',{ok,{response, {fault, ?IMSI_UNKNOW, "IMSI unknow"}}})++
	update_of_extra(?selfcare_user_imsi,"3")++
	profile_manager:rpc_for_test(provisioning_ftm,write_to_file,[])++
	profile_manager:rpc_for_test(?MODULE,verify_file,[]).

verify_file() ->
    {Y,M,D}=date(),
    Filename="Dossier_en_echec_OCF_"++lists:flatten(pbutil:sprintf("%02d%02d%02d",[D,M,Y-2000])),
    {ok,FD} = file:open("run/"++Filename++".csv",[read]),
    ok.

update_of_extra(Imsi,Nb_subs_ocf_failed) ->
    ["Updating field nb_subs_ocf_failed in local database",
     {shell_no_trace,
      [
       {send,
	"mysql -u possum -ppossum mobi -Be "
	"\"SELECT @u := uid FROM users WHERE imsi = '" ++Imsi++ "'; "
	"  UPDATE users_orangef_extra SET nb_subs_ocf_failed='"++Nb_subs_ocf_failed++"' WHERE uid = @u\""}
      ]}
    ].

						%init_error(no_resp)->
						%    profile_manager:update_spider(?uid,data,[{error,tcp_closed}]);
						%init_error(ErrorCode) ->
						%    profile_manager:update_spider(?uid,status,#spider_status{statusCode=ErrorCode});
						%init_error(no_resp, Type) ->
						%    profile_manager:update_spider(?uid,profile,{offerType,Type})++
						%    profile_manager:update_spider(?uid,data,[{error,tcp_closed}]);
						%init_error(ErrorCode, Type) ->    
						%    profile_manager:update_spider(Uid,profile,{offerType,Type})++
						%    profile_manager:update_spider(Uid,status,#spider_status{statusCode=ErrorCode}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_spider_out_of_order() -> service_test().

user_spider_out_of_order(SUB,ErrorCode) ->
    [{title,
      "CONNEXION D'UN CLIENT " ++ atom_to_list(SUB) ++ " ALORS QUE SPIDER EST HS"
     }
    ] ++
	reset_local_db() ++
	new_user(SUB) ++
	profile_manager:update_spider(?uid,status,#spider_status{statusCode=ErrorCode})++
	["Connexion a Cellcube pour realisation du self provisionning.",
	 {ussd2,
	  [{send, ?CODE},
	   case lists:member(SUB, ?spider_subscriptions) of
	       true -> 
		   {expect, "anon"};
	       _ -> 
		   {expect, atom_to_list(SUB)}
	   end
	  ]
	 }
	] ++
	["Verification du profil dans la base de donnees locale",
	 {shell,select_by_subscription(anon)}
	] ++
	profile_manager:update_spider(?uid,status,#spider_status{statusCode="a300"})++
	[].


expected_response_spider_error(?SERVICE_INDISPONIBLE)->
    "spider_service_indisponible";
expected_response_spider_error(?ACCES_REFUSE) ->
    "spider_acces_refuse";
expected_response_spider_error(?PROBLEME_TECHNIQUE) ->
    "spider_probleme_technique";    
expected_response_spider_error(?DOSSIER_INCONNU) ->
    "anon".

check_commercial_segment(Expected, Sub) ->
    [{shell,
      [ {send,
	 "mysql -u possum -ppossum mobi -Bse "
	 "\"SELECT commercial_segment "
	 "  FROM users LEFT JOIN users_orangef_extra USING (uid) "
	 "  WHERE imsi = '"++?selfcare_user_imsi++"'\""},
	{expect,Expected}
       ]}].

check_nb_subs_ocf_failed(Expected, Sub) -> 
    ["Verification nb_subs_ocf_failed du profil dans la base de donnees locale",
     {shell,
      [ {send,
	 "mysql -u possum -ppossum mobi -Bse "
	 "\"SELECT nb_subs_ocf_failed "
	 "  FROM users LEFT JOIN users_orangef_extra USING (uid) "
	 "  WHERE imsi = '"++?selfcare_user_imsi++"'\""},
	{expect,Expected}
       ]}].

rmplus(X) ->
    test_provisioning_local:rmplus(X).
select_by_subscription(SUB)->
    [{send, "mysql -u possum -ppossum -B -e \"SELECT imsi,subscription FROM users "
      "WHERE imsi='" ++ ?selfcare_user_imsi ++ "'\" mobi"},
     {expect, ?selfcare_user_imsi ++ ".*" ++ atom_to_list(SUB)}].
count_by_subscription(X,Y)->
    test_provisioning_local:count_by_subscription(X,Y).
count_by_imsi(X,Y)->
    test_provisioning_local:count_by_imsi(X,Y).
count_by_msisdn(Msisdn,Value) ->
    test_provisioning_local:count_by_msisdn(Msisdn,Value).
data(Type,Subscription) -> 
    test_provisioning_local:data(Type,Subscription).
