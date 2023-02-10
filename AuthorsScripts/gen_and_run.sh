#!/usr/bin/bash

# @(#) NMG/2WM - $Id: gen_and_run.sh,v 1.2 2023/02/10 22:39:34 user Exp $


### in case we want to cd back...
CWD=`pwd`

# we are in AuthorsScripts dir, we need to go to the main dir one step up

cd ..

IFL=README.md
OFL=README.htm
TMP_PL=tmp.pl
ERR_FL=/tmp/gen_and_run.err
FF='/cygdrive/c/Progra~1/Mozill~1/firefox.exe'

if [ ! -f $IFL ]
then
  echo "Cannot find $IFL to generate $OFL from it. Exiting..."
  exit 1
fi

# HERE should point to : /cygdrive/c/users/user/Documents/GitHub/WGOLDemo
HERE=$(cygpath -w `pwd`)


[ -f $OFL ] && rm -f $OFL

htmldoc $IFL >$OFL 2>$ERR_FL

# check if err file size is 0 then edit file and display in default browser

if [ ! -s $ERR_FL  -a  -f $OFL ]
then
  ex - $OFL <<EOF
%s/<!DOCTYPE/<!doctype/
/<BODY>/
:+1
i
<!-- auto-generated from $IFL using htmldoc -->
.
:wq
EOF

  cat > $TMP_PL <<EOF
#!/usr/bin/perl

use strict;
use warnings;

open(LOG, '<', "$OFL") || die "Cannot open $OFL for reading. Exiting...";
my @a=<LOG>;
close(LOG);
shift(@a);
foreach (@a)
  {
  s%<(\w+)%"<".lc(\$1)%ge;
  s%</(\w+)%"</".lc(\$1)%ge;
  }
push(@a, '</body>', "\n", '</html>', "\n");
open(LOG, '>', "$OFL") || die "Cannot open $OFL for writing. Exiting...";
print LOG @a;
close(LOG);
EOF

  $(perl $TMP_PL);

  $FF file://$HERE/$OFL &
  rm -f $ERR_FL $TMP_PL
else
  cat $ERR_FL
fi
