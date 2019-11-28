# APACHE TOMCAT LABS

## LAB 환경 설정 예제 배포
```
yum install -y git
git clone https://github.com/nationminu/LABS /home/share/tomcat-labs
```

## 사용자 추가 
```
groupadd -g 1001 edu 
useradd -u 1001 -g 1001 -d /edu edu
passwd edu
```

## ulimit 설정 
```
vi /etc/security/limits.conf
edu              soft     nproc           65536
edu              hard     nproc           65536
edu              soft     nofile          65536
edu              hard     nofile          65536
```

## hosts 설정 
```
vi /etc/hosts
192.168.56.101 wasts1 edu.example.com
192.168.56.102 wasts2 db.example.com 
```

## firewalld 비활성
```
systemctl stop firewalld
systemctl disable firewalld
```

##  openjdk 설치
```
yum install -y unzip java-1.8.0-openjdk java-1.8.0-openjdk-devel
```

## profile 설정
```
su - edu
vi ~/.bashrc

JAVA_HOME=/usr/lib/jvm/java-1.8.0
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH
```

## Apache Tomcat 설치 
```
mkdir -p /edu/tomcat/engine/
cd /edu/tomcat/engine/
wget http://apache.mirror.cdnetworks.com/tomcat/tomcat-9/v9.0.29/bin/apache-tomcat-9.0.29.tar.gz
tar -zxvf apache-tomcat-9.0.29.tar.gz
rm -f /edu/tomcat/engine/apache-tomcat-9.0.29.tar.gz

cd /edu/tomcat/engine/apache-tomcat-9.0.29/bin
./startup.sh

tail -f /edu/tomcat/engine/apache-tomcat-9.0.29/logs/catalina.2019-11-28.log
```

## 멀티인스턴스 설정
```
mkdir -p /edu/tomcat/domains
mkdir -p /log/tomcat

cp –r /edu/tomcat/engine/apache-tomcat-9.0.29 /edu/tomcat/domains/edu_server_11
cd /edu/tomcat/domains/edu_server_11

rm -f /edu/tomcat/domains/edu_server_11/*
rm -rf logs webapps lib work bin include

chown -R edu.edu /edu/tomcat
chown -R edu.edu /log/tomcat
```

## 멀티인스턴스 스크립트/예제 설정 복사
```
cp -r /home/share/tomcat-labs/tomcat/edu_server_11/bin /edu/tomcat/domains/edu_server_11  
cp -r /home/share/tomcat-labs/tomcat/edu_server_11/webapps /edu/tomcat/domains/edu_server_11/
cp /home/share/tomcat-labs/tomcat/default/* /edu/tomcat/domains/edu_server_11/conf/

chmod 600 /edu/tomcat/domains/edu_server_11/conf/*
``` 

## 관리 스크립트 수정
``` 
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

#export JAVA_HOME=/usr/lib/jvm/java-1.8.0
#export PATH=${JAVA_HOME}/bin:$PATH
export LOG_HOME=/log/tomcat/${SERVER_NAME}

# PORT OFFSET GROUP
export HOSTNAME=`/bin/hostname`
export JMX_BIND_ADDR=192.168.56.101
export PORT_OFFSET=0
``` 

## 권한 변경 
``` 
chown -R edu:edu /edu/ /log/
find /edu/tomcat -type d -exec chmod 700 {} \;
find /edu/tomcat -type f -exec chmod 600 {} \;
find /edu/tomcat -type f -name "*.sh" -exec chmod 700 {} \;
``` 

## Native Library 컴파일  
``` 
yum install –y gcc apr-util apr-devel openssl openssl-devel

cd /tmp
wget http://apache.tt.co.kr/tomcat/tomcat-connectors/native/1.2.23/source/tomcat-native-1.2.23-src.tar.gz
tar -zxvf tomcat-native-1.2.23-src.tar.gz
cd /tmp/tomcat-native-1.2.23-src/native
./configure --prefix=/edu/tomcat/engine/apache-tomcat-9.0.29 --with-java-home=/usr/lib/jvm/java-1.8.0-openjdk
make
make install
``` 

## Apache 컴파일  
``` 
yum install -y gcc openssl openssl-devel pcre pcre-devel apr apr-devel apr-util apr-util-devel

cd /tmp/
wget http://apache.tt.co.kr/httpd/httpd-2.4.41.tar.gz
tar -zxvf httpd-2.4.41.tar.gz
cd httpd-2.4.41
./configure --prefix=/edu/apache/httpd-2.4.41 --enable-mpms-shared=all --with-mpm=worker --enable-ssl --enable-rewrite
make
make install
``` 

## 연동 모듈 컴파일  
``` 
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz
tar -zxvf tomcat-connectors-1.2.46-src.tar.gz
cd tomcat-connectors-1.2.46-src/native
./configure --with-apxs=/edu/apache/httpd-2.4.41/bin/apxs
make
cp apache-2.0/mod_jk.so /edu/apache/httpd-2.4.41/modules

mkdir -p /log/apache/jk-log
``` 


# 연동 설정 -----------------
``` 
vi /edu/apache/httpd-2.4.41/conf/extra/jk.conf 

LoadModule jk_module modules/mod_jk.so 

JkWorkersFile conf/extra/workers.properties

JkLogFile "|/edu/apache/httpd-2.4.41/bin/rotatelogs /log/apache/jk-log/jk.log.%Y%m%d 86400 +540“ 
JkLogLevel error
JkLogStampFormat "[%Y %a %b %d %H:%M:%S]"
JKRequestLogFormat " [%w:%R] [%V] [%U] [%s] [%T]"

JkMountFile conf/extra/uriworkermap.properties
JkShmFile /log/apache/jk-log/mod-jk.shm 
``` 


## 연동 설정
``` 
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
``` 


## 연동 설정
``` 
vi /edu/apache/httpd-2.4.41/conf/extra/uriworkermap.properties

/*.jsp=edu_wlb
/*.do=edu_wlb

!/*.jpg=edu_wlb
!/*.png=edu_wlb
!/*.gif=edu_wlb
``` 

## vhost 설정
``` 
vi /edu/apache/httpd-2.4.41/conf/extra/vhosts.conf

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
``` 

## sample html
``` 
mkdir –p /edu/webapp/example.war
echo "HELLO EDU TOMCAT" >/edu/webapp/example.war/index.html
``` 

## Apache 설정 파일 추가
``` 
vi /edu/apache/httpd-2.4.41/conf/httpd.conf

Include conf/extra/jk.conf
Include conf/extra/vhosts.conf
``` 

## Apache 실행
``` 
cd /edu/apache/httpd-2.4.41/bin
./apachectl start 
./apachectl restart

tail -f /log/apache/jk-log/jk.log.20191129
``` 

# example.war 배포
``` 
rm -rf /edu/tomcat/domains/edu_server_11/webapps/ROOT 
cd /edu/webapp/example.war 
cp -r /home/share/tomcat-labs/webapp/example.war /edu/webapp/

chown -R edu.edu /edu/webapp
``` 

## server.xml example.war 배포 
```
vi /edu/tomcat/domain/edu_server_11/conf/server.xml

<Host name="localhost"  appBase="webapps"
    unpackWARs="true" autoDeploy="true">
<Context path="" docBase="/edu/webapp/example.war">
</Context>
...
</Host>
```

## Tomcat User 설정
```
vi /edu/tomcat/domain/edu_server_11/conf/tomcat-users.xml
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

  <role rolename="tomcat"/>
  <role rolename="manager"/>
  <role rolename="admin"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>
  <role rolename="Jolokia"/>

  <user username="edu" password="edu" roles="admin,tomcat,manager,manager-gui,manager-status,manager-jmx,manager-script,admin-gui,admin-script,Jolokia"/>

</tomcat-users>
```

## database 설치 
```
# 설치
yum install mariadb mariadb-server
systemctl start mariadb

yum install mysql mysql-server
systemctl start mysqld

# DB 생성 및 사용자 
mysql -u root -p 
password : Welcomemysql

create database tedu;
grant all on tedu.* to tedu identified by 'tomcatedu123!';
grant all on tedu.* to tedu@127.0.0.1 identified by 'tomcatedu123!';
grant all on tedu.* to tedu@localhost identified by 'tomcatedu123!';

# SAMPLE Data Import 
mysql -u root -p tedu < /home/share/tomcat-labs/sample-edu-db.sql
```

## JDBC 드라이버 추가
```
cp /home/share/tomcat-labs/tomcat/mysql-connector-java-8.0.18.jar /edu/tomcat/engine/apache-tomcat-9.0.29/lib/
```

## Datasource 설정
```
vi /edu/tomcat/domain/edu_server_11/conf/server.xml

<GlobalNamingResources>
...
 <Resource name="jdbc/eduDS" auth="Container"
               type="javax.sql.DataSource"
               driverClassName="com.mysql.jdbc.Driver"
               url="jdbc:mysql://192.168.56.102:3306/edu?useUnicode=true&amp;characterEncoding=utf8&amp;serverTimezone=UTC"
               username=“tedu" password=“tomcatedu1234!"
               maxTotal="10"
               maxIdle="10"
               minIdle="10"
               maxWaitMillis="30000"
               validationQuery="SELECT 1"
               testWhileIdle="true"
               timeBetweenEvictionRunsMillis="10000"
     /> 
</GlobalNamingResources>
``` 

## 클러스터링 설정
```
    <Engine name="Catalina" defaultHost="localhost" jvmRoute="${server.name}">

        <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="8">

          <Manager className="org.apache.catalina.ha.session.DeltaManager"
                   expireSessionsOnShutdown="false"
                   notifyListenersOnReplication="true"/>

          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        bind="192.168.56.101"
                        address="231.0.6.1"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="192.168.56.101"
                      port="4000"
                      autoBind="100"
                      selectorTimeout="5000"
                      maxThreads="6"/>


            <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
              <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
            </Sender>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.ThroughputInterceptor"/>
          </Channel>

          <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                 filter=""/>
          <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>

          <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                    tempDir="/tmp/war-temp/"
                    deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"
                    watchEnabled="false"/>

          <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
        </Cluster>        
```

## 클러스터 어플리케이션 설정
```
/edu/webapp/example.war/WEB-INF/web.xml

<web-app>

<distributable />
</web-app>
```

## 모니터링
```
http://192.168.56.101:8080/manager/jmxproxy?qry=Catalina:type=Executor,name=tomcatThreadPool
http://192.168.56.101:8080/manager/jmxproxy?qry=Catalina:type=DataSource,class=javax.sql.DataSource,name=%22jdbc/eduDS%22

./jmxsh –h localhost –p 9999 –U control –p

http://192.168.56.101:8080/jolokia/read/Catalina:type=Executor,name=tomcatThreadPool/maxThreads,activeCount,poolSize,largestPoolSize?ignoreErrors=true
http://192.168.56.101:8080/jolokia/read/Catalina:type=DataSource,class=javax.sql.DataSource,name="jdbc!/eudDS"/maxTotal,numActive,numIdle?ignoreErros=true
```




