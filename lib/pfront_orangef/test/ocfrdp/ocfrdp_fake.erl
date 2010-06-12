-module(ocfrdp_fake).


-export([request/2, start/0, start_ets/0]).

-include("../../include/ocf_rdp.hrl").
-include("./ocfrdp_fake.hrl").

start() ->
    spawn(?MODULE, start_ets, []).

start_ets() ->
    test_init(),
    receive after infinity -> ok end.
		    

request(_Http_request_info,Xml)->
%    test_init(),
    {ok, Dec} = xmlrpc_decode:payload(Xml),
    {_,Resp} = handler(dummy, Dec),
    {ok, EncResp} = xmlrpc_encode:payload(Resp),
    {200,"text/xml",EncResp}.

%% Subscribe
handler(_State, {call, 'OrangeAPI.subscribeByMsisdn', N}) ->
   [{struct, [{username,_},{password,_}]},Msisdn,_]=N,
    {false, {response, [true,{struct, info_sub({msisdn,Msisdn})}]}};

handler(_State, {call, 'OrangeAPI.subscribeByImsi', N}) ->
   [{struct, [{username,_},{password,_}]},IMSI,_]=N,
    {false, {response, subscribe({imsi,IMSI})}};

handler(_State, {call, 'OrangeAPI.unSubscribeByImsi', N}) ->
   [{struct, [{username,_},{password,_}]},IMSI]=N,
    {false, {response, [true]}};

handler(_State, {call, 'OrangeAPI.unSubscribeByMsisdn', N}) ->
   [{struct, [{username,_},{password,_}]},IMSI]=N,
    {false, {response, [true]}};

%% Consultation
%% Subscribe
handler(_State, {call, 'OrangeAPI.getUserInformationByMsisdn', N}) ->
   [{struct, [{username,_},{password,_}]},Msisdn]=N,
    {false, {response, [{struct, info_sub({msisdn,Msisdn})}]}};
handler(_State, {call, 'OrangeAPI.getUserInformationByImsi', N}) ->
   [{struct, [{username,_},{password,_}]},Imsi]=N,
    {false, {response, get_user_info({imsi,Imsi})}};

handler(_State, {call, 'OrangeAPI.getSubscriptionInformationByMsisdn', N}) ->
   [{struct, [{username,_},{password,_}]},VASId,Msisdn]=N,
    {false, {response, 
	     [{struct, 
	       [{'CustomerData',{struct, info_sub({msisdn,Msisdn})}},
	        {'SubscriptionInfo',{struct, info_options()}}]}]}};

handler(_State, {call, 'OrangeAPI.getSubscriptionInformationByImsi', N}) ->
   [{struct, [{username,_},{password,_}]},VASId,Imsi]=N,
    {false, {response, 
	     [{struct, 
	       [{'CustomerData',{struct, info_sub({imsi,Imsi})}},
	        {'SubscriptionInfo',{struct, info_options()}}]}]}};

handler(_State, {call, 'OrangeAPI.getOptionalServicesByMsisdn', N}) ->
   [{struct, [{username,_},{password,_}]},Msisdn]=N,
    {false,{response,[{array, options(Msisdn)}]}};

handler(_State, {call, 'OrangeAPI.isMsisdnOrange', N}) ->
   [{struct, [{username,_},{password,_}]},Msisdn]=N,
    IS=
	case Msisdn of
	    "33"++[H,_,_,_,_,_,_,_,X] when (((H==$6) or (H==$7)) and (X < $5)) -> true;
	    _ -> false
	end,
    {false, {response, [IS]}};

handler(_State, Payload) ->
    io:format("Default clause in OCFRDP fake:~p ~n",[Payload]),    
    FaultString = lists:flatten(io_lib:format("Unknown call: ~p", [Payload])),
    {false, {response, {fault, -1, FaultString}}}.

subscribe({imsi,"208010900000002"})->
    [false];
subscribe({imsi,"208010900000003"}) ->
    {fault, ?IMSI_UNKNOW, "IMSI unknow"};
subscribe({imsi,"208010900000004"}) ->
    {fault, 13, "Multiple souscription"};
subscribe({imsi,IMSI}=Crit) ->
    case init(IMSI) of
	#ocf_test{tac=TAC,ussd_level=UL,msisdn=MSISDN,sub=SUB,
		  tech_seg_code=TechSegCode}->
	    [{struct,[{'SubscriptionResult',true},
		      {'CustomerData',
		       {struct,
			info_sub(Crit,TAC,UL,SUB,MSISDN,TechSegCode)}}]}];
	?IMSI_UNKNOW->
	    {fault, ?IMSI_UNKNOW, "IMSI unknow"}
    end;
subscribe({msisdn,IMSI}=Crit) ->
    [{struct,[{'SubscriptionResult',true},
	      {'CustomerData',{struct,info_sub(Crit)}}]}].

get_user_info({imsi,"208010900000003"}) ->
    {fault, 11, "IMSI unknow"};
get_user_info({imsi,IMSI}=Crit)->
    case init(IMSI) of
	#ocf_test{tac=TAC,ussd_level=UL,msisdn=MSISDN,sub=SUB,
		  tech_seg_code=TechSegCode,prepaidFlag=PrepaidFlag}->
	    [{struct, info_sub(Crit,TAC,UL,SUB,MSISDN,TechSegCode,PrepaidFlag)}];
	?IMSI_UNKNOW->
	    {fault, ?IMSI_UNKNOW, "IMSI unknow"}
    end.
info_sub({msisdn,MSISDN})->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
    sub(MSISDN,imsi(MSISDN),Date);
info_sub({imsi,IMSI}) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
    sub(msisdn(IMSI),IMSI,Date).

info_sub({imsi,IMSI},TAC,UL,SUB,TechSegCode) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
    sub(msisdn(IMSI),IMSI,Date,TAC,UL,SUB,TechSegCode).


info_sub({imsi,IMSI},TAC,UL,SUB,undefined,TechSegCode) ->
    info_sub({imsi,IMSI},TAC,UL,SUB,TechSegCode);
info_sub({imsi,IMSI},TAC,UL,SUB,MSISDN,TechSegCode) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
    sub(format_msisdn(MSISDN),IMSI,Date,TAC,UL,SUB,TechSegCode).

info_sub({imsi,IMSI},TAC,UL,SUB,MSISDN,TechSegCode,PrepaidFlag) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
    sub(format_msisdn(MSISDN),IMSI,Date,TAC,UL,SUB,TechSegCode,PrepaidFlag).


sub(MSISDN,IMSI,Date)->
    [{'Msisdn',MSISDN},
     {'CreationDate',{date,Date}},
     {'LastUpdate',{date,Date}},
     {'FileState',"10"},
     {'Imsi',IMSI},
     {'CustomerId',"123456132456497"},
     {'PrepaidFlag',prepaid_flag("mobi")},
     {'SegmentCode',seg_co("mobi")},
     {'TACCode',"123456"},
     {'USSDLevel',1}].

sub(MSISDN,IMSI,Date,TAC,UL,Sub,undefined) ->
    [{'Msisdn',MSISDN},
     {'CreationDate',{date,Date}},
     {'LastUpdate',{date,Date}},
     {'FileState',"10"},
     {'Imsi',IMSI},
     {'CustomerId',"123456132456497"},
     {'PrepaidFlag',prepaid_flag(Sub)},
     {'SegmentCode',seg_co(Sub)},
     {'TACCode',TAC},
     {'USSDLevel',UL}];
sub(MSISDN,IMSI,Date,TAC,UL,Sub,TechSegCode)->
    [{'Msisdn',MSISDN},
     {'CreationDate',{date,Date}},
     {'LastUpdate',{date,Date}},
     {'FileState',"10"},
     {'Imsi',IMSI},
     {'CustomerId',"123456132456497"},
     {'PrepaidFlag',prepaid_flag(Sub)},
     {'SegmentCode',seg_co(Sub)},
     {'TechnologicalSegment',TechSegCode},
     {'TACCode',TAC},
     {'USSDLevel',UL}].

sub(MSISDN,IMSI,Date,TAC,UL,Sub,TechSegCode,PrepaidFlag)->
    [{'Msisdn',MSISDN},
     {'CreationDate',{date,Date}},
     {'LastUpdate',{date,Date}},
     {'FileState',"10"},
     {'Imsi',IMSI},
     {'CustomerId',"123456132456497"},
     {'SegmentCode',seg_co(Sub)},
     {'TechnologicalSegment',TechSegCode},
     {'TACCode',TAC},
     {'USSDLevel',UL},
     {'PrepaidFlag',PrepaidFlag}].

info_options()->
    [{'Email1',"test1@test.com"},
     {'Email2',"test2@test.com"},
     {'Email3',"test3@test.com"},
     {'MailboxStatus',14},
     {'ActivePortal',true},
     {'MMSBlacklist',false},
     {'SMSInfo',"OL1"}].

%% 20801HHV
imsi("33"++[H,H1,H2|R]) when H==$6;H==$7->
    "20801"++[H1,H2]++"0"++R;
imsi("999"++[H1,H2|R]) ->
    "99999"++[H1,H2]++"0"++R.
 
msisdn("2080"++[X,M1,M2,V|R])->
    lists:flatten("336"++[X,M1,R]);
msisdn("99900"++[M1,M2,V|R])->
    "9990"++R.

format_msisdn([$+|T])->
    T;
format_msisdn(M) ->
    M.
		     
seg_co("mobi")->
    "CPP01";
seg_co("omer")->
    "CPP02";
seg_co("cmo") ->
    "ABONW";
seg_co("dme") ->
    "30FLO";
seg_co("postpaid") ->
    "30JOU";
seg_co("bzh_gp")->
    "BZHF1";
seg_co("bzh_cmo")->
    "BZHF2";
seg_co("tele2_gp")->
    "TL2F1";
seg_co("tele2_pp")->
    "TL2F2";
seg_co("tele2_comptebloque")->
    "TL2F3";
seg_co("virgin_postpaid") ->
    "VIRG1";
seg_co("virgin_prepaid") ->
    "VIRG2";
seg_co("nrj_prepaid") ->
    "NEPT1";
seg_co("virgin_comptebloque") ->
    "VIRG3";
seg_co("ten_postpaid") ->
    "MAO00";
seg_co("ten_comptebloque") ->
    "MAO01";
seg_co("carrefour_prepaid") ->
    "CARF1";
seg_co("monacell_prepaid") ->
    "MOT01";
seg_co("monacell_comptebloqu") ->
    "MOT02";
seg_co("monacell_postpaid") ->
    "MOT00";
seg_co("nrj_comptebloque")->
    "NEPT2";
seg_co("carrefour_comptebloq")->
    "CARF1";
seg_co("opim")->
    "OPIM1";
seg_co("leo_gourou")->
    "F2LEO";
seg_co(Else) ->
    io:format("~n~n~n~n~p~n~n~n~n",[Else]),
    "UNKNOW".

prepaid_flag("mobi")->
    "oui";
prepaid_flag("omer")->
    "nof";
prepaid_flag("cmo") ->
    "cmo";
prepaid_flag("dme") ->
    "ENT";
prepaid_flag("postpaid") ->
    "non";
prepaid_flag("bzh_gp")->
    "nop";
prepaid_flag("bzh_cmo")->
    "noc";
prepaid_flag("tele2_gp")->
    "nop";
prepaid_flag("tele2_pp")->
    "nof";
prepaid_flag("tele2_comptebloque")->
    "noc";
prepaid_flag("virgin_postpaid") ->
    "nop";
prepaid_flag("virgin_prepaid") ->
    "nof";
prepaid_flag("nrj_prepaid") ->
    "nof";
prepaid_flag("virgin_comptebloque") ->
    "noc";
prepaid_flag("ten_postpaid") ->
    "nop";
prepaid_flag("ten_comptebloque") ->
    "noc";
prepaid_flag("carrefour_prepaid") ->
    "nof";
prepaid_flag("monacell_prepaid") ->
    "nof";
prepaid_flag("monacell_comptebloqu") ->
    "noc";
prepaid_flag("monacell_postpaid") ->
    "nop";
prepaid_flag("nrj_comptebloque")->
    "noc";
prepaid_flag("carrefour_comptebloq")->
    "noc";
prepaid_flag("opim")->
    "nop";
prepaid_flag("leo_gourou")->
    "";
prepaid_flag(Else) ->
    io:format("~n~n~n~n~p~n~n~n~n",[Else]),
    "UNKNOW".

%% ADD RM for test postpaid
options("33"++Msisdn)->
    case init("9"++Msisdn) of
	#ocf_test{options=L} when list(L)->
	    lists:map(fun(OptCode)->
			      {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
				       {'PrestationCode',OptCode}]}
		      end,L);
	#ocf_test{options=error}->
	    undefined;
	
	E->
	    io:format(?MODULE_STRING":options no config:~p~n",[Msisdn]),
	    [{struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
		      {'PrestationCode',"OPWAP"}]},
	     {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
		      {'PrestationCode',"WORX2"}]}
	    ]
    end;
options(Msisdn)->
    case init(Msisdn) of
	#ocf_test{options=L} when list(L)->
	    lists:map(fun(OptCode)->
			      {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
				       {'PrestationCode',OptCode}]}
		      end,L);
	#ocf_test{options=error}->
	    undefined;
	E->
	    io:format(?MODULE_STRING":options no config 2:~p~n",[Msisdn]),
	    [{struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
		      {'PrestationCode',"OPWAP"}]},
	     {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
		      {'PrestationCode',"WORX2"}]}
	    ]
    end.

test_init()->
    case catch ets:info(ocf_test,name) of
	ocf_test->
	    ok;
	_->
	    ets:new(ocf_test,[set,public,named_table]),
	    ets:insert(ocf_test,{"208010900000001",#ocf_test{tac="123456",
							     ussd_level=1,
							     sub="mobi"}})
    end.

init(ID)->
    case catch ets:info(ocf_test,name) of
	ocf_test->
	    ok;
	_->
	    ets:new(ocf_test,[set,public,named_table])
    end,
    case catch ets:lookup(ocf_test,ID) of
	[{ID,#ocf_test{}=OCF}]->
	    OCF;
	E->
	    io:format("Else:~p~n",[E]),
	    ?IMSI_UNKNOW
    end.
