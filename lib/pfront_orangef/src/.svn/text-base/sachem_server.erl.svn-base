-module(sachem_server).

%%%% Client API
-export([svi_a/2,svi_b/6, svi_d/4]).
-export([svi_g/5]).
-export([svi_h/3, svi_i/4]).
-export([svi_trc1/4, svi_tri1/4, svi_tre1/4, svi_trm1/3, svi_trs1/2]).
-export([svi_mns1/4, svi_mnp1/4, svi_mnr1/2,svi_accesgprs/2]).
-export([mtl_idmtl2/3]).
-export([mtl_ftm01/3,mtl_ftm21/2]).
-export([tlv_a3/2]).                    % requete de description de la requete
-export([tlv_a4/2]).                    % requete de consultation
-export([svi_mns2/4]).                  % Requete de souscription à l'option Mini-news
-export([svi_d4/5,svi_d5/5, svi_d6/5]). % requetes pour le rechargement par ticket
-export([svi_espadon/13]). %% shouldn't be used anymore
-export([svi_cpt/3, svi_cpt2/3, svi_nopt_cpt/3]).       % requete de gestion d'option
-export([svi_c_op/3,svi_c_op2/5]).      % requete de consultation d'options (detaillees)
-export([svi_g2/7]).                    % requete de changement de plan tarifaire
-export([svi_ntrd/4]).                  % requete de transfert de credit inter comptes
-export([c_tck/4]).                     % requete de consultation de ticket
-export([intl_to_nat/1]).

%%%% temporary export
-export([check_response_svi/3,check_response_mtl/3]).

%%%% Server
-export([start_link/1, init/1]).

-behaviour(gen_server).
-export([init/1, handle_call/3,  handle_info/2, 
	 code_change/3, handle_cast/2, terminate/2]).

%%%% for test_sdp_server:create_user
-export([svi_request/5]). 
-export([check_response_svi/3]). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +deftype gs_hcast_result() = {noreply,term()} | {reply,term()}.

-include("../include/sdp.hrl").
-include("../../pfront/include/pfront.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(MAX_NB_OPTIONS, 50).
-define(MAX_NB_MSISDN_OPTIONS, 50). %MSISDN attached to options
-define(MAX_NB_OPTIONS_TARIF_DEGRS, 1). %degressive tarification options 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +type start_link(interface()) -> gs_start_result().

start_link(#interface{type=sdp, name_node={Name,_Node}}=Interface) ->
    %% We don't register as Name until the connection is established.
    gen_server:start_link(?MODULE, Interface, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +deftype response_format() = [ {Tag::atom(), svi_format()} ].
%% +deftype svi_format() = io_format() 
%%                    | [svi_format_item()].
%% +deftype svi_format_item() = {prefix, io_format()}
%%                         | {repeat, io_format()}.
%%%% TODO Extensions pour requêtes minitel.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVI API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% +deftype msisdn() = string().
%% +deftype imsi() = string().

%% +deftype svi_key() = {mobi|cmo|omer, msisdn()}.
%%%% This is the type of keys for all SVI requests except svi_cl.

%% +deftype svi_cl_key() = {mobi|cmo, {msisdn,msisdn()}|{imsi,imsi()}}.

%% +type svi_a(atom(), svi_key()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête d'interrogation d'un CMO 
%%%% Unuse

svi_a(SRV, SVIKey) ->
    svi_request(SRV, "A", SVIKey, "",
		[ {ok, "00 %4s %d %d %d %x %d %d %x %x"},
		  {status, "%02d"} ]).

%% +type svi_b(atom(), svi_key(),date(),Duration::integer(),
%%             integer(), currency:currency()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de taxation 
%%%% Unuse

svi_b(SRV, SVIKey, DTA, Duration, NUM, Price) ->
    %% V22 = currency in interface version 2, N2 = Price
    {V22, N2} = 
	case pbutil:get_env(pfront_orangef, sdp_interface_version) of
	    1 ->
		%% All sums are in francs
		{0,
		 round(currency:round_value(currency:to_frf(Price))*1000)};
	    2 ->
		%% Ok to use currency
		ResV2 = case currency:currency(Price) of
			    frf -> 0;
			    euro  -> 1
			end,
		{ResV2,
		 round(currency:round_value(Price)*1000)}
	end,
    V1 = Duration,
    V21 = 0, % not used
    N1 = 0,    % not used
    Req = pbutil:sprintf("%x %d %d %d %19s %d %d",
			 [DTA, V1, V21, V22, NUM, N1, N2]),
    svi_request(SRV, "B", SVIKey, Req, [{ok, "00"}, {status, "%02d"},
				       {status, "%d %d"}]). %% 10 3

%% +type svi_d(atom(), svi_key(),CG::string(),date()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Rechargement 

svi_d(SRV, SVIKey, CG, DTA) ->
    Req = pbutil:sprintf("%s %x", [CG, DTA]),
    svi_request(SRV, "D", SVIKey, Req,
		%% =/= specs Prosodie : vald=%d, valf=%d
		[ {ok, "00 %4s %d %d %d %x %d %d %d %s %d %d %d"}, 
		  {status, "%d %d"},               % qualified errors
		  {status, "%d"}                   % simple errors
		 ]).

%%%% Requetes de Rechargement : d4, d5, d6 :
%%%% Q : D4 MSISDN TICKET DATE CHOIX     -
%%%% R : D4MSISDN STATUT ERR TTK_VALEUR_REELLE CTK_NUM   -     DOS_DATE_LV zone_60 [zone_60 ...]
%%%% Q : D5 MSISDN TICKET DATE CHOIX CANAL_NUM
%%%% R : D5MSISDN STATUT ERR TTK_VALEUR_REELLE CTK_NUM   -     DOS_DATE_LV zone_60 [zone_60 ...]
%%%% Q : D6 MSISDN TICKET DATE CHOIX CANAL_NUM
%%%% R : D6MSISDN STATUT ERR TTK_VALEUR_REELLE CTK_NUM TTK_NUM DOS_DATE_LV zone_60 [zone_60 ...]

%% +type svi_d4(atom(), svi_key(),CG::string(),date(),integer()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Rechargement 

svi_d4(SRV, SVIKey, CG, DTA, CHOIX) ->
    Req = pbutil:sprintf("%s %x %d", [CG, DTA, CHOIX]),
    svi_request(SRV, "D4", SVIKey, Req,
		%% =/= specs Prosodie : vald=%d, valf=%d
		[ {ok, [{prefix,"00 %d %d %x"}]++[{z60,10}]}, 
		  {status, "%d %d"},               % qualified errors
		  {status, "%d"}                   % simple errors
		 ]).

%% +type svi_d5(atom(), svi_key(),CG::string(),date(),inte ger()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Rechargement 

svi_d5(SRV, SVIKey, CG, DTA, CHOIX) ->
    CL_NUM = pbutil:get_env(pfront_orangef,d5_canal_num),
    Req = pbutil:sprintf("%s %x %d %d", [CG, DTA, CHOIX,CL_NUM]),
    svi_request(SRV, "D5", SVIKey, Req,
		%% =/= specs Prosodie : vald=%d, valf=%d
		[ {ok, [{prefix,"00 %d %d %x"}]++[{z60,10}]}, 
		  {status, "%d %d"},               % qualified errors
		  {status, "%d"}                   % simple errors
		 ]).

%% +type svi_d6(atom(), svi_key(),CG::string(),date(),integer()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Rechargement 

svi_d6(SRV, SVIKey, TICKET, DATE, CHOIX) ->
    CANAL_NUM = pbutil:get_env(pfront_orangef,d6_canal_num),
    Req = pbutil:sprintf("%s %x %d %d", [TICKET, DATE, CHOIX, CANAL_NUM]),
    svi_request(SRV, "D6", SVIKey, Req,
		%% =/= specs Prosodie : vald=%d, valf=%d
		[ {ok, [{prefix,"00 %d %d %d %x"}]++[{z60,10}]}, 
		  {status, "%d %d"},               % qualified errors
		  {status, "%d"}                   % simple errors
		 ]).

%% +type svi_g(atom(), svi_key(),PT::integer(),currency:currency(),date()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Changement de Plan Tarifaire
 
svi_g(SRV, SVIKey, PT, Cout, DTA) ->
    CoutSum = round(currency:round_value(Cout)*1000),
    CoutCur = case currency:currency(Cout) of
		  frf -> 0;
		  euro -> 1
	      end,
    ReqCout= pbutil:sprintf("%d %x %d", [CoutSum, DTA, CoutCur]),
    Req = pbutil:sprintf("%02d", [PT]),
    svi_request(SRV, "G", SVIKey, Req++" "++ReqCout,
		[ {ok, "00"},
		  {status, "%02d %d"},               % qualified errors
		  {status, "%02d"} ]).          	% simple errors

%% +type svi_g2(atom(), svi_key(),PT::integer(),currency:currency(),date(),
%%              TCP::integer(),CTRL_ESC::integer()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Changement de Plan Tarifaire
 
svi_g2(SRV, SVIKey, PT, Cout, DTA, TCP, CTRL_ESC) ->
    CoutSum = round(currency:round_value(Cout)*1000),
    CoutCur = case currency:currency(Cout) of
		  frf -> 0;
		  euro -> 1
	      end,
    ReqCout= pbutil:sprintf("%d %x %d %d %d", [CoutSum, DTA, CoutCur,TCP,CTRL_ESC]),
    Req = pbutil:sprintf("%d", [PT]),
    svi_request(SRV, "G2", SVIKey, Req++" "++ReqCout,
		[ {ok, "00"},
		  {status, "%02d %d"},               % qualified errors
		  {status, "%02d"} ]).          	% simple errors


%% +type svi_h(atom(), svi_key(), Option::atom()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête d'Activation Vocale 
%%%% sachem add a date in the end of the request

svi_h(SRV, SVIKey, Option) ->
    DTA=pbutil:unixtime(),
    Req = case Option of
	      suppression -> 0;
	      activation -> 1
	  end,
    Req2=pbutil:sprintf("%d %x", [Req, DTA]),
    svi_request(SRV, "H", SVIKey, Req2,
		[ {ok, "00"},
		  %% {status, "%d %d"}, %% bug prosodie 
		  {status, "%02d"} ]).

%% +type svi_i(atom(), svi_key(), Type::atom(),Code::string()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête de Modification de code Client/Invité
svi_i(SRV, SVIKey, Type, Code) ->
    Req = case Type of
	      client -> pbutil:sprintf("1 %4s", [Code]);
	      invite -> pbutil:sprintf("2 %4s", [Code])
	  end,
    svi_request(SRV, "I", SVIKey, Req,
		[ {ok, "00"},
		  {status, "%02d"} ]).

%% +type svi_trc1(atom(), svi_key(), Code::string(), currency:sum()) ->
%%                   {ok, [Idtribu::integer()]}
%%                 | {status, [ErrCode::integer()]}.
%%%% Requete de creation de tribu
svi_trc1(SRV, SVIKey, Code, Price) ->
    Req = Code ++ " " ++
	case currency:currency(Price) of
	    frf ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " F";
	    euro ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " E";
	    _ ->
		EuroPrice=currency:to_euro(Price),
		integer_to_list(round(currency:round_value(EuroPrice)*1000))
		    ++ " E"
	end,
    svi_request(SRV, "TRC1", SVIKey, Req, [{ok, "00 %d"}, {status, "%02d"}]).

%% +type svi_tri1(atom(), svi_key(), Member::string(), Code::string()) ->
%%                   {ok, [Args]}
%%                 | {status, [Code::integer()]}.
%%%% Requête d'interrogation d'un tribu
svi_tri1(SRV, SVIKey, Member, Code) ->
    Req = Member ++ " " ++ Code,
    svi_request(SRV, "TRI1", SVIKey, Req,
		[{ok, [{prefix, "00 %d"}, {repeat, " %d %s"}]},
		 {status, "%02d"}]).

%% +type svi_tre1(atom(), svi_key(), Idtribu::integer(), currency:sum()) ->
%%                   {ok, [Num::integer()]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête de sollicitation d'intégration d'une tribu
svi_tre1(SRV, SVIKey, IdTribu, Price) ->
    Req = integer_to_list(IdTribu) ++ " " ++
	case currency:currency(Price) of
	    frf ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " F";
	    euro ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " E";
	    _ ->
		EuroPrice=currency:to_euro(Price),
		integer_to_list(round(currency:round_value(EuroPrice)*1000))
		    ++ " E"
	end,
    svi_request(SRV, "TRE1", SVIKey, Req, [{ok, "00 %3d"}, {status, "%02d"}]).

%% +type svi_trm1(atom(), svi_key(), currency:sum()) ->
%%                   {ok, [Empty]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête d'interrogation d'une tribu avec retour par sms
svi_trm1(SRV, SVIKey, Price) ->
    Req = case currency:currency(Price) of
	      frf ->
		  integer_to_list(round(currency:round_value(Price)*1000)) ++
		      " F";
	      euro ->
		  integer_to_list(round(currency:round_value(Price)*1000)) ++
		      " E";
	      _ ->
		  EuroPrice=currency:to_euro(Price),
		  integer_to_list(round(currency:round_value(EuroPrice)*1000))
		      ++ " E"
	  end,
    svi_request(SRV, "TRM1", SVIKey, Req, [{ok, "00"}, {status, "%02d"}]).

%% +type svi_trs1(atom(), svi_key()) ->
%%                   {ok, [string()]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête de sortie d'une tribu
svi_trs1(SRV, SVIKey) ->
    svi_request(SRV, "TRS1", SVIKey, "", [{ok, "00"}, {status, "%02d"}]).
    
%% +type svi_mns1(atom(), svi_key(), Duration::integer(), currency:sum()) ->
%%                   {ok, [Solde_date::integer()]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête d'activation sms info
svi_mns1(SRV, SVIKey, Duration, Price) ->
    Req = integer_to_list(Duration) ++ " " ++
	case currency:currency(Price) of
	    frf ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " F";
	    euro ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " E";
	    _ ->
		EuroPrice=currency:to_euro(Price),
		integer_to_list(round(currency:round_value(EuroPrice)*1000))
		    ++ " E"
	end,
    svi_request(SRV, "MNS1", SVIKey, Req, [{ok, "00 %d %x %s"}, 
					   {status, "%02d"}]).

%% +type svi_mns2(atom(), msisdn(), Rubrique::integer(), currency:sum()) ->
%%%%         {ok, [IdRub::integer(),SoldeM::integer(),DateFin::string(),
%%%%               Dev::string()]} |
%%       {status, [Code::integer()]}.
%%%% Requête d'activation sms info
svi_mns2(SRV, {Sub,Msisdn}, Rubrique, Price) ->
    Req = integer_to_list(Rubrique) ++ " " ++
	integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " E",

    svi_request(SRV, "MNS2", {Sub,{msisdn,Msisdn}}, Req, 
		[{ok, "00 %d %d %x %d"}, 
		 {status, "%02d"}]).
%% +type svi_mnp1(atom(), svi_key(), Duration::integer(), currency:sum()) ->
%%                   {ok, [Solde_date::integer()]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête de prolongation sms info
svi_mnp1(SRV, SVIKey, Duration, Price) ->
    Req = integer_to_list(Duration) ++ " " ++
	case currency:currency(Price) of
	    frf ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " F";
	    euro ->
		integer_to_list(round(currency:round_value(Price)*1000)) ++
		    " E";
	    _ ->
		EuroPrice=currency:to_euro(Price),
		integer_to_list(round(currency:round_value(EuroPrice)*1000))
		    ++ " E"
	end,
    svi_request(SRV, "MNP1", SVIKey, Req, [{ok, "00 %d %x %s"}, 
					   {status, "%02d"}]).

    
%% +type svi_mnr1(atom(), svi_key()) ->
%%                   {ok, [Empty]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête de résiliation SMS Info
svi_mnr1(SRV, SVIKey) ->
    svi_request(SRV, "MNR1", SVIKey, "", [{ok, "00"}, {status, "%02d"}]).

%% +type svi_accesgprs(atom(), svi_key()) ->
%%                   {ok, [Empty]} 
%%                 | {status, [Code::integer()]}.
%%%% Requête de résiliation SMS Info
svi_accesgprs(SRV, SVIKey) ->
    svi_request(SRV, "ACCESGPRS", SVIKey, "", [{ok, "00"}, {status, "%02d"}]).

svi_espadon(SRV,SVIKey,TypeAct,Flag,DateD,HeureD,DateF,HeureF,
	    Cout,TcpN,PtfN,Info_1,Info_2) ->
    TypeAction = case TypeAct of 
		     activation -> "A";
		     modification -> "M";
		     suppression -> "S"
		 end,
    TopFlag  = case Flag of default -> "18" ; _ -> Flag end,
    DateDeb  = case DateD  of default -> "-"; _ -> DateD end,
    HeureDeb = case HeureD of default -> "-"; _ -> HeureD end,
    DateFin  = case DateF of 
		   default ->
		       {Y,M,D} = next_monday_date(),
		       pbutil:sprintf("%02d/%02d/%04d",[D,M,Y]);
		   _ ->
		       DateF
	       end,
    HeureFin  = case HeureF  of default -> "00:00:00"; _ -> HeureF end,
    CoutOpt   = case Cout    of gratuit -> "0";  payant -> "10000" end,
    PtfNum    = case PtfN    of default -> "0"; _ -> PtfN  end,
    TcpNum    = case TcpN    of default -> "0"; _ -> TcpN  end,
    OptInfo_1 = case Info_1  of default -> "-"; _ -> Info_1 end,
    OptInfo_2 = case Info_2  of default -> "-"; _ -> Info_2 end,
    
    Req = TypeAction++" "++TopFlag++" "++DateDeb++" "++HeureDeb++" "++
	DateFin++" "++HeureFin++" "++CoutOpt++" "++TcpNum++" "++PtfNum++" "++
	OptInfo_1++" "++OptInfo_2,
    ResponseFormat = [{operation_effectuee,"0"},
		      {msisdn_inconnu,"10"},
		      {date_incorrecte,"94"},
		      {solde_insuffisant,"95"},
		      {option_inexistante,"96"},
		      {option_deja_existante,"93"},
		      {top_flag_incorrest,"98"},
		      {erreur_99,"99"}
		     ],
    svi_request(SRV, "OPT_ESPADON", SVIKey, lists:flatten(Req), ResponseFormat).

%% +type svi_cpt(atom(),svi_key(),opt_cpt_request()) -> {atom(),string()}.
svi_cpt(SRV,SVIKey,Req) when record(Req,opt_cpt_request) ->
    
    #opt_cpt_request{type_action=Action,
		     top_num=TopNum,
		     date_deb=DateDeb,
		     heure_deb=HeureDeb,
		     date_fin=DateFin,
		     heure_fin=HeureFin,
		     cout=Cout,
		     tcp_num=TcpNum,
		     ptf_num=PtfNum,
		     info1=Info_1,
		     info2=Info_2,
		     mnt_initial=MntInitial,
		     rnv_num=RnvNum,
		     msisdn1=Msisdn_1,
		     msisdn2=Msisdn_2,
		     msisdn3=Msisdn_3,
		     msisdn4=Msisdn_4,
		     msisdn5=Msisdn_5}=Req,

    Request = Action++" "++TopNum++" "++DateDeb++" "++HeureDeb++" "++
	DateFin++" "++HeureFin++" "++Cout++" "++TcpNum++" "++PtfNum++
	" "++Info_1++" "++Info_2++" "++MntInitial++" "++RnvNum++" "++
	Msisdn_1++ " "++Msisdn_2++" "++Msisdn_3++" "++Msisdn_4++" "++Msisdn_5,

    ResponseFormat = [{opt_bloquee_101,"101"},
		      {nok_msisdn_inconnu,"10"},
		      {ok_operation_effectuee,"0"},
		      {ok_operation_effectuee,"1"},
		      {nok_num_not_Orange,"87"},
		      {nok_ptf_num,"91"},
		      {nok_rnv_num,"92"},
		      {nok_opt_deja_existante,"93"},
		      {nok_solde_insuffisant,"95"},
		      {nok_opt_inexistante,"96"},
		      {erreur_99,"99"}],
    svi_request(SRV,"OPT_CPT",SVIKey,Request,ResponseFormat).
  
%% +type svi_cpt2(atom(),svi_key(),opt_cpt_request()) -> {atom(),string()}.
svi_cpt2(SRV,SVIKey,Req) when record(Req,opt_cpt_request) ->
    
    #opt_cpt_request{type_action=Action,
		      top_num=TopNum,
		      date_deb=DateDeb,
		      heure_deb=HeureDeb,
		      date_fin=DateFin,
		      heure_fin=HeureFin,
		      cout=Cout,
		      tcp_num=TcpNum,
		      ptf_num=PtfNum,
		      info1=Info_1,
		      info2=Info_2,
		      mnt_initial=MntInitial,
		      rnv_num=RnvNum,
		      msisdn1=Msisdn_1,
		      msisdn2=Msisdn_2,
		      msisdn3=Msisdn_3,
		      msisdn4=Msisdn_4,
		      msisdn5=Msisdn_5,
		      msisdn6=Msisdn_6,
		      msisdn7=Msisdn_7,
		      msisdn8=Msisdn_8,
		      msisdn9=Msisdn_9,
		      msisdn10=Msisdn_10}=Req,
    
%%     Msisdn_6="0",
%%     Msisdn_7="0",
%%     Msisdn_8="0",
%%     Msisdn_9="0",
%%     Msisdn_10="0",
    
    Request = Action++" "++TopNum++" "++DateDeb++" "++HeureDeb++" "++
	DateFin++" "++HeureFin++" "++Cout++" "++TcpNum++" "++PtfNum++
	" "++Info_1++" "++Info_2++" "++MntInitial++" "++RnvNum++" "++
	Msisdn_1++ " "++Msisdn_2++" "++Msisdn_3++" "++Msisdn_4++" "++Msisdn_5++" "++
	Msisdn_6++ " "++Msisdn_7++" "++Msisdn_8++" "++Msisdn_9++" "++Msisdn_10,

    ResponseFormat = [{opt_bloquee_101,"101 %d %d"},
		      {nok_msisdn_inconnu,"10 %d %d"},
		      {ok_operation_effectuee,"0 %d %d"},
		      {nok_num_not_Orange,"87 %d %d"},
		      {nok_opt_incompatible, "90 %d %d"},
		      {nok_ptf_num,"91 %d %d"},
		      {nok_rnv_num,"92 %d %d"},
		      {nok_opt_deja_existante,"93 %d %d"},
		      {nok_solde_insuffisant,"95 %d %d"},
		      {nok_opt_inexistante,"96 %d %d"},
		      {erreur_99,"99 %d %d"}],
    svi_request(SRV,"OPT_CPT2",SVIKey,Request,ResponseFormat).


%% +type svi_cpt2(atom(),svi_key(),opt_cpt_request()) -> {atom(),string()}.
svi_nopt_cpt(SRV,SVIKey,Req)->
    NB_OPTIONS=integer_to_list(length(Req)),
    LISTE_OPTIONS=nop_cpt_get_liste_option(Req,[]),
    ACTION=nop_cpt_get_action(Req),
    Request=ACTION++" "++NB_OPTIONS++" "++LISTE_OPTIONS,
    ResponseFormat = [{opt_dependante_manquante,"105 %d %d %d"},
		      {opt_bloquee_101,"101 %d %d %d"},
		      {nok_msisdn_inconnu,"10 %d %d %d"},
		      {ok_operation_effectuee,"0 %d %d 0"},
		      {nok_num_not_Orange,"87 %d %d %d"},
		      {nok_opt_incompatible, "90 %d %d %d"},
		      {nok_ptf_num,"91 %d %d %d"},
		      {nok_rnv_num,"92 %d %d %d"},
		      {nok_opt_deja_existante,"93 %d %d %d"},
		      {nok_solde_insuffisant,"95 %d %d %d"},
		      {nok_opt_inexistante,"96 %d %d %d"},
		      {erreur_99,"99 %d %d %d"}],
    svi_request(SRV,"NOPT_CPT",SVIKey,Request,ResponseFormat).


nop_cpt_get_action([Opt1|Req]) when record(Opt1,opt_cpt_request) ->
    #opt_cpt_request{type_action=Action
		  }=Opt1,
    Action.

nop_cpt_get_liste_option([],List)->
    List;

nop_cpt_get_liste_option([Opt1|Req],[]) when record(Opt1,opt_cpt_request) ->
    #opt_cpt_request{type_action=Action,
		     top_num=TopNum,
		     date_deb=DateDeb,
		     heure_deb=HeureDeb,
		     date_fin=DateFin,
		     heure_fin=HeureFin,
		     cout=Cout,
		     tcp_num=TcpNum,
		     ptf_num=PtfNum,
		     info1=Info_1,
		     info2=Info_2,
		     mnt_initial=MntInitial,
		     rnv_num=RnvNum,
		     msisdn1=Msisdn_1,
		     msisdn2=Msisdn_2,
		     msisdn3=Msisdn_3,
		     msisdn4=Msisdn_4,
		     msisdn5=Msisdn_5}=Opt1,
    
    Acc=TopNum++";"++DateDeb++";"++HeureDeb++";"++DateFin++";"++HeureFin++";"++Cout,
    nop_cpt_get_liste_option(Req,Acc);

nop_cpt_get_liste_option([Opt1|Req],List) when record(Opt1,opt_cpt_request) ->
    #opt_cpt_request{type_action=Action,
		     top_num=TopNum,
		     date_deb=DateDeb,
		     heure_deb=HeureDeb,
		     date_fin=DateFin,
		     heure_fin=HeureFin,
		     cout=Cout,
		     tcp_num=TcpNum,
		     ptf_num=PtfNum,
		     info1=Info_1,
		     info2=Info_2,
		     mnt_initial=MntInitial,
		     rnv_num=RnvNum,
		     msisdn1=Msisdn_1,
		     msisdn2=Msisdn_2,
		     msisdn3=Msisdn_3,
		     msisdn4=Msisdn_4,
		     msisdn5=Msisdn_5}=Opt1,
    
    Acc=TopNum++";"++DateDeb++";"++HeureDeb++";"++DateFin++";"++HeureFin++";"++Cout,
    nop_cpt_get_liste_option(Req,Acc++"|"++List).


%% +deftype error_svi_c_op()= erreur_99 | nok_opt_inexistante | nok_opt_not_activated | 
%%                            nok_msisdn_inexistant.

%% +type svi_c_op(pid(), svi_key(),TOP_NUM::string()) -> 
%%                   {ok, DATE_SOUSCR::integer(), DATE_DEB::integer(),
%%                        DATE_FIN::integer()}
%%                 | {options, [integer()]}
%%                 | {error_svi_c_op(),string()}.
%%%% outputs the list of top_num if TOP_NUM=NULL
%%%% or 00+infos of option if TOP_NUM is corresponding to an active option

svi_c_op(SRV, {_,MSISDN}=SVIKey, Top_num_string)
  when is_list(Top_num_string)->
    C_OP2 = svi_c_op2(SRV, {_,MSISDN}=SVIKey, "1", MSISDN, Top_num_string), 
    case C_OP2 of
	%%empty zone_70 (no related options)
	{ok_operation_effectuee,[[], _, _]}-> 
	    slog:event(trace, ?MODULE, svi_c_op, C_OP2),
	    [];
	{ok_operation_effectuee,[Zones_70, _, _]}->
	    case Top_num_string of
		%%Require the list of top_num for the client
		"NULL" ->
		    {options, get_top_nums_from_z70(Zones_70)}; 
		%%Require information about one option with top num Top_num_string
		%%is supposed to be one zone 70 for one option
		_ ->
		    {ok, get_c_op_from_c_op2(Zones_70)} 
	    end;
	Else -> 
	    slog:event(warning, ?MODULE, bad_response_svi_c_op, Else),
	    Else
    end.

%% +type svi_c_op2(pid(), svi_key(), Criteria_type::string(), 
%%                 Criteria_value::string(), TOP_NUM::string()) -> 
%%                   {ok, DATE_SOUSCR::integer(), DATE_DEB::integer(),
%%                        DATE_FIN::integer()}
%%                 | {options, [integer()]}
%%                 | {error_svi_c_op(),string()}.
%%%% C_OP2 TYPE_CRITERE VALEUR_CRITERE TOP_NUM
%%%% C_OP2NUMERO STATYT ZONE_70 ZONE_70 ... ZONe_80 ZONE_80 ... ZONE_90
%%%% Consultation detaillee des options d'un dossier
%%%% outputs the list of top_num if TOP_NUM=NULL
%%%% or 00+infos of option if TOP_NUM is corresponding to an active option
%%%% svi_c_op2({svc_util_of:get_souscription(Session),MSISDN},"1",MSISDN, TOP_NUM)
svi_c_op2(SRV, {_,MSISDN}=SVIKey, Criteria_type, Criteria_value, TOP_NUM) 
  when is_integer(TOP_NUM)->
    TOP_NUM_STRING = integer_to_list(TOP_NUM),
    svi_c_op2(SRV, {_,MSISDN}=SVIKey, Criteria_type, Criteria_value, TOP_NUM_STRING);
svi_c_op2(SRV, {_,MSISDN}=SVIKey, Criteria_type, Criteria_value, TOP_NUM_STRING) 
  when is_list(TOP_NUM_STRING)->
    Request =  Criteria_type ++ " " ++ intl_to_nat(Criteria_value) ++ " "  ++ TOP_NUM_STRING,
    ResponseFormat = [{ok_operation_effectuee, 
		       [{prefix,"00"}]++
		       [{z70, ?MAX_NB_OPTIONS}]++
		       [{z80, ?MAX_NB_MSISDN_OPTIONS}]++
		       [{z90, ?MAX_NB_OPTIONS_TARIF_DEGRS}]},
		      {ok_operation_effectuee, 
		       [{prefix,"0"}]++
		       [{z70, ?MAX_NB_OPTIONS}]++
		       [{z80, ?MAX_NB_MSISDN_OPTIONS}]++
		       [{z90, ?MAX_NB_OPTIONS_TARIF_DEGRS}]},
 		      {nok_msisdn_inconnu,"10"},
 		      {nok_opt_inexistante_parametr,"95"},
 		      {nok_opt_inexistante_dossier,"96"},
 		      {nok_critere_inconnu,"97"},
 		      {nok_trame_inconnue,"98"},
 		      {erreur_technique_99,"99"}
		     ],      
    Res=svi_request(SRV, "C_OP2", SVIKey, Request,ResponseFormat).

%% +type svi_ntrd(atom(),svi_key(), string(), string()) -> {atom(), string()}.
%%%% "Transfert de credit inter dossier"
svi_ntrd(SRV, SVIKey, Receiver, Transfer_ID) ->
    Request = Receiver ++ " " ++ Transfer_ID,
    ResponseFormat = [{ok_operation_effectuee,"%d %d %d %d %d %d 0"},
		      {nok_emetteur_inexistant,"%d %d %d %d %d %d 10"},
		      {nok_solde_insuffisant,"%d %d %d %d %d %d 12"},
		      {nok_cpt_principal_inactif,"%d %d %d %d %d %d 34"},
		      {nok_recepteur_errone,"%d %d %d %d %d %d 35"},
		      {nok_transfer_inexistant,"%d %d %d %d %d %d 36"},
		      {nok_recepteur_est_emetteur,"%d %d %d %d %d %d 37"},
		      {nok_req_incorrect,"%d %d %d %d %d %d 98"},
		      {nok_incident_tech,"%d %d %d %d %d %d 99"},
		      {}
		     ],
    svi_request(SRV, "NTRD", SVIKey, Request, ResponseFormat).

%% +type c_tck(atom(),svi_key(), string(), string()) -> {atom(), string()}.
%%%% "Transfert de credit inter dossier"
c_tck(SRV, {CmoMobi, Msisdn}=SVIKey, C_Tck_key_type, C_Tck_key_value) ->
    Prefix = "C_TCK",
    %%Q: C_TCK TYPE_CLE VALEUR_CLE MSISDN    
    Msisdn1 = 
	case C_Tck_key_type of
	    "1" ->
		"0";
	    "2" ->
		Msisdn
	end,
    Request =  C_Tck_key_type ++ " " ++ C_Tck_key_value ++ " " ++ Msisdn1,
    %%R: C_TCKVALEUR_CLE STATUT TTK_NUM CTK_NUM ETT_NUM TCK_NSCR TCK_NE TCK_DATE_LIMITE 
    %%   TCK_DATE_ETAT UTL_DATE UTL_DOSSIER OFR_NUM
    ResponseFormat = [{ok,                 "%d 00 %d %d %d %d %d %x %x %x %d %d"},
		      {ko_ticket_inconnu,  "%d 11 %d %d %d %d %d %x %x %x %d %d"},
		      {ko_format_incorrect,"%d 10 %d %d %d %d %d %x %x %x %d %d"},
		      {ko_pb_technique,    "%d 99"},
		      {ko_pb_technique_avec_info,"%d 99 %d %d %d %d %d %x %x %x %d %d"},
		      {}], 
    svi_request(SRV, Prefix, SVIKey, Request, ResponseFormat).

%%%% Obsolete if we suppress the use of c_op !
%% +type decode_top_num_list([integer()])-> TOP_NUM::[integer()].
decode_top_num_list([F1,F2,F3,F4,F5,F6,F7,F8])->
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
		      end end,[],lists:seq(0,NO_BIT)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type svi_request(pid(), Code::string(), Key::string(), Args::string(), 
%%                   response_format()) -> [term()].
%%%% Selects a server, sends the request, parses the response.
svi_request(SRV, ReqCode, Key, Args, ResponseFormat) ->
    slog:event(interface, ?MODULE, svi_request, {SRV, ReqCode, Key}),
    case catch svi_do_request(SRV, ReqCode, Key, Args, ResponseFormat) of
	{'EXIT', E} -> 
	    slog:event(failure,?MODULE, svi_response_ko, E),
	    {error, E};
	Res -> Res
    end.

%% +type svi_do_request(pid(), Code::string(), Key::string(), Args::string(), 
%%                   response_format()) -> [term()].
svi_do_request(SRV, ReqCode, Key, Args, ResponseFormat) ->
    %% For all SVI requests, Key is a MSISDN in international format.
    %% The SDP expects a national number.
    {Attr, SDPKey} =
	case Key of
	    {MobiCMO, Msisdn} when list(Msisdn) ->
		%% This is the default used by most SVI requests.
		{[MobiCMO,msisdn|Msisdn], intl_to_nat(Msisdn)};
	    {MobiCMO, {imsi,Imsi}} ->
		%% For svi_cl only.
		{[MobiCMO,imsi|Imsi], Imsi};
	    {MobiCMO, {msisdn,Msisdn}} ->
		%% For svi_cl only.
		{[MobiCMO,msisdn|Msisdn], intl_to_nat(Msisdn)}
	end,
    %% Format the SDP request.
    Request = case Args of
		  "" -> [ReqCode, $ , SDPKey];
		  _  -> 
		      case ReqCode of
			  "C_TCK" -> [ReqCode, $ , Args];
			  "C_OP2" -> [ReqCode, $ , Args];
			  _       -> [ReqCode, $ , SDPKey, $ , Args]
		      end
	      end,
    %%io:format("SDP>~s~n",[Request]),
    %% sdp_server needs a response prefix.
    ResponsePrefix_1 = ReqCode ++ SDPKey ++ " ",
    ResponsePrefix_2 = ReqCode++"1"++SDPKey++ " ",
    ResponsePrefix =
	case ReqCode of
	    "NTRD"  -> ReqCode ++ " ";
	    "C_TCK" -> ReqCode ;
	    _    -> ResponsePrefix_1
	end,
    %% Twice the SDP server's timeout (covers erlang overhead).
    Timeout = pbutil:get_env(pfront_orangef, sdp_response_timeout) * 2,
    GSReq = {sdp_request, Attr, Request, ResponsePrefix, ResponsePrefix_2},
    {S, Line} = gen_server:call(SRV, GSReq, Timeout),
    %%io:format("S = ~p Line~p~n",[S,Line]),
    slog:event(interface,?MODULE, svi_response_ok, Line),
    %% Now check whether the reply matches one of the expected formats.
    case S of
	ok->
	    check_response_svi(ResponsePrefix, Line, ResponseFormat);
	
	ok2->
	    check_response_svi(ResponsePrefix_2, Line, ResponseFormat);
	E ->
	    E
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intl_to_nat("+33"++MSISDN)   -> "0"++MSISDN;
intl_to_nat("+99"++MSISDN)   -> "9"++MSISDN;
intl_to_nat(("+"++_)=MSISDN) -> exit({expected_coutry_33, MSISDN});
intl_to_nat(("0"++_)=MSISDN) -> MSISDN;
intl_to_nat(MSISDN)          -> exit({expected_international_isdn, MSISDN}).

%% +type check_response_svi(Prefix::string(), Line::string(),
%%                          response_format()) -> {Tag::atom(), [term()]}.
%%%% Finds a clause in the response format that matches the line.

check_response_svi(Prefix, Response, []) ->
    exit({bad_svi_response, Response});
%% partial decoding
check_response_svi(Prefix, Response, [{partial, {Tag, Format}}| TL]) ->
    case catch pbutil:sscanf(Prefix++Format, Response) of
	{'EXIT', _}        -> check_response_svi(Prefix, Response, TL);
	{Attributes, _}   -> {Tag, Attributes} 
    end;
check_response_svi(Prefix, Response, [{Tag, [{Type,Format}|TL1]} | TL2]) ->
    case catch check_complex_svi_response(Response,
					  [{prefix,Prefix}|
					   [{Type, Format}|TL1]], []) of
	{'EXIT', Reason} -> 
	    check_response_svi(Prefix, Response, TL2);
	{Attributes, ""} -> 
	    {Tag, Attributes};
	{Attributes, Rest} ->
	    slog:event(warning, ?MODULE, unexpected_sdp_response,
		       {{attributes_ok, Attributes},
			{extra_attributes, Rest}}),
	    exit({extra_attributes, Response})
    end;
check_response_svi(Prefix, Response, [{Tag, Format} | TL]) ->
    case catch pbutil:sscanf(Prefix++Format, Response) of
	{'EXIT', _}        -> check_response_svi(Prefix, Response, TL);
	{Attributes, ""}   -> {Tag, Attributes};
	{Attributes, Rest} -> 
	    slog:event(warning, ?MODULE, unexpected_sdp_response,
		       {{attributes_ok, Attributes},
			{extra_attributes, Rest}}),
	    exit({extra_attributes, Response})
    end;
check_response_svi(Prefix, Response, Else) ->
    slog:event(warning, ?MODULE, unexpected_sdp_response,{Prefix, Response, Else}), 
    exit({bad_svi_response_format, Response}).

%% +type check_complex_svi_response(Line::string(), response_format(),string()) -> 
%%                                         {[term()], Rest::string()}.
%%%% Tries to match complex svi response format
check_complex_svi_response(Rest, "", Acc) ->
    {lists:reverse(Acc), Rest};
check_complex_svi_response(Response, [{prefix, Prefix}|TL], Acc) ->
    {Attributes, Rest} = pbutil:sscanf(Prefix, Response),
    check_complex_svi_response(Rest, TL, Attributes++Acc);
%%%% 60 TCP_NUM;UNT_NUM;CPP_SOLDE;DLV;RNV;ECP_NUM;PTF_NUM;CPP_CUMUL;
%%%% PCT:ANCIENNETE;MNT_INIT;TOP_NUM;MONT_BONUS
check_complex_svi_response(Response, [{z60, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 60 %d;%d;%d;%x;%d;%d;%d;%d;%d;%d;%d;%d;%d"),
    check_complex_svi_response(Rest, TL, [Attributes | Acc]);
%%%% 70 TCP_NUM;OPT_DATE_SOUSCRIPTION;OPT_DATE_DEB_VALID;OPT_DATE_FIN_VALID;
%%%% OPT_INFO;OPT_INFO2;PTF_NUM;RNV_NUM;CPP_CUMUL_CREDIT
check_complex_svi_response(Response, [{z70, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 70 %d;%d;%d;%d;%s;%s;%d;%d;%d;%d"),
    check_complex_svi_response(Rest, TL, [Attributes | Acc]);
%%%% 80 MSISDN_MEMBER;OPTL_RANG;MSISDN_TOP_NUM;MSISDN_TCP_NUM;
%%%% MSISDN_PTF_NUM;MSISDN_RNV_NUM
check_complex_svi_response(Response, [{z80, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 80 %s;%d;%d;%d;%d;%d"),
    check_complex_svi_response(Rest, TL, [Attributes | Acc]);
%%%% 90 TOP_NUM;CTG_CPT_CUMUL;UNT_NUM;CTG_DATE_RAZ
check_complex_svi_response(Response, [{z90, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 90 %d;%d;%d;%x"),
    check_complex_svi_response(Rest, TL, [Attributes | Acc]);
%% matches zero or more occurences
check_complex_svi_response(Response, [{repeat, Format}|TL], Acc) ->
    {Attributes, Rest} = check_repeat_svi_response(Response, Format, []),
    check_complex_svi_response(Rest, TL, Attributes++Acc).

%% +type check_repeat_svi_response(Line::string(), response_format(),string()) -> 
%%                                         {[term()], Rest::string()}.
%%%% Tries to match complex svi response format
check_repeat_svi_response(Response, Format, Acc) ->
    case catch pbutil:sscanf(Format, Response) of
	{'EXIT', _} -> 
	    {[lists:reverse(Acc)], Response};
	{Attributes, Rest} ->
	    check_repeat_svi_response(Rest, Format, [Attributes|Acc])
    end.

%% +type check_zone(string(), string(), string, response_format()) -> 
%%                                         {[term()], Rest::string()}.
%%%% Checks that the additional zone is in the good format defined by Format
%%%% Note that the Count is the maximum number of occurance of this zone
%%%% in the response
check_zone_semicolon(Response, 0, Acc, Format) ->
    {lists:reverse(Acc), Response};
check_zone_semicolon("", Count, Acc, Format) ->
    {lists:reverse(Acc), ""};
check_zone_semicolon(" ", Count, Acc, Format) ->
    {lists:reverse(Acc), ""};
check_zone_semicolon(Response, Count, Acc, Format) ->
    case catch check_semicolon_response(Format, Response) of
	{'EXIT', E} -> 
	    {lists:reverse(Acc), Response};
	{Attributes, Rest} ->
	    check_zone_semicolon(Rest, Count-1, [Attributes | Acc], Format)
    end.

check_zone(Response, 0, Acc, Format) ->
    {lists:reverse(Acc), Response};
check_zone("", Count, Acc, Format) ->
    {lists:reverse(Acc), ""};
check_zone(" ", Count, Acc, Format) ->
    {lists:reverse(Acc), ""};
check_zone(Response, Count, Acc, Format) ->
    case catch pbutil:sscanf(Format, Response) of
        {'EXIT', _} ->
            {lists:reverse(Acc), Response};
        {Attributes, Rest} ->
            check_zone(Rest, Count-1, [Attributes | Acc], Format)
    end.

%% +type get_top_nums_from_z70(Zones_70:string()) -> 
%%                                        list().
%%%% Get the top_num values from the Zones 70
get_top_nums_from_z70([]) ->
    [];
get_top_nums_from_z70(Zones_70) 
  when list(Zones_70) ->
    get_top_nums_from_z70(Zones_70,[]).

%% +type get_top_nums_from_z70(string(), list()) -> 
%%                                        list().
%%%% Get the top_num values from the Zones 70
get_top_nums_from_z70([],Result) ->
    Result;
get_top_nums_from_z70([[Top_num|Zone_70_remain]|Zones_70_tail], Result) ->
    get_top_nums_from_z70(Zones_70_tail, [Top_num |Result]).   %% string/integer to be corrected !!! 

%% We assume one Zone_70, otherwise, we neglect the addional zones
get_c_op_from_c_op2(Zone_70) ->
    Zone_70_used = case Zone_70 of
		       [Zone_70_unique] -> 
			   Zone_70_unique;
		       %% we neglect the additional zones 70
		       [Zone_70_1| _] ->   
			   slog:event(warning, ?MODULE, received_multiple_zone_70),
			   Zone_70_1
		   end,   
    case Zone_70_used of  
	[Top_num,Opt_date_souscr,Opt_date_deb_valid,Opt_date_fin_valid,Opt_info1,Opt_info2|Remain] ->	    
	    [Opt_date_souscr,Opt_date_deb_valid,Opt_date_fin_valid,Opt_info1,Opt_info2];
	Else ->
	    slog:event(failure, ?MODULE, unable_to_get_c_op_from_c_op2, [Zone_70]),
	    ko
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Minitel API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FTM01 minitel request
%% +type mtl_ftm01(atom(),crit(), Tranche::integer()) -> Result.
%% +deftype crit() = {msisdn,MSISDN} | {nsce,NSCE} | {imsi,IMSI}.

mtl_ftm01(SRV, Key, Tranche) ->
    slog:event(trace, ?MODULE, mtl_ftm01, Key),
    {TrNum,Zone20} = case Tranche of
			 no_details -> {99, []};
			 _ -> {Tranche, [{zi,20}]}
	    end,
    mtl_request(SRV, "FTM01", Key, integer_to_list(TrNum),
		[{ok, [{prefix,"00"}, {z10,1}] ++ Zone20},
		 {status, [{prefix, "%d"}]}]).

%% FTM21 minitel request
%% +type mtl_ftm21(atom(),crit()) -> Result.

mtl_ftm21(SRV, Key) ->
     slog:event(trace, ?MODULE, mtl_ftm21, Key),
    mtl_request(SRV, "FTM21", Key, "",
		%% une zone 10
		[{ok, [{prefix, "00"}, {z10, 1}]},
		 {status, [{prefix, "%d"}]}]).

%% IDMTL2 minitel request
%% +type mtl_idmtl2(atom(),crit(), Tranche::integer()) -> Result.

mtl_idmtl2(SRV, Key, Tranche) ->
    slog:event(trace, ?MODULE, mtl_idmtl2, Key),
    {TrNum,Zone20} = case Tranche of
			 no_details -> {99, []};
			 _ -> {Tranche, [{zi,20}]}
		     end,
    mtl_request(SRV, "IDMTL2", Key, integer_to_list(TrNum),
		%% une zone 10 bis
		[{ok, [{prefix, "00"}, {z10bis, 1}] ++ Zone20},
		 {status, [{prefix, "%d"}]}]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type mtl_request(pid(), Code::string(), Key::string(), Args::string(), 
%%                   response_format()) -> [term()].
%%%% Selects a server, sends the request, parses the response.
mtl_request(SRV, ReqCode, Key, Args, ResponseFormat) ->
     slog:event(trace, ?MODULE, mtl_request, {SRV, ReqCode, Key,Args}),
    case catch mtl_do_request(SRV, ReqCode, Key, Args, ResponseFormat) of
	{'EXIT', E} -> {error, E};
	Res         -> Res
    end.

%% +type mtl_do_request(pid(), Code::string(), Key::string(), Args::string(), 
%%                   response_format()) -> [term()].
mtl_do_request(SRV, ReqCode, Key, Args, ResponseFormat) ->
    {MobiCMO, {Crit,Id}} = Key,
    SDPKey = case Crit of
		 msisdn -> "1 "++intl_to_nat(Id);
		 nsce -> "2 "++Id;
		 imsi -> "3 "++Id;
		 Else -> exit({bad_key_format, Key})
	     end,
    Attr = [MobiCMO, Crit | Id],
    %% Format the 
    Request = case Args of
		  "" -> [ReqCode, $ , SDPKey];
		  _  -> [ReqCode, $ , SDPKey, $ , Args]
	      end,
     %% Difference with SVI : space after request code
    ResponsePrefix_1 = ReqCode ++ " " ++ SDPKey ++ " ",
    ResponsePrefix_2=ReqCode++SDPKey++" ",
    GSReq = {sdp_request, Attr, Request, ResponsePrefix_1, ResponsePrefix_2},
    T0 = pbutil:unixmtime(),
    %% Twice the SDP server's timeout (covers erlang overhead).
    Timeout = pbutil:get_env(pfront_orangef, sdp_response_timeout) * 2,
    {R, Line} = gen_server:call(SRV, GSReq, Timeout),
    %%io:format("Line=~p~n",[Line]),
    slog:delay(perf, ?MODULE, response_delay, T0),
    %% Now check whether the reply matches one of the expected formats.
    case R of 
	ok->
	    check_response_mtl(ResponsePrefix_1, Line, ResponseFormat);
	ok2-> %% case error 99 for IDMTL2 or 10 for FTM01 sachem
	    check_response_mtl(ResponsePrefix_2, Line, ResponseFormat);
	E ->
	    E
    end.
	    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type check_response_mtl(Prefix::string(), Line::string(),
%%                          response_format()) -> {Tag::atom(), [term()]}.
%%%% Finds a clause in the response format that matches the line.

check_response_mtl(Prefix, Response, []) ->
    exit({bad_mtl_response, Response});
check_response_mtl(Prefix, Response, [{Tag, F}|TL]) ->
    case catch check_response_mtl_format(Response, [{prefix, Prefix}|F], []) of
	{'EXIT', _} -> check_response_mtl(Prefix, Response, TL);
	{Attributes, ""} -> {Tag, Attributes};
	{Attributes, " "} -> {Tag, Attributes};
	{Attributes, Rest} -> 
	    slog:event(warning, ?MODULE, unexpected_sdp_response,
		       {{attributes_ok, Attributes},
			{extra_attributes, Rest}}),
	    exit({extra_attributes, Response})
    end.

check_response_mtl_format(Rest, "", Acc) ->
    {lists:reverse(Acc), Rest};
check_response_mtl_format(Response, [{prefix, Prefix} | TL], Acc) ->
    case check_prefix(Prefix,Response) of
	{"", Rest} ->
	    check_response_mtl_format(Rest, TL, Acc);
	{Attributes, Rest} ->
	    check_response_mtl_format(Rest, TL, [Attributes, Acc])
    end;
check_response_mtl_format(Response, [{z10, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone(Response, Nb, [],
				   " 10 %s %s %s %4s %d %d %d %d %d "++
				   "%2s%2s%2s %2s%2s%2s%2s%2s %2s%2s%2s%2s%2s "++
				   "%d %d %d " ++
				   "%2s%2s%2s%2s%2s"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{z10bis, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone(Response, Nb, [],
				      " 10 %s %s %s %4s %d %d %d %d %d "++
				      "%2s%2s%2s %2s%2s%2s%2s%2s %2s%2s%2s%2s%2s "++
				      "%d %d %d " ++
				      "%2s%2s%2s%2s%2s " ++
				      "%2s%2s%2s%2s%2s %s %s %2s%2s%2s%2s%2s"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{z20, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone(Response, Nb, [], 
				   " 20 %2s%2s%2s %2d%2d %d %s %d %d %d %d"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{z30, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone(Response, Nb, [], 
				    " 30 %d %2s %s %s %s %d %d %d %d"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{z40, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 40 %d;%d;%d;%d;%d;%x;%x;%d;%d;%s;%s;%x;%x"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{z50, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 50 %d;%d;%d;%x;%d;%d;%d;%d"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{z50bis, Nb} | TL], Acc) ->
    {Attributes, Rest} = check_zone_semicolon(Response, Nb, [], 
				    " 50 %d;%d;%d;%x;%d;%d;%d;%d;%d;%d"),
    check_response_mtl_format(Rest, TL, [Attributes | Acc]);
check_response_mtl_format(Response, [{zi, Nb} | TL], Acc) ->
    check_response_mtl_format("","", Acc).

check_prefix(Prefix, Response) ->
    pbutil:sscanf(Prefix, Response).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEW API BASED on TLV FORMAT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A4 request
%% +type tlv_a4(atom(),crit()) -> term().
tlv_a4(SRV, Key) ->
    tlv_request(SRV, "A4", Key,
		[{ok, [{prefix,"%s 00"}, {z40,1}] ++ [{z50bis,40}]},
		 {status, [{prefix, "%d %s %d"}]},
		 {status, [{prefix, " %d %s %d"}]},
		 {status,[{prefix,"%d %d"}]}]).
%% A3 request
%% +type tlv_a3(atom(),crit()) -> term().
tlv_a3(SRV, Key) ->
     tlv_request(SRV, "A3", Key,
		[{ok, [{prefix,"%s 00"}, {z40,1}] ++ [{z50,20}]},
		 {status, [{prefix, "%d %s %d"}]},
		 {status, [{prefix, " %d %s %d"}]},
		 {status,[{prefix,"%d %d"}]}]).

%% +type tlv_request(pid(), Code::string(), Key::string(), response_format())
%% -> [term()].
%%%% Selects a server, sends the request, parses the response.
tlv_request(SRV, ReqCode, Key, ResponseFormat) ->
    slog:event(interface, ?MODULE, tlv_request, {SRV, ReqCode, Key}),
    case catch tlv_do_request(SRV, ReqCode, Key, ResponseFormat) of
	{'EXIT', E} -> 
	    slog:event(failure,?MODULE, tlv_response_ko, E),
	    {error, E}; 
        Res-> 
	    Res
    end.

%% +type tlv_do_request(pid(), Code::string(), Key::string(),
%%                   response_format()) -> [term()].
tlv_do_request(SRV, ReqCode, Key, ResponseFormat) ->
    {MobiCMO, {Crit,Id}} = Key,
    SDPKey = case Crit of
		 msisdn -> "1 "++intl_to_nat(Id);
		 nsce -> "2 "++Id;
		 imsi -> "3 "++Id;
		 Else -> exit({bad_key_format, Key})
	     end,
    Attr = [MobiCMO, Crit | Id],
    %% Format the 
    Request = [ReqCode, $ , SDPKey],
     %% Difference with SVI : space after request code
    ResponsePrefix= ReqCode,
    GSReq = {sdp_request, Attr, Request, ResponsePrefix},
    T0 = pbutil:unixmtime(),
    %% Twice the SDP server's timeout (covers erlang overhead).
    Timeout = pbutil:get_env(pfront_orangef, sdp_response_timeout) * 2,
    {R, Line} = gen_server:call(SRV, GSReq, Timeout),
    %%io:format("Line=~p~n",[Line]),
    slog:event(interface,?MODULE, tlv_response_ok, Line),
    slog:delay(perf, ?MODULE, response_delay, T0),
    %% Now check whether the reply matches one of the expected formats.
    check_response_mtl(ResponsePrefix, Line, ResponseFormat).

check_semicolon_response(Format, Response) ->
    do_check_semicolon_response(Format, Response, []).

do_check_semicolon_response(Format, Response, Acc) ->
    case pbutil:split_at($;, Format) of
	not_found ->
	    %% last item to be matched
	    {Attributes, Rest} = pbutil:sscanf(Format, Response),
	    {Acc++Attributes, Rest};
	{FItem, FormatRest} ->
	    %% this will exit if no ";" found
	    {RespItem, ResponseRest} = pbutil:split_at($;, Response),
	    {Attributes, Rest} = pbutil:sscanf(FItem, RespItem),
	    do_check_semicolon_response(FormatRest, ResponseRest,
					Acc++Attributes)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +deftype item() = { Client::pid(), Prefix::string(), To::unix_mtime() }.

%% +deftype state() = {Port::pid(), queue:queue(item), Nq::integer()}.

-record(state, {port, q, n}).

%% +type init(interface()) -> *.

init(I) ->
    put(interface, I),
    %% init/1 should not block. Therefore we return a special state
    %% with no port yet, and we cause it to timeout immediately.
    {ok, #state{port=connect, q=queue:new(), n=0}, 0}.

connect({x25port, Options, Addr}) ->
    Program = io_lib:format("~s/~s/x25port.out ~s ~s",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr ]),
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({fsx25port, Options, Addr}) ->
    Program = io_lib:format("~s/~s/fsx25port.out ~s ~s",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr ]),
    io:format("Spawning ~s~n", [Program]),
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({tcpport, Options, Addr, Port}) ->
    Program = io_lib:format("~s/~s/tcpport.out ~s ~s ~w",
			    [ code:priv_dir(pgsm), pbutil:arch(),
			      Options, Addr, Port ]),
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({port, Program}) ->
    open_port({spawn, lists:flatten(Program)}, [exit_status]);

connect({erlang_process, Name}) ->
    %% Wait a little (for sdp_fake).
    receive after 2000 -> ok end,
    Pid = pbutil:whereis_name(Name),
    Pid ! {self(), connect},
    receive {Pid, connected} -> Pid
    after 1000 -> exit(timeout_while_connecting)
    end.

check_banner(Banner, Port) ->
    Timeout = pbutil:get_env(pfront_orangef, sdp_connect_timeout),
    %% Note: do not match other messages here.
    receive
	%% Expect either Response or {eol, Response}
	%% (compatible with 'stream' and '{line,_}').
	{Port, {data,{eol,Banner}}} -> ok;
	{Port, {data,Banner}} -> ok;
	{Port, {data,{eol,B}}} -> exit({wrong_banner_from_sdp, B, Banner});
	{Port, {data,B}} -> exit({wrong_banner_from_sdp, B, Banner})
    after Timeout ->
	    exit(timeout_waiting_for_sdp_banner)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% Since the SDP protocol is synchronous, the queue size is 1.
%% Actually it is much better to wait for the reply synchronously,
%% than to return "overloaded" when two simultaneous requests are done.

handle_call({sdp_request, _Attr, Request, Prefix}, Client, State) ->
    slog:event(trace, ?MODULE, handle_call, {Request, Prefix}),
    #state{port=Port} = State,
    pbutil:send_port(Port, Request),
    Timeout = pbutil:get_env(pfront_orangef, sdp_response_timeout),
    Treq = pbutil:unixmtime(),
    %% Expect either Response or {eol, Response}
    %% (compatible with 'stream' and '{line,_}').
    receive
	{Port, {data, {eol, Response}}} ->
	    handle_sync_response(State, Request, Prefix, Response);
	{Port, {data, Response}} ->
	    handle_sync_response(State, Request, Prefix, Response);
	{Port, {exit_status, Status}} ->
	    slog:event(count, ?MODULE, {fsx25_exited_during_request, Status}),
	    exit(sdp_port_exited)
    after Timeout ->   
	    slog:event(trace, ?MODULE, response_timeout, Request),
	    exit(timeout_waiting_for_sdp_reply)
    end;

handle_call({sdp_request, _Attr, Request, Prefix_1, Prefix_2},Client, State) ->
    slog:event(trace, ?MODULE, handle_call),%% {Request, Prefix_1}),
    #state{port=Port} = State,
    pbutil:send_port(Port, Request),
    Timeout = pbutil:get_env(pfront_orangef, sdp_response_timeout),
    Treq = pbutil:unixmtime(),
    %% Expect either Response or {eol, Response}
    %% (compatible with 'stream' and '{line,_}').
    receive
	{Port, {data, {eol, Response}}} ->
	    slog:delay(perf, ?MODULE, port_response_time, Treq),
	    handle_sync_response(State, Request, Prefix_1, Prefix_2, Response);
	{Port, {data, Response}} ->
	    slog:delay(perf, ?MODULE, port_response_time, Treq),
	    handle_sync_response(State, Request, Prefix_1, Prefix_2, Response);
	{Port, {exit_status, Status}} ->
	    slog:event(count, ?MODULE, {fsx25_exited_during_request, Status}),
	    exit(sdp_port_exited)
    after Timeout ->
	    slog:event(trace, ?MODULE, response_timeout, Request),
	    exit(timeout_waiting_for_sdp_reply)
    end.

handle_sync_response(State, Request, Prefix, Response) -> 
    case lists:prefix(Prefix, Response) of
	false ->
	    slog:event(trace, ?MODULE, response_nok,{Request, Response}),
	    exit({sdp_sync, response_order});
	true ->
	    slog:event(trace, ?MODULE, response_ok,{Request, Response}),
	    {reply, {ok, Response}, State}
    end.

handle_sync_response(State, Request, Prefix_1, Prefix_2, Response) ->
    case {lists:prefix(Prefix_1, Response),lists:prefix(Prefix_2, Response)} of
	  {false,false} ->
	    slog:event(trace, ?MODULE, response_nok, {Request, Response}),
		 exit({sdp_sync, response_order});
	  {false,true} ->
	    slog:event(trace, ?MODULE, reponse_ok, {lists:flatten(Request), Response}),
	    {reply, {ok2, Response}, State};
	  {true,A} ->
	    slog:event(trace, ?MODULE, response_ok, {lists:flatten(Request), Response}),
	    {reply, {ok, Response}, State}
    end.

handle_info(timeout, #state{port=connect}=S) ->
    Config = (get(interface))#interface.extra,
    {Name,_Node} = (get(interface))#interface.name_node,
    slog:event(trace, ?MODULE, {Name,connecting}),
    Port = connect(Config#sdp_config.method),
    check_banner(Config#sdp_config.banner, Port),
    pfront_app:interface_up(Name),
    put(port, Port),
    {noreply, S#state{port=Port}};

handle_info(timeout, #state{q=Q, n=N}=S) ->
    case queue:out(Q) of
	{empty, _} ->
	    {noreply, S};
	{{value,{Client,_,Tmax}}, Q1} ->
	    Timeout = Tmax - pbutil:unixmtime(),
	    case Timeout > 0 of
		false -> gen_server:reply(Client, {error, timeout}),
			 {noreply, S#state{q=Q1, n=N-1}, 0};
		true -> {noreply, S, Timeout}
	    end
    end;

%% The following clauses are now unused: handle_call blocks until the
%% SDP replies.

handle_info({Port, {data, {eol,Response}}}, S) ->
    %% For compatibility between 'stream' and '{line,_}'.
    handle_info({Port, {data, Response}}, S);

handle_info({Port, {data, Response}}, S) ->
    #state{port=Port,q=Q,n=N} = S,
    case queue:out(Q) of
	{empty, _} ->
	    slog:event(failure,?MODULE,reponse_wihtout_request,Response),
	    exit(sdp_sync_response_without_request);
	{{value, {Client,Prefix,_}}, Q1} ->
	    case lists:prefix(Prefix, Response) of
		false ->
		    exit({sdp_sync, response_order});
		true ->
		    %%io:format("SDP REPLY: ~p~n", [Response]),
		    gen_server:reply(Client, {ok, Response}),
		    {noreply, S#state{q=Q1, n=N-1}, 0}
	    end
    end;
		  
handle_info({Port, {exit_status, Status}}, S) ->
    slog:event(count, ?MODULE, {fsx25_exited, Status}),
    exit(sdp_port_exited);

handle_info(Msg, S) ->
    pbutil:badmsg(Msg, ?MODULE).

%% +type code_change(Vsn, state(), M) -> {ok, state()}.

code_change(Old, State, Extra) ->
    {ok, State}.

%% +type handle_cast(M, state()) -> {noreply, state()}.

handle_cast(Req, S) ->
    {noreply, S}.


%% +type terminate(R, state()) -> ok.

terminate(Reason, S) ->
    ok.

%% +deftype datetime()={date(), time()}.
%% +deftype date()={Year::integer(), Month::integer(), Day::integer()}.
%% +deftype time()={Hour::integer(), Minute::integer(), Second::integer()}.
%% +type add_time_to_datetime(datetime(),SecToAdd::integer()) -> datetime().
add_time_to_datetime(DateTime, {secs,SecsToAdd}) ->
    Secs=calendar:datetime_to_gregorian_seconds(DateTime)+SecsToAdd,
    calendar:gregorian_seconds_to_datetime(Secs);

add_time_to_datetime(DateTime, {days,DaysToAdd}) ->
    Secs=calendar:datetime_to_gregorian_seconds(DateTime)+DaysToAdd*86400,
    calendar:gregorian_seconds_to_datetime(Secs).

-define(SUNDAY,7). %% en conformité avec calendar.erl

%% +type next_monday_date() -> date().
next_monday_date() ->
    DateTime = {Date,{Hour,_,_}} = calendar:universal_time(),
    %%calendar:now_to_local_time(now()),
    DayOWeek = calendar:day_of_the_week(Date),
    IsItSunday23h = (Hour == 23) and (DayOWeek==?SUNDAY),
    DiffToNextSunday = 8 - DayOWeek,
    {NextMondayDate,_} = 
	case IsItSunday23h of
	    false -> 
		add_time_to_datetime(DateTime,{days,DiffToNextSunday});
	    true  ->
		add_time_to_datetime(DateTime,{days,DiffToNextSunday+7})
	end,
    NextMondayDate.
