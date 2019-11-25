#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

# ------------------------------------
PID=`ps -ef | grep java | grep "\[SERVER_NAME=${SERVER_NAME}\]" | awk '{print $2}'`

if [ e$PID != "e" ]
then
    printf "\033[0;31m%-10s\033[0m\n" "Oops! JBoss(${SERVER_NAME}:${PID}) is already RUNNING"
    exit;
fi
# ------------------------------------

UNAME=`id -u -n`
if [ e$UNAME != "e$JBOSS_USER" ]
then
    printf "\033[0;31m%-10s\033[0m\n" "Opps! you are logged in as \"${UNAME}\" now, Run script as \"${JBOSS_USER}\""
    exit;
fi

if [ ! -d "${JBOSS_LOG_DIR}/nohup" ];
then
    mkdir -p ${JBOSS_LOG_DIR}/nohup
fi  

if [ ! -d "${JBOSS_LOG_DIR}/gclog" ];
then
    mkdir -p ${JBOSS_LOG_DIR}/gclog
fi  

if [ ! -d "${JBOSS_LOG_DIR}/heapdump" ];
then
    mkdir -p ${JBOSS_LOG_DIR}/heapdump
fi  

## set agent configuration
export AGENT_OPTS=""
SCOUTER_AGENT_DIR=/edu/scouter/agent.java
AGENT_OPTS="${AGENT_OPTS} -javaagent:${SCOUTER_AGENT_DIR}/scouter.agent.jar"
AGENT_OPTS="${AGENT_OPTS} -Dscouter.config=${DOMAIN_BASE}/${SERVER_NAME}/bin/scouter.conf"
AGENT_OPTS="${AGENT_OPTS} -Dobj_name=${SERVER_NAME}"
AGENT_OPTS="${AGENT_OPTS} -Djboss.modules.system.pkgs=org.jboss.byteman,scouter"

mv ${JBOSS_LOG_DIR}/nohup/${SERVER_NAME}.out ${JBOSS_LOG_DIR}/nohup/${SERVER_NAME}.out.${DATE}
mv ${JBOSS_LOG_DIR}/gclog/${SERVER_NAME}.gc.log ${JBOSS_LOG_DIR}/gclog/${SERVER_NAME}.gc.log.${DATE}

rm -rf $DOMAIN_BASE/${SERVER_NAME}/tmp/*

export JAVA_OPTS="${JAVA_OPTS} ${AGENT_OPTS}"
 
nohup $JBOSS_HOME/bin/standalone.sh -DSERVER=${SERVER_NAME} -P=$DOMAIN_BASE/${SERVER_NAME}/bin/env.properties -c $CONFIG_FILE >> ${JBOSS_LOG_DIR}/nohup/${SERVER_NAME}.out 2>&1 &

if [ e$1 = "tail" ]
then
    tail -f ${JBOSS_LOG_DIR}/nohup/${SERVER_NAME}.out
fi 

