#!/bin/sh

#Script to extract the statistics used in the monthly operation report

#If no arguments (crontab), extract the statistics of the previous month
#Otherwise, use the two arguments of the command line
if test $# -eq 0
then
    Next_Year=`date +%Y`
    Next_Month=`date +%m`
    Year=$Next_Year
    Previous_Year=$Year
    case $Next_Month in
	01) Month=12;Previous_Month=11;Year=$(($Next_Year-1));Previous_Year=$Year;;
	02) Month=01;Previous_Month=12;Previous_Year=$(($Year-1));;
	03) Month=02;Previous_Month=01;;
	04) Month=03;Previous_Month=02;;
	05) Month=04;Previous_Month=03;;
	06) Month=05;Previous_Month=04;;
	07) Month=06;Previous_Month=05;;
	08) Month=07;Previous_Month=06;;
	09) Month=08;Previous_Month=07;;
	10) Month=09;Previous_Month=08;;
	11) Month=10;Previous_Month=09;;
	12) Month=11;Previous_Month=10;;
	*) echo "Month is not valid"; exit 1;;
    esac 
else
if test $# -eq 2
then
    Year=$1
    Month=$2
    Next_Year=$Year
    Previous_Year=$Year
    case $Month in
	01) Next_Month=02;Previous_Month=12;Previous_Year=$(($Year-1));;
	02) Next_Month=03;Previous_Month=01;;
	03) Next_Month=04;Previous_Month=02;;
	04) Next_Month=05;Previous_Month=03;;
	05) Next_Month=06;Previous_Month=04;;
	06) Next_Month=07;Previous_Month=05;;
	07) Next_Month=08;Previous_Month=06;;
	08) Next_Month=09;Previous_Month=07;;
	09) Next_Month=10;Previous_Month=08;;
	10) Next_Month=11;Previous_Month=09;;
	11) Next_Month=12;Previous_Month=10;;
	12) Next_Month=01;Previous_Month=11;Next_Year=$(($Year+1));;
	*) echo "Month is not valid"; exit 1;;
    esac 
else
    echo "Use: \$0 YYYY \$1 MM"
    exit 1
fi
fi

Dir=/opt/cellcube/run/stats/
cd $Dir
echo $PWD $Year $Month

tar cvfz /mnt/backup/stats/stats_${Year}_${Month}.tgz \
    all_1day_${Previous_Year}-${Previous_Month}* \
    all_1hour_${Previous_Year}-${Previous_Month}* \
    all_1day_${Year}-${Month}* \
    all_1hour_${Year}-${Month}* \
    all_1day_${Next_Year}-${Next_Month}* \
    all_1hour_${Next_Year}-${Next_Month}* \
    interfaces-1day.csv sessions-1day.csv \
    sessions_gene-1hour.csv Qosmon-1day.csv \
    Resp_time-1day.csv \
    New_USER-1day.csv \
    public/result-${Year}-${Month}/* \
    private/result-${Year}-${Month}/* 
 
