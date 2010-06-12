#!/bin/bash

LOGFILE=/cellcube/install/install_patch_`/bin/date '+%Y%m%d_%H%M%S'`.log
echo Traces will be generated in $LOGFILE
./install_dev_specifiques.sh $1 $LOGFILE  2>&1 | tee $LOGFILE

