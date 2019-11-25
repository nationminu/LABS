#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/env.sh

unset JAVA_OPTS

ps -ef | grep java | grep "\[SERVER_NAME=${SERVER_NAME}\]" | awk -v today="${DATE}" {'print "jmap -dump:format=b,file=$LOG_HOME/java_dump." today ".hprof "  $2'} | sh -x
