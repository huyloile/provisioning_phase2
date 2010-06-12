-module(test_SMPP37).
-export([run/0,online/0]).

run() ->
    PDU = test_pdu(),
    {ok, BinDL} = asn1ct:encode('SMPP37', 'SMPP-PDU', PDU),
    %% Bin = lists:flatten(BinDL),    % For asn1ct(..., [ber]).
    Bin = list_to_binary(BinDL),   % For asn1ct(..., [ber_bin]).
    N = 5000,
    T0 = unixmtime(),
    encode(N, PDU),
    T1 = unixmtime(),
    decode(N, Bin),
    T2 = unixmtime(),
    io:format("SMPP37  encode: ~p/s,  decode: ~p/s~n",
	      [(N*1000) div (T1-T0), (N*1000) div (T2-T1)]).

online() ->
    ok.

encode(0, PDU) -> ok;
encode(N, PDU) ->
    {ok, Bin} = asn1ct:encode('SMPP37', 'SMPP-PDU', PDU),
    encode(N-1, PDU).

decode(0, Bin) -> ok;
decode(N, Bin) ->
    {ok, PDU} = asn1ct:decode('SMPP37', 'SMPP-PDU', Bin),
    decode(N-1, Bin).

unixmtime() -> {MS,S,US} = now(), (MS*1000000+S)*1000 + US div 1000.

test_pdu() ->          {'SMPP-PDU',259,
                        asn1_NOVALUE,
                        1008,
                        {'data-sm',{'DATA-SM-BODY',
                                       "USSD",
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       subscriberNumber,
                                       private,
                                       "66040367",
                                       [0,0,0,0,0,0,0,1],
                                       [0,0,0,0,0,0,0,1],
                                       [0,0,0,0,0,0,0,0],
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       [173,
                                        86,
                                        121,
                                        140,
                                        126,
                                        183,
                                        90,
                                        163,
                                        152,
                                        108,
                                        54,
                                        138,
                                        201,
                                        102,
                                        180,
                                        26],
                                       asn1_NOVALUE,
                                       "<0.37.0>",
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       asn1_NOVALUE,
                                       [16],
                                       asn1_NOVALUE}}}.
