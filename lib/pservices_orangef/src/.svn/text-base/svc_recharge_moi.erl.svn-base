-module(svc_recharge_moi).

-export([checks_and_send_sms/8]).

%% For tests.
-export([check_user_rolling_periods/2,
	 check_rolling_periods/2,
	 trim_periods/2]).

-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/recharge_moi.hrl").
-include("../../pgsm/include/sms.hrl").

%% +type checks_and_send_sms(
%%   session(), string(), string(), string(), string(), string(), string(),
%%   string())
%%  -> erlpage_result().

checks_and_send_sms(
  abs,
  UrlOk, UrlBadFormat, UrlNotMobile, UrlBalance, UrlRollingPeriodsCond,
  UrlSMSFailure, UrlBlackList) ->
    [{redirect, abs, UrlOk}, {redirect, abs, UrlBadFormat},
     {redirect, abs, UrlNotMobile}, {redirect, abs, UrlBalance},
     {redirect, abs, UrlRollingPeriodsCond}, {redirect, abs, UrlSMSFailure},
     {redirect, abs, UrlBlackList},
     {redirect, abs, "/orangef/home.xml#temporary"}];
checks_and_send_sms(
  Session,
  UrlOk, UrlBadFormat, UrlNotMobile, UrlBalance, UrlRollingPeriodsCond,
  UrlSMSFailure, UrlBlackList) ->
    {Session1, DestMsisdn} = extract_and_reset_nav_buffer(Session),
    TempURL = "/orangef/home.xml#temporary",
    case catch
	begin
	    Times = perform_checks(Session1, DestMsisdn),
	    send_sms_and_update_times(Session1, DestMsisdn, Times)
	end of
	bad_dest_msisdn_format    -> {redirect, Session1, UrlBadFormat};
	not_a_mobile_msisdn       -> {redirect, Session1, UrlNotMobile};
	balance_too_high          -> {redirect, Session1, UrlBalance};
	rolling_periods_cond      -> {redirect, Session1,UrlRollingPeriodsCond};
	ocf_failure               -> {redirect, Session1, UrlSMSFailure};
	sms_could_not_be_sent     -> {redirect, Session1, UrlSMSFailure};
	db_error                  -> {redirect, Session1, TempURL};
	dest_msisdn_in_black_list -> {redirect, Session1, UrlBlackList};
	svc_profile_update_failed -> {redirect, Session1, UrlOk};
	ok                        -> {redirect, Session1, UrlOk}
    end.

%% +type perform_checks(session(), string()) -> [unix_time()].
%%%% Performs some checks and returns the list of the times when SMSs were sent.

perform_checks(Session, DestMsisdn) ->
    check_dest_msisdn(DestMsisdn),
    %% check_balance(Session),
    {ok, Times} = check_rolling_periods(Session),
    Times.

%% +type send_sms_and_update_times(session(), string(), [unix_time()]) -> ok.

send_sms_and_update_times(Session, DestMsisdn, Times) ->
    case catch send_sms(Session, DestMsisdn) of
	ok -> update_times(Session, Times);
	X  -> throw(X)
    end.

%% +type update_times(session(), [unix_time()]) -> ok.

update_times(Session, Times) ->
    RPs = pbutil:get_env(pservices_orangef, recharge_moi_periodes_glissantes),
    RPSs = [{N, period_to_seconds(Period)} || {N, Period} <- RPs],
    Times1 = trim_periods(Times, RPSs),
    Times2 = [pbutil:unixtime() | Times1],
    case db:update_svc_profile(Session, ?SVC_NAME, Times2) of
	ok ->
	    ok;
	Err ->
	    slog:event(failure, ?MODULE, svc_profile_update_failed, Err),
	    throw(svc_profile_update_failed)
    end.

%% +type send_sms(session(), string()) -> ok.

send_sms(Session, DestMsisdn) ->
    "0" ++ Rest = DestMsisdn,
    OcfDestMsisdn = "33" ++ Rest,
    IntlDestMsisdn = "+33" ++ Rest,

    SrcMsisdn = intl2natl((Session#session.prof)#profile.msisdn),

    case catch ocf_rdp:isMsisdnOrange(OcfDestMsisdn) of
	true ->
	    FormatString = pbutil:get_env(pservices_orangef, recharge_moi_texte_dest_of),
	    Text = lists:flatten(io_lib:format(FormatString, [SrcMsisdn])),
	    send_sms_orange(Session, Text, IntlDestMsisdn);
	false ->
	    FormatString = pbutil:get_env(pservices_orangef, recharge_moi_texte_dest_not_of),
	    Text = lists:flatten(io_lib:format(FormatString, [SrcMsisdn])),
	    send_sms_cvf(Session, Text, IntlDestMsisdn);
	X ->
	    slog:event(failure, ?MODULE, ocf_rdp_no_answer, X),
	    throw(ocf_failure)
    end.

%% +type extract_and_reset_nav_buffer(session()) -> {session(), string()}.

extract_and_reset_nav_buffer(Session) ->
    MData = Session#session.mode_data,
    DestMsisdn = MData#mdata.nav_buffer,
    Session1 = Session#session{mode_data = MData#mdata{nav_buffer = []}},
    {Session1, DestMsisdn}.

%% +type check_dest_msisdn(string()) -> ok.

check_dest_msisdn(DestMsisdn) ->
    case pbutil:all_digits(DestMsisdn) of
	true  -> ok;
	false -> throw(bad_dest_msisdn_format)
    end,
    case length(DestMsisdn) of
	10 -> ok;
	_  -> throw(bad_dest_msisdn_format)
    end,
    case DestMsisdn of
	"06"++_ -> ok;
	"07"++_ -> ok;
	_       -> throw(not_a_mobile_msisdn)
    end,
    case black_list_member(DestMsisdn) of
	true -> throw(dest_msisdn_in_black_list);
	false -> ok
    end.
	    
black_list_member(MSISDN) ->
    AclName = pbutil:get_env(pservices_orangef, recharge_me_black_list_name),
    acl:member(MSISDN, AclName).

%% +type check_balance(session()) -> ok.

check_balance(Session) ->
    #sdp_user_state{declinaison=DCL} = State = svc_util_of:get_user_state(Session),
    {Curr, Amount} = pbutil:get_env(pservices_orangef, recharge_moi_solde_max),
    Threshold = currency:sum(Curr, Amount),
    Balance = svc_compte:solde_cpte(State, svc_util_of:godet_principal(DCL)),
    case catch currency:is_infeq(Balance, Threshold) of
	true  -> ok;
	false -> throw(balance_too_high)
    end.

%% +type check_rolling_periods(session()) -> {ok, [unix_time()]}.
%%%% Checks that the windows corresponding to the rolling periods are not full
%%%% and returns the list of the times when SMSs were sent.

check_rolling_periods(Session) ->
    Times =
	case catch db:lookup_svc_profile(Session, ?SVC_NAME) of
	    {ok, T} ->
		T;
	    not_found ->
		[];
	    no_profile ->
		exit({?MODULE, check_rolling_periods, no_profile});
	    Else ->
		throw(db_error)
	end,
    RPs = pbutil:get_env(pservices_orangef, recharge_moi_periodes_glissantes),
    RPSs = [{N, period_to_seconds(Period)} || {N, Period} <- RPs],
    case check_rolling_periods(RPSs, Times) of
	true  -> {ok, Times};
	false -> throw(rolling_periods_cond)
    end.

%% +type send_sms_orange(session(), string(), string()) -> bool().

send_sms_orange(Session, Text, DestMsisdn) ->
    slog:event(count, ?MODULE, send_sms_orange),
    send_smsmt(Session, Text, DestMsisdn).

%% +type send_sms_cvf(session(), string(), DestMsisdn::string()) -> bool().

send_sms_cvf(Session, Text, DestMsisdn) ->
    slog:event(count, ?MODULE, send_sms_cvf),
    Routing = pbutil:get_env(pservices_orangef, recharge_moi_cvf_routing),
    case svc_util:send_sms_mo(Session, Routing, Text, DestMsisdn) of
	true  -> ok;
	false -> throw(sms_could_not_be_sent)
    end.

%%%% Sending a short text to private SMS server in a SMS to MSISDN Target.
%% +type send_smsmt(Session::session(), Text::string(), Target::string())
%%   -> bool().

send_smsmt(Session, Text, Target) ->
    Routing = pbutil:get_env(pservices_orangef, recharge_moi_routing),
    case catch svc_util_of:send_smsmt(Session, Text, Target,[Routing]) of
	{ok, _} ->
	    ok;
	Err ->
	    slog:event(failure, ?MODULE, send_sms, Err),
	    throw(sms_could_not_be_sent)
    end.

%% +type intl2natl(string()) -> string().

intl2natl("+33" ++ Msisdn) ->
    "0" ++ Msisdn;
intl2natl("+99" ++ Msisdn) ->
    %% tests
    "0" ++ Msisdn.


%% Rolling periods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_rolling_periods([rolling_period()], [unix_time()]) -> bool().
%%%% Returns true iff none of the sliding windows corresponding to the rolling
%%%% periods RPs are full.

check_rolling_periods(RPs, Times) ->
    F = fun (RP) -> not is_window_full(RP, Times) end,
    lists:all(F, RPs).

%% +type is_window_full(rolling_period(), [unix_time()]) -> bool().
%%%% Returns true iff the sliding window corresponding to the rolling period
%%%% is not full.

is_window_full({N, Period}, Times) ->
    T0 = pbutil:unixtime() - Period,
    N =< length(trim(Times, T0)).

%% +type trim([unix_time()], unix_time()) -> [unix_time()].
%%%% Returns the sublist of the times superior to T0 in Times, which must be
%%%% sorted in descending order.

trim(Times, T0) ->
    F = fun (T) -> T > T0 end,
    lists:takewhile(F, Times).

%% +type trim_periods([unix_time()], [rolling_period()]) -> [unix_time()].
%%%% Trims Times according to the largest period in RPs which must be non-empty.

trim_periods(Times, RPs) ->
    Periods = [Period || {_N, Period} <- RPs],
    trim_periods_aux(Times, Periods).

%% +type trim_periods_aux([unix_time()], [second()]) -> [unix_time()].

trim_periods_aux(Times, Periods) ->
    LargestPeriod = lists:max(Periods),
    T0 = pbutil:unixtime() - LargestPeriod,
    trim(Times, T0).

%% +deftype period() = {integer(), seconds | minutes | hours | days}.
%% +deftype second() = integer().
%% +deftype rolling_period() = {integer(), second()}.
%% +deftype user_rolling_period() = {period(), second()}.

%% +type period_to_seconds(period()) -> second().

period_to_seconds({N, seconds}) -> N;
period_to_seconds({N, minutes}) -> N * 60;
period_to_seconds({N, hours})   -> N * 60 * 60;
period_to_seconds({N, days})    -> N * 60 * 60 * 24.

%% +type check_user_rolling_periods([user_rolling_period()], [unix_time()])
%%   -> bool().

check_user_rolling_periods(RPs, Times) ->
    RPSs = [{N, period_to_seconds(Period)} || {N, Period} <- RPs],
    svc_recharge_moi:check_rolling_periods(RPSs, Times).
