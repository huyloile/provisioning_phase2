include ../../../../../Makefile.defs

include $(TOPDIR)/make/common.mk

all::  htdocs/oma htdocs/oma_login.html htdocs/handsim htdocs/stats htdocs/sce_style.css

include ../../../oma_webmin/vsn.mk
include ../../../webmin_cube/vsn.mk
include ../../../handsim/vsn.mk

htdocs/oma:
	ln -s ../../../../oma_webmin-$(VSN_oma_webmin)/priv/webmin/htdocs/oma $@

htdocs/oma_login.html:
	ln -s ../../../../oma_webmin-$(VSN_oma_webmin)/priv/webmin/htdocs/oma_login.html $@

htdocs/sce_style.css:
	ln -s ../../../../webmin_cube-$(VSN_webmin_cube)/priv/webmin/htdocs/sce_style.css $@

htdocs/handsim:
	ln -s ../../../../handsim-$(VSN_handsim)/priv/webmin $@

htdocs/stats:
	ln -sf ../../../../../run/stats $@

clean::
	rm -f htdocs/oma htdocs/oma_login.html htdocs/stats htdocs/sce_style.css

######################################################################
# From lib/posmon/Makefile

# MOD_TOPDIR=$(shell echo $(TOPDIR) | sed -e 's/\//\\\//g')
# 
# all::	priv/notify_cellcube.sh cgi-bin/make_charts.cgi cgi-bin/index.cgi priv/extract_pages.sh priv/crontab cgi-bin/filter/trans_page.awk
# 
# clean::
# 	rm -f conf/httpd.conf
# 	rm -f priv/webuser/conf/httpd.conf
# 	rm -f priv/extract_pages.sh priv/notify_cellcube.sh priv/crontab
# 	rm -f cgi-bin/index.cgi cgi-bin/make_charts.cgi
# 	rm -f cgi-bin/filter/trans_page.awk
# 
# conf/httpd.conf:	conf/httpd.conf.template
# 	sed	-e "s#SERVER_ROOT#$(TOPDIR)/possum/lib/posmon/priv/webmin#" \
# 		-e "s#SERVER_NAME#cellcube#" \
# 		-e "s#SERVER_ADMIN#support@cellicium.com#" < $^ > $@ \
# 	|| rm -f $@
# 
# priv/notify_cellcube.sh: priv/notify_cellcube.template
# 	sed	-e 's/%%TOPDIR%%/$(MOD_TOPDIR)/g' \
# 		-e 's/%%USER%%/$(USER)/g' < $^ > $@; \
# 	chmod a+x $@
# 
# cgi-bin/make_charts.cgi: cgi-bin/make_charts.cgi.template
# 	sed 	-e "s#DATA#$(TOPDIR)/possum/runtime/stats#" \
# 		-e "s#OWTCHART#/usr/local/lib#" \
# 		-e "s#STORE#$(TOPDIR)/possum/lib/posmon/htdocs#" \
# 		-e "s#REF#stats#"  < $^ > $@ \
# 	|| rm -f $@; \
# 	chmod a+x $@
# 	chmod a+x cgi-bin/create_charts.cgi
# 
# cgi-bin/index.cgi: cgi-bin/index.cgi.template
# 	sed 	-e "s#STORE#$(TOPDIR)/possum/lib/posmon/htdocs/#" \
# 		-e "s#REF#stats#"  < $^ > $@ \
# 	|| rm -f $@; \
# 	chmod a+x $@
# 
# priv/extract_pages.sh: priv/extract_pages.sh.template
# 	sed     -e 's/%%TOPDIR%%/$(MOD_TOPDIR)/g' < $^ > $@; \
# 	chmod a+x $@
# 
# priv/crontab: priv/crontab.template
# 	sed     -e 's/%%TOPDIR%%/$(MOD_TOPDIR)/g' < $^ > $@
# 
# cgi-bin/filter/trans_page.awk: cgi-bin/filter/trans_page.awk.template
# 	sed 	-e 's#%%TOPDIR%%#$(TOPDIR)/#' < $^ > $@
