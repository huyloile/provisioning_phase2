-module(sachem_online).

-compile(export_all).

-include("../../pserver/include/pserver.hrl").
-include("sachem.hrl").
-include("profile_manager.hrl").
-include("../include/ftmtlv.hrl").

send_request(#session{prof=Profile}=Session, Req_name, Param_list) ->
    slog:event(trace,?MODULE,send_request,[{request_name,Req_name},{param_list,Param_list}]),
    Uid=profile_manager:get_uid({msisdn,Profile#profile.msisdn}),
    case Uid of 
        undefined -> 
            slog:event(trace,?MODULE,{msisdn,profile_uid},{Profile#profile.msisdn,Uid}),
            {nok, {error, exit}};
        _ ->
            Predefined_answers = profile_manager:retrieve_(Uid, ?predefined_answer),
            case Predefined_answers of 
                undefined -> 
                    slog:event(trace,?MODULE,sachem_is_not_init),
                    {nok, {error, exit}};
                _ -> 
                    case proplists:get_value(Req_name, Predefined_answers) of        
                        ok ->
                            Elements=construct_answer(Req_name, Param_list, Uid),
                            slog:event(trace,?MODULE,result,{Req_name,Elements}),
                            Session1=svc_util_of:change_sachem_availability(
                                Session,Req_name,Elements),
                            {ok,{Session1,Elements}};
                        {nok,Reason} -> 
                            {nok, Reason};
                        Reason->
                            {nok, Reason}
                    end
            end
    end.                  


construct_answer(Req_name=?rec_tck, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve_(User_profile_id, {?sachem, Req_name, Element})} || 
            Element <- ["TTK_NUM",
			"DOS_DATE_LV",
                        "TCK_DATE_LIMITE",
                        "TCK_DATE_ETAT",
                        "UTL_DATE",
                        "UTL_DOSSIER",
                        "TCK_NSCR",
                        "TCK_NE",
                        "OFR_NUM",
                        "CTK_NUM",
                        "ETT_NUM",
			"NB_CPT",
			"CPT_PARAMS",
                        "STATUT"]],    
    Data=proplists:get_value("CPT_PARAMS",List_elements),
    Comptes=lists:map(fun([TCP_NUM, Date, CPP_SOLDE, UNIT | T])->#compte{tcp_num=list_to_integer(TCP_NUM), etat=?CETAT_AC, dlv=list_to_integer(Date), unt_num=list_to_integer(UNIT), cpp_solde=list_to_integer(CPP_SOLDE)} end, Data),
    profile_manager:insert_comptes_(User_profile_id,Comptes),
    List_elements;

construct_answer(Req_name=?csl_doscp, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve_(User_profile_id, {?sachem, Req_name, Element})} ||
            Element <- [
			"DOS_DATE_ETAT",
			"DOS_OPTION3",
			"DOS_OPTION5",
			"DOS_CUMUL_MOIS",
			"DOS_MSISDN",
			"EPR_NUM",
			"DOS_IMSI",
			"DOS_OPTION4",
			"ESC_NUM_LONG",
			"DOS_OPTION7",
			"DOS_DATE_DER_REC",
			"DOS_ERR_REC",
			"DOS_BON_PCT",
			"DOS_MONTANT_REC",
			"DOS_DATE_REC",
			"DCL_NUM",
			"DOS_ABONNEMENT",
			"DOS_PLAFOND_REC",
			"DOS_DATE_DEB_FID",
			"DOS_OPTION",
			"DOS_DATE_CREATION",
			"OFR_NUM",
			"DOS_IMEI",
			"DOS_CODE_REC",
			"LNG_NUM",
			"DOS_DATE_ACTIV",
			"DOS_OPTION6",
			"STATUT",
			"DOS_NUMID",
			"DOS_DATE_LV",
			"KIT_NUM",
			"DOS_OPTION8",
			"DOS_NSCE",
			"DOS_OPTION2",
			"NB_CPT",
			"CPT_PARAMS"]],
    List_elements;
construct_answer(Req_name=?csl_op, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve(User_profile_id, {?sachem, Req_name, Element})} || 
            Element <- 
		["DOS_MSISDN",
		 "DOS_NUMID",
		 "NB_OP",
		 "STATUT",
		 "NB_OP_TG",
		 "NB_OCC",
		 "OP_PARAMS",
		 "NB_OCC_PARAMS"]],
    List_elements;
construct_answer(Req_name=?maj_op, Param_list, User_profile_id) ->
    TOP_NUM = proplists:get_value("TOP_NUM",Param_list),
    List_elements =
        [{Element, profile_manager:retrieve(User_profile_id, {?sachem, Req_name, Element})} ||
            Element <- ["DOS_NUMID",
			"CPP_SOLDE",
			"OPT_DATE_SOUSCRIPTION",
			"OPT_DATE_DEB_VALID",
			"OPT_DATE_FIN_VALID",
			"STATUT"]],
    ACTION = proplists:get_value("ACTION",Param_list),
    case ACTION of
	"A"->
	    profile_manager:set_list_options_(User_profile_id,[#option{top_num=list_to_integer(TOP_NUM)}]);
	_->[]
    end,
    List_elements;

construct_answer(Req_name=?maj_nopt, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve(User_profile_id, {?sachem, Req_name, Element})} ||
            Element <- ["CPP_SOLDE",
			"MSISDN",
			"STATUT",
			"TCP_NUM"]],
    OPTIONS = list_options_from_params(Param_list),
    ACTION = proplists:get_value("TYPE_ACTION",Param_list),
    case ACTION of
	"A"->
	    profile_manager:set_list_options_(User_profile_id,OPTIONS);
	_->[]
    end,
    List_elements;
construct_answer(Req_name=?csl_tck, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve(User_profile_id, {?sachem, Req_name, Element})} ||
            Element <- ["TTK_NUM",
			"TCK_DATE_LIMITE",
			"TCK_DATE_ETAT",
			"UTL_DATE",
			"UTL_DOSSIER",
			"TCK_NSCR",
			"TCK_NE",
			"OFR_NUM",
			"CTK_NUM",
			"ETT_NUM",
			"STATUT"]],
    List_elements;
construct_answer(Req_name=?mod_cp, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve(User_profile_id, {?sachem, Req_name, Element})} ||
            Element <- ["DOS_NUMID",
			"CPP_DATE_MODIF",
			"STATUT"
		       ]],
    {ok, List_elements};
construct_answer(Req_name=?tra_credit, Param_list, User_profile_id) ->
    List_elements =
        [{Element, profile_manager:retrieve(User_profile_id, {?sachem, Req_name, Element})} ||
            Element <- [
			"PTF_NUM_RECEVEUR",
			"CPP_SOLDE",
			"TCP_NUM_RECEVEUR",
			"PTF_NUM",
			"CPP_SOLDE_RECEVEUR",
			"TCP_NUM",
			"STATUT"]],
    List_elements.




get_default_data(Uid,Msisdn,Imsi) ->
    %% We define here all default values for a typical Sachem user
    %% DOS_NUMID should be the same in all answers:
    %% Generate dos_numid function of Msisdn number
    Dos_numid = generate_dos_numid(Msisdn),
    [
     {?csl_doscp,
      [{"DOS_DATE_ETAT","1253340653"},
       {"DOS_OPTION3","0"},
       {"DOS_OPTION5","0"},
       {"DOS_CUMUL_MOIS","0"},
       {"DOS_MSISDN", Msisdn}, 
       {"EPR_NUM","2"},
       {"DOS_IMSI", Imsi}, %% check that imsi is a string
       {"DOS_OPTION4","0"},
       {"ESC_NUM_LONG","1"},
       {"DOS_OPTION7","0"},
       {"DOS_DATE_DER_REC","0"},
       {"DOS_ERR_REC","0"},
       {"DOS_BON_PCT","0"},
       {"DOS_MONTANT_REC","0"},
       {"DOS_DATE_REC","0"},
       {"DCL_NUM","1"},
       {"DOS_ABONNEMENT","000000009622"},
       {"DOS_PLAFOND_REC","0"},
       {"DOS_DATE_DEB_FID","0"},
       {"DOS_OPTION","0"},
       {"DOS_DATE_CREATION","1235549111"},
       {"OFR_NUM","1"},
       {"DOS_IMEI","0000000000000000"},
       {"DOS_CODE_REC","0000"},
       {"LNG_NUM","1"},
       {"DOS_DATE_ACTIV","1253271639"},
       {"DOS_OPTION6","0"},
       {"STATUT","0"},
       {"DOS_NUMID",Dos_numid},
       {"DOS_DATE_LV","1271847639"},
       {"KIT_NUM","39"},
       {"DOS_OPTION8","0"},
       {"DOS_NSCE","5916039253507"},
       {"DOS_OPTION2","0"},
       {"NB_CPT","1"}, %% Number of "compte". By default, cpt_num = 1 is active
       {"CPT_PARAMS",[["1","2","1","327","0","1255950039","1235549111","1253632689","0000000000","5000","0","31",[]]]}]},
     {?csl_op,
      [{"DOS_MSISDN",Msisdn},
       {"DOS_NUMID",Dos_numid},
       {"NB_OP","1"},
       {"STATUT","0"},
       {"NB_OP_TG","0"},
       {"NB_OCC","1"},
       {"OP_PARAMS",
	[["216","1217196000","1217196000","2147483647","0000000000",[],"0","0","0","0"]]
       },
       {"NB_OCC_PARAMS",[["0632731928","1","166","0","0","0"]]}]},
     %%        %% Below is an example to see what is the format when an option is
     %%        %% available
     %%        %%        {"OP_PARAMS",
     %%        %%         [["124","1254780000","1254780000","1255467599","0000000000",[],"20","235","0","0"],
     %%        %%          ["126","1254780000","1254780000","1255467599","0000000000",[],"86","235","0","0"],
     %%        %%          ["251","1254780000","1254780000","1255467599","0000000000",[],"207","5","0","0"]]}
     %%       ]},
     {?maj_op,
      [{"DOS_NUMID",Dos_numid},
       {"CPP_SOLDE","3058"},
       {"OPT_DATE_FIN_VALID","1254430799"},
       {"STATUT","0"}]},
     {?maj_nopt,
      [{"CPP_SOLDE","76000"},
       {"MSISDN",Msisdn},
       {"STATUT","0"},
       {"TCP_NUM","1"}]},
     {?csl_tck,
      [{"TTK_NUM","17"},
       {"TCK_DATE_LIMITE","1317413674"},
       {"TCK_DATE_ETAT","1252440923"},
       {"UTL_DATE","0"},
       {"UTL_DOSSIER","0"},
       {"TCK_NSCR","13963970"},
       {"TCK_NE","6"},
       {"OFR_NUM","0"},
       {"CTK_NUM","1"},
       {"ETT_NUM","2"},
       {"STATUT","0"}]},
     {?rec_tck,
      [{"TTK_NUM","17"},
       {"DOS_DATE_LV","1275813730"},     
       {"CTK_NUM","1"},
       {"TCK_NSTE","00000000000000"},
       {"STATUT","0"},
       {"NB_CPT","1"}, %% By defaut recharge is done on cpt_num = 1
       {"CPT_PARAMS",[["1","1259743330","30710","1","0","0"]]}]},
     {?mod_cp,
      [{"DOS_NUMID", Dos_numid},
       {"CPP_DATE_MODIF","1254386497"},
       {"STATUT","0"}]},
     {?tra_credit,
      [{"PTF_NUM_RECEVEUR","2"},
       {"CPP_SOLDE","52214"},
       {"TCP_NUM_RECEVEUR","93"},
       {"PTF_NUM","2"},
       {"CPP_SOLDE_RECEVEUR","5000"},
       {"TCP_NUM","1"},
       {"STATUT","0"}]}     
    ].

generate_dos_numid(Msisdn)->
    Rand=random:uniform(1000000000),
    integer_to_list(Rand).

%%update_data/2
update_data(Sachem_data,[])->
    Sachem_data;

update_data(Sachem_data,[{Field,undefined}|T])->
    update_data(Sachem_data,T);

update_data(Sachem_data,[{Field,Value}|T])->
    New_sachem_data=update_data(Sachem_data,Field,Value),
    update_data(New_sachem_data,T).



%%update_data/3
update_data(Sachem_data,list_options,List) when list(List)->
    List_options=list_options(List),
    update_data(Sachem_data,?csl_op,[{"NB_OP",integer_to_list(length(List))},{"OP_PARAMS",List_options}]);

update_data(Sachem_data,list_comptes,List) when list(List)->    
    List_comptes=list_comptes(List),
    update_data(Sachem_data, ?csl_doscp, [{"NB_CPT",integer_to_list(length(List))},{"CPT_PARAMS",List_comptes}]);

update_data(Sachem_data,dcl,DCL) when integer(DCL)->
    update_data(Sachem_data, ?csl_doscp, [{"DCL_NUM",integer_to_list(DCL)}]);



update_data(Sachem_data,Req_name,Pairs)
  when Req_name==?csl_doscp;Req_name==?csl_op;Req_name==?maj_op;Req_name==?maj_nopt;
       Req_name==?csl_tck;Req_name==?rec_tck;Req_name==?mod_cp;Req_name==?tra_credit ->
    Resp_data=proplists:get_value(Req_name,Sachem_data),
    New_response_data=profile_manager:modify_list_property(Resp_data,Pairs),
    New_sachem_data=proplists:delete(Req_name,Sachem_data)++[{Req_name,New_response_data}];


update_data(Sachem_data,_,_)->
    Sachem_data.

list_options(Option) when record(Option,option)->
    list_options([Option]);

list_options([])->[];

list_options([Option|T]) when record(Option,option)->
    list_options([],[Option|T]).

list_options(OP_PARAMS,[])->
    OP_PARAMS;

list_options(OP_PARAMS,[Option|T]) when record(Option,option)->
    New_params=OP_PARAMS++[option_params(Option)],
    list_options(New_params,T).

option_params(Option) when record(Option,option)->
    TOP_NUM=Option#option.top_num,
    OPT_DATE_SOUSCRIPTION=Option#option.opt_date_souscription,
    OPT_DATE_DEB_VALID=Option#option.opt_date_deb_valid,
    OPT_DATE_FIN_VALID=Option#option.opt_date_fin_valid,
    OPT_INFO1=Option#option.opt_info1,
    OPT_INFO2=Option#option.opt_info2,
    TCP_NUM=Option#option.tcp_num,
    PTF_NUM=Option#option.ptf_num,
    RNV_NUM=Option#option.rnv_num,
    CPP_CUMUL_CREDIT=Option#option.cpp_cumul_credit,
    Pairs=[{top_num,TOP_NUM},{opt_date_souscription,OPT_DATE_SOUSCRIPTION},
	   {opt_date_deb_valid,OPT_DATE_DEB_VALID},{opt_date_fin_valid,OPT_DATE_FIN_VALID},
	   {opt_info1,OPT_INFO1},{opt_info2,OPT_INFO2},{tcp_num,TCP_NUM},{ptf_num,PTF_NUM},
	   {rnv_num,RNV_NUM},{cpp_cumul_credit,CPP_CUMUL_CREDIT}],
    option_params([],Pairs).

option_params(Op_params,[])->
    Op_params;

option_params(Op_params,[{Field,Value}|T])-> 

    [TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
     OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT]=
	case Op_params of
	    []->
		UT=pbutil:unixtime(),
		UT_add_one_day=UT+60*60*24,
		UT_s=integer_to_list(UT),
		UT_add_one_day_s=integer_to_list(UT_add_one_day),
		["1", UT_s, UT_s, UT_add_one_day_s, "0000000000",[],"0","0","0","0"];
	    _->
		Op_params
	end,
    case Value of
	undefined->
	    option_params(Op_params,T);
	_->
	    case Field of
		top_num->
		    New_op_params=[integer_to_list(Value),OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_op_params,T);
		opt_date_souscription->
		    New_date=case is_integer(Value) of
				 false->
				     svc_util_of:local_time_to_unixtime(Value);
				 true->
				     Value
			     end,
		    New_date_s=integer_to_list(New_date),
		    New_OP_PARAMS=[TOP_NUM,New_date_s,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		opt_date_deb_valid->
		    New_date=case is_integer(Value) of
				 false->
				     svc_util_of:local_time_to_unixtime(Value);
				 true->
				     Value
			     end,
		    New_date_s=integer_to_list(New_date),
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,New_date_s,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		opt_date_fin_valid ->
		    New_date=case is_integer(Value) of
				 false->
				     svc_util_of:local_time_to_unixtime(Value);
				 true->
				     Value
			     end,
		    New_date_s=integer_to_list(New_date),
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,New_date_s,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		opt_info1->
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   Value,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		opt_info2->
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,Value,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		tcp_num->
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,integer_to_list(Value),PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		ptf_num->
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,integer_to_list(Value),RNV_NUM,CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		rnv_num->
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,integer_to_list(Value),CPP_CUMUL_CREDIT],
		    option_params(New_OP_PARAMS,T);
		cpp_cumul_credit->
		    New_OP_PARAMS=[TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
				   OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,integer_to_list(Value)],
		    option_params(New_OP_PARAMS,T);
		_ ->
		    option_params(Op_params,T)
	    end
    end.

list_comptes(Compte)when record(Compte,compte)->
    list_comptes([Compte]);

list_comptes([])->[];

list_comptes([Compte|T]) when record(Compte,compte)->
    list_comptes([],[Compte|T]).

list_comptes(CPT_PARAMS,[])->
    CPT_PARAMS;

list_comptes(CPT_PARAMS,[Compte|T]) when record(Compte,compte)->
    New_params=CPT_PARAMS++[compte_params(Compte)],
    list_comptes(New_params,T).

compte_params(Compte)  when record(Compte,compte)->
    TCP_NUM=Compte#compte.tcp_num,
    ECP_NUM=Compte#compte.etat,
    UNT_NUM=Compte#compte.unt_num,
    PTF_NUM=Compte#compte.ptf_num,
    CPP_SOLDE=Compte#compte.cpp_solde,
    CPP_DATE_LV=Compte#compte.dlv,
    CPP_DATE_CREA=Compte#compte.d_crea,
    CPP_DATE_MODIF=Compte#compte.d_modif,
    CPP_DESTINATION=Compte#compte.cpt_dest,
    CPP_CUMUL_CREDIT=Compte#compte.cpp_cumul_credit,
    RNV_NUM=Compte#compte.rnv,
    TYPE_DLV=Compte#compte.dlv_type,
    OPT_TCP=Compte#compte.opt_tcp,
    Pairs=[{tcp_num,TCP_NUM},{ecp_num,ECP_NUM},{unt_num,UNT_NUM},{ptf_num,PTF_NUM},{cpp_solde, CPP_SOLDE},{cpp_date_lv,CPP_DATE_LV},{cpp_date_crea,CPP_DATE_CREA},{cpp_date_modif,CPP_DATE_MODIF},{cpp_destination,CPP_DESTINATION},{cpp_cumul_credit,CPP_CUMUL_CREDIT},{rnv_num,RNV_NUM},{type_dlv,TYPE_DLV},{opt_tcp,OPT_TCP}],
    compte_params([],Pairs).

compte_params(Cpt_params,[])->
    Cpt_params;

compte_params(Cpt_params,[{Field,Value}|T])-> 

    [TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
     CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
     CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP]=
	case Cpt_params of
	    []->
		UT=pbutil:unixtime(),
		UT_add_one_day=UT+60*60*24,
		UT_s=integer_to_list(UT),
		UT_add_one_day_s=integer_to_list(UT_add_one_day),
		["1", "2", "1", "1", "10000", UT_add_one_day_s, UT_s, 
		 UT_add_one_day_s, "0000000000","0", "1", "0", []];
	    _->
		Cpt_params
	end,
    case Value of
	undefined->
	    compte_params(Cpt_params,T);
	_->
	    case Field of
		tcp_num->
		    New_cpt_params=[integer_to_list(Value),ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		ecp_num->
		    New_cpt_params=[TCP_NUM,integer_to_list(Value),UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		unt_num->
		    New_cpt_params=[TCP_NUM, ECP_NUM, integer_to_list(Value), PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		ptf_num ->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, integer_to_list(Value), CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		cpp_solde->
		    New_cpt_params=[TCP_NUM,ECP_NUM,UNT_NUM,PTF_NUM,integer_to_list(Value), CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		cpp_date_lv->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, integer_to_list(Value),
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		cpp_date_crea->
		    New_date=case is_integer(Value) of
				 false->
				     svc_util_of:local_time_to_unixtime(Value);
				 true->Value
			     end,
		    New_date_s=integer_to_list(New_date),
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    New_date_s, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		cpp_date_modif->
		    New_date=case is_integer(Value) of
				 false->
				     svc_util_of:local_time_to_unixtime(Value);
				 true->Value
			     end,
		    New_date_s=integer_to_list(New_date),
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, New_date_s, CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		cpp_destination->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF, Value,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		cpp_cumul_credit->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    integer_to_list(Value), RNV_NUM, TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		rnv_num->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, integer_to_list(Value), TYPE_DLV, OPT_TCP],
		    compte_params(New_cpt_params,T);
		type_dlv->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, integer_to_list(Value), OPT_TCP],
		    compte_params(New_cpt_params,T);
		opt_tcp->
		    New_cpt_params=[TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, Value],
		    compte_params(New_cpt_params,T);
		_ ->
		    compte_params(Cpt_params,T)

	    end
    end.
user_state_params_to_doscp_resp_params({Field,Value})->
    user_state_params_to_doscp_resp_params([{Field,Value}]);

user_state_params_to_doscp_resp_params(Pairs) when list(Pairs)->
    user_state_params_to_doscp_resp_params([],Pairs).

user_state_params_to_doscp_resp_params(Params,[])->
    Params;

user_state_params_to_doscp_resp_params(Params,[{Field,Value}|T])->
    case Field of
	dlv->
	    New_date=case is_integer(Value) of
			 false->
			     svc_util_of:local_time_to_unixtime(Value);
			 true->
			     Value
		     end,
	    New_params=Params++[{"DOS_DATE_LV",integer_to_list(New_date)}],
	    user_state_params_to_doscp_resp_params(New_params,T);
	d_activ->
	    New_date=case is_integer(Value) of
			 false->
			     svc_util_of:local_time_to_unixtime(Value);
			 true->
			     Value
		     end,
	    New_params=Params++[{"DOS_DATE_ACTIV",integer_to_list(New_date)}],
	    user_state_params_to_doscp_resp_params(New_params,T);
        etats_sec->
	    New_params=Params++[{"ESC_NUM_LONG",integer_to_list(Value)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	cpte_princ->
	    New_params=Params++[{"EPR_NUM",integer_to_list(Value)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	nsce->
	    New_params=Params++[{"DOS_NSCE",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	abonn_cmo->
	    New_params=Params++[{"DOS_ABONNEMENT",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	kit_num->	    
	    New_params=Params++[{"KIT_NUM",integer_to_list(Value)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	d_creation->
	    New_date=case is_integer(Value) of
                         false->
                             svc_util_of:local_time_to_unixtime(Value);
                         true->
                             Value
                     end,
            New_params=Params++[{"DOS_DATE_CREATION",integer_to_list(New_date)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	d_chg_etat->
	    New_params=Params++[{"DOS_DATE_ETAT",integer_to_list(Value)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	err_rechg->
	    New_params=Params++[{"DOS_ERR_REC",integer_to_list(Value)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	imei->
	    New_params=Params++[{"DOS_IMEI",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	ofr_num->
	    New_params=Params++[{"OFR_NUM",integer_to_list(Value)}],
            user_state_params_to_doscp_resp_params(New_params,T);
	code_rechg->
	    New_params=Params++[{"DOS_CODE_REC",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	cumul_mois->
	    New_params=Params++[{"DOS_CUMUL_MOIS",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	plaf_rechg->
	    New_params=Params++[{"DOS_PLAFOND_REC",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	mnt_rechg->
	    New_params=Params++[{"DOS_MONTANT_REC",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	d_der_rec_cmo->
	    New_params=Params++[{"DOS_DATE_REC",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	d_deb_fidel->
	    New_params=Params++[{"DOS_DATE_DEB_FID",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	bon_pct_fid->
	    New_params=Params++[{"DOS_BON_PCT",Value}],
            user_state_params_to_doscp_resp_params(New_params,T);
	_->
	    user_state_params_to_doscp_resp_params(Params,T)
    end.

rpc(Mod, Fun, Args) ->
    case rpc:call(possum@localhost, Mod, Fun, Args) of
	{badrpc, X} = Error -> exit(Error);
	X                   -> X
    end.

list_options_from_params([])->[];

list_options_from_params([Item|T])->
    case Item of
	{"TOP_NUM",TOP_NUM}->
	    [#option{top_num=list_to_integer(TOP_NUM)}]++list_options_from_params(T);
	_ -> list_options_from_params(T)
    end.
