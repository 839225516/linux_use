####  Shadowsocks Go版安装及配置
``` shell 
yum install golang git -y

# Shadowsocks Go版安装
go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-local
cp -rp $GOPATH/bin/{shadowsocks-server,shadowsocks-local} /usr/local/bin/
```

### 配置文件config.json
```shell
cat /etc/ssr/config.json 
{
    "server":"0.0.0.0",					//服务器 ip 地址
    "server_port":8888,					//端口
    "local_port":1080,
    "local_address":"127.0.0.1",
    "password":"*****",					//密码
    "method": "aes-256-cfb",			//加密方式
    "timeout":600
}
```

#### 启动脚本
```shell
 cat /etc/init.d/ssr 
#!/bin/bash


# Source function library
. /etc/rc.d/init.d/functions

# Check that networking is up.
[ ${NETWORKING} ="yes" ] || exit 0

NAME=Shadowsocks-go
DAEMON=/usr/local/bin/shadowsocks-server
if [ -f /etc/ssr/config.json ]; then
    CONF=/etc/ssr/config.json
elif [ -f /etc/ssr/config.json ]; then
    CONF=/etc/ssr/config.json
fi
PID_DIR=/var/run
PID_FILE=$PID_DIR/shadowsocks-go.pid
LOG_FILE=/var/log/ssr.log
RET_VAL=0

[ -x $DAEMON ] || exit 0

if [ ! -d $PID_DIR ]; then
    mkdir -p $PID_DIR
    if [ $? -ne 0 ]; then
        echo "Creating PID directory $PID_DIR failed"
        exit 1
    fi
fi

if [ ! -f $CONF ]; then
    echo "$NAME config file $CONF not found"
    exit 1
fi

check_running() {
    if [ -r $PID_FILE ]; then
        read PID < $PID_FILE
        if [ -d "/proc/$PID" ]; then
            return 0
        else
            rm -f $PID_FILE
            return 1
        fi
    else
        return 2
    fi
}

do_status() {
    check_running
    case $? in
        0)
        echo "$NAME (pid $PID) is running..."
        ;;
        1|2)
        echo "$NAME is stopped"
        RET_VAL=1
        ;;
    esac
}

do_start() {
    if check_running; then
        echo "$NAME (pid $PID) is already running..."
        return 0
    fi
    $DAEMON -d -c $CONF 2>&1 >> $LOG_FILE &
    PID=$!
    echo $PID > $PID_FILE
    sleep 0.3
    if check_running; then
        echo "Starting $NAME success"
    else
        echo "Starting $NAME failed"
        RET_VAL=1
    fi
}

do_stop() {
    if check_running; then
        kill -9 $PID
        rm -f $PID_FILE
        echo "Stopping $NAME success"
    else
        echo "$NAME is stopped"
        RET_VAL=1
    fi
}

do_restart() {
    do_stop
    sleep 0.5
    do_start
}

case "$1" in
    start|stop|restart|status)
    do_$1
    ;;
    *)
    echo "Usage: $0 { start | stop | restart | status }"
    RET_VAL=1
    ;;
esac

exit $RET_VAL
```


##### 配置 shadowsocks-local
shadowsocks-local的配置文件/etc/ssr-local/config.json
```json
{
        "local_port": 1081,
        "server_password": [
                ["21.121.22.54:18008", "12345", "aes-256-cfb"],
                ["174.137.50.197:18081", "123456", "aes-256-cfb"]
        ]
}
```
shadowsocks-local的启动文件
```shell
#!/bin/bash


# Source function library
. /etc/rc.d/init.d/functions

# Check that networking is up.
[ ${NETWORKING} ="yes" ] || exit 0

NAME=Shadowsocks-go-local
DAEMON=/usr/local/bin/shadowsocks-local
if [ -f /etc/ssr-local/config.json ]; then
    CONF=/etc/ssr-local/config.json
elif [ -f /etc/ssr-local/config.json ]; then
    CONF=/etc/ssr-local/config.json
fi
PID_DIR=/var/run
PID_FILE=$PID_DIR/shadowsocks-go-local.pid
LOG_FILE=/var/log/ssrlocal.log
RET_VAL=0

[ -x $DAEMON ] || exit 0

if [ ! -d $PID_DIR ]; then
    mkdir -p $PID_DIR
    if [ $? -ne 0 ]; then
        echo "Creating PID directory $PID_DIR failed"
        exit 1
    fi
fi

if [ ! -f $CONF ]; then
    echo "$NAME config file $CONF not found"
    exit 1
fi

check_running() {
    if [ -r $PID_FILE ]; then
        read PID < $PID_FILE
        if [ -d "/proc/$PID" ]; then
            return 0
        else
            rm -f $PID_FILE
            return 1
        fi
    else
        return 2
    fi
}

do_status() {
    check_running
    case $? in
        0)
        echo "$NAME (pid $PID) is running..."
        ;;
        1|2)
        echo "$NAME is stopped"
        RET_VAL=1
        ;;
    esac
}

do_start() {
    if check_running; then
        echo "$NAME (pid $PID) is already running..."
        return 0
    fi
    $DAEMON -d -c $CONF 2>&1 >> $LOG_FILE  &
    PID=$!
    echo $PID > $PID_FILE
    sleep 0.3
    if check_running; then
        echo "Starting $NAME success"
    else
        echo "Starting $NAME failed"
        RET_VAL=1
    fi
}

do_stop() {
    if check_running; then
        kill -9 $PID
        rm -f $PID_FILE
        echo "Stopping $NAME success"
    else
        echo "$NAME is stopped"
        RET_VAL=1
    fi
}

do_restart() {
    do_stop
    sleep 0.5
    do_start
}

case "$1" in
    start|stop|restart|status)
    do_$1
    ;;
    *)
    echo "Usage: $0 { start | stop | restart | status }"
    RET_VAL=1
    ;;
esac

exit $RET_VAL
```

测试
```shell
#使用代理访问
curl --socks5 127.0.0.1:1086 http://cip.cc  
#不使用代理访问
curl http://cip.cc 
```


#### 开启firewalld
```shell
firewall-cmd --permanent --zone=public --add-port=8888/tcp
firewall-cmd --permanent --zone=public --add-port=8888/udp
firewall-cmd --reload

#或者
firewall-cmd --zone=public --add-port=8888/tcp --permanent
firewall-cmd --reload
```

#### 启动
```shell 
service ssr start
service ssr status
```


### 安装privoxy，用http代理socks5
```shell 
yum install privoxy
```

配置privosy
```conf
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action # Actions that are applied to all sites and maybe overruled later on.
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
filterfile user.filter      # User customizations
logfile logfile
debug   1           # show each GET/POST/CONNECT request
debug   4096        # Startup banner and warnings
debug   8192        # Errors - *we highly recommended enabling this*
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
listen-address 0.0.0.0:18888
# 添加socks5配置
forward-socks5 / 127.0.0.1:8888 .
forward-socks5 .google.com 127.0.0.1:8888 .  # 访问google用socks5代理
```

启动：
```shell
systemctl start privoxy
systemctl enable privoxy
```
