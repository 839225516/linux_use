
etcd tls集群安装

### 1）科普 ca

认识几个概念：SSL、TLS、HTTPS、X.509、CRT、CSR、PEM

SSL：（Secure Socket Layer，安全套接字层），用以保障在Internet上数据传输之安全，利用数据加密(Encryption)技术，可确保数据在网络上之传输过程中不会被截取。它已被广泛地用于Web浏览器与服务器之间的身份认证和加密数据传输。

TLS：(Transport Layer Security，传输层安全协议)，用于两个应用程序之间提供保密性和数据完整性。它建立在SSL 3.0协议规范之上，是SSL 3.0的后续版本，可以理解为SSL 3.1，它是写入了 RFC 的。该协议由两层组成： TLS 记录协议（TLS Record）和 TLS 握手协议（TLS Handshake）。较低的层为 TLS 记录协议，位于某个可靠的传输协议（例如 TCP）上面。

HTTPS：咱们通常所说的 HTTPS 协议，说白了就是“HTTP 协议”和“SSL/TLS 协议”的组合，给HTTP协议添加了安全层。 如果原来的 HTTP 是塑料水管，容易被戳破；那么如今新设计的 HTTPS 就像是在原有的塑料水管之外，再包一层金属水管。一来，原有的塑料水管照样运行；二来，用金属加固了之后，不容易被戳破。

X.509：这是一种证书标准,主要定义了证书中应该包含哪些内容.其详情可以参考RFC5280,SSL使用的就是这种证书标准.

CRT：（Certificate，证书）,常见于*NIX系统,有可能是PEM编码,也有可能是DER编码,大多数应该是PEM编码,相信你已经知道怎么辨别.

CSR：（Certificate Signing Request,即证书签名请求）,这个并不是证书,而是向权威证书颁发机构获得签名证书的申请,其核心内容是一个公钥(当然还附带了一些别的信息),在生成这个申请的时候,同时也会生成一个私钥,私钥要自己保管好.做过iOS APP的朋友都应该知道是怎么向苹果申请开发者证书的吧.

PEM：（Privacy Enhanced Mail）, 是 X.509 的一种编码格式（以"-----BEGIN..."开头, "-----END..."结尾,内容是BASE64编码）。还有一种是DER。

OpenSSL： 是一个安全套接字层密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及SSL协议，并提供丰富的应用程序供测试或其它目的使用。


公钥基础设施（public key infrastructure，缩写为PKI）
认证中心（CA）

PKI借助数字证书和公钥加密技术提供可信任的网络身份。通常，证书就是一个包含如下身份信息的文件：
    证书所有组织的信息
    公钥
    证书颁发组织的信息
    证书颁发组织授予的权限，如证书有效期、适用的主机名、用途等
    使用证书颁发组织私钥创建的数字签名

CFSSL支持以下三种私钥保护模式：
    “硬件安全模块（Hardware Security Module，缩写为HSM）
    Red October
    纯文本

SSL/TSL 认证分单向认证和双向认证两种方式。简单说就是单向认证只是客户端对服务端的身份进行验证，双向认证是客户端和服务端互相进行身份认证

### 2）使用CFSSL生成CA证书和私钥

1 安装 CFSSL,二进制安装
``` shell
# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
# chmod +x cfssl_linux-amd64
# mv cfssl_linux-amd64 /usr/local/bin/cfssl

# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
# chmod +x cfssljson_linux-amd64
# mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

# wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
# chmod +x cfssl-certinfo_linux-amd64
# mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
```
2 创建 CA 配置文件

ca信息：
Common Name             CN: My CA
Organizational Unit     OU=(组织单位名称)
Organization            O=(组织名称)
Locality                L=(城市或区域名称)
State or Province       ST=(州或省份名称)
Country                 C=(单位的两字母国家代码)

``` shell
# mkdir ssl
# cd ssl

# cfssl print-defaults csr > csr.json
```
初始化证书颁发机构,修改csr.json的ca信息：
``` json
{
    "CN": "K8S CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "system",
            "O": "k8s",
            "C": "CN",
            "L": "ShenZhen",
            "ST": "ShenZhen"
        }
    ]
}
``` 

生成 CA 证书：
```shell
# cfssl gencert -initca csr.json | cfssljson -bare ca -
```
将会生成以下几个文件：

    ca-key.pem
    ca.pem
    ca.csr
    请务必保证 ca-key.pem 文件的安全，*.csr 文件在整个过程中不会使用

配置 CA 选项,修改config.json,分别配置针对三种不同证书类型的profiles,期中有效期43800h为5年:

    config.json：可以定义多个 profiles，分别指定不同的过期时间、使用场景等参数；后续在签名证书时使用某个 profile；
    signing：表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE；
    server auth：表示client可以用该 CA 对server提供的证书进行验证；
    client auth：表示server可以用该CA对client提供的证书进行验证

etcd 涉及到三类证书：

    client certificate 用于通过服务器验证客户端。例如etcdctl，etcd proxy，fleetctl或docker客户端。
    server certificate 由服务器使用，并由客户端验证服务器身份。例如docker服务器或kube-apiserver。
    peer certificate 由 etcd 集群成员使用，供它们彼此之间通信使用
```shell
# cfssl print-defaults config > config.json
```
config.json
``` json
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
```

etcd 通过命令行或环境变量获取几个证书相关的配置

1）客户端到服务器的通信：
    
    --cert-file    设置此选项后，通告-客户端-URL可以使用HTTPS架构
    --key-file     证书的密钥，必须是末加密的
    --trusted-ca-file
    --auto-tls

2)对等通信：

    --peer-cert-file
    --peer-key-file
    --peer-trusted-ca-file
    --peer-auto-tls


server端证书：
```shell
# cfssl print-defaults csr > server.json
```
server.json
``` json
{
    "CN": "server",
    "hosts": [
        "127.0.0.1",
        "192.168.220.101",
        "192.168.220.102",
        "192.168.220.103"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "OU": "system",
            "O": "k8s",
            "C": "CN",
            "L": "ShenZhen",
            "ST": "ShenZhen"
        }
    ]
}
```
生成server端证书及private.key
``` shell
# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=config.json -profile=server server.json | cfssljson -bare server
```
将会生成如下文件：

	server-key.pem
	server.pem
	server.csr

client端证书：
client.json
``` json
{
    "CN": "client",
    "hosts": [
        "127.0.0.1",
        "192.168.220.101",
        "192.168.220.102",
        "192.168.220.103"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "system",
            "O": "k8s",
            "C": "CN",
            "L": "ShenZhen",
            "ST": "ShenZhen"
        }
    ]
}
```
生成client certificate
```shell
# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=config.json -profile=client client.json |  cfssljson -bare client
```
得到如下文件：

	client-key.pem
	client.pem
	client.csr 

对等证书：
member.json
``` json
{
    "CN": "member",
    "hosts": [
        "127.0.0.1",
        "192.168.220.101",
        "192.168.220.102",
        "192.168.220.103"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "system",
            "O": "k8s",
            "C": "CN",
            "L": "ShenZhen",
            "ST": "ShenZhen"
        }
    ]
}
```
生成 member certificate与private key
```shell
# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=config.json -profile=peer member.json |  cfssljson -bare member
```
得到如下文件：

	member-key.pem
	member.pem
	member.csr    

3 etcd 安装

https://github.com/coreos/etcd/releases 这里下面最新版本 v3.3.2
```shell
# wget https://github.com/coreos/etcd/releases/download/v3.3.2/etcd-v3.3.2-linux-arm64.tar.gz
```
解压缩etcd-v3.1.6-linux-amd64.tar.gz，将其中的etcd和etcdctl两个可执行文件复制到各节点的/usr/bin目录

在各节点创建etcd的数据目录：
```shell
# mkdir -p /var/lib/etcd
```
在各节点创建tls证书目录,并copy证书：
```shell
# mkdir -p /etc/etcd/ssl/
# cp ca.pem server.pem server-key.pem member.pem member-key.pem /etc/etcd/ssl/
```


在每个节点上创建etcd的systemd unit文件/usr/lib/systemd/system/etcd.service，注意替换ETCD_NAME和INTERNAL_IP变量的值：
```shell
# cat > /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd \
  --name node1 \
  --cert-file=/etc/etcd/ssl/server.pem \
  --key-file=/etc/etcd/ssl/server-key.pem \
  --peer-cert-file=/etc/etcd/ssl/member.pem \
  --peer-key-file=/etc/etcd/ssl/member-key.pem \
  --client-cert-auth --trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --peer-client-cert-auth --peer-trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --initial-advertise-peer-urls https://192.168.220.101:2380 \
  --listen-peer-urls https://192.168.220.101:2380 \
  --listen-client-urls https://192.168.220.101:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://192.168.220.101:2379 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster node1=https://192.168.220.101:2380,node2=https://192.168.220.102:2380,node3=https://192.168.220.103:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```
参数说明：

    启动参数中指定了etcd的工作目录和数据目录是/var/lib/etcd
    --cert-file和--key-file分别指定etcd的公钥证书和私钥
    --peer-cert-file和--peer-key-file分别指定了etcd的Peers通信的公钥证书和私钥。
    --trusted-ca-file指定了客户端的CA证书
    --peer-trusted-ca-file指定了Peers的CA证书
    --initial-cluster-state new表示这是新初始化集群


YUM 方式安装则可以在配置文件修改
```shell
# yum install  -y etcd
# vim /etc/etcd/etcd.conf
```
``` ini
# [member]
ETCD_NAME=etcd1
ETCD_DATA_DIR="/var/lib/etcd/etcd1.etcd"
ETCD_WAL_DIR="/var/lib/etcd/wal"
ETCD_SNAPSHOT_COUNT="100"
ETCD_HEARTBEAT_INTERVAL="100"
ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="https://192.168.220.101:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.220.101:2379,http://127.0.0.1:2379"
ETCD_MAX_SNAPSHOTS="5"
ETCD_MAX_WALS="5"
#ETCD_CORS=""

# [cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.220.101:2380"
ETCD_INITIAL_CLUSTER="etcd1=https://192.168.220.101:2380,etcd2=https://192.168.220.102:2380,etcd3=https://192.168.220.103:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.220.101:2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_STRICT_RECONFIG_CHECK="false"
#ETCD_AUTO_COMPACTION_RETENTION="0"

# [proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"

# [security]
ETCD_CERT_FILE="/etc/etcd/ssl/server.pem"
ETCD_KEY_FILE="/etc/etcd/ssl/server-key.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
ETCD_AUTO_TLS="true"
ETCD_PEER_CERT_FILE="/etc/etcd/ssl/member.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/ssl/member-key.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ssl/ca.pem"
ETCD_PEER_AUTO_TLS="true"

# [logging]
#ETCD_DEBUG="false"
# examples for -log-package-levels etcdserver=WARNING,security=DEBUG
#ETCD_LOG_PACKAGE_LEVELS=""
```    

其它节点修改对应的 ETCD_NAME 和 ip

启动etcd 
```shell
# systemctl daemon-reload
# systemctl enable etcd
# systemctl start etcd
# systemctl status etcd
```

检查集群是否健康，在任一节点执行：
```shell
# etcdctl --ca-file=/etc/etcd/ssl/ca.pem \
  --cert-file=/etc/etcd/ssl/server.pem \
  --key-file=/etc/etcd/ssl/server-key.pem \
  --endpoints=https://node1:2379,https://node2:2379,https://node3:2379 \
  cluster-health
```
确保cluster is healthy


##### yum 安装etcd 无证书
```shell 
yum install etcd -yum


ETCD_DATA_DIR="/var/lib/etcd/default.etcd"  #etcd数据保存目录
ETCD_LISTEN_CLIENT_URLS="http://10.25.72.164:2379,http://localhost:2379"  #供外部客户端使用的url
ETCD_ADVERTISE_CLIENT_URLS="http://10.25.72.164:2379,http://localhost:2379" #广播给外部客户端使用的url
ETCD_NAME="etcd1"   #etcd实例名称

ETCD_LISTEN_PEER_URLS="http://10.25.72.164:2380"  #集群内部通信使用的URL
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.25.72.164:2380"  #广播给集群内其他成员访问的URL
ETCD_INITIAL_CLUSTER="etcd1=http://10.25.72.164:2380,etcd2=http://10.25.72.233:2380,etcd3=http://10.25.73.196:2380"    #初始集群成员列表
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster" #集群的名称
ETCD_INITIAL_CLUSTER_STATE="new"  #初始集群状态，new为新建集群
```




