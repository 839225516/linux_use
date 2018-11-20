#### haproxy 安装
``` shell 
yum install haproxy
```

### 配置 haproxy 
haproxy 配置有五部分：

    global:  参数是进程级的，通常和操作系统相关
    default:  默认参数可以被用到frontend, backend, listen 组件
    frontend:  接收请求的前端虚拟节点
    backend:  后端服务集群的配置，是真实服务器
    Listen:  Frontend 和 Backend的组合体

配置说明
``` shell 
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    #ulimit-n    655350
    user        haproxy
    group       haproxy
    daemon      # 后台运行

defaults
    #########   defaults 不配置log相关参数
    mode        http
    option      dontlognull     #不记录健康检查日志信息
    option      http-server-close
    option      forwardfor  except 127.0.0.0/8
    option      redispatch
    retries     3
    timeout     http-request    10s
    timeout     queue           1m
    timeout     connect         10s
    timeout     client          1m
    timeout     server          1m
    timeout     http-keep-alive 10s
    timeout     check           10s
    maxconn     3000

#### 设置监控页面
listen  admin_status
    bind    0.0.0.0:8088
    mode    http
    log     global
    option  httplog
    stats   uri     30s     #设置监控页面刷新时间30s
    stats   realm   HAProxy \HaProxy   # 统计页面密码框上提示文本 
    stats   auth    admin:admin    # 设置监控页面的用户和密码:admin,可以设置多个用户名
    stats   hide-version
    stats   admin if TRUE       # 设置手工启动/禁用，后端服务器(haproxy-1.4.9以后版本)

#-----------------------  listen -------------------
listen dbproxy
    bind 0.0.0.0:1523
    mode tcp
    log global
    option tcplog
    timeout server 60s
    timeout client 60s
    timeout connect 60s
    balance roundrobin
    server s1 10.0.51.58:1521 weight 1 check inter 5s  fall 3
    server s2 10.0.51.59:1521 weight 1 check inter 5s  fall 3
#---------------------------------------------------

#--------------------- frontend & backend ---------------------
frondtend http_80_in
    bind 0.0.0.0:80
    mode    http
    log     global
    option  httplog
    option  httpclose
    option  forwardfor
    #==============ACL==================
    acl     index   url_end  / index.html index.htm index.asp index.php index.jsp
    acl     img     url_end  .git  .jpg  .jpeg
    acl     statis  url_reg  \.(css|js|swf|png|css?.*|js?.*)$
    acl     abc     hdr(host) -i  www.abc.com       # 访问域名

    #=============== use_backend =================
    use_backend     index_rr    if index
    use_backend     img_hash    if img
    use_backend     www_any     if statis
    default_backend www_any

backend index_rr
    balance     roundrobin
    log         global
    cookie      SERVERID
    option      httpchk GET /robot.txt
    server      www-80-1    check inter 3000 rise 1 fall 1 maxconn 65535

backend img_hash
        balance         uri len 15    #以URI的前15位做hash
        cookie          SERVERID
        option          httpchk GET /robots.txt 
        server          img-80-51     192.168.71.51:80    check inter 3000 rise 1 fall 1 maxconn 65535
backend www_any
        balance         uri len 15
        cookie          SERVERID
        option          httpchk GET /robots.txt
        server          www-80-21     192.168.71.21:80    check inter 3000 rise 1 fall 1 maxconn 65535
#--------------------------------------------------------------
```


### 配置日志
``` shell
创建日志文件目录
mkdir  /data/haproxylog

开启rsyslog记录haproxy日志功能
# vim  /etc/rsyslog.conf
# 默认有 $IncludeConfig /etc/rsyslog.d/*.conf，会读取 /etc/rsyslog.d/目录下的配置文件

在 /etc/rsyslog.d/ 目录下创建配置文件
vim   /etc/rsyslog.d/haproxy.conf
$ModLoad imudp
$UDPServerRun 514
local2.*     /var/log/haproxy.log


配置rsyslog的主配置文件，开启远程日志
vim  /etc/sysconfig/rsyslog

SYSLOGD_OPTIONS=”-c 2 -r -m 0″
# -c 2 使用兼容模式，默认是 -c 5
# -r 开启远程日志
# -m 0 标记时间戳。单位是分钟，为0时，表示禁用该功能

重启 rsyslog 
service rsyslog restart 
```



