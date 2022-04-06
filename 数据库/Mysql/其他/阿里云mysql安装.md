# 记一次阿里云安装mysql （rpm安装）



## 下载mysql源安装包

```mysql
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
```



## 安装mysql源

```mysql
yum localinstall mysql57-community-release-el7-8.noarch.rpm
```



## 检测是否安装完成

```mysql
yum repolist enabled | grep "mysql.*-community.*"
```



## 安装mysql

```mysql
yum install mysql-community-server
```



## 设置开启启动mysql服务

```shell
systemctl enable mysqld
```



## 查看安装的mysql版本

```shell
rpm -aq | grep -i mysql
```



## 启动MySQL服务

```mysql
systemctl restart mysqld
```



## 查看MySQL初始密码

```mysql
grep 'A temporary password' /var/log/mysqld.log
```

执行上面步骤可以获得mysql初始数据库密码：

```
获取到初始密码：.DhtciCJ?3rg
```

根据此密码就可以在第一次root登录的时候修改密码

## 更改MySQL密码

`mysqladmin -u root -p'旧密码' password '新密码'`

### 初始化更改密码的案例

```mysql
mysqladmin  -u root -p 'xxx' password 'xxxxx'
```

```mysql
alter user 'root'@'localhost' identified by '.DhtciCJ?3rg' # 这里用刚刚到随机初始密码
```



> 这里会可能出现<font color='red'>更改失败</font>的问题
>
> 方法一：把密码设置复杂点（这是最直接的方法）
>
> 方法二：关闭mysql密码强度验证(validate_password)
>
> 　　　　编辑配置文件：vim /etc/my.cnf， 增加这么一行validate_password=off
>
> 　　　　编辑后重启mysql服务：systemctl restart mysqld

## 设置mysql能够远程访问（不建议使用root）

### 1. 登录进MySQL：mysql -uroot -p密码

注意只有root用户才可以操作

### 2. 在阿里云当中增加一个用户给予访问权限：
具体查看阿里云配置安全组

### 开放用户远程访问:
https://www.cnblogs.com/hoge/p/4958214.html

mysql中添加一个和root一样的用户用于远程连接：

大家在拿站时应该碰到过。root用户的mysql，只可以本地连，对外拒绝连接。

下面语句添加一个新用户`administrtor`：

```mysql
-- 创建新用户
CREATE USER 'monitor'@'%' IDENTIFIED BY 'admin';

-- 给用户分配root并且支持远程访问
GRANT ALL PRIVILEGES ON *.* TO 'monitor'@'%' IDENTIFIED BY 'admin' WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
```

删除这个用户：

```mysql
-- 删除用户
DROP USER 'monitor'@'%';
-- 删除具体分配表
DROP DATABASE IF EXISTS `monitor` ;
```

 

### 3. 阿里云的安全组设置里面选择添加安全组规则，开启3306端口。授权对象选择`0.0.0.0/0`所有ip可访问，如果添加限制可以点击旁面的小叹号。

### <font color='red'>4. 最后：建议重启一下mysqld的服务</font>
