-module(test_123_mobi_roaming).
-compile(export_all).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("profile_manager.hrl").

-define(Uid, user_roaming_mobi).
-define(VLR,    "32495000000"). %%Belgique Camel Zone
-define(VLR_F,    "33495000000").
-define(DIRECT_CODE, "#123*#").
-define(CODE_FROM_F, "#123*2*4*5#").
-define(CODE, "#123*#").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%  Roaming service is an extension of #123# for users in a camel country.
%%  In order for this service to work, we need to pass a vlr_number
%%  in the SMPP message.
%%  As we cannot do this using ptester, we use our own shortcut to 
%%  create the connection
%%  Decoding of vlr_number via smppasn_server is not tested here 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TEXTS Options, Menus, Incompatibilities.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
first_page_fr()->
    "Bienvenue sur vos services a l'etranger.*"
	"1:Bons plans tarifs.*2:Utiliser votre messagerie"
	".*3:Quel tarif dans quel pays.*".
first_page_fr(?CODE_FROM_F)->
    first_page_fr();
first_page_fr(_) ->
    "Vos services a l'etranger.*"
	"1:Bons plans tarifs.*"
	"2:Recharger.*"
	"3:Suivi conso.*"
	"4:Utiliser votre messagerie.*"
	"5:Les tarifs a l'etranger.*"
	"6:Page accueil France".
code_mention_legale(?CODE_FROM_F) -> "45111*7";
code_mention_legale(_) -> "1117".

first_page_abroad()->
    "Vos services a l'etranger.*"
	"1:Bons plans tarifs.*2:Recharger.*3:Suivi conso"
	".*4:Utiliser votre messagerie"
	".*5:Les tarifs a l'etranger.*6:Page accueil France".


reduire_facture_fr(DCL,1)
  when DCL==?mobi ->   
      "1:Communiquer depuis la France vers l'etranger et l'outre mer.*"
      "2:Communiquer depuis l'etranger et l'outre mer.*"
      "3:Acceder a Internet depuis l'etranger.*".

reduire_facture_fr(1)->
    reduire_facture_fr(?mobi,1);
reduire_facture_fr(2)->
    "1:pass 20 minutes vers le Maghreb.*9:Accueil".


messagerie_vocale()->
    "Pour consulter votre messagerie vocale "
	": composez le 888 depuis votre mobile ou le . .ou 00."
	" 33608080808 depuis votre mobile ou.*".

opt_appels_recus_text(1)->
    "A l'etranger pour les fetes . Du 22 decembre 2007 au 2 janvier 2008, "
	"Orange vous offre 1h d'appels recus en zone Europe de 19 h a minuit .";
opt_appels_recus_text(2) ->
    "Vous allez souscrire a l'option appels recus Kdo, l'option est gratuite "
	"et sera valable du 22/12/2007 au 02/01/2008 inclus.";
opt_appels_recus_text(3) ->
    "Vous avez souscrit a l'option appels recus Kdo, vous avez 60 min d'appels"
	" recus offertes de 19h a minuit du 22/12/2007 au 02/01/2008.".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


top_num(Opt) -> profile_manager:rpc(svc_option_manager,get_top_num,[Opt,mobi]).
tcp_num(Opt) -> profile_manager:rpc(svc_option_manager,get_tcp_num,[Opt,mobi]).
ptf_num(Opt) -> profile_manager:rpc(svc_option_manager,get_ptf_num,[Opt,mobi]).

set_past_commercial_date() ->
    lists:append([test_util_of:set_past_commercial_date(Opt,mobi) || Opt <- 
									[
									 opt_10min_europe,
									 opt_pass_voyage_15min_europe,
									 opt_pass_voyage_30min_europe,
									 opt_pass_voyage_60min_europe,
									 opt_pass_voyage_15min_maghreb,
									 opt_pass_voyage_30min_maghreb,
									 opt_pass_voyage_60min_maghreb,
									 opt_pass_voyage_15min_rdm,
									 opt_pass_voyage_30min_rdm,
									 opt_pass_voyage_60min_rdm,
									 opt_pass_internet_int_jour_2E,
									 opt_pass_internet_int_jour_5E
									]]).


online() ->
    test_util_of:online(?MODULE,test()).


test() ->
    %%Test title
    [{title, "Test suite for Selfcare Roaming MOBI: CAMEL ZONE"}] ++		
	%% Initialisation of the accounts for the different IMSIs
	%% used in the tests
	roaming_from_abroad()++
	roaming_from_france(?mobi)++
	%%Session closing
	test_util_of:close_session() ++
	["Test reussi"] ++
	[].

roaming_from_abroad()->
    ["########## TEST ROAMING FROM ABROAD ###############"] ++
	test_menu(?mobi,from_abroad)++
	test_subscription(?mobi,?CODE,?VLR)++
	test_option_activated(?mobi,?CODE,?VLR)++
	test_solde_insuff(?mobi,?CODE,?VLR)++
	test_incompatibility_option(?mobi,?CODE,?VLR)++
 	test_infos_tarifs(1,?DIRECT_CODE,?VLR)++
	[].
roaming_from_france(DCL)->
    ["########## TEST ROAMING FROM FRANCE ###############"] ++
	test_menu(?mobi,from_france)++
	test_subscription(?mobi,?CODE_FROM_F,?VLR_F)++
	test_option_activated(?mobi,?CODE_FROM_F,?VLR_F)++
	test_solde_insuff(?mobi,?CODE_FROM_F,?VLR_F)++
	test_incompatibility_option(?mobi,?CODE_FROM_F,?VLR_F)++
	test_infos_tarifs(1,?CODE_FROM_F,?VLR_F)++
	[].


test_menu(DCL,from_abroad)->
    BundleA_no_balance=#spider_bundle{
        priorityType="A",
        restitutionType="FORF",
        bundleType="0003",
        bundleDescription="forfait",
        credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
            #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
    },
    ["MOBI Profile connecting from abroad - #123# Main Menu"]++

        empty_data()++
        init(?VLR) ++
        profile_manager:set_bundles(?Uid,[BundleA_no_balance])++
        profile_manager:set_list_comptes(?Uid,[])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
        [{ussd2,
          [
           {send, ?DIRECT_CODE},
           {expect,first_page_abroad()},
           {send, "1"},
           {expect,".*"},
           {send, "9"},
           {expect,".*"},
           {send, "2"},
           {expect,"1:par recharge mobicarte.*2:par carte bancaire"},
           {send, "9"},
           {expect,".*"},
           {send, "3"},
           {expect,"Au ../.. a .*:.*:epuise.*Renouvele:../.."},
           {send, "8"},
           {expect,".*"},
           {send, "4"},
           {expect,messagerie_vocale()}
          ]
         }
        ];
test_menu(DCL,from_france) ->
	         BundleA_no_balance=#spider_bundle{
                                priorityType="A",
                                restitutionType="FORF",
                                bundleType="0003",
                                bundleDescription="forfait",
                                credits=[#spider_credit{name="standard", unit="TEMPS", value="2h"},
                                                 #spider_credit{name="rollOver", unit="TEMPS", value="1h30min50s"}]
                                },
    ["MOBI Profile connecting from france - #123# Main Menu"]++
	empty_data()++
	init(?VLR_F)++
	profile_manager:set_bundles(?Uid,[BundleA_no_balance])++
        profile_manager:set_list_comptes(?Uid,[])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
	[{ussd2, 
	  [
	   {send, ?CODE_FROM_F},
	   {expect,first_page_fr()},
	   {send, "1"},
	   {expect,".*"},
	   {send, "9"},
           {expect,".*"},
           {send, "2"},
	   {expect,"1:par recharge mobicarte.*2:par carte bancaire"},
	   {send, "9"},
           {expect,".*"},
           {send, "1"},
	   {expect,"Au ../.. a .*:.*:epuise.*Renouvele:../.."}
	  ]
	 }
	].

test_infos_tarifs(Phase,CODE,VLR)->
    ["TEST ROAMING INFO TARIFS"]++
	test_tarifs_voix(Phase,CODE,VLR)++
	test_tarifs_smsmms(Phase,CODE,VLR)++
	test_tarifs_connexions(Phase,CODE,VLR)++
	[].


test_subscription(DCL,Code,VLR)->
    ["TEST SUBSCRIPTION FROM FRANCE"]++
	set_past_commercial_date()++
	lists:append([test_pass_voyage(Opt,DCL,Code,VLR)||Opt<-
							      [opt_10min_europe,
							       opt_pass_voyage_15min_europe,
							       opt_pass_voyage_30min_europe,
							       opt_pass_voyage_60min_europe,
							       opt_pass_voyage_15min_maghreb,
							       opt_pass_voyage_30min_maghreb,
							       opt_pass_voyage_60min_maghreb,
							       opt_pass_voyage_15min_rdm,
							       opt_pass_voyage_30min_rdm,
							       opt_pass_voyage_60min_rdm
							       
							      ]])++
	lists:append([test_internet(Opt,DCL,VLR,Code) || Opt <- 
							     [opt_pass_internet_int_jour_2E,
							      opt_pass_internet_int_jour_5E
							     ]
							    ])++
	case Code of
	    ?CODE_FROM_F ->
		test_pass_minutes(opt_europe,DCL,Code,VLR)++
		    test_pass_minutes(opt_maghreb,DCL,Code,VLR)++
		    test_pass_minutes(opt_pass_dom,DCL,Code,VLR);
	    _ ->
		[]
	end++
	["OK"].

test_pass_voyage(Opt,DCL,Code,VLR) ->
    ["####TEST SUBSCRIPTION ### DCL "++text(DCL) ++ ", option "++ atom_to_list(Opt)]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
	test_util_of:set_present_commercial_date(Opt,mobi)++
        [{ussd2,
          [
           {send, Code},
           {expect,first_page_fr(Code)},
           {send, "1"},
           {expect,".*"},
           {send, code_option(Opt, VLR)},
           {expect,".*"},
           {send, "1"},
           {expect,".*"},
           {send, "1"},
           {expect,".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"}
          ]
         }
        ]++
    ["####TEST MENTION LEGALES### DCL "++text(DCL) ++ ", option "++ atom_to_list(Opt)]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
        [{ussd2,
          [
           {send, Code},
           {expect,first_page_fr(Code)},
           {send, "1"},
           {expect,".*"},
           {send, code_option(Opt,VLR)},
           {expect,".*"},
           {send, code_conditions(Opt)},
           {expect,".*"},
           {send, "1"},
           {expect,".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"}
          ]
         }
        ]++
	test_util_of:reset_commercial_date(Opt,mobi)++
	test_util_of:close_session().

test_internet(Opt,DCL,VLR,CODE) ->
    ["Connect to #123# - MOBI, roaming -> SOUSCRIPTION REUSSIE A L'OPTION PASS INTERNET INTERNATIONAL"]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
	set_past_commercial_date()++
	test_util_of:set_present_commercial_date(Opt,mobi)++
	["####TEST Subscription###\n ", "option "++ atom_to_list(Opt)]++
	[{ussd2,
	  [
	   {send, CODE},
	   {expect, first_page_fr(CODE)},
	   {send, "1"},
	   {expect, ".*"},
	   {send, code_option(Opt,VLR)},
	   {expect,".*"},
           {send, "1"},
           {expect,".*"},
           {send, "1"},
           {expect,".*"},
	   {send, "1"},
	   {expect, ".*"}
	   ]}
	 ]++
	["####TEST MENTION LEGALES###\n ", "option "++ atom_to_list(Opt)]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
        [{ussd2,
          [
           {send, CODE},
	   {expect, first_page_fr(CODE)},
           {send, "1"},
           {expect,".*"},
	   {send, code_option(Opt,VLR)},
           {expect,".*"},
           {send, "7"},
           {expect,".*"},
           {send, "1"},
           {expect,".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"}
          ]
         }
        ]++
	test_util_of:reset_commercial_date(Opt,mobi)++
	test_util_of:close_session().

test_pass_minutes(opt_europe=Opt,DCL,Code,VLR) ->
    ["####MOBI Profile connecting from France - Pass 25 minutes vers l'Europe ###"]++
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
	test_util_of:set_present_commercial_date(Opt,mobi)++
	[{ussd2, 
	  [
	   {send, Code},
	   {expect,first_page_fr(Code)},
	   {send, "1"},	  
	   {expect,reduire_facture_fr(DCL,1)},
	   {send, "1"},
	   {expect,"l'Europe"},
	   {send, "111"},
	   {expect,"l'Europe"},
	   {send, "9"},
	   {expect,".*"}
	  ]
	 }
	]++
	test_util_of:reset_commercial_date(Opt,mobi);

test_pass_minutes(opt_maghreb=Opt,DCL,Code,VLR) ->	
    ["####MOBI Profile connecting from France - Pass 20 minutes vers le Maghreb ###"]++
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
	test_util_of:set_present_commercial_date(Opt,mobi)++
	[{ussd2,
	  [
	   {send, Code},
	   {expect,first_page_fr(Code)},
	   {send, "1"},
	   {expect,reduire_facture_fr(DCL,1)},
	   {send, "1"},
	   {expect,"le Maghreb"},
	   {send, "211"},
	   {expect,"le Maghreb"},
	   {send, "9"},
	   {expect,".*"}
	  ]
	 }
	]++
	test_util_of:reset_commercial_date(Opt,mobi)++
	test_util_of:close_session();

test_pass_minutes(opt_pass_dom=Opt,DCL,Code,VLR) ->	
    ["####MOBI Profile connecting from France - Pass 30 minutes vers les DOM ###"]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
        profile_manager:set_list_options(?Uid,[])++
	test_util_of:set_present_period_for_test(commercial_date,[opt_pass_dom])++	
	[{ussd2,
	  [
	   {send, Code},
	   {expect,first_page_fr(Code)},
	   {send, "11311"},
	   {expect, "Mentions legales"},
	   {send, "7"},
	   {expect, "Credit de communication valable 14 jours depuis la France metropolitaine"},
	   {send, "1"},
	   {expect, "vers la Guadeloupe, la Martinique, l'ile de la Reunion, Mayotte"},
	   {send, "1"},
	   {expect, "Saintes, Saint-Martin, la Guyane et Saint-Pierre-et-Miquelon avec le pass 30 minutes"},
	   {send, "1"},
           {expect, "sur les tarifs catalogue \\(cf. fiche tarifaire\\)"},
	   {send, "1"},
           {expect, "decomptees du compte principal au tarif en vigueur"},
	   {send, "1"},
	   {expect, "Pass incompatible avec les pass voyage"},
	   {send, "1"},
	   {expect,"Vous allez souscrire au pass 30 minutes vers les DOM pour 10E."},
	   {send, "1"},
	   {expect,"Validation.*Vous avez souscrit au pass 30 minutes"}
	  ]
	 }
	]++test_util_of:close_session().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%     Test incompability option - Roaming from France %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_incompatibility_option(DCL,Code,VLR)->
    ["TEST INCOMPABILITY OPTION"]++
	set_past_commercial_date()++
	lists:append([test_incompatibility(Opt,DCL,Code,VLR) || Opt <- [opt_10min_europe,
									opt_pass_voyage_15min_europe,
									opt_pass_voyage_30min_europe,
									opt_pass_voyage_60min_europe,
									opt_pass_voyage_15min_maghreb,
									opt_pass_voyage_30min_maghreb,
									opt_pass_voyage_60min_maghreb
								       ]
								   ])++
	["OK"].

test_incompatibility(Opt,DCL,Code,VLR) ->    
    ["####MOBI from France - option: "++atom_to_list(Opt)++" ###"]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=?C_BONS_PLANS,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=tcp_num(opt_europe),unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=?C_ROAMING_OUT,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                              #compte{tcp_num=?C_ROAMING_IN,unt_num=?EURO,cpp_solde=50000,
                                                      dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
	case Opt of 
	    opt_10min_europe -> 		
		profile_manager:set_list_options(?Uid,[#option{top_num=top_num(opt_10min_europe_carte_jump)}]);
	    _ ->
		profile_manager:set_list_options(?Uid,[#option{top_num=top_num(opt_pass_voyage_15min_rdm)},
						       #option{top_num=top_num(opt_pass_voyage_30min_rdm)},
						       #option{top_num=top_num(opt_pass_voyage_60min_rdm)}])
	end++	
	test_util_of:set_present_commercial_date(Opt,mobi)++
	[{ussd2, 
	  [{send, Code},
	   {expect, first_page_fr(Code)},
	   {send, "1"},
	   {expect,".*"},
	   {send, code_option(Opt,VLR)},
	   {expect, ".*"},
	   {send, "11"},
	   {expect,"Cette option n'est pas compatible avec"}
	  ]
	 }
	]++
	test_util_of:reset_commercial_date(Opt,mobi)++
	test_util_of:close_session().


test_option_activated(DCL,Code,VLR)->
    ["TEST OPTION ALREADY ACTIVATED"]++
	set_past_commercial_date()++
	lists:append([test_option_activated(Opt,DCL,VLR,Code) || Opt <- [ opt_10min_europe,
									  opt_pass_voyage_15min_europe,
									  opt_pass_voyage_30min_europe,
									  opt_pass_voyage_60min_europe,
									  opt_pass_voyage_15min_maghreb,
									  opt_pass_voyage_30min_maghreb,
									  opt_pass_voyage_60min_maghreb,
									  opt_pass_voyage_15min_rdm,
									  opt_pass_voyage_30min_rdm,
									  opt_pass_voyage_60min_rdm,
									  opt_pass_internet_int_jour_2E,
									  opt_pass_internet_int_jour_5E
									 ]]).

test_option_activated(Opt,DCL,VLR,Code) ->
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=?C_BONS_PLANS,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=tcp_num(opt_europe),unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=?C_ROAMING_OUT,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2},
                                              #compte{tcp_num=?C_ROAMING_IN,unt_num=?EURO,cpp_solde=50000,
                                                      dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
	test_util_of:set_present_commercial_date(Opt,mobi)++
        profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
	["\n########### Opt: "++atom_to_list(Opt)]++
	[
	 {ussd2,
	  [
	   {send, Code},
	   {expect, first_page_fr(Code)},
	   {send, "1"},
	   {expect, ".*"},
	   {send, code_option(Opt,VLR)},
	   {expect,".*"},
	   case Opt of
	       Opt when Opt==opt_pass_internet_int_jour_2E;
			Opt==opt_pass_internet_int_jour_5E ->
		   {send, "1"};
	       _ ->       
		   {send, "11"}
	   end,
	   {expect,"Vous avez deja souscrit a cette option."}
	  ]
	 }]++test_util_of:reset_commercial_date(Opt,mobi)++
	test_util_of:close_session().

test_solde_insuff(DCL,Code,VLR)->
    ["#### "]++
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=1000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_EP,ptf_num=?PCLAS_V2},
					       #compte{tcp_num=?C_BONS_PLANS,unt_num=?EURO,cpp_solde=1000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_EP,ptf_num=?PCLAS_V2},
					       #compte{tcp_num=tcp_num(opt_europe),unt_num=?EURO,cpp_solde=1000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_EP,ptf_num=?PCLAS_V2},
					       #compte{tcp_num=?C_ROAMING_OUT,unt_num=?EURO,cpp_solde=1000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_EP,ptf_num=?PCLAS_V2},
                                              #compte{tcp_num=?C_ROAMING_IN,unt_num=?EURO,cpp_solde=1000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_EP,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,DCL)++
 	test_util_of:set_present_period_for_test(commercial_date,[opt_pass_dom])++
	case Code of
	    ?CODE_FROM_F ->
 	[
 	 "####MOBI from France - OPT PASS 30 MINS VERS LES DOM ### DCL "++text(DCL),
 	 {ussd2, 
 	  [{send, Code},
 	   {expect,first_page_fr(Code)},
 	   {send, "1"},
 	   {expect,reduire_facture_fr(DCL,1)},
 	   {send, "13"},
 	   {expect,"pass 30 minutes vers les DOM"},
 	   {send,"111"},
 	   {expect,"pas d'assez de credit"}       
 	  ]
 	 }
 	]++
	[
	 "####MOBI from France - OPT MAGHREB NOT ENOUGH CREDIT ### DCL "++text(DCL),
	 {ussd2, 
	  [{send, Code},
	   {expect,first_page_fr(Code)},
	   {send, "1"},
	   {expect,reduire_facture_fr(DCL,1)},
	   {send, "12"},
	   {expect,".*"},
	   {send,"11"},
	   {expect,"pas d'assez de credit"}       
	  ]
	 }
	]++
	[
	 "####MOBI from France - OPT EUROPE NOT ENOUGH CREDIT ### DCL "++text(DCL),
	 {ussd2, 
	  [{send, Code},
	   {expect,first_page_fr(Code)},
	   {send, "1"},
	   {expect,reduire_facture_fr(DCL,1)},
	   {send, "11"},
	   {expect,".*"},
	   {send,"11"},
	   {expect,"pas d'assez de credit"}       
	  ]
	 }
	];
	_ -> []
	end
++test_util_of:close_session().

init(VLR) ->
    profile_manager:create_default(?Uid,"mobi")++
        profile_manager:init(?Uid,smpp)++
	test_util_of:set_vlr(VLR).

text(?mobi)-> "mobi";
text(_) -> "UNKNOWED DCL".

test_tarifs_voix(Phase,CODE,VLR) ->
    ["TARIFS VOIX"]++
 	test_voix_europe(default,Phase,CODE,VLR)++
 	lists:append([test_voix_europe(Opt,Phase,CODE,VLR)||
                 Opt<-
                 [
                     opt_pass_voyage_15min_europe,
                     opt_pass_voyage_30min_europe,
                     opt_pass_voyage_60min_europe
 
                 ]])++
 	test_voix_usa_maghreb(default,Phase,CODE,VLR)++
	test_voix_reste_du_monde(default,Phase,CODE,VLR)++
	["OK"].

test_tarifs_smsmms(Phase,CODE,VLR) ->
    ["TARIFS SMS MMS"]++
 	test_smsmms_europe(default,Phase,CODE,VLR)++
 	lists:append([test_smsmms_europe(Opt,Phase,CODE,VLR)||
                 Opt<-
                 [
                     opt_pass_voyage_15min_europe,
                     opt_pass_voyage_30min_europe,
                     opt_pass_voyage_60min_europe
 
                 ]])++
 	test_smsmms_usa_maghreb(default,Phase,CODE,VLR)++
	["OK"].

test_tarifs_connexions(Phase,CODE,VLR) ->   
    ["TARIFS DES CONNEXIONS"]++
 	test_connexions_europe(default,Phase,CODE,VLR)++
  	lists:append([test_connexions_europe(Opt,Phase,CODE,VLR)||
                  Opt<-
                  [
		   opt_pass_internet_int_jour_2E,
                   opt_pass_internet_int_jour_5E,
		   opt_pass_voyage_15min_europe,
		   opt_pass_voyage_30min_europe,
		   opt_pass_voyage_60min_europe

                  ]])++
	test_connexions_rdm(default,Phase,CODE,VLR)++
 	lists:append([test_connexions_rdm(Opt,Phase,CODE,VLR)||
			 Opt<-
			     [
			      opt_pass_internet_int_jour_2E,
			      opt_pass_internet_int_jour_5E,
			      opt_pass_voyage_15min_maghreb,
			      opt_pass_voyage_30min_maghreb,
			      opt_pass_voyage_60min_maghreb,
			      opt_pass_voyage_15min_rdm,
			      opt_pass_voyage_30min_rdm,
			      opt_pass_voyage_60min_rdm

			     ]])++
	["OK"].

test_voix_europe(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs a  l'L'etranger voix europe default",
	 {ussd2,
	  [
	   {send, CODE},
           {expect,".*"},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"1"},
	   {expect,"Connaitre les tarifs voix sur la zone:."
	    "1:Zone Europe."
	    "2:Zone USA Canada Maghreb Turquie."
	    "3:Zone Reste du monde"},
	   {send,"1"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour vos"},
	   {send,"11111"},
	   {expect,"Suisse et Andorre appels emis et recus decomptes a la sec"}
	  ]}];

test_voix_europe(Opt, Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger voix europe option=" ++ atom_to_list(Opt),
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"1"},
	   {expect,"Connaitre les tarifs voix sur la zone:."
	    "1:Zone Europe."
	    "2:Zone USA Canada Maghreb Turquie."
	    "3:Zone Reste du monde"},
	   {send, "1"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour"},
	   {send,"11111"},
	   {expect,".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, "www.orange.fr\\/travel"}
	  ]}]++
	test_util_of:close_session().

test_voix_usa_maghreb(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger voix usa canada maghreb default",
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"1"},
	   {expect,"Connaitre les tarifs voix sur la zone:."
	    "1:Zone Europe."
	    "2:Zone USA Canada Maghreb Turquie."
	    "3:Zone Reste du monde"},
	   {send,"2"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour"},
	   {send,"1111"},
	   {expect,"des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr\\/travel"}
	  ]}]. 


test_voix_reste_du_monde(default, Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger voix reste du monde",
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"13"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour"},
	   {send,"1111"},
	   {expect,"ou sur www.orange.fr.travel"}
	  ]}]++
	test_util_of:close_session()++
	[].

test_smsmms_europe(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger sms mms europe default",
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"2"},
	   {expect,"Connaitre les tarifs SMS/MMS sur la zone:."
	    "1:Zone Europe."
	    "2:hors Zone Europe."},
	   {send,"1"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille"},
	   {send,"111"},
	   {expect,"Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr.travel"}
	  ]}] ++ test_util_of:close_session();

test_smsmms_europe(Opt,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger sms mms europe option= "++atom_to_list(Opt),
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"2"},
	   {expect,"Connaitre les tarifs SMS/MMS sur la zone:."
	    "1:Zone Europe."
	    "2:hors Zone Europe."},
	   {send,"1"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille"},
	   {send,"1111"},
	   {expect,"Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr.travel"}
	  ]}]++
	test_util_of:close_session()++
	[].

test_smsmms_usa_maghreb(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger sms mms usa canada maghreb default",
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"2"},
	   {expect,"Connaitre les tarifs SMS/MMS sur la zone:."
	    "1:Zone Europe."
	    "2:hors Zone Europe."},
	   {send,"2"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille"},
	   {send,"11111"},
	   {expect,"Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr.travel"}
	  ]}].


test_connexions_europe(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger connexions europe defaut",
	 {ussd2,
	  [
	   {send, CODE},
	   {expect,".*"},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"3"},
	   {expect,"Connaitre les tarifs des connexions multimedia sur la zone:."
	    "1:Zone Europe."
	    "2:Hors Zone Europe"},
	   {send,"1"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web"},
	   {send,"111"},
	   {expect,"Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr.travel"}
	  ]}]++
	test_util_of:close_session()++
	[];

test_connexions_europe(Opt,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger connexions europe option="++atom_to_list(Opt),
	 {ussd2,
	  [
	   {send, CODE},
	   {expect,".*"},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"3"},
	   {expect,"Connaitre les tarifs des connexions multimedia sur la zone:."
	    "1:Zone Europe."
	    "2:Hors Zone Europe"},
	   {send,"1"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web"},
	   {send,"1111"},
	   {expect,"Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr.travel"}
	  ]}]++
	test_util_of:close_session()++
	[].

test_connexions_rdm(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger connexions usa canada maghreb default",
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"3"},
	   {expect,"Connaitre les tarifs des connexions multimedia sur la zone:."
	    "1:Zone Europe."
	    "2:Hors Zone Europe"},
	   {send,"2"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web"},
	   {send,"111"},
	   {expect,"tarifaire en vigueur ou sur www.orange.fr.travel"}
	  ]}]++
	test_util_of:close_session()++
	[];

test_connexions_rdm(Opt,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
	[
	 "Connect to #123# - MOBI, roaming -> Tarifs à l'étranger connexions usa canada maghreb option="++atom_to_list(Opt),
	 {ussd2,
	  [
	   {send, CODE},
	   {send, code_tarif(VLR,Phase)},
	   {expect,"1:Les tarifs voix."
	    "2:Les tarifs SMS/MMS."
	    "3:Les tarifs des connexions multimedia"},
	   {send,"3"},
	   {expect,"Connaitre les tarifs des connexions multimedia sur la zone:."
	    "1:Zone Europe."
	    "2:Hors Zone Europe"},
	   {send,"2"},
	   {expect,"Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web"},
           {send, "1"},
           {expect,".*"},
           {send,"1"},
           {expect,".*"},
	   {send,"1"},
	   {expect,".*"}
	  ]}]++
	test_util_of:close_session()++
	[].

code_tarif(?VLR,1) ->
    "5";
code_tarif(?VLR,2) ->
    "5";
code_tarif(?VLR_F,_) ->
    "3".
back_menu_roaming(?VLR)->
    "9";
back_menu_roaming(?VLR_F) ->
    "945".
code_service(_) ->
    "4".
code_accueil(1)->
    "6*7";
code_accueil(2) ->
    "6".

empty_data() ->	
    ["Empty data",
     {shell,
      [ {send,"mysql -upossum -ppossum -B -e \"delete FROM users WHERE subscription='mobi'\" mobi"}
       ]}].

page_description(Opt,?VLR) ->    
    case Opt of 
	Opt when 
	      Opt==opt_10min_europe;
	      Opt==opt_pass_voyage_15min_europe;
	      Opt==opt_pass_voyage_30min_europe;
	      Opt==opt_pass_voyage_60min_europe ->
	    "11";
	Opt when Opt==opt_pass_voyage_15min_maghreb;
		 Opt==opt_pass_voyage_30min_maghreb;
		 Opt==opt_pass_voyage_60min_maghreb ->
	    "21";
	Opt when Opt==opt_pass_voyage_15min_rdm;
		 Opt==opt_pass_voyage_30min_rdm;
		 Opt==opt_pass_voyage_60min_rdm-> 
	    "31"
    end.
code_option(Opt,VLR) when Opt==opt_pass_internet_int_jour_2E;
			   Opt==opt_pass_internet_int_jour_5E ->
    case VLR of 
	?VLR ->
	    "21";
	_ ->
	    "31"
    end;
code_option(Opt,?VLR) -> 
    "1"++page_description(Opt,?VLR);
code_option(Opt,_) ->
    "2"++page_description(Opt,?VLR).
	
code_conditions(Opt)->
    case Opt of
        X when X==opt_pass_internet_int_jour_5E; X==opt_pass_internet_int_jour_2E->"7";
        _->"17"
    end.
