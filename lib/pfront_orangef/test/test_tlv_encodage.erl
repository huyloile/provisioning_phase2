-module(test_tlv_encodage).

-include("../include/tlv.hrl").
-export([run/0,online/0]).

run()->
    %%%%test encodage Packet
    io:format("Test Packet ***************~n"),
    <<?DEBUT,?DEBUT,?DEBUT,?DEBUT,Appl,Vers,Cl1,CL2,
    Notrans:4/binary,L,1,3,6,1,48>> = 
	tlv_encodage:encode_packet(?id_mobi,1,{?PS_CHAR,"0"}),
    %%%% test Encodage longueur de Packet > 128
    io:format("Test Encodage Packet L > 128 ***************~n"),
    <<?DEBUT,?DEBUT,?DEBUT,?DEBUT,?id_all,?VERSION,?NO_CLIENT:16/big-signed,
    Notrans:4/binary,128,177,Rest/binary>>
	=tlv_encodage:encode_packet(
	   ?id_all,1,
	   [{?PS_CHAR,
	     "012345678901234567890123456789azertyuiopqsdfghjklmwnxbcv"},
	    {?PS_CHAR,
	     "012345678901234567890123456789azertyuiopqsdfghjklmwnxbcv"},
	    {?PS_CHAR,
	     "012345678901234567890123456789azertyuiopqsdfghjklmwnxbcv"}]),
    io:format("Test Encodage/Decodage Packet L > 128 ***************~n"),
    A=tlv_encodage:decode_packet(
	tlv_encodage:encode_packet(
	  ?id_all,1,
	  [{?PS_CHAR,
	    "012345678901234567890123456789azertyuiopqsdfghjklmwnxbcv"},
	   {?PS_CHAR,
	    "012345678901234567890123456789azertyuiopqsdfghjklmwnxbcv"},
	   {?PS_CHAR,
	    "012345678901234567890123456789azertyuiopqsdfghjklmwnxbcv"}])),
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Test Encodage Decodage
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    io:format("*****************************************************~n"),
    io:format("********* Test Encodage/Decodage ********************~n"),
    %%%% ASCII
    io:format("Test encodage/decodage ASCII ***************~n"),
    {ok, ["12345678\r"]} = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,{?PS_CHAR,"12345678\r"})),
    {ok, ["ABCDEF;-,\r"]} = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,{?PS_CHAR,"ABCDEF;-,\r"})),
    
    %%%% Octet
    io:format("Test encodage/decodage Octet ***************~n"),
    {ok, [0,255,0,56]} = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,[{?PS_TINY,0},{?PS_TINY,255},
					{?PS_TINY,256},{?PS_TINY,56}])),
          
    %%%% ENTIER LONG
    io:format("Test encodage/decodage ENTIER LONG ***************~n"),
    {ok, [0,-56,32767,100000] } = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,[{?PS_INT,0},{?PS_INT,-56},
					{?PS_INT,32767},
					{?PS_INT,100000}])),
    %%%%ENTIER Court
    io:format("Test encodage/decodage ENTIER COURT ***************~n"),
    {ok, [0,-56,-1,32767] } = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,[{?PS_SMALL,0},{?PS_SMALL,-56},
					{?PS_SMALL,-1},{?PS_SMALL,32767}])),
    %%%% DCB
    io:format("Test encodage/decodage DCB ***************~n"),
    {ok, ["0123456789*#-"] } = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,[{?PS_NUM,"0123456789*#-"}])),
    {ok, ["-56"] } = 
	tlv_encodage:decode_packet(
	  tlv_encodage:encode_packet(?id_all,1,[{?PS_NUM,"-56"}])),
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Test Encodage 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    io:format("*****************************************************~n"),
    io:format("********* Test Encodage          ********************~n"),
    %%%% ASCII
    io:format("Test encodage ASCII ***************~n"),
    <<255,255,255,255,?id_all,?VERSION,?NO_CLIENT:16/big-signed,
    NO_TRANS:4/binary,12,1,10,6,8,49,50,51,52,53,54,55,56>> = 
	tlv_encodage:encode_packet(?id_all,1,
				   {?PS_CHAR,"12345678"}),
    <<255,255,255,255,?id_all,?VERSION,?NO_CLIENT:16/big-signed,
    Notrans3:4/binary,10,1,8,6,6,65,66,67,68,44,45>> = 
       tlv_encodage:encode_packet(?id_all,1,
				   {?PS_CHAR,"ABCD,-"}),
     %%%% Octet
    io:format("Test encodage Octet ***************~n"),
    <<255,255,255,255,?id_all,?VERSION,?NO_CLIENT:16/big-signed,
    Notrans4:4/binary,L3,1,9,3,1,0,3,1,255,3,1,0>>
	= tlv_encodage:encode_packet(?id_all,1,[{?PS_TINY,0},{?PS_TINY,255},
				       {?PS_TINY,256}]),
    %%%% ENTIER LONG
    io:format("Test encodage ENTIER LONG ***************~n"),
    <<255,255,255,255,?id_all,?VERSION,?NO_CLIENT:16/big-signed,
    Notrans5:4/binary,14,1,12,4,4,0,0,0,0,4,4,128,0,0,56>> = 
	tlv_encodage:encode_packet(?id_all,1,[{?PS_INT,0},
					      {?PS_INT,-56}]),
       %%%% ENTIER COURT
    io:format("Test encodage ENTIER COURT ***************~n"),
    <<255,255,255,255,?id_all,?VERSION,?NO_CLIENT:16/big-signed,
    Notrans6:4/binary,10,1,8,5,2,0,0,5,2,128,56>> 
	=tlv_encodage:encode_packet(?id_all,1,[{?PS_SMALL,0},
				       {?PS_SMALL,-56}]),
    ok.

online() ->
    ok.



