-module(text_code101_opt_blocked).
-compile(export_all).

-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code101_opt_blocked(abs, Range) ->
    [{pcdata, ""}];

code101_opt_blocked(Session, Range) ->
    case svc_options_mobi:get_current_option(Session) of
	not_found ->
	    [{pcdata, ""}];
	OPT ->
	    [{pcdata, code_101_text(OPT, list_to_integer(Range))}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code101_opt_blocked_m6(abs, Range) ->
    [{pcdata, ""}];

code101_opt_blocked_m6(Session, Range) ->
    case svc_options_mobi:get_current_option(Session) of
	not_found ->
	    [{pcdata, ""}];
	OPT ->
	    [{pcdata, code_101_m6_text(OPT, list_to_integer(Range))}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code101_opt_blocked_foot(abs, Range) ->
    [{pcdata, ""}];

code101_opt_blocked_foot(Session, Range) ->
    case svc_options_mobi:get_current_option(Session) of
	not_found ->
	    [{pcdata, ""}];
	OPT ->
	    [{pcdata, code_101_foot_text(OPT, list_to_integer(Range))}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code101_opt_blocked_click(abs, Range) ->
    [{pcdata, ""}];

code101_opt_blocked_click(Session, Range) ->
    case svc_options_mobi:get_current_option(Session) of
	not_found ->
	    [{pcdata, ""}];
	OPT ->
	    [{pcdata, code_101_click_text(OPT, list_to_integer(Range))}]
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code_101_text(OPT, 1) ->
    "Vous ne pouvez souscrire a l'option "
	++svc_util_of:get_opt_name(OPT,mobi)++
	" car nous ne pouvons vous identifier."
	" Vous devez vous rendre dans votre point de vente";

code_101_text(OPT, 2) ->
    "accompagne de votre piece d'identite."
	" Votre ligne sera retablie quelques jours apres"
	" l'enregistrement de vos coordonnees...";

code_101_text(OPT, 3) ->
    "Sans action de votre part, votre ligne sera suspendue"
	" un mois apres l'activation de la ligne."
	" Vous ne pourrez plus passer d'appels...";

code_101_text(OPT, 4) ->
    "et votre ligne sera resiliee deux mois apres son activation."
	" Pour toute question, votre service clients mobile Orange"
	" est a votre disposition au ...";

code_101_text(OPT, 5) ->
    "722 depuis votre mobile (0,37E/min) ou au 3972 depuis un fixe.*"
	"(0,34E/min).*".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code_101_m6_text(OPT, 1) ->
    "Vous ne pouvez souscrire a l'option "
	++svc_util_of:get_opt_name(OPT,mobi)++
	" car nous ne pouvons vous identifier."
	" Vous devez nous renvoyer le coupon fourni avec votre carte SIM Orange...";

code_101_m6_text(OPT, 2) ->
    "accompagne d'une copie de votre piece d'identite."
	" Votre ligne sera retablie quelques jours apres"
	" l'enregistrement de vos coordonnees...";

code_101_m6_text(OPT, 3) ->
    "Sans retour de votre part sous 8 jours a compter de l'activation"
	" de la ligne, celle-ci sera suspendue."
	" Vous ne pourrez plus passer d'appels.";

code_101_m6_text(OPT, 4) ->
    "et votre ligne sera resiliee sous 30 jours a compter de l'expiration"
	" du delai d'identification de 8 jours.";

code_101_m6_text(OPT, 5) ->
    "Pour toute question, votre service clients mobile Orange est"
	" a votre disposition au  722 depuis votre mobile (0,37E/min)"
	" ou au 3972 depuis un fixe (0,34E/min).".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code_101_foot_text(OPT, 1) ->
    "Vous ne pouvez souscrire a l'option "
	++svc_util_of:get_opt_name(OPT,mobi)++
	" car nous ne pouvons vous identifier."
	" Vous devez nous renvoyer le coupon fourni avec votre carte SIM...";

code_101_foot_text(OPT, 2) ->
    "accompagne d'une copie de votre piece d'identite."
	" Votre ligne sera retablie quelques jours apres"
	" l'enregistrement de vos coordonnees...";

code_101_foot_text(OPT, 3) ->
    "Sans retour de votre part sous 8 jours a compter de l'activation"
	" de la ligne, celle-ci sera suspendue."
	" Vous ne pourrez plus passer d'appels.";

code_101_foot_text(OPT, 4) ->
    "et votre ligne sera resiliee sous 30 jours a compter de l'expiration"
	" du delai d'identification de 8 jours.";

code_101_foot_text(OPT, 5) ->
    "Pour toute question, votre service clients mobile Orange est"
	" a votre disposition au  722 depuis votre mobile (0,37E/min)"
	" ou au 3972 depuis un fixe (0,34E/min).".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
code_101_click_text(OPT, 1) ->
    "Vous ne pouvez souscrire a l'option "
	++svc_util_of:get_opt_name(OPT,mobi)++
	" car nous ne pouvons vous identifier."
	" Vous devez vous rendre dans un point de vente mobicarte accompagne de votre";
code_101_click_text(OPT, 2) ->
    "piece d'identite ou contacter votre service clients."
	"Votre ligne sera retablie quelques jours apres l'enregistrement de vos coordonnees...";
code_101_click_text(OPT, 3) ->
    "Sans action de votre part, votre ligne mobicarte sera suspendue un mois"
	" apres l'activation de la ligne. Vous ne pourrez plus passer d'appels...";
code_101_click_text(OPT, 4) ->
    "et votre ligne sera resiliee deux mois apres son activation."
	" Pour toute question, votre service clients mobile Orange est a votre disposition au ...";
code_101_click_text(OPT, 5) ->
    "722 depuis votre mobile (0,37E/min)"
	" ou au 3972 depuis un fixe (0,34E/min).".
