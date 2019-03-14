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

#指定返回给客户端的ttl时间，小于查询域名的ttl以设置为准，服务器中缓存ttl不变，大于以域名的ttl为准，
max-ttl=600

#同max-ttl类似，这个是dnsmasq服务器缓存时间设定，低于域名ttl以设定为准，否则以域名ttl为准
max-cache-ttl=3600

#和max-cache-ttl相反，如果域名ttl低于设定值，强制使用设定为dnsmasq服务器的缓存时间，限制不能超过3600
min-cache-ttl=3600

#重启后清空缓存
clear-on-reload

# 不缓存未知域名
no-negcache
###############################################
```