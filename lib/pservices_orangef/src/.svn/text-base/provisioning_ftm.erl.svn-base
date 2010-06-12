-module(provisioning_ftm).

-include("../../oma/include/slog.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").
-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../include/postpaid.hrl").
-include("../include/opim.hrl").
-include("../include/dme.hrl").
-include("../include/ftmtlv.hrl").


-export([init_session/1,niveau_provisioning/1,store_user/2]).
-export([dump_billing_info/1]).
-export([read_sdp_state/1, reset_sdp_state/1]).
-export([update_profile_with_state/2]).

%% for crontab
-export([write_to_file/0]).

%% for test environment
-export([insert_profile/1]).
-export([slog_info/3]).

%% +type init_session(session()) -> {nok, error} |
%%                                  {ok, session()} 
%%%% Processus d'initialisation du provisioning
init_session(#session{prof=#profile{imsi={na,_}}}=Session)->
    slog:event(trace,?MODULE,cannot_profile,imsi_unknown),
    {nok, imsi_unknown};
init_session(#session{prof=#profile{anon=true,imsi=IMSI}=Prof}=Session) ->
    slog:event(trace, ?MODULE, imsi_unknown_by_cc),
    query_ocf(Session);
init_session(#session{prof=#profile{subscription=Sub}}=Session) 
when Sub=="anon" ->
    slog:event(trace, ?MODULE, subscription_is_anon),
    query_ocf(Session);
init_session(#session{prof=#profile{terminal=#terminal{imei={na,_}=IMEI}}}=Session)-> 
    slog:event(trace, ?MODULE, imei_is_not_active, IMEI),
    query_ocf(Session);
init_session(#session{prof=#profile{terminal=#terminal{imei=IMEI}}}=Session)
when IMEI==""; IMEI=="NULL" -> 
    slog:event(trace, ?MODULE, imei_is_not_active, IMEI),
    query_ocf(Session);
init_session(Session) ->
    NbSubsOcfFailed = svc_util_of:get_nb_subs_ocf_failed(Session),
    case NbSubsOcfFailed of
        0 -> {ok, Session};
        _ -> 
            query_ocf(Session)
    end.
    
%% +type query_ocf(session()) -> {nok, error} |
%%                               {ok, session()} 
%%%% Processus d'interrogation OCF
query_ocf(#session{prof=#profile{imsi=IMSI}=Prof}=Session) -> 
    NbSubsOcfFailed = svc_util_of:get_nb_subs_ocf_failed(Session),
    case NbSubsOcfFailed of 
        0 ->	 
            case catch ocf_rdp:getUserInformationByImsi(IMSI) of
                {ok,#ocf_info_client{}=OCF_INFO}->
                    Prof1 = update_profile(Prof,OCF_INFO,IMSI,all),
                    Prof2 = store_user(Prof,Prof1),
                    {ok, Session#session{prof=Prof2}};
                Error->
                    slog:event(trace, ?MODULE, could_not_query_ocf, Error),
                    {nok, Error}
            end;
        _ ->
		    case catch (ocf_rdp:subscribeByImsi(IMSI)) of
			{error,?MULTIPLE_SOUSCRIPTION} ->
			    Session1 = svc_util_of:set_tech_seg_int(Session, ?OCF_QUERY_FAILED),
			    Prof1 = store_user(Prof,Session1#session.prof),
			    NewSession = svc_util_of:update_nb_subs_ocf_failed(Session1#session{prof=Prof1},0),
			    case catch ocf_rdp:getUserInformationByImsi(IMSI) of
				{ok,#ocf_info_client{}=OCF_INFO}->
				    Prof2 = update_profile(Prof1,OCF_INFO,IMSI,all),
				    Prof3 = store_user(Prof1,Prof2),
				    {ok, NewSession#session{prof=Prof3}};
				Error->
				    slog:event(trace, ?MODULE, could_not_query_ocf, Error),
				    {nok, Error}
			    end;
			{ok,#ocf_info_client{}=OCF_INFO} -> 
			    Prof1 = update_profile(Prof,OCF_INFO,IMSI,all),
			    Prof2 = store_user(Prof,Prof1),
			    NewSession = svc_util_of:update_nb_subs_ocf_failed(Session#session{prof=Prof2},0),
			    {ok, NewSession};
			{error,Error_Code}->
			    Session1 = svc_util_of:set_tech_seg_int(Session, ?OCF_QUERY_FAILED),
			    Prof1 = store_user(Prof,Session1#session.prof),
			    NewSession = case NbSubsOcfFailed of 
					     -1 -> 
						 svc_util_of:update_nb_subs_ocf_failed(Session1#session{prof=Prof1},1);
					     _ -> 
						 svc_util_of:update_nb_subs_ocf_failed(Session1#session{prof=Prof1},NbSubsOcfFailed+1)
					 end,
			    {ok, NewSession#session{prof=Prof1}};
			Error->
			    %% possibly multiple entries, it should not be managed here
			    slog:event(trace, ?MODULE, could_not_query_ocf, Error),
			    {nok, Error}
		    end
    end.

write_to_file() ->
    Query = io_lib:format("SELECT uid,imsi,msisdn,nb_subs_ocf_failed FROM users LEFT JOIN users_orangef_extra USING (uid) "
			  "WHERE nb_subs_ocf_failed > '~p'",[0]),
    case sql_specific:execute_stmt(Query,[users,users_orangef_extra],5000) of
	{selected,_,[[Uid,Imsi,Msisdn,Nb_subs_ocf_failed]]} -> 
	    Nb_tentative = pbutil:get_env(pservices_orangef,nb_tentative),
	    case list_to_integer(Nb_subs_ocf_failed) > Nb_tentative of 
		true -> 
		    slog:event(failure,?MODULE,nb_echec_query_ocf_depassement_seuil);
		_ ->
		    Filepath=pbutil:get_env(pservices_orangef,location_dossier_en_echec_ocf),
		    slog:event(trace,?MODULE,filepath,Filepath),
		    {Y,M,D}=date(),
		    Filename="Dossier_en_echec_OCF_"++lists:flatten(pbutil:sprintf("%02d%02d%02d",[D,M,Y-2000])),
		    Msg=io_lib:format("~p;~p;~p\n",[Uid,Imsi,Msisdn]),
		    case file:open(Filepath++Filename++".csv",[append]) of
			{ok, FD}-> case file:write(FD,Msg) of
				       ok-> 
					   file:close(FD);
				       _ -> 
					   slog:event(failure,?MODULE,error_to_write_dossier_en_echec_ocf_file)
				   end;
			_  -> 
			    slog:event(internal,?MODULE,error_to_open_dossier_en_echec_ocf_file)
		    end
	    end;
	_ ->
	    slog:event(count, ?MODULE, nb_subs_ocf_failed_less_than_1),
	    exit(no_found)
    end.

update_profile(#profile{terminal=Term}=Prof,
           #ocf_info_client{ussd_level=UL,tac=Tac,msisdn=Msisdn,
                segmentCode=SegCo,tech_seg=TSC,prepaidFlag=PrepaidFlag},
           IMSI,
           What) ->
    pbutil:autograph_label(ocf_profile_found),
    Terminal = terminal_of:info(Tac,UL,Term),
    Prof1 = Prof#profile{terminal=Terminal},
    Prof2 = case What of
        all -> update_subscription(Prof1,SegCo,PrepaidFlag);
        _ -> Prof1
        end,
    Prof3 = update_tech_seg(Prof2,TSC),
    update_profile_with_state(Prof3, {Msisdn, IMSI}).

update_subscription(Profile,SegmentCode,PrepaidFlag) ->
    case PrepaidFlag of 
    X when X=="OFR";X=="ENT";X=="SCS" ->
        Profile#profile{subscription="dme"};
    _->
        case ocf_rdp:segco_to_subscription(SegmentCode) of
            Sub_New when list(Sub_New)->
                Profile#profile{subscription=Sub_New};
            unknown_sub->
                Profile#profile{subscription="anon"}
        end
    end.

update_tech_seg(Profile,TSC) ->
    TSI = case ocf_rdp:tech_seg_code_to_int(TSC) of
          not_found ->
          slog:event(internal,?MODULE,unknown_tech_seg_code,TSC),
          ?OCF_UNKNOWN_CODE;
          TSI_ ->
          TSI_
      end,
    svc_util_of:set_tech_seg_int_profile(Profile, TSI).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type update_profile_with_state(profile(), {Msisdn::string(),
%%                                             Imsi::string()}) -> profile().
%%%% Updates a profile according to a sdp_user_state
update_profile_with_state(Profile, {SMsisdn, SImsi}) ->
    %% If the profile already contains a MSISDN (resp IMSI), check
    %% that it matches the result from the SDP.
    MSISDN = case {Profile#profile.msisdn, SMsisdn} of
         {{na,_},         "0"  ++MSISDN_} -> "+33"++MSISDN_;
         {{na,_},         "+33"++MSISDN_} -> "+33"++MSISDN_;
         {{na,_},         "9"  ++MSISDN_} -> "+99"++MSISDN_;
         {"+33"++MSISDN_, "0"  ++MSISDN_} -> "+33"++MSISDN_;
         {"+33"++MSISDN_, "+33"++MSISDN_} -> "+33"++MSISDN_;
         {"+99"++MSISDN_, "9"  ++MSISDN_} -> "+99"++MSISDN_;
         {"+99"++MSISDN_, "+99"++MSISDN_} -> "+99"++MSISDN_;
         {_,"99"++MSISDN_} -> "+999"++MSISDN_;
         %% Msisdn seems to have changed -> update profile
         {_,              "0"++MSISDN_} -> 
             slog:event(trace, ?MODULE, msisdn_update,
                {Profile, {SMsisdn, SImsi}}),
             "+33"++MSISDN_;
         {_,              "+33"++MSISDN_} ->
             slog:event(trace, ?MODULE, msisdn_update,
                {Profile, {SMsisdn, SImsi}}),
             "+33"++MSISDN_;
          {_,              "+99"++MSISDN_} ->
             slog:event(trace, ?MODULE, msisdn_update,
                {Profile, {SMsisdn, SImsi}}),
             "+99"++MSISDN_;
         _ ->
             pbutil:autograph_label(mismatched_msisdn),
             exit({mismatched_msisdn, Profile, {SMsisdn,SImsi}})

         end,
    IMSI = case {Profile#profile.imsi, SImsi} of
           {IMSI_, undefined} -> IMSI_;
           {{na,_}, IMSI_} -> IMSI_;
           {IMSI_, IMSI_} -> IMSI_;
           {IMSI_, spider_Imsi} -> IMSI_;
           {IMSI1_, IMSI2_} -> 
           slog:event(trace, ?MODULE, imsi_update, {Profile, {SMsisdn, SImsi}}),
           IMSI2_
       end,
    Profile#profile{msisdn=MSISDN, imsi=IMSI}.

%% +type store_user(profile(), profile()) -> profile() 
%%%% Processus d'insertion ou mise a jour de la base CC
% users is not known by Cellcube 
 
store_user(#profile{uid=Uid,anon=true},#profile{uid=Uid}=NewProfile) ->
    check_imsi(NewProfile),
    check_old_msisdn(NewProfile),
    insert_profile(db:unanon_profile(NewProfile));

% msisdn identique
store_user(#profile{msisdn=Msisdn}=Profile,#profile{msisdn=Msisdn}=NewProfile) ->
    check_imsi(NewProfile),
    db:update_profile(NewProfile,Profile),
    NewProfile;
% msisdn is not identique
store_user(#profile{msisdn=Msisdn}=Profile,#profile{msisdn=NewMsisdn}=NewProfile) ->
    check_imsi(NewProfile),
    check_old_msisdn(NewProfile),
    db:update_profile(NewProfile,Profile),
    NewProfile.

%%%% Check if an IMSI starts with "20801" and 15 numbers in length                                                                        %%%% if so => ok, otherwise create an evenement of type failure
check_imsi(#profile{imsi="20801"++T=IMSI}) -> 
    case length(IMSI)==15 andalso pbutil:all_digits(IMSI) of 
	false -> 
	    slog:event(failure,?MODULE,imsi_wrong_format,IMSI);
	_ ->
	    ok
    end;
check_imsi(_) ->
    slog:event(failure,?MODULE,imsi_wrong_format).    

%%%% Check if an old IMSI does not exist for the same MSISDN
%%%% if so, corresponding old profile should be removed
check_old_msisdn(#profile{msisdn={na,_}}) ->
    slog:event(trace, ?MODULE, msisdn_is_na);
check_old_msisdn(#profile{msisdn=Msisdn}) -> 
    case catch db:lookup_profile({msisdn,Msisdn}) of
        P when record(P,profile) ->
            %% entree exist: remove it!
            #profile{imsi=Old_IMSI,uid=UID}=P,
            slog:event(count,?MODULE,old_imsi_found,[{uid,UID},{imsi, Old_IMSI}]),
            case catch clean:delete(UID) of
                ok ->
                    ok;
                Else ->
                    %% possibly multiple entries, cannot continue
                    slog:event(service_ko,?MODULE,could_not_remove_old_entry,{{uid,UID},{imsi, Old_IMSI},Else}),
                    exit(db_not_avail)
            end;
        not_found ->
            slog:event(trace, ?MODULE, no_old_imsi),
            not_found;
        Error -> 
            %% possibly multiple entries, it should not be managed here
            slog:event(trace, ?MODULE, could_not_check_old_imsi,Error),
            Error
    end.

%% +type insert_profile(profile())-> profile() | {'EXIT',*}.
insert_profile(#profile{}=Profile) ->
    %% TO DO, try to find profile from MSISDN and remove old one
    NewProfile1 =
    case db:insert_profile(Profile) of
        {ok, #profile{subscription=S}=NewProfile} ->
            slog:event(trace,?MODULE,{new_user,S}),
            NewProfile;
        Else ->
            %% profile could not be inserted for some reason
            slog:event(failure, ?MODULE, could_not_insert_profile_in_db, Else),
            exit({could_not_insert_profile_in_db, Else})
    end,
    %% If the following insertion fails for any reason, there will not be
    %% any entry in users_orangef_extra corresponding to the one in users.
    case catch svc_util_of:insert_extra_profile(NewProfile1) of
        ok ->
            ok;
        Error ->
            slog:event(failure, ?MODULE, of_extra_profile_insertion_failed),
            exit({of_extra_profile_insertion_failed, Error})
    end,
    NewProfile1.


niveau_provisioning(#session{prof=#profile{subscription=Sub},service_code=Ussd_code}=Session) ->
    NiveauProvList = pbutil:get_env(pservices_orangef,level_database_by_service_code),
    NiveauProv = get_parameter(Ussd_code,NiveauProvList),
    slog:event(trace,?MODULE,niveauProv,NiveauProv),
    case NiveauProv of 
        {_,{niveau2, Platform}, Sublist} -> 
	    slog:event(trace,?MODULE,niveau2,[Platform,Sublist,Sub]),
            GisDeRef = case Sub of 
                            "anon" -> 
                                Platform;
                            {na, _} -> 
                                Platform;
                            _ -> 
			       Subsc = list_to_atom(Sub),
			       case lists:member(Subsc, Sublist) of
				   true->				       
				       GisementList = pbutil:get_env(pservices_orangef,database_by_subscription),
				       case get_parameter(Subsc,GisementList) of 
					   not_found -> 
					       [];
					   Result ->
					       element(2,Result)
				       end;
				   _ ->
				       []
			       end
                       end,
	    slog:event(trace,?MODULE,gisDeRef,GisDeRef),
            case GisDeRef of 
                sachem -> query_sachem(Session);
                spider -> query_spider(Session);
                _ -> {ok, Session}
            end;
        {_,niveau1,_} -> 
            {niveau1, Session};
        _ -> 
            {nok, {unknown_niveau_provisioning,Ussd_code}}
    end.

get_parameter(Element,List) ->
    case lists:keysearch(Element,1,List) of 	
	{value,Result} ->
	    Result;
	_ ->
	    not_found
    end.


query_sachem(#session{prof=Prof}=Session) ->
    Session_state = svc_util_of:update_user_state(Session, #sdp_user_state{}),
    case svc_sachem:update_sachem_user_state(Session_state) of
        {ok, State_updated} ->
            NewSess = update_record(Session_state, State_updated),
            Profile = NewSess#session.prof,
            {ok, NewSess#session{prof=Profile#profile{subscription=svc_util_of:declinaison(State_updated)}}};
        {nok, Error} -> 
            {nok, {update_profile, Session#session{prof=Prof#profile{subscription="anon"}}}}
    end.

query_spider(#session{prof=Prof}=Session) ->
    case catch svc_spider:get_spider_info_and_subscription(Session) of
        {ok, Subscription, Session_updated} ->
            NewProf = Session_updated#session.prof,
            {ok, Session_updated#session{prof=NewProf#profile{subscription=Subscription}}};
        Else ->
            {nok, {update_profile, Session#session{prof=Prof#profile{subscription="anon"}}}}
    end.

add_callbacks(CBs)->
    case lists:member({svc_spider,cb_end_sess,[]},CBs) of
    true  -> CBs;
    false -> [{svc_spider,cb_end_sess,[]}|CBs]
    end.


%% +type update_record(session(),sdp_user_state())-> 
%%                     session().
update_record(Session,State) ->
    AssocList=svc_util_of:init_svc_data(Session),
    AssocList2=
    case lists:keymember(user_state, 1, AssocList) of
        true->
        lists:keyreplace(user_state, 1, AssocList, 
                 {user_state, State});
        false->
        AssocList++[{user_state, State}]
    end,
    Session#session{svc_data=AssocList2}.


%% +type dump_billing_info(session()) -> {continue, session()}
%%                                    |  {stop, session(), term()}.
%%%% Called to dump all current billing info, to resync sdp with internal info
%%%% This function is called from selfcare.xml as well as from home.xml,
%%%% therefore we need absolute links.
dump_billing_info(#session{prof=Profile}=Session) ->
    case billing:reinit(Session) of
    {ok, Session1, Timeout}->
       {continue, Session1};
    {stop, Session3, Reason} = Stop->
        Stop
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type reset_sdp_state(session()) -> 
%%                       {ok, session(), sdp_user_state()} |  {'EXIT', *}.
%%%% Creates #sdp_mobi_user_state structure, analyzing result 
%%%% of idmtl2 sdp request
%%%% Do not return cached information
reset_sdp_state(#session{prof=#profile{subscription=S}=Profile,
             bill=Bill}=Session) 
  when S=="cmo";S=="mobi";
       S=="omer";S=="bzh_cmo"; S=="carrefour_comptebloq";
       S=="tele2_pp";S=="nrj_prepaid";S=="nrj_comptebloque";
       S=="virgin_prepaid";S=="virgin_comptebloque";
       S=="carrefour_prepaid",S=="tele2_comptebloque";
       S=="ten_comptebloque"; S=="monacell_prepaid"->

    reset_sdp_state(Session, list_to_atom(S)).

%% +type reset_sdp_state(session(), atom()) -> {ok, session(),
%%                                          sdp_user_state()}
%%                                 |  {'EXIT', *}.
reset_sdp_state(#session{bill=Bill}=Session, Sub)  ->
    case read_sdp_state_from_profile(Session, first, Sub) of
        {ok,New1Sess} ->
            US = svc_util_of:get_user_state(New1Sess),
            Bill1_ =  case New1Sess#session.bill of
                  undefined -> #bill{};
                  TempBill_ -> TempBill_
                  end,
            %% UserState is used by billing and svc, to keep a synchro
            %% we must reinit these fields at the same time.
            New2Sess = New1Sess#session{bill=Bill1_#bill{spec_data=US}},
            {ok,New2Sess,US};
        Else->
            Else
    end.


%% +type read_sdp_state(session()) -> {ok, session(),
%%                                          sdp_user_state()}
%%                                 |  {'EXIT', *}.
%%%% Creates #sdp_user_state structure, analyzing result of IDMTL2
%%%%  sdp request
read_sdp_state(#session{bill=#bill{spec_data=US}}=Session) 
  when record(US,sdp_user_state) ->
    %% user state has already been computed -> don't re-compute
    pbutil:autograph_label(return_cache_info),
    slog:event(trace, ?MODULE, {read_sdp_state, returning_cached_info}, ok),
    {ok, Session, US};
read_sdp_state(#session{prof=#profile{subscription=S}=Profile,
            bill=Bill}=Session) ->
    pbutil:autograph_label(init_cache_info),
    case read_sdp_state_from_profile(Session, first,list_to_atom(S)) of
%%  {error, user_unknown}->
%%      {error, user_unknown};
        {ok, New1Sess} ->
            US = svc_util_of:get_user_state(New1Sess),
            Bill1_ =  case New1Sess#session.bill of
                  undefined -> #bill{};
                  TempBill_ -> TempBill_
                  end,
            New2Sess = New1Sess#session{bill=Bill1_#bill{spec_data=US}},
            {ok,New2Sess,US};
        Else->
            {error_sdp,Session}
   end.

%% +type read_sdp_state_from_profile(session(),first | not_first,sub_of()) -> 
%%                                   {ok, session()}
%%                                   | {error,unknow_user_from_sdp}
%%                                   | {error_sdp,term()}.
read_sdp_state_from_profile(#session{prof=Profile}=Session,
                First, Subscription) ->
    %% Identity : IMSI > MSISDN since IMSI comes from network itself
    Identity = case {Profile#profile.msisdn, Profile#profile.imsi} of
           {{na,_}, {na,_}} ->
               %% This will cause the SDP request to fail
               {na,imsi_msisdn_empty};
           {MSISDN, {na, _}} -> {msisdn, MSISDN};
           {_, IMSI} -> {imsi,IMSI}
           end,
    Session_state = svc_util_of:update_user_state(Session, #sdp_user_state{}),
    case svc_util_of:consult_account_state(Session_state,Subscription,
                                    Identity,#sdp_user_state{}) of
    {ok, Msisdn, State} ->
        NewSess = update_record(Session,State),
        case State#sdp_user_state.etat_princ of
        ?ETAT_RO->
            pbutil:autograph_label(resilie_op),
            {error, user_unknown};
        ?ETAT_RA->
            pbutil:autograph_label(resilie_adv),
            {error, user_unknown};
        ?ETAT_TR->
            pbutil:autograph_label(transfert),
            {error, user_unknown};
        _->
            {ok,NewSess}
        end;
    {status,[[],[_,10]]} -> 
        pbutil:autograph_label(unknown_user),
        {error, user_unknown};
    {status,[[],[_,_,10]]} -> 
        pbutil:autograph_label(unknown_user),
        {error, user_unknown};
        %% We should adapt with the right error
    {nok,Reason} -> 
        pbutil:autograph_label(unknown_user),
        {error, user_unknown};
    Error ->
        pbutil:autograph_label(error_sdp),
        {error_sdp,Error}
    
    end.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Function use for decoding %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type opt_set_lang(profile()) -> session().
opt_set_lang(#profile{lang=L}=Prof) ->
    case L of
    {na,_} ->
        Lang = pbutil:get_env(pservices_orangef,selfprovisioning_language),
        Prof#profile{lang=Lang};
    _ ->
        Prof
    end.



slog_info(service_ko, ?MODULE, could_not_remove_old_entry) ->
    #slog_info{descr="A potential \"doublon\" was identified but could not"
               " be removed. To prevent a \"doublon\" the session was"
               " interrupted\n",
           operational="Check logs to see {Uid,Imsi} of the entry that"
               " could not be removed. To delete it manually:\n"
               " clean:delete(Uid).\n"};

slog_info(failure, ?MODULE, could_not_insert_profile_in_db) -> 
    #slog_info{descr="A new profile could not insert to Cellcube DB",
               operational="Check logs to see the reason of error that can not be inserted"};

slog_info(failure, ?MODULE, of_extra_profile_insertion_failed) -> 
    #slog_info{descr="An extra profile could not insert to Cellcube DB extra", 
               operational="Check logs to see the reason of error that can not be inserted"};

slog_info(failure, ?MODULE, imsi_wrong_format) ->
    #slog_info{descr="Check if an IMSI starts with \"20801\" and 15 numbers in length"
	       " if so => ok, otherwise create an evenement of type failure",
	       operational="Check logs to see the reason of error that can be imsi wrong format"};

slog_info(failure, ?MODULE, nb_echec_query_ocf_depassement_seuil) -> 
    #slog_info{descr="Numbers of querying to OCF by subscribeByImsi in failure", 
               operational="Check logs to see the reason of error that can be triggered"}.


