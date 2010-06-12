
-define(NB_tentative,3).%% 3 tentative

%% +deftype recharge_cb_cmo() = #recharge_cb_cmo{
%%       nadv::integer(),
%%       c_code_acces           ::integer(),
%%       c_code_client          ::integer(),
%%       c_code_user            ::integer(),
%%       c_code_CB              ::integer(),
%%       c_date_valid           ::integer(),
%%       c_montant              ::integer(),
%%       c_create_code          ::integer(),
%%       c_modif_code           ::integer(),
%%       c_cvx2                 ::integer(),
%%       c_tlr                  ::integer(),         
%%       code_acces             ::string(),
%%       code_client            ::string(),
%%       new_code_acces         ::string(),
%%       plafond                ::currency(),
%%       no_carte_cb            ::string(),
%%       date_valid_cb          ::string(),
%%       code_court             ::string(),
%%       new_code_court         ::string(),
%%       montant                ::currency(),
%%       bonus_montant          ::currency(),
%%       cvx2                   ::string(),
%%       tlr                    ::string()
%%       }.
-record(recharge_cb_cmo,
	{nadv, 
	 c_code_acces=  ?NB_tentative,
	 c_code_client= ?NB_tentative,
	 c_code_user=   ?NB_tentative,
	 c_code_CB=     ?NB_tentative, %% utiliser aussi pour code court
	 c_date_valid=  ?NB_tentative,
	 c_montant=     ?NB_tentative,
	 c_create_code= ?NB_tentative,
	 c_modif_code=  ?NB_tentative,
	 c_cvx2=        ?NB_tentative,
	 c_tlr =        ?NB_tentative,
	 code_acces,
	 code_client,
	 new_code_acces,
	 plafond,
	 no_carte_cb,
	 date_valid_cb,
	 code_court,
	 new_code_court,
	 montant,
	 bonus_montant,
	 cvx2,
	 tlr}).

