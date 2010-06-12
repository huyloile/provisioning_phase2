-module(test_123_one2one).
-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront/include/pfront.hrl").
-include("../../pserver/include/page.hrl").
-include("../include/ftmtlv.hrl").
-include("../include/one2one.hrl").
-include("profile_manager.hrl").

-define(Uid_oto, one2one_oe).
-define(Expect_CMO_Homepage,"L'offre Orange.*1:Bons plans.*2:Options SMS\\/MMS - Orange Messenger.*3:Options multimedia.*4:SMS\\/MMS Infos.*5:Options securite.*").
-define(USSD_COMMAND, "#123#").
-define(LIST_OFFERS,[
%                      "MOBOPTWEIN",
%                      "MOBOPTSOIN",
%                      "MOBOPTSSMS",
%                      "MOBOPTEURO",
%                      "MOBOPTMAGB",
%                      "MOBRECHILL",
%                      "MOBOPTJINF",
%                      "MOBOPTDUOJ",
%                      "MOBOPTSMSQ",
%                      "MOBOPTADMA",
%                      "MOBOPTTELE",
%                      "MOBOPTSPOR",
%                      "MOBOPTTOTV",
%                      "MOBOPTILKD",
%                      "MOBOPTDECO",
%                      "MOBOPTMUSI",
%                      "MOBOPTSURF",
%                      "MOBOPTOMWL",
%                      "MOBOMWLMEN",
%                      "MOBOPGECDV",
%                      "MOBFOTRCRE",
%                      "MOBFOZAP15",
%                      "MOBFOZAP18",
%                      "MOBFOZAP22",
%                      "MOBFOM619",
%                      "MOBFOM623",
%                      "MOBFOM624",
%                      "MOBFOM626",
%                      "MOBFOM629",
%                      "MOBRECILIC",
%                      "MOBMEGTRCR",
%                      "MOBMEGZEN1",
%                      "MOBMEGZEN2",
%                      "MOBMEGSTA1",
%                      "MOBMEGSTA2",
%                      "MOBOPTTEVE",
%                      "MOBMUSIMIX",
%                      "MOBMUSICOL",
%                      "MOBOPTINET",
%                      "MOBJINTMAX",
%                      "MOBWINTMAX",
%                      "MOBBPUNIK",
%                      "MOBOPUNIK",
%                      "MOBREX2JOU",
%                      "MOBOFREMOB",
%                      "FGX30",
%                      "FGR32",
%                      "FGX80",
%                      "FJ080",
%                      "FGT12",
%                      "FJ130",
%                      "FGT18",
%                      "FJ180",
%                      "FGT25",
%                      "FGTSL",
%                      "MOBOPTJSMS",
%                      "SMMS4",
%                      "MOBOPPSDOM",
% 		     "MOBOPT30SM",
 		     "MOBRECH10E",
% 		     "MOBRECH20E",
% 		     "MOBRECH30E",
%		     "71",
% 		     "69",
% 		     "70",
% 		     "FBPCM1",
% 		     "FFPCM1",
%%		     "MOBOPTIMAX",
%		     "BPM6A",
		     "NONE"
]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unit tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
	ok.

module_name_loop(LIST_OFFERS)->
    List_temp=lists:reverse(LIST_OFFERS),
    Name=lists:append([module_name_offer(Offer)||Offer<-List_temp]),
    list_to_atom(Name).
module_name_offer("NONE")->
    ?MODULE_STRING;
module_name_offer(Offer) ->
    "_" ++ Offer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%               TEST ONLINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


online()->
    test_util_of:online(module_name_loop(?LIST_OFFERS),test_one2one()),
    ok.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Init Config %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_oto()->
    rpc:call(possum@localhost,one2one_offers,csv2mnesia,["test_sample.csv"]),
    PAUSE = 2000,
    ["Activation de l'interface one2one",
     {erlang, [{rpc, call, [possum@localhost,
                            pcontrol, enable_itfs,
                            [[io_oto_mqseries1,possum@localhost]]]}]},
     "Pause de "++ integer_to_list(PAUSE) ++" Ms",
     {pause, PAUSE}] ++
        test_util_of:set_parameter_for_test(one2one_activated_cmo,true) ++
        test_util_of:set_parameter_for_test(one2one_activated_mobi,true) ++
        test_util_of:set_parameter_for_test(one2one_activated_postpaid,true) ++
        [].

init_test()->
    profile_manager:create_default(?Uid_oto,"mobi")++
    profile_manager:init(?Uid_oto)++
    init_oto().
init_test(cmo)->
    profile_manager:create_default(?Uid_oto,"cmo")++
    profile_manager:init(?Uid_oto)++
    init_oto();
init_test(_) ->
    init_test().
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TEST FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_one2one()->
    test_o2o_loop(?LIST_OFFERS) ++
	test_error_one2one(no_defini).

test_o2o_loop(LIST_OFFER)->
    init_test()++
	lists:append([test_o2o_offer(ID_OFFER)||ID_OFFER<-LIST_OFFER])++
	test_util_of:close_session()++
	["Test reuse"].

test_o2o_offer("NONE")->
    ["Test NONE"];
test_o2o_offer("MOBOPTWEIN")->
    ["Test Offer MOBOPTWEIN"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Un week-end infini pour 10 euros seulement !" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan week-end infini, appelez en illimite vers Orange.*"}
           ]}
        ]++
	[];
test_o2o_offer("MOBOPTSOIN")->
    ["Test Offer MOBOPTSOIN"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Une soiree infinie pour 3 euros  seulement !" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan Soiree infinie, vos appels sont illimites vers mobiles Orange.*"}
           ]}
        ]++
	[]
	;
test_o2o_offer("MOBOPTSSMS")->
    ["Test Offer MOBOPTSSMS"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Votre soiree SMS / MMS illimites pour 2,50  euros!" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan soiree SMS illimites envoyez vos SMS et MMS.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTEURO")->
    ["Test Offer MOBOPTEURO"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Economisez sur vos appels vers l'Europe" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Beneficiez de 42% de reduction sur vos appels vers la zone Europe.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPTMAGB")->
    ["Test Offer MOBOPTMAGB"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Economisez sur vos appels vers le Maghreb" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Profitez de 37% de reduction sur vos appels vers l'Algerie.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBRECHILL")->
    ["Test Offer"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Avec la recharge 20E, de l'illimite au choix !" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "La recharge 20E \\+illimite soir, c'est 20E de credit valable 1 mois.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTJINF")->
    ["Test Offer MOBOPTJINF"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Besoin d'appeler en illimite toute une journee \\?.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan Journee infinie, appelez en illimite vers Orange et fixes de 7h a 17h.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTDUOJ")->
    ["Test Offer MOBOPTDUOJ"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Une journee d'appels, de SMS, de MMS tout compris.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec l'option Duo Journee c'est simple et tout compris.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPTSMSQ")->
    ["Test Offer MOBOPTSMSQ"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Des SMS ou MMS a prix malin.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Le bon plan SMS quotidien c'est 6 sms ou MMS pour 0,50E par jour.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPTADMA")->
    ["Test Offer MOBOPTADMA"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             " Les nouveautes, astuces et bons plans mobicarte \\?.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Envie de connaitre les nouveautes mobicarte.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPTTELE")->
    ["Test Offer MOBOPTTELE"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Pour beneficier de l'option TV.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec l'option TV, profitez de 20 chaines de TV.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTSPOR")->
    ["Test Offer MOBOPTSPOR"]++
	 [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Pour beneficier de l'option sport.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Suivez  les plus grands evenements sportifs sur votre mobile.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTTOTV")->
    ["Test Offer MOBOPTTOTV"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Pour beneficier de l'option Totale TV.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec l'option Totale TV, profitez de 50 chaines de TV en direct.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTILKD")->
    ["Test Offer MOBOPTILKD"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "envie d'illimite.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Des 30E recharges dans le mois, profitez d'appels illimites.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPTDECO")->
    ["Test Offer MOBOPTDECO"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Avec l'option Decouverte.*" ++
             ".*En savoir.*Menu"},
            {send, "2"},
            {expect,"Avec l'option decouverte a 3E beneficiez de 5Mo valables 31 jours.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTMUSI")->
    ["Test Offer MOBOPTMUSI"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Tout en musique.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect,"Bougez toute la journee avec l'option musique a 6E.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTSURF")->
    ["Test Offer MOBOPTSURF"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "L'option surf.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Profitez de la navigation sur  Orange world en illimite a 6E pendant 31 jours.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTOMWL")->
    ["Test Offer MOBOPTOMWL"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Le messenger sur votre mobile.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Retrouvez votre communaute Windows Live Messenger depuis un mobile.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOMWLMEN")->
    ["Test Offer MOBOMWLMEN"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Le Messenger en illimite sur votre mobile.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Retrouvez votre communaute Windows Live Messenger depuis un mobile.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPGECDV")->
    ["Test Offer MOBOPGECDV"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "La garantie en cas de vol...*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec la garantie en cas de vol, le credit restant \\(limite 500E\\).*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOTRCRE")->
    ["Test Offer MOBFOTRCRE"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Faites plaisir a un proche : Offrez du credit.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le transfert de credit faites plaisir a un proche mobicarte en lui offrant.*Offrir du credit.*"}
           ]}
        ]++
        []
	;
test_o2o_offer("MOBFOZAP15")->
    ["Test Offer MOBFOZAP15"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque Zap a 15E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOZAP18")->
    ["Test Offer MOBFOZAP18"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque Zap 18E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOZAP22")->
    ["Test Offer MOBFOZAP22"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque Zap 22E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOM619")->
    ["Test Offer MOBFOM619"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque M6 a 19,99E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOM623")->
    ["Test Offer MOBFOM623"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque M6 a 23,90E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOM624")->
    ["Test Offer MOBFOM624"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque M6 a 24,99E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBFOM626")->
    ["Test Offer MOBFOM626"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque M6 a 26,99E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBFOM629")->
    ["Test Offer MOBFOM629"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait bloque!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Passez au forfait bloque M6 a 29,99E \\(sur 24 mois\\) sans changer de numero.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBRECILIC")->
    ["Test Offer MOBRECILIC"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "La simplicite du rechargement avec illico.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le rechargement illico, rechargez par CB ou vous voulez, quand vous voulez depuis votre mobile. C'est simple, rapide et entierement securise..*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMEGTRCR")->
    ["Test Offer MOBMEGTRCR"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Passez au forfait et gardez votre credit mobicarte.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Envie de passer a Origami \\? Votre credit mobicarte est transfere vers votre nouveau forfait et valable 1mois en appels voix \\(Fr metrop\\) Infos en point de vente.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMEGZEN1")->
    ["Test Offer MOBMEGZEN1"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Envie de simplicite\\? Passez a origami zen 1h.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Origami zen a 26E \\(24 mois\\): 1h d'appels \\+ 3 num kdo orange.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMEGZEN2")->
    ["Test Offer MOBMEGZEN2"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Envie de simplicite\\? Passez a origami zen 2h.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Origami zen a 34E \\(24 mois\\): 2h d'appels \\+ 3 num kdo orange sans.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMEGSTA1")->
    ["Test Offer MOBMEGSTA1"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "Envie de sensations\\? Passez a origami star 1h.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Origami star a 32E \\(24 mois\\): 1h d'appels \\+ 1h soir.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMEGSTA2")->
    ["Test Offer MOBMEGSTA2"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
             "MEG vers origami star 2h.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Origami star a 38E \\(24 mois\\): 2h d'appels \\+ 2h soir & w/e sans changer.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTTEVE")->
    ["Test Offer MOBOPTTEVE"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "La TV et la video ou je veux....*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec l'option TV profitez de \\+ de 20 chaines.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMUSIMIX")->
    ["Test Offer MOBMUSIMIX"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "20 chaines de TV en direct sur votre mobile !!!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec l'option TV profitez de \\+ de 20 chaines.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBMUSICOL")->
    ["Test Offer MOBMUSICOL"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Ma musique preferee partout avec moi....*" ++
             ".*En savoir.*Menu.*" },
            {send, "2"},
            {expect, "Avec Musique collection telechargez 25 titres par mois et accedez en illimite aux videos, aux radios et a tous les services.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTINET")->
    ["Test Offer MOBOPTINET"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Tout internet dans ma poche pour 6E seulement !.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec l'option Internet naviguez sur internet en illimite de 20h a 8h et profitez de tous les services d'Orange World.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBJINTMAX")->
    ["Test Offer MOBJINTMAX"]++
	[
         {ussd2,
	  [ {send, ?USSD_COMMAND},
	    {expect,".*" ++
	     "Tout internet dans ma poche, prendant une journee.*" ++
	     ".*En savoir.*Menu.*"},
	    {send, "2"},
	    {expect, "Avec la Journee Internet max, naviguez sur internet, Orange World ou Gallery en illimite de .*"}
	   ]}
	]++
	[];
test_o2o_offer("MOBWINTMAX")->
    ["Test Offer MOBWINTMAX"]++
	[
         {ussd2,
	  [ {send, ?USSD_COMMAND},
	    {expect,".*" ++
	     "Tout internet dans ma poche, pendant un week end.*" ++
             ".*En savoir.*Menu.*"},
	    {send, "2"},
	    {expect, "Avec le Week end Internet max, naviguez sur internet, Orange World ou Gallery en illimite .*"}
	   ]}
	] ++
	[];
test_o2o_offer("MOBBPUNIK")->
    ["Test Offer MOBBPUNIK"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Doublez votre temps de parole avec Unik !!!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan Unik, doublez votre temps de parole vers les mobiles Orange lorsque vous etes connecte.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPUNIK")->
    ["Test Offer MOBOPUNIK"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Nouveau : Vos appels vers les fixes en illimite !.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Desormais avec votre mobicarte tous vos appels vers les fixes.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPT30SM")->
    ["Test Offer MOBOPT30SM"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Vos SMS a petit prix pour 3 euros seulement !.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan 30 SMS/MMS valable 30 jours, envoyez 30 SMS ou MMS vers tous"
	     " les operateurs \\(France metrop.\\) 24h/24 et 7j/7.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOFREMOB")->
    ["Test Offer MOBOFREMOB"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Envie d'un nouveau mobile sans changer de numero \\?.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Desormais avec mobicarte,changez de mobile sans changer.*"}
           ]}
        ]++
        [];
test_o2o_offer("FGX30")->
    ["Test Offer FGX30"]++
	[
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "30 SMS ou 30 MMS \\(1MMS = 1SMS\\) pour 3E seulement par mois !.*"}
           ]}
        ] ++
        [];
test_o2o_offer("FGR32")->
    ["Test Offer FGR32"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "30 SMS ou 30 MMS\\(1MMS = 1SMS\\) pour 3E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FGX80")->
    ["Test Offer FGX80"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "80 SMS ou 80 MMS \\(1MMS = 1SMS\\) pour 7,5E seulement par mois !.*"}
           ]}
        ] ++
        [];
test_o2o_offer("FJ080")->
    ["Test Offer FJ080"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "80 SMS ou 80 MMS \\(1MMS = 1SMS\\) pour 7,5E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FGT12")->
    ["Test Offer FGT12"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "130 SMS ou 130 MMS \\(1MMS = 1SMS\\) pour 12E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FJ130")->
    ["Test Offer FJ130"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "130 SMS ou 130 MMS \\(1MMS=1SMS\\) pour 12E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FGT18")->
    ["Test Offer FGT18"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "210 SMS utilisables en SMS ou MMS \\(1MMS=3SMS\\) pour 18E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FJ180")->
    ["Test Offer FJ180"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Vos SMS ou MMS illimites 24h/24 pour 18E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FGT25")->
    ["Test Offer FGT25"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "300 SMS utilisables en SMS ou MMS \\(1MMS=3SMS\\) pour 25E seulement par mois !.*"}
           ]}
        ]++
        [];
test_o2o_offer("FGTSL")->
    ["Test Offer FGTSL"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
	    {send, "2"},
	    {expect, "Vos SMS ou MMS \\(1MMS=1SMS\\) illimites 24h/24 pour 18E seulement par mois !.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPTJSMS")->
    ["Test Offer MOBOPTJSMS"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Vos SMS et MMS illimites pour 2,50  euros / jour !.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect, "Avec le bon plan journee SMS illimites envoyez vos SMS et MMS.*"}
           ]}
        ]++
        [];
test_o2o_offer("SMMS4")->
    ["Test Offer SMMS4"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "le meilleur tarif pour les sms.*" ++
             ".*En savoir.*Menu.*"},
	    {send, "2"},
	    {expect, "Vos SMS ou MMS \\(1MMS=1SMS\\) illimites 24h/24 pour 18E seulement par mois !.*"}
           ]}
        ] ++
        [];
test_o2o_offer("MOBOPPSDOM")->
    ["Test Offer MOBOPPSDOM"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*" ++
	     "Nouveau : Economisez sur vos appels vers le DOM.*" ++
             ".*En savoir.*Menu.*"},
	    {send, "2"},
	    {expect, "Profitez de 52% de reduction sur vos appels vers les DOM et certains TOM \\(cf. tarifs en vigueur\\) avec le Pass 30 minutes vers les DOM valable 14 jrs pour 10E..*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBRECH10E") ->
    ["Test Offer MOBRECH10E"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Recharge 10E Edition Speciale : SMS/MMS illimites!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect,"Avec la recharge Edition Speciale 10E valable 7 jours, profitez en illimite de"
	     " 21h a 0h, de SMS/MMS \\(vers tous operateurs en France metrop.\\) et de Messenger..*"},
	    {send, "1"},
	    {expect, "Bienvenue sur le service de rechargement illico par CB. Choisissez votre recharge.*"}
           ]}
        ]++
        [];	    
test_o2o_offer("MOBRECH20E") ->
        ["Test Offer MOBRECH20E"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Recharge 20E Edition Speciale : SMS/MMS illimites!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect,"Avec la recharge Edition Speciale 20E valable 1 mois, profitez en illimite de"
	     " 21h a 0h, de SMS/MMS \\(vers tous operateurs en France metrop.\\) et de Messenger..*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBRECH30E") ->
        ["Test Offer MOBRECH30E"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Recharge 30E Edition Speciale : SMS/MMS illimites!.*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect,"Avec la recharge Edition Speciale 30E valable 45 jours, profitez en illimite de"
	     " 21h a 0h, de SMS/MMS \\(vers tous operateurs en France metrop.\\) et de Messenger..*"}
           ]}
        ]++
        [];
test_o2o_offer("71") ->
    init_test(cmo)++
        ["Test Offer 71"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Sms ilimite 2E la journee 2,5E la soiree.*" ++
             ".*En savoir.*Menu.*"},
            {send, "1"},
            {expect,"SMS\\/MMS et messenger illimites quand vous en avez besoin : 2E la journee 2,5E la soiree. Prix decompte du forfait.*Accueil.*"},
	    {send, "1"},
	    {expect, ?Expect_CMO_Homepage}
           ]}
        ]++
        [];
test_o2o_offer("69") ->
    init_test(cmo)++
        ["Test Offer 69"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Internet illimite 2E journee 2,5E soiree.*" ++
             ".*En savoir.*Menu.*"},
            {send, "1"},
            {expect,"Tout l'Internet illimite quand vous en avez besoin : 2E la journee 2,5E la soiree. Prix decompte du forfait.*Accueil.*"},
            {send, "1"},
            {expect, ?Expect_CMO_Homepage}
           ]}
        ]++
        [];    
test_o2o_offer("70") ->
    init_test(cmo)++
        ["Test Offer 70"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Appel ilimite 3E la journee 4E la soiree.*" ++
             ".*En savoir.*Menu.*"},
            {send, "1"},
            {expect,"Appels illimites vers tous les operateurs quand vous en avez besoin : 2E la journee 2,5E la soiree. Prix decompte du forfait..*Accueil.*"},
            {send, "1"},
            {expect, ?Expect_CMO_Homepage}

           ]}
        ]++
        [];
test_o2o_offer("FBPCM1") ->
    init_test(cmo)++
        ["Test Offer FBPCM1"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Un nouveau mobile a partir de 1 euro !.*" ++
             ".*En savoir.*Menu.*"},
            {send, "1"},
            {expect,"Orange Fidelite: Faites-vous plaisir! Changez de mobile a partir de 1E \\(reengagement 24 mois\\) & profitez du bonus Web. Rendez-vous sur orange.fr > espace client.*Accueil.*"}
           ]}
        ]++
        [];
test_o2o_offer("FFPCM1") ->
    init_test(cmo)++
        ["Test Offer FFPCM1"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Un nouveau mobile a partir de 1 euro !.*" ++
             ".*En savoir.*Menu.*"},
            {send, "1"},
            {expect,"Orange Fidelite: Faites-vous plaisir! Changez de mobile a partir de 1E \\(reengagement 24 mois\\) & profitez du bonus Web. Rendez-vous sur orange.fr > espace client.*Accueil.*"}
           ]}
        ]++
        [];
test_o2o_offer("MOBOPTIMAX") ->
    profile_manager:set_list_options(?Uid_oto,[#option{top_num=295}])++
        ["Test Offer MOBOPTIMAX"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Tout internet dans ma poche, depuis mon mobile...*" ++
             ".*En savoir.*Menu.*"},
            {send, "2"},
            {expect,"Avec l'option Internet max naviguez sur internet en illimite 24h24, 7j\\/7 et profitez aussi de tous les services d'Orange World en illimite pour 12E par mois.*"},
            {send, "1"},
            {expect, "Votre option Internet max est actuellement activee.*"}
           ]}
        ]++
        [];
test_o2o_offer("BPM6A") ->    
    init_test(cmo)++
        ["Test Offer BPM6A"]++
        [
         {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,"Pour ses 5 ans M6 mobile vous offre un Bon plan.*" ++
             ".*En savoir.*Menu.*"},
            {send, "1"},
            {expect,"M6 Mobile fete ses 5 ans et vous offre 1 Bon plan: le 16 Juin, le bon plan de votre choix est gratuit \\(Journee ou Soiree appels . SMS . Internet . TV\\).*"},
            {send, "1"},
	    {expect,"Decouvrir les Bons plans.*"},
	    {send,"1"},
	    {expect,?Expect_CMO_Homepage}
           ]}
        ]++
        [].
test_error_one2one(no_defini)->
    profile_manager:update_spider(?Uid_oto, profile,{offerPOrSUid,"CL"})++
	["Test One 2 One - Error no_defini"]++
	[
	 "Go to page without OTO",
	 {ussd2,
          [ {send, ?USSD_COMMAND},
            {expect,".*label forf:3h34m11s ou 45SMS.*Jsq 02/02 inclus.*Repondez:.*1:Suivi Conso \\+.*2:Menu.*3:Aide.*"}
           ]}
	]++
	[].
    
