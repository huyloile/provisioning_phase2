-module(test_svc_options).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").

-define(IMSI_CMO,"999000901000000").
-define(int_msisdn,"+99901000000").
-define(msisdn,"9901000000").

-define(Bons_plans_School,[opt_school_zone_a,
			   opt_school_zone_b,
			   opt_school_zone_c]).

insert_list_top_num(MSISDN,TOP_NUM_LIST) ->
    test_util_of:insert_list_top_num(MSISDN,TOP_NUM_LIST).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    
    test_is_option_activated().

online()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% is_option_activated tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_is_option_activated() ->
    test_is_option_activated("opt_zap_vacances").

test_is_option_activated("opt_zap_vacances") ->
    %% this "fake option" corresponds to one of ?Bons_plans_School
    
    lists:foldl(
      fun({OptList, DCL, Expected}, Count) ->
	      Session = test_util_of:create_session("cmo", 2),
	      Session1 = test_util_of:set_sdp_user_state_cmo(Session, DCL, 0,
							     undefined, 5000, 
							     OptList),
	      Result = svc_options:is_option_activated(Session1, 
						       opt_zap_vacances),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [
       {[opt_school_zone_a], ?zap_vacances, true},
       {[opt_school_zone_b], ?zap_vacances, true},
       {[opt_school_zone_c], ?zap_vacances, true},
       {[opt_school_zone_a], ?zap_cmo_1h30_v2, true},
       {[opt_school_zone_b], ?zap_cmo_1h30_v2, true},
       {[opt_school_zone_c], ?zap_cmo_1h30_v2, true},
       {[opt_pass_vacances_v2_mtc], ?zap_vacances, false},
       {[opt_pass_vacances_v2_mtc,opt_school_zone_c], ?zap_vacances, true}
       
      ]),
    io:format("test_is_option_activated(\"opt_zap_vacances\") OK ~n").
