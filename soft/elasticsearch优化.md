##### 硬件优化  ####
硬件要求(cpu,内存，硬盘)  ----> 8C 64G 多盘

    cpu: Elasticsearch部署对cpu要求不高，选择具有多个内核的现代处理器，常见的集群使用两到八个核的机器。
    硬盘: 使用raid 0提高I/O,有条件用ssd,没必要做raid的高可用，es通过replicas实现高可用。
    内存：大于8G，理想是64G。32G分配给jvm的堆内存，32G留给Lucene使用。

elasticsearch内存设置：

elaaticsearch默认安装后的堆内存是1GB。修改方案有两种：一种是设置 ES_HEAH_SIZE环境变量。服务在启动时会读到这个变量
> export ES_HEAP_SIZE=31G

另一种是在启动脚本中：
> ./bin/elasticsearch -Xmx31G -Xms31G

确保堆内存最小值(Xms) 与最大值(Xmx)的大小是相同的。防止程序在运行时改变堆内存大小， 这是一个很耗系统资源的过程。

jvm的设置不要高于32G,到底要低于32GB多少：
可以通过如下命令测试：返回true为合适
> java -Xmx32600m -XX:+PrintFlagsFinal 2> /dev/null | grep UseCompressedOops


##### 把内存的一半（或少于一半）给 Lucene  ######
标准的建议是把 50％ 的可用内存作为 Elasticsearch 的堆内存，保留剩下的 50％内存给Lucene。

##### 不使用swapping  #####
内存交换 到磁盘对服务器性能来说是 致命 的。

最好的办法就是在你的操作系统中完全禁用 swap。这样可以暂时禁用：
sed -i '/swap/s/^/#/' /etc/fstab
> sudo swapoff -a

如果需要永久禁用，你可能需要修改 /etc/fstab 文件。

如果并不打算完全禁用 swap，也可以选择降低 swappiness 的值,在sysctl中设置：
> vm.swappiness = 1

如果系统层设置不合适，可以设置elasticsearch.yml文件，允许jvm锁住内存，禁止操作系统交换出去：
> bootstrap.mlockall: true


##### 系统调参
``` shell
vim /etc/security/limits.conf
elasticsearch   soft    nofile  65535
elasticsearch   hard    nofile  65535
elasticsearch   soft    nproc  65535
elasticsearch   hard    nproc  65535
elasticsearch   soft    memlock  unlimited
elasticsearch   hard    memlock  unlimited
```


##### es的配置
``` shell
thread_pool.search.size: 48     # 建议为cpu的2，3倍
thread_pool.search.queue_size: 20000
thread_pool.index.size: 9       # cpu +1
thread_pool.index.queue_size: 40000

#----------------------------
template模块设置
    - "codec": "best_compression"   启用压缩
    - "refresh_interval": "30s"     适当增大数据落盘刷新，提高写入效率，降低segment数量
    - "number_of_shards": "8"       提高查询效率，一个分片数只能有效利用1核cpu,增加分片数，提高cpu使用率
```


##### 硬盘 多块
多块磁盘，获得N倍IO性能
> path.data: /data/elasticsearch/data,/data1/elasticsearch/data[,...]





