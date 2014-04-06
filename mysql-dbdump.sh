#!/bin/bash

if [[ '' == $1 ]]; then
    echo "Provide database name"
    exit 1
fi

OUT=$2
NAME=$3

if [[ $OUT == '' ]]; then
    OUT=~/backup
fi

if [[ $NAME == '' ]]; then
    NAME=${1}_`date +"%Y%m%d-%H%M"`.sql
fi

OUT=${OUT%/}

if [[ ! -d ${OUT} ]]; then
    mkdir ${OUT}
fi

mysqldump -u root -p --skip-add-locks -R ${1} | sed -e 's/DEFINER=[^*]*\*/\*/' > ${OUT}/${NAME}
