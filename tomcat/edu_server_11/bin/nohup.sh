#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

unset JAVA_OPTS
 
tail -f -n 0 ${LOG_HOME}/nohup/${SERVER_NAME}.out
