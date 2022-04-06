# redis学习笔记

[TOC]



## 推荐干货：

### 干货公众号文章

https://mp.weixin.qq.com/s?__biz=MzI1MzYzMTI2Ng==&mid=2247484439&idx=1&sn=2b1199ccb150c99b4efea45e2a5f49d5&chksm=e9d0ca5adea7434cb5f525a53fe258180fe70a48c649cc2939bcc5a71d9e786c224a84ab5558&mpshare=1&scene=1&srcid=11261zpS7iRS0EYMSpJPQbMI&sharer_sharetime=1606565535598&sharer_shareid=582fee21e05fb5c423a5e552ae7e1344&key=53cf22547bdcb3eabe168c284713387e23b74ef892a7a3f4fe3d4d65641657c2900e23df4bdc82dad9950e574bc23382a5e8990413ae977294493c00d0b43f3df5dd6f2b79e3282e14a83fb104b61689b58caaffc59476c1176c208e855f317bfd1bf66e97572bae83ab482f751025fbb2386b0f5e8bc2a1362e53b47288dc49&ascene=1&uin=MzM5MTE2NjA3OQ%3D%3D&devicetype=Windows+10+x64&version=6300002f&lang=zh_CN&exportkey=AzGeRfqsKpkUqOG%2FwPCO1TE%3D&pass_ticket=gnXjRaRFaXbSP2BlXLf9iM5RyS73uA5Tec1khFQJhc2cY5%2BofpWyn6FBOoY%2FXsGa&wx_header=0

### 《redis设计与实现》

http://redisbook.com/index.html

### redis持久化的扩展：

https://dbaplus.cn/news-158-1528-1.html

### 数据设计影响持久化：

https://szthanatos.github.io/topic/redis/improve-01/

### Redis基本操作——List（原理篇）

https://my.oschina.net/guodingding/blog/840018

# redis的基本介绍

Redis 是一个开源（BSD许可）的，内存中的数据结构存储系统，它可以用作**数据库**、**缓存**和**消息中间件**。 它支持**多种类型**的数据结构，如 [字符串（strings）](http://www.redis.cn/topics/data-types-intro.html#strings)， [散列（hashes）](http://www.redis.cn/topics/data-types-intro.html#hashes)， [列表（lists）](http://www.redis.cn/topics/data-types-intro.html#lists)， [集合（sets）](http://www.redis.cn/topics/data-types-intro.html#sets)， [有序集合（sorted sets）](http://www.redis.cn/topics/data-types-intro.html#sorted-sets) 与范围查询， [bitmaps](http://www.redis.cn/topics/data-types-intro.html#bitmaps)， [hyperloglogs](http://www.redis.cn/topics/data-types-intro.html#hyperloglogs) 和 [地理空间（geospatial）](http://www.redis.cn/commands/geoadd.html) 索引半径查询。 Redis 内置了 [复制（replication）](http://www.redis.cn/topics/replication.html)，[LUA脚本（Lua scripting）](http://www.redis.cn/commands/eval.html)， [LRU驱动事件（LRU eviction）](http://www.redis.cn/topics/lru-cache.html)，[事务（transactions）](http://www.redis.cn/topics/transactions.html) 和不同级别的 [磁盘持久化（persistence）](http://www.redis.cn/topics/persistence.html)， 并通过 [Redis哨兵（Sentinel）](http://www.redis.cn/topics/sentinel.html)和自动 [分区（Cluster）](http://www.redis.cn/topics/cluster-tutorial.html)提供高可用性（high availability）。

## 入门地址：

https://redis.io/

https://redis.io/commands

https://redis.io/clients

https://redis.io/documentation



# redis Linux安装(6.0.9版本)

## 前置条件

```shell
# 下载c和c++依赖 gcc环境，建议用最新版，redis有gcc版本要求
$ gcc：yum install gcc-c++
```



## 1.前往官网下载tar.gz包

```shell
$ wget https://download.redis.io/releases/redis-6.0.9.tar.gz
$ tar xzf redis-6.0.9.tar.gz
```

## 2. 编译redis安装

```shell
$ cd redis-6.0.9
$ make
$ make install
```



## 3.后端模式启动

```shell
vi redis.conf
找到 daemon-mode: no 改为 yes
redis默认使用6379端口
```

## 4. redis 允许远程访问

找到`redis.conf`

`protected-xxx: yes` 改为`no`

bind 127.0.0.1 默认绑定本地端口，这里去除掉，让redis绑定默认的公网IP

这两步骤开启之后意味着所有人都可以访问，注意保存重启即可

> 真实项目最好给redis设置密码，特别是读写用的主服务器

## 5. 常见问题

### 安装报错1：

> 如果出现安装redis-6.0.1到Linux报错server.c:xxxx:xx: error: ‘xxxxxxxx’ has no member named ‘xxxxx’
>
> https://blog.csdn.net/AJ_007/article/details/106316033?utm_medium=distribute.pc_feed_404.none-task-blog-BlogCommendFromBaidu-1.nonecase&depth_1-utm_source=distribute.pc_feed_404.none-task-blog-BlogCommendFromBaidu-1.nonecas

### 为什么不推荐Redis安装在windows上面？

1. redis在进行持久化的时候需要**fork 创建子进程**，而window不支持所以忽略
2. 建议使用微软提供的redis移植包或者使用`visual Studio`进行编辑安装redis
3. 真实业务不可能会将服务器放置到windows上！！！



# redis-Beanchmark 学习和使用

```shell
[root@izwz99gyct1a1rh6iblyucz bin]# ./redis-benchmark -h 127.0.0.1 -p 6379 -t set, lpush -n 10000 -q
====== lpush -n 10000 -q ======
  100000 requests completed in 1.01 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1
  host configuration "save": 900 1 300 10 60 10000
  host configuration "appendonly": no
  multi-thread: no

0.00% <= 0.2 milliseconds
21.79% <= 0.3 milliseconds
63.35% <= 0.4 milliseconds
96.20% <= 0.5 milliseconds
97.52% <= 0.6 milliseconds
98.15% <= 0.7 milliseconds
99.03% <= 0.8 milliseconds
99.62% <= 0.9 milliseconds
99.70% <= 1.0 milliseconds
99.76% <= 1.1 milliseconds
99.81% <= 1.2 milliseconds
99.83% <= 1.3 milliseconds
99.85% <= 1.4 milliseconds
99.86% <= 1.5 milliseconds
99.89% <= 1.6 milliseconds
99.93% <= 1.7 milliseconds
99.95% <= 5 milliseconds
99.98% <= 6 milliseconds
100.00% <= 6 milliseconds
99304.87 requests per second

```

## redis-Beanchmark 运行参数解释

|      |           |                                            |           |
| :--- | :-------- | :----------------------------------------- | :-------- |
| 序号 | 选项      | 描述                                       | 默认值    |
| 1    | **-h**    | 指定服务器主机名                           | 127.0.0.1 |
| 2    | **-p**    | 指定服务器端口                             | 6379      |
| 3    | **-s**    | 指定服务器 socket                          |           |
| 4    | **-c**    | 指定并发连接数                             | 50        |
| 5    | **-n**    | 指定请求数                                 | 10000     |
| 6    | **-d**    | 以字节的形式指定 SET/GET 值的数据大小      | 2         |
| 7    | **-k**    | 1=keep alive 0=reconnect                   | 1         |
| 8    | **-r**    | SET/GET/INCR 使用随机 key, SADD 使用随机值 |           |
| 9    | **-P**    | 通过管道传输 <numreq> 请求                 | 1         |
| 10   | **-q**    | 强制退出 redis。仅显示 query/sec 值        |           |
| 11   | **--csv** | 以 CSV 格式输出                            |           |
| 12   | **-l**    | 生成循环，永久执行测试                     |           |
| 13   | **-t**    | 仅运行以逗号分隔的测试命令列表。           |           |
| 14   | **-I**    | Idle 模式。仅打开 N 个 idle 连接并等待。   |           |

# redis基础知识

## 为什么redis有16个数据库，同时数量是16？

最佳答案：http://share.wukongwenda.cn/answer/6771041849399312647/

1. 可以理解为是**命名空间**
2. 为什么要支持多数据库
   1. 对于数据进行隔离，同时因为是key-value存储，要保证Key不会冲突
   2. 隔离并不是完全的隔离

Redis是一个字典结构的存储服务器，一个Redis实例提供了多个用来存储数据的字典，客户端可以指定将数据存储在哪个字典中。这与在一个关系数据库实例中可以创建多个数据库类似（如下图所示），所以可以将其中的每个字典都理解成一个独立的数据库。

默认数据库：

redis 默认有16个数据库，默认连接为0数据库

默认使用1数据库

> 如何修改默认的16个库？
>
> `redis/redis.conf` 里面可以配置
>
> `database: 16`
>
> 可以改为想要的大小

> 如何清空redis库里面的所有数据
>
> `FLUSHALL`命令可以清空一个Redis实例中所有数据库中的数据



## Redis4.0之前为什么使用单线程模式：





## 常用的基础命令

更多命令学习：http://www.redis.cn/commands.html

| 命令                                                       | 参数                                                         | 案例                                      | 命令作用                                                     | 复杂度 |
| ---------------------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------- | ------------------------------------------------------------ | ------ |
| SELECT [index]                                             | [index]：数据库下标                                          | SELECT 3                                  | 切换redis数据库                                              | O(1)   |
| DBSIZE                                                     |                                                              | DBSIZE                                    | 查看数据库大小                                               | O(1)   |
| KEYS [*]                                                   | [*]：代表当前所有Key                                         | KEYS *                                    | 查看当前redis所有key                                         | O(N)   |
| FLUSHALL                                                   |                                                              | FLUSHALL                                  | 清空当前所有的key                                            | O(1)   |
| FLUSHDB                                                    |                                                              | FLUSHDB                                   | 清空当前选中的数据库                                         | O(N)   |
| EXISTS [key]                                               | [key]：键是否存在                                            | EXISTS "key1"                             | 判断某个键是否存在                                           | O(1)   |
| MOVE [key] [index]                                         | [key]：Key，[index]：数据库                                  | MOVE"key1" 4                              | 移动key到指定的数据库                                        | O(1)   |
| EXPIRE [key] [time]                                        | [key]：Key，[time]：过期时间（秒）                           | EXPIRE name 10                            | 设置Key的过期时间                                            | O(1)   |
| TTL [key]                                                  | [key]：Key                                                   | TTL key1                                  | 检查key的过期时间                                            | O(1)   |
| TYPE [key]                                                 | [key]：Key                                                   | TYPE key1                                 | 查看当前key的数据类型                                        | O(1)   |
| INCR [key1]                                                | [key]：值为整型的Key                                         | INCR "key1" 1                             | 原子自增 1                                                   | O(1)   |
| DESC [key1]                                                | [key]：值为整型的Key                                         | DESC "key1" 1                             | 原子自减1                                                    | O(1)   |
| INCRBY [key1] [increment]                                  | [key]：值为整型的Key， [increment]： 步长，可以为负数        | INCRBY key1 5                             | 按照指定步长进行原子的自增                                   | O(1)   |
| DECRBY [key1] [increment]                                  | [key]：值为整型的Key， [increment]： 步长，可以为负数        | DECRBY key1 5                             | 按照指定步长进行原子的自减                                   | O(1)   |
| GET [key]                                                  | [key]：Key                                                   | GET "key1"                                | 获取当前key的值                                              | O(1)   |
| SET  [key] [value] [EX seconds] [PX milliseconds] [NX\|XX] | EX seconds –  设置键key的过期时间，单位时秒     PX milliseconds – 设置键key的过期时间，单位时毫秒     NX – 只有键key不存在的时候才会设置key的值     XX – 只有键key存在的时候才会设置key的值 | SET key1 value1 NX     SET key2 value2 xx | 设置当前的key的指定值                                        | O(1)   |
| SETEX [key] [expire] [value]                               | [key]：key      [expire]：过期时间      [value]：值          | SETEX key2 10 value2                      | 设置key对应字符串value，并且设置key在给定的seconds时间之后超时过期 | O(1)   |



## redis为什么是单线程？

redis是用c语言写的，不比 `Memcache`差

redis是很快的，基于内存操作，CPU不是性能瓶颈，redis是根据机器内存和网络带宽，既可以使用单线程，就使用单线程

误区1：高性能服务器一定是多线程？

误区2：多线程一定比单线程快？

CPU>内存>硬盘

核心：redis的全部数据放在内存中，读写是很快的。而多线程的环境需要CPU上下文的切换，单线程+内存的读写是不需要上下文切换的，效率非常高。

## 基础的数据类型：

## 五种基础类型：

一共是下面五种

1. string
2. hash
3. set
4. list
5. zset

在redis3.0版本之后陆续增加了几种特殊的类型

1. geospatial
2. bitmap
3. hyperloglog









#### 常用命令

| 命令                                      | 参数                                          | 案例                         | 命令作用                                                     | 复杂度    | 说明                   |
| ----------------------------------------- | --------------------------------------------- | ---------------------------- | ------------------------------------------------------------ | --------- | ---------------------- |
| APPEND [key] [value]                      | [key]：键key      [value]：字符串或者其他内容 | APPEND key5 111              | 向指定Key追加字符串     如果key存在：追加     不存在：创建key并追加 | O(1)      |                        |
| MGET key [key  ...]                       | [key ...]：可以获取多个key                    | MGET key1 key2               | 批量获取Key，不存在返回nil，操作永远不会失败                 | O(N)      |                        |
| MSET key value [key value ...]            | keY：键     value：值                         | MSET key1 value1 key2 value2 | 批量设置key,value                                            | O(N)      |                        |
| GETRANGE [key]  [start] [end]             | key：键     start：开始     end：结束         | GETRANGE key1 1 5            | 截取字符串，从start向end截取，如果为负数，则从倒数开始截取   | O(N)/O(1) |                        |
| SETRANGE [key]  [start] [value]           | key：键     start：开始     value：值         | SETRANGE key1 1 5            | 如果start超过了当前字符串的长度，会使用补0的操作(\X00)       | O(1)      | 不计算复制字符串的时间 |
| STRLEN [key]                              | key：键                                       | STRLEN key2                  | 获取字符串的长度                                             | O(1)      |                        |
| MSETNX [key1] [value1] [key2] [value2] …. | key：键…     value：[value]…                  | MSETNX k2 v1 k2 v2           | 对于给定的key进行批量赋值，只要有一个存在，则不能赋值，原子操作 | O(N)      |                        |

### list



#### redis当中的list实现原理：

　Redis的链表的实现的主要特性如下：

1. 双端：链表节点都有prev和next指针，这样获取一个节点的前置节点和后置节点的算法复杂度都为O(1)。
2. 无环：list的第一个节点（头节点）的prev和最后一个节点（尾节点）的next都指向NULL。
3. 带表头指针和表尾指针：通过list的head和tail两个指针，可以随意的从链表的头和尾进行操作。
4. 带链表长度计数器：可以通过len成员来获取链表的节点的个数，复杂度O(1)。
5. 多态：链表使用void *指针来保存value，并且可以通过dup，free，match来操控节点的value值，因此，该链表可以保存任意类型的值。



### zset



### hash:

`HSET [hash] [field1] [value1]`

hset和hmset有什么区别

1. 早期的`redis `不支持hset多个值，使用`Hmset`替代，4.0的版本之后，不在建议使用Hmset,并且后续会废弃
2. `hmset` 返回的是响应数据`OK`





# redis学习 - 深入解读Redis.conf文件配置

启动就需要redis.conf

> 单位：
>
> 1k => 1000bytes
>
> 1kb => 1024 bytes
>
> 1m => 1000000 bytes
>
> 1mb => 1024000 bytes

包含操作

> 包含：
>
> include /path/treee/redis.conf
>
> 可以包含多个配置文件
>
> 

网络：

```
bind: 127.0.0.1 绑定Ip
protected-mode: yes # 保护模式
port 6379 #端口
```



后台启动:

```
daemonize yes # 守护线程形式启动
```

日志级别:

```yml
# Specify the server verbosity level.
# This can be one of:
# debug (a lot of information, useful for development/testing)
# verbose (many rarely useful info, but not a mess like the debug level)
# notice (moderately verbose, what you want in production probably)
# warning (only very important / critical messages are logged)
loglevel notice
logfile "" # 日志文件位置名称
```

默认初始化数据库设置:

```yml
database 16 # 日期初始化设置
```

是否总是显示日志

```yml
always-show-logo yes
```

快照（持久化）

规定时间内执行多少次操作，

`.rdf` 

`.aof文件`

持久化规则如下:

redis断电即失，所以需要持久化

```yml
# 在900 内，至少有一个key修改
save 900 1
# 在300秒内，至少有10个key修改
save 300 10
# 在60秒内 10000 个key修改
save 60 10000
#持久化如果出错是否继续
stop-writes-on-bgsave-error: yes

# 是否压缩rdb文件，需要消耗CPU资源
rdbcompression yes

# 保存rdb的时候是否校验
rdbchecksum yes

# rdb保存目录
dir ./
```

> replication copy 主从复制

使用配置设置：

```
confit set key value
```

> 限制client
>
> maxclients 10000 最大客户端数量
>
> maxmemory <bytes> # redis 配置最大的内存容量
>
> maxmemory-policy noeviction # 内存达到上限的适合处理策略
>
> ​	\# 移除一些过期的key
>
> ​	\# 报错
>
> ​	\# LRU LFU

## redis的六种淘汰策略

Redis提供了**6种的淘汰策略**，其中默认的是`noeviction`，这6中淘汰策略如下：

1. `noeviction`(**默认策略**)：若是内存的大小达到阀值的时候，所有申请内存的指令都会报错。
2. `allkeys-lru`：所有key都是使用**LRU算法**进行淘汰。
3. `volatile-lru`：所有**设置了过期时间的key使用LRU算法**进行淘汰。
4. `allkeys-random`：所有的key使用**随机淘汰**的方式进行淘汰。
5. `volatile-random`：所有**设置了过期时间的key使用随机淘汰**的方式进行淘汰。
6. `volatile-ttl`：所有设置了过期时间的key**根据过期时间进行淘汰，越早过期就越快被淘汰**。

>  append only 模式 aof配置

```yml
appendonly on # 默认不开启aof ，而是使用rdb持久化的，rbd完全够用。
```

# redis事务

## redis事务的特点：

1. 所有的命令都按照序列化的执行，整个`命令队列`的执行过程是保证原子性的
2. 队列的命令要么全部被处理，要么全部忽略，当在事务上下文中丢失线程：
   1. `multi`命令之前，不执行任何command
   2. `exec`被调用，则所有命令都执行

## redis为什么不保证事务的原子性？

总结redis事务的三条性质：

1. 单独的隔离操作：事务中的所有命令会被序列化、按顺序执行，在执行的过程中不会被其他客户端发送来的命令打断
2. 没有隔离级别的概念：队列中的命令在事务没有被提交之前不会被实际执行
3. 不保证原子性：redis中的一个事务中如果存在命令执行失败，那么其他命令依然会被执行，没有回滚机制

## redis中的事务是如何执行的？

这就牵扯到cmd命令行当中的内容

## 为什么 Redis 不支持回滚？（roll back）

> 单个 Redis 命令的执行是原子性的，但 Redis 没有在事务上增加任何维持原子性的机制，所以 Redis 事务的执行并不是原子性的。
>
> 事务可以理解为一个打包的批量执行脚本，但批量指令并非原子化的操作，中间某条指令的失败不会导致前面已做指令的回滚，也不会造成后续的指令不做。


Redis事务为什么不支持回滚:

在事务运行期间，虽然Redis命令可能会执行失败，但是Redis仍然会执行事务中余下的其他命令，而不会执行回滚操作，你可能会觉得这种行为很奇怪。然而，这种行为也有其合理之处：只有当被调用的Redis命令有语法错误时，这条命令才会执行失败（在将这个命令放入事务队列期间，Redis能够发现此类问题），或者对某个键执行不符合其数据类型的操作：实际上，这就意味着只有程序错误才会导致Redis命令执行失败，这种错误很有可能在程序开发期间发现，一般很少在生产环境发现。

Redis已经在系统内部进行功能简化，这样可以确保更快的运行速度，因为Redis不需要事务回滚的能力。对于Redis事务的这种行为，有一个普遍的反对观点，那就是程序有可能会有缺陷（bug）。但是，你应当注意到：事务回滚并不能解决任何程序错误。例如，如果某个查询会将一个键的值递增2，而不是1，或者递增错误的键，那么事务回滚机制是没有办法解决这些程序问题的。

请注意，没有人能解决程序员自己的错误，这种错误可能会导致Redis命令执行失败。正因为这些程序错误不大可能会进入生产环境，所以我们在开发Redis时选用更加简单和快速的方法，没有实现错误回滚的功能。

# redis学习 - 整数集合：

## 什么是整数集合？

我们可以通过`debug object set`和`object encoding set`查看对应的结果：

```shell
127.0.0.1:17200> sadd set 1 2 2 3 3  33 4 55 6 66 67 77 7788 9 99 9 9  2020 0
127.0.0.1:17300> debug object set
Value at:0x7f935c630c30 refcount:1 encoding:intset serializedlength:39 lru:456392 lru_seconds_idle:9
127.0.0.1:17300> object encoding set
"intset
```

因为我们所有的元素都是**整数**类型，redis对于整数集合进行考察

> 注意：我们如果对任何一个整数集合添加一个非整数，那么他里面就会变为哈希表的结构：
>
> ```shell
> 127.0.0.1:17300> sadd set2 1 1
> (integer) 1
> 127.0.0.1:17200> object encoding set2
> "intset"
> 127.0.0.1:17200> sadd set2 1 af
> (integer) 1
> 127.0.0.1:17200> object encoding set2
> "hashtable"
> ```

## 源码分析和解读：

### intset定义：

我们从源码包src下面：`intset.h`当中，可以看到Intset的定义

```c
typedef struct intset {
    // 编码方式
    uint32_t encoding;
    // 集合包含的元素数量
    uint32_t length;
    // 元素内容素质
    int8_t contents[];
} intset;
```

整数集合使用结构体intset进行定义，里面包含了三个参数：

+ encoding：他代表了整数集合每一个元素的类型
+ length：集合包含的元素数量，同时也是数组的长度，可以直接用O(1)的速度获取到集合的大小
+ contents[]：保存元素的数组

注意，第一次看的时候，非常容易被迷惑，认为**contents**数组的类型为 `int8_t` 类型，但是其实他 **不保存任何int8_t类型的值**，<font color='red'>contents类型由 encoding属性决定</font>

#### `encoding`特殊用法：

<font color='red'>contents类型由 encoding属性决定</font>，那么他在源码中如何使用呢

在`intset.c`文件内，可以看到对于encoding进行判断之后，按照当前encoding的类型设置不同位数的值

所以可以证明contents元素的类型是由：`encoding`的属性来确定的

```c
/* 使用配置的编码在pos处设置值. */
static void _intsetSet(intset *is, int pos, int64_t value) {
    // 获取当前的整数集合的 encoding 类型
    uint32_t encoding = intrev32ifbe(is->encoding);
	// 根据encoding的类型，为当前contents的元素分配对应类型的数值
    if (encoding == INTSET_ENC_INT64) {
        // 
        ((int64_t*)is->contents)[pos] = value;
        memrev64ifbe(((int64_t*)is->contents)+pos);
    } else if (encoding == INTSET_ENC_INT32) {
        ((int32_t*)is->contents)[pos] = value;
        memrev32ifbe(((int32_t*)is->contents)+pos);
    } else {
        ((int16_t*)is->contents)[pos] = value;
        memrev16ifbe(((int16_t*)is->contents)+pos);
    }
}
```

这时候可能会有疑问了encoding的类型是如何判断的呢？

**encoding的大小是如何确定的？**

可以看如下代码，这个方法在很多地方有用到，比较关键：

```c
/* 返回提供的值所需的编码。 */
static uint8_t _intsetValueEncoding(int64_t v) {
    if (v < INT32_MIN || v > INT32_MAX)
        return INTSET_ENC_INT64;
    else if (v < INT16_MIN || v > INT16_MAX)
        return INTSET_ENC_INT32;
    else
        return INTSET_ENC_INT16;
}

```

代码比较好懂，就是根据参数类型的大小返回对应的大小，参数类型为`int64_t`是为了最大程度的判断大小，这里的返回类型为：`uint8_t`对应contents数组的类型。而预定义的三个常量都会对于对应类型进行`sizeof`操作，根据大小返回对应的类型。

> 上方代码判定的注意事项
>
> 这里注意`v < INT32_MIN || v > INT32_MAX`如果值的类型大于`INT32_MAX`，使用`INTSET_ENC_INT64`存储是可以理解的，那为什么使用`< INT32_MIN`这种情况下还是要使用`INTSET_ENC_INT64`呢？
>
> 

如果还不清楚，下方的单元测试可以帮助我们更好的理解作用

```c
printf("Value encodings: "); {
        assert(_intsetValueEncoding(-32768) == INTSET_ENC_INT16);
        assert(_intsetValueEncoding(+32767) == INTSET_ENC_INT16);
        assert(_intsetValueEncoding(-32769) == INTSET_ENC_INT32);
        assert(_intsetValueEncoding(+32768) == INTSET_ENC_INT32);
        assert(_intsetValueEncoding(-2147483648) == INTSET_ENC_INT32);
        assert(_intsetValueEncoding(+2147483647) == INTSET_ENC_INT32);
        assert(_intsetValueEncoding(-2147483649) == INTSET_ENC_INT64);
        assert(_intsetValueEncoding(+2147483648) == INTSET_ENC_INT64);
        assert(_intsetValueEncoding(-9223372036854775808ull) ==
                    INTSET_ENC_INT64);
        assert(_intsetValueEncoding(+9223372036854775807ull) ==
                    INTSET_ENC_INT64);
        ok();
    }

```

单元测试可以看到对应类型范围如下，INTSET_ENC_INT64基本可以存储所有的内容：

**INTSET_ENC_INT16**大小为：`-32768 ~ 32767`

**INTSET_ENC_INT32**大小为：`-2147483648 ~ 2147483647`

**INTSET_ENC_INT64**大小为：`-9223372036854775808ull ~ 9223372036854775807ull`



### 整数集合自动升级：

#### 什么是自动升级：

当

```c
/* Return the value at pos, given an encoding. */
static int64_t _intsetGetEncoded(intset *is, int pos, uint8_t enc) {
    int64_t v64;
    int32_t v32;
    int16_t v16;
	// 根据当前的encoding类型，进行Memcpy，对于扩容
    if (enc == INTSET_ENC_INT64) {
        memcpy(&v64,((int64_t*)is->contents)+pos,sizeof(v64));
        memrev64ifbe(&v64);
        return v64;
    } else if (enc == INTSET_ENC_INT32) {
        memcpy(&v32,((int32_t*)is->contents)+pos,sizeof(v32));
        memrev32ifbe(&v32);
        return v32;
    } else {
        memcpy(&v16,((int16_t*)is->contents)+pos,sizeof(v16));
        memrev16ifbe(&v16);
        return v16;
    }
}

```







# redis学习 - sds字符串

[Redis 设计与实现](http://redisbook.com/index.html)：如果想要知道redis底层，这本书可以给予不少的帮助，非常推荐每一位学习redis的同学去翻一翻。

sds字符串建议多看看源代码的实现，这篇文章基本是个人看了好几篇文章之后的笔记。

源代码文件分别是：`sds.c`，`sds.h`



## redis的string API使用

首先看下API的简单应用，设置str1变量为helloworld，然后我们使用`debug object +变量名`的方式看下，注意编码为**embstr**。

```shell
127.0.0.1:17100> set str1 helloworld
-> Redirected to slot [5416] located at 127.0.0.1:17300
OK
127.0.0.1:17300> debug object str1
Value at:0x7f2821c0e340 refcount:1 encoding:embstr serializedlength:11 lru:14294151 lru_seconds_idle:8

```

如果我们将str2设置为`helloworldhelloworldhelloworldhelloworldhell`，字符长度为44，再使用下`debug object+变量名`的方式看下，注意编码为**embstr**。

```shell
127.0.0.1:17300> set str2 helloworldhelloworldhelloworldhelloworldhell
-> Redirected to slot [9547] located at 127.0.0.1:17100
OK
127.0.0.1:17100> get str2
"helloworldhelloworldhelloworldhelloworldhell"
127.0.0.1:17100> debug object str2
Value at:0x7fd75e422c80 refcount:1 encoding:embstr serializedlength:21 lru:14294260 lru_seconds_idle:6
```

但是当我们把设置为`helloworldhelloworldhelloworldhelloworldhello`，字符长度为45，再使用`debug object+变量名`的方式看下，注意编码改变了，变为**raw**。

```shell
127.0.0.1:17100> set str2 helloworldhelloworldhelloworldhelloworldhello
OK
127.0.0.1:17100> debug object str2
Value at:0x7fd75e430c60 refcount:1 encoding:raw serializedlength:21 lru:14294358 lru_seconds_idle:9

```

最后我们将其设置为整数100，再使用`debug object+变量名`的方式看下，编码的格式变为了int。

```shell
127.0.0.1:17100> set str2 11
OK
127.0.0.1:17100> get str2
"11"
127.0.0.1:17100> debug object str2
Value at:0x7fd75e44d370 refcount:2147483647 encoding:int serializedlength:2 lru:14294440 lru_seconds_idle:9

```

所以Redis的string类型一共有三种存储方式：

1. 当字符串长度小于等于44，底层采用**embstr**；
2. 当字符串长度大于44，底层采用**raw**；
3. 当设置是**整数**，底层则采用**int**。

至于这三者有什么区别，可以直接看书：

http://redisbook.com/preview/object/string.html



## 为什么redis string 要使用sds字符串？

1. **O(1)获取长度**，c语言的字符串本身不记录长度，而是通过末尾的`\0`作为结束标志，而sds本身记录了字符串的长度所以获取直接变为O(1)的时间复杂度、同时，长度的维护操作由sds的本身api实现
2. **防止缓冲区溢出bufferoverflow**：由于c不记录字符串长度，相邻字符串容易发生缓存溢出。sds在进行添加之前会检查长度是否足够，并且不足够会自动根据api扩容
3. **减少字符串修改的内存分配次数**：使用动态扩容的机制，根据字符串的大小选择合适的header类型存储并且根据实际情况动态扩展。
4. 使用**空间预分配和惰性空间释放**，其实就是在扩容的时候，根据大小额外扩容2倍或者1M的空间，方面字符串修改的时候进行伸缩
5. 使用**二进制保护**，数据的读写不受特殊的限制，写入的时候什么样读取就是什么样
6. 支持**兼容部分**的c字符串函数，可以减少部分API的开发



## SDS字符串和C语言字符串库有什么区别

摘自黄健宏大神的一张表

| C 字符串                                             | SDS                                                  |
| :--------------------------------------------------- | :--------------------------------------------------- |
| 获取字符串长度的复杂度为 O(N) 。                     | 获取字符串长度的复杂度为 O(1) 。                     |
| API 是不安全的，可能会造成缓冲区溢出。               | API 是安全的，不会造成缓冲区溢出。                   |
| 修改字符串长度 `N` 次必然需要执行 `N` 次内存重分配。 | 修改字符串长度 `N` 次最多需要执行 `N` 次内存重分配。 |
| 只能保存文本数据。                                   | 可以保存文本或者二进制数据。                         |
| 可以使用所有 `<string.h>` 库中的函数。               | 可以使用一部分 `<string.h>` 库中的函数。             |

## redis的sds是如何实现的

由于c语言的string是以`\0`结尾的Redis单独封装了SDS简单动态字符串结构，如果在字符串变量十分多的情况下，会浪费十分多的内存空间，同时为了减少malloc操作，redis封装了自己的sds字符串。

下面是网上查找的一个sds字符串实现的数据结构设计图：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46b159febe6d4e039b5503e04c0f0616~tplv-k3u1fbpfcp-zoom-1.image)

s1,s2分别指向真实数据区域的头部，而要确定一个sds字符串的类型，则需要通过 s[-1] 来获取对应的flags，根据flags辨别出对应的Header类型，获取到Header类型之后，根据最低三位获取header的类型（这也是使用`__attribute__ ((__packed__))`关键字的原因下文会说明）：

- 由于s1[-1] == 0x01 == SDS_TYPE_8，因此s1的header类型是sdshdr8。
- 由于s2[-1] == 0x02 == SDS_TYPE_16，因此s2的header类型是sdshdr16。

下面的部分是sds的实现源代码：

sds一共有5种类型的header。之所以有5种，是为了能让不同长度的字符串可以使用不同大小的header。这样，短字符串就能使用较小的header，从而节省内存。

```c
typedef char *sds;
 
// 这个比较特殊，基本上用不到
struct __attribute__ ((__packed__)) sdshdr5 {
    usigned char flags;
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr8 {
    uint8_t len;
    uint8_t alloc;
    unsigned char flags;
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr16 {
    uint16_t len;
    uint16_t alloc;
    unsigned char flags;
    char buf[];
};
//string_size < 1ll<<32
struct __attribute__ ((__packed__)) sdshdr32 {
    uint32_t len;
    uint32_t alloc;
    unsigned char flags;
    char buf[];
};
//string_size < 1ll<<32
struct __attribute__ ((__packed__)) sdshdr64 {
    uint64_t len;
    uint64_t alloc;
    unsigned char flags;
    char buf[];
};
// 定义了五种header类型，用于表示不同长度的string 
#define SDS_TYPE_5 0
#define SDS_TYPE_8 1
#define SDS_TYPE_16 2
#define SDS_TYPE_32 3
#define SDS_TYPE_64 4

#define SDS_TYPE_MASK 7 // 类型掩码
#define SDS_TYPE_BITS 3 // 
#define SDS_HDR_VAR(T,s) struct sdshdr##T *sh = (void*)((s)-(sizeof(struct sdshdr##T))); // 获取header头指针
#define SDS_HDR(T,s) ((struct sdshdr##T *)((s)-(sizeof(struct sdshdr##T)))) // 获取header头指针
#define SDS_TYPE_5_LEN(f) ((f)>>SDS_TYPE_BITS)
```

上面的代码需要注意以下两个点：

+ `__attribute__ ((__packed__))` 这是C语言的一种关键字,这将使这个结构体在内存中不再遵守字符串对齐规则，而是以内存紧凑的方式排列。目的时在指针寻址的时候，可以直接通过sds[-1]找到对应flags，有了flags就可以知道头部的类型，进而获取到对应的len，alloc信息，而不使用内存对齐，CPU寻址就会变慢，同时如果不对齐会造成CPU进行优化导致空白位不补0使得header和data不连续，最终无法通过flags获取低3位的header类型。

+ `SDS_HDR_VAR`函数则通过结构体类型与字符串开始字节，获取到动态字符串头部的开始位置，并赋值给sh指针。`SDS_HDR`函数则通过类型与字符串开始字节，返回动态字符串头部的指针。

- 在各个header的定义中最后有一个char buf[]。我们注意到这是一个没有指明长度的字符数组，这是C语言中定义字符数组的一种特殊写法，称为柔性数组（[flexible array member](https://en.wikipedia.org/wiki/Flexible_array_member)），只能定义在一个结构体的最后一个字段上。它在这里只是起到一个标记的作用，表示在flags字段后面就是一个字符数组，或者说，它指明了紧跟在flags字段后面的这个字符数组在结构体中的偏移位置。而程序在为header分配的内存的时候，它并不占用内存空间。如果计算sizeof(struct sdshdr16)的值，那么结果是5个字节，其中没有buf字段。

> 关于柔性数组的介绍：
>
> [深入浅出C语言中的柔性数组](https://blog.csdn.net/ce123_zhouwei/article/details/8973073)

- **sdshdr5**与其它几个header结构不同，它不包含alloc字段，而长度使用flags的**高5位**来存储。因此，它不能为字符串分配空余空间。如果字符串需要动态增长，那么它就必然要重新分配内存才行。所以说，这种类型的sds字符串更适合存储静态的短字符串（长度小于32）。



同时根据上面的结构可以看到，SDS结构分为两个部分：

+ **len、alloc、flags**。只是`sdshdr5`有所不同，
  + len: 表示字符串的真正长度（不包含NULL结束符在内）。
  + alloc: 表示字符串的最大容量（不包含最后多余的那个字节）。
  + flags: 总是占用一个字节。其中的最低3个bit用来表示header的类型。header的类型共有5种，在sds.h中有常量定义。

```c
#define SDS_TYPE_5  0
#define SDS_TYPE_8  1
#define SDS_TYPE_16 2
#define SDS_TYPE_32 3
#define SDS_TYPE_64 4
```

+ **buf[]**：柔性数组，之前有提到过，其实就是具体的数据存储区域，注意这里实际存储的数据的时候末尾存在`NULL`

> 小贴士：
>
> \#define SDS_HDR(T,s) ((struct sdshdr##T *)((s)-(sizeof(struct sdshdr##T))))
>
> \#号有什么作用？
>
> 这个的含义是让"#"后面的变量按照**普通字符串**来处理
>
> 双\#又有什么用处呢？
>
> 双“#”号可以理解为，在单“#”号的基础上，增加了连接功能



## sds的创建和销毁

```c
sds sdsnewlen(const void *init, size_t initlen) {
    void *sh;
    sds s;
    
    char type = sdsReqType(initlen);
    /* Empty strings are usually created in order to append. Use type 8
     * since type 5 is not good at this. */
    if (type == SDS_TYPE_5 && initlen == 0) type = SDS_TYPE_8;
    int hdrlen = sdsHdrSize(type);
    unsigned char *fp; /* flags pointer. */

    sh = s_malloc(hdrlen+initlen+1);
    if (!init)
        memset(sh, 0, hdrlen+initlen+1);
    if (sh == NULL) return NULL;
    s = (char*)sh+hdrlen;
    fp = ((unsigned char*)s)-1;
    switch(type) {
        case SDS_TYPE_5: {
            *fp = type | (initlen << SDS_TYPE_BITS);
            break;
        }
        case SDS_TYPE_8: {
            SDS_HDR_VAR(8,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_16: {
            SDS_HDR_VAR(16,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_32: {
            SDS_HDR_VAR(32,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_64: {
            SDS_HDR_VAR(64,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
    }
    if (initlen && init)
        memcpy(s, init, initlen);
    s[initlen] = '\0';
    return s;
}

sds sdsempty(void) {
    return sdsnewlen("",0);
}

sds sdsnew(const char *init) {
    // 如果initlen 为NULL,使用0作为初始化数据
    size_t initlen = (init == NULL) ? 0 : strlen(init);
    return sdsnewlen(init, initlen);
}

void sdsfree(sds s) {
    if (s == NULL) return;
    s_free((char*)s-sdsHdrSize(s[-1]));
}
```

上面的源代码需要注意如下几个点：

1. **SDS_TYPE_5**由于设计之初按照常量对待，实际情况大多数为append操作扩容，而**SDS_TYPE_5**扩容会造成内存的分配，所以使用**SDS_TYPE_8** 进行判定
2. SDS字符串的长度为：`hdrlen+initlen+1` -> `sds_header`的长度 + 初始化长度 + 1 (末尾占位符`NULL`判定字符串结尾)
3. `s[initlen] = '\0';` 字符串末尾会使用`\0`进行结束标志：代表为`NULL`
4. sdsfree释放sds字符串需要计算出Header的起始位置，具体为`s_malloc`指针所指向的位置



知道了sds如何创建之后，我们可以了解一下里面调用的具体函数。比如**sdsReqType**，**sdsReqType**方法定义了获取类型的方法，首先根据操作系统的位数根据判别 `LLONG_MAX`是否等于`LONG_MAX`，根据机器确定为32位的情况下分配sds32，同时在64位的操作系统上根据判断小于2^32分配sds32，否则分配sds64。

这里值得注意的是：`string_size < 1ll<<32`这段代码在**redis3.2**中才进行了bug修复，在早期版本当中这里存在分配类型的`Bug`

[commit](https://github.com/antirez/redis/commit/603234076f4e59967f331bc97de3c0db9947c8ef)

```c
static inline char sdsReqType(size_t string_size) {
    if (string_size < 1<<5)
        return SDS_TYPE_5;
    if (string_size < 1<<8)
        return SDS_TYPE_8;
    if (string_size < 1<<16)
        return SDS_TYPE_16;
// 在一些稍微久远一点的文章上面没有这一串代码 #
#if (LONG_MAX == LLONG_MAX)
    if (string_size < 1ll<<32)
        return SDS_TYPE_32;
    return SDS_TYPE_64;
#else
    return SDS_TYPE_32;
#endif
}
```

再来看下`sdslen`方法，**s[-1]**用于向低位地址偏移一个字节，和`SDS_TYPE_MASK`按位与的操作，获得Header类型，

```c
static inline size_t sdslen(const sds s) {
    unsigned char flags = s[-1];
    // SDS_TYPE_MASK == 7
    switch(flags&SDS_TYPE_MASK) {
        case SDS_TYPE_5:
            return SDS_TYPE_5_LEN(flags);
        case SDS_TYPE_8:
            return SDS_HDR(8,s)->len;
        case SDS_TYPE_16:
            return SDS_HDR(16,s)->len;
        case SDS_TYPE_32:
            return SDS_HDR(32,s)->len;
        case SDS_TYPE_64:
            return SDS_HDR(64,s)->len;
    }
    return 0;
}
```





## sds的连接（追加）操作

```c
/* Append the specified binary-safe string pointed by 't' of 'len' bytes to the
 * end of the specified sds string 's'.
 *
 * After the call, the passed sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */

sds sdscatlen(sds s, const void *t, size_t len) {
    size_t curlen = sdslen(s);

    s = sdsMakeRoomFor(s,len);
    if (s == NULL) return NULL;
    memcpy(s+curlen, t, len);
    sdssetlen(s, curlen+len);
    // 注意末尾需要设置占位符\0代表结束标志
    s[curlen+len] = '\0';
    return s;
}

sds sdscat(sds s, const char *t) {
    return sdscatlen(s, t, strlen(t));
}

sds sdscatsds(sds s, const sds t) {
    return sdscatlen(s, t, sdslen(t));
}

// sds实现的一个核心代码，用于判别是否可以追加以及是否有足够的空间
sds sdsMakeRoomFor(sds s, size_t addlen) {
    void *sh, *newsh;
    size_t avail = sdsavail(s);
    size_t len, newlen;
    char type, oldtype = s[-1] & SDS_TYPE_MASK;
    int hdrlen;

    /* Return ASAP if there is enough space left. */
    // 如果原来的空间大于增加后的空间，直接返回
    if (avail >= addlen) return s;

    len = sdslen(s);
    sh = (char*)s-sdsHdrSize(oldtype);
    newlen = (len+addlen);
    // 如果小于 1M，则分配他的两倍大小，否则分配 +1M
    if (newlen < SDS_MAX_PREALLOC)
        newlen *= 2;
    else
        newlen += SDS_MAX_PREALLOC;

    type = sdsReqType(newlen);

    /* Don't use type 5: the user is appending to the string and type 5 is
     * not able to remember empty space, so sdsMakeRoomFor() must be called
     * at every appending operation. */
    // sdsheader5 会造成内存的重新分配，使用header8替代
    if (type == SDS_TYPE_5) type = SDS_TYPE_8;

    hdrlen = sdsHdrSize(type);
    // 如果不需要重新分配header，那么试着在原来的alloc空间分配内存
    if (oldtype==type) {
        newsh = s_realloc(sh, hdrlen+newlen+1);
        if (newsh == NULL) return NULL;
        s = (char*)newsh+hdrlen;
    } else {
        /* Since the header size changes, need to move the string forward,
         * and can't use realloc */
        // 如果需要更换Header，则需要进行数据的搬迁
        newsh = s_malloc(hdrlen+newlen+1);
        if (newsh == NULL) return NULL;
        memcpy((char*)newsh+hdrlen, s, len+1);
        s_free(sh);
        s = (char*)newsh+hdrlen;
        s[-1] = type;
        sdssetlen(s, len);
    }
    sdssetalloc(s, newlen);
    return s;
}
```

通过上面的函数可以了解到每次传入的都是一个旧变量，但是在返回的时候，都是**新的sds变量**，redis多数的数据结构都采用这种方式处理。

同时我们可以确认一下几个点：

+ **append**操作的实现函数为`sdscatlen`函数
+ `getrange`这种截取一段字符串内容的方式可以直接操作字符数组，对于部分内容操作看起来比较容易，效率也比较高。



## sds字符串 的空间扩容策略：

1. 如果sds字符串修改之后，空间小于1M，扩容和len等长的未分配空间。比如修改之后为13个字节，那么程序也会分配 `13` 字节的未使用空间
2. 如果修改之后大于等于1M，则分配1M的内存空间，比如修改之后为30M,则buf的实际长度为：30M+1M+1Byte

简单来说就是：

+ 小于1M，扩容修改后长度2倍
+ 大于1M，扩容1M



## 字符串命令的实现

| 命令        | `int` 编码的实现方法                                         | `embstr` 编码的实现方法                                      | `raw` 编码的实现方法                                         |
| :---------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| SET         | 使用 `int` 编码保存值。                                      | 使用 `embstr` 编码保存值。                                   | 使用 `raw` 编码保存值。                                      |
| GET         | 拷贝对象所保存的整数值， 将这个拷贝转换成字符串值， 然后向客户端返回这个字符串值。 | 直接向客户端返回字符串值。                                   | 直接向客户端返回字符串值。                                   |
| APPEND      | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此操作。 | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此操作。 | 调用 `sdscatlen` 函数， 将给定字符串追加到现有字符串的末尾。 |
| INCRBYFLOAT | 取出整数值并将其转换成 `long double` 类型的浮点数， 对这个浮点数进行加法计算， 然后将得出的浮点数结果保存起来。 | 取出字符串值并尝试将其转换成 `long double` 类型的浮点数， 对这个浮点数进行加法计算， 然后将得出的浮点数结果保存起来。 如果字符串值不能被转换成浮点数， 那么向客户端返回一个错误。 | 取出字符串值并尝试将其转换成 `long double` 类型的浮点数， 对这个浮点数进行加法计算， 然后将得出的浮点数结果保存起来。 如果字符串值不能被转换成浮点数， 那么向客户端返回一个错误。 |
| INCRBY      | 对整数值进行加法计算， 得出的计算结果会作为整数被保存起来。  | `embstr` 编码不能执行此命令， 向客户端返回一个错误。         | `raw` 编码不能执行此命令， 向客户端返回一个错误。            |
| DECRBY      | 对整数值进行减法计算， 得出的计算结果会作为整数被保存起来。  | `embstr` 编码不能执行此命令， 向客户端返回一个错误。         | `raw` 编码不能执行此命令， 向客户端返回一个错误。            |
| STRLEN      | 拷贝对象所保存的整数值， 将这个拷贝转换成字符串值， 计算并返回这个字符串值的长度。 | 调用 `sdslen` 函数， 返回字符串的长度。                      | 调用 `sdslen` 函数， 返回字符串的长度。                      |
| SETRANGE    | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此命令。 | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此命令。 | 将字符串特定索引上的值设置为给定的字符。                     |
| GETRANGE    | 拷贝对象所保存的整数值， 将这个拷贝转换成字符串值， 然后取出并返回字符串指定索引上的字符。 | 直接取出并返回字符串指定索引上的字符。                       | 直接取出并返回字符串指定索引上的字符。                       |





## 结尾：

多多翻翻资料，其实很多东西不需要去钻研细节，有很多优秀的人为我们答疑解惑，所以最重要的是理解作者为什么要这样设计，学习任何东西都要学习思想，思想层面的东西才是最有价值的。

sds已经被许多大佬文章进行过说明，这篇文章只是简单的归纳了一下自己看的内容，**如果有错误的地方还望指正**，谢谢







# 参考资料：

下面是个人学习sds的参考资料：

Redis内部数据结构详解(2)——sds

http://zhangtielei.com/posts/blog-redis-sds.html

解析redis的字符串sds数据结构：

https://blog.csdn.net/wuxing26jiayou/article/details/79644309

SDS 与 C 字符串的区别

http://redisbook.com/preview/sds/different_between_sds_and_c_string.html

Redis源码剖析--动态字符串SDS

https://zhuanlan.zhihu.com/p/24202316

C基础 带你手写 redis sds

https://www.lagou.com/lgeduarticle/77101.html

redis源码分析系列文章

http://www.soolco.com/post/73204_1_1.html

**Redis SDS (简单动态字符串) 源码阅读**

https://chenjiayang.me/2018/04/08/redis-sds-source-code/



# redis学习 - redis 持久化

无论面试和工作，持久化都是重点。

一般情况下,redis占用内存超过20GB以上的时候，必须考虑主从多redis实例进行数据同步和备份保证可用性。

rbd保存的文件都是 `dump.rdb`，都是配置文件当中的快照配置进行生成的。一般业务情况只需要用rdb即可。

aof默认是不开启的，因为aof非常容易产生大文件，虽然官方提供重写但是在文件体积过大的时候还是容易造成阻塞，谨慎考虑使用

rbd和aof在大数据量分别有各种不同情况的系统性能影响，具体使用何种解决策略需要根据系统资源以及业务的实际情况决定。



## 为什么要持久化？

1. 重用数据
2. 防止系统故障备份重要数据

### 持久化的方式

1. RDB 快照：将某一个时刻的所有数据写入到磁盘
2. AOF（append-only file）：将所有的命令写入到此判断。

默认情况：**RDB**，AOF需要手动开启

## redis.conf持久化配置说明

在`redis.conf`文件当中，存在如下的选项：

`redis.conf`当中RDB的相关配置

```properties
#是否开启rdb压缩 默认开启
rdbcompression yes
#代表900秒内有一次写入操作，就记录到rdb
save 900 1
# rdb的备份文件名称
dbfilename dump.rdb
# 表示备份文件存放位置
dir ./
```

`redis.conf`当中AOF的相关配置

```properties
# 是否开启aof，默认是关闭的
appendonly no
#aof的文件名称
appendfilename "appendonly.aof"
# no: don't fsync, just let the OS flush the data when it wants. Faster.
# always: fsync after every write to the append only log. Slow, Safest.
# everysec: fsync only one time every second. Compromise.
appendfsync everysec
# 在进行rewrite的时候不开启fsync，即不写入缓冲区，直接写入磁盘，这样会造成IO阻塞，但是最为安全，如果为yes表示写入缓冲区，写入的适合redis宕机会造成数据持久化问题(在linux的操作系统的默认设置下，最多会丢失30s的数据)
no-appendfsync-on-rewrite no
# 下面两个参数要配合使用，代表当redis内容大于64m同时扩容超过100%的时候会执行bgrewrite，进行持久化
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

```

## RDB

### 创建rdb快照的几种方式：

1. 客户端向redis发送bgsave的命令（注意windows不支持bgsave），此时reids调用 **fork** 创建子进程，父进程继续处理，子进程将快照写入磁盘，父进程继续处理请求。
2. 客户端发送save命令创建快照。注意这种方式会**阻塞**整个父进程。很少使用，特殊情况才使用。
3. redis通过shutdown命令关闭服务器请求的时候，此时redis会停下所有工作执行一次save，阻塞所有客户端不再执行任何命令并且进行磁盘写入，写入完成关闭服务器。
4. redis集群的时候，会发送sync 命令进行一次复制操作，如果主服务器**没有执行**或者**刚刚执行完**bgsave，则会进行bgsave。
5. 执行**flushall** 命令

### RDB快照的一些注意点:

1. **只使用rdb的时候**，如果创建快照的时候redis崩溃，redis会留存上一次备份快照，但是具体丢失多少数据由备份时间查看
2. 只适用一些可以容忍一定数据丢失的系统，否则需要考虑aof持久化
3. 在大数据量的场景下，特别是内存达到20GB以上的适合，一次同步大约要4-6秒
   1. 一种方式是用手动同步，在凌晨的适合进行手动阻塞同步，比BGSAVE快一些

> 一种解决方法：
>
> 通过日志记录来恢复中断的日志，来进行数据的恢复

如何通过修改配置来获得想要的持久化？

1. 修改save参数，尽量在开发环境模拟线上环境设置save，过于频繁造成资源浪费，过于稀少有可能丢失大量数据
2. 日志进行聚合计算，按照save进行计算最多会丢失多少时间的数据，判断容忍性，比如一小时可以设置 `save 3600 1`

### RDB的优缺点对比：

#### 优点：

1. 适合大规模的数据恢复
2. 如果数据不小心误删，可以及时恢复
3. 恢复速度一般情况下快于aof

#### 缺点：

1. 需要一定的时间间隔，如果redis意外宕机，最后一次修改的数据就没有了，具体丢失多少数据需要看持久化策略
2. fork进程的时候，会占用一定的内存空间，如果fork的内存过于庞大，可能导致秒级别的恢复时间
3. 数据文件经过redis压缩，可读性较差

## AOF（append only fail）

其实就是把我们的命令一条条记录下来，类似linux的`history`

默认是不开启的，需要手动开启，开启之后需要重启

如果aof文件错位了，可以用`redis-check-aof` 进行文件修复

> 文件同步：写入文件的时候，会发生三件事：
>
> 1. file.write() 方法将文件存储到缓冲区
> 2. file.flush() 将缓冲区的内容写入到硬盘
> 3. sync 文件同步，阻塞直到写入硬盘为止

### AOC的同步策略

| 选项     | 同步频率                               |
| -------- | -------------------------------------- |
| always   | 每次命令都写入磁盘，严重降低redis速度  |
| everysec | 每秒执行一次，显示将多个命令写入到磁盘 |
| no       | 操作系统决定，佛系                     |

分析：

1. 第一种对于固态的硬盘的伤害比较大，我们都知道固态的擦写次数的寿命是远远小于机械硬盘的，频繁的io是容易对固态造成欺骗认为一次擦写，导致本就寿命不长的固态变得更命短，**基本不用**，特殊情况下有可能用得到
2. 第二种是默认的方式，也是推荐以及比较实用的方式，最多只会丢失一秒的数据，这种方式比较好的保证数据的备份可用，**推荐使用**
3. 第三种对于CPU的压力是最小的，因为由系统决定，但是需要考虑能不能接受不定量的数据丢失，还有一个原因是硬盘将缓冲区刷新到硬盘不定时，所以**不建议使用**



### 重写和压缩AOF文件：

由于1秒一次同步在不断写入之后造成文件内容越来越大，同时同步速度也会变慢，为了解决这个问题，redis引入了`bgrewriteaof`命令来进行压缩，和`bgsave`创建快照类似，同样会有子进程拖垮的问题，同时会有大文件在重写的时候带来巨大的文件系统删除的压力，导致系统阻塞。

命令如下

`bgrewriteaof`

示例如下：

> 127.0.0.1:16379> BGREWRITEAOF
> Background append only file rewriting started

> 参数控制：
>
> auto-aof-rewrite-percentage：**100**
>
> auto-aof-rewrite-min-size ：**64MB**
>
> 这里案例配置代表当AOF大于64并且扩大了100%触发**bgrewrite**命令

#### redis aof的rewrite做了那些事？

1. 对于一些冗余的命令进行清除
2. 检测存在错误的命令，将错误命令下面的所有命令都进行清理，一般情况是末尾由于宕机没有执行完的一些命令清理。

### aof的优缺点对比

#### 优点：

1. 从不同步，效率高
2. 每秒同步一次，可能丢失一秒数据
3. 每次修改都同步，文件完整性好

#### 缺点：

1. 相对于数据文件来说，aof远远大于rdb。修复速度慢一些
2. 存在未知的bug，比如如果重写aof文件的时候突然中断，会有很多奇怪的现象

## 如何检查redis的性能瓶颈：

1. redis-benchmark 官方推荐的性能测试工具，非常强大，具体的地址为：https://www.runoob.com/redis/redis-benchmarks.html
2. Redis-cli中调用`slowlog get`，作用是返回执行时间**超过redis.conf**中定义的持续时间的命令列表，注意这个时间仅仅是请求的处理时间，不包含网络通信的时间，**默认值是一秒**，

> redis.conf 当中对于慢日志的解释:
>
> The following time is expressed in microseconds, so 1000000 is equivalent to one second. Note that a negative number disables the slow log, while a value of zero forces the logging of every command.
>
> 接下来的时间以微秒为单位，因此1000000等于一秒。 请注意，负数将禁用慢速日志记录，而零值将强制记录每个命令。**（以微秒为单位）**
>
> **slowlog-log-slower-than 10000**
>
> There is no limit to this length. Just be aware that it will consume memory. You can reclaim memory used by the slow log with SLOWLOG RESET.
>
> 该长度没有限制。 请注意，它将消耗内存。 您可以使用SLOWLOG RESET回收慢速日志使用的内存。**（意思就是说超过128条之后的命令会被自动移除）**
>
> **slowlog-max-len 128**

> 可以用命令 SLOWLOG RESET 清楚慢日志占用的内存
>
> 127.0.0.1:16379> SLOWLOG reset
> OK

==慢日志是存储在内存当中的，切记==

## 持久化性能建议

> - 因为RDB文件只用作后备用途，建议只在Slave上持久化RDB文件，而且只要15分钟备份一次就够了，只保留save 900 1这条规则。

> - 如果Enalbe AOF，好处是在最恶劣情况下也只会丢失不超过两秒数据，启动脚本较简单只load自己的AOF文件就可以了。代价一是带来了持续的IO，二是AOF rewrite的最后将rewrite过程中产生的新数据写到新文件造成的阻塞几乎是不可避免的。只要硬盘许可，应该尽量减少AOF rewrite的频率，AOF重写的基础大小默认值64M太小了，可以设到5G以上。默认超过原大小100%大小时重写可以改到适当的数值。

> - 如果不Enable AOF ，仅靠Master-Slave Replication 实现高可用性也可以。能省掉一大笔IO也减少了rewrite时带来的系统波动。代价是如果Master/Slave同时倒掉，会丢失十几分钟的数据，启动脚本也要比较两个Master/Slave中的RDB文件，载入较新的那个。**新浪微博**就选用了这种架构。

其他性能优化指南（强烈推荐）：

https://szthanatos.github.io/topic/redis/improve-02/

## 总结对比rdb和aof：

|              | RDB                                                          | AOF                                                          |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **存储内容** | 数据                                                         | 写操作日志                                                   |
| **性能影响** | 小                                                           | 大                                                           |
| **恢复速度** | 高                                                           | 低                                                           |
| **存储空间** | 小                                                           | 大                                                           |
| **可读性**   | 低                                                           | 高                                                           |
| **安全程度** | 较低，保存频率低                                             | 较高，保存频率高                                             |
| **默认开启** | 是                                                           | 否                                                           |
| **存储策略** | `save 900 1`：九百秒内一次修改即保存 `save 300 10`：三百秒内十次修改即保存 `save 60 10000`：六十秒内一万次修改即保存 允许自定义 | `always`：逐条保存 or `everysec`：每秒保存 or `no`：系统自己决定什么时候保存 |

## 其他拓展知识：

### 关于linux内核开启`transparent_hugepage`会带来的阻塞问题：

个人对于Linux学艺不精，就直接引用文章了，侵权请联系删除

[Linux 关于Transparent Hugepages的介绍](https://www.cnblogs.com/kerrycode/p/4670931.html)

[简单说说THP——记一次数据库服务器阻塞的问题解决](https://blog.51cto.com/1152313/1767927)

### 官方解决aof和rdb对于性能问题的折中处理方式

1. redis4.0之后有一个参数叫做:`aof-use-rdb-preamble yes`

参数解释如下：

```
# When rewriting the AOF file, Redis is able to use an RDB preamble in the
# AOF file for faster rewrites and recoveries. When this option is turned
# on the rewritten AOF file is composed of two different stanzas:
#
#   [RDB file][AOF tail]
#
# When loading, Redis recognizes that the AOF file starts with the "REDIS"
# string and loads the prefixed RDB file, then continues loading the AOF
# tail.
＃重写AOF文件时，Redis可以在
＃AOF文件可加快重写和恢复速度。 启用此选项时
重写的AOF文件上的＃由两个不同的节组成：
＃
＃[RDB文件] [AOF尾巴]
＃
＃加载时，Redis会识别AOF文件以“ REDIS”开头
＃字符串并加载带前缀的RDB文件，然后继续加载AOF
＃ 尾巴。

```

大致的内容就是说redis会将较早的部分内容转为RDB文件进行恢复，同时加入近期的数据为AOF文件

加载的时候先执行rdb文件的恢复，然后再加载aof命令

### 如何进行内存清理

在**redis4.0**之后，可以通过将配置里的`activedefrag`设置为`yes`开启自动清理，或者通过`memory purge`命令手动清理。







# Redis学习 - Redis发布订阅



## redis的发布订阅应用

消息通信模式，发送者发送消息，接受者接受消息，微信，微博，关注系统

redis客户端可以订阅任意数量的频道

订阅/发布消息：

1. 消息发送者
2. 频道
3. 消息内容
4. 消息接受者



## 消息发布的原理

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201118223756.png)

订阅/发布消息需要的四个必要对象：

1. 消息发送者 publisher
2. 频道 - channel
3. 消息内容 - channel msg
4. 消息接受者 - subscriber

## 如何订阅频道

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201118224115.png)

使用**subscribe** 命令发送消息，订阅消息会显示 1）2）3）,同时显示订阅的序号，从1开始，这时候命令行会阻塞等待消息传递

```
127.0.0.1:16379> subscribe first second
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "first"
3) (integer) 1
1) "subscribe"
2) "second"
3) (integer) 2
```

## 发送消息

redis设计了 **publish** 命令，用于订阅频道，发送消息会返回成功收到消息的数量，如果没有收到则为0

我们需要在新开一个窗口，输入如下命令

```
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ ./redis-cli -p 16379
127.0.0.1:16379> publish channel1 message
(integer) 1
127.0.0.1:16379> 

```



## 模式匹配

功能说明：允许客户端订阅某个模式的频道

本质：其实就是可以通过使用通配符的模式批量订阅一批频道

具体的命令如下：

```
127.0.0.1:16379> PSUBSCRIBE chanel-*
Reading messages... (press Ctrl-C to quit)
1) "psubscribe"
2) "chanel-*"
3) (integer) 1

```

如果订阅了一批频道，那么发送给这个频道的消息将被客户端接收到两次，只不过这两条消息的类型不同，一个是message类型，一个是**pmessage**类型，但其内容相同。

```
127.0.0.1:16379> PSUBSCRIBE chanel-*
Reading messages... (press Ctrl-C to quit)
1) "psubscribe"
2) "chanel-*"
3) (integer) 1
1) "pmessage"
2) "chanel-*"
3) "chanel-111"
4) "213213"
1) "pmessage"
2) "chanel-*"
3) "chanel-22"
4) "213213"
```

## 取消订阅

Redis采用**UNSUBSCRIBE**和**PUNSUBSCRIBE**命令取消订阅

## redis发布订阅原理实现

https://juejin.im/post/6844904186534952968#heading-7

### subscribe的实现

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201119134454.png)

1. 维护一个client 和 一个 server 结构体，都存储pubsub_patterns
2. client存储的是以hash表来实现的，用键值对的形式，键为键表示订阅的频道，值为空。
3. 而server存储的是改服务器当中所有频道以及订阅这个频道的客户端，也是字典类型。插入节点的时候键为频道，值为订阅的所有客户端组成的链表

### psubscribe

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201119225433.png)

1. 大体实现和subscribe类似，client维护的内容是相似的
2. 在server当中,表示该服务端的所有频道以及订阅频道客户端。插入节点使用的是键为频道，值为订阅了所有客户端组成的链表

### PUBLISH

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201119225849.png)

会在redis_server当中遍历所有的pubsub_channel中管理的所有频道，找到对应的频道之后链表遍历所有的客户端，将消息发给客户端。

## redis发布订阅的应用

用于监听命令和数据的变化，当redis通过发布订阅进行写操作的时候，会有两条消息，一条是del mykey，另一条是mykey del。一个表示空间变化，一个是频道的改变。可以用于进行消息的实时推送。

## redis和activeMQ的比较

（1）ActiveMQ支持多种消息协议，包括AMQP，MQTT，Stomp等，并且支持JMS规范，但Redis没有提供对这些协议的支持； 

（2）ActiveMQ提供持久化功能，但Redis无法对消息持久化存储，一旦消息被发送，如果没有订阅者接收，那么消息就会丢失； 

（3）ActiveMQ提供了消息传输保障，当客户端连接超时或事务回滚等情况发生时，消息会被重新发送给客户端，Redis没有提供消息传输保障。

>  ActiveMQ所提供的功能远比Redis发布订阅要复杂，毕竟Redis不是专门做发布订阅的，但是如果系统中已经有了Redis，并且需要基本的发布订阅功能，就没有必要再安装ActiveMQ了，因为可能ActiveMQ提供的功能大部分都用不到，而Redis的发布订阅机制就能满足需求。



# Redis内存压缩技术

## 介绍三种结构

1. 短结构：ziplist

不使用压缩列表，以链表为例，需要**两个指针**以及**三个值**：

1. 前继指针 - 4个字节
2. 后继指针 - 4个字节
3. **数据区指针** - 4个字节
   1. 字符串的长度 - 4个字节
   2. 字符串剩余可用空间长度  - 4个字节
   3. 字符串本身
   4. 额外字节 - 1个字节

> 至少需要21个字节存储

由节点组成的序列，由两个长度值和一些字符串。

第一个长度值：前一个节点的长度 - 1个字节

第二个长度值：当前节点的长度 - 1个字节

第三个字符串：被存储的字符串值 - 1个字节

### 段结构

#### 压缩编码:











# Redis学习 - 复制以及三种部署模式

## 什么是复制

单机的redis通常情况是无法满足项目需求的，一般都建议使用集群部署的方式进行数据的多机备份和部署，这样既可以保证数据安全，同时在redis宕机的时候，复制也可以对于数据进行快速的修复。

## 采取的方式

1. 单机部署（忽略）
2. 主从链
3. 一主多从
4. 哨兵模式
5. 集群模式

## 复制的前提

1. 需要保证`redis.conf`里面的配置是正确的，比如：

```
dir ./
dbfilename "dump.rdb"
```

2. 需要保证指定的路径对于redis来说是**可写**的，意味着如果当前目录没有写权限同样会失败

## 从服务器连接主服务器的几种方式

1. 在从服务器的配置文件里面配置连接那个主服务器：

连接的具体配置如下：

> 在5.0版本中使用了`replicaof`代替了`slaveof`（[github.com/antirez/red…](https://github.com/antirez/redis/issues/5335)），`slaveof`还可以继续使用，不过建议使用`replicaof`

下面是个人的配置

```properties
# replicaof <masterip> <masterport> 
replicaof 127.0.0.1 16379

```

> **警告**：此小节只说明了这一个配置的更改，进行主从配置的时候还有其他几个参数需要更改，这里只作为部分内容参考

2. 在启动的适合，在**redis从服务器**的redis-cli当中敲击如下的命令：

```shell
127.0.0.1:16380> slaveof 127.0.0.1 16379
OK Already connected to specified master
```

这样就可以在从服务器动态的指定要连接哪个主服务器了，但是这种配置是**当前运行时有效**，下次再次进入的时候，会根据配置文件进行配置或者按照默认的规则当前实例就是**master**3. 

3. 在从服务器执行`slaveof no one`，当前实例脱离控制自动成为`master`

## redis 复制启动的过程==（重点）==

| 主服务器操作                                                 | 从服务器操作                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1. （等待命令）                                              | 1. 连接（重新连接）主服务器，发送**sync**命令                |
| 2. 开始执行bgsave，使用缓冲区记录bgsave之后执行所有写命令    | 2. 根据配置选项是使用现有的数据（存在）处理客户端请求，还是向请求的客户端返回错误信息 |
| 3. bgsave执行完毕，向从服务器发送**快照文件**，同时异步执行缓冲区记录的写命令 | 3. **丢弃所有的旧数据**，载入主服务器的快照文件              |
| 4.  快照文件发送完毕，开始向着从服务器发送存储在缓冲区的写命令 | 4. 完成对于快照的解释操作，恢复日常的请求操作                |
| 5. 缓冲区写命令发送完成，同时现在每执行一个写命令就像从服务器发送相同写命令 | 5. 执行主服务器发来的所有存储在缓冲区的写命令，并且从现在开始接受主服务器的每一个命令 |

> 建议：由于**bgsave**需要开启进行子线程的创建写入缓冲区的创建，所以最好在系统中预留30% - 45% 内存用于redis的bgsave操作

> 特别注意：当从服务器连接主服务器的那一刻，执行到第三步会**清空**当前redis里面的所有数据。

### 配置方式和命令方式的区别：

redis.conf 配置slaveof 的方式：不会马上进行主服务器同步，而是**先载入当前本地存在的rdb或者aof**到redis中进行数据恢复，然后才开始同步复制

命令slaveof方式：会**立即**连接主服务器进行同步操作

### 关于redis的主主复制:

如果我们尝试让两台服务器互相slaveof 那么会出现上面情况呢？

从上面的复制过程可以看到，当一个服务器slaveof另一个服务器，产生的结果只会是两边相互覆盖，也就是从服务器会去同步主服务器的数据，如果此时按照主主的配置，两边互相同步对方的数据，这样产生的数据可能会不一致，或者数据干脆就是不完整的。不仅如此，这种操作还会大量占用资源区让两台服务器互相知道对方

### 当一台服务器连接另一台服务器的时候会发生什么？

| 当有新服务器连接的时候    | 主服务器操作                                                 |
| ------------------------- | ------------------------------------------------------------ |
| 步骤3还没有执行           | 所有从服务器都会收到相同的快照文件和相同缓冲区写命令         |
| 步骤3正在执行或者已经执行 | 完成了之前同步的五个操作之后，会跟新服务器重新执行一次新的五个步骤 |



## 系统故障处理

复制和持久化虽然已经基本可以保证系统的数据安全，但是总有意外的情况，比如突然断电断网，系统磁盘故障，服务器宕机等一系列情况，那么会出现各种莫名奇妙的问题，下面针对这些情况说明一下解决方式：

### 验证快照文件以及aof文件
在redis的`bin`目录下面，存在如下的两个sh
```
-rwxr-xr-x 1 root root 9722168 Nov 15 20:53 redis-check-aof
-rwxr-xr-x 1 root root 9722168 Nov 15 20:53 redis-check-rdb
```
他们的命令作用和内容如下：
```
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ ./redis-check-aof 
Usage: ./redis-check-aof [--fix] <file.aof>
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ ./redis-check-rdb 
Usage: ./redis-check-rdb <rdb-file-name>

```
redis-check-aof：如果加入`--fix`选项，那么命令会尝试修复aof文件，会将内容里面出现错误的命令以及下面的所有命令清空，一般情况下回清空尾部的一些未完成命令。

redis-check-rdb：遗憾的是目前这种修复收效甚微。建议在修复rdb的时候，用SHA1和SHA256验证文件是否完整。

### 校验和与散列值：
redis2.6 之后加入了校验和与散列值进行验证。

快照文件增加CRC64校验和

> 什么是crc**循环冗余校验**？
>
> https://zh.wikipedia.org/wiki/%E5%BE%AA%E7%92%B0%E5%86%97%E9%A4%98%E6%A0%A1%E9%A9%97

### 更换故障主服务器：

1. 假设A故障，存在BC两台机器，B为从服务，C为将要替换的主服务器
2. 向机器B发送save命令，同时创建一个新的快照文件，同步完成之后，发送给C
3. 机器C上面启动redis,让C成为B的主服务器

### Redis sentienel 哨兵

可以监视指定主服务器以及属下的从服务器

也就是我们常用的**哨兵模式**

但是随着时代进步，目前使用redis基本还是以`cluster模式`为主

## redis主从复制模式（redis6.0版本）：

### 前提说明：

有条件的可以弄三台虚拟机查看效果，这样模拟出来的效果算是比较真实的。

### 三台从服务器以及一台主服务器的配置

个人的办法是copy一个公用的配置，然后进行修改（这里只列举区别以及改动较多的地方，其他地方根据需要配置）：

第一台机器的配置：

```properties
pidfile /var/run/redis_16379.pid
port 16379
dbfilename dump16379.rdb
appendfilename "appendonly16379.aof"
logfile "log16379"
```

第二台机器的配置：

```properties
pidfile /var/run/redis_16380.pid
port 16380
dbfilename dump16380.rdb
appendfilename "appendonly16380.aof"
logfile "log16380"
```

第三台机器的配置：

```properties
pidfile /var/run/redis_16381.pid
port 16381
dbfilename dump16381.rdb
appendfilename "appendonly16381.aof"
logfile "log16381"
```

这时候要配置一台主服务器

```properties
pidfile /var/run/redis_10000.pid
port 10000
dbfilename dump10000.rdb
appendfilename "appendonly10000.aof"
logfile "log10000"
```

### 启动redis一主多从：

配置很简单，可以用**手动**进行主从复制，也可以使用**redis.conf**提前配置，具体区别上文已经进行过介绍，这里不再赘述。

从服务器可以通过命令：`slaveof 127.0.0.1 10000` 实现主从复制拷贝

可以通过命令`info replication` 查看主从配置的信息。

主服务器启动日志：

```
127.0.0.1:10000> info replication
# Replication
role:master
connected_slaves:0
master_replid:e2a92d8c59fbdde3b162da12f4d74ff28bab4fbb
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
127.0.0.1:10000> info replication
# Replication
role:master
connected_slaves:3
slave0:ip=127.0.0.1,port=16381,state=online,offset=14,lag=1
slave1:ip=127.0.0.1,port=16380,state=online,offset=14,lag=1
slave2:ip=127.0.0.1,port=16379,state=online,offset=14,lag=1
master_replid:029e455ee6f8fdc0e255b6d5c4f63136d933fb24
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:14
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:14
```

可以看到进行主从配置之后，当前的目录下面多出了对应备份文件

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201123232149.png)

当进行主从配置之后，从服务就无法进行写入了，主服务器才可以写入：

```
127.0.0.1:16379> set key 1
(error) READONLY You can't write against a read only replica.
```

#### 测试一主多从复制：

主服务器敲入如下命令：

```
127.0.0.1:10000> hset key1 name1 value1
(integer) 1
127.0.0.1:10000> keys *
1) "key1"
```

从服务器：

```
127.0.0.1:16379> hget key1 name1
"value1"
127.0.0.1:16380> hget key1 name1
"value1"
127.0.0.1:16381> hget key1 name1
"value1"
```

### 主从链

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201123134010.png)

配置方式：

和主从配置一样，只不过主节点换为从节点。

> 注意：主从链的配置依然只能是master节点可以写数据，同时中间的节点也是slave



### 扩展

如何检测磁盘是否写入数据？

1. 主从服务器通过一个虚标值（unique dummy value）来验证从服务器是否真的把数据写入到自己的磁盘。
2. 通过命令：`info`检查结果当中的 `aof_appending_bio_fsync`的值是否为0:

> \# 5.0 版本之后改为如下形式验证
>
> repl_backlog_active:0







## redis主从哨兵模式（Redis sentienel）（redis6.0版本）

### 哨兵模式有什么作用：

Redis的哨兵模式就是对redis系统进行实时的监控，其主要功能有下面两点

1.**监测**主数据库和从数据库是否正常运行。

2.当我们的主数据库出现故障的时候，可以自动将从数据库转换为主数据库，实现**自动的切换**。

### 为什么要使用哨兵模式：

1. 主从复制在主节点宕机的情况下，需要人工干预恢复redis，无法实现高可用。
2. 主节点宕机的情况下需要备份数据到新的从节点，然后其他节点将主节点设置为新的redis，需要一次全量复制同步数据的过程

### 哨兵模式原理

主节点故障的时候，由redis sentinel自动完成故障发现和转移

### 如何部署哨兵模式：

1. 首先按照上一节配置，已经设置了一个主节点三个从节点的配置

> 下面的配置如下：
>
> 主节点：10000
>
> 从节点1：16379
>
> 从节点2：16380
>
> 从节点3：16381

```
[xd@iZwz99gyct1a1rh6iblyucZ ~]$ ps -ef | grep redis
xd        2964  2910  0 18:02 pts/0    00:00:00 grep --color=auto redis
root     26412     1  0 Nov23 ?        00:06:07 ./redis-server 127.0.0.1:10000
root     26421     1  0 Nov23 ?        00:05:37 ./redis-server 127.0.0.1:16379
root     26428     1  0 Nov23 ?        00:05:37 ./redis-server 127.0.0.1:16380
root     26435     1  0 Nov23 ?        00:05:37 ./redis-server 127.0.0.1:16381
```

2. `sentinel.conf` 配置文件在安装redis的源码包里面有，所以如果误删了可以下回来然后把文件弄到手，其实可以配置一个常用的或者通用的配置放到自己的本地有需要直接替换
3. **配置5个sentienl.conf文件（建议奇数个哨兵，方便宕机选举产生新的节点）**

```shell
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ sudo cp sentinel.conf sentinel_26379.conf
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ sudo cp sentinel.conf sentinel_26380.conf
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ sudo cp sentinel.conf sentinel_26381.conf
[xd@iZwz99gyct1a1rh6iblyucZ bin]$ sudo cp sentinel.conf sentinel_10000.conf
```

4. 四个配置文件的改动依次如下：

所有的`sentinel.conf` 配置如下：

```shell
# 指定哨兵端口
port 20000
# 监听主节点10000
sentinel monitor mymaster 127.0.0.1 10000 2
# 连接主节点时的密码，如果redis配置了密码需要填写
sentinel auth-pass mymaster 12345678
# 故障转移时最多可以有2从节点同时对新主节点进行数据同步
sentinel config-epoch mymaster 2
# 故障转移超时时间180s，
sentinel failover-timeout mymasterA 180000 
# sentinel节点定期向主节点ping命令，当超过了300S时间后没有回复，可能就认定为此主节点出现故障了……
sentinel down-after-milliseconds mymasterA 300000
# 故障转移后，1代表每个从节点按顺序排队一个一个复制主节点数据，如果为3，指3个从节点同时并发复制主节点数据，不会影响阻塞，但存在网络和IO开销
sentinel parallel-syncs mymasterA 1
# 设置后台启动
daemonize yes
# 进程的pid文件，保险起见设置不一样的，特别是设置后台启动的时候
pidfile /var/run/redis-sentinel.pid
```

> 扩展：如何判定转移失败:
>
> a - 如果转移超时失败，下次转移时时间为之前的2倍；
>
> b - 从节点变主节点时，从节点执行slaveof no one命令一直失败的话，当时间超过**180S**时，则故障转移失败
>
> c - 从节点复制新主节点时间超过**180S**转移失败

下面为配好五个之后的配置：

```shell
-rw-r--r-- 1 root root   10772 Nov 28 21:00 sentienl_26382.conf
-rw-r--r-- 1 root root   10767 Nov 28 20:43 sentinel_10000.conf
-rw-r--r-- 1 root root   10772 Nov 28 21:03 sentinel_26379.conf
-rw-r--r-- 1 root root   10766 Nov 28 20:46 sentinel_26380.conf
-rw-r--r-- 1 root root   10772 Nov 28 20:59 sentinel_26381.conf
-rw-r--r-- 1 root root   10772 Nov 28 21:03 sentinel_26382.conf
-rw-r--r-- 1 root root   10744 Nov 28 18:06 sentinel.conf
```

5. 上一节已经启动过，这里不再介绍

5. **启动sentinel服务**

启动五个哨兵：

```shell
./redis-sentinel ./sentinel_10000.conf 
./redis-sentinel ./sentinel_26379.conf 
./redis-sentinel ./sentinel_263780.conf 
./redis-sentinel ./sentinel_263781.conf 
./redis-sentinel ./sentinel_263782.conf 
```

使用`ps`命令查看所有的服务：

```shell
root      3267     1  0 21:14 ?        00:00:01 ./redis-sentinel *:20000 [sentinel]
root      3280     1  0 21:15 ?        00:00:01 ./redis-sentinel *:26379 [sentinel]
root      3296     1  0 21:20 ?        00:00:00 ./redis-sentinel *:26380 [sentinel]
root      3303     1  0 21:21 ?        00:00:00 ./redis-sentinel *:26381 [sentinel]
root      3316  3254  0 21:28 pts/0    00:00:00 grep --color=auto redis
root     26412     1  0 Nov23 ?        00:06:17 ./redis-server 127.0.0.1:10000
root     26421     1  0 Nov23 ?        00:05:47 ./redis-server 127.0.0.1:16379
root     26428     1  0 Nov23 ?        00:05:47 ./redis-server 127.0.0.1:16380
root     26435     1  0 Nov23 ?        00:05:47 ./redis-server 127.0.0.1:16381
```

7. 验证一下哨兵是否管用

10000是主节点，他的`info`信息如下：

```
# Keyspace
db0:keys=1,expires=0,avg_ttl=0
127.0.0.1:10000> info replication
# Replication
role:master
connected_slaves:3

```

使用`kill -9 master节点进程端口号`之后，我们已经干掉了额主进程，验证一下从节点是否启动

进入到6379端口的`redis-cli`当中，可以看到从节点6379的实例被选举为新的的节点

```
127.0.0.1:16379> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=127.0.0.1,port=16380,state=online,offset=857706,lag=1
slave1:ip=127.0.0.1,port=16381,state=online,offset=858242,lag=1

```

> **挂掉的主节点恢复之后，能不能进行恢复为主节点？**
>
> 尝试重启挂掉的master之后，可以发现他变成了从节点
>
> ```shell
> 127.0.0.1:10000> info replication
> # Replication
> role:slave
> master_host:127.0.0.1
> master_port:16379
> master_link_status:up
> master_last_io_seconds_ago:2
> 
> ```

**注意：生产环境建议让redis Sentinel部署到不同的物理机上**

如果不喜欢上面的启动哨兵模式，也可以使用下面的命令开启：

```
[root@dev-server-1 sentinel]# redis-server sentinel1.conf --sentinel
[root@dev-server-1 sentinel]# redis-server sentinel2.conf --sentinel
[root@dev-server-1 sentinel]# redis-server sentinel3.conf --sentinel
```



### 哨兵模式部署建议

a，sentinel节点应部署在**多台**物理机（**线上**环境）

b，至少三个且**奇数**个sentinel节点

c，通过以上我们知道，**3个sentinel**可同时监控一个主节点或多个主节点

  监听N个主节点较多时，如果sentinel出现异常，会对多个主节点有影响，同时还会造成sentinel节点产生过多的网络连接，

  一般线上建议还是， **3个sentinel**监听一个主节点

也可以按照下面的方式在启动哨兵的时候启动：

### 哨兵模式的优缺点：

优点：

1. 哨兵模式基于主从复制模式，所以主从复制模式有的优点，哨兵模式也有
2. 哨兵模式下，master挂掉可以自动进行切换，系统可用性更高

缺点：

1. 同样也继承了主从模式难以在线扩容的缺点，Redis的容量受限于单机配置
2. 需要额外的资源来启动sentinel进程，实现相对复杂一点，同时slave节点作为备份节点不提供服务

## redis集群模式（redis6.0版本）

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201129145217.png)

随着应用的扩展，虽然主从模式和哨兵模式的加入解决了高可用的问题，但是现代的应用基本都是要求可以动态扩展了，为了支持动态扩展，redis在后续的版本当中加入了哨兵的模式

集群模式主要解决的问题是：

Cluster模式实现了Redis的分布式存储，即每台节点存储不同的内容，来解决在线扩容的问题

### redis结构设计：

使用的是无中心的结构，每一个节点和节点之间相互连接

1. redis 使用彼此互联的(ping-pong)的方式，进行互相关联，内部使用二进制协议优化速度
2. 客户端与redis节点直连,不需要中间代理层.客户端不需要连接集群所有节点,连接集群中任何一个可用节点即可
3. 节点的fail是通过集群中超过**半数**的节点检测失效时才生效

### redis集群的工作机制

1. 在Redis的每个节点上，都有一个插槽（slot），取值范围为0-16383，redis会根据接节点的数量分配槽的位置来进行判定发送给哪一个cluster节点

2. 当我们存取key的时候，Redis会根据CRC16的算法得出一个结果，然后把结果对16384求余数，这样每个key都会对应一个编号在0-16383之间的哈希槽，通过这个值，去找到对应的插槽所对应的节点，然后直接自动跳转到这个对应的节点上进行存取操作

3. 为了保证高可用，Cluster模式也引入**主从复制模式**，一个主节点对应一个或者多个从节点，当主节点宕机的时候，就会启用从节点

4. 当其它主节点ping一个主节点A时，如果半数以上的主节点与A通信超时，那么认为主节点A宕机了。如果主节点A和它的从节点都宕机了，那么**该集群就无法再提供服务了**




### 配置集群（重点）：

为了不产生干扰，先把上一节所有的redis进程干掉，包括哨兵的配置

使用`kil -9 进程端口号`直接抹掉整个应用

配置如下：

1. 集群至少需要三主三从，同时需要奇数的节点配置。
2. 我们可以将之前的主从配置的一主三从**增加两个主节点**，目前的配置如下：

```
-rw-r--r-- 1 root root   84993 Nov 28 21:41 redis10000.conf
-rw-r--r-- 1 root root   84936 Nov 28 21:35 redis16379.conf
-rw-r--r-- 1 root root   84962 Nov 28 21:35 redis16380.conf
-rw-r--r-- 1 root root   84962 Nov 28 21:35 redis16381.conf

# 增加两个主要节点
-rw-r--r-- 1 root root   84962 Nov 28 21:35 redis16382.conf
-rw-r--r-- 1 root root   84962 Nov 28 21:35 redis16383.conf
```

主节点的配置主要如下：

```
port 7100 # 本示例6个节点端口分别为7100,7200,7300,7400,7500,7600 
daemonize yes # r后台运行 
pidfile /var/run/redis_7100.pid # pidfile文件对应7100,7200,7300,7400,7500,7600 
cluster-enabled yes # 开启集群模式 
masterauth passw0rd # 如果设置了密码，需要指定master密码
cluster-config-file nodes_7100.conf # 集群的配置文件，同样对应7100,7200等六个节点
cluster-node-timeout 15000 # 请求超时 默认15秒，可自行设置 

```

启动如下：

```shell
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-server ./cluster/redis17000_cluster.conf
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-server ./cluster/redis17100_cluster.conf
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-server ./cluster/redis17200_cluster.conf
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-server ./cluster/redis17300_cluster.conf
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-server ./cluster/redis17400_cluster.conf
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-server ./cluster/redis17500_cluster.conf
[root@iZwz99gyct1a1rh6iblyucZ bin]# ps -ef | grep redis
root      4761     1  0 15:55 ?        00:00:00 ./redis-server 127.0.0.1:17000 [cluster]
root      4767     1  0 15:55 ?        00:00:00 ./redis-server 127.0.0.1:17100 [cluster]
root      4773     1  0 15:55 ?        00:00:00 ./redis-server 127.0.0.1:17200 [cluster]
root      4779     1  0 15:55 ?        00:00:00 ./redis-server 127.0.0.1:17300 [cluster]
root      4785     1  0 15:55 ?        00:00:00 ./redis-server 127.0.0.1:17400 [cluster]
root      4791     1  0 15:55 ?        00:00:00 ./redis-server 127.0.0.1:17500 [cluster]
root      4797  4669  0 15:55 pts/0    00:00:00 grep --color=auto redis

```

启动了上面六个节点之后，使用下面的命令并且敲入`yes`让他们变为集群：

```
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-cli --cluster create 127.0.0.1:17000 127.0.0.1:17100 127.0.0.1:17200 127.0.0.1:17300 127.0.0.1:17400 127.0.0.1:17500 --cluster-replicas 1

>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 127.0.0.1:17400 to 127.0.0.1:17000
Adding replica 127.0.0.1:17500 to 127.0.0.1:17100
Adding replica 127.0.0.1:17300 to 127.0.0.1:17200
>>> Trying to optimize slaves allocation for anti-affinity
[WARNING] Some slaves are in the same host as their master
M: 1179bb5f47e7f8221ba7917b5852f8064778e0db 127.0.0.1:17000
   slots:[0-5460] (5461 slots) master
M: 153afa1b9b14194de441fffa791f8d9001badc66 127.0.0.1:17100
   slots:[5461-10922] (5462 slots) master
M: 4029aeeb6b80e843279738d6d35eee7a1adcd2ff 127.0.0.1:17200
   slots:[10923-16383] (5461 slots) master
S: 3ceb11fe492f98432f124fd1dcb7b2bb1e769a96 127.0.0.1:17300
   replicates 1179bb5f47e7f8221ba7917b5852f8064778e0db
S: 66eaea82ccf69ef96dbc16aac39fd6f6ed3d0691 127.0.0.1:17400
   replicates 153afa1b9b14194de441fffa791f8d9001badc66
S: c34aeb59c8bedc11b4aeb720b70b0019e7389093 127.0.0.1:17500
   replicates 4029aeeb6b80e843279738d6d35eee7a1adcd2ff

```

#### 验证集群：

1. 输入`redis-cli`进入任意的一个主节点，注意是主节点，从节点不能做写入操作

`Redirected to slot [9189] located at 127.0.0.1:17100`根据Hash的算法，算出连接那个节点槽，然后提示slot[9189] 落到了17100上面，所以集群会自动跳转进行Key的加入

```shell
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-cli -p 17000
127.0.0.1:17000> set key1 1
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-cli -p 17000
127.0.0.1:17000> set key1 1
(error) MOVED 9189 127.0.0.1:17100
[root@iZwz99gyct1a1rh6iblyucZ bin]# ./redis-cli -p 17000 -c
127.0.0.1:17000> set key1 ke
-> Redirected to slot [9189] located at 127.0.0.1:17100
OK
```

> 小贴士：集群之后不能使用传统的连接方式，因为每一个key都要经过一次hash的操作找到对应的槽 -》节点之后才能做后续的操作
>
> 使用如下命令进入后正常
>
> ./redis-cli -p 17000 **-c**
>
> -c 代表以集群的方式连接

2. 可以使用如下命令验证集群的信息:

```shell
127.0.0.1:17000> cluster nodes
66eaea82ccf69ef96dbc16aac39fd6f6ed3d0691 127.0.0.1:17400@27400 slave 153afa1b9b14194de441fffa791f8d9001badc66 0 1606639411000 2 connected
4029aeeb6b80e843279738d6d35eee7a1adcd2ff 127.0.0.1:17200@27200 master - 0 1606639411000 3 connected 10923-16383
3ceb11fe492f98432f124fd1dcb7b2bb1e769a96 127.0.0.1:17300@27300 slave 1179bb5f47e7f8221ba7917b5852f8064778e0db 0 1606639410000 1 connected
1179bb5f47e7f8221ba7917b5852f8064778e0db 127.0.0.1:17000@27000 myself,master - 0 1606639410000 1 connected 0-5460
153afa1b9b14194de441fffa791f8d9001badc66 127.0.0.1:17100@27100 master - 0 1606639412002 2 connected 5461-10922
c34aeb59c8bedc11b4aeb720b70b0019e7389093 127.0.0.1:17500@27500 slave 4029aeeb6b80e843279738d6d35eee7a1adcd2ff 0 1606639413005 3 connected


```

3. 接下来我们验证一下当一个主节点挂掉会发生什么情况：

还是和主从复制的验证一样，直接Kill 进程：

kill掉 17000 之后，我们可以发现 17300 被升级为主节点

```shell
127.0.0.1:17300> info replication
# Replication
role:master
connected_slaves:0

```

此时的节点情况如下：

```shell
127.0.0.1:17100> cluster nodes
4029aeeb6b80e843279738d6d35eee7a1adcd2ff 127.0.0.1:17200@27200 master - 0 1606640582000 3 connected 10923-16383
153afa1b9b14194de441fffa791f8d9001badc66 127.0.0.1:17100@27100 myself,master - 0 1606640581000 2 connected 5461-10922
66eaea82ccf69ef96dbc16aac39fd6f6ed3d0691 127.0.0.1:17400@27400 slave 153afa1b9b14194de441fffa791f8d9001badc66 0 1606640581000 2 connected
c34aeb59c8bedc11b4aeb720b70b0019e7389093 127.0.0.1:17500@27500 slave 4029aeeb6b80e843279738d6d35eee7a1adcd2ff 0 1606640582624 3 connected
3ceb11fe492f98432f124fd1dcb7b2bb1e769a96 127.0.0.1:17300@27300 master - 0 1606640580619 7 connected 0-5460
1179bb5f47e7f8221ba7917b5852f8064778e0db 127.0.0.1:17000@27000 master,fail - 1606640370074 1606640367068 1 disconnected

```

4. 如果这时候主节点恢复呢？

和哨兵的模式一样，恢复之后也变为`slave`了。



### 集群模式优缺点：

优点：

1. 无中心架构，数据按照slot分布在多个节点。
2. 集群中的每个节点都是平等的关系，每个节点都保存各自的数据和整个集群的状态。每个节点都和其他所有节点连接，而且这些连接保持活跃，这样就保证了我们只需要连接集群中的任意一个节点，就可以获取到其他节点的数据。
3. 可线性扩展到1000多个节点，节点可动态添加或删除
4. 能够实现自动故障转移，节点之间通过gossip协议交换状态信息，用投票机制完成slave到master的角色转换

缺点：

1. 客户端实现复杂，驱动要求实现Smart Client，缓存slots mapping信息并及时更新，提高了开发难度。目前仅JedisCluster相对成熟，异常处理还不完善，比如常见的“max redirect exception”
2. 节点会因为某些原因发生阻塞（阻塞时间大于 cluster-node-timeout）被判断下线，这种failover是没有必要的
3. 数据通过异步复制，不保证数据的强一致性
4. slave充当“冷备”，不能缓解读压力
5. 批量操作限制，目前只支持具有相同slot值的key执行批量操作，对mset、mget、sunion等操作支持不友好
6. key事务操作支持有线，只支持多key在同一节点的事务操作，多key分布不同节点时无法使用事务功能
7. 不支持多数据库空间，单机redis可以支持16个db，集群模式下只能使用一个，即db 0

>  Redis Cluster模式不建议使用pipeline和multi-keys操作，减少max redirect产生的场景。

### cluster的相关疑问

#### 为什么redis的槽要用 `16384`？

![img](https://img2018.cnblogs.com/blog/725429/201908/725429-20190829164650720-1058321793.jpg)

值得高兴的是：这个问题作者出门回答了：

能理解作者意思的可以不用看下面的内容

地址：https://github.com/redis/redis/issues/2576

```
The reason is:

Normal heartbeat packets carry the full configuration of a node, that can be replaced in an idempotent way with the old in order to update an old config. This means they contain the slots configuration for a node, in raw form, that uses 2k of space with16k slots, but would use a prohibitive 8k of space using 65k slots.
At the same time it is unlikely that Redis Cluster would scale to more than 1000 mater nodes because of other design tradeoffs.
So 16k was in the right range to ensure enough slots per master with a max of 1000 maters, but a small enough number to propagate the slot configuration as a raw bitmap easily. Note that in small clusters the bitmap would be hard to compress because when N is small the bitmap would have slots/N bits set that is a large percentage of bits set.
```

1. 首先我们查看一下结构体，关于cluster的源代码：`cluster.h`

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20201129184329.png)

代码如下：

```c
typedef struct {
    char sig[4];        /* Signature "RCmb" (Redis Cluster message bus). */
    uint32_t totlen;    /* Total length of this message */
    uint16_t ver;       /* Protocol version, currently set to 1. */
    uint16_t port;      /* TCP base port number. */
    uint16_t type;      /* Message type */
    uint16_t count;     /* Only used for some kind of messages. */
    uint64_t currentEpoch;  /* The epoch accordingly to the sending node. */
    uint64_t configEpoch;   /* The config epoch if it's a master, or the last
                               epoch advertised by its master if it is a
                               slave. */
    uint64_t offset;    /* Master replication offset if node is a master or
                           processed replication offset if node is a slave. */
    char sender[CLUSTER_NAMELEN]; /* Name of the sender node */
    unsigned char myslots[CLUSTER_SLOTS/8];
    char slaveof[CLUSTER_NAMELEN];
    char myip[NET_IP_STR_LEN];    /* Sender IP, if not all zeroed. */
    char notused1[34];  /* 34 bytes reserved for future usage. */
    uint16_t cport;      /* Sender TCP cluster bus port */
    uint16_t flags;      /* Sender node flags */
    unsigned char state; /* Cluster state from the POV of the sender */
    unsigned char mflags[3]; /* Message flags: CLUSTERMSG_FLAG[012]_... */
    union clusterMsgData data;
} clusterMsg;

```

集群节点之间的通信内容无非就是IP信息，请求头，请求内容，以及一些参数信息，这里着重看一下参数`myslots[CLUSTER_SLOTS/8]`

> #define CLUSTER_SLOTS 16384  这里就是16384的来源

在redis节点发送心跳包时需要把所有的槽放到这个心跳包里，以便让节点知道当前集群信息，16384=16k，在发送心跳包时使用`char`进行bitmap压缩后是2k（`2 * 8 (8 bit) * 1024(1k) = 2K`），也就是说使用2k的空间创建了16k的槽数。

虽然使用CRC16算法最多可以分配65535（2^16-1）个槽位，65535=65k，压缩后就是8k（`8 * 8 (8 bit) * 1024(1k) = 8K`），也就是说需要需要8k的心跳包，作者认为这样做不太值得；并且一般情况下一个redis集群不会有超过1000个master节点，所以16k的槽位是个比较合适的选择。



## 参考资料：

https://juejin.cn/post/6844904097116585991#heading-9

https://juejin.cn/post/6844904178154897415#heading-25

[为什么Redis集群有16384个槽](https://www.cnblogs.com/rjzheng/p/11430592.html)

