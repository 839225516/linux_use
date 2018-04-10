## centos7 安装 mariadb ##
MySQL 已经不再包含在 CentOS 7 的源中，而改用了 MariaDB

1) yum安装 mariadb client 和mariadb server
```shell 
# yum -y install mariadb mariadb-server
```

2) 启动和设置开机启动
```shell
# systemctl start mariadb
# systemctl enable mariadb
```

3)初始化设置
``` shell
# mysql_secure_installation

首先是设置密码，会提示先输入密码
Enter current password for root (enter for none):  <– 初次运行直接回车

设置root密码
Set root password? [Y/n]      <– 是否设置root用户密码，输入y并回车或直接回车
New password:                 <– 设置root用户的密码
Re-enter new password:        <– 再输入一次你设置的密码

其他配置
Remove anonymous users? [Y/n]        <– 是否删除匿名用户，回车
Disallow root login remotely? [Y/n]  <–是否禁止root远程登录,回车,
Remove test database and access to it? [Y/n]   <– 是否删除test数据库，回车
Reload privilege tables now? [Y/n]             <– 是否重新加载权限表，回车
```

初始化完成后，测试登录：
```shell
# mysql -uroot -p
```

4)配置mariadb的字符集为utf-8
vim /etc/my.cnf
``` shell
#在 [mysqld] 标签下添加
init_connect='SET collation_connection = utf8_unicode_ci' 
init_connect='SET NAMES utf8' 
character-set-server=utf8 
collation-server=utf8_unicode_ci 
skip-character-set-client-handshake
```
vim /etc/my.cof.d/client.cnf
```shell
#在 [client] 标签中添加
default-character-set=utf8
```

vim /etc/my.cnf.d/mysql-clients.cnf
```shell
#在 [mysql] 中添加
default-character-set=utf8
```
重启mariadb
``` shell
# systemctl restart mariadb
```
进mariadb查看字符集
```shell
mysql> show variables like "%character%"; show variables likes "%collation%"
```

5)添加用户
``` shell
# 创建用户
mysql> create user username@localhost identified by 'passwd';

# 直接创建用户并授权
mysql> grant all privileges on *.* to username@localhost identified by 'passwd';

#授予权限并可以授权
mysql> grant all privileges on *.* to username@'hostname' identified by 'passwd' with grant option;
```


6) mariadb 完成安全配置后出现 1045 (28000)
错误信息：
```shell 
mariadb 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```
解决：
```shell
# systemctl stop mariadb
# mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
# mysql -u root mysql

MariaDB [mysql]> UPDATE user SET Password=PASSWORD('新密码') where USER='root';
MariaDB [mysql]> FLUSH PRIVILEGES;
MariaDB [mysql]> quit

# systemctl restart mariadb.service
```
