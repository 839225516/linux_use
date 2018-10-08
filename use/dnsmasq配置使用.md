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
