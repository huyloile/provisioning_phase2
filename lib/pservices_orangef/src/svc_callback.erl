%%% Module dealing with OF's callback via PRISM

-module(svc_callback).

-export([direct_callback/2]).
-export([sim_pull_init/5]).

-export([pull_init/2,
	 pull_init_direct_callback/2]).
-export([redirect_to_direct_callback/3]).

-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pgsm/include/ussd.hrl").
-include("../../pfront/include/pfront.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Does a callback from argument of service code (#XYZ*MSISDN#)
%% +type direct_callback(session(),Nav::string()) -> erlpage_result().
direct_callback(abs,URL) ->
    pull_init(abs,abs) ++ [{"No direct callback",{redirect,abs,URL}}];

direct_callback(Session,URL) ->
    slog:count(count,?MODULE,direct_callback),
    Dest = (Session#session.mode_data)#mdata.nav_buffer,
    case is_direct_callback(Dest) of
	true ->
	    {ok,Corrected} = correct_target_syntax(Dest),
	    pull_init(Session,Corrected);
	_ ->
	    {redirect,Session,URL}
    end.

%% +type sim_pull_init(string(),string(),string(),string(),string()) ->
%%                     ok | term().
sim_pull_init(From,To,IMSI,VLRNumber,Subs) ->
    Now = pbutil:unixmtime(),
    FakeSession = #session{prof     = #profile{msisdn       = From,
					       imsi         = IMSI,
					       subscription = Subs},
			   start    = Now,
			   location = [{vlr_number,VLRNumber}]},
    do_pull_init(FakeSession,To).

%%% Dump the adequate counter and redirect
dump_and_redirect(#session{prof=#profile{subscription=Subscription}}=Session,
		   Class,
		   Result,
		   Destination,
		   Result_detail,
		   Redirection) ->

    Vlr_number = case svc_roaming:get_vlr(Session) of
		     {Ok,X}->
			 X;
		     _ ->
			 ""
		 end,
    
    svc_util_of:event(dump_callback,
		      "callback",
		      "~p,~p,~s,~p,~p,~p,~p,~s",
		      [Class,
		       ?MODULE,
		       Subscription,
		       pull_init,
		       Result,
		       Destination,
		       Result_detail,
		       Vlr_number]),
        
    case Redirection of
	{Link,Parameters}->
	    {redirect,Session,Link,Parameters};
	_ ->
	    {redirect,Session,Redirection}
    end.

%%% Function triggering a pull init request
%% +type pull_init(session(),Target::string()) ->  erlpage_result().
pull_init(abs,_) ->
    [{redirect,abs,"#success_mobi_voice_mail"},
     {redirect,abs,"#success_mobi_customer_service"},
     {redirect,abs,"#success_mobi_phone_number"},
     {redirect,abs,"#success_cmo_voice_mail"},
     {redirect,abs,"#success_cmo_customer_service"},
     {redirect,abs,"#success_cmo_phone_number"},
     {redirect,abs,"#error3_9"},
     {redirect,abs,"#error2_4"},
     {redirect,abs,"#error5"},
     {redirect,abs,"#error6_7"},
     {redirect,abs,"#error8"},
     {redirect,abs,"#error8_country",["COUNTRY"]},
     {redirect,abs,"#error3_9"},
     {redirect,abs,"#unavailable"}];

pull_init(#session{prof=#profile{subscription=Subscription}}=Session,Target) ->
    Destination = case Target of
		      "722" -> customer_service;
		      "888" -> voice_mail;
		      _ -> phone_number
		  end,
    %% Syntaxic check on target
    case correct_target_syntax(Target) of
	{ok,Simplified} ->
	    case do_pull_init(Session,Simplified) of
		{ok,$1} ->
		    URL = "#success_" ++ Subscription ++ "_" ++ atom_to_list(Destination),
		    dump_and_redirect(Session,count,ok,Destination,success,URL);
		{ok,$2} ->
		    dump_and_redirect(Session,count,nok,Destination,error2,"#error2_4");
		{ok,$3} ->
		    dump_and_redirect(Session,count,nok,Destination,error3,"#error3_9");
		{ok,$4} ->
		    dump_and_redirect(Session,count,nok,Destination,error4,"#error2_4");
		{ok,$5} ->
		    dump_and_redirect(Session,count,nok,Destination,error5,"#error5");
		{ok,$6} ->
		    dump_and_redirect(Session,count,nok,Destination,error6,"#error6_7");
		{ok,$7} ->
		    dump_and_redirect(Session,count,nok,Destination,error7,"#error6_7");
		{ok,$8} ->
		    case get_country(Session) of
			{ok,Country} ->
			    dump_and_redirect(Session,count,nok,Destination,error8,
					       {"#error8_country",[{"COUNTRY",Country}]});
			nok ->
			    dump_and_redirect(Session,count,nok,Destination,error8,"#error8")
		    end;
		{ok,$9} ->
		    dump_and_redirect(Session,count,nok,Destination,error9,"#error3_9");
		{nok,_} ->
		    slog:event(failure, ?MODULE, pull_init, bad_reply),
		    dump_and_redirect(Session,failure,nok,Destination,bad_reply,"#unavailable");
		{timeout,_} ->
		    slog:event(failure, ?MODULE, pull_init, time_out),
		    dump_and_redirect(Session,failure,nok,Destination,time_out,"#unavailable");
		Else ->
		    slog:event(failure, ?MODULE, pull_init, Else),
		    dump_and_redirect(Session,failure,nok,Destination,default,"#unavailable")
	    end;
	_ ->
	    dump_and_redirect(Session,count,nok,Destination,bad_number,"#badnumber")
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPLEMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type is_direct_callback(Destr::string()) -> bool().
is_direct_callback("888") ->
    true;
%%% Commented for future use
%%%is_direct_callback("777") ->
%%%    true;
%%%is_direct_callback("722") ->
%%%    true;
%%%is_direct_callback(Dest) when length(Dest) > 7 ->
%%%    true;
is_direct_callback(_) ->
    false.
    

%% +type correct_target_syntax(string()) -> {ok,string()} | nok.
%%% Special calls in France
correct_target_syntax([$0,$0,$3,$3,X,Y,Z]) ->
    {ok,[X,Y,Z]};
correct_target_syntax([$+,$3,$3,X,Y,Z]) ->
    {ok,[X,Y,Z]};
correct_target_syntax([X,Y,Z]) ->
    {ok,[X,Y,Z]};
correct_target_syntax(Target) ->
    {ok,Target}.



%% +type do_pull_init(session(),Target::string()) -> ok | term().
do_pull_init(Session,Target) ->
    #session{prof  = #profile{msisdn=MSISDN,imsi=IMSI,subscription=Subs},
	     start = Start} = Session,

    SCPart = case Subs of
		 "mobi" -> pbutil:get_env(pservices_orangef,callback_mobi_sc);
		 "cmo" -> pbutil:get_env(pservices_orangef,callback_cmo_sc);
		 _ -> exit({forbidden_subscription_for_callbask,Subs})
	     end,
    case catch  svc_ussd:pull_init(Session,  SCPart, "", "pullinit", pssr, "#system_failure", [$* | Target]) of
	{page,Session2,Page} -> 
	    #page{items=[{pcdata,RText}]}=Page,
	    Session3=Session2#session{svc_data=RText},
	    ReturnCode = case RText of
			     "ERROR " ++ Tail when length(Tail)>0 ->
				 slog:event(count,?MODULE,reply_error),
				 {ok,hd(Tail)};
			     "SUCCES" ++ _ -> 	
				 slog:event(count,?MODULE,reply_ok),
				 {ok,$1};
				     _ ->
				 {nok,{bad_reply,RText}}
			 end,
	    ReturnCode;
	Else  ->
	    slog:event(failure,?MODULE,bad_reply,Else),
	    error
    end.

redirect_to_direct_callback(abs, URL_CALLBACK_FORM, URL_NOT_ALLOWED) ->
    [{redirect, abs, URL_CALLBACK_FORM},
     {redirect, abs, URL_NOT_ALLOWED}];

redirect_to_direct_callback(Session, URL_CALLBACK_FORM, URL_NOT_ALLOWED) ->
    case svc_roaming:get_vlr(Session) of
	{ok,"33" ++ _} ->
	    {redirect, Session, URL_NOT_ALLOWED};
	{ok,VLRNumber} ->
	    Dest = (Session#session.mode_data)#mdata.nav_buffer,
	    case Dest of
		[] ->
		    {redirect, Session, URL_CALLBACK_FORM};
		_ ->
		    pull_init_direct_callback(Session, Dest)
	    end;
        _ ->
	    {redirect, Session, URL_NOT_ALLOWED}
    end.

pull_init_direct_callback(abs,_) ->
    [{redirect,abs,"#success"},
     {redirect,abs,"#error3_9"},
     {redirect,abs,"#error2_4"},
     {redirect,abs,"#error5"},
     {redirect,abs,"#error6_7"},
     {redirect,abs,"#error8"},
     {redirect,abs,"#error8_country",["COUNTRY"]},
     {redirect,abs,"#error3_9"},
     {redirect,abs,"#unavailable"}];

pull_init_direct_callback(#session{prof=#profile{subscription=Subscription}}=Session,Destination) ->
    case do_pull_init(Session,Destination) of
	{ok,$1} ->
	    URL = "#success",
	    dump_and_redirect(Session,count,ok,Destination,success,URL);
	{ok,$2} ->
	    dump_and_redirect(Session,count,nok,Destination,error2,"#error2_4");
	{ok,$3} ->
	    dump_and_redirect(Session,count,nok,Destination,error3,"#error3_9");
	{ok,$4} ->
	    dump_and_redirect(Session,count,nok,Destination,error4,"#error2_4");
	{ok,$5} ->
	    dump_and_redirect(Session,count,nok,Destination,error5,"#error5");
	{ok,$6} ->
	    dump_and_redirect(Session,count,nok,Destination,error6,"#error6_7");
	{ok,$7} ->
	    dump_and_redirect(Session,count,nok,Destination,error7,"#error6_7");
	{ok,$8} ->
	    case get_country(Session) of
		{ok,Country} ->
		    dump_and_redirect(Session,count,nok,Destination,error8,
				      {"#error8_country",[{"COUNTRY",Country}]});
		nok ->
		    dump_and_redirect(Session,count,nok,Destination,error8,"#error8")
	    end;
	{ok,$9} ->
	    dump_and_redirect(Session,count,nok,Destination,error9,"#error3_9");
	{nok,_} ->
	    slog:event(failure, ?MODULE, pull_init_direct_callback, bad_reply),
	    dump_and_redirect(Session,failure,nok,Destination,bad_reply,"#unavailable");
	{timeout,_} ->
	    slog:event(failure, ?MODULE, pull_init_direct_callback, time_out),
	    dump_and_redirect(Session,failure,nok,Destination,time_out,"#unavailable");
	Else ->
	    slog:event(failure, ?MODULE, pull_init_direct_callback, Else),
	    dump_and_redirect(Session,failure,nok,Destination,default,"#unavailable")
    end.

%%% Retrieve country from VLR Number
%% +type get_country(session()) -> {ok, string()} | nok.
get_country(Session) ->
    {ok,VLRNumber} = svc_roaming:get_vlr(Session),
    case vlr_to_country(VLRNumber) of
	"" ->
	    slog:event(failure,?MODULE,get_country,{failed_for_vlr,VLRNumber}),
	    nok;
	Country ->
	    {ok,Country}
    end.



%%%% Tell Country name from vlr number
%% +type vlr_to_country(string()) -> string().
vlr_to_country("20" ++ _)  -> "Egypte";
vlr_to_country("212" ++ _) -> "Maroc";
vlr_to_country("213" ++ _) -> "Algerie";
vlr_to_country("216" ++ _) -> "Tunisie";
vlr_to_country("218" ++ _) -> "Libye";
vlr_to_country("220" ++ _) -> "Gambie";
vlr_to_country("221" ++ _) -> "Senegal";
vlr_to_country("222" ++ _) -> "Mauritanie";
vlr_to_country("223" ++ _) -> "Mali";
vlr_to_country("224" ++ _) -> "Guinee";
vlr_to_country("225" ++ _) -> "Côte d'Ivoire";
vlr_to_country("226" ++ _) -> "Burkina Faso";
vlr_to_country("227" ++ _) -> "Niger";
vlr_to_country("228" ++ _) -> "Togolaise";
vlr_to_country("229" ++ _) -> "Benin";
vlr_to_country("230" ++ _) -> "Maurice";
vlr_to_country("231" ++ _) -> "Liberia";
vlr_to_country("232" ++ _) -> "Sierra Leone";
vlr_to_country("233" ++ _) -> "Ghana";
vlr_to_country("234" ++ _) -> "Nigeria";
vlr_to_country("235" ++ _) -> "Tchad";
vlr_to_country("236" ++ _) -> "Republique Centrafricaine";
vlr_to_country("237" ++ _) -> "Cameroun";
vlr_to_country("238" ++ _) -> "Cap-Vert";
vlr_to_country("239" ++ _) -> "Sao Tome-et-Principe";
vlr_to_country("240" ++ _) -> "Guinee equatoriale";
vlr_to_country("241" ++ _) -> "Republique Gabonaise";
vlr_to_country("242" ++ _) -> "Congo";
vlr_to_country("243" ++ _) -> "Republique democratique du Congo";
vlr_to_country("244" ++ _) -> "Angola";
vlr_to_country("245" ++ _) -> "Guinee-Bissau";
vlr_to_country("246" ++ _) -> "Diego Garcia";
vlr_to_country("247" ++ _) -> "Ascension";
vlr_to_country("248" ++ _) -> "Seychelles";
vlr_to_country("249" ++ _) -> "Soudan";
vlr_to_country("250" ++ _) -> "Rwanda";
vlr_to_country("251" ++ _) -> "Ethiopie";
vlr_to_country("252" ++ _) -> "Somalie";
vlr_to_country("253" ++ _) -> "Djibouti";
vlr_to_country("254" ++ _) -> "Kenya";
vlr_to_country("255" ++ _) -> "Tanzanie";
vlr_to_country("256" ++ _) -> "Ouganda";
vlr_to_country("257" ++ _) -> "Burundi";
vlr_to_country("258" ++ _) -> "Mozambique";
vlr_to_country("260" ++ _) -> "Zambie";
vlr_to_country("261" ++ _) -> "Madagascar";
vlr_to_country("262" ++ _) -> "Reunion";
vlr_to_country("263" ++ _) -> "Zimbabwe";
vlr_to_country("264" ++ _) -> "Namibie";
vlr_to_country("265" ++ _) -> "Malawi";
vlr_to_country("266" ++ _) -> "Lesotho";
vlr_to_country("267" ++ _) -> "Botswana";
vlr_to_country("268" ++ _) -> "Swaziland";
vlr_to_country("269" ++ _) -> "Comores";
%vlr_to_country("269" ++ _) -> "Mayotte";
vlr_to_country("27" ++ _)  -> "Republique Sudafricaine";
vlr_to_country("290" ++ _) -> "Sainte-Helene";
vlr_to_country("291" ++ _) -> "Erythree";
vlr_to_country("297" ++ _) -> "Aruba";
vlr_to_country("298" ++ _) -> "Iles Feroe";
vlr_to_country("299" ++ _) -> "Groenland";
vlr_to_country("30" ++ _)  -> "Grece";
vlr_to_country("31" ++ _)  -> "Pays-Bas";
vlr_to_country("32" ++ _)  -> "Belgique";
%% vlr_to_country("33" ++ _)  -> "France";
vlr_to_country("34" ++ _)  -> "Espagne";
vlr_to_country("350" ++ _) -> "Gibraltar";
vlr_to_country("351" ++ _) -> "Portugal";
vlr_to_country("352" ++ _) -> "Luxembourg";
vlr_to_country("353" ++ _) -> "Irlande";
vlr_to_country("354" ++ _) -> "Islande";
vlr_to_country("355" ++ _) -> "Albanie";
vlr_to_country("356" ++ _) -> "Malte";
vlr_to_country("357" ++ _) -> "Chypre";
vlr_to_country("358" ++ _) -> "Finlande";
vlr_to_country("359" ++ _) -> "Bulgarie";
vlr_to_country("36" ++ _)  -> "Hongrie";
vlr_to_country("370" ++ _) -> "Lituanie";
vlr_to_country("371" ++ _) -> "Lettonie";
vlr_to_country("372" ++ _) -> "Estonie";
vlr_to_country("373" ++ _) -> "Moldova";
vlr_to_country("374" ++ _) -> "Armenie";
vlr_to_country("375" ++ _) -> "Belarus";
vlr_to_country("376" ++ _) -> "Andorre";
vlr_to_country("377" ++ _) -> "Monaco";
vlr_to_country("378" ++ _) -> "Saint-Marin";
vlr_to_country("379" ++ _) -> "Cite du Vatican";
vlr_to_country("380" ++ _) -> "Ukraine";
vlr_to_country("381" ++ _) -> "Serbie et Montenegro";
vlr_to_country("385" ++ _) -> "Croatie";
vlr_to_country("386" ++ _) -> "Slovenie";
vlr_to_country("387" ++ _) -> "Bosnie-Herzegovine";
vlr_to_country("389" ++ _) -> "Ex-Republique yougoslave de Macedoine";
vlr_to_country("39" ++ _) -> "Italie";
vlr_to_country("40" ++ _) -> "Roumanie";
vlr_to_country("41" ++ _) -> "Suisse";
vlr_to_country("420" ++ _) -> "Republique tcheque";
vlr_to_country("421" ++ _) -> "Republique slovaque";
vlr_to_country("423" ++ _) -> "Liechtenstein";
vlr_to_country("43" ++ _) -> "Autriche";
vlr_to_country("44" ++ _) -> "Royaume-Uni";
vlr_to_country("45" ++ _) -> "Danemark";
vlr_to_country("46" ++ _) -> "Suede";
vlr_to_country("47" ++ _) -> "Norveyge";
vlr_to_country("48" ++ _) -> "Pologne";
vlr_to_country("49" ++ _) -> "Allemagne";
vlr_to_country("500" ++ _) -> "Iles Falkland";
vlr_to_country("501" ++ _) -> "Belize";
vlr_to_country("502" ++ _) -> "Guatemala";
vlr_to_country("503" ++ _) -> "El Salvador";
vlr_to_country("504" ++ _) -> "Honduras";
vlr_to_country("505" ++ _) -> "Nicaragua";
vlr_to_country("506" ++ _) -> "Costa Rica";
vlr_to_country("507" ++ _) -> "Panama";
vlr_to_country("508" ++ _) -> "Saint-Pierre-et-Miquelon";
vlr_to_country("509" ++ _) -> "Haïti";
vlr_to_country("51" ++ _) -> "Perou";
vlr_to_country("52" ++ _) -> "Mexique";
vlr_to_country("53" ++ _) -> "Cuba";
vlr_to_country("54" ++ _) -> "Argentine";
vlr_to_country("55" ++ _) -> "Bresil";
vlr_to_country("56" ++ _) -> "Chili";
vlr_to_country("57" ++ _) -> "Colombie";
vlr_to_country("58" ++ _) -> "Venezuela";
vlr_to_country("590" ++ _) -> "Guadeloupe";
vlr_to_country("591" ++ _) -> "Bolivie";
vlr_to_country("592" ++ _) -> "Guyana";
vlr_to_country("593" ++ _) -> "Equateur";
vlr_to_country("594" ++ _) -> "Guyane française";
vlr_to_country("595" ++ _) -> "Paraguay";
vlr_to_country("596" ++ _) -> "Martinique";
vlr_to_country("597" ++ _) -> "Suriname";
vlr_to_country("598" ++ _) -> "Uruguay";
vlr_to_country("599" ++ _) -> "Antilles neerlandaises";
vlr_to_country("60" ++ _) -> "Malaisie";
vlr_to_country("61" ++ _) -> "Australie";
vlr_to_country("62" ++ _) -> "Indonesie";
vlr_to_country("63" ++ _) -> "Philippines";
vlr_to_country("64" ++ _) -> "Nouvelle-Zelande";
vlr_to_country("65" ++ _) -> "Singapour";
vlr_to_country("66" ++ _) -> "Thaïlande";
vlr_to_country("670" ++ _) -> "Timor";
vlr_to_country("672" ++ _) -> "Territoires exterieures de l'Australie";
vlr_to_country("673" ++ _) -> "Brunei Darussalam";
vlr_to_country("674" ++ _) -> "Nauru";
vlr_to_country("675" ++ _) -> "Papouasie-Nouvelle-Guinee";
vlr_to_country("676" ++ _) -> "Tonga";
vlr_to_country("677" ++ _) -> "Iles Salomon";
vlr_to_country("678" ++ _) -> "Vanuatu";
vlr_to_country("679" ++ _) -> "Fidji";
vlr_to_country("680" ++ _) -> "Palau";
vlr_to_country("681" ++ _) -> "Wallis-et-Futuna";
vlr_to_country("682" ++ _) -> "Iles Cook";
vlr_to_country("683" ++ _) -> "Niue";
vlr_to_country("684" ++ _) -> "Samoa americaines";
vlr_to_country("685" ++ _) -> "Samoa";
vlr_to_country("686" ++ _) -> "Kiribati";
vlr_to_country("687" ++ _) -> "Nouvelle-Caledonie";
vlr_to_country("688" ++ _) -> "Tuvalu";
vlr_to_country("689" ++ _) -> "Polynesie française";
vlr_to_country("690" ++ _) -> "Tokelau";
vlr_to_country("691" ++ _) -> "Micronesie";
vlr_to_country("692" ++ _) -> "Iles Marshall";
vlr_to_country("7" ++ _)   -> "Russie";
vlr_to_country("84" ++ _)  -> "Viet Nam";
vlr_to_country("850" ++ _) -> "Coree";
vlr_to_country("852" ++ _) -> "Hongkong, Chine";
vlr_to_country("853" ++ _) -> "Macao, Chine";
vlr_to_country("855" ++ _) -> "Cambodge";
vlr_to_country("856" ++ _) -> "Lao";
vlr_to_country("86" ++ _)  -> "Chine";
vlr_to_country("90" ++ _) -> "Turquie";
vlr_to_country("91" ++ _) -> "Inde";
vlr_to_country("92" ++ _) -> "Pakistan";
vlr_to_country("93" ++ _) -> "Afghanistan";
vlr_to_country("94" ++ _) -> "Sri Lanka";
vlr_to_country("95" ++ _) -> "Myanmar";
vlr_to_country("960" ++ _) -> "Maldives";
vlr_to_country("961" ++ _) -> "Liban";
vlr_to_country("962" ++ _) -> "Jordanie";
vlr_to_country("963" ++ _) -> "Syrie";
vlr_to_country("964" ++ _) -> "Iraq";
vlr_to_country("965" ++ _) -> "Koweït";
vlr_to_country("966" ++ _) -> "Arabie saoudite";
vlr_to_country("967" ++ _) -> "Yemen";
vlr_to_country("968" ++ _) -> "Oman";
vlr_to_country("971" ++ _) -> "Emirats arabes unis";
vlr_to_country("972" ++ _) -> "Israël";
vlr_to_country("973" ++ _) -> "Bahreïn";
vlr_to_country("974" ++ _) -> "Qatar";
vlr_to_country("975" ++ _) -> "Bhoutan";
vlr_to_country("976" ++ _) -> "Mongolie";
vlr_to_country("977" ++ _) -> "Nepal";
vlr_to_country("98" ++ _)  -> "Iran";
vlr_to_country("992" ++ _) -> "Tadjikistan";
vlr_to_country("993" ++ _) -> "Turkmenistan";
vlr_to_country("994" ++ _) -> "Azerbaïdjan";
vlr_to_country("995" ++ _) -> "Georgie";
vlr_to_country("996" ++ _) -> "Republique kirghize";
vlr_to_country("998" ++ _) -> "Ouzbekistan";
vlr_to_country(_) -> "".

