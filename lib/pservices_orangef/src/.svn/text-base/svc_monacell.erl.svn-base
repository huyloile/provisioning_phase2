-module(svc_monacell).
-define(Limit1,"131").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

%% XML API
-export([select_home_niv1/1,
	 select_home_niv3/1,
	 redirect_by_bonus/6,
	 verif_num/8,
	 do_confirm/5]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 1 and 2 (niveau 1 & 2) phones.

select_home_niv1(abs)->
    [{redirect,abs,"#ac_niv1"},{redirect,abs,"#ac_niv2"},
     {redirect,abs,"#ep_niv1"},{redirect,abs,"#ep_niv2"}];
select_home_niv1(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home_niv1(S,list_to_atom(Subs)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts and the subscription.
%%%% Used for level 3 (niveau 3) phones.

select_home_niv3(abs)->
    [{redirect,abs,"#act_niv3"},{redirect,abs,"#ep_niv3"}];
select_home_niv3(#session{prof=Prof}=S)->
    Subs=Prof#profile.subscription,
    select_home_niv3(S,list_to_atom(Subs)). 
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDIRECTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv1(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the accounts when
%%%% subscription is monacell_prepaid | monacell_comptebloqu.

select_home_niv1(S,Subs) when Subs==monacell_prepaid ->
    State = svc_util_of:get_user_state(S),
    case svc_compte:etat_cpte(State,cpte_princ) of
 	%% case main account (cpte_princ) active
 	?CETAT_AC ->
 	    svc_util:redirect_size(S,?Limit1,"#ac_niv1","#ac_niv2");
	%% case main account out of credit
 	_ ->
 	    svc_util:redirect_size(S,?Limit1,"#ep_niv1","#ep_niv2")
    end;

select_home_niv1(S,Subs) when Subs==monacell_comptebloqu ->
    State = svc_util_of:get_user_state(S),
    case { svc_compte:etat_cpte(State,cpte_forf_monaco_fb), 
           svc_compte:etat_cpte(State,cpte_princ) }  of
        {?CETAT_AC, ?CETAT_AC} ->
 	    svc_util:redirect_size(S,?Limit1,"#ac_ac_niv1","#ac_ac_niv2");
        {?CETAT_EP, ?CETAT_AC} ->
 	    svc_util:redirect_size(S,?Limit1,"#ep_ac_niv1","#ep_ac_niv2");
        {?CETAT_AC, ?CETAT_EP} ->
 	    svc_util:redirect_size(S,?Limit1,"#ac_ep_niv1","#ac_ep_niv2");
 	_ ->
 	    svc_util:redirect_size(S,?Limit1,"#ep_ep_niv1","#ep_ep_niv2")
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type select_home_niv3(session(),Subs::atom()) ->
%%                        erlpage_result().
%%%% Redirect according to the state of the account when
%%%% subscription is monacell_prepaid or monacell_comptebloqu.

select_home_niv3(S,Subs)when Subs==monacell_prepaid->
    State = svc_util_of:get_user_state(S),
    case svc_compte:etat_cpte(State,cpte_princ) of
	?CETAT_AC->
	    {redirect, S, "#act_niv3"};
	_->
	    {redirect, S, "#ep_niv3"}   
	end;
select_home_niv3(S,Subs)when Subs==monacell_comptebloqu->
    State = svc_util_of:get_user_state(S),
    case { svc_compte:etat_cpte(State, cpte_forf_monaco_fb), 
           svc_compte:etat_cpte(State,cpte_princ) }  of
        {?CETAT_AC, ?CETAT_AC} ->
	    {redirect, S, "#ac_ac_niv3"};
        {?CETAT_EP, ?CETAT_AC} ->
	    {redirect, S, "#ep_ac_niv3"};
        {?CETAT_AC, ?CETAT_EP} ->
	    {redirect, S, "#ac_ep_niv3"};
	_->
	    {redirect, S, "#ep_ep_niv3"}   
	end.

redirect_by_bonus(abs,_,_,Url_bonus,Url_deja_souscrit,Url_erreur) ->
    [{redirect, abs, Url_bonus}, 
     {redirect, abs, Url_deja_souscrit},
     {redirect, abs, Url_erreur}];

redirect_by_bonus(S, Subs, Opt, Url_bonus, Url_deja_souscrit, Url_erreur)
  when Subs=="monacell_prepaid" andalso Opt=="opt_sms_illimite" ->
    case svc_util_of:do_consultation(S, list_to_atom(Opt)) of  
	{ok, [Zone70, _, _]} ->
	    case Zone70 of 
		L_VIDE when L_VIDE==[];L_VIDE==[[]] ->
		    {redirect, S, Url_bonus};
		[[_,_,DEB,FIN|_]] ->
			  svc_util_of:redirect_option_launched(S, DEB, FIN, 
							       Url_deja_souscrit, Url_bonus);
		[_,_,DEB,FIN|_] -> svc_util_of:redirect_option_launched(S, DEB, FIN, 
									Url_deja_souscrit, Url_bonus);
		Bad_z70 ->     slog:event(failure,?MODULE,bad_z70,Bad_z70) 
	    end;
        {ok, {Session_resp, Resp_params}} ->
            List_options = proplists:get_value("OP_PARAMS", Resp_params),
            case svc_sachem:get_option_info(list_to_atom(Opt), List_options) of                      
                [_,_,DEB,FIN|_] ->
                    svc_util_of:redirect_option_launched(Session_resp, DEB, FIN, 
                                                         Url_deja_souscrit, Url_bonus);
                _ ->
                    slog:event(failure, ?MODULE, unknown_option, {list_to_atom(Opt), List_options}),
                    {redirect, S, Url_erreur}
            end;
	{nok_opt_inexistante_dossier,_} ->
	    {redirect, S, Url_bonus};
        {nok, Reason} ->
            slog:event(failure,?MODULE,redirect_by_bonus_do_consult,Reason),
            {redirect, S, Url_erreur};
        _ ->
	    {redirect, S, Url_erreur}
    end;

redirect_by_bonus(S, Subs, Opt, Url_bonus, Url_deja_souscrit, Url_erreur)
  when Subs=="monacell_comptebloqu" andalso Opt=="opt_sms_illimite" ->
    case svc_util_of:do_consultation(S, list_to_atom(Opt)) of  
        % Please change "ok" (in next line) to "ok_operation_effectuee" for sachem_tuxedo. I changed it to "ok" to make it work with X25 - hoangtt
	{ok, [Zone70, _, _]} ->
	    case Zone70 of 
		L_VIDE when L_VIDE==[];L_VIDE==[[]] ->
		    {redirect, S, Url_bonus};
		[[_,_,DEB,FIN|_]] ->
			  svc_util_of:redirect_option_launched(S, DEB, FIN, 
							       Url_deja_souscrit, Url_bonus);
		[_,_,DEB,FIN|_] -> svc_util_of:redirect_option_launched(S, DEB, FIN, 
									Url_deja_souscrit, Url_bonus);
		Bad_z70 ->     slog:event(failure,?MODULE,bad_z70,Bad_z70) 
	    end;
   
	{ok, {Session_resp, Resp_params}} ->
            List_options = proplists:get_value("OP_PARAMS", Resp_params),
            case svc_sachem:get_option_info(list_to_atom(Opt), List_options) of                      
                [_,_,DEB,FIN|_] ->
                    svc_util_of:redirect_option_launched(Session_resp, DEB, FIN, 
                                                         Url_deja_souscrit, Url_bonus);
                _ ->
                    slog:event(failure, ?MODULE, unknown_option, {list_to_atom(Opt), List_options}),
                    {redirect, S, Url_erreur}
            end;     
	{nok_opt_inexistante_dossier,_} ->
	    {redirect, S, Url_bonus};
        {nok, Reason} ->
            slog:event(failure,?MODULE,redirect_by_bonus_do_consult,Reason),
            {redirect, S, Url_erreur};
	Else ->
            slog:event(failure,?MODULE,redirect_by_bonus_do_consult,Else),
	    {redirect, S, Url_erreur}
    end.

%% +type verif_num(session(),string(),string(),string(),string(),string())-> erlpage_result().
verif_num(Session, Subs, Opt, URL_ok, URL_nok, URL_back, URL_menu, Number) when 
  Subs=="monacell_prepaid" andalso Opt=="opt_sms_illimite"->    
    case Number of 
	"0" -> 
	    {redirect, Session, URL_back};
	"00" -> 
	    {redirect, Session, URL_menu};
	_ ->
	    case verif_saisie_num(Number,number) of
		true->	    
		    [$0,H|_] = Number,
		    %% numero de mobile de choix commence par 06
		    case H of 
			H_ when H_==$6;H_==$7 ->		    
			    %% enregistrer Number
			    %% passer au montant a confirmer avec choix client = 3
			    State  = svc_util_of:get_user_state(Session),
			    NState = State#sdp_user_state{numero_sms_illimite=Number},
			    NSession = svc_util_of:update_user_state(Session,NState),
			    case catch ocf_rdp:isMsisdnOrange(Number) of
				true ->
				    {redirect, NSession, URL_ok};
				false ->
				    {redirect, NSession, URL_nok};
				X ->
				    slog:event(failure, ?MODULE, ocf_rdp_no_answer, X),
				    throw(ocf_failure)
			    end;
			_ -> 
			    {redirect, Session, URL_nok}
		    end;
		_->
		    {redirect, Session, URL_nok}    
	    end
    end;

verif_num(Session, Subs, Opt, URL_ok, URL_nok, URL_back, URL_menu, Number) when 
  Subs=="monacell_comptebloqu" andalso Opt=="opt_sms_illimite"->    
    case Number of 
	"0" -> 
	    {redirect, Session, URL_back};
	"00" -> 
	    {redirect, Session, URL_menu};
	_ ->
	    case verif_saisie_num(Number,number) of
		true->	    
		    [$0,H|_] = Number,
		    %% numero de mobile de choix commence par 06
		    case H of 
			H_ when H_==$6;H_==$7 ->		    
			    %% enregistrer Number
			    %% passer au montant a confirmer avec choix client = 3
			    State  = svc_util_of:get_user_state(Session),
			    NState = State#sdp_user_state{numero_sms_illimite=Number},
			    NSession = svc_util_of:update_user_state(Session,NState),
			    case catch ocf_rdp:isMsisdnOrange(Number) of
				true ->
				    {redirect, NSession, URL_ok};
				false ->
				    {redirect, NSession, URL_nok};
				X ->
				    slog:event(failure, ?MODULE, ocf_rdp_no_answer, X),
				    throw(ocf_failure)
			    end;
			_ -> 
			    {redirect, Session, URL_nok}
		    end;
		_->
		    {redirect, Session, URL_nok}    
	    end
    end.

verif_saisie_num(Number,number) 
  when is_list(Number), length(Number)==10 ->        
    pbutil:all_digits(Number);

verif_saisie_num(_,_) ->
    false.
    

%%%% Do request of confirm
%% +type do_confirm(session(),Opt::string())-> erlpage_result().
%%do_confirm(#session{prof=Profile}=Session, Opt)->
do_confirm(#session{prof=#profile{subscription=Subs}}=Session, Opt, URL_ok, URL_nok, URL_erreur) when 
  Subs=="monacell_prepaid" andalso Opt=="opt_sms_illimite"->    
    case check_compte_solde(Session, "7", "cpte_princ") of 
	true -> 
	    case svc_options:do_opt_cpt_request(Session, list_to_atom(Opt), subscribe) of
		{Session1,{ok_operation_effectuee,_}} ->
		    {redirect, Session1, URL_ok};
		_ ->
		    {redirect, Session, URL_erreur}
	    end;	
	_ ->
	    {redirect, Session, URL_nok}
    end;

do_confirm(#session{prof=#profile{subscription=Subs}}=Session, Opt, URL_ok, URL_nok, URL_erreur) when 
  Subs=="monacell_comptebloqu" andalso Opt=="opt_sms_illimite"->    
    case check_compte_solde(Session, "5", "cpte_princ") of 
	true -> 
	    case svc_options:do_opt_cpt_request(Session, list_to_atom(Opt), subscribe) of
		{Session1,{ok_operation_effectuee,_}} ->
		    {redirect, Session1, URL_ok};
		_ ->
		    {redirect, Session, URL_erreur}
	    end;	
	_ ->
	    {redirect, Session, URL_nok}
    end.

check_compte_solde(Session, Solde, Cpte) ->    
    State = svc_util_of:get_user_state(Session),
    Curr=currency:sum(euro,list_to_integer(Solde)),
    SoldeCpte = svc_compte:solde_cpte(State, list_to_atom(Cpte)),
    catch currency:is_infeq(Curr,SoldeCpte).
    
