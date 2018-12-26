#!/bin/bash


function Install_base_Softwares {
    echo -e "\e[1;33mInstalling base tools , please wait for a while...\e[0m"
    yum install vim -y > /dev/null
    yum install wget -y > /dev/null
}


function Install_DEV_Softwares {
    echo -e "\e[1;33mInstalling develop tools and libraries, please wait for a while...\e[0m"
    yum install gcc -y > /dev/null
    yum install gcc-c++ -y > /dev/null
    yum install make -y > /dev/null   
    yum install cmake -y > /dev/null
}

function Install_Necessary_Tools {
	echo -e "\e[1;33mInstalling necessary tools, please wait for a while...\e[0m"
	yum install net-tools -y > /dev/null
	yum install lrzsz -y > /dev/null	
	yum install ntpdate -y > /dev/null
}

function Change_Yum_Repo {
	cd /etc/yum.repos.d/

	mkdir repo_bak

	mv *.repo repo_bak/

	# 使用网易和阿里的开源镜像
	wget http://mirrors.aliyun.com/repo/Centos-7.repo
	wget http://mirrors.163.com/.help/CentOS7-Base-163.repo

	# 清除系统所有的yum缓存
	yum clean all

	# 生成yum缓存
	yum makecache


	# 安装epel源
	yum install -y epel-release

	# 使用阿里开源镜像提供的epel源
	wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all && yum makecache
}




# 1)安装基本的工具 wget,vim
Install_base_Softwares

# 2)添加第三方yum源
Change_Yum_Repo

# 3)安装开发软件和系统工具
Install_DEV_Softwares
Install_Necessary_Tools