#!/bin/bash

if test $# -ne 2
then echo "Use: \$1 YYYY \$2 MM";exit 1
fi

Year=$1
Month=$2

Stats_Folder="${HOME}/orangef/of_prod/cellicium/possum/run/stats"
Charts_Folder="${HOME}/orangef/of_prod/cellicium/possum/lib/pservices_orangef/operation/monthly_report/OrangeFrance/daily_licence/charts_${Year}_${Month}"
Exploit_Folder="${HOME}/orangef/of_prod/cellicium/possum/lib/pservices_orangef/operation/monthly_report"

echo "Uncompress the archive..."
cd $Stats_Folder
tar zxvf /home/clcm/orangef/of_prod/cellicium/possum/lib/pservices_orangef/operation/monthly_report/OrangeFrance/daily_licence/backup/stats_${Year}_${Month}.tgz

echo "Generate the statistics..."
cd $Exploit_Folder
erlc rapport.erl
erl -pa ../../../posutils/ebin/ -pa ./ \
    -run rapport start $Year $Month \
    -s erlang halt

echo "Create a new folder on the public folder..."
rm -r $Charts_Folder
mkdir $Charts_Folder
chmod 0777 $Charts_Folder

echo "Copy the files on the new folder..."
cd ${Exploit_Folder}
cp *${Year}-${Month}* ${Charts_Folder}
cd ${Stats_Folder}/public/result-${Year}-${Month}
cp avg_session.txt avg_session.png daytraffic.png ${Charts_Folder}
cd ${Stats_Folder}
cp sessions_gene-1hour.csv sessions-1day.csv Resp_time-1day.csv Qosmon-1day.csv New_USER-1day.csv interfaces-1day.csv ${Charts_Folder}
cd ${Charts_Folder}
rm -f all_1day*
rm -f all_1hour*


