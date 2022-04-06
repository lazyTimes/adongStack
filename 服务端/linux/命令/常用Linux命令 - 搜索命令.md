
# 搜索命令

## whereis 命令

whereis 是搜索系统命令的命令（像绕口令一样），也就是说，whereis 命令不能搜索普通文件，
而只能搜索系统命令。whereis 命令的基本信息如下。

- 命令名称：whereis。
- 英文原意：locate the binary, source, and manual page files for a command。
- 所在路径：/usr/bin/whereis。
- 执行权限：所有用户。
- 功能描述：查找二进制命令、源文件和帮助文档的命令。

## which  命令

which 也是搜索系统命令的命令。和 whereis 命令的区别在于：

- whereis 命令可以在查找到二进制命令的同时，查找到帮助文档的位置；
- 而 which 命令在查找到二进制命令的同时，如果这个命令有别名，则还可以找到别名命令。

## locate  命令

基本用法
locate 命令才是可以按照文件名搜索普通文件的命令。

- 优点：按照数据库搜索，搜索速度快，消耗资源小。数据库位置/var/lib/mlocate/mlocate.db，
  可以使用 `updatedb` 命令强制更新数据库。
- 缺点：只能按照文件名来搜索文件，而不能执行更复杂的搜索，比如按照权限、大小、修改时间等搜索文件。

locate 命令的基本信息如下。

- 命令名称：locate。
- 英文原意：find files by name。
- 所在路径：/usr/bin/locate。
- 执行权限：所有用户。
- 功能描述：按照文件名搜索文件。

配置文件

```
[root@localhost ~]# vi /etc/updatedb.conf
PRUNE_BIND_MOUNTS = "yes"

#开启搜索限制，也就是让这个配置文件生效
PRUNEFS = "……"

#在 locate 执行搜索时，禁止搜索这些文件系统类型
PRUNENAMES = "……"

#在 locate 执行搜索时，禁止搜索带有这些扩展名的文件
PRUNEPATHS = "……"

#在 locate 执行搜索时，禁止搜索这些系统目录

```



## find 命令

find 命令的基本信息如下。

- 命令名称：find。
- 英文原意：search for files in a directory hierarchy。
- 所在路径：/bin/find。
- 执行权限：所有用户。
- 功能描述：在目录中搜索文件。

### 按照文件名搜索

```
[root@localhost ~]# find 搜索路径 [选项] 搜索内容
选项：
-name： 按照文件名搜索
-iname： 按照文件名搜索，不区分文件名大小写
-inum： 按照 inode 号搜索

```



### 按照文件大小搜索

```
[root@localhost ~]# find 搜索路径 [选项] 搜索内容
选项：
-size [+|-]大小：  按照指定大小搜索文件

```

这里的“+”的意思是搜索比指定大小还要大的文件，“-”的意思是搜索比指定大小还要小的文件。



find 命令的单位：

```
[root@localhost ~]# man find
-size n[cwbkMG]

File uses n units of space. The following suffixes can be used:
'b' for 512-byte blocks (this is the default if no suffix is used)

#这是默认单位，如果单位为 b 或不写单位，则按照 512 Byte 搜索

'c' for bytes

#搜索单位是 c ，按照字节搜索

'w' for two-byte words 

#搜索单位是 w ，按照双字节（中文）搜索

'k' for Kilobytes (units of 1024 bytes)

#按照 KB 单位搜索，必须是小写的 k

'M' for Megabytes (units of 1048576 bytes)

#按照 MB 单位搜索，必须是大写的 M

'G' for Gigabytes (units of 1073741824 bytes)

#按照 GB 单位搜索，必须是大写的 

```



### 按照修改时间搜索

Linux 中的文件有访问时间（atime）、数据修改时间（mtime）、状态修改时间（ctime）这三个
时间，我们也可以按照时间来搜索文件。

```
[root@localhost ~]# find 搜索路径 [选项] 搜索内容
选项：
-atime [+|-]时间：  按照文件访问时间搜索
-mtime [+|-]时间：  按照文件数据修改时间搜索
-ctime [+|-]时间：  按照文件状态修改时间搜索

```

这种方法非常简单，输出的帮助信息基本上是 man 命令的信息简要版。
对于这 4 种常见的获取帮助的方法，大家可以按照自己的习惯任意使用。

这三个时间的区别我们在 stat 命令中已经解释过了，这里用 mtime 数据修改时间来举例，重点说
说“[+-]”时间的含义。

- -5：代表 5 天内修改的文件。
- 5：代表前 5～6 天那一天修改的文件。
- +5：代表 6 天前修改的文件。
- 

