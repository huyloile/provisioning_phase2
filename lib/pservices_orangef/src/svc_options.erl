-module(svc_options).
-compile(export_all).

%% XML API
-export([print_price_in_min/2,
	 print_balance/2,
	 print_balance/3,
	 print_balance_min/2,
	 print_end_credit/2,
	 print_end_credit/3,
	 print_account_dlv/3,
	 print_malin/1,
	 print_numero_sms_illimite/1,
	 print_numero_st_valentin/1,
	 print_numero_prefere/1,
	 print_msisdn_kdo/1,
	 print_opt_date_souscr/1,
	 print_date_end_opt/2,
	 print_option_price/2,
	 print_option_price/3,
	 print_commercial_start_date/3,
	 print_commercial_end_date/3,
	 print_commercial_name/2,
	 print_active_offer/4,
	 number_validity_end/1]).

-export([do_check_topnumlist/2,
	 debit_account/2]).

%% API
-export([opt_to_godet/2,
	 ptf_num/2,
	 tcp_num/2,
	 top_num/2,
	 dlv_opt/2,
	 mnt_initial/2]).

-export([check_topnumlist/1,
	 activ_options/1,
	 is_option_activated/2,
	 check_option_activated_from_list/2,
	 state/2,
	 is_any_option_activated/2]).

-export([do_opt_cpt_request/3,
	 do_nopt_cpt_request/4,
         get_modify_action/2]).

-export([redirect_update_option/7]).

-export([today_plus_datetime/1,
	 today_plus_datetime_time/1]).

-export([enough_credit/2,
	 enough_credit/3,
	 credit_bons_plans_ac/2]).

-export([export_options/0]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

-define(dbg(FMT,ARG),
	true%%io:format(?MODULE_STRING" traces: "++FMT,ARG)
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO PRINT INFORMATION IN XML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_balance(session(),Opt::string()) ->
%%                     erlinclude_result().
%%%% Print account balance for option

print_balance(abs,Opt) ->
    svc_compte:print_solde(abs,opt_to_godet(Opt,mobi))++
	svc_compte:print_solde(abs,opt_to_godet(Opt,cmo));
print_balance(#session{}=S,Opt) ->
    Subscr = svc_util_of:get_souscription(S),
    svc_compte:print_solde(S,opt_to_godet(Opt,Subscr)).

%% +type print_balance(session(),Opt::string(),
%%                     Unit::string()) ->
%%                     erlinclude_result().
%%%% Print account balance for option in given unit

print_balance(abs,Opt,Arg) ->
    svc_compte:print_solde(abs,opt_to_godet(Opt,mobi),Arg)++
	svc_compte:print_solde(abs,opt_to_godet(Opt,cmo),Arg);
print_balance(#session{}=S,Opt,Arg) ->
    Subscr = svc_util_of:get_souscription(S),
    svc_compte:print_solde(S,opt_to_godet(Opt,Subscr),Arg).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_balance_min(session(),Opt::string()) ->
%%                         erlinclude_result().
%%%% Print balance for option in minutes

print_balance_min(abs,Opt) ->
    svc_compte:print_solde_min(abs,opt_to_godet(Opt,mobi))++
	svc_compte:print_solde_min(abs,opt_to_godet(Opt,cmo));
print_balance_min(#session{}=S,Opt) ->
    Subscr = svc_util_of:get_souscription(S),
    svc_compte:print_solde_min(S,opt_to_godet(Opt,Subscr)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_end_credit(session(),Opt::string()) ->
%%                        erlinclude_result().
%%%% Print credit end date for option.
%%%% Either DLV (end of validity date) or RNV (renewal date).

print_end_credit(abs,Opt) ->
    [{pcdata,"DD/MM/YY"}];
print_end_credit(#session{}=S,Opt) ->
    Subscr = svc_util_of:get_souscription(S),
    svc_compte:print_fin_credit(S,opt_to_godet(Opt,Subscr)).

%% +type print_end_credit(session(),Opt::string(),
%%                        Type::string()) ->
%%                        erlinclude_result().
%%%% Print credit DLV (end of validity date) or RNV (renewal date) for option.

print_end_credit(abs,Opt,Type) ->
    [{pcdata,"DD/MM/YY"}];
print_end_credit(#session{}=S,Opt,Type) ->
    Subscr = svc_util_of:get_souscription(S),
    svc_compte:print_fin_credit(S,opt_to_godet(Opt,Subscr),Type).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_account_dlv(session(),Cpte::string(),Format::string())-> 
%%                         erlinclude_result().
%%%% Print credit end date.

print_account_dlv(abs,Cpte,Format)->
    [{pcdata,"DD/MM/YYYY"}];

print_account_dlv(Session,Cpte,Format)
  when Cpte=="forf_carrefour_z1";
       Cpte=="forf_carrefour_z2";
       Cpte=="forf_carrefour_z3" ->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
	    end_credit(DLV,RNV_NUM,Format);
 	E->   
	    svc_compte:print_fin_credit_default(Session, 
						"cpte_princ", Format)
    end;

print_account_dlv(Session,Cpte,Format)->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
	    end_credit(DLV,RNV_NUM,Format);
 	E->
 	    slog:event(internal,?MODULE,print_account_dlv,E),
 	    [{pcdata, "inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type number_validity_end(session()) ->
%%                           erlinclude_result().
%%%% Returns the end date of phone number validity

number_validity_end(abs) ->
    [ {pcdata, "31/12/99"} ];

number_validity_end(#session{}=Session) ->
    State = svc_util_of:get_user_state(Session),
    DLV=State#sdp_user_state.dlv,
    case svc_compte:etat_cpte(State,cpte_princ) of
	?CETAT_AC ->
	    %% The phone number is valid until the validity
	    %% end date (DLV) + a grace period is added
	    Fin_valid = DLV + get_env(periode_de_grace)*24*3600,
	    {{Y,Mo,D},{H,Mi,S}} = 
		calendar:now_to_datetime({Fin_valid div 1000000,
					  Fin_valid rem 1000000,0}),
	    Date=pbutil:sprintf("%02d/%02d/%02d", [D,Mo,Y rem 100]),
	    [{pcdata, lists:flatten(Date)}];
	_ ->
	    %% No grace period added
	    end_credit(DLV,0,"dmy") 
    end;

number_validity_end(_) ->
    [{pcdata, "**inconnu**"}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_date_end_opt(session(),Opt::string())->
%%                          erlinclude_result().
%%%% Print option validity end date during subscription.

print_date_end_opt(abs,_)->
    [{pcdata,"JJ/MM"}];
print_date_end_opt(Session,Opt)->
    Subscr = svc_util_of:get_souscription(Session),
    Date = dlv_opt(list_to_atom(Opt),Subscr),
    [{pcdata, Date}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_price_in_min(session(),Option::string())->
%%                          [{pcdata,string()}].
%%%% Print option price in minutes.
%%%% Subscr: "mobi" / "cmo".

print_price_in_min(abs,Option) ->
    [{pcdata,"XX min"}];
print_price_in_min(Session,Option) ->
    State = svc_util_of:get_user_state(Session),
    Opt = list_to_atom(Option),
    Subscr = svc_util_of:get_souscription(Session),
    DCL_NUM = State#sdp_user_state.declinaison,
    Ratio = svc_compte:ratio_mnesia(DCL_NUM,
				    tcp_num(Opt,Subscr),
				    ptf_num(Opt,Subscr),
				    min), %% EUR/min
    P= svc_util_of:subscription_price(Session, Opt),
    Txt = lists:flatten(io_lib:format("~p min",[trunc(P/(Ratio*1000))])),
    [{pcdata,Txt}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_option_price(session(),Opt::string())->
%%                          [{pcdata,string()}].
%%%% Print price, unit displayed is "E".

print_option_price(abs,_) ->
    [{pcdata,"XE"}];
print_option_price(Session,Opt) ->
    print_option_price(Session,Opt,"E").

%% +type print_option_price(session(),Opt::string(),Txt::string())->
%%                          [{pcdata,string()}].
%%%% Print price, unit displayed is defined by Txt.

print_option_price(abs,_,Txt) ->
    [{pcdata,"X"++Txt}];
print_option_price(Session,Opt,Txt) ->
    State = svc_util_of:get_user_state(Session),
    P = svc_util_of:subscription_price(Session, list_to_atom(Opt),without_promo),
    Peuros = P/1000,
    IoLibF = case (trunc(Peuros)*10)==trunc(Peuros*10) of
		 true  -> io_lib:format("~w"++Txt, [trunc(Peuros)]);
		 false -> io_lib:format("~.1f"++Txt, [Peuros])
	     end,
    [{pcdata,lists:flatten(IoLibF)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_malin(session())-> [{pcdata,string()}].
%%%% Print field malin in sdp_user_state.

print_malin(abs)->
    [{pcdata,"123456789"}];
print_malin(Session) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata,State#sdp_user_state.malin}].

%% +type print_numero_sms_illimite(session())-> [{pcdata,string()}].
%%%% Print field  in sdp_user_state.

print_numero_sms_illimite(abs)->
    [{pcdata,"06XXXXXXXX"}];
print_numero_sms_illimite(Session) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata,State#sdp_user_state.numero_sms_illimite}].

%% +type print_numero_sms_illimite(session())-> [{pcdata,string()}].
%%%% Print field  in sdp_user_state.

print_numero_st_valentin(abs)->
    [{pcdata,"06XXXXXXXX"}];
print_numero_st_valentin(Session) ->
    State = svc_util_of:get_user_state(Session),
    [{pcdata,State#sdp_user_state.numero_st_valentin}].

%% +type print_numero_sms_illimite(session())-> [{pcdata,string()}].
%%%% Print field  in sdp_user_state.

print_numero_prefere(abs)->    
    [{pcdata,"06XXXXXXXX"}];
print_numero_prefere(Session) ->
    State = svc_util_of:get_user_state(Session),
    Numpref = State#sdp_user_state.numero_prefere,
    [{pcdata, Numpref}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_msisdn_kdo(session())->
%%                             [{pcdata,string()}].
%%%% Print field numero_kdo_illimite in sdp_user_state.

print_msisdn_kdo(abs)->
    [{pcdata,"0612345678"}];
print_msisdn_kdo(#session{prof=Prof}=Session) ->
    State = svc_util_of:get_user_state(Session),
    Msisdn=Prof#profile.msisdn,
    No_KDO = case State#sdp_user_state.numero_kdo_illimite of
		 [D1,D2,D3,D4,D5,D6,D7,D8,D9,D10] ->
		     [D1,D2]++" "++[D3,D4]++" "++[D5,D6]++
			 " "++[D7,D8]++" "++[D9,D10];
		 Other ->
		     slog:event(failure,?MODULE,numero_kdo_illimite,Msisdn),
		     ""
	     end,
    [{pcdata, No_KDO}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_opt_date_souscr(session())->
%%                             [{pcdata,string()}].
%%%% Print field c_op_opt_date_souscr in sdp_user_state.

print_opt_date_souscr(abs)->
    [{pcdata,"0612345678"}];
print_opt_date_souscr(#session{prof=Prof}=Session) ->
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_commercial_start_date(session(),Option::string(),
%%                                   Format::string()) ->
%%                                   [{pcdata,string()}].
%%%% Displays the start date defined by the configuration parameter
%%%% commercial_date_cmo or commercial_date.

print_commercial_start_date(abs,Option,Format) ->
    [{pcdata, "XX/YY/WW"}];
print_commercial_start_date(Session,Option,Format) ->
    Opt=list_to_atom(Option),
    CDate = case svc_util_of:get_souscription(Session) of
		postpaid ->
		    lists:keysearch(Opt,1,get_env(commercial_date_postpaid));
		cmo -> 
		    lists:keysearch(Opt,1,get_env(commercial_date_cmo));
		_ ->
		    lists:keysearch(Opt,1,get_env(commercial_date))
	    end,
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
%%%% commercial_date_cmo or commercial_date.

print_commercial_end_date(abs,Option,Format) ->
    [{pcdata, "XX/YY/WW"}];
print_commercial_end_date(Session,Option,Format) ->
    Opt=list_to_atom(Option),
    CDate = case svc_util_of:get_souscription(Session) of
		postpaid ->
		    lists:keysearch(Opt,1,get_env(commercial_date_postpaid));

		cmo -> 
		    lists:keysearch(Opt,1,get_env(commercial_date_cmo));
		_ ->
		    lists:keysearch(Opt,1,get_env(commercial_date))
	    end,
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

%% +type print_commercial_name(session(),Option::string()) ->
%%                             [{pcdata,string()}].
%%%% Displays the commercial name of the option defined by the configuration
%%%% parameter opt_commercial_name.

print_commercial_name(abs,Option) ->
    [{pcdata, "option"}];
print_commercial_name(Session,Option) ->
    Opt=list_to_atom(Option),
    Name = case svc_util_of:get_souscription(Session) of
	       mobi -> 
		   lists:keysearch(Opt,1,get_env(opt_commercial_name_mobi));
	       _ ->
		   lists:keysearch(Opt,1,get_env(opt_commercial_name_cmo))
	   end,
    case Name of
	{value,{Opt, CommName}} ->
	    [{pcdata, CommName}];
	_ ->
	    [{pcdata, ""}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_active_offer(session(),Option::string(),
%%                        PCD_URLs::string(),BR::string())-> 
%%                        hlink().
%%%% Print link to the option if the option is commercially launched.

print_active_offer(abs,_,PCD_URLs,BR) ->
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);

print_active_offer(Session,Option,PCD_URLs,BR) ->
    Opt=list_to_atom(Option),
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    case svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    [#hlink{href=URL,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);
	_ ->
	    []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO HANDLE ACTIVE OPTIONS VIA TOP_NUM LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_check_topnumlist(session(),URL::string())->
%%                           erlpage_result().
%%%% Requests the list of active options for the user and 
%%%% stores it in sdp_user_state#topNumList.

do_check_topnumlist(abs,URL)->
    [{redirect,abs,URL}];
do_check_topnumlist(Session,URL)->
    {Session1,State_} = check_topnumlist(Session),
    {redirect,Session1,URL}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO HANDLE ACCOUNT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type debit_account(session(),Opt::string()) ->
%%                     [{pcdata,string()}].
%%%% Displays the account to debit.

debit_account(abs,Opt) ->
    [{pcdata," principal."}];
debit_account(Session,Opt) 
  when Opt=="opt_numprefp" ->
    Option = list_to_atom(Opt),
    State = svc_util_of:get_user_state(Session),
    PrixSubscr = svc_util_of:subscription_price(Session, Option),
    case {(svc_compte:etat_cpte(State,cpte_bons_plans)==?CETAT_AC),
	  credit_bons_plans_ac(State,currency:sum(euro,PrixSubscr/1000))} of
	{true,true} -> 
	    [{pcdata,"bons plans"}];
	{_,_} ->
	    [{pcdata,"principal"}]
    end;
debit_account(Session,Option) ->
    Opt = list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    DCL = State#sdp_user_state.declinaison,
    Subscr = svc_util_of:get_souscription(Session),
    PrixSubscr = svc_util_of:subscription_price(Session, Opt),

    if ((DCL==?RC_LENS_mobile) or (DCL==?ASSE_mobile)
        or (DCL==?OL_mobile) or (DCL==?OM_mobile)
        or (DCL==?PSG_mobile) or (DCL==?BORDEAUX_mobile)
        or (DCL==?CLUB_FOOT))->
	    [{pcdata,""}];

       true -> 
	    case {(svc_compte:etat_cpte(State,cpte_bons_plans)==?CETAT_AC),
		  credit_bons_plans_ac(State,{currency:sum(euro,PrixSubscr/1000),Opt})} of

		{true,true} -> 
		    [{pcdata,"bons plans"}];

		{_,_} ->

		    case Subscr of
			mobi ->  [{pcdata,"principal"}];

			cmo  ->  [{pcdata,"mobile"}]
		    end
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API INTERFACE - EXPORT FUNCTIONS USED BY OTHER MODULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO CHECK CREDIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type end_credit(DLV::integer(),RNV::integer() | atom(),
%%                  Format::atom())->
%%                  [{pcdata,string()}].
%%%% Define credit end date.
%%%% Format is the atom: dm (DDMM) or dmy (DDMMYY).

end_credit(DLV,RNV,Format) when RNV==0;RNV==undefined->
    {{Y,Mo,D},{H,Mi,S}} = 
	calendar:now_to_local_time({DLV div 1000000, 
				    DLV rem 1000000,0}),
    Date = 
	case list_to_atom(Format) of
	    dm->pbutil:sprintf("%02d/%02d", [D,Mo]);
	    dmy->pbutil:sprintf("%02d/%02d/%02d", [D,Mo,Y rem 100])
	end,
    [{pcdata, lists:flatten(Date)}];   

end_credit(_,RNV_NUM,Format) when list(Format)->
    [{pcdata, lists:flatten(svc_util_of:rnv_to_date(RNV_NUM,
						   list_to_atom(Format)))}];

end_credit(DLV,RNV_NUM,_)->
    slog:event(internal,?MODULE,end_credit,{DLV,RNV_NUM}),
    [{pcdata, "inconnu"}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type enough_credit(sdp_user_state(),
%%                     {currency:currency(),Opt::atom()} | currency:currency()) ->
%%                      bool().
%%%% Indicates whether there is enough credit on the account.

enough_credit(#sdp_user_state{}=S,{Curr,Opt}) ->
    case lists:keysearch(Opt,1,get_env(opt_promo_mobi)) of
	{value,_}->
	    currency:is_inf(Curr,svc_compte:solde_cpte(S,cpte_princ));
	_->
	    currency:is_infeq(Curr,svc_compte:solde_cpte(S,cpte_princ))
    end;
enough_credit(#sdp_user_state{}=S,Curr) ->
    currency:is_infeq(Curr,svc_compte:solde_cpte(S,cpte_princ)).

enough_credit(cmo,#sdp_user_state{}=S,Curr) ->
    true;
enough_credit(_,#sdp_user_state{}=S,Curr) ->
    enough_credit(S,Curr).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type credit_bons_plans_ac(sdp_user_state(),
%%                            {currency:currency(),Opt::string()}) ->
%%                            bool().
%%%% Checks whether enough credit and account BONS PLANS TCP_NUM=59.

credit_bons_plans_ac(#sdp_user_state{}=S,{Curr,Opt}) ->
    currency:is_infeq(Curr,svc_compte:solde_cpte(S,cpte_bons_plans));

credit_bons_plans_ac(#sdp_user_state{}=S,Curr) ->
    currency:is_infeq(Curr,svc_compte:solde_cpte(S,cpte_bons_plans)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TRANSLATION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type opt_to_godet(Option::term(),Subscription::atom()) ->
%%                    string().
%%%% Translates the option to the corresponding account (godet, compte).
%%%% Subscription is: mobi | cmo | virgin_prepaid | virgin_comptebloque

opt_to_godet(Option,Subscription)
  when list(Option) ->
    G_atom=opt_to_godet(list_to_atom(Option), Subscription),
    atom_to_list(G_atom);

opt_to_godet(Option,Subscription) ->
    svc_compte:search_cpte(tcp_num(Option,Subscription), Subscription).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type mnt_initial(Option::atom(),Subscription::atom()) ->
%%                   string().
%%%% Gives the MNT_INIT corresponding to the option and the subscription.

mnt_initial(Opt,Subscription) ->
    OPT_CPT_req = option_params(Opt, Subscription, subscribe),
    OPT_CPT_req#opt_cpt_request.mnt_initial.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO HANDLE ACTIVE OPTIONS VIA TOP_NUM LISTS AND FLAGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_topnumlist(session())->
%%                        sdp_user_state().
%%%% If TOP_NUM list not yet defined in sdp_user_state, request
%%%% information from Sachem.

check_topnumlist(Session)->
    State = svc_util_of:get_user_state(Session),
    UpdatedState=
        case State#sdp_user_state.topNumList of
            undefined -> 
                TopNumList = case activ_options(Session) of 
                                 {UpdatedSession,Activ_opts} ->
                                     Activ_opts;
                                 Error ->
                                     []
                             end,
                State#sdp_user_state{topNumList=TopNumList};
            _ -> 
                State
        end,
    {svc_util_of:update_user_state(Session,UpdatedState),UpdatedState}.

%% +type check_options(session())->
%%                        sdp_user_state().
%%%% If OPTIONS list not yet defined in sdp_user_state, request
%%%% information from Sachem.

check_options(#session{prof=Prof}=Session)->
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.options of
        undefined ->
            case svc_sachem:consult_account_options(Session) of
                {ok, {OkSession, Resp_params}} -> 
                    svc_util_of:get_user_state(OkSession);
                {nok, _} -> 
                    State
            end;
        _ -> State
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_activated(session(),Opt::atom()) ->
%%                           bool().
%%%% Function used to check whether the option is activated.
%%%% The TOP_NUM of the option is used to check this except for
%%%% option numprefp.

is_option_activated(Session, Opt)
  when Opt==opt_numprefp ->
    State = svc_util_of:get_user_state(Session),
    Is_Actif = (State#sdp_user_state.numero_prefere)#numero_prefere.numprefp,
    case Is_Actif of
	undefined -> false;
	_ -> Is_Actif
    end;

is_option_activated(Session, Opt) 
  when Opt==opt_tt_shuss;Opt==opt_pack_duo_journee ->
	check_any_option_activated_from_list(Session,[opt_pack_duo_journee,
                                                  opt_tt_shuss_sms,
						  opt_tt_shuss_voix_2]);
is_option_activated(Session, Opt) 
  when Opt==opt_zap_vacances ->
    check_any_option_activated_from_list(Session, [opt_school_zone_a, 
				      opt_school_zone_b, 
				      opt_school_zone_c]);

is_option_activated(Session, Opt) 
  when Opt==opt_pass_vacances ->
    is_option_activated(Session, opt_pass_vacances_moc);

is_option_activated(Session, Opt) 
  when Opt==opt_pass_vacances_v2;
       Opt==opt_pass_voyage_6E ->
	check_any_option_activated_from_list(Session,[opt_pass_voyage_6E,
						  opt_pass_vacances_v2_moc]);

is_option_activated(Session, Opt) 
  when Opt==opt_pass_voyage_9E ->
	check_any_option_activated_from_list(Session,[opt_pass_voyage_9E,
						  opt_pass_vacances_z2_moc]);

is_option_activated(Session, Opt)
when Opt==opt_ikdo ->
    check_any_option_activated_from_list(Session,[opt_illimite_kdo,
				     opt_ikdo_vx_sms,
				     opt_illimite_kdo_v2]);

is_option_activated(Session, Opt)
when Opt==opt_bonus_janus ->
    check_any_option_activated_from_list(Session,[opt_bonus_appels,
						  opt_bonus_sms,
						  opt_bonus_internet,
						  opt_bonus_appels_etranger]);

is_option_activated(Session, Opt) ->
    Subscr = svc_util_of:get_souscription(Session),
    is_option_activated(Session, Opt, Subscr).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type state(session(),Opt::atom()) ->
%%                           atom().
%%%% Function used is option activated to check whether the option is activated.
%%%% The TOP_NUM of the option is used to check this except for
%%%% option numprefp.

state(Session, Opt) ->
    Subscr = svc_util_of:get_souscription(Session),
    case Subscr of
	mobi ->
	    State = check_options(Session),
	    TOP_NUM = top_num(Opt, mobi),
	    case lists:keysearch(TOP_NUM, 1,State#sdp_user_state.options) of
		{value,{TOP_NUM,actived}}->
		    actived;
		{value,{TOP_NUM,suspend}}->
		    suspend;		
		false ->
		    not_actived
	    end;
	symacom ->
	    State = check_options(Session),
	    TOP_NUM = top_num(Opt, symacom),
	    case lists:keysearch(TOP_NUM, 1,State#sdp_user_state.options) of
		{value,{TOP_NUM,actived}}->
		    actived;
		{value,{TOP_NUM,suspend}}->
		    suspend;		
		false ->
		    not_actived
	    end;
	_ ->
	     slog:event(internal,?MODULE,subscription_not_supported,Subscr)    
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_any_option_activated(session(),Opts::[atom()]) ->
%%                           bool().
%%%% Function used to check whether any option is activated.
%%%% The TOP_NUM of the option is used to check this except for
%%%% option numprefp.
is_any_option_activated(Session,[])->
    false;
is_any_option_activated(Session,[Opt|Tail]) ->
    case is_option_activated(Session, Opt) of
	true ->
	    true;
	_ -> 
	    is_any_option_activated(Session,Tail)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_activated(session(),Opt::atom(),Subscr::atom()) ->
%%                           bool().
%%%% Function used to check whether the option is activated.

is_option_activated(Session, Opt, Subscr)
  when (((Subscr==virgin_prepaid) or (Subscr==virgin_comptebloque)) and

       ((Opt/=opt_sms_200) and (Opt/=opt_sms_ill)))->
    {Session_,State} = check_topnumlist(Session),
    case svc_compte:cpte(State,opt_to_godet(Opt,Subscr)) of
	#compte{etat=?CETAT_AC} ->
	    TOP_NUM=top_num(Opt,list_to_atom(svc_util_of:declinaison(State))),
	    lists:member(TOP_NUM, State#sdp_user_state.topNumList);
	_ -> false
    end;

is_option_activated(Session, Opt, Subscr) 
    when (((Subscr==tele2_comptebloque) or (Subscr==virgin_comptebloque) or (Subscr==bzh_cmo)) and
	 ((Opt==opt_sms_200) or (Opt==opt_sms_ill)))->
    {Session_,State} = check_topnumlist(Session),    
    %% State = svc_util_of:get_user_state(Session),
    TOP_NUM = top_num(Opt, list_to_atom(svc_util_of:declinaison(State))),
    lists:member(TOP_NUM, State#sdp_user_state.topNumList);

is_option_activated(Session, Opt, Subscr)
  when (Subscr==mobi) and (Opt==opt_cb_mobi) ->
    {Session_,State} = check_topnumlist(Session),
    TOP_NUM = top_num(Opt, list_to_atom(svc_util_of:declinaison(State))),
    lists:member(TOP_NUM, State#sdp_user_state.topNumList);

is_option_activated(Session, opt_illimite_kdo_v2, Subscr=mobi) ->
    is_option_activated(Session, opt_ikdo_voix, Subscr);

is_option_activated(Session, Opt, Subscr)
  when (Subscr==mobi) ->
    State = check_options(Session),
    TOP_NUM = top_num(Opt, list_to_atom(svc_util_of:declinaison(State))),
    case lists:keysearch(TOP_NUM, 1,State#sdp_user_state.options) of
	{value,{TOP_NUM,actived}}->
	    true;
	_ ->
	    false
    end;

is_option_activated(Session, Opt, Subscr) ->
    {Session_,State} = check_topnumlist(Session),
    TOP_NUM = top_num(Opt, list_to_atom(svc_util_of:declinaison(State))),
    lists:member(TOP_NUM, State#sdp_user_state.topNumList).

check_option_activated_from_list(Session,Opt) ->
    {Session_,State} = check_topnumlist(Session),
    Sub = svc_util_of:get_souscription(Session_),
    TOP_NUM = top_num(Opt,Sub),
    lists:member(TOP_NUM, State#sdp_user_state.topNumList).

check_any_option_activated_from_list(Session,[])-> 
    false;

check_any_option_activated_from_list(Session, [Opt|T])-> 
    case check_option_activated_from_list(Session,Opt) of
	false->
		check_any_option_activated_from_list(Session,T);
	_ ->
	    true
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type list_options_active(session(), Options:list())->
%%                        list().
%%%% Check active options.
list_active_options(Session, Options) ->
    list_active_options(Session, Options, []).

list_active_options(Session, [], Acc) ->
    Acc;
list_active_options(Session, [Option | Rest_of_options], Acc) ->
    case is_option_activated(Session,Option) of
	true ->
	    list_active_options(Session, Rest_of_options, [Option|Acc]);
	false ->
	    list_active_options(Session, Rest_of_options, Acc)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO HANDLE SUBSCRIPTION VIA OPT_CPT REQUEST TO SACHEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_opt_cpt_request(session(),Opt::atom(),
%%                          Action::atom())->
%%                          opt_cpt_request().
%%%% Initialize the OPT_CPT request according to the option.
%%%% Action: terminate, modify or subscribe

do_opt_cpt_request(#session{prof=Prof}=S,Opt, Action=subscribe)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqInit = option_params(Opt, Sub, subscribe),
    ReqCout = add_cout(S, Opt, ReqInit),
    ReqTypeAction = add_type_action(S, Opt, ReqCout, Action),
    ReqMntInit = add_mnt_initial(S, Opt, ReqTypeAction),
    Request = add_msisdn(State, subscribe, ReqMntInit,Opt),
    Result = case send_update_account_options(S, {Sub,Msisdn},subscribe,Request) of
		 {ok_operation_effectuee,Session_resp,""} -> 
		     prisme_dump:prisme_count(S,Opt, {subscribe, validation}, sachem),
		     {ok_operation_effectuee,Session_resp,""};
		 {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]} ->
		     prisme_dump:prisme_count(S,Opt, {subscribe, validation}, sachem),
		     {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]};
		 {error, Reason} ->
		     {error, Reason};
		 {OtherCPT2Respond, [TCP_NUM, CPP_SOLDE]} ->
		     {OtherCPT2Respond, ""};
		 Other -> 
		     slog:event(failure, ?MODULE, unknown_nopt, Other),
		     Other    
	     end,
    do_return_opt_cpt_request(S, Result);

do_opt_cpt_request(#session{prof=Prof}=S,Opt,Action)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqInit = option_params(Opt, Sub, Action),
    ReqCout = add_cout(S, Opt, ReqInit),
    ReqTypeAction = add_type_action(S, Opt, ReqCout, Action),
    ReqMntInit = add_mnt_initial(S, Opt, ReqTypeAction),
    Request = add_msisdn(State, Action, ReqMntInit,Opt),
    Result = send_update_account_options(S, {Sub,Msisdn},Action, Request),	    
    do_return_opt_cpt_request(S, Result).

do_return_opt_cpt_request(Session, Result)->		 
    case Result of
        {ok_operation_effectuee, Session_resp, Resp_params} ->			 
            {Session_resp,{ok_operation_effectuee,Resp_params}};
        _ ->    
            {Session,Result}
    end.

%%%% Temporary function to send request via
%%%% Either sachem X25 : opt_cpt req
%%%% or sachem Tuxedo  : update_account_options
send_update_account_options(#session{prof=Profile}=Session, 
                            {Sub,Msisdn}, Action, Request) ->
    slog:event(trace, ?MODULE, send_update_account_options, 
               Request),
    Msisdn = Profile#profile.msisdn,
            case svc_sachem:update_account_options(Session, Request) of
                {ok, {Session_resp, Resp}} -> 
                    slog:event(trace, ?MODULE, update_account_options,
                               {ok, Resp}),
                    %%CPP_SOLDE = proplists:get_value("CPP_SOLDE", Resp_params),
                    %%{ok_operation_effectuee, [[], CPP_SOLDE]};
                    {ok_operation_effectuee,Session_resp,""};
                {nok, {error, Reason}} 
                when Reason == "numero_invalid";
                     Reason == "solde_insuffisant";
                     Reason == "option_inexistante";
                     Reason == "option_deja_existante";
                     Reason == "operation_irrealisable";
                     Reason == "msisdn_inconnu";
                     Reason == "option_incompatible_dcl";
                     Reason == "option_incompatible_ptf";
                     Reason == "option_incompatible_opt";
                     Reason == "option_incompatible_sec";
                     Reason == "option_incompatible_solde";
                     Reason == "option_incompatible_date_activ";
                     Reason == "option_incompatible_date_rech";
                     Reason == "option_dependante_absente";
                     Reason == "reactivation_ko" ->
                    slog:event(service_ko, ?MODULE, update_account_options,
                               {Msisdn, Reason}),
                    {error, Reason};
                {nok, {error, Reason}} 
                when Reason == "une_option_souscrite" ->
                    slog:event(warning, ?MODULE, update_account_options,
                               {Msisdn, Reason}),
                    {error, Reason};
                {nok, {error, Reason}} 
                when Reason == "type_ACTION_incorrect" ->            
                    slog:event(warning, ?MODULE, update_account_options,
                               {Msisdn, Reason}),
                    {nok, {error, Reason}};
                {nok, {error, Reason}} 
                when Reason == "erreur_technique";
                     Reason == "other_error" -> 
                    slog:event(failure, ?MODULE, update_account_options,
                               {Msisdn, Reason, Request}),
                    {nok, {error, Reason}};
                Else ->
                    slog:event(failure, ?MODULE, update_account_options,
                               {Msisdn, Else, Request}),
                    {nok, Else}
    end.

do_nopt_cpt_request(#session{prof=Prof}=S,[Opt1|Opt],Action,Opt_params)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqInit = option_params(Opt1, Sub, Action),
    ReqCout = add_cout(S, Opt1, ReqInit),
    ReqTypeAction = add_type_action(S, Opt1, ReqCout, Action),
    ReqMntInit = add_mnt_initial(S, Opt1, ReqTypeAction),
    Request = add_msisdn(State, Action, ReqMntInit,Opt1),
    do_nopt_cpt_request(S,Opt,Action,[Request|Opt_params],Opt1).


do_nopt_cpt_request(#session{prof=Prof}=S,[],Action,Request,Option)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    Result = case send_NOPT_request(S, {Sub,Msisdn},Action,Request) of
		 {ok_operation_effectuee,Session_resp,""} -> 
		     prisme_dump:prisme_count(S,Option,{Action, validation}, sachem),
		     {ok_operation_effectuee,Session_resp,""};
		 {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]} ->
		     prisme_dump:prisme_count(S,Option,{Action, validation}, sachem),
		     {ok_operation_effectuee,Session_resp, [TCP_NUM, CPP_SOLDE]};
		 {OtherCPT2Respond, [TCP_NUM, CPP_SOLDE]} ->
		     {OtherCPT2Respond, ""};
		 {error, Reason} ->
		     {error, Reason};
		 Other -> 
		     Other    
	     end,
    do_return_opt_cpt_request(S, Result);

do_nopt_cpt_request(#session{prof=Prof}=S,[Opt1|Opt],Action,Opt_params,Option)->
    State = svc_util_of:get_user_state(S),
    Msisdn=Prof#profile.msisdn,
    Sub = svc_util_of:get_souscription(S),
    ReqInit = option_params(Opt1, Sub, Action),
    ReqCout = add_cout(S, Opt1, ReqInit),
    ReqTypeAction = add_type_action(S, Opt1, ReqCout, Action),
    ReqMntInit = add_mnt_initial(S, Opt1, ReqTypeAction),
    Request = add_msisdn(State, Action, ReqMntInit,Opt1),
    do_nopt_cpt_request(S,Opt,Action,[Request|Opt_params],Option).

send_NOPT_request(#session{prof=Prof}=Session, {Sub,Msisdn},Action,Request) ->
    slog:event(trace, ?MODULE, send_NOPT_request,Request),
    Msisdn = Prof#profile.msisdn,
    case svc_sachem:handle_options(Session, Request) of
	{ok, {Session_resp, Resp_params}} ->                  
	    TCP_NUM = proplists:get_value("TCP_NUM", Resp_params),
	    CPP_SOLDE = proplists:get_value("CPP_SOLDE", Resp_params),
	    {ok_operation_effectuee, Session_resp, [TCP_NUM, CPP_SOLDE]};
	{nok, {error, Reason}} 
	when Reason == "solde_insuffisant";
	     Reason == "option_inexistante";
	     Reason == "option_deja_existante";
	     Reason == "operation_irrealisable";
	     Reason == "msisdn_inconnu";
	     Reason == "option_incompatible_dcl";
	     Reason == "option_incompatible_ptf";
	     Reason == "option_incompatible_opt";
	     Reason == "option_incompatible_sec";
	     Reason == "option_incompatible_solde";
	     Reason == "option_incompatible_date_activ";
	     Reason == "option_incompatible_date_rech";
	     Reason == "option_dependante_absente";
	     Reason == "reactivation_ko" ->
	    slog:event(service_ko, ?MODULE, handle_options,
		       {Msisdn, Reason}),
	    {error, Reason};
	{nok, {error, Reason}} 
	when Reason == "type_ACTION_incorrect" ->            
	    slog:event(warning, ?MODULE, handle_options,
		       {Msisdn, Reason}),
	    {error, Reason};
	{nok, {error, Reason}} 
	when Reason == "erreur_technique";
	     Reason == "other_error" -> 
	    slog:event(failure, ?MODULE, handle_options,
		       {Msisdn, Reason, Request}),
	    {nok, {error, Reason}};
	Else ->
	    slog:event(failure, ?MODULE, handle_options,
		       {Msisdn, Else, Request}),
	    {nok, Else}
    end.
        
%% +type redirect_update_option(session(),Result::tuple(),
%%                          Uok::string(), UdejaAct::string(),
%%                          Uinsuff::string(), Uopt_bloquee::string(),
%%                          Uok::string()) ->
%%                          erlpage_result().
%%%% Redirect to page according to OPT_CPT answer
%%%% or MAJ_OP for Sachem via Tuxedo interface
redirect_update_option(Session, Result, Uok, UdejaAct, 
                       Uinsuff, Uopt_bloquee, Unok) ->
    redirect_update_option(Session, Result, Uok, UdejaAct, 
                           Uinsuff, Unok, Uopt_bloquee, Unok).

redirect_update_option(Session, Result, Uok, UdejaAct, 
                       Uinsuff, Uincompat, Uopt_bloquee, Unok) ->
    case Result of
    	{ok_operation_effectuee,_} ->
		%% reset user account information
	    {_,Session_reinit}= svc_util_of:reinit_compte(Session),
	    {redirect,Session_reinit,Uok};
	Error when Error == {nok_opt_deja_existante,""};
                   Error == {error, "option_deja_existante"};
                   Error == {error, "reactivation_ko"} ->
	    {redirect,Session,UdejaAct};
        Error when Error == {nok_solde_insuffisant,""};
                   Error == {error, "solde_insuffisant"} ->
	    {redirect,Session,Uinsuff};
        Error when Error == {nok_opt_incompatible,""};
                   Error == {error, "option_incompatible_opt"} ->
	    {redirect,Session,Uincompat};
        {opt_bloquee_101,_} ->
	    {redirect,Session,Uopt_bloquee};
        {error, "option_incompatible_sec"} ->
	    {redirect,Session,Uopt_bloquee};
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session, Unok}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type add_cout(session(),Opt::atom(),Req::opt_cpt_request()) ->
%%                opt_cpt_request().
%%%% Add subscription price to request from configuration parameter.

add_cout(S, Opt, Req) ->
    Subscr = svc_util_of:get_souscription(S),
    case svc_util_of:is_promotion(S,Subscr,Opt) of
	true ->
%% the old functionnality Cellcube force the option cost to 0.
%% Now the cost is defined by Sachem. The cost is "-"
	    Req;
	_ ->
	    case Req#opt_cpt_request.cout of
		from_conf_param -> 
		    Price = svc_util_of:subscription_price(S, Opt),
		    Req#opt_cpt_request{cout = integer_to_list(Price)};
		_ -> Req
	    end
    end.
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type add_type_action(session(),Opt::atom(),Req::opt_cpt_request()) ->
%%                       opt_cpt_request().
%%%% Add type_action to request depending on the option status.

add_type_action(S, Opt, Req) ->
    add_type_action(S, Opt, Req, "-").

%% +type add_type_action(session(),Opt::atom(),Req::opt_cpt_request(), Action::atom()) ->
%%                       opt_cpt_request().
%%%% Add type_action to request depending on the option status or on the Action.
add_type_action(S, Opt, Req, Action) ->
    case Req#opt_cpt_request.type_action of
	check_opt_status ->
	    TypeAction = 
 		case is_option_activated(S,Opt) of
 		    false -> "A";
 		    true  -> get_modify_action(S, Opt)
 		end,
	    Req#opt_cpt_request{type_action = TypeAction};
  	"-" ->
	    TypeAction = 
                case Action of
                    subscribe -> "A";
                    modify    -> get_modify_action(S, Opt);
                    terminate -> "S";
 		    _ -> slog:event(internal, ?MODULE, 
                                    unknown_add_type_action, Action),
 			 Action
 		end,
	    Req#opt_cpt_request{type_action = TypeAction};
	_ ->
            Req
    end.


%% +type get_modify_action(session(),Opt::string()) ->
%%                         "M"|"A"
%%%% Because of Sachem via Tuxedo limitations : June 2009
%%%% Sets the action to "Modify" only if it is a "numero prefere" option
%%%% Otherwise sets the action to "Add"
get_modify_action(Session, Opt) ->
    case lists:member(Opt, ?OPT_NUM_PREF) of
	true -> "M";
	_ -> "A"
    end.    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type add_mnt_initial(session(),Opt::atom(),Req::opt_cpt_request()) ->
%%                       opt_cpt_request().
%%%% Add mnt_initial to request.

add_mnt_initial(S, Opt, Req) ->
    case Req#opt_cpt_request.mnt_initial of
	from_conf_param ->
	    MntInit = svc_util_of:subscription_price(S, Opt),
	    Req#opt_cpt_request{mnt_initial=integer_to_list(MntInit)};
	_ -> Req
    end.
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type add_msisdn(sdp_user_state(),Action::atom(),Req::opt_cpt_request(),Opt::atom()) ->
%%                  opt_cpt_request().
%%%% Add msisdn1 to request.

add_msisdn(State, Action, Req,Opt=opt_sms_illimite) ->
    case Action of
	terminate ->
	    Req;
	_ ->
	    MSISDN1 = State#sdp_user_state.numero_sms_illimite,
	    Req#opt_cpt_request{msisdn1 = MSISDN1}
    end;
add_msisdn(State, Action, Req,Opt=opt_num_prefere) ->
    MSISDN1 = State#sdp_user_state.numero_prefere,
    Req#opt_cpt_request{msisdn1 = MSISDN1};

add_msisdn(State, Action, Req,Opt=opt_numpref_tele2) ->
    MSISDN1 = State#sdp_user_state.numero_prefere,
    Req#opt_cpt_request{msisdn1 = MSISDN1};
    
add_msisdn(State, Action, Req,Opt) ->
    case Action of
	modify ->
	    MSISDN1 = State#sdp_user_state.c_op_opt_date_souscr,
	    Req#opt_cpt_request{msisdn1 = MSISDN1};
	set ->
	    MSISDN1 = State#sdp_user_state.c_op_opt_date_souscr,
	    Req#opt_cpt_request{msisdn1 = MSISDN1};
	_ -> Req
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type today_plus_datetime(X::integer()) ->
%%                           {Year::integer(),Month::integer,Day::integer()}.
%%%% Add X days to current datetime and return the date.

today_plus_datetime(X) when integer(X)->
    DateTime = svc_util_of:local_time(),
    {Date,_} = svc_util_of:add_seconds_to_datetime(DateTime,X*86400),
    Date.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type today_plus_datetime_time(X::integer()) ->
%%                           {Year::integer(),Month::integer,Day::integer()}.
%%%% Add X days to current datetime and return the time.

today_plus_datetime_time(X) when integer(X)->
    DateTime = svc_util_of:local_time(),
    {_,Time} = svc_util_of:add_seconds_to_datetime(DateTime,X*86400),
    Time.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type activ_options(session())->
%%                     [integer()] | undefined | error.
%%%% Send request to Sachem server in order to get the list of active 
%%%% options.

activ_options(#session{prof=Prof}=Session)->
    MSISDN = Prof#profile.msisdn,
    Id = {svc_util_of:get_souscription(Session),MSISDN},
    case svc_util_of:get_options_list(Session, Id) of
	{options, TopNumList, UpdatedSession}->
	    {UpdatedSession, TopNumList}; %% return ok, list of TOP_NUMs for active options
	Error->
	    slog:event(failure,?MODULE,svi_c_op_ko,Error),
	    Error
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type next_monday_date() -> date().
%%%% Date defined to next monday.

next_monday_date() ->
    {Date,Time} = svc_util_of:local_time(),
    DayOWeek = calendar:day_of_the_week(Date),
    IsItSundayAfter23h = ( Time > {23,0,0} ) and (DayOWeek==7),
    DiffToNextMondaySecs =
        (case IsItSundayAfter23h of
             false -> 
                 (8 - DayOWeek)*86400;
             true  ->
                 (8 - DayOWeek + 7)*86400
         end),
    {NextMondayDate,_} =
        svc_util_of:add_seconds_to_datetime({Date,{12,0,0}},
                                            DiffToNextMondaySecs),
    NextMondayDate.

next_Saturday_date()->
    {Date, Time} = svc_util_of:local_time(),
    DayOfWeek = calendar:day_of_the_week(Date),
    if DayOfWeek == 6->
	    Date;
       DayOfWeek == 7 ->
	    {Date1, Time1} = svc_util_of:add_seconds_to_datetime({Date,Time}, -1*86400),
	    Date1;
       true->
	    {Date2, Time2} = svc_util_of:add_seconds_to_datetime({Date, Time}, (6-DayOfWeek)*86400),
	    Date2
    end.
next_Sunday_date()->
    SaturdayDate = next_Saturday_date(),
    {SundayDate, SundayTime} = svc_util_of:add_seconds_to_datetime({SaturdayDate,{0,0,0}},86400),
    SundayDate.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type format_date(date() | undefined) -> string().
%%%% Format date DD/MM/YYYY.

format_date({Y, M, D}) ->
    lists:flatten(pbutil:sprintf("%02d/%02d/%04d", [D,M,Y]));
format_date(undefined) ->
    "-".

%% +type format_date(date() | undefined) -> string().
%%%% Format date DD/MM/YY.
format_date_dmy({Y, M, D}) ->    
    lists:flatten(pbutil:sprintf("%02d/%02d/%02d", [D,M,Y rem 100]));
format_date_dmy(undefined) ->
    "-".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type format_date_dm(date() | undefined) -> string().
%%%% Format date DD/MM.

format_date_dm({_, M, D}) ->
    lists:flatten(pbutil:sprintf("%02d/%02d", [D,M]));
format_date_dm(undefined) ->
    "-".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UTILITIES USED IN THIS MODULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_env(atom()) -> term().
%%%% Get environmant variable.

get_env(ParamCfg) ->
    pbutil:get_env(pservices_orangef,ParamCfg).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UTILITY USED TO GET THE COMPLETE CONFIGURATION OF ALL THE OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
export_options()->
    Options_list = [opt1_virg_30j,
		    opt2_virg_30j,
		    opt3_virg_30j,
		    opt4_virg_30j,
		    opt1_tele2_cb_25sms,
		    opt1_tele2_cb_50sms,
		    opt1_tele2_cb_100sms,
		    opt_afterschool,
		    opt_appelprixunique,
		    opt_bp_10_mms,
		    opt_bonus_int,
		    opt_data_gprs,
		    opt_erech_jinf,
		    opt_erech_smsmms,
		    opt_europe,
		    opt_ikdo_vx_sms,
		    opt_illimite_kdo,
		    opt_jinf,
		    opt_maghreb,
		    opt_mms_mensu,
		    opt_musique,
		    opt_musique_mensu,
		    opt_numprefg,
		    opt_numprefp,
		    opt_numpref_tele2,
		    opt_sms_illimite,
		    opt_ow_10E_mobi,
		    opt_ow_3E_mobi,
		    opt_ow_6E_mobi,
		    opt_ow_deco,
		    opt_pack_noel_mms,
		    opt_pack_voeux_smsmms,
		    opt_pass_vacances,
		    opt_pass_vacances_moc,
		    opt_pass_vacances_mtc,
		    opt_pass_vacances_v2,
		    opt_pass_vacances_v2_moc,
		    opt_pass_vacances_v2_mtc,
		    opt_pass_vacances_v2_10_sms,
					opt_pass_voyage_9E,
		    opt_pass_vacances_z2,
                    opt_pass_vacances_z2_moc,
                    opt_pass_vacances_z2_mtc,
                    opt_pass_vacances_z2_10_sms,
		    opt_roaming,
		    opt_seminf,
		    opt_sinf,
		    opt_sms_hebdo,
		    opt_sms_mensu,
		    opt_sms_quoti,
		    opt_sms_surtaxe,
		    opt_sport,
		    opt_ssms,
		    opt_surf,
		    opt_surf_mensu,
		    opt_temps_plus,
		    opt_total_tv,
					opt_pack_duo_journee,
		    opt_tt_shuss,
		    opt_tt_shuss_sms,
		    opt_tt_shuss_voix,
		    opt_tt_shuss_voix_2,		    
		    opt_tv,
		    opt_vacances,
		    opt_voyage,
		    opt_weinf,
		    opt_we_sms,
		    opt_we_voix,
		    opt_tv_mensu,
		    opt_sport_mensu,
		    opt_total_tv_mensu,
		    opt_zap_quoti,
		    opt_s_app_ill,
		    opt_ssms_ill,
		    opt_jsms_ill,
		    opt_j_mm_ill,
		    opt_s_mm_ill,
		    opt_j_app_ill,
		    opt_j_tv_max_ill,
		    opt_s_tv_max_ill,
		    opt_sms_illimite_soir,
		    opt_bonus_multimedia,
		    opt_bby_sms_illimite,
		    opt_ssms_illimite,
		    opt_jsms_illimite,
		    opt_10mn_europe
		   ],

    Subscriptions_list = [mobi,
			  cmo,
			  postpaid,
			  dme,
			  omer,
			  bzh_gp,
			  bzh_cmo,
			  tele2_gp,
			  tele2_pp,
			  virgin_prepaid,
			  virgin_comptebloque,
			  tele2_compte_bloque,
			  carrefour_comptebloq,
			  virgin_postpaid,
			  ten_postpaid,
			  carrefour_prepaid,
			  monacell_prepaid],

    Actions_list = [subscribe, terminate, modify],

    List = [get_param(Opt,Subscription,Action) || Opt <- Options_list,
					    Subscription <- Subscriptions_list,
					    Action <- Actions_list],
    
    List2 = lists:filter(fun(X)->
				 case X of
				     undefined ->
					 false;
				     _ -> true
				 end
			 end,
			 List).

get_param(Opt,Subscription,Action) ->
    case option_params(Opt, Subscription, Action) of
	unknown_option_params ->
	    undefined;
	OPT_CPT_req ->
	    {{souscription,Subscription},
	     {top_num,OPT_CPT_req#opt_cpt_request.top_num},	  
	     {date_deb,OPT_CPT_req#opt_cpt_request.date_deb},
	     {heure_deb,OPT_CPT_req#opt_cpt_request.heure_deb},
	     {date_fin,OPT_CPT_req#opt_cpt_request.date_fin},
	     {heure_fin,OPT_CPT_req#opt_cpt_request.heure_fin},
	     {ptf_num,OPT_CPT_req#opt_cpt_request.ptf_num},
	     {tcp_num,OPT_CPT_req#opt_cpt_request.tcp_num},
	     {rnv_num,OPT_CPT_req#opt_cpt_request.rnv_num}
	    }
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type option_params(Opt::atom(),Subscription::atom(),Action::atom())->
%%                     opt_cpt_request().
%%%% Parameters for subscription via opt_cpt request.
%%%% These parameters are defined by option and subscription.
%%%% Subscription is: mobi | cmo | virgin_prepaid | virgin_comptebloque
%%%% Action: terminate or subscribe

search_option_params(Opt, Subscription, Action,[]) ->
    unknown_option_params;
search_option_params(Opt, Subscription, Action,[Option_Params| TAIL]) ->
    case Option_Params of
	{Opt, Subscription, Action, Type_Action, Top_Num, Date_Deb, Heure_Deb, Date_Fin, Heure_Fin, Ptf_Num, Tcp_Num, Cout, Mnt_initial, Rnv_Num} ->
	    #opt_cpt_request{
	  type_action = Type_Action,
	  top_num =integer_to_list(Top_Num),
	  date_deb = format_date(Date_Deb),
	  heure_deb = Heure_Deb,
	  date_fin = format_date(Date_Fin),
	  heure_fin = Heure_Fin,
	  ptf_num = integer_to_list(Ptf_Num),
	  tcp_num = integer_to_list(Tcp_Num),
	  cout = Cout,
	  mnt_initial = Mnt_initial,
	  rnv_num =Rnv_Num};
	{Opt, Subscription, all, Type_Action, Top_Num, Date_Deb, Heure_Deb, Date_Fin, Heure_Fin, Ptf_Num, Tcp_Num, Cout, Mnt_initial, Rnv_Num} ->
	    #opt_cpt_request{
	  type_action = Type_Action,
	  top_num =integer_to_list(Top_Num),
	  date_deb = format_date(Date_Deb),
	  heure_deb = Heure_Deb,
	  date_fin = format_date(Date_Fin),
	  heure_fin = Heure_Fin,
	  ptf_num = integer_to_list(Ptf_Num),
	  tcp_num = integer_to_list(Tcp_Num),
	  cout = Cout,
	  mnt_initial = Mnt_initial,
	  rnv_num =Rnv_Num};
	_ -> search_option_params(Opt, Subscription, Action, TAIL)
    end.

option_params(Opt, Subscription, Action) ->    
    case search_option_params(Opt, Subscription, Action,option_params_list()) of
	unknown_option_params -> slog:event(internal,?MODULE,unknown_options,{Opt, Subscription, Action}),
				 unknown_option_params;
	Option_Params -> 
	    Option_Params
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type ptf_num(Option::atom(),Subscription::atom()) ->
%%               integer().
%%%% Gives the PTF_NUM corresponding to the option.
%%%% Subscription is: mobi | cmo | virgin_prepaid | virgin_comptebloque | tele2cp
%%%% PTF_NUM values for options to which it is possible to subscribe
%%%% via USSD are defined in function option_params.
%%%% Other options PTF_NUM values (restitution, resiliation) are defined here. 

ptf_num(opt_nrj_data_illimite,   nrj_comptebloque) -> 41;
ptf_num(opt1_virg_30j,   virgin_comptebloque) -> 206;
ptf_num(opt2_virg_30j,   virgin_comptebloque) -> 202;
ptf_num(opt3_virg_30j,   virgin_comptebloque) -> 233;
ptf_num(opt4_virg_30j,   virgin_comptebloque) -> 234;
ptf_num(opt1_tele2_cb_25sms, tele2_comptebloque) -> 249;
ptf_num(opt1_tele2_cb_50sms, tele2_comptebloque) -> 249;
ptf_num(opt1_tele2_cb_100sms, tele2_comptebloque) -> 249;
ptf_num(opt1_tele2_cb_illsms, tele2_comptebloque) -> 217;
ptf_num(opt_numpref_tele2, tele2_pp)          -> 276;
ptf_num(opt_numpref_tele2, tele2_comptebloque)-> 276;
ptf_num(opt_illimite_cmo, cmo)                -> 41;
ptf_num(opt_1h_ts_reseaux, cmo)               -> 242;
ptf_num(opt_orange_messenger, cmo)               -> 41;
ptf_num(opt_msn_mensu_mobi, mobi)             -> 41;
ptf_num(opt_msn_journee_mo, mobi)             -> 41;
ptf_num(opt_ikdo_vx_sms, mobi)                -> 41;
ptf_num(opt_voice_unlimit, mobi)              -> 41;
ptf_num(opt_sms_unlimit, mobi)                -> 41;
ptf_num(opt_tv_unlimit, mobi)                 -> 41;
ptf_num(opt_ssms_illimite, mobi)              -> 41;
ptf_num(opt_jsms_illimite, mobi)              -> 41;
ptf_num(opt_sms_illimite, monacell_prepaid)   -> 41;
ptf_num(opt_sms_illimite, monacell_comptebloqu)   -> 41;
ptf_num(opt_internet_max_v3, mobi)            -> 41;
ptf_num(opt_internet_max_journee, mobi)       -> 41;
ptf_num(opt_internet_max_weekend, mobi)       -> 41;
ptf_num(opt_mail, mobi)                       -> 41;
ptf_num(opt_usages_commnunault, cmo)          -> 41;
ptf_num(opt_maghreb, cmo)                     -> 9;
ptf_num(opt_maghreb, mobi)                    -> 9;
ptf_num(opt_europe, cmo)                      -> 8;
ptf_num(opt_europe, mobi)                     -> 8;
ptf_num(opt_unik_data_pour_zap, cmo)          ->41;
ptf_num(opt_bonus_appels, mobi)               ->329;
ptf_num(opt_bonus_sms, mobi)                  ->330;
ptf_num(opt_bonus_internet, mobi)             ->331;
ptf_num(opt_bonus_appels_etranger, mobi)      ->332;
ptf_num(opt_bonus_europe, mobi)               ->332;
ptf_num(opt_bonus_maghreb, mobi)              ->332;
ptf_num(opt_bonus_appels_promo, mobi)         ->329;
ptf_num(opt_bonus_sms_promo, mobi)            ->330;
ptf_num(opt_bonus_internet_promo, mobi)       ->331;
ptf_num(opt_bonus_appels_etranger_promo, mobi)->332;
ptf_num(opt_bonus_europe_promo, mobi)         ->332;
ptf_num(opt_bonus_maghreb_promo, mobi)        ->332;
ptf_num(Opt = opt_mms_mensu,Subscription = mobi) ->
    OPT_CPT_req = option_params(Opt, Subscription, terminate),
    list_to_integer(OPT_CPT_req#opt_cpt_request.ptf_num);
ptf_num(Opt = opt_zap_quoti,Subscription = mobi) ->
    OPT_CPT_req = option_params(Opt, Subscription, terminate),
    list_to_integer(OPT_CPT_req#opt_cpt_request.ptf_num);
ptf_num(Opt,Subscription) ->
    OPT_CPT_req = option_params(Opt, Subscription, subscribe),
    list_to_integer(OPT_CPT_req#opt_cpt_request.ptf_num).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type tcp_num(Option::atom(),Subscription::atom()) ->
%%               integer().
%%%% Gives the TCP_NUM corresponding to the option and the subscription.
%%%% Subscription is: mobi | cmo | virgin_prepaid | virgin_comptebloque | tele2_cp
%%%% TCP_NUM values for options to which it is possible to subscribe
%%%% via USSD are defined in function option_params.
%%%% Other options TCP_NUM values (restitution) are defined here. 

tcp_num(opt_kdo_sms,     cmo)                 -> ?C_RDL_SMS;
tcp_num(opt_europe,     cmo)                  -> ?C_AEUROS;
tcp_num(opt_europe,     mobi)                 -> ?P_VOIX;
tcp_num(opt_maghreb,     cmo)                 -> ?C_AEUROS;
tcp_num(opt_maghreb,     mobi)                -> ?P_VOIX;
tcp_num(opt_1h_ts_reseaux,cmo)                -> ?C_TS_RESEAUX;
tcp_num(opt_orange_messenger,cmo)                -> ?C_MSN_MENSU_CMO;
tcp_num(opt_msn_journee_mobi,mobi)            -> ?C_MSN_MOBI;
tcp_num(opt_msn_mensu_mobi,mobi)              -> ?C_MSN_OMWL_MOBI;
tcp_num(opt_illimite_kdo,   mobi)             -> ?C_ILLIMITE_KDO;
tcp_num(opt_illimite_kdo_v2,mobi)             -> ?C_ILLIMITE_KDO;
tcp_num(opt_ikdo_vx_sms,    mobi)             -> ?C_IKDO_VX_SMS;
tcp_num(opt_easy_voice,  mobi)                -> ?C_EASY_VOICE;
tcp_num(opt_illimite_mobi,mobi)               -> ?C_EASY_VOICE;
tcp_num(opt_we_ow,       mobi)                -> ?C_ESP_MUL;
tcp_num(opt1_virg_30j,   virgin_comptebloque) -> ?C_FORF_VIRGIN1;
tcp_num(opt2_virg_30j,   virgin_comptebloque) -> ?C_FORF_VIRGIN2;
tcp_num(opt3_virg_30j,   virgin_comptebloque) -> ?C_FORF_VIRGIN3;
tcp_num(opt4_virg_30j,   virgin_comptebloque) -> ?C_FORF_VIRGIN4;
tcp_num(opt_sms_200,   virgin_comptebloque) -> ?OPT_SMS_200_VIRGIN_CB;
tcp_num(opt_sms_ill,   virgin_comptebloque) -> ?OPT_SMS_ILL_VIRGIN_CB;
tcp_num(opt_sms_200,   bzh_cmo) -> ?OPT_SMS_200_BZH_CB;
tcp_num(opt_5n_preferes,   virgin_comptebloque) -> ?C_OPT_5N_PREFERES_VIRGIN_CB;
tcp_num(verysms,         virgin_prepaid)      -> ?C_OPT_VIRGIN_PP;
tcp_num(veryvoix,        virgin_prepaid)      -> ?C_OPT_VIRGIN_PP;
tcp_num(very4,           virgin_prepaid)      -> ?C_OPT_VIRGIN_PP;
tcp_num(verylong,        virgin_prepaid)      -> ?C_PRINC;
tcp_num(opt1_tele2_cb_25sms, tele2_comptebloque) -> ?C_FORF_TELE2_CB_25_SMS;
tcp_num(opt1_tele2_cb_50sms, tele2_comptebloque) -> ?C_FORF_TELE2_CB_50_SMS;
tcp_num(opt1_tele2_cb_100sms, tele2_comptebloque) -> ?C_FORF_TELE2_CB_100_SMS;
tcp_num(opt1_tele2_cb_illsms, tele2_comptebloque) -> ?C_FORF_TELE2_CB_ILL_SMS;
tcp_num(opt_numpref_tele2,          tele2_pp) -> ?C_TELE2_NUM_PREFERE;
tcp_num(opt_numpref_tele2,tele2_comptebloque) -> ?C_TELE2_NUM_PREFERE;
tcp_num(opt_mms_mensu,   mobi)                -> ?C_MMS_MENSU;
tcp_num(opt_bp_10_mms,   mobi)                -> ?TCPNUM_PACKNOEL;
tcp_num(opt_voice_unlimit, mobi)              -> ?C_KDO_VOIX;
tcp_num(opt_sms_unlimit, mobi)                -> ?C_KDO_SMS;
tcp_num(opt_tv_unlimit,  mobi)                -> ?C_KDO_TV;
tcp_num(opt_surf_unlimit,mobi)                -> ?C_SL_7E;
tcp_num(opt_sl_7E, cmo)                       -> ?C_SL_7E;
tcp_num(media_decouvrt,cmo)                   -> 26;
tcp_num(media_internet,cmo)                   -> 26;
tcp_num(media_internet_plus,cmo)              -> 26;
tcp_num(opt_2numpref,cmo)                     -> 78;
tcp_num(opt_3num_kdo,cmo)                     -> 24;
tcp_num(opt_3num_kdo_sms,cmo)                 -> 105;
tcp_num(opt_bons_plans,cmo)                   -> 59;
tcp_num(opt_bons_plans,mobi)                  -> 59;
tcp_num(opt_bp_10_mms,cmo)                    -> 43;
tcp_num(opt_cadeau_orange_MMS,cmo)            -> 32;
tcp_num(opt_credit_OW_of,cmo)                 -> 23;
tcp_num(opt_credit_sms_of,cmo)                -> 22;
tcp_num(opt_credit_voix_of,cmo)               -> 21;
tcp_num(opt_easy_voice,cmo)                   -> 55;
tcp_num(opt_erech_smsmms,cmo)                 -> 43;
tcp_num(opt_etudiante,cmo)                    -> 37;
tcp_num(opt_five_min,cmo)                     -> 71;
tcp_num(opt_illimite_cmo,cmo)                 -> 55;
tcp_num(opt_J_illi_Data,cmo)                  -> 65;
tcp_num(opt_m5_20_sms,cmo)                    -> 100;
tcp_num(opt_m5_vx_rmg,cmo)                    -> 101;
tcp_num(opt_m6_smsmms,cmo)                    -> 68;
tcp_num(opt_usages_commnunault,cmo)           -> 292;
tcp_num(opt_OW_10E,cmo)                       -> 26;
tcp_num(opt_OW_30E,cmo)                       -> 26;
tcp_num(opt_ow_deco,cmo)                      -> 79;
tcp_num(opt_sms_12,cmo)                       -> 12;
tcp_num(opt_sms_18,cmo)                       -> 12;
tcp_num(opt_sms_25,cmo)                       -> 12;
tcp_num(opt_sms_3,cmo)                        -> 12;
tcp_num(opt_sms_7_5,cmo)                      -> 12;
tcp_num(opt_sms_surtaxe,mobi)                 -> 43;
tcp_num(opt_stim_voix,cmo)                    -> 30;
tcp_num(opt_weinf_OW_TV,cmo)                  -> 31;
tcp_num(opt_WE_OW,cmo)                        -> 65;
tcp_num(opt_we_voix_ill,cmo)                  -> 94;
tcp_num(opt_zap_mms,cmo)                      -> 67;
tcp_num(opt_zap_mms,mobi)                     -> 67;
tcp_num(ow_spo,cmo)                           -> 89;
tcp_num(ow_surf,cmo)                          -> 91;
tcp_num(ow_tv2,cmo)                           -> 88;
tcp_num(ow_tv,cmo)                            -> 87;
tcp_num(sms_opt_OW,cmo)                       -> 11;
tcp_num(ow_musique,cmo)                       -> ?C_MUSIQUE;
tcp_num(osl,cmo)                              -> ?C_WAP;
tcp_num(opt_foot_ligue1,cmo)                  -> 217;
tcp_num(opt_tt_shuss,mobi)                    -> ?TCPNUM_PACKNOEL;
tcp_num(opt_pack_duo_journee,mobi)                    -> ?TCPNUM_PACKNOEL;
tcp_num(opt_pass_vacances,mobi)               -> ?P_VOIX;
tcp_num(opt_pass_vacances_v2,mobi)               -> ?P_VOIX;
tcp_num(opt_pass_vacances_z2,mobi)               -> ?P_VOIX;
tcp_num(opt_pass_voyage_9E,mobi)               -> ?P_VOIX;
tcp_num(opt_ten_cb_20_sms,ten_comptebloque)   -> 131;
tcp_num(opt_ten_cb_50_sms,ten_comptebloque)   -> 125;
tcp_num(opt_ten_cb_100_sms,ten_comptebloque)  -> 138;
tcp_num(roaming_out,cmo)                      -> ?C_ROAMING_OUT;
tcp_num(roaming_in,cmo)                       -> ?C_ROAMING_IN;
tcp_num(rech_7E_cb_mobi,mobi)                 -> ?C_RECH_SL_7E_1;
tcp_num(rech_15E_cb_mobi,mobi)                -> ?C_RECH_SL_15E;
tcp_num(rech_20E_cb_mobi,mobi)                -> ?C_RECH_SL_20E;
tcp_num(opt_kdo_sinf,mobi)                    -> ?C_BONS_PLANS;
tcp_num(opt_ssms_m6,mobi)                     -> ?C_M6P_SMS_RECHARGE;
tcp_num(opt_nrj_data_illimite,nrj_comptebloque)->?C_NRJ_MINI_FF_DATA;
tcp_num(opt_nrj_data,nrj_comptebloque)        -> ?C_OPT_DATA_NRJ;
tcp_num(opt_nrj_sms,nrj_comptebloque)         -> ?C_OPT_SMS_NRJ; 
tcp_num(opt_nrj_data_2mo,nrj_comptebloque)    -> ?C_FORF_NRJ_DATA;        
tcp_num(opt_nrj_data_4mo,nrj_comptebloque)    -> ?C_FORF_NRJ_DATA;        
tcp_num(opt_sms_illimite_soir,cmo)            -> ?C_OPT_SMS_ILL_SOIR;
tcp_num(opt_bonus_multimedia,cmo)             -> ?C_OPT_BONUS_MULTIMEDIA_M6;    
tcp_num(opt_bby_sms_illimite,cmo)             -> ?C_OPT_SMS_ILL_SOIR;    
tcp_num(opt_sms_illimite, monacell_prepaid)   -> ?C_RECH_SMS_ILLM;
tcp_num(opt_orange_maps,mobi)                 -> ?C_ORANGE_MAPS;
tcp_num(opt_orange_maps,cmo)                  -> ?C_ORANGE_MAPS;
tcp_num(opt_double_jeu_pp,nrj_prepaid)        -> ?C_NRJ_SMS_ILL;
tcp_num(opt_nrj_light,nrj_prepaid)            -> ?C_NRJ_PP_LIGHT;     
tcp_num(opt_ssms_illimite,mobi)               -> ?C_OPT_SMS_ILLIMITE;
tcp_num(opt_jsms_illimite,mobi)               -> ?C_OPT_SMS_ILLIMITE;
tcp_num(opt_internet_max_v3, mobi)            -> 286;
tcp_num(opt_internet_max_journee, mobi)       -> 194;
tcp_num(opt_internet_max_weekend, mobi)       -> 289;
tcp_num(opt_10mn_europe, mobi)                -> 288;
tcp_num(opt_10mn_europe, cmo)                 -> 288;
tcp_num(opt_unik_data_pour_zap, cmo)          -> 277;
tcp_num(opt_bonus_sms_illimite, mobi)         -> ?C_MOBI_BONUS_SMS;
%%tcp_num(opt_tele2_25_sms,tele2_compte_bloque) -> 124;
%%tcp_num(opt_tele2_50_sms,tele2_compte_blqoue) -> 125;
tcp_num(opt_dte_plus,          mobi)          -> 0;
tcp_num(opt_mail, mobi)                       -> 270;
tcp_num(Opt,Subscription) when
    Opt==opt_tv_mensu;
    Opt==opt_musique_mensu;
    Opt==opt_musique;
    Opt==opt_sport_mensu;
    Opt==opt_total_tv_mensu;
    Opt==opt_zap_quoti;
    Opt==opt_temps_plus;
    Opt==opt_cityzi->
    OPT_CPT_req = option_params(Opt, Subscription, terminate),
    list_to_integer(OPT_CPT_req#opt_cpt_request.tcp_num);

tcp_num(Opt,Subscription) -> 
    OPT_CPT_req = option_params(Opt, Subscription, subscribe),
    list_to_integer(OPT_CPT_req#opt_cpt_request.tcp_num).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type top_num(Option::atom(),Subscription::atom()) -> integer().

%%%% Gives the TOP_NUM corresponding to the option and the subscription.
%%%% Subscription is: mobi | cmo | virgin_prepaid | virgin_comptebloque
%%%% TOP_NUM values for options to which it is possible to subscribe, or
%%%% which can be terminated or modified via USSD are defined in function
%%%% option_params.
%%%% Other options TOP_NUM values (restitution) are defined here. 

top_num(Opt, Sub) when list(Sub) ->
    slog:event(warning, ?MODULE, bad_subscription_format, Sub),
    top_num(Opt, list_to_atom(Sub));

%% Mobi option for which we only do a restitution
top_num(opt_cb_mobi,                   mobi) -> 130;
top_num(opt_pass_supporter,            mobi) -> 62;
top_num(opt_6sms_quoti,                mobi) -> 63;
top_num(opt_orange_foot_offert,        mobi) -> 341;
top_num(opt_easy_voice,                mobi) -> 74;
top_num(opt_illimite_mobi,             mobi) -> 75;
top_num(opt_illimite_kdo,           mobi) -> 127;
top_num(opt_illimite_kdo_v2,           mobi) -> 166;
top_num(opt_promo_base_sms,            mobi) -> 90;
top_num(opt_we_ow,                     mobi) -> 94;
top_num(opt_odr,                       mobi) -> 103;
top_num(opt_ort,                       mobi) -> 104;
top_num(ow_tv,                         mobi) -> 113;
top_num(ow_tv1,                        mobi) -> 113;
top_num(ow_tv2,                        mobi) -> 114;
top_num(opt_ikdo_vx_sms,               mobi) -> 135;
top_num(opt_mms_mensu,                 mobi) -> 139;
top_num(opt_mail, mobi)                      -> 448;
%For 5218 Godet sur PCM (PC Juin 09)
%top_num(opt_mms_mensu,                 mobi) -> 332;
top_num(opt_J_illi_Data,               mobi) -> 142;
top_num(opt_bp_10_mms,                 mobi) -> 140;
top_num(opt_top_num_198,               mobi) -> 198;
top_num(opt_ssms_illimite,             mobi) -> 391;
top_num(opt_jsms_illimite,             mobi) -> 318;
top_num(opt_mes_donnees,               mobi) -> 370;

%% tele2 options for which we only do a restitution
top_num(opt1_tele2_cb_25sms, tele2_comptebloque) -> 162;
top_num(opt1_tele2_cb_50sms, tele2_comptebloque) -> 163;
top_num(opt1_tele2_cb_100sms, tele2_comptebloque) -> 168;
top_num(opt1_tele2_cb_illimite, tele2_comptebloque) -> 217;
top_num(opt_numpref_tele2,        tele2_pp)  -> 376;
top_num(opt_numpref_tele2,        tele2_comptebloque)  -> 376;
%% CMO option for which we only do a restitution
top_num(osl,                           cmo)  -> 10;
top_num(opt_stim_voix,                 cmo)  -> 29;
top_num(pack_sms,                      cmo)  -> 32;
top_num(pack_mms,                      cmo)  -> 33;
top_num(opt_report,                    cmo)  -> 41;
top_num(opt_foot_ligue1,               cmo)  -> 271;
top_num(forf_orangex,                  cmo)  -> 57; %% added in July 06
top_num(opt_pass_supporter,            cmo) ->  62;
top_num(opt_kdo_sms,                   cmo)  -> 66;
top_num(cpte_easy_voice,               cmo)  -> 74;
top_num(opt_illimite_cmo,              cmo)  -> 75;
top_num(opt_m6_smsmms,                 cmo)  -> 80;
top_num(opt_five_min,                  cmo)  -> 89;
top_num(opt_2numpref,                  cmo)  -> 91;
top_num(opt_ow_deco,                   cmo)  -> 92;
top_num(opt_we_voix_ill,               cmo)  -> 108;
top_num(opt_bp_10_mms,                 cmo)  -> 140;
%% TOP_NUMs for restitution of CMO options which were subscribed via asmetier
top_num(media_decouvrt,                cmo)  -> 11;
top_num(media_internet,                cmo)  -> 12;
top_num(media_internet_plus,           cmo)  -> 58;
top_num(ow_tv,                         cmo)  -> 113;
top_num(ow_tv1,                        cmo)  -> 113;
top_num(ow_tv2,                        cmo)  -> 114;
top_num(ow_spo,                        cmo)  -> 115;
top_num(ow_surf,                       cmo)  -> 117;
top_num(ow_musique,                    cmo)  -> 125;
top_num(opt_sms_3,                     cmo)  -> 8;
top_num(opt_sms_7_5,                   cmo)  -> 9;
top_num(opt_sms_12,                    cmo)  -> 14;
top_num(opt_sms_18,                    cmo)  -> 101;
top_num(opt_sms_25,                    cmo)  -> 102;
top_num(opt_weinf_OW_TV,               cmo)  -> 68;
top_num(opt_3num_kdo,                  cmo)  -> 4;
top_num(opt_OW_10E,                    cmo)  -> 13;
top_num(opt_OW_30E,                    cmo)  -> 59;
top_num(sms_opt_OW,                    cmo)  -> 15;
top_num(opt_etudiante,                 cmo)  -> 26;
top_num(opt_3num_kdo_sms,              cmo)  -> 132;
top_num(opt_J_illi_Data,               cmo)  -> 142;
top_num(opt_WE_OW,                     cmo)  -> 94;
top_num(opt_1h_ts_reseaux,             cmo)  -> 152;
top_num(opt_orange_messenger,             cmo)  -> 155;
top_num(winning_50sms,                 cmo)  -> 160;
top_num(opt_tv_renouv,                 cmo)  -> 184;
top_num(opt_pass_vacances,             cmo)  -> 124;
top_num(opt_pass_vacances_z2,          cmo)  -> 342;
top_num(opt_pass_voyage_9E,            cmo)  -> 357;
top_num(opt_tv,                        cmo)  -> 226;
top_num(opt_tv_max,                    cmo)  -> 228;
%For 5218 Godet sur PCM (PC Juin 09)
%top_num(opt_tv_max,                    cmo)  -> 331;
top_num(verysms,            virgin_prepaid)  -> 221;
top_num(veryvoix,           virgin_prepaid)  -> 222;
top_num(very4,              virgin_prepaid)  -> 338;
top_num(verylong,           virgin_prepaid)  -> 407;
top_num(opt_unik,                     mobi)  -> 18;
top_num(opt_frais_maint,            symacom) -> 84;
top_num(opt_nrj_data_illimite,     nrj_comptebloque)  -> 489;
top_num(opt_nrj_data,     nrj_comptebloque)  -> 128;
top_num(opt_nrj_sms,      nrj_comptebloque)  -> 122;    
top_num(opt_nrj_data_2mo,nrj_comptebloque)   -> 386;
top_num(opt_nrj_data_4mo,nrj_comptebloque)   -> 383;
top_num(opt_double_jeu_pp,nrj_prepaid)       -> 399;
top_num(opt_nrj_light,nrj_prepaid)           -> 398;
top_num(opt_sms_illimite_soir, cmo)          -> 170;
top_num(opt_bonus_multimedia, cmo)           -> 249;
top_num(opt_bby_sms_illimite, cmo)           -> 334;
top_num(opt_sms_illimite,      monacell_prepaid)  -> 394;
top_num(opt_sms_illimite, monacell_comptebloqu)  -> 442;
top_num(opt_orange_maps,      cmo)           -> 393;
top_num(opt_internet_max_v3,  mobi)          -> 401;
top_num(opt_internet_max_journee, mobi)      -> 424;
top_num(opt_internet_max_weekend, mobi)      -> 415;
top_num(opt_usages_commnunault,cmo)          -> 420;
top_num(opt_bonus_appels,mobi)                 -> 435;
top_num(opt_bonus_sms,mobi)                  -> 436;
top_num(opt_bonus_internet,mobi)             -> 437;
top_num(opt_bonus_appels_etranger,mobi)      -> 438;
top_num(opt_bonus_europe,mobi)               -> 439;
top_num(opt_bonus_maghreb,mobi)               -> 440;
top_num(opt_unik_data_pour_zap,cmo)         ->377; 
top_num(opt_unik_zap_ts_ope_16h_20h,cmo)    -> 429; 
top_num(opt_dte_plus,              mobi)    -> 7;
top_num(Opt,Subscription)
  when (Opt==opt_temps_plus) or
       (Opt==opt_mms_mensu) or 
       (Opt==opt_musique_mensu) or
       (Opt==opt_musique) or
       (Opt==opt_tv_mensu) or
       (Opt==opt_sport_mensu) or
       (Opt==opt_total_tv_mensu) or
       (Opt==opt_msn_mensu_mobi) or
       (Opt==opt_zap_quoti) or
       (Opt==opt_cityzi) or
       (Opt==opt_unik),
       Subscription==mobi ->
    OPT_CPT_req = option_params(Opt, Subscription, terminate),
    list_to_integer(OPT_CPT_req#opt_cpt_request.top_num);

top_num(Opt,Subscription)
  when Subscription==mobi;
       Subscription==cmo;
       Subscription==virgin_prepaid;
       Subscription==virgin_comptebloque;
       Subscription==bzh_cmo;
       Subscription==carrefour_comptebloq;
       Subscription==tele2_comptebloque->
    OPT_CPT_req = option_params(Opt, Subscription, subscribe),
    list_to_integer(OPT_CPT_req#opt_cpt_request.top_num);

top_num(Opt,Subscription) -> 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type dlv_opt(Opt::atom(),Subscription::atom())->
%%               string().
%%%% Gives the DLV (validity end date) corresponding
%%%% to the option and the subscription.

dlv_opt(opt_europe,  cmo)  -> format_date_dm(today_plus_datetime(14));
dlv_opt(opt_maghreb, cmo)  -> format_date_dm(today_plus_datetime(14));
dlv_opt(opt_sms_quoti, cmo)  -> format_date_dm(today_plus_datetime(0));
dlv_opt(rech_20E_tlr_mobi, mobi) -> format_date(today_plus_datetime(31));
dlv_opt(rech_20E_cb_mobi, mobi) -> format_date(today_plus_datetime(31));
dlv_opt(opt_numpref_tele2, tele2_pp) -> format_date(today_plus_datetime(31));
dlv_opt(opt_numpref_tele2, tele2_comptebloque) -> format_date(today_plus_datetime(31));
dlv_opt(opt_1h_fixe, mobi) -> format_date_dm(today_plus_datetime(7));
dlv_opt(opt_msn_mensu_mobi, mobi) -> format_date(today_plus_datetime(31));
dlv_opt(opt_sl_7E,cmo) -> format_date(today_plus_datetime(7));
dlv_opt(rech_7E_cb_mobi,mobi) -> format_date(today_plus_datetime(7));
dlv_opt(opt_sms_illimite,monacell_prepaid) -> format_date(today_plus_datetime(31));
dlv_opt(opt_sms_illimite,monacell_comptebloqu) -> format_date(today_plus_datetime(31));
dlv_opt(opt_rech_sl_20E, cmo)  -> format_date_dmy(today_plus_datetime(31));
dlv_opt(opt_rech_sl_20E, mobi)  -> format_date_dmy(today_plus_datetime(31));
dlv_opt(opt_pass_dom,mobi) -> format_date_dm(today_plus_datetime(14));
dlv_opt(opt_pass_dom,cmo) -> format_date_dm(today_plus_datetime(14));

dlv_opt(Opt, Subscription) ->
    OPT_CPT_req = option_params(Opt, Subscription, subscribe),
    OPT_CPT_req#opt_cpt_request.date_fin.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type option_params_list()-> list().
%%     [{option::atom(),subscription::atom(),action::atom(),
%%       type_action::string(),top_num::integer(),
%%       date_deb::strint(),heure_deb::string(),
%%       date_fin::string(),heure_fin::string(),
%%       pft_num::integer(),tcp_num::integer(),
%%       cout::string(),mnt_initial::string(),
%%       rnv_num::string()}|list()].
%%%% Correspondence between option,subscription,action and parameters for OPT_CPT request. 
%%%%
%%%% option:: atom         option's name
%%%% subscription::atom()  mobi|cmo
%%%% action::atom()        subscribe|terminate|all
%%%% type_action::string() "A"|"S"
%%%% top_num::integer()
%%%% date_deb::strint()    undefined|date()
%%%% heure_deb::string()   "-"|"00:00:00"
%%%% date_fin::string()    undefined|date()
%%%% heure_fin::string()   "-"|"00:00:00"
%%%% pft_num::integer()    Plan tarifaire
%%%% tcp_num::integer()    Type de compte
%%%% cout::string()    
%%%% mnt_initial::string() Montant initiale    
%%%% rnv_num::string()     Renouvellement
%%%%
%%%% Default values
%%%% {option, subscription, action, type_action, top_num, date_deb, heure_deb, date_fin, heure_fin, 
%%%%  ptf_num, tcp_num, cout, mnt_initial, rnv_num}
%%%% {      ,             ,       ,            ,        , date()  ,"00:00:00",undefined, "-"      ,  
%%%%   0     , -1     , "-" , "-1"       , "-1"

option_params_list()->
	[{opt_appelprixunique,mobi,all,"A",64,date(),"00:00:00",today_plus_datetime(31),"23:59:59",24,?C_PRINC,"-","-1","-1"},
	 {opt_appelprixunique,cmo, all,"A",64,date(),"00:00:00",today_plus_datetime(31),"23:59:59",24,?C_PRINC,"-","-1","-1"},
	 {opt_afterschool,mobi,all,"A",61,date(),"00:00:00",date(),"23:59:59",26,?TCP_AFTERSCH_MOBI,"-","-1","-1"},
	 {opt_afterschool,cmo,all,"A",61,date(),"00:00:00",date(),"23:59:59",26,?TCP_AFTERSCH_CMO,"-","-1","-1"},
	 {opt_bonus_int,mobi,all,"A",76,date(),"00:00:00",today_plus_datetime(31),"00:00:00",41,?C_ESP_MUL,"-","-1","-1"},
	 {opt_erech_jinf,mobi,all,"A",93,date(),"00:00:00",today_plus_datetime(28),"23:59:59",41,?C_JINF_VOIX,"-","-1","-1"},
	 {opt_erech_smsmms,mobi,all,check_opt_status,44,date(),"00:00:00",today_plus_datetime(31),"23:59:59",60,?C_E_RECHARGE,"-","-1","-1"},
	 {opt_europe,mobi,all,check_opt_status,6,date(),"00:00:00",today_plus_datetime(14),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_europe,cmo,all,check_opt_status,6,date(),"00:00:00",today_plus_datetime(14),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_ikdo_vx_sms,mobi,subscribe,"A",135,date(),"00:00:00",undefined,"-",0,-1,"0","0","0"},
	 {opt_ikdo_vx_sms,mobi,modify,   "A",127,date(),"00:00:00",undefined,"-",0,-1,"0","0","0"},
	 {opt_ikdo_vx_sms,mobi,terminate,"S",135,date(),"00:00:00",undefined,"-",0,?C_IKDO_VX_SMS,"-","-1","-1"},
	 {opt_illimite_kdo,mobi,subscribe,"A",127,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_illimite_kdo,mobi,modify,   "A",127,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_illimite_kdo,mobi,terminate,"S",127,date(),"00:00:00",undefined,"-",41,?C_ILLIMITE_KDO,"-","-1","-1"},
	 
	 {opt_ikdo_voix,mobi,subscribe,"A",166,undefined,"-",undefined,"-",0,-1,"0","-1","-1"},
	 {opt_ikdo_voix,mobi,modify,   "M",166,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_ikdo_voix,mobi,set,      "A",166,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_ikdo_voix,mobi,terminate,"S",166,undefined,"-",undefined,"-",0,?C_ILLIMITE_KDO,"-","-1","-1"},

	 {opt_ikdo_sms, mobi,subscribe,"A",167,undefined,"-",undefined,"-",0,-1,"0","-1","-1"},
	 {opt_ikdo_sms, mobi,modify,   "M",167,undefined,"-",undefined,"-",0,-1,"0","-1","-1"},
	 {opt_ikdo_sms, mobi,terminate,"S",167,undefined,"-",undefined,"-",0,?C_IKDO_VX_SMS,"-","-1","-1"},

	 {opt_jinf,mobi,subscribe,"A",29,date(),"00:00:00",date(),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_jinf,mobi,terminate,"S",29,date(),"00:00:00",date(),"23:59:59",41,?C_JINF_VOIX,"0","0","0"},
	 {opt_jinf,cmo,all,"A",48,date(),"00:00:00",date(),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_maghreb,mobi,all,check_opt_status,19,date(),"00:00:00",today_plus_datetime(14),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_maghreb,cmo,all,check_opt_status,19,date(),"00:00:00",today_plus_datetime(14),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_mms_mensu,mobi,subscribe,"A",139,date(),"00:00:00",undefined,"-",58,-1,"-","-1","-1"},
	 {opt_mms_mensu,mobi,terminate,"S",139,date(),"00:00:00",undefined,"-",58,-1,"-","-1","-1"},
	 {opt_mms_mensu,cmo,terminate,"S",139,date(),"00:00:00",undefined,"-",58,-1,"-","-1","-1"},
	 {opt_j_omwl,cmo,all,"A",157,date(),"00:00:00",date(),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_musique_v0,mobi,all,"A",116,date(),"00:00:00",undefined,"-",41,?C_MUSIQUE,"-","-1","-1"},
	 {opt_numprefg,mobi,all,"A",3,date(),"00:00:00",next_monday_date(),"23:59:59",20,?C_NUM_PREF,"-","-1","-1"},
	 {opt_numprefp,mobi,all,"A",36,date(),"00:00:00",next_monday_date(),"23:59:59",20,?C_NUM_PREF,"-","-1","-1"},
	 {opt_ow_deco,mobi,all,"A",92,date(),"00:00:00",next_monday_date(),"23:59:59",17,?C_OW_DECO,"-","-1","-1"},
	 {opt_ow_3E_mobi,mobi,all,check_opt_status,52,date(),"00:00:00",today_plus_datetime(31),"23:59:59",40,?C_RDL_WAP,"-","-1","-1"},
	 {opt_ow_6E_mobi,mobi,all,check_opt_status,53,date(),"00:00:00",today_plus_datetime(31),"23:59:59",11,?C_RDL_WAP,"-","-1","-1"},
	 {opt_ow_10E_mobi,mobi,all,check_opt_status,54,date(),"00:00:00",today_plus_datetime(31),"23:59:59",15,?C_RDL_WAP,"-","-1","-1"},
	 {opt_pack_noel_mms,mobi,all,"A",23,date(),"00:00:00",next_monday_date(),"23:59:59",58,?TCPNUM_PACKNOEL,"-","-1","-1"},
	 {opt_pack_voeux_smsmms,mobi,all,"A",24,date(),"00:00:00",next_monday_date(),"23:59:59",43,?TCPNUM_PACKNOEL,"-","-1","-1"},
%% Options Pass Vacances Mobi & CMO 
	 %%Obsolete opt_pass_vacances_moc/mtc ?
	 {opt_pass_vacances_moc,mobi,all,"A",124,date(),"00:00:00",undefined,"-",235,?P_VOIX,"-","-1","-1"},
	 {opt_pass_vacances_moc,cmo,all,check_opt_status,124,date(),"00:00:00",undefined,"-",235,?C_AEUROS,"-","-1","-1"},
	 {opt_pass_vacances_mtc,mobi,all,"A",126,date(),"00:00:00",undefined,"-",235,?C_PASS_MTC,"-","-1","-1"},
	 {opt_pass_vacances_mtc,cmo,all,check_opt_status,126,date(),"00:00:00",undefined,"-",235,?C_PASS_MTC,"-","-1","-1"},
	 {opt_pass_vacances_v2_moc,mobi,all,"A",124,date(),"00:00:00",undefined,"-",0,?P_VOIX,"3395","-1","-1"},	
	 {opt_pass_vacances_v2_mtc,mobi,all,"A",126,date(),"00:00:00",undefined,"-",0,?C_PASS_MTC,"1605","-1","-1"},	
	 {opt_pass_vacances_v2_10_sms,mobi,all,"A",251,date(),"00:00:00",undefined,"-",0,?C_PASS_VACANCES_SMS_Z2,"1000","-1","-1"},	
	 {opt_pass_vacances_v2_moc,cmo,all,"A",124,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},	
	 {opt_pass_vacances_v2_mtc,cmo,all,"A",126,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},	
	 {opt_pass_vacances_v2_10_sms,cmo,all,"A",251,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},

	 {opt_pass_vacances_z2_moc,mobi,all,"A",342,date(),"00:00:00",undefined,"-",273,?P_VOIX,"5457","-1","-1"},
	 {opt_pass_vacances_z2_moc,cmo,all,check_opt_status,342,date(),"00:00:00",undefined,"-",273,?C_AEUROS,"2543","-1","-1"},
	 {opt_pass_vacances_z2_mtc,mobi,all,"A",343,date(),"00:00:00",undefined,"-",273,?C_PASS_MTC,"-","-1","-1"},
	 {opt_pass_vacances_z2_mtc,cmo,all,check_opt_status,343,date(),"00:00:00",undefined,"-",273,?C_PASS_MTC,"-","-1","-1"},
	 {opt_pass_vacances_z2_sms,mobi,all,"A",251,date(),"00:00:00",undefined,"-",5,?C_PASS_VACANCES_SMS_Z2,"1000","-1","-1"},
	 {opt_pass_vacances_z2_sms,cmo,all,check_opt_status,251,date(),"00:00:00",undefined,"-",5,?C_PASS_VACANCES_SMS_Z2,"1000","-1","-1"},
%%
	 {opt_roaming,mobi,all,"A",55,date(),"00:00:00",next_monday_date(),"23:59:59",14,?P_VOIX,"-","-1","-1"},
	 {opt_roaming,cmo,all,"A",55,date(),"00:00:00",next_monday_date(),"23:59:59",14,?C_AEUROS,"-","-1","-1"},
	 {opt_seminf,mobi,all,"A",60,date(),"00:00:00",next_monday_date(),"23:59:59",38,?C_RDL_VOIX,"-","-1","-1"},
	 {opt_seminf,cmo,all,"A",60,date(),"00:00:00",next_monday_date(),"23:59:59",38,?C_RDL_VOIX,"-","-1","-1"},
	 {opt_sinf,mobi,all,"A",43,date(),"00:00:00",date(),"23:59:59",41,?C_RDL_VOIX_MOBI,"-","-1","-1"},
	 {opt_sinf,cmo,all,"A",43,date(),"00:00:00",date(),"23:59:59",41,?C_RDL_VOIX,"-","-1","-1"},
	 {opt_sl_7E,cmo,all,"A",148,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_sms_hebdo,cmo,all,"A",34,date(),"00:00:00",next_monday_date(),"23:59:59",155,?C_RDL_MUL,"-","-1","-1"},
	 {opt_sms_quoti,mobi,subscribe,"A",95,date(),"00:00:00",undefined,"-",68,?C_SMS_QUOTIDIEN,"-","-1","-1"},
	 {opt_sms_quoti,cmo,all,"-",95,date(),"00:00:00",undefined,"-",68,?C_SMS_QUOTIDIEN,"-","-1","-1"},
	 {opt_sms_quoti,mobi,terminate,"S",95,date(),"00:00:00",undefined,"-",68,?C_SMS_QUOTIDIEN,"-","-1","-1"},
	 {opt_sms_mensu,cmo,subscribe,"A",109,date(),"00:00:00",undefined,"-",238,66,"-","-1","-1"},
	 {opt_sms_mensu,mobi,subscribe,"A",109,date(),"00:00:00",undefined,"-",238,66,"-","-1","-1"},
	 {opt_sms_mensu,cmo,terminate,"S",109,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_sms_mensu,mobi,terminate,"S",109,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_sms_surtaxe,cmo,all,"A",67,date(),"00:00:00",next_monday_date(),"23:59:59",69,?TCPNUM_PACKNOEL,"-","-1","-1"},

	 {opt_sport,mobi,all,"A",112,date(),"00:00:00",undefined,"-",41,?C_SPORT,"-","-1","-1"},
	 {opt_ssms,mobi,all,"A",35,date(),"00:00:00",date(),"23:59:59",140,?C_RDL_MUL,"-","-1","-1"},
	 {opt_ssms,cmo,all,"A",35,date(),"00:00:00",date(),"23:59:59",140,?C_RDL_MUL,"-","-1","-1"},
	 {opt_surf,mobi,all,"A",118,date(),"00:00:00",undefined,"-",41,?C_SURF,"-","-1","-1"},
	 {opt_surf_mensu,mobi,subscribe,"A",138,date(),"00:00:00",today_plus_datetime(31),"-",41,?C_SURF_MENSU,"-","-1","-1"},
	 {opt_surf_mensu,mobi,terminate,"S",138,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_temps_plus,mobi,terminate,"S",7,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_temps_plus,cmo,terminate,"S",7,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_tt_shuss_sms,mobi,all,"A",39,date(),"00:00:00",date(),"20:59:29",?C_DUO_JOURNEE,?TCPNUM_PACKNOEL,"-","-1","-1"},
	 {opt_tt_shuss_sms,cmo,all,"A",39,date(),"00:00:00",date(),"20:59:29",59,?TCPNUM_PACKNOEL,"-","-1","-1"},
	 {opt_tt_shuss_voix,mobi,all,"A",38,date(),"00:00:00",date(),"20:59:29",43,?C_SURPRISE_VOIX,"-","-1","-1"},
	 {opt_tt_shuss_voix_2,mobi,all,"A",431,date(),"00:00:00",date(),"20:59:29",?C_DUO_JOURNEE,?C_SURPRISE_VOIX,"-","-1","-1"},
	 {opt_tt_shuss_voix,cmo,all,"A",38,date(),"00:00:00",date(),"20:59:29",144,?C_SURPRISE_VOIX,"-","-1","-1"},
	 {opt_vacances,mobi,all,check_opt_status,37,date(),"00:00:00",today_plus_datetime(31),"23:59:59",58,?TCPNUM_PACKNOEL,"-","-1","-1"},
	 {opt_vacances,cmo,all,"A",37,date(),"00:00:00",today_plus_datetime(31),"23:59:59",58,?TCPNUM_PACKNOEL,"-","-1","-1"},
	 {opt_voyage,mobi,all,check_opt_status,56,date(),"00:00:00",today_plus_datetime(30),"23:59:59",12,?P_VOIX,"-","-1","-1"},
	 {opt_voyage,cmo,all,"A",56,date(),"00:00:00",today_plus_datetime(30),"23:59:59",12,?C_AEUROS,"-","-1","-1"},
	 {opt_weinf,mobi,all,"A",17,date(),"00:00:00",next_monday_date(),"00:00:00",41,?C_ESP_VOIX,"-","-1","-1"},
	 {opt_weinf,cmo,all,"A",17,date(),"00:00:00",next_monday_date(),"00:00:00",41,?C_ESP_VOIX,"-","-1","-1"},
	 {opt_we_sms,mobi,all,"A",65,date(),"00:00:00",next_monday_date(),"23:59:59",10,?C_RDL_MUL,"-","-1","-1"},
%	 {opt_tv_v0,mobi,all,"A", 110,date(),"00:00:00",undefined,"-",41,?C_OPT_TV,"-","-1","-1"},
	 {opt_total_tv,mobi,all,"A",111,date(),"00:00:00",undefined,"-",41,?C_OPT_TOTAL_TV,"-","-1","-1"},
	 {opt_we_sms,cmo,all,"A",65,date(),"00:00:00",next_monday_date(),"23:59:59",10,?C_RDL_MUL,"-","-1","-1"},
	 {opt_we_voix,cmo,all,"A",23,date(),"00:00:00",next_monday_date(),"23:59:59",118,?C_WE_VOIX,"-","-1","-1"},
	 {opt_voice_unlimit,mobi,all,"A",143,date(),"00:00:00",undefined,"-",0,-1,"-","-1","0"},
	 {opt_sms_unlimit,mobi,all,"A",144,date(),"00:00:00",undefined,"-",0,-1,"-","-1","0"},
	 {opt_tv_unlimit,mobi,all,"A",145,date(),"00:00:00",undefined,"-",0,-1,"-","-1","0"},
	 {opt_surf_unlimit,mobi,all,"A",148,date(),"00:00:00",undefined,"-",0,-1,"-","-1","0"},
	 {opt_msn_mensu_mobi,mobi,all,"-",172,date(),"00:00:00",today_plus_datetime(31),"23:59:59",41,?C_MSN_OMWL_MOBI,"-","-1","-1"},
	 {opt_msn_journee_mobi,mobi,all,"A",157,date(),"00:00:00",date(),"23:59:59",41,?C_MSN_MOBI,"-","-1","-1"},
	 {winning_50sms,mobi,all,"A",160,undefined,"-",today_plus_datetime(7),"23:59:59",137,?C_50SMS_WINNING,"0","7500","0"},
	 {winning_50sms,cmo,all,"A",160,undefined,"-",today_plus_datetime(7),"23:59:59",137,?C_50SMS_WINNING_CMO,"0","7500","0"},
	 {fdj_pocket_winning,mobi,all,"A",161,undefined,"-",today_plus_datetime(31),"23:59:59",0,0,"0","0","0"},
	 {fdj_pocket_winning,cmo,all,"A",161,undefined,"-",today_plus_datetime(31),"23:59:59",0,0,"0","0","0"},
	 {opt_kdo_sinf,mobi,all,"A",158,date(),"00:00:00",undefined,"-",0,?C_BONS_PLANS,"-","-1","-1"},
	 {opt_sms_illimite,mobi,subscribe,"A",183,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_sms_illimite,cmo,subscribe,"A",183,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_sms_illimite,mobi,terminate,"S",183,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_tv_mensu,mobi,terminate,"S",184,date(),"00:00:00",undefined,"-",0,0,"-","0","0"},

	 {opt_zap_quoti,mobi,terminate,"S",173,date(),"00:00:00",undefined,"-",0,0,"-","-1","-1"},
	 {opt_tv_renouv,cmo,terminate,"S",184,date(),"00:00:00",undefined,"-",0,-1,"0","0","0"},
	 {opt_sport_mensu,mobi,terminate,"S",194,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_total_tv_mensu,mobi,terminate,"S",195,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_11_18,cmo,subscribe,"A",203,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},


%% Mobi Bons plans multimedia :
	 {opt_internet,        mobi,all,      "-",231,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_internet_max_journee,        mobi,subscribe,      "-",424,undefined,"00:00:00",undefined,"23:59:59",0,-1,"-","-1","-1"},
         {opt_internet_max_weekend,        mobi,subscribe,      "-",415,next_Saturday_date(),"00:00:00",next_Sunday_date(),"23:59:59",0,-1,"-","-1","-1"},
	 {opt_internet_v3,     mobi,all,      "-",400,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_internet_bis,    mobi,all,      "-",233,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_internet_max,    mobi,all,      "-",224,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_internet_max_v3, mobi,all,      "-",401,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_internet_max_bis,mobi,all,      "-",242,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_tv,              mobi,all,      "-",227,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_tv_max,          mobi,all,      "-",229,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_musique,         mobi,all,      "-",220,date(),"00:00:00",undefined,"-",0,-1,  "-","-1","-1"},
         {opt_musique_mix,     mobi,all,      "-",244,undefined,"-",undefined,"-",41,185,"-","-1","-1"},
	 {opt_musique_collection,mobi,all,    "-",427,undefined,"-",undefined,"-",0,-1,  "-","-1","-1"},
	 {opt_mail,            mobi,all,      "-",448,undefined,"-",undefined,"-",0,-1,  "-","-1","-1"},
	 {opt_foot_ligue1,     mobi,all      ,"-",271,date(),"00:00:00",undefined,"-",41,217,"-","-1","-1"},
         {opt_mes_donnees,     mobi,all,      "-",370,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},

%% CMO Bons plans multimedia :
%	 {opt_tv,              cmo,all,"-",       226,date(),"00:00:00",undefined,"-",41,87,  "-","-1","-1"},
%	 {opt_tv_max,          cmo,all,"-",       228,date(),"00:00:00",undefined,"-",41,88,  "-","-1","-1"},
%         {opt_musique_mix,     cmo,all,"-",       250,date(),"00:00:00",undefined,"-",41,185,"-","-1","-1"},
%	 {opt_musique_collection,cmo,all,"-",     426,date(),"00:00:00",undefined,"-",41,186,  "-","-1","-1"},
%	 {opt_internet,        cmo,all,"-",       230,date(),"00:00:00",undefined,"-",41,197,  "-","-1","-1"},
	 {opt_internet_bis,    cmo,subscribe,"A",       232,date(),"00:00:00",undefined,"-",0,-1,  "-","-1","-1"},
%	 {opt_internet_max,    cmo,all,"-",       223,date(),"00:00:00",undefined,"-",41,194, "-","-1","-1"},
	 {opt_internet_max_bis,cmo,subscribe,"A",       240,date(),"00:00:00",undefined,"-",0,-1,  "-","-1","-1"},
	 {opt_foot_ligue1,     cmo,all      ,"-",       271,date(),"00:00:00",undefined,"-",41,217,"-","-1","-1"},
	 {opt_foot_ligue1_0_5, cmo,all      ,"-",       305,date(),"00:00:00",undefined,"-",41,217,"-","-1","-1"}, 

	 {opt_orange_max,cmo,subscribe,"A",998,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_mes_vocale_visuelle,cmo,subscribe,"A",999,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_zap_zone,mobi,subscribe,"A",216,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_zap_zone_bis,mobi,subscribe,"A",211,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_cityzi,mobi,terminate,"S",46,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_cityzi,mobi,subscribe,"A",46,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {mobile_prize,mobi,subscribe,"A",161,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {mobile_prize,cmo,subscribe,"A",161,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {mobile_prize_2,mobi,subscribe,"A",85,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {mobile_prize_2,cmo,subscribe,"A",85,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_unik,mobi,subscribe,"A",18,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_unik,mobi,terminate,"S",18,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
         {opt_school_zone_a, cmo, all, "-", 281, date(), "00:00:00", undefined, "23:59:59",0,-1,"0","-1","-1"},
         {opt_school_zone_b, cmo, all, "-", 282, date(), "00:00:00", undefined, "23:59:59",0,-1,"0","-1","-1"},
         {opt_school_zone_c, cmo, all, "-", 283, date(), "00:00:00", undefined, "23:59:59",0,-1,"0","-1","-1"},
	 {opt_sinf_kdo,mobi,all,"A",43,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_sinf_kdo,cmo,all,"A",43,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_ssms_m6,mobi,all,"A",391,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_frais_maint,symacom,subscribe,"A",84,date(),"00:00:00",undefined,"-",0,0,"-","-1","-1"},
	 {opt_j_mm_ill,cmo,all, "-",325,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_s_mm_ill,cmo,all, "-",326,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_jsms_ill,cmo,all, "-",327,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_j_app_ill,cmo,all,"-",422,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_s_app_ill,cmo,all,"-",423,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
	 {opt_ssms_ill,cmo,all, "-",330,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"}
]++ option_params_list_more().

option_params_list_more() ->
    [
     {opt1_virg_30j,virgin_prepaid,all,check_opt_status,97,date(),"00:00:00",today_plus_datetime(31),"23:59:59",209,?C_OPTION_VIRGIN,from_conf_param,from_conf_param,"0"},
     {opt2_virg_30j,virgin_prepaid,all,check_opt_status,98,date(),"00:00:00",today_plus_datetime(31),"23:59:59",210,?C_OPTION_VIRGIN,from_conf_param,from_conf_param,"0"},
     {opt3_virg_30j,virgin_prepaid,all,check_opt_status,99,date(),"00:00:00",today_plus_datetime(15),"23:59:59",211,?C_OPTION_VIRGIN,from_conf_param,from_conf_param,"0"},
     {opt4_virg_30j,virgin_prepaid,all,check_opt_status,100,date(),"00:00:00",today_plus_datetime(45),"23:59:59",212,?C_OPTION_VIRGIN,from_conf_param,from_conf_param,"0"},
     {opt_data_gprs,virgin_prepaid,all,check_opt_status,96,date(),"00:00:00",today_plus_datetime(31),"23:59:59",208,?C_ORANGEX,from_conf_param,"3072","0"},
     {opt_data_gprs,virgin_comptebloque,all,check_opt_status,96,date(),"00:00:00",today_plus_datetime(31),"23:59:59",208,?C_ORANGEX,from_conf_param,"3072","0"},
     {opt_sms_200,virgin_comptebloque,all,check_opt_status,86,date(),"00:00:00",today_plus_datetime(31),"23:59:59",96,?OPT_SMS_200_VIRGIN_CB,from_conf_param,"5000","0"},
     {opt_sms_200,bzh_cmo,all,check_opt_status,86,date(),"00:00:00",today_plus_datetime(31),"23:59:59",96,?OPT_SMS_200_BZH_CB,from_conf_param,"5000","0"},
     {opt_5n_preferes,virgin_comptebloque,all,"-",451,undefined,"-",undefined,"-",346,?C_OPT_5N_PREFERES_VIRGIN_CB,"0","-1","-1"},
     {opt_sms_ill,virgin_comptebloque,all,check_opt_status,217,date(),"00:00:00",today_plus_datetime(31),"23:59:59",41,?OPT_SMS_ILL_VIRGIN_CB,from_conf_param,"10000","0"},
     {verysms,virgin_prepaid,terminate,"S",221,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {veryvoix,virgin_prepaid,terminate,"S",222,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {very4,virgin_prepaid,terminate,"S",338,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {verylong,virgin_prepaid,all,"-",407,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
%     {opt_mail,        cmo,all,"-",340,date(),"00:00:00",undefined,"-",41,270,  "-","-1","-1"},
     {opt_roxy,        cmo,subscribe,"-",316,date(),"00:00:00",undefined,"-",41,263,  "-","-1","-1"},
     {opt_nrj_data,nrj_comptebloque,all,"A",128,date(),"00:00:00",undefined,"-",156,163,  "-","-1","-1"},
     {opt_nrj_sms,nrj_comptebloque,all,"A",122,date(),"00:00:00",undefined,"-",154,164,  "-","-1","-1"},
     {opt_nrj_data_2mo,nrj_comptebloque,all,"A",386,date(),"00:00:00",undefined,"-",156,269,  "-","-1","-1"},
     {opt_nrj_data_4mo,nrj_comptebloque,all,"A",383,date(),"00:00:00",undefined,"-",156,269,  "-","-1","-1"},
	{opt_numpref_tele2,tele2_pp, all,"-",376,date(),"00:00:00",today_plus_datetime(31),"23:59:59",276,?C_TELE2_NUM_PREFERE,"-","-1","-1"},
     {opt_numpref_tele2,tele2_comptebloque, all,"-",376,date(),"00:00:00",today_plus_datetime(31),"23:59:59",276,?C_TELE2_NUM_PREFERE,"-","-1","-1"},
     {opt_3num_kdo_sms, cmo, all,"-",132,date(),"00:00:00",undefined,"-",0,105,  "-","-1","-1"},
     {ow_spo, cmo, all,"-",115,date(),"00:00:00",undefined,"-",0,89,  "-","-1","-1"},
     {opt_weinf_OW_TV, cmo, all,"-",68,date(),"00:00:00",undefined,"-",0,31,  "-","-1","-1"},
     {sms_opt_OW, cmo, all,"-",15,date(),"00:00:00",undefined,"-",0,11,  "-","-1","-1"},
     {opt_sms_7_5, cmo, all,"-",9,date(),"00:00:00",undefined,"-",0,12,  "-","-1","-1"},
     {opt_sms_12, cmo, all,"-",14,date(),"00:00:00",undefined,"-",0,12,  "-","-1","-1"},
     {opt_sms_18, cmo, all,"-",101,date(),"00:00:00",undefined,"-",0,12,  "-","-1","-1"},
     {opt_sms_25, cmo, all,"-",102,date(),"00:00:00",undefined,"-",0,12,  "-","-1","-1"},
     {opt_etudiante, cmo, all,"-",26,date(),"00:00:00",undefined,"-",0,37,  "-","-1","-1"},
     {ow_tv, cmo, all,"-",113,date(),"00:00:00",undefined,"-",0,87,  "-","-1","-1"},
     {ow_tv2, cmo, all,"-",114,date(),"00:00:00",undefined,"-",0,88,  "-","-1","-1"},
     {media_decouvrt, cmo, all,"-",11,date(),"00:00:00",undefined,"-",0,26,  "-","-1","-1"},
     {media_internet, cmo, all,"-",12,date(),"00:00:00",undefined,"-",0,26,  "-","-1","-1"},
     {media_internet_plus, cmo, all,"-",58,date(),"00:00:00",undefined,"-",0,26,  "-","-1","-1"},
     {opt_OW_10E, cmo, all,"-",13,date(),"00:00:00",undefined,"-",0,26,  "-","-1","-1"},
     {opt_OW_30E, cmo, all,"-",59,date(),"00:00:00",undefined,"-",0,26,  "-","-1","-1"},
     {osl, cmo, all,"-",10,date(),"00:00:00",undefined,"-",0,?C_WAP,  "-","-1","-1"},
     {opt_1h_ts_reseaux, cmo, all,"-",152,date(),"00:00:00",undefined,"-",0,?C_TS_RESEAUX,  "-","-1","-1"},
     {opt_five_min, cmo, all,"-",89,date(),"00:00:00",undefined,"-",0,71,  "-","-1","-1"},
     {opt_2numpref, cmo, all,"-",91,date(),"00:00:00",undefined,"-",0,78,  "-","-1","-1"},
     {opt_report, cmo, all,"-",41,date(),"00:00:00",undefined,"-",0,-1,  "-","-1","-1"},
     {ow_surf, cmo, all,"-",117,date(),"00:00:00",undefined,"-",0,91,  "-","-1","-1"},
     {ow_musique, cmo, all,"-",125,date(),"00:00:00",undefined,"-",0,?C_MUSIQUE,  "-","-1","-1"},
     {opt_sms_illimite, monacell_prepaid, subscribe,"A",394,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_sms_illimite, monacell_comptebloqu, subscribe,"A",442,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_sms_illimite_soir,cmo,all,"-",170,date(),"00:00:00",undefined,"-",41,?C_OPT_SMS_ILL_SOIR,"-","-1","-1"},
     {sms_illimite_18E,cmo,all,"-",449,undefined,"-",undefined,"-",41,309,"-","-1","-1"},
     {opt_bonus_multimedia,cmo,all,"-",249,date(),"00:00:00",undefined,"-",41,?C_OPT_BONUS_MULTIMEDIA_M6,"-","-1","-1"},
     {opt_bby_sms_illimite,cmo,all,"-",334,date(),"00:00:00",undefined,"-",41,?C_OPT_SMS_ILL_SOIR,"-","-1","-1"},
     {opt_double_jeu_pp,nrj_prepaid,all,"-",399,date(),"00:00:00",undefined,"-",41,285,  "-","-1","-1"},
     {opt_nrj_light,nrj_prepaid,all,"-",398,date(),"00:00:00",undefined,"-",153,284,  "-","-1","-1"},
     {opt_ssms_illimite,mobi,all, "A",391,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_jsms_illimite,mobi,all, "A",318,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_40sms_special_rsa,cmo,all, "-",405,date(),"00:00:00",undefined,"-",309,287,"-","-1","-1"},
     {opt_orange_sport,    mobi,all      ,"-",471,date(),"00:00:00",undefined,"-",41,332,"-","-1","-1"},
     {opt_bordeaux,        mobi,all      ,"-",409,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_lens,            mobi,all      ,"-",410,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_lyon,            mobi,all      ,"-",411,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_marseille,       mobi,all      ,"-",412,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_paris,           mobi,all      ,"-",413,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_10mn_europe,     mobi,all      ,"A",406,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_10mn_europe,     cmo,all      ,"A",406,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_saint_etienne,   mobi,all      ,"-",414,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_usages_commnunault,cmo,all, "-",420,date(),"00:00:00",undefined,"-",41,?C_FORF_M6_USAGES_COMMUNAULT,"-","-1","-1"},
     {opt_adfunded_sms_mensuel, mobi,all,"-",433,date(),"00:00:00",undefined,"-",335,302,"-","-1","-1"},
     {opt_adfunded_sms_cumul,   mobi,all,"-",434,date(),"00:00:00",undefined,"-",335,303,"-","-1","-1"},
     {opt_bonus_appels,         mobi,subscribe,"A",435,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_appels,         mobi,terminate,"S",435,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS,"-","-1","-1"},
     {opt_bonus_sms,            mobi,subscribe,"A",436,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_sms,            mobi,terminate,"S",436,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS,"-","-1","-1"},
     {opt_bonus_sms_illimite,   mobi,terminate,"S",436,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS_SMS,"-","-1","-1"},
     {opt_bonus_internet,       mobi,subscribe,"A",437,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_internet,       mobi,terminate,"S",437,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS,"-","-1","-1"},
     {opt_bonus_appels_etranger,mobi,subscribe,"A",438,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_appels_etranger,mobi,terminate,"S",438,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS,"-","-1","-1"},
     {opt_bonus_europe,         mobi,subscribe,"A",439,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_europe,         mobi,terminate,"S",439,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS,"-","-1","-1"},
     {opt_bonus_maghreb,        mobi,subscribe,"A",440,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_maghreb,        mobi,terminate,"S",440,undefined,"00:00:00",undefined,"-",0,?C_MOBI_BONUS,"-","-1","-1"},
     {opt_bonus_appels_promo,         mobi,subscribe,"A",435,undefined,"00:00:00",undefined,"-",328,?C_MOBI_BONUS,"-","24000","0"},
     {opt_bonus_sms_promo,            mobi,subscribe,"A",436,undefined,"00:00:00",undefined,"-",41,?C_MOBI_BONUS_SMS,"-","10000","0"},
     {opt_bonus_internet_promo,       mobi,subscribe,"A",437,undefined,"00:00:00",undefined,"-",328,?C_MOBI_BONUS,"-","24000","0"},
     {opt_bonus_appels_etranger_promo,mobi,subscribe,"A",438,undefined,"00:00:00",undefined,"-",328,?C_MOBI_BONUS,"-","24000","0"},
     {opt_bonus_europe_promo,         mobi,subscribe,"A",439,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_bonus_maghreb_promo,        mobi,subscribe,"A",440,undefined,"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_unik_data_pour_zap, cmo, all, "-", 377, date(),"00:00:00", undefined,"-",41,277,"-", "-1", "-1"},
     {opt_dte_plus, mobi, terminate, "S", 7, date(),"00:00:00", undefined,"-",0,-1,"-","-1","-1"},
	 {opt_illimite_kdo_v2,mobi,terminate,"S",166,date(),"00:00:00",undefined,"-",41,?C_ILLIMITE_KDO,"-","-1","-1"},
     {opt_musique_mensu,mobi,terminate,"S",193,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pass_voyage_6E,mobi,subscribe,"A",294,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pass_voyage_6E,cmo,subscribe,"A",294,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_j_tv_max_ill,cmo,all,"-",464,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_s_tv_max_ill,cmo,all,"-",465,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_avan_dec_zap_zone,cmo,subscribe,"A",476,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_avan_dec_zap_zone,mobi,subscribe,"A",477,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_avan_dec_zap_zone,mobi,terminate,"S",477,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_10mn_quotidiennes,mobi,subscribe,"A",467,date(),"00:00:00",date(),"23:59:59",0,329,"-","-1","-1"},
     {opt_10mn_quotidiennes,mobi,terminate,"S",467,date(),"00:00:00",date(),"23:59:59",0,-1,"0","0","0"},
     {opt_30mn_hebdomadaires,mobi,subscribe,"A",466,date(),"00:00:00",date(),"23:59:59",0,329,"-","-1","-1"},
     {opt_30mn_hebdomadaires,mobi,terminate,"S",466,date(),"00:00:00",date(),"23:59:59",0,-1,"0","0","0"},
     {opt_30_sms_mms,mobi,subscribe,"A",109,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_30_sms_mms,mobi,terminate,"S",109,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     %% CMO Bons plans KDO
     {opt_j_mm_ill_kdo_bp,cmo,all, "-",325,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_s_mm_ill_kdo_bp,cmo,all, "-",326,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_jsms_ill_kdo_bp,cmo,all, "-",327,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_j_app_ill_kdo_bp,cmo,all,"-",422,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_s_app_ill_kdo_bp,cmo,all,"-",423,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_ssms_ill_kdo_bp,cmo,all, "-",330,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_j_tv_max_ill_kdo_bp,cmo,all, "-",464,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_s_tv_max_ill_kdo_bp,cmo,all, "-",465,date(),"00:00:00",undefined,"-",0,-1,"0","-1","-1"},
     {opt_j_omwl_kdo_bp,cmo,all,"A",157,date(),"00:00:00",date(),"23:59:59",0,-1,"-","-1","-1"},
     {opt_pack_ado,mobi,subscribe,"A",293,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pack_duo_journee,mobi,subscribe,"A",443,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pass_voyage_9E,mobi,subscribe,"A",357,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pass_voyage_9E,cmo,subscribe,"A",357,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_internet_max_pp,mobi,all,"-",295,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_internet_v2_pp,mobi,all,"-",297,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_internet_v3_pp,mobi,all,"-",402,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pass_dom,mobi,subscribe,"A",456,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_pass_dom,cmo,subscribe,"A",456,date(),"00:00:00",undefined,"-",0,-1,"-","-1","-1"},
     {opt_jeu,mobi,subscribe,"A",472,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_jeu,cmo,subscribe,"A",472,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_jeu_tirage,mobi,subscribe,"A",85,undefined,"-",undefined,"-",0,-1,"-","-1","-1"},
     {opt_jeu_tirage,cmo,subscribe,"A",85,undefined,"-",undefined,"-",0,-1,"-","-1","-1"}
    ].
