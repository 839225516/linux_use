#### 查看系统默认的最大句柄数，系统默认是1024
> ulimit -n

#### 统计系统当前打开的总文件句柄数
根据打开文件句柄的数量降序排列，其中第二列为进程ID：
> lsof |awk '{print $2}'| sort |uniq -c |sort -nr| more

根据进程pid查看某进程打开的文件句柄数
> lsof -n |grep -c {PID} 

grep -c 作用与grep | wc -l 类似


#### 修改linux最大文件句柄数

1)当前session修改,只当前shell有效
> ulimit -n 65535

2)修改用户profile文件,只对单个用户有效，在profile文件中添加：
> ulimit -n 65535

3)修改文件: /etc/security/limits.conf
```conf
#限制单个进程最大文件句柄数，立即生效，但当前session中ulimit -a无法显示
*   soft    nofile  32768
*   hard    nofile  65535
```

4)修改文件： /etc/sysctl.conf,添加
```conf
fs.file-max=65535
```
再运行命令,使用配置生效：
> /sbin/sysctl -p   