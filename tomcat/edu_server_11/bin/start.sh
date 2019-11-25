#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

# ------------------------------------
PID=`ps -ef | grep java | grep "\[SERVER_NAME=${SERVER_NAME}\]" | awk '{print $2}'` 
   
if [ e$PID != "e" ]
then
    printf "\033[0;31m%-10s\033[0m\n" "Oops! Tomcat(${SERVER_NAME}:${PID}) is already RUNNING" 
    printf "\033[0;31m%-10s\033[0m\n" "Listen Port : ${HTTP_PORT} ${HTTPS_PORT} ${AJP_PORT} ${SHUTDOWN_PORT} ${MGT_PORT} ${JMX_PORT}" 
    exit; 
fi
# ------------------------------------ 

if [ ! -d "${LOG_HOME}/gclog" ];
then
    mkdir -p ${LOG_HOME}/gclog
fi
if [ ! -d "${LOG_HOME}/nohup" ];
then
    mkdir -p ${LOG_HOME}/nohup
fi

mv ${LOG_HOME}/gclog/${SERVER_NAME}_gc.log ${LOG_HOME}/gclog/${SERVER_NAME}_gc.log.${DATE}
mv ${LOG_HOME}/nohup/${SERVER_NAME}.out ${LOG_HOME}/nohup/${SERVER_NAME}.out.${DATE}

nohup ${CATALINA_HOME}/bin/catalina.sh run >> ${LOG_HOME}/nohup/${SERVER_NAME}.out 2>&1 & 
