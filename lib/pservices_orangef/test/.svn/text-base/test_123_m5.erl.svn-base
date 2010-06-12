-module(test_123_m5).
-export([run/0, online/0]).
-include("../../pserver/include/page.hrl").
-include("../../oma/include/slog.hrl").
-include("access_code.hrl").
-include("profile_manager.hrl").

-define(Uid, user_davantage).
-define(service_code, "#123*1").
-define(menu_code_cmo, ?service_code"*7").
-define(menu_code_postpaid, ?service_code"*5").

run() ->
    decode(),  
    test_catalogue_header(),
    test_select(),
    test_catalogue(),
    test_m5_data().
%%    check_prisme_counters().

prisme_counters() ->
    [{"CM","PC01", 18},
     {"CM","PC02", 2},
     {"CM","PC03", 3}
     ].

test_m5_data()->
    Body=  "<getActivationPrimeReponse xmlns=\"http://localhost/pdr/services_G3R6/\">
   <date xmlns=\"\">16/11/2007</date>
   <heure xmlns=\"\">16:09:49</heure>
   <codeRet xmlns=\"\">403</codeRet>
   <messageRet xmlns=\"\">Dépassement du plafond PAP</messageRet>
   <requete xmlns=\"\">
    <dossier>0687116848</dossier>
    <canal>USSD</canal>
    <idRecompense>27</idRecompense>
    <prix>1000</prix>
    <donneesClient>
     <idDossierOEE>4227709</idDossierOEE>
     <numeroClient>0090007824</numeroClient>
     <codeProduit>6</codeProduit>
     <codeOffre>3BR02</codeOffre>
     <etatDossier>A</etatDossier>
     <codeRecouvrement>0</codeRecouvrement>
     <segment>COEUR</segment>
    </donneesClient>
   </requete>
  </getActivationPrimeReponse>", 
    "403" = soaplight:decode_body(Body,opal),
    lists:foldl(
      fun({Error_number, Expected}, Count) ->
              Result =
                  svc_m5_orangef:read_activationPrime(Error_number, "Subscription" ,"MSISDN"),
              {Count, Expected} = {Count, Result},
              Count + 1
      end,
      1,
      [{"401",{mobile_pbm, 0}},
       {"402",{mobile_pbm, 0}},
       {"403",{high_credit,0}},
       {"404",{error_PCM_points,0}},
       {"405",{error_PCM_points,0}},
       {"406",{error_PCM_points,0}},
       {"500",{error,0}}]).

test_catalogue_header() ->
    Data = [{solde, "7200", "120", "01/01/2006"}, {echeance, "1900", "18/03/2006"}],
    %[{pcdata,Header_end},{pcdata,Header_beg}] =
    [{pcdata,Header}] = svc_m5_orangef:catalogue_header(Data, 1),
    Expected= "Au 01/01 vous disposez de 7200pts avec 1900 valables jusqu'au 18/03 dont 120pts carte Steel",
    Expected = Header,
    [] = svc_m5_orangef:catalogue_header(Data, 2).

test_select() ->
    lists:foldl(
      fun({Sorted_list, Page, Expected}, Count) ->
              Result =
                  svc_m5_orangef:select_presents_for_page(Page, Sorted_list,
                                                          2, 4),
              {Count, Expected} = {Count, Result},
              Count + 1
      end,
      1,
      [{[{"30","1000"},{"50","1500"},{"20","2500"}],
        1,
        {[{"30","1000"},{"50","1500"}], true}},
       {[{"10","1000"},{"50","1200"},{"30","1500"},{"20","2000"},{"70","2500"},{"90","4000"},{"80","7000"}],
        2,
        {[{"30","1500"},{"20","2000"},{"70","2500"},{"90","4000"}], true}},
       {[{"30","1000"},{"50","1500"},{"20","2500"}],
        2,
        {[{"20","2500"}], false}}]).


test_catalogue() ->
    Data = [{solde, "7200", "120", "01/01/2006"}, {echeance, "1900", "18/03/2006"}],
    Data_nok = [{solde, "0", "0", "01/01/2006"}, {echeance, "1900", "18/03/2006"}],
    Description_fun = fun(_,"40") -> {ok, "20 SMS ou 7 MMS"};
                         (_,"41") -> {ok, "30min com fixe+mobOrange"};
                         (_,"50") -> {ok, "10E reduc sur fact Orang"};
                         (_,_)    -> error
                      end,
    Header = svc_m5_orangef:catalogue_header(Data, 1),
    Header_item = svc_util_of:br_separate(Header),
    lists:foldl(
      fun({Presents, Page, Expected}, Count) ->
              Result =
                  svc_m5_orangef:catalogue("postpaid",
                    Page, [{recompenses, Presents}|Data], Description_fun),
              {Count, Expected} = {Count, Result},
              Count + 1
      end,
      1,
      [ {[], 1,
        {ok, svc_m5_orangef:catalogue_header(Data, 1) ++
         [br,
          {pcdata,
           "Ce nombre de points ne vous permet pas encore"
           " de choisir un cadeau"}]}},
         {[{"40","1000","1","VX","1"}], 1, 
        {ok, Header_item ++
         [br,
          #hlink{href="erl://svc_m5_orangef:select_present?40&" ++
                 httputil:esc_get_post("20 SMS ou 7 MMS") ++ "&1000&1&1",
                 contents=[{pcdata, "20 SMS ou 7 MMS =1000pts"}]},
          br,
          #hlink{href="m5.xml#choix_par_usages",
                 contents=[{pcdata, "Choix par usage"}]},
          br,
          #hlink{href="m5.xml#plus_infos",
                 contents=[{pcdata, "+d'infos"}]}
         ]}},
        {[{"41", "2500","2","AB","1"}, {"40", "2000","1","CD","1"}], 1,
        {ok, Header_item ++
         [br,
          #hlink{href="erl://svc_m5_orangef:select_present?41&" ++
                 httputil:esc_get_post("30min com fixe+mobOrange") ++ "&2500&2&1",
                 contents=[{pcdata, "30min com fixe+mobOrange =2500pts"}]},
          br,
          #hlink{href="erl://svc_m5_orangef:select_present?40&" ++ 
                 httputil:esc_get_post("20 SMS ou 7 MMS") ++ "&2000&1&1",
                 contents=[{pcdata, "20 SMS ou 7 MMS =2000pts"}]},
          br,
          #hlink{href="m5.xml#choix_par_usages",
                 contents=[{pcdata, "Choix par usage"}]},
          br,
          #hlink{href="m5.xml#plus_infos",
                 contents=[{pcdata, "+d'infos"}]}
         ]}},
        {[{"41", "2500","3","AB","1"}, {"40", "2000","3","AB","1"}, {"50", "1200","3","AB","1"}], 1,
        {ok, Header_item ++
         [br,
          #hlink{href="erl://svc_m5_orangef:select_present?41&" ++ 
                 httputil:esc_get_post("30min com fixe+mobOrange") ++ "&2500&3&1",
                 contents=[{pcdata, "30min com fixe+mobOrange =2500pts"}]},
          br,
          #hlink{href="erl://svc_m5_orangef:select_present?40&" ++
                 httputil:esc_get_post("20 SMS ou 7 MMS") ++ "&2000&3&1",
                 contents=[{pcdata, "20 SMS ou 7 MMS =2000pts"}]},
          br,
          #hlink{href="erl://svc_m5_orangef:catalogue_page?2",
                 contents=[{pcdata, "Suite"}]},
          br,
          #hlink{href="m5.xml#choix_par_usages",
                 contents=[{pcdata, "Choix par usage"}]},
          br,
          #hlink{href="m5.xml#plus_infos",
                 contents=[{pcdata, "+d'infos"}]}
         ]}},
       {[{"99","1000","","",""}], 1, error}
      ]).


decode() ->
    BodyResp = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <soap:Envelope xmlns:impl=\"http://localhost:8080/webserv_if/services/\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\">
  <soap:Body>
<getConsultationCadeauxReponse>
        <date>18/04/2006</date>
        <heure>15:58:41</heure>
        <codeRet>0</codeRet>
        <messageRet/>
        <requete>
                <dossier>0601020304</dossier>
                <canal>SWI</canal>
                <idConseiller>JDGTRA</idConseiller >
                <idTypeUsage>CO</idTypeUsage>
                <idTypeRecompense/>
                <indRestitution>0</indRestitution>
                <donneesClient> 
                        <idDossierOEE>1234567890</idDossierOEE>
                        <numeroClient>0061295590</numeroClient>
                        <codeProduit>6</codeProduit>
                        <codeOffre>J03PA</codeOffre>
                        <etatDossier>A</etatDossier>
                        <codeRecouvrement>00</codeRecouvrement>
                        <segment>CUR</segment>
                        <indBonus>true</indBonus>
                        <indSIRET>false</indSIRET>
                </donneesClient>
        
        </requete>
        <resultat>
                <IN1>true</IN1>
                <IN2>true</IN2>
                <IN3>true</IN3>
                <solde>2500</solde>
                <pointsLimites/>
                <pointsCB>120</pointsCB>
                <jourLimitePts/>
                <codeEligibleBurn>OK</codeEligibleBurn>
                <causeNonEligibiliteBurn/>
                <isAdherentM5Plus>true</isAdherentM5Plus>
                <isCibleM5Plus>true</isCibleM5Plus>
                <isCibleM5bO/>
                <idFederation/>
                <listeDetailSolde>
                        <detailSolde>
                                <nbPoints>500</nbPoints>
                                <jourLimitePts>31/12/2006</jourLimitePts>
                        </detailSolde>
                        <detailSolde>
                                <nbPoints>2000</nbPoints>
                                <jourLimitePts>31/12/2007</jourLimitePts>
                        </detailSolde>
                </listeDetailSolde>
                <codeEligibleAdhesion/>
                <isAdherentBonus/>
                <catalogue>
                        <listeTypeUsage>
                                <typeUsage>
                                        <idTypeUsage>CO</idTypeUsage>
                                        <libelleTypeUsage>Services de comm</libelleTypeUsage>
 <listeTypeRecompense>
        <typeRecompense>
                <idTypeRecompense>4</idTypeRecompense>
                <libelleTypeRecompense>SMS/MMS photos</libelleTypeRecompense>
                <codeEligibleRecompense>OK</codeEligibleRecompense >
                <CauseNonEligibiliteRecompense/>
                <delaiActivation>24/07/2007</delaiActivation>
                <listeRecompense>
                        <recompense>
                                <idRecompense>55</idRecompense>
                                <libelleLongRecompense>20 SMS / 7 MMS</libelleLongRecompense>
                                <libelleCourtRecompense>20SMS/MMS</libelleCourtRecompense>
                                <isActivable>true</isActivable>
                                <prix>100</prix>
                                <prixAvecRemise/>
                                <listeTypeRecompenseBase>
                                        <typeRecompenseBase>
                                                <idTypeRecompense>22</idTypeRecompense>
                                                <libelleTypeRecompense>SMS HP</libelleTypeRecompense>
                                                <montant>20</montant>
                                                <typeUnite>3</typeUnite>
                                                <libelleUnite>SMS</libelleUnite>
                                        </typeRecompenseBase>
                                        <typeRecompenseBase>
                                                <idTypeRecompense>23</idTypeRecompense>
                                                <libelleTypeRecompense>MMS photos</libelleTypeRecompense>
                                                <montant>7</montant>
                                                <typeUnite>4</typeUnite>
                                                <libelleUnite>MMS</libelleUnite>
                                        </typeRecompenseBase>
                                </listeTypeRecompenseBase>
                        </recompense>
                        <recompense>
                                <idRecompense>56</idRecompense>
                                <prix>150</prix>
                        </recompense>
                </listeRecompense>
        </typeRecompense>
        <typeRecompense>
                <delaiActivation>1</delaiActivation>
                <idTypeRecompense>401</idTypeRecompense>
                <listeRecompense>
                        <recompense>
                                <idRecompense>60</idRecompense>
                                <prix>10</prix>
                        </recompense>
                        <recompense>
                                <idRecompense>66</idRecompense>
                                <prix>15</prix>
                        </recompense>
                </listeRecompense>
        </typeRecompense>
</listeTypeRecompense>
 <idTypeUsage>VX</idTypeUsage>
 <libelleTypeUsage>Voix</libelleTypeUsage>
 <listeTypeRecompense>
 <typeRecompense>
 <idTypeRecompense>401</idTypeRecompense>
 <delaiActivation>1</delaiActivation>
  <listeRecompense>
   <recompense>
    <idRecompense>60</idRecompense>
    <prix>10</prix>
    </recompense>
    <recompense>
    <idRecompense>66</idRecompense>
    <prix>15</prix>
   </recompense>
  </listeRecompense>
 </typeRecompense>
</listeTypeRecompense>
</typeUsage>
                        </listeTypeUsage>
                </catalogue>
        </resultat>
</getConsultationCadeauxReponse>
</soap:Body>
</soap:Envelope>",
    Dec = soaplight:decode_body(BodyResp,opal),
     {getConsultationCadeauxReponse,[{codeRet,"0"},
                                     {solde,"2500","120","18/04/2006"},
                                     {echeance,[],[]},
                                     {type_usage,["CO","VX"]},
                                     {recompenses,[{"55","100","24/07/2007","4","CO"},
                                                   {"56","150","24/07/2007","4","CO"},
                                                   {"60","10","1","401","CO"},
                                                   {"66","15","1","401","CO"},
                                                   {"60","10","1","401","VX"},
                                                   {"66","15","1","401","VX"}]}]} = Dec,
    ok.

online() ->
    profile_manager:rpc(fake_opal_server, start, []),
    profile_manager:rpc(oma_code,reload,[]),
    profile_manager:rpc(oma_config,reload,[]),
    test_util_of:reset_prisme_counters(prisme_counters()),    
    test_util_of:online(test_123_m5_test_adherent, test_adherent()),
    test_util_of:online(test_123_m5_test_adherent_cadeaux, test_adherent_cadeaux()),
    test_util_of:online(test_123_m5_test_non_adherent_pcm, test_non_adherent_pcm()),
    profile_manager:rpc(fake_opal_server, stop, []),
    ok.

test_adherent() ->
    Msisdn = test_util_of:generate_msisdn_from_uid(?Uid),
    init_adherent(Msisdn)++
    lists:append([test_adherent_davantage(Sub) || Sub <- [postpaid, cmo]])++
    ["Test reussi"].

test_adherent_cadeaux() ->
    Msisdn = test_util_of:generate_msisdn_from_uid(?Uid),
    init_adherent_cadeaux(Msisdn, {"73","3500"})++
    lists:append([test_adherent_cadeaux(Sub, {"73","3500"}) || Sub <- [postpaid, cmo]])++
    ["Test reussi"].

test_non_adherent_pcm() ->
    Msisdn = test_util_of:generate_msisdn_from_uid(?Uid),
    init_non_adherent(Msisdn)++
    lists:append([test_non_adherent_pcm(Sub) || Sub <- [postpaid, cmo]])++
    ["Test reussi"].


init_adherent_TU("CO") ->
    [adherent,
     {solde, "7200"},
     {pointsCB, "120"}, 
     {echeance, "1900", "18/03/2006"},
     {type_usage, ["CO"]},
     {idTypeRecompense, "5"},
     {recompenses,[
        {"109","700"},
        {"110","350"},
        {"111","700"},
        {"112","1400"},
        {"38","1000"},
        {"61","500"},
        {"19","1000"},
        {"18","2000"}
     ]},
     {delaiActivation,"25/12/2007"}];
init_adherent_TU("VX") ->
    [adherent,
     {solde, "7200"},
     {pointsCB, "120"}, 
     {echeance, "1900", "18/03/2006"},
     {type_usage, ["VX"]},
     {idTypeRecompense, "5"},
     {recompenses,[ 
        {"104","350"},
        {"71","3500"},
        {"75","5600"},
        {"72","5600"},
        {"78","1050"},
        {"80","1400"},
        {"81","1050"},
        {"35","500"},
        {"16","5000"},
        {"17","8000"},
        {"23","8000"},
        {"20","1500"},
        {"21","2000"},
        {"24","1500"}
     ]},
     {delaiActivation,"25/12/2007"}];
init_adherent_TU("VI") ->
    [adherent,
     {solde, "7200"},
     {pointsCB, "120"}, 
     {echeance, "1900", "18/03/2006"},
     {type_usage, ["VI"]},
     {idTypeRecompense, "5"},
     {recompenses,[ 
        {"73","3500"}, 
        {"74","3500"},
        {"13","5000"},
        {"22","5000"}
     ]},
     {delaiActivation,"25/12/2007"}];
init_adherent_TU("CP") ->
    [adherent,
     {solde, "7200"},
     {pointsCB, "120"}, 
     {echeance, "1900", "18/03/2006"},
     {type_usage, ["CP"]},
     {idTypeRecompense, "5"},
     {recompenses,[
     ]},
     {delaiActivation,"25/12/2007"}];
init_adherent_TU("HD") ->
    [adherent,
     {solde, "7200"},
     {pointsCB, "120"}, 
     {echeance, "1900", "18/03/2006"},
     {type_usage, ["HD"]},
     {idTypeRecompense, "5"},
     {recompenses,[ 
        {"105","700"},
        {"106","700"},
        {"107","1050"},
        {"108","1400"},
        {"116","700"},
        {"60","1000"},
        {"66","1000"},
        {"67","1500"},
        {"69","2000"},
        {"115","1000"}
     ]},
     {delaiActivation,"25/12/2007"}].

init_adherent(Msisdn) ->
    Init_data = [non_adherent,
                 {solde, "7200"},
                 {pointsCB, "120"}, 
                 {echeance, "1900", "18/03/2006"},
                 {type_usage, ["CO", "VX", "VI", "CP", "HD"]},
                 {idTypeRecompense, "5"},
                 {recompenses, recompense_all()},
                 {delaiActivation,"25/12/2007"},
                 adherent,
                 {solde, "7200"},
                 {pointsCB, "120"}, 
                 {echeance, "1900", "18/03/2006"},
                 {type_usage, ["CO", "VX", "VI", "CP", "HD"]},
                 {idTypeRecompense, "5"},
                 {recompenses, recompense_all()},
                 {delaiActivation,"25/12/2007"}],
    %Data = [lists:append([init_adherent_TU(TU) || TU <- ["CO", "VX", "VI", "CP", "HD"]]) | Init_data],
    Data = Init_data,
    profile_manager:rpc(fake_opal_server, init_customer, [opal:dossier(Msisdn), Init_data]),
    test_util_of:set_parameter_for_test(
        pservices_orangef, 
        m5_horaire_ouverture,
        [{cmo,{0,0,1},{0,0,0}},
         {postpaid,{0,0,1},{0,0,0}}]).

init_adherent_cadeaux(Msisdn, Cadeaux) ->
    Init_data = [adherent,
                 {solde, "7200"},
                 {pointsCB, "120"}, 
                 {echeance, "1900", "18/03/2006"},
                 {type_usage, ["CO", "VX", "VI", "CP", "HD"]},
                 {idTypeRecompense, "5"},
                 {recompenses, [Cadeaux]},
                 {delaiActivation,"25/12/2007"}],
    profile_manager:rpc(fake_opal_server, init_customer, [opal:dossier(Msisdn), Init_data]),
    test_util_of:set_parameter_for_test(
        pservices_orangef,
        m5_horaire_ouverture,
        [{cmo,{0,0,1},{0,0,0}},
         {postpaid,{0,0,1},{0,0,0}}]).

init_non_adherent(Msisdn) ->
    Init_data = [non_adherent,
                 {solde, "7200"},
                 {pointsCB, "120"}, 
                 {echeance, "1900", "18/03/2006"},
                 {type_usage, ["CO", "VX", "VI", "CP", "HD"]},
                 {idTypeRecompense, "5"},
                 {recompenses, recompense_all()},
                 {delaiActivation,"25/12/2007"}],
    %Data = [lists:append([init_adherent_TU(TU) || TU <- ["CO", "VX", "VI", "CP", "HD"]]) | Init_data],
    Data = Init_data,
    profile_manager:rpc(fake_opal_server, init_customer, [opal:dossier(Msisdn), Init_data]),
    test_util_of:set_parameter_for_test(
        pservices_orangef, 
        m5_horaire_ouverture,
        [{cmo,{0,0,1},{0,0,0}},
         {postpaid,{0,0,1},{0,0,0}}]).


init_sub(postpaid) ->
    BundleA=#spider_bundle{priorityType="A",
                           restitutionType="FORF",
                           bundleType="0005",
                           bundleDescription="label forf",
                           bundleAdditionalInfo="I1|I2|I3",
                           credits=[#spider_credit{name="balance",unit="MMS",value="40"},
                                    #spider_credit{name="rollOver", unit="SMS", value="18"},
                                    #spider_credit{name="bonus", unit="TEMPS", value="2h18min48s"}]},
    Amounts=[{amount,[{name,"hfAdv"},{allTaxesAmount,"1.150"}]},
             {amount,[{name,"hfInf"},{allTaxesAmount,"1.350"}]}],
    profile_manager:create_default(?Uid,"postpaid")++
    profile_manager:set_bundles(?Uid,[BundleA])++
    profile_manager:update_spider(?Uid,profile,{amounts,Amounts})++
    profile_manager:update_spider(?Uid,profile,{offerPOrSUid,"GP"})++
    profile_manager:init(?Uid)++
    test_util_of:set_present_period_for_test(commercial_date_postpaid,[m5])++
    [];
init_sub(cmo) -> 
    profile_manager:create_default(?Uid,"cmo")++
    profile_manager:init(?Uid)++ 
    test_util_of:set_present_period_for_test(commercial_date_cmo,[m5])++
    [].

menu_code(postpaid) ->
    ?menu_code_postpaid;
menu_code(cmo) ->
    ?menu_code_cmo.
 
test_adherent_davantage(Sub) ->
    init_sub(Sub)++
    ["Test adherent davatage: "++atom_to_list(Sub)]++
    test_adherent_menu(menu_code(Sub))++
    test_adherent_davantage_mobile(menu_code(Sub))++
    test_adherent_menu_choix_par_usage(menu_code(Sub))++
    close_session()++
    ["Test OK"].

test_non_adherent_pcm(Sub) ->
    init_sub(Sub)++
    ["Test non adherent and PCM: "++atom_to_list(Sub)]++
    [{ussd2,
      [{send, menu_code(Sub)},
       {expect, "Vos programmes :.*1:Changer de mobile.*2:Programme de fidelite davantage mobile.*"},
       {send, "2"}, 
       {expect, "Avec davantage mobile, Orange recompense votre fidelite. Pour en savoir plus et decouvrir les cadeaux a gagner, connectez vous sur orange.fr > espace client"},
       {send, "8"},
       {expect, "Vos programmes :.*1:Changer de mobile.*2:Programme de fidelite davantage mobile.*"},
       {send, "1"},
       {expect, ".*1:Changer de mobile" ".*2.Mobiles proposes" ".*3.Reglement"},
       {send, "1"},
       {expect, "Avec le Programme Changer de mobile, renouvelez votre mobile sans minimum de points ou d'anciennete. Chaque mois, vous gagnez 20 pts \\+ 1 pt par euro depense"},
       {send, "8"},
       {expect, ".*1:Changer de mobile" ".*2.Mobiles proposes" ".*3.Reglement"},
       {send, "2"},
       {expect, "Des l'atteinte de 1200 points quelle que soit votre offre, vous beneficiez d'un prix tres attractif! Retrouvez notre catalogue de mobiles sur www.orange.fr."},
       {send, "8"},
       {expect, ".*1:Changer de mobile" ".*2.Mobiles proposes" ".*3.Reglement"},
       {send, "3"},
       {expect, "Toutes les conditions specifiques au Programme Changer de mobile, sont disponibles sur votre espace client sur www.orange.fr."}
      ]}
    ]++
    close_session()++
    ["Test OK"].


test_adherent_menu(Menu_code) ->
    [{title, "TEST ADHERENT MENU"},
     {ussd2,
      [{send, Menu_code},
       {expect, "Vos programmes :.*1:Changer de mobile.*2:Programme de fidelite Davantage mobile.*3:Programme de fidelite Davantage"},
       {send, "3"}, 
       {expect, "Avec Davantage, regroupez vos points de fidelite fixe, mobile et internet et accedez a encore plus de kdos. RDV sur http://davantage.orange.fr"}
      ]}
    ]++
    [].

test_adherent_davantage_mobile(Menu_code) ->
    [{title, "TEST ADHERENT - DAVATAGE MOBILE"},
     {ussd2, 
      [{send, Menu_code++"2"}, 
       {expect, ".*Suite.*Choix par usage.*d'info"}, 
       {send, "4"}, 
       {expect, "Avec Davantage, vous cumulez chaque mois des points que vous transformez en cadeaux \\(sms, min de com, options multimedia...\\).*Suite"},
       {send, "1"},
       {expect, "Davantage, c'est gratuit et sans engagement"}
      ]}
    ]++
    [].

test_adherent_menu_choix_par_usage(Menu_code) ->
    [{title, "TEST ADHERENT - MENU CHOIX PAR USAGE"},
     {ussd2, 
      [{send, Menu_code++"23"}, 
       {expect, ".*1:SMS et MMS"
                ".*2:Min de com en France metropolitaine"
                ".*3:Min de com a l'international"
                ".*4:Suite des usages"
                ".*8:Precedent"
                ".*9:Accueil"}, 
       {send, "4"}, 
       {expect, ".*1:Achat de pts davantage mobile"
                ".*2:Multimedia : TV/Messenger"
                ".*3:Multimedia : Mail/Internet Max"
                ".*4:Multimedia : Sport"
                ".*8:Precedent"
                ".*9:Accueil"},
       {send, "4"},
       {expect, ".*Option sport =.*pts"}
      ]}
    ]++
    [].

test_adherent_cadeaux(postpaid, Cadeaux) ->
    init_sub(postpaid)++   
    ["Test adherent cadeaux: Postpaid"]++
    test_adherent_each_cadeaux(?menu_code_postpaid, Cadeaux)++
    close_session()++
    ["Test OK"];

test_adherent_cadeaux(cmo, Cadeaux) ->
    init_sub(cmo)++
    ["Test adherent cadeaux: CMO"]++
    test_adherent_each_cadeaux(?menu_code_cmo, Cadeaux)++
    close_session()++
    ["Test OK"].

test_adherent_each_cadeaux(Menu_code, Cadeaux) ->
    [{title, "TEST ADHERENT EACH CADEAUX"++tuple_to_list(Cadeaux)},
     {ussd2, 
      [{send, Menu_code++"21"}, 
       {expect, "Vous avez commande.*1:Confirmer.*"}, 
       {send, "1"}, 
       {expect, "Votre commande a bien ete prise en compte. Un sms vous confirmera l'activation de votre cadeau. Votre nouveau solde est de .* pts."}
      ]}
    ]++
    [].

recompense_all() -> 
    [
        {"73","3500"}, 
        {"74","3500"},
        {"105","700"},
        {"106","700"},
        {"107","1050"},
        {"108","1400"},
        {"109","700"},
        {"110","350"},
        {"111","700"},
        {"112","1400"},
        {"104","350"},
        {"71","3500"},
        {"75","5600"},
        {"72","5600"},
        {"78","1050"},
        {"80","1400"},
        {"81","1050"},
        {"116","700"},
        {"13","5000"},
        {"22","5000"},
        {"60","1000"},
        {"66","1000"},
        {"67","1500"},
        {"69","2000"},
        {"38","1000"},
        {"61","500"},
        {"19","1000"},
        {"18","2000"},
        {"35","500"},
        {"16","5000"},
        {"17","8000"},
        {"23","8000"},
        {"20","1500"},
        {"21","2000"},
        {"24","1500"},
        {"115","1000"}
    ].

pcm_text() ->
    "1.Changer de mobile."
    "2.Mobiles proposes."
    "3.Reglement.".

pcm_text_changer_mobile() ->
    "Avec le Programme Changer de mobile, renouvelez votre mobile sans minimum de points ou d'anciennete. Chaque mois, vous gagnez 20 pts \\+ 1 pt par euro depense".

pcm_text_mobiles_proposes() ->
    "Des l'atteinte de 1200 points quelle que soit votre offre, vous beneficiez d'un prix tres attractif! Retrouvez notre catalogue de mobiles sur www.orange.fr.".

pcm_text_reglement() ->
    "Toutes les conditions specifiques au Programme Changer de mobile, sont disponibles sur votre espace client sur www.orange.fr.".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close_session() ->
    test_util_of:close_session().
