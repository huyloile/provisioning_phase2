-module(svc_sachem).

%%%% Integration and Maintenance APIs
-export([sachem_offline/4, svc_sachem_offline/2]).

%%%% Sachem Requests APIs adapted to Orange France Services
%%%% calls sachem:consult_account CSL_DOSCP <=> A4/A5
-export([consult_account/1, consult_account/2, consult_account/3]).
-export([update_sachem_user_state/1, update_sachem_user_state/2]).
-export([get_accounts_from_resp/1, get_account_from_resp/2]).
-export([get_dos_numid/1]).
%%%% calls sachem:consult_account_options CSL_OP <=> C_OP2
-export([consult_account_options/1,consult_account_options/2,consult_account_options/3]).
-export([consult_options_list/1]).
-export([consult_options_info/1, consult_option_info/2]).
-export([get_options_info/1, get_option_info/2]).
-export([get_msisdns_info/1, get_msisdn_info/2]).
-export([get_options_tg_info/1]).
-export([consult_msisdn_list/1]).
-export([get_top_num_list/1]).
%%%% calls sachem:consult_recharge_ticket and sachem:recharge_ticket
%%%% CSL_TCK <=> C_TCK and REQ_TCK <=> D5/D6
-export([consult_recharge_ticket/2,consult_recharge_ticket/3]).
-export([recharge_ticket/2,recharge_ticket/3]).
%%%% calls sachem:change_user_account MOD_CP <=> G2
-export([change_user_account/2]).
%%%% calls sachem:update_account_options MAJ_OP <=> OPT_CPT2
-export([update_account_options/2]). 
%%%% calls sachem:handle_options MAJ_NOPT <=> NOPT_CPT
-export([handle_options/2]). 
%%%% calls sachem:transfert_credit TRA_CREDIT <=> NTRD
-export([transfer_credit/3]).
%%%% calls sachem:gen_param_value CSL_PARAM_GEN <=> CI3

-export([format_to_int/1]).

%%%% FOR TESTS
%%-export([filled_opt_cpt/1]).
%%-export([update_optional_values/2]).

-include("../include/ftmtlv.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/include/sdp.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OFFLINE APIs %%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type sachem_offline(atom, string(), list(), list()) ->
%%                         
%%%% Offline call of sachem requests
%%%% Function used for tests 
sachem_offline(Function_name, Msisdn, MParamList, OptParaList) ->
    Session = #session{prof = #profile{msisdn = Msisdn}},
    apply(sachem, Function_name, [Session, MParamList, OptParaList]).

%% +type svc_sachem_offline(atom, string(), list(), list()) ->
%%                         
%%%% Offline call of sachem requests
%%%% Function used for tests 
svc_sachem_offline(Function_name, ParamList) ->
    Session = #session{prof = #profile{}},
    Session_new = variable:update_value(Session, user_state, 
                          #sdp_user_state{}),
    apply(?MODULE, Function_name, [Session_new | ParamList]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type consult_account(session()) ->
%%                         {ok, {session(),[tuple()]} 
%%                       | {nok, session()}
%%%% Consult accounts of a user
%%%% Replaces the old A4/A5 Sachem requests
%%%% Default values for service :
%%%% CLE = 0 => IDENTIFIANT = Msisdn, 
%%%% DOS_ACTIV = 1 to activate the account
consult_account(Session) ->
    consult_account(Session, "1").

%% +type consult_account(session(), tuple()|string()) ->
%%                         {ok, {session(),[tuple()]} 
%%                       | {nok, session()}
%%%% Enable either to modify {CLE,IDENTIFIANT} or DOS_ACTIV
consult_account(#session{}=Session, {CLE, IDENTIFIANT}) ->
    consult_account(Session, {CLE, IDENTIFIANT}, "1");
consult_account(#session{prof=Profile}=Session, DOS_ACTIV) ->
    case {Profile#profile.msisdn, Profile#profile.imsi} of
        {{na,_}, {na,_}} ->
            %% This will cause the SDP request to fail
            slog:event(internal, ?MODULE, imsi_msisdn_empty, Profile),
            {nok, Session};
        {{na,_}, IMSI} -> 
            consult_account(Session, {"1", IMSI}, DOS_ACTIV);
        {MSISDN, _}    ->
            consult_account(Session, {"0", MSISDN}, DOS_ACTIV)
    end.

%% +type consult_account(session(), tuple(), string()) ->
%%                         {ok, {session(),[tuple()]} 
%%                       | {nok, session()}
%%%% Consult accounts of a user and updates sdp_user_state
consult_account(#session{}=Session, {CLE, Identifiant}, DOS_ACTIV) 
  when list(DOS_ACTIV) ->
    Identifiant_nat = case CLE of
                      "0" -> svc_util_of:int_to_nat(Identifiant);
                      _   -> Identifiant
                  end,
    Mandatory_params = [{"CLE", CLE}, {"IDENTIFIANT", Identifiant_nat}],
    Optional_params = [{"DOS_ACTIV",DOS_ACTIV}],                     
    send_consult_account(Session, Mandatory_params, Optional_params).

%%                         {ok, {session(),[tuple()]} 
%%                       | {nok, session()}
%%%% Send consult_account request to Sachem
send_consult_account(Session, Mandatory_params, Optional_params)->
    case sachem:consult_account(Session, 
                                Mandatory_params, Optional_params) of
        {ok, {Session_resp, Resp_params}} -> 
            State_updated = update_sachem_user_state(Session_resp, Resp_params),
            Session_updated = svc_util_of:update_user_state(Session, State_updated),
            {ok, {Session_updated, Resp_params}};
        {nok, Reason} -> 
            slog:event(failure, ?MODULE, send_consult_account, 
                           {Reason, 
                            input_parameters, Mandatory_params, Optional_params}),
            {nok, Reason}
    end.

%% +type update_user_state(session(), list()) ->
%%                         {ok|nok, sdp_user_state()} 
%%%% sends consult_account default request and Updates User State 
update_sachem_user_state(Session) ->
    case consult_account(Session) of
        {ok, {Session_resp, Resp_params}} ->
            {ok, update_sachem_user_state(Session_resp, Resp_params)};                    
        {nok, _} ->
            {nok, svc_util_of:get_user_state(Session)}
    end.       
%% +type update_user_state(session(), list()) ->
%%                         sdp_user_state() 
%%%% Update User State according to consult_account response
%%%% svc_sachem:consult_account must be called first :
%%%% Resp_params = svc_sachem:consult_account
update_sachem_user_state(Session, Resp_params) ->
    State_updated = set_user_state(Session, Resp_params),
    List_accounts = get_accounts_from_resp(Resp_params),
    set_accounts(State_updated, List_accounts).


%%%% Update User information in sdp_user_state
%%%% Attention: list_to_integer will crash if the output is not defined!
set_user_state(Session, Resp_params) ->
    State = svc_util_of:get_user_state(Session),
    case Resp_params of
        []->State;
        _->
            Etat_princ = format_to_int(proplists:get_value("EPR_NUM", Resp_params)),
            State_1 = svc_util_of:decode_etat_princ(Etat_princ, State),
            Date_limite_validite = 
            case proplists:get_value("DOS_DATE_LV",Resp_params) of
                %% force to zero because -1 + unixtime can cause crash
                "-1" -> 
                    slog:event(trace, ?MODULE, 
                        date_limite_validite_forced, Resp_params),
                    ?OFFSET_TZ;             
                Date -> format_to_int(Date) + ?OFFSET_TZ
            end,
            State_1#sdp_user_state{                              
                %% parameters common to A4/A5
                dos_numid   = format_to_int(proplists:get_value("DOS_NUMID",Resp_params)),
                msisdn      = svc_util_of:int_to_nat(
                    proplists:get_value("DOS_MSISDN", Resp_params)),
                imsi        = proplists:get_value("DOS_IMSI",   Resp_params),
                declinaison = format_to_int(proplists:get_value("DCL_NUM", Resp_params)),
                etats_sec   = format_to_int(proplists:get_value("ESC_NUM_LONG", Resp_params)),
                %% option      = OPTION, %% HAS CHANGED FORMAT
                d_activ     = format_to_int(proplists:get_value("DOS_DATE_ACTIV", Resp_params)),
                dlv         = Date_limite_validite,
                d_der_rec   = format_to_int(proplists:get_value("DOS_DATE_DER_REC", Resp_params)),
                langue      = proplists:get_value("LNG_NUM", Resp_params),
                etat_princ  = Etat_princ,
                %% cpte_princ  = proplists:get_value("", Resp_params), %% done elsewhere
                %% cpte_list   = proplists:get_value("", Resp_params), %% done elsewhere
                %% malin,     %% suppressed in CSL_DOSCP
                %% acces,     %% suppressed in CSL_DOSCP
                %% dtmn,      %% suppressed in CSL_DOSCP
                %%%% added in CSL_DOSCP
                nsce        = proplists:get_value("DOS_NSCE", Resp_params),
                abonn_cmo   = proplists:get_value("DOS_ABONNEMENT", Resp_params),
                kit_num     = format_to_int(proplists:get_value("KIT_NUM", Resp_params)),
                d_creation  = format_to_int(proplists:get_value("DOS_DATE_CREATION", Resp_params)),
                d_chg_etat  = format_to_int(proplists:get_value("DOS_DATE_ETAT", Resp_params)),
                err_rechg   = format_to_int(proplists:get_value("DOS_ERR_REC", Resp_params)),
                imei        = proplists:get_value("DOS_IMEI", Resp_params),
                ofr_num     = format_to_int(proplists:get_value("OFR_NUM",  Resp_params)),
                code_rechg  = proplists:get_value("DOS_CODE_REC", Resp_params),
                cumul_mois  = proplists:get_value("DOS_CUMUL_MOIS",  Resp_params),
                plaf_rechg  = proplists:get_value("DOS_PLAFOND_REC", Resp_params),
                mnt_rechg   = proplists:get_value("DOS_MONTANT_REC", Resp_params),                       
                d_der_rec_cmo=proplists:get_value("DOS_DATE_REC", Resp_params),
                d_deb_fidel = proplists:get_value("DOS_DATE_DEB_FID", Resp_params),
                bon_pct_fid = format_to_int(proplists:get_value("DOS_BON_PCT", Resp_params))
            }
    end.     

%% +type get_accounts_from_resp(proplist()) ->
%%                    list() 
%%%% Get list of accounts for the user
%%%% from the response to the request consult_account
%%%% or from the request recharge_ticket
get_accounts_from_resp(Resp_params) ->
    case proplists:get_value("CPT_PARAMS", Resp_params) of
        undefined ->
            slog:event(warning, ?MODULE, get_account_from_resp, Resp_params),
            [];
        Accounts_list -> Accounts_list
    end.
    


%% +type get_account_from_resp(proplist(), integer()) ->
%%                    compte()
%%%% Get specific Account with TCP_NUM
%%%% from the response to the request consult_account
%%%% or from the request recharge_ticket
get_account_from_resp(Resp_params, TCP_NUM) when integer(TCP_NUM) ->
    Accounts_list = get_accounts_from_resp(Resp_params),
    case get_account_from_list(Accounts_list, integer_to_list(TCP_NUM)) of
        undefined ->
            slog:event(warning, ?MODULE, get_account_from_resp_undef,
                       {Resp_params, TCP_NUM}),
            undefined;
        Compte -> Compte
    end.

get_account_from_list([], _) ->
    undefined;
get_account_from_list([Compte|Comptes], TCP_NUM) ->
    case Compte of
        [TCP_NUM|_] ->
            Compte;
        _ -> get_account_from_list(Comptes, TCP_NUM)
    end.

%% +type set_accounts(sdp_user_state(), list()) ->
%%                    sdp_user_state(
%%%% Update accounts info in sdp_user_state
%%%% According to the response of CSL_DOSCP
set_accounts(State, [])  ->
    State;
set_accounts(State, [Account|Rest]) ->
    case Account of
        [TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
         CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION, 
         CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP] ->
            %% Adjust DLV to handle "-1" which "might" mean infinity
            Dlv = case CPP_DATE_LV of
                      "-1" -> 
                          slog:event(trace, ?MODULE, 
                                     date_limite_validite_forced, Account),
                          0; %% value to be verified
                      Date -> format_to_int(Date)
                  end,
            Compte=#compte{tcp_num = format_to_int(TCP_NUM),
                           unt_num = format_to_int(UNT_NUM),
                           cpp_solde=svc_compte:calcul_solde(
                                       format_to_int(CPP_SOLDE),
                                       format_to_int(UNT_NUM)),
                           %%format_to_int(CPP_SOLDE),
                           dlv     = Dlv,
                           rnv     = format_to_int(RNV_NUM),
                           etat    = format_to_int(ECP_NUM),
                           ptf_num = format_to_int(PTF_NUM),
                           cpp_cumul_credit=format_to_int(CPP_CUMUL_CREDIT),
                           %% pct  = PCT %% removed from CSL_DOSCP
                           %% anciennete=%% removed from CSL_DOSCP
                           %% mnt_init=, %% removed from CSL_DOSCP
                           %% top_num =, %% removed from CSL_DOSCP
                           %% mnt_bonus=,%% removed from CSL_DOSCP
                           d_crea  = format_to_int(CPP_DATE_CREA),
                           d_modif = format_to_int(CPP_DATE_MODIF),
                           cpt_dest= format_to_int(CPP_DESTINATION),
                           dlv_type= format_to_int(TYPE_DLV),
                           opt_tcp = format_to_int(OPT_TCP)                           
                          },
            State_updated = svc_compte:add_compte(format_to_int(TCP_NUM),
                                                  Compte,State),
            set_accounts(State_updated, Rest);
        _ ->
            slog:event(failure, ?MODULE, bad_account_format, Account),
            State
    end.


%% +type get_options_list(session()) ->
%%                       {options, list()}|[]
%%%% send consult_account request to
%%%% get the list of top_num of options subscribed by the user account
%%%% Does not update user State
get_options_list(Session) ->
    case consult_account(Session) of
        {ok, {Session_resp, Resp_params}} ->
            get_options_list(Session_resp, Resp_params);
        {nok, Error} -> 
            slog:failure(failure, ?MODULE, get_options_list, Error),
            []
    end.

%%%% doesn't seem to work
get_options_list(_, Resp_params) ->
    Get_param_value = 
        fun(Elem) -> 
                Value = proplists:get_value(Elem,Resp_params),
                list_to_integer(Value)
        end, 
    DOS_OPTIONS = lists:map(Get_param_value,
                            ["DOS_OPTION", 
                             "DOS_OPTION2",
                             "DOS_OPTION3",
                             "DOS_OPTION4",
                             "DOS_OPTION5",
                             "DOS_OPTION6",
                             "DOS_OPTION7",
                             "DOS_OPTION8"]),    
    {options, decode_top_num_list(DOS_OPTIONS)}.

%% +type decode_top_num_list([integer()])-> TOP_NUM::[integer()].
decode_top_num_list([F1,F2,F3,F4,F5,F6,F7,F8]=List)->
    lists:flatten(decode_top_field(F1,0,31)++
                  decode_top_field(F2,32,31)++
                  decode_top_field(F3,64,31)++
                  decode_top_field(F4,96,31)++
 		  decode_top_field(F5,128,31)++
 		  decode_top_field(F6,160,31)++
 		  decode_top_field(F7,192,31)++
		  decode_top_field(F8,224,31)).

%% +type decode_top_field(integer(),integer(),integer())-> [integer()].
decode_top_field(B_F,TOP_MIN,NO_BIT)->
    lists:foldl(fun(X,Acc)->
			case (B_F band (1 bsl X))=/=0 of
                            true->
                                [TOP_MIN+X,Acc];
                            false ->
                                Acc
                        end 
                end,
                [],lists:seq(0,NO_BIT)).


%% +type get_do_numid(session()) -> integer()
%%%% Returns do_numid in integer format
%%%% Either from the #session record
%%%% Or by calling consult_account request
get_dos_numid(#session{prof=Prof}=Session) ->
    Msisdn = Prof#profile.msisdn,
    State = svc_util_of:get_user_state(Session),
    case State#sdp_user_state.dos_numid of
        undefined -> 
            case update_sachem_user_state(Session) of
                {ok, State_new} ->
                    Session_new = svc_util_of:update_user_state(Session, State_new),
                    {Session_new,State_new#sdp_user_state.dos_numid};
                _ ->
                    slog:event(failure, ?MODULE, get_dos_numid,Msisdn),                               
                    {Session,undefined}
            end;
        Dos_numid when integer(Dos_numid) -> 
            {Session,Dos_numid}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type consult_account_options(session()) ->
%%                        {ok, {session(), [tuple()]}}
%%                      | {nok, string()}
%%%% CSL_OP => consult_account_options()
%%%% New version of C_OP2 (Sachem X25)
%%%% Consultation des options d'un dossier
consult_account_options(Session) ->
    {Session1,Dos_numid} = get_dos_numid(Session),
    consult_account_options(Session1, Dos_numid, []).

%% +type consult_account_options(session(), string()|tuple()) ->
consult_account_options(Session, {PCT_MONTANT, UNT_NUM}) ->   
    {Session1,Dos_numid} = get_dos_numid(Session),
    consult_account_options(Session1, Dos_numid, {PCT_MONTANT, UNT_NUM});
consult_account_options(Session, Dos_numid) ->
    consult_account_options(Session, Dos_numid, []).

%% +type consult_account_options(session(), integer()|string(), tuple()) ->
consult_account_options(Session, DOS_NUMID, Montant) 
  when integer(DOS_NUMID) ->
    Mandatory_params = [{"DOS_NUMID", integer_to_list(DOS_NUMID)}],
    Optional_params = case Montant of
                          {PCT_MONTANT, UNT_NUM} ->
                              [{"PCT_MONTANT", format_to_list(PCT_MONTANT)}, 
                               {"UNT_NUM",     format_to_list(UNT_NUM)}];
                          [] -> []
                      end,            
    case sachem:consult_account_options(Session, 
                                        Mandatory_params, Optional_params) of
        {ok, {USession, Resp_params}} ->   
            State = svc_util_of:get_user_state(USession),              
            Options_list = get_options_info(Resp_params),
            State_options = svc_compte:decode_z70(Options_list, State),      
            Top_num_list = get_top_num_list(Options_list),
            State_top_num_list = State_options#sdp_user_state{
                                   topNumList=Top_num_list},            
            Session_updated = svc_util_of:update_user_state(USession,
                                                            State_top_num_list),
            {ok, {Session_updated, Resp_params}};
        {nok, Reason} -> 
            slog:event(warning, ?MODULE, consult_account_options,
                       {Reason, 
                        input_parameters, Mandatory_params, Optional_params}),            
            {nok, Reason}
    end;
consult_account_options(#session{prof=Profile}=Session, DOS_NUMID, _) 
  when DOS_NUMID==undefined ->
    Msisdn = Profile#profile.msisdn,
    slog:event(warning, ?MODULE, consult_account_options, 
               {undefined_dos_numid, Msisdn}),
    {nok, undefined_dos_numid}.

%% +type consult_options_info(session(), string()|atom()) ->
%%                        list()
%%%% Replaces old c_op2() when we input "NULL"
consult_options_info(Session) ->
    case consult_account_options(Session) of
        {ok, {UpdatedSession, Resp_params}} ->
            {UpdatedSession, get_options_info(Resp_params)};
        {nok, _} ->
            []
    end.

%% +type get_options_info(string()|atom()) ->
%%                        list()
%%%% Replaces old c_op2() when we input "NULL"
%%%% input is response of consult_account_options
%%%% Returns the field OP_PARAMS (list of options of this account)
%%%% corresponding to old Zone 70 in X25
get_options_info(Resp_params) ->
    Nb_options =  proplists:get_value("NB_OP", Resp_params),
    case list_to_integer(Nb_options) of
        0 ->
            [];
        _ ->
            proplists:get_value("OP_PARAMS", Resp_params)            
    end.

%% +type consult_option_info(session(), string()|atom()) ->
%%                        list()
%%%% Replaces old c_op2() when we input top_num
%%%% returns details about option with specific Top_num
consult_option_info(Session, Top_num)  ->
    {UpdatedSession, List_options} = consult_options_info(Session),
    {UpdatedSession, get_option_info(Top_num, List_options)}.


%% +type get_option_info(integer(), list()) ->
%%                        list()
%%%% returns option info for Top_num from the
%%%% response of get_options_info
%%%% This function is equivalent to the old C_OP2
%%%% and returns the Zone70 equivalent to Top_num
get_option_info("NULL", List_options) ->
    List_options;

get_option_info(Top_num, List_options) when integer(Top_num)->
    get_option_info(integer_to_list(Top_num), List_options);

get_option_info(_, Empty) 
  when Empty==[];
       Empty==[[]]->
    [];
get_option_info(Top_num, [[Top_num|Rest_of_info]|Rest_of_options]) ->
    [Top_num|Rest_of_info];
get_option_info(Top_num, [[Top_num_other|Rest_of_info]|Rest_of_options]) when 
  Top_num /= Top_num_other ->
    get_option_info(Top_num, Rest_of_options). 
    
%% +type consult_options_list(session(), list()) ->
%%                       list()|[]
%%%% get the list of top_num of options subscribed by the user account
%%%% Does not update user State
consult_options_list(Session) ->
    {UpdatedSession, Options_list} = consult_options_info(Session),
    {UpdatedSession, get_top_num_list(Options_list)}.


get_top_num_list(Options) ->
    get_top_num_list(Options,[]).

get_top_num_list([], Top_nums) ->
    Top_nums;
get_top_num_list([Option|Tail], Top_nums) ->
    case Option of 
        [Top_num|_] ->
            Top_num_int = 
                if list(Top_num) -> list_to_integer(Top_num);
                   true -> Top_num
                end,
            get_top_num_list(Tail, [Top_num_int|Top_nums]);
        _ ->
            slog:event(internal, ?MODULE, unexpected_option, Option),
            get_top_num_list([], Top_nums)
    end.
    

%% +type consult_msisdn_list(session(), string()|atom()) ->
%%                        ko|list()
%%%% Replaces old c_op2() when we input top_num
%%%% get details about option with specific Top_num
consult_msisdn_list(Session) ->
    case consult_account_options(Session) of
        {ok, {_, Resp_params}} ->
            get_msisdns_info(Resp_params);
        Error -> 
            slog:event(warning, ?MODULE, consult_msisdn_list, Error),
            []
    end.

%% +type get_msisdns_info(list())-> list().
%%%% Input is response of consult_account_options
%%%% Returns the field NB_OCC_PARAMS 
%%%% corresponding to old Zone 80 in X25
%%%% "MSISDNs remontes toutes options confondues"
get_msisdns_info(Resp_params) ->
    Nb_msisdn = proplists:get_value("NB_OCC", Resp_params),
    case list_to_integer(Nb_msisdn) of
        0 -> [];
        _ ->                                                             
            proplists:get_value("NB_OCC_PARAMS", Resp_params)
    end.
    

%% +type get_msisdn_info(msisdn(), list()) ->
%%                        list()
%%%% returns option info for Msisdn from the
%%%% list of Msisdns related to the account
%%%% returned from get_msisdns_info
%%%% This function is equivalent to the old C_OP2
%%%% and returns the Zone80 equivalent to Msisdn
get_msisdn_info("NULL", List_msisdns) ->
    List_msisdns;
get_msisdn_info(_, []) ->
    no_msisdn;
get_msisdn_info(Msisdn, [[Msisdn|Rest_of_info]|Rest_of_msisdns]) ->
    [Msisdn|Rest_of_info];
get_msisdn_info(Msisdn, [[Msisdn_other|Rest_of_info]|Rest_of_msisdns]) when 
  Msisdn /= Msisdn_other ->
    get_msisdn_info(Msisdn, Rest_of_msisdns). 


%% +type get_options_tg_info(list())-> list().
%%%% Input is response of consult_account_options
%%%% Returns the field OP_TG_PARAMS
%%%% corresponding to old Zone 90 in X25
%%%% "options TG trouves dans la table COMPTEUR_TG pour ce dossier"
get_options_tg_info(Resp_params) ->
    Nb_opt_tg = proplists:get_value("NB_OP_TG", Resp_params),
    case list_to_integer(Nb_opt_tg) of
        0 -> [];
        _ ->                                                             
            proplists:get_value("OP_TG_PARAMS", Resp_params)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type consult_recharge_ticket(session(), string()) ->
%%                         list()|ko
%%%% CSL_TCK   => consult_recharge_ticket()                      
%%%% New version of C_TCK (Sachem X25)
%%%% Consultation d'un ticket de rechargement
consult_recharge_ticket(#session{prof=Profile}=Session, Ticket_rechg) ->
    consult_recharge_ticket(#session{prof=Profile}=Session, Ticket_rechg, []).

consult_recharge_ticket(#session{prof=Profile}=Session, Ticket_rechg, []) ->
    Msisdn = Profile#profile.msisdn,
    consult_recharge_ticket(Session, Ticket_rechg, "2", Msisdn);
consult_recharge_ticket(Session, Ticket_rechg, Msisdn) ->
    consult_recharge_ticket(Session, Ticket_rechg, "2", Msisdn).

consult_recharge_ticket(Session, Ticket_rechg, 
                        Type_cle, Msisdn) ->
    Mandatory_params = [{"TYPE_CLE", Type_cle}, 
                        {"VALEUR_CLE", Ticket_rechg}, 
                        {"MSISDN", svc_util_of:int_to_nat(Msisdn)}],
    Optional_params = [],
    case sachem:consult_recharge_ticket(Session, 
                                        Mandatory_params, Optional_params) of
        {ok, {_, Resp_params}} -> 
            {ok, {Session, Resp_params}};
        {nok, Reason} ->
            slog:event(warning, ?MODULE, consult_recharge_ticket,
                       {Reason, 
                        input_parameters, Mandatory_params, Optional_params}),
            {nok, Reason}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type recharge_ticket(session(), string()) ->
%%                         {ok|nok, list()} 
%%%% REC_TCK => recharge_ticket() <= D6
%%%% Demande de rechargement par CaG
%%%% recharge_ticket(Session, numero_de_rechargement_du_ticket)
recharge_ticket(Session, NUM_CR) ->   
    recharge_ticket(Session, NUM_CR, 0).

%% +type recharge_ticket(session(), string(), integer()) ->
%%                         {ok|nok, list()} 
%%%% recharge_ticket(Session, numero_de_rechargement_du_ticket, choix_du_client)
recharge_ticket(#session{}=Session, NUM_CR, TRC_NUM) 
  when list(TRC_NUM) ->
    recharge_ticket(#session{}=Session, NUM_CR, list_to_integer(TRC_NUM));
recharge_ticket(#session{}=Session, NUM_CR, TRC_NUM) ->   
    CANAL_NUM = pbutil:get_env(pfront_orangef,d6_canal_num),
    {Session1,DOS_NUMID} = get_dos_numid(Session),
    Mandatory_params = [{"DOS_NUMID", integer_to_list(DOS_NUMID)}, 
                        {"NUM_CR", NUM_CR}, 
                        {"TRC_NUM", integer_to_list(TRC_NUM)}, 
                        {"CANAL_NUM", integer_to_list(CANAL_NUM)}],
    Optional_params = [],

    %% send a consult_account request to get the original account credit
    {Session3,Solde_orig} = 
        case consult_account(Session1) of
            {ok, {Session2, Resp_params_for_solde}} ->
                {Session2,get_solde_cpte(Resp_params_for_solde, ?C_PRINC)};
            Error ->
                slog:event(failure, ?MODULE, consult_account_for_solde_set_to_0, Error),
                {Session1,0}
        end,

    %% send the required recharge_ticket request
    case sachem:recharge_ticket(Session3, 
                                Mandatory_params, Optional_params) of
        {ok, {Session4, Resp_params_REC_TCK}} -> 
            
            %% send an additional consult_account to get missing
            %% account values in REC_TCK
            case update_sachem_user_state(Session4) of
                {ok, State_CSL_DOSCP} ->                  

                    %% Construct Accounts from output of CSL_DOSCP + REC_TCK
                    Comptes_REC_TCK = get_accounts_from_resp(Resp_params_REC_TCK),        
                    State_updated = update_recharged_accounts(Comptes_REC_TCK, 
                                                              State_CSL_DOSCP),                 

                    %% get recharge value as the difference between old
                    %% Credit (from CSL_DOSCP) and the new one (from REC_TCK)
                    Solde_new = get_solde_cpte(Resp_params_REC_TCK, ?C_PRINC),
                    Recharge_value = abs(Solde_new - Solde_orig),
                    Recharge = #recharge{montant=currency:sum(euro,
                                                      Recharge_value/1000)},
                    State_2 = State_updated#sdp_user_state{tmp_recharge=Recharge},
                    Session_updated = svc_util_of:update_user_state(Session4, 
                                                            State_2),      

                    %% Store TTK_NUM in Session
                    TTK_NUM = proplists:get_value("TTK_NUM", Resp_params_REC_TCK),
                    Session_2 = variable:update_value(Session_updated,
                                                      {"recharge","TTK_NUM"},
                                                      TTK_NUM),  
       
                    {ok, {Session_2, Resp_params_REC_TCK}};
                {nok, Reason_CSL_DOSCP} -> 
                    slog:event(failure, ?MODULE, consult_account,
                               {Reason_CSL_DOSCP, 
                                input_parameters, Mandatory_params, Optional_params}),
                    {nok, Reason_CSL_DOSCP}
            end;
        {nok, Reason_REC_TCK} -> 
            slog:event(service_ko, ?MODULE, recharge_ticket,
                       {Reason_REC_TCK, 
                        input_parameters, Mandatory_params, Optional_params}),
            {nok, Reason_REC_TCK}
    end.

%% +type get_solde_cpte(proplist(), atom()) ->
%%                    integer()
%%%% get the CPP_SOLDE from the response of
%%%% req consult_account or recharge_ticket
get_solde_cpte(Resp_params, TCP_NUM) ->
    Tcp_num_list = integer_to_list(TCP_NUM),
    case get_account_from_resp(Resp_params, TCP_NUM) of
        undefined ->
            slog:event(warning, ?MODULE, account_undef_solde_set_to_0,
                       {Resp_params, TCP_NUM}),
            0;
        Compte when list(Compte) ->
            case length(Compte) of
                %% resp of consult_account
                13 ->
                    [Tcp_num_list, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE|_] = Compte, 
                    list_to_integer(CPP_SOLDE);
                %% resp of recharge_ticket
                6 ->
                    [Tcp_num_list, CPP_DATE_LV, CPP_SOLDE|_] = Compte, 
                    list_to_integer(CPP_SOLDE);
                Else ->
                    slog:event(failure, ?MODULE, solde_not_found_set_to_0, 
                               {compte, TCP_NUM, 
                                resp_params, Resp_params, Else}),
                    0
            end
    end.

%% +type update_recharged_accounts(list(), state()) ->
%%                         State 
%%%% update accounts in State with REC_TCK result values
%%%% for fields BON_CPT and BON_MONTANT only
%%%% (the ones not in CSL_DOSCP)
update_recharged_accounts([], State) ->
    State;
update_recharged_accounts([[TCP_NUM, CPP_DATE_LV, CPP_SOLDE, UNT_NUM,
                            BON_PCT, BON_MONTANT]|Tail], 
                          State) ->
    %% Get compte info from State
    Subscr = list_to_atom(svc_util_of:declinaison(State)),
    Compte_name = svc_compte:search_cpte(list_to_integer(TCP_NUM), Subscr),
    Compte_init = svc_compte:get_cpte_from_list(State,Compte_name),

    %% Updated Compte with BON_CPT and BON_MONTANT
    Compte_updated = Compte_init#compte{
                       pct=format_to_int(BON_PCT),
                       mnt_bonus=svc_compte:calcul_solde(
                                   format_to_int(BON_MONTANT),
                                   format_to_int(UNT_NUM))},
    State2=svc_compte:add_compte(format_to_int(TCP_NUM),Compte_updated,State),
    update_recharged_accounts(Tail, State2);
update_recharged_accounts(Comptes, State) ->
    slog:event(warning, ?MODULE, recharged_empty_compte, {Comptes, State}),
    State.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type change_user_account(session(), string()) ->
%%                         {ok|nok, list()} 
%%%% MOD_CP => change_user_account() <= G2 (Sachem X25)
%%%% Modification d'un compte dans un dossier
%%%% Current Service use this function only to modify the PTF_NUM
change_user_account(#session{}=Session, #compte{}=Compte) ->
    State=svc_util_of:get_user_state(Session),
    {Session1,DOS_NUMID}   = get_dos_numid(Session),      
    Mandatory_params = [{"DOS_NUMID",  format_to_list(DOS_NUMID)}, 
                        {"TCP_NUM",    format_to_list(Compte#compte.tcp_num)}], 
    Optional_params = update_optional_values(State, Compte),
    case sachem:change_user_account(Session1,
                                    Mandatory_params, Optional_params) of
        {ok, {Session2, Resp_params}} -> 
            {ok, {Session2, Resp_params}};
        {nok, Reason} -> 
            slog:event(warning, ?MODULE, change_user_account,
                       {Reason, 
                        input_parameters, Mandatory_params, Optional_params}),          
            {nok, Reason}
    end.


%%%% Set the optional parameters for MOD_CP
update_optional_values(State, Compte) ->
    Pct_montant = 
        case Compte#compte.pct of
            Undefined when 
            Undefined==undefined;
            Undefined=="-" -> "-1";
            Cout -> 
                case catch round(currency:round_value(Cout)*1000) of
                    Integer when integer(Integer) -> 
                        Integer;
                    _ -> round(Cout*1000)
                end
        end,
    Default_values = ["0",
                      "-1",
                      "",
                      "0",
                      "0",
                      "0",
                      "-1"
                     ],
    Compte_values = [Compte#compte.etat,
                     Compte#compte.dlv,
                     Compte#compte.cpt_dest,
                     Compte#compte.rnv,
                     Compte#compte.ptf_num,
                     Compte#compte.ctrl_sec,
                     Pct_montant],
    Choose_value = fun(Compte_value, Default_value) ->
                           format_to_default(Compte_value, Default_value)
                   end,
    [ECP_NUM, Cpp_date_lv, CPP_DESTINATION, RNV_NUM, PTF_NUM, CTRL_ESC, 
     PCT_MONTANT] = pbutil:lmap2(Choose_value, Compte_values, Default_values),
    CPP_DATE_LV = force_to_default(Cpp_date_lv, "-1", ["0"]),
    [
     {"ECP_NUM",     ECP_NUM},
     {"CPP_DATE_LV", CPP_DATE_LV},
     {"CPP_DESTINATION", CPP_DESTINATION},
     {"RNV_NUM",     RNV_NUM},
     {"PTF_NUM",     PTF_NUM},
     {"CTRL_ESC",    CTRL_ESC},
     {"PCT_MONTANT", PCT_MONTANT}
    ].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type update_account_options(session(), string()) ->
%%                         list()|ko
%%%% MAJ_OP   => update_account_options()                      
%%%% New version of OPT_CPT2 (Sachem X25)
update_account_options(#session{}=Session, #opt_cpt_request{}=Opt_cpt)->
    {Session1,DOS_NUMID}=get_dos_numid(Session),
    Mandatory_params =
        [{"ACTION",    Opt_cpt#opt_cpt_request.type_action},
         {"DOS_NUMID", format_to_list(DOS_NUMID)},
         {"TOP_NUM",   format_to_list(Opt_cpt#opt_cpt_request.top_num)},
          %% According to Diana, should be set to "0", to be updated in svc_options
         {"OPT_DATE_DEB_VALID", "0"}, 
         {"TRN_NUM",   format_to_list(Opt_cpt#opt_cpt_request.rnv_num)}
        ],
    Pct_montant = format_to_default(Opt_cpt#opt_cpt_request.cout,"-1"),
    Optional_params =          
        [{"TOP_DUREE", format_to_list(Opt_cpt#opt_cpt_request.duree)},
         {"PCT_MONTANT",Pct_montant},
         {"OPT_INFO1", format_to_list(Opt_cpt#opt_cpt_request.info1)},
         {"OPT_INFO2", format_to_list(Opt_cpt#opt_cpt_request.info2)},
         {"PTF_NUM",   format_to_list(Opt_cpt#opt_cpt_request.ptf_num)},
         {"TCP_NUM",   format_to_list(Opt_cpt#opt_cpt_request.tcp_num)},
         {"TYPE_TRT",  format_to_list(Opt_cpt#opt_cpt_request.type_trt)},
         {"MNT_INITIAL",format_to_list(Opt_cpt#opt_cpt_request.mnt_initial)},
         {"MSISDN1",   format_to_list(Opt_cpt#opt_cpt_request.msisdn1)},
         {"MSISDN2",   format_to_list(Opt_cpt#opt_cpt_request.msisdn2)},
         {"MSISDN3",   format_to_list(Opt_cpt#opt_cpt_request.msisdn3)},
         {"MSISDN4",   format_to_list(Opt_cpt#opt_cpt_request.msisdn4)},
         {"MSISDN5",   format_to_list(Opt_cpt#opt_cpt_request.msisdn5)},
         {"MSISDN6",   format_to_list(Opt_cpt#opt_cpt_request.msisdn6)},
         {"MSISDN7",   format_to_list(Opt_cpt#opt_cpt_request.msisdn7)},
         {"MSISDN8",   format_to_list(Opt_cpt#opt_cpt_request.msisdn8)},
         {"MSISDN9",   format_to_list(Opt_cpt#opt_cpt_request.msisdn9)},
         {"MSISDN10",  format_to_list(Opt_cpt#opt_cpt_request.msisdn10)}],
    case sachem:update_account_options(Session1,
                                       Mandatory_params, 
                                       Optional_params) of
        {ok, {Session2, Resp_params}} -> 
            {ok, {Session2, Resp_params}};
        {nok, Reason} ->            
            slog:event(trace, ?MODULE, update_account_options,
                       {Reason, 
                        input_parameters, Mandatory_params, Optional_params}),
            {nok, Reason};
        Error ->
            slog:event(failure, ?MODULE, update_account_options,
                       {Error, 
                        input_parameters, Mandatory_params, Optional_params}),
            {nok, unknown_error}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type handle_options(session(), list(opt_cpt_request())) ->
%%                         {ok|ko, list()}
%%%% MAJ_NOPT   => handle_options()                      
%%%% New version of NOPT_CPT (Sachem X25)
handle_options(Session, #opt_cpt_request{}=Opt_cpt) ->
    handle_options(Session, [Opt_cpt]);
handle_options(#session{prof=Profile}=Session, List_Opt_cpt) 
  when list(List_Opt_cpt) ->
    Filled_Opt_cpt = filled_opt_cpt(List_Opt_cpt),
    case Filled_Opt_cpt of
        [Opt_cpt|_] when record(Opt_cpt,opt_cpt_request) ->
            Msisdn = Profile#profile.msisdn, 
            Action = Opt_cpt#opt_cpt_request.type_action,
            List_comptes = create_list_compte(Filled_Opt_cpt),
            Mandatory_params =
                [{"MSISDN",    svc_util_of:int_to_nat(Msisdn)}, 
                 {"TYPE_ACTION",    Action},
                 {"NB_OP",     integer_to_list(length(Filled_Opt_cpt))}]
                ++ List_comptes,
            Optional_params = [],
            case sachem:handle_options(Session, 
                                       Mandatory_params, Optional_params) of
                {ok, {Session_resp, Resp_params}} -> 
                    {ok, {Session_resp, Resp_params}};
                {nok, Reason}  ->            
                    slog:event(trace, ?MODULE, handle_options,
                               {Reason, 
                                input_parameters, Mandatory_params, Optional_params}),
                    {nok, Reason};
                Error ->
                    slog:event(failure, ?MODULE, handle_options,
                               {Error, 
                                input_parameters, Mandatory_params, Optional_params}),
                    {nok, unknown_error}
            end;
        _ ->
            slog:event(internal, ?MODULE, unexpected_Opt_cpt_input,
                       List_Opt_cpt),
            {nok, unexpected_Opt_cpt_input}    
    end.

filled_opt_cpt(List_Opt_cpt) ->
    List_reversed_Opt_cpt = case lists:reverse(List_Opt_cpt) of
                                [[]|Filled_list] -> Filled_list;
                                Filled_list -> Filled_list
                            end,
    lists:reverse(List_reversed_Opt_cpt).
                 
create_list_compte(List_comptes) ->
    create_list_compte(List_comptes, []).

create_list_compte([], Out_comptes) ->
    Out_comptes;
create_list_compte([Compte|Comptes], Out_comptes) ->
    Pct_montant = format_to_default(Compte#opt_cpt_request.cout, "-1"),
    Out_format = [{"TOP_NUM",     format_to_list(Compte#opt_cpt_request.top_num)},
                  {"DATE_DEB",    format_to_list(Compte#opt_cpt_request.date_deb)},
                  {"HEURE_DEB",   format_to_list(Compte#opt_cpt_request.heure_deb)},
                  {"DATE_FIN",    format_to_list(Compte#opt_cpt_request.date_fin)},
                  {"HEURE_FIN",   format_to_list(Compte#opt_cpt_request.heure_fin)},
                  {"PCT_MONTANT", Pct_montant}],
    create_list_compte(Comptes, Out_format ++ Out_comptes).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type transfer_credit(session(), string()) ->
%%                         list()|ko
%%%% TRA_CREDIT   => transfert_credit()                      
%%%% transfert de credit
%%%% New version of NTRD (Sachem X25)
transfer_credit(#session{}=Session, Msisdn_receiver, Transfer_type)->
    {Session1,DOS_NUMID}=get_dos_numid(Session),
    Mandatory_params =
        [{"DOS_NUMID",           integer_to_list(DOS_NUMID)},
         {"TRA_MSISDN_RECEVEUR", svc_util_of:int_to_nat(Msisdn_receiver)},
         {"TRA_TRC_NUM",         Transfer_type}],
    Optional_params = [],
    case sachem:transfert_credit(Session1,
                                 Mandatory_params, Optional_params) of
        {ok, {Session2, Resp_params}} -> 
            CPP_SOLDE = proplists:get_value("CPP_SOLDE", Resp_params),
            TCP_NUM = proplists:get_value("TCP_NUM", Resp_params),
            State = svc_util_of:get_user_state(Session2),
            Compte = svc_compte:cpte(State,cpte_princ),
            New_Compte = Compte#compte{cpp_solde = 
                                       svc_compte:calcul_solde(
                                         format_to_int(CPP_SOLDE),?EURO)},
            New_State=svc_compte:add_compte(TCP_NUM,New_Compte,State),
            Session_new = svc_util_of:update_user_state(Session2, New_State),
            {ok, {Session_new, Resp_params}};
        {nok, Reason} -> 
            slog:event(trace, ?MODULE, transfer_credit, 
                       {Reason,
                        input_parameters, Mandatory_params, Optional_params}),
            {nok, Reason}
    end.   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type consult_param_table(session(), string()) ->
%%                         list()|ko
%%%% CSL_PARAM_GEN   => consult_param_table()                      
%%%% consultation des tables de parametres
%%%% New version of  (Sachem X25)
%%%% OBSOLETE
consult_param_table(#session{}=Session, Msisdn_receiver, Transfer_type)->
    {Session1,DOS_NUMID}=get_dos_numid(Session),
    Mandatory_params =
        [{"DOS_NUMID",           DOS_NUMID},
         {"TRA_MSISDN_RECEVEUR", svc_util_of:int_to_nat(Msisdn_receiver)},
         {"TRA_TRC_NUM",         Transfer_type}],
    Optional_params = [],
    case sachem:change_user_account(Session1,
                                    Mandatory_params, Optional_params) of
        {ok, {Session2, Resp_params}} -> 
            {ok, {Session2, Resp_params}};
        {nok, Reason} -> 
            slog:event(warning, ?MODULE, consult_param_table, 
                       {Reason, 
                        input_parameters, Mandatory_params, Optional_params}),
            {nok, Reason}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type format_to_int(list()) -> undefined | integer()
%%%% Converts from integer to list
%%%% Should be adapted according to default values
format_to_int("") ->
    undefined;
format_to_int(undefined) ->
    undefined;
format_to_int(List) when list(List) ->
    case catch list_to_integer(List) of
        Int when integer(Int) ->
            Int;
        _ -> 
            case list_to_atom(List) of
                Atom when atom(Atom) ->
                    Atom;
                _ ->
                    slog:event(internal, ?MODULE, format_to_int, List),
                    undefined
            end
    end.

%% +type format_to_list(integer()) -> string()
%%%% Converts to list for xmlgeneric
format_to_list(Integer) when integer(Integer) ->
    integer_to_list(Integer);
format_to_list(List) when list(List) ->
    List;
format_to_list(Else) ->
    slog:event(warning, ?MODULE, element_forced_to_empty, Else),
    "".

%% +type format_to_default(Input_value, string()) -> string()
%%%% Set default value if undefined
format_to_default(Input_value, Default_value) ->
    case Input_value of
        Undefined when 
        Undefined==undefined;
        Undefined=="";
        Undefined=="-" ->
            Default_value;
        _ -> format_to_list(Input_value)
    end.

%% +type force_to_default(Input_value, string(), list()) -> string()
%%%% Forces default value if Input_value belongs to Forbidden values
force_to_default(Input_value, _, []) ->
    Input_value;
force_to_default(Input_value, Default_value, Forbidden_values) ->
    case lists:member(Input_value, Forbidden_values) of
        true  -> Default_value;
        false -> Input_value
    end.
            

