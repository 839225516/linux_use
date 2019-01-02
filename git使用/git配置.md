### git 配置

1. 全局设置
```shell
git config --global user.name  "onliny"
git config --global user.email "****@qq.com"

#永久记住密码
git config --global credential.helper store

##临时记住密码默认记住15分钟：
git config –global credential.helper cache

#自定义配置记住1小时：
git config credential.helper ‘cache –timeout=3600’
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
git remote add origin https://github.com/****/***.git
git push -u origin master
```

3. 更新远程代码到本地 git fetch   
fetch 更新本地仓库的两种方式
```shell 
# 从远程的origin仓库的master分支下载代码到本地的origin master
git fetch origin master

# 比较本地的仓库和远程参考的区别
git log -p master.. origin/master

# 把远程下载下来的代码合并到本地仓库，远程的和本地的合并
git merge origin/master

######################################### 
# 从远程的origin仓库的master分支下载到本地并新建一个分支temp
git fetch origin master:temp

# 比较master分支和temp分支的不同
git deff temp

# 合并master分支和temp分支的不同
git merge temp

# 删除temp
git branch -d temp
```
