# M1-Mac中docker的redis集群配置

# 前言

​	标题起名有些绕不过为了防止读者误解这也是一个必要的，本文是个人的一次mac上搭建redis集群的实战笔记，笔者为mac系统，虽然很多操作类似Linux但是有差异，也踩了不少的坑，本教程也可以作为linux的docker搭建redis集群参考使用，最后有任何疑问欢迎讨论。

> 提示：本教程适用于linux和mac系统，但是需要注意的是mac系统中`/usr/local`目录下面其实是被mac封闭的，不能作为配置和使用，虽然可以通过sudo强制构建配置等文件，但是会出现莫名其妙的情况，本文也会列出个人的**踩坑点**，希望能帮助同样使用mac系统的同学避坑。



# 一、准备docker

​	巧妇难为无米之炊，所以先得在mac上装一个docker。

## 1. 安装docker	

​	个人目前使用mac作为主力机，所以所有的演示都是在mac上完成，当然下载也是只提供mac的下载地址，首先需要跑到这个网址进行下载，https://docs.docker.com/desktop/mac/install/。

1. mac的安装直接拖过去就行，这里安装完成之后不知道为什么docker容器老是无法启动，但是点击了unintall啥的之后突然就好了，目前经过版本迭代docker已经可以正常在m1中使用了。
3. 安装完成之后启动软件，可以先运行一下docker的`ddocker info`的命令，也可以先选择软件推荐的镜像来运行一下，命令如下 ：`docker run -d -p 80:80 docker/getting-started`
![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211102140642.png)
4. 运行完成之后，直接访问localhost即可，此时会进入一个docker的快速入门页面。



## 2. 更新镜像
​	由于国外的docker实在是慢，所以这里需要先切换为国内的镜像仓库，最终使用的是网易的镜像地址：http://hub-mirror.c.163.com。在任务栏点击` Docker for mac 应用图标 -> Perferences... -> Daemon -> Registry mirrors`。在列表中填写加速器地址即可，修改完成之后，点击 `Apply & Restart `按钮，Docker 就会重启并应用配置的镜像地址了。

> 新版的docker 只要更改 docker engine的相关json配置即可，比如下面的就是替换之后的结果，也算是一个踩坑点，网上的多数教程都是老版本的docker，找了半天没找到在哪=-=：
>
> ![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211102135713.png)

​	最后为了验证配置是否生效我们可以使用`docker info`查看，在打印信息的最下方看到对应的配置地址说明配置生效了：

```yml
 Insecure Registries:
  127.0.0.0/8
 Registry Mirrors:
  https://docker.mirrors.ustc.edu.cn/
  https://hub-mirror.c.163.com/
 Live Restore Enabled: false
```





# 二、docker的redis单机部署

​	单机部署就十分简单了，只需要下面几个命令即可：

```shell
#默认拉取一个最新的redis镜像
docker pull redis
#在默认的6379端口上启动一个redis服务
docker run --name test-redis -p 6379:6379 -d redis
#进入容器内部
docker exec -it test-redis /bin/bash
# 连接redis
redis-cli
#进入之后安装惯例 ping一下即可
ping
```

​	单机运行还是配置还是挺快的，不过需要注意单机的运行使用的配置都是默认的配置，并且**docker启动redis镜像里是没有配置文件的**，如果想要像安装redis一样使用自定义的配置文件启动需要做如下的更改。

## 自定义redis配置启动

1. 如果是自定义的配置，首先在自己在任意的目录位置创建用于映射的目录以及从https://github.com/redis/redis/blob/unstable/redis.conf 拉一个模板的配置文件过来即可。

2. 最后，通过下面的命令内容进行配置 

```
#-d 后台运行返回容器id
#-p 端口映射
#-v 数据卷映射
#末尾[COMMAMD]执行该命令
docker run -d -p 6380:6380 -v /usr/docker/redis/myRedis/redis.conf:/etc/redis/redis.conf -v /usr/docker/redis/myRedis/data:/data --name myRedis redis redis-server /etc/redis/redis.conf
```

`/usr/docker/redis/myRedis/redis.conf`：这里需要改为你需要映射的配置文件地址，同理data文件也需要对应的修改。



# 三、docker 中redis集群部署（重点）

​	首先需要确保上面的内容都已经完成了处理，下面就可以进行相关的redis安装了，安装的过程如下：

## 1. 检索redis镜像

​	**docker search redis**，展示之后发现了常见的官方提供的redis镜像，直接啦取即可。

## 2. 拉取镜像

**docker pull redis**，同样也是把redis的镜像拉到本地来，拉取之后执行`docker images`,下面是执行结果：

```
zxd@zxddeMacBook-Pro ~ % docker images
REPOSITORY               TAG       IMAGE ID       CREATED        SIZE
redis                    latest    c3d77c9fc5b8   2 weeks ago    107MB
docker/getting-started   latest    613921574f76   4 months ago   26.7MB
```
## 3. 构建redis自定义

​	执行：`docker network create redis-net`，执行命令之后出现如下的返回结果，这样就创建了redis集群的通信端了

> 创建完成之后出现下面的内容： 
>
> a42040f20cb54027b75a68f3d000a7bb02f417e2f202297658bfc1a2c88041d7

## 4. 构建集群配置文件模板文件

​	构建基础集群的配置文件，如果你是linux系统可以执行：`cd /usr/local/src && mkdir redis-cluster && cd ./redis-cluster && touch redis-cluster.conf`。但是如果你是mac系统，建议不要这样操作，更加建议在`/User/用户名/redis/xxx`下面构建自己的配置，下面是`redis-cluster.conf`文件的模板。

```yml
# ${PORT}不需要替换，为占位符，注意
port ${PORT}
cluster-enabled yes
protected-mode no
cluster-config-file nodes.conf
cluster-node-timeout 5000
#对外ip，这里的ip要改为你的服务器Ip。【注意不能使用127.0.0.1】
cluster-announce-ip 192.168.0.12
cluster-announce-port ${PORT}
cluster-announce-bus-port 1${PORT}
appendonly yes
```

## 5. 生成具体集群配置文件

如果是linux系统，则可以使用命令`cd /usr/local/src/redis-cluster`进入到对应的构建配置的目录，当然这里是mac进行了对应的目录，然后我们生成conf和data目录，并生成配置信息：

`seq 6000 6005`: 可以自己指定遍历的端口，这里刚好是6个redis实例，也就是默认的3主3从的方式。

```js
for port in `seq 6000 6005`; do 
  mkdir -p ./${port}/conf && PORT=${port} envsubst < ./redis-cluster.conf > ./${port}/conf/redis.conf && mkdir -p ./${port}/data;
done
```

​	生成之后的效果如下，可以看到生成了从6000-6005的配置文件以及data目录，这就是搭建集群的基础配置 ：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211104133302.png)

​	如果打开其中一个配置文件，它的内容如下，这里可以对比之前的模板配置就能明白改了哪些内容：

```
port 6000
cluster-enabled yes
protected-mode no
cluster-config-file nodes.conf
cluster-node-timeout 5000
#对外ip
cluster-announce-ip 192.168.0.12
cluster-announce-port 6000
cluster-announce-bus-port 16000
appendonly yes
```

## 6. 编写并运行集群运行脚本

​	接着，在当前的目录下我们可以创建一个脚本文件`start.sh`，并且执行`vim start.sh`，在脚本的内容如下，编写完成之后使用shell命令执行如下：`sh start.sh`运行脚本即可。

​	下面重点来了，前文说过mac系统的/usr/local/src目录是不给访问的，虽然可以使用`sudo`强制创建或者修改文件，但是这并不是权限的问题，是mac把这个文件夹进行封闭并且不建议在此文件夹操作，所以下面的命令**仅仅适用Linux系统**。

```shell
for port in `seq 6000 6005`; do 
  docker run -d -ti -p ${port}:${port} -p 1${port}:1${port} -v /usr/local/src/redis-cluster/${port}/conf/redis.conf:/usr/local/etc/redis/redis.conf -v /usr/local/src/redis-cluster/${port}/data:/data  --restart always --name redis-${port} --net redis-net --sysctl net.core.somaxconn=1024 redis redis-server /usr/local/etc/redis/redis.conf; 
done
```

​	针对这个问题，在mac的系统中我做出了如下的调整（文件夹包含部分个人信息，已作处理）：

```shell
for port in `seq 6000 6005`; do 
  docker run -d -ti -p ${port}:${port} -p 1${port}:1${port} -v /Users/zxd/com/docker-redis/${port}/conf/redis.conf:/usr/local/etc/redis/redis.conf -v /Users/zxd/com/docker-redis/${port}/data:/data  --restart always --name redis-${port} --net redis-net --sysctl net.core.somaxconn=1024 redis redis-server /usr/local/etc/redis/redis.conf; 
done

```
​	下面是部分的参数解释：
```7. shell
#-d 后台运行返回容器id
#-p 端口映射，注意在上面中两个-p，前一个是启动端口，后一个是总线的通信端口
#-v 数据卷映射
#--net redis-net 自定义network(redis-net)
#--sysctl net.core.somaxconn=1024 是Linux中的一个kernel参数，表示socket监听（listen）的backlog上限。它的主要作用是限制了接收新 TCP 连接侦听队列的大小。对于一个经常处理新连接的高负载 web服务环境来说，默认的 128 太小了。大多数环境这个值建议增加到 1024 或者更多
#redis redis-server /usr/local/etc/redis/redis.conf 使用配置文件开启一个redis服务的命令，注意这里的redis.conf实际上会映射到不同的文件夹中的conf中运行
```

## 7. 构建redis集群		
 


​	构建集群的方式如下，验证是否可以使用，当然这里的/usr/local/bin使用的是对应的配置文件存放位置。首先我们需要使用`docker exec -it deb9f97f6f0a（改为你的容器ID） /bin/bash`进入任意点一个docker容器，然后才能进行下面点操作。

> 注意需要把ip改为之前的模板配置的ip否则是无法启动的

```
cd /usr/local/bin && redis-cli --cluster create 192.168.0.12:6000 192.168.0.12:6001 192.168.0.12:6002 192.168.0.12:6003 192.168.0.12:6004 ip:6005 --cluster-replicas 1
```

​	然后我们运行`docker ps`出现如下的结果，另外这里有可能存在由于端口没有开放的报错，但是由于我是本地搭建的，所以没有出现此问题：

```shell
docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED        STATUS        PORTS                                                        NAMES
deb9f97f6f0a   redis     "docker-entrypoint.s…"   33 hours ago   Up 30 hours   0.0.0.0:6005->6005/tcp, 0.0.0.0:16005->16005/tcp, 6379/tcp   redis-6005
b226de3d1fa1   redis     "docker-entrypoint.s…"   33 hours ago   Up 30 hours   0.0.0.0:6004->6004/tcp, 0.0.0.0:16004->16004/tcp, 6379/tcp   redis-6004
c805e9704a1a   redis     "docker-entrypoint.s…"   33 hours ago   Up 30 hours   0.0.0.0:6003->6003/tcp, 0.0.0.0:16003->16003/tcp, 6379/tcp   redis-6003
fbae17f03f77   redis     "docker-entrypoint.s…"   33 hours ago   Up 30 hours   0.0.0.0:6002->6002/tcp, 0.0.0.0:16002->16002/tcp, 6379/tcp   redis-6002
93e668ff8f2b   redis     "docker-entrypoint.s…"   33 hours ago   Up 30 hours   0.0.0.0:6001->6001/tcp, 0.0.0.0:16001->16001/tcp, 6379/tcp   redis-6001
9bdb2de54709   redis     "docker-entrypoint.s…"   33 hours ago   Up 30 hours   0.0.0.0:6000->6000/tcp, 0.0.0.0:16000->16000/tcp, 6379/tcp   redis-6000
```

## 8. 验证集群是否可用

​	最后我们通过连接某一个节点验证集群是否成功可用：

​	首先进入任意一个Redis容器内（CONTAINER ID为容器id）

```js
docker exec -it deb9f97f6f0a（改为你的容器ID） /bin/bash
```

​	然后进入 redis-cli（ip为你服务器ip）

```js
redis-cli -h 192.168.0.12 -p 6000
```

​	查看节点消息

```js
cluster nodes
```

​	查看集群信息

```js
cluster info
```

## 9. 验证集群分布

​	最后是实际输入几条简单的命令验证一下是否真的可以分片并且分布到多台机器进行处理

​	集群模式连接：以下例子显示操作正常（首先要退出当前redis-cli，然后再执行以下代码，ip为你服务器ip）。

```js
redis-cli -c -h ip -p 6000 set test 1
redis-cli -c -h ip -p 6000 get test
```

# 其他补充

## 关闭系统防火墙

```js
systemctl restart firewalld
```

## 重启docker

```js
systemctl restart docker
```

# 写在最后

​	内容比较多，一次成功的概率其实并不算很高，如果有疑问欢迎评论。