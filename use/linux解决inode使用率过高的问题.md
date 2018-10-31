### linux解决inode使用率过高的问题

查看系统的inode占用情况
``` shell 
df -ih
```

如何查找哪个目录文件最多
``` shell 
for i in /*; do echo $i; find $i | wc -l; done

如知道更具体目录是/data/
for i in /data/*; do echo $i; find $i | wc -l; done
```

找到文件数目最多的目录
``` shell 
# 删除0字节的文件，和一些不要的文件
find /data/logs -type f -size 0 -exec rm {} \;
```

