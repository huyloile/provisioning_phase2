-module(fake_mipc_vpbx_server).
%% fake to be used for MIPC and VPBX

-export([start/1, loop/1, stop/1, handle_request/3]).
-export([decode_by_name/2,build_record/2]).
-export([init_data/3]).
-export([handle_request_mipc/2,handle_request_vpbx/2]).

-define(debug,false).

%% MIPC / VPBX could be identified from URL, but this makes it easy
handle_request_mipc(Env,Input) ->
    handle_request(fake_mipc_server,Env,Input).
handle_request_vpbx(Env,Input) ->
    handle_request(fake_vpbx_server,Env,Input).

handle_request(ServerName,Env,Input) when atom(ServerName) ->
    ServerName!{self(),Input},
    {Http_code, Response_xml} =
	receive
	    {ServerName,""}->
		{500,soaplight:build_xml([],[],invalidInputException())};
	    {ServerName,[{'SOAP-ENV:Fault',[],Values}]=Response}->
		{500,soaplight:build_xml([],[],Response)};
	    {ServerName,Response}->
		print("fake mipc response:~n~p~n",[Response]),
		{200,soaplight:build_xml([],[],Response)}
	end,
    {Http_code, "application/xml+soap", Response_xml}.    
    

start(ServerName) when atom(ServerName) ->
    stop,
    timer:sleep(500),
    register(ServerName, proc_lib:spawn(?MODULE,loop,
					[{dict:new(),ServerName}])).

stop(undefined) ->
    ok;
stop(Pid) when is_pid(Pid) ->
    Pid ! stop;
stop(ServerName) when atom(ServerName) ->
    stop(whereis(ServerName)).

loop({Accounts,ServerName})->
    receive
	{init_identification,Data}->
	    New_accounts={init_identification,Data},
	    loop({New_accounts,ServerName});
	{init_activate_situation,Data}->
	    New_accounts={init_activate_situation,Data},
	    loop({New_accounts,ServerName});
	{init_get_situation_active,Data}->
	    New_accounts={init_get_situation_active,Data},
            loop({New_accounts,ServerName});
	{Pid,Http_body} ->
	    New_accounts=Accounts,
	    {{New_accounts,ServerName},Response}=
		response({Accounts,ServerName},Http_body),
	    Pid! {ServerName,Response},
	    loop({New_accounts,ServerName});
	 Else->
            print("Else: ~p~n", [Else]);
	stop ->
	    bye
    end.


response({Accounts,ServerName},XmlBody) when is_list(XmlBody)->
    DecodedBody=soaplight:decode_body(XmlBody,?MODULE),
    response({Accounts,ServerName},DecodedBody);

response({{init_activate_situation,Data},ServerName},{activerSituation,_})->
    Accounts={init_activate_situation,Data},
    {{Accounts,ServerName},Data};
response({Accounts,ServerName},{activerSituation,[{_,MSISDN},{_,IdS}]}) ->
    print("fake_mipc_vpbx_server:response/2:MSISDN=~p~n",[MSISDN]),
    print("fake_mipc_vpbx_server:response/2:Accounts=~p~n",[Accounts]),
    %%Situation = dict:fetch(MSISDN,Accounts),
    {{Accounts,ServerName},[{activerSituationResponse,
			     [],[{resultat,[],
				  [{codeRetour,[],"0"},
				   {commentaire,[],"succes"}
				   
				  ]}]}]};

response({{init_identification,Data},ServerName},{consulterInformations,_})->
    Accounts={init_identification,Data},
    {{Accounts,ServerName},Data};
response({Accounts,ServerName},{consulterInformations,[{_,MSISDN}]}) ->    
    print("~p:response/2: --> Line:~p & MSISDN=~p~n",[?MODULE, ?LINE, MSISDN]),
    print("~p:response/2: --> Line:~p & Accounts=~p~n",[?MODULE, ?LINE, Accounts]),
    TypeOffre = case ServerName of
		    fake_mipc_server -> "MIPC";
		    fake_vpbx_server -> 
			case lists:nthtail(length(MSISDN)-1,MSISDN) of 
			    "1" -> "VPBx";
			    _  -> "VPBX"
			end
		end,
    {{Accounts,ServerName},[{consulterInformationsResponse,
		[],[{resultat,[],
		     [{codeRetour,[],"0"},
		      {commentaire,[],"Succes"}
		     ]},
		    {reseau,[],
		     [{codeReseau,[],"1"},
		      {nomReseau,[],"Orange"}
		     ]},
		    {membre,[],
		     [{nom,[],"Simon"},
		      {prenom,[],"Roger"},
		      {manager,[],"true"}
		     ]},
		    {nbSituationsParametrees,[],"0"},
		    {typeOffre,[],TypeOffre}
		   ]}]};

response({Accounts,ServerName},{consulterParametrageReel_Request,[{_,MSISDN}]}) ->
        print("fake_mipc_vpbx_server:response/2:MSISDN=~p~n",[MSISDN]),
        print("fake_mipc_vpbx_server:response/2:Accounts=~p~n",[Accounts]),
        %%Situation = dict:fetch(MSISDN,Accounts),
        {{Accounts,ServerName},[{consulterParametrageReelResponse,
		    [],[{resultat,[],
			 [{codeRetour,[],"0"},
			  {commentaire,[],"Succes"}
			 ]},
			{parametrageNumeroUnique,[],
			 [{active,[],"0"},
			  {typeSonnerie,[],"simul"},
			  {presentationNoFixe,[],"true"}
			 ]},
			{parametrageRenvois,[],
			 [{typeRenvoi,[],"I"},
			  {versNumerosLibres,[],
			   [{listeNumeros,[],
			     [{numero,[],"33611221124"}
			     ]}
			   ]},
			  {versAssistante,[],[]}
			 ]}
		       ]}]};

response({Accounts,ServerName},{consulterSituation,[{_,MSISDN},{_,IdS}]}) ->
    print("fake_mipc_vpbx_server:response/2:MSISDN=~p~n",[MSISDN]),
    print("fake_mipc_vpbx_server:response/2:Accounts=~p~n",[Accounts]),
    %%Situation = dict:fetch(MSISDN,Accounts),
    case lists:nthtail(length(MSISDN)-1,MSISDN) of 
	"1" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"I"},
			   {versNumerosLibres,[],
			    [{premierNumero,[],""},
			     {listeNumeros,[],
			      [{numero,[],"33611221124"}]
			     },
			     {boiteVocale,[],""}]
			   },
			   {versAssistante,[],[]
			   },
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"},
			     {numero,[],"33611221127"},
                             {numero,[],"33611221128"},
                             {numero,[],"33611221129"}
			    ]
			   }]}
			]
		       }]};	
	"2" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"I"},
			   {versNumerosLibres,[],[]},
			   {versAssistante,[],
			    %% avec accents pour tester
			    [{nom,[],"Frédéric"},
			     {prenom,[],"Frédérique"},
			     {numero,[],"33612352345"},
			     {typeAppel,[],"I"}]
			   },
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"},
			     {numero,[],"33611221127"},
			     {numero,[],"33611221128"},
			     {numero,[],"33611221129"}
			    ]
			   }]}
			]
		       }]};
	"3" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"RC"},
			   %% check different formats of MSISDN
			   {versNumerosLibres,[],
			    [{premierNumero,[],"0611221123"},
			     {listeNumeros,[],
			      [{numero,[],"0111221124"},
			       {numero,[],"0211221125"}]
			     },
			     {boiteVocale,[],"33311221126"}]
			   },
			   {versAssistante,[],[]},
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"}]
			   }]}
			]
		       }]};	    
	"4" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"C"},
			   {versNumerosLibres,[],
			    [{premierNumero,[],""},
			     {listeNumeros,[],
			      [{numero,[],"336000000001"}]
			     },
			     {boiteVocale,[],""}]
			   },
			   {versAssistante,[],[]},
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"}]
			   }]}
			]
		       }]};
	"5" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"C"},
			   {versNumerosLibres,[],[]},
			   {versAssistante,[],
			    [{nom,[],"Paul"},
			     {prenom,[],"Shariat"},
			     {numero,[],"33612352345"},
			     {typeAppel,[],"I"}]
			   },
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"}]
			   }]}
			]
		       }]};
	"6" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"O"},
			   {versNumerosLibres,[],
			    [{premierNumero,[],""},
			     {listeNumeros,[],
			      [{numero,[],"33611221124"}]
			     },
			     {boiteVocale,[],""}]
			   },
			   {versAssistante,[],[]},
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"}]
			   }]}
			]
		       }]};
	"7" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageNumeroUnique,[],
			  [{active,[],"0"},
			   {typeSonnerie,[],"simul"},
			   {presentationNoFixe,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],"NR"},
			   {versNumerosLibres,[],
			    [{premierNumero,[],""},
			     {listeNumeros,[],
			      [{numero,[],"33611221124"}]
			     },
			     {boiteVocale,[],""}]
			   },
			   {versAssistante,[],[]},
			   {saufAppelsEmisDepuis,[],
			    [{numero,[],"33611221126"}]
			   }]}
			]
		       }]};
	"8" ->
	    {{Accounts,ServerName},[{consulterSituationResponse,[],
			[{resultat,[],
			  [{codeRetour,[],"0"},
			   {commentaire,[],"true"}
			  ]
			 },
			 {parametrageRenvois,[],
			  [{typeRenvoi,[],""}
			  ]
			 }]}]}
    end;
	
response({Accounts,ServerName},{listeSituationsParametrees,[{_,MSISDN}]}) ->
    print("fake_mipc_vpbx_server:response/2:MSISDN=~p~n",[MSISDN]),
    print("fake_mipc_vpbx_server:response/2:Accounts=~p~n",[Accounts]),
    %%Situation = dict:fetch(MSISDN,Accounts),
    {{Accounts,ServerName},[{listeSituationsParametreesResponse,[],
		[{resultat,[],
		  [{codeRetour,[],"0"},
		   {commentaire,[],"succes"}]
		  },
		 {listeSituationsParametrees,[],
		  [{listeSituations,[],
		  [ {situation,[],
		      [{idSituation,[],"1"},
		       {libelleSituation,[],"a mon bureau"}]
		     },
		     {situation,[],
		      [{idSituation,[],"2"},
		       {libelleSituation,[],"en deplacement"}]
		     },
		     {situation,[],
		      [{idSituation,[],"3"},
		       {libelleSituation,[],"en reunion"}]
		     },
		     {situation,[],
		      [{idSituation,[],"4"},
		       {libelleSituation,[],"en conges"}]
		     },
		     {situation,[],
		      [{idSituation,[],"5"},
		       {libelleSituation,[],"en formation"}]
		     },
		     {situation,[],
		      [{idSituation,[],"8"},
		       {libelleSituation,[],"a la maison"}]
		     },
		     {situation,[],
		      [{idSituation,[],"132"},
		       {libelleSituation,[],"en formation"}]
		     }]}]
		 }]
	       }]};
response({{init_get_situation_active,Data},ServerName},{situationActive,_})->
    Accounts={init_get_situation_active,Data},
    {{Accounts,ServerName},Data};
response({Accounts,ServerName},{situationActive,[{_,MSISDN}]}) ->
    print("fake_mipc_vpbx_server:response/2:MSISDN=~p~n",[MSISDN]),
    print("fake_mipc_vpbx_server:response/2:Accounts=~p~n",[Accounts]),
    %%Situation = dict:fetch(MSISDN,Accounts),
    {{Accounts,ServerName},[{situationActiveResponse,[],
		[{resultat,[],
		  [{codeRetour,[],"0"},
		   {commentaire,[],"succes"}
		  ]},
		 {situationActive,[],
		  [{idSituation,[],"5"},
		   {libelleSituation,[],"a mon bureau"}]
		  }]}]};

response({Accounts,ServerName},Request) ->
    print("~p>>> Bad Request:~p~n",[?MODULE, Request]),
    {{Accounts,ServerName},""}.

invalidInputException()->
    [].
decode_by_name(Name,Text) -> {Name,Text}.
build_record(Name,Elements) -> {Name,Elements}.

init_data(_,_,[])->
    ok;
init_data(ServerName,Init,Data) when atom(ServerName) ->
    ServerName!{Init,Data}.

print(A,B) ->
    if ?debug ->
	    io:format(A,B);
       true ->
	    ok
    end.
