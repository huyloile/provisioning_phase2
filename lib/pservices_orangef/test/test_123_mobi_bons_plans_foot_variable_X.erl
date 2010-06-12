-module(test_123_mobi_bons_plans_foot_variable_X).
-compile(export_all).

-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("profile_manager.hrl").
-include("access_code.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plugins Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(Uid,mobi_foot_user).

run() ->
    test_decode_z70(),
    test_print_credit(),
    test_proposer_lien(),
    ok.

test_proposer_lien() ->
    lists:foldl(
      fun({Solde, State, Expected}, Count) ->
	      Session = set_session(Solde, State),
	      Result = svc_of_plugins:proposer_lien_soiree_foot(Session,"Url_actived","Text_actived","Url_not_actived","Text_not_actived","Text_not_credit"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{3000,[{158,actived}],[#hlink{href="Url_actived",key=[],kw=[],cost=0,help=[],contents=[{pcdata, "Text_actived"}]},br]},
       {9000,[{0,actived}],[#hlink{href="Url_not_actived",key=[],kw=[],cost=0,help=[],contents=[{pcdata, "Text_not_actived"}]},br]},
       {0,[{158,actived}],[{pcdata,"Text_not_credit"},br]},
       {0,[{0,actived}],[#hlink{href="Url_not_actived",key=[],kw=[],cost=0,help=[],contents=[{pcdata, "Text_not_actived"}]},br]}]).

test_print_credit() ->
    lists:foldl(
      fun({Solde, Expected}, Count) ->
	      Session = set_session(Solde),
	      [{pcdata,Result}] = svc_of_plugins:print_credit(Session,"mobi", "opt_kdo_sinf", "day"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{3000,"1 soiree infinie offerte"},
       {0,"aucune soiree infinie offerte"},
       {9000,"3 soirees infinies offertes"}]).

test_decode_z70()->
    lists:foldl(
      fun({Zone_70, State, Expected}, Count) ->
	      Result = svc_compte:decode_z70(Zone_70, State),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{[[18,0,0,0,"0","-",0,0,24,0],[161,0,0,0,"0","-",0,0,0,0]],
	state(default),state([{18,actived},{161,actived}])},
       {[[18,0,0,0,"0","S",0,0,24,0],[161,0,0,0,"0","a",0,0,0,0]],
	state(default),state([{18,suspend},{161,actived}])},
       {[[18,0,0,0,"0","S",0,0,24,0],[161,0,0,0,"0","-",0,0,0,0]],
	state(default),state([{18,suspend},{161,actived}])},
       {[[18,0,0,0,"0","-",0,0,24,0],[161,0,0,0,"0","S",0,0,0,0]],
	state(default),state([{18,actived},{161,suspend}])}]).

state(default)->
    #sdp_user_state{};
state(OPTIONS)->
    #sdp_user_state{options = OPTIONS}.

set_session(Solde,State) ->
    #session{prof=#profile{subscription="mobi",terminal=#terminal{imei="35185301"}},
	     svc_data=[{user_state,#sdp_user_state{declinaison=0,topNumList=[0],options=State, d_activ = test_util_of:lt2unixt({date(),{0,0,0}})+86400,
						   cpte_princ = #compte{tcp_num=?C_PRINC, 
									unt_num=?EURO, 
									cpp_solde=10000, 
									dlv=pbutil:unixtime(), 
									rnv=0, 
									etat=?CETAT_AC,
									ptf_num=?PLUGV3},
						   cpte_list = [{cpte_bons_plans,#compte{tcp_num=?C_BONS_PLANS,
											 unt_num=?EURO,
											 cpp_solde={sum,euro,Solde},
											 dlv=pbutil:unixtime(),
											 rnv=0,
											 etat=?CETAT_AC,
											 ptf_num=?PBONS_PLANS}}] }}]}.
set_session(Solde)->
    set_session(Solde,[{0,actived}]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online - function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(CODE_MENU, "#123*1").
-define(CODE_FOOT_VAR_X,
	test_util_of:link_rank(test_123_mobi_homepage,
			       ?menu_page,
			       ?foot_variable_x,
			       [?foot_variable_x])).

-define(CODE_ORANGE_FOOT,
	test_util_of:link_rank(test_123_mobi_homepage,
			       ?menu_page,
			       ?foot_variable_y,
			       [?foot_variable_x, ?foot_variable_y])).

code_bons_plans(Solde) ->
    case Solde of
	0 ->
            "#123*1*3";
	_  ->
            "#123*1*4"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(L,[
	   ?RC_LENS_mobile,
	   ?ASSE_mobile,
	   ?OL_mobile,
	   ?OM_mobile,
	   ?PSG_mobile,
	   ?BORDEAUX_mobile
	  ]).
online() ->
    test_util_of:online(?MODULE,test()),
    ok.
test()->
    test_foot_variable_X_link_CLUB_FOOT()++
  	test_foot_variable_X_link(?L)++
 	test_decouvrir_orange()++
 	test_foot_bons_plans_variable_X_CLUB_FOOT()++
       	lists:append([test_foot_bons_plans_variable_X(Title,Solde,Top_num,Text,Text2,?L) || 
      			 {Title,Solde,Top_num,Text,Text2} <-
    			     [{"OPTION DEJA ACTIVEE - CPTE = 0",
   			       0,
    			       158,
    			       "Vous avez epuise vos soirees infinies offertes.*1:Les offres eXclusives.*","Votre demande ne"},
 
    			      {"OPTION DEJA ACTIVEE - CPTE > 0",
   			       3000,
    			       158,
    			       "1:Profitez de vos soirees infinies.2:Les offres eXclusives","Il vous reste"},
 
    			      {"OPTION NON ACTIVE",
   			       9000,
    			       0,
    			       "1:Activez vos soirees infinies.2:Les offres eXclusives","Profitez chaque mois"}]]) ++
 	test_util_of:close_session()++
	["Test reussi"].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_foot_variable_X_link_CLUB_FOOT()->
    %% TEST NEW DECLINAISON FOOT
    init_test(?CLUB_FOOT)++
        test_link_confirmer(?CLUB_FOOT)++
	[].
test_foot_variable_X_link([])->
    [];
test_foot_variable_X_link([DCL|T])->

    %% TEST OLD DECLINAISON FOOT
    init_test(DCL) ++
 	test_link_activez(DCL) ++
  	test_link_profitez(DCL) ++
  	test_no_link_variable_X(DCL) ++
	test_util_of:close_session() ++
	test_foot_variable_X_link(T) ++
	[].

test_link_activez(DCL) ->
    profile_manager:set_list_options(?Uid,[#option{top_num=414}])++
	profile_manager:set_list_comptes(?Uid,
			    [#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=42000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=?PCLAS_V2}])++
	[{title, "TEST LINK SOIREE INFINIES CLUBS DE FOOT\n"
	  "OPTION NON ACTIVE - DCL_NUM= " ++ integer_to_list(DCL)},

	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Activez vos soirees infinies.*:Decouvrir l'option Sport.*6:Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Profitez chaque mois de 4 soirees infinies pour appeler en illimite les fixes et les mobiles Orange de 21h a minuit.*"},
	   {send,"1"},
	   {expect, "Ideal pour refaire le match avec vos amis pendant les soirees de championnat, les soirees infinies vous permettent d'appeler en illimite les fixes et mobiles Orange.*"},
	   {send,"1"},
	   {expect, "en France metropolitaine de 21h a minuit. Pour pouvoir profiter de vos 4 soirees infinies chaque mois, il faut tout d'abord activer votre compte soirees infinies."},
	   {send,"1"},
	   {expect, "Une fois votre compte active,il est automatiquement renouvele tous les 31 jours a date anniversaire de son activation sous reserve que votre credit soit superieur a zero"},
	   {send,"1"},
	   {expect, "Ensuite, pour profiter de vos 4 soirees infinies par mois, c'est simple, il vous suffit d'appeler le 220 ou le #123# et de souscrire une soiree infinie."},
	   {send,"1"},
	   {expect,  "...le soir des matchs de votre equipe.*1:Activer votre compte soirees infinies.*9:Accueil"},
	   {send,"1"},
	   {expect, "Vous allez activer gratuitement votre compte soirees infinies.*1:Confirmer"},
	   {send,"1"},
	   {expect, "Votre souscription a bien ete prise en compte. Dans quelques instants, votre compte soirees infinies sera activee."}
	  ]},
	 {pause, 1000}] ++
	[].

test_link_profitez(DCL) ->
    profile_manager:set_list_options(?Uid,[#option{top_num=158}])++
	profile_manager:set_list_comptes(?Uid,
			    [#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=42000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=?PCLAS_V2},
			     #compte{tcp_num=?C_BONS_PLANS, %%compte utilise pour les soiree infinie
				     unt_num=?EURO,
				     cpp_solde=9000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=144}])++
 	[{title, "TEST SOIREE INFINIES CLUBS DE FOOT\n"
	  "OPTION DEJA ACTIVE - CPTE > 0 - DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,"2:Profitez de vos soirees infinies"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect,"Il vous reste 3 soiree.*"
	    "1:Pour activer une soiree infinie valable de 21h00 a minuit."
	    "2:Conditions"},
	   {send,"2"},
	   {expect,"Souscription possible le jour meme de 2h a 23h45 \\(appels gratuits depuis la France metropolitaine\\)....1:Suite"},
	   {send,"1"},
	   {expect,"Les 3E sont preleves a la souscription de l'option sur le compte.*1:Suite"},
	   {send,"1"},
	   {expect,"Appels voix, 3h maximum par appel, hors num speciaux, num de services et num en cours de portabilite... 1:Suite "},
	   {send,"1"},
	   {expect,"Appels directs entre personnes physiques et pour un usage personnel non lucratif direct.*"
	    "1:Pour activer une soiree infinie valable de 21h00 a minuit"},
	   {send,"8888*1"},
	   {expect,"Votre demande a bien ete prise en compte."}]},
	 {pause, 1000}] ++
	[].

test_no_link_variable_X(DCL) ->
    profile_manager:set_list_options(?Uid,[#option{top_num=158}])++
	profile_manager:set_list_comptes(?Uid,
			    [#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=42000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=?PCLAS_V2},
			     #compte{tcp_num=?C_BONS_PLANS, %%compte utilise pour les soiree infinie
				     unt_num=?EURO,
				     cpp_solde=0,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=144}])++
 	[{title, "TEST SOIREE INFINIES CLUBS DE FOOT\n"
	  "OPTION DEJA ACTIVE - CPTE = 0 -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,"Menu #123#.*1:Recharger.*2:Decouvrir l'option Sport.*3:Vos bons plans.*4:Fun.*5:Nouveautes"}
	  ]},
	 {pause, 1000}] ++
	[].

test_link_confirmer(DCL) ->
    profile_manager:set_list_options(?Uid,[])++
	profile_manager:set_list_comptes(?Uid,
			    [#compte{tcp_num=?C_PRINC,
				     unt_num=?EURO,
				     cpp_solde=42000,
				     dlv=pbutil:unixtime(),
				     rnv=0,
				     etat=?CETAT_AC,
				     ptf_num=?PCLAS_V2}])++
	[{title, "TEST CONFIRMER CLUBS DE FOOT ASSE -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Confirmer votre club.*Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Pour profiter pleinement de votre carte prepayee club de foot, vous devez confirmer votre club.*1:ASSE.*2:Girondins.*3:OL.*4:OM.*5:PSG.*6:RCL"},
	   {send,"1"},
	   {expect, "Pour confirmer ASSE, repondre 1.*1:Confirmer"},
 	   {send,"1"},
 	   {expect, "Votre club ASSE est confirme..*Si vous ne l'avez pas fait,renvoyez le coupon de la pochette Club de foot et les pieces demandees pour activer definitivement votre carte"},
 	   {send,"9"},
 	   {expect, "Menu #123#.*"}
	  ]},
	 {pause, 1000}] ++

    profile_manager:set_list_options(?Uid,[])++
 	[{title, "TEST CONFIRMER CLUBS DE FOOT Girondins -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Confirmer votre club.*Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Pour profiter pleinement de votre carte prepayee club de foot, vous devez confirmer votre club.*1:ASSE.*2:Girondins.*3:OL.*4:OM.*5:PSG.*6:RCL"},
	   {send,"2"},
	   {expect, "Pour confirmer Girondins, repondre 1.*1:Confirmer"},
	   {send,"1"},
	   {expect, "Club Girondins confirme..*Si vous ne l'avez pas fait,renvoyez le coupon de la pochette Club de foot et les pieces demandees pour activer definitivement votre carte"},
	   {send,"9"},
	   {expect, "Menu #123#.*"}
	  ]},
	 {pause, 1000}] ++

    profile_manager:set_list_options(?Uid,[])++
	[{title, "TEST CONFIRMER CLUBS DE FOOT OL -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Confirmer votre club.*Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Pour profiter pleinement de votre carte prepayee club de foot, vous devez confirmer votre club.*1:ASSE.*2:Girondins.*3:OL.*4:OM.*5:PSG.*6:RCL"},
	   {send,"3"},
	   {expect, "Pour confirmer OL, repondre 1.*1:Confirmer"},
	   {send,"1"},
	   {expect, "Votre club OL est confirme..*Si vous ne l'avez pas fait,renvoyez le coupon de la pochette Club de foot et les pieces demandees pour activer definitivement votre carte"},
	   {send,"9"},
	   {expect, "Menu #123#.*"}
	  ]},
	 {pause, 1000}] ++

    profile_manager:set_list_options(?Uid,[])++
	[{title, "TEST CONFIRMER CLUBS DE FOOT OM -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Confirmer votre club.*Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Pour profiter pleinement de votre carte prepayee club de foot, vous devez confirmer votre club.*1:ASSE.*2:Girondins.*3:OL.*4:OM.*5:PSG.*6:RCL"},
	   {send,"4"},
	   {expect, "Pour confirmer OM, repondre 1.*1:Confirmer"},
	   {send,"1"},
	   {expect, "Votre club OM est confirme..*Si vous ne l'avez pas fait,renvoyez le coupon de la pochette Club de foot et les pieces demandees pour activer definitivement votre carte"},
	   {send,"9"},
	   {expect, "Menu #123#.*"}
	  ]},
	 {pause, 1000}] ++

    profile_manager:set_list_options(?Uid,[])++
	[{title, "TEST CONFIRMER CLUBS DE FOOT PSG -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Confirmer votre club.*Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Pour profiter pleinement de votre carte prepayee club de foot, vous devez confirmer votre club.*1:ASSE.*2:Girondins.*3:OL.*4:OM.*5:PSG.*6:RCL"},
	   {send,"5"},
	   {expect, "Pour confirmer PSG, repondre 1.*1:Confirmer"},
	   {send,"1"},
	   {expect, "Votre club PSG est confirme..*Si vous ne l'avez pas fait,renvoyez le coupon de la pochette Club de foot et les pieces demandees pour activer definitivement votre carte"},
	   {send,"9"},
	   {expect, "Menu #123#.*"}
	  ]},
	 {pause, 1000}] ++

    profile_manager:set_list_options(?Uid,[])++
	[{title, "TEST CONFIRMER CLUBS DE FOOT RCL -  DCL_NUM= " ++ integer_to_list(DCL)},
	 {ussd2,
	  [
	   {send, ?CODE_MENU},
	   {expect,".*2:Confirmer votre club.*Nouveautes.*"},
	   {send, ?CODE_FOOT_VAR_X},
	   {expect, "Pour profiter pleinement de votre carte prepayee club de foot, vous devez confirmer votre club.*1:ASSE.*2:Girondins.*3:OL.*4:OM.*5:PSG.*6:RCL"},
	   {send,"6"},
	   {expect, "Pour confirmer RCL, repondre 1.*1:Confirmer"},
	   {send,"1"},
	   {expect, "Votre club RCL est confirme..*Si vous ne l'avez pas fait,renvoyez le coupon de la pochette Club de foot et les pieces demandees pour activer definitivement votre carte"},
	   {send,"9"},
	   {expect, "Menu #123#.*"}
	  ]},
	 {pause, 1000}] ++
        profile_manager:set_list_options(?Uid,[#option{top_num=414}])++
        profile_manager:set_list_comptes(?Uid,
                            [#compte{tcp_num=?C_PRINC,
                                     unt_num=?EURO,
                                     cpp_solde=42000,
                                     dlv=pbutil:unixtime(),
                                     rnv=0,
                                     etat=?CETAT_AC,
                                     ptf_num=?PCLAS_V2}])++
        [{title, "HOME PAGE - MENU FOOT - CHOIX CLUB EFFECTUE - DCL_NUM= " ++ integer_to_list(DCL)},
         {ussd2,
	  [ {send, ?CODE_MENU},
	    {expect,"[^2:Confirmez votre club.*]"}
	   ]},
	 {pause, 1000}] ++
	[].
test_foot_bons_plans_variable_X(Title,Solde,Top_num,Text,Text2,[]) ->
    [];
test_foot_bons_plans_variable_X(Title,Solde,Top_num,Text,Text2,[DCL|T]) ->
    init_test(DCL)++
    case Top_num of
       0 -> 
   	    profile_manager:set_list_options(?Uid,[]);
       _ ->
   	    profile_manager:set_list_options(?Uid,[#option{top_num=Top_num}])
       end++
 	profile_manager:set_list_comptes(?Uid,
 			    [#compte{tcp_num=?C_PRINC,
 				     unt_num=?EURO,
 				     cpp_solde=42000,
 				     dlv=pbutil:unixtime(),
 				     rnv=0,
 				     etat=?CETAT_AC,
 				     ptf_num=?PCLAS_V2},
			     #compte{tcp_num=?C_BONS_PLANS, %%compte utilise pour les soiree infinie
 				     unt_num=?EURO,
 				     cpp_solde=Solde,
 				     dlv=pbutil:unixtime(),
 				     rnv=0,
 				     etat=?CETAT_AC,
 				     ptf_num=144}])++  
	[{title, "TEST MENU BONS PLANS - LINK VARIABLE X\n"++Title++
	  " - DCL = " ++ integer_to_list(DCL)},
	 {ussd2,
	  [ 
	    {send, code_bons_plans(Solde)},
	    {expect, Text},
	    {send,"1"},
	    {expect,Text2}]}]++
	test_util_of:close_session()++
	test_foot_bons_plans_variable_X(Title,Solde,Top_num,Text,Text2,T).
test_foot_bons_plans_variable_X_CLUB_FOOT()->
    init_test(?CLUB_FOOT)++
        profile_manager:set_list_options(?Uid,[#option{top_num=414}])++
        profile_manager:set_list_comptes(?Uid,
                            [#compte{tcp_num=?C_PRINC,
                                     unt_num=?EURO,
                                     cpp_solde=42000,
                                     dlv=pbutil:unixtime(),
                                     rnv=0,
                                     etat=?CETAT_AC,
                                     ptf_num=?PCLAS_V2}])++
        [{title, "HOME PAGE - MENU FOOT BONS PLANS - CHOIX CLUB EFFECTUE - DCL_NUM= " ++ integer_to_list(?CLUB_FOOT)},
         {ussd2,
          [ 
	    {send, ?CODE_MENU},
            {expect,".*"},
            {send,"2"},
            {expect,"[^1:Confirmez votre club]"}
           ]},
         {pause, 1000}] ++
        [].
test_decouvrir_orange()->
    init_test(?OM_mobile)++
	profile_manager:set_list_options(?Uid,[])++
 	profile_manager:set_list_comptes(?Uid,
 			    [#compte{tcp_num=?C_PRINC,
 				     unt_num=?EURO,
 				     cpp_solde=42000,
 				     dlv=pbutil:unixtime(),
 				     rnv=0,
 				     etat=?CETAT_AC,
 				     ptf_num=?PCLAS_V2},
			     #compte{tcp_num=?C_BONS_PLANS,
 				     unt_num=?EURO,
				     cpp_solde=0,
 				     dlv=pbutil:unixtime(),
 				     rnv=0,
 				     etat=?CETAT_AC,
 				     ptf_num=144}])++  
        [{title, "TEST DECOUVRIR ORANGE FOOT - DCL = " ++ integer_to_list(?OM_mobile)},
	 {ussd2,
	  [ 
	    {send, ?CODE_MENU},
	    {expect, ".*3:Decouvrir l'option Sport.*"},
	    {send, ?CODE_ORANGE_FOOT},
	    {expect, "Avec l'option Sport, suivez les grands evenements sportifs en illimite 24h/24 7j/7 pr 6E/mois"}
	   ]}].

init_test(DCL_NUM)->
    profile_manager:create_default(?Uid,"mobi")++
    profile_manager:set_dcl(?Uid,DCL_NUM)++ 
    profile_manager:init(?Uid).
