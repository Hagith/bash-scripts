#!/bin/bash

mysql -u root -p $1 -e "show tables" | grep -v Tables_in | grep -v "+" | gawk '{print "drop table " $1 ";"}' | mysql -u root -p $1
