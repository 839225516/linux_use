### git 远程覆盖本地

有时本地被的修改，想用远程的库覆盖掉。
``` shell
git fetch --all  
git reset --hard origin/master
```

git fetch 只是下载远程的库的内容，不做任何的合并   
git reset 把HEAD指向刚刚下载的最新的版本



