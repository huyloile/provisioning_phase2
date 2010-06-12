#!/bin/sh

Code=1234;
read BODY

MSISDN=""
ORDRE=""
CODE=""
IMSI=""
VERSION=""
ORIGINE=""
##echo ${BODY%%[=]*}
x=`expr "$BODY" : '.*MSISDN=\([0-9]*\)'` && MSISDN="$x"
y=`expr "$BODY" : '.*ORDRE=\([0-Z]*\)'` && ORDRE="$y"
z=`expr "$BODY" : '.*CODE_CONFIDENTIEL=\([0-9]*\)'` && CODE="$z"
t=`expr "$BODY" : '.*IMSI=\([0-9]*\)'` && IMSI="$t"
v=`expr "$BODY" : '.*VERSION=\([0-9]*\)'` && VERSION="$v"


function affiche {
    case $ORDRE in
	"RECHARGE")
	    check_code;;
	*)
	    ## erreur technique
	    echo "STATUT=20;MSISDN=$MSISDN;IMSI=$IMSI";;
    esac
}

function check_code {
    case $CODE in
	1234)
	    recharge;;
	*) ## Pin erroné
	    echo "STATUT=01;MSISDN=$MSISDN;IMSI=$IMSI";;
    esac
}

function recharge {
    case $MSISDN in
	*001)
	    echo "STATUT=00;MSISDN=$MSISDN;IMSI=$IMSI;SOLDE=15000;DLV=1125595025";;
	*002)
	    ## postpayé
	    echo "STATUT=21;MSISDN=$MSISDN;IMSI=$IMSI";;
	*003)
	    ## pin erroné 3 fois
	    echo "STATUT=02;MSISDN=$MSISDN;IMSI=$IMSI";;	
	*)
	    echo "STATUT=0000;MSISDN=$MSISDN;IMSI=$IMSI;SOLDE=20000;DLV=1125595025";;
	esac
}

cat <<EOF
Content-Type: text/xml

`affiche`
EOF
