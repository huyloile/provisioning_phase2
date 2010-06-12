-module(text_opt_mms_mensu).
-compile(export_all).

-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_supprimer_generique_ac_text(abs, _) ->
    [{pcdata, ""}];

mms_mensu_supprimer_generique_ac_text(Session, Opt) ->
    [{pcdata, supprimer_generique_ac_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_supprimer_generique_ep_text(abs, _) ->
    [{pcdata, ""}];

mms_mensu_supprimer_generique_ep_text(Session, Opt) ->
    [{pcdata, supprimer_generique_ep_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_suppr_confirmer_ac_text(abs, _, _) ->
    [{pcdata, ""}];

mms_mensu_suppr_confirmer_ac_text(Session, Opt, UNT_REST) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, suppr_confirmer_ac_text(list_to_atom(Opt),
				      State,
				      UNT_REST)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_suppr_confirmer_ep_text(abs, _) ->
    [{pcdata, ""}];

mms_mensu_suppr_confirmer_ep_text(Session, Opt) ->
    [{pcdata, suppr_confirmer_ep_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_suppr_conditions_text(abs, _, _) ->
    [{pcdata, ""}];

mms_mensu_suppr_conditions_text(Session, Opt, Range) ->
    [{pcdata, suppr_conditions_text(list_to_atom(Opt),?mobi,
				    list_to_integer(Range))}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_suppr_conditions_foot_text(abs, _, _) ->
    [{pcdata, ""}];

mms_mensu_suppr_conditions_foot_text(Session, Opt, Range) ->
    [{pcdata, suppr_conditions_text(list_to_atom(Opt),foot,
				    list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_suppr_conditions_click_text(abs, _, _) ->
    [{pcdata, ""}];

mms_mensu_suppr_conditions_click_text(Session, Opt, Range) ->
    [{pcdata, suppr_conditions_text(list_to_atom(Opt),click,
				    list_to_integer(Range))}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_suppr_ok_text(abs, _) ->
    [{pcdata, ""}];

mms_mensu_suppr_ok_text(Session, Opt) ->
    [{pcdata, suppr_ok_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_restit_mms_mensu_ac_princ_ac_text(abs, _, _) ->
    [{pcdata, ""}];

mms_mensu_restit_mms_mensu_ac_princ_ac_text(Session, Opt, UNT_REST) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_mms_mensu_ac_princ_ac_text(list_to_atom(Opt),
						State,
						UNT_REST)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_restit_mms_mensu_ac_princ_ep_text(abs, _, _) ->
    [{pcdata, ""}];

mms_mensu_restit_mms_mensu_ac_princ_ep_text(Session, Opt, UNT_REST) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_mms_mensu_ac_princ_ep_text(list_to_atom(Opt),
						State,
						UNT_REST)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mms_mensu_restit_mms_mensu_ep_text(abs, _) ->
    [{pcdata, ""}];

mms_mensu_restit_mms_mensu_ep_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_mms_mensu_ep_text(list_to_atom(Opt),
				       State)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_mms_mensu_ac_princ_ac_text(OPT, State, UNT_REST) ->
    "Vous avez jusqu'au "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++
	" inclus pour utiliser les "
	++svc_util_of:get_credit(OPT, State, mobi, UNT_REST)++
	" MMS de votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Vous disposerez a nouveau de 10 MMS le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_mms_mensu_ac_princ_ep_text(OPT, State, UNT_REST) ->
    "Vous avez jusqu'au "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++
	" inclus pour utiliser vos "
	++svc_util_of:get_credit(OPT, State, mobi, UNT_REST)++
	" MMS."
	" Vous beneficierez a nouveau de 10 MMS si le credit de votre"
	" compte principal est superieur a "
	++svc_util_of:get_option_price(OPT, mobi)++
	" le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_mms_mensu_ep_text(OPT, State) ->
    "Votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" est epuisee ou suspendue, vous disposerez a nouveau de 10 MMS le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++ 
	" si le credit de votre compte principal est superieur a "
	++svc_util_of:get_option_price(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

supprimer_generique_ac_text(OPT) ->
    "Votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" est actuellement activee."
	" Vous beneficiez de 10 MMS valables 1 mois pour "
	++svc_util_of:get_option_price(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

supprimer_generique_ep_text(OPT) ->
    "Votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" est activee et vous avez epuise les 10 MMS mensuels."
	" Chaque mois, vous beneficiez de 10 MMS pour "
	++svc_util_of:get_option_price(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suppr_confirmer_ac_text(OPT, State, UNT_REST) ->
    "... non consommes sont perdus. Il vous reste "
	++svc_util_of:get_credit(OPT, State, mobi, UNT_REST)++
	" MMS a utiliser jusqu'au "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++
	", perdu(s) si vous supprimez votre option maintenant.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suppr_confirmer_ep_text(OPT) ->
    "Merci de confirmer la suppresion de votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suppr_ok_text(OPT) ->
    "La suppression de votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" a bien ete prise en compte."
	"  Merci de votre appel.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suppr_conditions_text(OPT, click ,1) ->
    "Offre valable en France metropolitaine et reservee aux clients mobicarte "
	"et click la mobicarte. 10 MMS valables un mois...";

suppr_conditions_text(OPT,_ ,1) ->
    "Offre valable en France metropolitaine et reservee aux clients mobicarte "
	"et click la mobicarte. 10 MMS valables un mois...";

suppr_conditions_text(OPT,_ ,2) ->
    "... (hors MMS surtaxe) et MMS carte postale et non convertibles en SMS. "
 	"Service disponible depuis un terminal compatible. Les "
	++svc_util_of:get_option_price(OPT, mobi)++
 	" sont preleves chaque mois sur le...";

suppr_conditions_text(OPT, foot, 3) ->
       "...compte du client sous reserve de disposer d'un credit suffisant. "
  	"En cas de credit insuffisant, l'option sera suspendue et reprendra automatiquement...";

suppr_conditions_text(OPT, _,3) ->
    "...compte du client sous reserve de disposer d'un credit suffisant. "
	"En cas de credit insuffisant, l'option sera suspendue et reprendra automatiquement...";

suppr_conditions_text(OPT, _, 4) ->
    "... a la date anniversaire si le credit est a nouveau suffisant. "
	"Les MMS non utilises dans le mois ne sont pas reportes sur le mois suivant. "
	"Souscription de....";

suppr_conditions_text(OPT, _, 5) ->
    "... l'option au 444 et resiliation a tout moment au 220 ou #123# (appels gratuits). "
	"Le client est informe qu'a compter de la resiliation les MMS...".

