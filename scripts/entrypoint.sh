#!/bin/bash

/opt/spark/sbin/start-master.sh -p 7077
/opt/spark/sbin/start-worker.sh spark://spark-master:7077
#start-worker.sh spark://spark-master:7077
/opt/spark/sbin/start-history-server.sh

### HMS


service mysql start
sleep 5

mysql -uroot -e "CREATE USER 'hive'@'%' IDENTIFIED BY 'password'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%' WITH GRANT OPTION"
mysql -uroot -e "CREATE DATABASE metastore_db"

export HADOOP_HOME=/opt/hadoop-3.2.0
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

# Check if schema exists
/opt/apache-hive-metastore-3.0.0-bin/bin/schematool -dbType mysql -info

if [ $? -eq 1 ]; then
  echo "Getting schema info failed. Probably not initialized. Initializing..."
  /opt/apache-hive-metastore-3.0.0-bin/bin/schematool -initSchema -dbType mysql
fi

/opt/apache-hive-metastore-3.0.0-bin/bin/start-metastore
