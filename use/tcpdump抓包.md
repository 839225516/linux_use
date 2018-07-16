tcpdump依赖libpcap,从网络驱动层抓取数据。

##### tcpdump 与 iptables的关系
tcpdump依赖libpcap,从网络驱动层抓取数据，不经过任何linux的网络协议栈。iptables依赖netfilter,工作在linux网络协议栈中。

    tcpdump可以抓取到被iptables在INPUT链上DROP掉的数据包
    tcpdump不能抓取到被iptables在OUTPUT链上DROP掉的包

##### tcpdump 抓包原则
抓包结果应该尽量少。过虑无效信息；  
客户端和服务端能完全控制下时，同时抓包分析  

#### tcpdump的5个参数

    -i      指定要抓包的网卡
    -nnn    展示ip和端口，而不使用域名
    -s      指定抓取的包的大小，使用 -s 0
    -c      指定抓取包的数量
    -w      指定抓包保存到文件

##### tcp的过滤器
常用的过滤器：

    host a.b.c.d    指定抓取本机和某ip a.b.c.d 的数据包
    tcp port x      指定抓取TCP协议 目的端口 或 源端口的数据包
    icmp            指定紧抓取ICMP协议的报文
    ！              取反 如： ！port 22 表示抓取22端口以外的所有端口的数据包
    and 和 or       过滤器规则组合 如： host a.b.c.d and top port x ;  tcp port x or icmp


##### tcpdump 抓包实例
1）抓经过网上eth0 端口80的所有包
> tcpdump -i eth0 -nnn  -s 0 tcp port 80 -w tcpdump_eth0_80.pcap

2）抓取所有经过eth0,目录或源端口是 25 的网络数据
> tcpdump -i eth0 -nnn -s 0 port 25

> tcpdump -i eth0 -nnn -s 0 src/dst port 25


3）过滤网段
> tcpdump -i eth0 net 192.168

3）协议过滤
> tcpdump -i eth0 arp/ip/tcp/udp/icmp

4) or  and
> tcpdump -i eth0 -nnn -s 0 '(tcp and port 90) and ((dst host 192.168.1.10) or (dst host 192.168.1.12))' 

5) 只抓 SYN 包
> tcpdump -i eth0 'tcp[tcpflags]=tcp-syn'   
> tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0'

之捕获TCP SYN或ACK包：
> tcpdump -i eth0 -nnn 'tcp[tcpflags] & (tcp-syn|tcp-ack) != 0'

6) 抓 DNS 请求数据
> tcpdump -i eth0 udp dst port 53



