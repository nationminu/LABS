#!/usr/bin/env bash

dbs=( "jdbc!/sample" "jdbc!/testdb" )

#echo "threads --------------"
curl --user admin:admin http://localhost:9990/jolokia/read/Catalina:type=Executor,name=tomcatThreadPool/maxThreads,activeCount,largestPoolSize?ignoreErrors=true

echo "" 

curl --user admin:admin http://localhost:9990/jolokia/read/Catalina:type=Manager,context=!/session,host=localhost/activeSessions,maxActive?ignoreErrors=true

echo ""

for db in "${dbs[@]}"
do
# echo "datasource $db ----- "
 curl --user admin:admin http://localhost:9990/jolokia/read/Catalina:type=DataSource,class=javax.sql.DataSource,name=%22$db%22/maxTotal,numActive,numIdle?ignoreErros=true
 echo ""
done
