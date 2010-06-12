-module(sms_mms_infos).

%% SMS MMS INFOS API
-export(['SMIIdentification'/1]).
-export(['SMIProfil'/2]).
-export(['SMIlisteOptions'/2]).
-export(['SMIlisteOptionsSouscrites'/2]).
-export(['SMISouscription'/3]).
-export(['SMImodification'/3]).
-export(['SMIresiliation'/2]).

%% Encoding functions 
-export([encode/4]).
-export([encode/5]).
-export([encode/7]).
-export([encode/8]).
-export([encode/10]).

%% soaplight Callbacks:
-export([decode_by_name/2, build_record/2]).

-include("../../pfront/include/soaplight.hrl").
-include("../include/sms_mms_infos.hrl").
-include("../../pservices_orangef/include/smsinfos.hrl").

-include("../../pserver/include/pserver.hrl").

%% +type request(Message::,TypeReq::atom(),Info::)->
%%                     tuple().
%%%% Sends a Soaplight request
request(Message,TypeReq,Info)->
    Http_url = pbutil:get_env(pfront_orangef, sms_mms_infos_http_url),
    Content_type = pbutil:get_env(pfront_orangef, sms_mms_infos_content_type),
    Req = #soap_req{
      web_service=pbutil:get_env(pfront_orangef,sms_mms_infos_webserv),
      http_url = Http_url, 
      http_headers = [{"Content-Type",Content_type},
		      {"SOAPAction",""}],
      envnamespaces = [{'xmlns:sms',"http://www.orange.fr/smsmmsinfos/"}],
      bodynamespaces = [],
      bodycontent = Message},
    Current_time = oma:unixmtime(),
    Resp = soaplight:request(Req),
    slog:delay(perf, ?MODULE, response_time, Current_time),
    case Resp of
	{'EXIT',{timeout,TimeoutR}}->
	    slog:event(failure, ?MODULE, sms_mms_infos_timeout, TimeoutR),
	    {error,timeout};
        {'EXIT',_}=OtherExit->
            slog:event(count, ?MODULE, sms_mms_infos_exit, OtherExit),
            OtherExit;
	Other ->
	    slog:event(trace, ?MODULE, sms_mms_infos_response,Other ),
	    Other
    end.	    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type 'SMIIdentification'(Msisdn::string())->
%%                     tuple().
%%%% Cette methode permet d'identifier un client afin d'en recuperer la ligne de marche.
%%%% Msisdn : "+336........"
'SMIIdentification'(Msisdn)->
    Message=encode('SMIIdentification',?USSD_CANAL,Msisdn,?USSD),
    request(Message,'SMIIdentification',Msisdn)  .

'SMIProfil'(Msisdn,TypeOption)->
    Message=encode('SMIprofil',?USSD_CANAL,Msisdn,?USSD,TypeOption),
    request(Message,'SMIProfil',Msisdn).

'SMIlisteOptions'(Msisdn,Groupe)->
    Message=encode('sms:SMIlisteOptions',?USSD_CANAL,Msisdn,Groupe),
    Result=request(Message,'sms:SMIlisteOptions',Msisdn),
    analyze_result(Result).

'SMIlisteOptionsSouscrites'(Msisdn,Groupe)->
    Message=encode('sms:SMIlisteOptionsSouscrites',?USSD_CANAL,Msisdn,Groupe),
    Result=request(Message,'sms:SMIlisteOptionsSouscrites',Msisdn),
    analyze_result(Result).


'SMISouscription'(Msisdn,IdOption,CodeCompOption)->
    Message=encode('sms:SMIsouscription',?USSD_CANAL,Msisdn,
		   IdOption,CodeCompOption),
    Result=request(Message,'sms:SMIsouscription',Msisdn),
    analyze_result(Result).


'SMImodification'(Msisdn,IdOption,CodeCompOption)->
    Message=encode('sms:SMImodification',?USSD_CANAL,Msisdn,
		   IdOption,CodeCompOption),
    Result=request(Message,'sms:SMImodification',Msisdn),
    analyze_result(Result).


'SMIresiliation'(Msisdn,IdCompOption)->
    Message=encode('sms:SMIresiliation',?USSD_CANAL,Msisdn,
		   IdCompOption),
    Result=request(Message,'sms:SMIresiliation',Msisdn),
    analyze_result(Result).


%% +type encode(RequestTitle::atom(),CanalSouscription::, _Msisdn::string(), Groupe::string(), TypeOption::) ->
%%                 list().
%%%% encode/4

encode('sms:SMIlisteOptions',CanalSouscription,"+"++_Msisdn,Groupe) ->
    [{'sms:SMIlisteOptions',
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'groupe',[],Groupe}
      ]}];

encode('sms:SMIresiliation',CanalSouscription,"+"++_Msisdn,
       IdCompOption) ->
    [{'sms:SMIresiliation',
      [{'idCanalHistoSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'idCompOption',[],IdCompOption}
      ]}];


encode(RequestTitle,CanalSouscription,"+"++_Msisdn,Groupe) ->
    [{RequestTitle,
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'groupe',[],Groupe}
      ]}].


%% +type encode(RequestTitle::atom(),CanalSouscription::, _Msisdn::string(), Groupe::string(), IdOption::,
%%              TypeOffer::, CompOffer::) ->
%%                 list().
%%%% encode/5
encode('sms:SMIsouscription',CanalSouscription,"+"++_Msisdn,
       IdOption,CodeCompOption) ->
    [{'sms:SMIsouscription',
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'idOption',[],IdOption},
       {'codeCompOption',[],CodeCompOption}
      ]}];


encode('sms:SMImodification',CanalSouscription,"+"++_Msisdn,
       IdOption,CodeCompOption) ->
    [{'sms:SMImodification',
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'idOption',[],IdOption},
       {'codeCompOption',[],CodeCompOption}
      ]}];

encode(RequestTitle,CanalSouscription,"+"++_Msisdn,Groupe,TypeOption) ->
    case pbutil:all_digits(TypeOption) of
	true ->
	    [{RequestTitle,
	      [{xmlns,"http://..."}],
	      [{'idCanalSouscr',[],CanalSouscription},
	       {'msisdn',[],_Msisdn},
	       {'groupe',[],Groupe},
	       {'IdOption',[],TypeOption}
	      ]}];
	false ->
	    [{RequestTitle,
	      [{xmlns,"http://..."}],
	      [{'idCanalSouscr',[],CanalSouscription},
	       {'msisdn',[],_Msisdn},
	       {'groupe',[],Groupe},
	       {'TypeOption',[],TypeOption}
	      ]}]
    end.


encode(RequestTitle,CanalSouscription,"+"++_Msisdn,Groupe,IdOption,TypeOffre,CompOffre) ->
    [{RequestTitle,
      [{xmlns,"http://..."}],
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'groupe',[],Groupe},
       {'IdOption',[],IdOption},
       {'TypeOffre',[],TypeOffre},
       {'CompOffre',[],CompOffre}
      ]}].

%% +type encode(RequestTitle::atom(),CanalSouscription::, _Msisdn::string(), Groupe::string(), IdOption::,
%%              CompOption1::,CompOption2::,CompOption3::,TypeOffre::,CompOffre::) ->
%%                 list().
%%%% encode/9
encode(RequestTitle,CanalSouscription,"+"++_Msisdn,Groupe,IdOption,CompOption1,CompOption2,CompOption3,TypeOffre,CompOffre) ->
    case {CompOption1,CompOption2,CompOption3} of
	{"","",""} ->
	    Complements = {};
	{_,"",""} ->
	    Complements = {'CompOption1',[],CompOption1};
	{_,_,""} ->
	    Complements = {'CompOption1',[],CompOption1},{'CompOption2',[],CompOption2};
	{_,_,_} ->
	    Complements = {'CompOption1',[],CompOption1},{'CompOption2',[],CompOption2},{'CompOption3',[],CompOption3}
    end,
    
    [{RequestTitle,
      [{xmlns,"http://..."}],
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'groupe',[],Groupe},
       {'IdOption',[],IdOption},
       Complements,
       {'TypeOffre',[],TypeOffre},
       {'CompOffre',[],CompOffre}
      ]}].

%% +type encode(RequestTitle::atom(),CanalSouscription::, _Msisdn::string(),Groupe::string(), IdOption::,
%%              CompOption1::,CompOption2::,CompOption3::) ->
%%                 list().
%%%% encode/7
encode(RequestTitle,CanalSouscription,"+"++_Msisdn,Groupe,IdOption,CompOption1,CompOption2,CompOption3) ->
    case {CompOption1,CompOption2,CompOption3} of
	{"","",""} ->
	    Complements = {};
	{_,"",""} ->
	    Complements = {'CompOption1',[],CompOption1};
	{_,_,""} ->
	    Complements = {'CompOption1',[],CompOption1},{'CompOption2',[],CompOption2};
	{_,_,_} ->
	    Complements = {'CompOption1',[],CompOption1},{'CompOption2',[],CompOption2},{'CompOption3',[],CompOption3}
    end,
    
    [{RequestTitle,
      [{xmlns,"http://..."}],
      [{'idCanalSouscr',[],CanalSouscription},
       {'msisdn',[],_Msisdn},
       {'groupe',[],Groupe},
       {'IdOption',[],IdOption},
       Complements
      ]}].

%%%%%%%%%%%%%%%%%%%%%%%%%%% SOAPLIGHT callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type decode_by_name(atom(),list()) ->
%%                 
%%%% This is a callback function called by soaplight.erl
decode_by_name(Name,Value)->
    {Name,Value}.


%% +type decode_by_name(RequestTitle::atom(),List::list()) ->
%%                 tuple().
%%%% Function to be validated
%%%% The aim of this function is to output a tuple containing only the values 
%%%% corresponding to the field of the answer of an xml request
%%%% List is in the format [{'title', Value}]
values_from_answer(RequestTitle, Answer) ->
    values_from_answer(RequestTitle, Answer, []).    

values_from_answer(RequestTitle, [], Answer) ->
    list_to_tuple(RequestTitle ++ Answer);  
values_from_answer(RequestTitle, [Tuple|Tail], Acc) ->
    case Tuple of
	{Title, Value} ->
	    values_from_answer(RequestTitle, Tail, Acc ++ Value );
	_ -> {}
    end.
    
%% +type build_record(atom(),list()) ->
%%                 
%%%% This is a callback function called by soaplight.erl
build_record('Header',Value)->
    [];
 
build_record(Name,Value) ->
    {Name,Value}.


%% +type translate(RequestTitle::atom(),Value::atom(), list()) ->
%%                     .
%%%% Translate the request's result status code to explanation defined sms_mms_infos.hrl
translate(RequestTitle,Value,[{Value,RequestTitle,Result}|T]) ->
    Result;
translate(RequestTitle,Value,[{Value,all_request,Result}|T]) ->
    Result;
translate(RequestTitle,Value,[_|T]) ->
     translate(RequestTitle,Value,T);
translate(RequestTitle,Value,[]) ->
     slog:event(warning,?MODULE,unknown_translation,{'status',Value}),
     {error,undefined}.
 
translate(Value,{Table_name,Table}) ->
    case lists:keysearch(Value,1,Table) of
	{value,{_,Found}} -> Found;
	_ ->
	    slog:event(warning,?MODULE,unknown_translation,{Table_name,Value}),
	    undefined
    end.

% decode_list_options(Value) ->
%     decode_list_options(Value,[]).

% decode_list_options([], Acc) ->
%     Acc;
% decode_list_options( [{'IdOption',Id},
% 		      {'CompOption1',CompOption1},
% 		      {'CompOption2',CompOption2},
% 		      {'CompOption3',CompOption3},
% 		      {'Facturation',Facturation},
% 		      {'Promo',Promo},
% 		      {'DureePromo',DureePromo}|Tail], Acc) ->
%     NewAcc = Acc++ [{'SMIoption',Id,CompOption1,CompOption2,CompOption3,Facturation,Promo,DureePromo,[],[]}],
%     decode_list_options(Tail,NewAcc);
% decode_list_options( [{'IdOption',Id},
% 		      {'Libelle',Libelle},
% 		      {'TypeRub',TypeRub}|Tail] ,Acc) ->
%     SMIOption = #'SMIoption'{id=Id,libelle=Libelle,typeRub=TypeRub},
%     NewAcc = Acc++ [SMIOption],
%     decode_list_options(Tail,NewAcc);
% decode_list_options( [{'IdOption',Id}|Tail] ,Acc) ->
%     SMIOption = #'SMIoption'{id=Id},
%     NewAcc = Acc++ [SMIOption],
%     decode_list_options(Tail,NewAcc);
% decode_list_options([{'ListeOption', Option}| Tail],Acc) ->
%     decode_list_options(Option++Tail, Acc);

% decode_list_options([_|Tail],Acc) ->
%     decode_list_options(Tail,Acc).

analyze_result({'SMIresiliationResponse',Infos})->
    Status = case lists:keysearch(status,1,Infos) of
		 {value,{status,Status_}} -> Status_;
		 _ -> not_found
	     end,

    [Status];            


analyze_result({'SMIsouscriptionResponse',Infos})->
    Status = case lists:keysearch(status,1,Infos) of
		 {value,{status,Status_}} -> Status_;
		 _ -> not_found
	     end,
    [Status];    

analyze_result({'SMImodificationResponse',Infos})->
    Status = case lists:keysearch(status,1,Infos) of
		 {value,{status,Status_}} -> Status_;
		 _ -> not_found
	     end,
    [Status];     

analyze_result({'SMIlisteOptionsResponse',Infos})->

    Status = case lists:keysearch(status,1,Infos) of
		 {value,{status,Status_}}-> Status_;
		 _-> not_found
	     end,

    CodeOffre= case lists:keysearch(codeOffre,1,Infos) of
		   {value,{codeOffre,CodeOffre_}}-> CodeOffre_;
		   _-> not_found
	       end,

    ControleParental= case lists:keysearch(controleParental,1,Infos) of
			  {value,{controleParental,ControleParental_}}-> ControleParental_;
			  _ -> not_foundElse
		      end,

    CodeTac= case lists:keysearch(codeTac,1,Infos) of
		 {value,{codeTac,CodeTac_}}-> CodeTac_;
		 _ -> not_found
	     end,

    AbonneConnu = case lists:keysearch(abonneConnu,1,Infos) of
		      {value,{abonneConnu,AbonneConnu_}}->AbonneConnu_ ;
		      _ -> not_found
		  end,

    ClasseImage= case lists:keysearch(classeImage,1,Infos) of
		     {value,{classeImage,ClasseImage_}}->ClasseImage_ ;
		     _ -> not_found
		 end,

    ClasseVideo= case lists:keysearch(classeVideo,1,Infos) of
		     {value,{classeVideo,ClasseVideo_}}-> ClasseVideo_;
		     _ -> not_found
		 end,

    CompatAlertVideo= case lists:keysearch(compatAlertVideo,1,Infos) of
			  {value,{compatAlertVideo,CompatAlertVideo_}}->CompatAlertVideo_ ;
			  _ -> not_found
		      end,

    NbOptionsSouscrites = case lists:keysearch(nbOptionsSouscrites,1,Infos) of
			      {value,{nbOptionsSouscrites,NbOptionsSouscrites_}}->NbOptionsSouscrites_ ;
			      _ -> not_found
			  end,

    SuspEnvoiMms = case lists:keysearch(suspEnvoiMms,1,Infos) of
		       {value,{suspEnvoiMms,SuspEnvoiMms_}}->SuspEnvoiMms_ ;
		       _ -> not_found
		   end,

    Opt_params= case lists:keysearch(listSouscrOption,1,Infos) of
		    {value,{listSouscrOption,Params}}-> make_opt_params(Params,[]);
		    _ -> slog:event(trace,?MODULE,no_opt)
		end,
    [Status,CodeOffre,ControleParental,CodeTac,AbonneConnu,
     ClasseImage,ClasseVideo,CompatAlertVideo,NbOptionsSouscrites,
     SuspEnvoiMms,Opt_params];   

analyze_result({'SMIlisteOptionsSouscritesResponse',Infos})->
    {value,{status,Status}}= lists:keysearch(status,1,Infos),
    Opt_params= case lists:keysearch(listSouscrOptionSouscrites,1,Infos) of
		    {value,{listSouscrOptionSouscrites,Params}}-> make_opt_params(Params,[]);
		    Else -> slog:event(trace,?MODULE,no_opt)
		end,
    [Status,Opt_params];    

analyze_result({'SMIsouscriptionResponse',Infos})->
    {value,{status,Status}}= lists:keysearch(status,1,Infos),
    [Status];    

analyze_result({error, Reason})-> 
    Reason;

analyze_result(Infos)-> 
    Infos.


make_opt_params([],List_Opt_record)->
    List_Opt_record;
make_opt_params([{souscOption,Opt}|Params],Tail)->
    Opt_record_filled=pbutil:pairs_to_record(sms_mms_option_params,
					     [idOption,
					      tarif,
					      idTarif,
					      tarifHorsPromo,
					      idtarifHorsPromo,
					      renouvellement,
					      uniteRenouvellement,
					      typeFacturation,
					      typeFacturationHorsPromo,
					      ordre,
					      libOption,
					      descOption,
					      presOption,
					      flagOptionSouscrite,
					      idCompOption,
					      lidCompOption,
					      codeCompOption,
					      ordreComOption],Opt), 
    make_opt_params(Params, [Opt_record_filled|Tail]).
