#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

unset JAVA_OPTS

${CATALINA_HOME}/bin/digest.sh -a sha-256 "$@" 
