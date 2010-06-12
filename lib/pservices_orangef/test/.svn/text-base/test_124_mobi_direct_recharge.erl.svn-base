-module(test_124_mobi_direct_recharge).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/smsinfos.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").

-define(uid, recharge_mobicarte_user).
%% gene
-define(back,"0").
-define(menu,"00").

-define(code,"#124*").
-define(code_menu,"#123*1").
-define(imsi_mobi,"999000900000001").
-define(msisdn_mobi,"9900000001").
-define(msisdn_mobi_int,"+99900000001").
-define(niv1,"100007XXXXXXX1").
-define(niv2,"100006XXXXXXX2").
-define(niv3,"100005XXXXXXX3").
-define(code_direct_recharge,"#124").

top_num(Opt) -> svc_options:top_num(Opt,mobi).
ptf_num(Opt) -> svc_options:ptf_num(Opt,mobi).
tcp_num(Opt) -> svc_options:tcp_num(Opt,mobi).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online()->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()).

test()->
    lists:append([test_direct_recharge(DCL_NUM)||DCL_NUM<-[?mobi,
                                                                  ?m6_prepaid,
                                                                  ?OL_mobile,
                                                                  ?click_mobi]])++     
	["Test reussi"].

test_direct_recharge(DCL_NUM)->
    profile_manager:create_default(?uid, "mobi")++
	profile_manager:set_dcl(?uid, DCL_NUM)++
	profile_manager:set_list_options(?uid, [])++
	profile_manager:set_list_comptes(?uid, [#compte{tcp_num=?C_PRINC,
							unt_num=?EURO,
							cpp_solde=1000,
							dlv=pbutil:unixtime(),
							rnv=0,etat=?CETAT_AC,
							ptf_num=?PCLAS_V2}])++
	profile_manager:set_bundles(?uid,[])++
	profile_manager:init(?uid)++
	test_util_of:set_past_period_for_test(commercial_date,[refill_game]) ++
	test_util_of:set_present_period_for_test(commercial_date,[recharge_cg]) ++
	direct_recharge(DCL_NUM)++   %%% recharge mobi par mobicarte
	["Test reussi"].

direct_recharge(DCL_NUM) ->
   profile_manager:set_sachem_recharge(?uid, #sachem_recharge{ttk_num=124,ctk_num=35,accounts=[#account{tcp_num=1,montant=10000,dlv=pbutil:unixtime()+7*86400}]})++
        [{title, "Test Rechargement MOBI Niv1 - DCL ="++integer_to_list(DCL_NUM)},
         "Pas de CG entree apr le client",
         {ussd2,
          [ {send, ?code_direct_recharge++"#"},
            {expect,"Saisissez \\#124\\*Code_a_14_chiffres\\# pour recharger"}]
         },
         "Code CG FAUX",
         {ussd2,
          [ {send, ?code_direct_recharge++"*123456#"},
            {expect,"Saisissez \\#124\\*Code_a_14_chiffres\\# pour recharger"}]
         },
         "Code CG OK",
         {ussd2,
          [ {send, ?code_direct_recharge++"*12345678912301#"},
            {expect,"Vous avez recharge votre compte de 10.00E."}
           ]}
        ]++
	[].

coupure_session(IMSI)->
    test_util_of:close_session().


prisme_counters() ->
    [{"MO","PRECTRSL", 12},
     {"MO","PRECTR", 20}
    ].
