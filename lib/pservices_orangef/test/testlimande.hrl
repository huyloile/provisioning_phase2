%% cmo
-define(msisdn_cmo,             "+99901222222").
-define(msisdn_cmo_nok,         "+99901000003").
-define(msisdn_cmo_sans_credit, "+99901222223").
-define(imsi_cmo, "999000901222222").
-define(imsi_cmo_nok, "999000901000003").
-define(imsi_cmo_sans_credit, "999000901222223").
-define(service_code, "#123").

%% postpaid99901222223
-define(msisdn_gp,"+33900000001").
-define(msisdn_gp_nok,"+33900000002").
-define(imsi_gp, "999000900000001").
-define(imsi_gp_nok, "999000900000002").

%% mobi
-define(msisdn_mobi,             "+99901222224").
-define(msisdn_mobi_nok,         "+99901000004").
-define(msisdn_mobi_nat,         "9901222224").
-define(msisdn_mobi_nok_nat,     "9901000004").
-define(imsi_mobi,               "999000901222224").
-define(imsi_mobi_nok,           "999000901000004").


-define(Offres,
	[{"LIM1","Mentions Legales1","suite Mentions & Legales1","Descriptions1"},
	 {"LIM2","Mentions Legales2","suite Mentions Legales2","Descriptions2"},
	 {"LIM3","Mentions Legales3","suite Mentions Legales3","Descriptions3"}]).

-record(testOffre,{idOffre,mentions,description}).
