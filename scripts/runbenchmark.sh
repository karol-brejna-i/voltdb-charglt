#!/bin/sh -x

cd
cd voltdb-charglt/jars 

# silently kill off any copy that is currently running...
kill -9 `ps -deaf | grep ChargingDemoTransactions.jar  | grep -v grep | awk '{ print $2 }'` 2> /dev/null

sleep 5 

MX=$1
CT=1
DT=`date '+%Y%m%d_%H%M'`

while
	[ "${CT}" -le "${MX}" ]
do

	java -jar ChargingDemoTransactions.jar `cat $HOME/.vdbhostnames`  60000000 100 1200 60 > ${DT}_`uname -n`_${CT}.lst &
	CT=`expr $CT + 1`
done

wait 
