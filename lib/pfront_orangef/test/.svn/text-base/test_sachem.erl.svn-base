-module(test_sachem).

-export([run/0, online/0]).

-include("../../pserver/include/pserver.hrl").

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
    {"TOP_NUM", "12"}, {"DATE_DEB", "20091231"}, {"HEURE_DEB", "123"},
    {"DATE_FIN", "20101231"}, {"HEURE_FIN", "456"}, {"PCT_MONTANT", "1234"},
    {"TOP_NUM", "444"}, {"DATE_DEB", "20080101"}, {"HEURE_DEB", "start"},
    {"DATE_FIN", "20100101"}, {"HEURE_FIN", "end"}, {"PCT_MONTANT", "9876"}]).
-define(TEST_LIST_REPEAT, [{"key1", "1"}, {"key2","2"}, {"start", "3"},
        {"repeat1","a1"}, {"repeat2","a2"}, {"repeat1","b1"}, {"repeat2","b2"},
        {"repeat1","c1"}, {"repeat2","c2"}, {"key3","3"}]).
-define(REPEAT_SECTION, [{"start", "3"},{"repeat1","a1"}, {"repeat2","a2"},
        {"repeat1","b1"}, {"repeat2","b2"},{"repeat1","c1"}, {"repeat2","c2"}]).


online() ->
    ok.

run() ->
    test_check_input(),
    test_update_session(),
    test_scan_list(),
    test_decode_repeat_list().

test_check_input() ->
    ok = ?TEST_MODULE:check_mparamlist([], [], "svc"),
    ok = check_list(?TEST_LIST), 
    {nok, "svc.key1 should be 1"} = (catch check_list(?TEST_LIST_FIX_ERROR)),
    {nok, "svc.key_error doesn't exist"} = (catch check_list(?TEST_LIST_WRONG_KEY)),
    {nok, "svc.key3 is not an integer"} = (catch check_list(?TEST_LIST_NO_INT)),
    {nok, "svc.key2 input wrong"} = (catch check_list(?TEST_LIST_NO_STRING)),
    {nok, "svc.key2 length should be 3"} = (catch
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
    #session{svc_data=[{{"maj_nopt", "PCT_MONTANT"}, "9876"},
    {{"maj_nopt", "HEURE_FIN"},"end"},{{"maj_nopt", "DATE_FIN"}, "20100101"},
    {{"maj_nopt", "HEURE_DEB"}, "start"},{{"maj_nopt", "DATE_DEB"}, "20080101"}, 
    {{"maj_nopt", "TOP_NUM"}, "444"}, {{"maj_nopt","REPEAT_PARA"}, R}, 
    {{"maj_nopt","key2"},"2"}, {{"maj_nopt","key1"}, "1"}]} =
   ?TEST_MODULE:input_all_params_in_session(#session{},
            ?PARAM_LIST_SPECIFIC, "maj_nopt").

request_string() ->
    "<sac:params>"
    "<sac:name>TOP_NUM</sac:name>"
    "<sac:type>Short</sac:type>"
    "<sac:value>12</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>DATE_DEB</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>20091231</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_DEB</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>123</sac:value>"
    "</sac:params>"   
    "<sac:params>"
    "<sac:name>DATE_FIN</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>20101231</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_FIN</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>456</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>PCT_MONTANT</sac:name>"
    "<sac:type>Long</sac:type>"
    "<sac:value>1234</sac:value>"
    "</sac:params>"   
    "<sac:params>"
    "<sac:name>TOP_NUM</sac:name>"
    "<sac:type>Short</sac:type>"
    "<sac:value>444</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>DATE_DEB</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>20080101</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_DEB</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>start</sac:value>"
    "</sac:params>"   
    "<sac:params>"
    "<sac:name>DATE_FIN</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>20100101</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>HEURE_FIN</sac:name>"
    "<sac:type>String</sac:type>"
    "<sac:value>end</sac:value>"
    "</sac:params>"
    "<sac:params>"
    "<sac:name>PCT_MONTANT</sac:name>"
    "<sac:type>Long</sac:type>"
    "<sac:value>9876</sac:value>"
    "</sac:params>".

test_scan_list() ->
    {[], ?PARAM_LIST_COMMON} = ?TEST_MODULE:scan_list(?PARAM_LIST_COMMON,
        {"start",123}, []),
    {?REPEAT_SECTION, ?PARAM_LIST_COMMON} = 
        ?TEST_MODULE:scan_list(?TEST_LIST_REPEAT, {"start",2}, []).

test_decode_repeat_list() ->
    [] = ?TEST_MODULE:decode_repeat_list([], 3, "repeat"),
    [{"start", "3"},{"repeat", [["a1", "a2"],["b1", "b2"],
        ["c1", "c2"]]}] = 
    ?TEST_MODULE:decode_repeat_list(?REPEAT_SECTION, 2, "repeat"),
    [{"start","0"}] =
    ?TEST_MODULE:decode_repeat_list([{"start","0"}],2,"repeat").


