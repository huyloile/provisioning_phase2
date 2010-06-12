-module(text_nouveaute).
-compile(export_all).

-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nouveaute_sous_menu_text(abs, _) ->
    [{pcdata, ""}];

nouveaute_sous_menu_text(Session, Range) ->
    State = svc_util_of:get_user_state(Session),
    DCL_NUM=State#sdp_user_state.declinaison,
    [{pcdata, sous_menu_text(list_to_integer(Range), DCL_NUM)}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sous_menu_text(3,_) ->
    "Du lundi 19 au vendredi 23 janv 2009 de 8H a 19H, vos SMS vers mobiles et fixes sont a -50%";
sous_menu_text(31,_)->
    "SMS en France metropolitaine emis depuis un mobile, hors SMS surtaxes, et numeros courts.";
sous_menu_text(4,_) ->
    "Inscrivez-vous sur Zap zone pour rejoindre 500 000 ados : chats avec des stars, KDOs, Videos, blogs... + 30 SMS offerts";
sous_menu_text(5,_) ->
    "";
sous_menu_text(7,_) ->
    "Journee Kdo MMS : Le 1er avril de 8h a 21h tous vos MMS texte, photo, son et video vers tous mobiles et adresses email sont gratuits et illimites.";
sous_menu_text(71,_) ->
    "MMS entre 7 et 600 Ko emis depuis un mobile en France metropolitaine, hors MMS surtaxes, numeros courts et hors MMS carte postale.";
sous_menu_text(72,_) ->
    "Sous reserve d'un credit > a 0E pour les clients Compte mobile, M6 mobile by Orange, Zap et mobicarte.".
