# 从零开始学Mysql - 连接管理和存储引擎

# 前言

​	本篇为个人mysql专栏的第二篇，第二篇将会是关于连接管理以及存储引擎的讨论，以及mysql底层的交互过程，这个概念在之前的mysql专栏中有提到过，这里再一次进行总结，在第一篇开篇的时候讨论过这个专栏的内容大多数都是参考《从根上理解Mysql》这本书，这里再次强调一遍，后续专栏文章不会再进行赘述。



# 概述

1. 客户端和服务端的连接过程
   1. Tcp/ip 方式：重点为IP地址和端口
   2. 命名管道和共享内存：window独有的连接方式，但是没什么鸟用，不用理会
   3. Unix域套接字文件：如果服务端修改套接字的默认监听文件
2. mysql请求处理流程
   1. 连接管理：服务端接口客服端的查询sql语句
   2. 查询优化：主要任务为拆解命令并对命令进行“编译”
   3. 存储引擎：通过对外接口API接受命令并且查询数据
3. 存储引擎介绍
   1. 存储引擎介绍
   2. 修改存储引擎





# Mysql连接

## 连接方式

### Tcp/IP

​	Tcp是一种网络的通信协议，通常我们只需要关注两个参数，**IP和端口**，IP地址可以看作门牌号，而端口可以看作应用程序的入口，进行网络通信需要IP和端口号才能完成，而端口号的范围通常为**0-65535**，有了IP地址和端口之后我们既可以进行mysql连接了，日常使用中最常见的`mysql -uroot -pxxx`命令，这一条命令的连接方式实际就是一种TCP/IP的连接方式。

​	Mysql如果在安装过程不进行其他改动的情况下默认占用**3306**的端口，客户端中我们连接的时候可以通过`mysql -P3307`中的`-P`参数进行端口的指定，而服务端的启动则可以使用`mysqld -P3307`指定用其他的端口启动一个mysql的服务端服务，注意不要看花眼了，上面的参数客户端是`mysql`而服务端是`mysqld`。

> 个人比较推荐端口的选择上在软件默认的端口前面加个1，比如mysql的默认端口3306推荐使用13306，这样可以有效的规避可能存在的和其他的应用程序的端口占用或者冲突，并且可以发现其实大多数的中间件或者框架都是使用1万以内的端口。

​	

### 命名管道和共享内存

​	这个方式主要针对window用户，客户端和服务端之间可以使用叫做命名管道或者共享内存的方式进行连接，由于这个东西 **不重要**所以简单了解即可，另外根据官方文档的介绍这种连接符方式要比TCP/IP的连接方式快30%-50%。

​	命名管道：因为Mysql默认是不启用这个命名管道的方式的，需要在启动服务器程序的命令中加上 `--enable-named-pipe` 参数，然后在启动客户端程序的命令中加入` --pipe`或者 `--protocol=pipe` 参数，或者我们在`my.ini `文件当中对于下面的内容进行修改：

```mysql
MySQL 默认是不启用命名管道连接方式，启用方法：
[mysqld]
enable-named-pipe
socket=MySQL
```

​	最后给出一个简单的JAVA例子了解如何配置链接即可，核心部分为：`socketFactory=com.mysql.jdbc.NamedPipeSocketFactory`：

```java
public class MySQLNamedPipeTester {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.jdbc.Driver").newInstance();
        Connection conn = DriverManager.getConnection(
                "jdbc:mysql:///oschina?socketFactory=com.mysql.jdbc.NamedPipeSocketFactory",
                "root",
                "xxxx");
        PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM xxxx");
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            System.out.println(rs.getInt(1));
        }
        //conn.close();
    }
}
```

​	共享内存：共享内存的连接方式**必须**保证客户端和服务端进程在同一个Windows主机，否则是无法生效的，共享内存的方式是在启动服务器程序的命令中加上` --shared-memory` 参数，并且进行重新启动之后即可，不过我们也可以在客户端的命令当中加入类似`--protocol=memory`参数来指定使用共享内存的方式通信。

### Unix域套接字文件

​	不是很重要的东西，同样简单了解即可，这种连接方式有点类似于本地的线程通信，因为现代操作系统多数都是从UNIX衍生出来的，所以这种连接方式需要操作系统底层的通信支持，既然是本地线程通信那么自然需要保证客户端和服务端在同一个机器上。套接字连接比较常用的场景比如我们平时使用localhost连接或者我们指定`--protocol=socket`的启动参数，MySQL 服务器程序默认监听的 Unix 域套接字文件路径为` /tmp/mysql.sock `，同样客户端也会默认连接这个套接字，如果我们想要修改这种默认的连接方式，我们需要作出如下的调整：

​	服务端：服务端在启动的时候可以指定`mysqld --socket=/tmp/a.txt`，这样默认监听的套接字文件就改变了

​	客户端：由于服务端改变了监听的文件，所以客户端进行UNIX套接字文件连接就需要使用在命令中加上`--socket=/temp/a.txt`的参数，例如`mysql -hlocalhost -uroot --socket=/tmp/a.txt -p`

> 再次强调一遍mysqld这个命令其实并不是常用，这里仅仅作为演示命令使用方式

​	



## 请求处理流程

​	请求的处理逻辑从整体上看就是：客户端发送一段sql语句然后服务端根据sql语句获取结果文本返回给客户端。请求处理流程在书中感觉并不是十分直观，这里用以前画的一幅图作为对比解释，可以看到从整体上看整个mysql的连接分为三个部分，第一部分为连接管理，主要负责的是和客户端的请求交接，以及接受客户端发送过来的命令等等，第二部分为解析优化，主要是检查sql语句是否被执行过，以及进行语法的翻译操作和优化语句的命令，第三部分为存储引擎，也是mysql最核心的部分，存储引擎是最终进行数据查询地方，它会根据第二部分的命令去找到相关的数据然后返回给客户端，下面我们分小节来一一讲解他们的作用。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211105074302.png)



​	   ![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210828115748.png)

### 连接管理

​	连接管理部分就是使用上面所说的连接方式进行服务端和客户端的交互，通常情况下我们会使用数据库连接池进行连接，所以mysql会为每一个连接的客户端分配一个线程进行交互，但是交互完成之后 **并不是马上把线程销毁**，通常要进行缓存并且留给下一个客户端连接使用，这样就减少了线程创建和分配以及销毁的开销。

​	另外连接管理部分通常也有诸多限制，比如需要用户名和密码进行认证，如果mysql不在同一台机器上也可以使用SSL的加密通信方式保证mysql连接的安全。

### 解析优化

​	解析优化的部分是mysql的重点，它包含了 **查询缓存，词法分析和查询优化**这三个部分。

**查询缓存：**

​	查询缓存在8.0的版本中已经删除了，在mysql5.7的版本中也已经不推荐使用，至于原因大致可以理解为现代的互联网资源不比以前，硬盘容量随便用不说，内存也是随便加，根本不差那点查询缓存的性能，但是重要原因基本还是 **缓存命中率极低**，比如下面的查询缓存命中的规则：

​	**1. 如果两个查询请求在任何字符上的不同(例如:空格、注释、大小写)，都 会导致缓存不会命中**。

​	**2. ** **如果使用了部分系统函数，比如now()，sum()等或者使用mysql 、information_schema、 performance_schema等系统表的时候，即使语句和结果一摸一样，也是不走缓存的**。

​	**3. 如果对于数据表进行过CRUD的操作，那么所有的缓存必须全部失效，并且将缓存立即从高速缓存中删除**

​	可以发现单纯上面的两点基本可以让绝大多数的缓存失效现代的搜索和查询多样化，导致查询缓存根本用不上，既然用不上那还维护它干啥，所以新版本基本也就不推荐使用并且在8.0版本直接删除了，

**词法分析：**

​	词法分析就是从请求命令语句中提取“关键字”，并且拆分命令是插入还是删除还是查询等等，也可以理解为mysql在对于命令进行自己的“编译”操作。

**查询优化：**

​	词法解析之后mysql就可以知道我们查询的是哪一张表，查询优化的任务是将我们的查询命令根据mysql的一套规则进行优化，比如删除无意义的条件，简化查询语句等等，总之优化的目的就是提高查询的效率（事与愿违，有时候会帮倒忙），在mysql中可以使用`explain`查看的语句的执行计划。



### 存储引擎

​	存储引擎接受查询优化器优化之后的命令就开始干活了，所以存储引擎才是真实的数据存储模块管理者，负责记录表的存储位置，怎么把数据写入到物理硬盘上等等，但是具体的存储方式取决于存储器的数据结构设计。

### 小结

​	经过上面的介绍之后，现在需要区分mysql请求处理的概念概念，首先在宏观的层面上可以把mysql看作两个部分，第一个部分是从 **连接管理-查询优化**这一条链路，这一部分做的事情主要是接受请求并且解析和优化命令，但是实际上**并没有任何的数据操作**，通常这部分划分到` Mysql Server`的部分。第二部分是 **存储引擎**，它才是真正干活的角色，主要负责数据的读取和存储，以及根据对外的接口进行实际的数据操作，最后这两个部分通过**统一的调度接口**进行关联，也就是说存储引擎需要实现特定的接口 API 接受命令的解析，优化完成的语句通过接口发送给存储引擎即可，这也意味着 **Sever其实并不需要关心如何存储数据**。

# 存储引擎介绍

​	mysql的常用的存储引擎包含下面的部分，其实一般常用的也就**MERMORY，MyISaM，InnoDB**这三个。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211105134028.png)

​	下面是存储引擎对于特殊功能的支持情况，当然也是简单了解即可

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211105163032.png)

## 查看当前系统支持的存储引擎

命令：`SHOW ENGINES;`

| Engine             | Support | Comment                                                      | Transactions | XA   | Savepoints |
| ------------------ | ------- | ------------------------------------------------------------ | ------------ | ---- | ---------- |
| ARCHIVE            | YES     | Archive storage engine                                       | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                        | NO           | NO   | NO         |
| FEDERATED          | NO      | Federated MySQL storage engine                               |              |      |            |
| MyISAM             | YES     | MyISAM storage engine                                        | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                           | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys   | YES          | YES  | YES        |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables    | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                           | NO           | NO   | NO         |

参数解释：

​	Support：存储引擎是否可用

​	DEFAULT：当前服务器默认的存储引擎，可以看到是InnoDB

​	Comment：存储的引擎的描述，应该不难懂

​	Transactions：是否支持事务

​	**XA：是否支持分布式事务**

Savepoints：是否支持**部分事务**回滚

## 修改存储引擎

​	一条语句：`ALTER TABLE 表名 ENGINE = 存储引擎名称;`

​	下面直接用书上的案例进行效果演示：

```
 mysql> ALTER TABLE engine_demo_table ENGINE = InnoDB;
    Query OK, 0 rows affected (0.05 sec)
    Records: 0  Duplicates: 0  Warnings: 0
mysql>
 
 mysql> SHOW CREATE TABLE engine_demo_table\G

  *************************** 1. row ***************************

Table: engine_demo_table

  Create Table: CREATE TABLE `engine_demo_table` (

   `i` int(11) DEFAULT NULL

  ) ENGINE=InnoDB DEFAULT CHARSET=utf8

  1 row in set (0.01 sec)

mysql>
```

# 总结

​	到此书中的第一篇内容算是讲述完了， 可以看到第一章节的内容都是非常浅显的内容，后续的难度会逐渐加强。本文的的重点部分毫无疑问就是请求的处理流程部分，特别是**存储引擎**，在后续的很多内容讲解都是围绕存储引擎Inn DB进行介绍的，我们学习Mysql的深入内容同样如此。



# 写到最后

​	再次回顾一遍发现内容还是比较简单的，如果觉得有帮助不妨点个赞？

