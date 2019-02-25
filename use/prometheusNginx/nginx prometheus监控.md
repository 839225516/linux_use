#### nginx基于prometheus的监控

##### 监控方式
通过 prometheus-nginxlog-exporter 遍历 nginx 日志 access.log,分析日志字段并采集数据  
prometheus-nginxlog-exporter 遍历基于tail方法


##### 监控指标
|数据项|说明|
| ------ | ------ |
|http_response_count_total  | 已处理的HTTP请求/响应的总量|
|http_response_size_bytes  |  传输内容的总量（以字节为单位）|
|http_upstream_time_seconds | upstream响应时间的摘要向量，以秒为单位$upstream_response_time|
| http_upstream_time_seconds_hist | 与 http_upstream_time_seconds 相同，但作为直方图矢量|
| http_response_time_seconds | 总响应时间的摘要向量，以秒为单位 |
| http_response_time_seconds_hist | 与 http_response_time_seconds 相同，但作为直方图矢量|



1)每个HTTP请求方法和响应状态的已处理的请求数   
tengine_http_response_count_total{method="GET",request_uri="/",serviceport="21880",status="200",upstream_addr="10.3.16.20:31880"} 932

tengine_http_response_time_seconds_count{app="10.3.120.6",method="POST",request_uri="/op/credit",serviceport="28869",status="200",upstream_addr="10.3.16.30:30869"} 129

2)每个HTTP请求方法和状态处理HTTP请求所需的总时间   

tengine_http_response_time_seconds_sum{app="10.3.120.6",method="POST",request_uri="/op/credit",serviceport="28869",status="200",upstream_addr="10.3.16.30:30869"} 15.704000000000011


* 第一个指标和第二个指标一起，可用于计算平均响应时间

#### 部署
##### 安装
安装路径 /data/
```shell
cd /data/
tar -zxf prometheusNginx.tgz
```

##### 配置文件
config.yaml
```yaml
listen:
  port: 4040
  address: "0.0.0.0"

enable_experimental: true

namespaces:
  - name: "tengine"
    format: "[$time_local] $remote_addr $server_addr:$server_port $upstream_addr \"$request\" [$request_length/$bytes_sent] \"$status\"  {$request_time/$upstream_response_time} \"$http_referer\" \"$host\" \"$http_user_agent\" $http_x_forwarded_for"
    source_files:
      - /data/tengine/logs/access.log
    labels:
      app: 10.0.120.16
    relabel_configs:
    - target_label: serviceport
      from: server_port
    - target_label: upstream_addr
      from: upstream_addr
    - target_label: request_uri
      from: request
      split: 2
```

* 注意 format的格式要与nginx的格式一致   
默认情况下0.0.0.0:4040）。http://<IP>:4040/metrics然后，使用URL ，Prometheus可以查看相应的性能指标

##### 启动脚本

centos6 启动文件 /etc/init.d/prometheusnginx
``` shell
#!/bin/bash

# /etc/init.d/prometheusnginx
#
# Startup script for prometheusnginx
#
# chkconfig: 2345 20 80
# description: Starts and stops etcdkeeper

. /etc/init.d/functions

prog="prometheus-nginxlog-exporter"
prog_bin="/data/prometheusNginx/$prog"
desc="prometheusnginx service discovery daemon"

USER="prometheus"
OPTS="-config-file /data/prometheusNginx/config.yaml"
OUT_FILE="/var/log/prometheusNginx.log"


if ! [ -f $prog_bin ]; then
  echo "$prog binary not found."
  exit 5
fi

#if [ -f /etc/sysconfig/$prog ]; then
#  . /etc/sysconfig/$prog
#else
#  echo "No sysconfig file found in /etc/sysconfig/$prog... exiting."
#  exit 5
#fi

start() {
  echo "Starting $desc ($prog): "
  su $USER -c "nohup $prog_bin $OPTS >> $OUT_FILE 2>&1 &"
  RETVAL=$?
  return $RETVAL
}

stop() {
  echo "Shutting down $desc ($prog): "
  pkill -f $prog_bin
}

restart() {
    stop
    start
}

status() {
  if [ -z $pid ]; then
     pid=$(pgrep -f $prog_bin)
  fi

  if [ -z $pid ]; then
    echo "$prog is NOT running."
    return 1
  else
    echo "$prog is running (pid is $pid)."
  fi

}

case "$1" in
  start)   start;;
  stop)    stop;;
  restart) restart;;
  status)  status;;
  *)       echo "Usage: $0 {start|stop|restart|status}"
           RETVAL=2;;
esac
exit $RETVAL
```

添加启动用户和创建日志文件
```shell
useradd prometheus

touch /var/log/prometheusNginx.log
chown prometheus.prometheus /var/log/prometheusNginx.log
```

##### Grafana 图表

平均响应时间：
sum(rate(app_http_response_time_seconds_sum[5m])) by (instance) / sum(rate(app_http_response_time_seconds_count[5m])) by (instance)   

每秒请求数：sum(rate(app_http_response_time_seconds_count[1m])) by (instance)   

响应时间（90％分位数）： app_http_response_time_seconds{quantile="0.9",method="GET",status="200"}   

HTTP流量： sum(rate(app_http_response_size_bytes[5m])) by (instance)   

每秒状态码： sum(rate(app_http_response_count_total[1m])) by (status) 


##### prometheus 配置
添加job_name 数据采集
```yaml
- job_name: 'tengine_posp_agent'
    static_configs:
      - targets: ['10.3.120.16:4040']
```
