-module(svc_of_plugins).

%% XML export

-export([proposer_lien/6,
	 proposer_lien/5,%%Obsolete
	 proposer_lien_autres_option/4,
	 proposer_lien_si_active/6,
	 proposer_lien_si_non_active/6,
	 prososer_lien_decouv_zap_zone/5,
	 proposer_lien_by_variable_foot_X/8,
	 proposer_lien_options_et_bons_plans/4,
	 proposer_lien_zone_academique/5,
	 print_commercial_start_date/3,
	 print_commercial_end_date/3,
	 print_option_price/3,
	 print_next_weekend_date/2,
	 print_date_end_opt/2,
	 init_postpaid_svc_data/2,
	 redirect_by_postpaid_segCo/3,
	 track_kenobi_code/2,
	 track_kenobi_code/3,
	 print_incomp_opts/2,
	 print_end_credit/2,
	 print_end_credit/3,
	 print_end_credit_bonus_rech_sl/3,
	 print_account_debited/2,
	 print_credit/1,
	 print_credit/4,
	 print_start_we/1,
	 print_end_we/1,
	 print_text/2,
	 active_options/3,
	 display_multimedia_menu/2,
	 display_appels_menu/2,
	 display_sms_messages_menu/2,
	 links_to_options/1,
	 first_page/7,
	 redirect_OptASM_state/7,
	 asm_GetIdentification/4,
	 asm_GetIdentification/5,
	 asm_GetListServiceOptionnel/4,
	 asm_SetServiceOptionnel/7,
	 subscribe/6,
	 subscribe/7,
	 subscribe/8,
	 subscribe/5,
	 unsubscribe/3,
	 check_credit_options/4,
	 redirect_dcl_cmo/6,
	 redirect_date/3,
	 redirect_time/4,
	 redirect_if_kdo/4,	 
	 redirect_by_kdo_dte/2,
	 check_capability_mms/3,
	 do_subscription/6,
	 dcl_num_filter/5,
	 code_opt/2,
	 update_session/2,
	 redirect_by_roaming_network/2,
	 redirect_by_roaming_network/6,
	 redirect_by_option_activation/5,
	 redirect_by_option_if_subscribed/5,
	 redirect_by_dcl/4,
	 redirect_by_zap_vacances/3,
	 redirect_by_bonus_identify_bic_phone/3,
	 redirect_by_declinaison/8,
	 redirect_by_option_state/4,
	 redirect_by_compte_solde/5,	 
	 redirect_by_identification/3,
	 redirect_by_bank_holiday/4,
	 redirect_by_variable_foot_X/5,
	 redirect_by_bonus/6,
	 redirect_by_choisir_bonus/3,
	 redirect_nouv_gerer_bonus/6,
	 redirect_by_suiviconso/4,
	 sachem_consultation/2,
	 sachem_consultation/3,
	 option_en_promo/3,
	 activate_visio/3,
	 redir_by_opt_visio_status/4,
	 write_to_file/4,
	 get_url_blocked/1,
	 proposer_lien_decouvrir_orange_foot/4,
	 redirect_by_identify_bic_phone/3,
	 resilier_option/2,
	 redir_by_jkdo_bp_date/3,
	 redir_by_teasing_jkdo_bp_date/3,
	 redir_by_segCo/4,
	 redir_by_end_credit_m6_ssms/3,
	 redirect_by_tac/4,
	 check_right_access_to_services/2,
	 option_multimedia_link/3,
	 option_appels_link/3,
	 option_sms_messages_link/3,
         option_page/2,
	 print_opt_name/1,
	 print_opt_foot_name/1,
	 redirect_if_ratio_zero/5,
	 search_subscr_code_opt/2,
	 print_avantage/2,
	 redirect_by_bonus_credit/2,
	 print_need_amount_for_bonus/1,
	 redirect_decouvrir_bonus/3,
	 resilier_mobi_bonus/1,
	 resilier_bonus_and_redirect/2,
	 print_bonus_solde/1,
	 print_fun_menu/2,
	 redirect_by_bonus_credit/1,
	 get_actived_bonus_option/1,
	 redirect_by_cpte_etat/3,
	 change_mobi_bonus/3,
	 check_incompatible_souhaitee/3
	]).

-export([check_number/5,
	do_register_refo/5,
	print_opt_date_souscr_refo/1,
	do_unsubscription_refo/4,
	redirect_state_opt_cpte_refo/4,
	print_opt_info_refo/3,
        print_renew_date/3,
	redirect_by_plan_tarifaire/4]).

-export([redirect_avantages_vacances/4	 
	]).

%% Unit test export
-export([display_link/4,
	 next_page/8,
	 option_start_date/3,
	 option_end_date/3,
	 option_price/3,
	 next_weekend_date/3,
         next_opt_page/3,
	 debited_account/3]).

%%Slog_info
-export([slog_info/3]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../oma/include/slog.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../include/subscr_asmetier.hrl").
-include("../include/mmsinfos.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/include/rdp_options.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").

-define(First_page_active,1).
-define(Start,1).
-define(Number_opts_per_page_cmo,4).
-define(Number_opts_per_page_postpaid,4).
-define(begin_tac,1).
-define(end_tac,8).
-define(One_M6_evening,2).
-define(Zero,0.00000e+0).
-define(Erl_multimedia_link,"erl://svc_of_plugins:option_multimedia_link?").
-define(Erl_appels_link,"erl://svc_of_plugins:option_appels_link?").
-define(Erl_sms_messages_link,"erl://svc_of_plugins:option_sms_messages_link?").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLUGINS RELATED TO SUBSCRIPTION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%proposer_lien/5
%% +type proposer_lien(session(),Subscription::string(),
%%                     Option::string(),PDC::string(),URL::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.
slog_info(internal, ?MODULE, unknow_type_subscription)->
    #slog_info{descr="Can not match the Declinaison returned from Sachem with the declared subscriptions"
	       " in pservices_orangef:redirect_mobicarte",
               operational="Please check pservices_orangef:redirect_mobicarte is updated"
	       " with all possible Declinaisons returned from Sachem\n"}.

proposer_lien(plugin_info, Subscription, Option, PCD, URL) ->
    {obsolete,{svc_of_plugins,proposer_lien,6},
     [Subscription, Option, PCD, URL, "nobr"]};
proposer_lien(Session, Subscription, Option, PCD, URL) ->
    proposer_lien(Session, Subscription, Option, PCD, URL, "nobr").

%%proposer_lien/6
%% +type proposer_lien(session(),Subscription::string(),
%%                     Option::string(),PDC::string(),URL::string(),BR:string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.

proposer_lien(plugin_info, Subscription, Option, PCD, URL,BR) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is commercially launched.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [mobi, cmo, postpaid]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [no_option,
				   opt_weinf,
				   opt_sinf,
				   opt_jinf,
				   opt_maghreb,
				   opt_europe,
				   opt_pass_dom,
				   opt_afterschool,
				   opt_ssms,
				   opt_sms_quoti,
				   opt_sms_illimite,
				   opt_ssms_illimite,
				   opt_jsms_illimite,
				   opt_illimite_kdo_v2,
				   opt_tt_shuss,
				   opt_pack_duo_journee,
				   opt_vacances,
				   ow_spo,
				   ow_surf,
				   ow_tv,
				   ow_tv2,
				   ow_musique,
				   ow_tv_mus_surf,
				   media_decouvrt,
				   media_internet,
				   opt_pass_vacances,opt_pass_vacances_v2,opt_pass_vacances_z2,
				   opt_pass_voyage_6E,
				   opt_pass_voyage_9E,
				   opt_pass_voyage_6E_gpro,
				   opt_pass_voyage_9E_gpro,
				   plan_zap,
				   offres_eXclusives,
				   portail_multimedia,
				   fun_menu,
				   chat,
				   jeux,
				   fun_tones,
				   carte_postale,
				   news,
				   annuaire,
				   cmo_tlr,
				   recharge_cg,
				   rech_cb,
				   refill_game,
				   rech_pour_moi,
				   appelle_moi,
				   mms_infos,
				   mms_video,
				   opt_j_omwl,
				   opt_orange_messenger,
				   opt_plus_internet_gpro,
				   opt_orange_foot_gpro,
				   davantage_gpro,
				   opt_tv,opt_tv_max,
				   opt_musique,
				   opt_musique_mix,
				   opt_musique_collection,
				   opt_internet,opt_internet_max,
				   opt_internet_max_weekend, opt_internet_max_journee,
				   opt_mes_vocale_visuelle,
				   opt_mes_vocale_visuelle_gpro,
				   opt_foot_ligue1, opt_foot_ligue1_0_5,
				   opt_orange_sport,
				   opt_unik,
				   transfert_credit,menu_without_spider,
				   opt_m6_une_soiree_sms,
				   opt_m6_des_soirees_sms,
				   opt_visio,
				   menu_zap_vacances,
				   opt_unik_tout_operateur,
                                   opt_orange_maps,
				   opt_mail,
				   opt_zap_zone,
                                   opt_mes_donnees,
				   etranger,
				   decouvrir_bonus_X,
				   decouvrir_bonus_Y,
				   janus_resilier_bonus,
				   opt_30mn_hebdomadaires,
				   opt_10mn_quotidiennes
				  ]}},

        "This parameter specifies the option."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr,br_after]}},
	"This parameter specifies br tag."}
      ]});

proposer_lien(abs, _, _, PCD, URL,BR) ->
    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Option =="decouvrir_bonus_X";
       Option =="decouvrir_bonus_Y" ->				  
    Type_decouvrir=pbutil:get_env(pservices_orangef,type_decouvrir_bonus),
    slog:event(trace, ?MODULE, type_decouvrir, Type_decouvrir),
    case Type_decouvrir of 
	"non" -> [];
	_ ->
	    State = svc_util_of:get_user_state(Session),
	    DCL = State#sdp_user_state.declinaison,
	    case DCL of
		DCL_ when DCL_==?mobi;
			  DCL_==?cpdeg;
			  DCL_==?mobi_new->
		    case Option of
			"decouvrir_bonus_X" ->
			    case svc_options:is_option_activated(Session,opt_ikdo) of
				false ->
				    display_link(Session,[], PCD, URL, BR);
				_ ->
				    []
			    end;
			_ ->
			    case svc_compte:is_transfert_credit_enable(State) of
				true -> [];
				_ ->
				    case svc_options:is_option_activated(Session,opt_ikdo) of
					true -> 
					    display_link(Session,[], PCD, URL, BR);
					_ ->
					    []
				    end
			    end
		    end;
		?B_phone ->
		    case svc_util_of:is_identify(Session) of
			true ->
			    case Option of
				"decouvrir_bonus_X" ->
				    case svc_options:is_option_activated(Session,opt_ikdo) of
					false ->
					    display_link(Session,[], PCD, URL, BR);
					_ ->
					    []
				    end;
				_ ->
				    case svc_compte:is_transfert_credit_enable(State) of
					true -> [];
					_ ->
					    case svc_options:is_option_activated(Session,opt_ikdo) of
						true ->
						    display_link(Session,[], PCD, URL, BR);
						_ ->
						    []
					    end
				    end
			    end;
			_->
			    []
		    end;
		?click_mobi ->
		    display_link(Session,[], PCD, URL, BR);
		_ -> []
	    end
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Option =="janus_resilier_bonus"->				  
    {_,Session1}= svc_util_of:reinit_compte(Session),
    State=svc_util_of:get_user_state(Session1),
    case svc_util_of:is_commercially_launched(Session1,mobi_janus_promo) of
	true->
	    DateActive = svc_util_of:unixtime_to_local_time(State#sdp_user_state.d_activ),
	    case svc_util_of:get_commercial_date(mobi,user_janus_promo) of
		 [{Begin,End}]->
		    case (Begin < DateActive) and (DateActive < End) of
			true->
			    slog:event(trace, ?MODULE, janus_promo, not_allow_resilier_bonus),
			    [];
			_->
			    slog:event(trace, ?MODULE, janus_promo, not_promo),
			    display_link(Session1,[],PCD,URL)
		    end;
		_->
		    slog:event(internal,?MODULE,user_janus_promo,commercial_date_not_found),
		    display_link(Session1,[],PCD,URL)
	    end;
	_->
	    display_link(Session1,[],PCD,URL)
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (Option =="mobi_bonus_options" andalso Subscription=="mobi") ->
    State = svc_util_of:get_user_state(Session),
    svc_spider:lienSiGodetsCouD(Session,PCD,URL);

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (Option =="opt_zap_zone") and
       (Subscription =="cmo")->				  
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
	DCL_ when DCL_==?pmu;
		  DCL_==?fmu_18;
		  DCL_==?fmu_24;
		  DCL_==?ppolc;
		  DCL_==?ppol4;
		  DCL_==?ppol3;
		  DCL_==?ppol2;
		  DCL_==?ppol1;
		  DCL_==?ppola;
		  DCL_==?cmo_sl;
		  DCL_==?zap_cmo;
		  DCL_==?zap_cmo_v2;
		  DCL_==?cmo_sl_apu;
		  DCL_==?big_cmo;
		  DCL_==?zap_cmo_18E;
		  DCL_==?zap_cmo_20E;
		  DCL_==?zap_cmo_25E;
		  DCL_==?zap_cmo_1h_v2;
		  DCL_==?zap_cmo_1h30_v2;
		  DCL_==?zap_cmo_1h30_ill;
		  DCL_==?parent_cmo;
		  DCL_==?zap_vacances;
		  DCL_==?zap_cmo_1h_unik;
		  DCL_==?DCLNUM_CMO_SL_ZAP_1h30_ILL->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->   []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (Option =="opt_heures_zap_vacances") and
       (Subscription =="cmo") ->				  
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case check_code_offre_quicksilver(Session) of
	true ->
            [];
	_ ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}]
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (Option =="opt_zap_vacances") and
       (Subscription =="cmo") ->				  
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case check_code_offre_quicksilver(Session, PCD) of
	true ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
            case DCL of
                DCL_ when DCL_==?zap_vacances; DCL_==?zap_cmo_25E ->
                    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
                _ ->
                    []
            end
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (Option =="menu_zap_vacances") and
       (Subscription =="cmo")->				  
    case is_condition_zap_vacances(Session) of
	true ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when ((Option =="ow_spo") or (Option =="ow_surf") or
	(Option =="ow_tv") or (Option =="ow_tv2") or
	(Option =="ow_musique") or (Option =="ow_tv_mus_surf") or
	(Option =="media_decouvrt") or (Option =="media_internet") or
	(Option =="opt_mes_vocale_visuelle") or 
	(Option =="no_option")) and
       (Subscription =="cmo")->				   
    Opt=list_to_atom(Option),
    display_link(Session, Option, PCD, URL,BR);

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (
	(Option =="opt_tv_gpro") or 
        (Option =="opt_plus_internet_gpro") or
	(Option =="opt_mes_vocale_visuelle_gpro") or
        (Option =="opt_orange_foot_gpro") or 
        (Option =="opt_unik_tout_operateur") or
	(Option =="no_option") 
       ) 
	and
       (Subscription =="postpaid")->				   
    Opt=list_to_atom(Option),
    display_link(Session, Option, PCD, URL,BR);

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when ((Option=="chat") or (Option=="jeux") or (Option=="annuaire")) and      
       ((Subscription=="cmo") or (Subscription=="postpaid")) ->
    Opt=list_to_atom(Option),
    display_link(Session, Opt, PCD, URL,BR);

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Option=="mms_infos" ->
    Opt=list_to_atom(Option),
    MMS=svc_mmsinfos:cast(Session),
    case (MMS#mmsinfos.mms_compat) of
	?mms_not_compatible ->
	    [];
	_ ->
	    display_link(Session, Opt, PCD, URL,BR)
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Option=="mms_video" ->
    Opt=list_to_atom(Option),
    MMS=svc_mmsinfos:cast(Session),
    case (MMS#mmsinfos.vdo_compat) of
	?mms_not_compatible ->
	    [];
	_ ->
	    display_link(Session, Opt, PCD, URL,BR)
    end;

proposer_lien(Session, Subscription,Opt, PCD, URL,BR)
  when Opt=="offres_eXclusives" ->
    case svc_util_of:get_env(offres_eXclusives) of
	true->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->[]
    end;

proposer_lien(Session, Subscription,Opt, PCD, URL,BR)
  when Opt=="etranger" ->
    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien(Session, Subscription, Option, PCD, URL,BR) 
  when Subscription=="monacell_prepaid" andalso Option=="opt_sms_illimite"->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    svc_util_of:add_br(BR) ++
		[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Subscription=="monacell_comptebloqu" andalso Option=="opt_sms_illimite"->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    Opt=list_to_atom(Option),
    case DCL of 
        ?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN ->
	    svc_util_of:add_br(BR) ++
		[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
when Option =="opt_pass_voyage_6E" andalso Subscription=="cmo" ->
    Opt=list_to_atom(Option),
    case svc_roaming:get_vlr(Session) of 
	{ok, VLR_Number} ->
			case svc_util_of:is_commercially_launched(Session,Opt) and 
				svc_util_of:is_good_plage_horaire(Opt) of
				true ->
					svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
				_ ->
					[]
		    end;
		_ ->
			[]
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR) 
when Option =="opt_10mn_europe" ->
    Opt=list_to_atom(Option),
    case svc_roaming:get_vlr(Session) of 
	{ok, VLR_Number} ->
	    case (svc_util_of:is_commercially_launched(Session,Opt) and 
		(not svc_options:is_option_activated(Session,Opt))) of
		true ->
		    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
		_ ->
		    []
	    end;
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR) 
  when Option=="opt_sms_illimite"->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DateActiv = svc_util_of:unixtime_to_local_time(State#sdp_user_state.d_activ),
    case svc_util_of:check_plage_datetimes(DateActiv, pbutil:get_env(pservices_orangef,sms_illimite_cmo)) and
	svc_util_of:is_commercially_launched(Session,Opt) of 
	true ->
	    svc_util_of:add_br(BR) ++
		[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR) 
  when Option=="opt_m6_une_soiree_sms"->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    Solde = svc_compte:solde_cpte(State, cpte_m6_soiree_sms),
    case 	
	(svc_util_of:is_identify(Session)) and 
	(Solde == currency:sum(euro,?One_M6_evening)) and 
	svc_util_of:is_commercially_launched(Session,Opt) of 
	true ->
	    display_link(Session, Opt, PCD, URL,BR);
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR) 
  when Option=="opt_m6_des_soirees_sms"->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    Solde = svc_compte:solde_cpte(State, cpte_m6_soiree_sms),
    case  
	(svc_util_of:is_identify(Session)) and 
	(currency:is_inf(currency:sum(euro,?One_M6_evening),Solde)) and 
	 svc_util_of:is_commercially_launched(Session,Opt)
	of
	true ->
	    display_link(Session, Opt, PCD, URL,BR);
	_ ->
	    []
    end;

proposer_lien(Session, Subscription, Option = "davantage_gpro", PCD, URL,BR) ->
    Opt=list_to_atom(Option), 
    display_link(Session, Opt, PCD, URL,BR);

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when (Option=="fun_menu") and (Subscription=="postpaid") ->
    Opt=list_to_atom(Option), 
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true -> 
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false->	     
	    []
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Subscription=="postpaid" ->
    Opt=list_to_atom(Option), 
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true -> 
	    display_link(Session, Opt, PCD, URL,BR);
	false->	     
	    []
    end;

proposer_lien(Session, Subscription, Option="opt_unik", PCD, URL,BR) ->
    Opt=list_to_atom(Option),
    case {svc_util_of:is_compatible(Opt, Session),svc_options:state(Session,Opt)} of
	{true,_} -> display_link(Session, Opt, PCD, URL,BR);
	{_,suspend} ->  display_link(Session, Opt, PCD, URL,BR);
	{_,actived} ->  display_link(Session, Opt, PCD, URL,BR);
	_ -> []
    end;	

proposer_lien(Session, Subscription, Option="transfert_credit", PCD, URL,BR) ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    List_DCL_eligible = pbutil:get_env(pservices_orangef,dcl_eligible_offrir_credit),
    case {lists:member(DCL,List_DCL_eligible),svc_compte:is_transfert_credit_enable(State)} of
	{true, true} ->
	    display_link(Session, Opt, PCD, URL,BR);
	_ -> []
    end;

proposer_lien(Session, "mobi", Option, PCD, URL,BR)
  when Option=="opt_illimite_kdo_v2" ->	
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) and
       svc_util_of:is_good_plage_horaire(Opt) and
        not (svc_options:is_option_activated(Session,opt_illimite_kdo) or
             svc_options:is_option_activated(Session,opt_ikdo_vx_sms)) of
       true ->
	    case svc_options:is_option_activated(Session,opt_illimite_kdo_v2) of
		true->
		    display_link(Session, Opt, PCD, URL,BR);
		false->
		    []
	    end;
       false->
           []
    end;


proposer_lien(Session, "mobi", Option, PCD, URL,BR)
  when Option=="opt_foot_ligue1";Option=="opt_ssms";
       Option=="opt_ssms_illimite";Option=="opt_jsms_illimite";
       Option=="opt_musique_mix";Option=="opt_musique_collection"->
    Opt=list_to_atom(Option),	
    case svc_util_of:is_commercially_launched(Session,Opt) of	
	true ->
	    display_link(Session, Opt, PCD, URL,BR);
	_ ->
	    slog:event(trace, ?MODULE, proposer_lien, 
		       {is_comm_launched, false}),
	    
	    []
    end;

proposer_lien(Session,"mobi",Option, PCD, URL, BR)
when Option =="opt_pass_voyage_6E"; Option =="opt_pass_voyage_9E"; 
     Option == "opt_europe"; Option == "opt_maghreb"; Option == "opt_pass_dom" ->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}] ++svc_util_of:add_br(BR);		    
	false ->
	    []
    end;

proposer_lien(Session, "mobi", Option, PCD, URL, BR)
when (Option == "opt_internet_max_journee") or  (Option == "opt_internet_max_weekend") ->
    Opt=list_to_atom(Option),
        case svc_util_of:is_good_plage_horaire(Opt) of
            true ->
                display_link(Session, Option, PCD, URL,BR);
            false ->[]
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when ((Option == "opt_10mn_quotidiennes")  and (Subscription=="mobi")) ->
    Opt=list_to_atom(Option),
    case svc_options:state(Session, Opt) of
        actived ->
            display_link(Session, Opt, PCD, URL,BR);
        _->[]
    end;
proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when ((Option=="opt_30mn_hebdomadaires") and (Subscription=="mobi")) ->
    Opt=list_to_atom(Option),
    case svc_options:state(Session, Opt) of
        X when X==actived; X==suspend ->
            display_link(Session, Opt, PCD, URL,BR);
        _->[]
    end;

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Subscription=="mobi" ->
    Opt=list_to_atom(Option), 
    display_link(Session, Opt, PCD, URL,BR);

proposer_lien(Session, Subscription, Option, PCD, URL,BR)
  when Subscription=="cmo" ->
    Opt=list_to_atom(Option), 
	case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true -> 
	    display_link(Session, Opt, PCD, URL,BR);
	false->
	    []
    end;
proposer_lien(Session, Subscription, Option, PCD, URL,BR) ->
    slog:event(internal, ?MODULE, proposer_lien, [Subscription, Option, PCD, URL]),
    [].
%% proposer_lien_autres_option/4
%% +type proposer_lien_autres_option(session(),Url_autres::string(),
%%                     Url_Unik::string(),Url_Cityzi::string()) ->
%%                     hlink().
%%%% Check whether link Autres Option or Unik or Cityzi should be proposed in bons plans menu
proposer_lien_autres_option(plugin_info, Url_autres,Url_Unik,Url_Cityzi)->
    (#plugin_info
     {help =
      "This plugin command redirect by Segment Commercial",
      type = function,
      license = [],
      args =
      [
       {url_autres, {link, []},
        "This parameter specifies the page when both Unik and Cityzi are proposed."},
       {url_unik, {link, []},
        "This parameter specifies the page when only Unik is proposed"},
       {url_cityzi, {link, []},
        "This parameter specifies the page when only Cityzi is proposed"}
      ]});
proposer_lien_autres_option(abs, Url_autres,Url_Unik,Url_Cityzi)->
    {redirect,abs, Url_autres},
    {redirect,abs, Url_Unik},
    {redirect,abs, Url_Cityzi};
proposer_lien_autres_option(Session,Url_autres,Url_Unik,Url_Cityzi)->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
	?mobi_janus->
	    case svc_options:state(Session,opt_cityzi) of
		X when X==actived;
		       X==suspend->
		    case svc_util_of:is_compatible(opt_unik, Session) of
			true->
			    svc_util_of:add_br("br")++[#hlink{href=Url_Cityzi,contents=[{pcdata,"Autres Options"}]}];
			_->
			    svc_util_of:add_br("br")++[#hlink{href=Url_Cityzi,contents=[{pcdata,"Option Cityzi"}]}]
		    end;
		_ ->[]
	    end;
	?DCLNUM_ADFUNDED->
	    [];
	_ ->
	    case svc_util_of:is_compatible(opt_unik, Session) of
		X when X==true->
		    case svc_options:state(Session,opt_cityzi) of
			Y when Y==actived;
			       Y==suspend->
			    svc_util_of:add_br("br")++[#hlink{href=Url_autres,contents=[{pcdata,"Autres Options"}]}];
			_ ->
			    svc_util_of:add_br("br")++[#hlink{href=Url_Unik,contents=[{pcdata,"Unik"}]}]
			end;
		_->
		    case svc_options:state(Session,opt_cityzi) of
			Y when Y==actived;
			       Y==suspend->
			    svc_util_of:add_br("br")++[#hlink{href=Url_Cityzi,contents=[{pcdata,"Option Cityzi"}]}];
			_ ->[]
		    end
	    end
    end.

% Check code offre to display Avantages Vacances link for client having Quicksilver right
check_code_offre_quicksilver(Session) ->
    case svc_subscr_asmetier:get_identification(Session,"oee") of
        {ok,IdDosOrId,CodeOffre,Session1} ->
	    lists:member(CodeOffre, ["2011P", "2013V"]);
        _ ->
	    false
    end.
check_code_offre_quicksilver(Session, PCD) ->
    case svc_subscr_asmetier:get_identification(Session,"oee") of
        {ok,IdDosOrId,CodeOffre,Session1} ->
	    if 
		(CodeOffre == "2011P") and (PCD == "Declaration Zone Academique")->
		    true;	    
		(CodeOffre == "2013V") and (PCD == "Changement Zone academique")->
		    true;
		 true ->
		    false
	    end;
        _ ->
	    false
    end.
redir_by_segCo(plugin_info, SegCo, URL_SegCo, URL_NoSegCo) ->
    (#plugin_info
     {help =
      "This plugin command redirect by Segment Commercial",
      type = command,
      license = [],
      args =
      [
       {segCo, {oma_type, {defval,"",string}},
	"This parameter specifies the string Segment Commercial."},
       {url_SegCo, {link, []},
        "This parameter specifies the page when SegCo isn't ONE02"},
       {url_noSegCo, {link, []},
        "This parameter specifies the page when SegCo is ONE02"}
      ]});

redir_by_segCo(Session, SegCo, URL_SegCo, URL_NoSegCo)->
    Sub=svc_util_of:get_souscription(Session),
    redir_by_segCo(Session, SegCo, Sub, URL_SegCo, URL_NoSegCo).

redir_by_segCo(Session, SegCo, Sub, URL_SegCo, URL_NoSegCo)->
    SegCo_list=string:tokens(SegCo,","),
    case svc_subscr_asmetier:get_segCo(Session, "oee") of
	{ok, CodeSegmentCommercial, NewSession} ->
	    slog:event(trace,?MODULE,codeSegmentCommercial,CodeSegmentCommercial),
	    case lists:member(CodeSegmentCommercial,SegCo_list) of
		true->
		    {redirect, NewSession, URL_SegCo};
		_->
		    {redirect, NewSession, URL_NoSegCo}
	    end;
	_->{redirect, Session, "/orangef/home.xml#as_metier_failure"}
    end.

%% proposer_lien_si_active/6
%% +type proposer_lien_si_active(session(),Subscription::string(),
%%                     Option::string(),PDC::string(),URL::string(),BR::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.

proposer_lien_si_active(plugin_info, Subscription, Option, PCD, URL,BR) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is actived.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [mobi, cmo, postpaid, tele2_comptebloque,carrefour_comptebloq, nrj_prepaid]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [opt_cityzi,
				   opt_illimite_kdo_v2,
				   opt_illimite_kdo,
				   opt_ikdo_vx_sms,
				   opt_kdo_sinf,
				   opt_surf_mensu,
				   opt_tv_mensu,
				   opt_musique,
				   opt_musique_mix,
				   opt_musique_collection,
				   opt_visio,
				   cpte_roaming,
				   forf_carrefour_z1,
				   forf_carrefour_z2,
				   forf_carrefour_z3,
				   forf_opt_carrefour,
                                   cpte_sms_ill,
                                   cpte_promo_surf,
                                   cpte_num_prefere,
                                   opt_orange_foot_offert,
                                   opt_foot_ligue1,
				   opt_internet_max,
				   opt_tv_max,
				   cpte_all_nrj_prepaid
								   ]}},

        "This parameter specifies the option or the compte."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr]}},
	"This parameter specifies br tag."}
      ]});

proposer_lien_si_active(abs, _, _, PCD, URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien_si_active(Session, Subscription, Option, PCD, URL,BR) 
  when Subscription=="cmo"; Subscription=="postpaid" ->
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    case svc_subscr_asmetier:is_option_activated(Session, Opt, State) of 
	true ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false -> 
	    []
    end;

proposer_lien_si_active(Session, Subscription="tele2_comptebloque", Compte, PCD, URL,BR) ->
    Cpte=list_to_atom(Compte),
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,Cpte) of
	no_cpte_found -> [];
	#compte{} -> display_link(Session, Cpte, PCD, URL,BR)
    end;


proposer_lien_si_active(Session, Subscription="carrefour_comptebloq", Compte, PCD, URL,BR) ->
    Cpte=list_to_atom(Compte),
    State=svc_util_of:get_user_state(Session),
    case svc_compte:etat_cpte(State,Cpte) of
       ?CETAT_AC -> display_link(Session, Cpte, PCD, URL,BR);
        _ -> []
    end;

proposer_lien_si_active(Session, Subscription="mobi",Option, PCD, URL,BR)
when Option=="opt_illimite_kdo";
     Option=="opt_ikdo_vx_sms";
     Option=="opt_illimite_kdo_v2"->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    slog:event(trace,?MODULE,proposer_lien_si_active,[DCL,dcl,Opt]),
    case DCL of 
	DCL_ when DCL_==?mobi;
		  DCL_==?cpdeg;
		  DCL_==?mobi_new;
		  DCL_==?B_phone ->
	    case svc_options:is_option_activated(Session,Opt) of 
		true -> display_link(Session, Opt, PCD, URL,BR);
		_ ->[]
	    end;
	_ -> 
	    []
    end;

proposer_lien_si_active(Session, "nrj_prepaid", Option="cpte_all_nrj_prepaid", PCD, URL,BR) ->
    State=svc_util_of:get_user_state(Session),    
    List_state_compte=[svc_compte:etat_cpte(State,cpte_forf_nrj_data),
		       svc_compte:etat_cpte(State,cpte_forf_nrj_sms),
		       svc_compte:etat_cpte(State,cpte_nrj_europe),
		       svc_compte:etat_cpte(State,cpte_nrj_maghreb),
		       svc_compte:etat_cpte(State,cpte_nrj_afrique)],
    case lists:member(?CETAT_AC,List_state_compte) of
	true->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_->
	    []
    end;

proposer_lien_si_active(Session, "mobi", Option="opt_internet_max", PCD, URL,BR) ->
    Opt=list_to_atom(Option),
    case {svc_options:state(Session,opt_internet_max),svc_options:state(Session,opt_internet_max_v3)} of
	{not_actived,not_actived} -> [];
	_ -> display_link(Session, Opt, PCD, URL,BR)
    end;
	
proposer_lien_si_active(Session, "mobi", Option, PCD, URL,BR) ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    if (((Opt==opt_orange_foot_offert) or (Opt==opt_foot_ligue1))
	and (DCL==?CLUB_FOOT)) ->
	    [];
       true ->
	    case svc_options:state(Session,Opt) of
		not_actived -> [];
		_ -> display_link(Session, Opt, PCD, URL,BR)
	    end
    end.

%% +type redirect_by_variable_foot_X(session(),Subscription::string(),
%%                     Option::string(),PDC::string(),URL::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.

redirect_by_variable_foot_X(plugin_info, Subscription, X1_URL, X2_URL, X3_URL) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is actived.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [mobi]}},
        "This parameter specifies the subscription."},
       {urls_x1, {link,[]},
	"This parameter specifies the X1 page"},
       {urls_x2, {link,[]},
	"This parameter specifies the X2 page"},
       {urls_x3, {link,[]},
	"This parameter specifies the X3 page"}
      ]});


redirect_by_variable_foot_X(Session, "mobi", X1_URL, X2_URL, X3_URL) ->
    Subscribed = variable:get_value(Session, {"bons_plans","foot_subscribe"}),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
	?CLUB_FOOT ->
	    case svc_options:is_any_option_activated(Session,
						     [opt_bordeaux, 
						      opt_lens, 
						      opt_lyon, 
						      opt_marseille, 
						      opt_paris, 
						      opt_saint_etienne]) or (Subscribed == "subscribed") of
		true ->
		    [];
		_ ->
		    display_link(Session, [], "Confirmer votre club", X3_URL)
	    end;
	_ ->
            case svc_options:state(Session,opt_kdo_sinf) of
                not_actived -> 
                    display_link(Session, opt_kdo_sinf, "Activez vos soirees infinies", X1_URL);
                _ -> 
		    Cpte=svc_options:opt_to_godet(opt_kdo_sinf,mobi),
                    case svc_compte:cpte(State,Cpte) of
                        #compte{unt_num=?EURO,etat=?CETAT_AC,cpp_solde=CPP_SOLDE,
                                tcp_num=_,ptf_num=_}->
                            RatioNbApp = ?RATIO_FOOT_SOIREE,
                            SOLDE_EUROS = currency:round_value(CPP_SOLDE),
                            NbApp = trunc(SOLDE_EUROS/RatioNbApp),
                            case NbApp of
                                0 ->
				    [];
                                _ ->
				    display_link(Session, opt_kdo_sinf, "Profitez de vos soirees infinies", X2_URL)
                            end;
                        _ ->
                            []
                    end
            end
    end.

%% proposer_lien_si_non_active/6
%% +type proposer_lien_si_non_active(session(),Subscription::string(),
%%                     Option::string(),PDC::string(),URL::string(),BR::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.
%%%% Can be used to check for incompatibility with an option

proposer_lien_si_non_active(plugin_info, Subscription, Option, PCD, URL,BR) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is actived.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [mobi, cmo, postpaid]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [opt_kdo_sinf,opt_musique, opt_surf_mensu,opt_tv_mensu]}},

        "This parameter specifies the option."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr]}},
	"This parameter specifies br tag."}
      ]});

proposer_lien_si_non_active(abs, _, _, PCD, URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien_si_non_active(Session, Subscription, Option, PCD, URL,BR) 
  when Subscription=="cmo"; Subscription=="postpaid" ->
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    case svc_subscr_asmetier:is_option_activated(Session, Opt, State) of 
	false ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	true -> 
	    []
    end;

proposer_lien_si_non_active(Session, Subscription, Option, PCD, URL,BR) ->
    Opt=list_to_atom(Option),
    case svc_options:is_option_activated(Session,Opt) of
	false ->
	    display_link(Session, Opt, PCD, URL,BR);
	true -> 
	    []
    end.

prososer_lien_decouv_zap_zone(plugin_info, Subscription, PCD, URL,BR) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is actived.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [mobi, cmo, postpaid]}},
        "This parameter specifies the subscription."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"},
       {br, {oma_type, {enum,[br,nobr,br_after]}},
	"This parameter specifies br tag."}
      ]});


prososer_lien_decouv_zap_zone(abs, _, PCD, URL,BR) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}];

prososer_lien_decouv_zap_zone(Session, Subscription, PCD, URL,BR) 
  when Subscription=="postpaid" ->
    State = svc_util_of:get_user_state(Session),
    case svc_subscr_asmetier:is_option_activated(Session, opt_avan_dec_zap_zone, State) of 
	false ->
	    display_link(Session, opt_avan_dec_zap_zone, PCD, URL,BR);
	true -> 
	    []
    end;

prososer_lien_decouv_zap_zone(Session, Subscription, PCD, URL,BR) 
  when Subscription=="cmo" ->
    State = svc_util_of:get_user_state(Session),
    DCL = svc_compte:dcl(State),
    Dcl_filter = pbutil:get_env(pservices_orangef,dcl_filter_options),
    {_,{_,Dcl_Num_List}}=lists:keysearch("opt_zap_zone",1,Dcl_filter),

    case lists:member(DCL,Dcl_Num_List++[?rsa_cmo]) of
	false ->
	    TOP_NUM = svc_options:top_num(opt_avan_dec_zap_zone, Subscription),
	    case lists:keysearch(TOP_NUM, 1,State#sdp_user_state.options) of
		false ->
		    display_link(Session, opt_avan_dec_zap_zone, PCD, URL,BR);
		_ ->
		    []
	    end;
	_ ->
	    []
    end;

prososer_lien_decouv_zap_zone(Session, Subscription, PCD, URL,BR) ->
    State = svc_util_of:get_user_state(Session),
    TOP_NUM = svc_options:top_num(opt_avan_dec_zap_zone, Subscription),
    case lists:keysearch(TOP_NUM, 1,State#sdp_user_state.options) of
	false ->
	    display_link(Session, opt_avan_dec_zap_zone, PCD, URL,BR);
	_ ->
	    []
    end.

proposer_lien_decouvrir_orange_foot(plugin_info, Subscription,PCD, URL) ->
    (#plugin_info
     {help =
      "This plugin function includes the link of decouvrir_orange if the options"
      " Orange_foot and Orange_foot_offert not activated.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [mobi]}},
        "This parameter specifies the subscription."},
       {pcd, {oma_type, {defval,"",string}},
	"This parameter specifies the text to be displayed."},
       {urls, {link,[]},
	"This parameter specifies the next page"}
      ]});

proposer_lien_decouvrir_orange_foot(abs, _, PCD, URL) ->
    [#hlink{href=URL,contents=[{pcdata,PCD}]}];

proposer_lien_decouvrir_orange_foot(Session, Subscription, PCD, URL) ->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
	?CLUB_FOOT ->
	    [];
	_ ->
	    State_options = {svc_options:is_option_activated(Session,opt_foot_ligue1)
                     ,svc_options:is_option_activated(Session,opt_orange_foot_offert)},
	    case State_options of
		{false,false} ->
		    svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
		_ -> 
		    []
	    end
    end.

	    
redirect_by_identify_bic_phone(plugin_info,  Url_identify, Url_unidentify) ->
    
    (#plugin_info
     {help =
      "This plugin function redirect to specific page when "
      "user is Bic phone and identify or not.",
      type = function,
      license = [],
      args =
      [
       {url_identify, {link,[]},
        "This parameter specifies the page when user is Bic Phone and identify"},
       {url_unidentify, {link,[]},
        "This parameter specifies the page when user is Bic Phone but not identify"}
      ]});
redirect_by_identify_bic_phone(abs, Url_identify, Url_unidentify) ->
    {redirect, abs, Url_identify};
redirect_by_identify_bic_phone(Session, Url_identify, Url_unidentify)->
        State = svc_util_of:get_user_state(Session),
        DCL = State#sdp_user_state.declinaison,
        case DCL of
            ?B_phone ->
		case svc_util_of:is_identify(Session) of
		    true ->
			{redirect, Session, Url_identify};
		    _->
		        {redirect, Session, Url_unidentify}
		end;
            _ ->
		{redirect, Session, Url_identify}
        end.
%% +type proposer_lien_by_variable_foot_X(session(),URL_ac::string(),PCD_ac::string(),URL_not_ac::string(),PCD_not_ac::string(),Txt_no_credit ::string(),URL_new_foot::string(),PCD_new_foot::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.

proposer_lien_by_variable_foot_X(plugin_info,Url_ac,Pcd_ac,Url_not_ac,Pcd_not_ac,Txt_no_credit,Url_new_foot,Pcd_new_foot) ->
    (#plugin_info
     {help =
      "This plugin function includes the link to the defined option"
      " if the option is actived.",
      type = function,
      license = [],
      args =
      [
       {url_ac, {link,[]},
        "This parameter specifies the next page if option soiree inf is actived"},
       {pcd_actived, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed."},
       {url_not_ac, {link,[]},
        "This parameter specifies the next page if option soiree inf is not actived"},
       {pcd_not_ac, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed."},
       {txt_no_credit, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed if the option is actived but there is not more credit."},
       {url_new_foot, {link, []},
        "This parameter specifies the next page if declinaison is new foot."},
       {pcd_new_foot, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed."}
      ]});

proposer_lien_by_variable_foot_X(abs,Url_ac,Pcd_ac,Url_not_ac,Pcd_not_ac,Txt_no_credit,Url_new_foot,Pcd_new_foot) ->
    [#hlink{href=Url_ac,contents=[{pcdata,Pcd_ac}]}];

proposer_lien_by_variable_foot_X(Session,Url_ac,Pcd_ac,Url_not_ac,Pcd_not_ac,Txt_no_credit,Url_new_foot,Pcd_new_foot) ->
    Subscribed = variable:get_value(Session, {"bons_plans","foot_subscribe"}),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
        ?CLUB_FOOT ->
            case svc_options:is_any_option_activated(Session,
                                                     [opt_bordeaux,
                                                      opt_lens,
                                                      opt_lyon,
                                                      opt_marseille,
                                                      opt_paris,
                                                      opt_saint_etienne]) or (Subscribed == "subscribed") of
                true ->
                    [];
                _ ->
		    [#hlink{href=Url_new_foot,contents=[{pcdata,Pcd_new_foot}]}]++svc_util_of:add_br("br")
            end;
        _ ->
	    Opt=opt_kdo_sinf,
	    case svc_options:is_option_activated(Session,Opt) of
		false ->
		    [#hlink{href=Url_not_ac,contents=[{pcdata,Pcd_not_ac}]}]++svc_util_of:add_br("br");
		true ->
		    Cpte=svc_options:opt_to_godet(Opt,mobi),
		    case svc_compte:cpte(State,Cpte) of
			#compte{unt_num=?EURO,etat=?CETAT_AC,cpp_solde=CPP_SOLDE,
				tcp_num=TCP_NUM,ptf_num=PTF_NUM}=Compte->
			    RatioNbApp = ?RATIO_FOOT_SOIREE,
			    SOLDE_EUROS = currency:round_value(CPP_SOLDE),
			    NbApp = trunc(SOLDE_EUROS/RatioNbApp),
			    case NbApp of
				0 -> [{pcdata,Txt_no_credit}]++svc_util_of:add_br("br");
				_ -> [#hlink{href=Url_ac,contents=[{pcdata,Pcd_ac}]}]++svc_util_of:add_br("br")
			    end;
			_ ->
			    []
		    end
	    end
    end.

proposer_lien_options_et_bons_plans(plugin_info,PCD1,PCD2,URL) ->
    (#plugin_info
     {help =
      "This plugin function includes the link 'Options et bons plans' depending on declinaison.",
      type = function,
      license = [],
      args =
      [
       {pcd1, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed."},
       {pcd2, {oma_type, {defval,"",string}},
        "This parameter specifies the text to be displayed."},
       {url_ac, {link,[]},
        "This parameter specifies the page 'Options et bons plans'"}
      ]});

proposer_lien_options_et_bons_plans(abs,PCD1,PCD2,URL) ->
    [#hlink{href=URL,contents=[{pcdata,PCD1}]}];

proposer_lien_options_et_bons_plans(Session,PCD1,PCD2,URL) ->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
        DCL_ when DCL_==?zap_vacances;
		  DCL_==?zap_cmo_25E;
		  DCL_==?zap_cmo_20E ->
            svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD2}]}];
        _ ->
	    svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD1}]}]
    end.

proposer_lien_zone_academique(plugin_info,PCD1,PCD2,URL1,URL2) ->
    (#plugin_info
     {help =
      "This plugin function includes the link Declarer/Changer zone academique.",
      type = function,
      license = [],
      args =
      [
       {pcd1, {oma_type, {defval,"",string}},
        "This parameter specifies the text Declarer zone academique."},
       {pcd2, {oma_type, {defval,"",string}},
        "This parameter specifies the text Changer zone academique."},
       {url1, {link,[]},
        "This parameter specifies the page Declarer zone academique"},
       {url2, {link,[]},
        "This parameter specifies the page Changer zone academique"}
      ]});

proposer_lien_zone_academique(abs,PCD1,PCD2,URL1,URL2) ->
    [#hlink{href=URL1,contents=[{pcdata,PCD1}]},
     #hlink{href=URL2,contents=[{pcdata,PCD2}]}];

proposer_lien_zone_academique(Session,PCD1,PCD2,URL1,URL2) ->
    State = svc_util_of:get_user_state(Session),
    DCL=svc_compte:dcl(State),
    case DCL of
	X when X==?zap_vacances;X==?zap_cmo_1h30_v2 ->
	    Declared = svc_options:is_option_activated(Session, opt_zap_vacances),
	    case Declared of
		true ->
		    svc_util_of:add_br("br")++[#hlink{href=URL2,contents=[{pcdata,PCD2}]}];
		_ ->
		    svc_util_of:add_br("br")++[#hlink{href=URL1,contents=[{pcdata,PCD1}]}]
	    end;
	_  ->
	    []
    end.


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type display_link(session(),Opt::atom(),
%%                     PDC::string(),URL::string()) ->
%%                     hlink().
%%%% Internal function used by plugin proposer_lien.

display_link(Session, Opt, PCD, URL)
  when Opt==plan_zap ->
    case is_condition_zap_vacances(Session) of
	true->
	    svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false->
	    []
    end;

display_link(Session, Opt, PCD, URL) 
  when Opt==opt_afterschool ->
    State = svc_util_of:get_user_state(Session),
    case (svc_util_of:is_plug(State) or svc_util_of:is_zap(State)) of
	true ->
	    svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false -> 
	    []
    end;

display_link(Session, Opt, PCD, URL) ->
    svc_util_of:add_br("br")++[#hlink{href=URL,contents=[{pcdata,PCD}]}].

%%display_link/5

display_link(Session, Opt, PCD, URL,BR)
  when Opt==plan_zap ->
    case is_condition_zap_vacances(Session) of
	true->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false->
	    []
    end;

display_link(Session, Opt, PCD, URL,BR) 
  when Opt==opt_afterschool ->
    State = svc_util_of:get_user_state(Session),
    case (svc_util_of:is_plug(State) or svc_util_of:is_zap(State)) of
	true ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	false -> 
	    []
    end;

display_link(Session, Opt, PCD, URL,BR) ->
    case BR of 
	"br_after" -> 
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br("br");
	"br" ->
	    svc_util_of:add_br(BR)++[#hlink{href=URL,contents=[{pcdata,PCD}]}];
	_ ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_page(session(),Subscription::string(),Opt::string(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string())->
%%                  erlpage_result(). 
%%%% First page for subscription of option.
%%%% Redirect to UAct when option already active,
%%%% redirect to UIncomp when option incompatible with existing options,
%%%% redirect to UInsuf when not enough credit,
%%%% redirect to UGene when subscription proposed.
	
first_page(plugin_info, Subscription, Opt, UAct, UIncomp, UInsuf, UGene) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether the option is activated or incompatible with existing options,"
      " and whether the account has enough credit",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,
					 mobi,
					tele2_compte_bloque]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [opt_weinf,
				   opt_sinf,
				   opt_jinf,
				   opt_j_app_ill,
				   opt_s_app_ill,
				   opt_j_mm_ill,
				   opt_s_mm_ill,
				   opt_ssms_ill,
				   opt_jsms_ill,
				   opt_j_tv_max_ill,
				   opt_s_tv_max_ill,
				   opt_j_app_ill_kdo_bp,
                                   opt_s_app_ill_kdo_bp,
                                   opt_j_mm_ill_kdo_bp,
                                   opt_s_mm_ill_kdo_bp,
                                   opt_ssms_ill_kdo_bp,
                                   opt_jsms_ill_kdo_bp,
                                   opt_j_omwl_kdo_bp,
				   opt_j_tv_max_ill_kdo_bp,
				   opt_s_tv_max_ill_kdo_bp,
				   opt_musique,
				   opt_maghreb,
				   opt_europe,
				   opt_pass_dom,
				   opt_afterschool,
				   opt_ssms,
				   opt_sms_quoti,
				   opt_sms_illimite,
				   opt_tt_shuss,
				   opt_pack_duo_journee,
				   opt_vacances,
				   opt_pass_vacances,
				   opt_pass_vacances_v2,
				   opt_pass_voyage_6E,
				   opt_pass_vacances_z2,
				   opt_pass_voyage_9E,
				   opt_j_omwl,
				   opt_orange_messenger,
				   opt_msn_journee_mobi,
				   opt_msn_mensu_mobi,
				   opt1_tele2_cb_25sms,
				   opt1_tele2_cb_50sms,
				   opt1_tele2_cb_100sms,
				   opt1_tele2_cb_illsms,
				   opt_illimite_kdo,
				   opt_tv,opt_tv_max,
				   opt_internet,
				   opt_internet_max,
				   opt_mes_vocale_visuelle,
				   opt_mail,
				   opt_unik_pour_zap_tous_operator
				  ]}},
        "This parameter specifies the option."},
       {uact, {link,[]},
	"This parameter specifies the next page when the option"
	" is already activated."},
       {uincomp, {link,[]},
	"This parameter specifies the next page when the option"
	" is incompatible with existing options."},
       {uinsuf, {link,[]},
	"This parameter specifies the next page when there is"
	" not enough credit on the account to subscribe to the option."},
       {ugene, {link,[]},
	"This parameter specifies the next page when subscription is allowed"}
      ]});

first_page(abs, Subscription, Opt, UAct, UIncomp, UInsuf, UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UIncomp},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene}];

first_page(Session, "mobi", Option, UAct, UIncomp, UInsuf, UGene) ->
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    Price = svc_util_of:subscription_price(Session, Opt),
    Curr = currency:sum(euro,Price/1000),
    Enough_credit = svc_options_mobi:enough_credit(State, {Curr, Opt}),
    Credit_bp = svc_options:credit_bons_plans_ac(State, {Curr,Opt}),
    next_page(Session, Opt, UAct, UIncomp, UInsuf, UGene,
	      Enough_credit, Credit_bp);
first_page(Session, Subscription, Option, UAct, UIncomp, UInsuf, UGene)
when (Option=="opt_unik_pour_zap_tous_operator") ->
    Opt = list_to_atom(Option),
    {_,Session_}= svc_util_of:reinit_compte(Session),
    State = svc_util_of:get_user_state(Session_),
    case svc_subscr_asmetier:is_option_activated(Session_, Opt, State) of
        true ->
            {redirect,Session_,UAct};
        false ->
	    Price = svc_util_of:subscription_price(Session_, Opt),
	    Curr = currency:sum(euro,Price/1000),
	    Credit_bp = svc_options:credit_bons_plans_ac(State, {Curr,Opt}),    
	    case {svc_compte:etat_cpte(State,cpte_princ),svc_options:enough_credit(State,Curr)} of 
		{?CETAT_AC,true} -> 
		    svc_subscr_asmetier:get_impactSouscrServiceOpt(Session_,
								   Subscription, Option,UAct,UIncomp,"#errorMsg",UGene);
		_ ->
 		    List = State#sdp_user_state.cpte_list, 		    
 		    case List of 
 			undefined ->
 			    {redirect,Session_,UInsuf};
 			_ -> 
			    case check_enough_credit(State,Curr,List) of 
				true ->
				    svc_subscr_asmetier:get_impactSouscrServiceOpt(Session_, Subscription, 
										   Option,UAct,UIncomp,"#errorMsg",UGene);
				_ ->
				    {redirect,Session_,UInsuf}
			    end		    
		    end
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type next_page(session(),Opt::atom(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string(),Enough_credit::bool(),Credit_bp::bool())->
%%                  erlpage_result(). 
%%%% Internal function used by plugin first_page.

next_page(Session, Opt, UAct, UIncomp, UInsuf, UGene, Enough_credit,
	  Credit_bp)->
    {Session_new,State_New} = svc_options:check_topnumlist(Session),
    Subscr = svc_util_of:get_souscription(Session_new),
    case {is_subscribed(Session_new, Opt, Subscr),is_resubscr_allowed(Opt)} of
	{true,false} ->
	    {redirect,Session_new,UAct};
	_ ->
	    case is_option_incomp(Session_new,Opt) of
		[] ->
		    case {(svc_compte:etat_cpte(State_New,
						cpte_bons_plans)==?CETAT_AC),                              
			  Credit_bp} of
			{true,true} -> 
			    {redirect,Session_new,UGene};
			_ ->
			    case Enough_credit of
				false ->
				    {redirect,Session_new,UInsuf};
				true  ->
				    {redirect,Session_new,UGene}
			    end
		    end;
		List ->
		    Session_incomp = 
			variable:update_value(Session_new,
					      {incomp, Opt},
					      List),
		    {redirect,Session_incomp,UIncomp}    
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_subscribed(session(),Opt::atom(),Subscr::string())->
%%                     bool().
%%%% Internal function used by plugin first_page.

is_subscribed(Session, Opt, Subscr)
  when Subscr==cmo,
       ((Opt==pack_sms) or
	(Opt==pack_mms) or
	(Opt==opt_tt_shuss) or
	(Opt==opt_pack_duo_journee) or
	(Opt==opt_pass_vacances) or
	(Opt==opt_pass_vacances_v2) or
	(Opt==opt_pass_voyage_6E) or
	(Opt==opt_pass_vacances_z2) or
	(Opt==opt_pass_voyage_9E) or
	(Opt==opt_pass_dom) or
	(Opt==opt_roaming) or
	(Opt==opt_seminf) or
	(Opt==opt_afterschool) or
	(Opt==opt_jinf) or
	(Opt==opt_j_app_ill) or
	(Opt==opt_s_app_ill) or
	(Opt==opt_j_mm_ill) or
	(Opt==opt_s_mm_ill) or
	(Opt==opt_ssms_ill) or
	(Opt==opt_jsms_ill) or
	(Opt==opt_sms_surtaxe) or
	(Opt==opt_orange_messenger) or
	(Opt==opt_j_omwl)) ->
    svc_options:is_option_activated(Session,Opt);

is_subscribed(Session, Opt, Subscr)
  when Subscr==mobi,
       ((Opt==opt_tt_shuss) or
		(Opt==opt_pack_duo_journee) or
	(Opt==opt_cb_mobi) or
	(Opt==opt_jinf) or
	(Opt==opt_roaming) or
	(Opt==opt_appelprixunique) or
	(Opt==opt_afterschool) or
	(Opt==opt_sms_quoti) or
	(Opt==opt_pass_vacances) or
	(Opt==opt_pass_vacances_v2) or
		(Opt==opt_pass_voyage_6E) or
	(Opt==opt_pass_vacances_z2) or
		(Opt==opt_pass_voyage_9E) or
	(Opt==opt_illimite_kdo) or
	(Opt==opt_ikdo_vx_sms) or
	(Opt==opt_surf_mensu) or
	(Opt==opt_ow_6E_mobi) or
	(Opt==opt_msn_mensu_mobi) or
	(Opt==opt_msn_journee_mobi)) ->
    svc_options:is_option_activated(Session,Opt);

is_subscribed(Session, Opt, Subscr) ->
    State = svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,svc_options:opt_to_godet(Opt,Subscr)) of
	#compte{etat=?CETAT_AC} ->
	    svc_options:is_option_activated(Session,Opt);
	_ -> false
    end.

is_resubscr_allowed(Opt)
  when  Opt==opt_pass_dom->
    true;
is_resubscr_allowed(_) ->
    false.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_incomp(session(),Opt::string())->
%%                        string().
%%%% Internal funtion used by plugin first_page.
%%%% Check incompatibilities between options.

is_option_incomp(Session,opt_pass_vacances) ->
  svc_options:list_active_options(Session,[opt_europe, 
					   opt_maghreb, 
					   opt_pass_voyage_6E,
					   opt_pass_voyage_9E]);

is_option_incomp(Session,Opt)
when Opt==opt_pass_vacances_v2;Opt==opt_pass_voyage_6E ->
  svc_options:list_active_options(Session,[opt_europe, 
					   opt_maghreb, 
					   opt_pass_voyage_9E]);

is_option_incomp(Session,Opt)
when Opt==opt_pass_vacances_z2;Opt==opt_pass_voyage_9E ->
    svc_options:list_active_options(Session,[opt_europe, 
					     opt_maghreb, 
					     opt_pass_voyage_6E,
					     opt_roaming
					     ]);

is_option_incomp(Session,opt_europe) ->
    case {svc_options:is_option_activated(Session,opt_maghreb),
	  svc_options:is_option_activated(Session,opt_pass_vacances)} of
	{true, true} ->
	    [opt_maghreb, opt_pass_vacances];
	{true, _} ->
	    [opt_maghreb];
	{_, true} ->
	    [opt_pass_vacances];
	{_, _} ->
	    []
    end;

is_option_incomp(Session,opt_maghreb) ->
    case {svc_options:is_option_activated(Session,opt_europe),
	  svc_options:is_option_activated(Session,opt_pass_vacances)} of
	{true, true} ->
	    [opt_europe, opt_pass_vacances];
	{true, _} ->
	    [opt_europe];
	{_, true} ->
	    [opt_pass_vacances];
	{_, _} ->
	    []
    end;

is_option_incomp(Session,opt_ssms) ->
    case svc_options:is_option_activated(Session,opt_sms_hebdo) of
	true ->
	    [opt_sms_hebdo];
	_ ->
	    []
    end;

is_option_incomp(Session,Opt)
when Opt==opt_tt_shuss;Opt==opt_pack_duo_journee ->
    case svc_options:is_option_activated(Session,opt_vacances) of
	true ->
	    [opt_vacances];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_vacances) ->
    case svc_options:is_option_activated(Session,opt_pack_duo_journee) of
	true ->
	    [opt_pack_duo_journee];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_erech_smsmms) ->
    case {svc_options:is_option_activated(Session,opt_pack_duo_journee),
	  svc_options:is_option_activated(Session,opt_vacances)} of
	{true, true} ->
	    [opt_pack_duo_journee, opt_vacances];
	{true, _} ->
	    [opt_pack_duo_journee];
	{_, true} ->
	    [opt_vacances];
	{_, _} ->
	    []
    end;

is_option_incomp(Session,opt_jinf) ->
    case {svc_options:is_option_activated(Session,opt_sinf),
	  svc_options:is_option_activated(Session,opt_seminf)} of
	{true, true} ->
	    [opt_sinf, opt_seminf];
	{true, _} ->
	    [opt_sinf];
	{_, true} ->
	    [opt_seminf];
	{_, _} ->
	    []
    end;

is_option_incomp(Session,opt_j_app_ill) ->
    L = [opt_sinf, opt_ssms, opt_jinf, opt_weinf, opt_s_app_ill],
    [X || X <- L,svc_options:is_option_activated(Session,X) =:= true];

is_option_incomp(Session,opt_s_app_ill) ->
    L = [opt_sinf, opt_ssms, opt_jinf, opt_weinf, opt_j_app_ill],
    [X || X <- L,svc_options:is_option_activated(Session,X) =:= true];

is_option_incomp(Session,opt_j_mm_ill) ->
    case {svc_options:is_option_activated(Session,opt_sinf),
	  svc_options:is_option_activated(Session,opt_ssms),
	  svc_options:is_option_activated(Session,opt_jinf),
	  svc_options:is_option_activated(Session,opt_weinf)} of
	{true, true, true, true} ->
	    [opt_sinf, opt_ssms, opt_jinf, opt_weinf];
	{true, true, true, _} ->
	    [opt_sinf, opt_ssms, opt_jinf];
	{true, true, _, true } ->
	    [opt_sinf, opt_ssms, opt_weinf];
	{true, true, _, _} ->
	    [opt_sinf, opt_ssms];
	{true, _, true, true} ->
	    [opt_sinf, opt_jinf, opt_weinf];
	{true, _, true, _} ->
	    [opt_sinf, opt_jinf];
	{true, _, _, true} ->
	    [opt_sinf, opt_weinf];
	{true, _, _, _} ->
	    [opt_sinf];
	{_, true, true, true} ->
	    [opt_ssms, opt_jinf, opt_weinf];
	{_, true, true, _} ->
	    [opt_ssms, opt_jinf];
	{_, true, _, true} ->
	    [opt_ssms, opt_weinf];
	{_, true, _, _} ->
	    [opt_ssms];
	{_, _, true, true} ->
	    [opt_jinf, opt_weinf];
	{_, _, true, _} ->
	    [opt_jinf];
	{_, _, _, true} ->
	    [opt_weinf];
	{_, _, _, _} ->
	    []
    end;

is_option_incomp(Session,opt_s_mm_ill) ->
    case {svc_options:is_option_activated(Session,opt_sinf),
	  svc_options:is_option_activated(Session,opt_ssms),
	  svc_options:is_option_activated(Session,opt_jinf),
	  svc_options:is_option_activated(Session,opt_weinf)} of
	{true, true, true, true} ->
	    [opt_sinf, opt_ssms, opt_jinf, opt_weinf];
	{true, true, true, _} ->
	    [opt_sinf, opt_ssms, opt_jinf];
	{true, true, _, true } ->
	    [opt_sinf, opt_ssms, opt_weinf];
	{true, true, _, _} ->
	    [opt_sinf, opt_ssms];
	{true, _, true, true} ->
	    [opt_sinf, opt_jinf, opt_weinf];
	{true, _, true, _} ->
	    [opt_sinf, opt_jinf];
	{true, _, _, true} ->
	    [opt_sinf, opt_weinf];
	{true, _, _, _} ->
	    [opt_sinf];
	{_, true, true, true} ->
	    [opt_ssms, opt_jinf, opt_weinf];
	{_, true, true, _} ->
	    [opt_ssms, opt_jinf];
	{_, true, _, true} ->
	    [opt_ssms, opt_weinf];
	{_, true, _, _} ->
	    [opt_ssms];
	{_, _, true, true} ->
	    [opt_jinf, opt_weinf];
	{_, _, true, _} ->
	    [opt_jinf];
	{_, _, _, true} ->
	    [opt_weinf];
	{_, _, _, _} ->
	    []
    end;

is_option_incomp(Session,opt_ssms_ill) ->
    L = [opt_sinf, opt_ssms, opt_jinf, opt_weinf, opt_jsms_ill],
    [X || X <- L,svc_options:is_option_activated(Session,X) =:= true];

is_option_incomp(Session,opt_jsms_ill) ->
    L = [opt_sinf, opt_ssms, opt_jinf, opt_weinf, opt_ssms_ill],
    [X || X <- L,svc_options:is_option_activated(Session,X) =:= true];

is_option_incomp(Session,opt_sinf) ->
    case {svc_options:is_option_activated(Session,opt_jinf),
	  svc_options:is_option_activated(Session,opt_seminf)} of
	{true, true} ->
	    [opt_jinf, opt_seminf];
	{true, _} ->
	    [opt_jinf];
	{_, true} ->
	    [opt_seminf];
	{_, _} ->
	    []
    end;
is_option_incomp(Session,opt_seminf) ->
    case {svc_options:is_option_activated(Session,opt_jinf),
	  svc_options:is_option_activated(Session,opt_sinf)} of
	{true, true} ->
	    [opt_jinf, opt_sinf];
	{true, _} ->
	    [opt_jinf];
	{_, true} ->
	    [opt_opt_sinf];
	{_, _} ->
	    []
    end;

is_option_incomp(Session,opt_j_omwl) ->
    case svc_options:is_option_activated(Session,opt_orange_messenger) of
	true ->
	    [opt_orange_messenger];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_msn_journee_mobi) ->
    case svc_options:is_option_activated(Session,opt_msn_mensu_mobi) of
	true ->
	    [opt_msn_mensu_mobi];
	_ ->
	    []
    end;
is_option_incomp(Session,opt_musique) ->
    case svc_options:is_option_activated(Session,opt_musique_mix) of
        true ->
            [opt_musique_mix];
        _ ->
            []
    end;
is_option_incomp(Session,opt_tv_max) ->
    case svc_options:is_option_activated(Session,opt_tv) of
	true ->
	    [opt_tv];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_tv) ->
    case svc_options:is_option_activated(Session,opt_tv_max) of
	true ->
	    [opt_tv_max];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_internet) ->
    case svc_options:is_option_activated(Session,opt_internet_max) of
	true ->
	    [opt_internet_max];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_internet_max) ->
    case svc_options:is_option_activated(Session,opt_internet) of
	true ->
	    [opt_internet_max];
	_ ->
	    []
    end;

is_option_incomp(Session,opt_mail) ->
    case svc_options:is_option_activated(Session,opt_mail) of
	true ->
	    [];
	_ ->
	    []
    end;

is_option_incomp(_,_) -> 
    [].
%subscribe/6()
subscribe(plugin_info, UAct, UInsuf, UIncom, UNok, Uok_princ) ->
    (#plugin_info
     {help =
      "This plugin command send the subscription request and redirects to"
      " the page corresponding to the result of the subscription.\n"
      "Searches for subscription and option values in the session variables.",
      type = command,
      license = [],
      args =
      [
       {uact, {link,[]},
	"This parameter specifies the next page when the option"
	" is already activated."},
       {uinsuf, {link,[]},
	"This parameter specifies the next page when there is"
	" not enough credit on the account to subscribe to the option."},
       {uincomp, {link,[]},
	"This parameter specifies the next page when there is"
	" incompatible option."},
       {unok, {link,[]},
	"This parameter specifies the next page in case of a"
	" technical problem"},
       {uok_princ, {link,[]},
	"This parameter specifies the next page when subscription is allowed with the principal acount"}
      ]});

subscribe(abs, UAct, UInsuf, UIncomp, UNok, Uok_princ) ->
    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,Uok_princ},
     {redirect,abs,UIncomp},
     {redirect,abs,UNok}];

subscribe(#session{prof=Prof}=Session, UAct, UInsuf, UIncomp,UNok, Uok_princ) ->
    Service=variable:get_value(Session, {"bons_plans","option"}),	
    Opt=list_to_atom(Service),
    {NewSession,Result} = 
	case Opt of 
            opt_internet_max_journee ->
                case svc_options_mobi:is_option_incomp(Session, Opt) of
                    true ->
                        {Session,{nok_opt_incompatible,""}};
                    _ ->
                        svc_options:do_opt_cpt_request(Session ,Opt,subscribe)
                end;

	    _ ->
		svc_options:do_opt_cpt_request(Session ,Opt,subscribe)
	end,
    Uopt_bloquee=get_url_blocked(NewSession),
    case Result of
        %% In Sachem Tuxedo, we do not have account info
	{opt_bloquee_101,_} ->
	    Session2=svc_options_mobi:set_current_option(NewSession,Opt),
	    {redirect,Session2,Uopt_bloquee};
        {error, "option_incompatible_sec"} ->
	    Session2=svc_options_mobi:set_current_option(NewSession,Opt),
	    {redirect,Session2,Uopt_bloquee};
        Status ->
            svc_options:redirect_update_option(NewSession, Status, Uok_princ, 
                                               UAct, UInsuf, UIncomp, 
                                               Uopt_bloquee, UNok)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subscribe/7
%% +type subscribe(session(),Subscription::string(),Option::string(),
%%                 UAct::string(),UInsuf::string(),
%%                 UGene::string(), UNok::string())->
%%                 erlpage_result(). 
%%%% Subscribe to option
%%%% Redirect to UAct when option already active,
%%%% redirect to UInsuf when not enough credit,
%%%% redirect to UGene when subscription proposed,
%%%% redirect to UNok in case of a technical problem.
	
subscribe(plugin_info, Subscription, Option, UAct, UInsuf, UGene, UNok) ->
    (#plugin_info
     {help =
      "This plugin command send the subscription request and redirects to"
      " the page corresponding to the result of the subscription.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,mobi]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [opt_weinf,
				   opt_sinf,
				   opt_jinf,
				   opt_avan_dec_zap_zone,
				   bons_plans,
				   opt_maghreb,
				   opt_europe,
				   opt_pass_dom,
				   opt_afterschool,
				   opt_ssms,
				   opt_sms_quoti,
				   opt_sms_illimite,
				   opt_tt_shuss,
				   opt_pack_duo_journee,
				   opt_vacances,
				   opt_pass_vacances,
				   opt_pass_vacances_v2,
				   opt_pass_voyage_6E,
				   opt_pass_vacances_z2,
				   opt_pass_voyage_9E,
				   opt_j_omwl,
				   opt_11_18,
				   opt_tv,
				   opt_tv_max,
				   opt_musique,
				   opt_internet,
				   opt_internet_max,
				   opt_mes_vocale_visuelle,
				   opt_school,dynamic_option,
				   opt_mail
				  ]}},
        "This parameter specifies the option."},
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

subscribe(abs, Subscription, Option, UAct, UInsuf, UGene, UNok) ->
    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene},
     {redirect,abs,UNok}];

subscribe(Session, Subscription, "opt_school", UAct, UInsuf, UGene, UNok) ->
    Zone = variable:get_value(Session, {"public","school_zone"}),
    Option = case Zone of
		 "A" -> "opt_school_zone_a";
		 "B" -> "opt_school_zone_b";
		 "C" -> "opt_school_zone_c"
	     end,
    subscribe(Session, Subscription, Option, UAct, UInsuf, UGene, UNok) ;

subscribe(Session, "cmo", "bons_plans", UAct, UInsuf, UGene, UNok) ->
    Option = svc_of_config_options_cmo:get_value(Session, "option"),
    Opt=svc_of_config_options_cmo:service_to_option(Option),
    {NewSession,Result} = svc_options:do_opt_cpt_request(Session,Opt,subscribe),
    svc_options:redirect_update_option(NewSession, Result, UGene, UAct, 
                                       UInsuf, UNok, UNok);

subscribe(Session, Subscription, Option, UAct, UInsuf, UGene, UNok) 
  when Subscription=="cmo",
       ((Option=="opt_weinf") or
	(Option=="opt_sinf") or
	(Option=="opt_jinf") or
	(Option=="opt_avan_dec_zap_zone") or
	(Option=="opt_j_app_ill") or
	(Option=="opt_s_app_ill") or
	(Option=="opt_j_mm_ill") or
	(Option=="opt_s_mm_ill") or
	(Option=="opt_ssms_ill") or
	(Option=="opt_jsms_ill") or
	(Option=="opt_j_tv_max_ill") or
	(Option=="opt_s_tv_max_ill") or
	(Option=="opt_afterschool") or
	(Option=="opt_ssms") or
	(Option=="opt_sms_quoti") or
	(Option=="opt_sms_illimite") or
	(Option=="opt_vacances") or
	(Option=="opt_j_omwl") or
	(Option=="opt_tv") or
	(Option=="opt_tv_max") or
	(Option=="opt_musique") or
	(Option=="opt_mes_vocale_visuelle") or 
	(Option=="opt_school_zone_a") or
	(Option=="opt_school_zone_b") or
	(Option=="opt_school_zone_c") or 
	(Option=="opt_europe") or 
	(Option=="opt_maghreb") or 
	(Option=="opt_pass_dom") or
	(Option=="opt_mail")) ->
    Opt=list_to_atom(Option),
    {NewSession,Result} = svc_options:do_opt_cpt_request(Session,Opt,subscribe),
    svc_options:redirect_update_option(NewSession, Result, UGene, UAct, 
                                       UInsuf, UNok, UNok);

subscribe(Session, Subscription, Option, UAct, UInsuf, UGene, UNok)
  when Subscription=="cmo",
       Option=="opt_tt_shuss";
       Option=="opt_pass_vacances";
       Option=="opt_pass_vacances_v2";
       Option=="opt_pass_voyage_6E";
       Option=="opt_pass_vacances_z2";
       Option=="opt_pass_voyage_9E";
       Option=="opt_internet";
       Option=="opt_internet_max";
       Option=="opt_mail"
       ->

    case Option of
	"opt_tt_shuss"         -> Opt=[opt_tt_shuss_sms,opt_tt_shuss_voix];
	"opt_pass_vacances"    -> Opt=[opt_pass_vacances_moc,opt_pass_vacances_mtc];
	"opt_pass_vacances_v2" -> Opt=[opt_pass_vacances_v2_moc,opt_pass_vacances_v2_mtc,opt_pass_vacances_v2_10_sms];
	"opt_pass_vacances_z2" -> Opt=[opt_pass_vacances_z2_moc,opt_pass_vacances_z2_mtc,opt_pass_vacances_z2_sms];
	"opt_internet"         -> Opt=[opt_internet,opt_internet_bis];
	"opt_internet_max"     -> Opt=[opt_internet_max,opt_internet_max_bis];
	"opt_mail" ->Opt=[opt_mail];
	_ ->
	    Opt=list_to_atom(Option)
    end,
    {NewSession,Result} = case is_list(Opt) of 
			      true -> 
				  svc_options:do_nopt_cpt_request(Session,Opt,subscribe,[]);
			      _ ->
				  svc_options:do_opt_cpt_request(Session,Opt,subscribe)
			  end,
    svc_options:redirect_update_option(NewSession, Result, UGene, UAct, 
				       UInsuf, UNok, UNok, UNok);
subscribe(Session, Subscription, Option, UAct, UInsuf, UGene, UNok)
  when Subscription=="mobi",
       Option=="dynamic_option" ->
    Service=variable:get_value(Session, {"bons_plans","option"}),
    Opt=service_to_option(Service),
    {NewSession,Result} = svc_options:do_opt_cpt_request(Session ,Opt,subscribe),
    svc_options:redirect_update_option(NewSession, Result, UGene, UAct, 
                                       UInsuf, UNok, UNok).
%%subscribe/8
subscribe(abs, Subscription, Option, UAct, UInsuf, UIncomp, UGene, UNok) ->

    [{redirect,abs,UAct},
     {redirect,abs,UInsuf},
     {redirect,abs,UIncomp},
     {redirect,abs,UGene},
     {redirect,abs,UNok}];
subscribe(Session, Subscription, Option, UAct, UInsuf, UIncomp, UGene, UNok)
 when Subscription=="cmo",
      ((Option=="opt_europe") or
       (Option=="opt_maghreb") or
       (Option=="opt_pass_dom") or
       (Option=="opt_pass_voyage_6E") or
       (Option=="opt_pass_voyage_9E"))->
    Opt=list_to_atom(Option),
        {NewSession,Result} = svc_options:do_opt_cpt_request(Session,Opt,subscribe),
        svc_options:redirect_update_option(NewSession, Result, UGene, UAct,
                                       UInsuf, UIncomp, UNok, UNok).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type subscribe(session(),Subscription::string(),Option::string(),
%%                 UGene::string(), UNok::string())->
%%                 erlpage_result(). 
%%%% redirect to UGene when subscription proposed,
%%%% redirect to UNok in case of a technical problem.

subscribe(plugin_info, Subscription, Option, UGene, UNok) ->
    (#plugin_info
     {help =
      "This plugin command send the subscription request and redirects to"
      " the page corresponding to the result of the subscription.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,postpaid]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [plan_zap,
				   opt_orange_messenger_gpro,
				   ow_spo,
				   ow_surf,
				   opt_mail,
				   ow_tv,
				   ow_tv2,
				   ow_musique,
				   ow_tv_mus_surf,
				   media_decouvrt,
				   media_internet,
				   opt_orange_messenger,
				   opt_tv_gpro,
				   ow_tv_promo_gpro,
				   opt_internet_gpro,
                                   opt_internet_promo_gpro,
				   opt_internet_max_gpro,
				   opt_internet_max_promo_gpro, 
				   opt_plus_internet_gpro,
				   opt_orange_foot_gpro,
				   opt_orange_foot_promo_gpro,
				   opt_tv_max_gpro,
				   ow_tv_max_promo_gpro,
				   opt_mes_vocale_visuelle_gpro,
			    	   opt_mail_gpro,
			    	   opt_mail_promo_gpro,
			    	   opt_mail_MMS_gpro,
			    	   opt_mail_MMS_promo_gpro,
			    	   opt_orange_maps_gpro,
			    	   opt_orange_maps_promo_gpro,
			    	   opt_giga_mail_gpro,
			    	   opt_giga_mail_promo_gpro,
				   opt_mes_donnees_gpro,
				   opt_mes_donnees_promo_gpro,
				   opt_iphone_3g_gpro,
				   opt_mail_blackberry_gpro,
				   opt_mail_blackberry_promo_gpro,
				   opt_unik_tout_operateur,
				   opt_unik_pour_zap_tous_operator,
				   opt_zap_vacances,
				   opt_avan_dec_zap_zone,
				   opt_11_18,
                                   opt_lyon_promo_gpro,
                                   opt_marseille_promo_gpro,
                                   opt_paris_promo_gpro,
                                   opt_bordeaux_promo_gpro,
                                   opt_lens_promo_gpro,
                                   opt_saint_etienne_promo_gpro,
				   opt_musique_mix_gpro, 
				   opt_musique_collection_gpro
				]
}},
        "This parameter specifies the option."},
       {ugene, {link,[]},
	"This parameter specifies the next page when subscription is allowed"},
       {unok, {link,[]},
	"This parameter specifies the next page in case of a"
	" technical problem"}
      ]});

subscribe(abs, Subscription, Option, UGene, UNok) ->
    [{redirect,abs,UGene},
     {redirect,abs,UNok}];

subscribe(Session, Subscription, "opt_zap_vacances", UGene, UNok) ->
    %% Get subscribed option to remove
    OldOption = case {svc_options:is_option_activated(Session,opt_school_zone_a),
		      svc_options:is_option_activated(Session,opt_school_zone_b),
		      svc_options:is_option_activated(Session,opt_school_zone_c)} of
		    {true,_,_}->
			opt_school_zone_a;
		    {_,true,_}->
			opt_school_zone_b;
		    {_,_,true}->
			opt_school_zone_c;
		    {_,_,_} ->
			[]
		end,
    {Error,Session1} = case OldOption of 
			   [] -> 
			       %% Case of declaration (no subscribed option)
			       {no_error,Session};
			   _ ->
			       %% Case of change zone, unsubscribe subscribed option
			       case (svc_options:do_opt_cpt_request(Session,OldOption,terminate)) of
				   {NewSession,{ok_operation_effectuee,_}} ->
				       %% reset user account information
				       svc_util_of:reinit_compte(NewSession);
				   Err ->
				       {error,Session}
			       end
		       end,
    case Error of
	error ->
	    %% Unsubscribe not ok
	    {redirect, Session, UNok};
	_ ->
	    %% Unsubscribed ok or no unsubscribe needed
	    Zone = variable:get_value(Session, {"public","school_zone"}),
	    Option = case Zone of
			 "A" -> "opt_school_zone_a";
			 "B" -> "opt_school_zone_b";
			 "C" -> "opt_school_zone_c"
		     end,
	    Opt=list_to_atom(Option),
	    %% Subscribe new zone
	    case svc_options:do_opt_cpt_request(Session1,Opt,subscribe) of
		{Session2,{ok_operation_effectuee,_}} ->
		    %% reset user account information
		    {_,Session_}= svc_util_of:reinit_compte(Session2),
		    {redirect, Session_, UGene};
		{Session2,E} ->
		    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
		    {redirect, Session2, UNok}
	    end
    end;

subscribe(Session, Subscription, Option, UGene, UNok)
  when (Subscription=="cmo") and
       ((Option == "ow_tv") or (Option == "ow_tv2") or
	(Option == "ow_spo") or (Option == "ow_surf") or
	(Option == "ow_musique") or (Option == "ow_tv_mus_surf") or
	(Option == "media_decouvrt") or (Option == "media_internet") or
	(Option == "opt_orange_messenger") or (Option == "opt_11_18") or 
	(Option=="opt_mail")) ->
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, 
						  code_opt(Session, Opt),
						 Opt) of
	{ok,NewSess} ->
	    OptActiv = svc_subscr_asmetier:cast(Session),
	    NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
	    {redirect,update_session(NewSess,NewOptActiv),UGene};
	error_msg -> 
	    {redirect,Session,UNok};
	E -> 
	    {redirect,Session,UNok}
    end;
subscribe(Session, Subscription, Option, UGene, UNok)
  when (Subscription=="cmo") and (Option == "opt_unik_pour_zap_tous_operator") ->
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, 
						  code_opt(Session, Opt),
						 Opt) of
	{ok,NewSess} ->
	    OptActiv = svc_subscr_asmetier:cast(Session),
	    NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
	    {redirect,update_session(NewSess,NewOptActiv),UGene};
	error_msg -> 
	    {redirect,Session,UNok};
	E -> 
	    {redirect,Session,UNok}
    end;
subscribe(Session, Subscription, Option, UGene, UNok)
  when (Subscription=="postpaid")->
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, 
						  code_opt(Session, Opt),
						 Opt) of
	{ok,NewSess} ->
	    OptActiv = svc_subscr_asmetier:cast(Session),
	    NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
	    {redirect,update_session(NewSess,NewOptActiv),UGene};
	error_msg -> 
	    {redirect,Session,UNok};
	E -> 
	    {redirect,Session,UNok}
    end;

subscribe(#session{prof=Profile}=Session_, Subscription, Option, UGene, UNok)
  when Subscription=="cmo",
       Option=="plan_zap" ->
    {_, Session} = svc_util_of:reinit_compte(Session_),
    State = svc_util_of:get_user_state(Session),
    Msisdn = Profile#profile.msisdn,
    DCL = svc_compte:dcl(State),
    %% do 2 g2 request

    case svc_selfcare_cmo:do_activ_plan_zap(Session, Msisdn,DCL) of
	{ok,_} when DCL==?zap_cmo->
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = 
		svc_util_of:update_state(Session,
					 [{cpte_princ,
					   C_PRINC#compte{ptf_num=
							  ?CMO_ZAP_PROMO}},
					  {cpte_voix,
					   C_VOIX#compte{ptf_num=
							 ?CMO_ZAP_PROMO}}]),
	    {redirect, S2, UGene};
	{ok,_} when DCL==?ppol2->
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 =
		svc_util_of:update_state(
		  Session,
		  [{cpte_princ,C_PRINC#compte{ptf_num=?CMO_ZAP_PROMO_PPOL2}},
		   {cpte_voix,C_VOIX#compte{ptf_num=?CMO_ZAP_PROMO_PPOL2}}]),
	    {redirect, S2, UGene};
	{ok,_} when DCL==?zap_vacances; DCL==?zap_cmo_25E->
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = 
		svc_util_of:update_state(Session,
					 [{cpte_princ,
					   C_PRINC#compte{ptf_num=
							  ?CMO_ZAP_PROMO}},
					  {cpte_voix,
					   C_VOIX#compte{ptf_num=
							 ?CMO_ZAP_PROMO}}]),
	    {redirect, S2, UGene};
	{ok,_} when DCL==?zap_cmo_1h30_v2->
	    C_PRINC =svc_compte:cpte(State,cpte_princ),
	    C_VOIX  =svc_compte:cpte(State,cpte_voix),
	    S2 = 
		svc_util_of:update_state(Session,
					 [{cpte_princ,
					   C_PRINC#compte{ptf_num=
							  ?CMO_ZAP_PROMO}},
					  {cpte_voix,
					   C_VOIX#compte{ptf_num=
							 ?CMO_ZAP_PROMO}}]),
	    {redirect, S2, UGene};
	_ ->
	    {redirect,Session,UNok}
    end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASMETIER PLUGINS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_OptASM_state(session(),Subscription::string(),Opt::string(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string())->
%%                  erlpage_result(). 
%%%% First page for subscription of option.
%%%% Redirect to UAct when option already active,
%%%% redirect to UIncomp when option incompatible with existing options,
%%%% redirect to UInsuf when not enough credit,
%%%% redirect to UGene when subscription proposed.
	
redirect_OptASM_state(plugin_info, Subscription, Opt, UAct, UIncomp, 
		      ErrorMsg, UGene) ->
    (#plugin_info
     {help =
      "",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,postpaid]}},
        "This parameter specifies the subscription."},
       {option, {oma_type, {enum, [ow_spo,
				   ow_surf,
				   ow_tv,
				   ow_tv2,
				   ow_musique,
				   ow_tv_mus_surf,
				   media_decouvrt,
				   media_internet,
				   opt_30_sms_mms,
				   opt_80_sms_mms,
				   opt_130_sms_mms,
				   opt_sms_mms_illimites,
				   opt_orange_messenger,
				   opt_30_sms_mms_gpro,
				   opt_80_sms_mms_gpro,
				   opt_130_sms_mms_gpro,
				   opt_sms_mms_ill_gpro,
				   opt_orange_messenger_gpro,
				   opt_tv_gpro,
				   opt_internet_gpro,
				   opt_plus_internet_gpro,
				   opt_orange_foot_gpro,
				   opt_orange_sport_gpro,
				   opt_tv,
				   opt_tv_max,
				   opt_musique,
				   opt_internet,
				   opt_internet_max,
				   opt_mes_vocale_visuelle,
				   opt_tv_max_gpro,
				   opt_internet_gpro,
				   opt_internet_max_gpro,
				   opt_mes_vocale_visuelle_gpro,
				   opt_unik_tout_operateur,
				   opt_mail_gpro,
				   opt_giga_mail_gpro,
				   opt_mail_MMS_gpro,
                                   opt_orange_maps,
				   opt_orange_maps_gpro,
				   opt_mail,
				   opt_musique_mix,
				   opt_musique_collection,
				   opt_foot_ligue1,
				   opt_orange_sport,
                                   opt_mes_donnees,
				   opt_mes_donnees_gpro,
				   opt_iphone_3g_gpro,
				   opt_mail_blackberry_gpro,
				   opt_lyon,opt_lyon_gpro,
                                   opt_marseille,opt_marseille_gpro,opt_marseille_pro,
                                   opt_paris,opt_paris_gpro,
                                   opt_bordeaux,opt_bordeaux_gpro,
                                   opt_lens,opt_lens_gpro,
                                   opt_saint_etienne,opt_saint_etienne_gpro,
				   opt_musique_mix_gpro,
				   opt_musique_collection_gpro
				   ]}},
        "This parameter specifies the option."},
       {uact, {link,[]},
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

redirect_OptASM_state(abs, Subscription, Option, UAct, UIncomp, ErrorMsg , UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UGene}]++
	 svc_subscr_asmetier:get_impactSouscrServiceOpt(abs, Subscription, 
	     Option,UAct,UIncomp,ErrorMsg,UGene);

redirect_OptASM_state(Session, Subscription, Option, UAct, UIncomp, 
		      ErrorMsg, UGene)
  when ((Option =="ow_spo") or (Option =="ow_surf") or
	(Option =="ow_tv") or (Option =="ow_tv2") or
	(Option =="ow_musique") or (Option =="ow_tv_mus_surf") or 
	(Option =="opt_30_sms_mms") or (Option =="opt_80_sms_mms") or (Option =="opt_130_sms_mms") or
	(Option =="opt_sms_mms_illimites") or 
	(Option =="media_decouvrt") or (Option =="media_internet") or
	(Option =="opt_orange_messenger") or (Option =="opt_mes_vocale_visuelle") or
	(Option =="opt_tv") or (Option =="opt_tv_max") or
	(Option =="opt_internet") or (Option =="opt_internet_max") or
        (Option =="opt_orange_maps") or (Option == "opt_mes_donnees") or
	(Option =="opt_mail") or
        (Option =="opt_orange_maps_gpro") or 
	(Option=="opt_musique_mix") or (Option=="opt_musique") or  (Option=="opt_musique_collection")
	or (Option=="opt_foot_ligue1") or
	(Option=="opt_orange_sport") or
        (Option =="opt_lyon") or (Option =="opt_marseille") or
	(Option =="opt_paris") or (Option =="opt_bordeaux") or
	(Option =="opt_lens") or (Option =="opt_saint_etienne"))
       and  (Subscription == "cmo")->
    State = svc_util_of:get_user_state(Session),
    Opt = list_to_atom(Option),
    case svc_subscr_asmetier:is_option_activated(Session, Opt, State) of
	true ->
	    {redirect,Session,UAct};
	false ->
	    svc_subscr_asmetier:get_impactSouscrServiceOpt(Session, 
		 Subscription, Option,UAct,UIncomp,ErrorMsg,UGene)
    end;   
 
redirect_OptASM_state(Session, Subscription, Option, UAct, UIncomp, 
		      ErrorMsg, UGene)
  when Subscription == "postpaid"->
    State = svc_util_of:get_user_state(Session),
    Opt = list_to_atom(Option),
    case svc_subscr_asmetier:is_option_activated(Session, Opt, State) of
	true ->
	    {redirect,Session,UAct};
	false ->
	    svc_subscr_asmetier:get_impactSouscrServiceOpt(Session, 
		 Subscription, Option,UAct,UIncomp,ErrorMsg,UGene)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Obsolete
asm_GetIdentification(plugin_info, Subscription, Mode, Menu, Error) ->
    {obsolete,{svc_of_plugins,asm_GetIdentification,4},
     [Mode, Menu, Error]};
asm_GetIdentification(Session, Subscription, Mode, Menu, Error) ->
    asm_GetIdentification(Session, Mode, Menu, Error).

%% +type asm_GetIdentification(session(),Subscription::string(),Mode::string(),
%%                  Asm_menu::string(),Asm_error::string())->
%%                  erlpage_result(). 
%%%% Redirect to  when option already active,
%%%% redirect to asm_menu when not enough credit,
%%%% redirect to asm_error when subscription proposed.
	
asm_GetIdentification(plugin_info, Mode, Menu, Error) ->
    (#plugin_info
     {help =
      "",
      type = command,
      license = [],
      args =
      [
      %% removed because of never used 
      %% {subscription, {oma_type, {enum, [cmo, mobi,postpaid]}},
      %%  "This parameter specifies the subscription."},
       {mode, {oma_type, {enum, [auto, edl, oee, edloee]}},
        "This parameter specifies the mode of getIdentification request."
        " toward ASMTIER PLATFORM."
        " edl: get identifiant Edelweiss if it is subscription is mobi (Mobicarte)."
        " oee: get identifiant Orchidee  if it's subscription is forfait bloque(cmo) or postpaid."
        " edloee : Prevent to use this value except certain situation. get identifiant Edelweiss or Orchidee "},
       {asm_menu, {link,[]},
	"This parameter specifies the next page when ASMETIER PLATFORM"
        " is in service"},
       {asm_error, {link,[]},
	"This parameter specifies the next page when ASMETIER PLATFORM"
	"respond (from get_impact request)with bad code or with unknown"
	" OptResil list code."}
      ]});
asm_GetIdentification(abs, Mode, Menu, Error) ->
   URLs = string:concat(Menu,","++Error), 
   svc_subscr_asmetier:get_identification(abs, Mode, URLs);
asm_GetIdentification(Session, Mode, Menu, Error) ->
    URLs = string:concat(Menu,","++Error),
    case Mode of
	"auto" ->
	    case (Session#session.prof)#profile.subscription of
		"mobi" ->
		    Mode1 = "edl";
		_      ->
		    Mode1 = "oee"
	    end,
	    svc_subscr_asmetier:get_identification(Session, Mode1, URLs);
	_ ->
	    svc_subscr_asmetier:get_identification(Session, Mode, URLs)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type asm_GetListServiceOptionnel(session(),Subscription::string(),
%%                  Asm_menu::string(),Asm_error::string())->
%%                  erlpage_result(). 
%%%% Redirect to  when option already active,
%%%% redirect to asm_menu when not enough credit,
%%%% redirect to asm_error when subscription proposed.
	
asm_GetListServiceOptionnel(plugin_info, Subscription, Menu, Error) ->
    (#plugin_info
     {help =
      "",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo, postpaid]}},
        "This parameter specifies the subscription."},
       {asm_menu, {link,[]},
	"This parameter specifies the next page when ASMETIER PLATFORM"
        " is in service"},
       {asm_error, {link,[]},
	"This parameter specifies the next page when ASMETIER PLATFORM"
	"respond (from get_impact request)with bad code or with unknown"
	" OptResil list code."}
      ]});
asm_GetListServiceOptionnel(abs, Subscription, Menu, Error) ->
    URLs = string:concat(Menu,","++Error),
    svc_subscr_asmetier:get_listServiceOptionnel(abs, URLs);
asm_GetListServiceOptionnel(Session, Subscription, Menu, Error)
  when Subscription == "cmo";Subscription== "postpaid"->
    URLs = string:concat(Menu,","++Error),
    svc_subscr_asmetier:get_listServiceOptionnel(Session, URLs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type asm_SetServiceOptionnel(session(),Subscription::string(),Option::string(),
%%                 UGene::strings(), UNok::string())->
%%                 erlpage_result(). 
%%%% redirect to UGene when subscription proposed,
%%%% redirect to UNok in case of a technical problem.

asm_SetServiceOptionnel(plugin_info, Subscription, Option, UGene,
			UPromo, UFunc, UNok) ->
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
       {option, {oma_type, {enum, [opt_30_sms_mms,
				   opt_80_sms_mms,
				   opt_130_sms_mms,
				   opt_sms_mms_illimites,
				   opt_30_sms_mms_gpro,
				   opt_80_sms_mms_gpro,
				   opt_130_sms_mms_gpro,
				   opt_sms_mms_ill_gpro,
                                   opt_internet_max_gpro,
                                   opt_internet_gpro,
                                   opt_mail_MMS_gpro,
                                   opt_giga_mail_gpro,
                                   opt_mail_gpro,
                                   opt_mes_donnees_gpro,
                                   opt_mail_blackberry_gpro,
                                   opt_tv_gpro,
                                   opt_tv_max_gpro,
                                   opt_orange_foot_gpro,
				   opt_orange_sport_gpro,
                                   opt_orange_maps_gpro,
				   opt_tv,opt_tv_max,
				   opt_musique,
				   opt_musique_mix,
				   opt_musique_collection,				   
				   opt_internet,opt_internet_max,
				   opt_mes_vocale_visuelle,
                                   opt_orange_maps,opt_mes_donnees,
				   opt_mail,
				   opt_foot_ligue1,
				   opt_orange_sport,
				   opt_lyon,opt_lyon_gpro,
                                   opt_marseille,opt_marseille_gpro,
                                   opt_paris,opt_paris_gpro,
                                   opt_bordeaux,opt_bordeaux_gpro,
                                   opt_lens,opt_lens_gpro,
                                   opt_saint_etienne,opt_saint_etienne_gpro,
				   opt_musique_mix_gpro,
				   opt_musique_collection_gpro
				   ]}},
        "This parameter specifies the option."},
       {ugene, {link,[]},
	"This parameter specifies the next page when subscription is allowed"},
       {upromo, {link,[]},
	"This parameter specifies the next page is case of"
	" option in promotion already used"},
       {ufunc, {link,[]},
	"This parameter specifies the next page when functional issue occurs"},
       {unok, {link,[]},
	"This parameter specifies the next page in case of a"
	" technical problem"}
      ]});

asm_SetServiceOptionnel(Session, Subscription, Option, UGene,
			UPromo, UFunc, UNok)
when Subscription == "cmo"  ->
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, 
						  code_opt(Session, Opt),
						 Opt) of
	{ok,NewSess} ->
	    OptActiv = svc_subscr_asmetier:cast(NewSess),
	    NewOptActiv = OptActiv#activ_opt{en_cours=Opt},
	    {redirect,update_session(NewSess,NewOptActiv),UGene};
	code_7 ->
	    {redirect,Session,UFunc};
	code_8 ->
	    {redirect,Session,UPromo};
	error_msg -> 
	    {redirect,Session,UNok};
	E -> 
	    {redirect,Session,UNok}
    end;
asm_SetServiceOptionnel(Session, Subscription, Option, UGene,
			UPromo, UFunc, UNok)
when Subscription == "postpaid"  ->
    Opt=list_to_atom(Option),
    case svc_subscr_asmetier:set_ServiceOptionnel(Session, 
						  code_opt(Session, Opt),
						 Opt) of
	{ok,NewSess} ->
	    {redirect,NewSess,UGene};
	code_7 ->
	    {redirect,Session,UFunc};
	code_8 ->
	    {redirect,Session,UPromo};
	error_msg -> 
	    {redirect,Session,UNok};
	E -> 
	    {redirect,Session,UNok}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO PRINT INFORMATION IN SCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_commercial_start_date(session(),Option::string(),
%%                                   Format::string()) ->
%%                                   [{pcdata,string()}].
%%%% Displays the start date defined by the configuration parameter
%%%% commercial_date_cmo, commercial_date or commercial_date_postpaid.

print_commercial_start_date(plugin_info, Option, Format) ->
    (#plugin_info
     {help =
      "This plugin function includes the commercial start date of the"
      " option.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_weinf,
				   opt_sinf,
				   opt_jinf,
				   opt_j_app_ill,
				   opt_s_app_ill,
				   opt_j_mm_ill,
				   opt_s_mm_ill,
				   opt_ssms_ill,
				   opt_jsms_ill,
				   opt_maghreb,
				   opt_europe,
				   opt_pass_dom,
				   opt_afterschool,
				   opt_ssms,
				   opt_sms_quoti,
				   opt_tt_shuss,
								   opt_pack_duo_journee,
				   opt_vacances,
				   opt_pass_vacances,
				   opt_pass_vacances_v2]}},
        "This parameter specifies the option."},
       {format, {oma_type, {defval,"",string}},
	"This parameter specifies the format of the commercial start date:"
	" dm, dmy, dmyy or dmhm."}
      ]});

print_commercial_start_date(abs, Option, Format) ->
    [{pcdata, "XX/YY/WW"}];

print_commercial_start_date(Session, Option, Format) ->
    Opt=list_to_atom(Option),
    CDate = get_commercial_date(Session, Opt),
    option_start_date(CDate, Opt, Format).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type option_start_date(CDate::term(),Opt::atom(),Format::string())->
%%                         [{pcdata,string()}].
%%%% Internal function used by plugin print_commercial_start_date.

option_start_date(CDate, Opt, Format) ->
    case CDate of
	{value, {Opt,List}} ->
	    case svc_util_of:find_interv_of_localtime(List) of
		no_interv ->
		    slog:event(internal,?MODULE,
			       opt_has_expired_trying2print_start_date,Opt),
		    [{pcdata,"XX/YY/WW"}];
		{interv,{Start,_}} ->
		    Date=svc_util_of:sprintf_datetime_by_format(Start,Format),
		    [{pcdata, lists:flatten(Date)}]
	    end;
	_ ->
	    slog:event(internal,?MODULE,{wrong_opt,print_commercial_date},Opt),
	    [{pcdata, "XX/YY/WW"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_commercial_end_date(session(),Option::string(),
%%                                 Format::string()) ->
%%                                 [{pcdata,string()}].
%%%% Displays the end date defined by the configuration parameter
%%%% commercial_date_cmo, commercial_date or commercial_date_postpaid.

print_commercial_end_date(plugin_info, Option, Format) ->
    (#plugin_info
     {help =
      "This plugin function includes the commercial end date of the"
      " option.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_weinf,
				   opt_sinf,
				   opt_jinf,
				   opt_j_app_ill,
				   opt_s_app_ill,
				   opt_j_mm_ill,
				   opt_s_mm_ill,
				   opt_ssms_ill,
				   opt_jsms_ill,
				   opt_maghreb,
				   opt_europe,
				   opt_pass_dom,
				   opt_afterschool,
				   opt_ssms,
				   opt_sms_quoti,
				   opt_tt_shuss,
				   opt_vacances,
				   opt_pass_vacances,
				   opt_pass_vacances_v2]}},
        "This parameter specifies the option."},
       {format, {oma_type, {defval,"",string}},
	"This parameter specifies the format of the commercial end date:"
       	" dm, dmy, dmyy or dmhm."}
      ]});

print_commercial_end_date(abs, Option, Format) ->
    [{pcdata, "XX/YY/WW"}];

print_commercial_end_date(Session, Option, Format) ->
    Opt=list_to_atom(Option),

    CDate = get_commercial_date(Session, Opt),
    
    option_end_date(CDate, Opt, Format).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type option_end_date(CDate::term(),Opt::atom(),Format::string())->
%%                       [{pcdata,string()}].
%%%% Internal function used by plugin print_commercial_end_date.

option_end_date(CDate, Opt, Format) -> 
    case CDate of
	{value, {Opt,List}} ->
	    case svc_util_of:find_interv_of_localtime(List) of	
		no_interv ->
		    slog:event(internal,?MODULE,
			       opt_has_expired_trying2print_end_date,Opt),
		    [{pcdata,"XX/YY/WW"}];
		{interv,{_,End}} ->
		    Date=svc_util_of:sprintf_datetime_by_format(End,Format),
		    [{pcdata, lists:flatten(Date)}]
	    end;
	_ ->	  
	    slog:event(internal,?MODULE,{wrong_opt,print_commercial_date},Opt),
	    [{pcdata, "XX/YY/WW"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_commercial_date(session(),Opt::atom())->
%%                           term(). 
%%%% Internal function used by plugins print_commercial_start_date and
%%%% print_commercial_end_date.

get_commercial_date(Session, Opt) ->
    case svc_util_of:get_souscription(Session) of
	postpaid ->
	    lists:keysearch(Opt,1,
			    pbutil:get_env(pservices_orangef,
					   commercial_date_postpaid));
	cmo -> 
	    lists:keysearch(Opt,1,pbutil:get_env(pservices_orangef,
						 commercial_date_cmo));
	_ ->
	    lists:keysearch(Opt,1,pbutil:get_env(pservices_orangef,
						 commercial_date))
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_option_price(session(),Option::string(),Unit::string())->
%%                          [{pcdata,string()}].
%%%% Print price, unit displayed is defined by Txt.

print_option_price(plugin_info, Option, Unit) ->
    (#plugin_info
     {help =
      "This plugin function includes the option price.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_weinf,
				   opt_sinf,
				   opt_jinf,
				   opt_j_app_ill,
				   opt_s_app_ill,
				   opt_j_mm_ill,
				   opt_s_mm_ill,
				   opt_ssms_ill,
				   opt_jsms_ill,
				   opt_maghreb,
				   opt_europe,
				   opt_pass_dom,
				   opt_afterschool,
				   opt_ssms,
				   opt_sms_quoti,
				   opt_sms_illimite,
				   opt_tt_shuss,
								   opt_pack_duo_journee,
				   opt_vacances,
				   opt_pass_vacances,opt_pass_vacances_v2,opt_pass_vacances_z2,
								   opt_pass_voyage_6E,opt_pass_voyage_9E,
				   opt_j_omwl,
				   opt_orange_messenger,
				   opt_msn_journee_mobi,
				   opt_msn_mensu_mobi
				  ]}},
        "This parameter specifies the option."},
       {unit, {oma_type, {defval,"E",string}},
	"This parameter displays the used unit. Default value is E (euro)"}
      ]});

print_option_price(abs, _, Unit) ->
    [{pcdata,"X"++Unit}];
 
print_option_price(Session, Option, Unit) ->
    Opt = list_to_atom(Option),
    P = svc_util_of:subscription_price(Session, Opt),
    option_price(Opt, P, Unit).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type option_price(Opt::atom(), Price::integer(),Unit::string())->
%%                    [{pcdata,string()}].
%%%% Internal function used by plugin print_option_price.

option_price(Opt, Price, Unit) ->
    Peuros = Price/1000,
    IoLibF = case (trunc(Peuros)*10)==trunc(Peuros*10) of
		 true  -> io_lib:format("~w"++Unit, [trunc(Peuros)]);
		 false -> io_lib:format("~.1f"++Unit, [Peuros])
	     end,
    [{pcdata,lists:flatten(IoLibF)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_next_weekend_date(session(),Day::string)->
%%                               [{pcdata,string()}].
%%%% Date for next day defined by Day

print_next_weekend_date(plugin_info, Day) ->
    (#plugin_info
     {help =
      "This plugin function includes the date for the next friday or sunday.",
      type = function,
      license = [],
      args =
      [
       {day, {oma_type, {enum, [friday, sunday]}},
	"This parameter specifies the start (friday) or end (sunday) date"
	" for the next week-end. If today is a saturday or"
	" a sunday, next week-end starts next friday."}
      ]});

print_next_weekend_date(Session, Day)->
    ToDay=calendar:day_of_the_week(date()),
    Now=pbutil:unixtime(),
    next_weekend_date(ToDay, Day, Now).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type next_weekend_date(ToDay::integer(),Day::string(),Now::integer())->
%%                      [{pcdata,string()}].
%%%% Internal function used by plugin print_next_weekend_date.

next_weekend_date(ToDay, Day, Now)->
    N_Day=svc_util_of:day_of_the_week(Day),
    Unix=
	case ToDay =< 5 of
	    true ->
		case ToDay=<N_Day of
		    true ->
			Now+(N_Day-ToDay)*24*60*60;
		    _ ->
			Now+(7-(ToDay-N_Day))*24*60*60
		end;
	    _ ->
		Now+(7-(ToDay-N_Day))*24*60*60
	end,
    Date_Time = 
        calendar:now_to_local_time({Unix div 1000000, 
                                    Unix rem 1000000,0}),
    S_Date=svc_util_of:sprintf_datetime_by_format(Date_Time,"dm"),  
    [{pcdata,lists:flatten(S_Date)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_date_end_opt(session(),Opt::string())->
%%                          erlinclude_result().
%%%% Print option validity end date during subscription.

print_date_end_opt(plugin_info, Option) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit validity end date of the"
      " specified option in the format dd/mm,"
      " before subscription is validated.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_europe,
				   opt_maghreb,
				   opt_pass_dom,
				   opt_msn_mensu_mobi,
				   winning_50sms,
		         	   rech_7E_cb_mobi,
				   opt_rech_sl_20E
				  ]}},
        "This parameter specifies the option."}
      ]});

print_date_end_opt(abs,_)->
    [{pcdata,"JJ/MM"}];
print_date_end_opt(Session,Opt)->
    Subscr = svc_util_of:get_souscription(Session),
    Date = svc_options:dlv_opt(list_to_atom(Opt),Subscr),
    [{pcdata, Date}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_end_credit(session(),Option::string(),Format::string()) ->
%%                        [{pcdata,string()}].
%%%% Display credit validity end date for option.

print_end_credit(plugin_info, Option, Format) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit validity end date of the"
      " specified option.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_sms_mensu,
				   opt_mms_mensu,
				   media_decouvrt,
				   media_internet,
				   media_internet_plus,
				   opt_seminf,
				   opt_we_sms,
				   opt_europe,
				   opt_maghreb,
				   opt_pass_dom,
				   opt_sms_3,
				   opt_sms_7_5,
				   opt_sms_12,          
				   opt_sms_18,                    
				   opt_sms_25,
				   opt_sms_ten,
				   opt_2numpref,
				   opt_five_min,
				   opt_tt_shuss_sms, 
				   opt_pass_vacances_mtc,
				   opt_pass_vacances_v2_mtc,
				   opt_pass_vacances_z2_mtc,
				   opt_OW_10E,
				   opt_OW_30E,
				   opt_sms_quoti,
				   sms_opt_OW,
				   opt_etudiante,
				   opt_credit_voix_of,
				   opt_credit_sms_of,
				   opt_cadeau_orange_MMS,
				   opt_credit_OW_of,
				   opt_bons_plans,
				   opt_1h_ts_reseaux,
				   opt_WE_OW,
				   opt_vacances,
				   opt1_tele2_cb_25sms,
				   opt1_tele2_cb_50sms,
				   opt1_tele2_cb_100sms,
				   opt1_tele2_cb_illsms,
				   winning_50sms,
				   roaming_in,
				   opt_ssms_m6,
				   cpte_roaming,
                                   cpte_sms_ill,
                                   cpte_princ,
				   forf_carrefour_z1,
				   forf_carrefour_z2,
				   forf_carrefour_z3,
				   cpte_opt_carrefour,
				   forf_carrefour_cb,
				   forf_nrj_cb,
				   opt_nrj_sms,
				   opt_nrj_data,
				   cpte_nrj_europe,
				   cpte_nrj_maghreb,
				   cpte_nrj_afrique,
				   forf_nrj_sms_bonus,
				   forf_nrj_wap,
				   opt_tv,
				   opt_mail,
				   opt_tv_max,
				   opt_musique,
				   opt_musique_mix,
				   opt_internet_max,
				   opt_internet,
				   opt_foot_ligue1,
                                   opt_orange_maps,
                                   opt_mes_donnees,
                                   opt_mes_vocale_visuelle,
				   ow_spo,
				   ow_tv,
				   ow_tv2,    
				   ow_surf,
				   ow_musique,
				   opt_numpref_tele2
				  ]}},
        "This parameter specifies the option or compte."},
       {format, {oma_type, {defval,"",string}},
        "This parameter specifies the format of the validity end date:"
        " dm or dmy."}
      ]});

print_end_credit(abs, Option, Format) ->
    [{pcdata,"DD/MM/YY"}];

print_end_credit(Session, "cpte_roaming", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_roaming",Format);
print_end_credit(Session, "cpte_sms_ill", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_sms_ill",Format);
print_end_credit(Session, "cpte_opt_carrefour", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_opt_carrefour",Format);
print_end_credit(Session, "forf_carrefour_cb", Format) ->
    svc_compte:print_fin_credit_default(Session,"forf_carrefour_cb",Format);
print_end_credit(Session, "forf_carrefour_z1", Format) ->
    svc_compte:print_fin_credit_default(Session,"forf_carrefour_z1",Format);
print_end_credit(Session, "forf_carrefour_z2", Format) ->
    svc_compte:print_fin_credit_default(Session,"forf_carrefour_z2",Format);
print_end_credit(#session{prof=Profile}=Session, "forf_nrj_cb", Format) ->
            Now = pbutil:unixtime(),
            {Dmy_now,_} = svc_util_of:now_to_local_time(Now),
    %% Check whether today is activation day or not
    case (svc_util_of:check_activation_day(Session,Dmy_now)) of
	{ok, New_date} ->
                    Date = svc_util_of:sprintf_datetime_by_format(New_date,Format),
                    [{pcdata, lists:flatten(Date)}];
                _ ->
	    svc_compte:print_fin_credit_default(Session,"forf_nrj_cb",Format)
    end;

print_end_credit(Session, "opt_numpref_tele2", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_num_prefere",Format);
print_end_credit(Session, "forf_carrefour_z3", Format) ->
    svc_compte:print_fin_credit_default(Session,"forf_carrefour_z3",Format);
print_end_credit(Session, "opt_ssms_m6", Format) ->
    State=svc_util_of:get_user_state(Session),
    case {svc_compte:cpte(State, cpte_m6_soiree_sms_dispo),
	  svc_compte:cpte(State, cpte_m6_soiree_sms_recharge)} of
	{no_cpte_found,no_cpte_found} -> [{pcdata,"inconnu"}];
	{Cpte_dispo,no_cpte_found} ->
	    svc_compte:print_fin_credit_default(Session,"cpte_m6_soiree_sms_dispo",Format);
	{_,Cpte_recharge} ->
	    svc_util_of:print_last_day_of_the_month(Session,"dm")
    end;

print_end_credit(Session, "opt_sms_ten", Format) ->
    Subscr = svc_util_of:get_souscription(Session),
    svc_compte:print_fin_credit_default(Session,
                                        "cpte_ten_sms",
                                        Format);
print_end_credit(Session, "forf_nrj_sms_bonus", Format) ->
    Now = pbutil:unixtime(),    
    {Dmy_now,_} = svc_util_of:now_to_local_time(Now),
    %% Check whether today is activation day or not
    case (svc_util_of:check_activation_day(Session,Dmy_now)) of
        {ok,New_date} ->	    
            Date = svc_util_of:sprintf_datetime_by_format(New_date,Format),
	    [{pcdata, lists:flatten(Date)}];
	_ -> 
	    svc_compte:print_fin_credit_default(Session,"cpte_forf_nrj_sms_bonus",Format)    
    end;

print_end_credit(Session, "opt_nrj_sms", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_forf_nrj_sms",Format);

print_end_credit(Session, "opt_nrj_data", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_forf_nrj_data",Format);

print_end_credit(Session, "cpte_nrj_europe", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_nrj_europe",Format);

print_end_credit(Session, "cpte_nrj_maghreb", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_nrj_maghreb",Format);

print_end_credit(Session, "cpte_nrj_afrique", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_nrj_afrique",Format);

print_end_credit(Session, "forf_nrj_wap", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_forf_nrj_wap",Format);

print_end_credit(Session, Option, Format) 
when Option == "opt_mes_donnees";
     Option == "opt_mes_vocale_visuelle" ->
    %% 20090526: temporarily a change of message is done if date is not avail
    case svc_subscr_asmetier:get_dateDesactivation(Session) of
        {ok,ListServOpt}->
            SOCode = code_opt_resiliation(Session, list_to_atom(Option)),
            case lists:keysearch(SOCode, 1, ListServOpt) of 
                {value,{SOCode, Date}} ->
                    case Date of
			undefined -> 
			    %%[{pcdata, "DATE"}];
			    [{pcdata, "chaque mois a date anniversaire"}];
			_ ->
			    
			    [{pcdata, "le "++
			      svc_util_of:sprintf_datetime_by_format(Date,
								     dmy)
			      ++" en fin de journee"}]
		    end;
		_->
		    slog:event(failure,?MODULE,print_end_credit,get_dateDesactivation),
                    %%[{pcdata, "DATE"}]
		    [{pcdata, "chaque mois a date anniversaire"}]
            end;
        _->
            slog:event(failure,?MODULE,print_end_credit,get_dateDesactivation),
            %%[{pcdata, "DATE"}]
	    [{pcdata, "chaque mois a date anniversaire"}]
    end;

print_end_credit(Session, "opt_mobi_bonus", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_mobi_bonus", Format);
print_end_credit(Session, "cpte_mobi_bonus_sms", Format) ->
    svc_compte:print_fin_credit_default(Session,"cpte_mobi_bonus_sms", Format);

print_end_credit(Session, "cpte_princ", Format) ->
    svc_compte:print_fin_credit_type(Session, "cpte_princ", "jma", Format);

print_end_credit(Session, Option, Format) ->
    Subscr = svc_util_of:get_souscription(Session),
    svc_compte:print_fin_credit_default(Session,
                                        svc_options:opt_to_godet(Option,
                                                                 Subscr),
                                        Format).

print_end_credit_bonus_rech_sl(plugin_info, Ticket, Format) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit validity end date of the"
      " bonus of recharge serie illimite.",
      type = function,
      license = [],
      args =
      [
       {ticket, {oma_type, {enum, [183,184,185]}},
	"This parameter specifies the recharge ticket."},
       {format, {oma_type, {defval,"",string}},
        "This parameter specifies the format of the validity end date."}
      ]});

print_end_credit_bonus_rech_sl(abs, Ticket, Format) ->
    [{pcdata,"DD/MM/YY"}];

print_end_credit_bonus_rech_sl(Session, Ticket, Format) ->
    Date_UT = case list_to_integer(Ticket) of
               183 ->
                   slog:event(trace, ?MODULE, ticket_rech_sl_10E),
		   pbutil:unixtime()+7*86400;
	       184 ->
                   slog:event(trace, ?MODULE, ticket_rech_sl_20E),
                   pbutil:unixtime()+31*86400;
               185 ->
                   slog:event(trace, ?MODULE, ticket_rech_sl_30E),
                   pbutil:unixtime()+45*86400
           end,
    DateTime = calendar:now_to_local_time({Date_UT div 1000000,
                                           Date_UT rem 1000000,
					   0}),
    Date = lists:flatten(svc_util_of:sprintf_datetime_by_format(DateTime,Format)),
    [JJ,MM,AA] = string:tokens(Date,"/"),
    Data = atom_to_list(svc_util_of:mois_int2atom(list_to_integer(MM))),
    [{pcdata, JJ++" "++Data++" "++AA}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_end_credit(session(),Format::string()) ->
%%                        [{pcdata,string()}].
%%%% Display credit validity end date for the main account.

print_end_credit(plugin_info, Format) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit validity end date of the"
      " main account.",
      type = function,
      license = [],
      args =
      [
       {format, {oma_type, {defval,"",string}},
        "This parameter specifies the format of the validity end date:"
        " dm or dmy."}
      ]});

print_end_credit(abs, Format) ->
    [{pcdata,"DD/MM/YY"}];

print_end_credit(Session, Format) ->
    svc_compte:print_fin_credit_default(Session, "cpte_princ", Format).

print_renew_date(plugin_info, Option, Format) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit validity renew date of the"
      " main account.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [forf_nrj_cb,cpte_forf_nrj_sms_bonus]}
		},
        "This parameter specifies the option or compte."},
       {format, {oma_type, {defval,"",string}},
        "This parameter specifies the format of the validity end date:"
        " dm or dmy."}
      ]});
print_renew_date(abs, Option, Format) ->    
    [{pcdata,"DD/MM/YY"}];
print_renew_date(Session, Option, Format) ->
    [{pcdata, End_credit}] =
    svc_compte:print_fin_credit_default(Session,Option,"dmy"),
    [Day,Month,Year] = string:tokens(End_credit,"/"),
    End_credit_UT =   pbutil:universal_time_to_unixtime({{list_to_integer(lists:append("20",Year)),
                                        list_to_integer(Month),
                                        list_to_integer(Day)},{00,00,00}}),
    %%get the following date
    Next_end_credit_UT = End_credit_UT + 86400,
    {DMY,HMS} = svc_util_of:now_to_local_time(Next_end_credit_UT),
    %%check whether today is activation day or not
    Date = case (svc_util_of:check_activation_day(Session,DMY)) of
	       {ok,New_date} ->
		   svc_util_of:sprintf_datetime_by_format(New_date,Format);
	       _ ->
		   svc_util_of:sprintf_datetime_by_format({DMY,HMS},Format)
	   end,
    [{pcdata, lists:flatten(Date)}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_credit(session())-> 
%%                   [{pcdata,string()}].
%%%% Print credit of main account (cpte_princ) in unit defined
%%%% by #compte.unt_num.

print_credit(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit on the main account.",
      type = function,
      license = [],
      args = []});

print_credit(abs)->
    [{pcdata,"YYY.YY"}];

print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session)->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State, cpte_princ) of
 	#compte{}=Compte->
 	    [{pcdata,svc_compte:print_cpte(Compte)}];
 	Error ->
 	    slog:event(internal,?MODULE,error_in_print_main_credit,
		       {Error, MSISDN}),
 	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_credit(session(),Subscription::string(), Opt::string(),
%%                   Unt_rest::string())-> [{pcdata,string()}].
%%%% Print credit of the option Opt in unity UNT_REST(sms,mms,euros,ko or min).

print_credit(plugin_info,Subscription, Opt, UNT_REST) ->
    (#plugin_info
     {help =
      "This plugin function includes the credit of the option.",
      type = function,
      license = [],
      args = [{subscription, {oma_type, {enum, [mobi,cmo,tele2_compte_bloque,
                                                tele2_comptebloque,
                                                ten_comptebloque,
                                                carrefour_comptebloq,
                                                nrj_comptebloque,
						nrj_prepaid
					       ]}},
	       "This parameter specifies the subscription."},
	      {cpte, {oma_type, {enum, [no_option,
					media_decouvrt,
					media_internet,
					media_internet_plus,
					opt_europe,
					opt_we_sms,
					opt_ssms,
					opt_maghreb,
					opt_pass_dom,
					opt_sms_3,
					opt_sms_7_5,
					opt_sms_12,          
					opt_sms_18,                    
					opt_sms_25,
					opt_sms_ten,
					opt_2numpref,
					opt_five_min,
					opt_tt_shuss_voix,
					opt_tt_shuss_voix_2,
					opt_tt_shuss_sms,
					opt_pass_vacances_moc,
					opt_pass_vacances_mtc,
					opt_pass_vacances_v2_moc,
					opt_pass_vacances_v2_mtc,
					opt_pass_vacances_v2_10_sms,
					opt_pass_vacances_z2_moc,
					opt_pass_vacances_z2_mtc,
					opt_pass_vacances_z2_sms,
					opt_OW_10E,
					opt_OW_30E,
					opt_sms_quoti,
					opt_sms_mensu,
					opt_mms_mensu,
					sms_opt_OW,
					opt_etudiante,
					opt_we_voix,
					opt_credit_voix_of,
					opt_credit_sms_of,
					opt_cadeau_orange_MMS,
					opt_credit_OW_of,
					opt_bons_plans,
					opt_1h_ts_reseaux,
					opt_vacances,
					opt1_tele2_cb_25sms,
					opt1_tele2_cb_50sms,
					opt1_tele2_cb_100sms,
					opt1_tele2_cb_illsms,
					forf_carrefour_cb,
					cpte_opt_carrefour,
					forf_carrefour_z1,
					forf_carrefour_z2,
					forf_carrefour_z3,
					winning_50sms,
					roaming_in,
					roaming_out,
					opt_kdo_sinf,
					cpte_roaming,
					cpte_promo_surf,
					forf_nrj_cb,
					opt_nrj_sms,
					opt_nrj_data,
					cpte_nrj_europe,
					cpte_nrj_maghreb,
					cpte_nrj_afrique,
					forf_nrj_sms_bonus,
					forf_nrj_wap,
					opt_ssms_m6,
					cpte_asms,
					cpte_num_prefere
				       ]}},
	       "This parameter specifies the option or compte."},
	      {unite_rest, {oma_type, {enum, [sms,
					      mms,
					      euro,
					      min,
					      ko,
                                              euro_p,
					      day]}},
	       "This parameter specifies the unite."}
	     ]});

print_credit(abs,Subscription, Opt,"sms")->
    [{pcdata,"XXX"}];
print_credit(abs,Subscription, Opt,"mms")->
    [{pcdata,"XXX"}];
print_credit(abs,Subscription, Opt,"euro")->
    [{pcdata,"YYY.YY"}];
print_credit(abs,Subscription, Opt,"min")->
    [{pcdata,"XXXminYYsec"}];
print_credit(abs,Subscription, Opt,"ko")->
    [{pcdata,"XXX Ko"}];
print_credit(abs,Subscription, Opt,"jour")->
    [{pcdata,"XXX soiree"}];
print_credit(#session{}=Session,"tele2_comptebloque", "cpte_promo_surf",_)->
    svc_compte:print_solde(Session,"cpte_promo_surf","ko");
print_credit(#session{}=Session,"tele2_comptebloque", "cpte_roaming",_)->
    svc_compte:print_solde(Session,"cpte_roaming");
print_credit(#session{}=Session,"carrefour_comptebloq", "forf_carrefour_cb",_)->
    svc_compte:print_solde(Session,"forf_carrefour_cb");
print_credit(#session{}=Session,"carrefour_comptebloq", "forf_carrefour_z1",_)->
    svc_compte:print_solde(Session,"forf_carrefour_z1");
print_credit(#session{}=Session,"carrefour_comptebloq", "forf_carrefour_z2",_)->
    svc_compte:print_solde(Session,"forf_carrefour_z2");
print_credit(#session{}=Session,"carrefour_comptebloq", "forf_carrefour_z3",_)->
    svc_compte:print_solde(Session,"forf_carrefour_z3");
print_credit(#session{}=Session,"carrefour_comptebloq", "cpte_opt_carrefour",_)->
    svc_compte:print_solde(Session,"cpte_opt_carrefour");
print_credit(#session{}=Session,"cmo", "cpte_asms","sms")->
    svc_compte:print_solde(Session,"cpte_asms","sms");
print_credit(#session{}=Session,Subscription, "opt_ssms_m6","day")->
    State=svc_util_of:get_user_state(Session),
    Solde = svc_compte:solde_cpte(State, cpte_m6_soiree_sms),
    RatioNbApp = ?RATIO_M6_SOIREE,
    SOLDE_EUROS = currency:round_value(Solde),
    NbApp = trunc(SOLDE_EUROS/RatioNbApp),
    case NbApp of
	0 -> [{pcdata, "0"}];
	1 -> [{pcdata, "1"}]; 
	2 -> [{pcdata, "2"}]; 
	_ -> [{pcdata, "3"}]
    end;

print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,"nrj_prepaid","no_option","min")->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State, cpte_princ) of
 	#compte{}=Compte->
 	    svc_compte:print_solde_min_sec_with_format(Session,"cpte_princ","mins");
 	Error ->
 	    slog:event(internal,?MODULE,error_in_print_main_credit,
		       {Error, MSISDN}),
 	    [{pcdata,"inconnu"}]
    end; 

print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Subscription,"no_option","min")->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State, cpte_princ) of
 	#compte{}=Compte->
 	    svc_compte:print_solde_hour_min_sec(Session,"cpte_princ");
 	Error ->
 	    slog:event(internal,?MODULE,error_in_print_main_credit,
		       {Error, MSISDN}),
 	    [{pcdata,"inconnu"}]
    end; 
   
print_credit(Session, Subscription, "no_option","euro_p") ->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State, cpte_princ) of
 	#compte{cpp_solde=SOLDE}=Compte->
            SOLDE_EUROS=trunc(currency:round_value(SOLDE)),
            [{pcdata,integer_to_list(SOLDE_EUROS)}];
 	Error ->
 	    slog:event(internal,?MODULE,error_in_print_main_credit, Error),
 	    [{pcdata,"inconnu"}]
    end; 

print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Subscription, Opt,UNT_REST)
when Subscription=="nrj_comptebloque";Subscription=="nrj_prepaid"->
    State=svc_util_of:get_user_state(Session),
    Cpte = case  Opt of
	      "opt_nrj_sms"->
		  "cpte_forf_nrj_sms";
	      "opt_nrj_data" ->
		  "cpte_forf_nrj_data";
	      "forf_nrj_sms_bonus" -> 
		   "cpte_forf_nrj_sms_bonus";
	      "forf_nrj_wap" ->
		   "cpte_forf_nrj_wap";
	      X when X=="forf_nrj_cb";
		     X=="cpte_nrj_europe";
		     X=="cpte_nrj_maghreb";
		     X=="cpte_nrj_afrique"->
		   Opt
    end,    
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
	#compte{etat=E}=Compte when E==?CETAT_EP;E==?CETAT_EP ->
 	    [{pcdata, "0min0sec"}];
	#compte{}=Compte-> 
	    %%Compte must be in euros here
	    case UNT_REST of
		"min"->
		    svc_compte:print_solde_hour_min_sec(Session,Cpte);
		"euro"->
		    svc_compte:print_solde(Session,Cpte);
		"sms" ->
		    svc_compte:print_solde(Session,Cpte,"sms");
		"mms" ->
		    svc_compte:print_solde(Session,Cpte,"mms")		
	    end;	
	undefined ->
	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
	    [{pcdata,"inconnu"}];
        no_cpte_found ->
            slog:event(internal,?MODULE,print_credit_no_cpte_found,
                       {Cpte,MSISDN}),
            [{pcdata,"inconnu"}];
        Answer ->
            slog:event(internal,?MODULE,print_credit_unknown_cpte,
                       {Cpte,MSISDN,Answer}),
 	    [{pcdata,"inconnu"}]
    end;


print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Subscription, Opt,"min")
when Subscription=="cmo";Subscription=="tele2_comptebloque"->
    State=svc_util_of:get_user_state(Session),
    Cpte =case  Subscription of
	      "cmo"->
		  svc_options:opt_to_godet(Opt,cmo);
	      "tele2_comptebloque" ->
		  case Opt of
		      "cpte_num_prefere" -> Opt;
		      _ ->
			  svc_options:opt_to_godet(Opt,tele2_comptebloque)
		  end
	  end,
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
	#compte{etat=E}=Compte when E==?CETAT_EP;E==?CETAT_PE ->
 	    [{pcdata, "0min0sec"}];
	#compte{}=Compte-> 
	    %%Compte must be in euros here
	    svc_compte:print_solde_min_sec(Session,Cpte);
	undefined ->
	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
	    [{pcdata,"inconnu"}];
	_ ->
	    slog:event(internal,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end;

print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,"mobi","opt_mobi_bonus",UNT_REST)->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,cpte_mobi_bonus) of
	#compte{}=Compte->
	    case UNT_REST of
		"min"->
		    svc_compte:print_solde_hour_min(Session,"cpte_mobi_bonus");
		_->
		    [{pcdata,svc_compte:print_cpte(svc_compte:dcl(State),Compte,UNT_REST,MSISDN)}]
	    end;
	undefined ->
	    slog:event(internal,?MODULE,undefined_print_solde,{cpte_mobi_bonus,UNT_REST}),
	    [{pcdata,"inconnu"}];
	_ ->
	    slog:event(internal,?MODULE,unknown_cpte,{cpte_mobi_bonus,UNT_REST,MSISDN}),
	    [{pcdata,"inconnu"}]
    end;

print_credit(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Subscription,
	    Opt,UNT_REST)->
    State=svc_util_of:get_user_state(Session),
    Cpte = case  Subscription of
	       "mobi" ->svc_options:opt_to_godet(Opt,mobi);
	       "cmo"  ->svc_options:opt_to_godet(Opt,cmo);
	       "tele2_comptebloque"-> svc_options:opt_to_godet(Opt,tele2_comptebloque);
	       "ten_comptebloque"  -> "cpte_ten_sms"
	   end,
    case svc_compte:cpte(State,list_to_atom(Cpte)) of

	#compte{}=Compte->
	    [{pcdata,svc_compte:print_cpte(svc_compte:dcl(State),Compte,UNT_REST,MSISDN)}];

	undefined ->
	    slog:event(internal,?MODULE,undefined_print_solde,
			{Cpte,UNT_REST}),
	    [{pcdata,"inconnu"}];

	_ ->
	    slog:event(internal,?MODULE,unknown_cpte,{Cpte,UNT_REST,MSISDN}),
	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_incomp_opts(session(),Option::string())-> 
%%                        [{pcdata,string()}].
%%%% Print list of incompatible options.

print_incomp_opts(plugin_info, _) ->
    (#plugin_info
     {help =
      "This plugin function includes the list of incompatible options.",
      type = function,
      license = [],
      args = [
	      {option, {oma_type, {enum, [opt_weinf,
					  opt_sinf,
					  opt_jinf,
					  opt_j_app_ill,
					  opt_s_app_ill,
					  opt_j_mm_ill,
					  opt_s_mm_ill,
					  opt_ssms_ill,
					  opt_jsms_ill,
					  opt_j_tv_max_ill,
					  opt_s_tv_max_ill,
					  opt_j_app_ill_kdo_bp,
					  opt_s_app_ill_kdo_bp,
					  opt_j_mm_ill_kdo_bp,
					  opt_s_mm_ill_kdo_bp,
					  opt_ssms_ill_kdo_bp,
					  opt_jsms_ill_kdo_bp,
					  opt_j_omwl_kdo_bp,
					  opt_j_tv_max_ill_kdo_bp,
					  opt_s_tv_max_ill_kdo_bp,
					  opt_maghreb,
					  opt_europe,
					  opt_pass_dom,
					  opt_afterschool,
					  opt_ssms,
					  opt_sms_quoti,
					  opt_sms_illimite,
					  opt_tt_shuss,
									  opt_pack_duo_journee,
					  opt_vacances,
					  opt_pass_vacances,
					  opt_pass_vacances_v2,
					  opt_pass_vacances_z2,
									  opt_pass_voyage_6E,
									  opt_pass_voyage_9E,
					  opt_30_sms_mms,
					  opt_80_sms_mms,
					  opt_130_sms_mms,
					  opt_sms_mms_illimites,
					  opt_30_sms_mms_gpro,
					  opt_80_sms_mms_gpro,
					  opt_130_sms_mms_gpro,
					  opt_sms_mms_ill_gpro,
					  opt_tv_gpro,
					  ow_tv,
					  ow_tv2,
					  ow_surf,
					  ow_spo,
					  ow_musique,
					  media_decouvrt,
					  media_internet,
					  ow_tv_mus_surf,
					  opt_orange_messenger,
					  opt_internet_gpro,
					  opt_plus_internet_gpro,
					  opt_orange_foot_gpro,
					  opt_orange_sport_gpro,
					  opt_tv,
					  opt_tv_max,
					  opt_internet,
					  opt_internet_max,
					  opt_mes_vocale_visuelle,
					  opt_mail,
					  opt_tv_max_gpro,
					  opt_internet_gpro,
					  opt_internet_max_gpro,
					  opt_mes_vocale_visuelle_gpro,
					  opt_unik_tout_operateur,
					  opt_unik_pour_zap_tous_operator,
					  opt_mail_gpro,
					  opt_giga_mail_gpro,
					  opt_mail_MMS_gpro,
                                          opt_orange_maps,
					  opt_orange_maps_gpro,
					  opt_musique,
					  opt_musique_mix,
					  opt_musique_collection,
					  opt_foot_ligue1,
					  opt_orange_sport,
                                          opt_mes_donnees,
					  opt_mes_donnees_gpro,
					  opt_iphone_3g_gpro,
					  opt_mail_blackberry_gpro,
					  opt_lyon,opt_lyon_gpro,
					  opt_marseille,opt_marseille_gpro,
					  opt_paris,opt_paris_gpro,
					  opt_bordeaux,opt_bordeaux_gpro,
					  opt_lens,opt_lens_gpro,
					  opt_saint_etienne, opt_saint_etienne_gpro,
					  opt_musique_mix_gpro,
					  opt_musique_collection_gpro
					 ]}},

	       "This parameter specifies the option."}
	     ]});

print_incomp_opts(abs, _)->
    [{pcdata,""}]++
	svc_subscr_asmetier:print_opt_incomp(abs);
print_incomp_opts(Session, Option)
  when Option == "ow_tv";Option == "ow_tv2";
       Option == "ow_spo";Option == "ow_surf";
       Option == "ow_musique";Option == "ow_tv_mus_surf";
       Option == "media_decouvrt";Option == "media_internet";
       Option == "opt_30_sms_mms";Option == "opt_80_sms_mms"; Option == "opt_130_sms_mms";
       Option == "opt_sms_mms_illimites";
       Option == "opt_tv"; Option == "opt_tv_max"; 
       Option == "opt_internet"; Option == "opt_internet_max";Option=="opt_mail";
       Option == "opt_mes_vocale_visuelle";
       Option == "opt_tv_max_gpro"; Option == "opt_internet_gpro"; Option == "opt_internet_max_gpro";
       Option =="opt_30_sms_mms_gpro";Option =="opt_80_sms_mms_gpro";Option =="opt_130_sms_mms_gpro";
       Option =="opt_sms_mms_ill_gpro";
       Option =="opt_tv_gpro";
       Option =="opt_internet_gpro";Option =="opt_plus_internet_gpro";
       Option =="opt_giga_mail_gpro";
       Option =="opt_mail_MMS_gpro";
       Option =="opt_orange_maps_gpro";
       Option =="opt_unik_tout_operateur"; Option == "opt_unik_pour_zap_tous_operator";
       Option == "opt_musique_mix_gpro";
       Option == "opt_musique_collection_gpro";
       Option == "opt_musique"; Option == "opt_musique_mix"; Option == "opt_musique_collection";
       Option == "opt_foot_ligue1"; Option == "opt_orange_sport";
       Option == "opt_mes_donnees_gpro";
       Option == "opt_iphone_3g_gpro";
       Option == "opt_mail_blackberry_gpro";
       Option == "opt_lyon"; Option == "opt_marseille";
       Option == "opt_paris"; Option == "opt_bordeaux";
       Option == "opt_lens"; Option == "opt_saint_etienne";
       Option =="opt_orange_sport_gpro";
       Option =="opt_lyon_gpro"; Option=="opt_marseille_gpro";
       Option =="opt_paris_gpro"; Option=="opt_bordeaux_gpro";
       Option =="opt_lens_gpro"; Option=="opt_saint_etienne_gpro" ->
    svc_subscr_asmetier:print_opt_incomp(Session);

print_incomp_opts(#session{prof=#profile{subscription=Sub}}=Session, Option)->
	    Opt = list_to_atom(Option),
	    case variable:get_value(Session,{incomp,Opt}) of
		List when list(List) ->
		    [{pcdata, option_to_name(List,list_to_atom(Sub))}];
		_ ->
		    [{pcdata,""}]
	    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type option_to_name(List::string(), Sub)->
%%                      term(). 
%%%% Internal function used by plugin print_incomp_opts.

option_to_name(List,Sub) when atom(Sub)->
    option_to_name(List,Sub, []).

%% +type option_to_name(List::string(), Sub, Acc::term())->
%%                      term(). 
%%%% Internal function used by plugin print_incomp_opts.

option_to_name([Incomp_opt],Sub, Acc) ->
    case svc_option_manager:get_commercial_name(Incomp_opt,Sub) of
	[] ->     
	    slog:event(internal, ?MODULE, option_to_name, Incomp_opt),
	    Acc;
	Name -> 
	    Acc++Name
    end;

option_to_name([Incomp_opt|Tail],Sub, Acc) ->
    case svc_option_manager:get_commercial_name(Incomp_opt,Sub) of
	[] ->
	    slog:event(internal, ?MODULE, option_to_name, Incomp_opt),
	    option_to_name(Tail, Acc);
	Name ->
	    option_to_name(Tail, Acc++Name++";")
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_start_we(session())-> [{pcdata,string()}].
%%%% Print the hour and the day of start of the next week end .

print_start_we(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function prints the hour and date of start of the week end"
      "belonging to the current week",
      type = function,
      license = [],
      args = []
});

print_start_we(abs)->
    [{pcdata, "JJ/MM a HHhMM"}];

print_start_we(Session)->
      
    State=svc_util_of:get_user_state(Session),
    Now = pbutil:unixtime(),
    {{Y,Mo,D},{H,Mi,S}} = calendar:now_to_local_time({Now div 1000000,
						      Now rem 1000000,0}),
    WeekDay = calendar:day_of_the_week(Y,Mo,D),
    case WeekDay of
	X when X>=6 -> % saturday or sunday
	    DateBegin = Now-((WeekDay-6)*24*3600),
	    {{Year,Month,Day},Time} = 
		calendar:now_to_local_time({DateBegin div 1000000,
					    DateBegin rem 1000000,0}),
	    DatePromo = pbutil:sprintf("%02d/%02d", [Day,Month]),
	    TimePromo = pbutil:sprintf("%02dh%02d", [0 ,0]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}];
	_ ->
	    NbDays = 6-WeekDay,
	    DateBegin = Now+(NbDays*24*3600),
	    {{Year,Month,Day},Time} =
		calendar:now_to_local_time({DateBegin div 1000000,
					    DateBegin rem 1000000,0}),
	    DatePromo = pbutil:sprintf("%02d/%02d", [Day,Month]),
	    TimePromo = pbutil:sprintf("%02dh%02d", [0 ,0]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}]
    end.
print_text(plugin_info, Text)->
    (#plugin_info
     {help =
      "This plugin function prints the hour and date of start of the week end"
      "belonging to the current week",
      type = function,
      license = [],
      args = [
	      {text, {oma_type, {defval,"",string}},
                "This parameter specifies the text ."}
	     ]
     });
print_text(abs, Text) ->
        [{pcdata, ""}];
print_text(Session, Text) ->
     [{pcdata, Text}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_end_we(session())-> [{pcdata,string()}].
%%%% Print the hour and the day of end of the next week end .

print_end_we(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function prints the hour and date of end of the week end"
      "belonging to the current week",
      type = function,
      license = [],
      args = []
     });

print_end_we(abs)->
     [{pcdata, "JJ/MM a HHhMM"}];

print_end_we(Session)->
    State=svc_util_of:get_user_state(Session),
    Now = pbutil:unixtime(),
    {{Y,Mo,D},{H,Mi,S}} = calendar:now_to_local_time({Now div 1000000,
						      Now rem 1000000,0}),
    WeekDay = calendar:day_of_the_week(Y,Mo,D),
    DateEnd = Now+((7-WeekDay)*24*3600),
    {{Year,Month,Day},Time} =
	calendar:now_to_local_time({DateEnd div 1000000, 
				    DateEnd rem 1000000,0}),
   
	    %%the end of the promo is the next sunday at 23h59
	    DatePromo = pbutil:sprintf("%02d/%02d", [Day,Month]),
	    TimePromo = pbutil:sprintf("%02dh%02d", [23 ,59]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_account_debited(session(),Option::string()) ->
%%                             [{pcdata,string()}].
%%%% Displays the account to debit.

print_account_debited(plugin_info, Option) ->
    (#plugin_info
     {help =
      "This plugin function includes the name of the account to be debited.",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_msn_journee_mobi,
				   opt_msn_mensu_mobi
				  ]}},
        "This parameter specifies the option."}
      ]});

print_account_debited(abs, Option) ->
    [{pcdata," principal."}];

print_account_debited(Session, Option) ->
    Opt = list_to_atom(Option),
    PrixSubscr = svc_util_of:subscription_price(Session, Opt),
    debited_account(Session, Opt, PrixSubscr).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type debited_account(session(),Opt::atom(),Price::integer())->
%%                       [{pcdata,string()}].
%%%% Internal function used by plugin print_account_debited.

debited_account(Session, Opt, Price) ->
    State = svc_util_of:get_user_state(Session),
    Subscr = svc_util_of:get_souscription(Session),
    DCL = State#sdp_user_state.declinaison,

    if ((DCL==?RC_LENS_mobile) or (DCL==?ASSE_mobile) 
	or (DCL==?OL_mobile) or (DCL==?OM_mobile)
	or (DCL==?PSG_mobile) or (DCL==?BORDEAUX_mobile) or (DCL==?CLUB_FOOT))->
	    [{pcdata,""}];
       (DCL==?click_mobi) ->
	     [{pcdata,"principal"}];
       true ->
	    case {(svc_compte:etat_cpte(State,cpte_bons_plans)==?CETAT_AC),
		  svc_options:credit_bons_plans_ac(State,
					   {currency:sum(euro,Price/1000),
					    Opt})} of
		{true,true} -> 
		    [{pcdata,"bons plans"}];
		
		{_,_} ->
		    case Subscr of
			mobi -> [{pcdata,"mobicarte"}];

		        cmo  -> [{pcdata,"principal"}]
		    end
	    end
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO HANDLE LISTS OF ACTIVE OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type active_options(session(), Uact::string(), U_no_opt::string())->
%%             erlpage_result(). 
%%%% redirect to 'Uact' if user has subsribed to one options or more 
%%%% redirect to 'U_no_opt' if the user has subscribed to 0 options
%%%% Check if one option has been subscribed or not

active_options(plugin_info, Uact, U_no_opt) ->
     (#plugin_info
      {help =
       "This plugin command redirects to the corresponding page depending on"
       " whether the user has subscribed to one option or not",
       type = command,
       license = [],
       args =
       [
        {uact, {link,[]},
 	"This parameter specifies the next page when 3 or less options exist"},
        {u_no_opt, {link,[]},
 	"This parameter specifies the next page when no option exist."}
       ]});

active_options(abs, Uact, U_no_opt)->
     [{redirect,abs,Uact},{redirect,abs,U_no_opt}];


active_options(#session{prof=#profile{subscription=Sub}}=Session, Uact, U_no_opt) ->
    Var_list_opts = case Sub of 
			"postpaid" ->
			    asmetier_opt_postpaid;
			_ ->
			    asmetier_opt_cmo
		    end,
    ListOptions=pbutil:get_env(pservices_orangef,Var_list_opts),
    {ListActiveOpts,Session3}=
        case svc_subscr_asmetier:get_identification(Session, "oee") of
            {ok, IdDosOrch, CodeOffreType,Session1} ->
                case svc_subscr_asmetier:get_listServiceOptionnel(Session1) of
                    {ok,ListServOpt,Session2}->
                        {list_active_opts(ListServOpt,ListOptions),Session2};
                    _->
                        slog:event(failure,?MODULE,active_options_error,get_listServiceOptionnel),
                        {[],Session1}
                end;
            Other ->
                slog:event(failure,?MODULE,active_options_UnknownError, Other),
                {[],Session}
        end,
    case ListActiveOpts of
	[]->
	    {redirect,Session3, U_no_opt};
	_->
	    {redirect,Session3, Uact}
    end.

option_sms_messages_link(#session{prof=#profile{subscription=Sub}}=Session, Option, Service) ->
    NewSession=variable:update_value(Session,{"bons_plans","option"}, Option),
    {redirect,NewSession,"file:/mcel/acceptance/mobi/bons_plans/vos_messages/"++Service++".xml"}.

option_appels_link(#session{prof=#profile{subscription=Sub}}=Session, Option, Service) ->
    NewSession=variable:update_value(Session,{"bons_plans","option"}, Option),
    {redirect,NewSession,"file:/mcel/acceptance/mobi/bons_plans/vos_appels/"++Service++".xml"}.

option_multimedia_link(#session{prof=#profile{subscription=Sub}}=Session, Option, Service) ->
    NewSession=variable:update_value(Session,{"bons_plans","option"}, Option),
    {redirect,NewSession,"file:/mcel/acceptance/mobi/bons_plans/votre_multimedia/"++Service++".xml"}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type display_multimedia_menu(session()) -> erlpage_result().                      
%%%% This plugin function prints the page of multimedia options 
%%%% Five or less options can be print on the first page
%%%% If the user has subscribed to more than five options
%%%% a link 'Suite' is created
%%%% This link 'Suite' will automatically call the function next_page_options.

display_multimedia_menu(plugin_info, _) ->
    (#plugin_info
     {help =
      "This plugin function prints the page of options of multimedia" 
      "Five or less options can be print on the first page"
      "If the user has subscribed to more than five options"
      "a link 'Suite' is printed",
      type = function,
      license = [],
      args = [
              {index, {oma_type, {defval,"",string}},
                "This parameter specifies the start index in list to display."}
             ]   
     });

display_multimedia_menu(abs, _) ->
    [{pcdata,""}];

display_multimedia_menu(#session{prof=#profile{subscription=Sub}}=Session,Start)
when Sub=="mobi"->
    Index = list_to_integer(Start),
    State = svc_util_of:get_user_state(Session),

    DCL = State#sdp_user_state.declinaison,
    Redirect_mobicarte= pbutil:get_env(pservices_orangef,redirect_mobicarte),
    {value, {_, List}} = lists:keysearch(sachem, 1, Redirect_mobicarte),
    {value, {_, Declinaison}} = lists:keysearch(integer_to_list(DCL), 1, List),
    List_opts=create_list_multimedia_opts(Session,Declinaison),
    Options = lists:nthtail(Index, List_opts),
    All_lines = get_options_page(Session, Index, Options, 0),
    Item = svc_util_of:br_separate(All_lines),
    {page, Session, #page{items= Item}}.

create_list_multimedia_opts(Session,Declinaison)->
    Open_list=case Declinaison of
		  Type_DCL1 when Type_DCL1==mobicarte;
				 Type_DCL1==m6;
				 Type_DCL1==m6sample;
				 Type_DCL1==click->
		      [{opt_internet_max_journee,"BP Journee Internet Max","opt_internet_max_journee","option"},
		       {opt_internet_max_weekend,"BP week end Internet Max","opt_internet_max_weekend","option"},
		       {opt_internet,"Option Internet","opt_internet_v3_pp","option"},
		       {opt_internet_max,"Option Internet max","opt_internet_max_pp","option"},
		       {opt_mail,"Option mail","opt_mail","option"},
		       {opt_tv,"Option TV","opt_tv","option_with_promo"},
		       {opt_musique_mix,"Option Musique mix","opt_musique_mix","option"},
		       {opt_musique_collection,"Option Musique collection","opt_musique_collection","option"},
		       {opt_orange_sport,"Option Sport","opt_orange_sport","option"},
		       {opt_mes_donnees,"Mes donnees +30Go","opt_mes_donnees","option"}
		      ];
		  foot ->
		      [
		       {opt_internet_max_journee,"BP Journee Internet Max","opt_internet_max_journee","option"},
		       {opt_internet_max_weekend,"BP week end Internet Max","opt_internet_max_weekend","option"},
		       {opt_internet,"Option Internet","opt_internet_v3_pp","option"},
                       {opt_internet_max,"Option Internet max","opt_internet_max_pp","option"},
		       {opt_mail,"Option mail","opt_mail","option"},
		       {opt_musique_mix,"Option Musique mix","opt_musique_mix","option"},
		       {opt_musique_collection,"Option Musique collection","opt_musique_collection","option"},
                       {opt_tv,"Option TV","opt_tv","option_with_promo"},
		       {opt_orange_sport,"Option Sport","opt_orange_sport","option"},
                       {opt_mes_donnees,"Mes donnees +30Go","opt_mes_donnees","option"}
                      ];
		  umobile ->
		      [{opt_internet,"Option Internet","opt_internet_v3_pp","option"},
		       {opt_tv,"Option TV","opt_tv","option_with_promo"},
                       {opt_musique_mix,"Option Musique mix","opt_musique_mix","option"},
                       {opt_musique_collection,"Option Musique collection","opt_musique_collection","option"}	       
		      ]
	      end,
    Close_list=case Declinaison of
		   Type_DCL2 when Type_DCL2==mobicarte;
				  Type_DCL2==foot;
				  Type_DCL2==click->
		       [
			{opt_tv_max,"Option TV max","opt_tv_max","option"},
			{opt_foot_ligue1,"Option Orange foot","opt_foot_ligue1","option"},
			{opt_surf_mensu,"Option Surf Mensuelle","opt_surf_mensu","option"},
			{opt_tv_mensu,"Option TV Mensuelle","opt_tv_mensu","option"},
			{opt_visio,"Activer la Visio","opt_visio","visio"}
		       ];
		   _Type_DCL when _Type_DCL==m6;
				  _Type_DCL==m6sample->
		       [
			{opt_tv_max,"Option TV max","opt_tv_max","option"},
			{opt_foot_ligue1,"Option Orange foot","opt_foot_ligue1","option"},
			{opt_tv_mensu,"Option TV Mensuelle","opt_tv_mensu","option"},
			{opt_visio,"Activer la Visio","opt_visio","visio"}
		       ];
		   umobile ->
		       [{opt_visio,"Activer la Visio","opt_visio","visio"}]
	       end,
    Open_links=create_open_list(Session,multimedia,Open_list,[],[]),
    Close_links=create_close_list(Session,multimedia,Close_list,[]),
    List_multimedia_opts=Open_links++Close_links.

create_open_list(Session,_,[],Open1,Open2)->
    Open1++Open2;
create_open_list(Session,multimedia=Menu,[{H,PCD,Var,Service}|T_Open_list],Open1,Open2) ->
    case check_display_multimedia_opt(Session,H,PCD,Var,Service) of
	{_,USession1,[]}->
	    create_open_list(USession1,Menu,T_Open_list,Open1,Open2);
	{false,Usession2,Link}->    
	    Open11=Open1++[Link],
	    create_open_list(Usession2,Menu,T_Open_list,Open11,Open2);
	{true,Usession3,Link}->
	    Open22=Open2++[Link],
	    create_open_list(Usession3,Menu,T_Open_list,Open1,Open22)
    end;
create_open_list(Session,appels=Menu,[{H,PCD,Var,Service}|T_Open_list],Open1,Open2) ->
    case check_display_appels_opt(Session,H,PCD,Var,Service) of
        {_,USession1,[]}->
            create_open_list(USession1,Menu,T_Open_list,Open1,Open2);
	        {false,Usession2,Link}->
            Open11=Open1++[Link],
            create_open_list(Usession2,Menu,T_Open_list,Open11,Open2);
        {true,Usession3,Link}->
            Open22=Open2++[Link],
            create_open_list(Usession3,Menu,T_Open_list,Open1,Open22)
    end;
create_open_list(Session,sms_messages=Menu,[{H,PCD,Var,Service}|T_Open_list],Open1,Open2) ->
    case check_display_sms_messages_opt(Session,H,PCD,Var,Service) of
	{_,USession1,[]}->
            create_open_list(USession1,Menu,T_Open_list,Open1,Open2);
	{false,Usession2,Link}->
            Open11=Open1++[Link],
            create_open_list(Usession2,Menu,T_Open_list,Open11,Open2);
        {true,Usession3,Link}->
            Open22=Open2++[Link],
            create_open_list(Usession3,Menu,T_Open_list,Open1,Open22)
    end.
create_close_list(Session,_,[],Close1)->
    Close1;
create_close_list(Session,multimedia=Menu,[{H,PCD,Var,Service}|T_Close_list],Close1) ->
    case check_display_multimedia_opt(Session,H,PCD,Var,Service) of
	{true,UpdateSession1,Link}->
            Close11=Close1++[Link],
            create_close_list(UpdateSession1,Menu,T_Close_list,Close11);
	{_,UpdateSession2,_}->
	    create_close_list(UpdateSession2,Menu,T_Close_list,Close1)
    end;
create_close_list(Session,sms_messages=Menu,[{H,PCD,Var,Service}|T_Close_list],Close1) ->
    case check_display_sms_messages_opt(Session,H,PCD,Var,Service) of
        {true,UpdateSession1,Link}->
            Close11=Close1++[Link],
	    create_close_list(UpdateSession1,Menu,T_Close_list,Close11);
	{_,UpdateSession2,_}->
            create_close_list(UpdateSession2,Menu,T_Close_list,Close1)
    end.

check_display_multimedia_opt(Session, Opt=opt_orange_sport, PCD, Var, Service) ->
    case svc_util_of:is_commercially_launched(Session,Opt) of
        true ->
	    case svc_option_manager:is_subscribed(Session,Opt) of
		{USession1,true}->
		    Href=?Erl_multimedia_link++Var++"&"++Service,
		    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession2,false}->
		    Href=?Erl_multimedia_link++Var++"&"++Service,
		    {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		Other ->
		    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[Opt,Other]),
		    {false,Session,[]}
	    end;
	_ ->
            slog:event(trace, ?MODULE, proposer_lien, {is_comm_launched, false}),
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt=opt_internet,PCD, Var, Service)->
    case svc_option_manager:is_subscribed(Session,opt_internet_v2_pp) of
	{USession1,true} ->
	    Href=?Erl_multimedia_link++"opt_internet_v2_pp"++"&"++Service,
            {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	{USession2,false}->
	    Href=?Erl_multimedia_link++"opt_internet_v3_pp"++"&"++Service,
	    case svc_option_manager:is_subscribed(USession2,opt_internet_v3_pp) of
		{USession21,true} ->
		    {true,USession21,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession22,false} ->
		    {false,USession22,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		Other ->
		    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[opt_internet_v3_pp,Other]),
		    {false,USession2,[]}
	    end;
	Other ->
	    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[opt_internet_v2_pp,Other]),	
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt=opt_musique_mix,PCD, Var, Service)->
    case svc_util_of:is_commercially_launched(Session,Opt) of
        true ->
	    case svc_option_manager:is_subscribed(Session,opt_musique) of
		{USession1,true} ->
		    Href=?Erl_multimedia_link++"opt_musique"++"&"++Service,
		    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession2,false}->
		    Href=?Erl_multimedia_link++"opt_musique_mix"++"&"++Service,
		    case svc_option_manager:is_subscribed(USession2,opt_musique_mix) of
			{USession21,true} ->
			    {true,USession21,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
			{USession22, false} ->
			    {false,USession22,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
			Other ->
			    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[opt_musique_mix,Other]),
			    {false,USession2,[]}
		    end;
		Other ->
		    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[opt_musique,Other]),
		    {false,Session,[]}
	    end;
	_ ->
	    slog:event(trace, ?MODULE, proposer_lien, {is_comm_launched, false}),
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt=opt_internet_max,PCD, Var, Service) ->
    case svc_option_manager:is_subscribed(Session,opt_internet_max_pp) of
	{USession1,true}->
	    Href=?Erl_multimedia_link++"opt_internet_max_pp"++"&"++Service,
	    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	{USession2,false}->
	    Href=?Erl_multimedia_link++"opt_internet_max_v3"++"&"++Service,
	    case svc_option_manager:is_subscribed(USession2,opt_internet_max_v3) of
		{USession21,true}->
		    {true, USession21, [#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession22,false} ->
		    {false, USession22, [#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		Other ->
                    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[opt_internet_max_v3,Other]),
                    {false,USession2,[]}
	    end;
	Other ->
            slog:event(trace,?MODULE, check_display_multimedia_opt_error,[opt_internet_max_pp,Other]),
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt,PCD, Var, Service)
  when (Opt == opt_internet_max_journee) or (Opt == opt_internet_max_weekend) ->
    case svc_util_of:is_good_plage_horaire(Opt) of
        true ->
	    Href=?Erl_multimedia_link++Var++"&"++Service,
	    case svc_option_manager:is_subscribed(Session,Opt) of
		{USession1,true}->
		    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession2,false}->
		    {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		Other ->
                    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[Opt,Other]),
                    {false,Session,[]}
	    end;
	false ->
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt,PCD, Var, Service)
  when (Opt == opt_tv_max) or
       (Opt == opt_foot_ligue1) ->
    case svc_option_manager:is_subscribed(Session,Opt) of
	{USession1,false}->
	    {false,USession1,[]};
	{USession2,true}->
	    Href=?Erl_multimedia_link++Var++"&"++Service,
	    {true,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	Other ->
	    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt,PCD, Var, Service)
  when (Opt == opt_surf_mensu) or
       (Opt == opt_tv_mensu)->    
    case svc_option_manager:state(Session,Opt) of
        {Usession,actived}->
            Href=?Erl_multimedia_link++Var++"&"++Service,
	    {true,Usession,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	_->
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session,Opt,PCD, Var, Service) 
  when (Opt == opt_musique_collection) ->
    case svc_util_of:is_commercially_launched(Session,Opt) of
        true ->
            Href=?Erl_multimedia_link++Var++"&"++Service,
	    case svc_option_manager:is_subscribed(Session,Opt) of
		{USession1, true}->
		    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession2, false}->
		    {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]}
	    end;
	_ ->
	    slog:event(trace, ?MODULE, proposer_lien, {is_comm_launched, false}),
            {false, Session, []}
    end;
check_display_multimedia_opt(Session, Opt, PCD, Var, Service)
  when (Opt == opt_mes_donnees) ->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
	?B_phone->
	    {false,Session,[]};
	_->
	    Href=?Erl_multimedia_link++Var++"&"++Service,
	    case svc_option_manager:is_subscribed(Session,Opt) of
		{USession1, true}->
		    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession2, false} ->
		    {false, USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		Other ->
                    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[Opt,Other]),
		    {false,Session,[]}
	    end
    end;
check_display_multimedia_opt(Session, Opt, PCD, Var, Service)
  when Opt == opt_mail;
       Opt == opt_tv->
    Href=?Erl_multimedia_link++Var++"&"++Service,
    case svc_option_manager:is_subscribed(Session,Opt) of
	{USession1, true}->
	    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	{USession2,false}->
	    {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	Other ->
	    slog:event(trace,?MODULE, check_display_multimedia_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end;
check_display_multimedia_opt(Session, Opt, PCD, Var, Service)
  when Opt == opt_visio->
    Href=?Erl_multimedia_link++Var++"&"++Service,
    {true,Session,[#hlink{href=Href, contents=[{pcdata,PCD}]}]}.


display_appels_menu(plugin_info,_)->
        (#plugin_info
     {help =
      "This plugin function prints the page of options of multimedia"
      "Five or less options can be print on the first page"
      "If the user has subscribed to more than five options"
      "a link 'Suite' is printed",
      type = function,
      license = [],
      args = [
              {index, {oma_type, {defval,"",string}},
                "This parameter specifies the start index in list to display."}
             ]
     });
display_appels_menu(abs,_) ->
    [{pcdata,""}];
display_appels_menu(#session{prof=#profile{subscription=Sub}}=Session,Start)
when Sub=="mobi"->
    Index = list_to_integer(Start),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    Redirect_mobicarte= pbutil:get_env(pservices_orangef,redirect_mobicarte),
    {value, {_, List}} = lists:keysearch(sachem, 1, Redirect_mobicarte),
    {value, {_, Declinaison}} = lists:keysearch(integer_to_list(DCL), 1, List),
    List_opts=create_list_appels_opts(Session,Declinaison),
    Options = lists:nthtail(Index, List_opts),
    All_lines = get_appels_options_page(Session, Index, Options, 0),
    Item = svc_util_of:br_separate(All_lines),
    {page, Session, #page{items= Item}}.

create_list_appels_opts(Session, Declinaison)->
    Open_list=case Declinaison of
	umobile->
	    [
	     {opt_jinf,"Journee Infinie","opt_jinf","option_with_promo"},
	     {opt_sinf,"Soiree Infinie","opt_sinf","option_with_promo"},
	     {opt_weinf,"Week End Infini","opt_weinf","option_with_promo"}
	    ];
	_ ->
	    [
             {opt_jinf,"Journee Infinie","opt_jinf","option_with_promo"},
             {opt_sinf,"Soiree Infinie","opt_sinf","option_with_promo"},
             {opt_weinf,"Week End Infini","opt_weinf","option_with_promo"},
	     {opt_pack_duo_journee,"Duo Journee","opt_pack_duo_journee","option_with_promo"},
	     {opt_10mn_quotidiennes,"10 minutes quotidiennes","opt_10mn_quotidiennes","10mn_quotidiennes"},
	     {opt_30mn_hebdomadaires,"30 minutes hebdomadaires","opt_30mn_hebdomadaires","30mn_hebdomadaires"}
            ]
    end,
    create_open_list(Session,appels,Open_list,[],[]).

check_display_appels_opt(Session,Opt,PCD,Var,Service)
    when Opt == opt_jinf;
	 Opt == opt_sinf;
	 Opt == opt_pack_duo_journee->
    State = svc_util_of:get_user_state(Session),
    Declinaison = State#sdp_user_state.declinaison,
    {Var1,Service1}=case Declinaison of
			?umobile->
			    {Var,Service};
			_->
			    State = svc_util_of:get_user_state(Session),
			    Curr={sum,euro,3000},
			    SoldeCpte = svc_compte:solde_cpte(State, cpte_bons_plans_jeu),
			    case currency:is_infeq(Curr,SoldeCpte) of
				true -> 
				    {Var++"_jeu","option_jeu_disney"};
				_ ->
				    {Var,Service}
			    end
		    end,
    Href=?Erl_appels_link++Var1++"&"++Service1,
    case svc_option_manager:is_subscribed(Session, Opt) of
	{USession1,true}->
	    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	{USession2,false}->
	    {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	Other ->
	    slog:event(trace,?MODULE, check_display_appels_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end;
check_display_appels_opt(Session,Opt,PCD,Var,Service) 
  when Opt==opt_weinf->
    Href=?Erl_appels_link++Var++"&"++Service,
    case svc_option_manager:is_subscribed(Session, Opt) of
        {USession1,true}->
            {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	{USession2,false}->
            {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	Other ->
            slog:event(trace,?MODULE, check_display_appels_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end;
check_display_appels_opt(Session,Opt=opt_10mn_quotidiennes,PCD,Var,Service)->
    Href=?Erl_appels_link++Var++"&"++Service,
    case svc_option_manager:state(Session, Opt) of
        {USession1,actived} ->
	    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	Other->
	    slog:event(trace,?MODULE, check_display_appels_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end;
check_display_appels_opt(Session,Opt=opt_30mn_hebdomadaires,PCD,Var,Service) ->
    Href=?Erl_appels_link++Var++"&"++Service,
    case svc_option_manager:state(Session, Opt) of
        {USession1,actived}->
	    {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};    
	{USession2,suspend} ->
	    {true,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
        {USession3,_}->
	    {false,USession3,[]};
	Other ->
	    slog:event(trace,?MODULE, check_display_appels_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end.

check_display_sms_messages_opt(Session,Opt=opt_30_sms_mms,PCD,Var,Service)->
    Href=?Erl_sms_messages_link++Var++"&"++Service,
    case svc_option_manager:is_subscribed(Session, Opt) of
        {USession1,true}->
            {true,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	{USession2,false}->
            {false,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
        Other ->
            slog:event(trace,?MODULE, check_display_sms_messages_opt_error,[Opt,Other]),
            {false,Session,[]}
    end;
check_display_sms_messages_opt(Session,Opt=opt_sms_quoti,PCD,Var,Service) ->
    Href=?Erl_sms_messages_link++Var++"&"++Service,
     case svc_option_manager:state(Session, Opt) of
         {USession1,suspend}->
	     {true,USession1,[]};
         {USession2,activate}->
	     {true,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	 {USession3,_}->
	     {false,USession3,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	 Other ->
	     slog:event(trace,?MODULE, check_display_sms_messages_opt_error,[Opt,Other]),
	     {false,Session,[]}
     end;
check_display_sms_messages_opt(Session,Opt,PCD,Var,Service) 
  when Opt == opt_sms_mensu; 
       Opt == opt_sms_illimite->
    Href=?Erl_sms_messages_link++Var++"&"++Service,
    case svc_option_manager:is_subscribed(Session, Opt) of
	{USession1,false}->
	    {false,USession1,[]};
	{USession2,true} ->
	    {true,USession2,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
	Other->
	    slog:event(trace,?MODULE, check_display_sms_messages_opt_error,[Opt,Other]),
	    {false,Session,[]}
    end;
check_display_sms_messages_opt(Session,Opt,PCD,Var,Service)
  when Opt==opt_jsms_illimite;
       Opt==opt_ssms_illimite ->
    case svc_util_of:is_commercially_launched(Session,Opt) of
        true ->
	    State = svc_util_of:get_user_state(Session),
	    Curr={sum,euro,2500},
	    SoldeCpte = svc_compte:solde_cpte(State, cpte_bons_plans_jeu),
 	    {Var1,Service1}=
		case currency:is_infeq(Curr,SoldeCpte) of
		    true ->
			{Var++"_jeu","option_jeu_disney"};
		    _ ->
			{Var,Service}
		end,
	    Href=?Erl_sms_messages_link++Var1++"&"++Service1,
            case svc_option_manager:is_subscribed(Session, Opt) of
                {USession1,false}->    
                    {false,USession1,[#hlink{href=Href, contents=[{pcdata,PCD}]}]};
		{USession2,true}->
		    {true,USession2,[]};
		Other ->
		    slog:event(trace,?MODULE, check_display_sms_messages_opt_error,[Opt,Other]),
		    {false,Session,[]}
            end;
        _ ->
	    slog:event(trace,?MODULE, out_of_commercial_date,Opt),
            {false,Session,[]}
    end.
    
get_options_page(Session, Index, [], Nlinks) ->
    [];
get_options_page(Session, Index, [H_link | T_links], Nlinks) ->
    case Nlinks of 
        5 -> 
	    Next=integer_to_list(Index),
            Suite_Href="erl://svc_of_plugins:display_multimedia_menu?"++Next,
            [#hlink{href=Suite_Href, contents=[{pcdata,"Suite"}]}];
        _ -> 
	    lists:append([H_link, get_options_page(Session, Index+1, T_links, Nlinks + 1)])
    end.

get_appels_options_page(Session, Index, [], Nlinks) ->
    [];
get_appels_options_page(Session, Index, [H_link | T_links], Nlinks) ->
    case Nlinks of
        6 ->
            Next=integer_to_list(Index),
            Suite_Href="erl://svc_of_plugins:display_appels_menu?"++Next,
            [#hlink{href=Suite_Href, contents=[{pcdata,"Suite"}]}];
        _ ->
            lists:append([H_link, get_appels_options_page(Session, Index+1, T_links, Nlinks + 1)])
    end.

get_sms_messages_options_page(Session, Index, [], Nlinks) ->
    [];
get_sms_messages_options_page(Session, Index, [H_link | T_links], Nlinks) ->
    case Nlinks of
        6 ->
            Next=integer_to_list(Index),
            Suite_Href="erl://svc_of_plugins:display_sms_messages_menu?"++Next,
            [#hlink{href=Suite_Href, contents=[{pcdata,"Suite"}]}];
        _ ->
            lists:append([H_link, get_sms_messages_options_page(Session, Index+1, T_links, Nlinks + 1)])
    end.

display_sms_messages_menu(plugin_info,_)->
    (#plugin_info
     {help =
      "This plugin function prints the page of options of multimedia"
      "Five or less options can be print on the first page"
      "If the user has subscribed to more than five options"
      "a link 'Suite' is printed",
      type = function,
      license = [],
      args = [
              {index, {oma_type, {defval,"",string}},
                "This parameter specifies the start index in list to display."}
             ]
     });
display_sms_messages_menu(abs,_) ->
    [{pcdata,""}];
display_sms_messages_menu(#session{prof=#profile{subscription=Sub}}=Session,Start)
when Sub=="mobi"->
    Index = list_to_integer(Start),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    Redirect_mobicarte= pbutil:get_env(pservices_orangef,redirect_mobicarte),
    {value, {_, List}} = lists:keysearch(sachem, 1, Redirect_mobicarte),
    {value, {_, Declinaison}} = lists:keysearch(integer_to_list(DCL), 1, List),
    List_opts=create_list_sms_messages_opts(Session,Declinaison),
    Options = lists:nthtail(Index, List_opts),
    All_lines = get_sms_messages_options_page(Session, Index, Options, 0),
    Item = svc_util_of:br_separate(All_lines),
    {page, Session, #page{items= Item}}.
create_list_sms_messages_opts(Session,Declinaison)->
    Open_list=case Declinaison of
		  umobile ->
		      [
		       {opt_ssms_illimite,"Soiree SMS illimites","opt_ssms_illimite","option"}
		      ];
		  _ ->
		      [
		       {opt_30_sms_mms,"30 SMS/MMS","opt_30_sms_mms","option"},
		       {opt_sms_quoti,"bon plan SMS quotidien","opt_sms_quoti","opt_sms_quoti"},
		       {opt_jsms_illimite,"Journee SMS Illimites","opt_jsms_illimite","opt_jsms_illimite"},
		       {opt_ssms_illimite,"Soiree SMS illimites","opt_ssms_illimite","opt_ssms_illimite"}	     
		      ]
	      end,
    Close_list=case Declinaison of
		   umobile->
		       [];
		   _ ->
		       [
			{opt_sms_mensu,"Option SMS mensuelle","opt_sms_mensu","opt_sms_mensu"},
			{opt_sms_illimite,"Messages illimites","opt_sms_illimite","option"}
		       ]
	       end,
    Open_links=create_open_list(Session,sms_messages,Open_list,[],[]),
    Close_links=create_close_list(Session,sms_messages,Close_list,[]),
    List_multimedia_opts=Open_links++Close_links.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type links_to_options(session()) -> erlpage_result().                      
%%%% This plugin function prints the page of options that
%%%% the user has subscribed
%%%% Three or less options can be print on the first page
%%%% If the user has subscribed to more than three options
%%%% a link 'Suite' is created
%%%% This link 'Suite' will automatically call the function next_page_options.

links_to_options(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function prints the page of options that" 
      "the user has subscribed"
      "Three or less options can be print on the first page"
      "If the user has subscribed to more than three options"
      "a link 'Suite' is printed",
      type = function,
      license = [],
      args = []   
     });

links_to_options(abs) ->
    [{redirect,abs,"#options"}];

links_to_options(#session{prof=#profile{subscription=Sub}}=Session) ->
    OptActiv= svc_subscr_asmetier:cast(Session),
    ListServOpt1=OptActiv#activ_opt.listServOpt,
    ListServOpt=case ListServOpt1 of
		     undefined->[];
		     _->ListServOpt1
		end,
    {Var_list_opts, Num_opts_per_page} = case Sub of
					     "postpaid" ->
						 {asmetier_opt_postpaid, ?Number_opts_per_page_postpaid};
					     _ ->
						 {asmetier_opt_cmo, ?Number_opts_per_page_cmo}
					 end,

    ListOptions=pbutil:get_env(pservices_orangef,Var_list_opts),
    User_opt_active= list_active_opts(ListServOpt,ListOptions),
    slog:event(trace,?MODULE,user_opt_active,User_opt_active),
    Nbre_p=number_of_page(length(User_opt_active),Num_opts_per_page),
    Current_page_opt=lists:sublist(User_opt_active,?Start,Num_opts_per_page),

    Fun=fun(Opt_code,Acc)->	
		case Opt_code of
                    [] ->[];
                    _-> 
			Href_subscribe="erl://svc_of_plugins:option_page?"++Opt_code,
                        Acc++[#hlink{href=Href_subscribe,
                                     contents=[{pcdata,opt_code_to_name(Session,Opt_code)}]}]
                end
	end,

    Text=[{pcdata,"Gerer mes options"}],
    Text2_=[{pcdata,"Vous pouvez modifier chaque option."}],
    Links = case Current_page_opt of
                [] ->[];
                _ ->lists:foldl(Fun,[],Current_page_opt)
            end,
    case Nbre_p of
	0->Text;
	1 ->    		  
	    All_lines = lists:append([Text,Links,Text2_]),
	    Item = svc_util_of:br_separate(All_lines),
	    {page, Session, #page{items= Item}};
	_ ->    	
	    Number_of_pages=integer_to_list(Nbre_p),
	    Next_page_active=integer_to_list(?First_page_active+1),
	    Next_start=integer_to_list(?Start+Num_opts_per_page),
	    Href_suite="erl://svc_of_plugins:next_opt_page?" 
		++Next_page_active++"&"++Next_start,
	    Suite= [#hlink{href=Href_suite, contents=[{pcdata,"Suite"}]}],
	    All_lines = lists:append([Text, Links, Suite, Text2_]),
	    Item = svc_util_of:br_separate(All_lines),
	    {page, Session, #page{items= Item}}				
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type next_opt_page(session(), Page_active::integer(),    
%%   Start::integer(), End::integer())-> erlpage_result().
%%%% redirect to the next option pages if the user has subscribed to
%%%%  more than 3 options.
next_opt_page(#session{prof=#profile{subscription=Sub}}=Session, Page_active, Start) ->
    OptActiv = svc_subscr_asmetier:cast(Session),
    ListServOpt=case OptActiv#activ_opt.listServOpt of
		     undefined->[];
		     _->OptActiv#activ_opt.listServOpt
		end,
    {Var_list_opts, Num_opts_per_page} = case Sub of
                                             "postpaid" ->
                                                 {asmetier_opt_postpaid, ?Number_opts_per_page_postpaid};
                                             _ ->
                                                 {asmetier_opt_cmo, ?Number_opts_per_page_cmo}
                                         end,

    ListOptions=pbutil:get_env(pservices_orangef,Var_list_opts),
    User_opt_active= list_active_opts(ListServOpt,ListOptions),
	case list_to_integer(Start) > length(User_opt_active) of
		true-> {page, Session, #page{items= [{pcdata,"Gerer mes options"}]}};
		_->
 	  	     Nbre_p=number_of_page(length(User_opt_active),Num_opts_per_page),
    Current_page_opt=lists:sublist(User_opt_active,
				   list_to_integer(Start),
				   Num_opts_per_page),

    Fun=fun(Opt_code,Acc)->
		case Opt_code of
 	  	 		    [] -> [];
		    _->
			Href_subscribe="erl://svc_of_plugins:option_page?"++Opt_code,
                        Acc++[#hlink{href=Href_subscribe,
                                     contents=[{pcdata,opt_code_to_name(Session,Opt_code)}]}]
		end
	end,

    Text=[{pcdata,"Gerer mes options"}],
    Text2_=[{pcdata,"Vous pouvez modifier chaque option."}],

    Links = case Current_page_opt of
		[] ->
		    [];
		_ ->
		    lists:foldl(Fun,[],Current_page_opt)
	    end,
      case  Page_active of
	Nbre_p->
	    All_lines = lists:append([Text,Links,Text2_]),
	    Item = svc_util_of:br_separate(All_lines),
	    {page, Session, #page{items= Item}};
	_ ->
	    Next_page_active=integer_to_list(list_to_integer(Page_active)+1), 
	    Next_start=integer_to_list(list_to_integer(Start)+Num_opts_per_page), 
	    Href_suite="erl://svc_of_plugins:next_opt_page?" 
 	  	 	  	  		++Next_page_active++"&"++Next_start,
	    Suite= [#hlink{href=Href_suite, contents=[{pcdata,"Suite"}]}],
	    {page,Session,#page{items=svc_util_of:br_separate(Text
							      ++Links
							      ++Suite
							      ++Text2_
							     )}}
 	  	 	   end
    end.

option_page(#session{prof=#profile{subscription=Sub}}=Session,Code_opt)->
    Service=case Sub of
		"postpaid" ->
		    resiliation_postpaid;
		_ ->
		    resiliation_cmo
	    end,
    NewSession=variable:update_value(Session,{Service,"code_option"},Code_opt),
    {redirect,NewSession,"#option_page"}.

print_opt_name(#session{prof=#profile{subscription=Sub}}=Session)->
    Service=case Sub of
                "postpaid" ->
                    resiliation_postpaid;
                _ ->
                    resiliation_cmo
            end,
    Code_opt=variable:get_value(Session,{Service,"code_option"}),
    Opt_name=opt_code_to_name(Session,Code_opt),
    [{pcdata,Opt_name}].

print_opt_foot_name(plugin_info) ->
    (#plugin_info
     {help =
      "This plugin function includes the name of the defined option",
      type = function,
      license = [],
      args = []
     });

print_opt_foot_name(Session)-> %%Using for foot
    Opt=variable:get_value(Session, {"bons_plans","option"}),
    Opt_name=opt_foot_name(Opt),
    [{pcdata,Opt_name}].

opt_code_to_name(#session{prof=#profile{subscription=Sub}}=Session,Opt_code)->
    ListOptions=case Sub of
		    "postpaid" ->
			pbutil:get_env(pservices_orangef,asmetier_opt_postpaid);
		    _ ->
			pbutil:get_env(pservices_orangef,asmetier_opt_cmo)
		end,
    Atom=search_option_resil(Opt_code,ListOptions),
    ListOptNames=case Sub of
                    "postpaid" ->
			 lists:keysearch(Atom,1,pbutil:get_env(pservices_orangef,opt_commercial_name_postpaid));
		     _ ->
			 lists:keysearch(Atom,1,pbutil:get_env(pservices_orangef,opt_commercial_name_cmo))
		 end,
    case ListOptNames of
	{value,{Atom,Name}}->
	    Name ;
	_ ->
	    slog:event(failure,?MODULE,opt_code_to_name,Atom), 
	    atom_to_list(Atom),
	    nok
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type filter_option_list(session(), List_opt::string())->string().
%%%% Internal function used by plugin links_to_options.
%%%% Filter the list of topnum list

filter_option_list(Session,List_opt) -> 

    List= lists:filter(fun(X) -> X /= [] end, List_opt),
    List_f1=filter_opt_m6_smsmms(Session, List),
    List_f2=filter_opt_pass_vacances_v2(List_f1),
    List_f3=filter_opt_pass_vacances(List_f2).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type filter_opt_m6_smsmms(session(), List::string())->string().
%%%% Internal function used by filter_option_list.
%%%% Delete opt_m6_smsmms if the DCL is different to 14,18,22,23,30,31,32,33.

filter_opt_m6_smsmms(Session, List)->
    
 case lists:member(opt_m6_smsmms,List) of

     true ->State = svc_util_of:get_user_state(Session),
	    DCL_NUM = State#sdp_user_state.declinaison,
	    
	    case DCL_NUM of
	
		?m6_cmo ->List;
		?m6_cmo2 ->List;
		?m6_cmo3 ->List;
		?m6_cmo4 ->List;
		?m6_cmo_1h ->List;
		?m6_cmo_1h20 ->List;
		?m6_cmo_1h40 ->List;
		?m6_cmo_1h_v3 ->List;
		?m6_cmo_1h30_v3 ->List;
		?m6_cmo_2h_v3 ->List;
		?m6_cmo_2h ->List;
		?m6_cmo_3h ->List;
		?m6_cmo_20h_8h ->List;
		?m6_cmo_ete -> List;
		?sl_blackberry_1h -> List;
		?m6_cmo_onet_1h_20E -> List;
		?m6_cmo_onet_1h_27E -> List;
		?m6_cmo_onet_2h_30E -> List;
		?FB_M6_1H_SMS -> List;
		?FB_M6_1H30 -> List;
		_  ->slog:event(failure,?MODULE,filter_opt_m6_smsmms,DCL_NUM), 
		     lists:delete(opt_m6_smsmms,List)
	    end;

     false ->List
		    
 end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type filter_opt_pass_vacances(List_f::string())->string().
%%%% Internal function used by filter_option_list.
%%%% The option opt_pass_vacances has 2 different TopNum. 

filter_opt(Option,List_f)->
    case lists:member(opt_pass_vacances_moc,List_f) of
	true -> 
	    case lists:member(opt_pass_vacances_mtc,List_f) of
		true  -> List_f1_=lists:delete(opt_pass_vacances_moc,List_f),
			 List_f2_=lists:delete(opt_pass_vacances_mtc,List_f1_),
			 case Option of
			     none -> List_f2_;
			     _    -> [Option|List_f2_]
			 end;
		false -> lists:delete(opt_pass_vacances_moc,List_f)
	    end;
	false ->
	    case lists:member(opt_pass_vacances_mtc,List_f) of 
		true-> lists:delete(opt_pass_vacances_mtc,List_f);
		false -> List_f
	    end
    end. 


filter_opt_pass_vacances_v2(List_f)->
    SMS_member = lists:member(opt_pass_vacances_v2_10_sms,List_f),
    List_f1_=lists:delete(opt_pass_vacances_v2_10_sms,List_f),
    case SMS_member of
	true ->
	    filter_opt(opt_pass_vacances_v2,List_f1_);
	false ->
	    filter_opt(none,List_f1_)
    end.

filter_opt_pass_vacances(List_f)->
    filter_opt(opt_pass_vacances,List_f).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type number_of_page(Nbre_opt::integer())-> integer().
%%%% Calculate the number of page (3 options max per page)
%%%% Internal function used by plugin links_to_options.

number_of_page(Nbre_opt,Number_opts_per_page)->
     Number_page = erlang:trunc(Nbre_opt/Number_opts_per_page),
     case (Nbre_opt/Number_opts_per_page - Number_page) of
         Neg when Neg < 0 -> Number_page;
         Pos when Pos > 0 -> Number_page + 1;
        _ -> Number_page
     end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_credit_options(session(),Opt::string(), U_ac::string(),
%%  U_ep::string())-> erlpage_result(). 
%%%% this plugin checks the credit of an ACTIVE option,
%%%% redirect to 'U_ac' if there is credit,
%%%% redirect to 'U_ep' if there is no credit left.

check_credit_options(plugin_info,Opt, U_ac, U_ep) ->
     (#plugin_info
      {help =
       "This plugin command redirects to the corresponding page depending on"
       "whether the option is activated and the corresponding account has"
       " credit. ",
       type = command,
       license = [],
       args =
       [{option, {oma_type, {enum, [media_decouvrt,
				    media_internet,
				    media_internet_plus,
				    opt_mms_mensu,
				    opt_sms_quoti,
				    opt_sms_mensu,
				    opt_sms_3,
				    opt_sms_7_5,
				    opt_sms_12,          
				    opt_sms_18,                    
				    opt_sms_25,
				    opt_2numpref,
				    opt_five_min,
				    opt_OW_10E,
				    opt_OW_30E,
				    sms_opt_OW,
				    opt_credit_voix_of,
				    opt_credit_sms_of,
				    opt_credit_OW_of,
				    opt_bons_plans,
				    opt_1h_ts_reseaux
				     ]}},
	 "This parameter specifies the option."},
        {u_ac, {link,[]},
 	"This parameter specifies the next page when 3 or less options exist"},
        {u_ep, {link,[]},
 	"This parameter specifies the next page when no option exist."}
       ]});
 

check_credit_options(abs,Opt, U_ac, U_ep)->
     [{redirect,abs,U_ac},{redirect,abs,U_ep}];
check_credit_options(Session, Opt, U_ac, U_ep) ->
    Subscription= svc_util_of:get_souscription(Session),
    State = svc_util_of:get_user_state(Session),   
    Compte = list_to_atom(svc_options:opt_to_godet(Opt,Subscription)),
    case svc_compte:etat_cpte(State, Compte) of
	?CETAT_AC->  {redirect,Session,U_ac};
	_->{redirect,Session,U_ep}
      end.
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_dcl_cmo(session(),Opt::string(),URL_14_18::string(),
%%                        URL_22_23::string(),URL_30_31::string(),
%%                        URL_32_33::string()) ->
%%                        erlpage_result().
%%%% Redirection depending on the DCL
%%%% redirect to URL_14_18 when the DCL  is 14 or 18,
%%%% redirect to URL_22_23 when the DCL  is 22 or 23,
%%%% redirect to URL_30_31 when the DCL  is 30 or 31,
%%%% redirect to URL_32_33 when the DCL  is 32 or 33.

redirect_dcl_cmo(plugin_info, Opt, URL_14_18, URL_22_23, URL_30_31, URL_32_33) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the  DCL",
      type = command,
      license = [],
      args =
      [
       {opt, {oma_type, {enum, [opt_m6_smsmms]}},
        "This parameter specifies the option."},
       {url_14_18, {link,[]},
	"This parameter specifies the next page when the option"
	"is subscribed with dcl 14 or 18."},
       {url_22_23, {link,[]},
	"This parameter specifies the next page when the option"
	"is subscribed with dcl 22 or 23."},
       {url_30_31, {link,[]},
	"This parameter specifies the next page when the option"
	"is subscribed with dcl 30 or 31."},
       {url_32_33, {link,[]},
	"This parameter specifies the next page when the option"
	"is subscribed with dcl 32 or 33."}
      
      ]});

redirect_dcl_cmo(abs, Opt, URL_14_18, URL_22_23, URL_30_31,
		 URL_32_33) ->

     [{redirect,abs,URL_14_18},{redirect,abs,URL_22_23},
      {redirect,abs,URL_30_31},{redirect,abs,URL_32_33}];

redirect_dcl_cmo(Session, Option, URL_14_18, URL_22_23, URL_30_31,
		 URL_32_33)
    when Option == "opt_m6_smsmms" ->	

    State = svc_util_of:get_user_state(Session),

    DCL_NUM = State#sdp_user_state.declinaison,
  
    Link = case DCL_NUM of

	       ?m6_cmo      -> URL_14_18;
	       ?m6_cmo2     -> URL_14_18;
	       ?m6_cmo3     -> URL_22_23;
	       ?m6_cmo4     -> URL_22_23;
	       ?m6_cmo_1h   -> URL_30_31;
	       ?m6_cmo_1h20 -> URL_30_31;
	       ?m6_cmo_1h40 -> URL_32_33;
	       ?m6_cmo_2h   -> URL_32_33;
	       ?m6_cmo_3h   -> URL_32_33;
	       ?m6_cmo_20h_8h -> URL_32_33;
	       ?m6_cmo_onet_1h_20E -> URL_32_33;
	       ?m6_cmo_onet_1h_27E -> URL_32_33;
	       ?m6_cmo_onet_2h_30E -> URL_32_33;
	       ?FB_M6_1H_SMS -> URL_32_33;
	       ?FB_M6_1H30 -> URL_32_33;
	       _  -> slog:event(failure,?MODULE,redirect_DCL_cmo,DCL_NUM)     
	   end,

    {redirect, Session, Link}.
	   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_date(session(), Url_week::string(),
%%                      Url_WE::string()) -> erlpage_result().
%%%% Redirection depending on the current day
%%%% Redirect to Url_week when the current day is included between 
%%%% Monday and Friday ,
%%%% redirect to Url_WE when the current day is saturday or sunday.

redirect_date(plugin_info, Url_week, Url_WE) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the current day (week or week-end)",
      type = command,
      license = [],
      args =
      [
       {url_week, {link,[]},
	"This parameter specifies the next page when the current day"
	"do not belong to the WE."},
       {url_WE, {link,[]},
	"This parameter specifies the next page when the current day"
	" belong to the WE."}
      ]});


redirect_date(abs, Url_week, Url_WE) ->
    [{redirect,abs,Url_week},{redirect,abs,Url_WE}];

redirect_date(Session,  Url_week, Url_WE)->

    Link = case calendar:day_of_the_week(date()) of
	       N when N==6; N==7 -> Url_WE;
	       _ -> Url_week
	   end,

    {redirect, Session, Link}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_time(session(), Url_week::string(),
%%                      Url_WE::string()) -> erlpage_result().
%%
%%%% Redirection depending on the current day
%%%% Redirect to Url_week when the current day is included between 
%%%% Monday and Friday ,
%%%% redirect to Url_WE when the current day is saturday or sunday.

redirect_time(plugin_info, Option, Url_in_range, Url_out_range)->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether the option is activated or not according to the range "
      " specified in the paramter pservices_orangef::plage_horaire",
      type = command,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_sms_quoti,
				   opt_sinf,
				   opt_jinf,
				   opt_j_app_ill,
				   opt_s_app_ill,
				   opt_j_mm_ill,
				   opt_s_mm_ill,
				   opt_ssms_ill,
				   opt_jsms_ill,
				   opt_ssms,
				   opt_tt_shuss,
								   opt_pack_duo_journee,
				   opt_numprefp,
				   opt_vacances,
				   opt_j_omwl,
				   opt_msn_journee_mobi,
				   opt_appelprixunique,
				   opt_ssms_m6
				]}},
	"This parameter specifies the option which is limited by time range."
       "see pservices_orangef::plage_horaire"},
       {url_in_range, {link,[]},
	"This parameter specifies the next page when the current time "
	" matches with the opening time for the option."},
       {url_out_range, {link,[]},
	"This parameter specifies the next page when the current time"
	" is out of the openig time of the option."}
      ]});

redirect_time(abs, Option, Url_in_range, Url_out_range)->
    [{redirect,abs,Url_in_range},{redirect,abs,Url_out_range}];

redirect_time(Session, Option, Url_in_range, Url_out_range)->   
    case svc_util_of:is_good_plage_horaire(Option) of
	true ->
	    {redirect, Session, Url_in_range};
	false ->
	    {redirect, Session, Url_out_range}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLUGINS RELATED TO MMS INFOS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_capability_mms(session(),Url_ok::string(),
%%                            Url_nok::string()) ->
%%                            erlpage_result(). 
%%%% Check terminal capability to do MMS or MMS Video

check_capability_mms(plugin_info, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command checks the terminal capability to do MMS"
      " or MMS Video, and redirects to the next page.",
      type = command,
      license = [],
      args =
      [
       {url_ok, {link,[]},
	"This parameter specifies the SMS MMS infos menu page "
	"according with terminal MMS capability"},
       {url_nok,{link,[]},
	"This parameter specifies the next page in case of a"
	" technical problem"}
      ]});

check_capability_mms(abs, Url_ok, Url_nok) ->
    svc_mmsinfos:start(abs,Url_ok)++
    [{redirect, abs, Url_nok}];

check_capability_mms(Session, Url_ok, Url_nok) ->
    svc_mmsinfos:start(Session,Url_ok).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% COMMON FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type check_capability_mms(session(),Url_ok::string(),
%%                            Url_nok::string()) ->
%%                            erlpage_result().

check_incompatible_souhaitee(plugin_info, Url_compatible_souhaitee, Url_incompatible_souhaitee)->
    (#plugin_info
     {help =
      "This plugin command checks value codeMessage of ExceptionServiceOptionnelImpossible",
      type = command,
      license = [],
      args =
      [
       {url_compatible_souhaitee, {link,[]},
        "This parameter specifies the page when ExceptionServiceOptionnelImpossible{codeMessage} is not 004 "},
       {url_incompatible_souhaitee,{link,[]},
        "This parameter specifies the page when ExceptionServiceOptionnelImpossible{codeMessage} is 004"}
      ]});
check_incompatible_souhaitee(abs, Url_compatible_souhaitee, Url_incompatible_souhaitee) ->
    [{redirect, abs, Url_compatible_souhaitee}];
check_incompatible_souhaitee(Session, Url_compatible_souhaitee, Url_incompatible_souhaitee) ->
    CodeMessage=variable:get_value(Session,exceptionServiceOptionnelImpossible),
    case CodeMessage of 
	"004"->
	    {redirect, Session, Url_incompatible_souhaitee};
	_ ->
	    {redirect, Session, Url_incompatible_souhaitee}
    end.

%% +type update_session(session(),Options::term())-> sdp_user_state().
%%%% Internal function used by plugins to update a specified
%%%% members of sdp_user_state record
%%%% and return session().

update_session(#session{prof=#profile{subscription=Sub}}=Session,
	       Options)
  when Sub=="cmo" ->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,
				  State#sdp_user_state{opt_activ=Options});
update_session(Session,Options) ->
    Session.

%% +type code_opt(session(),Option::string())-> SO_code::string().
%%%% Internal function used by plugin subscribe to retrieve
%%%% the SO code related to Option parameter.

code_opt(#session{prof=#profile{subscription=Sub}=Prof}, Opt) ->
    case svc_option_manager:get_SO_code_by_type(Opt,list_to_atom(Sub),subscribe) of
	"" ->
	    Msisdn = Prof#profile.msisdn,
	    Log= list_to_atom("unknown_option_"++Sub),
	    exit({?MODULE,Log,Opt,{msisdn,Msisdn}});
	[Code]->
	    Code
     end.

search_subscr_code_opt(Opt,[])->
    {nok,unknown_option};
search_subscr_code_opt(Opt,[Item|T]) ->
    case Item of
	{Opt,Code,X} when X==all;X==subscribe->
	    {ok,Code};
	_ ->
	    search_subscr_code_opt(Opt,T)
    end.
	    
search_resilier_code_opt(Opt,[])->
    {nok,unknown_option};
search_resilier_code_opt(Opt,[Item|T]) ->
    case Item of
	{Opt,Code,X} when X==all;X==terminate->
	    {ok,Code};
	_ ->
	    search_resilier_code_opt(Opt,T)
    end.

code_opt_resiliation(#session{prof=#profile{subscription="cmo"}}, Opt) ->
    case search_resilier_code_opt(Opt,pbutil:get_env(pservices_orangef,
						   asmetier_opt_cmo)) of
	{ok,Code}->
	    Code;
	_ ->
	    exit({?MODULE,unknown_option,Opt})
    end.

list_active_opts([],_)->
    [];
list_active_opts([{_,SOcode,_}|T],ListOptions) ->
    OptName=search_option_resil(SOcode,ListOptions),
    case OptName of
	[]->
	    list_active_opts(T,ListOptions);
	_-> [SOcode]++list_active_opts(T,ListOptions)
    end.

search_option_resil(_,[])->
    [];
search_option_resil(SOcode,[Item|T]) ->
    case Item of
	{Opt,SOcode,X}
	when X==all;X==terminate->
	    Opt;
	_->
	    search_option_resil(SOcode,T) 
    end.

redirect_by_kdo_dte(abs, URLs)->
    [Url,Url_kdo,Url_dte]=string:tokens(URLs,","),
    [{redirect, abs, Url},
     {redirect, abs, Url_kdo},
     {redirect, abs, Url_dte}];
redirect_by_kdo_dte(Session, URLs)-> 
    [Url,Url_kdo,Url_dte]=string:tokens(URLs,","),
    case svc_options:is_option_activated(Session, opt_dte_plus) of
        true ->
	     {redirect,Session,Url_dte};
        _ ->   
	    case svc_options:is_option_activated(Session, opt_ikdo) of
		true ->
	     	    {redirect,Session,Url_kdo};
		_ ->
	     	    {redirect,Session,Url}
	    end
    end.    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% refonte mobi              
%% +type redirect_if_kdo(session(),Opt::string(),URLs::string())->
%%                       erlpage_result().
%%%% Requests the value of field C_OP/OPT_DATE_SOUSCR from Sachem.
%%%% Redirects to corresponding page.

redirect_if_kdo(plugin_info,Opt,Uok,Unok)->
    (#plugin_info
     {help = 
      "This plugin command redirect to the corresponding page depending on"
      " whether the user has specified Nkdo",
      type = command,
      license = [],
      args = 
      [
       {opt, {oma_type, {enum ,[opt_illimite_kdo
				]}},
	"This parameter specifies the option."},
       {uok, {link,[]},
	"This parameter specifies the  next page when the nkdo is specified"},
       {unok, {link,[]},
	"This parameter specifies the  next page when the nkdo is not specified"}
       ]});

redirect_if_kdo(abs,_,Uok,Unok)->
    [{redirect,abs,Uok},{redirect,abs,Unok}];
redirect_if_kdo(Session,Opt,Uok,Unok)->
    Option = list_to_atom(Opt),
    NewSess = get_info_for_option(Session, Option),
    State = svc_util_of:get_user_state(NewSess),
    case State#sdp_user_state.c_op_opt_date_souscr of
	"0" -> 
	    {redirect,NewSess,Unok};
	_ ->
	    {redirect,NewSess,Uok}
    end.


%% +type get_info_for_option(session(), Option::atom())->
%%                           session().
%%%% Defines the TOP_NUM which should be used to send c_op request to Sachem.

get_info_for_option(Session, Option)
  when Option==opt_ikdo_vx_sms ->
    get_opt_info(Session, svc_options:top_num(opt_illimite_kdo,mobi));

get_info_for_option(Session, Option) ->
    get_opt_info(Session, svc_options:top_num(Option,mobi)).


%% +type get_opt_info(session(), TOPNUM::integer())->
%%                    session().
%%%% Send c_op request to Sachem server in order to get the fields 
%%%% OPT_DATE_SOUSCR and OPT_DATE_DEB_VALID for the given option.

get_opt_info(#session{prof=Prof}=Session, TOPNUM) ->
    State = svc_util_of:get_user_state(Session),
    MSISDN = Prof#profile.msisdn,
    case sdp_router:svi_c_op({svc_util_of:get_souscription(Session),MSISDN},
			     TOPNUM) of
	{ok,[OPT_DATE_SOUSCR, OPT_DATE_DEB_VALID, _, _, OPT_INFO2]} ->
	    OptInfo2_to_ms = case OPT_INFO2 of
				 [] -> 0;
				 _ ->
				     list_to_integer(OPT_INFO2)*1000
			     end,
	    KDO = case OPT_DATE_SOUSCR of
		      0 -> "0";
		      _ ->
			  "0"++integer_to_list(OPT_DATE_SOUSCR)
		  end,
	    NewState =  
		State#sdp_user_state{c_op_opt_date_souscr=KDO,
				     c_op_opt_date_deb_valid=
				     OPT_DATE_DEB_VALID,
				     c_op_opt_info2=OptInfo2_to_ms},
	    svc_util_of:update_user_state(Session,NewState);
	Error->
	    slog:event(failure,?MODULE,svi_c_op_ko,Error),
	    Session
    end.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription(session(),Opt::string(),URLs::string())->
%%                       erlpage_result().
%%%% XML API Interface to subscription.

do_subscription(plugin_info,Option,Uok,UdejaAct,Uinsuff,Unok)->
    (#plugin_info
     {help = 
      "This plugin command  send the subscription request and redirect to"
      " the page corresponding to the result of the subscription.",
      type = command,
      license = [],
      args =
      [
       {option, {oma_type, {enum, [opt_illimite_kdo
				  ]}},
	"This parameter specifies the option to subscribe."},
       {uok, {link,[]},
	"This parameter specifies the next page when the subscription to"
	" the option succeded."},
       {udejaact, {link,[]},
	"This parameter specifies the next page when the option"
	" is already activated."},
       {uinsuff, {link,[]},
	"This parameter specifies the next page when there is"
	" not enough credit on the account to subscribe to the option."
       },
       {unok, {link,[]},
       "This parameter specifies the next page in case of a"
       " technical problem"}
      ]});       
do_subscription(abs,"opt_numprefp",Uok,UdejaAct,Uinsuff,Unok) ->
   %% [Uok,Uinsuff,Unok]=string:tokens(URLs, ","),
    [{redirect,abs,Uinsuff},
     {redirect,abs,Unok},
     {redirect,abs,Uok,["DATE_FIN","NUM_PREF"]}];

do_subscription(abs,_,Uok,UdejaAct,Uinsuff,Unok) ->
    %%URL2 = string:tokens(URLs, ","),
    lists:map(fun(U) -> {redirect,abs,U} end,Uok);

do_subscription(#session{}=S,Option,Uok,UdejaAct,Uinsuff,Unok) ->
    State = svc_util_of:get_user_state(S),
    Uopt_bloquee =get_url_blocked(S),
    svc_options_mobi:do_subscription_request(S,list_to_atom(Option),Uok,UdejaAct,Uinsuff,Unok,Uopt_bloquee).


%% + type check_number(session(),Opt::string(),URLok::string(),
%%                         URLNok::string(),Number::string()) ->
%%                         erlpage_result().
%%%% Check that entered number is correct.
check_number(plugin_info,Opt,URLok,URLNok,Number)->
    (#plugin_info
     {help = 
      "This plugin command check that entered number is correct.",
      type = command,
      license = [],
      args = 
      [{opt, {oma_type, {enum, [opt_illimite_kdo,
				opt_sms_illimite
			      ]}},
       "This paramter specifies the option."},
       {urlok, {link,[]},
       "This parameter specifies the next page when the operation"
       " succeded."},
       {urlnok, {link,[]},
       "This parameter specifies the next page when the number is"
       " invalid."},
       {number,form_data,
       "This parameter specifies the number entered by the client"}
      ]});
check_number(abs,_,URLok,URLNok,_) ->
      [{redirect,abs,URLok},{redirect,abs,URLNok}];
check_number(Session,Opt,URLok,URLNok,Number)->
    svc_options_mobi:is_correct_number(Session,Opt,URLok,URLNok,Number).


%% +type do_register_refo(session(),Opt::string(),URLs::string())->
%%                   erlpage_result().
%%%% XML API Interface to register no KDO when option illimite KDO.    

do_register_refo(plugin_info,Opt,Uok,UnotOF,Unok)->
    (#plugin_info
     {help = 
      "this plugin command register no KDO when option illimite KDO",
     type=command,
     license = [],
     args = 
     [{opt, {oma_type, {enum, [opt_illimite_kdo
				]}},
	 "This paramter specifies the option."},
       {uok, {link, []},
	"This parameter specifies the next page when the operation"
	" succeded."},
       {unotof, {link, []},
	"This parameter specifies the next page when the number is"
	" invalid."},
       {unok, {link, []},
	"This parameter specifies the next page when the opearation failed."}
       ]});
do_register_refo(abs,_,Uok,UnotOF,Unok) ->
     [{redirect,abs,Uok},{redirect,abs,UnotOF},{redirect,abs,Unok}]; 
do_register_refo(Session,Opt,Uok,UnotOF,Unok) ->
    svc_options_mobi:do_register_request_refo(Session,Opt,Uok,UnotOF,Unok).


%% +type print_opt_date_souscr_refo(session())->
%%                             [{pcdata,string()}].
%%%% Print field c_op_opt_date_souscr in sdp_user_state.

print_opt_date_souscr_refo(plugin_info)->
    (#plugin_info
     {help =
      "this plugin function  Print the num KDO.",
      type=function,
      license = [],
      args =
      []});
print_opt_date_souscr_refo(abs) ->
    [{pcdata,"0612345678"}];
print_opt_date_souscr_refo(#session{prof=Prof}=Session) ->
    State = svc_util_of:get_user_state(Session),
    Msisdn=Prof#profile.msisdn,
    No_KDO = case State#sdp_user_state.c_op_opt_date_souscr of
		 [D1,D2,D3,D4,D5,D6,D7,D8,D9,D10] ->
		     [D1,D2]++" "++[D3,D4]++" "++[D5,D6]++
			 " "++[D7,D8]++" "++[D9,D10];
		 Other ->
		     slog:event(failure,?MODULE,print_opt_date_souscr,Msisdn),
		     ""
	     end,
    [{pcdata, No_KDO}].

%% +type do_unsubscription_refo(session(),Opt::string(),URLs::string())->
%%                         erlpage_result().
%%%% XML API Interface to subscription termination.

do_unsubscription_refo(plugin_info,Option,Uok,Unok)->
    (#plugin_info
     {help = 
      "This plugin command do unsubscription.",
      type=command,
      license = [],
      args = 
      [{option, {oma_type, {enum, [opt_illimite_kdo,
				   opt_sms_quoti,
				   opt_sms_mensu,
				   opt_temps_plus,
				   opt_ikdo_vx_sms,
				   opt_surf_mensu,
				   opt_mms_mensu,
				   opt_tv_renouv,
				   opt_msn_mensu_mobi
				   
				]}},
	"This parameter specifies the option to unsubscrib."},
	{uok, {link, []},
	 "This parameter specifies the next page when the operation"
	 " succeded."},
	{unok, {link, []},
	 "This parameter specifies the next page when the number is"
	 " invalid."}
	]});
do_unsubscription_refo(abs,_,Uok,Unok) ->
    [{redirect,abs,Uok},{redirect,abs,Unok}];
do_unsubscription_refo(Session,Option,Uok,Unok)->
   URLs = string:concat(Uok,","++Unok),
    case svc_util_of:get_souscription(Session) of
	mobi ->
	    svc_options_mobi:do_unsubscription_request(Session,Option,Uok,Unok);
	cmo ->
	    svc_options_cmo:do_unsubscription(Session,Option,URLs)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_state_opt_cpte_refo(session(),Opt::string(),URLs::string())->
%%                               erlpage_result().
%%%% Redirects according to the state of the option and the account state.

redirect_state_opt_cpte_refo(plugin_info,Opt,Uok,Unok)->
    (#plugin_info
     {help = 
      "This plugin command redirect according to the state of the option and"
      " the account state.",
      type=command,
      license = [],
      args = 
      [{opt, {oma_type, {enum, [opt_illimite_kdo,
				   opt_ikdo_vx_sms
				   ]}},
	"This parameter specifies the option to check."},
	{uok, {link, []},
	 "This parameter specifies the next page when the option is active."},
	{unok, {link, []},
	 "This parameter specifies the next page when the option is not active."}
	]});
redirect_state_opt_cpte_refo(abs,_,Uok,Unok)->
    [{redirect,abs,Uok},{redirect,abs,Unok}];
redirect_state_opt_cpte_refo(Session,Opt,Uok,Unok) ->
    svc_options_mobi:redirect_state_opt_cpte(Session,Opt,Uok,Unok).

%% +type print_opt_info_refo(session(),Opt::string,Info::string()) ->
%%                      [{pcdata,string()}].
%%%% Print the information defined by Info.

print_opt_info_refo(plugin_info,Opt,Type)->
    (#plugin_info
     {help = 
      "This plugin function  print the information defined by Info",
      type=function,
      license=[],
      args=
      [{opt, {oma_type, {enum, [opt_illimite_kdo,
				opt_ikdo_vx_sms,
				opt_sms_illimite
			       ]}},
	"This parameter specifies the option."},
       {type, {oma_type, {enum, [min_refill,
				 month,
				 refill_amount,
				 msisdn
			       ]}},
	"This parameter specifies the type of information."}
      ]});

print_opt_info_refo(abs,_,_) ->
    [{pcdata,"XX"}];
print_opt_info_refo(Session,Opt,Type)
when (Opt=="opt_sms_illimite") and
     (Type == "msisdn") ->
    svc_options:print_numero_sms_illimite(Session);
print_opt_info_refo(Session,Opt,Type) ->
    svc_options_mobi:print_opt_info_refo(Session,Opt,Type).

%% +type dcl_num_filter(session(),URL::string(),URL::string()) ->
%%                      erlpage_result().
%%%% Check whether the dcl_num of the session is in the m6_cmo list or not.

dcl_num_filter(plugin_info,Option,Filter,_,_) ->
    (#plugin_info
     {help=
      "This plugin checks whether the dcl_num of the session is in a list or not,"
      " the list is defined per option in config parameter: pservices_orangef::dcl_filter_options",
      type=command,
      license=[],
      args=
      [
       {opt, {oma_type, {enum, [
				opt_zap_zone
			       ]}},
	"This parameter specifies the option."},
       {filter_type, {oma_type, {enum, [
					in,
					out
				       ]}},
	"This parameter specifies the type of filter"},
       {url_in, {link, []},
	"This parameter specifies the next page when the dcl_num is found."},
       {url_out, {link, []},
	"This parameter specifies the next page when the dcl_num is not found."}
      ]
     }
    );
dcl_num_filter(abs,Option,Filter,Url_IN,Url_OUT) ->
    [{redirect,abs,Url_IN},{redirect,abs,Url_OUT}];

dcl_num_filter(Session,Option,Filter,Url_IN,Url_OUT) ->
    State = svc_util_of:get_user_state(Session),
    Dcl_Num=svc_compte:dcl(State),
    Dcl_filter=pbutil:get_env(pservices_orangef,dcl_filter_options),
    {_,{_,Dcl_Num_List}}=lists:keysearch(Option,1,Dcl_filter),
    case {Filter,lists:member(Dcl_Num,Dcl_Num_List)} of
	{"in",true} ->
	    slog:event(trace,?MODULE,dcl_num_filter,{Dcl_Num,Dcl_Num_List}),
	    {redirect,Session,Url_IN};
	{"in",false} ->
	    slog:event(trace,?MODULE,dcl_num_filter_nok,{Dcl_Num,Dcl_Num_List}),
	    {redirect,Session,Url_OUT};
	{"out",true} ->
	    slog:event(trace,?MODULE,dcl_num_filter_nok,{Dcl_Num,Dcl_Num_List}),
	    {redirect,Session,Url_OUT};
	{"out",false}->
	    slog:event(trace,?MODULE,dcl_num_filter,{Dcl_Num,Dcl_Num_List}),
	    {redirect,Session,Url_IN}
    end.


%% +type predirect_by_option_activation(session(), Subscription::string(), Option::string(),
%%                                      Url_in::string(),Url_out::string() ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
redirect_by_option_activation(plugin_info, Subscription, Option, Url_in, Url_out) ->
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on the option is commercially laucnhed or not.",
      type=command,
      license=[],
      args=
      [
       {subscription, {oma_type, {enum, [mobi, cmo, postpaid]}},
        "This parameter specifies the subscription."},
       {opt, {oma_type, {enum, [spider_no_resp,refill_game,plan_zap]}},
	"This parameter specifies the option."},
       {url_in, {link, []},
	"This parameter specifies the page when the option is launched"},
       {url_out, {link, []},
	"This parameter specifies the page when the option is not launched"}
      ]
     }
    );

redirect_by_option_activation(abs, Subscription, Option, Url_in, Url_out) ->
     [{redirect,abs,Url_in},{redirect,abs,Url_out}];

redirect_by_option_activation(Session, Subscription, Option="spider_no_resp" , Url_in, Url_out)->
    case pbutil:get_env(pservices_orangef,mobi_menu_without_spider) of
	true ->{redirect,Session,Url_in};
	_ ->   {redirect,Session,Url_out}
    end;

redirect_by_option_activation(Session, Subscription, Option, Url_in, Url_out)->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) of
	true ->{redirect,Session,Url_in};
	_ ->   {redirect,Session,Url_out}
    end.

%% +type redirect_by_option_if_subscribed(session(), 
%%                                        Subscription::string(), 
%%                                        Option::string(),
%%                                        UrlSubscribed::string(),
%%                                        UrlNotSubscribed::string() ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is already subscribed
redirect_by_option_if_subscribed(plugin_info, Subscription, Option, 
				 UrlSubscribed, UrlNotSubscribed) ->
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on whether the option is "
      "already subscribed or not.",
      type=command,
      license=[],
      args=
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {opt, {oma_type, {enum, [opt_zap_vacances, opt_11_18]}},
	"This parameter specifies the option."},
       {subscribed, {link, []},
	"This parameter specifies the page when the option is subscribed"},
       {not_subscribed, {link, []},
	"This parameter specifies the page when the option is not subscribed"}
      ]
     }
    );

redirect_by_option_if_subscribed(abs, Subscription, Option, 
				 UrlSubscribed, UrlNotSubscribed) ->
     [{redirect,abs,UrlSubscribed},{redirect,abs,UrlNotSubscribed}];

redirect_by_option_if_subscribed(Session, Subscription, Option, 
				 UrlSubscribed, UrlNotSubscribed)
when Option=="opt_11_18" ->
    Opt=list_to_atom(Option),    
    State = svc_util_of:get_user_state(Session),
    case svc_subscr_asmetier:is_option_activated(Session, Opt,State) of
	true ->
	    {redirect,Session,UrlSubscribed};
	_ ->
	    {redirect,Session,UrlNotSubscribed}
    end;

redirect_by_option_if_subscribed(Session, Subscription, Option, 
				 UrlSubscribed, UrlNotSubscribed) ->
    Opt=list_to_atom(Option),    
    case svc_options:is_option_activated(Session, Opt) of
	     true ->{redirect,Session,UrlSubscribed};
	_ ->   {redirect,Session,UrlNotSubscribed}
    end.


%% +type redirect_by_declinaison(session(), Plateform,
%%                                      Url_mobicarte::string(),Url_click::string(),Url_foot::string(),Url_M6::string() ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
redirect_by_declinaison(plugin_info, Platform, Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample) ->
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on the declinaison give by the selected platform",
      type=command,
      license=[],
      args=
      [
       {platform, {oma_type, {enum, [spider, sachem]}},
        "This parameter specifies the selected platform to get the declinaison."},
       {url_mobicarte, {link, []},
	"This parameter specifies the page when the declinaison is mobicarte"},
       {url_click, {link, []},
	"This parameter specifies the page when the declinaison is click mobicarte"},
       {url_foot, {link, []},
	"This parameter specifies the page when the declinaison is foot mobicarte"},
       {url_M6, {link, []},
	"This parameter specifies the page when the declinaison is m6 mobicarte"},
       {url_Umobile, {link, []},
	"This parameter specifies the page when the declinaison is U mobile mobicarte"},
       {url_M6sample, {link, []},
	"This parameter specifies the page when the declinaison is M6 sample"}
      ]
     }
    );
redirect_by_declinaison(abs, Platform, Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample) ->
     [{redirect,abs,Url_mobicarte},
      {redirect,abs,Url_click},
      {redirect,abs,Url_foot},
      {redirect,abs,Url_M6},
      {redirect,abs,Url_Umobile},
      {redirect,abs,Url_M6sample}];

redirect_by_declinaison(Session, "spider", Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample) ->
    Module = svc_spider,
    Function = redirect_by_produit,
    redirect_by_declinaison(Session, Module, Function, spider, "?", Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample);
redirect_by_declinaison(Session, "sachem", Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample) ->
    Module = svc_util_of,
    Function = redir_declinaison,
    redirect_by_declinaison(Session, Module, Function, sachem, "default", Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample).
    
redirect_by_declinaison(Session, Module, Function, Platform, Espace_car, Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample) ->
    Redirect_mobicarte= pbutil:get_env(pservices_orangef,redirect_mobicarte),
    {value, {Platform, List}} = lists:keysearch(Platform, 1, Redirect_mobicarte),
    Link = 
	lists:append([create_link(Parameter, Declinaison, Url_mobicarte, Url_click, Url_foot, Url_M6, Url_Umobile,Url_M6sample) 
		      || {Parameter, Declinaison} <- List]) ++ 
	Espace_car++"="++Url_mobicarte,
    Module:Function(Session,Link).

create_link(Parameter, mobicarte, Url_mobicarte, _, _, _,_,_)->
    Parameter ++ "=" ++ Url_mobicarte ++ ",";
create_link(Parameter, click, _, Url_click, _, _,_,_) ->
    Parameter ++ "=" ++ Url_click ++ ",";
create_link(Parameter, foot, _, _, Url_foot, _,_,_)->
    Parameter ++ "=" ++ Url_foot ++ ",";
create_link(Parameter, m6, _, _, _, Url_M6,_,_) ->
    Parameter ++ "=" ++ Url_M6 ++ ",";
create_link(Parameter, umobile, _, _, _,_, Url_Umobile,_) ->
    Parameter ++ "=" ++ Url_Umobile ++ ",";
create_link(Parameter, m6sample,_,_,_,_,_,Url_M6sample) ->
    Parameter ++ "=" ++ Url_M6sample ++ ",".

%% +type sachem_consultation(session(), Url_ok::string(),Url_nok::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
sachem_consultation(plugin_info, Url_ok) ->
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on the declinaison giove by the selected platform",
      type=command,
      license=[],
      args=
      [
       {url_ok, {link, []},
	"This parameter specifies the page when the sachem consultation is OK"}
      ]
     }
    );
sachem_consultation(abs, Url_ok) ->
     [{redirect,abs,Url_ok}];

sachem_consultation(Session, Url_ok) ->
    Url_nok="file:/orangef/selfcare_long/sachem.xml",
    svc_util_of:consultation_sachem(Session, Url_ok, Url_nok).

%% +type sachem_consultation(session(), Url_ok::string(),Url_nok::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
sachem_consultation(plugin_info, Url_ok, Url_nok) ->
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on the declinaison giove by the selected platform",
      type=command,
      license=[],
      args=
      [
       {url_ok, {link, []},
	"This parameter specifies the page when the sachem consultation is OK"},
       {url_nok, {link, []},
	"This parameter specifies the page when the sachem consultation is NOK"}
      ]
     }
    );
sachem_consultation(abs, Url_ok, Url_nok) ->
     [{redirect,abs,Url_ok},
      {redirect,abs,Url_nok}];

sachem_consultation(Session, Url_ok, Url_nok) ->
    svc_util_of:consultation_sachem(Session, Url_ok, Url_nok).

option_en_promo(plugin_info, Url_generique, Url_promo) ->
(#plugin_info
 {help=
      "This plugin redirect to the page depending on the activation of a promotion",
      type=command,
      license=[],
      args=
      [
       {url_generique, {link, []},
	"This parameter specifies the page when the promotion is not active"},
       {url_promo, {link, []},
	"This parameter specifies the page when the promotion is active"}
      ]
     }
)
	;
option_en_promo(abs, Url_generique, Url_promo) ->
    [{redirect,abs,Url_generique},
      {redirect,abs,Url_promo}];

option_en_promo(Session, Url_generique, Url_promo)->
    State = svc_util_of:get_user_state(Session),
    Service=variable:get_value(Session, {"bons_plans","option"}),
    Option=list_to_atom(Service),
    
    {_,_,Solde} = case svc_compte:cpte(State, cpte_bons_plans) of
		 #compte{}=Compte->
		     Compte#compte.cpp_solde;
		 _->
		     {sum, euro, 0}
	     end,
    Opt_price = svc_util_of:subscription_price(Session, Option),
    case Solde > Opt_price of
	true -> 
	    case svc_util_of:is_promotion(Session,mobi,Option) of
		true->
		    {redirect,Session,Url_promo};
		_ ->
		    {redirect,Session,Url_generique}
	    end;
	_ ->
	    {redirect,Session,Url_generique}
    end.

service_to_option("journee_infinie_jeu") ->
    opt_jinf;
service_to_option("soiree_infinie_jeu") ->
    opt_sinf;
service_to_option("duo_journee_jeu") -> 
	opt_pack_duo_journee;
service_to_option("opt_ssms_illimite_jeu") ->
    opt_ssms_illimite;
service_to_option("opt_jsms_illimite_jeu") ->
    opt_jsms_illimite;

service_to_option("soiree_sms_m6")->
    opt_ssms_m6;
service_to_option("opt_sms_quoti") ->
    opt_sms_quoti;
service_to_option("opt_sms_mensu") ->
    opt_sms_mensu;
service_to_option("opt_ssms") ->
    opt_ssms;
service_to_option("opt_zap_quoti") ->
    opt_zap_quoti;
service_to_option("opt_sms_illimite") ->
    opt_sms_illimite;
service_to_option("opt_mms_mensu") ->
    opt_mms_mensu;
service_to_option("opt_msn_mensu_mobi") ->
    opt_msn_mensu_mobi;
service_to_option("opt_msn_journee_mobi") ->
    opt_msn_journee_mobi;
service_to_option("opt_ssms_illimite") ->
    opt_ssms_illimite;
service_to_option("opt_jsms_illimite") ->
    opt_jsms_illimite;
service_to_option("opt_bordeaux") ->
    opt_bordeaux;
service_to_option("opt_lens") ->
    opt_lens;
service_to_option("opt_lyon") ->
    opt_lyon;
service_to_option("opt_marseille") ->
    opt_marseille;
service_to_option("opt_paris") ->
    opt_paris;
service_to_option("opt_saint_etienne") ->
    opt_saint_etienne;
service_to_option("opt_30_sms_mms")->
    opt_30_sms_mms;
service_to_option("opt_avan_dec_zap_zone")->
    opt_avan_dec_zap_zone;
service_to_option(not_found) ->
    exit({plugin,?MODULE,incl_variable_not_found,{"bons_plans","option"}});
service_to_option(Service) ->
    list_to_atom(Service).

opt_foot_name("opt_bordeaux") ->
    "Girondins";
opt_foot_name("opt_lens") ->
    "RCL";
opt_foot_name("opt_lyon") ->
    "OL";
opt_foot_name("opt_marseille") ->
    "OM";
opt_foot_name("opt_paris") ->
    "PSG";
opt_foot_name("opt_saint_etienne") ->
    "ASSE".

%% +type redirect_by_option_state(session(), Subscription::string(), Option::string(),
%%                                      Url_not_actived::string(),Url_actived::string(),Url_suspend::string() ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is launched
redirect_by_option_state(plugin_info, Url_not_actived, Url_actived, Url_suspend) ->
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on the option state.",
      type=command,
      license=[],
      args=
      [
       {url_not_actived, {link, []},
	"This parameter specifies the page when the option is not actived"},
       {url_actived, {link, []},
	"This parameter specifies the page when the option is actived"},
       {url_suspend, {link, []},
	"This parameter specifies the page when the option is suspend"}
      ]
     }
    ); 

redirect_by_option_state(abs, Url_not_actived, Url_actived, Url_suspend) ->
     [{redirect,abs,Url_not_actived},{redirect,abs,Url_actived},{redirect,abs,Url_suspend}];

redirect_by_option_state(Session, Url_not_actived, Url_actived, Url_suspend) ->
    Service=variable:get_value(Session, {"bons_plans","option"}),
    Opt=service_to_option(Service),
    case svc_options:state(Session,Opt) of
	not_actived -> 
	    {redirect,Session,Url_not_actived};
	actived     -> {redirect,Session,Url_actived};
	suspend     -> {redirect,Session,Url_suspend}
    end.

%% +type redir_by_opt_visio_status(session(),
%%                           UAct::string(),UGene::string()) ->
%%                           erlpage_result().
redir_by_opt_visio_status(plugin_info,UActive,UGeneric,UError) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the \"visio\" option state.",
      type=command,
      license=[],
      args=
      [
       {url_actived, {link, []},
	"This parameter specifies the page when the option is activated"},
       {url_generic, {link, []},
	"This parameter specifies the page when the option is not activated"},
       {url_error, {link, []},
	"This parameter specifies the page when the request t oocf rdp failed"}
      ]
     }
    ); 
redir_by_opt_visio_status(abs,UActive,UGeneric,UError) ->
    [{redirect,abs,UActive},{redirect,abs,UGeneric},{redirect,abs,UError}];

redir_by_opt_visio_status(Session, UActive, UGeneric,UError) ->
    case get_profile(Session) of
	{nok, Session1} -> {redirect, Session1, UError};
	{ok,  Session2} ->
	    State = svc_util_of:get_user_state(Session2),
	    CodeOpt =  pbutil:get_env(pservices_orangef,code_act_visio),
	    case lists:keysearch(CodeOpt,
				 2,
				 (State#sdp_user_state.opt_activ)#activ_opt_mobi.list
				) of
		{value,E}->
		    {redirect, Session2, UActive};
		false ->
		    {redirect, Session2, UGeneric}
	    end
    end.

get_profile(#session{prof=Prof}=Session)->
    State = svc_util_of:get_user_state(Session),
    case catch ocf_rdp:getOptionalServicesByMsisdn(Prof#profile.msisdn) of
	{ok, List} when list(List)->
	    State1=State#sdp_user_state{opt_activ=#activ_opt_mobi{list=List}},
	    Session1 = svc_util_of:update_user_state(Session,State1),
	    {ok, Session1};
	E ->
	    slog:event(warning,?MODULE,getOptionalServicesByMsisdn_failed,E),
	    {nok, Session}
    end.

%% +type redirect_by_option_state(session(), TCP_NUM::string(), Solde::string(),
%%                                      Url_less::string(),Url_more::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
redirect_by_compte_solde(plugin_info, Tcp_num, Solde, Url_less, Url_more) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the option state.",
      type=command,
      license=[],
      args=
      [
       {tcp_num, {oma_type, {enum, [cpte_m6_soiree_sms, 
                                    cpte_bons_plans_jeu]}},
        "This parameter specifies the account to check."},
       {solde, {oma_type, {enum, [2000,2500,3000]}},
        "This parameter specifies the value to check."},
       {url_less, {link, []},
	"This parameter specifies the page when the account has less than the value to check"},
       {url_more, {link, []},
	"This parameter specifies the page when the account has more than the value to check"}
      ]
     }
    );

redirect_by_compte_solde(abs, Tcp_num, Solde, Url_less, Url_more) ->
     [{redirect,abs,Url_less},{redirect,abs,Url_more}];

redirect_by_compte_solde(Session, "cpte_m6_soiree_sms", Solde, Url_less, Url_more) ->
    State = svc_util_of:get_user_state(Session),
    Curr={sum,euro,list_to_integer(Solde)},
    SoldeCpte = svc_compte:solde_cpte(State, cpte_m6_soiree_sms),
    case currency:is_inf(Curr,SoldeCpte) of
	true -> {redirect,Session,Url_more};
	_ ->    {redirect,Session,Url_less}
    end;
	
redirect_by_compte_solde(Session, "cpte_bons_plans_jeu", Solde, Url_less, Url_more) ->
    State = svc_util_of:get_user_state(Session),
    Curr={sum,euro,list_to_integer(Solde)},
    SoldeCpte = svc_compte:solde_cpte(State, cpte_bons_plans_jeu),
    case currency:is_infeq(Curr,SoldeCpte) of
	true -> {redirect,Session,Url_more};
	_ ->    {redirect,Session,Url_less}
    end;

redirect_by_compte_solde(Session, Compte, _ , Url_ep, Url_ac) ->
    State = svc_util_of:get_user_state(Session),
    Cpte=list_to_atom(Compte),    
    case svc_compte:etat_cpte(State,Cpte) of
       ?CETAT_AC -> {redirect,Session,Url_ac};
        _ 	 -> {redirect,Session,Url_ep}
    end.

%% +type redirect_by_option_state(session(), Url_identified::string(),Url_not_identified::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
redirect_by_identification(plugin_info, Url_identified, Url_not_identified) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the option state.",
      type=command,
      license=[],
      args=
      [
       {url_identified, {link, []},
	"This parameter specifies the page when the client is identified"},
       {url_not_identified, {link, []},
	"This parameter specifies the page when the client is not identified"}
      ]
     }
    );

redirect_by_identification(abs, Url_identified, Url_not_identified)->
     [{redirect,abs,Url_identified},{redirect,abs,Url_not_identified}];

redirect_by_identification(Session, Url_identified, Url_not_identified)->
    Links = "ident="++Url_identified++",default="++Url_not_identified,
    svc_util_of:redirect_etat_cpte_second(Session, Links).

%% +type redirect_by_option_state(session(), Url_day_off::string(),Url_not_day_off::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the option is laucnched
redirect_by_bank_holiday(plugin_info, Option, Url_bank_holiday, Url_not_bank_holiday) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the option state.",
      type=command,
      license=[],
      args=
      [
       {option, {oma_type, {defval,"",string}},
	"This parameter specifies the option"},
       {url_bank_holiday, {link, []},
	"This parameter specifies the page when the day is bank holiday"},
       {url_not_bank_holiday, {link, []},
	"This parameter specifies the page when the day is not bank holiday"}
      ]
     }
    );

redirect_by_bank_holiday(abs, Option, Url_bank_holiday, Url_not_bank_holiday) ->
     [{redirect,abs,Url_bank_holiday},{redirect,abs,Url_not_bank_holiday}];

redirect_by_bank_holiday(Session, Option, Url_bank_holiday, Url_not_bank_holiday) ->
    Opt=list_to_atom(Option),
    case svc_util_of:is_bank_holiday(Opt) of
	true -> {redirect, Session, Url_bank_holiday};
	false -> {redirect, Session, Url_not_bank_holiday}
    end.	    

%% +type redirect_by_tac(session(), Subscription::string(), Url::string(),Url_default::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page whether if the handet is UNIK handset
redirect_by_tac(plugin_info, Subscription, Url, Url_default) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the option dlv.",
      type=command,
      license=[],
      args=
      [
       {subscription, {oma_type, {enum, [cmo,postpaid]}},
	"This parameter specifies the option."},
       {url, {link, []},
	"This parameter specifies the page when the handset is Unik handset"},
       {url_default, {link, []},
	"This parameter specifies the page when the handset is not Unik handset"}
      ]
     }
    );

redirect_by_tac(abs,_, Url, Url_default)->
    [{redirect,abs,Url},{redirect,abs,Url_default}];

redirect_by_tac(Session, Subscription, Url, Url_default)
when Subscription=="cmo" ->
    Tac_list = pbutil:get_env(pservices_orangef,tac_list),
    Imei = plugin:get_attrib(Session,"imei"),
    case Imei of
        ""->
	    {redirect,Session,Url_default};
	_ ->
	    svc_util_of:check_imei(Session,Imei,Tac_list,Url,Url_default)
    end;

redirect_by_tac(Session, Subscription, Url, Url_default)
when Subscription=="postpaid" ->
    Tac_list = pbutil:get_env(pservices_orangef,tac_list_postpaid),
    Imei = plugin:get_attrib(Session,"imei"),
    case Imei of
        ""->
	    {redirect,Session,Url_default};
	_ ->
	    svc_util_of:check_imei(Session,Imei,Tac_list,Url,Url_default)
    end.
   

%% +type unsubscribe(session(), USuccess::string(),UFailure::string() ->
%%                      erlpage_result().
%%%% Redirects session following success or failure of deactivate option request
unsubscribe(plugin_info, USuccess, UFailure) ->
    (#plugin_info
     {help =
      "This plugin command sends the terminate option request, and redirects to"
      " success page or failure page following the result of the attempt.\n"
      "Searches for subscription and option values in the session variables.",
      type = command,
      license = [],
      args =
      [
       {usuccess, {link,[]},
	"This parameter specifies the next page when the option"
	" has been successfully deactivated."},
       {ufailure, {link,[]},
	"This parameter specifies the next page when the attempt to"
	" deactivate has failed"}
      ]});
unsubscribe(abs, USuccess, UFailure) ->
    [{redirect,abs,USuccess},
     {redirect,abs,UFailure}
    ];

unsubscribe(Session, USuccess, UFailure) ->
    Service=variable:get_value(Session, {"bons_plans","option"}),
    Opt=list_to_atom(Service),
    svc_options_mobi:do_unsubscription_request(Session,Opt,USuccess,UFailure).

%% +type activate_visio(session(), USuccess::string(),UFailure::string() ->
%%                      erlpage_result().
%%%% Redirects session following success or failure of activate visio option request
activate_visio(plugin_info, USuccess, UFailure) ->
    (#plugin_info
     {help =
      "This plugin command sends the \"visio\" option activate request, and redirects to"
      " success page or failure page following the result of the attempt.",
      type = command,
      license = [],
      args =
      [
       {usuccess, {link,[]},
	"This parameter specifies the next page when the option"
	" has been successfully activated."},
       {ufailure, {link,[]},
	"This parameter specifies the next page when the attempt to"
	" activate has failed"}
      ]});
activate_visio(abs, USuccess, UFailure) ->
    [{redirect,abs,USuccess},
     {redirect,abs,UFailure}
    ];

activate_visio(#session{prof=Prof}=Session, USuccess, UFailure) ->
    State = svc_util_of:get_user_state(Session),
    case catch ajout(Prof#profile.msisdn,State,opt_visio) of
	ok->
	    slog:event(count,?MODULE,{souscription,opt_visio}),
	    %OPT_MOBI=State#sdp_user_state.opt_activ,
	    %OPT_MOBI_en_cours=OPT_MOBI#activ_opt_mobi{en_cours=opt_visio},
	    {redirect,update_session_visio(Session,#activ_opt_mobi{en_cours=opt_visio}),USuccess};
	E->
	    slog:event(failure,?MODULE,rdp_option_souscription_ko,E),
	    {redirect,Session,UFailure}
    end.

%% +type ajout(Msisdn::string(),sdp_user_state(),opt_act_mobi())-> ok | term.
ajout(Msisdn,State,Opt) ->
    OPT_EVENT=#opt_event{msisdn=Msisdn,
			 cso=pbutil:get_env(pservices_orangef,code_opt_visio),
			 or_pos='AJTSO'},
    rdp_options_router:event(OPT_EVENT,[]).

%% +type update_session(session(),activ_opt_mobi())-> session().
update_session_visio(Session,OPT_MOBI)->
    State = svc_util_of:get_user_state(Session),
    State1 = State#sdp_user_state{opt_activ=OPT_MOBI},
    svc_util_of:update_user_state(Session,State1).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

repeat(0,_)->
    [];
repeat(Number,Str)->
    Str++repeat(Number-1,Str).

write_to_file(plugin_info, Variable, Uok, Unok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether the MSISDN,and IMSI of the user are written in specified file",
      type = command,
      license = [],
      args =
      [
       {variable, {oma_type, {defval,"",string}},
	"This parameter specifies the config variable."},
       {uok, {link,[]},
	"This parameter specifies the ok link."},
       {unok, {link,[]},
	"This parameter specifies the not ok link"}
      ]});

write_to_file(abs,_, Uok,Unok) ->
    [{redirect,abs,Uok},
     {redirect,abs,Unok}
    ];

write_to_file(#session{prof=Prof}=Session, Variable, Uok, Unok)
when Variable=="janus"->
    Config="janus_files_location",
    Filepath=pbutil:get_env(pservices_orangef,list_to_atom(Config)),
    {Y,M,D}=date(),
    Filename="Dossier_Ot_Janus123_"++lists:flatten(pbutil:sprintf("%02d%02d%02d", [D,M,Y-2000]))++".txt",
    Field1="JANUS123",
    Field2=svc_util_of:int_to_nat(Prof#profile.msisdn),
    Field3="000",
    Field4="CPJAN",
    Field5="I",
    Field6=repeat(76,";"),
    Msg=io_lib:format("~s;~s;~s;~s;~s~s~n",[Field1,Field2,Field3,Field4,Field5,Field6]),
    case file:open(Filepath++Filename,[append]) of
	{ok, FD}-> case file:write(FD,Msg) of
		       ok-> file:close(FD),
			    {Session1,State} = svc_options:check_topnumlist(Session),
			    case check_and_maj_opt_terminate(Session1,[opt_illimite_kdo,
								       opt_ikdo_vx_sms,
								       opt_illimite_kdo_v2,
								       opt_ikdo_sms,
								       opt_dte_plus]) of 
				{ok, NSession} -> 				    
				    {redirect,NSession,Uok};
				{Else, _} -> 
				    slog:event(failure,?MODULE,error_to_delete_option,Else),
				    {redirect,Session1, Unok}
			    end;
		       _ -> slog:event(internal,?MODULE,unable_to_write_janus_file),
			    {redirect,Session, Unok}
		   end;
	_  -> slog:event(internal,?MODULE,unable_to_open_janus_file),
	      {redirect,Session,Unok}
    end.


%% +type get_url_blocked (session()) ->
%%                      atom().
%%%% Get the page to siplayed when error 101 is return by Sachem. (option blocked for user)
get_url_blocked(S)->
    State = svc_util_of:get_user_state(S),
    Uopt_bloquee =
	case State#sdp_user_state.declinaison of
	    ?RC_LENS_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?ASSE_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?OL_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?OM_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?CLUB_FOOT->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?PSG_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?BORDEAUX_mobile->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_foot);
	    ?DCLNUM_ADFUNDED->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_m6);
	    ?m6_prepaid ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_m6);
	    ?click_mobi ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee_click);
	    _ ->
		pbutil:get_env(pservices_orangef,url_opt_bloquee)
	end.

%% +type resilier_option(session(), Subscription::string(), Option::string(),
%%                                      Url_ok::string(),Url_nok::string() ->
%%                      erlpage_result().
%%%% Redirect to the page whether the option is terminated
resilier_option(#session{prof=#profile{subscription=Sub}}=Session, URLs) ->
    [Uok,Unok]=string:tokens(URLs, ","),
    Code_opt=case Sub of
		 "postpaid" ->
		     variable:get_value(Session,{resiliation_postpaid,"code_option"});
		 _ ->
		     variable:get_value(Session,{resiliation_cmo,"code_option"})
	     end,
    ListOptions=case Sub of
                    "postpaid" ->
                        pbutil:get_env(pservices_orangef,asmetier_opt_postpaid);
                    _ ->
                        pbutil:get_env(pservices_orangef,asmetier_opt_cmo)
                end,
    Option=search_option_resil(Code_opt,ListOptions),
    case Code_opt of
	X when ((X==undefined) or (X==[]))->
	    {redirect, Session, Unok};
	_->
	    case svc_subscr_asmetier:set_ServiceOptionnel(Session, Code_opt,"false",Option) of
		{ok,NewSess} -> 
		    {redirect, NewSess, Uok};
		_ ->
		    {redirect, Session, Unok}
	    end
    end.
check_enough_credit(State,_,[]) -> false;    
check_enough_credit(State,Curr,[{Cpte,_}|Tail]) ->
    IsCreditSuff = currency:is_infeq(Curr,svc_compte:solde_cpte(State,Cpte)),
    case {svc_compte:etat_cpte(State,Cpte),IsCreditSuff} of
        {?CETAT_AC,true} ->
            true;
        _ ->
            check_enough_credit(State,Curr,Tail)
    end.

search_service(Ussd_code,[])->[];
search_service(Ussd_code,[{Ussd_code1,Sub_list}|Tail])->
    case Ussd_code1 of
	Ussd_code->
	    Sub_list;
	_ ->search_service(Ussd_code,Tail)
    end.

check_right_access_to_services(plugin_info, URLs) ->
    (#plugin_info
     {help=
      "This plugin checks right access to service, depending on ussd code and subscription.",
      type=command,
      license=[],
      args=
      [
       {urls, {oma_type, {defval,"",string}},
        "This parameter specifies two urls: url_ok and url_nok, which are seperated by comma"}
      ]
     }
    );

check_right_access_to_services(abs,URLs) ->
    [Uok,Unok]=string:tokens(URLs, ","),
     [{redirect, abs, Uok},
      {redirect, abs, Unok}];

check_right_access_to_services(#session{location=L}=Session,URLs)->
    Ussd_code=plugin:get_attrib(Session,"ussd_code"),
    State = svc_util_of:get_user_state_simple(Session),
    Declinaison = case is_record(State, sdp_user_state) of
		      true ->
			  State#sdp_user_state.declinaison;
		      _ ->
			  undefined
		  end,
    [Uok, Unok] = string:tokens(URLs, ","),
    case Declinaison of
	80 ->
	    {redirect,Session,Unok};
	115->
	    case lists:keysearch(roaming_network, 1, L) of 
		{value, {_,Smth}} ->
		    case Smth of
			noroaming->
			    redirect_by_access_service(Session,Uok,Unok,"#not_allowed_leogourou","#not_allowed_mvno");
			_->
			    {redirect,Session,Unok}
		    end;
		_ ->
		    {redirect,Session,Unok}
	    end;
	_ ->
	    DCLs_internet_everywhere = pbutil:get_env(pservices_orangef,dcl_internet_everywhere),
	    case lists:member(Declinaison,DCLs_internet_everywhere) of 
		true -> 
		    {redirect,Session,"#not_allowed_internet_everywhere"};
		_ ->
		    redirect_by_access_service(Session,Uok,Unok,"#not_allowed_leogourou","#not_allowed_mvno")
	    end
    end.

redirect_by_access_service(Session,Uok,Unok,Unok_leogourou,Unok_mvno) ->    
    Ussd_code=plugin:get_attrib(Session,"ussd_code"),
    Access_services=pbutil:get_env(pservices_orangef,access_services),
    Sub_list=search_service(Ussd_code,Access_services),
    case lists:member(all_and_anon,Sub_list) of
	true -> {redirect,Session,Uok};
	_ ->
	    Sub=svc_util_of:get_souscription(Session),
	    case lists:member(Sub,Sub_list) of
		true-> 
		    {redirect,Session,Uok};
		_->
		    case Sub of
			Sub_new when Sub_new==leo_gourou ->
			    {redirect,Session,Unok_leogourou};
			_ ->
			    Subs_mvno = pbutil:get_env(pservices_orangef,subscription_mvno),
			    case lists:member(Sub,Subs_mvno) of 
				true -> 
				    {redirect,Session,Unok_mvno};
				_ ->					    
				    {redirect,Session,Unok}
			    end
		    end
	    end
    end.

redirect_by_bonus(plugin_info, Option, Url_decouvrir, Url_choisir, Url_choisir_promo, Url_changer) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the bonus type.",
      type=function,
      license=[],
      args=
      [
       {option, {oma_type, {defval,"",string}},
	"This parameter specifies the option"},
       {url_decouvrir, {link, []},
	"This parameter specifies the page when client is not Janus"},
       {url_choisir, {link, []},
        "This parameter specifies the page when client is Janus and didn't choose bonus"},
       {url_choisir_promo, {link, []},
        "This parameter specifies the page choisir Janus promo"},
       {url_changer, {link, []},
	"This parameter specifies the page when client is Janus and chose bonus already"}
      ]
     }
    );

redirect_by_bonus(abs, Option, Url_decouvrir, Url_choisir, Url_choisir_promo, Url_changer) ->
     [{redirect,abs,Url_decouvrir},
      {redirect,abs,Url_choisir},
      {redirect,abs,Url_choisir_promo},
      {redirect,abs,Url_changer}];

redirect_by_bonus(Session,Option, Url_decouvrir, Url_choisir, Url_choisir_promo, Url_changer) ->
    Opt=list_to_atom(Option),
    {_,Session_init}= svc_util_of:reinit_compte(Session),
    {Session1,State}=svc_options:check_topnumlist(Session_init),
    DCL = State#sdp_user_state.declinaison,
    slog:event(trace,?MODULE,dcl,DCL),
    case DCL of
        ?mobi_janus  ->
            case svc_options:is_option_activated(Session1,Opt) of
                true ->
                    display_link(Session1,[],"changer bonus",Url_changer);
                _ ->
		    case svc_util_of:is_commercially_launched(Session1,mobi_janus_promo) of
			true->
			    DateActive = svc_util_of:unixtime_to_local_time(State#sdp_user_state.d_activ),
			    case svc_util_of:get_commercial_date(mobi,user_janus_promo) of
				[{Begin,End}]->
				    case (Begin < DateActive) and (DateActive < End) of
					true->
					    display_link(Session1,[],"choisir bonus promo",Url_choisir_promo);
					_->
					    slog:event(trace, ?MODULE, janus_promo, not_promo),
					    display_link(Session1,[],"choisir Bonus",Url_choisir)
				    end;
				_->
				    slog:event(internal,?MODULE,user_janus_promo,commercial_date_not_found),
				    display_link(Session1,[],"choisir Bonus",Url_choisir)
			    end;
			_->
			    display_link(Session1,[],"choisir Bonus",Url_choisir)
		    end
	    end;
	DCL_ when DCL_==?mobi;
		  DCL_==?cpdeg;
		  DCL_==?mobi_new;
		  DCL_==?B_phone ->
	    {redirect, Session1,Url_decouvrir};		 
	_ ->
	    []
    end.

%% +type redirect_nouv_gerer_bonus/5(session(),
%%                           Url_decouvrir::string(),
%%                           Url_choisir::string(),
%%                           Url_changer::string()) 
%%                           Url_error::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page depend on bonus type
redirect_nouv_gerer_bonus(plugin_info, Option, Url_decouvrir, Url_choisir, Url_changer, Url_error) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the bonus type.",
      type=function,
      license=[],
      args=
      [
       {option, {oma_type, {defval,"",string}},
        "This parameter specifies the option"},
       {url_decouvrir, {link, []},
        "This parameter specifies the page when client is not Janus"},
       {url_choisir, {link, []},
        "This parameter specifies the page when client is Janus and didn't choose bonus"},
       {url_changer, {link, []},
        "This parameter specifies the page when client is Janus and chose bonus already"}
      ]
     }
    );

redirect_nouv_gerer_bonus(abs, Option, Url_decouvrir, Url_choisir, Url_changer, Url_error) ->
     [{redirect,abs,Url_decouvrir},
      {redirect,abs,Url_choisir},
      {redirect,abs,Url_changer},
      {redirect,abs,Url_error}];

redirect_nouv_gerer_bonus(Session, Option, Url_decouvrir, Url_choisir, Url_changer, Url_error) ->
    Opt=list_to_atom(Option),
    {Session1,State}=svc_options:check_topnumlist(Session),
    DCL = State#sdp_user_state.declinaison,
    slog:event(trace,?MODULE,dcl,DCL),
        case DCL of
	    ?mobi_janus  ->
		case svc_options:is_option_activated(Session1,Opt) of
		    true ->
			{redirect, Session1, Url_changer};
		    _ -> 
			{redirect, Session1, Url_choisir}
		end;
	    DCL_ when DCL_==?mobi;
		      DCL_==?cpdeg;
		      DCL_==?mobi_new;
		      DCL_==?B_phone ->
		case svc_options:is_option_activated(Session1,opt_ikdo) of
		    false ->
			{redirect, Session1, Url_decouvrir};
		    _ ->
			{redirect, Session1, Url_error}
		end;
	    _ ->
		{redirect, Session1, Url_error}
	end.
    
%% +type redirect_by_suiviconso/4(session(), 
%%                                Option::string(), 
%%                                Url_mobi_janus_perso::string(),
%%                                Url_mobi_janus_sans_perso::string()) ->
%%                      erlpage_result().
%%%% Redirect to the page depend on bonus type
redirect_by_suiviconso(plugin_info, Option,  Url_mobi_janus_perso, Url_mobi_janus_sans_perso) ->
   (#plugin_info
     {help=
      "This plugin redirect to the page depending on the bonus type.",
      type=command,
      license=[],
      args=
      [
       {option, {oma_type, {defval,"",string}},
	"This parameter specifies the option"},
       {url_mobi_janus_perso, {link, []},
        "This parameter specifies the page when client is Janus with avantage personalisation"},
       {url_mobi_janus_sans_perso, {link, []},
        "This parameter specifies the page when client is Janus without avantage personalisation"}
      ]
     }
    );

redirect_by_suiviconso(abs, _, Url_mobi_janus_perso, Url_mobi_janus_sans_perso) ->
     [{redirect,abs,Url_mobi_janus_perso},
      {redirect,abs,Url_mobi_janus_sans_perso}];

redirect_by_suiviconso(Session, Option,  Url_mobi_janus_perso, Url_mobi_janus_sans_perso) ->
    Opt=list_to_atom(Option),
    {Session1,State}=svc_options:check_topnumlist(Session),
    DCL = State#sdp_user_state.declinaison,
    case DCL of
        ?mobi_janus  ->
            case svc_options:is_option_activated(Session1,Opt) of
                true ->
		    {redirect,Session,Url_mobi_janus_perso};
                _ ->
		    {redirect,Session,Url_mobi_janus_sans_perso}
            end;
        _ ->
	    {redirect,Session,Url_mobi_janus_sans_perso}
    end.
%% +type redirect_by_plan_tarifaire(session(),Subscription:string() ->
%%                        Url_ok:string(), Url_default:string()}.
redirect_by_plan_tarifaire(plugin_info, Subscription, Url_ok, Url_default) ->    
    (#plugin_info
     {help=
      "This plugin redirect to the page depending on the tariff plan of the main account.",
      type=command,
      license=[],
      args=
      [
       {subscription, {oma_type, {enum, [nrj_prepaid]}},
        "This parameter specifies the subscription."},
       {url_ok, {link, []},
        "This parameter specifies the page when match tariff plan"},
       {url_default, {link, []},
        "This parameter specifies the default page"}
      ]
     }
    );

redirect_by_plan_tarifaire(abs,Subscription, Url_ok, Url_default) ->  
    [{redirect,abs,Url_ok},
     {redirect,abs,Url_default}];

redirect_by_plan_tarifaire(Session,Subscription, Url_ok, Url_default) 
  when Subscription == "nrj_prepaid"->
    State = svc_util_of:get_user_state(Session),
    PTF=(State#sdp_user_state.cpte_princ)#compte.ptf_num,
    case PTF of
	?PTF_NEPTUNE_PP_DOUBLE_JEU ->
	    {redirect,Session,Url_ok};
	_ ->
	    slog:event(trace,?MODULE,plan_tarifaire,PTF),
	    {redirect,Session,Url_default}
    end.

redirect_by_dcl(plugin_info, DCL, URL_OK, URL_NOK) ->
    (#plugin_info
     {help =
      "This plugin function redirect to the page depending on"
      " the declinaison is the account declinaison or not.",
      type = command,
      license = [],
      args =
      [        
       {dcl, {oma_type, {defval, 0, int}},
	"This parameter specifies the declinaison."},
       {url_ok, {link, []},
        "This parameter specifies the next page when the DCL is the main account declinaison."},
       {url_nok, {link, []},
        "This parameter specifies the next page when the DCL is not the main account declinaison."}
      ]
     }
    );
redirect_by_dcl(abs, DCL, URL_OK, URL_NOK) ->
    [{redirect,abs,URL_OK},
     {redirect,abs,URL_NOK}];
redirect_by_dcl(Session, DCL, URL_OK, URL_NOK)->
    State = svc_util_of:get_user_state(Session),
    Dcl_num = State#sdp_user_state.declinaison,
    Dcl_str = integer_to_list(Dcl_num),
    case Dcl_str of
	DCL ->
	    {redirect, Session, URL_OK};
	_ ->
	    {redirect, Session, URL_NOK}
    end.

redirect_by_bonus_identify_bic_phone(plugin_info, URL_OK, URL_NOK)->
        (#plugin_info
     {help =
      "This plugin function redirect to the page depending on"
      " the declinaison is the account declinaison or not.",
      type = command,
      license = [],
      args =
      [
       {url_ok, {link, []},
        "This parameter specifies the next page when the DCL is ?mobi, ?cpdeg, ?mobi_new, identified B_phone."},
       {url_nok, {link, []},
        "This parameter specifies the next page when the DCL is non identified B_phone or Others."}
      ]
     }
    );
redirect_by_bonus_identify_bic_phone(abs, URL_OK, URL_NOK) ->
    [{redirect,abs,URL_OK},
     {redirect,abs,URL_NOK}];
redirect_by_bonus_identify_bic_phone(Session, URL_OK, URL_NOK)->
    {_,Session_reinit}=svc_util_of:reinit_compte(Session),
    State = svc_util_of:get_user_state(Session_reinit),
    Dcl_num = State#sdp_user_state.declinaison,
    case Dcl_num of
        DCL when DCL==?mobi;
		 DCL==?cpdeg;
		 DCL==?mobi_new;
		 DCL==?mobi_janus->
            {redirect, Session_reinit, URL_OK};
        ?B_phone ->
	    case svc_util_of:is_identify(Session_reinit) of
		true ->
		    {redirect, Session_reinit, URL_OK};
		_ ->
		    {redirect, Session_reinit, URL_NOK}
	    end;
	_ ->
	    {redirect, Session_reinit, URL_NOK}
    end.

redirect_if_ratio_zero(Session, Cpte, UNT_REST, URL_ZERO, URL_NOT_ZERO)
when UNT_REST=="sms"->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
	#compte{unt_num=?EURO,ptf_num=PTF_NUM,
                        etat=?CETAT_AC}=Compte->
	    Ratio = svc_compte:ratio_mnesia(svc_compte:dcl(State),Compte#compte.tcp_num,PTF_NUM,sms),
	    case Ratio of
		?Zero->
		    {redirect, Session, URL_ZERO};
		_ ->
		    {redirect, Session, URL_NOT_ZERO}
	    end;
	_->
	    {redirect, Session, URL_NOT_ZERO}
    end.

resilier_mobi_bonus(Session)->
    {Session1,Opt}=get_actived_bonus_option(Session),
    case Opt of
	no_option->
	    slog:event(trace,?MODULE,no_option_actived),
	    {Session1,{nok,no_option_active}};
	opt_bonus_sms->
	    {_,Session_reinit}= svc_util_of:reinit_compte(Session1),
	    State=svc_util_of:get_user_state(Session_reinit),
	    case svc_compte:cpte(State,cpte_mobi_bonus) of
		#compte{etat=?CETAT_AC}=Compte->
		    svc_options:do_opt_cpt_request(Session_reinit,opt_bonus_sms,terminate);
		_->
		    svc_options:do_opt_cpt_request(Session_reinit,opt_bonus_sms_illimite,terminate)
	    end;
	X when X==opt_bonus_europe;X==opt_bonus_maghreb->
	    svc_options:do_opt_cpt_request(Session1,opt_bonus_appels_etranger,terminate),
	    svc_options:do_opt_cpt_request(Session1,Opt,terminate);
	_->
	    svc_options:do_opt_cpt_request(Session1,Opt,terminate)
    end.%% {Session2,Result}
    

resilier_bonus_and_redirect(#session{prof=Profile}=Session,Urls)->
    [Uok,Unok]=string:tokens(Urls,","),
    {Session1,Result}=resilier_mobi_bonus(Session),
    case Result of
	{ok_operation_effectuee,_}->
	    {_,Session_reinit}= svc_util_of:reinit_compte(Session1),
	    Subscription = svc_util_of:get_souscription(Session_reinit),
	    Msisdn = Profile#profile.msisdn,
	    PTChangePrice = currency:sum(euro,0),
	    Compte = #compte{ptf_num=?PTF_MOBI_BONUS,
			     pct=PTChangePrice,
			     d_crea=pbutil:unixtime(),
			     tcp_num=?C_PRINC,
			     ctrl_sec=0},
	    case svc_util_of:change_user_account(Session_reinit, {Subscription, Msisdn},Compte) of 
		{ok,_}->
		    {_,NSession_reinit}= svc_util_of:reinit_compte(Session_reinit),
		    {redirect,NSession_reinit,Uok};
		E ->
		    slog:event(failure, ?MODULE, change_user_account_nok, E),
		    {redirect, Session_reinit, Unok}
	    end;
	Error->
	    slog:event(trace, ?MODULE, do_request_terminate_nok, Error),
	    {redirect, Session1, Unok}
    end.

change_mobi_bonus(#session{prof=Profile}=Session,Option,Urls)->
    [Uok,Unok]=string:tokens(Urls,","),
    Opt=list_to_atom(Option),
    {Session1,Result_supprime}=resilier_mobi_bonus(Session),
    case Result_supprime of
	{ok_operation_effectuee,_}->
	    slog:event(trace,?MODULE,opt_supprime,{terminate,ok}),
	    Subscription = svc_util_of:get_souscription(Session1),
	    Msisdn = Profile#profile.msisdn,
	    PTChangePrice = currency:sum(euro,0),
	    Compte = #compte{ptf_num=svc_options:ptf_num(Opt,mobi),
			     pct=PTChangePrice,
			     d_crea=pbutil:unixtime(),
			     tcp_num=?C_PRINC,
			     ctrl_sec=0},
	    {Session2,Result}=
		case Opt of
		    X when X==opt_bonus_europe;X==opt_bonus_maghreb->
			svc_options:do_nopt_cpt_request(Session1,[Opt,opt_bonus_appels_etranger],subscribe,[]);
		    _->
			svc_options:do_opt_cpt_request(Session1,Opt,subscribe)
		end,
	    case Result of
		{ok_operation_effectuee,_}->
		    {_,Session_reinit}= svc_util_of:reinit_compte(Session2),
		    case svc_util_of:change_user_account(Session_reinit, {Subscription, Msisdn},Compte) of 
			{ok,_}->
			    {_,NSession_reinit}= svc_util_of:reinit_compte(Session_reinit),
			    {redirect,NSession_reinit,Uok};
			E ->
			    slog:event(failure, ?MODULE, change_user_account_nok, E),
			    {redirect, Session_reinit, Unok}
		    end;
		Error->
		    slog:event(trace, ?MODULE, do_request_subscribe_nok, Error),
		    {redirect, Session2, Unok}
	    end;
	_->
	    slog:event(failure,?MODULE,terminate_nok,Result_supprime),
	    {redirect,Session1,Unok}
    end.

get_avantage(Opt,Amount)->
    Text1=integer_to_list(Amount)++"E_",
    Text2=
	case Opt of
	    opt_bonus_appels->"appels";
	    opt_bonus_sms->"messages";
	    opt_bonus_internet->"internet";
	    opt_bonus_europe->"appels_europe";
	    opt_bonus_maghreb->"appels_maghreb";
	    no_option -> ""
	end,
    Text=Text1++Text2,
    Avantage_list=pbutil:get_env(pservices_orangef,avantage_janus),
    Result=lists:keysearch(Text,1,Avantage_list),
    case Result of
	{value,{_,Avantage}}->
	    Avantage;
	_ ->
	    []
    end.

print_avantage(Session,Type)->
    State=svc_util_of:get_user_state(Session),
    Credit=get_bonus_solde(Session)/1000,
    Amount=
	case Type of
	    "current"->
		case Credit of
		    X when X<20->10;
		    Y when Y<30->20;
		    _->30
		end;
	    "next"->
		case Credit of
		    X when X<10->10;
		    Y when Y<20->20;
		    _->30
		end
	end,
    {Session1,Opt}=get_actived_bonus_option(Session),
    Avantage=get_avantage(Opt,Amount),
    [{pcdata,Avantage}].

print_need_amount_for_bonus(Session)->
    State=svc_util_of:get_user_state(Session),
    Credit=get_bonus_solde(Session)/1000,
    Sum=
	case Credit of
	    X when X<10->10-Credit;
	    Y when Y<20->20-Credit;
	    _ ->30-Credit
	end,
    Div=trunc(Sum*100) div 100,
    Rem=trunc(Sum*100+0.1) rem 100,
    Amount=pbutil:sprintf("%d.%d",[Div,Rem]),
    [{pcdata,Amount}].

redirect_by_bonus_credit(Session,URLs)->
    [Url_less10E,Url_less30E,Url_more30E]=string:tokens(URLs,","),
    {_,Session_reinit}= svc_util_of:reinit_compte(Session),
    State=svc_util_of:get_user_state(Session_reinit),
    Credit=get_bonus_solde(Session_reinit)/1000,
    case Credit of
	X when X<10->{redirect, Session_reinit, Url_less10E};
	Y when Y<30->{redirect, Session_reinit, Url_less30E};
	_ ->{redirect, Session_reinit, Url_more30E}
    end.

redirect_decouvrir_bonus(plugin_info, Url_cible, Url_provisoire) ->
    (#plugin_info
     {help =
      "This plugin command redirect by tye decouvrir bonus",
      type = command,
      license = [],
      args =
      [
       {url_cible, {link,[]},
	"This parameter specifies the cible page"},
       {url_provisoire, {link,[]},
	"This parameter specifies the provisoire page"}
      ]});

redirect_decouvrir_bonus(abs,Url_cible, Url_provisoire) ->
    [{redirect, abs, Url_cible},
     {redirect, abs, Url_provisoire}];

redirect_decouvrir_bonus(Session,Url_cible,Url_provisoire)->
    Type_decouvrir=pbutil:get_env(pservices_orangef,type_decouvrir_bonus),
    case Type_decouvrir of
	"cible"->
	    {redirect, Session, Url_cible};
	"provisoire" ->
	    {redirect, Session, Url_provisoire}
    end.

print_bonus_solde(Session)->
    Value=get_bonus_solde(Session),
    CR = currency:print(currency:to_euro({sum,euro,Value})),
    [{pcdata, lists:flatten(CR)}].
print_fun_menu(plugin_info, Page)->
    (#plugin_info
     {help =
      "This plugin returned appropriate message with input page.",
      type = function,
      license = [],
      args = [ 
	       {page, {oma_type, {enum,[fun_sonneries_p1,
				        fun_sonneries_p2,
					fun_sonneries_p3,
					fun_jeux_p1,
					fun_jeux_p2,
					fun_jeux_p3,
					fun_tones_p1,
					fun_tones_p2,
					fun_tones_p3]}},
		"This parameter specifies page to display returned messge."}
	      ]
     }
    );
print_fun_menu(abs, Page)->
    [{pcdata," "}];
print_fun_menu(Session, Page)->
    State = svc_util_of:get_user_state(Session),    
    DCL = State#sdp_user_state.declinaison,
    Redirect_mobicarte= pbutil:get_env(pservices_orangef,redirect_mobicarte),
    {value, {_, List}} = lists:keysearch(sachem, 1, Redirect_mobicarte),
    {value, {_, TypeSubbscription}} = lists:keysearch(integer_to_list(DCL), 1, List),
    Message=case TypeSubbscription of
		mobicarte->
		   case Page of
		       "fun_sonneries_p1"->
			   " multimedia: internet,";
		       "fun_sonneries_p2"->
			   "internet max, musique, TV, TV max. ";
		       "fun_jeux_p2"->
			   " multimedia: internet, internet max, ";
		       "fun_jeux_p3"->
			   "TV max. Mobiles compatible Java necessaire. ";
		       _ ->
			   ""
		   end;
		foot->
		   case Page of
                       "fun_sonneries_p1"->
                           " multimedia:";
                       "fun_sonneries_p2"->
                           "internet, internet max, musique, TV, TV max. ";
                       "fun_jeux_p2"->
                           " multimedia: internet, internet max, musique,";
                       "fun_jeux_p3"->
                           "TV, TV max. Mobiles compatible Java necessaire. ";
		       _ ->
			   ""
                   end;
		X when X==m6; X==m6sample->
		   case Page of
                       "fun_sonneries_p1"->
                           " multimedia:";
                       "fun_sonneries_p2"->
                           "internet, internet max, musique, TV, TV max. ";
                       "fun_jeux_p2"->
                           " multimedia: internet, internet max, musique,";
                       "fun_jeux_p3"->
                           "TV, TV max. Mobiles compatible Java necessaire. ";
		       _ ->
			   ""
                   end;
		click->
		   case Page of
                       "fun_sonneries_p1"->
                           "";
                       "fun_sonneries_p2"->
                           " multimedia: internet, internet max, musique, TV, TV max. ";
                       "fun_jeux_p2"->
                           " multimedia: internet, internet max, musique,";
                       "fun_jeux_p3"->
                           "TV, TV max. Mobiles compatible Java necessaire. ";
		       _ ->
			   ""
                   end;
		umobile->
		   case Page of
                       "fun_sonneries_p1"->
                           " multimedia: internet, internet max, musique, TV,";
		       "fun_sonneries_p2"->
                           "TV max ou reste a votre charge si vous n'avez pas ces options. ";
		       _ ->
			   ""
                   end;
		_ ->
		    slog:event(internal, ?MODULE, unknow_type_subscription, {dcl,DCL, typesubscription, TypeSubbscription}),
		    ""
	   end,
    [{pcdata,Message}].

get_bonus_solde(Session)->
    {Session1,Opt}=get_actived_bonus_option(Session),
    NewSess=
	case Opt of
	    no_option->
		Session1;
	    X when X==opt_bonus_europe;X==opt_bonus_maghreb->
		svc_options_mobi:get_info_for_option(Session1, opt_bonus_appels_etranger);
	    _->
		svc_options_mobi:get_info_for_option(Session1, Opt)
	end,
    State = svc_util_of:get_user_state(NewSess),
    OptInfo2=State#sdp_user_state.c_op_opt_info2,
    Cpp_cumul_credit_Princ = 
	case svc_compte:cpte(State,cpte_princ) of
	    #compte{cpp_cumul_credit=CrPr} when is_integer(CrPr) -> CrPr;
	    _ -> 0
	end,
    Cpp_cumul_credit_bons_plans = 
	case svc_compte:cpte(State,cpte_e_recharge) of
	    #compte{cpp_cumul_credit=CrBons} when is_integer(CrBons) -> CrBons;
	    _ -> 0
	end,
    Cumul = Cpp_cumul_credit_Princ + Cpp_cumul_credit_bons_plans,
    case Cumul >= OptInfo2 of
	true -> round((Cumul - OptInfo2)/1000)*1000; %% round up the value and convert to thousand of euro
	_ -> 0
    end.


get_actived_bonus_option(Session)->
    {Session1,State_topNumList}=svc_options:check_topnumlist(Session),
    Opt=	
	case {svc_options:check_option_activated_from_list(Session1,opt_bonus_appels),
	      svc_options:check_option_activated_from_list(Session1,opt_bonus_sms),
	      svc_options:check_option_activated_from_list(Session1,opt_bonus_internet),
	      svc_options:check_option_activated_from_list(Session1,opt_bonus_europe),
	      svc_options:check_option_activated_from_list(Session1,opt_bonus_maghreb)} of
	    {true,_,_,_,_}->opt_bonus_appels;
	    {_,true,_,_,_}->opt_bonus_sms;
	    {_,_,true,_,_}->opt_bonus_internet;
	    {_,_,_,true,_}->opt_bonus_europe;
	    {_,_,_,_,true}->opt_bonus_maghreb;
	    {_,_,_,_,_}->no_option
	end,
    {Session1,Opt}.

redirect_by_bonus_credit(#session{prof=Profile}=Session)->
    Msisdn = Profile#profile.msisdn,
    {_,Session_reinit}= svc_util_of:reinit_compte(Session),
    State=svc_util_of:get_user_state(Session_reinit),
    {Session1,Opt}=get_actived_bonus_option(Session_reinit),
    case {Opt,svc_compte:cpte(State,cpte_mobi_bonus),svc_compte:cpte(State,cpte_mobi_bonus_sms)} of
	{opt_bonus_sms,_,#compte{}=Compte} when Compte#compte.etat==?CETAT_AC->
	    Link="#bonus_sms_more30E",
	    {redirect,Session1,Link};

        {X ,#compte{}=Compte,_} when X=/=opt_bonus_sms,Compte#compte.etat==?CETAT_AC->
	    Prefix=string:substr(atom_to_list(Opt),5),
	    Link="#"++Prefix++"_more30E",
	    {redirect,Session1,Link};

	{_,#compte{}=Compte,_} when Compte#compte.etat==?CETAT_AC->
	    Prefix=string:substr(atom_to_list(Opt),5),
	    Link="#"++Prefix++"_more10E",
	    {redirect,Session1,Link};
        
	{X,no_cpte_found,no_cpte_found} when X=/=no_option->
	    Prefix=string:substr(atom_to_list(Opt),5),
	    Link="#"++Prefix++"_less10E",
	    {redirect,Session1,Link};

	{_,#compte{}=Compte,_} when Compte#compte.etat==?CETAT_EP;Compte#compte.etat==?CETAT_PE->
	    Prefix=string:substr(atom_to_list(Opt),5),
	    Link="#"++Prefix++"_consumed",
	    {redirect,Session1,Link};

	{_,_,#compte{}=Compte} when Compte#compte.etat==?CETAT_EP;Compte#compte.etat==?CETAT_PE->
	    Prefix=string:substr(atom_to_list(Opt),5),
	    Link="#"++Prefix++"_consumed",
	    {redirect,Session1,Link};

	{Opt, Cpte_mobi_bonus, Cpte_mobi_bonus_sms} ->
	    slog:event(failure,?MODULE,redirect_by_bonus_credit_no_bonus, 
                       {Msisdn,
                        {option,   Opt}, 
                        {cpte_mobi_bonus,     Cpte_mobi_bonus}, 
                        {cpte_mobi_bonus_sms, Cpte_mobi_bonus_sms}}),
	    {redirect,Session1,"#error_technique"}
    end.

check_and_maj_opt_terminate(Session,[]) -> {ok, Session};     
check_and_maj_opt_terminate(Session,Lists) ->
    [Opt1|Tail] = Lists,
    case svc_options:is_option_activated(Session,Opt1) of 
	true -> 
	    case svc_options:do_opt_cpt_request(Session,Opt1,terminate) of 
		{NSession,{ok_operation_effectuee,_}} ->
		    {_,Session_reinit}= svc_util_of:reinit_compte(NSession),
		    check_and_maj_opt_terminate(Session_reinit,Tail);
		Else ->
		    {Else, Session}
	    end;
	_ ->
	    check_and_maj_opt_terminate(Session,Tail)
    end.

% Redirect by the date of 'Journee KDO Bons plans'
redir_by_jkdo_bp_date(plugin_info, URL_JKDO, URL_NOT_JKDO) ->
    (#plugin_info
     {help =
      "This plugin command redirect by Segment Commercial",
      type = command,
      license = [],
      args =
      [
       {url_jkdo, {link, []},
        "This parameter specifies the page when the date is 'Journee KDO Bons plans'"},
       {url_not_jkdo, {link, []},
        "This parameter specifies the page when the date is not 'Journee KDO Bons plans'"}
      ]});
redir_by_jkdo_bp_date(Session, URL_JKDO, URL_NOT_JKDO)->
    case svc_util_of:is_commercially_launched(Session, journee_kdo_bp) of
        true ->
	    case svc_options:is_any_option_activated(Session,
                                                     [opt_j_app_ill,
                                                      opt_s_app_ill,
                                                      opt_jsms_ill,
                                                      opt_ssms_ill,
                                                      opt_j_mm_ill,
						      opt_s_mm_ill,
						      opt_j_tv_max_ill,
						      opt_s_tv_max_ill]) of 
		true ->
		    slog:event(trace, ?MODULE, check_kdo, true),
		    {redirect, Session, URL_NOT_JKDO};
		_ ->
		    {redirect, Session, URL_JKDO}
	    end;
	_ ->
	    {redirect, Session, URL_NOT_JKDO}
    end.

% Redirect by the date to display 'Journee KDO Bons plans' teasing
redir_by_teasing_jkdo_bp_date(plugin_info, URL_TEASING_JKDO, URL_NOT_TEASING_JKDO) ->
    (#plugin_info
     {help =
      "This plugin command redirect by Segment Commercial",
      type = command,
      license = [],
      args =
      [
       {url_teasing_jkdo, {link, []},
        "This parameter specifies the page when the date is suitable to diaplay 'Journee KDO Bons plans' teasing"},
       {url_not_teasing_jkdo, {link, []},
        "This parameter specifies the page when the date is not suitable to display 'Journee KDO Bons plans' teasing"}
      ]});
redir_by_teasing_jkdo_bp_date(Session, URL_TEASING_JKDO, URL_NOT_TEASING_JKDO)->
    case svc_util_of:is_commercially_launched(Session, teasing_jkdo_bp) of
        true ->
            {redirect, Session, URL_TEASING_JKDO};
        _ ->
	    {redirect, Session, URL_NOT_TEASING_JKDO}
    end.

redirect_by_cpte_etat(Session,Cpte,URLs)->
    [UAct,UNull]=string:tokens(URLs,","),
    {_,Session_reinit}= svc_util_of:reinit_compte(Session),
    State=svc_util_of:get_user_state(Session_reinit),
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
        #compte{}->
	    case svc_compte:etat_cpte(State,list_to_atom(Cpte)) of
		?CETAT_AC-> {redirect,Session_reinit,UAct};
		_ ->
		    {redirect,Session_reinit,UNull}
	    end;
	_ ->
	    {redirect,Session_reinit,UNull}
    end.

redirect_by_choisir_bonus(Session, Url_choisir, Url_choisir_promo) ->
    {_,Session_init}= svc_util_of:reinit_compte(Session),
    {Session1,State}=svc_options:check_topnumlist(Session_init),
    case State#sdp_user_state.d_activ of
	Int when integer(Int)->
    case svc_util_of:is_commercially_launched(Session1,mobi_janus_promo) of
	true->
	    DateActive = svc_util_of:unixtime_to_local_time(State#sdp_user_state.d_activ),
	    case svc_util_of:get_commercial_date(mobi,user_janus_promo) of
		[{Begin,End}]->
		    case (Begin < DateActive) and (DateActive < End) of
			true->
			    {redirect,Session1,Url_choisir_promo};
			_->
			    slog:event(trace, ?MODULE, janus_promo, out_of_promo),
			    {redirect,Session1,Url_choisir}
		    end;
		_->
		    slog:event(internal,?MODULE,user_janus_promo,commercial_date_not_found),
		    {redirect,Session1,Url_choisir}
	    end;
	_->
	    {redirect,Session1,Url_choisir}
 	     end;
	_->
	    slog:event(internal,?MODULE,unknow_d_activ,State#sdp_user_state.d_activ),
	    exit({error,redirect_by_choisir_bonus})
    end.
	
redir_by_end_credit_m6_ssms(plugin_info, URL_OK, URL_NOK) ->
    (#plugin_info
     {help =
      "This plugin command redirect by end credit date of soiree sms illimite m6",
      type = command,
      license = [],
      args =
      [
       {url_ok, {link, []},
        "This parameter specifies the page when the date is before the end credit date of soiree sms illimite m6"},
       {url_nok, {link, []},
        "This parameter specifies the page when the end credit date of soiree sms illimite m6 is passed"}
      ]});
redir_by_end_credit_m6_ssms(Session, URL_OK, URL_NOK) ->
    State=svc_util_of:get_user_state(Session),
    case {svc_compte:cpte(State, cpte_m6_soiree_sms_dispo),
          svc_compte:cpte(State, cpte_m6_soiree_sms_recharge)} of
        {no_cpte_found,no_cpte_found} ->
	    {redirect, Session, URL_NOK};
	{Cpte_dispo,no_cpte_found} ->
	    State=svc_util_of:get_user_state(Session),
	    case svc_compte:get_cpte_from_list(State,cpte_m6_soiree_sms_dispo) of
		#compte{dlv=DLV} ->
		    case DLV > svc_util_of:local_time_to_unixtime(erlang:localtime()) of
			true ->
			    {redirect, Session, URL_OK};
			_ ->
			    {redirect, Session, URL_NOK}
		    end;
		_ ->
		    {redirect, Session, URL_NOK}
	    end;
        {_,Cpte_recharge} ->
	    {redirect, Session, URL_OK}
    end.


is_condition_zap_vacances(Session) ->
    State = svc_util_of:get_user_state(Session),
    DCL=svc_compte:dcl(State),
    (DCL==?zap_vacances) or (DCL==?zap_cmo_1h30_v2) or
	is_condition_heure_zap_vacances(Session).

is_condition_heure_zap_vacances(Session) ->
    State = svc_util_of:get_user_state(Session),
    DCL=svc_compte:dcl(State),
    case DCL of
        ?ppol2->
            case {catch svc_compte:ptf_num(State,cpte_princ), catch svc_compte:ptf_num(State,cpte_voix)} of
                {?Capri,?PTF_ZAP_VACANCES_FB1}->
                    true;
                _->
                    false
            end;
        ?zap_cmo->
            case {catch svc_compte:ptf_num(State,cpte_princ), catch svc_compte:ptf_num(State,cpte_voix)} of
                {?PTF_ZAP_VACANCES_FB2,?PTF_ZAP_VACANCES_FB3}->
                    true;
                _->
                    false
            end;
        _->
            false
    end.
    

redirect_by_zap_vacances(plugin_info, URL_OK, URL_NOK) ->
    (#plugin_info
     {help =
      "This plugin command redirect by zap vacances condition",
      type = command,
      license = [],
      args =
      [
       {url_ok, {link, []},
        "This parameter specifies the page with zap vacances condition"},
       {url_nok, {link, []},
        "This parameter specifies the page without zap vacances condition"}
      ]});

redirect_by_zap_vacances(abs, URL_OK, URL_NOK) ->
    [{redirect,abs,URL_OK},
     {redirect,abs,URL_NOK}];

redirect_by_zap_vacances(Session, URL_OK, URL_NOK)->
    case is_condition_zap_vacances(Session) of
	true ->
	    {redirect, Session, URL_OK};
	_ ->
	    {redirect, Session, URL_NOK}
    end.

track_kenobi_code(plugin_info, Kenobi_code) ->
    (#plugin_info
     {help =
      "This plugin function add Kenobi trace to the log for current page",
      type = function,
      license = [],
      args =
      [
       {kenobi_code, {oma_type, {defval,"",string}},
        "This parameter specifies the Kenobi code"}
      ]});

track_kenobi_code(abs, Kenobi_code) ->
    [];

track_kenobi_code(Session, Kenobi_code) ->
    Navigation=lists:nth(1,Session#session.log),
    case Navigation of
        {'M',"back"}->[];
        _->
            prisme_dump:prisme_count_v1(Session, Kenobi_code)
    end,
    [].

track_kenobi_code(plugin_info, Option, Action) ->
    (#plugin_info
     {help =
      "This plugin function add KENOBI trace for page",
      type = function,
      license = [],
      args =
      [
       {option, {oma_type, {defval,"",string}},
        "This parameter specifies the Kenobi code"},
       {action, {oma_type, {enum, [description, souscription, validation]}},
        "This parameter specifies the Kenobi code"}
      ]});


track_kenobi_code(abs, Option, Action) ->
    [];

track_kenobi_code(Session, "bons_plans", mobi) ->
    Service=svc_of_config_options_mobi:get_value(Session,"option"),	
    Opt=list_to_atom(Service),
    Action=svc_of_config_options_mobi:get_value(Session, "request_state"),
    Current_page=svc_of_config_options_mobi:get_value(Session,"current_page"),
    Navigation=lists:nth(1,Session#session.log),
    case {Action++Current_page, Navigation} of
        {_, {'M',"back"}}->[];
        {X, _} when X=="description1"; X=="promo_description1"->
            prisme_dump:prisme_count(Session, Opt, description);
        {X, _} when X=="souscription1"; X=="promo_souscription1"->
            prisme_dump:prisme_count(Session, Opt, {subscribe, souscription});
        {_, _}->[]
    end,
    [];

track_kenobi_code(Session, "bons_plans", Sub)when Sub==cmo;Sub==postpaid->
    Option=svc_of_config_options_cmo:get_value(Session,"option"),	
    Opt=list_to_atom(Option),
    Action=svc_of_config_options_cmo:get_value(Session, "request_state"),
    Current_page=svc_of_config_options_cmo:get_value(Session,"current_page"),
    Navigation=lists:nth(1,Session#session.log),
    case {Action++Current_page, Navigation} of
        {_, {'M',"back"}}->[];
        {"description1", _}->
            prisme_dump:prisme_count(Session, Opt, description);
        {"souscription1", _}->
            prisme_dump:prisme_count(Session, Opt, {subscribe, souscription});
        {_, _}->[]
    end,
    [];

track_kenobi_code(Session, Option, Action) ->
    Opt=list_to_atom(Option),
    Act=list_to_atom(Action),
    Navigation=lists:nth(1,Session#session.log),
    case {Act, Navigation} of
        {_, {'M',"back"}}->[];
        {description, _}->
            prisme_dump:prisme_count(Session, Opt, description);
        {X, _} when X==souscription; X==validation->
            prisme_dump:prisme_count(Session, Opt, {subscribe, X});
        {_, _}->
            slog:event(trace,?MODULE,track_kenobi_code, incorrect_action)
    end, 
    [].

redirect_by_roaming_network(plugin_info, Url_default) ->
    (#plugin_info
     {help =
      "This plugin command redirect by zap vacances condition",
      type = command,
      license = [],
      args =
      [
       {url_default, {link, []},
        "This parameter specifies the default page"}
      ]});

redirect_by_roaming_network(abs, Url_default) ->
    [{redirect,abs, Url_default}];

redirect_by_roaming_network(Session=#session{prof=#profile{subscription="mobi"}}, Url_default)->
   Url_camel="file:/mcel/acceptance/mobi/roaming/menu.xml",
   Url_nocamel="file:/orangef/selfcare_long/callback.xml#mobi",
   Url_ming=Url_nocamel,
   Url_ansi=Url_nocamel,
   Links = "camel="++Url_camel++",nocamel="++Url_nocamel++",ming="++Url_ming++",ansi="++Url_ansi++",default="++Url_default,
   svc_roaming:redir_roaming_network(#session{location=L}=Session,Links).

redirect_by_roaming_network(plugin_info, Url_camel, Url_nocamel, Url_ming, Url_ansi,Url_default) ->
    (#plugin_info
     {help =
      "This plugin command redirect by zap vacances condition",
      type = command,
      license = [],
      args =
      [
       {url_camel, {link, []},
        "This parameter specifies the camel page"},
       {url_nocamel, {link, []},
        "This parameter specifies the nocamel page"},
       {url_ming, {link, []},
        "This parameter specifies the ming page"},
       {url_ansi, {link, []},
        "This parameter specifies the ansi page"},
       {url_default, {link, []},
        "This parameter specifies the default page"}
      ]});

redirect_by_roaming_network(abs, Url_camel, Url_nocamel, Url_ming, Url_ansi,Url_default) ->
    [{redirect,abs, Url_camel},
        {redirect,abs, Url_nocamel},
        {redirect,abs, Url_ming},
        {redirect,abs, Url_ansi},
        {redirect,abs, Url_default}];

redirect_by_roaming_network(Session, Url_camel, Url_nocamel, Url_ming, Url_ansi,Url_default)->
   Links = "camel="++Url_camel++",nocamel="++Url_nocamel++",ming="++Url_ming++",ansi="++Url_ansi++",default="++Url_default,
   svc_roaming:redir_roaming_network(#session{location=L}=Session,Links).

init_postpaid_svc_data(plugin_info, URL) ->
    (#plugin_info
     {help =
      "This plugin command init svc_data for postpaid and redirect",
      type = command,
      license = [],
      args =
      [
       {url, {link, []},
        "This parameter specifies the next page"}
      ]});

init_postpaid_svc_data(abs, URL) ->
    [{redirect,abs, URL}];

init_postpaid_svc_data(Session, URL)->
    OfferPOrSUid = svc_spider:read_field(offerPOrSUid, Session),
    case OfferPOrSUid of 
       "PRO"-> 
           svc_postpaid:init_svc_data(Session,"pro",URL);
       _->
           svc_postpaid:init_svc_data(Session,"gp",URL)
   end.

redirect_by_postpaid_segCo(plugin_info, URL_old, URL_new) ->
    (#plugin_info
     {help =
      "This plugin command and update segcode and redirect",
      type = command,
      license = [],
      args =
      [
       {url_old, {link, []},
        "This parameter specifies the next page if segco is in old list"},
       {url_new, {link, []},
        "This parameter specifies the page if segCo is new"}
      ]});

redirect_by_postpaid_segCo(abs, URL_old, URL_new) ->
    [{redirect,abs, URL_old},
     {redirect,abs, URL_new}];
redirect_by_postpaid_segCo(#session{prof=#profile{imsi=Imsi}}=Session,URL_old, URL_new) ->
    case svc_subscr_asmetier:check_client_forfait_date(Session) of
        {true,Value}->
            NSession=variable:update_value(Session,segCo,{Imsi,Value}),
            {redirect, NSession, URL_old};
        _ -> 
            NSession=variable:update_value(Session,segCo,{Imsi,undefined}),
            {redirect, NSession, URL_new}
    end.

%% PC Jun 10
redirect_avantages_vacances(plugin_info, URL_DECLARER, URL_CHANGER, URL_HEURE) ->
     (#plugin_info
     {help =
      "This plugin check 'zone academique' and 'hueres zap vacances' to redirect",
      type = command,
      license = [],
      args =
      [
       {url_declarer, {link,[]},
        "This parameter specifies the page Declarer zone academique"},
       {url_changer, {link,[]},
        "This parameter specifies the page Changer zone academique"},
       {url_heure, {link,[]},
        "This parameter specifies the page Heures Zap vacances"}
      ]});
redirect_avantages_vacances(abs, URL_DECLARER, URL_CHANGER, URL_HEURE) ->
    [
     {redirect, abs, URL_DECLARER},
     {redirect, abs, URL_CHANGER},
     {redirect, abs, URL_HEURE}
    ];

redirect_avantages_vacances(Session, URL_DECLARER, URL_CHANGER, URL_HEURE) ->
    State = svc_util_of:get_user_state(Session),
    DCL=svc_compte:dcl(State),
    case DCL of
        X when X==?zap_vacances;
	       X==?zap_cmo_1h30_v2 ->            
	    Declared = svc_options:is_option_activated(Session, opt_zap_vacances),
            case Declared of
                true ->
		    {redirect, Session, URL_CHANGER};
                _ ->
		    {redirect, Session, URL_DECLARER}
            end;
        _  ->
	    {redirect, Session, URL_HEURE}
    end.
