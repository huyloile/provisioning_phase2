-module(rdp_options_router).

-export([event/2]).

-export([start_link/1]).
-export([pool_get_attrib/1]).

-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/include/rdp_options.hrl").


%% +type event(opt_event(),term())-> ok.
event(EVENT, Attrs) ->
    rdp_options_server:event(?MODULE, EVENT, Attrs).

%% +type start_link(term())-> ok.
start_link(Workers) ->
    Arg = {{?MODULE,pool_get_attrib}, Workers},
    pool_server:start_link({?MODULE, Workers, fun()-> true end}).

%% routing criteria
%% +type pool_get_attrib({event,opt_event(),term()})-> term().
pool_get_attrib({event, EVENT, Attrs}) ->
    Attrs.
