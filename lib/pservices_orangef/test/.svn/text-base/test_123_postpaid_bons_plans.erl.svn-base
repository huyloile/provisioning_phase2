-module(test_123_postpaid_bons_plans).
-export([run/0,
	 online/0,
	 pages/0,
         links/1,
         parent/1]).

-include("../../ptester/include/ptester.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").

-define(IMSI, "999000900000001").

-include("access_code.hrl").
-include("../../pfront_orangef/include/asmetier_webserv.hrl").
-include("profile_manager.hrl").
-define(Uid,bons_plans_user).

asmserv_init(Uid, Code_so)->profile_manager:set_asm_profile(Uid, #asm_profile{code_so=Code_so}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Access Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pages() ->
    [?postpaid_bons_plans, opt_unik_page].

parent(?postpaid_bons_plans) ->
    test_123_postpaid_Homepage;
parent(opt_unik_page) ->
    ?MODULE.

links(?postpaid_bons_plans) ->
    [{promos_du_moment, static},
     {opt_musique_collection, static},
     {opt_internet_max, static},
     {postpaid_exclusives, static},
     {postpaid_etranger, static},
     {opt_unik_page, dyn},
     {postpaid_fun, static}];
links(opt_unik_page) ->
    [{opt_unik_tous_operateur, static}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run() ->
    ok.

online() ->
    test_util_of:online(?MODULE,test()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test specifications.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test() ->
    test_postpaid("GP") ++
	test_postpaid("PRO") ++
	test_util_of:close_session() ++
        ["Test reussi"] ++

	[].

test_postpaid(Type) ->
    [{title, "TEST "++ Type}]++
	test_without_unik(Type)++	
   	test_unik(Type) ++
	[].

test_without_unik(Type)->
    init(Type)++
 	test_bons_plans_menu(Type)++
 	test_bons_plans_promos_du_moment(Type)++
 	test_bons_plans_opt_musique_collection(Type)++
 	test_offres_exclusives(Type)++
 	test_etranger(Type)++
	test_fun(Type)++
	[].

test_unik(Type) ->
    init(Type,"35185301")++ %%Unik imei
  	test_bons_plans_menu_unik(Type)++
  	test_option_unik_tous_operateurs(Type) ++
	test_option_unik_tous_operateurs_actived(Type) ++

  	test_option_unik_tous_operateurs_incomp(Type) ++
        test_util_of:close_session()++
	[].

test_option_unik_tous_operateurs(Type) ->
    asmserv_init(?Uid, "NOACT")++
	[{title, "Test Option Unik - Unik tous operateurs - " ++ Type},
	 {ussd2,
	  [{send,test_util_of:access_code(?MODULE, opt_unik_page, opt_unik_page)++"#"},
	   {expect,"Options UNIK.*"
	    "1:Unik tous operateur.*"},
	   {send, test_util_of:link_rank(?MODULE, opt_unik_page, opt_unik_tous_operateur, [opt_unik_tous_operateur])},
	   {expect,"Unik tous operateurs.*"
	    "Appels illimites 24/7 vers fixes & mobiles tous operateurs \\(Fr metro\\) \\+ surf illimite pour 14E/mois.*"
	    "1:Suite.*7:Conditions.*"},
	   {send,"1"},
           {expect, "Unik tous operateurs.*"
            "Depuis votre mobile Unik connecte a une livebox.*"
            "1:Souscrire.*7:Conditions.*"},
           {send, "7"},
           {expect, "Offre soumise a conditions valable en France metropolitaine. Sous reserve d'etre abonne a un forfait mobile Orange eligible,.*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "de disposer d'un acces internet haut debit Orange \\(minimum 1 megamax\\) ou de la fibre Orange, d'une Livebox Wi-Fi.*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "et d'un mobile Unik compatible \\(liste des mobiles et conditions specifiques d'abonnement aux options Unik sur www.unik.orange.fr.\\).*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "Appel voix illimite initie avec votre mobile Unik connecte a une Livebox. 3h max/appel, hors n0s speciaux, n0s services,.*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "n0s IP a tarification specifique et n0s en cours de portabilite. dans la limite de 150 correspondants differents par mois..*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "Appels directs entre personnes physiques et pour un usage personnel non lucratif direct..*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "Navigation illimitee sur le portail Orange World, Gallery et internet. Consultation illimitee sur le portail Orange World.*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "des videos des rubriques actualite, sport et cinema \\(hors matchs en direct\\)..*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "Le streaming TV, audio, video \\(autres que ceux precites\\), les usages modem, le mail \\(SMTP, POP, IMAP\\), les contenus.*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "et services payants sont factures en dehors de l'option. Voix sur IP, peer to peer et Newsgroups interdits..*1:Suite.*2:Souscrire"},
	   {send, "1"},
           {expect, "Orange pourra limiter le debit au dela d'un usage de 500Mo/mois jusqu'a la date de facturation..*1:Suite.*2:Souscrire"},
           {send, "1"},
           {expect, "Services accessibles sur reseaux et depuis un terminal compatible..*1:Souscrire"},
	   {send,"1"},
           {expect, "Souscription.*Vous allez souscrire a l'option Unik tous operateurs, vous serez facture 14E/mois."
            ".*1:Valider"},
	   {send,"1"},
	   {expect,"Validation.*Souscription enregistree.Vous serez averti de son activation par SMS.*"}
	  ]
	 }
	]++
	profile_manager:set_asm_response(?Uid,?getImpact,#'ExceptionServiceOptionnelImpossible'{codeMessage="004"})++
	[{title, "Test Option Unik - Unik tous operateurs - with case Incompatibilite de l'option souhaitee avec le forfait du client" ++ Type},
         {ussd2,
          [{send,test_util_of:access_code(?MODULE, opt_unik_page, opt_unik_page)++"#"},
           {expect,"Options UNIK.*"
            "1:Unik tous operateur.*"},
           {send, test_util_of:link_rank(?MODULE, opt_unik_page, opt_unik_tous_operateur, [opt_unik_tous_operateur])},
	   {expect, ".*est incompatible avec votre offre, vous ne pouvez pas y souscrire.*Decouvrez les autres options.*1:Autres options.*."},
           {send, "1"},
	   {expect,"Options UNIK.*"
            "1:Unik tous operateur.*"}
	  ]
	 }
	]++
	profile_manager:set_asm_response(?Uid,?getImpact,{ok, []})++
	[].

test_option_unik_tous_operateurs_actived(Type) ->
    asmserv_init(?Uid, "UKTO1")++
	[{title, "Test Option Unik - Unik tous operateurs already subscribed - " ++ Type},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, opt_unik_tous_operateur, opt_unik_page)++"#"},
	   {expect, "Souscription.*"
	    "Vous souscrivez deja a Unik tous operateurs. Ces options ne sont pas cumulables.*"}
	  ]
	 }
	].

test_option_unik_tous_operateurs_incomp(Type) ->
    asmserv_init(?Uid, "NOACT")++
	profile_manager:set_asm_impact_options(?Uid, [#asm_option{code_so="UKC60",option_name="Unik 1"},
						      #asm_option{code_so="UKC61",option_name="Unik 2"}])++
	[{title, "Test Option Unik - Unik tous operateurs incompatible - " ++ Type},
	 {ussd2,
	  [{send, test_util_of:access_code(?MODULE, opt_unik_tous_operateur, opt_unik_page)++"#"},
	   {expect, "Unik tous operateurs.*"
	    "Attention, vos options.*seront resiliees.*"
	    "1:Souscrire.*"}
	  ]
	 }
	].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init_ptester_var(IMSI) ->
    [{var, "imsi", IMSI},
     {var, "imei",       "10000799999999"},
     {var, "imei_mid",   "10000699999999"},
     {var, "imei_degrad","10000599999999"},
     {var, "tac_wap",    "01023900XXXXX1"},
     {var, "tac_no_wap", "33000200XXXXX1"},
     {var, "tac_not_defined", "01009900XXXXX1"}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_offres_exclusives(Type) ->
    ["Test Offres eXclusives - " ++ Type,
     {ussd2,
      [{send, test_util_of:access_code(?MODULE, postpaid_exclusives)++"#"},
       {expect, ".*"}
      ]
     }
    ].

test_etranger(Type)->
    [{title, "Test etranger - " ++ Type},
     {ussd2,      
      [{send, test_util_of:access_code(?MODULE, postpaid_etranger)++"#"},
       {expect, "a l'etranger"}
      ]
     }
    ].

test_fun(Type)->
    [
     {title, "Test Fun - " ++ Type},
     {ussd2,      
      [{send, test_util_of:access_code(?MODULE, postpaid_fun)++"#"},
       {expect, "1:Avantage Decouverte Zap zone.*"
	"2:Pass 3 titres a 2,97E.mois.*"
	"3:Pass jeux a 3E.mois.*"
	"4:Pass sonnerie a 2E.mois.*"
	"5:Tonalites.*"
	"6:Chat SMS.*"
	"7:Jeux par SMS" },
       {send,"1"},
       {expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"},
       {send, "1"},
       {expect,"Vous allez souscrire a l'Avantage Decouverte Zap zone..*1:Confirmer"},
       {send,"1"},
       {expect,"Vous avez souscrit a l'Avantage Decouverte Zap Zone."},
       {send,"88"},
       {expect, "Avantage Decouverte Zap zone : 1 semaine de surf illimite et gratuit pour decouvrir le portail Zap zone..*1:Souscrire.*2:Conditions"},
       {send, "2"},
       {expect,"Avantage reserve aux clients mobile Orange dont l'utilisateur de la ligne est age de moins de 18 ans et non encore inscrit au portail Zapzone..*1:Suite"},
       {send,"1"},
       {expect,"Usages en France metropolitaine.Valable sur reseau et depuis un terminal compatible..*1:Suite"},
       {send,"1"},
       {expect,"Navigation illimitee sur le portail Zap zone pendant 7 jours a compter de la souscription de l'avantage decouverte Zap zone."}
      ]
     }
    ]++
	test_util_of:close_session()++
	asmserv_init(?Uid, "PADO5")++
	[
	 {title, "Test Fun - Without link 'Avantage Decouverte Zap zone'" ++ Type},
	 {ussd2,      
	  [{send, test_util_of:access_code(?MODULE, postpaid_fun)++"#"},
	   {expect, 
	    "1:Pass 3 titres a 2,97E.mois.*"
	    "2:Pass jeux a 3E.mois.*"
	    "3:Pass sonnerie a 2E.mois.*"
	    "4:Tonalites.*"
	    "5:Chat SMS.*"
	    "6:Jeux par SMS" }
	  ]
	 }]++
	test_util_of:close_session().

test_bons_plans_menu(Type)->
    [{title, "Test Bons Plans Menu without Unik - " ++ Type},
     {ussd2,
      [{send, test_util_of:access_code(parent(?postpaid_bons_plans), ?postpaid_bons_plans)++"#"},
       {expect, "1:Promos du moment & Kdo.*"
	"2:Option musique collection.*"
	"3:Option Internet max .*"
	"4:Offres eXclusives.*"
	"5:A l'etranger.*"
	"6:Fun*"}
      ]
     }
    ].

test_bons_plans_promos_du_moment(Type)->
    [{title, "Test Bons Plans promos du moment & Kdo- " ++ Type},
     {ussd2,
      [{send, test_util_of:access_code(parent(?postpaid_bons_plans), ?postpaid_bons_plans)++"#"},
       {expect, "1:Promos du moment & Kdo.*"
	"2:Option musique collection.*"
	"3:Option Internet max .*"
	"4:Offres eXclusives.*"
	"5:A l'etranger.*"
	"6:Fun*"},
       {send,"1"},
       {expect,"Promos du moment & Kdo.*"
       "1:Promo -50% pendant 2 mois sur les options Multimedia.*"
       "2:Nuit Kdo du 21.06.*"
       "3:Journee Kdo du 14.07"},
       {send,"2"},
       {expect,"Nuit Kdo SMS : Le 21 juin 2010, profitez de SMS illimites vers tous les mobiles et fixes de 21h30 au lendemain 8h !.*"},
       {send,"1"},
       {expect,"SMS interpersonnels emis depuis un mobile en France metropolitaine hors SMS surtaxes, n. courts, sous reserve d'un credit > a 0E.*"}
      ]
     }
    ].

test_bons_plans_menu_unik(Type)->
    [{title, "Test Bons Plans Menu with Unik - " ++ Type},
     {ussd2,
      [{send, test_util_of:access_code(parent(?postpaid_bons_plans), ?postpaid_bons_plans)++"#"},
       {expect, "1:Promos du moment & Kdo.*"
	"2:Option musique collection.*"
	"3:Option Internet max .*"
	"4:Offres eXclusives.*"
	"5:A l'etranger.*"
	"6:Option Unik.*"
	"7:Fun*"}
      ]
     }
    ].

test_bons_plans_opt_orange_sport(Type)->
    [{title, "Test Bons Plans - Option Orange Sport" ++ Type},
     {ussd2,
      [{send, test_util_of:access_code(?MODULE, opt_orange_sport)++"#"},
       {expect, "Option Sport."
	"Suivez les grands evenements sportifs en illimite 24h.24 7j.7 pr 6E/mois.-50% pendant 2 mois !"}
      ]
     }
    ].

test_bons_plans_opt_musique_collection(Type)->
        [{title, "Test Bons Plans - Option Musique Collection" ++ Type},
     {ussd2,
      [{send, test_util_of:access_code(?MODULE, opt_musique_collection)++"#"},
       {expect, "Musique Collection.*"
        "Telechargez 25 titres sur mobile&PC,transferables a volonte & surfez sur Orange World pour 12E/mois.*"}
      ]
     }
    ].

init(Type)->
    init(Type,default).

init(Type,Imei)->
    BundleA=#spider_bundle{priorityType="A",
                           restitutionType="FORF",
                           bundleType="0005",
                           bundleDescription="label forf",
                           bundleAdditionalInfo="I1",
                           credits=[#spider_credit{name="balance",unit="MMS",value="40"}]},
    BundleB=#spider_bundle{priorityType="B",
                           restitutionType="SOLDE",
                           bundleType="1",
                           bundleDescription="Solde",
                           exhaustedLabel="Solde",
                           credits=[#spider_credit{name="balance",unit="VALEU",value="2"}]},
    BundleC=#spider_bundle{priorityType="C",
                           restitutionType="SOLDE",
                           bundleType="0005",
                           bundleDescription="TITREC|C_LIB|",
                           credits=[#spider_credit{name="balance",unit="SMS",value="10"},
                                    #spider_credit{name="rollOver",unit="SMS",value="5"}
                                   ]},
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
             {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],

    case Imei of
	default->
	    profile_manager:create_default(?Uid,"postpaid");
	_->
	    profile_manager:create_and_insert_default(?Uid,#test_profile{sub="postpaid",imei=Imei})
    end ++
	profile_manager:set_bundles(?Uid,[BundleA,BundleB,BundleC])++
	profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
	profile_manager:update_spider(?Uid,profile,{offerPOrSUid,Type})++
	profile_manager:init(?Uid).
