#### linux 免密认证

1. 生成密钥对:

	authorized_keys:存放远程免密登录的公钥,主要通过这个文件记录多台机器的公钥  
	id_rsa : 生成的私钥文件  
	id_rsa.pub ： 生成的公钥文件  
	know_hosts : 已知的主机公钥清单  

ssh公钥生效需满足至少下面两个条件：
	
	.ssh目录的权限必须是700
	.ssh/authorized_keys文件权限必须是600
	
```shell
# 需要输入3次回车
ssh-keygen -t rsa

# cp 公钥到要名密登录的机器 192.168.10.10
ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.10.10
```



当我们使用ssh-keygen命令的时候，需要输入3次回车，才能创建密钥对，如何一键非交互生产密钥对呢？
```shell
ssh-keygen -t dsa -f /root/.ssh/id_dsa  -P ""

cd ~/.ssh && ssh-keygen -t dsa -f ./id_dsa  -P ""

cd ~/.ssh && ssh-keygen -t rsa -f ./id_rsa  -P ""
mkdir .ssh && chmod 700 .ssh && cd ~/.ssh && ssh-keygen -t rsa -f ./id_rsa  -P ""
```
在要登录的服务的.ssh目录下的authorized_keys文件中添加 id_dsa.pub 的内容
