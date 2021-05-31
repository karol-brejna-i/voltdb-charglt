#!/bin/sh -x

cd
cd voltdb-charglt/jars 

kill -9 `ps -deaf | grep ChargingDemoTransactions.jar  | grep -v grep | awk '{ print $2 }'`

sleep 5 

MX=$1
CT=1

while
	[ "${CT}" -le "${MX}" ]
do

	java -jar ChargingDemoTransactions.jar `cat $HOME/.vdbhostnames`  60000000 100 1200 60 > `uname -n`${CT}.lst &
	CT=`expr $CT + 1`
done
