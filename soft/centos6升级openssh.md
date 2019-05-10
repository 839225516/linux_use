centos6.5 升级openssh7.4

下载openssh7.4
> https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/openssh-7.4p1.tar.gz

安装依赖
> yum -y install gcc pam-devel zlib-devel openssl-devel


##### 安装telnet-server 防止ssh升级失败服务器登录不上
```shell
yum install telnet-server

vim /etc/xinetd.d/telnet
# 将disable = yes 改为disable = no

# 启动 xinetd
service xinetd start
```

允许root用户使用telnet 
```shell
vi /etc/pam.d/login
# 将pam_securetty.so行，加上“#”注释掉

vi /etc/securetty
# 增加如下几行
pts/0
pts/1
pts/2

service xinetd restart
```



手动升级openssl
```shell
# 备份当前ssl
mv /usr/bin/openssl /usr/bin/openssl.old
mv /usr/include/openssl  /usr/include/openssl.old
mv /usr/lib/libcrypto.so.1.1  /usr/lib/libcrypto.so.1.1.old
mv /usr/lib/libcrypto.so.1.1  /usr/lib/libcrypto.so.1.1.old

# 卸载旧版本openssl
rpm -qa | grep openssl  #（查看当前安装的版本）
rpm -e --nodeps `rpm -qa | grep openssh`


wget -c https://www.openssl.org/source/openssl-1.0.2o.tar.gz
tar zxf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
./config --prefix=/usr/local/openssl shared
make && make test 
make install

#设置软链接
ln -fs /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -fs /usr/local/openssl/include/openssl /usr/include/openssl
ln -fs /usr/local/openssl/lib/libssl.so.1.0.0 /usr/lib64/libssl.so
ln -fs /usr/local/openssl/lib/libssl.so.1.0.0 /usr/lib64/libssl.so.10
ln -fs /usr/local/openssl/lib/libcrypto.so.1.0.0 /usr/lib64/libcrypto.so
ln -fs /usr/local/openssl/lib/libcrypto.so.1.0.0 /usr/lib64/libcrypto.so.10

#将 OpenSSL 的动态链接库地址写入动态链接装入器（dynamic loader）
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
#重新加载动态链接库
ldconfig -v
 
#查看当前系统的openssl版本
openssl version -a
```

##### openSSH 升级 
备份当前ssh
```shell
mv /etc/ssh /etc/ssh.old 
mv /etc/init.d/sshd /etc/init.d/sshd.old

# 卸载旧版本
rpm -e --nodeps `rpm -qa | grep openssh`
```

编译安装
```shell
# tar zxf openssh-7.4p1.tar.gz
# cd openssh-7.4p1
# ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam \
  --with-ssl-dir=/usr/local/openssl --with-pam \
  --with-zlib --with-md5-passwords --with-tcp-wrappers
# make && make install

#验证openssh版本
ssh -V

cp contrib/redhat/sshd.init /etc/init.d/sshd

vi  /etc/ssh/sshd_config    
#增加  PermitRootLogin yes

chkconfig --add sshd
chkconfig sshd on
chkconfig --list sshd
service sshd restart
```

重启会出现问题：
Starting sshd: /etc/ssh/sshd_config line 80: Unsupported option GSSAPIAuthentication

解决办法：注释/etc/ssh/sshd_config中的

	PasswordAuthentication yes
	ChallengeResponseAuthentication yes
	UsePAM yes
	
升级后，默认会禁用root的远程登陆：打开注释
	
	PermitRootLogin yes


