
-define(NB_tentative_mobi,3).%% 3 tentative

%% +deftype recharge_cb_mobi() = #recharge_cb_mobi{
%%       nadv::integer(),
%%       c_no_cb              ::integer(),
%%       c_date_valid           ::integer(),
%%       c_cvx2                 ::integer(),  
%%       c_cvx2_cb              ::integer(), 
%%       c_no_mobile_choix      ::integer(),
%%       plafond                ::currency(),
%%       first_recharge         ::bool(),
%%       no_cb                  ::string(),
%%       date_valid             ::string(),
%%       montant                ::currency(),
%%       montant_max            ::currency(),
%%       bonus                  ::currency(),
%%       duree                  ::string(),
%%       cvx2                   ::string(),
%%       trc_num                ::string()
%%       }.
-record(recharge_cb_mobi,
	{nadv, 
	 c_no_cb=     ?NB_tentative_mobi, %% utiliser aussi pour code court
	 c_date_valid=  ?NB_tentative_mobi,
	 c_cvx2=        ?NB_tentative_mobi,
	 c_cvx2_cb=        ?NB_tentative_mobi,
	 c_no_mobile_choix= ?NB_tentative_mobi,
	 plafond=currency:sum(euro,80),
	 first_recharge,
	 no_cb,
	 date_valid,
	 montant,
         montant_max,
	 bonus,
	 duree,
	 cvx2,
	 trc_num="0"}).

-define(RECH_50_50,1).
-define(RECH_PRINC,0).
-define(RECH_10E,10).% Amount related to subscription of unlimited options
-define(RECH_20E,20).% Amount related to subscription of unlimited options
-define(RECH_30E,30).% Amount related to subscription of unlimited options
-define(RECH_15E,15).% Amount related to subscription of unlimited options
-define(RECH_7E,7).% Amount related to recharge serie limitee 7 euros
-define(RECH_7E_MessgIllim,7).% Amount related to recharge messages illimites 7 euros
