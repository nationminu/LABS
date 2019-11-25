#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

unset JAVA_OPTS  

export JAVA_OPTS=" -Djava.awt.headless=false"

${JBOSS_HOME}/bin/jboss-cli.sh  --controller=${CONTROLLER_IP}:${CONTROLLER_PORT} --connect $@

