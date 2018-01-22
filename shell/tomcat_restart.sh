#!/bin/bash 

set -eu

#修改tomcat的路径
PROG="Djava.util.logging.config.file=/data/java_service/tomcat/conf/logging.properties"
PID=`ps -ef |grep "$PROG"|grep -v grep |awk  '{print $2}'`
echo "tomcat的pid: $PID"
if [ "$PID" == "" ];then
    echo -e "\e[1;31mprogress is not running\e[0m!\n\e[1;34mStarting progress\e[0m ..."
    sh startup.sh

else
    echo -n "Stopping progress ..."
    kill $PID

    while kill -0 $PID
    do
        echo -n "..."
        sleep 2
    done

    echo -e "\n\e[1;34mRestart progress\e[0m ... "
    sh startup.sh
fi
