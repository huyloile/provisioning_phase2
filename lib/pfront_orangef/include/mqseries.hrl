%% +deftype md() =
%%       #md{strucid         :: string(),
%%	     version         :: int(),
%%	     report          :: int(),
%%	     msgtype         :: int(),
%%	     expiry          :: int(),
%%	     feedback        :: int(),
%%	     encoding        :: int(),
%%	     codedcharsetid  :: int(),
%%	     format          :: string(),
%%	     priority        :: int(),
%%	     persistence     :: int(),
%%	     msgid           :: binary(),
%%	     correlid        :: binary(),
%%	     backoutcount    :: int(),
%%	     replytoq        :: string(),
%%	     replytoqmgr     :: string(),
%%	     useridentifier  :: string(),
%%	     accountingtoken :: binary(),
%%	     applidentitydata:: string(),
%%	     putappltype     :: int(),
%%	     putapplname     :: string(),
%%	     putdat          :: string(),
%%	     puttime         :: string(),
%%	     applorigindata  :: string(),
%%	     groupid         :: binary(),
%%	     msgseqnumber    :: int(),
%%	     offset          :: int(),
%%	     msgflags        :: int(),
%%	     originallength  :: int()
%%           }.

-record(md, {strucid,
	     version,
	     report,
	     msgtype,
	     expiry,
	     feedback,
	     encoding,
	     codedcharsetid,
	     format,
	     priority,
	     persistence,
	     msgid,
	     correlid,
	     backoutcount,
	     replytoq,
	     replytoqmgr,
	     useridentifier,
	     accountingtoken,
	     applidentitydata,
	     putappltype,
	     putapplname,
	     putdat,
	     puttime,
	     applorigindata,
	     groupid,
	     msgseqnumber,
	     offset,
	     msgflags,
	     originallength}).

%% +deftype mqseries_config() =
%%       #mqseries_config{
%%           type   :: atom(),
%%	     put    :: pid(),
%%           get    :: pid() | none,
%%	     ping   :: nok | atom(),
%%           ping_timeout :: int(),
%%	     navail :: int(),
%%	     md     :: int(),
%%	     check  :: false | true
%%	    }.
%%%% type   -> mqseries | erlang_process
%%%% put    -> a port
%%%% get    -> a port or none for a send only interface
%%%% ping   -> none or the module name exporting ping_send/0 and ping_expect/1
%%%% ping_timeout -> to set a specific (defaults to 5000) timeout on ping
%%%% navail -> length of queue
%%%% md     -> list of params {key,value} to build record md for mqseries
%%%% check  -> should id of repsonse be matched with id of request ?
-record(mqseries_config, { type,
			   put,
			   get     = none,
			   ping    = nok,
			   ping_timeout = 5000,
			   navail,
			   md      = [],
			   check   = false
			  }).


% +deftype mqseries_request() = 
%%   #mqseries{
%%       send        :: string(),
%%       attr        :: lists(term()),
%%       timeout     :: int(),
%%       expect_resp :: true | false
%%	      }.
%%%% send        -> the request (a string)
%%%% attr        -> list of attribs used by pool server to route call
%%%% timeout     -> duration before timeout
%%%% expect_resp -> a response should (not) be expected
-record(mqseries_request, { send,
			    attr=[],
			    timeout = 5000,
			    expect_resp = true
			   }).


