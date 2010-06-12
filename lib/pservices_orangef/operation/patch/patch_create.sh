#!/bin/bash

if [[ $# -ne 1 || "${1%.txt}" = "$1" ]]; then
  echo "Use: \$0 File, with the txt extension, containing the list of files to be patched " >&2
  exit 1
fi

FILE="${1%.txt}"

cd ../../../../

REPERTOIRE_OPE="lib/pservices_orangef/operation/patch"

cat $REPERTOIRE_OPE/$FILE.txt | xargs tar zcvf $FILE.tgz
