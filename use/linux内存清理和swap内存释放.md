### Linux 内存清理和swap内存释放

#### swap内存释放
```shell 
# 先关闭swap,再打开swap
swapoff -a ; swapon -a
```

#### 清理内存和Cash的方法
``` shell 
#清理pagecache
sync && echo 1 > /proc/sys/vm/drop_caches


#清理dentries and inodes
sync && echo 2 > /proc/sys/vm/drop_caches


#清理 pagecashe,denties and inodes
sync && echo 3 > /proc/sys/vm/drop_caches
```


