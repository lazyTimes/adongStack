# Mysql专栏 - 线上调优与压力测试

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210829154044.png)

# 前言

​	本节内容讲述线上的调优手段以及压力测试的相关工具，结合一些实际的命令参数，我们将会介绍运行结果的具体含义。本节内容为大致的介绍如何压力测试和如何阅读参数，具体的运行效果需要自己部署一台机器测试，关于这部分的内容受到不同的机器影响会出现完全不同的效果，需要实际测试所以没有进行记录。

​	

# 概述

1. 介绍常见的mysql系统性能分析指标，介绍吞吐量和机器的选择
2. 压力测试工具的介绍，以及数据库压力测试的实战。
3. 最后将会根据Linux系统的命令介绍如何阅读mysql服务器的性能
4. 简单介绍Prometheus和Grafana 两个系统。

​	

# 系统指标分析

## 小型系统：

​	小型并发系统不需要考虑其他条件，因为那种系统可能每隔几分钟才会有一波请求发到数据库上去，而且数据库里一张表也许就几百条、几千条或者几万条数据，数据量很小，并发量很小，操作频率很低，用户量很小，并发量很小，只不过可能系统的业务逻辑很复杂而已，对于这类系统的数据库机器选型，就不在我们的考虑范围之内了。



## 通常选择: 

​	大多数情况下一般8核16G的机器部署的MySQL数据库，每秒抗个一两千并发请求是没问题的，但是如果并发量再高一些，假设每秒有几千并发请求，那么可能数据库就会有点危险了，因为数据库的**CPU、磁盘、IO、内存**的负载都会很高，数据库压力过大就会宕机。



## 吞吐量：

​	如果一个系统处理一个mysql请求需要1s，那么一分钟可能只处理100个请求，4核8G的机器部署普通的Java应用系统，通常每秒大致就是抗下几百的并发访问，但是同一个配置的机器可以从每秒一两百请求到每秒七八百请求都是有可能的，关键是看你每个请求处理需要耗费多长时间。

 

## 固态硬盘

​	因为数据库最大的复杂就在于**大量的磁盘IO**，他需要大量的读写磁盘文件，所以如果能使用SSD固态硬盘，那么你的数据库每秒能抗的并发请求量就会更高一些。

 

# 数据库压力测试

​	有了数据库之后，第一件事就是做压力测试：

## 什么是qps，什么是tps？

​	压测数据库，每秒能扛下多少请求，每秒会有多少请求，如果要判定性能可以通过下面的指标：

​	**Qps:全称是 `query per second`**，意味着数据库每秒可以处理多少个请求，一个请求就是一个sql语句，在mysql中意味着一秒可以处理多少个sql语句。

​	**Tps全程是 `transaction per second`**，Tps是用来衡量一个数据库每秒完成事务的数量，有一些人会把tps理解为数据库的每秒钟请求多数量，但是不太严谨。 

​	每秒可以处理的事务量，这个数据用在数据库内部中用的比较多，意味着数据库每秒会执行多少次事务提交或者回滚。

 

## Io的性能指标

​	关注的io相关性能指标，大家也要跟他做一个了解：

​	(1) **IOPS**：这个指的是机器的随机IO并发处理的能力，比如机器可以达到200 IOPS，意思就是说每秒可以执行200个随机 IO读写请求。

​	(2) **吞吐量**：这个指的是机器的磁盘存储**每秒可以读写多少字节的数据量**

​    (3) **latency**：这个指标说的是往磁盘里写入一条数据的延迟。

​	通常情况下一个普通磁盘的顺序写入都是可以到达200mb的请求上，通常而言，磁盘吞吐量都可以到200mb

 	通常情况下一块硬盘的读写延迟越低，数据库的性能就越高，执行sql和事务的速度就会越快。

 

## 压力测试的其他性能指标

1. **cpu负载**：是一个重要的性能指标，假设数据库压测到了3000了，但是cpu负载已经满了，也就意味着它最多只能 处理这么多数据了。
  2. **网络负载：**压测到一定的qps或者tps的时候，每秒钟都机器网卡都输入多少mb数据，输出多少mb数据，qps1000的时候，网络负载打满了，每秒传输100mb到达上限也是无法压力测试的。
  3. **内存负载**：机器的耗费到了极限也是不能压力测试的。

 

> 给你一台4核8G的机器，他可以扛住每秒几千甚至每秒几万的并发请求吗? 
>
> ​	扛下多少请求，需要看实际的cpu，硬盘，内存，网络带宽等环境。一台机器扛下500+的请求已经很高了，如果每秒1000+请求，基本负载会打满。机器有可能挂掉。同时此时的内存也基本打满了，同时jvm的gc频率可能会非常高。

 

# 压力测试工具介绍

​	使用压力测试的工具是：**sysbench**工具

## 安装教程：

安装教程如下：

```mysql
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash 
sudo yum -y install sysbench
sysbench --version 
```

# 数据库压测实战

下面是一个案例的指令，可以在使用的时候边运行结果对比了解：

```mysql
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_read_write --db-ps-mode=disable prepare
```

我们分别来介绍参数的内容：

```mysql
--db-driver=mysql:这个很简单，就是说他基于mysql的驱动去连接mysql数据库，你要是oracle，或者sqlserver，那 自然就是其他的数据库的驱动了 
--time=300:这个就是说连续访问300秒--threads=10:这个就是说用10个线程模拟并发访 问
--report-interval=1:这个就是说每隔1秒输出一下压测情况
--mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=test_user --mysql-password=test_user:连接到哪台机器的哪个端口上的MySQL库，他的用户名和密码是什么
--mysql-db=test_db --tables=20 --table_size=1000000:这一串的意思，就是说在test_db这个库里，构造20个测试 表，每个测试表里构造100万条测试数据，测试表的名字会是类似于sbtest1，sbtest2这个样子的 oltp_read_write:这个就是说，执行oltp数据库的读写测试
--db-ps-mode=disable:这个就是禁止ps模式
--prepare 这个参数会按照设置构建测试需要的数据，自动创建20个表，每个表100万数据。
```

 

## 全方位测试

​	测试数据库的综合读写TPS，使用的是oltp_read_write模式(大家看命令中最后不是prepare，是run了，就是运行压测)：

```mysql
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_read_write --db-ps-mode=disable run
```

​	测试数据库的只读性能，使用的是oltp_read_only模式(大家看命令中的oltp_read_write已经变为oltp_read_only了)：

```mysql
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_read_only --db-ps-mode=disable run
```

​	测试数据库的删除性能，使用的是oltp_delete模式:

```java
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 --table_size=1000000 oltp_delete --db-ps-mode=disable run
```

​	使用上面的命令，sysbench工具会根据你的指令构造出各种各样的SQL语句去更新或者查询你的20张测试表里的数据，同时 监测出你的数据库的压测性能指标，最后完成压测之后，可以执行下面的cleanup命令清理数据：

```mysql
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_read_write --db-ps-mode=disable cleanup
```

​	测试数据库的更新索引字段的性能，使用的是oltp_update_index模式:

 ```mysql
 sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_update_index --db-ps-mode=disable run
 ```

​	测试数据库的更新非索引字段的性能，使用的是oltp_update_non_index模式:

 ```mysql
 sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_update_non_index --db-ps-mode=disable run
 ```

​	测试数据库的更新非索引字段的性能，使用的是oltp_update_non_index模式:

```mysql
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_update_non_index --db-ps-mode=disable run
```

​	测试数据库的插入性能，使用的是oltp_insert模式:

 ```mysql
 sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_insert --db-ps-mode=disable run
 ```

​	测试数据库的写入性能，使用的是oltp_write_only模式:

 ```mysql
 sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_write_only --db-ps-mode=disable run
 ```

​	最后完成压测之后，可以执行下面的**cleanup**命令清理数据：

```mysql
sysbench --db-driver=mysql --time=300 --threads=10 --report-interval=1 --mysql-host=127.0.0.1 --mysqlport=3306 --mysql-user=test_user --mysql-password=test_user --mysql-db=test_db --tables=20 -table_size=1000000 oltp_read_write --db-ps-mode=disable cleanup
```



## 测试结果分析

​	下面是一个sysbench的运行结果：

```mysql
[22s] thds: 10 tps: 380.99 qps: 7312.66 (r/w/o: 5132.99/1155.86/1321.35) lat (ms, 95%): 21.33 err/s: 0.00 reconn/s: 0.00
```



### 分析：

​	上面说的是第`22s`发生的事情，以及其他字段分别代表的含义：

 ```java
 Tdhs: 表示10个线程
 Tps: 每秒执行了380个事务
 Qps: 每秒执行了7312个请求
 (r/w/o)…: 这一段内容表示7312.66个请求当中，有5132.99个是读请求。1155.86是写请求，1321个其他类型的请求。其实就是对整个qpsj你想拆分
 Lat(ms, 95%): 意思是说，95%延迟在21.33毫秒以下
 Err/s：每秒0个失败，发生了0次网络重连。
 ```

 

### 压测报告的解释

​	根据上面的压测命令在结果的最后是压测的整个报告，关于报告的内容其解释如下：

```mysql
SQL statistics:queries performed:

  read: 1480084 
  // 这就是说在300s的压测期间执行了148万多次的读请求 write: 298457 
  // 这是说在压测期间执行了29万多次的写请求

  other: 325436 
  // 这是说在压测期间执行了30万多次的其他请求

  total: 2103977 // 这是说一共执行了210万多次的请求
  // 这是说一共执行了10万多个事务，每秒执行350多个事务 transactions: 105180( 350.6 per sec. )
  // 这是说一共执行了210万多次的请求，每秒执行7000+请求 queries: 2103977 ( 7013.26 per sec. )

  ignored errors: 0 (0.00 per sec.) reconnects: 0 (0.00 per sec.)
  // 下面就是说，一共执行了300s的压测，执行了10万+的事务 General staticstics:

total time: 300.0052s

total number of events: 105180

Latency (ms):

  min: 4.32 
  // 请求中延迟最小的是4.32ms

  avg: 13.42 
  // 所有请求平均延迟是13.42ms

  max: 45.56 
  // 延迟最大的请求是45.56ms

	95th percentile: 21.33 
	// 95%的请求延迟都在21.33ms以内
```

​	其实压测就是用命令观察对应的情况**用增加线程的手段试探机器的极限**，另外一个就是通过linux的相关命令查看是否是正常情况。



# 命令查看压力测试性能：

## Top：

​	top命令最直观展示cpu负载的，在linux执行top指令，我们可以看到下面的内容：

```shell
top 15:52:00 up 42:35, 1 user, load average: 0.15, 0.05, 0.01	
```

​	下面是关于上面的结果内容展示：

```mysql
这里指的是系统运行了42:35分钟，15:52指的是当前的时间，
1 user就是一个用户在使用
Load averatge 0.15, 0.05, 0.01 表示的则是cpu在 1分钟， 5分钟，15分钟的负载情况,假设一个4核心的cpu，负载时0.15，就是说4个核心一个核心都没用满。如果你的负载是1，说明4核有一个比较忙了
```

​	测时如何观察机器的内存负载情况?

+ Mem: 33554432k total, 20971520k used, 12268339 free, 307200k buffers
+ Top命令最后的内容是如下，总内存有32gb，已经使用了20gb，还有10多个是空闲的。

 

## 如何看磁盘io

​	使用`dstat -d`命令，会看到如下的东西:

 ```mysql
 -dsk/total read writ 103k 211k
 0 11 
 ```

​	在硬件的一定合理的负载范围内，把数据库的QPS提高到最大，这就是数据库压测的时候最合理的一个极限QPS值。

 

# Prometheus和Grafana 两个系统

​	这两个系统请自行百度查阅了解和学习：

​	`prometheus`：是一个监控数据采集和存储系统，可以看作是定期从mysql中采集需要的监控数据。

​	`granfana`：适用于和`prometheus`进行辅助组合使用的，可以对于mysql进行一个可视化的监控动作。



# 思考题：

1. 假设开发的Java系统部署在一台4核8G的机器上，那么我们假设这个Java系统处理一个请求非常非常快，每个请求只需要0.01ms就可以处理完了，那你觉得这一台机器部署的Java系统，可以实现每秒抗下几千并发 请求吗?可以实现每秒抗下几万并发请求吗?

> 答案来源：[MySQL： 5 生产环境下的数据库机器配置_136.la](https://www.136.la/nginx/show-136024.html)
>
> **答：**每个请求处理0.01ms，应该是不涉及磁盘的纯内存操作
>
> 在4核8G的机器上，也就是同时有4个线程数为最佳，多了反而会由于竞态问题导致频繁上下文切换，浪费性能。
>
> **理论上的并发请求数量**
>
> 这里按照数据库使用3个线程，另一个CPU核心线程给其他进程使用。
>
> 在不考虑网卡资源的情况下，理论上可以实现每秒 3 * 1s/0.01ms = 30万请求。
>
> **生产环境下的影响因素**
>
> 在真实生产环境下，还需要考虑很多的因素。生产环境必然不只是有4个线程在工作，那么就导致会存在CPU线程竞态切换的时间；当并发量高的时候还要算下内存消耗发生YGC和Full GC的STW时间也算进去；当并发很高，对CPU负载也很高，处理会变慢，此时TPS会很长。还有磁盘IO、网卡等因素也需要考虑进去。
>
> 此时，按照均值每**个请求所需要的耗时可能达到100ms左右**。



2. 关于QPS和TPS的。如果一个交易系统拆分为了很多服务，那么每个服务每秒接收的 并发请求是QPS还是TPS呢?

> 这个明显是QPS，因为每个服务就负责干自己的一些事儿，其实对他来说，每秒并发请求数量就是QPS。



# 总结

​	本次我们从简单的系统测试入手，介绍了影响mysql服务的指标，其实影响一个mysql服务性能的参数有很多，包括内存，处理器，io性能，网络带宽都有影响，所以不能完全按照理性化的配置去猜测数据库能承受多少压力，而是要根据压力测试对于数据库进行实际的压测之后，通过增加压力的方式找到mysql服务器的压力极限，最后通过两个思考题我们可以看到衡量一个mysql的性能需要从多方面考虑，哪怕是理想情况下能够处理的请求其实也不是很多。



# 写在最后

​	本文介绍的内容较为基础和简单，希望可以通过这篇文章引发更多关于mysql性能的思考。	

 

 