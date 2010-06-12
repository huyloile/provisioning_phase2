include ../../../../Makefile.defs

DOCS=		man_orangef_sw
ASPELL_OPTS=	| aspell --master=french -H --encoding=utf-8 -l \


include $(TOPDIR)/make/docbook.mk

SUBDIRS=	annuaire provisioning
include $(TOPDIR)/make/subdirs_inc.mk


## TODO Add test specific OF
# TS_CELLCUBE_INC =	tr/tree_test.pdf \
# 			tr/tree_navigation.pdf \
# 			tr/tree_contents.pdf \
# 			tr/tree_taxation.pdf \
# 			tr/tree_language.pdf \
# 			tr/tree_navigation2.pdf \
# 			tr/tree_unicode.pdf

# pdf/ts_cellcube_sw.pdf:       $(TS_CELLCUBE_INC)

######################################################################

params_cc.xml:	../../../lib/*/ebin/*_app.beam
	erl	-pa ../../../lib/*/ebin		\
		-noshell			\
		-s oma_doc dump_docbook		\
			pfront_orangef pdist_orangef pservices_orangef \
			webmin_orangef webuser_orangef 	\
		-s erlang halt > $@.log  ||  (cat $@.log; exit 1)
	mv $@.log $@

clean::
	rm -f params_cc.xml


tr/test_%.xml:	../lib/pservices_orangef/doc/test_%.xml
	cp $^ $@

tr/tree_%.pdf: tr/tree_%.ps
	ps2pdf -SPAPERSIZE=a4 $^ $@

tr/tree_%.ps:	../lib/pservices_orangef/doc/tree_%.ps
	cp $^ $@
