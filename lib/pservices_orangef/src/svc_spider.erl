-module(svc_spider).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([redirect_by_typeRestitution/2,
	 redirect_by_identifiant/2,
	 redirect_by_produit/2,
	 redirect_by_fileRestitutionType/2,
	 redir_si_credit_nul/4,
	 redir_si_montant_nul/4,
	 print_libelle/3,
	 print_libelleepuise/3,
	 print_infocompgodetA/3,
	 print_dureeHfDise/2,
	 print_dateValidite/3,
	 print_dateDesactivation/3,
	 print_dateProchFactu/2,
	 print_dateProchFactuInFmt/3,
	 print_dateProchFactuPlus1/2,
	 print_dateCouranteFactu/2,
	 print_dateHeureReactu/3,
	 print_dateReactu/2,
	 print_last_use_date/4,
	 print_somme_montant_hfAdv_hfInf/2,
	 print_somme_montant_hfAdv_hfInf2/2,
	 print_montant/3,
	 print_credit/5,
	 print_credits/4,
	 print_XXh/2,
	 print_solde_hour_min_sec/2,
	 restitGodets/3,
	 lienSiAjustableEtbonus/3,
	 lienSiGodetsCouD/3,
	 lienSiGodetsF/3,
	 lienSiAutresGodets/3,
	 lienSuiviConsoPlus/3,
	 lienSousMenu/1,
	 dme_suiviconsoplus/1,
	 opim_suiviconsoplus/1,
	 suiviconsodetaille/1,
	 next_suiviconsodetaille/2,
	 do_restitGodet/2,
	 lien_offre_boost/3,
	 restit_offre_boost/1,
	 restit_offre_miro/2,
	 typeRestitution/1,
	 get_codedomaine/1,
	 produit2codedomaine/2,
	 get_godets_miro/1,
	 display_page/2,
	 read_field/2,
	 redirect_by_GodetCouD/3,
	 do_suiviconsodetaille/1,
	 redirect_si_Godet/4
	]).

-export([cb_end_sess/2]).

-export([get_custMsisdn/1,
	 get_declinaison/1,
	 get_spider_info/1,
	 get_spider_info_and_subscription/1,
	 get_offerPOrSUid/1,
	 get_fileState/1,
	 set_availability/2,
	 get_availability/1,
	 get_record_name/1]).
-export([slog_info/3]).

-include_lib("oma/include/slog.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pserver/include/page.hrl").
-include("../../pdist_orangef/include/spider.hrl").
-include("../../pservices_orangef/include/ftmtlv.hrl").
-include("../../pservices_orangef/include/postpaid.hrl").
-include("../../pservices_orangef/include/opim.hrl").
-include("../../pservices_orangef/include/dme.hrl").

%% +deftype url()=string().
%% +deftype multilink()=ustring().
%% +deftype bundle_lvl()=string().  %% niveau du godet = "1"|"2"|"3"
%% +deftype ussd_lvl()=integer().   %% niveau USSD = 1|2|3
%% +deftype fmt()=string().         %% une string au format d'io_lib
%% +deftype amount_name()=string(). %% "hfDise"|"hfAdv".
%% +deftype credit_name()=string(). %% "rollOver"|"bonus"|"standard"|"consumed"
%%%% |"balance"|"excess"|
%% +deftype credit_unit()=string().   %% "TEMPS"|"VALEU"|"MINUT"
%% +deftype priority_type()=string(). %% "A"|"B"|"C"|"D".
%% +deftype date()=calendar:date().
%% +deftype time()=calendar:time().
%% +deftype datetime()=calendar:datetime().


%% +type redirect_by_typeRestitution(session(), multilink()) ->
%%  erlpage_result().
%%% Redirige en fonction du type de restitution du godet A (scripts postpaid)
redirect_by_typeRestitution(abs,MultiLink) ->
    Rules = plugin:parse_multilink(MultiLink, "equal"),
    lists:map(fun ({Pat,Target}) -> {redirect,abs,Target} end, Rules);
redirect_by_typeRestitution(Session,MultiLink) ->
    OfferRestitType = typeRestitution(Session),
    plugin:redirect_multi(Session, "equal", OfferRestitType, MultiLink).

typeRestitution(Session) ->
    case get_godetA(Session) of
	#bundle{restitutionType=RT} when RT /= undefined -> RT;
	_  -> ""
    end.

%% +type redirect_by_identifiant(session(), multilink()) -> erlpage_result().
%%% Redirige en fonction du champ id du godet A (scripts dme)
redirect_by_identifiant(abs,MultiLink) ->
    Rules = plugin:parse_multilink(MultiLink, "equal"),
    lists:map(fun ({Pat,Target}) -> {redirect,abs,Target} end, Rules);
redirect_by_identifiant(Session,MultiLink) ->
    GodetA_Id = case get_godetA(Session) of 
		    #bundle{bundleType=BundleType} 
		    when BundleType /= undefined -> 
			BundleType;
		    _ -> 
			case read_field(fileState,Session) of
			    "OSEN" ->
				slog:event(trace, ?MODULE, redirect_by_identifiant_fileState, "OSEN"),
				"osen";
			    _ ->
				slog:event(trace, ?MODULE, redirect_by_identifiant_fileState, ""),
				""
			end
		end,
    plugin:redirect_multi(Session, "equal", GodetA_Id, MultiLink).

%% +type redirect_by_produit(session(), multilink()) -> erlpage_result().
%%% Redirige en fonction du champ offerPOrSUid
redirect_by_produit(abs,MultiLink) ->
    Rules = plugin:parse_multilink(MultiLink, "equal"),
    lists:map(fun ({Pat,Target}) -> {redirect,abs,Target} end, Rules);
redirect_by_produit(Session,MultiLink) ->
    OfferPOrSUid = read_field(offerPOrSUid, Session),
    plugin:redirect_multi(Session, "equal", OfferPOrSUid, MultiLink).

%% +type redirect_by_fileRestitutionType(session(), multilink()) ->
%%  erlpage_result().
%%% Redirige en fonction du champ fileRestitutionType
redirect_by_fileRestitutionType(abs,MultiLink) ->
    Rules = plugin:parse_multilink(MultiLink, "equal"),
    lists:map(fun ({Pat,Target}) -> {redirect,abs,Target} end, Rules);
redirect_by_fileRestitutionType(Session,MultiLink) ->
    FileRestitutionType = read_field(fileRestitutionType, Session),
    plugin:redirect_multi(Session, "equal", FileRestitutionType, MultiLink).


%% +type redir_si_credit_nul(session(), credit_name(), url(), url()) ->
%%  erlinclude_result().
redir_si_credit_nul(abs, CreditName, Url_nul, Url_non_nul) ->
    [{redirect, abs, Url_nul},{redirect, abs, Url_non_nul}];
redir_si_credit_nul(Session, CreditName, Url_nul, Url_non_nul) ->
    GodetA = get_godetA(Session),
    case etat_godet(GodetA, CreditName) of
	epuise ->  {redirect, Session, Url_nul};
	actif  ->  {redirect, Session, Url_non_nul}
    end.

%% +type is_cred_nul(credit()) -> bool().
is_cred_nul(#credit{value="0"}) -> true;
is_cred_nul(#credit{value="0min"}) -> true;
is_cred_nul(#credit{value="0h00min00s"}) -> true;
is_cred_nul(#credit{}) -> false.

%% +type etat_godet(bundle(),CreditName::string()) -> epuise | actif.
%%%% Regarde si le CreditName credit d'un godet est nul
etat_godet(#bundle{credits=Credits}, CreditName) when list(Credits) ->
    case lists:keysearch(CreditName, #credit.name, Credits) of
	false -> 
	    slog:event(warning, ?MODULE, searching_failed, {CreditName, #credit.name, Credits}),
 	    epuise;
	{value, Credit} -> 
	    case is_cred_nul(Credit) of
		true -> epuise;
		false -> actif
	    end
    end;
etat_godet(_, _) -> epuise.
	    
%% +type redir_si_montant_nul(session(), credit_name(), url(), url()) ->
%%  erlinclude_result().
redir_si_montant_nul(abs, MontantName, Url_nul, Url_non_nul) ->
    [{redirect, abs, Url_nul},{redirect, abs, Url_non_nul}];
redir_si_montant_nul(Session, MontantName, Url_nul, Url_non_nul) ->
    case read_field(amounts, Session) of
	Amounts when list(Amounts) ->
	    case lists:keysearch(MontantName, #amount.name, Amounts) of
		{value,#amount{allTaxesAmount=Val}} when Val /= "0" ->
		    {redirect, Session, Url_non_nul};
		_ -> 
		    {redirect, Session, Url_nul}
	    end;
	_ ->
	    {redirect, Session, Url_nul}
    end.

get_godet(Session,GodetName) -> 
    get_godet(Session, undefined,GodetName).

%% +type get_godet(session(), bundle_lvl(), godetname) -> bundle() | undefined.
get_godet(Session, BundleALvl,GodetName) -> 
    case catch read_field(bundles, Session) of
	Bundles when list(Bundles) ->
	    case findgodet(BundleALvl, Bundles, GodetName) of
		not_found -> 
		    slog:event(failure, ?MODULE, no_godet,
			       (Session#session.prof)#profile.msisdn),
		    undefined;
		Godet -> Godet		
	    end;
	_ ->	undefined    
    end.

%% +type get_godetA(session()) -> bundle() | undefined.
get_godetA(Session) -> 
    get_godetA(Session, undefined).

%% +type get_godetA(session(), bundle_lvl()) -> bundle() | undefined.
get_godetA(Session, BundleALvl) -> 
    case catch read_field(bundles, Session) of
	Bundles when list(Bundles) ->
	    case findgodetA(BundleALvl, Bundles) of
		not_found -> 
		    slog:event(failure, ?MODULE, no_godetA,
			       (Session#session.prof)#profile.msisdn),
		    undefined;
		GodetA -> 
		    GodetA		
	    end;
	_ ->	undefined    
    end.

%% +type findgodetA(bundle_lvl(), [bundle()]) -> bundle()|not_found.
findgodetA(Lvl,[#bundle{priorityType="A"}=G|_]) -> G;
findgodetA(Lvl,[]) -> not_found;
findgodetA(Lvl,[H|T]) -> findgodetA(Lvl,T).

findgodet(undefined,[#bundle{priorityType=GodetName}=G|_],GodetName) -> G;
findgodet(Lvl,[#bundle{priorityType=GodetName,bundleLevel=undefined}=G|_],GodetName) -> G;
findgodet(Lvl,[#bundle{priorityType=GodetName,bundleLevel=Lvl}=G|_],GodetName) -> G;
findgodet(Lvl,[],GodetName) -> not_found;
findgodet(Lvl,[H|T],GodetName) -> findgodet(Lvl,T,GodetName).

print_dateHeure(Fmt, Date, DateFormat, HourDisplay)->
    JJMM = svc_util_of:sprintf_datetime_by_format(Date,DateFormat),
    case HourDisplay of
	displayHour ->
	    HHMM = svc_util_of:sprintf_datetime_by_format(Date,"hm"),
	    [{pcdata, flat_fmt(Fmt, [JJMM, HHMM])}];
	noDisplayHour ->
	    [{pcdata, flat_fmt(Fmt, [JJMM])}]
    end.

%% +type printDateHeureReactu(session(), arg(), fmt()) -> erlinclude_result().
print_dateHeureReactu(abs, Arg, Fmt) -> 
    [{pcdata, flat_fmt(Fmt, Arg)}];

print_dateHeureReactu(Session,Arg, Fmt) ->
    case get_godetA(Session) of
 	#bundle{reactualDate=undefined} ->
	    MSISDN = (Session#session.prof)#profile.msisdn,
	    slog:event(service_ko, ?MODULE, date_undefined,{msisdn,MSISDN}),
	    [{pcdata, ["Au inconnu "]}];
 	#bundle{reactualDate=Date} ->
	    print_dateHeure(Fmt, Date, Arg, displayHour);
	_ ->[]
    end.

%% +type print_dateReactu(session(), fmt()) -> erlinclude_result().
print_dateReactu(abs, Fmt) ->
    [{pcdata, flat_fmt(Fmt,["JJ/MM"])}];
print_dateReactu(Session, Fmt) ->
    case get_godetA(Session) of
 	#bundle{reactualDate=undefined} ->
	    MSISDN = (Session#session.prof)#profile.msisdn,
	    slog:event(service_ko, ?MODULE, date_undefined,{msisdn,MSISDN}),
	    [{pcdata, ["Au inconnu "]}];
	#bundle{reactualDate=Date} ->
	    print_dateHeure(Fmt, Date, "dm", noDisplayHour);
	_ -> []
    end.

%% +type print_dateDesactivation(session(), arg(), fmt()) -> erlinclude_result().
print_dateDesactivation(abs, Arg, Fmt) -> 
    [ {pcdata,flat_fmt(Fmt, [Arg])} ];
print_dateDesactivation(Session, Arg, Fmt) ->
    case get_godetA(Session) of
 	#bundle{desactivationDate=undefined} ->
	    MSISDN = (Session#session.prof)#profile.msisdn,
	    slog:event(service_ko, ?MODULE, date_undefined,{msisdn,MSISDN}),
	    [{pcdata, ["Au inconnu "]}];
 	#bundle{desactivationDate=Date} ->
	    print_dateHeure(Fmt, Date, Arg, noDisplayHour);
 	_ -> []
    end.

print_last_use_date(abs,Fmt, Arg,GodetName) -> 
    [ {pcdata,lists:flatten(Arg)} ];
print_last_use_date(Session,Fmt, Arg, GodetName) ->
    case get_godet(Session,GodetName) of
 	#bundle{lastUseDate=undefined} ->
	    MSISDN = (Session#session.prof)#profile.msisdn,
	    slog:event(service_ko, ?MODULE, date_undefined,{msisdn,MSISDN}),
	    [{pcdata, ["Au inconnu "]}];
 	#bundle{lastUseDate=Date} ->
	    print_dateHeure(Fmt, Date, Arg, noDisplayHour);
 	_ -> []
    end.


%% +type flat_fmt(fmt(), [term]) -> string().
flat_fmt(FMT, ARGs) -> lists:flatten(io_lib:format(FMT, ARGs)).

%% +type print_libelle(session(), bundle_lvl(), fmt()) -> erlinclude_result().
print_libelle(abs, BLvl, Fmt) -> [ {pcdata,flat_fmt(Fmt, ["LABEL"])} ];
print_libelle(Session, BLvl, Fmt) ->
    case get_godetA(Session, BLvl) of
	#bundle{bundleDescription=Libelle} when Libelle /= undefined ->
	    [ {pcdata,flat_fmt(Fmt, [Libelle])} ];
	_ -> []
    end.

%% +type print_infocompgodetA(session(), CreditName::string(),
%%                            bundle_lvl()) -> 
%%                            erlinclude_result().
print_infocompgodetA(abs, CreditName, BLvl) -> [ {pcdata,"InfoComp"}, br];
print_infocompgodetA(Session, "hfAdv_hfInf", BLvl) ->
    case get_godetA(Session, BLvl) of
	#bundle{bundleAdditionalInfo=IC}=GA ->
	    Etat = case somme_montant_hfAdv_hfInf(Session) of
		       0.0 -> epuise;
		       _ -> actif
		   end,
	    [ {pcdata, addinfogodet(IC, Etat,"~s\n")}];
	_ -> []
    end;
print_infocompgodetA(Session, CreditName, BLvl) ->
    case get_godetA(Session, BLvl) of
	#bundle{bundleAdditionalInfo=IC}=GA ->
	    Etat = etat_godet(GA, CreditName),
	    [ {pcdata, addinfogodet(IC, Etat,"~s\n")}];
	_ -> []
    end.

%% +type print_libelleepuise(session(), bundle_lvl(), fmt()) ->
%%  erlinclude_result().
print_libelleepuise(abs, BLvl, Fmt) -> [ {pcdata,flat_fmt(Fmt, ["LABEL"])} ];
print_libelleepuise(Session, BLvl, Fmt) ->    
    case get_godetA(Session, BLvl) of
	#bundle{exhaustedLabel=LibelleEpuise} when LibelleEpuise /= undefined ->
	    [ {pcdata,flat_fmt(Fmt, [LibelleEpuise])} ];
	_ -> []
    end.

%% +type print_dureeHfDise(session(), fmt()) -> erlinclude_result().
print_dureeHfDise(abs, Fmt) ->
    [ {pcdata,flat_fmt(Fmt, ["DUREE_HF_DISE"])} ];
print_dureeHfDise(Session, Fmt) ->
    case read_field(durationHf, Session) of
	undefined -> [];
	ODD -> [{pcdata, flat_fmt(Fmt, [ODD])}]
    end.

print_fieldDate(Session, Arg, Fmt, Field, IsDisplayHour) ->
    case read_field(Field,Session) of
	undefined -> [];
	Date ->
	    print_dateHeure(Fmt, Date, Arg, IsDisplayHour)
    end.

%% +type print_dateValidite(session(), arg(), fmt()) -> erlinclude_result().
print_dateValidite(abs, Arg, Fmt) -> [ {pcdata,flat_fmt(Fmt, [Arg])} ];
print_dateValidite(Session, Arg, Fmt) ->
    print_fieldDate(Session, Arg, Fmt, validityDate, noDisplayHour).

%% +type print_dateProchFactu(session(), fmt()) -> erlinclude_result().
print_dateProchFactu(abs,Fmt) -> [ {pcdata,flat_fmt(Fmt, ["JJ/MM"])} ];
print_dateProchFactu(Session,Fmt) ->
    print_fieldDate(Session, "dm", Fmt, nextInvoice, noDisplayHour).

%% +type print_dateProchFactuInFmt(session(), fmt(), dateFmt()) -> erlinclude_result().
print_dateProchFactuInFmt(abs,Fmt,DateFmt) ->
     [ {pcdata,flat_fmt(Fmt, ["JJ/MM"])} ];
print_dateProchFactuInFmt(Session,Fmt, DateFmt) ->
    print_fieldDate(Session, DateFmt, Fmt, nextInvoice, noDisplayHour).

%% +type print_dateProchFactuPlus1(session(), fmt()) -> erlinclude_result().
print_dateProchFactuPlus1(abs,Fmt) ->
    [ {pcdata,flat_fmt(Fmt, ["JJ/MM"])} ];
print_dateProchFactuPlus1(Session,Fmt) ->
    case read_field(nextInvoice,Session) of
	undefined -> [];
	{Date,_} ->
	    {Date2,_Heure} = add1day({Date,{12,0,0}}),
	    print_dateHeure(Fmt, {Date2,_Heure}, "dm", noDisplayHour)
    end.

%% +type add1day(datetime()) -> datetime().
add1day(DateTime) ->
    svc_util_of:add_seconds_to_datetime(DateTime, 24*3600).

%% +type print_dateCouranteFactu(session(), fmt()) -> erlinclude_result().
print_dateCouranteFactu(abs,Fmt) -> [ {pcdata,flat_fmt(Fmt, ["JJ/MM"])} ];
print_dateCouranteFactu(Session,Fmt) ->
    print_fieldDate(Session, "dm", Fmt, invoiceDate, noDisplayHour).


%% +type print_somme_montant_hfAdv_hfInf(session(), fmt()) ->
%%  erlinclude_result().
print_somme_montant_hfAdv_hfInf(abs, Fmt) ->
    print_montant(abs, '_', Fmt);
print_somme_montant_hfAdv_hfInf(Session, Fmt) ->
    case somme_montant_hfAdv_hfInf(Session) of
	0.0 -> [];
	SumFloat ->
	    SumString = trunc_and_conv_to_string(SumFloat),
	    String2 = flat_fmt(Fmt ,[SumString]),
	    [ {pcdata, String2} ]
    end.

somme_montant_hfAdv_hfInf(Session) ->
    case read_field(amounts,Session) of
	Amounts when list(Amounts) ->
	    getamount("hfAdv",Amounts) + getamount("hfInf",Amounts);
	undefined -> 0.0
    end.

%% +type print_somme_montant_hfAdv_hfInf2(session(), fmt()) ->
%%  erlinclude_result().
%%% Affiche 0.0 si nul
print_somme_montant_hfAdv_hfInf2(abs, Fmt) ->
    print_montant(abs, '_', Fmt);
print_somme_montant_hfAdv_hfInf2(Session, Fmt) ->
    case print_somme_montant_hfAdv_hfInf(Session, Fmt) of
	[] -> [ {pcdata, flat_fmt(Fmt ,["0.00"])} ];
	ERLINCLUDE_RES -> ERLINCLUDE_RES
    end.


%% +type getamount(amount_name(), [amount()]) -> float().
getamount(Name, Amounts) ->
    case lists:keysearch(Name,#amount.name,Amounts) of
	{value,#amount{allTaxesAmount=Val}} -> number_list_to_float(Val);
	false -> 0.0
    end.


%% +type print_montant(session(), amount_name(), fmt()) -> erlinclude_result().
print_montant(abs, MontantName, Fmt) ->
    String = flat_fmt(Fmt, ["XXX.XX"]),
    [ {pcdata, String} ];
print_montant(Session, MontantName, Fmt) ->
    case read_field(amounts,Session) of
	Amounts when list(Amounts) ->
	    case lists:keysearch(MontantName,#amount.name,Amounts) of
		{value,#amount{allTaxesAmount=Val}} ->
		    String = format_montant(Fmt,Val),
		    [ {pcdata, String} ];
		false -> []
	    end;
	undefined -> []
    end.

%% +type format_montant(fmt(), string()) -> string().
format_montant(Fmt,FloatStr) ->
    Float = number_list_to_float(FloatStr),
    String = trunc_and_conv_to_string(Float),
    flat_fmt(Fmt, [String]).

%% +type trunc_and_conv_to_string(float()) -> string().
trunc_and_conv_to_string(Float) ->
    Float2 = round(Float*100)/100,
    lists:flatten(io_lib:format("~.2f", [Float2])).

%% +type print_credit(session(), string(), credit_name(), credit_unit(), fmt())
%% -> erlinclude_result().
print_credit(abs, BLvl, CreditName, CreditUnit, Fmt) ->
    String = flat_fmt(Fmt, [CreditName++"_",CreditUnit]),
    [ {pcdata, String} ];
print_credit(Session, BLvl, CreditName, CreditUnit, Fmt) ->
    case get_godetA(Session, BLvl) of
	#bundle{credits=Credits} when list(Credits) ->
	    case creditsearch(CreditName,CreditUnit,Credits) of
		{value,#credit{value=Val}} ->
		    Val2 = format_val(Val, CreditUnit),
		    Lab = unit_to_label(CreditUnit),
		    String = flat_fmt(Fmt, [Val2, Lab]),
		    [ {pcdata, String} ];
		false ->
		    []
	    end;
	_ -> []
    end.

%% +type print_XXh(session(), fmt()) -> erlinclude_result().
print_XXh(abs, Fmt) ->
    String = flat_fmt(Fmt, ["XXh"]),
    [ {pcdata, String} ];
print_XXh(Session, Fmt) ->
    case get_godetA(Session) of
	#bundle{credits=Credits} when list(Credits) ->
	    case creditsearch("standard","TEMPS",Credits) of
		{value,#credit{value=V}} ->
		    V2=lists:takewhile(fun(Char) -> Char/=$h end, V)++"h",
		    String = flat_fmt(Fmt,[V2]),
		    [ {pcdata, String} ];
		false ->
		    []
	    end;
	_ -> []
    end.

print_solde_hour_min_sec(abs, GodetName) ->
    String = lists:flatten("XXhYYminZZs"),
    [ {pcdata, String} ];
print_solde_hour_min_sec(Session, GodetName) ->
    case get_godet(Session,GodetName) of
	#bundle{credits=Credits} when list(Credits) ->
	    case creditsearch("balance","TEMPS",Credits) of
		{value,#credit{value=V}} ->
		    [ {pcdata, lists:flatten(V)} ];
		false ->
		    []
	    end;
	_ -> []
    end.

%% +type print_credits(session(), string(), credit_name(), fmt()) ->
%%  erlinclude_result().
print_credits(abs, Lvl, CreditName, Fmt) ->
    String = flat_fmt(Fmt,["X soit Y ou Z"]),
    [#nbblock{contents=[{pcdata,String}]}];
print_credits(Session, Lvl, CreditName, Fmt) ->
    Term = (Session#session.prof)#profile.terminal,
    Ulvl = terminal_of:ussd_level(Term#terminal.ussdsize),
    case get_godetA(Session, Lvl) of
	#bundle{credits=Credits} when list(Credits) ->
	    String = restit_credits(CreditName, Fmt, Credits, Ulvl),
	    [#nbblock{contents=[{pcdata,String}]}];
	_ -> []
    end.

%% +type restit_credits(credit_name(), fmt(), [credit()], ussd_lvl()) ->
%%  string().
restit_credits(CreditName,Fmt,undefined,Ulvl) -> "";
restit_credits(CreditName,Fmt,Credits,Ulvl) ->
    case lists:filter(fun(#credit{name=N}) -> N==CreditName end, Credits) of
 	[] -> "";
 	FCredits -> 
	    String = restit_creds_by_pair(FCredits, Ulvl),
	    flat_fmt(Fmt, [String])
    end.

%% +type restit_creds_by_pair(credit(), ussd_lvl()) -> string().
restit_creds_by_pair([Cred_1,Cred_2|Rest],Ulvl) ->
    U1 = Cred_1#credit.unit,
    U2 = Cred_2#credit.unit,
    Sep = case usage_ou_monnaie(U1) == usage_ou_monnaie(U2) of
	      true -> " ou ";
	      false -> " soit "
	  end,
    val_unit_inf(Cred_1, Ulvl) ++ Sep ++
	restit_creds_by_pair([Cred_2|Rest], Ulvl);
restit_creds_by_pair([Cred],Ulvl) ->
    val_unit_inf(Cred, Ulvl).

%% +type usage_ou_monnaie(credit_unit()) -> atom().
usage_ou_monnaie("VALEU") -> monnaie;
usage_ou_monnaie(_) -> usage.


%% +type val_unit_inf(credit(), ussd_lvl()) -> string().
val_unit_inf(#credit{value=V,unit=U,additionalInfo=AI}, Ulvl) ->
    format_val(V,U) ++ unit_to_label(U) ++
	addinfocred(AI, Ulvl).

%% +type format_val(string(), credit_unit()) -> string().
format_val(Val, "VOLUM") ->
    case list_to_integer(Val) of
	X when X > 1023 -> integer_to_list(trunc(X/1024))++"Mo";
	Y -> Val ++ "Ko"
    end;
format_val(Val, "TEMPS") -> 
    lists:filter(fun(Char) -> (Char/=$i) and (Char/=$n) end, Val);
format_val(Val, "MINUT") ->
    lists:delete($i, Val);
format_val(Val,"VALEU") -> format_montant("~s", Val);
format_val(Val,"EURO") -> format_montant("~s EUR", Val);
format_val(Val, _) -> Val.    


%% +type creditsearch(credit_name(), credit_unit(), [credit()]) ->
%%  {value,credit()} | false.
creditsearch(Name,Unit,[#credit{name=Name,unit=Unit}=C|T]) -> {value,C};
creditsearch(Name,Unit,[H|T]) -> creditsearch(Name,Unit,T);
creditsearch(Name,Unit,[]) -> false.

%% +type suiviconsodetaille(session()) -> erlinclude_result().
suiviconsodetaille(abs) -> [{pcdata, "SUIVICONSOPLUS"}];
suiviconsodetaille(Session) ->
    case catch do_suiviconsodetaille(Session) of
	{'EXIT',Reason} ->
	    slog:event(failure, ?MODULE, svcp_non_dispo, Reason),
	    [{pcdata, "Votre suivi conso plus n'est pas disponible"}];
	ERLINCLUDE_RESULT ->
	    case is_list(ERLINCLUDE_RESULT) of
		true-> 
		    case ERLINCLUDE_RESULT of
			[{_,[{_,GodetCD}]},_]->			    
			    next_suiviconsodetaille(Session,GodetCD);
			_->
			    ERLINCLUDE_RESULT
		    end;
		_ ->
		    ERLINCLUDE_RESULT
	    end  
    end.	    

next_suiviconsodetaille(Session,GodetCD)->
    Item = case (string:len(GodetCD)) of
	       X when X>160 ->
		   %% in case of more than 160 chars, split into multiple pages
		   St1 = string:left(GodetCD,160),		   
		   %% get last position of ' '
		   Pos_to_split = string:rchr(St1,$ ),
		   {First,Last} = lists:split(Pos_to_split,GodetCD),
		   Href_suite="erl://svc_spider:next_suiviconsodetaille?"++Last,
		   Suite= [#hlink{href=Href_suite, contents=[{pcdata,"Suite"}]}],
		   svc_util_of:br_separate([{pcdata, First}]++Suite);
	       _ ->
		   [{pcdata,GodetCD}]
	   end,  
    {page, Session, #page{backtext=notext,menutext="Menu",items= Item}}.

%% +type do_suiviconsodetaille(session()) -> erlinclude_result().
do_suiviconsodetaille(#session{prof=#profile{subscription="mobi"}}=Session) ->
    menuGodets(Session, "1", "C") ++ menuGodets(Session, "1", "D");

do_suiviconsodetaille(#session{prof=#profile{subscription=Subscr}}=Session) ->
    restitGodets(Session, "1", "C") ++ restitGodets(Session, "1", "D").

%% +type restitGodets(session(), bundle_lvl(), priority_type()) ->
%%  erlinclude_result().
%%% Restitue tous les godets de meme priorite
menuGodets(abs, BLvl, PriorityType) ->
    [#nbblock{contents=[{pcdata,"GODET_"++PriorityType}, br]}];
menuGodets(Session, BLvl, PriorityType) ->
    Subscr = svc_util_of:get_souscription(Session),
    Term = (Session#session.prof)#profile.terminal,
    Ulvl = terminal_of:ussd_level(Term#terminal.ussdsize),
    case read_field(bundles, Session) of
	Bundles when list(Bundles) ->
	    FunFilt = fun(#bundle{priorityType=PT, bundleLevel=BuLvl}) ->
			      (PT==PriorityType)
				  and ((BuLvl==BLvl) or (BuLvl==undefined))
		      end,
	    Bundlesf = lists:filter(FunFilt, Bundles),
%	    Session2=variable:update_value(Session,{?MODULE,restitGodet},[]),
	    menuGodets2(Bundlesf,Session,  Ulvl, Subscr);
	_ -> []
    end.

%% +type restitGodets(session(), bundle_lvl(), priority_type()) ->
%%  erlinclude_result().
%%% Restitue tous les godets de meme priorite
restitGodets(abs, BLvl, PriorityType) ->
    [#nbblock{contents=[{pcdata,"GODET_"++PriorityType}, br]}];
restitGodets(Session, BLvl, PriorityType) ->
    Subscr = svc_util_of:get_souscription(Session),
    Term = (Session#session.prof)#profile.terminal,
    Ulvl = terminal_of:ussd_level(Term#terminal.ussdsize),
    case read_field(bundles, Session) of
	Bundles when list(Bundles) ->
	    FunFilt = fun(#bundle{priorityType=PT, bundleLevel=BuLvl}) ->
			      (PT==PriorityType)
				  and ((BuLvl==BLvl) or (BuLvl==undefined))
		      end,
	    Bundlesf = lists:filter(FunFilt, Bundles),
            case catch restitGodets2(Bundlesf, Ulvl, Subscr) of 
                {'EXIT', Why} -> 
		    slog:event(failure, ?MODULE, unexpected_exit, {(Session#session.prof)#profile.msisdn, Why});
                Val ->
                    Val
            end;
	_ -> []
    end.

%% +type restitGodets2([bundle()], ussd_lvl(), Subscr::atom()) -> [pageitem()].
menuGodets2([], Session, Ulvl, Subscr) -> [];
menuGodets2([Bundle|T], Session, Ulvl, Subscr) ->
%    RestitGodet=variable:get_value(Session,{?MODULE,restitGodet}),
%    Content = restitGodets2([Bundle], Ulvl, Subscr),
%    Session2=variable:update_value(Session,{?MODULE,restitGodet},RestitGodet++Content
    Link = case catch make_link(Bundle, Ulvl, Subscr) of
                  {'EXIT', Why} -> 
		      slog:event(failure, ?MODULE, unexpected_exit, {(Session#session.prof)#profile.msisdn, Why});
                  Val ->
                      Val
           end,
    Link ++ [br] ++ menuGodets2(T, Session, Ulvl, Subscr).

make_link(#bundle{bundleDescription=Libelle}=Bundle,Ulvl, Subscr)->
    Content = restitGodets2([Bundle], Ulvl, Subscr),
    Href_subscr="erl://"?MODULE_STRING":do_restitGodet?"++Content,
    Title = print_title_lib("~s",Libelle),
    [#hlink{href=Href_subscr,contents=[{pcdata,Title}]}].

do_restitGodet(#session{prof=#profile{subscription=Subscr}}=Session,Content)->
    Session2 = variable:update_value(Session, {?MODULE, suivi_conso_detaille}, Content),
    {redirect, Session2 ,"/orangef/selfcare_long/spider.xml#suiviconsodetaille_item"}.
%    {page,Session,#page{items=Content}}.


%% +type restitGodets2([bundle()], ussd_lvl(), Subscr::atom()) -> [pageitem()].
restitGodets2([], Ulvl, Subscr) -> [];
restitGodets2([#bundle{restitutionType="SOLDE"}=Bundle|T], Ulvl, Subscr) ->
    restit_SOLDE(Bundle, Ulvl, Subscr) ++ [br] ++ restitGodets2(T, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="CONSO"}=Bundle|T], Ulvl, Subscr) ->
    restit_CONSO(Bundle, Ulvl) ++ [br] ++ restitGodets2(T, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="LIB"}=Bundle|T], Ulvl, Subscr) ->
    restit_LIB(Bundle, Ulvl) ++ [br] ++ restitGodets2(T, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="SOLDE_"++_=RT}|T]=L, Ulvl, Subscr) ->
    {L1,L2}=lists:splitwith(fun(#bundle{restitutionType=X}) -> X==RT end, L),
    restit_SOLDE_XXX(L1, Ulvl) ++ [br] ++ restitGodets2(L2, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="CONSO_"++_=RT}|T]=L, Ulvl, Subscr) ->
    {L1,L2}=lists:splitwith(fun(#bundle{restitutionType=X}) -> X==RT end, L),
    restit_CONSO_XXX(L1, Ulvl) ++ [br] ++ restitGodets2(L2, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="LSOLDE"}=Bundle|T], Ulvl, Subscr) ->
    restit_LSOLDE(Bundle, Ulvl, Subscr) ++ [br] ++ restitGodets2(T, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="LCONSO"}=Bundle|T], Ulvl, Subscr) ->
    restit_LCONSO(Bundle, Ulvl) ++ [br] ++ restitGodets2(T, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="LSOLDE_"++_=RT}|T]=L, Ulvl, Subscr) ->
    {L1,L2}=lists:splitwith(fun(#bundle{restitutionType=X}) -> X==RT end, L),
    restit_LSOLDE_XXX(L1, Ulvl) ++ [br] ++ restitGodets2(L2, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType="LCONSO_"++_=RT}|T]=L, Ulvl, Subscr) ->
    {L1,L2}=lists:splitwith(fun(#bundle{restitutionType=X}) -> X==RT end, L),
    restit_LCONSO_XXX(L1, Ulvl) ++ [br] ++ restitGodets2(L2, Ulvl, Subscr);
restitGodets2([#bundle{restitutionType=RT}|T], Ulvl, Subscr) ->
    slog:event(warning, ?MODULE, restitutionType_unknown, RT),
    restitGodets2(T, Ulvl, Subscr).

%% +type restit_SOLDE_script(ussd_lvl()) -> string().
restit_SOLDE_script(mobi, 2) ->
    " jusqu'au ~s";
restit_SOLDE_script(_, _) ->
    " a utiliser jusqu'au ~s inclus".


%% +type restit_SOLDE(bundle(), ussd_lvl(), Subscr::atom()) -> [pageitem()].
restit_SOLDE(#bundle{bundleDescription=Libelle,
		     bundleAdditionalInfo=AddInf,
		     desactivationDate=IDO,
		     credits=Creds}=Bundle, 
	     Ulvl, 
	     Subscr) ->
    Etat = etat_godet(Bundle, "balance"),
    String = print_lib("~s",Libelle)
	++ restit_credits("rollOver"," +report ~s",Creds,Ulvl) ++	
	case Etat of
	    epuise -> " : epuise";
	    
	    actif ->
		restit_credits("balance"," : ~s",Creds,Ulvl) ++
		    format_date(IDO,restit_SOLDE_script(Subscr, Ulvl),"dm")
	end
	++ addinfogodet(AddInf,Etat,"\n~s"),
    String2 = linefeed(String),
    [#nbblock{contents=[{pcdata,String2}]}].

%% +type restit_CONSO(bundle(), ussd_lvl()) -> [pageitem()].
restit_CONSO(#bundle{bundleDescription=Libelle,
		     bundleAdditionalInfo=AddInf,
		     desactivationDate=InvalidDateOffer,
		     credits=Creds}=Bundle, Ulvl) ->
    EtatGodet = etat_godet(Bundle, "consumed"),
    String = print_lib("~s",Libelle)
	++ restit_credits("rollOver"," +report ~s",Creds,Ulvl)
	++ format_date(InvalidDateOffer," utilisable jusqu'au ~s inclus","dm")
	++ restit_credits("consumed",": ~s",Creds,Ulvl)
	++ addinfogodet(AddInf,EtatGodet,"\n~s"),
    String2 = linefeed(String),
    [#nbblock{contents=[{pcdata, String2}]}].

%% +type restit_LIB(bundle(), ussd_lvl()) -> [pageitem()].
restit_LIB(#bundle{bundleDescription=Libelle,
		   bundleAdditionalInfo=AddInf,
		   exhaustedLabel=LibelleEpuise,
		   lastUseDate=DateFinCred,
		   credits=Creds}, Ulvl) ->
    SoldeStatus = case Creds of
		      undefined -> 1;
		      _ ->
			  case lists:keysearch("balance", #credit.name, Creds) of
			      false -> 1;
			      {value, Credit} ->
				  case is_cred_nul(Credit) of
				      true -> 0;
				      false -> 1
				  end
			  end
		  end,
    String = case SoldeStatus of
		 1 -> % solde (not available) OR (available and > 0)
		     Solde = restit_credits("balance","~s",Creds,Ulvl),
                     Str = print_lib("~s",Libelle),
                     Pos = string:str(Str, "$$date"),
                     case Pos of
                         0 ->
                             Str;
                         _ ->
                             string:left(Str, Pos-1) ++ format_date(DateFinCred," ~s inclus","dm")
                     end;
		 _ -> % solde (available and = 0)
		     print_lib("~s",LibelleEpuise) ++ addinfogodet(AddInf,epuise,"~s")
	     end,
    [#nbblock{contents=[{pcdata, String}]}].

%% +type restit_SOLDE_XXX([bundle()], ussd_lvl()) -> [pageitem()].
restit_SOLDE_XXX([#bundle{bundleDescription=BD}|_]=L, Ulvl) ->
    String = print_lib("~s:\n",BD),
    [{pcdata, String}] ++ restit_SOLDE_XXX2(L, Ulvl).

%% +type restit_SOLDE_XXX2([bundle()], ussd_lvl()) -> [pageitem()].
restit_SOLDE_XXX2([], Ulvl) -> [];
restit_SOLDE_XXX2([#bundle{}=B|T]=L, Ulvl) ->
    #bundle{bundleDescription=Libelle,
	    bundleAdditionalInfo=AddInf,
	    desactivationDate=InvalidDateOffer,
	    exhaustedLabel=LibelleEpuise,
	    credits=Creds}=B,
    EtatGodet = etat_godet(B, "balance"),
    String = 
	case EtatGodet of
	    epuise -> print_lib("> ~s: epuise",LibelleEpuise);

	    actif -> 
		restit_credits("balance","> ~s",Creds,Ulvl)
		    ++ format_date(InvalidDateOffer,
				   " utilisable jusqu'au ~s inclus",
				   "dm")
	end 
	++ addinfogodet(AddInf,EtatGodet,"\n~s"),
    String2 = linefeed(String),
    [#nbblock{contents=[{pcdata, String2}]}] ++ [br] ++ restit_SOLDE_XXX2(T, Ulvl).

%% +type restit_CONSO_XXX([bundle()], ussd_lvl()) -> [pageitem()].
restit_CONSO_XXX([B|_]=L, Ulvl) ->
    String = print_lib("~s",B#bundle.bundleDescription)
	++ format_date(B#bundle.desactivationDate,
		       ", utilisable jusqu'au ~s inclus",
		       "dm"),
    String2 = fin2points(String),
    String3 = linefeed(String2),
    [{pcdata, String3}] ++ [br] ++ restit_CONSO_XXX2(L, Ulvl).

%% +type restit_CONSO_XXX2([bundle()], ussd_lvl()) -> [pageitem()].
restit_CONSO_XXX2([], Ulvl) -> [];
restit_CONSO_XXX2([#bundle{}=B|T]=L, Ulvl) ->
    #bundle{bundleDescription=Libelle,
	    bundleAdditionalInfo=AddInf,
	    desactivationDate=InvalidDateOffer,
	    exhaustedLabel=LibelleEpuise,
	    credits=Creds}=B,
    EtatGodet = etat_godet(B, "consumed"),
    String = restit_credits("consumed","> ~s",Creds,Ulvl)
	++ addinfogodet(AddInf,EtatGodet,"\n~s"),
    String2 = linefeed(String),
    [#nbblock{contents=[{pcdata, String2}]}] ++ [br] ++ restit_CONSO_XXX2(T, Ulvl).

%% +type restit_LSOLDE(bundle(), ussd_lvl()) -> [pageitem()].
restit_LSOLDE(Bundle, Ulvl, Subscr) ->
    restit_SOLDE(Bundle, Ulvl, Subscr) ++ [br] ++ phrase_renouv(Bundle).

%% +type restit_LCONSO(bundle(), ussd_lvl()) -> [pageitem()].
restit_LCONSO(Bundle, Ulvl) ->
    restit_CONSO(Bundle, Ulvl) ++ [br] ++ phrase_renouv(Bundle).

%% +type restit_LSOLDE_XXX([bundle()], ussd_lvl()) -> [pageitem()].
restit_LSOLDE_XXX([Bun|_]=L, Ulvl) ->
    restit_SOLDE_XXX(L, Ulvl) ++ [br] ++ phrase_renouv(Bun).

%% +type restit_LCONSO_XXX([bundle()], ussd_lvl()) -> [pageitem()].
restit_LCONSO_XXX([Bun|_]=L, Ulvl) ->
    restit_CONSO_XXX(L, Ulvl) ++ [br] ++ phrase_renouv(Bun).

%% +type phrase_renouv(bundle()) -> [pageitem()].
phrase_renouv(#bundle{reinitDate=undefined}) -> [];
phrase_renouv(#bundle{reinitDate=RDate, desactivationDate=DDate}) ->
    case list_to_integer(RDate) of
	X when 1=<X,X=<31 ->
	    %% renouv mensuel
	    String =
		"Renouvele le "++ RDate ++ " du mois" ++
		mois_annee(DDate, " jusqu'a ~s inclus"),
	    [{pcdata, String}, br];
	X when 40=<X,X=<46 -> 
	    %% renouv hebdo
	    Day = atom_to_list(svc_util_of:dow_int2atom(X-39)),
	    String =
		"Renouvele tous les "++ Day ++
		jour_mois_annee(DDate, " jusqu'au ~s inclus"),
	    [{pcdata, String}, br];
	50 ->
	    %% renouv quotidien
	    String =
		"Renouvele tous les jours" ++
		jour_mois_annee(DDate, " jusqu'au ~s inclus"),
	    [{pcdata, String}, br];
	_ ->
	    []
    end.

%% +type jour_mois_annee(date(), string()) -> string().
jour_mois_annee(undefined, _) -> "";
jour_mois_annee({{Y,M,D},_}, Fmt) -> 
    Mois = atom_to_list(svc_util_of:mois_int2atom(M)),
    Date = pbutil:sprintf("%d %s %d", [D,Mois,Y]),
    DateF = lists:flatten(Date),
    flat_fmt(Fmt, [DateF]).

%% +type mois_annee(date(), string()) -> string().
mois_annee(undefined, _) -> "";
mois_annee({{Y,M,D},_}, Fmt) -> 
    Mois = atom_to_list(svc_util_of:mois_int2atom(M)),
    Date = pbutil:sprintf("%s %d", [Mois,Y]),
    DateF = lists:flatten(Date),
    flat_fmt(Fmt, [DateF]).

%% +type fin2points(string()) -> string().
fin2points("") -> "";
fin2points(String) -> String++":".

%% +type print_lib(fmt(), string()) -> string().
print_lib(Fmt, undefined) -> "";
print_lib(Fmt, Libelle) when length(Libelle)>3 -> 
    case parse_icg(Libelle) of
	[TitreLibelle, DescriptionLibelle,_] ->
	    flat_fmt(Fmt, [DescriptionLibelle]);
	[TitreLibelle, DescriptionLibelle] ->
	    flat_fmt(Fmt, [DescriptionLibelle]);
	[DescriptionLibelle] ->
	    flat_fmt(Fmt, [DescriptionLibelle]);
	Error ->
	    slog:event(failure,?MODULE,unknown_libelle,Error),
	    ""
    end.

%% +type print_title_lib(fmt(), string()) -> string().
print_title_lib(Fmt, undefined) -> "";
print_title_lib(Fmt, Libelle) when length(Libelle)>3 -> 
    case parse_icg(Libelle) of
	[TitreLibelle, DescriptionLibelle, _] ->
	    flat_fmt(Fmt, [TitreLibelle]);
	[TitreLibelle, DescriptionLibelle] ->
	    flat_fmt(Fmt, [TitreLibelle]);
	[DescriptionLibelle] ->
	    flat_fmt(Fmt, [DescriptionLibelle]);
	Error ->
	    slog:event(failure,?MODULE,unknown_libelle,Error),
	    ""
    end.


%% +type linefeed(string()) -> string().
linefeed("") -> "";
linefeed(String) ->
    string:strip(String, right, $\n) ++ "".

%% +type unit_to_label(credit_unit()) -> string().
unit_to_label("VOLUM") -> "";
unit_to_label(UnitName) ->
    Table = pbutil:get_env(pservices_orangef, spider_table),
    case lists:keysearch(UnitName,#unite.nom,Table) of
	false -> "";
	{value,#unite{libelle=Libelle}} -> Libelle
    end.

%% +type addinfocred(string(), ussd_lvl()) -> string().
addinfocred(UNDEF,Ulvl) when UNDEF==undefined;UNDEF==[] -> "";
addinfocred(SpiderCode,Ulvl) ->
    Table = pbutil:get_env(pservices_orangef, spider_infos_comp),
    case lists:keysearch(SpiderCode,1,Table) of
	false -> 
	    slog:event(failure,?MODULE,unknown_addinfo,SpiderCode),
	    "";
	{value,{_,ListMsg}} -> 
	    case lists:keysearch(Ulvl,1,ListMsg) of
		{value, {_,Msg}} -> 
		    " "++Msg;
		_ -> 
		    slog:event(failure,?MODULE,unknown_level,Ulvl),
		    ""
	    end
    end.    

%% +type addinfogodet(string(), atom(), fmt()) -> string().
addinfogodet(undefined,_,_) -> "";
addinfogodet(String,EtatGodet,Fmt) when length(String)>3-> 
    case parse_icg(String) of
	[ICG01,ICG02,ICG03] ->
	    String2 = case EtatGodet of
			  actif ->  concat_str(ICG01, ICG02);
			  epuise -> concat_str(ICG01, ICG03)
		      end,
	    flat_fmt(Fmt, [String2]);
	_ -> 
	    slog:event(count, ?MODULE, bad_icg),
	    ""
    end;
addinfogodet(_,_,_) -> "".

%% +type parse_icg(string()) -> [string()].
parse_icg(String) -> parse_icg(String,[]).
%% +type parse_icg(string(), Acc::[string()]) -> [string()].
parse_icg([$||T],Acc) -> [Acc | parse_icg(T)];
parse_icg([H|T],Acc) -> parse_icg(T,Acc++[H]);
parse_icg([],Acc) -> [Acc].

concat_str("", "") -> "";
concat_str(S1, "") -> S1;
concat_str("", S2) -> S2;
concat_str(S1, S2) -> S1++" "++S2.    

%% +type format_date(date(), string(), string()) -> string().
format_date(undefined,_,_) -> "";
format_date({Date,_Heure}, Fmt, DateFormat) -> 
    JJMM = svc_util_of:sprintf_datetime_by_format({Date,_Heure},DateFormat),
    flat_fmt(Fmt, [JJMM]).

%% +type lienSiAjustableEtbonus(session(), string(), url()) ->
%%  erlinclude_result().
lienSiAjustableEtbonus(abs,Pcd,Url) ->
    [#hlink{href=Url,contents=[{pcdata,Pcd}]}];
lienSiAjustableEtbonus(Session,Pcd,Url) ->
    case ajustableEtBonus(Session) of
	true -> [#hlink{href=Url,contents=[{pcdata,Pcd}]}];
	false -> []
    end.

%% +type ajustableEtBonus(session()) -> bool().
ajustableEtBonus(Session) ->
    case get_godetA(Session) of
	#bundle{restitutionType="AJUST",credits=Creds} ->
	    case lists:keysearch("bonus",#credit.name,Creds) of
		false -> false;
 		{value,CredBonus} -> 
		    case is_cred_nul(CredBonus) of
			true -> false;
			false -> true
		    end
	    end;
	_ -> false
    end.

%% +type lienSiGodetsCouD(session(), string(), url()) -> erlinclude_result().
lienSiGodetsCouD(abs,Pcd,Url) ->
    [#hlink{href=Url,contents=[{pcdata,Pcd}]}, br];
lienSiGodetsCouD(Session,Pcd,Url) ->
    case godetsCouD(Session) of
	true -> [#hlink{href=Url,contents=[{pcdata,Pcd}]}];
	false -> []
    end.

%% +type lienSiGodetsCouD(session(), string(), url()) -> erlinclude_result().
redirect_by_GodetCouD(abs,Url_ok,Url_nok) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_nok}
    ];    
redirect_by_GodetCouD(Session,Url_ok,Url_nok) ->
    case godetsCouD(Session) of
	true -> 
	    {redirect, Session, Url_ok};
	false ->
	    ListOptions=pbutil:get_env(pservices_orangef,asmetier_opt_postpaid),
	    case svc_subscr_asmetier:get_identification(Session, "oee") of
		{ok, IdDosOrch, CodeOffreType,Session1} ->
		    case svc_subscr_asmetier:get_listServiceOptionnel(Session1) of
			{ok,ListServOpt,Session2}->
			    {redirect, Session2, Url_nok};
			_->
			    slog:event(failure,?MODULE,redirect_by_GodetCouD_error,get_listServiceOptionnel),
			    {redirect,Session, "/orangef/home.xml#as_metier_failure"}
     		    end;
		Other ->
		    slog:event(failure,?MODULE,redirect_by_GodetCouD_UnknownError, Other),
		    {redirect,Session, "/orangef/home.xml#as_metier_failure"}
     	    end
    end.

redirect_si_Godet(abs, GodetName, Url_ok, Url_null) ->
    [{redirect, abs, Url_ok},
     {redirect, abs, Url_null}
    ];    
redirect_si_Godet(Session, GodetName, Url_ok,Url_null) ->
    case godet(Session,GodetName) of
	true -> {redirect, Session, Url_ok};
	false -> {redirect, Session, Url_null}
    end.
%% +type godet(session()) -> bool().
godet(Session,GodetName) ->
    case read_field(bundles, Session) of
	undefined -> false;
	Bundles ->
	    lists:any(fun(#bundle{priorityType=PT}) -> (PT==GodetName)
		      end, Bundles)
    end.

%% +type godetsCouD(session()) -> bool().
godetsCouD(Session) ->
    case read_field(bundles, Session) of
	undefined -> false;
	Bundles ->
	    lists:any(fun(#bundle{priorityType=PT}) -> (PT=="C") or (PT=="D")
		      end, Bundles)
    end.

%% +type lienSiGodetsF(session(), string(), url()) -> erlinclude_result().
lienSiGodetsF(abs,Pcd,Url) ->
    [#hlink{href=Url,contents=[{pcdata,Pcd}]}, br];
lienSiGodetsF(Session,Pcd,Url) ->
    case get_godets_miro(Session) of
	[#bundle{bundleDescription=Libelle}] when Libelle /= undefined ->
	    String = Pcd ++" "++ Libelle ++ "\n",
	    [#hlink{href=Url,contents=[{pcdata,String}]}];
	_ -> []
    end.

%% +type lienSuiviConsoPlus(session(), string(), url()) -> erlinclude_result().
lienSuiviConsoPlus(abs, Pcd, Url) ->
    [#hlink{href=Url,contents=[{pcdata,Pcd}]}];
lienSuiviConsoPlus(Session, Pcd, Url) ->
    case godetsCouD(Session) or ajustableEtBonus(Session) or 
	(get_godets_boost(Session)/=[]) of
	true -> [#hlink{href=Url,contents=[{pcdata,Pcd}]}];
 	false -> []
    end.

%% +type lienSousMenu(session()) ->
%%                    erlinclude_result().

-define(LIENT, "Suivi conso +\n").
-define(SUITE, "Suite\n").
-define(U_SVD, "file:/orangef/selfcare_long/spider.xml#suiviconsodetaille").
-define(U_BON, "file:/orangef/selfcare_long/spider.xml#mesbonus").
-define(U_BOO, "file:/orangef/selfcare_long/spider.xml#boosts").
-define(U_SVP, "file:/orangef/selfcare_long/spider.xml#suiviconsoplus").
-define(U_MIRO, "file:/orangef/selfcare_long/spider.xml#miro").
-define(U_CMO_GODETC, "file:/orangef/selfcare_long/selfcare_cmo_new.xml#suivi_conso_godetC").
-define(U_POSTPAID_GODETC, "file:/orangef/selfcare_long/resiliation_options_postpaid.xml#suivi_conso_godetC").

lienSousMenu(abs) ->
    [#hlink{href=?U_SVD,contents=[{pcdata,?LIENT}]},
     #hlink{href=?U_BON,contents=[{pcdata,?LIENT}]},
     #hlink{href=?U_BOO,contents=[{pcdata,?LIENT}]},
     #hlink{href=?U_MIRO,contents=[{pcdata,?LIENT}]}
    ];
lienSousMenu(Session) ->
    Sub=svc_util_of:get_souscription(Session),
    case Sub of
	postpaid ->
	    lienSiGodetsCouD(Session,?SUITE,?U_POSTPAID_GODETC);
	cmo->
	    lienSiGodetsCouD(Session,?SUITE,?U_CMO_GODETC);
	_->
	    case {godetsCouD(Session),  ajustableEtBonus(Session),
		  get_godets_boost(Session)/=[], get_godets_miro(Session)/=[]} of
		{true,false,false,false} -> [#hlink{href=?U_SVD,contents=[{pcdata,?LIENT}]}];
		{false,true,false,false} -> [#hlink{href=?U_BON,contents=[{pcdata,?LIENT}]}];
		{false,false,true,false} -> [#hlink{href=?U_BOO,contents=[{pcdata,?LIENT}]}];
		{_,_,_,true} -> [#hlink{href=?U_MIRO,contents=[{pcdata,?LIENT}]}];
		{false, false, false,false} -> [];
		_ -> [#hlink{href=?U_SVP,contents=[{pcdata,?LIENT}]}]
	    end
    end.


%% +type lienSiAutresGodets(session(), string(), url()) -> erlinclude_result().
lienSiAutresGodets(abs, Pcd, Url) ->
    [#hlink{href=Url,contents=[{pcdata,Pcd}]}];
lienSiAutresGodets(Session, Pcd, Url) ->
    case read_field(bundles, Session) of
	undefined -> [];
	Bundles ->
	    case lists:any(fun(#bundle{priorityType=PT}) -> 
				   PT /= "A" end, Bundles) of
		true -> [#hlink{href=Url,contents=[{pcdata,Pcd}]}, br];
		false -> []
	    end
    end.

%% +type dme_suiviconsoplus(session()) -> erlinclude_result().
dme_suiviconsoplus(abs) ->
    [#nbblock{contents=[{pcdata, "GODETS B,C ou D"}, br]}];
dme_suiviconsoplus(Session) ->
    case read_field(bundles, Session) of
	undefined -> [];
	Bundles ->
	    Bundles2 = lists:filter(fun(#bundle{priorityType=PT}) -> PT /= "A"
				    end, Bundles),
	    lists:map(fun dme_restit_suiviconsop/1, Bundles2)
    end.

opim_suiviconsoplus(abs) ->
    [#nbblock{contents=[{pcdata, "GODETS B,C ou D"}, br]}];
opim_suiviconsoplus(Session) ->
    case read_field(bundles, Session) of
        undefined -> [];
        Bundles ->
            Bundles2 = lists:filter(fun(#bundle{priorityType=PT}) -> PT /= "A"
                                    end, Bundles),
            lists:map(fun opim_restit_suiviconsop/1, Bundles2)
    end.

opim_restit_suiviconsop(#bundle{bundleDescription=Libelle,credits=Credits}) ->
    case lists:filter(fun(#credit{name=N}) -> N == "balance"
                      end, Credits) of
        [] -> [];
        Balances ->
            Sep = ", ",
            StringBal = lists:flatmap(fun(#credit{value=Val, unit=U}) ->
                                              Sep++format_val(Val,U)++
                                                  unit_to_label(U)
                                      end, Balances),
            StringBal2 = string:substr(StringBal,1+length(Sep)),
            String = restit_label_dme(Libelle,Credits) ++ " : " ++ StringBal2,
            #nbblock{contents=[{pcdata, String}, br]}
    end.

%% +type dme_restit_suiviconsop(bundle()) -> pageitem().
dme_restit_suiviconsop(#bundle{bundleDescription=Libelle,credits=Credits}) ->
    case lists:filter(fun(#credit{name=N}) -> N == "balance"
		      end, Credits) of
	[] -> [];
	Balances ->
	    Sep = ", ",
	    StringBal = lists:flatmap(fun(#credit{value=Val, unit=U}) -> 
					      Sep++format_val(Val,U)++
						  unit_to_label(U)
				      end, Balances),
	    StringBal2 = string:substr(StringBal,1+length(Sep)),
	    String = restit_label_dme(Libelle,Credits) ++ " : " ++ StringBal2,
	    #nbblock{contents=[{pcdata, String}, br]}
    end.

%% +type restit_label_dme(string(), [credit()]) -> string().
restit_label_dme(undefined,_) -> "";
restit_label_dme(Label, Credits) ->
    case string:tokens(Label, "\$") of
	[Label] -> %% $$START$$ n'est pas present
	    Label;
	List ->    %% $$START$$ est present
	    StringRep =
		case lists:keysearch("start",#credit.name,Credits) of
		    {value,#credit{value=V,unit=U}} ->
			format_val(V,U)++unit_to_label(U);
		    false -> ""
		end,
	    List2 = replace_elt(List, "START", StringRep),
	    lists:flatten(List2)

    end.

%% +type replace_elt([string()], string(), string()) -> [string()].
replace_elt([Elem|T], Elem, New) -> [New|T];
replace_elt([X|T], Elem, New) -> [X | replace_elt(T, Elem, New)];
replace_elt([], Elem, New) -> not_replaced.


%% +type read_field(FieldName::atom(), session()) -> term().
read_field(FieldN, Session) -> 
    SPIDER_DATA = get_spider_info_int(Session), 
    %% to make sure it is up to date
    read_field2(FieldN, SPIDER_DATA).

%% +type read_field2(FieldN::atom(), spider_response()) -> term().
read_field2(bundles,     #spider_response{bundles=V}) -> V;
read_field2(file,        #spider_response{file=V}) -> V;
read_field2(availability,#spider_response{availability=V}) -> V;
read_field2(version,     #spider_response{version=V}) -> V;
read_field2(offerType,   #spider_response{file=#file{offerType=V}})-> V;
read_field2(amounts,     #spider_response{file=#file{amounts=V}})-> V;
read_field2(fileState,   #spider_response{file=#file{fileState=V}})-> V;
read_field2(custMsisdn,   #spider_response{file=#file{custMsisdn=V}})-> V;
read_field2(custImsi,   #spider_response{file=#file{custImsi=V}})-> V;
read_field2(durationHf,  #spider_response{file=#file{durationHf=V}})-> V;
read_field2(nextInvoice, #spider_response{file=#file{nextInvoice=V}})-> V;
read_field2(invoiceDate, #spider_response{file=#file{invoiceDate=V}})-> V;
read_field2(validityDate, #spider_response{file=#file{validityDate=V}})-> V;
read_field2(offerPOrSUid,#spider_response{file=#file{offerPOrSUid=V}})-> V;
read_field2(fileRestitutionType, #spider_response{file=#file{fileRestitutionType=V}})-> V;
read_field2(frSpecificPrepaidOfferValue, #spider_response{file=#file{frSpecificPrepaidOfferValue=V}})-> V;
read_field2(_,_) -> undefined.


%% %% +type 'hh:mm'(time()) -> string().
%% 'hh:mm'({H,M,S}) ->
%%     Hour = pbutil:sprintf("%02d:%02d", [H,M]),
%%     lists:flatten(Hour).


update_commercial_segment(Session) ->
    case pbutil:get_env(pservices_orangef, store_commercial_segment) of
	true ->
	    Uid = (Session#session.prof)#profile.uid,
	    OfferPOrSUid = read_field(offerPOrSUid, Session),
	    case catch svc_util_of:update_extra_commercial(Uid, OfferPOrSUid) of
		{'EXIT', no_update}->
		    svc_util_of:insert_extra_commercial(Uid,OfferPOrSUid);
		{'EXIT', {bad_response_from_db, X}} ->
		    put(error, get(error)++[{update_ofe_failed,{Uid,OfferPOrSUid},X}]);
		ok ->
		    ok
	    end;
	%% 	    case svc_util_of:query_commercial_segment_by_uid(Uid) of
	%% 		{ok, OfferPOrSUid} -> 
	%% 		    ok;
	%% 		{ok, _} -> svc_util_of:update_extra_commercial(Uid, OfferPOrSUid)
	%% 	    end;
	false ->
	    ok
    end.


%% +type cb_end_sess(session(), [term]) -> {ok, session()}.
cb_end_sess(#session{log=Log, prof=#profile{subscription=S}}=Session, Args) ->
    slog:event(trace, ?MODULE, cb_end_sess,{S}),
    case S of
	"mobi" ->
	    update_commercial_segment(Session);
	_ ->
	    ok
    end,
    {ok, Session}.

%% +type get_codedomaine(session()) -> string().
get_codedomaine(Session) ->
    Produit = read_field(offerPOrSUid, Session),
    MSISDN=(Session#session.prof)#profile.msisdn,
    produit2codedomaine(Produit,MSISDN).

%% +deftype produit()=string().     %% "3G"|"OLA"|"ORA"|"PRO"|"FNAC"
%% +deftype codedomaine()=string(). %% "OL"|"OR"|"3G"|"PR"|"FN"
%% +type produit2codedomaine(produit()) -> codedomaine().
%%% fait la correspondance entre le code produit retourne par SPIDER
%%% et le code domaine a envoyer a PRISME (CDC PRISME)
produit2codedomaine(Produit,MSISDN) ->
    List=pbutil:get_env(pservices_orangef,codeOffre_codeDomaine_souscription_packageOTO),
    case lists:keysearch(Produit,1,List) of
	{value,{Produit, Code,_,_}}->
	    case Code of
		"non_defini"->
		    slog:event(trace,?MODULE, code_domaine_non_defini,[Code]),
		    "**";
		_ ->
		    Code
	    end;
	_ ->
	    slog:event(failure,?MODULE,unknown_codedomaine,{MSISDN,Produit}),
	    "**"
    end.

%% +type number_list_to_float(string()) -> float().
number_list_to_float(S) ->
    case catch list_to_float(S) of
        {'EXIT', E} -> 0.0 + catch_list_to_integer(S);
	F           -> F
    end.

%% +type catch_list_to_integer(string()) -> integer().
catch_list_to_integer(S) ->
    case catch list_to_integer(S) of
	{'EXIT', _ } -> 0;
	Int -> Int
    end.	    

%% +type lien_offre_boost(session(), string(), url()) -> erlinclude_result().
lien_offre_boost(abs, Lien, Url) -> 
    [#hlink{href=Url,contents=[{pcdata,Lien}]}];
lien_offre_boost(Session, Lien, Url) ->
    case get_godets_boost(Session) of
	[] -> [];
	DEFINED_ -> [#hlink{href=Url,contents=[{pcdata,Lien}]}]
    end.

%% +type get_godets_boost(session()) -> [bundle()].
get_godets_boost(Session) ->
    case read_field(bundles, Session) of
	Bundles when list(Bundles) ->
	    filter_gboost(Bundles);
	_ -> []
    end.

%% +type filter_gboost([bundle()]) -> [bundle()].
filter_gboost([]) -> [];
filter_gboost([#bundle{priorityType="E",restitutionType="AVTG",
		       credits=Credits}=GB|T]) when list(Credits) ->
    [GB | filter_gboost(T)];
filter_gboost([H|T]) -> filter_gboost(T).

%% +type get_godets_boost(session()) -> [bundle()].
get_godets_miro(Session) ->
    case read_field(bundles, Session) of
	Bundles when list(Bundles) ->
	    filter_miro(Bundles);
	_ -> []
    end.

%% +type filter_gboost([bundle()]) -> [bundle()].
filter_miro([]) -> [];
filter_miro([#bundle{priorityType="F",restitutionType="TG",
		     credits=Credits}=GB|T]) when list(Credits) ->
    [GB | filter_miro(T)];
filter_miro([H|T]) -> filter_miro(T).

%% +type restit_offre_boost(session()) -> erlinclude_result().
restit_offre_boost(abs) -> [{pcdata,"OffresBOOST\n"}];
restit_offre_boost(Session) ->
    GBOOST = get_godets_boost(Session),
    lists:map(fun gboost_to_pageitem/1, GBOOST).

%% +type restit_offre_miro(session(),Page::string()) -> erlinclude_result().
restit_offre_miro(abs,Fmt) -> [{pcdata,"OffresMIRO\n"}];
restit_offre_miro(Session,Page) ->
    [#bundle{bundleDescription=LibelleAvantage,
	     thresholdFlag=DernierPalier,
	     lastUseDate=DateFinCred,
	     credits=Credits}] = get_godets_miro(Session),

    restit_offre_miro(Session,LibelleAvantage,DernierPalier,DateFinCred,Credits, lists:keymember("gain",2,Credits),Page).

restit_offre_miro(Session,LibelleAvantage,"0",DateFinCred,Credits,true,"page1") -> % Le client a passe un palier mais pas le dernier
    Suite = [#hlink{href="/orangef/selfcare_long/spider.xml#miro_page2", contents=[{pcdata, "Suite"}]}],
    String = LibelleAvantage++":\n"++
	restit_credits("counter","Vous avez consomme ~s,",Credits,1) ++
	restit_credits("reducedPrice"," vous beneficiez actuellement d'une reduction de ~s",Credits,1),
    Text = [{pcdata, String}],
    {page,Session,#page{items=svc_util_of:br_separate(Text++Suite)}};

restit_offre_miro(Session,LibelleAvantage,"0",DateFinCred,Credits,true,"page2") ->
    Suite = suite_godetCouD(Session),
    String = ""++
	restit_credits("toNextStage","Il vous reste a consommer ~s",Credits,1) ++
	format_date( DateFinCred, " avant le ~s", "dmy") ++
	restit_credits("nextGain"," pour beneficier de ~s",Credits,1) ++
	restit_credits("nextReducedPrice"," soit ~s.",Credits,1),
    Text = [{pcdata, String}],    
    {page,Session,#page{items=svc_util_of:br_separate(Text++Suite)}};

restit_offre_miro(Session,LibelleAvantage,"0",DateFinCred,Credits,false,"page1") ->  % Le client n'a pas encore atteint le premier palier
    Suite = suite_godetCouD(Session),
    String = LibelleAvantage++":\n"++
	restit_credits("counter","Vous avez consomme ~s",Credits,1) ++
	restit_credits("toNextStage"," Il vous reste a consommer ~s",Credits,1) ++
	format_date(DateFinCred, " avant le ~s","dmy") ++
	restit_credits("nextGain"," pour beneficier de ~s",Credits,1)
	++ restit_credits("nextReducedPrice"," soit ~s.",Credits,1),
    Text = [{pcdata, String}],    
    {page,Session,#page{items=svc_util_of:br_separate(Text++Suite)}};

restit_offre_miro(Session,LibelleAvantage,"1",DateFinCred,Credits,true,"page1") -> %Le client a atteint le dernier palier
    Suite = suite_godetCouD(Session),
    String = LibelleAvantage++":\n"++
	restit_credits("counter","Vous avez consomme plus de ~s,",Credits,1) ++
	restit_credits("reducedPrice"," vous beneficiez actuellement d'une reduction de ~s",Credits,1)++
	format_date(DateFinCred," valable jusqu'au ~s", "dmy")++
	".",
    Text = [{pcdata, String}],    
    {page,Session,#page{items=svc_util_of:br_separate(Text++Suite)}}.

suite_godetCouD(Session) ->
    case godetsCouD(Session) of
	true ->[#hlink{href=?U_SVD,contents=[{pcdata,"Suite"}]}];
	_ -> []
    end.

%% +type gboost_to_pageitem(bundle()) -> pageitem().
gboost_to_pageitem(#bundle{bundleDescription=LibelleAvantage,
			   previousPeriodLastUseDate=DateFinPeriodePrec,
			   firstUseDate=DateDebCred,
			   lastUseDate=DateFinCred,
			   credits=Credits}) ->
    String1 = restit_credits("previousCounter","~s",Credits,1) ++
	restit_credits("previousAdvantage"," offrant ~s",Credits,1)
	++ format_date(DateFinPeriodePrec, " a utiliser jusqu'au ~s","dm"),

    String2 = case String1 of
		  "" -> "";
		  _  -> String1++"\n\n"
	      end,
    String3 = 
	print_lib("~s :\n", LibelleAvantage) ++ String2 ++
	restit_credits("counter","~s",Credits,1) ++
	restit_credits("advantage"," offrant ~s",Credits,1) ++
	restit_dates_boost_deb_fin(DateDebCred, DateFinCred) ++ "\n\n",
    #nbblock{contents=[{pcdata,String3}]}.


%% +type restit_dates_boost_deb_fin(datetime(), datetime()) -> string().
restit_dates_boost_deb_fin(Deb, undefined) -> "";
restit_dates_boost_deb_fin(undefined, Fin) ->
    format_date(Fin, " a utiliser jusqu'au ~s","dm");
restit_dates_boost_deb_fin(Deb, Fin) ->
    format_date(Deb, " a utiliser du ~s","dm") ++ format_date(Fin, " au ~s","dm").

%% +type display_page(session())->erlpage_result() 
display_page(abs,ValueName) ->
    [{redirect, abs, "Valeur dynamique"}];
display_page(Session,ValueName) ->
    case variable:get_value(Session, {?MODULE, list_to_atom(ValueName)}) of
	not_found ->
	    [{pcdata,""}];
	Page -> 
	    Page
    end.



%% Spider API

%% +type query_spider(session(), string()) -> 
%%                             {ok,Sub,session()}
%%                           | {unknown_user,session()}
%%                           | {{query_crashed, ErrCode}, session()}.
query_spider(#session{prof=Prof}=Session) ->    
    OfferType = get_offertype(Session),
    {IdType, IdVal} =
        case Prof#profile.msisdn of
            {na, _} ->

                case Prof#profile.imsi of
                    {na, _} ->
			exit({query_spider, no_imsi_or_msisdn});
		    Imsi    -> {"IMSI", Imsi}
                end;
            "+33"++M ->
                {"MSISDN", "0"++M};
            Msisdn ->
                {"MSISDN", Msisdn}
        end,
    Term = Prof#profile.terminal,
    Level = terminal_of:ussd_level(Term#terminal.ussdsize),
    Subscription = Prof#profile.subscription,
    LvlSpider = level_spider(OfferType, Subscription, Level),

    case spider:getBalance(IdType, IdVal, OfferType, LvlSpider) of
	{ok, Subscription, GBR} ->
            %% SPIDER repond la meme souscription que celle en base
	    Session1 = 
		set_spider_info(Session,
				GBR#spider_response{availability=available}),
	    {ok, Subscription, Session1};
	{ok, MobCmo, GBR} when MobCmo=="cmo"; MobCmo=="mobi" ->
	    Session1 = Session#session{prof=Prof#profile{subscription=MobCmo}},
	    query_spider(Session1);
	{ok, "entreprise", GBR} ->
	    EnterprisePossible = 
		pbutil:get_env(pdist_orangef,
			       spider_entreprise_possible_subscription),
	    case lists:member(Subscription,EnterprisePossible) of
		true ->		    
		    %% leave subscription unchanged
		    Session1 = 
			set_spider_info(Session,
					GBR#spider_response{availability=
							    available}),
		    {ok, Subscription, Session1};
		_ ->
		    %% previously badly identified, or unsupported change
		    %% For example a change from anything to dme (because OPIM)
		    %% Users in this case will become anon, then OK on 
		    %%  next session...
		    Session1 = 
			set_spider_info(Session,
					#spider_response{availability=
							 not_available}),
		    {unknown_user, Session}
	    end;

	{ok, OtherSub, GBR} ->
	    %% SPIDER repond "postpaid"
	    Session1 = 
		set_spider_info(Session,
				GBR#spider_response{availability=available}),
	    {ok, OtherSub, Session1};
        unknown_user ->
	    if OfferType=="postpaid"-> prisme_dump:prisme_count("SCONIN");
               true -> ok
            end,
	    Session1 = 
		set_spider_info(Session,
				#spider_response{availability=not_available}),
	    Session2=variable:update_value(Session1, spider_error, unknown_user),
            {unknown_user, Session2};
        {spider_error, ErrCode} ->
	    Session1 = 
		set_spider_info(Session,
				#spider_response{availability=not_available}),
	    Error1 = case ErrCode of
			 {no_resp, timeout}->
			     Session2=variable:update_value(Session1, spider_error, timeout),
			     no_resp;
			 {no_resp, tcp_closed}->
			     Session2=variable:update_value(Session1, spider_error, tcp_closed),
                             no_resp;
			 {Code, invalid_code}->
                             Session2=variable:update_value(Session1, spider_error, invalid_code),
			     Code;
			 {Code, Module}->
                             Session2=variable:update_value(Session1, spider_error, Module),
			     Code;
			 no_resp->
			     Session2=variable:update_value(Session1, spider_error, no_resp),
			     no_resp;
			 _->
			     Session2=variable:update_value(Session1, spider_error, ErrCode),
			     ErrCode
		     end,    
            {{query_crashed, Error1}, Session2}
    end.

%% +type level_spider(string(),sub_of(),integer())-> string().
level_spider("prepaid", "mobi", 1) -> "1;2;3;";
level_spider("prepaid", "cmo",  1) -> "1;2;3;";
level_spider(_, _, Level) -> integer_to_list(Level).

%%+type get_offertype(session())->list of atom
get_offertype(Session)->
    S = (Session#session.prof)#profile.subscription, 
    if
	S=="postpaid" ->
	    "postpaid";
	S=="dme";S=="opim" ->
	    "entreprise";
	S=="mobi";S=="cmo" ->
	    "prepaid";
	true ->
	    ""    
    end.

%%+type get_spider_info_int(session())-> spider_response()
%%                                  | undefined.
get_spider_info_int(Session) ->
    case variable:get_value(Session,?SPIDER_KEY) of
	not_found -> undefined;
	SpiderInfo -> SpiderInfo
    end.

%%+type get_spider_info(session())->  session().
get_spider_info(Session) ->
    get_spider_info(Session,false).
get_spider_info_and_subscription(Session) ->   
    get_spider_info(Session,true).

get_spider_info(Session,WithSub) ->
    Resp =
	case get_availability(Session) of
	    Avai when Avai==out_of_date;
		      Avai==undefined ->
		query_spider(Session);
	    _ -> 
		Prof = Session#session.prof,
		{ok,Prof#profile.subscription,Session}
	end,
    case WithSub of
	true ->
	    Resp;
	_ ->
	    case Resp of
		{ok,_,Session1} ->
		    Session1;
		{unknown_user,Session1} ->
		    Session1;
		{{query_crashed, _}, Session1} ->
		    Session1
	    end
    end.

%% +type set_spider_info(session()) -> session()}.
set_spider_info(Session,Spider) ->
    variable:update_value(Session, ?SPIDER_KEY, Spider).

%% +type get_declinaison(session() | spider_response()) -> 
%%                                          declinaison : int | undefined.
get_declinaison(abs) ->
    undefined;
get_declinaison(Session) when record(Session,session) ->    
    case read_field(frSpecificPrepaidOfferValue,Session) of
	[] ->
            undefined;
	undefined ->
            undefined;
        DCL when list(DCL)->
            list_to_integer(DCL)
    end;
get_declinaison(SpiderResponse) when record(SpiderResponse,spider_response) ->
    case read_field2(frSpecificPrepaidOfferValue,SpiderResponse) of
	[] ->
            undefined;
	undefined ->
            undefined;
        DCL when list(DCL)->
            list_to_integer(DCL)
    end.

%% +type set_availability(session() ) -> session().
set_availability(Session,Value) ->
    SpiderInfo = case get_spider_info_int(Session) of
        Spider when record(Spider,spider_response) ->
			 Spider#spider_response{availability=Value};
	_ ->
			 #spider_response{availability=not_available}
		 end,
    set_spider_info(Session,SpiderInfo).

	
%% +type get_availability(session() | spider_response()) -> 
%%                                          availability : string() | undefined.
get_availability(abs) ->
    available;
get_availability(Session) when record(Session,session) ->    
    case read_field(availability,Session) of
	[] ->
            undefined;
	undefined ->
            undefined;
	Availability->
	    Availability
    end;
get_availability(SpiderResponse) when record(SpiderResponse,spider_response) ->
    case read_field2(availability,SpiderResponse) of
	[] ->
            undefined;
	undefined ->
            undefined;
	Availability->
	    Availability
    end.

%% +type set_version(session() ) -> session().
set_version(Session,Value) ->
    SpiderInfo = case get_spider_info_int(Session) of
        Spider when record(Spider,spider_response) ->
			 Spider#spider_response{version=Value};
	_ ->
			 #spider_response{}
		 end,
    set_spider_info(Session,SpiderInfo).

%% +type get_version(session() | spider_response()) -> 
%%                                          version : int | undefined.
get_version(abs) ->
    undefined;
get_version(Session) when record(Session,session) ->    
    case read_field(version,Session) of
	[] ->
            undefined;
	undefined ->
            undefined;
	Version->
	    Version
    end;
get_version(SpiderResponse) when record(SpiderResponse,spider_response) ->
    case read_field2(version,SpiderResponse) of
	[] ->
            undefined;
	undefined ->
            undefined;
	Version->
	    Version
    end.

%% +type get_offerPOrSUid(session() | spider_response()) -> 
%%                                          offerPOrSUid : string() | undefined.
get_offerPOrSUid(abs) ->
    undefined;
get_offerPOrSUid(Session) when record(Session,session) ->    
    case read_field(offerPOrSUid,Session) of
	[] ->
            undefined;
	undefined ->
            undefined;
	OfferPOrSUid->
	    OfferPOrSUid
    end;
get_offerPOrSUid(SpiderResponse) when record(SpiderResponse,spider_response) ->
    case read_field2(offerPOrSUid,SpiderResponse) of
	[] ->
            undefined;
	undefined ->
            undefined;
	OfferPOrSUid->
	    OfferPOrSUid
    end.

%% +type get_fileState(session() | spider_response()) -> 
%%                                          fileState : string() | undefined.
get_fileState(abs) ->
    undefined;
get_fileState(Session) when record(Session,session) ->    
    case read_field(fileState,Session) of
	[] ->
            undefined;
	undefined ->
            undefined;
	FileState->
	    FileState
    end;
get_fileState(SpiderResponse) when record(SpiderResponse,spider_response) ->
    case read_field2(fileState,SpiderResponse) of
	[] ->
            undefined;
	undefined ->
            undefined;
	FileState->
	    FileState
    end.

%% +type get_custMsisdn(session() | spider_response()) -> 
%%                                          custMsisdn : string() | undefined.
get_custMsisdn(abs) ->
    undefined;
get_custMsisdn(Session) when record(Session,session) ->    
    case read_field(custMsisdn,Session) of
	[] ->
            undefined;
	undefined ->
            undefined;
	CustMsisdn->
	    CustMsisdn
    end;
get_custMsisdn(SpiderResponse) when record(SpiderResponse,spider_response) ->
    case read_field2(custMsisdn,SpiderResponse) of
	[] ->
            undefined;
	undefined ->
            undefined;
	CustMsisdn->
	    CustMsisdn
    end.
	    
%% OBSOLETE: should use get_version !
%% +type get_record_name(session() | spider_response()) -> 
%%                                          custMsisdn : string() | undefined.
get_record_name(abs) ->
    element(1,#spider_response{});
get_record_name(Session) ->
    case get_spider_info_int(Session) of
	undefined -> undefined;
	SpiderRec -> element(1, SpiderRec)
    end.

slog_info(service_ko, ?MODULE, date_undefined)->
    #slog_info{descr="The date field is undefined",
               operational="Check the corresponded date field in session\n"}.
