### vsftpd 安装及配置

#### 1.安装vsftpd
```shell
yum install -y vsftpd

# 关闭selinux 和 iptables
setenforce 0
service firewalld stop
service iptables stop
```

#### 2.配置文件
vim /etc/vsftpd/vsftpd.conf
```conf

anonymous_enable=NO     #是否开启匿名用户，匿名不安全不开
local_enable=YES        #允许本机账号登录FTP


#允许账号都有写操作
write_enable=YES

#local_umask的意思是指：
#    文件目录权限：777-022=755
#    文件权限：666-022=644
local_umask=022


#匿名用户是否有上传文件的功能，不开
#anon_upload_enable=YES

#匿名用户是否有创建文件夹的功能，不开
#anon_mkdir_write_enable=YES


#进入某个目录的时候，是否在客户端提示一下
dirmessage_enable=YES


#日志记录
xferlog_enable=YES

#开放port模式的20端口的连接
connect_from_port_20=YES

#修改默认的21端口
listen_port=2222

#允许没人认领的文件上传的时候，更改掉所属用户
#chown_uploads=YES

#chown_uploads=YES的前提下，所属的用户
#chown_username=whoever

#日志存放的地方
#xferlog_file=/var/log/vsftpd.log

#日志成为std格式
xferlog_std_format=YES

#用户session超时，服务器会主动断开连接，单位秒
#idle_session_timeout=600

#数据连接超时
#data_connection_timeout=120

#以 ftpsecure 作为此一服务执行者的权限。
#因为 ftpsecure 的权限相当的低，因此即使被入侵，入侵者仅能取得nobody 的权限
#nopriv_user=ftpsecure

#异步停用，由客户发起
#async_abor_enable=YES

#使用ascii格式上传文件
#ascii_upload_enable=YES

#使用ascii格式下载文件
#ascii_download_enable=YES

#欢迎词
#ftpd_banner=Welcome to blah FTP service.

#以anonymous用户登录时候，是否禁止掉名单中的emaill密码。
#deny_email_enable=YES

#以anonymous用户登录时候，所禁止emaill密码名单。
#banned_email_file=/etc/vsftpd/banned_emails

#限制用户只能在自己的目录活动
chroot_local_user=YES
#允许 限制在自己的目录活动的用户 拥有写权限
allow_writeable_chroot=YES

#例外名单，如果是YES的话，这个有点怪，上面的选项会跟这个名单反调（会被上面的选项影响）。
#chroot_list_enable=YES
#chroot_list_file=/etc/vsftpd/chroot_list

#是否允许使用ls -R等命令
ls_recurse_enable=NO

#监听ipv4端口，开了这个就说明vsftpd可以独立运行，不用依赖其他服务。
listen=YES

#监听ipv6端口
# listen_ipv6=YES

#pam模块的名称，放置在 /etc/pam.d/vsftpd ，认证用
pam_service_name=vsftpd

#使用允许登录的名单
userlist_enable=YES

#限制允许登录的名单，前提是userlist_enable=YES
userlist_deny=NO


#Tcp wrappers ： Transmission Control Protocol (TCP) Wrappers 为由 inetd 生成的服务提供了增强的安全性。
tcp_wrappers=YES
```

配置文件说明：

	   /etc/vsftpd/vsftpd.conf  vsftpd的核心配置文件
	   /etc/vsftpd/ftpusers  用于指定哪些用户不能访问FTP服务器
	   /etc/vsftpd/user_list 指定允许使用vsftpd的用户列表文件
	   /etc/vsftpd/vsftpd_conf_migrate.sh 是vsftpd操作的一些变量和设置脚本
	   /var/ftp/ 默认情况下匿名用户的根目录


#### 3.添加用户
```shell 
useradd -d /home/ftpuser -g ftp -s /sbin/nologin ftpuser

passwd ftpuser

vim /etc/vsftpd/user_list
# 在文件最后一行加登录ftp的用户名
# ftpuser
```

#### 4.启动服务
```shell 
systemctl start vsftpd.service 
systemctl enable vsftpd.service
```