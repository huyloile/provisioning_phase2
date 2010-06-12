#!/bin/bash

#This script generates on the standard output and optionally in a file
#the counters specified by the user

##########VARIABLES TO BE INITIALIZED##########

COUNTERS_NUIT_SMS_KDO_INTERNAL="failure,routeur_mnesia 
                       internal 
                       send_message_failed 
                       license_info.*,msg 
                       license.*rate_exceeded.*,msg 
                       count,ocf_rdp,response_ko 
                       session_end_err"

COUNTERS_NUIT_SMS_KDO_EXTERNAL="failure,routeur_mnesia 
                       send_message_failed 
                       license_info.*,msg 
                       license.*rate_exceeded.*,msg 
                       count,ocf_rdp,response_ko "

COUNTERS_SMS="count.*svc_recharge_moi.*send_sms_orange
              count.*svc_recharge_moi.*send_sms_cvf
              count.*svc_call_me_back.*send_sms_orange
              count.*svc_call_me_back.*send_sms_cvf"

COUNTERS=$COUNTERS_NUIT_SMS_KDO_INTERNAL

EXPRESSIONS="all_1hour_2006-10-31*
             all_1hour_2006-11-01*"

###########################################

OUTPUT_FILE=""
if test $# -eq 1; then
    OUTPUT_FILE="/tmp/$1"
    if test -e $OUTPUT_FILE; then
	rm $OUTPUT_FILE
    fi
    touch $OUTPUT_FILE
fi

COUNTERS_LIST="("
pre=""
for i in $COUNTERS; do
  COUNTERS_LIST="${COUNTERS_LIST}${pre}$i)"
  pre="|("
done

FOLDER="install-current/cellicium/possum/run/stats"
cd ~/$FOLDER

if test $# -eq 1; then
    for expression in $EXPRESSIONS; do
	egrep -H $COUNTERS_LIST $expression | grep -v ";0" >> $OUTPUT_FILE
    done
    cat $OUTPUT_FILE
else
    for expression in $EXPRESSIONS; do
	egrep -H $COUNTERS_LIST $expression | grep -v ";0"
    done
fi

if test $# -eq 1; then
    echo "/tmp/$1 generated"
fi



