#!/usr/bin/env bash
# env.sh - start a new shell with instance variables set

DATE=`date +%Y%m%d%H%M%S`

export SERVER_USER=edu
export SERVER_NAME=edu_server_11

## set base env
export SERVER_HOME=/edu/tomcat
export CATALINA_HOME=${SERVER_HOME}/engine/apache-tomcat-9.0.29
export CATALINA_BASE=${SERVER_HOME}/domains/${SERVER_NAME}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CATALINA_HOME}/lib:${SERVER_HOME}/commons/native
export CLASSPATH=${CLASSPATH}:${SERVER_HOME}/commons/lib:${SERVER_HOME}/commons/conf

export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export PATH=${JAVA_HOME}/bin:$PATH 
export LOG_HOME=/log/tomcat/${SERVER_NAME}

# PORT OFFSET GROUP
export HOSTNAME=`/bin/hostname`
export JMX_BIND_ADDR=127.0.0.1
export PORT_OFFSET=0

let HTTP_PORT=8080+${PORT_OFFSET}
let HTTPS_PORT=8443+${PORT_OFFSET}
let AJP_PORT=8009+${PORT_OFFSET}
let SHUTDOWN_PORT=8005+${PORT_OFFSET}
let MGT_PORT=9990+${PORT_OFFSET}
let JMX_PORT=9999+${PORT_OFFSET}
export HTTP_PORT HTTPS_PORT AJP_PORT SHUTDOWN_PORT MGT_PORT JMX_PORT

JAVA_OPTS="-server"
JAVA_OPTS="${JAVA_OPTS} -D[SERVER_NAME=${SERVER_NAME}]"
JAVA_OPTS="${JAVA_OPTS} -Dserver.base=${SERVER_HOME}"
JAVA_OPTS="${JAVA_OPTS} -Dcatalina.base.log=${LOG_HOME}" 

JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"
JAVA_OPTS="${JAVA_OPTS} -Dserver.encoding=UTF-8" 
JAVA_OPTS="${JAVA_OPTS} -Dserver.name=${SERVER_NAME}"

JAVA_OPTS="${JAVA_OPTS} -Xms1024m"
JAVA_OPTS="${JAVA_OPTS} -Xmx1024m"
JAVA_OPTS="${JAVA_OPTS} -XX:MetaspaceSize=256m"
JAVA_OPTS="${JAVA_OPTS} -XX:MaxMetaspaceSize=256m"
#JAVA_OPTS="${JAVA_OPTS} -XX:PermSize=256m"
#JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256m" 

JAVA_OPTS="${JAVA_OPTS} -XX:+UseParallelGC" 
JAVA_OPTS="${JAVA_OPTS} -XX:+UseParallelOldGC"  

JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOG_HOME}/gclog/${SERVER_NAME}_gc.log"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDetails"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCTimeStamps"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintHeapAtGC"
JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS="${JAVA_OPTS} -XX:HeapDumpPath=$LOG_HOME/${SERVER_NAME}_java_pid_$DATE.hprof"
#JAVA_OPTS="${JAVA_OPTS} -XX:OnOutOfMemoryError='${SERVER_HOME}/bin/heap_dump.sh;${SERVER_HOME}/bin/kill.sh;${SERVER_HOME}/bin/start.sh'"

JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.access.file=${CATALINA_BASE}/conf/jmxremote.access"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.password.file=${CATALINA_BASE}/conf/jmxremote.password"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.port=${JMX_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.host=${JMX_BIND_ADDR}"
JAVA_OPTS="${JAVA_OPTS} -Djava.rmi.server.hostname=${JMX_BIND_ADDR}"

# BINDING PORT GROUP - edit server.xml
JAVA_OPTS="${JAVA_OPTS} -Dhttp.bind.port=${HTTP_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dhttps.bind.port=${HTTPS_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dajp.bind.port=${AJP_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dshutdown.bind.port=${SHUTDOWN_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dmanagement.bind.port=${MGT_PORT}"

# SecureRandom Bug
# http://wiki.apache.org/tomcat/HowTo/FasterStartUp
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"

JAVA_OPTS="${JAVA_OPTS} -Djava.net.preferIPv4Stack=true"
# tomcat 8 -> conf/web.xml : strict_quote_escaping
#JAVA_OPTS="${JAVA_OPTS} -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false"
#JAVA_OPTS="${JAVA_OPTS} -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_HTTP_SEPARATORS_IN_V0=false"

export JAVA_OPTS

printf "\e[1;34m%s\n" "================================================"
#printf " %-15s = %-20s \n" "SERVER_HOME" "${SERVER_HOME}"
printf " %-15s = %-20s \n" "CATALINA_HOME" "${CATALINA_HOME}"
printf " %-15s = %-20s \n" "CATALINA_BASE" "${CATALINA_BASE}"
printf " %-15s = %-20s \n" "SERVER_NAME" "${SERVER_NAME}"
#printf " %-15s = %-20s \n" "JAVA_OPTS" "${JAVA_OPTS}"
printf "%s\e[0m\n" "================================================"

UNAME=$USER 

if [ e${UNAME} != "e${SERVER_USER}" ]
then 
    printf "\033[0;31m%-10s\033[0m\n" "Opps! you are logged in as \"${UNAME}\" now, Run script as \"${SERVER_USER}\""
    exit;
fi 
