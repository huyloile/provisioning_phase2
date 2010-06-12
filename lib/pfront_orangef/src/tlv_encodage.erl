-module(tlv_encodage).
-include("../include/tlv.hrl").

-export([decode_packet/1,encode_packet/3]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Decodage TLV                                     %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type decode_packet(binary()) -> binary().
decode_packet(<<?DEBUT,?DEBUT,?DEBUT,?DEBUT,Appl,?VERSION,
	      ?NO_CLIENT:16/big-signed,
	      Notrans:4/binary,L,Rest/binary>>) when (L band 128) ==0->
    {NoRequest,Params } = decode_request(Rest),
    decode_param(Params);
	  
decode_packet(<<?DEBUT,?DEBUT,?DEBUT,?DEBUT,Appl,?VERSION,NO_CLIENT:2/binary,
	      Notrans:4/binary,L1,L2,Rest/binary>>) ->
    L_= L1 band 2#01111111,
    <<L:2/binary>> = <<L_,L2>>,
    {NoRequest,Params } = decode_request(Rest),
    decode_param(Params);
decode_packet(Else) ->
    slog:event(failure,?MODULE,unknow_header_in_tlv_decodage,Else),
    error.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type decode_request(binary()) -> binary().
decode_request(<<Tag, Len, Param/binary>>) when (Len band 128) ==0  ->
    {Tag, Param};
decode_request(<<Tag, Len1, Len2, Rest/binary>>) ->
    {Tag, Rest}.

%% +type decode_param(binary()) -> {ok , [term()]}.
decode_param(Bin)->
    decode_param(Bin,[]).

%% +type decode_param(binary(),[term()]) -> {ok , [term()]}.
decode_param(Bin,Acc) when size(Bin)=/=0 ->
    {Value, Rest } = decode(Bin),
    decode_param(Rest, [Value|Acc]);
decode_param(<<>>,Acc)->
    {ok, lists:reverse(Acc)}.

%% +type decode(binary()) -> {Value::term(),binary()}.
decode(<<Tag, Len, Rest/binary>>) when Len < 128 ->
    <<Value:Len/binary, Rest1/binary>> = Rest,
    {decode_type(dico_tlv:dico(Tag), Value), Rest1};
decode(<<Tag, Len_1, Rest1/binary>>) ->
    <<Len_2, Rest2/binary>> = Rest1,
    Len = ((Len_1 band 127) bsl 8) bor Len_2,
    <<Value:Len/binary, Rest3/binary>> = Rest2,
    {decode_type(dico_tlv:dico(Tag), Value), Rest3}.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  Encodage TLV                            %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type encode_packet(MobiOrCMO::integer(),binary(),
%%              [{Tag::integer(),Value::term()}]) -> binary().
encode_packet(MobiorCMO,Request, Param)->
    B_Param=encode_param(Param),
    Time=pbutil:unixtime(),
    T = <<Time:32/big-signed>>,
    B_Request = encode_request(Request,B_Param),
    Appl=MobiorCMO,
    L=len(size(B_Request)),
    <<?DEBUT,?DEBUT,?DEBUT,?DEBUT,Appl,?VERSION,?NO_CLIENT:16/big-signed,
    T/binary,L/binary,B_Request/binary>>.

%% +type encode_request(binary(),
%%              [{Tag::integer(),Value::term()}]) -> binary().
encode_request(Request,B_param)->
    L=size(B_param),
    Len=len(L),
    <<Request,Len/binary,B_param:L/binary>>.    

%% +type encode_param([{Tag::integer(),Value::term()}]) -> binary().
encode_param(Param)->    
    encode_param(Param,<<>>).

%% +type encode_param([{Tag::integer(),Value::term()}],binary()) -> binary().
encode_param([{Tag,Value}|T],Acc)->
    P=encode({Tag,Value}),
    encode_param(T,<<Acc/binary,P/binary>>);
encode_param({Tag,Value},Acc)->
    P=encode({Tag,Value}),
    encode_param([],<<Acc/binary,P/binary>>);
encode_param([],Acc) ->
    Acc;
encode_param(E,Acc) ->
    Acc.

%% +type encode({Tag::integer(),Value::term()})-> binary().
encode({Tag,Value}=Args) ->
    Val= encode_type(dico_tlv:dico(Tag),Value),
    Len=size(Val),
    L=len(Len),
    <<Tag,L/binary,Val:Len/binary>>;
encode(Args) ->
     io:format("Args ~p",[Args]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type decode_type(atom(),binary())-> term().
decode_type(string, B) -> binary_to_list(B);
decode_type(octet, <<X:8/unsigned>>) -> X;
decode_type(int, <<A,B,C,D>>)->
    case A band 2#10000000 of 
	2#10000000 ->
	    A1 = A band 2#01111111,
	    <<X:32/big-signed>> = <<A1,B,C,D>>,
	    -X;
	_ ->
	    <<X:32/big-signed>> = <<A,B,C,D>>,
	    X
    end;
decode_type(short, <<A,B>>)->
    case A band 2#10000000 of 
	2#10000000 ->
	    A1 = A band 2#01111111,
	    <<X:16/big-signed>> = <<A1,B>>,
	    -X;
	_ ->
	    <<X:16/big-signed>> = <<A,B>>,
	    X
    end;
decode_type(dcb, X) -> dcb2list(X).

%% +type encode_type(atom(),term())-> binary().
encode_type(string, S) -> list_to_binary(S);
encode_type(octet, X) -> <<X:8/unsigned>>;
encode_type(int, X) when X>=0 -> <<X:32/big-signed>>;
encode_type(int, X) -> 
    <<A,B,C,D>> = <<-X:32/big>>,
	A1 = A bor 2#10000000,
    <<A1,B,C,D>>;
encode_type(short, X) when X>=0-> <<X:16/big-signed>>;
encode_type(short, X) -> 
    <<A,B>> = <<-X:16/big>>,
	A1 = A bor 2#10000000,
    <<A1,B>>;
encode_type(dcb,X) when list(X)-> list2dcb(X).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ששש
%%%% longueur 
%% +type len(integer())-> binary().
len(Len) when Len< 128 ->
    <<Len>>;
len(Len)->
  L = Len bor 2#1000000000000000,
  <<L:16/big-unsigned>>.

%% +type list2dcb(string())-> binary().
list2dcb(X)->
    list2dcb(X,<<>>).

%% +type list2dcb(string(),binary())-> binary().
list2dcb([C1,C2|T],Acc)->
    C=char2dcb(C1)*16+char2dcb(C2), 
    list2dcb(T,<<Acc/binary,C:8/unsigned>>);
list2dcb([C1],Acc)->
    C=char2dcb(C1)*16+char2dcb(" "),  
    <<Acc/binary,C:8/unsigned>>;
list2dcb([],Acc) ->
    Acc.

%% +type dcb2list(binary())-> string().
dcb2list(X)->
    dcb2list(X,[]).

%% +type dcb2list(binary(),string())-> string().
dcb2list(<<A,B/binary>>,Acc)->
    C1 = dcb2char(A div 16),
    case dcb2char(A band 2#00001111) of 
	$?->
	    dcb2list(B,[C1|Acc]);
	E ->
	    dcb2list(B,[E,C1|Acc])
    end;
dcb2list(<<>>,Acc) ->
    lists:reverse(Acc).

%% +type char2dcb(char())-> integer().
char2dcb($0)->
    0;
char2dcb($1)->
    1;
char2dcb($2)->
    2;
char2dcb($3)->
    3;
char2dcb($4)->
    4;
char2dcb($5)->
    5;  
char2dcb($6)->
    6; 
char2dcb($7)->
    7; 
char2dcb($8)->
    8; 
char2dcb($9)->
    9; 
char2dcb($*)->
    10; 
char2dcb($#)->
    11;
char2dcb($-)->
    14; 
char2dcb(E)->
    io:format("Other ~p~n",[E]),
    15.

%% +type dcb2char(integer())-> char().
dcb2char(0)->
    $0;
dcb2char(1) ->
    $1;
dcb2char(2) ->
    $2;
dcb2char(3) ->
    $3;
dcb2char(4) ->
    $4;
dcb2char(5) ->
    $5;
dcb2char(6) ->
    $6;
dcb2char(7) ->
    $7;
dcb2char(8) ->
    $8;
dcb2char(9) ->
    $9;
dcb2char(10)->
    $*;
dcb2char(11) ->
    $#;
dcb2char(14) ->
    $-;
dcb2char(15) ->
    $?.
