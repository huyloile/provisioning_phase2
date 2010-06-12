-module(test_123_postpaid_sms_mms_infos).
-export([run/0, online/0, pages/0, parent/1, links/1]).

-include("../../ptester/include/ptester.hrl").
-include("../include/mmsinfos.hrl").
-include("../include/ftmtlv.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(sms_menu_script1_mobi,"SMS Infos: Vous souhaitez vous inscrire a la rubrique:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport.*5:Blagues.*6:Suite des rubriques.*7:\\+ d'infos.*").
-define(Dyn_links_sms,[?sms_meteo, ?sms_horoscope, ?sms_actu, ?sms_sport, ?sms_blague]).
-define(Dyn_links_mms,[?mms_meteo, ?mms_actu, ?mms_ligue1, ?mms_people, ?mms_cine, ?mms_humour, ?mms_charme]).
-define(Dyn_links_mmsv,[?mms_ligue1_vdo, ?humour_menu, ?coquin_menu]).
-define(Dyn_link_main_page,[?suivi_conso_plus_menu, 
			    ?suivi_conso_plus,
			    ?mobi_bonus,
			    ?exclusives]).
-define(Dyn_link_main_page_promo,[?suivi_conso_plus_menu,
                            ?suivi_conso_plus,
                            ?mobi_bonus,
                            ?exclusives,
			    ?suite_to_promo]).
-define(smsi_mobi, test_util_of:access_code(?MODULE, ?sms_infos, 
					    ?Dyn_link_main_page
					   )).

-define(smsi_mobi_promo, test_util_of:access_code(?MODULE, ?sms_infos_promo, 
						  ?Dyn_link_main_page_promo
						 )).

-define(code_ligue1_mobi, test_util_of:access_code(?MODULE, ?orange_ligue1, 
						   ?Dyn_link_main_page
						  )).

-define(code_meteo_mobi, test_util_of:access_code(?MODULE, ?sms_meteo, 
						  ?Dyn_link_main_page
						  ++ ?Dyn_links_sms)).

-define(code_meteo_mobi_promo,  test_util_of:access_code(?MODULE, ?meteo_promo,
							 ?Dyn_link_main_page_promo
)).

-define(code_horo_mobi, test_util_of:access_code(?MODULE, ?sms_horoscope, 
						 ?Dyn_link_main_page
						 ++ ?Dyn_links_sms)).

-define(code_horo_mobi_promo,  test_util_of:access_code(?MODULE, ?horoscope_promo,
							?Dyn_link_main_page_promo
						       )).

-define(code_actu_mobi, test_util_of:access_code(?MODULE, ?sms_actu, 
						 ?Dyn_link_main_page
						 ++ ?Dyn_links_sms)).

-define(code_actu_mobi_promo,  test_util_of:access_code(?MODULE, ?actu_promo, 
							?Dyn_link_main_page_promo
						       )).

-define(code_sport_mobi, test_util_of:access_code(?MODULE, ?sms_sport, 
						  ?Dyn_link_main_page
						  ++ ?Dyn_links_sms)).

-define(code_sport_mobi_promo,test_util_of:access_code(?MODULE, ?sport_promo, 
						       ?Dyn_link_main_page_promo
						      )).

-define(code_blagues_mobi, test_util_of:access_code(?MODULE, ?sms_blague, 
						    ?Dyn_link_main_page
						    ++ ?Dyn_links_sms)).

-define(code_blagues_mobi_promo, test_util_of:access_code(?MODULE, ?blague_promo, 
							  ?Dyn_link_main_page_promo
							 )).

-define(code_tv_mobi, test_util_of:access_code(?MODULE, ?sms_tv, 
					       ?Dyn_link_main_page
					       ++ ?Dyn_links_sms)).

-define(code_tv_mobi_promo, test_util_of:access_code(?MODULE, ?tv_promo, 
						     ?Dyn_link_main_page_promo
						    )).

-define(code_people_mobi, test_util_of:access_code(?MODULE, ?sms_people, 
						   ?Dyn_link_main_page
						   ++ ?Dyn_links_sms)).

-define(code_people_mobi_promo, test_util_of:access_code(?MODULE, ?people_promo, 
							 ?Dyn_link_main_page_promo
							)).

-define(code_cine_mobi, test_util_of:access_code(?MODULE, ?sms_cine, 
						 ?Dyn_link_main_page
						 ++ ?Dyn_links_sms)).

-define(code_cine_mobi_promo, test_util_of:access_code(?MODULE, ?cine_promo, 
						       ?Dyn_link_main_page_promo
						      )).

-define(code_loto_mobi, test_util_of:access_code(?MODULE, ?sms_loto, 
						 ?Dyn_link_main_page
						 ++ ?Dyn_links_sms)).

-define(code_loto_mobi_promo, test_util_of:access_code(?MODULE, ?loto_promo, 
						       ?Dyn_link_main_page_promo
						      )).

-define(code_quinte_mobi, test_util_of:access_code(?MODULE, ?sms_quinte, 
						   ?Dyn_link_main_page
						   ++ ?Dyn_links_sms)).

-define(code_quinte_mobi_promo, test_util_of:access_code(?MODULE, ?quinte_promo, 
							 ?Dyn_link_main_page_promo
							)).

-define(code_modif_resil_mobi_blocked, test_util_of:access_code(?MODULE, ?sms_modif_resil, 
								?Dyn_link_main_page++
								[
								 ?sms_blague
								]
							       )).
pages()->
    [?options_SMS_MMS_infos, ?suite_to_promo, ?sms_infos, ?sms_infos_suite, ?sms_infos_promo, ?sms_infos_suite_promo, ?mmsinfos_promo, ?mms_infos_suite_promo, ?mmsinfos_video, ?mmsinfos_video_promo, ?mmsinfos, ?mms_infos_suite].

parent(?options_SMS_MMS_infos)->
    test_123_mobi_bons_plans_vos_messages;
parent(_) ->
    ?MODULE.

links(?options_SMS_MMS_infos)->
    [
     {?suite_to_promo, dyn},
     {?sms_infos, static},
     {?orange_ligue1, static},
     {?mmsinfos, static},
     {?mmsinfos_video, static}
    ];
links(?suite_to_promo)->
    [
     {?sms_infos_promo, static},
     {?orange_ligue1_promo, static},
     {?mmsinfos_promo, static},
     {?mmsinfos_video_promo, static}
    ];
links(?sms_infos)->
    [
     {?sms_meteo, dyn},
     {?sms_horoscope, dyn},
     {?sms_actu, dyn},
     {?sms_sport, dyn},
     {?sms_blague, dyn},
     {?sms_infos_suite, static},
     {?sms_plus_infos, static}
    ];
links(?sms_infos_suite)->
    [
     {?sms_tv, static},
     {?sms_people, static},
     {?sms_cine, static},
     {?sms_loto, static},
     {?sms_quinte, static},
     {?sms_modif_resil, static},
     {?sms_plus_infos_suite, static}
    ];
links(?sms_infos_promo)->
    [
     {?meteo_promo, static},
     {?horoscope_promo, static},
     {?actu_promo, static},
     {?sport_promo, static},
     {?blague_promo, static},
     {?sms_infos_suite_promo, static}
    ];
links(?sms_infos_suite_promo)->
    [
     {?tv_promo, static},
     {?people_promo, static},
     {?cine_promo, static},
     {?loto_promo, static},
     {?quinte_promo, static}
    ];
links(?mmsinfos)->
    [
     {?mms_meteo, dyn},
     {?mms_horoscope, dyn},
     {?mms_actu, dyn},
     {?mms_ligue1, dyn},
     {?mms_people, dyn},
     {?mms_infos_suite, static},
     {?mms_plus_infos, static}
    ];
links(?mms_infos_suite)->
    [
     {?mms_cine, dyn},
     {?mms_humour, dyn},
     {?mms_charme, dyn},
     {?mms_plus_infos_suite, static},
     {?mms_modif_resil, static}
    ];
links(?mmsinfos_promo)->
    [
     {?mms_meteo_promo, static},
%     {?mms_horoscope_promo, static},
     {?mms_actu_promo, static},
     {?mms_ligue1_promo, static},
     {?mms_people_promo, static},
     {?mms_infos_suite_promo, static}
    ];
links(?mms_infos_suite_promo)->
    [
     {?mms_cine_promo, static},
     {?mms_humour_promo, static},
     {?mms_charme_promo, static}
    ];
links(?mmsinfos_video)->
    [
     {?mms_ligue1_vdo, dyn},
     {?humour_menu, dyn},
     {?coquin_menu, dyn},
     {?mmsv_plus_infos, static},
     {?mmsv_modif_resil, static}
    ];
links(?mmsinfos_video_promo)->
    [
     {?mms_ligue1_vdo_promo, static},
     {?humour_menu_promo, static},
     {?coquin_menu_promo, static}
    ];
links(Else) ->
    io:format("~p : links of this page ~p are not defined~n",[?MODULE, Else]).

%% MOBI
-define(mms_video_menu_script1_mobi,"MMS Video.*Vous souhaitez vous inscrire a la rubrique:.*:Video Orange L1.*2:Video Humour.*3:Video Charme.*4:\\+ d'infos").
-define(mms_menu_script1_mobi,"MMS Video.*Vous souhaitez vous inscrire a la rubrique:.*:Video Orange Ligue 1.*2:Video Humour.*3:Video Charme.*4:\\+ d'infos").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%          CODE FOR MMS/MMS PROMO                               %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(mmsi_mobi,  test_util_of:access_code(?MODULE, ?mmsinfos, 
					     ?Dyn_link_main_page
					    )).

-define(mmsi_mobi_promo,  test_util_of:access_code(?MODULE, ?mmsinfos_promo, 
						   ?Dyn_link_main_page_promo
						  )).

-define(code_mms_meteo_mobi, test_util_of:access_code(?MODULE, ?mms_meteo, 
						      ?Dyn_link_main_page
						      ++ ?Dyn_links_mms)).

-define(code_mms_meteo_mobi_promo, test_util_of:access_code(?MODULE, ?mms_meteo_promo, 
							    ?Dyn_link_main_page_promo
							   )).

-define(code_mms_horo_mobi, test_util_of:access_code(?MODULE, ?mms_horoscope, 
						     ?Dyn_link_main_page
						     ++ ?Dyn_links_mms)).

-define(code_mms_horo_mobi_promo, test_util_of:access_code(?MODULE, ?mms_horoscope_promo, 
							   ?Dyn_link_main_page_promo
							  )).

-define(code_mms_actu_mobi, test_util_of:access_code(?MODULE, ?mms_actu, 
						     ?Dyn_link_main_page
						     ++ ?Dyn_links_mms)).

-define(code_mms_actu_mobi_promo,  test_util_of:access_code(?MODULE, ?mms_actu_promo, 
							    ?Dyn_link_main_page_promo
							   )).
%%ligue1
-define(code_mms_ligue1_mobi, test_util_of:access_code(?MODULE, ?mms_ligue1, 
						       ?Dyn_link_main_page
						       ++ ?Dyn_links_mms)).

-define(code_mms_ligue1_mobi_promo,  test_util_of:access_code(?MODULE, ?mms_ligue1_promo, 
							      ?Dyn_link_main_page_promo
							     )).
%%
-define(code_mms_people_mobi, test_util_of:access_code(?MODULE, ?mms_people, 
						       ?Dyn_link_main_page
						       ++ ?Dyn_links_mms)).

-define(code_mms_people_mobi_promo, test_util_of:access_code(?MODULE, ?mms_people_promo, 
							     ?Dyn_link_main_page_promo
							    )).

-define(code_mms_cine_mobi, test_util_of:access_code(?MODULE, ?mms_cine, 
						     ?Dyn_link_main_page
						     ++ ?Dyn_links_mms)).

-define(code_mms_cine_mobi_promo, test_util_of:access_code(?MODULE, ?mms_cine_promo, 
							   ?Dyn_link_main_page_promo
							  )).

-define(code_mms_humour_mobi, test_util_of:access_code(?MODULE, ?mms_humour, 
						       ?Dyn_link_main_page
						       ++ ?Dyn_links_mms)).

-define(code_mms_humour_mobi_promo, test_util_of:access_code(?MODULE, ?mms_humour_promo, 
							     ?Dyn_link_main_page_promo
							    )).

-define(code_mms_charme_mobi, test_util_of:access_code(?MODULE, ?mms_charme, 
						       ?Dyn_link_main_page
						       ++ ?Dyn_links_mms)).

-define(code_mms_charme_mobi_promo, test_util_of:access_code(?MODULE, ?mms_charme_promo, 
							     ?Dyn_link_main_page_promo
							    )).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%          CODE FOR MMS VIDEO/MMS VIDEO PROMO                   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(mmsv_mobi, test_util_of:access_code(?MODULE, ?mmsinfos_video, 
					    ?Dyn_link_main_page
					   )).

-define(mmsv_mobi_promo, test_util_of:access_code(?MODULE, ?mmsinfos_video_promo, 
						  ?Dyn_link_main_page_promo
						 )).

-define(code_mms_ligue1_vdo, test_util_of:access_code(?MODULE, ?mms_ligue1_vdo, 
						      ?Dyn_link_main_page
						      ++ ?Dyn_links_mmsv)).

-define(code_mms_ligue1_vdo_promo, test_util_of:access_code(?MODULE, ?mms_ligue1_vdo_promo, 
							    ?Dyn_link_main_page_promo
							   )).

-define(code_humour_menu, test_util_of:access_code(?MODULE, ?humour_menu, 
						   ?Dyn_link_main_page
						   ++ ?Dyn_links_mmsv)).

-define(code_humour_menu_promo, test_util_of:access_code(?MODULE, ?humour_menu_promo, 
							 ?Dyn_link_main_page_promo
							)).

-define(code_coquin_menu, test_util_of:access_code(?MODULE, ?coquin_menu, 
						   ?Dyn_link_main_page
						   ++ ?Dyn_links_mmsv)).

-define(code_coquin_menu_promo, test_util_of:access_code(?MODULE, ?coquin_menu_promo, 
							 ?Dyn_link_main_page_promo
							)).

-define(ACCUEIL_CLASSIQUE,"SMS Infos: Vous souhaitez vous inscrire a la rubrique:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport.*5:Blagues.*6:Suite des rubriques.*7:\\+ d'infos").
-define(SUB_MENU,"Vous pouvez a tout moment resilier votre inscription sur le #123#").



-define(back_mmsi_mobi,"92331").
-define(User_mobi, user_mobi).
-define(User_mobi_promo, user_mobi_promo).
-define(User_partial_blocked_mobi, user_partial_blocked_mobi).
-define(User_actu_nationale, user_actu_nationale).

-define(IMSI_mobi, test_util_of:generate_imsi_from_uid(?User_mobi)).
-define(MSISDN_mobi, test_util_of:generate_msisdn_from_uid(?User_mobi) ).
-define(IMSI_partial_blocked_mobi, test_util_of:generate_imsi_from_uid(?User_partial_blocked_mobi)).
-define(MSISDN_partial_blocked_mobi, test_util_of:generate_msisdn_from_uid(?User_partial_blocked_mobi)).
-define(MSISDN_actu_nationale, test_util_of:generate_msisdn_from_uid(?User_actu_nationale)).
-define(IMSI_mobi_promo, test_util_of:generate_imsi_from_uid(?User_mobi_promo)).
-define(MSISDN_mobi_promo, test_util_of:generate_msisdn_from_uid(?User_mobi_promo)).

-define(IMSI_no_profile_mobi,"999000900000001").
-define(MSISDN_no_profile_mobi,"9900000001").
-define(IMSI_all_blocked_mobi,"999000900000012").
-define(MSISDN_all_blocked_mobi,"9900000012").

%-define(OPTIONS_MMS_MOBI, [opt_mms_mensu,opt_smms]). % What is opt_smms ?
-define(OPTIONS_MMS_MOBI, [opt_mms_mensu]).
%-define(OPTIONS_MMS_MOBI, [opt_vacances,opt_mms_mensu]).
-define(OPTIONS_MSN_MOBI, [opt_msn_mensu_mobi,opt_msn_journee_mobi]).
-define(OPTIONS_INFO_VIDEO_MOBI, [mms_infos,mms_video]).
-define(ALL_OPTIONS_MOBI, ?OPTIONS_MMS_MOBI ++
	?OPTIONS_MSN_MOBI ++ ?OPTIONS_INFO_VIDEO_MOBI).

-define(ACCUEIL,"Se divertir, s'informer, connaitre la meteo...Orange vous offre votre premiere rubrique MMS ou MMS pendant 30 jours \\(hors MMS Ligue 1 Orange\\)..*1:Suite").
-define(ACCUEIL_POST,"MMS&MMS Infos.*Recevez des infos quotidiennes par MMS sur votre mobile.*1:MMS Infos.*2:MMS Orange Ligue 1.*3:MMS Infos.*4:MMS Infos video").
-define(CMO_INSCRIPTION,"Vous pouvez a tout moment resilier votre inscription sur le #123#.").
-define(MOBI_INSCRIPTION,"Vous pouvez a tout moment resilier votre inscription en appelant le 733 \\(0,37EUR/min\\) ou en navigant sur le #123#.").
-define(POSTPAID_INSCRIPTION,"Vous pouvez a tout moment resilier votre inscription sur le #123#.").


-define(POSSUM_ENV_VARS, [{pservices_orangef, commercial_date}]).
-define(PATH, "lib/pfront_orangef/test/webservices/postpaid_cmo/").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    %% No unit tests.
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    rpc:call(possum@localhost, fake_sms_mms_infos_smi, start, []),
    test_util_of:online(?MODULE,mmsinfo()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Tests.

%% +type mmsinfo() -> service_test().

mmsinfo() ->
    [{title,"Test du pilotage de l'option MMS Info."}] ++

        %%Connection to the USSD simulator (smppasn by default)
    	profile_manager:create_default(?User_mobi,"mobi")++
    	profile_manager:init(?User_mobi)++

             %%Test construction
             %%Test Menu/souscription Classique%
 	mmsinfo_mobi_mms()++
     	mmsinfo_mobi_mms_v()++
     	smsinfo_mobi()++

           %%Test Menu/souscription PROMO
	profile_manager:create_default(?User_mobi_promo,"mobi")++
        profile_manager:init(?User_mobi_promo)++

	menu_promo()++
 	mmsinfo_mobi_mms_promo()++
   	mmsinfo_mobi_promo_mms_v()++
   	smsinfo_mobi_promo()++


        profile_manager:create_default(?User_partial_blocked_mobi,"mobi")++
        profile_manager:init(?User_partial_blocked_mobi)++
         %% Test Resiliation

    	mmsinfo_mobi_modif_resil_mms()++
    	mmsinfo_mobi_modif_resil_mms_v()++
    	smsinfo_mobi_modif_resil_sms()++
	

	%%Session closing
	test_util_of:close_session() ++

	["Test reussi"] ++

        [].
   	
smsinfo_mobi()->
    [ "Test du pilotage de l'option SMS Info; Clients Mobicarte" ] ++

	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
 	menu_sms(?MSISDN_mobi,?IMSI_mobi,?smsi_mobi,?SUB_MENU,?ACCUEIL_CLASSIQUE) ++
  	meteo_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_meteo_mobi) ++
 	horoscope_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_horo_mobi) ++
    	actu_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_actu_mobi) ++
    	sport_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_sport_mobi)++
    	blagues_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_blagues_mobi)++ 
      	tv_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_tv_mobi) ++
      	people_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_people_mobi) ++
     	cine_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_cine_mobi) ++
      	loto_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_loto_mobi) ++
     	quinte_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_quinte_mobi) ++
     	ligue1_mobi_sms(?MSISDN_mobi,?IMSI_mobi,?code_ligue1_mobi) ++
	test_util_of:close_session() ++
       	[].


smsinfo_mobi_promo()->

    [ "Test du pilotage de l'option SMS Infos; Clients MOBI:CAS PROMOTIONNEL" ] ++
 	menu_promo_sms(?MSISDN_mobi,?IMSI_mobi,?smsi_mobi_promo,?SUB_MENU,?ACCUEIL_CLASSIQUE) ++
 	meteo_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_meteo_mobi_promo) ++
 	horoscope_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_horo_mobi_promo) ++
 	actu_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_actu_mobi_promo) ++
 	sport_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_sport_mobi_promo)++
 	blagues_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_blagues_mobi_promo)++
 	tv_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_tv_mobi_promo) ++
 	people_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_people_mobi_promo) ++
 	cine_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_cine_mobi_promo) ++
 	loto_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi, ?code_loto_mobi_promo) ++
 	quinte_mobi_promo_sms(?MSISDN_mobi,?IMSI_mobi,?code_quinte_mobi_promo) ++
	test_util_of:close_session() ++
	[].


mmsinfo_mobi_mms()->
    [ "Test du pilotage de l'option MMS Info; Clients Mobicarte" ] ++

	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
 	menu_mms(?MSISDN_mobi,?IMSI_mobi,?mmsi_mobi,?SUB_MENU,?ACCUEIL_CLASSIQUE) ++
   	meteo_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_meteo_mobi) ++
%    	horoscope_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_horo_mobi) ++
   	actu_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_actu_mobi) ++
    	ligue1_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_ligue1_mobi) ++
     	people_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_people_mobi) ++
   %% 	tv_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?mmsi_mobi) ++ 
     	cinema_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_cine_mobi) ++
     	humour_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_humour_mobi) ++
     	charme_mms_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_charme_mobi) ++
 	test_util_of:close_session() ++
	[].
menu_promo()->
     [
     {title, "Option MMS Info: Test du menu"},
     "Aucune option MMS active pour ce client"]++
        %% aucune option d'activer par defaut
        [{erlang_no_trace,
          [
           {net_adm, ping,[possum@localhost]},
           {rpc, call, [possum@localhost,ets,
                        insert,[smsinfos,{?MSISDN_mobi_promo,"T",[]}]]}
          ]}]++
    [{ussd2,
      [{send, test_util_of:access_code(parent(?options_SMS_MMS_infos), ?options_SMS_MMS_infos,
				       ?Dyn_link_main_page_promo
				      )},
       {expect, "Se divertir, s'informer, connaitre la meteo... Orange vous offre votre premiere rubrique SMS ou MMS pendant 30 jours \\(hors SMS Orange L1\\).*1:Suite.*"}
      ]
     }
    ]++
	[].
mmsinfo_mobi_mms_promo()->
    [ "Test du pilotage de l'option MMS Info; Clients Mobicarte" ] ++
	
	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
  	menu_mms_promo(?MSISDN_mobi,?IMSI_mobi,?mmsi_mobi_promo) ++
    	meteo_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_meteo_mobi_promo) ++
 %   	horoscope_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_horo_mobi_promo) ++
    	actu_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_actu_mobi_promo) ++
     	ligue1_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_ligue1_mobi_promo) ++
   	people_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_people_mobi_promo) ++
     	cinema_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_cine_mobi_promo) ++
     	humour_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_humour_mobi_promo) ++
    	charme_mms_mobi_promo(?MSISDN_mobi,?IMSI_mobi,?code_mms_charme_mobi_promo) ++
	test_util_of:close_session() ++
	[].

mmsinfo_mobi_modif_resil_mms()->
    [ "Test du pilotage de RESILIATION d option MMS" ] ++

	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
   	modif_resil_mms(?MSISDN_mobi_promo,?IMSI_mobi_promo,?mmsi_mobi,?MOBI_INSCRIPTION,?ACCUEIL) ++
   	%%modif_horoscope_mms(?MSISDN_mobi_promo,?IMSI_mobi_promo,?mmsi_mobi,?MOBI_INSCRIPTION,?ACCUEIL) ++
	test_util_of:close_session() ++
	[].


smsinfo_mobi_modif_resil_sms()->
    [ "Test du pilotage de RESILIATION d option SMS METEO" ] ++
	modif_resil_meteo_sms(?MSISDN_mobi_promo,?IMSI_mobi_promo, ?code_modif_resil_mobi_blocked, ?MOBI_INSCRIPTION,?ACCUEIL) ++
	[ "Test du pilotage de RESILIATION d option SMS HOROSCOPE" ] ++
   	modif_resil_horoscope_sms(?MSISDN_mobi_promo,?IMSI_mobi_promo, ?code_modif_resil_mobi_blocked, ?MOBI_INSCRIPTION,?ACCUEIL) ++
	[ "Test du pilotage de RESILIATION d option SMS ACTUALITE" ] ++
   	modif_resil_actu_locale_sms(?MSISDN_mobi_promo,?IMSI_mobi_promo, ?code_modif_resil_mobi_blocked, ?MOBI_INSCRIPTION,?ACCUEIL) ++
	test_util_of:close_session() ++
	[].



mmsinfo_mobi_mms_v()->
    [ "Test du pilotage de l'option MMS Info; Clients Mobicarte" ] ++

	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
   	menu_classique_mms_video(?MSISDN_mobi_promo,?IMSI_mobi_promo,?mmsv_mobi,?MOBI_INSCRIPTION,?ACCUEIL) ++
	ligue1_mobi(?MSISDN_mobi,?IMSI_mobi,?code_mms_ligue1_vdo) ++
	humour_mobi(?MSISDN_mobi,?IMSI_mobi,?code_humour_menu) ++
    	charme_mobi(?MSISDN_mobi,?IMSI_mobi,?code_coquin_menu) ++
	test_util_of:close_session() ++
	[].

mmsinfo_mobi_promo_mms_v()->
    [ "Test du pilotage de l'option MMS VIDEOS; Clients Mobicarte" ] ++

	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++

 	[ "Test du pilotage de l'option MMS Infos; Clients MOBI:CAS PROMOTIONNEL" ] ++
 	menu_promo_mms_video(?MSISDN_mobi_promo,?IMSI_mobi_promo,?mmsv_mobi_promo,?MOBI_INSCRIPTION,?ACCUEIL) ++
	ligue1_mobi_promo(?MSISDN_mobi_promo,?IMSI_mobi_promo,?code_mms_ligue1_vdo_promo) ++
    	humour_mobi_promo(?MSISDN_mobi_promo,?IMSI_mobi_promo,?code_humour_menu_promo) ++
     	charme_mobi_promo(?MSISDN_mobi_promo,?IMSI_mobi_promo,?code_coquin_menu_promo) ++
	test_util_of:close_session() ++
	[].

mmsinfo_mobi_modif_resil_mms_v()->
    [ "Test du pilotage de RESILIATION d option MMS VIDEOS" ] ++

	test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
   	modif_resil_mms_v(?MSISDN_mobi_promo,?IMSI_mobi_promo,?mmsv_mobi,?MOBI_INSCRIPTION,?ACCUEIL) ++
	test_util_of:close_session() ++
	[].



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type init_parameters() -> service_test().

%% init_parameters() ->
%%     [
%%      %% Parameters for ptester.
%%      %% Variables (substituted in the send/expect pairs below).
%%      %% Client identity.
%%      {var, "msisdn", ?MSISDN_mobi},
%%      {var, "imsi", ?IMSI_mobi},
%%      {var, "imei","100008XXXXXXX1"}
%%     ].
%% init_ptester_var(IMSI) ->
%%     [{msaddr, {subscriber_number, private, IMSI}},
%%      {var, "imsi", IMSI},
%%      {var, "msisdn", ?MSISDN_mobi},
%%      {var, "imsi", ?IMSI_mobi},
%%      {var, "imei","100008XXXXXXX1"}
%%     ].



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type menu_promo() -> service_test().
menu_promo_mms_video(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option MMS Info VIDEO: test du menu promotionnel"},
	 "Aucune option MMS active pour ce client"]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ {send, CODE++"#"},
	    {expect,?mms_menu_script1_mobi},
	    {send, "1"},
	    {expect, "Retrouvez en images l'actu L1 et en video la .*belle action de chaque journee de L1.*Ce service est gratuit 30j.*"},
	    {send, "82"},
	    {expect, "Recevez tous les jours votre video humour.*Ce service est gratuit .*"},	   	  
	    {send, "83"},
	    {expect, "Recevez tous les jours votre video coquine.* Ce service est gratuit *."}
	   ]}]++
	[].

menu_classique_mms_video(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option MMS Info VIDEO: test du menu classique"},
	 "Aucune option MMS active pour ce client"]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ {send, CODE++"#"},
	    {expect,?mms_menu_script1_mobi},
	    {send, "1"},
	    {expect, "Retrouvez en images l'actu L1 et en video la plus belle action de chaque journee de L1.*"},
	    {send, "82"},
	    {expect, "Recevez tous les jours votre video humour.*Cette option vous sera"},	   	  
	    {send, "83"},
	    {expect, "Recevez tous les jours votre video coquine. Ce service vous sera"}
	   ]}]++
	[].

meteo_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info METEO"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "Meteo.*Decouvrez en images la meteo de la semaine et du week-end. Cette option vous sera.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Meteo a bien ete prise en compte"}
       ]}
    ].

horoscope_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Horo"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "Horoscope.*Du lundi au vendredi retrouvez vos previsions astrologiques completes.*1:feminin.*2:masculin"},
	{send,"1"},
	{expect, "Veuillez preciser votre date de naissance au format jjmm..*Par exemple 2202"},
	{send,"1313"},
	{expect, "Nous n'avons pas compris votre reponse..*Veuillez repondre en respectant le format suivant"},
	{send,"1305"},
	{expect, "Vous avez choisi de recevoir l'Horoscope feminin pour le signe TAUREAU"}
       ]}

    ].

actu_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info ACTU"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "Actualite.*Decouvrez 5 jours par semaine le journal de l'info en images. Cette option vous sera facturee.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Actualites a bien ete prise en compte"}
       ]}

    ].

ligue1_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Ligue 1"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "Avec Orange Ligue 1 suivez en images toute l'actualite du football.*Cette option vous sera facturee.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Orange Ligue 1 a bien ete prise en compte"}
       ]}

    ].

people_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info People"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "People:.*Suivez 5 jours par semaine et en images l'actu des stars et les derniers potins. Cette option.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos People a bien ete prise en compte"}
       ]}

    ].


tv_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info TV"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "TV:.*Decouvrez votre programme TV de la soiree en images tous les jours de la semaine.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Programme TV a bien ete prise en compte"}
       ]}

    ].

cinema_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info CINEMA"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "Cinema..*Decouvrez en images les sorties de la semaine et notre coup de coeur Cette option vous sera facturee.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Cinema a bien ete prise en compte"}
       ]}

    ].



humour_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Humour"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Humour.*5 MMS par semaine pour un mix de BD, de blagues et d'images insolites.*Cette option vous sera facturee.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Humour a bien ete prise en compte"}
       ]}

    ].


charme_mms_mobi(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Charme"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Charme.*5 jours par semaine recevez des images coquines. Ce service est interdit aux moins de 18 ans. Il vous sera facturee.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Charme a bien ete prise en compte"}
       ]}

    ].

menu_mms_promo(MSISDN,IMSI,CODE) ->
%    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    [
     {title, "Option MMS Info: Test du menu PROMO"},
     "Aucune option MMS active pour ce client"]++
        %% aucune option d'activer par defaut
        [{erlang_no_trace,
          [
           {net_adm, ping,[possum@localhost]},
           {rpc, call, [possum@localhost,ets,
                        insert,[mmsinfos,{MSISDN,"T",[]}]]}
          ]}]++
        %% CAS Aucune RUBRIQUE
        [{ussd2,
         [
           {send, CODE++"#"},
           {expect,"MMS.*Vous souhaitez vous inscrire a la rubrique:.*1:Meteo.*2:Actualites.*3:Orange Ligue 1.*4:People.*5:Suite.*6:\\+ d'infos"},
           {send, "5"},
           {expect,"Suite de la liste des rubriques MMS Infos :.*1:Cinema.*2:Humour.*3:Charme.*4:\\+ d'infos"},
           {send, "411"},
           {expect, "L'inscription est mensuelle. Vous pouvez resilier a tout moment sur le #123#. La resiliation sera immediate,mais le mois en cours sera entierement facture"}
          ]}].

meteo_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info METEO PROMO"},
     {ussd2,
      [
	{send, CODE ++ "#"},
	{expect, "Meteo.*Decouvrez en images la meteo de la semaine et du week-end. Cette option est gratuite pendant 30 jours.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Meteo a bien ete prise en compte"}
       ]}
    ].

horoscope_mms_mobi_promo(MSISDN,IMSI,CODE) ->
      [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Horo"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Horoscope.*Du lundi au vendredi retrouvez vos previsions astrologiques completes.*1:feminin.*2:masculin"},
	{send,"1"},
	{expect, "Veuillez preciser votre date de naissance au format jjmm..*Par exemple 2202"},
	{send,"1313"},
	{expect, "Nous n'avons pas compris votre reponse..*Veuillez repondre en respectant le format suivant"},
	{send,"1305"},
	{expect, "Vous avez choisi de recevoir l'Horoscope feminin pour le signe TAUREAU"}
       ]}

    ].
 
actu_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info ACTU PROMO"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Actualite.* Cette option est gratuite pendant 30 jours.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Actualites a bien ete prise en compte"}
       ]}

    ].


ligue1_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Ligue 1 PROMO"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Avec Orange Ligue 1.*Cette option est gratuite pendant 30 jours.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Orange Ligue 1 a bien ete prise en compte"}
       ]}

    ].

people_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info People PROMO "},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "People.*Cette option est gratuite pendant 30j.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos People a bien ete prise en compte"}
       ]}

    ].

cinema_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info CINEMA PROMO"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Cinema..*Cette option est gratuite.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Cinema a bien ete prise en compte"}
       ]}

    ].

humour_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Humour PROMO "},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Humour.*Cette option est gratuite.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Humour a bien ete prise en compte"}
       ]}

    ].

charme_mms_mobi_promo(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option MMS Info Charme PROMO"},
     {ussd2,
      [
        {send, CODE ++ "#"},
	{expect, "Charme.* Cette option est gratuite.*"},
	{send,"1"},
	{expect,"Votre inscription a MMS infos Charme a bien ete prise en compte"}
       ]}

    ].

modif_resil_mms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option MMS Info: RESILIATION"}]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ 
	    {send, CODE},
	    {expect, ".*"},
	    {send, "2"},
	    {expect, "3:Modif/Resiliations.*"},
	    {send, "3"},
            {expect, "1:Modifier les parametres de l'horoscope.*2:Resilier une rubrique.*"},
	    {send, "2"},
            {expect, "1:Meteo.*2:Horo.*3:Orange Ligue 1.*4:People.*5:Cinema.*6:Suite.*"},
	    {send, "6"},
	    {expect,"1:Charme"}
	    ]}]++
	[].



modif_resil_meteo_sms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option SMS Info: MODIF/RESIL METEO"}]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ {send, CODE},
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "1"},
	    {expect, "Vous etes actuellement abonne a la rubrique Meteo pour le departement 29.*"},
	    {send, "1"},
	    {expect, "Pour modifier votre abonnement au service SMS Meteo veuillez saisir les 2 chiffres du departement de votre ville"},
	    {send, "2131"},
	    {expect, "Nous n'avons pas compris votre demande.*"},
	    {send, "75"},
	    {expect, "Votre abonnement a SMS infos Meteo 75 a bien ete pris en compte.*"}
	    ]}]++

	[{ussd2,
	  [ {send, CODE },
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "1"},
	    {expect, "Vous etes actuellement abonne a la rubrique Meteo pour le departement 29.*"},
	    {send, "2"},
	    {expect, "Votre resiliation a bien ete prise en compte.*"}
	    ]}]++

	[].



modif_resil_horoscope_sms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option SMS Info: MODIF/RESIL HOROSCOPE "}]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ {send, CODE },
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "2"},
	    {expect, "Vous etes actuellement abonne a la rubrique Horoscope pour le signe.*LION.*"},
	    {send, "1"},
	    {expect, "Pour modifier votre signe astrologique"},
	    {send, "2131"},
	    {expect, "Nous n'avons pas compris votre demande.*"},
	    {send, "1304"},
	    {expect, "Votre abonnement a SMS infos Horoscope BELIER a bien ete pris en compte.*"}
	    ]}]++

	[{ussd2,
	  [ {send, CODE },
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "2"},
	    {expect, "Vous etes actuellement abonne a la rubrique Horoscope pour le signe.*LION.*"},
	    {send, "2"},
	    {expect, "Votre resiliation a bien ete prise en compte.*"}
	    ]}]++

	[].



modif_resil_actu_locale_sms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option SMS Info:MODIF/RESIL ACTU "}]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++

	%% Modification de code
	[{ussd2,
	  [ {send, CODE },
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "3"},
	    {expect, "Vous etes actuellement abonne a la rubrique Actu generale et Actu Saone-et-Loire.*"},
	    {send, "1"},
	    {expect, "Pour modifier votre abonnement au service SMS Actu .*"},
	    {send, "2131"},
	    {expect, "Nous n'avons pas compris votre demande.*"},
	    {send, "29"},
	    {expect, "Votre abonnement a SMS infos Actualites Fini.*"}
	    ]}]++
	%% Resiliation
	[{ussd2,
	  [ {send, CODE },
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "3"},
	    {expect, "Vous etes actuellement abonne a la rubrique Actu generale et Actu Saone-et-Loire.*"},
	    {send, "2"},
% 	    {expect, "Vous souhaitez resilier votre abonnement a la rubrique actualite.*"
% 	     "Cette resiliation sera immediate mais le mois en cours sera entierement facture"},
% 	    {send, "1"},
	    {expect, "Votre resiliation a bien ete prise en compte.*"
	     "1:Pour souscrire a une autre rubrique.*"}
	    ]}]++

	ano_actu_nationale(CODE) ++
	[].

ano_actu_nationale(CODE) ->
	[
	 {title, "Option SMS Info:MODIF/RESIL ACTU nationale seule"}]++
	profile_manager:create_default(?User_actu_nationale,"mobi")++
	profile_manager:init(?User_actu_nationale)++
 	[{erlang_no_trace, 
 	  [
 	   {net_adm, ping,[possum@localhost]},
 	   {rpc, call, [possum@localhost,ets,
 			insert,[mmsinfos,{?MSISDN_actu_nationale,"T",[]}]]}
 	  ]}]++
	[{ussd2,
	  [ {send, CODE },
	    {expect,"Vous etes actuellement abonne aux rubriques suivantes:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport"},
	    {send, "3"},
	    {expect, "Vous etes actuellement abonne a la rubrique Actu generale et Actu nationale seule.*"},
	    {send, "2"},
% 	    {expect, "Vous souhaitez resilier votre abonnement a la rubrique actualite.*"
% 	     "Cette resiliation sera immediate mais le mois en cours sera entierement facture"},
% 	    {send, "1"},
	    {expect, "Votre resiliation a bien ete prise en compte.*"
	     "1:Pour souscrire a une autre rubrique.*"}
	    ]}].


modif_horoscope_mms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option MMS Infos : MODIF HOROSCOPE"}]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ {send, CODE++"*5*3#"},
	    {expect, "Vous souhaitez.*1:Modifier les parametres de l'horoscope"},
	    {send, "1"},
	    {expect, "Vous recevez .* pour le signe .*Vous souhaitez recevoir l'horoscope.*1:feminin.*2:masculin"},
	    {send, "1"},
	    {expect, "Veuillez preciser votre date de naissance au format.*"},
	    {send,"1313"},
	    {expect, "Nous n'avons pas compris votre reponse..*Veuillez repondre en respectant le format suivant"},
	    {send,"1305"},
	    {expect, "Vous avez choisi de recevoir l'Horoscope feminin pour le signe TAUREAU"}

	    ]}]++
	[].






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%        TEST MMS VIDEO                             %%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ligue1_mobi(MSISDN,IMSI,CODE) ->
    [ {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MMS Info Ligue1"},
     {ussd2,
      [ {send, CODE++"*1#"},
	{expect,"Votre inscription a MMS infos Video Orange Ligue 1 a bien ete prise en compte"}
	]}

    ].

%% +type meteo_mobi_no_promo() -> service_test().
ligue1_mobi_promo(MSISDN,IMSI,CODE) ->
    [ {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MMS Info Promo Ligue1"},
     {ussd2,
      [ {send, CODE++"*1#"},
	{expect,"Votre inscription a MMS infos Video Orange Ligue 1 a bien ete prise en compte"}
	]}

    ].
charme_mobi(MSISDN,IMSI,CODE) ->
   [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI MMS Infos VIdeos Coquine "},
     {ussd2,
      [ {send, CODE++"*1#"},
	{expect,"Votre inscription a MMS infos Video Charme a bien ete prise en compte"}
      ]}] ++

	test_util_of:close_session().


charme_mobi_promo(MSISDN,IMSI,CODE) ->
   [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI MMS Infos Promo VIdeos Coquine "},
     {ussd2,
      [ {send, CODE++"*1#"},
	{expect,"Votre inscription a MMS infos Video Charme a bien ete prise en compte"}
      ]}] ++

	test_util_of:close_session().

humour_mobi(MSISDN,IMSI,CODE) ->
   [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI MMS Infos Videos Humour "},
     {ussd2,
      [ {send, CODE++"*1#"},
	{expect,"Votre inscription a MMS infos Video Humour a bien ete prise en compte"}
      ]}] ++

	test_util_of:close_session().


humour_mobi_promo(MSISDN,IMSI,CODE) ->
   [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[mmsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI MMS Infos Promo Videos Humour "},
     {ussd2,
      [ {send, CODE++"*1#"},
	{expect,"Votre inscription a MMS infos Video Humour a bien ete prise en compte"}
      ]}] ++

	test_util_of:close_session().


modif_resil_mms_v(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
    test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
    test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
	[
	 {title, "Option MMS Info VIDEOS: Avec Opt Actives"}]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[mmsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	  [ {send, CODE++"#"},
	    {expect,"3:Modif.*Resil"},
	    {send, "3"},
	    {expect, "resilier.*1:Video Orange Ligue 1.*2:Video Charme.*"},
	    {send, "1"},
	    {expect, "Vous avez choisi de resilier votre abonnement a MMS Infos Video Orange Ligue 1 .*"} ,
	    {send, "1"},
	    {expect, "Votre resiliation a MMS Infos Video Orange Ligue 1 a bien ete pris en compte.*"}
	    ]}]++
	[].





%% +type menu() -> service_test().
menu_sms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
     test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_ssms]),
     [
     {title, "Option SMS Info: Test du menu"},
     "Aucune option SMS active pour ce client"]++
	%% aucune option d'activer par défaut
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[smsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% CAS Aucune RUBRIQUE
	[{ussd2,
	 [ 
 	   {send, CODE++"#"},
 	   {expect,"SMS Infos: Vous souhaitez vous inscrire a la rubrique:.*1:Meteo.*2:Horoscope.*3:Actualites.*4:Sport.*5:Blagues.*6:Suite des rubriques.*7:\\+ d'infos"},
	   {send, "6"}, %% added
	   {expect, "2:People.*"}, %% added
	   {send, "2"}, %% added
           {expect, "People.*1:Confirmez"},
	   {send, "1"}, %% added
           {expect, "Votre abonnement a SMS infos People a bien ete pris en compte.*"},	   
	   {send, "887"},
	   {expect, "SMS Infos: Pour recevoir directement sur votre mobile l'essentiel de l'info qui vous interesse...*Suite"},
	   {send, "1"},
	   {expect, "Les conditions legales sont disponibles sur le site www.orange.fr ou aupres de votre service clients.*Suite"},
	   {send, "1"},
	   {expect, SUB_EXPECTED}
	  ]}].


%% +type menu() -> service_test().
menu_mms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
     test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_smms]),
     [
     {title, "Option MMS Info: Test du menu"},
     "Aucune option MMS active pour ce client"]++
	%% aucune option d'activer par defaut
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[smsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% CAS Aucune RUBRIQUE
%	asmserv_init("+"++?MSISDN_mobi, "NOACT")++
	[{ussd2,
	 [ 
 	   {send, CODE++"#"},
 	   {expect,"MMS.*Vous souhaitez vous inscrire a la rubrique:.*1:Meteo.*2:Actualites.*3:Orange Ligue 1.*4:People.*5:Suite.*6:\\+ d'infos"},
	   {send, "5"},
	   {expect,"Suite de la liste des rubriques MMS Infos :.*1:Cinema.*2:Humour.*3:Charme.*4:\\+ d'infos"},
	   {send, "411"},
	   {expect, "L'inscription est mensuelle. Vous pouvez resilier a tout moment sur le #123#. La resiliation sera immediate,mais le mois en cours sera entierement facture"}
	  ]}].

meteo_mobi_sms(MSISDN,IMSI,CODE) ->
    [ {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option SMS Info Meteo"},
     {ussd2,
      [ {send, CODE ++ "#"},
	{expect,"Meteo.*Recevez par SMS tous les apres-midi les previsions meteo du lendemain pour .* euros par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Pour vous inscrire au service SMS Meteo veuillez saisir les 2 chiffres du departement de votre ville. Tapez 8 pour revenir a la page precedente."},
	{send, "91"},
	{expect,"Votre abonnement a SMS infos Meteo 91 a bien ete pris en compte."}
	]},

{ussd2,
      [ {send, CODE ++ "#"},
	{expect,"Meteo.*Recevez par SMS tous les apres-midi les previsions meteo du lendemain pour .* euros par mois.*1:Confirmez"},
	{send, "1"},
	{expect,"Pour vous inscrire au service SMS Meteo veuillez saisir les 2 chiffres du departement de votre ville. Tapez 8 pour revenir a la page precedente."},
	{send, "102"},
	{expect,".*Nous n'avons pas compris votre demande.*"},
	{send,"29"},
	{expect,"Votre abonnement a SMS infos Meteo 29 a bien ete pris en compte."}
	]}
    ].



horoscope_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI SMS Info Horoscope"},
     {ussd2,
      [ {send, CODE++"#"},
	{expect,"Horoscope: Recevez par SMS chaque matin votre horoscope du jour.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"2403"},
	{expect,"Votre abonnement a SMS infos Horoscope BELIER a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
	]},
    
     {ussd2,
      [{send, CODE++"#"},
	{expect,"Horoscope: Recevez par SMS chaque matin votre horoscope du jour.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"0109"},
	{expect,"Votre abonnement a SMS infos Horoscope VIERGE a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
	]},
     
   {ussd2,
      [{send, CODE++"#"},
	{expect,"Horoscope: Recevez par SMS chaque matin votre horoscope du jour.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"2104"},
	{expect,"Votre abonnement a SMS infos Horoscope TAUREAU a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
      ]},
     {ussd2,
      [{send, CODE++"#"},
	{expect,"Horoscope: Recevez par SMS chaque matin votre horoscope du jour.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"1407"},
	{expect,"Votre abonnement a SMS infos Horoscope CANCER a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
      ]},
     {ussd2,
      [{send, CODE++"#"},
       {send, "1"},
       {expect,"date de naissance.*jjmm"},
       {send,"23022004"},
       {expect,"Nous n'avons"},
       {send,"2358504"},
       {expect,"Nous n'avons"},
       {send,"2403"},
	{expect,"Votre abonnement a SMS infos Horoscope BELIER a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}

      ]}] ++

	test_util_of:close_session().


actu_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI SMS Info Actualites"},
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Actu: Recevez les dernieres breves d'actualite generale et locale pour .* EUR par mois.*1:Pour recevoir l'actu Generale.*2:Pour recevoir l'actu Generale et Locale"},
	{send,"2"},
	{expect,"Pour vous inscrire au service SMS Actualite veuillez saisir les 2 chiffres de votre departement.*Tapez 8 pour revenir a la page precedente"},
	{send, "75"},
	{expect,"Votre abonnement a SMS infos Actualites Paris a bien ete pris en compte."},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]},

{ussd2,
      [ {send, CODE ++"#"},
	{expect, "Actu: Recevez les dernieres breves d'actualite generale et locale pour .* EUR par mois.*1:Pour recevoir l'actu Generale.*2:Pour recevoir l'actu Generale et Locale"},
	{send, "2"},
	{expect,"Pour vous inscrire au service SMS Actualite veuillez saisir les 2 chiffres de votre departement.*Tapez 8 pour revenir a la page precedente"},
	{send, "607"},
	{expect,".*Nous n'avons pas compris votre demande.*"},
	{send, "75"},
	{expect,"Votre abonnement a SMS infos Actualites Paris a bien ete pris en compte."},
	{send, "1"},
	{expect,?sms_menu_script1_mobi}
	]},

{ussd2,
      [
	{send, CODE ++"#"},
	{expect, "Actu: Recevez les dernieres breves d'actualite generale et locale pour .* EUR par mois.*1:Pour recevoir l'actu Generale.*2:Pour recevoir l'actu Generale et Locale"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Actualites generales a bien ete pris en compte."}
	]}
    ].





sport_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Mobi :Option SMS Info Sport"},
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Sport: Recevez par SMS les dernieres infos sportives, pour .* EUR par mois.*1:Souscrire"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Sport a bien ete pris en compte."},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].




%% +type blagues_mobi() -> service_test().
blagues_mobi_sms(MSISDN,IMSI,CODE) ->
    [ 
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Mobi :Option SMS Info BLAGUES"},
     {ussd2,
      [ 
	{send,CODE ++"#"},
	{expect, "Blagues: Recevez par SMS la blague du jour, pour .* EUR par mois.*1:Souscrire"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Blagues a bien ete pris en compte."}
	]}
    ].

tv_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     {title, "Mobi: Option SMS Info TV"},
     "Test SMS TV: aucune option active",
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Programme TV: Chaque matin le programme de votre soiree sur votre mobile, pour .* par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Programme TV a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].

people_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     {title, "Mobi: Option SMS Info PEOPLE"},
     "Test SMS PEOPLE: aucune option active",
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "People:.*Recevez par SMS tous les potins de vos stars preferees pour .*EUR par mois..*1:Confirmez"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos People a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].


cine_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option SMS Info CINEMA"},
     {ussd2,
      [ {send,CODE ++"#"},
	{expect, "Cinema: Recevez par SMS toute l'actualite.*1:Souscrire"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Cinema a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].

loto_mobi_sms(MSISDN,IMSI,CODE) ->
    [      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option SMS Info LOTO-KENO EUROMILLIONS"},
     {ussd2,
      [{send, CODE ++"#"},
	{expect, "Loto Euromillions Keno:.*Recevez par SMS les resultats de chaque tirage pour .*EUR par mois.*1:Confirmez Loto,Euromillions.*2:Confirmez Keno.*3:Confirmez Loto,Euromillions et Keno"},
	{send,"3"},
	{expect,"Votre abonnement a SMS infos Loto et Keno a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "}

	]}
    ].


%% +type quinte_mobi() -> service_test().
quinte_mobi_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option SMS Info QUINTE"},
     {ussd2,
      [ {send,CODE ++"#"},
	{expect, "Quinte: Recevez les resultats et les rapports de la course du jour, pour .*EUR par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Quinte a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},	
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].



ligue1_mobi_sms(MSISDN,IMSI,CODE) ->
    [ 
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option SMS Info Ligue 1"},
     {ussd2,

      [ {send, CODE++"#"},
	{expect, "OL1: Les options.*1:Resultats.*2:Club"},
	{send,"1"},
	{expect,"Vous recevez le score de tous les matchs de Ligue 1.*1:Confirmez"},
	{send, "1"},
	{expect,"Votre abonnement a SMS infos OL1 Resultats facture .*E par journee de championnat a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une rubrique SMS Infos"}
	]},
     {title, "Option SMS Info Ligue 1 - Caen (CAE)"},
      {ussd2,
      [ {send, CODE++"#"},
	{expect, "OL1: Les options.*1:Resultats.*2:Club"},
	{send,"2"},
	{expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
	{send, "1"},
	{expect,"les trois premieres lettres de la ville de votre Club"},
	{send,"CAE"},
	{expect,"Nous n'avons pas compris votre demande."}
	]},
     {title, "Option SMS Info Ligue 1 - Le Havre (LEH)"},
      {ussd2,
      [ {send, CODE++"#"},
        {expect, "OL1: Les options.*1:Resultats.*2:Club"},
        {send,"2"},
        {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
        {send, "1"},
        {expect,"les trois premieres lettres de la ville de votre Club"},
        {send,"LEH"},
        {expect,"Nous n'avons pas compris votre demande."}
        ]},
      {title, "Option SMS Info Ligue 1 - Nancy (NAN)"},
      {ussd2,
      [ {send, CODE++"#"},
        {expect, "OL1: Les options.*1:Resultats.*2:Club"},
        {send,"2"},
        {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
        {send, "1"},
        {expect,"les trois premieres lettres de la ville de votre Club"},
        {send,"NAN"},
        {expect,"OL1.*Nancy.*pris en compte"}
        ]},
      {title, "Option SMS Info Ligue 1 - Boulogne (BOU)"},
      {ussd2,
      [ {send, CODE++"#"},
        {expect, "OL1: Les options.*1:Resultats.*2:Club"},
        {send,"2"},
        {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
        {send, "1"},
        {expect,"les trois premieres lettres de la ville de votre Club"},
        {send,"BOU"},
        {expect,"OL1.*Boulogne.*pris en compte"}
        ]},
      {title, "Option SMS Info Ligue 1 - Lens (LEN)"},
      {ussd2,
      [ {send, CODE++"#"},
        {expect, "OL1: Les options.*1:Resultats.*2:Club"},
        {send,"2"},
        {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
        {send, "1"},
        {expect,"les trois premieres lettres de la ville de votre Club"},
        {send,"LEN"},
        {expect,"OL1.*Lens.*pris en compte"}
        ]},
      {title, "Option SMS Info Ligue 1 - Monaco (MON)"},
      {ussd2,
      [ {send, CODE++"#"},
        {expect, "OL1: Les options.*1:Resultats.*2:Club"},
        {send,"2"},
        {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
        {send, "1"},
        {expect,"les trois premieres lettres de la ville de votre Club"},
        {send,"MON"},
        {expect,"Tapez 1 si vous souhaitez vous abonner a SMS Infos ligue 1 pour le club de MONTPELLIER.*"
         "Tapez 2 pour le club de MONACO..*"},
        {send,"2"},
        {expect,"OL1.*Monaco.*pris en compte"}
        ]},
      {title, "Option SMS Info Ligue 1 - Montpellier (MON)"},
      {ussd2,
      [ {send, CODE++"#"},
        {expect, "OL1: Les options.*1:Resultats.*2:Club"},
        {send,"2"},
        {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
        {send, "1"},
        {expect,"les trois premieres lettres de la ville de votre Club"},
        {send,"MON"},
	{expect,"Tapez 1 si vous souhaitez vous abonner a SMS Infos ligue 1 pour le club de MONTPELLIER.*"
	 "Tapez 2 pour le club de MONACO..*"},
        {send,"1"},
        {expect,"OL1.*Montpellier.*pris en compte"}
        ]},
      {title, "Option SMS Info Ligue 1 - Montpellier (MOT)"},
       {ussd2,
       [ {send, CODE++"#"},
         {expect, "OL1: Les options.*1:Resultats.*2:Club"},
         {send,"2"},
         {expect,"Vous suivez en direct par SMS l'evolution du score des match.*1:Souscrire"},
         {send, "1"},
         {expect,"les trois premieres lettres de la ville de votre Club"},
         {send,"MOT"},
	 {send, "11"},
         {expect,"SMS Infos: Vous souhaitez vous inscrire a la rubrique"}
         ]}
    ].



menu_promo_sms(MSISDN,IMSI,CODE,SUB_EXPECTED,CHAR) ->
      test_util_of:set_present_period_for_test(commercial_date,[opt_vacances, opt_ssms]),
     test_util_of:set_present_period_for_test(commercial_date, ?ALL_OPTIONS_MOBI) ++
      [
     {title, "Option SMS Info: test du menu promotionnel"},
     "Aucune option SMS active pour ce client"]++
	[{erlang_no_trace, 
	  [
	   {net_adm, ping,[possum@localhost]},
	   {rpc, call, [possum@localhost,ets,
			insert,[smsinfos,{MSISDN,"T",[]}]]}
	  ]}]++
	%% Cas aucune rubrique
	[{ussd2,
	 [ {send, CODE++"#"},
 	   {expect, CHAR},
	   {send, "6"},
	   {expect, "2:People"},
	   {send, "2"},
           {expect, "People.*1:Confirmez"},
	   {send, "1"},
           {expect, "Votre abonnement a SMS infos People.*"},	   
 	   {send, "887"},
 	   {expect,"SMS Infos: Pour recevoir directement sur votre mobile l'essentiel de l'info qui vous interesse"},
   	   {send, "1"},
	   {send, "1"},
	   {expect, SUB_EXPECTED}
	  ]}]++ 
	[].



meteo_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [ {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option SMS Info Meteo PROMO"},
     {ussd2,
      [ {send,CODE++"#" },
	{expect,"Meteo.*Recevez tous les jours les previsions meteo du lendemain. Cette option est gratuite pendant 30j puis vous sera facturee .* Euro par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Pour vous inscrire au service SMS Meteo veuillez saisir les 2 chiffres du departement de votre ville. Tapez 8 pour revenir a la page precedente."},
	{send, "91"},
	{expect,"Votre abonnement a SMS infos Meteo 91 a bien ete pris en compte."}
	]},

    {ussd2,
      [ {send, CODE++"#"},
	{expect,"Meteo.*Recevez tous les jours les previsions meteo du lendemain. Cette option est gratuite pendant 30j puis vous sera facturee .* Euro par mois.*1:Confirmez"},
	{send, "1"},
	{expect,"Pour vous inscrire au service SMS Meteo veuillez saisir les 2 chiffres du departement de votre ville. Tapez 8 pour revenir a la page precedente."},
	{send, "102"},
	{expect,".*Nous n'avons pas compris votre demande.*"},
	{send,"29"},
	{expect,"Votre abonnement a SMS infos Meteo 29 a bien ete pris en compte."}
	]}
    ].


horoscope_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI SMS Info Horoscope"},
     {ussd2,
      [ {send, CODE ++ "#"},
	{expect,"Recevez tous les jours votre horoscope. Cette option sera gratuite pendant 30j puis vous sera facturee .* EUR par mois.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"2403"},
	{expect,"Votre abonnement a SMS infos Horoscope BELIER a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
	]},
    
     {ussd2,
      [{send, CODE++"#"},
	{expect,"Recevez tous les jours votre horoscope. Cette option sera gratuite pendant 30j puis vous sera facturee .* EUR par mois.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"0109"},
	{expect,"Votre abonnement a SMS infos Horoscope VIERGE a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
	]},
     
   {ussd2,
      [{send, CODE++"#"},
	{expect,"Recevez tous les jours votre horoscope. Cette option sera gratuite pendant 30j puis vous sera facturee .* EUR par mois.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"2104"},
	{expect,"Votre abonnement a SMS infos Horoscope TAUREAU a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
      ]},
     {ussd2,
      [{send, CODE++"#"},
	{expect,"Recevez tous les jours votre horoscope. Cette option sera gratuite pendant 30j puis vous sera facturee .* EUR par mois.*1:Confirmez"},
	{send, "1"},
	{expect,"Veuillez preciser votre date de naissance au format jjmm. Par exemple 2202 si vous etes ne\\(e\\) un 22 fevrier..*Tapez 8 pour revenir a la page precedente."},
	{send,"1407"},
	{expect,"Votre abonnement a SMS infos Horoscope CANCER a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"}
      ]},
     {ussd2,
      [{send, CODE++"#"},
       {send, "1"},
       {expect,"date de naissance.*jjmm"},
       {send,"23022004"},
       {expect,"Nous n'avons"},
       {send,"2358504"},
       {expect,"Nous n'avons"},
       {send,"2403"},
       {expect,"Votre abonnement a SMS infos Horoscope BELIER a bien ete pris en compte..*1:Si vous souhaitez vous inscrire a une autre rubrique"},
{send,"1"},
	{expect,?sms_menu_script1_mobi}

      ]}] ++

	test_util_of:close_session().



actu_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Option MOBI SMS Info Actualites"},
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Actualite: Recevez les dernieres breves d'actualite generale et locale. Cette option sera gratuite pendant 30j puis sera facturee .* EUR par mois.*"},
	{send,"1"},
	{send,"2"},
	{expect,"Pour vous inscrire au service SMS Actualite veuillez saisir les 2 chiffres de votre departement.*Tapez 8 pour revenir a la page precedente"},
	{send, "75"},
	{expect,"Votre abonnement a SMS infos Actualites Paris a bien ete pris en compte."},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]},

{ussd2,
      [ {send, CODE ++"#"},
{expect, "Actualite: Recevez les dernieres breves d'actualite generale et locale. Cette option sera gratuite pendant 30j puis sera facturee .* EUR par mois.*"},
	{send,"1"},
	{send, "2"},
	{expect,"Pour vous inscrire au service SMS Actualite veuillez saisir les 2 chiffres de votre departement.*Tapez 8 pour revenir a la page precedente"},
	{send, "607"},
	{expect,".*Nous n'avons pas compris votre demande.*"},
	{send, "75"},
	{expect,"Votre abonnement a SMS infos Actualites Paris a bien ete pris en compte."},
	{send, "1"},
	{expect,?sms_menu_script1_mobi}
	]},

{ussd2,
      [
	{send, CODE ++"#"},
{expect, "Actualite: Recevez les dernieres breves d'actualite generale et locale. Cette option sera gratuite pendant 30j puis sera facturee .* EUR par mois.*"},
	{send,"1"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Actualites generales a bien ete pris en compte."}
	]}
    ].


sport_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Mobi :Option SMS Info Sport"},
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Sport: Recevez les dernieres infos sportives. Cette option sera gratuite pendant 30j puis facturee .* EUR par mois.*1:Souscrire"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Sport a bien ete pris en compte."},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].

blagues_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [ 
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "Mobi :Option SMS Info BLAGUES"},
     {ussd2,
      [ 
	{send,CODE ++"#"},
	{expect, "Blagues: Recevez une blague par jour. Cette option sera gratuite pendant 30j puis facturee .* EUR par mois.*1:Souscrire"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Blagues a bien ete pris en compte."},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].


tv_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     {title, "Mobi: Option SMS Info TV"},
     "Test SMS TV: aucune option active",
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Programme TV: Recevez chaque matin le programme de la soiree. Cette option sera gratuite pendant 30j puis facturee .* Euros par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Programme TV a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].

people_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     {title, "Mobi: Option SMS Info PEOPLE"},
     "Test SMS PEOPLE: aucune option active",
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "People: Recevez tous les potins de vos people preferees. Cette option sera gratuite pendant 30j puis facturee .* EUR par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos People a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].


cine_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option SMS Info CINEMA"},
     {ussd2,
      [ {send,CODE ++"#"},
	{expect, "Cinema: Recevez par SMS toute l'actualite.*1:Souscrire"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Cinema a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].

loto_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option SMS Info LOTO-KENO EUROMILLIONS"},
     {ussd2,
      [{send, CODE ++"#"},
	{expect,"Loto Euromillions Keno: Recevez par SMS les resultats de chaque tirage. Cette option sera gratuite pendant 30j puis facturee .* EUR par mois.*1:Suite"},
        {send,"1"},
        {expect,"Choisissez:.*Confirmez Loto,Euromillions"},
	{send,"3"},
	{expect,"Votre abonnement a SMS infos Loto et Keno a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "}

	]}
    ].

quinte_mobi_promo_sms(MSISDN,IMSI,CODE) ->
    [
      {erlang_no_trace, 
      [
       {net_adm, ping,[possum@localhost]},
       {rpc, call, [possum@localhost,ets,
		    insert,[smsinfos,{MSISDN,"T",[]}]]}
      ]},
     %% test 1 : aucune options active
     {title, "MOBI:Option SMS Info QUINTE"},
     {ussd2,
      [ {send, CODE ++"#"},
	{expect, "Quinte: Recevez les resultats et les rapports de la course du jour. Cette option est gratuite pendant 30j et facturee .* EUR par mois.*1:Confirmez"},
	{send,"1"},
	{expect,"Votre abonnement a SMS infos Quinte a bien ete pris en compte.*1:Si vous souhaitez vous inscrire a une autre rubrique "},	
	{send,"1"},
	{expect,?sms_menu_script1_mobi}
	]}
    ].




