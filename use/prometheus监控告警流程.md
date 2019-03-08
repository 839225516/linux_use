prometheus监控告警流程

##### 1. 监控采集、计算和告警
1) 监控采集    
```yaml
global:
  scrape_interval:     15s 
  evaluation_interval: 15s 

  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job=~"kubernetes-.*"}'
        #- '{__name__=~"job:.*"}'
    static_configs:
      - targets: ['10.3.16.10:30003']
```

    scrape_interval: 15s        数据采集间隔为15s
    evaluation_interval: 15s    告警规则计算周期，只有全局值，然后更新告警状态


三种告警状态：

    inactive        没有触发阈值
    pending         已触发阈值但末满足告警持续时间
    firing          已触发阈值且满足告警持续时间


2) 告警规则
```yaml
groups:
- name: ks_k8s_node.rules
  rules:
  - alert: k8s集群Node状态
    expr: kube_node_status_condition{condition="Ready",status!="true"} == 1
    for: 1m
    labels:
      severity: critical
      service: nodes
    annotations:
      summary: k8s集群节点故障
      description: ks_k8s_Node {{ $labels.node }} 节点状态错误
```
收集到的kube_node_status_condition{condition="Ready",status!="true"}!=1, 告警状态为inactive    
收集到的kube_node_status_condition{condition="Ready",status!="true"}==1，且持续时间小于1m，告警状态为pending     
收集到的kube_node_status_condition{condition="Ready",status!="true"}==1，且持续时间大于1m，告警状态为firing     

**配置中的for语法就是用来设置告警持续时间的；如果配置中不设置for或者设置为0，那么pending状态会被直接跳过**


    prometheus以15s一个采集频率采集数据；  
    然后根据采集到的数据按evaluation_interval: 15s 一个计算周期，计算表达式，表达式为真，告警状态切换到pending
    下个计算周期，表达式仍为真，且符合for: 1m(即持续了1分钟)，告警状态变更为active,并将告警从prometheus发送给alertmanager;
    下个计算周期表达式仍为真，且符合for持续1m，持续告警给alertmanager

##### 2. 告警分组、抑制和静默
alertmanager在收到告警时，并不是把接收到的告警简单的直接发送出去

    分组    group
    抑制    inhibitor
    静默    silencer

告警分组：同类告警合并，减少告警数量   
告警抑制：消除冗余的告警，相关联的告警链，只发最根本的那边告警，抑制多余的告警    
告警静默: 阻止发送可预期的告警


##### 3. 告警延时
提到了分组的概念，分组势必会带来延时；合理的配置延时，才能避免告警不及时的问题，同时帮助我们避免告警轰炸的问题    
告警延时的几个重要参数：

    group_by        分组参数
    group_wait      分组等待时间 eg: 5s
    group_interval  分组尝试再次发送告警的时间间隔  eg: 5m
    repeat_interval 分组内发送相同告警的时间间隔    eg: 60m


延时举例：   
```yaml
    group_wait: 5s
    group_interval: 5m
    repeat_interval: 60m
```
同组警告集A,有 a1,a2,a3; 另一组告警集B，有 b1,b2,b3;   

场景一：

    a1先到达告警系统，此时在group_wait: 5s的作用下，a1不会立刻告警出来；
    a2在5s内也触发，a1,a2会在5s后合并为一个分组，通过一个告警消息发出来；
    a1,a2持续末解决，它们会在repeat_interval: 60m的作用下，每隔一小时发送告警消息。

场景二：

    a1,a2持续末解决，中间又有新的同组的告警a3出现，此时在group_interval: 5m的作用下，由于同组状态发生变化，a1,a2,a3会在5分钟后发告警消息，不会被收敛60min（repeat_interval）的时间。
    a1,a2,a3如持续无变化，它们会在repeat_interval： 60m作用下，再次每隔一小时发送告警消息

场景三：

    a1,a2发生的过程中，发生了b1的告警，由于b1分组规则不在集合A中，所以b1遵循集合B的时间线；


