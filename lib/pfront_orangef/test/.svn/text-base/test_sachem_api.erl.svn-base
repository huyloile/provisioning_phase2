-module(test_sachem_api).

-export([run/0, online/0]).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../../pdist/include/generic_router.hrl").


-define(SIMULATOR, fake_http_server).
-define(NODE, possum@localhost).
-define(TEST_MSISDN, "+33670315187").


-define(TEST_MODULE, sachem).
-define(TEST_LIST, [{"key1", "1"}, {"key2", "333"}, {"key3",
            "456"},{"key4","1234"},{"key5","b"},{"key6", "abc"}]).
-define(TEST_LIST_FIX_ERROR, [{"key1", "3"}, {"key2", "333"}, {"key3", "456"}]).
-define(TEST_LIST_WRONG_KEY, [{"key_error", "123"}]).
-define(TEST_TYPES, [{"key1", fixed, "1"}, {"key2", string, 3},{"key3",int},
        {"key4", int, 4}, {"key5",in_list,["a", "b", "c"]}, {"key6", string}]).
-define(TEST_LIST_NO_INT, [{"key3", "aaa123"}]).
-define(TEST_LIST_NO_STRING, [{"key1", "1"}, {"key2", abc}]).
-define(TEST_LIST_STRING_LEN_ERROR, [{"key1", "1"}, {"key2", "ddddd"}]).
-define(TEST_LIST_OUT_RANGE, [{"key1", "1"}, {"key5", "cc"}]).
-define(TEST_LIST_INT_LEN_ERROR, [{"key4","1111111"}]).


-define(PARAM_LIST_COMMON, [{"key1","1"}, {"key2", "2"}, {"key3", "3"}]).
-define(PARAM_LIST_SPECIFIC, [{"key1","1"}, {"key2", "2"}, {"NB_OP", "2"},
    {"TOP_NUM", "6"}, {"DATE_DEB", "-"}, {"HEURE_DEB", "-"},
    {"DATE_FIN", "-"}, {"HEURE_FIN", "-"}, {"PCT_MONTANT", "0"},
    {"TOP_NUM", "7"}, {"DATE_DEB", "-"}, {"HEURE_DEB", "-"},
    {"DATE_FIN", "-"}, {"HEURE_FIN", "-"}, {"PCT_MONTANT", "0"}]).
-define(TEST_LIST_REPEAT, [{"key1[0]", "1"}, {"key2[0]","2"},{"repeat1[1]","b1"},
        {"start[0]", "3"}, {"repeat2[0]","a2"},{"repeat1[0]","a1"},
        {"repeat2[1]","b2"}, {"repeat2[2]","c2"},
        {"repeat1[2]","c1"}, {"key3[0]","3"}]).
-define(ERROR_LIST, [{"key1[0]","1"},{"start[0]", "3"},{"repeat1[1]","a1"}, {"repeat2[1]","a2"},
        {"repeat1[2]","b1"}, {"repeat2[2]","b2"}]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run() ->
    test_check_input(),
    test_update_session(),
    test_get_repeated_section().

test_check_input() ->
    ok = ?TEST_MODULE:check_mparamlist([], [], "svc"),
    ok = check_list(?TEST_LIST), 
    {nok, "svc.key1 should be 1"} = (catch check_list(?TEST_LIST_FIX_ERROR)),
    {nok, "svc.key_error doesn't exist"} = (catch check_list(?TEST_LIST_WRONG_KEY)),
    {nok, "svc.key3 is not an integer"} = (catch check_list(?TEST_LIST_NO_INT)),
    {nok, "svc.key2 input wrong"} = (catch check_list(?TEST_LIST_NO_STRING)),
    {nok, "svc.key2 max length should be 3"} = (catch
        check_list(?TEST_LIST_STRING_LEN_ERROR)),
    {nok, "svc.key5 out of range [\"a\",\"b\",\"c\"]"} =
        (catch check_list(?TEST_LIST_OUT_RANGE)),
    {nok, "svc.key4 length should be 4"} = (catch check_list(
                ?TEST_LIST_INT_LEN_ERROR)). 

check_list(List) ->
    ?TEST_MODULE:check_mparamlist(List, ?TEST_TYPES, "svc").

test_update_session() ->
    #session{} = ?TEST_MODULE:input_all_params_in_session(#session{},[],"svc"),
    #session{svc_data=[{{"svc","key3"}, "3"},
            {{"svc","key2"},"2"},{{"svc","key1"}, "1"}]} = 
        ?TEST_MODULE:input_all_params_in_session(#session{}, ?PARAM_LIST_COMMON,
        "svc"),
    R = request_string(),
    #session{svc_data=[
    {{"maj_nopt", "PCT_MONTANT"}, "0"},
    {{"maj_nopt", "HEURE_FIN"},"-"},{{"maj_nopt", "DATE_FIN"}, "-"},
    {{"maj_nopt", "HEURE_DEB"}, "-"},{{"maj_nopt", "DATE_DEB"}, "-"}, 
    {{"maj_nopt", "TOP_NUM"}, "7"},   
    {{"maj_nopt","REPEAT_PARA"},R},{{"maj_nopt","NB_OP"},"2"}, 
    {{"maj_nopt","key2"},"2"}, {{"maj_nopt","key1"}, "1"}]}
    = ?TEST_MODULE:input_all_params_in_session(#session{},
            ?PARAM_LIST_SPECIFIC, "maj_nopt").

request_string() ->
    "<sac:params>"
    "<sac:name>TOP_NUM@@1</sac:name>"
    "<sac:type>Short</sac:type>"
    "<sac:value>6</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>DATE_DEB@@1</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_DEB@@1</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"   
    "<sac:params>"
    "<sac:name>DATE_FIN@@1</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_FIN@@1</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>PCT_MONTANT@@1</sac:name>"
    "<sac:type>Long</sac:type>"
    "<sac:value>0</sac:value>"
    "</sac:params>"   
    "<sac:params>"
    "<sac:name>TOP_NUM@@2</sac:name>"
    "<sac:type>Short</sac:type>"
    "<sac:value>7</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>DATE_DEB@@2</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_DEB@@2</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"   
    "<sac:params>"
    "<sac:name>DATE_FIN@@2</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_FIN@@2</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>-</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>PCT_MONTANT@@2</sac:name>"
    "<sac:type>Long</sac:type>"
    "<sac:value>0</sac:value>"
    "</sac:params>".


test_get_repeated_section() ->
    RepeatKeyList = ["repeat1","repeat2"],
    {[],[]} = ?TEST_MODULE:get_repeated_section([], RepeatKeyList,"start[0]","repeat"),
    {[{"repeat", [["a1", "a2"],["b1", "b2"],["c1", "c2"]]}],
     [{"key1[0]", "1"}, {"key2[0]","2"},{"start[0]", "3"},{"key3[0]","3"}]} = 
        ?TEST_MODULE:get_repeated_section(?TEST_LIST_REPEAT, RepeatKeyList,
            "start[0]", "repeat"),
    {nok,_} = ?TEST_MODULE:get_repeated_section(?ERROR_LIST, RepeatKeyList,
              "start[0]","repeat").






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
online() ->
    Tests = test_cases(),
    Files = lists:map(fun launch_test/1,Tests),
    MakeEntity =
        fun(File) ->
            " <!ENTITY"++ File ++ "SYSTEM \"tr/" ++ File ++ ".xml\">~n"
        end,
    MakeRef =
        fun(File) ->
            "   &" ++ File ++ ";~n"
        end,
    Entities = lists:flatten(lists:map(MakeEntity,Files)),
    Refs = lists:flatten(lists:map(MakeRef,Files)),
    io:format("Entities:~n" ++ Entities ++ "~nReferences:~n" ++ Refs ++ "~n"),
    ok. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          Main function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_cases() ->
    L = [?MODULE_STRING],%"internal_"++?MODULE_STRING],
    lists:map(fun list_to_atom/1,L).

launch_test(Fun) ->
    {Title,Ref,Intro,Config,Feature,Doc} = apply(?MODULE,Fun,[description]),
    FileSuffix = atom_to_list(Fun),
    receive after 200 -> ok end,
    ok = testreport:start_link_logger(
        "../doc/" ++ FileSuffix ++ ".html",
        [{title,Title},
         {ref,Ref},
         {intro,Intro},
         {config,Config},
         {feature,Feature},
         {doc,Doc}
        ]),
    test_service:online(apply(?MODULE,Fun,[test])),
    testreport:stop_logger(),
    FileSuffix.

test_sachem_api(description) ->
    description("Acceptance test:");
test_sachem_api(test) ->
    acceptance_test().

internal_test_sachem_api(description) ->
    description("Internal test:");
internal_test_sachem_api(test) ->
    internal_test().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%      Description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
description(Prefix) ->
    {Prefix ++ service_description(),
     refernce_name(),
     intro(),
     config(?TEST_MSISDN),
     feature(),
     additional_doc()
    }.

service_description() ->
    "Test for sachem APIs".

refernce_name() ->
    "test_sachem_api".

intro() ->
    "This is an unit test for sachem APIs.".

config(Msisdn) ->
    "MSISDN = " ++ Msisdn ++"\n"
        "USSD capability: Phase 2,181 characters or 80 UCS2 encoded"
        " characters both for session_ending and in session messages\n".

feature() ->
   "Test sachem APIs".

additional_doc() ->
    "NA".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       acceptance test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acceptance_test() ->
    init_script()++
    [{title,"prerequisites:The subscriber has a SIM card can access this
             service"}] ++
    generate_test_set(acceptance_test_set()) ++ [].

acceptance_test_set() ->
    [
     {"test_consult_account",
     test_consult_account},
     {"test_consult_account_error",
     test_consult_account_error},   
     {"test_recharge_ticket",
     test_recharge_ticket}
    ].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%      internal test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
internal_test() ->
    init_script() ++
        [{title,"prerequisites:The subscriber has a SIM card can access this
                 service"}] ++
                 generate_test_set(internal_test_set()) ++ stop_script().


internal_test_set() ->
    acceptance_test_set() ++
        [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         generate and init function<to generate title and invoke test function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init_script() ->
    [
     {title,"Functional tests: " ++ service_description()},
     {connect_smpp,{"localhost",7431}},
     {msaddr,{international, isdn, ?TEST_MSISDN}}
    ] ++ 
   test_util:switch_interface(disabled,xml_generic) ++
   test_util:switch_interface(enabled,xml_generic) ++
   test_util:switch_interface(enabled,soap_interface) ++
   %%start_httpd_ucip() ++
   create_table() ++     [].

stop_script() ->
    delete_table() ++
    [].
create_table() ->
    [{title,"create new table................."},
     {erlang,[{rpc,call,[?NODE,?SIMULATOR,create_ets,[]]}]}].

delete_table() ->
    Pid = self(),
    [{title,"delete table....."},
        {erlang,[{rpc,call,[?NODE,?SIMULATOR,delete_ets,[Pid]]}]}
    ].

generate_test_set(L) ->
    {_,Tests} = lists:foldl(fun generate_test/2,{1,[]},L),
    Tests.

generate_test({Title,Fun},{N,Acc}) ->
    {N+1,Acc ++ ["Test " ++ integer_to_list(N) ++ ":" ++ Title]
     ++ ?MODULE:Fun()}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%              test function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_consult_account() ->
    Reply = get_XML_from_file("callCsl_doscp_response.xml"),
%%    Reply = get_XML_from_file("TEST_XML2.xml"),
    set_response(Reply) ++
    [{erlang, [{?MODULE, test_consult_account_act, []}]}]++
    [].

test_consult_account_act() ->
    Result = rpc:call(?NODE, ?TEST_MODULE, consult_account,
        [#session{svc_data=none},[{"CLE","0"},{"IDENTIFIANT","0680890041"}],
           [{"DOS_ACTIV","1"}]]),
   {ok,{_Session,
           [{"FML32_SAC_PTF_NUM_RECEVEUR[0]","307"},
            {"FML32_SAC_CPP_SOLDE[0]","54950"},
            {"FML32_SAC_TCP_NUM_RECEVEUR[0]","93"}]}} =
   Result.

test_consult_account_error() ->
    Reply = get_XML_from_file("callCsl_doscp_response_error.xml"),
    set_response(Reply) ++
    [{erlang, [{?MODULE, test_consult_account_error_act, []}]}]++
    [].

test_consult_account_error_act() ->
    Result = rpc:call(?NODE, ?TEST_MODULE, consult_account,
        [#session{svc_data=none},[{"VERSION","2"},{"CLE","0"},{"IDENTIFIANT","0680890041"}],
           [{"DOS_ACTIV","1"}]]),
   {nok, _} = Result.

test_recharge_ticket() ->
    Reply = get_XML_from_file("callRec_tck_response.xml"),
    set_response(Reply) ++
    [{erlang, [{?MODULE, test_recharge_ticket_act, []}]}]++
    [].

test_recharge_ticket_act() ->
    Result = rpc:call(?NODE, ?TEST_MODULE, recharge_ticket,
        [#session{svc_data=none},[{"DOS_NUMID","12345"},{"NUM_CR","9004122222"},
                {"TRC_NUM", "1"}, {"CANAL_NUM", "12"}], []]),
   {ok,{_Session,
           [{"TCK_NSTE","1234567890"},{"TTK_NUM","123"},{"CTK_NUM","23"},{"DOS_DATE_LV","123242142"},
            {"STATUT","00"}, {"NB_CPT","2"},{"CPT_PARAMS",[["1","20080101","1234","3","4","123456"],
             ["2","20090101","12444","7","8","373737"]]}]}} =
   Result.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%   Start http
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_XML_from_file(FileName)->
    Path = "test_xml_reply/"++FileName,
    {ok , Binary}= file:read_file(Path),
    binary_to_list(Binary).

set_response(Resp)->
    [{erlang,
         [{rpc, call, 
             [?NODE, ?SIMULATOR, set_response_list, [[Resp]]]}]}].
    
debug(true) ->
    dbg:tracer(),
    dbg:p(all, [c]),
    %dbg:tpl(xml_request, [{'_', [], [{return_trace}]}]),
    %dbg:tpl(xml_generic, [{'_', [], [{return_trace}]}]),
    dbg:tpl(customer_information_interface, process, [{'_', [], [{return_trace}]}]),
    ok;
debug(_) ->
    ok.

