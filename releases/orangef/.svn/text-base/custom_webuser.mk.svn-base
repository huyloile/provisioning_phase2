include $(TOPDIR)/possum/lib/webuser_orangef/vsn.mk

all::
	ln -fs ../../lib/webuser_orangef-$(VSN_webuser_orangef)/priv/orangef/cgi-bin

auth conf htdocs icons::
	ln -fs ../../lib/webuser_orangef-$(VSN_webuser_orangef)/priv/orangef/$@

clean::
	rm -f cgi-bin
