##### 错误信息：
redis.clients.jedis.exceptions.JedisClusterException: CLUSTERDOWN The cluster is down

##### 排查
在一台redis机器验证集群是否正常
```shell
./redis-trib.rb check 127.0.0.1:8000
```
检测结果：[ERR] Nodes don’t agree about configuration!


问题分析：slot配置不一致问题

##### 解决办法
```shell
./redis-trib.rb fix 127.0.0.1:8000
```

修复完后，再次检测集群健康状态
```shell
./redis-trib.rb check 127.0.0.1:8000
```
