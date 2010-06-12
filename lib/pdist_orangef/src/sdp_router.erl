-module(sdp_router).
-export([svi_a/1,svi_b/5, svi_d/3]).
-export([svi_g/4]).
-export([svi_h/2,svi_i/3]).
-export([svi_trc1/3, svi_tri1/3, svi_tre1/3, svi_trm1/2, svi_trs1/1]).
-export([svi_mns1/3, svi_mnp1/3, svi_mnr1/1,accesgprs/1]).
-export([mtl_idmtl2/2,mtl_ftm01/2]).
-export([tlv_a3/1,tlv_a4/1]).
-export([svi_mns2/3]).
-export([svi_d4/4,svi_d5/4,svi_d6/4]).
-export([start_link/1]).
-export([pool_get_attrib/1]).
-export([svi_espadon/12]).
-export([svi_cpt/3,svi_c_op/1,svi_c_op/2, svi_c_op2/4,svi_nopt_cpt/3, svi_g2/6]).
-export([svi_ntrd/3]).
-export([c_tck/3]).

%%%% <h2> Client API </h2>
%%%% Here we just invoke sdp_server's client API, with the first
%%%% argument SRV=sdp_router.

%%%% just use by CMO
svi_a(MSISDN) ->
    slog:event(warning, ?MODULE, svi_a, {is_not_expected_to_be_used, MSISDN}),
    sachem_server:svi_a(?MODULE, MSISDN).
mtl_ftm01(CritId, Tranche) ->
    slog:event(warning, ?MODULE, mtl_ftm01, {is_not_expected_to_be_used, CritId, Tranche} ),
    sachem_server:mtl_ftm01(?MODULE, CritId, Tranche).

%%%% New A3 _ Use by Both
tlv_a3(CritId)->
    slog:event(warning, ?MODULE, tlv_a3, {is_not_expected_to_be_used, CritId}),
    sachem_server:tlv_a3(?MODULE,CritId).  

%%%% New A4 _ Use by Both
tlv_a4(CritId)->
    sachem_server:tlv_a4(?MODULE,CritId).

%%%% use by both
%%% seems to be used during provisioning
svi_b(MSISDN, DTA, Duration, NUM, Price) ->
%    slog:event(warning, ?MODULE, tlv_d, {is_not_expected_to_be_used, MSISDN, DTA, Duration, NUM, Price }),
    sachem_server:svi_b(?MODULE, MSISDN, DTA, Duration, NUM, Price).

svi_d(MSISDN, CG, DTA) ->
    slog:event(warning, ?MODULE, tlv_d, {is_not_expected_to_be_used, MSISDN, CG, DTA}),
    sachem_server:svi_d(?MODULE, MSISDN, CG, DTA).

svi_d4(MSISDN, CG, DTA, CX) ->
    slog:event(warning, ?MODULE, tlv_d4, {is_not_expected_to_be_used, MSISDN, CG, DTA, CX}),
    sachem_server:svi_d4(?MODULE, MSISDN, CG, DTA, CX).

%%% is used by Eskimo
svi_d5(MSISDN, CG, DTA, CX) ->
    slog:event(warning, ?MODULE, tlv_d5, {is_not_expected_to_be_used, MSISDN, CG, DTA, CX}),
    sachem_server:svi_d5(?MODULE, MSISDN, CG, DTA, CX).

svi_d6(MSISDN, CG, DTA, CX) ->
    sachem_server:svi_d6(?MODULE, MSISDN, CG, DTA, CX).

svi_g(MSISDN, PT, Cout, DTA) ->
    slog:event(warning, ?MODULE, tlv_g, {is_not_expected_to_be_used, MSISDN, PT, Cout, DTA}),
    sachem_server:svi_g(?MODULE, MSISDN, PT, Cout,DTA).

svi_h(MSISDN, Option) ->
    slog:event(warning, ?MODULE, tlv_h, {is_not_expected_to_be_used, MSISDN, Option}),
    sachem_server:svi_h(?MODULE, MSISDN, Option).

%%%% just use by mobicarte for the moment
mtl_idmtl2(CritId, Tranche) ->
    sachem_server:mtl_idmtl2(?MODULE, CritId, Tranche).

svi_i(MSISDN, Type, Code) ->
    sachem_server:svi_i(?MODULE, MSISDN, Type, Code).
svi_trc1(MSISDN, Code, Price) ->
    sachem_server:svi_trc1(?MODULE, MSISDN, Code, Price).
svi_tri1(MSISDN, Member, Code) ->
    sachem_server:svi_tri1(?MODULE, MSISDN, Member, Code).
svi_tre1(MSISDN, IdTribu, Price) ->
    sachem_server:svi_tre1(?MODULE, MSISDN, IdTribu, Price).
svi_trm1(MSISDN, Price) ->
    sachem_server:svi_trm1(?MODULE, MSISDN, Price).
svi_trs1(MSISDN) ->
    sachem_server:svi_trs1(?MODULE, MSISDN).

svi_mns1(MSISDN, Duration, Price) ->
    sachem_server:svi_mns1(?MODULE, MSISDN, Duration, Price).
svi_mns2(MSISDN, Rub, Price) ->
    sachem_server:svi_mns2(?MODULE, MSISDN, Rub, Price).
svi_mnp1(MSISDN, Duration, Price) ->
    sachem_server:svi_mnp1(?MODULE, MSISDN, Duration, Price).
svi_mnr1(MSISDN) ->
    sachem_server:svi_mnr1(?MODULE, MSISDN).
accesgprs(MSISDN) ->
    sachem_server:svi_accesgprs(?MODULE, MSISDN).

svi_espadon(MSISDN,TYPE_ACTION,TOP_FLAG,TOP_DATE_DEB,TOP_HEURE_DEB,
	    TOP_DATE_FIN,TOP_HEURE_FIN,TOP_COUT,TCP_NUM,PTF_NUM,OPT_INFO_1,
	    OPT_INFO_2) ->
    sachem_server:svi_espadon(?MODULE, MSISDN,TYPE_ACTION,TOP_FLAG,
			      TOP_DATE_DEB,TOP_HEURE_DEB,
			      TOP_DATE_FIN,TOP_HEURE_FIN,
			      TOP_COUT,TCP_NUM,PTF_NUM,OPT_INFO_1,OPT_INFO_2).

svi_cpt({mobi,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{mobi,Msisdn},Req);
svi_cpt({cmo,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{cmo,Msisdn},Req);
svi_cpt({symacom,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{symacom,Msisdn},Req);
svi_cpt({monacell_prepaid,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{monacell_prepaid,Msisdn},Req);
svi_cpt({monacell_comptebloqu,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{monacell_comptebloqu,Msisdn},Req);
svi_cpt({tele2_pp,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{tele2_pp,Msisdn},Req);
svi_cpt({tele2_comptebloque,Msisdn},Action,Req) ->
    sachem_server:svi_cpt2(?MODULE,{tele2_comptebloque,Msisdn},Req);
svi_cpt(SVIKey,Action,Req) ->
    sachem_server:svi_cpt(?MODULE,SVIKey,Req).

svi_nopt_cpt({cmo,Msisdn},Action,Req)->
     sachem_server:svi_nopt_cpt(?MODULE,{cmo,Msisdn},Req);

svi_nopt_cpt({mobi,Msisdn},Action,Req)->
     sachem_server:svi_nopt_cpt(?MODULE,{mobi,Msisdn},Req).

%% +type svi_c_op({atom,Msisdn::string()},Top_num::integer())-> {atom(),term()}.
%%%% is option activated
svi_c_op(SVIKey,Top_num) when integer(Top_num) ->
    sachem_server:svi_c_op(?MODULE,SVIKey,integer_to_list(Top_num));
svi_c_op(SVIKey,Top_num) when list(Top_num)->
    sachem_server:svi_c_op(?MODULE,SVIKey,Top_num).


%% +type svi_c_op({atom(),Msisdn::string()})-> {atom(),term()}.
%%%% return bit field which represent all option activated
svi_c_op(SVIKey) ->
    sachem_server:svi_c_op(?MODULE,SVIKey,"NULL").

%% +type svi_c_op2({atom(),string()}, Criteria_type::string(), 
%%                  Criteria_value::string(), TOP_NUM::string())
%%                 -> {atom(),term()}.
%%%% Detailed questioning of the options
svi_c_op2(SVIKey, Criteria_type, Criteria_value, TOP_NUM) ->
    sachem_server:svi_c_op2(?MODULE, SVIKey,  
			    Criteria_type, Criteria_value, TOP_NUM).

%% +type svi_ntrd(svi_key(), Receiver::string(), Transfer_ID::string()) 
%%               -> {atom(),string()}.
svi_ntrd(SVIKey, Receiver, Transfer_ID) ->
    sachem_server:svi_ntrd(?MODULE, SVIKey, Receiver, Transfer_ID).

%% +type svi_c_tck(svi_key(), Receiver::string(), Transfer_ID::string()) 
%%               -> {atom(),string()}.
c_tck(SVIKey, C_tck_key_type, C_tck_key_value) ->
    sachem_server:c_tck(?MODULE, SVIKey, C_tck_key_type, C_tck_key_value).


%% +type svi_g2({atom(),Msisdn::string()}, PT::integer(),currency:currency(),
%%                 TCP::integer(),CTRL_ESC::integer())-> {atom(),[integer()]}.
svi_g2(MSISDN, PT, Cout, DTA, TCP, CTRL_ESC) ->
    sachem_server:svi_g2(?MODULE, MSISDN,PT,Cout,DTA,TCP,CTRL_ESC).

%% <h2> Server API </h2>
%% +type start_link([pool_server:worker()]) -> gs_start_result().
start_link(Workers) ->
    Arg = {{?MODULE,pool_get_attrib}, Workers},
    pool_server:start_link({?MODULE, Workers, fun()-> true end}).

pool_get_attrib({sdp_request, Attr, Request, Prefix}) ->
    Attr;
pool_get_attrib({sdp_request, Attr, Request, PesponsePrefix_1,  
		 ResponsePrefix_2}) ->
    Attr.
