%%%% "Flash Nouveautés" service

-module(svc_flash).
-export([flash_msg/3]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").


flash_msg(abs, _, _) ->
    do_redirect(abs, abs, abs, abs)++
	[{failure, {redirect, abs, "file:/orangef/flash.xml#noaccess"}}];
flash_msg(Session, ServiceId, MaxMsgIndex) ->
    NumMaxMsgIndex= case pbutil:all_digits(MaxMsgIndex) of
			false ->
			    slog:event(failure,?MODULE,bad_param,MaxMsgIndex),
			    exit(msg_index_not_integer);
			true -> list_to_integer(MaxMsgIndex)
		    end,
    case db:lookup_svc_profile(Session, ServiceId) of
	{ok, Count} ->
	    do_redirect(Session, ServiceId, Count, NumMaxMsgIndex);
	not_found ->
	    %% user has no profile declared yet -> 
	    %% it will be created by update_svc_profile in do_redirect
	    do_redirect(Session, ServiceId, NumMaxMsgIndex, NumMaxMsgIndex);
	no_profile -> 
	    {redirect, Session, "file:/orangef/flash.xml#noaccess"};
	_ -> 
	    {redirect, Session, "file:/orangef/flash.xml#noaccess"}
    end.
    
    
do_redirect(abs, _, _, _) ->
    [{redirect, abs, "#1"},
     {failure, {redirect, abs, "file:/orangef/flash.xml#temporary"}}];
do_redirect(Session, ServiceId, Count, MaxMsgIndex) ->
    NextCount = if 
		    Count >= MaxMsgIndex -> 1;
		    true -> Count+1
		end,
    case db:update_svc_profile(Session, ServiceId, NextCount) of
	ok ->
	    {redirect, Session, "#"++integer_to_list(NextCount)};
	_ ->
	    {redirect, Session, "file:/orangef/flash.xml#temporary"}
    end.
