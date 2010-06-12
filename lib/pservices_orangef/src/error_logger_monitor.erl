%%%% This module can be used to monitor error_logger
%%%% and generate an alarm when exceeding a threshold
%%%% To be triggered, check_queue_length can be called
%%%% from a crontab

-module(error_logger_monitor).
-export([check_queue_length/1]).


get_queue_length() ->
    {message_queue_len, Length} = 
        process_info(whereis(error_logger), message_queue_len),
    Length.
    
check_queue_length(Max_queue_len) ->
    Queue_length = get_queue_length(),
    {ok, File} = file:open("run/log_error_logger_queue.txt",[append]),
    Now =  erlang:localtime(),
    io:fwrite(File, "~p ~p~n", [Now, Queue_length]),
    file:close(File),
    if Queue_length > Max_queue_len ->
            catch eva:asend_alarm(internal,
                                  {internal, error_logger_queue_overloaded}, 
                                  self(), 
                                  "error_logger_queue_overloaded", ""),
            ok;
       true -> ok
    end.
