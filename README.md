# APACHE TOMCAT LABS

## LAB 환경 설정 예제 배포
<code><pre>
yum install -y git
git clone https://github.com/nationminu/LABS /home/share/tomcat-labs
</pre></code>

## 사용자 추가 
<code><pre>
groupadd -g 1001 edu 
useradd -u 1001 -g 1001 -d /edu edu
passwd edu
</pre></code>

## ulimit 설정 
<code><pre>
vi /etc/security/limits.conf
edu              soft     nproc           65536
edu              hard     nproc           65536
edu              soft     nofile          65536
edu              hard     nofile          65536
</pre></code>

## hosts 설정 
<code><pre>
vi /etc/hosts
192.168.56.101 wasts1 edu.example.com
192.168.56.102 wasts2 db.example.com 
</pre></code>

## firewalld 비활성
<code><pre>
systemctl stop firewalld
systemctl disable firewalld
</pre></code>

##  openjdk 설치
<code><pre>
yum install -y unzip java-1.8.0-openjdk java-1.8.0-openjdk-devel
</pre></code>

## profile 설정
<code><pre>
su - edu
vi ~/.bashrc

JAVA_HOME=/usr/lib/jvm/java-1.8.0
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH
</pre></code>

## Apache Tomcat 설치 
<code><pre>
mkdir -p /edu/tomcat/engine/
cd /edu/tomcat/engine/
wget http://apache.mirror.cdnetworks.com/tomcat/tomcat-9/v9.0.29/bin/apache-tomcat-9.0.29.tar.gz
tar -zxvf apache-tomcat-9.0.29.tar.gz
rm -f /edu/tomcat/engine/apache-tomcat-9.0.29.tar.gz

cd /edu/tomcat/engine/apache-tomcat-9.0.29/bin
./startup.sh

tail -f /edu/tomcat/engine/apache-tomcat-9.0.29/logs/catalina.2019-11-28.log
</pre></code>

## 멀티인스턴스 설정
<code><pre>
mkdir -p /edu/tomcat/domains
mkdir -p /log/tomcat

cp –r /edu/tomcat/engine/apache-tomcat-9.0.29 /edu/tomcat/domains/edu_server_11
cd /edu/tomcat/domains/edu_server_11

rm -f /edu/tomcat/domains/edu_server_11/*
rm -rf logs webapps lib work bin include

chown -R edu.edu /edu/tomcat
chown -R edu.edu /log/tomcat
</pre></code>

## 멀티인스턴스 스크립트/예제 설정 복사
<code><pre>
cp -r /home/share/tomcat-labs/tomcat/edu_server_11/bin /edu/apache/domains/edu_server_11  
cp -r /home/share/tomcat-labs/tomcat/edu_server_11/webapps /edu/apache/domains/edu_server_11/
cp /home/share/tomcat-labs/tomcat/default/* /edu/apache/domains/edu_server_11/conf/

chmod 600 /edu/apache/domains/edu_server_11/conf/*
</pre></code> 

# 관리 스크립트 수정 ----------------# 
<code><pre>
#!/usr/bin/env bash
# env.sh - start a new shell with instance variables set

DATE=`date +%Y%m%d%H%M%S`

export SERVER_USER=edu
export SERVER_NAME=edu_server_11

## set base env
export SERVER_HOME=/edu/tomcat
export CATALINA_HOME=${SERVER_HOME}/engine/apache-tomcat-9.0.29
export CATALINA_BASE=${SERVER_HOME}/domains/${SERVER_NAME}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CATALINA_HOME}/lib
export CLASSPATH=${CLASSPATH}

export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export PATH=${JAVA_HOME}/bin:$PATH
export LOG_HOME=/log/tomcat/${SERVER_NAME}

# PORT OFFSET GROUP
export HOSTNAME=`/bin/hostname`
export JMX_BIND_ADDR=192.168.56.101
export PORT_OFFSET=0
</pre></code> 

# 권한 변경 ----------------# 
chown -R edu:edu /edu/jboss /log/jboss
find /edu/jboss -type d -exec chmod 700 {} \;
find /edu/jboss -type f -exec chmod 600 {} \;
find /edu/jboss -type f -name "*.sh" -exec chmod 700 {} \;

# 관리 스크립트 ----------------# 
su # edu
cd /edu/jboss/domains/edu_server_11/bin
./start.sh
./stop.sh
./tail.sh
./kill.sh 

# Apache 컴파일 ----------------# 
yum install -y gcc openssl openssl-devel pcre pcre-devel apr apr-devel apr-util apr-util-devel

cd /tmp/
wget http://apache.tt.co.kr/httpd/httpd-2.4.41.tar.gz
tar -zxvf httpd-2.4.41.tar.gz
cd httpd-2.4.41
./configure --prefix=/edu/apache/httpd-2.4.41 --enable-mpms-shared=all --with-mpm=worker --enable-ssl --enable-rewrite
make
make install

# 연동 모듈 컴파일 ----------------# 
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz
tar -zxvf tomcat-connectors-1.2.46-src.tar.gz
cd tomcat-connectors-1.2.46-src/native
./configure --with-apxs=/edu/apache/httpd-2.4.41/bin/apxs
make
cp apache-2.0/mod_jk.so /edu/apache/httpd-2.4.41/modules

mkdir -p /log/apache/jk-log

# 연동 설정 -----------------
vi /edu/apache/httpd-2.4.41/conf/extra/jk.conf 

LoadModule jk_module modules/mod_jk.so 

JkWorkersFile conf/extra/workers.properties

JkLogFile "|/edu/apache/httpd-2.4.41/bin/rotatelogs /log/apache/jk-log/jk.log.%Y%m%d 86400 +540“ 
JkLogLevel error
JkLogStampFormat "[%Y %a %b %d %H:%M:%S]"
JKRequestLogFormat " [%w:%R] [%V] [%U] [%s] [%T]“

JkMountFile conf/extra/uriworkermap.properties
JkShmFile /log/apache/jk-log/mod-jk.shm  

# 연동 설정 -----------------
vi /edu/apache/httpd-2.4.41/conf/extra/workers.properties

worker.list=jkstatus,edu_wlb

worker.template.lbfactor=1
worker.template.type=ajp13 
 
worker.edu_server_11.reference=worker.template
worker.edu_server_11.host=192.168.56.101
worker.edu_server_11.port=8009

worker.edu_server_21.reference=worker.template
worker.edu_server_21.host=192.168.56.102
worker.edu_server_21.port=8009
 
worker.edu_wlb.type=lb 
worker.edu_wlb.method=session
worker.edu_wlb.sticky_session=true
worker.edu_wlb.balance_workers=edu_server_11,edu_server_21

worker.jkstatus.type=status


# 연동 설정 -----------------
vi /edu/apache/httpd-2.4.41/conf/extra/uriworkermap.properties

/*.jsp=edu_wlb
/*.do=edu_wlb

!/*.jpg=edu_wlb
!/*.png=edu_wlb
!/*.gif=edu_wlb

# vhost 설정
<VirtualHost *:80>
    ServerName  edu.example.com

    DocumentRoot "/edu/webapp/example.war"
    ServerAdmin  admin@example.com

    JkMount /*.do	edu_wlb
    JkMount /*.jsp	edu_wlb

    JkUnMount /*.jpg	edu_wlb
    JkUnMount /*.png	edu_wlb
    JkUnMount /*.gif	edu_wlb
</VirtualHost> 
<Directory "/edu/webapp/example.war"> 
    Require all granted 
</Directory>

# sample html -----------------
mkdir –p /edu/webapp/example.war
echo "HELLO EDU JBOSS" >/edu/webapp/example.war/index.html

cd /edu/apache/httpd-2.4.41/bin
./apachectl start
./apachectl stop
./apachectl restart

tail -f /log/apache/jk-log/jk.log.20191129

# example 배포 -----------------
mkdir -p /edu/webapp/example.war
cp /home/share/LABS/session.war /edu/webapp/example.war
cd /edu/webapp/example.war
unzip session.war
rm –f session.war


./jboss-cli.sh
deploy --runtime-name=example.war --name=example.war --unmanaged /edu/webapp/example.war/

   <deployments>
        <deployment name="example.war" runtime-name="example.war">
            <fs-exploded path="/edu/webapp/example.war"/>
        </deployment>
    </deployments>



# database 설치 -----------------
yum install mariadb mariadb-server
systemctl start mariadb

mysql -uroot -p edu < sample-edu-db.sql

# 모듈 설정 -----------------
mkdir -p /edu/jboss/engine/jboss-eap-7.2/modules/system/layers/base/mysql/main
cp /home/share/LABS/mysql-connector-java-8.0.18.jar /edu/jboss/engine/jboss-eap-7.2/modules/system/layers/base/mysql/main
cd /edu/jboss/engine/jboss-eap-7.2/modules/system/layers/base/mysql/main

vi module.xml

<module name="“"mysql" xmlns="urn:jboss:module:1.5"> 

    <resources>
        <resource-root path="mysql-connector-java-8.0.18.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/> 
    </dependencies>
</module>


# DB 설정 ----------------# 
<datasource jndi-name="java:/jdbc/eduDS" pool-name="eduDS">
<connection-url>jdbc:mysql://192.168.56.102:3306/edu?characterEncoding=UTF-8&amp;serverTimezone=UTC</connection-url>
<driver>mysql</driver>
<security>
  <user-name>edu</user-name>
  <password>edu</password>
</security>
<validation>
  <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker"/>
  <validate-on-match>true</validate-on-match>
  <background-validation>false</background-validation>
  <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"/>
</validation>
</datasource>

<driver name="mysql" module="mysql">
  <driver-class>com.mysql.jdbc.Driver</driver-class>
</driver>

/subsystem=datasources/data-source=eduDS:test-connection-in-pool

