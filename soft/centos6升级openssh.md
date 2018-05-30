centos6.5 升级openssh7.4

下载openssh7.4
> https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/openssh-7.4p1.tar.gz

安装依赖
> yum -y install gcc pam-devel zlib-devel openssl-devel

编译安装
```shell
# tar zxf openssh-7.4p1.tar.gz
# cd openssh-7.4p1
# ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam \
  --with-zlib --with-md5-passwords --with-tcp-wrappers
# make && make install
```

重启会出现问题：
Starting sshd: /etc/ssh/sshd_config line 80: Unsupported option GSSAPIAuthentication

解决办法：注释/etc/ssh/sshd_config中的

	PasswordAuthentication yes
	ChallengeResponseAuthentication yes
	UsePAM yes
	
升级后，默认会禁用root的远程登陆：打开注释
	
	PermitRootLogin yes


