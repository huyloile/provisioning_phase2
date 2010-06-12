-module(svc_options_cmo).

%% XML export

-export([proposer_lien/4,
	 proposer_lien/5,
	 proposer_text/4,
	 first_page/6,
	 do_subscription/3,
	 do_unsubscription/3]).

%% Plugin export

-export([is_subscribed/2,
	 is_option_incomp/2,
	 print_incomp_opts/2]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pdist_orangef/include/spider.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% XML API INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS RELATED TO SUBSCRIPTION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type proposer_lien(session(),OPT::string(),
%%                     PDC_URLs::string(),BR::string()) ->
%%                     hlink().
%%%% Check whether link to subscription should be proposed in main menu.
%%%% Value of BR: "br" or "nobr".

proposer_lien(Session,OPT,PCD_URLs,BR)->
    proposer_lien(Session,OPT,PCD_URLs,BR,"").

%% +type proposer_lien(session(),Option::string(),PCD_URLs::string(),
%%                     BR::string(),Key::string())-> 
%%                     hlink().

proposer_lien(abs,_,PCD_URLs,BR,Key) ->
    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++svc_util_of:add_br(BR);

proposer_lien(Session,Option,PCD_URLs,BR,Key) 
  when Option=="opt_afterschool" ->
    Opt=list_to_atom(Option),
    State = svc_util_of:get_user_state(Session),
    case (svc_util_of:is_plug(State) or svc_util_of:is_zap(State))
	and svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false -> 
	    []
    end;
proposer_lien(Session,Option,PCD_URLs,BR,Key)
  when Option=="opt_jinf" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    D = State#sdp_user_state.declinaison,
    case svc_util_of:is_commercially_launched(Session,Opt) and
	svc_util_of:is_good_plage_horaire(Opt) and
 	lists:member(D, [1,2,3,4,5,6,7,8,9,10,13,14,15]) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false -> 
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,Key)
  when Option == "opt_sinf";
       Option == "opt_weinf";
       Option == "opt_ssms" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    DateActiv = State#sdp_user_state.d_activ,
    case svc_util_of:is_good_plage_horaire(Opt)
	and svc_util_of:is_commercially_launched(Session,Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false -> 
	    []
    end;

proposer_lien(#session{prof=#profile{imsi=IMSI}}=Session,Option,PCD_URLs,BR,Key)
  when Option=="m5" ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case (svc_util_of:is_commercially_launched(Session,Opt) and 
	  svc_util_of:is_good_plage_horaire(Opt)) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false ->
	    []
    end;

proposer_lien(Session,Option,PCD_URLs,BR,Key) ->
    State = svc_util_of:get_user_state(Session),
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(Session,Opt) and 
	svc_util_of:is_good_plage_horaire(Opt) of
	true ->
	    [{PCD,URL}]=svc_util_of:dec_pcd_urls(PCD_URLs),
	    [#hlink{href=URL,key=Key,contents=[{pcdata,PCD}]}]++
		svc_util_of:add_br(BR);
	false ->
	    []
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type first_page(session(),Opt::string(),
%%                  UAct::string(),UIncomp::string(),UInsuf::string(),
%%                  UGene::string())->
%%                  erlpage_result(). 
%%%% First page for subscription of option.
%%%% Redirect to UAct when option already active,
%%%% redirect to UIncomp when option incompatible with existing options,
%%%% redirect to UInsuf when not enough credit,
%%%% redirect to UGene when subscription proposed.
	
first_page(abs,Opt,UAct,UIncomp,UInsuf,UGene) ->
    [{redirect,abs,UAct},
     {redirect,abs,UIncomp},
     {redirect,abs,UInsuf},
     {redirect,abs,UGene}];

first_page(Session,Option,UAct,UIncomp,UInsuf,UGene) ->
    State = svc_util_of:get_user_state(Session),
    Opt = list_to_atom(Option),
    {Session_new,State_New} = svc_options:check_topnumlist(Session),
    case is_subscribed(Session_new,Opt) of
	true -> {redirect,Session_new,UAct};
	false ->
	    case is_option_incomp(Session_new,Opt) of
		true -> 
		    {redirect,Session_new,UIncomp};
		false ->
		    PrixSubscr =
			svc_util_of:subscription_price(Session_new, Opt),
		    Curr = currency:sum(euro,PrixSubscr/1000),
		    case {(svc_compte:etat_cpte(State_New,
						cpte_bons_plans)==?CETAT_AC),
			  svc_options:credit_bons_plans_ac(State_New,
							   {Curr,Opt})} of
			{true,true} -> 
			    {redirect,Session_new,UGene};
			{_,_} ->
			    case svc_options:enough_credit(cmo,State_New,Curr) of
				false ->
				    {redirect,Session_new,UInsuf};
				true  ->
				    {redirect,Session_new,UGene}
			    end
		    end
	    end
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription(session(),Option::string(),URLs::string())->
%%                       erlpage_result().
%%%% XML API Interface to subscription.

do_subscription(abs,_,URL) ->
    URL2 = string:tokens(URL, ","),
    lists:map(fun(U) -> {redirect,abs,U} end,URL2);

do_subscription(#session{}=S,Option,URL) ->
    do_subscription_request(S,list_to_atom(Option),URL).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type proposer_text(session(),Option::string(),Text::string(),
%%                     BR::string())->
%%                     [{pcdata,string()}].
%%%% Text to be displayed depending on the value of the configuration
%%%% parameter commercial_date_cmo for the option.

proposer_text(abs,_,Text,BR)->
    [{pcdata,Text}]++svc_util_of:add_br(BR);

proposer_text(S,Option,Text,BR)->
    Opt=list_to_atom(Option),
    case svc_util_of:is_commercially_launched(S,Opt) of
	true->
	    [{pcdata,Text}]++svc_util_of:add_br(BR);
	false ->
	    []++svc_util_of:add_br(BR)
    end.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS RELATED TO TERMINATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_unsubscription(session(),Opt::string(),URLs::string())->
%%                         erlpage_result().
%%%% XML API Interface to subscription termination.

do_unsubscription(abs,Option,URLs) ->
    [Uok,Unok] = string:tokens(URLs, ","),
    [{redirect,abs,Uok},{redirect, abs, Unok}];
do_unsubscription(#session{}=S,Option,URLs) ->
    do_unsubscription_request(S,list_to_atom(Option),URLs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS USED IN PLUGINS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_subscribed(session(),Opt::atom())->
%%                     bool().
%%%% Check whether subscription to option already exists.

is_subscribed(Session,Opt)
  when Opt==pack_sms;
       Opt==pack_mms;
       Opt==opt_tt_shuss;
	   Opt==opt_pack_duo_journee;
       Opt==opt_pass_vacances;
       Opt==opt_pass_vacances_v2;
	   Opt==opt_pass_voyage_6E;
       Opt==opt_roaming;
       Opt==opt_seminf;
       Opt==opt_afterschool;
       Opt==opt_jinf;
       Opt==opt_sms_surtaxe ->
    svc_options:is_option_activated(Session,Opt);

is_subscribed(Session,Opt) ->
    Subscr = svc_util_of:get_souscription(Session),
    State = svc_util_of:get_user_state(Session),
    case svc_compte:cpte(State,svc_options:opt_to_godet(Opt,Subscr)) of
        #compte{etat=?CETAT_AC}=CPTE ->
            svc_options:is_option_activated(Session,Opt);
        _ -> false
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_option_incomp(session(),Opt::string())->
%%                        bool().
%%%% Check incompatibilities between options.

is_option_incomp(Session,opt_pass_vacances) ->
    svc_options:is_option_activated(Session,opt_maghreb)
	or svc_options:is_option_activated(Session,opt_europe)
 	or svc_options:is_option_activated(Session,opt_roaming)
 	or svc_options:is_option_activated(Session,opt_voyage);

is_option_incomp(Session,Opt)
when Opt==opt_pass_vacances_v2;
	 Opt==opt_pass_voyage_6E ->
    is_option_incomp(Session,opt_pass_vacances);

is_option_incomp(Session,opt_europe) ->
    svc_options:is_option_activated(Session,opt_maghreb)
		or svc_options:is_option_activated(Session,opt_roaming)
		or svc_options:is_option_activated(Session,opt_pass_vacances)
		or svc_options:is_option_activated(Session,opt_pass_vacances_v2)
		or svc_options:is_option_activated(Session,opt_pass_voyage_6E)
		or svc_options:is_option_activated(Session,opt_voyage);

is_option_incomp(Session,opt_maghreb) ->
    svc_options:is_option_activated(Session,opt_europe)
		or svc_options:is_option_activated(Session,opt_roaming)
		or svc_options:is_option_activated(Session,opt_pass_vacances)
		or svc_options:is_option_activated(Session,opt_pass_vacances_v2)
		or svc_options:is_option_activated(Session,opt_pass_voyage_6E)
		or svc_options:is_option_activated(Session,opt_voyage);

is_option_incomp(Session,opt_voyage) ->
    svc_options:is_option_activated(Session,opt_europe)
		or svc_options:is_option_activated(Session,opt_maghreb)
		or svc_options:is_option_activated(Session,opt_pass_vacances)
		or svc_options:is_option_activated(Session,opt_pass_vacances_v2)
		or svc_options:is_option_activated(Session,opt_pass_voyage_6E)
		or svc_options:is_option_activated(Session,opt_roaming);

is_option_incomp(Session,opt_ssms) ->
    svc_options:is_option_activated(Session,opt_sms_hebdo);

is_option_incomp(Session,Opt)
when Opt==opt_tt_shuss;Opt==opt_pack_duo_journee ->
    svc_options:is_option_activated(Session,opt_vacances);

is_option_incomp(Session,opt_vacances) ->
    svc_options:is_option_activated(Session,opt_pack_duo_journee);

is_option_incomp(Session,opt_erech_smsmms) ->
    svc_options:is_option_activated(Session,opt_pack_duo_journee) or
	svc_options:is_option_activated(Session,opt_vacances);

is_option_incomp(Session,opt_jinf) ->
    svc_options:is_option_activated(Session,opt_sinf) or
	svc_options:is_option_activated(Session,opt_seminf);

is_option_incomp(Session,opt_sinf) ->
    svc_options:is_option_activated(Session,opt_jinf) or
	svc_options:is_option_activated(Session,opt_seminf);

is_option_incomp(Session,opt_seminf) ->
    svc_options:is_option_activated(Session,opt_jinf) or
	svc_options:is_option_activated(Session,opt_sinf);

is_option_incomp(_,_) -> false.


%% +type print_incomp_opts(session(),Option::string())-> 
%%                        [{pcdata,string()}].
%%%% Print list of incompatible options.

print_incomp_opts(abs, _)->
    [{pcdata,""}]++get_opt_incomp(abs, [], [""]);
print_incomp_opts(Session, Option)
  when Option == "opt_pass_vacances" ->
    {Session1,State_} = svc_options:check_topnumlist(Session), 
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_maghreb","opt_pass_voyage_9E"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_pass_vacances_v2";Option == "opt_pass_voyage_6E" ->
    {Session1,State_} = svc_options:check_topnumlist(Session),
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_maghreb", "opt_pass_supporter","opt_pass_voyage_9E","opt_pass_dom"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_pass_vacances_z2";Option == "opt_pass_voyage_9E" ->
    {Session1,State_} = svc_options:check_topnumlist(Session),
    Opt = list_to_atom(Option),
    List_opt = ["opt_europe", "opt_maghreb", "opt_pass_voyage_6E","opt_pass_dom"],
    get_opt_incomp(Session1, List_opt, "");

print_incomp_opts(Session, Option)
  when Option == "opt_europe" ->
    {Session1,State_} = svc_options:check_topnumlist(Session),
    Opt = list_to_atom(Option),
    List_opt = ["opt_pass_voyage_6E", "opt_pass_voyage_9E", "opt_maghreb"],
    get_opt_incomp(Session1, List_opt, "");
print_incomp_opts(Session, Option)
  when Option == "opt_maghreb" ->
    {Session1,State_} = svc_options:check_topnumlist(Session),
    Opt = list_to_atom(Option),
    List_opt = ["opt_pass_voyage_6E", "opt_pass_voyage_9E", "opt_europe"],
    get_opt_incomp(Session1, List_opt, "").


%% +type get_opt_incomp(session(),ListOpt::[string()], Accu::[string()])-> 
%%                        [{pcdata,string()}].
%%%% Internal function used to find out all incompatibles
%%%% options with the second argument.
get_opt_incomp(abs, [], [""])->
    [{pcdata,"Any incompatibility found"}];
get_opt_incomp(Session, [Opt|Tail], Accu)
  when Opt == "opt_edition_special" ->
    Option = list_to_atom(Opt),
    State = svc_util_of:get_user_state(Session),
    case (svc_compte:etat_cpte(State,cpte_avoix)==?CETAT_AC) of
	true ->
	 [{pcdata,Name}] = svc_options:print_commercial_name(Session, Opt),
	    NewAccu = lists:concat([Accu,separator(Accu),Name]),
	    get_opt_incomp(Session, Tail,NewAccu);
	_->
	  get_opt_incomp(Session, Tail, Accu)
    end;
get_opt_incomp(Session, [Opt|Tail], Accu)->
    Option = list_to_atom(Opt),
    case svc_options:is_option_activated(Session,Option) of
	true ->
	 [{pcdata,Name}] = svc_options:print_commercial_name(Session, Opt),
	    NewAccu = lists:concat([Accu,separator(Accu),Name]),
	    get_opt_incomp(Session, Tail,NewAccu);
	_->
	  get_opt_incomp(Session, Tail, Accu)
    end;
get_opt_incomp(Session,[],Accu) ->
    [{pcdata,Accu}].

%% +type separator(Accu::[string()])-> [string()].    
separator(Accu)->
    case Accu of
	"" ->
	    Accu;
	_ ->
	    '; '
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTERNAL FUNCTIONS TO THIS MODULE, NOT TO BE CALLED FROM OTHER MOUDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TERMINATION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_unsubscription_request(session(),Opt::string(),URLs::string())->
%%                                 erlpage_result().
%%%% Terminate subscription to options.

do_unsubscription_request(#session{prof=Prof}=S,Opt,URLs)
 when Opt==opt_sms_quoti;
      Opt==opt_tv_renouv ->
    [Uok,Unok] = string:tokens(URLs, ","),
    case svc_options:do_opt_cpt_request(S,Opt,terminate) of
	{Session1,{ok_operation_effectuee,_}} ->
	    {_,Session_}= svc_util_of:reinit_compte(Session1),
	    {redirect,Session_,Uok};
	{Session1,E} ->
	    slog:event(failure, ?MODULE, bad_response_from_sdp, E),
	    {redirect, Session1, Unok}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUBSCRIPTION FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type do_subscription_request(session(),Opt::string(),URL_OK::string())->
%%                               erlpage_result().
%%%% Subscribe to options.

do_subscription_request(#session{prof=Prof}=Session,Opt,URLs) 
  when Opt==opt_weinf;
       Opt==opt_sms_quoti;
       Opt==opt_maghreb;
       Opt==opt_europe;
       Opt==opt_vacances;
       Opt==opt_sinf;
       Opt==opt_ssms;
       Opt==opt_voyage;
       Opt==opt_afterschool;
       Opt==opt_afterschool_promo;
       Opt==opt_jinf ->
    [UAct,UInsuf,URL_OK] = string:tokens(URLs, ","),
    State = svc_util_of:get_user_state(Session),
    {Session1,Result} = svc_options:do_opt_cpt_request(Session,Opt,subscribe),
    Unok = "#failure",
    svc_options:redirect_update_option(Session1, Result, URL_OK, 
                                       UAct, UInsuf, Unok, Unok);

do_subscription_request(Session,Opt,URLs) 
  when Opt==opt_ow ->
    [UAct,UInsuf,URL_OK] = string:tokens(URLs, ","),  
    State = svc_util_of:get_user_state(Session),
    #sdp_user_state{dos_numid=DOSNUM} = State,
    Price = svc_util_of:subscription_price(Session, Opt),
    Prix = trunc(Price),
    case catch tlv_router:mk_INT_ID27(cmo,DOSNUM,num_transf(Opt)) of
 	[CPP_SOLDE,0,0] ->
 	    case catch tlv_router:mk_INT_ID14(cmo,DOSNUM,num_prest(Opt),
					      Prix,?EURO,0,?C_PRINC) of
 		[CPP_SOLDEAfterID14,0,0] ->
		    WasDebited=(CPP_SOLDE-CPP_SOLDEAfterID14 == Prix/1000),
		    if (WasDebited==false) ->
			    slog:event(warning,?MODULE,transfert_prestation,
				       not_debited_by_sachem);
		       true ->
			    ok
		    end,
		    %% reset les informations du compte client
		    {_,Session_}= svc_util_of:reinit_compte(Session),
 		    {redirect,Session_,URL_OK};
 		Error ->
 		    slog:event(failure,?MODULE,Opt,
			       {tlv_int_id14,dec_tlv_err(Error)}),
 		    {redirect,Session,"#failure"}
 	    end;
 	Error ->
 	    slog:event(failure,?MODULE,Opt,{tlv_int_id27,dec_tlv_err(Error)}),
 	    {redirect,Session,"#failure"}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type dec_tlv_err(term())-> term().
%%%% Decode errors received from TLV.

dec_tlv_err([178,0]) -> le_transfert_nexiste_pas;
dec_tlv_err(E) -> E.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type num_transf(atom())-> integer().
%%%% Translate option to transfer number.

num_transf(opt_ssms)        -> ?NUMTRANS_SSMS_CMO;
num_transf(opt_afterschool) -> ?NUMTRANS_AFTER_CMO;
num_transf(opt_voyage)      -> ?NUMTRANS_VOY_CMO.   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type num_prest(atom())-> integer().
%%%% Translate option to number.

num_prest(opt_ssms)        -> ?NUMPREST_SSMS_CMO;
num_prest(opt_afterschool) -> ?NUMPREST_AFTER_CMO;
num_prest(opt_voyage)      -> ?NUMPREST_VOY_CMO.
