-module(cbhttp).

%% version 1
-export([rcod/1,vcod/3,mcod/3,info/1,pay/4,mcc/4,dmcc/2]).
%% choix version
-export([rcod/3,vcod/5,mcod/5,info/3,pay/6,mcc/6,dmcc/4,ident40/3]).
-export([encode_body/4,decode_body/2]).

-include("../../pfront/include/pfront.hrl").
-include("../../pfront/include/httpclient.hrl").
-include("../include/cbhttp.hrl").
-include("../../pservices_orangef/include/recharge_cb_cmo_new.hrl").
-include("../../pservices_orangef/include/recharge_cb_mobi.hrl").
-include("../../pdist/include/generic_router.hrl").


%% +deftype cbhttp_response() = {ok,[term()]} | {statut,integer()} . 
%% +deftype sub_of() = cmo | mobi.
%% +deftype param() = {VARNAME::string(),VALUE::string()}.
%% +deftype response() = {VARNAME::string(),FORMAT::string()}.
%% +deftype recharge_cb() = recharge_cb_cmo() | recharge_cb_mobi().

%% +type request(ORDRE::string(),[param()],[response()],
%%               URL::string(),Timeout::integer(),sub_of(),
%%               Version::integer()) -> 
%%  cbhttp_response().
request(Ordre, Params, Response, URL, Timeout,SUB,VERSION) ->
    %%%% recup routing, host, port, version, timeout from config
    %%%% example cbhttp_host ++ version,origine
    Conf =read_config(SUB),
    Bod = encode_body(Ordre,Params,Conf,VERSION),
    Req=
	#http_request{ routing = Conf#cbhttp_config.routing,
		       host=Conf#cbhttp_config.host, 
		       port = Conf#cbhttp_config.port,
		       method=post, 
		       url=URL, 
		       version="1.1",
		       headers=[ {"Accept", "*/*"} ],
		       body = lists:flatten(Bod),
		       timeout = Timeout
		      },
    slog:event(cbhttp, ?MODULE, request, Req),
    case catch generic_router:routing_request(?HTTPClient_Module,Req, Timeout) of
	{ok, {ok,_,200,_,Head,Body}}->
	    %%io:format("RESP:~p~n",[Body]),
	    slog:event(interface,?MODULE,response_ok,Body),
	    decode_body(Body,Response);
	Else ->
	    slog:event(interface,?MODULE,response_ko,Else),
	    {statut,Else}
    end.
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type rcod(MSISDN::string())-> cbhttp_response().
%%% old API : backward compatibility
rcod(MSISDN)->
    rcod(MSISDN,1,cmo).

%% +type rcod(MSISDN::string(),Version::integer(),sub_of()) -> 
%%          cbhttp_response().
rcod(MSISDN,1,SUB)->
    slog:event(trace,?MODULE,rcod_request),
    %% version 1
    Param=[{"MSISDN",MSISDN}],
    Response=[{"MSISDN","%s"},{"IMSI","%s"},{"NADV","%s"},
	      {"CODE_PLAN_TARIFAIRE","%s"},
	      {"NB_TENTATIVE","%d"},{"NUM_CLIENT","%s"}],
    request("RC25",Param,Response,"/rcm_sda.pgi",?TIMEOUT,SUB,1).

%% +type vcod(MSISDN::string(),IMSI::string(),Code::string()) -> 
%%                       cbhttp_response().
vcod(MSISDN,IMSI,CODE)->
    vcod(MSISDN,IMSI,CODE,1,cmo).

%% +type vcod(MSISDN::string(),IMSI::string(),Code::string(),
%%            Version::integer(),sub_of()) -> 
%%                       cbhttp_response().
vcod(MSISDN,IMSI,CODE,1,SUB)->
    %%%% version 1
    Param= [{"MSISDN",MSISDN},{"IMSI",IMSI},{"CODE",CODE}],
    Resp = [{"MSISDN","%s"},{"IMSI","%s"}],
    request("VCOD",Param,Resp,"/rcm_sda.pgi",?TIMEOUT,SUB,1).

%% +type mcod(MSISDN::string(),IMSI::string(),NCODE::string())->
%%         cbhttp_response().
mcod(MSISDN,IMSI,NCODE)->
    mcod(MSISDN,IMSI,NCODE,1,cmo).
%% +type mcod(MSISDN::string(),IMSI::string(),NCODE::string(),
%%            Version::integer(),sub_of()) -> cbhttp_response().
mcod(MSISDN,IMSI,NCODE,1,SUB)->
    %%%% version 1  
    Param=[{"MSISDN",MSISDN},{"IMSI",IMSI},{"NEWCODE",NCODE}],
    Resp =[{"MSISDN","%s"},{"IMSI","%s"}],
    request("MCOD",Param,Resp,"/rcm_sda.pgi",?TIMEOUT,SUB,1).

%% +type info(MSISDN::string())-> cbhttp_response().
info(MSISDN)->
    info(MSISDN,1,cmo).
%% +type info(MSISDN::string(),Version::integer(),sub_of()) -> 
%%         cbhttp_response().
info(MSISDN,1,SUB)->
   %%%% version 1  
    Param=[{"CLE","0"},{"MSISDN",MSISDN}],
    Resp =[{"DOSNUMID","%s"},{"MSISDN","%s"},{"IMSI","%s"},
	   {"EPR_NUM","%d"},{"ESC_NUM","%d"},{"DOS_MONTANT_REC","%d"},
	   {"DATEDER","%x"},{"UNT_NUM","%d"},{"PLAFOND_E","%d"},
	   {"SOLDE_E","%d"},{"VALID24","%x"},
	   {"NB_CPT","%d"},{"BONUS","%d"}],
    request("INFO",Param,Resp,"/rcm_info.pgi",?TIMEOUT,SUB,1);
info(MSISDN,2,SUB) ->
    %%%% version 2
    Param=[{"CLE","0"},{"MSISDN",MSISDN}],
    Resp =[{"DOSNUMID","%s"},{"MSISDN","%s"},{"IMSI","%s"},
	   {"EPR_NUM","%d"},{"ESC_NUM","%d"},{"DOS_CUMUL_REC","%d"},
	   {"DATEDER","%x"},{"UNT_NUM","%d"},{"PLAFOND_E","%d"},
	   {"SOLDE_E","%d"},{"VALID24","%x"},
	   {"NB_CPT","%d"},{"BONUS","%d"},{"MOBI_OPTION","%d"},
	   {"DOS_DATE_DER_REC","%x"},{"DOS_MONTANT_REC","%d"}],
    request("INFO",Param,Resp,"/rcm_info.pgi",?TIMEOUT,SUB,2).

%% +type pay(MSISDN::string(),IMSI::string(),DOSNUMID::integer(),
%%           RECH::recharge_cb()) -> cbhttp_response().
pay(MSISDN,IMSI,DOSNUMID,RECH_CB)->
    pay(MSISDN,IMSI,DOSNUMID,RECH_CB,1,cmo).
%% +type pay(MSISDN::string(),IMSI::string(),DOSNUMID::integer(),
%%           RECH::recharge_cb(),Version::integer(),sub_of()) -> 
%%    cbhttp_response().
pay(MSISDN,IMSI,DOSNUMID,#recharge_cb_cmo{montant=Montant,no_carte_cb=NO_CB,
				      date_valid_cb=FIN_DATE_CB,
				      cvx2=CVX2,
				      code_court=CC,tlr=TLR},1,SUB)->
    {IS_CVX2,CVX2_2} = format_cvx2(CVX2),
    {TYPE_PAY,CC2}= format_type_paiement(NO_CB,CC,TLR),
    [Montant2]=io_lib:format("~p",[trunc(currency:round_value(Montant)*1000)]),
    Param=[{"MSISDN",MSISDN},{"IMSI",IMSI},
	   {"DOSNUMID",integer_to_list(DOSNUMID)},
	   {"TYPE_PAIEMENT",TYPE_PAY},{"MONTANT",Montant2},
	   {"NO_CB",NO_CB},{"FIN_DATE_CB",FIN_DATE_CB},
	   {"CVX2",CVX2},{"CODE_COURT",CC2},{"CVX_A_EFFACER",IS_CVX2}],
    Resp=[{"MSISDN","%s"},{"IMSI","%s"},{"SOLDE","%d"},
	  {"UNT_NUM","%d"},{"BON_PCT","%d"},{"BONUS_MONTANT","%d"}],
    request("PAY",Param,Resp,"/rcm_pay.pgi",?PAY_TIMEOUT,SUB,1);
pay(MSISDN,IMSI,DOSNUMID,#recharge_cb_cmo{montant=Montant,no_carte_cb=NO_CB,
					  date_valid_cb=FIN_DATE_CB,
					  cvx2=CVX2,
					  code_court=CC,
					  tlr=TLR,
					  trc_num=TRC},
    Version,SUB)
  when (Version==2) or  (Version==3) ->
    {IS_CVX2,CVX2_2} = format_cvx2(CVX2),
    {TYPE_PAY,CC2}= format_type_paiement(NO_CB,CC,TLR),
    [Montant2]=io_lib:format("~p",[trunc(currency:round_value(Montant)*1000)]),
    Param=[{"MSISDN",MSISDN},{"IMSI",IMSI},
	   {"DOSNUMID",integer_to_list(DOSNUMID)},
	   {"TYPE_PAIEMENT",TYPE_PAY},{"MONTANT",Montant2},
	   {"NO_CB",NO_CB},{"FIN_DATE_CB",FIN_DATE_CB},
	   {"CVX2",CVX2},{"CODE_COURT",CC2},{"CVX_A_EFFACER",IS_CVX2},
	   {"TRC_NUM",TRC}],
    Resp=[{"MSISDN","%s"},{"IMSI","%s"},{"NB_CPT","%d"},
	  {"TCP_NUM","%d"},{"CPP_DATE_LV","%d"},{"SOLDE","%d"}, %% multi ?!
	  {"UNT_NUM","%d"},{"BON_PCT","%d"},{"BONUS_MONTANT","%d"}],
    request("PAY",Param,Resp,"/rcm_pay.pgi",?PAY_TIMEOUT,SUB,Version);
pay(MSISDN,IMSI,DOSNUMID,#recharge_cb_mobi{montant=Montant,no_cb=NO_CB,
					   date_valid=FIN_DATE_CB,
					   cvx2=CVX2,
					   trc_num=TRC},Version,SUB) 
  when (Version==2) or  (Version==3) ->
    {IS_CVX2,CVX2_2} = format_cvx2(CVX2),
    [Montant2]=io_lib:format("~p",[trunc(currency:round_value(Montant)*1000)]),
    Param=[{"MSISDN",MSISDN},{"IMSI",IMSI},
	   {"DOSNUMID",integer_to_list(DOSNUMID)},
	   {"TYPE_PAIEMENT","CB"},{"MONTANT",Montant2},
	   {"NO_CB",NO_CB},{"FIN_DATE_CB",FIN_DATE_CB},
	   {"CVX2",CVX2},{"CODE_COURT","0000"},{"CVX_A_EFFACER",IS_CVX2},
	   {"TRC_NUM",TRC}],
    Resp=[{"MSISDN","%s"},{"IMSI","%s"},{"NB_CPT","%d"},
	  {"TCP_NUM",{mult,"%d"}},{"CPP_DATE_LV",{mult,"%d"}},
	  {"SOLDE",{mult,"%d"}}, {"UNT_NUM",{mult,"%d"}},
	  {"BON_PCT",{mult,"%d"}},{"BONUS_MONTANT",{mult,"%d"}}],
    request("PAY",Param,Resp,"/rcm_pay.pgi",?PAY_TIMEOUT,SUB,Version).
    

%% +type mcc(MSISDN::string(),IMSI::string(),NO_CB::string(),DATE_CB::string()) -> 
%%                     cbhttp_response().
mcc(MSISDN,IMSI,NO_CB,DATE_CB)->
    mcc(MSISDN,IMSI,NO_CB,DATE_CB,1,cmo).
%% +type mcc(MSISDN::string(),IMSI::string(),NO_CB::string(),
%%           DATE8CB::string(),VERSION::integer(),sub_of()) -> cbhttp_response().
mcc(MSISDN,IMSI,NO_CB,DATE_CB,_,SUB)->
    Param=[{"MSISDN",MSISDN},{"IMSI",IMSI},{"PRODUIT","OL1"},
	   {"NO_CB",NO_CB},{"FIN_DATE_CB",DATE_CB}],
    Resp =[{"MSISDN","%s"},{"IMSI","%s"},{"CODE_COURT","%s"}],
    request("MCC",Param,Resp,"/rcm_mcc.pgi",?MCC_TIMEOUT,SUB,1).

%% +type dmcc(MSISDN::string(),CODE::string()) -> cbhttp_response().
dmcc(MSISDN,CODE) ->
    dmcc(MSISDN,CODE,1,cmo).
%% +type dmcc(MSISDN::string(),CODE::string(),Version::integer(),sub_of()) -> 
%%         cbhttp_response().
dmcc(MSISDN,CODE,_,SUB) ->
    %% Version 1
    Param=[{"MSISDN",MSISDN},{"CODE_COURT",CODE}],
    Resp =[{"MSISDN","%s"},{"IMSI","%s"}],
    request("DMCC",Param,Resp,"/rcm_dmcc.pgi",?TIMEOUT,SUB,1).

%% +type ident40(MSISDN::string(),V::integer(),sub_of())-> cbhttp_response().
ident40(MSISDN,_,SUB)->
    Param=[{"MSISDN",MSISDN}],
    Resp =[{"MSISDN","%s"},{"IMSI","%s"},{"NOADV","%d"},{"CODE_PLT","%s"},
	   {"NUM_CLNT","%d"},{"TYPE_DOS","%s"},{"CODE_PROD","%s"},
	   {"SEG_OP","%s"},{"PARC","%s"},{"ID_SCS","%s"},{"ETADOS","%s"},
	   {"LIB_ETADOS","%s"},{"ETAPE_REC","%s"},{"SO","%s"},
	   {"FACT_MOY","%s"}],
    request("RIDENT_40",Param,Resp,"/rcm_ident40.pgi",?TIMEOUT,SUB,1).

%%%% UTILITIES
%% +type read_config(sub_of())-> cbhttp_config().
read_config(SUB) ->
    Fields = record_info(fields, cbhttp_config),
    HH = #cbhttp_config{}, %%%% Uses default values from http.hrl.
    %%%% Read the default permissions.
    Config = pbutil:get_env(pfront_orangef, cbhttp_config),
    %% recup SUB profile
    {value,{SUB,HH1}} = lists:keysearch(SUB,1,Config),
    pbutil:update_record(Fields, HH, HH1).
      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Encodage /Decodage %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +deftype cb_parameter()= {Name::string(),Value::string()}.

%% +type encode_body(Ordre::string(),[cb_parameter()],
%%                   cbhttp_config(),V::integer())-> string().
encode_body(ReqName,Args,Conf,V)->
    Version= pbutil:sprintf("%02d",[V]),
    L =  [{"ORDRE", ReqName},
	  {"VERSION", to_list(Version)},
	  {"ORIGINE", Conf#cbhttp_config.origine}]++
	Args,
    encode(L,[]).

%% +type encode([cb_parameter()],string())-> string().
encode([{Arg,Val}|[]],Acc) ->
    Acc2=Acc++Arg++"="++to_list(Val),
    Acc2;			
encode([{Arg,Val}|T],Acc)->
    Acc2=Acc++Arg++"="++to_list(Val)++"&",
    encode(T,Acc2).

%% +type to_list(term())-> string().
to_list(I) when integer(I)->
    integer_to_list(I);
to_list(I) when list(I)->
    I;
to_list(undefined)->
    "";
to_list(I) when atom(I)->
    atom_to_list(I).

%%%%% ENCODE FIELDS
%% +type format_cvx2(undefined | string())-> {string(),string()}.
format_cvx2(undefined)->
    {"0","   "};
format_cvx2(CVX2)->
    {"1",CVX2}.

%% +type format_type_paiement(undefined|string(),undefined|string(),undefined|string())-> {string(),string()}.
format_type_paiement(undefined,CC,undefined)->
    {"CC",CC};
format_type_paiement(_,CC,undefined)->
    {"CB",CC};
format_type_paiement(_,undefined,TLR) when list(TLR)->
    {"TL",TLR}.
%%%% Body Format => STATUT=0000;Name=Value;Name2=Value;....
%%%%                STATUT=0401;STATUT_LINELLE=Description
%%%%                STATUT=XXXX

%% +deftype cbhttp_format()= {Name::string(),Format::string()}.

%% +type decode_body(string(),[cbhttp_format()])-> 
%%                  {ok,[Value]}
%%               |  {statut, integer()}.
decode_body(Body,Response)->
    Body2= case pbutil:split_at($\n, Body) of
	       {B,Rest}->
		   B;
	       not_found->
		   Body
	   end,   
    L_var=string:tokens(Body2,";"),
    Var_Lists=
	lists:map(fun(P)->
			  {Name,Value} =
			      case string:tokens(P,"=") of
				  [N,V]->
				      {N,V};
				  [N|V]->
				      {N,V}
			      end,
			  {Name,Value}
		  end,L_var),
    format_response(Var_Lists,Response).
    
%% +type format_response([param()],[response()])-> {ok, [term()]} | 
%%                                                 {statut,integer()}.
format_response([{"STATUT",Val}|T],Resp)->
    case pbutil:sscanf("%d",Val) of
	{[X],Rest} when X==0->
	    {ok,format_response(T,Resp,[])};
	{[X],Rest} ->
	    %%%% Si info supplémentaire, retournée valeur sous forme d'alarme
	    statut_libelle(T,X),
	    {statut,X}
    end.

%% +type format_response([param()],[response()],term())-> term().
format_response([{Name,Val}|T],Resp,Acc)->
    case lists:keysearch(Name,1,Resp) of
	{value, {Name,{mult,Format}}}->
	    Vals = string:tokens(Val,":"),
	    Valds=lists:map(fun(Valx)->
				    {[Val_d],Rest}=pbutil:sscanf(Format,Valx),
				    Val_d
			    end,Vals),
	    format_response(T,Resp,Acc++[Valds]);
	{value, {Name,Format}}->
	    {[Val_d],Rest}=pbutil:sscanf(Format,Val),
	    format_response(T,Resp,Acc++[Val_d]);
	false ->
	    slog:event(warning,?MODULE,unknown_variable,Name),
	    format_response(T,Resp,Acc)
    end;
format_response([],Resp,Acc) ->
    Acc.

%% +type statut_libelle([param()],atom())-> ok.
statut_libelle(T,X)->
    case lists:keysearch("STATUT_LIBELLE",1,T) of
	{value, {_,Descr}}->
	    slog:event(warning,?MODULE,{format_error,X,Descr});
	_->
	    ok
    end.
