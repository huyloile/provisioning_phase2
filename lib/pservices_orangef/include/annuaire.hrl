
%% +deftype annu_service() = 
%%     #annu_service{ command :: string(),
%%                    key     :: string(),
%%                    param   :: string()}.
-record(annu_service,{command="",key="",param=""}).

%% +deftype annuaire() =
%%     #annuaire{ key         :: integer(),
%%                name        :: string(),
%%                number      :: string(),
%%                heading     :: string(),
%%                theme       :: string(),
%%                new         :: bool(),
%%                rules       :: string(),
%%                tease_multi :: string(),
%%                tease_head  :: string(),
%%                services    :: [annu_service()],
%%                cust_care   :: string()}.
-record(annuaire,{key=1,name="",number="",heading="",theme="",new="",
		  rules="",tease_multi="",tease_head="",services=[],
		  cust_care=""}).


%% +deftype next_page() =
%%     #next_page{ mode           :: undefined | theme | editor | number,
%%                 themes_links   :: [string()],
%%                 theme          :: string(),
%%                 headings_links :: [string()],  
%%                 heading        :: string(),
%%                 editors_links  :: [string()],
%%                 editor         :: string() | '_',
%%                 noheadings     :: bool(),                  
%%                 tease_multi    :: string(),
%%                 number         :: string() | '_',
%%                 results        :: [annuaire()],
%%                 end_info       :: [string()]}.
-record(next_page,{mode,themes_links=[],theme="",headings_links=[],
		   heading="",editors_links=[],editor="",noheadings=false,
		   tease_multi="",number="",results=[],end_info=[]}).



