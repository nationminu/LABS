#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

unset JAVA_OPTS 

tail -f ${JBOSS_LOG_DIR}/server.log

