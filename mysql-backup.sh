#!/bin/sh

# mysql-backup - Dump all MySQL databases

if [ $# -eq 0 ] ; then
  echo "Usage: ./$(basename $0) [options] user@host backup_dir\n" >&2
  echo "Options:" >&2
  echo "         -s, --ssh" >&2
  echo "             Use FTP over SSH (sftp://)\n" >&2
  echo "         -p, --password password" >&2
  echo "             Set user password\n" >&2
  exit 1
fi

ARGS=$(getopt -l 'password' -o 'p:' -- "$@" 2> /dev/null)
eval set -- "$ARGS"

user=
host=
password=

while true
do
    case "$1" in
    --password | -p)
        password="--password=\"$2\""
        shift;;
    --)
        shift
        break
        ;;
    esac
    shift
done

user="$(echo $1 | cut -d@ -f1)"
host="$(echo $1 | cut -d@ -f2)"

echo mysql -h $host -u $user $password

mysql -h $host -u $user $password -e "show databases"

#mysql -u root --password="2nmf9bI4" -e "show databases" | grep -v Database | grep -v "_schema" | grep -v "mysql"