#!/usr/bin/bash

# @(#) NMG/2WM - $Id: chk_with_csv_ver.bash,v 1.1 2023/02/10 22:25:20 user Exp $

CVS_REPO_DIR=$HOME/WGOLDemo
GH_REPO_DIR=$(cygpath $USERPROFILE/Documents/GitHub/WGOLDemo)

TMP=/tmp/diffs

find $GH_REPO_DIR -type f >$TMP

ex - $TMP <<-!
g/CVS/d
g/git/d
:wq
!

cat $TMP  | while read line
do
  T=$(echo $line | sed -e "s%$GH_REPO_DIR%$CVS_REPO_DIR%")
  if [ ! -f $T ]
  then
    echo "$line is not in $CVS_REPO_DIR"
    continue
  fi
  D=$(diff $line $T)
  if [ ! -z "$D" ]
  then
    echo "Diffing $line and $T:"
    echo "$D"
  fi
done
