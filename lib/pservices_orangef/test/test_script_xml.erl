-module(test_script_xml).

-export([run/0, online/0]).

-define(ACCEPTED_CHARS_CONDITION,C<127;C==176;C==224;C==231;C==232;C==233;C==234;C==251).

-include("../../pserver/include/page.hrl").

run() ->
    test1(),
    ok.

print_when_possible(ToPrint) ->
    io:format("ERROR (not printable chars are between two %%%):"),
    print_when_possible_int(ToPrint).

print_when_possible_int([]) ->
    io:format("~n");
print_when_possible_int([C|Tail]) 
  when ?ACCEPTED_CHARS_CONDITION ->
    io:format([C]),
    print_when_possible_int(Tail);
print_when_possible_int([C|Tail]) ->
    io:format("%%%~p%%%",[C]),
    print_when_possible_int(Tail).


check_page([#page{items=ITEMS}=Pages|Tail],Acc) ->
    NewAcc=check_page(ITEMS,Acc),
%    io:format("Acc~p~nItem~p~n~n",[NewAcc,ITEMS]),
    check_page(Tail,NewAcc);
check_page([{pcdata,Line}|Tail],Acc)->
    NewAcc=check_char(Line,Acc,Line),
    check_page(Tail,NewAcc);
check_page([_|Tail],Acc)->
    check_page(Tail,Acc);
check_page([],Acc) ->
    Acc.

check_char([C|Tail],Acc,Line) when ?ACCEPTED_CHARS_CONDITION ->
    check_char(Tail,Acc,Line);
check_char([C|Tail],Acc,Line) ->
    %% SDi these cases was previously highlighted, but dont know why
    %% C==195;C==168;C==169;C==176;C==244
    check_char(Tail,Acc++"\n"++[Line],Line);
check_char([],Acc,Line)->
    Acc.

read_file(Path,[FileName|Tail],IsSuccess) ->
    File = Path++FileName,
    Acc = case file:read_file_info(File) of
	      {ok,{file_info,_,directory,_,_,_,_,_,_,_,_,_,_,_}} ->
		  {ok,List} = file:list_dir(File),
		  read_file(File++"/",List,IsSuccess);
	      {ok,{file_info,_,regular ,_,_,_,_,_,_,_,_,_,_,_}} ->
		  case lists:prefix("lmx.",lists:reverse(FileName)) of
		      true ->
			  XML = xmerl2page:eval(File,undefined),
			  {pages,_,_,_,Pages} = XML,
			  Res=check_page(Pages,[]),
			  Res;
		      _ -> not_xml,
			   io:format("NOT XML~n"),
			   []
		  end
	  end,
    ThisFileSuccess = (Acc == []) or (Acc == true),
    NewIsSuccess = ThisFileSuccess and IsSuccess,
    case ThisFileSuccess of
	false -> 
	    io:format("~nFile ->~p~n",[File]),
	    print_when_possible(lists:flatten(Acc));
	_ -> ok
    end,
    read_file(Path,Tail,NewIsSuccess);

read_file(Path,[],Acc) ->
    Acc.

test_dir(Path) ->
    List = filelib:wildcard(Path++"*/*.xml"),
    read_file("./",List,true).
    

test1() ->
    IsSuccess1 = test_dir("../priv/xml/"),
    IsSuccess2 = test_dir("../../../run/xml/mcel/acceptance/"),
    IsSuccess1 = true,
    IsSuccess2 = true,
    ok.

online() ->
    ["TEST OK"].

