-module(text_opt_ikdo_vx_sms).
-compile(export_all).

-include("../include/ftmtlv.hrl").
-include("../../pserver/include/pserver.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_suivi_rech_ok_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_suivi_rech_ok_text(Session, Opt) ->
    [{pcdata, suivi_rech_ok_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_suivi_rech_nok_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_suivi_rech_nok_text(Session, Opt) ->
    [{pcdata, suivi_rech_nok_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_rech_ok_inf30_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_rech_ok_inf30_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    Amount = State#sdp_user_state.refill_amount,
    [{pcdata, rech_ok_inf30_text(list_to_atom(Opt), Amount)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_rech_ok_sup30_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_rech_ok_sup30_text(Session, Opt) ->
    [{pcdata, rech_ok_sup30_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_rech_nok_inf30_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_rech_nok_inf30_text(Session, Opt, Range) ->
    State = svc_util_of:get_user_state(Session),
    Amount = State#sdp_user_state.refill_amount,
    [{pcdata, rech_nok_inf30_text(list_to_atom(Opt), Amount,
				  list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_inscr_nb_max_atteint_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_inscr_nb_max_atteint_text(Session, Opt) ->
    [{pcdata, inscr_nb_max_atteint_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_inscr_generique_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_inscr_generique_text(Session, Opt, Range) ->
    [{pcdata, inscr_generique_text(list_to_atom(Opt), list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_inscrire_suite_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_inscrire_suite_text(Session, Opt) ->
    [{pcdata, inscrire_suite_text(list_to_atom(Opt))}]
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_confirmer_suite_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_confirmer_suite_text(Session, Opt) ->
    [{pcdata, confirmer_suite_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_conditions_inscr_text(abs, _, Range) ->
    [{pcdata, ""}];

ikdo_vx_sms_conditions_inscr_text(Session, Opt, Range) ->
    [{pcdata, conditions_inscr_text(list_to_atom(Opt),
				    list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_inscrire_cond_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_inscrire_cond_text(Session, Opt) ->
    [{pcdata, inscrire_cond_text(list_to_atom(Opt))}]
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_confirmer_cond_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_confirmer_cond_text(Session, Opt) ->
    [{pcdata, confirmer_cond_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_inscrire_gratuit_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_inscrire_gratuit_text(Session, Opt, Range) ->
    [{pcdata, inscrire_gratuit_text(list_to_atom(Opt),
				    list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_confirmer_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_confirmer_text(Session, Opt) ->
    [{pcdata, confirmer_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_enreg_generique_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_enreg_generique_text(Session, Opt, Range) ->
    [{pcdata, enreg_generique_text(list_to_atom(Opt),
				   list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_enregistrer_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_enregistrer_text(Session, Opt) ->
    [{pcdata, enregistrer_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_enreg_ok_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_enreg_ok_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    Msisdn = State#sdp_user_state.numero_kdo_illimite,
    [{pcdata, enreg_ok_text(list_to_atom(Opt), Msisdn)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_enreg_nok_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_enreg_nok_text(Session, Opt) ->
    [{pcdata, enreg_nok_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_conditions_enreg_text(abs, _, Range) ->
    [{pcdata, ""}];

ikdo_vx_sms_conditions_enreg_text(Session, Opt, Range) ->
    [{pcdata, conditions_enreg_text(list_to_atom(Opt),
				    list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_consulter_generique_text(abs, _, Range) ->
    [{pcdata, ""}];

ikdo_vx_sms_consulter_generique_text(Session, Opt, Range) ->
    State = svc_util_of:get_user_state(Session),
    Msisdn = State#sdp_user_state.numero_kdo_illimite,
    [{pcdata, consulter_generique_text(list_to_atom(Opt), Msisdn,
				       list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_deja_modifie_text(abs, _, Range) ->
    [{pcdata, ""}];

ikdo_vx_sms_deja_modifie_text(Session, Opt, Range) ->
    [{pcdata, deja_modifie_text(list_to_atom(Opt),
				list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_modifier_generique_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_modifier_generique_text(#session{prof=#profile{msisdn=Msisdn_user}=Prof}=Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    Msisdn = State#sdp_user_state.numero_kdo_illimite,
    case Msisdn of
	undefined -> slog:event(failure,?MODULE,error_in_msisdn,{Msisdn_user}),
		     [{pcdata, modifier_generique_text(list_to_atom(Opt), Msisdn)}];
	_-> [{pcdata, modifier_generique_text(list_to_atom(Opt), Msisdn)}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_modifier_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_modifier_text(Session, Opt) ->
    [{pcdata, modifier_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_modif_ok_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_modif_ok_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    Msisdn = State#sdp_user_state.numero_kdo_illimite,
    [{pcdata, modif_ok_text(list_to_atom(Opt), Msisdn)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_desinscrire_nok_inf30_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_desinscrire_nok_inf30_text(Session, Opt) ->
    [{pcdata, desinscrire_nok_inf30_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_desinscrire_nok_sup30_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_desinscrire_nok_sup30_text(Session, Opt, Range) ->
    [{pcdata, desinscrire_nok_sup30_text(list_to_atom(Opt), 
					 list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_desinscrire_ok_inf30_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_desinscrire_ok_inf30_text(Session, Opt, Range) ->
    [{pcdata, desinscrire_ok_inf30_text(list_to_atom(Opt), 
					list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_desinscrire_ok_sup30_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_desinscrire_ok_sup30_text(Session, Opt, Range) ->
    [{pcdata, desinscrire_ok_sup30_text(list_to_atom(Opt), 
					list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_conditions_text(abs, _, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_conditions_text(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt), list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_desinscrire_confirm_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_desinscrire_confirm_text(Session, Opt) ->
    [{pcdata, desinscrire_confirm_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ikdo_vx_sms_failure_desinscr_text(abs, _) ->
    [{pcdata, ""}];

ikdo_vx_sms_failure_desinscr_text(Session, Opt) ->
    [{pcdata, failure_desinscr_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suivi_rech_ok_text(OPT) ->
    "Vous beneficiez de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" jusqu'a la fin du mois."
	" Pour continuer a en profiter le mois prochain, rechargez au moins "
	++svc_util_of:get_opt_info(min_refill)++
	" ce mois-ci.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suivi_rech_nok_text(OPT) ->
    "Vous ne beneficiez pas de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" ce mois-ci."
	" Pour en profiter le mois prochain, pensez a recharger au moins "
	++svc_util_of:get_opt_info(min_refill)++
	" avt la fin de ce mois.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rech_ok_inf30_text(OPT, Refill_amount) ->
    "Depuis le "
	++svc_util_of:get_opt_info(month)++
	" vous avez recharge "
	++svc_util_of:get_opt_info(Refill_amount)++ " euros."
	" Des 30 euros recharges dans le mois, vous beneficierez le mois"
	" prochain d'appels et sms illimites vers votre No KDO.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rech_ok_sup30_text(OPT) ->
    "Felicitations, vous beneficierez d'appels et sms illimites vers"
	" votre No KDO le mois prochain, des reception du SMS de confirmation.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rech_nok_inf30_text(OPT, Refill_amount, 1) ->
    "Vous avez recharge "
	++svc_util_of:get_opt_info(Refill_amount)++ " euros."
	" A partir de "
	++svc_util_of:get_opt_info(min_refill)++
	" euros recharges dans le mois (apres votre inscription),";

rech_nok_inf30_text(OPT, _, 2) ->
    "vous beneficierez le mois  prochain d'appels et sms illimites vers"
	" votre No KDO.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inscr_nb_max_atteint_text(OPT) ->
    "Desole, cette offre etait reservee aux 100 000 premiers clients"
	" mobicarte inscrits. Ce chiffre est desormais atteint.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inscr_generique_text(OPT, 1) ->
    "Exclusif ! Beneficiez des sms illimites en plus des appels illimites"
	" 24h/24 et 7j7 vers votre numero de mobile Orange...";
inscr_generique_text(OPT, 2) ->
    "...prefere pour toute inscription gratuite a l'illimite KDO avt le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++ "."
	" A partir de "
	++svc_util_of:get_opt_info(min_refill)++
	" euros recharges dans le mois...";

inscr_generique_text(OPT, 3) ->
    "... vous beneficierez d'appels et sms illimites 7j/7 et 24h/24"
	" vers votre numero KDO le mois suivant...";

inscr_generique_text(OPT, 4) ->
    "...Tout rechargement effectue avant l'inscription a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" ne sera pas pris en compte.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inscrire_suite_text(OPT) ->
    "Vous allez vous inscrire  gratuitement a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

confirmer_suite_text(OPT) ->
    "Votre inscription a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" a bien ete prise en compte."
	" Le cumul de vos rechgts du mois commence maintenant."
	" C'est a vous!".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conditions_inscr_text(OPT, 1) ->
    "Offre valable en France metropolitaine reservee aux 100 000 premiers"
	" clients de l'offre mobicarte uniquement, ayant active leur ligne"
	" entre le "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++ "...";

conditions_inscr_text(OPT, 2) ->
    "...et le "
        ++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et inscrits a l'illimite kdo serie limitee de Noel avant le"
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus."
	" Inscription gratuite et choix du No KDO...";

conditions_inscr_text(OPT, 3) ->
    "...Orange en appelant le 220 ou en composant le #123# (appels gratuits)."
	"SMS de confirmation de l'activation du No KDO Orange envoye"
	" au client beneficiaire le mois suivant..";

conditions_inscr_text(OPT, 4) ->
    "...le rechargement de "
	++svc_util_of:get_opt_info(min_refill)++
	" minimum cumules par mois calendaire (hors recharge sms et"
	" hors credit offert) ne sera pas pris en compte."
	" Tout rechargement effectue...";

conditions_inscr_text(OPT, 5) ->
    "...avant l'inscription a l'illimite KDO serie limitee de Noel"
	" ne sera pas pris en compte."
	" Appels voix/visio en France metropolitaine et sms...";

conditions_inscr_text(OPT, 6) ->
    "metropolitains (hors sms surtaxes) vers un No KDO Orange (3 heures"
	" maximum par appel, hors nos de mobiles Orange ou tout autre"
	" operateur en cours de portabilite,...";

conditions_inscr_text(OPT, 7) ->
    "...hors nos speciaux, nos courts, nos d'acces WAP et WEB, appels"
	" emis depuis des boitiers et appels vers plate formes telephoniques)"
	" le mois suivant le...";

conditions_inscr_text(OPT, 8) ->
    "...rechargement."
	" Appels et sms directs entre personnes physiques et pour un usage"
	" non lucratif direct...";

conditions_inscr_text(OPT, 9) ->
    "...Appels en visiophonie entre terminaux et sur reseaux compatibles"
	" et SMS illimites pendant un an fin de mois a compter de"
	" l'inscription.";

conditions_inscr_text(OPT, 10) ->
    "...pendant un an a compter de l'inscription.".
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inscrire_cond_text(OPT) ->
    "Vous allez vous inscrire gratuitement a l'illimite KDO."
	" Tout rechargement effectue avant l'inscription a l'illimite"
	" KDO ne sera pas pris en compte.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

confirmer_cond_text(OPT) ->
    "Votre inscription a l'illimite KDO a bien ete prise en compte."
	" Le cumul de vos rechargements du mois commence maintenant."
	" C'est a vous!".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inscrire_gratuit_text(OPT, 1) ->
    "Vous allez vous inscrire gratuitement a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Tout rechargement effectue avant l'inscription...";

inscrire_gratuit_text(OPT, 2) ->
    " ...a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" ne sera pas pris en compte dans le cumul"
	" du rechargement.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

confirmer_text(OPT) ->
    "Votre inscription a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" a bien ete prise en compte."
	" Le cumul de vos rechargements du mois commence maintenant.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enreg_generique_text(OPT, 1) ->
    "Beneficiez d'appels et sms illimites vers votre numero de mobile"
	" prefere Orange."
	" A partir de "
	++svc_util_of:get_opt_info(min_refill)++
	" euros recharges dans le mois...";

enreg_generique_text(OPT, 2) ->
    "...vous beneficierez d'appels et sms illimites 7j/7 et 24h/24"
	" vers votre numero KDO le mois suivant.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enregistrer_text(OPT) ->
    "Merci de bien vouloir taper les 10 chiffres de votre numero KDO."
	" Ce numero doit etre un numero de mobile Orange.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enreg_ok_text(OPT, Msisdn) ->
    "Merci, vous avez enregistre le "
	++svc_util_of:get_msisdn(Msisdn)++
	" comme numero KDO.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enreg_nok_text(OPT) ->
    "Le numero KDO que vous venez de saisir n'est pas un numero de mobile"
	" Orange.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conditions_enreg_text(OPT, 1) ->
    "Offre valable en France metropolitaine reservee aux 100 000 premiers"
	" clients de l'offre mobicarte uniquement ayant active leur ligne"
	" entre le "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy");

conditions_enreg_text(OPT, 2) ->
    "...et le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et inscrits a l'illimite kdo serie limitee d'Arthur"
	" et les Minimoys avant le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus."
	" Inscription gratuite et choix. ..";

conditions_enreg_text(OPT, 3) ->
    "... du No KDO Orange en appelant le 220 ou en composant le #123#"
	" (appels gratuits)."
	" SMS de confirmation de l'activation du No KDO Orange envoye au"
	" client...";

conditions_enreg_text(OPT, 4) ->
    "...beneficiaire le mois suivant le rechargement de "
	++svc_util_of:get_opt_info(min_refill)++"E"
	" minimum cumules par mois calendaire (hors recharge sms et hors"
	" credit offert)...";

conditions_enreg_text(OPT, 5) ->
    "...Tout rechargement effectue avant l'inscription a l'illimite KDO serie"
	" limitee d'Arthur et les Minimoys ne sera pas pris en compte...";

conditions_enreg_text(OPT, 6) ->
    "...Appels voix/visio en France metropolitaine et sms metropolitains"
	" (hors sms surtaxes) vers un No KDO."
	" 3 heures maximum par appel (hors nos de";

conditions_enreg_text(OPT, 7) ->
    "...mobiles Orange ou tout autre operateur en cours de portabilite,"
	" hors nos speciaux, nos courts, nos d'acces WAP et WEB, appels"
	" emis depuis des boitiers et...";

conditions_enreg_text(OPT, 8) ->
    " ...appels vers plate formes telephoniques) le mois suivant le"
	" rechargement."
	" Appels et sms directs entre personnes physiques et pour un usage"
	" non lucratif direct...";

conditions_enreg_text(OPT, 9) ->
    "... Appels en visiophonie entre terminaux et sur reseaux compatibles et"
	" SMS illimites pendant un an fin de mois a compter de l'inscription.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consulter_generique_text(OPT, Msisdn, 1) ->
    "Vous avez enregistre le "
	++svc_util_of:get_msisdn(Msisdn)++
	" comme numero KDO Orange."
	" Vous avez la possibilite de le modifier une fois uniquement"
	" dans le mois...";

consulter_generique_text(OPT, _, 2) ->
    "...ou vous beneficiez de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Pour modifier votre numero KDO, revenez au menu precedent.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

deja_modifie_text(OPT, 1) ->
    "Desole, vous avez deja modifie votre numero KDO ce mois-ci."
	" Un seul changement de numero KDO est autorise dans le mois ou"
	" vous beneficiez de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "...";

deja_modifie_text(OPT, 2) ->
    "...Vous pourrez a nouveau changer de numero KDO le prochain mois ou"
	" vous beneficierez a nouveau de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modifier_generique_text(OPT, Msisdn) ->
    "Vous voulez modifier votre numero KDO Orange."
	" Vous aviez enregistre le "
	++svc_util_of:get_msisdn(Msisdn)++
	" comme numero KDO?".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modifier_text(OPT) ->
    "Merci de bien vouloir taper les 10 chiffres de votre nouveau numero KDO."
	" Ce numero doit etre un numero de mobile Orange.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modif_ok_text(OPT, Msisdn) ->
    "Vous avez enregistre le "
	++svc_util_of:get_msisdn(Msisdn)++
	" comme numero KDO.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

desinscrire_nok_inf30_text(OPT) ->
    "Vous souhaitez vous desinscrire de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

desinscrire_nok_sup30_text(OPT, 1) ->
    "Attention si vous souhaitez vous desinscrire, vous perdrez"
	" immediatement tous les benefices lies a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Vous avez deja recharge...";

desinscrire_nok_sup30_text(OPT, 2) ->
    "...au moins "
	++svc_util_of:get_opt_info(min_refill)++
	" euros ce mois-ci, si vous confirmez votre souhait de vous"
	" desinscrire, vous perdrez le benefice de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" le mois suivant...".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

desinscrire_ok_inf30_text(OPT, 1) ->
    "Attention si vous souhaitez vous desinscrire, vous perdrez immediatement"
	" tous les benefices lies a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Vous beneficiez actuellement de...";

desinscrire_ok_inf30_text(OPT, 2) ->
    "...l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" jusqu'a la fin de ce mois."
	" Si vous vous desinscrivez,vous perdrez immediatement le benefice"
	" de l'"
	++svc_util_of:get_opt_name(OPT, mobi).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

desinscrire_ok_sup30_text(OPT, 1) ->
    "Attention si vous souhaitez vous desinscrire, vous perdrez immediatement"
	" tous les benefices lies a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Vous avez deja recharge...";

desinscrire_ok_sup30_text(OPT, 2) ->
    "...au moins "
	++svc_util_of:get_opt_info(min_refill)++
	" euros ce mois-ci, et vous beneficiez actuellement de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++
	" jusqu'a la fin de ce mois."
	" Si vous vous desinscrivez,...";

desinscrire_ok_sup30_text(OPT, 3) ->
    "...vous perdrez immediatement le benefice de l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "...".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conditions_text(OPT, 1) ->
    "Offre valable en France metropolitaine reservee aux 100 000 premiers"
	" clients de l'offre mobicarte uniquement ayant active leur ligne"
	" entre le "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy");

conditions_text(OPT, 2) ->
    "...et le " ++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et inscrits a l'illimite kdo serie limitee de Noel avant le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus."
	" Inscription gratuite et choix...";

conditions_text(OPT, 3) ->
    "... du No KDO Orange en appelant le 220 ou en composant le #123#"
	" (appels gratuits)."
	" SMS de confirmation de l'activation du No KDO Orange envoye au"
	" client  ...";

conditions_text(OPT, 4) ->
    "...beneficiaire le mois suivant le rechargement de "
	++svc_util_of:get_opt_info(min_refill)++"E"
	" minimum cumules par mois calendaire (hors recharge sms et hors"
	" credit offert)...";

conditions_text(OPT, 5) ->
    "...Tout rechargement effectue avant l'inscription a l'illimite KDO"
	" serie limitee de Noel ne sera pas pris en compte...";

conditions_text(OPT, 6) ->
    "...Appels voix/visio en France metropolitaine et sms metropolitains"
	" (hors sms surtaxes) vers un No KDO."
	" 3 heures maximum par appel (hors nos de";

conditions_text(OPT, 7) ->
    "...mobiles Orange ou tout autre operateur en cours de portabilite,"
	" hors nos speciaux, nos courts, nos d'acces WAP et WEB, appels"
	" emis depuis des boitiers et...";

conditions_text(OPT, 8) ->
    "...appels vers plate formes telephoniques) le mois suivant le"
	" rechargement."
	" Appels et sms directs entre personnes physiques et pour un usage"
	" non lucratif direct...";

conditions_text(OPT, 9) ->
    "...Appels en visiophonie entre terminaux et sur reseaux compatibles"
	" et SMS illimites pendant un an fin de mois a compter de"
	" l'inscription.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

desinscrire_confirm_text(OPT) ->
    "Vous n'etes plus inscrit a l'"
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Orange vous remercie de votre appel.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

failure_desinscr_text(OPT) ->
    "Suite a un probleme technique, nous ne pouvons vous desinscrire"
	" du programme "
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Veuillez reessayer plus tard. Desole et merci de votre appel.".
