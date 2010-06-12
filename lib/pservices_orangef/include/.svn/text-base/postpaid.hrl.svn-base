%% +deftype offre_postpaid() = gp | pro.

%% +deftype postpaid_user_state() =
%%       #postpaid_user_state{
%%               offre            :: offre_postpaid(),
%%               msisdn           :: string(), 
%%		 mmsinfos         :: term(),
%%               smsinfos         :: term(),
%%               opt_activ        :: record(),
%%               spider           :: undefined | getBalanceResponse(),
%%               parentChild      :: undefined | parentChild()
%%		}.

-record(postpaid_user_state, {
	  offre,
	  msisdn, 
	  mmsinfos,
	  smsinfos,
	  opt_activ,
	  spider,
	  parentChild,
	  o2o_data
	 }).
