include $(TOPDIR)/possum/lib/webmin_orangef/vsn.mk

htdocs auth::
	ln -fs ../../lib/webmin_orangef-$(VSN_webmin_orangef)/priv/webmin/$@
