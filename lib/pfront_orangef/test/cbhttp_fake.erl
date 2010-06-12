-module(cbhttp_fake).

-include("../../pfront/include/httpserver.hrl").

-export([request/2]).

request(#httpserver_request_info{abs_url=Url},Body)->
    Params = parse_body(Body),
    MSISDN = value("MSISDN",Params),
    IMSI = value("IMSI",Params),
    L3Dig = last3dig(MSISDN),
    Resp = resp(Url, L3Dig, MSISDN, IMSI, Params),
    {200,"text/xml",Resp}.

parse_body(String) ->
    lists:map(fun(E) -> case string:tokens(E, "=") of
			    [F,V] -> {F,V};
			    [F]   -> {F,""}
			end
	      end, string:tokens(String, "&")).

value(Field,Params) ->
    case lists:keysearch(Field, 1, Params) of
	{value, {_,V}} -> V;
	_ -> ""
    end.

last3dig(String) ->
    [C,B,A|_]=lists:reverse(String),
    [A,B,C].

resp("/rcm_sda.pgi", L3Dig, MSISDN, IMSI, Params) ->
    ORDRE = value("ORDRE",Params),
    Res = 
	case ORDRE of
	    "RC25" ->
		SUB = sub(Params),
		rc25(SUB,L3Dig);
	    "VCOD" ->
		case value("CODE",Params) of
		    "1234" -> "STATUT=0000;MSISDN=~s;IMSI=~s";
		    _ ->      vcod(L3Dig)
		end;
	    "MCOD" ->
		mcod(L3Dig)
	end,
    flatfmt(Res, [MSISDN,IMSI]);

resp("/rcm_ident40.pgi", L3Dig, MSISDN, IMSI, Params) ->
    Ident = ident_v1(L3Dig),
    flatfmt(Ident, [MSISDN,IMSI]);

resp("/rcm_mcc.pgi", L3Dig, MSISDN, IMSI, Params) ->
    Mcc = mcc(L3Dig),
    flatfmt(Mcc, [MSISDN,IMSI]);

resp("/rcm_dmcc.pgi", L3Dig, MSISDN, IMSI, Params) ->
    Dmcc = dmcc(L3Dig),
    flatfmt(Dmcc,[MSISDN]);

resp("/rcm_info.pgi", L3Dig, MSISDN, IMSI, Params) ->
    Info = 
	case sub(Params) of
	    cmo ->
		VER = value("VERSION",Params),
		case lists:last(VER) of
		    $1 -> info_cmo(L3Dig);
		    _  -> info_cmo_v2(L3Dig)
		end;
	    mob ->
		info_mob(L3Dig)
	end,
    flatfmt(Info, [MSISDN,IMSI]);
		   
resp("/rcm_pay.pgi", L3Dig, MSISDN, IMSI, Params) ->
    Pay = 
	case sub(Params) of
	    cmo ->
		VER = value("VERSION",Params),
		case lists:last(VER) of
		    $1 -> pay_cmo(L3Dig);
		    _  -> pay_cmo_v2(L3Dig)
		end;
	    mob ->
		pay_mob(L3Dig)
	end,
    PayType = value("TYPE_PAIEMENT",Params),
    CodeCourt = value("CODE_COURT",Params),
    Pay2 = 
	case {CodeCourt,PayType} of
	    {"","CC"} -> pay_cmo_v2("041");
	    _ -> Pay
	end,
    flatfmt(Pay2,[MSISDN,IMSI]);
		   
resp("/recharge_prepaid.cgi", L3Dig, MSISDN, IMSI, Params) ->
    Rech =
	case value("ORDRE",Params) of
	    "RECHARGE" ->
		case value("CODE_CONFIDENTIEL",Params) of
		    "1234" ->
			rech(L3Dig);
		    _ ->
			"STATUT=01;MSISDN=~s;IMSI=~s"
		end;
	    _ ->
		"STATUT=20;MSISDN=~s;IMSI=~s"
	end,
    flatfmt(Rech,[MSISDN,IMSI]).

sub(Params) ->
    {value, {_,ORIGINE}} = lists:keysearch("ORIGINE", 1, Params),
    case last3dig(ORIGINE) of
	"CMO" -> cmo;
	"OBI" -> mob;
	"MOB" -> mob
    end.

flatfmt(Fmt,Args) -> lists:flatten(io_lib:format(Fmt,Args)).
    

rc25(cmo,"001") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=3;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT==1111222233";
rc25(cmo,"002") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=2;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT==1111222233";
rc25(cmo,"003") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=1;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT==1111222233";	
rc25(cmo,"004") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=0;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";
rc25(cmo,"005") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=-1;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";	
rc25(cmo,"006") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=-2;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";
rc25(cmo,"007") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=-3;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";
rc25(cmo,"008") ->
    "STATUT=0152;MSISDN=~s;IMSI=~s;NADV=;NB_TENTATIVE=;NUM_CLIENT=";
rc25(cmo,"009") ->
    "STATUT=401;MSISDN=~s;IMSI=~s;NADV=;NB_TENTATIVE=;NUM_CLIENT=;"
	"STATUT_LIBELLE=Ordre inconnu";
rc25(cmo,_)     ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=11;NB_TENTATIVE=1;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";

rc25(mob,"012") ->
    "STATUT=0152;MSISDN=~s;IMSI=~s;NADV=;NB_TENTATIVE=;NUM_CLIENT=";
rc25(mob,"013") ->
    "STATUT=401;MSISDN=~s;IMSI=~s;NADV=;NB_TENTATIVE=;NUM_CLIENT=;"
	"STATUT_LIBELLE=Ordre inconnu";
rc25(mob,"014") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=TEST;NB_TENTATIVE=1;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";
rc25(mob,"551") ->
     "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=TEST;NB_TENTATIVE=1;"
         "CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233";
rc25(mob,_) ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NADV=BY;NB_TENTATIVE=1;"
	"CODE_PLAN_TARIFAIRE=PTE;NUM_CLIENT=1111222233".
    
vcod("011")  -> "STATUT=0152;MSISDN=~s;IMSI=~s";
vcod("012")  -> "STATUT=0158;MSISDN=~s;IMSI=~s";
vcod("013")  -> "STATUT=0157;MSISDN=~s;IMSI=~s";
vcod("014")  -> "STATUT=0159;MSISDN=~s;IMSI=~s";
vcod(_)  -> "STATUT=0156;MSISDN=~s;IMSI=~s".

mcod("020") -> "STATUT=0152;MSISDN=~s;IMSI=~s";
mcod(_) -> "STATUT=0000;MSISDN=~s;IMSI=~s".
     
ident_v1("012") ->
    "STATUT=0152;MSISDN=~s;IMSI=~s;NOADV=4;CODE_PLT=PTE;NUM_CLNT=1111222233;"
	"TYPE_DOS=;CODE_PROD=;SEG_OP=;PARC=;ID_SCS=;ETADOS=;LIB_ETADOS=;"
	"ETAPE_REC;SO=;FACT_MOY=;";
ident_v1("013") -> "STATUT=401;MSISDN=~s;IMSI=~s;STATUT_LIBELLE=Ordre inconnu";
ident_v1("014") ->
    "STATUT=0;MSISDN=~s;IMSI=~s;NOADV=0;CODE_PLT=PTE;NUM_CLNT=1111222233;"
	"TYPE_DOS=;CODE_PROD=;SEG_OP=;PARC=;ID_SCS=;ETADOS=;LIB_ETADOS=;"
	"ETAPE_REC;SO=;FACT_MOY=;";
ident_v1(_) ->
    "STATUT=0;MSISDN=~s;IMSI=~s;NOADV=4;CODE_PLT=PTE;NUM_CLNT=1111222233;"
	"TYPE_DOS=;CODE_PROD=;SEG_OP=;PARC=;ID_SCS=;ETADOS=;LIB_ETADOS=;"
	"ETAPE_REC;SO=;FACT_MOY=;".

mcc("151") -> "STATUT=0152;MSISDN=~s;IMSI=~s;CODE_COURT=";
mcc("152") -> "STATUT=0401;MSISDN=~s;IMSI=~s;CODE_COURT=;STATUT_LIBELLE=error";
mcc("153") -> "STATUT=0499;MSISDN=~s;IMSI=~s;CODE_COURT=";
mcc("154") -> "STATUT=0301;MSISDN=~s;IMSI=~s;CODE_COURT=";
mcc("155") -> "STATUT=0302;MSISDN=~s;IMSI=~s;CODE_COURT=";
mcc("156") -> "STATUT=0303;MSISDN=~s;IMSI=~s;CODE_COURT=";
mcc("157") -> "STATUT=0314;MSISDN=~s;IMSI=~s;CODE_COURT=";
mcc(_) -> "STATUT=0000;MSISDN=~s;IMSI=~s;CODE_COURT=1234".

dmcc("061") -> "STATUT=0152;MSISDN=~s";
dmcc("062") -> "STATUT=0401;MSISDN=~s;STATUT_LIBELLE=error format";
dmcc("063") -> "STATUT=0499;MSISDN=~s";
dmcc(_) -> "STATUT=0000;MSISDN=~s".

info_cmo("030") ->
    "STATUT=0296;DOSNUMID=;MSISDN=~s;IMSI=~s;EPR_NUM=;ESC_NUM=;"
	"DOS_MONTANT_REC=;DATEDER=;UNT_NUM=;PLAFOND_E=;SOLDE_E=;VALID24=;"
	"NB_CPT=;BONUS=";
info_cmo("031") ->
    "STATUT=0297;DOSNUMID=;MSISDN=~s;IMSI=~s;EPR_NUM=;ESC_NUM=;"
	"DOS_MONTANT_REC=;DATEDER=;UNT_NUM=;PLAFOND_E=;SOLDE_E=;VALID24=;"
	"NB_CPT=;BONUS=";
info_cmo("032") ->
    "STATUT=0298;DOSNUMID=;MSISDN=~s;IMSI=~s;EPR_NUM=;ESC_NUM=;"
	"DOS_MONTANT_REC=;DATEDER=;UNT_NUM=;PLAFOND_E=;SOLDE_E=;VALID24=;"
	"NB_CPT=;BONUS=";
info_cmo("033") ->
    "STATUT=0299;DOSNUMID=;MSISDN=~s;IMSI=~s;EPR_NUM=;ESC_NUM=;"
	"DOS_MONTANT_REC=;DATEDER=;UNT_NUM=;PLAFOND_E=;SOLDE_E=;VALID24=;"
	"NB_CPT=;BONUS=";
info_cmo("034") ->
    "STATUT=0499;DOSNUMID=;MSISDN=~s;IMSI=~s;EPR_NUM=;ESC_NUM=;"
	"DOS_MONTANT_REC=;DATEDER=;UNT_NUM=;PLAFOND_E=;SOLDE_E=;VALID24=;"
	"NB_CPT=;BONUS=";
info_cmo("035") ->
    "STATUT=0000;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=1024;"
	"DOS_MONTANT_REC=73000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=80000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=10;BONUS=5";
info_cmo(_) ->
    "STATUT=0000;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=1024;"
	"DOS_MONTANT_REC=5000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=80000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=10;BONUS=5".

info_cmo_v2("030") -> "STATUT=0296;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_cmo_v2("031") -> "STATUT=0297;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_cmo_v2("032") -> "STATUT=0298;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_cmo_v2("033") -> "STATUT=0299;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_cmo_v2("034") -> "STATUT=0499;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_cmo_v2("035") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=73000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=80000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;DOS_MONTANT_REC=5";
info_cmo_v2("064") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=73000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=800;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;DOS_MONTANT_REC=5";
info_cmo_v2(_) ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=1;"
	"DOS_CUMUL_REC=5000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=80000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;;DOS_MONTANT_REC=5".

info_mob("030") -> "STATUT=0296;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_mob("031") -> "STATUT=0297;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_mob("032") -> "STATUT=0499;DOSNUMID=;MSISDN=~s;IMSI=~s;";
info_mob("033") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=73000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=8000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;DOS_MONTANT_REC=0";
info_mob("034") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=53000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=60000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;DOS_MONTANT_REC=0";
info_mob("035") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=20000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=50000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;DOS_MONTANT_REC=0";
info_mob("036") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=5000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=80000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;;DOS_MONTANT_REC=1000";
info_mob("068") ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=0;"
	"DOS_CUMUL_REC=40000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=50000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;DOS_MONTANT_REC=0";
info_mob(_) ->
    "STATUT=0;DOSNUMID=123456;MSISDN=~s;IMSI=~s;EPR_NUM=00;ESC_NUM=1;"
	"DOS_CUMUL_REC=5000;DATEDER=3f8ff668;UNT_NUM=1;PLAFOND_E=80000;"
	"SOLDE_E=6000;VALID24=3f8ff668;NB_CPT=3;BONUS=5;MOBI_OPTION=1;"
	"DOS_DATE_DER_REC=3f8ff668;;DOS_MONTANT_REC=0".

pay_cmo("041") ->
    "STATUT=0296;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("042") ->
    "STATUT=0297;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("043") ->
    "STATUT=0301;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("044") ->
    "STATUT=0302;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("045") ->
    "STATUT=0303;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("046") ->
    "STATUT=0314;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("047") ->
    "STATUT=0298;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo("048") ->
    "STATUT=0401;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=;"
	"STATUT_LIBELLE=error";
pay_cmo("049") ->
    "STATUT=0499;MSISDN=~s;IMSI=~s;SOLDE=;UNT_NUM=;BON_PCT=;BONUS_MONTANT=";
pay_cmo(_) ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;SOLDE=6000;UNT_NUM=1;BON_PCT=5;"
	"BONUS_MONTANT=500".

pay_cmo_v2("041") -> "STATUT=0296;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("042") -> "STATUT=0297;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("043") -> "STATUT=0301;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("044") -> "STATUT=0302;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("045") -> "STATUT=0303;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("046") -> "STATUT=0314;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("047") -> "STATUT=0298;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("048") -> "STATUT=0401;MSISDN=~s;IMSI=~s;STATUT_LIBELLE=error";
pay_cmo_v2("049") -> "STATUT=0499;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("050") -> "STATUT=0300;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("051") -> "STATUT=0304;MSISDN=~s;IMSI=~s;";
pay_cmo_v2("006") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=1;TCP_NUM=1;CPP_DATE_LV=3f8ff668;"
	"SOLDE=18000;UNT_NUM=1;BON_PCT=5;BONUS_MONTANT=1000";
pay_cmo_v2(_) ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=1;TCP_NUM=1;CPP_DATE_LV=3f8ff668;"
	"SOLDE=6000;UNT_NUM=1;BON_PCT=5;BONUS_MONTANT=1000".

pay_mob("041") -> "STATUT=0296;MSISDN=~s;IMSI=~s;";
pay_mob("042") -> "STATUT=0297;MSISDN=~s;IMSI=~s;";
pay_mob("043") -> "STATUT=0340;MSISDN=~s;IMSI=~s;";
pay_mob("044") -> "STATUT=0314;MSISDN=~s;IMSI=~s;";
pay_mob("045") -> "STATUT=0344;MSISDN=~s;IMSI=~s;";
pay_mob("046") -> "STATUT=0345;MSISDN=~s;IMSI=~s;";
pay_mob("047") -> "STATUT=0350;MSISDN=~s;IMSI=~s;";
pay_mob("048") -> "STATUT=0351;MSISDN=~s;IMSI=~s;STATUT_LIBELLE=error";
pay_mob("049") -> "STATUT=0352;MSISDN=~s;IMSI=~s;STATUT_LIBELLE=error";
pay_mob("050") -> "STATUT=0353;MSISDN=~s;IMSI=~s;STATUT_LIBELLE=error";
pay_mob("051") -> "STATUT=0370;MSISDN=~s;IMSI=~s;STATUT_LIBELLE=error";
pay_mob("052") -> "STATUT=0352;MSISDN=~s;IMSI=~s;";
pay_mob("053") -> "STATUT=0353;MSISDN=~s;IMSI=~s;";
pay_mob("054") -> "STATUT=0370;MSISDN=~s;IMSI=~s;";
pay_mob("055") -> "STATUT=0371;MSISDN=~s;IMSI=~s;";
pay_mob("056") -> "STATUT=0372;MSISDN=~s;IMSI=~s;";
pay_mob("057") -> "STATUT=0373;MSISDN=~s;IMSI=~s;";
pay_mob("058") -> "STATUT=0377;MSISDN=~s;IMSI=~s;";
pay_mob("059") -> "STATUT=0399;MSISDN=~s;IMSI=~s;";
pay_mob("060") -> "STATUT=0499;MSISDN=~s;IMSI=~s;";
pay_mob("061") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=1:4;"
	"CPP_DATE_LV=1066399336:3f8ff668;SOLDE=6000:1000;UNT_NUM=1:1;"
	"BON_PCT=5:5;BONUS_MONTANT=500:100";
pay_mob("062") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=1:111;"
	"CPP_DATE_LV=1066399336:3f8ff668;SOLDE=21000:20000;UNT_NUM=1:1;"
	"BON_PCT=5:5;BONUS_MONTANT=0:0";
pay_mob("063") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=1:113;"
	"CPP_DATE_LV=1066399336:3f8ff668;SOLDE=7000:20000;UNT_NUM=1:1;"
	"BON_PCT=5:5;BONUS_MONTANT=0:0";
pay_mob("064") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=140:141;"
	"CPP_DATE_LV=1066399336:1066399336;SOLDE=15000:20000;UNT_NUM=1:1;"
	"BON_PCT=0:0;BONUS_MONTANT=0:0";
pay_mob("065") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=1:110;"
	"CPP_DATE_LV=1066399336:3f8ff668;SOLDE=21000:20000;UNT_NUM=1:1;"
	"BON_PCT=5:5;BONUS_MONTANT=0:0";
pay_mob("066") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=1:109;"
	"CPP_DATE_LV=1066399336:3f8ff668;SOLDE=21000:20000;UNT_NUM=1:1;"
	"BON_PCT=5:5;BONUS_MONTANT=0:0";
pay_mob("067") ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=2;TCP_NUM=1:92;"
	"CPP_DATE_LV=1066399336:3f8ff668;SOLDE=20000:21000;UNT_NUM=1:1;"
	"BON_PCT=5:5;BONUS_MONTANT=0:0";
pay_mob(_) ->
    "STATUT=0000;MSISDN=~s;IMSI=~s;NB_CPT=1;TCP_NUM=1;CPP_DATE_LV=1066399336;"
	"SOLDE=6000;UNT_NUM=1;BON_PCT=5;BONUS_MONTANT=500".

rech("001") -> "STATUT=00;MSISDN=~s;IMSI=~s;SOLDE=15000;DLV=1125595025";
rech("002") -> "STATUT=21;MSISDN=~s;IMSI=~s";
rech("003") -> "STATUT=02;MSISDN=~s;IMSI=~s";
rech(_) -> "STATUT=0000;MSISDN=~s;IMSI=~s;SOLDE=20000;DLV=1125595025".
