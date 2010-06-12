%%%% Home page generator.

-module(svc_home).
-export([home/2, name/1, session_price/1]).
-export([version/1]).
-export([filter_pathological_mobi/2,filter_pathological_cmo/2]).
-export([init_session/2,niveau_provisioning/2,check_services_access/2]).
-export([not_postpaid/1,not_bzh_gp/1,filter_state_limit/2]).
-export([slog_info/3]).
                                             
-include("../../oma/include/slog.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/dme.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pdist_orangef/include/spider.hrl").

-define(home_cmo,"/orangef/prov_cmo.xml").
-define(home_mobi,"/orangef/prov.xml").
-define(home_omer,"/orangef/prov_omer.xml").
-define(home_tele2,"/orangef/tele2/selfcare.xml").
-define(home_virgin,"/orangef/virgin/selfcare_virgin_pp.xml").
-define(home_carrefour,"/orangef/carrefour/selfcare_carrefour_pp.xml").
-define(home_tele2_cb,"/run/xml/mcel/acceptance/selfcare_tele2_cb.xml").
-define(home_ten_cb,"/run/xml/mcel/acceptance/selfcare_ten_cb.xml").
-define(home_monacell,"/orangef/monacell/selfcare_monacell_pp.xml").
-define(home_monacell_cb,"/orangef/monacell/selfcare_monacell_cb.xml").
%% +type home(session(),string()) -> erlpage_result().
%%%% Switches between anonymous and personalized home pages.

home(abs,URL) ->
    [ %% Special clauses in home/1.
      {"sms", {redirect, abs, "#auth_preprod"}},
      {"default",{redirect, abs, URL}}
     ];
%% PB 20020322 Il n'y a plus de test_sms.xml en prod.
%% PB 20080523 test limande avec IMSI commençant par 0000
home(#session{bearer={sms,_}}=Session,URL) ->
    pbutil:autograph_label(sms),
    {redirect, Session, "#auth_preprod"};
home(#session{prof=#profile{imsi="20801"++_}}=Session,URL)->
    {redirect,Session,URL};
home(#session{prof=#profile{imsi="999"++_}}=Session,URL) ->
    {redirect,Session,URL};
home(#session{prof=#profile{imsi="0000"++_}}=Session,URL) ->
    {redirect,Session,URL};
home(#session{prof=#profile{imsi={na,_}}}=Session,URL) ->
    {redirect,Session,URL};
home(#session{prof=Prof}=Session,_) ->
    {redirect, Session, "#auth_preprod"}.

not_postpaid(#session{prof=#profile{subscription=S}=Profile} = Session) when S=="postpaid"->
    Profile_=Profile#profile{subscription="bzh_gp"},
    %% get to bzh URL
    URL= pbutil:get_env(pservices_orangef,url_not_postpaid),
    {redirect,Session#session{prof=Profile_},URL}.

not_bzh_gp(#session{prof=#profile{subscription=S}=Profile} = Session)->
    Profile2=Profile#profile{subscription="anon"},
    {redirect,Session#session{prof=Profile2},"file:/orangef/home.xml#anon"}.

init_session(abs,Url) -> 
    [ %% Special clauses in home/1.
      {"nok",{redirect, abs, "#prov_failed"}},
      {"ok",{redirect, abs, Url}}
    ];
init_session(Session,Url) -> 
    case provisioning_ftm:init_session(Session) of
        {ok, InitialSession} -> 
            Session1 = InitialSession#session{billing=billing_standard_of},
            case billing:start(Session1) of 
                {ok, Session2, Timeout} -> 
                    {redirect, Session2, Url};
                {stop, Session2, Error} ->
                    %% unexpected error
                    slog:event(failure, ?MODULE, billing_init_failed, Error),
                    {redirect, Session, "#prov_failed"}
            end;
        {nok, Error} -> 
	    slog:event(failure,?MODULE,provisioning_failed,Error),
            {redirect, Session, "#prov_failed"}
    end.


niveau_provisioning(abs,Url) -> 
    [
      {"ok",{redirect, abs, Url}},
      {"nok",{redirect, abs, "#prov_failed"}}
    ];
niveau_provisioning(#session{prof=Prof}=Session,Url) ->
    case provisioning_ftm:niveau_provisioning(Session) of 
        {ok, SessionProv} -> 
	    pbutil:autograph_label(identified),
            case filter_pathological(SessionProv,default) of
		{redirect, #session{prof=Prof_}=Session_, URL}->
		    pbutil:autograph_label(redirect),
                    NewProf = provisioning_ftm:store_user(Prof,Prof_),
                    {redirect, Session_#session{prof=NewProf}, URL};
		{continue, #session{prof=Prof_}=Session_}->
                    NewProf = provisioning_ftm:store_user(Prof,Prof_),
                    {redirect, Session_#session{prof=NewProf}, Url}
	    end;
        {niveau1, SessionProv} -> 
            {redirect, SessionProv, Url};
        {nok, {update_profile, #session{prof=Prof_}=SessionProv}} -> 
            NewProf = provisioning_ftm:store_user(Prof,Prof_),
            {redirect, SessionProv#session{prof=NewProf}, Url};
	{nok, Error} -> 
	    slog:event(failure,?MODULE,provisioning_failed,Error),
            {redirect, Session, "#prov_failed"}
    end.

check_services_access(abs,URLs) ->
    [Uok,Unok]=string:tokens(URLs, ","),
     [{redirect, abs, Uok},
      {redirect, abs, Unok}];

check_services_access(Session,URLs)->
    Ussd_code=plugin:get_attrib(Session,"ussd_code"),
    State = svc_util_of:get_user_state(Session),
    Declinaison = case is_record(State, sdp_user_state) of
		      true ->
			  State#sdp_user_state.declinaison;
		      _ ->
			  undefined
		  end,
    [Uok,Unok]=string:tokens(URLs, ","),
    Sub=svc_util_of:get_souscription(Session),
    slog:event(trace,?MODULE,check_services_access,{Ussd_code,Sub,Session}),

    case Declinaison of
	80 ->
	    {redirect,Session,Unok};
	_ ->
	    Access_services=pbutil:get_env(pservices_orangef,access_services),
	    Sub_list=search_service(Ussd_code,Access_services),
	    case lists:member(all_and_anon,Sub_list) of
		true -> {redirect,Session,Uok};
		_ ->
		    case lists:member(Sub,Sub_list) of
			true-> {redirect,Session,Uok};
			_->  
			    case Sub of 
				Sub_new when Sub_new==leo_gourou -> 
				    {redirect,Session,"/orangef/home.xml#not_allowed_leogourou"};
				_ ->
				    Subs_mvno = pbutil:get_env(pservices_orangef,subscription_mvno),
				    case lists:member(Sub, Subs_mvno) of
					true ->
					    {redirect,Session,"/orangef/home.xml#not_allowed_mvno"};
					_->    
					    {redirect,Session,Unok}
				    end
			    end
		    end
	    end
    end.

search_service(Ussd_code,[])->[];
search_service(Ussd_code,[{Ussd_code1,Sub_list}|Tail])->
    case Ussd_code1 of
	Ussd_code->
	    Sub_list;
	_ ->search_service(Ussd_code,Tail)
    end.

    
%% store IMSI and type to re-do the request in batch
%% give a default value (Niv1) to navigation profile 
recup_ocf_failure(#session{prof=#profile{imsi=IMSI,terminal=Term}=Prof}=
		  Session_1,Type,?MULTIPLE_SOUSCRIPTION)->
    batch_reset_imei:add(IMSI,get_user),
    Terminal = db:terminal_info(""),
    Session_2 = Session_1#session{
		  prof= Prof#profile{terminal=Terminal}},
    {continue,Session_2};
recup_ocf_failure(#session{prof=#profile{imsi=IMSI,terminal=Term}=Prof}=
		  Session_1,Type,_)->
    batch_reset_imei:add(IMSI,Type),
    Terminal = db:terminal_info(""),
    Session_2 = Session_1#session{
		  prof= Prof#profile{terminal=Terminal}},
    {continue,Session_2}.

filter_pathological(abs,abs) ->
    [{redirect, abs, "/orangef/home.xml#prov_failed"}] ++
	filter_pathological_etat(abs,abs);
filter_pathological(#session{prof=#profile{subscription=S}=Profile} = 
		    Session,_) 
  when S=="omer"; S=="bzh_cmo"->
    %% Initialize svc_data, so that selfcare error pages still work
    case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, #sdp_user_state{}=US}->
	    Profile1 = Profile#profile{subscription=svc_util_of:declinaison(US)},
	    NewSess = svc_util_of:update_user_state(Session_,US),
	    filter_pathological_etat(NewSess#session{prof=Profile1}, US);
	Else ->
	    slog:event(failure,?MODULE,read_error_in_filter_pathologiq,Else),
            pbutil:autograph_label(sdp_hs),
	    FailURL = pbutil:get_env(pservices_orangef, failure_url),
	    {redirect, Session, FailURL}
    end;
filter_pathological(#session{prof=#profile{subscription=S}=Profile} = 
		    Session,_) 
  when S=="mobi"; S=="cmo"->
    case svc_spider:get_availability(Session) of
	Avail when Avail==not_available ->
	    %% Sachem 
	    filter_pathological_etat(Session,svc_util_of:get_user_state(Session));
	_ ->
	    filter_patho_etat_spider(Session, S, 
				     svc_spider:get_fileState(Session))
    end;
filter_pathological(#session{prof=#profile{subscription="dme"}} = Session,
		    selfcare) ->
    pbutil:autograph_label(dme),
    {continue, Session};

filter_pathological(#session{prof=#profile{anon=true}=Prof} = Session,_) ->
    pbutil:autograph_label(anon),
    %% for the moment, we filter anonymous profiles here
    %% we could let them go further, and let svc_home handle them.
    FailURL = pbutil:get_env(pservices_orangef, failure_url),
    {redirect, Session, FailURL};
filter_pathological(#session{prof=#profile{subscription=S}=Profile} =Session,_)
 when S == "carrefour_prepaid" ;S == "tele2_pp";
      S =="virgin_prepaid"; S =="virgin_comptebloque";
      S =="monacell_prepaid";S == "leo_gourou" ->
    filter_pathological_etat(Session,svc_util_of:get_user_state(Session));
filter_pathological(Session,_) ->
    pbutil:autograph_label(other),
    {continue,Session}.

filter_pathological_etat(abs,abs)->
    filter_pathological_mobi(abs,abs) ++
	filter_pathological_cmo(abs,abs);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="mobi",US#sdp_user_state.declinaison==?mobi->
    filter_pathological_mobi(Session,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="mobi",US#sdp_user_state.declinaison==?cpdeg->
    filter_pathological_mobi(Session,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="omer",US#sdp_user_state.declinaison==?omer->
    filter_pathological_all(Session,US,?home_omer);
filter_pathological_etat(#session{prof=#profile{subscription=S}=Prof}=Session,
			 US) 
  when S=="mobi",US#sdp_user_state.declinaison==?omer->
    slog:event(trace,?MODULE,mobi_change_to_omer,filter_pathological),
    NewProf=Prof#profile{subscription="omer"},
    NewSession=Session#session{prof=NewProf},
    filter_pathological_all(NewSession,US,?home_omer);
filter_pathological_etat(#session{prof=#profile{subscription=S}=Prof}=Session,
			 US) 
  when S=="mobi",US#sdp_user_state.declinaison>=?ppol1,
       US#sdp_user_state.declinaison<?omer->
    slog:event(trace,?MODULE,mobi_change_to_cmo,filter_pathological),
    NewProf=Prof#profile{subscription="cmo"},
    NewSession=Session#session{prof=NewProf},
    filter_pathological_cmo(NewSession,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}=Prof}=Session,
			 US) 
  when S=="mobi",US#sdp_user_state.declinaison==?ppol4->
    slog:event(trace,?MODULE,mobi_change_to_cmo,filter_pathological),
    NewProf=Prof#profile{subscription="cmo"},
    NewSession=Session#session{prof=NewProf},
    filter_pathological_cmo(NewSession,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}=Prof}=Session,
			 US) 
  when S=="mobi",US#sdp_user_state.declinaison==?ppola->
    slog:event(trace,?MODULE,mobi_change_to_cmo,filter_pathological),
    NewProf=Prof#profile{subscription="cmo"},
    NewSession=Session#session{prof=NewProf},
    filter_pathological_cmo(NewSession,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}=Prof}=Session,
			 US) 
  when S=="cmo",US#sdp_user_state.declinaison==?mobi->
    slog:event(trace,?MODULE,cmo_change_to_mobi,filter_pathological),
    NewProf=Prof#profile{subscription="mobi"},
    NewSession=Session#session{prof=NewProf},
    filter_pathological_mobi(NewSession,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="cmo",US#sdp_user_state.declinaison ==?ppola->
    filter_pathological_cmo(Session,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="cmo"->
    filter_pathological_cmo(Session,US);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="virgin_prepaid";S=="virgin_comptebloque" ->
    filter_pathological_all(Session,US,?home_virgin);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="carrefour_prepaid" ->
    filter_pathological_all(Session,US,?home_carrefour);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S == "tele2_pp" ->
    filter_pathological_all(Session,US,?home_tele2);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S == "tele2_comptebloque" ->
    filter_pathological_all(Session,US,?home_tele2_cb);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S == "ten_comptebloque" ->
    filter_pathological_all(Session,US,?home_ten_cb);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="monacell_prepaid" ->
    filter_pathological_all(Session,US,?home_monacell);
filter_pathological_etat(#session{prof=#profile{subscription=S}}=Session,US) 
  when S=="monacell_comptebloqu" ->
    filter_pathological_all(Session,US,?home_monacell_cb);
filter_pathological_etat(Session,US) ->
    {continue,Session}.


-define(is_patho(S),
	S==?ETAT_SI;
	S==?ETAT_SF;
	S==?ETAT_SV;
	S==?ETAT_SA;
	S==?ETAT_SR;
	S==?ETAT_RA).

filter_patho_etat_spider(Session, Sub, State) when ?is_patho(State) ->
    case Sub of
	"mobi" -> {redirect, Session, page_patho_mobi(State)};
	"cmo"  -> {redirect, Session, page_patho_cmo(State)}
    end;

filter_patho_etat_spider(Session, Sub, SpiderData) ->
    {continue, Session}.

filter_pathological_mobi(abs,abs)->
    [{redirect, abs, ?home_mobi++"#notdeclared"},
     {redirect, abs, ?home_mobi++"#sursitaire"},
     {redirect, abs, ?home_mobi++"#suspendu"},
     {redirect, abs, ?home_mobi"#resilie"}];
filter_pathological_mobi(Session,#sdp_user_state{etat_princ=ETAT_P})
  when ?is_patho(ETAT_P) -> {redirect,Session, page_patho_mobi(ETAT_P)};
filter_pathological_mobi(Session,State) ->
    {continue, Session}.

filter_pathological_cmo(abs,abs)->
    [{redirect, abs, ?home_cmo++"#notdeclared"},
     {redirect, abs, ?home_cmo++"#sursitaire"},
     {redirect, abs, ?home_cmo++"#suspendu"},
     {redirect, abs, ?home_cmo++"#resilie"}];
filter_pathological_cmo(Session,#sdp_user_state{etat_princ=ETAT_P})
  when ?is_patho(ETAT_P) ->
    {redirect,Session, page_patho_cmo(ETAT_P)};
filter_pathological_cmo(Session,State) ->
    {continue, Session}.

page_patho_mobi(?ETAT_SI) -> ?home_mobi++"#notidentified";
page_patho_mobi(?ETAT_SF) -> ?home_mobi++"#suspendu";
page_patho_mobi(?ETAT_SV) -> ?home_mobi++"#suspendu";
page_patho_mobi(?ETAT_SA) -> ?home_mobi++"#suspendu";
page_patho_mobi(?ETAT_SR) -> ?home_mobi++"#sursitaire";
page_patho_mobi(?ETAT_RA) -> ?home_mobi++"#resilie".

page_patho_cmo(?ETAT_SI) -> ?home_cmo++"#suspendu";
page_patho_cmo(?ETAT_SF) -> ?home_cmo++"#suspendu";
page_patho_cmo(?ETAT_SV) -> ?home_cmo++"#suspendu";
page_patho_cmo(?ETAT_SA) -> ?home_cmo++"#suspendu";
page_patho_cmo(?ETAT_SR) -> ?home_cmo++"#sursitaire";
page_patho_cmo(?ETAT_RA) -> ?home_cmo++"#resilie".

%% CARREFOUR, OMER, TELE2, VIRGIN, MONACELL PATHOLOGICAL REDIRECTION
filter_pathological_all(abs,abs,Home_customer)->
    [{redirect, abs, Home_customer++"#notidentified"},
     {redirect, abs, Home_customer++"#sursitaire"},
     {redirect, abs, Home_customer++"#suspendu"},
     {redirect, abs, Home_customer++"#resilie"}];
filter_pathological_all(Session,#sdp_user_state{etat_princ=?ETAT_SI},
			     Home_customer)->
    {redirect,Session, Home_customer++"#notidentified"};
filter_pathological_all(Session,#sdp_user_state{etat_princ=?ETAT_SF},
			     Home_customer)->
    {redirect,Session, Home_customer++"#suspendu"};
filter_pathological_all(Session,#sdp_user_state{etat_princ=?ETAT_SV},
			     Home_customer)->
    {redirect,Session, Home_customer++"#suspendu"};
filter_pathological_all(Session,#sdp_user_state{etat_princ=?ETAT_SA},
			     Home_customer)->
    {redirect,Session, Home_customer++"#suspendu"};
filter_pathological_all(Session,#sdp_user_state{etat_princ=?ETAT_SR},
			     Home_customer)->
    {redirect,Session, Home_customer++"#sursitaire"};
filter_pathological_all(Session,#sdp_user_state{etat_princ=?ETAT_RA},
			     Home_customer)->
    {redirect,Session, Home_customer++"#resilie"};
filter_pathological_all(Session,State,Home_customer) ->
    {continue, Session}.

filter_state_limit(abs,URL)->
    [{redirect,abs,"#epuise"},
     {redirect,abs,"#perime"},
     {redirect,abs,URL}];
filter_state_limit(#session{prof=#profile{subscription=X}}
		   =Session,URL) 
  when X=="mobi";X=="cmo";X=="omer"->
    US = svc_util_of:get_user_state(Session),
    case svc_compte:etat_cpte(US,cpte_princ) of
	?CETAT_EP->
	    List = US#sdp_user_state.cpte_list,
	    case List of 
		undefined ->
		    {redirect,Session, "#epuise"};
		_ ->
		    [{Compte_Forfait,_}|Tail] = List,
		    case svc_compte:etat_cpte(US,Compte_Forfait) of
			?CETAT_AC -> 
			    {redirect,Session,URL};
			_ -> 
			    Etat=check_state_compte(US,Tail),
			    case Etat of 
				?CETAT_AC -> 
				    {redirect,Session,URL};
				_ -> 
				    {redirect,Session, "#epuise"}
			    end;
			_ ->
			    {redirect,Session,URL}
		    end
	    end;
	?CETAT_PE->
	    {redirect,Session, "#perime"};
	_ ->
	    {redirect,Session,URL}
    end;

filter_state_limit(Session,URL) ->
    {redirect,Session,URL}.

%% +type check_state_compte(state(),list()) -> compte_state().
%%%% Return the state of account.
check_state_compte(State, []) ->
    ?CETAT_EP;
check_state_compte(State, [{Cpte,_}|Tail]) ->    
    case svc_compte:etat_cpte(State, Cpte) of
	?CETAT_AC -> 
	    ?CETAT_AC;
	_ -> 
	    check_state_compte(State,Tail)
    end.


%% +type name(session()) -> erlinclude_result().
%%%% Prints the full name of the user.

name(abs) -> [];

name(#session{prof=Profile}) ->
    %% TODO l'espace devrait etre dans home.xml
    [ {pcdata, " "++Profile#profile.realname} ].

session_price(Session) ->
    {ok, S} = billing:current_price(Session),
    [{pcdata, currency:print(currency:to_euro(S))++" EUR"}].


version(abs)->
     [{"#123***", {redirect, abs, "#version",["SYSTEM_ID"]}}];
version(Session)->
    {redirect, Session, "#version",
     [{"SYSTEM_ID",pbutil:get_env(oma, system_id)}]}.

spider_error(?SERVICE_INDISPONIBLE,Session)->
    FailURL= pbutil:get_env(pservices_orangef, spider_url_service_indisponible),
    {redirect, Session, FailURL};
spider_error(?ACCES_REFUSE,Session)->
    FailURL= pbutil:get_env(pservices_orangef, spider_url_acces_refuse),
    {redirect, Session, FailURL};
spider_error(?PROBLEME_TECHNIQUE,Session)->
    FailURL= pbutil:get_env(pservices_orangef, spider_url_service_indisponible),
    {redirect, Session, FailURL};
spider_error(?DOSSIER_INCONNU,Session)->
    FailURL= pbutil:get_env(pservices_orangef, spider_url_dossier_inconnu),
    {redirect, Session, FailURL};
spider_error(no_resp,Session)->
    pbutil:autograph_label(error_unknow),
    FailURL= pbutil:get_env(pservices_orangef,spider_url_service_indisponible),
    {redirect, Session, FailURL};
spider_error(Error,Session)->
    slog:event(trace,?MODULE,unexpected_spider_error,{Error,Session}),
    pbutil:autograph_label(error_unknow),
    FailURL= pbutil:get_env(pservices_orangef,spider_url_service_indisponible),
    {redirect, Session, FailURL}.

slog_info(failure,?MODULE,billing_init_failed) -> 
    #slog_info{descr="The provisioning process is failed due to initialisation of billing is failed",
               operational="Check logs to see the reason of error that can not initialize the billing"};
slog_info(failure,?MODULE,provisioning_failed) -> 
    #slog_info{descr="The provisioning process is failed",
               operational="Check logs to see the reason of error that makes provisioning process failed"}.
