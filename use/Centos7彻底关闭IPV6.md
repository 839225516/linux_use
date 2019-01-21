##### 查看系统版本
```shell
cat /etc/redhalt-release
```

编辑/etc/default/grub, 在GRUB_CMDLINE_LINUX的句首加上ipv6.disable=1   
```conf
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=0
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rd.lvm.lv=centos/root rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
```
修改完毕后保存，运行grub2-mkconfig -o /boot/grub2/grub.cfg重新生成grub.cfg文件
```shell
grub2-mkconfig -o /boot/grub2/grub.cfg
reboot
```