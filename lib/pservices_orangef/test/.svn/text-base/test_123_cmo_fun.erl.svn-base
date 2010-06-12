-module(test_123_cmo_fun).

-export([online/0]).
-export([pages/0, parent/1, links/1]).

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


-define(code_main_menu,"#123*1#").

-define(Uid, user_fun).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?'fun'].

parent(?'fun') ->
    test_123_cmo_Homepage;
parent(_) ->
    ?MODULE.

links(?'fun') ->
    [{fun_chat, static},
     {fun_jeux, static},
     {fun_fun_tones, static},
     {fun_pass_sonneries, static}].

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
        [test_util_of:connect(smppasn)] ++
    	test_menu_fun([DCL||DCL <- [
  				    ?cmo_smart_40min,
  				    ?cmo_smart_1h,
  				    ?cmo_smart_1h30,
  				    ?cmo_smart_2h,
  				    ?ppola,
  				    ?m6_cmo_3h,
  				    ?m6_cmo_20h_8h,
  				    ?zap_vacances,
  				    ?zap_cmo_20E,
  				    ?zap_cmo_1h_unik,
  				    ?m6_cmo_fb_1h,
  				    ?DCLNUM_CMO_SL_ZAP_1h30_ILL,
 				    ?FB_M6_1H_SMS,
				    ?FB_M6_1H30,
                                    ?m6_cmo_onet_2h_30E
    				   ]])++
	[].

test_menu_fun([]) -> ["Test reussi"];
test_menu_fun([DCL|T]) ->
    init_test(DCL)++
	case DCL of
	    ?zap_cmo_20E ->
		profile_manager:set_list_options(?Uid,[#option{top_num=316}]);
	    _->
		profile_manager:set_list_options(?Uid, [])

	end++
	profile_manager:set_dcl(?Uid, DCL)++
	[{title, "Menu Fun -"++user_subscription(DCL)++"\n"++
	  "#### DCL = "++integer_to_list(DCL)}]++
 	[
 	 {ussd2,
 	  [{send, code_menu_fun(DCL)},
 	   {expect,"Decouvrez les Services Multimedia d'Orange.*"
 	    "1:Chat.*"
 	    "2:Jeux.*"
 	    "3:Tonalites.*"
 	    "4:Pass sonneries.*"
	   }
 	  ]
 	 }
 	] ++

  	[{title, "Fun - Chat"},
 	 {ussd2,
 	  [
  	   {send, code_menu_fun(DCL)++"*1#"},
  	   {expect, "Bienvenue sur le Chat Orange"}
  	  ]
  	 }
 	] ++

 	[{title, "Fun - Fun tones"},
 	 {ussd2,
 	  [{send, code_menu_fun(DCL)++"*3#"},
  	   {expect,"Tonalite d'appel - Fun tones ! Ceux qui vous appellent entendent votre musique preferee quand votre mobile sonne.*1:Accedez a Tonalites.*8:Retour.*9:Menu"},
	   {send, "8"},
	   {expect, ".*"}
  	  ]
 	 }
 	] ++

	[{title, "Fun - Pass Sonneries"},
	 {ussd2,
	  [{send, code_menu_fun(DCL)++"*4#"},
 	   {expect,"Avec le pass sonneries a 2E/mois, vous beneficiez d'1 sonnerie Hifi/mois. Infos et souscription sur Orange World"}
 	  ]}]++

	close_session()++
	test_menu_fun(T).

code_menu_fun(?zap_vacances) ->
    test_util_of:access_code(test_123_cmo_Homepage,
			     ?'fun',
			     [?avantages_vacances, ?zap_zone]);
code_menu_fun(DCL)
  when DCL==?m6_cmo_3h; DCL==?m6_cmo_20h_8h;
       DCL==?rsa_cmo; DCL==?m6_cmo_fb_1h;
       DCL==?FB_M6_1H_SMS; DCL==?FB_M6_1H30;
       DCL==?m6_cmo_onet_2h_30E ->
    test_util_of:access_code(test_123_cmo_Homepage,
			     ?'fun');
code_menu_fun(?zap_cmo_20E) ->
    test_util_of:access_code(test_123_cmo_Homepage,
			     ?'fun',
			     [?zap_zone]);
code_menu_fun(_) ->
    test_util_of:access_code(test_123_cmo_Homepage,
			     ?'fun',
			     [?zap_zone]).

user_subscription(?zap_vacances) ->
    " SL Zap Vacances et Zap V3 ";
user_subscription(?zap_cmo_20E) ->
    " SL Roxy ";
user_subscription(?zap_cmo_25E) ->
    " SL Zap Vacances et Zap V3 ";
user_subscription(?ppola) ->
    " PPOLA ";
user_subscription(?m6_cmo_3h)->
    " M6 FB 3h ";
user_subscription(?m6_cmo_20h_8h)->
    " M6 FB 1h O&f 20h - 8h ";
user_subscription(?FB_M6_1H_SMS)->
    " FB M6 1h SMS 19.99E ";
user_subscription(?FB_M6_1H30)->
    " FB M6 1h30 25.99E ";
user_subscription(?m6_cmo_onet_2h_30E)->
    " M6 ONET 2h 29.99E ";
user_subscription(?rsa_cmo)->
    " FB Special RSA";
user_subscription(?zap_cmo_1h_unik) ->
    "SL Zap 1h avec Unik";
user_subscription(?zap_cmo_1h30_ill) ->
    "SL Zap 1h30 Ill";
user_subscription(?DCLNUM_CMO_SL_ZAP_1h30_ILL) ->
    "SL Zap 1h30 Msg 24/7";
user_subscription(?m6_cmo_fb_1h) ->
    "M6 FB 1h";
user_subscription(?cmo_smart_40min) ->
    "SMART 40MIN";
user_subscription(?cmo_smart_1h) ->
    "SMART 1H";
user_subscription(?cmo_smart_1h30) ->
    "SMART 1H30";
user_subscription(?cmo_smart_2h) ->
    "SMART 2H";
user_subscription(_) ->
    "UNKOWN DECLICAISON".

asmserv_restore(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_restore(MSISDN, ACTIV_OPTs).
asmserv_init(MSISDN, ACTIV_OPTs) ->
    test_util_of:asmserv_init(MSISDN, ACTIV_OPTs).
insert(IMSI,DCL,OPT,COMPTES) ->
    test_util_of:insert(IMSI,DCL,OPT,COMPTES,[]).
insert_list_top_num(MSISDN,TOP_NUM_LIST) ->
    test_util_of:insert_list_top_num(MSISDN,TOP_NUM_LIST).

init_test(DCL_NUM)->    
    Test_profile = #test_profile{sub="cmo",
                                 dcl=DCL_NUM,
                                 comptes=[#compte{tcp_num=?C_PRINC,
                                                  unt_num=?EURO,
						  cpp_solde=42000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,
                                                  etat=?CETAT_AC,
                                                  ptf_num=?PCLAS_V2}]
                                },
    profile_manager:create_and_insert_default(?Uid,Test_profile)++
        profile_manager:init(?Uid).


close_session() ->
    test_util_of:close_session().
