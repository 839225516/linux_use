##### 临时设置 #####
直接在当前shell执行 
```shell
# export http_proxy=http://172.20.21.116:8888 
# export https_proxy=http://172.20.21.116:8888
# export ftp_proxy=$http_proxy
```
> 当前shell执行的export只对当前登录shell。

取消代理：
```shell
# unset http_proxy
# unset https_proxy
# unset ftp_proxy
```

##### 写入profile文件 #####
vim /etc/profile
```shell
# export http_proxy=http://172.20.21.116:8888 
# export https_proxy=http://172.20.21.116:8888
# export ftp_proxy=$http_proxy
```
执行命令加载配置
```shell
# source /etc/profile
```
