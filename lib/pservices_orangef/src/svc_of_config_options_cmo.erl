-module(svc_of_config_options_cmo).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pservices_orangef/include/messages_options_cmo.hrl").
-include("../../pservices_orangef/include/subscr_asmetier.hrl").
-include("../include/ftmtlv.hrl").

-define(back,"-1").

select_list("opt_orange_sport") ->
    ?OPT_ORANGE_SPORT;
select_list("opt_tv") ->
    ?OPT_TV;
select_list("opt_tv_max") ->
    ?OPT_TV_MAX;
select_list("opt_internet_max") ->
    ?OPT_INTERNET_MAX;
select_list("opt_internet") ->
    ?OPT_INTERNET;
select_list("opt_paris") ->
    ?OPT_PARIS;
select_list("opt_marseille") ->
    ?OPT_MARSEILLE;
select_list("opt_lyon") ->
    ?OPT_LYON;
select_list("opt_lens") ->
    ?OPT_LENS;
select_list("opt_saint_etienne") ->
    ?OPT_SAINT_ETIENNE;
select_list("opt_bordeaux") ->
    ?OPT_BORDEAUX;
select_list("opt_mail") ->
    ?OPT_MAIL;
select_list("opt_orange_maps") ->
    ?OPT_ORANGE_MAPS;
select_list("opt_mes_donnees") ->
    ?OPT_MES_DONNEES;
select_list("opt_musique_mix") ->
    ?OPT_MUSIQUE_MIX;
select_list("opt_musique_collection") ->
    ?OPT_MUSIQUE_COLLECTION;
select_list("opt_j_omwl") ->
    ?OPT_J_OMWL;
select_list("opt_j_app_ill") ->
    ?OPT_J_APP_ILL;
select_list("opt_s_app_ill") ->
    ?OPT_S_APP_ILL;
select_list("opt_jsms_ill") ->
    ?OPT_JSMS_ILL;
select_list("opt_jsms_ill_jeu") ->
    ?OPT_JSMS_ILL_JEU;
select_list("opt_ssms_ill") ->
    ?OPT_SSMS_ILL;
select_list("opt_ssms_ill_jeu") ->
    ?OPT_SSMS_ILL_JEU;
select_list("opt_j_mm_ill") ->
    ?OPT_J_MM_ILL;
select_list("opt_j_mm_ill_jeu") ->
    ?OPT_J_MM_ILL_JEU;
select_list("opt_s_mm_ill") ->
    ?OPT_S_MM_ILL;
select_list("opt_s_mm_ill_jeu") ->
    ?OPT_S_MM_ILL_JEU;
select_list("opt_j_tv_max_ill") ->
    ?OPT_J_TV_MAX_ILL;
select_list("opt_s_tv_max_ill") ->
    ?OPT_S_TV_MAX_ILL;
select_list("opt_j_omwl_kdo_bp") ->
    ?OPT_J_OMWL_KDO_BP;
select_list("opt_j_app_ill_kdo_bp") ->
    ?OPT_J_APP_ILL_KDO_BP;
select_list("opt_s_app_ill_kdo_bp") ->
    ?OPT_S_APP_ILL_KDO_BP;
select_list("opt_jsms_ill_kdo_bp") ->
    ?OPT_JSMS_ILL_KDO_BP;
select_list("opt_ssms_ill_kdo_bp") ->
    ?OPT_SSMS_ILL_KDO_BP;
select_list("opt_j_mm_ill_kdo_bp") ->
    ?OPT_J_MM_ILL_KDO_BP;
select_list("opt_s_mm_ill_kdo_bp") ->
    ?OPT_S_MM_ILL_KDO_BP;
select_list("opt_j_tv_max_ill_kdo_bp") ->
    ?OPT_J_TV_MAX_ILL_KDO_BP;
select_list("opt_s_tv_max_ill_kdo_bp") ->
    ?OPT_S_TV_MAX_ILL_KDO_BP;
select_list("opt_30_sms_mms") ->
    ?OPT_30_SMS_MMS;
select_list("opt_80_sms_mms") ->
    ?OPT_80_SMS_MMS;
select_list("opt_130_sms_mms") ->
    ?OPT_130_SMS_MMS;
select_list("opt_sms_mms_illimites") ->
    ?OPT_SMS_MMS_ILLIMITES;
select_list("opt_orange_messenger") ->
    ?OPT_ORANGE_MESSENGER;
select_list("opt_pass_voyage_15min_europe") ->
    ?OPT_PASS_VOYAGE_15MIN_EUROPE;
select_list("opt_pass_voyage_30min_europe") ->
    ?OPT_PASS_VOYAGE_30MIN_EUROPE;
select_list("opt_pass_voyage_60min_europe") ->
    ?OPT_PASS_VOYAGE_60MIN_EUROPE;
select_list("opt_pass_voyage_15min_maghreb") ->
    ?OPT_PASS_VOYAGE_15MIN_MAGHREB;
select_list("opt_pass_voyage_30min_maghreb") ->
    ?OPT_PASS_VOYAGE_30MIN_MAGHREB;
select_list("opt_pass_voyage_60min_maghreb") ->
    ?OPT_PASS_VOYAGE_60MIN_MAGHREB;
select_list("opt_pass_voyage_15min_rdm") ->
    ?OPT_PASS_VOYAGE_15MIN_RDM;
select_list("opt_pass_voyage_30min_rdm") ->
    ?OPT_PASS_VOYAGE_30MIN_RDM;
select_list("opt_pass_voyage_60min_rdm") ->
    ?OPT_PASS_VOYAGE_60MIN_RDM;
select_list("opt_pass_internet_int_jour_2E") ->
    ?OPT_PASS_INTERNET_INT_JOUR_2E;
select_list("opt_pass_internet_int_jour_5E") ->
    ?OPT_PASS_INTERNET_INT_JOUR_5E;
select_list("opt_10min_europe") ->
    ?OPT_10MIN_EUROPE;
select_list("opt_europe") ->
    ?OPT_EUROPE;
select_list("opt_maghreb") ->
    ?OPT_MAGHREB;
select_list("opt_pass_dom") ->
    ?OPT_PASS_DOM;
select_list("opt_messagerie") ->
    ?OPT_MESSAGERIE;
select_list("opt_appeler") ->
    ?OPT_APPELER;
select_list("infos_tarifs_default")->
    ?INFOS_TARIFS_DEFAULT.
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
    svc_of_plugins:track_kenobi_code(Session, "bons_plans", cmo),
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
                          conditions,
                          tarifs_europe_voix,
                          tarifs_maghreb_voix,
                          tarifs_rdm_voix,
                          tarifs_europe_sms_mms,
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
					       validation,
                           actived
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
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
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

option_name(Session, "cmo", Page)->
    Option=list_to_atom(get_value(Session, "option")),
    Str=svc_option_manager:get_commercial_name(Option, cmo),
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
                    "This parameter specifies the next page when the option"
                    " is already activated."},
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

redirect_by_option_state(plugin_info, Option, UAct, UIncomp, UInsuf, UGene) ->
    (#plugin_info
        {help = "",
            type = command,
            license = [],
            args =
            [
                {option, {oma_type, {enum, [bons_plans]}},
                    "This parameter specifies the option"},
                {uact, {link,[]},
                    "This parameter specifies the next page when the option"
                    " is already activated."},
                {uincomp, {link,[]},
                    "This parameter specifies the next page when the option"
                    " is incompatible with existing options."},
                {uInsuf, {link,[]},
                    "This parameter specifies the next page insuf"},
                {ugene, {link,[]},
                    "This parameter specifies the next page when subscription is allowed"}
            ]});

redirect_by_option_state(Session, "bons_plans", UAct, UIncomp, UInsuf, UGene) ->
    Option=get_value(Session, "option"),
    Opt = service_to_option(Option),
    State = svc_util_of:get_user_state(Session),
    Price = svc_util_of:subscription_price(Session, Opt),
    Curr = currency:sum(euro,Price/1000),
    Enough_credit = svc_options:enough_credit(cmo,State,Curr),
    Credit_bp = svc_options:credit_bons_plans_ac(State, {Curr,Opt}),
    case svc_option_manager:is_subscribed(Session,Opt) of
        {SessionUpdated, true} ->
            {redirect, SessionUpdated, UAct};
        _ ->
            case is_option_incomp(Session,Opt) of
                {NSession, true} -> 
                    {redirect, NSession, UIncomp};
                _ ->
                    case Enough_credit of
                        false ->
                            {redirect, Session, UInsuf};
                        true  ->
                            {redirect, Session, UGene}
                    end
            end
    end.
is_option_incomp(Session,Opt)->
    ListIncomp=svc_option_manager:get_list_incompatible_opts(Opt,cmo),
    case ListIncomp of 
	Case when Case==not_found;Case==closed -> 
	    {Session,false};
	_ ->
	    svc_option_manager:is_subscribed(Session,ListIncomp)
    end.

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

print_incomp_sachem(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes the list of incompatible options.",
      type = function,
      license = [],
      args = []
     });

print_incomp_sachem(abs)->
    [{pcdata,""}];

print_incomp_sachem(Session)->
    Option=get_value(Session, "option"),
    Opt = service_to_option(Option),
    List_incomp_opts = svc_option_manager:get_list_incompatible_opts(Opt, cmo),
    case List_incomp_opts of 
	Case when Case==not_found;Case==closed -> 
	    [{pcdata,""}];
	_ ->
	    case svc_option_manager:get_list_opts_activated(Session, List_incomp_opts) of
		[OptIncomp] ->
		    [{pcdata, "Cette option n'est pas compatible avec votre option "++svc_option_manager:get_commercial_name(OptIncomp, cmo)}];
		List when list(List)->
		    Txt_opts = 
			[{pcdata, "Cette option n'est pas compatible avec vos options "++get_opt_names(List)}];
		_ ->
		    [{pcdata,""}]
	    end
    end.



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
    Service=get_value(Session, "option"),
    Opt=service_to_option(Service),
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
    end.

print_if_first_page(plugin_info, Text) ->
    (#plugin_info
     {help =
      "This plugin function prints the text if current page is first page",
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

service_to_option(Service) ->
    case lists:sublist(Service, length(Service)-3, 4) of
	"_jeu" ->
	    list_to_atom(lists:sublist(Service, 1, length(Service)-4));
	_ ->
	    list_to_atom(Service)
    end.

get_opt_names([]) ->
    [];
get_opt_names([Option]) ->
    svc_option_manager:get_commercial_name(Option, cmo);
get_opt_names([Option | T]) ->
    svc_option_manager:get_commercial_name(Option, cmo)++", "++get_opt_names(T).

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
        {"voix", "europe"} ->[opt_pass_voyage_15min_europe,opt_pass_voyage_30min_europe,opt_pass_voyage_60min_europe];
        {"sms_mms", "europe"} ->[opt_pass_voyage_15min_europe,opt_pass_voyage_30min_europe,opt_pass_voyage_60min_europe];
        {"internet", "europe"} ->[opt_pass_voyage_15min_europe,opt_pass_voyage_30min_europe,opt_pass_voyage_60min_europe, opt_pass_internet_int_jour_2E, opt_pass_internet_int_jour_5E];
        {"internet", "rdm"} ->[opt_pass_voyage_15min_maghreb, opt_pass_voyage_30min_maghreb, opt_pass_voyage_60min_maghreb, opt_pass_voyage_15min_rdm, opt_pass_voyage_30min_rdm, opt_pass_voyage_60min_rdm, opt_pass_internet_int_jour_2E, opt_pass_internet_int_jour_5E];
        {_, _}-> []
    end,
    case is_any_options_actived(Session, ListOptions) of
        {true, Opt}->
            Session_new=update_value(Session,"option",atom_to_list(Opt)),
            slog:event(trace,?MODULE, set_bons_plans_actived_option, Opt),
            {redirect, Session_new, URL};
        {false, _}->
            Session_updated=update_value(Session,"option","infos_tarifs_default"),
            slog:event(trace,?MODULE, set_bons_plans_actived_option, infos_tarifs_default),
            {redirect, Session_updated, URL}
    end.

is_any_options_actived(Session,[])->
    {false, no_option};

is_any_options_actived(Session, [Opt|T])->
    State = svc_util_of:get_user_state(Session),
    case svc_option_manager:is_subscribed(Session, Opt) of
        {_,true}->
            {true, Opt};
        _->
            is_any_options_actived(Session, T)
    end. 

proposer_lien(plugin_info, Option, PCD, URL,BR)->
        (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {defval,"",string}},
        "This parameter specifies the option."},
       {pcd, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed."},
       {urls, {link,[]},
        "This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr,br_after]}},
        "This parameter specifies br tag."}
      ]});

proposer_lien(Session,Option, PCD, URL,BR) ->    
    Opt=service_to_option(Option),
    case svc_option_manager:is_possible_subscription(Session,Opt) of
	{NSession,true} ->
            svc_util_of:display_link(URL, PCD, BR);
        {_,false}->
	    [];
	{_,_,Why}->
	    []
    end.

subscribe(plugin_info, Option, UAct, UInsuf, UGene, UNok) ->
    (#plugin_info
        {help =
            "This plugin command send the subscription request and redirects to"
            " the page corresponding to the result of the subscription.",
            type = command,
            license = [],
            args =
            [
                {option, {oma_type, {defval,"",string}},
                    "This parameter specifies the option"},
                {uact, {link,[]},
                    "This parameter specifies the next page when the option"
                    " is already activated."},
                {uinsuf, {link,[]},
                    "This parameter specifies the next page when there is"
                    " not enough credit on the account to subscribe to the option."},
                {ugene, {link,[]},
                    "This parameter specifies the next page when subscription is allowed"},
                {unok, {link,[]},
                    "This parameter specifies the next page in case of a"
                    " technical problem"}
            ]});

subscribe(abs, Option, UAct, UInsuf, UGene, UNok) ->
    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene},
     {redirect,abs,UNok}];

subscribe(Session, "roaming", UAct, UInsuf, UGene, UNok) ->
    Option = get_value(Session, "option"),
    Opt=list_to_atom(Option),
    {NewSession,Result} = svc_option_manager:do_opt_cpt_request(Session,Opt,subscribe),
    svc_options:redirect_update_option(NewSession, Result, UGene, UAct, UInsuf, UNok, UNok).
