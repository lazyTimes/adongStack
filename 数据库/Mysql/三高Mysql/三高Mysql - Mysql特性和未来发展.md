# 三高Mysql - Mysql特性和未来发展

## 引言

​	内容为慕课网的《高并发 高性能 高可用 Mysql 实战》视频的学习笔记内容和个人整理扩展之后的笔记，这一节主要讲讲Mysql5.8比较常用的几个新特性以及针对内部服务器的优化介绍，理论部分的内容比较多简单看看理解一下即可。

​	如果内容比较难可以跟随《Mysql是怎么样运行》个人读书笔记专栏补补课：

​	地址如下：[从零开始学Mysql](https://juejin.cn/column/7024363476663730207)。

## Mysql8.0新特性

Mysql为什么叫8.0？其实就是个数字游戏可以直接认为是5.8。

Mysql8.0有什么新特性：

窗口函数：rank()

*   列分隔，分为多个窗口

*   在窗口里面可以执行特定的函数

```sql
-- partition by 排名，案例指的是按照顾客支付金额排名。
-- rank() 窗口函数
select *,
  rank() over ( partition by customer_id order by amount desc) as ranking
from 
  payment;

```



隐藏索引

*   暂时隐藏某个索引。

*   可以隐藏和显示索引，测试索引作用，多用于开发的时候评估索引的可用性。

```sql
show index from payment;
-- 隐藏索引
alter table payment alter index fk_payment_rental Invisible;
-- 显示索引
alter table payment alter index fk_payment_rental Visible;
```



降序索引

*   8.0 之前只有升序的索引，自8.0之后引入了降序索引的索引排序方式，用于进行某些特殊查询的情况下也可以走索引。



通用表达式（CTE）

*   CTE表达式预先定义复杂语句中反复使用的中间结果

*   可以简单认为是一个临时视图

```sql
select b,d 
from (select a,b from table1) join  (select a,b from table2)
where cte1.a = cte2.c;

-- 简化
with 
  cte1 as (select a,b from table1),
  cte1 as (select a,b from table2)
select b,d
from cte1 join cte2
where cte.a = cte2.c;
  

```



UTF8编码

*   UTF8mb4作为默认的字符集

* DDL 事务

    *   支持DDL事务，元数据操作可以回滚

    *   对于不同数据库之间的DDL对比，可以看这篇文章：

  <https://juejin.cn/post/6986545706504814629>



InnoDB Cluster：组复制不是说Mysql可以组集群了而是说保证强一致性的数据同步，下面是关于一些核心组件的解释：

*   Mysql Router：路由

*   管理端绕过路由进行配置，可以实现主备的自由切换。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092032598.png)

> 另外从上面这个图还可以看到在新的概念图里面一般不会把节点叫master/slave了，额，zzzq就完事了。

Mysql官方的组复制其实是借用了Percona XtraDB Cluster的设计思路，只不过加了一些辅助工具看起来比较强一点而已，强一致性的组复制早就被实现过了，比如Percona XtraDB Cluster，设计思路也是来自于Zookeeper的一致性协议，可以认为是原理大同小异。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092032033.png)

最后强一致性的最大问题那就是等待同步的时间是否可以被系统接受，所以看似组复制在尝试解决复制带来的数据同步问题实际上这种代价看上去还是比较大的。



## 数据库的分类

对于数据库我们可以做出下面的总结，市面上主流的数据库基本都可以按照下面的几种方式进行归类：用途归类，存储形式归类和架构分类。

用途分类：

*   OLTP：在线事务处理
*   OLAP：在线分析处理
*   HTAP：事务和分析混合处理



OLTP：在线事务交易和处理系统，SQL语句不复杂大都用于事务的处理。并发量打，可用性的要求十分高。（Mysql / Postgres）

OLAP：在线分析处理系统，SQL语句复杂，并且数据量十分大，单个事务为单位。（Hive）

HTAP：混合两种数据库优点，一种架构多功能。（设计思路优秀，但是实际产出很可能类似新能源汽车，烧油不行烧点也不行）



存储形式分类

*   行存储：传统数据库的存储形式
*   列存储：针对传统OLTP数据库大数据量分析而逐渐出现的一种格式，行格式利于数据存储和数据分析。
*   K/V存储：无论是行还是列存储，似乎都逃不过KV的概念，这一点读者可以自行思考理解。



架构分类

*   Share-Everything&#x20;

    *   CPU、内存、硬盘，多合一，类似电脑（数据库不用）

*   Share-Memory

    *   多CPU独立，内存，硬盘，超级计算机架构（多CPU同内存通信，同一片大内存超级计算机）

*   SHare-Disk

    *   一个CPU绑定一个内存，硬盘独立，共享存储的架构。

*   Shared-Nothing

    *   CPU、内存、硬盘共享，常见集群的架构。



## 单体数据库之王

PostgresSQL说实话国内用的人太少了国内市场没有选择并且被忽视的优秀数据库，然而在国外Postgre SQL随着开源的不断发展以及比Mysql更优秀的设计市场占有率在逐年上升，同时Postgresql对于数据库设计者来说也是很好的范本，无论是学习还是研究都是十分好的参考资料，最后Postgresql是开源的社区在国外也比较活跃，这一点很重要，可惜国内只能老老实实研究Mysql了。

> Mysql随着Oracle的商业化逐渐自闭式发展进步也越来越小实在看不到他的未来。

Postgresql和Mysql类似的地方以及更加进步的地方：

*   Mysql类似功能

*   性能更好，更稳定

*   代码质量更高

*   有赶超Mysql的优势

*   良好的插件，包含并不完全列举比如下面的这些插件：

    *   Postgres-XL（OLTP）
    *   GTM管理每个事务的执行
    *   Coordinator解析SQL，制定执行计划，分发
    *   DataNode返回执行结果到Coordinator。
    *   GreenPlum 是给予Postgres分布式分析集群
        *   高性能SQL优化器：GPORCA
        *   Slice的实现机制


    ![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091750619.png)







## Mysql如何魔改

首先看看PolarDB的改进，PolarDB是阿里巴巴的东西所以除了内部人员可能使用之外外部的技术人员基本接触不到这个东西，这里简单介绍相关的设计思路。

下面为相关的设计图：



![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091751246.png)

在PorlarDB中包含下面的关键组件：

1.  ECS：客户端
2.  Read/Write Splitter 读写分离中间件
3.  Mysql节点，文件系统， 数据路由和数据缓冲。主备服务器
4.  RMDA统一的管理
5.  Data Chunk Server：数据的存储桶，存储服务器，集群的方式存储

    1.  Raft：强一致性的存储服务器。
6.  日志传送和共享存储

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091747069.png)

7\. 备库如何查询数据

在传统的方式中，备库使用下面的方式进行处理

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091751461.png)

创新和改进点：在读取事务改动的时候，使用了叠加redo log的方式处理，防止读写库的数据不一致的问题

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091749281.png)



## 如何支撑双十一？

双十一刚刚出现的时候是一个十分火热的话题，然而到了现在电商成熟的年代双十一似乎变成了“日常活动”......，双十一的支撑依靠十分核心的中间组件：**OceanBase**，也被称之为new sql数据库。

OceanBase属于**行列互存**的架构最大的特点是机房跨全球。存储引擎的最下层是分片的分区层，Share-Nothing架构，数据分区使用的一主两备的结构。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091749537.png)

数据如何更新？

数据更新依靠下面的流程，看起来比较负责，其实这里的设计思路有点类似谷歌在2006年的“Bigtable”设计，而SSTable于这篇论文中首次出现，SSTable主要用于给予LSM-Tree数据结构的日志存储引擎。

如果不清楚什么是LSM-Tree，可以阅读下面的文章了解：

[《数据密集型型系统设计》LSM-Tree VS BTree - 掘金 (juejin.cn)](https://juejin.cn/post/7082216648538587167)

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091735956.png)

## 国产混合数据库-TiDB

TiDB简介：

下面的内容引用自官方介绍：

> [TiDB](https://github.com/pingcap/tidb) 是 [PingCAP](https://pingcap.com/about-cn/) 公司自主设计、研发的开源分布式关系型数据库，是一款同时支持在线事务处理与在线分析处理 (Hybrid Transactional and Analytical Processing, HTAP) 的融合型分布式数据库产品，具备水平扩容或者缩容、金融级高可用、实时 HTAP、云原生的分布式数据库、兼容 MySQL 5.7 协议和 MySQL 生态等重要特性。目标是为用户提供一站式 OLTP (Online Transactional Processing)、OLAP (Online Analytical Processing)、HTAP 解决方案。TiDB 适合高可用、强一致要求较高、数据规模较大等各种应用场景。

简单来说Tidb主要有下面的几个特点：

*   一键水平扩容或者缩容
*   金融级高可用
*   实时HTAP

> HTAP数据库（Hybrid Transaction and Analytical Process，混合事务和分析处理）。2014年Gartner的一份报告中使用混合事务分析处理(HTAP)一词描述新型的应用程序框架，以打破OLTP和OLAP之间的隔阂，既可以应用于事务型数据库场景，亦可以应用于分析型数据库场景。实现实时业务决策。这种架构具有显而易见的优势：不但避免了繁琐且昂贵的ETL操作，而且可以更快地对最新数据进行分析。这种快速分析数据的能力将成为未来企业的核心竞争力之一。

*   云原生的分布式数据库
*   兼容Mysql5.7 协议和Mysql生态。

虽然TiDB被使用之后有许多令人诟病的缺点，同时因为是新型的数据库对于一些实践问题的解答资料也比较少，但是作为一款非常有潜力的数据库还是值得我们保持关注的。

TiDB的架构设计如下：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091740198.png)

*   纯分布式架构，拥有良好的扩展性，支持弹性的扩缩容

*   支持 SQL，对外暴露 Mysql 的网络协议，并兼容大多数 Mysql 的语法，在大多数场景下可以直接替换 Mysql

*   默认支持高可用，在少数副本失效的情况下，数据库本身能够自动进行数据修复和故障转移，对业务透明

*   支持 ACID 事务，对于一些有强一致需求的场景友好，例如：银行转账

*   具有丰富的工具链生态，覆盖数据迁移、同步、备份等多种场景



## CockroachDB

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092043295.png)

​	小强数据库，2015启动，谷歌前员工发起。

​	CockroachDB，目标是打造一个开源、可伸缩、跨地域复制且兼容事务的 ACID 特性的分布式数据库，它不仅能实现全局（多数据中心）的一致性，而且保证了数据库极强的生存能力，就像 Cockroach（蟑螂）这个名字一样，是打不死的小强。

​	CockroachDB 的思路源自 Google 的全球性分布式数据库 Spanner。其理念是将数据分布在多数据中心的多台服务器上，实现一个可扩展，多版本，全球分布式并支持同步复制的数据库。

## 小结

​	本节内容主要针对Mysql的一些新特性以及其他第三方如何对于数据库进行扩展的，同时介绍了数据库的分类，我们可以发现数据库的分类最后都可以按照某种特定的类型进行划分。



# 写在最后

​	本节内容非常简单，读者可以根据相关的内容进行深入学习即可。


