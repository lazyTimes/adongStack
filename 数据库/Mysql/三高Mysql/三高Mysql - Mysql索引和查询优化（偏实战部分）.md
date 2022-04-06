# 三高Mysql - Mysql索引和查询优化（偏实战部分）

# 引言

​	实战部分挑选一些比较常见的情况，事先强调个人使用的是**mysql 8.0.26**，所以不同版本如果出现不同测试结果也不要惊讶，新版本会对于过去一些不会优化的查询进行优化。

​	实战部分承接上一篇文章：[三高 Mysql - Mysql 索引和查询优化（偏理论部分）](https://segmentfault.com/a/1190000041661403)

# 前置准备

​	这里还是要再啰嗦一遍，所有的数据库和表均来自官方的**sakila-db**，作为学习和熟悉mysql数据库操作非常好。

## sakila-db

​	sakila-db是什么？国外很火的一个概念，指的是国外电影租赁市场外国人使用租赁的方式进行电影的观看，过去十分受外国人的喜欢，这里拿出来介绍是因为后续的内容都用到了这个案例，所以我们需要提前把相关的环境准备好，从如下地址进行下载：

​	下载地址：https://dev.mysql.com/doc/index-other.html

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204061302118.png)

## work-bench

​	work-bench是官方开发的数据库关系图的可视化工具，使用官方案例的具体关系图展示效果如下，通过这些图可以看到Sakila-db之间的大致关系：

> work-bench 是免费软件，下载地址如下：
>
> https://dev.mysql.com/downloads/workbench/

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204061302376.png)

​	

​	安装`workbench`和下载`sakila-db`的过程这里不做记录，在运行的时候需要注意先建立一个数据库运行`Sheme`文件，然后执行data的sql文件，最终借助navicat中查看数据和表结构关系：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204061302205.png)

​	

# 正文部分

## where查询太慢怎么办？

​	遇到where查询太慢，我们第一步是需要分析数据类型的组成以及数据表的设置是否合理，其次我们可以使用`explain`对于查询语句进行分析，使用方式十分简单在需要优化的查询语句前面添加`explain`语句，对于所有的查询来说，覆盖索引的查找方式是最优解，因为覆盖索引不需要回表查数据。

​	覆盖索引：覆盖索引是查询方式，他不是一个索引，指的是在查询返回结果的时候和使用的索引是同一个，这时候可以发现他压根不需要回表，直接查辅助索引树就可以得到数据，所以覆盖索引的查询效率比较高。

> 如何使用sql语句查看某一个表的建表语句：
>
> 回答：使用`show create table 表名称`即可。 

​	

​	那么什么情况下会使用覆盖索引：

1. 查询字段为辅助索引的字段或者聚簇索引的字段。
2. 符合**最左匹配原则**，如果不是最左匹配则不能走索引。

​	我们使用上面提到的`sakila-db`进行实验，这里可以使用`inventory`表作为实验，但是这个表需要进行一些调整，下面请看具体的sql：

```SQL
CREATE TABLE `inventory_test` (
  `inventory_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `film_id` smallint unsigned NOT NULL,
  `store_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  -- KEY `idx_fk_film_id` (`film_id`),
  KEY `idx_store_id_film_id` (`store_id`,`film_id`)
  -- CONSTRAINT `fk_inventory_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  -- CONSTRAINT `fk_inventory_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4582 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```


​	我们将原始的sql建表语句只保留一个辅助索引，比如在上面的语句中删除了`idx_fk_film_id`索引，下面删除这个索引之后的实验效果：

```SQL
explain select * from inventory_test where film_id = 1;
-- 案例1. 不符合最左原则不走索引 
-- 1  SIMPLE  inventory_test    ALL          1  100.00  Using where

explain select * from inventory_test where store_id = 1;
-- 案例2: 使用了辅助索引（联合索引）：
-- 1  SIMPLE  inventory_test    ref  idx_store_id_film_id  idx_store_id_film_id  1  const  1  100.00  

explain select inventory_id,film_id,store_id from inventory_test where store_id = 1;
-- 案例3:  正常使用索引 
-- 1 SIMPLE  inventory_test    ref  idx_store_id_film_id  idx_store_id_film_id  1  const  1  100.00  Using index

explain select film_id,store_id from inventory_test where store_id = 1;
-- 案例4:  覆盖索引 
-- 1  SIMPLE  inventory_test    ref  idx_store_id_film_id  idx_store_id_film_id  1  const  1  100.00  Using index

explain select film_id,store_id from inventory_test where film_id = 1;
-- 案例5: 正常使用索引，但是type存在区别 
-- 1  SIMPLE  inventory_test    index  idx_store_id_film_id  idx_store_id_film_id  3    1  100.00  Using where; Using index

explain select inventory_id,film_id,store_id from inventory_test where film_id = 1;
-- 案例6: 使用索引返回结果，但是type存在区别 
-- 1  SIMPLE  inventory_test    index  idx_store_id_film_id  idx_store_id_film_id  3    1  100.00  Using where; Using index

explain select inventory_id,film_id,store_id from inventory_test where store_id = 1;
-- 案例7: 覆盖索引 
-- 1  SIMPLE  inventory_test    ref  idx_store_id_film_id  idx_store_id_film_id  1  const  1  100.00  Using index


```

​	案例1和案例2是较为典型的**索引最左匹配原则**的错误使用反面教材，也是很多新手建立索引但是可能用错的陷阱之一，最左匹配原则指的是where条件需要从建立索引的最左列开始进行搜索，可以看到这里的星号和建表的时候字段的顺序是一样的，也就是`inventory_id`，`film_id,store_id`，`last_update`，所以是虽然是`select *`但是是正常走索引的。

（实际干活时候千万不要这么做，这里是为了演示偷懒而已）

> 不用星号我使用**乱序**的列查询会怎么样，其实这时候如果你把查询列的数据换一下会.....没啥影响，**随意调换查询列顺序依然可以走索引**。

​	接下来是案例3 - 案例7的几个查询，这几个查询意图解释的是针对覆盖索引使用的细节问题，在上面的测试案例语句当中可以看到案例4由于查询的结果和where条件都是使用了索引的，所以最终mysql使用了完整的覆盖索引，同时符合联合索引的最左匹配原则，所以查询的效率达到了`ref`级别（这个级别暂时简单理解就是非常快就行）。

​	接着案例5又把where条件换了一下，可以看到虽然还是走了索引，但是效率一下子就低了下来，因为他不符合最左匹配原则，另外这个案例5的查询级别可以理解为它需要把整个辅助索引也就是联合索引的树扫完再去进行where筛选，效率自然就不如直接检索排序索引值快了，但是index这个级别还是比ALL这个龟速快不少。

​	理解了上面的这一层意思，再来理解案例6和7就很简单了，可以看到只多了一个主键列查询。

​	这里读者可能会觉得你这上面不是说返回结果全是索引列才会覆盖么，怎么加入了主键列还是奏效呢？主键不是在聚簇索引上嘛不是需要回表么？其实这两个问题很好回答，因为辅助索引当中key存储的确实是索引列的值，但是他的索引值放的是主键ID，当mysql在搜索索引列的时候发现这里多了一个列，但是又发现这个列是主键，所以最后发现可以直接通过联合索引直接返回结果不需要回表，所以这样覆盖索引的条件同样是成立的。

​	如果读者不清楚查询`explain`结果列代表的含义，可以参考下面的内容对比：

- id: 首先，一个select就会出现一个id, 通常在复杂的查询里面会包含多张表的查询，比如join, in等等
- select_type：这个表示的是查询的类型
- table：表名称
- partitions：这个表示表空间，分区的概念
- **type** : 比如查询的优化等级,  const, index, all，分别代表了聚簇索引，二级索引(辅助索引)，全表扫描的查询搜索方式
- Possiblekeys：和type一样确定访问方式，确定有哪些索引可以选择，
- key：确定有哪些可以提供选择，同时提供索引的对应长度
- key_len： 表示的是索引的长度
- ref： 等值匹配的时候出现的一些匹配的相关信息
- Rows： 预估通过所索引或者别的方式读取多少条数据
- filtered：经过搜索条件过滤之后的剩余数据百分比。
- extra：额外的信息不重要，主要用于用户判定查询走了什么索引。




总结

通过上面的案例我们可以从下面的角度思考来如何提升索引查询速度：

- 使用**覆盖索引**查询方式提高效率，再次强调覆盖索引不是索引是优化索引查询一种方式。
- 如果数据不只使用索引列那么就构不成覆盖索引。
- 可以优化sql语句或者优化联合索引的方式提高覆盖索引的命中率。



## 如何确认选择用什么索引？

​	这里涉及一个索引基数（cardinality）的问题，索引基数是什么，其实就是利用算法和概率学统计的方式确定最优化的索引方案，这个值可以通过`show index from 表名`的方式进行获取，比如下面的200和121就是**索引基数（cardinality）**。

> 因为索引基数的存在如果索引不符合我们到使用预期可以尝试强制使用某索引。


```Java
> show index from actor;
actor  0  PRIMARY  1  actor_id  A  200        BTREE      YES  
actor  1  idx_actor_last_name  1  last_name  A  121        BTREE      YES  
```

​	索引基数的定义官方文档的介绍：

​	下面一坨东西简单来说就是mysql会根据基数的数值根据一定的算法选择使用索引，但是有时候如果查询不能符合预期要求就需要强制使用索引了。

> 表列中不同值的数量。当查询引用具有关联索引的列时，每列的基数会影响最有效的访问方法。<br />例如，对于具有唯一约束的列，不同值的数量等于表中的行数。如果一个表有一百万行，但特定列只有 10 个不同的值，<br />则每个值（平均）出现 100,000 次。 SELECT c1 FROM t1 WHERE c1 = 50 等查询因此可能会返回 1 行或大量行，<br />并且数据库服务器可能会根据 c1 的基数以不同方式处理查询。<br /><br />如果列中的值分布非常不均匀，则基数可能不是确定最佳查询计划的好方法。例如，SELECT c1 FROM t1 WHERE c1 = x;<br />当 x=50 时可能返回 1 行，当 x=30 时可能返回一百万行。在这种情况下，您可能需要使用索引提示来传递有关哪种<br />查找方法对特定查询更有效的建议。<br /><br />基数也可以应用于多个列中存在的不同值的数量，例如在复合索引中。<br />参考：**列、复合索引、索引、索引提示、持久统计、随机潜水、选择性、唯一约束**。

```tex
原文：
The number of different values in a table column. When queries refer to columns that have an 
associated index, the cardinality of each column influences which access method is most 
efficient. For example, for a column with a unique constraint, the number of different 
values is equal to the number of rows in the table. If a table has a million rows but 
only 10 different values for a particular column, each value occurs (on average) 100,000 times.
 A query such as SELECT c1 FROM t1 WHERE c1 = 50; thus might return 1 row or a huge number of 
 rows, and the database server might process the query differently depending on the cardinality 
 of c1.

If the values in a column have a very uneven distribution, the cardinality might not be 
a good way to determine the best query plan. For example, SELECT c1 FROM t1 WHERE c1 = x;
 might return 1 row when x=50 and a million rows when x=30. In such a case, you might need 
 to use index hints to pass along advice about which lookup method is more efficient for a 
 particular query.

Cardinality can also apply to the number of distinct values present in multiple columns, 
as in a composite index.

See Also column, composite index, index, index hint, persistent statistics, random dive,
 selectivity, unique constraint.

```


​	

​	如何让sql强制使用索引

​	可以使用from表之后接条件语句：`force index(索引)` 的方式进行处理，使用强制索引的情况比较少，除非优化器真的选择了不符合预期的优化规则并且严重影响查询性能，使用强制索引的案例如下：

```SQL
select * from actor force index(idx_actor_last_name);
```




## count()慢的原因是什么？

count函数不用多介绍，作用是查询结果的行数，但是需要注意优化器在处理过程中会**比对并且排除掉结果为null的值**的数据，这意味着在行数很大的时候如果使用不正确count会因为比对数据操作进而降低查询效率。

所以这里我们只要记住一个特定的规则，那就是只要是涉及行数的查询，那就使用`select(*)`，原因仅仅是mysql官方针对这个做了专门的优化，也不需要去纠结为什么官方要给`select(*)`做优化，只能说**约定大于配置**，下面是常见的查询性能之间的对比：

- count(非索引字段)：理论上是最慢的，因为对于每一行结果都要判断是否为null。
- count(索引字段)：虽然走了索引，但是依然需要对每一行结果判断是否为null。
- count(1)：虽然不涉及字段了，但是这种方式依然需要对1进行判断是否为null。
- **count(*)：Mysql官方进行优化，查询效率最快，只需要记住这种方式即可**。



## 索引下推

索引下推实现版本为Mysql5.6以上。

作用：本质上是为了减少辅助索引（或者说二级索引）**回表次数**的一种优化手段。

案例：请看下面的建表语句，这里比较关键的是建立了`store_id`和`film_id`的联合索引 。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/202203211327993.png)

​	以下面的SQL语句为例，如果是5.6之前的版本虽然他是覆盖索引的查询方式但却是**不能使用索引**的，数据进过索引查找之后虽然store_id是顺序排序的但是film_id是乱序的，在索引检索的时候由于没有办法顺序扫描（如果不清楚索引组织结构可以多看几遍B+树索引构造） 它需要一行行使用主键回表进行查询，查询实际需要使用每一行的`inentory_id`回表4次去匹配film_id是否为3。

```sql
select * from inventory_3 where store_id in (1,2) and film_id = 3;
```

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204061303013.png)

​	按照人的思维看起来是很不合理的，因为我们可以发现按照正常的逻辑有一种搜索的方法是通过“跳跃“索引的方式进行扫描，当扫描到索引列如果不符合条件，则直接跳跃索引到下一个索引列，有点类似我们小时候”跳房子“方式来寻找自己需要的沙袋（索引数据）。

​	**那么索引下推是如何处理上面这种情况的呢**？虽然film_id是没有办法顺序扫描的也不符合索引的排列规则，但是发现可以根据遍历film_id汇总索引之后再回表查呀！比如根据查询条件搜索遍历找到film=3之后再根据二级索引列对应的主键去查主索引，这时候只需要一次回表就可以查到数据，此时原本应该根据每个二级索引的主键值进行回表变为遍历索引并找到索引值之后再回表，最终达到减少回表次数的效果，这也是前面为什么说索引下推是为了减少了回表的次数的答案。

​	索引下推的开启和关闭可以参考如下命令：

```SQL
-- 索引下推变量值：
mysql> select @@optimizer_switch\G;
*************************** 1. row ***************************
@@optimizer_switch: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on
1 row in set (0.00 sec)

-- 关闭索引下推
set optimizer_switch='index_condition_pushdown=off';
-- 开启索引下推
set optimizer_switch='index_condition_pushdown=on';


```

## **松散索引和紧凑索引**

​	关于松散索引和紧凑索引可以看下面两个文档对比参考阅读：

​	[MySql 中文文档 - 8.2.1.15 GROUP BY 最佳化 | Docs4dev](https://www.docs4dev.com/docs/zh/mysql/5.7/reference/group-by-optimization.html)

​	[MySQL :: MySQL 8.0 Reference Manual :: 8.2.1.17 GROUP BY Optimization](https://dev.mysql.com/doc/refman/8.0/en/group-by-optimization.html)

​	松散索引和紧凑索引的概念不是特别好理解，松散索引和紧凑索引实际上就是当MySQL 利用索引扫描来实现`GROUP BY`的时候，**并不需要扫描所有满足条件的索引键即可完成操作得出结果**，仅仅处理的情况细节不同。

​	过去Mysql对于`group by`操作是构建临时表并且在临时表上操作，在使用索引的情况下，分组查询是可以走索引的：

```sql
explain select last_name from actor  GROUP BY last_name
-- 1	SIMPLE	actor		index	idx_actor_last_name	idx_actor_last_name	182		200	100.00	Using index
```

​	由于`group by` 操作和`order by`操作不走索引的时候可能会产生临时表，同时`group by` 操作拥有和`order by` 类似的排序操作，有时候我们分组查询不止一个字段，所以可能会出现多列索引情况，所以此时mysql对于多列联合索引分组查询进一步优化，提供了松散索引和紧凑索引多概念，

​	松散索引在官方有下面的定义：

1. 当彻底使用索引扫描实现`group by`操作的时候，只需要使用部分的索引列就可以完成操作
2. 虽然Btree的二级索引内部是排序并且要求索引是顺序访问的，但是对于group by最大的优化是扫描这种顺序索引的时候**where条件没必要完全贴合所有索引key**，

​	上面定义有两个个关键词：**彻底**和**不完全**，where条件没必要完全贴合索引键。为了更好理解我们这里使用了官方给的例子，假设在 table`t1(c1,c2,c3,c4)`上有一个索引`idx(c1,c2,c3)`。松散索引扫描访问方法可用于以下查询：

```SQL
-- 可以不使用所有索引字段，可以走联合索引
SELECT c1, c2 FROM t1 GROUP BY c1, c2;
-- 去重操作内部也会进行隐式的分组行为
SELECT DISTINCT c1, c2 FROM t1;
-- 分组的极值查询可以使用松散索引，因为c2和c1依然有序
SELECT c1, MIN(c2) FROM t1 GROUP BY c1;
-- 分组前的where 条件
SELECT c1, c2 FROM t1 WHERE c1 < const GROUP BY c1, c2;
-- 对于c3的极值操作依然和c1,c2构成索引
SELECT MAX(c3), MIN(c3), c1, c2 FROM t1 WHERE c2 > const GROUP BY c1, c2;
-- 支持范围查询的同时走松散索引
SELECT c2 FROM t1 WHERE c1 < const GROUP BY c1, c2;
-- 最后一列等值查询依然可以视为松散索引
SELECT c1, c2 FROM t1 WHERE c3 = const GROUP BY c1, c2;	
-- 松散索引可以作用于下面的查询
SELECT COUNT(DISTINCT c1), SUM(DISTINCT c1) FROM t1;

SELECT COUNT(DISTINCT c1, c2), COUNT(DISTINCT c2, c1) FROM t1;
```

​	松散索引需要满足下面的条件：

- 分组查询是单表查询
- `group by`的条件必须同一个索引顺序索引的连续位置。
- `group by`的同时只能使用max或者min两个聚合函数（但是在5.5之后，新增了更多函数支持）。
- 如果应用`group by`以外字段条件必须用**常量形式**存在。
- 必须使用完整的索引值，也就意味着like这样的前缀索引是不适用的。

​	如果想要判定查询是否使用松散索引可以根据`explain`的`extra`内容是否为`Using index for group-by`确认。

​	下面我们用更实际SQL来介绍，假设在 table`t1(c1,c2,c3,c4)`上有一个索引`idx(c1,c2,c3)`。松散索引扫描访问方法可用于以下查询：

```SQL

-- 自我实验：松散索引
EXPLAIN SELECT COUNT(DISTINCT film_id, store_id), COUNT(DISTINCT store_id, film_id) FROM inventory_test;
-- 1  SIMPLE  inventory_test    range  idx_store_id_film_id  idx_store_id_film_id  3    4  100.00  Using index for group-by (scanning)
-- 自我实验：松散索引
EXPLAIN SELECT COUNT(DISTINCT store_id), SUM(DISTINCT store_id) FROM inventory_test;
-- 1  SIMPLE  inventory_test    range  idx_store_id_film_id  idx_store_id_film_id  1    4  100.00  Using index for group-by (scanning)

-- 但是如果查询的不是同一个索引，不满足最左原则是不走松散索引的，而是走更快的索引扫描：
EXPLAIN SELECT COUNT(DISTINCT store_id), SUM(DISTINCT store_id) FROM inventory_test;
EXPLAIN SELECT COUNT(DISTINCT film_id), SUM(DISTINCT film_id) FROM inventory_test;
-- 1	SIMPLE	inventory_test		range	idx_store_id_film_id	idx_store_id_film_id	1		4	100.00	Using index for group-by (scanning)
-- 1	SIMPLE	inventory_test		index	idx_store_id_film_id	idx_store_id_film_id	3		3	100.00	Using index
```

**紧凑索引**

​	和松散索引区别的是紧凑索引使用前提是必须是**全索引扫描**或者**范围索引扫描**，当松散索引没有生效时使得`group by` 依然有可能避免创建临时表，紧凑索引需要读取所有满足条件的索引键才会工作，然后根据读取的数据完成`group by` 操作。

​	为了使紧凑索引查询这种方法奏效在查询中的所有列都要有**恒定的相等条件**，比如必须`GROUP BY`键之前或之间的部分键。

​	在紧凑索引扫描方式下，先对索引执行**范围扫描（range scan）**，再对结果元组进行分组。为了更好的理解，可以看一下相关的案例：

​	在`GROUP BY`中存在一个缺口，但是它被条件`c2='a'`所覆盖。

```SQL
SELECT c1, c2, c3 FROM t1 WHERE c2 = 'a' GROUP BY c1, c3;
```


​	`GROUP BY`没有以键的第一部分开始，但是有一个条件为这部分提供了一个常数。

```SQL
SELECT c1, c2, c3 FROM t1 WHERE c1 = 'a' GROUP BY c2, c3;
```


​	我们按照官方给的案例实验一下，首先是表结构，我们在下面表中建立联合索引：

```SQL
CREATE TABLE `inventory_test` (
  `inventory_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `film_id` smallint unsigned NOT NULL,
  `store_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  KEY `idx_store_id_film_id` (`store_id`,`film_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4582 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

​	下面是个人使用紧凑索引的案例，当where条件是常量值并且是针对索引的常量值的时候，`group by`就可以走索引，但是如果where条件是非索引字段依然需要全表扫描，注意这里group的字段并不是按照联合索引的最左前缀处理的依然可以走索引，这就是mysql对于分组操作的一系列优化了。

```SQL
-- 紧凑索引
EXPLAIN select count(*),max(film_id),sum(film_id), avg(film_id) from inventory_test where store_id = 1 GROUP BY film_id;
-- 1  SIMPLE  inventory_test    ref  idx_store_id_film_id  idx_store_id_film_id  1  const  1  100.00  Using index

EXPLAIN select count(*),max(film_id),sum(film_id), avg(film_id) from inventory_test where last_update > '2022-02-02 23:20:45' GROUP BY film_id;
-- 1  SIMPLE  inventory_test    ALL  idx_store_id_film_id        3  33.33  Using where; Using temporary

EXPLAIN select count(*),max(film_id),sum(film_id), avg(film_id) from inventory_test where last_update = '2022-02-02 23:20:45' GROUP BY film_id;
-- 1  SIMPLE  inventory_test    ALL  idx_store_id_film_id        3  33.33  Using where; Using temporary

```

​	建议读者多读一读官方文档加深这两个概念理解。



## order by如何优化？

什么是中间结果集？

​	对于常规的sort语句，由于需要对于搜索的结果按照某一字段进行大小排序，而为了让这个操作顺利完成，mysql会把这个操作放到硬盘或者内存完成。



排序的基本步骤和原理 

​	对于涉及排序的语句，它的大致工作原理如下：

1. 选取查询字段，根据`where`进行条件查询。
2. 查询结果集生成`sort_buffer`，如果内存不够，需要在硬盘建立中间表进行排序。
3. 将中间表根据`Order` 字段进行排序。
4. 回表生成完整结果集，组装返回结果。

 

中间结果集特点

​	如果中间表比较小则放到内存中，判定什么时候会存在于内存中Mysql提供了`sort_buffer_size`的参数，它负责控制中间结果集的大小，如果优化内存需要调整降低这个参数值，但是如果想要优化查询的时间，则需要调大这个参数。



回表生成完整结果集

​	回表生成完整结果集这个操作其实也不是总是执行的，会根据会话参数`max_length_for_sort_data`进行判断，如果当前查询小于这个数值，会生成一个**全字段中间表**结果可以直接从全字段中间表获取，但是如果大于这个数值那么就只会生成**排序字段+主键中间表**（类似二级索引），所以这时候显然查找一遍是无法找到的，需要回表才能完成操作。

> 需要注意**排序字段+主键中间表**看起来像是二级索引但是实际上和二级索引完全没有关系，只是一个简单列表需要反复去主表获取数据。

​	总结：全字段中间表>`max_length_for_sort_data`>排序字段+主键中间表，数值并不是越大越好越大越影响查询效率。



排序查询优化点

​	根本问题在于排序的结果是中间结果集，虽然结果集可以在内存中处理，但是他有最为本质的问题那就是**中间表不存在索引**并且导致索引失效，所以为了让中间表可以走索引我们可以使用**索引覆盖**的方式。

> 优化手段：索引覆盖，也是最高效的处理方式。索引覆盖可以跳过生成生成中间结果集，直接输出查询结果。

1. order by的字段为索引（或者联合索引的最左边）。
2. 其他字段（条件、输出）均在上述索引中。
3. 索引覆盖可以跳过中间结果集，直接输出查询结果。 

> 什么是索引覆盖？
>
> 覆盖索引：覆盖索引是**查询方式**而不是一个索引，指的是一个sql语句中包括查询条件和返回结果均符合索引使用条件，当然在Mysql5.6之后增加索引下推，满足下推条件的也可以走覆盖索引。

​	比如下面的语句并不会生成中间结果集并且可以有效利用索引：


```SQL
explain select film_id, title from film order by title;
-- 1	SIMPLE	film		index		idx_title	514		1000	100.00	Using index
```



总结：提升排序查询速度

1. 给`order by`字段增加索引，或者`where`字段使用索引，让查询可以走覆盖索引的方式。
2. 调整`sort_buffer_size`大小，或者调整`max_length_for_sort_data`的大小，让排序尽量在内存完成。



## 函数操作索引失效的问题

通过下面的案例可以得知，如果我们对于索引的字段进行了类似函数的操作那么mysql会放弃使用索引，另外一种情况是日期函数比如month()函数也会使得索引失效。

> 小贴士：很多人以为函数操作是那些sum()，count()函数，实际上对于字段的**加减乘除**操作都可以认为是函数操作，因为底层需要调用计算机的寄存器完成相关指令操作。另外这里需要和签名的索引下推和松散紧凑索引做区分，松散和紧凑索引针对分组操作索引优化，索引下推到了5.6才被正式引入。大多数旧版本的mysql系统是没法享受使用函数操作同时还能走索引的。


```SQL
-- sql1：对于索引字段进行函数操作
EXPLAIN SELECT
  title 
FROM
  film   
WHERE
  title + '22' = 'ACADEMY DINOSAUR' 
  AND length + 11 = 86;
  -- 1  SIMPLE  film    ALL          1000  100.00  Using where
  
-- sql2：如果对于其他字段使用函数操作，但是索引字段不进行 函数操作依然可以走索引
EXPLAIN SELECT
  title 
FROM
  film 
WHERE
  title  = 'ACADEMY DINOSAUR' 
  AND length + 11 = 86;
  -- 1  SIMPLE  film    ref  idx_title  idx_title  514  const  1  100.00  Using where

```



时间函数如何优化：

​	我们要如何优化时间函数呢？有一种比较笨的方式是使用 **between and 替代，**比如要搜索5月份，就使用5月的第一天到5月的最后一天，具体的优化案例如下：

```SQL
explain select last_update from payment where month(last_update) =2;
-- last_update需要手动创建索引
-- 1  SIMPLE  payment    ALL          16086  100.00  Using where
```


​	如果需要优化上面的结果，我们可以使用其他的方式替换写法：

```Java
explain select * from payment where last_update between '2006-02-01' and '2006-02-28';
-- 1  SIMPLE  payment    ALL  idx_payment_lastupdate        16086  50.00  Using where

```


​	这里很奇怪，咋和上面说的不一样呢？其实是因为`last_update`这个字段使用的数据类型是**t**imestamp，而timestamp在进行搜索的时候由于优化器的判断会放弃使用索引！所以解决办法也比较简单：**使用force inde**x 让SQL 强制使用索引。

```SQL
explain select  * from payment force index(idx_payment_lastupdate) where last_update between '2006-02-01' and '2006-02-28' ;
-- 1  SIMPLE  payment    range  idx_payment_lastupdate  idx_payment_lastupdate  5    8043  100.00  Using index condition
```


> 这里经过实验发现如果字段是datetime，就可以直接用Between and索引，对于时间戳类型并没有实验，仅从现有的表设计来看结果如下：


```SQL
-- 优化后
-- 1  SIMPLE  rental    range  rental_date  rental_date  5    182  100.00  Using index condition
explain select * from rental where rental_date between '2006-02-01' and '2006-02-28';

-- 1  SIMPLE  rental    ALL          16008  100.00  Using where
explain select * from rental where  month(rental_date) =2;
```



字符和数字比较：

​	字符和数字比较也是会出现函数转化的同样会导致索引失效，所以在等式匹配的时候需要确保被比较的类型左右两边一致，另外如果无法修改查询可以使用cast函数进行补救，比如像下面这样处理。

```SQL
select * from city where cast(city_id as SIGNED int) = 1;
```



隐式字符编码转化：

​	如果两个表字段的编码不一样，也会出现索引失效的问题，因为底层需要对于编码进行转化，解决方式也比较简单，在比较的时候， 同时**尽量**比较字符串保证编码一致。那么假设两张表比较的时候，那个表的字段需要转化呢，比如A表的utf8和B表utf8mb4，A表中字段需要和B表字段进行比较的时候，需要将**A表的字段转为和 B表的字段一致**。

> 这个就偷懒不实验了，绝大多数情况下表的字符集编码格式只要跟随表级别基本不会出现不一致的问题......




## order by rand()原理

```SQL
select tilte, desciption from film order by rand() limit 1;
-- EXPLAIN select title, description from film order by rand() limit 1;
-- 1  SIMPLE  film    ALL          1000  100.00  Using temporary; Using filesort
```


​	`rand()`函数是十分耗费数据库性能的函数，在日常使用过程中我们可能遇到需要临时获取一条数据的情况，这时候就有可能会使用`rand()`函数，下面是`rand()`函数的执行原理：

- 创建一个临时表，临时表字段为`rand、title、description`。
- 从临时表中获取一行，调用rand()，把结果和数据放入临时表，以此类推。
- 针对临时表，把rand字段+行位置（主键）放入到`sort_buffer`。

​	可以看到这里最大的问题是出现了**两次中间结果集**。

​	针对此问题可以使用下面的临时方案进行处理，这个临时方案可以看作是把rand()内部的工作拆开来进行处理，也是在不改动业务的情况下一种比较“笨”的解决方式：

```SQL
select max(film_id),min(film_id) into @M,@N from film;
set @x=FLOOR((@M-@N+1) * rand() + @N);
EXPLAIN select title,description from film where film_id >= @X limit 1;
```


​	其他处理方式是使用业务和逻辑代码替代sql的内部处理，比如使用下面的方式进行处理：

1. 查询数据表总数 total。
2. total范围内，随机选取一个数字r。
3. 执行下列的SQL：

```SQL
select title,description from film limit r,1;
```


​	小结：

1. `order by rand() limit` 这个查询的效率极其低下，因为他需要生成两次中间表才能获取结果，谨慎使用此函数。

2. 解决方案有两种：
   
   - 临时解决方案：在主键的最大值和最小值中选取一个。
   
   - 好理解的方式处理：业务代码加limit处理
   
   优点：在不改变业务的情况下直接通过调整SQL                                                                                                                       
   
   缺点：模板代码比较难以记忆，并且并不是万能的，因为可能不给你相关权限
   
3. 建议使用业务逻辑代码处理不使用rand()函数。



## 分页查询慢怎么办？

​	再次注意这里实验的时候使用的数据库版本为**8.0.26**。

​	我们首先来看一下《高性能Mysql 第三版》 241-242页怎么说的，作者使用的也是sakila表，推荐的方式是使用**延迟关联**的方法，比如把下面的sql进行优化：

```SQL
-- 优化前
select film_id,description from film order by title limit 50,5;

-- 优化后
select film_id,description from film inner join (select film_id from film order by title limit 50, 5) as lim using(film_id)
```


​	第二种方式是当id符合某种排序规则并且业务刚好符合的时候可以使用`between ...and`替代

```SQL
select * from film where film_id between 46 and 50 order position;
```


​	最后还有一种方式是利用排序的特性将数据排序之后获取前面的行即可：

```SQL
select * from film where film_id order position desc limit 5;
```


​	以上是关于《高性能Mysql 第三版》 部分的介绍。下面来看下我们是否还有其他的办法？

​	深分页问题不管是面试还是日常开发中经常会遇到的问题，这和limit的语法特性有关，可以看下面的内容：

```SQL
select * from film limit x,y;
```


​	limit的语句的执行顺序如下：

1. 先按照列查找出所有的语句，如果有where语句则根据where查找出数据
2. 查找数据并且加入结果集直到查找到（x+y）条数据为止。
3. 丢弃掉前面的x条，保留y条。
4. 返回剩下的y条数据。



​	针对limit我们有下面的优化和处理方案：

​	1. **简单优化**：

​	如果主键是int自增并且主键是逻辑符合业务自增的，那么我们可以使用下面的语句进行优化：

```SQL
select * from film where id >= 10000 limit y;
```

​	

​	2. **子查询优化**：

​	自查询的优化方式是减少回表次数的一种方式，我们可以使用自查询的方式，由于不同业务之间存在不同的处理方式，这里给一个大致的处理模板：

```SQL
select * from film where ID in (select id from film where title = 'BANG KWAI') limit 10000,10
```


​	这样处理过后有两个优点：

- 查询转为搜索索引列，并且不需要磁盘IO。
- 虽然使用的是子查询，但是因为搜索的是索引列，所以效率还是比较高的。



​	3. **延迟关联**

​	和《高性能Mysql》的方式一样，其实就是子查询方式的一种优化版本，优化的思路也是把过滤数据变为走索引之后在进行排除，由于上文已经介绍过这里就不再赘述了。



总结：

​	对于深分页的问题我们一般有下面的优化思路：

- 如果主键符合自增或者符合业务排序，可以直接通过`id>xxx` 然后limit搜索数据。
- 如果通过排序可以正确搜索相关数据，则可以直接排序之后取条数即可。
- 延迟关联，延迟关联有两种方式，第一种是使用in的子查询，第二种是使用inner join，本质都是通过索引列的方式避免大数据的查找，同时转变为查索引的方式。
- 如果可以确认范围，使用between and 替代。



# 总结

​	本节内容针对了一些实战过程中可能经常遇到的一些问题处理进行阐述，其中稍微有些难度的部分在索引下推和紧凑索引部分，这些特性



# 参考资料

​	[MySql 中文文档 - 8.2.1.15 GROUP BY 最佳化 | Docs4dev](https://www.docs4dev.com/docs/zh/mysql/5.7/reference/group-by-optimization.html)

​	[MySQL :: MySQL 8.0 Reference Manual :: 8.2.1.17 GROUP BY Optimization](https://dev.mysql.com/doc/refman/8.0/en/group-by-optimization.html)