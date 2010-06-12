#!/bin/sh

FOLDER_PROD=~/cellicium_prod/possum

cd ../../../../

FILES=$(find lib/webmin_orangef lib/webuser_orangef lib/pdist_orangef lib/pfront_orangef lib/pservices_orangef -name "*.erl" -o -name "*.hrl" -o -name "*.xml" -o -name "*.app.src" -o -name "*.csv" | grep -v "test" | grep -v "pservices_orangef/operation" | grep -v "doc")

EXTRACTOR="s;Files \([^ ]\+\) and \([^ ]\+\) differ;\1;p"

for i in $FILES; do
    diff --brief $i $FOLDER_PROD/$i | sed -ne "$EXTRACTOR"
done

    
