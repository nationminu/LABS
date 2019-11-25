#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. ${BASEDIR}/env.sh

unset JAVA_OPTS 

## Variable Definition ##
SNAME=$1
PASSWORD=$2
DBNAME=$3

## DBNAME CHECK ##
str_chk=`echo "$DBNAME" | egrep "(.*)\/(.*)$" | wc -l`

if [[ $str_chk ]];
then
        DBNAME=`echo "$DBNAME" | sed -e 's/\//\\\\\//g'`
fi

## CHECK INPUT DATA ##
if [ e$DBNAME == "e" ];
then
        echo " Input Datasource Info ....."
        echo " ex ) ./encrypt.sh 'Store Name' 'Password' 'Pool Name' "
        exit 1
fi

## CREATE CLI ##
echo "/subsystem=elytron/credential-store=$SNAME:add(relative-to=jboss.server.base.dir,location="bin/credentials/$SNAME.jceks",credential-reference={clear-text=rockplace},create=true)" > elytron.cli
echo "/subsystem=elytron/credential-store=$SNAME:add-alias(alias=$SNAME,secret-value=$PASSWORD)" >> elytron.cli
echo "/subsystem=datasources/data-source=$DBNAME:undefine-attribute(name=password)" >> elytron.cli
echo "/subsystem=datasources/data-source=$DBNAME:write-attribute(name=credential-reference,value={store=$SNAME,alias=$SNAME})" >> elytron.cli

./jboss-cli.sh --file=elytron.cli

rm -f elytron.cli

##############################
echo "Credential Store name : $SNAME"
echo "password : $PASSWORD"
echo "Datasource pool name : $DBNAME"
echo "## END ##"
