
# 三高Mysql - 搭建“三高”架构之扩展与切换

# 引言

​	内容为慕课网的《高并发 高性能 高可用 Mysql 实战》视频的学习笔记内容和个人整理扩展之后的笔记，这一节讲述三高架构的另外两个部分切换和扩展，扩展指的是分库分表减轻数据库的压力，同时因为分库分表需要针对节点宕机问题引入了一些优化手段，而切换部分就是讲述节点宕机的切换问题的，最后我们结合复制的主从切换讲述如何搭建一个三高的架构。

​	如果内容比较难可以跟随《Mysql是怎么样运行》个人读书笔记专栏补补课：

​	地址如下：[从零开始学Mysql](https://juejin.cn/column/7024363476663730207)。

# 扩展

## 分区表

​	Innodb的分区表是指将一个表拆分为多个表但是注意这个概念和分库分表的物理分表有差别，在Innodb中虽然已经在存储引擎进行了划分，实际上分区表在Server层上还是被当成一个表看待。

​	分区表的构建可以看下面的案例：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091442304.png)

​	为了验证Sever层把它当做一个表看待这里可以进入命令行通过下面的命令查看，在截图中可以看到虽然表面上是一个表然而实际上Innodb存储引擎把它们拆分为四个表：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091444404.png)

​

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091445471.png)

 	InnoDB分区存在下面的几种方式：

1. 范围分区：通过数据的存储范围进行划分分区。
2. 哈希分区：通过哈希值进行分区。
3. List分区：针对字段取值的方式进行分区。

​

分区表有下面的特点：

1. 降低Btree树层级，提高搜索查询的效率。
2. 第一次访问需要访问所有分区。
3. **所有分区表共同使用一个MDL锁**，这意味着对于分区表的锁表会同步处理
4. 因为对于server层来说分区表只是一张表，所以分区实际上没有提高性能。

## 分库分表

​	分库分表按照严格来说应该分为分库和分表，分库的处理情况一般比较少更多的是根据业务进行分表的操作，分表通常分为下面几种方式：

垂直分表：垂直分表指的是根据某表的数据按照某种规则冷热进行划分。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091504977.png)

水平分表：水平分表通常按照数据行拆表，这种方式类似把真实的数据行拆分到多个表里面，防止单表数据过大，同时内部使用范围值或者哈希值进行水平分表的数据查找，其中**水平分表最为常用**。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091504311.png)

> 注意本部分讲述的分表和上面的**分区表**是有区别的，在Server层这种分库分表会当作实际的拆分看待而不是同一个表。



而分库的概念现在使用的情况不是特别多了，在分库概念中分为下面的内容：

垂直分库：数据分散在多个数据库或者分到多个节点。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091526372.png)

水平分库：将数据表按照特殊业务规则划分，是每一个库负责各自的主要业务。同时数据库的基本结构配置相同。水平分库通常还有一种场景是较为新的数据和较为老的数据放到不同的库中进行查看，同样和下面的结构图类似。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091526173.png)

分库分表有哪些优缺点呢？

优点：

- 增加隔离性
- 增加并发和隔离性：因为数据结构在server层被看作不同的库和块，
- 和分区表虽然很像，但是本质上完全不一样。

缺点：

- 对于部分失效的特征会成倍的增加和出现。
- **单点事务**不可以实现，需要引入分布式的锁进行控制。
- 垂直分库分表之后不能够join查询，会多写很多SQL。
- 对于范围查询的SQL会存在问题



## Dble和Mycat

简介：这两款中间件都是用于Mysql进行分库分表的市面上使用非常多的主流中间件，Mycat可能更为人熟知而Dble则是在Mycat的基础上更进一步优化和扩展。

基础运行原理：

- 分析查询的SQL语句。
- 把SQL的查询按照中间件算法分发到多个库和多个表进行查询，同时发送到数据节点
- 将数据节点的数据进行聚集合并，最后返回给客户端。

Dble：高性能的Mysql分库分表中间件，由国内一家叫做爱可生的公司进行开发，可以说是国产之光，项目完全开源同时基于另一个开源项目Mycat进行优化和改良，同时这款工具主要是由JAVA编写，对于一些实际使用的问题可以由大部分的开发人员尝试解决。

Dble的设计结构如下，对于客户端来说和平时连接Mysql的分片没有区别然而实际上这是因为Dble内部做了一系列的优化操作：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091543669.png)

Dble的基础概念：

- Schema：虚拟数据库（和传统数据库的Schema不同）。
- ShardingTable：虚拟表，通过虚拟表把数据进行算法划分。
- ShardingNode：虚拟节点，存在数据库的Database中，可以认为一个DB就是一个节点。
- dbGroup：实际的Mysql集群。
- Database：表示实际的Database。

最后我们通过一个简单的分表案例来看看Dble做了哪些操作：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091612714.png)

Dble的分库分表特点是无论分库还是分表都是使用分表来实现的。

在上面的图中可以看到，首先我们的物理表被Dble当作一个shariding table看待，这里的虚拟表在Dble内部首先会被分发到两个Mysql节点，对于Mysql1和Mysql2来说他们之间是**没有任何关系**的双方不知道对方存在的（和上一篇提到的主主架构是不一样的），而Dble则在这两个节点当中的实际db创建了虚拟机节点进行水平分库，内部通过算法分发到不同的库中进行查询，这里的表看起来很小是因为内部实际上有可能还存在其他的虚拟节点，而对于Dble来说是拆分合并到不同的Mysql中管理，这些虚拟节点对于Mysql1和Mysql来说是分开保管的数据，对于Mysql本身来说和普通的数据没有明显感知和区别，真正的数据合并则由Dble完成。



## Dble安装搭建和使用

关于具体的操作使用可以参考官方所写的文档：[Introduction · Dble manual (actiontech.github.io)](https://actiontech.github.io/Dble-docs-cn/)，安装过程这里就略过了我们重点从Dble的配置开始：

首先Dble有几个重要的配置文件：

- [cluster.cnf](https://actiontech.github.io/Dble-docs-cn/1.config_file/1.01_cluster.cnf.html):集群参数配置
- [bootstrap.cnf](https://actiontech.github.io/Dble-docs-cn/1.config_file/1.02_bootstrap.cnf.html):实例参数配置，包括JVM启动参数，Dble性能，定时任务，端口等
- [user.xml](https://actiontech.github.io/Dble-docs-cn/1.config_file/1.03_user.xml.html):Dble 用户配置
- [db.xml](https://actiontech.github.io/Dble-docs-cn/1.config_file/1.04_db.xml.html)：数据库相关配置
- [sharding.xml](https://actiontech.github.io/Dble-docs-cn/1.config_file/1.05_sharding.xml.html)：数据拆分相关配置

注意这些文件在安装好的Dble目录里面都是**模板**，除开部分需要根据自己的Mysql情况修改配置之外，只需要直接改名去掉`_template`即可。

接下来是修改db.xml文件，在这个文件中需要根据自己的数据库节点情况进行相关配置的修改，比如下方截图中的框线部分需要进行改动为自己的Mysql节点配置。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091645543.png)

如果截图看不清也可以参考官方给的一个样板进行修改，需要改的地方都有相关的标识，比较好理解。

```xml
<?xml version="1.0"?>
<Dble:db xmlns:Dble="http://Dble.cloud/">

    <dbGroup name="dbGroup1" rwSplitMode="1" delayThreshold="100">
        <heartbeat errorRetryCount="1" timeout="10">show slave status</heartbeat>
        <dbInstance name="instanceM1" url="ip4:3306" user="your_user" password="your_psw" maxCon="200" minCon="50" primary="true">
            <property name="testOnCreate">false</property>
            <property name="testOnBorrow">false</property>
            <property name="testOnReturn">false</property>
            <property name="testWhileIdle">true</property>
            <property name="connectionTimeout">30000</property>
            <property name="connectionHeartbeatTimeout">20</property>
            <property name="timeBetweenEvictionRunsMillis">30000</property>
            <property name="idleTimeout">600000</property>
            <property name="heartbeatPeriodMillis">10000</property>
            <property name="evictorShutdownTimeoutMillis">10000</property>
        </dbInstance>

        <!-- can have multi read instances -->
        <dbInstance name="instanceS1" url="ip5:3306" user="your_user" password="your_psw" maxCon="200" minCon="50" primary="false">
            <property name="heartbeatPeriodMillis">60000</property>
        </dbInstance>
    </dbGroup>
</Dble:db>
```

接下来是修改`user.xml`部分，这部分需要注意有**managerUser**和**shardingUser**两个角色，一个是管理员负责管理Dble的用户，另一个sharingUser则需要建表权限对于客户端请求进行分库分表。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Dble:user xmlns:Dble="http://Dble.cloud/">
    <managerUser name="man1" password="654321" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false"/>
    <managerUser name="user" usingDecrypt="true" readOnly="true" password="AqEkFEuIFAX6g2TJQnp4cJ2r7Yc0Z4/KBsZqKhT8qSz18Aj91e8lxO49BKQElC6OFfW4c38pCYa8QGFTub7pnw==" />

    <shardingUser name="root" password="123456" schemas="testdb" readOnly="false" blacklist="blacklist1" maxCon="20"/>
    <shardingUser name="root2" password="123456" schemas="testdb,testdb2" maxCon="20" tenant="tenant1">
        <privileges check="true">
            <schema name="testdb" dml="0110">
                <table name="tb01" dml="0000"/>
                <table name="tb02" dml="1111"/>
            </schema>
        </privileges>
    </shardingUser>
    <!--rwSplitUser not work for now-->
    <rwSplitUser name="rwsu1" password="123456" dbGroup="dbGroup1" blacklist="blacklist1"
                 maxCon="20"/>
    <blacklist name="blacklist1">
        <property name="selectAllow">true</property>
    </blacklist>
</Dble:user>
```

最后我们来看看Dble的核心配置`sharing.xml`，根据官方的介绍他有下面的三个部分的主要内容。

- schema (虚拟schema，可配置多个)
- shardingNode (虚拟分片，可配置多个)
- function (拆分算法，可配置多个)

支持的分区算法： 目前已支持的分区算法有: hash, stringhash, enum, numberrange, patternrange, date，jumpstringhash，具体的分区算法细节可以阅读文档相关内容介绍，这里就不过多介绍了。

目前国内使用的案例比较少这里实战部分直接找了一篇博客，这里就不做演示Dble的分库分表了，有需要的时候再回来看看即可：

[Dble分库分表实战_李如磊的技术博客_51CTO博客](https://blog.51cto.com/lee90/2434496)



如何提高分库分表性能？

提高分库分表性能问题首先想到的是搭建多个主备节点将主备复制和Dble进行结合。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204091725639.png)

其次可以在Dble上配置读写分离，配置读写分离同样可以参考官方文档。



## 分库分表存在问题

dble自动管理分库分表实际上也是存在下面的问题的，而dble是基于mycat进行处理的，下面的规则对于分库分表来说都会有类似的问题：



查询语句中需要尽可能的带有拆分字段：

- dble 根据拆分字段判断数据节点的位置。
- 无法判断数据节点**只能遍历所有的节点**。这一点会导致分库分表查询的负优化



插入的语句同样必须带有拆分的字段：

- Dble 根据拆分的字段，判断数据在那个点 。



拆分尽量使用等值条件：

- 范围拆分字段会导致过多节点扫描。
- 使用IN语句缩减IN子句点值的数量。



减少表搜索遍历：

下面这些动作都会对于性能造成影响

- 不带拆分字段。
- Distinct，group by，order by。



减小结果集：

- 数据交互会导致查询性能受到影响。
- 分布式系统导致节点大量的数据交互。



跨节点连表：

- 对于经常join的表需要按照固定的规则拆分。
- 使用拆分字段作为join条件。
- 尽量对于驱动表增加更多过滤条件。
- 尽量减少数据的分页。
- 复杂语句拆分为简单语句。



上面的内容小结如下：

- 减少数据交互。
- 数据增删改查需要增加拆分字段。
- 连接键进行拆分处理。



# 切换

切换的核心是**保业务**还是**保数据**？

如何进行身份切换：

*   停止备库同步

*   配置主库复制从库。

*   复制是一种平级的关系，可以独立。

切换策略：

单纯从切换策略卡率我们可以看到存在下面的两种方式：

*   可靠优先策略：意味着seconds\_behind\_master参数不能过大不能落后库太大。需要把A库切换为只读的形式，这时候业务只能读取不新增数据，当seconds\_behind\_master=0的时候意味着两个库同步。此时A库停止，B库停止复制A，A库开始复制B库。这个可靠说明的是数据可靠，但是不保证业务不受影响，因为最大的问题来自于停机。

*   可用性策略：取消等待数据的一致过程，A库只读B库关闭只读，B库停止复制A库，A库开始复制B库，优点是系统没有不可写时间，缺点是切换的时候如果有没有及时重放的relay log容易导致数据不一致。

​	对于大多数普通业务执行尽量选用**可靠优先策略**，但是如果对于业务高可用严格建议可用性策略，比如日志流水同样需要可用性，对于一些数据要求强一致性的比较低允许一定数据丢失的业务则可以考虑使用可用性策略。



## 业务如何切换？

*   预留接口，通知连接到新的数据库地址。
*   微服务框架通知业务，比如注册中心。
*   内部使用DNS，域名连接，切换之后刷新DNS处理。

    *   K8S使用了这种方式实现处理。
*   keepalived 进行VIP漂移。通过检测处理优先级处理。
*   代理的方式切换：加一层代理负载均衡处理。
*   Dble的时候主备切换



## 自动主从切换

**keepalived** 如何主备切换？

keepalive是经常被使用的中间件，在自动主从切换中它担任了身份切换和VIP飘移的角色，VIP即Virtual IP Address，是实现HA（高可用）系统的一种方案，高可用的目的是通过技术手段避免因为系统出现故障而导致停止对外服务，一般实现方式是部署备用服务器，在主服务器出现故障时接管业务。 VIP用于向客户端提供一个固定的“虚拟”访问地址，以避免后端服务器发生切换时对客户端的影响。

> Keepalived的设计目的即是为了管理VIP，因此使用Keepalived实现VIP的配置非常简单。Keepalived采用了[Virtual Router Redundancy Protocol (VRRP)](https://rascaldev.io/2017/12/23/vip-management-with-keepalived/)协议来进行实现主备服务器之间的通信以及选举。

keepalive的主从切换类似下面的对方式，当比如当MysqlA服务宕机会自动切换到下一个A`的服务器提供服务，内部通过一定的选举算法选举出新节点。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204100859027.png)



**Mha（master high availability）** 如何进行主备切换？

Mha也是常用的Mysql高可用组件，它通过自研主从切换的概念完成主备切换，这个组件由facebook工程师进行开发，同时支持GTID的方式，最大特点：在宕机的时候第一时间登陆宕机服务器下载binlog日志。但是Mha最大的问题是无法进行VIP漂移。

根据下面的图可以看到，在Mha的工作机制当中，如果发现A节点的服务宕机此时会立刻登陆到A节点的服务器把文件进行抢救，但是这里存在复制的数据同步问题，在半同步复制中会有 **脱扣**时间导致binlog传送转变为异步传送有可能会出现binlog没有传递过来的情况，这种情况下有可能会导致其他数据的不完整导致数据不同步。

值得一提的是Mha的并不是直接通过客户端访问宕机节点而是需要等待SLAVE节点的数据落库之后再通过从库访问主库抢救binlog，这些操作基本都是来自于设计者日常工作经验中发现的一些问题针对的特殊处理所以十分受到广大开发者的青睐。



![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204100912367.png)



当抢救binlog任务完成之后，Mha 的下一步是重新选去Master，注意宕机的节点不会用脚本尝试重启恢复，因为这种情况下不通过人为干预通常已经没有太大的效果了，即使重启也有可能会有数据不一致的问题。



## 三高系统搭建

在搭建三高之前，我们需要思考为什么有时候集群搭建起来了为什么还会挂？原因是任何一个成熟的单一系统都不会单纯依赖某一个开源组件而是在中间层加入大量的容错机制防止某一组件崩盘造成大面积的损失，这里涉及到DRDS的概念，DRDS表示（Distributed Relational Database Service）分布式的Mysql集群，而Mysql的集群通常不会是本身的集群，而是通过一系列的中间件维持三高的基本特征。

接下来我们一步步来看下三高系统是如何搭建的：

分库分表有一个问题点：我们发现当dble出现问题的时候会导致整个服务不可用，Dble的单点问题这里我们后续进讨论，这里出现了Mha和Dble联动来解决Mysql节点宕机的问题。

> 对于开发人员来说日常实践过程基本碰不到这个东西这里同样找了一篇在需要的时候进行学习大致的搭建流程和一些基本配置即可：
>
> ​	[爱可生DBLE Mha-dble高可用联动实例](https://www.modb.pro/db/202713)



下面是Mha结合DBLE对于整个架构的增强结构图：

通过Mha和dble的搭配，当节点出现宕机的时候可以通过Mha进行节点的切换保证分库分表的正常工作。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092109048.png)

但是我们还发现一个问题那就是dble本身也是单点的，所以dble也需要做集群的负载均衡防止整个节点不可用，而对于dble的负载分发可以通过Haproxy结合zookeeper进行处理。

> HAProxy 是一款提供高可用性、负载均衡以及基于TCP（第四层）和HTTP（第七层）应用的代理软件，支持虚拟主机，它是免费、快速并且可靠的一种解决方案。 HAProxy特别适用于那些负载特大的web站点，这些站点通常又需要会话保持或七层处理。HAProxy运行在时下的硬件上，完全可以支持数以万计的 并发连接。并且它的运行模式使得它可以很简单安全的整合进您当前的架构中， 同时可以保护你的web服务器不被暴露到网络上。

> ZooKeeper是一个集中式服务，用于维护配置信息、命名、提供分布式同步和提供组服务。所有这些类型的服务都以某种形式被分布式应用使用。每次实现这些服务时，都有大量的工作用于修复不可避免的错误和竞争条件。由于实现这类服务的难度，应用程序最初通常会忽略它们，这使得它们在变化的情况下变得很脆弱而且难以管理。即使做得正确这些服务的不同实现也会导致应用程序部署时的管理复杂性。

最后客户端通过keepalive的VIP飘移寻找网关的入口，经过选举分发之后找到对应的dble，dble再进行分库分表查找相关的数据进行处理，最后找到相关的Mysql节点汇总数据之后返回给客户端，当Mysql节点出现问题的时候，Mha则会通过一系列的脚本抢救binlog文件之后重新选举主从节点。

至此一个三高架构的分布式Mysql集群的完整结构完成，我们把上面的文字用结构图表示可以看到还是十分复杂的：



![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092150995.png)



## 总结

​	本部分内容讲述了Mysql分区表特性，以及一个国产开源的分库分表插件，其实分库分表对于大部分的中小项目基本都是不需要的，它通常出现在比较大的系统架构当中，dble作为一款国产开源组件有着不错的表现，在Mycat的基础上改进的同时使用JAVA语言编写十分贴合WEB开发人员的喜好。

​	在切换的部分我们讲述了另外两个组件：MHA和Keepalive，这两个组件由大量的资源和案例参考，所以这里简单拿来介绍它们是如何和Mysql进行组合增强集群架构的高可用特性的，



# 写到最后

​	三高架构看起来十分复杂并且高大上，然而实际上我们把组件拆分完成之后发现各个组件的角色分工非常明确，作用也比较明显。当然这些内容可能更多是运维会接触到和使用到，对于开发人员来说这些内容只需要简单了解流程和理论即可。

