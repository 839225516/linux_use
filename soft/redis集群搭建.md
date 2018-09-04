#### redis 集群说明 

Redis 集群是一个提供在多个Redis间节点间共享数据的程序集。

Redis集群并不支持处理多个keys的命令,因为这需要在不同的节点间移动数据,从而达不到像Redis那样的性能,在高负载的情况下可能会导致不可预料的错误.

Redis 集群通过分区来提供一定程度的可用性,在实际环境中当某个节点宕机或者不可达的情况下继续处理命令. Redis 集群的优势:

    自动分割数据到不同的节点上。
    整个集群的部分节点失败或者不可达的情况下能够继续处理命令

##### redis 集群分片
Redis 集群没有使用一致性hash, 而是引入了 哈希槽的概念.  

Redis 集群有16384个哈希槽,每个key通过CRC16校验后对16384取模来决定放置哪个槽.集群的每个节点负责一部分hash槽 

如当前集群有3个节点,那么:

    节点 A 包含 0 到 5500号哈希槽.
    节点 B 包含5501 到 11000 号哈希槽.
    节点 C 包含11001 到 16384号哈希槽

#### redis 集群的主从复制
为了使在部分节点失败或者大部分节点无法通信的情况下集群仍然可用，所以集群使用了主从复制模型,每个节点都会有N-1个复制品. 

例子中具有A，B，C三个节点的集群,在没有复制模型的情况下,如果节点B失败了，那么整个集群就会以为缺少5501-11000这个范围的槽而不可用.

然而如果在集群创建的时候（或者过一段时间）我们为每个节点添加一个从节点A1，B1，C1,那么整个集群便有三个master节点和三个slave节点组成，这样在节点B失败后，集群便会选举B1为新的主节点继续服务，整个集群便不会因为槽找不到而不可用了

不过当B和B1 都失败后，集群是不可用的.

要让集群正常运作至少需要三个主节点，不过在刚开始试用集群功能时， 强烈建议使用六个节点： 其中三个为主节点， 而其余三个则是各个主节点的从节点

##### 软件及版本信息
    
    os: CentOS Linux release 7.2.1511 (Core)
    redis: redis-4.0.9

##### redis 编译安装 #####
``` shell 
# yum install tcl
# tar zxf redis-4.0.9.tar.gz
# cd redis-4.0.9
# make MALLOC=libc 
# make test
# make install PREFIX=/usr/local/redis
```
##### 集群配置
```conf
daemonize yes
port 7000
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
```
说明：

    cluster-enabled         用于开实例的集群模式
    cluster-config-file     设定保存节点配置文件的路径，默认为nodes.conf无须人为修改，由 Redis 集群在启动时创建， 并在有需要时自动进行更新


创建六个以端口号为名字的子目录，每个目录中运行一个Redis实例：
```shell
# mkdir -p /data/redis-cluster/{7000,7001,7002,7003,7004,7005}
```
文件夹 7000 至 7005 中， 各创建一个 redis.conf 文件
``` shell 
# cat redis.conf |grep -v "^#" |grep -v "^$" >> /data/redis-cluster/7000/redis.conf
# sed "s/7000/7001/g" redis.conf > ../7001/redis.conf
```
并添加集群相关配置和修改端口号，dir
```shell 
port 7000
bind 172.20.20.13 127.0.0.1
daemonize yes
pidfile /var/run/redis_7000.pid
dir /data/redis-cluster/7000
cluster-enabled yes
cluster-config-file nodes-7000.conf
cluster-node-timeout 15000
appendonly yes
```
redis.conf 配置文件
```conf
bind 172.20.20.13 127.0.0.1
protected-mode yes
port 7000
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /var/run/redis_7000.pid
loglevel notice
logfile ""
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data/redis-cluster/7000
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
cluster-enabled yes
cluster-config-file nodes-7000.conf
cluster-node-timeout 15000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
```

启动6个节点:
```shell 
/usr/local/redis/bin/redis-server /data/redis-cluster/7000/redis.conf
/usr/local/redis/bin/redis-server /data/redis-cluster/7001/redis.conf
/usr/local/redis/bin/redis-server /data/redis-cluster/7002/redis.conf
/usr/local/redis/bin/redis-server /data/redis-cluster/7003/redis.conf
/usr/local/redis/bin/redis-server /data/redis-cluster/7004/redis.conf
/usr/local/redis/bin/redis-server /data/redis-cluster/7005/redis.conf
```

#### 安装redis-trib所需的 ruby脚本,ruby 要2.2以上
复制redis解压文件src下的redis-trib.rb文件到redis-cluster目录
```shell 
# yum install curl 
#
# curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
# curl -L get.rvm.io | bash -s stable
# source /etc/profile.d/rvm.sh
# 
# rvm install  2.4.0
# rvm remove 2.0.0
# ruby --version
# yum install rubygems
# gem install redis

####################################################
# 或者手动安装 
# ruby-2.2.4.tar.bz2   	https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.4.tar.bz2
# rubygems-2.5.1.tgz	https://rubygems.global.ssl.fastly.net/rubygems/rubygems-2.5.1.tgz
# redis-3.2.2.gem	https://rubygems.global.ssl.fastly.net/gems/redis-3.2.2.gem
####################################################
```

#### 用redis-trib.rb构建集群
```shell  
# ./redis-trib.rb create --replicas 1 172.20.20.246:7000 172.20.20.246:7001 \
 172.20.20.246:7002 172.20.20.246:7003 172.20.20.246:7004 172.20.20.246:7005
```
使用create命令 --replicas 1 参数表示为每个主节点创建一个从节点，其他参数是实例的地址集合

#### 验证集群是否成功
客户端连接集群redis-cli需要带上 -c
``` shell 
# redis-cli -h 172.20.20.246 -c -p 7000
> set hello "helloworld"

# redis-cli -h 172.20.20.246 -c -p 7005
> get hello
```

#### 集群节点选举
模拟7002节点挂掉，按照原理会选举7002的从节点7005为主节点 
``` shell
# ps -ef|grep redis
# kill {7002pid}


查看集群中的7002节点
# ./redis-trib.rb check 127.0.0.1:7002
[ERR] Sorry, can't connect to node 127.0.0.1:7002

# ./redis-trib.rb check 127.0.0.1:7005
```

再重启7002，再check 7002

7002变成7005的从节点了
