-module(oto_request).

-export([request/2]).

-export([ping_send/0,ping_expect/1]).   %%%%% For interface MQSeries

-export(['#xml-inheritance#'/0]).
-export(['#root#'/4,
	 '#element#'/5,
	 '#text#'/1]).
-import(xmerl_lib, [markup/3, empty_tag/2, export_text/1]).

-include("../../pservices_orangef/include/one2one.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../xmerl/include/xmerl.hrl").

%%% make request to one2one
%% +type request(string() | remontee_stat())-> 
%%                {ok,process_event_resp()} | {ok,stats_sent} | 
%%                {no_answer,term()} | {malformed_resp,term()} |
%%                {unexpected_error,term()}.
request(#remontee_stat{}=Stats, PACKAGE_VALUE) ->
    T0 = pbutil:unixmtime(),
    Request = make_remontee_stat(Stats, PACKAGE_VALUE),
    %% io:format("O2O sending stats:~n~s~n",[Request]),
    T1 = pbutil:unixmtime(),
    Max_request_time=pbutil:get_env(pfront_orangef,oto_time_out),
    case catch mqseries_router:request_no_resp(Request,[oto],Max_request_time)
	of
	ok ->
	    T2 = pbutil:unixmtime(),
	    slog:stats(perf,?MODULE,stat_resp_time,T2 - T1),
	    slog:event(trace,?MODULE,oto_stats_result),
	    {ok, stats_sent};
	{error,Reason} ->
	    slog:event(warning,?MODULE,error, {Reason, PACKAGE_VALUE}),
	    {no_answer,Reason};
	{'EXIT',Reason} ->
	    slog:event(warning,?MODULE,no_answer_stats, {Reason, PACKAGE_VALUE}),
	    {no_answer,Reason}
    end;
request(MSISDN, PACKAGE_VALUE) ->
    T0 = pbutil:unixmtime(),
    Request = make_demande_calcul(MSISDN, PACKAGE_VALUE),
    %% io:format("O2O sending : ~p~n",[Request]),
    %% io:format("O2O sending offer demand:~n~s~n",[Request]),
    T1 = pbutil:unixmtime(),
    Max_request_time=pbutil:get_env(pfront_orangef,oto_time_out),
    case catch mqseries_router:request(Request,[oto], 
				       Max_request_time,
				       2*Max_request_time) of
	{ok, Response} ->
	    T2 = pbutil:unixmtime(),
	    slog:stats(perf,?MODULE,resp_time,T2 - T1),
	    %% io:format("O2O received:~n~s~n",[Response]),
	    case catch read_process_event_resp(Response,MSISDN, PACKAGE_VALUE) of
		{ok,Resp} ->
		    T3 = pbutil:unixmtime(),
		    slog:stats(perf,?MODULE,treatment_time,T3 - T0),
		    slog:event(trace,?MODULE,oto_result,Resp),
		    {ok, Resp};
		{resp_with_error_code,{MSISDN,"03"}} ->
		    slog:event(trace,?MODULE,resp_no_offer,{{MSISDN,"03"},PACKAGE_VALUE}),
		    {resp_with_error_code,{MSISDN,"03"}};
		{resp_with_error_code,ErrorCode} ->
		    slog:event(warning,?MODULE,resp_with_error_code,{ErrorCode,PACKAGE_VALUE}),
		    {resp_with_error_code,ErrorCode};
		{resp_with_wrong_numdossier,GotExpected} ->
		    slog:event(warning,?MODULE,
			       resp_with_wrong_numdossier,{GotExpected,PACKAGE_VALUE}),
		    {resp_with_wrong_numdossier,GotExpected};
		{'EXIT',{malformed_resp,Details}} -> 
		    slog:event(failure,?MODULE,malformed_resp,{Details,PACKAGE_VALUE}),
		    {malformed_resp,Details};
		Error ->
		    slog:event(internal,?MODULE,unexpected_error,{Error,PACKAGE_VALUE}),
		    {unexpected_error,Error}
	    end;
	{error,Reason} ->
	    slog:event(warning,?MODULE,error,{Reason,PACKAGE_VALUE}),
	    {no_answer,Reason};
	{'EXIT',Reason} ->
	    slog:event(failure,?MODULE,o2o_no_answer, {Reason,PACKAGE_VALUE}),
	    {no_answer,Reason};
	Other ->
	    slog:event(failure,?MODULE,o2o_unexpected, {Other,PACKAGE_VALUE}),
	    {no_answer,Other}
    end.


%%%%%%%%%% MQSeries API PING %%%%%%%%%%%%%%%%%%%%

%%   TO DO   %%

%% +type ping_send() -> term().
ping_send() -> "ONE2ONE".

%% +type ping_expect(Data::string()) -> ok | exit(Reason).
ping_expect(Data) -> 
    case pbutil:sscanf("%5d",Data) of
	{[1],_} -> ok;
	Other -> exit({bad_ping,1,Other})
    end.

%%% XML requests builder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type make_demande_calcul(string(), string()) -> xmlElement().
make_demande_calcul(MSISDN, PACKAGE_VALUE) ->	
    NumDossier = format(MSISDN),
    {ParentsToFields,NextPos,Acc} =
	make_process_event(PACKAGE_VALUE,?DEMANDE_DE_CALCUL),
    {_,NextPos1,Acc1} =
	add_field(ParentsToFields,1,?IDCANAL_NAME,?IDCANAL_VALUE,Acc),
    {_,_,Acc2} =
	add_field(ParentsToFields,NextPos1,?NUMDOSSIER_NAME,NumDossier,Acc1),
    RawRequest = build_tree(lists:reverse(Acc2)),
    lists:flatten(xmerl:export(RawRequest,oto_request)).

%% +type make_remontee_stat(remontee_stat(), string()) -> xmlElement().
make_remontee_stat(
  #remontee_stat{idsession=IdSession,numdossier=NumDossier,
		 code=IdOffre,heureecoute=HeureEcoute,
		 indecoute=IndEcoute,dureemessage=DureeMessage,
		 dureeecoute=DureeEcoute,canalabout=CanalAbout,
		 indactivation=IndActivation,param1=Param_1,
		 param2=Param_2,param3=Param_3}=Stats,
  PACKAGE_VALUE) ->
    {Par2Fields,NextPos,Acc} =
	make_process_event(PACKAGE_VALUE,?REMONTEE_STAT),
    FieldsToAdd = [
		   {?IDCANAL_NAME,      ?IDCANAL_VALUE},
		   {?IDSESSION_NAME,    IdSession},
		   {?NUMDOSSIER_NAME,   NumDossier},
		   {?ID_OFFRE_NAME,     IdOffre},
		   {?HEURE_ECOUTE_NAME, HeureEcoute},
		   {?INDECOUTE_NAME,    IndEcoute},
		   {?DUREE_MESSAGE_NAME,DureeMessage},
		   {?DUREE_ECOUTE_NAME, DureeEcoute},
		   %% Optional (and unused) params have to be sent
		   {?CANAL_ABOUT_NAME,  CanalAbout},
		   {?INDACTIVATION_NAME,IndActivation},
		   {?PARAM1_NAME,       Param_1},
		   {?PARAM2_NAME,       Param_2},
		   {?PARAM3_NAME,       Param_3}
		  ],
    Fun = fun({Tag,Value},{_,NextPos1,Acc1}) ->
		  add_field(Par2Fields,NextPos1,Tag,Value,Acc1)
	  end,
    {_,_,Acc2} = lists:foldl(Fun,{Par2Fields,NextPos,Acc},FieldsToAdd),

    RawRequest = build_tree(lists:reverse(Acc2)),
    lists:flatten(xmerl:export(RawRequest,oto_request)).

%% +type make_process_event(string(),string()) -> xmlBuilder().
make_process_event(PackageName,EventName) ->
    {ParentsToRoot, _, XMLRoot} = 
	create_xml_root(?PROCESS_EVENT_TAG),
    %%	io:format("XML Root : ~p~n",[print(XMLRoot)]),
    {_,NextPos1,ProcessEvent1} = 
	add_element_with_text(ParentsToRoot,1,
			      ?PACKAGE_TAG,PackageName,
			      XMLRoot),
    %% io:format("ProcessEvent1 : ~p~n",[print(ProcessEvent1)]),
    {_,NextPos2,ProcessEvent2} = 
	add_element_with_text(ParentsToRoot, NextPos1,
			      ?EVENT_TAG,EventName,
			      ProcessEvent1),
    %% io:format("ProcessEvent2 : ~p~n",[print(ProcessEvent2)]),
    {ParentsToFields,NextPos3,ProcessEvent3} = 
	add_xml_element(ParentsToRoot, NextPos2,?FIELDS_TAG,ProcessEvent2).

%% +type format(msisdn()) -> msisdn().
format(MSISDN) ->
    MSISDN.

is_equal(NumDossier,MSISDN) ->
    NumDossierT = string:right(NumDossier,9),
    MSISDNT = string:right(MSISDN,9),
    NumDossierT == MSISDNT.
       

%%% XML encode / decode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This XML encoder API works in two steps :
%%% Step one : create root node, and add xml elements and text to the list
%%% Step two : build the final xml tree
%%%
%%% - It is based on the xmerl tools and records
%%% - The "builder functions" are create_xml_root/1, add_xml_element/4, 
%%%   add_xml_text/4, add_carriage_return/3, add_element_with_text/5 and 
%%%   specific for one2one add_field/5
%%% - The result of the builder functions are an xmlBuilder composed of :
%%%    1. a list of parents : [{Tag,Pos}], which identifies uniquely the 
%%%       position in the tree of the xml element created by the function
%%%    2. a position : integer(), which is the first available position to 
%%%       give to a new xml element having the same father as the xml element 
%%%       created in the function (this allows to create more than one element
%%%       within a function)
%%%    3. an accumulator [xmlElement()|xmlText()] : which is the list (of 
%%%       depth one) of created xml elments. This list is passed to the 
%%%       different builder functions, and finally, after being reversed, 
%%%       passed to build_tree/1.

%%% Builder functions %%%
%% +type create_xml_root(atom()|string()) -> xmlBuilder().
create_xml_root(Name) ->
    Tag = case Name of 
	      X when atom(X) -> X;
	      X when list(X) -> list_to_atom(X)
	  end,
    Root = #xmlElement{ name       = Tag,
			pos        = 1
		       },
    {[{Tag,1}],
     2,
     [Root]}.

%% +type add_xml_element([parent()],integer(),atom()|string(),[xmlElement()|xmlText()]) -> xmlBuilder().
add_xml_element(Parents,Pos,Name,Acc) ->
    {_,NextPos ,Acc1} = 
	add_carriage_return(Parents,Pos,Acc),
    Tag = case Name of 
	      X when atom(X) -> X;
	      X when list(X) -> list_to_atom(X)
	  end,
    Element = #xmlElement{ name       = Tag,
			   parents    = Parents,
			   content    = [],
			   pos        = NextPos
			  },
    { [ {Tag, NextPos}   | Parents ],
      NextPos +1,
      [ Element	| Acc1 ]}.

%% +type add_xml_text([parent()],integer(),string(),[xmlElement()|xmlText()])
%%     -> xmlBuilder().
add_xml_text(Parents,Pos,Text,Acc) ->
    RealText = format_text(Text),
    Element = #xmlText{parents = Parents,
		       pos     = Pos,
		       value   = RealText},

    { Parents,
      Pos +1,
      [ Element	| Acc ]}.

%% +type add_carriage_return([parent()],integer(),[xmlElement()|xmlText()]) 
%%     -> xmlBuilder().
add_carriage_return(Parents,Pos,Acc) ->
    add_xml_text(Parents,Pos,"\n" ++ indent(length(Parents)-1),Acc).

%% +type add_element_with_text(
%%            [parent()],integer(),atom(),string(),[xmlElement()|xmlText()])
%%         -> xmlBuilder().
add_element_with_text(Parents,Pos,Tag,Text,Acc) ->
    {ParentsToE, NextPos1, Acc1} = 
	add_xml_element(Parents,Pos,Tag,Acc),
    {_, _, Acc2} = 
	add_xml_text(ParentsToE,1,Text,Acc1),
    {  ParentsToE,
       NextPos1,
       Acc2}.

%%% Tree builder functions %%%

%% +type build_tree([xmlElement()|xmlText()]) -> xmlElement().
build_tree([H|T]) ->
    Root = H#xmlElement{content = getChilds(H,T,[])}.

%% +type getChilds(
%%            xmlElement(),[xmlElement()|xmlText()],[xmlElement()|xmlText()])
%%        -> [xmlElement()|xmlText()].
getChilds(Father,[],[]) ->
    %% leaf, no child -> keep content unchanged
    Father#xmlElement.content;
getChilds(Father,[],Acc) ->
    %% no more childs
    lists:reverse(Acc);
getChilds(Father=#xmlElement{parents=FParents,pos=Pos,name=Tag},
	  [H=#xmlText{parents = Parents}|T],
	  Acc) ->
    case [{Tag,Pos} | FParents] of
	Parents ->
	    %%NewChild = build_tree([H|T]),
	    getChilds(Father,T,[H|Acc]);
	_ ->
	    getChilds(Father,T,Acc)
    end;
getChilds(Father=#xmlElement{parents=FParents,pos=Pos,name=Tag},
	  [H=#xmlElement{parents = Parents}|T],
	  Acc) ->
    case [{Tag,Pos} | FParents] of
	Parents ->
	    NewChild = build_tree([H|T]),
	    getChilds(Father,T,[NewChild|Acc]);
	_ ->
	    getChilds(Father,T,Acc)
    end.

%% +type format_text(term()) -> string().
format_text(Text) when atom(Text) ->
    atom_to_list(Text);
format_text(Text) when integer(Text) ->
    integer_to_list(Text);
format_text(Text) ->
    lists:flatten(Text).

%% +type indent(integer()) -> string().
indent(Number) -> string:chars(32,Number*2).

%%% Specific o2o%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type add_field(
%%      [parent()],integer(),atom(),string(),[xmlElement()|xmlText])
%%   -> xmlbuilder().
add_field(Parents, Pos, Name, Value, Acc) ->
    {ParentsToField, PosAfterField, Acc1} = 
	add_xml_element(Parents,Pos,?FIELD_TAG,Acc),
    {_, PosAfterName, Acc2} =
	add_element_with_text(ParentsToField,1,?NAME_TAG,Name,Acc1),
    {_, _, Acc3} =
	add_element_with_text(ParentsToField,PosAfterName,
			      ?VALUE_TAG,Value,Acc2),
    {  ParentsToField,
       PosAfterField,
       Acc3}.

%%% XML responses reader %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type read_process_event_resp(string(),string(),string()) -> 
%%       {ok,process_event_resp()} | exit({malformed_resp,atom()}) |
%%       {resp_with_error_code,string()} |
%%       {resp_with_wrong_numdossier,{got,string(),expected,string()}}.
read_process_event_resp(Resp,MSISDN, PACKAGE_VALUE) ->
    {Head,Root} = xmerl_scan:string(Resp),
    case Root#xmlElement.name of
	?PROCESS_EVENT_RESP_TAG -> ok;
	_ -> exit({malformed_resp,not_a_resp})
    end,
    %% io:rmat("Root:~n~p~n",[Root]),
    Attributes = xmerl_xpath:string("./offers/offer[1]/attributes/*[name]",
				    Root),
    L = length(Attributes),
    if
	%% at least IDSESSION and CODERETOUR, IDOFFRE presence is optional
	%% so expecting 2 or 3 attributes
	L==2;L==3 -> ok;
	true -> exit({malformed_resp,wrong_nb_of_attributes})
    end,
    ReadAttributes = readAttributes(Attributes),

    NumDossier = readAttribute(?NUMDOSSIER_NAME,ReadAttributes),
    IdSession = readAttribute(?IDSESSION_NAME,ReadAttributes),
    CodeRetour = readAttribute(?CODERETOUR_NAME,ReadAttributes),
    Test = is_equal(NumDossier,MSISDN),

    if not Test ->
	    slog:event(failure,?MODULE,resp_with_wrong_numdossier,
		       {got,NumDossier,expected,MSISDN}),
	    {resp_with_wrong_numdossier,{got,NumDossier,expected,MSISDN}};
       CodeRetour =/= "00" ->
	    %% "00" ok, 
	    %% "01" Moteur RT HS, "02" Client inconnu, "03" pas d'offre
	    slog:count(count, ?MODULE, {oto_error_code,CodeRetour, PACKAGE_VALUE}),
	    {resp_with_error_code,{NumDossier,CodeRetour}};
       true ->
            CodeOffre = getText("offers/offer[1]/name/node()",Root),
	    {ok,#process_event_resp{code=CodeOffre,
				    numdossier=NumDossier,
				    idsession=IdSession,
				    codeerreur=CodeRetour}}
    end.

%% +type getText(string(),xmlElement()) -> string().
getText(Str_xPath,Root) ->
    case xmerl_xpath:string(Str_xPath,Root) of
	[TextNode|_] -> string:strip(TextNode#xmlText.value);
	_            -> exit({malformed_resp, {Str_xPath, Root}})
    end.

%% +type readAttributes([xmlElement()]) -> [attribute()].
readAttributes(Attributes) ->
    readAttributes(Attributes,[]).

%% +type readAttributes([xmlElement()],[attribute()]) -> 
%%                                                  [attribute()].
readAttributes([],Acc) ->
    Acc;
readAttributes([H=#xmlElement{name=?ATTRIBUTE_TAG}|T],Acc) ->
    Name = getText("name/node()",H),
    Value = getText("value/node()",H),
    readAttributes(T,[{Name,Value}|Acc]);
readAttributes([H|T],Acc) ->
    readAttributes(T,Acc).

%% +type readAttribute(string(),[attribute()]) -> string() | undefined.
readAttribute(Tag,Attributes) ->
    case lists:keysearch(Tag,1,Attributes) of
	{value,{_,Val}} -> Val;
	_ -> undefined
    end.

%% Generic Xmerl Callbacks

'#xml-inheritance#'() -> [].

%% The '#text#' function is called for every text segment.
'#text#'(Text) ->
    export_text(Text).

%% The '#root#' tag is called when the entire structure has been
%% exported. It does not appear in the structure itself.
'#root#'(Data, Attrs, [], E) ->
    ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>", Data].

%% The '#element#' function is the default handler for XML elements.
'#element#'(Tag, [], Attrs, Parents, E) ->
    empty_tag(Tag, Attrs);
'#element#'(Tag, Data, Attrs, Parents, E) ->
    markup(Tag, Attrs, Data).


%%% XML debug %%%

%% +type print([xmlElement()|xmlText()|string()]) -> string().
print([]) ->
    [];
print([E=#xmlElement{name = N, parents = P, pos = Pos, content = C}|T]) ->
    [{N,Pos,print(P),print(C)} | print(T)];
print([E=#xmlText{parents = P, pos = Pos, value = C}|T]) ->
    [{text,Pos,print(P),print(C)} | print(T)];
print([{Tag,Pos}|T]) ->
    [{Tag,Pos} | print(T)];
print(#xmlElement{name = N, parents = P, pos = Pos, content = C}) ->
    [{N,Pos,print(P),print(C)}];
print(Term) ->
    io_lib:format("~s",[Term]).

test() ->
    read_process_event_resp(
      "<ProcessEventResponse>\n"++
      "   <offers>\n"++
      "      <offer>\n"++
      "         <name> valeur[#IDOFFRE]  </name>\n"++
      "         <imagePath> </imagePath>\n"++
      "         <attributes>\n"++
      "            <attribute>\n"++
      "               <name> NUMDOSSIER   </name>\n"++
      "               <value> 0620664390   </value>\n"++
      "            </attribute>\n"++
      "            <attribute>\n"++
      "               <name>IDSESSION</name>\n"++
      "               <value>valeur[#IDSESSION]</value>\n"++
      "            </attribute>\n"++
      "            <attribute>\n"++
      "               <name>CODERETOUR</name>\n"++
      "               <value>valeur[#CODERETOUR]</value>\n"++
      "            </attribute>\n"++
      "         </attributes>\n"++
      "      </offer>\n"++
      "   </offers>\n"++
      "</ProcessEventResponse>",
      "+33620664390",
      "Package").

%% +private.
%% +deftype parent() = {atom(),integer()}.
%% +deftype xmlBuilder() = {[parent()],integer(),[xmlElement()]}.
%% +deftype attribute() = {string(),string()}.
