#!/bin/sh

# sync-ftp - Sync files from current directory to FTP/SFTP using lftp

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [options] user@host [remotedir]\n" >&2
  echo "Options:" >&2
  echo "         -s, --ssh" >&2
  echo "             Use FTP over SSH (sftp://)\n" >&2
  echo "         -p, --password password" >&2
  echo "             Set user password\n" >&2
  echo "         -e, --exclude local/path" >&2
  echo "              Exclude local path, can be used multiple times" >&2
  exit 1
fi

ARGS=$(getopt -l 'password,exclude,ssh' -o 'p:,e:,s' -- "$@" 2> /dev/null)
eval set -- "$ARGS"

sourcedir=`pwd`
remotedir="/"
exclude=""

ssh=0
user=
host=
password=

while true
do
    case "$1" in
    --password | -p)
        password="$2"
        shift;;
    --exclude | -e)
        exclude="$exclude --exclude $2"
        shift;;
    --ssh | -s)
        ssh=1
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

if [ ! -z "$2" ]; then
    remotedir=$2
fi

if [ "$ssh" -eq 1 ]; then
  cmd="open -u ${user},${password} sftp://${host};"
else
  cmd="set ftp:list-options -a;
       open ftp://${user}:${password}@${host};"
fi

lftp -c "$cmd
lcd $sourcedir;
cd $remotedir;
mirror --reverse \
       --delete \
       --verbose \
       --ignore-time \
       $exclude"

exit 0
