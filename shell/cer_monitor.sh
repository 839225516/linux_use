#!/bin/bash

######################################
# https 证书监控
# usage: ./cer_monitor.sh url
# eg: ./cer_monitor.sh www.jlpay.com
######################################

if [ "$#" -eq "1" ];then
    url=$1
else
    echo -e "Usage: $0 url\n   eg: $0 www.jlpay.com"
    exit 1
fi

cer_start_day=`echo | openssl s_client -servername $url -connect ${url}:443 2>/dev/null | openssl x509 -noout -dates|grep notBefore| grep -v grep| awk -F'=' '{print $2}'| xargs -I {} date -d "{}" +%F`
cer_start_time=`echo | openssl s_client -servername $url -connect ${url}:443 2>/dev/null | openssl x509 -noout -dates|grep notBefore| grep -v grep| awk -F'=' '{print $2}'| xargs -I {} date -d "{}" +%s`
echo "证书起始时间" $cer_start_day

cer_end_day=`echo | openssl s_client -servername $url -connect ${url}:443 2>/dev/null | openssl x509 -noout -dates|grep notAfter| grep -v grep| awk -F'=' '{print $2}'| xargs -I {} date -d "{}" +%F`
cer_end_time=`echo | openssl s_client -servername $url -connect ${url}:443 2>/dev/null | openssl x509 -noout -dates|grep notAfter| grep -v grep| awk -F'=' '{print $2}'| xargs -I {} date -d "{}" +%s`
echo "证书到期时间" $cer_end_day

current_day=`date +%F`
current_time=`date +%s`
echo "当前时间" $current_day

enable_days_stamp=$(( $cer_end_time - $current_time ))
enable_days=$(($enable_days_stamp/86400))
echo "$url 证书可用天数: " $enable_days
