-module(test_123_mobi_bons_plans_votre_multimedia).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("profile_manager.hrl").

-define(Uid,multimedia_user).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    application:start(pservices_orangef),
    test_code_domaine_is_no_defini(),
    ok.

test_code_domaine_is_no_defini()->
    "**"=svc_spider:produit2codedomaine("IEM","1111111").
online() ->
    test_util_of:reset_prisme_counters(prisme_counters()),
    test_util_of:online(?MODULE,test_votre_multimedia()),
    test_util_of:test_kenobi(prisme_counters()),
    ok.

prisme_counters() ->
    [{"MO","PB21", 4},
     {"MO","AB21", 6},
     {"MO","MB21", 4},

     {"MO","PB20", 6},
     {"MO","AB20", 12},
     {"MO","MB20", 6},
     {"MO","SCONOK", 184}     
    ].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dcl_label(DCL) ->
    case DCL of
        ?mobi->
            "Mobi (DCL=0)";
	?umobile->
            "U-Mobile (DCL=70)";
        ?mobi_janus->
            "Mobi Janus (DCL=110)";
        ?OM_mobile->
            "Foot (DCL=42)";
        ?CLUB_FOOT->
            "Foot (DCL=87)";
        ?m6_prepaid->
            "M6 prepaid (DCL=35)";
        ?click_mobi->
            "Click (DCL=51)"
    end.

%% Menu Bons plans Votre multimedia
code_menu_multimedia(DCL)->
    case DCL of
	?mobi->		%% DCL=0
	    "#123*2*4*4";
	?umobile->	%% DCL=70
	    "#123*2*3*2*4";
	?mobi_janus->	%% DCL=110
	    "#123*2*4*4";
	?OM_mobile->	%% DCL=42
	    "#123*2*3*2*5";
	?CLUB_FOOT->	%% DCL=87
	    "#123*2*3*2*5";
	?m6_prepaid->	%% DCL=35
	    "#123*1*2*3";	   
	?click_mobi-> 	%% DCL=51
	    "#123*2*3*2*4"
    end.
code_opts(inactive,opt_orange_sport,DCL) ->
    code_menu_multimedia(DCL)++"64";
code_opts(_,opt_orange_sport,DCL)->
    code_menu_multimedia(DCL)++"65";
code_opts(_,opt_foot_ligue1,DCL)->
    code_menu_multimedia(DCL)++"661";
code_opts(_,_,DCL) ->
    code_menu_multimedia(DCL)++"6".
%% Intenet Max Journee
code_option(opt_internet_max_journee, DCL) ->
    code_menu_multimedia(DCL)++"1";

%% Intenet Max Week end
code_option(opt_internet_max_weekend, DCL) ->
    code_menu_multimedia(DCL)++"2";

%% Internet
code_option(opt_internet, DCL) ->
    code_menu_multimedia(DCL)++
	case DCL of
	    ?umobile ->
		"1";
	    _ ->
		"3"
	end;

%% Mail
code_option(opt_mail, DCL) ->
    code_menu_multimedia(DCL)++"5";

%% TV
code_option(opt_tv, DCL) ->
    code_menu_multimedia(DCL)++
        case DCL of
            ?umobile ->
                "2";
	    Foot when Foot==?OM_mobile;
		      Foot==?CLUB_FOOT->
		"63";
            _ ->
                "61"
        end;

code_option(opt_musique, DCL) ->
    code_menu_multimedia(DCL)++
        case DCL of
            ?umobile ->
                "3";
            _ ->
                "65"
        end;
%% Musique mix
code_option(opt_musique_mix, DCL) ->
    code_menu_multimedia(DCL)++
        case DCL of
            ?umobile ->
                "3";
	    Foot when Foot==?OM_mobile;
                      Foot==?CLUB_FOOT->
		"61";
            _ ->
                "62"
        end;

%% Musique collection
code_option(opt_musique_collection, DCL) ->
    code_menu_multimedia(DCL)++
        case DCL of
            ?umobile ->
                "4";
	    Foot when Foot==?OM_mobile;
                      Foot==?CLUB_FOOT->
		"62";
            _ ->
                "63"
        end;

%% Orange sport
code_option(opt_orange_sport, DCL) ->
    code_menu_multimedia(DCL)++"64";

%% Mes donnees +30Go
code_option(opt_mes_donnees, DCL) ->
    code_menu_multimedia(DCL)++"65";

%% Visio
code_option(opt_visio, DCL) ->
    code_menu_multimedia(DCL)++
        case DCL of
            ?umobile ->
                "5";
            _ ->
                "65"
        end;

%% Others options
code_option(_, DCL) ->
    code_menu_multimedia(DCL)++"661". 

top_num(Opt) ->
    svc_options:top_num(Opt,mobi).

test_votre_multimedia() ->	
    [{title, "TEST BONS PLANS VOTRE MULTIMEDIA"}]++
	test_menu_multimedia()++
    	test_opt_multimedia()++
      	test_opt_multimedia_promo()++

	["Test reussi"].

test_opt_multimedia() ->		
    [{title, "TEST BONS PLANS OPTIONS MULTIMEDIA"}]++
    	lists:append([test_opt_multimedia(OPT,DCL)||
   			 OPT<-[
			       opt_internet,
			       opt_internet_max,
			       opt_tv,
			       opt_tv_max,
			       opt_musique,
			       opt_musique_mix,
			       opt_musique_collection,
			       opt_mail,
			       opt_internet_max_journee,
			       opt_internet_max_weekend,
			       opt_orange_sport,
			       opt_foot_ligue1,
			       opt_mes_donnees,
			       opt_tv_mensu
%   			       opt_visio
    			      ],
    		 	 DCL<-[?mobi,
     			       ?OM_mobile,
     			       ?m6_prepaid,
     			       ?click_mobi,
                               ?umobile
     			      ]])++

	[].

test_opt_multimedia_promo() ->
    test_opt_multimedia_promo(opt_tv,?mobi)++
	test_opt_multimedia_promo(opt_tv,?click_mobi)++
	[].

test_menu_multimedia() ->
    [{title, "TEST MENU MULTIMEDIA"}]++
	test_menu(?mobi)++
    	test_menu(?click_mobi)++
  	test_menu(?m6_prepaid)++
    	test_menu(?OM_mobile)++
    	test_menu(?mobi_janus)++
 	test_menu(?CLUB_FOOT)++
 	test_menu(?umobile)++
	[].

test_menu(DCL) ->
    profile_manager:create_default(?Uid,"mobi")++
	profile_manager:set_dcl(?Uid,DCL)++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
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
						  ptf_num=?PBONS_PLANS}])++
	profile_manager:init(?Uid)++
	[{title, "Test menu Bons plans Votre multimedia - "++dcl_label(DCL)},
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL)},
	   {expect, expect_menu(DCL)},
	   {send, "6"},
	   {expect, expect_menu_suite(DCL)},
	   {send, "6"},
           {expect, expect_menu_suite2(DCL)}
	  ]
	 }
	]++

	case DCL of
	    ?umobile ->
		[];
	    _ ->
		init_sachem(opt_foot_ligue1)++
		    [{title, "Test menu bons plans Votre multimdeida - Link Option Orange foot - "++dcl_label(DCL)},
		     {ussd2,
		      [
		       {send, code_menu_multimedia(DCL)},
		       {expect, ".*"},
		       {send, "6"},
		       {expect, ".*"},
                       {send, "6"},
		       {expect, "Option Orange foot.*"}
		      ]
		     }
		    ]
	end++

	test_util_of:close_session().

expect_menu(DCL) ->
    case DCL of
	?umobile ->
	    "1:Option Internet.*"
		"2:Option TV.*"
		"3:Option Musique mix.*"
		"4:Option Musique collection.*"
		"5:Activer la Visio";
	_DCL when _DCL==?CLUB_FOOT;
		  _DCL==?OM_mobile->
	     "1:BP Journee Internet Max.*"
                "2:BP week end Internet Max.*"
                "3:Option Internet.*"
		"4:Option Internet max.*"
                "5:Option mail.*"
                "6:Suite";
	_  ->
	    "1:BP Journee Internet Max.*"
		"2:BP week end Internet Max.*"
		"3:Option Internet.*"
                "4:Option Internet max.*"
		"5:Option mail.*"
		"6:Suite"
    end.

expect_menu_suite(DCL) ->
    case DCL of
	?umobile -> ".*";
	_DCL when _DCL==?CLUB_FOOT;
		  _DCL==?OM_mobile->
	    "1:Option Musique mix.*"
		"2:Option Musique collection.*"
		"3:Option TV.*"
                "4:Option Sport.*"
                "5:Mes donnees \\+30Go.*"
                "6:Suite.*";
	_  ->
	    "1:Option TV.*"
		"2:Option Musique mix.*"
		"3:Option Musique collection.*"
		"4:Option Sport.*"
		"5:Mes donnees \\+30Go.*"
		"6:Suite.*"
    end.
expect_menu_suite2(DCL) ->
    case DCL of
	?umobile->
	    ".*";
	_ ->
	    "1:Activer la Visio"
    end.

test_musique_mix(out_of_commercial_date,DCL)->
    init_test(DCL) ++
	set_past_period(opt_musique_mix) ++
	init_sachem(opt_musique_mix)++
	[{title, "Votre Multimedia - option Musique mix - Not in commercial date - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique mix - Without link Musique Mix  - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL)},
	   {expect, ".*"},
	   {send, "6"},
	   {expect, ".*"}
	  ]}];

test_musique_mix(souscriptions, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_mix) ++
	init_sachem(no_option)++	
	[{title, "Votre Multimedia - option Musique mix inactive - Test Souscriptions - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique mix - Test Souscriptions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_option(opt_musique_mix,DCL)},
	   {expect,"Avec l'option musique mix, telechargez 10 titres / mois et regardez les clips et ecoutez les radios en illimite sur Orange World.*1:Souscrire.*"},
	   {send,"1"},
	   {expect,"Vous allez souscrire a l'option musique mix pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois.*1:Valider"},
	   {send,"1"},
	   {expect,"Vous avez souscrit a l'option musique mix pour 6E.Ce montant a ete debite de votre compte. Attention:l'option musique mix sera active dans 48 heures."
	    ".*9:Accueil"}
	  ]}];

test_musique_mix(conditions, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_mix) ++
	init_sachem(opt_musique_mix)++
	[{title, "Votre Multimedia - option Musique mix active - Test conditions - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique mix - Test conditions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  []++
	   case DCL of
	       ?umobile->
		   [{send, code_menu_multimedia(DCL) ++"4"}];
	       _->
		   [{send, code_menu_multimedia(DCL) ++ "65"}]
	   end++
	  [
	   {expect,"7:Conditions.*"},
	   {send,"7"},
	   {expect,"Option Musique mix a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Orange incluant le telechargement.*1:Suite"},
	   {send, "1"},
	   {expect,"d'au moins 10 titres et offres Internet everywhere\\). Option incompatible avec l'option Musique collection.Telechargement.*1:Suite"},
	   {send, "1"},
	   {expect,"de 10 titres musicaux par mois parmi le catalogue de titres eligible a l'option \\(hors rubriques classique et jazz\\). Nombre de titres.*1:Suite"},
	   {send, "1"},
	   {expect,"decomptes en mois calendaire. Titres supplementaires et hors catalogue proposes a l'achat a 0.99E/titre. Titres telechargeables depuis.*1:Suite"},
	   {send, "1"},
	   {expect,"mobile et ordinateur \\(PC/Mac\\). Titres telecharges sur le mobile non transferables. Navigation illimitee sur le portail Orange World..*1:Suite"},
	   {send, "1"},
	   {expect,"Consultation illimitee sur le portail Orange World des videos des rubriques musique, actualite, sport \\(hors evenements sportifs.*1:Suite"},
	   {send, "1"},
	   {expect,"en direct\\) et cinema \\(hors Orange cinema series\\). Consultation illimitee des chaines TV musicales \\(NRJ Hit, MCM top, MCM pop, M6 Music,.*1:Suite"},
	   {send, "1"},
	   {expect,"M6 Black, M6 Music club, Trace TV, Trace Tropical\\). Ecoute illimitee des radios sur le portail Orange World. Liste des chaines TV.*1:Suite"},
	   {send, "1"},
	   {expect,"musicales et radios susceptible d'evolution. Ne sont pas compris dans l'option, les contenus et services payants. Pour une qualite de.*1:Suite"},
	   {send, "1"},
	   {expect,"service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages.*1:Suite"},
	   {send, "1"},
	   {expect,"en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Telechargements et ecoute des radios.*1:Suite"},
	   {send, "1"},
	   {expect,"non accessibles sur terminaux iPhone. Titres telecharges depuis un ordinateur lisibles et transferables sur terminaux iPhone. Voir.*1:Suite"},
	   {send, "1"},
	   {expect,"details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.*"}
	  ]}];

test_musique_mix(suppression, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_mix) ++
	init_sachem(opt_musique_mix)++
	[{title, "Votre Multimedia - option Musique mix activee - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique mix activee - Test Suppression - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  []++
	  case DCL of
	      ?umobile->
		  [{send, code_menu_multimedia(DCL) ++"4"}];
	      _->
		  [{send, code_menu_multimedia(DCL) ++ "65"}]
	  end++
          [
	    {expect, "Votre option Musique mix est actuellement activee.*"
	     "1:Supprimer l'option.*"
	     "7:Conditions.*"},
	    {send,"1"},
	    {expect,"Merci de confirmer la suppression de votre option Musique mix."
	     "Si vous supprimez votre option maintenant,"},
	    {send,"1"},
	    {expect,"vous perdez immediatement le benefice de celle-ci."},
	    {send,"1"},
	    {expect,"La suppression de votre option Musique mix a bien ete prise en compte.."
	     "Merci de votre appel."
	     ".*9:Accueil"}
	   ]}];

test_musique_mix(reactivation,DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_mix) ++
	init_sachem([opt_musique_mix], "S") ++
	[{title, "Votre Multimedia - option Musique mix suspendue - Test Reactivation - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique mix suspendue - Test Reactivation - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  []++
           case DCL of
               ?umobile->
                   [{send, code_menu_multimedia(DCL) ++"4"}];
               _->
                   [{send, code_menu_multimedia(DCL) ++ "65"}]
           end++
          [
	    {expect, "Votre Option Musique mix est actuellement suspendue.."},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de clips et radios en illimite,"
	     " ni des 10 titres a telecharger, pour seulement 6E.*"
	     "1:Reactiver l'option."
	     "2:Supprimer l'option.*"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option Musique mix pour 6E. "
	     "Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois."},
	    {send,"1"},
	    {expect,"la reactivation de votre option Musique mix a bien ete prise en compte. "
	     "6E ont ete debites de votre compte"
	     ".*9:Accueil"}, %% If faudra valider compte principale ...etc
	    {send,"1"},
	    {expect,"Attention : votre option Musique mix sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++

	init_sachem([opt_musique_mix], "S") ++
	[{title, "Votre Multimedia - option Musique mix suspendue - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique mix supendue - Test Suppression - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  []++
	  case DCL of
	      ?umobile->
		  [{send, code_menu_multimedia(DCL) ++"4"}];
	      _->
		  [{send, code_menu_multimedia(DCL) ++ "65"}]
	  end++
          [
	   {expect, "Votre Option Musique mix est actuellement suspendue.."},
	   {send,"1"},
	    {expect,"Vous ne beneficiez plus de clips et radios en illimite,"
	     " ni des 10 titres a telecharger, pour seulement 6E.*"
	     "1:Reactiver l'option."
	     "2:Supprimer l'option.*"},
	    {send, "2"},
	    {expect,"Merci de confirmer la suppression de votre option Musique mix."
	     "Si vous supprimez votre option maintenant,"},
	    {send,"1"},
	    {expect,"vous perdez immediatement le benefice de celle-ci."},
	    {send,"1"},
	    {expect,"La suppression de votre option Musique mix a bien ete prise en compte.."
	     "Merci de votre appel."
	     ".*9:Accueil"}
	   ]}]++
	[].

test_musique(conditions, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique) ++
	init_sachem(opt_musique)++
	[{title, "Votre Multimedia - option Musique activee - Test conditions - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique activee - Test conditions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_option(opt_musique, DCL)},
	   {expect,"7:Conditions.*"},
	   {send,"7"},
	   {expect,"Option Musique mix a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Orange incluant le telechargement.*1:Suite"},
	   {send, "1"},
	   {expect,"d'au moins 10 titres et offres Internet everywhere\\). Option incompatible avec l'option Musique collection.Telechargement.*1:Suite"},
	   {send, "1"},
	   {expect,"de 10 titres musicaux par mois parmi le catalogue de titres eligible a l'option \\(hors rubriques classique et jazz\\). Nombre de titres.*1:Suite"},
	   {send, "1"},
	   {expect,"decomptes en mois calendaire. Titres supplementaires et hors catalogue proposes a l'achat a 0.99E/titre. Titres telechargeables depuis.*1:Suite"},
	   {send, "1"},
	   {expect,"mobile et ordinateur \\(PC/Mac\\). Titres telecharges sur le mobile non transferables. Navigation illimitee sur le portail Orange World..*1:Suite"},
	   {send, "1"},
	   {expect,"Consultation illimitee sur le portail Orange World des videos des rubriques musique, actualite, sport \\(hors evenements sportifs.*1:Suite"},
	   {send, "1"},
	   {expect,"en direct\\) et cinema \\(hors Orange cinema series\\). Consultation illimitee des chaines TV musicales \\(NRJ Hit, MCM top, MCM pop, M6 Music,.*1:Suite"},
	   {send, "1"},
	   {expect,"M6 Black, M6 Music club, Trace TV, Trace Tropical\\). Ecoute illimitee des radios sur le portail Orange World. Liste des chaines TV.*1:Suite"},
	   {send, "1"},
	   {expect,"musicales et radios susceptible d'evolution. Ne sont pas compris dans l'option, les contenus et services payants. Pour une qualite de.*1:Suite"},
	   {send, "1"},
	   {expect,"service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages.*1:Suite"},
	   {send, "1"},
	   {expect,"en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Telechargements et ecoute des radios.*1:Suite"},
	   {send, "1"},
	   {expect,"non accessibles sur terminaux iPhone. Titres telecharges depuis un ordinateur lisibles et transferables sur terminaux iPhone. Voir.*1:Suite"},
	   {send, "1"},
	   {expect,"details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.*"}
	  ]}];

test_musique(suppression, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique) ++
	init_sachem(opt_musique)++
	[{title, "Votre Multimedia - option Musique activee - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique activee - Test Suppression - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(opt_musique, DCL)},
	    {expect, "Votre option Musique mix est actuellement activee.*"
	     "1:Supprimer l'option.*"
	     "7:Conditions.*"},
	    {send,"1"},
	    {expect,"Merci de confirmer la suppression de votre option Musique mix."
	     "Si vous supprimez votre option maintenant,"},
	    {send,"1"},
	    {expect,"vous perdez immediatement le benefice de celle-ci."},
	    {send,"1"},
	    {expect,"La suppression de votre option Musique mix a bien ete prise en compte.."
	     "Merci de votre appel."
	     ".*9:Accueil"}
	   ]}];

test_musique(reactivation,DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique) ++
	init_sachem([opt_musique], "S") ++
	[{title, "Votre Multimedia - option Musique suspendue - Test Reactivation - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique suspenduee - Test Reactivation - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(opt_musique, DCL)},
	    {expect, "Votre Option Musique mix est actuellement suspendue.."},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de clips et radios en illimite,"
	     " ni des 10 titres a telecharger, pour seulement 6E.*"
	     "1:Reactiver l'option."
	     "2:Supprimer l'option.*"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option Musique mix pour 6E. "
	     "Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois."},
	    {send,"1"},
	    {expect,"la reactivation de votre option Musique mix a bien ete prise en compte. "
	     "6E ont ete debites de votre compte"
	     ".*9:Accueil"}, %% If faudra valider compte principale ...etc
	    {send,"1"},
	    {expect,"Attention : votre option Musique mix sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++

	init_sachem([opt_musique], "S") ++
	[{title, "Votre Multimedia - option Musique suspendue - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique suspendue - Test Suppression - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(opt_musique, DCL)},
	    {expect, "Votre Option Musique mix est actuellement suspendue.."},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de clips et radios en illimite,"
	     " ni des 10 titres a telecharger, pour seulement 6E.*"
	     "1:Reactiver l'option."
	     "2:Supprimer l'option.*"},
	    {send, "2"},
	    {expect,"Merci de confirmer la suppression de votre option Musique mix."
	     "Si vous supprimez votre option maintenant,"},
	    {send,"1"},
	    {expect,"vous perdez immediatement le benefice de celle-ci."},
	    {send,"1"},
	    {expect,"La suppression de votre option Musique mix a bien ete prise en compte.."
	     "Merci de votre appel."
	     ".*9:Accueil"}
	   ]}]++
	[].

test_mail(souscriptions, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_mail) ++
	init_sachem(no_option)++
	[{title, "Votre Multimedia - option mail inactive - Test Souscriptions - "++dcl_label(DCL)},
	 "Votre Multimedia - option mail - Test Souscriptions - " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_option(opt_mail, DCL)},
	   {expect,"Consultez et envoyez vos e-mails, avec pieces jointes, en illimite directement sur votre mobile pour 9E par mois.*"},
	   {send,"1"},
	   {expect,"Vous allez souscrire a l'Option mail pour 9E. Cette option est renouvelee chaque mois a date anniversaire pour 9E par mois."},
	   {send,"1"},
	   {expect,"Vous avez souscrit a l'Option mail pour 9E. Ce montant a ete debite de votre compte."
	    ".*9:Accueil"},
	   {send,"1"},
	   {expect,"Attention : votre Option mail sera active dans 48 heures."
	    ".*9:Accueil"}
	  ]}];

test_mail(conditions,DCL) ->
    init_test(DCL) ++
	init_sachem([opt_mail],"S")++
	[{title, "Votre Multimedia - option mail activee - Test conditions - "++dcl_label(DCL)},
	 "Votre Multimedia - option mail - Test conditions - " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL) ++ "65"},
	   {expect,"7:Conditions.*"},
	   {send,"7"},
	   {expect, "Option Mail a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\).Option incompatible.*"},
	   {send,"1"},
	   {expect, "avec l'option Mail pour BlackBerryTM. Reception et envoi illimite de mails et de PJ a partir du client e-mail du mobile.Service accessible depuis.*"},
	   {send,"1"},
	   {expect, "tt compte mail utilisant les protocoles IMAP,POP&SMTP \\(hors services payants\\) ou du service Nokia Messaging avec Orange"},
	   {send,"1"},
	   {expect, "Ne sont pas compris dans l'option, les services de messagerie Microsoft\\(C\\) ExchangeTM et les applications de messagerie utilisant le protocole.*"},
	   {send,"1"},
	   {expect,"de navigation http. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois"},
	   {send,"1"},
	   {expect,"jusqu'a la date de facturation. Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles."},
	   {send,"1"},
	   {expect,"Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr.Pour les clients mobicarte"},
	   {send,"1"},
	   {expect,"et cartes prepayees, option valable 31 jours a compter de la date d'activation intervenant sous 48h a compter de la souscription et"},
	   {send,"1"},
	   {expect,"renouvelee tous les mois sous reserve d'un credit suffisant. Souscription a l'option au 220, #123#, service client et sur www.orange.fr.*"}
	  ]}];

test_mail(suppression,DCL) ->
    init_test(DCL) ++
	init_sachem(opt_mail)++
	[{title, "Votre Multimedia - option mail activee - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option mail activee - Test Suppression - " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL) ++ "65"},
	   {expect, "Votre Option mail est actuellement activee.*"
	    "1:Supprimer l'option.*"
	    "7:Conditions.*"},
	   {send,"1"},
	   {expect,"Merci de confirmer la suppression de votre Option mail.Si vous la supprimez maintenant, vous perdez immediatement le benefice de celle-ci."},
	   {send,"1"},
	   {expect,"La suppression de votre Option mail a bien ete prise en compte. Merci de votre appel."
	    ".*9:Accueil"}
	  ]}];

test_mail(reactivation,DCL) ->
    init_test(DCL) ++
	init_sachem([opt_mail], "S") ++

	[{title, "Votre Multimedia - option mail suspendu - Test Reactivation - "++dcl_label(DCL)},
	 "Votre Multimedia - option mail activee - Test Reactivation - " ++ integer_to_list(DCL),
	 {ussd2,
	  [ 
	  {send, code_menu_multimedia(DCL) ++ "65"},
	    {expect, "Votre Option mail est actuellement suspendue."},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de l'envoi ni de la reception de vos e-mails en illimite sur votre mobile.*"
	     "1:Reactiver l'option.*"
	     "2:Supprimer l'option.*"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'Option mail pour 9E. Cette option est renouvelee chaque mois a date anniversaire pour 9E par mois."},
	    {send,"1"},
	    {expect,"La reactivation de votre Option mail a bien ete prise en compte. 9E ont ete debites de votre compte."
	     ".*9:Accueil"}, 
	    {send,"1"},
	    {expect,"Attention : votre option mail sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++
	[].

test_musique_collection(out_of_commercial_date,DCL)->
    init_test(DCL) ++
	set_past_period(opt_musique_collection) ++
	init_sachem(opt_musique_collection)++
	[{title, "Votre Multimedia - option Musique collection - Not in commercial date - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique collection - Without link Musique Collection  - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL)},
	   {send, "6"},
	   {expect, ".*"}
	  ]}];

test_musique_collection(souscriptions, DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_collection) ++
	init_sachem(no_option)++
	[{title, "Votre Multimedia - option Musique collection inactive - Test Souscriptions - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique collection - Test Souscriptions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_option(opt_musique_collection, DCL)},
	   {expect,"Avec l'option musique collection, telechargez 25 titres / mois et regardez les clips et ecoutez les radios en illimite sur Orange World.*1:Souscrire.*"},
	   {send,"1"},
	   {expect,"Vous allez souscrire a l'option musique collection pour 12E. Cette option est renouvelee chaque mois a date anniversaire pour 12E par mois..*1:Valider"},
	   {send,"1"},
	   {expect,"Vous avez souscrit a musique collection pour 12E.Ce montant a ete debite de votre compte. Attention:musique collection sera active dans 48 heures."
	    ".*9:Accueil"}
	  ]}];

test_musique_collection(conditions,DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_collection) ++
	init_sachem(opt_musique_collection)++
	[{title, "Votre Multimedia - option Musique Collection activee - Test conditions - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique Collection activee - Test conditions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
          []++
           case DCL of
               ?umobile->
                   [{send, code_menu_multimedia(DCL) ++"4"}];
               _->
                   [{send, code_menu_multimedia(DCL) ++ "65"}]
           end++	  
	  [ 
	    {expect,"7:Conditions.*"},
	    {send,"7"},
	    {expect,"Option Musique collection a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\).*1:Suite"},
	    {send,"1"},
	    {expect,"Option incompatible avec l'option Musique mix.Telechargement de 25 titres musicaux par mois parmi le catalogue de titres eligibles.*1:Suite"},
	    {send,"1"},
	    {expect,"a l'option \\(hors rubriques classique et jazz\\). Nombre de titres decomptes en mois calendaire. Titres supplementaires et hors.*1:Suite"},
	    {send,"1"},
	    {expect,"catalogue proposes a l'achat a 0.99E/titre. Titres telechargeables depuis mobile et ordinateur \\(PC/Mac\\). Titres telecharges sur le mobile.*1:Suite"},
	    {send,"1"},
	    {expect,"non transferables. Navigation illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange World des videos.*1:Suite"},
	    {send,"1"},
	    {expect,"des rubriques musique, actualite, sport \\(hors evenements sportifs en direct\\) et cinema \\(hors Orange cinema series\\). Consultation.*1:Suite"},
	    {send,"1"},
	    {expect,"illimitee des chaines TV musicales \\(NRJ Hit, MCM top, MCM pop, M6 Music, M6 Black, M6 Music club, Trace TV, Trace Tropical\\). Ecoute illimitee.*1:Suite"},
	    {send,"1"},
	    {expect,"des radios sur le portail Orange World. Liste des chaines TV musicales et radios susceptible d'evolution. Ne sont pas compris.*1:Suite"},
	    {send,"1"},
	    {expect,"dans l'option, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit.*1:Suite"},
	    {send,"1"},
	    {expect,"au dela d'un usage de 500Mo/mois jusqu'a la date de facturation. Usages en France metropolitaine. Services accessibles sur reseaux.*1:Suite"},
	    {send,"1"},
	    {expect,"et depuis un terminal compatibles. Telechargements et ecoute des radios non accessibles sur terminaux iPhone.Titres telecharges depuis.*1:Suite"},
	    {send,"1"},
	    {expect,"un ordinateur lisibles et transferables sur terminaux iPhone. Voir details de l'option, conditions specifiques et liste des terminaux.*1:Suite"},
	    {send,"1"},
	    {expect,"compatibles sur www.orange.fr.*"}
	   ]}];

test_musique_collection(suppression,DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_collection) ++
	init_sachem(opt_musique_collection)++
	[{title, "Votre Multimedia - option Musique collection activee - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique collection activee - Test Suppression - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  []++
	  case DCL of
	      ?umobile->
		  [{send, code_menu_multimedia(DCL) ++"4"}];
	      _->
		  [{send, code_menu_multimedia(DCL) ++ "65"}]
	  end++
	  [ 
	    {expect, "Votre option Musique collection est actuellement activee.*"
	     "1:Supprimer l'option.*"
	     "7:Conditions.*"},
	    {send,"1"},
	    {expect,"Merci de confirmer la suppression de votre option Musique collection.Si vous supprimez votre option maintenant,"},
	    {send,"1"},
	    {expect,"vous perdez immediatement le benefice de celle-ci."},
	    {send,"1"},
	    {expect,"La suppression de votre option Musique collection a bien ete prise en compte. Merci de votre appel."
	     ".*9:Accueil"}
	   ]}];

test_musique_collection(reactivation,DCL) ->
    init_test(DCL) ++
	set_present_period(opt_musique_collection) ++
	init_sachem([opt_musique_collection], "S") ++

	[{title, "Votre Multimedia - option Musique collection suspendue - Test Reactivation - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique collection suspendue - Test Reactivation - " ++ integer_to_list(DCL),
	 {ussd2,
          []++
           case DCL of
               ?umobile->
                   [{send, code_menu_multimedia(DCL) ++"4"}];
               _->
                   [{send, code_menu_multimedia(DCL) ++ "65"}]
           end++
	  [ 
	    {expect, "Votre option Musique collection est actuellement suspendue.."},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de clips et radios en illimite, ni des 25 titres"
	     " a telecharger, pour seulement 12E.*"
	     "1:Reactiver l'option.*"
	     "2:Supprimer l'option.*"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option Musique collection pour 12E. Cette option est renouvelee chaque mois a date anniversaire pour 12E par mois."},
	    {send,"1"},
	    {expect,"La reactivation de votre option Musique collection a bien ete prise en compte. 12E ont ete debites de votre compte."
	     ".*9:Accueil"}, 
	    {send,"1"},
	    {expect,"Attention : votre option Musique collection sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++

	init_sachem([opt_musique_collection], "S") ++
	[{title, "Votre Multimedia - option Musique collection suspendue - Test Suppression - "++dcl_label(DCL)},
	 "Votre Multimedia - option Musique collection suspendue - Test Suppression - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
          []++
	  case DCL of
	      ?umobile->
		  [{send, code_menu_multimedia(DCL) ++"4"}];
	      _->
		  [{send, code_menu_multimedia(DCL) ++ "65"}]
	  end++	  
	  [ 
	    {expect, "Votre option Musique collection est actuellement suspendue.."},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de clips et radios en illimite, ni des 25 titres"
	     " a telecharger, pour seulement 12E.*"
	     "1:Reactiver l'option.*"
	     "2:Supprimer l'option.*"},
	    {send, "2"},
	    {expect,"Merci de confirmer la suppression de votre option Musique collection.Si vous supprimez votre option maintenant,"},
	    {send,"1"},
	    {expect,"vous perdez immediatement le benefice de celle-ci."},
	    {send,"1"},
	    {expect,"La suppression de votre option Musique collection a bien ete prise en compte. Merci de votre appel."
	     ".*9:Accueil"}
	   ]}]++ 
	[].
test_opt_multimedia(Opt,?umobile)
when Opt==opt_internet_max; Opt==opt_tv_max; Opt==opt_musique;
     Opt==opt_mail; Opt==opt_internet_max_journee; Opt==opt_internet_max_weekend;
     Opt==opt_orange_sport; Opt==opt_foot_ligue1; Opt==opt_mes_donnees;
     Opt==opt_tv_mensu->
         [];
test_opt_multimedia(opt_surf_mensu,?m6_prepaid)->
    [];

test_opt_multimedia(Opt=opt_musique_mix, DCL) ->
    test_musique_mix(out_of_commercial_date,DCL) ++
	test_musique_mix(souscriptions, DCL) ++
	test_musique_mix(conditions,DCL) ++
	test_musique_mix(suppression,DCL) ++
	test_musique_mix(reactivation,DCL)++
	[];

test_opt_multimedia(Opt=opt_musique, DCL) ->
    test_musique(conditions,DCL) ++
	test_musique(suppression,DCL) ++
	test_musique(reactivation,DCL)++
	[];

test_opt_multimedia(Opt=opt_internet, DCL) ->    
    init_test(DCL)++
	init_sachem(no_option) ++
	[{title, "Votre Multimedia - option internet inactive - Test Souscription and Conditions - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet inactive - Test Souscription and Conditions - DCL = "++ integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(Opt, DCL)},
	    {expect,"Surfez en illimite sur internet de 20h a 8h et sur Orange World 24h/24 pour 6E par mois.*7:Conditions.*"},
	    {send,"7"},
	    {expect,"Option Internet a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\). Navigation.*1:Suite"},
	    {send, "1"},
	    {expect,"illimitee sur le portail Orange World. Consultation illimitee des videos des rubriques actualite, cinema \\(hors Orange cinema series\\),.*1:Suite"},
	    {send, "1"},
	    {expect,"sport \\(hors evenements sportifs en direct\\) sur le portail Orange World. De 20h a 8h, navigation illimitee sur Gallery, internet.*1:Suite"},
	    {send, "1"},
	    {expect,"et consultation illimitee des videos de la rubrique mes communautes.Ne sont pas compris dans l'option, les usages mail \\(smtp, pop,.*1:Suite"},
	    {send, "1"},
	    {expect,"imap\\), modem, les contenus et services payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une.*1:Suite"},
	    {send, "1"},
	    {expect,"qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.*1:Suite"},
	    {send, "1"},
	    {expect,"Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option,.*1:Suite"},
	    {send, "1"},
	    {expect,"conditions specifiques et liste des terminaux compatibles sur www.orange.fr. Pour les clients mobicarte et cartes prepayees, option valable.*1:Suite"},
	    {send, "1"},
	    {expect,"31 jours a compter de la date d'activation intervenant sous 48h a compter de la souscription et renouvelee tous les mois sous.*1:Suite"},
	    {send, "1"},
	    {expect,"reserve d'un credit suffisant. Souscription a l'option au 220, #123#, service client et sur www.orange.fr."},
	    {send,"8888888888"},
	    {expect, "1:Suite"},
	    {send,"1"},
	    {expect, "Toute l'actu, le sport et les services pratiques \\(trafic, meteo\\) et Internet de 20h a 8h sont disponibles sur votre mobile Orange.*1:Souscrire"},
	    {send,"1"},
	    {expect, "Vous allez souscrire a l'option Internet pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois.*1:Valider"},
	    {send,"1"},
	    {expect,"Vous avez souscrit a l'option Internet pour 6E.Ce montant a ete debite de votre compte.*1:Suite"
	     ".*9:Accueil"},
	    {send,"1"},
	    {expect, "Attention : votre option Internet sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++

        init_sachem([opt_internet_v2_pp],"S") ++ %%% S -> suspend
        [{title, "Votre Multimedia - option internet suspendue - Test Reactivation - "++dcl_label(DCL)},
         "Test Menu votre multimedia internet suspendue - Test Reactivation - DCL = "++ integer_to_list(DCL),
         {ussd2,
          [ ]++
	    case DCL of
		?umobile->
		    [{send,code_menu_multimedia(DCL) ++"4"}];
		_->
		    [{send,code_menu_multimedia(DCL) ++ "65"}
		    ]
	    end ++
	  [{expect,"Votre Option Internet est actuellement suspendue.*1:Suite"},
            {send,"1"},
	    {expect,"Vous ne beneficiez plus de tout Orange World en illimite 24h/24 et.*1:Suite"},
            {send,"1"},
	    {expect,"d'Internet en illimite tous les jours de 20h a 8h pour 5E par mois.*1:Reactiver l'option"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option Internet pour 5E. Cette option est renouvelee chaque mois a date anniversaire pour 5E par mois.*1:Confirmer"},
	    {send,"1"},
            {expect,"la reactivation de votre Option.*5E.*1:Suite"
	     ".*9:Accueil"},
	    {send,"1"},
            {expect,"Attention : votre option Internet sera active dans 48 heures."
	     ".*9:Accueil"}
           ]}]++

	init_sachem(opt_internet_v3_pp) ++
	[{title, "Votre Multimedia - option internet v3 active - Test Suppression - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet v3 active - Test Suppression - DCL = "++ integer_to_list(DCL),
	 {ussd2,
	  []++
	   case DCL of
                ?umobile->
                    [{send,code_menu_multimedia(DCL) ++"4"}];
                _->
                    [{send,code_menu_multimedia(DCL) ++"65"}]
            end ++
	  [
	   {expect,"Votre option Internet est actuellement activee.*1:Supprimer l'option"},
	   {send,"1"},
	   {expect,"Merci de confirmer la suppression de votre option Internet.Si vous supprimez votre option maintenant,.*1:Suite"},
	   {send,"1"},
	   {expect,"vous perdez immediatement le benefice de celle-ci.*1:Valider"},
	   {send,"1"},
	   {expect,"La suppression de votre option Internet a bien ete prise en compte. Merci de votre appel"
	    ".*9:Accueil"}
	  ]}]++

	init_sachem([opt_internet_v3_pp],"S") ++ %% S -> suspend
	[{title, "Votre Multimedia - option internet v3 suspendue - Test Reactivation - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet v3 suspendue - Test Reactivation - DCL = "++ integer_to_list(DCL),
	 {ussd2,
	  [ ]++
	   case DCL of
                ?umobile->
                    [{send,code_menu_multimedia(DCL) ++"4"}];
                _->
                    [{send,code_menu_multimedia(DCL) ++"65"}]
            end ++
	  [
	    {expect,"Votre Option Internet est actuellement suspendue.*1:Suite"},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de tout Orange World en illimite 24h/24 et.*1:Suite"},
	    {send,"1"},
	    {expect,"d'Internet en illimite tous les jours de 20h a 8h pour 6E par mois.*1:Reactiver l'option"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option Internet pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois.*1:Confirmer"},
	    {send,"1"},
	    {expect,"la reactivation de votre Option.*6E.*1:Suite"
	     ".*9:Accueil"},
	    {send,"1"},
	    {expect,"Attention : votre option Internet sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++
	[];
test_opt_multimedia(Opt=opt_surf_mensu, DCL) ->
    init_test(DCL) ++
	init_sachem(Opt)++
        [{title, "Votre Multimedia - option Surf Mensuelle active - Test Suppression - "++dcl_label(DCL)},
         "Test Menu votre multimedia option Surf Mensuelle active - Test Suppression - DCL = "++ integer_to_list(DCL),
         {ussd2,
          [
	   {send, code_option(Opt, DCL)},
	   {expect,"Votre option surf mensuelle est actuellement activee.*1:Supprimer l'option.*7:Conditions.*"},
	   {send,"7"},
	   {expect,"Offre valable en France metropolitaine et reservee aux clients mobicarte et click la mobicarte.*"},
	   {send,"1"},
	   case DCL of
	       ?click_mobi->
		   {expect,"Acces et connexions illimitees aux services du Portail Orange mobile \\(hors Gallery,Internet,streaming audio,TV et video,et hors contenus payants\\).*"};
	       _->
		   {expect,"Acces et connexions illimitees aux services du Portail Orange World \\(hors Gallery,Internet,streaming audio,TV et video,et hors contenus payants\\).*"}
	   end,
	   {send,"1"},
	   {expect,"pendant un mois consecutifs a compter de la date d'activation de l'option.Services accessibles sur reseaux et depuis un terminal compatible.*"},
	   {send,"1"},
	   {expect,"Les 6E sont preleves chaque mois sur le compte mobicarte du client sous reserve de disposer d'un credit suffisant. En cas de credit insuffisant.*"},
	   {send,"1"},
	   {expect,"l'option sera suspendue et reprendra automatiquement a la date anniversaire si le credit est a nouveau suffisant. Souscription de l'option au 444.*"},
	   {send,"1"},
	   {expect,"...et resiliation a tout moment au 220 ou #123# \\(appels gratuits\\). Voir details de l'option, Conditions Specifiques*"},
	   {send,"1"},
	   {expect,"...et liste des mobiles compatibles sur www.orange.fr onglet mobile."},
	   {send,"8888888"},
	   {expect,"Votre option surf mensuelle est actuellement activee.*1:Supprimer l'option.*7:Conditions.*"},
	   {send, "1"},
	   {expect,"Merci de confirmer la suppression de votre option surf mensuelle.*1:Valider.*"},
	   {send,"1"},
	   {expect,"La suppression de votre option surf mensuelle a bien ete prise en compte.*Merci de votre appel.*"
	    ".*9:Accueil"}
	  ]}]++    
	[];

test_opt_multimedia(Opt=opt_tv_mensu, DCL) ->
    init_test(DCL) ++
	init_sachem(Opt)++
        [{title, "Votre Multimedia - option Tv Mensuelle active - Test Suppression - "++dcl_label(DCL)},
         "Test Menu votre multimedia option Tv Mensuelle active - Test Suppression - DCL = "++ integer_to_list(DCL),
         {ussd2,
          [
	   {send, code_option(Opt, DCL)},
	   {expect,"Votre option TV mensuelle est actuellement activee.*1:Supprimer l'option.*7:Conditions.*"},
	   {send,"7"},
	   case DCL of
	       ?m6_prepaid->
		   {expect,"Offre valable en France metropolitaine et reservee aux clients d'une offre prepayee Orange. Acces et.*"};
	       _->
		   {expect,"Offre valable en France metropolitaine et reservee aux clients mobicarte et click la mobicarte. Acces et connexions illimitees.*"}
	   end,
	   {send, "1"},
	   case DCL of
	       X when X==?mobi;
	              X==?click_mobi->
		   {expect,"...a plus de 20 chaines de television et a toutes les videos proposees sur Orange mobile \\(hors contenus payants\\).*"};
	       _->
		   {expect,"...a plus de 20 chaines de television et a toutes les videos proposees sur Orange World \\(hors contenus payants\\).*"}
	   end,
	   {send,"1"},
	   {expect,"Liste des chaines susceptible d'evolution. Services accessibles sur reseaux et depuis un terminal compatibles.*"},
	   {send, "1"},	   
	   {expect,"Voir details de l'option, Conditions Specifiques et liste des mobiles compatibles.*"},
	   {send, "1"},
	   case DCL of
	       ?m6_prepaid->
		   {expect,"sur www.orange.fr. Option reconduite chaque mois. Le prix de l'option est preleve chaque mois sur le compte principal du client sous reserve.*"};
	       _->
		   {expect,"sur www.orange.fr. Option reconduite chaque mois. Le prix de l'option est preleve chaque mois sur le compte du client sous reserve.*"}
	   end,
	   {send, "1"},
	   {expect,"d'un credit suffisant. A defaut,l'option sera suspendue et reprendra automatiquement a date anniversaire si le credit est a nouveau suffisant.*"},
	   {send, "1"},
	   {expect,"... Resiliation possible au au 220 ou au #123#.  Option incompatible avec l'option totale TV et l'option TV.*"},
	   {send,"8888888"},
	   {expect,"Votre option TV mensuelle est actuellement activee.*1:Supprimer l'option.*7:Conditions.*"},
	   {send, "1"},
	   {expect,"Merci de confirmer la suppression de votre option TV mensuelle.*1:Valider.*"},
	   {send,"1"},
	   {expect,"La suppression de votre option TV mensuelle a bien ete prise en compte.*Merci de votre appel.*"
	    ".*9:Accueil"}
	  ]}]++    
	[];

test_opt_multimedia(Opt=opt_mail, DCL) ->
    test_mail(souscriptions, DCL)++
	test_mail(conditions,DCL)++
	test_mail(suppression,DCL)++
	test_mail(reactivation,DCL)++
	[];

test_opt_multimedia(Opt=opt_musique_collection, DCL) ->
    test_musique_collection(out_of_commercial_date,DCL)++
	test_musique_collection(souscriptions, DCL)++
	test_musique_collection(conditions,DCL)++
	test_musique_collection(suppression,DCL)++
	test_musique_collection(reactivation,DCL)++
	[];

test_opt_multimedia(Opt=opt_internet_max, DCL) ->    
    init_test(DCL)++

	init_sachem(no_option) ++
        [{title, "Votre Multimedia - internet max inactive - Test link Internet max - "++dcl_label(DCL)},
         "Test Menu votre multimedia - internet max inactive - Test link Internet max - DCL = "++integer_to_list(DCL),
         {ussd2,
          [ {send, code_menu_multimedia(DCL)},
            {send, "6"},
            {expect,".*"}
	   ]}]++
	test_util_of:close_session()++

	init_sachem(opt_internet_max_pp) ++
	[{title, "Votre Multimedia - internet max activee - Test Suppression and Conditions - "++dcl_label(DCL)},
	 "Test Menu votre multimedia - internet max active - Test Suppression and Conditions - DCL = "++integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_menu_multimedia(DCL) ++ "65"},
	    {expect,"Votre option Internet max est actuellement activee.*7:Conditions"},
	    {send,"7"},
	    {expect,"Option Internet max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors mobicarte, cartes prepayees et.*1:Suite"},
	    {send, "1"},
	    {expect,"offres Internet everywhere\\). Navigation illimitee sur le portail Orange World, Gallery et internet. Consultation illimitee des videos.*1:Suite"},
	    {send, "1"},
	    {expect,"des rubriques actualite, cinema \\(hors Orange cinema series\\), sport \\(hors evenements sportifs en direct\\) et mes communautes sur le.*1:Suite"},
	    {send, "1"},
	    {expect,"portail Orange World.Ne sont pas compris dans l'option, les usages mail \\(smtp, pop, imap\\), les usages modem, les contenus et services.*1:Suite"},
	    {send, "1"},
	    {expect,"payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Pour une qualite de service optimale sur son reseau.*1:Suite"},
	    {send, "1"},
	    {expect,"Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine..*1:Suite"},
	    {send, "1"},
	    {expect,"Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option, conditions specifiques et liste des terminaux.*1:Suite"},
	    {send, "1"},
	    {expect,"compatibles sur www.orange.fr.Pour les clients mobicarte et cartes prepayees, option valable 31 jours a compter de la date.*1:Suite"},
	    {send, "1"},
	    {expect,"d'activation intervenant sous 48h a compter de la souscription et renouvelee tous les mois sous reserve d'un credit suffisant. Souscription.*1:Suite"},
	    {send, "1"},
	    {expect,"a l'option au 220, #123#, service client et sur www.orange.fr."},
	    {send,"8888888888"},
	    {expect,"1:Supprimer l'option"},
	    {send, "1"},
            {expect,"Merci de confirmer la suppression de votre option Internet max.Si vous supprimez votre option maintenant,.*1:Suite"},
	    {send, "1"},
            {expect,"vous perdez immediatement le benefice de celle-ci.*1:Valider"},
	    {send, "1"},
	    {expect,"La suppression de votre option"
	     ".*9:Accueil"}
	   ]}]++

	init_sachem([opt_internet_max_pp],"S") ++ %% S -> suspend
        [{title, "Votre Multimedia - option internet max suspendue - Test link Internet max - "++dcl_label(DCL)},
         "Test Menu votre multimedia - internet max supendue - Test link Internet max - DCL = "++integer_to_list(DCL),
         {ussd2,
          [ {send, code_menu_multimedia(DCL)},
            {send, "6"},
            {expect,".*"}
	   ]}]++


	test_util_of:close_session()++

	init_sachem(opt_internet_max_v3) ++
	[{title, "Votre Multimedia - option internet max v3 activee - Test Suppression - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet max v3 activee - Test Suppression - DCL = "++integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_menu_multimedia(DCL)++"65"},
	    {expect,"Votre option Internet max est actuellement activee.*7:Conditions"},
	    {send,"7"},
	    {expect,"Option Internet max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors mobicarte, cartes prepayees et.*1:Suite"},
	    {send,"8"},
	    {expect,"1:Supprimer l'option"},
	    {send,"1"},
            {expect,"Merci de confirmer la suppression de votre option Internet max.Si vous supprimez votre option maintenant,.*1:Suite"},
	    {send,"1"},
            {expect,"vous perdez immediatement le benefice de celle-ci.*1:Valider"},
	    {send,"1"},
	    {expect,"La suppression de votre option"
	     ".*9:Accueil"}
	   ]}]++

	init_sachem([opt_internet_max_v3],"S") ++
        [{title, "Votre Multimedia - internet max v3 suspendue - Test link Internet max - "++dcl_label(DCL)},
         "Test Menu votre multimedia - internet max v3 suspendue - Reactivate option - DCL = "++integer_to_list(DCL),
         {ussd2,
          [
	    {send, code_menu_multimedia(DCL)++"65"},
	    {expect, "Votre Option Internet max est actuellement suspendue.*Suite.*Conditions.*"},
	    {send, "1"},
	    {expect, "Vous ne beneficiez plus de tout internet et Orange World en illimite 24h/24 pour 12E par mois..1:Reactiver l'option.*2:Supprimer l'option.*"},
	    {send, "1"},
            {expect, "Vous allez reactiver l'option Internet max pour 12E. Cette option est renouvelee chaque mois a date anniversaire pour 12E par mois..1:Confirmer.*"},
	    {send, "1"},
	    {expect, "la reactivation de votre Option Internet max a bien ete prise en compte. 12E ont ete debites de votre compte..1:Suite.*"},
	    {send, "1"},
	    {expect, "Attention : votre option Internet max sera active dans 48 heures.*"}
	   ]}]++
	test_util_of:close_session()++
	
	init_sachem([opt_internet_max_v3],"S") ++
        [{title, "Votre Multimedia - internet max v3 suspendue - Test link Internet max - "++dcl_label(DCL)},
         "Test Menu votre multimedia - internet max v3 suspendue - Supprime option - DCL = "++integer_to_list(DCL),
         {ussd2,
          [ 
            {send, code_menu_multimedia(DCL)++"65"},
            {expect, "Votre Option Internet max est actuellement suspendue.*Suite.*Conditions.*"},
            {send, "1"},
            {expect, "Vous ne beneficiez plus de tout internet et Orange World en illimite 24h/24 pour 12E par mois..1:Reactiver l'option.*2:Supprimer l'option.*"},
            {send, "2"},
            {expect, "Merci de confirmer la suppression de votre option Internet max.Si vous supprimez votre option maintenant,.*"},
            {send, "1"},
            {expect, "vous perdez immediatement le benefice de celle-ci.*"},
	    {send, "1"},
	    {expect, "La suppression de votre option Internet max a bien ete prise en compte. Merci de votre appel.*"}
           ]}]++
        test_util_of:close_session()++

        init_sachem(no_option) ++
        [{title, "Votre Multimedia - internet max v3 inactive - Test link Internet max - "++dcl_label(DCL)},
         "Test Menu votre multimedia - internet max v3 inactive - Souscrire option - DCL = "++integer_to_list(DCL),
         {ussd2,
          [
            {send, code_menu_multimedia(DCL)++"4"},
            {expect, "Surfez en illimite sur internet sur Orange World 24h/24 pour 12E par mois.*Suite.*Conditions.*"},
            {send, "1"},
            {expect, "Toute l'actu, le sport et les services pratiques \\(trafic, meteo\\) et Internet sont disponibles sur votre mobile Orange 24h/24.*Souscrire.*"},
            {send, "1"},
            {expect, "Vous allez souscrire a l'option Internet pour 12E. Cette option est renouvelee chaque mois a date anniversaire pour 12E par mois.*Valider.*"},
            {send, "1"},
            {expect, "Vous avez souscrit a l'option Internet max pour 12E.Ce montant a ete debite de votre compte.*"},
            {send, "1"},
            {expect, "Attention : votre option Internet max sera active dans 48 heures.*"}
           ]}]++
        test_util_of:close_session()++
	[];

test_opt_multimedia(Opt=opt_tv, DCL) ->
    init_test(DCL)++
	init_sachem(no_option) ++
	[{title, "Votre Multimedia - option TV inactive - Test Subscription and Conditions - "++dcl_label(DCL)},
	 "Test Menu votre multimedia TV inactive - Test Subscription and Conditions - DCL = "++ integer_to_list(DCL),
	 {ussd2,
	  [ 
	    {send, code_option(Opt, DCL)},
	    {expect,"Avec l'option TV, profitez de plus de 20 chaines, de tte la video en illimite et de tous les services d'Orange World pour 6E par mois.*7:Conditions"},
	    {send,"7"},
	    {expect,"Option TV a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\). Navigation.*1:Suite"},
	    {send, "1"},
	    {expect,"illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange World et/ou l'application orange TV player de.*1:Suite"},
	    {send, "1"},
	    {expect,"plus de 20 chaines de TV et de toutes les videos proposees sur le portail Orange World \\(hors rubrique mes communautes et Orange cinema Series\\)..*1:Suite"},
	    {send, "1"},
	    {expect,"Liste des chaines TV susceptible d'evolution.Ne sont pas compris dans l'option, les evenements sportifs en direct, les.*1:Suite"},
	    {send, "1"},
	    {expect,"contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage.*1:Suite"},
	    {send, "1"},
	    {expect,"de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis un terminal.*1:Suite"},
	    {send, "1"},
	    {expect,"compatibles. Chaines TV accessibles sur terminaux iPhone sous reserve de telechargement aux tarifs en vigueur de l'application correspondante.*1:Suite"},
	    {send, "1"},
	    {expect,"Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr. Pour les clients mobicarte.*1:Suite"},
	    {send, "1"},
	    {expect,"et cartes prepayees, option valable 31 jours a compter de la date d'activation intervenant sous 48h a compter de la souscription.*1:Suite"},
	    {send, "1"},
	    {expect,"et renouvelee tous les mois sous reserve d'un credit suffisant. Souscription a l'option au 220, #123#, service client et sur www.orange.fr"},
	    {send,"8888888888"},
	    {expect, "1:Suite"},
	    {send, "1"},
	    {expect, "Suivez les chaines nationales et celles de la TNT ainsi que toutes les videos actu,musique,sport,humour,cinema en illimite 24h/24 et 7j/7.*1:Souscrire"},
	    {send, "1"},
	    {expect, "Vous allez souscrire a l'option TV pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois.*1:Valider"},
	    {send, "1"},
	    {expect,"Vous avez souscrit a l'option TV pour 6E. Ce montant a ete debite de votre compte.*"
	     ".*9:Accueil"}
	   ]}]++

        init_sachem([Opt], "S") ++
        [{title, "Votre Multimedia - option TV suspendue - Test Reactivation - "++dcl_label(DCL)},
         "Test Menu votre multimedia option TV suspendue - Test Reactivation - DCL = "++ integer_to_list(DCL),
         {ussd2,
          [ ]++
	  case DCL of
	      ?umobile->
		  [{send, code_menu_multimedia(DCL)++"4"}];
	      _->
		  [{send, code_menu_multimedia(DCL)++"65"}]
	  end++
	  [
            {expect,"Votre Option TV est actuellement suspendue.*1:Suite"},
            {send,"1"},
            {expect,"Vous ne beneficiez plus de plus de 20 chaines, de tte la video en illimite et.*1:Suite"},
            {send,"1"},
            {expect,"de tous les services d'Orange World pour 6E par mois.*1:Reactiver l'option"},
	    {send,"1"},
            {expect,"Vous allez reactiver l'option TV pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois.*1:Confirmer"},
            {send,"1"},
            {expect,"la reactivation de votre Option.*6E.*1:Suite"
	     ".*9:Accueil"},
	    {send,"1"},
            {expect,"Attention : votre option TV sera active dans 48 heures."
	     ".*9:Accueil"}
           ]}]++
	[];


test_opt_multimedia(Opt=opt_tv_max, DCL) ->    
    init_test(DCL)++
	init_sachem(no_option) ++
        [{title, "Votre Multimedia - TV max inactive - Test link TV max - "++dcl_label(DCL)},
         "Test Menu votre multimedia - TV max inactive - Test link TV max - DCL = "++integer_to_list(DCL),
         {ussd2,
          [ {send, code_menu_multimedia(DCL)},
            {send, "6"},
            {expect,"[^Option TV max]"}
	   ]}]++

	init_sachem(Opt) ++
	[{title, "Votre Multimedia - option TV max activee - Test Suppression and Conditions - "++dcl_label(DCL)},
	 "Test Menu votre multimedia TV max activee - Test Suppression and Conditions - DCL = "++integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(Opt, DCL)},
	    {expect,"Votre option TV max est actuellement activee.*7:Conditions"},
	    {send,"7"},
	    {expect,"Option TV max a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors Mobicarte, cartes prepayees et offres.*1:Suite"},
	    {send, "1"},
	    {expect,"Internet everywhere\\). Option incompatible avec l'option Orange foot. Navigation illimitee sur le portail Orange World. Consultation.*1:Suite"},
	    {send, "1"},
	    {expect,"illimitee sur le portail Orange World et/ou l'application Orange TV player de plus de 60 chaines TV, sur le portail Orange World.*1:Suite"},
	    {send, "1"},
	    {expect,"et/ou l'application Ligue 1R de 8 matchs de Ligue 1 en direct par journee de championnat et de toutes les videos proposees sur le.*1:Suite"},
	    {send, "1"},
	    {expect,"portail Orange World \\(hors rubrique mes communautes et Orange cinema series\\). Liste des chaines TV susceptible d'evolution.Ne sont pas.*1:Suite"},
	    {send, "1"},
	    {expect,"compris dans l'option, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter.*1:Suite"},
	    {send, "1"},
	    {expect,"le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation. Usages en France metropolitaine. Services accessibles sur.*1:Suite"},
	    {send, "1"},
	    {expect,"reseaux et depuis un terminal compatibles. Chaines TV et Matchs en direct accessibles sur terminaux iPhone sous reserve de telechargement.*1:Suite"},
	    {send, "1"},
	    {expect,"aux tarifs en vigueur des applications correspondantes. Voir details de l'option, conditions specifiques et liste des terminaux.*1:Suite"},
	    {send, "1"},
	    {expect,"compatibles sur www.orange.fr.Pour les clients mobicarte et cartes prepayees, option valable 31 jours a compter de la date d'activation.*1:Suite"},
	    {send, "1"},
	    {expect,"intervenant sous 48h a compter de la souscription et renouvelee tous les mois sous reserve d'un credit suffisant. Souscription a.*1:Suite"},
	    {send, "1"},
	    {expect,"l'option au 220, #123#, service client et sur www.orange.fr"},
	    {send,"888888888888"},
	    {expect, "1:Supprimer l'option"},
	    {send, "1"},
	    {expect, "Merci de confirmer la suppression de votre option TV max.Si vous supprimez votre option maintenant,.*1:Suite"},
            {send, "1"},
	    {expect, "vous perdez immediatement le benefice de celle-ci.*1:Valider"},
            {send, "1"},
	    {expect,"La suppression de votre option TV max"
	     ".*9:Accueil"}
	   ]}]++

	init_sachem([Opt],"S") ++ %% S -> suspend
	[{title, "Votre Multimedia - option tv max suspendue - Test Reactivation - "++dcl_label(DCL)},
	 "Test Menu votre multimedia TV max suspendue - Test Reactivation - DCL = "++integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(Opt, DCL)},
	    {expect,"Votre Option TV max est actuellement suspendue.*1:Suite"},
	    {send,"1"},
            {expect,"Vous ne beneficiez plus de plus de 60 chaines, de toute la video et.*1:Suite"},
	    {send,"1"},
            {expect,"de tous les services d'Orange World en illimite pour 9E par mois.*1:Reactiver l'option"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option TV max pour 9E. Cette option est renouvelee chaque mois a date anniversaire pour 9E par mois.*1:Confirmer"},
            {send,"1"},
	    {expect,"la reactivation de votre Option.*9E.*1:Suite"
	     ".*9:Accueil"},
	    {send,"1"},
	    {expect,"Attention : votre option TV max sera active dans 48 heures."
	     ".*9:Accueil"}
	   ]}]++
	[];

test_opt_multimedia(Opt=opt_internet_max_journee, DCL) ->
    init_test(DCL)++
	init_sachem([Opt,opt_tv,opt_tv_max,opt_musique_mix,opt_musique_collection],"-") ++
	[{title, "Votre Multimedia - option internet max journee - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet max journee supprime option - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
 	   {send, code_menu_multimedia(DCL)++"62"},
	   {expect, "Votre bon plan Journee Internet max est actuellement active.*"}
	  ]
	 }
	]++
	[{title, "Votre Multimedia - option internet max journee - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet max journee conditions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL)++"62"},
	   {expect, ".*"},
	   {send, "7"},
	   {expect, "Option valable en France metropolitaine pour tout client prepaye Orange. Navigation illimitee sur le portail Orange World, Gallery et ..."},
	   {send, "1"},
	   {expect, "... internet. Consultation illimitee des videos des rubriques actualite, cinema, sport \\(hors evenements sportifs en direct\\) et mes ..."},
	   {send, "1"},
	   {expect, " ... communautes sur le portail Orange World. Ne sont pas compris dans l'option, les usages mail \\(smtp, pop, imap\\), les usages modem, ..."},
	   {send, "1"},
	   {expect, "... les contenus et services payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Usages en France metropolitaine."},
	   {send, "1"},
	   {expect, "Services accessibles sur reseaux et depuis un terminal compatibles."},
	   {send, "1"},
	   {expect, "Souscription a l'option au 220 et #123#, au service clients et sur www.orange.fr"},
	   {send, "8"},
	   {expect, ".*"}
	  ]}]++
 	init_sachem(no_option)++
 	[{title, "Votre Multimedia - option internet max journee inactive - Conditions - "++dcl_label(DCL)},
 	 "Test Menu votre multimedia internet max journee inactive - DCL = " ++ integer_to_list(DCL),
 	 {ussd2,
 	  [ 
 	    {send, code_option(Opt, DCL)},
 	    {expect, "Surfez en illimite sur le portail Orange World, Gallery et Internet de 2h a 24h en France metropolitaine pour 3E le jour de la souscription.*"},
 	    {send, "1"},
 	    {expect, "Toute l'actu, le sport et les services pratiques \\(trafic, meteo\\) et Internet sont disponibles sur votre mobile Orange.*"},
 	    {send, "1"},
 	    {expect, "Vous allez souscrire au bon plan Journee Internet max pour 3E. Cette option est active uniquement le jour de sa souscription et sans engagement.*"},
 	    {send, "1"},
 	    {expect, "Vous avez souscrit au bon plan Journee Internet max pour 3E. Ce montant a ete debite de votre compte."
 	     ".*9:Accueil"},

 	    {send, "1"},
 	    {expect, "Attention : votre bon plan Journee Internet max sera actif a reception du SMS de confirmation.*"
 	     ".*9:Accueil"},
 	    {send, "8"},
 	    {expect, "Vous avez souscrit au bon plan Journee Internet max pour 3E. Ce montant a ete debite de votre compte."},
 	    {send, "8"},
 	    {expect, ".*"}
 	   ]}]++
 	init_sachem([opt_internet_max_weekend,opt_tv,opt_tv_max,opt_musique_mix,opt_musique_collection],"-") ++
 	[{title, "Votre Multimedia - option internet max journee incompatible - "++dcl_label(DCL)},
 	 "Test Menu votre multimedia internet max journee incompatible - DCL = " ++ integer_to_list(DCL),
 	 {ussd2,
 	  [
 	   {send, code_option(Opt, DCL)},
 	   {expect, "Surfez en illimite sur le portail Orange World, Gallery et Internet de 2h a 24h en France metropolitaine pour 3E le jour de la souscription.*"},
 	   {send, "1"},
 	   {expect, "Toute l'actu, le sport et les services pratiques \\(trafic, meteo\\) et Internet sont disponibles sur votre mobile Orange.*"},
 	   {send, "1"},
 	   {expect, "Vous allez souscrire au bon plan Journee Internet max pour 3E. Cette option est active uniquement le jour de sa souscription et sans engagement.*"},
 	   {send, "1"},
 	   {expect, "Bonjour, vous ne pouvez pas souscrire au bon plan Journee Internet max. Merci de contacter.*"}
 	  ]}]++
	[];

test_opt_multimedia(Opt=opt_internet_max_weekend, DCL) ->
    init_test(DCL)++
	init_sachem(Opt) ++
	[{title, "Votre Multimedia - option internet max weekend - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet max Week end supprime option - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL)++"65"},
	   {expect, "Votre bon plan Week end Internet max est actuellement active.*"}
	  ]
	 }
	]++

	[{title, "Votre Multimedia - option internet max weekend - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet max weekend conditions - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_menu_multimedia(DCL)++"65"},
	   {expect, ".*"},
	   {send, "7"},
	   {expect, "Option valable en France metropolitaine pour tout client mobicarte Orange. Navigation illimitee sur le portail Orange World, Gallery et ..."},
	   {send, "1"},
	   {expect, "... internet. Consultation illimitee des videos des rubriques actualite, cinema, sport \\(hors evenements sportifs en direct\\) et mes ..."},
	   {send, "1"},
	   {expect, " ... communautes sur le portail Orange World. Ne sont pas compris dans l'option, les usages mail \\(smtp, pop, imap\\), les usages modem, ..."},
	   {send, "1"},
	   {expect, "... les contenus et services payants. Les services de Voix sur IP, peer to peer et Newsgroups sont interdits. Usages en France metropolitaine."},
	   {send, "1"},
	   {expect, "Services accessibles sur reseaux et depuis un terminal compatibles."},
	   {send, "1"},
	   {expect, "Souscription a l'option au 220 et #123#, au service clients et sur www.orange.fr"},
	   {send, "8"},
	   {expect, ".*"}
	  ]}]++

	init_sachem(no_option)++
	[{title, "Votre Multimedia - option internet max weekend inactive - Conditions - "++dcl_label(DCL)},
	 "Test Menu votre multimedia internet max weekend inactive - DCL = " ++ integer_to_list(DCL),
	 {ussd2,
	  [
	   {send, code_option(Opt, DCL)},
	   {expect, "Surfez en illimite sur le portail Orange World, Gallery et Internet du vendredi minuit au dimanche minuit en France metropolitaine pour 5E.*"},
	   {send, "1"},
	   {expect, "Toute l'actu, le sport et les services pratiques \\(trafic, meteo\\) et Internet sont disponibles sur votre mobile Orange.*"},
	   {send, "1"},
	   {expect, "Vous allez souscrire au bon plan Week end Internet max pour 5E. Cette option sans engagement est active uniquement le week end de sa souscription.*"},
	   {send, "1"},
	   {expect, "Vous avez souscrit au bon plan Week end Internet max pour 5E. Ce montant a ete debite de votre compte."
	    ".*9:Accueil"},
	   {send, "1"},
	   {expect, "Attention : votre bon plan Week end Internet max sera actif a reception du SMS de confirmation.*"
	    ".*9:Accueil"},
	   {send, "8"},
	   {expect, "Vous avez souscrit au bon plan Week end Internet max pour 5E. Ce montant a ete debite de votre compte."},
	   {send, "8"},
	   {expect, ".*"}
	  ]}]++
	[];

test_opt_multimedia(Opt=opt_visio, DCL) ->    
    init_test(DCL)++
	init_sachem(no_option) ++
	[{title, "Votre Multimedia - option visio - Test Souscription and Conditions - "++dcl_label(DCL)},
	 "Test option visio Souscription and Conditions - DCL = "++ integer_to_list(DCL),
	 {ussd2,
	  [ {send, code_option(Opt, DCL)},
	    {expect,"Activation de la visiophonie.*7:Conditions.*"},
	    {send,"7"}
	   ]++
	  case DCL of
	      ?umobile->
		  [ 
		    {expect, "Service accessible aux clients U mobile. Visiophonie disponible entre terminaux et sur reseaux compatibles. Les communications visio sont"},
		    {send, "1"},
		    {expect, "decomptees a la seconde des la premiere seconde \\(les 15 premiere secondes sont gratuites\\) au tarif du plan a la seconde du client"},
		    {send, "1"},
		    {expect, "Service disponible pour les appels en France metropolitaine, les mobiles visio Orange et les mobiles visio des operateurs proposant..."},
		    {send, "1"},
		    {expect, "un reseau compatible, en France metropolitaine et Monaco.*1:Souscrire"},
		    {send, "1"},
		    {expect, "Votre demande a ete prise en compte et sera effective sous 72h sous reserve que votre mobile soit compatible visio Merci de votre appel"}
		   ];
	      X when X==?m6_prepaid;
		     X==?OM_mobile;
		     X==?click_mobi->
		  [

		   {expect,"Service accessible aux clients d'une offre prepayee Orange sur un plan decompte a la seconde des la premiere seconde..*1:Suite "},
		   {send, "1"},
		   {expect,"Visiophonie disponible entre terminaux et sur reseaux compatibles. Les communications visio sont decomptees a la seconde.*1:Suite"},
		   {send, "1"},
		   {expect,"des la premiere seconde \\(les 15 premiere secondes sont gratuites\\) au tarif du plan a la seconde du client.*1:Suite"},
		   {send, "1"},
		   {expect,"Service disponible pour les appels en France metropolitaine, les mobiles visio Orange et les mobiles visio des operateurs proposant....*1:Suite"},
		   {send, "1"},
		   {expect,"un reseau compatible en France metropolitaine et Monaco....*1:Souscrire"},
		   {send, "1"},
                   {expect,"Votre demande a ete prise en compte et sera effective sous 72h sous reserve que votre mobile soit compatible visio.Merci de votre appel"}
                  ];
	      _->	  
		  [
		   {expect, "Service accessible aux clients mobicarte et cartes prepayees sur un plan decompte a la seconde des la premiere seconde....*1:Suite"},
		   {send, "1"},
		   {expect, "Visiophonie disponible entre terminaux et sur reseaux compatibles. Les communications visio sont decomptees a la seconde....*1:Suite"},
		   {send, "1"},
		   {expect, "des la premiere seconde \\(les 15 premiere secondes sont gratuites\\) au tarif du plan a la seconde du client.*1:Suite"},
		   {send, "1"},
		   {expect, "Service disponible pour les appels en France metropolitaine, les mobiles visio Orange et les mobiles visio des operateurs proposant....*1:Suite"},
		   {send, "1"},
		   {expect, "un reseau compatible en France metropolitaine et Monaco....*1:Souscrire"},
		   {send,"1"},
		   {expect,"Votre demande a ete prise en compte et sera effective sous 72h sous reserve que votre mobile soit compatible visio.Merci de votre appel"}
		  ]
	  end
	 }]++
	[];

test_opt_multimedia(Opt=opt_mes_donnees, DCL) ->    
    init_test(DCL)++
	init_sachem(no_option) ++
	[{title, "Votre Multimedia - option mes donnees inactive - Test Souscription - "++dcl_label(DCL)},
	 {ussd2,
	  [ {send, code_option(Opt, DCL)++"#"},
	    {expect,"Avec l'option Mes donnees .30Go, beneficiez de 30Go supplementaires pour stocker, partager vos fichiers multimedias pour 5E par mois.*1:Souscrire.*"},
	    {send,"1"},
	    {expect,"Vous allez souscrire a l'option Mes donnees .30Go pour 5E..1:Valider"},
	    {send, "1"},
	    {expect,"Vous avez souscrit a l'option Mes donnees .30Go pour 5E. Ce montant a ete debite de votre compte."
	     ".*9:Accueil"}
	   ]}]++

	init_sachem(no_option) ++
	[{title, "Test Option Mes donnees +30Go - Mentions legales - "++dcl_label(DCL)},
         {ussd2,
          [
           {send, code_option(Opt, DCL)++"#"},
           {expect, "Avec l'option Mes donnees .30Go, beneficiez de 30Go supplementaires pour stocker, partager vos fichiers multimedias pour 5E par mois.*1:Souscrire.*7:Conditions"},
	   {send, "7"},
	   {expect,"Option mes donnees \\+30 Go a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors Fnac Mobile\\)..*1:Suite"},
	   {send,"1"},
	   {expect,"Augmentation de l'espace de stockage sur le service mes donnees, de 30 Go supplementaires, permettant aux souscripteurs de passer de..*1:Suite"},
	   {send,"1"},
	   {expect,"10 a 40 Go de stockage pour les clients mobile ou de 20 a 50 Go pour les clients mobiles ayant active l'option gratuite..*1:Suite"},            
	   {send,"1"},
	   {expect,"mes services unifies. Service accessible depuis tout compte Orange disposant d'une facture. Sont factures en dehors de l'option les..*1:Suite"},
	   {send,"1"},
	   {expect,"couts de connexions lies a l'acces au service depuis son terminal. Cette option peut etre interrompue a tout..*1:Suite"},
	   {send,"1"},
	   {expect,"moment par l'utilisateur. Usages en France metropolitaine. Service accessible sur reseaux et depuis un terminal compatible..*1:Suite"},
	   {send,"1"},
	   {expect,"Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr."}
	  ]}] ++

	init_sachem([Opt],"S") ++ %%% S -> suspend
	[{title, "Votre Multimedia - option mes donnees suspendue - Test Reactivation - "++dcl_label(DCL)},
         {ussd2,
          [ 
	    {send, code_option(Opt, DCL)++"#"},
	    {expect,"Votre option Mes donnees .30Go est actuellement suspendue..1:Suite"},
	    {send,"1"},
	    {expect,"Vous ne beneficiez plus de plus de 30Go supplementaires pour stocker, partager vos fichiers multimedias..1:Reactiver l'option"},
	    {send,"1"},
	    {expect,"Vous allez reactiver l'option Mes donnees .30Go pour 5E. Cette option est renouvelee chaque mois a date anniversaire pour 5E par mois..1:Confirmer"},
	    {send,"1"},
	    {expect,"la reactivation de votre option Mes donnees .30Go a bien ete prise en compte. 5E ont ete debites de votre compte."
	     ".*9:Accueil"}
           ]}]++

	init_sachem(Opt) ++
	[{title, "Votre Multimedia - option mes donnees active - Test Suppression - "++dcl_label(DCL)},
	 {ussd2,
	  [
	   {send, code_option(Opt, DCL)++"#"},
	   {expect,"Votre option Mes donnees .30Go est actuellement activee.*1:Supprimer l'option"},
	   {send,"1"},
	   {expect,"Merci de confirmer la suppression de votre option Mes donnees .30Go.Si vous supprimez votre option maintenant,.*1:Suite"},
	   {send,"1"},
	   {expect,"vous perdez immediatement le benefice de celle-ci.*1:Valider"},
	   {send,"1"},
	   {expect,"La suppression de votre option Mes donnees .30Go a bien ete prise en compte. Merci de votre appel"
	    ".*9:Accueil"}
	  ]}]++

	[];

test_opt_multimedia(Opt=opt_foot_ligue1, DCL) ->
    test_conditions(Opt, DCL) ++
        test_suppression(Opt, DCL)++
        test_reactivation(Opt, DCL)++
	[];

test_opt_multimedia(Opt=opt_orange_sport, DCL) ->
    test_conditions(Opt, DCL) ++
 	test_souscription(Opt, DCL)++
 	test_suppression(Opt, DCL)++
 	test_reactivation(Opt, DCL)++
	[].

test_souscription(Opt, DCL) ->
    init_test(DCL) ++
        set_present_period(Opt) ++
        init_sachem(no_option)++
	[{title, "TEST Votre Multimedia - "++option_label(Opt)++" inactive - Souscription - "++dcl_label(DCL)},
         {ussd2,
          [ 
	    {send, code_option(Opt, DCL)},
	    {expect, expect_text(description1, Opt)},
	    {send, "1"},
	    {expect, expect_text(souscription, Opt)},
	    {send, "1"},
            {expect, expect_text(validation1, Opt)},
	    {send, "1"},
            {expect, expect_text(validation2, Opt)}
	   ]
	 }].

test_suppression(Opt, DCL) ->
    init_test(DCL) ++
        set_present_period(Opt) ++
        init_sachem(Opt)++
        [{title, "TEST Votre Multimedia - "++option_label(Opt)++" activee - Suppression - "++dcl_label(DCL)},
         {ussd2,
          [
	    {send,code_opts(active,Opt,DCL)},
            {expect, expect_text(description_actived, Opt)},
            {send, "1"},
            {expect, expect_text(suppression1, Opt)},
            {send, "1"},
            {expect, expect_text(suppression2, Opt)},
            {send, "1"},
            {expect, expect_text(suppressed, Opt)}
           ]
         }].

test_reactivation(Opt, DCL) ->
    init_test(DCL) ++
        set_present_period(Opt) ++
        init_sachem([Opt], "S")++
        [{title, "TEST Votre Multimedia - "++option_label(Opt)++" suspendue - Reactivation - "++dcl_label(DCL)},
         {ussd2,
          [ 
	    {send,code_opts(suspend,Opt,DCL)},
            {expect, expect_text(description_suspend, Opt)},
            {send, "1"},
            {expect, expect_text(reactivation, Opt)},
            {send, "1"},
            {expect, expect_text(reactived1, Opt)},
            {send, "1"},
            {expect, expect_text(reactived2, Opt)}
           ]
         }].

test_conditions(Opt, DCL) ->
    init_test(DCL) ++
        set_present_period(Opt) ++
	init_sachem(Opt)++
        [{title, "TEST Votre Multimedia - "++option_label(Opt)++" - Conditions - "++dcl_label(DCL)},
         {ussd2,

          [
	   {send, code_opts(active,Opt,DCL)++ "7#"}
	  ]++
	  %% Test conditions
	  men_leg(Opt)

	 }].

option_label(Opt) ->
    case Opt of
	opt_orange_sport ->
	    "Option Sport";
	opt_foot_ligue1 ->
	    "Option Orange foot";
	_ ->
	    ""
    end.

men_leg(opt_orange_sport) ->
    [
     {expect, "Option Sport a souscrire et valable pour des usages en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\).*1:Suite"},
     {send, "1"},
     {expect, "sur reseaux et depuis un terminal compatibles. Option incompatible avec l'option TV max et l'avantage OM. Navigation illimitee sur.*1:Suite"},
     {send, "1"},
     {expect, "le portail Orange World. Consultation illimitee sur le portail Orange World et/ou l'application Orange correspondante de 8 matchs de Ligue 1R en.*1:Suite"},
     {send, "1"},
     {expect, "direct par journee de championnat, de tous les evenements sportifs en direct proposes sur l'espace sport \\(hors directs TV\\),.*1:Suite"},
     {send, "1"},
     {expect, "des chaines TV Orange sport et Orange sport info et des videos des rubriques actualite, sport et cinema \\(hors Orange cinema series\\)..*1:Suite"},
     {send, "1"},
     {expect, "Liste des chaines susceptible d'evolution. Ne sont pas compris les contenus et services payants. Pour une qualite de service optimale.*1:Suite"},
     {send, "1"},
     {expect, "sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation..*1:Suite"},
     {send, "1"},
     {expect, "Details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr. Usages en France metropolitaine. Services.*1:Suite"},
     {send, "1"},
     {expect, "accessibles sur reseaux et depuis un terminal compatibles. Matchs de Ligue 1R en direct et chaines TV accessibles sur terminaux.*1:Suite"},
     {send, "1"},
     {expect, "iPhone sous reserve de telechargement aux tarifs en vigueur de l'application correspondante. Autres evenements.*1:Suite"},
     {send, "1"},
     {expect, "sportifs en direct sous reserve de disponibilite de l'application correspondante.Pour les clients mobicarte et cartes prepayees,.*1:Suite"},
     {send, "1"},
     {expect, "option valable 31 jours a compter de la date d'activation intervenant sous 48h a compter de la souscription puis renouvelee.*1:Suite"},
     {send, "1"},
     {expect, "tous les mois sous reserve d'un credit suffisant. Souscription a l'option au 220 et #123#, en service clients et sur www.orange.fr."}
    ];

men_leg(opt_foot_ligue1) ->
    [
     {expect,"Option Orange foot a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Internet everywhere\\)..*1:Suite"},
     {send, "1"},
     {expect,"Option incompatible avec l'option TV max.Navigation illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange.*1:Suite"},
     {send, "1"},
     {expect,"World et/ou l'application Ligue 1R de 8 matchs de Ligue 1R en direct par journee de championnat et des videos des rubriques actualite.*1:Suite"},
     {send, "1"},
     {expect,"sport et cinema \\(hors Orange cinema series\\). Reception des alertes SMS Ligue 1R comprise dans l'option.Ne sont pas compris dans.*1:Suite"},
     {send, "1"},
     {expect,"l'option, les contenus et services payants. Pour une qualite de service optimale sur son reseau, Orange pourra limiter le debit au-dela.*1:Suite"},
     {send, "1"},
     {expect,"d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages en France metropolitaine. Services accessibles sur reseaux et depuis.*1:Suite"},
     {send, "1"},
     {expect,"un terminal compatibles. Matchs en direct accessibles sur terminaux iPhone sous reserve de telechargement aux tarifs en vigueur.*1:Suite"},
     {send, "1"},
     {expect,"de l'application correspondante. Voir details de l'option, conditions specifiques et liste des terminaux compatibles sur www.orange.fr..*1:Suite"},
     {send, "1"},
     {expect,"Pour les clients mobicarte et cartes prepayees, option valable 31 jours a compter de la date d'activation intervenant sous 48h a compter.*1:Suite"},
     {send, "1"},
     {expect,"de la souscription et renouvelee tous les mois sous reserve d'un credit suffisant. Souscription a l'option au 220, #123#,.*1:Suite"},
     {send, "1"},
     {expect,"service client et sur www.orange.fr"}
    ].



%% TEXTS SOUSCRIPTION
expect_text(description1, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Avec l'option Sport, suivez les grands evenements sportifs en illimite 24h/24 7j/7 pr 6E/mois";
	_ ->
            ""
    end++
	".*1:Souscrire";

expect_text(souscription, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Vous allez souscrire a l'option Sport pour 6E.";
	_ ->
            ""
    end++
        ".*1:Valider";

expect_text(validation1, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Vous avez souscrit a l'option Sport pour 6E. Ce montant a ete debite de votre compte.";
	_ ->
            ""
    end++
        ".*1:Suite";

expect_text(validation2, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Attention : votre option Sport sera active dans 48 heures.";
        _ ->
            ""
    end;

%% TEXTS SUPPRESSION
expect_text(description_actived, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Votre option Sport est actuellement activee.";
	opt_foot_ligue1 ->
	    "Votre option Orange foot est actuellement activee.";
	_ ->
            ""
    end++
	".*1:Supprimer l'option";

expect_text(suppression1, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Merci de confirmer la suppression de votre option Sport. Si vous supprimez votre option maintenant,";
	opt_foot_ligue1 ->
            "Merci de confirmer la suppression de votre option Orange foot.Si vous supprimez votre option maintenant,";
	_ ->
            ""
    end++
	".*1:Suite";

expect_text(suppression2, Opt) ->
    case Opt of
        opt_orange_sport ->
            "vous perdez immediatement le benefice de celle-ci.";
	opt_foot_ligue1 ->
            "vous perdez immediatement le benefice de celle-ci.";
	_ ->
            ""
    end++
	".*1:Valider";

expect_text(suppressed, Opt) ->
    case Opt of
        opt_orange_sport ->
            "La suppression de votre option Sport a bien ete prise en compte..*Merci de votre appel.";
	opt_foot_ligue1 ->
            "La suppression de votre option Orange foot a bien ete prise en compte.";
	_ ->
            ""
    end;

%% TEXTS REACTIVATION
expect_text(description_suspend, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Votre option Sport est actuellement suspendue.";
	opt_foot_ligue1 ->
            "Votre option Orange foot est actuellement suspendue.";
	_ ->
            ""
    end++
	".*1:Reactiver l'option"
	".*2:Supprimer l'option";

expect_text(reactivation, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Vous allez reactiver l'option Sport pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois.";
	opt_foot_ligue1 ->
            "Vous allez reactiver l'option Orange foot pour 6E. Cette option est renouvelee chaque mois a date anniversaire pour 6E";
	_ ->
            ""
    end++
	".*1:Confirmer";

expect_text(reactived1, Opt) ->
    case Opt of
        opt_orange_sport ->
            "la reactivation de votre option Sport a bien ete prise en compte..*6E ont ete debites de votre compte.";
	opt_foot_ligue1 ->
            "la reactivation de votre option Orange foot a bien ete prise en compte..*6E ont ete debites de votre compte.";
	_ ->
            ""
    end++
	".*1:Suite";

expect_text(reactived2, Opt) ->
    case Opt of
        opt_orange_sport ->
            "Attention : votre option Sport sera active dans 48 heures.";
	opt_foot_ligue1 ->
            "Attention : votre option Orange foot sera active dans 48 heures.";
	_ ->
            ""
    end.    


test_opt_multimedia_promo(Opt=opt_tv, DCL) ->
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
	[{title, "Votre Multimedia PROMO - option TV PROMO - Test Subscription and Conditions"},
         "Test Menu votre multimedia TV PROMO - Test Subscription and Conditions - DCL = "++ integer_to_list(DCL),
         {ussd2,
          [
	   {send, code_option(Opt, DCL)},
	   {expect, "Grace a votre promotion 1er rechargement, vous beneficiez de bons plans offerts..*"
	    "1:Suite.*7:Conditions"},
	   {send, "1"},
	   {expect, "Pensez a verifier le credit de votre compte bons plans offerts \\(suivi conso \\+\\). Si le credit est insuffisant,.*"
	    "1:Suite.*7:Conditions"},
	   {send, "1"},
           {expect, "le montant du bon plan sera debite de votre compte principal..Avec l'option TV \\(d'une valeur de 6E\\).*"
	    "1:Suite.*7:Conditions"},
	   {send, "1"},
           {expect, "profitez de plus de 20 chaines, de tte la video en illimite et de tous les services d'Orange World..*"
	    "1:Souscrire.*7:Conditions"}
	  ]++

	  test_men_leg(Opt, DCL)++

	  [
	   {send, "1"},
           {expect, "Vous allez souscrire a l'option TV \\(d'une valeur 6E\\). Cette option est renouvelee chaque mois a date anniversaire pour 6E par mois..*"
	    "1:Valider"},
	   {send, "1"},
	   {expect, "Vous avez souscrit a l'option TV pour 6E. Ce montant a ete debite de votre compte..*"
	    "1:Suite"
	    ".*9:Accueil"},
	   {send, "1"},
           {expect, "Attention : votre option TV sera active dans 48 heures."
	    ".*9:Accueil"}
	  ]

	 }]++
	[].

test_men_leg(opt_tv, DCL) ->
    case DCL of
	?mobi ->
	    [
	     {send, "7"},
	     {expect, "Option TV a souscrire et valable en France metropolitaine. Acces et connexions illimitees 24H/24 aux services du Portail Orange World.*1:Suite"},
	     {send, "1"},
	     {expect, "\\(hors Gallery, Internet, streaming audio, Orange Messenger by Windows Live, et hors contenus et telechargements payants\\).*1:Suite"},
	     {send, "1"},
	     {expect, "Acces et connexions illimitees a plus de 20 chaines de television et a toutes les videos proposees sur Orange World, Liste des chaines TV.*1:Suite"},
	     {send, "1"},
	     {expect, "susceptible d'evolution. Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option, Conditions Specifiques et.*1:Suite"},
	     {send, "1"},
	     {expect, "liste des mobiles compatibles sur www.orange.fr. Option non compatible avec l'option TV max, L'option sera valable 31 jours consecutifs.*1:Suite"},
	     {send, "1"},
	     {expect, "a compter de la date d'activation de l'option intervenant sous 48h a compter de la souscription et renouvelee tous les mois..*1:Suite"},
	     {send, "1"},
	     {expect, "Le prix de l'option sera preleve sur le compte du client chaque mois sous reserve que le credit dudit compte soit suffisant..*1:Souscrire"}
	    ];
	?click_mobi ->
	    [
	     {send, "7"},
	     {expect, "Option TV a souscrire et valable en France metropolitaine pour tout client mobile Orange \\(hors offres Orange incluant plus de 20 chaines.*1:Suite"},
	     {send, "1"},
	     {expect, "TV en illimite\\). Navigation illimitee sur le portail Orange World. Consultation illimitee sur le portail Orange World et/ou.*1:Suite"},
	     {send, "1"},
	     {expect, "l'application orange TV player de plus de 20 chaines de TV et de toutes les videos proposees. Liste des chaines TV susceptible d'evolution.*1:Suite"},
	     {send, "1"},
	     {expect, "Sont factures en dehors de l'option, les evenements sportifs en direct, les contenus et services payants. Pour une qualite de service.*1:Suite"},
	     {send, "1"},
	     {expect, "optimale sur son reseau, Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation.Usages.*1:Suite"},
	     {send, "1"},
	     {expect, "en France metropolitaine. Services accessibles sur reseaux et depuis un terminal compatibles. Voir details de l'option, conditions.*1:Suite"},
	     {send, "1"},
	     {expect, "specifiques et liste des terminaux compatibles sur www.orange.fr. Pour les clients mobicarte et cartes prepayees, option valable 31 jours.*1:Suite"},
	     {send, "1"},
	     {expect, "a compter de la date d'activation intervenant sous 48h a compter de la souscription et renouvelee tous les mois sous reserve d'un.*1:Suite"},
	     {send, "1"},
	     {expect, "credit suffisant. Souscription a l'option au 220 et #123#, en service clients et sur www.orange.fr.*1:Souscrire"}	    ]
    end.

init_test()->
    init_test(?mobi).
init_test(DCL_NUM)->
    profile_manager:create_default(?Uid,"mobi")++
	profile_manager:set_dcl(?Uid,DCL_NUM)++
	profile_manager:set_list_comptes(?Uid,
					 [#compte{tcp_num=?C_PRINC,
						  unt_num=?EURO,
						  cpp_solde=42000,
						  dlv=pbutil:unixtime(),
						  rnv=0,
						  etat=?CETAT_AC,
						  ptf_num=?PCLAS_V2}])++
	profile_manager:init(?Uid).

init_sachem(Options,Param) 
  when (Param == "-") or (Param == "S")->
    List_options=lists:map(fun(Option_name)->#option{top_num=top_num(Option_name),
						     opt_info2=Param} end,
			   Options),
    profile_manager:set_list_options(?Uid,List_options).

init_sachem(no_option)->
    profile_manager:set_list_options(?Uid,[])++
	test_123_mobi_bons_plans_autres_options:reset_imsi_unik();


init_sachem(Option) ->
    init_sachem([Option],"-").

set_present_period(Opt) ->
    test_util_of:set_present_commercial_date(Opt,mobi).
set_past_period(Opt) ->
    test_util_of:set_past_commercial_date(Opt,mobi).
