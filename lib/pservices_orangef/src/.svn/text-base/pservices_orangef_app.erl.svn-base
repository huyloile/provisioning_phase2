-module(pservices_orangef_app).
-behaviour(application).

-export([start/2, stop/1, param_info/1]).
-export([install/1, install_game/1]).

-include("../../oma/include/oma.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/annuaire.hrl").
-include("../include/one2one.hrl").
-include("../include/tele2.hrl").
-include("../include/option.hrl").

%-import(oma_mnesia, [check_table/3]).
%%%% Callbacks for behaviour "application".

start(Type, Args) -> 
    Tables = [ratio,annuaire,?ONE2ONE_OFFER,option_sachem,option_asmetier],
    evae_app:wait_for_tables(Tables, 5000),
    oma_mnesia:load_table(ratio),
    io:format("TABLE Ratio loaded ~n"),
    oma_mnesia:load_table(annuaire),
    annuaire:csv2mnesia(),
    io:format("TABLE Annuaire loaded ~n"),
    oma_mnesia:load_table(?ONE2ONE_OFFER),
    io:format("TABLE One2One loaded ~n"),
    oma_mnesia:load_table(option_sachem),
    io:format("TABLE Option Sachem loaded ~n"),
    oma_mnesia:load_table(option_asmetier),
    io:format("TABLE Option Asmetier loaded ~n"),
    pservices_orangef_sup:start_link(Args).

stop(State) -> ok.

%% +type install([atom()]) -> ok.
install(Nodes)->
    DelRes = lists:map(fun(T) -> mnesia:delete_table(T) end,
                       [ratio,annuaire,refill_game,logo_table,option_sachem,option_asmetier]),
    T1Opts = [ {disc_copies, Nodes},
	       {attributes, record_info(fields,ratio)}],
    T1Res  = (catch mnesia:create_table(ratio, T1Opts)), 

    T2Opts = [ {disc_copies, Nodes},{type,ordered_set},
	       {attributes, record_info(fields,annuaire)}],
    T2Res  = (catch mnesia:create_table(annuaire, T2Opts)),
    
    T3Opts = [ {disc_copies, Nodes},{type,ordered_set},
	       {attributes, record_info(fields,?ONE2ONE_OFFER)}],
    T3Res  = (catch mnesia:create_table(?ONE2ONE_OFFER, T3Opts)),

    T4Opts = [ {type, bag},{disc_copies, Nodes},
               {attributes, record_info(fields,option_sachem)}],
    T4Res  = (catch mnesia:create_table(option_sachem, T4Opts)),

    T5Opts = [ {type, bag},{disc_copies, Nodes},{index,[#option_asmetier.subscription]},
               {attributes, record_info(fields,option_asmetier)}],
    T5Res  = (catch mnesia:create_table(option_asmetier, T5Opts)),

    io:format("~p CREATE: ~p ~p ~p~n",
              [?MODULE, T1Res, T2Res, T3Res]).

install_game(Nodes)->
    T1Opts = [ {disc_copies, Nodes}, {type,bag},
               {attributes, record_info(fields,refill_game)} ],
    T1Res = (catch mnesia:create_table(refill_game, T1Opts)),
    A =rpc:multicall(Nodes,refillgame_2_mnesia,csv_2_mnesia,
		  [?REFILL_GAME,"refill_game.csv","record_name",$;]),

    ok.


%% +type param_info(atom()) -> param_info().
param_info(erl_exports)->
    pserver_app:param_info(erl_exports);
param_info(new_provisioning_module_proportion) ->
    (#param_info
     {type = int,
      name = "New provisioning module proportion",
      help = "Percentage of sessions for which the new provisioning "
      "module (Spider) should be used.",
      example = 50,
      activation = auto,
      level = install
     });
param_info(provisioning_module) ->
    (#param_info
     {type = {enum, [provisioning_ftm,provisioning_ftm_old]},
      name = "Provisioning module",
      help = "Choose Provisioning Module.",
      example = provisoning_ftm_old,
      activation = auto,
      level = install
     });
param_info(activate_billing) ->
    (#param_info
     {type = bool,
      name = "Activate billing",
      help = "Allow to activate billing in fonction of subscription ",
      example = true,
      activation = auto,
      level = install
     });
param_info(dump_callback) ->
    (#param_info
     {type = bool,
      name = "Dump callback counters",
      help = "",
      example = true,
      activation = auto,
      level = install
     });
param_info(dump_sms_mms_infos) ->
    (#param_info
     {type = bool,
      name = "Dump sms mms infos counters",
      help = "",
      example = true,
      activation = auto,
      level = install
     });
param_info(new_consult) ->
    (#param_info
     {type = bool,
      name = "Consultation request switch",
      help = "if true we use A4\n if false we use A3",
      example = true,
      activation = auto,
      level = install
     });
param_info(acces_service_parentChild) ->
    (#param_info
     {type = {enum, [ouvert, ferme]},
      name = "Ouvrir le service parentChild",
      help = "Ouvre/Ferme l'acces au service parentChild (affichage du "
      "lien 'Recharge pour un proche' depuis le menu des postpaid)",
      example = true,
      activation = auto,
      level = install
     });
param_info(ocfrdp_failure) ->
    (#param_info
     {type = {enum, [continue_session,end_session]},
      name = "Type of behavior when OCFRDP is HS",
      help = "if continue session the service is rendered with USSD_LEVEL=1\n"
      " if end_session the service retruned an error message",
      example = continue_session,
      activation = auto,
      level = install});
param_info(ocf_sub_reinit) ->
    (#param_info
     {type = {tuple, "Pause/Ten", [{"Pause",int},{"Max Tentative",int}]},
      name = "Pause and Number of tentative to reinit subscription in OCF",
      help = "Pause: Time in ms between two subscribe Task\n"
      "Max Number of ocf request attempt",
      example = {1000,3},
      activation = auto,
      level = install
     });
param_info(update_ratio) ->
    (#param_info
     {type = {enum, [tlv,file,disabled]},
      name = "Update ratio switch",
      help = "if tlv, we use TLV to update mnesia table ratio\n"
      "if file ,we use default file\n"
      "if no ,no update will be done",
      example = tlv,
      activation = auto,
      level = install});
param_info(promo_link) ->
    (#param_info
     {type = {list, {print_raw,
		     {tuple,"Promo",[{"compte",atom},{"URL",string}]}
		    }},
      name = "List of Promotion Service",
      help = "Service Promotion: permet de définir la liste des "
      "promotions à afficher",
      example = [{compte,"#url_print_compte"}],
      activation = auto,
      level = install});
param_info(mvno_urls) ->
    (#param_info
     {type = {list, {print_raw,
		     {tuple,"Urls Mvno",[{"mvno",string},{"URL",string}]}
		    }},
      name = "Liste des urls mvnos",
      help = "Urls a joindre en fonction du mvno",
      example = [{"virgin","http://virgin_gp/xml_suiviconso.php"}],
      activation = auto,
      level = install});
param_info(O) when O==options_link->
    Type={alt,[
	       {compte_ac,{tuple,"Compte AC",[{"compte",atom},
					      {"url",string}]}},
	       {compte, {tuple,"Compte AC",[{"compte",atom},
					    {"url actif",string},
					    {"url épuisée",string}
					   ]}},
	       {option, {tuple,"Option", [{"option_name",
					   {tuple,"option", 
					    [{"opt",{const,option}},
					     {"name",atom}]}},
					  {"URL",string}]}}
	      ]},
    (#param_info
     {type = {list, {print_raw, Type}},
      name = "Suivi conso des options",
      help = "Service SV Option: permet de définir la liste des "
      "Sv d'option à afficher",
      example = [{compte,"#url_print_compte"}],
      activation = auto,
      level = install});
param_info(promo_link_mobi) ->
    (#param_info
     {type = {list, {print_raw,
                     {tuple,"Promo",[{"compte",atom},{"URL",string}]}
                    }},
      name = "List of Promotion Service",
      help = "Service Promotion: permet de definir la liste des "
      "promotions à afficher",
      example = [{compte,"#url_print_compte"}],
      activation = auto,
      level = install});

param_info(failure_url) ->
    (#param_info
     {type = string,
      name = "Failed url for OF service",
      help = "URL return when Provisioning Failed",
      example = "/orangef/home.xml#prov_failed",
      activation = auto,
      level = install});
param_info(url_opt_bloquee) ->
    (#param_info
     {type = string,
      name = "Url when option blocked by Sachem",
      help = "URL erreur identification Mobicarte",
      example = "/orangef/selfcare_long/selfcare.xml#code101_opt_bloquee",
      activation = auto,
      level = install});
param_info(url_opt_bloquee_m6) ->
    (#param_info
     {type = string,
      name = "M6 Url when option blocked by Sachem",
      help = "URL erreur identification M6 mobile",
      example = "/orangef/selfcare_long/selfcare.xml#code101_opt_bloquee_m6",
      activation = auto,
      level = install});
param_info(url_opt_bloquee_foot) ->
    (#param_info
     {type = string,
      name = "Url when option blocked by Sachem",
      help = "URL erreur identification pour client mobile club de foot",
      example = "/orangef/selfcare_long/selfcare.xml#code101_opt_bloquee_foot",
      activation = auto,
      level = install});
param_info(url_opt_bloquee_click) ->
    (#param_info
     {type = string,
      name = "Url when option blocked by Sachem",
      help = "URL erreur identification pour client click mobile",
      example = "/orangef/selfcare_long/selfcare.xml#code101_opt_bloquee_click",
      activation = auto,
      level = install});
param_info(url_recharge_interdit) ->
    (#param_info
     {type = string,
      name = "Url when recharge forbidden",
      help = "URL erreur identification rechargement Mobicarte",
      example = "/orangef/selfcare_long/selfcare.xml#recharge_interdit",
      activation = auto,
      level = install});
param_info(url_recharge_interdit_umobile) ->
    (#param_info
     {type = string,
      name = "Umobile Url when recharge forbidden",
      help = "URL erreur identification rechargement Umobile",
      example = "/orangef/selfcare_long/selfcare.xml#recharge_interdit_umobile",
      activation = auto,
      level = install});
param_info(url_recharge_interdit_m6) ->
    (#param_info
     {type = string,
      name = "M6 Url when recharge forbidden",
      help = "URL erreur identification rechargement M6 mobile",
      example = "/orangef/selfcare_long/selfcare.xml#recharge_interdit_m6",
      activation = auto,
      level = install});
param_info(url_recharge_interdit_click) ->
    (#param_info
     {type = string,
      name = "Click Url when recharge forbidden",
      help = "URL erreur identification rechargement Click",
      example = "/orangef/selfcare_long/selfcare.xml#recharge_interdit_click",
      activation = auto,
      level = install});
param_info(notallowed_url) ->
    (#param_info
     {type = string,
      name = "url for OF service when Pay balance is over",
      help = "URL return when Billing stop the session",
      example = "/orangef/home.xml#not_allowed",
      activation = auto,
      level = install});
param_info(url_not_postpaid) ->
    (#param_info
     {type = string,
      name = "url for OF service when User isn't postpaid",
      help = "URL return when a client isn't postpaid",
      example = "/orangef/home.xml#selfcare",
      activation = auto,
      level = install});
param_info(periode_de_grace) ->
    (#param_info
     {type = int,
      name = "Periode de grace",
      help = "Nombre de jours avant résilation complété",
      example = 183,
      activation = auto,
      level = install});
param_info(price_max) ->
    (#param_info
     {type = currency(),
      name = "Prix maximum de la session",
      help = "",
      example = {euro,10.0},
      activation = auto,
      level = install});
param_info(solde_min) ->
    (#param_info
     {type = currency(),
      name = "SOlde minimale avant taxation",
      help = "",
      example = {euro,1.0},
      activation = auto,
      level = install});

param_info(annuaire_headers) ->
    #param_info{
	    type       = string,
	    name       = "Expression régulière des en-têtes de colonnes",
	    help       = "Les données commencent sur la ligne suivante",
	    example    =  "\rubriques\"",
	    activation = auto,
	    level      = user};

param_info(annuaire_rules_headings) ->
    #param_info{
	    type       = {list,string},
	    name       = "Rubriques affichant un lien supplémentaire",
	    help       = "Nécessaire pour la rubrique de jeux",
	    example    =  ["jeux"],
	    activation = auto,
	    level      = user};

param_info(annuaire_maxchars) ->
    #param_info{
	    type       = int,
	    name       = "Nombre maximum de caractères "
	    "par champ dans la table mnesia",
	    help       = "Evite la surcharge de la plate-forme",
	    example    =  400,
	    activation = auto,
	    level      = user};

param_info(annuaire_next_tag) ->
    #param_info{
	    type       = string,
	    name       = "Intitulé de lien pour les services suivants",
	    help       = "",
	    example    =  "suite",
	    activation = auto,
	    level      = user};   

param_info(annuaire_categories) ->
    #param_info{
	    type       = {list,{tuple, "Categorie", 
				[{"theme", string},
				 {"rubriques",
				  {list,string}}]}},
	    name       = "Annuaire: arborescence themes/rubriques",
	    help       = "Permet de valider un fichier .csv",
	    example    = [
			  {"chat",[]
			  },
			  {"divertissement",
			   ["cine/sortie","horoscope","humour","jeux",
			    "radio/tv","test"]
			  },
			  {"info",
			   ["actu","finance","meteo","pratique","sport"]
			  },
			  {"logo/sonnerie",
			   ["logo","sonnerie","fond d'ecran"]
			  }
			 ],
	    activation = auto,
	    level      = user};

param_info(one2one_activated_cmo) ->
    #param_info{
	    type       = bool,
	    name       = "L'interrogation de One 2 One est activee ou non",
	    help       = "Doit etre positionne a true pour etre active,"
	    " ensuite le planning est pris en compte",
	    example    = true,
	    activation = auto,
	    related = [one2one_schedule],
	    level      = install};
param_info(one2one_activated_mobi) ->
    #param_info{
	    type       = bool,
	    name       = "L'interrogation de One 2 One est activee ou non",
	    help       = "Doit etre positionne a true pour etre active,"
	    " ensuite le planning est pris en compte",
	    example    = true,
	    activation = auto,
	    related = [one2one_schedule],
	    level      = install};
param_info(one2one_activated_postpaid) ->
    #param_info{
	    type       = bool,
	    name       = "L'interrogation de One 2 One est activee ou non",
	    help       = "Doit etre positionne a true pour etre active,"
	    " ensuite le planning est pris en compte",
	    example    = true,
	    activation = auto,
	    related = [one2one_schedule],
	    level      = install};

param_info(one2one_schedule) ->
    #param_info{
 	    type       = {tuple,"Planning",
			  [{"Lundi",weekday(monday)},
			   {"Mardi",weekday(tuesday)},
			   {"Mercredi",weekday(wednesday)},
			   {"Jeudi",weekday(thursday)},
			   {"Vendredi",weekday(friday)},
			   {"Samedi",weekday(saturday)},
			   {"Dimanche",weekday(sunday)}
			  ]
 			 },
 	    name       = "One to One : definition des horaires d'ouverture du"
	    " service",
 	    help       = "Indispensable pour definir les heures de"
	    " fonctionnement",
 	    example    = 
	    {{monday,    {on, {07,30,00},{22,30,00}}},
	     {tuesday,   {on, {07,30,00},{22,30,00}}},
	     {wednesday, {on, {07,30,00},{22,30,00}}},
	     {thursday,  {on, {07,30,00},{22,30,00}}},
	     {friday,    {on, {07,30,00},{22,30,00}}},
	     {saturday,  {on, {07,30,00},{22,30,00}}},
	     {sunday,    {off,{07,30,00},{22,30,00}}}
	    },
 	    activation = auto,
	    related = [one2one_activated_mobi],
	    level      = user};

param_info(one2one_visu_partielle) ->
    #param_info{
	    type       = percentage(),
	    name       = "Borne de visualisation partielle",
	    help       = "Exprimee en pourcents [0-100]",
	    example    =  "20",
	    activation = auto,
	    related = [one2one_visu_totale,one2one_subscription_tag,
		       one2one_ecoutepartielle_tag],
	    level      = user};

param_info(one2one_visu_totale) ->
    #param_info{
	    type       = percentage(),
	    name       = "Borne de visualisation totale",
	    help       = "Exprimee en pourcents [0-100]",
	    example    =  "80",
	    activation = auto,
	    related = [one2one_visu_partielle,one2one_subscription_tag,
		       one2one_ecoutetotale_tag],
	    level      = user};

param_info(one2one_nonecoute_tag) ->
    #param_info{
	    type       = string,
	    name       = "Tag de non écoute",
	    help       = "envoye dans le flux XML de statistiques"
	    " (non utilise)",
	    example    =  "NonEcoute",
	    activation = auto,
	    level      = user};

param_info(one2one_ecoutepartielle_tag) ->
    #param_info{
	    type       = string,
	    name       = "Tag d'ecoute partielle",
	    help       = "envoye dans le flux XML de statistiques",
	    example    =  "P",
	    activation = auto,
	    level      = user};

param_info(one2one_ecoutetotale_tag) ->
    #param_info{
	    type       = string,
	    name       = "Tag d'ecoute totale",
	    help       = "envoye dans le flux XML de statistiques",
	    example    =  "T",
	    activation = auto,
	    level      = user};

param_info(one2one_subscription_tag) ->
    #param_info{
	    type       = string,
	    name       = "Tag de souscription",
	    help       = "envoye dans le flux XML de statistiques",
	    example    =  "O",
	    activation = auto,
	    level      = user};

param_info(one2one_subscription_redir) ->
    #param_info{
	    type       = {list,{tuple, "Link to option", 
				[{"ref", atom},
				 {"module",atom},
				 {"function",atom},
				 {"args",{list,string}},
				 {"success page",string}]}},
	    name       = "Liste des MFA/success page pour les liens"
	    " de souscriptions",
	    help       = "Faire passer les tests avant de modifier",
	    example    =  
	    [{opt1,
	      svc_options,proposer_lien,
	      ["opt_sinf","~s=selfcare_long/opt_sinf.xml",""],
	      "file:/orangef/selfcare_long/opt_sinf.xml#success"},
	     {opt2,
	      svc_options,proposer_lien,
	      ["opt_europe","~s=selfcare_long/opt_europe.xml",""],
	      "file:/orangef/selfcare_long/opt_europe.xml#success"},
	     {opt3,
	      svc_options,proposer_lien,
	      ["opt_maghreb","~s=selfcare_long/opt_maghreb.xml",""],
	      "file:/orangef/selfcare_long/opt_maghreb.xml#success"},
	     {opt4,
	      svc_options,proposer_lien,
	      ["opt_afterschool",
	       "~s=selfcare_long/opt_afterschool.xml",""],
	      "file:/orangef/selfcare_long/opt_afterschool.xml#success"},
	     {opt5,
	      svc_options,proposer_lien,
	      ["opt_ssms","~s=selfcare_long/opt_ssms.xml",""],
	      "file:/orangef/selfcare_long/opt_ssms.xml#success"},
	     {opt6,
	      svc_options,proposer_lien,
	      ["opt_weinf","~s=selfcare_long/opt_weinf.xml",""],
	      "file:/orangef/selfcare_long/opt_weinf.xml#success"},
	     {opt7,
	      svc_one2one,link_option,
	      ["opt_ow_3E_mobi.xml","~s"],
	      "file:/orangef/selfcare_long/opt_ow_3E_mobi.xml#success"},
	     {opt8,
	      svc_one2one,link_option,
	      ["sms_infos.xml","~s"],
	      "file:/orangef/selfcare_long/sms_infos.xml#success_sms"},
	     {opt9,
	      svc_one2one,link_option,
	      ["mmsinfos.xml","~s"],
	      "file:/orangef/selfcare_long/mmsinfos.xml#success_abo"},
	     {opt10,
	      svc_one2one,link_option,
	      ["options_sms.xml","~s"],
	      "file:/orangef/selfcare_long/options_sms.xml#success"},
	     {opt11,
	      svc_options,proposer_lien,
	      ["opt_numprefp","~s=selfcare_long/opt_numprefp.xml",""],
	      "file:/orangef/selfcare_long/opt_numprefp.xml#success"},
	     {opt12,
	      svc_options,proposer_lien,
	      ["opt_pack_duo_journee","~s=selfcare_long/opt_tt_shuss.xml",""],
	      "file:/orangef/selfcare_long/opt_tt_shuss.xml#success"},
	     {opt13,
	      svc_options,proposer_lien,
	      ["opt_vacances","~s=selfcare_long/opt_vacances.xml",""],
	      "file:/orangef/selfcare_long/opt_vacances.xml#success"},
	     {opt14,
	      svc_options,proposer_lien,
	      ["opt_jinf","~s=selfcare_long/opt_jinf.xml",""],
	      "file:/orangef/selfcare_long/opt_jinf.xml#success"},
	     {opt15,
	      svc_options,proposer_lien,
	      ["opt_voyage","~s=selfcare_long/opt_voyage.xml",""],
	      "file:/orangef/selfcare_long/opt_voyage.xml#success"},
	     {opt16,
	      svc_one2one,link_option,
	      ["opt_ow_6E_mobi.xml","~s"],
	      "file:/orangef/selfcare_long/opt_ow_6E_mobi.xml#success"},
	     {opt17,
	      svc_one2one,link_option,
	      ["opt_ow_10E_mobi.xml","~s"],
	      "file:/orangef/selfcare_long/opt_ow_10E_mobi.xml#success"}
	    ],
	    activation = auto,
	    level      = user};

param_info(callback_mobi_sc) ->
    #param_info{
	    type       = string,
	    name       = "Code de service Mobi callback",
	    help       = "Code de service envoyé dans la requête USSD"
	    "pour les clients Mobicarte",
	    example    =  "#123",
	    activation = auto,
	    level      = user};

param_info(callback_cmo_sc) ->
    #param_info{
	    type       = string,
	    name       = "Code de service CMO callback",
	    help       = "Code de service envoyé dans la requête USSD"
	    "pour les clients CMO",
	    example    =  "#124",
	    activation = auto,
	    level      = user};

param_info(callback_itf) ->
    #param_info{
	    type       = {list,{tuple,"Callback Interfaces",
				[{"Name",atom},{"Node",atom}]}},
	    name       = "Interfaces Callback",
	    help       = "Nom des interfaces vers Cellgate/PRISM",
	    example    =  "[{io_ussd_cellgate:0,possum@localhost}]",
	    activation = auto,
	    level      = user};
param_info(tac_list) ->
    #param_info{
	    type       = {print_raw,{list,int}},
	    name       = "Tac des mobiles unik",
	    help       = "Liste des Tac des mobiles adaptes a option unik",
	    example    = "",
	    activation = auto,
	    level      = user};
param_info(tac_list_postpaid) ->
    #param_info{
            type       = {print_raw,{list,int}},
            name       = "Tac des mobiles unik",
            help       = "Liste des Tac des mobiles adaptes a option unik pour postpaye",
            example    = "",
            activation = auto,
            level      = user};

param_info(callback_timeout) ->
    #param_info{
	    type       = int,
	    name       = "Timeout Callback",
	    help       = "Temsp d'attente d'une réponse de PRISM",
	    example    =  "10000",
	    activation = auto,
	    level      = user}; 

param_info(roaming_camel_codes) ->
    #param_info{
	    type       = {print_raw,{list,string}},
	    name       = "Codes camel en roaming",
	    help       = "Liste des préfixes de VLRs Camel",
	    example    =  "",
	    activation = auto,
	    level      = user};

param_info(roaming_ansi_codes) ->
    #param_info{
	    type       = {print_raw,{list,string}},
	    name       = "Codes ANSI en roaming",
	    help       = "Liste des préfixes de VLRs ANSI",
	    example    =  "",
	    activation = auto,
	    level      = user};

param_info(vlr_prefixes_direct_callback) ->
    #param_info{
            type       = {print_raw,{list,string}},
            name       = "Codes direct callback en roaming",
            help       = "Liste des prefixes de VLRs direct callback",
            example    =  "",
            activation = auto,
            level      = user};

param_info(recharge_cb_cmo_mini) ->
    #param_info
	    {type = currency(),
	     name = "Rechargement Mobi CB minimum authorisé",
	     help = "",
	     example = {euro,10.0},
	     activation = auto,
	     level = user};
param_info(recharge_cb_mobi_mini) ->
    #param_info
	    {type = currency(),
	     name = "Rechargement Mobi CB minimum authorisé",
	     help = "",
	     example = {euro,10.0},
	     activation = auto,
	     level = user};

param_info(rech_cb_mobi_type_ident) ->
    #param_info
	    {type = {enum, [{rcod,"RCOD"},{ident40,"IDENT40"}]},
	     name = "Choix requête d'identification",
	     help = "rcod => rcm_sda.pgi (RC25) \n"
	     "ident40 => rcm_ident40.pgi",
	     example = rcod,
	     activation = auto,
	     level = user};
param_info(rech_cb_mobi_controle_plf) ->
    #param_info
	    {type = bool,
	     name = "Authorise le controle du plafond ou non",
	     help = "true-> Active le controle du plafond",
	     example = true,
	     activation = auto,
	     level = user};
param_info(recharge_dcl_interdit)->
    (#param_info
     {type = {list, int},
      name = "Listes des declinaisons interdites au rechargement",
      help = "",
      example = [34, 35],
      activation = auto,
      level = install});

param_info(dcl_eligible_offrir_credit)->
    (#param_info
     {type = {list, int},
      name = "Listes des declinaisons eligibles a offrir du credit",
      help = "",
      example = [0, 34, 35],
      activation = auto,
      level = install});

param_info(alarm_class_rech_cb) ->
    #param_info
	    {type = {enum, [{warning,"No alarm"},{failure,"Failure"}]},
	     name = "Type de Class d'alarm por le service Rech CB MOBI",
	     help = "",
	     example = failure,
	     activation = auto,
	     level = user};

param_info(list_rechargeU_cb)->
    #param_info
	    {type={list, {tuple, "SAISIE MONTANT",
			  [{"MONTANT en euro ",int},{"BONUS en euro",int},
			   {"Date de validite",string}]}},
	     name = "Lists des montant, bonus et date de validite",
	     help = "",
	     example = [{5,0,"7 jours"},
			{10,0,"15 jours"},
			{15,0,"1 mois"},
			{25,5,"2 mois"},
			{35,10,"3 mois"}],
	     activation = auto,
	     level = user};
param_info(list_montant_rech_cb_mobi)->
    #param_info
	    {type={list, {tuple, "SAISIE MONTANT",
			  [{"MONTANT en euro ",int},{"BONUS en euro",int},
			   {"Date de validite",string}]}},
	     name = "Lists des montant, bonus et date de validite",
	     help = "",
	     example = [{10,0,"15 jours"},
			{20,0,"2 mois"},
			{30,5,"3 mois"},
			{40,10,"3 mois"},
			{50,15,"4 mois"}],
	     activation = auto,
	     level = user};
param_info(X) when X==calend_avant_cmo;X==calend_avant ->
    #param_info
					    {type= {print_raw,{list, {tuple, "Period/OPT/URL", 
								      [{"Period",period_of_day()},{"Option",atom},
								       {"URL",string}]}}}, 
					     name = "Calendrier de l'avant",
					     help = "",
					     example = [],
					     activation = auto,
					     level = user};
param_info(X) when X==subscription_price_cmo;
		   X==subscription_price_mobi->
    #param_info
			{type= {list, {tuple, "Id Option/Prix", 
				       [{"Id Option",atom},{"Prix en milliemes d'euros",int}]}}, 
			 name = "Prix à la souscription f(option)",
			 help = "Prix pour chaque option=> utiliser lors des controle de prix et dans les"
			 "requête de soucription",
			 example = [{opt_example,1000}],
			 activation = auto,
			 level = user};
param_info(opt_cpt_mnt_initial)->
    #param_info
	    {type= {list, {tuple, "Id Option/Prix", 
			   [{"Id Option",atom},{"Prix en milliemes d'euros",int}]}}, 
	     name = "Montant initial du godet lors de la souscription f(option)",
	     help = "Montant a préciser dans la requete OPT_CPT lorsqu'il est diffrent du prix de la souscription",
	     example = [{opt_example,1000}],
	     activation = auto,
	     level = user};
param_info(plage_horaire) ->
    #param_info
	    {type= {print_raw,{list, {tuple, "Id Option/Horaire fermeture", 
				      [{"Id Option",atom},
				       {"List de plage horaire",
					{list, type_plage_dow()}
				       }]}
			      }}, 
	     name = "Fermeture souscription d'option",
	     help = "Chaque service de souscription peut etre ferme par plage horaire",
	     example = [{opt_example,[{{1,0,0},{2,0,0}}]}],
	     activation = auto,
	     level = user};
param_info(X) when X==commercial_date;
		   X==commercial_date_cmo;
		   X==commercial_date_dme;
		   X==commercial_date_postpaid;
		   X==commercial_date_carrefour_pp;
		   X==commercial_date_monacell_pp;
		   X==commercial_date_virgin_pp;
		   X==commercial_date_virgin_cb;
		   X==commercial_date_tele2_pp;
		   X==commercial_date_tele2_cb;
		   X==commercial_date_wap_push;
		   X==list_bank_holidays;
		   X==commercial_date_monacell_pp->
    #param_info{type = 
		{print_raw,
		 {list, {tuple, "Id Option/Dates commercialisation", 
			 [{"Id Option",atom},
			  {"Liste de plages journalieres",type_list_plages()}
			 ]}
		 }}, 
		name = "Date d'ouverture de chaque option",
		help = "Periode d'ouverture commercial pour chaque option\n"
		"Hors periode les liens lie a ces options ne sont pas presente au client",
		example = [{opt_example,[{{{1,1,2005},{0,0,0}},{{2,2,2005},{0,0,0}}}]}],
		activation = auto,
		level = user};
param_info(asmetier_opt_cmo) ->
    #param_info
	    {type= {list, {tuple, "OPTION / CODE / ACTION", [{"Id Option",atom},{"Code",string},{"Action",atom}]}},
	     name = "Correspondance Option - Code AS Metier",
	     help = "Liste des options dont la souscripion ou la suppression se fait par l'AS Metier, des codes AS Metier correspondants et l'action pour des options",
	     example = [{opt_example,"CODE",subscribe}],
	     activation = auto,
	     level = user};
param_info(asmetier_opt_postpaid) ->
    #param_info
	    {type= {list, {tuple, "OPTION / CODE / ACTION", [{"Id Option",atom},{"Code",string},{"Action",atom}]}},
	     name = "Correspondance Option - Code option AS Metier",
	     help = "Liste des options dont la souscripion ou la suppression se fait par l'AS Metier, des codes AS Metier correspondants et l'action pour des options",
	     example = [{opt_example,"CODE",subscribe}],
	     activation = auto,
	     level = user};
param_info(asmetier_so_incomp_cmo) ->
    #param_info
	    {type= {list, {tuple, "SO INCOMPATIBLES CODE/LIBELLE", [{"Code",string},{"Libelle",string}]}},
	     name = "Correspondance Code option resiliee AS Metier - libelle option resiliee",
	     help = "Liste des codes options incompatibles envoyes par l'AS Metier et des libelles"
	     " correspondants",
	     example = [{"CODE","LIBELLE"}],
	     activation = auto,
	     level = user};
param_info(asmetier_so_incomp_postpaid) ->
    #param_info
	    {type= {list, {tuple, "SO INCOMPATIBLES CODE/LIBELLE", [{"Code",string},{"Libelle",string}]}},
	     name = "Correspondance Code option AS Metier - libelle option",
	     help = "Liste des codes options incompatibles envoyes par l'AS Metier et des libelles"
	     " correspondants",
	     example = [{"CODE","LIBELLE"}],
	     activation = auto,
	     level = user};
param_info(asmetier_verif_subscr_postpaid) ->
    (#param_info
     {type = bool,
      name = "Verification souscription (postpaid)",
      help = " Si true, l'AS Metier verifie au prealable si la souscription du service optionnel est rendue possible par l'offre type actuelle du dossier.",
      example = true,
      activation = auto,
      level = user
     });
param_info(asmetier_verif_subscr_cmo) ->
    (#param_info
     {type = bool,
      name = "Verification souscription (cmo)",
      help = " Si true, l'AS Metier verifie au prealable si la souscription du service optionnel est rendue possible par l'offre type actuelle du dossier.",
      example = true,
      activation = auto,
      level = user
     });
param_info(opt_commercial_name_postpaid) ->
    #param_info
	    {type= {list, {tuple, "OPTION / LIBELLE", [{"Id Option",atom},{"Libelle",string}]}},
	     name = "Correspondance Option Postpaid - libelle option",
	     help = "Liste des options postpaid pour la restitution",
	     example = [{opt_example,"Libelle"}],
	     activation = auto,
	     level = user};
param_info(opt_commercial_name_mobi) ->
    #param_info
	    {type= {list, {tuple, "OPTION / LIBELLE", [{"Id Option",atom},{"Libelle",string}]}},
	     name = "Correspondance Option Mobi - libelle option",
	     help = "Liste des options mobi pour la restitution",
	     example = [{opt_example,"Libelle"}],
	     activation = auto,
	     level = user};
param_info(opt_commercial_name_cmo) ->
    #param_info
	    {type= {list, {tuple, "OPTION / LIBELLE", [{"Id Option",atom},{"Libelle",string}]}},
	     name = "Correspondance Option CMO - libelle option",
	     help = "Liste des options CMO pour la restitution",
	     example = [{opt_example,"Libelle"}],
	     activation = auto,
	     level = user};
param_info(code_opt_visio) ->
    (#param_info
     {type = string,
      name = "Code Service Optionnel ADV Visio",
      help = "",
      example = "CODE",
      activation = auto,
      level = user
     });
param_info(code_act_visio) ->
    (#param_info
     {type = string,
      name = "Code prestation Visio active",
      help = "",
      example = "CODE",
      activation = auto,
      level = user
     });
param_info(class_smsinfos_timeout) ->
    #param_info
	    {type = {enum, [{warning,"No alarm"},{failure,"Failure"}]},
	     name = "Type de Class d'alarm en cas de timeout SMSINFOS",
	     help = "",
	     example = failure,
	     activation = auto,
	     level = user};
param_info(ocf_failure_class) ->
    #param_info
	    {type = {enum, [{warning,"No alarm"},{failure,"Failure"}]},
	     name = "Type de Class d'alarm en cas d'erreur OCF/RDP",
	     help = "",
	     example = failure,
	     activation = auto,
	     level = user};
param_info(mobi_max_cmb) ->
    (#param_info
     {type = int,
      name = "Nb de CMB maximum autorise pour les Mobicartes",
      help = "Un nombre nul ou négatif empeche tout envoi de CMB",
      example = 15,
      activation = auto,
      level = user,
      related = [ cmo_max_cmb ]
     });
param_info(cmo_max_cmb) ->
    (#param_info
     {type = int,
      name = "Nb de CMB maximum autorise pour les CMO forfait",
      help = "Un nombre nul ou négatif empeche tout envoi de CMB",
      example = 10,
      activation = auto,
      level = user,
      related = [ mobi_max_cmb ]
     });
param_info(cmb_to_orange) ->
    (#param_info
     {type = string,
      name = "Message du SMS à destination des clients Orange France",
      help = "le \~s est remplacé par le msisdn de l'émetteur du CMB",
      example = 'Le ~s cherche a  vous joindre et souhaiterait que vous le rappeliez. Merci',
      activation = auto,
      level = user,
      related = [ cmb_to_cvf ]
     });
param_info(cmb_to_cvf) ->
    (#param_info
     {type = string,
      name = "Message du SMS à destination des NON abonnes Orange France",
      help = "le \~s est remplacé par le msisdn de l'émetteur du CMB",
      example = 'Le ~s cherche a  vous joindre et souhaiterait que vous le rappeliez. Merci',
      activation = auto,
      level = user,
      related = [ cmb_to_orange ]
     });
param_info(cmb_cvf_routing) ->
    (#param_info
     {type = string,
      name = "Clé utilisée pour le routage des SMS à destination des "
      "NON abonnes Orange France",
      help = "Modifier en fonction des routages existants dans pdist<br>"
      "see pdist::sms_routing",
      example = "cvf_98765",
      activation = auto,
      level = install
     });
param_info(users_orangef_extra_routing) ->
    (#param_info
     {type = string,
      name = "label utilise pour le routage des requ�tes vers la table users_orangef_extra",
      help = "Modifier en fonction des routages existants dans pdist<br>"
      "see pdist::sql_routing",
      example = "users",
      activation = auto,
      level = install
     });

param_info(recharge_moi_periodes_glissantes) ->
    PeriodType =
	{tuple, "valeur, unité",
	 [{"valeur", {int, [{ge, 0}]}},
	  {"unité", {enum, [days, hours, minutes, seconds]}}]},
    (#param_info
     {type = {list, {tuple, "nombre d'utilisations, période",
		     [{"nombre d'utilisations", {int, [{ge, 0}]}},
		      {"période", PeriodType}]}},
      name = "Périodes glissantes pour \"Recharge-moi\"",
      help = "Limitations du nombre d'utilisations du service \"Recharge-moi\" "
      "par périodes glissantes. Doit être non vide. Dans l'exemple, il ne sera "
      "pas possible pour un client d'utiliser le service plus de 5 fois sur "
      "une période glissante de 30 jours et plus d'une fois sur une période "
      "glissante d'une heure.",
      example = [{5, {30, days}}, {1, {1, hours}}],
      activation = auto,
      level = install});
param_info(dcl_filter_options) ->
    (#param_info
     {type = {list, {tuple, "declinaison filtrees par options",
		     [{"option", {defval,"opt_zap_zone",string}},
		      {"declinaison", {print_raw, {list, int}}}]}},
      name = "Listes des declinaisons filtrees pour une options",
      help = "Les declinaisons appartenant à la liste n'ont pas accès à l'option",
      example = [{"opt_zap_zone", [34,35]}],
      activation = auto,
      level = install});
param_info(recharge_moi_texte) ->
    (#param_info
     {type = string,
      name = "Corps du SMS",
      help = "Doit contenir une unique occurrence de \"~s\" qui sera remplacée "
      "par le MSISDN du client USSD. Toute autre séquence de formatage est "
      "proscrite.",
      example = "Le ~s souhaite que vous rechargiez son compte !",
      activation = auto,
      level = user,
      related = []});
param_info(recharge_moi_solde_max) ->
    (#param_info
     {type = currency(),
      name = "Solde maximum pour accéder à \"Recharge-moi\"",
      help = "L'accès au service \"Recharge-moi\" n'est accordé que lorsque "
      "le solde du client est sous ce seuil.",
      example = {euro, 1.0},
      activation = auto,
      level = install});
param_info(recharge_moi_cvf_routing) ->
    (#param_info
     {type = string,
      name = "Attribut de routage des SMS à destination des "
      "abonnés non Orange France",
      help = "Modifier en fonction des routages existants dans pdist",
      example = "cvf_98765",
      activation = auto,
      level = install,
      related = [{pdist, sms_routing}]});

param_info(sms_preetabli_texte) ->
    (#param_info
     {type = string,
      name = "Texte du SMS",
      help = "Doit contenir 3 occurrences de \"~s\" qui seront remplacées par le Nom, " 
      "le Prenom et le MSISDN du client USSD. Toute autre séquence de formatage est proscrite.",
      example = "~s ~s ~s vous informe de son nouveau numero:~s",
      activation = auto,
      level = user,
      related = []});
param_info(max_sms_preetabli) ->
    (#param_info
     {type = int,
      name = "Nombre maximum de SMS autorisés",
      help = "L'envoi du SMS n'est pas accordé au déla de ce seuil.",
      example = 10,
      activation = auto,
      level = install});
param_info(sms_preetabli_routing) ->
    (#param_info
     {type = atom,
      name = "Attribut de routage des SMS à destination des abonnés Orange France",
      help = "Modifier en fonction des routages existants dans pdist",
      example = "default",
      activation = auto,
      level = install,
      related = [{pdist, sms_routing}]});

param_info(sms_preetabli_cvf_routing) ->
    (#param_info
     {type = string,
      name = "Attribut de routage des SMS à destination des "
      "abonnés non Orange France",
      help = "Modifier en fonction des routages existants dans pdist",
      example = "cvf_98765",
      activation = auto,
      level = install,
      related = [{pdist, sms_routing}]});

param_info(offres_eXclusives) ->
    #param_info{
            type       = atom,
            name       = "Paramètre d'activations des offres eXclusives",
            help       = "Ce paramètre permet l'activation ou non du lien vers les offres eXclusives",
            example    =  "true ou false",
            activation = auto};

param_info(prisme_cfg) ->
    #param_info{type= prisme_dump:type_prisme_cfg(),
		name="Configuration Prisme",
		help="",
		example="",
		activation=auto};

param_info(spider_postpaid_table) ->
    (#param_info
     {type = {list, type_restit_cfg()},
      name = "Table de restitution des unités pour les postpaid",
      help = "Cette table établit la correspondance entre "
      "l'unité d'un crédit renvoyée par SPIDER et "
      "l'unité à restituer dans tous les scripts de suivi conso "
      "postpaid",
      example = "",
      activation = auto});

param_info(spider_dme_table) ->
    (#param_info
     {type = {list, type_restit_cfg()},
      name = "Table de restitution des unités pour les dme",
      help = "Cette table établit la correspondance entre "
      "l'unité d'un crédit renvoyée par SPIDER et "
      "l'unité à restituer dans tous les scripts de suivi conso "
      "dme",
      example = "",
      activation = auto});

param_info(spider_table) ->
    (#param_info
     {type = {list, type_restit_cfg()},
      name = "Table de restitution des unités pour le suivi conso "
      "SPIDER",
      help = "Cette table établit la correspondance entre "
      "l'unité d'un crédit renvoyée par SPIDER et "
      "l'unité à restituer dans tous les scripts de suivi conso",
      example = "",
      activation = auto});

param_info(spider_infos_comp) ->
    MessageType =
	{list, {tuple, "Message/niveau ussd",
		[{"Niveau", int},
		 {"Message", string}]}},
    (#param_info
     {type = {list, {tuple,"Info compl&eacute;mentaire Godet",
                     [{"code renvoy&eacute; par SPIDER", string},
		      {"Message associ&eacute;", MessageType}]}},
      name = "Complement Information for Spider Selfcare",
      help = "Correspondance Table between number in Spider Response and string to display - THIS TABLE IS CHANGE BY ORANGE FRANGE",
      example = "",
      activation = auto});

param_info(codeOffre_codeDomaine_souscription_packageOTO) ->
    (#param_info
     {type = {list, {tuple,"CodeOffer/CodeDomaine/Souscription/PackageOTO",
                     [{"CodeOffer", string},
		      {"CodeDomaine", string},
		      {"Souscription", string},
		      {"PackageOTO", string}]}},
      name = "Table de correspondance Code Offre - Code Domaine - Souscription - Package OTO",
      help = "no help available",
      example = "",
      activation = auto});

param_info(recharge_tele2) ->
    (#param_info
     {type = type_recharge_tele2(),
      name = "Config Service de rechargement Tele2",
      help = "Permet de configurer le nombre de retentative,"
      "la liste des montant disponible, le timer de la requête de rechargement"
      "ainsi que l'attribut de routage http à utiliser pour les requêtes",
      example = {recharge_cfg,[
			       {tentative,3},
			       {liste_montant, [{15000,1500},{25000,5000},{35000,15000},
						{50000,22500},{75000,37500}]},
			       {url,"/refill.cgi"},
			       {host,"tele2.com"},
			       {port,80},
			       {origine,"Prod"},
			       {timeout,5000},
			       {routing,default}]},
      activation=auto});

param_info(catalogue_parentChild) ->
    #param_info{type = svc_parentChild:type_catalogue(),
		name = "Config Bonus ParentChild",
		help = "Restitution des bonus ParentChild",
		example = [],
		activation=auto};

param_info(spider_prepaid_cmo) ->
    (#param_info
     {type = {alt, [{false, {const, false}},
		    {true, {tuple, "", [{"", {const, true}},
					{"Pourcentage", {defval, 0, int}}]}}]},
      name = "Define if the CMO client use Spider for Selfcare",
      help = "",
      example = {true, 50},
      activation = auto,
      level = install
     });

param_info(spider_prepaid_mobi) ->
    (#param_info
     {type = {alt, [{false, {const, false}},
		    {true, {tuple, "", [{"", {const, true}},
					{"Pourcentage", {defval, 0, int}}]}}]},
      name = "Define if the Mobicarte client use Spider for Selfcare",
      help = "",
      example = {true, 50},
      activation = auto,
      level = install
     });

param_info(spider_url_service_indisponible) ->
    (#param_info
     {type = string,
      name = "Spider unavailable service",
      help = "URL return when Spider is unavailble - Spider error Code '02' or no_resp",
      example = "/orangef/home.xml#spider_service_indisponible",
      activation = auto,
      level = install
     });
param_info(spider_url_acces_refuse) ->
    (#param_info
     {type = string,
      name = "Spider unavailable service",
      help = "URL return when Spider returns Error code '03'",
      example = "/orangef/home.xml#spider_acces_refuse",
      activation = auto,
      level = install
     });
param_info(spider_url_probleme_technique) ->
    (#param_info
     {type = string,
      name = "Spider unavailable service",
      help = "URL return when Spider returns Error code '04'",
      example = "/orangef/home.xml#spider_probleme_technique",
      activation = auto,
      level = install
     });
param_info(spider_url_dossier_inconnu) ->
    (#param_info
     {type = string,
      name = "Spider unavailable service",
      help = "URL return when Spider returns Error code '05'",
      example = "/orangef/home.xml#spider_dossier_inconnu",
      activation = auto,
      level = install
     });   
param_info(recharge_moi_texte_dest_of) ->
    (#param_info
     {type = string,
      name = "Corps du SMS envoyé par le service recharge moi lorsque "
      "le destinataire est un client Orange",
      help = "Doit contenir une unique occurrence de \"~s\" qui sera remplacée "
      "par le MSISDN du client USSD. Toute autre séquence de formatage est "
      "proscrite.",
      example = "Le ~s souhaite que vous rechargiez son compte !",
      activation = auto,
      level = user,
      related = []});

param_info(recharge_moi_texte_dest_not_of) ->
    (#param_info
     {type = string,
      name = "Corps du SMS envoyé par le service recharge moi lorsque "
      "le destinataire n'est pas un client Orange",
      help = "Doit contenir une unique occurrence de \"~s\" qui sera remplacée "
      "par le MSISDN du client USSD. Toute autre séquence de formatage est "
      "proscrite.",
      example = "Le ~s souhaite que vous rechargiez son compte !",
      activation = auto,
      level = user,
      related = []});

param_info(recharge_me_black_list_name) ->
    (#param_info
     {type = atom,
      name = "Nom de la black list (acl mnesia) du service recharge_moi",
      help = "",
      example = recharge_me_black_list,
      activation = auto,
      level = user,
      related = []});

param_info(call_me_back_black_list_name) ->
    (#param_info
     {type = atom,
      name = "Nom de la black list (acl mnesia) du service call_me_back",
      help = "",
      example = call_me_back_black_list,
      activation = auto,
      level = user,
      related = []});

param_info(restit_options_mobi)->
    (#param_info
     {type = {print_raw, {list, atom}},
      name = "Listes des options",
      help = "Service SV Option: permet de dÃ©finir la liste des "
      "options Ã  restituer",
      example = [opt_weinf,opt_jinf],
      activation = auto,
      level = install});

param_info(opt_promo_mobi)->
    (#param_info
     {type = {list, {tuple, "OPTION / Prix",[{"Id Option",atom},{"Prix en milliemes d'euros",string}]}},
      name = "Listes des options en promotion",
      help = "Service Souscription d'Options: permet de definir la liste des "
      "options en promo",
      example = [{opt_weinf,"1000"},{opt_jinf,"-"}],
      activation = auto,
      level = user});
param_info(opt_promo_click)->
    (#param_info
     {type = {list, {tuple, "OPTION / Prix",[{"Id Option",atom},{"Prix en milliemes d'euros",string}]}},
      name = "Listes des options click en promotion",
      help = "Service Souscription d'Options: permet de definir la liste des "
      "options click en promo",
      example = [{opt_weinf,"1000"},{opt_jinf,"-"}],
      activation = auto,
      level = user});
param_info(opt_promo_foot)->
    (#param_info
     {type = {list, {tuple, "OPTION / Prix",[{"Id Option",atom},{"Prix en milliemes d'euros",string}]}},
      name = "Listes des options foot en promotion",
      help = "Service Souscription d'Options: permet de definir la liste des "
      "options foot en promo",
      example = [{opt_weinf,"1000"},{opt_jinf,"-"}],
      activation = auto,
      level = user});
param_info(opt_promo_m6)->
    (#param_info
     {type = {list, {tuple, "OPTION / Prix",[{"Id Option",atom},{"Prix en milliemes d'euros",string}]}},
      name = "Listes des options M6 en promotion",
      help = "Service Souscription d'Options: permet de definir la liste des "
      "options M6 en promo",
      example = [{opt_weinf,"1000"},{opt_jinf,"-"}],
      activation = auto,
      level = user});

param_info(call_me_back_routing) ->
    (#param_info
     {type = atom,
      name = "Clé utilisée pour le routage des SMS lors de l'envoi d'un "
      "SMS Call Me Back",
      help = "Modifier en fonction des routages existants dans pdist",
      example = call_me_back,
      activation = auto,
      level = install,
      related = [{pdist, sms_routing}]
     });

param_info(routing_prefix_recharge_moi) ->
    #param_info{
	    type = string,
	    name = "Prefix of routing label to SMSC interface",
	    help = "This prefix is added to the default routing label used by sms_router\n"
	    "Currently this prefix is the short code used to access SMSC",
	    example = "20565",
	    activation = auto,
	    related = [{pdist, sms_routing}]};

param_info(routing_prefix_call_me_back) ->
    #param_info{
	    type = string,
	    name = "Prefix of routing label to SMSC interface",
	    help = "This prefix is added to the default routing label used by sms_router\n"
	    "Currently this prefix is the short code used to access SMSC",
	    example = "20432",
	    activation = auto,
	    related = [{pdist, sms_routing}]};

param_info(recharge_moi_routing) ->
    (#param_info
     {type = atom,
      name = "Clé utilisée pour le routage des SMS lors de l'envoi d'un "
      "SMS Recharge Moi",
      help = "Modifier en fonction des routages existants dans pdist",
      example = recharge_moi,
      activation = auto,
      level = install,
      related = [{pdist, sms_routing}]
     });

param_info(wap_push_routing) ->
    (#param_info
     {type = atom,
      name = "Clé utilisée pour le routage des SMS lors de l'envoi d'un "
      "WAP PUSH",
      help = "Modifier en fonction des routages existants dans pdist",
      example = wap_push,
      activation = auto,
      level = install,
      related = [{pdist, sms_routing}]
     });

param_info(m5_horaire_ouverture) ->
    #param_info{
	    type= {list, {tuple,"M5 Horaires d'ouverture",
			  [{"Souscription",atom},
			   {"Ouverture",time_of_day()},
			   {"Fermeture",time_of_day()}]
			 }},
	    name = "M5 Horaire d'ouverture du service",
	    help = "Pour une indisponibilite totale, definir Debut = Fin",
	    example =[{cmo,{8,0,0},{23,59,59}},
		      {postpaid_gp,{8,0,0},{23,59,59}},
		      {postpaid_pro,{8,0,0},{23,59,59}}],
	    activation = auto,
	    level = user};

param_info(m5_present_names) ->
    #param_info{
	    type= {list, {tuple, "M5 id libellé",
			  [{"idRecompense",string},
			   {"idInterne",string},
			   {"Libelle",string}]}},
	    name = "M5: correspondance idRecompense OPAL -> libellé USSD",
	    help = "Liste des libelles courts USSD des récompense M5, en"
	    " fonction de l'identifiant retourné par OPAL.\n"
	    "L'identité interne est utilisée pour la correspondance"
	    " Libellé - Descriptif",
	    example = [{"40","1","30min com fixe+mobOrange"}],
	    activation = auto,
	    level = user};

param_info(cmo_menu_without_spider) ->
    #param_info{
	    type       = bool,
	    name       = "Menu #123# CMO available",
	    help       = "Define if Main menu is available, with the bad Spider response - ONLY PREPROD",
	    example    = false,
	    activation = auto,
	    level      = install};
param_info(mobi_menu_without_spider) ->
    #param_info{
	    type       = bool,
	    name       = "Menu #123# Mobi available",
	    help       = "Define if Main menu is available, with the bad Spider response - ONLY PREPROD",
	    example    = false,
	    activation = auto,
	    level      = install};
param_info(redirect_mobicarte) ->
    #param_info{
	    type       = {list, {tuple, "Config Declinaison", [{"Plate-forme",atom},
							       {"Config",{list, {tuple, "Id/Declinaison", [{"Id Platform",string},{"Declinaison",atom}]}}}]}},
	    name       = "Declinaison Mobicarte",
	    help       = "Definit les déclinaison mobicarte (Mobicarte/Foot/click/m6) en fonction des information Spider ou Sachem",
	    example    = [{spider,[ {"MOB", mobicarte} , {"M6P", m6}]},{sachem,[]}],
	    activation = auto,
	    level      = install};
param_info(day_off) ->
        #param_info
	    {type={list, {tuple, "JOURS FERIES",
			  [{"Annee",int},{"Mois",int},
			   {"jour",int}]}},
	     name = "Liste des jours feriees",
	     help = "",
	     example = [{2008,01,01}],
	     activation = auto,
	     level = user};
param_info(store_commercial_segment) ->
        #param_info
	    {
	    type       = bool,
	    name       = "Stockage de la valeur segment commercial",
	    help       = "Definit si le segment commerciale doit etre stocke en base, depend de l'existant de la colonne commercial_segment dans la table users_orangef_extra",
	    example    = false,
	    activation = auto,
	    level      = install};
param_info(access_services) ->
        #param_info
	    {
	    type       = type_access_service(),
	    name       = "association code de service / souscription",
	    help       = "liste des souscriptions ayant acces aux differents codes de services",
	    example    = [{"#123",[mobi,cmo,postpaid,dme]},
			  {"*144",[carrefour_prepaid,carrefour_comptebloq]}],
	    activation = auto,
	    level      = install};
param_info(janus_files_location) ->
	(#param_info
     {type = string,
      name = "File location",
      help = "Location to store file of mobicarte client migrating to Janus",
      example = "/home/clcm/",
      activation = auto,
      level = install});

param_info(segCo_offre_postpaid) ->
    #param_info
	    {type       = {print_raw,{list,string}},
	     name       = "Segment Commercial pour les clients postpaid",
	     help       = "Segment Commercial pour les clients postpaid utilise pour XXXX",
	     example    =  "F1ACM",
	     activation = auto,
	     level      = user};

param_info(segCo_autorise_offrir_credit)->
    #param_info
	    {type = {print_raw,{list,string}},
	     name = "Segment Commercial for the clients authorised with offer of credit",
	     help = "Segment Commercial for the clients authorised with offer of credit",
	     example = "CPP01",
	     activation = auto,
	     level = user};

param_info(subscription_mvno)->
    #param_info
	    {type = {print_raw,{list,atom}},
	     name = "Subscription of MVNO clients",
	     help = "Subscription of MVNO clients",
	     example = virgin_prepaid,
	     activation = auto,
	     level = user};

param_info(dcl_internet_everywhere)->
    #param_info
	    {type = {list, int},
	     name = "List of the declinaisons for the clients of internet everywhere",
	     help = "List of the declinaisons for the clients of internet everywhere",
	     example = [120,124,138,139,140,141,142,143],
	     activation = auto,
	     level = install};

param_info(nb_tentative) ->
    (#param_info
     {type = int,
      name = "Nombre de tentative",
      help="Number of trying to query OCF in failure",
      example = 3,
      activation = auto,
      level = install
     }).

type_access_service() ->
     {list, {tuple, "autorisations", 
	     [{"code",string},
	      {"souscriptions",
	       {list,{enum,[all_and_anon]++?ALL_SUBSCRIPTIONS}}}]}}.
    

type_plage_dow() ->
    {alt,
     [{'Independant des jours de la semaine', type_plage_horaire()},
      {'Fonction des jours de la semaine', type_plage_horaire_fct_jours()}]}.

type_plage_horaire_fct_jours() ->
    {tuple, "", [{"Debut", {defval,{0,0,0}, time_of_day()}},
 		 {"Fin", {defval,{23,59,59}, time_of_day()}},
		 {"Liste des jours de la semaine",type_list_of_days()}]}.

type_plage_horaire() ->
    {tuple, "", [{"Debut", {defval,{0,0,0}, time_of_day()}},
 		 {"Fin", {defval,{23,59,59}, time_of_day()}}]}.

type_list_of_days() ->
    {list, type_day()}.

type_day() ->
    {enum, lists:map(fun dow_int2atom/1, lists:seq(1,7))}.

type_list_plages() ->
     {list, {tuple, "Debut/Fin", 
	     [{"Debut",day_and_time()},
	      {"Fin",day_and_time()}]}}.

dow_int2atom(Int) -> svc_util_of:dow_int2atom(Int).

%% +type currency() -> type_expr().
currency()->
    Monnaie={enum,[{frf,"frf"},{euro,"euro"}]},
    Price=float,
    {tuple, "Price", [{"Currency",Monnaie},{"Prix",Price}]}.

%% +type weekday(atom()) -> type_expr().
weekday(Day) ->			   
    {tuple,"Jour de la semaine",
     [{"Jour",{const,Day}}, 
      {"Activation/Horaires",{tuple,"Day Schedule",
			      [{"activation",{enum, [on,off]}},
			       {"ouverture",time_of_day()},
			       {"fermeture",time_of_day()}]
			     }}
     ]}.

%% +type time_of_day() -> type_expr(). 
time_of_day()->
    {tuple, "Horaire", [{"heure",{int, [ {ge, 0}, {le,23} ]}},
			{"minute",{int, [ {ge, 0}, {le,59} ]}},
			{"seconde",{int, [ {ge, 0}, {le,59} ]}}]}.

percentage()->
    {int,[{ge,0},{le,100}]}.


day()->
    {tuple, "Jour du mois", [{"Annee", {int, [ {ge,2004}, {le,2099} ]}},
			 {"Mois",  {int, [ {ge,1}, {le,12} ]} },
			 {"Jour",  {int, [ {ge,1}, {le,31} ]} }]}.

day_and_time()->
    {tuple, "Jour/Heure", [{"Jour", day()},{"Heure",time_of_day()}]}.

period_of_day()->
    {tuple, "Debut/Fin", [{"Debut",day_and_time()},
			  {"Fin",day_and_time()}]}.

type_restit_cfg() ->
    {record, "Config Restitution", unite, 
     [{nom, string, "Nom de l'unit&eacute; retourn&eacute; par SPIDER"},
      {libelle, string, "Libell&eacute; &agrave; restituer"}]}.

type_recharge_tele2() ->
    Fields = record_info(fields, recharge_tele2_cfg),
    {ok, {recharge_tele2_cfg,DefaultPairs}} =
	application:get_env(pservices_orangef, recharge_tele2),
    Default = oma_util:pairs_to_record(#recharge_tele2_cfg{}, 
				       Fields, DefaultPairs),
    {pairs, Default, Fields, {defval,Default,type_rech_tele2_cfg()}}.

type_rech_tele2_cfg() ->
    Route ={enum,plugin:get_routing_attr(httpclient_routing)},
    Fields =
	[ {"tentative",   {int, [ {ge,1}, {le,10} ]}},
	  {"listes des Montants et Bonus (millieme d'euros)", 
	   {list, {tuple, "Montant/Bonus" , [{"Montant",int},{"Bonus",int}]}}},
	  {"URL", string},
	  {"Host",string},
	  {"port",int},
	  {"origine", {enum, ["Prod","Preprod"]}},
	  {"Timeout (ms)",  int},
	  {"Routing Attribute",       Route}
	 ],
    {named_type,"Recharge Tele2 PP Config",
     {record, "Recharge Tele2", recharge_tele2_cfg, Fields}}.

