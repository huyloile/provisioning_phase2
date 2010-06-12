-module(test_svc_soap_interface_orangef).
-export([run/0,online/0]).
-compile(export_all).


-include("../../pserver/include/page.hrl").
-include("../../pfront/include/smpp_server.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../../pdist/include/generic_router.hrl").

-define(access_code, "#111").
-define(SIMULATOR, fake_http_server).
-define(NODE, possum@localhost).
-define(TEST_MSISDN, "+33670315187").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
online() ->
    {ok, StartUrl} = rpc:call(possum@localhost, application, get_env, [pserver,
            start_url]),
    rpc:call(possum@localhost, application, set_env, [pserver, start_url,
            "file:/mcel/acceptance/test/test_soap_interface.xml"]),   

    Tests = test_cases(),
    Files = lists:map(fun launch_test/1,Tests),
    rpc:call(possum@localhost, application, set_env, [pserver, start_url,
                StartUrl]),
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

test_svc_soap_interface_orangef(description) ->
    description("Acceptance test:");
test_svc_soap_interface_orangef(test) ->
    acceptance_test().

internal_test_svc_soap_interface_orangef(description) ->
    description("Internal test:");
internal_test_svc_soap_interface_orangef(test) ->
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
    "Test for plugin for soap interface".

refernce_name() ->
    "test_soap_interface_orangef".

intro() ->
    "This is an unit test for soap interface and template.".

config(Msisdn) ->
    "MSISDN = " ++ Msisdn ++"\n"
        "USSD capability: Phase 2,181 characters or 80 UCS2 encoded"
        " characters both for session_ending and in session messages\n".

feature() ->
   "Test soap interface plugins and template".

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
        {"Test Csl_doscp request",
         test_Csl_doscp},
        {"Test Rec_tck request",
         test_Rec_tck},
        {"Test Csl_op request",
         test_Csl_op},
        {"Test Maj_op request",
         test_Maj_op},
        {"Test Mod_dos request",
         test_Mod_dos},
        {"Test Csl_tck request",
         test_Csl_tck}
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
    %%stop_fake_ussdc() ++
    delete_table() ++
    [].
create_table() ->
    %%proc_lib:start_link(?MODULE,spawn_ets,[]),
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
test_Csl_doscp() ->
    Reply = get_XML_from_file("callCsl_doscp_response.xml"),
    slog:event(trace,?MODULE,fake_reply,[Reply]),
    set_response(Reply) ++ 
    [{ussd2, [{send, ?access_code ++ "*1#"}, {expect, "DOS_NUMID_Value = "
                    "1234567890"}]}
    ] ++ [].

test_Rec_tck() ->
    Reply = get_XML_from_file("callRec_tck_response.xml"),
    slog:event(trace,?MODULE,fake_reply,[Reply]),
    set_response(Reply) ++ 
    [{ussd2, [{send, ?access_code ++ "*2#"}, {expect, "value = "
                    "1234567890"}]}
    ] ++ [].

test_Csl_op() ->
    Reply = get_XML_from_file("callCsl_op_response.xml"),
    slog:event(trace,?MODULE,fake_reply,[Reply]),
    set_response(Reply) ++ 
    [{ussd2, [{send, ?access_code ++ "*3#"}, {expect, "statut = 00"}]}
    ] ++ [].

test_Maj_op() ->
    Reply = get_XML_from_file("callMaj_op_response.xml"),
    slog:event(trace,?MODULE,fake_reply,[Reply]),
    set_response(Reply) ++ 
    [{ussd2, [{send, ?access_code ++ "*4#"}, {expect, "CPP_SOLDE ="
                    " 1234567"}]}
    ] ++ [].

test_Mod_dos() ->
    Reply = get_XML_from_file("callMod_dos_response.xml"),
    slog:event(trace,?MODULE,fake_reply,[Reply]),
    set_response(Reply) ++ 
    [{ussd2, [{send, ?access_code ++ "*6#"}, {expect, "CPP_SOLDE ="
                    " 10000"}]}
    ] ++ [].

test_Csl_tck() ->
    Reply = get_XML_from_file("callCsl_tck_response.xml"),
    slog:event(trace,?MODULE,fake_reply,[Reply]),
    set_response(Reply) ++ 
    [{ussd2, [{send, ?access_code ++ "*9#"}, {expect, "CTK_NUM ="
                    " 1234567"}]}
    ] ++ [].

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

