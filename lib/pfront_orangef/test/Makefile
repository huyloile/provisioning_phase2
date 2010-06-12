include ../../../../Makefile.defs

ERLPAS=	-pa ../../pgsm/ebin -pa ../../posutils/ebin -pa ../../pfront/ebin \
	-pa ../../pserver/ebin \
	-pa ../../posmon/ebin -pa ../../pfront_orangef/ebin \
	-pa ../../oma/ebin -pa ../../xmerl/ebin -pa ../../eva/ebin \
	-pa ../../pservices/ebin -pa ../../pfront_orangef/test \
	-pa ../../pdist_orangef/ebin -pa ../../pfront/test \
    -pa ../../pservices/test -pa ../../ptester/ebin \
    -pa ../../ucs/ebin -pa ../../pservices_orangef/test\
    -pa ../../common_tools/ebin -pa WSDL

SUBDIRS+=  sdp ocfrdp wifi spider webservices WSDL

include $(TOPDIR)/make/test.mk
include $(TOPDIR)/make/subdirs.mk

run-test:
	erl $(ERLPAS) -s test_smppasn_server run -s erlang halt

SIMU_CONFIG=	simu.config
SIMU_OUTBIND_CONFIG=	simu-outbind.config

run-mqseries: 	all
	erl $(ERLPAS) -run test_mqseries	

run-esme:	all
	erl $(ERLPAS) -config $(SIMU_CONFIG) -run esme_simu

run-ussdc:	all
	erl $(ERLPAS) -config $(SIMU_CONFIG) -run ussdc_simu

run-esme-outbind:	all
	erl $(ERLPAS) -config $(SIMU_OUTBIND_CONFIG) -run esme_simu

run-ussdc-outbind:	all
	erl $(ERLPAS) -config $(SIMU_OUTBIND_CONFIG) -run ussdc_simu


test-batch_ocf:test_batch_ocf.beam
	mysql -u possum -ppossum mobi -B -e "DELETE FROM users_orangef_extra";
	mysql -u possum -ppossum mobi -B -e "DELETE FROM stats";
	mysql -u possum -ppossum mobi -B -e "DELETE FROM svcprofiles";
	mysql -u possum -ppossum mobi -B -e "DELETE FROM users";
	$(TOPDIR)/possum/install/mysql/fill-users-mysql.sh;
	erl $(ERLPAS) -sname test@localhost -noinput\
                         -s test_batch_ocf online\
                         -s erlang halt

online:: online_all

######################################################################
# Testing compatibility with snacc

SNACC=/usr/local/build/snacc-1.3

ASN1_MODULE=SMPP37

run-snacc:	all $(ASN1_MODULE).tt netrelay
	rxvt -geometry 80x5+1+1 -font fixed -title ESME -e sh -c	\
	    "erl $(ERLPAS) -config $(SIMU_CONFIG) -run esme_simu	\
	     | tee /tmp/esme.log" &
	rxvt -geometry 80x5+512+1 -font fixed -title USSD-C -e sh -c	\
	    "sleep 2;					\
	     erl $(ERLPAS) -config $(SIMU_CONFIG)	\
		-ussdc_simu port 7432 -run ussdc_simu	\
	     | tee /tmp/ussdc.log" &
	/bin/echo -n > /tmp/log-server.asn1
	/bin/echo -n > /tmp/log-client.asn1
	rxvt -geometry 80x20+1+100 -font fixed -title ESME -e		\
		tail -f /tmp/log-server.asn1 &
	rxvt -geometry 80x20+512+100 -font fixed -title USSDC -e	\
		tail -f /tmp/log-client.asn1 &
	PATH=$(SNACC)/tbl-tools/berdecode:$$PATH 			\
		./netrelay -log-server "./log-tcp.sh server"		\
			   -log-client "./log-tcp.sh client"		\
			-verbose 7432 localhost 7431			\
		    > /tmp/log-netrelay.txt

NETRELAY_VERSION=1.1-solaris8
NETRELAY=/tmp/netrelay-$(NETRELAY_VERSION)

distrib-netrelay:	all $(ASN1_MODULE).tt netrelay
	rm -rf $(NETRELAY)
	mkdir $(NETRELAY)
	cp netrelay $(NETRELAY)
	cp $(SNACC)/tbl-tools/berdecode/berdecode $(NETRELAY)
	cp README.netrelay $(NETRELAY)/README
	cp log-tcp.sh $(NETRELAY)
	cp run-netrelay.sh $(NETRELAY)/run
	cp $(ASN1_MODULE).tt $(NETRELAY)
	cd /tmp; tar zcvf netrelay-$(NETRELAY_VERSION).tar.gz \
			  netrelay-$(NETRELAY_VERSION)

netrelay:	netrelay.ml
	ocamlc -custom unix.cma $^ -o $@ -cclib "-lunix"

test-emi: all
	erl $(ERLPAS) -s test_emi_server online -s erlang halt


clean::
	rm -f netrelay *.cmo *.cmi

%.tt:	../src/%.asn
	$(SNACC)/compiler/snacc -T $@ $<

######################################################################
# Distrib

# Should match the versions in esme_simu.app and ussdc_simu.app,
# and the CVS tag too.
ESME_SIMU_VERSION=1.3devel

SIMU=/tmp/esme-simu-$(ESME_SIMU_VERSION)
SSRC=..
distrib-simu:	all
	rm -rf $(SIMU)
	mkdir $(SIMU)
	mkdir $(SIMU)/src
	mkdir $(SIMU)/ebin
	mkdir $(SIMU)/include
	cp README.simu					$(SIMU)/README
	cp CHANGES.simu					$(SIMU)/CHANGES
	cp Makefile.simu				$(SIMU)/Makefile
	cp $(SSRC)/include/ussd.hrl			$(SIMU)/include
	cp $(SSRC)/include/smpp_constants.hrl		$(SIMU)/include
	cp $(SSRC)/include/smpp_server.hrl		$(SIMU)/include
	cp $(SSRC)/../pfront/include/tcp_listener.hrl	$(SIMU)/include
	cp $(SSRC)/../pfront/ebin/tcp_listener.beam	$(SIMU)/ebin
	cp $(SSRC)/ebin/smppasn_server.beam		$(SIMU)/ebin
	cp $(SSRC)/ebin/ussd_server.beam		$(SIMU)/ebin
	cp $(SSRC)/src/$(ASN1_MODULE).asn		$(SIMU)/src
	cp $(SSRC)/test/test_smppasn_server.erl		$(SIMU)/src
	cp $(SSRC)/test/esme_simu.erl			$(SIMU)/src
	cp $(SSRC)/test/ussdc_simu.erl			$(SIMU)/src
	cp $(SSRC)/test/simu.config			$(SIMU)
	cp $(SSRC)/test/simu-bind.config		$(SIMU)
	cp $(SSRC)/test/simu-outbind.config		$(SIMU)
	cp $(SSRC)/test/esme_simu.app			$(SIMU)/src
	cp $(SSRC)/test/ussdc_simu.app			$(SIMU)/src
	cp -a $(SSRC)/test/logs				$(SIMU)
	make -C $(SIMU) compile
	cd /tmp; tar zcvf esme-simu-$(ESME_SIMU_VERSION).tar.gz \
			  esme-simu-$(ESME_SIMU_VERSION)


