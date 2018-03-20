基于SSH搭建SFTP服务器

基于 ssh 的 sftp 服务相比 ftp 有更好的安全性（非明文帐号密码传输）和方便的权限管理（限制用户的活动目录）
    开通 sftp 帐号，使用户只能 sftp 操作文件， 而不能 ssh 到服务器
    限定用户的活动目录，使用户只能在指定的目录下活动，使用 sftp 的 ChrootDirectory 配置

确保 ssh 的版本高于 4.8p1
``` shell
# ssh -V
```

新建sftp用户组及用户
``` shell
# groupadd sftp
# useradd -d /home/sftp -m -g sftp -s /bin/false sftp
# passwd sftp
```


活动目录,用chroot将用户的根目录指定到/data/sftp/%u
目录的权限设定有两个要点：
1、由ChrootDirectory指定的目录开始一直往上到系统根目录为止的目录拥有者都只能是root
2、由ChrootDirectory指定的目录开始一直往上到系统根目录为止都不可以具有群组写入权限
``` shell
# mkdir -p /data/sftp/%u
#配置权限 注意此目录如果用于后续的 chroot 的活动目录 目录所有者必须是 root 必须是！！！
# chown root.sftp /data/sftp/%u
# chmod 755 /data/sftp/%u
```

配置sftp
``` shell
# vim /etc/ssh/sshd_config

#####这里我们使用系统自带的 internal-sftp 服务即可满足需求,也可以用 /usr/libexec/openssh/sftp-server
#Subsystem      sftp    /usr/libexec/openssh/sftp-server
Subsystem      sftp    internal-sftp

#####sftp用户权限限定
#####Match [User|Group] userName|groupName
### ChrootDirectory /data/sftp/%u
Match Group sftp
    ChrootDirectory %h # 还可以用 %h代表用户家目录 %u代表用户名
    ForceCommand    internal-sftp # 强制使用系统自带的 internal-sftp 服务 这样用户只能使用ftp模式登录
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication no

```


ChrootDirectory    用户的可活动目录 可以用 %h 标识用户家目录 %u 代表用户名 当 Match 匹配的用户登录后 会话的根目录会切换至此目录
 这里要尤其注意两个问题
	chroot 路径上的所有目录，所有者必须是 root，权限最大为 0755，这一点必须要注意而且符合 所以如果以非 root 用户登录时，我们需要在 chroot 下新建一个登录用户有权限操作的目录
	

ForceCommand    强制用户登录会话时使用的初始命令 如果如上配置了此项 则 Match 到的用户只能使用 sftp 协议登录，而无法使用 ssh 登录
``` shell
# service sshd restart
```

建立SFTP可以写的目录
``` shell
# mkdir /home/sftp/upload
# chown sftp.sftp /home/sftp/upload
# chmod 755 /home/sftp/upload
```



-----------------------------------
sftp 日志
``` shell
# vim /etc/ssh/sshd_config

Subsystem sftp /usr/libexec/openssh/sftp-server -l INFO -f local5
LogLevel INFO

# vim /etc/rsyslog.conf

auth,authpriv.*,local5.* /var/log/sftp.log

# service rsyslog restart
# service sshd restart
```

参考： https://wiki.archlinux.org/index.php/SFTP_chroot 