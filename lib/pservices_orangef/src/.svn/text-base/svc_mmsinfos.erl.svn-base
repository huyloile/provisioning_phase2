%%%% generique fonctions USSD for MMSINFOS Services
%%%% Fonction USer for MOBI and CMO.

-module(svc_mmsinfos).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/sms_mms_infos_opt.hrl").
-include("../include/postpaid.hrl").
-include("../../pdist_orangef/include/spider.hrl").

%% XML API 
%%include
-export([
%print_rubrique/3,
	 print_rubrique_en_cours/2]).
%-export([rubrique_prix/2]).
%% redirect

-export([print_horo_signe/1,print_horo_genre/1]).
%% resiliation 

%% export for smsinfos
-export([cast/1]).
-export([print_modification/2, print_modification/3]).
-export([print_rubrique_active/4,print_rubrique_active/5]).
-export([print_rubrique_inactive/4]).
-export([print_menu_opts_resiliation/3]).
-export([subscribe/3]).
-export([print_prix/3]).
-export([descr_rubrique/1]).
-export([redirect_by_SMIlistOptions_status/5]).                       
-export([resil/3]).

%%% HORO
-export([subscribe_horo/2]).
-export([modif_horo/3]).
-export([store_horo_signe/3]).
-export([store_horo_promo_signe/3]).
-export([print_horo_signe_opt_subscribed/1]).
%% IMPORT
-import(svc_util_of,[add_br/1,dec_pcd_urls/1]).


%%%%%%%%%%%%% DYNAMIC LINK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_rubrique_inactive(session(),string(),ULR::string()) -> hlink().
%%%% print link to activate an rubrique


print_rubrique_inactive(abs,Rubrique,URL,Classe)->
    [#hlink{href=URL,contents=[{pcdata,Rubrique}]},br];

print_rubrique_inactive(Session,Rubrique,URL,Classe) 
  when Classe=="video" ->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,String,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS_V),
    case svc_smsinfos:is_active(Id,All_opts) of
	true-> [];
	false->
	    [#hlink{href=URL,contents=[{pcdata,String}]},br]
    end;

print_rubrique_inactive(Session,Rubrique,URL,Classe)->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,String,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS),
    case svc_smsinfos:is_active(Id,All_opts) of
	true->[];
	false->
	    [#hlink{href=URL,contents=[{pcdata,String}]},br]	    
    end.


%% +type print_rubrique_active(session(),string(),Rub_Name::string(),
%%       URL::string()) -> hlink().
%%%% print only active rubrique
print_rubrique_active(abs,Rubrique,URL,Classe)->
    [#hlink{href=URL,contents=[{pcdata,Rubrique}]},br];

print_rubrique_active(Session,Rubrique,URL,Classe) 
  when Classe=="video" ->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,String,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS_V),
    case svc_smsinfos:is_active(Id,All_opts) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,String}]},br];
	false->
	    []
    end;

print_rubrique_active(Session,Rubrique,URL,Classe)->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,String,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS),
    case svc_smsinfos:is_active(Id,All_opts) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,String}]},br];
	false->
	    []
    end.

print_rubrique_active(Session,Rubrique,URL,Classe,Message)->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,String,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS),
    case svc_smsinfos:is_active(Id,All_opts) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,Message}]},br];
	false->
	    []
    end.

%% +type print_rubrique(session(),string(),Rub_Name::string()) -> hlink().
%%%% print only active rubrique
% print_rubrique(abs,Config_Param,Rubrique)->
%     [{pcdata,Rubrique}];
% print_rubrique(Session,Config_Param,Rubrique)->
%     case lists:keysearch(list_to_atom(Rubrique),1,
% 			 pbutil:get_env(pservices_orangef,
% 					list_to_atom(Config_Param))) of
% 	{value,{_,String}}->
% 	    %% print hlink if present
% 	    [{pcdata,String}];
% 	false ->
% 	    slog:event(internal,?MODULE,no_rub_in_print_rubrique),
% 	    []
%     end.

%% +type print_rubrique_en_cours(session(),string()) -> hlink().
%%%% print only active rubrique
print_rubrique_en_cours(abs,Config_Param)->
    [{pcdata,"Rubrique"}];
print_rubrique_en_cours(Session,Config_Param)->
    #mmsinfos{en_cours=Rubrique}=cast(Session),
    case lists:keysearch(Rubrique,1,
			 pbutil:get_env(pservices_orangef,
					list_to_atom(Config_Param))) of
	{value,{_,String}}->
	    %% print hlink if present
	    [{pcdata,String}];
	false ->
	    slog:event(internal,?MODULE,no_rub_in_print_rubrique_en_cours,Rubrique),
	    []
    end.


%% +type descr_rubrique(session())-> [{pcdata,string()}].
descr_rubrique(abs)->
    [{pcdata, "INFOS Rubrique en cours"}];
descr_rubrique(Session)->
    #mmsinfos{en_cours=Rub}=cast(Session),
    #rubrique{descr_rub=Descr}=Rub,
    [{pcdata, lists:flatten(Descr)}].




%% +type print_horo_genre(session())-> [{pcdata,string()}].
print_horo_genre(abs)->
    [{pcdata,"masculin"}];
print_horo_genre(Session)->
    {value,{_,Name,Id}}= lists:keysearch(horoscope,1,?LISTE_OPTS_MMS_INFOS),
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=svc_smsinfos:get_opt_params(Id,All_opts),
    case get_info_horo(Opt_param#sms_mms_option_params.codeCompOption) of
	{ok, SigneHF, {SignDescr,HFDescr}}->
	    [{pcdata, HFDescr}];
	false->
	    slog:event(internal,?MODULE,print_horo_genre_ko,Id),
	    [] 
    end.
     
	
%% +type print_horo_signe(session())-> [{pcdata,string()}].
print_horo_signe(abs)->
    [{pcdata,"Belier"}];
print_horo_signe(Session)->
  {value,{_,Name,Id}}= lists:keysearch(horoscope,1,?LISTE_OPTS_MMS_INFOS),
    #mmsinfos{horoscope=Rubrique}=cast(Session),
    Sign_Value=Rubrique#rubrique.saisie,
    case get_info_horo(Sign_Value) of
	{ok, SigneHF, {SignDescr,HFDescr}}->
	    [{pcdata, SignDescr}];
	false->
	    slog:event(internal,?MODULE,print_horo_signe_ko,Id),
	    [] 
%    end
end.



print_horo_signe_opt_subscribed(Session)->
 {value,{_,Name,Id}}= lists:keysearch(horoscope,1,?LISTE_OPTS_MMS_INFOS),
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=svc_smsinfos:get_opt_params(Id,All_opts),
      case Opt_param#sms_mms_option_params.flagOptionSouscrite of 
 	"1" ->
 	    case get_info_horo(Opt_param#sms_mms_option_params.codeCompOption) of
  		{ok, SigneHF, {SignDescr,HFDescr}}->
  		    [{pcdata, SignDescr}];
  		false->
 		    slog:event(internal,?MODULE,print_horo_signe_ko,Id),
  		    [] 
  	    end
      end.



%% +type get_info_horo(string())-> {ok ,term(), Descr::string()} | string().
get_info_horo(Comp1)->
    case lists:keysearch(to_int(Comp1),3,?LIST_SIGN_MMS) of
	{value,{SigneHF,Descr,Value}}->
	    {ok, SigneHF, Descr} ;
	false->
	    slog:event(internal,?MODULE,get_info_horo_ko,Comp1),
	    [] 
    end.

%% +type to_int(term())-> integer().
to_int(X) when list(X)->
    list_to_integer(X);
to_int(X) when integer(X)->
    X.


%% +type info_signe(atom(),[h | f])-> 
%%         {true,term(),string(),Val::integer()} |
% %%         false.
info_signe(Signe,HF)->
     case lists:keysearch({Signe,HF},1,?LIST_SIGN_MMS) of
 	{value,{SignHF,Descr,Value}}->
 	    %%{value,{{belier,f},{"BELIER","feminin"},1}}}
 	    {true,SignHF,Descr,Value};
 	false->
 	    false 
     end.
  
%%%%%%%%%%%%%%% GENERIC FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type update_session(session(),mmsinfos())-> session().
update_session(#session{prof=#profile{subscription=Sub}}=Session,
	       #mmsinfos{}=MMSINFOS) when Sub=="mobi";Sub=="cmo"->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,State#sdp_user_state{mmsinfos=MMSINFOS});
update_session(#session{prof=#profile{subscription=Sub}}=Session,
	       #mmsinfos{}=MMSINFOS) when Sub=="postpaid"->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,State#postpaid_user_state{mmsinfos=MMSINFOS}).

%% +type cast(session())-> mmsinfos().
cast(#session{prof=#profile{subscription=Sub}}=Session) when Sub=="postpaid"->
    State = svc_util_of:get_user_state(Session),
    case State#postpaid_user_state.mmsinfos of
	#mmsinfos{}=MMS->
	    MMS;
	_->
	    #mmsinfos{}
    end;
cast(#session{}=Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.mmsinfos of
	#mmsinfos{}=MMS->
	    MMS;
	_ ->
	    #mmsinfos{}
    end.

%% +type update_mmsinfos(mmsinfos(),term()) -> mmsinfos().
update_mmsinfos(MMSI,Pairs)->
    L=record_info(fields,mmsinfos),
    pbutil:update_record(L,MMSI,Pairs).

%% +type rubrique(session(),Rub::atom())-> rubrique() | no_field_found.
%%%% get info stored in #rubrique{} from session
rubrique(Session,Rubrique) when atom(Rubrique)->
    SMSI=cast(Session),
    L=record_info(fields,mmsinfos),
    case position(L,Rubrique) of
	I when integer(I)->
	    element(I+1,SMSI);
	_ ->
	    no_field_found
    end.
 
%% +type position(term(),atom())-> integer() | not_found.
position(L,Key)->
    position(L,Key,0).
%% +type position(term(),atom(),integer())-> integer() | not_found.
position([Key|T],Key,I)->
    I+1;
position([H|T],Key,I)->
    position(T,Key,I+1);
position([],_,I) ->
    not_found.



print_prix(abs,_,_)->
    [{pcdata,"XX.XX"}];

print_prix(Id,[],_)->
    slog:event(internal,?MODULE,idoption_not_found,Id),
    "?";
print_prix(Session,Rubrique,Classe) when Classe=="video"->
    {value,{_,_,Id}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS_V),
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    svc_smsinfos:search_price(Id, All_opts);

print_prix(Session,Rubrique,Classe)->
    {value,{_,_,Id}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS),
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    svc_smsinfos:search_price(Id, All_opts).


subscribe(#session{prof=#profile{msisdn=MSISDN}}=Session,Opt, Classe) when Classe=="video"->
    IdCompOption="nul",
    case lists:keysearch(list_to_atom(Opt),1,?LISTE_OPTS_MMS_INFOS_V) of
	{value,{_,Name,IdOption}}-> 
 	     [Status] =sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption),
 	     case Status of 
 	 	"90"-> Rubrique=#rubrique{descr_rub=Name},
 	 	       #mmsinfos{listerubrique=All_opts}=cast(Session),
 	 	       Session2=update_session(Session,#mmsinfos{listerubrique=All_opts,en_cours=Rubrique}),
 	 	       {redirect,Session2,"#success_mms"};
 	 	Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
 	 		 {redirect,Session,"#temporary"}
 	     end;
	_->
	    slog:event(internal,?MODULE, option_not_found, {MSISDN,Opt}),
 	    {redirect,Session,"#temporary"}
    end;


subscribe(#session{prof=#profile{msisdn=MSISDN}}=Session,Opt, Classe)->
    IdCompOption="nul",
    case lists:keysearch(list_to_atom(Opt),1,?LISTE_OPTS_MMS_INFOS) of
	{value,{_,Name,IdOption}}->
 	     case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption) of
 	 	["90"]-> Rubrique=#rubrique{descr_rub=Name},
 	 	       #mmsinfos{listerubrique=All_opts}=cast(Session),
 	 	       Session2=update_session(Session,#mmsinfos{listerubrique=All_opts,en_cours=Rubrique}),
 	 	       {redirect,Session2,"#success_mms"};
 	 	Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
 	 		 {redirect,Session,"#temporary"}
 	     end;
	_->
	    slog:event(internal,?MODULE, option_not_found, {MSISDN,Opt}),
 	    {redirect,Session,"#temporary"}
    end.


redirect_by_SMIlistOptions_status(abs,Groupe,Url_classique,Url_promo, Url_error)->                       
    [{redirect,abs,Url_classique},
     {redirect,abs,Url_promo},
     {redirect,abs,Url_error}];

redirect_by_SMIlistOptions_status(#session{prof=#profile{msisdn=MSISDN}}=Session,Groupe,
				  Url_classique, Url_promo, Url_error) ->

    case sms_mms_infos:'SMIlisteOptions'(MSISDN,Groupe) of    
        [Status,CodeOffre,ControleParental,CodeTac,AbonneConnu,
          ClasseImage,ClasseVideo,CompatAlertVideo,NbOptionsSouscrites,
          SuspEnvoiMms,All_opts]->
        	case Status of
	         "90" ->
	            case svc_smsinfos:is_promo(Session,All_opts,Url_classique,Url_promo,All_opts) of
	                    promo->   Session2=update_session(Session,#mmsinfos{listerubrique=All_opts}),
	                              {redirect,Session2,Url_promo};
	
	                    no_promo->  Session2=update_session(Session,#mmsinfos{listerubrique=All_opts}),
	                                {redirect,Session2,Url_classique}
                    end;
        	 Else  -> slog:event(failure,?MODULE,smilisteOptions_bad_status,{MSISDN, Else}),
                  {redirect,Session,Url_error}
                end;
	Else->
	slog:event(failure,?MODULE, smiListeOptions_failed,{MSISDN, Else}),
                  {redirect,Session,Url_error}
    end.

print_modification(Session,URL)->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    case svc_smsinfos:get_opts_souscrites(All_opts,[]) of
	[]->[];
	Opts -> 
	    [#hlink{href=URL,contents=[{pcdata,"Modif/Resiliations"}]}]
    end.

print_modification(Session,URL_modif_resil,URL_resil)->
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    case svc_smsinfos:get_opts_souscrites(All_opts,[]) of
	[]->[];
	Opts -> 
	    {value,{_,Name,IdCompOption}}= lists:keysearch(horoscope,1,?LISTE_OPTS_MMS_INFOS),
		case  svc_smsinfos:is_active(IdCompOption,All_opts) of
		    true -> [#hlink{href=URL_modif_resil,contents=[{pcdata,"Modif/Resiliations"}]},br];
		    false ->[#hlink{href=URL_resil,contents=[{pcdata,"Modif/Resiliations"}]},br]
		end	       
    end.

check_opts_resil([],_,List) -> List;
    
check_opts_resil([Opt|Next_Opt], Opts_souscrites,List) ->
     {_,_,IdCompOption}= Opt,
     case svc_smsinfos:is_active(IdCompOption, Opts_souscrites) of 
	 true -> 
	     check_opts_resil(Next_Opt,Opts_souscrites,[Opt|List]);
	 _ ->
	     check_opts_resil(Next_Opt,Opts_souscrites,List)
     end.

print_menu_opts_resiliation(Session,URL_resil,URL_resil_next)->    
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    case svc_smsinfos:get_opts_souscrites(All_opts,[]) of
	[]->[];
	Opts -> 
 	    case check_opts_resil(?LISTE_OPTS_MMS_INFOS,Opts,[]) of
 		[] -> [];
 		Opts_souscrites -> 
		    case length(Opts_souscrites) of 
			L when L =< 5 ->
			    {redirect, Session, URL_resil};
			_ ->
			    {redirect, Session, URL_resil_next}
		    end
	    end
    end.

resil(#session{prof=#profile{msisdn=Msisdn}=Prof}=Session,Rubrique,Classe)
  when Classe=="video" ->
    {value,{_,Name,IdOption}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS_V),
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=svc_smsinfos:get_opt_params(IdOption,All_opts),
    IdCompOption=Opt_param#sms_mms_option_params.idCompOption,
    case sms_mms_infos:'SMIresiliation'(Msisdn,IdCompOption) of 
	["90"]->   Rubrique2=#rubrique{descr_rub=Name},
		   #mmsinfos{listerubrique=All_opts}=cast(Session),  
		   Session2=update_session(Session,#mmsinfos{listerubrique=All_opts,en_cours=Rubrique2}),
		   {redirect,Session2,"#success_resil"};
	Else  -> slog:event(failure,?MODULE, resiliation_nok,{Msisdn,IdOption,Else}),
	     {redirect,Session,"#temporary"}
end;


resil(#session{prof=#profile{msisdn=Msisdn}=Prof}=Session,Rubrique,Classe)->
    {value,{_,Name,IdOption}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_MMS_INFOS),
    #mmsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=svc_smsinfos:get_opt_params(IdOption,All_opts),
    IdCompOption=Opt_param#sms_mms_option_params.idCompOption,
    case sms_mms_infos:'SMIresiliation'(Msisdn,IdCompOption) of
	["90"]-> Rubrique2=#rubrique{descr_rub=Name},
	       #mmsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,#mmsinfos{listerubrique=All_opts,en_cours=Rubrique2}),
	       {redirect,Session2,"#success_resil"};

	Else  -> slog:event(failure,?MODULE, resiliation_nok,{Msisdn, IdOption, Else}),
		 {redirect,Session,"#temporary"}
    end.


store_horo_signe(#session{prof=#profile{msisdn=MSISDN}}=Session,Genre,Date)->
    case is_signe(Date,Genre) of
	{true,Signe2,{Descr,Genre2},Sign_Value}->
	    %% Genre = h | f
	    Rub=rubrique(Session,horoscope),
	    MMSI2 = update_mmsinfos(cast(Session),
				    [{horoscope,Rub#rubrique{saisie=Sign_Value,descr_rub=Descr++" "++Genre2}}]),
	    case Genre of
		"f" ->{redirect,update_session(Session,MMSI2),"#confirm_inscription_horo_f"};
		"h" ->{redirect,update_session(Session,MMSI2),"#confirm_inscription_horo_h"}
	    end;
	
	false -> case Genre of
		     "f" ->{redirect,Session,"#form_horo_f_nok"};
		     "h" ->{redirect,Session,"#form_horo_h_nok"}
		 end
    end.



store_horo_promo_signe(#session{prof=#profile{msisdn=MSISDN}}=Session,Genre,Date)->
    case is_signe(Date,Genre) of
	{true,Signe2,{Descr,Genre2},Sign_Value}->
	    %% Genre = h | f
	    Rub=rubrique(Session,horoscope),
	    MMSI2 = update_mmsinfos(cast(Session),
				    [{horoscope,Rub#rubrique{saisie=Sign_Value,descr_rub=Descr++" "++Genre2}}]),
	    case Genre of
		"f" ->{redirect,update_session(Session,MMSI2),"#confirm_inscription_horo_f_promo"};
		"h" ->{redirect,update_session(Session,MMSI2),"#confirm_inscription_horo_h_promo"}
	    end;
	
	false -> case Genre of
		     "f" ->{redirect,Session,"#form_horo_f_nok_promo"};
		     "h" ->{redirect,Session,"#form_horo_h_nok_promo"}
		 end
    end.


subscribe_horo(#session{prof=#profile{msisdn=MSISDN}}=Session,Genre)->
    #mmsinfos{horoscope=Horo_param}=cast(Session),
    IdCompOption=Horo_param#rubrique.saisie,
    Descr=Horo_param#rubrique.descr_rub,
    {value,{_,_,IdOption}}= lists:keysearch(horoscope,1,?LISTE_OPTS_MMS_INFOS),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,
                                              integer_to_list(IdCompOption)) of
	["90"]->{redirect,Session,"#success_mms"};

	Else -> slog:event(failure,?MODULE, souscription_nok, {MSISDN, IdOption, Else}),
                 {redirect,Session,"#temporary"}
    end.

modif_horo(#session{prof=#profile{msisdn=MSISDN}}=Session,Genre,Signe)->
    case is_signe(Signe,Genre) of
	{true,Signe2,{Descr,_},Sign_Value}->
	    {value,{_,_,IdOption}}= lists:keysearch(horoscope,1,?LISTE_OPTS_MMS_INFOS),
	    case sms_mms_infos:'SMImodification'(MSISDN,IdOption,integer_to_list(Sign_Value)) of 
		["90"]-> 
		    Rubrique=#rubrique{descr_rub=Descr,saisie=Sign_Value},
		    #mmsinfos{listerubrique=All_opts}=cast(Session),
		    Session2=update_session(Session,#mmsinfos{listerubrique=All_opts,horoscope=Rubrique}),
		    case Genre of
			"f" ->{redirect,Session2,"#modif_success_f"};
			"h" ->{redirect,Session2,"#modif_success_h"}
		    end;

		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN, IdOption, Else}),
			 {redirect,Session,"#temporary"}
	    end;

	false -> case Genre of
	     "f" ->{redirect,Session,"#form_horo_modif_f_nok"};
	     "h" ->{redirect,Session,"#form_horo_modif_h_nok"}
	 end
end.


is_signe(Date,HF) when list(Date),length(Date)==4->
    %% JJMM => {J,M}
    case catch pbutil:sscanf("%02d%02d", Date) of
	{[J,M], ""}->
	    case svc_smsinfos:date_to_signe({M,J}) of 
		false -> false ;
		Signe -> info_signe(Signe,list_to_atom(HF))
	    end;
	E -> slog:event(trace,?MODULE,bad_format_in_date,E),
	     false
    end;
is_signe(Date,HF)->
    slog:event(trace,?MODULE,bad_format_in_date,Date),
    false.


