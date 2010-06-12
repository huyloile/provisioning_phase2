-module(svc_call_me_back).

-export([verify_send/8]).

-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/billing.hrl").
-include("../../pgsm/include/sms.hrl").
-include("../include/cmb.hrl").
-include("../include/ftmtlv.hrl").

-define(DEF_SACHEM_VAL,0). 
%% Valeur par défaut renvoyée par Sachem quand un utilisateur 
%% n'a jamais rechargé.

%% +deftype url() = string().

%%%% Only exported fun for this service.
%%%% Does the verifications and eventually sends an SMS (MO or MT)
%%%% Redirects to one of the passed URLs
%% +type verify_send(session(),Subscription::string(),OkUrl::url(),
%%                   NokFormatUrl::url(),NokNumDestUrl::url(),
%%                   NokSoldeUrl::url(),NokDateUrl::url(),NokNumUrl::url()) ->
%%       erlpage_result().
verify_send(abs,"mobi",OkUrl,NokFormatUrl,NokNumDestUrl,
	    NokSoldeUrl,NokDateUrl,NokNumUrl) ->
    [{"OK - MOBI",{redirect, abs, OkUrl}},
     {"Format /= #122*<msisdn>",{redirect, abs, NokFormatUrl}},
     {"<msisdn> is not a french mobile",{redirect, abs, NokNumDestUrl}},
     {"Balance > limit (1E)",{redirect, abs, NokSoldeUrl}},
     {"Validity exceeded",{redirect, abs, NokDateUrl}},
     {"Max number of CMB "++integer_to_list(?MOBI_MAX_CMB)++"reached",
      {redirect, abs, NokNumUrl}}
    ];
verify_send(abs,"cmo",OkUrl,NokFormatUrl,NokNumDestUrl,
	    NokSoldeUrl,NokDateUrl,NokNumUrl) ->
    [{"OK - CMO",{redirect, abs, OkUrl}},
     {"Format /= #122*<msisdn>",{redirect, abs, NokFormatUrl}},
     {"<msisdn> is not a french mobile",{redirect, abs, NokNumDestUrl}},
     {"Balance > limit (1E)",{redirect, abs, NokSoldeUrl}},
     {"Validity exceeded",{redirect, abs, NokDateUrl}},
     {"Max number of CMB "++integer_to_list(?CMO_MAX_CMB)++"reached",
      {redirect, abs, NokNumUrl}}
    ];
verify_send(abs,"symacom",OkUrl,NokFormatUrl,NokNumDestUrl,
	    NokSoldeUrl,NokDateUrl,NokNumUrl) ->
    [{"OK - SYMACOM",{redirect, abs, OkUrl}},
     {"Format /= #122*<msisdn>",{redirect, abs, NokFormatUrl}},
     {"<msisdn> is not a french mobile",{redirect, abs, NokNumDestUrl}},
     {"Balance > limit (1E)",{redirect, abs, NokSoldeUrl}},
     {"Validity exceeded",{redirect, abs, NokDateUrl}},
     {"Max number of CMB "++integer_to_list(?SYMACOM_MAX_CMB)++"reached",
      {redirect, abs, NokNumUrl}}
    ];

verify_send(Session,Subscription,OkUrl,NokFormatUrl,NokNumDestUrl,
	    NokSoldeUrl,NokDateUrl,NokNumUrl) ->
    catch verify_send_int(Session,Subscription,
			  OkUrl,NokFormatUrl,NokNumDestUrl,
			  NokSoldeUrl,NokDateUrl,NokNumUrl).
verify_send_int(Session,Subscription,OkUrl,NokFormatUrl,NokNumDestUrl,
		NokSoldeUrl,NokDateUrl,NokNumUrl) ->
    {ok,NumDest,Session1} = filter_command(Session,NokFormatUrl,NokNumDestUrl),
    {ok,CMB} = verif_cond(Session1,list_to_atom(Subscription),
			  NokSoldeUrl,NokDateUrl,NokNumUrl),
    send_sms(Session1,NumDest,CMB),
    {redirect, Session1, OkUrl}.

%%%% tests command format #122*num_dest#, accepted formats 
%%%  for num_dest = [Beginning|End] :
%%%      format 1 : Beginning = [], End = ten_digit_number
%%%      format 2 : Beginning = [0033], End = nine_digit_number
%%%      format 3 : Beginning = [33], End = nine_digit_number
%%%% If format is not valid, throws a redirect to NokFormatUrl

%% +type filter_command(session(),NokFormatUrl::url(),
%%                      NokNumDestUrl::url()) -> erlpage_result().
filter_command(Session,NokFormatUrl,NokNumDestUrl) ->
    Command = (Session#session.service_code),
    ModeData = Session#session.mode_data,
    Dest = ModeData#mdata.nav_buffer,
    case pbutil:all_digits(Dest) of
	false ->
	    throw({redirect,Session, NokFormatUrl});
	true ->
	    ok
    end,
    Num_dest = case filter_command_int(Dest) of
		   nok -> 
		       throw({redirect,Session, NokFormatUrl});
		   {ok,Num_dest_} -> 
		       Num_dest_
	       end,
    case test_french_mobile_int(Num_dest) of
	{ok,N} ->
	    case black_list_member("0"++N) of
		true -> throw({redirect,Session, "#dest_msisdn_in_bl"});
		false -> ok
	    end,
	    {ok,N,
	     Session#session{mode_data=ModeData#mdata{nav_buffer=[]}}};
	nok -> throw({redirect,Session,NokNumDestUrl})
    end.

%%%% Test validity of number format
%% +type filter_command_int(Dest::string()) -> {ok,string()} | nok.
filter_command_int(Dest) ->
    case Dest of
	Num_dest when length(Num_dest) == 10 ->
	    slog:event(count,?MODULE,format1, Num_dest),
	    {ok,Num_dest};
	[$0,$0,$3,$3|Num_dest] when length(Num_dest) == 9 ->
	    slog:event(count,?MODULE,format2, Num_dest),
	    {ok,Num_dest};
	[$3,$3|Num_dest] when length(Num_dest) == 9 ->
	    slog:event(count,?MODULE,format3, Num_dest),
	    {ok,Num_dest};
	Num_dest -> 
	    slog:event(count,?MODULE,invalid_format, Num_dest),
	    nok
    end.

%%%% tests if Num_dest is a french mobile number :
%%% Num_dest = 06eight_digit / 6eight_digit
%%% if OK, sends pre-formated SMS to Num_dest
%%% if OK, calls filter_solde(Session)
%%%% If number is not a french mobile number, throws a redirect to 
%%%% NokNumDestUrl

%% +type test_french_mobile_int(Num_dest::string()) -> {ok,string()} | nok.
test_french_mobile_int(Num_dest) ->
    case Num_dest of
	[$0,$6|X] when length(X) == 8 ->
	    slog:event(trace,?MODULE,format1_OK, Num_dest),
	    {ok,[$6|X]};
	[$6|X] when length(X) == 8 ->
	    slog:event(trace,?MODULE,format2or3_OK, Num_dest),
	    {ok,Num_dest};
	[$0,$7|X] when length(X) == 8 ->
	    slog:event(trace,?MODULE,format1_OK, Num_dest),
	    {ok,[$7|X]};
	[$7|X] when length(X) == 8 ->
	    slog:event(trace,?MODULE,format2or3_OK, Num_dest),
	    {ok,Num_dest};
	_ -> 
	    slog:event(count,?MODULE,invalid_format, Num_dest),
	    nok
    end.

%%%% Verifies the conditions of a CMB taking in account balance, current date, 
%%%% date_der_rec and stored info in svc_profile, and either throws a redirect
%%%% to a passed URL, or returns the stored data.
%% +type verif_cond(session(),mobi|cmo,
%%                  NokSoldeUrl::url(),NokDateUrl::url(),NokNumUrl::url()) ->
%%       erlpage_result() | {ok,call_me_back()}.
verif_cond(Session,Subscription,NokSoldeUrl,NokDateUrl,NokNumUrl) ->
    Now = pbutil:unixtime(),
    %% retrieve CMB data
    CMB = case catch db:lookup_svc_profile(Session,?SVC_NAME) of
	      %% !! cmb record change in 07/05
	      {ok,{call_me_back,Date,Num}}->
		  %%%% backward compatibility
		  %%%% last_cmb=date of 1er CMB
		  #call_me_back{date=Date,num=Num,last_cmb=Date};
	      {ok,#call_me_back{date=undefined} = Data} ->
		  %% ??
		  Data#call_me_back{date=Now,num=0};
	      {ok,#call_me_back{num=N} = Data} when N=<0 ->
		  %% 0 when CMB tried unsuccessfully
		  Data#call_me_back{date=Now,num=0}; 
	      {ok,#call_me_back{} = Data} ->
		  Data;
	      not_found ->
		  #call_me_back{date=Now,last_cmb=Now};
	      Else_ ->
		  slog:event(failure,?MODULE,retrieve_cmb_data,Else_),
		  throw({redirect, Session, "#confirm_nok"})
	  end,
    %% do verifications and send
    case catch try_cmb(Session,Subscription,
		       NokSoldeUrl,NokDateUrl,NokNumUrl,CMB) of
	{ok,CMB1} -> {ok,CMB1};
	{redirect,_,_}=Resp ->
	    throw(Resp);
	Else1_ ->
	    slog:event(internal,?MODULE,unexpected,Else1_),
	    throw({redirect, Session, "#confirm_nok"})
    end.

%%%% checks balance, date, number of CMB already sent by user, and either 
%%%% throws a redirect to a passed URL, or returns the stored data.
%% +type try_cmb(Session::session(),mobi|cmo,
%%               NokSoldeUrl::url(),NokDateUrl::url(),NokNumUrl::url(),
%%               CMB::call_me_back()) ->
%%       erlpage_result() | {ok,call_me_back()}.
try_cmb(Session,Subscription,NokSoldeUrl,NokDateUrl,NokNumUrl,CMB) ->
    case catch check_balance(Session,Subscription) of
	ok ->
	    ok;
        _ ->
	    throw({redirect, Session, NokSoldeUrl})
    end,
    CMB1 = case catch check_date(Session,Subscription,CMB) of
	       {ok,CMB1_} ->
		   CMB1_;
	       invalid_date->
		   throw({redirect, Session, NokDateUrl});
	       Else2_ ->
		   slog:event(internal,?MODULE,invalid_date,
					      {Else2_,CMB,Session}),
		   throw({redirect, Session, NokDateUrl})
	   end,
    case catch check_num(Session,Subscription,CMB1) of
	ok ->
	    ok;
	Else3_ ->
	    slog:event(trace,?MODULE,invalid_num,Else3_),
	    throw({redirect, Session, NokNumUrl})
    end,
    {ok,CMB1}.

%% +type check_balance(session(),mobi|cmo) -> 
%%       ok | invalid_balance.
%%%% Subscription unused, but could be usefull if balance limit should be 
%%%% different for MOBI and CMO.
check_balance(Session,Subscription) ->
    State= svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    OneEuro = currency:sum(euro,1),
    Solde = svc_compte:solde_cpte(State, svc_util_of:godet_principal(DCL)),
    %%slog:event(trace, ?MODULE, balance, Solde),
    case catch currency:is_infeq(Solde, OneEuro) of
	true ->
	    ok;
	false ->
	    invalid_balance
    end.

%%%% eventually updates CMB under certain conditions
%% +type check_date(session(),mobi|cmo,CMB::call_me_back()) -> 
%%       {ok,call_me_back()} | invalid_date.
%%%% Subscription unused, but could be usefull if date limit should be 
%%%% different for MOBI, Symacom and CMO.
check_date(Session,Subs,CMB) when Subs==mobi ->
    State= svc_util_of:get_user_state(Session),
    DateDerRec = 
	case State#sdp_user_state.d_der_rec of
	    undefined -> 0;
	    ?DEF_SACHEM_VAL -> 0;
	    Else -> Else
	end,
    StoredDate = CMB#call_me_back.date,
    Last_CMB = CMB#call_me_back.last_cmb,
    StoredDate_plus = add_week(StoredDate),
    Now = pbutil:unixtime(),
    CMB1=
	if 
	    DateDerRec > Last_CMB->
		%% since last CMB, account was recredited, but balance is
		%% once again under the limit. A new CMB periods starts
		CMB#call_me_back{date=Now,num=0};
	    Now > StoredDate_plus->
		throw(invalid_date);
	    true->
		CMB
	end,
     {ok,CMB1};
%check_date(Session, symacom,CMB) ->
check_date(Session,Subs,CMB) when Subs==symacom ->
    State= svc_util_of:get_user_state(Session),
    DateDerRec = 
	case State#sdp_user_state.d_der_rec of
	    undefined -> 0;
	    ?DEF_SACHEM_VAL -> 0;
	    Else -> Else
	end,
    Last_CMB = CMB#call_me_back.last_cmb,
    Now = pbutil:unixtime(),
    CMB1=
	if 
	    DateDerRec > Last_CMB->
		%% since last CMB, account was recredited, but balance is
		%% once again under the limit. A new CMB periods starts
		CMB#call_me_back{date=Now,num=0};
	    true->
		CMB
	end,
     {ok,CMB1};
%check_date(Session, cmo,CMB) ->
check_date(Session, Subs,CMB) when Subs==cmo ->
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    StoredDate = CMB#call_me_back.date,
    Last_CMB = CMB#call_me_back.last_cmb,
    StoredDate_plus = add_week(StoredDate),
    Now = pbutil:unixtime(),
    {Y,M,D}=date(),
    #compte{rnv=Rnv}=svc_compte:cpte(State,
					 svc_util_of:godet_principal(DCL)),
    {{Yh,Mh,_},{_,_,_}}=calendar:now_to_local_time({Last_CMB div 1000000,
						   Last_CMB rem 1000000,0}),
    Rnv_M=pbutil:universal_time_to_unixtime({valid_date({Y,M,Rnv}),
					     {23,30,0}}),
    Rnv_Mh=pbutil:universal_time_to_unixtime({valid_date({Yh,Mh,Rnv}),
					      {23,30,0}}),
    CMB1=
	if 
	    Last_CMB < Rnv_M , Rnv_M < Now->
		%% depuis dernier CMB, renouv forfait
		CMB#call_me_back{date=Now,num=0};
	    Last_CMB < Rnv_Mh, Rnv_Mh< Now->
		%% depuis dernier CMB, renouv forfait
		CMB#call_me_back{date=Now,num=0};
	    Now > StoredDate + 2678400 -> 
		%% First authorized cmb 31 days ago
		CMB#call_me_back{date=Now,num=0};
	    Now > StoredDate_plus->
		throw(invalid_date);
	    true->
		CMB
	end,
    {ok,CMB1}.

valid_date({Y,M,0}=Date)->
    %% RNV_NUM=0 ?!
    {Y,M,1};
valid_date({Y,M,D}=Date) when D=<28->
    Date;
valid_date({Y,M,D}=Date)->
    %% Check if RNV_NUM > Last_day_of_the_month.
    Last = calendar:last_day_of_the_month(Y, M),
    if
	D > Last ->
	    {Y,M,Last};
	true->
	    Date
    end.

%% +type check_num(session(),mobi|cmo,CMB::call_me_back()) -> 
%%       ok | invalid_num.
check_num(Session,mobi,#call_me_back{num=N}) ->
    Max = ?MOBI_MAX_CMB,
    check_max(N,Max);
check_num(Session,cmo,#call_me_back{num=N}) ->
    Max = ?CMO_MAX_CMB,
    check_max(N,Max);
check_num(Session,symacom,#call_me_back{num=N}) ->
    Max = ?SYMACOM_MAX_CMB,
    check_max(N,Max).

check_max(N,Max) when N<Max ->
    ok;
check_max(N,Max) ->
    invalid_num.

%% +type send_sms(session(), Num_dest::string(), CMB::call_me_back()) ->
%%       erlpage_result() | ok.
send_sms(Session, Num_dest, CMB) ->
    case send_sms(Session, Num_dest) of
	{true,OP} ->
	    slog:event(count,?MODULE,{dest,OP}),
	    update(Session,success,CMB);
	{false,_} ->
	    update(Session,failure,CMB),
	    throw({redirect, Session, "#confirm_nok"});
	false ->
	    update(Session,failure,CMB),
	    throw({redirect, Session, "#confirm_nok"})
    end.


%% +type send_sms(session(), Num_dest::string()) -> 
%%        {true | false, orange | not_orange} | false.
send_sms(Session, Num_dest) ->
    case catch ocf_rdp:isMsisdnOrange("33"++Num_dest) of
	true ->
	    {send_sms_orange(Session, Num_dest),orange};
	false ->
	    {send_sms_cvf(Session, Num_dest),not_orange};
	X ->
	    slog:event(failure, ?MODULE, ocf_rdp_no_answer, X),
	    false
    end.

%% +type send_sms_orange(session(), Num_dest::string()) -> true | false.
send_sms_orange(Session, Num_dest) ->
    Msisdn = intl2natl((Session#session.prof)#profile.msisdn),
    Subs = (Session#session.prof)#profile.subscription,

    case Subs of 
	"symacom" ->
	    CMB_2_X = cmb_to_orange_symacom;
	_ ->
	    CMB_2_X = cmb_to_orange
    end,
    Raw_text = pbutil:get_env(pservices_orangef, CMB_2_X),
    Text = lists:flatten(io_lib:format(Raw_text, [Msisdn])),
    Ok_URL = pbutil:get_env(pservices,sendsmsok_url),
    slog:event(count, ?MODULE, send_sms_orange,Text),
    send_smsmt(Session, Text, "+33"++Num_dest).

%% +type send_sms_cvf(session(), Num_dest::string()) -> true | false.
send_sms_cvf(Session, Num_dest) ->
    Msisdn = intl2natl((Session#session.prof)#profile.msisdn),
    Routing = pbutil:get_env(pservices_orangef, cmb_cvf_routing),
    Subs = (Session#session.prof)#profile.subscription,
    case Subs of 
	"symacom" ->
	    CMB_2_X = cmb_to_cvf_symacom;
	_ ->   
	    CMB_2_X = cmb_to_cvf
    end,
    Raw_text = pbutil:get_env(pservices_orangef, CMB_2_X),
    Text = lists:flatten(io_lib:format(Raw_text, [Msisdn])),
    slog:event(count, ?MODULE, send_sms_cvf,Text),
    svc_util:send_sms_mo(Session,Routing,Text,"+33"++Num_dest).

%%%% Sending a short text to private SMS server in a SMS to MSISDN Target.
%% +type send_smsmt(Session::session(), Text::string(), Target::string()) -> 
%% true | false.
send_smsmt(Session, Text, Target) ->
    Routing = pbutil:get_env(pservices_orangef, call_me_back_routing),
    case catch svc_util_of:send_smsmt(Session, Text, Target,[Routing]) of
	{ok, _} -> true;
	Err -> slog:event(failure, ?MODULE, send_sms, Err),
	       false
    end.

add_week(Date) ->
    Date + (7*24*60*60).

update(Session,success,#call_me_back{num=N}=CMB) ->
    update_int(Session,CMB#call_me_back{num=N+1,last_cmb=pbutil:unixtime()});
update(Session,failure,CMB) ->
    update_int(Session,CMB).

update_int(Session,CMB) ->
    case catch db:update_svc_profile(Session,?SVC_NAME,CMB) of
	ok ->
	    ok;
	Else ->
	    %% could not update stored info 
	    %% -> potentially successfull CMB is not stored
	    slog:event(internal,?MODULE,update_profile,Else),
	    ok
    end.

intl2natl([$+,$3,$3|Msisdn]) ->
    "0"++Msisdn;
intl2natl([$+,$9,$9|Msisdn]) ->
    %% tests
    slog:event(trace,?MODULE,intl2natl,{test_msisdn,"+99"++Msisdn}),
    "0"++Msisdn;
intl2natl(Else) ->
    slog:event(failure,?MODULE,intl2natl,{not_intl,Else}),
    not_intl.

black_list_member(MSISDN) ->
    AclName = pbutil:get_env(pservices_orangef, call_me_back_black_list_name),
    acl:member(MSISDN, AclName).
