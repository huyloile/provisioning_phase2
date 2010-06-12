-module(import_wap_push_capabilities).
-export([csv_to_orangef_erlang_module/1, csv_to_mnesia/1]).
-export([test/0]).
-include("../../pserver/include/pserver.hrl").

%%% For offline, occasional use: reads a CSV file provided by Orange when
%%%   svc_wap_push_orangef was developed, containing the WAP Push capabilities
%%%   of some handsets, and either produces the wap_push_capability.erl module,
%%%   or updates the 'terminal' mnesia table (which can then be exported to
%%%   possum/optional_data/tac_database.csv).


%% ----------------- Exported functions: to be called by hand  --------------

%% Updates 'wap_push' fields in 'terminal' mnesia table.
%% Requires a running Cellcube.
csv_to_mnesia(Input_file_name) ->
    Capabilities = read_csv(Input_file_name),
    Fun = 
	fun() ->
		{Found,Total,Warnings} =
		    lists:foldl(
		      fun({Tac, Caps}, {Found, Total, Warnings}) ->
			      case mnesia:read(terminal, Tac, write) of
				  [#terminal{}=R] ->
				      New_warnings =
					  case R#terminal.wap_push of
					      undefined ->
						  Warnings;
					      Other ->
						  [{Tac, Other} | Warnings]
					  end,
				      Wap_push = to_property_string(Caps,""),
				      RR = R#terminal{wap_push=Wap_push},
				      mnesia:write(RR),
				      {Found + 1, Total + 1, New_warnings};
				  [] ->
				      {Found, Total + 1, Warnings}
			      end
		      end,
		      {0,0,[]},
		      Capabilities),
		{{found,Found},
		 {not_found,Total-Found},
		 {already_defined, length(Warnings), Warnings}}
	end,
    mnesia:transaction(Fun).

%% Creates a wap_push_capability.erl module needed by svc_wap_push_orangef.erl
csv_to_orangef_erlang_module(Input_file_name) ->
    Records = read_csv(Input_file_name),
    Code = to_orangef_erlang_module(Records),
    ok = file:write_file("wap_push_capability.erl", list_to_binary(Code)).

%% -------------------- Sub-functions --------------------

read_csv(Input_file_name) ->
    {ok, Binary} = file:read_file(Input_file_name),
    Text = binary_to_list(Binary),
    Lines = tl(string:tokens(Text, "\n")),
    [csv_record_to_term(L) || L <- Lines].
    
csv_record_to_term(Line) ->
    {10, _, Record} =
	lists:foldl(
	  fun($,, {3, Word, {}}) -> {4, [], {lists:reverse(Word), []}};
	     ($,, {7, "1", {Tac, Capabilities}}) -> {8, [], {Tac, [clickable|Capabilities]}};
	     ($,, {8, "1", {Tac, Capabilities}}) -> {9, [], {Tac, [indication|Capabilities]}};
	     ($,, {N, _, Record}) -> {N + 1, [], Record};
	     (Char, {Count, Word, Record}) -> {Count, [Char|Word], Record}
	  end,
	  {1, [],{}},
	  Line),
    Record.

to_orangef_erlang_module(Records) ->
    Head = "-module(wap_push_capability).\n"
	"-export([tac/1]).\n\n",
    Body = 
	lists:reverse(
	  lists:foldl(
	    fun({Tac, Capabilities}, Acc) ->
		    case lists:member(clickable, Capabilities) of
			true ->
			    Clause = ["tac(\"", Tac, "\") -> clickable_sms;\n"],
			    [Clause | Acc];
			false ->
			    case lists:member(indication, Capabilities) of
				true ->
				    Clause = ["tac(\"", Tac, "\") -> wap_push;\n"],
				    [Clause | Acc];
				false ->
				    Acc
			    end
		    end
	    end,
	    [],
	    Records)),
    Tail = "tac(_) -> unknown.\n",
    lists:flatten([Head ,Body, Tail]).

%% -------------------- TESTS ----------------------------------------

test_line(wap_push) ->
    "\"ALCATEL\",\"ALCATEL One Touch 156\",35437500,18648,\"1\",\"C\",,1,\"CMO\",";

test_line(clickable_sms) ->
    "\"ALCATEL\",\"ALCATEL One Touch 531\",35142835,5091,\"1\",\"A\",1,,\"CMO\",";

test_line(both) ->
    "\"NOKIA\",\"NOKIA N70\",35792700,4,\"1\",\"C\",1,1,\"CMO\",";

test_line(extra_field) ->
    "\"MOTOROLA\",\"MOTOROLA V220\",35387200,35566,\"1\",\"B\",,1,\"CMO\",\"M\"".

test_output1() ->
    "-module(wap_push_capability).\n"
	"-export([tac/1]).\n\n"
	"tac(\"1\") -> wap_push;\n"
	"tac(\"2\") -> clickable_sms;\n"
	"tac(_) -> unknown.\n".

test_output2() ->
    "-module(wap_push_capability).\n"
	"-export([tac/1]).\n\n"
	"tac(\"51\") -> clickable_sms;\n"
	"tac(\"75\") -> wap_push;\n"
	"tac(\"78\") -> wap_push;\n"
	"tac(_) -> unknown.\n".

test() ->
    test_csv_record_to_term(),
    test_to_erlang(),
    test_to_property_string(),
    ok.

test_csv_record_to_term() ->
    {"35437500", [indication]} = csv_record_to_term(test_line(wap_push)),
    {"35142835", [clickable]} = csv_record_to_term(test_line(clickable_sms)),
    {"35387200", [indication]} = csv_record_to_term(test_line(extra_field)),
    {"35792700", [indication, clickable]} = csv_record_to_term(test_line(both)).

test_to_erlang() ->
    Expected1 = test_output1(),
    Expected1 = to_orangef_erlang_module([{"1", [indication]}, {"2", [clickable]}]),
    Expected2 = test_output2(),
    Expected2 = to_orangef_erlang_module(
		  [{"51", [clickable]},
		   {"75", [indication]},
		   {"78", [indication]}]).

test_to_property_string() ->
    "" = to_property_string([], ""),
    "indication" = to_property_string([indication], ""),
    "loading, indication, clickable" =
	to_property_string([loading, indication, clickable], "").

to_property_string([P | Ps], "") ->
    to_property_string(Ps, atom_to_list(P));
to_property_string([P | Ps], String) ->
    to_property_string(Ps, String ++ ", " ++ atom_to_list(P));
to_property_string([], String) ->
    String.
