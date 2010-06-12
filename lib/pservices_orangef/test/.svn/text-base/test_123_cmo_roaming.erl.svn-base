-module(test_123_cmo_roaming).
-export([run/0,online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("profile_manager.hrl").


-define(VLR,    "32495000000"). %%Belgique
-define(VLR_F,    "33495000000").
-define(DIRECT_CODE, "#123*#").
-define(DIRECT_CODE_F, "#123*1*2*6*2#").
-define(CODE, "#123*#").

-define(Uid, user_cmo_roaming).
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

online() ->
    test_util_of:online(?MODULE,test()).


test() ->

    %%Test title
    [{title, "Test suite for Selfcare Roaming CMO"}] ++
	roaming_from_abroad()++
	roaming_from_france()++		
	test_util_of:close_session() ++
	["Test reussi"].


roaming_from_abroad() ->
    sequence(2,?VLR,?DIRECT_CODE).
roaming_from_france() ->
    sequence(2,?VLR_F,?DIRECT_CODE_F).

sequence(Phase,VLR,CODE) ->
    ["TEST ROAMING"]++
 	test_menu(Phase,VLR,CODE)++
 	test_messagerie(Phase,VLR,CODE) ++
 	test_subscription(Phase,VLR,CODE) ++
 	test_option_activated(Phase,VLR,CODE) ++
  	test_infos_tarifs(Phase,VLR,CODE)++
 	test_incompability(Phase,VLR,CODE)++
	[].

top_num(Opt) -> profile_manager:rpc(svc_option_manager,get_top_num,[Opt,cmo]).
tcp_num(Opt) -> profile_manager:rpc(svc_option_manager,get_tcp_num,[Opt,cmo]).
ptf_num(Opt) -> profile_manager:rpc(svc_option_manager,get_ptf_num,[Opt,cmo]).

set_past_commercial_date() ->
    lists:append([test_util_of:set_past_commercial_date(Opt,cmo) || Opt <- 
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

code_messagerie(?VLR)->
    "4";
code_messagerie(?VLR_F) ->
    "2".
code_tarif(?VLR,1) ->
    "6*5";
code_tarif(?VLR,2) ->
    "5";
code_tarif(?VLR_F,_) ->
    "3".

init(VLR) ->
    profile_manager:create_default(?Uid,"cmo")++
        profile_manager:init(?Uid,smpp)++
	test_util_of:set_vlr(VLR).

test_menu(Phase,VLR,CODE) ->
    init(VLR)++
	[
	 "Connect to #123# - CMO, roaming -> Page Menu",
	 {ussd2,
	  [{send, CODE},suivi_conso_cmo(Phase,VLR)]
	 }
	].
test_messagerie(Phase,VLR,CODE) ->   
    init(VLR)++
	[
	 "Connect to #123# - CMO, roaming -> Infos Messagerie",
	 {ussd2,
	  [
	   {send, CODE},suivi_conso_cmo(Phase,VLR),
	   {send, code_messagerie(VLR)},
	   {expect,"Pour consulter votre messagerie vocale : "
	    "composez le 888 depuis votre mobile ou le \\+"
	    " \\(ou 00\\) 33608080808 depuis votre mobile ou.*"}
	  ]++infos_messagerie("1")++[]
	 }
	].

test_subscription(Phase,VLR,CODE) ->
    ["TEST SUBSCRIPTION OPTION"]++
	test_pass_voyage(Phase,VLR,CODE)++
	[].

test_option_activated(Phase,VLR,CODE) ->
    ["TEST OPTION ALREADY SUBSCRIBED"]++
	lists:append([test_option_activated(Opt,Phase,VLR,CODE) || Opt <- [ opt_10min_europe,
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

test_option_activated(Opt,Phase,VLR,CODE) ->
    ["Connect to #123# - CMO, roaming -> Souscrip Opt Europe, OPTION DEJA ACTIVEE"]++
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=15000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=113},
                                              #compte{tcp_num=?C_AEUROS,unt_num=?EURO,cpp_solde=20000,
                                                   dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=113}])++
	test_util_of:set_present_commercial_date(Opt,cmo)++
        profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
	["\n########### Opt: "++atom_to_list(Opt)]++
	[
	 {ussd2,
	  [
	   {send, CODE},suivi_conso_cmo(Phase,VLR),
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
	 }]++test_util_of:reset_commercial_date(Opt,cmo).


%%TEST OPTION EUROPE
test_pass_voyage(Phase,VLR,CODE) ->
      lists:append([test_pass_voyage(Opt,Phase,VLR,CODE) || Opt <- 
      							       [opt_10min_europe,
      								opt_pass_voyage_15min_europe,
      								opt_pass_voyage_30min_europe,
      								opt_pass_voyage_60min_europe,
      								opt_pass_voyage_15min_maghreb,
      								opt_pass_voyage_30min_maghreb,
      								opt_pass_voyage_60min_maghreb,
      								opt_pass_voyage_15min_rdm,
      								opt_pass_voyage_30min_rdm,
      								opt_pass_voyage_60min_rdm]
      							      ])++
	lists:append([test_internet(Opt,Phase,VLR,CODE) || Opt <- 
							       [opt_pass_internet_int_jour_2E,
								opt_pass_internet_int_jour_5E
							       ]
							      ])++
	case CODE of
	    ?DIRECT_CODE_F ->
		test_pass_minutes(opt_europe,Phase,CODE,VLR)++
		    test_pass_minutes(opt_maghreb,Phase,CODE,VLR)++
		    test_pass_minutes(opt_pass_dom,Phase,CODE,VLR);
	    _ ->
		[]
	end++
	["OK"].

test_pass_voyage(Opt,Phase,VLR,CODE) ->
    ["Connect to #123# - CMO, roaming -> SOUSCRIPTION REUSSIE A L'OPTION EUROPE"]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
	set_past_commercial_date()++
	test_util_of:set_present_commercial_date(Opt,cmo)++
	["####TEST Subscription###\n ", "option "++ atom_to_list(Opt)]++
	[{ussd2,
	  [
	   {send, CODE},suivi_conso_cmo(Phase,VLR),
	   {send, "1"},
	   {expect, ".*"},
	   {send, code_option(Opt,VLR)},
	   {expect,".*"},
           {send, "1"},
           {expect,".*"},
           {send, "1"},
           {expect,".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"}
	   ]}
	 ]++
	["####TEST MENTION LEGALES###\n ", "option "++ atom_to_list(Opt)]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
        [{ussd2,
          [
           {send, CODE},suivi_conso_cmo(Phase,VLR),
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
	test_util_of:reset_commercial_date(Opt,cmo)++
	test_util_of:close_session().

test_internet(Opt,Phase,VLR,CODE) ->
    ["Connect to #123# - CMO, roaming -> SOUSCRIPTION REUSSIE A L'OPTION PASS INTERNET INTERNATIONAL"]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
	set_past_commercial_date()++
	test_util_of:set_present_commercial_date(Opt,cmo)++
	["####TEST Subscription###\n ", "option "++ atom_to_list(Opt)]++
	[{ussd2,
	  [
	   {send, CODE},suivi_conso_cmo(Phase,VLR),
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
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
        [{ussd2,
          [
           {send, CODE},suivi_conso_cmo(Phase,VLR),
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
	test_util_of:reset_commercial_date(Opt,cmo)++
	test_util_of:close_session().

test_pass_minutes(opt_europe=Opt,Phase,Code,VLR) ->
    ["####CMO Profile connecting from France - Pass 25 minutes vers l'Europe ###"]++
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
	set_past_commercial_date()++
	test_util_of:set_present_commercial_date(Opt,cmo)++
	[{ussd2, 
	  [
	   {send, Code},suivi_conso_cmo(Phase,VLR),
	   {send, "1"},	  
	   {expect,"1:Communiquer depuis la France vers l'etranger et l'outre mer.*"
	    "2:Communiquer depuis l'etranger et l'outre mer.*"
	    "3:Acceder a Internet depuis l'etranger.*"},
	   {send, "1"},
	   {expect,"l'Europe"},
	   {send, "111"},
	   {expect,"l'Europe"},
	   {send, "9"},
	   {expect,".*"}
	  ]
	 }
	]++
	test_util_of:reset_commercial_date(Opt,cmo);

test_pass_minutes(opt_maghreb=Opt,Phase,Code,VLR) ->	
    ["####CMO Profile connecting from France - Pass 20 minutes vers le Maghreb ###"]++
	empty_data()++
	init(VLR)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
	set_past_commercial_date()++
	test_util_of:set_present_commercial_date(Opt,cmo)++
	[{ussd2,
	  [
	   {send, Code},suivi_conso_cmo(Phase,VLR),
	   {send, "1"},
	   {expect,"1:Communiquer depuis la France vers l'etranger et l'outre mer.*"
	    "2:Communiquer depuis l'etranger et l'outre mer.*"
	    "3:Acceder a Internet depuis l'etranger.*"},
	   {send, "1"},
	   {expect,"le Maghreb"},
	   {send, "211"},
	   {expect,"le Maghreb"},
	   {send, "9"},
	   {expect,".*"}
	  ]
	 }
	]++
	test_util_of:reset_commercial_date(Opt,cmo)++
	test_util_of:close_session();

test_pass_minutes(opt_pass_dom=Opt,Phase,Code,VLR) ->	
    ["####CMO Profile connecting from France - Pass 30 minutes vers les DOM ###"]++
	empty_data()++
	init(VLR) ++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=50000,
                                                       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?PCLAS_V2}])++
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
        profile_manager:set_list_options(?Uid,[])++
	test_util_of:set_present_period_for_test(commercial_date,[opt_pass_dom])++	
	[{ussd2,
	  [
	   {send, Code},suivi_conso_cmo(Phase,VLR),
	   {send, "11311"},
	   {expect, "Mentions legales"},
	   {send, "7"},
	   {expect, "Credit de communication valable 14 jours depuis la France metropolitaine"},
	   {send, "1"},
	   {expect, "vers la Guadeloupe, la Martinique, l'ile de la Reunion, Mayotte"},
	   {send, "1"},
	   {expect, "Saintes, Saint-Martin, la Guyane et Saint-Pierre-et-Miquelon"},
	   {send, "1"},
           {expect, ".*"},
	   {send, "1"},
           {expect, ".*"},
	   {send, "1"},
	   {expect, ".*"},
	   {send, "1"},
	   {expect,".*"},
	   {send, "1"},
	   {expect,".*"}
	  ]
	 }
	]++test_util_of:close_session().

test_infos_tarifs(Phase,VLR,CODE)->
    ["TEST INFOS TARIFS"]++
 	test_tarifs_voix(Phase,VLR,CODE)++
  	test_tarifs_smsmms(Phase,VLR,CODE)++
 	test_tarifs_connexions(Phase,VLR,CODE)++
	[].

test_tarifs_voix(Phase,VLR,CODE) ->
    ["TARIF ROAMING VOIX"]++
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

test_tarifs_smsmms(Phase,VLR,CODE) ->
    ["TARIF ROAMING SMS MMS"]++
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

test_tarifs_connexions(Phase,VLR,CODE) ->
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

test_incompability(Phase,VLR,CODE) ->
    ["TEST INCOMPABILITY OPTIONS"]++	
	lists:append([test_incompatibility(Opt,Phase,CODE,VLR) || Opt <- [opt_10min_europe,
									 opt_pass_voyage_15min_europe,
									 opt_pass_voyage_30min_europe,
									 opt_pass_voyage_60min_europe,
									 opt_pass_voyage_15min_maghreb,
									 opt_pass_voyage_30min_maghreb,
									 opt_pass_voyage_60min_maghreb
									  ]
								    ])++
	["OK"].

test_incompatibility(Opt,Phase,Code,VLR) ->    
    ["####CMO from France - option: "++atom_to_list(Opt)++" ###"]++
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
        profile_manager:set_dcl(?Uid,?zap_cmo_25E)++
	case Opt of 
	    opt_10min_europe -> 		
		profile_manager:set_list_options(?Uid,[#option{top_num=top_num(opt_10min_europe_carte_jump)}]);
	    _ ->
		profile_manager:set_list_options(?Uid,[#option{top_num=top_num(opt_pass_voyage_15min_rdm)},
						       #option{top_num=top_num(opt_pass_voyage_30min_rdm)},
						       #option{top_num=top_num(opt_pass_voyage_60min_rdm)}])
	end++	
	test_util_of:set_present_commercial_date(Opt,cmo)++
	[{ussd2, 
	  [{send, Code},suivi_conso_cmo(Phase,VLR),
	   {send, "1"},
	   {expect,".*"},
	   {send, code_option(Opt,VLR)},
	   {expect, ".*"},
	   {send, "11"},
	   {expect,"Cette option n'est pas compatible avec"}
	  ]
	 }
	]++
	test_util_of:reset_commercial_date(Opt,cmo)++
	test_util_of:close_session().

test_voix_europe(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - CMO, roaming -> Tarifs a  l'L'etranger voix europe default",
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
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger voix europe option=" ++ atom_to_list(Opt),
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
	   {expect, "et dans le pass voyage : appels emis et recus decomptes a la sec.au.dela de la 1ere min indivisible"}
	  ]}]++
	test_util_of:close_session().

test_voix_usa_maghreb(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger voix usa canada maghreb default",
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
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger voix reste du monde",
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
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger sms mms europe default",
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
	 "Connect to #123# - CMO, roaming -> Tarifs a l'etranger sms mms europe option= "++atom_to_list(Opt),
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
	   {expect,".*"}
	  ]}]++
	test_util_of:close_session()++
	[].

test_smsmms_usa_maghreb(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger sms mms usa canada maghreb default",
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
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger connexions europe defaut",
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
	 "Connect to #123# - CMO, roaming -> Tarifs a l'etranger connexions europe option="++atom_to_list(Opt),
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
	   {expect,".*"}
	  ]}]++
	test_util_of:close_session()++
	[].

test_connexions_rdm(default,Phase,CODE,VLR)->
    init(VLR)++
    profile_manager:set_list_options(?Uid,[])++
	[
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger connexions usa canada maghreb default",
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
	 "Connect to #123# - CMO, roaming -> Tarifs à l'étranger connexions usa canada maghreb option="++atom_to_list(Opt),
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

suivi_conso_cmo(2,?VLR_F) ->
    {expect,"Bienvenue sur vos services a l'etranger"
     ".*1:Bons plans tarifs"
     ".*2:Utiliser votre messagerie"
     ".*3:Quel tarif dans quel pays"
    };
suivi_conso_cmo(2,?VLR) ->
    {expect,"Vos services a l'etranger"
     ".*1:Bons plans tarifs.*2:Recharger.*3:Suivi conso"
     ".*4:Utiliser votre messagerie"
     ".*5:Les tarifs a l'etranger"
     ".*6:Page accueil France"};
suivi_conso_cmo(1,?VLR) ->
    {expect,"Vos services a l'etranger"
     ".*1#:Bons plans tarifs"
     ".*2#:Recharger"
     ".*3#:Suivi conso"
     ".*4#:Utiliser votre messagerie"
     ".*5#:.*"}.

code_mention_legale(?DIRECT_CODE) -> "1117";
code_mention_legale(_) -> "271117".

infos_messagerie("1") ->
    [{send, "1"},{expect,"une ligne fixe et laissez-vous guider."
		  " Attention : dans certains pays, votre code secret"
		  " vous sera demande pour interroger votre..."}]
	++ infos_messagerie("2");
infos_messagerie("2") ->
    [{send, "1"},{expect,"messagerie vocale. N'oubliez pas "
		  "d'enregistrer votre code avant votre depart. L'activation"
		  " ou la modification de votre code secret doit..."}]
	++ infos_messagerie("3");
infos_messagerie("3") ->
    [{send, "1"},{expect,"se faire depuis la France metropolitaine. "
		  "Avant de partir a l'etranger, composez le : 888 "
		  "choisissez l'option 2 et laissez-vous guider."}]
	++ infos_messagerie("4");
infos_messagerie("4") ->
    [{send, "1"},{expect,"Faites un essai de votre code confidentiel en "
		  "composant le \\+\\(ou 00\\) 33608080808 puis "
		  "laissez-vous guider. Retenez bien votre code secret."}]
	++ infos_messagerie("5");
infos_messagerie(_) ->
    [{send, "1"},{expect,"Cout de consultation de la messagerie "
		  "vocale a l'etranger = cout d'une communication"
		  " vers la France metro*."}].

empty_data() ->    	
    ["Empty data",
     {shell,
      [ {send,"mysql -upossum -ppossum -B -e \"delete FROM users WHERE subscription='cmo'\" mobi"}
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
        X when X==opt_pass_dom->"117";
        X when X==opt_pass_internet_int_jour_2E;X==opt_pass_internet_int_jour_5E->
            "7";
        _->"17"
    end.
