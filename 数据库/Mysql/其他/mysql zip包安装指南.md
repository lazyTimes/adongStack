# 1. 下载zip 包

## 地址：

https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.31-winx64.zip

<!-- more -->

# 2. 解压缩，放到D盘自定义位置

我的位置如下:

D:\soft\mysql-5.7.31-winx64

# 3. 配置环境变量

以win10 为例：

1. 打开高级设置

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20200801115826.png)

2. 在此处配置环境变量

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20200801115848.png)

3. 配置如下

MYSQL_HOME : mysql5.7zip包解压路径

**path：%MYSQL_HOME%\bin**

# 4. 新建my.ini文件（解压包里是没有my-dafault.ini或自带my.ini文件，需自己创建）编辑写入以下信息

配置如下

```ini
[mysql]
# 设置mysql客户端默认字符集
default-character-set=utf8 
[mysqld]
# 设置3306端口
port = 3306 
# 设置mysql的安装目录
basedir=C:\Program Files\mysql-5.7.21-winx64
# 设置mysql数据库的数据的存放目录
datadir=C:\Program Files\mysql-5.7.21-winx64\data
# 允许最大连接数
max_connections=200
# 设置mysql服务端默认字符集
character-set-server=utf8
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB 
```

# 5. 让配置生效

mysql初始化，以**管理员权限**打开cmd命令窗口，切换到`”C:\Program Files\mysql-5.7.21-winx64\bin”`路径下执行

这里可以获得ROOT密码：`j<ASsKzqP8M4`

> 这里提示报错:
>
> ==由于找不到msvcr120.dll无法继续执行代码==
>
> 我的解决办法是，进入到：https://www.microsoft.com/zh-cn/download/confirmation.aspx?id=40784
>
> 这种错误是由于未安装 vcredist 引起的
>
> 引入自博客：https://blog.csdn.net/weixin_30517001/article/details/97706795

>MySQL5.7执行mysqld命令出现Can‘t change dir to ‘C:\Program Files\MySQL\MySQL Server 5.7\data\‘错误
>
>==解决方法：==
>提示No such file or directory，到C:\Program Files\MySQL\MySQL Server 5.7\目录下创建data文件夹即可。
>
>楼主这里手动创建了对应的目录以及对应的子目录

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20200801123207.png)

# 6. 让my.ini 配置生效

执行如下命令

`mysqld install MySQL --defaults-file="C:\Program Files\mysql-5.7.21-winx64\my.ini`

my.ini 为你自己建立的配置文件路径

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20200801123830.png)

# 7. 启动mysql服务，输入 net start mysql，启动成功，会出现下面的截图。**如果服务一直处于启动中，说明上一步的操作有误，核实my.ini文件路径是否正确**

如果之前有安装过mysql，这里可以查看这篇博客了解如何卸载:

https://www.cnblogs.com/puhongjun/p/10189454.html

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20200801125305.png)

经过不懈的努力，安装成功

PS：mysql 还是建议装在c盘，个人碰到了各种莫名其妙的问题

# 8. 初次登陆设置mysql root 用户密码：

>  ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.

当使用mysql 安装生成的root 密码登录的时候，需要重新设置root 密码，修改root 密码为:

修改密码命令：`set password = password(‘新密码’)`;

# 9. 结语

此时在服务里面可以看到Mysql 的服务已经启动了

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20200801132213.png)

用zip 包的安装方式可能会有各种各样的问题，这里找了百度先生处理一些常见的问题:

https://jingyan.baidu.com/article/da1091fb1a46a6027849d6a8.html