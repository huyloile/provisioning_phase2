
%%%% generique fonctions USD for SMSINFOS Services
%%%% Fonction USE for MOBI, CMO and postpaid.

-module(svc_smsinfos).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/sms_mms_infos_opt.hrl").
-include("../include/postpaid.hrl").
-include("../../pdist_orangef/include/spider.hrl").


-export([redirect_by_SMIlistOptions_status/5]).

%Display links functions
-export([print_rubrique_inactive/4]).
-export([print_rubrique_active/4]).
-export([print_modification/2]).
-export([include_links/1]).

%Display option parameters
-export([print_prix/2]).
-export([is_signe/1]).
-export([print_compl_rubrique/2]).
-export([descr_rubrique/1]).


%%Subscription functions
-export([subscribe/2]).
-export([subscribe_loto/3]).
-export([subscribe_horo/2]).
-export([subscribe_meteo/2]).
-export([subscribe_actu_locale/2]).
-export([subscribe_ol1/2]).
-export([subscribe_ol1_club/2]).

%%Modification functions
-export([modif_horo/2]).
-export([modif_meteo/2]).
-export([modif_actu_locale/2]).

%%Resiliation function
-export([resil/2]).

%% Function used by svc_mmsinfos.erl
-export([get_opts_souscrites/2]).
-export([is_promo/5]).    
-export([search_price/2]).
-export([get_opt_params/2]).
-export([is_active/2]).
-export([date_to_signe/1]).
-export([is_signe/1]).
-export([include_text/2]).


%% +type print_rubrique_inactive(session(),string(),URL::string(),string()) -> hlink().
%%%% print link to activate an rubrique
print_rubrique_inactive(abs,Rubrique,URL,String)->
    [#hlink{href=URL,contents=[{pcdata,Rubrique}]},br];
print_rubrique_inactive(Session,Rubrique,URL,String)->
    #smsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,_,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_SMS_INFOS),
    case is_active(Id,All_opts) of
	true->
	    [];
	false->
	    [#hlink{href=URL,contents=[{pcdata,String}]},br]
    end.

is_active(Id,[])->
    false;
is_active(Id,[#sms_mms_option_params{idOption=Id_option,flagOptionSouscrite=Flag}=Opt|All_opts])->
    case Id of
 	Id_option ->
	    case Flag of 
		"1" ->true;
		"0"-> false
	    end;
 	_ -> 
	    is_active(Id,All_opts)
    end.

include_links(abs)->
    [#hlink{href="erl://svc_smsinfos:inscription_ligue1?11",
	    contents=[{pcdata,"Monaco"},br]},
     #hlink{href="erl://svc_smsinfos:inscription_ligue1?12"
	    ,contents=[{pcdata,"Montpellier"},br]}];
include_links(Session)->
    SMSI=cast(Session),
    SMSI#smsinfos.tmp_links.


%% +type print_rubrique_active(session(),string(),URL::string(),string()) -> hlink().
%%%% print only active rubrique
print_rubrique_active(abs,Rubrique,URL,String)->
    [#hlink{href=URL,contents=[{pcdata,String}]},br];
print_rubrique_active(Session,Rubrique,URL,String)->
    #smsinfos{listerubrique=All_opts}=cast(Session),
    {value,{_,_,Id}}=lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_SMS_INFOS),
    case is_active(Id,All_opts) of
	true->
	    [#hlink{href=URL,contents=[{pcdata,String}]},br];
	false->
	    []
    end.

%% +type print_modification(session(),URL::string()) -> hlink().
print_modification(abs,URL)->
    [#hlink{href=URL,contents=[{pcdata,"Modifications/Resiliation"}]},br];
print_modification(Session,URL)->
    #smsinfos{listerubrique=All_opts}=cast(Session),
    case get_opts_souscrites(All_opts,[]) of
	[]->[];
	_ ->[#hlink{href=URL,contents=[{pcdata,"Modifications/Resiliation"}]},br]
    end.

get_opts_souscrites([],List)->
    List;
get_opts_souscrites([#sms_mms_option_params{idOption=Id_option,flagOptionSouscrite=Flag}=Opt|All_opts],List)->
    case Flag of
	"1" ->get_opts_souscrites(All_opts,[Opt|List]);
	_ ->get_opts_souscrites(All_opts,List)
    end.

        
										
%% +type print_prix(session(),Rub::atom())-> [{pcdata,string()}].
print_prix(Id,[])->
    slog:event(internal,?MODULE,price_not_found,Id),
    "?";
print_prix(Session,Rubrique)->
    {value,{_,_,Id}}= lists:keysearch(list_to_atom(Rubrique),1,
				      ?LISTE_OPTS_SMS_INFOS),
    #smsinfos{listerubrique=All_opts}=cast(Session),
    search_price(Id, All_opts).

search_price(Id,[])->
    slog:event(internal,?MODULE,price_not_found,Id),
    [{pcdata,"?"}];

search_price(Id,[#sms_mms_option_params{idOption=Id_option,tarifHorsPromo=Tarif}=Opt|All_opts])->
    case Id_option of
 	Id ->[Formatted_value]=io_lib:format("~.2f", [list_to_integer(Tarif)/1000]),
 	     [{pcdata, Formatted_value}];
 	_ -> search_price(Id,All_opts)
    end.

%% +type resil(session())-> erlpage_result().
resil(abs)->
    resil(abs,"");
resil(#session{prof=#profile{msisdn=Msisdn}=Prof}=Session)->
    SMSI = #smsinfos{en_cours=Rubrique} = cast(Session),
    resil(Session,Rubrique).

%% +type resil(session(),RubName::string())-> erlpage_result().

resil(#session{prof=#profile{msisdn=Msisdn}=Prof}=Session,Rubrique)->
    {value,{_,Name,IdOption}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_SMS_INFOS),
    #smsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=get_opt_params(IdOption,All_opts),
    IdCompOption=Opt_param#sms_mms_option_params.idCompOption,
    case sms_mms_infos:'SMIresiliation'(Msisdn,IdCompOption) of
	["90"]-> Rubrique2=#rubrique{descr_rub=Name},
	       #smsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,
				       #smsinfos{listerubrique=All_opts,
						 en_cours=Rubrique2}),
	       {redirect,Session2,"#success_resil"};
	Else  -> slog:event(failure,?MODULE, resiliation_nok, {Msisdn,IdOption,Else}),
		 {redirect,Session,"#temporary"}
    end.

get_opt_params(Id,[])->
    slog:event(internal,?MODULE,idoption_not_found,Id),
    "?";

get_opt_params(Id,[#sms_mms_option_params{idOption=Id_option,tarif=Tarif}=Opt|All_opts])->
    case Id_option of
 	Id -> Opt; 
	_ -> get_opt_params(Id,All_opts)
    end.


descr_rubrique(abs)->
    [{pcdata, "INFOS Config Rub"}];
descr_rubrique(Session)->
    #smsinfos{en_cours=Rub}=cast(Session),
    #rubrique{descr_comp=Descr,descr_rub=Descr_Rub}=Rub,
    case Descr of
	""->
	    [{pcdata, Descr_Rub}];
	_ ->
	    [{pcdata, Descr_Rub++" "++Descr}]
    end.


%% +type get_ville(string())-> false | {true, Dept::string(), Value::string()}.
get_ville(Dpt)->
    case pbutil:all_digits(Dpt) of
	true->
	    %%on continue
	    %%cherche correspodance
	    case dept_to_ville(Dpt) of
		{true, Dept, Value} when list(Value)->
		    {true,Dpt,Value};
		E ->
		    false
	    end;
	_ ->
	    false
    end.

%% +type dept_to_ville(string())-> {true,Dept::string(),Val::string()} | false.
dept_to_ville(Dept) when list(Dept)->
    case lists:keysearch(list_to_integer(Dept),1,?LIST_METEO) of
	{value,{I_Dept,Dept_Descr,Villes,Value}}->
	    {true,Dept,integer_to_list(Value)};
	false->
	    false
    end.

%% +type comp2dept(Val::string())-> {true,Dept::string(),Val::string()} | false.
comp2dept(Val) when list(Val)->
    case lists:keysearch(list_to_integer(Val),4,?LIST_METEO) of
	{value,{I_Dept,Dept_Descr,Villes,Value}}->
	    {true,integer_to_list(I_Dept),Val};
	false->
	    false
    end.

%% +type is_signe(string())-> false | {true, {(h | f),atom}, string(),Val::string()}.
is_signe(Date) when list(Date),length(Date)==4->
    %% JJMM => {J,M}
    case catch pbutil:sscanf("%02d%02d", Date) of
	{[J,M], ""}->
	    Signe=date_to_signe({M,J}),
	    case lists:keysearch(Signe,1,?LIST_SIGN) of
		{value,{SignHF,Descr,Value}}->
		    {true,SignHF,Descr,Value};
		false->
		    false 
	    end;
	E ->
	    slog:event(trace,?MODULE,bad_format_in_date,E),
	    false
    end;
is_signe(Date)->
    slog:event(trace,?MODULE,bad_format_in_date,Date),
    false.

%% +type comp2signe(string())-> false | {true, term(), string(),Val::string()}.
comp2signe(Comp)->
    %%% Valeur du signe
    case lists:keysearch(list_to_integer(Comp),3,?LIST_SIGN) of
	{value,{Signe2,Descr,Value}}->
	    {true,Signe2,Descr,Value};
	false->
	    false
    end.


%% +type is_club(Club::string())-> false | 
%%        {true, string(), Descr::string(),Val::string()}.
is_club(Club)->
    %%% 3 premières lettre en MAJUSCULE
    Club2 = lists:map(fun(X) -> pbutil:upcase(X) end, lists:sublist(Club,3)),
    case search(Club2,?LISTE_CLUB,[]) of
	[{value,Club2,Descr,Value}]->
	    {true,Club2,Descr,Value};
	[]->
	    false;
	L when list(L) ->
	    %% X possibility
	    L;
	_->
	    false
    end.

search(_,[],Acc)->
    Acc;
search(KeyClub,[{KeyClub,Descr,Val}|H],Acc)->
    search(KeyClub,H,Acc++[{value,KeyClub,Descr,Val}]);
search(KeyClub,[{_,Descr,Val}|H],Acc) ->
    search(KeyClub,H,Acc).


%% +type comp2club(Val::string())-> false |
%%           {true, Club::string(),Descr::string(),Val::string()}.
comp2club(Comp)->
    %%% Variable renvoyé par SMS INFOS
    case lists:keysearch(Comp,3,?LISTE_CLUB) of
	{value,{Club,Descr,Value}}->
	    {true,Club,Descr,Value};
	false->
	    false
    end.

%%%%%%%%%%%%%%% GENERIC FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type update_session(session(),smsinfos())-> session().
update_session(#session{prof=#profile{subscription=Sub}}=Session,
	       #smsinfos{}=SMSINFOS) when Sub=="postpaid"->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,State#postpaid_user_state{smsinfos=SMSINFOS});
update_session(#session{}=Session,#smsinfos{}=SMSINFOS)->
    State = svc_util_of:get_user_state(Session),
    svc_util_of:update_user_state(Session,State#sdp_user_state{tmp_smsinfo_offer=SMSINFOS}).


%% +type cast(session())-> smsinfos().
cast(#session{prof=#profile{subscription=Sub}}=Session) when Sub=="postpaid"->
    State = svc_util_of:get_user_state(Session),
    State#postpaid_user_state.smsinfos;
cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#sdp_user_state.tmp_smsinfo_offer.

%% +type init_smsinfos(SMSI::string(),IMEI::string(),
%%                     currency:currency(),
%%                     RUB_FACT::[{RubId::integer(),FactType::string()}])->
%%                     smsinfos().
init_smsinfos(SMSI,IMEI,PM,RUB_FACT)->
    Rub_s=lists:map(fun({RubId,Fact})-> #rubrique{id=RubId,
						  active=true,
						  facturation=Fact} end,
		    RUB_FACT),
    SMSI#smsinfos{portemonnaie=PM,imeitac=IMEI,listerubrique=Rub_s}.
	      


%% +type redirect_form_ko(session,URL_NOK::string(),URL_END::string(),
%%            integer())-> erlpage_result().
redirect_form_ko(abs,Url_nok,Url_end,_)->
    [{redirect,abs,Url_nok},
     {redirect,abs,Url_end}];
redirect_form_ko(Session,URL_nok,URL_end,TEN) when TEN>0->
    {redirect,Session,URL_nok};
redirect_form_ko(Session,URL_nok,URL_end,TEN) ->
    {redirect,Session,URL_end}.


subscribe(#session{prof=#profile{msisdn=MSISDN}}=Session,Opt) when Opt=="actu_gene" ->
    CodeCompOption="0",
    {value,{_,Name,IdOption}}= lists:keysearch(list_to_atom(Opt),1,?LISTE_OPTS_SMS_INFOS),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,CodeCompOption) of
	["90"]-> Rubrique=#rubrique{descr_rub=Name},
	       #smsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
	       {redirect,Session2,"#success_sms"};
	Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
		 {redirect,Session,"#temporary"}
    end;

subscribe(#session{prof=#profile{msisdn=MSISDN}}=Session,Opt)->
    CodeCompOption="nul",
    {value,{_,Name,IdOption}}= lists:keysearch(list_to_atom(Opt),1,?LISTE_OPTS_SMS_INFOS),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,CodeCompOption) of
	["90"]-> Rubrique=#rubrique{descr_rub=Name},
	       #smsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
	       {redirect,Session2,"#success_sms"};
	Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
		 {redirect,Session,"#temporary"}
    end.


subscribe_horo(#session{prof=#profile{msisdn=MSISDN}}=Session,Signe)->
    case is_signe(Signe) of
	{true,Signe2,Descr,IdCompOption}->
	    {value,{_,_,IdOption}}= lists:keysearch(horoscope,1,?LISTE_OPTS_SMS_INFOS),
	    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,
						      integer_to_list(IdCompOption)) of
		["90"]-> Rubrique=#rubrique{descr_rub="Horoscope"++" "++Descr},
		       #smsinfos{listerubrique=All_opts}=cast(Session),
		       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		       {redirect,Session2,"#success_sms"};
		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
			 {redirect,Session,"#temporary"}
	    end;
						      
	false ->{redirect,Session,"#form_horo_nok"}
    end.


modif_horo(#session{prof=#profile{msisdn=MSISDN}}=Session,Signe)->
    case is_signe(Signe) of
	{true,Signe2,Descr,Sign_Value}->
	    {value,{_,_,IdOption}}= lists:keysearch(horoscope,1,?LISTE_OPTS_SMS_INFOS),
	    case sms_mms_infos:'SMImodification'(MSISDN,IdOption,
						      integer_to_list(Sign_Value)) of
		["90"]-> Rubrique=#rubrique{descr_rub="Horoscope"++" "++Descr},
		       #smsinfos{listerubrique=All_opts}=cast(Session),
		       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		       {redirect,Session2,"#success_sms"};
		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
			 {redirect,Session,"#temporary"}
	    end;
	false ->{redirect,Session,"#form_horo_nok"}
    end.




subscribe_loto(#session{prof=#profile{msisdn=MSISDN}}=Session,Opt,IdCompOption) ->
   {value,{_,_,IdOption}}= lists:keysearch(list_to_atom(Opt),1,?LISTE_OPTS_SMS_INFOS),
   {value,{_,Name}}= lists:keysearch(IdCompOption,1,?LIST_LOTO),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption) of
	["90"]-> Rubrique=#rubrique{descr_rub=Name},
	       #smsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
	       {redirect,Session2,"#success_sms"};
	Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
		 {redirect,Session,"#temporary"}
    end.



subscribe_actu_locale(#session{prof=#profile{msisdn=MSISDN}}=Session,Dpt)->
    case is_dept(Dpt) of
	{true,Descr}->
	    {value,{_,_,IdOption}}= lists:keysearch(actu,1,?LISTE_OPTS_SMS_INFOS),
	    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption, Dpt) of
		["90"]->Rubrique=#rubrique{descr_rub="Actualites "++Descr},
		      #smsinfos{listerubrique=All_opts}=cast(Session),
		      Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		      {redirect,Session2,"#success_sms"};
		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
			 {redirect,Session,"#temporary"}
	    end;
	false ->{redirect,Session,"#form_actu_locale_nok"}
    end.


modif_actu_locale(#session{prof=#profile{msisdn=MSISDN}}=Session,Dpt)->
    case is_dept(Dpt) of
	{true,Descr}->
	    {value,{_,_,IdOption}}= lists:keysearch(actu,1,?LISTE_OPTS_SMS_INFOS),
	    case sms_mms_infos:'SMImodification'(MSISDN,IdOption,Dpt) of
		["90"]->Rubrique=#rubrique{descr_rub="Actualites "++Descr},
		      #smsinfos{listerubrique=All_opts}=cast(Session),
		      Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		      {redirect,Session2,"#success_sms"};
		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
			 {redirect,Session,"#temporary"}
	    end;
	false ->{redirect,Session,"#form_actu_locale_nok"}
    end.


subscribe_meteo(#session{prof=#profile{msisdn=MSISDN}}=Session,Dpt)->
    case get_ville(Dpt) of
	{true,Dpt,IdCompOption}->
	    {value,{_,_,IdOption}}= lists:keysearch(meteo,1,?LISTE_OPTS_SMS_INFOS),
	    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption) of
		["90"]-> Rubrique=#rubrique{descr_rub="Meteo "++Dpt},
		       #smsinfos{listerubrique=All_opts}=cast(Session),
		      Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		       {redirect,Session2,"#success_sms"};
		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
			 {redirect,Session,"#temporary"}
	    end;

	false ->{redirect,Session,"#form_meteo_nok"}
    end.


modif_meteo(#session{prof=#profile{msisdn=MSISDN}}=Session,Dpt)->
    case get_ville(Dpt) of
	{true,Dpt,Value}->
	    {value,{_,_,IdOption}}= lists:keysearch(meteo,1,?LISTE_OPTS_SMS_INFOS),
	    case sms_mms_infos:'SMImodification'(MSISDN,IdOption,Value) of
		["90"]-> Rubrique=#rubrique{descr_rub="Meteo "++Dpt},
		       #smsinfos{listerubrique=All_opts}=cast(Session),
		      Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		       {redirect,Session2,"#success_sms"};
		Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
			 {redirect,Session,"#temporary"}
	    end;

	false ->{redirect,Session,"#form_meteo_nok"}
    end.


subscribe_ol1(#session{prof=#profile{msisdn=MSISDN}}=Session,IdCompOption)->
    {value,{_,Descr,IdOption}}= lists:keysearch(ligue1,1,?LISTE_OPTS_SMS_INFOS),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption) of
	["90"]-> Rubrique=#rubrique{descr_rub="Ligue1 "++Descr},
	       #smsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
	       {redirect,Session2,"#success_sms"};
	Else  -> slog:event(failure,?MODULE, souscription_nok,{MSISDN,IdOption,Else}),
		 {redirect,Session,"#temporary"}
    end.

subscribe_ol1_club(#session{prof=#profile{msisdn=MSISDN}}=Session,Club) 
  when ((Club=="03") or (Club=="07"))->
    {value,{_,_,IdOption}}= lists:keysearch(ligue1,1,?LISTE_OPTS_SMS_INFOS),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,Club) of
	["90"]-> {value,{_,Descr,_}}= lists:keysearch(Club,3,?LISTE_CLUB),
	       Rubrique=#rubrique{descr_rub=Descr},
	       #smsinfos{listerubrique=All_opts}=cast(Session),
	       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
	       {redirect,Session2,"#success_club"};
	Else  -> slog:event(failure,?MODULE, souscription_nok, {MSISDN,IdOption,Else}),
		 {redirect,Session,"#temporary"}
    end;

subscribe_ol1_club(#session{prof=#profile{msisdn=MSISDN}}=Session,Club)
  when ((Club=="1") or (Club=="2"))->
    IdCompOption = case Club of
		       "1" ->
			   "25";
		       "2" ->
			   "11";
		       _ ->
			   "25"
		   end,
    {value,{_,_,IdOption}}= lists:keysearch(ligue1,1,?LISTE_OPTS_SMS_INFOS),
    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption) of
        ["90"]-> {value,{_,Descr,_}}= lists:keysearch(IdCompOption,3,?LISTE_CLUB),
	       Rubrique=#rubrique{descr_rub=Descr},
               #smsinfos{listerubrique=All_opts}=cast(Session),
               Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
               {redirect,Session2,"#success_club"};
        Else  -> slog:event(failure,?MODULE, souscription_nok,{MSISDN, IdOption,Else}),
                 {redirect,Session,"#temporary"}
    end;

subscribe_ol1_club(#session{prof=#profile{msisdn=MSISDN}}=Session,Club) ->
    case is_club(Club) of
	{true,Club2,Descr,IdCompOption}->
	    {value,{_,_,IdOption}}= lists:keysearch(ligue1,1,?LISTE_OPTS_SMS_INFOS),

	    case sms_mms_infos:'SMISouscription'(MSISDN,IdOption,IdCompOption) of
		["90"]-> Rubrique=#rubrique{descr_rub="Ligue1 "++Descr},
		       #smsinfos{listerubrique=All_opts}=cast(Session),
		       Session2=update_session(Session,#smsinfos{listerubrique=All_opts,en_cours=Rubrique}),
		       {redirect,Session2,"#success_club"};
		Else  -> slog:event(failure,?MODULE, souscription_nok,{MSISDN, IdOption, Else}),
			 {redirect,Session,"#temporary"}
	    end;

	false ->
	    {redirect,Session,"#form_options_club_nok"};
	[{value,"MON","Monaco","11"},{value,"MON","Montpellier","25"}] ->
	    {redirect,Session,"#select_duplicated_club"};
	List ->
	    %% return a page with all possibility of return
	    %% make link
	    HLINKS= lists:map(
		      fun({value,KeyClub,Descr,Value})->
			      #hlink{
			   href="erl://svc_smsinfos:subscribe_ol1_club?"++
			   Value,contents=[{pcdata,Descr},br]}
		      end,List),
  	    SMSI=cast(Session),
	    SMSI2=SMSI#smsinfos{tmp_links=HLINKS},
	    {redirect,update_session(Session,SMSI2),"#modification_club"} 
    end.


redirect_by_SMIlistOptions_status(abs,Groupe,Url_classique,Url_promo, Url_error)->                       
    [{redirect,abs,Url_classique},
     {redirect,abs,Url_promo},
     {redirect,abs,Url_error}];

redirect_by_SMIlistOptions_status(#session{prof=#profile{msisdn=MSISDN}}=Session,Groupe,
				  Url_classique, Url_promo, Url_error) ->
    case sms_mms_infos:'SMIlisteOptions'(MSISDN,Groupe) of
	["90",CodeOffre,ControleParental,CodeTac,AbonneConnu,
	 ClasseImage,ClasseVideo,CompatAlertVideo,NbOptionsSouscrites,
	 SuspEnvoiMms,All_opts] ->
	    case is_promo(Session,All_opts,Url_classique,Url_promo,All_opts) of
		promo->   Session2=update_session(Session,#smsinfos{listerubrique=All_opts}),
			  {redirect,Session2,Url_promo};
		no_promo->  Session2=update_session(Session,#smsinfos{listerubrique=All_opts}),
			    {redirect,Session2,Url_classique}
	    end;
	Else  -> slog:event(failure,?MODULE, smilistOptions_bad_status,{MSISDN, Else}),
 		 {redirect,Session,Url_error}
    end.
    
is_promo(Session,[],Url_classique,Url_promo,All_opts)->
    no_promo;

is_promo(Session,[#sms_mms_option_params{typeFacturation=TypeFact, 
 					 flagOptionSouscrite=FLAG}=Opt|Opts],
 	 Url_classique,Url_promo,All_opts)->
    case TypeFact of
 	"PROMBASE" ->
 	    case FLAG of
 		"0" -> promo;
 		 Else ->
 		    is_promo(Session,Opts,Url_classique,Url_promo,All_opts)
 	    end;
 	Else -> is_promo(Session,Opts,Url_classique,Url_promo,All_opts)
    end.

%% +type is_dept(string())-> false | {true, Descr::string()}.
is_dept(X)->
    case lists:keysearch(X,1,?LISTE_LOCALE) of
	{value, {Dept,Descr}}->
	    {true, Descr};
	false->
	    false
    end.



print_compl_rubrique(Session,Rubrique)
  when Rubrique=="horoscope" ->
    {value,{_,Name,Id}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_SMS_INFOS),
    #smsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=get_opt_params(Id,All_opts),
    {value,{_,Descr,_}}=lists:keysearch(list_to_integer(Opt_param#sms_mms_option_params.codeCompOption),3,?LIST_SIGN),
    [{pcdata, Descr}];				      		 

print_compl_rubrique(Session,Rubrique)
  when Rubrique=="actu" ->
    {value,{_,Name,Id}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_SMS_INFOS),
    #smsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=get_opt_params(Id,All_opts),
    {value,{_,Descr}}=lists:keysearch(Opt_param#sms_mms_option_params.codeCompOption,1,?LISTE_LOCALE),
    [{pcdata,Descr}];

print_compl_rubrique(Session,Rubrique)
  when Rubrique=="meteo" ->  
    {value,{_,Name,Id}}= lists:keysearch(list_to_atom(Rubrique),1,?LISTE_OPTS_SMS_INFOS),
    #smsinfos{listerubrique=All_opts}=cast(Session),
    Opt_param=get_opt_params(Id,All_opts),
    {value,{Descr,_,_,_}}=lists:keysearch(list_to_integer(Opt_param#sms_mms_option_params.codeCompOption),4,?LIST_METEO),
    [{pcdata,integer_to_list(Descr)}].


%% +type date_to_signe({M::integer(),J::integer()})-> atom().
date_to_signe({M,J}= Date) when M>=1,M=<12,J>=1,J=<31->
    case Date of
	D when D>={3,21}, D=<{4,20}->
	    belier;
	D when D>={4,21}, D=<{5,21}->
	    taureau;
	D when D>={5,22}, D=<{6,21}->
	    gemeaux;
	D when D>={6,22}, D=<{7,23}->
	    cancer;
	D when D>={7,24}, D=<{8,23}->
	    lion;
	D when D>={8,24}, D=<{9,23}->
	    vierge;
	D when D>={9,24}, D=<{10,23}->
	    balance;
	D when D>={10,24},D=<{11,22}->
	    scorpion;
	D when D>={11,23},D=<{12,21}->
	    sagitaire;
	D when D>={12,22}, D=<{12,31}->
	    capricorne;
	D when D>={1,1}, D=<{2,20}->
	    capricorne;
	D when D>={2,20}, D=<{3,20}->
	    poisson;
	Else->
	    false
    end;
date_to_signe(_) ->
    false.
	   
include_text(Session,Is_promo)->
    case Is_promo of
	"promo" ->
	    [{pcdata,"/mois"}];
	Else ->
	    [{pcdata,"par mois"}]
    end.
