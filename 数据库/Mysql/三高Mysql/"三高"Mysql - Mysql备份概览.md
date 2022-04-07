# "三高"Mysql - Mysql备份概览

# 目录

[Toc]

# 引言
​	内容为慕课网的**《高并发 高性能 高可用 MySQL 实战》**视频的学习笔记内容和个人整理扩展之后的笔记，本篇内容侧重Mysql备份的基本原理和常用介绍为主，大部分为理论相关的内容。

​	数据备份在平时的工作和学习中可能使用的比较少，但是对于一个线上项目来说却是不可或缺的一环，对于开发人员来说熟悉和了解备份的相关知识是很有必要的，学习备份的相关内容可以帮助我们了解运维工作中一些基本的备份操作。

​	本节内容偏向理论为主，重点在于了解Mysqldump如何实现增量备份和全量备份，为后面的文章介绍Mysql主备同步打下基础。



# 知识点：

- Outfile 原生mysql工具介绍
- MysqlDump对于Outfile工具改进，MysqlDump特点介绍
- MysqlDump实现增量备份和全量备份的细节
- Xtrabackup备份工具的介绍以及实现增量备份和全量备份的细节



# 备份介绍

为什么需要备份？

1.  现代的多数服务多数系统高可用，数据无价，丢失会带来难以承担的损失。

2.  一套完整的备份机制可以使得系统遇到不可抗力的情况时将数据的修复代价降到最低甚至零损失。

3.  对于任何项目都应该具备定期备份数据的好习惯，无论是否为生产项目。



备份形式

1.  物理备份：比如我们使用硬盘拷贝自己的重要数据，灵活性一般，安全性较高。

2.  云服务器备份：将数据传到第三方的云数据库进行保管，维护成本一般，安全性取决于第三方维护商的质量。

3.  自建服务器备份：开销比较大，但是数据安全性和稳定性都是最高的，也可以离线进行物理备份，可操作性强。



备份时候数据状态三种：

*   热备：正常运行备份。此时数据库可读可写。

*   冷备：停机备份。数据库无法进行任何操作。

*   **温备**：**数据库只读**。数据库可用性弱于热备，备份期间，数据库只能进行读操作，不能进行写操作



备份文件格式

备份文件的格式意味着导出的时候是什么样的：

*   逻辑备份：输出或者SQL语句，可以供技术人员阅读。

*   物理备份（裸文件）：备份数据库底层文件但是不可阅读



备份内容

*   完全备份：备份完整数据

*   增量备份：备份全量备份之后的数据差异

*   日志备份：也就是Binlog 备份



常用工具

常用的备份工具有下面两种

*   **Mysqldump**：逻辑备份，热备份，全量

*   **xtrabackup**：物理，热，全量 + 增量备份



小结

*   备份的基本形式：从备份的形式来看，可以使用物理磁盘备份，也可以依赖于三方服务商的服务器或者自建的服务器进行备份，而从备份数据状态来看，可以存在热备，冷备和温备，这里需要小心温备这个概念。

*   备份工具比较常用的有两种：**Mysqldump**和**xtrabackup**，这两种工具都需要重点掌握基础的操作使用，实践多余理论，多使用就会了。

*   开发的时候使用逻辑备份比较多，但是对于运维人员来说可能使用物理备份的方式更快，逻辑备份常常用于线上出问题的场景。



# Outfile命令备份（了解）

怎么来？

​	关于这个命令我们只需要了解，在日常使用中并不涉及使用场景，此命令为mysql自带的命令同时也是mysql 的预留关键字，可以说是最原始的逻辑备份方式，可以作为了解MysqlDump的前置基础。



使用前提

1.  **要知道网站的绝对路径，可以通过报错信息、phpinfo界面、404界面等一些方式知道**。

2.  要有file的读写权限，建议给相关文件夹执行`chmod -R /xxx/xxx` 。

3.  写的文件名一定是在文件管理中中不存在的，不然也会不成功！



特点

1.  简单的导出SQL结果主要用于临时需要数据验证的场景。

2.  Mysql原生命令支持的导出方式，执行效率高。

3.  命令简单操作方便，可以导出一致性视图。



缺陷

*   导出的格式较为简陋，通常需要对于数据进行二次处理才能正常使用。

*   只能导出SQL执行结果，没有办法将导出后的数据用于还原。

> 通过上面的介绍可以看出Outfile这个命令只能用于日常开发的场景下需要测试数据临时导出，不能作为热备的主要工具，但是这个命令对于Mysqldump来说是启发性的。



如何使用？

前提条件：在具体的导出之前我们需要了解Mysql导出的具体路径，使用下面的语句检查一下当前的安全文件导出前缀，注意结果如果为NULL在Mysql5.6版本没有影响但是**Mysql5.7**版本是存在影响的。

另外个人使用的Mac系统的文件系统管理虽然和Linux大体一致，但是其实有很多权限等等细节问题也是踩了一波小坑。

```sql
show variables like '%secure%'
-- secure_file_priv  NULL
```

> 为什么说使用`secure_file_priv`为NULL是存在影响的？
>
> 解答：
>
> &#x20;   Mysql5.7的版本中，在Mysql启动的时候，如果使用了这个参数的配置则会 **限制你可以使用LOAD DATA INFILE**加载文件的范围，意味着如果想要导出必须是在这个配置指定的目录下面才能成功，下面是此配置对应的变化：
>
> 1\. secure\_file\_priv 为 NULL 时，表示限制mysqld**不允许导入或导出**。
>
> 2\. secure\_file\_priv 为 /tmp 时，表示限制mysqld**只能**在/tmp目录中执行导入导出，其他目录不能执行。
>
> 3\. secure\_file\_priv **没有值**时，表示**不限制**mysqld在任意目录的导入导出。



完成上面这些准备工作之后，我们需要搭建基本的操作环境，比如新建数据库或者表，这里依然使用了sakila数据库，我们可以使用下面的命令进行尝试导出，比如下面的语句中我们将payment表的所有数据导出。

```sql
select * from payment into Outfile '/Users/xxx/xxx/a.csv' 
```

> 注：Sakila数据库在Mysql官方的example中可以直接下载。

但是实际执行过程中会出现如下的报错，从报错信息可以看到这里是因为`secure_file_priv`为`NULL`的问题：

```sql
1290 - The MySQL server is running with the --secure-file-priv option so it cannot execute this statement, Time: 0.004000s
```

再次强调个人学习的时候使用的是macos系统，设置起来比较麻烦这里也不啰嗦具体细节了，主要讲一下处理思路：

*   设置自定义的配置`my.ini`文件并且放到`/etc` 的目录下面（Mysql读取配置文件规则最高优先级），在文件结尾设置此参数：`secure_file_priv=/Users/xxxx/xxx/`然后`:x`保存（注意用`sudo vim my.ini`），导出路径建议选的当前`/User/xxx`家目录，方便导出之后立马打开。（根路径路径不太安全，macos系统也不允许你这么弄）

*   重启Mysql或者重启电脑，连接Mysql之后继续执行上述命令后发现报错：`PermissionError: [Errno 13] Permission denied`，明显是macOs的权限问题，通过命令`chmod 777 导出文件夹/* `可以给整个文件夹开放权限（根目录不要这样做）。

*   **如果出现重名文件使用命令一样报错**，提示导出文件已经存在，切记每次执行前检查是否重名文件。

> Macos使用`brew`安装Mysql会发现没有`my.ini`文件，个人从网上翻了份能用的直接在下面链接提供的文件尾部添加`secure_file_priv=/Users/xxxx/xxx/`即可 ，省去大伙的时间，当然是针对我这种蛋疼的MacOs系统来说的，其他操作系统应该可以直接找到相关配置文件。
>
> 链接: [https://pan.baidu.com/s/1bM3cQtaXMl3ZGNgQRzhEMA](https://pan.baidu.com/s/1bM3cQtaXMl3ZGNgQRzhEMA "https://pan.baidu.com/s/1bM3cQtaXMl3ZGNgQRzhEMA") 提取码: phkg



> 插曲：Maxos使用homebrew安装版本的启动和关闭：
>
> 关闭：`sudo pkill -9 mysql`
>
> 启动：`cd /usr/local/mysql/support-file/mysql.server start（stop关闭）`



上面啰嗦一大堆之后，下面是最终导出的结果，可以看到默认只使用了空格分隔，并且格式比较乱：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204071404540.png)

Outfile使用也是比较好记的，同时下面是Outfile的一些使用参数，通过这些参数可以自由配置：

```sql
SELECT ... INTO Outfile 'file_name'
        [CHARACTER SET charset_name]
        [export_options]
 
export_options:
    [{FIELDS | COLUMNS}
        [TERMINATED BY 'string']
        [[OPTIONALLY] ENCLOSED BY 'char']
        [ESCAPED BY 'char']
    ]
    [LINES
        [STARTING BY 'string']
        [TERMINATED BY 'string']
    ]


```

我们发现上面的格式比较混乱，我们 希望按照规范表格的形式导出，于是我们可以在每一行的数据之间添加都好，让导出之后的数据保持规范。

```sql
select * from payment into Outfile '/Users/xxx/xxx/a.csv' FIELDS terminated by ','
```

从结果可以看出Outfile只能用作一些简单的场景的导出操作：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204071405081.png)



到此为止我们只需要简单了解这个命令即可，为下面了解`Mysqldump`打下原理基础。



# Mysqldump命令使用

`Mysqldump`的命令可以看作是Outfile命令的扩展，作为十分重要的备份工具经常用于开发和测试的场景，当然线上不推荐使用这种命令操作，一般需要由运维人员操作来导出需要的数据，如果直接对着整个库热备份很容易出问题。

「知识点」

1. Outfile的痛点，或者说Mysqldump改进点

2. Mysqldump特点

3. Mysqldump的操作（实战案例）

4.  Mysqldump的增量备份如何实现（原理）

    - Binlog 忠实记录mysql变化
    
    - Mysqldump通常只能全量备份，所以借助Binlog作为增量备份。
    
    - **关键：Mysqldump备份，切换新的Binlog文件**，之后拷贝binlog文件作为增量备份，注意全量备份和增量备份文件的不同。
    
    - 采用从零开始还原，采用全量还原 + Binlog还原。
    
2.  Mysqldump通常只能全量备份，使用Binlog增量备份
    - 关键：Mysqldump备份，切换新的Binlog文件。
    
4.  采用从零开始还原：全量还原 + Binlog还原



## Outfile的痛点

​	只要简单操作一下Outfile命令就会发现Outfile有下面这几个明显的缺点，Mysqldump其实就是解决了Outfile的很多现实问题，并且在此基础上改进让它更加简单好用。

*   只能导出数据，很难把数据再次导入
*   无法做逻辑备份，也就是备份SQL逻辑
*   导出形式单一，通常只能导出excel。



## Mysqldump特点

*   Mysql官方内置命令，内置实现可以避开很多没有必要的问题。
*   支持远程备份，可以生成多种格式的文件。
*   与存储引擎无关，可以在多种存储引擎下进行备份恢复，对innodb引擎支持热备，**对MyISAM引擎支持温备（施加表锁）**。
*   免费。



## 如何学习Mysqldump？

官方开发的当然是官方文档学习最好啦，链接提供的是Mysql8.0的版本，其他版本需要根据自己当前使用的版本切换阅读，另外命令参数不需要去记忆也没有意义，在需要的时候翻出来看看然后看看官方文档即可：

> 任何工具类的东西适合使用的时候查阅，死记硬背是没有意义的，最后会发现只需要记住常用的方式即可。

​	<https://dev.mysql.com/doc/refman/8.0/en/Mysqldump.html>



## 备份所需权限

*   如果需要备份数据至少需要`SELECT`权限。

*   备份视图需要`SHOW VIEW`权限。

*   备份触发器需要`TRIGGER`权限。

*   如果不使用参数[**--single-transaction**](https://dev.mysql.com/doc/refman/8.0/en/Mysqldump.html#option_Mysqldump_single-transaction "--single-transaction")，则需要相关权限进行锁表。

*   （从MySQL 8.0.21开始）如果不使用`--no-tablespaces`选项则需要`PROCESS`权限。

*   如果需要导入备份数据，则需要包含执行语句的所有权限，比如`CREATE、ALTER、DELETE`权限



## 实践：MysqlDump备份案例

​	我们可以尝试备份一下官方提供的example比如sakila，下面是一些简单的操作命令：

​	备份一个数据库

```sql
-- 第一种备份方法
./Mysqldump -uroot -pxxxxxx sakila > /Users/xxx/xxx/xxx/xxxx/backup-file.sql
-- Mysqldump: [Warning] Using a password on the command line interface can be insecure.

```

​	备份多个数据库到一个sql文件

```sql
./Mysqldump  --databases sakila sakila-db -uroot -xxx > /Users/xxx/xx/xxxx/xxx/backup-file_bk2.sql     
```

​	**将数据从一个服务器备份到另一个服务器**

```sql
-- 个人是本地单机没有进行虚拟机模拟，实验结果未知
Mysqldump --opt db_name | mysql --host=remote_host -C db_name

```

​	如果使用InnoDB 的存储引擎Mysql有一种在线备份的方法：

```sql
-- 参数解释
-- --all-databases 所有数据库
-- --single-transaction RR级别的备份，也就是确保一致性的视图(Innodb存储引擎)
-- --master-data 将二进制日志文件的名称和位置写到输出端(留意一下，为下文的增量备份铺垫)
-- 如果不是InnoDB,需要使用下面的参数：
-- 1. --lock-all-tables 使用FTWRL锁锁住所有表（MyISAM）
-- 2. --lock-tables 使用READ LOCAL锁住当前库的表（MyISAM）

Mysqldump -uroot -pxx --all-databases --master-data --single-transaction > /Users/xxx/xxx/all_databases.sql
```

​	还原数据库

```sql
-- 
./Mysqldump -uroot -pxxxxxx sakila < /Users/xxx/xxx/xxx/xxxx/backup-file.sql

-- 第二种还原备份方法
-- 1. 使用具备相关权限的用户名和密码登陆连接到mysql服务器 mysql -uroot -proot 
-- 2. source /xxx路径/xx.sql文件 source xxx.sql

-- 第三种方式
mysql -e "source /path-to-backup/backup-file.sql" db_name

```

​	关于其他的命令这里就不再扩展了，这里介绍一些常用的基本够日常开发使用了，如果需要更多的写法可以参考上面的官方文档。



## Mysqldump的增量备份实现原理

​	上面提到的都是全量备份的方式，虽然我们在拷贝的时候可以通过[**--single-transaction**](https://dev.mysql.com/doc/refman/8.0/en/Mysqldump.html#option_Mysqldump_single-transaction "--single-transaction")拷贝一致性的视图，虽然拷贝那一刻的数据记录是全量并且完整的，但是此时数据库依然是存在还在执行的增量数据的，那么这部分数据应该如何备份呢？

​	使用Mysqldump的进行增量备份首先需要了解增量备份的细节，所以这里就轮到Binlog日志上场了，Binlog的备份包含下面几个小点：

1.  Binlog 忠实记录mysql变化，全量增量备份和还原过程。

2.  Mysqldump通常只能全量备份，所以借助Binlog作为增量备份。

3.  **关键：Mysqldump备份，切换新的Binlog文件**，之后拷贝binlog文件作为增量备份，注意全量备份和增量备份文件的不同。

4.  采用从零开始还原，采用全量还原 + Binlog还原。

> 为什么不能同时增量和全量备份：
>
> 我们可以把 Mysql记录日志的过程看作是在纸上写字，此时Mysql在最新的Binlog日志中记录内容，如果我们把正在写的内容和之前的日志内容一并备份，就很可能导致**备份出写了一半的数据**，就好像我们写字的时候突然被抽中本子一样，这样就很有可能导致数据损坏。



​	Binlog 忠实记录mysql变化，全量增量备份和还原过程。

​	实现增量备份的关键点在于如**何给Binlog日志做切入点**，做Mysqldump增量备份存在的最大问题是我们无法知道当前的**全量备份和增量数据的分界点**。Binlog日志记录的是Mysql的变化内容比如CRUD的数据记录变动记录以及数据的结构的调整等等，并且和InnoDB的存储引擎的`redo log`双写保持事务一致性。

​	根据上面的内容介绍我们知道了**Mysqldump只能全量备份，需要借助Binlog日志完成增量备份**。

​	增量备份实现思路是在备份的时候将当前正在读写的Binlog日志停掉，并且将此文件进行拷贝，但是需要注意的是此时拷贝的是Binlog文件，和日常编写的逻辑SQL是不一样的，切记。

​	**关键点：Mysqldump备份，Mysql服务器停止当前Binlog写入并且切换新的Binlog文件**

​	Mysqldump提供了类似上面提到的操作，下面是Mysqldump全量备份+增量备份的操作流程：

```sql
-- --all-databases 所有数据库
-- --single-transaction RR级别的备份，也就是确保一致性的视图(Innodb存储引擎)
-- --master-data=[=Value]（8.0.26改为--source-data命令） 将二进制日志文件的名称和位置写到输出端(留意一下，为下文的增量备份铺垫)
-- --flush-logs 在备份之前刷新服务器的日志 
Mysqldump -uroot -pxx --all-databases --master-data=2 --flush-logs --single-transaction > /Users/xxx/xxx/all_databases.sql
```

​	通过执行上面的命令之后首先会进行**全量备份**同时会把Binlog切换到下一份日志文件重新开始进行读写，此时就可以把这一份停止写入对binlog日志文件备份出来进行后续的增量备份还原，简而言之：Mysql备份的同时切换Binlog，并且把当前写了一部分的Binlog日志进行拷贝。

​	Mysql其实还有一种备份方式那就是Binlog手动增量备份，实现方式是直接使用命令把缓存的日志刷到磁盘中并且切换到下一个Binlog，它的命令格式如下：

```sql
mysqladmin -uroot -p123456 flush-logs
```

​	需要注意的是这里使用的是`mysqladmin`工具，在执行命令之后我们可以手动将所有的Binlog进行备份。

​	还原方式：**全量还原 + Binlog还原**，还原操作和增量全量备份方式对应，因为是Mysqldump全量+Binlog增量备份，所以同样需要先进行全量还原再增量还原。

​	恢复全量备份：还原的操作最简单的方式是连接服务器之后执行`source xxx.sql` ，而Binlog增量还原操作案例如下：

```sql
mysqlBinlog Mysql-bin.00002 ... | mysql -uroot -p123456
```

​	

小结

1.  `Mysqldump` + `Binlog` 可以有效进行全量 + 增量备份。
2.  Mysqldump实际上是对于Outfile工具的扩展和升级。
3.  Binlog备份，Binlog还原，Mysqldump备份可以看出不同组件的搭配。
4.  从理论上来说Binlog可以还原到任意的时刻。
5.  Mysqldump 的参数较多，熟悉和掌握需要多加练习。
5.  需要注意区分mysqladmin、mysqlBinlog、mysqldump



# XtraBackup物理备份

​	XtrqBackup虽然不是官方开发的工具，但是使用的频率却远高于mysqldump，物理备份相对比mysql的逻辑备份来说更加可靠，同时对于系统的影响也要更小。

​	为什么需要物理备份通常具备下面的理由：

1.  逻辑备份针对大数据量备份速度十分缓慢。

2.  导出速度快不需要二次转化。

3.  对于数据库的压力较小。

4.  增量备份更加容易。



**直接拷贝裸文件可行么？**

我们直接CV数据库的文件可以么？理论上是可行的但是实际操作会发现有很多问题，以Innodb的存储引擎的数据为例，它不仅涉及Binlog文件，idb文件（数据库原始数据）以及frm文件，还包括独有的redo log和 undo log这些文件等，此时会发现如果要拷贝这些文件**只能冷备**，但是仅仅冷备还是不行的，因为这里还牵扯操作系统和数据库版本兼容等等问题，有十分明显的跨平台的问题。

从结论来看，直接拷贝裸文件理论上是可行的，但是实际上备份出来的数据可能完全不可用，甚至可能无法兼容。



## 如何实现物理+全量+热备？

实现思路如下：核心的思想是监听`redo log`文件变化的同时，备份`Idb`文件和备份过程中进行了改动的`redo log`文件。

1.  启动监听线程，收集redo log

2.  备份idb文件，记录**监听**过程中新产生的redo log日志

3.  备份idb完成，停止收集redo log日志

4.  **增加FTWRL锁拷贝元数据frm**

> FTWRL锁是啥？
>
> `FLUSH TABLES WITH READ LOCK`简称(FTWRL)，该命令主要用于备份工具获取一致性备份(数据与Binlog位点匹配)。需要注意的是这个锁的粒度非常大，基本是锁住整个库的等级，如果是备份主库会导致整个主库“卡”住，从库则会导致线程等待。
>
> 所需权限：`FLUSH_TABLES` 和 `RELOAD`权限。
>
> 由于这里讲的主要是备份的内容，想进一步了解FTWRL锁实现细节和使用教程可以参考下面的博客：
>
> *   [FLUSH TABLE WITH READ LOCK详解 - 天士梦 - 博客园 (cnblogs.com)](https://www.cnblogs.com/cchust/p/4603599.html "FLUSH TABLE WITH READ LOCK详解 - 天士梦 - 博客园 (cnblogs.com)")
>
> *   [MySQL 全局锁和表锁 - keme - 博客园 (cnblogs.com)](https://www.cnblogs.com/keme/p/11065025.html "MySQL 全局锁和表锁 - keme - 博客园 (cnblogs.com)")



注意在第四步给整个库加全局锁会有一段时间数据库是处于温备的情况的（不能进行读写）。

这里还存在一个问题，如何知道哪些数据是增量数据？Xtrabackup的思路是在Mysql中每一个数据页存在一个**LSN号**码，在备份的时候可以通过这个LSN号确定哪个页存在变化，当进行过一次全量备份之后记录变化过数据的LSN号，在下一次备份可以直接找比上一次LSN号更大的值进行备份。

> LSN（log [sequence](https://so.csdn.net/so/search?q=sequence\&spm=1001.2101.3001.7020 "sequence") number）：日志序列号，是一个一直递增的整形数字，在MySQL5.6.3版本后占8个字节。它表示事务写入到日志的字节总量。LSN主要用于发生crash时对数据进行recovery！每个**数据页**、**重做日志**、**checkpoint**都有LSN。



## Xtrabackup介绍

在介绍Xtrabackup之前需要了解Mysql的`ibbackup`，它是由Innodb官方开发，后续被改名为`Mysql Enterprise Backup`，由于这个软件为收费软件用户并不多，所以后续出现了完全替代品`Xtrabackup`并且被广泛使用。

Xtrabackup是由percona开源的免费数据库备份软件，不同于Mysqldump这是一个第三方公司开发的软件，在前面提到的Mysqldump命令是逻辑备份，逻辑备份最大的问题是在数据量特大的情况下导出会十分缓慢并且十分影响数据库的读写性能，并且导出的时候需要对于数据库进行“RR级别”的锁定或者使用表锁（MyISAM），所以对于大数据量还是建议使用物理备份的方式备份。

Xtrabackup安装完成后有4个可执行文件，其中2个比较重要的备份工具是**innobackupex**、**xtrabackup**。下面是xtrabackup其他工具的大致介绍：

1）xtrabackup 是专门用来备份InnoDB表的，和mysql server没有交互；

2）innobackupex 是一个封装xtrabackup的Perl脚本，支持同时备份innodb和myisam，但在对myisam备份时需要加一个全局的读锁。

3）xbcrypt 加密解密备份工具

4）xbstream 流传打包传输工具，类似tar



## XtraBackup特点

*   备份速度快，几乎不影响服务器的正常业务处理

*   压缩存储，节省磁盘容量，同时可以存储到另一个服务器

*   还原速度很快，对于服务器的负载较小。

## XtraBackup安装过程

Xtrabackup是没有windows和mac版本的，只有linux版本，所以需要做实验也只能使用linux系统，所以这里简单记录一下如何安装：

下载地址：[Percona Software downloads for databases](https://www.percona.com/downloads/ "Percona Software downloads for databases")

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202204070747277.png)

注意里面包含很多软件，这里找到如上截图所示的界面，根据自己的Mysql 版本下载：

*   8.0：对应Mysql8.0以上版本。
*   2.4：对应Mysql5.0 - Mysql5.7版本。

下面是xtrabackup的大致安装操作流程：

```bash
wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/redhat/6/x86_64/Percona-XtraBackup-2.4.9-ra467167cdd4-el6-x86_64-bundle.tar

[root@centos ~]# ll

total 703528

-rw-r--r-- 1 root root 654007697 Sep 27 09:18 mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz

-rw-r--r-- 1 root root  65689600 Nov 30 00:11 Percona-XtraBackup-2.4.9-ra467167cdd4-el6-x86_64-bundle.tar

[root@centos ~]# tar xf Percona-XtraBackup-2.4.9-ra467167cdd4-el6-x86_64-bundle.tar

[root@centos ~]# yum install percona-xtrabackup-24-2.4.9-1.el6.x86\_64.rpm -y

[root@centos ~]# which xtrabackup 

/usr/bin/xtrabackup

[root@centos ~]# innobackupex -v

innobackupex version 2.4.9 Linux (x86\_64) (revision id: a467167cdd4)

#已经安装完成

```

## XtraBackup全量备份与恢复

Xtrabackup安装完成之后，我们可以使用下面的命令进行备份操作：

```sql
[root@centos ~]# innobackupex --defaults-file=/etc/my.cnf --user=root --password="123456" --backup /root
```

执行完成之后，会在对应的目录里面新增一个日期文件目录，接着我们需要同步log日志：

```sql
#使用此参数使用相关数据性文件保持一致性状态
[root@centos ~]#innobackupex --apply-log /root/(日期)/
```

最后我们通过下面的命令对于备份文件进行恢复：

```sql
[root@centos ~]# innobackupex --defaults-file=/etc/my.cnf --copy-back /root/(日期)/
```



## Xtrabackup增量备份与恢复

需要注意的是增量备份仅能应用于**InooDB**或XtraDB表，下面的命令用于创建增量备份的数据。

```sql
[root@Vcentos ~]# innobackupex --defaults-file=/etc/my.cnf --user=root --password=123456 --incremental /backup/ --incremental-basedir=/root/(日期)

#--incremental /backup/   指定增量备份文件备份的目录

#--incremental-basedir    指定上一次全备或增量备份的目录
```

增量备份的恢复命令：

```sql
[root@centos ~]# innobackupex --apply-log --redo-only /root/(日期)/

[root@centos ~]# innobackupex --apply-log --redo-only /root/(日期)/ --incremental-dir=/backup/(日期)/
```

如果需要恢复全部的数据，可以使用下面的命令处理：

```sql
[root@centos ~]#innobackupex --defaults-file=/etc/my.cnf --copy-back /root/(日期)/
```

增量备份合并至全量备份，可以使用下面的命令：

```sql
innobackupex --apply-log bakdir/xxx-xx-xx/ --incremental-dir=basedir/YYYY-YY-YY/
```

小结

*   物理备份是一种高效备份方式。

*   XtraBackup 采用备份idb + 备份期间监听改动redo log的方式实现全量热备+增量备份。

*   XtraBackup 是常用的Mysql物理备份工具。

*   物理备份最大缺点是备份之后的文件无法直接阅读。



# Mysql备份产生的创新

从Mysqldump对于备份的改进过程中我们可以从下面的方式进行思考：

1.  直接复制磁盘：比复制数据文件更为直接，直接复制物理磁盘设备镜像备份。

2.  多线程备份：通过多线程的方式加快备份的速度。

3.  备份工具管理：我们可以发现传统备份都是小黑框，对于备份工具本身进行管理的软件是许需要的。

由此扩展出下面几个比较特殊的备份方式扩展：

- Mylvmbackup：LVM备份磁盘。备份磁盘是一种**物理温备**的备份方式，备份磁盘本身是一种很好的思路扩展，但是备份磁盘同样有一个严重的问题，那就是兼容性的问题，所以这个备份工具使用了LVM逻辑卷进行磁盘管理。

- Mydumper：多线程备份。这个工具的使用频率甚至比Mysqldump还要高一些。Mydumper主要有下面的特点

​	1. 和Mysqldump类似的工具，2. 实现了多线程兵法备份还原，3. 速度更快。

- Zmanda Recovery Manager（ZRM）：备份工具管理。提供了可视化的方式管理备份文件，类似于数据库管理工具中的navicat，这个工具的特点是集成Binlog和多种备份工具。



# 如何养成良好数据管理习惯

​	最后无论多少的备份软件其实最好的情况是备份的数据我们永远也用不上，除开备份以外我们还有其他的方式来防止数据丢失，比如遵循下面的规范：

*   权限隔离

    *   业务只有DML权限，删除尽量使用假删除

    *   开发人员只拥有只读账号，当然很多情况下稍微大一些的公司都有明确的权限管理。

    *   DBA日常只使用只读账户，特殊操作再切换账号

    *   永远不要使用root直接连客户端，禁用root连接mysql

*   SQL 审计

    *   DBA环境上线之前审计SQL语句

    *   开发修改数据需要DBA执行

    *   Inception 自动审核工具

*   伪删表

    *   删表之前先改个名字，观察业务影响
*   删除过程使用脚本给特殊标记表名称删除，而不是手动操作
    *   对于本地开发需要备份的表可以使用加入`_bak`进行标记。

*   完备过程

    *   上线之前必须备份

# 总结

​	本节从Outfile这个古老的命令入手，介绍了mysqldump的命令前身以及对于outfile命令的改进优化，讲述如何通过mysqldump实现增量和全量备份，同时介绍了内部的细节。但是逻辑备份通常只适用于数据量不是很大并且系统运行接受一定延迟响应对情况下可以这么做，一旦数据量过大并且要求快速响应，如果想要热备不影响系统，更加推荐Xtrabackup备份，这个工具可以说是运维备份Mysql DB的一大杀器，十分强大并且十分好用，这里简单介绍了实现的细节，对于XtraBack的细节探索这里就不做过多演示了，更建议参考官方资料熟悉工具的使用。



# 写在最后

​	本篇同样侧重理论为主，下一篇内容围绕整个课程的核心如何搭建“三高”架构进行讲解。
