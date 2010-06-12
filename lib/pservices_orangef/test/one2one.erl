%% Simulation (très approximative) de l'interface ONE2ONE
%% Behaves like a port process with an additional connection
%% establishment phase.

-module(one2one).
-export([run/0]).
-export([start/0, start_reliable/0]).

-export([put_fake/0,get_fake/0]).

-export([build_resp/2]).

-include("../../../lib/xmerl/include/xmerl.hrl").
-include("../../../lib/pservices_orangef/include/one2one.hrl").

-define(PASSWORD,"1234").

start() -> proc_lib:start(?MODULE, run, []).

start_reliable() -> proc_lib:start(?MODULE, run_reliable, []).

run() ->
    spawn(?MODULE,put_fake,[]),
    spawn(?MODULE,get_fake,[]),
    proc_lib:init_ack({ok, self()}),
    process_flag(trap_exit, true).



put_fake() ->
    global:register_name(o2o_put_fake, self()),
    available_put().

get_fake() ->
    global:register_name(o2o_get_fake, self()),
    available_get().


available_get() ->
    receive
	{_, {command,_}} ->
%%%% md structure not used for erlang_process !!!
	    available_get();
	{From,Message} ->
	    Message2 = term_to_binary({get,Message}),
	    From!{self(),{data,Message2}},
	    available_get();
	X ->
	    io:format("X message get O2O ~p~n",[X])
    after 1000 ->
	    available_get()
    end.

available_put() ->
    receive
	{_,{command,"E"}} ->
	    receive
		{From,{command,"T"}} ->
		    %% terminate command
		    send_to_o2o_client("T"),
		    global:unregister_name(o2o_put_fake, self()),
		    ok;
		{From,{command,Message}} ->
		    From ! {self(),
			    {data,term_to_binary({put,0,"null"})}}, 
		    %% ack mqseries
		    spawn_link(?MODULE,build_resp,[From,Message]),
		    available_put()
	    after 1000 ->
		    exit(no_message_after_E)
	    end
    after 2000 ->
	    erase(), %%%% delete all value stored for test
	    available_put()
    end.

build_resp(From,Message) ->
    {Head,Root} = xmerl_scan:string(lists:flatten(Message)),

    %% check if what is sent is a ProcessEvent, else exit
    case Root#xmlElement.name of
	?PROCESS_EVENT_TAG -> ok;
	_ -> exit(?MODULE,not_a_process_event)
    end,

    %% format a response
    case catch response(Root) of
	{'EXIT',Reason} ->
	    io:format("WARNING : unexpected exit ~p~n",
		      [Reason]),
	    ok;
	no_resp ->
	    %% for Stats, nothing is sent back
	    ok;
	Resp ->
	    receive after 200 -> ok end,
	    %% for DemandeDeCalcul, send a response
	    pbutil:whereis_name(o2o_get_fake)!{From,Resp}
    end.

send_to_o2o_client(Message)->
    case catch pbutil:whereis_name(fake_o2o_client) of
	{'EXIT',_} -> 
	    io:format("WARNING : no_o2o_client_listening ~n",[]);
	P ->
	    P ! {fake_o2o_stats, Message}
    end.

response(Root) ->
    Event = getText("event/node()",Root),
    Fields = xmerl_xpath:string("./fields/*[name]",Root),
    ReadFields = readFields(Fields),
    NumDossier = readField(?NUMDOSSIER_NAME,ReadFields),
    case Event of
	?REMONTEE_STAT ->

	    IDOffre = readField(?ID_OFFRE_NAME,ReadFields),
	    IndEcoute = readField(?INDECOUTE_NAME,ReadFields),
	    IndSouscription = readField(?INDACTIVATION_NAME,ReadFields),
	    %% nothing to send back through MQ Series, but eventually inform
	    %% a listening client of contents of sent stats
	    send_to_o2o_client({NumDossier, IDOffre, IndEcoute, IndSouscription}),
	    no_resp;
	?DEMANDE_DE_CALCUL ->
	    send_to_o2o_client({NumDossier,computeOffer}),
	    %% check we have right number of "fields" -> 2 else exit
	    case length(Fields) of
		X when X=/=2 -> exit(?MODULE,more_or_less_than_2_fields);
		_ -> ok
	    end,
	    %% the Offer code returned is the last 2 digits of 
	    %% NumDossier (MSISDN)
	    Num = list_to_integer(string:right(NumDossier,2)),
	    Offers = 
		case catch mnesia:dirty_all_keys(?ONE2ONE_OFFER) of
		    {'EXIT',Error} ->
			io:format("Error in accessing offer keys :"
				  " ~p~n",[Error]),
			["offre non trouvée"];
		    [] ->
			io:format("No offer keys~n"),
			["aucune offre"];
		    X1 -> X1
		end,
	    NbOffers = length(Offers),
	    Rem = Num rem NbOffers,
	    IDOffre = case {Rem,Num} of
			  {_,0} -> "not_found"; %% offer 00 not found...
			  {0,_} -> lists:nth(NbOffers,Offers);
			  {X2,_} -> lists:nth(X2,Offers)
		       end,
	    %% The Session ID is also built using last two digits
	    IDSession = "10"++string:right(NumDossier,2),
	    L = length(NumDossier),
	    BeforeBeforeLast = string:sub_string(NumDossier,L-2,L-2),
	    %% If before before last digit equals 
	    %% 1, 2 or 3, CodeRetour = "01", "02" or "03"
	    %% 9, IDOffre = "not_exists" to test offer_not_found
	    %% _, CodeRetour = "00"
	    {CodeRetour,IDOffre1} = 
		case BeforeBeforeLast of
		    Digit when Digit=="1"; Digit=="2"; Digit=="3" ->
			{"0"++BeforeBeforeLast,IDOffre};
		    "9" -> {"00","not_exists"};
		    _ -> {"00",IDOffre}
		end,

	    "<?xml version=\"1.0\"?>
		<ProcessEventResponse>
		<offers>
		<offer>
		<name>"++IDOffre1++"</name>
		<imagePath> </imagePath>
		<attributes>
		<attribute>
		<name>NUMDOSSIER</name>
		<value>"++NumDossier++"</value>
		</attribute>
		<attribute>
		<name>IDSESSION</name>
		<value>"++ IDSession ++"</value>
		</attribute>
		<attribute>
		<name>CODERETOUR</name>
		<value>"++ CodeRetour++"</value>
		</attribute>
		</attributes>
		</offer>
		</offers>
		</ProcessEventResponse>
		"
    end.

%% +type getText(string(),xmlElement()) -> string().
getText(Str_xPath,Root) ->
    case xmerl_xpath:string(Str_xPath,Root) of
	[TextNode|_] -> string:strip(TextNode#xmlText.value);
	[] -> ""
    end.

%% +type readFields([xmlElement()]) -> [field()].
readFields(Fields) ->
    readFields(Fields,[]).

%% +type readFields([xmlElement()],[field()]) -> 
%%                                                  [field()].
readFields([],Acc) ->
    Acc;
readFields([H=#xmlElement{name=?FIELD_TAG}|T],Acc) ->
    Name = getText("name/node()",H),
    Value = getText("value/node()",H),
    readFields(T,[{Name,Value}|Acc]);
readFields([H|T],Acc) ->
    readFields(T,Acc).

%% +type readField(string(),[field()]) -> string() | undefined.
readField(Tag,Fields) ->
    case lists:keysearch(Tag,1,Fields) of
	{value,{_,Val}} -> Val;
	_ -> undefined
    end.

%% +private.
%% +deftype field() = {string(),string()}.
