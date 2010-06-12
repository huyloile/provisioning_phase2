%%%% Calltogether service functions to be called from the XML file.
%%%%
%%%% Two plug-ins:
%%%% list_create : add telephone numbers in the conference call list
%%%% list_display : display telephone numbers of the conference call list

-module(svc_calltogether).
-export([list_create/4,
         numbers_display/1,
         svcdata_null/2,
         prompt_redirect/3
	]).
-include("../../pserver/include/page.hrl").
-include("../../pserver/include/pserver.hrl").

list_create(abs,LinkOk,LinkNok,_) ->
     [{redirect,abs,LinkOk},{redirect,abs,LinkNok}];

list_create(Session,LinkOk,LinkNok,Value) ->
     case pbutil:all_digits(Value) of
       true ->
             L=Session#session.svc_data,
     	     NS=Session#session{svc_data=[Value|L]},
     	     {redirect,NS,LinkOk};
       false ->
             {redirect,Session,LinkNok}
     end.

svcdata_null(abs,Link) ->
    [{redirect,abs,Link}];

svcdata_null(Session,Link) ->
     Session1 = Session#session{svc_data=[]},
     {redirect,Session1,Link}.

numbers_display(abs) ->
     list_display(["...","number3","number2","number1"]);

numbers_display(Session) ->
     L=Session#session.svc_data,
     list_display(L).

list_display([]) ->
    [];

list_display([H|T]) ->
     list_display(T)++[{pcdata,H},br].

prompt_redirect(abs,Link,_) ->
     [{redirect,abs,Link}];

prompt_redirect(Session,Link,Value) ->
     {redirect,Session,Link}.
