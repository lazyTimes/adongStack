# 从零开始学MYSQL - MYSQL安装

# 前言

​	这个专栏也可以认为是学习笔记，由于之前的专栏学习的是网络上的培训机构教程，学习完成之后发现虽然讲到一些有一些深入的东西，但是讲的都不是特别深，所以从这一节开始将会从零开始来全盘了解MYSQL，这里找了一本书《从根上理解Mysql》，个人也十分推荐读者去看看这边书，不仅有新特性对接讲解，也有很多的干货，同时讲的也十分好，作为支持个人后面也买了一本实体书（虽然基本都是拿pdf看的）。



# 思维导图（持续更新）

https://www.mubucm.com/doc/7DDOY0CuMK5

图片地址：https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211029134243.png

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211029134243.png)



# 参考资料：

1. 英文mysql5.7官方文档：https://dev.mysql.com/doc/refman/5.7/en/mysqld-safe.html
2. 中文对应翻译网站（机翻）：https://www.docs4dev.com/docs/zh/mysql/5.7/reference/preface.html



# 概述

1. 认识mysql的客户端和服务端是怎么一回事
2. 了解安装mysql的注意事项，以及回顾mysql个人
3. 简要介绍关于mysql启动的常见四个命令以及具体的作用
   1. mysqld
   2. mysqld_safe
   3. mysql.server
   4. mysqld_multi



# 认识客户端和服务端

​	由于是Mysql的专栏，这里就不牵扯上面TCP/IP，什么网络传输协议了，总之我们只需要了解mysql是分为客户端和服务端的，通常我们访问页面或者浏览数据就是一次数据库的访问过程（当然现在多数东西都静态化了），所以连接的这一方被称为客户端而接受请求的这一方面被称为服务端。

## mysql的基本任务

通常我们使用MYSQL基本都是干这些事情：

1. 连接数据库。
2. 查询数据库的数据，客户端发送请求给服务端，服务端根据命令找到数据回送给客户端。
3. 和数据库断开连接。



## mysql实例

​	说完了上面的废话之后，我们来说下mysql实例，实例也在操作系统的层面叫做进程，而进程可以看做是处理器，内存，IO设备的抽象，我们不需要知道这个进程底层是如何传输数据存储数据的，我们只需要了解他需要一个**端口**，并且每一个实例都有一个 **进程ID**的东西，在数据库实例运行的时候系统会分配一个进程ID给它并且保证唯一，而每一个进程都有自己的名字，这个名称是安装的时候由程序员自己设置的，但是如果没有分配则会使用MYSQL自己默认设置的名称。

> 我们启动的 MySQL **服务器进程的默认名称**为 **mysqld** ， 而我们**常用的 MySQL 客户端进程**的默认名称为 **mysql** 。
>
> 从这个名称我们也可以推测出为什么我们启动一个服务通常会使用Mysqld，而我们连接数据库通常使用mysql。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210801211525.png)

- 每一个文件就是对于IO设备的抽象
- 虚拟内存是对内存和IO设备的抽象
- 进程：则是对处理器，虚拟内存和IO设备的抽象



# 安装Mysql的注意事项

​	安装Mysql其实是一件十分简单但是实际上如果全手动安装细节还是比较多的，通常情况下我们自己使用直接用EXE程序或者直接使用BIN包等，但很多时候对于Linux的软件很多人都会推荐使用 **源码安装**，源码安装的好处不仅仅是缩小体积，经过不少的实验证明源码的安装方式效率会有所提升，所以正式环境下 **尽可能使用源码安装**，最后需要注意的一点是：**Linux下使用RPM包会有单独的服务器和客户端RPM包，需要分别安装**。



## 安装目录位置的区别

​	下面是具体的Mysql安装目录，当然下面这里只做参考，个人mac电脑使用的是`brew install mysql`加上m1的的芯片安装的，适配性未知，所以为了保证笔记的可靠，这里用回了windows系统来进行实际测试和演练，下面是不同的操作系统在mysql的安装目录存储位置存在细微的不同，**但是一定要十分清楚mysql真实的安装位置**，这对于自己捣鼓各种命令以及设置参数很重要。

```java
macOS 操作系统上的安装目录：
/usr/local/mysql/
Windows 操作系统上的安装目录：
C:\Program Files\MySQL\MySQL Server 5.7
```



# Mysql安装

## windows安装过程

​	安装过程就不演示了，网上的教程一抓一大把，为了稳妥起见这里个人使用的mysql版本是5.7的版本，同时使用了默认exe程序安装，如果你使用了**mysql-installxx.exe**安装，有的时候会出现下面的命令：

```
'mysql' 不是内部或外部命令，也不是可运行的程序
```

​	看到这个提示之后，第一反应是进入power shell的管理员模式：

```
PS C:\Windows\system32> mysql -uroot -p
mysql : 无法将“mysql”项识别为 cmdlet、函数、脚本文件或可运行程序的名称。请检查名称的拼写，如果包括路径，请确保路径正
确，然后再试一次。
所在位置 行:1 字符: 1
+ mysql -uroot -p
+ ~~~~~
    + CategoryInfo          : ObjectNotFound: (mysql:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException
```

​	发现还是报错，然后我跑去服务看了下mysql是否有启动，发现mysql又是启动的，这里有点奇怪。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211028215128.png)

​	这里找了下网络上的解决办法，其实加个环境变量就行了，然后使用power shell直接安装即可，最后我们照常输入命令就可以发现mysql正常安装完毕了：

```
PS C:\Windows\system32> mysql -uroot -pxxxxxx
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.35-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>


```

> 关于绝对路径和相对路径启动问题：
>
> 绝对路径：如果你的系统环境变量里面访问不到你的应用程序命令，这时候就需要进入到相关的目录执行命令，比如上面我没有配置环境变量就需要进入到`C:\Program Files\MySQL\MySQL Server 5.7\bin`目录下进行操作，也可以正常使用mysql，但是每次这样弄很麻烦，所以基本是个正常人都会使用环境变量，如果你不知道环境变量是什么，额。。。。请自行百度
>
> 相对路径：配置完环境变量之后，我们敲命令会根据系统环境变量配置的 **先后顺序**找到我们的命令并且执行，但是这点在mysql有点特别，后续会讲到如果多个系统参数配置会默认使用 **最后读到的配置参数为准**。

​	

## macos安装过程

​	Mac本子个人也是24分期才敢碰的神物，我相信用的人也不多，所以这里直接放个帖子：

​	https://www.cnblogs.com/nickchen121/p/11145123.html



## Linux安装过程

​	由于个人使用云服务器搭建mysql比较多，这里提供了一个阿里云rpm包的安装方式，版本是centeros7，centeros6同样可以使用，不过需要修改部分命令。

​	https://juejin.cn/post/6895255541544255496



# Mysql启动：

​	多数情况我们使用mysql.sever启动即可，因为它会间接的调用其他的几个命令，而mysqld_muti这个命令更建议自己实战的时候进行配置的学习使用，更加事半功倍。	

## mysqld

​	Mysqld：代表的是mysql的服务器程序，运行就可以启动一个服务器的进程，但是**不常用**。

​	个人在实践之后使用了mysqld命令之后，发现运行的结果如下，起初比较莫名其妙的问题，但是看日志不难发现问题，其实就是 **目录不存在**并且mysql又没法给你创建目录，只要使用**everything**找到对应点文件即可（mac为什么没有这么好用的软件，哎）。

​	你可以通过找到下面的`my.ini`文件并且修改里面关于**datadir**的路径即可。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211028222404.png)

​	通过打开这个文件发现配置路径里面有一个`/Data`，然后发现目录里面没有这路径:

```
# Path to the database root
datadir=C:/ProgramData/MySQL/MySQL Server 5.7/Data
```

​	下面是上面描述的日志的运行结果，感兴趣的可以自己试一试，也可能遇不到我这种问题

```
PS C:\Windows\system32> mysqld -datadir=D:\soft\mysqltest
mysqld: Can't change dir to 'C:\Program Files\MySQL\MySQL Server 5.7\data\' (Errcode: 2 - No such file or directory)
2021-10-28T14:20:14.063607Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2021-10-28T14:20:14.063669Z 0 [Note] --secure-file-priv is set to NULL. Operations related to importing and exporting data are disabled
2021-10-28T14:20:14.064027Z 0 [Note] C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqld.exe (mysqld 5.7.35) starting as process 3296 ...
2021-10-28T14:20:14.066088Z 0 [Warning] Can't create test file C:\Program Files\MySQL\MySQL Server 5.7\data\DESKTOP-L8AD9HM.lower-test
2021-10-28T14:20:14.066416Z 0 [Warning] Can't create test file C:\Program Files\MySQL\MySQL Server 5.7\data\DESKTOP-L8AD9HM.lower-test
2021-10-28T14:20:14.067090Z 0 [ERROR] failed to set datadir to C:\Program Files\MySQL\MySQL Server 5.7\data\
2021-10-28T14:20:14.067408Z 0 [ERROR] Aborting

2021-10-28T14:20:14.067619Z 0 [Note] Binlog end
2021-10-28T14:20:14.067904Z 0 [Note] C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqld.exe: Shutdown complete
```

​	最后你可以运行`mysqld`启动一个服务器进程并且在对应的目录下面构建了对应的文件。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211028223126.png)



> 答案的灵感来自于下面的部分：
>
> What I did (Windows 10) for a new installation:
>
> 1. Start cmd in admin mode (run as administrator by hitting windows key, typing cmd, right clicking on it and selecting "Run as Administrator"
>
> 2. Change into "MySQL Server X.Y" directory (for me the full path is C:\Program Files\MySQL\MySQL Server 5.7")
>
> 3. using notepad create a my.ini with a mysqld section that points at your data directory
>
>    ```sql
>    [mysqld]
>    datadir="X:\Your Directory Path and Name"
>    ```
>
> 4. created the directory identified in my.ini above.
>
> 5. change into bin Directory under server directory and execute: `mysqld --initialize`
>
> 6. Once complete, started the service and it came up fine.

## mysqld_safe

​	**mysqld_safe** 是一个启动脚本，在间接的调用**mysqld** ，同时**监控进程**，使用 mysqld_safe 启动服务器程序时，会通过监控把出错的内容和出错的信息重定向到一某个文件里面产生出错日志，这样可以方便我们找出发生错误的原因。

​	但是个人实践之后找不到，其实原因是**windows没有这个命令**的，关于更多mysqld_safe命令的解释可以看看mysql的官方网站：https://dev.mysql.com/doc/refman/5.7/en/mysqld-safe.html

> 如果阅读英文有困难，这里有一个中文的翻译网站：https://www.docs4dev.com/docs/zh/mysql/5.7/reference/preface.html

> 对于一些Linux 平台，使用 RPM 或 Debian 软件包安装的 MySQL 包括对 ManagementMySQL 服务器启动和关闭的系统支持。在这些平台上可能被认为没有必要所有没有安装[mysql.server](https://www.docs4dev.com/docs/zh/mysql/5.7/reference/mysql-server.html)和[mysqld_safe](https://www.docs4dev.com/docs/zh/mysql/5.7/reference/mysqld-safe.html)。



## mysql.server

​	这个文件同样也是一个启动脚本，也是最常用的脚本，实际上这个命令可以看做是一个链接，也就是一个“快捷方式”，实际指向的路径为： `../support-files/mysql.server`，另外这个**命令会间接的调用mysqld_safe**，我们使用下面的命令就可以直接启动服务：

```
mysql.server start
```

> 如果操作系统在安装之后没有构建相应的链接文件，可能需要自己手动构建一个链接文件，另外，linux服务器需要注意权限的问题，因为有时候没有root权限可能需要对于对应的目录配置用户组，下马是关于官网的介绍
>
> 如果从源分发版或使用不自动安装[**mysql.server**](https://dev.mysql.com/doc/refman/5.7/en/mysql-server.html)的二进制分发版格式安装 MySQL，则 可以手动安装脚本。它可以 `support-files`在 MySQL 安装目录下的目录或 MySQL 源代码树中找到。将脚本复制到`/etc/init.d`名为[**mysql**](https://dev.mysql.com/doc/refman/5.7/en/mysql.html)的目录并使其可执行：
>
> ```shell
> shell> cp mysql.server /etc/init.d/mysql
> shell> chmod +x /etc/init.d/mysql
> ```

​	最后启动和关闭mysql可以使用如下的方式（linux系统）：

```MYSQL
mysql.server start
mysql.server stop
```

​	如果是windows系统，使用上面的命令会报错，所以我们使用下面的命令即可：

```mysql
PS C:\Windows\system32> mysql.server start
mysql.server : 无法将“mysql.server”项识别为 cmdlet、函数、脚本文件或可运行程序的名称。请检查名称的拼写，如果包括路径
，请确保路径正确，然后再试一次。
所在位置 行:1 字符: 1
+ mysql.server start
+ ~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (mysql.server:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException

PS C:\Windows\system32> net start mysql
服务名无效。

请键入 NET HELPMSG 2185 以获得更多的帮助。

PS C:\Windows\system32> net start mysql57
请求的服务已经启动。
```

## mysqld_multi

​	有的时候我们可能会想要在一台的机器上使用多个服务器的进程，这个命令的作用是对于每一个服务器进程进行启动或者停止监控，但是由于这个命令较为复杂，个人还是建议使用上面的官方稳定链接进行具体的细节了解。

> 如果阅读英文有困难，这里有一个中文的翻译网站：https://www.docs4dev.com/docs/zh/mysql/5.7/reference/preface.html



## window&服务启动

​	这个简单了解一下即可，window端的mysql基本是为了照顾windows的用户才出现的，真正能施展拳脚的地方还是linux，当然有些公司确实会使用window作为服务器。。。。。所以还是过一下，下面是安装一个windows的服务的命令：

```
"完整的可执行文件路径" --install [-manual] [服务名]
```

> 其中的 -manual 可以省略，区别在于加上会关闭 **自动启动**改为**手动启动**

​	最后下面是个人的mysqld服务安装命令，请读者根据自己的系统环境自行安装即可。

```
C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqld --install
```

​	安装之后使用`net start mysql`和`net stop mysql`命令即可启动或者关闭。



# Mysql连接

​	这里只有一个需要注意一下的点那就是对于命令格式来说，如果使用-u、-p等参数的时候使用一个短划线，但是如果使用--username、--password等要使用双划线的形式。



# 总结

​	本节内容非常简单，介绍了关于mysql的安装过程的踩坑和四个常见的启动命令，其实我们重点只需要掌握一个命令即可，同时对于部分命令更加建议自己使用的时候边学边记录可以更好的消化和吸收。

​	以上就是笔者边学习边踩坑的记录，最后发现最好的教程还是官方文档，另外遇到问题也不要慌，先在自己脑海中大胆的猜测问题点，进行验证之后反复重试，踩坑多了之后自然会熟悉。



# 写在最后

​	算了对于专栏的重新编写，后续会对之前的学习内容做一个复盘和总结。

