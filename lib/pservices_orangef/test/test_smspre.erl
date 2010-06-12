-module(test_smspre).

-export([run/0, online/0]).
-export([sms_queue_init/2, switch_interface_status/2, do_check_svc_profiles/2]).

-include("../../ptester/include/ptester.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../include/smspre.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").

run() ->
    ok.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(USSD_COMMAND_START, "*140*").
-define(NOM,"DUPOND").
-define(PRENOM,"Guillaume").

-define(VLR_OF, "33900000000"). % fake number
-define(VLR_MACEDOINE, "38900000000").

-define(MSISDN_ORANGE, "612345670").
-define(MSISDN_NOT_ORANGE, "612345678").

%% format donnant accès à svc_profile dans sachem_cmo_fake
%% 999000901YYYYYY
-define(IMSI_CMO,"999000901222222"). 
-define(MSISDN_CMO,"901222222").
-define(IMEI_DEF_CMO,"012345XXXXXXX1").
%% format donnant accès à svc_profile dans sachem_fake
%% 999000900YYYYYY
-define(IMSI_M6_PREPAID,"999000900111111").
-define(MSISDN_M6_PREPAID,"900111111").
-define(IMEI_DEF_M6_PREPAID,"123456XXXXXXX1").
-define(IMEI_LEVEL_1, "123456XXXXXXX1").
%% other
-define(IMSI_POST,   "208010902000001").
-define(IMSI_DME,    "208010903000001").
-define(IMSI_VI,     "208010904000001").
-define(IMSI_OMER,   "208010905000001").
-define(IMSI_m6_prepaid1, "208010906000001").
-define(MSISDN_m6_prepaid1, "+99906000001").

-define(OK_LEVEL_1,"#140#.*votre correspondant va recevoir dans quelque instant votre nouveau.*").
-define(NOK_LEVEL_1, "#140#.*Vous avez utilise tous vos messages.").
-define(NOK_ROAMER,"Ce service n'est pas disponible a l'etranger. Merci").
-define(NOK_DECL,"Vous n'avez pas acces a ce service").
-define(NOK_FORMAT,"Veuillez reformuler votre demande :."
	"#126\\*numero_du_destinataire#").
-define(NOK_OCF_DOWN_1,
	"Le service est temporairement indisponible\\. "
	"Veuillez nous en excuser, et vous reconnecter ultérieurement\\. "
	"Merci\\.").
-define(NOK_CVF_DOWN_1, ?NOK_OCF_DOWN_1).

-define(COLOUR_SMS, cyan).


-record(cpte_test,{imsi,sub,dcl,balance=0,d_der_rec=0,level=1,rnv=10}).


online() ->
    QueuePid = sms_start_client(false),
    %% QueuePid must be stored in the dictionary to build the test_service()
    put(pid_sms_ql, QueuePid),
    {TestService, ExpectedSMSs} = split(test()),
    QueuePid ! {specs, ExpectedSMSs},
    application:start(pservices_orangef),
    test_util_of:online(?MODULE,test_service(TestService)),
    sms_stop_client(QueuePid).

test() ->
 	successes() ++ 
 	svc_profile() ++ 
	failures().    

test_service(TestService) ->

    %%Test title
    [{title, "Tests pour SMS Pre-etabli"}] ++
	[test_util_of:connect(smpp)] ++

 	switch(enabled,httpclient_ocfrdp) ++
	switch(enabled, io_sms_emi_ip_20565) ++
	switch(enabled, io_sms_loop) ++

 	test_util_of:init_test({imsi,?IMSI_m6_prepaid1},
 			       {subscription,"mobi"},
 			       {msisdn,?MSISDN_m6_prepaid1},
 			       {imei,?IMEI_DEF_M6_PREPAID}) ++

	test_util_of:init_test({imsi,?IMSI_M6_PREPAID},
			       {subscription,"mobi"},
			       {msisdn,?MSISDN_M6_PREPAID},
			       {imei,?IMEI_DEF_M6_PREPAID}) ++

	test_util_of:init_test({imsi,?IMSI_CMO},
			       {subscription,"cmo"},
			       {msisdn,?MSISDN_CMO},
			       {imei,?IMEI_DEF_CMO}) ++

	reset_svc_profiles() ++
	TestService ++
	reset_svc_profiles().

successes() ->
    L = [success(Sub, 1, DestOperator) ||
	    Sub <- [mobi, cmo],
	    DestOperator <- [orange, not_orange]],
    lists:append(L).

success(Sub, Level, DestOperator) ->
    {Imsi, Msisdn, Expected} =
	case Sub of
	    mobi -> {?IMSI_M6_PREPAID, ?MSISDN_M6_PREPAID, ?OK_LEVEL_1};
	    cmo  -> {?IMSI_CMO, ?MSISDN_CMO, ?NOK_DECL}
	end,
    {SMSType, DestMsisdn, SmsTxt} =
	case DestOperator of
	    orange     -> {sms_mt, ?MSISDN_ORANGE, sms_preetabli_texte};
	    not_orange -> {sms_mo, ?MSISDN_NOT_ORANGE,sms_preetabli_texte}
	end,
    Format = test_util_of:get_env(pservices_orangef, SmsTxt),
    ExpSMS = lists:flatten(io_lib:format(Format, [?NOM,?PRENOM,type_carte(?m6_prepaid),"0" ++ Msisdn])),
    Title =
	lists:flatten(io_lib:format("Success test ~p, level ~p, to ~p",
				    [Sub, Level, DestOperator])),
    ExpSMSSpec =
	{SMSType, {Title, "+99" ++ Msisdn, "+33"++DestMsisdn, ExpSMS}},
    case Sub of
	mobi -> 
	    session(
	      {title, Title}, Imsi, Sub, Level, "0"++DestMsisdn, 0,
	      0, Expected, ExpSMSSpec, 1,?m6_prepaid);
	_->
	    session(
	      {title, Title}, Imsi, Sub, Level, "0"++DestMsisdn, 0,
	      0, Expected, {no_sms, "Bad subscription"} , 0,?cmo_sl)
    end.

%%%% The rolling periods must match certain conditions for this to work.
svc_profile() ->
    NbMax=test_util_of:get_env(pservices_orangef,max_sms_preetabli),   
    set_svc_profiles(?IMSI_m6_prepaid1, NbMax) ++
	[{title, "svcprofiles test"}] ++
	svc_profile_aux(NbMax).

svc_profile_aux(Nb) ->
    Title = io_lib:format("svcprofiles time n° ~p", [Nb]),
    Format = test_util_of:get_env(pservices_orangef, sms_preetabli_texte),
    ExpSMS = lists:flatten(io_lib:format(Format, [?NOM,?PRENOM,type_carte(?m6_prepaid),"0" ++ ?MSISDN_M6_PREPAID])),
    % ExpSMSSpec =
% 	{sms_mt,
% 	 {Title, "+99" ++ ?MSISDN_M6_PREPAID, "+33" ++ ?MSISDN_ORANGE, ExpSMS}},
    session(
      Title, ?IMSI_m6_prepaid1, mobi, 1, "0" ++ ?MSISDN_ORANGE, 500,
      no_update, ?NOK_LEVEL_1, {no_sms, "Max reached"}, Nb,?m6_prepaid).

failures() ->
  	platforms_out_of_order() ++
	[].

erlang_rpc_call(M, F, A) ->
    [{erlang, [{rpc, call, [possum@localhost, M, F, A]}]}].

rpc_call(M, F, A) ->
    rpc:call(possum@localhost, M, F, A).

platforms_out_of_order() ->
	switch(disabled, httpclient_ocfrdp) ++
	session(
	  {title, "OCF down"}, ?IMSI_M6_PREPAID, mobi, 1, "0" ++ ?MSISDN_ORANGE, 0,
	  0, ?NOK_OCF_DOWN_1, {no_sms, "OCF down"}, 0,?m6_prepaid) ++
	switch(enabled, httpclient_ocfrdp) ++
	switch(disabled, io_sms_emi_ip_20565) ++
	session(
	  {title, "SMS-C down"}, ?IMSI_M6_PREPAID, mobi, 1, "0" ++ ?MSISDN_ORANGE, 0,
	  0, ?NOK_CVF_DOWN_1, {no_sms, "CVF down"}, 0,?m6_prepaid) ++
	switch(enabled, io_sms_emi_ip_20565).

%% +deftype sub() = mobi | cmo.
%% +deftype level() = 1 | 2 | 3.
%% +deftype sms_spec() = {no_sms, string()} | sms().

%% +type session(
%%   string() | {title, string()},
%%   string(), sub(), level(), string(), number(), [unix_time()] | no_update,
%%   string(), {no_sms, string()} | sms_spec(), integer())
%%  -> test_service().

session(
  Title, Imsi, Sub, Level, DestMsisdn, Balance, Times, Expected,
  ExpectedSMS, NTimes,Dcl) ->
    OptExpSMS =
	case ExpectedSMS of
	    {no_sms, Test} ->
		[{expected_sms, {no_sms, Test}},
		 {erlang, [{pbutil, tsend, [get(pid_sms_ql), no_sms]}]}];
	    _ ->
		[{expected_sms, ExpectedSMS}]
	end,
    OptSetSvcProfile =
	case Times of
	    no_update -> [];
	    _         -> set_svc_profiles(Imsi, Times)
	end,
    Cpte = #cpte_test{
      imsi = Imsi, sub = Sub, dcl = Dcl, level = Level, balance = Balance},
    [Title] ++ [io_lib:format("svcprofiles time n° ~p", [OptExpSMS])]++
	set_simulators(Cpte) ++
	test_util_of:change_navigation_to_niv(Level, Imsi) ++
	OptSetSvcProfile ++
	set_imsi_and_ensure_session_closed(Imsi, Level) ++
	send_ussd(Imsi,DestMsisdn,Expected)++
	check_svc_profiles(Imsi, NTimes) ++
	OptExpSMS.

send_ussd(?IMSI_M6_PREPAID,DestMsisdn,Expected)->
    [{ussd2,
      [ {send, ?USSD_COMMAND_START++"#"},
	{expect,"#140#.*laissez vous guider.*\\(maximum 25 caracteres\\)"},
	{send,?NOM},
	{expect,"#140#.*ETAPE 2.*tapez votre PRENOM puis valider \\(maximum 25 caracteres\\)"},
	{send,?PRENOM},
	{expect,"#140#.*ETAPE 3.*Tapez le numero de mobile du destinataire commencant par 06, puis validez."},
	{send,DestMsisdn},
	{expect, Expected}
       ]}];
send_ussd(_,_,Expected) ->
    [{ussd2,
      [ {send, ?USSD_COMMAND_START++"#"},
	{expect, Expected}
       ]}].

set_simulators(#cpte_test{imsi=IMSI,level=Level,sub=SUB}=CPTE_TEST) ->
    insert_client(IMSI,SUB,Level) ++
	build_test_account(CPTE_TEST).

set_imsi_and_ensure_session_closed(IMSI, Level) ->
    [
     "Set imsi="++IMSI,
     {msaddr, {subscriber_number, private, IMSI}}
    ] ++ 
	close_session(Level).

close_session(3) ->
    [
     "Ensure that the session is closed",
     {ussd2, [ {send, "#128*133#"}, {expect, "Closing"} ]},
     {pause, 500}
    ];
close_session(_) ->
    test_util_of:close_session().

insert_client(IMSI,SUB,Level) ->
    [{erlang_no_trace,
      [{net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[sub,{IMSI,SUB}]]},
       {rpc, call, [possum@localhost,ets,
		    insert,[ocf_test,{IMSI,#ocf_test{tac="012345",
						     ussd_level=Level,
						     sub=SUB}}]]}]}].

build_test_account(#cpte_test{imsi=Imsi,dcl=?cmo_sl,balance=Balance,
			      d_der_rec=DateDerRec,level=Level,rnv=RNV}) ->
    test_util_of:insert(
      Imsi, ?cmo_sl, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
       #compte{tcp_num=?C_FORF_CMOSL,unt_num=?EURO,cpp_solde=Balance,
	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
      ],
      [{d_der_rec,DateDerRec}]
     );
% build_test_account(#cpte_test{imsi=Imsi,dcl=DCL,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV}) 
%   when DCL==?ppol3;DCL==?ppol1->
%     test_util_of:insert(
%       Imsi, DCL, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?pmu,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?pmu, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_PMU,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?ppol2,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?ppol2, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_SMS,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?ppolc,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?ppolc, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_HC,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?fmu_18,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?fmu_18, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_FMU_18,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?fmu_24,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?fmu_24, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_FMU_24,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?bzh_cmo,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?bzh_cmo, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_BZH,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?zap_cmo,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?zap_cmo, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_VOIX_ZAP,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
% build_test_account(#cpte_test{imsi=Imsi,dcl=?m6_cmo,balance=Balance,
% 			      d_der_rec=DateDerRec,level=Level,rnv=RNV})->
%     test_util_of:insert(
%       Imsi, ?m6_cmo, 0,
%       [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=5000,
% 	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=101},
%        #compte{tcp_num=?C_FORF_MU_M6,unt_num=?EURO,cpp_solde=Balance,
% 	       dlv=0,rnv=RNV,etat=?CETAT_AC,ptf_num=101}
%       ],
%       [{d_der_rec,DateDerRec}]
%      );
build_test_account(#cpte_test{imsi=Imsi,dcl=DCL,balance=Balance,
			      d_der_rec=DateDerRec,level=Level})
  when DCL==?cpdeg;DCL==?m6_prepaid;DCL==?ppola;DCL==?omer->
    test_util_of:insert(
      Imsi, DCL, 0,
      [#compte{tcp_num=?C_PRINC,unt_num=?EURO,cpp_solde=Balance,
	       dlv=pbutil:unixtime(),rnv=0,etat=?CETAT_AC,ptf_num=?MCLAS}],
      [{d_der_rec,DateDerRec}]
     ).

reset_svc_profiles() ->
    Del = "mysql -upossum -ppossum mobi -Bse "
	"\"DELETE FROM svcprofiles WHERE svc = '"++?SVC_NAME++"'\"",
    Cnt = "mysql -upossum -ppossum mobi -Bse "
	"\"SELECT COUNT(*) FROM svcprofiles WHERE svc = '"++?SVC_NAME++"'\"",
    ["Reset svcprofiles.",
     {shell,
      [ {send, Del},
	{send, Cnt},
	{expect, "^0\$"}
       ]}].

set_svc_profiles(Imsi, Nb) ->
    SMSData=#sms_pre{num=Nb},
    DataHex = svc_util_of:bin2hex(binary_to_list(term_to_binary(SMSData))),
    Now = pbutil:unixtime(),
    Update = io_lib:format(
	       "SELECT @u := uid FROM users where imsi = '~s'; "
	       "DELETE FROM svcprofiles WHERE uid = @u AND svc = '~s'; "
	       "INSERT INTO svcprofiles (uid, svc, data, updated) "
	       "  VALUES (@u, '~p', '~s',  ~p); ",
	       [Imsi,
		?SVC_NAME,
		?SVC_NAME, DataHex, Now]),
    [lists:flatten(io_lib:format("Insert ~p into svcprofiles", [Nb])),
     {shell_no_trace,
      [ {send, "mysql -u possum -ppossum -B -vv -e \""++Update++"\" mobi"},
	{expect, "1 row affected"}
       ]}].

check_svc_profiles(Imsi, NTimes) ->
    [{erlang,
      [{rpc, call, [test@localhost,
		    ?MODULE, do_check_svc_profiles, [Imsi, NTimes]]}
      ]}].

do_check_svc_profiles(Imsi, NTimes) ->
    Select = io_lib:format(
	       "SELECT @u := uid FROM users where imsi = '~s';"
	       "SELECT data FROM svcprofiles WHERE uid = @u AND svc = '~s'",
	       [Imsi, ?SVC_NAME]),
    Res = os:cmd("mysql -u possum -ppossum mobi -Bse \""++Select++"\""),
    [_Uid, HexData] = string:tokens(Res, [$\n]),
    #sms_pre{num=Times} = binary_to_term(list_to_binary(svc_util_of:hex2bin(HexData))),
    case Times == NTimes of
	true ->
	    io:format("check_svc_profiles expected ~p times, OK~n",
		      [NTimes]);
	false ->
	    io:format("check_svc_profiles expected ~p times, got Times = ~p~n",
		      [NTimes, Times]),
	    halt(1)
    end.

type_carte(?m6_prepaid) ->
    "La carte prepayee m6 mobile by orange";
type_carte(DCL_NUM) when DCL_NUM==?RC_LENS_mobile;DCL_NUM==?ASSE_mobile;
			DCL_NUM==?OL_mobile;DCL_NUM==?OM_mobile;
			DCL_NUM==?PSG_mobile;DCL_NUM==?BORDEAUX_mobile->
    "carte prepayee club de foot";
type_carte(_)->
    "mobicarte".

switch(How,What) ->
    ["Switching " ++ atom_to_list(What) ++ " to " ++ atom_to_list(How),
     {erlang_no_trace,
      [ {net_adm, ping,[possum@localhost]},
	{rpc, call, [possum@localhost,code,
		     load_abs,
		     ["lib/pservices_orangef/test/test_smspre"]]},
	{rpc, call, [possum@localhost,test_smspre,
		     switch_interface_status,
		     [What,How]]}]
     },
     {pause, 4000}
    ].

switch_interface_status(Name, Status) ->
    OldEnv = application_controller:prep_config_change(),
    {value, {pfront,PfrontOldConfig}} = lists:keysearch(pfront,1,OldEnv),
    {value, {interfaces,OldInterfaces}} = 
	lists:keysearch(interfaces, 1, PfrontOldConfig),
    {value, OldInterface} =
	lists:keysearch({Name,possum@localhost},4,OldInterfaces),
    NewInterface = OldInterface#interface{admin_state=Status},
    %% This is needed because we don't really update application parameters...
    RealOldInterface = case Status of
			   disabled ->
			       OldInterface#interface{admin_state=enabled};
			   enabled ->
			       OldInterface#interface{admin_state=disabled}
		       end,
    NewInterfaces = lists:keyreplace({Name,possum@localhost},4,
				     OldInterfaces,NewInterface),
    RealOldInterfaces = lists:keyreplace({Name,possum@localhost},4,
					 OldInterfaces,RealOldInterface),
    pfront_sup:interfaces_changed(RealOldInterfaces,NewInterfaces).

%% +type partition(fun (T) -> bool(), [T]) -> {[T], [T]}.

partition(Pred, L) ->
    partition_aux(Pred, L, [], []).

%% +type partition_aux(fun (T) -> bool(), [T], [T], [T]) -> {[T], [T]}.

partition_aux(_Pred, [], RevTrue, RevFalse) ->
    {lists:reverse(RevTrue), lists:reverse(RevFalse)};
partition_aux(Pred, [H | T], RevTrue, RevFalse) ->
    case Pred(H) of
	true  -> partition_aux(Pred, T, [H | RevTrue], RevFalse);
	false -> partition_aux(Pred, T, RevTrue, [H | RevFalse])
    end.

%% +type split(sms_test_service()) -> {test_service(), [sms_spec()]}.

split(L) ->
    F =
	fun ({expected_sms, ExpectedSMS}) -> false;
	    (_)                           -> true
	end,
    {TestService, ExpectedSMSs} = partition(F, L),
    ExpSMSSpecs = [Spec || {expected_sms, Spec} <- ExpectedSMSs],
    {TestService, ExpSMSSpecs}.

%%%% Fun dealing with SMSs

%%% Starts a sms queue, defined as a client for smsloop_server
sms_start_client(ColourOutput) ->
    proc_lib:start_link(?MODULE, sms_queue_init, [self(), ColourOutput]).

%%% Sync with the queue
sms_stop_client(Pid) ->
    Pid ! sms_stop,
    receive
	ok -> ok;
	{error,Else} -> exit(Else)
    end.

%%% Register the queue as a smsloop_client
sms_queue_init(Parent, ColourOutput) ->
    proc_lib:init_ack(self()),
    put(colour_output, ColourOutput),
    pong = net_adm:ping(possum@localhost), 
    ptester:start_interface(loop),
    receive
	{specs, ExpectedSMSs} ->
	    sms_queue_loop(Parent, ExpectedSMSs)
    end.

%% +deftype sms() = {sms_mo | sms_mt, {string(), From, To, string()}}.

%%% Main queue loop
sms_queue_loop(Parent, [{no_sms, Test} | SMSs]) ->
    print_sms_ql("Check SMS contents Test ~s: expecting no_sms~n",
		 [Test]),
    receive
	no_sms ->
	    print_sms_ql("sms_queue_loop: OK~n"),
	    sms_queue_loop(Parent,SMSs)
    end;

sms_queue_loop(Parent,[{sms_mo,{Test,From,To,ExpText}=SMSMO} | SMSs]) ->
    print_sms_ql("Check SMS contents Test: ~s: ~s~n",[Test,ExpText]),
    receive 
	{fake_incoming_mo,
	 #sms_incoming{da      = To,
		       deliver = #sms_deliver{dcs = DCS,
					      oa  = From,
					      ud  = UD}}}=Data ->
	    Text = gsmcharset:ud2iso(DCS, UD),
	    case Text == ExpText of
		true ->
		    print_sms_ql("sms_queue_loop: OK~n"),
		    sms_queue_loop(Parent,SMSs);
		false ->
		    exit({smsmo_badmatch,Text,ExpText})
	    end;

	{fake_incoming_mo,INC} -> 
	    exit({smsmo_unexpected,INC,instead_of,SMSMO});

	sms_stop -> Parent ! {error,{smsmo_still_awaiting,[SMSMO|SMSs]}}

    end;

sms_queue_loop(Parent,[{sms_mt,{Test,From,To,ExpText}=SMSMT} | SMSs]) ->
    print_sms_ql("Check SMS contents Test: ~s: ~s~n",[Test,ExpText]),
    receive 
	{fake_insert_sms,
	 #sms_insert{sa  = From,
		     submit = #sms_submit{da  = To,
					  dcs = DCS,
					  ud  = UD}}}=Data ->
	    Text = gsmcharset:ud2iso(DCS, UD),
	    case Text == ExpText of
		true ->
		    print_sms_ql("sms_queue_loop: OK~n"),
		    sms_queue_loop(Parent,SMSs);
		false ->
		    exit({smsmt_badmatch,Text,ExpText})
	    end;

	{fake_insert_sms,INS} -> 
	    exit({smsmt_unexpected,sms_text(INS),instead_of,SMSMT});

	sms_stop -> Parent ! {error,{smsmt_still_awaiting,[SMSMT|SMSs]}}

    end;

sms_queue_loop(Parent,[]) ->
    receive
	sms_stop -> Parent ! ok;
	{fake_incoming_mo,INC} ->
	    Parent ! {error,{smsmo_unexpected,INC}};
	{fake_insert_sms,INS} -> 
	    Parent ! {error,{smsmt_unexpected,INS}}
    end.

sms_text(#sms_incoming{deliver = #sms_deliver{dcs = DCS, ud  = UD}}) ->
    gsmcharset:ud2iso(DCS, UD);
sms_text(#sms_insert{submit = #sms_submit{dcs = DCS, ud  = UD}}) ->
    gsmcharset:ud2iso(DCS, UD).

print_sms_ql(Format) ->
    print_colour(?COLOUR_SMS, Format).

print_sms_ql(Format, Args) ->
    print_colour(?COLOUR_SMS, Format, Args).

%%%% Probably not highly portable.
print_colour(Colour, Format) ->
    print_colour(Colour, Format, []).

print_colour(Colour, Format, Args) ->
    ColourEsc =
	case Colour of
	    cyan -> "\033[36;1m"
	end,
    {Pre, Post} =
	case get(colour_output) of
	    true -> {ColourEsc, "\033[0;0m"};
	    _    -> {"", ""}
	end,
    io:format(Pre ++ Format ++ Post, Args).
