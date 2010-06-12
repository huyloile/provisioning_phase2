-module(svc_plan_tarif_omer).

-export([print_hlinks_by_plan/2,
	 redirect_by_plan/2,
	 print_by_plan/2,
	 redir_by_plan/2,
	 check_solde/3,
	 include_msg_gratuite/4,
	 do_changement_to/2,
	 print_prix_eur_min/2,
	 print_prix_eur_sec/2,
	 print_prix_du_changement/1
	]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type redirect_by_plan(session(),string())-> erlpage_result().
redirect_by_plan(abs,REDIR_PLANs) ->
    [{_,URL}|_] = svc_util_of:str2tuplist(REDIR_PLANs,",","="),
    {redirect,abs,URL};
redirect_by_plan(Sess,REDIR_PLANs) ->
    Ptf=ptf_num(Sess),
    L = svc_util_of:str2tuplist(REDIR_PLANs,",","="),
    PlanURL=(case lists:keysearch(ptfnum_int2str(Ptf),1,L) of
		 {value, {_,URL1}} -> 
		     URL1;
		 false  -> 
		     case lists:last(L) of
			 {"default",URL2} -> 
			     URL2;
			 _ -> slog:event(service_ko,?MODULE,
					 bad_args_from_xml_or_bad_plan,
					 {Ptf,ptfnum_int2str(Ptf),REDIR_PLANs}),
			      "#temporary"
		     end
	     end),
    {redirect,Sess,PlanURL}.

%% +type ptfnum_str2int(string())-> integer().
ptfnum_str2int("pomer_lanc_min") -> 44;
ptfnum_str2int("pomer_lanc_sec") -> 45;
ptfnum_str2int("pomer_class_min") -> 46;
ptfnum_str2int("pomer_class_sec") -> 47;
ptfnum_str2int("pcmo_sec") -> ?PBZH_CMO_SEC;
ptfnum_str2int("pcmo_min") -> ?PBZH_CMO_MIN;
ptfnum_str2int("pcmo_sec2") ->?PBZH_CMO_SEC2;
ptfnum_str2int("pcmo_min2") ->?PBZH_CMO_MIN2;

ptfnum_str2int("pcmo_min_cb1") ->?PTF_BZH_MIN_CB1;
ptfnum_str2int("pcmo_min_cb2") ->?PTF_BZH_MIN_CB2;
ptfnum_str2int("pcmo_min_cb3") ->?PTF_BZH_MIN_CB3;
ptfnum_str2int("pcmo_min_cb4") ->?PTF_BZH_MIN_CB4;

ptfnum_str2int("pcmo_sec_cb1") ->?PTF_BZH_SEC_CB1;
ptfnum_str2int("pcmo_sec_cb2") ->?PTF_BZH_SEC_CB2;
ptfnum_str2int("pcmo_sec_cb3") ->?PTF_BZH_SEC_CB3;
ptfnum_str2int("pcmo_sec_cb4") ->?PTF_BZH_SEC_CB4.

%% +type ptfnum_int2str(integer())-> string().
ptfnum_int2str(44) -> "pomer_lanc_min";
ptfnum_int2str(45) -> "pomer_lanc_sec";
ptfnum_int2str(46) -> "pomer_class_min";
ptfnum_int2str(47) -> "pomer_class_sec";
ptfnum_int2str(?PBZH_CMO_SEC) -> "pcmo_sec";
ptfnum_int2str(?PBZH_CMO_MIN) -> "pcmo_min";
ptfnum_int2str(?PBZH_CMO_SEC2) ->"pcmo_sec2";
ptfnum_int2str(?PBZH_CMO_MIN2) ->"pcmo_min2";

ptfnum_int2str(?PTF_BZH_MIN_CB1) -> "pcmo_min_cb1";
ptfnum_int2str(?PTF_BZH_MIN_CB2) -> "pcmo_min_cb2";
ptfnum_int2str(?PTF_BZH_MIN_CB3) -> "pcmo_min_cb3";
ptfnum_int2str(?PTF_BZH_MIN_CB4) -> "pcmo_min_cb4";

ptfnum_int2str(?PTF_BZH_SEC_CB1) -> "pcmo_sec_cb1";
ptfnum_int2str(?PTF_BZH_SEC_CB2) -> "pcmo_sec_cb2";
ptfnum_int2str(?PTF_BZH_SEC_CB3) -> "pcmo_sec_cb3";
ptfnum_int2str(?PTF_BZH_SEC_CB4) -> "pcmo_sec_cb4".

%% +type print_by_plan(session(),string()) -> [{redirect,session(),string()}].
redir_by_plan(abs,DESCR_PLANs) ->
    [{_,FIRST_PCD}|_]=svc_util_of:str2tuplist(DESCR_PLANs,",","="),
    [{redirect,abs,FIRST_PCD}];

redir_by_plan(Session,DESCR_PLANs) ->
%%  DESCR_PLANs must have the following format : 
%% "plan1=pcdata1,plan2=pcdata2,...,planN=pcdataN,default=pcdataDef"
%% 'default' can be omitted
    State = svc_util_of:get_user_state(Session),
    PTF =  ptf_num(Session),
    PTF_STR=ptfnum_int2str(PTF),
    L=svc_util_of:str2tuplist(DESCR_PLANs,",","="),
    URL=(case lists:keysearch(PTF_STR,1,L) of
		{value,{_,PCD}} -> PCD;
		false  -> 
		    case lists:last(L) of
			{"default",PCD} -> PCD;
			false -> ""
		    end
	    end),
    {redirect,Session,URL}.

%% +type print_by_plan(session(),string()) -> [{pcdata,string()}].
print_by_plan(abs,DESCR_PLANs) ->
    [{_,FIRST_PCD}|_]=svc_util_of:str2tuplist(DESCR_PLANs,",","="),
    [{pcdata,FIRST_PCD}];

print_by_plan(Session,DESCR_PLANs) ->
%%  DESCR_PLANs must have the following format : 
%% "plan1=pcdata1,plan2=pcdata2,...,planN=pcdataN,default=pcdataDef"
%% 'default' can be omitted
    State = svc_util_of:get_user_state(Session),
    PTF =  ptf_num(Session),
    PTF_STR=ptfnum_int2str(PTF),
    L=svc_util_of:str2tuplist(DESCR_PLANs,",","="),
    PCDATA=(case lists:keysearch(PTF_STR,1,L) of
		{value,{_,PCD}} -> PCD;
		false  -> 
		    case lists:last(L) of
			{"default",PCD} -> PCD;
			false -> ""
		    end
	    end),
    [{pcdata,PCDATA}].

%% +type print_hlinks_by_plan(session(),string()) -> [hlink()].
print_hlinks_by_plan(abs,PLAN_HLINKS) ->
    [{_,HLINKS}|_] = svc_util_of:str2tuplist(PLAN_HLINKS,",",":"),
    L2 = svc_util_of:str2tuplist(HLINKS,";","="),
    build_hlinks(L2);
print_hlinks_by_plan(Sess,PLAN_HLINKS) ->
    PtfNum=ptf_num(Sess),
    L = svc_util_of:str2tuplist(PLAN_HLINKS,",",":"),
    {value,{_,HLINKS}}=lists:keysearch(ptfnum_int2str(PtfNum),1,L),
    L2 = svc_util_of:str2tuplist(HLINKS,";","="),
    build_hlinks(L2).

%% +type build_hlinks([{string(),string()}])-> [hlink()].
build_hlinks([]) -> [];
build_hlinks([{PCD,URL}|T]) -> 
    [#hlink{href=URL,contents=[{pcdata,PCD},br]}|build_hlinks(T)].

%% +type check_solde(session(),string(),string())-> erlpage_result().
check_solde(abs,Urlok,Urlnok)->
    [{redirect,abs,Urlok},{redirect,abs,Urlnok}];
check_solde(Session,Urlok,Urlnok)->
    State = svc_util_of:get_user_state(Session),
    Price_PT=prix_du_changement(State),
    Compte=State#sdp_user_state.cpte_princ,
    case currency:is_infeq(Price_PT,Compte#compte.cpp_solde) of
	true ->
	    {redirect,Session,Urlok};
	false ->
	    {redirect,Session,Urlnok}
    end.

%% +type include_msg_gratuite(session(),string(),string(),string())-> [erlinclude_result()].
include_msg_gratuite(abs,Url2g,Url1g,Url0g) ->
    [{include,{relurl,Url2g}},
     {include,{relurl,Url1g}},
     {include,{relurl,Url0g}}];

include_msg_gratuite(Session,Url2g,Url1g,Url0g) ->
    #sdp_user_state{etats_sec=EtatSec} = svc_util_of:get_user_state(Session),
    case {EtatSec band ?SETAT_PT,EtatSec band ?SETAT_P2} of
	{?SETAT_PT, ?SETAT_P2} ->
	    %%Price = currency:sum(get_env(prix_changement_plan_tarif_omer)),
	    %%EurPriceStr = svc_selfcare:print_sum(?EURO, Price),
	    %%[{pcdata, "Ce changement vous sera facture "
	    %%++ EurPriceStr}];
	    [{include,{relurl,Url0g}}];
	{?SETAT_PT, 0} ->
	    [{include,{relurl,Url1g}}];
	_ ->
	    [{include,{relurl,Url2g}}]
    end.

%% +type print_prix_du_changement(session())-> [{pcdata,string()}].
print_prix_du_changement(abs) ->
    Prix = currency:sum(euro,0),
    Str = svc_selfcare:print_sum(?EURO, Prix),
    [{pcdata,Str}];
print_prix_du_changement(Session) ->
    State = svc_util_of:get_user_state(Session),
    Prix = prix_du_changement(State),
    Str = svc_selfcare:print_sum(?EURO, Prix),
    [{pcdata,Str}].

%% +type prix_du_changement(sdp_user_state())-> currency:currency().
prix_du_changement(#sdp_user_state{etats_sec=EtatSec}) ->
    case {EtatSec band ?SETAT_PT, EtatSec band ?SETAT_P2} of
	{?SETAT_PT, ?SETAT_P2} ->
	    currency:sum(get_env(prix_changement_plan_tarif_omer));
	_ ->
	    currency:sum(euro,0)
    end.

%% +type do_changement_to(session(),string())-> erlpage_result().
do_changement_to(abs, _) ->
    [ {redirect, abs, "#change_pt_error"},
      {redirect, abs, "#not_enough_credit_pt"},
      {redirect, abs, "#change_pt_error"},
      {redirect, abs, "#change_pt_success"}
     ];

do_changement_to(#session{prof=Profile} = Session, PT) ->
    State = svc_util_of:get_user_state(Session),
    Compte_P=State#sdp_user_state.cpte_princ,
    PrixChgtPlan = prix_du_changement(State),
    Msisdn = Profile#profile.msisdn,
    NewPT = ptfnum_str2int(PT),
    case catch do_change_pt(Session, Msisdn, NewPT, PrixChgtPlan) of
	{ok, _} ->
	    NewSession = update_state(Session,NewPT,PrixChgtPlan),
	    {redirect,NewSession,"#change_pt_success"};
 	{status, [10, 1]} -> 
 	    {redirect, Session, "#change_pt_error"};
 	{status,  [10, 2]} ->
 	    {redirect, Session, "#not_enough_credit_pt"};
 	{status, [99]}->
 	    {redirect, Session, "#change_pt_error"};
 	{status, [99,X]}->
 	    {redirect, Session, "#change_pt_error"};
        {nok, Reason} ->
	    slog:event(failure, ?MODULE, bad_response_from_sachem, Reason),
	    {redirect, Session, "#change_pt_error"};
	E ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session, "#change_pt_error"}
    end.

%% +type do_change_pt(session(),Msisdn::string(),NewPT::integer(),
%%                    PTChangePrice::integer())->
%%                    {ok,string()} | {status, integer()}.
do_change_pt(Session, Msisdn, NewPT, PTChangePrice)->
    Time = pbutil:unixtime(),
    case svc_compte:dcl(svc_util_of:get_user_state(Session)) of
	?bzh_cmo->
            Compte = #compte{ptf_num=NewPT, pct=PTChangePrice, d_crea=Time,
                                     tcp_num=?C_FORF_BZH,  ctrl_sec=1},
            svc_util_of:change_user_account(Session, {cmo,Msisdn},
                                           Compte);
	?bzh_cmo2->
            Compte = #compte{ptf_num=NewPT, pct=PTChangePrice, d_crea=Time,
                             tcp_num=?C_FORF_BZH2,  ctrl_sec=1},
            svc_util_of:change_user_account(Session, {cmo,Msisdn},
                                            Compte);
	Else ->
            slog:event(warning, ?MODULE, do_change_pt_unexpected_dcl, 
                       {dcl, Else,force_to_compte ,?C_FORF_BZH2}),
            Compte = #compte{ptf_num=NewPT, pct=PTChangePrice, d_crea=Time,
                             tcp_num=?C_FORF_BZH2,  ctrl_sec=1},
            svc_util_of:change_user_account(Session, {cmo,Msisdn},
                                            Compte)
    end.

%% +type update_state(session(),integer(),currency:currency())-> session().
update_state(Session,NewPT,PrixChgtPlan)->
    {_,Session1}=svc_util_of:reinit_prepaid(Session),
    Session1.

%% +type print_prix_eur_min(session(),string())-> [{pcdata,string()}].
print_prix_eur_min(abs,PtfNumStr) ->
    [{pcdata, "0.XXeuros/mn"}];
print_prix_eur_min(_,PtfNumStr) ->
    PtfNum = ptfnum_str2int(PtfNumStr),
    R = svc_compte:ratio_mnesia(?omer,?C_PRINC,PtfNum,min),
    Txt = lists:flatten(io_lib:format("~.2f euros/mn",[R])),
    [{pcdata, Txt}].

%% +type print_prix_eur_sec(session(),string())-> [{pcdata,string()}].
print_prix_eur_sec(abs,PtfNumStr) ->
    [{pcdata, "0.XXXeuros/s"}];
print_prix_eur_sec(_,PtfNumStr) ->
    PtfNum = ptfnum_str2int(PtfNumStr),
    R = svc_compte:ratio_mnesia(?omer,?C_PRINC,PtfNum,min)/60,
    Txt = lists:flatten(io_lib:format("~.4f euros/s",[R])),
    [{pcdata, Txt}].

%% +type get_env(atom())-> term().
get_env(ParamCfg) ->
    pbutil:get_env(pservices_orangef,ParamCfg).

%% +type ptf_num(session())-> integer().
ptf_num(Session)->
    State=svc_util_of:get_user_state(Session),
    case svc_compte:dcl(svc_util_of:get_user_state(Session)) of
	X when X==?bzh_cmo;X==?bzh_cmo2->
	    svc_compte:ptf_num(State,forf_bzh);
	_->
	    svc_compte:ptf_num(State,cpte_princ)
    end.
