#!/bin/sh

# repertoire final ou sont stock�s les resultats
Ref="stats"
# repertoire ou sont stock�s les r�sultats
Result="/home/dk/dev/orangef/branches/of_prod/../../../orangef/branches/of_prod/../prod_build/possum/lib/webuser_orangef/priv/orangef/htdocs/secure/$Ref/public"

cd $Result
Res=`ls -1d charts_*`
Now=`date --date 'today' +%D\ %H:%M`

HTML="";
for i in $Res;
	do
	HTML="$HTML<a href=/secure/$Ref/public/$i/stats.html>$i</a><br>"
	done;

 echo ""
 echo ""
 echo "</body><TITLE>Statistic USSD</TITLE>"
 echo " Generated $Now<br>"
 echo "<h2>Lists of the available periods</h2>"
 echo $HTML
 echo "<br><body>"
	 
	
