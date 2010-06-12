%%%% This module contains svc_util_of tests and utilities for various tests.

-module(test_util_of).

-compile(export_all).

-include("../../oma/include/slog.hrl").
-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/tlv.hrl").
-include("sachem.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../include/recharge_cb_cmo_new.hrl").
-include("../include/prisme.hrl").
-include("test_util_of.hrl").

-define(P_MOBI,1).
-define(NOT_SPLITTED, ".*[^>]\$").
-define(PATH, "lib/pfront_orangef/test/webservices/postpaid_cmo/").
-define(OUT_FILE_DIR,"../doc/").

online()->
    ok.

%%%%%%%%%%%%%%%% LOCAL UNIT TESTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run()->
    are_ibu_codes_defined(),
    test_check_imei(),
    redir_declinaison(),
    test_redir_mvno(),
    ok.

are_ibu_codes_defined() ->
    application:start(pservices_orangef),
    MobiOpts = pbutil:get_env(pservices_orangef,opt_commercial_name_mobi),
    CMOOpts = pbutil:get_env(pservices_orangef,opt_commercial_name_cmo),
    PostOpts = pbutil:get_env(pservices_orangef,opt_commercial_name_postpaid),
    FSub = fun({Sub,OptionList}) ->
		   F = fun({Option,CommercialName}) ->
			       find_option_code(Sub,Option,CommercialName)
		       end,
		   lists:foreach(F,OptionList)
	   end,
    lists:foreach(FSub, [{mobi,MobiOpts}, 
		      {cmo,CMOOpts},
		      {postpaid,PostOpts}]).

find_option_code(Sub,Option,CommercialName) ->
    case lists:keysearch({Sub,Option}, 2, ?LIST_OPT_CODE ) of
	{value, {no_counter,Option}} -> 
	    ok;
	{value, {Counter,Option}} -> 
	    ok;
	_ -> 
	    case lists:keysearch(Option, 2, ?LIST_OPT_CODE ) of
		{value, {no_counter,Option}} -> 
		    ok;
		{value, {Counter,Option}} -> 
		    ok;
		_ -> 
		    io:format("IBU Code Not Defined for ~p~n",
			      [{Option,CommercialName}])
	    end
    end.

%% Case 1543
test_check_imei() ->
    Session = #session{},%init_session(Opt, ok),
    Imei1="12345679XXXXXXXX",
    Imei2="12345678XXXXXXXX",
    Imei3="123456XXXXXXXXXX",
    Imei4="ABXX",
    Imei5="",
    Tac_list = [12345678],
    Url=url_ok,
    Url_default=url_nok,

    {redirect,Session,Url_default} = svc_util_of:check_imei(Session,Imei1,Tac_list,Url,Url_default),
    {redirect,Session,Url} = svc_util_of:check_imei(Session,Imei2,Tac_list,Url,Url_default),
    {redirect,Session,Url_default} = svc_util_of:check_imei(Session,Imei3,Tac_list,Url,Url_default),
    {redirect,Session,Url_default} = svc_util_of:check_imei(Session,Imei4,Tac_list,Url,Url_default),
    {redirect,Session,Url_default} = svc_util_of:check_imei(Session,Imei5,Tac_list,Url,Url_default).

redir_declinaison() ->
    %% Test when declinaison is well defined
    Session_mobi = create_session(mobi, 0, "1"),
    {redirect, _, "#link1"} = 
	svc_util_of:redir_declinaison(Session_mobi, "0=#link1,2=#link2,default=#link3"),
    %% Test when declinaison is undefined : goes to default link
    Session_undefined = create_session(mobi, [undefined], "1"),
    {redirect, Session, "#link3"} = 
	svc_util_of:redir_declinaison(Session_undefined, "0=#link1,2=#link2,default=#link3").
    

%%%To get a structure of this file execute the command "grep FUNCTIONS%%% test_util_of.erl"

%%%GENERIC FUNCTIONS%%%
%% +type rpc(term(), term(), [term()]) -> term().
rpc(Mod, Fun, Args) ->
    case rpc:call(possum@localhost, Mod, Fun, Args) of
	{badrpc, X} = Error -> exit(Error);
	X                   -> X
    end.

%%%ON LINE TESTS FUNCTIONS%%%

empty_test_table(Table)->
    case rpc:call(possum@localhost, ets, info, [Table,name]) of
 	undefined ->
 	    ok;
 	Else ->
 	    rpc:call(possum@localhost, ets, delete_all_objects, [Table])
    end.

empty_test_table_for_test(Table)->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
  		    empty_test_table,[Table]]} 
      ]}].

reload_config() ->
    ok = rpc:call(possum@localhost, oma_config, reload_config, []).

reload_config_for_test() ->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,oma_config,
		    reload_config,[]]}
      ]}].

reload_code() ->
    rpc:call(possum@localhost,oma_code,reload,[]),
    rpc:call(possum@localhost,option_manager,init,[]).

empty_mysql_tables() ->
    CMD= "mysql -u possum -ppossum mobi -Bse \""
	"DELETE FROM users_orangef_extra;"
	"DELETE FROM stats;"
	"DELETE FROM svcprofiles;"
	"DELETE FROM users;\"",
    os:cmd(CMD).


%% +type online(string(), list()) -> list().
online(Module,Test)->
    reload_config(),
    reload_code(),
    [empty_test_table(Table) || Table <- ?MNESIA_TEST_TABLES],
    FILE_NAME="../doc/"++atom_to_list(Module)++".html",
    case Module of
	no_logger -> ok;
	_ -> testreport:start_link_logger(FILE_NAME)
    end,
    application:start(ptester),
    application:set_env(ptester, extension_modules, [ptester_orangef]),
    test_service:online(Test),
    case Module of
	no_logger -> ok;
	_ -> testreport:stop_logger()
    end.

%% +type online(atom(), list()) -> list().
online_v2(Module,TestList)->
    Files=lists:map(fun(Test)-> 
			    launch_test(Module,Test) 
		    end,
		    TestList),  
    MakeEntity = 
	fun (File) ->
		"    <!ENTITY "++File++" SYSTEM \"tr/"++File++".xml\">~n"
	end,
    MakeRef = 
	fun (File) ->
		"      &"++File++";~n"
	end,
    Entities = lists:flatten(lists:map(MakeEntity,Files)),
    Refs = lists:flatten(lists:map(MakeRef,Files)),
    io:format("Entities:~n"++Entities++"~nReferences:~n"++Refs++"~n").

launch_test(Module,{Fun,Args}) ->
    {Title,Ref,Intro,Config,Feature,Doc} = 
	apply(Module,Fun,[description|Args]),
    FileSuffix = "_"++atom_to_list(Fun),
    FilePrefix = atom_to_list(Module),
    %% give time to stop "trace_logger" of previous tests
    receive after 200 -> ok end,
    ok = testreport:start_link_logger(
	   ?OUT_FILE_DIR ++ FilePrefix ++ FileSuffix ++ ".html",
	   [{title,Title},
	    {ref,Ref},
	    {intro,Intro},
	    {config,Config},
	    {feature,Feature},
	    {doc,Doc}
	   ]),

    online(no_logger,apply(Module,Fun,[test|Args])),

    testreport:stop_logger(),
    FilePrefix ++ FileSuffix.


init_profile(#test_profile{msisdn=Msisdn, 
                           imsi=Imsi, 
                           imei=Imei,
                           vlr=Vlr,
                           tac=Tac,
                           ussd_level=Ussd_level,
                           language=Lang,
                           subscription=Subscription,
                           declinaison=Declinaison,
                           comptes=Comptes,
                           option=Option,
                           top_num_list=Top_num_list,
                           opts=Opts,
                           tech_seg_code=Seg_co,
                           code_so=Code_so,
                           comment=Realname}) ->
    Imei_level =  get_imei_from_ussd_level(Ussd_level),
    Imei_value = case Imei of
                     undefined -> Imei_level;
                     _ -> Imei
                 end,      

    %% SQL : removes and inserts the complete profile
    set_mysql_profile(#sql_profile{msisdn=Msisdn, 
                                   imsi=Imsi,
                                   imei=Imei_value,
                                   language=Lang,
                                   realname=Realname,
                                   subscription=Subscription,
				   tech_seg_code=Seg_co}) ++

        %% Set common provisionning if possible
        case Subscription of
            "mobi" ->                
                Dcl = case Declinaison of
                                  undefined -> ?mobi;
                                  _ -> Declinaison
                              end,                                      
                set_ocf(Imsi, #ocf_test{tac=Tac, 
                                        ussd_level=Ussd_level, 
                                        sub=Subscription,
                                        options=Top_num_list,
                                        msisdn=Msisdn,
                                        tech_seg_code=Seg_co})++
                    set_in_sachem(Imsi,Subscription)++  %% sets sub ets table
                    set_in_spider(Msisdn,Imsi,Subscription,Dcl) ++ %% creates XML files
                    set_comptes(Imsi, Dcl,Option,Comptes,Opts)++ %%what is Opts and OPT
                    insert_list_top_num(sachem_server:intl_to_nat(Msisdn),Top_num_list);
            "cmo" ->
                Dcl = case Declinaison of
                          undefined -> ?ppola;
                          _ -> Declinaison
                      end,    
                set_ocf(Imsi, #ocf_test{tac=Tac, 
                                        ussd_level=Ussd_level, 
                                        sub=Subscription,
                                        options=Top_num_list,
                                        msisdn=Msisdn,
                                        tech_seg_code=Seg_co})++
                    set_in_sachem(Imsi,Subscription)++  %% sets sub ets table
                    set_in_spider(Imsi,Subscription,Dcl)++ %% creates XML files
                    set_comptes(Imsi, Dcl,Option,Comptes,Opts)++ %%what is Opts and OPT
                    insert_list_top_num(sachem_server:intl_to_nat(Msisdn),Top_num_list) ++
                    case Code_so of
                        undefined -> [];
                        _ ->
                            asmserv_init(Msisdn, Code_so)
                    end;
            Else ->
                io:format("~n~n*********unsupported subscription yet:~p****** ~n~n",[Subscription])
        end.

get_imei_from_ussd_level(Ussd_level) ->
    case Ussd_level of
        undefined ->"100008XXXXXXX1";
        1 ->"100008XXXXXXX1";
        2 ->"100006XXXXXXX2";
        3 ->"100005XXXXXXX3"
    end.

%% +type start_session(string()) -> list().
start_session(IMSI) ->
    ["Start session"] ++
	[{msaddr, {subscriber_number, private, IMSI}}] ++
	set_ocf(IMSI) ++
	[{ussd2, [{send, "#121*#"},{expect, ".*"}]}] ++
	[{pause, 1000}] ++
	[].

%% +type close_session(string()) -> list().
close_session() ->
    ["Close session",
%      {ussd2, [ {send, "#128*13#"}, {expect, "Closing"} ]},
     {ussd2, [ {send, "#128*13#"}]},
     {pause, 1000}
    ].

%%%OMA MANIPULATION FUNCTIONS%%%

get_env(App,Args) ->
    {ok, V} = rpc(application, get_env, [App, Args]),
    V.

%% +type rset_env(atom(), atom(), term()) -> *.
rset_env(App, Var, Val) ->
    rpc(application, set_env, [App, Var, Val]).

set_env(A,P,V) -> 
    rpc:call(possum@localhost, oma_config, change_param, [A,P,V]),
    [].
lt2unixt(LT) -> svc_util_of:local_time_to_unixtime(LT).

get_present_period()->
    DT = calendar:local_time(),
    GS = calendar:datetime_to_gregorian_seconds(DT),
    DT0 = calendar:gregorian_seconds_to_datetime(GS - 100),
    DT1 = calendar:gregorian_seconds_to_datetime(GS + 24 * 60 * 60),
    {DT0, DT1}.

get_past_period() ->
    {{{2005,5,10},{0,0,0}},{{2005,5,11},{23,59,59}}}.

get_past_date()->
    lt2unixt(element(1,get_past_period())).
  
set_present_period(Key, Subkey) when is_atom(Subkey) ->
    set_period(Key, Subkey, [get_present_period()]);
set_present_period(Key, Subkeys)  when is_list(Subkeys)->
    lists:foreach(fun(Subkey) -> set_present_period(Key, Subkey) end, Subkeys).

set_past_period(Key, Subkey) when is_atom(Subkey) ->
    set_period(Key, Subkey, [get_past_period()]);
set_past_period(Key, Subkeys)  when is_list(Subkeys)->
    lists:foreach(fun(Subkey) -> set_past_period(Key, Subkey) end, Subkeys).

set_period(Key, Subkey, Value) when is_atom(Subkey)->
    Period_list = get_env(pservices_orangef, Key),
    case lists:keysearch(Subkey, 1, Period_list) of
	{value, _} ->
	    Modified_period_list = lists:keyreplace(Subkey, 1, Period_list, {Subkey, Value}),
	    set_env(pservices_orangef, Key, Modified_period_list);
	Else ->
	    io:format("test_util_of:set_period: Key:~p~n, Subkey:~p~n, Value:~p~n",
		      [Key, Subkey, Value]),
	    []
    end;
set_period(Key, Subkeys, Value) when is_list(Subkeys)->
    lists:foreach(fun(Subkey) -> set_period(Key, Subkey, Value) end, Subkeys).

set_present_period_for_test(Parameter,DatesList)->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
		    set_present_period,[Parameter,DatesList]]}
      ]}].

set_present_period_for_test(Parameter)->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
		    set_env,[pservices_orangef,Parameter,test_util_of:get_present_period()]]}
      ]}].

set_past_period_for_test(Parameter,DatesList)->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
		    set_past_period,[Parameter,DatesList]]}
      ]}].

set_past_period_for_test(Parameter)->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,test_util_of,
		    set_env,[pservices_orangef,Parameter,test_util_of:get_past_period()]]}
      ]}].

set_parameter_for_test(Parameter,Value)->
    set_parameter_for_test(pservices_orangef,Parameter,Value).
set_parameter_for_test(Application,Parameter,Value)->
     [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,test_util_of,
 		    set_env,[Application,Parameter,Value]]}
       ]}].

regexp_date()->
    "[0-3][0-9]/[0-1][0-9]/[0-1][0-9]".

init_day_hour_range() ->
    HourRange = get_env(pservices_orangef, plage_horaire),
    HourRange2 = lists:map(fun({N,_}) -> {N,[{{0,0,0},{23,59,59}, 
					      [lundi, mardi, mercredi,
					       jeudi, vendredi, samedi,
					       dimanche]}]}
			   end,
			   HourRange),

    set_parameter_for_test(plage_horaire, HourRange2).


%%%OMA CONFIGURATION VALIDATION FUNCTIONS%%%

compare_configs(Element,ConfigA,ConfigB) ->
    EnvDiff=oma_config:make_diff_config(ConfigA,ConfigB),
    case lists:keysearch(Element,1,EnvDiff) of
	{value,{Element,EnvDiff2}} ->
	    lists:map(fun({A,B})->A end,EnvDiff2);
	false ->
	    [];
	_ ->
	    error
    end.

double_compare_configs(Element,ConfigA,ConfigB) ->
    ConfigA2=oma_config:sort_env(ConfigA),
    ConfigB2=oma_config:sort_env(ConfigB),
    FirstEnvDiff=compare_configs(Element,ConfigA2,ConfigB2),
    SecondEnvDiff=compare_configs(Element,ConfigB2,ConfigA2),
    TotalEnvDiff=FirstEnvDiff++SecondEnvDiff,
    TotalEnvDiff2=lists:usort(TotalEnvDiff),
    io:format("~p~n",[TotalEnvDiff2]).

%Compare the current configuration to the one contained in a file
compare_to_file_config(Element,FilePath) ->
    LocalEnv=oma_config:get_config(),
    case file:consult(FilePath) of
	{ok,[FileHandler]}->
	    FileEnv=oma_config:override_env([], FileHandler),
	    double_compare_configs(Element,LocalEnv,FileEnv);
	_ ->
	    error
    end.
    
%Compare the current configuration to the one contained in the app files
compare_to_app_file_config(Element) ->
    LocalEnv=oma_config:get_config(),
    AppFileEnv=oma_config:read_boot_config(),
    double_compare_configs(Element,LocalEnv,AppFileEnv).

%%%CONNECTION FUNCTIONS%%%
%% +type connect(string()) -> list().
connect(smppasn) ->
    {connect_smppasn, {"localhost", 7432}};
connect(smpp) ->
    {connect_smpp, {"localhost", 7431}}.

%% +type connect() -> tuple().
connect()->
    [connect(smppasn)].

switch_interface_status(Name,Status)->
    [case Status of 
	 enabled ->
	     "Connexion";
	 disabled -> 
	     "Deconnexion"
     end ++
     " de l'interface " ++ atom_to_list(Name)] ++
	[{erlang_no_trace, 
	  [{rpc, call, [possum@localhost,
			pcontrol,
			case Status of
			    enabled -> enable_itfs;
			    disabled -> disable_itfs
			end,
			[[Name,possum@localhost]]]}
	  ]}] ++

	%%The pause duration must be greater than pdist:pool_polling_delay
	[{pause, 5000}] ++
	
	[].

%%%DATABASE INITIALISATION FUNCTIONS%%%
%% +type init_test( string()) -> list().
init_test(IMSI) ->
    init_test(IMSI, "mobi").

%% +type init_test( string(),string()) -> list().
init_test(IMSI, SUB) ->
    init_test(IMSI, SUB, 1).

%% +type init_test( {imsi,         string()} |string(), 
%%                  {subscription, string()} |string(), 
%%                  {vlr_number,   string()} |string()) -> list().
init_test({imsi,IMSI},
 	  {subscription,SUB},
 	  {vlr_number,VLR}) ->
    insert_imsi_db(IMSI) ++
 	change_subscription(IMSI, SUB) ++
 	change_navigation_to_niv(1, IMSI) ++
 	set_imei(IMSI,null) ++
	set_vlr(VLR);
init_test(IMSI, SUB, NAV) ->
    init_test(IMSI, SUB, NAV, null).

%% +type init_test( {imsi,             string()}|string(), 
%%                  {subscription,     string()}|string(),
%%                  {navigation_level, integer()}|integer(),
%%                  {vlr_number,       string()}|string()) -> list().
init_test({imsi,IMSI},
	  {subscription,SUB},
	  {navigation_level,NAV},
	  {msisdn,MSISDN}) ->
    insert_imsi_db(IMSI) ++
	change_msisdn(IMSI,MSISDN) ++
	change_subscription(IMSI, SUB) ++
	change_navigation_to_niv(NAV, IMSI) ++
	set_imei(IMSI,null);
init_test({imsi,IMSI},
	  {subscription,SUB},
	  {msisdn,MSISDN},
	  {imei,IMEI}) ->
    insert_imsi_db(IMSI) ++
	change_msisdn(IMSI,MSISDN) ++
	change_subscription(IMSI, SUB) ++
	set_imei(IMSI,IMEI);
init_test(IMSI, SUB, NAV, IMEI) ->
    init_test(IMSI, SUB, NAV, IMEI, []).

%% +type init_test( string(),string(), integer(), string(), string()) -> list().
init_test(IMSI, SUB, NAV, IMEI, VLR) ->
    insert_imsi_db(IMSI) ++
	change_subscription(IMSI, SUB) ++
	change_navigation_to_niv(NAV, IMSI) ++
	set_imei(IMSI,IMEI) ++
	set_vlr(VLR)++
    [].

set_vlr(VLR)->
    case VLR of
	[] -> [];
	_ -> [{vlr_number,VLR}]
    end.

%%%% opening and closing a session with an imsi which does not exist in the bd
%%%% enables the insertion of this imsi in the db
%% +type insert_imsi_db(string()) -> list().
insert_imsi_db(IMSI) ->
    start_session(IMSI) ++
    close_session().

set_mysql_profile(#sql_profile{msisdn=Msisdn, 
                               imsi=Imsi,
                               imei=Imei,
                               language=Lang,
                               realname=Realname,
                               subscription=Subscription}) ->
    remove_mysql_profile({"msisdn",Msisdn}) ++
    remove_mysql_profile({"imsi",Imsi})++
    insert_mysql_profile(#sql_profile{msisdn=Msisdn, 
                                      imsi=Imsi,
                                      imei=Imei,
                                      language=Lang,
                                      realname=Realname,
                                      subscription=Subscription}).

remove_mysql_profile({Field_name, Field_value}) ->
    ["Remove mysql profile:"++ Field_value,      
     {shell_no_trace,
      [ {send, "mysql -u possum -ppossum -B -vv -e "
         "\"DELETE FROM users WHERE " ++ 
         Field_name ++
         "=\'" ++ Field_value ++ "\'"++
         "\" mobi"
        },
        {expect, "Query OK.*"}
       ]}
    ].

insert_mysql_profile(#sql_profile{msisdn=Msisdn, 
                                  imsi=Imsi,
                                  imei=Imei,
                                  language=Lang,
                                  realname=Realname,
                                  subscription=Subscription,
				  tech_seg_code=Tech_Seg}) ->
    Profile=rpc:call(possum@localhost,db,
		     create_anon,[[{msisdn,Msisdn}, 
				   {imsi,Imsi}]]),
    Profile1=rpc:call(possum@localhost,db,
		      unanon_profile,[
				      Profile#profile{
					imei=Imei,
					lang=Lang,
					subscription=Subscription}]),
    Profile2=
	case Tech_Seg of
	    undefined -> 
		svc_util_of:set_tech_seg_int_profile(Profile1,1);
	    _ ->
		Tech_Seg_int =     
		    case ocf_rdp:tech_seg_code_to_int(Tech_Seg) of
			not_found ->
			    exit({set_tech_seg_code, unknown_tech_seg_code});
			TSI ->
			    TSI
		    end,
		svc_util_of:set_tech_seg_int_profile(Profile1,Tech_Seg_int)
	end,
    
    ["Set mysql profile:"
     " Msisdn: "++ print_undef(Msisdn) ++ 
     " Imsi: " ++ Imsi ++ 
     " Subscription: " ++ print_undef(Subscription) ++ 
     " Tech Seg: " ++ print_undef(Tech_Seg) ++
     " Ignored:" ++ print_undef(Realname)] ++
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,provisioning_ftm,
		    insert_profile,[Profile2]]}
      ]}].
    
print_undef(undefined) ->
    "undefined";
print_undef(Other) ->
    Other.

%% to be called by rpc on a running Cellcube
build_and_insert_real_profile(Idents) ->
    insert_real_profile(build_real_profile(Idents)).

%% to be called by rpc on a running Cellcube
build_real_profile(Idents) ->
    db:unanon_profile(db:create_anon(Idents)).

%% to be called by rpc on a running Cellcube
insert_real_profile(Profile) ->
    provisioning_ftm:insert_profile(Profile).
    
%% +type change_subscription( string(),string() ) -> list().
change_subscription(IMSI,SUB) ->
    ["La souscription de l'IMSI " ++ IMSI ++ " devient " ++ SUB,
     {shell_no_trace,
      [ {send, "mysql -u possum -ppossum -B -vv -e "
	 "\"UPDATE users SET subscription='"++SUB++"'"
	 " WHERE imsi='"++IMSI++"'\" mobi"},{expect, ".*"}
       ]}
    ].

%% +type change_msisdn( string(),string() ) -> list().
change_msisdn(IMSI,MSISDN)->
    [
     "Le MSISDN de l'IMSI " ++ IMSI ++ " devient " ++ MSISDN,
     {shell_no_trace,
      [ {send, "mysql -u possum -ppossum -B -vv -e "
	 "\"UPDATE users SET msisdn='"++MSISDN++"'"
	 " WHERE imsi='"++IMSI++"'\" mobi"},{expect, ".*"}
       ]}
    ].

change_navigation_to_niv1(IMSI) ->
    change_navigation_to_niv(1, IMSI).
change_navigation_to_niv2(IMSI) ->
    change_navigation_to_niv(2, IMSI).
change_navigation_to_niv3(IMSI) ->
    change_navigation_to_niv(3, IMSI).

change_navigation_to_niv(Level, IMSI) ->
    set_imei(IMSI,
	     case Level of 
		 1 ->"35061310100006";
		 2 ->"100006XXXXXXX2";
		 3 ->"100005XXXXXXX3"
	     end).

set_imei(IMSI,IMEI) ->
    case IMEI of
	null -> [];
	_ ->
	    ["L'IMEI de l'IMSI " ++ IMSI ++ " devient " ++ IMEI,
	     {shell_no_trace,
	      [ {send, "mysql -u possum -ppossum -B -vv -e "
		 "\"UPDATE users SET imei='"++IMEI++"'"
		 " WHERE imsi='"++IMSI++"'\" mobi"},
		{expect, ".*"},
		{send, "mysql -u possum -ppossum  -B -e "
		 "\"SELECT imei from  users where imsi='"++IMSI++"'\" mobi"},
		{expect,IMEI}
	       ]}
	    ]
    end.

%%%HANDSET FUNCTIONS%%%
imei(unknown) ->
     "";
imei(Type) ->
     terminal_of:imei(tac(Type), 1).

tac(wap_push) ->
      Tac = "35437500",
      wap_push = wap_push_capability:tac(Tac),
      Tac;
tac(no_wap_push) ->
      Tac = "12345678",
      unknown = wap_push_capability:tac(Tac),
      Tac.

%%%OCF FUNCTIONS%%%
rpc_insert(ocf_test, IMSI, MSISDN, SUB) ->
    rpc_insert(ocf_test, IMSI, MSISDN, SUB, "012345").
rpc_insert(ocf_test, IMSI, MSISDN, SUB, TAC) ->
    {rpc, call, [possum@localhost,ets,
		 insert,[ocf_test,{IMSI,#ocf_test{
				     msisdn=MSISDN,
				     tac=TAC,
				     ussd_level=1,
				     sub=SUB}}]]}.

set_ocf(IMSI)->
    [
     {erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
 		    insert,[ocf_test,{IMSI,
 				      #ocf_test{tac="012345",
 						ussd_level=2,
 						sub="postpaid"}}]]}]}
    ].

set_ocf(Imsi, #ocf_test{tac=Tac, 
                        ussd_level=Level, 
                        sub=Sub,
                        options=Opt_list,
                        msisdn=Msisdn,
                        tech_seg_code=SegCo}) ->
    Ocf_test = #ocf_test{tac="012345",
                         ussd_level=Level,
                         sub=Sub,
                         options=Opt_list},
    Set_msisdn = case Msisdn of
                     undefined ->
                         [] ;
                     "+"++_ ->
                         [{erlang, 
                           [{net_adm, ping,[possum@localhost]},
                            {rpc, call, 
                             [possum@localhost,ets,insert,
                              [ocf_test,
                               [{Msisdn, Ocf_test}]
                              ]]}]}]
                 end,
    Set_msisdn ++
        [{erlang, 
          [{net_adm, ping,[possum@localhost]},
           {rpc, call, [possum@localhost,ets,insert,
                        [ocf_test,
                         [{Imsi, Ocf_test}]
                        ]]}]}].

ocf_test(MSISDN,Opt_list)->
     %% Configuration of the OCF answer
     [{erlang, 
          [
           {net_adm, ping,[possum@localhost]},
           {rpc, call, [possum@localhost,ets,
                        insert,
                        [ocf_test,{MSISDN,#ocf_test{options=Opt_list}}]
                        ]}
           ]}
     ].

ocf_set(IMSI,SUB) ->
    [{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   rpc_insert(ocf_test, IMSI, [], SUB)
	  ]}].
ocf_set(IMSI,"+"++MSISDN,SUB) ->
    [{erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   rpc_insert(ocf_test, IMSI, MSISDN, SUB)
	  ]}].


%%%SACHEM FUNCTIONS%%%

connect_sachem_fake(Subscription)->
    switch_interface_status(sachem_fake(Subscription),enabled).

disconnect_sachem_fake(Subscription)->
    switch_interface_status(sachem_fake(Subscription),disabled).

send_a4(Imsi) ->
    ["requete A4",
     {sdp,
      [ {send, "A4 3 "++Imsi},
	{expect, "."}
       ]}
    ].
 
    

%% +type set_in_spider(string(),atom()) -> list().
set_in_spider(IMSI,Subscription,DCL)->
    test_util_spider:build_and_insert_xml(IMSI, list_to_atom(Subscription),integer_to_list(DCL)).

set_in_spider(IMSI,Subscription,Response,DCL) 
  when Response==pas_reponse;Response==suivi_conso_plus  ->
    test_util_spider:build_and_insert_xml(IMSI, list_to_atom(Subscription),Response,integer_to_list(DCL));
set_in_spider(MSISDN,IMSI,Subscription,DCL) 
  when Subscription =="mobi";Subscription =="cmo";Subscription =="postpaid"->	
    test_util_spider:build_and_insert_xml(MSISDN, IMSI, list_to_atom(Subscription),integer_to_list(DCL));
set_in_spider(IMSI,Subscription,Config,DCL) 
  when is_list(Config)->	
    test_util_spider:build_and_insert_xml(IMSI, list_to_atom(Subscription),Config,integer_to_list(DCL)).

%% +type set_in_sachem(string(),atom()) -> list().
set_in_sachem(IMSI,Subscription) ->	
    [{erlang,
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[sub,
			    [{IMSI,Subscription}]]]}
      ]}].

set_in_sachem(IMSI,MSISDN,Subscription) ->	
    [{erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[sub,
			    [{IMSI,Subscription},
			     {MSISDN,Subscription}]]]}
      ]}].

delete_in_sachem(Item)->
    [{erlang, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    match_delete,[sub,{Item,'_'}]]}
      ]}].
sachem_fake(tele2_comptebloque)->
    io_sach_cmo_fake;
sachem_fake(virgin_comptebloque)->
    io_sach_cmo_fake;
sachem_fake(cmo)->
    io_sach_cmo_fake;
sachem_fake(bzh_cmo)->
    io_sach_cmo_fake;
sachem_fake(Subscription)->
    io_sach_mobi_fake.

rpc_insert(sdp_compte, {msisdn, MSISDN}, TOP_NUM_LIST) ->
    {rpc, call, [possum@localhost,ets,
		 insert,[sdp_compte,{{top_num_list,MSISDN},TOP_NUM_LIST}]]};
rpc_insert(sdp_compte, {imsi, IMSI}, TOP_NUM_LIST) ->
    {rpc, call, [possum@localhost,ets,
		 insert,[sdp_compte,{IMSI,TOP_NUM_LIST}]]}.

modifier_godet(DOSNUM,GODET,PTF_NUM,ETAT,DLV,RNV_NUM)
  when list(DOSNUM),integer(PTF_NUM),integer(DLV),integer(RNV_NUM) ->
    ["MODIF GODET "++atom_to_list(GODET)++" EN "++integer_to_list(PTF_NUM)
     ++" "++atom_to_list(ETAT),
     {tlv,
      [{send,tlv_encodage:encode_packet(?P_MOBI,?int_id07,
					[{?ACI_NUM,?Val_ACI_NUM},
					 {?DOS_NUMID,list_to_integer(DOSNUM)},
					 {?TCP_NUM,godet2int(GODET)},
					 {?PTF_NUM,PTF_NUM},
					 {?ECP_NUM,ecpnum_atom2int(ETAT)},
					 {?CPP_DATE_LV,DLV},
					 {?RNV_NUM,RNV_NUM}])},
       {expect2, "."}]}].

supprimer_godet(DOSNUM,GODET) when list(DOSNUM) ->
    ["SUPPRESSION DU GODET "++atom_to_list(GODET),
     {tlv,
      [{send,tlv_encodage:encode_packet(?P_MOBI,?int_id08,
					[{?ACI_NUM,?Val_ACI_NUM},
					 {?DOS_NUMID,list_to_integer(DOSNUM)},
					 {?TCP_NUM,godet2int(GODET)}])},
       {expect2, "."}]}
    ].

creer_godet(DOSNUM,GODET,ETAT,SOLDE,DLV,RNV_NUM)
  when list(DOSNUM),
       integer(SOLDE),integer(DLV),integer(RNV_NUM) ->    
    ["CREATION DU GODET "++atom_to_list(GODET)
     ++" "++atom_to_list(ETAT)++" "++integer_to_list(SOLDE),
     {tlv,
      [{send,tlv_encodage:encode_packet(?P_MOBI,?int_id06,
					[{?ACI_NUM,?Val_ACI_NUM},
					 {?DOS_NUMID,list_to_integer(DOSNUM)},
					 {?TCP_NUM,godet2int(GODET)},
					 {?ECP_NUM,ecpnum_atom2int(ETAT)},
					 {?CPP_SOLDE,SOLDE},
					 {?CPP_DATE_LV,DLV},
					 {?RNV_NUM,RNV_NUM}])},
       {expect2, "."}]}
    ].

modifier_etat_sec(DOSNUM,NEWETAT)
  when list(DOSNUM),integer(NEWETAT) ->
    ["MODIFI DE L ETAT SEC EN "++integer_to_list(NEWETAT),
     {tlv,
      [{send,tlv_encodage:encode_packet(?P_MOBI,?int_id12,
					[{?ACI_NUM,?Val_ACI_NUM},
					 {?DOS_NUMID,list_to_integer(DOSNUM)},
					 {?ESC_NUM_BIN,NEWETAT}])},
       {expect2, "."}]}
    ].

godet2int(principal) -> 1.

ecpnum_atom2int(actif) -> 1;
ecpnum_atom2int(epuise) -> 2;
ecpnum_atom2int(perime) -> 3.

insert(IMSI,DCL,OPT,COMPTES)->
    insert(IMSI,DCL,OPT,COMPTES,[]).
insert(IMSI,DCL,OPT,COMPTES,Opts)->
    [{erlang_no_trace,
      [
       {net_adm, ping,[possum@localhost]},
       rpc_insert(sdp_compte, {imsi, IMSI}, {{DCL,OPT,COMPTES}, Opts})
     ]}
     ].

insert(cmo, IMSI, DCL, OPT, COMPTES, Opts, Tac)->
    [insertt(cmo, IMSI, DCL, OPT, COMPTES, Opts, Tac)].
insertt(cmo, IMSI, DCL, OPT, COMPTES, Opts, Tac)->
    {erlang, 
     [{net_adm, ping,[possum@localhost]},
      rpc_insert(sdp_compte, {imsi, IMSI}, {{DCL,OPT,COMPTES}, Opts}),  
      rpc_insert(ocf_test, IMSI, [], "cmo", Tac)
     ]}.

%% replaces insert/5
set_comptes(IMSI,DCL,OPT,COMPTES,Opts)->
    [{erlang_no_trace,
      [
       {net_adm, ping,[possum@localhost]},
       rpc_insert(sdp_compte, {imsi, IMSI}, {{DCL,OPT,COMPTES}, Opts})
      ]}
    ].

insert_list_top_num(MSISDN,TOP_NUM_LIST) ->
    ["Insert Top num list into sdp_compte"] ++
    [{erlang_no_trace,
      [
       {net_adm, ping,[possum@localhost]},
       rpc_insert(sdp_compte, {msisdn, MSISDN}, TOP_NUM_LIST)
     ]}
     ].
insert_list_top_num_and_dates(MSISDN,TOP_NUM_LIST,DATE_SOUSCR,DEB,FIN)->
    [{erlang,
      [
       {net_adm, ping,[possum@localhost]},
       rpc_insert(sdp_compte, {msisdn, MSISDN}, {TOP_NUM_LIST, DATE_SOUSCR,DEB,FIN,0,0}) 
     ]}
     ].
insert_list_top_num_and_opt_info2(MSISDN,TOP_NUM_LIST,OPT_INFO2)->
    [{erlang,
      [
       {net_adm, ping,[possum@localhost]},
       rpc_insert(sdp_compte, {msisdn, MSISDN}, {TOP_NUM_LIST, 0,0,0,0, OPT_INFO2})
     ]}
     ].
insert_list_top_num_and_c_op_fields(MSISDN,TOP_NUM_LIST,
				    SOUSCR,DEB,FIN,OPT_INFO_1,OPT_INFO2)->
    [{erlang,
      [
       {net_adm, ping,[possum@localhost]},
       rpc_insert(sdp_compte, {msisdn, MSISDN},
		  {TOP_NUM_LIST, SOUSCR, DEB, FIN, OPT_INFO_1, OPT_INFO2})
     ]}
     ].

%%%AS METIER FUNCTIONS%%%
asmserv_init(MSISDN, ACTIV_OPTs)->
    %% Redirect to the appropriate webservices_server/postpaid_cmo file 
     [
      {erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost, file,
			copy, [?PATH++"GETIDENT_"++MSISDN++"_"++ACTIV_OPTs++".xml", 
				 ?PATH++"GETIDENT_"++MSISDN++".xml"]]},
  	   {rpc, call, [possum@localhost, file,
  			copy, [?PATH++"SETSERVOPT_oee_"++MSISDN++".xml",
  			       ?PATH++"SETSERVOPT_oee_"++MSISDN++"_"++ACTIV_OPTs++".xml"]]}
	   ]}
     ].

asmserv_restore(MSISDN, ACTIV_OPTs)->
    %% Restore the webservices_server/postpaid_cmo file 
     [
      {erlang, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost, file,
			delete, [?PATH++"GETIDENT_"++MSISDN++".xml"]]},
  	   {rpc, call, [possum@localhost, file,
  			delete, [?PATH++"SETSERVOPT_oee_"++MSISDN++"_"++ACTIV_OPTs++".xml"]]}
	   ]}
     ].

%%%SPIDER FUNCTIONS%%%
spider_test_init(MSISDN,IMSI,SUB)->

    MSISDN_NAT = case MSISDN of
		     "+33"++NAT->
			 "0"++NAT;
		     "+99"++NAT->
			 "0"++NAT;
		     _MSISDN_NAT->
			 _MSISDN_NAT
		 end,

    test_spider:init_data_test(MSISDN_NAT,IMSI,SUB,
				    [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
				     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
				    [{bundle,
				      [{priorityType,"A"},
				       {restitutionType,"FORF"},
				       {bundleType,"0005"},
				       {bundleDescription,"label forf"},
				       {reactualDate, "2005-06-05T07:08:09.MMMZ"},
				       {bundleAdditionalInfo, "I1|I2|I3"},
				       {credits,
					[{credit,[{name,"balance"},{unit,"MMS"},{value,"40"}]},
					 {credit,[{name,"rollOver"},{unit,"SMS"},{value,"18"}]},
					 {credit,[{name,"bonus"},{unit,"TEMPS"},{value,"2h18min48s"}]}]}]}]).

spider_test_init(MSISDN,IMSI,SUB,BUNDLES) ->
    MSISDN_NAT = case MSISDN of
                     "+33"++NAT->			 
                         "0"++NAT;
		     "+99"++NAT-> 
			 "0"++NAT;
                     _MSISDN_NAT->
                         _MSISDN_NAT
                 end, 
    test_spider:init_data_test(MSISDN_NAT,IMSI,SUB,
			       [{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
				{amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
			       BUNDLES).

spider_test_init(MSISDN,IMSI,SUB,AMOUNTS,BUNDLES) ->	
    MSISDN_NAT = case MSISDN of
                     "+33"++NAT->
						 
                         "0"++NAT;
					 "+99"++NAT->             "0"++NAT;
                     _MSISDN_NAT->
                         _MSISDN_NAT
                 end,
    test_spider:init_data_test(MSISDN_NAT,IMSI,SUB,AMOUNTS,BUNDLES).

spider_test_init(MSISDN,IMSI,SUB,FILESTATE,AMOUNTS,BUNDLES) ->
	MSISDN_NAT = case MSISDN of
                     "+33"++NAT->						 
                         "0"++NAT;
					 "+99"++NAT->
						 "0"++NAT;
                     _MSISDN_NAT->
                         _MSISDN_NAT
                 end,
	test_spider:init_data_test(MSISDN_NAT,IMSI,FILESTATE,SUB,"",AMOUNTS,BUNDLES).

%%%EXPECTED TEXT MANIPULATION FUNCTIONS%%%

%% +type expected_text(MFA::{atom(),atom(),[T]}) -> string().
expected_text({Mod,Fun,Args}) ->
    Text = rpc:call(possum@localhost,Mod, Fun, Args),
    case regexp:gsub(Text, "[()+?]", ".*") of
	{ok, NewString, RepCount} -> 
	    remove_date(NewString);
	_ ->
	    ""
    end.

%% +type remove_date(Text::string()) -> string().

remove_date(Text) ->
    case regexp:gsub(Text, 
		     "\([0-3][0-9]/[0-1][0-9]/[0-1][0-9]\)", 
		     "../../..") of
	{ok, NewString, RepCount} ->
	    remove_line_feed(NewString);
	_ ->
	    ""
    end.

%% +type remove_line_feed(Text::string()) -> string().

remove_line_feed(Text) ->
    case regexp:gsub(Text, "\\n", ".*") of
	{ok, NewString, RepCount} ->
	    NewString;
	_ ->
	    ""
    end.

send_exp(S,E) -> [{send, S},
		  {expect, ?NOT_SPLITTED},
		  {expect, E}].


%% +type list_position(Link_name::atom(), List::list()) ->
%%                          list().
%%%% Returns the element's position in a list
list_position(Element, []) ->
    "";
list_position(Element, List) ->
    Position = lists:seq(1,length(List)), % Position = 1..6
    Nth = fun(N) ->
		  case lists:nth(N, List) == Element of      % Element(Position)
		      true -> N;
		      _ -> 0
		  end
	  end,
    List_output = lists:map(Nth, Position),
    Link = lists:foldl(fun(X, Sum) -> X + Sum end, 0, List_output),
    integer_to_list(Link).


check_wap_push_sent(first)->
    "=======SIMULATION OF RECEIPT OF SMS WAP PUSH WITH LOGO====";
check_wap_push_sent(last)->
    {erlang, [{?MODULE, assert_received, []}]};
check_wap_push_sent(_)->
    "".
assert_received() ->
    [_] = smsloop_client:purge(),
    ok.


%%Redirect mvno function test
test_redir_mvno()->
    Session=create_session("virgin_gp",1),
    {redirect, _, "http://virgin_gp/xml_suiviconso.php"}=
	svc_util_of:redir_mvno(Session,"virgin_gp","#temporary"),
    Session1=create_session("bzh_gp",1),
    {redirect, _, "http://bzh_gp/xml_suiviconso.php"}=
	svc_util_of:redir_mvno(Session1,"bzh_gp","#temporary"),
    ok.

%%%SESSION MANIPULATION FOR UNIT TEST FUNCTIONS%%%

create_session(Subscription, Phase) ->
    #session{bearer={ussd,Phase},
 	     prof=#profile{subscription=Subscription},
 	     billing=billing_standard_of,
 	     svc_data=[{user_state,#sdp_user_state{}}]}.

create_session(Subscription, DCL, Phase) ->
    #session{bearer={ussd,Phase},
	     prof=#profile{subscription=Subscription},
	     billing=billing_standard_of,
	     svc_data=[{user_state,#sdp_user_state{declinaison=DCL}}]}.
    
start_unit_test() ->
    application:start(pservices_orangef),
    application:start(pfront_orangef),
    application:start(pdist_orangef).

create_session_tux() ->
    create_session_tux("mobi").

create_session_tux(Subscription) ->
    Session = #session{prof = #profile{msisdn = "0612345678",
                                      subscription = Subscription}},  
    variable:update_value(Session, user_state, 
                          #sdp_user_state{dos_numid=123456789}).

set_tux_params() ->
    application:set_env(pfront_orangef,sachem_version, offline).

set_sdp_user_state_cmo(Session, DCL, PTF_NUM, DLV, Credit, List_active_opt) ->
    Topnum_list =
	lists:append([case X of
			  none ->[];
			  opt_tt_shuss ->
			      [top_num_cmo(opt_tt_shuss_voix),
			       top_num_cmo(opt_tt_shuss_sms)];
			  opt_pass_vacances ->
			      [top_num_cmo(opt_pass_vacances_moc)];
			  _ -> [top_num_cmo(X)]
		      end || X <- List_active_opt]),
    State = #sdp_user_state{declinaison=DCL,
			    cpte_princ=
			    #compte{tcp_num=?C_PRINC,
				    unt_num=?EURO,
				    cpp_solde={sum,euro,Credit},
				    dlv=DLV,
				    rnv=0,
				    etat=?CETAT_AC,
				    ptf_num=PTF_NUM},
			    d_activ=
			    test_util_of:lt2unixt({date(),{0,0,0}})+86400,
			    topNumList=Topnum_list,
			    tmp_recharge=#recharge_cb_cmo{}},
    svc_util_of:update_user_state(Session, State).

top_num_cmo(Opt) -> 
    svc_options:top_num(Opt,cmo).

to_nat(MSISDN) ->
    MSISDN_NAT = case MSISDN of
		     "+33"++NAT->
			 "0"++NAT;
		     "+99"++NAT->
			 "0"++NAT;
		     _MSISDN_NAT->
			 _MSISDN_NAT
		 end.

reset_prisme_counters(Prisme_counters_list) ->    
    Res = rpc:call(possum@localhost, ?MODULE, reset_prisme_counters_local, [Prisme_counters_list]),
    io:format("Res ~p~n", [Res]).

reset_prisme_counters_local(Prisme_counters_list) ->   
    lists:foreach(fun({CodeDomain,CodeKenobi,_}) ->
			  mnesia:dirty_delete(slog_row, {count,prisme_counter,{CodeDomain,CodeKenobi}}) end,
                  Prisme_counters_list).

check_prisme_counters_local(Key, ExpectCounted) ->    
    case mnesia:dirty_read(slog_row, Key) of
	[#slog_row{ranges=Ranges}]->
	    {#slog_data{count=Count}, _} = lists:last(Ranges),
	    if 
		Count == ExpectCounted->
		    ok;
		true->
		    io:format("~p Expected:~p  Got:~p~n", [Key, ExpectCounted, Count]),	    
		    nok
	    end;
	_ ->
	    io:format("~p not found ~n", [Key]),
	    nok
    end.

test_kenobi_unit(Key, ExpectCounted) ->    
   rpc:call(possum@localhost, ?MODULE, check_prisme_counters_local, [Key, ExpectCounted]).

test_kenobi([], {OK,NOK}=Acc) ->
    if 
	NOK>0 ->
	    io:format("~nTest Kenobi result: NOK: ~p; OK: ~p~n",[NOK,OK]),
	    nok;
	true ->
	    io:format("~nTest Kenobi all OK~n",[]),
	    ok
    end;

test_kenobi([{CodeDomain,CodeKenobi,Expected} | ListCases], {OK,NOK}=Acc) ->
    case test_kenobi_unit({count,prisme_counter,{CodeDomain,CodeKenobi}}, Expected) of
       ok -> test_kenobi(ListCases, {OK+1,NOK});
       _ -> test_kenobi(ListCases, {OK,NOK+1})
    end.

test_kenobi(ListCases) ->
    test_kenobi(ListCases, {0,0}).


%% handy for unit tests
unit_test(Module,Function,ListCases) ->
unit_test(Module,Function,ListCases, {0,0}).
unit_test(Module,Function,[], {OK,NOK}=Acc) ->
    Info = atom_to_list(Module)++":"++atom_to_list(Function),
    if NOK>0 ->
	    io:format("~p~nFailed, nb of failure ~p~n",[Info,NOK]),
	    exit({Info,NOK});
       true ->
	    io:format("~nSUCCESS:~n~p~n******~n",[Info]),
	    ok
    end;
unit_test(Module,Function,
     [{CaseArgs, Expect} | ListCases], {OK,NOK}=Acc) ->
    Info = atom_to_list(Module)++":"++atom_to_list(Function)++"("++
	lists:flatten(io_lib:format("~p",[CaseArgs]))++")",
    case test_unit(Info, Expect, catch apply(Module,Function,CaseArgs)) of
       ok -> unit_test(Module,Function,ListCases, {OK+1,NOK});
       nok -> 
	    unit_test(Module,Function,ListCases, {OK,NOK+1})
    end.

test_unit(_,A,A) -> ok;
test_unit(Info,A,B) ->
    io:format("~n~p~nExpected:~n~p~nGot:~n~p~n",[Info,A,B]),
    nok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type access_code(string(), string(), list()) -> string().
%%%% Returns the access code fpr Link_name and Subscription and Dynamic_links
%%%% in the format "#123*1"
%%%% You have to add the final "#"
access_code(Module, []) ->
    io:format("~p : You missed an initialization in :~p~n"
              "\tCheck the function links() and pages()~n",
              [?MODULE, Module]),
    "";
access_code(Module, Link) ->
    access_code(Module, Link, []).

access_code(Module, ?main_page, _) ->
    Module_name=atom_to_list(Module),
    Code=lists:sublist(Module_name,6,3),
    case Module of 
	test_144_opim -> 
	    "*144";
	_ -> 
	    case catch list_to_integer(Code) of
		{'EXIT',_}->"#123";
		_->
		    "#"++Code
	    end
    end;
	
access_code(Module, Link, Dynamic_elements) when atom(Dynamic_elements)->
    access_code(Module, Link,[Dynamic_elements]);

access_code(Module, Link, Dynamic_elements) ->
    Parent = parent(Module, Link),
    ParentModule = apply(Module, parent, [Parent]),
    access_code(ParentModule, Parent, Dynamic_elements) ++ "*" ++
	link_rank(Module, Parent, Link, Dynamic_elements).

parent(Module, Element) ->
    Pages = apply(Module, pages, []),
    get_parent_page(Module, Element, Pages).

get_parent_page(_, _, []) ->
    [];
get_parent_page(Module, Element, [Page|Tail]) ->
    Links = apply(Module, links, [Page]),
    case tuple_rank_in_list(Element, Links) of
        [] ->
            get_parent_page(Module, Element, Tail);
        _ ->
            Page
    end.

%% +type link_rank(string(), string(), list()) -> string().
%%%% Returns the link rank in the Page
%%%% Output format "1"
link_rank(Module, Page, Element) ->
    link_rank(Module, Page, Element, []).

link_rank(Module, Page, Element, Dynamic_links) ->
    Rank = compute_rank(Module, Page, Element, Dynamic_links),
    integer_to_list(Rank).

%% +type compute_rank(string(), string(), list()) -> string().
%%%% Returns the access code fpr Link_name and Subscription and Dynamic_links  
compute_rank(Module, Page, Element, Dynamic_elements) ->
    Page_links_all = apply(Module, links, [Page]),
    Page_links = compute_page_links(Page_links_all, Dynamic_elements),
    tuple_rank_in_list(Element, Page_links).

%% +type compute_menu_links(string(), string(), list()) -> string().
%%%% Returns the access code fpr Link_name and Subscription and Dynamic_links 
compute_page_links(Links, Dynamic_elements) ->
    compute_page_links(Links, Dynamic_elements, []).

compute_page_links([], _, Page_links) ->
    Page_links;
compute_page_links([{Link, static}|Tail], Dynamic_elements, Page_links) ->
    compute_page_links(Tail, Dynamic_elements, Page_links ++ [{Link, static}]);
compute_page_links([{Link, dyn}|Tail], Dynamic_elements, Page_links) ->
    case lists:member(Link, Dynamic_elements) of
        true ->
            compute_page_links(Tail, Dynamic_elements, Page_links ++ [{Link, dyn}]);
        _ ->
            compute_page_links(Tail, Dynamic_elements, Page_links)
    end.

%% +type rank_in_list(atom(), list()) -> integer().
%%%% Gives the rank of an atom Element in a list
tuple_rank_in_list(Element, List) ->
    case tuple_rank_in_list(Element, List, 1) of
        [] ->
            [];
        Rank when integer(Rank) -> Rank
    end.
            

tuple_rank_in_list(_, [], _) ->
    [];
tuple_rank_in_list(Element, [{Head,Type}|Tail], Length) ->
    if Head == Element -> Length;
       true -> tuple_rank_in_list(Element, Tail, Length + 1)
    end.

generate_msisdn_from_uid(Uid) when atom(Uid)->
        generate_msisdn_from_uid(atom_to_list(Uid));
generate_msisdn_from_uid(Uid) when list(Uid)->
    Num=lists:sum(Uid),
    Str=lists:flatten( pbutil:sprintf("%03d",[Num rem 1000])),
    "0900000"++Str.

generate_imsi_from_uid(Uid) when atom(Uid)->    
    generate_imsi_from_uid(atom_to_list(Uid));
generate_imsi_from_uid(Uid) when integer(Uid)->
    generate_imsi_from_uid(integer_to_list(Uid));

generate_imsi_from_uid(Uid) when list(Uid)->
    Num=lists:sum(Uid),
    Str=lists:flatten( pbutil:sprintf("%03d",[Num rem 1000])),
    "999000900000"++Str.

get_top_num(Opt,Sub) ->
    rpc(option_manager,get_orange_id,[{Opt,Sub},top_num]).

get_option_param({Key,Sub},Parameter)->    
    rpc(option_manager,get_orange_id,[{Key,Sub},Parameter]).

set_commercial_date(Opt,Sub,Value) when is_atom(Opt)->    
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,option_manager,
		    set_commercial_date,[{Opt,Sub},Value]]}
       ]}].

set_present_commercial_date(Opt,Sub) when is_atom(Opt)->
    
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,option_manager,
		    set_present_commercial_date,[{Opt,Sub}]]}
       ]}].

set_past_commercial_date(Opt,Sub) ->
    
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,option_manager,
		    set_past_commercial_date,[{Opt,Sub}]]}
       ]}].

reset_commercial_date(Opt,Sub) ->
    
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,option_manager,
		    reset_commercial_date,[{Opt,Sub}]]}
       ]}];
reset_commercial_date(Opts,Sub) ->
    lists:foreach(fun(Opt) -> reset_commercial_date(Opt,Sub) end,Opts).

set_open_hour(Opt,Sub,Value) when is_atom(Opt) ->
     [{erlang_no_trace,
       [{net_adm, ping,[possum@localhost]},
        {rpc, call, [possum@localhost,option_manager,
		     set_open_hour,[{Opt,Sub},Value]]}
        ]}].

set_open_day(Opt,Sub,Value) when is_atom(Opt)->
    [{erlang_no_trace,
     [{net_adm, ping,[possum@localhost]},
     {rpc, call, [possum@localhost,option_manager,
		 set_open_day,[{Opt,Sub},Value]]}
     ]}].
