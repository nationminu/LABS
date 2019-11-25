#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

unset JAVA_OPTS  

export JAVA_OPTS="-Djboss.server.config.user.dir=${DOMAIN_BASE}/${SERVER_NAME}/configuration "

${JBOSS_HOME}/bin/add-user.sh $@
