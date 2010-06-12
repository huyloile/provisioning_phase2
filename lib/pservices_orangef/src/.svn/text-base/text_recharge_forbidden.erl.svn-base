-module(text_recharge_forbidden).
-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recharge_interdit(abs, Range) ->
    [{pcdata, ""}];

recharge_interdit(Session, Range) ->
    [{pcdata, recharge_interdit_text(list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recharge_interdit_click(abs, Range) ->
    [{pcdata, ""}];

recharge_interdit_click(Session, Range) ->
    [{pcdata, recharge_interdit_click_text(list_to_integer(Range))}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recharge_interdit_m6(abs, Range) ->
    [{pcdata, ""}];

recharge_interdit_m6(Session, Range) ->
    [{pcdata, recharge_interdit_m6_text(list_to_integer(Range))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recharge_interdit_text(1) ->
    "Vous ne pouvez recharger votre mobicarte car nous ne pouvons"
	" vous identifier."
	" Vous devez nous renvoyer le coupon fourni avec"
	" votre mobicarte...";

recharge_interdit_text(2) ->
    "accompagne d'une copie de votre piece d'identite. Votre ligne sera"
	" retablie quelques jours apres l'enregistrement"
	" de vos coordonnees...";

recharge_interdit_text(3) ->
    "Sans retour de votre part, votre ligne mobicarte sera suspendue"
    " un mois apres l'activation de la ligne."
	" Vous ne pourrez plus passer d'appels...";

recharge_interdit_text(4) ->
    "et votre ligne sera resiliee deux mois apres son activation."
	" Pour toute question, votre service clients mobile Orange est a"
	" votre disposition au ...";

recharge_interdit_text(5) ->
   "722 depuis votre mobile (0,37E/min) ou au 3972 depuis un fixe"
	" (0,34E/min).".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recharge_interdit_m6_text(1) ->
    "Vous ne pouvez recharger votre compte car nous ne pouvons"
	" vous identifier."
	" Vous devez nous renvoyer le coupon fourni avec"
	" votre carte SIM Orange...";

recharge_interdit_m6_text(2) ->
    "accompagne d'une copie de votre piece d'identite."
	" Votre ligne sera retablie quelques jours apres"
	" l'enregistrement de vos coordonnees...";

recharge_interdit_m6_text(3) ->
    "Sans retour de votre part sous 8 jours a compter de l'activation"
	" de la ligne, celle-ci sera suspendue."
	" Vous ne pourrez plus passer d'appels et votre ligne...";

recharge_interdit_m6_text(4) ->
    "sera resiliee sous 30 jours a compter de l'expiration"
	" du delai d'identification de 8 jours."
	" Pour toute question, votre service clients mobile Orange...";

recharge_interdit_m6_text(5) ->
    "est a votre disposition au 722 depuis votre mobile"
	" (0,37E/min) ou au 3972 depuis un fixe (0,34E/min).".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recharge_interdit_click_text(1) ->
    "Vous ne pouvez recharger votre mobicarte car nous ne pouvons vous"
	" identifier. Vous devez vous rendre dans un point de vente"
	" mobicarte accompagne de votre";
recharge_interdit_click_text(2) ->
    "piece d'identite ou contacter votre service clients."
	"Votre ligne sera retablie quelques jours apres"
	" l'enregistrement de vos coordonnees...";
recharge_interdit_click_text(3) ->
    "Sans action de votre part, votre ligne mobicarte"
	" sera suspendue un mois apres l'activation de la ligne."
	" Vous ne pourrez plus passer d'appels...";
recharge_interdit_click_text(4) ->
    "et votre ligne sera resiliee deux mois apres son activation."
	" Pour toute question, votre service clients mobile Orange "
	"est a votre disposition au ...";
recharge_interdit_click_text(5) ->
    "722 depuis votre mobile (0,37E/min)"
	" ou au 3972 depuis un fixe (0,34E/min).".
