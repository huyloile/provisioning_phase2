-module(test_123_mobi_bons_plans_vos_appels).
-compile(export_all).


-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").

-define(Uid, mobi_user).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()),
    ok.

prisme_counters() ->
    [{"MO","PB21", 6},
     {"MO","AB21", 6},
     {"MO","MB21", 6},

     {"MO","PB20", 6},
     {"MO","AB20", 12},
     {"MO","MB20", 6},
     {"MO","SCONOK", 47}
    ].

init_test(DCL_NUM)->
    Test_profile = #test_profile{sub="mobi",
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

test()->
    test_vos_appels()++
 	test_jeu_disney()++
	[].

test_jeu_disney()->
     lists:append([test_opt_jeu_disney_vos_appels(DCL,Opt)||
 		     DCL<-[?mobi,
  			   ?click_mobi,
  			   ?OM_mobile,
 			   ?m6_prepaid],
 		     Opt<-[opt_journee_infinie,
  			   opt_soiree_infinie,
 			   opt_duo_journee]])++
 	lists:append([test_opt_jeu_disney_vos_messages(DCL,Opt)||
 			 DCL<-[?mobi,
 			       ?click_mobi,
 			       ?OM_mobile,
 			       ?m6_prepaid],
 			 Opt<-[opt_journee_sms_illimite,
 			       opt_soiree_sms_illimite]])++
	[].

test_opt_jeu_disney_vos_messages(DCL, Opt)->
    init_test(DCL) ++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=333,
						       unt_num=?EURO,
						       cpp_solde=4000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	[{title, "#### Test Vos Messages Jeu disney - "++option_label(Opt, DCL)++" - DCL="++ integer_to_list(DCL)++" ####"},
         {ussd2,
          [
           {send, vos_messages_menu(DCL)},
           {expect, ".*"},
           {send, option_code_vos_messages(Opt)},
           {expect,"Grace au jeu Disney, vous avez gagne 3 euros de bons plans offerts"},
           {send, "1"},
           {expect,".*"},
           {send,"1"},
           {expect,".*"},
           {send,"1"},
           {expect,".*"},
	   {send,"1"},
           {expect,"Dans quelques instants, votre bon plan.*"},
           {send,"9"},
           {expect,".*"}
          ]
         }
        ]++
	test_util_of:close_session().

test_opt_jeu_disney_vos_appels(DCL, Opt)->
    init_test(DCL) ++
	profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=333,
						       unt_num=?EURO,
						       cpp_solde=4000,
						       dlv=pbutil:unixtime(),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=?PCLAS_V2}])++
	[{title, "#### Test Vos Appels Jeu disney - "++option_label(Opt, DCL)++" - DCL="++ integer_to_list(DCL)++" ####"},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
           case DCL of
               ?umobile ->      
                   {expect,
                    "1:Journee Infinie.*"
                    "2:Soiree Infinie.*"
                    "3:Week End Infini.*"
                   };
	       _->
                   {expect,
                    "1:Journee Infinie.*"
                    "2:Soiree Infinie.*"
		    "3:Week End Infini.*"
                    "4:Duo Journee.*"
                   }
           end,
           {send, option_code(Opt)},
           {expect,"Grace au jeu Disney, vous avez gagne 3 euros de bons plans offerts"},
           {send, "1"},
           {expect,".*"},
           {send,"1"},
           {expect,".*"},
           {send,"1"},
           {expect,".*"},
	   {send,"1"},
           {expect,"Dans quelques instants, votre bon plan.*"},
	   {send,"9"},
	   {expect,".*"}
          ]
         }
        ]++
	test_util_of:close_session().
test_vos_appels()->
     test_menu_vos_appels([?mobi,
      			  ?click_mobi,
      			  ?OM_mobile,
      			  ?m6_prepaid
      			 ])++

    	test_opt_journee_infinie()++
   	test_opt_soiree_infinie()++
  	test_opt_weekend_infini()++
  	test_opt_duo_journee()++

    	test_opt_10mn_quotidiennes()++
 	test_opt_30mn_hebdomadaires()++

 	test_opt_journee_infinie_promo()++
       	test_opt_soiree_infinie_promo()++
       	test_opt_duo_journee_promo()++
	test_error_tuxedo_107(?mobi)++
 	["Test reussi"].

test_opt_journee_infinie() ->
    test_opt_vos_appels(?mobi, opt_journee_infinie)++
    	test_opt_vos_appels(?click_mobi, opt_journee_infinie)++
    	test_opt_vos_appels(?OM_mobile, opt_journee_infinie)++
    	test_opt_vos_appels(?m6_prepaid, opt_journee_infinie)++
   	test_opt_vos_appels(?umobile, opt_journee_infinie)++
 	[].

test_opt_soiree_infinie() ->
    test_opt_vos_appels(?mobi, opt_soiree_infinie)++
   	test_opt_vos_appels(?click_mobi, opt_soiree_infinie)++
   	test_opt_vos_appels(?OM_mobile, opt_soiree_infinie)++
 	test_opt_vos_appels(?m6_prepaid, opt_soiree_infinie)++
  	test_opt_vos_appels(?umobile, opt_soiree_infinie)++
 	[].

test_opt_weekend_infini() ->
    test_opt_vos_appels(?mobi, opt_weekend_infini)++
   	test_opt_vos_appels(?click_mobi, opt_weekend_infini)++
   	test_opt_vos_appels(?OM_mobile, opt_weekend_infini)++
 	test_opt_vos_appels(?m6_prepaid, opt_weekend_infini)++
  	test_opt_vos_appels(?umobile, opt_weekend_infini)++
 	[].

test_opt_duo_journee() ->
    test_opt_vos_appels(?mobi, opt_duo_journee)++
      	test_opt_vos_appels(?click_mobi, opt_duo_journee)++
      	test_opt_vos_appels(?OM_mobile, opt_duo_journee)++
  	test_opt_vos_appels(?m6_prepaid, opt_duo_journee)++
 	[].

test_opt_10mn_quotidiennes() ->
    test_opt_vos_appels_suppression([?mobi,
   				     ?click_mobi,
   				     ?OM_mobile,
  				     ?m6_prepaid],
  				    opt_10mn_quotidiennes)++	
 	test_opt_vos_appels_conditions([?mobi,
 					?click_mobi,
 					?OM_mobile,
 					?m6_prepaid],
 				       opt_10mn_quotidiennes)++
        [].			

test_opt_30mn_hebdomadaires() ->
    test_opt_vos_appels_suppression([?mobi,
     				     ?click_mobi,
     				     ?OM_mobile,
     				     ?m6_prepaid],
  				    opt_30mn_hebdomadaires)++	
  	test_opt_vos_appels_reactivation([?mobi,
  					  ?click_mobi,
  					  ?OM_mobile,
  					  ?m6_prepaid],
  					 opt_30mn_hebdomadaires)++	
	test_opt_vos_appels_conditions([?mobi,
					?click_mobi,
					?OM_mobile,
					?m6_prepaid],
				       opt_30mn_hebdomadaires)++
        [].

test_opt_journee_infinie_promo() ->
    test_opt_vos_appels_promo(?mobi, opt_journee_infinie)++
 	test_opt_vos_appels_promo(?click_mobi, opt_journee_infinie)++
	[].

test_opt_soiree_infinie_promo() ->
    test_opt_vos_appels_promo(?mobi, opt_soiree_infinie)++
 	test_opt_vos_appels_promo(?click_mobi, opt_soiree_infinie)++
	[].

test_opt_duo_journee_promo() ->
    test_opt_vos_appels_promo(?mobi, opt_duo_journee)++
 	test_opt_vos_appels_promo(?click_mobi, opt_duo_journee)++
        [].

test_opt_vos_appels_conditions([], _) ->
    [];
test_opt_vos_appels_conditions([DCL|T], Opt) ->
    init_test(DCL) ++
	profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt)}])++
        [{title, "Test Vos Appels - "++option_label(Opt, DCL)++" - Conditions - DCL="++ integer_to_list(DCL)},
         {ussd2,

	  [{send, vos_appels_menu(DCL)++option_code(Opt)},
	   {expect,".*"}
          ]++
	  test_men_leg(Opt, DCL)
         }
        ]++
        test_util_of:close_session()++

	test_opt_vos_appels_conditions(T, Opt).

test_opt_vos_appels_reactivation([], _) ->
    [];
test_opt_vos_appels_reactivation([DCL|T], Opt) ->
    init_test(DCL) ++
	profile_manager:set_list_comptes(?Uid, [#compte{tcp_num=?C_PRINC,
                                                        unt_num=?EURO,
                                                        cpp_solde=42000,
                                                        dlv=pbutil:unixtime(),
                                                        rnv=0,etat=?CETAT_AC,
                                                        ptf_num=?PCLAS_V2},
						#compte{tcp_num=?C_OPT_VOIX_APPELS,
							unt_num=?EURO,
							cpp_solde=42000,
							dlv=pbutil:unixtime(),
							rnv=0,
							etat=?CETAT_AC,
							ptf_num=?PCLAS_V2}])++
	profile_manager:set_list_options(?Uid,[#option{top_num=top_num(Opt),opt_info2="S"}])++
	[{title, "Test Vos Appels - "++option_label(Opt, DCL)++" - reactivation - DCL="++ integer_to_list(DCL)},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
	   case Opt of
	       opt_10mn_quotidiennes->
		   {expect,"5:10 minutes quotidiennes.*"};
	       _->
		   {expect,"5:30 minutes hebdomadaires.*"}
	   end,
           {send, option_code(Opt)},
	   {expect, expect_text(description_reacti1, Opt)},
	   {send,"1"},
	   {expect,expect_text(description_reacti2, Opt)},
	   {send,"1"},
	   {expect,expect_text(reactivation, Opt)},
	   {send,"1"},
	   {expect,expect_text(validation_reacti, Opt)}
	  ]
	 }
        ]++
	test_util_of:close_session()++
	test_opt_vos_appels_reactivation(T, Opt).


test_opt_vos_appels_suppression([], _) ->
    [];
test_opt_vos_appels_suppression([DCL|T], Opt) ->
    init_test(DCL) ++
	profile_manager:set_list_comptes(?Uid, [#compte{tcp_num=?C_PRINC,
                                                        unt_num=?EURO,
                                                        cpp_solde=42000,
                                                        dlv=pbutil:unixtime(),
                                                        rnv=0,etat=?CETAT_AC,
                                                        ptf_num=?PCLAS_V2},
						#compte{tcp_num=?C_OPT_VOIX_APPELS,
							unt_num=?EURO,
							cpp_solde=42000,
							dlv=pbutil:unixtime(),
							rnv=0,
							etat=?CETAT_AC,
							ptf_num=svc_options:ptf_num(Opt,mobi)}])++
	profile_manager:set_list_options(?Uid, [#option{top_num=top_num(Opt),
							tcp_num=svc_options:tcp_num(Opt,mobi),
							ptf_num=svc_options:ptf_num(Opt,mobi)}])++
	[{title, "Test Vos Appels - "++option_label(Opt, DCL)++" - Suppression - DCL="++ integer_to_list(DCL)},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
	   case Opt of
	       opt_10mn_quotidiennes->
		   {expect,"5:10 minutes quotidiennes.*"};
	       _->
		   {expect,"5:30 minutes hebdomadaires.*"}
	   end,
           {send, option_code(Opt)},
	   {expect,expect_text(description_suppr, Opt)},
	   {send,"1"},
	   {expect,expect_text(suppression1, Opt)},
	   {send,"1"},
	   {expect,expect_text(suppression2, Opt)},
	   {send,"1"},
	   {expect,expect_text(validation_suppr, Opt)}
	  ]

	 }
        ]++
	test_util_of:close_session()++
	test_opt_vos_appels_suppression(T, Opt).
test_menu_vos_appels([])->
    [];
test_menu_vos_appels([DCL|T])->
    init_test(DCL) ++
	profile_manager:set_list_options(?Uid, [#option{top_num=top_num(opt_10mn_quotidiennes)},
						#option{top_num=top_num(opt_30mn_hebdomadaires)}
					       ])++
	[{title, "Test Menu Vos Appels - with links - "++"DCL="++ integer_to_list(DCL)},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
           {expect, expect_menu_vos_appels(DCL)}
	  ]
	 }
        ]++
	test_util_of:close_session()++

	profile_manager:set_list_options(?Uid, []) ++
	[{title, "Test Menu Vos Appels - without links - "++"DCL="++ integer_to_list(DCL)},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
	   {expect,
	    "1:Journee Infinie.*"
	    "2:Soiree Infinie.*"
	    "3:Week End Infini.*"
	    "4:Duo Journee.*"
	   }
	  ]
	 }
        ]++
	test_util_of:close_session()++
	test_menu_vos_appels(T).

test_opt_vos_appels(DCL, Opt) ->
    init_test(DCL) ++
	[{title, "#### Test Vos Appels - "++option_label(Opt, DCL)++" - DCL="++ integer_to_list(DCL)++" ####"},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
	   case DCL of
	       ?umobile ->		
		   {expect,
		    "1:Journee Infinie.*"
		    "2:Soiree Infinie.*"
		    "3:Week End Infini.*"
		   };
	       _->
		   {expect,
		    "1:Journee Infinie.*"
		    "2:Soiree Infinie.*"
		    "3:Week End Infini.*"
		    "4:Duo Journee.*"
		   }
	   end,
           {send, option_code(Opt)}
	  ]++

	  case Opt of
	      opt_duo_journee ->
		  [{expect, expect_text(description1, Opt)},
		   {send,"1"},
		   {expect, expect_text(description2, Opt)},
		   {send,"1"},
		   {expect, expect_text(description3, Opt)},
		   {send,"1"},
		   {expect, expect_text(description4, Opt)}];
	      _ ->
		  [{expect, expect_text(description1, Opt)}]
	  end ++

	  test_men_leg(Opt, DCL) ++

	  [
           {send,"1"},
	   {expect, expect_text(souscription, Opt)},
           {send, "1"},
           {expect, expect_text(validation1, Opt)},
           {send, "1"},
           {expect, expect_text(validation2, Opt)}
          ]
         }
        ]++
	test_util_of:close_session().

test_opt_vos_appels_promo(DCL, Opt) ->
    Test_profile = #test_profile{sub="mobi",
                                 dcl=DCL,
                                 comptes=[#compte{tcp_num=?C_PRINC,
                                                  unt_num=?EURO,
                                                  cpp_solde=42000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,
                                                  etat=?CETAT_AC,
                                                  ptf_num=?PCLAS_V2},
					  #compte{tcp_num=?C_BONS_PLANS,
                                                  unt_num=?EURO,
                                                  cpp_solde=15000,
                                                  dlv=pbutil:unixtime(),
                                                  rnv=0,
                                                  etat=?CETAT_AC,
						  ptf_num=?PCLAS_V2}]
                                },
    profile_manager:create_and_insert_default(?Uid,Test_profile)++
        profile_manager:init(?Uid)++

        [{title, "#### Test Vos Appels PROMO - "++option_label(Opt, DCL)++" PROMO - DCL="++ integer_to_list(DCL)++" ####"},
         {ussd2,
          [
           {send, vos_appels_menu(DCL)},
	   case DCL of
	       ?umobile ->      
		   {expect,
		    "1:Journee Infinie.*"
		    "2:Soiree Infinie.*"
		    "3:Week End Infini.*"
		   };
	       _->
		   {expect,
		    "1:Journee Infinie.*"
		    "2:Soiree Infinie.*"
		    "3:Week End Infini.*"
		    "4:Duo Journee.*"
		   }
	   end,
           {send, option_code(Opt)},
	   {expect, expect_text(description1_promo, Opt)},
	   {send,"1"},
	   {expect, expect_text(description2_promo, Opt)},
	   {send,"1"},
	   {expect, expect_text(description3_promo, Opt)},
	   {send,"1"},
	   {expect, expect_text(description4_promo, Opt)}
          ]++

          test_men_leg(Opt, DCL) ++

          [
           {send,"1"},
           {expect, expect_text(souscription_promo, Opt)},
           {send, "1"},
           {expect, expect_text(validation1_promo, Opt)},
           {send, "1"},
           {expect, expect_text(validation2_promo, Opt)}
          ]
         }
        ]++
        test_util_of:close_session().

vos_appels_menu(Dcl)->
    case Dcl of
        ?OM_mobile->
	    "#123*2*3*2*3";
	?m6_prepaid ->
	    "#123*2*3*2*1";
	?umobile ->
            "#123*1*2*2";
	?click_mobi ->
	    "#123*2*3*2*2";
	?mobi ->
	    "#123*2*4*2";
        _ ->
            "#123*2*4*2"
    end.

vos_messages_menu(Dcl)->
    case Dcl of
        ?OM_mobile->
	    "#123*2*3*2*4*1";
	?m6_prepaid ->
	    "#123*2*3*2*2*1";
	?umobile ->
            "#123*1*2*3*1";
	?click_mobi ->
	    "#123*2*3*2*3*1";
	?mobi ->
            "#123*2*4*3*1";
        _ ->
            "#123*2*4*2"
    end.

expect_menu_vos_appels(DCL) ->
    case DCL of
	?umobile ->
	    "1:Journee Infinie.*"
		"2:Soiree Infinie.*"
		"3:Week End Infini.*";
	_  ->
	    "1:Journee Infinie.*"
		"2:Soiree Infinie.*"
		"3:Week End Infini.*"
		"4:Duo Journee.*"
		"5:10 minutes quotidiennes.*"
		"6:30 minutes hebdomadaires.*"
    end.


option_label(opt_10mn_quotidiennes, DCL) ->
    case DCL of
	?mobi ->
	    "10 minutes quotidiennes";
	_ ->
	    "Bon plan 10 minutes quotidiennes"
    end;

option_label(opt_30mn_hebdomadaires, DCL) ->
    case DCL of
        ?mobi ->
	    "30 minutes hebdomadaires";
	_->            
	    "Bon plan 30 minutes hebdomadaires"
    end;

option_label(Opt, DCL) ->
    case Opt of
	opt_journee_infinie ->
	    "Journee Infinie";
	opt_soiree_infinie ->
	    "Soiree Infinie";
        opt_weekend_infini ->
	    "Weekend Infini";
        opt_duo_journee ->
	    "Duo Journee";
        opt_soiree_sms_illimite->
	    "Soiree sms illimite";
        opt_journee_sms_illimite->
	    "Journee sms illimite"
    end.

option_code(Opt) ->
    case Opt of
        opt_journee_infinie ->
            "1";
	opt_soiree_infinie ->
            "2";
        opt_weekend_infini ->
            "3";
        opt_duo_journee ->
            "4";
	opt_10mn_quotidiennes ->
	    "5";
	opt_30mn_hebdomadaires->
	    "5"
    end.

option_code_vos_messages(Opt) ->
    case Opt of
        opt_journee_sms_illimite->
            "3";
	opt_soiree_sms_illimite->
            "4"
    end.

expect_text(description1, opt_duo_journee) ->
    "Vos communications de la journee a petit prix : 1h de com' nat. \\+ 15 SMS utilisables en MMS de 9h a 21h pour seulement 3E..*1:Suite";

expect_text(description2, opt_duo_journee) ->
    "Communiquez autrement a prix reduit avec l'option duo journee.Preparez ou racontez vos vacances,echangez les derniers potins....*1:Suite";

expect_text(description3, opt_duo_journee) ->
    "...en appelant vos amis ou par SMS et envoyez vos plus belles photos par MMS..*Pour seulement 3 euros, vous profitez....*1:Suite";

expect_text(description4, opt_duo_journee) ->
    "...d'1 heure de com' nat. vers fixe et mobiles \\+ 15 SMS ou MMS valables de 9h00 a 21h00 le jour de la souscription..*1:Souscrire.*7:Conditions";

expect_text(description1, Opt) ->
    case Opt of
	opt_journee_infinie ->
	    "Avec l'option Journee Infinie,profitez de communications illimitees une journee vers les fixes et les mobiles Orange pour 3E.";
	opt_soiree_infinie ->
	    "Avec l'option Soiree Infinie,profitez de communications illimitees de 21h a minuit ce soir vers les fixes et mobiles orange pour 3E.";
	opt_weekend_infini ->
	    "Avec l'option week-end infini,profitez de communications illimitees le weekend vers les fixes et les mobiles orange pour seulement 10E."
    end++
	".*1:Souscrire.*7:Conditions";

expect_text(description1_promo, Opt) ->
    "Grace a votre promotion 1er rechargement, vous beneficiez de bons plans offerts..*"
	"1:Suite";

expect_text(description2_promo, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Avec la Journee Infinie d'une valeur de 3E vos appels sont illimites de 7 a 17h ce jour vers les fixes et les mobiles Orange.";
        opt_soiree_infinie ->
            "Pensez a verifier le credit de votre compte bons plans offerts \\(menu suivi conso \\+\\). Si le credit est insuffisant,";
        opt_duo_journee ->
            "Pensez a verifier le credit de votre compte bons plans offerts \\(suivi conso \\+\\). Si le credit est insuffisant"
    end++
        ".*1:Suite";
expect_text(description3_promo, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Pensez a verifier le solde de votre compte bons plans offerts \\(menu suivi conso \\+\\). Si le credit est insufisant \\(inferieur a 3E\\),";
        opt_soiree_infinie ->
            "le montant du bon plan sera debite de votre compte principal.Avec l'option Soiree Infinie \\(d'une valeur de 3E\\),";
        opt_duo_journee ->
            "le montant du bon plan sera debite de votre compte principal. Avec l'option Duo Journee \\(d'une valeur de 3E\\)"
    end++
        ".*1:Suite";

expect_text(description4_promo, Opt) ->
    case Opt of
        opt_journee_infinie ->
	    "le montant du bon plan sera debite de votre compte principal.";
        opt_soiree_infinie ->
	    "profitez de communications illimitees de 21h a minuit ce soir vers fixes et mobiles orange";
	opt_duo_journee ->
	    "Vos communications de la journee a petit prix : 1h de com. nat. \\+ 15 SMS utilisables en MMS de 9h a 21h."
    end++
        ".*1:Souscrire.*7:Conditions";

expect_text(souscription, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Vous allez souscrire a l'option Journee Infinie pour 3E.";
	opt_soiree_infinie ->
            "Vous allez souscrire a l'option Soiree Infinie pour 3E.";
        opt_weekend_infini ->
            "Vous allez souscrire a l'option Week End Infini pour 10E.";
        opt_duo_journee ->
            "Vous allez souscrire a l'option duo journee pour 3 euros."
    end++
	".*1:Valider";

expect_text(souscription_promo, Opt) ->
    "Vous allez souscrire a l'option "++
	case Opt of
	    opt_journee_infinie ->
		"Journee Infinie";
	    opt_soiree_infinie ->
		"Soiree Infinie";
	    opt_duo_journee ->
		"duo journee"
	end++
        " \\(d'une valeur de 3E\\).*1:Valider";

expect_text(validation1, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Vous avez souscrit a l'option Journee infinie pour 3E.";
	opt_soiree_infinie ->
            "Vous avez souscrit a l'option Soiree Infinie pour 3E.";
        opt_weekend_infini ->
            "Vous avez souscrit a l'option Week-end Infini pour 10E.";
        opt_duo_journee ->
            "Vous avez souscrit a l'option Duo Journee pour 3E."
    end++
	" Ce montant a ete debite de votre compte..*1:Suite.*9:Accueil";

expect_text(validation2, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Dans quelques instants, votre option journee infinie sera activee.";
	opt_soiree_infinie ->
            "Dans quelques instants, votre option soiree infinie sera activee.";
        opt_weekend_infini ->
            "Dans quelques instants, votre option week-end infini sera activee.";
        opt_duo_journee ->
            "Dans quelques instants, votre option Duo Journee sera activee"
    end++
	".*9:Accueil";

expect_text(validation1_promo, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Vous avez souscrit a l'option Journee infinie pour 3E.";
	opt_soiree_infinie ->
            "Vous avez souscrit a l'option Soiree Infinie pour 3E.";
        opt_duo_journee ->
            "Vous avez souscrit a l'option Duo Journee pour 3E."
    end++
        " Ce montant a ete debite de votre compte..*1:Suite.*9:Accueil";

expect_text(validation2_promo, Opt) ->
    case Opt of
        opt_journee_infinie ->
            "Dans quelques instants, votre option journee infinie sera activee.";
        opt_soiree_infinie ->
            "Dans quelques instants, votre option soiree infinie sera activee.";
        opt_duo_journee ->
            "Dans quelques instants, votre option Duo Journee sera activee"
    end++
	".*9:Accueil";

expect_text(description_suppr, Opt) ->
    case Opt of
        opt_10mn_quotidiennes ->
	    "Votre bon plan 10 minutes quotidiennes est actuellement active et vous beneficiez de 10 minutes d'appels par jour.";
	opt_30mn_hebdomadaires ->
	    "Votre bon plan 30 minutes hebdomadaires est actuellement active et vous beneficiez de 30 minutes d'appels par semaine."
    end++
	".*1:Supprimer l'option.*7:Conditions.*9:Accueil";

expect_text(suppression1, Opt) ->
    "En supprimant ce bon plan maintenant, vous perdrez le temps restant a consommer sur ce dernier \\(consultable dans la rubrique suivi conso\\)"
	".*1:Suite";

expect_text(suppression2, Opt) ->

    case Opt of
        opt_10mn_quotidiennes ->	    
            "Merci de confirmer la suppression de votre bon plan 10 minutes quotidiennes.";
        opt_30mn_hebdomadaires ->
	    "Merci de confirmer la suppression de votre bon plan 30 minutes hebdomadaires."
    end++
	".*1:Valider";

expect_text(validation_suppr, Opt) ->
    case Opt of
	opt_10mn_quotidiennes ->
	    "La suppression de votre bon plan 10 minutes quotidiennes a bien ete prise en compte. Merci de votre appel.";
	opt_30mn_hebdomadaires->
	    "La suppression de votre bon plan 30 minutes hebdomadaires a bien ete prise en compte. Merci de votre appel."
    end++
	".*9:Accueil";

expect_text(description_reacti1, Opt) ->
    case Opt of
	opt_30mn_hebdomadaires->
	    "Votre bon plan 30 minutes hebdomadaires est actuellement suspendu."
    end++
        ".*1:Suite";

expect_text(description_reacti2, Opt) ->
    case Opt of
	opt_30mn_hebdomadaires->
            "Vous ne beneficiez plus de vos 30 minutes d'appels par semaine."
    end++
        ".*1:Reactiver l'option.*2:Supprimer l'option.*7:Conditions.*9:Accueil";

expect_text(reactivation, Opt) ->
    case Opt of
	opt_30mn_hebdomadaires ->
	    "Vous allez reactiver le bon plan 30 minutes hebdomadaires. Ce bon plan est renouvele chaque semaine a date anniversaire."
    end++
	".*1:Confirmer";

expect_text(validation_reacti, Opt) ->
    case Opt of
	opt_30mn_hebdomadaires ->
	    "La reactivation de votre bon plan 30 minutes hebdomadaires a bien ete prise en compte."
    end++
	".*9:Accueil".

test_men_leg(opt_journee_infinie, DCL) ->
    case DCL of
	?m6_prepaid ->
	    [
	     {send, "7"},
	     {expect, "Appels voix illimites en France metropolitaine le jour de la souscription de 7h a 17h, vers les Nos fixes et mobiles Orange....*1:Suite"},
	     {send, "1"},
	     {expect, "...\\(hors No speciaux,No courts,No d'acces wap et web, appels emis depuis des boitiers et appels vers les plates-formes telephoniques\\)....*1:Suite"},
	     {send, "1"},
	     {expect, "...dans la limite de 3 heures maximum par appel. Appels directs entre personnes physiques pour un usage personnel non lucratif direct....*1:Suite"},
	     {send, "1"},
	     {expect, "...Option non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
	    ];
	_ ->
	    [
	     {send, "7"},
	     {expect, "Souscription possible le jour meme, du lundi au vendredi, de 2h a 16h45 \\(appels gratuits depuis la France metropolitaine\\)....*1:Suite"},
	     {send, "1"},
	     {expect, "Les 3E sont preleves a la souscription de l'option sur le compte. Option non disponible les week-end, jours feries et veilles de jours feries....*1:Suite"},
	     {send, "1"},
	     {expect, "Appels voix, 3h maximum par appel, hors numeros speciaux, num de services et num en cours de portabilite....*1:Suite"},
	     {send, "1"},
	     {expect, "Appels directs entre personnes physiques et pour un usage personnel non lucratif direct..*1:Souscrire"}
	    ]
    end;

test_men_leg(opt_soiree_infinie, DCL) ->
    case DCL of
	?m6_prepaid ->
	    [
	     {send, "7"},
             {expect, "Appels voix illimites en France metropolitaine le soir de la souscription de 21h a minuit, vers les Nos fixes et mobiles Orange....*1:Suite"},
             {send, "1"},
             {expect, "...\\(hors No speciaux,No courts,No d'acces wap et web, appels emis depuis des boitiers et appels vers les plates-formes telephoniques\\)....*1:Suite"},
             {send, "1"},
             {expect, "...dans la limite de 3 heures maximum par appel. Appels directs entre personnes physiques, pour un usage personnel non lucratif direct....*1:Suite"},
             {send, "1"},
             {expect, "...Option non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
	    ];
	_ ->
	    [
	     {send, "7"},
	     {expect, "Souscription possible le jour meme de 2h a 23h45 \\(appels gratuits depuis la France metropolitaine\\)....*1:Suite"},
	     {send, "1"},
	     {expect, "Les 3E sont preleves a la souscription de l'option sur le compte. Option non disponible les week-end, jours feries et veilles de jours feries.*1:Suite"},
	     {send, "1"},
	     {expect, "Appels voix, 3h maximum par appel, hors num speciaux, num de services et num en cours de portabilite....*1:Suite"},
	     {send, "1"},
	     {expect, "Appels directs entre personnes physiques et pour un usage personnel non lucratif direct..*1:Souscrire"}
	    ]
    end;

test_men_leg(opt_weekend_infini, DCL) ->
    case DCL of
	?m6_prepaid ->
	    [
	     {send, "7"},
	     {expect, "Appels voix illimites en France metropolitaine de vendredi minuit au dimanche minuit, vers les Nos fixes et mobiles Orange....*1:Suite"},
	     {send, "1"},
	     {expect, "...\\(hors No speciaux,No courts,No d'acces wap et web, appels emis depuis des boitiers et appels vers les plates-formes telephoniques\\).*1:Suite"},
	     {send, "1"},
	     {expect, "dans la limite de 3 heures maximum par appel. Appels directs entre personnes physiques, pour un usage personnel non lucratif direct.*1:Suite"},
	     {send, "1"},
	     {expect, "...Option non disponible les jours feries et veilles de jours feries..*1:Souscrire"}
	    ];
	_ ->
	    [
	     {send, "7"},
	     {expect, "Souscription possible du lundi au dimanche de 2h a 23h45 \\(appels gratuits depuis la France metropolitaine\\)....*1:Suite"},
	     {send, "1"},
	     {expect, "...pour le week-end a venir ou en cours. Les 10E sont preleves a la souscription de l'option sur le compte. Option non disponible....*1:Suite"},
	     {send, "1"},
	     {expect, "..les jours feries et veilles de jours feries. Appels voix, 3h maximum par appel, hors num speciaux, num de services et....*1:Suite"},
	     {send, "1"},
	     {expect, "...num en cours de portabilite. Appels directs entre personnes physiques et pour un usage personnel non lucratif direct.*1:Souscrire"}
	    ]
    end;
test_men_leg(opt_10mn_quotidiennes, DCL) ->
    [           
		{send , "7"},
		{expect, "Offre valable en France metropolitaine. 10 minutes d'appels vers tous les numeros fixe et mobile en France metropolitaine,.*1:Suite"},
		{send, "1"},
		{expect, "hors numeros speciaux, de services et numeros courts. Appels directs entre personnes physiques et pour un usage personnel non lucratif direct..*1:Suite"},
		{send, "1"},
		{expect, "Le prix de l'option est preleve sur le compte principal lors du renouvellement quotidien de l'option sous reserve que le credit soit suffisant..*1:Suite"},
		{send, "1"},
		{expect, "En cas de credit insuffisant, l'option est suspendue et reprend automatiquement des que celui-ci .*a nouveau suffisant..*1:Suite"},
		{send, "1"},
		{expect, "Les minutes non utilisees par jour ne sont pas reportees sur le jour suivant. Le renouvellement quotidien de l'option est effectue chaque jour.*1:Suite"},
		{send, "1"},
		{expect, "entre 23h00 et 1h00."}
	       ];

test_men_leg(opt_30mn_hebdomadaires, DCL) ->
    [
     {send, "7"},
     {expect, "Offre valable en France metropolitaine. 30 minutes d'appels vers tous les numeros fixe et mobile en France metropolitaine,.*1:Suite"},
     {send, "1"},
     {expect, "hors numeros speciaux, de services et numeros courts. Appels directs entre personnes physiques et pour un usage personnel non lucratif direct..*1:Suite"},
     {send, "1"},
     {expect, "Le prix de l'option est preleve sur le compte principal lors du renouvellement hebdomadaire de l'option sous reserve que le credit soit.*1:Suite"},
     {send, "1"},
     {expect, "suffisant. Les minutes non utilisees sur la periode ne sont pas reportees sur la periode suivante."}
    ];

test_men_leg(opt_duo_journee, DCL) ->
    case DCL of
	?m6_prepaid ->
	    [
	     {send, "7"},
	     {expect, "Offre reservee aux clients d'une offre prepayee Orange et disponible du 14/06/07 au 15/08/07 inclus. 1 heure de communication en.*1:Suite"},
	     {send, "1"},
	     {expect, "France metropolitaine vers les No fixes \\(hors No speciaux\\) et les No mobiles et 15 SMS metropolitains \\(hors SMS surtaxes\\). SMS utilisables en MMS.*1:Suite"},
	     {send, "1"},
	     {expect, "...\\(hors MMS surtaxes et MMS Carte Postale\\) avec un mobile compatible et decomptes sur la base de 1 MMS= 1SMS....*1:Suite"},
	     {send, "1"},
	     {expect, "Communications decomptees a la seconde des la premiere seconde.Option incompatible avec l'option vacances MMS et la recharge SMS/MMS..*1:Souscrire"}
	    ];
	_ ->
	    [
	     {send, "7"},
	     {expect, "1 heure de communication en France metropolitaine vers les num fixes \\(hors num speciaux\\) et les num mobiles et 15 SMS metropolitains....*1:Suite"},
	     {send, "1"},
	     {expect, "...\\(hors SMS surtaxes\\). SMS utilisables en MMS \\(hors MMS surtaxes et MMS Carte Postale\\) avec un mobile compatible et decomptes....*1:Suite"},
	     {send, "1"},
	     {expect, "...sur la base de 1 MMS=1SMS. Communications decomptees a la seconde des la premiere seconde.Option avec la recharge SMS..*1:Souscrire"}
	    ]
    end.

%% Test error tuxedo "107"
test_error_tuxedo_107(DCL)->
    init_test(DCL) ++
	profile_manager:set_sachem_response(?Uid, {"maj_op",{nok, {error,"option_incompatible_sec"}}}) ++
        [{title, "#### Test Error Tuxedo - "++option_label(opt_journee_infinie, DCL)++" - DCL="++ integer_to_list(DCL)++" ####"},
         {ussd2,
	  [
           {send, vos_appels_menu(DCL)++option_code(opt_journee_infinie)++"11"},
           {expect,"Vous ne pouvez souscrire a l'option .* car nous ne pouvons vous identifier. Vous devez vous rendre dans votre point de vente.*1:suite"},
	   {send, "1"},
	   {expect, "accompagne de votre piece d'identite. Votre ligne sera retablie quelques jours apres l'enregistrement de vos coordonnees....*1:suite"},
	   {send, "1"},
	   {expect,"Sans action de votre part, votre ligne sera suspendue un mois apres l'activation de la ligne. Vous ne pourrez plus passer d'appels....*1:suite"},
	   {send, "1"},
	   {expect,"et votre ligne sera resiliee deux mois apres son activation. Pour toute question, votre service clients mobile Orange est a votre disposition au ....*1:suite"},
 	   {send, "1"},
   	   {expect, "722 depuis votre mobile \\(0,37E/min\\) ou au 3972 depuis un fixe.*\\(0,34E/min\\)."}
          ]
         }]++
	test_util_of:close_session().

top_num(Opt)->
    svc_options:top_num(Opt,mobi).
