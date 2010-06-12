-module(proxy_decoder).

-export([decode/2,encode/1]).

%%TERM_SEP is the separator between terms in the binary flow.
-define(TERM_SEP, 131).

decode(<<131,131,97,L,Datab/binary>>, Buff) ->
    %slog:event(trace,?MODULE, catch binary_to_term(Datab)),
    %io:format("~p 1 ~p", [?MODULE, Datab]),
    Sdata = size(Datab),
    if 
	L >  Sdata -> {[], {partial,L,Sdata,Datab}};
        L == Sdata -> bin_dec:to_term(Datab);
	true ->
	    slog:event(trace, ?MODULE, sdata_gt_L),
	    <<Datab1:L/binary,Rest/binary>> = Datab,
	    {FirstTerm, <<>>} = bin_dec:to_term(Datab1),
	    {SecondTerm, Buff1} = decode(Rest, <<>>),
	    {FirstTerm++SecondTerm, Buff1}
    end;

decode(<<131,131,98,L:32,Datab/binary>>, Buff) ->
    Sdata = size(Datab),
    if 
	L >  Sdata -> {[], {partial, L, Sdata, Datab}};
        L == Sdata -> bin_dec:to_term(Datab);
	true ->
	    slog:event(trace, ?MODULE, sdata_gt_L),
	    <<Datab1:L/binary,Rest/binary>> = Datab,
	    {FirstTerm, <<>>} = bin_dec:to_term(Datab1),
	    {SecondTerm, Buff1} = decode(Rest,<<>>),
	    {FirstTerm++SecondTerm, Buff1}
    end;
   
    %slog:event(trace,?MODULE, catch binary_to_term(Datab)),
    %slog:event(trace, ?MODULE, first, {Sdata, L}),
    % io:format("~p 2  ~p", [?MODULE, Datab]),
%    case L > Sdata of
%	true -> {[], {partial,L,Sdata,Datab}};
%        _ -> bin_dec:to_term(Datab)
%    end;

decode(Datab,{partial,L,SBuff,Buff}) when binary(Datab) ->
    Sdatab = size(Datab),
    Sdata  = Sdatab + SBuff,
    if 
	L >  Sdata -> {[], {partial,L,Sdata,<<Buff/binary,Datab/binary>>}};
        L == Sdata -> bin_dec:to_term(<<Buff/binary,Datab/binary>>);
	true ->
	    slog:event(trace, ?MODULE, sdata_gt_L),
	    <<Datab1:L/binary,Rest/binary>> = <<Buff/binary,Datab/binary>>,
	    {FirstTerm, <<>>} = bin_dec:to_term(Datab1),
	    {SecondTerm, Buff1} = decode(Rest,<<>>),
	    {FirstTerm++SecondTerm, Buff1}
    end;
	    
%    case L > Sdata of
%	true -> {[], {partial,L,Sdata,<<Buff/binary,Datab/binary>>}};
%        _ -> bin_dec:to_term(<<Buff/binary,Datab/binary>>)
%    end;

decode(Data, Buf) when binary(Data) ->
    slog:event(trace, ?MODULE, bad_term_data, Data),
    slog:event(trace, ?MODULE, bad_term_buf, Buf),
    {error, bad_term};
decode(Data, Buf) ->
    {error, bad_rcv_data_no_binary}.

encode(Data) ->        
    Datab=term_to_binary(Data),
    Lb=term_to_binary(size(Datab)),
    <<131,Lb/binary,Datab/binary>>.
