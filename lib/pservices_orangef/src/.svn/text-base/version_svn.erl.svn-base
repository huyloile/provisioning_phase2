-module(version_svn).

-export([value/0,
	 check_version/0]).

-include("../include/version.hrl").


value()->
    ?VERSION.

check_version()->
    LIST = {lists:duplicate(length(oma:get_env(nodes)), ?VERSION),[]},
    CURRENT = rpc:multicall(oma:get_env(nodes),?MODULE,value,[]),
    case CURRENT of
	LIST ->
	    "The Number version is :"++?VERSION;
	_ ->
	    "The node are incoherent"
    end.
	    
	   

