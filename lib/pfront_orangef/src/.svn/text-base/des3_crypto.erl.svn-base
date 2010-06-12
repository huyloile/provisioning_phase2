-module(des3_crypto).
%%for test 
-compile(export_all).

-export([encryption_des3/1]).
%% function to replace clear-text key
-export([replace_orange_key/1]).

%%default vector provided by Orange
-define(Ivec,<<16#34, 16#56, 16#78, 16#9a, 16#bc, 16#de, 16#f0, 16#12>>).

%%local cellcube settings
-define(CC_Key,<<16#56,16#34,16#ca,16#ac,16#cc,16#35,16#64,16#80>>).
-define(CC_Ivec,<<16#ef,16#26,16#36,16#71,16#09,16#34,16#a2,16#d4>>).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%encryption text with ede3 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



encryption_des3(Text) ->
    Key = get_random_key(),
    Key_Orange = crypto:des_cbc_decrypt(?CC_Key,?CC_Ivec,Key),
    IV = ?Ivec,
    <<Key1:8/binary,Key2:8/binary>> = Key_Orange,
    Key3 = Key1,
    Out = crypto:des_ede3_cbc_encrypt(Key1,Key2,Key3,IV,Text),
    Result = convert_utils:binary2hex(Out),
    {ok,Result}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  get a random key according to configuration 
%%  return binary of 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_random_key() ->
    Keys = pbutil:get_env(pfront_orangef,des3_encryption_keys),
    case Keys of 
        [] ->
            slog:event(failure,?MODULE,no_key_provided_in_pfront_orangef,[]),
            exit(no_key_provided_in_configuration);
        _ ->
            Keys_num = length(Keys),
            Index = random:uniform(Keys_num),
            FileName = lists:nth(Index,Keys),
            Key  = read_file(FileName)
    end.


read_file(File)->
    {ok,FD} = file:open(File,[read]),
    case file:read(FD,16) of 
        {ok, Data} ->
            list_to_binary(Data);
        eof  ->
            slog:event(failure, ?MODULE, key_length_less_than_16,[File]),
            exit(key_length_less_than_16);
        {error,Reason} ->
            slog:event(failure, ?MODULE, key_file_unreadable, [File,Reason]),
            exit(key_file_unreadable)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This function will encrypt a clear-text key using des_cbc. The clear-text key will be replaced by its chiper. 
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
replace_orange_key(Filename)->
    
    NewFileName = Filename ++ ".cipher",
    Key = case file:read_file(Filename) of 
	      {ok , Binary} ->
		  Binary ;
	      {error,Reason} ->
		  exit(Reason)
	  end,
    
    case (erlang:bitsize(Key) rem 64) of 
	0 ->
	    ok ;
	_ ->
	    exit("Original key must be a multiple of 64bit(8bytes)")
    end,
    
    Cipher = crypto:des_cbc_encrypt(?CC_Key , ?CC_Ivec , Key),
    case file:write_file(NewFileName,Cipher) of
	ok ->
	    ok;
	{error,Error} ->
	    exit("error writing cipher key"+Error)
    end,
    
    case file:delete(Filename) of 
	ok ->
	    {ok,"Your file is replaced by "++NewFileName};
	{error,E} ->
	    exit(E)
    end.
	   

