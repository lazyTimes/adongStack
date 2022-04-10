# 三高Mysql - 搭建“三高”架构之复制

# 引言

​	内容为慕课网的《高并发 高性能 高可用 Mysql 实战》视频的学习笔记内容和个人整理扩展之后的笔记，这一节讲述搭建Mysql三高架构中的复制，Mysql的复制在实战中实现比较简单，但是Mysql针对复制的内部优化却是一直在进行，这样说明这是值得重视和学习的内容，所以本节针对复制这一特征介绍相关的理论内容。

​	如果内容比较难可以跟随《Mysql是怎么样运行》个人读书笔记专栏补补课：

​	地址如下：[从零开始学Mysql](https://juejin.cn/column/7024363476663730207)。

## 什么是“三高”架构？

三高架构比较好理解，这里简单过一遍：

- 高并发：同时处理多条事务数高

- 高性能：SQL 执行效率高

- 高可用：系统可用率达到99%以上。

三高是目的不是手段

三高架构的关键在于三个关键字：**复制，扩展，切换**。

复制：数据冗余，binlog传送，并发量提升，可用性提高。缺点是复制会加大服务器的性能开销。

扩展：扩展容量，数据库分片分表，性能和并发量提升。缺点是降低可用性。

切换：主从库提高高可用，主从身份切换，并发量提升。缺点是丢失切换时刻的数据。

这三点对应CAP的理论，CAP中最多只能满足CP或者AP，CAP的理论知识这里略过，结合上面三点可以简单梳理。



三高实现本质：

三高的本质其实就是如何结合复制、扩展、切换三个方法实现三高，我们需要思考下面的三个问题：

*   如何将数据进行冗余？
*   如何有效扩展容量，提高并发性能？
*   如何做主从备份切换，提高高可用？

针对上面三个问题在回到开头提到的三高最终Mysql的三高总结来说就是下面三点：

高并发：复制和拓展，分散多节点

高性能：复制提升速度，拓展容量

高可用：节点之间切换。

&#x20;

# 复制

复制是Mysql中实现高可用的重要功能，复制类型分为三种：**异步复制和半同步复制，组复制**的模式以及新版本带来的GTID复制增强模式。

*   异步复制
*   半同步复制
*   组复制（Mysql5.7新特性）

- GTID 复制模式（Mysql5.6.5之后新增）（减少复制故障）

## 复制原理

**异步复制**

异步复制是非常传统的Mysql复制方式也是实现方式最为简单的一种，异步复制和其名字的意义一样主库在写入binlog之后通知从库数据已经发送然后自己干自己的事情去了，此时从库会主动发起IO请求建立和主库的连接，接着是binlog拷贝到本地写入到relay log中进行重放日志最终sql线程重放然后在最后达到数据一致的效果。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092100092.png)

基本的处理步骤如下：

1.  主节点执行备份线程，读取binlog文件并且发送给从库。

2.  从库的io线程和主库建立连接，使用二进制转储线程读取到binlog文件，如果数据是同步的则睡眠等待主库发送同步信号，否则获取数据把binlog文件保存为relay log，注意从库不会立马执行主库发来的sql，而是会放入到redo log中。

3.  从库会通过sql线程定时读取最新的relay log文件，对于relay log重放，重放之后自己再记录一次binlog日志。（自己再记录一次主要是因为从库本身也有可能是其他子从库的主库，整个过程按照相同的步骤处理）

> 异步复制的问题：
>
> *   读取binlog文件的时候主节点的状态？是否需要锁表？
>
>     主节点此时依然可以正常执行，不需要锁表，因为操作的是二进制的binlog文件。
>     
> *   重放relay log是啥意思？
>
>     relay log：中继日志，relay
>
>     relay：中继。
>
>     重放：重新播放可以认为是重读
>     
> *   从库复制涉及多少线程
>
>     两个，一个IO线程一个SQL线程，IO线程负责从主库获取binlog文件，SQL负责将中继日志进行重放。
>     
> *   为什么从库最后还需要记录一次binlog？
>
>     因为从库也有可能存在自己的子节点，所以也需要按照同样的步骤复制给自己的子节点。
>     
> *   为什么需要relay log中继日志？
>
>     如果备库直接连接主库进行拷贝并且直接执行可能会存在问题，如果此时主库频繁的往binlog塞日志，那么很容易出现主库和备库之间长时间连接并且备库无法正常工作。

异步复制流程图：根据流程图可以看到，在主库执行完sql之后会记录`binlog`文件并且`commit`事务，通过异步的方式把`binlog`发给其他分片上的从库，从库会根据主库的`binlog`重放`relay log`之后最终记录到`binlog`，然后和主库一样完成提交的动作保证数据同步。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092100747.png)

> 问题：
> 如果主库写入binlog但是此时突然断电，但是Binlog已经发送给从节点，此时会出现什么情况？
> 没有影响，因为记录binlog意味着已经完成了事务的操作，即时断电主库也可以通过redo log和bin log恢复数据，由于事务已经提交了，发送给从库出现新增数据也是正常的。

异步复制有下面的特点：

*   对于网络延迟具有一定要求

*   实现方式和原理简单。

*   不能保证日志被送到备库**可能会出现日志丢失**。

通过上面的特点介绍，可以发现异步复制的最大问题就在于异步两个字，由于网络环境的复杂性主库和备库之间是互相分离的，为了确保数据确实送到了从库，Mysql在此基础上改进复制的流程，后面提到的半同步复制其实就在提交之前进行一次“确认”的操作。



**半同步复制**：

如上面所说的，半同步复制其实就在主库发送binlog文件之后没有立马提交事务，而是等待所有的从库接收到了binlog并且写入到relay log之后才进行事务提交，注意这里并不是等所有的从库提交再提交，而是确认接受到binlog转为relay log之后立马就进行提交。

半同步的复制是延迟了主库一定的提交时间，确保主备数据同步。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092058252.png)

> 问题 ：
>
> 半同步复制时间等待过久怎么办？
>
> `rpl_semi_sync_master_timeout` 参数可以配置脱扣时间，脱扣时间是主备库之间的同步过了多少时间超时。



**组复制（Mysql Group Replication）**

组复制是Mysql5.7版本出现的新特性，组复制的核心是确保数据的强一致性，缺点也很明显会导致数据库系统的响应速度受到影响。

介绍：复制组由多个Mysql Server组成，组中的每个成员可以在任何时候独立执行事务，他们内部使用十分复杂的共识算法进行识别

（核心团体通信系统（GCS）协议），组复制的特点是在复制的时候需要保持**强一致性**，如下面的图构造显示，和上面提到了复制方式不

同，在组复制的模式下所有的节点是近似平级关系，通过广播的形式通知改动，当主节点发生binlog变动的时候，需要让其他的同级节点

收到通知验证之后才能进行事务的提交。

读者可能会误解组复制让Mysql实现集群了，然而只是有其行没有其本质组复制只不过是用了些新的对概念包装了一些旧东西罢了，可

以看到组复制的最大痛点在于强一致性的等待时间，看起来很美好，数据似乎永远都不会出现故障绝对能保持一致，实际上这个组复制的

等待时间在很多高并发的系统是没法接受的。



组复制的概念出现于比较新的Mysql版本并且在Mysql8.0中被最终完善，这里找了两篇文章供大家拓展阅读：

*   [Mysql 5.7 基于组复制(Mysql Group Replication) - 运维小结 - 散尽浮华 - 博客园 (cnblogs.com)](https://www.cnblogs.com/kevingrace/p/10260685.html "Mysql 5.7 基于组复制(Mysql Group Replication) - 运维小结 - 散尽浮华 - 博客园 (cnblogs.com)")

*   官方用了一个大节专门吹组复制：[Mysql :: Mysql 8.0 Reference Manual :: 18 Group Replication](https://dev.Mysql.com/doc/refman/8.0/en/group-replication.html "Mysql :: Mysql 8.0 Reference Manual :: 18 Group Replication")


![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204092102095.png)

## 主从复制实战

这里仅仅记录操作，建议读者根据自己的版本进行实验，注意下面的实验在默认的情况下是**异步复制**：

1. 为了模拟复制可以先弄两台linux虚拟机，比如现代144和146两台服务器，安装了同样为5.7版本的Mysql，这个实验中144为主库，146位从库。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204072223302.png)

2. 两个实验数据库的数据库内容如下：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204072225045.png)

3. 两个服务器都需要修改配置ini文件并且开放binlog，图中为部分配置：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204072232530.png)

4. `systemctl restart Mysqld`重启主库的服务器，此时可以通过命令`show master status`和`show slave status`来判断是否构成主备架构。
5. Mysql命令连接主库同时执行`flush tables with read lock`加上全局锁来进行第一次主备数据全量同步，此时可以使用`show master status`查看当前binlog的写入的位置，使用Mysqldump命令进行全量备份。

> 全量备份的使用可以阅读：["三高"Mysql - Mysql备份概览](https://juejin.cn/post/7083744759428317192)中关于Mysqldump复制这一部分的内容。

6. 把备份文件到从库上执行`source xxx.sql`实现主备数据之间的同步，注意此时从库需要和主库一样需要将binlog的日志的写入位置进行同步，而binlog文件的写入位置通过主库的`show master status`进行查看，比如这里从库就需要同步到主库的`.000012`的194位置。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204072241565.png)

7. **关键步骤：**从库如果是slave状态需要通过命令`stop slave`停止slave主库，并且执行`reset slave`重置状态，为了和主库保持同步，需要通过下面的命令同步binlog的写入位置，完成之后通过`show slave status`检查两边是否同步：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204072244328.png)

8. 最后检查是否正常主备复制同步：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204072246296.png)

至此，异步主从复制的实战流程结束，如果我们想要实验半同步复制，需要在`my.ini`中配置半同步的插件 ，因为半同步复制并不是原生支持的，需要额外的插件支持。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204081337686.png)

最后通过`show variances like 'rpl_semi_sync_master_timeout'`可以查看脱扣时间， 通过`show processlist`命令可以查看主节点的当前线程情况。

主节点有下面的线程，可以看到有一个等待Binlog 写入的线程，这是从库等待主库改动binlog的一个线程任务

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204081339997.png)

从节点有两个线程，也可以通过`show processlist`方法查看IO现场和重放relay log的两个线程。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204081341156.png)

## GTID增强复制模式

经过上一个小节的介绍，我们发现传统主备节点复制的操作比较麻烦，特别是LOG_FILE + LOG_POS 的方式处理比较麻烦，根本原因是备库不知道从哪一个log开始进行复制，Mysql针对这一点在更高的版本中提供了全局事务的特性，给每一个事务配置一个唯一ID，也就是Mysql5.6的GTID增强模式，GTID就是 `server_uuid:gno` 组成一个键值对：

- server_uuid（节点的UUID）
- Gno：事务流水号（回滚之后进行回收）

启动GTID模式的配置很简单，在配置文件中加入如下的配置：

- gitd_mode = on
- enforece_gtid_consistency = on

最后使用GTID配置可以修改上一节最后部分提到的`change..master`部分：

```sql
change master to 
MASTER_HOST = 'xx.xx.xx.xx'
MASTER_USER = 'root'
master_auto_position = 1
```

GTID复制是为了增强主从复制减少故障率而出现的，推荐默认开启

## binlog格式格式演变

注意在主从复制中最为关键的binlog格式随着Mysql的升级是做过调整的，在Mysql5.0之前的binlog格式是statement格式，同时内部记录的是原文，而对于一些特殊的语句来说同样的语句可能会有不同的效果，这时候就会有数据风险，比如下面的语句在处理对过程中会出现问题：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082130767.png)

**为什么要使用row格式**

通过上面的介绍，我们大致了解了为什么需要使用row格式，因为row格式**不记录SQL语句的原文**，而是记录数据行的变化。但是row格式依然没有摆脱记录逻辑日志的这一条规则，而记录文本数据数据量比statement更大，之后会出现空间占用比较大的问题 。

进一步改进：mixed格式的binlog

针对binlog的row格式文本存储的问题，Mysql在提供了一种混合row和statement的对混合模式，对于有数据同步风险的使用row格式，而对于没有风险的则直接使用原文。

另外statement和row格式也称为给予语句的复制和给予行的复制，只是说法上的差别而已本质上并没有差别。



## 主备延迟如何处理

首先我们需要了解为什么主备之间存在延迟？

*   log的传送其实开销比较小，主要的消耗是消费relay log的耗时，

*   备库的性能比主库要小很多

*   备库承担了很多分析SQL的任务，压力比主库要打

*   如果主库有长事务没有提交。



通常主备延迟有下面的解决方式：

*   主备之间使用相同配置的机器

*   备库关闭log实时落盘&#x20;

*   使用大数据系统分担日志处理任务



但是上面的处理也不是完美的，存在比较大的缺陷，并且通过上面的处理方式之后，依然没有办法完全排除所有的问题，还有诸如备库的性能由于被动接受复制，性能要比主库大打折扣，主库支持“多线程”而备库限制于“单线程”。



总结上面的内容可以发现主备延迟的特点如下：

*   备库延迟主要是备库执行总是要比主库要慢。

*   通过升级备库的硬件和关闭log实时落盘提高性能

*   增加其他的组件分担复制的压力

*   对于新时代的应用系统，使用“组复制”是官方的推荐选择。



针对上面的问题，Mysql对于传统的复制模式提供了更加细分的解决方式：**并行复制**。并行复制通常有两种思路，第一种是按表分发，第二种是按行分发，以及较新版本出现的事务组并行策略。



并行复制的原理

注意：**Mysql 5.6**的版本才出现并行复制。

并行复制是在主从复制同步的时候，从库在获取到主库的binlog日志并且保存为relay log之后，把重放relay log的任务另外分配一个叫做 worker的线程执行，sql线程则执行分配relay log的任务，从库只需要读取并分配任务不需要自己进行处理，从而更高效的重放relay log。

**难点：如何分配relay log日志**。

这里还涉及几个关联问题：事务存在上下文依赖如何处理？如果存在冲突如何分配处理？（比如新增数据同时并行删除）。

并行复制名称看起来比较高大上，但是最大的问题是**仅仅只是加快了重访relay log的速度**，对于binlog 解析为relay log没有进行更多改进，也就是说把任务分担给了第三者让自己压力小了一点点，但是自己的处理速度和之前基本没太大变化。我们可以通过下面的图进行了解：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082154106.png)



并行复制 - 分配思路：

因为并行复制的难点在于如何分发relay log，Mysql提供了两种分配方式：**按行分配**和**按表分配**。

在最早期还有一种思路出现那就是**按库并行**的策略：这种处理方式是分发选择方式特别快，同时支持各种的log格式分发，但是同时缺点也非常明显，库粒度非常大并且负载均衡非常难。

开启方式：

salve-parallel-type=DATABASE，这是最初配置，由按照库的方式并行复制，这样的处理方式有下面的特点：

* 分发选择非常快，支持各种log格式

* 难以进行负载均衡，库粒度非常大。因为所有的worker实际上都是分配到一个单独的库进行处理，和之前的单线程处理方式并没有太大的却别。

  基于上面的一些问题，在后续的版本中Mysql对于并行复制进行了优化。



当然Mysql不会满足于库的粒度，所以后续基于按库复制基础上出现更多分配的方式：

按行分配：由于binlog记录的是数据行的改动内容，如果修改的不是同一行就可以分配，否则就把他们分配到同一个线程执行。

按表分配：语句按照不同的表进行分类，同一个表的事务放到同一个线程进行分配。

按事务组分配：Mysql5.7提出，使用事务组的方式进行并发提交和处理，下文将会单独介绍。



Mysql按照事务组并行策略（Mysql5.7新特性）

在介绍具体的策略之前，需要解释一下主库对于binlog刷盘的原理，binlog 刷盘分为两步动作，通过这两步动作之后，由此主库的binlog多线程访问，对于多线程事务的提交就可以进行并行刷盘的操作：

1.  binlog → binlog cache 写到binlog内存文件

2.  binlog内存文件刷到磁盘中（fsync 持久化磁盘）



事务组并行策略：

下面这图看起来十分复杂，其实简单理解可以认为每一次同步类似我们一次`ctrl+s`的动作，我们每一次的保存动作都需要刷新到磁盘，在多线程的操作过程中修改先是修改内存，然后按照顺序的进行刷盘。这里有读者可能会疑问，如果线程之间存在事务交叉怎么办？所以这里会依据binlog刷磁盘的逻辑，按照类似按行分配的处理方式将多线程写入到一个binlog缓冲文件之后一次刷新磁盘。

这样事务组并行缓冲合并刷新到方式，使得并行分配肯定会存在下面两种原则：

*   **能够在同一个组里提交的事务，一定不会修改同一行**

*   **主库上可以并行执行的事务，备库上也一定是可以并行执行的**

> 吐槽：其实这个特性说白了还是“抄”了Mysql原作者的思路，这里提一嘴MariaDB 是在 Mysql 版权被 Oracle 收购后，由 Mysql 创始人 Monty 创立的一个开源数据库，其版权授予了“MariaDB基金会（非营利性组织）。果然最了解儿子的还是亲爹。

下面的结构图是按照上面的文字描述的事物组并行策略的改进图：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082204902.png)

可以看到上面的处理方式十分耗费IO性能，并行刷盘频繁浪费性能，可以发现最后一步可以合并前面的并行修改通过一次刷盘完成，所以出现了下面的优化方式：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082205124.png)

事务组的含义就是将下面多个并行刷盘的操作合并为同一个，但是这时候又会有一个疑问到底等待多久合并并且刷新一次磁盘？

Mysql 使用了下面的参数进行控制：

（两个条件是或的关系）

*   binlog\_group\_commit\_sync\_delay：延迟多少微秒之后调用`fsync()`。

*   binlog\_group\_commit\_sync\_no\_dalay\_count：类似多少次之后才调用`fsync()`。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082206544.png)



事务组并行策略优化（Mysql5.7.22版本）

在5.7版本中还存在过一个小版本的升级对于这个策略做了更多的扩展，比如下面的参数：

binlog-transaction-dependency-tracking 参数

*   COMMIT\_ORDER：默认策略

*   WRITESET：没有修改相同行的事务可以并行。

*   WRITESET\_SESSION：同一个线程先后执行两个事务不能并行。

&#x20;&#x20;

## 强制走主库

如何判断备库已经追上去：

*   强制延时

    *   seconds\_behind\_master = 0

*   对比binlog执行位点

*   对比GTID对比情况

但是无法从根本上解决备库延迟的问题，它具备下面几个无法解决的根本性问题：

- binlog 传送和redo log 重放需要时间，这时候受到网络IO或者磁盘IO阻塞的影响
- 备库复制永远只能尽可能减小，无法从本质上完美解决延迟问题。
- 备库因需要

针对次依然可以使用下面的方式判断具体事务是否重放：

- 等待binlog位点：比如通过下面的命令直接监听到具体位置的变动，一旦有变动就认为主库的数据事务完成了。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082210004.png)

- 等待GTID（5.7.6之后每次都会返回GTID），通过下面的命令检查唯一事务ID：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204082212646.png)



## 简单-双主架构

主-主复制架构一半在一些项目比较小或者一些小公司经常使用，主主复制也就是两个库不存在主备关系，而是通过一个热备的库对于主节点宕机之后临时支撑业务使用。简单理解可以理解为柴油发电机，在停电的时候临时充当使用。

*   两个节点均为Master

*   两个节点均为Salve

*   两库的数据互相复制

*   如果其中一个出现问题，立刻切换到另一个库。

![](resource/image/image_b1ERngowWBojB4FGEqyZ5a.png)

主主架构有下面一些比较明显的问题：

*   数据冲突

    *   两边同时插入数据，出现冲突

    *   约定好插入不同ID

    *   只有一些库可写，另一个只读

    *   切换过快的数据库丢失问题。
*   应用切换问题

    *   应用自己切换比较麻烦

    *   keepalived 手段自动切换
*   循环复制问题

    *   理论上的问题。
*   未开GTID：使用ServerID过滤。



## 小结

​	在复制的部分介绍了复制的基本原理以及Mysql复制的三种方式，在5.6之后还提供了GTID的复制模式使得复制的故障率进一步下降，而针对复制的核心一方面是binlog文件，这里简单的介绍了binlog文件的三种写入格式，最早的statement，常用的row和一种推荐的混合模式，然而混合模式使用频率依然不如row多，内部的机制在实践过程中依然发现不少问题。

​	而另一方面则是在整个复制过程中插入“中间层”加快部分操作的处理速度，比如在重放relay log中加入一个worker专门负责处理和分发重放relay log的任务，Mysql在这个relay log重放分发的过程中做文章引入了并行复制，并行复制在早期使用按库的力度分配，这虽然很简单好实现但是因为粒度太大被立马改进，后续出现了按行分配和按表分配，最终出现了按事务组的策略分配，这些内容我们只需要理解，并不要去背诵或则牢记。

​	介绍完主备复制以及相关优化之后，我们切换视角来到了主库这边，主库这边也出现了更优秀的同步策略，那就是直接针对点进行监控，当然这种处理方式比较极端多数情况下不会接触到所以本部分没有过多介绍。

​	最后我们简单介绍了一下双主的架构，适合大部分的中小公司，对于个人开发的开源项目也能基本应付需求。



# 写在最后

​	复制部分仅仅是三高Mysql的第一个大关，后面和还有切换和扩展等着我们介绍，这里也会继续整理给大家带来更多好内容。



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

