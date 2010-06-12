-module(test_123_mobi_bons_plans_autres_options).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(opt_cityzi,46).
-define(IMEI_UNIK,35061310).
-define(Uid, user_autres_option_mobi).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    test_redirect_by_option_state(),
    ok.

test_redirect_by_option_state()->
    lists:foldl(
      fun({State, Expected}, Count) ->
	      Session = set_session(State),
	      NewSession = variable:update_value(Session,{"bons_plans", "option"},"unik"),
	      {redirect, _, Result} = svc_of_plugins:redirect_by_option_state(NewSession, "not_actived", "actived", "suspend"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{actived,  "actived"},
       {not_actived,  "not_actived"},
       {suspend,  "suspend"}
      ]).

set_session(actived) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{options = [{18,actived}]}}]};
set_session(not_actived) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{options = []}}]};
set_session(suspend) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{options = [{18,suspend}]}}]}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-define(IMSI,"999000900000001").
-define(MSISDN,"9900000001").

parent(?autres_options)->
    test_123_mobi_homepage;
parent(_) ->
    ?MODULE.
pages()->
    [?autres_options].
links(?autres_options)->
    [
     {opt_unik, static},
     {opt_cityzi, static}
    ];
links(Else) ->    
        io:format("~p : links of this page ~p are not defined~n",[?MODULE, Else]).

-define(CODE_BONS_PLANS, test_util_of:access_code(parent(?autres_options), ?bons_plans,
                                           [?recharger,
					    ?suivi_conso_plus_menu, 
					    ?mobi_bonus, 
					    ?exclusives])).
-define(CODE_AUTRES_OPTIONS, test_util_of:access_code(parent(?autres_options), ?autres_options, 
						      [?recharger,
						       ?suivi_conso_plus_menu, 
						       ?mobi_bonus, 
						       ?exclusives, 
						       ?autres_options])).
get_dyn_links(DCL) ->
    case DCL of
	?mobi ->
	    [?recharger,
	     ?suivi_conso_plus_menu,
	     ?mobi_bonus,
	     ?exclusives,
	     ?autres_options];
	?click_mobi ->
	    [?recharger,
	     ?exclusives,
	     ?autres_options];
	?OM_mobile ->
            [?recharger,
	     ?foot_variable_x,
	     ?foot_variable_y,
	     ?soirees,
	     ?exclusives,
	     ?autres_options];
	?m6_prepaid ->
            [?recharger,
	     ?autres_options];
	?umobile ->
            [?recharger,
	     ?exclusives,
	    ?autres_options]
    end.

code_cityzi(DCL) ->
     case DCL of
 	?mobi ->
 	    test_util_of:access_code(?MODULE, opt_cityzi, get_dyn_links(DCL));
 	_ ->
 	    test_util_of:access_code(parent(?autres_options), ?autres_options, get_dyn_links(DCL))
     end.


online() ->
    test_util_of:online(?MODULE,test_unik()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


test_clas_plan()->
    [
     {send, ?CODE_AUTRES_OPTIONS},
     {expect,".*Avec le bon plan Unik, doublez votre temps de parole  vers les mobiles Orange en France"},
     {send,"1"},
     {expect,"Pour 3E par mois"},
     {send,"1"},
     {expect,".*les trois conditions suivantes : avoir un.*"},
     {send,"1"},
     {expect,".*Confirmer.*"},
     {send,"1"},
     {expect,".*Vous avez souscrit au bon plan unik pour 3E. Ce montant a ete debite de votre compte.*"},
     {send,"1"},
     {expect,"..wep dans votre mobile."},
     {send,"1"},	    
     {expect,"..Pour plus d'informations"}
    ].

test_unik() ->
     init_test()++
   	["TEST UNIK - DECLINAISON DCL_NUM=110 - COMPATIBLE OPT UNIK"] ++
   	set_profile(?mobi_janus,plan_sec)++
           set_imsi_unik()++
           [{title, "<center>#### Option - Unik Plan Classique Seconde ####</center>"},
            "Test premiere page",
            {ussd2,
   	  [{send, ?CODE_BONS_PLANS},
   	  {expect,".*[^Autres Options].*"}]
             }]++
           test_util_of:close_session()++

   	["TEST UNIK - DECLINAISON DCL_NUM=110 - HAVING OPT CITYZI - COMPATIBLE OPT UNIK"] ++
           set_profile(?mobi_janus,opt_cityzi)++
           set_imsi_unik()++
           [{title, "<center>#### Option - Unik Plan Classique Seconde ####</center>"},
            "Test premiere page",
            {ussd2,
             [{send, ?CODE_BONS_PLANS},
             {expect,".*Autres Options.*"},
   	  {send, "6"},
   	  {expect, ".*Attention, si vous supprimez votre option Cityzi.*"}]
             }]++
           test_util_of:close_session()++

   	["TEST UNIK - DECLINAISON DCL_NUM=110 - HAVING OPT CITYZI - INCOMPATIBLE OPT UNIK"] ++
   	set_profile(?mobi_janus,opt_cityzi)++
           reset_imsi_unik()++
           [{title, "<center>#### Option - Unik Plan Classique Seconde ####</center>"},
            "Test premiere page",
            {ussd2,
             [{send, ?CODE_BONS_PLANS},
             {expect,".*6:Option Cityzi.*"},
             {send, "6"},
             {expect, ".*Attention, si vous supprimez votre option Cityzi.*"}]
             }]++
           test_util_of:close_session()++

   	[ "TEST UNIK MOBICARTE MOBILE UNIK DECLINAISON DCL_NUM=0 OPT NOT ACT "]++
   	set_profile(?mobi,plan_sec)++
   	set_imsi_unik()++
   	[{title, "<center>#### Option - Unik Plan Classique Seconde ####</center>"},
   	 "Test premiere page",
   	 {ussd2,
   	  test_clas_plan()
   	  }]++
   	test_util_of:close_session()++

   	set_profile(?mobi,plan_sec_v2)++
   	set_imsi_unik()++
   	[{title, "<center>#### Option - Unik Plan Classique Seconde V2 ####</center>"},
   	 "Test premiere page",
   	 {ussd2,
   	  test_clas_plan()
   	  }]++

   	["TEST UNIK MOBICARTE MOBILE UNIK DECLINAISON DCL_NUM=m6_prepaid OPT NOT ACT "]++
   	set_profile(?m6_prepaid,pas_d_options)++
   	[ {ussd2,
   	   [
   	    {send, test_util_of:access_code(parent(?autres_options), ?bons_plans,[?recharger])},
   	    {expect,"4:Bons plans appels internationaux.*[^7]"}
   	   ]}]++

   	["TEST UNIK MOBICARTE MOBILE UNIK DECLINAISON DCL_NUM=PSG_mobile OPT NOT ACT "]++
   	set_profile(?PSG_mobile,pas_d_options)++
   	[ {ussd2,
   	   [
   	    {send, test_util_of:access_code(parent(?autres_options), ?bons_plans,[?recharger,?foot_variable_x, ?foot_variable_y])},
   	    {expect,"6:Vos appels internationaux.*[^7]"}
   	   ]}]++

   	["TEST UNIK MOBICARTE MOBILE UNIK DECLINAISON DCL_NUM=click_mobi OPT NOT ACT "]++
   	set_profile(?click_mobi,pas_d_options)++
   	[ {ussd2,
   	   [
   	    {send, test_util_of:access_code(parent(?autres_options), ?bons_plans,[?recharger])},
   	    {expect,"5:Vos appels internationaux.*[^7]"}
   	   ]}]++
   	reset_imsi_unik()++

   	["TEST UNIK MOBICARTE MOBILE  UNIK DECLINAISON DCL_NUM=mobi OPT UNIK ACT "]++
   	set_imsi_unik()++
   	set_profile(?mobi,opt_unik)++
   	[ {ussd2,
   	   [
   	    {send, ?CODE_AUTRES_OPTIONS},
   	    {expect,"Votre option unik est actuellement activee.*Supprimer.*"},
   	    {send,"1"},
   	    {expect,"Merci de confirmer la suppression"},
   	    {send,"2"},
   	    {expect,"La suppression de votre bon plan unik a bien ete prise en compte..*"}
   	   ]}]++

   	["TEST UNIK MOBICARTE MOBILE  UNIK DECLINAISON DCL_NUM=mobi OPT UNIK SUSPEND "]++
   	set_imsi_unik()++
   	set_profile(?mobi,opt_unik)++
 	profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_unik,mobi),opt_info2="S"}])++
   	[ {ussd2,
   	   [
   	    {send, ?CODE_AUTRES_OPTIONS},
   	    {expect,"Votre Option Unik est actuellement inactive..1:Reactiver l'option.2:Supprimer l'option.3:Conditions"},
   	    {send,"1"},
   	    {expect,"Vous allez reactiver l'option Unik pour 3E. Cette option est renouvelee chaque mois a date anniversaire pour 3E par mois"},
   	    {send,"1"},
   	    {expect,"la reactivation de votre bon plan Unik a bien ete prise en compte. 3E ont ete debites de votre compte."}
   	   ]}]++

   	["TEST UNIK MOBICARTE MOBILE  UNIK DECLINAISON DCL_NUM=mobi OPT CITYZI ACT "]++
   	set_imsi_unik()++
   	set_profile(?mobi,opt_cityzi)++
   	[ {ussd2,
   	   [
   	    {send, ?CODE_AUTRES_OPTIONS},
   	    {expect,".*2:Option Cityzi.*"},
   	    {send,"2"},
   	    {expect,"Attention, si vous supprimez votre option Cityzi, vous allez perdre l'acces a vos services Cityzi.*1:Supprimer l'option Cityzi.*"},
   	    {send,"1"},
   	    {expect,"Votre option Cityzi vient d'etre supprimee. Pensez a contacter vos fournisseurs de services Cityzi si necessaire.*"}
   	   ]}]++

 	test_option_cityzi_suspend(?mobi)++
   	test_option_cityzi_suspend(?click_mobi)++
   	test_option_cityzi_suspend(?OM_mobile)++
   	test_option_cityzi_suspend(?m6_prepaid)++
  	test_option_cityzi_suspend(?umobile)++

  	set_profile(?mobi,pas_d_options)++
  	set_imsi_unik()++
  	[ {ussd2,
  	   [
  	    {send, ?CODE_AUTRES_OPTIONS},
  	    {expect,"Pour souscrire au bon plan unik, vous devez etre sur le plan tarifaire classique seconde."}
  	   ]}]++
	test_util_of:close_session()++
	["TEST UNIK MOBICARTE MOBILE  UNIK DECLINAISON DCL_NUM=ADFUNDED OPT CITYZI ACT "]++
        set_imsi_unik()++
        set_profile(?DCLNUM_ADFUNDED,opt_cityzi)++
        [ {ussd2,
           [
            {send, test_util_of:access_code(parent(?autres_options), ?bons_plans,[?recharger,?suivi_conso_plus_menu])},
            {expect,".*[^Autres Options].*"}
           ]}]++
  	reset_imsi_unik()++
	["Test reussi"].

test_option_cityzi_suspend(DCL) ->
    ["TEST OPTION CITYZI - DCL="++integer_to_list(DCL)++" OPT CITYZI SUSPEND -  REACTIVER CITYZI"]++
	set_imsi_unik()++
	case DCL of
	    ?mobi ->
		set_profile(DCL,opt_cityzi);
	    _ ->
		set_profile(DCL,pas_d_options)
	end ++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_cityzi,mobi),opt_info2="S"}])++
        [ {ussd2,
           [
            {send, code_cityzi(DCL)},
            {expect,"Votre Option Cityzi est actuellement inactive.*1:Reactiver l'option Cityzi.*2:Supprimer l'option Cityzi.*8:Precedent.*9:Accueil"},
            {send,"1"},
            {expect,"Votre option Cityzi vient d'etre reactivee pour 2E. Vous pouvez consulter sa date de renouvellement dans le menu suivi conso \\+.*9:Accueil"}
           ]}]++
	test_util_of:close_session()++
	["TEST OPTION CITYZI - DCL="++integer_to_list(DCL)++" OPT CITYZI SUSPEND -  SUPPRIMER CITYZI"]++
	set_imsi_unik()++
	case DCL of
            ?mobi ->
		set_profile(DCL,opt_cityzi);
            _ ->
                set_profile(DCL,pas_d_options)
        end ++
	profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_cityzi,mobi),opt_info2="S"}])++
        [ {ussd2,
           [
	    {send, code_cityzi(DCL)},
            {expect,"Votre Option Cityzi est actuellement inactive.*1:Reactiver l'option Cityzi.*2:Supprimer l'option Cityzi.*8:Precedent.*9:Accueil"},
            {send,"2"},
	    {expect,"Votre option Cityzi vient d'etre supprimee. Pensez a contacter vos fournisseurs de services Cityzi si necessaire.*9:Accueil"}
           ]}]++
	test_util_of:close_session()++
    [].

init_test()->
    profile_manager:create_default(?Uid,"mobi")++
        profile_manager:init(?Uid)++
        profile_manager:set_list_comptes(?Uid,[])++
        profile_manager:set_list_options(?Uid,[#option{top_num=0}]).

set_profile(DCL_NUM, pas_d_options) ->
    profile_manager:set_default_spider(?Uid,config,[])++
	profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_options(?Uid,[#option{top_num=0}])++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?MCLAS}])++
                profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_AT});

set_profile(DCL_NUM, suivi_conso_plus) ->
    profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
	profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_options(?Uid,[#option{top_num=0}])++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?MCLAS}])++
                profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_AT});

set_profile(DCL_NUM, plan_sec) ->
    profile_manager:set_default_spider(?Uid,config,[])++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_options(?Uid,[#option{top_num=0}])++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_SEC}])++
	profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_AT});

set_profile(DCL_NUM, plan_sec_v2) ->
    profile_manager:set_default_spider(?Uid,config,[])++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_options(?Uid,[#option{top_num=0}])++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PTF_CLAS_SEC_V2}])++
        profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_AT});

set_profile(DCL_NUM, unik_cityzi) ->
    profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(opt_unik,mobi)},
					       #option{top_num=svc_options:top_num(opt_cityzi,mobi)}])++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?MCLAS},
					       #compte{tcp_num=svc_options:tcp_num(opt_unik, mobi),
						       unt_num=?EURO,
						       cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),
						       rnv=0,etat=?CETAT_AC,
						       ptf_num=svc_options:ptf_num(opt_unik, mobi)},
					       #compte{tcp_num=svc_options:tcp_num(opt_cityzi, mobi),
						       unt_num=?EURO,
						       cpp_solde=42000,
						       dlv=pbutil:unixtime(),
						       rnv=0,etat=?CETAT_AC,
						       ptf_num=svc_options:ptf_num(opt_cityzi, mobi)}])++
        profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_AT});    
set_profile(DCL_NUM, Option) ->
    profile_manager:set_default_spider(?Uid,config,[suivi_conso_plus])++
        profile_manager:set_dcl(?Uid,DCL_NUM)++
        profile_manager:set_list_options(?Uid,[#option{top_num=svc_options:top_num(Option,mobi)}])++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?MCLAS},
                                               #compte{tcp_num=svc_options:tcp_num(Option, mobi),
                                                       unt_num=?EURO,
                                                       cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),
                                                       rnv=0,etat=?CETAT_AC,
                                                       ptf_num=svc_options:ptf_num(Option, mobi)}])++
        profile_manager:update_user_state(?Uid,{etats_sec,?SETAT_AT}).

set_imsi_unik()->
     [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,test_util_of,
 		    set_env,[pservices_orangef,tac_list,[?IMEI_UNIK]]]}
       ]}].
reset_imsi_unik()->
     [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,test_util_of,
 		    set_env,[pservices_orangef,tac_list,[]]]}
       ]}].
