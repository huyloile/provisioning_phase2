-module(pfront_orangef_sup).
-behaviour(supervisor).

-export([start_link/1, init/1]).

-include("../../pfront/include/pfront.hrl").
-include("../include/ocf_rdp.hrl").

%% +type start_link(Arg) -> sup_start_result().

start_link(Arg) ->
    rsupervisor:start_link({local,pfront_orangef_sup}, ?MODULE, Arg).

%% +type init(Args) -> sup_init_result().

init(Args) ->
    %% Allow up to 10 restarts in 5s.
    %% Note 1: This must be scaled with the number of interfaces.
    %% Note 2: Whenever the max restart frequency is reached, the
    %%         supervisor will freeze for 5s. Therefore the value must
    %%         not be chosen too high.
    Children = batch_ocf_supervisor(),
    ChildSpec = {{one_for_one, 10, 5}, Children},
    {ok, ChildSpec}.

%% +type batch_ocf_supervisor()
%%   -> [{atom(), mfa(), atom(), integer(), atom(), atom()}].

batch_ocf_supervisor() ->
    BOC = batch_ocfrdp:get_batch_ocf_config(),
    case lists:member(node(), BOC#batch_ocf_config.nodes) of
	false ->
	    [];
	true ->
	    [{updates_supervisor,
	      {batch_ocfrdp, start_link_updates_supervisor, []},
	      permanent, 100, worker, dynamic}]
    end.

%% +private.

%% +usedeftype([child_spec/0, sup_shutdown/0, mfa/0]).
%% +usedeftype([sup_start_result/0, sup_init_result/0]).
