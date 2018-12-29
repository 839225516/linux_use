#!/bin/bash


jarfile=riskctrl-manage-server.jar

red_echo ()      { echo -e "\033[031;1m$@\033[0m"; }
blue_echo ()     { echo -e "\033[034;1m$@\033[0m"; }
green_echo ()    { echo -e "\033[032;1m$@\033[0m"; }
yellow_echo ()   { echo -e "\e[1;33m$@\e[0m"; }


srcDIR=pos_j@10.0.117.17:/data/java_service/riskctrl-services/riskctrl-manage-server

DIR=$(dirname $( cd "$( dirname "$0" )" && pwd ))
blue_echo "服务路径：" $DIR
cd $DIR

### stop service
yellow_echo  "\n\n$(date +%Y/%m/%d-%H:%M:%S)    1) 停服务  "
stop=`${DIR}/bin/stop.sh skip`
green_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)        $stop "


## backup lib
yellow_echo  "\n\n$(date +%Y/%m/%d-%H:%M:%S)    2) backup jar "
green_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)        mv $jarfile ${jarfile}.bak$(date +%y%m%d_%H%M)  "
mvlib=`mv $jarfile ${jarfile}.bak$(date +%y%m%d_%H%M)  `

### rsync lib 
yellow_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)    3) rsync libs "
green_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/libs $DIR "
rsynclib=`rsync -avh ${srcDIR}/libs $DIR`
#echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsynclib  \e[0m"

### rsync rules
yellow_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)    3) rsync lib "
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/rules $DIR  \e[0m"
rsynrules=`rsync -avh ${srcDIR}/rules $DIR`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsyncrules  \e[0m"

### rsync jar
yellow_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)    3) rsync jar   \e[0m"
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        rsync -avh ${srcDIR}/${jarfile} $DIR/${jarfile}  "
rsynjar=`rsync -avh ${srcDIR}/${jarfile} $DIR/${jarfile}`
echo -e "\n\n\e[1;35m$(date +%Y/%m/%d-%H:%M:%S)        $rsynjar  \e[0m"


### start service 
yellow_echo "\n\n$(date +%Y/%m/%d-%H:%M:%S)    4) 启服务  "
${DIR}/bin/start.sh