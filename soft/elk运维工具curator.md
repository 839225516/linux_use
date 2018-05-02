curator是官方为定期的清除数据，合并 segment，备份恢复等工作开发的工具。

官方入口：

    https://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html

##### 安装curator  ####
###### 1.直接pip安装  ######
```shell 
# pip install elasticsearch-curator
```
###### 2.生产环境一般没有外网，可以用rpm包安装  ######
下载地址：

    Centos6: https://packages.elastic.co/curator/5/centos/6/Packages/elasticsearch-curator-5.5.1-1.x86_64.rpm
    Centos7: https://packages.elastic.co/curator/5/centos/7/Packages/elasticsearch-curator-5.5.1-1.x86_64.rpm

##### curator使用  ####
curator提供了两个interface： curator和curator_cli，curator_cli只支持一次运行一个action.

eg: curator_cli获取所有的index, close index
```shell 
# curator_cli --host 10.0.52.4 --port 9200 show_indices --verbose
# curator_cli --host 10.33.4.160 --port 9200 close --filter_list  \
  '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":1}, \
  {"filtertype":"pattern","kind":"prefix","value":"syslog-"}]'
```

curator 一般使用配置文件来调用：这里做一个保留40天index的任务
```yaml
# config.yml
client:
  hosts:
    - 10.0.52.4
  port: 9200
  url_prefix:
  use_ssl: False
  certificate:
  client_cert:
  client_key:
  ssl_no_validate: False
  http_auth:
  timeout: 30
  master_only: False

logging:
  loglevel: INFO
  logfile: /var/log/curator.log
  logformat: default
  blacklist: ['elasticsearch', 'urllib3']
```

action配置文件：
```yaml
# delete_index.yml
# action由三部分组成
# - action 具体执行的操作
# - option 配置哪些可选项
# - fiter 过滤条件，哪些index需要执行action,一般使用的filtertype是pattern和age

actions:
  # 这里的1是action id, 必须要有
  1:
    action: delete_indices
    description: "删除index前缀为posp_log_transaction_service_的大于40天的索引"                                                                                
    options:
      ignore_empty_list: True
      #disable_action: True
    filters:
    - filtertype: pattern
      kind: regex
      value: '^posp_log_transaction_service_.*$'
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 40
```

测试：
``` shell 
# curator --config /etc/curator/config.yml /etc/curator/delete_index.yml --dry-run
```

设置定时任务：
``` shell
# crontab -l
* 01 * * * /usr/bin/curator --config /etc/curator/config.yml /etc/curator/delete_index.yml
```





