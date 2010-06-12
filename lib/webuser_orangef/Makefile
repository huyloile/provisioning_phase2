include ../../../Makefile.defs
MOD_TOPDIR=$(shell echo $(TOPDIR) | sed -e 's/\//\\\//g')

include $(TOPDIR)/make/app.mk

all:: priv/orangef/conf/httpd.conf priv/orangef/cgi-bin/index.cgi

clean::
	rm -f priv/orangef/cgi-bin/index.cgi

priv/orangef/cgi-bin/index.cgi: priv/orangef/cgi-bin/index.cgi.template
	sed 	-e "s#STORE#$(TOPDIR)/possum/lib/webuser_orangef/priv/orangef/htdocs/secure#" \
		-e "s#REF#stats#"  < $^ > $@ \
	|| rm -f $@; \
	chmod a+x $@

all::	priv/orangef/htdocs/secure/stats

priv/orangef/htdocs/secure/stats:
	ln -s ../../../../../../run/stats $@ || true
