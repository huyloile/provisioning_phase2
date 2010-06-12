#!/bin/sh

## VARIBLES ##
SPLIT=10000
DO_DIR=./
DIR=./
###############

Files=`ls | grep USSD`
echo "Files found : $Files"

## traiter tous les fichiers arriver depuis la dernière execution

for i in $Files ;
  do 
  ##echo $i
  nice xsltproc --nonet rdp.xsl $i >> $DO_DIR/tmp_delete.txt;
  ##mv $i $DO_DIR
done

## decoupage du fichiers en tranche de 10.000.
## merge fichgier en cours avec tmp_delete
## sort et re-split.
cd $DO_DIR
Split_Files=`ls | grep delete_imsi`
case $Split_Files in
    delete*)
	#echo "Slit file" $Split_Files
	cat $Split_Files >> tmp_delete.txt ;;
    *)
	echo "nothing to do"
esac
##
Split_Files=`ls | grep tmp_delete`
case $Split_Files in
    tmp*)
	sort tmp_delete.txt > delete.txt;
	rm tmp_delete.txt;
         ## decoupage du fichiers en tranche de 10.000.
	split -l 10000 delete.txt delete_imsi.
	rm delete.txt;;
    *)
	echo "no delete found"
esac

### /home/cft/ocf/do/delete_imsi.*
### backup 15 jour de fichiers de suppresion
