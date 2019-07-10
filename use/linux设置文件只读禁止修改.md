##### Linux文件保护禁止修改、删除、移动文件
chattr 命令：锁定文件，不能删除，不能更改
	
	+ ：在原有参数设定基础上，追加参数
	- ：在原有参数设定基础上，移除参数
	A：文件或目录的 atime (access time)不可被修改(modified)
	S：硬盘I/O同步选项，功能类似sync
	a：即append，设定该参数后，只能向文件中添加数据，而不能删除，多用于服务器日志文 件安全，只有root才能设定这个属性
	c：即compresse，设定文件是否经压缩后再存储。读取时需要经过自动解压操作
	d：即no dump，设定文件不能成为dump程序的备份目标
	i：设定文件不能被删除、改名、设定链接关系，同时不能写入或新增内容。i参数对于文件 系统的安全设置有很大帮助
	j：即journal，设定此参数使得当通过 mount参数：data=ordered 或者 data=writeback 挂 载的文件系统，文件在写入时会先被记录(在journal中)。如果filesystem被设定参数为 data=journal，则该参数自动失效
	s：保密性地删除文件或目录，即硬盘空间被全部收回
	u：与s相反，当设定为u时，数据内容其实还存在磁盘中，可以用于undeletion
	
```shell
# 加锁: 文件不能删除，不能更改，不能移动,root用户也不行
chattr +i  /etc/passwd

# 查看锁
lsattr /etc/passwd

# 解锁
chattr -i /etc/passwd
```	
