# 三高Mysql - Mysql索引和查询优化（偏理论部分）

# 引言

​	内容为慕课网的"高并发 高性能 高可用 MySQL 实战"视频的学习笔记内容和个人整理扩展之后的笔记，本节内容讲述的索引优化的内容，另外本部分内容涉及很多优化的内容，所以学习的时候建议翻开《高性能Mysql》第六章进行回顾和了解，对于Mysql数据的开发同学来说大致了解内部工作机制是有必要的。

​	由于文章内容过长，所以这里拆分为两部分，上下部分的内容均使用**sakila-db**，也就是mysql的官方案例。第一部分讲述优化的理论和Mysql过去的优化器设计的缺陷，同时会介绍更高的版本中如何修复完善这些问题的（但是从个人看来新版本那些优化根本算不上优化，甚至有的优化还是照抄的Mysql原作者的实现的，发展了这么多年才这么一点成绩还是要归功于Oracle这种极致商业化公司的功劳）。

> 如果内容比较难，可以跟随《Mysql是怎么样运行》个人读书笔记专栏补补课，个人也在学习和同步更新中。
>
> 地址如下：https://juejin.cn/column/7024363476663730207。



# 【知识点】

- Mysql索引内容的介绍
- 索引的使用策略和使用规则
- 查询优化排查，简单了解Mysql各个组件的职责



# 前置准备

## sakila-db

​	sakila-db是什么？国外很火的一个概念，指的是国外的电影租赁市场使用租赁的方式进行电影的观看十分受外国的喜欢。这里介绍是因为后续的内容都用到了这个案例。所以我们需要提前把相关的环境准备好，从如下地址进行下载：

​	下载地址：https://dev.mysql.com/doc/index-other.html

> 《高性能Mysql》的SQL 案例也是使用官方的example

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/202203201510470.png)

## work-bench

​	work-bench是官方开发的数据库关系图的可视化工具，使用官方案例的具体关系图展示效果如下，通过这些图可以看到Sakila-db之间的大致关系：

> work-bench也是开源免费软件，下载地址如下：
>
> https://dev.mysql.com/downloads/workbench/

![sakila-db示意图](https://gitee.com/lazyTimes/imageReposity/raw/master/img/202203201508589.png)

​	安装workbench和下载sakila-db的方式这里不做记录，在运行的时候需要注意先建立一个数据库运行sheme文件，然后执行data的sql文件，最终在navicat中查看数据：

![数据库关系图](https://gitee.com/lazyTimes/imageReposity/raw/master/img/202203201521740.png)

# 正文部分

## 索引类型

​	首先是索引的特点以及作用：

1. 索引的目的是为了提升数据的效率。

2. 对于ORM框架来说索引的使用至关重要，但是ORM的优化往往难以顾及所有业务情况，后续被逐渐废弃。

3. 不同的索引类型适用于不同的场景。

4. 索引关键在于减少数据需要扫描的量，同时避免服务器内部对内容排序和临时表（因为临时表会索引失效），随机IO转顺序IO等特点

​	

​	下面介绍Mysql相关的索引类型：

- 哈希索引：哈希索引适合全值匹配和精确查找，查询的速度非常快 在MySQL中只有memory存储引擎显式支持此索引，memory还支持非唯一哈希索引的，是哈希索引设计里面比较特殊的。
- 空间索引：空间索引是myisam表支持，主要用作地理数据存储，这里包含一个叫做GIS的玩意，但是GIS在Postgre中使用比MySQL要出色很多，所以mysql中空间索引是无关紧要的东西。
- 全文索引：全文索引也是myisam独有支持的一种索引类型。适合使用的场景为全值匹配的场景和关键字查询，对于大文本的关键字匹配可以有效处理。
- 聚簇索引：聚簇索引是innodb存储引擎的默认存储引擎。
- 前缀压缩索引：注意这个索引针对的是myisam存储引擎，目的是为了让索引放入内存中排序，，前缀压缩的方法是首先保存索引块的第一个值，然后在保存第二个值，存储第二个值类似（长度,索引值）的形式存放前缀索引。

其他索引类型注意事项：

​	Archive 在5.1之后才支持单列自增索引。

​	MyISAM 支持压缩之后的前缀索引，使得数据结构占用更小。



**哈希索引**

​	在Mysql中唯一显式实现哈希索引的存储引擎为Memory，Memory是存在非唯一哈希索引，同时BTree也支持“自适应哈希索引的方式“兼容哈希索引。



下面是哈希索引特点：

- 键存储的是索引哈希值，注意不是索引值本身，而值存储的是指向行的指针
- 注意此哈希索引无法避免行扫描，但是在内存中指针非常快通常可以忽略不计
- 注意只有哈希值按照顺序排序，但是行指针不是按照顺序排序
- 哈希不支持：部分索引覆盖，只支持全索引覆盖，因为使用全部的索引列计算哈希值
- 哈希索引支持等值匹配操作不支持范围查询，比如等于，in子查询，不全等。
- 如果出现哈希冲突，哈希索引将退化为链表顺序查询，同时维护索引的开销也会变大



**聚簇索引**

​	聚簇表示数据行的值紧凑存储在一起。而innodb聚簇的值就是主键的值，所以通常使用都是主键上的索引，针对主键索引的选择十分重要。由于本部分着重索引优化，聚簇索引这里就不再讲述了。

​	MyISam和Innodb的主键索引区别是MyISam的索引很简单，因为数据行只包含行号，所以索引**直接存储列值和行号**，数据单独存放另一处，类似于一个唯一非空索引，索引和数据不在一处，MyISam的索引设计比InnoDB简单很多，这和MyIsam不需要支持事务也有直接关系，而innodb将索引和行数据放入一个数据结构，将列进行紧凑的存储。

​	

聚簇索引有下面优点

- 紧凑存储数据行，所以可以只扫描少量磁盘就可以获取到数据
- 数据访问的速度非常快，索引和数据放在同一颗BTree中，比非聚簇索引查询快很多
- 覆盖索引可以直接**减少回表**



当然索引也有下面的缺点：

- 对于非IO密集型应用，聚簇索引的优化无意义。
- 插入速度依赖于插入顺序，但是如果不是自增插入则需要optimize table重新组织表。
- 更新代价非常高，因为BTree要保证顺序排序需要挪动数据页位置和指针。
- 主键数据插入过满数据页存在页分裂问题，行溢出会导致存储压力加大。
- 聚簇索引导致全表扫描变慢，页分裂导致数据问题等。
- 二级索引需要回表查询聚簇索引才能查询数据。
- 二级索引由于需要存储主键开销会更大，至少在InnoDb中维护一个二级索引的开销是挺大的。



压缩索引

​	压缩索引的特点是使用更少的空间存放尽可能多的内容，但是这样的处理方式仅仅适用于IO密集型的系统，压缩前缀存储形式最大的缺陷是无法使用二分法进行查找，同时如果使用的倒序索引的方式比如order by desc 的方式可能会因为压缩索引的问题存在卡顿的情况。



Bree索引的特点

- 叶子结点存在逻辑页和索引页两种，通常非最底层叶子结点都是索引页，最底层索引页由链表串联。

- Btree索引会根据**建表顺序**对于索引值进行排序，索引建表时候建议将经常查询的字段往前挪。

- Btree索引适合的查询类型：**前缀查询，范围查询，键值查询（哈希索引）**。



自适应哈希索引

​	当innodb发现某些索引列和值使用频繁的时候，BTree会在此基础上自动创建哈希索引辅助优化，但是这个行为是不受外部控制的，完全是内部的优化行为，如果不需要可以考虑关闭。



Btree查询类型

​	针对Innodb的Btree索引，有下面几种常见的查询方式：

- 全值匹配：等值匹配的方式，全值匹配适合哈希索引进行查询
- 最左匹配原则：二级索引的查询条件放在where最左边
- 前缀匹配：只使用索引的第一列，并且like ‘xxx%’
- 范围匹配：范围匹配索引列到另一列之间的值
- 范围查询和精确匹配结合，一个全值匹配，一个范围匹配
- 覆盖索引查询：覆盖索引也是一种查询方式，



## 索引策略

​	下面是关于建立索引的一些常见策略：

1. 第一件事情需要考虑的是预测那些数据为热点数据或者热点列，按照《高性能Mysql》介绍，对于热点列来说有时候要违背最大选择性的原则，通过建立时常搜索的索引作为最左前缀的默认的设置。同时优化查询需要考虑所有的列，如果一个查询的优化会破坏另一个查询，那么就需要优化索引的结构。
2. 第二件事情是考虑where的条件组合，通过组合多种where条件，需要考虑的是尽可能让查询重用索引而不是大规模的建立新索引。
3. 避免多个范围进行扫描，一方面是范围查询会导致，但是对于多个等值的条件查询，最好的办法是尽量控制搜索范围。

​	

​	对于索引的策略我们还需要了解下面的细节

- 单行访问很慢，特别是随机访问要比顺序访问要慢更多，一次性加载很多数据页会造成性能的浪费。
- 顺序访问范围数据很快，顺序IO的速度不需要多磁道查找，比随机的访问IO块很多，顺序访问也可以使用group by进行聚合计算。
- 索引覆盖速度很快，如果查询字段包含了索引列，就不需要回表。



索引碎片优化

​	Innodb的数据结构和特性会导致索引存在数据碎片，对于任何存储结构来说顺序的存储结构是最合适的，并且索引顺序访问要比随机访问快更多，数据存储的碎片比索引本身复杂很多，索引碎片通常包含下面的情况：

- 行碎片：数据行的数据被存储在多个数据页当中，碎片可能会导致性能的下降。
- 行间碎片：逻辑顺序上的页，行在磁盘上不顺序存储，行间数据碎片会导致全表扫描。
- 剩余空间碎片：数据页的间隙有大量的垃圾数据导致的浪费。

​	对于上面几点，对于myisam 都有可能出现，但是innodb的行碎片不会出现，内部会移动碎片重写到一个片段。

​	索引碎片的处理方式：在Mysql中可以通过`optimize table `导入和导出的方式重新整理数据，防止数据碎片问题。

​	

索引规则

- 索引必须按照索引顺序从左到右匹配
- 如果在查询中间出现范围，则范围查询之后的索引失效
- 不能跳过索引列的方式查询（和B+tree索引数据结构设计有关系）

​	接着是索引顺序问题，由于BTree的结构特性，索引都是按照建立顺序进行查找的，通常不包含排序和分组的情况下，把选择性最高的索引放在最左列是一个普遍正确策略。

​	如何查看索引基数：`show index from sakila.actor`，还有一种方式是通过`information_schema.statistics` 表查询这些信息，可以编写为一个查询给出选择性较低的索引。

​	当innodb打开某些表的时候会触发索引信息的统计，比如打开`information_schema`表或者使用`show table status`和`show index`的时候，所以如果在系统要运行压力较大的业务时期尽量避开这些操作。



**冗余重复索引**

​	Mysql允许同一个列上创建多种类型的索引，有时候会因为建表的特性问题给字段重复建索引造成不必要的性能浪费。冗余索引和重复索引有什么区别？

​	冗余索引：是符合最左匹配法则的情况下重复对相同列建立索引。

​	重复索引：是对于不最做的方式创建的索引就有可能是重复创建索引。

​	比如联合索引：(A,B) 如果在创建 （A）或者（A，B）都是重复索引，但是创建（B）就不是重复索引而是冗余索引。另外某些十分特殊的情况下可能用到冗余索引，但是这会极大的增加索引维护的开销，最为直观的感受是插入、更新、删除的开销变得很大。



**多列索引**

​	首先多列索引不是意味着`where`字段出现的地方就需要加入，其次多列索引虽然在现在主流使用版本中（5.1版本之后）实现了索引内部合并，也就是使用`and or`或者`and`和`or`合并的方式相交使用索引，但是他存在下面几个缺点

- 内部优化器的合并和计算十分耗费CPU的性能，索引反而增加数据查询复杂度，效率也不好
- 往往会存在优化过度的情况，导致运行效果还不如全表扫描
- 出现多列索引合并通常意味着建立索引的方式不对，存在反向优化的嫌疑



**文件排序**

​	文件排序遵循Innodb的Btree索引的最基本原则：**最左前缀原则**，如果索引列的顺序和order by排序一致，并且查询列都和排序列都一样才会用索引替代排序，对于多表查询则排序字段**全为第一个表**才能进行索引排序。但是有一个特例那就是排序字段的前导列为**常量**的时候依然可以使用索引排序。

​	案例：rental 表的联合索引列进行排序

> Backward index scan 是 MySQL-8.0.x 针对上面场景的一个专用优化项，它可以从索引的后面往前面读，性能上比加索引提示要好的多

```sql
EXPLAIN select rental_id,staff_id from rental where rental_date = '2005-05-25' order by inventory_id desc, customer_id asc;
-- 1 SIMPLE rental ref rental_date rental_date 5 const 1 100.00 Using filesort

EXPLAIN select rental_id,staff_id from rental where rental_date = '2005-05-25' order by inventory_id desc;
-- Backward-index-scan
-- Backward index scan 是 MySQL-8.0.x 针对上面场景的一个专用优化项，它可以从索引的后面往前面读，性能上比加索引提示要好的多
-- 1 SIMPLE rental ref rental_date rental_date 5 const 1 100.00 Backward index scan

EXPLAIN select rental_id,staff_id from rental where rental_date = '2005-05-25' order by inventory_id, staff_id;
-- 1 SIMPLE rental ref rental_date rental_date 5 const 1 100.00 Using filesort
-- 无法使用索引
EXPLAIN select rental_id,staff_id from rental where rental_date > '2005-05-25' order by inventory_id, customer_id;
-- 1 SIMPLE rental ALL rental_date 16008 50.00 Using where; Using filesort

EXPLAIN select rental_id,staff_id from rental where rental_date = '2005-05-25' and inventory_id in (1,2) order by customer_id;
-- 1 SIMPLE rental range rental_date,idx_fk_inventory_id rental_date 8 2 100.00 Using index condition; Using filesort

explain select actor_id, title from film_actor inner join film using(film_id) order by actor_id;
-- 1 SIMPLE film index PRIMARY idx_title 514 1000 100.00 Using index; Using temporary; Using filesort
-- 1 SIMPLE film_actor ref idx_fk_film_id idx_fk_film_id 2 sakila.film.film_id 5 100.00 Using index
```



## 查询优化排查

​	查询优化的排查意味着我们需要先了解Mysql的各个组件在各步骤中做了哪些事情，下面这张图来自于《高性能Mysql》，对于一次客户端的请求，大致分为下面的流程：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/202203212336431.png)

1. 客户端发送请求

2. 服务器查询执行缓存

   - 不重要，8.0之后已经删除

3. 服务端进行SQL解析和预处理

   - 权限检查
   - 词法解析
   - 语法树

4. **优化器生成执行计划**

   - 优化器存在的问题？

   - 优化器如何工作？

5. 根据执行计划调用存储引擎的APi接口执行查询

6. 结果返回客户端

​	对于关系型的数据库来说，核心部分在于查询优化器和执行计划的部分，因为不管我们如何编写SQL语句，如果没有强大的优化器和执行计划那么一切都是空谈，所以本部分的重点也会围绕优化器进行讲解，在此之前我们先看看其他组件的工作：

​	首先查询缓存不需要过多解释，他的作用是当用户重复执行一个查询的时候会内部对于结果进行缓存，但是一旦用户修改查询条件，缓存就失效了，在早期的互联网环境中这种处理很不错，可以减少磁盘IO和CPU的压力，但是到了现在的环境下显然不适合，所以8.0删除也是可以理解的。

​	接着是解析器，解析器这部分主要工作是通过解析语法形成解析树对于语句进行预处理，预处理可以类看作我们编译器把我们写的编程语句“翻译”为机器代码的过程，让下一步的优化器可以认识这颗解析树去进行解析，

​	如果想要了解SQL解析优化的底层过程，可以从这篇文章入手：

​	[SQL解析在美团的应用 - 美团技术团队 (meituan.com)](https://tech.meituan.com/2018/05/20/sql-parser-used-in-mtdp.html)

​	在上面的博客中提到了一个DBA必须掌握的工具**pt-query-digest**，分析慢查询日志，下面这个文章中提供了一个实际的案例来排查和优化，案例较为简单适合刚接触这个工具的人进行学习和思考，这里一并列出来了。

​	[使用 pt-query-digest 分析 RDS MySQL 慢查询日志 | 亚马逊AWS官方博客 (amazon.com)](https://aws.amazon.com/cn/blogs/china/pt-query-digest-rds-mysql-slow-searchnew/)

> SQL解析部分笔记：
>
> 词法分析：核心代码在sql/sql_lex.c文件中的，`MySQLLex→lex_one_Token`
>
> **MySQL语法分析树生成过程**：全部的源码在`sql/sql_yacc.yy`中，在MySQL5.6中有17K行左右代码
>
> 最核心的结构是SELECT_LEX，其定义在`sql/sql_lex.h`中



​	下面我们来深入看看优化器的部分工作内容以及Mysql优化历史：

​	由于讲述优化器的内容较少，这里直接总结《高性能Mysql》的内容，优化器也不需要研究和记忆，因为随着版本的迭代不断更新优化器会不断调整，一切要以真实实验为准：

**1. 子查询关联**：

​	下面的查询在通常情况下我们会认为先进行子查询，然后通过for循环扫描film表进行匹配操作，然后从explain的结果中可以看到这里的查询线进行了全表扫描，然后通过关联索引进行第二层的for循环查询，这样的写法类似`exists`。

```sql
explain select * from sakila.film where film_id in (select film_id from film_actor where actor_id)
-- 1	SIMPLE	film		ALL	PRIMARY				1000	100.00	
-- 1	SIMPLE	film_actor		ref	idx_fk_film_id	idx_fk_film_id	2	sakila.film.film_id	5	90.00	Using where; Using index; FirstMatch(film)
```

​	优化这个子查询的方式使用关联查询替代子查询，但是需要注意这里存在where条件才会走索引，否则和上面的结果没有区别：

```sql
explain select film.* from sakila.film film  join film_actor actor using (film_id) where actor.actor_id = 1
```

​	另一种是使用exists的方式进行关联匹配。

```sql
explain select * from film where exists (select * from film_actor actor where actor.film_id =  film.film_id and actor.actor_id = 1);
```

​	可以看到哪怕到了5.8的版本，Mysql的子查询优化既然没有特别大的改进，所以通常情况下如果不确定in查询的内容大小，建议用exists或者join进行查询，另外也不要相信什么in查询就一定慢点说法，在不同的mysql优化器版本中可能会有不同的效果。

**2. union查询**

​	虽然多数情况下我们会用union替换or，但是更多的情况是应该尽量避免使用union，因为union查询会产生临时表和中间结果集容易导致优化索引失效，需要注意的是 **union**会触发内部的排序动作，也就是说union会等价于`order by`的排序，如果数据不是强烈要求不能重复，那么更建议使用union all，对于优化器来说这样工作更加简单，直接把两个结果集凑在一起就行，也不会进行排序。

​	union查询能不用就不用，除非是用来代替or查询的时候酌情考虑是否有必要使用。

​	最后注意union的产生排序不受控制的，可能会出现意料之外的结果。

**3. 并行查询优化**

​	并行查询优化在8.0中终于有了实现，可以根据参数：`innodb_parallel_read_threads =并行数`来验证。

​	由于个人是M1的CPU，读者可以根据自己的实际情况进行实验。

```sql
set local innodb_parallel_read_threads = 1;
select count(*) from payment;
set local innodb_parallel_read_threads = 6;
select count(*) from payment;
```

从执行结果可以看到仅仅是1万多条数据的count(*)查询就有明显直观的差距：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204051714387.png)

**4. 哈希关联**

​	官方文档的介绍地址：[Mysql官方文档哈希关联](https://dev.mysql.com/doc/refman/8.0/en/hash-joins.html)

​	在MySQL 8.0.18中Mysql终于增加了哈希关联的功能。在此之前的版本中，Mysql的优化器通常只支持for循环嵌套关联，曲线救国的方法是建立一个哈希索引或者使用Memory存储引擎，而新版本提供的哈希关联则提供了一种新的对关联方式，哈希关联的方式如下：

​	把一张小表数据存储到**内存**中的哈希表里，通过匹配大表中的数据计算**哈希值**，并把符合条件的数据从内存中返回客户端。	

​	对于Mysql的哈希关联，我们直接使用官方的例子：

```sql
CREATE TABLE t1 (c1 INT, c2 INT);
CREATE TABLE t2 (c1 INT, c2 INT);
CREATE TABLE t3 (c1 INT, c2 INT);

EXPLAIN
     SELECT * FROM t1
         JOIN t2 ON t1.c1=t2.c1;
-- Using where; Using join buffer (hash join)
```

​	除开等值查询以外，Mysql的8.0.20之后提供了更多的支持，比如在 MySQL 8.0.20 及更高版本中，连接不再需要包含至少一个等连接条件才能使用哈希连接，除此之外它还包括下面的内容：

```sql
-- 8.0.20 支持范围查询哈希关联
EXPLAIN  SELECT * FROM t1 JOIN t2 ON t1.c1 < t2.c1;
-- 8.0.20 支持 in关联
EXPLAIN  SELECT * FROM t1 
        WHERE t1.c1 IN (SELECT t2.c2 FROM t2);
-- 8.0.20 支持 not exists 关联
EXPLAIN  SELECT * FROM t2 
         WHERE NOT EXISTS (SELECT * FROM t1 WHERE t1.c1 = t2.c2);
-- 8.0.20 支持 左右外部连接
EXPLAIN SELECT * FROM t1 LEFT JOIN t2 ON t1.c1 = t2.c1;
EXPLAIN SELECT * FROM t1 RIGHT JOIN t2 ON t1.c1 = t2.c1;
```



> 注意8.0.18版本的哈希关联**仅仅支持join查询**，对于可能会带来笛卡尔积的左连和右连接查询是不支持的。但是在后续的版本中提供了更多查询条件支持
>
> 另外，8.0.20版本之前想要查看是否使用hash join，需要结合 `format=tree` 选项。

![哈希关联](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204051721828.png)

​	最终Mysql在8.0.18版本中曾经提供过开关哈希索引和设置优化器提示`optimizer_switch`等参数来判定是否给予hash join的提示，真是闲的蛋疼（官方自己也这么认为）所以在8.0.19立马就把这些参数给废弃。

​	注意哈希连接不是没有限制的，了解哈希关联的流程就会发现如果哈希表过大，会导致整个哈希关联过程在磁盘中完成其速度可想而知，所以官方提供了下面的建议：

- 增加`join_buffer_size`，也就是增加哈希关联的哈希表缓存大小，防止进入磁盘关联。
- 增加`open_files_limit`数量，这个参数什么意思这里就不介绍了，意义是增加这个参数可以增加关联的时候关联次数。

> 吐槽：说句心里话自Mysql被Oracle收购之后，越来越商业化的同时进步也越来越小，in查询优化这一点其实在很多开源库甚至Mysql的原作者给解决了，但是Mysql到了8.0依然和多年前的《高性能Mysql》结果没有差别。哎。。。。。
>
> Mysql数据库的发展也告诉我们时刻保持开放的心态，吸取教训正视不足和改进，才不会被时代逐渐淘汰。

**5. 松散索引**

​	松散索引在Mysql5.6之后已经支持，松散索引简单理解就是在进行多列索引扫描的时候，即使次索引不是有序的，但是跳过索引是有序的，也可以走索引来快速匹配数据。

 	松散索引的优化细节放到了下半部分的文章，这里简单讲述一下大致的工作原理。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204051830883.png)

6. **查询同时更新数据**

​	在Postgresql中，支持下面的语法：

```sql
update tbl_info
set name = tmp.name
from 
(select name from tbl_user where name ='xxx')
tmp
[where ....]

-- 比如下面的写法：
UPDATE `sakila`.`actor` SET `first_name` = 'PENELOPE'
from 
(select address,address_id from address where address_id = 1) tmp
 WHERE `actor_id` = 1 and actor.actor_id = tmp.address_id;
```

​	但是很可惜这种语法在Mysql是没有办法实现也是不支持的，哪怕到了8.0.26依然没有支持，这和Mysql的优化器设计有着本质的关系。

7. **优化器提示设置**

优化器提示没有多少意义，这里直接略过了。

8. **最大值和最小值优化**

​	从实际的情况来看Mysql最大值和最小值这两个函数使用并不是很多所以不再进行介绍了，另外无论什么样的数据库都不是很建议频繁使用函数，而是改用业务+简单SQL实现高效索引优化。



其他慢查询优化

​	对于慢查询的优化我们需要清楚优化是分为几种类别的，在Mysql中优化策略分为**动态优化**和**静态优化**：静态优化主要为优化更好的写法，比如常数的排序和一些固定的优化策略等，这些动作通常在一次优化过程中就可以完成。而动态优化策略要复杂很多，可能会在执行的过程中优化，有可能在执行过后重新评估执行计划。

​	静态优化是受优化器影响的，不同版本有不同情况，所以这里讲述动态优化的情况，而动态优化主要包含下面的内容：

- 关联表顺序，有时候关联表顺序和查询顺序不一定相同。
- 重写外连接为内连接：如果一个外连接关联是没有必要的就优化掉外连接关联。
- 等价替换，比如 a>5 and a= 5被优化为a >= 5 ，类似数学的逻辑公式简化
- 优化count()、max()、min()等函数：有时候找最大和最小值只需要找最大和最小的索引记录，这时候由于不需要遍历，可以认为直接为哈希的获取记录的方式，所以在查询分析的 extra 里面进行体现（Select tables optimized away），比如：explain select max(actor_id) from actor;
- 预估和转化常数：以连接查询为例，如果在查询条件中可以实现预估关联的记录条数，那么对于一个关联查询来说就有可能被优化器作为常数进行优化，因为事先取出记录的条数被优化器知晓。所以优化起来十分简单。
- 子查询优化：子查询虽然有可能被索引优化但是需要尽量避免使用。
- 覆盖索引扫描：让索引和查询列一致，是非常高效的优化和执行方式
- 提前终止查询：提前终止查询指的是当遇到一些查询条件会让查询提前完成，优化器会提前判断加快数据的匹配和搜索速度
- 等值传递，如果范围查询可以根据关联表查询优化，那么无需 显式的提示则可以直接搜索数据。

​	

# 参考资料：

这里汇总了文章中出现的一些参考资料：

-  [Mysql官方文档哈希关联](https://dev.mysql.com/doc/refman/8.0/en/hash-joins.html)
- [SQL解析在美团的应用 - 美团技术团队 (meituan.com)](https://tech.meituan.com/2018/05/20/sql-parser-used-in-mtdp.html)
- [使用 pt-query-digest 分析 RDS MySQL 慢查询日志 | 亚马逊AWS官方博客 (amazon.com)](https://aws.amazon.com/cn/blogs/china/pt-query-digest-rds-mysql-slow-searchnew/)



# 写在最后

​	上半部分以理论为主，下半部分将会着重实战内容进行介绍。

