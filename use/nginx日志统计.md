nginx 日志统计
##### 日志格式
```conf
log_format      access '[$time_local] $remote_addr $server_addr:$server_port $upstream_addr "$request" [$request_length/$bytes_sent] ' 
                       '"$status"  {$request_time/$upstream_response_time} "$http_referer" "$http_user_agent" $http_x_forwarded_for';
```

##### 数据统计
```shell
#统计 IP 访问量(独立ip的访问数量)
# sort -n 按数值大小排序，默认按ASCII码值排序
tail -n 10000 logs/access.log | awk '{print $3}' | sort -n|uniq | wc -l


#查看某一时间段的IP访问量
cat logs/access.log |grep '2019:11:06:4[0-9]' | awk '{print $3}' | sort -n |uniq -c |sort -nr | head -n 10






#查看当前TCP连接数
netstat -tan | grep "ESTABLISHED" | grep ":80" | wc -l


#用tcpdump嗅探80端口的访问看看谁最高
tcpdump -i eth0 -tnn dst port 80 -c 1000 | awk -F"." '{print $1"."$2"."$3"."$4}' | sort | uniq -c | sort -nr

```
