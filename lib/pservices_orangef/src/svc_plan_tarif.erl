-module(svc_plan_tarif).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pdist_orangef/include/spider.hrl").

-export([plans_to_change/1,plans_change_header/1]).
-export([plans_change_price/1,pt_change/2]).
-export([verif_credit/2]).
-export([confirm_leave_noel/2,print_confirm_noel/1,prix_plan/2]).
-export([print_link/2,confirm_msg_sup/1]).

-export([pt_change_plug_vac/1]).

%% 

plans_to_change(abs) ->
    [{redirect, abs, "#temporary"},
     {redirect, abs, "#change_pt_is_classique"},
     {redirect, abs, "#change_pt_is_surmesure"},
     {redirect, abs, "#change_pt_is_orange_plug"},
     {redirect, abs, "#change_pt_is_plug_noel"},
     {redirect, abs, "#change_pt_is_noel"},
     {redirect, abs, "#change_pt_is_soir_we"},
     {redirect, abs, "#change_pt_is_class_v2"}
    ];
plans_to_change(Session) ->
    State = svc_util_of:get_user_state(Session),
    Compte_P=svc_compte:cpte(State,cpte_princ),
    case Compte_P#compte.ptf_num of
	?MCLAS->
	    {redirect, Session, "#change_pt_is_classique"};
	?PSMM->
	    {redirect, Session, "#change_pt_is_surmesure"};
	?PSMAM->
	    {redirect, Session, "#change_pt_is_surmesure"};
	?PSMS->
	    {redirect, Session, "#change_pt_is_surmesure"};
	?PSMN->
	    {redirect, Session, "#change_pt_is_surmesure"};
	?MADRID2->
	    {redirect, Session, "#change_pt_is_orange_plug"};
	?PLUG_NOEL->
	    {redirect, Session, "#change_pt_is_plug_noel"};
	?PSOIR_WE->
	    {redirect, Session, "#change_pt_is_soir_we"};
	?PCLAS_V2->
	    {redirect, Session, "#change_pt_is_class_v2"};
	E->
	    slog:event(failure, ?MODULE,unknow_plan_tarifaire,E),
	    {redirect, Session, "#temporary"}
    end.

plans_change_header(abs) ->
    [ {pcdata, "Deuxième et dernière modification gratuite de plan ou de"
      " plage(suivante: XX EUR/chgt)"},br];
plans_change_header(Session) ->
    State = svc_util_of:get_user_state(Session),
    case {State#sdp_user_state.etats_sec band ?SETAT_PT,
	  State#sdp_user_state.etats_sec band ?SETAT_P2} of
	{?SETAT_PT, ?SETAT_P2} ->
	    Price = currency:sum
		      (pbutil:get_env(pservices_orangef, 
				      prix_changement_plan_tarifaire)),
	    EurPriceStr = svc_selfcare:print_sum(?EURO, Price),
	    FrfPriceStr = svc_selfcare:print_sum(?FRANC, Price),
	    [{pcdata, "Cette modification vous sera facturée "
	      ++ EurPriceStr++"."}];
	{?SETAT_PT, 0} ->
	    Price = currency:sum
		      (pbutil:get_env(pservices_orangef, 
				      prix_changement_plan_tarifaire)),
	    EurPriceStr = svc_selfcare:print_sum(?EURO, Price),
	    [{pcdata, "Deuxième et dernière modification gratuite de plan"
	      ++" ou de plage(suivante:"++EurPriceStr++"/chgt)."}];
	_ ->
	    [{pcdata, "Première modification de plan gratuite."}]
    end.

plans_change_price(abs) ->
    [ {pcdata, "Vous avez déjà modifié deux fois de plan tarifaire. "
       "Toute modification suivante sera facturée XX EUR"}];
plans_change_price(Session) ->
    State = svc_util_of:get_user_state(Session),
    case {State#sdp_user_state.etats_sec band ?SETAT_PT,
	  State#sdp_user_state.etats_sec band ?SETAT_P2} of
	{?SETAT_PT, ?SETAT_P2} ->
	    Price = currency:sum
		      (pbutil:get_env(pservices_orangef, 
				      prix_changement_plan_tarifaire)),
	    EurPriceStr = svc_selfcare:print_sum(?EURO, Price),
	    FrfPriceStr = svc_selfcare:print_sum(?FRANC, Price),
	    [{pcdata, "Vous avez déjà modifié deux fois gratuitement de plan"
	      " tarifaire. Toute modification suivante sera facturée "
	      ++ EurPriceStr ++":"}];
	{?SETAT_PT, 0} ->
	    [{pcdata, "Vous pouvez encore changer une fois gratuitement"
	      " de plan tarifaire:"}];
	_ ->
	    [{pcdata, "Vos deux premières modifications de plan tarifaire"
	     " ou de plage horaire sont gratuites:"}]
    end.

%% +type pt_change(session(), Pt::string()) -> erlpage_result().
pt_change(abs, _) ->
    [ {redirect, abs, "#change_pt_error"},
      {redirect, abs, "#not_enough_credit_pt"},
      {redirect, abs, "#mobirecharge_change_pt"},
      {redirect, abs, "#change_pt_error"},
      {redirect, abs, "#change_pt_success",["TEXT_FIN"]}
     ];

pt_change(#session{prof=Profile} = Session, PT)->
    State = svc_util_of:get_user_state(Session),
    PTChangePrice = determine_pt_change_price(State),
    Compte_P=svc_compte:cpte(State,cpte_princ),
    %% we need to have price in the user's currency because of SDP
    PTChangePrice1 = case Compte_P#compte.unt_num of
 			 ?EURO ->
 			     currency:to_euro(PTChangePrice);
 			 ?FRANC ->
 			     currency:to_frf(PTChangePrice)
 		     end,
    EurPTChangePriceStr = svc_selfcare:print_sum(?EURO, PTChangePrice1),
    FrfPTChangePriceStr = svc_selfcare:print_sum(?FRANC, PTChangePrice1),
    Free=currency:sum(euro,0),
    Msisdn = Profile#profile.msisdn,
    Time = pbutil:unixtime(),
    {Result, NewPT} = 
	case PT of
	    "toclassique" -> 
		{sdp_router:svi_g({mobi,Msisdn}, ?MCLAS,PTChangePrice1,Time),
		 ?MCLAS};
	    "tomatin" -> 
		{sdp_router:svi_g({mobi,Msisdn}, ?PSMM, PTChangePrice1, Time),
		 ?PSMM};
	    "toapresmidi" ->
		{sdp_router:svi_g({mobi,Msisdn}, ?PSMAM, PTChangePrice1,
				  Time),
		 ?PSMAM};
	    "tosoir" -> 
		{sdp_router:svi_g({mobi,Msisdn}, ?PSMS, PTChangePrice1, Time),
		 ?PSMS};
	    "tonuit" ->
		{sdp_router:svi_g({mobi,Msisdn}, ?PSMN, PTChangePrice1, Time),
		 ?PSMN};
	    "tomadrid" ->
		{sdp_router:svi_g({mobi,Msisdn}, ?MADRID2, PTChangePrice1, Time),
		 ?MADRID2};
	    "toclass_v2" ->
		{sdp_router:svi_g({mobi,Msisdn}, ?PCLAS_V2, PTChangePrice1, Time),
		 ?PCLAS_V2};
	    "tosoir_we" ->
		{sdp_router:svi_g({mobi,Msisdn}, ?PSOIR_WE, 
				  PTChangePrice1, Time),
		 ?PSOIR_WE};
	    _ -> 
		 Compte_P=svc_compte:cpte(State,cpte_princ),
		{bad_pt_change_request, Compte_P#compte.ptf_num}
	end,
    case Result of
	{ok, ""} ->
	    Opt = list_to_atom(PT),
	    prisme_dump:prisme_count(Session,Opt),
	    Compte_P2=Compte_P#compte{
			cpp_solde=impute(Compte_P,PTChangePrice1),
			ptf_num=NewPT},
	    NewState = 
		State#sdp_user_state{
		  etats_sec = 
		  add_pt_change(State#sdp_user_state.etats_sec),
		  cpte_princ=Compte_P2},
	    NewSession = svc_util_of:update_user_state(Session,NewState), 
	    case currency:is_infeq(PTChangePrice1,Free) of
		true ->
		    Text="Ce changement ne vous est pas facturé.",
		    {redirect,NewSession,"#change_pt_success",
		     [{"TEXT_FIN",Text}]};
		false ->
		    Text="Ce changement vous est facturé " ++
			EurPTChangePriceStr ++ " (" ++
			FrfPTChangePriceStr ++").",
		    {redirect,NewSession,"#change_pt_success",
				[{"TEXT_FIN",Text}]}		   
	    end;
	{status, [10, 1]} -> 
	    {redirect, Session, "#change_pt_error"};
	{status,  [10, 2]} ->
	    {redirect, Session, "#not_enough_credit_pt"};
	{status,  [10, 3]} ->
	    {redirect, Session, "#mobirecharge_change_pt"};
	{status, [99]}->
	    {redirect, Session, "#change_pt_error"};
	{status, [99,X]}->
	    {redirect, Session, "#change_pt_error"};
	E ->
	    slog:event(internal, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session, "#change_pt_error"}
    end.

verif_credit(abs,Url)->
    [{redirect, abs, Url},
     {redirect, abs, "#not_enough_credit_pt"}];
verif_credit(Session,Url)->
    State = svc_util_of:get_user_state(Session),
    Price_PT=determine_pt_change_price(State),
    Compte=svc_compte:cpte(State,cpte_princ),
    case currency:is_infeq(Compte#compte.cpp_solde,Price_PT) of
	true ->
	    {redirect,Session,"#not_enough_credit_pt"};
	false ->
	    {redirect,Session,Url}
    end.

determine_pt_change_price(State) ->
    case {State#sdp_user_state.etats_sec band ?SETAT_PT,
	  State#sdp_user_state.etats_sec band ?SETAT_P2} of
	{?SETAT_PT, ?SETAT_P2} ->
	    currency:sum(pbutil:get_env(pservices_orangef, 
					prix_changement_plan_tarifaire));
	Else ->
	    %% free change
	    currency:sum(euro,0)
    end.
add_pt_change(EtatsSec) when (EtatsSec band ?SETAT_P2)==0 ->
    EtatsSec bor ?SETAT_P2;
add_pt_change(EtatsSec) ->
    EtatsSec bor ?SETAT_PT.

impute(Compte,Sum)->
    Result = currency:sub(Compte#compte.cpp_solde, Sum),
    Free = currency:sum(euro,0),
    case currency:is_infeq(Result, Free) of
	true ->
	    slog:event(failure, ?MODULE,
		       imputation_over_balance, {Compte, Sum}),
	    Free;
	false ->
	    Result
    end.

confirm_leave_noel(abs,URL)->
    put(url,URL),
    [{"not_noel",{redirect, abs, URL}},
     {"is_plug_noel",{redirect, abs, "#confirm_leave_plug_noel"}},
     {"is_noel",{redirect, abs, "#confirm_leave_noel"}}];
confirm_leave_noel(Session,URL)->
    State = svc_util_of:get_user_state(Session),
    Compte_P=svc_compte:cpte(State,cpte_princ),
    case Compte_P#compte.ptf_num of
	?PLUG_NOEL->
	    State_= State#sdp_user_state{tmp_ptfnum=URL},
	    {redirect,svc_util_of:update_user_state(Session,State_),
	     "#confirm_leave_plug_noel"};
	_ ->
	    {redirect,Session,URL}
    end.

print_confirm_noel(abs)->
    Url=get(url),
    [#hlink{href=Url,contents=[{pcdata,"Confirmer"}]}];
print_confirm_noel(Session)->
    #sdp_user_state{tmp_ptfnum=URL}= svc_util_of:get_user_state(Session),
    [#hlink{href=URL,contents=[{pcdata,"Confirmer"}]}].



print_link(abs,"class_v2")->
    [#hlink{href="erl://svc_plan_tarif:verif_credit?"
	    "#change_pt_confirm_to_class_v2",
	    contents=[{pcdata,"Choisir nouveau plan classique"}]}];
print_link(abs,"soir_we")->
    [#hlink{href="erl://svc_plan_tarif:verif_credit?"
	    "#change_pt_confirm_to_soir_we",
	    contents=[{pcdata,"Choisir plan soir et we"}]}];
print_link(abs,"plug")->
    [#hlink{href="erl://svc_plan_tarif:verif_credit?"
	    "#change_pt_confirm_to_orange_plug",
	    contents=[{pcdata,"Choisir plan Orange plug"}]}];
print_link(Session,Plan) ->
    State = svc_util_of:get_user_state(Session),
    Compte_P=svc_compte:cpte(State,cpte_princ),
    case {Compte_P#compte.ptf_num,Plan} of
	{?PCLAS_V2,"class_v2"}->
	    [];
	{_,"class_v2"} ->
	    [#hlink{href="erl://svc_plan_tarif:verif_credit?"
	    "#change_pt_confirm_to_class_v2",
	    contents=[{pcdata,"Choisir nouveau plan classique"}]}];
	{?PSOIR_WE,"soir_we"}->
	    [];
	{_,"soir_we"} ->
	    [#hlink{href="erl://svc_plan_tarif:verif_credit?"
	    "#change_pt_confirm_to_soir_we",
	    contents=[{pcdata,"Choisir plan soir et week end"}]}];
	 {?MADRID2,"plug"}->
	    [];
	{_,"plug"} ->
	    [#hlink{href="erl://svc_plan_tarif:verif_credit?"
		    "#change_pt_confirm_to_orange_plug",
		    contents=[{pcdata,"Choisir plan Orange plug"}]}]
    end.


%% Returns user's credit expressed in minutes, according to its
%% currency credit, its current currency, and the current prices
prix_plan(abs,_) -> [ {pcdata, "XX"} ];
prix_plan(Session,PLAN)->
    Prix = case PLAN of
	       "classique" ->
		   svc_compte:ratio(?mobi,?C_PRINC,?MCLAS,?MIN);
	       "mesure" ->
		   svc_compte:ratio(?mobi,?C_PRINC,?PSMM,?MIN);
	       "plug" ->
		   svc_compte:ratio(?mobi,?C_PRINC,?PLUGV3,?MIN);
	       "plug_noel" ->
		   svc_compte:ratio(?mobi,?C_PRINC,?PLUG_NOEL,?MIN);
	       "soir_we"->
		   svc_compte:ratio(?mobi,?C_PRINC,?PSOIR_WE,?MIN);
	       "class_v2"->
		   svc_compte:ratio(?mobi,?C_PRINC,?PCLAS_V2,?MIN)
	 end,
    PR = currency:round_value(currency:to_euro(currency:sum(euro,Prix))),
    CR=  lists:flatten(pbutil:sprintf("%02d", [trunc(PR)])),
    [{pcdata, CR}].

confirm_msg_sup(abs) ->
    [ {pcdata, "Attention, vous perdrez définitivement l'accès "
       "à votre plan actuel"}];
confirm_msg_sup(Session) ->
    State = svc_util_of:get_user_state(Session),
    Cpte =svc_compte:cpte(State,cpte_princ),
    case Cpte#compte.ptf_num of
	X when X==?PLUG_NOEL->
	    [{pcdata, "Attention, vous perdrez définitivement l'accès "
	      "à votre plan actuel"},br];
	_ ->
	    [{pcdata, ""}]
    end.


%% +type pt_change_plug_vac(session()) -> erlpage_result().
pt_change_plug_vac(abs) ->
    [ {redirect, abs, "#change_pt_error"},
      {redirect, abs, "#not_enough_credit_pt"},
      {redirect, abs, "#mobirecharge_change_pt"},
      {redirect, abs, "#change_pt_error"},
      {redirect, abs, "#change_pt_plug_vac_success"}
     ];

pt_change_plug_vac(#session{prof=Profile} = Session)->
    State = svc_util_of:get_user_state(Session),
    Compte_P=svc_compte:cpte(State,cpte_princ),
    Free=currency:sum(euro,0),
    Msisdn = Profile#profile.msisdn,
    Time = pbutil:unixtime(),
    {Result, NewPT} = 
	{sdp_router:svi_g({mobi,Msisdn}, ?PLUG_NOEL, Free, Time),?PLUG_NOEL},

    case Result of
	{ok, ""} ->
	    Compte_P2=Compte_P#compte{ptf_num=NewPT},
	    NewSession = 
		svc_util_of:update_state(Session,
					 [{etats_sec,add_pt_change(State#sdp_user_state.etats_sec)},
					  {cpte_princ,Compte_P2}]), 
	    {redirect,NewSession,"#change_pt_plug_vac_success"};
	{status, [10, 1]} -> 
	    {redirect, Session, "#change_pt_error"};
	{status,  [10, 2]} ->
	    {redirect, Session, "#not_enough_credit_pt"};
	{status,  [10, 3]} ->
	    {redirect, Session, "#mobirecharge_change_pt"};
	{status, [99]}->
	    {redirect, Session, "#change_pt_error"};
	{status, [99,X]}->
	    {redirect, Session, "#change_pt_error"};
	E ->
	    slog:event(internal, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session, "#change_pt_error"}
    end.

	    
