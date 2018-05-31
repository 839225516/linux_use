#!/bin/bash 
DIR=$(dirname $( cd "$( dirname "$0" )" && pwd ))
echo "服务路径：" $DIR
SERVICE_NAME="Djava.util.logging.config.file=${DIR}/conf/logging.properties"
PID=`ps -ef |grep "$SERVICE_NAME"|grep -v grep |awk  '{print $2}'`
#echo $PID
if [ "$PID" == "" ];then
    echo -e "\e[1;31mprogress is not running\e[0m\n\e[1;34mStarting progress\e[0m ..."
    sh $DIR/bin/startup.sh
    
else
    echo -n "Stopping progress ..."
    kill $PID

    while kill -0 $PID
    do
        echo -n "..."
        sleep 2
    done

    echo -e "\n\e[1;34mRestart progress\e[0m ... "
    sh $DIR/bin/startup.sh
fi
