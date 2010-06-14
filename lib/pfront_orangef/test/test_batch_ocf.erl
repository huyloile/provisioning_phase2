-module(test_batch_ocf).

-export([online/0,run/0]).

-include("../include/ocf_rdp.hrl").
-include("../../pdatabase/include/pdatabase.hrl").
-include("../../pdist/include/generic_router.hrl").
-include("../../pservices_orangef/test/test_util_of.hrl").
-include("../../pserver/include/pserver.hrl").

run()->
    compare(catch batch_ocfrdp:check_ranges([]), ok, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{1, 0}]),
	    {'EXIT', {malformed_elt, {1, 0}}}, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{23, 15}, atom}]),
	    {'EXIT', {malformed_elt, {{23, 15}, atom}}}, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{0, -1}, 1}]),
	    {'EXIT', {incorrect_time, {0, -1}}}, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{24, 15}, 1}]),
	    {'EXIT', {incorrect_time, {24, 15}}}, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{23, 15}, -0.1}]),
	    {'EXIT', {negative_rate, -0.1}}, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{2, 15}, 0.1}, {{2, 14}, 2}]),
	    {'EXIT', {elts_not_sorted, {{2, 15}, {2, 14}}}}, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{0, 0}, 0}]), ok, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{23, 15}, 1}]), ok, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{23, 15}, 1.23}]), ok, ?LINE),
    compare(catch batch_ocfrdp:check_ranges([{{2, 14}, 0.1}, {{2, 15}, 2}]),
	    ok, ?LINE),

    compare(batch_ocfrdp:range_rate([],
				    batch_ocfrdp:day_time({0, 0})),
	    0, ?LINE),
    compare(batch_ocfrdp:range_rate([{{2, 14}, 0.1}, {{2, 15}, 2}],
				    batch_ocfrdp:day_time({0, 0})),
	    0, ?LINE),
    compare(batch_ocfrdp:range_rate([{{0, 0}, 1}, {{2, 15}, 2}],
				    batch_ocfrdp:day_time({0, 0})),
	    1, ?LINE),
    compare(batch_ocfrdp:range_rate([{{2, 14}, 0.1}, {{2, 15}, 2}],
				    batch_ocfrdp:day_time({2, 14})),
	    0.1, ?LINE),
    compare(batch_ocfrdp:range_rate([{{2, 14}, 0.1}, {{2, 15}, 2}],
				    batch_ocfrdp:day_time({2, 14, 59})),
	    0.1, ?LINE),
    compare(batch_ocfrdp:range_rate([{{2, 14}, 0.1}, {{2, 15}, 2}],
				    batch_ocfrdp:day_time({2, 14, 59})),
	    0.1, ?LINE),
    compare(batch_ocfrdp:range_rate([{{2, 14}, 0.1}, {{2, 15}, 2}],
				    batch_ocfrdp:day_time({2, 15, 59})),
	    2, ?LINE),

    ok.

compare(Gotten, Expected, Line) ->
    case Gotten == Expected of
	true ->
	    ok;
	false ->
	    io:format(?MODULE_STRING " line ~p,~ngot ~p~nexp ~p~n",
		      [Line, Gotten, Expected]),
	    halt(1)
    end.

-define(IMSIs,
	["208010000000001","208010000000002","208010000000003",
	 "208010000000004","208010010000005","208010000000006",
         "208010000000005",
	 "208010000000007","208010000000008","208010000000009",
	 "208010000000010","208010000000013","208010000000014",
	 "208010000000015","208010000000016"]).

-define(IMSIs_CONFIG,
	[{"208010000000001", "+33600000001", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000002", "+33600000002", "33219800000483", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000003", "+33600000003", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000004", "+33600000004", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000005", "+33600000005", "000001XXXXXXX1", ?OCF_NO_FIELD, -1, "MOB"},
%%	 {"208010010000005", "+33600000005", "000001XXXXXXX1", -1, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000006", "+33600000006", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "ERGO"},
	 {"208010000000007", "+33600000007", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000008", "+33600000008", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000009", "+33600000009", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000010", "+33600000010", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000011", "+33600000011", "000001XXXXXXX1", ?OCF_NO_FIELD, -1, "MOB"},
	 {"208010000000013", "+33600000013", "00000100000001", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000014", "+33600000014", "00000100000001", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000015", "+33600000015", "00000100000001", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000016", "+33600000015", "00000200000001", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000041", "+33600000042", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"},
	 {"208010000000042", "+33600000041", "000001XXXXXXX1", ?OCF_NO_FIELD, ?OCF_NO_FIELD, "MOB"}
	].

%% Each 3-tuple contains an IMSI, the initial technological segment
%% (-1 indicates that there should be no row in users_orangef_extra) and
%% the expected technological segment after the batch is run (-1 if
%% the user is to be removed by the batch).
-define(OFE_IMSIs,
	[{"208010000000017", ?OCF_DOES_NOT_KNOW, ?OCF_DOES_NOT_KNOW, "TEST"},
	 {"208010000000018", ?OCF_DOES_NOT_KNOW, ?OCF_NO_FIELD, "TEST"},
	 {"208010000000019", ?OCF_DOES_NOT_KNOW,
	  rpc:call(possum@localhost, ocf_rdp, tech_seg_code_to_int,["TRM3G"]), "TEST"},
	 {"208010000000020", ?OCF_DOES_NOT_KNOW, ?OCF_UNKNOWN_CODE, "TEST"},
	 {"208010000000021", ?OCF_DOES_NOT_KNOW, -1, "TEST"},
	 {"208010000000022", -1, ?OCF_DOES_NOT_KNOW, null},
	 {"208010000000023", -1,rpc:call(possum@localhost, ocf_rdp, tech_seg_code_to_int,["TRM3G"]), null},
	 {"208010000000024", -1, -1, "TEST"},
	 {"208010000000025", -1,?OCF_NO_FIELD, null},
	 {"208010000000026", -1,?OCF_NO_FIELD, null},
	 {"208010000000027", -1,?OCF_NO_FIELD, null},
	 {"208010000000028", -1,?OCF_NO_FIELD, null},
	 {"208010000000029", -1,?OCF_NO_FIELD, null},
	 {"208010000000030", -1,?OCF_NO_FIELD, null},
	 {"208010000000031", -1,?OCF_NO_FIELD, null},
	 {"208010000000032", -1,?OCF_NO_FIELD, null},
	 {"208010000000033", -1,?OCF_NO_FIELD, null},
	 {"208010000000034", -1,?OCF_NO_FIELD, null}
	]).

online()->
    %% test daily batch process
    %% 1 -> insert profiles in base
    %% 2 -> pase batch file
    %% 3 -> verify modification in users base
    %% 4 -> delete imsi in use 
    %% 5 -> verify deletion of inactive profiles    
    test_prov(),
    test_prov2(),
    io:format("Test OK~n"),
    ok.

init_data() ->
    %% 1 -> insert profiles in base
    delete_imsi(?IMSIs),
    lists:foreach(fun ({I, _, _, _}) -> delete_of_extra(I) end, ?OFE_IMSIs),
    insert_profile_in_base().
    
test_prov() ->
    init_data(),
    %% to be inserted in both tables
    ToOFInsert    = [X || X = {_, TS, D, C} <- ?OFE_IMSIs, TS /= -1, D /= -1],
    ToOFInsertDel = [X || X = {_, TS, D, C} <- ?OFE_IMSIs, TS /= -1, D == -1],
    %% to be inserted only in users
    ToInsert      = [X || X = {_, TS, D, C} <- ?OFE_IMSIs, TS == -1, D /= -1],
    ToInsertDel   = [X || X = {_, TS, D, C} <- ?OFE_IMSIs, TS == -1, D == -1],
    DelUids = [insert_of_extra(I, TS) || {I, TS, _, _} <- ToOFInsertDel]
      	++    [insert(I)              || {I, _TS, _, _} <- ToInsertDel],
    _Uids =   [insert_of_extra(I, TS) || {I, TS, _, _} <- ToOFInsert]
      	++    [insert(I)              || {I, _TS, _, _} <- ToInsert],
    rpc:call(possum@localhost,application,set_env,
	     [pfront_orangef,authorized_ul_down,false]),
    CMD1="cp ../test/USSD123 ../priv/; cd ../priv; ./batch_ocf_preproc.sh",
    {ok,33,26}=updates(CMD1),
    {ok,0}=deletions(),
    verify_user_state(),
    verify_of_extra(ToInsert ++ ToOFInsert, DelUids),
    lists:foreach(fun  ({IMSI, _, _, OLD_OCF, NEW_OCF, COMMERCIAL}) -> verify_of_extra_aux({IMSI,OLD_OCF,NEW_OCF,COMMERCIAL}) end,
		  ?IMSIs_CONFIG),
    rpc:call(possum@localhost,application,set_env,
      	      [pfront_orangef,authorized_ul_down,true]),
    CMD2="cp ../priv/old/USSD* ../priv/",
    {ok,33,1}=updates(CMD2),
    {ok,0}=deletions(),
    verify_user_state2(),
    delete_imsi(?IMSIs),
    lists:foreach(fun ({I, _, _,_}) -> delete_of_extra(I) end, ?OFE_IMSIs),
    os:cmd("cp ../priv/old/USSD* ../test/"),
    verify_delete_inactive().

test_prov2() ->
    io:format("Insert clients with etat dossier = 10 inconnu in database\n"++
	     "& Delete clients with etat dossier = 60 or 70~n"),
    init_data(),
    rpc:call(possum@localhost,application,set_env,
       	     [pfront_orangef,authorized_ul_down,true]),
    CMD3="cp ../test/USSD123_etatDossier10 ../priv/",
    {ok,11,6}=updates(CMD3),
    io:format("Verify deleting client with etat dossier 60 or 70~n"),
    {ok,0} = deletions(),
    verify_user_state3().


verify_delete_inactive() ->
    io:format("verify_delete_inactive~n"),
    test_util_of:empty_mysql_tables(),
    Profile1=rpc:call(possum@localhost,test_util_of,
		      build_and_insert_real_profile,
		      [[{msisdn,"+33600012301"}, 
			{imsi,"208010000012301"}]]),
    Profile2=rpc:call(possum@localhost,test_util_of,
		      build_and_insert_real_profile,
		      [[{msisdn,"+33600012302"}, 
			{imsi,"208010000012302"}]]),
    Profile3=rpc:call(possum@localhost,test_util_of,
		      build_and_insert_real_profile,
		      [[{msisdn,"+33600012303"}, 
			{imsi,"208010000012303"}]]),
    Date1= pbutil:unixtime(),
    set_stats("208010000012301",Date1),
    set_stats("208010000012302",Date1-2*31*24*3600), %% 2 months
    set_stats("208010000012302",Date1-3*31*24*3600), %% 3 months
    rpc:call(possum@localhost,batch_ocfrdp,
	     delete_old_user,[1,4]), %% remove older than 1 month
    Date1=get_oldest(),
    ok.

    

get_oldest() ->
    CMD="SELECT min(latest) FROM stats",
    try rpc:call(possum@localhost,?SQL_Module,execute_stmt,
		 [CMD,[stats],10000]) of
        {selected,_,[[Oldest]]}-> 
	    case Oldest of
		"0" -> pbutil:unixtime();
		Date -> list_to_integer(Date)
	    end;
	Else -> 
	    io:format("Else:~p~n",[Else]),
	    pbutil:unixtime()
    catch Tag:Value ->  
	    io:format("Tag:Value:~p:~p~n",[Tag,Value]),
	    pbutil:unixtime()
    end.
    
set_stats(IMSI,Date) ->
    {ok, [{uid,UID}]} = select_uid({imsi,IMSI}),
    CMD="UPDATE stats SET latest='"++integer_to_list(Date)++
	"' WHERE uid='"++UID++"'" ,
    try rpc:call(possum@localhost,?SQL_Module,execute_stmt,
		 [CMD,[stats],10000]) of
        {updated,1} -> ok;
	Else -> 
	    io:format("Else:~p~n",[Else]),
	    nok
    catch Tag:Value -> 
	    io:format("Tag:Value:~p:~p~n",[Tag,Value]),
	    nok
    end.
    

insert_profile_in_base()->
    %% cas classique
    lists:foreach(fun ( {IMSI, MSISDN, TAC, OCF, _, COMMERCIAL})-> insert_of_extra(IMSI, MSISDN, TAC, OCF, COMMERCIAL) end,
		  ?IMSIs_CONFIG),
    lists:foreach(fun  ({IMSI, _, _, OLD_OCF, NEW_OCF, COMMERCIAL}) -> verify_of_extra_aux({IMSI,NEW_OCF,OLD_OCF,COMMERCIAL}) end,
		  ?IMSIs_CONFIG).
	    

updates(CMD) ->
    io:format("Updates~n"),
    net_adm:ping(possum@localhost),
    V1 = rpc:call(possum@localhost, pbutil, get_env,
		  [pfront_orangef, batch_ocf_updates_check_period]),
    V2 = rpc:call(possum@localhost, pbutil, get_env,
		  [pfront_orangef, batch_ocf_updates_rates]),
    %% rpc:call(possum@localhost, application, set_env,
    %%          [pfront_orangef, batch_ocf_updates_check_period, 1]),
    rpc:call(possum@localhost, application, set_env,
	     [pfront_orangef, batch_ocf_updates_rates, [{{00, 00}, 10.0}]]),
    receive after (V1 + 3) * 1000 -> ok end,

    A=os:cmd(CMD),
    io:format("~s~n",[A]),
    Result = rpc:call(possum@localhost,batch_ocfrdp,updates_aux2,[]),

    rpc:call(possum@localhost, application, set_env,
	     [pfront_orangef, batch_ocf_updates_check_period, V1]),
    rpc:call(possum@localhost, application, set_env,
	     [pfront_orangef, batch_ocf_updates_rates, V2]),
    Result.

deletions() ->
    io:format("Deletions~n"),
    net_adm:ping(possum@localhost),
    rpc:call(possum@localhost,batch_ocfrdp,daily,[]).

verify_user_state()->
    %% test cas classique
    %% verify msisdn, subscription, imei.
    io:format("Verify user state1~n"),
    {ok, [{msisdn,"+33600000001"},{imei,"000001XXXXXXX1"},
	  {subscription,"postpaid"}]} = 
	select_profile({imsi,"208010000000001"}),
    %% modif IMEI Old version to new OF
    {ok, [{msisdn,"+33600000002"},{imei,"000001XXXXXXX1"},
	  {subscription,"postpaid"}]} = 
	select_profile({imsi,"208010000000002"}),
    %% modif IMEI verif pas de baisse de niveau
    {ok, [{msisdn,"+33600000003"},{imei,"000001XXXXXXX1"},
	  {subscription,"postpaid"}]} = 
	select_profile({imsi,"208010000000003"}),
       %% modif Msisdn
    {ok, [{msisdn,"+33610000004"},{imei,"000001XXXXXXX1"},
	  {subscription,"postpaid"}]} = 
	select_profile({imsi,"208010000000004"}),
    %% modif imsi
    %% old imsi n'existe plus
    not_found=select_profile({imsi,"208010000000005"}),
    %% nouveau imsi avec le bon profile
    {ok, [{msisdn,"+33600000005"},{imei,"000001XXXXXXX1"},
	  {subscription,"postpaid"}]} = 
	select_profile({imsi,"208010010000005"}),
    %% souscription mobi
    {ok, [{msisdn,"+33600000006"},{imei,"000001XXXXXXX1"},
	  {subscription,"mobi"}]} = 
	select_profile({imsi,"208010000000006"}),
    %% souscription cmo
    {ok, [{msisdn,"+33600000007"},{imei,"000001XXXXXXX1"},
	  {subscription,"cmo"}]} = 
	select_profile({imsi,"208010000000007"}),
     %% souscription postpaid
    {ok, [{msisdn,"+33600000008"},{imei,"000001XXXXXXX1"},
	  {subscription,"postpaid"}]} = 
	select_profile({imsi,"208010000000008"}),
     %% souscription dme
    {ok, [{msisdn,"+33600000009"},{imei,"000001XXXXXXX1"},
	  {subscription,"dme"}]} = 
	select_profile({imsi,"208010000000009"}),
     %% souscription inconnu
    {ok, [{msisdn,"+33600000010"},{imei,"000001XXXXXXX1"},
	  {subscription,null}]} = 
	select_profile({imsi,"208010000000010"}),
    %% delete imsi
    not_found=select_profile({imsi,"208010000000011"}),
    %% client inconnu
    {ok,_} = select_profile({imsi,"208010000000012"}),
    %% tac=#NA# UL=0
    {ok, [{msisdn,"+33600000013"},{imei,"00000100000001"},
	  {subscription,null}]} = 
	select_profile({imsi,"208010000000013"}),
    % tac=#NA# UL=2
    {ok, [{msisdn,"+33600000014"},{imei,"00000100000001"},
    	  {subscription,null}]} = 
	select_profile({imsi,"208010000000014"}),
    %% cas changement d'imsi et client new_imsi existe
    %% profile old imsi existe
    {ok, [{msisdn,"+33600000015"},{imei,"00000100000001"},
    	  {subscription,null}]} = 
	select_profile({imsi,"208010000000015"}),
    %% profile new imsi existe
     {ok, [{msisdn,"+33600000015"},{imei,"00000200000001"},
     	  {subscription,null}]} = 
 	select_profile({imsi,"208010000000016"}),
%     %% doublons MSISDN
     {ok,
      [[{imsi,"208010000000015"},{imei,"00000100000001"},{subscription,null}],
      [{imsi,"208010000000016"},{imei,"00000200000001"},{subscription,null}]]}
 	=select_profile({msisdn,"+33600000015"}),
     %% paiement mode ENT -> dme
     {ok, [{msisdn,"+33600000025"},{imei,"000001XXXXXXX1"},
     	  {subscription,"dme"}]} = 
 	select_profile({imsi,"208010000000025"}),
     %% paiement mode non ignored -> postpaid
     {ok, [{msisdn,"+33600000026"},{imei,"000001XXXXXXX1"},
     	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000026"}),
     %% paiement mode cmo ignored -> postpaid
     {ok, [{msisdn,"+33600000027"},{imei,"000001XXXXXXX1"},
     	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000027"}),
     %% paiement mode oui ignored -> postpaid
     {ok, [{msisdn,"+33600000028"},{imei,"000001XXXXXXX1"},
     	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000028"}),
     %% paiement mode nof ignored -> postpaid
     {ok, [{msisdn,"+33600000029"},{imei,"000001XXXXXXX1"},
     	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000029"}),
     %% paiement mode ENT -> dme
     {ok, [{msisdn,"+33600000030"},{imei,"000001XXXXXXX1"},
     	  {subscription,"dme"}]} = 
 	select_profile({imsi,"208010000000030"}),
     %% paiement mode SCS -> dme
     {ok, [{msisdn,"+33600000031"},{imei,"000001XXXXXXX1"},
     	  {subscription,"dme"}]} = 
 	select_profile({imsi,"208010000000031"}),
     %% paiement mode OFR -> dme
     {ok, [{msisdn,"+33600000032"},{imei,"000001XXXXXXX1"},
     	  {subscription,"dme"}]} = 
 	select_profile({imsi,"208010000000032"}),
     %% paiement mode oui ignored -> postpaid
     {ok, [{msisdn,"+33600000033"},{imei,"000001XXXXXXX1"},
     	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000033"}),
     %% paiement mode nof ignored -> postpaid
     {ok, [{msisdn,"+33600000034"},{imei,"000001XXXXXXX1"},
     	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000034"}),
    ok.
	
verify_user_state2()->
%%     %% modif IMEI verif avec  baisse de niveau
     io:format("Verify user state 2~n"),
     {ok, [{msisdn,"+33600000003"},{imei,"000001XXXXXXX2"},
 	  {subscription,"postpaid"}]} = 
 	select_profile({imsi,"208010000000003"}),
     %% pas de mise à jour de l'IMEI si TAC=#NA#
     {ok, [{msisdn,"+33600000014"},{imei,"00000100000001"},
 	  {subscription,null}]} = 
 	select_profile({imsi,"208010000000014"}),
     rpc:call(possum@localhost,application,set_env,
 	     [pfront_orangef,authorized_ul_down,false]).

verify_user_state3()->
     io:format("Verify user state 3~n"),
     {ok, [{msisdn,"+33600000101"},{imei,_},
 	  {subscription,_}]} = 
 	select_profile({imsi,"208010000000101"}),
     %% pas de mise à jour de l'IMEI si TAC=#NA#
     {ok, [{msisdn,"+33600000102"},{imei,_},
 	  {subscription,_}]} = 
 	select_profile({imsi,"208010000000102"}),
    {ok, [{msisdn,"+33600000103"},{imei,_},
 	  {subscription,_}]} = 
 	select_profile({imsi,"208010000000103"}),
     rpc:call(possum@localhost,application,set_env,
 	     [pfront_orangef,authorized_ul_down,false]).

    
select_uid({imsi,IMSI})->
    net_adm:ping(possum@localhost),
    Command = [ "SELECT uid FROM users WHERE imsi="++
		IMSI],
    case rpc:call(possum@localhost,?SQL_Module,execute_stmt,[Command, [],5000]) of
	{selected, Cols, [Row]} ->{ok, pair(Cols, Row)};
	{selected, Cols, []} -> not_found;
	E -> {error, E}
    end.

select_profile({imsi,IMSI})->
    net_adm:ping(possum@localhost),
    Command = [ "SELECT  msisdn,imei,subscription FROM users WHERE imsi="++
		IMSI],
    case rpc:call(possum@localhost,?SQL_Module,execute_stmt,[Command, [],5000]) of
	{selected, Cols, [Row]} ->{ok, pair(Cols, Row)};
	{selected, Cols, []} -> not_found;
	E -> {error, E}
    end;
select_profile({msisdn,MSISDN})->
    net_adm:ping(possum@localhost),
    Command = [ "SELECT  imsi,imei,subscription FROM users WHERE msisdn="++
		MSISDN++" order by imsi"],
    case rpc:call(possum@localhost,?SQL_Module,execute_stmt,[Command, [],5000]) of
						%   case rpc:call(possum@localhost,?SQL_Module,execute_stmt,[Command,[],5000]) of

	{selected, Cols, []} -> not_found;
	{selected, Cols, Rows} -> {ok, lists:map(fun(Row) ->
							 pair(Cols, Row)
						 end,Rows)};

	E -> {error, E}
    end.

%% +type pair([A], [B]) -> [{A,B}].
pair([], []) -> [];
pair([C|Cols], [R|Rows]) -> [{list_to_atom(C),R} | pair(Cols,Rows)].


delete_imsi(IMSI_LIST)->
    lists:map(fun(IMSI)->
		      []=os:cmd( "mysql -u possum -ppossum mobi -e "
				 "\"DELETE FROM users where imsi='"++IMSI++
				 "'\"")
	      end,IMSI_LIST).

%% +type insert(string()) -> string().
%%%% Returns the UID corresponding to the insertion.

insert(Imsi) ->
    Msisdn = "+336000000"
	++ string:substr(Imsi, length(Imsi) - 2 + 1, length(Imsi)),
    insert(Imsi, Msisdn, "00000100000001").

insert(Imsi, Msisdn, Imei) ->
    Cmd = io_lib:format(
	    "mysql -u possum -ppossum mobi -Bse "
	    "\"INSERT INTO users (imsi,msisdn,imei) VALUES ('~s', '~s', '~s');"
	    "  SELECT @u := uid FROM users WHERE imsi = '~s'; "
	    "  SELECT @u\"",
	    [Imsi, Msisdn, Imei, Imsi]),
    S = os:cmd(Cmd),
    Uid = lists:last(string:tokens(S, "\n")), % last line
    Uid.

%% +type insert_of_extra(string(), tech_seg_int()) -> string().
%%%% Returns the UID corresponding to the insertion.

insert_of_extra(Imsi, TSI) ->
    Msisdn = "+336000000"
	++ string:substr(Imsi, length(Imsi) - 2 + 1, length(Imsi)),
    insert_of_extra(Imsi, Msisdn, "00000100000001", TSI, "TEST").

insert_of_extra(Imsi, Msisdn, Imei, -1, Commercial_Segment) ->
    [];
insert_of_extra(Imsi, Msisdn, Imei, TSI, Commercial_Segment) ->
    Cmd = io_lib:format(
	    "mysql -u possum -ppossum mobi -Bse "
	    "\"INSERT INTO users (imsi,msisdn,imei) VALUES ('~s', '~s', '~s');"
	    "  SELECT @u := uid FROM users WHERE imsi = '~s'; "
	    "  INSERT INTO users_orangef_extra (uid, tech_segment, commercial_segment) VALUES "
	    "    (@u, ~p, '~s'); "
	    "  SELECT @u\"",
	    [Imsi, Msisdn, Imei, Imsi, TSI, Commercial_Segment]),
    S = os:cmd(Cmd),
    Uid = lists:last(string:tokens(S, "\n")), % last line
    Uid.

delete_of_extra(Imsi) ->
    Res =
	os:cmd(
	  "mysql -u possum -ppossum mobi -Bse "
	  "\"SELECT @u := uid FROM users WHERE imsi = '"++Imsi++"'; "
	  "  DELETE FROM users WHERE uid = @u; "
	  "  DELETE FROM users_orangef_extra WHERE uid = @u\"; "
	  "echo $?"),
    "0" = lists:last(string:tokens(Res, "\n")).

%% +type verify_of_extra(
%%   [{string(), tech_seg_int(), tech_seg_int()}], [string()]) -> ok.

verify_of_extra(Modified, DelUids) ->
    lists:foreach(fun verify_of_extra_aux/1, Modified),
    lists:foreach(fun verify_deletion/1, DelUids),
    ok.

%% verify_of_extra_aux({"208010000000005", _InitTsi, ExpTSI, Commercial}) ->
%%     ok;
verify_of_extra_aux({Imsi, _InitTsi, ExpTSI, Commercial}) ->
    TSI_ =
	case ExpTSI of
	    ExpTSI when list(ExpTSI)    -> ExpTSI;
	    ExpTSI when integer(ExpTSI) -> integer_to_list(ExpTSI);
	    not_found -> "toto"
	end,
    case select_of_extra(Imsi) of
	{ok, [[{tech_segment, TSI_},{commercial_segment,Commercial}]]} ->
	    ok;
	not_found when TSI_=="-1" ->
	    ok;
	{ok, X} ->
	    io:format("verify_of_extra_aux: Imsi = ~s~ngot ~p~nexpected ~p~n",
		      [Imsi, X, [[{tech_segment, TSI_},{commercial_segment,Commercial}]]]),
	    halt(1);
	Error -> 
	    io:format("verify_of_extra_aux error: Imsi ~s~ngot ~p~nTSI_ ~p~n",
			   [Imsi, Error, TSI_]),
	    halt(1)
		      
    end.

%% +type verify_deletion(string()) -> ok.
%%%% Crashes if there exists a row indexed by Uid in users or
%%%% users_orangef_extra.

verify_deletion(Uid) ->
    "0\n" = os:cmd("mysql -u possum -ppossum mobi -Bse "
		   "\"SELECT COUNT(*) FROM users WHERE uid = "++Uid++"\""),
    "0\n" = os:cmd("mysql -u possum -ppossum mobi -Bse "
		   "\"SELECT COUNT(*) FROM users_orangef_extra WHERE uid = "
		   ++Uid++"\""),
    ok.

select_of_extra(Imsi)->
    Command =
	"SELECT tech_segment,commercial_segment FROM users LEFT JOIN users_orangef_extra "
	"USING (uid) WHERE imsi = " ++ Imsi,
    case rpc:call(possum@localhost,?SQL_Module,execute_stmt,[Command,[],5000]) of
  	{selected, Cols, []} ->
	    not_found;
	{selected, Cols, Rows} ->
	    {ok, lists:map(fun(Row) -> pair(Cols, Row) end, Rows)};
	E ->
	    {error, E}
end.        

