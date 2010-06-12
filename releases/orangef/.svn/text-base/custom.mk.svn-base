
CUSTOM_CONFIG=	test

# added to /lib SUBDIRS
CUSTOM_SUBDIRS=	pfront_orangef pdist_orangef pservices_orangef	\
		webmin_orangef webuser_orangef

# added at the end of runcustom command
CUSTOM_RUN= -pa lib/common_test_tools/ebin \
	-pa lib/pfront_orangef/test \
	-pa lib/pfront_orangef/test/sdp -s sachem_fake start_reliable \
	-pa lib/pfront_orangef/test/sdp -s sachem_cmo_fake start_reliable \
	-pa lib/pfront_orangef/test/sdp -s tlv_fake start_reliable \
	-pa lib/pfront_orangef/test/sdp -s dme_fake start \
	-pa lib/pfront_orangef/test/ocfrdp -s ocfrdp_fake start \
	-pa lib/pfront_orangef/test/sdp -s smsinfos_fake start \
	-pa lib/pfront_orangef/test/wifi -s wifi start \
	-pa lib/pservices_orangef/test -s one2one start \
	-pa lib/pfront_orangef/test/webservices -s webservices_server start \
	-pa lib/pfront_orangef/test/spider -s mod_spider start

# added to the make install-generic
CUSTOM_INSTALL=	-s pservices_orangef_app install 'possum@localhost'

CUSTOM_PRE_CMDS=

custom_pre_cmds:
	make -C lib/pfront_orangef/test cbhttp-stop-httpd
	make -C lib/pfront_orangef/test cbhttp-start-httpd

######################## 

# Config for testing with X.25 through rsh.
# You must have a mwp sql base in local to make test.
rundevel-x25:
	erl -sname possum@localhost  \
		-boot releases/devel/cellcube \
		-boot_var PRODUCT_ROOT . \
		-config releases/devel/cellcube \
		-config releases/devel/devel_license \
		-config releases/devel/$(DEVEL) \
		-pa test/mps -s mps_fake run  \
		-pa lib/pfront_orangef/test/sdp -s sachem_fake start_reliable \
		-pa lib/pfront_orangef/test/sdp -s sachem_cmo_fake start_reliable \
		-pa lib/pfront_orangef/test/sdp -s tlv_fake start_reliable \
		-pa lib/pfront_orangef/test/sdp -s dme_fake start \
		-pa lib/pfront_orangef/test/ocfrdp -s ocfrdp_fake start \
		-pa lib/pfront_orangef/test/sdp -s smsinfos_fake start \
		-pa lib/pfront_orangef/test/wifi -s wifi start \
		-pa lib/pservices_orangef/test -s one2one start \
		-pa lib/pfront_orangef/test/spider -s mod_spider start

custom_install_orangef:
	tar cvfz custom_install-$(CUSTOM)-$(VERSION)-$(OTP_VERSION)-$(OS_RELEASE).tgz --exclude *.svn* --exclude *.erl -c $(wildcard $(CUSTOM_SUBDIRS:%=lib/%/ebin) $(CUSTOM_SUBDIRS:%=lib/%/priv) $(CUSTOM_SUBDIRS:%=lib/%/xml_src)) run/xml/mcel/acceptance/*.xml run/xml/mcel/acceptance/*/*.xml releases/$(CUSTOM)/

# Config for functional and performance tests:
# - More servers_per_node
# - Keywords compatible with old test suites (except selfcare)
# - Enable qosmons.
# - No stdout
runtest:
	mkdir -p $(TOPDIR)/possum/run/sasl
	erl -sname possum@localhost  \
		-boot releases/devel/cellcube \
		-boot_var PRODUCT_ROOT . \
		-config releases/devel/cellcube \
		-config releases/devel/$(DEVEL) \
                -config releases/devel/devel_auth \
		-config releases/devel/devel_license \
		-pserver back_keyword '"0"' \
		-pserver menu_keyword '"00"' \
		-pserver servers_per_node 1000 \
		-posmon slog_filter '[{bug,true},{failure,true},{error,true}]'\
		-pdist trace_ussd false \
		-pa test/mps -s mps_fake run  \
		-pa lib/pfront_orangef/test/sdp -s sachem_fake start_reliable \
		-pa lib/pfront_orangef/test/sdp -s sachem_cmo_fake start_reliable \
		-pa lib/pfront_orangef/test/sdp -s tlv_fake start_reliable \
		-pa lib/pfront_orangef/test/sdp -s dme_fake start \
		-pa lib/pfront_orangef/test/ocfrdp -s ocfrdp_fake start \
		-pa lib/pfront_orangef/test/sdp -s smsinfos_fake start \
		-pa lib/pfront_orangef/test/wifi -s wifi start \
		-pa lib/pservices_orangef/test -s one2one start \
		-pa lib/pfront_orangef/test/spider -s mod_spider start \
	        -s pcontrol enable_itfs io_mwp_mem_test possum@localhost \
		-s pcontrol enable_itfs io_mwp_disk_test possum@localhost \
		-s pcontrol enable_itfs	io_smpp_qosmon possum@localhost \
		-s pcontrol enable_qosmons qosmon_123 qosmon_148 > $(TOPDIR)/possum/run/log.txt 2>&1

install-generic: install-orangef-db

install-orangef-db:
	mysql -uroot -Bse "ALTER TABLE users modify subscription text" mobi || true
	mysql -uroot mobi --force < lib/pservices_orangef/priv/create-orangef-tables.sql || true
	mysql -uroot mobi < lib/webuser_orangef/priv/create-webuser_of-tables.sql || true
	mysql -uroot mobi < lib/pservices_orangef/priv/quicksilver/create-quicksilver.sql || true
	mysql -uroot mobi < lib/pservices_orangef/priv/quicksilver/populate-quicksilver.sql || true
	mysql -uroot mobi < lib/pservices_orangef/priv/jeu/create-jeu.sql || true
	mysql -uroot mobi < lib/pservices_orangef/priv/jeu/populate-jeu.sql || true
