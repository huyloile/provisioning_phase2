-module(svc_m5_orangef).
-export([redirect_by_open_hours/3,
	 redirect_by_membership/4,
	 redirect_by_membership_m5_plus/3,
	 redirect_by_target_m5BO/3,
	 link_if_m5_plus_target/3]).
-export([catalogue_page/2, catalogue_header/2, catalogue/4, present_naming/2]).
-export([display_page/2]).
-export([present_page/3,present_page/4,
	 present_details/5,
	 select_present/6,
	 confirm_selection/4,
         present_description_suite/5]).
-export([select_presents_for_page/4]).
-export([print_usage/4]).
-export([read_activationPrime/3]).
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pdist_orangef/include/spider.hrl").

-define(catalogue_first_page_presents_default, 2).
-define(catalogue_next_page_presents, 4).
-define(first_page_presents_by_tu, 3).
-define(next_page_presents_by_tu, 3).
-define(ACTIVATION_NOW, "I").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redirect_by_open_hours(abs, Open_href, Closed_href) ->
    [{redirect, abs, Open_href},
     {redirect, abs, Closed_href}];
redirect_by_open_hours(Session, Open_href, Closed_href) ->
    Subscr = svc_util_of:get_souscription(Session),
    Horaire = pbutil:get_env(pservices_orangef, m5_horaire_ouverture),
    {Open_from, Open_to} =
	case lists:keysearch(Subscr, 1, Horaire) of
	    {value,{Subscr, Open, Close}} ->
		{Open, Close}; 
	    _ ->
		{{0,0,0},{0,0,0}}
	end,
    {Date, Time} = erlang:localtime(),
    Href = case svc_util_of:check_plage_horaire(Time, {Open_from, Open_to}) of
	       true -> Open_href;
	       false -> Closed_href
	   end,
    {redirect, Session, Href}.

redirect_by_membership(abs, Member_href, Non_member_href, Error_href) ->
    [{redirect, abs, Member_href},
     {redirect, abs, Non_member_href},
     {redirect, abs, Error_href}];
redirect_by_membership(Session,
		       Member_href,
		       Non_member_href,
		       Error_href) ->
    {Result, M5_data} =
	case variable:get_value(Session, {?MODULE, m5_profile}) of
	    not_found ->
		consult_account(Session);
	    Stored_M5_data ->
		{ok, Stored_M5_data}
	end,
    case Result of
	ok ->
	    Updated_session =
		variable:update_value(Session, {?MODULE, m5_profile},
				      M5_data),
	    Href = case lists:member(adherent, M5_data) of
		       true -> Member_href;
		       false -> Non_member_href
		   end,
	    {redirect, Updated_session, Href};
	_ ->
	    {redirect, Session, Error_href}
    end.

redirect_by_membership_m5_plus(abs, M5_plus_member_href,
			       Non_m5_plus_member_href) ->
    [{redirect, abs, M5_plus_member_href},
     {redirect, abs, Non_m5_plus_member_href}];
redirect_by_membership_m5_plus(Session,
			       M5_plus_member_href,
			       Non_m5_plus_member_href) ->
    Data = variable:get_value(Session, {?MODULE, m5_profile}),
    Href = case lists:member(adherentM5Plus, Data) of
	       true -> M5_plus_member_href;
	       false -> Non_m5_plus_member_href
	   end,
    {redirect, Session, Href}.

redirect_by_target_m5BO(abs, M5BO_href, Non_M5BO_href) ->
    [{redirect, abs, M5BO_href},
     {redirect, abs, Non_M5BO_href}];
redirect_by_target_m5BO(Session, M5BO_href, Non_M5BO_href) ->
    Data = variable:get_value(Session, {?MODULE, m5_profile}),
    Href = case lists:member(cibleM5BO, Data) of
	       true -> M5BO_href;
	       false -> Non_M5BO_href
	   end,
    {redirect, Session, Href}.

link_if_m5_plus_target(abs, _, _) ->
    [{pcdata,"Programme de fidelite global Encore+"}];
link_if_m5_plus_target(Session, Href, Text) when is_record(Session, session) ->
    Data = variable:get_value(Session, {?MODULE, m5_profile}),
    case lists:member(cible, Data) or lists:member(adherentM5Plus, Data) of
	true -> [#hlink{href=Href, contents=[{pcdata, Text}]}, br];
	false -> []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API INTERFACE - EXPORT FUNCTIONS USED BY OTHER MODULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display_page(abs,ValueName) ->
    [{redirect, abs, "Valeur dynamique"}];
display_page(Session,ValueName) ->
    case variable:get_value(Session, {?MODULE, list_to_atom(ValueName)}) of
	not_found ->
	    [{pcdata,""}];
	Page -> 
	    Page
    end.

catalogue_page(abs, _) ->
    [{redirect, abs, "#menu_indisponibilite"}];
catalogue_page(#session{prof=#profile{subscription=Subscription}}=Session, Page) ->
    {Result, M5_data} =
	case variable:get_value(Session, {?MODULE, m5_presents}) of
	    not_found ->
		consult_catalogue(Session);
	    Stored_M5_data ->
		{ok, Stored_M5_data}
	end,
    slog:event(trace,?MODULE,m5_data,M5_data),
    case Result of
	ok ->
	    Updated_session = 
		variable:update_value(Session, {?MODULE, m5_presents},
				      M5_data),
	    case catalogue(Subscription,list_to_integer(Page), M5_data,
			   {?MODULE,present_naming}) of
		{ok, Catalogue} ->
%%		    Updated_session_2 =variable:update_value(Updated_session, {?MODULE, page_catalogue}, Catalogue),
%%		    {redirect, Updated_session_2 ,"#page_catalogue"};
		    {page, Updated_session, #page{items=Catalogue}};
		error ->
		    {redirect, Updated_session, "#menu_indisponibilite"}
	    end;
	_ ->
	    {redirect, Session, "#menu_indisponibilite"}
    end.

present_page(abs, _, _) ->
    [{redirect, abs, "#menu_indisponibilite"}];
present_page(#session{prof=#profile{subscription=Subscription}}=Session, Page, TU) ->
    {Result, M5_data} =
    consult_catalogue(Session, TU),
    case Result of
	ok ->
	    Updated_session = 
		variable:update_value(Session, {?MODULE, m5_presents_for_TU},
				      M5_data),
	    M5_session = 
		variable:update_value(Updated_session, {?MODULE, m5_tu}, TU),
	    case present(Subscription,list_to_integer(Page), M5_data,
			 {?MODULE,present_naming}, TU) of
		{ok, Present} ->
		    Updated_session_2 =variable:update_value(Updated_session, {?MODULE, menu_TU}, Present),
		    {redirect, Updated_session_2 ,"#menu_"++TU};		    
	error ->
		    {redirect, M5_session, "#menu_indisponibilite"}
	    end;
	_ ->
	    {redirect, Session, "#menu_indisponibilite"}
    end.

present_page(#session{prof=#profile{subscription=Subscription}}=Session, Page, TU, Presents_names) ->
    {Result, M5_data} =
	consult_catalogue(Session, TU),
    case Result of
	ok ->
	    Updated_session = 
		variable:update_value(Session, {?MODULE, m5_presents_for_TU},
				      M5_data),
	    M5_session = 
		variable:update_value(Updated_session, {?MODULE, m5_tu}, TU),
 	    case present(Subscription,list_to_integer(Page), M5_data,
 			 {?MODULE,present_naming}, TU, Presents_names) of
 		{ok, Present} ->
 		    Updated_session_2 =variable:update_value(Updated_session, {?MODULE, menu_TU}, Present),
 		    {redirect, Updated_session_2 ,"#menu_"++TU};		    
 		error ->
 		    {redirect, M5_session, "#menu_indisponibilite"}
 	    end;
	_ ->
	    {redirect, Session, "#menu_indisponibilite"}
    end.

present_details(abs,_,_,_,_) ->
    [{redirect, abs, "#details"}];
present_details(Session,Present_id, Price, Delay, Usage) ->
    Subscr = svc_util_of:get_souscription(Session),
    case present_description(external_id, Present_id) of
        {Description_msg, none} -> 
            Href_confirm = "erl://"?MODULE_STRING":confirm_selection?"++Present_id++"&"++Price++"&"++Delay,
            Confirm = [#hlink{href=Href_confirm, contents=[{pcdata, "Confirmer"}]}],
            All_lines = lists:append([Description_msg,
                                      Confirm
                                      ]),
            Item = svc_util_of:br_separate(All_lines),
            Updated_session =variable:update_value(Session, {?MODULE, details}, Item),
            {redirect, Updated_session ,"#details"};
        {Description_msg, Description_suite_msg} ->
            Href_suite = "erl://"?MODULE_STRING":present_description_suite?"++Description_suite_msg++"&"++Present_id++"&"++Price++"&"++Delay,
            Suite = [#hlink{href=Href_suite, contents=[{pcdata, "Suite"}]}],
            Href_confirm = "erl://"?MODULE_STRING":confirm_selection?"++Present_id++"&"++Price++"&"++Delay,
            Confirm = [#hlink{href=Href_confirm, contents=[{pcdata, "Confirmer"}]}],
            All_lines = lists:append([Description_msg,
                                      Suite,
                                      Confirm
                                      ]),
            Item = svc_util_of:br_separate(All_lines),
            Updated_session =variable:update_value(Session, {?MODULE, details}, Item),
            {redirect, Updated_session ,"#details"}
    end.

present_description_suite(Session,Description_suite, Present_id, Price, Delay)->
    Subscr = svc_util_of:get_souscription(Session),
    Href_confirm = "erl://"?MODULE_STRING":confirm_selection?"++Present_id++"&"++Price++"&"++Delay,
    Confirm = [#hlink{href=Href_confirm, contents=[{pcdata, "Confirmer"}]}],
    All_lines = lists:append([Description_suite,
                              Confirm
                              ]),
    Item = svc_util_of:br_separate(All_lines),
    Updated_session =variable:update_value(Session, {?MODULE, details}, Item),
    {redirect, Updated_session ,"#details"}.

select_present(#session{prof=#profile{subscription=Subscription}}=Session,
	       Present_id, Naming, Price, Delay, Usage) ->
    {ok, Present} = present_naming(Subscription,Present_id),
    Header = confirm_message(Usage,Delay,Present,Price),
    Href_confirm = "erl://"?MODULE_STRING":confirm_selection?"++Present_id++"&"++Price++"&"++Delay,
    Confirm = [#hlink{href=Href_confirm, contents=[{pcdata, "Confirmer"}]}],
    Href_description = "erl://"?MODULE_STRING":present_details?"++Present_id++"&"++Price++"&"++Delay++"&"++Usage,
    Description = [#hlink{href=Href_description, contents=[{pcdata, "Descriptif du cadeau"}]}],
    All_lines = lists:append([Header,
			      Confirm,
			      Description]),
    Item = svc_util_of:br_separate(All_lines),
    Updated_session =variable:update_value(Session, {?MODULE, select_present}, Item),
    {redirect, Updated_session ,"#select_present"}.

confirm_selection(abs, _, _,_) ->
    [{redirect, abs, "#solde_insuffisant"},
     {redirect, abs, "#menu_indisponibilite"}];
confirm_selection(#session{prof=#profile{subscription=Subscription}}=Session,
		  Present_id, Price, Delay) ->
    slog:event(count,?MODULE,{menu_activation_recompense,Subscription,Present_id}),
    {Result, Solde} = activate_present(Session, Present_id, Price),
    Data = variable:get_value(Session, {?MODULE, m5_presents}),
    case Result of
	ok ->
	    prisme_dump:prisme_count(Session,{m5, Present_id}),
	    TU = case variable:get_value(Session, {?MODULE, m5_tu}) of
		     not_found -> "pas de type d'usage";
		     M5_TU -> M5_TU
		 end,
	    slog:event(count,?MODULE,
		       {souscription_recompense,Subscription,Present_id, TU}),
	    Confirmation = validate_message(Solde),
	    Updated_session =variable:update_value(Session, {?MODULE, confirmation}, Confirmation),
	    {redirect, Updated_session ,"#confirmation"};
	not_enough_credit ->
	    {redirect, Session, "#solde_insuffisant"};
	mobile_pbm ->
	    {redirect, Session, "#mobile_non_eligible"};
	high_credit ->
	    {redirect, Session, "#plafond"};
	error_PCM_points ->
	    {redirect, Session, "#erreur_PCM_points"};
	_ ->
	    {redirect, Session, "#menu_indisponibilite"}
    end;

confirm_selection(_, _, _, _) ->
    [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, USED ALSO IN TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

select_presents_for_page(Page, Sorted_list, Nb_presents_first_page,
			 Nb_presents_next_pages) ->
    {Start, Length, Next_page} =
	selection(Page, length(Sorted_list), Nb_presents_first_page,
		  Nb_presents_next_pages),
    {lists:sublist(Sorted_list, Start, Length), Next_page}.

selection(Page, Length, Nb_presents_first_page, _) 
  when Page == 1, Length =< Nb_presents_first_page ->
    {1, Length, false};
selection(Page, Length, Nb_presents_first_page, _)
  when Page == 1 ->
    {1, Nb_presents_first_page, true};
selection(Page, List_length, Nb_presents_first_page, Nb_presents_next_page)
  when Page > 1 ->
    Start = Nb_presents_first_page+1 + (Page-2)*Nb_presents_next_page,
    Remaining_length = List_length - Start + 1,
    {Selection_length, Has_next_page} = case Remaining_length > 4 of
				   true ->
				       {4, true};
				   false ->
				       {Remaining_length, false}
			       end,
    {Start, Selection_length, Has_next_page}.

catalogue_header(Data, 1) ->
    {value, {solde, Balance, PointsCB, Full_balance_date }} =
	lists:keysearch(solde, 1, Data),
    Balance_date = lists:sublist(Full_balance_date, 5),
    {value, {echeance, Expiring, Full_expiry_date}} =
	lists:keysearch(echeance, 1, Data),
    case {Full_expiry_date,PointsCB} of
	{"",""} ->
	    [{pcdata, lists:append(
			["Au ", Balance_date,
			 " vous disposez de ", Balance, "pts"])}];
	{"",_} ->
	    [{pcdata, lists:append(
			["Au ", Balance_date,
			 " vous disposez de ", Balance, "pts dont ",
			 PointsCB,"pts carte Steel"])}];
	{_,""}->
	    Expiry_date = lists:sublist(Full_expiry_date, 5),
	    [{pcdata, lists:append(
			["Au ", Balance_date,
			 " vous disposez de ", Balance, 
			 "pts avec ", Expiring, 
			 " valables jusqu'au ", Expiry_date])}];
	_ ->
	    Expiry_date = lists:sublist(Full_expiry_date, 5),
	    [{pcdata, lists:append(
			["Au ", Balance_date,
			 " vous disposez de ", Balance, 
			 "pts avec ", Expiring, 
			 " valables jusqu'au ", Expiry_date,
			 " dont ", PointsCB,"pts carte Steel"])}]
    end;

catalogue_header(_, _) ->
    [].

catalogue(Subscription, Page, Session_data, Naming_fun) ->
    {value, {recompenses, Presents}} =
	lists:keysearch(recompenses, 1, Session_data),
    {Selection, Has_next_page} =
	select_presents_for_page(Page, Presents,
				 catalogue_first_page_presents(Session_data), 
				 ?catalogue_next_page_presents),

    catalogue_aux(
      Selection,
      [],
      catalogue_header(Session_data, Page),
      Naming_fun,
      Subscription,
      Page,
      Has_next_page).

catalogue_aux([], [], [Header_item], _, _, _, _) ->
    {ok, [Header_item, br,
	  {pcdata,
	   "Ce nombre de points ne vous permet pas encore"
	   " de choisir un cadeau"}]};

catalogue_aux([{Id, Price, Delay, Type, Usage} | Presents], Acc, Header, Naming_fun, Subscription, Page,
	      Has_next_page) ->
    case Naming_fun(Subscription,Id) of
	{ok, Naming} ->
	    Href = "erl://"?MODULE_STRING":select_present?"++Id++"&"++
		httputil:esc_get_post(Naming)++"&"++Price++"&"++Delay++"&"++Usage,
	    Text = text(Naming, Price, Usage),
	    Item = #hlink{href=Href, contents=[{pcdata, Text}]},
	    catalogue_aux(
	      Presents,
	      [Item | Acc],
	      Header,
	      Naming_fun,
	      Subscription,
	      Page,
	      Has_next_page);
	error ->
	    error
    end;

catalogue_aux([], Acc, Header,  _, Subscription, Page, Has_next_page) ->
    Next_link = next_link(Page, Has_next_page),
    Usage =
	[#hlink{href="m5.xml#choix_par_usages",
	       contents=[{pcdata, "Choix par usage"}]}],
    More_info = more_info(Subscription,Page),
    All_lines_rev = lists:append(
		      [More_info,
		       Usage,
		       Next_link,
		       Acc,
		       Header]),
    All_lines = lists:reverse(All_lines_rev),
    {ok, svc_util_of:br_separate(All_lines)}.

catalogue_first_page_presents(M5_data)->
    {value, {echeance, Expiring, Full_expiry_date}}=
	lists:keysearch(echeance, 1,M5_data),
    {value, {solde, Balance, PointsCB, Full_balance_date}}=
	lists:keysearch(solde, 1,M5_data),
    case {Full_expiry_date,PointsCB} of
	{"",""}->
	    ?catalogue_first_page_presents_default;
	_ ->
	    1
	end.
	    
present(Subscription, Page, Session_data, Naming_fun, TU) ->
    {value, {recompenses, Presents}} =
	lists:keysearch(recompenses, 1, Session_data),
    {Selection, Has_next_page} = 
	select_presents_for_page(Page, Presents,
				 ?first_page_presents_by_tu,
				 ?next_page_presents_by_tu),
    present_aux(
      Selection,
      [],
      Naming_fun,
      Subscription,
      Page,
      Has_next_page,
      TU).

present(Subscription, Page, Session_data, Naming_fun, TU, Present_names) ->
    {value, {recompenses, Presents}} =
	lists:keysearch(recompenses, 1, Session_data),
    Presents_by_name = select_presents_by_name(Presents,Subscription,Present_names),
    {Selection, Has_next_page} = 
	select_presents_for_page(Page, Presents_by_name,
				 ?first_page_presents_by_tu,
				 ?next_page_presents_by_tu),
    present_aux(
      Selection,
      [],
      Naming_fun,
      Subscription,
      Page,
      Has_next_page,
      TU).

present_aux([], [], _, _, _, _, _) ->
    {ok, [{pcdata, "Votre nombre de points ne vous permet pas encore"
	   " de choisir un cadeau dans cette categorie."}]};

present_aux([{Id, Price, Delay, Type, Usage} | Presents], Acc, Naming_fun, Subscription, Page,
	    Has_next_page, TU) ->
    case Naming_fun(Subscription,Id) of
	{ok, Naming} ->
	    Href = "erl://"?MODULE_STRING":select_present?"++Id++"&"++
		httputil:esc_get_post(Naming)++"&"++Price++"&"++Delay++"&"++Usage,
	    Text = text(Naming, Price, Usage),
	    Item = #hlink{href=Href, contents=[{pcdata, Text}]},
	    present_aux(
	      Presents,
	      [Item | Acc],
	      Naming_fun,
	      Subscription,
	      Page,
	      Has_next_page,
	      TU);
	error ->
	    error
    end;

present_aux([], Acc,  _, Subscription, Page, Has_next_page, TU) ->
    Next_link = next_link_presents(Page, Has_next_page, TU),
    All_lines_rev = lists:append([Next_link, Acc]),
    All_lines = lists:reverse(All_lines_rev),
    {ok, svc_util_of:br_separate(All_lines)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

next_link(Page, true) ->
    Page_string = integer_to_list(Page + 1),
    Href = "erl://svc_m5_orangef:catalogue_page?" ++ Page_string,
    [#hlink{href=Href, contents=[{pcdata, "Suite"}]}];
next_link(_, false) ->
    [].

next_link_presents(Page, true, TU) ->
    Page_string = integer_to_list(Page + 1),
    Href = "erl://svc_m5_orangef:present_page?" ++ Page_string ++ "&" ++ TU,
    [#hlink{href=Href, contents=[{pcdata, "Suite"}]}];
next_link_presents(_, false, _) ->
    [].

more_info(Subscription,1) ->
    [#hlink{href="m5.xml#plus_infos", contents=[{pcdata, "+d'infos"}]}];
more_info(_,_) ->
    [].

present_naming(Subscription,Id) ->
    Namings = pbutil:get_env(pservices_orangef, m5_present_names),
    case lists:keysearch(Id, 1, Namings) of
	{value, {Id, _, Naming}} ->
	    {ok, Naming};
	_ ->
	    slog:event(failure, ?MODULE, {absence_nom_pour_cadeau, Subscription, Id}),
	    error
    end.

present_internal_id(Id) ->
    Conf = pbutil:get_env(pservices_orangef, m5_present_names),
    case lists:keysearch(Id, 1, Conf) of
	{value, {Id, Internal_id, _}} ->
	    {ok, Internal_id};
	_ ->
	    error
    end.

present_description(external_id,Id) ->
    case present_internal_id(Id) of
	{ok, Internal_id} ->
	    present_description(internal_id, list_to_integer(Internal_id));
	error ->
	    present_description(internal_id, no_offer)
    end;

present_description(internal_id, 1)->
    {[{pcdata,
      "Valable 7j/7 en France metropolitaine, hors supplement"
      " des services SMS/MMS."
      " Validite = 30j sans report"}], none};
present_description(internal_id, 2)->
    {[{pcdata,
      "Valable 7j/7 en France metropolitaine, hors supplement"
      " des services SMS/MMS."
      " Validite = 30j sans report"}], none};  
present_description(internal_id, 3)->
    {[{pcdata,
      "Valable 7j/7 en France metro, hors No speciaux, wap et web."
      " Appels vers fixe et mobile Orange decomptes a la sec des la 1re sec."}],
     [{pcdata, " Validite = 30j sans report."}]};
present_description(internal_id, 4)->
    {[{pcdata,
      "WE illimite vers fixe et mobile Orange. Valable"
      " du vend minuit au dim minuit, en France metro,"
      " hors No speciaux, wap et web."}], [{pcdata, "Usage personnel + non lucratif"}]};
present_description(internal_id, 5)->
    {[{pcdata,
      "Valable 7j/7 en France metro,hors no speciaux,wap et web.Appels vers fixe et mobile decomptes a la sec des la 1re sec.Validite = 30j sans report."
      }], none};
present_description(internal_id, 6) ->
    {[{pcdata,
      "Valable 7j/7 en France metro, hors No speciaux, wap et web."
      " Appels vers fixe et mobile Orange decomptes a la sec des la 1re sec."}],
     [{pcdata,
      "Validite = 30j sans report."}]};
present_description(internal_id, 7) ->
    {[{pcdata,
      "WE illimite vers fixe et mobile.Valable du vend minuit au dim minuit,en France metro,hors no spéciaux, wap et web.Usage personnel + non lucratif"
      }], none};
present_description(internal_id, 8) ->
    {[{pcdata,
      "Valable 7j/7,international ttes zones, hors No speciaux, wap et web."
      " Appels decomptes a la sec au-dela de la 1ere min indivisible."}],
     [{pcdata, "Validite = 30j sans report"}]};
present_description(internal_id, 9) ->
    {[{pcdata,
      "Valable 7j/7 depuis zone Europe vers France ou pays visite,"
      " hors No speciaux."
      " Appels decomptes a la sec au-dela de la 1ere min indivisible."}],
     [{pcdata,
      "Validite = 30j sans report"}]};
present_description(internal_id, 10) ->
    {[{pcdata,
      "Valable 7j/7 en France metro,hors no speciaux,wap et web.Appels vers fixe et mobile decomptes a la sec des la 1re sec.Validite = 30j sans report."
      }], none};
present_description(internal_id, 16) ->
    {[{pcdata,  
      "Votre compte points changer de mobile sera credite de 500 pts. "
      "Conditions du programme sur orange.fr > espace client"}], none}; 
present_description(internal_id, 17) ->
    {[{pcdata,  
      "Soiree ill vers fixe et mob Orange. Valable de 21h a 00h en France metro, hors no speciaux et no en portabilite. 3h max/appel."}], 
     [{pcdata,
      "Usage perso+non lucratif"}]};
present_description(internal_id, 18) ->
    {[{pcdata,  
      "Valable dans la limite de 100 SMS / 33 MMS photo (hors SMS/MMS surtaxes) vers les mobiles en France metropolitaine"}], none};
present_description(internal_id, 20) ->
    {[{pcdata, 
      "Votre compte davantage sera credite de 7000pts et votre compte changer de mobile sera debite de 500pts. Conditions du prog"}], 
     [{pcdata,
      "sur orange.fr >espace client"}]};
present_description(internal_id, 23) ->
    {[{pcdata,
      "Acces illimite a 60 chaines TV + videos sur Orange World. Valable 10 jours en France metro"}],
     [{pcdata, 
      "hors forfait Orange pour Iphone et sous reserve mobile compatible. Voir detail sur orange.fr"}]};
present_description(internal_id, 24)->
    {[{pcdata,
      "Valable 7j/7 en France metropolitaine, hors supplement"
      " des services SMS/MMS."
      " Validite = 30j sans report"}], none};
present_description(internal_id, 26)->
    {[{pcdata,
      "Consultez et envoyez vos mails avec piece jointe en illimite sur votre mobile 24h/24 et 7j/7."
      " Valable 10 jours en France metro"}],
     [{pcdata,
      " hors forfait Orange pour Iphone et sous reserve mobile compatible. Voir detail sur orange.fr"}]};
present_description(internal_id, 27)->
    {[{pcdata,
      "Acces illimite a Internet et a la navigation sur Orange World."
      " Valable 10 jours en France metro"}],
     [{pcdata,
      " hors forfait Orange pour Iphone et sous reserve mobile compatible. Voir detail sur orange.fr"}]};
present_description(internal_id, 28)->
    {[{pcdata,
      "Envoyez en illimite depuis votre mobile des messages instantanes a vos contacts MSN/Windows Live Messenger."
       " Valable 1 mois en France metro"}], none};
present_description(internal_id, 43)->
    {[{pcdata,
      "Acces : 8 matches en direct Ligue1 Orange + chaines Orange Sport en illimite. Valable 10 jours en France metro"}],
     [{pcdata,
      "sous reserve mobile compatible. Voir detail sur orange.fr"}]};
present_description(internal_id, 45)->
    {[{pcdata,
      "Acces illimite a 60 chaines TV + videos sur Orange World. Valable 10 jours en France metro"}],
     [{pcdata,
      "hors forfait Orange pour Iphone et sous reserve mobile compatible. Voir detail sur orange.fr. "
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 46)->
    {[{pcdata,
      "Consultez et envoyez vos mails avec piece jointe en illimite sur votre mobile 24h/24 et 7j/7. Valable 10 jours en France metro"}],
     [{pcdata,
      "hors forfait Orange pour Iphone et sous reserve mobile compatible. Voir detail sur orange.fr. "
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 47)->
    {[{pcdata,
      "Acces illimite a Internet et a la navigation sur Orange World. Valable 10 jours en France metro hors forfait Orange pour Iphone "}],
     [{pcdata,
      "et sous reserve mobile compatible. Voir detail sur orange.fr. "
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 48)->
    {[{pcdata,
      "Envoyez en illimite depuis votre mobile des messages instantanes a vos contacts MSN/Windows Live Messenger."}],
     [{pcdata,
      "Valable 1 mois en France metropolitaine. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 49)->
    {[{pcdata,
      "Valable 7j/7 en France metropolitaine, hors supplement des services SMS/MMS. Validite = 30j sans report."}],
     [{pcdata,
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 50)->
    {[{pcdata,
      "Valable 7j/7 en France metropolitaine, hors supplement des services SMS/MMS. Validite = 30j sans report."}],
     [{pcdata,
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 51)->
    {[{pcdata,
      "Valable 7j/7 en France metropolitaine, hors supplement des services SMS/MMS. Validite = 30j sans report."}],
     [{pcdata,
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 52)->
    {[{pcdata,
      "Valable dans la limite de 100 SMS / 33 MMS photo (hors SMS/MMS surtaxes) vers les mobiles en France metropolitaine"}],
     [{pcdata,
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 53)->
    {[{pcdata,
      "Valable 7j/7 en France metro, hors no speciaux, wap et web. Appels vers fixe et mobile Orange decomptes a la sec des la 1re sec."}],
     [{pcdata,
      "Validite = 30j sans report. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 54)->
    {[{pcdata,
      "WE illimite vers fixe et mobile Orange. Valable du vend minuit au dim minuit, en France metro, hors no speciaux, wap et web."}],
     [{pcdata,
      "Usage personnel + non lucratif, " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 55)->
    {[{pcdata,
      "Valable 7j/7 en France metro, hors no speciaux, wap et web. Appels vers fixe et mobile decomptes a la sec des la 1re sec."}],
     [{pcdata,
      "Validite = 30j sans report. "
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 56)->
    {[{pcdata,
      "Valable 7j/7 en France metro, hors no speciaux, wap et web. Appels vers fixe et mobile Orange decomptes a la sec des la 1re sec."}],
     [{pcdata,
      "Validite = 30j sans report. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 57)->
    {[{pcdata,
      "WE illimite vers fixe et mobile. Valable du vend minuit au dim minuit, en France metro, hors no speciaux, wap et web."}],
     [{pcdata,
      "Usage personnel + non lucratif, " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 58)->
    {[{pcdata,
      "Valable 7j/7 en France metro, hors no speciaux, wap et web. Appels vers fixe et mobile decomptes a la sec des la 1re sec. "}],
     [{pcdata,
      "Validite = 30j sans report. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 59)->
    {[{pcdata,
      "Soiree ill vers fixe et mob Orange. Valable de 21h a 00h en France metro, hors no speciaux et no en portabilite. 3h max/appel."}],
     [{pcdata,
      "Usage personnel + non lucratif, "
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 60)->
    {[{pcdata,
      "Acces : 8 matches en direct Ligue1 Orange + chaines Orange Sport en ill. Valable 10 jours en France metro"}],
     [{pcdata,
      "sous reserve mobile compatible. Voir detail sur orange.fr. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 62)->
    {[{pcdata,
      "Valable 7j/7, international ttes zones, hors no speciaux, wap et web. Appels decomptes a la sec au-dela de la 1ere min indivisible."}],
     [{pcdata,
      "Validite = 30j sans report. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, 63)->
    {[{pcdata,
      "Valable 7j/7 depuis zone Europe vers France ou pays visite, hors no speciaux. Appels decomptes a la sec au-dela 1ere min indivisible."}],
     [{pcdata,
      "Validite = 30j sans report. " 
      "Promotion valable du 10 juin au 18 aout 2010"}]};
present_description(internal_id, no_offer) ->
    {[{pcdata, ""}], none}.

confirm_message("CP",_,Present,Price)->
    Msg = "Vous avez commande "++Present++" avec "++Price++" pts changer de mobile. Votre cadeau sera active des reception du sms",
    [{pcdata, lists:append([Msg])}];
confirm_message(_,?ACTIVATION_NOW,Present,Price) ->
    Msg = "Vous avez commande "++Present++" avec "++Price++" pts. Votre cadeau sera active des reception du sms",
    [{pcdata, lists:append([Msg])}]; 
confirm_message(Usage,Delay,Present,Price) ->
    case svc_util_of:is_format_date_DD_MM_YYYY(Delay) of
	true -> 
	    confirm_message(Usage,date,Present,Price,Delay);
	false ->
	    confirm_message(Usage,time,Present,Price,Delay)
    end.
confirm_message(_,time,Present,Price,Delay) ->
    Msg = "Vous avez commande "++Present++" avec "++Price++" pts. Votre cadeau sera active dans "++Delay++" heures.",
    [{pcdata, lists:append([Msg])}];
confirm_message(_,date,Present,Price,Delay) ->
    Msg="Vous avez commande "++Present++" avec "++Price++" pts. Votre cadeau sera active le "++lists:sublist(Delay, 5) ++" 00h00 pour une duree de 48h.",
    [{pcdata, lists:append([Msg])}].



validate_message(Solde)->
    Msg="Votre commande a bien ete prise en compte. Un sms vous confirmera l'activation de votre cadeau. "
	"Votre nouveau solde est de ",
    [{pcdata, lists:append([Msg, Solde, " pts."])}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% OPAL requests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

consult_account(#session{prof=#profile{msisdn=Msisdn,subscription=Subscription}}=Session) ->
    case opal:consult_account(opal:dossier(Msisdn)) of
	{consulterSoldeReponse, M5_data} ->
	    case lists:keysearch(codeRet, 1, M5_data) of
		{value,{codeRet,"0"}} ->
		    {ok, lists:keydelete(codeRet, 1, M5_data)};
		Code ->
		    slog:event(failure, ?MODULE, {consultation_solde, Subscription, Code}),
		    {error, undefined}
	    end;
	Error ->
	    log_event(Error, consultation_solde, Subscription, Msisdn),
	    {error, undefined}
    end.

consult_catalogue(#session{prof=#profile{msisdn=Msisdn,subscription=Subscription}}=Session) ->
    Catalogue = opal:consult_catalogue(opal:dossier(Msisdn)),
    compute_catalogue(Catalogue, Msisdn, Subscription).

consult_catalogue(#session{prof=#profile{msisdn=Msisdn,subscription=Subscription}}=Session, TU) ->
    Catalogue = opal:consult_catalogue_with_TU(opal:dossier(Msisdn), TU),
    compute_catalogue(Catalogue, Msisdn, Subscription).

compute_catalogue(Catalogue, Msisdn, Subscription) ->
    case Catalogue of
	{getConsultationCadeauxReponse, Initial_data} ->
	    case lists:keysearch(codeRet, 1, Initial_data) of
		{value,{codeRet,"0"}} ->
		    {value, {recompenses, Presents}} =
			lists:keysearch(recompenses, 1, Initial_data),
		    Sort = fun({X,Y,Z,_,_}, {A,B,C,_,_}) ->
				   list_to_integer(Y) <list_to_integer(B)
			   end,
		    Sorted_by_decreasing_price = lists:reverse(lists:sort(Sort, Presents)),
		    M5_data =
			lists:keyreplace(recompenses, 1, Initial_data,
					 {recompenses,
					  Sorted_by_decreasing_price}),
		    {ok, lists:keydelete(codeRet, 1, M5_data)};
		Code ->
		    slog:event(failure, ?MODULE, {consultation_cadeau, Subscription, Code}),
		    {error, undefined}
	    end;
	Error ->
	    log_event(Error, consultation_cadeaux, Subscription, Msisdn),
	    {error, undefined}
    end.

activate_present(#session{prof=#profile{msisdn=Msisdn,subscription=Subscription}}=Session, Present_id, Price) ->
    Reponse = opal:activate_present(opal:dossier(Msisdn), Present_id, Price),
    read_activationPrime(Reponse,Subscription, Msisdn).

read_activationPrime(Reponse, Subscription, Msisdn) ->
    case Reponse of 
	{getActivationPrimeReponse, M5_data} ->
	    case lists:keysearch(codeRet, 1, M5_data) of
		{value,{codeRet,"0"}} ->
		    {value, {solde, Solde}} = 
			lists:keysearch(solde, 1, M5_data),
		    {ok, Solde};
		Code ->
		    slog:event(failure, ?MODULE, activation_prime, Subscription, Code),
		    {error, 0}
	    end;
	"308" ->
	    {not_enough_credit, 0};
	"401" ->
	    {mobile_pbm, 0};
	"402" ->
	    {mobile_pbm, 0};
	"403" ->
	    {high_credit, 0};
	Error when Error=="404";Error=="405";Error=="406" ->
	    {error_PCM_points, 0};
	Error ->
	    log_event(Error, activation_prime, Subscription, Msisdn),
	    {error, 0}
    end.

%% +type log_event(Err::term(),Request::atom(),
%%                 Subscription::atom(),Id::string()) ->
%%                 erlpage_result().
log_event(Err, Request, Subscription, Id) ->
    case Err of
	{_, _, HttpCode, Error, _, _} ->
	    slog:event(failure, ?MODULE, {Request, Subscription}, {Id, HttpCode, Error});
	_ ->
	    slog:event(failure, ?MODULE, {Request, Subscription}, Err)
    end.

%% +type print_usage(session(), arg(), fmt()) -> erlinclude_result().
print_usage(#session{prof=#profile{subscription=Subscription}}=Session,UsageToDisplay,Tag,Scripts)->
    Data = variable:get_value(Session, {?MODULE, m5_presents}),
    {value, {type_usage, Usages}} = lists:keysearch(type_usage, 1, Data), 
    case lists:member(UsageToDisplay, Usages) of
	true -> [#hlink{href="m5.xml"++Tag,contents=[{pcdata,Scripts}]}, br];
	_ -> []
    end.

text(Naming, Price, "CP")->
    Naming;
text(Naming, Price, Usage)->
    Naming ++ " =" ++ Price ++ "pts".

select_presents_by_name([], _,_) -> [];
select_presents_by_name([H|T], Subscription, Presents_name) ->
    Names = string:tokens(Presents_name,","),
    {PresentId,_,_,_,_} = H,
    case present_naming(Subscription, PresentId) of
	{ok, X} ->
	    case lists:any(fun (Name) ->  Name == X end, Names) of
		true ->
		    [H]++select_presents_by_name(T, Subscription, Presents_name);	    
		_ ->
		    select_presents_by_name(T, Subscription, Presents_name)
	    end;
	_ ->
	    select_presents_by_name(T, Subscription, Presents_name)
    end.
    
    
