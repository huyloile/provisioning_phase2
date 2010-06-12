%%% Module dealing with OF's selfcare roaming

-module(svc_roaming).

-export([init_roaming/2]).
-export([redir_roaming_network/2]).
-export([include_suivi_conso/1]).
-export([inc_roaming_offer/2]).
-export([get_vlr/1]).
-export([is_prefix_vlr/2]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/plugin.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Check if user is in roaming, by matching with local VLR lists
%%% Add {roaming_network,T} item in session.location and 
%%% redirect to appropriate page
%% +type init_roaming(session(),string()) -> erlpage_result().
init_roaming(abs,NextPage) ->
    [{"NextPage",{redirect,abs,NextPage}}];

init_roaming(#session{location=Loc} = Session,NextPage) ->
    LocInfo =
	case get_vlr(Session) of
	    
	    %% If we're not in roaming, branch out here
	    {ok,"33" ++ _} ->
		{roaming_network,noroaming};
	    {ok,VLRNumber} ->	    
		%% Check vlr prefixes direct callback,
		case is_prefix_vlr(VLRNumber,vlr_prefixes_direct_callback) of
		    true->
			{roaming_network,ming};
		    false->
			%% Check camel roaming network for this vlr_number,			
			case is_prefix_vlr(VLRNumber,roaming_camel_codes) of 
			    true -> 
				{roaming_network,camel};
			    false ->
				%% Check ansi roaming network for this vlr_number,
				case is_prefix_vlr(VLRNumber,roaming_ansi_codes) of
				    true -> 
					{roaming_network,ansi};
				    false ->
					{roaming_network,nocamel}
				end
			end
		end;
	    %% No vlr number, branch out too.
	    _ ->
		{roaming_network,noroaming}
	end,
    %% If no vlr was found in pssr, then location = none.
    Loc1 = if list(Loc) -> [LocInfo | Loc];
	      true -> [LocInfo]
	   end,
    slog:event(trace,?MODULE,init_roaming,LocInfo),
    {redirect,Session#session{location=Loc1},NextPage}.


%%% Redirect by roaming network type (camel, ansi, nocamel, ming, noroaming)
%%% (init_roaming/2 must have been called before)
%% +type redir_roaming_network(session(),Links::string()) -> erlpage_result().
redir_roaming_network(abs,Links) ->
    svc_util:redirect_multi(abs, abs, Links);
    
redir_roaming_network(#session{location=L}=Session,Links) ->
    case catch lists:keysearch(roaming_network, 1, L) of
	{value, {_,Smth}} ->
	    svc_util:redirect_multi(Session, atom_to_list(Smth), Links);
	_ ->
	    svc_util:redirect_multi(Session, "noroaming", Links)
    end.

%%% We want to include an erlang function that returns a redirect.
%%% Sneaky function to include this result.
%% +type include_suivi_conso(session()) -> erlinclude_result().
include_suivi_conso(abs) ->
    [{pcdata,"Suivi-conso 130 caractères"}];

include_suivi_conso(#session{prof=#profile{subscription=Subs}}=Session) ->
    case svc_spider:get_availability(Session) of
	available ->
	    include_spider_svc130();
	_ ->
	    include_sachem_svc130(Session)
    end.

include_sachem_svc130(#session{prof=#profile{subscription=Subs}}=Session) -> 
    {Mod,Fun,XML} = case Subs of
	      "mobi" -> {svc_selfcare,select_home_niv2,"selfcare.xml"};
	      "cmo" -> {svc_selfcare_cmo,select_home,"selfcare_cmo.xml"}
	  end,
    {redirect,_,Page} = Mod:Fun(Session),
    [{include,{relurl,"file:/orangef/selfcare_light/" ++ XML ++ Page}}].
    
include_spider_svc130() ->
    [{include,{relurl,"file:/orangef/selfcare_light/spider.xml#prepaid"}}].

%% +type get_vlr(session()) -> {ok,string()} | nok.
get_vlr(#session{location=L}=Session) when list(L)-> 
    case lists:keysearch(vlr_number, 1, L) of
	{value, {_,[]}} -> nok;
	{value, {_,V}} -> {ok,V};
	false          -> nok
    end;
get_vlr(_) ->
    nok.

%%%% Used in recharge.xml to add a special offer link
%% +type inc_roaming_offer(session(),string()) -> erlinclude_result().
inc_roaming_offer(abs,Url) ->
    Link = "file:/orangef/selfcare_long/roaming_cmo.xml#include_offer_link",
    [br,{pcdata,"("},
     #hlink{href     = Url,contents = [{include,{relurl,Link}}]},
     {pcdata,")?"}
    ];

inc_roaming_offer(#session{location=L,prof=P}=Session,Url)
  when list(L) ->
    Data = svc_util_of:get_user_state(Session),
    Subs = P#profile.subscription,
    Is_Camel = lists:keysearch(is_camel, 1, L),
    case {Subs,Is_Camel} of
	{"cmo",{value, {_,true}}} ->
		Link = "file:/orangef/selfcare_long/roaming_cmo.xml"
		    "#include_offer_link",
		Contents = [{include,{relurl,Link}}],
		[#hlink{href = Url,contents = Contents}];
	_ -> []
    end;

inc_roaming_offer(_,_) ->   
     [].


%%%%%%%%%%%%%%%%%%%%%%%%%%%% VLR NUMBERS LIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Check if the beginning of vlr_number belongs to a list
%% +type is_prefix_vlr(string(),atom()) -> bool().

%%% Hard coded value for Orange France : avoids a whole check list
is_prefix_vlr("33" ++ _,_) ->
    noroaming;

is_prefix_vlr(VLRNumber,Param) ->
    Keys  = pbutil:get_env(pservices_orangef,Param),
    match_key(VLRNumber,Keys).



%% +type match_key(string(),[integer()]) -> bool().
match_key(VLRNumber,[CCNDC | Keys]) ->
    lists:prefix(CCNDC,VLRNumber) orelse match_key(VLRNumber, Keys);

match_key(_,[]) ->
    false.
    
