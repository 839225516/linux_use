#!/bin/bash

###  只用改这一个地方 srcDIR
srcDIR=pos_j@10.0.16.5:/data/java_service/accp-java-server

DIR=$(dirname $( cd "$( dirname "$0" )" && pwd ))
echo "服务路径：" $DIR
cd $DIR

### stop service
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    1) 停服务  \e[0m"
stop=`${DIR}/bin/stop.sh skip`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $stop  \e[0m"

### backup lib
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    2) backup lib  \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        mv lib lib.bak$(date +%y%m%d_%H%M)  \e[0m"
mvlib=`mv lib lib.bak$(date +%y%m%d_%H%M)`

### rsync lib from 10.0.16.5
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    3) rsync lib from 10.0.16.5  \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/lib $DIR  \e[0m"
rsynclib=`rsync -avh ${srcDIR}/lib $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsynclib  \e[0m"


echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/conf/*.xml $DIR/conf/  \e[0m"
rsyncXML=`rsync -avh ${srcDIR}/conf/*.xml $DIR/conf/`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsyncXML  \e[0m"

### start service 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    4) 启服务  \e[0m"
${DIR}/bin/start.sh