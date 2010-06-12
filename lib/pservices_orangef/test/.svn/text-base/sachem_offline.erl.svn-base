-module(sachem_offline).
-export([send_request/3]).

-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/tlv.hrl").
-include("../../pfront_orangef/include/sdp.hrl").
-include("../../pserver/include/pserver.hrl").
-include("sachem.hrl").


%%%% Consult_account
send_request(#session{prof=Prof}=Session, "csl_doscp", Param_list) ->
    io:format("sachem_offline send request csl_doscp~n"),
    {ok, {Session, 
          [{"DOS_DATE_ETAT","1239106988"},
           {"DOS_CUMUL_MOIS","0"},
           {"DOS_MSISDN","0643000581"},
           {"EPR_NUM","2"},
           {"ESC_NUM_LONG","1048583"},
           {"DOS_IMSI","064300058100000"},
           {"DOS_OPTION7","0"},
           {"NB_CPT","2"},
           {"DCL_NUM","0"},
           {"DOS_PLAFOND_REC","0"},
           {"DOS_ABONNEMENT","064300058100"},
           {"DOS_DATE_CREATION","1239095681"},
           {"DOS_CODE_REC","0000"},
           {"LNG_NUM","1"},
           {"DOS_NUMID","315302477"},
           {"KIT_NUM","255"},
           {"DOS_OPTION8","0"},
           {"DOS_NSCE","0643000581000"},
           {"DOS_OPTION3","0"},
           {"DOS_OPTION5","0"},
           {"DOS_OPTION4","0"},
           {"DOS_DATE_DER_REC","1242315255"},
           {"DOS_ERR_REC","0"},
           {"DOS_BON_PCT","0"},
           {"DOS_MONTANT_REC","0"},
           {"DOS_DATE_REC","0"},
           {"DOS_DATE_DEB_FID","0"},
           {"DOS_OPTION","64"},
           {"OFR_NUM","1"},
           {"DOS_IMEI","0000000000000000"},
           {"DOS_DATE_ACTIV","1234001700"},
           {"DOS_OPTION6","0"},
           {"STATUT","0"},
           {"DOS_DATE_LV","1266420662"},
           {"DOS_OPTION2","0"},
           {"CPT_PARAMS",
            [["1",
              "1",
              "1",
              "307",
              "44900",
              "1250350262",
              "1239095681",
              "1242662922",
              "0000000000",
              "65000",
              "0",
              "31",
              "0"],
             ["16",
              "1",
              "1",
              "8",
              "30000",
              "1243889999",
              "1242317577",
              "1242662922",
              "0000000000",
              "0",
              "0",
              "0",
              "0000001"]]}]}};

%%%% Consult_account_options
send_request(Session, "csl_op",    Param_list) ->
    io:format("sachem_offline send request csl_op~n"),
    {ok, {Session,  
          [{"DOS_MSISDN","0630875689"},
           {"DOS_NUMID","318321582"},
           {"NB_OP","5"},
           {"STATUT","0"},
           {"NB_OP_TG","0"},
           {"NB_OCC","1"},
           {"OP_PARAMS",
            [["95",
              "1248213600",
              "1248213600",
              "2147483647",
              "0000000000",
              "S",
              "66",
              "68",
              "50",
              "504"],
             ["166",
              "1251324000",
              "1251324000",
              "2147483647",
              "0000472383",
              "646",
              "0",
              "0",
              "0",
              "0"],
             ["435",
              "0",
              "1220911200",
              "2147483647",
              "0000472382",
              "646",
              "0",
              "0",
              "0",
              "0"],
             ["394",
              "1217196000",
              "1217196000",
              "1219957199",
              "0000000000",
              [],
              "173",
              "172",
              "0",
              "0"],
             ["216",
              "1217196000",
              "1217196000",
              "2147483647",
              "0000000000",
              [],
              "0",
              "0",
              "0",
              "0"]]},
           {"NB_OCC_PARAMS",[["0632731928","1","166","0","0","0"]]}]}};

%%%% update_account_options
send_request(Session, "maj_op",    Param_list) ->
    io:format("sachem_offline send request maj_op~n"),
    {ok, {Session, [{"DOS_NUMID","307688235"},
                    {"CPP_SOLDE","0"},
                    {"OPT_DATE_FIN_VALID","1241557199"},
                    {"STATUT","0"}]}};
%%%% update_account_options
send_request(Session, "maj_nopt",  Param_list) ->
    io:format("sachem_offline send request maj_nopt~n"),
    {ok, {Session,  [{"CPP_SOLDE","44900"},
                     {"MSISDN","0643000581"},
                     {"STATUT","0"},
                     {"TCP_NUM","1"}]}};

%%%% recharge_ticket
send_request(Session, "rec_tck",   Param_list) ->
    io:format("sachem_offline send request rec_tck~n"),
    {ok, {Session,[{"TTK_NUM","94"},
                   {"DOS_DATE_LV","2147483647"},
                   {"CTK_NUM","1"},
                   {"TCK_NSTE","00000000000000"},
                   {"STATUT","0"},
                   {"NB_CPT","1"},
                   {"CPT_PARAMS",
                    [["1","2147483647","20000","1","0","0"]
                    ]
                   }]}};

%%%% consult_recharge_ticket
send_request(Session, "csl_tck",   Param_list) ->
    io:format("sachem_offline send request csl_tck~n"),
    {ok, {Session, 
          [{"TTK_NUM","22"},
           {"TCK_DATE_LIMITE","1356825600"},
           {"TCK_DATE_ETAT","1243934428"},
           {"UTL_DATE","1243682908"},
           {"UTL_DOSSIER","0633443818"},
           {"TCK_NSCR","12499"},
           {"TCK_NE","0"},
           {"OFR_NUM","1"},
           {"CTK_NUM","1"},
           {"ETT_NUM","2"},
           {"STATUT","0"}]
         }};
%%%% change_user_account
send_request(Session, "mod_cp",    Param_list) ->
    io:format("sachem_offline send request mod_cp~n"),
    {ok, {Session, [
                    {"DOS_NUMID", "314834488"},
                    {"CPP_DATE_MODIF","1239794465"},
                    {"STATUT","0"}]}};

%%%% transfer_credit
send_request(Session, "tra_credit", Param_list) ->
    io:format("sachem_offline send request tra_credit~n"),
    {ok, {Session, [
                    {"TCP_NUM",  "1"},
                    {"PTF_NUM",  "307"},
                    {"CPP_SOLDE","54950"},
                    {"TCP_NUM_RECEVEUR","93"},
                    {"PTF_NUM_RECEVEUR","307"},
                    {"CPP_SOLDE_RECEVEUR","5000"},
                    {"STATUT",   "0"}
                   ]}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
extract_zones(Zones) ->
    io:format("extract_zones/1 input~n"),
    {[], Output} = extract_zones(Zones,[]),
%    io:format("extract_zones/1 Ouput:~p~n",[Output]),
    Output.

extract_zones([], Output) ->
%    io:format("extract_zones/2 Ouput:~p~n",[Output]),
    {[], Output};
extract_zones(Zones, Output_1) ->
%    io:format("extract_zone of Zones:~p~n",[Zones]),
    {Zones_remain, Output_2} = 
        case string:left(Zones,3) of
            "40 " -> extract_zone40(Zones, Output_1);
            " 40" -> Zone_40 =  string:substr(Zones, 2), 
                     extract_zone40(Zone_40, Output_1);
            "50 " -> extract_zone50(Zones, Output_1);
            " 50" -> Zone_50 =  string:substr(Zones, 2), 
                     extract_zone50(Zone_50, Output_1)
        end,
    extract_zones(Zones_remain, Output_1 ++ Output_2).

%% extract_zone40([], Zones_output) ->
%%     Zones_output;
extract_zone40(Zones, Zones_output_1) ->

%    {[DECLINAISON,ETAT_PRINCIPAL,ETAT_SECONDAIRE,OPTION,DATE_ACTIVATION,
%      DLV,DATE_DER_REC,LNG_NUM,MALIN,TRIBU,ACCES,DMN] pas complet !
%    Out = pbutil:sscanf("40 %d;%d;%d;%d;%d;%x;%x;%d;%d;%s;%s;%x;%x",
%    lists:flatten(Zones)), par complet !!

%    io:format("extract_zone40 of Zones:~p~n",[Zones]),
    {[DECLINAISON, ETAT_PRINCIPAL, ETAT_SECONDAIRE, OPTION, DATE_ACTIVATION,
      DLV, DATE_DER_REC, LNG_NUM, MALIN, TRIBU], Zones_remain} = 
        pbutil:sscanf("40 %d;%d;%d;%d;%d;%x;%x;%d;%d;%s", lists:flatten(Zones)),
    %% OPTION a gerer
    Soap_output =  [{"LNG_NUM",	LNG_NUM},
                    {"DOS_DATE_LV",	DLV}, %% -1 dans traces Tuxedo
                    {"DOS_DATE_ACTIV",	DATE_ACTIVATION},
                    {"DOS_DATE_DER_REC",	DATE_DER_REC},
                    {"DCL_NUM",	 DECLINAISON},
                    {"EPR_NUM",	 ETAT_PRINCIPAL},
                    {"ESC_NUM_LONG",ETAT_SECONDAIRE},
                    {"DOS_DATE_REC",	DATE_DER_REC} %% "0" dans traces tuxedo
                   ],
    extract_zones(Zones_remain, Zones_output_1 ++ Soap_output).

% "9905000001 00 40 123456;66;2;1;0;4a097844;4a097844;1242134596;0;-;-;0;0 50 1;1;15000;4a317e60;0;1;152;0;0;0").

%% extract_zone50([], Zones_output) ->
%%     Zones_output;
extract_zone50(Zones, Zones_output_1) ->
%    io:format("extract_zone50 of Zones:~p~n Previous zone:~p~n",[Zones, Zones_output_1]),
    {[TCP_NUM, UNT_NUM, CPP_SOLDE, DLV, RNV, ECP_NUM,
      PTF_NUM,CPP_CUMUL_CREDIT,PCT,ANCIENNETE], Zones_remain} 
        = pbutil:sscanf("50 %d;%d;%d;%x;%d;%d;%d;%d;%d;%d", lists:flatten(Zones)),
    Soap_output = [{"CPT_PARAMS", 
                    [[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, DLV,
                   "cpp_date_crea", "cpp_date_modif", "cpp_destination", 
                   CPP_CUMUL_CREDIT, "rnv_num", "type_dlv", "opt_tcp"]]}],        
%    io:format("extract_zone50 soap output:~p~n",[Soap_output]),
%    io:format("extract_zone50 Zones_remain:~p~n",[Zones_remain]),
    extract_zones(Zones_remain, Zones_output_1 ++ Soap_output ).


