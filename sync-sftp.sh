#!/bin/sh

# sync-sftp - Sync files from current directory to SFTP using lftp

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [options] user@host [remotedir]\n" >&2
  echo "Options:" >&2
  echo "         -p, --password password" >&2
  echo "             Set user password\n" >&2
  echo "         -e, --exclude local/path" >&2
  echo "              Exclude local path, can be used multiple times" >&2
  exit 1
fi

ARGS=$(getopt -l 'password,exclude' -o 'p:,e:' -- "$@" 2> /dev/null)
eval set -- "$ARGS"

sourcedir=`pwd`
remotedir="/"
exclude=""

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

lftp -c "open -u ${user},${password} sftp://${host};
lcd $sourcedir;
cd $remotedir;
mirror --reverse \
       --delete \
       --verbose \
       --ignore-time \
       $exclude"

exit 0
