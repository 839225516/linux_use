### Centos 7 安装 polipo

```shell
# 安装git
yum install -y git gcc gcc-c++ make texinfo

#下载
git clone https://github.com/jech/polipo.git
cd polipo

make all
make install 
cp polipo /usr/local/bin/

mkdir /opt/polipo

```

vim /opt/polipo/config
```conf
logSyslog = true
socksParentProxy = "localhost:1080"
socksProxyType = socks5
logFile = /var/log/polipo.log
logLevel = 4
proxyAddress = "0.0.0.0"
proxyPort = 8123
chunkHighMark = 50331648
objectHighMark = 16384

serverMaxSlots = 64
serverSlots = 16
serverSlots1 = 32
```
touch /var/log/polipo.log

vim /usr/lib/systemd/system/polipo.service
```conf
[Unit]
Description=polipo web proxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/tmp
User=root
Group=root
ExecStart=/usr/soft/polipo/polipo -c /opt/polipo/config
Restart=always
SyslogIdentifier=Polipo

[Install]
WantedBy=multi-user.target
```

#### firewalld 
```shell
firewall-cmd --permanent --add-port=8123/tcp
firewall-cmd --reload
```

systemctl start polipo.service  
systemctl enable polipo


