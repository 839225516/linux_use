#! /usr/bin/env bash
# 适用于只有后台启动的服务

set -eu

# pid文件
pidfile="/data/c_service/bin/run/apay_wdposp.pid"

# 告警通知脚本notice.sh
/bin/bash /etc/supervisor/notice.sh

# 启动后台服务
cd /data/c_service/bin/
command="./apay_wdposp ../etc/apay_wdposp.ini"

# Proxy signals
function kill_app(){
    kill $(cat $pidfile)
    exit 0 # exit okay
}
trap "kill_app" SIGINT SIGTERM

# Launch daemon
$command
sleep 2

# Loop while the pidfile and the process exist
while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
    sleep 0.5
done
exit 1000
