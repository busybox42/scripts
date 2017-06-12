#/bin/bash

DIR=`pwd`
UPDATES=`checkupdates|wc -l`
KUP=`checkupdates |grep linux`

echo $UPDATES > $DIR/bin/chkupdates.state
echo $KUP > $DIR/bin/kup.state
