## 使用filebeat和logstash收集日志 ##

elk的另一种用法： 

    filebeat -> redis -> logstash -> logfile
filebeat 采集各服务的日志文件，输出到redis; logstash从redis取日志信息，输出到各日志文件，达到集中式管理日志的目的。

filebeat端配置文件：filebeat.yml
``` yaml 
filebeat.prospectors:
- input_type: log
  paths:
    - /data/java_service/logs/cash-web.log
  multiline.pattern: ^\[
  multiline.negate: true
  multiline.match: after
  document_type: cashOut
  tags: cashOut
  
#output.logstash:
#  hosts: ["10.0.52.6:5044"]

output.redis:
  enable: true
  hosts: "10.0.52.6"
  port: 6379
  key: "logstash:redis"
  datatype: list
  db: 0
  passwd: "***"

```
参数解释：

    datatype: 队列list 或 channel 发布订阅
    key: list或者channel模式，key都是指定的键值
    db: Redis里面有数据库的概念，一般是16个，默认登录后是0


logstash 端配置：logfile.yml
``` yaml
input {
#    beats {
#        port => 5044
#    }

    redis {
        host => "10.0.52.6"
        port => 6379
        data_type => "list"
        key => "logstash:redis"
        threads => 1
    }
}

output {
    if [type] == "openapiQrcodeApi" {
        if [beat][hostname] == "reg_33.mpos.kx.com" {
            file {
                path            => "/home/trade/static_qrcode/10.0.117.33/openapiQrcodeApi_%{+yyyy-MM-dd}.log"
                codec => line { format => "%{message}"}
                flush_interval  => 0
            }
        } else if [beat][hostname] == "devops10011734" {
            file {
                path            => "/home/trade/static_qrcode/10.0.117.34/openapiQrcodeApi_%{+yyyy-MM-dd}.log"
                codec => line { format => "%{message}"}
                flush_interval  => 0
            }
        } 

    }  else if [type] == "cashOut" {
       if [beat][hostname] == "004.risk.mpay.dc.com"{ 
            file {
                path            => "/home/trade/cashOut/10.0.25.4/cash-web_%{+yyyy-MM-dd}.log"
                codec => line { format => "%{message}"}
                flush_interval  => 0
            }
        }
 
    } else {
        #stdout{}    
    }
} 

```
参数说明：
  
    threads: 启用线程数量
    
    
