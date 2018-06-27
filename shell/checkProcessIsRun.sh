#!/bin/bash
# check process is running or not 

PROCESS='mysql'
ps -ef|grep ${PROCESS} |grep -v grep

if [ $? -ne 0 ]; then
    echo "${PROCESS} not running"
else
    echo "${PROCESS} is running"
fi