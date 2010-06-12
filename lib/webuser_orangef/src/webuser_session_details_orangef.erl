
-module(webuser_session_details_orangef).

-export([show/2, detail_ask/2]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%% HTTP handlers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% gives the detail of one session
%% +type show(http_env(), string()) -> html().
show(Env, Input) ->
    case webuser_util:get_args(["uid","time","language",
                                "modifytag","msisdn","subscription"],Input) of
	missing_arg ->
	    webuser_orangef:send_code(argument_error);
	[Uid,Time,Lang,ModifyTag,Msisdn,Subscription] ->
            Uid_as_int = list_to_integer(Uid),
            {value, {_, User}} = lists:keysearch(remote_user, 1, Env),
            ok = webuser_logs_orangef:write_event
                   (User, Uid_as_int, {consult_session, Time}),
	    case webuser_generic:session(Uid,Time,Lang) of
		{error,Code} -> webuser_orangef:send_code(Code);
		{Rows,Time,Lang,Choice} ->
		    %% show first page when just enter the session page
		    Body = webuser_session_orangef:session2
			     (Rows,Time,Lang,Choice,Uid,ModifyTag,
			      Msisdn,Subscription,"1"),
                    Headers =
                        webuser_orangef:session_header(ModifyTag),
		    webuser_orangef:html(Headers ++ Body)
	    end
    end.



%%% gives the details of each page of one session
%% +type detail_ask(http_env(), string()) -> html().
detail_ask(Env, Input) ->
    Fields =
	["a","b","c","d","e","f","g","h","i","j",
	 "modifytag","msisdn","subscription","page"],
    case webuser_util:get_args(Fields,Input) of
	missing_arg ->
	    webuser_orangef:send_code(argument_error);
	[Action,Dur,Price,Time,Lang,Code,
	 Bearer,List_Choice,Choice,Uid,ModifyTag,Msisdn,
	 Subscription,Page] ->
	    Action2 = httpd_util:decode_base64(Action),
	    List2 = separate_enum(List_Choice,[],[]),
	    List3 = lists:map(fun (Value) ->
				      list_to_integer(Value) end,
			      List2),
	    Choice2  = case Choice of
			   [] -> -1;
			   _ -> list_to_integer(Choice)
		       end,
	    List4 = case List3 of
			[] -> [Choice2];
			_ -> case lists:member(Choice2,List3) of
				 true ->lists:delete(Choice2,List3);
				 _ -> [Choice2|List3]
			     end
		    end,
	    Body = webuser_session_orangef:session2(
		     [Action2,Dur,Bearer,Price],Time,Lang,List4,Uid,
		     [ModifyTag],Msisdn,Subscription,Page),
            Header = webuser_orangef:session_header(ModifyTag),
	    webuser_orangef:html([Header, Body])
    end.


%%%% separates arguments with the separator ~ and create a list
%% +type separate_enum(string(),[string()], [string()]) -> [string()].
separate_enum([],Acc_T,Res) -> Res;
separate_enum([$~|Rest],Acc_T,Res) -> separate_enum_end(Rest,[],Res);
separate_enum([X|Rest],Acc_T,Res) -> separate_enum(Rest,[],Res).

%%%%
%% +type separate_enum_end(string(),string(),[string()]) -> [string()].
separate_enum_end([],Acc_T,Res) -> lists:reverse([lists:reverse(Acc_T)|Res]);
separate_enum_end([$~|Rest],Acc_T,Res) -> 
    separate_enum_end(Rest,[],[lists:reverse(Acc_T)|Res]);
separate_enum_end([X|Rest],Acc_T,Res) -> separate_enum_end(Rest,[X|Acc_T],Res).
