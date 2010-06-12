-module(test_transfert_credit). 

-compile(export_all).
-include("../include/ftmtlv.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").

-include("access_code.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").
-define(Uid,transfert_credit_user).
-define(Uid1,msisdn_destinataire).

-define(USSD_CODE, "#123").

-define(MSISDN_MOB,"0688888888").
-define(MSISDN_MOB_INT,"+33688888888").
-define(IMSI_MOB,msisdn2imsi(?MSISDN_MOB)).
-define(MSISDN_CMO,"0678787878").
-define(IMSI_CMO,msisdn2imsi(?MSISDN_CMO)).
-define(OLD_MSISDN, generate_old_msisdn(?Uid)).

-define(MENU_TRANSFERT_1, "Offrir du credit c'est simple et c'est gratuit avec le service de transfert de credit."
	" Vous pouvez tester le service... 1:Suite 2:Pour offrir du credit 3:Conditions").
-define(MENU_TRANSFERT_2, "de transfert de credit en offrant un montant libre entre 1 et 15 euros a un proche detenant une carte prepayee Orange. Ce montant est debite de votre").
-define(MENU_TRANSFERT_3, "compte principal et immediatement transfere a un proche. Le montant offert est valable 7 jours et sera decompte au tarif en vigueur...").
-define(MENU_TRANSFERT_4, "Le montant offert ne prolonge pas la validite du compte principal et de la ligne du beneficiaire.*"
	"1:Pour offrir du credit.*9:Accueil").
-define(MENU_OFFRIR_1, "Veuillez repondre en saisissant le numero de telephone de la personne a qui vous souhaitez offrir du credit \\(cette personne devant detenir une carte prepayee Orange\\)").
-define(MENU_OFFRIR_2, "Votre montant a bien ete enregistre.*"
        "Veuillez a present saisir le numero de telephone mobicarte de votre proche.*").
-define(MENU_OFFRIR_3, "Vous souhaitez transferer 14 euros au 06 88 88 88 88 1:Confirmer.*9:Accueil").
-define(MENU_ERREUR_MONTANT, "Desole le montant saisi est incorrect. Merci de saisir un montant sans decimale compris entre 1 et 15 E.*").
-define(MENU_ERREUR_MSISDN_WRONG_FORMAT, "Numero non valide.*Merci d'entrer un no commencant par 06 ou 07, comportant 10 chiffres, sans espace.*Nous vous invitons a recommencer en entrant un nouveau numero").
-define(MENU_ERREUR_MSISDN_WRONG_PP_ORANGE, "Numero de telephone non valide. Seul un numero prepaye Orange.*"
	"peut beneficier d'un transfert de credit.*Merci de recommencer en saisissant un nouveau numero.*").
-define(CONFIRM,"Vous venez de transferer 14 euros au 06 88 88 88 88."
	" Dans quelques instants vous recevrez un SMS de confirmation ainsi que le beneficiaire.*9:Accueil").

-define(CONDITIONS_1, "Service accessible en France metropolitaine et reserve aux clients prepaye Orange").
-define(CONDITIONS_2, "...Transfert de credit d'un montant de 1 a 15 euros par pas de 1 euro vers un autre compte prepaye Orange. Service accessible par le #123# et le 224...").
-define(CONDITIONS_3,"Le credit transfere est valable 7 jours et ne prolonge ni la duree de validite du credit du compte principal "
	"ni la duree de validite du num d'appel du beneficiaire.*1:Suite").
-define(CONDITIONS_4,"...Si la duree de validite du num d'appel est inferieure a 7 jours au moment du transfert, "
	"elle sera automatiquement positionnee sur 7 jours... 1:Suite.*9:Accueil").
-define(CONDITIONS_5,"...Les communications sont decomptees en priorite du credit transfere au tarif du plan classique seconde "
	".*voir fiche tarifaire en vigueur.*... 1:Suite.*9:Accueil").
-define(CONDITIONS_6,"...Service limite a 5 transferts par mois pour le donneur et le beneficiaire. "
	"Le credit transfere ne peut pas faire l'objet d'un nouveau transfert... 1:Suite.*9:Accueil").
-define(CONDITIONS_7,"Si le beneficiaire est inscrit a l'illimite kdo, le credit transfere n'entre pas en compte dans le calcul des 30E "
	"recharges dans le mois. 1:Offrir du credit.*9:Accueil").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unitary tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    test_proposer_lien(),
    ok.

test_proposer_lien()->
    lists:foldl(
      fun({State, Expected}, Count) ->
	      Session = set_session(State),
	      Result = svc_of_plugins:proposer_lien(Session, "mobi", "transfert_credit", "Link", "Url"),
	      {Count, Expected} = {Count, Result},
	      Count + 1
      end,
      1,
      [{actived,
	[#hlink{href="Url",key=[],kw=[],cost=0,help=[],
		contents=[{pcdata, "Link"}]},br]},
       {not_actived,[]}
]).
    
set_session(actived) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{cpte_princ=#compte{cpp_solde=currency:sum(euro,45000)}}}]};
set_session(not_actived) ->
    #session{prof=#profile{subscription="mobi"},
	     svc_data=[{user_state,#sdp_user_state{cpte_princ=10}}]}.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Online tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

online() ->

    smsloop_client:start(),

    check_interf(httpclient_spider),
    init_config(),

    test_util_of:online(?MODULE,test()),
    smsloop_client:stop(),
    ok.
    
init_config() ->
    rpc:call(possum@localhost, oma_config, reload_config, []),
    Params = 
	[{pservices,prov_type_by_sc, [{?USSD_CODE,"#selfcare_user"}]},
	 {pservices,auth_by_sc_acl, [{?USSD_CODE,"/orangef/home.xml##123",
				      [],"/orangef/auth.xml#auth_preprod",
				      whitelist, []},
				     {"#128","/test/index.xml",
				      "test en ligne","/system/home.xml#auth_preprod",
				      blacklist,[]}
				    ]},
	 {oma, sasl_dump_class, all},
	 {pservices_orangef,new_provisioning_module_proportion,100},
	 {pservices_orangef, provisioning_module, provisioning_ftm},
	 {pservices_orangef, spider_prepaid_cmo, {true, 100}},
	 {pservices_orangef, spider_prepaid_mobi, {true, 100}}],

    lists:foreach(fun rpc_call_change_param/1, Params).

rpc_call_change_param({App,P,NewV}) ->
    ok = rpc:call(possum@localhost,oma_config,change_param,[App,P,NewV]).

reload_config() ->
    ok = rpc:call(possum@localhost, oma_config, reload_config, []).

check_interf(InterName) ->
    case rpc:call(possum@localhost,erlang,whereis,[InterName]) of
	Proc when pid(Proc) -> io:format("interf ~p ~p~n", [InterName, Proc]);
	_ -> exit({no_proc,InterName})
    end.
 
generate_old_msisdn(Uid) when atom(Uid)->
        generate_old_msisdn(atom_to_list(Uid));
generate_old_msisdn(Uid) when list(Uid)->
        Num=lists:sum(Uid),
        Str=lists:flatten( pbutil:sprintf("%03d",[Num rem 1000])),
        "0900000"++Str.

msisdn2imsi(MSISDN) ->
    MSISDN_NAT = sachem_server:intl_to_nat(MSISDN),
    "20801"++MSISDN_NAT.

init(Uid,CPP_SOLDE)->
    BundleA=#spider_bundle{priorityType="A",
			   bundleLevel="1",
			   restitutionType="FORF",
			   bundleType="0003",
			   bundleDescription="forfait",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   credits=[#spider_credit{name="standard",unit="TEMPS",value="2h"},
				    #spider_credit{name="balance",unit="TEMPS",value="00h29min10s"},
				    #spider_credit{name="rollOver",unit="TEMPS",value="1h30min50s"}
				   ]
			  },
    BundleC=#spider_bundle{priorityType="C",
			   bundleLevel="1",
			   restitutionType="LIB",
			   bundleType="0005",
			   bundleDescription="C_LIB",
			   reactualDate="2008-09-30T07:08:09.MMMZ",
			   desactivationDate="2008-12-12T07:08:09.MMMZ",
			   credits=[#spider_credit{name="balance",unit="SMS",value="0"},
				    #spider_credit{name="rollOver",unit="SMS",value="1"}
				   ]
			  },
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
	     {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    profile_manager:create_default(Uid,"mobi")++
        profile_manager:set_bundles(Uid,[BundleA,BundleC])++
        profile_manager:update_spider(Uid,profile,{amounts,Amounts})++
        profile_manager:init(Uid)++
	test_util_of:set_parameter_for_test(refonte_ergo_mobi,true)++
   	profile_manager:set_list_comptes(Uid,[#compte{tcp_num=?C_PRINC,
						      unt_num=?EURO,
						      cpp_solde=CPP_SOLDE,
						      dlv=pbutil:unixtime(),
						      rnv=0,
						      etat=?CETAT_AC,
						      ptf_num=?MCLAS}])++
	profile_manager:set_dcl(?Uid,?mobi).

test() ->
      lists:append([test_control_eligibility(Params) || 
      		     Params <- [{45000,?mobi},
      				{50000,?B_phone},
      				{55000,?click_mobi},
      				{60000,?mobi_janus},
      				{65000,?RC_LENS_mobile},
      				{70000,?mobi_new},
      				{75000,?m6_prepaid},
      				{80000,115} %%% M6 Prepaid Add funded
      			       ]])++
     	test_control_msisdn_dest()++
     	test_control_saisir_credit() ++ %% Work OK
	test_control_transfert_credit()++
	test_conditions() ++ %% Work OK
 	["TESTS OK"].



test_control_eligibility({CPP_SOLDE,DCL}) ->
     init(?Uid,CPP_SOLDE) ++
 	profile_manager:set_dcl(?Uid,DCL)++
 	[ "Test - lien en attendu : Offrir du credit\n"++
 	  "DCL :"++integer_to_list(DCL)++" "++dcl2subs(DCL),
 	  {ussd2,
 	  [ {send, "#123#"},
 	    {expect, ".*"},
	    {send,"2"},
 	    {expect, "Offrir du credit"}
 	   ]}
 	 ].

test_control_msisdn_dest() ->
    ["TEST CONTROL MSISDN DU DESTINATAIRE"]++
	test_saisir_msisdn()++
	[].

test_saisir_msisdn()->
    lists:append([test_saisir_OK(OK) || OK <- [known_in_db,
					       known_by_ocf]]) ++ 
	lists:append([test_saisir_error(Error) || Error <- [wrong_format,
							inproper_msisdn,
							not_found_in_db,
							not_found_by_ocf
						       ]])++
	[].

test_saisir_OK(OK) ->
	case OK of 
	    known_in_db -> 
		Profile_Receiver=#test_profile{msisdn=?MSISDN_MOB_INT,
					       sub="mobi",
					       dcl=51},
		profile_manager:create_and_insert_default(?Uid1,Profile_Receiver,true)++
		    [];
	    known_by_ocf ->
		Profile_Receiver=#test_profile{msisdn=?MSISDN_MOB_INT},
		profile_manager:create_and_insert_default(?Uid1,Profile_Receiver,false)++
		    delete_msisdn_dest(?MSISDN_MOB)++
		    profile_manager:set_ocf_response(?Uid1,'OrangeAPI.getUserInformationByMsisdn',{ok,{response,
												       [{struct,[{'SegmentCode',"CPP04"}]
													}]}})
	end++
	init(?Uid,50000) ++
	[ "Test saisir MSISDN successfully with MSISDN :"++atom_to_list(OK),
	  {ussd2,
	   [ {send, "#123*2*5#"},
	     {expect, ?MENU_TRANSFERT_1},
	     {send, "9"},
	     {expect, "5:Offrir du credit"},
	     {send, "5"},
	     {expect, ?MENU_TRANSFERT_1},
	     {send, "1"},
	     {expect, ?MENU_TRANSFERT_2},
	     {send, "1"},
	     {expect, ?MENU_TRANSFERT_3},
	     {send, "1"},
	     {expect, ?MENU_TRANSFERT_4},
	     {send, "1"},
	     {expect, ?MENU_OFFRIR_1},
	     {send, ?MSISDN_MOB},
	     {expect, "Vous souhaitez offrir du credit au .*1:Confirmer"},
	     {send, "1"},
	     {expect, "Numero enregistre.*Veuillez a present saisir le montant que vous souhaitez transferer compris entre 1 et 15 E.*"
	      "Vous devez choisir un nombre entier"},
	     {send, "10"},
	     {expect, "Vous souhaitez transferer 10 euros au 06 88 88 88 88.*1:Confirmer"},
	     {send, "1"},
	     {expect, "Vous venez de transferer 10 euros au 06 88 88 88 88.*Dans quelques instants le beneficiaire et vous recevrez un SMS de confirmation."},
	     {send, "9"},
	     {expect, "Menu #123#.*"}	    
	    ]}
 	 ].


test_saisir_error(wrong_format=Error) ->    
    init(?Uid,50000) ++
	[ "Test saisir MSISDN with error :"++atom_to_list(Error),
	  {ussd2,
	  [ {send, "#123*2*5#"},
	    {expect, "2:Pour offrir du credit"},
	    {send, "2"},
	    {expect, ?MENU_OFFRIR_1},
	    {send, "06876543210"},
	    {expect, ?MENU_ERREUR_MSISDN_WRONG_FORMAT},
	    {send, "08 98989898"},
	    {expect, ?MENU_ERREUR_MSISDN_WRONG_FORMAT},
	    {send, "Abs"},
	    {expect, ?MENU_ERREUR_MSISDN_WRONG_FORMAT}
	   ]}
	 ];
test_saisir_error(inproper_msisdn=Error) ->
    Msisdn_Receiver=svc_util_of:int_to_nat(profile_manager:msisdn_by_uid(?Uid)),
    init_msisdn_dest(Msisdn_Receiver,"mobi")++
    init(?Uid,50000) ++
	[ "Test saisir MSISDN with error :"++atom_to_list(Error)++"\n",
	  "Receiver msisdn is the same as transmetteur msisdn",
	  {ussd2,
	  [ {send, "#123*2*5#"},
	    {expect, "2:Pour offrir du credit"},
	    {send, "2"},
	    {expect, ?MENU_OFFRIR_1},
	    {send, "0898989898"},
            {expect, ?MENU_ERREUR_MSISDN_WRONG_FORMAT},
	    {send, Msisdn_Receiver},
	    {expect, "Vous ne pouvez pas offrir du credit a votre propre carte prepayee, merci d'entrer un autre numero.*Vous pouvez aussi recharger votre carte en tapant 1.*1:Recharger"},
	    {send, "1"},
	    {expect, "Rechargement.*1:par recharge mobicarte.*2:par carte bancaire.*3:Recharge pour moi"}
	   ]}
	 ];
test_saisir_error(Error) ->
    case Error of 
	not_found_in_db -> 
	    init_msisdn_dest(?MSISDN_MOB_INT,"cmo");
	not_found_by_ocf -> 
	    profile_manager:create_and_insert_default(?Uid1,#test_profile{msisdn="33688888888"},false)++
		delete_msisdn_dest(?MSISDN_MOB_INT)++
		profile_manager:set_ocf_response(?Uid1,'OrangeAPI.getUserInformationByMsisdn',{ok,{response,
												   [{struct,[{'SegmentCode',"CPP02"}]
												    }]}})
    end++
	init(?Uid,50000) ++
	["Test saisir MSISDN with error :"++atom_to_list(Error),
	 {ussd2,
	  [ {send, "#123*2*5#"},
	    {expect, ?MENU_TRANSFERT_1},
 	    {send, "9"},
 	    {expect, "5:Offrir du credit"},
 	    {send, "5"},
 	    {expect, ?MENU_TRANSFERT_1},
 	    {send, "1"},
 	    {expect, ?MENU_TRANSFERT_2},
 	    {send, "1"},
 	    {expect, ?MENU_TRANSFERT_3},
	    {send, "1"},
            {expect, ?MENU_TRANSFERT_4},
 	    {send, "1"},
 	    {expect, ?MENU_OFFRIR_1},
 	    {send, ?MSISDN_MOB},
	    {expect,?MENU_ERREUR_MSISDN_WRONG_PP_ORANGE}
 	   ]}
       ].


test_control_saisir_credit()->
    init(?Uid,50000) ++
	init_msisdn_dest(?MSISDN_MOB_INT,"mobi")++	
	[ "Test - Mauvais Montant",
	  {ussd2,
	  [ {send, "#123*2*5#"},
	    {expect, "2:Pour offrir du credit"},
	    {send, "2"},
	    {expect, ?MENU_OFFRIR_1},
 	    {send, ?MSISDN_MOB},
 	    {expect, "Vous souhaitez offrir du credit au 06 88 88 88 88.*1:Confirmer"},
	    {send,"1"},
	    {expect, "Numero enregistre.*Veuillez a present saisir le montant que vous souhaitez transferer compris entre 1 et 15 E. Vous devez choisir un nombre entier."},
	    {send,"8.5"},	    
	    {expect, ?MENU_ERREUR_MONTANT},
	    {send, "ab"},
	    {expect, ?MENU_ERREUR_MONTANT},
	    {send, "20"},
            {expect, ?MENU_ERREUR_MONTANT},
	    {send, "00"},
	    {expect, "5:Offrir du credit"}
	   ]}
	 ].


test_control_transfert_credit()->
    test_trc2msisdn_dest_inactif()++
	[].

test_trc2msisdn_dest_inactif() ->
        init(?Uid,50000) ++
	init_msisdn_dest(?MSISDN_MOB_INT, "mobi")++
	profile_manager:update_sachem(?Uid,?tra_credit,{"STATUT","-35"})++
        [ "Test - Transfert credit to Msisdn destinatire inactif",
          {ussd2,
          [ {send, "#123*2*5*2#"},
            {expect, ?MENU_OFFRIR_1},
            {send, ?MSISDN_MOB},
            {expect, "Vous souhaitez offrir du credit au 06 88 88 88 88.*1:Confirmer"},
	    {send, "1"},
	    {expect, "Numero enregistre.*Veuillez a present saisir le montant que vous souhaitez transferer compris entre 1 et 15 E"},
            {send, "7"},
	    {expect, "Vous souhaitez transferer 7 euros au 06 88 88 88 88.*1:Confirmer"},
	    {send, "1"},
            {expect, "La carte prepayee de votre proche est inactive. Vous ne pouvez pas lui offrir du credit.*9:Accueil"},
	    {send, "9"},
	    {expect, "Menu #123#"}
           ]}
         ].

test_conditions() ->
    init(?Uid,50000) ++
	[ "Test - Conditions",
	  {ussd2,
	  [ {send, "#123*2*5*3#"},
	    {expect, ?CONDITIONS_1},
	    {send, "1"},
	    {expect, ?CONDITIONS_2},
	    {send, "1"},
	    {expect, ?CONDITIONS_3},
	    {send, "1"},
	    {expect, ?CONDITIONS_4},
	    {send, "1"},
	    {expect, ?CONDITIONS_5},
	    {send, "1"},
	    {expect, ?CONDITIONS_6},
	    {send, "1"},
	    {expect, ?CONDITIONS_7},
	    {send, "1"},
	    {expect, ?MENU_OFFRIR_1}
	    ]}
	  ].

dcl2subs(DCL) ->
    case DCL of 
	?mobi -> "mobi";
	?B_phone -> "BIC phone";
	?mobi_janus -> "Mobicarte Janus";
	?mobi_new -> "Proximite";
	?m6_prepaid -> "M6 Prepaid";
	?RC_LENS_mobile -> "Clubs de foot";
	115 -> "M6 Prepaid add funded";
	?click_mobi -> "Click"
    end.

delete_msisdn_dest(MSISDN) ->	     
    ["Delete msisdn destinataire from database users",
     {shell,
      [ {send, "mysql -u possum -ppossum mobi -B -e \"delete from users where msisdn='"++MSISDN++"'\""}
       ]}
     ].
init_msisdn_dest(MSISDN,SUB) ->
    delete_msisdn_dest(MSISDN)++
    ["Create msisdn destinataire",
     {shell,
      [
	{send, "mysql -u possum -ppossum mobi -B -e \"insert into users (msisdn,subscription) values ('"++MSISDN++"','"++SUB++"')\""}
       ]}
     ].

