-module(profile_manager).
-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("profile_manager.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/include/mipc_vpbx_webserv.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_ets() ->
    case catch ets:info(test_profile,name) of
        test_profile->
	    ets:delete_all_objects(test_profile),
            ok;
	_->
	    spawn(?MODULE, create_ets_table, [])
    end.

create_ets_table() ->
    ets:new(test_profile,[set,public,named_table]),
    receive after infinity -> ok end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%create_default/2: create_default(my_id,"mobi")%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create_default(Uid, Sub)->
    rpc(?MODULE,start_ets,[]),
    rpc_for_test(?MODULE,create_default_,[Uid,Sub,true]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%create_default/3: create_default(my_id,"mobi",true)%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create_default(Uid, Sub, MysqlInsert)->
    rpc(?MODULE,start_ets,[]),
    rpc_for_test(?MODULE,create_default_,[Uid,Sub,MysqlInsert]).

create_default_(Uid, Sub, MysqlInsert)->
    Msisdn=msisdn_by_uid(Uid),
    Imsi=imsi_by_uid(Uid),
    DCL=default_value(dcl,{Sub,undefined}),
    Interfaces=get_interfaces(Sub),
    Profile=#test_profile{
      sub=Sub,
      imsi=Imsi,
      msisdn=Msisdn,
      interfaces=Interfaces,
      dcl=DCL},

    case MysqlInsert of
	true->
	    set_mysql_profile(Profile);
	false->
	    []
    end,
    New_Profile=init_interfaces(Interfaces,Profile),
    insert_profile(Uid,New_Profile),
    case retrieve_(Uid,?msisdn) of
	[] ->nok;
	_ -> 
	    ok
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
create_and_insert_default(Uid, Profile)->
    rpc(?MODULE,start_ets,[]),
    rpc_for_test(?MODULE,create_and_insert_default_,[Uid,Profile]).

create_and_insert_default(Uid, Profile, MysqlInsert)->
    rpc(?MODULE,start_ets,[]),
    rpc_for_test(?MODULE,create_and_insert_default_,[Uid,Profile,MysqlInsert]).

create_and_insert_default_(Uid,Profile) when record(Profile,test_profile)->
	create_and_insert_default_(Uid,Profile,true). 

create_and_insert_default_(Uid,Profile,MysqlInsert) when record(Profile,test_profile)->
    Msisdn= 
	case Profile#test_profile.msisdn of
	    undefined->
		msisdn_by_uid(Uid);
	    _->Profile#test_profile.msisdn
	end,
    Imsi= 
	case Profile#test_profile.imsi of
	    undefined->
		imsi_by_uid(Uid);
	    _->Profile#test_profile.imsi
	end,
    Sub=Profile#test_profile.sub,
    DCL=default_value(dcl,{Sub,Profile#test_profile.dcl}),
    Interfaces=get_interfaces(Sub),

    Profile_init=Profile#test_profile{imsi=Imsi,
				      msisdn=Msisdn,
				      interfaces=Interfaces,
				      dcl=DCL},

    case MysqlInsert of
		true->
	   	 set_mysql_profile(Profile_init);
		false->
	   	 []
    end,
    New_Profile=init_interfaces(Interfaces,Profile_init),
    insert_profile(Uid,New_Profile),
    case retrieve_(Uid,?msisdn) of
	[] ->nok;
	_ -> ok
    end.


default_value(tech_seg_code,Init_value)->
    case Init_value of
        undefined->"12345";
        _->Init_value
    end;

default_value(prepaidFlag,{Sub,Init_value})->
    case Init_value of
       undefined-> 
           ocfrdp_online:prepaid_flag(Sub);
       _->Init_value
    end;

default_value(dcl,{Sub,Init_value})->
    case Init_value of
        undefined-> 
            case Sub of
                "cmo" -> ?ppola;
                "mobi"->?mobi;
                "omer"->?omer;
                "bzh_cmo"->?bzh_cmo;
                "tele2_pp"->?tele2_pp;
                "virgin_comptebloque"->?DCLNUM_VIRGIN_COMPTEBLOQUE1;
                "virgin_prepaid"->?DCLNUM_VIRGIN_PREPAID;
                "carrefour_prepaid"->?DCLNUM_CARREFOUR_PREPAID;
                "carrefour_comptebloq"->?DCLNUM_CARREFOUR_CB1;
                "tele2_comptebloque"->?tele2_cb;
                "ten_comptebloque"->?ten_cb;
                "nrj_comptebloque"->?nrj_cb;
                "nrj_prepaid"->?nrj_pp;
                "monacell_prepaid"->?DCLNUM_MONACELL_PREPAID;
                "monacell_comptebloqu"->?DCLNUM_MONACELL_COMPTEBLOQUE_40MIN;
                "symacom"->?decl_symacom;
                _->undefined
            end;
        _ -> Init_value
    end.

set_mysql_profile(Profile=#test_profile{msisdn=Msisdn,
					imsi=Imsi,
					imei=Imei,
					language=Lang,
					sub=Sub,
					tech_seg_code=Tech_Seg})->
    remove_mysql_profile({"msisdn",Msisdn}),
    remove_mysql_profile({"imsi",Imsi}),
    insert_mysql_profile(Profile).

insert_mysql_profile(#test_profile{msisdn=Msisdn,
				   imsi=Imsi,
				   imei=Imei,
				   language=Lang,
				   sub=Sub})->
    Profile=rpc(db,create_anon,[[{msisdn,Msisdn}, {imsi,Imsi}]]),
    Profile1=rpc(db,unanon_profile,[Profile#profile{imei=Imei,lang=Lang,subscription=Sub}]),
    db:insert_profile(Profile1).


remove_mysql_profile({Field_name, Field_value}) ->
    Cmd="DELETE FROM users WHERE "++Field_name++"=\'" ++ Field_value ++ "\'",
    sql_specific:execute_stmt(Cmd,[],10000).



init_interfaces([],Profile)->
    Profile;

init_interfaces([I|T],Profile)->
    New_Profile=
	case I of
	    sachem->
		init_sachem(Profile);
	    spider ->
		init_spider(Profile);
	    asmetier ->
		init_asmetier(Profile);
            mipc_vpbx->
                init_mipc_vpbx(Profile);
	    ocfrdp ->
		init_ocfrdp(Profile)
	end,
    init_interfaces(T,New_Profile).


init_sachem(Profile=#test_profile{msisdn=Msisdn,
				  sub=Sub,
				  imsi=Imsi,
				  options=List_options,
				  comptes=List_comptes,
				  dcl=DCL})->
    Uid=get_uid({msisdn,Msisdn}),
    Sachem_data=sachem_online:get_default_data(Uid,Msisdn,Imsi),
    Pairs=[{list_comptes,List_comptes},{list_options,List_options},{dcl,DCL}],
    New_sachem_data=sachem_online:update_data(Sachem_data,Pairs),
    New_Profile=Profile#test_profile{sachem_data=New_sachem_data,predefined_answer=?PREDEFINED_ANSWER}.

init_spider(Profile=#test_profile{
	      msisdn=Msisdn,
	      sub=Sub,
	      imsi=Imsi,
	      dcl=Dcl})->
    case Sub of
	X when X=="dme";X=="postpaid";X=="opim";X=="enterprise"->
	    Spider=spider_online:build_spider(Msisdn,Imsi,Sub,"1"),
	    Profile#test_profile{spider_data=Spider};
	_->
	    Spider=spider_online:build_spider(Msisdn,Imsi,Sub,integer_to_list(Dcl)),
	    Profile#test_profile{spider_data=Spider}
    end.

init_mipc_vpbx(Profile=#test_profile{
	      msisdn=Msisdn})->
    Mipc=mipc_vpbx_online:default_data("mipc", Msisdn),
    Vpbx=mipc_vpbx_online:default_data("vpbx", Msisdn),
    Profile#test_profile{mipc_data=Mipc,vpbx_data=Vpbx}.

init_asmetier(Profile=#test_profile{msisdn=Msisdn})->
    Asmetier_data=asmetier_online:get_default_data(Msisdn),
    Profile#test_profile{asmetier_data=Asmetier_data}.

init_ocfrdp(Init_profile=#test_profile{tac=Tac,
				  ussd_level=Ussd_level,
				  sub=Sub,
				  imsi=Imsi,
				  msisdn=Msisdn,
                               prepaidFlag=PrepaidFlag,
				  tech_seg_code=Tech_Seg_co,
				  ocf_options=Ocf_options})->
    New_tech_seg_code=default_value(tech_seg_code,Tech_Seg_co),
    New_PrepaidFlag=default_value(prepaidFlag,{Sub,PrepaidFlag}), 
    Profile=Init_profile#test_profile{prepaidFlag=New_PrepaidFlag,tech_seg_code=New_tech_seg_code},
    Requests=['OrangeAPI.subscribeByMsisdn',
              'OrangeAPI.subscribeByImsi',
              'OrangeAPI.unSubscribeByImsi',
              'OrangeAPI.unSubscribeByMsisdn',
              'OrangeAPI.getUserInformationByImsi',
	      'OrangeAPI.getUserInformationByMsisdn',
              'OrangeAPI.getSubscriptionInformationByMsisdn',
              'OrangeAPI.getSubscriptionInformationByImsi',
              'OrangeAPI.getOptionalServicesByMsisdn',
              'OrangeAPI.isMsisdnOrange'
             ],
    Data=lists:append([ocfrdp_online:default_response(R, Profile)||R <- Requests]),
    Profile#test_profile{ocfrdp_data=Data}.


generate_msisdn()->
    {A, B, C} = erlang:now(),
    random:seed(A, B,C),
    Rand=random:uniform(1000),
    Rand_s=
    case Rand of
	X when X<10->"00"++integer_to_list(Rand);
	X when X<100->"0"++integer_to_list(Rand);
	_->integer_to_list(Rand)
    end,
    Msisdn="+33900000"++Rand_s,
	case get_uid({msisdn,Msisdn}) of
		undefined->Msisdn;
		_->generate_msisdn()
	end.

generate_imsi(Msisdn)->
    Rand_s=string:right(Msisdn,3),
    "999000900000"++Rand_s.
msisdn_by_uid(Uid) when integer(Uid)->
    msisdn_by_uid(integer_to_list(Uid));

msisdn_by_uid(Uid) when atom(Uid)->
    msisdn_by_uid(atom_to_list(Uid));

msisdn_by_uid(Uid) when list(Uid)->
	Num=lists:sum(Uid),
	Str=lists:flatten( pbutil:sprintf("%03d",[Num rem 1000])),
	"+33900000"++Str.

imsi_by_uid(wrongimsi) ->
    "2080109000000029";

imsi_by_uid(Uid) when atom(Uid)->
    imsi_by_uid(atom_to_list(Uid));

imsi_by_uid(Uid) when integer(Uid)->
    imsi_by_uid(integer_to_list(Uid));

imsi_by_uid(Uid) when list(Uid)->
    Num=lists:sum(Uid),
    Str=lists:flatten( pbutil:sprintf("%03d",[Num rem 1000])),
    "999000900000"++Str.

get_interfaces(Sub)->
    case Sub of
	"mobi"->
	    [ocfrdp, spider, sachem, asmetier];
	"cmo"->
	    [ocfrdp, spider, sachem, asmetier];
	X when X=="postpaid";X=="dme";X=="opim";X=="enterprise"->
	    [ocfrdp, spider,asmetier];
	X when X=="virgin_comptebloque";X=="virgin_prepaid";X=="carrefour_prepaid";X=="carrefour_comptebloq";
		   X=="tele2_comptebloque";X=="tele2_pp";X=="ten_comptebloque";X=="nrj_comptebloque";X=="nrj_prepaid";
		   X=="monacell_prepaid";X=="monacell_comptebloqu";X=="symacom";X=="omer";X=="bzh_cmo"->
	    [ocfrdp, sachem];
	_ ->
	    [ocfrdp]
    end.

get_uid({imsi,Imsi})->
    case ets:info(test_profile,name) of
	undefined->undefined;
	_-> Profiles=ets:tab2list(test_profile),
	    get_uid(Profiles,{imsi,Imsi})
    end;


get_uid({msisdn,Msisdn})->
    case ets:info(test_profile,name) of
	undefined->undefined;
	_-> 
	    Profiles=ets:tab2list(test_profile),
	    get_uid(Profiles,{msisdn,Msisdn})
    end.

get_uid([],_)->undefined;

get_uid([H|T],{msisdn,[$0|L]=Msisdn})->
    case H of
	{Uid,P} when tuple(P)->
	    P1=tuple_to_list(P),
	    case lists:nth(2,P1) of		
	     	Msisdn -> Uid;				
		"33"++L -> Uid;
		"+33"++L -> Uid;
	     	_->get_uid(T,{msisdn,Msisdn})
	     end;
	_->get_uid(T,{msisdn,Msisdn})
    end;

get_uid([H|T],{msisdn,Msisdn}) ->
    case H of
	{Uid,P} when tuple(P)->
	    P1=tuple_to_list(P),
	    case lists:nth(2,P1) of		
	     	Msisdn -> Uid;
		"+"++Msisdn -> Uid;
		_->get_uid(T,{msisdn,Msisdn})
	    end;
	_->get_uid(T,{msisdn,Msisdn})
    end;


get_uid([H|T],{imsi,Imsi})->
    case H of
	{Uid,P} when tuple(P)->
	    P1=tuple_to_list(P),
	    case lists:nth(3,P1) of
		Imsi-> Uid;
		_->get_uid(T,{imsi,Imsi})
	    end;
	_->get_uid(T,{imsi,Imsi})
    end.


insert_profile(Uid,Profile)->
    ets:insert(test_profile,{Uid,Profile}),
    io:format("Inserted profile to ets,Uid= ~p~n",[Uid]).

retrieve(Uid, Type)->
    rpc(?MODULE,retrieve_,[Uid,Type]).


retrieve_(Uid, ?imsi)->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.imsi;
	_->
	    []
    end;

retrieve_(Uid,?msisdn) ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
 	    Profile#test_profile.msisdn;
	_ ->
	    []
    end;

retrieve_(Uid,"subscription") ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
 	    Profile#test_profile.sub;
	_ ->
	    []
    end;

retrieve_(Uid,?predefined_answer) ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.predefined_answer;
	_ ->
	    []
    end;

retrieve_(Uid,"spider") ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
 	    Profile#test_profile.spider_data;
	_ ->
	    undefined
    end;

retrieve_(Uid,?sachem) ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.sachem_data;
	_ ->
	    []
    end;

retrieve_(Uid,?asmetier) ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.asmetier_data;
	_ ->
	    []
    end;

retrieve_(Uid,?ocfrdp) ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.ocfrdp_data;
	_ ->
	    []
    end;

retrieve_(Uid,"mipc") ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.mipc_data;
	_ ->
	   undefined 
    end;

retrieve_(Uid,"vpbx") ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Profile#test_profile.vpbx_data;
	_ ->
	   undefined 
    end;

retrieve_(Uid,{?ocfrdp,Request}) ->
    case ets:lookup(test_profile,Uid) of
	[{Uid,Profile}]->
	    Data=Profile#test_profile.ocfrdp_data,
            case Data of
               undefined->undefined;
               _->
                   Response=proplists:get_value(Request,Data)
           end; 
	_ ->
	    []
    end;

retrieve_(Uid, {?sachem, Req_name})->
    case ets:lookup(test_profile,Uid) of
        [{Uid,Profile}]->
            Sachem_data=Profile#test_profile.sachem_data,
	    proplists:get_value(Req_name,Sachem_data);
	_ ->
	    []
    end;

retrieve_(Uid, {?sachem, Req_name, Element})->
    case ets:lookup(test_profile,Uid) of
        [{Uid,Profile}]->
            Sachem_data=Profile#test_profile.sachem_data,
	    Req_data=proplists:get_value(Req_name,Sachem_data),
	    proplists:get_value(Element,Req_data);
	_ ->
	    []
    end;

retrieve_(Uid,"interfaces") ->
    case ets:lookup(test_profile,Uid) of
        [{Uid,Profile}]->
            Profile#test_profile.interfaces;
	_ ->
	    []
    end;

retrieve_(Uid,"test_profile") ->
    case ets:lookup(test_profile,Uid) of
        [{Uid,Profile}]->
            Profile;
	_ ->
	    []
    end;

retrieve_(Uid,_) ->
    io:format("Not found"),
    [].

update_profile(Uid,{Field,Value})->
    update_profile(Uid,[{Field,Value}]);

update_profile(Uid,Pairs) when list(Pairs)->
    Old_profile=
	case ets:lookup(test_profile,Uid) of
	    []->
		#test_profile{};
	    [{Uid,Profile}]->
		Profile
	end,
    Fields=record_info(fields,test_profile),
    New_profile=oma_util:pairs_to_record(Old_profile, Fields, Pairs),
    ets:delete(test_profile,Uid),
    ets:insert(test_profile,{Uid,New_profile}),
    ok.

update_profile(Uid,?predefined_answer,Pairs)->
    Predefined_answer = retrieve_(Uid, ?predefined_answer),
    New_predefined_answer=modify_list_property(Predefined_answer,Pairs),
    update_profile(Uid, [{predefined_answer, New_predefined_answer}]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils for initing the conection  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



set_interfaces_for_test()->
    rpc_for_test(application,set_env,[pfront_orangef,sachem_version,online])++
	rpc_for_test(application,set_env,[pfront_orangef,mipc_vpbx_version, online])++
	rpc_for_test(application,set_env,[pfront_orangef,spider_version, online])++
	rpc_for_test(application,set_env,[pfront_orangef,ocfrdp_version, online])++
	rpc_for_test(application,set_env,[pfront_orangef,asmetier_version, online]).

disable_oto()->
	rpc_for_test(application,set_env,[pservices_orangef,one2one_activated_cmo,false])++
	rpc_for_test(application,set_env,[pservices_orangef,one2one_activated_mobi,false])++
	rpc_for_test(application,set_env,[pservices_orangef,one2one_activated_postpaid,false]).

init(Uid,Server)->
    [connect(Server)]++
	init_connection(Uid)++
	[{ussd2, [ {send, "#128*13#"}]},
	 {pause, 1000}]++
	rpc_for_test(oma_config,reload_config,[])++
	rpc_for_test(application,set_env,[pservices_orangef,sce_used,true])++
	rpc_for_test(application,set_env,[pservices_orangef,refonte_ergo_mobi,true])++
	disable_oto()++
	set_interfaces_for_test().

init(Uid)->
    init(Uid,smppasn).

init_connection(Uid) ->
    Imsi=imsi_by_uid(Uid),
    [{msaddr, {subscriber_number, private, Imsi}}].

connect(smppasn) ->
    {connect_smppasn, {"localhost", 7432}};
connect(smpp) ->
    {connect_smpp, {"localhost", 7431}}.

set_imei(Uid,IMEI) ->
    IMSI=imsi_by_uid(Uid),    
    case IMEI of
	null -> [];
	_ ->
	    ["L'IMEI de l'IMSI " ++ IMSI ++ " devient " ++ IMEI,
	     {shell_no_trace,
	      [ {send, "mysql -u possum -ppossum -B -vv -e "
		 "\"UPDATE users SET imei='"++IMEI++"'"
		 " WHERE imsi='"++IMSI++"'\" mobi"},
		{expect, ".*"},
		{send, "mysql -u possum -ppossum  -B -e "
		 "\"SELECT imei from  users where imsi='"++IMSI++"'\" mobi"},
		{expect,IMEI}
	       ]}
	    ]
    end.


%%%%%%%%%%%%%%%%%%%%%%
%%Common utils     %%%
%%%%%%%%%%%%%%%%%%%%%%

rpc(Mod, Fun, Args) ->
    case rpc:call(possum@localhost, Mod, Fun, Args) of
	{badrpc, X} = Error -> exit(Error);
	X                   -> X
    end.
rpc_for_test(Mod, Fun, Arg)->
    [{erlang_no_trace,
      [{rpc, call, [possum@localhost,Mod, Fun,Arg]}
      ]}].


modify_list_property(List,{Field,Value})->
    modify_list_property(List,[{Field,Value}]);

modify_list_property(List,[])->
    List;

modify_list_property(List,[{Field_name,Value}|T])->
    New_list=proplists:delete(Field_name,List)++[{Field_name,Value}],
    modify_list_property(New_list,T).
wait(Time) ->
    receive
	nothing -> ok
    after Time ->
	    ok
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils for updating SACHEM data   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%update_sachem/3

update_sachem(Uid,Req_name,Type)->
    rpc_for_test(?MODULE,update_sachem_,[Uid,Req_name,Type]).

%%update_sachem_/3
update_sachem_(Uid, Req_name, {Field,Value})->
    update_sachem_(Uid, Req_name, [{Field,Value}]);

update_sachem_(Uid, Req_name, Pairs) when list(Pairs) ->
    Sachem_data = retrieve_(Uid, ?sachem),
    Resp_data=proplists:get_value(Req_name,Sachem_data),
    New_response_data=modify_list_property(Resp_data,Pairs),
    New_sachem_data=proplists:delete(Req_name,Sachem_data)++[{Req_name,New_response_data}],
    update_profile(Uid, [{sachem_data, New_sachem_data}]).

%%set_dcl/2
set_dcl(Uid,DCL)->
    rpc_for_test(?MODULE,set_dcl_,[Uid,DCL]).

set_dcl_(Uid,DCL)->
    update_spider_(Uid, profile, {frSpecificPrepaidOfferValue,integer_to_list(DCL)}),
    update_sachem_(Uid, ?csl_doscp, [{"DCL_NUM",integer_to_list(DCL)}]).

%%set_list_options/2
set_list_options(Uid,List)->
    rpc_for_test(?MODULE,set_list_options_,[Uid,List]).

set_list_options_(Uid,List)->
    List_options=sachem_online:list_options(List),
    update_sachem_(Uid, ?csl_op, [{"NB_OP",integer_to_list(length(List))},{"OP_PARAMS",List_options}]).

insert_option_(Uid,Option)when record(Option,option)->
    Old_OP_PARAMS=retrieve_(Uid,{?sachem,"csl_op", "OP_PARAMS"}),
    New_OP_PARAMS=add_option(Option,Old_OP_PARAMS),
    update_sachem_(Uid, ?csl_op, [{"NB_OP",integer_to_list(length(New_OP_PARAMS))},{"OP_PARAMS",New_OP_PARAMS}]).

add_option(Option,[]) when record(Option,option)->
    [sachem_online:option_params(Option)];
add_option(Option,[H|T]) when record(Option,option)->
    [TOP_NUM,OPT_DATE_SOUSCRIPTION,OPT_DATE_DEB_VALID,OPT_DATE_FIN_VALID,
     OPT_INFO1,OPT_INFO2,TCP_NUM,PTF_NUM,RNV_NUM,CPP_CUMUL_CREDIT]=H,
    case Option#option.top_num of
	TOP_NUM->
	    [H|T];
	_->[H]++add_option(Option,T)
    end.

%%set_list_comptes/2
set_list_comptes(Uid,List)->
    rpc_for_test(?MODULE,set_list_comptes_,[Uid,List]).

set_list_comptes_(Uid,List)->
    List_comptes=sachem_online:list_comptes(List),
    update_sachem_(Uid, ?csl_doscp, [{"NB_CPT",integer_to_list(length(List))},{"CPT_PARAMS",List_comptes}]).

%%insert_compte/2
insert_comptes(Uid,Comptes)->
    rpc_for_test(?MODULE,insert_comptes_,[Uid,Comptes]).

insert_comptes_(Uid,Comptes)->
    Old_CPT_PARAMS=retrieve_(Uid,{?sachem,"csl_doscp", "CPT_PARAMS"}),
    New_CPT_PARAMS=add_comptes(Comptes,Old_CPT_PARAMS),
    update_sachem_(Uid, ?csl_doscp, [{"NB_CPT",integer_to_list(length(New_CPT_PARAMS))},{"CPT_PARAMS",New_CPT_PARAMS}]).

add_comptes([],CPT_PARAMS)->
    CPT_PARAMS;

add_comptes([Compte|Rest],CPT_PARAMS)->
    New_CPT_PARAMS=add_compte(Compte,CPT_PARAMS),
    add_comptes(Rest,New_CPT_PARAMS).

add_compte(Compte,[]) when record(Compte,compte)->
    [sachem_online:compte_params(Compte)];

add_compte(Compte,[H|T]) when record(Compte,compte)->
    [TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
     CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
     CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP]=H,
    case integer_to_list(Compte#compte.tcp_num) of
	TCP_NUM->
	    Compte1=Compte#compte{rnv=list_to_integer(RNV_NUM)},
	    Compte_params=sachem_online:compte_params(Compte1),
	    [Compte_params]++T;
	_->[H]++add_compte(Compte,T)
    end.

set_sachem_recharge(Uid,Sachem_recharge)->
    rpc_for_test(?MODULE,set_sachem_recharge_,[Uid,Sachem_recharge]).

set_sachem_recharge_(Uid,Sachem_recharge) 
  when record(Sachem_recharge,sachem_recharge)->
    TTK_NUM=integer_to_list(Sachem_recharge#sachem_recharge.ttk_num),
    CTK_NUM=integer_to_list(Sachem_recharge#sachem_recharge.ctk_num),
    Accounts=lists:map(fun(#account{tcp_num=Tcp,montant=Montant,unit=Unit,dlv=Dlv,bon_montant=Bonus})->
			       {integer_to_list(Tcp),integer_to_list(Montant),integer_to_list(Unit),integer_to_list(Dlv),integer_to_list(Bonus)} end,
		       Sachem_recharge#sachem_recharge.accounts),
    CPT_PARAMS=profile_manager:retrieve(Uid, {?sachem, ?csl_doscp, "CPT_PARAMS"}),
    Comptes= lists:map(fun({TCP_NUM,MONTANT,UNIT,DLV,BON_MONTANT})->
			       case search_compte_from_list(TCP_NUM,CPT_PARAMS) of
				   [TCP_NUM, ECP_NUM, UNT_NUM, PTF_NUM, CPP_SOLDE, CPP_DATE_LV,
				    CPP_DATE_CREA, CPP_DATE_MODIF,CPP_DESTINATION,
				    CPP_CUMUL_CREDIT, RNV_NUM, TYPE_DLV, OPT_TCP]->
				       NEW_SOLDE=integer_to_list(list_to_integer(CPP_SOLDE)+list_to_integer(MONTANT)),
				       [TCP_NUM,DLV,NEW_SOLDE,UNIT,"0",BON_MONTANT];
				   _->
				       [TCP_NUM,DLV,MONTANT,UNIT,"0",BON_MONTANT]
			       end 
		       end, Accounts),
    update_sachem_(Uid,?csl_tck,{"TTK_NUM", TTK_NUM}),
    update_sachem_(Uid,?rec_tck,[{"TTK_NUM", TTK_NUM},{"CPT_PARAMS", Comptes},{"CTK_NUM", CTK_NUM}]).

search_compte_from_list(TCP_NUM,[])->
    [];
search_compte_from_list(TCP_NUM,[H|T])->
    case H of
	[TCP_NUM | Rest]->
	    H;
	_->search_compte_from_list(TCP_NUM,T)
    end.

update_user_state(Uid,Type)->
    rpc_for_test(?MODULE,update_user_state_,[Uid,Type]).

update_user_state_(Uid,Pairs)when list(Pairs);tuple(Pairs)->
    Params=sachem_online:user_state_params_to_doscp_resp_params(Pairs),
    update_sachem_(Uid,?csl_doscp,Params).

%%set_sachem_response/2: 
%%set_sachem_response(my_id,{"maj_op",{nok,myreason}})
%%set_sachem_response(my_id,[{"maj_op",{nok,reason1}},{"csl_tck",{nok,reason2}}])

set_sachem_response(Uid,Pairs)->
    rpc_for_test(?MODULE,update_profile,[Uid, ?predefined_answer, Pairs]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils for updating SPIDER data  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set_default_spider(Uid,Type, Data)->
    rpc_for_test(?MODULE,set_default_spider_,[Uid,Type,Data]).

set_default_spider_(Uid, config, Config)-> 
    Profile=retrieve(Uid,"test_profile"),
    Msisdn=Profile#test_profile.msisdn,
    Imsi=Profile#test_profile.imsi,
    Sub=Profile#test_profile.sub,
    Dcl=
	case Sub of
	    X when X=="postpaid";X=="opim";X=="dme";X=="anon"->1;
	    _->Profile#test_profile.dcl
	end,
    Spider=spider_online:build_spider(Msisdn,Imsi,Sub,integer_to_list(Dcl),Config),
    update_profile(Uid, [{spider_data, Spider}]);

set_default_spider_(Uid, sub, Sub)-> 
    Profile=retrieve(Uid,"test_profile"),
    Msisdn=Profile#test_profile.msisdn,
    Imsi=Profile#test_profile.imsi,
    Dcl=
	case Sub of
	    X when X=="postpaid";X=="opim";X=="dme";X=="anon"->1;
	    _->Profile#test_profile.dcl
	end,
    Spider=spider_online:build_spider(Msisdn,Imsi,Sub,integer_to_list(Dcl)),
    update_profile(Uid, [{spider_data, Spider}]).

set_bundles(Uid,Bundles)->
    rpc_for_test(?MODULE,set_bundles_,[Uid,Bundles]).

set_bundles_(Uid,Bundle) when record(Bundle,spider_bundle)->
    set_bundles_(Uid,[Bundle]);

set_bundles_(Uid,Bundles=[H|T]) when record(H,spider_bundle)->
    Spider=retrieve(Uid,"spider"),
    update_profile(Uid, {spider_data, Spider#spider{bundles=Bundles}});
set_bundles_(Uid,[])->
    Spider=retrieve(Uid,"spider"),
    update_profile(Uid, {spider_data, Spider#spider{bundles=[]}}).

insert_bundle(Uid,Bundle) when record(Bundle,spider_bundle) ->
    rpc_for_test(?MODULE,insert_bundle_,[Uid,Bundle]).

insert_bundle_(Uid,Bundle) when record(Bundle,spider_bundle)->
    Spider=retrieve(Uid,"spider"),
    Bundles1=add_bundles(Spider#spider.bundles,Bundle),
    update_profile(Uid, {spider_data, Spider#spider{bundles=Bundles1}}).

add_bundles([],Bundle)->
    [Bundle];

add_bundles([H|T],Bundle)->
    PriorityType=H#spider_bundle.priorityType,
    case Bundle#spider_bundle.priorityType of
	PriorityType->
	    [Bundle]++T;
	_->[H]++add_bundles(T,Bundle)
    end.

update_spider(Uid, Type, Data)->
    rpc_for_test(?MODULE,update_spider_,[Uid, Type, Data]).

update_spider_(Uid,status,Status) when record(Status,spider_status)->
    Spider=retrieve(Uid,"spider"),
    update_profile(Uid, [{spider_data, Spider#spider{status=Status}}]);

update_spider_(Uid,profile, {Field,Value})->
    update_spider_(Uid,profile, [{Field,Value}]);

update_spider_(Uid, profile, Pairs)->
    Spider=retrieve(Uid,"spider"),
    case Spider of
	undefined->[];
	_->
	    Fields=record_info(fields,spider_profile),
	    Profile_pairs=oma_util:record_to_pairs(Fields,Spider#spider.profile),
	    NewProfile_pairs=modify_list_property(Profile_pairs,Pairs),
	    Profile=oma_util:pairs_to_record(#spider_profile{},Fields,NewProfile_pairs),
	    update_profile(Uid, [{spider_data, Spider#spider{profile=Profile}}])
	end;

update_spider_(Uid, profile, Profile) when record(Profile,spider_profile)->
    Spider=retrieve(Uid,"spider"),
    update_profile(Uid, {spider_data, Spider#spider{profile=Profile}});

update_spider_(Uid, data, Data)->
    update_profile(Uid, [{spider_data, Data}]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils for updating ASMETIER data%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_asm_profile(Uid,Asm_profile)->
    rpc_for_test(?MODULE,set_asm_profile_,[Uid,Asm_profile]).

set_asm_profile_(Uid,#asm_profile{code_so=Code_so,
				  option_name=Option_name,
				  code_segco=Code_segco})->
    Asmetier_data=retrieve(Uid,?asmetier),
    Msisdn=retrieve(Uid,?msisdn),
    IdDossier="oee_"++Msisdn++"_"++Code_so,
    IdUtilisateur = "edl_"++Msisdn++"NOACT",
    New_Ident={ok, IdDossier,IdUtilisateur,Code_so,Code_segco},
    Options=
	case Code_so of
	    "NOACT"->[];
	    _->
		[#asm_option{code_so=Code_so,option_name=Option_name}]
	end,
    Asm_options=asmetier_online:list_service_optionels(Options),
    Pairs=[{?getIdent,New_Ident},{?getServicesOptionnels,{ok, Asm_options}},{?getImpact,{ok,[]}},{?doMod,ok}],
    New_data=modify_list_property(Asmetier_data,Pairs),
    update_profile(Uid,{asmetier_data,New_data}).

set_asm_list_options(Uid,Options)->
    rpc_for_test(?MODULE,set_asm_list_options_,[Uid,Options]).

set_asm_list_options_(Uid,Options=[H|T]) when record(H,asm_option)->
    Asmetier_data=retrieve(Uid,?asmetier),
    Asm_options=asmetier_online:list_service_optionels(Options),
    Pairs=[{?getServicesOptionnels,{ok, Asm_options}}],
    New_data=modify_list_property(Asmetier_data,Pairs),
    update_profile(Uid,{asmetier_data,New_data}).

set_asm_impact_options(Uid,Options)->
    rpc_for_test(?MODULE,set_asm_impact_options_,[Uid,Options]).

set_asm_impact_options_(Uid,Options=[H|T]) when record(H,asm_option)->
    Asmetier_data=retrieve(Uid,?asmetier),
    Asm_options=asmetier_online:list_service_optionels(Options),
    Pairs=[{?getImpact,{ok, Asm_options}}],
    New_data=modify_list_property(Asmetier_data,Pairs),
    update_profile(Uid,{asmetier_data,New_data}).


set_asm_response(Uid,Req_name,Data)->
    rpc_for_test(?MODULE,set_asm_response_,[Uid,Req_name,Data]).

set_asm_response_(Uid,Req_name,Data)->
    Asmetier_data=retrieve(Uid,?asmetier),
    Pairs=[{Req_name,Data}],
    New_data=modify_list_property(Asmetier_data,Pairs),
    update_profile(Uid,{asmetier_data,New_data}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils for updating MPIC & VPBX data%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_mipc(Uid, RequestName, Data)->
    set_mipc_vpbx(Uid, "mipc", RequestName, Data).

set_vpbx(Uid, RequestName, Data)->
    set_mipc_vpbx(Uid, "vpbx", RequestName, Data).

set_mipc_vpbx(Uid, Server, RequestName, New_RespData)->
    rpc_for_test(?MODULE,set_mipc_vpbx_,[Uid,Server, RequestName,New_RespData]).

set_mipc_vpbx_(Uid, Server, RequestName, New_RespData)->
    Data= 
    case retrieve_(Uid, Server) of
        undefined->[];
        X->X
    end,
    New_data=proplists:delete(RequestName,Data)++[{RequestName,New_RespData}],
    update_profile(Uid, [{list_to_atom(Server++"_data"), New_data}]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Utils for updating OCF RDP data%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_ocf_response(Uid,Request,Data)->
    rpc_for_test(?MODULE,set_ocf_response_,[Uid,Request,Data]).

set_ocf_response_(Uid,Request,Data)->
    Response = 
        case Data of 
            default -> 
                Profile = retrieve_(Uid, "test_profile"),
                [{T, Res}] = ocfrdp_online:default_response(Request, Profile),
                Res;
            _ -> 
                Data
        end,
    Ocfrdp_data=retrieve_(Uid,"ocfrdp"),
    New_data=modify_list_property(Ocfrdp_data,{Request,Response}),
    update_profile(Uid,{ocfrdp_data,New_data}).
