-module(webmin_orangef_app).

-export([param_info/1]).

-include("../../oma/include/oma.hrl").

param_info(editable_parameters) ->
    (#param_info
     {type = {list, type_app_params()},
      name = "Editable parameters",
      help = "This lists specifies which parameters OF is allowed to"
      " modify using their web interface",
      activation = auto,
      level = user
     });
param_info(stats_refresh_period_of) ->
    (#param_info
     {type = oma_types:timeout_s(),
      name = "Refresh period for HTML statistics",
      help = "Specifies period to refresh statistics page",
      example = [ ],
      activation = auto,
      level = internal
     });
param_info(stats_views_of) ->
    (#param_info
     {type = {list, type_stats_view()},
      name = "List of view for 'Counters and statistics'",
      help = "Each view is a list of counters\n"
      "This definition is made by a list of include and exclude counters",
      example = [{"stats",[{stats,'_','_'}],[]}],
      activation = auto,
      level = internal
      }).

type_app_params() ->
    {tuple, "", [{"Application", atom},
		 {"Parameters", {list, atom}}]}.

type_stats_view()->
    {tuple, "Stat View", [{"view Name",string},
			  {"Include Counters", counter_filter("Include")},
			  {"Exclude Counters", counter_filter("Exclude")}]}.

counter_filter(Name)->
    {print_raw, 
     {list, {tuple, Name, [{"class", atom},
			   {"module",atom},
			   {"name",term}]
	    }
     }
    }.


