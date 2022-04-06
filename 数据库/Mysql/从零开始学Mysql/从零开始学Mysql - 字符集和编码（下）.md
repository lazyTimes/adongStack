# 从零开始学Mysql - 字符集和编码（下）



# 引言

​	这个系列的文章是根据《MySQL是怎样运行的：从根儿上理解MySQL》这本书的个人笔记总结专栏，这里十分推荐大家精读一下这本书，也是目前市面上个人所知的讲述Mysql原理的为数不多的好书之一，好了废话不多说我们下面进入正题。

> 上篇：[从零开始学Mysql - 字符集和编码（上）](https://juejin.cn/post/7038059481070043172)

​	由于这个系列涉及的，这里先根据文章的知识点汇总了一份个人思维导图，有需要导图源文件的也可以评论或者私信我进行获取：

​	[幕布地址](https://www.mubucm.com/doc/7DDOY0CuMK5)

# 回顾上篇

​	因为上一篇和本篇编写的间隔时间比较久，这里我们先来回顾一下上一篇讲了什么内容：

1. 在Mysql数据中，字符串的大小比较本质上是通过下面两种方式进行比较，简而言之字符串的大小比较是依赖**字符集和比较规则**来进行比较的。
   1. 将字符统一转为大写或者小写再进行二进制的比较
   2. 或者大小写进行**不同大小的编码规则编码**

2. 简述和掌握几个比较常用的字符集：
   1. ASCII 字符集：收录128个字符，
   2. ISO 8859-1 字符集：在ASCII 字符集基础上进行扩展，共256个字符，字符集叫做latin1，也是Mysql5.7之前默认的字符集（Mysql8.0之后默认字符集为utf8mb4）
   3. GB2312：首先需要注意的是不仅仅只有“汉字”哦，比较特殊的是采用了**变长编码规则**，变长编码规则值得是根据字符串的内容进行不同的字符集进行编码，比如'啊A'中‘啊’使用两个字节编码，'A'因为可以使用ASCII 字符集表示所以可以只使用一个字节进行编码
   4. GBK 字符集：对于GB2312进行字符集的扩展，其他和GB2312编码规则一致
   5. UTF8字符集：UTF-8规定按照1-4个字节的**变长编码方式**进行编码，最后UTF8和gbk一样也兼容了ASCII的字符集

> 提示：这里有一个思考题目那就UTF-8mb3和UTF8-mb4的字符集有什么区别？这里也隐藏了一个历史遗留问题带来的坑，如果主要使用Mysql数据库这个坑有必要仔细了解一下，在上篇的文章最后给出答案，这里不再赘述。

3. 查看字符集命令：`show charset;`，比如：`show charset like 'big%';`
4. 比较规则查看：`show collation [like 匹配模式]`，比如`show collation like 'utf_%';`
5. 字符集和比较规则的级别分为四种：
   1. 服务器级别：可以通过配置文件进行设置，但是启动之后无法修改服务器级别的字符集或者比较规则。
   2. 数据库级别：如果没有指定数据库级别比较规则或者字符集，则默认使用服务器的。
   3. 表级别：表级别在默认的情况下使用数据库级别的字符集和比较规则。
   4. 列级别：列级别规则使用比较少，通常在建表的时候指定，但是通常不建议同一个表使用不同字符集的列。

6. 最后，我们回顾一下字符集和比较规则的常见命令。

| 数据库级别 | 查看字符集                                            | 查看比较规则                                                 | 系统变量                                                     | 修改/创建方式                                                | 案例                                                         |
| ---------- | ----------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 服务器级别 | show variables like 'character_set_server';           | SHOW VARIABLES LIKE 'collation_server'                       | character_set_server<br />：当前服务器比较规则collation_server：当前服务器比较规则 | 修改配置文件<br />[server]<br/> character_set_server=gbk<br/>collation_server=gbk_chinese_ci | CREATE DATABASE charset_demo_db<br/>         CHARACTER SET gb2312<br/>        COLLATE gb2312_chinese_ci; |
| 数据库级别 | show variables like 'character_set_database';         | show variables LIKE 'collation_database';                    | character_set_database：**当前数据库**字符集 Collation_database：**当前数据库**比较规则 | alter database 数据库名<br/>	[[DEFAULT] CHARACTER SET 字符集名称]<br/>	[[DEFAULT] COLLATE 比较规则名称]; | CREATE DATABASE charset_demo_db<br/>         CHARACTER SET gb2312<br/>        COLLATE gb2312_chinese_ci; |
| 表级别     | show table status from '数据库名称' like '数据表名称' | SELECT TABLE_SCHEMA, TABLE_NAME,TABLE_COLLATION FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = '数据表名称' | 未设置情况下默认参考数据库的级别设置                         | CREATE TABLE 表名 (列的信息)<br/>[[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称]]<br/><br/>ALTER TABLE 表名<br/>[[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称] | create table test(<br/>	id int auto_increment primary key<br/>) character set utf8mb4 <br/>COLLATE utf8mb4_0900_ai_ci |
| 列级别     | show full columns from admin like 'username';         | show full columns from admin like 'username';                | 未设置情况下默认参考数据表的级别设置                         | CREATE TABLE 表名(<br/>	列名 字符串类型 [CHARACTER SET 字符集名称] [COLLATE 比较规则名称], 其他列...<br/>);<br />ALTER TABLE t MODIFY col VARCHAR(10) CHARACTER SET gbk COLLATE gbk_chinese_ci; |                                                              |

# 文章目的

​	在介绍正文之前，这里先提前总结本文的主要内容。

1. 为什么在进行mysql查询的时候会出现乱码，通过一个简单查询了解来龙去脉。
2. 一个Sql请求的字符集转换规则细节讲述（重点）
3. 不同比较规则下字符串的比较差别讨论。



# 版本说明

​	为了防止读者误解，这里提供一下基本的环境：

+ mysql版本号：



# 查询中的乱码是怎么来的？

​	在乱码的世界中有一个十分经典的词：“锟斤拷”，下面是关于这词的百科介绍：

> 是一串经常在搜索引擎页面和其他网站上看到的[乱码](https://baike.baidu.com/item/乱码)字符。乱码源于[GBK](https://baike.baidu.com/item/GBK)字符集和[Unicode](https://baike.baidu.com/item/Unicode)字符集之间的转换问题。除了锟斤拷以外，还有两组比较经典的乱码，分别是"烫烫烫"和"屯屯屯"，这两个乱码产生自VC，这是debug模式下VC对内存的初始化操作。

​	乱码的本质其实就是字符串的编码方式和解码方式的不同一，比如使用UTF8的编码情况下“我”这字符会被翻译为“æˆ‘”，由于UTF8的“我”使用的是三个字节的编码，当我这个字符被转为另一个编码的时候就会因为不同字符集被解析为不同的字符，读取和加密的编码不是同一个最终就出现问题了。

# 一个请求的编码历程

​	我们都知道mysql的请求无非就是发送一条sql语句，服务器收到命令之后讲数据进行筛选整理最终进行编码返回结果，这个传输过程本质上是字符串与字符串的交流和传输，而字符串的本质其实也只是一段字节的特殊编码规则翻译过后便于理解而已，另外只要稍微了解一下mysql的数据行存储规则就会知道一个数据行实际存储的是一段字节编码，以innodb为例你可以简单的认为我们存储的所有数据类型其实本质上都是字符串，对于文本内容则会根据系统的字符集对于内容进行不同的处理，那么这里就涉及到一个问题了，我们的字符是在请求的时候编码的？还是在送到mysql应用程序之后内部有一套转化的规则？下面我们一起来看一下一个请求的实际传输过程

​	在具体的讲述之前，我们先来了解一下为什么书中不建议使用navicat这样的工具进行验证请求编码的规则处理：

​	首先我们通过工具navicat创建一个在数据库，并且创建的时候指定字符集和比较规则。

> 提示：需要注意的是此时utf8是utf8mb3的

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20220125111237.png)

​	接着我们构建一个简单的表，这表里面只有id和name两列数据。

```sql
CREATE TABLE `test` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(255) DEFAULT NULL COMMENT '名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='测试字符集和编码';
```

​	接着我们插入一条数据：

```mysql
INSERT INTO `test`.`test` (`id`, `name`) VALUES (1, '我');
```

​	最后我们执行一条sql语句进行测试，这当然不会出现任何问题，但是这里我们可以玩一点花样，比如把字符集和编码改成下面的形式，这时候你会发现你还是可以照常插入中文也可以插入任何数据，这是为什么？其实看一下他对应的DLL建表语句就可以看出端倪。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20220125112155.png)



```mysql
-- DDL建表语句
CREATE TABLE `test` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(255) CHARACTER SET gbk COLLATE gbk_chinese_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='测试字符集和编码';
```

​	可以看到如果你胡乱修改表的字符集，列的字符集会根据存储的内容选择兼容的方案，比如这里使用了gbk的编码格式进行处理。但是如果你通过下面的语句修改列的字符集，就会发现这条语句无法执行通过。

```sql
ALTER TABLE test MODIFY name VARCHAR(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci;
-- 报错：1366 - Incorrect string value: '\xCE\xD2\xCA\xC7' for column 'name' at row 1, Time: 0.004000s
```

​	通过上面的案例，我们可以看到navicat“偷偷”在细节做了很多操作，如果不是了解底层这种处理当然很方便，但是如果我们要知道字符集的处理流程，就不得不脱离可视化工具，使用命令行来操作了。

​	下面我们就使用命令行来看一下如何进行操作。其实关于字符集和编码的转化规则很简单，只要一个命令就可以了解，从结果可以看到居然涉及到9个变量，而且有的看起来比较类似，比如**client**和**connection**的区别是什么？从下面的内容也可以看到字符集的存储位置，由于个人使用了macos做实验，所以存储的位置就是`/usr/local/mysql-8.0.26-macos11-arm64/share/charsets/`，这里建议读者可以自己连接一下自己的数据库看一下配置。

```MYSQL
mysql> show variables like 'character_%';
+--------------------------+-------------------------------------------------------+
| Variable_name            | Value                                                 |
+--------------------------+-------------------------------------------------------+
| character_set_client     | utf8mb4                                               |
| character_set_connection | utf8mb4                                               |
| character_set_database   | utf8mb4                                               |
| character_set_filesystem | binary                                                |
| character_set_results    | utf8mb4                                               |
| character_set_server     | utf8mb4                                               |
| character_set_system     | utf8mb3                                               |
| character_sets_dir       | /usr/local/mysql-8.0.26-macos11-arm64/share/charsets/ |
+--------------------------+-------------------------------------------------------+
8 rows in set (0.00 sec)
```

​	这样一个个的配置太难记的，我们用一图流带过：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20220125144144.png)

从上面的这个图中我们可以基本了解到下面的信息：

1. 如果character_set_results 转化后的字符集和操作系统的字符集不同，那就很可能出现乱码的可能。
2. 不管客户端使用的是什么样形式的编码，最终都会转化为character_set_connection，虽然character_set_connection看上去没什么用但是如果character_set_connection和character_set_client字符集不一致，有可能由于无法编码导致Mysql出现警告。
3. 如果客户端使用的字符集和服务端所使用的character_set_client 字符集不一致的话，就很可能出现服务器无法理解客户端请求的情况
4. 一个请求的字符集转化会在客户端和服务端交互的时候完成两次，在服务器内部完成3次的转化操作，看上去十分繁琐。

下面我们来实验一下上面出现可能乱码的情况。

​	首先是最直观的也是在windows的操作系统中使用mysql最容易产生的问题，那就是我们又可能会把查询的结果内容出现乱码的情况。这里我们根据上面实验提到的表进行 测试，我们直接通过修改results的字符集就可以看到效果：

```mysql
mysql> set character_set_results=latin1;
Query OK, 0 rows affected (0.00 sec)
mysql> show variables like 'character_%';
+--------------------------+-------------------------------------------------------+
| Variable_name            | Value                                                 |
+--------------------------+-------------------------------------------------------+
| character_set_client     | utf8mb4                                               |
| character_set_connection | utf8mb4                                               |
| character_set_database   | utf8mb3                                               |
| character_set_filesystem | binary                                                |
| character_set_results    | latin1  //被修改                                              |
| character_set_server     | utf8mb4                                               |
| character_set_system     | utf8mb3                                               |
| character_sets_dir       | /usr/local/mysql-8.0.26-macos11-arm64/share/charsets/ |
+--------------------------+-------------------------------------------------------+
8 rows in set (0.00 sec)
mysql> select * from test;
+----+------+
| id | name |
+----+------+
|  1 | ??   |
|  2 | ?    |
+----+------+
2 rows in set (0.00 sec)
```

​	接下来 我们来尝试一下如果character_set_client和character_set_connection不一样会有什么问题，

```mysql
mysql> show variables like 'character_%';
+--------------------------+-------------------------------------------------------+
| Variable_name            | Value                                                 |
+--------------------------+-------------------------------------------------------+
| character_set_client     | latin1                                                |
| character_set_connection | ascii                                                 |
| character_set_database   | utf8mb3                                               |
| character_set_filesystem | binary                                                |
| character_set_results    | latin1                                                |
| character_set_server     | utf8mb4                                               |
| character_set_system     | utf8mb3                                               |
| character_sets_dir       | /usr/local/mysql-8.0.26-macos11-arm64/share/charsets/ |
+--------------------------+-------------------------------------------------------+
8 rows in set (0.01 sec)

mysql> set character_set_client=utf8mb4;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from test;
+----+------+
| id | name |
+----+------+
|  1 | ??   |
|  2 | ?    |
+----+------+
2 rows in set (0.00 sec)

mysql> select * from test where name= '我';
Empty set, 1 warning (0.01 sec)

//==========注意关键点在这===========
mysql> show warnings;
+---------+------+------------------------------------------------------------+
| Level   | Code | Message                                                    |
+---------+------+------------------------------------------------------------+
| Warning | 1300 | Cannot convert string '\xE6\x88\x91' from utf8mb4 to ascii |
+---------+------+------------------------------------------------------------+
1 row in set (0.00 sec)
```

​	我们把client设置为latin1，把connection设置为ascii，从报错可以看到虽然我们进行基本查询的时候没啥问题，但是一旦像 服务器传输字符集没有的汉字就会出现报错了。所以在设置mysql的配置的时候，一定要把他们配置为同一个字符集，否则这个错误可能并不是那么容易发现。（通过实验可以看到如果你不传中文的内容在请求中甚至可能一直发现不了问题）

​	最后我们来试一下如何让服务端**无法**理解客户端的请求，其实也比较简单，就是让服务端采用的字符集范围比客户端使用的字符集范围小就可以了，比如把客户端设置为uft8，服务端设置为ascii，为了不让代码过多，这里省区了修改字符集的其他命令直接看结果，这串英文告诉我们的是这两个字符集无法比较，也就出现前面说的服务端无法理解客户端请求的情况下：

```mysql
mysql> select * from test where name ='我';
ERROR 1267 (HY000): Illegal mix of collations (gbk_chinese_ci,IMPLICIT) and (ascii_general_ci,COERCIBLE) for operation '='
```

​	将上面的内容实验完成之后，这时候我们会想要怎么把字符集修改回来，可以发现我们基本上主要使用的字符集也就 **character_set_client**、**character_set_connection**、**character_set_results**，这三个字符集兜兜转转所以mysql也是考虑到同时改三个字符集太麻烦了所以提供了一个快捷操作的命令：`set name 字符集` （其实这个命令也挺容易误解的），这条命令的效果大致等同于下面的命令：

```mysql
SET character_set_client = 字符集名;
SET character_set_connection = 字符集名; 
SET character_set_results = 字符集名;
```

​	比较有意思的是，这里在设置字符集的时候mysql给了提示，那就是如果直接使用utf8进行设置，官方还会进行提示。

```mysql
mysql> set names utf8;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> show warnings;
+---------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Level   | Code | Message                                                                                                                                                                     |
+---------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Warning | 3719 | 'utf8' is currently an alias for the character set UTF8MB3, but will be an alias for UTF8MB4 in a future release. Please consider using UTF8MB4 in order to be unambiguous. |
+---------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> set character_set_client=utf8
    -> ;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> show warnings;
+---------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Level   | Code | Message                                                                                                                                                                     |
+---------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Warning | 3719 | 'utf8' is currently an alias for the character set UTF8MB3, but will be an alias for UTF8MB4 in a future release. Please consider using UTF8MB4 in order to be unambiguous. |
+---------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

​	另外还有一种方法是在配置文件里面进行配置：

```mysql
[client]
default-character-set=utf8
```

​	总结：我们通常都把 **character_set_client**、**character_set_connection**、**character_set_results** 这三个系统变量设置成和客户端使用的字符集一致的情况，这样减少了很多无谓的字符集转换。

​	

# 比较规则的影响

​	了解了字符集的对于mysql请求和响应的影响之后，我们来了解一下比较规则有什么影响，之前说过字符集影响了字符串的的内容显示，那么比较规则则是影响了字符的比较操作的进行，而比较这一操作则影响了字符串的比较和排序操作，为了说明对于比较规则的影响，这里我们同样用一个简单的理解进行介绍：

> 补充：比较规则的设计要比字符集的设置要直观一些，分为三个变量 collation_connection，collation_database，collation_server，见名知义，可以分为连连接级别，数据库级别和server服务器级别，关于比较规则使用规律在 [从零开始学Mysql - 字符集和编码（下）](https://juejin.cn/post/7038059481070043172) 进行了讨论，这里就不展开了：
>
> mysql> show variables like 'collation_%';
>
> +----------------------+--------------------+
> | Variable_name        | Value              |
> +----------------------+--------------------+
> | collation_connection | utf8_general_ci    |
> | collation_database   | utf8_general_ci    |
> | collation_server     | utf8mb4_0900_ai_ci |
> +----------------------+--------------------+

1. 首先我们往前文使用 的表添加几条记录：

```sql
INSERT INTO `test`.`test` (`id`, `name`) VALUES (1, '我是');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (2, '我');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (3, '我');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (4, 'ABCD');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (5, 'A');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (6, 'a');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (7, 'B');
INSERT INTO `test`.`test` (`id`, `name`) VALUES (8, 'c');
```

2. 首先我们按照名称的顺序查询一下排序，这里在执行之前可以先查看一下当前的比较规则：

```mysql
mysql> show variables like 'collation_%';
+----------------------+--------------------+
| Variable_name        | Value              |
+----------------------+--------------------+
| collation_connection | utf8_general_ci    |
| collation_database   | utf8_general_ci    |
| collation_server     | utf8mb4_0900_ai_ci |
+----------------------+--------------------+
8 rows in set (0.01 sec)
> select * from test order by name desc;
1	我是
2	我
3	我
8	c
7	B
4	ABCD
5	A
6	a
```

3. 我们可以尝试把字符集改为其他的字符集再看一下排序的结果，可以看到排序的结果发生了改变：

> 备注： gbk_bin 是直接比较字符的编码，所以是区分大小写的

```mysql
ALTER TABLE test MODIFY name VARCHAR(255) COLLATE gbk_bin;
1	我是
2	我
3	我
8	c
6	a
7	B
4	ABCD
5	A
```



# 总结

​	通过本文我们了解到一个字符串本身是通过字符集进行编码的，使用的是本文主要了解了一个请求是如何经过mysql处理的，他的处理过程如下：

- 请求先通过客户端的字符集转为character_set_client的字符集解码，然后通过将字符串通过 character_set_connection 的格式进行编码。
- 如果**character_set_client**和**character_set_connection**一致，则进行下一步操作，否则的话会尝试将请求中的字符串从 character_set_connection的字符集转换为**具体操作的列** 使用的字符集，如果转为操作列的字符集操作还是失败，则可能会拒绝处理的情况。
- 把某列的字符集转为character_set_results的字符集编码结果，同时发送给客户端，如果此时客户端和results的编码集不一致，那么就会出现乱码的情况。
- 客户端最终使用操作系统的字符集解析收到的结果集字节串。

​	而对于比较规则细节比较少，只要记住比较规则会影响内容的排序即可，如果某一次查询的排序结果和预期不符合，那么这时候可以从排序规则入手看一下是否可以通过排序规则调整可以更好的符合预期结果。



# 写在最后

​	





​	





