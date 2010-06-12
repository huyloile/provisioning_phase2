-module(text_opt_ow_3E_mobi).
-compile(export_all).

-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_generique(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_generique(Session, Opt) ->
    [{pcdata, generique_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_generique_promo(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_generique_promo(Session, Opt) ->
    [{pcdata, generique_promo_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_souscrire(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_souscrire(Session, Opt) ->
    [{pcdata, souscrire_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_souscrire(abs, _,_) ->
    [{pcdata, ""}];

ow_3E_mobi_souscrire(Session, Opt, Cpt) ->
    [{pcdata, souscrire_text(list_to_atom(Opt),Cpt)}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_confirmer(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_confirmer(Session, Opt) ->
    [{pcdata, confirmer_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_confirmer_promo(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_confirmer_promo(Session, Opt) ->
    [{pcdata, confirmer_promo_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_controle_solde(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_controle_solde(Session, Opt) ->
    [{pcdata, controle_solde_text(list_to_atom(Opt), ?mobi)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_m6_controle_solde(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_m6_controle_solde(Session, Opt) ->
    [{pcdata, controle_solde_text(list_to_atom(Opt), ?m6_prepaid)}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_foot_controle_solde(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_foot_controle_solde(Session, Opt) ->
    [{pcdata, controle_solde_text(list_to_atom(Opt), foot)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_click_controle_solde(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_click_controle_solde(Session, Opt) ->
    [{pcdata, controle_solde_text(list_to_atom(Opt), click)}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_controle_solde_promo(abs, _) ->
    [{pcdata, ""}];

ow_3E_mobi_controle_solde_promo(Session, Opt) ->
    [{pcdata, controle_solde_promo_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_conditions(abs, _, Range) ->
    [{pcdata, ""}];

ow_3E_mobi_conditions(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt), ?mobi,
			      list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_m6_conditions(abs, _, Range) ->
    [{pcdata, ""}];

ow_3E_mobi_m6_conditions(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt), ?m6_prepaid,
			      list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_foot_conditions(abs, _, Range) ->
    [{pcdata, ""}];

ow_3E_mobi_foot_conditions(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt), foot,
			      list_to_integer(Range))}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_conditions_promo(abs, _, Range) ->
    [{pcdata, ""}];

ow_3E_mobi_conditions_promo(Session, Opt, Range) ->
    [{pcdata, conditions_promo_text(list_to_atom(Opt), ?mobi,
				    list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ow_3E_mobi_m6_conditions_promo(abs, _, Range) ->
    [{pcdata, ""}];

ow_3E_mobi_m6_conditions_promo(Session, Opt, Range) ->
    [{pcdata, conditions_promo_text(list_to_atom(Opt), ?m6_prepaid,
				    list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generique_text(OPT) ->
    "Avec l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++","
	" accedez sans contrainte aux services Orange World a un"
	" tarif privilegie...".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generique_promo_text(OPT) -> 
    "Votre 1ere option " 
	++svc_util_of:get_opt_name(OPT, mobi)++
	" est offerte jusqu'au "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++"."
	" Accedez sans contrainte aux services Orange World.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

souscrire_text(OPT) ->
    "Votre souscription a bien ete prise en compte.\n"
	"Dans quelques instants, votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" sera activee."
	" Merci de votre appel.".
souscrire_text(OPT,CPT) ->
    "Vous avez souscrit a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" pour "
	++svc_util_of:get_option_price(OPT, mobi)++
	". Ce montant a ete debite de votre compte "
	++CPT++
	". Dans quelques instants, votre bon plan sera active.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

confirmer_text(OPT) ->
    "Vous allez souscrire a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" pour "
	++svc_util_of:get_option_price(OPT, mobi)++"."
	" Ce montant sera debite de votre compte ".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

confirmer_promo_text(OPT) ->
    "Vous allez beneficier de votre premiere option " 
	++svc_util_of:get_opt_name(OPT, mobi)++
	" offerte.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

controle_solde_text(OPT, ?m6_prepaid) ->
    "Bonjour, pour souscrire a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	", vous devez disposer de plus de "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sur votre compte principal."
	" Merci de votre appel.";

controle_solde_text(OPT, foot) ->
    "Bonjour, pour souscrire a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	", vous devez disposer de plus de "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sur votre compte."
	" Merci de votre appel.";

controle_solde_text(OPT, click) ->
    "Bonjour, pour souscrire a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	", vous devez disposer de plus de "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sur votre compte."
	" Merci de votre appel.";

controle_solde_text(OPT, _) ->
    "Bonjour, pour souscrire a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	", vous devez disposer de plus de "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sur votre compte."
	" Merci de votre appel.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

controle_solde_promo_text(OPT) ->
    "Bonjour, pour beneficier de votre 1ere souscription a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" offerte, vous devez disposer d'un credit > a "
	++svc_util_of:get_option_price(OPT, mobi_promo)++".".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conditions_text(OPT, foot, 1) ->
    "5 Mo pour naviguer sur Orange world, Gallery et Internet."
	" Communications WAP et WEB en France metropolitaine (sous"
	" reserve que votre fournisseur d'acces ait ...";

conditions_text(OPT, _, 1) ->
    "5 Mo pour naviguer sur Orange world, Gallery et Internet."
	" Communications WAP et WEB en France metropolitaine (sous"
	" reserve que votre fournisseur d'acces ait ...";

conditions_text(OPT, _, 2) ->
    "...demande a etre inclus dans l'offre)."
	" Ces communications sont decomptees de l'option choisie au"
	" Ko au-dela d'un premier palier de 10Ko indivisible.";

conditions_text(OPT, _, 3) ->
    "...en 3G/EDGE/GPRS ou a la seconde des la 1re seconde en CSD,"
	" le cas echeant."
	" Disponibles depuis un terminal compatible."
	" Liste sur www.orange.fr."
	" En cas...";

conditions_text(OPT, _, 4) ->
    "...de perte des reseaux 3G, EDGE et GPRS, il sera propose aux clients"
	" de continuer en CSD a concurrence de 5h sur l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++"."
	"Offre incompatible...";

conditions_text(OPT, _, 5) ->
    "...avec l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++"."
	" Detail de l'offre et conditions specifiques sur"
	" www.orange.fr."
	" L'option est valable 31 jours a compter de la souscription...";

conditions_text(OPT, _, 6) ->
    "...Souscription au 220 et #123# (appels gratuits)...";

conditions_text(OPT, ?m6_prepaid, 7) ->
    "Le prix de l'option sera preleve sur le compte principal du client"
	" sous reserve que le credit dudit compte soit suffisant.";

conditions_text(OPT, foot, 7) ->
    "Le prix de l'option sera preleve sur le compte du client"
	" sous reserve que le credit dudit compte soit suffisant.";

conditions_text(OPT, _, 7) ->
    "Le prix de l'option sera preleve sur le compte du client"
	" sous reserve que le credit dudit compte soit suffisant.";

conditions_text(_, _, _) -> 
    "".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conditions_promo_text(OPT, _, 1) ->
   "Offre valable en France metropolitaine."
	" 1er mois offert pour toute 1ere souscription a l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" avant le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et...";

conditions_promo_text(OPT, ?m6_prepaid, 2) ->
    "...reservee aux clients d'une offre prepayee Orange ayant active"
	" leur ligne entre le "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++
	" et le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus sous reserve d'un credit > a "
	++svc_util_of:get_option_price(OPT, mobi_promo)++"...";

conditions_promo_text(OPT, _, 2) ->
    "...reservee aux clients mobicarte ayant active leur ligne entre le "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++
	" et le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus sous reserve d'un credit > a "
	++svc_util_of:get_option_price(OPT, mobi_promo)++"...";

conditions_promo_text(OPT, _, 3) ->
    "...5 Mo pour naviguer sur Orange world, Gallery et Internet."
	" Communications WAP et WEB en France metropolitaine (sous reserve que"
	" votre fournisseur d'acces ait...";

conditions_promo_text(OPT, _, 4) ->
    "...demande a etre inclus dans l'offre)."
	" Ces communications sont decomptees de l'option choisie au Ko"
	" au-dela d'un premier palier de 10Ko indivisible...";

conditions_promo_text(OPT, _, 5) ->
    "...en 3G/EDGE/GPRS ou a la seconde des la 1re seconde en CSD, le cas echeant."
	" Disponibles depuis un terminal compatible."
	" Liste sur www.orange.fr.";

conditions_promo_text(OPT, _, 6) ->
    "...En cas de perte des reseaux 3G, EDGE et GPRS, il sera propose aux clients"
	" de continuer en CSD a concurrence de 5h sur l'option "
	++svc_util_of:get_opt_name(OPT, mobi)++"...";

conditions_promo_text(OPT, _, 7) ->
    "...Offre incompatible avec l'option "
	++svc_util_of:get_opt_name(opt_ow_6E_mobi, mobi)++"."
	" Detail de l'offre et conditions specifiques sur www.orange.fr."
	" L'option est...";

conditions_promo_text(OPT, _, 8) ->
    "...valable 31 jours a compter de la souscription."
	" Souscription au 220 et #123# (appels gratuits).".
