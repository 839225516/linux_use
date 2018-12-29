#!/bin/bash

gitDIR=trans-api
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

srcDIR=/tmp/${gitDIR}

DIR=$(dirname $( cd "$( dirname "$0" )" && pwd ))
echo "服务路径：" $DIR
cd $DIR

### stop service
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    1) 停服务  \e[0m"
stop=`${DIR}/bin/stop.sh skip`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $stop  \e[0m"

## backup lib
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    2) backup lib  \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        mv lib lib.bak$(date +%y%m%d_%H%M)  \e[0m"
mvlib=`mv lib lib.bak$(date +%y%m%d_%H%M)`

### rsync lib 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    3) rsync lib   \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/lib $DIR  \e[0m"
rsynclib=`rsync -avh ${srcDIR}/lib $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsynclib  \e[0m"


echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/conf $DIR/conf/  \e[0m"
rsyncXML=`rsync -avh ${srcDIR}/conf $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsyncXML  \e[0m"


echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        cat conf/environment.properties.${runenv} > conf/environment.properties  \e[0m"
changeCONF=`cat conf/environment.properties.${runenv} > conf/environment.properties`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $changeCONF  \e[0m"

### start service 
echo -e "\n\n\e[1;34m$(date +%Y/%m/%d-%H:%M:%S)    4) 启服务  \e[0m"
${DIR}/bin/start.sh