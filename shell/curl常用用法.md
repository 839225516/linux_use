#### curl 常用参数
    
    -v    小写的v参数，用于打印更多信息，包括发送的请求信息
    -k    允许不使用证书到SSL站点
    -d    HTTP POST方式传送数据
    -H    自定义头信息传递给服务器
    -o    小写o,把输出写到文件
    -O    大写O,下载网页文件，保留远程文件的文件
    -#    显示下载进度条
##### examples
```shell 
curl -v https://www.baidu.com 

#保存网页 
curl -v https://www.baidu.com > baidu.html
curl -o baidu.html  https://www.baidu.com

#下载文件
curl -o pic.JPG  http://test.com/pic.JPG
curl -O http://test.com/pic.JPG 

#循环下载, 下载pic1.JPG  pic2.JPG  ... pic5.JPG
curl -O http://test.com/pic[1-5].JPG

```



``` shell 
curl查看 网页的响应时间
# curl -o /dev/null -s -w "time_connect: %{time_connect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n"  url

返回码：
# curl -o /dev/null -s -w %{http_code} "www.qq.com"

网页或文件大小
# curl -o /dev/null -s -w %{size_header} url
```


查看外网出口的ip
```shell 
# curl -L tool.lu/ip
```

