#!/bin/bash
# check process is running or not 

PROCESS='mysql'
ps -ef|grep ${PROCESS} |grep -v grep

if [ $? -ne 0 ]; then
    echo "${PROCESS} not running"
else
    echo "${PROCESS} is running"
fi


# kill -0 PID
if kill -0 10010 2>/dev/null ;then
    echo "PID 10010 服务还在"
else
    echo "PID 10010 服务不在了"
fi

