-module(svc_one2one).

-export([is_active/1,get_offer/1]).
-export([get_o2o_teaser/1,get_o2o_message/1]).
-export([redirect_one2one/3,include_one2one_niv1/1,include_one2one_niv3/1,
	 print_lien_notreconseil/3]).
-export([link_option/3,cb_end_of_session/2]).

%%%% pour les tests en 2à2
-export([get_package_value/1]).
%%%% fin tests en 2à2

%%%% pour les tests en charge
-export([test/0, test_int/1, test_en_charge/2]).
-export([offer_demand/1, send_stats/7, send_stats/12, print_offer_table/0]).
-export([load_test_rate/2, count_request_processes_terminations/2,
	 make_one_request/2, store_msisdns/1, erase_msisdns/0,
	 abort_load_test_rate/0]).
%%%% fin tests en charge

-include("../../pserver/include/pserver.hrl").
-include("../../xmerl/include/xmerl.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pservices_orangef/include/ftmtlv.hrl").
-include("../../pservices_orangef/include/postpaid.hrl").
-include("../include/one2one.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../../pserver/include/plugin.hrl").

-define(URL,"file:/orangef/o2o.xml#o2o_message").
-define(Max_length,165).

%%%% Service API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type redirect_one2one(session(),UrlOk::string(),UrlNok::string()) -> 
%%           erlpage_result().
%%%% Redirection depending on the existing OTO offer
%%%% Redirect to Url_oto_offer when a oto offer is known
%%%% redirect to Url_no_oto_offer when oto offer is unknown

redirect_one2one(plugin_info, Url_oto_offer, Url_no_oto_offer)->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " existance of an oto offe",
      type = command,
      license = [],
      args =
      [
       {url_oto_offer, {link,[]},
	"This parameter specifies the next page when the oto offer is known"},
       {url_no_oto_offer, {link,[]},
	"This parameter specifies the next page when the oto offer is unknown"}
      ]});redirect_one2one(abs,UrlOk,UrlNok) ->
    [{"One2One running",{redirect,abs,UrlOk}},
     {"One2One not running",{redirect,abs,UrlNok}}];
redirect_one2one(#session{prof=#profile{subscription=Sub}=Prof}=S,UrlOk,UrlNok) ->
    case is_activated(Sub) of
	true ->
	    S1 = set_up_one2one(S),
	    case is_one2one_running(S1) of
		true ->
		    {redirect,S1,UrlOk};
		false  ->
		    {redirect,S1,UrlNok}
	    end;
	_ -> {redirect,S,UrlNok}
    end.

is_activated(Sub) 
when Sub =="cmo"; Sub =="mobi" ; Sub == "postpaid"-> 
    Param = "one2one_activated_" ++ Sub,    
    case pbutil:get_env(pservices_orangef, list_to_atom(Param)) of
	true -> true;
	_ ->    false
    end;
is_activated(_) ->
    false.



%% +type include_one2one_niv1(session()) -> erlpage_result().
include_one2one_niv1(abs) ->
    [{pcdata,"suivi-conso niv 1"}];
include_one2one_niv1(#session{}=S) ->
    Sub=svc_util_of:get_souscription(S),
    LienNotreCons = 
	#hlink{href="file:/orangef/o2o.xml",
	       contents=[{pcdata,"notre conseil"}]},
    case svc_spider:get_availability(S) of
	available ->
 	    {InclRes,_} =
	    case Sub of
		X when X==postpaid;X==cmo->
		    pageutil:eval_includes(S, [] , [{include,{relurl,"file:/orangef/selfcare_long/spider.xml#one2one"}}]);
		_->
		    pageutil:eval_includes(S, [] , [{include,{relurl,"file:/orangef/selfcare_long/spider.xml#one2one"}}, br, LienNotreCons])
	    end,
	    lienmenu_alafin(InclRes);
	_ ->
 	    {InclRes,_} =
		case Sub of
		    Subscription when Subscription==postpaid;Subscription==cmo->
			pageutil:eval_includes(S, [] , [{include,{relurl,"file:/orangef/selfcare_long/selfcare_long.xml#redirect_compte_sdp"}}]);
		    _->
			pageutil:eval_includes(S, [] , [{include,{relurl,"file:/orangef/selfcare_long/selfcare_long.xml#redirect_compte_sdp"}}, LienNotreCons])
		end,
	    lienmenu_alafin(InclRes)
    end.

lienmenu_alafin([]) -> [];
lienmenu_alafin([#hlink{key="00"}=M|T]) ->
    lienmenu_alafin(T) ++ [br, M];
lienmenu_alafin([H|T]) -> [H|lienmenu_alafin(T)].

%% +type include_one2one_niv3(session()) -> erlpage_result().
include_one2one_niv3(abs) ->
    [{pcdata,"suivi-conso niv one2one"}];
include_one2one_niv3(#session{}=S) ->
    case svc_spider:get_availability(S) of
	available ->
	    [{include,{relurl,"file:/orangef/selfcare_mini/spider.xml#one2one"}}];
	_ ->
	    [{include,{relurl,"file:/orangef/selfcare_mini/spider.xml#redirect_compte_sdp"}}]
    end.

%% +type print_lien_notreconseil(session(),string(),PcData::string())->
%%                               [hlink()].
print_lien_notreconseil(abs,UrlNotreConseil,PcData) ->
    [#hlink{href=UrlNotreConseil,contents=[{pcdata,PcData},br]}];
print_lien_notreconseil(#session{}=S,UrlNotreConseil,PcData) ->
    case is_one2one_running(S) of
	true ->
	    [#hlink{href=UrlNotreConseil,
		    contents=[{pcdata,PcData},br]}];
	false  ->
	    []
    end.

%% +type is_one2one_running(session()) -> true | false.
is_one2one_running(#session{callbacks=NewCallbacks}=Session) ->
    case catch get_o2o_data(Session) of
	Data when record(Data,o2o_data) -> true;
	_ -> false
    end.

%% +type get_o2o_teaser(session()) -> [{pcdata,string()}].
get_o2o_teaser(plugin_info)->
    (#plugin_info
     {help =
      "This function include the o2o teaser",
      type = function,
      license = [],
      args =
      [
      ]});
get_o2o_teaser(abs) ->
    [{pcdata,"Teaser_o2o"}];
get_o2o_teaser(Session) ->
    Offer = (get_o2o_data(Session))#o2o_data.offer,
    Teaser_o2o = Offer#?ONE2ONE_OFFER.short_desc,
    [{pcdata,Teaser_o2o}].

%% +type get_o2o_message(session()) -> erlpage_result().
get_o2o_message(plugin_info)->
    (#plugin_info
     {help =
      "This function include the o2o message",
      type = function,
      license = [],
      args =
      [
      ]});

get_o2o_message(abs) ->
    [{pcdata,"Message_o2o"}];
get_o2o_message(Session) ->
    Offer = (get_o2o_data(Session))#o2o_data.offer,
    Message_o2o = lists:sublist(Offer#?ONE2ONE_OFFER.long_desc,?Max_length),    
    Links = build_subscription_links(Session,Offer),
    case Links of
	none ->[{pcdata,Message_o2o}];
	[] -> [{pcdata,Message_o2o}];
	_ -> [{pcdata,Message_o2o},br]++Links

    end.

%% +type link_option(session(),string(),string()) -> [hlink()].
link_option(Session,Page,Label) ->
    [#hlink{href="selfcare_long/"++Page,
	    contents=[{pcdata,Label}]}].
% link_option(Session,"sms_infos.xml",Label) ->
%     [#hlink{href="selfcare_long/sms_infos.xml",
% 	    contents=[{pcdata,Label}]}];
% link_option(Session,"mmsinfos.xml",Label) ->
%     [#hlink{href="selfcare_long/mmsinfos.xml",
% 	    contents=[{pcdata,Label}]}].


%% +type cb_end_of_session(session(),Args::string()) -> {ok,session()}.
cb_end_of_session(#session{prof=#profile{subscription=Sub}=Prof}=Session,Args) ->
    %% Encapsulation to prevent internals...
    slog:event(count,?MODULE,{cb_end_of_session,Sub}),
    slog:event(trace,?MODULE,cb_end_of_session,Prof),
    case catch cb_end_of_session_int(Session,Args) of
	{'EXIT',Er} -> 
	    slog:event(failure,?MODULE,oto_callback,Er),
	    ok;
	Else ->
	    Else
    end.

cb_end_of_session_int(#session{prof=#profile{subscription=Sub}=Prof}=Session,Args) ->
    Log = Session#session.log,
    CountP = count(Log,Sub),
    if CountP =/= 0 -> 
	    DCS = get(ussdc_dcs),
	    URL = ?URL ++"_"++Sub,
	    P = pageutil:get_page(Session,URL),
	    {TempPages, _} = page_ussd:evaluate(Session, P, [], DCS),
	    NbPages = length(TempPages),
	    Quotient = case NbPages of
			   0 ->
			       slog:event(failure,?MODULE,zero_lenghted_offer),
			       0;
			   _ -> CountP/NbPages*100
		       end,
	    BornePart = pbutil:get_env(pservices_orangef,
				       one2one_visu_partielle),
	    BorneTot = pbutil:get_env(pservices_orangef,one2one_visu_totale),
	    if %% Stats are sent only in this case :
		Quotient >= BornePart ->
		    send_stats_int(Session,Quotient,BornePart,BorneTot,
				   NbPages,CountP);
		true ->
		    slog:event(count,?MODULE,{quotient_inf_borne_part,Sub}),
		    ok
	    end;
       %% no need to test return value, as no resending should be done...
       true -> 
	    %% NbPages = 0 means the offer was not even recovered -> no stats
	    %% Note : This should not happen
	    slog:event(count,?MODULE,{nb_pages_nul,Sub}),
	    ok
    end,
    {ok,Session}.


%%%% Service utils %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type set_up_one2one(session()) -> session().
set_up_one2one(#session{}=Session) ->
    case is_one2one_running(Session) of
	true -> Session;
	false -> Msisdn = (Session#session.prof)#profile.msisdn,
		 Subscr = svc_util_of:get_souscription(Session),
		 SpiderAvail = svc_spider:get_availability(Session),
		 case {Msisdn,SpiderAvail} of
		     {{na,_},_} -> Session;
		     {_,Avail} when Avail=/=available -> Session;
		     {_,_} -> 
			 SpiderProduct = svc_spider:get_offerPOrSUid(Session),
			 case get_package_value(SpiderProduct) of
			     package_not_found ->
				 Session;
			     PackageValue ->
				 case catch do_the_job(format(Msisdn), PackageValue) of
				     {'EXIT',E} -> 
					 slog:event(internal,?MODULE,o2o_unexpected_error,E),
					 Session;
				     {one2one,not_active} -> Session; %% already logged
				     {one2one,no_answer} -> Session; %% already logged
				     {error,offer_not_found,Code,Error} ->
					 slog:event(warning,?MODULE,{offer_not_found,Code},Error),
					 Session;
				     {ok,Offer,NumDossier,IdSession} ->
					 NewCallbacks = create_callback(Session#session.callbacks),
					 O2OData = #o2o_data{
					   offer=Offer,numdossier=NumDossier,idsession=IdSession},
					 SDPData = svc_util_of:get_user_state(Session),
					 SDPData1 = update_state(SDPData,O2OData),
					 Session1 = svc_util_of:update_user_state(Session, SDPData1),
					 Session2 = Session1#session{callbacks=NewCallbacks},
					 Session2
				 end
			 end
		 end   
    end.

update_state(#sdp_user_state{} = State,O2OData)->
    State#sdp_user_state{o2o_data=O2OData};
update_state(#postpaid_user_state{} = State,O2OData)->
    State#postpaid_user_state{o2o_data=O2OData}.

create_callback([]) ->
    [{?MODULE,cb_end_of_session,[]}];
create_callback(ExistingCallbacks) ->
    case lists:keysearch(?MODULE,1,ExistingCallbacks) of
	{value,_} -> ExistingCallbacks;
	_ -> 
	    [{?MODULE,cb_end_of_session,[]} | ExistingCallbacks]
    end.

%% +type do_the_job(MSISDN::string()) -> 
%%          {one2one,not_active} | {one2one,no_answer} | 
%%          {error,offer_not_found,term(),term()} |
%%          {ok,one2one_offer(),string(),string()}.
do_the_job(MSISDN, PACKAGE_VALUE) ->
    T0 = pbutil:unixmtime(),

    case is_active(now) of
	true ->
	    case oto_request:request(MSISDN, PACKAGE_VALUE) of
		{ok,#process_event_resp{code=Code, numdossier=NumDossier,
					idsession=IdSession}=Resp} ->
		    Offer = get_offer(Code),
		    case Offer of
			{error,offer_not_found,_,_} -> 
			    Offer;
			_ -> 
			    T1 = pbutil:unixmtime(),
			    slog:stats(perf,?MODULE,o2o_resp_time,T1 - T0),
			    {ok,Offer,NumDossier,IdSession}
		    end;
		%% these errors are already logged in oto_request
		{resp_with_error_code,_} ->
		    {one2one,no_answer};
		{malformed_resp,_} ->
		    {one2one,no_answer};
		{unexpected_error,_} ->
		    {one2one,no_answer};
		{no_answer,Reason} ->
		    {one2one,no_answer}
	    end;
	_ ->
	    slog:event(trace,?MODULE,not_active),
	    {one2one,not_active}
    end.

%% +type send_stats_int(session(),integer(),integer(),
%%                      integer(),integer(),integer()) -> 
%%                {ok,stats_sent} | {no_answer,term()} | 
%%                {malformed_resp,term()} | {unexpected_error,term()}.
send_stats_int(Session,Quotient,BornePart,BorneTot,NbPages,CountP) ->
    O2O_data = get_o2o_data(Session),
    Offer = O2O_data#o2o_data.offer,
    CodeOffre= Offer#?ONE2ONE_OFFER.code,

    Success_Pages = 
	case Offer#?ONE2ONE_OFFER.labels of
	    undefined -> 
		[];
	    Labels when list(Labels) ->
		case catch pbutil:get_env(pservices_orangef,
					  one2one_subscription_redir) of
		    {'EXIT',_} -> 
			slog:event(failure,?MODULE,missing_env,
				   one2one_subscription_redir),
			[];
		    SubscriptionMFAs when list(SubscriptionMFAs) ->
			get_success_pages_int(Labels,SubscriptionMFAs,[])
		end
	end,
    Subscription = case Success_Pages of
		       [] -> no;
		       Success_Pages when list(Success_Pages) -> 
			   {ok,Res} = 
			       find_success_pages(Session,Success_Pages),
			   Res
		   end,
    {IndActivation,CanalAbout} =
	if
	    Subscription == yes ->
		{pbutil:get_env(pservices_orangef,
				one2one_subscription_tag),
		 ?CANAL_ABOUT_VALUE};
	    true -> {"",""}
	end,
    IndEcoute = 
	if 
	    %% Quotient < BornePart -> not possible here
	    %%     pbutil:get_env(pservices_orangef,
	    %%	                  one2one_nonecoute_tag);
	    Quotient < BorneTot -> 
		pbutil:get_env(pservices_orangef,
			       one2one_ecoutepartielle_tag);
	    true -> 
		pbutil:get_env(pservices_orangef,
			       one2one_ecoutetotale_tag)
	
	end,
    slog:event(count,?MODULE,{stats_sent,IndEcoute,IndActivation}),
    IdSession = O2O_data#o2o_data.idsession,
    NumDossier = O2O_data#o2o_data.numdossier,
    {{Yy,Mois,Dd},{Hh,Min,Ss}} = 
	calendar:now_to_local_time(now()),
    HeureEcoute = 
	pbutil:sprintf("%d-%02d-%02d %02d:%02d:%02d",
		       [Yy,Mois,Dd,Hh,Min,Ss]),
    Stats=#remontee_stat{
      idsession=IdSession,numdossier=NumDossier,code=CodeOffre,
      heureecoute=HeureEcoute,indecoute=IndEcoute,
      dureemessage=NbPages,dureeecoute=CountP,indactivation=IndActivation,
      canalabout=CanalAbout},
    GetSpiderProduct = svc_spider:get_offerPOrSUid(Session),
    case GetSpiderProduct of
	undefined -> [];
	SpiderProduct ->	    
	    Package_Value = get_package_value(SpiderProduct),
	    oto_request:request(Stats, Package_Value);
	_ ->
	    []
    end.

%%% From Logs, count the number of pages visited
count(Log,Sub) ->
    URL = ?URL ++ "_"++Sub,
    count(lists:reverse(Log),URL,0,0).

count([],_,C,M) ->
    if M> C -> M;
       true -> C
    end;
count([{'M',"Next Page"},{'P',URL}|T],URL,C,M) ->
    %% real next page -> +1
    count(T,URL,C+1,M);
count([{'P',URL}|T],URL,_,M) ->
    %% first page (eventually after navigation)
    count(T,URL,1,M);
count([{'P',_}|T],URL,C,M) ->
    %% other page, set max if needed and reset
    NewM = if M> C -> M;
	      true -> C
	   end,
    count(T,URL,0,NewM);
count([_|T],URL,C,M) ->
    count(T,URL,C,M).

%%% From Log, get the Url OTO.




%%% Check in log if success page of option subscription was reached
get_success_pages_int([],Env,Acc) ->
    Acc;
get_success_pages_int([{_,Opt}|Rest],Env,Acc) ->
    case catch lists:keysearch(Opt,1,Env) of
	{value,{_,_,_,_,SuccessPage}} ->
	    get_success_pages_int(Rest,Env,[SuccessPage | Acc]);
	_ ->
	    get_success_pages_int(Rest,Env,Acc)
    end.

find_success_pages(Session,[]) ->
    {ok,no};
find_success_pages(Session,[Page|OtherPages]) ->
    case find_success_page(Session,Page) of
	{ok,yes} -> {ok,yes};
	_ -> find_success_page(Session,OtherPages)
    end.

find_success_page(Session,Success) ->
    Log = Session#session.log,
    find_success_page_int(Log,Success).

find_success_page_int([],_) -> {ok,no};
find_success_page_int([{'P',Success}|_],Success) -> {ok,yes};
find_success_page_int([H|T],Success) -> 
    find_success_page_int(T,Success).
    
%%% recover offer %%%
%% +type get_offer(integer()) -> one2one_offer() | {error,term()}.
get_offer(Code) ->
    case catch mnesia:dirty_match_object(#?ONE2ONE_OFFER{code=Code,_='_'}) of
	[Offer|_] ->
	    Offer;
	Error ->
	    slog:event(error,?MODULE,get_offer,{db_error,Error}),
	    {error,offer_not_found,Code,Error}
    end.



%%% Schedule %%%

%% +type is_active(now | date()) -> true | false.
%%% check if at the present time, the one2one service is active
%%% start with global parameter
is_active(now) ->
    is_active(calendar:now_to_local_time(now()));
is_active(DateTime) ->
    is_in_schedule(DateTime).

%% +type is_in_schedule(date()) -> true | false.
%%% then check if the current day is a work day
is_in_schedule(DateTime) ->
    ScheduleConf_tuple = pbutil:get_env(pservices_orangef,one2one_schedule),
    ScheduleConf = tuple_to_list(ScheduleConf_tuple),
    Schedule = pbutil:pairs_to_record(
		 week_schedule,
		 [monday,tuesday,wednesday,thursday,friday,saturday,sunday],
		 ScheduleConf),
    time_is_in_schedule(DateTime,Schedule).

%% +type time_is_in_schedule(date(),week_schedule()) -> true | false.
%%% then check current time is in schedule
time_is_in_schedule(Now,Schedule) ->
    {Date,Time} = Now,
    Day_of_week = get_day(calendar:day_of_the_week(Date),Schedule),
    case Day_of_week of
	{off,_,_} -> false;
	{on,Start,Stop} ->
	    is_before({Date,Start},Now) and is_before(Now,{Date,Stop})
    end.

get_day(1,Schedule) -> Schedule#week_schedule.monday;
get_day(2,Schedule) -> Schedule#week_schedule.tuesday;
get_day(3,Schedule) -> Schedule#week_schedule.wednesday;
get_day(4,Schedule) -> Schedule#week_schedule.thursday;
get_day(5,Schedule) -> Schedule#week_schedule.friday;
get_day(6,Schedule) -> Schedule#week_schedule.saturday;
get_day(7,Schedule) -> Schedule#week_schedule.sunday.
    
%% +type is_before(date(),date()) -> true | false.
is_before(D1,D2) ->
    D1Secs = calendar:datetime_to_gregorian_seconds(D1),
    D2Secs = calendar:datetime_to_gregorian_seconds(D2),
    D1Secs =< D2Secs.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Schedule - end %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_o2o_data(#sdp_user_state{} =State) ->
    State#sdp_user_state.o2o_data;
get_o2o_data(#postpaid_user_state{} =State) ->
    State#postpaid_user_state.o2o_data;
get_o2o_data(Session) ->
    SDPData = svc_util_of:get_user_state(Session),
    get_o2o_data(SDPData).


format("+336"++Msisdn) ->
    "06"++Msisdn;
format("336"++Msisdn) ->
    "06"++Msisdn;
format("+337"++Msisdn) ->
    "07"++Msisdn;
format("337"++Msisdn) ->
    "07"++Msisdn;
format(Msisdn) ->
    %% not modified in case of tests (+999...) or if correctly set 06XXXXXXXX
    Msisdn.

build_subscription_links(Session,Offer) ->
    case Offer#?ONE2ONE_OFFER.labels of
	undefined -> 
	    [];
	Labels when list(Labels) ->
	    case catch pbutil:get_env(pservices_orangef,
				      one2one_subscription_redir) of
		{'EXIT',_} -> 
		    slog:event(failure,?MODULE,missing_env,
			       one2one_subscription_redir),
		    [];
		List when list(List) -> 
		    build_sub_links_int(Session,Labels,List,[])
	    end
    end.

build_sub_links_int(Session,[],_,Acc) ->
    lists:reverse(Acc);
build_sub_links_int(Session,[{Label,Opt}|Rest],Env,Acc) ->
    case catch lists:keysearch(Opt,1,Env) of
	{value,{_,M,F,A,_}} ->
	    A1=replace_label(A,Label),
	    Link = apply(M,F,[Session|A1]),
	    if 
		length(Acc)>0 ->
		    %% if at least one link is there, add a br
	       	    build_sub_links_int(Session,Rest,Env,Link++[br]++Acc);
		true ->
	       	    build_sub_links_int(Session,Rest,Env,Link)
	    end;
	_ -> undefined
    end.

replace_label([A1,A2],Label) ->
    [A1,lists:flatten(io_lib:format(A2,[Label]))];
replace_label([A1,A2,A3],Label) 
  when A1=="opt_vacances";
       A1=="opt_illimite_kdo"->
    [Z1,Z2]=string:tokens(A2, ","),
    Args = lists:flatten(io_lib:format(Z1,[Label]))++","++
	lists:flatten(io_lib:format(Z2,[Label])),
    [A1,Args,A3];
replace_label([A1,A2,A3],Label) ->
    [A1,lists:flatten(io_lib:format(A2,[Label])),A3].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% From here on : tests en charge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Sequentially, as fast as possible.
test_en_charge(0,_) ->
    io:format("Done");
test_en_charge(N,MSISDN) ->
    case catch do_the_job(MSISDN, get_package_value("MOB")) of
	{ok,Offer,_,_} -> 
	    io:format("OK, Step ~p, Offer : ~p~n",[N,Offer]),
	    test_en_charge(N-1,MSISDN);
	Error ->
	    io:format("Nok,Step ~p, Error : ~p~n",[N,Error])
    end.
    
%% N requests in around 4 seconds
test() ->
    N =100,
    Time = pbutil:unixmtime(),
    ok = test(N),
    Diff = pbutil:unixmtime() - Time,
    io:format("O2O : ~p requests launched in ~p milliseconds~n",[2*N,Diff]),
    io:format("O2O : 80 requests /sec expected~n",[]).
    %%io:format("O2O : avg resp time ~n",[Total / N]).

test(0) ->
    ok;
test(N) ->
    proc_lib:start_link(?MODULE, test_int, [N]),
    receive after 25 -> ok end,
    test(N-1).


test_int(N) ->
    proc_lib:init_ack(self()),
    pong = net_adm:ping(possum@localhost), 
    case catch do_the_job("+99900000005", get_package_value("MOB")) of
	{ok,_,_,_} -> 
	    ok;
	Error_ -> 
	    io:format("Step ~p, Error : ~p~n",[2*N,Error_])
    end,
    case catch do_the_job("+99900000005", get_package_value("MOB")) of
	{ok,_,_,_} -> 
	    ok;
	Error1_ -> 
	    io:format("Step ~p, Error : ~p~n",[2*N-1,Error1_])
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

offer_demand(Msisdn) ->
    oto_request:request(Msisdn, get_package_value("MOB")).

send_stats(
  Id_session, Num_dossier, Code, Heure_ecoute, Indice_ecoute,
  Duree_message, Duree_ecoute) ->
    send_stats(Id_session, Num_dossier, Code, Heure_ecoute, Indice_ecoute,
	       Duree_message, Duree_ecoute, "", "", "", "", "").

send_stats(
  Id_session, Num_dossier, Code, Heure_ecoute, Indice_ecoute,
  Duree_message, Duree_ecoute, Canal_about, Ind_activation, P1, P2, P3) ->
    R = #remontee_stat{
      idsession = Id_session,
      numdossier = Num_dossier,
      code = Code,
      heureecoute = Heure_ecoute,
      indecoute = Indice_ecoute,
      dureemessage = Duree_message,
      dureeecoute = Duree_ecoute,
      canalabout = Canal_about,
      indactivation = Ind_activation,
      param1 = P1,
      param2 = P2,
      param3 = P3},
    oto_request:request(R, get_package_value("MOB")).

print_offer_table() ->
    F = fun () -> mnesia:match_object(#one2one_offer{_ = '_'}) end,
    {atomic, L} = mnesia:transaction(F),
    L.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Usage:
% - use store_msisdns/1,
% - call load_test_rate/2,
% - optionally call erase_msisdns/0 to erase the MSISDNs from the dictionnary.
% To abort a test, call abort_load_test_rate/0.

%% +type store_msisdns(FN::string()) -> ok.
%%%% Stores the N MSISDNs found in the file named FN in the process dictionnary
%%%% under the keys {oto_load_tests_msisdn, I}, for all 1 <= I <= N. There
%%%% must be one MSISDN per line in the file, `parsing" stops at the first empty
%%%% line. FN must be in priv/one2one.
store_msisdns(FN) ->
    P = filename:join([code:priv_dir("pservices_orangef"), "one2one", FN]),
    {ok, In} = file:open(P, [read]),
    N = store_msisdns_aux(In, 1),
    put(oto_number_of_msisdns, N),
    ok.


%% +type store_msisdns_aux(In::string(), integer()) -> integer().
%%%% Returns the number of MSISDNs stored.
store_msisdns_aux(In, I) ->
    case io:get_line(In, "") of
	eof ->
	    I - 1;
	S   ->
	    case string:strip(string:strip(S, right, $\n)) of
		"" ->
		    I - 1;
		Msisdn ->
		    put({oto_load_tests_msisdn, I}, Msisdn),
		    store_msisdns_aux(In, I + 1)
	    end 
    end.


%% +type erase_msisdns() -> integer().
%%%% Returns the number of MSISDNs that were indicated in the
%%%% oto_number_of_msisdns entry in the dictionnary.
erase_msisdns() ->
    erase_msisdns_aux(1),
    erase(oto_number_of_msisdns).


%% +type erase_msisdns_aux(integer()) -> ok.
erase_msisdns_aux(N) ->
    case erase({oto_load_tests_msisdn, N}) of
	undefined -> ok;
	_         -> erase_msisdns_aux(N + 1)
    end.


%% +type abort_load_test_rate() -> term().
abort_load_test_rate() ->
    load_test_rate ! abort.


%% +deftype hertz() = integer().
%% +type load_test_rate(integer(), hertz()) -> ok.
%%%% Makes N requests (in parallel) at rate R (in Hz). Displays the time
%%%% taken to launch the request processes, the time it took for all the
%%%% requests to be made and the number of request successes and failures.
load_test_rate(N, R) ->
    register(load_test_rate, self()),
    CPid = proc_lib:start_link(
	     ?MODULE, count_request_processes_terminations, [N, self()]),
    io:format(
      "About to launch ~p processes at rate ~p processes/s.~n"
      "Send an abort atom to load_test_rate (PID ~p) to stop "
      "spawning processes.~n",
      [N, R, self()]),
    T0 = pbutil:unixmtime(),
    Res = load_test_interval(N, trunc(1000/R), CPid, pbutil:unixmtime()),
    T1 = pbutil:unixmtime(),
    case Res of
	aborted ->
	    io:format("Aborted after ~p milliseconds~n", [T1 - T0]),
	    stop_crpt(CPid);
	ok ->
	    io:format("~p request processes started in ~p milliseconds~n",
		      [N, T1-T0]),
	    io:format(
	      "Waiting for count_request_processes_terminations (abort by "
	      "sending an abort atom to load_test_rate (PID ~p)~n", [self()]),
	    receive
		{Status, S, F, CRT, Min, Max, Errors} ->
		    case Status of
			all_requests_completed ->
			    io:format("All ~p requests processes have terminated ",
				      [S+F]);
			aborted ->
			    stop_crpt(CPid),
			    io:format("Aborted after ~p requests ", [S+F])
		    end,
		    T2 = pbutil:unixmtime(),
		    ER = (S + F) / ((T1 - T0) / 1000), % effective rate
		    MRT = case S of 0 -> -1; _ -> CRT / S end,
		    io:format(
		      "in ~p milliseconds.~n~p successes, ~p failures.~n"
		      "Effective rate: ~p requests/s~n"
		      "Mean response time: ~p~n"
		      "Minimum response time: ~p, maximum: ~p~n"
		      "Errors:~n",
		      [T2 - T0, S, F, ER, MRT, Min, Max]),
		    print_dict(Errors)
	    end
    end,
    unregister(load_test_rate).


%% +type stop_crpt(pid()) -> bool().
stop_crpt(CPid) ->
    io:format("Sending abort to count_request_processes_terminations... "),
    CPid ! abort,
    TO = 10000,
    receive
	aborted ->
	    io:format("acknowledged.~n"),
	    true
    after TO ->
	    io:format("Not acknowledged after ~p~n", [TO]),
	    false
    end.


%% +type load_test_interval(integer(),integer(),pid(),integer())->
%%                          ok | aborted.
%%%% Launches N requests (in parallel) each Int milliseconds. CPid is the
%%%% PID of the process to which request_succeeded or request_failed messages
%%%% must be sent.
load_test_interval(0, _Int, CPid, _T) ->
    ok;
load_test_interval(N, Int, CPid, T) ->
    NM = get(oto_number_of_msisdns),
    Msisdn = get({oto_load_tests_msisdn, random:uniform(NM)}),
    Delay = T - pbutil:unixmtime(),
    case Delay >= 0 of
	true  -> receive after Delay -> ok end;
	false -> ok % io:format("Overloaded, delay = ~p~n", [Delay])
    end,
    spawn_link(?MODULE, make_one_request, [CPid, Msisdn, get_package_value("MOB")]),
    receive
	abort ->
	    io:format("load_test_interval: aborted.~n"),
	    aborted
    after 0 ->
	    load_test_interval(N - 1, Int, CPid, T + Int)
    end.


%% +type make_one_request(pid(), string()) -> ok.
%%%% Makes an `offer number request' and sends request_succeeded
%%%% (resp. request_failed) to CPid in case of success (resp. failure).
make_one_request(CPid, Msisdn) ->
%% for testing
%    T0 = pbutil:unixmtime(),
%    receive after 1000 -> ok end,
%    %%io:format("mor `" ++ Msisdn ++ "'~n"),
%    T1 = pbutil:unixmtime(),
%    case (pbutil:unixmtime() rem 10) == 0 of
%       true  -> CPid ! {request_failed, error, T1 - T0};
%       false -> CPid ! {request_succeeded, T1 - T0}
%    end. 
    T0 = pbutil:unixmtime(),
    Res =
	case oto_request:request(Msisdn, get_package_value("MOB")) of
	    {ok,#process_event_resp{code=Code, numdossier=NumDossier,
				    idsession=IdSession}=Resp} ->
		Offer = get_offer(Code),
		case Offer of
		    {error,offer_not_found,_,_} ->
                        offer_not_found;
		     _ -> 
		        T = pbutil:unixmtime(),
		        slog:stats(perf,?MODULE,o2o_resp_time,T - T0),
		        ok
		end;
	    %% these errors are already logged in oto_request
	    {resp_with_error_code,{_,N}} ->
                {resp_with_error_code, N};
	    {malformed_resp,_} ->
                malformed_resp;
	    {unexpected_error,_} ->
                unexpected_error;
	    {no_answer,Reason} ->
                io:format("~p: no_answer: ~p~n", [Msisdn, Reason]),
                no_answer
         end,
    T1 = pbutil:unixmtime(),
    case Res of
	ok ->
	    CPid ! {request_succeeded, T1 - T0};
	Error ->
            io:format("*** Error: ~p~n~n", [Error]),
	    CPid ! {request_failed, Error, T1 - T0}
    end.


%% +type count_request_processes_terminations(integer(), pid()) -> Any.
%%%% Sends all_requests_completed to Pid when it has received N request
%%%% completion messages.
count_request_processes_terminations(N, Pid) ->
    proc_lib:init_ack(self()),
    count_request_processes_terminations_aux(N, Pid, 0, 0, 0, 999999999, -1).


%% +type count_request_processes_terminations_aux(
%%   integer(), pid(), integer(), integer(), integer(),
%%   integer(), integer()) -> Any.
%%%% S: number of successes, F: number of failures, CRT: cumulated
%%%% successful requests response times, Min: minimum reponse time,
%%%% Max: maximum response time.
count_request_processes_terminations_aux(0, Pid, S, F, CRT, Min, Max) ->
    Pid ! {all_requests_completed, S, F, CRT, Min, Max, get()};
count_request_processes_terminations_aux(N, Pid, S, F, CRT, Min, Max) ->
    receive
	{request_succeeded, T} ->
	    NMin = pbutil:min(T, Min),
	    NMax = pbutil:max(T, Max),
	    count_request_processes_terminations_aux(
	      N-1, Pid, S+1, F, CRT+T, NMin, NMax);
	{request_failed, Error, T} ->
            incr(Error),
	    count_request_processes_terminations_aux(
	      N-1, Pid, S, F+1, CRT, Min, Max);
	abort ->
	    Pid ! {aborted, S, F, CRT, Min, Max, get()}
    end.


%% +type incr(Key) -> undefined | Value.
%%%% Increments the value corresponding to Key in the dictionnary, or
%%%% sets it to 1 if unset.
incr(Key) ->
    Val =
	case get(Key) of
	    undefined -> 0;
	    V         -> V
	end,
    put(Key, Val + 1).


%% +type print_dict([{Key, Value}]) -> ok.
%%%% Prints the content of a dictionnary except the entries which key
%%%% is an atom starting with a dollar character.
print_dict([]) ->
    ok;
print_dict([{Key, Val} | T]) when atom(Key) ->
    case atom_to_list(Key) of
	"$" ++ _ ->
	    ok;
	_ ->
	    io:format("~p: ~p~n", [Key, Val])
    end,
    print_dict(T);
print_dict([{Key, Val} | T]) ->
    io:format("~p -> ~p~n", [Key, Val]),
    print_dict(T).


get_package_value(Subscr) ->
    List=pbutil:get_env(pservices_orangef,codeOffre_codeDomaine_souscription_packageOTO),
    case lists:keysearch(Subscr, 1, List) of
	{value, {Subscr, _,_,PACKAGE_VALUE}} -> 
	    case PACKAGE_VALUE of
		"non_defini"->
		    package_not_found;
		_->
		    PACKAGE_VALUE
	    end;
	_ -> 
	    slog:event(failure,?MODULE,unknown_package_value, Subscr),
	    package_not_found
    end.
