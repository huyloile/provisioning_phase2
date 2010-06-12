-module(test_144_virgin_cb).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("sachem.hrl").
-include("profile_manager.hrl").
-define(Uid,virgin_cb_user).
-define(DIRECT_CODE,"*144").
-define(niv1,   "100007XXXXXXX1").
-define(niv2,   "100006XXXXXXX2").
-define(niv3,   "100005XXXXXXX3").

-define(AC, ?CETAT_AC). %1
-define(EP, ?CETAT_EP). %2
-define(PE, ?CETAT_PE). %3

-record(cpte_test,{dcl,princ,forf_virgin,niv,cpte_odr,opt_sms,nb_sms,bonus_voix,bonus_sms,godet_5n_pref}).

-define(LIST_STATES_TO_TEST,[{?CETAT_AC,"actif"},
			     {?CETAT_EP,"epuise"}
			    ]).


-define(LIST_DCL_TO_TEST,[{?DCLNUM_VIRGIN_COMPTEBLOQUE1,"compte multi usage 1"},
   			  {?DCLNUM_VIRGIN_COMPTEBLOQUE2,"compte multi usage 2"},
   			  {?DCLNUM_VIRGIN_COMPTEBLOQUE3,"compte multi usage 3"},
  			  {?DCLNUM_VIRGIN_COMPTEBLOQUE4,"compte multi usage 4"},
  			  {?DCLNUM_VIRGIN_COMPTEBLOQUE5,"compte multi usage 5"},
  			  {?DCLNUM_VIRGIN_COMPTEBLOQUE6,"compte multi usage 6"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE7,"compte multi usage 7"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE8,"compte multi usage 8"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE9,"compte multi usage 9"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE10,"compte multi usage 10"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE11,"compte multi usage 11"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE12,"compte multi usage 12"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE13,"compte multi usage 13"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE14,"compte multi usage 14"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE15,"compte multi usage 15"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE16,"compte multi usage 16"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE17,"compte multi usage 17"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE18,"compte multi usage 18"},
			  {?DCLNUM_VIRGIN_COMPTEBLOQUE19,"compte multi usage 19"},
			  {?DCLNUM_VIRGIN_COMPTEBLOQUE20,"compte multi usage 20"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE24,"compte multi usage 24"},
 			  {?DCLNUM_VIRGIN_COMPTEBLOQUE25,"compte multi usage 25"},
			  {?DCLNUM_VIRGIN_COMPTEBLOQUE26,"compte multi usage 26"},
			  {?DCLNUM_VIRGIN_COMPTEBLOQUE27,"compte multi usage 27"}
			 ]).

-define(LIST_LEVELS_TO_TEST,   [{?niv1,"Niveau 1"}
 		%		{?niv2,"Niveau 2"},
 		%		{?niv3,"Niveau 3"}
			       ]).

-define(ALL_CASES_VIRGIN, [#cpte_test{dcl=D,forf_virgin=S1,princ=S2,niv=N,cpte_odr=S3,opt_sms=S4,nb_sms=200,bonus_voix=S5,bonus_sms=S6,godet_5n_pref=S7} || 
			      {D,_}  <- ?LIST_DCL_TO_TEST,
			      {S1,_} <- ?LIST_STATES_TO_TEST,
			      {S2,_} <- ?LIST_STATES_TO_TEST,
			      {S3,_} <- ?LIST_STATES_TO_TEST,
			      {S4,_} <- ?LIST_STATES_TO_TEST,
			      {S5,_} <- ?LIST_STATES_TO_TEST,
			      {S6,_} <- ?LIST_STATES_TO_TEST,
			      {S7,_} <- ?LIST_STATES_TO_TEST,
			      {N,_} <- ?LIST_LEVELS_TO_TEST]).

-define(OPTION_SMS, [#cpte_test{dcl=D,forf_virgin=S1,princ=S2,niv=N,cpte_odr=S3,opt_sms=?CETAT_AC,nb_sms=200,bonus_voix=S4,bonus_sms=S5,godet_5n_pref=S6} ||
			D <- [?DCLNUM_VIRGIN_COMPTEBLOQUE1,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE2,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE3,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE5,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE6,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE7,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE8,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE15,
			      ?DCLNUM_VIRGIN_COMPTEBLOQUE16
			     ],
			{S1,_} <- ?LIST_STATES_TO_TEST,
			{S2,_} <- ?LIST_STATES_TO_TEST,
			{S3,_} <- ?LIST_STATES_TO_TEST,
			{S4,_} <- ?LIST_STATES_TO_TEST,
			{S5,_} <- ?LIST_STATES_TO_TEST,
			{S6,_} <- ?LIST_STATES_TO_TEST,
			{N,_} <- ?LIST_LEVELS_TO_TEST]).

-define(OPTION_SMS_ILL, [#cpte_test{dcl=D,forf_virgin=S1,princ=S2,niv=N,cpte_odr=S3,opt_sms=S4,nb_sms=illimite,bonus_voix=S6,bonus_sms=S6,godet_5n_pref=S7} ||
			    D <- [?DCLNUM_VIRGIN_COMPTEBLOQUE1,
				  ?DCLNUM_VIRGIN_COMPTEBLOQUE2,
				  ?DCLNUM_VIRGIN_COMPTEBLOQUE3
				 ],
			    {S1,_} <- ?LIST_STATES_TO_TEST,
			    {S2,_} <- ?LIST_STATES_TO_TEST,
			    {S3,_} <- ?LIST_STATES_TO_TEST,
			    {S4,_} <- ?LIST_STATES_TO_TEST,
			    {S5,_} <- ?LIST_STATES_TO_TEST,
			    {S6,_} <- ?LIST_STATES_TO_TEST,
			    {S7,_} <- ?LIST_STATES_TO_TEST,
			    {N,_} <- ?LIST_LEVELS_TO_TEST]).

-define(ALL_CASES_ROAMING, [ #cpte_test{dcl=D,princ=S1,forf_virgin=S2,niv=?niv1,cpte_odr=?EP,opt_sms=?EP,nb_sms=Nb_SMS,bonus_voix=?EP,bonus_sms=?EP,godet_5n_pref=?EP} || 
			       {D,_}  <- ?LIST_DCL_TO_TEST,
			       {S1,_} <- ?LIST_STATES_TO_TEST,
			       {S2,_} <- ?LIST_STATES_TO_TEST,
			       Nb_SMS <- [200,illimite]]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generic functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

state_name(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_STATES_TO_TEST),
    Nom.

state_dcl(Int) ->
    {value,{_,Nom}}=lists:keysearch(Int, 1, ?LIST_DCL_TO_TEST),
    Nom.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_test_account(#cpte_test{dcl=D,forf_virgin=E1,princ=E2,niv=N,cpte_odr=E3,opt_sms=E4,nb_sms=Nb_SMS,godet_5n_pref=E5}) ->
    "Forfait Virgin CB\n" ++
    "IMEI: "++N++" "
    ++"Forfait: "++state_name(E1)++" "
    ++"Compte Recharge: "++state_name(E2)++" "
    ++"Declinaison: "++integer_to_list(D)++" "++state_dcl(D)++" "
    ++"Godet ODR: "++" "++state_name(E3)++" "
    ++"Option SMS: "++" "++state_name(E4)++" "
    ++"Nb SMS= "++sms_to_list(Nb_SMS)++" "
    ++"Godet 5n preferes: "++" "++state_name(E5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consult_account(Cpte) ->
    [
     {title, "CONSULTATION D'UN COMPTE: "++display_test_account(Cpte)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*#"},
	{expect, expected(Cpte)},
        {send, "1"},
        {expect, ".*"}
       ]}     
    ].

test_all_cases([]) -> [];
test_all_cases([H|T]) ->
    modify_account_state(H) ++ consult_account(H) ++ test_all_cases(T).


modify_account_state(#cpte_test{dcl=D,princ=E1,forf_virgin=E2,niv=IMEI,cpte_odr=E3,opt_sms=ETAT_SMS,nb_sms=Nb_SMS,bonus_voix=E_BONUS_VOIX,bonus_sms=E_BONUS_SMS,godet_5n_pref=E_GODET_5N}) ->
    profile_manager:set_imei(?Uid,IMEI)++
	profile_manager:set_dcl(?Uid,D)++
	profile_manager:set_list_options(?Uid,[#option{top_num=top_num(200)},
										   #option{top_num=top_num(Nb_SMS)},
										   #option{top_num=top_num(opt_5n_pref)}])++
	profile_manager:set_list_comptes(?Uid,
                        [#compte{tcp_num=?C_PRINC,
                                 unt_num=?EURO,
                                 cpp_solde=2000,
                                 dlv=pbutil:unixtime(),
                                 rnv=0,
                                 etat=E1,
                                 ptf_num=206},
                         #compte{tcp_num=?C_FORF_VIRGIN1,
                                 unt_num=?EURO,
                                 cpp_solde=1000,
                                 dlv=0,
                                 rnv=10,
                                 etat=E2,
                                 ptf_num=206},
                         #compte{tcp_num=?C_FORF_ODR,
                                 unt_num=?EURO,
                                 cpp_solde=2000,
                                 dlv=0,
                                 rnv=10,
                                 etat=E3,
                                 ptf_num=206},
                         #compte{tcp_num=?C_VIRGIN_BONUS_SMS_CB,
                                 unt_num=?EURO,
                                 cpp_solde=2000,
                                 dlv=pbutil:unixtime(),
                                 rnv=10,
                                 etat=E_BONUS_SMS,
                                 ptf_num=5},
                         #compte{tcp_num=?C_VIRGIN_BONUS_VOIX_CB,
                                 unt_num=?EURO,
                                 cpp_solde=2000,
                                 dlv=pbutil:unixtime(),
                                 rnv=10,
                                 etat=E_BONUS_VOIX,
                                 ptf_num=286},
                         #compte{tcp_num=tcp_num(200),
                                 unt_num=?SMS,
                                 cpp_solde=2000,
                                 dlv=0,
                                 rnv=10,
                                 etat=ETAT_SMS,
                                 ptf_num=ptf_num(200)},
                         #compte{tcp_num=tcp_num(opt_5n_pref),
                                 unt_num=?EURO,
                                 cpp_solde=2000,
                                 dlv=0,
                                 rnv=10,
                                 etat=E_GODET_5N,
                                 ptf_num=ptf_num(opt_5n_pref)}

                        ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define expected results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(TXT_EURO, "E.*min.*sec.*").
-define(TXT_SMS, "SMS.*").
-define(TXT_DATE, "../../...*").
-define(TXT_DATE2,"../...*").
-define(TXT_LIEN_MENU, "Recharger.*").
-define(TXT_VIRGIN,".*").

text(princ,?AC)->
    "Cpte recharge: .*E.*";
text(cpte_ord,?AC)->
    ".*E jusq.*";
text(sms_illimite,illimite) ->
    "et SMS illimites.*";
text(sms_illimite,_) -> 
    "ou .* SMS.*";
text(sms_200,?AC) -> 
    ".*SMS sur option.*";
text(bonus_voix,?AC) -> 
    "Et en plus:.*mn.*s.*";
text(bonus_sms,?AC) -> 
    "Et en plus:.*SMS.*";
%text(godet_5n_pref,?AC)->
%    "Encore .*mn.*s.*";
text(_,_) ->
    [].

text(DCL,forf_virgin,?AC,ILLIMITE)->
    case (DCL) of
	?DCLNUM_VIRGIN_COMPTEBLOQUE4 ->
    	    "Magot: .*E soit .*"++text(sms_illimite,illimite);
	_ ->
	    "Magot: .*E soit .*"++text(sms_illimite,ILLIMITE)
    end;
text(_,forf_virgin,_,_) ->
    "Credit epuise..*".
    

expected(#cpte_test{princ=ETAT_C,forf_virgin=ETAT_FORF,dcl=DCL,niv=?niv1,cpte_odr=ETAT_ODR,opt_sms=ETAT_SMS,nb_sms=ILLIMITE,
		    bonus_voix=E_BONUS_VOIX,bonus_sms=E_BONUS_SMS,godet_5n_pref=E_GODET_5N})->
    text(DCL,forf_virgin,ETAT_FORF,ILLIMITE)++text(princ,ETAT_C)++text(cpte_ord,ETAT_ODR)++text(sms_200,ETAT_SMS)
    ++text(bonus_voix,E_BONUS_VOIX)++text(bonus_sms,E_BONUS_SMS)++text(godet_5n_pref,E_GODET_5N).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    test_util_of:online(?MODULE,selfcare()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


selfcare() ->
    [ "Test du service selfcare Virgin Compte Bloque." ] ++
    test_util_of:set_present_period_for_test(commercial_date_virgin_cb,[opt_data_gprs]) ++
	profile_manager:create_default(?Uid,"virgin_comptebloque")++
	profile_manager:init(?Uid)++
    test_all_cases(?ALL_CASES_VIRGIN) ++
    %test_all_cases(?OPTION_SMS) ++
    %test_all_cases(?OPTION_SMS_ILL) ++
    %test_roaming(?ALL_CASES_ROAMING) ++
    test_refill()++
    test_util_of:close_session() ++
    [ "Test reussi." ].

test_refill()->
    modify_account_state(#cpte_test{dcl=?DCLNUM_VIRGIN_COMPTEBLOQUE20,
				    princ=?CETAT_EP,forf_virgin=?CETAT_EP,
				    niv=?niv1,cpte_odr=?CETAT_EP,opt_sms=?CETAT_EP,nb_sms=illimite,
				    bonus_voix=?CETAT_EP,bonus_sms=?CETAT_EP,godet_5n_pref=?CETAT_EP})++
	profile_manager:set_sachem_recharge(?Uid,#sachem_recharge{accounts=[#account{tcp_num=1, montant=15000}],
											ttk_num=143})++
    [
    {title, "Test de rechargement Suivi-conso"},
    "Cas Classique",
    {ussd2,
     [ {send, ?DIRECT_CODE++"*1#"},
       {expect,"Tapez sans leur faire mal les 14 chiffres de votre code de rechargement. Attention, 3 essais seulement.*"}]
      },
     "Code CG FAUX",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*123456#"},
        {expect,"Rechargement refuse: votre code n'est pas correct. Veuillez verifier votre code et renouveler l'operation. Merci.*"}]
     },
     "Code CG OK",
     {ussd2,
      [ {send, ?DIRECT_CODE++"*112345678912341#"},
        {expect,"Vous venez de recharger 15EUR sur votre compte rechargeable.*"
         "Nouveau solde de votre compte: .*E \\(duree de validite illimitee\\)"}
       ]}
   ] ++
	profile_manager:set_sachem_response(?Uid, {"rec_tck",{error,"incompatible_offre"}}) ++
	[
	  "Error Incompatible Offre",
	 {ussd2,
	  [ {send, ?DIRECT_CODE++"*112345678912341#"},
	    {expect,"Rechargement refuse: votre code n'est pas correct. Veuillez verifier votre "
	     "code et renouveler l'operation. Merci."}
	   ]}
	].

is_menu_tarifs(#cpte_test{dcl=Dcl,niv=?niv1,forf_virgin=?EP,princ=?AC,cpte_odr=?EP,opt_sms=?EP,nb_sms=_}) ->
    true;
is_menu_tarifs(#cpte_test{dcl=DCL})
  when DCL==?DCLNUM_VIRGIN_COMPTEBLOQUE4;DCL==?DCLNUM_VIRGIN_COMPTEBLOQUE9;DCL==?DCLNUM_VIRGIN_COMPTEBLOQUE10 ->
    true;
is_menu_tarifs(_) ->
    false.

expected_roaming(Cpte) ->
    [{expect,"Les destinations sont classees en 4 zones tarifaires : "
     "Europe, Suisse/Andorre, Maghreb/Amerique du Nord/Turquie et . Reste du monde.*1:suite"},
     {send, "1"},
     {expect,"Un seul tarif est applique par zone pour vos appels voix vers la "
     "France Metropolitaine ou la zone de votre destination. Prix/mn des .*1:suite"},
     {send, "1"},
     {expect,"vers: la zone Europe =0.514E, .sauf Suisse-Andorre =1E15., la zone Maghreb/Amerique du Nord.Turquie=1.40E, la zone .Reste du monde.=3E. Prix.mn des appels"},
     {send, "1"},
     {expect,"recus depuis : la zone Europe = 0.227E, .sauf Suisse-Andorre =0.65E., la zone Maghreb.Amerique du Nord.Turquie= 0.75E, la zone .Reste du monde. = 1.50E."},
     {send, "1"},
     {expect,"En zone UE, vos appels sont decomptes a la sec des la 1ere sec pour la reception, a la sec au-dela de 30sec indivisibles pour les emissions d'appel en UE"},
     {send, "1"},
     {expect,"et vers la France. Dans les autres pays, facturation a la sec au-dela de la 1ere min indivisible. Envoi d'1 SMS vers ou depuis l'etranger: 0.30E .0,1315E"},
     {send, "1"},
     {expect,"depuis UE vers UE., reception gratuite. Envoi d'1 MMS vers ou depuis l'etranger: 1.10E. Reception d'un MMS: 0.80E. Prix des connexions data depuis"},
     {send, "1"},
     {expect,"l'etranger:0,30E TTC.10ko."},
     {send, "00"},
     {expect,"Connaitre les tarifs a l'etranger"},
     {send, "0"},
     {expect,".*"}
    ].

test_roaming([]) -> [];
test_roaming([H|T]) ->
    modify_account_state(H)++
    [
     {title, "Test de scripts a l'etranger "++display_test_account(H)},
     {ussd2,
      [ {send, ?DIRECT_CODE++"*0#"},
        {expect, "1:Connaitre les tarifs a l'etranger.*0:Retour"},
        {send, "1"}]++
                expected_roaming(H)
     }]++
    test_roaming(T).

top_num(200) ->
    86;
top_num(illimite) ->
    217;
top_num(opt_5n_pref)->
    451;
top_num(_) ->
    0.

tcp_num(200) ->
    138;
tcp_num(illimite) ->
    179;
tcp_num(opt_5n_pref)->
    311;
tcp_num(_) ->
    0.

ptf_num(200) ->
    96;
ptf_num(illimite) ->
    41;
ptf_num(opt_5n_pref)->
    346;
ptf_num(_) ->
    0.

sms_to_list(illimite)->
    "illimite";
sms_to_list(NbSms)->
    integer_to_list(NbSms).
