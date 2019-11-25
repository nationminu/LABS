#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

unset JAVA_OPTS

for count in 1 2 3 4 5; do
    echo "Thread Dump : $count"
    for i in `ps -ef | grep java | grep "\[SERVER_NAME=${SERVER_NAME}\]" | awk '{print $2}'`
    do
        date
    	echo "+kill -3 $i"
    	kill -3 $i
    done
    echo "done"
    echo "sleep 3 sec"
    sleep 3
done
	
