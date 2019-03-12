centos6添加宋体字体
```shell
mkdir -p /usr/share/fonts/chinese/TrueType
cd /usr/share/fonts/chinese/TrueType

# 上传字体文件

chmod 755 *.ttf

yum install -y mkfontscale fontconfig

# 建立字体缓存
mkfontscale 
mkfontdir 
fc-cache -fv 
```