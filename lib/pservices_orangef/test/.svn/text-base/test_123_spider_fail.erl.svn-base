-module(test_123_spider_fail). 

-include("../../pdist_orangef/include/spider.hrl").
-include("../include/ftmtlv.hrl").
-include("../../oma/include/slog.hrl").

-compile(export_all).
-export([online/0]).


-define(USSD_CODE, "#123").
-define(Uid, spider_user).

-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->
    testreport:start_link_logger("../doc/"?MODULE_STRING".html"),
    test_service:online(spec()),
    ok.


spec() ->
    without_menu()++
	with_menu() ++
	["TESTS OK"].

without_menu()->
    profile_manager:create_default(?Uid,"postpaid")++
	profile_manager:init(?Uid,smpp)++
	test_util_of:set_parameter_for_test(cmo_menu_without_spider,false)++
	test_util_of:set_parameter_for_test(mobi_menu_without_spider,false)++

	profile_manager:create_default(?Uid,"mobi")++
  	mobi_niv1_without_menu() ++

	profile_manager:create_default(?Uid,"cmo")++
	cmo_niv1_without_menu() ++
	[].    

with_menu()->
 	profile_manager:create_default(?Uid,"mobi")++
	profile_manager:init(?Uid,smpp)++
  	test_util_of:set_parameter_for_test(cmo_menu_without_spider,true)++
   	test_util_of:set_parameter_for_test(mobi_menu_without_spider,true)++
 
     	mobi_niv1() ++	
  	profile_manager:create_default(?Uid,"cmo")++
     	cmo_niv1() ++

	profile_manager:create_default(?Uid,"postpaid")++
  	postpaid("PRO") ++
	[].

postpaid(Type)->
    profile_manager:update_spider(?Uid,profile,{offerType,Type})++

  	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a302"})++
 	["Postpaid Spider error: a302 ",
 	 {ussd2,
 	  [{send,?USSD_CODE"*#"},
 	   {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*"}]}]++

 	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a303"})++
 	["Postpaid Spider error: a303",
 	 {ussd2,
 	  [{send,?USSD_CODE"*#"},
 	   {expect,"Vous n'avez pas acces a ce service.*"}]}]++
	
        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
		statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SACHEM"})++
        ["Postpaid Spider error: a304 - MODULE SACHEM",
	 "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module SACHEM",
         {ussd2,
          [{send,?USSD_CODE"*#"},
           {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER110.*"}]}]++

        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
		statusDescription="Technical problem in back office sub-system   subStatus: 240 : module GLORIA"})++
        ["Postpaid Spider error: a304 - MODULE GLORIA",
	 "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module GLORIA",
         {ussd2,
          [{send,?USSD_CODE"*#"},
           {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER111.*"}]}]++

        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
		statusDescription="Technical problem in back office sub-system   subStatus: 240 : module DISE"})++
        ["Postpaid Spider error: a304 - MODULE DISE",
	 "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module DISE",
         {ussd2,
          [{send,?USSD_CODE"*#"},
           {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER112.*"}]}]++

        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SDA"})++
        ["Postpaid Spider error: a304 - MODULE SDA",
	 "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module SDA",
         {ussd2,
          [{send,?USSD_CODE"*#"},
           {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER113.*"}]}]++

        profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                statusDescription="Technical problem in back office sub-system   subStatus: 240 : module INFRANET"})++
        ["Postpaid Spider error: a304 - MODULE INFRANET",
	 "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module INFRANET",
         {ussd2,
          [{send,?USSD_CODE"*#"},
           {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER114.*"}]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a305"})++
         ["Postpaid Spider error: a305",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Service indisponible. Merci de vous reconnecter ulterieurement.*"}]}]++

	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a306"})++
	["Postpaid spider error: invalid statusCode from Spider",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect,"Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER101.*"}]}]++

	profile_manager:update_spider(?Uid,data,{error,tcp_closed})++
	["postpaid by SCE avec Menu: Spider no response",
	 {ussd2,
	  [{send,?USSD_CODE"*#"},
	   {expect, "Suivi conso momentanement indisponible, merci de vous reconnecter ulterieurement.*ER100.*Menu.*"},
	   {send, "1"},
	   {expect, "Menu #123#.*"}
	  ]}].   

mobi_niv1_without_menu()->
    profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a302"})++
	[{title,"MOBI niv1 Spider indisponible without menu - Error 302"},
	 {ussd2,
	  [
	   {send,?USSD_CODE"*#"},
	   {expect,"Service Indisponible. Nous vous invitons a consulter votre compte sur www.orange.fr>espace client"}
	  ]
	 }
	] ++
	profile_manager:update_spider(?Uid,data,{error,tcp_closed})++
	[{title,"MOBI niv1 Spider indisponible without menu - no respon"},
	 {ussd2,
	  [
	   {send,?USSD_CODE"*#"},
	   {expect,"Service Indisponible. Nous vous invitons a consulter votre compte sur www.orange.fr>espace client"}
	  ]
	 }
	].
mobi_niv1() ->
     profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a302"})++
   	["mobi spider error a302",
   	 {ussd2,
   	  [{send,?USSD_CODE"*#"},
   	   {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*1:Recharger.*2:Acceder au menu #123#"}]}]++

    	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a303"})++
   	["mobi spider error a303: access refused",
   	 {ussd2,
   	  [{send,?USSD_CODE"*#"},
   	   {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*1:Recharger.*2:Acceder au menu #123#.*"}]}]++

   	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SACHEM"})++
  	["mobi spider error a304: technical problem - statusDescription= SACHEM",
	 "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module SACHEM",
  	 {ussd2,
  	  [{send,?USSD_CODE"*#"},
  	   {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER110.*1:Recharger.*2:Acceder au menu #123#.*"}]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module GLORIA"})++
         ["mobi spider error a304: technical problem - statusDescription= GLORIA",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module GLORIA",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER111.*1:Recharger.*2:Acceder au menu #123#.*"}]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module DISE"})++
         ["mobi spider error a304: technical problem - statusDescription= DISE",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module DISE",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER112.*1:Recharger.*2:Acceder au menu #123#.*"}]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SDA"})++
         ["mobi spider error a304: technical problem - statusDescription= SDA",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module SDA",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER113.*1:Recharger.*2:Acceder au menu #123#.*"}]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module INFRANET"})++
         ["mobi spider error a304: technical problem - statusDescription= INFRANET",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module INFRANET",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER114.*1:Recharger.*2:Acceder au menu #123#.*"}]}]++

   	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a305"})++
   	["mobi spider error a305",
  	 {ussd2,
  	  [{send,?USSD_CODE"*#"},
  	   {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*1:Recharger.*2:Acceder au menu #123#"}]}]++


         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a306"})++
         ["mobi spider error: invalid statusCode from Spider",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER101.*1:Recharger.*2:Acceder au menu #123#"}]}]++

 	profile_manager:update_spider(?Uid,data,{error,tcp_closed})++
 	["mobi spider no respone",
 	 {ussd2,
 	  [{send,?USSD_CODE"*#"},
 	   {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER100.*1:Recharger.*2:Acceder au menu #123#"}]}]++
	[].


cmo_niv1_without_menu()->
    profile_manager:update_spider(?Uid,data,{error,tcp_closed})++
	["CMO niv1 Spider indisponible without menu",
	 {ussd2,
	  [
	   {send,?USSD_CODE"*#"},
	   {expect,"Service Indisponible. Nous vous invitons a appeler le 740 \\(appel gratuit\\) ou a vous rendre sur www.orange.fr>espace client pour consulter votre compte"}
	  ]
	 }     
	].
cmo_niv1() ->

     profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a302"})++
  	["cmo spider error a302",
   	 {ussd2,
   	  [{send,?USSD_CODE"*#"},
   	   {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*1:Recharger.*2:Acceder au menu #123#"}]}]++

    	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a305"})++
   	["cmo spider error a305",
   	 {ussd2,
   	  [{send,?USSD_CODE"*#"},
   	   {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*1:Recharger.*2:Acceder au menu #123#"}]}] ++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SACHEM"})++
         ["cmo spider error 304 - MODULE SACHEM",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module SACHEM",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER110.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*2:Suivi conso options.*"},
            {send, "2"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER110.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*1:Suivi conso detaille.*"},
            {send, "1"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER110.*1:Recharger.*2:Acceder au menu #123#"}
           ]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module GLORIA"})++
         ["cmo spider error 304 - MODULE GLORIA",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module GLORIA",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER111.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*2:Suivi conso options.*"},
            {send, "2"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER111.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*1:Suivi conso detaille.*"},
            {send, "1"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER111.*1:Recharger.*2:Acceder au menu #123#"}
           ]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module DISE"})++
         ["cmo spider error 304 - MODULE DISE",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module DISE",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER112.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*2:Suivi conso options.*"},
            {send, "2"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER112.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*1:Suivi conso detaille.*"},
            {send, "1"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER112.*1:Recharger.*2:Acceder au menu #123#"}
           ]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module SDA"})++
         ["cmo spider error 304 - MODULE SDA",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module SDA",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER113.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*2:Suivi conso options.*"},
            {send, "2"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER113.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*1:Suivi conso detaille.*"},
            {send, "1"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER113.*1:Recharger.*2:Acceder au menu #123#"}
           ]}]++

         profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a304", 
                 statusDescription="Technical problem in back office sub-system   subStatus: 240 : module INFRANET"})++
         ["cmo spider error 304 - MODULE INFRANET",
	  "statusDescription=Technical problem in back office sub-system   subStatus: 240 : module INFRANET",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER114.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*2:Suivi conso options.*"},
            {send, "2"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER114.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*1:Suivi conso detaille.*"},
            {send, "1"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER114.*1:Recharger.*2:Acceder au menu #123#"}
           ]}]++

	profile_manager:update_spider(?Uid,status,#spider_status{statusCode="a306"})++
         ["cmo spider error: invalid statusCode from Spider",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER101.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*2:Suivi conso options.*"},
            {send, "2"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER101.*1:Recharger.*2:Acceder au menu #123#"},
            {send, "2"},
            {expect, ".*3:Suivi Conso.*"},
            {send, "3"},
            {expect, ".*1:Suivi conso detaille.*"},
            {send, "1"},
            {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER101.*1:Recharger.*2:Acceder au menu #123#"}
           ]}]++

         profile_manager:update_spider(?Uid,data,{error,tcp_closed})++
         ["CMO avec Menu spider no respone",
          {ussd2,
           [{send,?USSD_CODE"*#"},
            {expect,"Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER100.*1:Recharger.*2:Acceder au menu #123#"},
 	   {send, "2"},
 	   {expect, ".*3:Suivi Conso.*"},
 	   {send, "3"},
 	   {expect, ".*2:Suivi conso options.*"},
 	   {send, "2"},
 	   {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER100.*1:Recharger.*2:Acceder au menu #123#"},
 	   {send, "2"},
 	   {expect, ".*3:Suivi Conso.*"},
 	   {send, "3"},
 	   {expect, ".*1:Suivi conso detaille.*"},
 	   {send, "1"},
 	   {expect, "Votre suivi conso est momentanement indisponible, nous vous invitons a vous reconnecter ulterieurement.*ER100.*1:Recharger.*2:Acceder au menu #123#"}
 	  ]}] ++
	[].

