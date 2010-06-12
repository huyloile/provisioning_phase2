include ../../../../Makefile.defs

ERLPAS=	-pa ../ebin -pa ../../posutils/ebin -pa ../../ptester/ebin \
	-pa ../../pgsm/ebin -pa ../../posmon/ebin -pa ../../pfront/ebin \
	-pa ../../pserver/ebin -pa ../../pservices/ebin/ -pa ./ \
	-pa ../../pfront_orangef/ebin 	-pa ../../pfront_orangef/test \
        -pa ../../oma/ebin/ ../../pdist/ebin ../../pdatabase/ebin \
	-pa ../../pservices/test -pa ../../ucs/ebin -pa ../../pserver/ebin \
	-pa ../../xmerl/ebin -pa ../../pfront_orangef/test/sdp \
	-pa ../../pdist_orangef/ebin -pa ../../pfront_orangef/test/spider \
	-pa ../../eva/ebin -pa ../../common_tools/ebin \
	-pa ../../evae/ebin \
	-pa ../../oma/test/ \
	-pa ../../oma_init/ebin/

include $(TOPDIR)/make/test.mk

######################################################################
# Online tests.
# A server must be running at localhost:7431 (e.g. "make runsingle").
# For test-selfcare, the server must be at io0:7440.
######################################################################

# Note: - "make test_XXX" runs test_XXX:run() (see $(TOPDIR)/make/test.mk)
#       - "make test-XXX" runs test_XXX:online()

test-taxation_std_of:test_taxation_std_of.beam
	mysql -u possum -ppossum mobi -B -e "DELETE FROM users_orangef_extra";
	mysql -u possum -ppossum mobi -B -e "DELETE FROM stats";
	mysql -u possum -ppossum mobi -B -e "DELETE FROM svcprofiles";
	mysql -u possum -ppossum mobi -B -e "DELETE FROM users";
	$(TOPDIR)/possum/install/mysql/fill-users-mysql.sh;
	erl $(ERLPAS) -sname test@localhost -noinput\
                         -s test_taxation_std_of online\
                         -s erlang halt

online::online_all 
######################################################################

create50_test:	create50_test.beam
	erl -noshell -s create50_test run

######################################################################

DG_PAS=	-pa lib/posxml/ebin \
	-pa lib/xmerl/ebin \
	-pa lib/ucs/ebin \
	-pa lib/posutils/ebin \
	-pa lib/pserver/ebin \
	-pa lib/pservices/ebin \
	-pa lib/pservices_fun/ebin \
	-pa lib/pservices_demos/ebin \
	-pa lib/pservices_orangef/ebin \
	-pa lib/pservices_orangef/test \
	-pa lib/email/ebin \
	-pa lib/email/test \
	-pa lib/sms_portal/ebin \
	-pa lib/posmon/ebin \
	-pa lib/oma/ebin \
	-pa lib/pgsm/ebin \
	-pa lib/push/ebin \
	-pa lib/sms_portal/ebin \

docgraphs::	docgraphs_orangef.beam
	cd $(TOPDIR)/possum; erl -noinput $(DG_PAS) -config ./releases/orangef/test.config -s docgraphs_orangef run

ifndef testfun
testfun=online
endif

simple_test-%:: test_%.erl all
	$(ERL) -sname test@localhost $(ERLPAS) -noinput \
                -s test_$* $(testfun) -s erlang halt
