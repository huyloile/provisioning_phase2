%% +deftype wifi() =
%%       #wifi{
%%             return           :: int(), 
%%	       password         :: string(),
%%	       text             :: string(),
%%             idDosOrchid      :: string()
%%            }.

-record(wifi,{return,
	      password,
	      text,
	      idDosOrchid=[]}
       ).
