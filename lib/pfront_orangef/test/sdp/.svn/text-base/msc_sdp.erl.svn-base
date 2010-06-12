-module(msc_smpp).
-compile(export_all).

nodes() -> [automsc@localhost,
	    io0@localhost, admin0@localhost, server0@localhost].


procs() -> ['fake_mobile_+98612345678', ussdc_fake,
	    x25_to_ussdc_fake, smpp_lowlevel0,
	    io_ussd_smpp_fake, fep_ussd0, routeur0,
	    ussd_router, psrv37, mysql_server].

setup() ->
    pong = net_adm:ping(io0@localhost),
    x25_to_ussdc_fake:start_link(),
    receive after 100 -> ok end,
    ussdc_fake:start_link(smpp_lowlevel0),
    mobile_ussd:start_link("+98612345678"),
    receive after 1000 -> ok end,
    %% code_server looses the trace token when it loads a module.
    %% This dummy session ensures that all modules are loaded for the
    %% real tracing.
    do_menus(["#123#"]),
    receive after 1000 -> ok end,
    'fake_mobile_+98612345678' ! stop,
    %% Wait for the session timeout (pserver)
    receive after 10000 -> ok end.

run() ->
    do_menus(["#123#", "1"]).

do_menus([]) -> 
    stop;
do_menus([S|Choices]) ->
    'fake_mobile_+98612345678' ! {send, S},
    receive after 500 -> ok end,
    'fake_mobile_+98612345678' ! {self(), ping},
    receive {_, pong} -> ok after 1000 -> exit(ping_timeout) end,
    do_menus(Choices).
