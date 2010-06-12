include ../../../Makefile.defs

include $(TOPDIR)/make/app.mk

SUBDIRS+=	priv


# "cvs checkout" does not restore symbolic links.

install-devel:
	erl -sname possum@localhost -pa $(wildcard ../*/ebin) \
	    -mnesia dir '"../../run/mnesia"' \
	    -s mnesia start \
	    -s pservices_orangef_app install  'possum@localhost' \
	    -s mnesia stop \
	    -s erlang halt

# make NODE=admin@admin0 NODES="srv@srv0 srv@srv1" install-dist
install-dist:
	erl -sname $(NODE) -pa test -pa $(wildcard ../*/ebin) \
	    -mnesia dir '"../../run/mnesia"' \
	    -s mnesia start \
	    -s pservices_orangef_app install  ${NODES} \
	    -s mnesia stop  \
	    -s erlang halt
