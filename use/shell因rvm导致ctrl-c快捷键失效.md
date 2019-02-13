##### linux安装rvm后导致ctrl-c快捷键失效
正常情况，登录linux后，按ctrl-c，屏幕上会出现^C字样

##### 问题
按ctrl-c后完全失效，没有任何反应。

##### 原因
安装了rvm软件（Ruby的一个管理软件），rvm -v 的版本是1.29.4,那么就会有 ctrl-c 失效的问题

##### 解决办法
卸载rvm,或者下载最新的rvm


卸载rvm
```shell
rvm implode
cd ~; rm -rf .rvm .rvmrc  /etc/rvmrc; gem uninstall rvm
```


新版已经解决了这个bug,也可以更新最版
```shell
rvm get head
```