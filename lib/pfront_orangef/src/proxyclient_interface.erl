-module(proxyclient_interface).
-export([start_link/1]).

-include("../../pfront/include/pfront.hrl").
-include("../include/proxyclient.hrl").

start_link(#interface{name_node={Name,Node}, extra=CFG}) ->
    CB = fun (up) -> case whereis(Name) of
			undefined -> register(Name, self());
			Pid when Pid==self() -> ok;
			_ -> exit({unable_to_register,Name})
		    end;
	     (down) ->
		 case whereis(Name) of
		     Pid when Pid==self() -> 
			 unregister(Name);
		     _ -> ok
		 end 
	end,
    CFG1 = CFG#proxyclient_config{callback=CB},
    proxyclient_server:start_link(CFG1).

