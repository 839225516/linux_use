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
    -s      指定抓取的包的大小，使用 -s 0指定数据包大小为 262144字节
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

4）or  and
> tcpdump -i eth0 -nnn -s 0 '(tcp and port 90) and ((dst host 192.168.1.10) or (dst host 192.168.1.12))' 

5）只抓 SYN 包
> tcpdump -i eth0 'tcp[tcpflags]=tcp-syn'   
> tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0'

之捕获TCP SYN或ACK包：
> tcpdump -i eth0 -nnn 'tcp[tcpflags] & (tcp-syn|tcp-ack) != 0'

6）抓 DNS 请求数据
> tcpdump -i eth0 udp dst port 53



##### tcpdump 包分析
tcpdump对tcp数据包的显示格式：
> [time] [src > dst] [flags] [data-seqno] [ack] [window] [urgent] [options]

    src > dst   表明从源地址到
    flags       TCP包中的标志信息，S是SYN标志，F(FIN) ,P(PUSH) , R(RST), "."(没有标记)
    data-seqno  数据包中的数据的顺序号
    ack         下次期望的顺序号
    window      接收缓存的窗口大小
    urgent      数据包中是否有紧急指针
    option      选项

下面是对http进行一次完整的抓包
> tcpdump -i ens18 -nnn 'port 6666'
```
14:07:37.785688 IP 172.20.21.110.48254 > 172.20.2.225.6666: Flags [S], seq 1120822545, win 14600, options [mss 1460,sackOK,TS val 2835787065 ecr 0,nop,wscale 7], length 0
14:07:37.785789 IP 172.20.2.225.6666 > 172.20.21.110.48254: Flags [S.], seq 919861369, ack 1120822546, win 28960, options [mss 1460,sackOK,TS val 3651522101 ecr 2835787065,nop,wscale 7], length 0
14:07:37.786215 IP 172.20.21.110.48254 > 172.20.2.225.6666: Flags [.], ack 1, win 115, options [nop,nop,TS val 2835787065 ecr 3651522101], length 0

14:07:37.786326 IP 172.20.21.110.48254 > 172.20.2.225.6666: Flags [P.], seq 1:181, ack 1, win 115, options [nop,nop,TS val 2835787065 ecr 3651522101], length 180
14:07:37.786375 IP 172.20.2.225.6666 > 172.20.21.110.48254: Flags [.], ack 181, win 235, options [nop,nop,TS val 3651522102 ecr 2835787065], length 0
14:07:37.789143 IP 172.20.2.225.6666 > 172.20.21.110.48254: Flags [P.], seq 1:177, ack 181, win 235, options [nop,nop,TS val 3651522104 ecr 2835787065], length 176
14:07:37.789539 IP 172.20.21.110.48254 > 172.20.2.225.6666: Flags [.], ack 177, win 123, options [nop,nop,TS val 2835787069 ecr 3651522104], length 0

14:07:37.790234 IP 172.20.21.110.48254 > 172.20.2.225.6666: Flags [F.], seq 181, ack 177, win 123, options [nop,nop,TS val 2835787069 ecr 3651522104], length 0
14:07:37.791915 IP 172.20.2.225.6666 > 172.20.21.110.48254: Flags [F.], seq 177, ack 182, win 235, options [nop,nop,TS val 3651522107 ecr 2835787069], length 0
14:07:37.792378 IP 172.20.21.110.48254 > 172.20.2.225.6666: Flags [.], ack 178, win 123, options [nop,nop,TS val 2835787071 ecr 3651522107], length 0
```
第一行到第三行为tcp三次握手过程，包状态为[S] [S.] [.]   
第一行：client:172.20.21.110 向 server:172.20.2.225 发送了一个序号seq 1120822545 给服务端  
第二行：server 收到syn后将序号+1 并返回 ack(ack=syn+1) 1120822546,同时发一个syn=919861369包，即 SYN+ACK  
第三行：client 收到SYN+ACK包后，向server发 ack 1，建立连接。此时 client和server都进入ESTABLISHED状态  

第四行到第七行为数据交互，tcpdump -X 可以显示出具体的内容  

第八行到第十行为四次挥手的过程，包状态为 [F.] [F.] [.]
第八行： client发送一个FIN=1, seq 181 给server,说明要断开连接  
第九行： server收到后返回 ack(ack=seq+1) 182（同意断开连接）,FIN=1,seq=177的包给client（请求断开连接）--- ack延时确认，两个包合到一块一次发送了
第十行： client确认后，向server发送 ack 178 连接断开  
> 注因为在TCP连接过程中，确认的发送有一个延时（即延时的确认），一端在发送确认的时候将等待一段时间，如果自己在这段事件内也有数据要发送，就跟确认一起发送，如果没有，则确认单独发送。而我们的抓包实验中，由服务器端先断开连接，之后客户端在确认的延迟时间内，也有请求断开连接需要发送，于是就与上次确认一起发送，因此就只有三个数据报了。
