#!/bin/sh

# http://www.gnutoolbox.com/shell-script-directory/?page=detail&get_id=45&category=5
#
# sftpsync - Given a target directory on an sftp server, make sure that 
#   all new or modified files are uploaded to the remote system. Uses
#   a timestamp file ingeniously called .timestamp to keep track.

timestamp=".timestamp"
tempfile="/tmp/sftpsync.$$"
count=0

trap "/bin/rm -f $tempfile" 0 1 15      # zap tempfile on exit &sigs

if [ $# -eq 0 ] ; then
  echo "Usage: $0 user@host { remotedir }" >&2
  exit 1
fi

user="$(echo $1 | cut -d@ -f1)"
server="$(echo $1 | cut -d@ -f2)"

if [ $# -gt 1 ] ; then
  echo "cd $2" >> $tempfile
fi

if [ ! -f $timestamp ] ; then
  # no timestamp file, upload all files
  for filename in *
  do 
    if [ -f "$filename" ] ; then
      echo "put -P \"$filename\"" >> $tempfile
      count=$(( $count + 1 ))
    fi
  done
else
  for filename in $(find . -newer $timestamp -type f -print)
  do 
    echo "put -P \"$filename\"" >> $tempfile
    count=$(( $count + 1 ))
  done
fi

if [ $count -eq 0 ] ; then
  echo "$0: No files require uploading to $server" >&2
  exit 1
fi

echo "quit" >> $tempfile

echo "Synchronizing: Found $count files in local folder to upload."

if ! sftp -b $tempfile "$user@$server" ; then
  echo "Done. All files synchronized up with $server"
  touch $timestamp
fi

exit 0
