#!/bin/sh -x

MX=$1

if 	
	[ "$MX" == "" ]
then
	echo Usage: $0 max_tps
	exit 1
fi

cd
cd voltdb-charglt/jars 

# silently kill off any copy that is currently running...
kill -9 `ps -deaf | grep ChargingDemoTransactions.jar  | grep -v grep | awk '{ print $2 }'` 2> /dev/null

sleep 5 

CT=1
DT=`date '+%Y%m%d_%H%M'`

while
	[ "${CT}" -le "${MX}" ]
do

	echo "Starting a 20 minute run at ${CT} Transactions Per Second"
	java -jar ChargingDemoTransactions.jar `cat $HOME/.vdbhostnames`  60000000 ${CT} 1200 60 > ${DT}_`uname -n`_${CT}.lst &
	CT=`expr $CT + 1`
done

wait 
