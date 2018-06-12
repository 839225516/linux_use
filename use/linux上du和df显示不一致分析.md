linux 使用df -h 和 du -sh /data ，发现文件系统使用率不一样的情况

```shell
# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/vg_006-lv_root
                       18G  4.2G   13G  26% /
tmpfs                 7.8G   80K  7.8G   1% /dev/shm
/dev/mapper/Data-lv_data
                       99G   86G  7.9G  92% /data


# du -sh /data/
45G	/data/
```
可以看到 /data 目录 df 看到使用了 86G,但du 只使用了45G

#### 原因分析
du 命令

    分对统计文件逐个调用fstat这个系统调用，获取文件大小。它的数据是基于文件获取，可以跨多个分区操作

df 命令

    使用statfs这个系统调用，直接读取分区的超级块信息获取分区使用情况。它的数据基于分区元数据，只能针对整个分区

> 导致这个两个命令查看磁盘容量不一致的原因是  
> 用户删除了大量的文件被删除后，在文件系统目录中已经不可见了，所以du就不会再统计它。  
> 然而如果此时还有运行的进程持有这个已经被删除的文件句柄，那么这个文件就不会真正在磁盘中被删除，分区超级块中的信息也就不会更改，df仍会统计这个被删除的文件。

可通过 lsof命令查看处于deleted状态的文件，被删除的文件在系统中被标记为deleted.

```shell 
# lsof |grep deleted
java       28949     pos_j    1w      REG              253,2 45705754894    5767947 /data/java_service/agent-profit/logs/stdout.log-20180601 (deleted)
java       28949     pos_j    2w      REG              253,2 45705754894    5767947 /data/java_service/agent-profit/logs/stdout.log-20180601 (deleted)
```
看到有个大文件 stdout.log-20180601
#### 解决办法
根据lsof列出的pid,重启对应的服务




