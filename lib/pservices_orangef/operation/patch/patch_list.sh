#!/bin/bash

##########VARIABLES TO INITIALIZE##########

# List of files not to be included in the patch, separated by blanks
EXCLUDED_FILES="lib/pservices_orangef/doc/Makefile"

###########################################

FOLDER="cellicium/possum"

cd ../../../../

SEPARATOR=""
for i in $EXCLUDED_FILES; do
  FILTER_EXCLUDED_FILES="${FILTER_EXCLUDED_FILES}${SEPARATOR}${i}"
  SEPARATOR="|"
done

EXTRACTOR="s;RCS file: /home/cvs/cvsroot/\+$FOLDER/\+\([^ ]\+\),v;\1;p"

cvs diff 2>&1 | grep -v "cvs server" | grep "RCS file" | egrep -v "$FILTER_EXCLUDED_FILES" | sed -ne "$EXTRACTOR"
