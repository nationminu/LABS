# APACHE TOMCAT LABS

## 사용자 추가 
<code>
<pre>
groupadd -g 1001 edu 
useradd -u 1001 -g 1001 -d /edu edu
passwd edu
</pre>
</code>

## ulimit 설정 
vi /etc/security/limits.conf
edu              soft     nproc           65536
edu              hard     nproc           65536
edu              soft     nofile          65536
edu              hard     nofile          65536

# hosts 설정 ----------------- 
<code>
vi /etc/hosts
192.168.56.101 wasts1 edu.example.com poc.example.com
192.168.56.102 wasts2 db.example.com 
</code>

# firewalld 비활성 -----------------
systemctl stop firewalld
systemctl disable firewalld

# openjdk 설치 -----------------
yum install -y unzip java-1.8.0-openjdk java-1.8.0-openjdk-devel

# profile 설정 ----------------# 
su # edu
vi ~/.bashrc

JAVA_HOME=/usr/lib/jvm/java-1.8.0
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH

# jboss EAP 설치 ----------------# 
mkdir -p /edu/jboss/engine/
cp /home/share/LABS/jboss-eap-7.2.0.zip /edu/jboss/engine/
cd /edu/jboss/engine/
unzip /edu/jboss/engine/jboss-eap-7.2.0.zip
chown -R edu:edu /edu/jboss

# 멀티인스턴스 설정 ----------------# 
mkdir -p /edu/jboss/domains/
cp -r /edu/jboss/engine/jboss-eap-7.2/standalone /edu/jboss/domains/edu_server_11
cd /edu/jboss/domains/edu_server_11
rm -rf /edu/jboss/domains/edu_server_11/data
rm -rf /edu/jboss/domains/edu_server_11/log
rm -rf /edu/jboss/domains/edu_server_11/tmp

# 관리 스크립트 설정 ----------------# 
cp /home/share/LABS/script.tar.gz /edu/jboss/domains/edu_server_11
cd /edu/jboss/domains/edu_server_11
tar -zxvf script.tar.gz
rm -f script.tar.gz
chown -R edu:edu /edu/jboss /log/jboss

# 관리 스크립트 수정 ----------------# 
##### JBOSS Directory Setup #####
export JBOSS_HOME=/edu/jboss/engine/jboss-eap-7.2
export DOMAIN_BASE=/edu/jboss/domains
export SERVER_NAME=edu_server_11
export JBOSS_LOG_DIR=/log/jboss/${SERVER_NAME}

##### Configration File #####
export CONFIG_FILE=standalone-ha.xml

export HOST_NAME=`/bin/hostname`
export NODE_NAME=${SERVER_NAME}

export PORT_OFFSET=0

export JBOSS_USER=edu

##### Bind Address #####
export BIND_ADDR=192.168.56.101

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

