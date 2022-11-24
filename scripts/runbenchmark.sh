
ST=$1
MX=$2
INC=$3
USERCOUNT=5000000

if 	
	[ "$MX" = "" -o "$ST" = "" -o "$INC" = 0 ]
then
	echo Usage: $0 start_tps max_tps increment

	exit 1
fi

cd
mkdir logs 2> /dev/null

cd voltdb-charglt/jars 

# silently kill off any copy that is currently running...
kill -9 `ps -deaf | grep ChargingDemoTransactions.jar  | grep -v grep | awk '{ print $2 }'` 2> /dev/null

sleep 5 

CT=${ST}
DT=`date '+%Y%m%d_%H%M'`

while
	[ "${CT}" -le "${MX}" ]
do

	echo "Starting a 20 minute run at ${CT} Transactions Per Second"
	java ${JVMOPTS}  -jar ChargingDemoTransactions.jar `cat $HOME/.vdbhostnames`  ${USERCOUNT} ${CT} 1200 60 | tee -a $HOME/logs/${DT}_charging_`uname -n`_${CT}.lst 
	CT=`expr $CT + ${INC}`
done

wait 

exit 0
