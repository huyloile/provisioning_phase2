-module(test_svc_of_plugins).

-export([run/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests for svc_of_plugins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    application:start(pservices_orangef),
    option_to_name(),
    ok.

option_to_name() ->
    test_util_of:set_env(pservices_orangef, cmo_libelle_opt_incomp, 
                         [{opt_pass_vacances, "Pass voyage 6E"},
                          {opt_pass_vacances_v2, "Pass voyage 6E"}]),
    "Pass voyage 6E"++";"++"Pass voyage 6E" = 
        svc_of_plugins:option_to_name([opt_pass_vacances, opt_pass_vacances_v2], cmo).
