-module(svc_of_config_options_postpaid).
-compile(export_all).

-include("../include/postpaid.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pservices_orangef/include/messages_options_postpaid.hrl").
-include("../../pservices_orangef/include/subscr_asmetier.hrl").
-include("../include/ftmtlv.hrl").

-define(back,"-1").
select_list("opt_internet_max_gpro")->
    ?OPT_INTERNET_MAX_GPRO;
select_list("opt_internet_gpro")->
    ?OPT_INTERNET_GPRO;
select_list("opt_mail_MMS_gpro")->
    ?OPT_MAIL_MMS_GPRO;
select_list("opt_giga_mail_gpro")->
    ?OPT_GIGA_MAIL_GPRO;
select_list("opt_mail_gpro")->
    ?OPT_MAIL_GPRO;
select_list("opt_mes_donnees_gpro")->
    ?OPT_MES_DONNEES_GPRO;
select_list("opt_mail_blackberry_gpro")->
    ?OPT_MAIL_BLACKBERRY_GPRO;
select_list("opt_iphone_3g_gpro")->
    ?OPT_IPHONE_3G_GPRO;
select_list("opt_musique_collection_gpro")->
    ?OPT_MUSIQUE_COLLECTION_GPRO;
select_list("opt_musique_mix_gpro")->
    ?OPT_MUSIQUE_MIX_GPRO;
select_list("opt_tv_max_gpro")->
    ?OPT_TV_MAX_GPRO;
select_list("opt_tv_gpro")->
    ?OPT_TV_GPRO;
select_list("opt_orange_sport_gpro")->
    ?OPT_ORANGE_SPORT_GPRO;
select_list("opt_paris_gpro")->
    ?OPT_PARIS_GPRO;
select_list("opt_marseille_gpro")->
    ?OPT_MARSEILLE_GPRO;
select_list("opt_lyon_gpro")->
    ?OPT_LYON_GPRO;
select_list("opt_lens_gpro")->
    ?OPT_LENS_GPRO;
select_list("opt_saint_etienne_gpro")->
    ?OPT_SAINT_ETIENNE_GPRO;
select_list("opt_bordeaux_gpro")->
    ?OPT_BORDEAUX_GPRO;
select_list("opt_orange_maps_gpro")->
    ?OPT_ORANGE_MAPS_GPRO;
select_list("opt_30_sms_mms_gpro")->
    ?OPT_30_SMS_MMS_GPRO;
select_list("opt_80_sms_mms_gpro")->
    ?OPT_80_SMS_MMS_GPRO;
select_list("opt_130_sms_mms_gpro")->
    ?OPT_130_SMS_MMS_GPRO;
select_list("opt_sms_mms_ill_gpro")->
    ?OPT_SMS_MMS_ILL_GPRO;
select_list("opt_orange_messenger_gpro")->
    ?OPT_ORANGE_MESSENGER_GPRO;
select_list("opt_unik_tous_op_gpro")->
    ?OPT_UNIK_TOUS_OP_GPRO;
select_list("opt_10min_europe_gpro") ->
    ?OPT_10MIN_EUROPE_GPRO;
select_list("opt_pass_voyage_15min_europe_gpro") ->
    ?OPT_PASS_VOYAGE_15MIN_EUROPE_GPRO;
select_list("opt_pass_voyage_30min_europe_gpro") ->
    ?OPT_PASS_VOYAGE_30MIN_EUROPE_GPRO;
select_list("opt_pass_voyage_60min_europe_gpro") ->
    ?OPT_PASS_VOYAGE_60MIN_EUROPE_GPRO;
select_list("opt_pass_voyage_15min_maghreb_gpro") ->
    ?OPT_PASS_VOYAGE_15MIN_MAGHREB_GPRO;
select_list("opt_pass_voyage_30min_maghreb_gpro") ->
    ?OPT_PASS_VOYAGE_30MIN_MAGHREB_GPRO;
select_list("opt_pass_voyage_60min_maghreb_gpro") ->
    ?OPT_PASS_VOYAGE_60MIN_MAGHREB_GPRO;
select_list("opt_pass_voyage_15min_rdm_gpro") ->
    ?OPT_PASS_VOYAGE_15MIN_RDM_GPRO;
select_list("opt_pass_voyage_30min_rdm_gpro") ->
    ?OPT_PASS_VOYAGE_30MIN_RDM_GPRO;
select_list("opt_pass_voyage_60min_rdm_gpro") ->
    ?OPT_PASS_VOYAGE_60MIN_RDM_GPRO;
select_list("opt_destination_europe_v037_gpro")->
    ?OPT_DESTINATION_EUROPE_V037_GPRO;
select_list("opt_destination_europe_v038_gpro")->
    ?OPT_DESTINATION_EUROPE_V038_GPRO;
select_list("opt_suisse_v037_gpro")->
    ?OPT_SUISSE_V037_GPRO;
select_list("opt_suisse_v038_gpro")-> 
    ?OPT_SUISSE_V038_GPRO;
select_list("opt_espagne_v037_gpro")->
    ?OPT_ESPAGNE_V037_GPRO;
select_list("opt_espagne_v038_gpro")->
    ?OPT_ESPAGNE_V038_GPRO;
select_list("opt_belgique_v037_gpro")->
    ?OPT_BELGIQUE_V037_GPRO;
select_list("opt_belgique_v038_gpro")->
    ?OPT_BELGIQUE_V038_GPRO;
select_list("opt_italie_v037_gpro")->
    ?OPT_ITALIE_V037_GPRO;
select_list("opt_italie_v038_gpro")->
    ?OPT_ITALIE_V038_GPRO;
select_list("opt_portugal_v037_gpro")->
    ?OPT_PORTUGAL_V037_GPRO;
select_list("opt_portugal_v038_gpro")->
    ?OPT_PORTUGAL_V038_GPRO;
select_list("opt_royaume_uni_v037_gpro")->
    ?OPT_ROYAUME_UNI_V037_GPRO;
select_list("opt_royaume_uni_v038_gpro")->
    ?OPT_ROYAUME_UNI_V038_GPRO;
select_list("opt_allemagne_v037_gpro")->
    ?OPT_ALLEMAGNE_V037_GPRO;
select_list("opt_allemagne_v038_gpro")->
    ?OPT_ALLEMAGNE_V038_GPRO;
select_list("opt_luxembourg_v037_gpro")->
    ?OPT_LUXEMBOURG_V037_GPRO;
select_list("opt_luxembourg_v038_gpro")->
    ?OPT_LUXEMBOURG_V038_GPRO;
select_list("opt_dom_v037_gpro")->
    ?OPT_DOM_V037_GPRO;
select_list("opt_dom_v038_gpro")->
    ?OPT_DOM_V038_GPRO;
select_list("opt_maroc_v037_gpro")->
    ?OPT_MAROC_V037_GPRO;
select_list("opt_maroc_v038_gpro")->
    ?OPT_MAROC_V038_GPRO;
select_list("opt_algerie_v037_gpro")->
    ?OPT_ALGERIE_V037_GPRO;
select_list("opt_algerie_v038_gpro")->
    ?OPT_ALGERIE_V038_GPRO;
select_list("opt_tarif_jour_zone_europe_gpro")->
    ?OPT_TARIF_JOUR_ZONE_EUROPE_GPRO;
select_list("opt_pass_internet_int_jour_2E_gpro")->
    ?OPT_PASS_INTERNET_INT_JOUR_2E_GPRO;
select_list("opt_pass_internet_int_jour_5E_gpro")->
    ?OPT_PASS_INTERNET_INT_JOUR_5E_GPRO;
select_list("opt_pass_internet_int_5E_gpro")->
    ?OPT_PASS_INTERNET_INT_5E_GPRO;
select_list("opt_pass_internet_int_20E_gpro")->
    ?OPT_PASS_INTERNET_INT_20E_GPRO;
select_list("opt_pass_internet_int_35E_gpro")->
    ?OPT_PASS_INTERNET_INT_35E_GPRO;
select_list("opt_messagerie_gpro")->
    ?OPT_MESSAGERIE_GPRO;
select_list("infos_tarifs_default_gpro")->
    ?INFOS_TARIFS_DEFAULT_GPRO.
get_message(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin is dedicated to legal mentions display, concerning options\n"
      " a user can subscribe to.",
      type = function,
      license = [],
      args = []
     }
    );

get_message(abs)->                       
    [{pcdata,"Message dynamique options bons plans"}];

get_message(Session) ->
    svc_of_plugins:track_kenobi_code(Session, "bons_plans", postpaid),
    case {get_value(Session, "request_state"),
	  get_value(Session, "option"),
	  get_value(Session, "current_page")
	 }
	of
	{not_found,_,_}->
	    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","request_state"}});
	{_,not_found,_}->
	    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","option"}});
	{_,_,not_found}->
	    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","current_page"}});
	{Variable,Option,Page} ->	    
	    case message(Option,list_to_atom(Variable++Page)) of
		[] ->
		    slog:event(internal,?MODULE,page_not_found_in_list,{Option,Variable,Page}),
		    [];
		Message ->
		    [{pcdata,Message}]
	    end
    end.

message(Service, Value) ->
    Message_List = select_list(Service),
    Phrase = case lists:keysearch(Value,1,Message_List) of
		 {value,{Value,Message}} ->
		     Message;
		 _->
		     []
	     end.

dohist_back(plugin_info,URL,URL_HOME) ->
    (#plugin_info
     {help =
      "This plugin redirect depend on value of current page.",
      type = command,
      license = [],
      args = [
	      {url, {link,[]},"This parameter specifies the ok page"},
	      {url_home, {link,[]},"This parameter specifies options menu page"}
	     ]
     }
    );

dohist_back(abs,URL,URL_HOME)->
    [{redirect,abs,URL}];

dohist_back(Session,URL,URL_HOME) ->
    Current=get_value(Session,"current_page"),
    Offset=get_value(Session,"offset"),
    case {Current,Offset} of
	{"1","-1"}->
	    {redirect,Session,URL_HOME};
	{"1","0"}->
	    NSession = update_value(Session,"offset",?back),
	    {redirect,NSession,URL};
	_ ->
	    NSession=set_new_index(Session,Offset),
	    {redirect,NSession,URL}
    end.



next(plugin_info,URL) ->
    (#plugin_info
     {help =
      "This plugin redirect depend on value of current page.",
      type = command,
      license = [],
      args = [
	      {url, {link,[]},"This parameter specifies the previous page"}
	     ]
     }
    );

next(abs,URL)->
    [{redirect,abs,URL}];

next(Session,URL) ->
    NSession=set_new_index(Session,"1"),
    {redirect,NSession,URL}.

back(plugin_info,Other_message_type,URL1,URL2) ->
    (#plugin_info
     {help =
      "This plugin redirect depend on value of current page.",
      type = command,
      license = [],
      args = [{other_message_type, {oma_type, {enum,[conditions,
						     description,
						     souscription]}},
	       "This parameter specifies new type of message."},
	      {url_old, {link,[]},"This parameter specifies the previous page when current page = 1"},
	      {url_current, {link,[]},"This parameter specifies the previous page when current page > 1"}
	     ]
     }
    );

back(abs,Other_message_type,URL1,URL2)->
    [{redirect,abs,URL1},
     {redirect,abs,URL2}];
back(Session,Other_message_type,URL1,URL2)->
    Current_page=get_value(Session, "current_page"),
    case Current_page of
	"1"->
	    NSession=init_session(Session,Other_message_type),
	    {redirect,NSession,URL1};
	_ ->
	    NSession= set_new_index(Session,?back),
	    {redirect,NSession,URL2}
    end.


start(plugin_info,Message_type,URL) ->
    (#plugin_info
     {help =
      "This plugin is dedicated to legal mentions. It updates the current page to be displayed.",
      type = command,
      license = [],
      args = [
	      {message_type, {oma_type, {enum,[description,
                            tarifs_europe_voix,
                            tarifs_maghreb_voix,
                            tarifs_rdm_voix,
                            tarifs_europe_sms_mms,
                            tarifs_maghreb_sms_mms,
                            tarifs_rdm_sms_mms,
                            tarifs_europe_internet,
                            tarifs_rdm_internet
                      ]}},
	       "This parameter specifies the name of the session variable to be selected."},
	      {ok, {link,[]},"This parameter specifies the next page"}
	     ]
     }
    );

start(abs,_,URL)->
    [{redirect,abs,URL}];

start(Session, Message_type, URL)->
    Session1=init_session(Session,Message_type),
    NSession=update_value(Session1,"offset","0"),
    {redirect,NSession,URL}.

reset(plugin_info,Message_type,URL) ->
    (#plugin_info
     {help =
      "This plugin is dedicated to legal mentions. It updates the current page to be displayed.",
      type = command,
      license = [],
      args = [
	      {message_type, {oma_type, {enum,[conditions,
					       description,
					       souscription,
					       validation
					      ]}},
	       "This parameter specifies the name of the session variable to be selected."},
	      {ok, {link,[]},"This parameter specifies the next page"}
	     ]
     }
    );

reset(abs,_,URL)->
    [{redirect,abs,URL}];

reset(Session, Message_type, URL)->
    NSession=init_session(Session,Message_type),
    {redirect,NSession,URL}.

proposer_lien_suite(plugin_info, Suite) ->
    (#plugin_info
     {help =
      "This plugin function includes the suite link",
      type = function,
      license = [],
      args =
      [
       {suite, {link,[]},
	"This parameter specifies the next page for suite link"}
      ]});

proposer_lien_suite(abs, Suite) ->
    [#hlink{href=Suite,contents=[{pcdata,"Suite"}]}];

proposer_lien_suite(Session, Suite)->
    case is_last_page(Session) of
	true->
	    [];
	false ->
	    [#hlink{href=Suite,contents=[{pcdata,"Suite"}]}]
    end.

proposer_lien_suite(plugin_info, PCD, URL, Suite) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
      type = function,
      license = [],
      args =
      [
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the alternative text to be displayed."},
       {url, {link,[]},
	"This parameter specifies the next page for pcd"},
       {suite, {link,[]},
	"This parameter specifies the next page for suite link"}
      ]});

proposer_lien_suite(abs, PCD, URL, Suite) ->
    [#hlink{href=Suite,contents=[{pcdata,"Suite"}]}];

proposer_lien_suite(Session, PCD, URL, Suite)->
    case is_last_page(Session) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false ->
	    [#hlink{href=Suite,contents=[{pcdata,"Suite"}]}]
    end.


proposer_lien_suite(plugin_info, PCD1, PCD2, URL1, URL2, Suite) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
      type = function,
      license = [],
      args =
      [
       {pcd1, {oma_type, {defval,"",string}},
	"This parameter specifies the first text to be displayed."},
       {pcd2, {oma_type, {defval,"",string}},
	"This parameter specifies the first text to be displayed."},
       {url1, {link,[]},
	"This parameter specifies the next page for pcd 1"},
       {url2, {link,[]},
	"This parameter specifies the next page for pcd 2"},
       {suite, {link,[]},
	"This parameter specifies the next page for suite link"}
      ]});

proposer_lien_suite(abs, PCD1, PCD2, URL1, URL2, Suite) ->
    [#hlink{href=Suite,contents=[{pcdata,"Suite"}]}];

proposer_lien_suite(Session, PCD1, PCD2, URL1, URL2, Suite)->
    case is_last_page(Session) of
	true->
	    [#hlink{href=URL1,contents=[{pcdata,PCD1}]}]++ 
		svc_util_of:add_br("br")++
		[#hlink{href=URL2,contents=[{pcdata,PCD2}]}];
	false ->
	    [#hlink{href=Suite,contents=[{pcdata,"Suite"}]}]
    end.

is_last_page(Session)->
    Current=get_value(Session,"current_page"),
    Message_type=get_value(Session,"request_state"),
    Option=get_value(Session,"option"),
    Next=integer_to_list(list_to_integer(Current)+1),
    case message(Option, list_to_atom(Message_type++Next)) of
	[]->true;
	_ ->false
    end.

get_value(Session,Variable_name) ->
    variable:get_value(Session, {"bons_plans",Variable_name}).

update_value(Session,Variable_name,Value) ->    
    variable:update_value(Session, {"bons_plans",Variable_name}, Value).    

set_new_index(Session,Offset) ->
    Current=get_value(Session,"current_page"),
    NewIndex = list_to_integer(Current) + list_to_integer(Offset),
    update_value(Session,"current_page",integer_to_list(NewIndex)).

init_session(Session,Message_type)->
    Session1=update_value(Session,"request_state",Message_type),
    update_value(Session1,"current_page","1").

option_name(plugin_info, Sub, Page)->
    (#plugin_info
     {help =
      "This plugin function includes the display name of an option",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo, postpaid]}}, "This parameter specifies the subscription."},
       {page, {oma_type, {enum, [not_set, 1]}}, "This parameter specifies the flag, which need to check the first page."}
      ]});

option_name(abs, Sub, _) ->
    [{pcdata, "Libelle Option"}];


option_name(Session, "postpaid", Page)->
    Option = list_to_atom(get_value(Session, "option")),
    Str = svc_option_manager:get_commercial_name(Option, postpaid),
    case Page of
        "not_set"-> [{pcdata, Str}];
        "1"->
            Current_page=get_value(Session,"current_page"),
            case Current_page of
                "1"-> [{pcdata, Str}];
                _->[]
            end
    end.

redirect_OptASM_state(plugin_info, UAct, UIncomp,ErrorMsg, UGene) ->
    (#plugin_info
     {help = "",
      type = command,
      license = [],
      args =
      [{uact, {link,[]},
	"This parameter specifies the next page when the option is already activated."},
       {uincomp, {link,[]},
	"This parameter specifies the next page when the option"
	" is incompatible with existing options."},
       {errorMsg, {link,[]},
	"This parameter specifies the next page when ASMETIER PLATFORM"
	"respond (from get_impact request)with bad code or with unknown"
	" OptResil list code."},
       {ugene, {link,[]},
	"This parameter specifies the next page when subscription is allowed"}
      ]});

redirect_OptASM_state(Session, UAct, UIncomp, ErrorMsg, UGene) ->
    Option=get_value(Session, "option"),
    Subscription=svc_util_of:get_souscription(Session),
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    case svc_subscr_asmetier:is_option_activated(Session, Opt, State) of
        true ->
            {redirect,Session,UAct};
        false ->
            svc_subscr_asmetier:get_impactSouscrServiceOpt(Session, 
							   Subscription, Option,UAct,UIncomp,ErrorMsg,UGene)
    end.
%%Return the text "Attention, votre option..."
print_incomp_opts(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes the list of incompatible options.",
      type = function,
      license = [],
      args = [ ]});

print_incomp_opts(abs)->
    [{pcdata,""}];

print_incomp_opts(Session)->
    svc_subscr_asmetier:print_opt_incomp(Session).

%%Return the text "Cette option n'est pas compatible avec votre option"
print_incomp_options(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes the list of incompatible options.",
      type = function,
      license = [],
      args = [ ]});

print_incomp_options(abs)->
    [{pcdata,""}];

print_incomp_options(Session)->
    Opt=list_to_atom(get_value(Session, "option")),
    svc_subscr_asmetier:print_opt_incomp(Session, Opt).

asm_SetServiceOptionnel(plugin_info, Subscription, UGene, UFunc, UNok) ->
    (#plugin_info
     {help =
      "This plugin command send the subscription request to"
      " ASMETIER PLATFORM and redirects to the page "
      " corresponding to the result of the subscription.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,postpaid]}},
        "This parameter specifies the subscription."},
       {ugene, {link,[]},
	"This parameter specifies the next page when subscription is allowed"},
       {ufunc, {link,[]},
	"This parameter specifies the next page when functional issue occurs"},
       {unok, {link,[]},
	"This parameter specifies the next page in case of a"
	" technical problem"}
      ]});

asm_SetServiceOptionnel(Session, Subscription, UGene, UFunc, UNok)
  when Subscription == "cmo"  ->
    Option=get_value(Session, "option"),
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, svc_of_plugins:code_opt(Session, Opt), Opt) of
        {ok,NewSess} ->
            OptActiv = svc_subscr_asmetier:cast(NewSess),
            NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
            {redirect, svc_of_plugins:update_session(NewSess,NewOptActiv),UGene};
        code_7 ->
            {redirect,Session,UFunc};
        error_msg -> 
            {redirect,Session,UNok};
        E -> 
            {redirect,Session,UNok}
    end;

asm_SetServiceOptionnel(Session, Subscription, UGene, UFunc, UNok)
  when Subscription == "postpaid"  ->
    Option=get_value(Session, "option"),
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, svc_of_plugins:code_opt(Session, Opt), Opt) of
        {ok,NewSess} ->
            {redirect,NewSess,UGene};
        code_7 ->
            {redirect,Session,UFunc};
        error_msg -> 
            {redirect,Session,UNok};
        E -> 
            {redirect,Session,UNok}
    end.

print_if_first_page(plugin_info, Text) ->
    (#plugin_info
     {help =
      "This plugin function prints the text if first page.",
      type = function,
      license = [],
      args = [
	      {text, {oma_type, {defval,"",string}},
	       "This parameter specifies the text to be printed"}
	     ]});

print_if_first_page(abs, Text)->
    [{pcdata,""}];

print_if_first_page(Session, Text)->
    Current_page=get_value(Session, "current_page"),
    case Current_page of
        "1"->[{pcdata,Text++"\n"}];
        _->[]
    end.

proposer_lien_last_page(plugin_info, PCD, URL, KEY, BR) ->
    (#plugin_info
     {help =
      "This plugin function prints the link if last page.",
      type = function,
      license = [],
      args = [
          {pcd, {oma_type, {defval,"",string}},
              "This parameter specifies the text of link"},
          {url, {link,[]},
              "This parameter specifies the next page"},
          {key, {oma_type, {defval,"",string}},
              "This parameter specifies the key link"},
          {br, {oma_type, {enum,[br,nobr, br_after]}},
              "This parameter specifies the break line"}
      ]});

proposer_lien_last_page(abs, PCD, URL, KEY, BR)->
    [{redirect, abs, URL}];

proposer_lien_last_page(Session, PCD, URL, KEY, BR)->
    case is_last_page(Session) of
        true->
            svc_util_of:display_link(URL, PCD, KEY, BR);
        _->[]
    end.
redirect_by_option_type(plugin_info, Url_mail, Url_musique, Url_sport, Url_maps)->
    (#plugin_info
     {help = "This plugin redirect to homepage by option type",
      type = command,
      license = [],
      args =
      [
       {url_mail, {link,[]},
	"This parameter specifies the homepage when option type is mail"},
       {url_musique, {link,[]},
	"This parameter specifies the homepage when option type is musique"},
       {url_sport, {link,[]},
	"This parameter specifies the homepage when option type is sport"},
       {url_map, {link,[]},
	"This parameter specifies the homepage when option type is maps"}
      ]});

redirect_by_option_type(Session, Url_mail, Url_musique, Url_sport, Url_maps)->
    Option=list_to_atom(get_value(Session,"option")),
    case Option of
        X when X==opt_internet_max_gpro; 
	       X==opt_mail_gpro;
	       X==opt_mail_MMS_gpro;
	       X==opt_internet_gpro;
	       X==opt_giga_mail_gpro;
	       X==opt_iphone_3g_gpro;
	       X==opt_mail_blackberry_gpro;
	       X==opt_mes_donnees_gpro->
	    {redirect, Session, Url_mail};
	X when X==opt_musique_collection_gpro;
	       X==opt_musique_mix_gpro;
	       X==opt_tv_max_gpro;
	       X==opt_tv_gpro->
	    {redirect, Session, Url_musique};
	X when X==opt_orange_sport_gpro;
	       X==opt_paris_gpro; 
	       X==opt_marseille_gpro; 
	       X==opt_lyon_gpro; 
	       X==opt_lens_gpro; 
	       X==opt_saint_etienne_gpro; 
	       X==opt_bordeaux_gpro->
	    {redirect, Session, Url_sport};
	opt_orange_maps_gpro->
	    {redirect, Session, Url_maps}
    end.

proposer_lien(plugin_info, Option, PCD, URL, BR) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {defval,"",string}},
	"This parameter specifies the option"},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the option name"},
       {url, {link,[]},
	"This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr, br_after]}},
	"This parameter specifies the break line"}
      ]});

proposer_lien(abs, Option, PCD, URL, BR) ->
    [{redirect, abs, URL}];

proposer_lien(Session, Option, PCD, URL, BR) ->
    Opt=list_to_atom(Option),
    case svc_option_manager:is_possible_subscription(Session,Opt) of
        {NSession,true} ->
            svc_util_of:display_link(URL, PCD, BR);
        {_,false}->
            [];
        {_,_,Why}->
            []
    end.

set_bons_plans_actived_option(plugin_info, URL) ->
    (#plugin_info
        {help =
            "This plugin command update variable option and redirect",
            type = command,
            license = [],
            args =
            [
                {url, {link,[]},
                    "This parameter specifies the next page"}
            ]});

set_bons_plans_actived_option(abs, URL) ->
    [{redirect, abs, URL}];
set_bons_plans_actived_option(Session, URL)->
    ListOptions=
    case {get_value(Session, "tarifs_type"), get_value(Session, "zone")} of
        {"voix", "europe"} ->
            [
                opt_pass_voyage_15min_europe_gpro,
                opt_pass_voyage_30min_europe_gpro,
                opt_pass_voyage_60min_europe_gpro,
                opt_destination_europe_v037_gpro,
                opt_destination_europe_v038_gpro,
                opt_suisse_v037_gpro,
                opt_suisse_v038_gpro,
                opt_espagne_v037_gpro,
                opt_espagne_v038_gpro,
                opt_belgique_v037_gpro,
                opt_belgique_v038_gpro,
                opt_italie_v037_gpro,
                opt_italie_v038_gpro,
                opt_portugal_v037_gpro,
                opt_portugal_v038_gpro,
                opt_royaume_uni_v037_gpro,
                opt_royaume_uni_v038_gpro,
                opt_allemagne_v037_gpro,
                opt_allemagne_v038_gpro,
                opt_luxembourg_v037_gpro,
                opt_luxembourg_v038_gpro,
                opt_dom_v037_gpro,
                opt_dom_v038_gpro
            ];
        {"voix", "maghreb"} ->
            [
                opt_maroc_v037_gpro,
                opt_maroc_v038_gpro,
                opt_algerie_v037_gpro,
                opt_algerie_v038_gpro
            ];
        {"sms_mms", "europe"} ->
            [
                opt_pass_voyage_15min_europe_gpro,
                opt_pass_voyage_30min_europe_gpro,
                opt_pass_voyage_60min_europe_gpro

            ];
        {"internet", "europe"} ->
            [
                opt_pass_internet_int_jour_2E_gpro,
                opt_pass_internet_int_jour_5E_gpro,
                opt_pass_internet_int_5E_gpro,
                opt_pass_internet_int_20E_gpro,
                opt_pass_internet_int_35E_gpro,
                opt_pass_voyage_15min_europe_gpro,
                opt_pass_voyage_30min_europe_gpro,
                opt_pass_voyage_60min_europe_gpro
            ];
        {"internet", "rdm"} ->
            [
                opt_pass_internet_int_jour_2E_gpro,
                opt_pass_internet_int_jour_5E_gpro,
                opt_pass_internet_int_5E_gpro,
                opt_pass_internet_int_20E_gpro,
                opt_pass_internet_int_35E_gpro,
                opt_pass_voyage_15min_maghreb_gpro,
                opt_pass_voyage_30min_maghreb_gpro,
                opt_pass_voyage_60min_maghreb_gpro,
                opt_pass_voyage_15min_rdm_gpro,
                opt_pass_voyage_30min_rdm_gpro,
                opt_pass_voyage_60min_rdm_gpro
            ];
        {_,_}->[]
    end,
    case is_any_options_actived(Session, ListOptions) of
        {true, Opt}->
            Session_new=update_value(Session,"option",atom_to_list(Opt)),
            slog:event(trace,?MODULE,set_bons_plans_actived_options,Opt),
            {redirect, Session_new, URL};
        {false, _}->
            Session_updated=update_value(Session,"option","infos_tarifs_default_gpro"),
            slog:event(trace,?MODULE,set_bons_plans_actived_options,infos_tarifs_default_gpro),
            {redirect, Session_updated, URL}
    end.

is_any_options_actived(Session,[])->
    {false, no_option};

is_any_options_actived(Session, [Opt|T])->
    State = svc_util_of:get_user_state(Session),
    case svc_subscr_asmetier:is_option_activated(Session, Opt, State) of
        true->
            {true, Opt};
        _->
            is_any_options_actived(Session, T)
    end. 
