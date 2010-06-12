#!/bin/bash

if test $# -eq 2
then
    Year=$1
    Month=$2
    Next_Year=$Year
    Next_Month=$(( ($Month % 12) + 1 ))
    [ $Next_Month -eq 1 ] && Next_Year=$(( $Year + 1 ))
else
    echo "Use: \$0 YYYY \$1 MM"
    exit 1
fi

Gforge_Address=192.168.254.201

Date_Min=`date -d $Month/01/$Year +%s`
Date_Max=`date -d $Next_Month/01/$Next_Year +%s`

Output_File="/tmp/gforge_mep.csv"

ssh clcm@$Gforge_Address "psql -U gforge gforge_453 -c \"select p2.summary as Projet,p1.summary as Tache,p1.start_date as Date from project_task_vw p1 left join project_task_vw p2 on (p1.parent_id=p2.project_task_id) where p1.start_date>$Date_Min and p1.summary ilike '%MEP %' and p1.start_date < $Date_Max\"" > $Output_File







