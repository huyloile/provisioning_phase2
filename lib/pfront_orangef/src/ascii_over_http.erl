-module(ascii_over_http).

-export([request/7]).

-include("../../pfront/include/pfront.hrl").
-include("../../pfront/include/httpclient.hrl").
-include("../../pdist/include/generic_router.hrl").

%% +deftype values() = [{Label::string(),Value::term()}].
%% +deftype dec_values() =[{Label::string(),Format::string()}].

%% +type request(URL::string(),V_Host::string(),Port::integer(),Routing::atom(),
%%               P_Encode::values(),P_Decode::dec_values(),Timeout::integer()) -> 
%%  {ok, values()} | {statut, term()}.
request(URL, V_Host, Port, Routing, P_ENCODE, P_DECODE, Timeout) ->
    Bod = encode(P_ENCODE,[]),
    Req=
	#http_request{ routing = [Routing],
		       host=V_Host, 
		       port = Port,
		       method=post, 
		       url=URL, 
		       version="1.1",
		       headers=[ {"Accept", "*/*"} ],
		       body = lists:flatten(Bod),
		       timeout = Timeout
		      },
    slog:event(interface, ?MODULE, request, Req),
    T0 = oma:unixtime(),
    case catch generic_router:routing_request(?HTTPClient_Module,Req, Timeout) of
	{ok, {ok,_,200,_,Head,Body}}->
	    slog:event(interface,?MODULE,response_ok,Body),
	    slog:delay(perf,?MODULE,resp_time,T0),
	    decode_body(Body,P_DECODE);
	{'EXIT',{timeout,_}}->
	    slog:event(interface,?MODULE,response_ko,timeout),
	    {statut,timeout};
	Else ->
	    slog:event(interface,?MODULE,response_ko,Else),
	    {statut,Else}
    end.
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Encodage /Decodage %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% +type encode([values()],string())-> string().
encode([{Arg,Val}|[]],Acc) ->
    Acc2=Acc++Arg++"="++to_list(Val),
    Acc2;			
encode([{Arg,Val}|T],Acc)->
    Acc2=Acc++Arg++"="++to_list(Val)++"&",
    encode(T,Acc2).

%% +type to_list(term())-> string().
to_list(I) when integer(I)->
    integer_to_list(I);
to_list(I) when list(I)->
    I;
to_list(undefined)->
    "";
to_list(I) when atom(I)->
    atom_to_list(I).

%%%% Body Format => STATUT=0000;Name=Value;Name2=Value;....
%%%%                STATUT=0401;STATUT_LINELLE=Description
%%%%                STATUT=XXXX

%% +deftype cbhttp_format()= {Name::string(),Format::string()}.

%% +type decode_body(string(),[cbhttp_format()])-> 
%%                  {ok,[Value]}
%%               |  {statut, integer()}.
decode_body(Body,Response)->
    Body2= case pbutil:split_at($\n, Body) of
	       {B,Rest}->
		   B;
	       not_found->
		   Body
	   end,   
    L_var=string:tokens(Body2,";"),
    Var_Lists=
	lists:map(fun(P)->
			  {Name,Value} =
			      case string:tokens(P,"=") of
				  [N,V]->
				      {N,V};
				  [N|V]->
				      {N,V}
			      end,
			  {Name,Value}
		  end,L_var),
    format_response(Var_Lists,Response).
    
%% +type format_response([values()],[dec_values()])-> {ok, [term()]} | 
%%                                                 {statut,integer()}.
format_response([{"STATUT",Val}|T],Resp)->
    case pbutil:sscanf("%d",Val) of
	{[X],Rest} when X==0->
	    {ok,format_response(T,Resp,[])};
	{[X],Rest} ->
	    {statut,X}
    end.

%% +type format_response([values()],[dec_values()],term())-> term().
format_response([{Name,Val}|T],Resp,Acc)->
    case lists:keysearch(Name,1,Resp) of
	{value, {Name,{mult,Format}}}->
	    Vals = string:tokens(Val,":"),
	    Valds=lists:map(fun(Valx)->
				    {[Val_d],Rest}=pbutil:sscanf(Format,Valx),
				    Val_d
			    end,Vals),
	    format_response(T,Resp,Acc++[Valds]);
	{value, {Name,Format}}->
	    {[Val_d],Rest}=pbutil:sscanf(Format,Val),
	    format_response(T,Resp,Acc++[Val_d]);
	false ->
	    slog:event(warning,?MODULE,unknown_variable,Name),
	    format_response(T,Resp,Acc)
    end;
format_response([],Resp,Acc) ->
    Acc.

