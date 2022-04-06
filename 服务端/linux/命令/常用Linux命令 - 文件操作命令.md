# 常用Linux命令 - 文件操作命令

# 前言

​	没啥好说的，更多的是作为自己的一个笔记，在忘记的时候临时看一下使用。



# 文件操作命令

> 补充点：
>
> **echo** 命令， 将数据内容打印
>
> **\>\>** 重定向的打印符号
>
> `echo sadsadsad >> filename` 将输出重定向到一个文件 

## touch 命令

- 作用：**创建空文件**或者**修改文件时间**
- 命令所在路径： **/bin/touch**
- 执行权限：所有用户
- 修改文件的时间戳
- 示例

```
-rw-rw-r-- 1 zxd zxd 0 3月  31 12:00 111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ touch 111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ll
总用量 0
-rw-rw-r-- 1 zxd zxd 0 3月  31 12:02 111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ^C
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ 

```

## stat 命令

stat 是查看文件详细信息的命令，而且可以看到文件的这三个时间，信息如下：

- 命令名称：stat
- 所在路径： /usr/bin/stat
- 执行权限：所有用户
- 功能描述：显示文件或者文件系统的详细信息
- 示例

```
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ stat 111
  文件："111"
  大小：0         	块：0          IO 块：4096   普通空文件
设备：fd01h/64769d	Inode：406041      硬链接：1
权限：(0664/-rw-rw-r--)  Uid：( 1001/     zxd)   Gid：( 1001/     zxd)
最近访问：2019-03-31 12:02:51.603218828 +0800
最近更改：2019-03-31 12:02:51.603218828 +0800
最近改动：2019-03-31 12:02:51.603218828 +0800
创建时间：-

```





## cat 命令

用来查看文件内容

- 命令名称：cat
- 所在路径：/bin/cat
- 执行权限：所有用户
- 功能描述：合并文件并打印输出到标准输出
- 示例：

```
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ echo adasdsad >> 111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ls 11
ls: 无法访问11: 没有那个文件或目录
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ls 111
111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ cat 111
adasdsad
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ cat -n 111
     1	adasdsad
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ cat -A 111
adasdsad$

```



## more命令

​	more是分屏显示文件的一种命令。

- 命令名称：More
- 所在文件：/bin/more
- 执行权限：所有用户
- 功能描述：分屏显示文件内容

​	more 命令比较简单，一般不用什么选项，命令会打开一个交互界面，可以识别一些交互命令。常
用的交互命令如下。

- 空格键：向下翻页。
- b：向上翻页。
- 回车键：向下滚动一行。
- /字符串：搜索指定的字符串。
- q：退出。

##  less  命令

​	less 命令和 more 命令类似，只是 more 是分屏显示命令，而 less 是分行显示命令，其基本信息如下。

- 命令名称：less。
- 英文原意：opposite of more。
- 所在路径：/usr/bin/less
- 示例

```
[zxd@izwz99gyct1a1rh6iblyucz jdk]$ less THIRDPARTYLICENSEREADME.txt 
[zxd@izwz99gyct1a1rh6iblyucz jdk]$ 
```

## head  命令

​	head 是用来显示文件开头的命令，其基本信息如下。

- 命令名称：head。
- 英文原意：output the first part of files。
- 所在路径：/usr/bin/head。
- 执行权限：所有用户。
- 功能描述：显示文件开头的内容。

​	命令格式

```shell
[root@localhost ~]# head [选项] 文件名
选项：
-n 行数：  从文件头开始，显示指定行数
-v： 显示文件名
```

​	示例

```
[zxd@izwz99gyct1a1rh6iblyucz ~]$ cd testLinux/
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ head -v 111 
==> 111 <==
adasdsad
asdfoafhodiwsfhdosafhisaodfhoidshfodshf

```



##  ln 命令

​	补充：如何知道根目录的i 节点号，我们可以使用如下的命令进行查看

```
[zxd@izwz99gyct1a1rh6iblyucz jdk]$ ls -ild /
2 dr-xr-xr-x. 19 root root 4096 3月   7 18:07 /
```

​	 ln 命令的基本信息。

- 命令名称：ln。
- 英文原意：make links between file。
- 所在路径：/bin/ln。
- 执行权限：所有用户。
- 功能描述：在文件之间建立链接。

```
[root@localhost ~]# ln [选项] 源文件 目标文件
选项：
-s： 建立软链接文件。如果不加“-s”选项，则建立硬链接文件
-f： 强制。如果目标文件已经存在，则删除目标文件后再建立链接文件
```

## 补充：硬链接和软链接

### 硬链接的特征：

+ 源文件和硬链接文件拥有相同的 Inode 和 Block
+ 修改任意一个文件，另一个都改变
+  删除任意一个文件，另一个都能使用
+ 硬链接标记不清，很难确认硬链接文件位置，不建议使用
+ 硬链接不能链接目录

+ 硬链接不能跨分区

### 不推荐使用硬链接的原因：

> 原因： 
>
> 1. 只能通过I节点和引用计数器来确定是否为硬链接，不清晰
> 2. 硬链接不能指向目录
> 3. 硬链接不能跨分区



示例：

```
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ mkdir lndirt
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ln lndirt/ 
ln: "lndirt/": 不允许将硬链接指向目录
```

创建一个硬链接

```
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ls -il 
总用量 8
406041 -rw-rw-r-- 2 zxd zxd 9 3月  31 16:25 111
406041 -rw-rw-r-- 2 zxd zxd 9 3月  31 16:25 test111
```

## 软链接特征：

- 软链接和源文件拥有不同的 Inode 和 Block
- 两个文件修改任意一个，另一个都改变
- 删除软链接，源文件不受影响；删除源文件，软链接不能使用软链接没有实际数据，只保存源文件的 Inode，不论源文件多大，软链接大小不变
- 软链接的权限是最大权限 **lrwxrwxrwx.**，但是由于没有实际数据，最终访问需要参考源文件权限
- 软链接可以链接目录
- 软链接可以跨分区 
- 软链接特征明显，建议使用软连接

### <font color='red'>建立软连接使用绝对路径</font>

### <font color='red'>建立软连接使用绝对路径</font>

### <font color='red'>建立软连接使用绝对路径</font>

# 总结

​	文件的操作命令其实到最后用的最多的就一个More和cat比较多，或者有时候快速查找使用head找前面的几条命令。

