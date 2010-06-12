%%% WAP PUSH experiment (July/August 2006).
%%% Offer a selection of WAP services, whose URL gets sent by Wap Push or
%%% clickable SMS to the user's terminal (according to its capability).
%%% Details vary according to subscription family (ZAP, M6 or other CMO).
-module(svc_wap_push_orangef).

%% Included from selfcare_cmo.xml
-export([main_menu_item/1, wap_menu/1]).

%% Linked to by pages returned by functions in this module.
-export([service/2, cost/2, send/2]).

%% Unit tested.
-export([wap_menu_list/1, subscription_family/1, auto_link/3, format_lines/1]).

-include("../include/ftmtlv.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pgsm/include/sms.hrl").

%% +deftype family() =  cmo | m6 | zap.
%% +deftype service() = logo | sport | chat | jeux | funtones | repondeurs |
%%                      actualite | horoscope | blog.
%% +deftype roaming_network() = noroaming | camel | ansi | nocamel | ming.
%% +deftype capability() = wap_push | clickable_sms | unknown.
%%% ----------------------------------------------------------------------------
%%% Service API: included from XML files
%%% ----------------------------------------------------------------------------

%% +type main_menu_item(session()) -> hlink().
%%%% The link, included in the main menu, to the wap push menu.
main_menu_item(abs) ->
    [#hlink{href="#wap_push", contents=[{pcdata, "wap_push"}]},br];

main_menu_item(Session) ->
    Family = subscription_family(Session),
    Tac = tac(Session),
    Launched = is_commercially_launched(Family),
    main_menu_item(Session, Family, Tac, Launched).

%% +type wap_menu(session()) -> contents().
%%%% The wap push menu: a selection of WAP services
wap_menu(abs) ->
    [{pcdata, "wap_push"}];
wap_menu(#session{}=Session) ->
    Family = subscription_family(Session),
    Network = roaming_network(Session),
    wap_menu_aux(Family, Network).

%%% ----------------------------------------------------------------------------
%%% Service API: (self)-linked to by stuff returned by this module
%%% ----------------------------------------------------------------------------

%% +type service(session(), Service_url::string()) -> erlpage_result().
%%%% A specific WAP service, chosen from the wap menu.
%%%% Page items depend on subscription family and terminal capability.
service(Session, Service_url) ->
    Family = subscription_family(Session),
    Service = list_to_atom(Service_url),
    Capability = capability(Session),
    {page, Session, #page{items=service(Service, Family, Capability)}}.

%% +type send(session(), Service_url::string()) -> erlpage_result().
%%%% Actually sends the WAP Push or clickable SMS, then returns a page
%%%% informing of outcome.
send(#session{prof=#profile{msisdn=Msisdn}}=Session, Service_string) ->
    Service = list_to_atom(Service_string),
    Family = subscription_family(Session),
    Url = wap_url(Service, Family),
    Capability = capability(Session),
    Sms_list = sms(Capability, Msisdn, Url, message()),
    Result = send(Sms_list),
    log_send(Service, Family, Capability, Result),
    send_result_page(Session, Service, Family, Result).

%% +type cost(session(), Service_url::string()) -> erlpage_result().
%%%% Page informing user of the cost of using a WAP service.
cost(#session{}=Session, Service_url) ->
    Service = list_to_atom(Service_url),
    Family = subscription_family(Session),
    Items = format_lines(cost_lines(Service, Family)),
    {page, Session,
     #page{items=Items}}.

%%% ----------------------------------------------------------------------------
%%% Sub-functions
%%% ----------------------------------------------------------------------------

%% +type main_menu_item(session(), family(), default|string(),
%%           Launched::bool()) -> contents().
main_menu_item(_, _, _, false) ->
    [];
main_menu_item(#session{prof=#profile{uid=Uid, msisdn=Msisdn, imsi=Imsi, imei=Imei}}, Family, default, _) ->
    slog:event(failure, ?MODULE, {rdp_error, Family}, {Uid,Msisdn,Imsi,Imei}),
    [];
main_menu_item(_, Family, Tac, _) when is_list(Tac) ->
    [#hlink{href="#wap_push", contents=[portal_name_term(Family, main)]}, br].

%% +type portal_name_term(family(), atom()) -> contents().
portal_name_term(Family, Context) ->
    {pcdata, portal_name(Family, Context)}.

%% +type portal_name(family(), atom()) -> string().
%%%% The name of the WAP portal: depends on the subscription, and on the context
%%%% (i.e. where within the service the name appears).
portal_name(zap, horoscope)    -> "Astro sur ZapZone";
portal_name(_, horoscope)      -> "Horoscope sur Orange World";
portal_name(cmo, _)            -> "Orange World";
portal_name(m6, main)          -> "Club M6 mobile";
portal_name(m6, incompatible)  -> "M6 mobile";
portal_name(m6, Other)         -> portal_name(cmo, Other);
portal_name(zap, main)         -> "Zap Zone";
portal_name(zap, incompatible) -> "ZAP Zone";
portal_name(zap, _)            -> "ZapZone".

%% +type wap_menu_aux(family(), roaming_network()) -> contents().
%%%% Wap menu is only provided when not roaming.
wap_menu_aux(Family, noroaming) ->
    slog:event(count, ?MODULE, {wap_push_menu, Family}),
    wap_menu_aux(Family);
wap_menu_aux(_, Roaming) ->
    [{pcdata, "Ce service n'est pas disponible a l'etranger. Merci"}].

%% +type wap_menu_aux(family()) -> contents().
wap_menu_aux(m6) ->
    [{pcdata, greeting("M6 Mobile by Orange")} |
     menu(m6, wap_menu_list(m6))];
wap_menu_aux(cmo) ->
    [{pcdata, greeting("Orange World")} |
     menu(cmo, wap_menu_list(cmo))];
wap_menu_aux(zap) ->
    [{pcdata, greeting("Zap Zone")} |
     menu(zap, wap_menu_list(zap))].

%% +type subscription_family(session()|integer()) -> family().
subscription_family(#session{}=Session) ->
    State = svc_util_of:get_user_state(Session),
    subscription_family(State#sdp_user_state.declinaison);
subscription_family(?m6_cmo)  -> m6;
subscription_family(?m6_cmo2) -> m6;
subscription_family(?m6_cmo3) -> m6;
subscription_family(?m6_cmo4) -> m6;
subscription_family(?zap_cmo) -> zap;
subscription_family(?ppol2)   -> zap;
subscription_family(_)        -> cmo.

%% +type roaming_network(session()) -> roaming_network().
%%%% Extracts the roaming network from session.
roaming_network(#session{location=Location}) ->
    {value, {roaming_network, Network}} =
	lists:keysearch(roaming_network, 1, Location),
    Network.

%% +type tac(session()) -> string() | default.
%%%% Extracts the TAC from the IMEI from the session.
tac(#session{prof=#profile{imei=Imei}}) when is_list(Imei), length(Imei) > 8 ->
    lists:sublist(Imei, 8);
tac(#session{prof=#profile{imsi=Imsi}}) ->
    batch_reset_imei:add(Imsi,subscribe),
    default.

%% +type capability(session()) -> capability().
%%%% Extracts the terminal's Wap Push capability() from the session().
capability(Session) ->
    Tac = tac(Session),
    wap_push_capability:tac(Tac).

%% +type service(service(), family(), capability()) -> contents().    
service(Service, Family, unknown) ->
    slog:event(count, ?MODULE, {incompatible_terminal, Family}),
    [{pcdata, "Pour profiter de ce service, connectez vous au portail "},
     portal_name_term(Family, incompatible),
     {pcdata, " a partir du menu de votre telephone"}];
service(Service, Family, _) ->
    slog:event(count, ?MODULE, {wap_push_service, Family, Service}),
    lists:append(
      description(Service, Family, portal_name_term(Family, Service)),
      [br,
       auto_link(send, Service, "Confirmer"),
       br,
       auto_link(cost, Service, "Tarif en vigueur")]).

%% +type wap_menu_list(family()) -> [service()].
%%%% The list of services, in the order they appear in the menu offered to
%%%% each subscription family.
wap_menu_list(m6) ->
    [logo, sport, chat, jeux, funtones, repondeurs, actualite, horoscope];
wap_menu_list(cmo) ->
    [logo, sport, actualite, chat, horoscope, jeux, funtones, repondeurs];
wap_menu_list(zap) ->
    [chat, blog, logo, sport, jeux, funtones, repondeurs, horoscope].

%% +type greeting(Custom_string::string()) -> string().
%%%% The greeting that appears above the Wap menu.
greeting(Custom_string) ->
    "Avec " ++ Custom_string ++
	", decouvrez un univers de services sur votre mobile !".

%% +type menu(family(), [service()]) -> contents().
menu(Family, List) ->
    {_, Menu} =
	lists:foldl(
	  fun(Item, {Index, Menu}) ->
		  Menu_item_text = menu_item(Item, Family),
		  Menu_item_term = auto_link(service, Item, Menu_item_text),
		  {Index - 1, [br, Menu_item_term | Menu]}
	  end,
	  {length(List), []},
	  lists:reverse(List)),
    Menu.

%% +type sending(service(), family()) -> string().
%%%% The actual text of the page displayed when sending the Wap Push.
sending(Service, Family) ->
    "Votre confirmation de connexion au service " ++
	service_string(Service, Family) ++
	" a bien ete prise en compte. Vous allez recevoir un SMS pour vous "
	"connecter au service choisi.".

%% +type service_string(service(), family()) -> string().
%%%% The actual string that appears as the name of the service that is going
%%%% to be pushed to your terminal. Mostly identical to menu_item.
service_string(logo, _)         -> "Sonnerie et Logo";
service_string(horoscope, zap)  -> menu_item(horoscope, cmo);
service_string(Service, Family) -> menu_item(Service, Family).

%% +type menu_item(service(), family()) -> string().
%%%% The actual string that appears as the menu item for each WAP service.
%%%% Sometimes varies according to subscription.
menu_item(logo, _)        -> "Sonneries&logo";
menu_item(sport, _)       -> "Sport";
menu_item(actualite, _)   -> "Actualite";
menu_item(chat, _)        -> "Chat";
menu_item(horoscope, zap) -> "Astro";
menu_item(horoscope, _)   -> "Horoscope";
menu_item(jeux, zap)      -> "Games";
menu_item(jeux, _)        -> "Jeux";
menu_item(funtones, _)    -> "Fun tones";
menu_item(repondeurs, _)  -> "Repondeurs";
menu_item(blog, zap)      -> "BlogZone".

%% +type auto_link(Function::atom(), Arg::atom(), Text::string()) -> hlink().
%%%% HLink to a function of this module which takes a single atom as an argument
%%%% (intended for a service()).
auto_link(Function, Arg, Text) ->
    Href = "erl://"?MODULE_STRING":"
	++ atom_to_list(Function)
	++ "?" ++ atom_to_list(Arg),
    #hlink{href=Href, contents=[{pcdata, Text}]}.

%% +type send_result_page(session(), service(), family(), Errors::[term()]) ->
%%          erlpage_result().
%%%% The page displaying the result of trying to send the WAP push.
send_result_page(Session, Service, Family, []) ->
    Sending_text = sending(Service, Family),
    {page, Session, #page{items=[{pcdata, Sending_text}]}};
send_result_page(Session, _, _, _) ->
    {redirect, Session, "#temporary"}.

%% +type log_send(service(), family(), capability(), Errors :: [term()]) ->
%%          term().
%%%% Logs the result of trying to send the Wap Push
log_send(Service, Family, Capability, []) ->
    slog:event(count, ?MODULE, {wap_push_sent, Family, Service, Capability});
log_send(Service, Family, Capability, Errors) ->
    slog:event(failure, ?MODULE,
	       {wap_push_send_failure, Family, Service, Capability}, Errors).

%% +type send([sms_insert()]) -> [Errors::term()].
send(Sms_list) ->
    Routing = pbutil:get_env(pservices_orangef, wap_push_routing),
    Results = [sms_router:insert(Sms, [Routing]) || Sms <- Sms_list],
    lists:filter(fun({ok,_}) -> false; (_) -> true end, Results).

%% +type sms(capability(), msisdn(), Url::string(), Message::string()) ->
%%           [sms_insert()].
sms(wap_push, Msisdn, Url, Message) ->
    sms_push:indication_sms(Msisdn, 1, Url, Message); 
sms(clickable_sms, Msisdn, Url, Message) ->
    sms_push:clickable_sms(Msisdn, 1, Url, Message, default_alphabet).

%% +type description(service(), family(), Portal::contents()) -> contents().
description(sport, _, Portal) ->
    [{pcdata, "Decouvrir le Sport sur "},
     Portal,
     {pcdata, " et suivre en direct les principales competitions de sport "
      "(L1, Top14, C1, R.Garros ...)."}];
description(logo, _, Portal) ->
    [{pcdata,
      "Toutes les nouveautes avec plus de 20 000 Sonneries & Logos"
      " classes par genres sur "},
     Portal,
     {pcdata, " !"}];
description(chat, zap, _) ->
    [{pcdata,
      "Venez chatter sur le chat ZapZone, "
      "c'est trop cool y a toujours des connectes!"}];
description(chat, _, _) ->
    [{pcdata,
      "Discuter avec plus d'un million d'inscrits au chat Orange "
      "sur les caneaux Love, Friends, Filles !"}];
description(jeux, _, _) ->
    [{pcdata,
      "Telechargez vos jeux preferes, denichez toutes les astuces "
      "consoles, decouvrez tous les cadeaux que vous pouvez "
      "gagner..."
      }];
description(funtones, _, _) ->
    [{pcdata,
      "Hits, humour, bruitage, avec Fun tones, ceux qui vous "
      "appellent vont entendre la tonalite de votre choix!"}];
description(blog, zap, _) ->
    [{pcdata,
      "Cree ton blog sur Zap Zone, c'est simple et ca prend moins de deux "
      "minutes ! En plus tu peux mater les blogs des autres membres"}];
description(repondeurs, _, _) ->
    [{pcdata,
      "Personnalisez l'annonce d'accueil de votre messagerie "
      "vocale 888 avec le service Repondeurs Orange."}];
description(actualite, _, _) ->
    [{pcdata,
      "Retrouvez toute l'actualite en continu dans le monde, en France "
      "et pres de chez vous avec l'actualite regionale !"}];
description(horoscope, _, Portal) ->
    [{pcdata, "Decouvrez l'"},
     Portal,
     {pcdata, ": SMS a l'acte (Astro,Tarot,Lucky Test...) ou Packs proposant "
      "un acces mensuel illimite!"}].

%% +type format_lines(Lines::[string()]) -> contents().
%%%% Formats a list of strings into {pcdata, ...} separated (but not terminated)
%%%% by a BR.
format_lines(Lines) ->
    Pcdata = [{pcdata, Line} || Line <- Lines],
    svc_util_of:br_separate(Pcdata, []).

%% +type cost_lines(service(), family()) -> [string()].
%%%% Lines of text giving cost of using a Wap service.
cost_lines(sport, _) ->
    ["Pour acceder aux contenus premium (commentaires, stats, photos,...) "
     "souscrivez au Direct Premium: 3 euros/mois ou 1euro/24h"];
cost_lines(logo, _) ->
    ["Prix par sonnerie polyphonique ou logo couleurs : 2E (*). "
     "Prix par sonnerie Hi-Fi : 3E (*).",
     "(*) Hors cout de connexion a Orange World."];
cost_lines(jeux, _) ->
    ["Prix TTC(*):de 3E a 7E pour les jeux telecharges",
     "2E pour Hot Paradisio et Columbo",
     "1E a 3E pour Astuces Jeux Video",
     "(*) Hors cout de connexion a Orange World"];
cost_lines(funtones, _) ->
    ["Achat de tonalite: 3E(*) valide de 6 mois. En cas "
     "d'inactivite durant 6 mois, le service sera desactive",
     "(*) Hors cout de connexion a Orange World"];
cost_lines(repondeurs, _) ->
    ["Prix d'un repondeur: 2E(*)",
     "(*) Hors cout de connexion a Orange World"];
cost_lines(horoscope, _) ->
    ["Prix (TTC) 0,5 EUR (*) pour les SMS a l'acte.",
     "Prix (TTC) 2 EUR (*) pour les Packs (acces mensuel illimite).",
     "(*) Hors cout de connexion a Orange World"];
cost_lines(_, zap) ->
    ["Cout de connexion au portail"];
cost_lines(_, _) ->
    ["Cout de connexion a Orange World."].

%% +type wap_url(service(), family()) -> string().
%%%% The actual WAP URL to be pushed to the terminal.
wap_url(Service, Family) ->
    orange_url(url_suffix(Service,Family)).

%% +type orange_url(string()) -> string().
%%%% Appends given service string to the base part of the Orange World WAP URL.
orange_url(Suffix) ->
    "http://www.orange.fr/0/accueil/Retour?SA=USSD" ++ Suffix.

%% +type url_suffix(service(), family()) -> string().
%%%% The variable suffix part of the  WAP URL parameter
url_suffix(blog, zap)    -> "BLOGZONEZAP";
url_suffix(chat, zap)    -> "CHATZAP";
url_suffix(Atom, zap)    -> url_suffix(Atom, cmo) ++ "ZAP";
url_suffix(chat, _)      -> "CHATOWLOC";
url_suffix(logo, _)      -> "SL";
url_suffix(actualite, _) -> "ACTU";
url_suffix(Atom, _)      -> string:to_upper(atom_to_list(Atom)).

%% +type message() -> string().
%%%% sequence of Unicode values for the text to be pushed.
message() ->
    "Cliquez pour vous connecter au site Orange World choisi.".

%% +type is_commercially_launched(family()) -> bool().
is_commercially_launched(Family) ->
    Dates = pbutil:get_env(pservices_orangef, commercial_date_wap_push),
    svc_util_of:is_commercially_launched(Dates, Family).
