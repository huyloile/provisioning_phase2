#!/bin/bash

if test $# -ne 1
then echo "Use: \$1 FILE";exit 1
fi

FILE=$1

eval `cat $FILE | sort | uniq | grep -v test | grep -v doc | grep -v webuser_orangef | grep -v webmin_orangef | grep -v pdist_orangef.app.src > tmp.txt;cp tmp.txt $FILE; rm tmp.txt`
