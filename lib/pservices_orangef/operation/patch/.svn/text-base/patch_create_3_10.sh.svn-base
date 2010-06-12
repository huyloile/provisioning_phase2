#!/bin/bash

PATCH_PREFIX=`grep PATCH_PREFIX cellcube.orangef.txt | sed -e "s/PATCH_PREFIX: //"`

PATTERN=" \
-not -type d \
-and -not -path '*CVS*' \
-and -not -path '*chat.xml' \
-and -not -path '*_orangef/test/*' \
-and '(' \
    -path '*_orangef/ebin/*.app' \
-or -path '*_orangef/ebin/*.beam' \
-or -path '*_orangef/src/*.erl' \
-or -path '*_orangef/src/*.src' \
-or -path '*_orangef/include/*.hrl' \
-or -path '*_orangef/xml_src/*.csv' \
-or -path '*_orangef/*Makefile' \
-or -path '*_orangef/priv/*.xml' \
-or -path '*_orangef/priv/*.error' \
-or -path '*_orangef/priv/*.mapping' \
-or -path '*run/xml/mcel/*.xml' \
-or -path '*annauire.csv' \
-or -path '*tableratio.csv' \
-or -path '*oto_last.csv' \
 ')'"

OUTPUT_FILE=/tmp/${PATCH_PREFIX}_`date +%Y-%m-%d_%H-%M`.tgz

function display_result()
{
    if [ $1 = 0 ]; then
	echo "OK : $2"
    else 
	echo "ERROR : $2" 
	exit 1
    fi
}

function cvs_update ()
{
    svn update
    display_result $? "SVN update $1_orangef"
}

function make_depend_all ()
{ 
    make depend all
    display_result $? "Make $1_orangef" 
}

cd ../../../..



for action in cvs_update make_depend_all; do
    for module in pservices pdist pfront webmin webuser; do
	pushd lib/${module}_orangef
	${action} ${module}
	popd
    done
done

echo "Create version helper"
pushd lib/pservices_orangef/include
svn up | cut -f3 -d\ | sed "s/\.//g" | awk '{printf("-define(VERSION,\"%d\").\n", $1)}' > version.hrl
cd ../src
make 
popd

echo "start Cellcube and push Enter"
read

echo "Generating XML files (SCE) from CSV files..."
make -C lib/pservices_orangef/xml_src xml
display_result $? "Generating Xml file from CSV files"

echo "Building the archive..."
tar zcvf $OUTPUT_FILE $(eval "find $PATTERN")
display_result $? "$OUTPUT_FILE"

