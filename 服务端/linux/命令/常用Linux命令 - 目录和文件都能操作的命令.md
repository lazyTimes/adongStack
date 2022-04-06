
# 目录和文件都能操作的命令

## m 命令

rm 是强大的删除命令，不仅可以删除文件，也可以删除目录。这个命令的基本信息如下。

- 命令名称：rm。
- 英文原意：remove files or directories。
- 所在路径：/bin/rm。
- 执行权限：所有用户。
- 功能描述：删除文件或目录。

命令格式

```shell
[root@localhost ~]# rm [选项] 文件或目录
选项：
-f： 强制删除（force）
-i： 交互删除，在删除之前会询问用户
-r： 递归删除，可以删除目录（recursive

```

- 示例

```
rm -rf / 光速离职命令
rm -i 其实不加任何参数和此命令效果等同
```



## cp 命令

cp 是用于复制的命令

- 命令名称：cp。
- 英文原意：copy files and directories。
- 所在路径：/bin/cp。
- 执行权限：所有用户。
- 功能描述：复制文件和目录。

命令格式

```
[root@localhost ~]# cp [选项] 源文件 目标文件
选项：
-a： 相当于-dpr 选项的集合，这几个选项我们一一介绍
-d： 如果源文件为软链接（对硬链接无效），则复制出的目标文件也为软链接
-i： 询问，如果目标文件已经存在，则会询问是否覆盖
-p： 复制后目标文件保留源文件的属性（包括所有者、所属组、权限和时间）
-r： 递归复制，用于复制目录

```

- 示例

```
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ls -li
总用量 12
406041 -rw-rw-r-- 2 zxd zxd 49 3月  31 17:16 111
406045 -rw-rw-r-- 1 zxd zxd 49 3月  31 19:27 120
406044 lrwxrwxrwx 1 zxd zxd  3 3月  31 17:04 ddd -> 111
406041 -rw-rw-r-- 2 zxd zxd 49 3月  31 17:16 test111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ cp ddd sss
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ll
总用量 16
-rw-rw-r-- 2 zxd zxd 49 3月  31 17:16 111
-rw-rw-r-- 1 zxd zxd 49 3月  31 19:27 120
lrwxrwxrwx 1 zxd zxd  3 3月  31 17:04 ddd -> 111
-rw-rw-r-- 1 zxd zxd 49 3月  31 19:27 sss
-rw-rw-r-- 2 zxd zxd 49 3月  31 17:16 test111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ rm sss 
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ cp -a ddd sss
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ ll
总用量 12
-rw-rw-r-- 2 zxd zxd 49 3月  31 17:16 111
-rw-rw-r-- 1 zxd zxd 49 3月  31 19:27 120
lrwxrwxrwx 1 zxd zxd  3 3月  31 17:04 ddd -> 111
lrwxrwxrwx 1 zxd zxd  3 3月  31 17:04 sss -> 111
-rw-rw-r-- 2 zxd zxd 49 3月  31 17:16 test111
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ 


```

##  mv  命令

mv 是用来剪切的命令，其基本信息如下。

- 命令名称：mv。
- 英文原意：move (rename) files。
- 所在路径：/bin/mv。
- 执行权限：所有用户。
- 功能描述：移动文件或改名。

命令格式

```
[root@localhost ~]# mv [选项] 源文件 目标文件
选项：
-f： 强制覆盖，如果目标文件已经存在，则不询问，直接强制覆盖
-i： 交互移动，如果目标文件已经存在，则询问用户是否覆盖（默认选项）
-v： 显示详细信息

```

+ 示例

```
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ mv aaa /usr/local/
[zxd@izwz99gyct1a1rh6iblyucz testLinux]$ mv aaa bbb
```
