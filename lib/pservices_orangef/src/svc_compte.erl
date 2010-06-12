-module(svc_compte).

%%%% XML API
-export([print_solde/2,
	 print_solde/3,
	 print_solde_euro_centime/2,
	 print_solde_1_cipher/2,
	 print_solde_hour_min/2,
	 print_solde_min/2,
	 print_solde_min_sec/2,
	 print_solde_min_sec_with_format/3,
	 print_solde_hour_min_sec/2,
	 print_bonus/1,
	 print_debut_promo/2,
	 print_fin_promo/3,
	 print_next_credit/2,
	 print_next_credit/3,
	 print_fin_credit/2,
	 print_fin_credit_default/3,
	 print_fin_credit/3,
	 print_fin_credit_type/4,
	 get_credit/3,
	 get_end_credit/3,
	 get_cpte_from_list/2,
	 ratio_mnesia/4]).

%%%% API
-export([etat_cpte/2,
	 solde_cpte/2,
	 is_transfert_credit_enable/1,
         add_compte/3,
	 decode_compte/2,
	 decode_z60/2,
	 decode_z70/2,
	 decode_z80/2,
	 decode_ntrd/2,
	 calcul_solde/2,
	 cpte/2,
	 dcl/1,
	 ptf_num/2,
	 ratio/4,
	 search_cpte/2,
	 update_sdp_user_state/5,
	 set_cpte_to_list/3
	]).

%%%% Export for plugins
-export([print_cpte/1,
	 print_cpte/4
	]).

-include("../include/ftmtlv.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO PRINT INFORMATION IN XML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde(session(),Cpte::string(),UNT_REST::string())-> 
%%                   [{pcdata,string()}].
%%%% Print account credit in unit defined by parameter UNT_REST.

print_solde(abs,Cpte,"sms")->
    [{pcdata,"XXX"}];
print_solde(abs,Cpte,"sms_p")->
    [{pcdata,"XXX"}];
print_solde(abs,Cpte,"mms")->
    [{pcdata,"XXX"}];
print_solde(abs,Cpte,"euro")->
    [{pcdata,"YYY.YY"}];
print_solde(abs,Cpte,"euro_p")->
    [{pcdata,"YYY.Y"}];
print_solde(abs,Cpte,"min")->
    [{pcdata,"XXXminYYsec"}];
print_solde(abs,Cpte,"min_p")->
    [{pcdata,"XXXminYYsec"}];
print_solde(abs,Cpte,"ko")->
    [{pcdata,"XXX Ko"}];

print_solde(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte,"min")->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
	#compte{etat=E}=Compte when E==?CETAT_EP;E==?CETAT_PE ->
	    [{pcdata, "0min0sec"}];
	#compte{}=Compte->
	    %%Compte must be in euros here
	    print_solde_min_sec(Session,Cpte);
	undefined ->
	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
	    [{pcdata,"inconnu"}];
	_ ->
	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end;

print_solde(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,
	    Cpte,UNT_REST)->
    %%%% G1R6 use the ptf_num of cpte
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
	#compte{}=Compte->
	    [{pcdata, print_cpte(dcl(State),Compte,UNT_REST,MSISDN)}];
	undefined ->
	     slog:event(internal,?MODULE,undefined_print_solde,
			{Cpte,UNT_REST}),
	    [{pcdata,"inconnu"}];
	_ ->
	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,UNT_REST,MSISDN}),
	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde(session(),Cpte::string())-> 
%%                   [{pcdata,string()}].
%%%% Print account credit in unit defined by #compte.unt_num.

print_solde(abs,Cpte) when Cpte=="forf_smsx";
 			   Cpte=="forf_smsy";
 			   Cpte=="forf_sms";
 			   Cpte=="cpte_sms";
 			   Cpte=="cpte_asms";
 			   Cpte=="cpte_sms_noel"->
    [{pcdata,"XXX"}];
print_solde(abs,Cpte) when Cpte=="cpte_princ";
			   Cpte=="cpte_aeuros"->
    [{pcdata,"YYY.YY"}];
print_solde(abs,Cpte)->
    [{pcdata,"YYY.YY"}];


print_solde(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)
  when Cpte=="forf_carrefour_z1";
       Cpte=="forf_carrefour_z2";
       Cpte=="forf_carrefour_z3" ->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
 	#compte{}=Compte->
	    [{pcdata,print_cpte(Compte)}];
	_ ->
	    [{pcdata,"0"}]  
    end;

print_solde(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
 	#compte{}=Compte->
 	    [{pcdata,print_cpte(Compte)}];
 	undefined ->
 	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
 	    [{pcdata,"inconnu"}];
 	_ ->
 	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde_euro_centime(session(),Cpte::atom())->
%%                       string().
%%%% Print account credit in euros and centimes.

print_solde_euro_centime(abs,Cpte)->    
    [{pcdata,"XX euros YY"}];
print_solde_euro_centime(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
        #compte{unt_num=?EURO,cpp_solde=SOLDE}=Compte->
	    CR = currency:print(currency:to_euro(SOLDE)),
            [Euros,Centimes] = string:tokens(CR,"."),
            [{pcdata,Euros++" euros "++Centimes}];
        undefined ->
            slog:event(internal,?MODULE,undefined_print_solde,Cpte),
            [{pcdata,"inconnu"}];
        _ ->
            slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
            [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde_1_cipher(session(),Cpte::atom())->
%%                       string().
%%%% Print account credit with 1 cipher in the right hand.

print_solde_1_cipher(abs,Cpte)->    
    [{pcdata,"XX.X"}];
print_solde_1_cipher(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
        #compte{cpp_solde=SOLDE}=Compte->
	    CR = currency:print(currency:to_euro(SOLDE)),
	    Len = string:len(CR)-1,
	    CR1 = lists:sublist(CR,Len),
	    [{pcdata,lists:flatten(CR1)}];
        undefined ->
            slog:event(internal,?MODULE,undefined_print_solde,Cpte),
            [{pcdata,"inconnu"}];
        _ ->
            slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
            [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde_hour_min(session(),Cpte::atom())->
%%                       string().
%%%% Get account credit in hours and minutes.

print_solde_hour_min(abs,Cpte)->    
    [{pcdata,"XhYYmin"}];

print_solde_hour_min(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)
when Cpte=="cpte_mobi_bonus"->
    State=svc_util_of:get_user_state(Session),
    DCL = dcl(State),
    case {DCL,cpte(State,list_to_atom(Cpte))} of
 	{?mobi_janus,#compte{ptf_num=328}=Compte}->
	    {Session1,Opt}=svc_of_plugins:get_actived_bonus_option(Session),
	    Prix_min=
		case Opt of 
		    opt_bonus_internet->100/1000;
		    opt_bonus_europe->  600/1000;
		    opt_bonus_maghreb-> 600/1000;
		    _->300/1000
		end,
 	    [{pcdata,print_hour_min(dcl(State),Compte,Prix_min)}];
	{_,#compte{}=Compte}->
            Prix_min=price_in_min(dcl(State),Compte),
 	    [{pcdata,print_hour_min(dcl(State),Compte,Prix_min)}];
 	{_,undefined} ->
 	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
 	    [{pcdata,"inconnu"}];
 	{_,_} ->
 	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end;

print_solde_hour_min(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
        #compte{}=Compte->
            Prix_min=price_in_min(dcl(State),Compte),
            [{pcdata,print_hour_min(dcl(State),Compte,Prix_min)}];
        undefined ->
            slog:event(internal,?MODULE,undefined_print_solde,Cpte),
            [{pcdata,"inconnu"}];
        _ ->
            slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
            [{pcdata,"inconnu"}]
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde_min(session(),Cpte::atom())->
%%                       string().
%%%% Get account credit in minutes.

print_solde_min(abs,Cpte)->
    [{pcdata,"XXXmin"}];

print_solde_min(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
 	#compte{}=Compte->
 	    Prix_min=price_in_min(dcl(State),Compte),
 	    [{pcdata,print_min(dcl(State),Compte,Prix_min)}];
	undefined ->
	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
	    [{pcdata,"inconnu"}];
	_ ->
	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
	    [{pcdata,"inconnu"}]
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde_min_sec(session(),Cpte::atom())->
%%                       [{pcdata,string()}].
%%%% Print account credit in minutes and seconds.
%%%% Used in selfcare light.

print_solde_min_sec(abs,Cpte)->
    [{pcdata,"XXXminYYsec"}];

print_solde_min_sec(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
 	#compte{}=Compte->
 	    Prix_min=price_in_min(dcl(State),Compte),
 	    [{pcdata,print_min_sec(dcl(State),Compte,Prix_min)}];
 	undefined ->
 	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
 	    [{pcdata,"inconnu"}];
 	_ ->
 	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_solde_min_sec_with_format(session(),Cpte::atom(),Format)->
%%                       [{pcdata,string()}].
%%%% Print account credit in minutes and seconds with format.

print_solde_min_sec_with_format(abs,Cpte,Format)->
    [{pcdata,"XXXmn YYsec"}];

print_solde_min_sec_with_format(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte,Format)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
 	#compte{}=Compte->
 	    Prix_min=price_in_min(dcl(State),Compte),
 	    [{pcdata,print_min_sec_with_format(dcl(State),Compte,Prix_min,Format)}];
 	undefined ->
 	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
 	    [{pcdata,"inconnu"}];
 	_ ->
 	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end.

print_solde_hour_min_sec(abs,Cpte)->
    [{pcdata,"XXXhYYminZZsec"}];

print_solde_hour_min_sec(#session{prof=#profile{msisdn=MSISDN}=Prof}=Session,Cpte)->
    State=svc_util_of:get_user_state(Session),
    case cpte(State,list_to_atom(Cpte)) of
 	#compte{}=Compte->
 	    Prix_min=price_in_min(dcl(State),Compte),
 	    [{pcdata,print_hour_min_sec(dcl(State),Compte,Prix_min)}];
 	undefined ->
 	    slog:event(internal,?MODULE,undefined_print_solde,Cpte),
 	    [{pcdata,"inconnu"}];
 	_ ->
 	    slog:event(failure,?MODULE,unknown_cpte,{Cpte,MSISDN}),
 	    [{pcdata,"inconnu"}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_bonus(session())->
%%                   [{pcdata,string()}].
%%%% Print % bonus.

print_bonus(abs)->
    [{pcdata,"XX"}];

print_bonus(Session)->
    State=svc_util_of:get_user_state(Session),
    Cpte_Ref=
 	case State#sdp_user_state.declinaison of
 	    X when X==?mobi;X==?cpdeg;X==?ppola;X==?ppol2->
		cpte(State,cpte_princ);
	    X when X==?ppol1;X==?ppol3;X==?ppol4->
		cpte(State,cpte_forf);
	    ?pmu ->
		cpte(State,forf_pmu);
	    ?ppolc ->
		cpte(State,forf_hc);
	    X when X==?fmu_18;X==?fmu_24 ->
		cpte(State,forf_fmu);
	    ?cmo_sl ->
		cpte(State,forf_cmosl);
 	    _->
 		cpte(State,cpte_princ)
 	end,
    PCT=Cpte_Ref#compte.pct,
    Cr_PCT=io_lib:format("~p", [PCT]),
    [{pcdata, lists:flatten(Cr_PCT)}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_debut_promo(session(),Cpte::string())->
%%                         [{pcdata,string()}].
%%%% Print the start date of the promotion.

print_debut_promo(abs,_)->
    [{pcdata, "JJ/MM/AA"}];

print_debut_promo(Session,Cpte)
  when Cpte=="cpte_rdl_sms" ->
    State=svc_util_of:get_user_state(Session),
    case get_cpte_from_list(State,
			    list_to_atom(Cpte)) of
	#compte{dlv=0}->
	    slog:event(internal,?MODULE,pb_in_print_debut_promo,dlv_null),
	    [{pcdata, "inconnu"}];
	#compte{dlv=Dlv,rnv=RNV_NUM}=Compte->
	    %%the beginning of the promo is the end of the promo minus
	    %%1 day (seconds) at 21h30
	    New_dlv = Dlv-(24*3600),
	    {{Y,Mo,D},{H,Mi,S}} =
		calendar:now_to_local_time({New_dlv div 1000000,
					    New_dlv rem 1000000,0}),
	    DatePromo = pbutil:sprintf("%02d/%02d", [D,Mo]),
	    TimePromo = pbutil:sprintf("%02d/%02d", [21,30]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}];
	E ->
	    slog:event(internal,?MODULE,pb_in_print_debut_credit,E),
	    [{pcdata, "inconnu"}]
    end;

print_debut_promo(Session,Cpte)
  when Cpte=="cpte_rdl_mult" ->
    State=svc_util_of:get_user_state(Session),
    %%the beginning of the promo is the next saturday at 00h00 if week day
    %%and the previous saturday at 00h00 if week-end.
    Now = pbutil:unixtime(),
    {{Y,Mo,D},{H,Mi,S}} = calendar:now_to_local_time({Now div 1000000,
						      Now rem 1000000,0}),
    WeekDay = calendar:day_of_the_week(Y,Mo,D),
    case WeekDay of
	X when X>=6 -> % saturday or sunday
	    DateBegin = Now-((WeekDay-6)*24*3600),
	    {{Year,Month,Day},Time} = 
		calendar:now_to_local_time({DateBegin div 1000000,
					    DateBegin rem 1000000,0}),
	    DatePromo = pbutil:sprintf("%02d/%02d", [Day,Month]),
	    TimePromo = pbutil:sprintf("%02d/%02d", [0 ,0]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}];
	_ ->
	    NbDays = 6-WeekDay,
	    DateBegin = Now+(NbDays*24*3600),
	    {{Year,Month,Day},Time} =
		calendar:now_to_local_time({DateBegin div 1000000,
					    DateBegin rem 1000000,0}),
	    DatePromo = pbutil:sprintf("%02d/%02d", [Day,Month]),
	    TimePromo = pbutil:sprintf("%02d/%02d", [0 ,0]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_fin_promo(session(),Cpte::string(),Subscr::string())-> 
%%                       [{pcdata,string()}].
%%%% Print the end date of the promotion.

print_fin_promo(abs,_,_)->
    [{pcdata, "JJ/MM/AA"}];

print_fin_promo(Session,Cpte,Subsrc)
  when Cpte=="cpte_rdl_sms"->
    State=svc_util_of:get_user_state(Session),
    case get_cpte_from_list(State,
			    list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}=Compte->
	    {{Y,Mo,D},{H,Mi,S}} = 
		calendar:now_to_local_time({DLV div 1000000, 
					    DLV rem 1000000,0}),
	    Date = pbutil:sprintf("%02d/%02d", [D,Mo]),
	    Time = pbutil:sprintf("%02d/%02d", [H,Mi]),
	    [{pcdata, lists:flatten(Date)++" a "++lists:flatten(Time)}];
 	E->
 	    slog:event(internal,?MODULE,pb_in_print_fin_promo,E),
 	    [{pcdata, "inconnu"}]
    end;

print_fin_promo(Session,Cpte,Subscr)
  when Cpte=="cpte_rdl_mult"->
    State=svc_util_of:get_user_state(Session),
    Now = pbutil:unixtime(),
    {{Y,Mo,D},{H,Mi,S}} = calendar:now_to_local_time({Now div 1000000,
						      Now rem 1000000,0}),
    WeekDay = calendar:day_of_the_week(Y,Mo,D),
    DateEnd = Now+((7-WeekDay)*24*3600),
    {{Year,Month,Day},Time} =
	calendar:now_to_local_time({DateEnd div 1000000, 
				    DateEnd rem 1000000,0}),
    case list_to_atom(Subscr) of
	mobi ->
	    %%the end of the promo is the next sunday DD/MM/YYYY
	    DatePromo = pbutil:sprintf("%02d/%02d/%04d", [Day,Month,Year]),
	    [{pcdata, lists:flatten(DatePromo)}];
	cmo ->
	    %%the end of the promo is the next sunday at 23h59
	    DatePromo = pbutil:sprintf("%02d/%02d", [Day,Month]),
	    TimePromo = pbutil:sprintf("%02d/%02d", [23 ,59]),
	    [{pcdata, lists:flatten(DatePromo)++" a "
	      ++lists:flatten(TimePromo)}]
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_next_credit(session(), Compte::string(),string())->
%%                         [{pcdata,string()}].
%%%% Print date of next available credit.

print_next_credit(abs,_,_)->
    [{pcdata, "JJ/MM/AA"}];    
print_next_credit(#session{prof=#profile{msisdn=MSISDN}}=Session,
		  Compte,Format)->
    Subscription = svc_util_of:get_souscription(Session),
    case end_of_credit(Session, {Subscription, MSISDN}, unix_time, "dmy") of
	error ->
	    print_fin_credit_type(Session,Compte,"rnv",Format);
	Date_UT ->
	    DateTime = 
		calendar:now_to_local_time({Date_UT div 1000000,
					    Date_UT rem 1000000,
					    0}),
	    Date = svc_util_of:sprintf_datetime_by_format(DateTime,Format), 
	    [{pcdata, lists:flatten(Date)}]
    end.

%% +type print_next_credit(session(),string())->[{pcdata,string()}].
%%%% For Compatibility reason.

print_next_credit(abs,_)->  
     [{pcdata, "JJ/MM/AA"}];
print_next_credit(Session,Compte)->
    print_next_credit(Session,Compte,"dmy").
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_fin_credit_default(session(),Cpte::string(),Format::string())-> 
%%                        [{pcdata,string()}].
%%%% Print credit end date for the account.

print_fin_credit_default(abs,_,Fmt)->
    [{pcdata, "JJ/MM/AA"}];

print_fin_credit_default(#session{prof=#profile{msisdn=MSISDN}}=Session,
			 Cpte,Fmt)->
    Subscription = svc_util_of:get_souscription(Session),
    State=svc_util_of:get_user_state(Session),
    case get_cpte_from_list(State,
			    list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
	    case RNV_NUM of
		50 -> %%%SMS quoti
		    case end_of_credit(Session, {Subscription, MSISDN},
				       unix_time,Fmt) of
			error -> 
			    [{pcdata, "inconnu"}];
			Date_UT ->
			    [{pcdata, end_of_credit_date(Date_UT, Fmt)}]
		    end;
		_ ->
		    [{pcdata,end_of_credit(Session, DLV,RNV_NUM,Fmt)}]
	    end;
 	E->
 	    slog:event(failure,?MODULE,pb_in_print_fin_credit,
		       {E,Cpte,MSISDN}),
 	    [{pcdata, "inconnu"}]
    end.

%%%For compatibility reason. 
print_fin_credit(abs,_)->
    [{pcdata, "JJ/MM/AA"}];
print_fin_credit(Session,Cpte) ->
    print_fin_credit_default(Session,Cpte,"dmy").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_fin_credit_type(session(),Cpte::string(),Type::string(),
%%                        Format::string()) -> [{pcdata,string()}].
%%%% Print the last validity date (DLV) or renewal date (RNV)
%%%% of the credit for the account.
print_fin_credit_type(abs,_,_,_)->
    [{pcdata, "JJ/MM/AA"}];

print_fin_credit_type(#session{prof=#profile{msisdn=MSISDN}}=Session,
		      Cpte,"jma",Format)->
    State=svc_util_of:get_user_state(Session),
    case get_cpte_from_list(State,
			    list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
	    [JJ,MM,AA] = string:tokens(end_of_credit(Session, DLV,0,Format),"/"),
	    Data = atom_to_list(svc_util_of:mois_int2atom(list_to_integer(MM))),
 	    [{pcdata, JJ++" "++Data++" "++AA}];
 	E->
 	    slog:event(failure,?MODULE,pb_in_print_fin_credit,
		       {E,Cpte,MSISDN}),
 	    [{pcdata, "inconnu"}]
    end;

print_fin_credit_type(#session{prof=#profile{msisdn=MSISDN}}=Session,
		      Cpte,"dlv",Format)->
    State=svc_util_of:get_user_state(Session),
    case get_cpte_from_list(State,
			    list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
 	    [{pcdata, end_of_credit(Session, DLV,0,Format)}];
 	E->
 	    slog:event(failure,?MODULE,pb_in_print_fin_credit,
		       {E,Cpte,MSISDN}),
 	    [{pcdata, "inconnu"}]
    end;

print_fin_credit_type(#session{prof=#profile{msisdn=MSISDN}}=Session,
		      Cpte,"rnv",Format)->
    State=svc_util_of:get_user_state(Session),
    case get_cpte_from_list(State,
			    list_to_atom(Cpte)) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
 	    [{pcdata, end_of_credit(Session, DLV,RNV_NUM,Format)}];
 	E->
	    slog:event(failure,?MODULE,pb_in_print_fin_credit,
		       {E,Cpte,MSISDN}),
 	    [{pcdata, "inconnu"}]
    end.

%%%For compatibility reason. 
print_fin_credit(abs,_,_)->
    [{pcdata, "JJ/MM/AA"}];
print_fin_credit(Session,Cpte,Type) ->
    print_fin_credit_type(Session,Cpte,Type,"dmy").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEW INTERFACE USED IN TEXT_xxxx FILES:
%% FUNCTIONS TO PRINT INFORMATION IN XML AND ONLINE TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_credit(State::sdp_user_state,Cpte::atom(),
%%                  UNT_REST::string())-> 
%%                  string().
%%%% Get account credit in unit defined by parameter UNT_REST.

get_credit(State, Cpte, "min") ->
    case cpte(State, Cpte) of
	#compte{etat=E}=Compte when E==?CETAT_EP;E==?CETAT_PE ->
	    "0min0sec";
	#compte{}=Compte->
	    %%Compte must be in euros here
	    Prix_min=price_in_min(dcl(State),Compte),
	    print_min(dcl(State),Compte,Prix_min);
	Other ->
	    slog:event(internal,?MODULE,no_compte_get_credit,{Cpte, Other}),
	    "inconnu"
    end;

get_credit(State, Cpte, UNT_REST) ->
    case cpte(State, Cpte) of
	#compte{}=Compte->
	    print_cpte(dcl(State),Compte,UNT_REST,unknown_msisdn);
	Other ->
	    slog:event(internal,?MODULE,no_compte_get_credit,
		       {Cpte,UNT_REST,Other}),
	    "inconnu"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_end_credit(State::sdp_user_state(),Cpte::atom(),
%%                      Fmt::string())-> 
%%                      string().
%%%% Get credit end date for the account.

get_end_credit(State,Cpte,Fmt)->
    Session = #session{},
    Session_bidon = svc_util_of:update_user_state(Session, State),
    case get_cpte_from_list(State, Cpte) of
 	#compte{dlv=DLV,rnv=RNV_NUM}->
	    end_of_credit(Session_bidon, DLV,RNV_NUM,Fmt);
 	E->
 	    slog:event(internal,?MODULE,no_compte_get_end_credit,E),
 	    "inconnu"
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API INTERFACE - EXPORT FUNCTIONS USED BY OTHER MODULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO GET INFORMATION FROM RECORD COMPTE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type etat_cpte(sdp_user_state(),CPTE::atom())->
%%                 undefined | 1 | 2 | 3.
%%%% Return the state of the account.

etat_cpte(#sdp_user_state{}=State, CPTE)
  when atom(CPTE) ->
    case cpte(State, CPTE) of
	#compte{}=Compte->
	    Compte#compte.etat;
	_->
	    undefined
    end;

etat_cpte(State, CPTE) ->
    undefined.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type solde_cpte(sdp_user_state(),CPTE::atom())->
%%                  currency:sum().
%%%% Return the currency (euro, frf) and the amount of credit.

solde_cpte(#sdp_user_state{}=State, CPTE=cpte_m6_soiree_sms) ->
    Solde_dispo = solde_cpte(State, cpte_m6_soiree_sms_dispo),
    Solde_recharge = solde_cpte(State, cpte_m6_soiree_sms_recharge),
    case Solde_dispo of
	{sum,euro,0} -> Solde_recharge;
	_ -> Solde_dispo
    end;

solde_cpte(#sdp_user_state{}=State, CPTE)
  when atom(CPTE) ->
    case cpte(State,CPTE) of
	#compte{}=Compte->
	    Compte#compte.cpp_solde;
	_->
	    currency:sum(euro,0)
    end;

solde_cpte(State,CPTE)->
    currency:sum(euro,0).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_transfert_credit_enable(sdp_user_state(),CPTE::atom())->
%%                  atom().
%%%% Return if transfert credit is enabled.

is_transfert_credit_enable(#sdp_user_state{}=State) ->
    case solde_cpte(State, cpte_princ) of
	{sum,euro,Credit} ->
	    Credit >= 45000;
	_ -> false
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type cpte(sdp_user_state(),CPTE::atom())->
%%            compte().
%%%% Return the account.

cpte(#sdp_user_state{}=State,CPTE=cpte_princ) ->
    State#sdp_user_state.cpte_princ;

cpte(#sdp_user_state{}=State,CPTE) 
  when atom(CPTE) ->
    get_cpte_from_list(State,CPTE);

cpte(State, Cpte)->
    slog:event(warning, ?MODULE, fail_get_cpte_from_state, {State, Cpte}),
    undefined.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type ptf_num(sdp_user_state(),Cpte::atom())-> 
%%               integer().
%%%% Return PTF_NUM of the account.

ptf_num(State,Cpte) ->
    case cpte(State,Cpte) of
	#compte{ptf_num=PTF}->
	    PTF;
	E->
	    exit({no_compte_in_state,Cpte,State})
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO GET INFORMATION FROM RECORD SDP_USER_STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type dcl(sdp_user_state())->
%%           integer().
%%%% Return DCL_NUM of the account.

dcl(#sdp_user_state{declinaison=DCL})->
    DCL.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS TO CALCULATE THE RATIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type ratio(DCL_NUM::integer(),TCP_NUM::integer(),PTF_NUM::integer(),
%%             UNT_REST::atom())->
%%             float().
%%%% The ratio is in MNESIA RATIO TABLE.

ratio(DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST)->
    case catch ratio_mnesia(DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST) of
 	X when float(X)->
 	    X;
 	_ ->
 	    %% default
 	    1
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type ratio_mnesia(DCL_NUM::integer(),TCP_NUM::integer(),PTF_NUM::integer(),
%%                    UNT_REST::atom())->
%%                    float().
%%%% Get the ratio from MNESIA RATIO TABLE.

ratio_mnesia(DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST)
  when integer(UNT_REST) ->
    F = fun () -> recup_ratio({DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST}) end,
    {atomic, E} = mnesia:transaction(F),
    E;

ratio_mnesia(DCL_NUM,TCP_NUM,PTF_NUM,UNT_REST)
  when atom(UNT_REST) ->
    ratio_mnesia(DCL_NUM,TCP_NUM,PTF_NUM,atom_to_int(UNT_REST)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type calcul_solde(CPP::integer(),UNT::integer())-> 
%%                    currency:currency() | integer().
%%%% Calculate credit and return currency (euro, frf) and credit.

calcul_solde(CPP,?FRANC)->
    currency:sum(frf,CPP/1000);

calcul_solde(CPP,?EURO) ->
    currency:sum(euro,CPP/1000);

calcul_solde(CPP,_) ->
    round(CPP/1000).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type decode_compte(L::term(),sdp_user_state())->
%%                     sdp_user_state().

decode_compte(L,State)->
     decode_compte_v2(L,State).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type decode_z60(term(),sdp_user_state())->
%%                  sdp_user_state().

decode_z60([[TCP_NUM,UNT_NUM,CPP_SOLDE,DLV,RNV,ECP_NUM,
	     PTF_NUM,CPP_CUMUL,PCT,ANC,MNT_INIT,TOP_NUM,MNT_BON]|T],State)->
    Compte=#compte{tcp_num=TCP_NUM,
 		   unt_num=UNT_NUM,
 		   cpp_solde=calcul_solde(CPP_SOLDE,UNT_NUM),
		   dlv=DLV,
 		   rnv=RNV,
 		   etat=ECP_NUM,
 		   ptf_num=PTF_NUM,
 		   cpp_cumul_credit=calcul_solde(CPP_CUMUL,UNT_NUM),
 		   pct=PCT,
 		   anciennete=ANC,
 		   mnt_init=MNT_INIT,
 		   top_num=TOP_NUM,
 		   mnt_bonus=calcul_solde(MNT_BON,UNT_NUM)},
    State2=add_compte(TCP_NUM,Compte,State),
    decode_z60(T,State2);

decode_z60(L_VIDE,State) when L_VIDE==[];L_VIDE==[[]]->
    State;

decode_z60(S,State) when length(S)>1 ->
    slog:event(warning, ?MODULE, unknown_z60_state,S),
    State.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type decode_z70(term(),sdp_user_state())->
%%                  sdp_user_state().


decode_z70(Zone70,State)->
    decode_z70(Zone70,State,[]).

decode_z70([[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
	     OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT]|T],State,ACC)->
    Option_state = case OPT_INFO2 of
		       "S" ->
			   suspend;
		       _ ->
			   actived
		   end,
    %% To adapt with Tuxedo format
    Top_num_int = if list(TOP_NUM) -> list_to_integer(TOP_NUM);
                     true -> TOP_NUM
                  end,
    decode_z70(T,State,ACC++[{Top_num_int, Option_state}]);

decode_z70(L_VIDE,#sdp_user_state{options=OPTIONS}=State,ACC) when L_VIDE==[];L_VIDE==[[]]->
    State#sdp_user_state{options=ACC};   

decode_z70(S,State,ACC) when length(S)>1 ->
    slog:event(warning, ?MODULE, unknown_z70_state,S),
    State.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type decode_z80(term(),sdp_user_state())->
%%                  sdp_user_state().

decode_z80(Zone80,State)->
     decode_z80(Zone80,State,[]).

decode_z80([[MSISDN_MEMBER,OPTL_RANG,MSISDN_TOP_NUM,MSISDN_TCP_NUM,
	          MSISDN_PTF_NUM,MSISDN_RNV_NUM]|T],State,ACC)->
     decode_z80(T,State,ACC++[MSISDN_MEMBER]);

decode_z80(L_VIDE,State,ACC) when L_VIDE==[];L_VIDE==[[]] ->
    State#sdp_user_state{numpref_list=ACC};

decode_z80(S,State,ACC) when length(S)>1 ->
    slog:event(warning, ?MODULE, unknown_z80_state,S),
    State.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type decode_ntrd(term(),sdp_user_state())->
%%                  sdp_user_state().

decode_ntrd([TCP_NUM, PTF_NUM, CPP_SOLDE, _TCP_NUM_RECEVEUR, _PTF_NUM_RECEVEUR, _CPP_SOLDE_RECEVEUR],
	    State)->
    Compte = cpte(State,cpte_princ),
    New_Compte = Compte#compte{cpp_solde=calcul_solde(CPP_SOLDE,?EURO)},
    New_State=add_compte(TCP_NUM,New_Compte,State),
    New_State.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_cpte(DCL::integer(),compte(),UNT_REST::string())-> 
%%                  string().
%%%% Get account credit (#compte.cpp_solde) in unit defined by UNT_REST.

print_cpte(DCL,#compte{unt_num=?SMS,cpp_solde=Solde,
		       ptf_num=PTF_NUM,etat=?CETAT_AC}=CPTE,"sms",_MSISDN)->
    CRNbSMS = io_lib:format("~p", [Solde]),
    lists:flatten(CRNbSMS);

print_cpte(DCL,#compte{unt_num=?SMS,cpp_solde=Solde,
		       ptf_num=PTF_NUM,etat=?CETAT_AC}=CPTE,"mms",_MSISDN)->
    CRNbSMS = io_lib:format("~p", [Solde/3]),
    lists:flatten(CRNbSMS);

print_cpte(DCL,#compte{unt_num=?EURO,cpp_solde=SOLDE,
		       etat=?CETAT_AC}=CPTE,"euro",_MSISDN)->
    CR = currency:print(currency:to_euro(SOLDE)),
    lists:flatten(CR);

print_cpte(DCL,#compte{unt_num=?EURO,cpp_solde=SOLDE,
		       etat=?CETAT_AC}=CPTE,"euro_p",_MSISDN)->
    Cr_euros = currency:round_value(currency:to_euro(SOLDE)),
    Cr = trunc(Cr_euros),
    Pr = trunc(Cr_euros*10) rem 10,
    Solde = io_lib:format("~p,~p", [Cr, Pr]), 
    lists:flatten(Solde);


%%%% Translate EURO -> SMS, EURO -> MMS, EURO -> Ko, EURO -> min
%%%% Print account credit in sms, mms or Ko depending on parameter UNT_REST.

print_cpte(DCL, #compte{unt_num=?EURO,ptf_num=PTF_NUM,
			etat=?CETAT_AC}=CPTE, UNT_REST,_MSISDN)
  when UNT_REST=="sms" -> %% EURO -> SMS
    R = ratio_mnesia(DCL,CPTE#compte.tcp_num,PTF_NUM,sms),
    Cr_euros = 
 	currency:round_value(currency:to_euro(CPTE#compte.cpp_solde)),
    NbSMS=trunc((Cr_euros*1000)/(R*1000)),
    CRNbSMS = io_lib:format("~p", [NbSMS]),
    lists:flatten(CRNbSMS);

print_cpte(DCL, #compte{unt_num=?EURO,ptf_num=PTF_NUM,
			etat=?CETAT_AC}=CPTE, UNT_REST,_MSISDN)
 when UNT_REST=="sms_p" -> %% EURO -> SMS
    R=ratio_mnesia(DCL,CPTE#compte.tcp_num,PTF_NUM,sms_p),
    Cr_euros = 
 	currency:round_value(currency:to_euro(CPTE#compte.cpp_solde)),
    NbSMS=trunc((Cr_euros*1000)/(R*1000)),
    CRNbSMS = io_lib:format("~p", [NbSMS]),
    lists:flatten(CRNbSMS);

print_cpte(DCL, #compte{unt_num=?EURO,ptf_num=PTF_NUM,
			etat=?CETAT_AC}=CPTE, UNT_REST,_MSISDN)
  when UNT_REST=="mms" -> %% EURO -> MMS
    R=ratio_mnesia(DCL,CPTE#compte.tcp_num,PTF_NUM,mms),
    Cr_euros = 
 	currency:round_value(currency:to_euro(CPTE#compte.cpp_solde)),
    NbMMS=trunc((Cr_euros*1000)/(R*1000)),
    CRNbMMS = io_lib:format("~p", [NbMMS]),
    lists:flatten(CRNbMMS);

print_cpte(DCL, #compte{unt_num=?EURO,ptf_num=PTF_NUM,
			etat=?CETAT_AC}=CPTE, UNT_REST,_MSISDN)
  when UNT_REST=="ko" -> %% EURO -> Ko
    R=ratio_mnesia(DCL,CPTE#compte.tcp_num,PTF_NUM,ko),
    Cr_euros = 
 	currency:round_value(currency:to_euro(CPTE#compte.cpp_solde)),
    NbKo=(Cr_euros*1000)/(R*1000),
    CRNbKo = 
 	case NbKo of
 	    Ko when Ko>1024->
 		io_lib:format("~.2fMo", [(Ko/1024)]);
 	    Ko->
 		integer_to_list(trunc(Ko))++" Ko"
 	end,
    lists:flatten(CRNbKo);

print_cpte(DCL,#compte{unt_num=?EURO,ptf_num=PTF_NUM,
		       etat=?CETAT_AC}=CPTE,UNT_REST,_MSISDN)
  when UNT_REST=="min_p" -> %% EURO -> Min
    Prix_min=ratio_mnesia(DCL,CPTE#compte.tcp_num,PTF_NUM,min_p),
    print_min(DCL,CPTE,Prix_min);

%%%% Print number of calls.

print_cpte(DCL, #compte{unt_num=?EURO,etat=?CETAT_AC,cpp_solde=CPP_SOLDE,
			tcp_num=TCP_NUM,ptf_num=PTF_NUM}=CPTE, UNT_REST,_MSISDN)
  when UNT_REST=="nbappels" ->
    SOLDE_EUROS = currency:round_value(CPP_SOLDE),
    RatioNbApp = ratio_mnesia(DCL,TCP_NUM,PTF_NUM,nbappels),
    NbApp = trunc((SOLDE_EUROS*1000)/(RatioNbApp*1000)),
    lists:flatten(io_lib:format("~p", [NbApp]));


print_cpte(DCL, #compte{unt_num=?EURO,etat=?CETAT_AC,cpp_solde=CPP_SOLDE,
			tcp_num=TCP_NUM,ptf_num=PTF_NUM}=CPTE, UNT_REST,_MSISDN)
  when UNT_REST=="day" ->
    RatioNbApp = ?RATIO_FOOT_SOIREE,
    SOLDE_EUROS = currency:round_value(CPP_SOLDE),
    NbApp = trunc(SOLDE_EUROS/RatioNbApp),
    case NbApp of
	0 -> "aucune soiree infinie offerte";
	1 -> "1 soiree infinie offerte";
	_ ->  lists:flatten(io_lib:format("~p soirees infinies offertes", [NbApp]))
    end;
%%%% Print account status when our of credit or expired.

print_cpte(DCL,#compte{etat=E}=CPTE,"euro",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0.00";

print_cpte(DCL,#compte{etat=E}=CPTE,"euro_p",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0,0";

print_cpte(DCL,#compte{etat=E}=CPTE,"sms",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0";

print_cpte(DCL,#compte{etat=E}=CPTE,"mms",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0";

print_cpte(DCL,#compte{etat=E}=CPTE,"ko",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0 Ko";

print_cpte(DCL,#compte{etat=E}=CPTE,"sms_p",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0";

print_cpte(DCL,#compte{etat=E}=CPTE,"min_p",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0min0sec";

print_cpte(DCL,#compte{etat=E}=CPTE,"day",_MSISDN) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "aucune soiree infinie offerte";

print_cpte(DCL,#compte{unt_num=UNT}=CPT,UNT_REST,MSISDN)->
    slog:event(internal,?MODULE,unknown_print_compte_rest,{MSISDN,CPT,UNT_REST}),
    "inconnu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_cpte(compte())-> 
%%                  [{pcdata,string()}].
%%%% Print account status.

print_cpte(#compte{etat=E,unt_num=?EURO}=CPTE) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0.00";

print_cpte(#compte{etat=E,unt_num=?SMS}=CPTE) 
  when E==?CETAT_EP;E==?CETAT_PE->
    "0";

print_cpte(#compte{etat=E,unt_num=?MIN}=CPTE)
  when E==?CETAT_EP;E==?CETAT_PE->
    "0";

print_cpte(#compte{unt_num=?SMS,cpp_solde=Solde})->
    CRNbSMS = io_lib:format("~p", [Solde]),
    lists:flatten(CRNbSMS);

print_cpte(#compte{unt_num=?EURO,cpp_solde=SOLDE})->    
    CR = currency:print(currency:to_euro(SOLDE)),
    lists:flatten(CR);

print_cpte(#compte{unt_num=?MIN,cpp_solde=SOLDE})->
    CRNbMIN = io_lib:format("~p", [SOLDE]),
    lists:flatten(CRNbMIN);

print_cpte(#compte{unt_num=UNT})->
    slog:event(internal,?MODULE,unknown_unt_num,UNT),
    "inconnu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type end_of_credit(Param::term(),
%%                     Atom_or_RNV::term(),
%%                     Format::string())->
%%                     atom() | string().
%%%% Param is either {Subscription::atom(), MSISDN::string()}
%%%% or Dlv::unixtime() and
%%%% Atom_or_RNV is either unix_time::atom(), pcdata::atom() or RNV::integer()

end_of_credit(Session, {Subscription, MSISDN}, unix_time, Format)->
    %% Used only for option sms_quotidien
    %% If subscription today, DLV = tomorrow, otherwise DLV = today
    SVIKey = {Subscription, MSISDN},
    TOP_NUM = svc_options:top_num(opt_sms_quoti,Subscription),
    case svc_util_of:consult_account_options(Session, SVIKey, TOP_NUM) of
        %%	case sdp_router:svi_c_op(SVIKey,TOP_NUM) of
	{ok, [DATE_SOUSCR_UT,_,_,_,_]} when list(DATE_SOUSCR_UT)->
            compute_date_souscr(list_to_integer(DATE_SOUSCR_UT));
	{ok, [DATE_SOUSCR_UT,_,_,_,_]} ->
            compute_date_souscr(DATE_SOUSCR_UT);
        {nok, Reason} -> 
            slog:event(failure,?MODULE,end_of_credit,{nok, Reason}),
            error;
        Error ->
            slog:event(failure,?MODULE,end_of_credit,{MSISDN, Error}),
            error
    end;   

end_of_credit(_, Dlv,RNV,Format)
  when RNV==0;RNV==undefined ->
    DateTime = calendar:now_to_local_time({Dlv div 1000000, 
					   Dlv rem 1000000,0}),
    Date = svc_util_of:sprintf_datetime_by_format(DateTime,Format),
    lists:flatten(Date);

end_of_credit(_, Dlv,RNV,Format)
  when RNV==50 ->
    %% Used by: Option SMS Quotidien CMO, Godet 34
    Now = pbutil:unixtime(),
    NextDay = Now+86400,
    DateTime =
	case is_startdate_now(Dlv) of
	    true -> calendar:now_to_local_time({NextDay div 1000000, 
						NextDay rem 1000000,0});
	    _ -> calendar:now_to_local_time({Now div 1000000, 
					     Now rem 1000000,0})
	end,
    Date = svc_util_of:sprintf_datetime_by_format(DateTime,Format),
    lists:flatten(Date);

end_of_credit(_, _,RNV,Format)->
    lists:flatten(svc_util_of:rnv_to_date(RNV,list_to_atom(Format))).


compute_date_souscr(DATE_SOUSCR_UT) ->
    {{_,DATE_SOUSCR_Month,DATE_SOUSCR_Day},_} = 
        calendar:now_to_local_time({DATE_SOUSCR_UT div 1000000,
                                    DATE_SOUSCR_UT rem 1000000,
                                    0}),
    DATE_SOUSCR = [DATE_SOUSCR_Day,DATE_SOUSCR_Month],
    
    Today_UT = pbutil:unixtime(),
    {{_,M_Today,D_Today},_} = 
        calendar:now_to_local_time({Today_UT div 1000000,
                                    Today_UT rem 1000000,
                                    0}),
    Today = [D_Today,M_Today],
    Tomorrow_UT = Today_UT + 86400,
    {{_,Tomorrow_Month,Tomorrow_Day},_} = 
        calendar:now_to_local_time({Tomorrow_UT div 1000000,
                                    Tomorrow_UT rem 1000000,
                                    0}),
    Tomorrow = [Tomorrow_Day,Tomorrow_Month],
    case (DATE_SOUSCR == Today) of 
        true ->
            Tomorrow_UT;
        false ->
            Today_UT
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type end_of_credit_date(Date_UT::unix_time(), Format::string())->
%%                          string().

end_of_credit_date(Date_UT, Format) ->
    DateTime = 
	calendar:now_to_local_time({Date_UT div 1000000,
				    Date_UT rem 1000000,
				    0}),
    Date = svc_util_of:sprintf_datetime_by_format(DateTime,Format), 
    lists:flatten(Date).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_startdate_now(Dlv::integer())->
%%                        bool().

is_startdate_now(Dlv)->
    Now = pbutil:unixtime(),
    {DateNow,TimeNow} = calendar:now_to_local_time({Now div 1000000,
						    Now rem 1000000,0}),
    StartDate = Dlv -14*86400,
    {DateStart,TimeStart} = 
	calendar:now_to_local_time({StartDate div 1000000,
				    StartDate rem 1000000,0}),
    (DateNow == DateStart).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type price_in_min(DCL::integer(),compte())-> 
%%                float().
%%%% This function is actually used only for CMO.

price_in_min(DCL,#compte{tcp_num=TCP_NUM,ptf_num=PTF_NUM})->
    ratio_mnesia(DCL,TCP_NUM,PTF_NUM,min).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_min(DCL::integer(),compte(),Prix_min::integer())->
%%                 [{pcdata,string()}].
%%%% Print price in minutes.
print_hour_min_sec(DCL,#compte{cpp_solde=Solde,unt_num=?EURO},Prix_min) ->
    Solde_val = currency:round_value(currency:to_euro(Solde)),
    Secondes_T = trunc(Solde_val/Prix_min*60),
    Minutes=trunc(Secondes_T/60),
    Secondes=Secondes_T-Minutes*60,
    CR_tp=
 	case Minutes of
 	    Mn when Mn>=60->
 		%% h min sec
 		Hours=trunc(Minutes/60),
 		Min2=Minutes-Hours*60,
 		io_lib:format("~ph ~pmin ~ps", [Hours,Min2,Secondes]);
 	    _->
 		io_lib:format("~pmin ~ps", [Minutes,Secondes])
 	end,
    lists:flatten(CR_tp).	


print_min(DCL,#compte{cpp_solde=Solde,unt_num=?EURO},Prix_min) ->
    Solde_val = currency:round_value(currency:to_euro(Solde)),
    Secondes_T = trunc(Solde_val/Prix_min*60),
    Minutes=trunc(Secondes_T/60),
    Secondes=Secondes_T-Minutes*60,
    CR_tp=
 	case Minutes of
 	    Mn when Mn>60->
 		%% h min sec
 		Hours=trunc(Minutes/60),
 		Min2=Minutes-Hours*60,
 		io_lib:format("~ph~pmin", [Hours,Min2]);
 	    _->
 		io_lib:format("~pmin", [Minutes])
 	end,
    lists:flatten(CR_tp).	

print_hour_min(DCL,#compte{cpp_solde=Solde,unt_num=?EURO},Prix_min) ->
    Solde_val = currency:round_value(currency:to_euro(Solde)),
    Secondes_T = trunc(Solde_val/Prix_min*60),
    Minutes=trunc(Secondes_T/60),
    Secondes=Secondes_T-Minutes*60,
    CR_tp=
        case Minutes of
            Mn when Mn>60->
		%% h min sec
                Hours=trunc(Minutes/60),
		Min2=Minutes-Hours*60,
		io_lib:format("~ph~pmin", [Hours,Min2]);
	    _->
                io_lib:format("~ph~pmin", [0,Minutes])
        end,
    lists:flatten(CR_tp).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_min_sec(DCL::integer(),compte(),Prix_min::integer())->
%%                     [{pcdata,string()}].
%%%% Print price in minutes and seconds.
%%%% Used in selfcare light.

print_min_sec(DCL,#compte{cpp_solde=Solde,unt_num=?EURO},Prix_min) ->	 
    Solde_val = currency:round_value(currency:to_euro(Solde)),
    Secondes_T = trunc(Solde_val/Prix_min*60),
    Minutes=trunc(Secondes_T/60),
    Secondes=Secondes_T-Minutes*60,
    case Minutes of
	0->
	    "1min";
	_->
             CR_tp = io_lib:format("~pmin~psec", [Minutes,Secondes]),
	    lists:flatten(CR_tp)
    end;
print_min_sec(DCL,Compte,Prix_min) ->
    "inconnu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type print_min_sec_with_format(DCL::integer(),compte(),Prix_min::integer(),Format::lists)->
%%                     [{pcdata,string()}].
%%%% Print price in minutes and seconds in right format.

print_min_sec_with_format(DCL,#compte{cpp_solde=Solde,unt_num=?EURO}=Compte,Prix_min,Format) ->
    Solde_val = currency:round_value(currency:to_euro(Solde)),
    Secondes_T = trunc(Solde_val/Prix_min*60),
    Minutes=trunc(Secondes_T/60),
    Secondes=Secondes_T-Minutes*60,
    case Format of
	"mnsec" ->
	    case Minutes of
		0->
		    "1mn";
		_->
		    CR_tp = io_lib:format("~pmn ~psec", [Minutes,Secondes]),
		    lists:flatten(CR_tp)
	    end;
	"mns" ->
	    case Minutes of
		0->
		    "1mn";
		_->
		    CR_tp = io_lib:format("~pmn~ps", [Minutes,Secondes]),
		    lists:flatten(CR_tp)
	    end;
        "mins" ->
	    CR_tp = io_lib:format("~pmin~ps", [Minutes,Secondes]),
	    lists:flatten(CR_tp);
	"mn"->
	    Min_tmp=case Secondes of
			0-> Minutes;
			_->Minutes+1
		    end,
	    CR_tp = io_lib:format("~pmn", [Min_tmp]),
            lists:flatten(CR_tp);
	"minsec" ->
	    CR_tp = io_lib:format("~pmin~psec", [Minutes,Secondes]),
	    lists:flatten(CR_tp);
	_ ->
	    print_min_sec(DCL,Compte,Prix_min)
    end;
 
print_min_sec_with_format(DCL,Compte,Prix_min,Format) ->
    "inconnu".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type get_cpte_from_list(sdp_user_state(),Cpte::atom())-> 
%%                          compte().
%%%% Search compte in #sdp_user_state.cpte_list or
%%%% #sdp_user_state.cpte_princ if cpte_princ.

get_cpte_from_list(State, Cpte=cpte_princ) ->
    State#sdp_user_state.cpte_princ;

get_cpte_from_list(State, Cpte=cpte_forfait_voix) ->
    List_cpt_voix = ?CPTE_FORFAIT_VOIX,
    get_cpte_from_cpte_voix(State, List_cpt_voix);

get_cpte_from_list(State, Cpte) ->
    List = State#sdp_user_state.cpte_list,
    case List of
	undefined -> 
	    no_cpte_found;
	_ ->
	    case lists:keysearch(Cpte,1,List) of
		{value,{Cpte,AccountInfo}}->
		    AccountInfo;
		_->
		    no_cpte_found
	    end
    end.

get_cpte_from_cpte_voix(State, []) ->
    no_cpte_found;
get_cpte_from_cpte_voix(State, [Cpte|T]) ->
    case get_cpte_from_list(State, Cpte) of 
	no_cpte_found ->
	    get_cpte_from_cpte_voix(State, T);
	AccountInfo -> 
	    AccountInfo
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type set_cpte_to_list(sdp_user_state(),Cpte::atom(),
%%                        AccountInfo::compte())-> 
%%                        sdp_user_state().
%%%% Set compte to #sdp_user_state.cpte_list.

set_cpte_to_list(State, Cpte, AccountInfo) ->
    List = State#sdp_user_state.cpte_list,
    case {List,Cpte} of
	{List,unknown_cpte} ->
	    State;
	{undefined,Cpte} ->
	    State#sdp_user_state{cpte_list=[{Cpte, AccountInfo}]};
	{[],Cpte} ->
	    State#sdp_user_state{cpte_list=[{Cpte, AccountInfo}]};
	_ ->
	    update_sdp_user_state(List,State,Cpte,AccountInfo,[])
    end.

update_sdp_user_state([{Cpte,_}|TAIL],State,Cpte,AccountInfo,ACC)->
    State#sdp_user_state{cpte_list=ACC++[{Cpte, AccountInfo}]++TAIL};
update_sdp_user_state([CURRENT|TAIL],State,Cpte,AccountInfo,ACC)->
    update_sdp_user_state(TAIL,State,Cpte,AccountInfo,ACC++[CURRENT]);
update_sdp_user_state([],State,Cpte,AccountInfo,ACC) ->
    State#sdp_user_state{cpte_list=ACC++[{Cpte, AccountInfo}]}.   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type recup_ratio({DCL::integer(),TCP_NUM::integer(),PTF_NUM::integer(),
%%                    UNT_REST::integer()})->
%%                    float().

recup_ratio({DCL,TCP_NUM,PTF_NUM,UNT_REST}=INDEX)->
    recup_ratio(INDEX,first).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type recup_ratio({DCL::integer(),TCP_NUM::integer(),PTF_NUM::integer(),
%%                    UNT_REST::integer()},Type::atom())->
%%                    float().
%%%% Get ratio from mnesia.

recup_ratio({DCL,TCP_NUM,PTF_NUM,UNT_REST}=INDEX,Type)->
    R=#ratio{key=INDEX},
    case mnesia:read({ratio,R#ratio.key}) of
	[#ratio{ratio=Ratio}] ->
	    Ratio/1000;
 	[]->
	    %% search equivalent ratio
	    case Type of
		first->
		    recup_ratio_equivalent(INDEX,Type);
		second->
		    default_ratio(UNT_REST)
	    end;
 	Else ->
 	    slog:event(internal,unknown_response_mnesia,?MODULE,Else),
 	    default_ratio(UNT_REST)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type default_ratio(UNT::integer())->
%%                     float().
%%%% Define default ratio.

default_ratio(UNT) when UNT==sms;
			UNT==?SMS;
			UNT==sms_p;
			UNT==?SMS_P->
    0.1;
default_ratio(UNT) when UNT==mms;
			UNT==?MMS->
    0.3;
default_ratio(_)->
    1.
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%% +type recup_ratio_equivalent({DCL::integer(),TCP_NUM::integer(),
%%                               PTF_NUM::integer(),UNT_REST::integer()},
%%                              Type::atom())->
%%                              float().
%%%% Translate to equivalent ratio.

recup_ratio_equivalent({DCL,TCP_NUM,PTF_NUM,UNT_REST}=INDEX,Type)->
    case ratio_equivalent(UNT_REST) of
	{N_UNT,Ratio_Equi}->
	    case recup_ratio({DCL,TCP_NUM,PTF_NUM,N_UNT},second) of
		1->
		    default_ratio(UNT_REST);
		R when float(R)->
		    Ratio_Equi*R
	    end;
	_->
	    default_ratio(UNT_REST)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  			    
%% +type ratio_equivalent(UNT::integer())->
%%                        {integer(),float()}.
%%%% Perform translations of ratio between units.

ratio_equivalent(?MIN)->
    {?SEC,60};
ratio_equivalent(?SEC) ->
    {?MIN,1/60};
ratio_equivalent(?MMS) ->
    {?SMS,3};
ratio_equivalent(?KO) ->
    {?MO,1/1024};
ratio_equivalent(?MO) ->
    {?KO,1024};
ratio_equivalent(_) ->
    no_equivalent.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% +type atom_to_int(Unt_rest::atom())->
%%                   unt_num().

atom_to_int(nbappels)->
    ?NBAPPELS;
atom_to_int(euro)->
    ?EURO;
atom_to_int(sms) ->
    ?SMS;
atom_to_int(min) ->
    ?MIN;
atom_to_int(ko) ->
    ?KO;
atom_to_int(mms) ->
    ?MMS;
atom_to_int(sms_p) ->
    ?SMS_P;
atom_to_int(min_p) ->
    ?MIN_P.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% + type decode_compte_v2(term(),sdp_user_state())-> sdp_user_state().
%%%% TLV_A4 returns fields PCT and ANCIENNETE

decode_compte_v2([[[TCP_NUM,UNT_NUM,CPP_SOLDE,DLV,RNV,ECP_NUM,
		    PTF_NUM,CPP_CUMUL,PCT,ANCIENNETE]|T]],State) ->
    Compte=#compte{tcp_num=TCP_NUM,
		   unt_num=UNT_NUM,
 		   cpp_solde=calcul_solde(CPP_SOLDE,UNT_NUM),
 		   dlv=DLV,
 		   rnv=RNV,
 		   etat=ECP_NUM,
 		   ptf_num=PTF_NUM,
 		   cpp_cumul_credit=CPP_CUMUL,
 		   pct=PCT,
 		   anciennete=ANCIENNETE},
    State2=add_compte(TCP_NUM,Compte,State),
    decode_compte_v2([T],State2);

decode_compte_v2([[]],State)->
    State;

decode_compte_v2(S,State)->
    slog:event(warning, ?MODULE, unknown_compte_v2,S),
    State.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% +type add_compte(TCP_NUM::integer(),compte(),sdp_user_state())->
%%                  sdp_user_state().

add_compte(?C_PRINC,CPTE_RECORD,STATE)->
    STATE#sdp_user_state{cpte_princ=CPTE_RECORD};
add_compte(TCP_NUM,CPTE_RECORD,STATE) ->
    Subscr = list_to_atom(svc_util_of:declinaison(STATE)),
    AddCpte = search_cpte(TCP_NUM, Subscr),
    set_cpte_to_list(STATE, AddCpte, CPTE_RECORD).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type search_cpte(TCP_NUM::integer(),string())->
%%                   compte().
 
search_cpte(TCP_NUM, Subscr) ->
    search_cpte(TCP_NUM, Subscr,?TCPNUM_CPTE).

%% +type search_cpte(TCP_NUM::integer(),string())->
%%                   compte().

search_cpte(TCP_NUM, Subscr,[]) ->
    unknown_cpte;
search_cpte(TCP_NUM, Subscr, [Tcpnum_cpte | TAIL]) ->
    case Tcpnum_cpte of
	{TCP_NUM, CPTE, all_subscriptions} -> CPTE;
	{TCP_NUM, CPTE, Subscr} -> CPTE;
	_ -> search_cpte(TCP_NUM,Subscr,TAIL)
    end.
