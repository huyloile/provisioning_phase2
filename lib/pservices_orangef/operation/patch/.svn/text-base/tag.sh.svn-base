#!/bin/bash

if [ "x"$1 = "xPREPROD_OF" -o "x"$1 = "xPROD_OF" ]; then
    TAG=$1
else
    echo 1>&2 "Usage:   $0 <TAG>"
    echo 1>&2 "Example: $0 PROD_OF"
    echo 1>&2 "Example: $0 PREPROD_OF"
    exit 1
fi

cd ../../../..

for i in pservices pdist pfront webmin webuser; do
    pushd lib/${i}_orangef
    cvs update -A
    cvs tag -F $TAG
    popd
done
