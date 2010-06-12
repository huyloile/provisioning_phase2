-module(ocfrdp_online).
-compile(export_all).


-include("../../pfront_orangef/include/ocf_rdp.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-include("profile_manager.hrl").

request(Call)->
    Resp = get_response(Call),
    slog:event(trace,?MODULE,result,Resp),
    Resp.

get_response(Call)->
    {call,Request,N}=Call,
    case Request of
        X when X=='OrangeAPI.subscribeByMsisdn' -> 
            [{struct, [{username,_},{password,_}]},Resource,_]=N,
            Uid=profile_manager:get_uid({msisdn,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.unSubscribeByMsisdn'; 
            X=='OrangeAPI.getUserInformationByMsisdn' -> 
            [{struct, [{username,_},{password,_}]},Resource]=N,
            Uid=profile_manager:get_uid({msisdn,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.getSubscriptionInformationByMsisdn' ->
            [{struct, [{username,_},{password,_}]},_,Msisdn]=N,
            Uid=profile_manager:get_uid({msisdn,Msisdn}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.unSubscribeByMsisdn'; 
            X=='OrangeAPI.getUserInformationByMsisdn' -> 
            [{struct, [{username,_},{password,_}]},Resource]=N,
            Uid=profile_manager:get_uid({msisdn,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.getSubscriptionInformationByMsisdn' ->
            [{struct, [{username,_},{password,_}]},_,Resource]=N,
            Uid=profile_manager:get_uid({msisdn,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.subscribeByImsi' -> 
            [{struct, [{username,_},{password,_}]},Resource,_]=N,
            Uid=profile_manager:get_uid({imsi,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.unSubscribeByImsi';
            X=='OrangeAPI.getUserInformationByImsi'->
            [{struct, [{username,_},{password,_}]},Resource]=N,
            Uid=profile_manager:get_uid({imsi,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});

        X when X=='OrangeAPI.getSubscriptionInformationByImsi'->
            [{struct, [{username,_},{password,_}]},_,Resource]=N,
            Uid=profile_manager:get_uid({imsi,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        X when X=='OrangeAPI.getOptionalServicesByMsisdn';
            X=='OrangeAPI.isMsisdnOrange' ->
            [{struct, [{username,_},{password,_}]},Resource]=N,
            Uid=profile_manager:get_uid({msisdn,Resource}),
            profile_manager:retrieve_(Uid,{"ocfrdp",X});
        Payload -> 
            io:format("Default clause in OCFRDP fake:~p ~n",[Payload]),    
            FaultString = lists:flatten(io_lib:format("Unknown call: ~p", [Payload])),
            {fault, -1, FaultString}
    end.


%% Subscribe
default_response('OrangeAPI.subscribeByMsisdn'=Type, Profile=#test_profile{msisdn=Msisdn}) ->
    [{Type,{ok, {response, [true,{struct, info_sub(Profile)}]}}}];

default_response('OrangeAPI.subscribeByImsi'=Type, Profile=#test_profile{imsi=IMSI}) ->
    [{Type,{ok, {response, subscribe(Profile)}}}];

default_response('OrangeAPI.unSubscribeByImsi'=Type, _) ->
    [{Type,{ok, {response, [true]}}}];

default_response('OrangeAPI.unSubscribeByMsisdn'=Type, _) ->
    [{Type,{ok, {response, [true]}}}];

%% Consultation
%% Subscribe
default_response('OrangeAPI.getUserInformationByMsisdn'=Type, Profile=#test_profile{msisdn=Msisdn})->
    [{Type,{ok, {response, [{struct, info_sub(Profile)}]}}}];
default_response('OrangeAPI.getUserInformationByImsi'=Type, Profile=#test_profile{imsi=Imsi}) ->
    [{Type,{ok, {response, get_user_info(Profile)}}}];

default_response('OrangeAPI.getSubscriptionInformationByMsisdn'=Type, Profile=#test_profile{msisdn=Msisdn}) ->
    [{Type,{ok, {response, 
	     [{struct, 
	       [{'CustomerData',{struct, info_sub(Profile)}},
                   {'SubscriptionInfo',{struct, info_options()}}]}]}}}];

default_response('OrangeAPI.getSubscriptionInformationByImsi'=Type, Profile=#test_profile{imsi=Imsi}) ->
    [{Type,{ok, {response, 
	     [{struct, 
	       [{'CustomerData',{struct, info_sub(Profile)}},
                   {'SubscriptionInfo',{struct, info_options()}}]}]}}}];

default_response('OrangeAPI.getOptionalServicesByMsisdn'=Type, Profile=#test_profile{msisdn=Msisdn}) ->
    [{Type,{ok,{response,[{array, options(Profile)}]}}}];

default_response('OrangeAPI.isMsisdnOrange'=Type, _) ->
    [{Type,{ok, {response, [true]}}}].

% subscribe({imsi,"208010900000002"})->
%     [false];
% subscribe({imsi,"999000900000379"})->
%     [false];
% subscribe({imsi,"208010900000003"}) ->
%     {fault, ?IMSI_UNKNOW, "IMSI unknow"};
% subscribe({imsi,"208010900000004"}) ->
%     {fault, 13, "Multiple souscription"};
subscribe(#test_profile{tac=TAC,ussd_level=UL,imsi=IMSI,msisdn=MSISDN,sub=SUB,tech_seg_code=TechSegCode})->
    [{struct,[{'SubscriptionResult',true},
                {'CustomerData', {struct, info_sub({imsi,IMSI},TAC,UL,SUB,MSISDN,TechSegCode)}}]}].
% subscribe(#test_profile{msisdn=MSISDN}) ->
%     [{struct,[{'SubscriptionResult',true},
% 	      {'CustomerData',{struct,info_sub({msisdn,MSISDN})}}]}].

% get_user_info({imsi,"208010900000003"}) ->
%     {fault, 11, "IMSI unknow"};
get_user_info(#test_profile{tac=TAC,ussd_level=UL,imsi=IMSI,msisdn=MSISDN,sub=SUB,
        tech_seg_code=TechSegCode,prepaidFlag=PrepaidFlag})->
    [{struct, info_sub({imsi,IMSI},TAC,UL,SUB,MSISDN,TechSegCode,PrepaidFlag)}].

info_sub(Profile=#test_profile{msisdn=MSISDN,imsi=IMSI})->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
    Date1=lists:flatten(Date),
    sub(MSISDN,IMSI,Date1).

info_sub({imsi,IMSI},TAC,UL,SUB,TechSegCode) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
     Date1=lists:flatten(Date),
    sub(msisdn(IMSI),IMSI,Date1,TAC,UL,SUB,TechSegCode).


info_sub({imsi,IMSI},TAC,UL,SUB,undefined,TechSegCode) ->
    info_sub({imsi,IMSI},TAC,UL,SUB,TechSegCode);
info_sub({imsi,IMSI},TAC,UL,SUB,MSISDN,TechSegCode) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
	Date1=lists:flatten(Date),
    sub(format_msisdn(MSISDN),IMSI,Date1,TAC,UL,SUB,TechSegCode).

info_sub({imsi,IMSI},TAC,UL,SUB,MSISDN,TechSegCode,PrepaidFlag) ->
    {{Y,M,D},{H,Mi,S}}={date(),time()},
    Date=pbutil:sprintf("%04d%02d%02dT%02d:%02d:%02d",[Y,M,D,H,Mi,S]),
	Date1=lists:flatten(Date),
    sub(format_msisdn(MSISDN),IMSI,Date1,TAC,UL,SUB,TechSegCode,PrepaidFlag).


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
imsi("+33"++[H,H1,H2|R]) when H==$6;H==$7->
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
seg_co("symacom")->
    "F1SYM";
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
 % options("33"++Msisdn)->
 %     case init({msisdn,"9"++Msisdn}) of
 % 	#test_profile{ocf_options=L} when list(L)->
 % 	    lists:map(fun(OptCode)->
 % 			      {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
 % 				       {'PrestationCode',OptCode}]}
 % 		      end,L);
 % 	#test_profile{ocf_options=error}->
 % 	    undefined;
 % 	
 % 	E->
 % 	    io:format(?MODULE_STRING":options no config:~p~n",[Msisdn]),
 % 	    [{struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
 % 		      {'PrestationCode',"OPWAP"}]},
 % 	     {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
 % 		      {'PrestationCode',"WORX2"}]}
 % 	    ]
 %     end;
options(Profile=#test_profile{})->
    case Profile#test_profile.ocf_options of 
        error -> undefined;
        L when list(L) -> 
	    lists:map(fun(OptCode)->
			      {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
				       {'PrestationCode',OptCode}]}
		      end,L);
	E->
	    [{struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
		      {'PrestationCode',"OPWAP"}]},
	     {struct,[{'EndSubscriptionDate',{date,"18000101T00:00:00"}},
		      {'PrestationCode',"WORX2"}]}
	    ]
    end.

%init(ID)->
%    case catch ets:info(test_profile,name) of
%        test_profile->
%            ok;
%        _->
%            ets:new(test_profile,[set,public,named_table])
%    end,
%    Uid=profile_manager:get_uid(ID),
%    case catch ets:lookup(test_profile,Uid) of
%	[{Uid,#test_profile{}=Profile}]->
%	    Profile;
%	E->
%	    io:format("Else:~p~n",[E]),
%	    ?IMSI_UNKNOW
%    end.
