-module(svc_limande).

%%XML API
-export([enabled_offers/1,do_subscription/2,offer_menu/2]).
-export([get_description/2,get_mentionsLegales/2,get_moreMentions/3]).
-export([confirm_subscription/2,redirect_by_code/2]).
-export([proposer_lien/4]).
-export([display_page/2]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pfront_orangef/include/limande.hrl").

info_ligne("cmo")->
    "CMO";
info_ligne("mobi")->
    "MOB";
info_ligne("postpaid") ->
    "FAPRO".

%% +type enabled_offers(session())->erlpage_result().
%%%% display links to offers enabled for the current user
enabled_offers(abs)->
    [{redirect,abs,"#0_offre"},
     {redirect,abs,"#error"},
     {redirect,abs,"#pb_tech"}];
enabled_offers(#session{prof=#profile{msisdn=MSISDN,subscription=Sub}}
	       =Session)->
    Dosclient=case variable:get_value(Session,{?MODULE,dossierClient}) of
		  not_found->[];
		  Dos-> Dos
	      end,
    case limande:getOffresSouscriptibles(?SENDER,info_ligne(Sub),MSISDN,Dosclient) of
	#offresSouscriptibles{doscli=DossierClient,listeOffre=ListeOffre}->
	    slog:event(count,?MODULE,{menu_offres_eXclusives,Sub}),
	    Session1=
		variable:update_value(Session,{?MODULE,offresSouscriptibles},
				      ListeOffre),
	    Session2=variable:update_value(Session1,{?MODULE,dossierClient},
					   DossierClient),
	    links_to_offers(Session2);
	FaultResp->
	    handle_fault(Session,FaultResp)
    end.

%% +type links_to_offers(Session)->erlpage_result().
links_to_offers(abs)->
    [{redirect,abs,"#0_offre"}];
links_to_offers(Session)->     
    case variable:get_value(Session,{?MODULE,offresSouscriptibles}) of
	[]->
	    {redirect,Session,"#0_offre"};
	ListeOffre->
	    Fun=fun(#offre{libelleOffre=Libelle,montantOffre=Montant,
			   idOffre=IDOffre},Acc)->
			Href_subscribe=
			    "erl://"?MODULE_STRING":offer_menu?"++
			    IDOffre,
			Acc++[#hlink{href=Href_subscribe,
				     contents=[{pcdata,Libelle}]}]
		end,	    
            Text=[{pcdata,"Choisissez une offre:"}],	    
	    Links=lists:foldl(Fun,[],ListeOffre),
	    Page=svc_util_of:br_separate(Text ++ Links),
	    Updated_session =variable:update_value(Session, {?MODULE, menu_page}, Page),
	    {redirect, Updated_session ,"#menu"}
%	    {page,Session,#page{items=svc_util_of:br_separate(Text ++ Links)}}
    end.

%% +type offer_menu(session(),string())->erlpage_result().
%%%% Display the subscription menu for an offer
offer_menu(#session{prof=#profile{subscription=Sub}}=Session,IDOffre)->
    slog:event(count,?MODULE,{acces_offre_eXclusive,Sub,IDOffre}),
%    #offre{libelleOffre=Libelle}=get_Offre(Session,IDOffre),
    case get_Offre(Session,IDOffre) of 
	#offre{libelleOffre=Libelle} ->
	    Text=[{pcdata,Libelle}],
	    Items=Text++make_link("Souscrire",IDOffre)++
		make_link("Description",IDOffre)++
		make_link("Mentions legales",IDOffre),
	    Page=svc_util_of:br_separate(Items),
	    Updated_session =variable:update_value(Session, {?MODULE, offer_page}, Page),
	    {redirect, Updated_session ,"#menu_offre"};
%	    {page,Session,#page{hist=donthist, items=svc_util_of:br_separate(Items)}};
	offer_not_found ->
	    {redirect,Session,"#pb_tech"}
    end.

%% +type get_description(session(),string())->erlpage_result().
%%%% get more details about the offer with ID IDOffre
get_description(Session,IDOffre)->
%%     #offre{idOffre=IDOffre}
%%  	=get_Offre(Session,IDOffre),
    case get_Offre(Session,IDOffre) of 
	#offre{idOffre=IDOffre} ->
	    case limande:getDescriptionOffre(?SENDER,IDOffre) of
		{_,Description}->
		    Text=[{pcdata,Description}],
		    Items=Text ++ make_link("Souscrire",IDOffre)++
			make_link("Mentions legales",IDOffre),	  
		    Page = svc_util_of:br_separate(Items),
		    Updated_session =variable:update_value(Session, {?MODULE, description_page}, Page),
		    {redirect, Updated_session ,"#description_offre"};
%		    {page,Session,#page{hist=donthist,items=svc_util_of:br_separate(Items)}};
		FaultResp->
		    handle_fault(Session,FaultResp)
	    end;
	_ ->
	    {redirect,Session,"#pb_tech"}
    end.

%% +type get_mentionsLegales(session(),string())->erlpage_result().
%%%% get legales informations about the offer with ID IDOffre
get_mentionsLegales(Session,IDOffre)->
%%     #offre{libelleOffre=Libelle,montantOffre=Montant,idOffre=IDOffre}
%%  	=get_Offre(Session,IDOffre),
    case get_Offre(Session,IDOffre) of 
	#offre{libelleOffre=Libelle,montantOffre=Montant,idOffre=IDOffre} ->
	    case limande:getMentionsLegalesOffre(?SENDER,IDOffre) of
		#mentionsLegalesOffre{ecran1=Ecran1,ecran2=VEcran}->
		    Text=[{pcdata,Ecran1}],
		    Links=
			case VEcran of
			    []->
				make_link("Souscrire",IDOffre)++
				    make_link("Description",IDOffre);
			    VEcran2->
				Esc_VEcran2=svc_util_of:esc_ampersand(VEcran2),
				Href="erl://"?MODULE_STRING":get_moreMentions?"
				    ++IDOffre++"&"++Esc_VEcran2, 
				[#hlink{href=Href,contents=[{pcdata,"Suite"}]}]
			end,
		    Items=Text ++ Links,
		    Page = svc_util_of:br_separate(Items),
		    Updated_session =variable:update_value(Session, {?MODULE, mentions_legales_page}, Page),
		    {redirect, Updated_session ,"#mentions_legales_offre"};
%		    {page,Session,#page{hist=donthist,items=svc_util_of:br_separate(Items)}};
		FaultResp->
		    handle_fault(Session,FaultResp)
	    end;
	_ ->
	    {redirect,Session,"#pb_tech"}
    end.

%% +type get_moreMentions(session(),string(),string())->erlpage_result().
%%%% get more legales information if any
get_moreMentions(Session,IDOffre,Ecran2)->
    Text=[{pcdata,Ecran2}],
    Items=Text ++ make_link("Souscrire",IDOffre)
	++make_link("Description",IDOffre),
    Page = svc_util_of:br_separate(Items),
    Updated_session =variable:update_value(Session, {?MODULE, mentions_legales_page_2}, Page),
    {redirect, Updated_session ,"#mentions_legales_offre_2"}.
%    {page,Session,#page{hist=donthist,items=svc_util_of:br_separate(Items)}}.

%% +type do_subscription(session(),string())->erlpage_result().
%%%% make a subscription request for a limande offer to limande server.
do_subscription(#session{prof=#profile{subscription=Sub}}=Session,IDOffre)->
    slog:event(count,?MODULE,{souscrire_offre_eXclusive,Sub,IDOffre}),
%%     #offre{libelleOffre=Libelle,montantOffre=Montant,idOffre=IDOffre}
%%  	=get_Offre(Session,IDOffre),
    case get_Offre(Session,IDOffre) of
	#offre{libelleOffre=Libelle,montantOffre=Montant,idOffre=IDOffre} ->
	    Montant2=list_to_integer(Montant),
	    Montant3=Montant2/1000,
	    Montant4=io_lib:format("~.2f",[Montant3]),
	    Text=[{pcdata,"Vous souhaitez souscrire a l'offre "++Libelle++
		   ".Votre compte sera debite de "++Montant4++
		   "EUR. Repondre 1 pour confirmer."}],
	    Href_confirm="erl://"?MODULE_STRING":confirm_subscription?"++IDOffre,
	    Link=[#hlink{href=Href_confirm,contents=[{pcdata,"Souscrire"}]}],
	    Items=Text++Link,
	    Page = svc_util_of:br_separate(Items),
	    Updated_session =variable:update_value(Session, {?MODULE, souscrire_page}, Page),
	    {redirect, Updated_session ,"#souscrire_offre"};
%	    {page,Session,#page{hist=donthist,items=svc_util_of:br_separate(Items)}};
	_ ->
	    {redirect,Session,"#pb_tech"}
    end.

%% +type confirm_subscription(session(),string())->erlpage_result().
confirm_subscription(abs,_)->
    [{redirect,abs,"#souscription_ok"}];
confirm_subscription(#session{prof=#profile{msisdn=MSISDN,subscription=Sub}}
		     =Session,IDOffre)->
    slog:event(count,?MODULE,{confirmer_souscr_offre_eXclusive,Sub,IDOffre}),
    DossierClient=variable:get_value(Session,{?MODULE,dossierClient}),
    case limande:doSouscriptionOffre(?SENDER,MSISDN,IDOffre,DossierClient) of
	{ok,ResultCode}->
	    slog:event(count,?MODULE,{souscription_offre_eXclusive_ok,
				      Sub,IDOffre}),
	    {redirect,Session,"#souscription_ok"};
	FaultResp->
	    slog:event(count,?MODULE,{souscription_offre_eXclusive_nok,
				      Sub,IDOffre}),
	    handle_fault(Session,FaultResp)
    end.

%% +type redirect_by_code(session(),integer())->erlpage_result().
redirect_by_code(abs,_)->
     [{redirect,abs,"#pb_tech"},
      {redirect,abs,"#solde_insuff"},
      {redirect,abs,"#limite_subscr"},
      {redirect,abs,"#offre_term"},
      {redirect,abs,"#offre_susp_quoti"},
      {redirect,abs,"#offre_susp_mensu"},
      {redirect,abs,"#offre_desact"},
      {redirect,abs,"#horaire_souscr_nok"},
      {redirect,abs,"#offre_souscr_nok"}];
redirect_by_code(Session,Links)->
    ErrCode=variable:get_value(Session,{?MODULE,error_code}),
    plugin:redirect_multi(Session,"equal",ErrCode,Links).
    
%% +type get_Offre(session(),string())->offre().    
get_Offre(#session{prof=#profile{msisdn=MSISDN}}=Session,IDOffre)->
    ListeOffre=variable:get_value(Session,{?MODULE,offresSouscriptibles}),
%    {value,Offre}=lists:keysearch(IDOffre,#offre.idOffre,ListeOffre),
    case lists:keysearch(IDOffre,#offre.idOffre,ListeOffre) of
	{value,Offre} ->
	    Offre;
	_ ->
	    slog:event(internal,?MODULE,{offer_not_found,IDOffre,ListeOffre,MSISDN}),
	    offer_not_found
    end.

%% make_link(string(),string())->link().
make_link(Title,IDOffre) when Title=="Souscrire"->
    Href_subscr="erl://"?MODULE_STRING":do_subscription?"++IDOffre,
    [#hlink{href=Href_subscr,contents=[{pcdata,Title}]}];
make_link(Title,IDOffre) when Title=="Mentions legales"->
    Href_mentions="erl://"?MODULE_STRING":get_mentionsLegales?"++IDOffre,
    [#hlink{href=Href_mentions,contents=[{pcdata,Title}]}];
make_link(Title,IDOffre) when Title=="Description"->
    Href_descr="erl://"?MODULE_STRING":get_description?"++IDOffre,
    [#hlink{href=Href_descr,contents=[{pcdata,Title}]}];
make_link(_,IDOffre)->
    [].

%% +deftype http_response() ={ok,V,Code, Result, H, Body}.
%% +type handle_fault(session(),http_response())->erlpage_result().
handle_fault(abs,_)->
    [{redirect,abs,"#error"},
     {redirect,abs,"#pb_tech"}];
handle_fault(Session,{ok,_,500,_,_,BodyResp})->
    case soaplight:decode_body(BodyResp,limande)of
	{limandeException,ErrMessage,ErrCode}->
	    slog:event(failure,?MODULE,limandeException,{ErrCode,ErrMessage}),
	    Session2=variable:update_value(Session,{?MODULE,error_code},ErrCode),
	    {redirect,Session2,"#error"};
	{invalidInputException,Message}->
	    slog:event(failure,?MODULE,invalidInputException,Message),
	    {redirect,Session,"#pb_tech"};
	Error->
	    slog:event(failure,?MODULE,limande_request_failed,Error),
	    {redirect,Session,"#pb_tech"}
    end;
handle_fault(Session,FaultResp)->
    slog:event(failure,?MODULE,limande_request_failed,FaultResp),
    {redirect,Session,"#pb_tech"}.
	    
proposer_lien(Session,PCD,Url,Br)->
    case svc_util_of:get_env(offres_eXclusives) of
	true->
	    Text=[{pcdata,"Les offres exclusives vous reservent "
		   "des surprises ! Profitez-en des maintenant !"}],
	    Text++svc_util_of:add_br("br")++[#hlink{href=Url,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(Br);
	_ ->[{pcdata,"Orange vous donne rendez vous tous les mardis matins sur le 444"
	      " (gratuit) pour decouvrir l'offre eXclusive de la semaine et profiter"
	      " d'offres a prix exceptionnels"}]++svc_util_of:add_br(Br)
    end.


%% +type display_page(session())->erlpage_result() 
display_page(abs,ValueName) ->
    [{redirect, abs, "Valeur dynamique"}];
display_page(Session,ValueName) ->
    case variable:get_value(Session, {?MODULE, list_to_atom(ValueName)}) of
	not_found ->
	    [{pcdata,""}];
	Page -> 
	    Page
    end.
