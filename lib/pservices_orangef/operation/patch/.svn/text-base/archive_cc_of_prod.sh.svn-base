#!/bin/sh

function die {
  echo "$@" >&2
  exit 1
}

[ $# -eq 1 ] || die "$0 compress|uncompress"

ARCHIVE=archive_prod
TMP_FILE=tmp.tmp

case $1 in
    compress)
	FILES=$(find lib/webmin_orangef lib/webuser_orangef lib/pdist_orangef lib/pfront_orangef lib/pservices_orangef -name "*.erl" -o -name "*.hrl" -o -name "*.xml" -o -name "*.app.src" -o -name "*.csv")
	touch $TMP_FILE
	tar cf $ARCHIVE $TMP_FILE
	rm $TMP_FILE
	for i in $FILES; do
	    tar rf $ARCHIVE $i;
	done
	tar czf $ARCHIVE.tgz $ARCHIVE
	rm $ARCHIVE
	echo /tmp/$ARCHIVE.tgz created
	cp $ARCHIVE.tgz /tmp
	rm $ARCHIVE.tgz
	;;
    uncompress)
	tar xvzf $ARCHIVE.tgz
	tar xvf $ARCHIVE
	rm $ARCHIVE.tgz                                                                                                                               
	rm $ARCHIVE
	rm $TMP_FILE
	;;
    *)
	die "$0 compress|uncompress"
esac
    
