##  logrorate 切割日志  ##

#### logrotate 安装 ####
``` shell
# yum install -y logrorate
```

#### logrotate 配置 ####
logrorate的全局配置在/etc/logrorate.conf;自定义配置在/etc/logrotate.d/

实例一：切割/data/java_service/agent-profit/logs/stdout.log，如果日志的大于1G就每天切割一次

vim /etc/logrotate.d/agent-profit
``` conf
/data/java_service/agent-profit/logs/stdout.log {
        create 640 pos_j pos_j
        notifempty
        daily
        rotate 7
        size=1024M
        dateext
        nocompress
        copytruncate
}
```
实例二: 切割/data/tengine/logs/目录下以.log结尾的日志文件
``` conf
/data/tengine/logs/*.log {
        daily
        missingok
        rotate 90
        compress
        delaycompress
        notifempty
        dateext
        dateformat -%Y%m%d.%s
        create 640 root root
        sharedscripts
        postrotate
                if [ -f /data/tengine/logs/nginx.pid ]; then
                        kill -USR1 `cat /data/tengine/logs/nginx.pid`
                fi
        endscript
}
```

配置说明：

    daily       每天执行一次
    weekly      每周执行一次
    monthly     每月执行一次
    rotate n    保留n份日志，超过的删除，默认是0
    create 0640 user usergroup      切割的日志用户权限
    notifempty  当日志文件为空时，不进行轮转
    missingok   如果日志丢失，不报错继续滚动下一个日志
    sharedscripts   运行postrotate脚本，作用是在所有日志都轮转后统一执行一次脚本
    prerotate   在logrotate转储之前需要执行的指令
    postrotate/endscript  在logrotate转储之后需要执行的指令，例如重新启动 (kill -HUP) 某个服务
    dateext     使用当期日期作为命名格式     
    dateformat .%s      配合dateext使用，只支持 %Y %m %d %s 这四个参数
    size        当日志文件到达指定的大小时才转储
    compress    在轮循任务完成后，已轮循的归档将使用gzip进行压缩
    delaycompress       与compress选项一起用，指示logrotate不要将最近的归档压缩


#### logrorate 运行机制  ####
logrorate系统默认都有安装。系统会定时运行logrorate。一般是每天一次，定时脚本在/etc/cron.daily/logrorate。
``` shell 
#!/bin/sh

/usr/sbin/logrotate /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```

#### logrorate 切割日志的方式  ####
##### 方案1： create  #####
方案的思路是重命名原日志文件，创建新的日志文件,重启服务让log指向新的日志文件。

    1.重命名程序当前正在输出日志的程序。因为重命名只会修改目录文件的内容，而进程操作文件靠的是inode编号，所以并不影响程序继续输出日志。
    2.创建新的日志文件，文件名和原来日志文件一样。
    3.通过某些方式通知程序，重新打开日志文件。程序重新打开日志文件，靠的是文件路径而不是inode编号，所以打开的是新的日志文件。

######  注意：一个程序可能输出了多个需要滚动的日志文件。每滚动一个就通知程序重新打开所有日志文件不太划得来。有个sharedscripts的参数，让程序把所有日志都重命名了以后，只通知一次。

##### 方案2： copytruncate  #####
如果程序不支持重新打开日志的功能，又不能粗暴地重启程序，怎么滚动日志呢？copytruncate

这个方案的思路是把正在输出的日志拷(copy)一份出来，再清空(trucate)原来的日志:

    1.拷贝程序当前正在输出的日志文件，保存文件名为滚动结果文件名。这期间程序照常输出日志到原来的文件中，原来的文件名也没有变。
    2.清空程序正在输出的日志文件。清空后程序输出的日志还是输出到这个日志文件中，因为清空文件只是把文件的内容删除了。

结果上看，旧的日志内容存在滚动的文件里，新的日志输出到空的文件里。实现了日志的滚动。





