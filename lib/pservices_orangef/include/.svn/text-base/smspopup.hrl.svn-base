%%%% <h2> Popups </h2>
%% 
%%%% A script is a notification flag and a list of actions.
%% 
%% +deftype sp_script() = {notif|no_notif, [sp_action()]}.
%% 
%%%% Actions. The ISO8859 charset may be used for strings.
%% 
%% +deftype sp_action() =
%%     {call, msisdn()} 
%%   | mo_sm
%%   | {choice, Title::bstring(12),
%% 	use|no_use, [sp_choiceitem()]}
%%   | {mo_sm, msisdn(), byte(), sms_dcs()}
%%   | {input, Minlen::integer(), Maxlen::integer(),
%% 	 {digits|alphanum, visible|hidden,
%% 	   storage|no_storage, pause|no_pause, sharp|no_sharp},
%% 	  Prompt::bstring(16), Default::bstring(12)}
%%   | {display, string()}
%%   | getloc.
%% 
%%%% Choice items may specify a sequence of hex digits when the last
%%%% action is a <code>call</code>.
%% 
%% +deftype sp_choiceitem() = string() | {string(),hexstring()}.

-define(POPUP_PROMPT_MAX, 16).
-define(POPUP_DEFAULT_MAX, 12).
-define(POPUP_TITLE_MAX, 12).
-define(POPUP_ITEM_MAX, 12).

