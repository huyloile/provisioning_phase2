-module(test_identifying_user_local).

-export([run/0, online/0]).
-export([delete_users_and_uoe_by_imsi/1,
	 delete_ofe_by_imsi/1,
	 set_ocf/2,
	 check_tech_seg_in_db/2]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("test_provisioning.hrl").

-define(direct_code,"#105").

data(imsi,mobi)->               "208010900000001";
data(imsi,cmo)->                "208010901000001";
data(imsi,postpaid)->           "208010902000001";
data(imsi,dme)->                "208010903000001";
data(imsi,anon)->               "208010904000001";
data(imsi,omer)->               "208010905000001";
data(imsi,bzh_gp)->             "208010906000001";
data(imsi,bzh_cmo)->            "208010907000001";
data(imsi,tele2_gp)->           "208010908000001";
data(imsi,tele2_pp)->           "208010909000001";
data(imsi,virgin_prepaid)->     "208010900100001";
data(imsi,virgin_comptebloque)->"208010901100001";
data(imsi,virgin_postpaid)->    "208010902100001";
data(imsi,ten_postpaid)->       "208010903100001";
data(imsi,carrefour_prepaid)->  "208010904100001";
data(imsi,monacell_prepaid)->   "208010905100001";
data(imsi,monacell_postpaid)->  "208010906100001".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,identifying_user()).

identifying_user() ->

    %%Test title
    [{title, "Test du provisioning de niveau 1"}] ++
	
        %%Connection to the USSD simulator (smppasn by default)
        test_util_of:connect() ++

	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM users_orangef_extra\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM stats\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM svcprofiles\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM users\""}]}] ++

 	lists:append([new_client(Subscription,out_ocf) || Subscription <- ?all_subscriptions]) ++ 
 	lists:append([new_client(Subscription,in_ocf) || Subscription <- ?all_subscriptions, Subscription /= anon]) ++ 
 	lists:append([user_in_base(Subscription) || Subscription <- ?all_subscriptions, Subscription /= anon]) ++ 
  	test_new_client_ofe() ++
	
	%%Session closing
	test_util_of:close_session() ++
	
	["Test reussi"] ++

        [].

test_new_client_ofe() ->

    [StcNoField, StcDoesNotKnow, StcNotQueriedYet] = 
	[rpc:call(possum@localhost,
		  ocf_rdp,
		  tech_seg_int_to_code,
		  [Ocf]) || Ocf <- [?OCF_NO_FIELD,?OCF_DOES_NOT_KNOW,?OCF_NOT_QUERIED_YET]],

   	new_client_ofe(data(imsi,mobi),
   		       "mobi",
   		       "UMTS1",
   		       "UMTS1",
   		       "mobi long 3g",
   		       in_ocf)++
   	new_client_ofe(data(imsi,mobi),
   		       "mobi",
   		       "TRM3G",
   		       "TRM3G",
   		       "mobi long 3g",
   		       in_ocf)++
   	new_client_ofe(data(imsi,mobi),
   		       "mobi",
   		       "TRM3G",
   		       StcNotQueriedYet,
   		       "mobi long 3g",
   		       in_ocf)++
   	new_client_ofe(data(imsi,mobi),
   		       "mobi",
   		       StcNoField,
   		       StcNoField,
   		       "mobi long default",
   		       in_ocf)++
   	new_client_ofe(data(imsi,mobi),
   		       "mobi",
   		       StcDoesNotKnow,
   		       StcDoesNotKnow,
   		       "mobi long default",
   		       in_ocf)++
	[].
    
%% +type consultation_princ_ac() -> service_test().

new_client_ofe(IMSI,SUB,TSC,ExpTSC, ExpPage,Type) when Type == in_ocf ->
    OT = #ocf_test{tac="012345", ussd_level=1, sub=SUB,
		   tech_seg_code = TSC},
    TSI =
	case TSC of
	    S when list(S) ->
		rpc:call(possum@localhost,
			 ocf_rdp, tech_seg_code_to_int, [TSC]);
	    N when integer(N) ->
		N
	end,
    EQR = lists:flatten(io_lib:format("~s[ \t]+~p", [SUB, TSI])),
    OT = #ocf_test{tac="012345", ussd_level=1, sub=SUB,
		   tech_seg_code = TSC},
    Title = io_lib:format(
	      "Test connexion nouveau client ~s avec segment technologique ~p",
	      [SUB, TSC]),
    delete_users_and_uoe_by_imsi(IMSI) ++
	[{title, Title},
	 {msaddr, {subscriber_number, private, IMSI}}]
	++ set_ocf(IMSI, OT) ++
	[{ussd2,
	  [ {send, ?direct_code++"#"},
	    {expect, ExpPage}
	   ]},
	 {pause,100}
	]
	++ check_tech_seg_in_db(IMSI, EQR)
	++ delete_users_and_uoe_by_imsi(IMSI).

new_client(SUB,in_ocf) ->

    [{title, "Test pour un client " ++ atom_to_list(SUB) ++ " inconnu en base et connu dans OCF"}] ++
	[{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[sub,{data(imsi,SUB),SUB}]]},
	   {rpc, call, [possum@localhost,ets,
			insert,[ocf_test,{data(imsi,SUB),#ocf_test{tac="012345",
								   ussd_level=1,
								   sub=atom_to_list(SUB)}}]]}]}] ++

	[{title, "Test pour un client "++ atom_to_list(SUB) ++" inconnu en base et connu dans OCF"}] ++

	delete_users_and_uoe_by_imsi(data(imsi,SUB))++

	[{msaddr, {subscriber_number, private, data(imsi,SUB)}},  
	 {ussd2,
	  [ {send, ?direct_code++"#"},
	    {expect, atom_to_list(SUB)}
	   ]}] ++

	[{pause,100},
	 {shell,
	  [ {send, "mysql -u possum -ppossum -B -e \"SELECT subscription FROM users "
	     "WHERE imsi='"++data(imsi,SUB)++"'\" mobi"},
	    {expect,atom_to_list(SUB)}
	   ]}
	] ++

	[{title, "Test SACHEM HS pour un client " ++ atom_to_list(SUB) ++ " inconnu en base et connu dans OCF"}] ++

	test_util_of:switch_interface_status(io_sach_mobi_fake,disabled)++
	delete_users_and_uoe_by_imsi(data(imsi,SUB))++
	[{ussd2,
	  [ {send, ?direct_code++"*#"},
	    {expect, atom_to_list(SUB)}
	   ]}]++
	test_util_of:switch_interface_status(io_sach_mobi_fake,enabled)++

	[{title, "Test OCF HS pour un client " ++ atom_to_list(SUB) ++ " inconnu en base et connu dans OCF"}] ++

	test_util_of:switch_interface_status(httpclient_ocfrdp,disabled)++
	delete_users_and_uoe_by_imsi(data(imsi,SUB))++
	[{ussd2,
	  [ {send, ?direct_code++"*#"},
	    {expect, "Le service est temporairement indisponible"}
	   ]}]++
	test_util_of:switch_interface_status(httpclient_ocfrdp,enabled)++

	[];

new_client(SUB,out_ocf) ->
    delete_users_and_uoe_by_imsi(data(imsi,SUB))++
	[{title, "Test pour un client "++ atom_to_list(SUB) ++ " inconnu en base et inconnu dans OCF"},
	 {msaddr, {subscriber_number, private,data(imsi,SUB)}},  
	 {erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[sub,{data(imsi,SUB),atom_to_list(SUB)}]]},
	   {rpc, call, [possum@localhost,ets,
			delete,[ocf_test,data(imsi,SUB)]]}]},
	 {ussd2,
	  [ {send, ?direct_code++"#"},
	    {expect, ".*tempora*"}
	   ]},
	 {pause,100},
	 {shell,
	  [ {send, "mysql -u possum -ppossum -B -e \"SELECT count(*) FROM users "
	     "WHERE imsi='"++data(imsi,SUB)++"'\" mobi"},
	    {expect,"0"}
	   ]}
	].

%% +type consultation_princ_ac() -> service_test().
user_in_base(SUB) ->
    [
     {title, "Test client " ++ atom_to_list(SUB) ++ " connu en base"},
     {shell,
      [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
	 "SET subscription='"++atom_to_list(SUB)++"' WHERE imsi='"++data(imsi,SUB)++"'\" mobi"}
       ]},
     {msaddr, {subscriber_number, private, data(imsi,SUB)}},  
     {ussd2,
      [{send, ?direct_code++"#"},
       {expect, atom_to_list(SUB)}
      ]},
     {pause,100},
     {shell,
      [ {send, "mysql -u possum -ppossum -B -e \"SELECT subscription FROM users "
	 "WHERE imsi='"++data(imsi,SUB)++"'\" mobi"},
	{expect,atom_to_list(SUB)}
       ]}  
    ].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% FUNCTION USE IN TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delete_users_and_uoe_by_imsi(IMSI) ->
    ["Deleting row in users (imsi = "++IMSI++") "
     "stats and users_orangef_extra",
     {shell,
      [ {send,
	 "mysql -u possum -ppossum mobi -Be "
	 "\"SELECT @u := uid FROM users WHERE imsi = '"++IMSI++"'; "
	 "  DELETE FROM users WHERE uid = @u; "
	 "  DELETE FROM stats WHERE uid = @u; "
	 "  DELETE FROM svcprofiles WHERE uid = @u; "
	 "  DELETE FROM users_orangef_extra WHERE uid = @u\""}]}
    ].

%% +type set_ocf(string(), ocf_test()) -> service_test().

set_ocf(IMSI, OT) ->
    #ocf_test{sub = SUB} = OT,
    [{erlang, 
      [ {net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,ets,insert,[sub,{IMSI,SUB}]]},
        {rpc, call, [possum@localhost,ets,insert,[ocf_test,{IMSI,OT}]]}]}].

%% +type check_tech_seg_in_db(string()) -> service_test().

check_tech_seg_in_db(IMSI, Expected) ->
     [{shell,
      [ {send,
	 "mysql -u possum -ppossum mobi -Bse "
	 "\"SELECT subscription, tech_segment "
	 "  FROM users LEFT JOIN users_orangef_extra USING (uid) "
	 "  WHERE imsi = '"++IMSI++"'\""},
	{expect,Expected}
       ]}].

%% +type delete_ofe_by_imsi(string()) -> service_test().
delete_ofe_by_imsi(Imsi) ->
    [{shell,
      [ {send,
	 "mysql -u possum -ppossum mobi -Bse "
	 "\"SELECT @u := uid FROM users WHERE imsi = '"++Imsi++"'; "
	 "  DELETE FROM users_orangef_extra WHERE uid = @u\""}
       ]}].


