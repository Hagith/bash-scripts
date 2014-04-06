#!/bin/bash

if [[ '' == $1 || '' == $2 ]]; then
    echo "Provide domain name and URL"
    exit 1
fi

wget \
    --recursive \
    --no-clobber \
    --page-requisites \
    --html-extension \
    --convert-links \
    --restrict-file-names=windows \
    --domains $1 \
    --no-parent \
    $2

