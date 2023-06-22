#!/bin/sh

BNAME=$1

if
	[ "$BNAME" = "" ]
then
	echo Usage: nohup sh $0 filename \& 
	exit 1
fi

sh -x runlargebenchmark.sh 190 2000 5  4000000  > ${BNAME}_oltp.lst
sleep 60
sh -x runlargekvbenchmark.sh 190 2000 5 4000000 100 50  > ${BNAME}_kv.lst
