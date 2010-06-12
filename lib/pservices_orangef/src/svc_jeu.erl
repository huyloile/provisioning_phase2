-module(svc_jeu).

-export([je_participe/2]).

-include("../../pserver/include/db.hrl").
-include("../../pdist/include/generic_router.hrl").
-include("../../oma/include/slog.hrl").

-export([slog_info/3]).

je_participe(abs,abs) -> 
    {redirect, abs, "#perdant"};
je_participe(Session,Souscription) -> 
    CurDateTime = erlang:localtime(),
    case get_winning_time() of 
        {ok, {DateGagnant, NombreBP}} -> 
            [Date, Time] = string:tokens(DateGagnant, " "),
            [Y, M, D] = string:tokens(Date, "-"),
            [H, Mi, S] = string:tokens(Time, ":"),
            DG = {{list_to_integer(Y), list_to_integer(M), list_to_integer(D)},
                  {list_to_integer(H), list_to_integer(Mi), list_to_integer(S)}},
            case (DG < CurDateTime) and (NombreBP > 0) of
                true -> 
                    {NewSession, Result} = 
                        svc_options:do_nopt_cpt_request(Session, [opt_jeu, opt_jeu_tirage], subscribe, []),
                    case Result of 
                        {ok_operation_effectuee, _} ->
                            slog:event(trace, ?MODULE, je_participe, {gagnant, Souscription, DG}),
                            update_awards(),
                            case Souscription of 
                                "mobi" -> 
                                    {redirect, NewSession, "#gagnant"};
                                _ -> 
                                    {redirect, NewSession, "#gagnant_cmo"}
                            end;
                        _ -> 
                            slog:event(failure, ?MODULE, maj_nopt_request_failed, Result),
                            redirect_perdant(NewSession,Souscription)
                    end;
                false -> 
                    redirect_perdant(Session,Souscription)
            end;
        {not_found, RES} -> 
            slog:event(internal, ?MODULE, perdant, {RES, CurDateTime}),
            redirect_perdant(Session,Souscription)
    end.

redirect_perdant(abs,abs) ->
    {redirect, abs, "#perdant"};
redirect_perdant(Session,Souscription) ->
    {NewSession, Result} = svc_options:do_opt_cpt_request(Session, opt_jeu_tirage, subscribe),
    case Souscription of 
        "mobi" -> {redirect, NewSession, "#perdant"};
        _ -> {redirect, NewSession, "#perdant_cmo"}
    end.

get_winning_time() ->
    Query = "SELECT dategagnant,nombrebp FROM jeu limit 1",
    Route = pbutil:get_env(pservices_orangef,jeu_routing),
    case ?SQL_Module:execute_stmt(Query,[orangef, Route],?SQL_SELECT_TIMEOUT) of
        {selected, _, [[DateTime, NombreBP]]} -> 
            {ok, {DateTime, NombreBP}};
        RES -> 
	    {not_found, RES}
    end.

update_awards() ->
    Commands = [ "UPDATE jeu SET nombrebp=nombrebp-1 limit 1",
		 "DELETE FROM jeu WHERE (nombrebp=0) limit 1"],
    Route = pbutil:get_env(pservices_orangef,jeu_routing),
    case ?SQL_Module:execute_stmt({atomic,Commands}, [orangef, Route], ?SQL_SELECT_TIMEOUT) of
	{committed,[{updated, 1},_]} ->
            updated;
	RES ->
            slog:event(internal, ?MODULE, counter_decreased_failed, RES),
            {nok, RES}
    end.

slog_info(failure, ?MODULE, maj_nopt_request_failed) ->  
    #slog_info{descr="An user win the game but can not do maj_nopt request to subscribe the options opt_jeu(472) and opt_jeu_tirage(85)",
               operational="Check logs to see the reason of error that request maj_nopt failed to subscribe options"};

slog_info(internal, ?MODULE, perdant) ->  
    #slog_info{descr="An user participates the game but losing",
               operational="Check logs to see the time they participate and the error when they submit to database"};
slog_info(internal, ?MODULE, counter_decreased_failed) ->
    #slog_info{descr="An user win the prize but the counter can not decreased",
        operational="Check logs to see the reason that mysql server can not be updated"}. 

