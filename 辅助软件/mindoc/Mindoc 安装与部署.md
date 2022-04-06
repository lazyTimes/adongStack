# Mindoc 安装与部署

地址： https://www.iminho.me/wiki/docs/mindoc/mindoc-summary.md

## 第一步 下载可执行文件

请从 <https://github.com/lifei6671/mindoc/releases> 下载最新版的可执行文件，一般文件名为 mindoc_windows_amd.zip .

## 第二步 解压压缩包

请将刚才下载的文件解压，推荐使用好压解压到任意目录。建议不用用中文目录名称。

## 第三步 创建数据库

如果你使用的 mysql 数据库，请创建一个编码为utf8mb4格式的数据库，如果没有GUI管理工具，推荐用下面的脚本创建：

```sql
CREATE DATABASE mindoc_db  DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
```

------

如果你使用的是 sqlite 数据库，请将 conf/app.conf 中的数据库配置成如下,系统会自动创建 sqlite 数据库文件：

```
db_adapter=sqlite3
db_database=mindoc_db
```

## 第四步 配置数据库

请将刚才解压目录下 conf/app.conf.example 重名为 app.conf。同时配置如下节点：

```ini
#数据库配置
db_adapter=mysql
#mysql数据库的IP
db_host=127.0.0.1

#mysql数据库的端口号一般为3306
db_port=3306

#刚才创建的数据库的名称
db_database=mindoc_db

#访问数据库的账号和密码
db_username=root
db_password=123456
```

在 MinDoc 根目录下使用命令行执行如下命令，用于初始化数据库：

```bash
mindoc_windows_amd64.exe install
```

稍等一分钟，程序会自动初始化数据库，并创建一个超级管理员账号：`admin` 密码：`123456`

## 第五步 启动程序

如果你设置了环境变量，但是没有重启电脑，请在cmd命令行启动 mindoc_windows_amd64.exe 程序。

如果你设置了环境变量，并且重启了电脑，双击 mindoc_windows_amd64.exe 即可。

此时访问 [http://localhost:8181](http://localhost:8181/) 就能访问 MinDoc 了。





