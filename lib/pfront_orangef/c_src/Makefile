include ../../../../Makefile.defs


HAS_MQM=      $(shell test -f /opt/mqm/inc/cmqc.h && echo 1 || echo 0)
ifeq "$(HAS_MQM)" "1"
APPS=	mqseries_port
APPS+=  mqseries_port_get
else
$(warning "cmqc.h not found. Will not buit MQseries utilities.")
endif

CFLAGS=	-O2 -ansi -Wall

ERL_INTERFACE=	$(wildcard $(ERL_TOP)/lib/erl_interface-*)
MYLIB=	-L/usr/lib -L/usr/X11R6/lib
MQNC=	-I/opt/mqm/inc

CLIBS=	$(MYLIB) -lmqm -L$(ERL_INTERFACE)/lib -lei

CINCPATH=	-I$(ERL_TOP)/usr/include -I$(ERL_TOP)/lib \
		-I$(ERL_INTERFACE)/include $(MQNC)

include $(TOPDIR)/make/c_src.mk

../priv/$(ARCH)/mqseries_port.out:	../priv/$(ARCH)/mqseries_port.o 
../priv/$(ARCH)/mqseries_port_get.out:	../priv/$(ARCH)/mqseries_port_get.o

