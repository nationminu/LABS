#!/usr/bin/env bash

dbs=( "jdbc/sample" "jdbc/testdb" )

curl --user admin:admin http://localhost:9990/manager/jmxproxy?qry=Catalina:type=Executor,name=tomcatThreadPool

curl --user admin:admin http://localhost:9990/manager/jmxproxy?qry=Catalina:type=Manager,context=/session,host=localhost

for db in "${dbs[@]}"
do

curl --user admin:admin http://localhost:9990/manager/jmxproxy?qry=Catalina:type=DataSource,class=javax.sql.DataSource,name=%22$db%22 | grep -v "password"
done
