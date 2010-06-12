-module(svc_soap_interface_orangef).
-export([decode_xmlnode_to_list/6, get_value_by_key/7,incl_value_by_key/4]).

-include("../../xmerl/include/xmerl.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../oma/include/slog.hrl").

decode_xmlnode_to_list(plugin_info, _SvcIn, _XmlNode, _SvcOut, _ResultList, _NextUrl) ->
    #plugin_info{
    help = "This plugin is used to decode a list of reload histories from the"
           "xml node which is retrieved from response following the mapping.\n"
           "The example of Element in the list: [{\"key1\", \"value1\"}, "
           "{\"key2\", \"value2\", ... }]",
    type = command,
    args = [
            {service_in, {oma_type, string},
             "The service who contain the xml node"},
            {xmlNode_name, {oma_type, string},
             "The name of the xml node retrieved from response"},
            {service_result, {oma_type, string},
             "The service who hold the result list"},
            {result_list, {oma_type, string},
             "the name of the history list"},
            {next, {link, []}, "Next page"}
           ]
    };
decode_xmlnode_to_list(abs, _, _, _, _, NextUrl) ->
    [{redirect, abs, NextUrl}];
decode_xmlnode_to_list(Session, SvcIn, XmlNode, SvcOut, ResultList, NextUrl) ->
    case variable:get_value(Session, {SvcIn, XmlNode}) of
        not_found  ->
            slog:event(trace, ?MODULE, error, xml_node_not_found),
            {redirect, Session, NextUrl};
        Xml ->
            slog:event(trace, ?MODULE, xml_node, Xml),
            Result = xmerl:export(Xml,
                get_list_from_soap_response_xmerl),
            slog:event(trace, ?MODULE, response_info_list, Result),
            NewSession = variable:update_value(Session, {SvcOut, ResultList},
                Result),
            {redirect, NewSession, NextUrl}
    end.

get_value_by_key(plugin_info, _SvcIn, _List, _Key, _SvcOut, _Result, _NextUrl) ->
    #plugin_info{
    help = "This plugin is used to get a value from a list, and set the value"
           " into variable.\n"
           "The list is like: [{\"key1\", \"value1\"}, {\"key2\", \"value2\", ... }]"
           ". Input the key = key1, the value1 will be retrieved.",
    type = command,
    args = [
            {service_in, {oma_type, string},
             "The service which contains the response information list"},
            {list_name, {oma_type, string},
             "The name of the list"},
            {key, {mcel_type, dyn_string},
             "key"},
            {service_result, {oma_type, string},
             "The service who hold the info variable"},
            {result_list, {oma_type, string},
             "the name of the variabel"},
            {next, {link, []}, "Next page"}
           ]
    };
get_value_by_key(abs, _, _, _, _, _, NextUrl) ->
    [{redirect, abs, NextUrl}];
get_value_by_key(Session, SvcIn, List, Key, SvcOut, Result, NextUrl) ->
    case variable:get_value(Session, {SvcIn, List}) of
        not_found  ->
            slog:event(trace, ?MODULE, error, list_not_found),
            {redirect, Session, NextUrl};
        Info_List ->
            slog:event(trace, ?MODULE, list, Info_List),
            slog:event(trace, ?MODULE, key, Key),
            Value = get_value_by_key(Key, Info_List),
            NewSession = variable:update_value(Session, {SvcOut, Result},
                Value),
            {redirect, NewSession, NextUrl}
    end.

incl_value_by_key(plugin_info, _SvcIn, _ListName, _Key) ->
    (#plugin_info{
        help = "This plugin displays a value which is retrieved from a list.\n"
        "For Example: the list is [{\"key1\", \"value1\"}, {\"key2\", "
        "\"value2\", ... }]. When \"key1\" is input, value1 will be displayed.",
        type = function,
        args = 
        [{service_in, {oma_type, string}, 
          "Service name which holds the list"},
         {list_name, {oma_type, string}, 
          "the name of the list"},
         {key, {mcel_type, dyn_string},
          "the key"}]});
incl_value_by_key(abs, _SvcIn, _ListName, _Key) ->
    [{pcdata, "the value form key"}];
incl_value_by_key(Session, SvcIn, ListName, Key) ->
    List = variable:get_value(Session, {SvcIn, ListName}),
    slog:event(trace, ?MODULE, list, List),
    [{pcdata, get_value_by_key(Key, List)}].

get_value_by_key(Key, List) ->
    case lists:keysearch(Key, 1, List) of
        {value, {Key, Value}} ->
           Value;
        V ->
           slog:event(trace, ?MODULE, searchresult, V),
           "not_found"
    end.
