#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

unset JAVA_OPTS

ps -ef | grep java | grep "\[SERVER_NAME=${SERVER_NAME}\]" | awk {'print "kill -9 " $2'} | sh -x
