DEV_HOME=$(HOME)/dev
home_dir=$(shell pwd)
services_tools_dir=$(DEV_HOME)/cellcube/service-tools
erl_top=/usr/lib/erlang

# target of build, no trailing '/'
build_dir=$(home_dir)/../build_provisioning_ph2
PRODUCT=possum
customer=orangef
product_dir=$(build_dir)/$(PRODUCT)


# dependencies on development environment and product
dev_env=$(services_tools_dir)/archives/3.11/dvpt-3.11.4-R11-RH9-22815.tar
product_env= $(services_tools_dir)/archives/3.11/cellcube-3.11.4.1-R11-RH9-22815.tgz
product_version=3.11
xml_folder=acceptance
include $(services_tools_dir)/make/services.mk

simple_test-%:
	$(MAKE) $(MAKE_OPTIONS) -C $(product_dir)/lib/pservices_$(customer)/test simple_test-$*


