dnsmasp 配置

##### 安装
> yum install dnsmasq -y

##### 配置
dnsmasq配置文件 /etc/dnsmasq.conf

可以根据扩展名来包含或忽略配置文件：星号表示包含，不加星号表示排除
```conf
conf-dir=/etc/dnsmasq.d/,*.conf,*.foo
conf-dir=/etc/dnsmasq.d, .old, .bak, .tmp
```

配置修改后，必须重启dnsmasq才能生效，可以使用dnsmasq --test 来检查配置语法是否错误


##### 使用dnsmasq作本地缓存
```conf
no-hosts
no-resolv
strict-order
listen-address=127.0.0.1,0.0.0.0
log-facility=/var/log/dnsmasq.log
#开启debug模式，记录客户端查询记录到/var/log/debug
log-queries

################  上游DNS  ###################
server=119.29.29.29
server=114.114.114.114
server=8.8.8.8
##############################################


################ DNS cache ###################
#缓存的数量
cache-size=1024

#如果查询的域名没ttl，则使用此设置为缓存ttl时间
neg-ttl=600

#重启后清空缓存
clear-on-reload

# 不缓存未知域名
no-negcache
###############################################
```

