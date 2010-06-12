-module(svc_mipc_vpbx).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/include/mipc_vpbx_webserv.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../include/mipc_vpbx.hrl").

-export([slog_info/3]).
-include("../../oma/include/slog.hrl").

-compile(export_all).


consulterInformations_Request(abs, URL_MIPC, URL_VPBX, URL_NO_SITUATION, URL_NOK) ->
    [{redirect, abs, URL_MIPC}, 
     {redirect, abs, URL_VPBX}, 
     {redirect, abs, URL_NO_SITUATION},
     {redirect, abs, URL_NOK}];

consulterInformations_Request(Session,URL_MIPC, URL_VPBX, URL_NO_SITUATION, URL_NOK) ->
    Msisdn = msisdn_int(Session),
    case Msisdn of
        msisdn_nok ->
            {redirect, Session, URL_NOK};
	_->
	    %% if offre unknown, start with MIPC
	    case consulterInformations_Request(Session,Msisdn,[?MIPC, ?VPBX]) of
		{ok,mipc} ->
		    {redirect, Session, URL_MIPC};
		{ok,vpbx} ->
		    {redirect, Session, URL_VPBX};
		{ok,no_situation} ->
		    {redirect, Session, URL_NO_SITUATION};
		{ok,not_identified} ->
		    update_type(Session,undefined),
		    {redirect, Session, URL_NOK};
		{nok,failure} ->
		    %% reset type to make sure we try to identify him next time
		    update_type(Session,undefined),
		    {redirect, Session, "#system_failure"}
	    end
    end.


consulterInformations_Request(Session,Msisdn,[]) ->
    {ok,not_identified};

consulterInformations_Request(Session,Msisdn,[Type|OtherTypes]) ->
    case  mipc_vpbx_webserv:consulterInformations(Msisdn,Type) of
	{ok,#consulterInformationsResponse
	 {nbSituationsParametrees = NbSituationsParametrees,
	  typeOffre               = TypeOffre}}	->
	    case TypeOffre of
		?MIPC_TYPE_OFFRE ->
		    ok;
		?VPBX_TYPE_OFFRE ->
		    ok;
		?VPBX_TYPE_OFFRE1 ->
		    ok;
		UnknownType ->
		    slog:event(failure,?MODULE,unknown_type_offre,UnknownType)
	    end,
	    case list_to_integer(NbSituationsParametrees) of 
		X when X>=1 ->
		    %% check if an update in db is necessary
		    case variable:get_value(Session,mipcvpbx_offre) of
			not_found ->
			    update_type(Session,TypeOffre);
			TypeOffre ->
			    ok;
			NewType when NewType == ?MIPC_TYPE_OFFRE;
				     NewType == ?VPBX_TYPE_OFFRE;
				     NewType == ?VPBX_TYPE_OFFRE1 ->
			    update_type(Session,TypeOffre)		    
		    end,
		    {ok,Type};
		_->
		    {ok,no_situation}
	    end;
	{nok,CodeRetour,Commentaire} ->
	    case CodeRetour of
		"101"->
		    consulterInformations_Request(Session,Msisdn,OtherTypes);
		_ ->
		    {nok,failure}
	    end;
	_ ->
	    {nok,failure}
    end.

%% +type get_situation_active(session(),Type::string(),
%%                     TextOK::string(),TextNOK::string()) ->
%%%% Includes the situation active of user
get_situation_active(plugin_info, Type, TextOK, TextNOK) ->
    (#plugin_info
     {help =
      "This plugin function includes situation active of user"
      " if no profile found, display no situation active",
      type = function,
      license = [],
      args =
      [
       type_arg(),
       {textOK, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed if get the situation successfully."},
       {textNOK, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed if get the situation unsuccessfully."} 
      ]});
get_situation_active(abs, _, TextOK, TextNOK) ->
    [{pcdata,TextNOK}];
get_situation_active(Session, Type, TextOK, TextNOK) ->
    Msisdn = msisdn_int(Session),
    case (mipc_vpbx_webserv:situationActive(Msisdn,list_to_atom(Type))) of
	{ok,#situationActiveResponse
	 {situationActive = #situation{
	    libelleSituation = LibelleSituation}}} ->
	    [{pcdata,TextOK++" "++print_libelle(LibelleSituation)}];
	Else ->
	    slog:event(trace,?MODULE,unexpected_situation_active,Else),
	    update_type(Session,undefined),
	    [{pcdata,TextNOK}]
    end.

msisdn_int(#session{prof=#profile{msisdn=Msisdn}})->
    case Msisdn of
        [$+| MsisdnInt] ->
	    MsisdnInt;
	_->
	    slog:event(internal,?MODULE,msisdn_nok,Msisdn),
	    msisdn_nok
    end.

redir_by_type_offre(plugin_info, URL_MIPC, URL_VPBX, URL_NO_SITUATION, URL_NOK) ->
    (#plugin_info
     {help =
      "This plugin command redirect by Segment Commercial",
      type = command,
      license = [],
      args =
      [
       {url_mipc, {link, []},
        "This parameter specifies the page when offre type is mipc"},
       {url_vpbx, {link, []},
        "This parameter specifies the page when offre type is vpbx"},
       {url_no_situation, {link, []},
        "This parameter specifies the page when no situation"},
       {url_nok, {link, []},
        "This parameter specifies the nok page"}
      ]});

redir_by_type_offre(abs, URL_MIPC, URL_VPBX, URL_NO_SITUATION, URL_NOK)->
    [{redirect, abs, URL_MIPC},
     {redirect, abs, URL_VPBX},
     {redirect, abs, URL_NO_SITUATION},
     {redirect, abs, URL_NOK}];

redir_by_type_offre(Session, URL_MIPC, URL_VPBX, URL_NO_SITUATION, URL_NOK)->
    case db:lookup_svc_profile(Session, ?ServiceName) of
        {ok,{mipc_vpbx,?MIPC_TYPE_OFFRE}}->
	    NewSess = variable:update_value(Session, mipcvpbx_offre, ?MIPC),
            {redirect, NewSess, URL_MIPC};
        {ok,{mipc_vpbx,TypeOffre_}} when TypeOffre_==?VPBX_TYPE_OFFRE;
					 TypeOffre_==?VPBX_TYPE_OFFRE1 ->
	    NewSess = variable:update_value(Session, mipcvpbx_offre, ?VPBX),
            {redirect, Session, URL_VPBX};
        _->
            slog:event(trace,?MODULE,redir_by_type_offre,data_not_found),
	    Sub=svc_util_of:get_souscription(Session),
	    case Sub of
		dme->
		    slog:event(trace,?MODULE,redir_by_type_offre,
			       subscription_dme),
		    consulterInformations_Request(Session, URL_MIPC, URL_VPBX, 
						  URL_NO_SITUATION, URL_NOK);
		_ ->
		    slog:event(trace,?MODULE,redir_by_type_offre,
			       {subscription,Sub}),
		    {redirect, Session, URL_NOK}
	    end
    end.

%% +type get_list_situation(session(),Type::string(),
%%                     URL::hlink()) ->
%%%% Includes the list of situations
get_list_situations(plugin_info, Type, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin function get the list of situations active of user"
      " if no profile found, link to unsuccessful page",
      type = command,
      license = [],
      args =
      [
       type_arg(),
       {url_ok, {link,[]},
        "This parameter specifies the next when get list of situations succesfully."}, 
       {url_nok, {link,[]},
        "This parameter specifies the page unsuccessfully."} 
      ]});
get_list_situations(abs, Type, Url_ok, Url_nok) ->
    [{redirect,abs,Url_ok},
     {redirect,abs,Url_nok}];    

get_list_situations(Session, Type, Url_ok, Url_nok) ->
    Msisdn = msisdn_int(Session),
    case (mipc_vpbx_webserv:listeSituationsParametrees(Msisdn,list_to_atom(Type))) of
	{ok,#listeSituationsParametreesResponse
	 {listeSituations= ListSituations}} ->
	    List = lists:map(
		     fun(#situation{idSituation = Ids,
				    libelleSituation= Libelle})->
			     {Ids,print_libelle(Libelle)}
		     end, ListSituations),
	    NewSess = variable:update_value(Session, list_situation, List),	    
	    {redirect,NewSess,Url_ok};
	_ ->
	    update_type(Session,undefined),
	    {redirect,Session,Url_nok}
    end.

%% +type incl_list_situation(session(),Type::string(),
%%                     URL::hlink()) ->
%%%% Includes the list of situations
incl_list_situations(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes list of situations",
      type = function,
      license = [],
      args =
      [
      ]});
incl_list_situations(abs) ->
    [{pcdata,""}];

incl_list_situations(Session) ->
    List = variable:get_value(Session, list_situation),
    List1 = index_list(List,1),
    %% Get list of situations's name 
    Links = case (length(List)) of
		X when (X<7) ->   
		    lists:flatmap(
		      fun(Libelle) ->
			      [{pcdata,print_libelle(Libelle)},br]
		      end, List1);	    
		_ -> 
		    %% case > 6 situations, add Suite
		    List2 = lists:sublist(List1,?Max_situation),
		    Links2 = lists:flatmap(
			       fun(Libelle) ->
				       [{pcdata,print_libelle(Libelle)},br]
			       end, List2),
		    Links2++[{pcdata,"7:Suite"},br]		    
	    end,
    Links ++ [br,{pcdata,"9:Accueil"}].

%% +type incl_list_situation(session(),Type::string(),
%%                     URL::hlink()) ->
%%%% Includes the list of situations
incl_list_situations_next(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes next list of situation",
      type = function,
      license = [],
      args =
      [
      ]});
incl_list_situations_next(abs) ->
    [{pcdata,""}];

incl_list_situations_next(Session) ->
    List = variable:get_value(Session, list_situation),
    List1 = lists:sublist(List,?Max_situation+1,length(List)-?Max_situation),
    List2 = index_list(List1,1),
    %% Get list of situations's name 
    Links = lists:flatmap(
	      fun(Libelle) ->
		      [{pcdata,print_libelle(Libelle)},br]
	      end, List2),    
    Links++[br,{pcdata,"8:Precedent"},br,{pcdata,"9:Accueil"}].


select_situation(plugin_info,Url_situation,Url_suite,Url_accueil,Number)->
    (#plugin_info
     {help =
      "This plugin receive the number response from user and redirect to "
      " corresponding page",
      type = command,
      license = [],
      args =
      [
       {url_situation, {link,[]},
        "This parameter specifies the next page when a situation is selected."},
       {url_suite, {link,[]},
        "This parameter specifies the next page."},
       {url_accueil, {link,[]},
        "This parameter specifies the main page."},
       {number,form_data,
	"This parameter specifies the code response by user"}
      ]});
select_situation(abs,Url_situation,Url_suite,Url_accueil,Number) ->
    [{redirect,abs,Url_situation},
     {redirect,abs,Url_suite},
     {redirect,abs,Url_accueil}];

select_situation(Session, Url_situation, Url_suite, Url_accueil, Number) ->
    List = variable:get_value(Session, list_situation),
    Len = length(List),
    Min = lists:min([Len,?Max_situation]),
    case (pbutil:all_digits(Number)) of
	true ->
	    case (list_to_integer(Number)) of
		X when ((X>0) and (X=<Min)) ->		    
		    NewSess = variable:update_value(Session,selected_situation,Number),
		    NewSess1 = variable:update_value(NewSess,situation_next,"0"),
		    {redirect,NewSess1,Url_situation};
		X when ((X==7) and (Len>?Max_situation))->
		    {redirect,Session,Url_suite};
		X when (X==9) ->
		    {redirect,Session,Url_accueil};
		_ ->
		    {redirect,Session,"/system/home.xml#bad_choice"}
	    end;
	false  ->
	    {redirect,Session,"/system/home.xml#bad_choice"}
    end.

select_situation_next(plugin_info,Url_situation,Url_precedent,Url_accueil,Number)->
    (#plugin_info
     {help =
      "This plugin receive the number response from user and redirect to "
      " corresponding page",
      type = command,
      license = [],
      args =
      [
       {url_situation, {link,[]},
        "This parameter specifies the next page when a situation is selected."},
       {url_precedent, {link,[]},
        "This parameter specifies the preivous page."},
       {url_accueil, {link,[]},
        "This parameter specifies the main page."},
       {number,form_data,
	"This parameter specifies the code response by user"}
      ]});
    
select_situation_next(abs,Url_situation,Url_precedent,Url_accueil,Number) ->
    [{redirect,abs,Url_situation},
     {redirect,abs,Url_accueil}];

select_situation_next(Session, Url_situation, Url_precedent,Url_accueil, Number) ->
    List = variable:get_value(Session, list_situation),
    Len = length(List)-?Max_situation,
    case (pbutil:all_digits(Number)) of
	true ->
	    case (list_to_integer(Number)) of
		X when ((X>0) and (X=<Len)) ->		    
		    NewSess = variable:update_value(Session,selected_situation,Number),
		    NewSess1 = variable:update_value(NewSess,situation_next,"1"),
		    {redirect,NewSess1,Url_situation};
		X when (X==8) ->
		    {redirect,Session,Url_precedent};
		X when (X==9) ->
		    {redirect,Session,Url_accueil};
		_ ->
		    {redirect,Session,"/system/home.xml#bad_choice"}
	    end;
	false  ->
	    {redirect,Session,"/system/home.xml#bad_choice"}
    end.

incl_situation_selected(plugin_info)->    
    (#plugin_info
     {help =
      "This plugin function includes situation active of user"
      " if no profile found, display no situation active",
      type = function,
      license = [],
      args =
      [
      ]});
incl_situation_selected(abs) ->
    [{pcdata,""}];

incl_situation_selected(Session) ->
    List = variable:get_value(Session, list_situation),    
    Selected = variable:get_value(Session,selected_situation),
    Num_next = is_next_page(Session),
    {_,Libelle} = lists:nth(list_to_integer(Selected)+Num_next,List),
    [{pcdata,print_libelle(Libelle)}].

%% +type activate_situation(session(),Type::string(),
%%                     URL::hlink()) ->
%%%% Activate a situation
activate_situation(plugin_info, Type, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command activate a situation for user",
      type = command,
      license = [],
      args =
      [
       type_arg(),
       {url_ok, {link,[]},
        "This parameter specifies the next when activate situation succesfully."}, 
       {url_nok, {link,[]},
        "This parameter specifies the page unsuccessfully."} 
      ]});
activate_situation(abs, Type, Url_ok, Url_nok) ->
    [{redirect,abs,Url_ok},
     {redirect,abs,Url_nok}];    

activate_situation(Session, Type, Url_ok, Url_nok) ->
    Msisdn = msisdn_int(Session),
    List = variable:get_value(Session, list_situation),
    Selected = variable:get_value(Session,selected_situation),
    Num_next = is_next_page(Session),
    %% Get id of the situation selected 
    {Ids,_} = lists:nth(list_to_integer(Selected)+Num_next,List),

    case (mipc_vpbx_webserv:activerSituation(Msisdn,Ids,list_to_atom(Type))) of
	{ok,_}->
	    {redirect,Session,Url_ok};
	_ ->
	    update_type(Session,undefined),
	    {redirect,Session,Url_nok}
    end.

is_next_page(Session)->
     case (variable:get_value(Session,situation_next)) of
	 "1" ->
	     ?Max_situation;
	 _ -> 0
     end.

index_list([{_,B}|T],Num)->        
    [integer_to_list(Num)++":"++B]++index_list(T,Num+1);
index_list([],Num)->
    [].

consulterSituation_Request(plugin_info, Type, Url_no_renvoi, Url_I_vers_num, Url_I_vers_assistante, Url_RC, 
			   Url_C_vers_num, Url_C_vers_assistante, Url_O, Url_NR, Url_nok)->    
    (#plugin_info
     {help =
      "This plugin function includes situation active of user"
      " if no profile found, display no situation active",
      type = command,
      license = [],
      args =
      [
       type_arg(),
       {url_no_renvoi, {link,[]},
        "This parameter specifies the next when the situation is aucun renvoi"},
       {url_i_vers_num, {link,[]},
        "This parameter specifies the next when the situation is renvoi immediat vers numero"},
       {url_i_vers_assistante, {link,[]},
        "This parameter specifies the next when the situation is renvoi immediat vers assistante"},
       {url_rc, {link,[]},
        "This parameter specifies the next when the situation is recherche contact"},
       {url_c_vers_num, {link,[]},
        "This parameter specifies the next when the situation is renvoi conditionnel vers numero"},
       {url_c_vers_assistante, {link,[]},
        "This parameter specifies the next when the situation is renvoi conditionnel vers assistante"},
       {url_o, {link,[]},
        "This parameter specifies the next when the situation is renvoi sur occupation"},
       {url_nr, {link,[]},
        "This parameter specifies the next when the situation is renvoi sur non response"},
       {url_nok, {link,[]},
        "This parameter specifies the page unsuccessfully."}
      ]});
consulterSituation_Request(abs, Type, Url_no_renvoi, Url_I_vers_num, Url_I_vers_assistante, Url_RC,
                           Url_C_vers_num, Url_C_vers_assistante, Url_O, Url_NR, Url_nok) ->
    [{redirect, abs, Url_no_renvoi},
     {redirect, abs, Url_I_vers_num},
     {redirect, abs, Url_I_vers_assistante},
     {redirect, abs, Url_RC},
     {redirect, abs, Url_C_vers_num},
     {redirect, abs, Url_C_vers_assistante},
     {redirect, abs, Url_O},
     {redirect, abs, Url_NR},
     {redirect, abs, Url_nok}];

consulterSituation_Request(Session, Type, Url_no_renvoi, Url_I_vers_num, Url_I_vers_assistante, Url_RC,
                           Url_C_vers_num, Url_C_vers_assistante, Url_O, Url_NR, Url_nok) ->
    Msisdn = msisdn_int(Session),
    List = variable:get_value(Session, list_situation),
    Selected = variable:get_value(Session,selected_situation),
    Num_next = is_next_page(Session),
    %% Get id of the situation selected
    {Ids,_} = lists:nth(list_to_integer(Selected)+Num_next,List),
    case mipc_vpbx_webserv:consulterSituation(Msisdn,Ids,list_to_atom(Type)) of
	{ok,#consulterSituationResponse
	 {parametrageRenvois = #parametrageRenvois
	  {typeRenvoi = TypeRenvoie,
	   versNumerosLibres = VersNumerosLibres,
	   versAssistante=VersAssistante}} = Situation} ->
	    NSession = variable:update_value(Session,situation,Situation),
	    case TypeRenvoie of 
		?immediat ->
		    case catch check_values(VersAssistante,
					    VersNumerosLibres) of
			assistante ->
			    {redirect, NSession, Url_I_vers_assistante};
			numerosLibres ->
			    {redirect, NSession, Url_I_vers_num};
			Else ->
			    slog:event(failure,?MODULE,
				       missing_info_for_immediat,
				       {TypeRenvoie,Situation}),
			    {redirect, Session, Url_nok}
		    end;
		?recherche_contact  ->
		    {redirect, NSession, Url_RC};
		?conditionnel  ->
		    case catch check_values(VersAssistante,
					    VersNumerosLibres) of
			assistante ->
			    {redirect, NSession, Url_C_vers_assistante};
			numerosLibres ->
			    {redirect, NSession, Url_C_vers_num};
			_ ->
			    slog:event(failure,?MODULE,
				       missing_info_for_conditionnel,
				       {TypeRenvoie,Situation}),
			    {redirect, Session, Url_nok}
		    end;
		?occupation ->
		    {redirect, NSession, Url_O};
		?non_response ->
		    {redirect, NSession, Url_NR};
		_ ->
		    {redirect, Session, Url_no_renvoi}
	    end;	    
	_ ->
	    {redirect, Session, Url_nok}
    end.

check_values(VersAssistante, VersNumerosLibres) ->
    case VersAssistante of 
	VersAssistante_ 
	when VersAssistante_==undefined;
	     VersAssistante_==#versAssistante{} ->
	    case VersNumerosLibres of
		VersNumerosLibres_ 
		when VersNumerosLibres_==undefined;
		     VersNumerosLibres_==#versNumerosLibres{} ->
		    no_values;
		_ ->
		    numerosLibres
	    end;
	_ ->
	    assistante
    end.

print_numero_exception(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin prints a telephone number",
      type = function,
      license = [],
      args =
      []
     });
print_numero_exception(abs)->
    [{pcdata}];

print_numero_exception(Session) ->
    Situation = variable:get_value(Session, situation),
    case catch Situation of 
	#consulterSituationResponse{} ->
	    ParametrageRenvois = Situation#consulterSituationResponse.parametrageRenvois,
	    case catch ParametrageRenvois of
		#parametrageRenvois{} ->
		    ListeNumeros = ParametrageRenvois#parametrageRenvois.saufAppelsEmisDepuis,
		     case catch ListeNumeros of
                        undefined ->
                            [];
                        _ ->
                            [{pcdata,"Sauf pour:"},br]++print(ListeNumeros)
                    end;
		_ ->
		    []
	    end;
	_ ->
	    []
    end.

%% check_numero_exception(plugin_info, PCD, Url) ->
%%     (#plugin_info
%%      {help =
%%       "This plugin prints a telephone number",
%%       type = function,
%%       license = [],
%%       args =
%%       [{pcd, {oma_type, {defval,"",string}},
%%         "This parameter specifies the text to be displayed."},
%%        {url, {link,[]},
%% 	"This parameter specifies the next page"}]
%%      });
%% check_numero_exception(abs,PCD,URL)->
%%     [#hlink{href=URL,contents=[{pcdata,PCD}]};

%% check_numero_exception(Session,PCD,URL) ->
%%     Situation#consulterSituationResponse
%%       {parametrageRenvois = #parametrageRenvois{
%% 	 saufAppelsEmisDepuis = ListeNumeros}}	
%%        } = variable:get_value(Session, situation),
%%     case ListeNumeros of
%% 	undefined ->
%% 	    [];
%% 	_ ->
%% 	    [#hlink{href=URL,contents=[{pcdata,PCD}]}
%%     end;   
    

print_numero(plugin_info, Critere) ->
    (#plugin_info
     {help =
      "This plugin prints a telephone number",
      type = function,
      license = [],
      args =
      [
       {critere,{oma_type, {enum, [immediat,
				   immediat_vers_assistante,
				   contact,
				   conditionnel,
				   conditionnel_vers_assistante,
				   occupation,
				   non_reponse]}},
	"This is a critere of situation to consult"}
      ]
     });
print_numero(abs,Critere)->
    [{pcdata,Critere}];

print_numero(Session,Critere) ->
    Situation = variable:get_value(Session, situation),
    print_numero_int(Critere,Situation).

print_numero_int(Critere,#consulterSituationResponse
		 {parametrageRenvois = #parametrageRenvois{
		    versNumerosLibres = #versNumerosLibres{
		      listeNumeros = ListeNumeros}}
		 }=Situation) when Critere=="immediat";
				   Critere=="conditionnel";
				   Critere=="occupation";
				   Critere=="non_reponse" ->
    case ListeNumeros of
	undefined ->
	    slog:event(failure,?MODULE,missing_info,{Critere,Situation}),
	    [];
	_ ->
	    print(ListeNumeros)
    end;
print_numero_int("contact",#consulterSituationResponse
		 {parametrageRenvois = #parametrageRenvois{
		    versNumerosLibres = #versNumerosLibres{
		      premierNumero = PremierNumero,
		      listeNumeros = ListeNumeros,
		      boiteVocale = BoiteVocale}}
		 }) ->
    List1 = lists:map(fun(undefined) -> [];
			 (X) -> X end,
		      [PremierNumero,ListeNumeros,BoiteVocale]),
    print([PremierNumero]++ListeNumeros++[BoiteVocale]);
print_numero_int(Critere,#consulterSituationResponse
		 {parametrageRenvois = #parametrageRenvois{
		    versAssistante = Assistante}
		 }) when Critere=="immediat_vers_assistante";
			 Critere=="conditionnel_vers_assistante" ->
    print_vers_assistante(Assistante);
print_numero_int(Critere,Situation) ->
    slog:event(failure,?MODULE,unexpected_situation,{Critere,Situation}),
    [].
    
print([]) ->[];
print([[]|Tail]) ->
    print(Tail);
print([MSISDN|Tail]) ->
   [{pcdata,MSISDN},br]++print(Tail).	     
    
print_vers_assistante(#versAssistante{
		      nom = Nom,
		      prenom = Prenom,
		      numero = Numero,
		      typeAppel = TypeAppel}) ->
    Type = case TypeAppel of 
	       "*" -> "tous";
	       "E" -> "externe";
	       "I" -> "interne";
	       "S" -> "intra-site"
	   end,
    [{pcdata,"prenom: "++gsmcharset:iso2ud(Prenom,ascii)},br]++
	[{pcdata,"nom: "++gsmcharset:iso2ud(Nom,ascii)},br]++
	[{pcdata,"numero: "++Numero},br]++
	[{pcdata,"type appel: "++Type},br];
print_vers_assistante(Else) ->
    slog:event(warning,?MODULE,assistante_not_found,Else),
    [].


update_type(Session,Type) ->
    Data=#mipc_vpbx{profile=Type},
    db:update_svc_profile(Session, ?ServiceName, Data).
       
type_arg() ->
    {type, {oma_type, {enum, [?MIPC,?VPBX]}},
     "This parameter specifies the user's type: mipc or vpbx"}.

%% remove accentuated characters from libellés
print_libelle(Libelle) ->
    gsmcharset:iso2ud(Libelle,ascii).

%% Unused function
%% format_msisdn([$3,$3,X|Rest]) when X==$1;
%% 				   X==$2;
%% 				   X==$3;
%% 				   X==$4;
%% 				   X==$5;
%% 				   X==$6;
%% 				   X==$7 ->
%%     "0"++[X]++Rest;
%% format_msisdn([$0,X|Rest]=Num) when X==$1;
%% 				      X==$2;
%% 				      X==$3;
%% 				      X==$4;
%% 				      X==$5;
%% 				      X==$6;
%% 				      X==$7 ->
%%     Num;
%% format_msisdn(MSISDN) ->
%%     slog:event(failure,?MODULE,badly_formated_msisdn,MSISDN),
%%     "".


slog_info(failure,?MODULE,badly_formated_msisdn) ->
    #slog_info{descr="An MSISDN was received with a prefix different from:"
	       " 33X or 0X where X is a member of [1,2,3,4,5,6,7].",
	       operational="Check logs to see bad formed MSISDN.\n"};
slog_info(failure,?MODULE,unknown_type_offre)->
    #slog_info{descr="Received an unknown \"TypeOffre\".\n"
	       "Known types:\n"
		?MIPC_TYPE_OFFRE ++"\n"
		?VPBX_TYPE_OFFRE++"\n"
		?VPBX_TYPE_OFFRE1++"\n",
	       operational="Check logs to find received type.\n"};
slog_info(internal,?MODULE,msisdn_nok)->
    #slog_info{descr="internal MSISDN should start with a +",
	       operational="Check logs to see bad formed MSISDN.\n"};
slog_info(failure,?MODULE,missing_info_for_immediat) ->
    #slog_info{descr="Type renvoie is \"immediat\", but both fields"
	       " versNumerosLibres and versAssistante are absent.\n",
	       operational="Check logs to see {TypeRenvoie,Situation}.\n"};
slog_info(failure,?MODULE,missing_info_for_conditionnel) ->
    #slog_info{descr="Type renvoie is \"conditionnel\", but both fields"
	       " versNumerosLibres and versAssistante are absent.\n",
	       operational="Check logs to see {TypeRenvoie,Situation}.\n"};
slog_info(failure,?MODULE,missing_info)->
    #slog_info{descr="listeNumeros is empty when it should not.\n",
	       operational="Check logs to see {Critere,Situation}.\n"};
slog_info(failure,?MODULE,unexpected_situation)->
    #slog_info{descr="Situation unexpected, Cellcube does not know what"
	       " to do\n",
	       operational="Check logs to see {Critere,Situation}.\n"};
slog_info(warning,?MODULE,assistante_not_found)->
    #slog_info{descr="While trying to print info on Assistante,"
	       " the corresponding information was not found."
	       " Either the field is absent, or bad formed",
	       operational="Check why bad \"assitante\" field was sent."}.
