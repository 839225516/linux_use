### Manjaro 安装及配置
#### 配置相关pacman源
```shell
# 生成可用的中国镜像站列表
sudo pacman-mirrors -i -c China -m rank


#更换软件源：
nano  /etc/pacman.d/mirrors
## 清华大学
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
# nanoc编辑好文本后按trl + x 然后按y再按回车即可

添加archlinuxcn软件源： 
编辑nano  /etc/pacman.conf，在最下方添加：
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch

sudo pacman -Syyu　　　　　　　　#更新系统

# 更新软件源并导入公钥：
sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
```
##### 安装输入法
```shell
#我选择的是搜狗拼音输入法
sudo pacman -S fcitx-sogoupinyin
sudo pacman -S fcitx-im 
sudo pacman -S fcitx-configtool

#修改nano  ～/.profile，在最下方添加：
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
```

#### 其它软件
```shell
sudo pacman -S zsh git vim wget links lrzsz

sudo pacman -S electronic-wechat 　　　　　　　　　　#微信
sudo pacman -S netease-cloud-music 　　　　　　　　 #网易云音乐
sudo pacman -S pycharm 　　　　　　　　　　　　　　#代码编辑器（IDE）
sudo pacman -S python-pip　　　　　　　　　　　　　 #python用到的一个什么东西
```



