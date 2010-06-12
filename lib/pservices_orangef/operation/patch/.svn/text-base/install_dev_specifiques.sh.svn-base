#!/bin/bash
LOGFILE=$2

function find_errors() {
Error=$(grep '\(Permission denied\|No such\)' $1)
if [ -n "$Error" ] ; then
echo -e Installation on $2 \\033[0\;30m[\\033[m \\033[0\;31mWARNING\\033[m \\033[0\;30m]\\033[m
echo "L'expression suivante est apparues dans le fichier $1 :"
echo $Error
echo
else
   echo -e Installation on $2 \\033[0\;30m[\\033[m \\033[0\;32mOK\\033[m \\033[0\;30m]\\033[m
echo
fi


}
Files="lib/*_orangef run/xml/mcel"
Nodes='opmk9cc1 opmk9io0 opmk9io1 opmk9io2 opmk9io3 opmk9sv0 opmk9sv1 opmk9sv2 opmk9sv3 opmk9sv4 opmk9sv5 opmk9sv6'

Node=`hostname -s`
TYPE="sudo /usr/bin/exec_root.sh"

case $Node in
  opmk9cc0) 
	echo "Will make a backup"
	echo "Press enter to continue"
	read R
        if [ -d /opt/cellcube/lib/pservices_orangef ]
                then
                echo "Making backup..."
                nice tar zcvf ${1}.backup $Files;
                else
                echo "Warning : Backup impossible, specific developments not fou
nd "
        fi
	echo "Will copy patch on all nodes..."
	echo "Press enter to continue"
	read R
	echo "Copying the patch on all nodes..."
        for i in $Nodes; do scp -p $1 clcm@$i-adm:$1; done;;
    *)
	echo "";;
esac

echo "######## UPGRADE NODE $Node##########"
echo "Will decompress the patch..."
echo "Press enter to continue"
read R
echo "Decompressing the patch..."
cd /opt/cellcube/
ssh $Node-adm "${TYPE}" tar zxvf $1 --directory /opt/cellcube/

case $Node in
  opmk9cc0) 
	echo $2
	find_errors $LOGFILE $Node
	for i in $Nodes; do ssh clcm@$i-adm /opt/cellcube/install_dev_specifiques.sh $1
        find_errors $LOGFILE $i;
 done

echo COPY XML GENERIC
apply_all_nodes 'cp -p /opt/cellcube/lib/pservices_orangef/priv/data/xml_generic/* /opt/cellcube/conf/xml_generic';;
    *)
	echo "";;
esac
