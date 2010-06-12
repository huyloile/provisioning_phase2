-module(test_123_mobi_bons_plans_low_credit).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid, user_low_credit).

online() ->
    test_util_of:online(?MODULE,test()).

test()->
      test_bp_lowcredit_multimedia() ++
   	test_bp_lowcredit_messages() ++
	test_bp_lowcredit_appels() ++
	["Test reussi"].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text_title(opt_jinf) ->
    "Journee Infinie";
text_title(opt_sinf) ->
    "Soiree Infinie";
text_title(opt_weinf) ->
    "Week end Infini";
text_title(opt_duo) ->
    "Duo Journee";
text_title(opt_sms_quoti) ->
    "SMS quotidien";
text_title(opt_ssms) ->
    "Soiree SMS illimites";
text_title(opt_msn_journee_mobi) ->
    "Journee SMS illimites".
text_low_credit(opt_jinf) ->
    "Journee Infinie";
text_low_credit(opt_sinf) ->
    "Soiree Infinie";
text_low_credit(opt_weinf) ->
    ".*eek.*nd .*nfini";
text_low_credit(opt_duo) ->
    "duo journee";
text_low_credit(opt_sms_quoti) ->
    "SMS quotidienne";
text_low_credit(opt_ssms) ->
    "soiree SMS";
text_low_credit(opt_msn_journee_mobi) ->
    "journee Orange Messenger by Windows Live".



codes_vos_appels(Opt, DCL) ->
    Link = test_123_mobi_bons_plans_vos_appels:vos_appels_menu(DCL),
    case Opt of
	opt_jinf ->
	    Link ++ "111";
	opt_sinf ->
	    Link ++ "211";
	opt_weinf ->
	    Link ++ "311";
	_->
	    Link ++ "411111"
    end.

test_bp_lowcredit_appels() ->
     test_bp_lowcredit_appels(opt_jinf, ?mobi)++
    	test_bp_lowcredit_appels(opt_sinf, ?mobi)++
    	test_bp_lowcredit_appels(opt_weinf, ?mobi)++
 	test_bp_lowcredit_appels(opt_duo, ?mobi)++
        [].

test_bp_lowcredit_appels(opt_duo=Opt, DCL_NUM) ->
    init_test()++
  	profile_manager:set_sachem_response(?Uid, {"maj_op", {nok, {error,"solde_insuffisant"}}})++	
        [{title, "<center>#### DCL_NUM "++integer_to_list(DCL_NUM)++" Vos Appels - "
          ++text_title(Opt)++" sans promo ####</center>"},
	 "Test Duo Journee",
	 {ussd2,
	  [ {send, codes_vos_appels(Opt, DCL_NUM)},
	    {expect,"Bonjour, pour souscrire a l'option "++text_low_credit(Opt)++
	     ", vous devez disposer de .* sur votre compte."},
	    {send,"1"}, 
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"}
	   ]}
	]++

	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_BONS_PLANS,
						       unt_num=?EURO,
						       cpp_solde=15000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PBONS_PLANS}])++
	[{title, "<center>#### Vos Appels - "++text_title(Opt)++
          " avec promo - Low Credit ####</center>"},
 	 "Test Duo Journee",
 	 {ussd2,
 	  [ {send, codes_vos_appels(Opt, DCL_NUM)},
 	    {expect,".*"},
            {expect,"Bonjour, pour souscrire a l'option "++text_low_credit(Opt)++
             ", vous devez disposer de .* sur votre compte mobicarte."},
            {send,"1"},
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"}  
 	   ]}];

test_bp_lowcredit_appels(Opt, DCL_NUM)->
    init_test()++
  	profile_manager:set_sachem_response(?Uid, {"maj_op", {nok, {error,"solde_insuffisant"}}})++	
 	[{title, "<center>####  DCL_NUM "++integer_to_list(DCL_NUM)++" Vos Appels - "
          ++text_title(Opt)++" ####</center>"},
 	 "Test "++text_title(Opt),
 	 {ussd2,
          [ {send, codes_vos_appels(Opt, DCL_NUM)},
            {expect,".*"},
            {expect,"Bonjour, pour souscrire a l'option "++text_low_credit(Opt)++
             ", vous devez disposer de .* sur votre compte. "
             "Orange vous remercie de votre appel."},
            {send,"1"}, 
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"} 
	   ]
    	 }
    	].
codes_vos_messages(Opt)->
    Link = test_123_mobi_bons_plans_vos_messages:code_vos_messages(?mobi),
    case Opt of
	opt_sms_quoti ->
	    Link ++ "12";
	opt_ssms ->
	    Link ++ "14";
	_->
	    Link ++ "13"
    end.
test_bp_lowcredit_messages() ->
    test_bp_lowcredit_messages(opt_sms_quoti, ?mobi) ++
  	test_bp_lowcredit_messages(opt_ssms, ?mobi) ++
 	test_bp_lowcredit_messages(opt_msn_journee_mobi, ?mobi) ++
	[].

test_bp_lowcredit_messages(Opt, DCL_NUM) ->
    init_test()++
  	profile_manager:set_sachem_response(?Uid, {"maj_op", {nok, {error,"solde_insuffisant"}}})++	
        test_util_of:set_present_period_for_test(commercial_date,[Opt])++
 	[{title, "<center>####  DCL_NUM "++integer_to_list(DCL_NUM)++" Vos Messages SMS - Option "++ text_title(Opt) ++
          " ####</center>"},
         "Test Option "++ text_title(Opt) ++" Low Credit",
	 {ussd2,
	  [ 
	    {send, codes_vos_messages(Opt)},
	    {expect,".*"},
	    {send,"11111"},
    	    {expect,"Bonjour, pour souscrire au bon plan "++text_title(Opt)++
             ".*vous devez disposer de .*E sur votre compte.*"
             "1:Recharger"},
	    {send,"1"},
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"} 
 	   ]
    	 }
    	]++
	[].

code_menu_multimedia(DCL)->
    test_123_mobi_bons_plans_votre_multimedia:code_menu_multimedia(DCL).

test_bp_lowcredit_multimedia() ->
    test_opt_multimedia(opt_orange_sport, ?m6_prepaid) ++
       	test_opt_multimedia(opt_orange_sport, ?click_mobi) ++
      	test_opt_multimedia(opt_internet, ?mobi)++
	test_opt_multimedia(opt_tv, ?mobi) ++
	[].                  
code_souscrire_option(Opt,DCL)->
    case {Opt,DCL} of
	{opt_orange_sport,?m6_prepaid}->"311";
	{opt_orange_sport,?click_mobi}->"311";
	{opt_internet,?mobi}->"11";
	{opt_tv,?mobi} ->"111"
    end.
test_opt_multimedia(Option=opt_internet, DCL) ->    
    init_test()++
 	profile_manager:set_sachem_response(?Uid, {"maj_op", {nok, {error,"solde_insuffisant"}}})++
    	[{title, "<center>#### Votre Multimedia - option internet inactive - Souscription####</center>"},
    	 "Test Menu votre multimedia internet max inactive",
    	 {ussd2,
    	  [ {send, code_menu_multimedia(DCL)++"3"},
    	    {expect,".*"},
     	    {send,code_souscrire_option(opt_internet,DCL)},
	    {send, "1"},
     	    {expect,"Bonjour, pour souscrire a l'option Internet, vous devez disposer de plus de 6E "
	     "sur votre compte principal. Merci de votre appel"},
      	    {send,"1"},
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"} 
    	   ]}];                  

test_opt_multimedia(opt_tv, DCL) ->
    init_test()++
 	profile_manager:set_sachem_response(?Uid, {"maj_op", {nok, {error,"solde_insuffisant"}}})++	
   	[{title, "<center>#### Votre Multimedia - option TV inactive####</center>"},
    	 "Test Menu votre multimedia TV inactive",
    	 {ussd2,
    	  [ 
	    {send, code_menu_multimedia(DCL) ++ "5"},
    	    {expect,".*"},
     	    {send,code_souscrire_option(opt_tv,DCL)},
     	    {expect,"Bonjour, pour souscrire a l'option .* vous devez"
             " disposer de plus de 6E sur votre compte. Merci de votre appel"},
      	    {send,"1"},
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"} 
    	   ]}];

test_opt_multimedia(Opt=opt_orange_sport, DCL) ->
    init_test(DCL) ++
 	profile_manager:set_sachem_response(?Uid, {"maj_op", {nok, {error,"solde_insuffisant"}}})++
  	[{title, "<center>#### Votre Multimedia - option Foot inactive - Test souscription####</center>"},
   	 "Votre Multimedia - option Foot inactive - Test souscription - " ++ integer_to_list(DCL),
   	 {ussd2,
   	  [ 
	    {send, code_menu_multimedia(DCL)++"*6"},
  	    {expect, ".*"},
  	    {send,code_souscrire_option(opt_orange_sport,DCL)},
     	    {expect,"Bonjour, pour souscrire a l'option Sport, vous devez" 
	     " disposer de plus de 6E sur votre compte."},
      	    {send,"1"},
    	    {expect,"Rechargement"
             ".*1:par recharge mobicarte.*2:par carte bancaire"} 
   	   ]}].

init_config_cc() ->
    test_util_of:set_parameter_for_test(sce_used,true)++
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true).

init_test()->
    init_test(?mobi).
init_test(DCL_NUM)->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="mobi",dcl=DCL_NUM})++
	profile_manager:init(?Uid)++
 	profile_manager:set_dcl(?Uid, DCL_NUM)++

        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
                                                       unt_num=?EURO,
                                                       cpp_solde=420,
                                                       dlv=pbutil:unixtime(),
                                                       rnv=0,
                                                       etat=?CETAT_AC,
                                                       ptf_num=?PCLAS_V2}])++

	init_config_cc().

reset_imsi_unik()->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
                    set_env,[pservices_orangef,tac_list,[]]]}
      ]}].
