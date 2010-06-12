#!/bin/bash

date=`date +%Y%m%d`

FILE1="/var/www/html/cvsaudit/cellcube/log-up2date-custom-orangef-online.txt"
FILE1bis="/var/www/html/cvsaudit/cellcube/log-up2date-custom-orangef-run.txt"
FILE2="/tmp/cvs_audit.txt"
FILE2bis="/tmp/cvs_audit_log.txt"
FILE3="/tmp/cvs_audit_summary_${date}.txt"

scp -q clcm@192.168.8.202:$FILE1 $FILE2
scp -q clcm@192.168.8.202:$FILE1bis $FILE2bis

EXTRACTOR="s;make\[3\]: \*\*\* \[\(.\+\)\] Error 1;\1;p" 

cat $FILE2 | sed -ne "$EXTRACTOR" > $FILE3

more $FILE3

