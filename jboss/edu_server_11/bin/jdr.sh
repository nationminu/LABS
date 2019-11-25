#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

unset JAVA_OPTS 

$JBOSS_HOME/bin/jdr.sh $@

tar cvfz ${JBOSS_LOG_DIR}/jboss_sosreport_${DATE}.tar.gz ${DOMAIN_BASE}/${SERVER_NAME}/configuration/ ${JBOSS_LOG_DIR}/ ${DOMAIN_BASE}/${SERVER_NAME}/bin  
