#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

# ------------------------------------
PID=`ps -ef | grep java |  grep "\[SERVER_NAME=${SERVER_NAME}\]" | awk '{print $2}'`

if [ e$PID == "e" ]
then
    printf "\033[0;31m%-10s\033[0m\n" "Opps! Tomcat(${SERVER_NAME}) is not RUNNING." 
    exit;
fi

unset JAVA_OPTS
export JAVA_OPTS="-Dshutdown.bind.port=${SHUTDOWN_PORT}"

${CATALINA_HOME}/bin/catalina.sh stop 
