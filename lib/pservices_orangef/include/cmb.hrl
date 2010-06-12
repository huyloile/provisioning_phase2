
-define(SVC_NAME,"cmb").
-define(MOBI_MAX_CMB,pbutil:get_env(pservices_orangef,mobi_max_cmb)).
-define(CMO_MAX_CMB,pbutil:get_env(pservices_orangef,cmo_max_cmb)).
-define(SYMACOM_MAX_CMB,pbutil:get_env(pservices_orangef,symacom_max_cmb)).

%% +deftype call_me_back()= #call_me_back {  
%%                         date   :: unixtime(),
%%                         num    :: integer(),
%%                         last_cmb:: unixtime()}.
-record(call_me_back,{date=0,num=0,last_cmb=0}).
