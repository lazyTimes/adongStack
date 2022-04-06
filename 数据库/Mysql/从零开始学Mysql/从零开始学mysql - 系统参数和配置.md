

# 从零开始学mysql - 系统参数和配置

# 前言

​	本节我们来讲述关于MYSQL的系统启动命令相关内容，也是比较基础但是可能有些人会很模糊的内容，本节的核心也是讲述配置有关的内容

# 思维导图

导图地址：https://www.mubucm.com/doc/7DDOY0CuMK5

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211119001340.png)

​	

# 概述

​	下面是对于本文的简单提要：

1. ，命令行的命令格式
   1. 单划线和双划线
2. 配置文件
   1. 配置文件读取顺序
      1. window，mac，Linux的配置读取顺序对比
   2. 配置文件的内容
   3. 特定版本配置
   4. 配置文件优先级
      1. 多配置文件和单文件配置的读书特性：总是以最后为准
   5. 自定义配置读取：通常为命令行指定读取
3. 系统变量的配置
   1. 查看系统变量
   2. 设置系统变量
   3. 运行时的系统变量
      1. 作用范围：全局变量和会话变量
      2. 全局变量和会话变量设置
      3. 查看系统变量的范围
   4. 系统变量的注意事项
   5. 启动选项和系统变量的区别
   6. 状态变量的补充
      1. 如何查看状态变量





# 命令行命格式

## 单划线和双划线命令格式

​	命令行命令就是我们通常连接mysql使用的命令，命令行的命令一般分为两种，首先是双划线的命令，比如使用`mysqld --skip-networing` 就可以禁止客户端连接，这种命令也被称之为长命令，使用命令的时候需要使用`--`两个短划线进行拼接，另一种是更为常用的命令`-h`，`-p`等命令， 这样的命令只需要一个短划线即可（为--host，--port的命令简称）。

> 命令的另一种写法是使用**下划线**进行替代，--skip_networing。

​	单划线命令效果如下，服务端开启禁止客户端登陆之后使用客户端连接就不允许了：

```
mysql -h127.0.0.1 -uroot -p
    Enter password:
ERROR 2003 (HY000): Can't connect to MySQL server on '127.0.0.1' (61)
```

​	另外一个案例是服务端启动的默认创建表引擎，比如我们需要改为InnoDB引擎在使用命令的时候加上`--default-storage-engine=InnoDB`选项，最后只要在任意的数据库下创建一张表，在末尾可以发现表的的存储引擎变了，当然默认的存储引擎看不到效果，可以使用`MyISAM`进行验证：

```
ENGINE=MyISAM DEFAULT CHARSET=utf8
```

​	mysql的默认安装之后启动会自动附加一些参数，比如下面的命令，这里有个命令的重要使用规则是不要把变量声明的习惯带进来，**在命令的=（等号）两边增加空格是不被允许的**：

```mysql
/usr/local/mysql/bin/mysqld --user=_mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --plugin-dir=/usr/local/mysql/lib/plugin --log-error=/usr/local/mysql/data/mysqld.local.err --pid-file=/usr/local/mysql/data/mysqld.local.pid --keyring-file-data=/usr/local/mysql/keyring/keyring --early-plugin-load=keyring_file=keyring_file.so
```

​	最后如果不清楚如何使用命令，直接使用`--help`，不过只有一个`mysqld`的比较特殊，他需要使用`--verbose --help`才行，记不住也没关系，在`--help`的命令最后mysql会给我们进行提示，还是比较贴心的（不过我觉得大多数人还是会使用度娘查命令，哈哈。）

```
For more help options (several pages), use mysqld --verbose --help.
```



# 配置文件

​	虽然命令的方式十分的方便，在启动的时候也有较高的自由度，但是这种方式用的其实并不是很多，实际工作使用配置文件的形式会更多，配件文件的形式是更为常用的也是更容易记忆的方式，但是在了解配置文件之前，我们需要大致了解配置文件的**读取顺序**。当然不需要牢固的记忆，只要作为了解即可。

## 配置文件的读取顺序

### Window的配置文件读取顺序

​	Windows不是使用MySQL的重点，但是作为自我练习的时候还是需要了解的，他的配置读取顺序如下。

1. %WINDIR%\my.ini %windir\my.cnf% （echo %WINDIR%获取）
2. C:\my.ini C:\my.cnf
3. Basdir\my.ini basdir\my.cnf（based it指的是默认的安装路径）
4. Defaults-extra-file 命令行制定的额外配置文件路径
5. %appdata%\MySQL\ .mylogin.cnf 登陆路径选项（客户端指定，通过echo %APPDATA%可以获取）

​	上面第一条出现`.ini`和`.cnf`意味着支持多种后缀文件格式，`%windir% `表示为windows的目录位置，通常是`C:\windows`。另外最后两个配置有点特别，第四个指的是可以利用命令参数：`—defaults-extra-file=C:\xxxx\xxx\xxx.txt`这样的方式指定要读取的配置文件，而最后一个`%appdata%`指的是windows对应应用程序目录值，另外这个.**mylogin.cnf**（注意前面的小数点） 这个文件不是和前面一样类似的纯文本，而是使用**mysql_config_editor** 使用程序的加密文件，文件也只能固定为mysql规定的一些配置信息。（这些配置这里借用官网查看一下）

> Mysql_config_editor 这个编辑器是mysql官方开发的一个可执行的文件。具体的参数配置可以参考官方的配置进行处理。



### 类Unix的配置读取

​	废话不多说，我们来看下类Unix的系统读取配置，这个配置不同于window需要仔细对待，当然最好能时常回顾，因为Linux上使用mysql的场景会比较多。

1. /etc/MySQL/my.inf
2. SYSCONFIGDIR/my.cnf （MySQL的系统安装目录）
3. %MYSQL_HOME%/my.cnf 仅限服务器的选项
4. Defaults_extra-file 同样为命令行指定读取
5. ~/.my.cnf （注意前面的逗号）
6. ~/.mylogin.cnf 需要**mysql_config_editor** 的支持并不是纯文本文件

​	SYSCONFDIR 表示在使用 CMake 构建 MySQL 时使用SYSCONFDIR 选项指定的目录，默认的情况下为`/etc`的下面。

​	mysql_home 相信了解环境变量这个概念的都比较熟悉，可以自由选择设置还是不设置，我们可以在配置的环境变量下放置一个my.cnf，但是如果放置之后，内容就不能乱写了，只能放置**关于启动服务器程序的相关选项（意味着客户端和服务端端配置可以共存）**，这里再次强调和` .mylogin.cnf `文件还是有差别，他的限制更加严格（再次啰嗦注意前面的小数点）。

> 补充：Mysql.server 会间接调用mysqld_safe 这个命令，而mysqld_safe 的命令会使用mysqld命令，最后mysqld 安装规则当然也会按照规则配置文件，说了这么多结果就是：**mysql.server如果发现环境变量配置了my.cnf文件也会进行配置文件的应用**。

​	～是属于类unix系统的特殊符号，代表 **当前用户登陆的根路径**，比如mac下面通常为`/User/用户名`，通常可以使用home的环境变量查看，由于是每一个用户都存在一个目录，所以最后两个配置的读取顺序其实都是根据不同登陆用户判断的，所以可以在这个目录下面构建这两个“专属”文件。

​	Defaults-extra-file 指定为：`—defaults-extra-file=C:\xxxx\xxx\xxx.txt`这样的方式指定要读取的配置文件，和windows的方式一致，因为

​	`.mylogin.cnf` 含义和window中也是一样的，需要**mysql_config_editor** 的支持并不是纯文本文件，也不能随意的更改。

### mac系统配置读取

​	mac系统的配置读取需要一定的获取技巧，可以使用**mysql -verbose --help | grep my.cnf** 这个命令来获取，可以看到下面的路径和上面讲述的路径大致逻辑是一致的。

```
./mysql --verbose --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf 
```

​	但是个人实际寻找的时候发现 **没有任何**的配置文件，根据网上的资料发现需要去`/usr/local/supporting-file`下面有一个配置文件的模版，但是个人实际操作之后发现这个文件还是不存在的，最后不得已只能去官网拷贝一份配置文件然后按照上面的打印的规则放到指定的目录去了.....

## 配置文件内容

​	了解完配置文件的基本读取顺序之后，下面我们来了解配置文件的内容，这里说一下小插曲，mac的配置文件在`/usr/local/mysql`中无法发现配置文件，所以这里只好拿官方的样例文件进行解释，为了防止篇幅过长，这里放到了文章的最后部分，从配置文件中首先我们可以看到很多的配置分组，比如如下的形式：

```mysql
[server] (具体的启动选项...)
[mysqld] (具体的启动选项...)
[mysqld_safe] (具体的启动选项...)
[client] (具体的启动选项...)
[mysql] (具体的启动选项...)
[mysqladmin] (具体的启动选项...)
```

​	通过这样的分组之后，可以在不同的分组下可以配置，根据分组的配置项我们又可以分为两种，一种是：`选项`另一种是`选项=选项值`，需要注意的是在配置文件中不能编写`h=127.0.0.1`短链接形式而是全部只能使用 **长形式**的配置方式，同时配置文件和命令行不同的是允许中间加入空格的，比如`slow_query_log    = 0`，另外我们可以使用`#`符号进行注释，比如`#xxxx`，最后我们再来看下一下命令行的形式：`--option`和`--option=optionvalue`。

​	分组的意义在于可以将客户端的命令和服务端的命令进行区分，比如下面的不同分组我们可以清晰配置变量的作用范围，也可能更好的规划我们的服务器启动参数或者客户端的连接参数。

```
[server] 组下边的启动选项将作用于所有的服务器程序。 
[client] 组下边的启动选项将作用于所有的客户端程序
```

​	需要注意的是`mysql_safe`和`mysql.server`基本都会间接调用`mysqld`命令，从命令的读取范围我们也可以了解到为什么建议使用mysql.server或者mysql.safe这两个命令，同时也可以发现mysql的客户端命令只能读取mysql下面的命令以及client下面的命令，通过下面的图表可以发现我们基本上只需要学习两个比较常用的命令`mysqld_safe`和`mysql.server`的读取范围即可。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211111133014.png)

> Mysql.server 命令本身就是设计为针对配置文件使用，所以他最终支持的命令行的命令仅仅为 `start`和`stop`

## 特定版本的配置

​	mysql的配置文件支持根据版本号的方式读取配置，比如8.0我们可以配置**[mysqld-8.0]**，而5.7我们就可以使用**[mysqld-5.7]**，他们本身的作用是一致的，但是会根据当前的mysql版本匹配进行生效。

## 配置文件的优先级

​	总结起来就是两句话，如下记忆即可：

+ **多个文件s以文件的读取顺序中最后的读取的为最终结果**
+ **单文件重复分组按照最后一个组中出现的配置为主**

### 多配置文件的读取

​	通常情况下除非我们在mysql连接的时候使用指定的配置文件读取路径，否则我们通常使用上面介绍过的配置文件的读取顺序进行读取，这时候有可能出现一种情况就是多个配置文件下出现相同的配置到底应该应用哪一个配置？这里只要记住一条铁律就是**最后的读取的为最终结果**。

### 单文件重复配置读取

​	单文件读取的优先级使用的是，按照 **最后一个组中出现的配置为主**，比如说出现过下面的参数配置，会按照MyISAM的配置进行读取。

```mysql
[server]
    default-storage-engine=InnoDB
    [mysqld]
    default-storage-engine=MyISAM
```

## 自定义指定配置读取

​	如果你不想记忆那些默认的搜索规则，或者为了保证配置按照自己的想法进行读取，可以使用`mysqld --defaults-file=/tmp/myconfig.txt`的命令方式指定你需要读取的配置文件路径，但是需要注意`--defaults-file`和`defaults-extra-file `这两个命令是有区别的，`defaults-extra-file `可以指定额外的路径而`--defaults-file` 只能指定一个配置路径。

> 补充：如果遇到配置文件和命令行出现相同的配置，最后无论配置文件如何进行配置， **一切按照命令行的配置为主**。



# 系统变量配置

​	默认情况下如果我们没有进行任何配置，mysql会默认给我们分配一个配置，比如最大连接数，错误连接次数，或者查询的缓存大小等等变量的配置等，如果我们想要了解当前的配置变量，我们可以使用如下的命令进行查看。

## 查看系统变量

```mysql
SHOW VARIABLES [LIKE 匹配的模式];
```

​	比如我们按照下面的命令进行运行查看，可以看到数量有几百条，一个个看是看不过来的，所以我们进行系统变量配置的时候会使用某一个大分类下的具体配置进行查看（下面使用了通配符的写法）：

```mysql
mysql> show variables like '%%';
+----------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name                                            | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
+----------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| activate_all_roles_on_login                              | OFF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| admin_address                                            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| admin_port                                               | 33062                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| admin_ssl_ca                                             |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| admin_ssl_capath                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| admin_ssl_cert                                           |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| admin_ssl_cipher                                         |          
....
| windowing_use_high_precision                             | ON                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
+----------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
638 rows in set (0.01 sec)
```

​	比如我们想查看当前mysqld服务的默认存储引擎可以使用如下的命令，这时候就会只显示一条数据，感兴趣的读者也可以试一试在连接mysql服务之后执行`SHOW VARIABLES like 'max_connections';`命令查看效果：

```mysql

mysql> SHOW VARIABLES LIKE 'default_storage_engine';
+------------------------+--------+
| Variable_name          | Value  |
+------------------------+--------+
| default_storage_engine | InnoDB |
+------------------------+--------+
1 row in set (0.00 sec)
```

​	另外在mysql中想要模糊的查看某一个项目的配置，可以使用百分号%进行通配符搜索，比如下面这样：

```mysql
mysql> show variables like 'mysql%';
+---------------------------------------------+----------------------------------------+
| Variable_name                               | Value                                  |
+---------------------------------------------+----------------------------------------+
| mysql_native_password_proxy_users           | OFF                                    |
| mysqlx_bind_address                         | *                                      |
| mysqlx_compression_algorithms               | DEFLATE_STREAM,LZ4_MESSAGE,ZSTD_STREAM |
| mysqlx_connect_timeout                      | 30                                     |
| mysqlx_deflate_default_compression_level    | 3                                      |
| mysqlx_deflate_max_client_compression_level | 5                                      |
| mysqlx_document_id_unique_prefix            | 0                                      |
| mysqlx_enable_hello_notice                  | ON                                     |
| mysqlx_idle_worker_thread_timeout           | 60                                     |
| mysqlx_interactive_timeout                  | 28800                                  |
| mysqlx_lz4_default_compression_level        | 2                                      |
| mysqlx_lz4_max_client_compression_level     | 8                                      |
| mysqlx_max_allowed_packet                   | 67108864                               |
| mysqlx_max_connections                      | 100                                    |
| mysqlx_min_worker_threads                   | 2                                      |
| mysqlx_port                                 | 33060                                  |
| mysqlx_port_open_timeout                    | 0                                      |
| mysqlx_read_timeout                         | 30                                     |
| mysqlx_socket                               | /tmp/mysqlx.sock                       |
| mysqlx_ssl_ca                               |                                        |
| mysqlx_ssl_capath                           |                                        |
| mysqlx_ssl_cert                             |                                        |
| mysqlx_ssl_cipher                           |                                        |
| mysqlx_ssl_crl                              |                                        |
| mysqlx_ssl_crlpath                          |                                        |
| mysqlx_ssl_key                              |                                        |
| mysqlx_wait_timeout                         | 28800                                  |
| mysqlx_write_timeout                        | 60                                     |
| mysqlx_zstd_default_compression_level       | 3                                      |
| mysqlx_zstd_max_client_compression_level    | 11                                     |
+---------------------------------------------+----------------------------------------+
30 rows in set (0.00 sec)
```

## 设置系统变量

​	我们了解了如何查看系统变量之后，下面我们来学习如何进行系统变量的设置，其实我们在之前已经讲述过如何设置系统变量，比如我们在读取配置文件的时候使用`--default-file=xxx`的方式自定义读取配置文件的位置，又或者在配置文件里面制定配置然后在启动mysqld服务器进行读取相关的配置，比如上面提到的`default-storage-engine=MyISAM`，所以配置选项有下面的两种：

+ 通过命令行启动选项
+ 通过配置文件启动选项

​	所以设置系统变量也没有什么特别的，无非就是这两种方式罢了。

> 补充：**对于启动选项来说，如果启动选项名由多个单词组成，各个单词之间用短划线 - 或者下划线 _ 连接起来都可 以，但是对应的系统变量之间必须使用下划线 _ 连接起来**

## 运行时的系统变量

​	mysql的系统变量的特性是：**对于多数的系统变量都是可以在服务器程序运行的时候动态修改**，但是很多时候我们对于运行时的变量修改这个概念十分模糊，到底什么时候修改变量时临时的，什么时候又是全局生效的，这里需要好好来唠叨一下。针对一次客户端端连接我们会有下面的情况：客户端A使用配置1，而客户端B使用配置2但是我们并不想他们私有更改系统的固定配置，这样肯定是不行的，另一种情况是我们想要每一个客户端连接的时候想要可以使用一一些自定义的配置要如何处理？根据上面的描述，我们可以看到系统变量运行时候的配置出现的下面两个问题：

+ 连接时的系统变量配置
+ 公有参数的私有化问题

​	为了解决这两个问题，mysql设计了“作用范围”的方式来区分运行时的系统变量和全局的系统变量。

### 作用范围

​	根据mysql的规则定义，他将变量分为下面两种：

+ GLOBAL :全局变量，影响服务器的整体操作。

+ SESSION :会话变量，影响**某个客户端连接**的操作。(注: SESSION 有个别名叫 LOCAL（本次连接变量或者当前变量，**不是本地变量哦**）)

​	服务器启动的时候，他会将所有连接当前服务端程序的客户端默认的变量配置为GLOBAL的全局变量的配置，也就是说每一个客户端连接的时候都会**继承**一份GLOBAL全局变量为 **SESSION**的会话变量进行使用，比如我们通过`mysqld`命令进行设置的变量都是`GLOABL`全局变量，因为这时候服务器还在启动不可能会有会话变量的存在，而使用`mysql`命令进行连接才有可能会出现会话变量的调整。

> 补充：特别强调会话变量的作用范围仅仅限制于一次客户端的连接，当建立一次新的客户端连接的时候又会接着按照继承全局变量的方式重新读取（前提是你的新客户端没有对与配置进行修改），所以需要十分小心当前变量的作用范围

​	最后，为了防止你头晕，这里我们只需要进行如下的记忆:

​	Mysqld：服务端启动的相关配置都是全局的变量

​	Mysql：客户端连接的命令产生的配置，连接前的命令行使用会话变量，在连接时可以进行相关命令操作把全局变量变为临时变量。

### 全局变量和会话变量的设置

​	设置系统变量一般有下面两种方法，

```mysql
SET [GLOBAL|SESSION] 系统变量名 = 值;
SET [@@(GLOBAL|SESSION).]var_name = XXX;
```

​	比如如果我们想要设置服务端端全局变量的参数：

```mysql
SET GLOBAL default_storage_engine = MyISAM; 
SET @@GLOBAL.default_storage_engine = MyISAM;
```

​	下面是客户端进行连接的时候，我们可以使用SESSION的变量设置方法设置当前的参数和变量参数。

```mysql
SET SESSION default_storage_engine = MyISAM; 
SET @@SESSION.default_storage_engine = MyISAM; 
SET default_storage_engine = MyISAM;
```

### 查看系统变量的作用范围

​	既然引入了变量的作用范围，那么我们最开始提到的关于系统变量的作用范围，**查看的是全局变量还是当前变量？**仔细思考其实不难理解，答案是：**默认查看的是 SESSION 作用范围的系统变量**，既然默认看当前的变量值，当然我们也可以在查看系统变量的语句上加上要查看哪个 作用范围 的系统变量，就像这样：

​	`SHOW [GLOBAL|SESSION] VARIABLES [LIKE 匹配的模式];`

​	下面是关于部分操作的演示，当然也可以进个个人的试验：

```mysql
SHOW SESSION VARIABLES LIKE 'default_storage_engine';
SHOW GLOBAL VARIABLES LIKE 'default_storage_engine';
SET SESSION default_storage_engine = MyISAM;
SHOW SESSION VARIABLES LIKE 'default_storage_engine';
```

​	由于篇幅有限这里就不展示运行结果了，相信看到语法之后也可以很快的理解含义。

> 补充：值得注意的是SESSION的变量只会针对设置了变量之后的后续的客户端连接的值，而不会修改之前已经进行连接的客户端的参数，并且我们可以发现修改某个客户端的连接当前配置，并不会影响GLOBAL全局变量的设置。



## 系统变量注意事项

+ 并不是所有系统变量都具有 GLOBAL 和 SESSION 的作用范围。
  + 有一些系统变量只具有 GLOBAL 作用范围，比方说 max_connections 。
  + 有一些系统变量只具有 SESSION 作用范围，比如 insert_id。
  + 有一些系统变量的值既具有 GLOBAL 作用范围，也具有 SESSION 作用范围，比如我们前边用到的 default_storage_engine。
+ 有些系统变量是只读的，并不能设置值。
  + 比方说 version ，**表示当前 MySQL 的版本**。修改即没有意义，也不能修改。

## 启动选项和系统变量的区别

​	启动选项可以看作是我们启动变量的时候使用`--`(双划线)或者`-`(单划线)进行设置的系统变量启动参数，并且大部分的系统变量都是可以使用系统变量参数进行设置的，所以对于系统变量和启动选项有如下的区别：

+  大部分系统变量可以使用启动选项的方式设置
+ 部分系统变量是启动启动的时候生成，无法作为启动选项（比如：` character_set_client`）
+ 有些启动选项也不是系统变量，比如 `defaults-file`

## 状态变量

​	服务器也不全是系统变量，为了反应系统的性能，会存在诸如状态变量的参数，比如手当前连接的线程数量，以及连接的错误次数等等，**由于这些参数反应的是服务器自身的运行情况，所以不能由程序员设置，而是需要依靠应用程序设置**。

### 查看状态变量

​	这里可能会好奇为什么状态变量也存在全局和当前变量的参数区别？这里不要被误导了，上面说明的是可以由应用程序设置，也就意味着会存在多个客户端访问的情况，所以也需要考虑区别全局和当前的情况，最后查看状态变量的命令如下：

```mysql
SHOW [GLOBAL|SESSION] STATUS [LIKE 匹配的模式];
```

​	下面是一个实际的操作案例：

```mysql
mysql> SHOW STATUS LIKE 'thread%';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| Threads_cached    | 0     |
| Threads_connected | 1     |
| Threads_created   | 1     |
| Threads_running   | 2     |
+-------------------+-------+
4 rows in set (0.01 sec)
```

​	可以看到所有和thread相关的变量都进行了展示。



# 总结

​	本节我们从命令行的格式基础开始，介绍了mysql如何进行配置的读取的，以及在读取配置的时候需要注意哪下情况，这里面的细节还是比较多的，并且操作系统的不同会存在读取顺序的不同，但是基本只需要重点记忆和 **Linux **有关的参数即可。

​	



# 写在最后

​	写下来发现写的内容挺多的，需要多回顾和总结才能慢慢消化。



# 补充资料

## My.ini配置文件模板（5.7）

[My.ini配置模板获取网站配置文件](https://www.fromdual.com/sites/default/files/my.cnf)



如果觉得内容不明不白的，可以去官方的介绍页面进行了解，地址如下：

https://www.fromdual.com/mysql-configuration-file-sample

![配置文件后去](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211110135742.png)

当然最后如果懒得访问网页的，这里也直接从网页吧模板拷贝过来了。

```mysql
#
# FromDual configuration file template for MySQL, Galera Cluster, MariaDB and Percona Server
# Location: %MYCNF%
# This template is intended to work with MySQL 5.7 and newer and MariaDB 10.3 and newer
# Get most recent updated from here:
# https://www.fromdual.com/mysql-configuration-file-sample
#

[client]

port                           = %PORT%                              # default 3306
socket                         = %SOCKET%                            # Use mysqld.sock on Ubuntu, conflicts with AppArmor otherwise


[mysql]

no_auto_rehash
max_allowed_packet             = 16M
prompt                         = '\u@\h [\d]> '                      # 'user@host [schema]> '
default_character_set          = utf8                                # Possibly this setting is correct for most recent Linux systems


[mysqldump]

max_allowed_packet             = 16M


[mysqld]

# Connection and Thread variables

port                           = %PORT%                                # default 3306
socket                         = %SOCKET%                              # Use mysqld.sock on Ubuntu, conflicts with AppArmor otherwise
basedir                        = %BASEDIR%
datadir                        = %DATADIR%
# tmpdir                         = '%INSTANCEDIR%/tmp'

max_allowed_packet             = 16M
default_storage_engine         = InnoDB
# explicit_defaults_for_timestamp = 1                                  # MySQL 5.6 ff. default in MySQL 8.0, test carefully! This can have an impact on application.
# disable_partition_engine_check  = true                               # Since MySQL 5.7.17 to 5.7.20. To get rid of nasty message in error log

# character_set_server           = utf8mb4                             # For modern applications, default in MySQL 8.0
# collation_server               = utf8mb4_general_ci


max_connections                = 151                                 # Values < 1000 are typically good
max_user_connections           = 145                                 # Limit one specific user/application
thread_cache_size              = 151                                 # Up to max_connections makes sense


# Query Cache (does not exist in MySQL 8.0 any more!)

# query_cache_type               = 1                                   # Set to 0 to avoid global QC Mutex, removed in MySQL 8.0
# query_cache_size               = 32M                                 # Avoid too big (> 128M) QC because of QC clean-up lock!, removed in MySQL 8.0


# Session variables

sort_buffer_size               = 2M                                  # Could be too big for many small sorts
tmp_table_size                 = 32M                                 # Make sure your temporary results do NOT contain BLOB/TEXT attributes

read_buffer_size               = 128k                                # Resist to change this parameter if you do not know what you are doing
read_rnd_buffer_size           = 256k                                # Resist to change this parameter if you do not know what you are doing
join_buffer_size               = 128k                                # Resist to change this parameter if you do not know what you are doing


# Other buffers and caches

table_definition_cache         = 1400                                # As big as many tables you have
table_open_cache               = 2000                                # connections x tables/connection (~2)
table_open_cache_instances     = 16                                  # New default in 5.7


# MySQL error log

log_error                      = %INSTANCEDIR%/log/%UNAME%_%INSTANCE%_error.log   # Adjust AppArmor configuration: /etc/apparmor.d/local/usr.sbin.mysqld
# log_timestamps                 = SYSTEM                              # MySQL 5.7, equivalent to old behaviour
# log_warnings                   = 2                                   # MariaDB equivalent to log_error_verbosity = 3, MySQL does NOT support this any more!
# log_error_verbosity            = 3                                   # MySQL 5.7 ff., equivalent to log_warnings = 2, MariaDB does NOT support this!
innodb_print_all_deadlocks     = 1
# wsrep_log_conflicts            = 1                                   # for Galera only!


# Slow Query Log

slow_query_log_file            = %INSTANCEDIR%/log/%UNAME%_%INSTANCE%_slow.log   # Adjust AppArmor configuration: /etc/apparmor.d/local/usr.sbin.mysqld
slow_query_log                 = 0
log_queries_not_using_indexes  = 0                                   # Interesting on developer systems!
long_query_time                = 0.5
min_examined_row_limit         = 100


# General Query Log

general_log_file               = %INSTANCEDIR%/log/%UNAME%_%INSTANCE%_general.log   # Adjust AppArmor configuration: /etc/apparmor.d/local/usr.sbin.mysqld
general_log                    = 0


# Performance Schema

# performance_schema             = ON                                  # for MariaDB 10 releases
performance_schema_consumer_events_statements_history_long = ON      # MySQL 5.6/MariaDB 10 and newer


# Binary logging and Replication

server_id                      = %SERVERID%                            # Must be set on MySQL 5.7 and newer if binary log is enabled!
log_bin                        = %INSTANCEDIR%/binlog/%UNAME%_%INSTANCE%_binlog            # Locate outside of datadir, adjust AppArmor configuration: /etc/apparmor.d/local/usr.sbin.mysqld
# master_verify_checksum         = ON                                  # MySQL 5.6 / MariaDB 10.2
# binlog_cache_size              = 1M                                    # For each connection!
# binlog_stmt_cache_size         = 1M                                    # For each connection!
max_binlog_size                = 128M                                # Make bigger for high traffic to reduce number of files
sync_binlog                    = 1                                   # Set to 0 or higher to get better write performance, default since MySQL 5.7
expire_logs_days               = 5                                   # We will survive Easter holidays
# binlog_expire_logs_seconds     = 432000                              # MySQL 8.0, 5 days * 86400 seconds
binlog_format                  = ROW                                 # Use MIXED if you want to experience some troubles, default since MySQL 5.7, MariaDB default is MIXED
# binlog_row_image               = MINIMAL                             # Since 5.6, MariaDB 10.1
# auto_increment_increment       = 2                                   # For Master/Master set-ups use 2 for both nodes
# auto_increment_offset          = 1                                   # For Master/Master set-ups use 1 and 2


# Slave variables

log_slave_updates              = 1                                   # Use if Slave is used for Backup and PiTR, default since MySQL 8.0
read_only                      = 0                                   # Set to 1 to prevent writes on Slave
# super_read_only                = 0                                   # Set to 1 to prevent writes on Slave for users with SUPER privilege. Since 5.7, not in MariaDB
# skip_slave_start               = 1                                   # To avoid start of Slave thread
# relay_log                      = %UNAME%_%INSTANCE%_relay-bin
# relay_log_info_repository      = TABLE                               # MySQL 5.6, default since MySQL 8.0, MySQL only
# master_info_repository         = TABLE                               # MySQL 5.6, default since MySQL 8.0, MySQL only
# slave_load_tmpdir              = '%INSTANCEDIR%/tmp'                 # defaults to tmpdir


# Crash-safe replication Master

# binlog_checksum                = CRC32                               # default
# sync_binlog                    = 1                                   # default since 5.7.6, but slow!
# innodb_support_xa              = 1                                   # default, depracted since 5.7.10


# Crash-safe replication Slave

# relay_log_info_repository      = TABLE                               # MySQL 5.6, default since MySQL 8.0, MySQL only
# master_info_repository         = TABLE                               # MySQL 5.6, default since MySQL 8.0, MySQL only
# relay_log_recovery             = 1
# sync_relay_log_info            = 1                                   # default 10000
# relay_log_purge                = 1                                   # default
# slave_sql_verify_checksum      = 1                                   # default


# GTID replication

# gtid_mode                        = ON                                  # MySQL only, Master and Slave
# enforce_gtid_consistency         = 1                                   # MySQL only, Master and Slave

# log_bin                          = %INSTANCEDIR%/binlog/%UNAME%_%INSTANCE%_binlog   # In 5.6 also on Slave
# log_slave_updates                = 1                                   # In 5.6 also on Slave


# Security variables

# local_infile                   = 0                                   # If you are security aware
# secure_auth                    = 1                                   # If you are security aware
# sql_mode                       = TRADITIONAL,ONLY_FULL_GROUP_BY,NO_ENGINE_SUBSTITUTION,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO   # Be careful changing this afterwards, NO_AUTO_CREATE_USER does NOT exist any more in MySQL 8.0
# skip_name_resolve              = 0                                   # Set to 1 if you do not trust your DNS or experience problems
# secure_file_priv               = '%INSTANCEDIR%/tmp'                   # chmod 750, adjust AppArmor configuration: /etc/apparmor.d/local/usr.sbin.mysqld


# MyISAM variables

key_buffer_size                = 8M                                  # Set to 25 - 33 % of RAM if you still use MyISAM
myisam_recover_options         = 'BACKUP,FORCE'
# disabled_storage_engines       = 'MyISAM,MEMORY'                     # MySQL 5.7, do NOT during/before mysql_upgrade, good for Galera!


# MEMORY variables

max_heap_table_size            = 64M                                 # Should be greater or equal to tmp_table_size


# InnoDB variables

innodb_strict_mode             = ON                                  # Default since MySQL 5.7, and MariaDB 10.4
innodb_buffer_pool_size        = 128M                                # Go up to 75% of your available RAM
innodb_buffer_pool_instances   = 8                                   # Bigger if huge InnoDB Buffer Pool or high concurrency

innodb_file_per_table          = 1                                   # Is the recommended way nowadays
# innodb_flush_method            = O_DIRECT                            # O_DIRECT is sometimes better for direct attached storage
# innodb_write_io_threads        = 8                                   # If you have a strong I/O system or SSD
# innodb_read_io_threads         = 8                                   # If you have a strong I/O system or SSD
# innodb_io_capacity             = 1000                                # If you have a strong I/O system or SSD

innodb_flush_log_at_trx_commit = 2                                   # 1 for durability, 0 or 2 for performance
innodb_log_buffer_size         = 16M                                 # Bigger if innodb_flush_log_at_trx_commit = 0
innodb_log_file_size           = 256M                                # Bigger means more write throughput but longer recovery time

                                                                     # Since MariaDB 10.0 and MySQL 5.6
innodb_monitor_enable = all                                          # Overhead < 1% according to PeterZ/Percona


# Galera specific MySQL parameter

# default_storage_engine         = InnoDB                            # Galera only works with InnoDB
# innodb_flush_log_at_trx_commit = 2                                 # Durability is achieved by committing to the Group
# innodb_autoinc_lock_mode       = 2                                 # For parallel applying
# binlog_format                  = row                               # Galera only works with RBR
# query_cache_type               = 0                                 # Use QC with Galera only in a Master/Slave set-up, removed in MySQL 8.0
# query_cache_size               = 0                                 # removed in MySQL 8.0
# log_slave_updates              = ON                                # Must be enabled on ALL Galera nodes if binary log is enabled!
# server_id                      = ...                               # Should be equal on all Galera nodes according to Codership CTO if binary log is enabled.


# WSREP parameter

# wsrep_on                       = on                                  # Only MariaDB >= 10.1
# wsrep_provider                 = /usr/lib/galera/libgalera_smm.so    # Location of Galera Plugin on Ubuntu ?
# wsrep_provider                 = /usr/lib64/galera-3/libgalera_smm.so   # Location of Galera v3 Plugin on CentOS 7
# wsrep_provider                 = /usr/lib64/galera-4/libgalera_smm.so   # Location of Galera v4 Plugin on CentOS 7
# wsrep_provider_options         = 'gcache.size = 1G'                  # Depends on you workload, WS kept for IST
# wsrep_provider_options         = 'gcache.recover = on'               # Since 3.19, tries to avoid SST after crash

# wsrep_cluster_name             = "My cool Galera Cluster"            # Same Cluster name for all nodes
# wsrep_cluster_address          = "gcomm://192.168.0.1,192.168.0.2,192.168.0.3"   # Start other nodes like this

# wsrep_node_name                = "Node A"                            # Unique node name
# wsrep_node_address             = 192.168.0.1                         # Our address where replication is done
# wsrep_node_incoming_address    = 10.0.0.1                            # Our external interface where application comes from
# wsrep_sync_wait                = 1                                   # If you need realy full-synchronous replication (Galera 3.6 and newer)
# wsrep_slave_threads            = 16                                  # 4 - 8 per core, not more than wsrep_cert_deps_distance

# wsrep_sst_method               = rsync                               # SST method (initial full sync): mysqldump, rsync, rsync_wan, xtrabackup-v2
# wsrep_sst_auth                 = sst:secret                          # Username/password for sst user
# wsrep_sst_receive_address      = 192.168.2.1                         # Our address where to receive SST


# Group Replication parameter

# default_storage_engine         = InnoDB                              # Group Replication only works with InnoDB
# server_id                      = %SERVERID%                          # Should be different on all 3 nodes
# log_bin                        = %INSTANCEDIR%/binlog/%UNAME%_%INSTANCE%_binlog   # Locate outside of datadir, adjust AppArmor configuration: /etc/apparmor.d/local/usr.sbin.mysqld
# binlog_format                  = ROW
# binlog_checksum                = NONE                                # not default!
# gtid_mode                      = ON
# enforce_gtid_consistency       = ON
# master_info_repository         = TABLE
# relay_log_info_repository      = TABLE
# log_slave_updates              = ON

# slave_parallel_workers         = <n>                                 # 1-2/core, max. 10
# slave_preserve_commit_order    = ON
# slave_parallel_type            = LOGICAL_CLOCK

# transaction_write_set_extraction            = XXHASH64

# loose-group_replication_group_name          = "$(uuidgen)"           # Must be the same on all nodes
# loose-group_replication_start_on_boot       = OFF
# loose-group_replication_local_address       = "192.168.0.1"
# loose-group_replication_group_seeds         = "192.168.0.1,192.168.0.2,192.168.0.3"   # All nodes of Cluster
# loose-group_replication_bootstrap_group     = OFF
# loose-group_replication_single_primary_mode = FALSE                  # = multi-primary
```

## 可以直接使用的模板

下面是经过配置之后一个可以直接用的模板，建议不要打开，在linux通过vim查看，否则文件的编码格式改变容易导致问题：

```sql
# Example MySQL config file for small systems.  
#  
# This is for a system with little memory (<= 64M) where MySQL is only used  
# from time to time and it's important that the mysqld daemon  
# doesn't use much resources.  
#  
# MySQL programs look for option files in a set of  
# locations which depend on the deployment platform.  
# You can copy this option file to one of those  
# locations. For information about these locations, see:  
# http://dev.mysql.com/doc/mysql/en/option-files.html  
#  
# In this file, you can use all long options that a program supports.  
# If you want to know which options a program supports, run the program  
# with the "--help" option.  

# The following options will be passed to all MySQL clients  
[client]  
default-character-set=utf8  
#password   = your_password  
port        = 3306 
socket      = /tmp/mysql.sock  

# Here follows entries for some specific programs  

# The MySQL server   
[mysqld]  
default-storage-engine=INNODB  
character-set-server=utf8  
collation-server=utf8_general_ci  
port        = 3306 
socket      = /tmp/mysql.sock  
skip-external-locking  
key_buffer_size = 16K  
max_allowed_packet = 1M  
table_open_cache = 4 
sort_buffer_size = 64K  
read_buffer_size = 256K  
read_rnd_buffer_size = 256K  
net_buffer_length = 2K  
thread_stack = 128K  

# Don't listen on a TCP/IP port at all. This can be a security enhancement,  
# if all processes that need to connect to mysqld run on the same host.  
# All interaction with mysqld must be made via Unix sockets or named pipes.  
# Note that using this option without enabling named pipes on Windows  
# (using the "enable-named-pipe" option) will render mysqld useless!  
#   
#skip-networking  
server-id   = 1

# Uncomment the following if you want to log updates  
log-bin=mysql-bin  

# binary logging format - mixed recommended  
#binlog_format=mixed  

# Causes updates to non-transactional engines using statement format to be  
# written directly to binary log. Before using this option make sure that  
# there are no dependencies between transactional and non-transactional  
# tables such as in the statement INSERT INTO t_myisam SELECT * FROM  
# t_innodb; otherwise, slaves may diverge from the master.  
#binlog_direct_non_transactional_updates=TRUE  

# Uncomment the following if you are using InnoDB tables  
#innodb_data_home_dir = /usr/local/mysql/data  
#innodb_data_file_path = ibdata1:10M:autoextend  
#innodb_log_group_home_dir = /usr/local/mysql/data  
# You can set .._buffer_pool_size up to 50 - 80 %  
# of RAM but beware of setting memory usage too high  
#innodb_buffer_pool_size = 16M  
#innodb_additional_mem_pool_size = 2M  
# Set .._log_file_size to 25 % of buffer pool size  
#innodb_log_file_size = 5M  
#innodb_log_buffer_size = 8M  
#innodb_flush_log_at_trx_commit = 1 
#innodb_lock_wait_timeout = 50 

[mysqldump]  
quick  
max_allowed_packet = 16M  

[mysql]  
no-auto-rehash  
# Remove the next comment character if you are not familiar with SQL  
#safe-updates  

[myisamchk]  
key_buffer_size = 8M  
sort_buffer_size = 8M  

[mysqlhotcopy]  
interactive-timeout

[mysqld] 
transaction-isolation=READ-COMMITTED

```

