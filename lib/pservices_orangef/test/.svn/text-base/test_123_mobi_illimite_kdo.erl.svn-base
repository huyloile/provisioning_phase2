-module(test_123_mobi_illimite_kdo).
-export([run/0, online/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(Uid, user_ill_kdo).

-define(CODE_MENU,  test_util_of:access_code(test_123_mobi_homepage,?menu_page)).
-define(CODE_ILLIMITE_KDO, test_util_of:access_code(test_123_mobi_homepage, ?mobi_bonus,
 						    [?suivi_conso_plus_menu,
 						     ?mobi_bonus])).
-define(List_illimite_kdo, [
			    opt_illimite_kdo,
 			    opt_ikdo_vx_sms,
			    opt_illimite_kdo_v2
			   ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close_session() ->  test_util_of:close_session().
lt2unixt(LT) -> test_util_of:lt2unixt(LT).
top_num(Opt) -> svc_options:top_num(Opt,mobi).
tcp_num(Opt) -> svc_options:tcp_num(Opt,mobi).
ptf_num(Opt) -> svc_options:ptf_num(Opt,mobi).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    test_proposer_lien_si_active(),
    test_proposer_lien(), %Anomalie 1767
    ok.

test_proposer_lien()->
    pbutil:opt_set_env(pservices_orangef, commercial_date,[{opt_illimite_kdo_v2, [{{{2008,06,12}, {0,0,0}}, {{21000,08,21},   {23,59,59}}}]}]),
    pbutil:opt_set_env(pservices_orangef, plage_horaire,[]),
    lists:foldl(
      fun({Option_actived, Expected}, Count) ->
	      Session = set_session(Option_actived),
	      Result = svc_of_plugins:proposer_lien(Session, "mobi", "opt_illimite_kdo_v2", "Link", "Url"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{opt_illimite_kdo,[]},
       {opt_ikdo_vx_sms,[]},
       {none,
	[#hlink{href="Url",key=[],kw=[],cost=0,help=[],
		contents=[{pcdata, "Link"}]},br]}
]).
test_proposer_lien_si_active()->
    lists:foldl(
      fun({Option, Option_actived, Expected}, Count) ->
	      Session = set_session(Option_actived),
	      Result = svc_of_plugins:proposer_lien_si_active(Session, "mobi", Option, "Link", "Url","br"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{"opt_illimite_kdo",opt_illimite_kdo,
	[#hlink{href="Url",key=[],kw=[],cost=0,help=[],
		contents=[{pcdata, "Link"}]},br]},
       {"opt_ikdo_vx_sms",opt_illimite_kdo,
	[]},
       {"opt_illimite_kdo",opt_ikdo_vx_sms,
	[]},
       {"opt_ikdo_vx_sms",opt_ikdo_vx_sms,
	[#hlink{href="Url",key=[],kw=[],cost=0,help=[],
		contents=[{pcdata, "Link"}]},br]},
       {"opt_illimite_kdo",none,
 	[]},
       {"opt_illimite_kdo",opt_ikdo_voix,[]},
       {"opt_ikdo_vx_sms",opt_ikdo_voix,[]}
]).
    
set_session(none) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{declinaison=0,options=[]}}]};
set_session(opt_ikdo_vx_sms) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{declinaison=0,topNumList=[127,135],options=[{127,actived},{135,actived}]}}]};
set_session(opt_illimite_kdo) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{declinaison=0,topNumList=[127],options=[{127,actived}]}}]};
set_session(opt_ikdo_voix)->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{declinaison=0,topNumList=[166],options=[{166,actived}]}}]}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE, test()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test()->
	test_util_of:set_present_period_for_test(commercial_date,?List_illimite_kdo) ++

	test_util_of:init_day_hour_range() ++
	test_util_of:set_past_period_for_test(commercial_date,[user_janus_promo])++
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true) ++

  	test_illimite_kdo(?mobi) ++
    	test_illimite_kdo_v2(?mobi) ++
   	test_illimite_kdo_voix_sms(?mobi) ++
  	test_illimite_kdo(?mobi_janus) ++
  	test_illimite_kdo_v2(?mobi_janus) ++
 	test_illimite_kdo_voix_sms(?mobi_janus) ++

        [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Test ILLIMITE KDO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_illimite_kdo(?mobi_janus=DCL_NUM)->
    init_test(DCL_NUM)++
        test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo]) ++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_illimite_kdo, "mobi")}])++
        profile_manager:set_list_comptes(?Uid, [compte(?C_PRINC,cpp_cumul_credit),
						compte(?C_SMS),
						compte(opt_illimite_kdo,50000,?CETAT_AC)])++

        [ "DECLINAISON DCL_NUM= " ++ integer_to_list(DCL_NUM)] ++
	["SOUSCRIPTION OPTION ILLIMITE KDO \n"
	 "without Illimite KDO link\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_MENU},
	    {send, "#123*2"},
   	    {expect, "Menu #123#.*Suivi Conso.*Recharger.*choisir Bonus.*Vos bons plans.*Offrir du credit.*"}]}] ++
	close_session();
test_illimite_kdo(DCL_NUM)->
    init_test(DCL_NUM)++
    test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo]) ++
	profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_illimite_kdo, "mobi")}])++
	profile_manager:set_list_comptes(?Uid,[compte(?C_PRINC,cpp_cumul_credit),
					       compte(?C_SMS),
					       compte(opt_illimite_kdo,50000,?CETAT_AC)])++

	["SOUSCRIPTION OPTION ILLIMITE KDO \n"
	 "LE CLIENT BENEFICIE DE L'ILLIMITE KDO DANS LE MOIS EN COURS\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_ILLIMITE_KDO},	   
  	    {send, "#123*2*3"},	   
   	    {expect, "1:Suivi du rechargement.*"
	     "2:Pour consulter son No KDO.*"
	     "3:Pour modifier son No KDO.*"
	     "4:Se desinscrire de l'illimite KDO.*"
	     "5:Conditions.*"}]}] ++
	close_session()++
    test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo,
							      opt_ikdo_vx_sms]) ++
    [ "DECLINAISON DCL_NUM= " ++ integer_to_list(DCL_NUM)] ++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_ikdo_vx_sms, "mobi")}])++
        profile_manager:set_list_comptes(?Uid,[compte(?C_PRINC)])++
	profile_manager:update_sachem(?Uid, "csl_op", {"NB_OCC","0"})++

	["SOUSCRIPTION OPTION ILLIMITE KDO : CAS OPTION ILLIMITE KDO VOIX SMS ACTIVE,\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_ILLIMITE_KDO},
	    {send, "#123*2*3"},
	    {expect, ".*A partir de 30 euros recharges dans le mois.*1:Suite.*2:Conditions.*3:Enregistrer son numero"}]}] ++
	profile_manager:update_sachem(?Uid, "csl_op", {"NB_OCC","1"})++
	close_session()++
	[].
test_illimite_kdo_v2(?mobi_janus=DCL_NUM)->
    init_test(DCL_NUM)++
        test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo_v2]) ++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_illimite_kdo_v2, "mobi")}])++
        profile_manager:set_list_comptes(?Uid, [compte(?C_PRINC,cpp_cumul_credit),
                                                compte(?C_SMS),
                                                compte(opt_illimite_kdo_v2,50000,?CETAT_AC)])++

        ["DECLINAISON DCL_NUM= " ++ integer_to_list(DCL_NUM)] ++
	["SOUSCRIPTION OPTION ILLIMITE KDO V2  \n"
	 "without Illimite KDO link\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_MENU},
	    {send, "#123*2"},
   	    {expect, "Menu #123#.*Suivi Conso.*Recharger.*choisir Bonus.*Vos bons plans.*Offrir du credit.*"}]}] ++
	close_session();
test_illimite_kdo_v2(DCL_NUM)->
    init_test(DCL_NUM)++
    test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo_v2]) ++
	profile_manager:set_dcl(?Uid,DCL_NUM)++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_illimite_kdo_v2, "mobi")}])++
        profile_manager:set_list_comptes(?Uid, [compte(?C_PRINC,cpp_cumul_credit),
                                                compte(?C_SMS),
                                                compte(opt_illimite_kdo_v2,50000,?CETAT_AC)])++

	["SOUSCRIPTION OPTION ILLIMITE KDO V2 \n"
	 "LE CLIENT BENEFICIE DE L'ILLIMITE KDO DANS LE MOIS EN COURS\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_ILLIMITE_KDO},	   
	    {send, "#123*2*3"},
   	    {expect, "1:Suivi du rechargement.*"
	     "2:Pour consulter son No KDO.*"
	     "3:Pour modifier son No KDO.*"
	     "4:Se desincrire de l'illimite KDO voix \\+ sms.*"
	     "5:Conditions.*"}]}] ++
	close_session()++
    test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo_v2,
							      opt_ikdo_vx_sms]) ++
    [ "DECLINAISON DCL_NUM= " ++ integer_to_list(DCL_NUM)] ++
	profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_ikdo_vx_sms, "mobi")}])++
        profile_manager:set_list_comptes(?Uid,[compte(?C_PRINC)])++
        profile_manager:update_sachem(?Uid, "csl_op", {"NB_OCC","0"})++

	["SOUSCRIPTION OPTION ILLIMITE KDO V2 : CAS OPTION ILLIMITE KDO VOIX SMS ACTIVE,\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_ILLIMITE_KDO},
	    {send, "#123*2*3"},
	    {expect, ".*A partir de 30 euros recharges dans le mois.*1:Suite.*2:Conditions.*3:Enregistrer son numero"}]}] ++
	close_session()++
	[].

test_illimite_kdo_voix_sms(?mobi_janus=DCL_NUM)->
    init_test(DCL_NUM)++
        test_util_of:set_present_period_for_test(commercial_date,[opt_ikdo_vx_sms]) ++
	profile_manager:set_dcl(?Uid,DCL_NUM)++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_ikdo_vx_sms, "mobi")}])++
        profile_manager:set_list_comptes(?Uid, [compte(?C_PRINC,cpp_cumul_credit),
                                                compte(?C_SMS),
                                                compte(opt_ikdo_vx_sms,50000,?CETAT_AC)])++

        [ "DECLINAISON DCL_NUM= " ++ integer_to_list(DCL_NUM)] ++
	["SOUSCRIPTION OPTION ILLIMITE KDO VOIX SMS \n",
	 "without Illimite KDO link\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_MENU},
	    {send, "#123*2"},
   	    {expect, "Menu #123#.*Suivi Conso.*Recharger.*choisir Bonus.*Vos bons plans.*Offrir du credit.*"}]}] ++
	close_session();
test_illimite_kdo_voix_sms(DCL_NUM)->
    init_test(DCL_NUM)++
	test_util_of:set_present_period_for_test(commercial_date,[opt_ikdo_vx_sms]) ++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_ikdo_vx_sms, "mobi")}])++
        profile_manager:set_list_comptes(?Uid, [compte(?C_PRINC,cpp_cumul_credit),
                                                compte(?C_SMS),
                                                compte(opt_illimite_kdo,50000,?CETAT_AC)])++
	
	["SOUSCRIPTION OPTION ILLIMITE KDO VOIX SMS\n"
	 "LE CLIENT BENEFICIE DE L'ILLIMITE KDO DANS LE MOIS EN COURS\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_ILLIMITE_KDO},	   
	    {send, "#123*2*3"},
   	    {expect, "1:Suivi du rechargement.*"
	     "2:Pour consulter son No KDO.*"
	     "3:Pour modifier son No KDO.*"
	     "4:Se desinscrire de l'illimite KDO .*"
	     "5:Conditions.*"}]}] ++
	close_session()++
    test_util_of:set_present_period_for_test(commercial_date,[opt_illimite_kdo,
							      opt_ikdo_vx_sms]) ++
    [ "DECLINAISON DCL_NUM= " ++ integer_to_list(DCL_NUM)] ++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_ikdo_vx_sms, "mobi")}])++
        profile_manager:set_list_comptes(?Uid,[compte(?C_PRINC)])++
        profile_manager:update_sachem(?Uid, "csl_op", {"NB_OCC","0"})++

	["SOUSCRIPTION OPTION ILLIMITE KDO VOIX SMS : CAS OPTION ILLIMITE KDO ACTIVE,\n",
   	 {ussd2,
   	  [ 
%% 	    {send, ?CODE_ILLIMITE_KDO},
	    {send, "#123*2*3"},
	    {expect, ".*A partir de 30 euros recharges dans le mois.*1:Suite.*2:Conditions.*3:Enregistrer son numero"}]}] ++
	[].

compte(?C_PRINC)->
    #compte{tcp_num=?C_PRINC, 	 
	    unt_num=?EURO, 	 
	    cpp_solde=50000, 	 
	    dlv=pbutil:unixtime(), 	 
	    rnv=0, 	 
	    etat=?CETAT_AC, 	 
	    ptf_num=?PCLAS_V2};
compte(?C_SMS)->
    #compte{tcp_num=?C_SMS, 	 
	    unt_num=?EURO, 	 
	    cpp_solde=50000, 	 
	    cpp_cumul_credit=20000,
	    dlv=pbutil:unixtime(), 
	    rnv=0,
	    etat=?CETAT_AC, 	 
	    ptf_num=?PCLAS_V2}.

compte(?C_PRINC,cpp_cumul_credit)->
    #compte{tcp_num=?C_PRINC, 	 
	    unt_num=?EURO, 	 
	    cpp_solde=50000, 	 
	    cpp_cumul_credit=30000,
	    dlv=pbutil:unixtime(), 	 
	    rnv=0, 	 
	    etat=?CETAT_AC, 	 
	    ptf_num=?PCLAS_V2};

compte(?C_PRINC,_) ->
    #compte{tcp_num=?C_PRINC, 	 
	    unt_num=?EURO, 	 
	    cpp_solde=50000, 	 
	    dlv=pbutil:unixtime(), 	 
	    rnv=0, 	 
	    etat=?CETAT_AC, 	 
	    ptf_num=?PCLAS_V2}.
compte(opt_illimite_kdo,Solde,State) ->
    #compte{tcp_num=tcp_num(opt_illimite_kdo),
	    unt_num=?EURO,
	    cpp_solde=Solde,
	    dlv=pbutil:unixtime()+7*86400,
	    rnv=-1,
	    etat=State,
	    ptf_num=ptf_num(opt_illimite_kdo)};
compte(opt_ikdo_vx_sms,Solde,State) ->
    #compte{tcp_num=tcp_num(opt_ikdo_vx_sms),
	    unt_num=?EURO,
	    cpp_solde=Solde,
	    dlv=pbutil:unixtime()+7*86400,
	    rnv=-1,
	    etat=State,
	    ptf_num=ptf_num(opt_ikdo_vx_sms)};
compte(opt_illimite_kdo_v2,cpp_cumul_credit,State)->		     
    #compte{tcp_num=tcp_num(opt_illimite_kdo_v2),
	    unt_num=?EURO,
	    cpp_solde=0, 	 
	    cpp_cumul_credit=200000,
	    dlv=pbutil:unixtime()+7*86400,
	    rnv=-1,
	    etat=State,
	    ptf_num=ptf_num(opt_ikdo_voix)};
compte(opt_illimite_kdo_v2,_,State) ->
    #compte{tcp_num=tcp_num(opt_illimite_kdo_v2),
	    unt_num=?EURO,
	    cpp_solde=0, 	 
	    dlv=pbutil:unixtime()+7*86400,
	    rnv=-1,
	    etat=State,
	    ptf_num=ptf_num(opt_ikdo_voix)}.


init_test(DCL_NUM)->
        profile_manager:create_and_insert_default(?Uid, #test_profile{sub="mobi",dcl=DCL_NUM})++
        profile_manager:init(?Uid).

today_plus_datetime(Days) ->
        svc_util_of:local_time_to_unixtime({svc_options:today_plus_datetime(Days),{0,0,0}}).
