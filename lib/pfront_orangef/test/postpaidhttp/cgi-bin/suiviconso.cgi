#!/bin/sh

read HEAD

MSISDN=`echo "+33${HTTP_USER_IMSI:6:10}"`
IMSI=${HTTP_USER_IMSI}

case $MSISDN in
    *001)
	  XMLPAGE="#menu_gp";;
    *002)
	  XMLPAGE="#menu_pro";;
    *)
	  XMLPAGE="#menu_gp";;
esac


cat <<EOF
Content-Type: text/xml

<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE pages SYSTEM "cellflash.dtd">

<pages descr="suiviconso">
  <page>
    <redirect src="erl://svc_postpaid:store_msisdn?$MSISDN&#conso_gp"/>
  </page>

  <page tag="conso_gp" descr="Description forfait" backtext="notext" 
	menutext="notext">
    Suivo conso postpaid<br/>
    IMSI: $IMSI<br/>
    MSISDN: $MSISDN<br/>
    <a href="#consoplus">suivi conso+</a><br/>
    *<a href="file:/orangef/postpaid.xml$XMLPAGE" key="00">menu ($XMLPAGE)</a>*
  </page>
  <page tag="consoplus" descr="Description option" backtext="notext" 
	menutext="notext">
    <nbblock>Solde forfait 30 SMS/10 MMS: 10 SMS ou 3 MMS<br/></nbblock>
    <a href="#conso">suivi conso</a>
  </page>
</pages>
EOF
