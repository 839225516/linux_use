
```shell
忘记了用sudo命令，!!表示上一条命令
# sudo !! 

查看挂载的文件系统
# mount | column -t

查看命令使用频率
# history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head

查看系统位数
# getconf LONG_BIT

排除删除
# rm !(*.foo|*.bar|*.baz)

查看程序占用端口
# lsof -P -i -n |grep 80

# lsof -Pan -i tcp -i udp


通过80端口共享文件
# nc -v -l 80 < file.ext

# 按时间范围查找文件
find . -type f -newermt "2010-01-01" ! -newermt "2010-06-01"

find . -type f -newermt "3 years ago" ! -newermt "2 years ago"

find . -type f -newermt "last monday"


列出活动的网络连接数和类型
# netstat -ant | awk '{print $NF}' | grep -v '[a-z]' | sort | uniq -c

查看passwd
# column -ts: /etc/passwd

监听网口，显示与主机通信的ip
# tcpdump -i wlan0 -n ip | awk '{ print gensub(/(.*)\..*/,"\\1","g",$3), $4, gensub(/(.*)\..*/,"\\1","g",$5) }' | awk -F " > " '{print $1"\n"$2}'

查看dmesg 
# dmesg -T|sed -e 's|\(^.*'`date +%Y`']\)\(.*\)|\x1b[0;34m\1\x1b[0m - \2|g'

vim 删除所有空行
# :g/^$/d

netstat -plantu
-p 显示建立相关链接的程序名
-l 仅列出有在 Listen (监听) 的服務状态
-n 拒绝显示别名，能显示数字的全部转化成数字
-a (all)显示所有选项，默认不显示LISTEN相关
-t (tcp)仅显示tcp相关选项
-u (udp)仅显示udp相关选项

-r 显示路由信息，路由表
-e 显示扩展信息，例如uid等
-s 按各个协议进行统计
-c 每隔一个固定时间，执行该netstat命令


ps -eo pid,lstart,etime,cmd

dns 查询
# dig baidu.com @172.20.11.246

# nslookup qq.com 172.20.11.246


清理内存缓存
sync && echo 1 > /proc/sys/vm/drop_caches  
sync && echo 2 > /proc/sys/vm/drop_caches  
sync && echo 3 > /proc/sys/vm/drop_caches


curl查看 网页的响应时间
# curl -o /dev/null -s -w "time_connect: %{time_connect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n"  url

返回码：
# curl -o /dev/null -s -w %{http_code} "www.qq.com"

网页或文件大小
# curl -o /dev/null -s -w %{size_header} url


# ls只看当前目录的文件，不看文件夹
ls -al | grep '^-'


linux/unix下的回车符是'0d',而在windows下侧是'0d0a'
^M 可以用 dos2unix 命令 去除：
dos2unix filename

不影响使用，是因为windows换行符使用 \r\n 而 Linux使用的是 \n 导致的换行符问题，可以使用tr进行去除
cat yourfile | tr -s "\r\n" "\n" > newfile

--stdin 修改密码，非交互修改密码
# echo passwd | passwd --stdin username



```