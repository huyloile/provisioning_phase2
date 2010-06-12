%% +deftype sdp_config() =
%%     #sdp_config { banner::string(),
%% 		     prefix::string(), % MSISDN prefix
%% 		     method::connect_method()
%% 		   }.

-record(sdp_config, {banner, prefix, method}).


%% +deftype connect_method() =
%%     {x25, Options::string(), Addr::string()}      % Linux X.25 API
%%   | {fsx25, Options::string(), Addr::string()}    % FarSite card driver
%%   | {erlang_process, Global_name::atom()}.


%% +deftype opt_cpt_request() =
%%     #opt_cpt_request {
%%        type_action :: string(),
%%	  top_num     :: string(),
%%	  date_deb    :: string(),
%%	  heure_deb   :: string(),
%%	  date_fin    :: string(),
%%	  heure_fin   :: string(),
%%        duree       :: string(), %%new for MAJ_OP
%%	  cout        :: string(),
%%	  tcp_num     :: string(),
%%	  ptf_num     :: string(),
%%	  info1       :: string(),
%%	  info2       :: string(),
%%	  mnt_initial :: string(),
%%	  rnv_num     :: string(),
%%        type_trt    :: string(), %%new for MAJ_OP
%%	  msisdn1     :: string(),
%%	  msisdn2     :: string(),
%%	  msisdn3     :: string(),
%%	  msisdn4     :: string(),
%%	  msisdn5     :: string(),
%%	  msisdn6     :: string(),
%%	  msisdn7     :: string(),
%%	  msisdn8     :: string(),
%%	  msisdn9     :: string(),
%%	  msisdn10    :: string() 
%%     }.

-record(opt_cpt_request, {type_action,
			  top_num,
			  date_deb="-",
			  heure_deb="-", %% obsolete for new MAJ_OP
			  date_fin="-",  %% obsolete for new MAJ_OP
			  heure_fin="-", %% obsolete for new MAJ_OP
                          duree="0",
			  cout="-1", %%%% x25 : "-", Sachem : "-1"
			  tcp_num="-1",
			  ptf_num="0",
			  info1="",
			  info2="",
			  mnt_initial="-1",
			  rnv_num="-1",
                          type_trt="0",
			  msisdn1="",
			  msisdn2="",
			  msisdn3="",
			  msisdn4="",
			  msisdn5="",
			  msisdn6="",
			  msisdn7="",
			  msisdn8="",
			  msisdn9="",
			  msisdn10=""}).
