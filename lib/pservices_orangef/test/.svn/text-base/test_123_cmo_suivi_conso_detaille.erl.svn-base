-module(test_123_cmo_suivi_conso_detaille).

-export([online/0,
         pages/0,
         parent/1,
         links/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(Uid,cmo_suiviconso_user).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?suivi_conso, ?suivi_conso_plus].

parent(?suivi_conso) ->
    test_123_cmo_Homepage;
parent(?suivi_conso_plus) ->
    test_123_cmo_Homepage.

links(?suivi_conso_plus) ->
    [{?suivi_conso_detaille_1, static},
     {?suivi_conso_option_1,   static},
     {?gerer_options_1,        static}];

links(?suivi_conso) ->
    [{?suivi_conso_detaille_2, static},
     {?suivi_conso_option_2,   static},
     {?gerer_options_2,    static}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test()),
    test_util_of:test_kenobi(prisme_counters()),
    ok.

test()->
	test_util_of:init_day_hour_range() ++
	test_suivi_conso_detaille([?ppol3,
                                   ?m6_cmo_fb_1h,
 				   ?DCLNUM_CMO_SL_ZAP_1h30_ILL,
 				   ?cmo_smart_40min,
 				   ?cmo_smart_1h,
 				   ?cmo_smart_1h30,
				   ?cmo_smart_2h]) ++

	[].

test_suivi_conso_detaille([]) -> ["Test reussi"];
test_suivi_conso_detaille([DCL|T]) ->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="cmo",dcl=DCL})++
        profile_manager:init(?Uid)++
	profile_manager:set_list_comptes(?Uid, [#compte{tcp_num=?C_PRINC,
							unt_num=?EURO,
							cpp_solde=50000,
							dlv=pbutil:unixtime(),
							rnv=0,
							etat=?CETAT_AC,
							ptf_num=?PCLAS_V2},
						#compte{tcp_num=?C_FORF,
							unt_num=?EURO,
							cpp_solde=50000,
							dlv=pbutil:unixtime(),
							rnv=0,
							etat=?CETAT_AC,
							ptf_num=?PCLAS_V2}]) ++

	[{title, "Test Suivi Conso detaille - DCL =" ++ integer_to_list(DCL)}] ++
      	cmo_ac_sce()++
      	cmo_ep_sce()++
    	sv_conso_options(list_resiliation(), DCL) ++
     	test_restit_LIB_solde_not_available() ++
       	test_restit_LIB_solde_ac() ++
       	test_restit_LIB_solde_ep() ++

	test_suivi_conso_detaille(T)++
	[].


prisme_counters() ->    
    [
     {"CM","SCACOK", 172},
     {"CM","SCONOK", 88}
    ].

list_resiliation()->
    [ "VMPRE",
      "A4SM2",
      "OTV03",
      "OSP01",
      "OMUS0",
      "OPSU0",
      "OTV13",
      "OBTS0",
      "OPCC0",
      "OPCC1",
      "OPCC2",
      "MM043",
      "MM044",
      "OM012",
      "MM031",
      "PORFT",
      "SNS30",
      "FG30W",
      "FG30U",
      "FG30P",
      "OF1R4",
      "FG30S",
      "FJ30S",
      "FG80M",
      "FG30T",
      "OFR24",
      "OMI03",
      "OFR16",
      "FV30S",
      "OFR14",
      "FGX30",
      "FGS80",
      "SNS80",
      "FG80E",
      "FG80P",
      "FG80S",
      "FG80T",
      "FJ80S",
      "FGX80",
      "OFR15",
      "OFR17",
      "OFR18",
      "FG130",
      "F130S",
      "FK130",
      "FGT12",
      "FS21C",
      "FGT18",
      "FGTSL",
      "FS30C",
      "FGT25",
      "CMOR3",
      "CMOR6",
      "CMOR10",
      "CMR19",
      "CMR24",
      "CMR29",
      "CMR34",
      "CMOR8",
      "CMR13",
      "CMR21",
      "CMR26",
      "CMR31",
      "CMR36",
      "RPTCM",
      "RPTC1",
      "RPTC2",
      "RPTMG",
      "RPTSM",
      "HP6N2",
      "3NKD1",
      "3NKD2",
      "3NKD3",
      "3NKD5",
      "3NKD6",
      "3NKD9",
      "HP1N2",
      "HP2N2",
      "HP3N2",
      "HP4N2",
      "O3SM0",
      "O3SM1",
      "OMW02",
      "GPSM3",
      "MM069", % Musique Mix
      "MM070",  % Musique collection
      "OSP20" % Orange Sport
     %%      "OCF01",% Club de foot
     %%      "OCF02",
     %%      "OCF03",
     %%      "OCF04",
     %%      "OCF05",
     %%      "OCF06"     
    ].

text_sv_conso(SOCode)->
    case SOCode of
	"VMPRE"-> "Messagerie Vocale Visuelle";
	"A4SM2"-> "Option SMS illimites";
	"MM044"-> "Option TV Max";
	"OSP01"-> "Option Sport";
	"FGS80" -> "Option SMS 7.5E";
	"SNS80" -> "Option SMS 7.5E";
	"FG80E" -> "Option SMS 7.5E";
	"FG80P" -> "Option SMS 7.5E";
	"FG80S" -> "Option SMS 7.5E";
	"FG80T" -> "Option SMS 7.5E";
	"FJ80S" -> "Option SMS 7.5E";
	"OFR15" -> "Option SMS 7.5E";
	"OFR17" -> "Option SMS 7.5E";
	"OFR18" -> "Option SMS 7.5E";
	"FGX80" -> "Option SMS 7.5E";
	"FG130" -> "Option SMS 12E";
	"F130S" -> "Option SMS 12E";
	"FK130" -> "Option SMS 12E";
	"FGT12" -> "Option SMS 12E";
	"FS21C" -> "Option SMS 18E";
	"FGT18" -> "Option SMS 18E";
	"FS30C" -> "Option SMS 25E";	
	"FGT25" -> "Option SMS 25E";	
        "FGTSL" -> "Option SMS/MMS illimite";
	"O3SM0" -> "Option 3NoKDO SMS";
	"O3SM1" -> "Option 3NoKDO SMS";
	"OMW02" -> "Orange Messenger";
	"OTV13" -> "Option TV";
	"OTV03" -> "Option Totale TV";
	"MM009" -> "Option Musique hits";
	"MM043" -> "Option Internet max";
	"OM012" -> "Option Internet max tv";
	"PORFT" -> "Option Foot";
	"OMUS0" -> "Option Musique";
	"OPSU0" ->"Option Surf";
	"OBTS0" -> "Option TV . Surf";
	"OPCC0" -> "Option dec Multi 3E";
	"OPCC1" -> "Option Internet 6E";
	"OPCC2" -> "Option \\+ d'internet";
	"CMOR3" -> "Option OW 10E";
	"CMOR6" -> "Option OW 10E";
	"CMOR10"-> "Option OW 10E";
	"CMR19" -> "Option OW 10E";
	"CMR24" -> "Option OW 10E";
	"CMR29" -> "Option OW 10E";
	"CMR34" -> "Option OW 10E";
	"CMOR8" -> "Option OW 30E";
	"CMR13" -> "Option OW 30E";
	"CMR21" -> "Option OW 30E";
	"CMR26" -> "Option OW 30E";
	"CMR31" -> "Option OW 30E";
	"CMR36" -> "Option OW 30E";
	"OSP01" -> "Option Sport";
	"HP6N2" -> "Opt encore 5 minutes";
	"HP1N2" -> "Opt mes 2No preferes";
	"HP2N2" -> "Opt mes 2No preferes";
	"HP3N2" -> "Opt mes 2No preferes";
	"HP4N2" -> "Opt mes 2No preferes";
	"RPTCM" -> "Option Report";
	"RPTC1" -> "Option Report";
	"RPTC2" -> "Option Report";
	"RPTMG" -> "Option Report";
	"RPTSM" -> "Option Report";
	"MM031" -> "Option mail";
	"UKC53" -> "Option Unik Fixe";
	"UKC54" -> "Unik Orange et Fixe";
	"UKC56" ->"Option unik pour zap";
	"UKC55"->"Unik internationales";
        "3NKD1"->"Option 3No KDO";
	"3NKD2"->"Option 3No KDO";
	"3NKD3"->"Option 3No KDO";
	"3NKD5"->"Option 3No KDO";
	"3NKD6"->"Option 3No KDO";
	"3NKD9"->"Option 3No KDO";
	"OM011"->"Option Musique";
	"SNS30"->"Option SMS 3E";
	"FG30W"->"Option SMS 3E";
	"FG30U"->"Option SMS 3E";
	"FG30P"->"Option SMS 3E";
	"OF1R4"->"Option SMS 3E";
	"FG30S"->"Option SMS 3E";
	"FJ30S"->"Option SMS 3E";
	"FG80M"->"Option SMS 3E";
	"FG30T"->"Option SMS 3E";
	"OFR24"->"Option SMS 3E";
	"OMI03"->"Option SMS 3E";
	"OFR16"->"Option SMS 3E";
	"FV30S"->"Option SMS 3E";
	"OFR14"->"Option SMS 3E";
	"FGX30"->"Option SMS 3E";
	"GPSM3"->"Option Orange maps";
	"MM069"->"Option Musique Mix";
	"MM070"->"Option Musique collection";
	"OCF03"->"option PSG Mobile";
	"OCF02"->"option OM Mobile";
	"OCF01"->"option OL Mobile";
	"OCF04"->"opt Girondins Mobile";
	"OCF05"->"option RCL Mobile";
	"OCF06"->"option ASSE Mobile";
	"OSP20" ->"option Sport"
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sv_conso_options([],_) -> [];

sv_conso_options([SOCode|Tail], DCL)->
    [
     {title, "SUIVI CONSO "++ text_sv_conso(SOCode) ++ " with SOCode " ++ SOCode }]++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=10000,
						  dlv=pbutil:unixtime(),
						  rnv=0,  			
						  etat=?CETAT_AC}
					 ])++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so=SOCode}) ++
	[
	 {ussd2,
	  [ 
	    {send, test_util_of:access_code(parent(?suivi_conso), ?suivi_conso)},
	    {expect,"1:Suivi conso detaille.*2:Suivi conso options.*3:Gerer mes options"},
	    {send, test_util_of:link_rank(?MODULE, ?suivi_conso, ?gerer_options_2)},
	    {expect,"Gerer mes options.*Vous pouvez modifier chaque option"},
	    {send, "1"},
	    {expect, "1:Souscrire une autre option de la gamme.*2:Supprimer cette option"},
	    {send, "2"},
	    {expect,"Etes-vous sur de vouloir supprimer votre .*Vous perdrez le benefice de celle-ci."},
	    {send, "1"},
	    {expect,"Votre demande a bien ete prise en compte. Vous recevrez sous 48 heures un SMS vous informant de la suppression de votre option"},
	    {send, "1"},
	    {expect,"L'offre Orange"}
	   ]}
	]++
	profile_manager:set_asm_profile(?Uid, #asm_profile{code_so="NOACT"}) ++
	test_util_of:close_session()++
	sv_conso_options(Tail, DCL)++
	[].

cmo_ac_sce() ->
     profile_manager:set_bundles(?Uid,
				 [bundleA("1", ac),
				  bundleB("1"),
				  bundleC("1"),
				  bundleA("2", ac),
				  bundleB("2"),
				  bundleC("2")
				 ]
				)++
 	["Test suivi conso detaille actif",
 	 {ussd2,
 	  [
 	   {send, test_util_of:access_code(parent(?suivi_conso_plus), ?main_page)++"*#"},
 	   {expect, 
 	    "Restant:.* 3h34m11s ou 45SMS.*"
 	    "Repondre.*"
 	    "1:Menu.*"
 	    "2:Suivi conso.*"
 	    "3:Aide"} ,
  	   {send, test_util_of:link_rank(parent(?suivi_conso_plus), ?main_page, ?suivi_conso_plus, [?suivi_conso_plus])},
  	   {expect,"1:Suivi conso detaille.*"
  	    "2:Suivi conso options.*"
  	    "3:Gerer mes options"},
  	   {send, test_util_of:link_rank(?MODULE, ?suivi_conso_plus, ?suivi_conso_detaille_1)},
  	   {expect,"act.: ../...*"},
  	   {send, "1"},
  	   {expect,"solde bonus "},
  	   {send, "1"},
  	   {expect,"3h30m20s ou 60SMS"}
 	  ]}]++

 	["Test suivi conso options actif",
 	 {ussd2,
 	  [
 	   {send, test_util_of:access_code(?MODULE, ?suivi_conso_option_1, ?suivi_conso_plus)},
 	   {expect,"solde bonus "},
 	   {send, "1"},
 	   {expect,"3h30m20s ou 60SMS"}
 	  ]}]++
	[].

cmo_ep_sce() ->
    profile_manager:set_bundles(?Uid,
				[bundleA("2", ep)])++

 	["Test suivi conso detaille without godet C",
 	 {ussd2,
 	  [
 	   {send, test_util_of:access_code(?MODULE, ?suivi_conso_detaille_1, ?suivi_conso_plus)},
 	   {expect,"epuise"}
 	  ]}]++

        ["Test suivi conso options without godet C",
         {ussd2,
          [
	   {send, test_util_of:access_code(?MODULE, ?suivi_conso_option_1, ?suivi_conso_plus)},
	   {expect,"Suivi conso options.*Vous n'avez souscrit a aucune option pour le moment"},
	   {send, "1"},
	   {expect, "L'offre Orange.*"}
	   
	  ]}].

test_restit_LIB_solde_not_available() ->
    profile_manager:set_bundles(?Uid,
				[
				 bundleA("1", ac),
				 bundleB("1"),
				 #spider_bundle{priorityType="C",
						restitutionType="LIB",
						bundleDescription="Internet Max|Vous disposez de l'option Internet Max active avant le$$date ",
 						lastUseDate="2005-06-05T07:08:09.MMMZ",
						bundleLevel="1",
						exhaustedLabel="Internet Max|Votre option Internet Max est suspendue ou ",
						bundleAdditionalInfo="||si a cette date vous disposez de 9E sur votre compte"
					       }
				])++
	["Test suivi conso detaille with restitutionType=LIB - Solde unavailable",
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE, ?suivi_conso_detaille_1, ?suivi_conso_plus)},
           {expect,"cmo_niv1: 3h34m11s ou 45SMS.*Prochaine fact.: .*"},
           {send, "1"},
           {expect,"Vous disposez de l'option Internet Max active avant le 05/06 inclus"}
          ]}].

test_restit_LIB_solde_ac() ->
    profile_manager:set_bundles(?Uid,
				[
				 bundleA("1", ac),
				 bundleB("1"),
				 #spider_bundle{priorityType="C",
						restitutionType="LIB",
						bundleDescription="Internet Max|Vous disposez de l'option Internet Max active avant le$$date ",
 						lastUseDate="2005-06-05T07:08:09.MMMZ",
						bundleLevel="1",
						exhaustedLabel="Internet Max|Votre option Internet Max est suspendue ou ",
						bundleAdditionalInfo="||si a cette date vous disposez de 9E sur votre compte",
						credits=[#spider_credit{name="balance",
									unit="TEMPS",
									value="3h30min20s"
								       },
							 #spider_credit{name="balance",
									unit="SMS",
									value="60"
								       }
							]
                                               }
				])++
        ["Test suivi conso detaille with restitutionType=LIB - Solde > 0",
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE, ?suivi_conso_detaille_1, ?suivi_conso_plus)},
           {expect,"cmo_niv1: 3h34m11s ou 45SMS.*Prochaine fact.: .*"},
           {send, "1"},
           {expect,"Vous disposez de l'option Internet Max active avant le 05/06 inclus"}
          ]}].

test_restit_LIB_solde_ep() ->
    profile_manager:set_bundles(?Uid,
				[
				 bundleA("1", ac),
				 bundleB("1"),
				 #spider_bundle{priorityType="C",
						restitutionType="LIB",
						bundleDescription="Internet Max|Vous disposez de l'option Internet Max active avant le$$date ",
 						lastUseDate="2005-06-05T07:08:09.MMMZ",
						bundleLevel="1",
						exhaustedLabel="Internet Max|Votre option Internet Max est suspendue ou ",
						bundleAdditionalInfo="||si a cette date vous disposez de 9E sur votre compte",
						credits=[#spider_credit{name="balance",
									unit="TEMPS",
									value="0h00min00s"
								       }
							]
					       }
				])++
        ["Test suivi conso detaille with restitutionType=LIB - Solde = 0",
         {ussd2,
          [
           {send, test_util_of:access_code(?MODULE, ?suivi_conso_detaille_1, ?suivi_conso_plus)},
           {expect,"cmo_niv1: 3h34m11s ou 45SMS.*Prochaine fact.: .*"},
           {send, "1"},
           {expect,"Votre option Internet Max est suspendue ou si a cette date vous disposez de 9E sur votre compte"}
          ]}].

bundleA(BundleLevel,Status) ->
    Credits = case Status of
		  ac ->
		      [#spider_credit{name="balance",
				      unit="TEMPS",
				      value="3h34min11s"},
		       #spider_credit{name="balance",
				      unit="SMS",
				      value="45"}
		      ];
		  ep ->
		      [#spider_credit{name="balance",
				      unit="TEMPS",
				      value="0h00min00s"
				     }
		      ]
	      end,
    Descr = case Status of
		ac ->
		    "cmo_niv1";
		ep ->
		    "cmo_niv1_ep"
	    end,
    #spider_bundle{priorityType="A",
		   restitutionType="CPTMOB",
		   bundleDescription=Descr,
		   bundleLevel=BundleLevel,
		   credits=Credits
		  }.

bundleB(BundleLevel) ->
    #spider_bundle{priorityType="B",
		   restitutionType="SOLDE",
		   bundleDescription="solde",
		   bundleLevel=BundleLevel,
		   credits=[#spider_credit{name="balance",
					   unit="TEMPS",
					   value="4h34min13s"},
			    #spider_credit{name="balance",
					   unit="SMS",
					   value="25"}
			   ]
		  }.

bundleC(BundleLevel) ->
    #spider_bundle{priorityType="C",
		   restitutionType="SOLDE",
		   bundleDescription="solde bonus filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling filling",
		   bundleLevel=BundleLevel,
		   credits=[#spider_credit{name="balance",
					   unit="TEMPS",
					   value="3h30min20s"},
			    #spider_credit{name="balance",
					   unit="SMS",
					   value="60"}
			   ]
		  }.
