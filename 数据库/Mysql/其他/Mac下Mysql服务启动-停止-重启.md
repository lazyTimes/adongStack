Mac下Mysql服务启动/停止/重启

给自己看系列

1.需要进入Mysql目录/support-files 下

MySQL 在 Mac 下默认安装位置在：

	/usr/local/mysql
	# 我们需要进入 mysql文件下的support-files
复制代码
2.启动MySQL

support-files 下 有 mysql.server 使用命令启动
命令如下：

	sudo /usr/local/mysql/support-files/mysql.server start
	# 注：必须加sudo
复制代码
mysql的停止和重启 和 启动相似 把start 替换为 stop 或 restart 即可

3.mysql.server 配置环境变量

方便之后每次的 开启、停止 和 重启，就不用像上面中命令一样每次都要加路径了

命令如下：

	# 打开 .bash_profile 添加 mysql.server 路径 
	vim ~/.base_profile
	
	# 添加入下：
	export MYSQL_HOME=/usr/local/mysql
	export PATH=${PATH}:${MYSQL_HOME}/support-files
	
	# 保存.bash_profile后使用 source 命令让 刚才的改动生效
	source !/.bash_profile
	
	# 最后使用 sudo /usr/local/mysql/support-files/mysql.server start 验证是否配置成功即可
	
