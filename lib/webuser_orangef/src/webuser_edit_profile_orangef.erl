-module(webuser_edit_profile_orangef).

-include("../../pserver/include/pserver.hrl").
-include("../../oma_webmin/include/webmin.hrl").
-include("../../webuser/include/webuser.hrl").

-define(PROFILE_FIELDS,record_info(fields,profile)).

-export([edit_webuser/4]).

%%%% DOCUMENTATION
-export([slog_info/3]).
-include("../../oma/include/slog.hrl").

%%% This module implements tab edition for the profile() record
%%% This is the default webuser panel


%% +type edit_webuser(profile(),string(),fields_config(),wu_cb()) ->
%%                    {ok,html()}.
edit_webuser(P,_,FieldsConf,CB) ->
    Pairs = oma_util:record_to_pairs(?PROFILE_FIELDS,P),
    {ok,[edit_webuser_tab(P,FieldsConf,Pairs,CB)]}.


%% +type edit_webuser_tab(profile(),fields_config(),[tuple()],wu_cb())->html().
edit_webuser_tab(P,[{Name,Descr,Type} | FieldsConf],Pairs,CB) ->
    %% Look for current field. Bad config if it does not exist
    Value =
	case lists:keysearch(Name,1,Pairs) of
	    {value,{_,V}} -> V;
	    _ -> exit({could_not_find,Name,in,Pairs})
	end,

    CB_Field =
	fun(HTTP_Env, Vars, {nok,Msg}) ->
		CB(Msg);
	   (HTTP_Env, Vars, {ok,NewValue}) ->
		NewPairs = lists:keyreplace(Name,1,Pairs,{Name,NewValue}),
		NewRecord = oma_util:update_record(?PROFILE_FIELDS,P,NewPairs),
		NewRecord2 = no_null(NewRecord),
		case catch db:update_profile(NewRecord2,P) of
		    ok ->
                        {value, {_, User}} =
                            lists:keysearch(remote_user, 1, HTTP_Env),
                        Data = {update_profile, atom_to_list(Name)},
                        ok = webuser_logs_orangef:write_event
                               (User, NewRecord2#profile.uid, Data),
                        CB(update_ok);
		    Error ->
			slog:event(internal,?MODULE,could_not_update_profile,
				   Error),
			CB(update_not_done)
		end
	end,

    %% Edit next row
    [webuser_editor_orangef:edit_row(Descr,Value,Type,CB_Field) |
     edit_webuser_tab(P,FieldsConf,Pairs,CB)];

edit_webuser_tab(P,[],_,_) ->
    [].


%%% Reformat some profile fields if null
%% +type no_null(profile()) -> profile().
no_null(#profile{lang     = Lang,
		 msisdn   = MSISDN,
		 imsi     = IMSI,
		 subscription = Subscription}=Profile) ->
    Profile#profile{lang         = no_null_field(Lang),
		    msisdn       = no_null_field(MSISDN),
		    imsi         = no_null_field(IMSI),
		    subscription = no_null_field(Subscription)}.

%% +type no_null_field(string()) -> string() | {na,null_in_db}.
no_null_field("NULL") ->
    {na,null_in_db};
no_null_field(Else) ->
    Else.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DOCUMENTATION
%% +type slog_info(Class::atom(),Module::atom(),SLog::term()) -> slog_info().
slog_info(internal,?MODULE,could_not_update_profile) ->
    #slog_info{descr="Customer profile could not be updated in database",
	       operational=?MYSQL_FAILURE}.

