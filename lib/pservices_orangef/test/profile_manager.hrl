-define(csl_op, "csl_op").
-define(csl_doscp, "csl_doscp").
-define(csl_tck, "csl_tck").
-define(maj_op, "maj_op").
-define(maj_nopt, "maj_nopt").
-define(mod_cp, "mod_cp").
-define(tra_credit, "tra_credit").
-define(rec_tck, "rec_tck").
-define(predefined_answer, "predefined_answer").
-define(msisdn, "msisdn").
-define(imsi, "imsi").
-define(sachem,"sachem").
-define(spider,"spider").
-define(asmetier,"asmetier").
-define(ocfrdp,"ocfrdp").

%%%Asmetier request
-define(getIdent,"getIdent").
-define(getImpact,"getImpact").
-define(doMod,"doMod").
-define(getServicesOptionnels,"getServicesOptionnels").
-define(isRechargeableMobi,"isRechargeableMobi").
-define(isRechargeableCmo,"isRechargeableCmo").
-define(doRechargeCB,"doRechargeCB").

-define(PREDEFINED_ANSWER,[{"csl_doscp",ok},{"csl_op",ok},{"csl_tck",ok},{"maj_op",ok},
        {"mod_cp",ok},{"maj_nopt",ok}, {"tra_credit",ok},{"rec_tck",ok}]).

%% Define commonly used Sachem fields
%% Real fields in Sachem response must be a string

%% Please notice that some fields are different from request to the other :
%% example Msisdn is called "DOS_MSISDN" in csl_doscp and csl_op, but "MSISDN"
%% in maj_nopt
-record(test_profile,{
        msisdn, 
        imsi, 
        imei="35061310100006",
        language="fr",
        sub="mobi",
        dcl,				%%init sachem
        comptes,			%%init sachem
        options,			%%init sachem
        interfaces,
        vlr,
        ocf_options=error,%% ocfrdp
        prepaidFlag,		%% ocfrdp
        tac,				%% ocfrdp
        ussd_level=1, 	%% ocfrdp
        tech_seg_code, 	%% ocfrdp
        comment="Test number",
        sachem_data,
        spider_data,
        asmetier_data,
        ocfrdp_data,
        mipc_data,
        vpbx_data,
        predefined_answer
    }).

-record(option,{
        top_num,
        opt_date_souscription,
        opt_date_deb_valid,
        opt_date_fin_valid,
        opt_info1,
        opt_info2,
        tcp_num,
        ptf_num,
        rnv_num,
        cpp_cumul_credit
    }).

-record(spider,{
        status,
        profile,
        bundles=[]
    }).

-record(spider_status,{
        statusCode="a300",
        statusType="0",
        statusName="BalanceGetSuccess",
        statusDescription="Successful get Invocation"
    }).
-record(spider_profile,{
        durationHf="OBDD",
        fileState="",
        custName="",
        custImsi="",
        custMsisdn="",
        offerPOrSUid="MOB",
        offerType="",
        invoiceDate="2005-01-01T07:08:00.MMMZ",
        nextInvoice="2006-02-02T07:08:00.MMMZ",
        validityDate="2007-03-08T07:08:00.MMMZ",
        amounts=[],
        fileRestitutionType="",
        frSpecificPrepaidOfferValue=""
    }).

-record(spider_bundle,{
        bundleLevel="2",
        priorityType="A",
        restitutionType="FORF",
        reinitDate="50",
        bundleDescription="label forf",
        reactualDate="2005-06-05T07:08:09.MMMZ",
        desactivationDate="2006-07-06T07:08:09.MMMZ",
        bundleType="0003",
        credits=[],
        previousPeriodLastUseDate="",
        thresholdFlag="",
        firstUseDate="2005-06-05T07:08:09.MMMZ",
        lastUseDate="2009-08-13T07:08:09.MMMZ",
        exhaustedLabel="",
        bundleAdditionalInfo="",
        bundleStatus="-"
    }).

-record(spider_credit,{
        name="balance",
        unit="TEMPS",
        value="00min00s",
        additionalInfo=""
    }).

-record(asm_option,{
        code_so="",
        option_name="Option",
        dateActivation="15/01/2009 14:00:22",
        dateDesactivation="15/01/2010 14:00:22"
    }).

-record(asm_profile,{
        code_so="",
        option_name="Option",
        code_segco=""
    }).
-record(account,{
        tcp_num=1,
        montant=10000,
        unit=1,
        dlv=1263393251,
	bon_montant=0
    }).
-record(sachem_recharge,{
        ctk_num=1,
        ttk_num=143,
        accounts=[#account{}]
    }).

