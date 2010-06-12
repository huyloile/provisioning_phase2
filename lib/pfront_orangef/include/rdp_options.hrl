%% +deftype rdp_options_config() = 
%%         #rdp_options_config{
%%                   files_root     ::string(),
%%                   files_size     ::integer(),
%%                   files_no       ::integer(),
%%                   max_duration   ::integer(),
%%                   transfer_fn    ::mfa()}.
-record(rdp_options_config, 
	{files_root, % root of CDR filenames
	 files_size, % max CDR file size
	 files_no,   % number of CDR files
	 max_duration, % max CDR file duration before closing
	 transfer_fn   % fun called when a file is closed
	}).


%% +deftype opt_event() =
%%       #opt_event{msisdn        ::string(),
%%              cso           ::string(), %% code service optionel
%%              or_pos        ::'AJTSO' | 'SUPSO', %% ajout/retrait
%%              date_activ    ::pbutil:unixtime(),
%%              date_retrait  ::pbutil:unixtime()}.
-record(opt_event,
	{msisdn,
	 cso,
	 or_pos,
	 date_activ=0,
	 date_retrait=0}).

