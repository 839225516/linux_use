#!/bin/bash

# 根据PID 获取服务的 内存 CPU 线程数 文件打开数

# 使用的总内存MB
function get_total_memery(){
	total_memery=`cat /proc/${1}/status  |grep VmSize |awk '{print $2/1024}'`
	echo $total_memery
}

# 使用的物理内存MB
function get_rss_memery(){	
	rss_memery=`cat /proc/${1}/status  |grep VmRSS |awk '{print $2/1024}'`
	echo $rss_memery
}

# 进程的线程数
function get_Threads(){
	Threads=`cat /proc/${1}/status  |grep Threads |awk '{print $2}'`
	echo $Threads
}

# 进程CPU使用率 %
function get_cpu(){
    use_cpu=` top -bn 1 -p ${1}|grep ${1} |awk '{print $9}'`
	echo $use_cpu
}

# 进程打开的文件数
function get_open_files_num(){
	open_files_num=`ls -l /proc/${1}/fd |wc -l`
	echo $open_files_num
}

if [ $# -eq 1 ];then
	process_pid=$1
	cpu_use=`get_cpu $process_pid`
    total_mem=`get_total_memery $process_pid`
    rss_mem=`get_rss_memery $process_pid`
	thread_num=`get_Threads $process_pid`
	open_files_num=`get_open_files_num $process_pid`

    printf "%-8s %-10s %-14s %-10s %-15s\n" "CPU(%)" "总内存(MB)" "物理内存(MB)" "线程数" "文件打开数"
    printf "%-8s %-10s %-14s %-10s %-15s\n" "$cpu_use" "$total_mem" "$rss_mem" "$thread_num" "$open_files_num"
else 
	echo "Usage: $0 pid"
	exit 1
fi