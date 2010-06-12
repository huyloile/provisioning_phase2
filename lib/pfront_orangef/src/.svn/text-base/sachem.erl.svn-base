
-module(sachem).
-export([consult_account/3, recharge_ticket/3, consult_recharge_ticket/3, 
    consult_account_options/3, update_account_options/3, handle_options/3,
    transfert_credit/3, consult_params_table/3, change_user_account/3]).

-export([check_mparamlist/3, input_all_params_in_session/3,
        get_repeated_section/4, decode_one_repeated_section/2]).

-export([slog_info/3]).

-include("../../xmerl/include/xmerl.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../oma/include/slog.hrl").

-define(DEFAULT_OPT_LIST_CSL_DOSCP, [{"DOS_ACTIV","0"}]).
-define(DEFAULT_OPT_LIST_CSL_OP, [{"PCT_MONTANT","0"}, {"UNT_NUM", "0"}]).
-define(DEFAULT_OPT_LIST_MAJ_OP, 
        [{"TOP_DUREE","0"}, {"PCT_MONTANT", "-1"}, {"OPT_INFO1", ""}, 
         {"OPT_INFO2",""}, {"PTF_NUM", "0"}, {"TCP_NUM", "-1"}, {"TYPE_TRT", "0"}, 
         {"MNT_INITIAL", "-1"}, {"MSISDN1", ""}, {"MSISDN2", ""},
         {"MSISDN3", ""}, {"MSISDN4", ""}, {"MSISDN5", ""}, {"MSISDN6", ""}, 
         {"MSISDN7", ""}, {"MSISDN8", ""}, {"MSISDN9", ""}, {"MSISDN10", ""}]).
-define(DEFAULT_OPT_LIST_MOD_CP,
        [{"ECP_NUM","0"},{"CPP_DATE_LV","0"},{"CPP_DESTINATION","0"},{"RNV_NUM","0"},
         {"PTF_NUM",""},{"CTRL_ESC",""},{"PCT_MONTANT",""}]).

%% type definition list for each request
-define(TYPE_LIST_CSL_DOSCP,
    [{"CLE",in_list,["0","1","2","3","4"]},{"IDENTIFIANT",string,15}]).
-define(TYPE_LIST_REC_TCK,
    [{"DOS_NUMID",int},{"NUM_CR",string,14},{"TRC_NUM",int},{"CANAL_NUM",int}]).
-define(TYPE_LIST_CSL_OP,
    [{"DOS_NUMID", int}]).
-define(TYPE_LIST_MAJ_OP,
    [{"ACTION",in_list,["A", "S","M"]},{"DOS_NUMID",int},
     {"TOP_NUM",int},{"OPT_DATE_DEB_VALID",int},{"TRN_NUM",int}]).
-define(TYPE_LIST_MAJ_NOPT,
    [{"MSISDN",int,10},
     {"TYPE_ACTION",in_list,["A","S","M"]},{"NB_OP",int},{"TOP_NUM",int},
     {"DATE_DEB",string},{"HEURE_DEB",string},{"DATE_FIN",string},{"HEURE_FIN",string},
     {"PCT_MONTANT",int}]).
-define(TYPE_LIST_TRA_CREDIT,
    [{"DOS_NUMID",int},{"TRA_MSISDN_RECEVEUR",string,12},{"TRA_TRC_NUM",int}]).
-define(TYPE_LIST_MOD_CP,
    [{"DOS_NUMID",int},{"TCP_NUM",int}]).
-define(TYPE_LIST_CSL_PARAM_GEN, [{"PARAMETRE",string,20}]).
-define(TYPE_LIST_CSL_TCK,
    [{"TYPE_CLE",in_list,["1","2"]},
    {"VALEUR_CLE",string,14},{"MSISDN",string}]).

%% repeated response parameter key list
-define(RepeatKeyList_CSL_DOSCP, ["TCP_NUM", "ECP_NUM", "UNT_NUM", "PTF_NUM",
        "CPP_SOLDE", "CPP_DATE_LV", "CPP_DATE_CREA", "CPP_DATE_MODIF",
        "CPP_DESTINATION", "CPP_CUMUL_CREDIT", "RNV_NUM", "TYPE_DLV", "OPT_TCP"]).
-define(RepeatKeyList_REC_TCK,["TCP_NUM","CPP_DATE_LV","CPP_SOLDE","UNT_NUM","BON_PCT","BON_MONTANT"]).
-define(RepeatKeyList_CSL_OP_1,["TOP_NUM","OPT_DATE_SOUSCRIPTION","OPT_DATE_DEB_VALID","OPT_DATE_FIN_VALID",
    "OPT_INFO1","OPT_INFO2","TCP_NUM","PTF_NUM","RNV_NUM","CPP_CUMUL_CREDIT"]).
-define(RepeatKeyList_CSL_OP_2,["MSISDN_MEMBRE","OPL_RANG","MSISDN_TOP_NUM","MSISDN_TCP_NUM",
    "MSISDN_PTF_NUM","MSISDN_RNV_NUM"]).
-define(RepeatKeyList_CSL_OP_3,["TOP_NUM","CPT_CUMUL","UNT_NUM","DATE_RAZ"]).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for CSL_DOSCP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consult_account(Session, MParamList, OptParaList) ->
    ReplacedOptList = update_opt_list(OptParaList, ?DEFAULT_OPT_LIST_CSL_DOSCP),
    case length(MParamList) of
        2 ->
            case catch check_mparamlist(MParamList, ?TYPE_LIST_CSL_DOSCP, "csl_doscp") of
                ok -> 
                    send_request(Session, MParamList++ReplacedOptList,
                        "csl_doscp", "callCsl_doscp");
                {nok, R} ->
                    slog:event(trace, ?MODULE, error_reason,R), 
                    {nok, R};
                Error ->
                    slog:event(trace, ?MODULE, error_sachem,Error),
                    {nok, Error}
            end;
        _ -> {nok, "CSL_DOSCP parameters number wrong, it should be 2"}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for REC_TCK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recharge_ticket(Session, MParamList, OptParaList) ->
    case length(MParamList) of
       4 -> 
            case catch check_mparamlist(MParamList, ?TYPE_LIST_REC_TCK, "rec_tck") of
                ok -> 
		    send_request(Session, MParamList++OptParaList,"rec_tck", "callRec_tck");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "REC_TCK parameters number wrong, it should be 4"}
    end. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for CSL_OP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consult_account_options(Session, MParamList, OptParaList) ->
    ReplacedOptList = update_opt_list(OptParaList, ?DEFAULT_OPT_LIST_CSL_OP),
    case length(MParamList) of
        1 ->
            case catch check_mparamlist(MParamList, ?TYPE_LIST_CSL_OP, "csl_op") of
                ok -> 
		    send_request(Session, MParamList++ReplacedOptList,"csl_op",
                        "callCsl_op");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "CSL_OP parameters number wrong, it should be 1"}
    end. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for MAJ_OP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_account_options(Session, MParamList, OptParaList) ->
    ReplacedOptList = update_opt_list(OptParaList, ?DEFAULT_OPT_LIST_MAJ_OP),
    case length(MParamList) of
        5 -> 
            case catch check_mparamlist(MParamList,?TYPE_LIST_MAJ_OP,"maj_op") of
                ok -> 
		    send_request(Session, MParamList++ReplacedOptList,
                        "maj_op", "callMaj_op");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "MAJ_OP parameters number wrong, it should be 5"}
    end. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for MAJ_NOPT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_options(Session, MParamList, OptParaList) ->
    case find_value_by_name("NB_OP", MParamList) of
        {not_found, _} -> {nok, "maj_nopt.NB_OP not_found"};
        Val ->
            case catch list_to_integer(Val) of
                {'EXIT', _} -> {nok, "maj_nopt.NB_OP is not an integer"};
                Num -> handle_options(Session, MParamList, OptParaList, Num)
            end
    end.
handle_options(Session, MParamList, OptParaList, Num) ->
    ParamNum = 3+6*Num,
    case length(MParamList) of
        ParamNum ->
            case catch check_mparamlist(MParamList, ?TYPE_LIST_MAJ_NOPT,
                    "maj_nopt") of
                ok -> 
		    send_request(Session, MParamList++OptParaList,
                        "maj_nopt", "callMaj_nopt");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "MAJ_NOPT parameters number wrong, it should be"
                ++integer_to_list(ParamNum)}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for MOD_CP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_user_account(Session, MParamList, OptParaList) ->
    ReplacedOptList = update_opt_list(OptParaList, ?DEFAULT_OPT_LIST_MOD_CP),
    case length(MParamList) of
        2 -> 
            case catch check_mparamlist(MParamList, ?TYPE_LIST_MOD_CP,
                    "mod_cp") of
                ok -> 
		    send_request(Session, MParamList++ReplacedOptList,
                        "mod_cp", "callMod_cp");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "MOD_CP parameters number wrong, it should be 2"}
    end.

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for TRA_CREDIT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
transfert_credit(Session, MParamList, OptParaList) ->
    case length(MParamList) of
        3 -> 
            case catch check_mparamlist(MParamList, ?TYPE_LIST_TRA_CREDIT,
                    "tra_credit") of
                ok -> 
		    send_request(Session, MParamList++OptParaList,
                        "tra_credit", "callTra_credit");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "TRA_CREDIT parameters number wrong, it should be 3"}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for CSL_PARAM_GEN 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consult_params_table(Session, MParamList, OptParaList) ->
    case length(MParamList) of
        1 -> 
            case catch check_mparamlist(MParamList, ?TYPE_LIST_CSL_PARAM_GEN,
                    "csl_param_gen") of
                ok -> 
		    send_request(Session, MParamList++OptParaList,
                        "csl_param_gen", "callCsl_param_gen");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "CSL_PARAM_GEN parameters number wrong, it should be 1"}
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API for CSL_TCK 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consult_recharge_ticket(Session, MParamList, OptParaList) ->
    case length(MParamList) of
        3 -> 
            case catch check_mparamlist(MParamList, ?TYPE_LIST_CSL_TCK,
                    "csl_tck") of
                ok -> 
		    send_request(Session, MParamList++OptParaList,
                        "csl_tck", "callCsl_tck");
                {nok, R} -> {nok, R};
                Error -> {nok, Error}
            end;
        _ -> {nok, "CSL_TCK parameters number wrong, it should be 3"}
    end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% the common methods 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input parameters list, if correct return ok, if not throw an exception
%% +type check_mparamlist(MParamList::list(), TypeList::list(), 
%%       SvcName::string()) ->
%% Result::atom()|exception() ok | exception
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_mparamlist([], _, _) ->
    ok;
check_mparamlist([{Key,Value}|Rest], TypeList, SvcName) ->
    case lists:keysearch(Key, 1, TypeList) of
        {value, Type} ->
            case check_parameter(Type, Value, SvcName) of
                ok -> check_mparamlist(Rest, TypeList, SvcName);
                {nok, Error} -> throw({nok, Error})
            end;
        _ -> throw({nok, SvcName++"."++Key++" doesn't exist"})
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check one parameter following the type defination
%% +type check_parameter(TypeDefine::tuple(), Value::String(), 
%%       SvcName::string()) ->
%% Result::atom()|tuple() ok | {nok, ErrorMessage}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_parameter({Key, fixed, FixVal}, Value, SvcName) ->
    case FixVal == Value of
        true -> ok;
        _ -> {nok, SvcName++"."++Key++" should be "++FixVal}
    end;
check_parameter({Key,in_list,Range}, Value, SvcName) ->
    case lists:member(Value, Range) of
        true -> ok;
        _ -> {nok, SvcName++"."++Key++" out of range " ++
                lists:flatten(io_lib:fwrite("~p", [Range]))}
    end;
check_parameter({Key,string,Len}, Value, SvcName) ->
    case check_length(Value, Len) of
        true -> ok;
        false -> {nok, SvcName++"."++Key++" max length should be " ++
            integer_to_list(Len)};
        _ -> {nok, SvcName++"."++Key++" input wrong"}
    end;
check_parameter({Key,int}, Value, SvcName) ->
    case check_number(Value) of
        true -> ok;
        _ -> {nok, SvcName++"."++Key++" is not an integer"}
    end;
check_parameter({Key,int,Len}, Value, SvcName) ->
    case check_number(Value) of
        true ->
            case length(Value) of
                Len -> ok;
                _ -> {nok, SvcName++"."++Key++" length should be "
                        ++integer_to_list(Len)}
            end;
        _ -> {nok, SvcName++"."++Key++" is not an integer"}
    end;
check_parameter({_, string}, _, _) ->
    ok;
check_parameter({Key,_}, _, SvcName) ->
    {nok, SvcName++"."++Key++" unknown definition"}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% send a request with xml_generic and return the decoded result
%% +type send_request(Session::recode(), ParamList::list(), 
%%                SvcName::string(), RequestName::string()) ->
%% Result::tuple() {ok, {ResultSession::recode(), ResultList::list()}} |
%%                 {nok, Reason::term()}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_request(Session, ParamList, SvcName, RequestName) ->
    case svc_util_of:get_available_sachem_data(Session,SvcName) of
        undefined->
            slog:event(count,?MODULE,list_to_atom(SvcName++"_request")),
            slog:event(count, ?MODULE, request, {SvcName, ParamList}),
            case pbutil:get_env(pfront_orangef, sachem_version) of
                offline ->
                    sachem_offline:send_request(Session, SvcName, ParamList);
                online ->
                    sachem_online:send_request(Session, SvcName, ParamList);
                sachem_G3R2->
                    send_request_sachem_G3R2(
                        Session, ParamList, SvcName, RequestName)
            end;
        Available_data ->
            slog:event(trace,?MODULE,
                list_to_atom(SvcName++"_available_data"),
                Available_data),
            {ok,{Session,Available_data}}
    end.
send_request_sachem_G3R2(Session, ParamList, SvcName, RequestName) ->
    Profile = Session#session.prof,
    MSISDN = Profile#profile.msisdn,
    Session_new = input_all_params_in_session(Session, ParamList, SvcName),
    {Path, Route, URL, Timeout} = get_env_params(),
    Current_time = oma:unixmtime(),
    Xml_Response = (catch xml_generic:send_request(RequestName, Session_new,
            Path, Route, URL, Timeout)),
    slog:delay(perf, ?MODULE, response_time, Current_time),
    case Xml_Response of
        {ok, Label_values} ->
            Mediated_label_values= xml_generic:mediate(Label_values),
            Session2 = save_values(Session_new,SvcName, Mediated_label_values),
            {value, {_, XmlNode}} = lists:keysearch("returnItems",1,
                Mediated_label_values),  
            ResultList = xmerl:export(XmlNode,
                get_list_from_soap_response_xmerl),
            Result = decode_result_list(SvcName, ResultList),
            case Result of
                {nok, Error} ->
                    slog:event(failure,?MODULE,
                        {list_to_atom(RequestName++"_response_ko"),Error}),
                    {nok, Error};
                Val ->
                    slog:event(trace, ?MODULE, decode_result_list,
                        {SvcName, input, ParamList, output, Val}),
                    slog:event(count,?MODULE,
                        list_to_atom(RequestName++"_response_ok")),
                    Session3=svc_util_of:change_sachem_availability(
                        Session2,SvcName,Val),
                    {ok, {Session3, Val}}
            end;
        {error, timeout} ->
            slog:event(failure, ?MODULE, 
                list_to_atom(RequestName++"_response_ko"),timeout),
            {nok, timeout};
        {error, Error} ->
            slog:event(count,?MODULE,
                {list_to_atom(RequestName++"_response_with_error_code"),Error},MSISDN),
            {nok, {error, Error}};
        {'EXIT', Error} ->
            slog:event(failure, ?MODULE, 
                {list_to_atom(RequestName++"_response_ko"),exit} , Error),
            {nok, exit};
        Error ->
            slog:event(failure, ?MODULE, xml_generic_failure, 
                {Error, SvcName, 
                    {input, ParamList}, 
                    Path,Route, URL, Timeout}),
            slog:event(failure, ?MODULE, 
                list_to_atom(RequestName++"_response_ko"),Error),
            {nok, Error}
    end.
save_values(Session,_,[])->
    Session;
save_values(Session,Svc_Name,[{Label,Value}|T])->
    Session2 = variable:update_value(Session, {Svc_Name,Label}, Value),
    save_values(Session2,Svc_Name,T).

decode_result_list("csl_doscp", List) ->
    Result = get_repeated_section(List, ?RepeatKeyList_CSL_DOSCP,"NB_CPT[0]",
        "CPT_PARAMS"),
    case Result of 
        {nok, Error} -> {nok, "csl_doscp " ++ Error};
        {RepeatParams, Others} ->
            lists:append(clear_suffix(Others),RepeatParams)
    end;
decode_result_list("rec_tck", List) ->
    Result = get_repeated_section(List, ?RepeatKeyList_REC_TCK,"NB_CPT[0]",
        "CPT_PARAMS"),
    case Result of 
        {nok, Error} -> {nok, Error};
        {RepeatParams, Others} ->
            lists:append(clear_suffix(Others),RepeatParams)
    end;
decode_result_list("csl_op", List) ->
    case get_repeated_section(List, ?RepeatKeyList_CSL_OP_1,
            "NB_OP[0]","OP_PARAMS") of
        {nok, Error1} -> {nok, Error1};
        {RepeatParams1, Others1} ->
            case get_repeated_section(Others1, ?RepeatKeyList_CSL_OP_2,
                    "NB_OCC[0]","NB_OCC_PARAMS") of
                {nok, Error2} -> {nok, Error2};
                {RepeatParams2, Others2} ->
                    case get_repeated_section(Others2, ?RepeatKeyList_CSL_OP_3,
                            "NB_OP_TG[0]","OP_TG_PARAMS") of
                        {nok, Error3} -> {nok, Error3};
                        {RepeatParams3, Others3} ->
                            lists:append([clear_suffix(Others3),
                                    RepeatParams1,RepeatParams2,RepeatParams3])
                    end
            end
    end;
decode_result_list("csl_param_gen", List) ->
    Result = get_repeated_section(List, repeatListCslParamGen(),"NB_VAL_PARAM[0]",
        "VAL_PARAMS"),
    case Result of 
        {nok, Error} -> {nok, Error};
        {RepeatParams, Others} ->
            lists:append(clear_suffix(Others),RepeatParams)
    end;
decode_result_list(_, List) ->
    clear_suffix(List).

repeatListCslParamGen() ->
    lists:map(fun(A) -> "CHAMP"++integer_to_list(A) end,lists:seq(1,30)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type get_repeated_section(list(), list(), string(), string()) -> tuple
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_repeated_section(List, RepeatKeyList, CounterKey, RepeatSectionName) ->
    case find_value_by_name(CounterKey, List) of
        {not_found, _} ->  {[],List};
        "0" -> {[],List};
        Val ->
            Fun1 = fun({Key,_}) -> check_if_member(Key, RepeatKeyList) end,
            {Matched,NotMatched} = scan_list(List, Fun1),
            Fun2 = fun(X, Y) -> compare_element(X, Y, RepeatKeyList) end,
            OrderedList = qsort(Matched, Fun2),
            RepeatedParamList = decode_one_repeated_section(OrderedList, list_to_integer(Val)),
            case RepeatedParamList of
                {error, Error} -> {nok, Error};
                [] -> {[], NotMatched};
                VList ->
                    {[{RepeatSectionName, VList}], NotMatched}
            end
    end. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ([{"K1[0]",v01},{"K2[0]",v02},{"K1[1]",v11},{"K2[1]",v12}],2)
%%      -> [[v01,v02],[v11,v12]]
%% +type decode_one_repeated_section(list(), integer()) -> list()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
decode_one_repeated_section([], _) ->
    [];
decode_one_repeated_section(List, Int) ->
    decode_one_repeated_section(List, Int, []).

decode_one_repeated_section([], 0, ResultList) ->
    ResultList;
decode_one_repeated_section([], _, _) ->
    {error, "the response repeated counter not matched"};
decode_one_repeated_section(_, 0, _) ->
    {error, "the response repeated counter not matched"};
decode_one_repeated_section(List, Int, ResultList) ->
    Fun = fun({Key,_}) -> get_index(Key)==Int-1 end,
    {Repeat, Rest} = scan_list(List, Fun),
    ValList = lists:map(fun({_,Val}) -> Val end, Repeat),
    decode_one_repeated_section(Rest, Int-1, [ValList|ResultList]).


%% +type scan_list(list(), fun()) -> {Matched::list(), NotMatched::list()}
scan_list(List, Fun) ->
    scan_list(List, Fun, [], []).

scan_list([],_,Matched, NotMatched) ->
    {lists:reverse(Matched), lists:reverse(NotMatched)};
scan_list([H|T], Fun, Matched, NotMatched) ->
    case Fun(H) of
        true ->
            scan_list(T, Fun, [H | Matched], NotMatched);
        false ->
            scan_list(T, Fun, Matched, [H | NotMatched])
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% find a parameter value in the parameter list.
%% +type find_value_by_name(Name::string(), List::list()) ->
%% Result::string() | tuple()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
find_value_by_name(Name, List) ->
    case lists:keysearch(Name, 1, List) of
        {value, {_, Value}} -> Value;
        _ -> {not_found, Name}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type check_length(String::string(), Length::integer()) ->
%% Result::boolean()|list()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_length(String, Length) when is_list(String) ->
    length(String) =< Length;
check_length(_, _) ->
    "not list".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type check_number(String::string()) ->
%% Result:boolean()|list()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_number(String) when is_list(String) ->
    case catch list_to_integer(String) of
        {'EXIT', _} -> 
            %% Allow empty number
            case String of
                ""  -> true;
                " " -> true;
                _   -> false
            end;
        _ -> true
    end;
check_number(_) ->
    "not list".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% replace all the default values
%% +type update_opt_list(OptListInput::list(), DefaultOptList::list()) ->
%% ReplacedList::list()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_opt_list(OptListInput, DefaultOptList) ->
    lists:map(fun(Elem) -> replace_opt_value(Elem, OptListInput) end,
        DefaultOptList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% replace one default if it is set in the OptListInput
%% +type replace_opt_value(Elem::tuple()={Key::string(), Value::string()},
%% OptList::list()) ->
%% Result::tuple()={Key::string(), Value::string()}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
replace_opt_value({Key, Value}, OptListInput) ->
    case lists:keysearch(Key, 1, OptListInput) of
        {value, {Key, Value}} -> {Key,Value};
        {value, {Key, ValueInput}} -> {Key,ValueInput};
        _ -> {Key,Value}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% insert the request parameters into session
%% +type input_all_params_in_session(Session::record()=, ParamList::list(),
%% ServiceName::string()) ->
%% NewSession::record()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_all_params_in_session(Session, [], _) ->
    Session;
input_all_params_in_session(Session, [{"NB_OP", "0"}| Rest], "maj_nopt") ->
    NewSession = variable:update_value(Session, {"maj_nopt", "NB_OP"}, "0"),
    input_all_params_in_session(NewSession, Rest, "maj_nopt");
input_all_params_in_session(Session, [{"NB_OP", Num}| Rest], "maj_nopt") ->
    Session1 = variable:update_value(Session, {"maj_nopt", "NB_OP"}, Num),
    RepeatRequest = make_repeat_request(Rest, list_to_integer(Num)),
    NewSession = variable:update_value(Session1, {"maj_nopt", "REPEAT_PARA"},
        RepeatRequest),
    input_all_params_in_session(NewSession, Rest, "maj_nopt");
input_all_params_in_session(Session, [{Name, Value}|Rest], ServiceName) ->
    NewSession = variable:update_value(Session, {ServiceName, Name}, Value),
    input_all_params_in_session(NewSession, Rest, ServiceName).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% make a string of xml which contains all the repeated parameters
%% +type make_repeat_request(List::list(), Int::integer()) -> Result::string()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_repeat_request(List, Int) ->
    Fun = fun({A,B}) -> {A, get_type(A), B} end,
    ListWithType = lists:map(Fun, List),
    make_string_to_replace(ListWithType,6,Int).
%    make_string_to_replace(ListWithType,Int).


make_string_to_replace(List, Increase, Int) ->
    make_string_to_replace(List,Increase,Int,[]).

make_string_to_replace([],_,0,String) ->
    String;
make_string_to_replace([],_,_,String) ->
    String;
make_string_to_replace(_,_,0,String) ->
    String;
make_string_to_replace(List, Increase, Int, String) ->
    SubList = lists:sublist(List, length(List)-Increase+1, length(List)),
    Rest = lists:sublist(List, length(List)-Increase),
    make_string_to_replace(Rest, Increase,Int-1, 
        make_section_for_one_list(SubList,Int)++String).



%% +type make_string_to_replace(List::list(), Amount::integer()) -> Result::string()
%%make_string_to_replace(List, Amount) ->
%%    make_string_to_replace(List, Amount, Amount, []).
%%
%%make_string_to_replace(_, _, 0, Result) ->
%%    Result;
%%make_string_to_replace(List, Amount, Index, Result) ->
%%    make_string_to_replace(List, Amount, Index-1,
%%        make_section_for_one_list(List, Index)++Result).

%% +type get_type(Key:string()) -> Type::string().
get_type("TOP_NUM") -> "Short";
get_type("PCT_MONTANT") -> "Int";
get_type(_) -> "String". 

%% +type make_section_for_one_list(List::string(),Index::integer()) ->
%% Result::string()
make_section_for_one_list(List,Index) ->
    make_section_for_one_list(List,Index,[]).

make_section_for_one_list([],_,Result) ->
    Result;
make_section_for_one_list([{Name,Type,Value}|T],Index,Result) ->
    make_section_for_one_list(T,Index,Result++make_one_block(Name,Type,Value,Index)).

make_one_block(Name,Type,Value,Index) ->
    "<sac:params>"
    "<sac:name>"++Name++"@@"++integer_to_list(Index)++"</sac:name>"
    "<sac:type>"++Type++"</sac:type>"
    "<sac:value>"++Value++"</sac:value>"
    "</sac:params>".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get the parameters needed from environment parameters
%% +type get_env_params() ->
%% Result::tuple()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_env_params() ->
    %% parameters to be created in pfront_orangef
    Path = pbutil:get_env(pfront_orangef, sachem_xml_generic_path),
    Route = pbutil:get_env(pfront_orangef, sachem_xml_generic_route),
    URL = pbutil:get_env(pfront_orangef, sachem_xml_generic_url),
    Timeout = pbutil:get_env(pfront_orangef, sachem_xml_generic_timeout),
    {Path, Route, URL, Timeout}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% quick sort
%% +type qsort(List::list,Fun::fun()) ->  Result::list()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qsort([], _)->[];
qsort([Pivot|Rest], FunName) ->
    qsort([X || X <- Rest, FunName(X, Pivot)], FunName)
    ++ [Pivot] ++
    qsort([X || X <- Rest, not FunName(X, Pivot)], FunName).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% compare 2 Keys, first compare with the Index [i], then the position of
%% KeyList, e.g. List = ["a", "b", "c"]. 
%%               ("a[0]", "b[1]") -> true;
%%               ("c[4]", "b[2]") -> false;
%%               ("a[0]", "b[0]") -> true;
%%               ("c[0]", "b[0]") -> false
%% +type compare_element(Elem1::tuple{Key1::string(),_},
%% Elem2::tuple{Key1::string(),_}, List::list()) ->  Result::bool()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compare_element({Key1,_},{Key2,_},List) ->
    Index1 = get_index(Key1),
    Index2 = get_index(Key2),
    Pos1 = find_position(remove_index(Key1), List),
    Pos2 = find_position(remove_index(Key2), List),
    case Index1 < Index2 of
        true -> true;
        _ ->
            case Index1 == Index2 of
                true ->
                    Pos1 < Pos2;
                _ -> false
            end
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get index from key, key = "KEY[3]" index = 3.
%% +type get_index(Key::string()) ->  Result::integer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_index(Key) ->
    list_to_integer(string:sub_string(Key,string:chr(Key, $[)+1, 
            string:chr(Key, $])-1)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% remove index from key, key = "KEY[3]" result = "KEY".
%% +type remove_index(Key::string()) ->  Result::string()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_index(Key) ->
    case string:chr(Key, $[) of
        0 -> Key;
        Pos -> string:sub_string(Key,1,Pos-1)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% return the position of a element in the list, if not exsit, return 0
%% +type find_position(Elem:term(), List::list()) ->  Result::integer()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
find_position(Elem, List) ->
    find_position(Elem, List, 0).
find_position(_, [], Position) ->
    Position;
find_position(Elem, [Elem|Rest], Position) ->
    Position+1;
find_position(Elem, [E|Rest], Position) ->
    find_position(Elem, Rest, Position+1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type check_if_member(Key::string(), List::list()) ->  Result::bool()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_if_member(Key, List) ->
    lists:member(remove_index(Key),List).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% remove the suffix of the key {"AAA[0]",_} -> {"AAA", _}
%% +type clear_suffix(List::list()) ->  Result::list()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear_suffix(List) ->
    lists:map(fun({Key,Val}) -> {remove_index(Key),Val} end, List).


slog_info(count, ?MODULE, RequestName)->
    #slog_info{descr="A "++request(RequestName)++" was sent to Sachem;"};
slog_info(count, ?MODULE, Response_Ok)->
    #slog_info{descr="A "++response(Response_Ok)++" was successfully returned by Sachem;"};
slog_info(count,?MODULE, {Response_with_error_code,Error})->
    #slog_info{descr="A "++response(Response_with_error_code)++" indicating "++Error++" in the trace",
               operational="1. Check the Counters & Statistics to see if occurrence is high,"
               "2. Check the Logs to identify the Error and MSISDN,"
               "3. Eventually verify with Sachem"};
slog_info(failure,?MODULE, {Response_Ko,timeout})->
    #slog_info{descr="A "++response(Response_Ko)++" received with timeout;"};
slog_info(failure,?MODULE, {Response_Ko,Error})->
    #slog_info{descr="A "++response(Response_Ko)++" received with the unknown error",
               operational="1. Check the Counters & Statistics to see if occurrence is high,"
               "2. Check the Logs to identify the Error and MSISDN,"
               "3. Eventually verify with Sachem"}.

request(RequestName) ->
    atom_to_list(RequestName).
response(Response) ->
    atom_to_list(Response).
