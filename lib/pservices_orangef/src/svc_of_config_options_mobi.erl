-module(svc_of_config_options_mobi).
-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pservices_orangef/include/messages_options_mobi.hrl").

-define(back,"-1").
-define(URL_HOME,"file:/mcel/acceptance/mobi/bons_plans/votre_multimedia/menu.xml").
select_list("opt_jinf") ->
    ?OPT_JINF;
select_list("opt_sinf") ->
    ?OPT_SINF;
select_list("opt_weinf") ->
    ?OPT_WEINF;
select_list("opt_10mn_quotidiennes") ->
    ?OPT_10MN_QUOTIDIENNES;
select_list("opt_30mn_hebdomadaires") ->
    ?OPT_30MN_HEBDOMADAIRES;
select_list("opt_pack_duo_journee") ->
    ?OPT_PACK_DUO_JOURNEE;
select_list("opt_sms_quoti") ->
    ?OPT_SMS_QUOTI;
select_list("opt_jsms_illimite") ->
    ?OPT_JSMS_ILLIMITE;
select_list("opt_ssms_illimite") ->
    ?OPT_SSMS_ILLIMITE;
select_list("opt_30_sms_mms") ->
    ?OPT_30_SMS_MMS;
select_list("opt_sms_mensu") ->
    ?OPT_SMS_MENSU;
select_list("opt_sms_illimite") ->
    ?OPT_MSG_ILLIMITE;
select_list("opt_mms_mensu") ->
    ?OPT_10_MMS;
select_list("opt_msn_journee_mobi") ->
    ?OPT_JOUNEE_WL;
select_list("opt_msn_mensu_mobi") ->
    ?OPT_MENSUELLE_WL;
select_list("opt_foot_ligue1") ->
    ?OPT_FOOT_LIGUE1;
select_list("opt_orange_sport") ->
    ?OPT_ORANGE_SPORT;
select_list("opt_internet_v2_pp") ->
    ?OPT_INTERNET_V2_PP;
select_list("opt_internet_v3_pp") ->
    ?OPT_INTERNET_V3_PP;
select_list("opt_internet_max_pp") ->
    ?OPT_INTERNET_MAX_PP;
select_list("opt_internet_max_v3") ->
    ?OPT_INTERNET_MAX_V3;
select_list("opt_internet_max_journee") ->
    ?OPT_INTERNET_MAX_JOURNEE;
select_list("opt_internet_max_weekend") ->
    ?OPT_INTERNET_MAX_WEEKEND;
select_list("opt_mail") ->
    ?OPT_MAIL;
select_list("opt_tv") ->
    ?OPT_TV;
select_list("opt_tv_max") ->
    ?OPT_TV_MAX;
select_list("opt_musique") ->
    ?OPT_MUSIQUE_MIX;
select_list("opt_musique_mix") ->
    ?OPT_MUSIQUE_MIX;
select_list("opt_musique_collection") ->
    ?OPT_MUSIQUE_COLLECTION;
select_list("opt_mes_donnees") ->
    ?OPT_MES_DONNEES;
select_list("opt_surf_mensu") ->
    ?OPT_SURF_MENSU;
select_list("opt_tv_mensu") ->
    ?OPT_TV_MENSU;
select_list("opt_visio") ->
    ?OPT_VISIO;
select_list("opt_ssms") ->
    ?OPT_SOIREE_SMS;
select_list("opt_jinf_jeu") ->
    ?OPT_JINF_JEU;
select_list("opt_sinf_jeu") ->
    ?OPT_SINF_JEU;
select_list("opt_pack_duo_journee_jeu") ->
    ?OPT_DUO_JEU;
select_list("opt_ssms_illimite_jeu") ->
    ?OPT_SOIREE_SMS_ILLIMITE_JEU;
select_list("opt_jsms_illimite_jeu") ->
    ?OPT_JOURNEE_SMS_ILLIMITE_JEU;
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
    svc_of_plugins:track_kenobi_code(Session, "bons_plans", mobi),
    case {get_value(Session, "request_state"),
	  get_value(Session, "option"),
	  get_value(Session, "current_page"),
	  get_value(Session, "subscription")
	 }
	of
	{not_found,_,_,_}->
	    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","request_state"}});
	{_,not_found,_,_}->
		 exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","option"}});
	{_,_,not_found,_}->
	    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","current_page"}});
	{Variable,Option,Page,not_found} ->	    
	    case message(Option,list_to_atom(Variable++Page)) of
		[] ->
		    slog:event(internal,?MODULE,page_not_found_in_list,{Option,Variable,Page}),
		    [];
		Message ->
		    [{pcdata,Message}]
	    end;
	{Variable,Option,Page,Subscription} ->	    
	    case message(Option,list_to_atom(Subscription++"_"++Variable++Page)) of
		[] ->
		    slog:event(internal,?MODULE,page_not_found_in_list,{Option,Subscription,Variable,Page}),
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
						     souscription,
						     description_actived,
						     actived,
						     suppression,
						     description_suspend,
						     promo_description,
						     promo_souscription,
						     reactivation]}},
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
					       description_actived,
					       description_suspend,
					       promo_description,
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
					       description_suspend,
					       description_actived,
					       souscription,
					       suppression,
					       suppressed,
					       reactivation,
					       actived,
					       low_credit,
					       principal,
					       reactived_principal,
					       incompatible,
					       error,
					       promo_conditions,
					       promo_souscription,
					       promo_actived,
					       promo_error,
					       promo_low_credit,
					       promo_incompatible,
					       promo_principal
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

is_last_page(Session)->
    Current=get_value(Session,"current_page"),
    Subscription=get_value(Session,"subscription"),
    Message_type=get_value(Session,"request_state"),
    Option=get_value(Session,"option"),
    Next=integer_to_list(list_to_integer(Current)+1),
    case Subscription of
        not_found->
            case message(Option, list_to_atom(Message_type++Next)) of
                []->true;
                _ ->false
            end;
        _->
            case message(Option, list_to_atom(Subscription++"_"++Message_type++Next)) of
                []->true;
                _ ->false
            end
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
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    PrixSubscr = svc_util_of:subscription_price(Session, Opt, without_promo),
    EnoughCredit = svc_options_mobi:enough_credit(State,{currency:sum(euro,PrixSubscr/1000),Opt}),
    case svc_option_manager:is_subscribed(Session,Opt) of
        {SessionUpdated, true} ->
            {redirect, SessionUpdated, UAct};
        _ ->
            case is_option_incomp(Session,Opt) of
                true -> 
                    {redirect, Session, UIncomp};
                false ->
                    case EnoughCredit of
                        false ->
                            {redirect, Session, UInsuf};
                        true  ->
                            {redirect, Session, UGene}
                    end
            end
    end.


is_option_incomp(Session,Opt)->
    ListIncomp=svc_option_manager:get_list_incompatible_opts(Opt,mobi),
    case ListIncomp of 
	Case when Case==not_found;Case==closed -> 
	    false;
	_ -> 
	    case is_any_options_actived(Session, ListIncomp) of
		{false,_}->
		    false;
		{true, _}->
		    true
	    end
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

print_if_first_page(plugin_info, Text) ->
    (#plugin_info
     {help =
      "This plugin function print the text if current page is first page",
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
    Opt = list_to_atom(Option),
    List_incomp_opts = svc_option_manager:get_list_incompatible_opts(Opt,mobi),
    case List_incomp_opts of 
	Case when Case==not_found;Case==closed ->
	    [{pcdata,""}];
	_ ->
	    case svc_option_manager:get_list_opts_activated(Session, List_incomp_opts) of
		[OptIncomp] ->
		    [{pcdata, "Cette option n'est pas compatible avec votre option "++svc_option_manager:get_commercial_name(OptIncomp, mobi)}];
		List when list(List)->
		    Txt_opts = 
			[{pcdata, "Cette option n'est pas compatible avec vos options "++get_opt_names(List)}];
		_ ->
		    [{pcdata,""}]
	    end
    end.

get_opt_names([]) ->
    [];
get_opt_names([Option]) ->
    svc_option_manager:get_commercial_name(Option,mobi);
get_opt_names([Option | T]) ->
    svc_option_manager:get_commercial_name(Option, mobi)++"; "++get_opt_names(T).

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

proposer_lien(plugin_info, Option, PCD, URL,BR) ->
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
                    "This parameter specifies the text to be displayed."},
                {url, {link,[]},
                    "This parameter specifies the next page"},
                {br, {oma_type, {enum,[br,nobr,br_after]}},
                    "This parameter specifies br tag."}
            ]});

proposer_lien(abs, _, PCD, URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien(Session, Option, PCD, URL,BR)
when Option =="opt_mms_mensu"->
    Opt=list_to_atom(Option),
    case svc_options:state(Session, Opt) of
        not_actived ->[];
        _->
            svc_util_of:display_link(URL, PCD, BR)
    end;

proposer_lien(Session, Option, PCD, URL,BR)
when Option=="opt_msn_journee_mobi"->
    Opt=list_to_atom(Option),	
    case svc_options:state(Session, Opt) of
        not_actived->
            svc_util_of:display_link(URL, PCD, BR);
        _->[]
    end;

proposer_lien(Session, Option, PCD, URL, BR)
when Option == "opt_europe"; Option == "opt_maghreb"; Option == "opt_pass_dom" ->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true ->
            svc_util_of:display_link(URL, PCD, BR);
	false ->
	    []
    end;

proposer_lien(Session, Option, PCD, URL, BR)
when Option == "opt_pass_voyage_15min_europe"; 
     Option == "opt_pass_voyage_30min_europe";
     Option == "opt_pass_voyage_60min_europe"; 
     Option == "opt_pass_voyage_15min_maghreb"; 
     Option == "opt_pass_voyage_30min_maghreb";
     Option == "opt_pass_voyage_60min_maghreb"; 
     Option == "opt_pass_voyage_15min_rdm";
     Option == "opt_pass_voyage_30min_rdm"; 
     Option == "opt_pass_voyage_60min_rdm";
     Option == "opt_10min_europe";
     Option == "opt_pass_internet_int_jour_2E";
     Option == "opt_pass_internet_int_jour_5E" ->
    Opt=list_to_atom(Option),
    case svc_option_manager:is_possible_subscription(Session,Opt) of 
        {_,true} ->
            svc_util_of:display_link(URL, PCD, BR);
        _->
            []
    end.

%%subscribe/7
subscribe(plugin_info, Option, UAct, UInsuf, UIncomp, UNok, Uok_princ) ->
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
                {uincomp, {link,[]},
                    "This parameter specifies the next page when there is incompatibe options actived"},
                {unok, {link,[]},
                    "This parameter specifies the next page in case of a technical problem"},
                {uok_princ, {link,[]},
                    "This parameter specifies the next page when subscription is allowed"}
            ]});

subscribe(abs, Option, UAct, UInsuf, UIncomp, UNok, Uok_princ) ->
    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,Uok_princ},
     {redirect,abs,UIncomp},
     {redirect,abs,UNok}];
	 
subscribe(#session{prof=Prof}=Session, Option, UAct, UInsuf, UIncomp,UNok, Uok_princ)
    when Option=="vos_messages"; Option == "multimedia"; Option == "vos_appels"; Option == "Others"->
    Service=get_value(Session, "option"),
    Opt=service_to_option(Service),
    {NewSession,Result} = 
    case Opt of 
        Y when Y==opt_ssms_illimite;Y==opt_jsms_illimite;
	       Y==opt_internet_max_journee->
            case is_option_incomp(Session,Y) of
                true->
                    {Session,{nok_opt_incompatible,""}};
                _->
                    svc_option_manager:do_opt_cpt_request(Session , Y, subscribe)
            end;
        _ ->
            svc_option_manager:do_opt_cpt_request(Session ,Opt,subscribe)
    end,
    Uopt_bloquee=svc_of_plugins:get_url_blocked(NewSession),
    case Result of
        %% In Sachem Tuxedo, we do not have account info
        {opt_bloquee_101,_} ->
            Session2=svc_options_mobi:set_current_option(NewSession,Opt),
            {redirect,Session2,Uopt_bloquee};
        {error, "option_incompatible_sec"} ->
            Session2=svc_options_mobi:set_current_option(NewSession,Opt),
            {redirect,Session2,Uopt_bloquee};
	Status->
	    svc_options:redirect_update_option(NewSession, Status, Uok_princ, UAct, 
					       UInsuf, UIncomp, Uopt_bloquee, UNok)
    end.

%%subscribe/8
subscribe(plugin_info, Option, UAct, UInsuf, UIncomp, UNok, Uok_princ, UNok_heure) ->
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
                {uincomp, {link,[]},
                    "This parameter specifies the next page when there is incompatibe options actived"},
                {unok, {link,[]},
                    "This parameter specifies the next page in case of a technical problem"},
                {uok_princ, {link,[]},
                    "This parameter specifies the next page when subscription is allowed"},
                {unok_heure, {link,[]},
                    "This parameter specifies the next page in case of heure"}
            ]});
subscribe(abs, Option, UAct, UInsuf, UIncomp, UNok, Uok_princ, UNok_heure) ->
    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,Uok_princ},
     {redirect,abs,UIncomp},
     {redirect,abs,UNok},
     {redirect,abs,UNok_heure}];
	 
subscribe(#session{prof=Prof}=Session, "vos_messages", UAct, UInsuf, UIncomp,UNok, Uok_princ, UNok_heure) ->
    Service=get_value(Session, "option"),
    Opt=service_to_option(Service),
    {NewSession,Result} = 
    case Opt of 
        Y when Y==opt_ssms_illimite;Y==opt_jsms_illimite ->
        case svc_util_of:is_good_plage_horaire(Y,mobi) of
            true ->
                case is_option_incomp(Session,Y) of
                    true->
                        {Session,{nok_opt_incompatible,Y}};
                    _->
                        svc_option_manager:do_opt_cpt_request(Session , Y, subscribe)
                end;
            _ ->
                {Session,{nok_heure_fermeture, Y}}
        end;
    _ ->
        svc_option_manager:do_opt_cpt_request(Session ,Opt,subscribe)
    end,
    Uopt_bloquee=svc_of_plugins:get_url_blocked(NewSession),
    case Result of
        {nok_heure_fermeture, _} ->
            {redirect, NewSession, UNok_heure};
        Status ->
            svc_options:redirect_update_option(NewSession, Result, Uok_princ, UAct, 
                UInsuf, UIncomp, Uopt_bloquee, UNok)
    end. 

service_to_option("opt_jinf_jeu") ->
    opt_jinf;
service_to_option("opt_sinf_jeu") ->
    opt_sinf;
service_to_option("opt_pack_duo_journee_jeu") -> 
	opt_pack_duo_journee;
service_to_option("opt_ssms_illimite_jeu") ->
    opt_ssms_illimite;
service_to_option("opt_jsms_illimite_jeu") ->
    opt_jsms_illimite;
service_to_option(not_found) ->
    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","option"}});
service_to_option(Service)when list(Service) ->
    list_to_atom(Service).
