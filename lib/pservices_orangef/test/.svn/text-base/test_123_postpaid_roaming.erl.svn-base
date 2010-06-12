-module(test_123_postpaid_roaming).
-export([run/0,online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("profile_manager.hrl").

-define(Uid,roaming_postpaid_user).

-define(VLR,    "32495000000"). %%Belgique Camel Zone
-define(VLR_F,    "33495000000").

-define(DIRECT_CODE, "#123*").
-define(DIRECT_CODE_F, "#123*1*1*5").


%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TEXTS Options, Menus, Incompatibilities.& Utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(ZONE_EUROPE,"Europe").
-define(ZONE_MAGHREB,"USA Canada Maghreb Turquie").
-define(ZONE_RDM,"Reste du monde").
-define(ZONE_HORS_EU,"Hors Europe").


-define(LIST_OPTS_EUROPE_VOIX, [
				default,
				opt_pass_voyage_15min_europe_gpro,
				opt_pass_voyage_30min_europe_gpro,
				opt_pass_voyage_60min_europe_gpro,
  				opt_destination_europe_v037_gpro,
  				opt_destination_europe_v038_gpro,
  				opt_suisse_v037_gpro,
  				opt_suisse_v038_gpro,
  				opt_espagne_v037_gpro,
  				opt_espagne_v038_gpro,
  				opt_belgique_v037_gpro,
  				opt_belgique_v038_gpro,
  				opt_italie_v037_gpro,
  				opt_italie_v038_gpro,
  				opt_portugal_v037_gpro,
  				opt_portugal_v038_gpro,
  				opt_royaume_uni_v037_gpro,
  				opt_royaume_uni_v038_gpro,
  				opt_allemagne_v037_gpro,
  				opt_allemagne_v038_gpro,
  				opt_luxembourg_v037_gpro,
  				opt_luxembourg_v038_gpro,
  				opt_dom_v037_gpro,
  				opt_dom_v038_gpro
			       ]).

-define(LIST_OPTS_MAGHREB_VOIX, [
				 default,
				 opt_maroc_v037_gpro,
				 opt_maroc_v038_gpro,
				 opt_algerie_v037_gpro,
				 opt_algerie_v038_gpro
				]).

-define(LIST_OPTS_RDM_VOIX, [
			     default
			    ]).



-define(LIST_OPTS_EUROPE_SMSMMS, [
				  default,
				  opt_pass_voyage_15min_europe_gpro,
				  opt_pass_voyage_30min_europe_gpro,
				  opt_pass_voyage_60min_europe_gpro
				 ]).
-define(LIST_OPTS_MAGHREB_SMSMMS, [
				   default
				  ]).

-define(LIST_OPTS_RDM_SMSMMS, [
			       default
			      ]).

-define(LIST_OPTS_EUROPE_INTERNET, [
				    default,
				    opt_pass_internet_int_jour_2E_gpro,
				    opt_pass_internet_int_jour_5E_gpro,
				    opt_pass_voyage_15min_europe_gpro,
				    opt_pass_voyage_30min_europe_gpro,
				    opt_pass_voyage_60min_europe_gpro,
				    opt_pass_internet_int_5E_gpro,
				    opt_pass_internet_int_20E_gpro,
				    opt_pass_internet_int_35E_gpro
				   ]).

-define(LIST_OPTS_RDM_INTERNET, [
				 default,
				 opt_pass_voyage_15min_maghreb_gpro,
				 opt_pass_voyage_30min_maghreb_gpro,
				 opt_pass_voyage_60min_maghreb_gpro,
				 opt_pass_voyage_15min_rdm_gpro,
				 opt_pass_voyage_30min_rdm_gpro,
				 opt_pass_voyage_60min_rdm_gpro,
				 opt_pass_internet_int_jour_2E_gpro,
				 opt_pass_internet_int_jour_5E_gpro,
				 opt_pass_internet_int_5E_gpro,
				 opt_pass_internet_int_20E_gpro,
				 opt_pass_internet_int_35E_gpro
				]).

-define(MENU_BONS_PLANS,
	"1:Communiquer regulierement vers ou depuis l'etranger."
	"2:Communiquer occasionnellement depuis l'etranger."
	"3:Acceder a Internet depuis l'etranger").

-define(MENU_DEST_PREF,
	"1:En Europe.*"
	"2:Au Maghreb").

-define(MENU_INFO_TARIFS,
	"Choix de l'info tarif a l'etranger:.*"
	"1:Les tarifs voix.*"
	"2:Les tarifs SMS/MMS.*"
	"3:Les tarifs des connexions multimedia").


text_first_page(?DIRECT_CODE) -> %% First page abroad
    "Vos services a l'etranger"
        ".*1:Bons plans tarifs"
	".*2:Suivi conso"
        ".*3:Utiliser votre messagerie"
        ".*4:Quel tarif dans quel pays"
        ".*5:Page accueil France";
text_first_page(?DIRECT_CODE_F) -> %% First page France
    "Bienvenue sur vos services a l'etranger"
	".*1:Bons plans tarifs"
	".*2:Utiliser votre messagerie"
	".*3:Quel tarif dans quel pays.*".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
code_so(Opt)->
    case Opt of 
	opt_destination_europe_v037_gpro -> "EURO1";
	opt_destination_europe_v038_gpro -> "EURO6";
	opt_suisse_v037_gpro-> "OPAY1";
	opt_suisse_v038_gpro-> "OPAY3";
	opt_espagne_v037_gpro-> "OPY03";
	opt_espagne_v038_gpro-> "OPY16";
	opt_belgique_v037_gpro -> "OPY05";
	opt_belgique_v038_gpro -> "OPY17";
	opt_italie_v037_gpro -> "ITAL1";
	opt_italie_v038_gpro -> "ITAL3";	
	opt_portugal_v037_gpro -> "PORT1";
	opt_portugal_v038_gpro -> "PORT4";
	opt_royaume_uni_v037_gpro -> "OPY07";
	opt_royaume_uni_v038_gpro -> "OPY19";
	opt_allemagne_v037_gpro-> "OPY09";
	opt_allemagne_v038_gpro-> "OPY21";
	opt_luxembourg_v037_gpro -> "OPY11";
	opt_luxembourg_v038_gpro -> "OPY24";
	opt_dom_v037_gpro-> "OPY13";
	opt_dom_v038_gpro-> "OPY25";
	opt_maroc_v037_gpro -> "MARO1";
	opt_maroc_v038_gpro -> "MARO3";
	opt_algerie_v037_gpro -> "ALGE1";
	opt_algerie_v038_gpro -> "ALGE3";
	opt_pass_internet_int_5E_gpro -> "IR029";	
	opt_pass_internet_int_20E_gpro -> "IR030";
	opt_pass_internet_int_35E_gpro -> "IR045";
	opt_tarif_jour_zone_europe_gpro-> "DFUM1";	
	opt_10min_europe_gpro -> "EURO4";	
	opt_pass_internet_int_jour_2E_gpro -> "IR053";	
	opt_pass_internet_int_jour_5E_gpro -> "IR050";	
	opt_pass_voyage_15min_europe_gpro -> "PV115";	
	opt_pass_voyage_30min_europe_gpro -> "PV130";	
	opt_pass_voyage_60min_europe_gpro -> "PV160";	
	opt_pass_voyage_15min_maghreb_gpro -> "PV215";	
	opt_pass_voyage_30min_maghreb_gpro -> "PV230";	
	opt_pass_voyage_60min_maghreb_gpro -> "PV260";	
	opt_pass_voyage_15min_rdm_gpro -> "PV315";	
	opt_pass_voyage_30min_rdm_gpro -> "PV330";	
	opt_pass_voyage_60min_rdm_gpro -> "PV360";	
	_ -> "NOACT"
    end.

code_segco(Opt) ->
    case Opt of 
	Opt when Opt==opt_destination_europe_v037_gpro;
		 Opt==opt_suisse_v037_gpro;
		 Opt==opt_espagne_v037_gpro;
		 Opt==opt_belgique_v037_gpro;
		 Opt==opt_italie_v037_gpro;
		 Opt==opt_portugal_v037_gpro;
		 Opt==opt_royaume_uni_v037_gpro;
		 Opt==opt_allemagne_v037_gpro;
		 Opt==opt_luxembourg_v037_gpro;
		 Opt==opt_dom_v037_gpro;
		 Opt==opt_maroc_v037_gpro;
		 Opt==opt_algerie_v037_gpro ->
	    "F1JET";
	_ -> 
	    "CPP01"
    end.



opt_label(Opt)->
    case Opt of 
	Opt_Eur when Opt_Eur==opt_destination_europe_v037_gpro;
		     Opt_Eur==opt_destination_europe_v038_gpro -> "Option destination Europe";
        Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;
		     Opt_Sui==opt_suisse_v038_gpro -> "Option Destination preferee Suisse";
        Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;
		     Opt_Esp==opt_espagne_v038_gpro -> "Option destination preferee Espagne";
        Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;
		     Opt_Bel==opt_belgique_v038_gpro -> "Option destination preferee Belgique";
        Opt_Ita when Opt_Ita==opt_italie_v037_gpro;
		     Opt_Ita==opt_italie_v038_gpro -> "Option destination preferee Italie";
        Opt_Por when Opt_Por==opt_portugal_v037_gpro;
		     Opt_Por==opt_portugal_v038_gpro -> "Option destination preferee Portugal";
        Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;
		     Opt_Roy==opt_royaume_uni_v038_gpro -> "Option destination preferee Royaume-Uni";
        Opt_All when Opt_All==opt_allemagne_v037_gpro;
		     Opt_All==opt_allemagne_v038_gpro -> "Option destination preferee Allemagne";
        Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;
		     Opt_Lux==opt_luxembourg_v038_gpro -> "Option destination preferee Luxembourg";
        Opt_Dom when Opt_Dom==opt_dom_v037_gpro;
		     Opt_Dom==opt_dom_v038_gpro -> "Destination preferee Outre-Mer";
        Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;
		     Opt_Mar==opt_maroc_v038_gpro -> "Option destination preferee Maroc";
        Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;
		     Opt_Alg==opt_algerie_v038_gpro -> "Option destination preferee Algerie";
	opt_10min_europe_gpro-> "10 minutes offertes en Europe";
	opt_tarif_jour_zone_europe_gpro-> "Tarif jour en zone Europe";
	opt_pass_internet_int_jour_2E_gpro -> "pass Internet international jour 2E";
	opt_pass_internet_int_jour_5E_gpro -> "pass Internet international jour 5E";
	opt_pass_internet_int_5E_gpro -> "pass Internet international 5E";
	opt_pass_internet_int_20E_gpro -> "pass Internet international 20E";
	opt_pass_internet_int_35E_gpro -> "pass Internet international 35E";
	opt_pass_voyage_15min_europe_gpro -> "Pass voyage 15mn / 10 SMS / 2 Mo";
	opt_pass_voyage_30min_europe_gpro -> "Pass voyage 15mn / 10 SMS / 2 Mo";
	opt_pass_voyage_60min_europe_gpro -> "Pass voyage 15mn / 10 SMS / 2 Mo";
	opt_pass_voyage_15min_maghreb_gpro -> "Pass voyage 15mn / 10 SMS / 2 Mo";
	opt_pass_voyage_30min_maghreb_gpro -> "Pass voyage 30mn / 10 SMS / 2 Mo";
	opt_pass_voyage_60min_maghreb_gpro -> "Pass voyage 60mn / 10 SMS / 2 Mo";
	opt_pass_voyage_15min_rdm_gpro -> "Pass voyage 15mn / 10 SMS / 2 Mo";
	opt_pass_voyage_30min_rdm_gpro -> "Pass voyage 30mn / 10 SMS / 2 Mo";
	opt_pass_voyage_60min_rdm_gpro -> "Pass voyage 60mn / 10 SMS / 2 Mo";
	default -> "default"
    end.
code_condition(Opt)->
    case Opt of
        X when X == opt_pass_voyage_15min_europe_gpro;
	       X == opt_pass_voyage_30min_europe_gpro;
	       X == opt_pass_voyage_60min_europe_gpro;
	       X == opt_pass_voyage_15min_maghreb_gpro;
	       X == opt_pass_voyage_30min_maghreb_gpro;
	       X == opt_pass_voyage_60min_maghreb_gpro;
	       X == opt_pass_voyage_15min_rdm_gpro;
	       X == opt_pass_voyage_30min_rdm_gpro;
	       X == opt_pass_voyage_60min_rdm_gpro;
	       X == opt_pass_internet_int_5E_gpro;
	       X == opt_pass_internet_int_20E_gpro;
	       X == opt_pass_internet_int_35E_gpro;
	       X == opt_10min_europe_gpro
	       ->"17";
        _->"7"
    end.

opt_code(Opt)->
    case Opt of 
	Opt_Eur	when Opt_Eur==opt_destination_europe_v037_gpro;
		     Opt_Eur==opt_destination_europe_v038_gpro ->                           "1111";
        Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;Opt_Sui==opt_suisse_v038_gpro ->         "1111";
        Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;Opt_Esp==opt_espagne_v038_gpro ->       "1111";
        Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;Opt_Bel==opt_belgique_v038_gpro ->     "11111";
        Opt_Ita when Opt_Ita==opt_italie_v037_gpro;Opt_Ita==opt_italie_v038_gpro ->         "11111";
        Opt_Por when Opt_Por==opt_portugal_v037_gpro;Opt_Por==opt_portugal_v038_gpro ->     "11111";
        Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;Opt_Roy==opt_royaume_uni_v038_gpro -> "111111";
        Opt_All when Opt_All==opt_allemagne_v037_gpro;Opt_All==opt_allemagne_v038_gpro ->   "111111";
        Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;Opt_Lux==opt_luxembourg_v038_gpro -> "111111";
        Opt_Dom when Opt_Dom==opt_dom_v037_gpro;Opt_Dom==opt_dom_v038_gpro ->               "111111";
        Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;Opt_Mar==opt_maroc_v038_gpro ->           "1121";
        Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;Opt_Alg==opt_algerie_v038_gpro ->       "1121";
	opt_10min_europe_gpro->                                                   "1211";
	opt_tarif_jour_zone_europe_gpro->                                                   "131";
	opt_pass_voyage_15min_europe_gpro ->                                                   "1211";
	opt_pass_voyage_30min_europe_gpro ->                                                   "1211";
	opt_pass_voyage_60min_europe_gpro ->                                                   "1211";
	opt_pass_voyage_15min_maghreb_gpro ->                                                   "1221";
	opt_pass_voyage_30min_maghreb_gpro ->                                                   "1221";
	opt_pass_voyage_60min_maghreb_gpro ->                                                   "1221";
	opt_pass_voyage_15min_rdm_gpro ->                                                   "1231";
	opt_pass_voyage_30min_rdm_gpro ->                                                   "1231";
	opt_pass_voyage_60min_rdm_gpro ->                                                   "1231";
	opt_pass_internet_int_jour_2E_gpro ->                                              "1311";
	opt_pass_internet_int_jour_5E_gpro ->                                              "1311";
	opt_pass_internet_int_5E_gpro ->                                                   "1321";
	opt_pass_internet_int_20E_gpro ->                                                   "1321";
	opt_pass_internet_int_35E_gpro ->                                                    "1321"
    end.

link_infos_tarifs(?DIRECT_CODE)->
    "4";
link_infos_tarifs(?DIRECT_CODE_F) ->
    "3".



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
online() ->
    test_util_of:online(?MODULE,test()).


test() ->
    [{title, "Test suite for Selfcare Roaming POSTPAID: ANSI,CAMEL,NO-CAMEL ZONES"}] ++
	profile_manager:create_default(?Uid,"postpaid")++

 	test_postpaid("GP")++
  	test_postpaid("PRO")++
	["Test reussi"] ++
	[].

test_postpaid(Type) ->
    BundleA=#spider_bundle{priorityType="A",
			   restitutionType="FORF",
			   bundleType="0005",
			   bundleDescription="label forf",
			   bundleAdditionalInfo="I1|I2|I3",
			   credits=[#spider_credit{name="balance",unit="MMS",value="40"},
				    #spider_credit{name="rollOver",unit="SMS",value="18"},
				    #spider_credit{name="bonus",unit="TEMPS",value="2h18min48s"}]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    profile_manager:set_bundles(?Uid,[BundleA])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	profile_manager:update_spider(?Uid,profile,{offerPOrSUid,Type})++
	profile_manager:init(?Uid,smpp)++

        set_commercial_date_to_all_options(present)++
 	roaming_from_abroad(Type)++
  	roaming_from_france(Type)++
        [].

roaming_from_france(Type)->
    [{title, "Test Roaming from France "++ Type}]++
	test_util_of:set_vlr(?VLR_F)++

	france_menu(Type)++
	test_menu_pays_prefere(?DIRECT_CODE_F,Type)++
	test_infos_tarifs_menu(?DIRECT_CODE_F,Type)++

     	subscriptions(?DIRECT_CODE_F,Type)++
	infos_tarifs_voix(?DIRECT_CODE_F++"3*1",Type)++
	infos_tarifs_smsmms(?DIRECT_CODE_F++"3*2",Type)++
	infos_tarifs_connexion_data(?DIRECT_CODE_F++"3*3",Type)++
	["Test OK"].


roaming_from_abroad(Type)->
    [{title, "Test Roaming from abroad "++ Type}]++
	test_util_of:set_vlr(?VLR)++

	abroad_menu(Type)++
	test_menu_pays_prefere(?DIRECT_CODE,Type)++
	test_infos_tarifs_menu(?DIRECT_CODE,Type)++

	subscriptions(?DIRECT_CODE,Type)++
     	infos_tarifs_voix(?DIRECT_CODE++"4*1",Type)++ 
        infos_tarifs_smsmms(?DIRECT_CODE++"4*2",Type)++
        infos_tarifs_connexion_data(?DIRECT_CODE++"4*3",Type)++
	[].

subscriptions(Code,Type)->
    [{title, "TEST SUBSCRIPTIONS & MENTIONS LEGALES " ++Type}]++
        test_opts_roaming([
			   opt_destination_europe_v037_gpro,
			   opt_destination_europe_v038_gpro,
			   opt_suisse_v037_gpro,
			   opt_suisse_v038_gpro,
			   opt_espagne_v037_gpro,
			   opt_espagne_v038_gpro,
			   opt_belgique_v037_gpro,
			   opt_belgique_v038_gpro,
			   opt_italie_v037_gpro,
			   opt_italie_v038_gpro,
			   opt_portugal_v037_gpro,
			   opt_portugal_v038_gpro,
			   opt_royaume_uni_v037_gpro,
			   opt_royaume_uni_v038_gpro,
			   opt_allemagne_v037_gpro,
			   opt_allemagne_v038_gpro,
			   opt_luxembourg_v037_gpro,
			   opt_luxembourg_v038_gpro,
			   opt_dom_v037_gpro,
			   opt_dom_v038_gpro,
			   opt_maroc_v037_gpro,
			   opt_maroc_v038_gpro,
			   opt_algerie_v037_gpro,
			   opt_algerie_v038_gpro,
			   opt_pass_internet_int_5E_gpro,
			   opt_pass_internet_int_20E_gpro,
			   opt_pass_internet_int_35E_gpro,
			   opt_10min_europe_gpro,
			   opt_pass_internet_int_jour_2E_gpro,
			   opt_pass_internet_int_jour_5E_gpro,
			   opt_tarif_jour_zone_europe_gpro,
			   opt_pass_voyage_15min_europe_gpro,
			   opt_pass_voyage_30min_europe_gpro,
			   opt_pass_voyage_60min_europe_gpro,
			   opt_pass_voyage_15min_maghreb_gpro,
			   opt_pass_voyage_30min_maghreb_gpro,
			   opt_pass_voyage_60min_maghreb_gpro,
			   opt_pass_voyage_15min_rdm_gpro,
			   opt_pass_voyage_30min_rdm_gpro,
			   opt_pass_voyage_60min_rdm_gpro
			  ],
			  Code,Type)++
        [].

abroad_menu(Type)->
    [
     "POSTPAID Profile "++Type++" connecting from abroad - #123# Main Menu",
     {ussd2,
      [
       {send, ?DIRECT_CODE},
       {expect,text_first_page(?DIRECT_CODE)},
       {send, "1"},
       {expect,?MENU_BONS_PLANS},
       {send,"1"},
       {expect,"1:En Europe."
	"2:Au Maghreb"},
       {send,"1"},
       {expect,"Option Destination preferee Suisse"},
       {send,"82"},
       {expect,"Option destination preferee Maroc"},
       {send,"88"},
       {expect,?MENU_BONS_PLANS},
       {send,"2"},
       {expect,"Choisissez la zone depuis laquelle vous souhaitez communiquer:.*"
	"1:Europe, USA, Canada.*"
	"2:Maghreb, Turquie.*"
	"3:Reste du monde"},
       {send,"83"},
       {expect,".*"}
      ] 
     }
    ]++
	test_util_of:close_session().

france_menu(Type)->    
    set_commercial_date_to_all_options(present)++
	[
	 "POSTPAID Profile "++Type++" connecting from France - #123# Main Menu",
	 {ussd2,
	  [
	   {send, ?DIRECT_CODE_F},
	   {expect,text_first_page(?DIRECT_CODE_F)},
	   {send, "1"},
	   {expect,?MENU_BONS_PLANS},
	   {send, "1"},
	   {expect,"1:En Europe."
	    "2:Au Maghreb"},
	   {send,"8"},
	   {expect,?MENU_BONS_PLANS},
	   {send,"2"},
	   {expect,"Choisissez la zone depuis laquelle vous souhaitez communiquer:."
	    "1:Europe, USA, Canada.*"
	    "2:Maghreb, Turquie.*"
	    "3:Reste du monde"},
	   {send, "83"},
	   {expect,"Choisissez la duree d'utilisation dont vous avez besoin:."
	    "1:Tarif jour en zone Europe."
	    "2:Pass internet valables 24h."
	    "3:Pass internet valables 7 jours"}
	  ] 
	 }
	].

test_menu_pays_prefere(Code,Type) ->
    set_commercial_date_to_all_options(present)++
	[{title, "Test menu options pays preferes: "++Type}]++
 	asmserv_init(?Uid, "NOACT")++	
 	["Test MENU et MENTIONS LEGALES",
 	 {ussd2,
 	  [
 	   {send, Code},
 	   {expect,text_first_page(Code)},
 	   {send, "1*1"},
 	   {expect, ?MENU_DEST_PREF},
 	   {send, "1"},
 	   {expect,"Option Destination preferee Suisse.*"
 	    "Option destination preferee Espagne.*"},
 	   {send,"4"},
 	   {expect,
 	    "Option destination preferee Italie.*"
 	    "Option destination preferee Portugal.*"},
 	   {send,"4"},
 	   {expect,
	    "Option destination preferee Allemagne.*"
	    "Option destination preferee Luxembourg.*"
	    "Destination preferee Outre-Mer"},
 	   {send,"8"},
	   {expect,".*"},
	   {send,"2"},
	   {expect, "1:Option destination preferee Maroc.*"
            "2:Option destination preferee Algerie"}
 	  ]}
 	]++
	test_util_of:close_session().

test_infos_tarifs_menu(Code,Type) ->
    asmserv_init(?Uid, "NOACT")++
	["POSTPAID Profile "++Type++" Infos Tarifs Menu",
	 {ussd2, 
	  [
	   {send, Code++link_infos_tarifs(Code)},
	   {expect,?MENU_INFO_TARIFS}
	  ]}]++
	test_util_of:close_session().


infos_tarifs_voix(Code,Type) ->
    infos_tarifs_voix(Code++"1",Type,?LIST_OPTS_EUROPE_VOIX,?ZONE_EUROPE)++
     	infos_tarifs_voix(Code++"2",Type,?LIST_OPTS_MAGHREB_VOIX,?ZONE_MAGHREB)++
	infos_tarifs_voix(Code++"3",Type,?LIST_OPTS_RDM_VOIX,?ZONE_RDM)++
	[].

infos_tarifs_voix(_,_,[],_) ->
    [];
infos_tarifs_voix(Code,Type,[Option|T],Zone)->
    asmserv_init(?Uid, Option)++
	["## TEST INFO TARIFS VOIX - ZONE "++Zone++" - "++opt_label(Option)++ " Option = " ++ atom_to_list(Option) ++" - "++Type,
         {ussd2,
          [
           {send, Code}
	  ]++
	  test_info_tarifs_voix(Option,Zone)
	 }]++
	asmserv_init(?Uid, "NOACT")++
	test_util_of:close_session()++

	infos_tarifs_voix(Code,Type,T,Zone).

infos_tarifs_smsmms(Code,Type) ->
    infos_tarifs_smsmms(Code++"1",Type, ?LIST_OPTS_EUROPE_SMSMMS, ?ZONE_EUROPE)++
	infos_tarifs_smsmms(Code++"2",Type, ?LIST_OPTS_MAGHREB_SMSMMS, ?ZONE_MAGHREB)++
	infos_tarifs_smsmms(Code++"2",Type, ?LIST_OPTS_RDM_SMSMMS, ?ZONE_RDM)++
	[].

infos_tarifs_smsmms(_,_,[],_) ->
    [];
infos_tarifs_smsmms(Code,Type,[Option|T],Zone)->
    asmserv_init(?Uid, Option)++
	["## TEST INFO TARIFS SMS MMS - ZONE "++Zone++" - "++opt_label(Option)++" - "++Type,
         {ussd2,
          [
           {send, Code}
	  ]++
	  test_info_tarifs_smsmms(Option,Zone)
	 }]++
	asmserv_init(?Uid, "NOACT")++
	test_util_of:close_session()++

	infos_tarifs_smsmms(Code,Type,T,Zone).

infos_tarifs_connexion_data(Code,Type) ->    
    infos_tarifs_connexion_data(Code++"1",Type,?LIST_OPTS_EUROPE_INTERNET, ?ZONE_EUROPE)++
	infos_tarifs_connexion_data(Code++"2",Type,?LIST_OPTS_RDM_INTERNET, ?ZONE_HORS_EU)++
	[].

infos_tarifs_connexion_data(_,_,[],_) ->
    [];
infos_tarifs_connexion_data(Code,Type,[Option|T],Zone) ->
    asmserv_init(?Uid, Option)++
	["## TEST INFO TARIFS Connexion Data - ZONE "++Zone++" - "++opt_label(Option)++" - "++Type,
         {ussd2,
          [
           {send, Code}
	  ]++
	  test_info_tarifs_internet(Option,Zone)
	 }]++
	asmserv_init(?Uid, "NOACT")++
	test_util_of:close_session()++

	infos_tarifs_connexion_data(Code,Type,T,Zone).


test_opts_roaming([],_,_) ->
    [];
test_opts_roaming([Opt|T],Code,Type) ->
    [{title, "Test "++opt_label(Opt)}]++
	asmserv_init(?Uid, "NOACT",Opt)++
 	test_opts_roaming_men_leg(Opt,Code,Type)++
 	test_opts_roaming_souscription(Opt,Code,Type)++

        test_opts_roaming(T,Code,Type)++
        [].


test_opts_roaming_men_leg(Opt,Code,Type) ->
    set_commercial_date_to_all_options(past)++
	test_util_of:set_present_commercial_date(Opt,postpaid)++        
 	["TEST MENTIONS LEGALES Option = "++atom_to_list(Opt),
 	 {ussd2,
 	  [
	   {send, Code++opt_code(Opt)++code_condition(Opt)}
 	  ]++
	  test_men_leg(Opt)
	 }
 	].

test_opts_roaming_souscription(Opt,Code,Type) ->
    set_commercial_date_to_all_options(past)++
	test_util_of:set_present_commercial_date(Opt,postpaid)++        
  	["TEST SOUSCRIPTION" ,
  	 {ussd2,
  	  [
  	   {send, Code++opt_code(Opt)},
  	   {expect,".*"}
	  ]++

	  case Opt of
	      X when X==opt_destination_europe_v037_gpro;X==opt_destination_europe_v038_gpro ->
		  [];
	      _ ->
		  [
		   {send, "1"},
		   {expect,".*"}
		  ]
	  end++

	  [
  	   {send, "1"},
	   {expect,".*"},
  	   {send, "1"},
   	   {expect,".*"},
	   {send, "1"},
	   {expect,".*"}
  	  ] 
	 }
  	]++
	test_util_of:close_session().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DESCRIPTION TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expect_text(description1, Opt) ->
    case Opt of
        Opt_Eur when Opt_Eur==opt_destination_europe_v037_gpro;Opt_Eur==opt_destination_europe_v038_gpro ->
	    "Option destination Europe 10E/mois:vos appels vers et depuis l'Europe au tarif national \\+ 60min/mois pour vos appels recus en Europe";
        Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;Opt_Sui==opt_suisse_v038_gpro ->
	    "Option destination preferee Suisse, 5E/mois : vos appels vers et depuis la Suisse au tarif national \\+ 60 minutes/mois pour";
        Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;Opt_Esp==opt_espagne_v038_gpro ->
	    "Option destination preferee Espagne, 5E/mois :vos appels vers et depuis l'Espagne au tarif national \\+ 60 minutes/mois pour";
        Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;Opt_Bel==opt_belgique_v038_gpro ->
	    "Option destination preferee Belgique, 5E/mois : vos appels vers et depuis la Belgique au tarif national \\+ 60 minutes/mois";
        Opt_Ita when Opt_Ita==opt_italie_v037_gpro;Opt_Ita==opt_italie_v038_gpro ->
	    "Option destination preferee Italie, 5E/mois : vos appels vers et depuis l'Italie au tarif national \\+ 60 minutes/mois pour";
        Opt_Por when Opt_Por==opt_portugal_v037_gpro;Opt_Por==opt_portugal_v038_gpro ->
	    "Option destination preferee Portugal, 5E/mois : vos appels vers et depuis le Portugal au tarif national \\+ 60 min/mois pour";
        Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;Opt_Roy==opt_royaume_uni_v038_gpro ->
	    "Option destination preferee Royaume-Uni 5E/mois: vos appels vers et depuis le Royaume-Uni au tarif national \\+ 60 mn/mois pour";
        Opt_All when Opt_All==opt_allemagne_v037_gpro;Opt_All==opt_allemagne_v038_gpro ->
	    "Option destination preferee Allemagne, 5E/mois : vos appels vers et depuis l'Allemagne au tarif national \\+ 60 min/mois pour";
        Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;Opt_Lux==opt_luxembourg_v038_gpro ->
	    "Option destination preferee Luxembourg, 5E/mois: vos appels vers et depuis le Luxembourg au tarif national \\+ 60 min/mois pour";
        Opt_Dom when Opt_Dom==opt_dom_v037_gpro;Opt_Dom==opt_dom_v038_gpro ->
	    "Option destination preferee outre-mer, 5E/mois : vos appels vers et depuis les destinations d'outre-mer au tarif national \\+";
        Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;Opt_Mar==opt_maroc_v038_gpro ->
	    "Option destination preferee Maroc, 9E/mois: vos appels vers et depuis le Maroc au tarif national \\+ 60 min/mois pour";
        Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;Opt_Alg==opt_algerie_v038_gpro ->
	    "Option destination preferee Algerie, 9E/mois: vos appels vers et depuis l'Algerie au tarif national \\+ 60 min/mois pour";
        opt_pass_internet_int_5E_gpro ->
	    "pass Internet international 5E : disposez de 3Mo d'echange de donnees depuis les pays de la zone Europe ou 2Mo depuis les pays";
        opt_pass_internet_int_20E_gpro ->
	    "pass Internet international 20E : disposez de 20Mo d'echange de donnees depuis les pays de la zone Europe ou 13Mo depuis les pays";
        opt_pass_internet_int_35E_gpro ->
	    "pass Internet international 35E : disposez de 50Mo d'echange de donnees depuis les pays de la zone Europe ou 34Mo depuis les"
    end++
	case Opt of
	    Opt_Eur when Opt_Eur==opt_destination_europe_v037_gpro;Opt_Eur==opt_destination_europe_v038_gpro ->
		".*1:Souscrire";
	    _ ->
		".*1:Suite"
	end;

expect_text(description2, Opt) ->
    case Opt of
        Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;Opt_Sui==opt_suisse_v038_gpro ->
	    "recevoir vos appels en Suisse";
        Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;Opt_Esp==opt_espagne_v038_gpro ->
	    "recevoir vos appels en Espagne";
        Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;Opt_Bel==opt_belgique_v038_gpro ->
	    "pour recevoir vos appels en Belgique";
        Opt_Ita when Opt_Ita==opt_italie_v037_gpro;Opt_Ita==opt_italie_v038_gpro ->
	    "recevoir vos appels en Italie";
        Opt_Por when Opt_Por==opt_portugal_v037_gpro;Opt_Por==opt_portugal_v038_gpro ->
	    "recevoir vos appels au Portugal";
        Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;Opt_Roy==opt_royaume_uni_v038_gpro ->
	    "recevoir vos appels au Royaume-Uni";
        Opt_All when Opt_All==opt_allemagne_v037_gpro;Opt_All==opt_allemagne_v038_gpro ->
	    "recevoir vos appels en Allemagne";
        Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;Opt_Lux==opt_luxembourg_v038_gpro ->
	    "recevoir vos appels au Luxembourg";
        Opt_Dom when Opt_Dom==opt_dom_v037_gpro;Opt_Dom==opt_dom_v038_gpro ->
	    "60 minutes/mois pour recevoir vos appels dans les destinations d'outre-mer";
        Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;Opt_Mar==opt_maroc_v038_gpro ->
	    "recevoir vos appels au Maroc";
        Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;Opt_Alg==opt_algerie_v038_gpro ->
	    "recevoir vos appels en Algerie";
        opt_pass_internet_int_5E_gpro ->
	    "des zones Maghreb/USA/Canada/Turquie et reste du monde, valables pendant 7 jours, dans \\+ de 190 destinations";
        opt_pass_internet_int_20E_gpro ->
	    "des zones Maghreb/USA/Canada/Turquie et reste du monde, valables pendant 7 jours, dans plus de 190 destinations";
        opt_pass_internet_int_35E_gpro ->
	    "pays des zones Maghreb/USA/Canada/Turquie et reste du monde, valables pendant 7 jours, dans plus de 190 destinations";
        opt_pass_internet_int_iphone_gpro ->
	    "depuis les destinations des zones Maghreb/USA/Canada/Turquie et reste du monde, valables pendant 24heures, dans plus de 190 destinations."
    end++
	".*1:Souscrire";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SOUSCRIPTION TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expect_text(souscription, Opt) ->
    "Souscription.*"++
	case Opt of
	    Opt_Eur when Opt_Eur==opt_destination_europe_v037_gpro;Opt_Eur==opt_destination_europe_v038_gpro ->
		"Vous allez souscrire a l'option destination Europe. Votre compte sera debite de 10E tous les mois.";
	    Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;Opt_Sui==opt_suisse_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Suisse. Votre compte sera debite de 5E tous les mois.";
	    Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;Opt_Esp==opt_espagne_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Espagne. Votre compte sera debite de 5E tous les mois.";
	    Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;Opt_Bel==opt_belgique_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Belgique. Votre compte sera debite de 5E tous les mois. ";
	    Opt_Ita when Opt_Ita==opt_italie_v037_gpro;Opt_Ita==opt_italie_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Italie. Votre compte sera debite de 5E tous les mois.";
	    Opt_Por when Opt_Por==opt_portugal_v037_gpro;Opt_Por==opt_portugal_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Portugal. Votre compte sera debite de 5E tous les mois.";
	    Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;Opt_Roy==opt_royaume_uni_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Royaume-Uni. Votre compte sera debite de 5E tous les mois.";
	    Opt_All when Opt_All==opt_allemagne_v037_gpro;Opt_All==opt_allemagne_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Allemagne. Votre compte sera debite de 5E tous les mois.";
	    Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;Opt_Lux==opt_luxembourg_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Luxembourg. Votre compte sera debite de 5E tous les mois.";
	    Opt_Dom when Opt_Dom==opt_dom_v037_gpro;Opt_Dom==opt_dom_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee outre-mer. Votre compte sera debite de 5E tous les mois.";
	    Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;Opt_Mar==opt_maroc_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Maroc. Votre compte sera debite de 9E tous les mois.";
	    Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;Opt_Alg==opt_algerie_v038_gpro ->
		"Vous allez souscrire a l'option destination preferee Algerie. Votre compte sera debite de 9E tous les mois.";
	    opt_pass_internet_int_5E_gpro ->
		"Vous allez souscrire au pass Internet international 5E. Votre compte sera debite de 5E. L'option est valable 7 jours consecutifs.";
	    opt_pass_internet_int_20E_gpro ->
		"Vous allez souscrire au pass Internet international 20E. Votre compte sera debite de 20E. L'option est valable 7 jours consecutifs.";
	    opt_pass_internet_int_35E_gpro ->
		"Vous allez souscrire au pass Internet international 35E. Votre compte sera debite de 35E. L'option est valable 7 jours consecutifs.";
	    opt_pass_internet_int_iphone_gpro ->
		"Vous allez souscrire au pass Internet international iPhone. Votre compte sera debite de 5E. L'option est valable 24 heures."
	end++
	".*1:Valider";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VALIDATION TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expect_text(validation1, Opt) ->
    "Validation.*"++
	case Opt of
	    Opt_Eur when Opt_Eur==opt_destination_europe_v037_gpro;Opt_Eur==opt_destination_europe_v038_gpro ->
		"Vous avez souscrit a l'option destination Europe, vos appels depuis les pays de la zone Europe vers ces pays et la France metro et depuis la";
	    Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;Opt_Sui==opt_suisse_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Suisse, vos appels depuis la Suisse vers ce pays et la France metropolitaine et depuis";
	    Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;Opt_Esp==opt_espagne_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Espagne, vos appels depuis l'Espagne vers ce pays et la France metropolitaine et depuis";
	    Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;Opt_Bel==opt_belgique_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Belgique, vos appels depuis la Belgique vers ce pays et la France metropolitaine et";
	    Opt_Ita when Opt_Ita==opt_italie_v037_gpro;Opt_Ita==opt_italie_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Italie, vos appels depuis l'Italie vers ce pays et la France metropolitaine et depuis";
	    Opt_Por when Opt_Por==opt_portugal_v037_gpro;Opt_Por==opt_portugal_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Portugal, vos appels depuis le Portugal vers ce pays et la France metropolitaine et";
	    Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;Opt_Roy==opt_royaume_uni_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Royaume-Uni, vos appels depuis le Royaume-Uni vers ce pays et la France metrop. et depuis";
	    Opt_All when Opt_All==opt_allemagne_v037_gpro;Opt_All==opt_allemagne_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Allemagne, vos appels depuis l'Allemagne vers ce pays et la France metrop. et depuis";
	    Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;Opt_Lux==opt_luxembourg_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Luxembourg, vos appels depuis le Luxembourg vers ce pays et la France metrop. et depuis";
	    Opt_Dom when Opt_Dom==opt_dom_v037_gpro;Opt_Dom==opt_dom_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee outre-mer, vos appels depuis les destinations d'outre-mer vers la France metropolitaine";
	    Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;Opt_Mar==opt_maroc_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Maroc, vos appels depuis le Maroc vers ce pays et la France metrop. et depuis";
	    Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;Opt_Alg==opt_algerie_v038_gpro ->
		"Vous avez souscrit a l'option destination preferee Algerie, vos appels depuis l'Algerie vers ce pays et la France metrop. et depuis";
	    opt_pass_internet_int_5E_gpro ->
		"Vous avez souscrit au pass Internet international 5E, vous avez 3Mo pour vos echanges de donnees en zone Europe ou 2Mo dans les";
	    opt_pass_internet_int_20E_gpro ->
		"Vous avez souscrit au pass Internet international 20E, vous avez 20Mo pour vos echanges de donnees en zone Europe ou 13Mo dans les";
	    opt_pass_internet_int_35E_gpro ->
		"Vous avez souscrit au pass Internet international 35E, vous avez 50Mo pour vos echanges de donnees en zone Europe ou 34Mo dans les";
	    opt_pass_internet_int_iphone_gpro ->
		"Vous avez souscrit au pass Internet international iPhone, vous avez 10Mo pour vos echanges de donnees en zone Europe ou 6,9Mo dans les"
	end++
	".*1:Suite";

expect_text(validation2, Opt) ->
    case Opt of
        Opt_Eur when Opt_Eur==opt_destination_europe_v037_gpro;Opt_Eur==opt_destination_europe_v038_gpro ->
	    "France metro vers les pays de la zone Europe sont au tarif National, vous avez 60 min/mois pour vos appels recus en zone Europe";
        Opt_Sui when Opt_Sui==opt_suisse_v037_gpro;Opt_Sui==opt_suisse_v038_gpro ->
	    "la France metropolitaine vers la Suisse sont au tarif National, vous avez 60 minutes d'appels recus par mois en Suisse.";
        Opt_Esp when Opt_Esp==opt_espagne_v037_gpro;Opt_Esp==opt_espagne_v038_gpro ->
	    "la France metropolitaine vers l'Espagne sont au tarif National, vous avez 60 minutes d'appels recus par mois en Espagne";
        Opt_Bel when Opt_Bel==opt_belgique_v037_gpro;Opt_Bel==opt_belgique_v038_gpro ->
	    "depuis la France metropolitaine vers la Belgique sont au tarif National, vous avez 60 minutes d'appels recus par mois en Belgique.";
        Opt_Ita when Opt_Ita==opt_italie_v037_gpro;Opt_Ita==opt_italie_v038_gpro ->
	    "la France metropolitaine vers l'Italie sont au tarif National, vous avez 60 minutes d'appels recus par mois en Italie.";
        Opt_Por when Opt_Por==opt_portugal_v037_gpro;Opt_Por==opt_portugal_v038_gpro ->
	    "depuis la France metropolitaine vers le Portugal sont au tarif National, vous avez 60 minutes d'appels recus par mois au Portugal.";
        Opt_Roy when Opt_Roy==opt_royaume_uni_v037_gpro;Opt_Roy==opt_royaume_uni_v038_gpro ->
	    "la France metropolitaine vers le Royaume-Uni sont au tarif National, vous avez 60 minutes d'appels recus par mois au Royaume-Uni.";
        Opt_All when Opt_All==opt_allemagne_v037_gpro;Opt_All==opt_allemagne_v038_gpro ->
	    "la France metropolitaine vers l'Allemagne sont au tarif National, vous avez 60 mn d'appels recus par mois en Allemagne.";
        Opt_Lux when Opt_Lux==opt_luxembourg_v037_gpro;Opt_Lux==opt_luxembourg_v038_gpro ->
	    "la France metropolitaine vers le Luxembourg sont au tarif National, vous avez 60 minutes d'appels recus par mois au Luxembourg.";
        Opt_Dom when Opt_Dom==opt_dom_v037_gpro;Opt_Dom==opt_dom_v038_gpro ->
	    "et ces destinations et depuis la France metropolitaine vers ces destinations sont au tarif National \\+ 60 mn d'appels recus par mois";
        Opt_Mar when Opt_Mar==opt_maroc_v037_gpro;Opt_Mar==opt_maroc_v038_gpro ->
	    "la France metropolitaine vers le Maroc sont au tarif National, vous avez 60 minutes d'appels recus par mois au Maroc.";
        Opt_Alg when Opt_Alg==opt_algerie_v037_gpro;Opt_Alg==opt_algerie_v038_gpro ->
	    "la France metropolitaine vers l'Algerie sont au tarif National, vous avez 60 minutes d'appels recus par mois en Algerie.";
        opt_pass_internet_int_5E_gpro ->
	    "autres zones, valables pendant 7 jours, dans plus de 190 destinations \\(reseaux partenaires en 3G\\+/3G/EDGE/GPRS\\)";
        opt_pass_internet_int_20E_gpro ->
	    "autres zones, valables pendant 7 jours, dans plus de 190 destinations \\(reseaux partenaires en 3G\\+/3G/EDGE/GPRS\\)";
        opt_pass_internet_int_35E_gpro ->
	    "autres zones, valables pendant 7 jours, dans plus de 190 destinations \\(reseaux partenaires en 3G\\+/3G/EDGE/GPRS\\)";
        opt_pass_internet_int_iphone_gpro ->
	    "autres zones, valables pendant 24 heures, dans plus de 190 destinations \\(reseaux partenaires en 3G\\+/3G/EDGE/GPRS\\)"
    end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONDITIONS TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_men_leg(Opt) 
  when Opt==opt_10min_europe_gpro;
Opt==opt_pass_internet_int_jour_2E_gpro;
Opt==opt_pass_internet_int_jour_5E_gpro;
Opt==opt_tarif_jour_zone_europe_gpro;
Opt==opt_pass_voyage_15min_europe_gpro;
Opt==opt_pass_voyage_30min_europe_gpro;
Opt==opt_pass_voyage_60min_europe_gpro;
Opt==opt_pass_voyage_15min_maghreb_gpro;
Opt==opt_pass_voyage_30min_maghreb_gpro;
Opt==opt_pass_voyage_60min_maghreb_gpro;
Opt==opt_pass_voyage_15min_rdm_gpro;
Opt==opt_pass_voyage_30min_rdm_gpro;
Opt==opt_pass_voyage_60min_rdm_gpro->

    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ];

test_men_leg(Opt)
  when Opt==opt_destination_europe_v037_gpro;Opt==opt_destination_europe_v038_gpro ->
    Price = case Opt of
		opt_destination_europe_v037_gpro ->
		    "0,37";
		opt_destination_europe_v038_gpro ->
		    "0,38"
	    end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis les destinations de la zone Europe vers ces destinations ou la France metropolitaine, ou depuis la France metropolitaine.*1:Suite"},
     {send, "1"},
     {expect, "vers les destinations de la zone Europe. Appels decomptes a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une.*1:Suite"},
     {send, "1"},
     {expect, "communication nationale au-dela du forfait, soit "++Price++"E/min. Pour les clients Origami first, first plus et first pour iPhone,.*1:Suite"},
     {send, "1"},
     {expect, "le tarif de l'option est applique en lieu et place des tarifs applicables dans ces forfaits vers les fixes de la zone Europe..*1:Suite"},
     {send, "1"},
     {expect, "Credit de communication voix de 60 min pour les appels recus dans les destinations de la zone Europe, non reportable d'un mois sur l'autre..*1:Suite"},
     {send, "1"},
     {expect, "En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la souscription d'une autre option relative.*1:Suite"},
     {send, "1"},
     {expect, "aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_suisse_v037_gpro;Opt==opt_suisse_v038_gpro ->
    Price = case Opt of
                opt_suisse_v037_gpro ->
                    "0,37";
                opt_suisse_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis la Suisse vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers la Suisse. Appels decomptes.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes en Suisse. Credit de communication voix de 60 minutes pour les appels recus en Suisse,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_espagne_v037_gpro;Opt==opt_espagne_v038_gpro ->
    Price = case Opt of
                opt_espagne_v037_gpro ->
                    "0,37";
                opt_espagne_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis l'Espagne vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers l'Espagne. Appels decomptes.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes en Espagne. Credit de communication voix de 60 minutes pour les appels recus en Espagne,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_belgique_v037_gpro;Opt==opt_belgique_v038_gpro ->
    Price = case Opt of
                opt_belgique_v037_gpro ->
                    "0,37";
                opt_belgique_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis la Belgique vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers la Belgique. Appels decomptes.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes en Belgique. Credit de communication voix de 60 minutes pour les appels recus en Belgique,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_italie_v037_gpro;Opt==opt_italie_v038_gpro ->
    Price = case Opt of
                opt_italie_v037_gpro ->
                    "0,37";
                opt_italie_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis l'Italie vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers l'Italie. Appels.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes en Italie. Credit de communication voix de 60 minutes pour les appels recus en Italie,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_portugal_v037_gpro;Opt==opt_portugal_v038_gpro ->
    Price = case Opt of
                opt_portugal_v037_gpro ->
                    "0,37";
                opt_portugal_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis le Portugal vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers le Portugal. Appels.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes au Portugal. Credit de communication voix de 60 minutes pour les appels recus au Portugal,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_royaume_uni_v037_gpro;Opt==opt_royaume_uni_v038_gpro ->
    Price = case Opt of
                opt_royaume_uni_v037_gpro ->
                    "0,37";
                opt_royaume_uni_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis le Royaume-Uni vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers le Royaume-Uni. Appels.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes au Royaume-Uni. Credit de communication voix de 60 minutes pour les appels recus au Royaume-Uni.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_allemagne_v037_gpro;Opt==opt_allemagne_v038_gpro ->
    Price = case Opt of
                opt_allemagne_v037_gpro ->
                    "0,37";
                opt_allemagne_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis l'Allemagne vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers l'Allemagne. Appels.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes en Allemagne. Credit de communication voix de 60 minutes pour les appels recus en Allemagne,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_luxembourg_v037_gpro;Opt==opt_luxembourg_v038_gpro ->
    Price = case Opt of
                opt_luxembourg_v037_gpro ->
                    "0,37";
                opt_luxembourg_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis le Luxembourg vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers le Luxembourg. Appels.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes au Luxembourg. Credit de communication voix de 60 minutes pour les appels recus au Luxembourg,.*1:Suite"},
     {send, "1"},
     {expect, "non reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_dom_v037_gpro;Opt==opt_dom_v038_gpro ->
    Price = case Opt of
                opt_dom_v037_gpro ->
                    "0,37";
                opt_dom_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis les destinations suivantes : Guadeloupe, Martinique, Reunion, Guyane, Mayotte, Saint Barthelemy, Saint Martin et Saint.*1:Suite"},
     {send, "1"},
     {expect, "Pierre & Miquelon vers ces destinations ou la France metropolitaine, ou depuis la France metropolitaine vers ces destinations. Appels.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la sec. apres une 1re min indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit "++Price++"E/min..*1:Suite"},
     {send, "1"},
     {expect, "Pour les clients Origami first, first plus et first pour iPhone, le tarif de l'option est applique en lieu et place des tarifs.*1:Suite"},
     {send, "1"},
     {expect, "applicables dans ces forfaits vers les fixes des destinations d'outre-mer. Credit de communication voix de 60 min pour les appels recus dans.*1:Suite"},
     {send, "1"},
     {expect, "les destinations suivantes: Guadeloupe, Martinique, Reunion, Guyane, Mayotte, Saint Barthelemy, Saint Martin et Saint Pierre & Miquelon, non.*1:Suite"},
     {send, "1"},
     {expect, "reportable d'un mois sur l'autre. En cas de resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la.*1:Suite"},
     {send, "1"},
     {expect, "souscription d'une autre option Destination preferee, ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_maroc_v037_gpro;Opt==opt_maroc_v038_gpro ->
    Price = case Opt of
                opt_maroc_v037_gpro ->
                    "0,37";
                opt_maroc_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis le Maroc vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers le Maroc. Appels.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit.*1:Suite"},
     {send, "1"},
     {expect, ""++Price++"E/min. Credit de communication voix de 60 minutes pour les appels recus au Maroc, non reportable d'un mois sur l'autre. En cas de.*1:Suite"},
     {send, "1"},
     {expect, "resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la souscription d'une autre option Destination preferee,.*1:Suite"},
     {send, "1"},
     {expect, "ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt)
  when Opt==opt_algerie_v037_gpro;Opt==opt_algerie_v038_gpro ->
    Price = case Opt of
                opt_algerie_v037_gpro ->
                    "0,37";
                opt_algerie_v038_gpro ->
                    "0,38"
            end,
    [
     {expect, "Offre soumise a condition. Option mensuelle sans engagement, valable apres acceptation du dossier par Orange France, sur les communications.*1:Suite"},
     {send, "1"},
     {expect, "voix emises depuis l'Algerie vers ce pays ou la France metropolitaine, ou depuis la France metropolitaine vers l'Algerie. Appels.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la seconde apres une 1re minute indivisible. Appels emis au tarif d'une communication nationale au-dela du forfait, soit.*1:Suite"},
     {send, "1"},
     {expect, ""++Price++"E/min. Credit de communication voix de 60 minutes pour les appels recus en Algerie, non reportable d'un mois sur l'autre. En cas de.*1:Suite"},
     {send, "1"},
     {expect, "resiliation, le credit restant est perdu. Option non cumulable et incompatible avec la souscription d'une autre option Destination preferee,.*1:Suite"},
     {send, "1"},
     {expect, "ainsi qu'avec toute autre offre relative aux appels vers et depuis l'etranger."}
    ];

test_men_leg(Opt) 
  when Opt==opt_pass_internet_int_5E_gpro;Opt==opt_pass_internet_int_20E_gpro;Opt==opt_pass_internet_int_35E_gpro->
    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ].



test_messagerie() ->
    [
     {expect, "Pour consulter votre messagerie vocale : composez le 888 depuis votre mobile ou le \\+ \\(ou 00\\) 33608080808 depuis votre mobile ou.*1:Suite"},
     {send, "1"},
     {expect, "une ligne fixe et laissez-vous guider. Attention : dans certains pays, votre code secret vous sera demande pour interroger votre.*1:Suite"},
     {send, "1"},
     {expect, "messagerie vocale. N'oubliez pas d'enregistrer votre code avant votre depart. L'activation ou la modification de votre code secret doit.*1:Suite"},
     {send, "1"},
     {expect, "se faire depuis la France metropolitaine. Avant de partir a l'etranger, composez le : 888 choisissez l'option 2 et laissez-vous guider..*1:Suite"},
     {send, "1"},
     {expect, "Faites un essai de votre code confidentiel en composant le \\+\\(ou 00\\) 33608080808 puis laissez-vous guider. Retenez bien votre code secret..*1:Suite"},
     {send, "1"},
     {expect, "Cout de consultation de la messagerie vocale a l'etranger = cout d'une communication vers la France metro \\(voir fiche tarifaire en vigueur\\)."}
    ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INFO TARIFS VOIX TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_info_tarifs_voix(default,?ZONE_EUROPE) ->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour vos.*1:Suite"},
     {send, "1"},
     {expect, "appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E"},
     {send, "1"},
     {expect, "Suisse et Andorre = 1E\\). Prix/min des appels recus depuis la zone Europe = 0,23E..*1:Suite"},
     {send, "1"},
     {expect, "Vos appels sont hors forfait \\(sauf forfaits pro, Origami.*1:Suite"},
     {send, "1"},
     {expect, "emis et des la 1ere seconde pour les appels recus.*1:Suite"},
     {send, "1"},
     {expect, "indivisible\\). En cas d'appel vers une autre zone..*1:Suite"},
     {send, "1"},
     {expect, "Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];


test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_destination_europe_v037_gpro;Opt==opt_destination_europe_v038_gpro ->
    Price = case Opt of
		opt_destination_europe_v037_gpro -> "0,37";
		opt_destination_europe_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = "++Price++"E/min.*1:Suite"},
     {send, "1"},
     {expect, "dans le cadre de votre option Destination Europe. Prix/min des appels recus depuis la zone Europe =gratuit a hauteur de 60 min/mois.*1:Suite"},
     {send, "1"},
     {expect, "dans le cadre de votre option Destination Europe au dela = 0,23E \\(sauf Suisse et Andorre = 0,30E\\)..*1:Suite"},
     {send, "1"},
     {expect, "Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec au-dela de la 1ere min indivisible, les appels.*1:Suite"},
     {send, "1"},
     {expect, "recus au dela des 60 min sont decomptes a la sec. des la 1ere seconde \\(sauf Suisse et Andorre : appels recus decomptes a la seconde.*1:Suite"},
     {send, "1"},
     {expect, "au-dela de la 1ere min indivisible\\). En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique..*1:Suite"},
     {send, "1"},
     {expect, "Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_suisse_v037_gpro;Opt==opt_suisse_v038_gpro ->
    Price = case Opt of
                opt_suisse_v037_gpro -> "0,37";
                opt_suisse_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Andorre = 1E et Suisse = "++Price++"E/min dans le cadre de votre option destination preferee\\). Prix/min des appels recus depuis la zone.*1:Suite"},
     {send, "1"},
     {expect, "Europe = 0,23E \\(sauf Andorre =0,30E et Suisse = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination preferee,.*1:Suite"},
     {send, "1"},
     {expect, "au dela = 0,30E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30 sec..*1:Suite"},
     {send, "1"},
     {expect, "pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse et Andorre : appels emis et recus decomptes a la seconde.*1:Suite"},
     {send, "1"},
     {expect, "au-dela de la 1ere min indivisible\\). En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique..*1:Suite"},
     {send, "1"},
     {expect, "Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_espagne_v037_gpro;Opt==opt_espagne_v038_gpro ->
    Price = case Opt of
                opt_espagne_v037_gpro -> "0,37";
                opt_espagne_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre = 1E et Espagne = "++Price++"E/min dans le cadre de votre option destination preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe = 0,23E \\(sauf Suisse et Andorre = 0,30E et Espagne = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee au dela = 0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de.*1:Suite"},
     {send, "1"},
     {expect, "30 secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Espagne : appels emis et recus.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la seconde au-dela de la 1ere min indivisible\\), les appels recus en Espagne, au dela des 60 min gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1ere seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_belgique_v037_gpro;Opt==opt_belgique_v038_gpro ->
    Price = case Opt of
                opt_belgique_v037_gpro -> "0,37";
                opt_belgique_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre = 1E et Belgique = "++Price++"E/min dans le cadre de votre option destination preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe = 0,23E \\(sauf Suisse et Andorre =0,30E et Belgique = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee au dela=0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30.*1:Suite"},
     {send, "1"},
     {expect, "secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Belgique : appels emis et recus.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la seconde au-dela de la 1ere min indivisible\\), les appels recus en Belgique, au dela des 60 min gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1ere seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_italie_v037_gpro;Opt==opt_italie_v038_gpro ->
    Price = case Opt of
                opt_italie_v037_gpro -> "0,37";
                opt_italie_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre = 1E et Italie = "++Price++"E/min dans le cadre de votre option destination preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe = 0,23E \\(sauf Suisse et Andorre =0,30E et Italie = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee au dela=0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30.*1:Suite"},
     {send, "1"},
     {expect, "secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Italie : appels emis et recus decomptes.*1:Suite"},
     {send, "1"},
     {expect, "a la seconde au-dela de la 1ere min indivisible\\), les appels recus en Italie, au dela des 60 min gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1ere seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_portugal_v037_gpro;Opt==opt_portugal_v038_gpro ->
    Price = case Opt of
                opt_portugal_v037_gpro -> "0,37";
                opt_portugal_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre= 1E et Portugal = "++Price++"E/min dans le cadre de votre option destination preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe=0,23E \\(sauf Suisse et Andorre =0,30E et Portugal = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee, au dela=0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30.*1:Suite"},
     {send, "1"},
     {expect, "secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Portugal : appels emis et recus.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la sec au-dela de la 1ere min indivisible\\), les appels recus au Portugal, au dela des 60 min gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1ere seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_royaume_uni_v037_gpro;Opt==opt_royaume_uni_v038_gpro ->
    Price = case Opt of
                opt_royaume_uni_v037_gpro -> "0,37";
                opt_royaume_uni_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre = 1E et Royaume-Uni = "++Price++"E/min dans le cadre de votre option dest. preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe = 0,23E \\(sauf Suisse et Andorre=0,30E et Royaume-Uni=gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee, au dela=0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30.*1:Suite"},
     {send, "1"},
     {expect, "secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Royaume-Uni : appels emis et recus.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la sec au-dela de la 1ere min indivisible\\), les appels recus au Royaume-Uni, au dela des 60 mn gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1re seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_allemagne_v037_gpro;Opt==opt_allemagne_v038_gpro ->
    Price = case Opt of
                opt_allemagne_v037_gpro -> "0,37";
                opt_allemagne_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre =1E et Allemagne = "++Price++"E/min dans le cadre de votre option destination preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe =0,23E \\(sauf Suisse et Andorre=0,30E et Allemagne=gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee, au dela=0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30.*1:Suite"},
     {send, "1"},
     {expect, "secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Allemagne : appels emis et recus.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la sec au-dela de la 1ere min indivisible\\), les appels recus en Allemagne, au dela des 60 min gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1ere seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_luxembourg_v037_gpro;Opt==opt_luxembourg_v038_gpro ->
    Price = case Opt of
                opt_luxembourg_v037_gpro -> "0,37";
                opt_luxembourg_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre = 1E et Luxembourg = "++Price++"E/min dans le cadre de votre option dest. preferee\\). Prix/min des appels recus depuis la.*1:Suite"},
     {send, "1"},
     {expect, "zone Europe=0,23E \\(sauf Suisse et Andorre =0,30E et Luxembourg = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee au dela=0,23E\\). Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec apres un palier de 30.*1:Suite"},
     {send, "1"},
     {expect, "secondes pour les appels emis et des la 1ere seconde pour les appels recus \\(sauf Suisse, Andorre et Luxembourg : appels emis et recus.*1:Suite"},
     {send, "1"},
     {expect, "decomptes a la sec au-dela de la 1ere min indivisible\\), les appels recus au Luxembourg, au dela des 60 mn gratuites sont decomptes a la.*1:Suite"},
     {send, "1"},
     {expect, "seconde des la 1ere seconde. En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans.*1:Suite"},
     {send, "1"},
     {expect, "la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)
  when Opt==opt_dom_v037_gpro;Opt==opt_dom_v038_gpro ->
    Price = case Opt of
                opt_dom_v037_gpro -> "0,37";
                opt_dom_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Europe. Prix/min des appels emis depuis et vers la zone Europe = 0,51E \\(sauf.*1:Suite"},
     {send, "1"},
     {expect, "Suisse et Andorre=1E et Guadeloupe, Martinique, Reunion, Guyane, Mayotte, St Barthelemy, St Martin et St Pierre&Miquelon = "++Price++"E/min.*1:Suite"},
     {send, "1"},
     {expect, "dans le cadre de votre option destination preferee outre-mer\\). Prix/min des appels recus depuis: la zone Europe=0,23E \\(sauf Suisse et.*1:Suite"},
     {send, "1"},
     {expect, "Andorre=0,30E et Guadeloupe, Martinique, Reunion, Guyane, Mayotte, St Barthelemy, St Martin et St Pierre &Miquelon = gratuit a hauteur de.*1:Suite"},
     {send, "1"},
     {expect, "60 mn/mois dans le cadre de votre option destination preferee outre-mer, au dela =0,23E. Vos appels sont hors forfait \\(sauf forfaits pro,.*1:Suite"},
     {send, "1"},
     {expect, "Origami first et Jet\\) et decomptes a la sec apres un palier de 30 secondes pour les appels emis et des la 1ere seconde pour les appels.*1:Suite"},
     {send, "1"},
     {expect, "recus \\(sauf Suisse et Andorre et les destinations d'outre mer: appels emis et recus decomptes a la sec. au-dela de la 1ere min indivisible\\),.*1:Suite"},
     {send, "1"},
     {expect, "les appels recus dans les destinations d'Outre-Mer, au dela des 60 min gratuites sont decomptes a la seconde des la 1ere seconde. En cas.*1:Suite"},
     {send, "1"},
     {expect, "d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans la fiche tarifaire en vigueur ou.*1:Suite"},
     {send, "1"},
     {expect, "sur www.orange.fr/travel"}
    ];


test_info_tarifs_voix(default,?ZONE_MAGHREB) ->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Maghreb/USA/Canada/Turquie. Prix/min des appels emis depuis et vers la zone.*1:Suite"},
     {send, "1"},
     {expect, "Maghreb/USA/Canada/Turquie=1,18E. Prix/min des appels recus depuis la zone Maghreb/USA/Canada/Turquie = 0,55E. Vos appels sont hors forfait.*1:Suite"},
     {send, "1"},
     {expect, "\\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec au-dela de la 1ere min indivisible. En cas d'appel vers une autre zone,.*1:Suite"},
     {send, "1"},
     {expect, "le tarif de la zone le plus eleve est applique. Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];


test_info_tarifs_voix(Opt,?ZONE_MAGHREB)
  when Opt==opt_maroc_v037_gpro;Opt==opt_maroc_v038_gpro ->
    Price = case Opt of
		opt_maroc_v037_gpro -> "0,37";
		opt_maroc_v038_gpro -> "0,38"
	    end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Maghreb/USA/Canada/Turquie. Prix/min des appels emis depuis et vers la zone.*1:Suite"},
     {send, "1"},
     {expect, "Maghreb/USA/Canada/Turquie=1,18E, sauf au Maroc = "++Price++"E/min dans le cadre de votre option dest. preferee\\). Prix/min des appels recus.*1:Suite"},
     {send, "1"},
     {expect, "depuis la zone Maghreb/USA/Canada/Turquie=0,55E \\(sauf Maroc = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee, au dela=0,55E\\). Vos appels sont decomptes a la seconde au-dela de la 1ere min indivisible. En cas d'appel vers une autre zone, le.*1:Suite"},
     {send, "1"},
     {expect, "tarif de la zone le plus eleve est applique. Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_MAGHREB)
  when Opt==opt_algerie_v037_gpro;Opt==opt_algerie_v038_gpro ->
    Price = case Opt of
                opt_algerie_v037_gpro -> "0,37";
                opt_algerie_v038_gpro -> "0,38"
            end,
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone Maghreb/USA/Canada/Turquie. Prix/min des appels emis depuis et vers la zone.*1:Suite"},
     {send, "1"},
     {expect, "Maghreb/USA/Canada/Turquie=1,18E, sauf en Algerie = "++Price++"E/min dans le cadre de votre option dest. preferee\\). Prix/min des appels recus.*1:Suite"},
     {send, "1"},
     {expect, "depuis la zone Maghreb/USA/Canada/Turquie=0,55E \\(sauf Algerie = gratuit a hauteur de 60 min/mois dans le cadre de votre option destination.*1:Suite"},
     {send, "1"},
     {expect, "preferee, au dela=0,55E\\). Vos appels sont decomptes a la seconde au-dela de la 1ere min indivisible. En cas d'appel vers une autre zone, le.*1:Suite"},
     {send, "1"},
     {expect, "tarif de la zone le plus eleve est applique. Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(default,?ZONE_RDM) ->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Un seul tarif est applique pour.*1:Suite"},
     {send, "1"},
     {expect, "vos appels vers la France Metro ou les destinations de la zone reste du monde. Prix/min des appels emis depuis et vers la zone Reste du.*1:Suite"},
     {send, "1"},
     {expect, "monde = 2,90E. Prix/min des appels recus depuis la zone \"Reste du monde\" = 1,40E..*1:Suite"},
     {send, "1"},
     {expect, "Vos appels sont hors forfait \\(sauf forfaits pro, Origami first et Jet\\) et decomptes a la sec au-dela de la 1ere min indivisible..*1:Suite"},
     {send, "1"},
     {expect, "En cas d'appel vers une autre zone, le tarif de la zone le plus eleve est applique. Voir detail des zones dans la fiche tarifaire en vigueur.*1:Suite"},
     {send, "1"},
     {expect, "ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_voix(Opt,?ZONE_EUROPE)->
    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INFO TARIFS SMS MMS TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_info_tarifs_smsmms(default,?ZONE_EUROPE) ->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Prix des SMS envoyes depuis et vers.*1:Suite"},
     {send, "1"},
     {expect, "la France Metro ou les destinations de la zone Europe =0,13E/SMS sauf Suisse et Andorre=0,28E/SMS, prix des SMS vers les autres zones =0,28E.*1:Suite"},
     {send, "1"},
     {expect, "la reception des SMS est gratuite. Prix des MMS envoyes depuis la zone Europe = 1,10E/MMS, prix des MMS recus en zone Europe = 0,80E/MMS..*1:Suite"},
     {send, "1"},
     {expect, "Vos SMS/MMS envoyes depuis l'etranger sont hors forfait sauf forfaits pro, Origami first et jet\\).*1:Suite"},
     {send, "1"},
     {expect, "Voir detail des zones dans la fiche tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_smsmms(Opt,?ZONE_EUROPE) ->
    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ];

test_info_tarifs_smsmms(default,?ZONE_MAGHREB) ->
    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ];

test_info_tarifs_smsmms(default,?ZONE_RDM) ->
    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INFO TARIFS DATA TEXTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_info_tarifs_internet(Opt,?ZONE_EUROPE) when 
  Opt == opt_pass_internet_int_5E_gpro; Opt == opt_pass_internet_int_20E_gpro; Opt == opt_pass_internet_int_35E_gpro->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web.*1:Suite"},
     {send, "1"},
     {expect, "Prix des connexions multimedia depuis"},
     {send, "1"},
     {expect, "Europe"},
     {send, "1"},
     {expect, "international"},
     {send, "1"},
     {expect, "Voir detail des zones dans la"},
     {send,"1"},
     {expect,".*"}
    ];

test_info_tarifs_internet(default,?ZONE_HORS_EU) ->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web.*1:Suite"},
     {send, "1"},
     {expect, "Prix des connexions multimedia depuis"},
     {send, "1"},
     {expect, "Vos connexions depuis l'etranger sont decomptees par"},
     {send, "1"},
     {expect, "tarifaire en vigueur ou sur www.orange.fr/travel"}
    ];

test_info_tarifs_internet(Opt,?ZONE_HORS_EU) when
Opt == opt_pass_internet_int_5E_gpro; Opt == opt_pass_internet_int_20E_gpro; Opt == opt_pass_internet_int_35E_gpro->
    [
     {expect, "Avec Orange, vous beneficiez des meilleurs tarifs quel que soit l'operateur etranger qui vous accueille. Connexions multimedia = wap/web.*1:Suite"},
     {send, "1"},
     {expect, "Prix des connexions multimedia depuis"},
     {send, "1"},
     {expect, "Hors connexions"},
     {send, "1"},
     {expect, "Blackberry : facturees hors pass"},
     {send, "1"},
     {expect, "13,31E/Mo. Vos connexions depuis"}
    ];

test_info_tarifs_internet(Opt,_) ->
    [
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"},
     {send, "1"},
     {expect, ".*"}
    ].
asmserv_init(Uid,"NOACT") ->
    profile_manager:set_asm_profile(?Uid,#asm_profile{code_so="NOACT"});

asmserv_init(Uid,Opt)->
    profile_manager:set_asm_profile(?Uid,#asm_profile{code_so=code_so(Opt),
						      code_segco=code_segco(Opt)}).
asmserv_init(Uid,"NOACT",Opt) ->
    profile_manager:set_asm_profile(?Uid,#asm_profile{code_segco=code_segco(Opt)}).

set_commercial_date_to_all_options(Time) when Time==present; Time==past->
    Fun=list_to_atom("set_"++atom_to_list(Time)++"_commercial_date"),
    lists:append([test_util_of:Fun(Opt,postpaid)||Opt<-
						      [
						       opt_destination_europe_v037_gpro,
						       opt_destination_europe_v038_gpro,
						       opt_suisse_v037_gpro,
						       opt_suisse_v038_gpro,
						       opt_espagne_v037_gpro,
						       opt_espagne_v038_gpro,
						       opt_belgique_v037_gpro,
						       opt_belgique_v038_gpro,
						       opt_italie_v037_gpro,
						       opt_italie_v038_gpro,
						       opt_portugal_v037_gpro,
						       opt_portugal_v038_gpro,
						       opt_royaume_uni_v037_gpro,
						       opt_royaume_uni_v038_gpro,
						       opt_allemagne_v037_gpro,
						       opt_allemagne_v038_gpro,
						       opt_luxembourg_v037_gpro,
						       opt_luxembourg_v038_gpro,
						       opt_dom_v037_gpro,
						       opt_dom_v038_gpro,
						       opt_maroc_v037_gpro,
						       opt_maroc_v038_gpro,
						       opt_algerie_v037_gpro,
						       opt_algerie_v038_gpro,
						       opt_pass_internet_int_jour_2E_gpro,
						       opt_pass_internet_int_jour_5E_gpro,
						       opt_10min_europe_gpro,
						       opt_tarif_jour_zone_europe_gpro,
						       opt_pass_internet_int_5E_gpro,
						       opt_pass_internet_int_20E_gpro,
						       opt_pass_internet_int_35E_gpro,
						       opt_pass_voyage_15min_europe_gpro,
						       opt_pass_voyage_30min_europe_gpro,
						       opt_pass_voyage_60min_europe_gpro,
						       opt_pass_voyage_15min_maghreb_gpro,
						       opt_pass_voyage_30min_maghreb_gpro,
						       opt_pass_voyage_60min_maghreb_gpro,
						       opt_pass_voyage_15min_rdm_gpro,
						       opt_pass_voyage_30min_rdm_gpro,
						       opt_pass_voyage_60min_rdm_gpro
						      ]]).
