-module(test_144_nrj_cb).
-export([run/0, online/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../include/ftmtlv.hrl").%Main structures used in OF services
-include("../../ptester/include/ptester.hrl").%USSD simulator
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").%OCF/RDP simulator
-include("profile_manager.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(CODE_SERVICE_MENU,"*144").
-define(Uid, user_nrj_cb).

-define(TXT_NIV1_EP_AC, "Forfait Bloque epuise, il sera renouvele le .*Rechargement complementaire:.*E.*(sans duree de validite).*").
-define(TXT_NIV1_EP_EP, "Forfait epuise, il sera renouvele le .*Pour continuer a appeler, pensez a recharger en appelant gratuitement le 675300.*").
-define(TXT_NIV1_AC_AC, "Forfait Bloque:.*EUR.*(soit.*d'appel).*valable jusqu'au .*Rechargement complementaire:.*EUR.*").

-define(LIST_STATES_TO_TEST,[{?CETAT_AC,"actif"},
                             {?CETAT_EP,"epuise"}
                            ]).
-record(cpte_test,{forf, cpte_princ, cpte_sms, cpte_data, cpte_europe, cpte_maghreb, cpte_afrique}).

-define(IMEI,   "100007XXXXXXX1"). % niv1 : 180 car
						%-define(IMEI,   "100006XXXXXXX2"). % niv2 : 130 car
						%-define(IMEI,   "100005XXXXXXX3"). % niv3 : 64 car
						%-define(IMEI, "35324901XXXXX1").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() -> 
    test_util_of:online(?MODULE,test()).

test()->
    case ?IMEI of
	"100005XXXXXXX3" ->
	    nrj_cb_test_niv3();
	_ ->
       	    nrj_cb_test_bonus(?nrj_cb3,"Mini forfait 30min")++
      	      	nrj_cb_test_bonus(?nrj_cb4,"Mini forfait 45min")++
      	      	nrj_cb_test(?nrj_cb1,?PTF_NEPTUNE_FF1,?C_FORF_NRJ_CB1,"Forfait 90min","forfait")++
      	      	nrj_cb_test(?nrj_cb2,?PTF_NEPTUNE_FF2,?C_FORF_NRJ_CB2,"Forfait 120min","forfait")++
      	      	nrj_cb_test(?nrj_cb3,?PTF_NEPTUNE_FF3,?C_FORF_NRJ_CB3,"Mini forfait 30min","mini")++
      	      	nrj_cb_test(?nrj_cb4,?PTF_NEPTUNE_FF4,?C_FORF_NRJ_CB4,"Mini forfait 45min","mini")++
   	      	test_nrj_cb_sl(?nrj_cb5,?PTF_NRJ_FB_SL2,?C_FORF_NRJ_CB5,"Forfait SL 1h","illimitee")++
   	      	test_nrj_cb_sl(?nrj_cb6,?PTF_NRJ_FB_SL3,?C_FORF_NRJ_CB5,"Forfait SL 1h30","illimitee")++
   	      	test_nrj_cb_sl(?nrj_cb7,?PTF_NRJ_FB_SL4,?C_FORF_NRJ_CB5,"Forfait SL 2h","illimitee")++
		[]
    end ++
	lists:append([test_bonus_in_menu_rechargement(DCL)||
			 DCL<-[?nrj_cb1,
			       ?nrj_cb2,
			       ?nrj_cb3,
			       ?nrj_cb4,
			       ?nrj_cb5,
			       ?nrj_cb6,
			       ?nrj_cb7]])++
	[].

nrj_cb_test_niv3() ->
    nrj_cb_test_niv3_mini_act()++
	nrj_cb_test_niv3_mini_ep()++
	nrj_cb_test_niv3_forfait_act()++
	nrj_cb_test_niv3_forfait_ep()++
	[]
	.

nrj_cb_test_niv3_mini_act() ->
    init_test()++
	modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP, 
					cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
					cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			     ?nrj_cb3,?PTF_NEPTUNE_FF3,?C_FORF_NRJ_CB3) ++
	[
	 {title, "Test NRJ Mobile"},
	 "Cas Actif : DCL Mini forfait 30min",
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,expect_text(niv3_mini_act)}
	  ]}]++
	close_test()
	.

nrj_cb_test_niv3_mini_ep() ->
    init_test()++
	modify_account_state(#cpte_test{forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
					cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			     ?nrj_cb4,?PTF_NEPTUNE_FF4,?C_FORF_NRJ_CB4) ++
	[
	 {title, "Test NRJ Mobile"},
	 "Cas Epuise : DCL Mini forfait 40min",
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,expect_text(niv3_ep)}
	  ]}]++
	close_test()
	.

nrj_cb_test_niv3_forfait_act() ->
    init_test()++
	modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
					cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			     ?nrj_cb1,?PTF_NEPTUNE_FF1,?C_FORF_NRJ_CB1) ++
	[
	 {title, "Test NRJ Mobile"},
	 "Cas Actif : DCL Forfait 90min",
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,expect_text(niv3_forfait_act)}
	  ]}]++
	close_test()
	.

nrj_cb_test_niv3_forfait_ep() ->
    init_test()++
	modify_account_state(#cpte_test{forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
					cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			     ?nrj_cb2,?PTF_NEPTUNE_FF2,?C_FORF_NRJ_CB2) ++
	[
	 {title, "Test NRJ Mobile"},
	 "Cas Epuise : DCL Forfait 120min",
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,expect_text(niv3_ep)}
	  ]}]++
	close_test()
	.


test_bonus_in_menu_rechargement(DCL) ->    
    init_test()++
	profile_manager:set_dcl(?Uid,DCL)++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=1,cpp_solde=10000,etat=?CETAT_AC},
					       #compte{tcp_num=?C_NRJ_MINI_FF_VOIX,cpp_solde=10000,etat=?CETAT_AC},
					       #compte{tcp_num=?C_NRJ_MINI_FF_SMS_MMS,cpp_solde=10000,etat=?CETAT_AC}])++
	profile_manager:set_list_options(?Uid,[#option{top_num=489}])++
	[
	 {title, "Test NRJ bonus"},
	 "Cas Actif : DCL " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,".*"},
	   {send, code_recharge_complementairs(DCL)},
	   {expect,".*"},
	   {send,"2"},
	   {expect,"Internet"}
	  ]}]++
	close_test().

nrj_cb_test_bonus(DCL,Text) ->    
    init_test()++
	profile_manager:set_imei(?Uid,?IMEI)++
	insert(?CETAT_AC,DCL,?PCLAS_V2,?C_OPT_SMS_NRJ_BONUS,10000)++
	[
	 {title, "Test NRJ Mobile Bonus SMS"},
	 "Cas Actif : DCL "++Text,
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,expect_text(menu_mini)},
	   {send, "2"},
	   {expect,expect_text(bonus_sms_act)}
	  ]}]++
	close_test()++
	init_test()++
	profile_manager:set_imei(?Uid,?IMEI)++
	insert(?CETAT_EP,DCL,?PCLAS_V2,?C_OPT_SMS_NRJ_BONUS,10000)++
	[
	 {title, "Test NRJ Mobile Bonus SMS"},
	 "Cas Epuise : DCL "++Text,
	 {ussd2,
	  [
	   {send, ?CODE_SERVICE_MENU++"#"},
	   {expect,expect_text(menu_mini)},
	   {send, "2"},
	   {expect,expect_text(bonus_sms_ep)}
	  ]}]++
	close_test().

insert(Etat,Dcl,Ptf,Tcp,Cpp)->
    profile_manager:set_dcl(?Uid,Dcl)++
        profile_manager:set_list_comptes(?Uid,
                                         [#compte{tcp_num=Tcp,unt_num=?EURO,cpp_solde=Cpp,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=Etat,ptf_num=Ptf}])++
	[].
test_nrj_cb_sl(Dcl,Ptf,Tcp,Text,Type)->
    init_test()++
	test_nrj_cb_sl_ep_ep_ep(Dcl,Ptf,Tcp,Text,Type)++
	test_nrj_cb_sl_ac_ac_ep(Dcl,Ptf,Tcp,Text,Type)++
	test_nrj_cb_sl_ac_ep_ac(Dcl,Ptf,Tcp,Text,Type)++


	test_menu_2(Dcl,Ptf,Tcp,Text)++

	close_test()++
	[].

test_nrj_cb_sl_ep_ep_ep(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test Suivi conso forfait epuise, compte princ epuise, compte sms(mms) epuise: "++Text },
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_"++Type))},
	   {send, "1"},
	   {expect,expect_text(list_to_atom("forfait_ep_"++Type))},
	   {send, "0*"++codeRech(Type)},
	   {expect,expect_text(princ_ep)}
	  ]}].

test_nrj_cb_sl_ac_ac_ep(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test Suivi conso forfait actif, compte princ actif, compte sms(mms) epuise: "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_"++Type))},
	   {send, "1"},
	   {expect,expect_text(list_to_atom("forfait_act_"++Type))},
	   {send, "0*"++codeRech(Type)},
	   {expect,"Recharges classiques.*"},
	   {send,"1"},
	   {expect,expect_text(princ_act)},
	   {send,"0*0*9"},
           {expect,expect_text(menu9)}
	  ]}].

test_nrj_cb_sl_ac_ep_ac(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_AC, cpte_data=?CETAT_EP,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test Suivi conso forfait actif, compte princ epuise, compte sms(mms) actif: "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_"++Type))},
	   {send, "1"},
	   {expect,expect_text(list_to_atom("forfait_act_"++Type))},
	   {send, "0*"++codeRech(Type)},
	   {expect,expect_text(list_to_atom("menu_recharge_"++Type))},
	   {send,"1"},
	   {expect,expect_text(sms_act)}
	  ]}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nrj_cb_test(Dcl,Ptf,Tcp,Text,Type)->
    init_test()++
	suivi_conso_test_ep_ep_ep_ep(Dcl,Ptf,Tcp,Text,Type)++
	suivi_conso_test_ac_ac_ep_ep(Dcl,Ptf,Tcp,Text,Type)++
	suivi_conso_test_ac_ep_ac_ac(Dcl,Ptf,Tcp,Text,Type)++
	suivi_conso_test_ac_ep_ac_ac_ac_ac_ac(Dcl,Ptf,Tcp,Text,Type)++
	test_forf_wap(Dcl,Ptf,Tcp,Text,Type,opt_2mo)++
	test_forf_wap(Dcl,Ptf,Tcp,Text,Type,opt_4mo)++
	test_menu_2(Dcl,Ptf,Tcp,Text)++

	close_test()++
	[].

init_test()->
    profile_manager:create_default(?Uid,"nrj_comptebloque")++
        profile_manager:init(?Uid).
close_test()->
    test_util_of:close_session() .


modify_account_state(#cpte_test{forf=ETAT_CB, cpte_princ=ETAT_CP, cpte_sms=ETAT_SMS, cpte_data=ETAT_DATA,
				cpte_europe=ETAT_EUROPE, cpte_maghreb=ETAT_MAGHREB, cpte_afrique=ETAT_AFRIQUE},Dcl,Ptf,Tcp) ->
    profile_manager:set_dcl(?Uid,Dcl)++
        profile_manager:set_list_comptes(?Uid,
                                         [#compte{tcp_num=Tcp,unt_num=?EURO,cpp_solde=23220,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_CB,ptf_num=Ptf},
                                          #compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=12000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_CP,ptf_num=ptf_num(princ,Dcl)},
					  #compte{tcp_num=?C_OPT_DATA_NRJ,unt_num=?EURO,cpp_solde=50000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_DATA,ptf_num=?PTF_NEPTUNE_DATA},
                                          #compte{tcp_num=?C_OPT_SMS_NRJ,unt_num=?EURO,cpp_solde=23000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_SMS,ptf_num=ptf_num(sms,Dcl)},
					  #compte{tcp_num=?C_NRJ_INT_EUROPE,unt_num=?EURO,cpp_solde=25000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_EUROPE,ptf_num=?PTF_NEPTUNE_ZONES},
					  #compte{tcp_num=?C_NRJ_INT_MAGHREB,unt_num=?EURO,cpp_solde=25000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_MAGHREB,ptf_num=?PTF_NEPTUNE_ZONES},
					  #compte{tcp_num=?C_NRJ_INT_AFRIQUE,unt_num=?EURO,cpp_solde=25000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=ETAT_AFRIQUE,ptf_num=?PTF_NEPTUNE_ZONES}
					 ])++
	profile_manager:set_imei(?Uid,?IMEI)++
	[].

expect_text(menu_recharge_mini)->
    "Recharges MMS.*Recharges surf";
expect_text(menu_recharge_forfait)->
    ".*Recharges MMS.*Recharges surf";

expect_text(menu_recharge_illimitee)->
    "Recharges MMS";

expect_text(menu_wap_forfait)->
    "1:Forfait Bloque SMS illimites.*"
        "2:Rechargements complementaires.*"
	"3:Forfait surf";

expect_text(menu_wap_forfait_ep)->
    "1:Forfait Bloque SMS illimites.*"
	"2:Rechargements complementaires.*";

expect_text(menu_wap_mini)->
    "1:Mini Bloque.*"
	"2:Bonus 100 SMS.*"
	"3:Rechargements complementaires.*"
        "4:Forfait surf";

expect_text(menu_wap_mini_ep)->
    "1:Mini Bloque.*"
        "2:Bonus 100 SMS.*"
        "3:Rechargements complementaires.*";

expect_text(menu_forfait)->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    "Bienvenue sur votre info conso.*"
		"1:Forfait Bloque.*"
		"2:Rechargements complementaires.*";
	_->
	    "Bonjour et bienvenue sur votre info conso NRJ Mobile.*"
		"1:Forfait Bloque.*"
		"2:Rechargements complementaires.*"
		"9:Menu.*"
    end;

expect_text(menu_illimitee)->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    "Bienvenue sur votre info conso.*"
		"1:Forfait Bloque.*"
		"2:Rechargements complementaires.*"
		"9:Menu.*";
	_->
	    "Bonjour et bienvenue sur votre info conso NRJ Mobile.*"
		"1:Forfait Bloque.*"
		"2:Rechargements complementaires.*"
		"9:Menu.*"
    end;

expect_text(menu_mini)->
    "Bienvenue sur votre info conso NRJ Mobile.*"
	"1:Mini Bloque.*"
        "2:Bonus 100 SMS.*"
	"3:Rechargements complementaires.*";   

expect_text(bonus_sms_act) ->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    "Bonus SMS : il vous reste .*EUR de credit SMS Bonus, soit .*SMS, valable jusqu'au .* inclus.";
        _ ->
	    "Bonus SMS : il vous reste .*EUR de credit SMS Bonus, soit .*SMS metropolitains, valable jusqu'au .* inclus."
    end;

expect_text(bonus_sms_ep) ->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    "Bonus SMS epuise. Pour continuer a envoyer des SMS, pensez a recharger en appelant gratuitement le 675300.";
        _ ->
	    "Votre bonus SMS est epuise. Il sera renouvele le .*. Pour continuer a envoyer des SMS, pensez a recharger en appelant gratuitement le 675300."
    end;

expect_text(niv3_mini_act) ->
    "Mini Bloque : .*E et .*SMS jusqu'au .* inclus.";
expect_text(niv3_forfait_act) ->
    "Forfait: .*E jusqu'au .* - Rech complementaire: .*E.";
expect_text(niv3_ep) ->
    "Credit epuise. Rechargez en appelant gratuitement le 675300.";

expect_text(forfait_act_mini) ->
    "Mini Bloque : il vous reste .*EUR, soit jusqu'a .* d'appel, valable jusqu'au .* inclus.";
expect_text(forfait_act_forfait) ->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    "Forfait Bloque SMS illimites: il vous reste .*EUR, soit jusqu'a .* d'appels, valable jusqu'au .* 1:-->";
        _ ->
	    "Forfait Bloque SMS illimites : il vous reste .*EUR, soit jusqu'a .* d'appels, valable jusqu'au .* inclus."
    end;

expect_text(forfait_act_illimitee) ->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    "Forfait Bloque: il vous reste .*EUR, soit jusqu'a .* d'appel, valable jusqu'au .* inclus";
        _ ->
	    "Forfait Bloque SMS et WEB illimites : il vous reste .*, soit jusqu'a .* d'appels, valable jusqu'au.* inclus"
    end;


expect_text(forfait_ep_mini) ->
    case ?IMEI of
	"100006XXXXXXX2" ->
	    "Forfait epuise. Il sera renouvele le .*. Pour continuer a appeler, rechargez en appelant gratuitement le 675300.";
	_ ->
	    "Votre Mini Bloque est epuise. Il sera renouvele le .*. Pour continuer .*, rechargez en appelant gratuitement le 675300.*"
    end;
expect_text(forfait_ep_forfait) ->
    case ?IMEI of
	"100006XXXXXXX2" ->
	    "Forfait epuise. Il sera renouvele le .*. Pour continuer a appeler, rechargez en appelant gratuitement le 675300.";
	_ ->
	    "Votre Forfait Bloque est epuise. Il sera renouvele le .*. Pour continuer .*, pensez a recharger en appelant gratuitement le 675300.*"
    end;

expect_text(forfait_ep_illimitee) ->
    case ?IMEI of
	"100006XXXXXXX2" ->
	    "Forfait epuise. Il sera renouvele le .*. Pour continuer a appeler, rechargez en appelant gratuitement le 675300.";
	_ ->
	    "Votre Forfait Bloque est epuise. Il sera renouvele le .*. Pour continuer .*, pensez a recharger en appelant gratuitement le 675300.*"
    end;

expect_text(princ_act) ->
    case ?IMEI of
        "100006XXXXXXX2" ->
	    ".*EUR de credit de rechargement complementaire, soit jusqu'a .* d'appel "
		"\\(credit sans duree de validite\\)";
        _ ->
	    ".*EUR de credit de rechargement complementaire.*"
    end;

expect_text(princ_ep) ->
    "Vous n'avez pas effectue de rechargement complementaire. Rechargez en appelant gratuitement le 675300..*";
expect_text(menu9) ->
    ".*144.*1:Actu NRJ Mobile.*00:Info conso.*";
expect_text(sms_act) ->
    "Vous disposez de .*EUR de credit .* metropolitains non surtaxes. Ce credit est sans duree de validite.";
expect_text(data_act) ->
    "Vous disposez de .*de credit surf. Ce credit est sans duree de validite.";
expect_text(europe_act) ->
    "Vous disposez de .*E de credit pour appeler vers l'Europe. Ce credit est sans duree de validite.*";
expect_text(maghreb_act) ->
    "Vous disposez de .*E de credit pour appeler vers le Maghreb. Ce credit est sans duree de validite.*";
expect_text(afrique_act) ->
    "Vous disposez de .*E de credit pour appeler vers l'Afrique. Ce credit est sans duree de validite.*";
expect_text(wap)->
    "Vous disposez de .* E de credit sur votre forfait surf mensuel, utilisable jusqu'au .* inclus".

suivi_conso_test_ep_ep_ep_ep(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test Suivi conso forfait epuise, compte princ epuise, compte data epuise, compte sms(mms) epuise: "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_"++Type))},
	   {send, "1"},
	   {expect,expect_text(list_to_atom("forfait_ep_"++Type))},
	   {send, "0*"++codeRech(Type)},
	   {expect,expect_text(princ_ep)}
	  ]}].

suivi_conso_test_ac_ep_ac_ac(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_AC, cpte_data=?CETAT_AC,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test Suivi conso forfait actif, compte princ epuise, compte data actif, compte sms(mms) actif: "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_"++Type))},
	   {send, "1"},
	   {expect,expect_text(list_to_atom("forfait_act_"++Type))},
	   {send, "0*"++codeRech(Type)},
	   {expect,expect_text(list_to_atom("menu_recharge_"++Type))},
	   {send,"1"},
	   {expect,expect_text(sms_act)},
           {send,"0*0*"++codeRech(Type)++"2"},
	   {expect,expect_text(data_act)}
	  ]}].

suivi_conso_test_ac_ep_ac_ac_ac_ac_ac(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_AC, cpte_data=?CETAT_AC,
				    cpte_europe=?CETAT_AC, cpte_maghreb=?CETAT_AC, cpte_afrique=?CETAT_AC},
			 Dcl,Ptf,Tcp) ++
	[
         {title, "Test Suivi conso forfait actif, compte princ epuise, compte data actif, compte sms(mms) actif, "
	  "compte europe actif, compte maghreb actif, compte afrique actif : "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
           {expect,expect_text(list_to_atom("menu_"++Type))},
           {send, "1"},
           {expect,expect_text(list_to_atom("forfait_act_"++Type))},
           {send, "0*"++codeRech(Type)},
           {expect,expect_text(list_to_atom("menu_recharge_"++Type))},
           {send,"1"},
           {expect,expect_text(sms_act)},
           {send,"0*0*"++codeRech(Type)++"2"},
           {expect,expect_text(data_act)},
	   {send, "0*0*" ++ codeRech(Type)++"3"},
	   {expect,expect_text(europe_act)},
	   {send, "0*0*" ++ codeRech(Type)++"4"},
           {expect,expect_text(maghreb_act)},
	   {send, "0*0*" ++ codeRech(Type)++"5"},
           {expect,expect_text(afrique_act)}
	  ]}].

suivi_conso_test_ac_ac_ep_ep(Dcl,Ptf,Tcp,Text,Type)->
    modify_account_state(#cpte_test{forf=?CETAT_AC, cpte_princ=?CETAT_AC, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test Suivi conso forfait actif, compte princ actif, compte data epuise, compte sms(mms) epuise: "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_"++Type))},
	   {send, "1"},
	   {expect,expect_text(list_to_atom("forfait_act_"++Type))},
	   {send, "0*"++codeRech(Type)},
	   {expect,"Recharges classiques.*"},
	   {send,"1"},
	   {expect,expect_text(princ_act)},
	   {send,"0*0*9"},
           {expect,expect_text(menu9)}
	  ]}].

test_forf_wap(Dcl,Ptf,Tcp,Text,Type,Opt_WAP)->
    profile_manager:set_dcl(?Uid,Dcl)++
        profile_manager:set_list_comptes(?Uid,
                                         [#compte{tcp_num=Tcp,unt_num=?EURO,cpp_solde=23220,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=?CETAT_AC,ptf_num=Ptf},
                                          #compte{tcp_num=?C_FORF_NRJ_DATA,unt_num=?EURO,cpp_solde=23000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=?CETAT_EP,ptf_num=?PTF_NEPTUNE_DATA}])++
	profile_manager:set_list_options(?Uid,[#option{top_num=386}])++
        profile_manager:set_imei(?Uid,?IMEI)++

        [{title, "Test Suivi conso forfait(Cpte Forf WAP epuise) "++Text++text_wap(Opt_WAP)},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
           {expect,expect_text(list_to_atom("menu_wap_"++Type++"_ep"))}
          ]}]++

	profile_manager:set_dcl(?Uid,Dcl)++
        profile_manager:set_list_comptes(?Uid,
                                         [#compte{tcp_num=Tcp,unt_num=?EURO,cpp_solde=23220,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=?CETAT_AC,ptf_num=Ptf},
                                          #compte{tcp_num=?C_FORF_NRJ_DATA,unt_num=?EURO,cpp_solde=23000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,etat=?CETAT_AC,ptf_num=?PTF_NEPTUNE_DATA}])++
	[{title, "Test Suivi conso forfait "++Text++text_wap(Opt_WAP)},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
	   {expect,expect_text(list_to_atom("menu_wap_"++Type))},
	   {send, codeRech(wap,Type)},
	   {expect,expect_text(wap)},
           {send,"0*9"},
           {expect,expect_text(menu9)}
	  ]}].

codeRech("mini")->
    "3";
codeRech("illimitee")->
    "2";
codeRech("forfait") ->
    "2".

codeRech(wap,"mini")->
    "4";
codeRech(wap,"forfait") ->
    "3".

top_num(opt_2mo) ->
    386;
top_num(opt_4mo) ->
    383.

text_wap(opt_2mo) ->
    " forfait WAP 2MO";
text_wap(opt_4mo) ->
    " forfait WAP 4MO".

ptf_num(princ,Dcl)
  when Dcl == ?nrj_cb3; Dcl ==?nrj_cb4 ->
    ?PTF_NEPTUNE_CB_PP;
ptf_num(princ,Dcl)
  when Dcl == ?nrj_cb5; Dcl == ?nrj_cb6; Dcl == ?nrj_cb7 ->
    ?PTF_NRJ_FB_SL1;
ptf_num(princ,_) ->
    ?PTF_NEPTUNE_CB_PRINC;
ptf_num(sms,Dcl) 
  when Dcl == ?nrj_cb3; Dcl ==?nrj_cb4 ->
    ?PTF_NEPTUNE_MINI_SMS;
ptf_num(sms,_) ->
    ?PTF_NEPTUNE_SMS.

test_menu_2(Dcl,Ptf,Tcp,Text)->
    modify_account_state(#cpte_test{forf=?CETAT_EP, cpte_princ=?CETAT_EP, cpte_sms=?CETAT_EP, cpte_data=?CETAT_EP,
				    cpte_europe=?CETAT_EP, cpte_maghreb=?CETAT_EP, cpte_afrique=?CETAT_EP},
			 Dcl,Ptf,Tcp) ++
        [
         {title, "Test menu 2 "++Text},
         {ussd2,
          [
           {send, ?CODE_SERVICE_MENU++"*#"},
           {expect,"9:Menu"},
           {send, "9"},
           {expect,expect_text(menu9)},
           {send, "2"},
           {expect,"Avec NRJ Mobile, beneficiez de tarifs avantageux pour vos appels vers l'international et depuis l'etranger.*1:Suite.*0:Retour.*9:Menu"},
           {send, "1"},
           {expect,"Les destinations sont classees en 3 zones tarifaires. Zone 1 : Europe / Zone 2 : Maghreb, Amerique du Nord / Zone 3 : reste du monde et TOM.*1:Suite.*0:Retour.*9:Menu"},
	   {send, "1"},
           {expect,"Appels emis depuis et vers la zone Europe ou les DOM.*0:Retour.*9:Menu"},
	   {send, "1"},
           {expect,"Appels emis depuis et vers la zone 2 = 1,49E/mn, recu = 0,70E/mn sauf USA = 1,05E/mn.*1:Suite.*0:Retour.*9:Menu"},
           {send, "1"},
           {expect,"Appels emis depuis et vers la zone 3 = 2,50E/mn, recu = 1,05E/mn..Reception d'un SMS gratuite.*Envoi = 0,1315 E/SMS .zone 1., 0,30E/SMS .zone 2 et 3.*0:Retour.*9:Menu"}
	  ]}].
code_recharge_complementairs(DCL)->
    case DCL of
        X when X==90;X==91;X==125;X==126;X==127->"2";
        _->"3"
    end.
