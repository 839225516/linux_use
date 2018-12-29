### zkClient.sh 使用

172.20.8.20:30220

./zkCli.sh -timeout 5000  -r -server 172.20.8.20:30220

连接后输入h，获取帮助信息：
```shell 
ZooKeeper -server host:port cmd args
	stat path [watch]
	set path data [version]
	ls path [watch]
	delquota [-n|-b] path
	ls2 path [watch]
	setAcl path acl
	setquota -n|-b val path
	history 
	redo cmdno
	printwatches on|off
	delete path [version]
	sync path
	listquota path
	rmr path
	get path [watch]
	create [-s] [-e] path data acl
	addauth scheme auth
	quit 
	getAcl path
	close 
	connect host:port
```

```shell
#查看节点状态: stat  /node_name
stat  /

#查看节点的状态信息，包含内容： get /node_name
get /posp

./zkCli.sh -timeout 5000  -r -server 172.20.8.20:30220  delete /posp/accp_finance/10.233.144.51:30601




容器
#/bin/bash 

IP=`ip a|grep 'inet'|grep -v '127.0.0.1'|awk -F'[/ ]' '{print $6}'`
echo $IP

ZKIP=`netstat -plant|grep 2181|grep 'ESTABLISHED'|awk '{print $5}'|awk -F':' '{print $1}'`
echo $ZKIP
#ZKPort=`netstat -plant|grep 2181|grep 'ESTABLISHED'|awk '{print $5}'|awk -F':' '{print $2}'`
ZKPort=2181

# Find zk node
ZKNode=`echo dump |grep nc $ZKIP 2181 |grep $IP|awk '{print $1}'`



delete 

```



golang 使用go-zookeeper连接zk
```
GOROOT=D:\Go

go-zookeeper:   github.com/samuel/go-zookeeper/zk   

获取go-zookeeper   
go get github.com/samuel/go-zookeeper/zk   


