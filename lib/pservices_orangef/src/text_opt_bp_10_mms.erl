-module(text_opt_bp_10_mms).
-compile(export_all).

-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_bp_10_mms_restit_ac_text(abs, _, _) ->
    [{pcdata, ""}];

opt_bp_10_mms_restit_ac_text(Session, Opt, UNT_REST) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata, restit_ac_text(list_to_atom(Opt),
			     State,
			     UNT_REST)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_bp_10_mms_restit_ep_text(abs, _) ->
    [{pcdata, ""}];

opt_bp_10_mms_restit_ep_text(Session, Opt) ->
    [{pcdata, restit_ep_text(list_to_atom(Opt))}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_ac_text(OPT, State, UNT_REST) ->
    "Il vous reste "
	++svc_util_of:get_credit(OPT, State, mobi, UNT_REST)++
	" MMS inclus dans votre option "
	++svc_util_of:get_opt_name(OPT, mobi)++
	" a utiliser avant le "
	++svc_util_of:get_end_credit(OPT, State, mobi, "dm")++
	" inclus."
	" MMS utilisables sur la base 1 MMS texte = 1 photo = 1 MMS video".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restit_ep_text(OPT) ->
    "Votre option 10 MMS est epuisee.". 
