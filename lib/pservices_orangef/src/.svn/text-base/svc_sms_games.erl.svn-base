-module(svc_sms_games).

-export([send_mes/3,send_mes/4,pre_send/4]).
-export([init/2,verif_credit/2]).
-export([post_send/3]).

-include("../../pserver/include/pserver.hrl").

%% +deftype sms_games() =
%%     #sms_games{     word_begin     :: string(),
%%                     target         :: string(),
%%                     tax            :: bool()}.
-record(sms_games,{word_begin,target,tax=false}).

%% +type verif_credit(session(),Url::string())-> erlpage_result().
verif_credit(abs,Url)->
    [{redirect,abs,"#balance_too_low"},
     {redirect,abs,"#not_prepaid"},
     {redirect,abs,Url}];
verif_credit(#session{prof=Profile}=Session,Url) 
  when Profile#profile.subscription=="postpaid"->
    {redirect,Session,"#not_prepaid"};
verif_credit(Session,Url)->
    P = pbutil:get_env(pservices_orangef, prix_sms),
    Price=currency:to_euro(currency:sum(P)),
    case billing:acte(Session, Price) of
	{ok, BilledSession, Timeout} ->
	    %% don't return billedSession we just verify if we can taxe
	    {redirect,update_record(Session,[{tax,true}]), Url};
	{stop, BilledSession, Reason} ->
	    {redirect, Session, "#balance_too_low"}
    end.

%%%% inits svc_data
%% +type init(session(),string()) -> erlpage_result().
init(abs,Url) ->
    [{redirect,abs,Url}];
init(Session,Url) ->
    {redirect,update_record(Session,#sms_games{}), Url}.

%%%% defines redirect url for success or failed sms
%% +type send_mes(session(), Text::string(),Target::string())-> erlpage_result().
send_mes(abs, _, _) -> 
    send_mes(abs,abs,abs,"#conf_ok_10","#confirm_nok");
send_mes(Session, Text, Target) ->
    send_mes(Session,Text,Target,"#conf_ok_10","#confirm_nok").

%%%% defines redirect url for success or sms
%% +type send_mes(session(), Text::string(),Target::string(),Ok::string())->
%%                                                       erlpage_result().
send_mes(abs, _, _,Ok) -> send_mes(abs,abs,abs,Ok,"#confirm_nok");
send_mes(Session, Text, Target,Ok) -> 
    send_mes(Session,Text,Target,Ok,"#confirm_nok").

%%%% defines redirect url for success or failed sms
%% +type send_mes(session(), Text::string(),Target::string(),
%%          Ok :: string(), Nok :: string())-> erlpage_result().
send_mes(abs, _, _,Ok,Nok) -> 
    send_sms_redirect(abs,abs,abs,Ok,Nok);
send_mes(Session, Text, Target, Ok, Nok) ->
    slog:event(count,?MODULE,{Text,Target}),
    send_sms_redirect(Session,Text,Target, Ok, Nok).


%%%% Send sms to private server and redirect function result
%% +type send_sms_redirect(session(), Text:: string(), Target::string(),
%%                           Ok::string(), Nok::string()) -> erlpage_result().
send_sms_redirect(abs,_,_,Ok,Nok) -> [{redirect,abs,Ok}] ++ 
					 [{redirect,abs,Nok}]; 
send_sms_redirect(Session, Text, Target, Ok, Nok)->
    case get_value(Session,tax) of
	false->
	    case svc_util:send_sms_priv(Session, Text, Target) of
		true -> {redirect, Session, Ok};
		false -> {redirect, Session, Nok}
	    end;
	_->
	    P = pbutil:get_env(pservices_orangef, prix_sms),
	    Price=currency:to_euro(currency:sum(P)),
	    case billing:acte(Session, Price) of
		{ok, BilledSession, Timeout} ->
		    case svc_util:send_sms_priv(BilledSession, Text, Target) of
			true -> 
			    {redirect, BilledSession, Ok};
			false -> 
			    {redirect, Session, Nok}
		    end;
		{stop, BilledSession, Reason} ->
		    {redirect, Session, "#balance_too_low"}
	    end
    end.

%%%% Store text and redirect for new entry
%% +type pre_send(session(), Text:: string(), Target::string(),Url::string())
%%                  -> erlpage_result().
pre_send(abs,_,_,Url) -> [{redirect,abs,Url}];
pre_send(Session, Text, Target, Url) ->
    io:format("Got ~p~n, expected ~p~n",[get_record(Session),#sms_games{}]),
    Session1 =  update_record(Session,[{word_begin,Text},{target,Target}]),
    {redirect, Session1, Url}.


%%%% concatenates old date with new text and send sms
%% +type post_send(session(), Ok::string(),Text::string()) -> erlpage_result().
post_send(abs,Ok,_)-> send_sms_redirect(abs,"", "", Ok, "#confirm_nok");
post_send(Session, Ok, Text) ->
    SMSG = get_record(Session),
    Begin = SMSG#sms_games.word_begin,
    Target = SMSG#sms_games.target,
    slog:event(count,?MODULE,{Begin,Target}),   
    Text2 = Begin ++ " " ++ Text,
    send_sms_redirect(Session, Text2, Target, Ok, "#confirm_nok").


%% Fonction use to get, or update SMS_GAMES record
%% don't use another fonction

%% +type get_record(session())-> sms_games() | not_found.
get_record(Session)->
    case lists:keysearch(sms_games,1,Session#session.svc_data) of
	{value,{sms_games,Value}}->
	    Value;
	_->
	    not_found
    end.

%% +type get_value(session(),Field::atom())-> term().
get_value(Session,Field) when record(Session,session)->
    get_value(get_record(Session),Field);
get_value(Record,Field) when record(Record,sms_games)->
    Fields=record_info(fields,sms_games),
    Pairs=oma_util:record_to_pairs(Fields, Record),
    case lists:keysearch(Field,1,Pairs) of
	{value,{Field,Value}}->
	    Value;
	_->
     	    no_field_found
    end.

%% +deftype pair()={atom(),term()}.
%% +deftype sms_games_or_pairs() = sms_games() | [pair()].

%% +type update_record(session(),sms_games_or_pairs())-> session().
update_record(Session,SMSGAMES) when record(SMSGAMES,sms_games)->
    AssocList=svc_util_of:init_svc_data(Session),
    AssocList2=
	case lists:keymember(sms_games, 1, AssocList) of
	    true->
		lists:keyreplace(sms_games, 1, AssocList, {sms_games,SMSGAMES});
	    false->
		AssocList++[{sms_games,SMSGAMES}]
	end,
    Session#session{svc_data=AssocList2};
update_record(Session,Pairs)->
    SMSGAMES=get_record(Session),
    update_record(Session,update_field(SMSGAMES,Pairs)).


%% +type update_field(sms_games(),[pair()])-> sms_games().
update_field(Record,Pairs)->
    Fields=record_info(fields,sms_games),
    oma_util:pairs_to_record(Record, Fields, Pairs).




