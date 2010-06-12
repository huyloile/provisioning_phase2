-module(get_list_from_soap_response_xmerl).

-export(['#xml-inheritance#'/0]).
-export(['#root#'/4, '#element#'/5, '#text#'/1]).

-include("../../xmerl/include/xmerl.hrl").
-define(PREFIX, "FML32_SAC_").

'#xml-inheritance#'() ->
    [].

%% The '#text#' function is called for every text segment.
'#text#'(Text) ->
    [].

%% The '#root#' tag is called when the entire structure has been
%% exported. It does not appear in the structure itself.

'#root#'(Data, Attrs, [], E) ->
    lists:flatten(Data).

%% The '#element#' function is the default handler for XML elements.
'#element#'('item', Data, Attrs, Parents, 
    #xmlElement{content=[
            #xmlElement{content=[#xmlText{value=Key}]},
            #xmlElement{content=[#xmlText{value=Value}]}
        ]}) ->
    {remove_prefix(Key),remove_space(Value)};
'#element#'('item', Data, Attrs, Parents, 
    #xmlElement{content=[
            #xmlElement{content=[#xmlText{value=Key}]},
            #xmlElement{content=[]}
        ]}) ->
    {remove_prefix(Key),""};
'#element#'(Tag, Data, Attrs, Parents, E) ->
    Data.

remove_prefix(Key) ->
    case string:str(Key,?PREFIX) of
        1 -> string:sub_string(Key,11);
        _ -> Key
    end. 

remove_space(Value) ->
    string:strip(Value, both). 
