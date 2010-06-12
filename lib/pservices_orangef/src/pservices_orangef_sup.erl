-module(pservices_orangef_sup).
-behaviour(supervisor).

-export([start_link/1, init/1]).

start_link(Arg) ->
    rsupervisor:start_link({local,pservices_orangef_sup}, ?MODULE, Arg).

%%%% Callbacks for behaviour "supervisor".

init(Args) ->
    table_ratio_mnesia:init_table(),
    option_manager:init(),
    batch_reset_imei:init(),
    AddPrismeDump = error_logger:add_report_handler(prisme_dump),
    io:format("error_logger:add_report_handler(prisme_dump) -> ~p~n",
	      [AddPrismeDump]),
    ChildSpec = {{one_for_one, 1, 60}, []},
    {ok, ChildSpec}.
