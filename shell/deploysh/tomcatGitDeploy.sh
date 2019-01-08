#!/bin/bash

gitDIR=openflatform
runenv=kx.verify


function gitCloneFile() {
    if [ $# == 1 ];then
        ProcName=`echo "$1" | sed 's#\_#\-#g'`
	    echo -e "\e[1;36m$(date +%Y/%m/%d-%H:%M:%S)        Name: $ProcName \e[0m"
	    gitlib="http://10.150.148.254/posp/java"

	    if [ -d /tmp/$1 ];then
	        echo -e "\e[1;36m$(date +%Y/%m/%d-%H:%M:%S)        rm -rf /tmp/$1 \e[0m"
	        rm -rf /tmp/$1
        fi 
	    #echo "${gitlib}/${ProcName}"
	    echo -e "\e[1;36m$(date +%Y/%m/%d-%H:%M:%S)        git clone --depth 1 ${gitlib}/${ProcName}.git /tmp/$1 \e[0m"	
        git clone --depth 1 ${gitlib}/${ProcName}.git /tmp/$1
    else 
        echo "get clone 参数错误"
    fi
}




echo -e "\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    1) git clone ${gitDIR} \e[0m"
gitres=`gitCloneFile ${gitDIR}`
echo "$gitres"


###  只用改这一个地方 srcDIR
srcDIR=/tmp/$gitDIR

DIR=$(dirname $( cd "$( dirname "$0" )" && pwd ))
echo "服务路径：" $DIR
cd $DIR

### stop service
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    1) 停服务  \e[0m"
stop=`${DIR}/bin/shutdown.sh`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $stop  \e[0m"

### backup 
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        mkdir -p tmp && cd webapps/ROOT/WEB-INF/classes && \cp -pf log4j.properties servicemanage.properties  $DIR/tmp/ && cd $DIR  \e[0m"
mvconf=`mkdir -p tmp && cd webapps/ROOT/WEB-INF/classes && \cp -pf log4j.properties servicemanage.properties  $DIR/tmp/ && cd $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $mvconf  \e[0m"

 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    2) backup   \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        cd webapps/ && tar zcf ROOT.bak$(date +%y%m%d_%H%M).tgz ROOT && rm -rf ROOT && cd $DIR  \e[0m"
mvlib=`cd webapps/ && tar zcf ROOT.bak$(date +%y%m%d_%H%M).tgz ROOT && rm -rf ROOT  && cd $DIR`

### rsync lib from 10.0.16.5
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    3) rsync lib from 10.0.16.5  \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/ROOT $DIR/webapps  \e[0m"
rsynclib=`rsync -avh ${srcDIR}/ROOT $DIR/webapps`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsynclib  \e[0m"


echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        cd $DIR/tmp/ && \cp -pf log4j.properties servicemanage.properties ${DIR}/webapps/ROOT/WEB-INF/classes && cd $DIR  \e[0m"
rsyncXML=`cd $DIR/tmp/ && \cp -pf log4j.properties servicemanage.properties ${DIR}/webapps/ROOT/WEB-INF/classes && cd $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsyncXML  \e[0m"

### start service 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    4) 启服务  \e[0m"
${DIR}/bin/startup.sh