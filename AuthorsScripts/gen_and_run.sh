#!/usr/bin/bash

# @(#) NMG/2WM - $Id: gen_and_run.sh,v 1.6 2023/02/12 04:55:21 user Exp $

### in case we want to cd back
CWD=`pwd`

# we are in AuthorsScripts dir, we need to go to the main dir one step up

cd ..

MD_FL=README.md
HTML_FL=README.htm
TMP_PL=tmp.pl
ERR_FL=/tmp/gen_and_run.err
FF='/cygdrive/c/Progra~1/Mozill~1/firefox.exe'

if [ ! -f $MD_FL ]
then
  echo "Cannot find $MD_FL to generate $HTML_FL from it. Exiting..."
  exit 1
fi


# HERE should point to : /cygdrive/c/users/user/Documents/GitHub/WGOLDemo
HERE=$(cygpath -w `pwd`)


[ -f $HTML_FL ] && rm -f $HTML_FL

htmldoc $MD_FL >$HTML_FL 2>$ERR_FL

# check if err file size is 0 then edit file and display in default browser

if [ ! -s $ERR_FL  -a  -f $HTML_FL ]
then
  ex - $HTML_FL <<EOF
%s/<!DOCTYPE/<!doctype/
/<BODY>/
:+1
i
<!-- auto-generated from $MD_FL using htmldoc -->
.
:wq
EOF

  cat > $TMP_PL <<EOF
#!/usr/bin/perl

use strict;
use warnings;

open(LOG, '<', "$HTML_FL") || die "Cannot open $HTML_FL for reading. Exiting...";
my @a=<LOG>;
close(LOG);
shift(@a);
foreach (@a)
  {
  s%<(\w+)%"<".lc(\$1)%ge;
  s%</(\w+)%"</".lc(\$1)%ge;
  s%^(\w+)%lc(\$1)%ge;
  s%(ALIGN|NAME|HREF)=%lc(\$1)."="%ge;
  s%(CONTENTS|CENTER|NOSHADE)%lc(\$1)%ge;
  s%(CONTENT|CHARSET|HTTP\-EQUIV)=%lc(\$1)."="%ge;
  }
push(@a, '</body>', "\n", '</html>', "\n");
open(HTML_FL, '>', "$HTML_FL") || die "Cannot open $HTML_FL for writing. Exiting...";
print HTML_FL @a;
close(HTML_FL);
EOF

  $(perl $TMP_PL);
  [ $# -eq 0 ] && $FF file://$HERE/$HTML_FL &
  rm -f $ERR_FL $TMP_PL
else
  cat $ERR_FL
fi
