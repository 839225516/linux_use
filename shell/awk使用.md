### awk 使用


``` shell
#文件根据创建时间重命名
ls -l --full-time --time-style=+%y%m%d_%H%M log_[1-6]* |awk  '{cmd="mv "$7" "$7"-"$6;system(cmd)}'

# awk 使用shell变量，用 -v 自定义变量并赋值shell变
GIT_IP=10.150.148.254 
CI_PROJECT_URL=`echo "$CI_PROJECT_URL" | awk -v gitip=$GIT_IP -F"/" 'BEGIN{OFS="/"}{$3=gitip;print $0}'


```