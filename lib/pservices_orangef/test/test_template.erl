-module(test_template).
-export([run/0, online/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../include/ftmtlv.hrl").%Main structures used in OF services
-include("../../ptester/include/ptester.hrl").%USSD simulator
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").%OCF/RDP simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(CODE_SERVICE_MENU,"#128#").
-define(IMSI_MOBI,"999000900000001").
-define(IMSI_CMO, "999000900000002").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Any function which is used in this test only or any redefinition of a generic function
%Example : set_past_period(DatesList)->
%          test_util_of:set_past_period_for_test(commercial_date,DatesList).
%Example : lt2unixt(LT) -> test_util_of:lt2unixt(LT).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    %%Initialize the application, if you want to use a configuration parameter inside the test
    application:start(pservices_orangef),

    test_util_of:online(?MODULE,test()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test()->

    %%Test title
    [{title, "Mon titre"}] ++

        %%Initialization of OMA configuration parameters
	%%Example : test_util_of:set_present_period_for_test(
	%%commercial_date,[opt_europe, opt_maghreb]) ++
	%%Example : test_util_of:set_parameter_for_test(Parameter,Value) ++

        %%Connection to the USSD simulator (smppasn by default)
        test_util_of:connect() ++
	%%Use [test_util_of:connect(smpp)] in case of roaming or if Cellgate is required

	%%In debugging mode, connection to the differents simulators
	%%if they have been disabled by accident
	%%(typically, a test crashed after disabled the interface)

        %%Initialization of customer data in ptester
	[{msaddr, {subscriber_number, private, ?IMSI_MOBI}}] ++

        %%Initialization of customer data in the local database
	%%default values equivalent to test_util_of:init_test(?IMSI_MOBI)
	test_util_of:init_test(?IMSI_MOBI, "mobi", 1, null, "") ++ 
	%%other example
	test_util_of:init_test(?IMSI_CMO,   "cmo", 2, "012345XXXXXXX1", "32495000000" ) ++ 

        %%Initialization of customer data in the other simulator(s) : SACHEM, OCF, SPIDER...
	%%Example : test_util_of:ocf_set(?IMSI_MOBI, "mobi") ++
	%%Example : test_util_of:set_in_sachem(?IMSI_MOBI, "mobi") ++

        %%Test construction
	my_test1() ++
	%%my_test2() ++

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++

        [].

my_test1() ->

    %Test title
    [ "Mon test"] ++

        %Any useful connection, disconnection, initialization as described in test()

	%% if using many IMSIs, redeclare the IMSI used (already done in init_test)
	[{msaddr, {subscriber_number, private, ?IMSI_MOBI}}] ++ 

        %Construction of USSD messages
	[{ussd2,
	  [{send, ?CODE_SERVICE_MENU},
	   {expect, "Main menu.*1:Navigation.*2:\\(unused\\)"}
	  ]
	 }
	] ++

	%%Restore IMSIs to mobi, navigation 1, imei="", vlr= ""
	test_util_of:init_test(?IMSI_CMO) ++
	
	%%Session closing
	test_util_of:close_session() ++

	[].

%my_test2()


