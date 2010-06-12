-module(text_opt_surf_mensu).
-compile(export_all).

-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_supprimer_generique_text(abs, _) ->
    [{pcdata, ""}];

surf_mensu_supprimer_generique_text(Session, Opt) ->
    [{pcdata, supprimer_generique_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_suppr_confirmer_text(abs, _, _) ->
    [{pcdata, ""}];

surf_mensu_suppr_confirmer_text(Session, Opt, UNT_REST) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, suppr_confirmer_text(list_to_atom(Opt),
				   State,
				   UNT_REST)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_conditions_text(abs, _, _) ->
    [{pcdata, ""}];

surf_mensu_conditions_text(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt),
			      ?mobi,
			      list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_conditions_m6_text(abs, _, _) ->
    [{pcdata, ""}];

surf_mensu_conditions_m6_text(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt),
			      ?m6_prepaid,
			      list_to_integer(Range))}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_conditions_foot_text(abs, _, _) ->
    [{pcdata, ""}];

surf_mensu_conditions_foot_text(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt),
			      foot,
			      list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_conditions_click_text(abs, _, _) ->
    [{pcdata, ""}];

surf_mensu_conditions_click_text(Session, Opt, Range) ->
    [{pcdata, conditions_text(list_to_atom(Opt),
			      click,
			      list_to_integer(Range))}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_supprimer_cond_text(abs, _) ->
    [{pcdata, ""}];

surf_mensu_supprimer_cond_text(Session, Opt) ->
    [{pcdata, supprimer_cond_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_suppr_ok_text(abs, _) ->
    [{pcdata, ""}];

surf_mensu_suppr_ok_text(Session, Opt) ->
    [{pcdata, suppr_ok_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_restit_surf_mensu_ac_princ_ac_text(abs, _) ->
    [{pcdata, ""}];

surf_mensu_restit_surf_mensu_ac_princ_ac_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_surf_mensu_ac_princ_ac_text(list_to_atom(Opt),
						 State)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_restit_surf_mensu_ac_princ_ep_text(abs, _) ->
    [{pcdata, ""}];

surf_mensu_restit_surf_mensu_ac_princ_ep_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_surf_mensu_ac_princ_ep_text(list_to_atom(Opt),
						 State)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

surf_mensu_restit_surf_mensu_ep_text(abs, _) ->
    [{pcdata, ""}];

surf_mensu_restit_surf_mensu_ep_text(Session, Opt) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_surf_mensu_ep_text(list_to_atom(Opt),
					State)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

supprimer_generique_text(OPT) ->
    "Votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" est actuellement activee.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suppr_confirmer_text(OPT, State, UNT_REST) ->
    "Merci de confirmer la suppression de votre option surf mensuelle.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conditions_text(OPT, ?m6_prepaid, 1) ->
    "Offre valable en France metropolitaine du "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++
	" au "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et reservee aux clients M6 mobile."
	" Acces et connexions illimitees aux services du Portail...";

conditions_text(OPT, foot, 1) ->
    "Offre valable en France metropolitaine et reservee aux clients "
	" ayant souscrit a l'offre entre le "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++
	" et le "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" Acces et connexions illimitees...";

conditions_text(OPT, click, 1) ->
    "Offre valable en France metropolitaine du "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++
	" au "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et reservee aux clients mobicarte et click la mobicarte.";

conditions_text(OPT, _, 1) ->
    "Offre valable en France metropolitaine du "
	++svc_util_of:get_commercial_start_date(OPT, mobi,"dmy")++
	" au "
	++svc_util_of:get_commercial_end_date(OPT, mobi,"dmy")++
	" inclus et reservee aux clients mobicarte et click la mobicarte."
	" Acces et connexions illimitees...";

conditions_text(OPT, foot, 2) ->
    "...aux services du Portail Orange World (hors Gallery, Internet, streaming audio, TV"
	" et video, et hors contenus payants) pendant un mois consecutifs"
	" a compter de...";

conditions_text(OPT, click_, 2) ->
    " Acces et connexions illimitees aux services du Portail Orange World (hors Gallery, Internet, streaming audio, TV"
	" et video, et hors contenus payants) pendant 1 mois";

conditions_text(OPT, _, 2) ->
    "...aux services du Portail Orange World (hors Gallery, Internet, streaming audio, TV"
	" et video, et hors contenus payants) pendant un mois consecutifs"
	" a compter de...";

conditions_text(OPT, ?m6_prepaid, 3) ->
    "...l'option."
	" Services accessibles sur reseaux et depuis un terminal compatible."
	" Les "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sont preleves chaque mois sur le compte principal du client sous...";

conditions_text(OPT, foot, 3) ->
    "...la date d'activation de l'option."
	" Services accessibles sur reseaux et depuis un terminal compatible."
	" Les "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sont preleves chaque mois sur le compte mobicarte du ...";

conditions_text(OPT, click, 3) ->
    "consecutif a compter de la date d'activation de l'option."
	" Services accessibles sur reseaux et depuis un terminal compatible."
	" Les "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sont preleves chaque mois sur le";

conditions_text(OPT, _, 3) ->
    "...la date d'activation de l'option."
	" Services accessibles sur reseaux et depuis un terminal compatible."
	" Les "
	++svc_util_of:get_option_price(OPT, mobi)++
	" sont preleves chaque mois sur le compte du...";

conditions_text(OPT, foot, 4) ->
    "... client sous reserve de disposer d'un credit suffisant."
	" En cas de credit insuffisant, l'option sera suspendue et"
	" reprendra automatiquement a la date...";

conditions_text(OPT, click, 4) ->
    "compte du client sous reserve de disposer d'un credit suffisant."
	" En cas de credit insuffisant, l'option sera suspendue et"
	" reprendra automatiquement a la date anniversaire si le...";

conditions_text(OPT, _, 4) ->
    "...client sous reserve de disposer d'un credit suffisant."
	" En cas de credit insuffisant, l'option sera suspendue et"
	" reprendra automatiquement a la date...";

conditions_text(OPT, foot, 5) ->
    "...anniversaire si le credit est a nouveau suffisant."
	" Souscription de l'option au 444 et resiliation a tout moment"
	" au 220 ou #123# (appels gratuits)...";

conditions_text(OPT, click, 5) ->
    "...anniversaire si le credit est a nouveau suffisant."
	" Souscription de l'option au 444 et resiliation a tout moment"
	" au 220 ou #123# (appels gratuits)...";

conditions_text(OPT, _, 5) ->
    "...anniversaire si le credit est a nouveau suffisant."
	" Souscription de l'option au 444 et resiliation a tout moment"
	" au 220 ou #123# (appels gratuits)...";

conditions_text(OPT, _, 6) ->
    "...Voir details de l'option, Conditions Specifiques et liste des"
	" mobiles compatibles sur www.orange.fr.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

supprimer_cond_text(OPT) ->
    "Merci de confirmer la suppresion de votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

suppr_ok_text(OPT) ->
    "La suppression de votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" a bien ete prise en compte."
	"  Merci de votre appel.".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_surf_mensu_ac_princ_ac_text(OPT, State) ->
    "Vous avez jusqu'au "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++
	" inclus pour profiter de votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++ "."
	" Vous disposerez a nouveau de cette option le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_surf_mensu_ac_princ_ep_text(OPT, State) ->
    "Vous avez jusqu'au "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++
	" inclus pour profiter de l'option surf."
	" Vous en beneficierez de nouveau si le credit de votre compte"
	" principal est superieur a "
	++svc_util_of:get_option_price(OPT, mobi)++
	" le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++ ".".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_surf_mensu_ep_text(OPT, State) ->
    "Votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" est actuellement suspendue."
	" Vous en beneficierez de nouveau si le credit de votre compte"
	" principal est superieur a "
	++svc_util_of:get_option_price(OPT, mobi)++
	" le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++ ".".
