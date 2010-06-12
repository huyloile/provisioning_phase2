-module(test_123_service_access).
-compile([export_all]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INCLUDES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("../../ptester/include/ptester.hrl").
-include("profile_manager.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid,service_access).
-define(DIRECT_CODE,"#123#").

run()->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



online() ->
    smsloop_client:start(),
    test_util_of:online(?MODULE,test()),
    smsloop_client:stop().

test()->
    test_mvno_access()++
	test_internet_everywhere_access()++
	["Test reussi"].

test_mvno_access() ->
     lists:append([test_mvno_access(Sub) || Sub <- [
     						    "virgin_prepaid",
     						    "virgin_comptebloque",
     						    "virgin_postpaid",
     						    "tele2_pp",
     						    "tele2_comptebloque",
     						    "carrefour_prepaid",
     						    "ten_postpaid",
     						    "ten_comptebloque",
     						    "monacell_prepaid",
     						    "nrj_prepaid",
     						    "nrj_comptebloque",
     						    "carrefour_comptebloque",
     						    "opim"
     						  ]]).

test_internet_everywhere_access() ->
    lists:append([test_internet_everywhere_access(DCL) || DCL <- [120,124,138,139,140,141,142,143]]).

test_mvno_access(Sub) ->
    init(Sub)++
	[{title,"Test MVNO subscription "++Sub++" access with #123"}] ++
	 [ {ussd2,
	    [ {send, ?DIRECT_CODE},
	      {expect, "Vous n'avez pas acces a ce service.*"
	       "Pour acceder a votre suivi conso, merci d'appeler le numero \\*144\\# depuis votre mobile \\(appel gratuit\\)."}
	     ]}]++
	test_util_of:close_session().

test_internet_everywhere_access(Dcl) ->
    init("mobi")++
	profile_manager:set_dcl(?Uid,Dcl)++
	[{title,"Test Internet everywhere access by declinaison = "++integer_to_list(Dcl)}] ++
	 [ {ussd2,
	    [ {send, ?DIRECT_CODE},
	      {expect, "Vous n'avez pas acces a ce service.*Pour acceder a votre suivi conso, telechargez depuis votre ordinateur le nouveau kit de connexion sur orange.fr \\> rubrique assistance"}
	     ]}]++
	test_util_of:close_session().

init(Sub) ->
  	profile_manager:create_default(?Uid,Sub)++
  	profile_manager:init(?Uid).


