%%%% Tele2 PP record
-define(NB_tentative_tele2,3).
%% +deftype recharge_pp() = #recharge_pp{
%%       c_code_secret        :: integer(),         
%%       code_secret          :: string(),
%%       montant              :: integer(), %%% montant en millieme d'euros
%%       bonus                :: integer()
%%       }.
-record(recharge_pp,
	{c_code_secret=0,
	 code_secret,
	 montant,
	 bonus,
	 c_no_prefere	
	}).

%% +deftype recharge_tele2_cfg() = #recharge_tele2_cfg{
%%       tentative       ::integer(),
%%       liste_montant    ::term(),
%%       url             ::string(),
%%       host            ::string(),
%%       port            ::integer(),
%%       origine         ::string(),
%%       timeout         ::integer(),
%%       routing::atom()}.
-record(recharge_tele2_cfg,{
	  tentative,
	  liste_montant,
	  url,
	  host,
	  port,
	  origine,
	  timeout,
	  routing}).

%%%% Error Code
-define(er_cs_invalid,1).
-define(er_cs_blocked,2).
-define(er_tele2_gp,22).
-define(er_technique,20).
-define(er_inactif_user,21).
-define(er_sachem_ko,22).
