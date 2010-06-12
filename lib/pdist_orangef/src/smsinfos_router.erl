-module(smsinfos_router).


%% API %%
-export([dprofMediaSVI/2,dprofFactSVI/2,modprofSVI/7]).
-export([tarifSVI/3,dprofrub/3,dprofforfait/3,resSVI/4]).
-export([info/1,dterm/1,term/2,filtreClient/2]).
%% NEW Request MMS Video
-export([dprofMediaSVI/3,modterm/2]).
-export([start_link/1]).
-export([pool_get_attrib/1]).

-define(SERVER,smsinfos_server).
%%%% <h2> Client API </h2>
%%%% Here we just invoke smsinfos_server's client API, with the first
%%%% argument SRV=smsinfos_router.

%% +deftype msisdn() = string().
%% +deftype subscription() = mobi | cmo | postpaid.
%% +deftype facturationtype() = string(). %%%% "A"(abo) or "M"(factu au MT).
%% +deftype media() = sms | mms.
%% +deftype smsinfos_error() =  {status, ErrorCode::integer()} |
%%                              {status, atom()}               |
%%                              {error,{badresponse,term()}}.

%% +type dprofMediaSVI(msisdn(),media())->
%%            {ok, [Result::term()]} |
%%            smsinfos_error().
%%%% demande de profile
%%%% Result = [currency:currency(),IMEI::string(),facturationtype(),
%%%%          [RubId::integer()]].
dprofMediaSVI(MSISDN,Media) ->
    ?SERVER:dprofMediaSVI(?MODULE, MSISDN, Media,all).
%% +type dprofMediaSVI(msisdn(),media(),TypeFlux::atom())->
%%            {ok, [Result::term()]} |
%%            smsinfos_error().
dprofMediaSVI(MSISDN,Media,TypeFlux) ->
    ?SERVER:dprofMediaSVI(?MODULE, MSISDN, Media,TypeFlux).


%% +type dprofFactSVI(msisdn(),media())->
%%            {ok, [Result::term()]} |
%%            smsinfos_error().
%%%% demande de profile
%%%% Result = [currency:currency(),IMEI::string(),
%%%%          [{RubId::integer(),facturationtype()}]].
dprofFactSVI(MSISDN,Media) ->
    ?SERVER:dprofFactSVI(?MODULE, MSISDN, Media).

%% +type modprofSVI(msisdn(),IdServ::integer(),string(),string(),string(),
%%                  subscription(),facturationtype())-> 
%%       {ok, date()} | smsinfos_error().
%%%% modif de profile
modprofSVI(MSISDN,Idserv,Comp_1,Comp_2,Comp_3,Sub,FactType) ->
    ?SERVER:modprofSVI(?MODULE, MSISDN,Idserv, Comp_1, Comp_2, Comp_3,
			  Sub, FactType).

%% +type tarifSVI(msisdn(),Idservice::integer(),facturationtype())-> 
%%            {ok, Prix_PROMO::currency:currency(),PRIX_MAX::currency:currency()} |
%%            smsinfos_error().
%%%% demande de tarifs
tarifSVI(MSISDN,Idservice,Fact_Type) ->
    ?SERVER:tarifSVI(?MODULE, MSISDN, Idservice, Fact_Type).

%% +type dprofrub(msisdn(),Idrub::integer(),media())-> 
%%          {ok, Result::term()} | smsinfos_error().
%%%% demande d'infos sur la rubrique
%%%% Result= [Comp1::string(),Comp2::string(),Comp3::string(),date(),
%%%%          term(),Media2::media()]
dprofrub(MSISDN,Idrub,Media) ->
    ?SERVER:dprofrub(?MODULE, MSISDN, Idrub, Media).

%% +type dprofforfait(msisdn(),Idrub::integer(),media())-> 
%%            {ok, Result::term()} | smsinfos_error().
%%%% demande d'infos sur les forfaits souscripts
%%%% Result = [TypeForfait::facturationtype(),Comp::string(), date(),
%%%%           [RubId::integer()]].
dprofforfait(MSISDN,Idrub,Media) ->
    ?SERVER:dprofforfait(?MODULE, MSISDN, Idrub, Media).

%% +type resSVI(msisdn(),RubID::integer(),facturationtype(),media())-> 
%%           ok | smsinfos_error().
%%%% resiliation de profile
resSVI(MSISDN,Id,FactType,Media) ->
    ?SERVER:resSVI(?MODULE, MSISDN, Id, FactType,Media).

%% +deftype liste_service() = string(). %%%% "LISTESMS" or "LISTEMMS".
%% +type info(liste_service())-> {ok , [term()]} | smsinfos_error().
%%%% liste des service SMS ou MMS (NOT USED).
info(Liste) ->
    ?SERVER:info(?MODULE, Liste).

%% +type dterm(msisdn())-> {ok, TAC::string()} | smsinfos_error().
%%%% demande d'infos terminal
dterm(MSISDN) ->
    ?SERVER:dterm(?MODULE, MSISDN).

%% +type term(msisdn(),TAC::string())-> ok | smsinfos_error().
%%%% Ce Terminal est t'il compatible MMS ?
term(MSISDN,TAC) ->
    ?SERVER:term(?MODULE, MSISDN, TAC).

%% +type modterm(msisdn(),TAC::string())-> ok | smsinfos_error().
%%%% Ce Terminal est t'il compatible MMS ou,et MMS Video
modterm(MSISDN,TAC) ->
    ?SERVER:modterm(?MODULE, MSISDN, TAC).

%% +type filtreClient(msisdn(),Type::integer())-> 
%%                 {ok,integer(),[integer()]} |
%%                 smsinfos_error().
filtreClient(MSISDN,FilterType)->
    ?SERVER:filtreClient(?MODULE,MSISDN,FilterType).

%%%% <h2> Server API </h2>
%% +type start_link([pool_server:worker()]) -> gs_start_result().
start_link(Workers) ->
    Arg = {{?MODULE,pool_get_attrib}, Workers},
    pool_server:start_link({?MODULE, Workers, fun()-> true end}).

%% +deftype smsinfos_request() = {smsinfos_request, string() , Prefix::string(),
%%                                Request::string()}.
%% +type pool_get_attrib(smsinfos_request()) -> [term()].
pool_get_attrib({smsinfos_request, Attr, Prefix, Request}) ->
    Attr.
