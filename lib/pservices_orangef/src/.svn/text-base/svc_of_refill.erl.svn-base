-module(svc_of_refill).

%% XML export

-export([refill_start/4,
	 refill_mobicarte/5,
	 refill_cb/4,
	 refill_cb_identify/5,
	 is_rechargeable_cb/5,
	 refill_tlr/3,
	 request_info/4,
	 first_time/4,
	 verify_code/8,
	 verify_date/6,
	 verify_code_tlr/6,
	 create_access_code/6,
	 modify_access_code/6,
	 reinit_counter/3,
	 verify_access_code/9,
	 verify_code_cvx2/6,
	 verify_code_contract/6,
	 enter_amount/7,
	 enter_mobile_choix/5,
	 get_mobile_choix/2,
	 payment_cb/9,
	 payment_debit/2,
	 payment_debit/3,
	 verify_refill_code/5,
	 verify_refill_code_try/7,
	 refill_request_cmo/5,
	 refill_request_rech_sl/3,
	 refill_request/5,
	 refill_request/6,
	 refill_request/8,
	 refill_request/12,
	 refill_request/16,
	 print_refill_info/3,
	 is_lucky_number/8,
	 redirect_tr_error/8,
	 verify_special_mobicarte/9,
	 text_sl_7E/3,
	 check_recharge_amount/3,
	 check_amount_rech_spe/6
	]).

%% Unit test export

-export([determine_homepage/3,
	 success_d6/4,
	 success_d6/6,
	 success_d6/11,
	 success_d6/15,
	 verify_access_code_nok/4,
	 update_recharge_cb/2,
	 check_amount/7]).

-include("../include/subscr_asmetier.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../oma/include/slog.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/plugin.hrl").
-include("../include/recharge_cb_cmo_new.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").


-define(vcod_version,1).
-define(info_version,2).
-define(dmcc_version,1).
-define(pay_version,3).
-define(TCK_KEY_TYPE, "2").
-define(TTK_RECH_20E, 13).
-define(TTK_RECH_SL_20E, 172).
-define(TTK_RECH_SPECIAL_SL_10E, 183).
-define(TTK_RECH_SPECIAL_SL_20E, 184).
-define(TTK_RECH_SPECIAL_SL_30E, 185).
%-define(TTK_RECH_SL_20E, 174).
-define(TTK_20E_messages, 124).
-define(TTK_20E_musique, 163).
-define(TTK_SL_7E_MessgIllim, 168).
-define(CHOICE_20E_messages, 4).
-define(CHOICE_20E_SSMS_ILLIM, 1).
-define(CHOICE_RECH_SL,1).
-define(sub,cmo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLUGINS RELATED TO REFILL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_start(session(),Subscription::string(),
%%                    Url_ok::string(),Url_nok::string()) ->
%%                    erlpage_result(). 
%%%% Start refill. Redirect to next page depending on provisioning result.

refill_start(plugin_info, Subscription, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill is allowed.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
	"This parameter specifies the next page when refill is allowed."},
       {url_nok, {link,[]},
	"This parameter specifies the next page when refill is not allowed."}
      ]});

refill_start(abs, _, Url_ok, Url_nok) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_nok}];

refill_start(Session, Subscription, Url_ok, Url_nok) 
  when Subscription=="cmo" ->
    case provisioning_ftm:dump_billing_info(Session) of
	{continue, Session_prov} ->
	    {redirect, Session_prov, Url_ok};
	{stop, Session_err, Reason} ->
	    {redirect, Session_err, Url_nok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_mobicarte(session(),Subscription::string(),
%%                        Url_ph2_ok::string(),Url_ph1_ok::string(),
%%                        Url_nok::string()) ->
%%                        erlpage_result(). 
%%%% Refill by mobicarte.

refill_mobicarte(plugin_info, Subscription, Url_ph2_ok, Url_ph1_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the ussd phase (1 or 2).",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ph2_ok, {link,[]},
	"This parameter specifies the next page for ussd phase 2."},
       {url_ph1_ok, {link,[]},
	"This parameter specifies the next page for ussd phase 1."},
       {url_nok, {link,[]},
	"This parameter specifies the next page when an error occured."}
      ]});

refill_mobicarte(abs, Subscription, Url_ph2_ok, Url_ph1_ok, Url_nok) ->
    [{redirect, abs, Url_ph2_ok},
     {redirect, abs, Url_ph1_ok},
     {redirect, abs, Url_nok}];

refill_mobicarte(#session{prof=Profile}=Session, Subscription,
		Url_ph2_ok, Url_ph1_ok, Url_nok)
  when Subscription=="cmo" ->
    case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, State}  ->
	    NewSession = svc_util_of:update_user_state(Session_,State),
	    determine_homepage(NewSession, Url_ph2_ok, Url_ph1_ok);
	Error ->
	    %% This should not happen because we have already gone
	    %% through provisioning in svc_home.
	    {redirect, Session, Url_nok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type determine_homepage(session(),
%%                          Url_ph2_ok::string(),Url_ph1_ok::string()) ->
%%                          erlpage_result(). 
%%%% Internal function used by plugin refill_mobicarte.

determine_homepage(#session{bearer={ussd,1}}=Session,
		   Url_ph2_ok, Url_ph1_ok) ->
    {redirect, Session, Url_ph1_ok};
determine_homepage(#session{}=Session,
		   Url_ph2_ok, Url_ph1_ok)->
    {redirect, Session, Url_ph2_ok}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_cb(session(),Subscription::string(),
%%                 Url_ok::string(),
%%                 Url_nok::string()) ->
%%                 erlpage_result(). 
%%%% Refill by cb.

refill_cb(plugin_info, Subscription, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the result of authentication.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
	"This parameter specifies the next page when authentication ok,"
	" information should then be requested using plugin request_info."},
       {url_nok, {link,[]},
	"This parameter specifies the next page when authentication failed."}
      ]});

refill_cb(abs, Subscription, Url_ok, Url_nok) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_nok}];

refill_cb(#session{prof=Profile}=Session, Subscription, Url_ok, Url_nok)
  when Subscription=="cmo" ->
    case provisioning_ftm:read_sdp_state(Session) of
	{ok, Session_, State}  ->
 	    %% Reinit recharge_cb_cmo.
 	    NState = State#sdp_user_state{tmp_recharge=#recharge_cb_cmo{}},
 	    NewSession =
		svc_util_of:update_user_state(Session_,NState),
            {redirect, NewSession, Url_ok};
 	Error ->
 	    %% This should not happen because we have already gone
 	    %% through provisioning in svc_home.
	    {redirect, Session, Url_nok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_cb_identify(session(),Subscription::string(),
%%                        Url_ok::string(),
%%                        Url_nok::string()) ->
%%                        erlpage_result(). 

refill_cb_identify(plugin_info, Subscription, Url_ok,Url_no_msisdn, Url_nok) ->    
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the result of identification.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
        "This parameter specifies the next page when identification ok."},
       {url_no_msisdn, {link,[]},                                                                                                                        
	"This parameter specifies the next page when no msisdn."}, 
       {url_nok, {link,[]},
        "This parameter specifies the next page when identification failed."}
      ]});
refill_cb_identify(abs, Subscription, Url_ok,Url_no_msisdn, Url_nok) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_no_msisdn},
     {redirect, abs, Url_nok}];

refill_cb_identify(#session{prof=Profile}=Session, Subscription, Url_ok, Url_no_msisdn, Url_nok)
  when Subscription=="cmo" ->
      case svc_subscr_asmetier:get_identification(Session, "oee") of 
          {ok, IdDosOrch, IdUtilisateurEdlws, CodeOffreType, _, NewSession} ->
              {redirect, NewSession, Url_ok};
	  {nok,error,no_msisdn}->
	      {redirect, Session, Url_no_msisdn};
	  _->
	      {redirect, Session, Url_nok}
      end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_rechargeable_cb(session(),Subscription::string(),
%%                          Url_ok::string(),
%%                          Url_nok::string()) ->
%%                         erlpage_result(). 

is_rechargeable_cb(plugin_info, Subscription, Url_ok, Url_not_auth, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the result of authentication.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
	"This parameter specifies the next page when authentication ok."},
       {url_not_auth, {link,[]},
	"This parameter specifies the next page when authentication nok"},
       {url_nok, {link,[]},
	"This parameter specifies the next page when authentication failed."}
      ]});

is_rechargeable_cb(abs, Subscription, Url_ok, Url_not_auth, Url_nok) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_not_auth},
     {redirect, abs, Url_nok}];

is_rechargeable_cb(#session{prof=Profile}=Session, Subscription, Url_ok, Url_not_auth, Url_nok)
  when Subscription=="cmo" ->
      case svc_subscr_asmetier:is_rechargeable_cb(Session) of 
          {ok, PlafondStr, MontantMaxStr, Session1} -> 
              List_to_number = fun(X) -> 
                                   case string:to_float(X) of
                                       {error, _} -> 
                                           list_to_integer(X);
                                       {Number, _} ->
                                           Number
                                   end
                               end,
              Plafond = currency:sum(euro, List_to_number(PlafondStr)),
              MontantMax = currency:sum(euro, List_to_number(MontantMaxStr)),
              NewSession = update_recharge_cb(Session1, [{plafond, Plafond}, 
                                                        {montant_max, MontantMax}]),
              {redirect, NewSession, Url_ok};
          {nok, Exception} ->
	      case Exception of
		  #'ExceptionEtatDossierIncorrect'{}=E ->
		      {redirect, Session, Url_not_auth};
		  #'ExceptionOptionInterdite'{}=E ->
		      {redirect, Session, Url_not_auth};
		  _ ->
		      {redirect, Session, Url_nok}
	      end;
	  _ ->
	    {redirect, Session, Url_nok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_tlr(session(),Subscription::string(),Url_ok::string()) ->
%%                  erlpage_result(). 
%%%% Refill by tlr. Initialize sdp_user_state.

refill_tlr(plugin_info, Subscription, Url_ok) ->
    (#plugin_info
     {help =
      "This plugin command redirects initializes the sdp_user_state"
      " for refill by tlr and redirects to the page url_ok.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
	"This parameter specifies the next page."}
      ]});

refill_tlr(abs, Subscription, Url_ok) ->
    [{redirect, abs, Url_ok}];

refill_tlr(#session{prof=Profile}=Session, Subscription, Url_ok)
  when Subscription=="cmo" ->
    {_,Session_}= svc_util_of:reinit_compte(Session),
    State = svc_util_of:get_user_state(Session_),
    Session1 = svc_util_of:update_user_state(Session_, State),
    {redirect, Session1, Url_ok}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type request_info(session(),Subscription::string(),
%%                    Url_ok::string(),
%%                    Url_nok::string()) ->
%%                    erlpage_result(). 
%%%% Request cb info via http.

request_info(plugin_info, Subscription, Url_ok, Url_nok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page Url_ok if info request"
      " was successful, otherwise to Url_nok.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
	"This parameter specifies the next page when info request"
	" successful."},
       {url_nok, {link,[]},
	"This parameter specifies the next page when info request returns"
	" an error."}
      ]});

request_info(abs, Subscription, Url_ok, Url_nok) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_nok}];

request_info(Session, Subscription, Url_ok, Url_nok)
  when Subscription=="cmo" ->
    State = svc_util_of:get_user_state(Session),
    MSISDN = int_to_nat((Session#session.prof)#profile.msisdn),
    case cbhttp:info(MSISDN,?info_version,?sub) of
	{ok, [_,MSISDN,_,EPR_NUM,ESC_NUM,DOS_CUMUL_REC,DATEDER,
	      UNT_NUM,PLAFOND_E,SOLDE_E,VALID24,NB_CPT,BONUS,MOBI_OPT,
	      DOS_DATE_DER_REC,DOS_MONTANT_REC]}->
	    PLF_E = currency:sum(euro,PLAFOND_E/1000),
	    MONTANT_MOIS = currency:sum(euro,DOS_CUMUL_REC/1000),
	    REST = currency:sub(PLF_E,MONTANT_MOIS),
	    %% Store amount of refills still left 
	    NSession = update_recharge_cb(Session, [{plafond,REST}]),
	    {redirect,NSession, Url_ok};
	Else->
	    slog:event(failure, ?MODULE, cbhttp_info_error, [info,Else,MSISDN]),
	    {redirect, Session, Url_nok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_time(session(),Subscription::string(),
%%                    Url_first::string(),
%%                    Url_not_first::string()) 
%%                    erlpage_result(). 
%%%% Request cb info via http.

first_time(plugin_info, Subscription, Url_first, Url_not_first) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page Url_not_first if "
      " the client already done a CB refill, otherwise to Url_first.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_first, {link,[]},
	"This parameter specifies the next page when first trial for CB"
	"refill"},
       {url_not_first, {link,[]},
	"This parameter specifies the next page when next trial."}
      ]});

first_time(abs, Subscription, Url_first, Url_not_first ) ->
    [{redirect, abs, Url_first},
     {redirect, abs, Url_not_first}];

first_time(Session, Subscription, Url_first, Url_not_first)
  when Subscription=="cmo" ->
    State = svc_util_of:get_user_state(Session),
    case svc_util_of:is_first_recharge(State) of 
	true ->
	    {redirect,Session, Url_first};
	_ ->
	    {redirect,Session, Url_not_first}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_code(session(),Subscription::string(),
%%                   Url_cb_ok::string(),
%%                   Url_code_ok::string(),
%%                   Url_code_1 ::string(),
%%                   Ucode_incorrect::string(),
%%                   Ucode_incorrect_second::string(),
%%                   Code::string()) ->
%%                   erlpage_result(). 
%%%% Check correctness of entered short code or CB number.

verify_code(plugin_info, Subscription, Url_cb_ok, Url_code_ok, Url_code_1,
	    Ucode_incorrect, Ucode_incorrect_third, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the next page depending on the"
      " correctness of the entered information (short code, CB number,"
      " or refill code).",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_cb_ok, {link,[]},
	"This parameter specifies the next page when the entered"
	" CB number is correct."},
       {url_code_ok, {link,[]},
	"This parameter specifies the next page when the entered"
	" short code is correct."},
       {url_code_1, {link,[]},
	"This parameter specifies the next page when the entered"
	" short code is 1."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when first trial for code"
	" or CB number ended in format incorrect."},
       {ucode_incorrect_third, {link,[]},
	"This parameter specifies the next page when third trial for code"
	" or CB number ended in format incorrect."},
       {code, form_data,
        "This parameter specifies the code to be entered.\n"
	"It can be either a 14 digits refill code, a 4 digits short code or"
	" a CB number from 16 to 19 digits."
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

verify_code(abs, Subscription, Url_cb_ok, Url_code_ok, Url_code_1,
	    Ucode_incorrect, Ucode_incorrect_third, Code) ->
    [{redirect, abs, Url_cb_ok},
     {redirect, abs, Url_code_ok},
     {redirect, abs, Url_code_1},
     {redirect, abs, Ucode_incorrect},
     {redirect, abs, Ucode_incorrect_third}];

verify_code(Session, Subscription, Url_cb_ok, Url_code_ok, Url_code_1,
	    Ucode_incorrect, Ucode_incorrect_third, Code)
  when Subscription=="cmo", length(Code)>=16, length(Code)=<19 ->
    case pbutil:all_digits(Code) of
	true->
	    verif_cle_luhn(Session, Code, Url_cb_ok, Ucode_incorrect,
			   Ucode_incorrect_third);
	false->
	    wrong_code_cb(Session, Ucode_incorrect, Ucode_incorrect_third)
    end;

verify_code(Session, Subscription, Url_cb_ok, Url_code_ok, Url_code_1,
	    Ucode_incorrect, Ucode_incorrect_third, "1") 
  when Subscription=="cmo" ->
    {redirect, Session, Url_code_1};

verify_code(Session, Subscription, Url_cb_ok, Url_code_ok, Url_code_1,
            Ucode_incorrect, Ucode_incorrect_third, Code) 
  when Subscription=="cmo" ->
    case svc_util_of:is_code(Code,4) of
	true->
	    NSession = update_recharge_cb(Session, [{code_court,Code}]),
	    {redirect, NSession, Url_code_ok};
	false->
              wrong_code_cb(Session, Ucode_incorrect, Ucode_incorrect_third)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verif_cle_luhn(session(),CB::string(),Url_cb_ok::string(),
%%                      Ucode_incorrect::string(),
%%                      Ucode_incorrect_second::string()) ->
%%                      erlpage_result(). 
%%%% Internal function used by plugin verify_code.

verif_cle_luhn(Session, Code, Url_cb_ok, Ucode_incorrect, 
	       Ucode_incorrect_second) ->
    State =svc_util_of:get_user_state(Session),
    case svc_util_of:is_cle_luhn(Code) of
	true->
	    NSession = update_recharge_cb(Session, [{no_carte_cb,Code}]),
	    {redirect, NSession, Url_cb_ok};
	false->
	    wrong_code_cb(Session, Ucode_incorrect, Ucode_incorrect_second)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type wrong_code_cb(session(),
%%                     Ucode_incorrect::string(),
%%                     Ucode_incorrect_second::string()) ->
%%                     erlpage_result(). 
%%%% Internal function used by plugin verify_code.

wrong_code_cb(Session, Ucode_incorrect, Ucode_incorrect_second)->
    F_TENTA=(cast(Session))#recharge_cb_cmo.c_code_CB,
    case F_TENTA of
	X when X>1->
	    NSession = update_recharge_cb(Session, [{c_code_CB, F_TENTA-1}]),
	    {redirect, NSession, Ucode_incorrect};
	1 ->
	    {redirect, Session, Ucode_incorrect_second}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_date(session(),Subscription::string(),
%%                   Url_ok::string(),
%%                   Udate_incorrect::string(),
%%                   Udate_incorrect_second::string(),
%%                   Date::string()) ->
%%                   erlpage_result(). 
%%%% Check correctness of entered date.

verify_date(plugin_info, Subscription, Url_ok,
	    Udate_incorrect, Udate_incorrect_third, Date) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page url_ok if the format of"
      " of the entered date is correct, otherwise to ucode_incorrect for a"
      " retry, or ucode_incorrect_second if no more retries allowed.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_ok, {link,[]},
	"This parameter specifies the next page when the entered date"
	" is correct."},
       {udate_incorrect, {link,[]},
	"This parameter specifies the next page when first trial for date"
	" ended in format incorrect."},
       {udate_incorrect_third, {link,[]},
	"This parameter specifies the next page when third trial for date"
	" ended in format incorrect."},
       {date, form_data,
        "This parameter specifies the validity date of the CB.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

verify_date(abs, Subscription, Url_ok,
	    Udate_incorrect, Udate_incorrect_third, Date) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Udate_incorrect},
     {redirect, abs, Udate_incorrect_third}];

verify_date(Session, Subscription, Url_ok,
	    Udate_incorrect, Udate_incorrect_third, Date) 
  when Subscription=="cmo" ->
    C_DATE=(cast(Session))#recharge_cb_cmo.c_date_valid,
    case {(svc_util_of:is_code(Date,4) and
	   svc_util_of:is_date_ok(Date)),C_DATE} of
	{true,_}->
	    NSession = update_recharge_cb(Session, [{date_valid_cb,Date}]),
	    {redirect, NSession, Url_ok};
	{false,C_DATE} when C_DATE>1->
	    NSession = update_recharge_cb(Session, [{c_date_valid, C_DATE-1}]),
	    {redirect, NSession, Udate_incorrect};
	{false,_} ->
	    NSession = update_recharge_cb(Session, [{c_date_valid,0}]),
	    {redirect, NSession, Udate_incorrect_third}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_code_tlr(session(),Subscription::string(),
%%                       Url_refill::string(),
%%                       Ucode_incorrect_retry::string(),
%%                       Ucode_incorrect::string(), Code) ->
%%                       erlpage_result(). 
%%%% Check correctness of entered TLR code.

verify_code_tlr(plugin_info, Subscription, Url_refill, Ucode_incorrect_retry,
		Ucode_incorrect, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page url_refill if the entered"
      " code is correct, otherwise to the page ucode_incorrect_retry to enter"
      " the code again, or to the page ucode_incorrect if the maximum number"
      " of retries is reached.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {url_refill, {link,[]},
	"This parameter specifies the next page when the code is correct."},
       {ucode_incorrect_retry, {link,[]},
	"This parameter specifies the next page when the code is incorrect"
	" and retry is allowed."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when code is incorrect and"
	" retry is not allowed."},
       {code, form_data,
        "This parameter specifies the 4 digits code to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

verify_code_tlr(abs, Subscription, Url_refill, Ucode_incorrect_retry,
		Ucode_incorrect, Code) ->
    [{redirect, abs, Url_refill},
     {redirect, abs, Ucode_incorrect_retry},
     {redirect, abs, Ucode_incorrect}];

verify_code_tlr(Session,  Subscription, Url_refill, Ucode_incorrect_retry,
		Ucode_incorrect, Code) ->
    F_TENTA=(cast(Session))#recharge_cb_cmo.c_tlr,
    case {svc_util_of:is_code(Code,4),F_TENTA} of
	{true,_}->
	    %% store TLR
	    NSession=update_recharge_cb(Session,[{tlr,Code}]),
	    {redirect, NSession, Url_refill};
	{false,X} when X>1->
	    NSession=update_recharge_cb(Session,[{c_tlr,F_TENTA-1}]),
	    {redirect, NSession, Ucode_incorrect_retry};
	{false,1}->
	    {redirect, Session, Ucode_incorrect}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_code_cvx2(session(),Subscription::string(),
%%                        Url_refill::string(),
%%                        Ucode_incorrect_retry::string(),
%%                        Ucode_incorrect::string(), Code) ->
%%                        erlpage_result(). 
%%%% Checks the correctness of the entered cvx2 code.

verify_code_cvx2(plugin_info, Subscription, Url_refill, Ucode_incorrect_retry,
		 Ucode_incorrect, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page url_refill if the entered"
      " code is correct, otherwise to the page ucode_incorrect_retry to enter"
      " the code again, or to the page ucode_incorrect if the maximum number"
      " of retries is reached.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
	"This parameter specifies the subscription."},
       {url_refill, {link,[]},
	"This parameter specifies the next page when the code is correct."},
       {ucode_incorrect_retry, {link,[]},
	"This parameter specifies the next page when the code is incorrect"
	" and retry is allowed."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when code is incorrect and"
	" retry is not allowed."},
       {code, form_data,
	"This parameter specifies the 3 digits code to be entered.\n"
	"If the plugin is used to process data from a form, this parameter"
	" will be overridden by the form data."}
      ]});

verify_code_cvx2(abs, _, Url_refill, Ucode_incorrect_retry,
		 Ucode_incorrect, Code) ->
    [{redirect, abs, Url_refill},
     {redirect, abs, Ucode_incorrect_retry},
     {redirect, abs, Ucode_incorrect}];

verify_code_cvx2(Session, Subscription, Url_refill, Ucode_incorrect_retry,
		 Ucode_incorrect, Code) ->
    F_TENTA=(cast(Session))#recharge_cb_cmo.c_cvx2,
    case {svc_util_of:is_code(Code,3),F_TENTA} of
	{true,_}->
	    NSession=update_recharge_cb(Session,[{cvx2,Code}]),
	    {redirect, NSession, Url_refill};
	{false,X} when X>1->
	    NSession=update_recharge_cb(Session,[{c_cvx2,F_TENTA-1}]),
	    {redirect, NSession, Ucode_incorrect_retry};
	{false,1}->
	    {redirect, Session, Ucode_incorrect}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type create_access_code(session(),Subscription::string(),
%%                          Uok::string(),
%%                          Ucode_incorrect_retry::string(),
%%                          Ucode_incorrect::string(),
%%                          Code::string()) ->
%%                          erlpage_result(). 
%%%% Requests to enter an access code when code is created.

create_access_code(plugin_info, Subscription, Uok, Ucode_incorrect_retry,
		   Ucode_incorrect, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page url_refill if the entered"
      " code is correct, otherwise to the page ucode_incorrect_retry to enter"
      " the code again, or to the page ucode_incorrect if the maximum number"
      " of retries is reached.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when the code is correct."},
       {ucode_incorrect_retry, {link,[]},
	"This parameter specifies the next page when the code is incorrect"
	" and retry is allowed."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when code is incorrect and"
	" retry is not allowed."},
       {code, form_data,
        "This parameter specifies the 4 digits code to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

create_access_code(abs, Subscription, Uok, Ucode_incorrect_retry,
		   Ucode_incorrect, Code) ->
    [{redirect, abs, Uok},
     {redirect, abs, Ucode_incorrect_retry},
     {redirect, abs, Ucode_incorrect}];

create_access_code(Session, Subscription, Uok, Ucode_incorrect_retry,
		   Ucode_incorrect, Code) ->
    Rech_CB=cast(Session),
    F_TENTA=Rech_CB#recharge_cb_cmo.c_create_code,
    case svc_util_of:is_code(Code,4) of
	true->
	    NSession=update_recharge_cb(Session,[{new_code_acces,Code}]),
	    {redirect, NSession, Uok};
	false->
	    case F_TENTA of
		X when X>1->
		    NSession=update_recharge_cb(Session,
						[{c_create_code,F_TENTA-1}]),
		    {redirect, NSession, Ucode_incorrect_retry};
		X when X==1->
		    {redirect, Session, Ucode_incorrect}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type modify_access_code(session(),Subscription::string(),
%%                          Uok::string(),
%%                          Ucode_incorrect_retry::string(),
%%                          Ucode_incorrect::string(),
%%                          Code::string()) ->
%%                          erlpage_result(). 
%%%% Requests to enter an access code when code is modified.

modify_access_code(plugin_info, Subscription, Uok, Ucode_incorrect_retry,
		   Ucode_incorrect, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page url_refill if the entered"
      " code is correct, otherwise to the page ucode_incorrect_retry to enter"
      " the code again, or to the page ucode_incorrect if the maximum number"
      " of retries is reached.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when the code is correct."},
       {ucode_incorrect_retry, {link,[]},
	"This parameter specifies the next page when the code is incorrect"
	" and retry is allowed."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when code is incorrect and"
	" retry is not allowed."},
       {code, form_data,
        "This parameter specifies the 4 digits code to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

modify_access_code(abs, Subscription, Uok, Ucode_incorrect_retry,
		   Ucode_incorrect, Code) ->
    [{redirect, abs, Uok},
     {redirect, abs, Ucode_incorrect_retry},
     {redirect, abs, Ucode_incorrect}];

modify_access_code(Session, Subscription, Uok, Ucode_incorrect_retry,
		   Ucode_incorrect, Code) ->
    Rech_CB=cast(Session),
    F_TENTA=Rech_CB#recharge_cb_cmo.c_modif_code,
    case svc_util_of:is_code(Code,4) of
	true->
	    NSession = update_recharge_cb(Session, [{new_code_acces,Code}]),
	    {redirect, NSession, Uok};
	false->
	     case F_TENTA of
		X when X>1->
		    NSession = update_recharge_cb(Session,
						  [{c_modif_code,F_TENTA-1}]),
		    {redirect, NSession, Ucode_incorrect_retry};
		X when X==1->
		    {redirect, Session, Ucode_incorrect}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_access_code(session(),Subscription::string(),
%%                          Uok::string(),Ucreate_ac::string(),
%%                          Uincorrect::string(),Uincorrect_last::string(),
%%                          Ureinit_code::string(),Unok::string(),
%%                          Code::string()) ->
%%                          erlpage_result(). 
%%%% Checks the correctness of the entered access code.

verify_access_code(plugin_info, Subscription, Uok, Ucreate_ac, Uincorrect,
		   Uincorrect_last, Ureinit_code, Unok, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page uok after validation"
      " of the entered code.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when access code correct."},
       {ucreate_ac, {link,[]},
	"This parameter specifies the next page when new access"
	" code created."},
       {uincorrect, {link,[]},
	"This parameter specifies the next page when the code is incorrect"
	" and retry is allowed."},
       {uincorrect_last, {link,[]},
	"This parameter specifies the next page when the entered code"
	" was incorrect, a last trial is allowed before code reinitialized."},
       {ureinit_code_nok, {link,[]},
	"This parameter specifies the next page when code is incorrect and"
	" retry is not allowed."},
       {unok, {link,[]},
	"This parameter specifies the next page when an error occured."},
       {code, form_data,
        "This parameter specifies the 4 digits code to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

verify_access_code(abs, Subscription, Uok, Ucreate_ac, Uincorrect,
		   Uincorrect_last, Ureinit_code, Unok, Code) ->
    [{redirect, abs, Uok},
     {redirect, abs, Ucreate_ac},
     {redirect, abs, Uincorrect},
     {redirect, abs, Uincorrect_last},
     {redirect, abs, Ureinit_code},
     {redirect, abs, Unok}];

verify_access_code(Session, Subscription, Uok, Ucreate_ac, Uincorrect,
		   Uincorrect_last, Ureinit_code, Unok, Code) ->
    case svc_util_of:is_code(Code,4) of
	false->
	    verify_access_code_nok(Session, Uincorrect, Uincorrect_last,
				   Ureinit_code);
	true->
	    MSISDN = int_to_nat((Session#session.prof)#profile.msisdn),
	    IMSI =
		svc_util_of:imsi_court((Session#session.prof)
					       #profile.imsi),
	    case cbhttp:vcod(MSISDN,IMSI,Code,?vcod_version,?sub) of
		{ok,[MSISDN,IMSI]} ->
		    NSession=update_recharge_cb(Session,[{code_acces,Code},
							 {code_court,Code}]),
		    {redirect, NSession, Uok};
		{statut,156} ->
		    verify_access_code_nok(Session, Uincorrect,
					   Uincorrect_last, Ureinit_code);
		{statut,X} when X==158;X==159 ->
		    {redirect, Session, Ureinit_code};
		{statut,157} ->
		    {redirect, Session, Ucreate_ac};
		Else ->
		    slog:event(failure, ?MODULE, cbhttp_vcod_error, [vcod,Else,MSISDN]),
		    {redirect, Session, Unok}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_access_code_nok(session(),
%%                              Uincorrect::string(),
%%                              Uincorrect_last::string(),
%%                              Ureinit_code::string()) ->
%%                              erlpage_result(). 
%%%% Internal function used by plugin verify_access_code.

verify_access_code_nok(Session, Uincorrect, Uincorrect_last, Ureinit_code) ->
    NB_ten=(cast(Session))#recharge_cb_cmo.c_code_acces,
    NSession=update_recharge_cb(Session, [{c_code_acces,NB_ten-1}]),
    case NB_ten-1 of
	X when X>1->
	    {redirect, NSession, Uincorrect};
	X when X==1->
	    {redirect, NSession, Uincorrect_last};
	X when X<1->
	    {redirect, NSession, Ureinit_code}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_code_contract(session(),Subscription::string(),
%%                            Ucreate_ac::string(),
%%                            Ucode_incorrect_retry::string(),
%%                            Ucode_incorrect::string(), Code::string()) ->
%%                            erlpage_result(). 
%%%% Checks the correctness of the customer contract code.

verify_code_contract(plugin_info, Subscription, Ucreate_ac,
		     Ucode_incorrect_retry, Ucode_incorrect, Code) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the page url_refill if the entered"
      " code is correct, otherwise to the page ucode_incorrect_retry to enter"
      " the code again, or to the page ucode_incorrect if the maximum number"
      " of retries is reached.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
	"This parameter specifies the subscription."},
       {ucreate_ac, {link,[]},
	"This parameter specifies the next page when the code is correct."},
       {ucode_incorrect_retry, {link,[]},
	"This parameter specifies the next page when the code is incorrect"
	" and retry is allowed."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when code is incorrect and"
	" retry is not allowed."},
       {code, form_data,
	"This parameter specifies the 10 digits code to be entered.\n"
	"If the plugin is used to process data from a form, this parameter"
	" will be overridden by the form data."}
      ]});

verify_code_contract(abs, _, Ucreate_ac, Ucode_incorrect_retry,
		     Ucode_incorrect, Code) ->
    [{redirect, abs, Ucreate_ac},
     {redirect, abs, Ucode_incorrect_retry},
     {redirect, abs, Ucode_incorrect}];

verify_code_contract(Session, Subscription, Ucreate_ac,
		     Ucode_incorrect_retry, Ucode_incorrect, Code) ->
    Rech_CB=cast(Session),
    Code_contrat = Rech_CB#recharge_cb_cmo.code_client,
    case {svc_util_of:is_code(Code,10),Code_contrat==Code} of
	{true,true}->
	    {redirect, Session, Ucreate_ac};
	_->
	    F_TENTA = Rech_CB#recharge_cb_cmo.c_code_client,
	    case F_TENTA of
		X when X>1->
		    NSession = update_recharge_cb(Session,
						  [{c_code_client,F_TENTA-1}]),
		    {redirect, NSession, Ucode_incorrect_retry};
		X when X==1->
		    {redirect, Session, Ucode_incorrect}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type enter_mobile_choix/5(session(),
%%                        Subscription::string(),
%%                        Uok::string(),
%%                        Unok::string(),
%%                        NO_CHOIX::string()) ->
%%                        erlpage_result(). 
%%%% Checks that the entered amount is between the minimum and maximum
%%%% allowed.

enter_mobile_choix(plugin_info, Subscription, Uok, Unok, NO_CHOIX) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the next page depending on whether"
      " the entered amount is between the allowed limits.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when the mobile number of choice is correct."},
       {unok, {link,[]},
	"This parameter specifies the next page when the mobile number of choice is incorrect"},
       {numero, form_data,
        "This parameter specifies the mobile number of choice.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

enter_mobile_choix(abs, Subscription, Uok, Unok, NO_CHOIX) ->
    [{redirect, abs, Uok},
     {redirect, abs, Unok}];

enter_mobile_choix(Session, Subscription, Uok, Unok, NO_CHOIX) 
  when Subscription=="cmo" ->
    case verif_no_choix(Session, NO_CHOIX) of 
	true ->
	    [$0,H|_] = NO_CHOIX,
	    case H of 
		$6 -> 
		    State = svc_util_of:get_user_state(Session),
		    NState = State#sdp_user_state{numero_st_valentin = NO_CHOIX},
		    NSession = svc_util_of:update_user_state(Session, NState),
		    {redirect, NSession, Uok};
		_ ->
		    {redirect, Session, Unok}
	    end;
	_ ->
	    {redirect, Session, Unok}	
    end.

%% +type get_mobile_choix/2(session(),
%%                        Subscription::string())->
%%                        erlpage_result().
%%%% Get the mobile number of choice entered.
get_mobile_choix(plugin_info, Subscription) ->        
     (#plugin_info
      {help =
       "This plugin command redirects to the next page depending on whether"
       " the entered amount is between the allowed limits.",
       type = function,
       license = [],
       args =
       [
	{subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."}      
       ]});
get_mobile_choix(abs,_) -> [];
get_mobile_choix(Session, Subscription)
  when Subscription=="cmo"->
    State = svc_util_of:get_user_state(Session),
    NO_CHOIX = State#sdp_user_state.numero_st_valentin,
    [{pcdata,NO_CHOIX}].
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type verif_no_choix(session(),
%%                      NO_CHOIX::string()) -> erlpage_result(). 
%%%% Internal function used by plugin enter_mobile_choix.

verif_no_choix(Session, NO_CHOIX) 
  when is_list(NO_CHOIX), length(NO_CHOIX)==10 ->
    pbutil:all_digits(NO_CHOIX);
verif_no_choix(_,_)->
    false.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type enter_amount(session(),Subscription::string(),
%%                    Uconfirm::string(),
%%                    Uamount_less_min::string(),
%%                    Uamount_incorrect_third::string(),
%%                    Urech_special::string(),
%%                    Amount::string()) ->
%%                    erlpage_result(). 
%%%% Checks that the entered amount is between the minimum and maximum
%%%% allowed.

enter_amount(plugin_info, Subscription, Uconfirm, Uamount_less_min,
	     Uamount_incorrect_third, Urech_special, Amount) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the next page depending on whether"
      " the entered amount is between the allowed limits.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uconfirm, {link,[]},
	"This parameter specifies the next page when the amount is correct."},
       {uamount_less_min, {link,[]},
	"This parameter specifies the next page when the amount is less"
	" than the minimum allowed."},
       {uamount_incorrect_third, {link,[]},
	"This parameter specifies the next page when the second trial for "
	" the amount is not correct."},
       {urech_special, {link,[]},
        "This parameter specifies the next page to recharge edition special"},
       {amount, form_data,
        "This parameter specifies the refill amount.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

enter_amount(abs, Subscription, Uconfirm, Uamount_less_min,
	     Uamount_incorrect_third,Urech_special, Amount) ->
    [{redirect, abs, Uconfirm},
     {redirect, abs, Uamount_less_min},
     {redirect, abs, Uamount_incorrect_third},
     {redirect, abs, Urech_special}];

enter_amount(Session, Subscription, Uconfirm, Uamount_less_min,
	     Uamount_incorrect_third,Urech_special, Amount) 
  when Subscription=="cmo" ->
    Min = currency:sum(
	    pbutil:get_env(pservices_orangef,recharge_cb_cmo_mini)),
    case pbutil:all_digits(Amount) of
	true ->
	    case list_to_integer(Amount) of
		1 ->
		    {redirect, Session, Urech_special};
		_ ->
		    check_amount(Session, Amount, Min, Uconfirm, Uamount_less_min,
				 Uamount_incorrect_third, Urech_special)
	    end;
	_ -> 
	    wrong_amount(Session, Uamount_less_min,
			 Uamount_incorrect_third)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_amount(session(),Amount::string(),Min::string(),
%%                    Uconfirm::string(),
%%                    Uamount_less_min::string(),
%%                    Uamount_more_max::string(),
%%                    Uamount_incorrect_third::string()) ->
%%                    erlpage_result(). 
%%%% Internal function used by plugin enter_amount.

check_amount(Session, Amount, Min, Uconfirm, Uamount_less_min,
	     Uamount_incorrect_third, Urech_special) ->
    State =svc_util_of:get_user_state(Session),
    MaxMontant = (cast(Session))#recharge_cb_cmo.montant_max,
    Mont = currency:sum(euro,list_to_integer(Amount)),
    case currency:is_infeq(Min,Mont) of
	true->
	    %% store amount
	    NSession = update_recharge_cb(Session, [{montant, Mont}]),
	    {redirect, NSession, Uconfirm};
	_->
	    %% amount < min allowed
	    wrong_amount(Session, Uamount_less_min,
			 Uamount_incorrect_third)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type wrong_amount(session(),
%%                    Uamount_less_min::string(),
%%                    Uamount_incorrect_third::string(),
%%                    SupOrInf::atom()) ->
%%                    erlpage_result(). 
%%%% Internal function used by plugin enter_amount.

wrong_amount(Session, Uamount_less_min, Uamount_incorrect_third) ->
    C_montant = (cast(Session))#recharge_cb_cmo.c_montant,
    case C_montant of
	X when X>1->
	     NSession = update_recharge_cb(Session,
					   [{c_montant, C_montant-1}]),
	    {redirect, NSession, Uamount_less_min};
	_->
	    NSession = update_recharge_cb(Session, [{c_montant,0}]),
	    {redirect, NSession, Uamount_incorrect_third}
    end.

check_amount_rech_spe(plugin_info, Subscription, Amount, Uconfirm, Umore_max, Uamount_incorrect_third) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the next page depending on whether"
      " the entered amount is between the allowed limits.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,cmo_par]}},
        "This parameter specifies the subscription."},
       {amount, {oma_type, {enum, [10,20,30]}},
        "This parameter specifies the amount."},
       {uconfirm, {link,[]},
	"This parameter specifies the next page when the amount is correct."},
       {umore_max, {link,[]},
	"This parameter specifies the next page when the amount is less"
	" than the minimum allowed."},
       {uamount_incorrect_third, {link,[]},
	"This parameter specifies the next page when the second trial for "
	" the amount is not correct."}
      ]});

check_amount_rech_spe(abs, Subscription, Amount, Uconfirm, Umore_max, Uamount_incorrect_third) ->
    [{redirect, abs, Uconfirm},
     {redirect, abs, Umore_max},
     {redirect, abs, Uamount_incorrect_third}];

check_amount_rech_spe(Session,Subscription, Amount, Uconfirm, Umore_max, Uamount_incorrect_third) ->
    case Subscription of 
	"cmo" ->	    
	    MaxMontant = (cast(Session))#recharge_cb_cmo.montant_max;
	_->	    
	    MaxMontant = (cast(Session))#recharge_cb_cmo.plafond
    end,    
    C_montant = (cast(Session))#recharge_cb_cmo.c_montant,
    Mont = currency:sum(euro,list_to_integer(Amount)),
    case currency:is_infeq(Mont,MaxMontant) of
        true ->
	    NSession = update_recharge_cb(Session,[{montant, Mont}, 
						   {c_montant, 0}]),
	    {redirect, NSession, Uconfirm};
	_ ->
	    case C_montant > 1 of
		 true ->		    
		    NSession = update_recharge_cb(Session, [{c_montant, C_montant-1}]),
		    {redirect, NSession, Umore_max};
		_->
		    NSession = update_recharge_cb(Session, [{c_montant,0}]),
		    {redirect, NSession, Uamount_incorrect_third}    
	    end
    end.
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type reinit_counter(session(),Counter::string(),
%%                      Uok::string()) ->
%%                      erlpage_result(). 
%%%% Reinitializes the count of allowed retries.

reinit_counter(plugin_info, Counter, Uok) ->
    (#plugin_info
     {help =
      "This plugin command reinitialzes the counter of allowed retries",
      type = command,
      license = [],
      args =
      [
       {counter, {oma_type, {enum, [c_montant,
				    c_create_code,
				    c_modif_code]}},
        "This parameter specifies the counter to be reinitialized."},
       {uok, {link,[]},
	"This parameter specifies the next page when the counter has been"
	" reinitialized."}
      ]});

reinit_counter(abs, _, Uok)->
    [{redirect, abs, Uok}];

reinit_counter(Session, Counter, Uok) ->
    NSession = update_recharge_cb(Session,
				  [{list_to_atom(Counter),?NB_tentative}]),
    {redirect, NSession, Uok}.

%%payment_debit/2
payment_debit(plugin_info,Urefill_ok) ->
    (#plugin_info
     {help =
      "This plugin command sends the payment request when payment is done"
      " by bank account debit, and redirects to the one of the pages:\n"
      " urefill_ok if payment was successfully done,"
      " upb_cb if a problem occured, and"
      " urefused if payment was refused.",
      type = command,
      license = [],
      args =
      [
       {urefill_ok, {link,[]},
 	"This parameter specifies the next page when payment was successful."}
      ]});

payment_debit(abs, Urefill_ok) ->
    [{redirect, abs, Urefill_ok}];

payment_debit(Session, Urefill_ok) ->
     case do_payment(Session,?pay_version,?sub) of
	 {ok, Session1}->
	     prisme_dump:prisme_count_v1(Session,"PRECTLR"),
	     {redirect, Session1, Urefill_ok};
	 {statut,286} ->
	     {redirect, Session, "errors.xml#error_opt"};
	 {statut,300} ->
	     {redirect, Session, "errors.xml#not_registred"};
	 {statut,303} ->
	     {redirect, Session, "errors.xml#pb_cb"};
	 {statut,304} ->
	     {redirect, Session, "errors.xml#not_authorized"};
	 {statut,314} ->
	     {redirect, Session, "errors.xml#payment_refused"};
	 {statut,377} ->
	     {redirect, Session, "errors.xml#error_377"};
	 Else ->
	     slog:event(failure, ?MODULE, cbhttp_unexpected_pay_status, Else),
	     {redirect, Session, "errors.xml#pb_tech_cb"}
     end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_payment(session(),integer(),atom())->
%%                   {ok, session()} | term().
%%%% Internal function used by plugin payment.


do_payment(Session, ?pay_version, ?sub) ->
    State = svc_util_of:get_user_state(Session),
    Rech_CB = cast(Session),
    Msisdn = int_to_nat((Session#session.prof)#profile.msisdn),
    IMSI = svc_util_of:imsi_court((Session#session.prof)#profile.imsi),
    Dosnum=State#sdp_user_state.dos_numid,
    case catch cbhttp:pay(Msisdn,IMSI,Dosnum,Rech_CB,?pay_version,?sub) of
 	{ok,[Msisdn,_,NB_CPT,TCP_NUM,CPP_DATE_LV,SOLDE,UNT_NUM,BON_PCT,
 	     BONUS_MONTANT]=Resp}->
 	    %% update account
 	    NSession = update_session_after_recharge(Session,SOLDE,UNT_NUM),
 	    %% update maximum allowed amount and refill amount*
 	    Plafond=Rech_CB#recharge_cb_cmo.plafond,
 	    Montant=Rech_CB#recharge_cb_cmo.montant,
 	    slog:avg(trace,?MODULE,montant_recharge,
		     currency:round_value(Montant)),
 	    NSession2 = 
		update_recharge_cb(NSession,
				   [{plafond,currency:sub(Plafond,Montant)},
				    {bonus_montant,
				     currency:sum(euro,BONUS_MONTANT/1000)}]),
 	    {ok,NSession2};
 	Else ->
	    slog:event(failure, ?MODULE, cbhttp_pay, [pay, Else, Msisdn]), 
	    Else
   end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% verify_refill_code/5
%% +type verify_refill_code(session(),Subscription::string(),
%%                          Uok::string(),
%%                          Unok::string(),CG::string()) ->
%%                          erlpage_result(). 
%%%% Check correctness of entered code for refill by Mobicarte.

verify_refill_code(plugin_info, Subscription, Uok, Unok, CG) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether on the correctness of the entered code.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when the entered code"
	" is correct."},
       {unok, {link,[]},
	"This parameter specifies the next page in any other error case."},
       {cg, form_data,
        "This parameter specifies the 14 digit code to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

verify_refill_code(abs,_,Uok,Unok,_) ->
    [{redirect, abs, Uok},
     {redirect, abs, Unok}];

verify_refill_code(Session, Subscription, Uok, Unok, CG) ->
    case svc_util_of:is_valid(CG) of
	{nok, _} ->
	    case variable:get_value(Session,{recharge,"nb_code_trials"}) of
		"1" ->
		    Session_nok = 
			variable:update_value(Session,
					      {recharge,"nb_code_trials"},
					      "0"),
		    {redirect, Session_nok, "errors.xml#format_incorrect_1"};		
		"2" ->
		    Session_nok = 
			variable:update_value(Session,
					      {recharge,"nb_code_trials"},
					      "1"),
		    {redirect, Session_nok, "errors.xml#format_incorrect_2"};
		_ ->
		    Session_nok = 
			variable:update_value(Session,
					      {recharge,"nb_code_trials"},
					      "1"),
		    {redirect, Session_nok, "errors.xml#format_incorrect_3"}
	    end;

	{ok, Code}  ->
 	    Session_ok =
		variable:update_value(Session, {recharge,"code"}, Code),
	    {redirect, Session_ok, Uok}
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_refill_code(session(),Subscription::string(),
%%                          Uok::string(),
%%                          Ucode_incorrect::string(),
%%                          Ucode_incorrect_second::string(),
%%                          Unok::string(),Try::integer(),
%%                          CG::string()) ->
%%                          erlpage_result(). 
%%%% Check correctness of entered code for refill by Mobicarte.

verify_refill_code_try(plugin_info, Subscription, Uok, Ucode_incorrect,
		       Ucode_incorrect_last, Number_try, CG) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether on the correctness of the entered code.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo,
					carrefour_comptebloque]}},
        "This parameter specifies the subscription."},

       {uok, {link,[]},
	"This parameter specifies the next page when the entered code"
	" is correct."},
       {ucode_incorrect, {link,[]},
	"This parameter specifies the next page when first trial for code"
	" ended in format incorrect."},
       {ucode_incorrect_last, {link,[]},
	"This parameter specifies the next page when second trial for code"
	" ended in format incorrect."},
       {number_try, {oma_type, {enum, [1,2,3,4,5]}},
        "This parameter specifies the number of try."},
       {cg, form_data,
        "This parameter specifies the 14 digit code to be entered.\n"
        "If the plugin is used to process data from a form, this parameter"
        " will be overridden by the form data."}
      ]});

verify_refill_code_try(abs,_, Uok, Ucode_incorrect, Ucode_incorrect_last,
		       Number_try, CG) ->
    [{redirect, abs, Uok},
     {redirect, abs, Ucode_incorrect},
     {redirect, abs, Ucode_incorrect_last}];
verify_refill_code_try(Session, Subscription, Uok, Ucode_incorrect,
                       Ucode_incorrect_last, Number_try, "0")
  when Subscription=="carrefour_comptebloque"->
    {redirect, Session,"/mcel/acceptance/selfcare_carrefour_cb.xml#suivi_conso_niv1"};
verify_refill_code_try(Session, Subscription, Uok, Ucode_incorrect,
                       Ucode_incorrect_last, Number_try, "00")
  when Subscription=="carrefour_comptebloque"->
    {redirect, Session,"/mcel/acceptance/selfcare_carrefour_cb.xml#suivi_conso_niv1"};
verify_refill_code_try(Session, Subscription, Uok, Ucode_incorrect,
		       Ucode_incorrect_last, Number_try, CG) ->

    case svc_util_of:is_valid(CG) of
	{nok, _} ->

	    case X=variable:get_value(Session,{recharge,"nb_code_trials"}) of

		not_found->
		    Session_nok = 
			variable:update_value(Session,
					      {recharge,"nb_code_trials"},
					      "1"),
		    {redirect, Session_nok, Ucode_incorrect};

		_ ->		     
		    Session_nok = 
			variable:update_value(Session,
					      {recharge,"nb_code_trials"},
					      integer_to_list(
						list_to_integer(X)+1)),

		    case variable:get_value(Session_nok,
					    {recharge,"nb_code_trials"}) of

			Number_try-> 
			    {redirect, Session, Ucode_incorrect_last};

			_ ->
			    {redirect, Session_nok, Ucode_incorrect}

		    end

	    end;

	{ok, Code}  ->
	    Session_ok =
		variable:update_value(Session, {recharge,"code"}, Code),
	    {redirect, Session_ok, Uok}
    end.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_request(session(),Subscription::string(),
%%                      Uok::string(),
%%                      Uok_princ_sms::string()
%%                      Uok_sl_20E::string()
%%                      Unok::string()) ->
%%                      erlpage_result(). 
%%%% Send request to refill by Mobicarte.
%%%% Redirect to next page depending on refill result.
refill_request(plugin_info, Subscription,
	       Uok, Uok_princ_sms, Uok_sl_20E, Unok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when refill succeeded."},
       {uok_princ_sms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" princ and sms account exist."},
       {uok_sl_20E, {link,[]},
        "This parameter specifies the next page when refill succeeded,"
        " appels illimites."},
        {unok, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."}
      ]});

refill_request(abs, _, Uok, Uok_princ_sms, Uok_sl_20E, Unok) ->
    [{redirect, abs, Uok},
     {redirect, abs, Uok_princ_sms},
     {redirect, abs, Uok_sl_20E},
     {redirect, abs, Unok}
    ];

refill_request(#session{prof=Profile}=Session, Subscription,
	       Uok, Uok_princ_sms, Uok_sl_20E, Unok) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                               pbutil:unixtime(),Default_choice) of
	{ok, Session_new, Infos} ->
	    success_d6(Session_new, Infos,
		       Uok, Uok_princ_sms);
        {error, Status} ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_6,Status,Msisdn]),
            New_Session = variable:update_value(Session,{recharge,"tr_error"},Status),
	    {redirect, New_Session, Unok};
	Error ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_6,Error,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Error),
	    {redirect, New_Session, Unok}
    end.

refill_request(plugin_info, Subscription,
	       Uok, U_sys_failure, U_bad_profil, U_incompatible, U_promo,
	       U_bad_code) ->

    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [{subscription, {oma_type, {enum, [ten_comptebloque,
                                         tele2_comptebloque,
                                         carrefour_comptebloq]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when refill succeeded."},
       {u_sys_failure, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."},
       {u_bad_profil, {link,[]},
 	"This parameter specifies the next page when the user has not access"
	" to this service"},
       {u_incompatible, {link,[]},
 	"This parameter specifies the next page when refill is incompatible."},
       {u_promo, {link,[]},
 	"This parameter specifies the next page when the promo refill"
	" is not allowed"},
       {u_bad_code, {link,[]},
 	"This parameter specifies the next page when the refill"
	"code is not correct."}
      ]});

refill_request(abs, _, Uok, U_sys_failure, U_bad_profil, U_incompatible, U_promo,
	       U_bad_code) ->
    [{redirect, abs, Uok},
     {redirect, abs, U_sys_failure},
     {redirect, abs, U_bad_profil},
     {redirect, abs, U_incompatible},
     {redirect, abs, U_promo},
     {redirect, abs, U_bad_code}];

refill_request(#session{prof=Profile}=Session, "carrefour_comptebloq",
	       Uok, U_sys_failure, U_bad_profil, U_incompatible, U_promo,
	       U_bad_code) ->

    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                               pbutil:unixtime(),Default_choice) of
	{ok, Session_new, Infos} ->
	    {redirect, Session_new, Uok};
	{error, Error} ->           
            svc_recharge:recharge_error(Session, Error, U_bad_profil, U_sys_failure, 
                                        U_bad_code, U_incompatible, U_promo)
    end;
%%%% Redirected to Bad_code
%% 		{status, [10,4]} ->
%%                     slog:event(service_ko, ?MODULE,response_10_4, tr_vole),
%% 		    {redirect, Session, U_incompatible};


refill_request(#session{prof=Profile}=Session, Subscription,
	       Uok, U_sys_failure, U_bad_profil, U_incompatible, U_promo,
	       U_bad_code) ->

    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                               pbutil:unixtime(),Default_choice) of
	{ok, Session_new, Infos} ->
	    {redirect, Session_new, Uok};
	{error, Error} ->
            svc_recharge:recharge_error(Session, Error, U_bad_profil, U_sys_failure, 
                                        U_bad_code, U_incompatible, U_promo);
        {nok, Reason} ->
            slog:event(warning,?MODULE,bad_response_from_sachem,
                       [recharge_ticket,Reason, Msisdn]),
            {redirect, Session,U_sys_failure};
        Else ->
            slog:event(failure, ?MODULE,bad_response_from_sachem,
                       [recharge_ticket,Else,Msisdn]),
            {redirect, Session,U_sys_failure}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  refill_request/12
%% +type refill_request(session(),Subscription::string(),
%%                      Uok::string(),
%%                      Uok_princ_sms::string(),
%%                      Uok_no_sms::string(),
%%                      Uok_no_princ::string(),
%%                      Uact_weinf::string(),
%%                      Uok_sms_mms::string(),
%%                      Uok_sl::string(),
%%                      Unok_sl::string(),
%%                      Unok::string(),
%%                      Uok_recharge_vacances::string()) ->
%%                      erlpage_result(). 
%%%% Send request to refill by Mobicarte.
%%%% Redirect to next page depending on refill result.

refill_request(plugin_info, Subscription,
	       Uok, Uok_princ_sms, Uok_no_sms,
	       Uok_no_princ, Uact_weinf,	       
	       Uok_sms_mms, Uok_sl,  Unok_sl, Unok,
	       Uok_recharge_vacances
) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when refill succeeded."},
       {uok_princ_sms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" princ and sms account exist."},
       {uok_no_sms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" princ, no sms account."},
       {uok_no_princ, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" no princ."},    
       {uact_weinf, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" week-end infini already subscribed."},       
       {uok_sms_mms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" Cas SMS/MMS"},
       {uok_sl, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" successful subscription to Option Surf 7j"
	" Cas Recharge 7E Serie Limitee"},
       {unok_sl, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" unsuccessful subscription to Option Surf 7j"
	" Cas Recharge 7E Serie Limitee"},
       {unok, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."},
       {uok_reacharge_vacances, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	"Cas Recharge Vacances."}
      ]});

refill_request(abs, _, Uok, Uok_princ_sms, Uok_no_sms,
	       Uok_no_princ, Uact_weinf,	       
	       Uok_sms_mms, Uok_sl, Unok_sl, Unok,
	       Uok_recharge_vacances) ->
    [{redirect, abs, Uok},
     {redirect, abs, Uok_princ_sms},
     {redirect, abs, Uok_no_sms},
     {redirect, abs, Uok_no_princ},     
     {redirect, abs, Uact_weinf},     
     {redirect, abs, Uok_sms_mms},
     {redirect, abs, Uok_sl},
     {redirect, abs, Unok_sl},
     {redirect, abs, Unok},
     {redirect, abs, Uok_recharge_vacances}];

refill_request(#session{prof=Profile}=Session, Subscription,
	       Uok, Uok_princ_sms, Uok_no_sms, Uok_no_princ,
	       Uact_weinf, Uok_sms_mms, Uok_sl, Unok_sl, Unok,
	       Uok_recharge_vacances) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                               pbutil:unixtime(),Default_choice) of
	{ok, Session_new, Infos} ->
	    success_d6(Session_new, Infos,
		       Uok, Uok_princ_sms, Uok_no_sms, Uok_no_princ,
		       Uact_weinf, Uok_sms_mms, Uok_sl, Unok_sl, Uok_recharge_vacances);
	{error, Status} ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_12,Status,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"}, Status),
	    {redirect, New_Session, Unok};
	Error ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_12,Error,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Error),
	    {redirect, New_Session, Unok}
    end.

refill_request_rech_sl(plugin_info, Uok_rech_sl, Unok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [
       {uok_rech_sl, {link,[]},
        "This parameter specifies the next page when refill succeeded."},
        {unok, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."}
      ]});

refill_request_rech_sl(abs, Uok_rech_sl, Unok) ->
    [
     {redirect, abs, Uok_rech_sl},
     {redirect, abs, Unok}
    ];

refill_request_rech_sl(#session{prof=Profile}=Session, Uok_rech_sl, Unok) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, pbutil:unixtime(),?CHOICE_RECH_SL) of
	{ok, Session_new, Infos} ->
	    prisme_dump:prisme_count_v1(Session,"PRECTRSL"),
	    {redirect, Session_new, Uok_rech_sl};
	{error, Status} ->
	    slog:event(warning, ?MODULE, recharge_request,[refill_request_rech_sl,Status,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Status),
	    {redirect, New_Session, Unok};
	Error ->
	    slog:event(warning, ?MODULE, recharge_request,[refill_request_rech_sl,Error,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Error),
	    {redirect, New_Session, Unok}
    end.

refill_request_cmo(plugin_info, Subscription,
	       Uok, Uok_princ_sms, Unok) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when refill succeeded."},
       {uok_princ_sms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" princ and sms account exist."},
        {unok, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."}
      ]});

refill_request_cmo(abs, _, Uok, Uok_princ_sms, Unok) ->
    [{redirect, abs, Uok},
     {redirect, abs, Uok_princ_sms},
     {redirect, abs, Unok}
    ];

refill_request_cmo(#session{prof=Profile}=Session, Subscription,
	       Uok, Uok_princ_sms, Unok) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                                            pbutil:unixtime(),Default_choice) of
        {ok, Session_new, Infos} ->
	    prisme_dump:prisme_count_v1(Session,"PRECTR"),
            success_d6(Session_new, Infos, Uok, Uok_princ_sms);
        {error, Status} ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_cmo_5,Status,Msisdn]),
            New_Session = variable:update_value(Session,{recharge,"tr_error"},Status),
            {redirect, New_Session, Unok};
        Error ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_cmo_5,Error,Msisdn]),
            New_Session = variable:update_value(Session,{recharge,"tr_error"},Error),
            {redirect, New_Session, Unok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_request(session(),Subscription::string(),
%%                      Uok::string(),
%%                      Uok_princ_sms::string(),
%%                      Uok_no_sms::string(),
%%                      Uok_no_princ::string(),
%%                      Uok_subscr_opt::string(),
%%                      Uact_weinf::string(),
%%                      Unok_subscr_weinf::string(),
%%                      Uok_eur::string(),
%%                      Uok_magh::string(),
%%                      Uok_sms_mms::string(),
%%                      Uok_sl::string(),
%%                      Unok_sl::string(),
%%                      Unok::string(),
%%                      Uok_recharge_vacances::string()) ->
%%                      erlpage_result(). 
%%%% Send request to refill by Mobicarte.
%%%% Redirect to next page depending on refill result.

refill_request(plugin_info, Subscription,
	       Uok, Uok_princ_sms, Uok_no_sms,
	       Uok_no_princ, Uok_subscr_weinf, Uact_weinf,
	       Unok_subscr_weinf, Uok_eur, Uok_magh,
	       Uok_sms_mms, Uok_sl,  Unok_sl, Unok,
	       Uok_recharge_vacances
) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uok, {link,[]},
	"This parameter specifies the next page when refill succeeded."},
       {uok_princ_sms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" princ and sms account exist."},
       {uok_no_sms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" princ, no sms account."},
       {uok_no_princ, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" no princ."},
       {uok_subscr_weinf, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" subscription to week-end infini."},
       {uact_weinf, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" week-end infini already subscribed."},
       {unok_subscr_weinf, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" unsuccessful subscription to week-end infini."},
       {uok_eur, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" Cas Europe"},
       {uok_magh, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" Cas Maghreb"},
       {uok_sms_mms, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" Cas SMS/MMS"},
       {uok_sl, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" successful subscription to Option Surf 7j"
	" Cas Recharge 7E Serie Limitee"},
       {unok_sl, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	" unsuccessful subscription to Option Surf 7j"
	" Cas Recharge 7E Serie Limitee"},
       {unok, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."},
       {uok_reacharge_vacances, {link,[]},
	"This parameter specifies the next page when refill succeeded,"
	"Cas Recharge Vacances."}
      ]});

refill_request(abs, _, Uok, Uok_princ_sms, Uok_no_sms,
	       Uok_no_princ, Uok_subscr_weinf, Uact_weinf,
	       Unok_subscr_weinf, Uok_eur, Uok_magh,
	       Uok_sms_mms, Uok_sl, Unok_sl, Unok,
	       Uok_recharge_vacances) ->
    [{redirect, abs, Uok},
     {redirect, abs, Uok_princ_sms},
     {redirect, abs, Uok_no_sms},
     {redirect, abs, Uok_no_princ},
     {redirect, abs, Uok_subscr_weinf},
     {redirect, abs, Uact_weinf},
     {redirect, abs, Unok_subscr_weinf},
     {redirect, abs, Uok_eur},
     {redirect, abs, Uok_magh},
     {redirect, abs, Uok_sms_mms},
     {redirect, abs, Uok_sl},
     {redirect, abs, Unok_sl},
     {redirect, abs, Unok},
     {redirect, abs, Uok_recharge_vacances}];

refill_request(#session{prof=Profile}=Session, Subscription,
	       Uok, Uok_princ_sms, Uok_no_sms, Uok_no_princ,
	       Uok_subscr_weinf, Uact_weinf, Unok_subscr_weinf,
	       Uok_eur, Uok_magh, Uok_sms_mms, Uok_sl, Unok_sl, Unok,
	       Uok_recharge_vacances) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                               pbutil:unixtime(),Default_choice) of
	{ok, Session_new, Infos} ->
	    success_d6(Session_new, Infos,
		       Uok, Uok_princ_sms, Uok_no_sms, Uok_no_princ,
		       Uok_subscr_weinf, Uact_weinf, Unok_subscr_weinf,
		       Uok_eur, Uok_magh, Uok_sms_mms, Uok_sl, Unok_sl, Uok_recharge_vacances);
	{error, Status} ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_16,Status,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Status),
	    {redirect, New_Session, Unok};
	Error ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_16,Error,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Error),
	    {redirect, New_Session, Unok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% success_d6/11
%% +type success_d6(session(),Infos::term(),
%%                  Uok::string(),
%%                  Uok_princ_sms::string(),
%%                  Uok_no_sms::string(),
%%                  Uok_no_princ::string(),
%%                  Uact_weinf::string(),
%%                  Uok_sms_mms::string(),
%%                  Uok_sl::string(),
%%                  Unok_sl::string(),
%%                  Uok_recharge_vacances::string()) ->
%%                  erlpage_result().
%%%% Internal function used by plugin refill_request.

success_d6(#session{prof=Prof}=Session,
           Infos,
	   Uok, Uok_princ_sms, Uok_no_sms,
	   Uok_no_princ, Uact_weinf,
	   Uok_sms_mms, Uok_sl, Unok_sl, Uok_recharge_vacances) ->
    {Session2, TCPs, CTK_NUM} = get_info_success(Session, Infos),
    %% Next page depends on option and account
    case {TCPs,CTK_NUM,Prof#profile.subscription} of	
	{_,?RECHARGE_SMSMMS,"cmo"} ->
	    {redirect, Session2, Uok_sms_mms};
	{_,?RECHARGE_SL,"cmo"} ->
	    do_subscription(Session2, opt_sl_7E, Uok_sl, Unok_sl);
	{_,?RECHARGE_VACANCES,_}->
	    {redirect,Session2,Uok_recharge_vacances};
	{[?C_PRINC],_,_} ->
	    {redirect, Session2, Uok_no_sms};
	{[?C_ASMS],_,_} ->
	    {redirect, Session2, Uok_no_princ};
	{[?C_PRINC,?C_ASMS],_,_} ->
	    {redirect,Session2,Uok_princ_sms};
	{_,_,_} ->
	    {redirect, Session2, Uok}
    end.
%% success_d6/4
%% +type success_d6(session(),Infos::term(),
%%                  Uok::string(),
%%                  Uok_princ_sms::string(),
%%%% Internal function used by plugin refill_request.

success_d6(#session{prof=Prof}=Session,
           Infos,
	   Uok, Uok_princ_sms) ->
    {Session2, TCPs, CTK_NUM} = get_info_success(Session, Infos),
    %% Next page depends on option and account
    case {TCPs,CTK_NUM,Prof#profile.subscription} of	
	{[?C_PRINC,?C_ASMS],_,_} ->
	    {redirect,Session2,Uok_princ_sms};
	{_,_,_} ->
	    {redirect, Session2, Uok}
    end.

%% success_d6/6
%% +type success_d6(session(),Infos::term(),
%%                  Uok::string(),
%%                  Uok_princ_sms::string(),
%%                  Uok_20E::string(),
%%                  Unok::string(),
%%%% Internal function used by plugin refill_request.

success_d6(#session{prof=Prof}=Session,
           Infos,
	   Uok, Uok_princ_sms, Uok_20E, Unok) ->
    {Session2, TCPs, CTK_NUM} = get_info_success(Session, Infos),
    %% Next page depends on option and account
    case {TCPs,CTK_NUM,Prof#profile.subscription} of	
	{[?C_PRINC,?C_ASMS],_,_} ->
	    prisme_dump:prisme_count_v1(Session,"PRECTR"),
	    {redirect,Session2,Uok_princ_sms};
	{_,?RECHARGE_20E_SL,"cmo"} ->
	    prisme_dump:prisme_count_v1(Session,"PRECTRSL"),
	    {redirect,Session2,Uok_20E};
	{_,_,_} ->
	    {redirect, Session2, Uok}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type success_d6(session(),Infos::term(),
%%                  Uok::string(),
%%                  Uok_princ_sms::string(),
%%                  Uok_no_sms::string(),
%%                  Uok_no_princ::string(),
%%                  Uok_subscr_weinf::string(),
%%                  Uact_weinf::string(),
%%                  Unok_subscr_weinf::string(),
%%                  Uok_eur::string(),
%%                  Uok_magh::string(),
%%                  Uok_sms_mms::string(),
%%                  Uok_sl::string(),
%%                  Unok_sl::string(),
%%                  Uok_recharge_vacances::string()) ->
%%                  erlpage_result().
%%%% Internal function used by plugin refill_request.

success_d6(#session{prof=Prof}=Session,
           Infos,
	   Uok, Uok_princ_sms, Uok_no_sms,
	   Uok_no_princ, Uok_subscr_weinf, Uact_weinf,
	   Unok_subscr_weinf, Uok_eur, Uok_magh, Uok_sms_mms, 
	   Uok_sl, Unok_sl, Uok_recharge_vacances) ->
    {Session2, TCPs, CTK_NUM} = get_info_success(Session, Infos),
    %% Next page depends on option and account
    case {TCPs,CTK_NUM,Prof#profile.subscription} of
	{_,?RECHARGE_WEINF,"cmo"} ->
	    do_weinf_souscription(Session2, Uok_subscr_weinf, Uact_weinf,
				  Unok_subscr_weinf);
	{_,?RECHARGE_EUROPE,"cmo"} ->
	    {redirect, Session2, Uok_eur};
	{_,?RECHARGE_MAGHREB,"cmo"} ->
	    {redirect, Session2, Uok_magh};
	{_,?RECHARGE_SMSMMS,"cmo"} ->
	    {redirect, Session2, Uok_sms_mms};
	{_,?RECHARGE_SL,"cmo"} ->
	    do_subscription(Session2, opt_sl_7E, Uok_sl, Unok_sl);
	{_,?RECHARGE_VACANCES,_}->
	    {redirect,Session2,Uok_recharge_vacances};
	{[?C_PRINC],_,_} ->
	    {redirect, Session2, Uok_no_sms};
	{[?C_ASMS],_,_} ->
	    {redirect, Session2, Uok_no_princ};
	{[?C_PRINC,?C_ASMS],_,_} ->
	    {redirect,Session2,Uok_princ_sms};
	{_,_,_} ->
	    {redirect, Session2, Uok}
    end.

%% +type get_opt_info(session(), list())->
%%                    {session(), list(), string()}.
get_info_success(Session, Infos) ->
    CTK_NUM = svc_util_of:get_param_value("CTK_NUM", Infos),
    COMPTES = svc_util_of:get_param_value("CPT_PARAMS", Infos),
    TCPs = lists:sort(lists:map(fun([TCP_NUM|T])-> list_to_integer(TCP_NUM) end, COMPTES)),
    {Session, TCPs, list_to_integer(CTK_NUM)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_weinf_souscription(Session::session(),
%%                             Uok_subscr_weinf::string(),
%%                             Uact_weinf::string(),
%%                             Unok_subscr_weinf::string()) ->
%%                             erlpage_result(). 
%%%% Internal function used by plugin refill_if_correct_code.

do_weinf_souscription(Session, Uok_subscr_weinf, Uact_weinf,
		      Unok_subscr_weinf)->
    {Session_new,State} = svc_options:check_topnumlist(Session),
    case svc_options:is_option_activated(Session_new,opt_weinf) of
	true->
	    {redirect, Session_new, Uact_weinf};
	false->
	    {Session1,Result} = svc_options:do_opt_cpt_request(Session_new,opt_weinf, subscribe),
	    case Result of
		{ok_operation_effectuee,_} ->
		    {redirect, Session1, Uok_subscr_weinf};
		{nok_opt_deja_existante,""} ->
		    {redirect, Session1, Uact_weinf};
                {nok, option_deja_existante} ->
		    {redirect, Session1, Uact_weinf};
                {error, "option_inexistante"} ->
		    {redirect, Session1, Uact_weinf};
		_ ->
		  {redirect, Session1, Unok_subscr_weinf}
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription(Session::session(),Option::atom(),Uok::string(),
%%                       Unok::string()) ->
%%                       erlpage_result(). 
%%%% Internal function used by plugin refill_if_correct_code.

do_subscription(Session, Option, Uok, Unok)->
    {Session_new,State} = svc_options:check_topnumlist(Session),
    case svc_options:do_opt_cpt_request(Session_new, Option, subscribe) of
	{Session1,{ok_operation_effectuee,_}} ->
	    {redirect, Session1, Uok};
	{Session1,_} ->
	    {redirect, Session1, Unok}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_lucky_number(session(),Subscription::string(),Url_ok::string()) ->
%%                  erlpage_result(). 
%%%% Refill by tlr. Initialize sdp_user_state.
is_lucky_number(plugin_info, Subscription, Success_mobile_prize, Success_sinf, Success_mobile_prize2, Loosing_case, Temporary, Nb) ->
    (#plugin_info
     {help =
      "This plugin command check if number entered [1-7]by the"
      "customer is winning. According with thisstate a page is returned",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {success_mobile_prize, {link,[]},
	"This parameter specifies the page when the user win a mobile phone "},
       {success_opt_sinf_kdo, {link,[]},
	"This parameter specifies the next page for opt soiree infinie"
	" and retry is allowed."},
        {success_mobile_prize_2, {link,[]},
	"This page is returned for loosing case but the user will participate to the drawing of lots"},
       {loosing_case, {link,[]},
	"This page is returned for loosing case but the user loose"},
	{temporary, {link,[]},
	"This page is returned when user won something but the subscription failed"},
       {lucky_number, form_data,
        "This parameter specifies the nb to be entered.\n"
	"It must be between 1 and 7."}
      ]});

is_lucky_number(abs, Subscription,  Success_mobile_prize, Success_sinf, Success_mobile_prize2, Loosing_case, Temporary, Lucky_nb) ->
    svc_recharge_cb_mobi:is_lucky_number(abs, Lucky_nb);

is_lucky_number(#session{prof=Profile}=Session, Subscription, Success_mobile_prize, Success_sinf, Success_mobile_prize2, Loosing_case, Temporary, Lucky_nb)
  when Subscription=="cmo" ->
    svc_recharge_cb_mobi:is_lucky_number(Session, Lucky_nb).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO PRINT INFORMATION IN SCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_refill_info(Session::session(),
%%                         Pay_with::string(),Info::string()) ->
%%                         [{pcdata,string()}].
%%%% This plugin prints the specified information.

print_refill_info(plugin_info, Pay_with, Info) ->
    (#plugin_info
     {help =
      "This plugin function includes the specified information.",
      type = function,
      license = [],
      args = [
	      {pay_with, {oma_type, {enum, [mobicarte,
					    cb_or_short_code,
					    debit_account]}},
	       "This parameter specifies which type of payment is used."},
	      {info, {oma_type, {enum, [max_amount,
					min_amount,
					amount,
					access_code]}},
	       "This parameter specifies information to be included."}
	     ]});

print_refill_info(abs, _, _) ->
    [{pcdata,"XX"}];

print_refill_info(Session, "debit_account", Info) 
  when Info=="max_amount" ->
    Max_montant=(cast(Session))#recharge_cb_cmo.plafond,
    [{pcdata,currency:print(Max_montant)}];


print_refill_info(Session, Pay_with, Info) 
  when Info=="max_amount" ->
    Max_montant=(cast(Session))#recharge_cb_cmo.montant_max,
    [{pcdata,currency:print(Max_montant)}];

print_refill_info(Session, Pay_with, Info) 
  when Info=="min_amount"->    
    RECH_MINI =currency:sum(pbutil:get_env(pservices_orangef,
					   recharge_cb_cmo_mini)),
    [{pcdata,currency:print(RECH_MINI)}];

print_refill_info(Session, Pay_with, Info) 
  when Pay_with=="mobicarte",
       Info=="amount"->
    State = svc_util_of:get_user_state(Session),
    Montant= (State#sdp_user_state.tmp_recharge)#recharge.montant,
    Mt = trunc(currency:round_value(Montant)),
    [{pcdata, integer_to_list(Mt)}];

print_refill_info(Session, Pay_with, Info) 
  when Info=="amount"->
    Mnt=(cast(Session))#recharge_cb_cmo.montant,
    Int_Mnt=trunc(currency:round_value(Mnt)),
    [{pcdata,integer_to_list(Int_Mnt)}];

print_refill_info(Session, Pay_with, Info) 
  when Info=="access_code" ->
    NCODE = (cast(Session))#recharge_cb_cmo.new_code_acces,
    [{pcdata,NCODE}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UTILITIES USED IN THIS MODULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type update_recharge_cb(session(),[{Name::atom(),Value::term()}])->
%%                          sdp_user_state().

update_recharge_cb(Session,Values)->
    State = svc_util_of:get_user_state(Session),
    Fields = record_info(fields, recharge_cb_cmo),
    %% Read the default permissions.
    RCB1=
	case cast(Session) of
	    #recharge_cb_cmo{}=RC->
		RC;
	    Else->
		#recharge_cb_cmo{}
	end,
    RCB2=pbutil:update_record(Fields, RCB1, Values),
    svc_util_of:update_user_state(Session,
				  State#sdp_user_state{tmp_recharge=RCB2}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
%% +type update_session_after_recharge(session(),Solde::integer(),
%%                                     UNT::integer())->
%%                                     erlpage_result().

update_session_after_recharge(Session, Solde, UNT_NUM)->
    OldState = svc_util_of:get_user_state(Session),
    Compte = OldState#sdp_user_state.cpte_princ,
    NewSolde = currency:sum(euro, Solde/1000),
    NewCompte = Compte#compte{cpp_solde=NewSolde,
 			      etat=?CETAT_AC},
    svc_util_of:update_user_state(Session,
 				  OldState#sdp_user_state{cpte_princ=
							  NewCompte}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type cast(session())-> recharge_cb_cmo().

cast(Session)->
    State = svc_util_of:get_user_state(Session),
    State#sdp_user_state.tmp_recharge.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type int_to_nat(string())-> string().

int_to_nat("+33"++MSISDN)->
    "0"++MSISDN;
int_to_nat("+99"++MSISDN)->
    "0"++MSISDN;
int_to_nat("06"++Rest=MSISDN) ->
    MSISDN;
int_to_nat("07"++Rest=MSISDN) ->
    MSISDN.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% redirect_tr_error/8
%% +type redirect_tr_error(session(),Subscription::string(),
%%               U_bad_profil::string(), U_incompatible::string(), U_incompatible_offre::string(), U_promo::string(),
%%               U_bad_code::string(), U_sys_failure::string()) ->
%%               erlpage_result(). 
%%%% Redirection for the TR error 

redirect_tr_error(plugin_info, Subscription, U_bad_profil, U_incompatible, U_promo, U_bad_code_55, U_bad_code_56, U_sys_failure) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " the error store in the variable tr_error.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
	"This parameter specifies the subscription."},
       {url_badprofil, {link,[]},
 	"This parameter specifies the next page when error type is bad profil."},
       {url_incompatible, {link,[]},
 	"This parameter specifies the next page when error type is incompatible."},
       {url_promo, {link,[]},
 	"This parameter specifies the next page when error type is promo."},
       {url_badcode_55, {link,[]},
 	"This parameter specifies the next page when error type is badcode."},
       {url_badcode_56, {link,[]},
 	"This parameter specifies the next page when error type is badcode."},
       {url_systemfailure, {link,[]},
 	"This parameter specifies the next page when error type is systemfailure."}
      ]});

redirect_tr_error(abs, _, U_bad_profil, U_incompatible, U_promo, U_bad_code_55, U_bad_code_56, U_sys_failure)->
    [{redirect, abs, U_bad_profil},
     {redirect, abs, U_incompatible},
     {redirect, abs, U_promo},
     {redirect, abs, U_bad_code_55},
     {redirect, abs, U_bad_code_56},
     {redirect, abs, U_sys_failure}];

redirect_tr_error(Session, Subscription, U_bad_profil, U_incompatible, 
                  U_promo, U_bad_code_55,U_bad_code_56, U_sys_failure)
  when Subscription=="cmo" ->	
    Error = variable:get_value(Session,{recharge,"tr_error"}),
    svc_recharge:recharge_error(Session, Error, U_bad_profil, U_sys_failure, 
                                U_bad_code_55, U_bad_code_56, U_incompatible,
                                U_incompatible, U_promo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type verify_special_mobicarte(session(),Subscription::string(),
%%                      Uspecial20Menu::string(),
%%                      Uspecial20Direct::string(),
%%                      U_20E_musique::string(),
%%                      Unormal::string(),
%%                      Utck_nok::string(),
%%                      Utck_used::string(),
%%                      Unormal::string(),
%%                      Url_nok::string()) ->
%%%% Send request to check the Mobicarte.
%%%% Redirect to next page depending on CTK result.

verify_special_mobicarte(plugin_info, Subscription,
	       Uspecial10E, Uspecial20E, Uspecial30E, Unormal, Utck_nok, Utck_used, Unok) ->
    (#plugin_info
     {help =
      "This plugin command send the CTK request redirects to the corresponding page depending on"
      " whether special refill.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {uspecial10E, {link,[]},
	"This parameter specifies the next page when mobicarte is special."},
       {uspecial20E, {link,[]},
	"This parameter specifies the next page when mobicarte is special."},
       {uspecial30E, {link,[]},
	"This parameter specifies the next page when mobicarte is special."},
       {unormal, {link,[]},
	"This parameter specifies the next page when mobicarte is normal."},
       {utck_nok, {link,[]},
	"This parameter specifies the next page when bad mobicarte."},
       {utck_used, {link,[]},
	"This parameter specifies the next page when mobicarte is used."},
       {unok, {link,[]},
	"This parameter specifies the next page when technical problem occurs"}
      ]});

verify_special_mobicarte(abs, _, Uspecial10E, Uspecial20E, Uspecial30E, Unormal, Utck_nok, Utck_used, Unok) ->
    [{redirect, abs, Uspecial10E},
     {redirect, abs, Uspecial20E},
     {redirect, abs, Uspecial30E},
     {redirect, abs, Unormal},
     {redirect, abs, Utck_nok},
     {redirect, abs, Utck_used},
     {redirect, abs, Unok}];

verify_special_mobicarte(#session{prof=Profile}=Session, Subscription,
			 Uspecial10E, Uspecial20E, Uspecial30E, Unormal, Utck_nok, Utck_used, Unok) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    case svc_recharge:send_consult_rech_request(Session, 
                                                {cmo,Msisdn}, ?TCK_KEY_TYPE, Code) of
	{ok, Answer_tck} ->
	    STATUS = proplists:get_value("STATUT",Answer_tck),
            slog:event(trace,?MODULE,status,STATUS),
            if (STATUS=/=undefined) -> 
                    case list_to_integer(STATUS) of
                        0 -> 
                            slog:event(trace,?MODULE,status,STATUS),
                            case svc_recharge:get_ett_num(Answer_tck) of
                                undefined -> 
                                    {redirect, Session, Unok};
                                ETT_NUM when ETT_NUM==3;ETT_NUM==5;ETT_NUM==6;ETT_NUM==7;ETT_NUM==8 -> 
                                    {redirect, Session, Utck_nok};
                                4 -> 
                                    {redirect, Session, Utck_used};
                                _ ->
				    
				    case svc_util_of:is_commercially_launched(Session, recharge_sl_cmo) of
					true ->
					    case svc_recharge:get_ttk(Session, c_tck, Answer_tck) of
						?TTK_RECH_SPECIAL_SL_10E -> 
						    slog:event(trace, ?MODULE, ticket_rech_sl_10E),
						    {redirect,Session,Uspecial10E};
						?TTK_RECH_SPECIAL_SL_20E -> 
						    slog:event(trace, ?MODULE, ticket_rech_sl_20E),
						    {redirect,Session,Uspecial20E};
						?TTK_RECH_SPECIAL_SL_30E -> 
						    slog:event(trace, ?MODULE, ticket_rech_sl_30E),
						    {redirect,Session,Uspecial30E};
						Else ->
						    Default_Choice = 0,
						    Session2 =	variable:update_value(Session, {recharge,"choice"}, Default_Choice),
						    {redirect,Session,Unormal}
					    end;
					_ ->
					    Default_Choice = 0,
					    Session2 =  variable:update_value(Session, {recharge,"choice"}, Default_Choice),
					    {redirect,Session,Unormal}
				    end
			    end;
			_  ->
			    {redirect, Session, Unok}
		    end;
	       true ->
		    {redirect, Session, Unok}
	    end;
	{'EXIT', Error} ->
	    slog:event(failure, ?MODULE, sdp_c_tck, {Error, Msisdn}),
	    {redirect, Session, Unok};
	Else ->
	    slog:event(failure, ?MODULE, sdp_c_tck, {Else, Msisdn}),
	    {redirect, Session, Unok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type refill_request(session(),Subscription::string(), Choice::enum
%%                      Uok::string(),
%%                      Unok::string()) ->
%%                      erlpage_result(). 
%%%% Send request to refill by Mobicarte.
%%%% Redirect to next page depending on refill result.

refill_request(plugin_info, Subscription, Choice,
	       Uok, Unok ) ->
    (#plugin_info
     {help =
      "This plugin command redirects to the corresponding page depending on"
      " whether refill was successful or not.",
      type = command,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
        "This parameter specifies the subscription."},
       {choice, {oma_type, {defval, default, {enum, [1,2,3,4,5]}}},
	"This parameter specifies the client's choice."},
       {uok, {link,[]},
	"This parameter specifies the next page when refill succeeded."},
       {unok, {link,[]},
	"This parameter specifies the next page when refill did not succeed,"
	" other error."}
      ]});

refill_request(abs, _, _, Uok, Unok) ->
    [{redirect, abs, Uok},
     {redirect, abs, Unok}];

refill_request(#session{prof=Profile}=Session, Subscription, Choice,
	       Uok, Unok) ->
    Msisdn = Profile#profile.msisdn,
    Code = variable:get_value(Session, {recharge,"code"}),
    Default_choice = 0,
    case svc_recharge:send_recharge_request(Session, {cmo,Msisdn}, Code, 
                               pbutil:unixtime(),Default_choice) of
	{ok, Session_new, Infos} ->
	    {redirect, Session_new, Uok};
	{error, Status} ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_5,Status,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Status),
	    {redirect, New_Session, Unok};
	Error ->
	    slog:event(warning, ?MODULE, recharge_request,
                       [refill_request_5,Error,Msisdn]),
	    New_Session = variable:update_value(Session,{recharge,"tr_error"},Error),
	    {redirect, New_Session, Unok}
    end.

%%payment_cb/9
payment_cb(plugin_info, Choice, Urefill_ok, Urefill_nok_banque_40, Urefill_nok_banque_14, 
	   Urefill_nok_cb,Urefill_nok_technique, Urefill_nok_fonctionnelle, Urefill_nok) ->
    (#plugin_info
     {help =
      "This plugin command sends the payment request when payment is done"
      " by CB, and redirects to the one of the pages:\n"
      " urefill_ok if payment was successfully done,"
      " upb_cb if a problem occured, and"
      " urefused if payment was refused.",
      type = command,
      license = [],
      args =
      [
       {choice, {oma_type, {defval, default, {enum, [0,183,184,185]}}},
	"This parameter specifies the client's choice."},
       {urefill_ok, {link,[]},
 	"This parameter specifies the next page when payment was successful."},
       {urefill_nok_banque_40, {link,[]},
 	"This parameter specifies the next page when payment was not successful."},
       {urefill_nok_banque_14, {link,[]},
 	"This parameter specifies the next page when payment was not successful."},
       {urefill_nok_cb, {link,[]},
 	"This parameter specifies the next page when payment was not successful."},
       {urefill_nok_technique, {link,[]},
 	"This parameter specifies the next page when payment was not successful."},
       {urefill_nok_fonctionnelle, {link,[]},
 	"This parameter specifies the next page when payment was not successful."},
       {urefill_nok, {link,[]},
 	"This parameter specifies the next page when payment was not successful."}
      ]});

payment_cb(abs, _, Urefill_ok, Urefill_nok_banque_40, Urefill_nok_banque_14,
           Urefill_nok_cb,Urefill_nok_technique, Urefill_nok_fonctionnelle, Urefill_nok) ->
    [{redirect, abs, Urefill_ok},
     {redirect, abs, Urefill_nok_banque_40},
     {redirect, abs, Urefill_nok_banque_14},
     {redirect, abs, Urefill_nok_cb},
     {redirect, abs, Urefill_nok_technique},
     {redirect, abs, Urefill_nok_fonctionnelle},
     {redirect, abs, Urefill_nok}];

payment_cb(#session{prof=Profile}=Session, Choice, Urefill_ok, Urefill_nok_banque_40, Urefill_nok_banque_14,
           Urefill_nok_cb,Urefill_nok_technique, Urefill_nok_fonctionnelle, Urefill_nok) ->
    Rech_CB=cast(Session),
    GetStr = fun(X) -> 
                case X of
                    undefined -> 
                        "";
                    _ -> X
                end
	    end,
    NumCarte = GetStr(Rech_CB#recharge_cb_cmo.no_carte_cb),
    Court = GetStr(Rech_CB#recharge_cb_cmo.code_court),
    FinVal = GetStr(Rech_CB#recharge_cb_cmo.date_valid_cb),
    Cvx2 = GetStr(Rech_CB#recharge_cb_cmo.cvx2),
	Amount = trunc(currency:round_value(Rech_CB#recharge_cb_cmo.montant)),
    case svc_subscr_asmetier:do_recharge_cb(Session, cmo,
                                            Choice, NumCarte, Court, FinVal, Cvx2, Amount) of 
        {ok, Resp} -> 
            Session1 = svc_util_of:remove_from_sachem_available(Session,"csl_doscp"),
            {_, Session2} = svc_util_of:reinit_prepaid(Session1),
	    prisme_dump:prisme_count_v1(Session2,"PRECCB"),
            {redirect, Session2, Urefill_ok};
        {nok_banque_40, Error} -> 
            {redirect, Session, Urefill_nok_banque_40};
        {nok_banque_14, Error} -> 
            {redirect, Session, Urefill_nok_banque_14};
        {nok_cb, Error} -> 
            {redirect, Session, Urefill_nok_cb};
        {nok_technique, Error} -> 
            {redirect, Session, Urefill_nok_technique};
	{nok_fonctionnelle, Error} -> 
            {redirect, Session, Urefill_nok_fonctionnelle};
 	Else ->
            {redirect, Session, Urefill_nok}
    end.

%%payment_debit/3
payment_debit(plugin_info, Choice, Urefill_ok) ->
    (#plugin_info
     {help =
      "This plugin command sends the payment request when payment is done"
      " by bank account debit, and redirects to the one of the pages:\n"
      " urefill_ok if payment was successfully done,"
      " upb_cb if a problem occured, and"
      " urefused if payment was refused.",
      type = command,
      license = [],
      args =
      [
       {choice, {oma_type, {defval, default, {enum, [1,2,3]}}},
	"This parameter specifies the client's choice."},
       {urefill_ok, {link,[]},
 	"This parameter specifies the next page when payment was successful."}
      ]});

payment_debit(abs, _, Urefill_ok) ->
    [{redirect, abs, Urefill_ok}];

payment_debit(Session, Choice, Urefill_ok) ->
    New_session=update_recharge_cb(Session,[{trc_num,Choice}]),
    case do_payment(New_session,?pay_version,?sub) of
	{ok, Session1}->
	    {redirect, Session1, Urefill_ok};
	{statut,286} ->
	    {redirect, Session, "errors.xml#error_opt"};
	{statut,300} ->
	    {redirect, Session, "errors.xml#not_registred"};
	{statut,303} ->
	    {redirect, Session, "errors.xml#pb_cb"};
	{statut,304} ->
	     {redirect,Session, "errors.xml#not_authorized"};
	{statut,314} ->
	    {redirect, Session, "errors.xml#payment_refused"};
	{status,377} ->
            {redirect, Session, "errors.xml#error_377"};
	Else ->
 	    slog:event(failure, ?MODULE, cbhttp_unexpected_pay_status, Else),
	    {redirect, Session, "errors.xml#pb_tech_cb"}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type text_sl_7E(session(),Subscription::string(), Type::enum
%%                     erlpage_result(). 
%%%% Display the right textSend payment request.

text_sl_7E(plugin_info, Subscription, Type)->
    (#plugin_info
     {help =
      "This plugin display the correct message for le limited refill 7E.",
      type = function,
      license = [],
      args =
      [
       {subscription, {oma_type, {enum, [cmo]}},
	"This parameter specifies the subscription."},
       {choice, {oma_type, {defval, default, {enum, [confirmation,validation,information]}}},
	"This parameter specifies text to display."}
      ]});

text_sl_7E(abs, _, Type)->
    Text = Type ++ " pour la recharge Serie limite 7E",
    [{pcdata, Text}];

text_sl_7E(Session, _Subscription, Type)->
    Text = case svc_spider:read_field(offerPOrSUid, Session) of
	       "ZAP" ->
		   text_sl_7E(zap,Type);
	       "M6" ->
		   text_sl_7E(m6,Type);
	       _->
		   text_sl_7E(cmo,Type)
	   end,
    [{pcdata, Text}].

text_sl_7E(zap,"confirmation")->
    "Vous souhaitez recharger votre compte de 7E et profiter d'une semaine de surf illimite sur le portail Zap zone ?";
text_sl_7E(zap,"validation")->
    "Surfez en illimite sur le portail Zap zone jusqu'au ";
text_sl_7E(zap,"information") ->
    "Contenus payants non compris dans l'offre. Services accessibles sur reseaux et depuis terminal compatible. Details de l'offre et conditions sur orange.fr";
text_sl_7E(m6,"confirmation")->
    "Vous souhaitez recharger 7E de credit valable 7j et beneficiez d'un acces illimite au portail Inside M6 mobile pendant 7j.";
text_sl_7E(m6,"validation")->
    "Surfez en illimite sur le portail Inside M6 mobile jusqu'au ";
text_sl_7E(m6,"information") ->
"Contenus payants non compris dans l'offre. Services accessibles sur reseaux et depuis terminal compatible. Details de l'offre et conditions sur orange.fr";
text_sl_7E(cmo,"confirmation")->
    "Vous souhaitez recharger 7E de credit valable 7j et beneficiez d'1h vers fixes offerte valable 7 jrs";
text_sl_7E(cmo,"validation")->
    "Profitez de votre heure offerte vers les fixes avant le ";
text_sl_7E(cmo,"information") ->
    "Credit de 7E et 1h de voix vers fixes offerte valable 7 jours en France metropolitaine. Details de l'offre et conditions sur orange.fr".


slog_info(failure,?MODULE, cbhttp_rcod_error)->
    #slog_info{descr="Error in the response of cbhttp to the rcod request",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(failure,?MODULE, cbhttp_info_error)->
    #slog_info{descr="Error in the response of cbhttp to the info request",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(failure,?MODULE, cbhttp_dmcc_error)->
    #slog_info{descr="Error in the response of cbhttp to the short code "
	       "validity request",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(failure,?MODULE, cbhttp_mcod_error)->
    #slog_info{descr="Error in the response of cbhttp to the mcod request",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(failure,?MODULE, cbhttp_vcod_error)->
    #slog_info{descr="Error in the response of cbhttp to the vcod request",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(failure,?MODULE, cbhttp_unexpected_pay_status)->
    #slog_info{descr="Error in the response of cbhttp to the pay request"
	       "Unexpected returned status",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(failure,?MODULE, cbhttp_pay)->
    #slog_info{descr="Error in the response of cbhttp to the pay request",
	       operational="Check the technical architecture to decode"
	       "the meaning of the error\n"};
slog_info(warning,?MODULE, bad_response_from_sdp)->
    #slog_info{descr="Error in the response of Sachem",
	       operational="Check the technical architecture of Sachem "
	       "to decode the meaning of the error\n"}.

check_recharge_amount(plugin_info, URL_ok, URL_nok) ->    
      (#plugin_info
         {help =
         "This plugin function inserts the value of the day of the week"
         " of the current session into a page.\n",
         type = command,
         args =
         [
         {url_ok, {link,[]},
         "This parameter specifies the next page"},
         {url_nok, {link,[]},
         "This parameter specifies the next page when cumulated recharge amount exceed ceiling"}
         ]});
check_recharge_amount(abs, URL_ok, URL_nok) ->
       [{redirect, abs, URL_ok},
       {redirect, abs, URL_nok}];
check_recharge_amount(Session, URL_ok, URL_nok) ->
        %{redirect,Session, URL_ok}.
        info(Session,cb,URL_ok,URL_nok).


info(Session,Type,URL_ok,URL_nok)->    
    State = svc_util_of:get_user_state(Session),
    MSISDN=int_to_nat((Session#session.prof)#profile.msisdn),
    case cbhttp:info(MSISDN,?info_version,?sub) of
         {ok, [_,MSISDN,_,EPR_NUM,ESC_NUM,DOS_CUMUL_REC,DATEDER,
               UNT_NUM,PLAFOND_E,SOLDE_E,VALID24,NB_CPT,BONUS,MOBI_OPT,
               DOS_DATE_DER_REC,DOS_MONTANT_REC]}->
             %% MAJ solde compte princ SOLDE_E
             %% MAJ Bonus ???
             PLF_E=currency:sum(euro,PLAFOND_E/1000),
             MONTANT_MOIS=currency:sum(euro,DOS_CUMUL_REC/1000),
 	    case currency:is_infeq(MONTANT_MOIS,PLF_E) of
 		true->               
 		    {redirect,Session,URL_ok};
 		_ ->
 		    {redirect,Session,URL_nok}
 	    end;
       Else->
	   svc_recharge_cb_cmo:error_return(Session,Else,info,Type)
    end.
