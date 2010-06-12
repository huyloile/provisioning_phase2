-module(tlv_router).
-include("../../pfront_orangef/include/tlv.hrl").
-export([start_link/1]).
-export([pool_get_attrib/1]).

-export([mk_INT_ID01/2, mk_INT_ID02/2, mk_INT_ID04/6, mk_INT_ID27/3]).
-export([mk_INT_IG31ter/3,mk_INT_ID14/7]).

%%%% <h2> Client API </h2>
%%%% Here we just invoke sdp_server's client API, with the first
%%%% argument SRV=tlv_router.

mk_INT_ID01(ID,{Crit,Id})->
    tlv_server:request(?MODULE,
		       code_id(ID),
		       ?int_id01,
		       [{?DOS_TYPE,crit_val(Crit)},
			{?DOS_ID,Id}]).
    
%%%% information sur le compte principale
mk_INT_ID02(ID,DOS_NUMID)->
    tlv_server:request(?MODULE,
		       code_id(ID),
		       ?int_id02,
		       [{?DOS_NUMID,DOS_NUMID}]).

%%%% liste les comptes d'un dossier
mk_INT_ID04(ID,DOS_NUMID,Dir,Col_Tri,Val_Filtre,Pos)->
    tlv_server:request(?MODULE,
		       code_id(ID),
			?int_id04,
			[{?DOS_NUMID,DOS_NUMID},
			 {?DIRECTION,Dir},{?COLONNE_TRI,Col_Tri},
			 {?VALEUR_FILTRE,Val_Filtre},{?POSITION,Pos}]).

%% Permet d'imputer un transfert pour un dossier
mk_INT_ID27(ID,DOS_NUMID,TRC_NUM)->
   tlv_server:request(?MODULE,
		      code_id(ID),
		      ?int_id27,
		      [{?ACI_NUM,?Val_ACI_NUM},{?DOS_NUMID,DOS_NUMID},
		       {?TRC_NUM,TRC_NUM}]).


mk_INT_IG31ter(ID,RATIO_NUM,MAX)->
  tlv_server:request(?MODULE,
		     code_id(ID),
		     ?PROC,
		     [{?PS_NAME,"INT_IG31_iter"},
		      {?PS_INT,RATIO_NUM},
		      {?PS_INT,MAX}]).

%% Permet d'imputer un transfert pour un dossier
mk_INT_ID14(ID,DOS_NUMID,PSC_NUM,PCT_MONTANT,UNT_NUM,PCT_NBJOUR,TCP_NUM)->
   tlv_server:request(?MODULE,
		      code_id(ID),
		      ?int_id14,
		      [{?ACI_NUM,-1},
		       {?DOS_NUMID,DOS_NUMID},
		       {?PSC_NUM,PSC_NUM},
		       {?PCT_MONTANT,PCT_MONTANT},
		       %%{?UNT_NUM,UNT_NUM},
		       {?PCT_NBJOUREX,PCT_NBJOUR},
		       {?TCP_NUM,TCP_NUM}]).
crit_val(Crit)->
    case Crit of
	dos_num -> 0;
	msisdn ->  1;
	nsce ->    2;
	imsi ->    3;
	abo ->     4
    end.
code_id(cmo)->
    ?id_cmo;
code_id(mobi) ->
    ?id_mobi;
code_id(_) ->
    ?id_all.
%% <h2> Server API </h2>
%% +type start_link([worker()]) -> gs_start_result().
start_link(Workers) ->
    Arg = {{?MODULE,pool_get_attrib}, Workers},
    pool_server:start_link({?MODULE, Workers, fun()-> true end}).

pool_get_attrib({tlv_request, Request }) ->
    [].
