include ../../../../Makefile.defs

# Override the default rule for ASN.1. We want binary mode for SMPP.

%.erl %.hrl:    %.asn
	$(ERLC) +noobj -bber_bin $<

include $(TOPDIR)/make/src.mk
