-module(transfert_of_cra).

-export([cra_standard/1,if_error/1,do_transfert/3,
	log_transfert/4]).

%% +type cra_standard(string()) -> ok.
%%%% Callback function used by cdr_server.
%%%% Called each time a cdr file is closed.
%%%% on considére que le nombre de fichiers tournant est inférieur à  9999.
%%%% est que la gestion des cra est faite sur les back-end

cra_standard(FileName) ->
    Nodes = pbutil:get_env(pfront_orangef, transfert_nodes),
    DestFileName = format_dest_name(FileName),
    R=do_transfert(FileName,Nodes,DestFileName),
    case Nodes of
	[]->
	    %%%% no transfert 
	    ok;
	Nds->
	    log_transfert(R,Nds,FileName,DestFileName)
    end.

%% +type no_backend()-> integer().
no_backend()->
    pbutil:lpos(node(),pbutil:get_env(pserver,active_nodes)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% generic functions -not exported
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Format du nom de fihier aprés transfert
%%%% DC_USSD_QQQhhmmss_SSSS
%%%% QQQ: numéro du back-end sur 3 digit
%%%% SSSS: numéro de séquence sur 4 digit
%%%% hhmmss : heure minute seconde du transfert.

%% +type format_dest_name(FileName::string())-> File::string().
format_dest_name(FileName)->
    DestDir = pbutil:get_env(pfront_orangef, cdr_transfer_directory),
    [Name,Seq_Number]= string:tokens(FileName,"."),
    FName=lists:last(string:tokens(Name,"/")),
    %io:format("Name:~p~n",[Name]),
    SourceFileName=filename:absname(FileName),
    {H,M,S}=time(),
    Part2=pbutil:sprintf("%03d%02d%02d%02d_%04d",[no_backend(),H,M,S,
					     list_to_integer(Seq_Number)-1]),
    DestName=io_lib:format("~s_~s",[FName,Part2]),
    filename:join(DestDir, DestName).

%% +deftype transfert_result() = 
%%                          {ok,Node::string()} |
%%                          transfert_hs.


%%%% scp cra files in the first CFT node available.
%% +type do_transfert(SrcFileName::string(),[LoginAtNode::string()],
%%                    DestName::string()) -> transfert_result().
do_transfert(SrcFileName,[LoginAtNode|T],DestName)->
    %%%% -B batch mode and -p preserve modification times , access
    Cmd = "scp -B -p -q "++SrcFileName++" "++LoginAtNode++":"++DestName,
    %io:format("*DesFileName:~p~n~n~n~n~n~n",[Cmd]),
    case os:cmd(Cmd) of
	[]->
	    {ok,LoginAtNode};

	"Article 323-1 du code penal\nLe fait d'acceder ou de se maintenir, frauduleusement, dans tout ou partie d'un systeme de traitement automatise de donnees est puni de deux ans d'emprisonnement et de 30000 euros d'amende (150 000 euros pour les personnes morales)\n"->
	    {ok,LoginAtNode};

	E->
	    slog:event(failure,?MODULE,transfert_failed,E),
	    do_transfert(SrcFileName,T,DestName)
    end;
do_transfert(SrcFileName,[],DestName) ->
    transfert_hs.


%% +type log_transfert(transfert_result(),string(),string(),string())-> ok.
log_transfert(Err,Nodes,SrcName,DestName)->
    {ok,FD}=file:open("run/transfert_log",[append]),
    {Y,Mo,D}=date(),
    {H,M,S} =time(),
    Date = lists:flatten(pbutil:sprintf("%04d/%02d/%02d-%02d:%02d:%02d",
					[Y,Mo,D,H,M,S])),
    do_log_transfert(FD,Date,Err,Nodes,SrcName,DestName),

    file:close(FD).

%% +type do_log_transfert(term(),Date::string(),transfert_result(),
%%                        node(),SrcName::string(),DestName::string())->
%% ok | error.
do_log_transfert(FD,Date,{ok,Node},Nodes,SrcName,DestName)->    
    %%%% transfert successful
    Msg=io_lib:format("~s ~s ~s ~s ~s~n",[Date,Node,SrcName,
				       lists:flatten(DestName),
				       "Sucessful"]),
    file:write(FD,Msg);
do_log_transfert(FD,Date,transfert_hs,Nodes,SrcName,DestName) ->
    slog:event(failure,?MODULE,error_in_transfert,
	       {Nodes,SrcName,lists:flatten(DestName)}),
    Msg=io_lib:format("~s ~p ~s ~s ~s~n",[Date,Nodes,SrcName,
					  DestName,"Failed"]),
    Res=file:write(FD,Msg),
    error.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% use to redo error transfert update transfert file %%%%%%
%% +type if_error(FileName::string())-> ok.
if_error("transfert_log")->
    io:format("You can't use this file beecause is actually in use~n");
if_error(Fname) when list(Fname)->
    {ok,FD_read}=file:open(Fname,[read]),
    {ok,FD_write}=file:open(Fname++".new",[write]),
    case redo_transfert(FD_read,FD_write) of
	ok->
	    file:close(FD_read),
	    file:close(FD_write),
	    file:copy(Fname++".new",Fname);
	Else->
	    io:format("Error:~p~n",[Else])
    end.

%% +type redo_transfert(FD_read::term(),FD_write::term())-> 
%%            ok | end_of_file.
redo_transfert(FD_read,FD_write)->
   is_transfert_success(FD_read,FD_write).    

%% +type is_transfert_success(FD_read::term(),FD_write::term())-> 
%%            ok | end_of_file.
is_transfert_success(eof,_)->
    end_of_file;
is_transfert_success(FD_read,FD_write)->
    E=recup_info(read_line(FD_read)),
    case E of
	{failed,[_,SrcName,DestName]}->
	    %io:format("Failed may be restart~n"),
	    Nodes_2 = pbutil:get_env(pfront_orangef, transfert_nodes),
	    Res=do_transfert(SrcName,Nodes_2,DestName),
	    log_transfert(Res,Nodes_2,SrcName,DestName),
	    is_transfert_success(FD_read,FD_write);
	{sucess,[Node,SrcName,DestName]}->
	    %io:format("OK juste rewrite in tmp file~n"),
	    log_transfert({ok,Node},Node,SrcName,DestName),
	    is_transfert_success(FD_read,FD_write);	
	end_of_file ->
	    ok
    end.

%% +type recup_info([string()])-> 
%%    {sucess, [string()]}  |
%%    {failed, [string()]}  |
%%    end_of_file.
recup_info([Date,DestNode,ScrFile,DestFile,"Sucessful\n"])->
    {sucess,[DestNode,ScrFile,DestFile]};
recup_info([Date,DestNode,ScrFile,DestFile,"Failed\n"])->
    {failed,[DestNode,ScrFile,DestFile]};
recup_info(end_of_file) ->
    end_of_file;
recup_info(Else) ->
    io:format("Else:~p",[Else]),
    end_of_file.

%% +type read_line(FD::term())-> LINE::string() | end_of_file.
read_line(FD_read)->
    case io:get_line(FD_read,"") of
	eof->
	    end_of_file;
	L when list(L)->
	    string:tokens(L," ")
    end.
