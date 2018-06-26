#### Java 服务内存异常排查

Java服务常见的两种异常：

    java.lang.OutOfMemoryError: PermGen space
    java.lang.OutOfMemoryError: Java heap space

要详细解释这两种异常，需要简单重提下Java内存模型：  
在Java虚拟机中，内存分为三个代：新生代（New）、老生代（Old）、永久代（Perm）

    新生代New：新建的对象都存放这里
    老生代Old：存放从新生代New中迁移过来的生命周期较久的对象。新生代New和老生代Old共同组成了堆内存
    永久代Perm：是非堆内存的组成部分。主要存放加载的Class类级对象如class本身，method，field等等

> 如果出现java.lang.OutOfMemoryError: Java heap space 异常，说明Java虚拟机的堆内存不够。原因有二：

    （1）Java虚拟机的堆内存设置不够，可以通过参数-Xms、-Xmx来调整。
    （2）代码中创建了大量大对象，并且长时间不能被垃圾收集器收集（存在被引用）。


> 如果出现java.lang.OutOfMemoryError: PermGen space，说明是Java虚拟机对永久代Perm内存设置不够  
一般出现这种情况，都是程序启动需要加载大量的第三方jar包。例如：在一个Tomcat下部署了太多的应用

##### 排查方法
top 查看进程 PID

用ps命令，看能否找到具体是哪个线程
> ps -mp {PID} -o THREAD,tid,time,rss,size,%mem

发现，PS命令可以查到具体进程的CPU占用情况，但是不能查到一个进程下具体线程的内存占用情况


导出整个JVM中的内存信息，然后利用MAT工具分析是否存在内存泄漏
> jmap -dump:live,format=b,file=xxx.xxx {PID}


查看整个JVM的内存状态,要注意的是在使用CMS GC 情况下，jmap -heap的执行有可能会导致JAVA 进程挂起
> jmap -heap {PID}


查看JVM堆中对象详细占用情况
> jmap -histo {PID}

jstack 是sun JDK自带的工具，通过该工具可以看到JVM中线程运行状况，包括锁等待，线程是否在运行
> jstack {PID}


最后，总结下排查内存故障的方法和技巧有哪些：

    1.top命令：Linux命令。可以查看实时的内存使用情况。  
    2.jmap -histo:live [pid]，然后分析具体的对象数目和占用内存大小，从而定位代码。
    3.jmap -dump:live,format=b,file=xxx.xxx [pid]，然后利用MAT工具分析是否存在内存泄漏等等

