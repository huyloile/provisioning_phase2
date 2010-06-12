-module(test_123_mobi_m6_soirees_sms_offerte).
-compile(export_all).

-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").


-define(Uid, user_soirees_sms_offerte).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    test_print_credit_soiree(),
    test_redirect_by_day_off(),
    test_soirees_sms(),
    test_redirect_soirees_sms(),
    test_print_end_credit(),
    ok.


test_print_credit_soiree() ->
    lists:foldl(
      fun({Solde_1,Solde_2,Expected},Count) ->
	      Session = set_session(Solde_1,Solde_2),
	      [{pcdata,Result}] = svc_of_plugins:print_credit(Session,"mobi","opt_ssms_m6","day"),
	      {Count, Expected}= {Count, Result},
	      Count + 1
      end,
      1,
      [{0,0,"0"},
       {2000,0,"1"},
       {0,2000,"1"},
       {2000,2000,"1"},
       {6000,2000,"3"}
      ]
     ).


test_redirect_by_day_off() ->
    Today=date(),
    Session=set_session(0),
    pbutil:opt_set_env(pservices_orangef, day_off, [Today]),
    {redirect, _, "day_off"} = svc_of_plugins:redirect_by_day_off(Session,"day_off","not_day_off").

test_print_end_credit()->
    {Y,M,_}=date(),
    Last_Day = lists:flatten(pbutil:sprintf("%02d/%02d",[calendar:last_day_of_the_month(Y,M),M])),
    lists:foldl(
      fun({Existing_compte, Expected}, Count) ->
	      Session = set_session(Existing_compte),
	      [{pcdata,Result}] = svc_of_plugins:print_end_credit(Session,"opt_ssms_m6","dm"),
	      {Count, Expected} = {Count, Result},
	      Count +1
      end,
      1,
      [{[cpte_m6_soiree_sms_dispo],"08/06"},
       {[cpte_m6_soiree_sms_recharge],Last_Day},
       {[cpte_m6_soiree_sms_dispo,cpte_m6_soiree_sms_recharge],Last_Day}]).


test_soirees_sms()->
    pbutil:opt_set_env(pservices_orangef, commercial_date,[{opt_m6_une_soiree_sms, [{{{2008,1,1},{0,0,0}}, {{2100,1,1},{0,0,0}}}]},
							   {opt_m6_des_soirees_sms,[{{{2008,1,1},{0,0,0}}, {{2100,1,1},{0,0,0}}}]}]),
    Default_url = [#hlink{href="Url",key=[],kw=[],cost=0,help=[],contents=[{pcdata, "Link"}]},br],
    lists:foldl(
      fun({Solde, Etat_CP, Etat_CS, Expected}, Count) ->
	      Session = set_session(Solde, Etat_CP, Etat_CS),
	      Result_une = svc_of_plugins:proposer_lien(Session,"mobi", "opt_m6_une_soiree_sms", "Link", "Url"),
	      Result_des = svc_of_plugins:proposer_lien(Session,"mobi", "opt_m6_des_soirees_sms", "Link", "Url"),
	      {Count, Expected} = {Count, {Result_une,Result_des}},
	      Count + 1
      end,
      1,
      [{[2000, 0], ?CETAT_AC, ?SETAT_ID, {Default_url,[]}},
       {[0,    0], ?CETAT_AC, 0, {[],[]}},
       {[0,    0], ?CETAT_AC, ?SETAT_ID,{[],[]}},
       {[2000, 0], ?CETAT_AC, ?SETAT_ID,{Default_url,[]}},
       {[0,    0], 0,            ?SETAT_ID,{[], []}},
       {[4000, 0], ?CETAT_AC, ?SETAT_ID,{[],Default_url}},
       {[4000, 0], ?CETAT_AC, 0,{[],[]}},
       {[6000, 0], ?CETAT_AC, ?SETAT_ID,{[],Default_url}},
       {[10000,0], ?CETAT_AC, ?SETAT_ID,{[],Default_url}},
       {[2000,2000], ?CETAT_AC, ?SETAT_ID,{Default_url,[]}},
       {[2000,4000], ?CETAT_AC, ?SETAT_ID,{Default_url,[]}}
      ]).

test_redirect_soirees_sms()->
    pbutil:opt_set_env(pservices_orangef, commercial_date,[{opt_m6_une_soiree_sms, [{{{2008,1,1},{0,0,0}}, {{2100,1,1},{0,0,0}}}]},
							   {opt_m6_des_soirees_sms,[{{{2008,1,1},{0,0,0}}, {{2100,1,1},{0,0,0}}}]}]),
    lists:foldl(
      fun({Solde1, Solde2, Expected}, Count) ->
	      Session = set_session(Solde1, Solde2),
	      {redirect, _, Result} = svc_of_plugins:redirect_by_compte_solde(Session, "cpte_m6_soiree_sms", "2000", "url_une", "url_des"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{2000, 0, "url_une"},
       {0, 0, "url_une"},
       {6000, 0, "url_des"},
       {2000, 6000, "url_une"},
       {0, 6000, "url_des"}]).

tcp_num(cpte_m6_soiree_sms_recharge)->
    216;
tcp_num(cpte_m6_soiree_sms_dispo_dlv_ok) ->
    215;
tcp_num(cpte_m6_soiree_sms_dispo) ->
    215.
dlv(cpte_m6_soiree_sms_dispo)->
    svc_util_of:local_time_to_unixtime({{2005,6,8},{23,59,59}});
dlv(_) ->
    pbutil:unixtime()+86400.


compte(cpte_m6_soiree_sms_dispo_dlv_ok, Solde)->
    compte(cpte_m6_soiree_sms_dispo, cpte_m6_soiree_sms_dispo_dlv_ok, Solde);
compte(Name, Solde)->
    compte(Name, Name, Solde). 
compte(Name, Config, Solde)->
    {Name,#compte{tcp_num=tcp_num(Config),
		  unt_num=?EURO,
		  cpp_solde={sum,euro,Solde},
		  dlv=dlv(Config),
		  rnv=0,
		  etat=?CETAT_AC,
		  ptf_num=?PBONS_PLANS}}.

set_session(Existing_compte) when is_list(Existing_compte) ->
    Comptes = [compte(Name,2000) || Name <- Existing_compte],
    set_session(2000, ?CETAT_AC, ?SETAT_ID, Comptes);

set_session(Solde)->
    set_session([Solde,0], ?CETAT_AC, ?SETAT_ID).

set_session(Solde_1,Solde_2)->
    Comptes = [compte(Name,Solde) || {Name,Solde} <- [{cpte_m6_soiree_sms_dispo,Solde_1},
						      {cpte_m6_soiree_sms_recharge,Solde_2}
						     ]],
    set_session(2000, ?CETAT_AC, ?SETAT_ID, Comptes).

set_session([Solde_1, Solde_2], Etat_CP, Etat_CS)->
    set_session(Solde_1, Etat_CP, Etat_CS, [compte(cpte_m6_soiree_sms_dispo,Solde_1),
					    compte(cpte_m6_soiree_sms_recharge,Solde_2)]).

set_session(_, Etat_CP, Etat_CS, Comptes) ->
    #session{prof=#profile{subscription="mobi",terminal=#terminal{imei="35185301"}},
	     svc_data=[{user_state,#sdp_user_state{declinaison=?DCLNUM_ADFUNDED,topNumList=[0],options=[], d_activ = test_util_of:lt2unixt({date(),{0,0,0}})+86400,
						   cpte_princ = #compte{tcp_num=?C_PRINC, 
									unt_num=?EURO, 
									cpp_solde=10000, 
									dlv=pbutil:unixtime(), 
									rnv=0, 
									etat=Etat_CP,
									ptf_num=?PLUGV3},
						   cpte_list = Comptes,
						   etats_sec=Etat_CS}}]}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online - function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(IMSI,"999000900000001").
-define(MSISDN,"9900000001").
-define(IMSI_NOK,"999000900000002").
-define(MSISDN_NOK,"9900000002").

online() ->
    test_util_of:online(?MODULE,test()).

test()->
    test_soiree_sms_offertes(?m6_prepaid) ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dcl_to_name(?m6_prepaid)->
    "M6 Prepaid";
dcl_to_name(_) ->
    "M6 Adfunded".

test_soiree_sms_offertes(DCL)->
    lists:append([test_soiree_sms_offertes(Solde, Etat_sec, Text, ExpectedText, DCL) || 
		     {Solde,Etat_sec,Text,ExpectedText} <- [
							    %% Une soiree
							    {0,
							     1,
							     "Test Menu without link soiree sms",
							     "4:Nouveautes"},
							    %% Une soiree
							    {2,
							     1,
							     "Test Votre soiree sms offerte",
							     "5:Votre soiree sms offerte"},
							    %% 2 soirees
							    {4,
							     1,
							     "Test Vos soirees sms offertes",
							     "5:Vos soirees sms offertes"},
							    %% 3 soirees
							    {6,
							     1,
							     "Test Vos soirees sms offertes",
							     "5:Vos soirees sms offertes"}
							   ]])++

	lists:append([test_soiree_sms_offertes_expired(Solde, Text, DCL) ||
			 {Solde,Text} <- [{2,"Test Votre soiree sms offerte"},
					  {4,"Test Vos soirees sms offertes"},
					  {6,"Test Vos soirees sms offertes"}
					 ]])++
	[].

test_soiree_sms_offertes(Solde,Etat_sec,Text,ExpectedText,DCL)->
    init_test(DCL)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
                                                       unt_num=?EURO,
                                                       cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),
                                                       rnv=0,
                                                       etat=?CETAT_AC,
                                                       ptf_num=?PCLAS_V2},
					       #compte{tcp_num=?C_M6P_SMS_DISPO,
						       unt_num=?EURO,
						       cpp_solde=Solde*1000,
						       dlv=svc_util_of:local_time_to_unixtime({{2015,02,15},{10,00,00}}),
						       rnv=0,
						       etat=?CETAT_AC,
						       ptf_num=144}])++
 	[{title, Text},
	 "SOIREE SMS ILLIMITES OFFERTES - "++ dcl_to_name(DCL)++" - Solde = "++integer_to_list(Solde)++"E",
 	 {ussd2,
 	  [ 
	    {send, test_util_of:access_code(test_123_mobi_homepage, ?menu_page)},
 	    {expect,ExpectedText}
 	   ]}]++

	suite_test_soiree_sms_offertes(Solde) ++
	%% suite_test_soiree_sms_illimite_deja_active(Solde) ++
	test_util_of:close_session()++
	[].

suite_test_soiree_sms_offertes(0)->
    [];
suite_test_soiree_sms_offertes(Solde) ->
    ["Test Souscription and Conditions",
     {ussd2,
      [
       {send, test_util_of:access_code(test_123_mobi_homepage, ?m6_variable_x, [?m6_variable_x])},
       {expect,"M6 mobile by Orange vous offre "++ nb_soiree(Solde)++
	"Ce bonus est valable jusqu'au ../.. minuit.."
	"1:Suite"},
       {send,"1"},
       {expect,"l'activation de cette soiree sms illimites offerte est possible jusqu'au ../.. minuit.."
	"1:Activer."
	"2:Conditions"},
       {send,"2"},
       {expect,"Activation possible le jour meme de 2h00 a 23h45 au 220 ou au #123# \\(appels gratuits depuis la France metropolitaine\\)..*"
	"1:Suite.*"
	"8:Precedent"},
       {send,"1"},
       {expect,"SMS/MMS illimites vers les mobiles en France metropolitaine de 21h a 23h59 dans la limite de 200 destinataires differents par soiree..*"
	"1:Suite.*"
	"8:Precedent"},
       {send,"1"},
       {expect,"et pour un usage personnel non lucratif direct..*"
	"1:Activer.*"
	"8:Precedent"},
       {send,"1"},
       {expect,"Votre souscription a bien ete prise en compte. M6 mobile by orange a le plaisir de vous offrir votre soiree SMS illimites, valable ce soir de 21h a 23h59..*"
	"1:Suite"},
       {send,"1"},
       {expect,"Vous pouvez egalement envoyer des MMS sur la base de 1 MMS egal 1 SMS..*"
	"Dans quelques instants, vous recevrez un SMS de confirmation."}
      ]}].

test_soiree_sms_offertes_expired(Solde, Text, DCL) ->
    init_test(DCL)++
        profile_manager:set_list_comptes(?Uid,[#compte{tcp_num=?C_PRINC,
                                                       unt_num=?EURO,
                                                       cpp_solde=42000,
                                                       dlv=pbutil:unixtime(),
                                                       rnv=0,
                                                       etat=?CETAT_AC,
                                                       ptf_num=?PCLAS_V2},
                                               #compte{tcp_num=?C_M6P_SMS_DISPO,
                                                       unt_num=?EURO,
                                                       cpp_solde=Solde*1000,
                                                       dlv=svc_util_of:local_time_to_unixtime({{2009,12,31},{10,00,00}}),
                                                       rnv=0,
                                                       etat=?CETAT_AC,
                                                       ptf_num=144}])++
	[{title, Text++" - Offer SOIREE SMS ILLIMITE OFFERTES expired"},
	 {ussd2,
	  [
	   {send, test_util_of:access_code(test_123_mobi_homepage, ?m6_variable_x, [?m6_variable_x])++"11#"},
	   {expect,"Le delai de validite du cadeau bonus est depasse.Vous pouvez souscrire a la soiree sms illimites pour 2,5E."}
	  ]}].

suite_test_soiree_sms_illimite_deja_active(0)->
    [];    
suite_test_soiree_sms_illimite_deja_active(Solde) ->
    test_util_of:insert_list_top_num(?MSISDN,[0,391])++
	[{"Test Soiree SMS ILLIMITE deja active"},
	 {ussd2,
	  [ 
	    {send, test_util_of:access_code(test_123_mobi_homepage, ?m6_variable_x, [?m6_variable_x])++"11#"},
	    {expect,"Bonjour, votre bon plan Soiree SMS illimites est deja active.."
	     "Orange vous remercie de votre appel."}
	   ]}].

init_test(DCL)->
    profile_manager:create_and_insert_default(?Uid, #test_profile{sub="mobi",dcl=DCL})++
        profile_manager:init(?Uid)++
	profile_manager:set_dcl(?Uid, DCL)++
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true).

nb_soiree(2)->
    "une soiree sms illimites soit des SMS en illimite de 21h a 23h59. ";
nb_soiree(4) ->
    "2 soirees sms illimites, soit des SMS illimites a utiliser de 21h00 a 23h59, ";
nb_soiree(6) ->
    "3 soirees sms illimites, soit des SMS illimites a utiliser de 21h00 a 23h59, ".
