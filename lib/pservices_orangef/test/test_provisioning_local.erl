-module(test_provisioning_local).
-export([run/0, online/0, rmplus/1, renew_imsi/1, data/2,set_in_sachem/1,reset_local_db/1,renouv/1,count_by_imsi/2,count_by_subscription/2,select_by_subscription/1,change_msisdn_of_renewed_imsi/1,count_by_msisdn/2,set_ocf/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/ftmtlv.hrl").
-include("test_provisioning.hrl").

-define(subscriptions_with_no_platform,[tele2_gp,bzh_gp,virgin_postpaid,ten_postpaid,monacell_postpaid]).

-define(service_code_level_2,"#104*#").
-define(service_code_level_3,"#103*#").

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
data(imsi,monacell_postpaid) -> "208010906100001";

data(msisdn,mobi)->               "+33600000001";
data(msisdn,cmo)->                "+33601000001";
data(msisdn,postpaid)->           "+33602000001";
data(msisdn,dme)->                "+33603000001";
data(msisdn,anon)->               "+33604000001";
data(msisdn,omer)->               "+33605000001";
data(msisdn,bzh_gp)->             "+33606000001";
data(msisdn,bzh_cmo)->            "+33607000001";
data(msisdn,tele2_gp)->           "+33608000001";
data(msisdn,tele2_pp)->           "+33609000001";
data(msisdn,virgin_prepaid)->     "+33600100001";
data(msisdn,virgin_comptebloque)->"+33601100001";
data(msisdn,virgin_postpaid)->    "+33602100001";
data(msisdn,ten_postpaid) ->      "+33603100001";
data(msisdn,carrefour_prepaid) -> "+33604100001";
data(msisdn,monacell_prepaid) ->  "+33605100001";
data(msisdn,monacell_postpaid) -> "+33606100001";

data(dcl,mobi)->                  integer_to_list(?mobi);
data(dcl,cmo)->                   integer_to_list(?ppol3);
data(dcl,_)->                     "".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,provisioning()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type provisionning() -> service_test().

provisioning() ->

    %%Test title
    [{title, "Test du provisioning de niveau 2"}] ++

        %%Connection to the USSD simulator (smppasn by default)
        test_util_of:connect() ++

	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM users_orangef_extra\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM stats\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM svcprofiles\""}]}] ++
	[{shell, [{send, "mysql -u possum -ppossum mobi -B -e \"DELETE FROM users\""}]}] ++

	test_util_of:set_parameter_for_test(niveau_provisioning,[{"#104",niveau1}])++
        %%Test construction
       	lists:append([provisioning(Subscription) || Subscription <- ?all_subscriptions]) ++ 
       	lists:append([level_232(Subscription) || Subscription <- ?internet_subscriptions]) ++ 
	lists:append([anon_as_origin(Subscription) || Subscription <- ?internet_subscriptions]) ++ 

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++

        [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type provisioning() -> service_test().
provisioning(Subscription)->
    user_changing_msisdn(Subscription) ++
	user_renouvellement_msisdn_change(Subscription)++
	user_reuse_msisdn(Subscription)++
      	user_self_provisionning(Subscription) ++   
 	user_renouvellement(Subscription) ++
       	user_sachem_out_of_order(Subscription) ++
     	lists:append([change_subscription(Subscription,New_subscription) || 
     			 New_subscription <- ?sachem_subscriptions]) ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_changing_msisdn() -> service_test().
user_changing_msisdn(Subscription) ->
    [{title,
      "CHANGEMENT DE MSISDN D'UN CLIENT " ++ atom_to_list(Subscription)
     }
    ]
 	++
 	reset_local_db(Subscription)
 	++
 	new_user(Subscription) ++
 	[
 	 "Changement du msisdn dans la base locale",
 	 {shell_no_trace,
 	  [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
 	     "SET msisdn='" ++ ?new_msisdn ++
	     "' WHERE imsi='" ++ data(imsi,Subscription) ++ "'\" mobi"}
 	   ]}
	]
 	++
 	do_self_provisionning(Subscription)
 	++
 	[
 	 "Verification du profil dans la base de donnees locale",
 	 {shell,
	  case {lists:member(Subscription,?sachem_subscriptions),Subscription} of
	      {X,Y} when X==true;Y==anon ->
		  lists:append([select_by_subscription(Subscription),
				count_by_subscription(imsi,Subscription),
				count_by_subscription(msisdn,Subscription),
				count_by_msisdn(?new_msisdn,"0")
			       ]);
	      _ ->
		  lists:append([count_by_subscription(imsi,Subscription),
				count_by_msisdn(data(msisdn,Subscription),"0"),
				count_by_msisdn(?new_msisdn,"1")
			       ])
	  end
	 }   
 	].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_renouvellement_msisdn_change() -> service_test().
user_renouvellement_msisdn_change(Subscription) ->
    [{title,"RENOUVELLEMENT DE CARTE SIM AVEC CHANGEMENT DE MSISDN D'UN CLIENT " ++ atom_to_list(Subscription)}]
  	++
  	reset_local_db(Subscription)
  	++
  	new_user(Subscription) ++
  	["Changement de l'imsi dans la base locale",
  	 {shell,renew_imsi(Subscription)},
  	 "Changement du msisdn dans la base locale",
  	 {shell,change_msisdn_of_renewed_imsi(Subscription)}
  	]
  	++
  	do_self_provisionning(Subscription)
  	++
  	["Verification du profil dans la base de donnees locale",
  	 {shell,
	  case {lists:member(Subscription,?sachem_subscriptions),Subscription} of
	      {X,Y} when X==true;Y==anon ->
		  lists:append([select_by_subscription(Subscription),
				count_by_subscription(imsi,Subscription),
				count_by_subscription(msisdn,Subscription),
				count_by_imsi(renouv(data(imsi,Subscription)),"0"),
				count_by_msisdn(?new_msisdn,"0")
			       ]);
	      _->
		  lists:append([count_by_subscription(imsi,Subscription),
				count_by_imsi(renouv(data(imsi,Subscription)),"0"),
				count_by_msisdn(data(msisdn,Subscription),"0"),
				count_by_msisdn(?new_msisdn,"1")
			       ])
	  end
	 }
  	].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_reuse_msisdn() -> service_test().

user_reuse_msisdn(Subscription) ->
    [{title,
      "REUTILISATION DU MSISDN PAR UN NOUVEAU CLIENT " ++ atom_to_list(Subscription)}
    ]
  	++
  	reset_local_db(Subscription) ++
  	new_user(Subscription) ++
  	[
  	 "Changement de l'imsi dans la base locale",
  	 {shell_no_trace,
  	  [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
  	     "SET imsi='" ++ ?new_imsi ++ "' WHERE imsi='" ++ data(imsi,Subscription) ++ "'\" mobi"}
  	   ]}
	]
  	++
  	do_self_provisionning(Subscription)
  	++
  	["Verification du profil dans la base de donnees locale",
  	 {shell,
	  lists:append([select_by_subscription(Subscription),
			count_by_msisdn(data(msisdn,Subscription),
					case Subscription of
					    anon -> "1";%%If anon, do_self_provisionning() empties the database
					    _ ->"2"
					end)
		       ]
		      )
	 }     
  	].

%% +type user_self_provisionning() -> service_test().

user_self_provisionning(Subscription) ->
    [{title, 
      "PROCEDURE DE PROVISIONNING D'UN CLIENT AVEC LA SOUSCRIPTION " ++ atom_to_list(Subscription)
     }
    ] ++
	reset_local_db(Subscription) ++
	new_user(Subscription) ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type new_user() -> service_test().

new_user(Subscription) ->
    do_self_provisionning(Subscription) ++
  	["Verification du profil dans la base de donnees locale",
  	 {shell,select_by_subscription(Subscription)},
	 {shell,count_by_subscription(imsi,Subscription)},
	 {shell,count_by_subscription(msisdn,Subscription)}
	] ++
	[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type user_renouvellement() -> service_test().
user_renouvellement(Subscription) ->
    [{title,"RENOUVELLEMENT DE CARTE SIM D'UN CLIENT " ++ atom_to_list(Subscription)}]
	++
	reset_local_db(Subscription)
	++
	new_user(Subscription)
	++
	["Changement de l'imsi dans la base locale",
	 {shell,renew_imsi(Subscription)}
	]
	++
	do_self_provisionning(Subscription)
	++
	[
	 "Verification du profil dans la base de donnees locale",
	 {shell,lists:append([select_by_subscription(Subscription),
			      count_by_subscription(imsi,Subscription),
			      count_by_subscription(msisdn,Subscription),
			      count_by_imsi(renouv(data(imsi,Subscription)),"0")
			     ]
			    )
	 }     
	].

user_sachem_out_of_order(Subscription) ->

    [{title,
      "CONNEXION D'UN CLIENT " ++ atom_to_list(Subscription) ++ " ALORS QUE SACHEM EST HS"
     }
    ] ++

	reset_local_db(Subscription) ++

	test_util_of:disconnect_sachem_fake(Subscription) ++

	["Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
	 {ussd2,
	  [{send, ?service_code_level_2},
	   {expect,
	    case lists:member(Subscription,?subscriptions_with_no_platform) of
		true -> atom_to_list(Subscription);
		_ -> "Service indisponible"
	    end
	   }
	  ]
	 }
	] ++

	["Verification du profil dans la base de donnees locale",
	 {shell,count_by_imsi(data(imsi,Subscription),
			      case lists:member(Subscription,?subscriptions_with_no_platform) of
				  true -> "1";
				  _ -> "0"
			      end)}
	] ++

	test_util_of:connect_sachem_fake(Subscription) ++

	[].

do_self_provisionning(anon) ->
    %% It is necessary to reset the database :
    %%otherwise, OCF is not queried and the subscription is anon instead of postpaid
    reset_local_db(anon) ++
	set_ocf(data(imsi,anon),data(msisdn,anon),postpaid)++
	["Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,anon)}},
	 {ussd2,
 	  [ {send,?service_code_level_2},
 	    {expect, "postpaid"}
 	   ]},
	 %% wait for profile to be dumped in local db
	 {pause, 1000},
	 {shell_no_trace,
	  [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
	     "SET subscription='anon' WHERE imsi='"++ data(imsi,anon) ++ "'\" mobi"}
	   ]}
	];

do_self_provisionning(Subscription) ->
    set_ocf(Subscription) ++
	set_in_sachem(Subscription) ++
	[
	 "Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
	 {ussd2,
	  [ {send, ?service_code_level_2},
	    {expect, atom_to_list(Subscription)}
	   ]},
	 %% wait for profile to be dumped in local db
	 {pause, 1000}
	].

change_subscription(Origin,Target) ->
    case Target of
	Origin -> 
	    [];
	_ ->
	    [{title, 
	      "CLIENT " ++ atom_to_list(Origin) ++ " DEVIENT " ++ atom_to_list(Target)
	     }
	    ] ++
		reset_local_db(Origin) ++

		reset_local_db(Target) ++

		set_in_sachem(Origin) ++	

		new_user(Origin) ++

		change_subscription_in_sachem(Origin,Target) ++	
		[
		 "Connexion a Cellcube pour realisation du provisioning selfcare.",
		 {msaddr, {subscriber_number, private, data(imsi,Origin)}},
		 {ussd2,
		  [ {send, ?service_code_level_2},
		    {expect, case lists:member(Origin,?subscriptions_with_no_platform) of
				 true -> atom_to_list(Origin);
				 false -> atom_to_list(Target)
			     end}
		   ]},
		 {pause, 500}
		]++ 

		[
		 " Verification du profil dans la base locale",
		 {shell_no_trace,
		  [ {send, "mysql -u possum -ppossum -B -e \"SELECT msisdn,imsi,subscription FROM users "
		     "WHERE imsi='" ++ data(imsi,Origin) ++ "'\" mobi"},
		    {expect,
		     rmplus(data(msisdn,Origin)) ++ ".*" ++
		     data(imsi,Origin) ++ ".*" ++ 
		     case lists:member(Origin,?subscriptions_with_no_platform) of
			 true -> atom_to_list(Origin);
			 false -> atom_to_list(Target)
		     end}
		   ]}
		] ++

		change_subscription_in_sachem(Origin,Origin)
    end.

level_232(Subscription)->
    set_ocf(Subscription) ++
	[
	 "Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
	 {ussd2,
	  [ {send, ?service_code_level_2},
	    {expect, atom_to_list(Subscription)}
	   ]},
	 %% wait for profile to be dumped in local db
	 {pause, 1000}
	] ++

	[
	 "Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
	 {ussd2,
	  [ {send, ?service_code_level_3},
	    {expect, atom_to_list(Subscription)}
	   ]},
	 %% wait for profile to be dumped in local db
	 {pause, 1000}
	] ++

	[
	 "Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
	 {ussd2,
	  [ {send, ?service_code_level_2},
	    {expect, atom_to_list(Subscription)}
	   ]},
	 %% wait for profile to be dumped in local db
	 {pause, 1000}
	].

anon_as_origin(Subscription)->

    set_ocf(Subscription) ++
	[
	 "Connexion a Cellcube pour realisation du self provisionning.",
	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
	 {ussd2,
	  [ {send, ?service_code_level_2},
	    {expect, atom_to_list(Subscription)}
	   ]},
	 %% wait for profile to be dumped in local db
	 {pause, 1000}
	] ++

	[{shell,[{send, "mysql -u possum -ppossum -B -e \"UPDATE users set subscription='" ++ "anon" ++ "' "
	  "WHERE imsi='" ++ data(imsi,Subscription) ++ "'\" mobi"}]}] ++

 	[
 	 "Connexion a Cellcube pour realisation du self provisionning.",
 	 {msaddr, {subscriber_number, private, data(imsi,Subscription)}},
 	 {ussd2,
 	  [ {send, ?service_code_level_2},
 	    {expect, atom_to_list(Subscription)}
 	   ]},
 	 %% wait for profile to be dumped in local db
 	 {pause, 1000}
 	] ++

	[].

%%%%OCF FAKE UTILITIES

set_ocf(Subscription)->
    [
     {erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[ocf_test,{data(imsi,Subscription),
				      #ocf_test{tac="012345",
						ussd_level=1,
						msisdn=data(msisdn,Subscription),
						sub=atom_to_list(Subscription)}}]]}]}
    ].

set_ocf(Imsi,Msisdn,Subscription)->
    [
     {erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[ocf_test,{Imsi,
				      #ocf_test{tac="012345",
						ussd_level=1,
						msisdn=Msisdn,
						sub=atom_to_list(Subscription)}}]]}]}
    ].

%%%%SACHEM FAKE UTILITIES

change_subscription_in_sachem(Origin,Target)->

    case Origin of 
	Target -> ["Insertion de la souscription dans le SACHEM local"];
	_ -> ["Modification de la souscription dans le SACHEM local"]
    end ++

	test_util_of:delete_in_sachem(data(imsi,Origin)) ++

	test_util_of:delete_in_sachem(data(msisdn,Origin)) ++

	case lists:member(Target,?sachem_subscriptions) of
	    true ->
		test_util_of:set_in_sachem(data(imsi,Origin),
					   data(msisdn,Origin),
					   atom_to_list(Target));
	    _ ->
		[]
	end.

set_in_sachem(Subscription) ->
    change_subscription_in_sachem(Subscription,Subscription).

%%%%SQL QUERIES

select_by_subscription(Subscription) ->
    [{send, "mysql -u possum -ppossum -B -e \"SELECT imsi,subscription FROM users "
 	    "WHERE imsi='" ++ data(imsi,Subscription) ++ "'\" mobi"},
     {expect, data(imsi,Subscription) ++ ".*" ++ atom_to_list(Subscription)}].

count_by_subscription(imsi,Subscription) ->
    [{send, "mysql -u possum -ppossum -B -e \"SELECT COUNT(*) FROM users "
     "WHERE imsi='" ++ data(imsi,Subscription) ++ "'\" mobi"},
    {expect, "1"}];

count_by_subscription(msisdn,Subscription) ->
    [{send, "mysql -u possum -ppossum -B -e \"SELECT COUNT(*) FROM users "
     "WHERE msisdn='" ++ data(msisdn,Subscription) ++ "'\" mobi"},
    {expect, "1"}].

count_by_msisdn(Msisdn,Value) ->
    [{send, "mysql -u possum -ppossum -B -e \"SELECT COUNT(*) FROM users "
     "WHERE msisdn='" ++ Msisdn ++ "'\" mobi"},
    {expect,Value}].

count_by_imsi(Imsi,Value) ->
    [{send, "mysql -u possum -ppossum -B -e \"SELECT COUNT(*) FROM users "
     "WHERE imsi='" ++ Imsi ++ "'\" mobi"},
    {expect,Value}].

renew_imsi(Subscription) ->
    [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
       "SET imsi='" ++ renouv(data(imsi,Subscription)) ++ "' WHERE imsi='" ++ data(imsi,Subscription) ++ "'\" mobi"}
     ].
change_msisdn_of_renewed_imsi(Subscription) ->
    [ {send, "mysql -u possum -ppossum -B -e \"UPDATE users "
       "SET msisdn='" ++ ?new_msisdn ++
       "' WHERE imsi='" ++ renouv(data(imsi,Subscription)) ++ "'\" mobi"}
     ].

reset_local_db(Subscription)->
    ["Deleting profiles corresponding to the subscription " ++ atom_to_list(Subscription) ++ " in local database",
     {shell_no_trace,
      [{send,
	"mysql -u possum -ppossum mobi -Be "
 	"\"SELECT @u := uid FROM users WHERE msisdn = '" ++ ?new_msisdn ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""},
       {send,
 	"mysql -u possum -ppossum mobi -Be "
 	"\"SELECT @u := uid FROM users WHERE imsi = '" ++ data(imsi,Subscription) ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""},
       {send,
	"mysql -u possum -ppossum mobi -Be "
 	"\"SELECT @u := uid FROM users WHERE imsi = '" ++renouv(data(imsi,Subscription)) ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
  	"  DELETE FROM svcprofiles WHERE uid = @u; "
	"  DELETE FROM users_orangef_extra WHERE uid = @u\""},
       {send,
	"mysql -u possum -ppossum mobi -Be "
	"\"SELECT @u := uid FROM users WHERE msisdn = '" ++ data(msisdn,Subscription) ++ "'; "
 	"  DELETE FROM users WHERE uid = @u; "
 	"  DELETE FROM stats WHERE uid = @u; "
 	"  DELETE FROM svcprofiles WHERE uid = @u; "
 	"  DELETE FROM users_orangef_extra WHERE uid = @u\""}
      ]}
    ].

%%%%UTILITIES

renouv(IMSI) -> renouv(IMSI, 1).
renouv([], N) -> [];
renouv([H|T], 8) -> [H+1|T];
renouv([H|T], N) -> [H|renouv(T, N+1)].

rmplus([$+|T]) -> T.
