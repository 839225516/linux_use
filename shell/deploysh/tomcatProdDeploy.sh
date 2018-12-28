#!/bin/bash

###  只用改这一个地方 srcDIR
srcDIR=pos_j@10.0.117.17:/data/java_service/agent-parent/tomcat-agent-web

DIR=$(dirname $( cd "$( dirname "$0" )" && pwd ))
echo "服务路径：" $DIR
cd $DIR

### stop service
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    1) 停服务  \e[0m"
stop=`${DIR}/bin/bin/shutdown.sh`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $stop  \e[0m"

### backup 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    2) backup   \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        cd webapps/ && tar zcf ROOT.bak$(date +%y%m%d_%H%M).tgz ROOT && cd $DIR  \e[0m"
mvlib=`cd webapps/ && tar zcf ROOT.bak$(date +%y%m%d_%H%M).tgz ROOT && cd $DIR`

echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        cd webapps/ROOT/WEB-INF/classes && \cp -pf log4j.properties servicemanage.properties  $DIR/tmp/ && cd $DIR  \e[0m"
mvconf=`cd webapps/ROOT/WEB-INF/classes && \cp -pf log4j.properties servicemanage.properties  $DIR/tmp/ && cd $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $mvconf  \e[0m"

### rsync lib from 10.0.16.5
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    3) rsync lib from 10.0.16.5  \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/webapps/ROOT $DIR/webapps  \e[0m"
rsynclib=`rsync -avh ${srcDIR}/webapps/ROOT $DIR/webapps`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsynclib  \e[0m"


echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        cd $DIR/tmp/ && \cp -pf log4j.properties servicemanage.properties ${DIR}/webapps/ROOT/WEB-INF/classes && cd $DIR  \e[0m"
rsyncXML=`cd $DIR/tmp/ && \cp -pf log4j.properties servicemanage.properties ${DIR}/webapps/ROOT/WEB-INF/classes && cd $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsyncXML  \e[0m"

### start service 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    4) 启服务  \e[0m"
${DIR}/bin/startup.sh