#### smb 安装
> yum install -y samba

#### 配置
``` conf
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        passdb backend = tdbsam
        load printers = no
        cups options = raw
[代付日志]
        comment = daifu log
        path = /data/approot/daifu/10.0.25.3
        public = no
        ;有效用户 @表示用户组
        valid users = devlog,@devlog
        ;写列表
        ;write list = @devlog
        browseable = yes
        writeable = no
        create mask = 0770
```

测试配置文件
> testparm

启动smb
> service smb start

#### 添加用户
创建的Samba用户必须先是系统用户,passdb.tdb用户数据库可使用smbpasswd –a 创建Samba用户  
也可使用pdbedit创建Samba账户
```shell 
先添加系统用户
# groupadd devlog
# useradd -g devlog -s /sbin/nologin -d /dev/null devlog

添加 smb帐号
# smbpasswd -a devlog
# 输入两次密码

使用pdbedit命令管理用户
新建用户
# pdbedit -a username

删除用户
# pdbedit -x username

列出用户
# pdbedit -L

列出用户详细信息
# pdbedit -Lv

暂停用户
# pdbedit -c "[D]" -u username

恢复暂停
# pdbedit -c "[]" -u username
```

#### 挂载samba
linux 
> mount -t cifs -o username="administarator",password="1234546"  //192.168.1.10/smb  /mnt/ntfs

windows
```bat
断开samba共享连接
net use * /del
net use G: //192.168.1.10/smb  password /USER:administartor
exit
```