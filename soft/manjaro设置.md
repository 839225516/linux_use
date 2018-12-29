### Manjaro 安装及配置
#### 配置相关pacman源
```shell
# 将本地数据包与远程数据包同步
sudo pacman -Syy

# 安装vim
sudo pacman -S vim


#更换软件源：
sudo vim  /etc/pacman.d/mirrors
## 清华大学
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch


# 添加archlinxCN源
sudo vim /etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server =https://mirrors.ustc.edu.cn/archlinuxcn/$arch

sudo pacman -Syyu　　　　　　　　#更新系统

# 更新软件源并导入公钥：
sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
```

#### 安装 zsh
```shell 
sudo pacman -S git
sudo pacman -S zsh

# 配置oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# 更换默认的shell
chsh -s /bin/zsh

```

##### 安装输入法
```shell
#我选择的是搜狗拼音输入法
sudo pacman -S fcitx-sogoupinyin
sudo pacman -S fcitx-im         # 全部安装
sudo pacman -S fcitx-configtool # 图形化配置工具

#修改vim  ～/.profile，在最下方添加：
exportGTK_IM_MODULE=fcitx
exportQT_IM_MODULE=fcitx
exportXMODIFIERS="@im=fcitx"
```

#### 其它软件
```shell
sudo pacman -S  wget links lrzsz

sudo pacman -S electronic-wechat 　　　　　　　　　　#微信
sudo pacman -S netease-cloud-music 　　　　　　　　 #网易云音乐
sudo pacman -S pycharm 　　　　　　　　　　　　　　#代码编辑器（IDE）
sudo pacman -S python-pip　　　　　　　　　　　　　 #python用到的一个什么东西
pacman -S visual-studio-code-bin                # vs code
```



