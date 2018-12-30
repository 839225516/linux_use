### git 配置

1. 全局设置
```shell
git config --global user.name  "onliny"
git config --global user.email "****@qq.com"
```

2. 创建git仓库并提交到远程仓库
```shell
mkdir project
cd project
touch README.md
git add README.md 
git commit -m "第一次commit"
git remot add origin https://https://github.com/********/linux.git
git push -u origin master

### 对已有项目进行提交
cd ${existing_git_repo}
git remote add origiin https://github.com/****/***.git
git push -u origin master
```
