#!/bin/bash

###############################################################
#File Name      :   
#Arthor         :   
#Created Time   :   2018年12月26日13:3:27
#Email          :   
#Blog           :   
#Github         :   
#Version        :	1.0
#Description    :	centos初始化脚本，前提已配置好网络
###############################################################

IP=`ip a|grep inet |grep -v 127.0.0.1 |grep -v inet6 | awk '{print $2}' |awk -F'/' '{print $1}'`

# 设置时间 hostname 
Timezone=Asia/Shanghai
HostName=devops

timedatectl set-timezone $Timezone
hostnamectl set-hostname ${HostName}-${IP}


# 关闭selinux firewalld 及 swap
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl disable firewalld
systemctl stop firewalld

swapoff -a 
sed -i 's/.*swap.*/#&/' /etc/fstab