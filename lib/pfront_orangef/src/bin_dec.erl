%%%----------------------------------------------------------------------
%%% File    : bin_dec.erl
%%% Purpose : 
%%% Created :  7 May 2004 by ep 
%%%----------------------------------------------------------------------

-module(bin_dec).

-compile(export_all).

-define(TERM_SEP, 131).
-define(SMALL_INT_EXT, 97).      %%integer 8 bits
-define(INT_EXT, 98).            %%integer 32 bits
-define(FLOAT_EXT, 99).          %%float 31 bytes
-define(ATOM_EXT, 100).          %%atome
-define(REF_EXT, 101).           %%reference (i.e. make_ref/0)
-define(PORT_EXT, 102).
-define(PID_EXT, 103).
-define(SMALL_TUPLE_EXT, 104).
-define(LARGE_TUPLE_EXT, 105).
-define(NIL_EXT, 106).
-define(STRING_EXT, 107).
-define(LIST_EXT, 108).
-define(BINARY_EXT, 109).
-define(SMALL_BIG_EXT, 110).
-define(LARGE_BIG_EXT, 111).
-define(NEW_CACHE, 78).
-define(CACHED_ATOM, 67).
-define(NEW_REF_EXT, 114).
-define(FUN_EXT, 117).

-define(MAX_SIZE_TUPLE, 100).
-define(MAX_SIZE_LIST, 100).
-define(MAX_SIZE_BIN, 200).
-define(MAX_SIZE_BIG_EXT, 100).
-define(MAX_SIZE_NEW_CACHE, 100).
-define(MAX_SIZE_NEW_REF_EXT, 100).

%% +type to_term(binary()) -> {[term()], buffer()}.
to_term(<<?TERM_SEP, Data/binary>>) ->
    to_term(<<Data/binary>>, <<>>, []);
to_term(Else) ->
    {error,unable_to_decode}.

%% +type to_term(binary(), buffer()) -> {[term()], buffer()}.
to_term(<<Data/binary>>, {partial_term, AccBin, Bin}) ->
    to_term(<<Bin/binary, Data/binary>>, AccBin, []).

%% +type to_term(binary(),AccBin::binary(), [term()]) -> {[term()], buffer()}.
to_term(<<Data/binary>>, AccBin, Terms) ->
    case extract_subterm(Data, AccBin) of
	%% A full term is in AccBin1 -> convert into term
	%% Rest Data -> treat it
	{ok, <<?TERM_SEP, Rest>>, AccBin1} when binary(Rest), binary(AccBin1) ->
	    slog:event(trace,?MODULE, term_rest),
	    Term=binary_to_term(<<?TERM_SEP, AccBin1/binary>>),
	    to_term(Rest, <<>>, [Term|Terms]);

	%% A full term can be in AccBin1 -> try convert into term
	%% No more data to treat
	{ok, <<>> , AccBin1} when binary(AccBin1) ->
	    case catch binary_to_term(<<?TERM_SEP, AccBin1/binary>>) of 
		{'EXIT', _} -> {lists:reverse(Terms), AccBin1};
		Term ->	{lists:reverse([Term|Terms]), <<>>}
	    end;
	%% A subterm has been extracted, it is housed in AccBin1 -> 
	%% Continue the treatment with Rest 
	{ok, Rest, AccBin1} when binary(Rest), binary(AccBin1) ->
	    to_term(Rest, AccBin1, Terms);

	%%End of data ->  incomplete term 
	%%Here Acc is a part of the term which is already treated.
	{partial_term, AccBin1, Data1} ->
	    {lists:reverse(Terms), {partial_term, AccBin1, Data1}};
	%%Extract_subterm detects a problem in term's syntax
	{bad_binary, Reason} -> 
	    {error,{bad_binary, Reason}}
    end.

%% +type extract_subterm(Bin::binary(), AccBin::binary()) -> 
%%     {ok, Rest::binary(), AccBin::binary()} |
%%     {partial_term, AccBin::binary(), Bin::binary()} |
%%     {bad_binary, Reason}.

extract_subterm(<<?SMALL_INT_EXT, Value:8, Rest/binary>>, Acc) ->
    %%slog:event(trace, ?MODULE, small_int_ext),
    {ok, Rest, <<Acc/binary, ?SMALL_INT_EXT, Value:8>>};

extract_subterm(<<?INT_EXT, Value:32, Rest/binary>>, Acc) ->  
    %%slog:event(trace, ?MODULE, int_ext),
    {ok, Rest, <<Acc/binary, ?INT_EXT, Value:32>>};

%%248 = 31 bytes * 8 bits
extract_subterm(<<?FLOAT_EXT, Value:248, Rest/binary>>, Acc) ->
    %%slog:event(trace, ?MODULE, float_ext),
    {ok, Rest, <<Acc/binary, ?FLOAT_EXT, Value:248>>};

%%Length max is 255 even if the value is stored with 2 bytes. So the 
%%Most Significant Byte must be 0
extract_subterm(<<?ATOM_EXT, 0, Len:8, Rest/binary>> = Bin, Acc) ->
    %%slog:event(trace, ?MODULE, atom_ext, {Len, Rest, Acc}),
    case skip(Len, Rest) of
	partial_term -> 
	    {partial_term, Acc, Bin};
	{Rest1, Content} ->
	    %%slog:event(trace, ?MODULE, atom_ext_content, { Rest, Content}),
	    {ok, Rest1, <<Acc/binary, ?ATOM_EXT, 0, Len:8, Content/binary>>}
    end;

%%Case of MSB =/= 0 => bad binary
extract_subterm(<<?ATOM_EXT, N:8, Len:8, Rest/binary>> = Bin, Acc) ->  
    %%slog:event(trace, ?MODULE, atom_ext),
    {bad_binary, atom_ext_bad_len};


% extract_subterm(<<TermTag:8, NodeTag:8, Rest/binary>> = Bin, Acc) 
%   when TermTag == ?REF_EXT; TermTag == ?PORT_EXT ->
%     {bad_binary, ref_ext_or_port_ext_forbidden};

extract_subterm(<<TermTag:8, NodeTag:8, Rest/binary>> = Bin, Acc) 
  when TermTag == ?REF_EXT; TermTag == ?PORT_EXT ->
    %%slog:event(trace, ?MODULE, ref_port_ext),
    case NodeTag of
 	Tag when Tag == ?ATOM_EXT; Tag == ?CACHED_ATOM; Tag == ?NEW_CACHE ->
 	    case extract_subterm(<<Tag:8, Rest/binary>>, <<>>) of
 		{ok, <<Dummy:14, RestID:18, Creation:8, Rest1/binary>>, AccNode}
 		when Dummy == 0->
 		    {ok, Rest1, <<Acc/binary, TermTag/binary, AccNode/binary, 
 		     Dummy:14, RestID:18, Creation:8>>};
 		{ok, _, _} ->
 		    {partial_term, Acc, Bin};
 		{partial_term, _,_} ->
 		    {partial_term, Acc, Bin};
 		{bad_binary, Reason} -> 
 		    {bad_binary, {ref_or_port_bad_node, Reason}}
 	    end;
 	Else -> 
 	    {bad_binary, {ref_or_port_bad_node, Else}}
    end;

extract_subterm(<<?PID_EXT, NodeTag:8, Rest/binary>> = Bin, Acc) ->
     %%slog:event(trace, ?MODULE, pid_ext),
    {bad_binary, pid_ext_forbidden};

% extract_subterm(<<?PID_EXT, NodeTag:8, Rest/binary>> = Bin, Acc) ->    
%     case NodeTag of
% 	Tag when Tag == ?ATOM_EXT; Tag == ?CACHED_ATOM; Tag == ?NEW_CACHE ->
% 	    case extract_subterm(<<Tag:8, Rest/binary>>, <<>>) of
% 		{ok, <<Dummy:17, RestID:15, Serial:32, Creation:8, Rest1/binary>>,
% 		 AccNode}
% 		when Dummy == 0->
% 		    {ok, Rest1, <<Acc/binary, ?PID_EXT, AccNode/binary, 
% 		     Dummy:17, RestID:15, Serial:32, Creation:8>>};		
% 		{ok, R, A} ->
% 		    {partial_term, Acc, Bin};
% 		{partial_term, _,_} ->
% 		    {partial_term, Acc, Bin};
% 		{bad_binary, Reason} -> 
% 		    {bad_binary, {pid_ext_bad_node, Reason}}
% 	    end;
% 	Else -> 
% 	    {bad_binary, {pid_ext_bad_node, Else}}
%     end;

extract_subterm(<<?SMALL_TUPLE_EXT, Arity:8, Rest/binary>>, AccBin) ->
    %%slog:event(trace, ?MODULE, small_tuple_ext),
    if 
	Arity > ?MAX_SIZE_TUPLE ->  {bad_binary, {small_tuple, exceed_arity}};
	true -> {ok, Rest, <<AccBin/binary, ?SMALL_TUPLE_EXT, Arity:8>>}
    end;

extract_subterm(<<?LARGE_TUPLE_EXT, Arity:32, Rest/binary>>, AccBin) ->
    %%slog:event(trace, ?MODULE, large_tuple_ext),
    if 
	Arity > ?MAX_SIZE_TUPLE ->  {bad_binary, {large_tuple, exceed_arity}};
	true -> {ok, Rest, <<AccBin/binary, ?LARGE_TUPLE_EXT, Arity:32>>}
    end;

extract_subterm(<<?NIL_EXT, Rest/binary>>, AccBin) ->
    %%slog:event(trace, ?MODULE, nil_ext),
    {ok, Rest, <<AccBin/binary, ?NIL_EXT>>};

extract_subterm(<<?STRING_EXT, Len:16, Rest/binary>> = Bin, AccBin) ->
    %%slog:event(trace, ?MODULE, string_ext),
    case skip(Len, Rest) of
	partial_term -> 
	    {partial_term, AccBin, Bin};
	{Rest1, Content} ->
	    {ok, Rest1, 
	     <<AccBin/binary, ?STRING_EXT, Len:16, Content/binary>>}
    end;

extract_subterm(<<?LIST_EXT, N:32, Rest/binary>>, AccBin) ->
    %%slog:event(trace, ?MODULE, list_ext),
    if 
	N > ?MAX_SIZE_LIST ->  {bad_binary, {list_ext, exceed_len}};
	true -> {ok, Rest, <<AccBin/binary, ?LIST_EXT, N:32>>}
    end;	

extract_subterm(<<?BINARY_EXT, Len:32, Rest/binary>>, AccBin) ->
    %%slog:event(trace, ?MODULE, binary_ext),
    if 
	Len > ?MAX_SIZE_BIN ->  {bad_binary, {binary_ext, exceed_len}};
	true -> {ok, Rest, <<AccBin/binary, ?BINARY_EXT, Len:32>>}
    end;

extract_subterm(<<?SMALL_BIG_EXT, N:8, Sign:8, Rest/binary>> = Bin, AccBin) ->
    %%slog:event(trace, ?MODULE, small_big_ext),
    if 
	N > ?MAX_SIZE_BIG_EXT ->  {bad_binary, {small_bignum, exceed_size}};
	true -> 
	    case skip(N, Rest) of
		partial_term -> 
		    {partial_term, AccBin, Bin};
		{Rest1, Content} ->
		    {ok, Rest1, 
		     <<AccBin/binary, ?SMALL_BIG_EXT, N:8,
		     Sign:8, Content/binary>>}
	    end
    end;

extract_subterm(<<?LARGE_BIG_EXT, N:32, Sign:8, Rest/binary>> = Bin, AccBin) ->
    %%slog:event(trace, ?MODULE, large_big_ext),
    if 
	N > ?MAX_SIZE_BIG_EXT ->  {bad_binary, {large_bignum, exceed_size}};
	true -> 
	    case skip(N, Rest) of
		partial_term -> 
		    {partial_term, AccBin, Bin};
		{Rest1, Content} ->
		    {ok, Rest1, 
		     <<AccBin/binary, ?LARGE_BIG_EXT, N:32, Sign:8,
		     Content/binary>>}
	    end
    end;

extract_subterm(<<?NEW_CACHE, Index:8, Len:16, Rest/binary>> = Bin, AccBin) ->
    %%slog:event(trace, ?MODULE, new_cache),
    {bad_binary, new_cache_forbidden};
% extract_subterm(<<?NEW_CACHE, Index:8, Len:16, Rest/binary>> = Bin, AccBin) ->
%     if 
% 	Len > ?MAX_SIZE_NEW_CACHE ->  {bad_binary, {new_cache, exceed_len}};
% 	true ->
% 	    case skip(Len, Rest) of
% 		partial_term -> 
% 		    {partial_term, AccBin, Bin};
% 		{Rest1, Content} ->
% 		    {ok, Rest1, 
% 		     <<AccBin/binary, ?NEW_CACHE, Index:8, Len:16,
% 		     Content/binary>>}
% 	    end
%     end;

extract_subterm(<<?CACHED_ATOM, Index:8, Rest/binary>>, AccBin) ->
    %%slog:event(trace, ?MODULE, cached_atom),
    {ok, Rest, <<AccBin/binary, ?CACHED_ATOM, Index:8>>};

% extract_subterm(<<?NEW_REF_EXT, Len:16, NodeTag:8, Rest/binary>> = Bin, AccBin) 
%   when Len < ?MAX_SIZE_NEW_REF_EXT ->
%     {bad_binary, new_ref_ext_forbidden};

extract_subterm(<<?NEW_REF_EXT, Len:16, NodeTag:8, Rest/binary>> = Bin, AccBin)
  when Len < ?MAX_SIZE_NEW_REF_EXT ->
    %%slog:event(trace, ?MODULE, new_ref_max,{Len, NodeTag,Rest}),
    case NodeTag of
 	Tag when Tag == ?ATOM_EXT; Tag == ?CACHED_ATOM; Tag == ?NEW_CACHE ->
 	    case extract_subterm(<<Tag:8, Rest/binary>>, <<>>) of
 		{ok, <<Creation:8, Dummy:14, RestID:18, Rest1/binary>>, AccNode}
 		when Dummy == 0 ->
 		    %% minus 3 because of fields Dummy and RestID  and creation
 		    Skip = (Len - 1) * 4,
 		    case skip(Skip, Rest1) of
 			partial_term -> {partial_term, AccBin, Bin};
 			{Rest2, Content} ->
 			    {ok, Rest2, <<AccBin/binary, ?NEW_REF_EXT,
 			     Len:16, AccNode/binary, Creation:8, Dummy:14,
 			     RestID:18, Content/binary>>}
 		    end;
 		{ok, _, _} ->
 		    {partial_term, AccBin, Bin};
 		{partial_term, _,_} ->
 		    {partial_term, AccBin, Bin};
 		{bad_binary, Reason} -> 
 		    {bad_binary, {new_ref_bad_node, Reason}}
 	    end;
 	Else -> 
 	    {bad_binary, {new_ref_bad_node, Else}}
    end;

extract_subterm(<<?FUN_EXT, Rest/binary>>, AccBin) ->
    %slog:event(trace, ?MODULE, fun_ext),
    {bad_binary, fun_forbidden};

extract_subterm(Bin, AccBin) ->
    %%slog:event(trace, ?MODULE, default, {Bin, AccBin}),
    {partial_term, AccBin, Bin}.

%% +type skip(integer(), binary()) -> partial_term | {Bin::binary(), Acc::binary()}.
skip(N,Bin) ->
    skip(N,Bin,<<>>).
skip(0, Bin, Acc) ->
    {Bin, Acc};
skip(N, <<>>, Acc) when N > 0 ->
    %%slog:event(trace, ?MODULE, partial_term, N),
    partial_term;
skip(N,<<Bin , Rest/binary>>,Acc) ->
    skip(N-1, Rest, <<Acc/binary,Bin>>).
