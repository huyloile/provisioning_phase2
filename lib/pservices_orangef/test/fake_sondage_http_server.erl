-module(fake_sondage_http_server).
-export([handle_request/2]).

-include("../../pfront/include/httpserver.hrl").

-define(HTTP_REPLY, http_reply).
-define(NODE, possum@localhost).
-define(HTTP, fake_sondage_http_server).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% httpserver_server handler
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% +type process(httpserver_request_info(),[ustring()]) -> httpserver_reply().
handle_request(#httpserver_request_info{method = get}=Req, Body) ->
    {200, "application/xml+soap", reply()}.

reply() ->
    "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
     <!DOCTYPE pages SYSTEM \"mml.dtd\">
      <pages>
	<page>
           A propos de la qualite d'ecoute du conseiller, etes-vous ...<br/>
           <a href=\"#tres_satisfait\">Tres satisfait</a><br/>
           <a href=\"#satisfait\">Satisfait</a><br/>
           <a href=\"#peu_satisfait\">Peu satisfait</a><br/>
           <a href=\"#pas_satisfait\">Pas du tout satisfait</a>
       </page>
        <page tag=\"tres_satisfait\">
         Tres satisfait
       </page>
       <page tag=\"satisfait\">
         Satisfait
       </page>
       <page tag=\"peu_satisfait\">
          Peu satisfait
       </page>
       <page tag=\"pas_satisfait\">
         Pas du tout satisfait
       </page>
     </pages>".
