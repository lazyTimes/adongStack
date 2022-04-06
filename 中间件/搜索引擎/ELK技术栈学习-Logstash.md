# logstash学习

# 安装

## 下载

目前，Logstash 分为两个包：核心包和社区贡献包。你可以从 <http://www.elasticsearch.org/overview/elkdownloads/> 下载这两个包的源代码或者二进制版本。

- 源代码方式

```
wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz
wget https://download.elasticsearch.org/logstash/logstash/logstash-contrib-1.4.2.tar.gz
```

- Debian 平台

```
wget https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb
wget https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb
```

- Redhat 平台

```
wget https://download.elasticsearch.org/logstash/logstash/packages/centos/logstash-1.4.2-1_2c0f5a1.noarch.rpm
https://download.elasticsearch.org/logstash/logstash/packages/centos/logstash-contrib-1.4.2-1_efd53ef.noarch.rpm
```

## 安装

上面这些包，你可能更偏向使用 `rpm`，`dpkg` 等软件包管理工具来安装 Logstash，开发者在软件包里预定义了一些依赖。比如，`logstash-1.4.2-1_2c0f5a.narch` 就依赖于 `jre` 包。

另外，软件包里还包含有一些很有用的脚本程序，比如 `/etc/init.d/logstash`。

如果你必须得在一些很老的操作系统上运行 Logstash，那你只能用源代码包部署了，记住要自己提前安装好 Java：

```
yum install openjdk-jre
export JAVA_HOME=/usr/java
tar zxvf logstash-1.4.2.tar.gz
```

## 最佳实践

但是真正的建议是：如果可以，请用 Elasticsearch 官方仓库来直接安装 Logstash！

### Debian 平台

```bash
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
cat >> /etc/apt/sources.list <<EOF
deb http://packages.elasticsearch.org/logstash/1.4/debian stable main
EOF
apt-get update
apt-get install logstash
```

### Redhat 平台

```
rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/logstash.repo <EOF
[logstash-1.4]
name=logstash repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/logstash/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF
yum clean all
yum install logstash
```

## Hello World

在终端中，像下面这样运行命令来启动 Logstash 进程：

```
bin/logstash -e 'input{stdin{}}output{stdout{codec=>rubydebug}}'
```

此时终端会等待数据

输入helloword显示结果

```
{
      "@version" => "1",
          "host" => "izwz99gyct1a1rh6iblyucz",
    "@timestamp" => 2018-11-22T08:15:46.454Z,
       "message" => "helloword"
}
```

### 解释

每位系统管理员都肯定写过很多类似这样的命令：`cat randdata | awk '{print $2}' | sort | uniq -c | tee sortdata`。这个管道符 `|` 可以算是 Linux 世界最伟大的发明之一(另一个是“一切皆文件”)。

Logstash 就像管道符一样！

你**输入**(就像命令行的 `cat` )数据，然后处理**过滤**(就像 `awk` 或者 `uniq` 之类)数据，最后**输出**(就像 `tee` )到其他地方。



当然实际上，Logstash 是用不同的线程来实现这些的。如果你运行 `top`命令然后按下 H 键，你就可以看到下面这样的输出：

```
PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                     21401 root      16   0 1249m 303m  10m S 18.6  0.2 866:25.46 |worker                   21467 root      15   0 1249m 303m  10m S  3.7  0.2 129:25.59 >elasticsearch.           21468 root      15   0 1249m 303m  10m S  3.7  0.2 128:53.39 >elasticsearch.            21400 root      15   0 1249m 303m  10m S  2.7  0.2 108:35.80 <file                     21403 root      15   0 1249m 303m  10m S  1.3  0.2  49:31.89 >output                    21470 root      15   0 1249m 303m  10m S  1.0  0.2  56:24.24 >elasticsearch.
```

Logstash 会给事件添加一些额外信息。最重要的就是 **@timestamp**，用来标记事件的发生时间。因为这个字段涉及到 Logstash 的内部流转，所以必须是一个 joda 对象，如果你尝试自己给一个字符串字段重命名为 `@timestamp` 的话，Logstash 会直接报错。所以，**请使用 filters/date 插件 来管理这个特殊字段**。

1. **host** 标记事件发生在哪里。
2. **type** 标记事件的唯一类型。
3. **tags** 标记事件的某方面属性。这是一个数组，一个事件可以有多个标签。

# 长期运行

## 1. 标准的 service 方式

采用 RPM、DEB 发行包安装的读者，推荐采用这种方式。发行包内，都自带有 sysV 或者 systemd 风格的启动程序/配置，你只需要直接使用即可。

以 RPM 为例，`/etc/init.d/logstash` 脚本中，会加载 `/etc/init.d/functions` 库文件，利用其中的 `daemon`函数，将 logstash 进程作为后台程序运行。

所以，你只需把自己写好的配置文件，统一放在 `/etc/logstash/` 目录下(注意目录下所有配置文件都应该是 **.conf** 结尾，且不能有其他文本文件存在。因为 logstash agent 启动的时候是读取**全文件夹**的)，然后运行 `service logstash start` 命令即可。



## 2. 最基础的 nohup 方式

这是最简单的方式，也是 linux 新手们很容易搞混淆的一个经典问题：

使用配置文件的方式，在Logstash目录下创建.conf

```
input { stdin {} }
output {
        elasticsearch {
                hosts => '172.18.118.222'
        }
        stdout { codec => rubydebug }
}
```

**(遇到OOM问题)**

```
command
command > /dev/null
command > /dev/null 2>&1
command &
command > /dev/null &
command > /dev/null 2>&1 &
command &> /dev/null
nohup command &> /dev/null
```

## 3. 更优雅的 SCREEN 方式

screen 算是 linux 运维一个中高级技巧。通过 screen 命令创建的环境下运行的终端命令，其父进程不是 sshd 登录会话，而是 screen 。这样就可以即避免用户退出进程消失的问题，又随时能重新接管回终端继续操作。

创建独立的 screen 命令如下：

```
screen -dmS elkscreen_1
```

接管连入创建的 `elkscreen_1` 命令如下：

```
screen -r elkscreen_1
```

然后你可以看到一个一模一样的终端，运行 logstash 之后，不要按 Ctrl+C，而是按 Ctrl+A+D 键，断开环境。想重新接管，依然 `screen -r elkscreen_1` 即可。

如果创建了多个 screen，查看列表命令如下：

```
screen -list
```

## 4. 最推荐的 daemontools 方式

不管是 nohup 还是 screen，都不是可以很方便管理的方式，在运维管理一个 ELK 集群的时候，必须寻找一种尽可能简洁的办法。所以，对于需要长期后台运行的大量程序(注意大量，如果就一个进程，还是学习一下怎么写 init 脚本吧)，推荐大家使用一款 **daemontools** 工具。

**daemontools** 是一个软件名称，不过配置略复杂。所以这里我其实是用其名称来指代整个同类产品，包括但不限于 python 实现的 supervisord，perl 实现的 ubic，ruby 实现的 god 等。

1. 以 **supervisord** 为例，因为这个出来的比较早，可以直接通过 EPEL 仓库安装。

```
yum -y install supervisord --enablerepo=epel
```

2. 在 `/etc/supervisord.conf` 配置文件里添加内容，定义你要启动的程序：

```
[program:logstash]
environment=LS_HEAP_SIZE=128m
directory=/usr/local/software/logstash
command=/usr/local/software/logstash/bin/logstash -f /usr/local/software/logstash/logstash.conf --pluginpath /usr/local/software/logstash/plugins/ -w 10 -l /var/log/logstash/pro1.log

[program:elkpro_2]
environment=LS_HEAP_SIZE=128m
directory=/usr/local/software/logstash
command=/usr/local/software/logstash/bin/logstash -f /etc/logstash/pro2.conf --pluginpath /opt/logstash/plugins/ -w 10 -l /var/log/logstash/pro2.log
```

启动然后`service supervisord start`即可。

其他办法`sudo /bin/systemctl start  supervisord.service`

查看是否启动

systemctl status supervisord.service

logstash会以supervisord子进程的身份运行，你还可以使用`supervisorctl`命令，单独控制一系列logstash子进程中某一个进程的启停操作：

```
supervisorctl stop elkpro_2
```



### supervisorctl 常用命令

supervisorctl status：查看所有进程的状态

supervisorctl stop ：停止

supervisorctl start ：启动

supervisorctl restart : 重启

supervisorctl update ：配置文件修改后可以使用该命令加载新的配置

supervisorctl reload: 重新启动配置中的所有程序



## 5. 使用Docker

```sh
docker pull docker.elastic.co/logstash/logstash:6.5.1
```

## 语法

Logstash 设计了自己的 DSL —— 有点像 Puppet 的 DSL，或许因为都是用 Ruby 语言写的吧 —— 包括有区域，注释，数据类型(布尔值，字符串，数值，数组，哈希)，条件判断，字段引用等。

### 区段(section)

Logstash 用 `{}` 来定义区域。区域内可以包括插件区域定义，你可以在一个区域内定义多个插件。插件区域内则可以定义键值对设置。示例如下：

```
input {
    stdin {}
    syslog {}
}
```

Logstash 支持少量的数据值类型：

- bool

```
debug => true
```

- string

```
host => "hostname"
```

- number

```
port => 514
```

- array

```
match => ["datetime", "UNIX", "ISO8601"]
```

- hash

```
options => {
    key1 => "value1",
    key2 => "value2"
}
```

### 字段引用(field reference)

字段是 `Logstash::Event` 对象的属性。我们之前提过事件就像一个哈希一样，所以你可以想象字段就像一个键值对。

*小贴士：我们叫它字段，因为 Elasticsearch 里是这么叫的。*

如果你想在 Logstash 配置中使用字段的值，只需要把字段的名字写在中括号 `[]` 里就行了，这就叫**字段引用**。

对于 **嵌套字段**(也就是多维哈希表，或者叫哈希的哈希)，每层的字段名都写在 `[]` 里就可以了。比如，你可以从 geoip 里这样获取 *longitude* 值(是的，这是个笨办法，实际上有单独的字段专门存这个数据的)：

```
[geoip][location][0]
```

*小贴士：logstash 的数组也支持倒序下标，即 [geoip][location][-1] 可以获取数组最后一个元素的值。*

Logstash 还支持变量内插，在字符串里使用字段引用的方法是这样：

```
"the longitude is %{[geoip][location][0]}"
```

### 条件判断(condition)

Logstash从 1.3.0 版开始支持条件判断和表达式。

表达式支持下面这些操作符：

- equality, etc: ==, !=, <, >, <=, >=
- regexp: =~, !~
- inclusion: in, not in
- boolean: and, or, nand, xor
- unary: !()

通常来说，你都会在表达式里用到字段引用。比如：

```
if "_grokparsefailure" not in [tags] {
    } else if [status] !~ /^2\d\d/ and [url] == "/noc.gif" {
    } else {
}
```

## 命令行参数

Logstash 提供了一个 shell 脚本叫 `logstash` 方便快速运行。它支持一下参数：

- -e

意即*执行*。我们在 "Hello World" 的时候已经用过这个参数了。事实上你可以不写任何具体配置，直接运行 `bin/logstash -e ''` 达到相同效果。这个参数的默认值是下面这样：

```
input {
    stdin { }
}
output {
    stdout { }
}
```

- --config 或 -f

意即*文件*。真实运用中，我们会写很长的配置，甚至可能超过 shell 所能支持的 1024 个字符长度。所以我们必把配置固化到文件里，然后通过 `bin/logstash -f agent.conf` 这样的形式来运行。

此外，logstash 还提供一个方便我们规划和书写配置的小功能。你可以直接用 `bin/logstash -f /etc/logstash.d/` 来运行。logstash 会自动读取 `/etc/logstash.d/` 目录下所有的文本文件，然后在自己内存里拼接成一个完整的大配置文件，再去执行。

- --configtest 或 -t

意即*测试*。用来测试 Logstash 读取到的配置文件语法是否能正常解析。Logstash 配置语法是用 grammar.treetop 定义的。尤其是使用了上一条提到的读取目录方式的读者，尤其要提前测试。

- --log 或 -l

意即*日志*。Logstash 默认输出日志到标准错误。生产环境下你可以通过 `bin/logstash -l logs/logstash.log`命令来统一存储日志。

- --filterworkers 或 -w

意即*工作线程*。Logstash 会运行多个线程。你可以用 `bin/logstash -w 5` 这样的方式强制 Logstash 为**过滤**插件运行 5 个线程。

*注意：Logstash目前还不支持输入插件的多线程。而输出插件的多线程需要在配置内部设置，这个命令行参数只是用来设置过滤插件的！*

**提示：Logstash 目前不支持对过滤器线程的监测管理。如果 filterworker 挂掉，Logstash 会处于一个无 filter 的僵死状态。这种情况在使用 filter/ruby 自己写代码时非常需要注意，很容易碰上 NoMethodError: undefined method '\*' for nil:NilClass 错误。需要妥善处理，提前判断。**

- --pluginpath 或 -P

可以写自己的插件，然后用 `bin/logstash --pluginpath /path/to/own/plugins` 加载它们。

- --verbose

输出一定的调试日志。

*小贴士：如果你使用的 Logstash 版本低于 1.3.0，你只能用 bin/logstash -v 来代替。*

- --debug

输出更多的调试日志。

*小贴士：如果你使用的 Logstash 版本低于 1.3.0，你只能用 bin/logstash -vv 来代替。*

# 标准输入

最好使用一个配置文件进行运行

## 配置示例

```
input {
    stdin {
        add_field => {"key" => "value"}
        codec => "plain"
        tags => ["add"]
        type => "std"
    }
}
output {
    stdout {
        codec=>rubydebug
    }
}
```

### 输出内容

```
{
    "@timestamp" => 2018-11-22T12:59:34.166Z,
      "@version" => "1",
          "host" => "izwz99gyct1a1rh6iblyucz",
       "message" => "helloworld",
          "type" => "std",
           "key" => "value",
          "tags" => [
        [0] "add"
    ]
}
```

## 常用用法

```
input {
    stdin {
        type => "web"
    }
}
filter {
    if [type] == "web" {
        grok {
            match => ["message", %{COMBINEDAPACHELOG}]
        }
    }
}
output {
    if "_grokparsefailure" in [tags] {
        nagios_nsca {
            nagios_status => "1"
        }
    } else {
        elasticsearch {
        }
    }
}
```

# 读取文件

Logstash使用一个名叫*FileWatch*的Ruby Gem库来监听文件变化。这个库支持glob展开文件路径，而且会记录一个叫*.sincedb*的数据库文件来跟踪被监听的日志文件的当前读取位置。所以，不要担心logstash会漏过你的数据。

## 配置示例

```
input
    file {
        path => ["/var/log/*.log", "/var/log/message"]
        type => "system"
        start_position => "beginning"
    }
}
```

## 解释

有一些比较有用的配置项，可以用来指定*FileWatch*库的行为：

- discover_interval

logstash每隔多久去检查一次被监听的`path`下是否有新文件。默认值是15秒。

- 排除

不想被监听的文件可以排除出去，这里跟`path`一样支持glob展开。

- sincedb_path

如果你不想用默认的`$HOME/.sincedb`（Windows平台上在`C:\Windows\System32\config\systemprofile\.sincedb`），可以通过这个配置定义sincedb文件到其他位置。

- sincedb_write_interval

logstash每隔多久写一次sincedb文件，默认是15秒。

- stat_interval

logstash每隔多久检查一次被监听文件状态（是否有更新），默认是1秒。

- START_POSITION

logstash从什么位置开始读取文件数据，默认是结束位置，也就是说logstash进程会以类似`tail -F`的形式运行。如果你是要导入原有数据，把这个设定改成“开始”，logstash进程就从头开始读取，有点类似`cat`，但是读到最后一行不会终止，而是继续变成`tail -F`。

## 注意

1. 通常你要导入原有数据进Elasticsearch的话，你还需要[过滤/日期](https://doc.yonyoucloud.com/doc/logstash-best-practice-cn/filter/date.html)插件来修改默认的“@timestamp”字段值。稍后会学习这方面的知识。
2. *FileWatch*只请立即获取iTunes文件的**绝对路径**，而且会不自动递归目录。所以有需要的话，请用数组方式都写明具体哪些文件。
3. *LogStash :: Inputs :: File只是*在进程运行的注册阶段初始化一个*FileWatch*对象。所以它不能支持类似fluentd那样的`path => "/path/to/%{+yyyy/MM/dd/hh}.log"`写法。达到相同目的，你只能写成`path => "/path/to/*/*/*/*.log"`。
4. `start_position` 仅在该文件从未被监听过的时候起作用。如果sincedb文件中已经有这个文件的inode记录了，那么logstash依然会从记录过的pos开始读取数据。所以重复测试的时候每回需要删除sincedb文件。
5. 因为windows平台上没有inode的概念，Logstash某些版本在windows平台上监听文件不是很靠谱.windows平台上，推荐考虑使用nxlog作为收集端，参阅本书[稍后](https://doc.yonyoucloud.com/doc/logstash-best-practice-cn/ecosystem/nxlog.html)章节。

# 读取网络数据（TCP）

未来你可能会用Redis服务器或者其他的消息队列系统来作为logstash broker的角色。不过Logstash其实也有自己的TCP / UDP插件，在临时任务的时候，也算能用，尤其是测试环境。

*小贴士：虽然LogStash::Inputs::TCP用Ruby的Socket和OpenSSL库实现了高级的SSL功能，但Logstash本身只能在SizedQueue中缓存20个事件。这就是我们建议在生产环境中换用其他消息队列的原因。*

## 配置示例

```
input {
    tcp {
        port => 8888
        mode => "server"
        ssl_enable => false
    }
}
```

## 常见场景

目前来看，`LogStash::Inputs::TCP`最常见的用法就是配合`nc`命令导入旧数据。在启动logstash进程后，在另一个终端运行如下命令即可导入数据：

```
# nc 127.0.0.1 8888 < olddata
```

这种做法比用`LogStash::Inputs::File`好，因为当nc命令结束，我们就知道数据导入完毕了。而用输入/文件方式，logstash进程还会一直等待新数据输入被监听的文件，不能直接看出是否任务完成了。



# 生成测试数据(Generator)

实际运行的时候这个插件是派不上用途的，但这个插件依然是非常重要的插件之一。因为每一个使用 ELK stack 的运维人员都应该清楚一个道理：数据是支持操作的唯一真理（否则你也用不着 ELK）。所以在上线之前，你一定会需要在自己的实际环境中，测试 Logstash 和 Elasticsearch 的性能状况。这时候，这个用来生成测试数据的插件就有用了！

## 配置示例

```
input {
    generator {
        count => 10000000
        message => '{"key1":"value1","key2":[1,2],"key3":{"subkey1":"subvalue1"}}'
        codec => json
    }
}
```

插件的默认生成数据，message 内容是 "hello world"。你可以根据自己的实际需要这里来写其他内容。

## 使用方式

做测试有两种主要方式：

- 配合 LogStash::Outputs::Null

inputs/generator 是无中生有，output/null 则是锯嘴葫芦。事件流转到这里直接就略过，什么操作都不做。相当于只测试 Logstash 的 pipe 和 filter 效率。测试过程非常简单：

```
$ time ./bin/logstash -f generator_null.conf
real    3m0.864s
user    3m39.031s
sys        0m51.621s

# 自己的配置
real    0m46.086s
user    0m22.083s
sys     0m0.663s
```

- 使用 pv 命令配合 LogStash::Outputs::Stdout 和 LogStash::Codecs::Dots

上面的这种方式虽然想法挺好，不过有个小漏洞：logstash 是在 JVM 上运行的，有一个明显的启动时间，运行也有一段事件的预热后才算稳定运行。所以，要想更真实的反应 logstash 在长期运行时候的效率，还有另一种方法：

```
output {
    stdout {
        codec => dots
    }
}
```

LogStash::Codecs::Dots 也是一个另类的 codec 插件，他的作用是：把每个 event 都变成一个点(`.`)。这样，在输出的时候，就变成了一个一个的 `.` 在屏幕上。显然这也是一个为了测试而存在的插件。

下面就要介绍 pv 命令了。这个命令的作用，就是作实时的标准输入、标准输出监控。我们这里就用它来监控标准输出：

```
$ ./bin/logstash -f generator_dots.conf | pv -abt > /dev/null
2.2MiB 0:03:00 [12.5kiB/s]
```

可以很明显的看到在前几秒中，速度是 0 B/s，因为 JVM 还没启动起来呢。开始运行的时候，速度依然不快。慢慢增长到比较稳定的状态，这时候的才是你需要的数据。

这里单位是 B/s，但是因为一个 event 就输出一个 `.`，也就是 1B。所以 12.5kiB/s 就相当于是 12.5k event/s。

*注：如果你在 CentOS 上通过 yum 安装的 pv 命令，版本较低，可能还不支持 -a 参数。单纯靠 -bt 参数看起来还是有点累的。*

## 额外的话

既然单独花这么一节来说测试，这里想额外谈谈一个很常见的话题： *ELK 的性能怎么样？*

**其实这压根就是一个不正确的提问**。ELK 并不是一个软件而是一个并不耦合的套件。所以，我们需要分拆开讨论这三个软件的性能如何？怎么优化？

- LogStash 的性能，是最让新人迷惑的地方。因为 LogStash 本身并不维护队列，所以整个日志流转中任意环节的问题，都可能看起来像是 LogStash 的问题。这里，需要熟练使用本节说的测试方法，针对自己的每一段配置，都确定其性能。另一方面，就是本书之前提到过的，LogStash 给自己的线程都设置了单独的线程名称，你可以在 `top -H` 结果中查看具体线程的负载情况。
- Elasticsearch 的性能。这里最需要强调的是：Elasticsearch 是一个分布式系统。从来没有分布式系统要跟人比较单机处理能力的说法。所以，更需要关注的是：在确定的单机处理能力的前提下，性能是否能做到线性扩展。当然，这不意味着说提高处理能力只能靠加机器了——有效利用 mapping API 是非常重要的。不过暂时就在这里讲述了。
- Kibana 的性能。通常来说，Kibana 只是一个单页 Web 应用，只需要 nginx 发布静态文件即可，没什么性能问题。页面加载缓慢，基本上是因为 Elasticsearch 的请求响应时间本身不够快导致的。不过一定要细究的话，也能找出点 Kibana 本身性能相关的话题：因为 Kibana3 默认是连接固定的一个 ES 节点的 IP 端口的，所以这里会涉及一个浏览器的同一 IP 并发连接数的限制。其次，就是 Kibana 用的 AngularJS 使用了 Promise.then 的方式来处理 HTTP 请求响应。这是异步的。



# 读取 Syslog 数据

syslog 可能是运维领域最流行的数据传输协议了。当你想从设备上收集系统日志的时候，syslog 应该会是你的第一选择。尤其是网络设备，比如思科 —— syslog 几乎是唯一可行的办法。

我们这里不解释如何配置你的 `syslog.conf`, `rsyslog.conf` 或者 `syslog-ng.conf` 来发送数据，而只讲如何把 logstash 配置成一个 syslog 服务器来接收数据。

有关 `rsyslog` 的用法，稍后的[类型项目](https://doc.yonyoucloud.com/doc/logstash-best-practice-cn/dive_into/similar_projects.md)一节中，会有更详细的介绍。

## 配置示例

```
input {
  syslog {
    port => "514"
  }
}
```

## 运行结果

作为最简单的测试，我们先暂停一下本机的 `syslogd` (或 `rsyslogd` )进程，然后启动 logstash 进程（这样就不会有端口冲突问题）。现在，本机的 syslog 就会默认发送到 logstash 里了。我们可以用自带的 `logger` 命令行工具发送一条 "Hello World"信息到 syslog 里（即 logstash 里）。看到的 logstash 输出像下面这样：

```ruby
{
           "message" => "Hello World",
          "@version" => "1",
        "@timestamp" => "2014-08-08T09:01:15.911Z",
              "host" => "127.0.0.1",
          "priority" => 31,
         "timestamp" => "Aug  8 17:01:15",
         "logsource" => "raochenlindeMacBook-Air.local",
           "program" => "com.apple.metadata.mdflagwriter",
               "pid" => "381",
          "severity" => 7,
          "facility" => 3,
    "facility_label" => "system",
    "severity_label" => "Debug"
}
```

## 解释

Logstash 是用 `UDPSocket`, `TCPServer` 和 `LogStash::Filters::Grok` 来实现 `LogStash::Inputs::Syslog` 的。所以你其实可以直接用 logstash 配置实现一样的效果：

```
input {
  tcp {
    port => "8514"
  }
}
filter {
  grok {
    match => ["message", %{SYSLOGLINE} ]
  }
  syslog_pri { }
}
```

## 最佳实践

**建议在使用 LogStash::Inputs::Syslog 的时候走 TCP 协议来传输数据。**

因为具体实现中，UDP 监听器只用了一个线程，而 TCP 监听器会在接收每个连接的时候都启动新的线程来处理后续步骤。

如果你已经在使用 UDP 监听器收集日志，用下行命令检查你的 UDP 接收队列大小：

```
# netstat -plnu | awk 'NR==1 || $4~/:514$/{print $2}'
Recv-Q
228096
```

228096 是 UDP 接收队列的默认最大大小，这时候 linux 内核开始丢弃数据包了！

**强烈建议使用LogStash::Inputs::TCP和 LogStash::Filters::Grok 配合实现同样的 syslog 功能！**

虽然 LogStash::Inputs::Syslog 在使用 TCPServer 的时候可以采用多线程处理数据的接收，但是在同一个客户端数据的处理中，其 grok 和 date 是一直在该线程中完成的，这会导致总体上的处理性能几何级的下降 —— 经过测试，TCPServer 每秒可以接收 50000 条数据，而在同一线程中启用 grok 后每秒只能处理 5000 条，再加上 date 只能达到 500 条！

才将这两步拆分到 filters 阶段后，logstash 支持对该阶段插件单独设置多线程运行，大大提高了总体处理性能。在相同环境下， `logstash -f tcp.conf -w 20` 的测试中，总体处理性能可以达到每秒 30000 条数据！

*注：测试采用 logstash 作者提供的 yes "<44>May 19 18:30:17 snack jls: foo bar 32" | nc localhost 3000命令。出处见：https://github.com/jordansissel/experiments/blob/master/ruby/jruby-netty/syslog-server/Makefile*

### 小贴士

如果你实在没法切换到 TCP 协议，你可以自己写程序，或者使用其他基于异步 IO 框架(比如 libev )的项目。下面是一个简单的异步 IO 实现 UDP 监听数据输入 Elasticsearch 的示例：

<https://gist.github.com/chenryn/7c922ac424324ee0d695>



# 读取 Redis 数据

Redis 服务器是 logstash 官方推荐的 broker 选择。Broker 角色也就意味着会同时存在输入和输出俩个插件。这里我们先学习输入插件。

`LogStash::Inputs::Redis` 支持三种 *data_type*（实际上是*redis_type*），不同的数据类型会导致实际采用不同的 Redis 命令操作：

- list => BLPOP
- channel => SUBSCRIBE
- pattern_channel => PSUBSCRIBE

注意到了么？**这里面没有 GET 命令！**

Redis 服务器通常都是用作 NoSQL 数据库，不过 logstash 只是用来做消息队列。所以不要担心 logstash 里的 Redis 会撑爆你的内存和磁盘。

## 配置示例

```
input {
    redis {
        data_type => "pattern_channel"
        key => "logstash-*"
        host => "192.168.0.2"
        port => 6379
        threads => 5
    }
}
```

## 使用方式

### 基本方法

首先确认你设置的 host 服务器上已经运行了 redis-server 服务，然后打开终端运行 logstash 进程等待输入数据，然后打开另一个终端，输入 `redis-cli` 命令(先安装好 redis 软件包)，在交互式提示符后面输入`PUBLISH logstash-demochan "hello world"`：

```
# redis-cli
127.0.0.1:6379> PUBLISH logstash-demochan "hello world"
```

你会在第一个终端里看到 logstash 进程输出类似下面这样的内容：

```ruby
{
       "message" => "hello world",
      "@version" => "1",
    "@timestamp" => "2014-08-08T16:26:29.399Z"
}
```

注意：这个事件里没有 **host** 字段！（或许这算是 bug……）

### 输入 JSON 数据

如果你想通过 redis 的频道给 logstash 事件添加更多字段，直接向频道发布 JSON 字符串就可以了。 `LogStash::Inputs::Redis` 会直接把 JSON 转换成事件。

继续在第二个终端的交互式提示符下输入如下内容：

```
127.0.0.1:6379> PUBLISH logstash-chan '{"message":"hello world","@version":"1","@timestamp":"2014-08-08T16:34:21.865Z","host":"raochenlindeMacBook-Air.local","key1":"value1"}'
```

你会看到第一个终端里的 logstash 进程随即也返回新的内容，如下所示：

```ruby
{
       "message" => "hello world",
      "@version" => "1",
    "@timestamp" => "2014-08-09T00:34:21.865+08:00",
          "host" => "raochenlindeMacBook-Air.local",
          "key1" => "value1"
}
```

看，新的字段出现了！现在，你可以要求开发工程师直接向你的 redis 频道发送信息好了，一切自动搞定。

### 小贴士

这里我们建议的是使用 *pattern_channel* 作为输入插件的 *data_type* 设置值。因为实际使用中，你的 redis 频道可能有很多不同的 *keys*，一般命名成 *logstash-chan-%{type}* 这样的形式。这时候 *pattern_channel* 类型就可以帮助你一次订阅全部 logstash 相关频道！

## 扩展方式

如上段"小贴士"提到的，之前两个使用场景采用了同样的配置，即数据类型为频道发布订阅方式。这种方式在需要扩展 logstash 成多节点集群的时候，会出现一个问题：**通过频道发布的一条信息，会被所有订阅了该频道的 logstash 进程同时接收到，然后输出重复内容！**

*你可以尝试再做一次上面的实验，这次在两个终端同时启动 logstash -f redis-input.conf 进程，结果会是两个终端都输出消息。*

这种时候，就需要用 *list* 类型。在这种类型下，数据输入到 redis 服务器上暂存，logstash 则连上 redis 服务器取走 (`BLPOP` 命令，所以只要 logstash 不堵塞，redis 服务器上也不会有数据堆积占用空间)数据。

### 配置示例

```
input {
    redis {
        batch_count => 1
        data_type => "list"
        key => "logstash-list"
        host => "192.168.0.2"
        port => 6379
        threads => 5
    }
}
```

### 使用方式

这次我们同时在两个终端运行 `logstash -f redis-input-list.conf` 进程。然后在第三个终端里启动 redis-cli 命令交互：

```
$ redis-cli 
127.0.0.1:6379> RPUSH logstash-list "hello world"
(integer) 1
```

这时候你可以看到，只有一个终端输出了结果。

连续 `RPUSH` 几次，可以看到两个终端近乎各自输出一半条目。

### 小贴士

RPUSH 支持 batch 方式，修改 logstash 配置中的 `batch_count` 值，作为示例这里只改到 2，实际运用中可以更大(事实上 `LogStash::Outputs::Redis` 对应这点的 `batch_event` 配置默认值就是 50)。

重启 logstash 进程后，redis-cli 命令中改成如下发送：

```
127.0.0.1:6379> RPUSH logstash-list "hello world" "hello world" "hello world" "hello world" "hello world" "hello world"
(integer) 3
```

可以看到，两个终端也各自输出一部分结果。而你只用了一次 RPUSH 命令。

## 推荐阅读

- [http://redis.io](http://redis.io/)



# collectd简述

collectd 是一个守护(daemon)进程，用来收集系统性能和提供各种存储方式来存储不同值的机制。它会在系统运行和存储信息时周期性的统计系统的相关统计信息。利用这些信息有助于查找当前系统性能瓶颈（如作为性能分析 `performance analysis`）和预测系统未来的 load（如能力部署`capacity planning`）等

下面简单介绍一下: collectd的部署以及与logstash对接的相关配置实例

## collectd的安装

### 解决依赖

```
rpm -ivh "http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"
yum -y install libcurl libcurl-devel rrdtool rrdtool-devel perl-rrdtool rrdtool-prel libgcrypt-devel gcc make gcc-c++ liboping liboping-devel perl-CPAN net-snmp net-snmp-devel
```

### 源码安装collectd

```
wget http://collectd.org/files/collectd-5.4.1.tar.gz
tar zxvf collectd-5.4.1.tar.gz
cd collectd-5.4.1
./configure --prefix=/usr/local/software/collectd --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib --mandir=/usr/share/man --enable-all-plugins

make && make install
```

### 安装启动脚本

```
cp contrib/redhat/init.d-collectd /etc/init.d/collectd
chmod +x /etc/init.d/collectd
```

### 启动collectd

```
service collectd start
```

## collectd的配置

以下配置可以实现对服务器基本的**CPU、内存、网卡流量、磁盘 IO 以及磁盘空间占用**情况的监控:

```
Hostname "host.example.com"
LoadPlugin interface
LoadPlugin cpu
LoadPlugin memory
LoadPlugin network
LoadPlugin df
LoadPlugin disk
<Plugin interface>
    Interface "eth0"
    IgnoreSelected false
</Plugin>
<Plugin network>
    <Server "10.0.0.1" "25826"> ## logstash 的 IP 地址和 collectd 的数据接收端口号
    </Server>
</Plugin>
```

## logstash的配置

以下配置实现通过 logstash 监听 `25826` 端口,接收从 collectd 发送过来的各项检测数据:

### 示例一：

```
input {
 collectd {
    port => 25826 ## 端口号与发送端对应
    type => collectd
}
```

### 示例二：（推荐）

```
udp {
    port => 25826
    buffer_size => 1452
    workers => 3          # Default is 2
    queue_size => 30000   # Default is 2000
    codec => collectd { }
    type => "collectd"
}
```

## 运行结果

下面是简单的一个输出结果：

```
{
  "_index": "logstash-2014.12.11",
  "_type": "collectd",
  "_id": "dS6vVz4aRtK5xS86kwjZnw",
  "_score": null,
  "_source": {
    "host": "host.example.com",
    "@timestamp": "2014-12-11T06:28:52.118Z",
    "plugin": "interface",
    "plugin_instance": "eth0",
    "collectd_type": "if_packets",
    "rx": 19147144,
    "tx": 3608629,
    "@version": "1",
    "type": "collectd",
    "tags": [
      "_grokparsefailure"
    ]
  },
  "sort": [
    1418279332118
  ]
}
```

## 参考资料

- collectd支持收集的数据类型： <http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=README>
- collectd收集各数据类型的配置参考资料：<http://collectd.org/documentation/manpages/collectd.conf.5.shtml>
- collectd简单配置文件示例： <https://gist.github.com/untergeek/ab85cb86a9bf39f1fc6d>



# 编码插件(Codec)

Codec 是 logstash 从 1.3.0 版开始新引入的概念(*Codec* 来自 *Co*der/*dec*oder 两个单词的首字母缩写)。

在此之前，logstash 只支持纯文本形式输入，然后以*过滤器*处理它。但现在，我们可以在*输入* 期处理不同类型的数据，这全是因为有了 **codec** 设置。

所以，这里需要纠正之前的一个概念。Logstash 不只是一个`input | filter | output` 的数据流，而是一个 `input | decode | filter | encode | output` 的数据流！*codec* 就是用来 decode、encode 事件的。

codec 的引入，使得 logstash 可以更好更方便的与其他有自定义数据格式的运维产品共存，比如 graphite、fluent、netflow、collectd，以及使用 msgpack、json、edn 等通用数据格式的其他产品等。

事实上，我们在第一个 "hello world" 用例中就已经用过 *codec* 了 —— *rubydebug* 就是一种 *codec*！虽然它一般只会用在 stdout 插件中，作为配置测试或者调试的工具。

*小贴士：这个五段式的流程说明源自 Perl 版的 Logstash (后来改名叫 Message::Passing 模块)的设计。本书最后会对该模块稍作介绍。*



# 采用 JSON 编码

在早期的版本中，有一种降低 logstash 过滤器的 CPU 负载消耗的做法盛行于社区(在当时的 cookbook 上有专门的一节介绍)：**直接输入预定义好的 JSON 数据，这样就可以省略掉 filter/grok 配置！**

这个建议依然有效，不过在当前版本中需要稍微做一点配置变动 —— 因为现在有专门的 *codec* 设置。

## 配置示例

社区常见的示例都是用的 Apache 的 customlog。不过我觉得 Nginx 是一个比 Apache 更常用的新型 web 服务器，所以我这里会用 nginx.conf 做示例：

```
logformat json '{"@timestamp":"$time_iso8601",'
               '"@version":"1",'
               '"host":"$server_addr",'
               '"client":"$remote_addr",'
               '"size":$body_bytes_sent,'
               '"responsetime":$request_time,'
               '"domain":"$host",'
               '"url":"$uri",'
               '"status":"$status"}';
access_log /var/log/nginx/access.log_json json;
```

*注意：在 $request_time 和 $body_bytes_sent 变量两头没有双引号 "，这两个数据在 JSON 里应该是数值类型！*

重启 nginx 应用，然后修改你的 input/file 区段配置成下面这样：

```
input {
    file {
        path => "/var/log/nginx/access.log_json""
        codec => "json"
    }
}
```

## 运行结果

下面访问一下你 nginx 发布的 web 页面，然后你会看到 logstash 进程输出类似下面这样的内容：

```ruby
{
      "@timestamp" => "2014-03-21T18:52:25.000+08:00",
        "@version" => "1",
            "host" => "raochenlindeMacBook-Air.local",
          "client" => "123.125.74.53",
            "size" => 8096,
    "responsetime" => 0.04,
          "domain" => "www.domain.com",
             "url" => "/path/to/file.suffix",
          "status" => "200"
}
```

## 小贴士

对于一个 web 服务器的访问日志，看起来已经可以很好的工作了。不过如果 Nginx 是作为一个代理服务器运行的话，访问日志里有些变量，比如说 `$upstream_response_time`，可能不会一直是数字，它也可能是一个 `"-"` 字符串！这会直接导致 logstash 对输入数据验证报异常。

有两个办法解决这个问题：

1. 用 `sed` 在输入之前先替换 `-` 成 `0`。

运行 logstash 进程时不再读取文件而是标准输入，这样命令就成了下面这个样子：

```
tail -F /var/log/nginx/proxy_access.log_json \
    | sed 's/upstreamtime":-/upstreamtime":0/' \
    | /usr/local/logstash/bin/logstash -f /usr/local/logstash/etc/proxylog.conf
```

1. 日志格式中统一记录为字符串格式(即都带上双引号 `"`)，然后再在 logstash 中用 `filter/mutate` 插件来变更应该是数值类型的字符字段的值类型。

有关 `LogStash::Filters::Mutate` 的内容，本书稍后会有介绍。

# 合并多行数据（多）

有些时候，应用程序调试日志会包含非常丰富的内容，为一个事件打印出很多行内容。这种日志通常都很难通过命令行解析的方式做分析。

而logstash正为此准备好了*codec / multiline*插件！

*小贴士：multiline插件也可以用于其他类似的堆栈式信息，比如linux的内核日志。*

## 配置示例

```
input {
    stdin {
        codec => multiline {
            pattern => "^\["
            negate => true
            what => "previous"
        }
    }
}
```

## 运行结果

运行logstash进程，然后在等待输入的终端中输入如下几行数据：

```
[Aug/08/08 14:54:03] hello world
[Aug/08/09 14:54:04] hello logstash
    hello best practice
    hello raochenlin
[Aug/08/10 14:54:05] the end
```

你会发现logstash输出下面这样的返回：

```ruby
{
    "@timestamp" => "2014-08-09T13:32:03.368Z",
       "message" => "[Aug/08/08 14:54:03] hello world\n",
      "@version" => "1",
          "host" => "raochenlindeMacBook-Air.local"
}
{
    "@timestamp" => "2014-08-09T13:32:24.359Z",
       "message" => "[Aug/08/09 14:54:04] hello logstash\n\n    hello best practice\n\n    hello raochenlin\n",
      "@version" => "1",
          "tags" => [
        [0] "multiline"
    ],
          "host" => "raochenlindeMacBook-Air.local"
}
```

你看，后面这个事件，在“message”字段里存储了三行数据！

*小贴士：你可能注意到输出的事件中都没有最后的“the end”字符串。这是因为你最后输入的回车符\n并不匹配设定的^\[正则表达式，logstash还得等下一行数据直到匹配成功后才会输出这个事件。*

## 解释

其实这个插件的原理很简单，就是把当前行的数据添加到前面一行后面,,新直到进的当前行匹配`^\[`正则为止。

这个正则还可以用grok表达式，稍后你就会学习这方面的内容。

## Log4J的另一种方案

说到应用程序日志，log4j肯定是第一个被大家想到的。使用`codec/multiline`也确实是一个办法。

不过，如果你本事就是开发人员，或者可以推动程序修改变更的话，logstash还提供了另一种处理log4j的方式：[input / log4j](http://logstash.net/docs/1.4.2/inputs/log4j)。与`codec/multiline`不同，这个插件是直接调用了`org.apache.log4j.spi.LoggingEvent`处理TCP端口接收的数据。

## 推荐阅读

<https://github.com/elasticsearch/logstash/blob/master/patterns/java>



# Grok 正则捕获

Grok 是 Logstash 最重要的插件。你可以在 grok 里预定义好命名正则表达式，在稍后(grok参数或者其他正则表达式里)引用它。

## 正则表达式语法

运维工程师多多少少都会一点正则。你可以在 grok 里写标准的正则，像下面这样：

```
\s+(?<request_time>\d+(?:\.\d+)?)\s+
```

*小贴士：这个正则表达式写法对于 Perl 或者 Ruby 程序员应该很熟悉了，Python 程序员可能更习惯写 (?P<name>pattern)，没办法，适应一下吧。*

现在给我们的配置文件添加第一个过滤器区段配置。配置要添加在输入和输出区段之间(logstash 执行区段的时候并不依赖于次序，不过为了自己看得方便，还是按次序书写吧)：

```
input {stdin{}}
filter {
    grok {
        match => {
            "message" => "\s+(?<request_time>\d+(?:\.\d+)?)\s+"
        }
    }
}
output {stdout{}}
```

运行 logstash 进程然后输入 "begin 123.456 end"，你会看到类似下面这样的输出：

```
{
         "message" => "begin 123.456 end",
        "@version" => "1",
      "@timestamp" => "2014-08-09T11:55:38.186Z",
            "host" => "raochenlindeMacBook-Air.local",
    "request_time" => "123.456"
}
```

漂亮！不过数据类型好像不太满意……*request_time* 应该是数值而不是字符串。

我们已经提过稍后会学习用 `LogStash::Filters::Mutate` 来转换字段值类型，不过在 grok 里，其实有自己的魔法来实现这个功能！

## Grok 表达式语法

Grok 支持把预定义的 *grok 表达式* 写入到文件中，官方提供的预定义 grok 表达式见：<https://github.com/logstash/logstash/tree/v1.4.2/patterns>。

**注意：在新版本的logstash里面，pattern目录已经为空，最后一个commit提示core patterns将会由logstash-patterns-core gem来提供，该目录可供用户存放自定义patterns**

下面是从官方文件中摘抄的最简单但是足够说明用法的示例：

```
USERNAME [a-zA-Z0-9._-]+
USER %{USERNAME}
```

**第一行，用普通的正则表达式来定义一个 grok 表达式；第二行，通过打印赋值格式，用前面定义好的 grok 表达式来定义另一个 grok 表达式。**

grok 表达式的打印复制格式的完整语法是下面这样的：

```
%{PATTERN_NAME:capture_name:data_type}
```

*小贴士：data_type 目前只支持两个值：int 和 float。*

所以我们可以改进我们的配置成下面这样：

```
filter {
    grok {
        match => {
            "message" => "%{WORD} %{NUMBER:request_time:float} %{WORD}"
        }
    }
}
```

重新运行进程然后可以得到如下结果：

```
{
         "message" => "begin 123.456 end",
        "@version" => "1",
      "@timestamp" => "2014-08-09T12:23:36.634Z",
            "host" => "raochenlindeMacBook-Air.local",
    "request_time" => 123.456
}
```

这次 *request_time* 变成数值类型了。

## 最佳实践

实际运用中，我们需要处理各种各样的日志文件，如果你都是在配置文件里各自写一行自己的表达式，就完全不可管理了。所以，我们建议是把所有的 grok 表达式统一写入到一个地方。然后用 *filter/grok* 的 `patterns_dir` 选项来指明。

如果你把 "message" 里所有的信息都 grok 到不同的字段了，数据实质上就相当于是重复存储了两份。所以你可以用 `remove_field` 参数来删除掉 *message* 字段，或者用 `overwrite` 参数来重写默认的 *message* 字段，只保留最重要的部分。

重写参数的示例如下：

```
filter {
    grok {
        patterns_dir => "/path/to/your/own/patterns"
        match => {
            "message" => "%{SYSLOGBASE} %{DATA:message}"
        }
        overwrite => ["message"]
    }
}
```

## 小贴士

### 多行匹配

在和 *codec/multiline* 搭配使用的时候，需要注意一个问题，grok 正则和普通正则一样，默认是不支持匹配回车换行的。就像你需要 `=~ //m` 一样也需要单独指定，具体写法是在表达式开始位置加 `(?m)` 标记。如下所示：

```
match => {
    "message" => "(?m)\s+(?<request_time>\d+(?:\.\d+)?)\s+"
}
```

### 多项选择

有时候我们会碰上一个日志有多种可能格式的情况。这时候要写成单一正则就比较困难，或者全用 `|` 隔开又比较丑陋。这时候，logstash 的语法提供给我们一个有趣的解决方式。

文档中，都说明 logstash/filters/grok 插件的 `match` 参数应该接受的是一个 Hash 值。但是因为早期的 logstash 语法中 Hash 值也是用 `[]` 这种方式书写的，所以其实现在传递 Array 值给 `match` 参数也完全没问题。所以，我们这里其实可以传递多个正则来匹配同一个字段：

```
match => [
    "message", "(?<request_time>\d+(?:\.\d+)?)",
    "message", "%{SYSLOGBASE} %{DATA:message}",
    "message", "(?m)%{WORD}"
]
```

logstash 会按照这个定义次序依次尝试匹配，到匹配成功为止。虽说效果跟用 `|` 分割写个大大的正则是一样的，但是可阅读性好了很多。

**最后也是最关键的，我强烈建议每个人都要使用 Grok Debugger 来调试自己的 grok 表达式。**

![grokdebugger](http://www.elasticsearch.org/content/uploads/2014/10/Screen-Shot-2014-10-22-at-00.37.37.png)

# 时间处理(Date)

之前章节已经提过，*filters/date* 插件可以用来转换你的日志记录中的时间字符串，变成 `LogStash::Timestamp`对象，然后转存到 `@timestamp` 字段里。

**注意：因为在稍后的 outputs/elasticsearch 中常用的 %{+YYYY.MM.dd} 这种写法必须读取 @timestamp 数据，所以一定不要直接删掉这个字段保留自己的字段，而是应该用 filters/date 转换后删除自己的字段！**

这在导入旧数据的时候固然非常有用，而在实时数据处理的时候同样有效，因为一般情况下数据流程中我们都会有缓冲区，导致最终的实际处理时间跟事件产生时间略有偏差。

*小贴士：个人强烈建议打开 Nginx 的 access_log 配置项的 buffer 参数，对极限响应性能有极大提升！*

## 配置示例

*filters/date* 插件支持五种时间格式：

### ISO8601

类似 "2011-04-19T03:44:01.103Z" 这样的格式。具体Z后面可以有 "08:00"也可以没有，".103"这个也可以没有。常用场景里来说，Nginx 的 *log_format* 配置里就可以使用 `$time_iso8601` 变量来记录请求时间成这种格式。

### UNIX

UNIX 时间戳格式，记录的是从 1970 年起始至今的总秒数。Squid 的默认日志格式中就使用了这种格式。

### UNIX_MS

这个时间戳则是从 1970 年起始至今的总毫秒数。据我所知，JavaScript 里经常使用这个时间格式。

### TAI64N

TAI64N 格式比较少见，是这个样子的：`@4000000052f88ea32489532c`。我目前只知道常见应用中， qmail 会用这个格式。

### Joda-Time 库

Logstash 内部使用了 Java 的 Joda 时间库来作时间处理。所以我们可以使用 Joda 库所支持的时间格式来作具体定义。Joda 时间格式定义见下表：

#### 时间格式

| Symbol | Meaning                     | Presentation | Examples                           |
| ------ | --------------------------- | ------------ | ---------------------------------- |
| G      | era                         | text         | AD                                 |
| C      | century of era (>=0)        | number       | 20                                 |
| Y      | year of era (>=0)           | year         | 1996                               |
| x      | weekyear                    | year         | 1996                               |
| w      | week of weekyear            | number       | 27                                 |
| e      | day of week                 | number       | 2                                  |
| E      | day of week                 | text         | Tuesday; Tue                       |
| y      | year                        | year         | 1996                               |
| D      | day of year                 | number       | 189                                |
| M      | month of year               | month        | July; Jul; 07                      |
| d      | day of month                | number       | 10                                 |
| a      | halfday of day              | text         | PM                                 |
| K      | hour of halfday (0~11)      | number       | 0                                  |
| h      | clockhour of halfday (1~12) | number       | 12                                 |
| H      | hour of day (0~23)          | number       | 0                                  |
| k      | clockhour of day (1~24)     | number       | 24                                 |
| m      | minute of hour              | number       | 30                                 |
| s      | second of minute            | number       | 55                                 |
| S      | fraction of second          | number       | 978                                |
| z      | time zone                   | text         | Pacific Standard Time; PST         |
| Z      | time zone offset/id         | zone         | -0800; -08:00; America/Los_Angeles |
| '      | escape for text             | delimiter    |                                    |
| ''     | single quote                | literal      | '                                  |

<http://joda-time.sourceforge.net/apidocs/org/joda/time/format/DateTimeFormat.html>

下面我们写一个 Joda 时间格式的配置作为示例：

```
filter {
    grok {
        match => ["message", "%{HTTPDATE:logdate}"]
    }
    date {
        match => ["logdate", "dd/MMM/yyyy:HH:mm:ss Z"]
    }
}
```

**注意：时区偏移量只需要用一个字母 Z 即可。**

## 时区问题的解释

很多中国用户经常提一个问题：为什么 @timestamp 比我们早了 8 个小时？怎么修改成北京时间？

其实，Elasticsearch 内部，对时间类型字段，是**统一采用 UTC 时间，存成 long 长整形数据的**！对日志统一采用 UTC 时间存储，是国际安全/运维界的一个通识——欧美公司的服务器普遍广泛分布在多个时区里——不像中国，地域横跨五个时区却只用北京时间。

对于页面查看，ELK 的解决方案是在 Kibana 上，读取浏览器的当前时区，然后在页面上转换时间内容的**显示**。

所以，建议大家接受这种设定。否则，即便你用 `.getLocalTime` 修改，也还要面临在 Kibana 上反过去修改，以及 Elasticsearch 原有的 `["now-1h" TO "now"]` 这种方便的搜索语句无法正常使用的尴尬。

以上，请读者自行斟酌。

# 数据修改(Mutate)

*filters/mutate* 插件是 Logstash 另一个重要插件。它提供了丰富的基础类型数据处理能力。包括类型转换，字符串处理和字段处理等。

## 类型转换

类型转换是 *filters/mutate* 插件最初诞生时的唯一功能。其应用场景在之前 [Codec/JSON](https://doc.yonyoucloud.com/doc/logstash-best-practice-cn/codec/json.html) 小节已经提到。

可以设置的转换类型包括："integer"，"float" 和 "string"。示例如下：

```
filter {
    mutate {
        convert => ["request_time", "float"]
    }
}
```

**注意：mutate 除了转换简单的字符值，还支持对数组类型的字段进行转换，即将 ["1","2"] 转换成 [1,2]。但不支持对哈希类型的字段做类似处理。有这方面需求的可以采用稍后讲述的 filters/ruby 插件完成。**

## 字符串处理

- gsub

仅对字符串类型字段有效

```
    gsub => ["urlparams", "[\\?#]", "_"]
```

- split

```
filter {
    mutate {
        split => ["message", "|"]
    }
}
```

随意输入一串以`|`分割的字符，比如 "123|321|adfd|dfjld*=123"，可以看到如下输出：

```ruby
{
    "message" => [
        [0] "123",
        [1] "321",
        [2] "adfd",
        [3] "dfjld*=123"
    ],
    "@version" => "1",
    "@timestamp" => "2014-08-20T15:58:23.120Z",
    "host" => "raochenlindeMacBook-Air.local"
}
```

- join

仅对数组类型字段有效

我们在之前已经用 `split` 割切的基础再 `join` 回去。配置改成：

```
filter {
    mutate {
        split => ["message", "|"]
    }
    mutate {
        join => ["message", ","]
    }
}
```

filter 区段之内，是顺序执行的。所以我们最后看到的输出结果是：

```ruby
{
    "message" => "123,321,adfd,dfjld*=123",
    "@version" => "1",
    "@timestamp" => "2014-08-20T16:01:33.972Z",
    "host" => "raochenlindeMacBook-Air.local"
}
```

- merge

合并两个数组或者哈希字段。依然在之前 split 的基础上继续：

```
filter {
    mutate {
        split => ["message", "|"]
    }
    mutate {
        merge => ["message", "message"]
    }
}
```

我们会看到输出：

```ruby
{
       "message" => [
        [0] "123",
        [1] "321",
        [2] "adfd",
        [3] "dfjld*=123",
        [4] "123",
        [5] "321",
        [6] "adfd",
        [7] "dfjld*=123"
    ],
      "@version" => "1",
    "@timestamp" => "2014-08-20T16:05:53.711Z",
          "host" => "raochenlindeMacBook-Air.local"
}
```

如果 src 字段是字符串，会自动先转换成一个单元素的数组再合并。把上一示例中的来源字段改成 "host"：

```
filter {
    mutate {
        split => ["message", "|"]
    }
    mutate {
        merge => ["message", "host"]
    }
}
```

结果变成：

```ruby
{
       "message" => [
        [0] "123",
        [1] "321",
        [2] "adfd",
        [3] "dfjld*=123",
        [4] "raochenlindeMacBook-Air.local"
    ],
      "@version" => "1",
    "@timestamp" => "2014-08-20T16:07:53.533Z",
          "host" => [
        [0] "raochenlindeMacBook-Air.local"
    ]
}
```

看，目的字段 "message" 确实多了一个元素，但是来源字段 "host" 本身也由字符串类型变成数组类型了！

下面你猜，如果来源位置写的不是字段名而是直接一个字符串，会产生什么奇特的效果呢？

- strip
- lowercase
- uppercase

## 字段处理

- rename

重命名某个字段，如果目的字段已经存在，会被覆盖掉：

```
filter {
    mutate {
        rename => ["syslog_host", "host"]
    }
}
```

- update

更新某个字段的内容。如果字段不存在，不会新建。

- replace

作用和 update 类似，但是当字段不存在的时候，它会起到 `add_field` 参数一样的效果，自动添加新的字段。

## 执行次序

需要注意的是，filter/mutate 内部是有执行次序的。其次序如下：

```
    rename(event) if @rename
    update(event) if @update
    replace(event) if @replace
    convert(event) if @convert
    gsub(event) if @gsub
    uppercase(event) if @uppercase
    lowercase(event) if @lowercase
    strip(event) if @strip
    remove(event) if @remove
    split(event) if @split
    join(event) if @join
    merge(event) if @merge

    filter_matched(event)
```

而 `filter_matched` 这个 filters/base.rb 里继承的方法也是有次序的。

```
  @add_field.each do |field, value|
  end
  @remove_field.each do |field|
  end
  @add_tag.each do |tag|
  end
  @remove_tag.each do |tag|
  end
```

# GeoIP 地址查询归类

GeoIP 是最常见的免费 IP 地址归类查询库，同时也有收费版可以采购。GeoIP 库可以根据 IP 地址提供对应的地域信息，包括国别，省市，经纬度等，对于可视化地图和区域统计非常有用。

## 配置示例

```
filter {
    geoip {
        source => "message"
    }
}
```

## 运行结果

```ruby
{
       "message" => "183.60.92.253",
      "@version" => "1",
    "@timestamp" => "2014-08-07T10:32:55.610Z",
          "host" => "raochenlindeMacBook-Air.local",
         "geoip" => {
                      "ip" => "183.60.92.253",
           "country_code2" => "CN",
           "country_code3" => "CHN",
            "country_name" => "China",
          "continent_code" => "AS",
             "region_name" => "30",
               "city_name" => "Guangzhou",
                "latitude" => 23.11670000000001,
               "longitude" => 113.25,
                "timezone" => "Asia/Chongqing",
        "real_region_name" => "Guangdong",
                "location" => [
            [0] 113.25,
            [1] 23.11670000000001
        ]
    }
}
```

## 配置说明

GeoIP 库数据较多，如果你不需要这么多内容，可以通过 `fields` 选项指定自己所需要的。下例为全部可选内容：

```
filter {
    geoip {
        fields => ["city_name", "continent_code", "country_code2", "country_code3", "country_name", "dma_code", "ip", "latitude", "longitude", "postal_code", "region_name", "timezone"]
    }
}
```

需要注意的是：`geoip.location` 是 logstash 通过 `latitude` 和 `longitude` 额外生成的数据。所以，如果你是想要经纬度又不想重复数据的话，应该像下面这样做：

filter { geoip { fields => ["city_name", "country_code2", "country_name", "latitude", "longitude", "region_name"] remove_field => ["[geoip][latitude]", "[geoip][longitude]"] } } ```

## 小贴士

geoip 插件的 "source" 字段可以是任一处理后的字段，比如 "client_ip"，但是字段内容却需要小心！geoip 库内只存有公共网络上的 IP 信息，查询不到结果的，会直接返回 null，而 logstash 的 geoip 插件对 null 结果的处理是：**不生成对应的 geoip.字段。**

所以读者在测试时，如果使用了诸如 127.0.0.1, 172.16.0.1, 182.168.0.1, 10.0.0.1 等内网地址，会发现没有对应输出！



# JSON 编解码

在上一章，已经讲过在 codec 中使用 JSON 编码。但是，有些日志可能是一种复合的数据结构，其中只是一部分记录是 JSON 格式的。这时候，我们依然需要在 filter 阶段，单独启用 JSON 解码插件。

## 配置示例

```
filter {
    json {
        source => "message"
        target => "jsoncontent"
    }
}
```

## 运行结果

```
{
    "@version": "1",
    "@timestamp": "2014-11-18T08:11:33.000Z",
    "host": "web121.mweibo.tc.sinanode.com",
    "message": "{\"uid\":3081609001,\"type\":\"signal\"}",
    "jsoncontent": {
        "uid": 3081609001,
        "type": "signal"
    }
}
```

## 小贴士

如果不打算使用多层结构的话，删掉 `target` 配置即可。新的结果如下：

```
{
    "@version": "1",
    "@timestamp": "2014-11-18T08:11:33.000Z",
    "host": "web121.mweibo.tc.sinanode.com",
    "message": "{\"uid\":3081609001,\"type\":\"signal\"}",
    "uid": 3081609001,
    "type": "signal"
}
```

# split 拆分事件

上一章我们通过 multiline 插件将多行数据合并进一个事件里，那么反过来，也可以把一行数据，拆分成多个事件。这就是 split 插件。

## 配置示例

```
filter {
    split {
        field => "message"
        terminator => "#"
    }
}
```

## 运行结果

这个测试中，我们在 intputs/stdin 的终端中输入一行数据："test1#test2"，结果看到输出两个事件：

```
{
    "@version": "1",
    "@timestamp": "2014-11-18T08:11:33.000Z",
    "host": "web121.mweibo.tc.sinanode.com",
    "message": "test1"
}
{
    "@version": "1",
    "@timestamp": "2014-11-18T08:11:33.000Z",
    "host": "web121.mweibo.tc.sinanode.com",
    "message": "test2"
}
```

## 重要提示

split 插件中使用的是 yield 功能，其结果是 split 出来的新事件，会直接结束其在 filter 阶段的历程，也就是说写在 split 后面的其他 filter 插件都不起作用，进入到 output 阶段。所以，一定要保证 **split 配置写在全部 filter 配置的最后**。

使用了类似功能的还有 clone 插件。

*注：从 logstash-1.5.0beta1 版本以后修复该问题。*



# UserAgent 匹配归类

## 配置示例

```
filter {
    useragent {
        target => "ua"
        source => "useragent"
    }
}
```

# Key-Value 切分

在很多情况下，日志内容本身都是一个类似于 key-value 的格式，但是格式具体的样式却是多种多样的。logstash 提供 `filters/kv` 插件，帮助处理不同样式的 key-value 日志，变成实际的 LogStash::Event 数据。

## 配置示例

```
filter {
    ruby {
        init => "@kname = ['method','uri','verb']"
        code => "event.append(Hash[@kname.zip(event['request'].split(' '))])"
    }
    if [uri] {
        ruby {
            init => "@kname = ['url_path','url_args']"
            code => "event.append(Hash[@kname.zip(event['uri'].split('?'))])"
        }
        kv {
            prefix => "url_"
            source => "url_args"
            field_split => "&"
            remove_field => [ "url_args", "uri", "request" ]
        }
    }
}
```

## 解释

Nginx 访问日志中的 `$request`，通过这段配置，可以详细切分成 `method`, `url_path`, `verb`, `url_a`, `url_b` ...

# 随心所欲的 Ruby 处理

如果你稍微懂那么一点点 Ruby 语法的话，*filters/ruby* 插件将会是一个非常有用的工具。

比如你需要稍微修改一下 `LogStash::Event` 对象，但是又不打算为此写一个完整的插件，用 *filters/ruby* 插件绝对感觉良好。

## 配置示例

```ruby
filter {
    ruby {
        init => "@kname = ['client','servername','url','status','time','size','upstream','upstreamstatus','upstreamtime','referer','xff','useragent']"
        code => "event.append(Hash[@kname.zip(event['message'].split('|'))])"
    }
}
```

官网示例是一个比较有趣但是没啥大用的做法 —— 随机取消 90% 的事件。

所以上面我们给出了一个有用而且强大的实例。

## 解释

通常我们都是用 *filters/grok* 插件来捕获字段的，但是正则耗费大量的 CPU 资源，很容易成为 Logstash 进程的瓶颈。

而实际上，很多流经 Logstash 的数据都是有自己预定义的特殊分隔符的，我们可以很简单的直接切割成多个字段。

*filters/mutate* 插件里的 "split" 选项只能切成数组，后续很不方便使用和识别。而在 *filters/ruby* 里，我们可以通过 "init" 参数预定义好由每个新字段的名字组成的数组，然后在 "code" 参数指定的 Ruby 语句里通过两个数组的 zip 操作生成一个哈希并添加进数组里。短短一行 Ruby 代码，可以减少 50% 以上的 CPU 使用率。

*filters/ruby* 插件用途远不止这一点，下一节你还会继续见到它的身影。

## 更多实例

*2014 年 09 年 23 日新增*

```
filter{
    date {
        match => ["datetime" , "UNIX"]
    }
    ruby {
        code => "event.cancel if 5 * 24 * 3600 < (event['@timestamp']-::Time.now).abs"
    }
}
```

在实际运用中，我们几乎肯定会碰到出乎意料的输入数据。这都有可能导致 Elasticsearch 集群出现问题。

当数据格式发生变化，比如 UNIX 时间格式变成 UNIX_MS 时间格式，会导致 logstash 疯狂创建新索引，集群崩溃。

或者误输入过老的数据时，因为一般我们会 close 几天之前的索引以节省内存，必要时再打开。而直接尝试把数据写入被关闭的索引会导致内存问题。

这时候我们就需要提前校验数据的合法性。上面配置，就是用于过滤掉时间范围与当前时间差距太大的非法数据的。

# 数值统计(Metrics)

*filters/metrics* 插件是使用 Ruby 的 *Metriks* 模块来实现在内存里实时的计数和采样分析。该模块支持两个类型的数值分析：meter 和 timer。下面分别举例说明：

## Meter 示例(速率阈值检测)

web 访问日志的异常状态码频率是运维人员会非常关心的一个数据。通常我们的做法，是通过 logstash 或者其他日志分析脚本，把计数发送到 rrdtool 或者 graphite 里面。然后再通过 check_graphite 脚本之类的东西来检查异常并报警。

事实上这个事情可以直接在 logstash 内部就完成。比如如果最近一分钟 504 请求的个数超过 100 个就报警：

```
filter {
    metrics {
        meter => "error.%{status}"
        add_tag => "metric"
        ignore_older_than => 10
    }
    if "metric" in [tags] {
        ruby {
            code => "event.cancel if event['error.504.rate_1m'] * 60 < 100"
        }
    }
}
output {
    if "metric" in [tags] {
        exec {
            command => "echo \"Out of threshold: %{error.504.rate_1m}\""
        }
    }
}
```

这里需要注意 `*60` 的含义。

metriks 模块生成的 *rate_1m/5m/15m* 意思是：最近 1，5，15 分钟的**每秒**速率！

## Timer 示例(box and whisker 异常检测)

官版的 *filters/metrics* 插件只适用于 metric 事件的检查。由插件生成的新事件内部不存有来自 input 区段的实际数据信息。所以，要完成我们的百分比分布箱体检测，需要首先对代码稍微做几行变动，即在 metric 的 timer 事件里加一个属性，存储最近一个实际事件的数值：<https://github.com/chenryn/logstash/commit/bc7bf34caf551d8a149605cf28e7c5d33fae7458>

然后我们就可以用如下配置来探测异常数据了：

```
filter {
    metrics {
        timer => {"rt" => "%{request_time}"}
        percentiles => [25, 75]
        add_tag => "percentile"
    }
    if "percentile" in [tags] {
        ruby {
            code => "l=event['rt.p75']-event['rt.p25'];event['rt.low']=event['rt.p25']-l;event['rt.high']=event['rt.p75']+l"
        }
    }
}
output {
    if "percentile" in [tags] and ([rt.last] > [rt.high] or [rt.last] < [rt.low]) {
        exec {
            command => "echo \"Anomaly: %{rt.last}\""
        }
    }
}
```

*小贴士：有关 box and shisker plot 内容和重要性，参见《数据之魅》一书。*



# 标准输出(Stdout)

和之前 *inputs/stdin* 插件一样，*outputs/stdout* 插件也是最基础和简单的输出插件。同样在这里简单介绍一下，作为输出插件的一个共性了解。

## 配置示例

```
output {
    stdout {
        codec => rubydebug
        workers => 2
    }
}
```

## 解释

输出插件统一具有一个参数是 `workers`。Logstash 为输出做了多线程的准备。

其次是 codec 设置。codec 的作用在之前已经讲过。可能除了 `codecs/multiline` ，其他 codec 插件本身并没有太多的设置项。所以一般省略掉后面的配置区段。换句话说。上面配置示例的完全写法应该是：

```
output {
    stdout {
        codec => rubydebug {
        }
        workers => 2
    }
}
```

单就 *outputs/stdout* 插件来说，其最重要和常见的用途就是调试。所以在不太有效的时候，加上命令行参数 `-vv` 运行，查看更多详细调试信息。

# 保存成文件(File)

通过日志收集系统将分散在数百台服务器上的数据集中存储在某中心服务器上，这是运维最原始的需求。早年的 scribed ，甚至直接就把输出的语法命名为 `<store>`。Logstash 当然也能做到这点。

和 `LogStash::Inputs::File` 不同, `LogStash::Outputs::File` 里可以使用 sprintf format 格式来自动定义输出到带日期命名的路径。

## 配置示例

```
output {
    file {
        path => "/path/to/%{+yyyy/MM/dd/HH}/%{host}.log.gz"
        message_format => "%{message}"
        gzip => true
    }
}
```

## 解释

使用 *output/file* 插件首先需要注意的就是 `message_format` 参数。插件默认是输出整个 event 的 JSON 形式数据的。这可能跟大多数情况下使用者的期望不符。大家可能只是希望按照日志的原始格式保存就好了。所以需要定义为 `%{message}`，当然，前提是在之前的 *filter* 插件中，你没有使用 `remove_field` 或者 `update` 等参数删除或修改 `%{message}` 字段的内容。

另一个非常有用的参数是 gzip。gzip 格式是一个非常奇特而友好的格式。其格式包括有：

- 10字节的头，包含幻数、版本号以及时间戳
- 可选的扩展头，如原文件名
- 文件体，包括DEFLATE压缩的数据
- 8字节的尾注，包括CRC-32校验和以及未压缩的原始数据长度

这样 gzip 就可以一段一段的识别出来数据 —— **反过来说，也就是可以一段一段压缩了添加在后面！**

这对于我们流式添加数据简直太棒了！

*小贴士：你或许见过网络流传的 parallel 命令行工具并发处理数据的神奇文档，但在自己用的时候总见不到效果。实际上就是因为：文档中处理的 gzip 文件，可以分开处理然后再合并的。*





# 保存进 Elasticsearch

Logstash 早期有三个不同的 elasticsearch 插件。到 1.4.0 版本的时候，开发者彻底重写了 `LogStash::Outputs::Elasticsearch` 插件。从此，我们只需要用这一个插件，就能任意切换使用 Elasticsearch 集群支持的各种不同协议了。

## 配置示例

```
output {
    elasticsearch {
        host => "192.168.0.2"
        protocol => "http"
        index => "logstash-%{type}-%{+YYYY.MM.dd}"
        index_type => "%{type}"
        workers => 5
        template_overwrite => true
    }
}
```

## 解释

### 协议

现在，新插件支持三种协议： *node*，*http* 和 *transport*。

一个小集群里，使用 *node* 协议最方便了。Logstash 以 elasticsearch 的 client 节点身份(即不存数据不参加选举)运行。如果你运行下面这行命令，你就可以看到自己的 logstash 进程名，对应的 `node.role` 值是 **c**：

```
# curl 127.0.0.1:9200/_cat/nodes?v
host       ip      heap.percent ram.percent load node.role master name
local 192.168.0.102  7      c         -      logstash-local-1036-2012
local 192.168.0.2    7      d         *      Sunstreak
```

特别的，作为一个快速运行示例的需要，你还可以在 logstash 进程内部运行一个**内嵌**的 elasticsearch 服务器。内嵌服务器默认会在 `$PWD/data` 目录里存储索引。如果你想变更这些配置，在 `$PWD/elasticsearch.yml`文件里写自定义配置即可，logstash 会尝试自动加载这个文件。

对于拥有很多索引的大集群，你可以用 *transport* 协议。logstash 进程会转发所有数据到你指定的某台主机上。这种协议跟上面的 *node* 协议是不同的。*node* 协议下的进程是可以接收到整个 Elasticsearch 集群状态信息的，当进程收到一个事件时，它就知道这个事件应该存在集群内哪个机器的分片里，所以它就会直接连接该机器发送这条数据。而 *transport* 协议下的进程不会保存这个信息，在集群状态更新(节点变化，索引变化都会发送全量更新)时，就不会对所有的 logstash 进程也发送这种信息。更多 Elasticsearch 集群状态的细节，参阅<http://www.elasticsearch.org/guide>。

如果你已经有现成的 Elasticsearch 集群，但是版本跟 logstash 自带的又不太一样，建议你使用 *http* 协议。Logstash 会使用 POST 方式发送数据。

#### 小贴士

- Logstash 1.4.2 在 transport 和 http 协议的情况下是固定连接指定 host 发送数据。从 1.5.0 开始，host 可以设置数组，它会从节点列表中选取不同的节点发送数据，达到 Round-Robin 负载均衡的效果。
- Kibana4 强制要求 ES 全集群所有 node 版本在 1.4 以上，所以采用 node 方式发送数据的 logstash-1.4(携带的 Elasticsearch.jar 库是 1.1.1 版本) 会导致 Kibana4 无法运行，采用 Kibana4 的读者务必改用 http 方式。
- 开发者在 IRC freenode#logstash 频道里表示："高于 1.0 版本的 Elasticsearch 应该都能跟最新版 logstash 的 node 协议一起正常工作"。此信息仅供参考，请认真测试后再上线。

#### 性能问题

Logstash 1.4.2 在 http 协议下默认使用作者自己的 ftw 库，随同分发的是 0.0.39 版。该版本有[内存泄露问题](https://github.com/elasticsearch/logstash/issues/1604)，长期运行下输出性能越来越差！

解决办法：

1. 对性能要求不高的，可以在启动 logstash 进程时，配置环境变量ENV["BULK"]，强制采用 elasticsearch 官方 Ruby 库。命令如下：

   export BULK="esruby"

2. 对性能要求高的，可以尝试采用 logstash-1.5.0RC2 。新版的 outputs/elasticsearch 放弃了 ftw 库，改用了一个 JRuby 平台专有的 [Manticore 库](https://github.com/cheald/manticore/wiki/Performance)。根据测试，性能跟 ftw 比[相当接近](https://github.com/elasticsearch/logstash/pull/1777)。

3. 对性能要求极高的，可以手动更新 ftw 库版本，目前最新版是 0.0.42 版，据称内存问题在 0.0.40 版即解决。

### 模板

Elasticsearch 支持给索引预定义设置和 mapping(前提是你用的 elasticsearch 版本支持这个 API，不过估计应该都支持)。Logstash 自带有一个优化好的模板，内容如下:

```json
{
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "5s"
  },
  "mappings" : {
    "_default_" : {
       "_all" : {"enabled" : true},
       "dynamic_templates" : [ {
         "string_fields" : {
           "match" : "*",
           "match_mapping_type" : "string",
           "mapping" : {
             "type" : "string", "index" : "analyzed", "omit_norms" : true,
               "fields" : {
                 "raw" : {"type": "string", "index" : "not_analyzed", "ignore_above" : 256}
               }
           }
         }
       } ],
       "properties" : {
         "@version": { "type": "string", "index": "not_analyzed" },
         "geoip"  : {
           "type" : "object",
             "dynamic": true,
             "path": "full",
             "properties" : {
               "location" : { "type" : "geo_point" }
             }
         }
       }
    }
  }
}
```

这其中的关键设置包括：

- template for index-pattern

只有匹配 `logstash-*` 的索引才会应用这个模板。有时候我们会变更 Logstash 的默认索引名称，记住你也得通过 PUT 方法上传可以匹配你自定义索引名的模板。当然，我更建议的做法是，把你自定义的名字放在 "logstash-" 后面，变成 `index => "logstash-custom-%{+yyyy.MM.dd}"` 这样。

- refresh_interval for indexing

Elasticsearch 是一个*近*实时搜索引擎。它实际上是每 1 秒钟刷新一次数据。对于日志分析应用，我们用不着这么实时，所以 logstash 自带的模板修改成了 5 秒钟。你还可以根据需要继续放大这个刷新间隔以提高数据写入性能。

- multi-field with not_analyzed

Elasticsearch 会自动使用自己的默认分词器(空格，点，斜线等分割)来分析字段。分词器对于搜索和评分是非常重要的，但是大大降低了索引写入和聚合请求的性能。所以 logstash 模板定义了一种叫"多字段"(multi-field)类型的字段。这种类型会自动添加一个 ".raw" 结尾的字段，并给这个字段设置为不启用分词器。简单说，你想获取 url 字段的聚合结果的时候，不要直接用 "url" ，而是用 "url.raw" 作为字段名。

- geo_point

Elasticsearch 支持 *geo_point* 类型， *geo distance* 聚合等等。比如说，你可以请求某个 *geo_point* 点方圆 10 千米内数据点的总数。在 Kibana 的 bettermap 类型面板里，就会用到这个类型的数据。

### 其他模板配置建议

- doc_values

doc_values 是 Elasticsearch 1.3 版本引入的新特性。启用该特性的字段，索引写入的时候会在磁盘上构建 fielddata。而过去，fielddata 是固定只能使用内存的。在请求范围加大的时候，很容易触发 OOM 报错：

> ElasticsearchException[org.elasticsearch.common.breaker.CircuitBreakingException: Data too large, data for field [@timestamp] would be larger than limit of [639015321/609.4mb]]

doc_values 只能给不分词(对于字符串字段就是设置了 `"index":"not_analyzed"`，数值和时间字段默认就没有分词) 的字段配置生效。

doc_values 虽然用的是磁盘，但是系统本身也有自带 VFS 的 cache 效果并不会太差。据官方测试，经过 1.4 的优化后，只比使用内存的 fielddata 慢 15% 。所以，在数据量较大的情况下，**强烈建议开启**该配置：

```json
{
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "5s"
  },
  "mappings" : {
    "_default_" : {
       "_all" : {"enabled" : true},
       "dynamic_templates" : [ {
         "string_fields" : {
           "match" : "*",
           "match_mapping_type" : "string",
           "mapping" : {
             "type" : "string", "index" : "analyzed", "omit_norms" : true,
               "fields" : {
                 "raw" : { "type": "string", "index" : "not_analyzed", "ignore_above" : 256, "doc_values": true }
               }
           }
         }
       } ],
       "properties" : {
         "@version": { "type": "string", "index": "not_analyzed" },
         "@timestamp": { "type": "date", "index": "not_analyzed", "doc_values": true, "format": "dateOptionalTime" },
         "geoip"  : {
           "type" : "object",
             "dynamic": true,
             "path": "full",
             "properties" : {
               "location" : { "type" : "geo_point" }
             }
         }
       }
    }
  }
}
```

- order

如果你有自己单独定制 template 的想法，很好。这时候有几种选择：

1. 在 logstash/outputs/elasticsearch 配置中开启 `manage_template => false` 选项，然后一切自己动手；
2. 在 logstash/outputs/elasticsearch 配置中开启 `template => "/path/to/your/tmpl.json"` 选项，让 logstash 来发送你自己写的 template 文件；
3. 避免变更 logstash 里的配置，而是另外发送一个 template ，利用 elasticsearch 的 templates order 功能。

这个 order 功能，就是 elasticsearch 在创建一个索引的时候，如果发现这个索引同时匹配上了多个 template ，那么就会先应用 order 数值小的 template 设置，然后再应用一遍 order 数值高的作为覆盖，最终达到一个 merge 的效果。

比如，对上面这个模板已经很满意，只想修改一下 `refresh_interval` ，那么只需要新写一个：

```json
{
  "order" : 1,
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "20s"
  }
}
```

然后运行 `curl -XPUT http://localhost:9200/_template/template_newid -d '@/path/to/your/tmpl.json'` 即可。

logstash 默认的模板， order 是 0，id 是 logstash，通过 logstash/outputs/elasticsearch 的配置选项 `template_name` 修改。你的新模板就不要跟这个名字冲突了。

## 推荐阅读

- <http://www.elasticsearch.org/guide>

# 输出到 Redis

## 配置示例

```
input { stdin {} }
output {
    redis {
        data_type => "channel"
        key => "logstash-chan-%{+yyyy.MM.dd}"
    }
}
```

## Usage

我们还是继续先用 `redis-cli` 命令行来演示 *outputs/redis* 插件的实质。

### basical use case

运行 logstash 进程，然后另一个终端启动 redis-cli 命令。输入订阅指定频道的 Redis 命令 ("SUBSCRIBE logstash-chan-2014.08.08") 后，首先会看到一个订阅成功的返回信息。如下所示：

```
# redis-cli
127.0.0.1:6379> SUBSCRIBE logstash-chan-2014.08.08
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "logstash-chan-2014.08.08"
3) (integer) 1
```

好，在运行 logstash 的终端里输入 "hello world" 字符串。切换回 redis-cli 的终端，你发现已经自动输出了一条信息：

```
1) "message"
2) "logstash-chan-2014.08.08"
3) "{\"message\":\"hello world\",\"@version\":\"1\",\"@timestamp\":\"2014-08-08T16:34:21.865Z\",\"host\":\"raochenlindeMacBook-Air.local\"}"
```

看起来是不是非常眼熟？这一串字符其实就是我们在 inputs/redis 一节中使用的那段数据。

看，这样就把 *outputs/redis* 和 *inputs/redis* 串联起来了吧！

事实上，这就是我们使用 redis 服务器作为 logstassh 架构中 broker 角色的原理。

让我们把这两节中不同配置的 logstash 进程分别在两个终端运行起来，这次不再要运行 redis-cli 命令了。在配有 *outputs/redis* 这端输入 "hello world"，配有 "inputs/redis" 的终端上，就自动输出数据了！

### notification use case

我们还可以用其他程序来订阅 redis 频道，程序里就可以随意写其他逻辑了。你可以看看 [output/juggernaut](http://logstash.net/docs/1.4.2/outputs/juggernaut)插件的原理。这个 Juggernaut 就是基于 redis 服务器和 socket.io 框架构建的。利用它，logstash 可以直接向 webkit 等支持 socket.io 的浏览器推送告警信息。

## 扩展方式

和 `LogStash::Inputs::Redis` 一样，这里也有设置成 **list** 的方式。使用 `RPUSH` 命令发送给 redis 服务器，效果和之前展示的完全一致。包括可以调整的参数 `batch_event`，也在之前章节中讲过。这里不再重复举例。



# 输出到 Statsd

Statsd 最早是 2008 年 Flickr 公司用 Perl 写的针对 graphite、datadog 等监控数据后端存储开发的前端网络应用，2011 年 Etsy 公司用 nodejs 重构。用于接收、写入、读取和聚合时间序列数据，包括即时值和累积值等。

## 配置示例

```
output {
    statsd {
        host => "statsdserver.domain.com"
        namespace => "logstash"
        sender => "%{host}"
        increment => ["httpd.response.%{status}"]
    }
}
```

## 解释

Graphite 以树状结构存储监控数据，所以 statsd 也是如此。所以发送给 statsd 的数据的 key 也一定得是 "first.second.tree.four" 这样的形式。而在 *outputs/statsd* 插件中，就会以三个配置参数来拼接成这种形式：

```
    namespace.sender.metric
```

其中 namespace 和 sender 都是直接设置的，而 metric 又分为好几个不同的参数可以分别设置。statsd 支持的 metric 类型如下：

### metric 类型

- increment

示例语法：`increment => ["nginx.status.%{status}"]`

- decrement

语法同 increment。

- count

示例语法：`count => {"nginx.bytes" => "%{bytes}"}`

- gauge

语法同 count。

- set

语法同 count。

- timing

语法同 count。

关于这些 metric 类型的详细说明，请阅读 statsd 文档：<https://github.com/etsy/statsd/blob/master/docs/metric_types.md>。

## 推荐阅读

- Etsy 发布 nodejs 版本 statsd 的博客：[Measure Anything, Measure Everything](http://codeascraft.etsy.com/2011/02/15/measure-anything-measure-everything/)
- Flickr 发布 statsd 的博客：[Counting & Timing](http://code.flickr.net/2008/10/27/counting-timing/)

# 报警到 Nagios

Logstash 中有两个 output 插件是 nagios 有关的。*outputs/nagios* 插件发送数据给本机的 `nagios.cmd` 管道命令文件，*outputs/nagios_nsca* 插件则是 调用 `send_nsca` 命令以 NSCA 协议格式把数据发送给 nagios 服务器(远端或者本地皆可)。

## Nagios.Cmd

nagios.cmd 是 nagios 服务器的核心组件。nagios 事件处理和内外交互都是通过这个管道文件来完成的。

使用 CMD 方式，需要自己保证发送的 Logstash 事件符合 nagios 事件的格式。即必须在 *filter* 阶段预先准备好 `nagios_host` 和 `nagios_service` 字段；此外，如果在 *filter* 阶段也准备好 `nagios_annotation` 和 `nagios_level` 字段，这里也会自动转换成 nagios 事件信息。

```
filter {
    if [message] =~ /err/ {
        mutate {
            add_tag => "nagios"
            rename => ["host", "nagios_host"]
            replace => ["nagios_service", "logstash_check_%{type}"]
        }
    }
}
output {
    if "nagios" in [tags] {
        nagios { }
    }
}
```

如果不打算在 *filter* 阶段提供 `nagios_level` ，那么也可以在该插件中通过参数配置。

所谓 `nagios_level`，即我们通过 nagios plugin 检查数据时的返回值。其取值范围和含义如下：

- "0"，代表 "OK"，服务正常；
- "1"，代表 "WARNNING"，服务警告，一般 nagios plugin 命令中使用 `-w` 参数设置该阈值；
- "2"，代表 "CRITICAL"，服务危急，一般 nagios plugin 命令中使用 `-c` 参数设置该阈值；
- "3"，代表 "UNKNOWN"，未知状态，一般会在 timeout 等情况下出现。

默认情况下，该插件会以 "CRITICAL" 等级发送报警给 Nagios 服务器。

nagios.cmd 文件的具体位置，可以使用 `command_file` 参数设置。默认位置是 "/var/lib/nagios3/rw/nagios.cmd"。

关于和 nagios.cmd 交互的具体协议说明，有兴趣的读者请阅读 [Using external commands in Nagios](http://archive09.linux.com/feature/153285) 一文，这是《Learning Nagios 3.0》书中内容节选。

## NSCA

NSCA 是一种标准的 nagios 分布式扩展协议。分布在各机器上的 `send_nsca` 进程主动将监控数据推送给远端 nagios 服务器的 NSCA 进程。

当 Logstash 跟 nagios 服务器没有在同一个主机上运行的时候，就只能通过 NSCA 方式来发送报警了 —— 当然也必须在 Logstash 服务器上安装 `send_nsca` 命令。

nagios 事件所需要的几个属性在上一段中已经有过描述。不过在使用这个插件的时候，不要求提前准备好，而是可以在该插件内部定义参数：

```
output {
    nagios_nsca {
        nagios_host => "%{host}"
        nagios_service => "logstash_check_%{type}"
        nagios_status => "2"
        message_format => "%{@timestamp}: %{message}"
        host => "nagiosserver.domain.com"
    }
}
```

这里请注意，`host` 和 `nagios_host` 两个参数，分别是用来设置 nagios 服务器的地址，和报警信息中有问题的服务器地址。

关于 NSCA 原理，架构和配置说明，还不了解的读者请阅读官方网站 [Using NSClient++ from nagios with NSCA](http://nsclient.org/nscp/wiki/doc/usage/nagios/nsca) 一节。

## 推荐阅读

除了 nagios 以外，logstash 同样可以发送信息给其他常见监控系统。方式和 nagios 大同小异：

- *outputs/ganglia* 插件通过 UDP 协议，发送 gmetric 型数据给本机/远端的 `gmond` 或者 `gmetad`
- *outputs/zabbix* 插件调用本机的 `zabbix_sender` 命令发送



# 发送邮件(Email)

## 配置示例

```
output {
    email {
        to => "admin@website.com,root@website.com"
        cc => "other@website.com"
        via => "smtp"
        subject => "Warning: %{title}"
        options => {
            smtpIporHost       => "localhost",
            port               => 25,
            domain             => 'localhost.localdomain',
            userName           => nil,
            password           => nil,
            authenticationType => nil, # (plain, login and cram_md5)
            starttls           => true
        }
        htmlbody => ""
        body => ""
        attachments => ["/path/to/filename"]
    }
}
```

## 解释

*outputs/email* 插件支持 SMTP 协议和 sendmail 两种方式，通过 `via` 参数设置。SMTP 方式有较多的 options 参数可配置。sendmail 只能利用本机上的 sendmail 服务来完成 —— 文档上描述了 Mail 库支持的 sendmail 配置参数，但实际代码中没有相关处理，不要被迷惑了。。。



# 调用命令执行(Exec)

*outputs/exec* 插件的运用也非常简单，如下所示，将 logstash 切割成的内容作为参数传递给命令。这样，在每个事件到达该插件的时候，都会触发这个命令的执行。

```
output {
    exec {
        command => "sendsms.pl \"%{message}\" -t %{user}"
    }
}
```

需要注意的是。这种方式是每次都重新开始执行一次命令并退出。本身是比较慢速的处理方式(程序加载，网络建联等都有一定的时间消耗)。最好只用于少量的信息处理场景，比如不适用 nagios 的其他报警方式。示例就是通过短信发送消息。

# Kafka

<https://github.com/joekiller/logstash-kafka>

插件已经正式合并进官方仓库，以下使用介绍基于**logstash 1.4相关版本**，1.5及以后版本的使用后续依照官方文档持续更新。

插件本身内容非常简单，其主要依赖同一作者写的 [jruby-kafka](https://github.com/joekiller/jruby-kafka) 模块。需要注意的是：**该模块仅支持 Kafka－0.8 版本。如果是使用 0.7 版本 kafka 的，将无法直接使 jruby-kafka 该模块和 logstash-kafka 插件。**

## 安装

- 安装按照官方文档完全自动化的安装.或是可以通过以下方式手动自己安装插件，不过重点注意的是 **kafka 的版本**，上面已经指出了。

> 1. 下载 logstash 并解压重命名为 `./logstash-1.4.0` 文件目录。
> 2. 下载 kafka 相关组件，以下示例选的为 [kafka_2.8.0-0.8.1.1-src](https://www.apache.org/dyn/closer.cgi?path=/kafka/0.8.1.1/kafka-0.8.1.1-src.tgz)，并解压重命名为 `./kafka_2.8.0-0.8.1.1`。
> 3. 下载 logstash-kafka v0.4.2 从 [releases](https://github.com/joekiller/logstash-kafka/releases)，并解压重命名为 `./logstash-kafka-0.4.2`。
> 4. 从 `./kafka_2.8.0-0.8.1.1/libs` 目录下复制所有的 jar 文件拷贝到 `./logstash-1.4.0/vendor/jar/kafka_2.8.0-0.8.1.1/libs` 下，其中你需要创建 `kafka_2.8.0-0.8.1.1/libs` 相关文件夹及目录。
> 5. 分别复制 `./logstash-kafka-0.4.2/logstash` 里的 `inputs` 和 `outputs` 下的 `kafka.rb`，拷贝到对应的 `./logstash-1.4.0/lib/logstash` 里的 `inputs` 和 `outputs` 对应目录下。
> 6. 切换到 `./logstash-1.4.0` 目录下，现在需要运行 logstash-kafka 的 gembag.rb 脚本去安装 jruby-kafka 库，执行以下命令： `GEM_HOME=vendor/bundle/jruby/1.9 GEM_PATH= java -jar vendor/jar/jruby-complete-1.7.11.jar --1.9 ../logstash-kafka-0.4.2/gembag.rb ../logstash-kafka-0.4.2/logstash-kafka.gemspec`。
> 7. 现在可以使用 logstash-kafka 插件运行 logstash 了。例如：`bin/logstash agent -f logstash.conf`。

## Input 配置示例

以下配置可以实现对 kafka 读取端(consumer)的基本使用。

消费端更多详细的配置请查看 <http://kafka.apache.org/documentation.html#consumerconfigs> kafka 官方文档的消费者部分配置文档。

```
input {
    kafka {
        zk_connect => "localhost:2181"
        group_id => "logstash"
        topic_id => "test"
        reset_beginning => false # boolean (optional)， default: false
        consumer_threads => 5  # number (optional)， default: 1
        decorate_events => true # boolean (optional)， default: false
        }
    }
```

## Input 解释

消费端的一些比较有用的配置项：

- group_id

消费者分组，可以通过组 ID 去指定，不同的组之间消费是相互不受影响的，相互隔离。

- topic_id

指定消费话题，也是必填项目，指定消费某个 `topic` ，这个其实就是订阅某个主题，然后去消费。

- reset_beginning

logstash 启动后从什么位置开始读取数据，默认是结束位置，也就是说 logstash 进程会以从上次读取结束时的偏移量开始继续读取，如果之前没有消费过，那么就开始从头读取.如果你是要导入原有数据，把这个设定改成 "true"， logstash 进程就从头开始读取.有点类似 `cat` ，但是读到最后一行不会终止，而是变成 `tail -F` ，继续监听相应数据。

- decorate_events

在输出消息的时候会输出自身的信息包括:消费消息的大小， topic 来源以及 consumer 的 group 信息。

- rebalance_max_retries

当有新的 consumer(logstash) 加入到同一 group 时，将会 `reblance` ，此后将会有 `partitions` 的消费端迁移到新的 `consumer` 上，如果一个 `consumer` 获得了某个 `partition` 的消费权限，那么它将会向 `zookeeper`注册， `Partition Owner registry` 节点信息，但是有可能此时旧的 `consumer` 尚没有释放此节点，此值用于控制，注册节点的重试次数。

- consumer_timeout_ms

指定时间内没有消息到达就抛出异常，一般不需要改。

以上是相对重要参数的使用示例，更多参数可以选项可以跟据 <https://github.com/joekiller/logstash-kafka/blob/master/README.md> 查看 input 默认参数。

## 注意

1.想要使用多个 logstash 端协同消费同一个 `topic` 的话，那么需要把两个或是多个 logstash 消费端配置成相同的 `group_id` 和 `topic_id`， 但是前提是要把**相应的 topic 分多个 partitions (区)**，多个消费者消费是无法保证消息的消费顺序性的。

> 这里解释下，为什么要分多个 **partitions(区)**， kafka 的消息模型是对 topic 分区以达到分布式效果。每个 `topic` 下的不同的 **partitions (区)**只能有一个 **Owner** 去消费。所以只有多个分区后才能启动多个消费者，对应不同的区去消费。其中协调消费部分是由 server 端协调而成。不必使用者考虑太多。只是**消息的消费则是无序的**。

总结:保证消息的顺序，那就用一个 **partition**。 **kafka 的每个 partition 只能同时被同一个 group 中的一个 consumer 消费**。

## Output 配置

以下配置可以实现对 kafka 写入端 (producer) 的基本使用。

生产端更多详细的配置请查看 <http://kafka.apache.org/documentation.html#producerconfigs> kafka 官方文档的生产者部分配置文档。

```
 output {
    kafka {
        broker_list => "localhost:9092"
        topic_id => "test"
        compression_codec => "snappy" # string (optional)， one of ["none"， "gzip"， "snappy"]， default: "none"
    }
}
```

## Output 解释

生产的可设置性还是很多的，设置其实更多，以下是更多的设置：

- compression_codec

消息的压缩模式，默认是 none，可以有 gzip 和 snappy (暂时还未测试开启压缩与不开启的性能，数据传输大小等对比)。

- compressed_topics

可以针对特定的 topic 进行压缩，设置这个参数为 `topic` ，表示此 `topic` 进行压缩。

- request_required_acks

消息的确认模式:

> 可以设置为 0: 生产者不等待 broker 的回应，只管发送.会有最低能的延迟和最差的保证性(在服务器失败后会导致信息丢失)
>
> 可以设置为 1: 生产者会收到 leader 的回应在 leader 写入之后.(在当前 leader 服务器为复制前失败可能会导致信息丢失)
>
> 可以设置为 -1: 生产者会收到 leader 的回应在全部拷贝完成之后。

- partitioner_class

分区的策略，默认是 hash 取模

- send_buffer_bytes

socket 的缓存大小设置，其实就是缓冲区的大小

#### 消息模式相关

- serializer_class

消息体的系列化处理类，转化为字节流进行传输，**请注意 encoder 必须和下面的 key_serializer_class 使用相同的类型**。

- key_serializer_class

默认的是与 `serializer_class` 相同

- producer_type

生产者的类型 `async` 异步执行消息的发送 `sync` 同步执行消息的发送

- queue_buffering_max_ms

**异步模式下**，那么就会在设置的时间缓存消息，并一次性发送

- queue_buffering_max_messages

**异步的模式下**，最长等待的消息数

- queue_enqueue_timeout_ms

**异步模式下**，进入队列的等待时间，若是设置为0，那么要么进入队列，要么直接抛弃

- batch_num_messages

**异步模式下**，每次发送的最大消息数，前提是触发了 `queue_buffering_max_messages` 或是 `queue_enqueue_timeout_ms` 的限制

以上是相对重要参数的使用示例，更多参数可以选项可以跟据 <https://github.com/joekiller/logstash-kafka/blob/master/README.md> 查看 output 默认参数。

### 小贴士

默认情况下，插件是使用 json 编码来输入和输出相应的消息，消息传递过程中 logstash 默认会为消息编码内加入相应的时间戳和 hostname 等信息。如果不想要以上信息(一般做消息转发的情况下)，可以使用以下配置，例如:

```
 output {
    kafka {
        codec => plain {
            format => "%{message}"
        }
    }
}
```

# HDFS

- <https://github.com/dstore-dbap/logstash-webhdfs>

This plugin based on WebHDFS api of Hadoop, it just POST data to WebHDFS port. So, it's a native Ruby code.

```
output {
    hadoop_webhdfs {
        workers => 2
        server => "your.nameno.de:14000"
        user => "flume"
        path => "/user/flume/logstash/dt=%{+Y}-%{+M}-%{+d}/logstash-%{+H}.log"
        flush_size => 500
        compress => "snappy"
        idle_flush_time => 10
        retry_interval => 0.5
    }
}
```

- <https://github.com/avishai-ish-shalom/logstash-hdfs>

This plugin based on HDFS api of Hadoop, it import java classes like `org.apache.hadoop.fs.FileSystem`etc.

### Configuration

```
input {
    hdfs {
        path => "/path/to/output_file.log"
        enable_append => true
    }
}
```

### Howto run

```
CLASSPATH=$(find /path/to/hadoop -name '*.jar' | tr '\n' ':'):/etc/hadoop/conf:/path/to/logstash-1.1.7-mon
```

# scribe

<https://github.com/EverythingMe/logstash-scribeinput>

```
input {
        scribe {
                host => "localhost"
                port => 8000
        }
}
java -Xmx400M -server \
   -cp scribe_server.jar:logstash-1.2.1-flatjar.jar \
   logstash.runner agent \
   -p /where/did/i/put/this/downloaded/plugin \
   -f logstash.conf
```





# 自己写一个插件

前面已经提过在运行 logstash 的时候，可以通过 `--pluginpath` 参数来加载自己写的插件。那么，插件又该怎么写呢？

## 插件格式

一个标准的 logstash 输入插件格式如下：

```ruby
require 'logstash/namespace'
require 'logstash/inputs/base'
class LogStash::Inputs::MyPlugin < LogStash::Inputs::Base
  config_name 'myplugin'
  milestone 1
  config :myoption_key, :validate => :string, :default => 'myoption_value'
  public def register
  end
  public def run(queue)
  end
end
```

其中大多数语句在过滤器和输出阶段是共有的。

- config_name 用来定义该插件写在 logstash 配置文件里的名字；
- milestone 标记该插件的开发里程碑，一般为1，2，3，如果不再维护的，标记为 0；
- config 可以定义很多个，即该插件在 logstash 配置文件中的可配置参数。logstash 很温馨的提供了验证方法，确保接收的数据是你期望的数据类型；
- register logstash 在启动的时候运行的函数，一些需要常驻内存的数据，可以在这一步先完成。比如对象初始化，*filters/ruby* 插件中的 `init` 语句等。

*小贴士*

milestone 级别在 3 以下的，logstash 默认为不足够稳定，会在启动阶段，读取到该插件的时候，输出类似下面这样的一行提示信息，日志级别是 warn。**这不代表运行出错**！只是提示如果用户碰到 bug，欢迎提供线索。

> {:timestamp=>"2015-02-06T10:37:26.312000+0800", :message=>"Using milestone 2 input plugin 'file'. This plugin should be stable, but if you see strange behavior, please let us know! For more information on plugin milestones, see <http://logstash.net/docs/1.4.2-modified/plugin-milestones>", :level=>:warn}

## 插件的关键方法

输入插件独有的是 run 方法。在 run 方法中，必须实现一个长期运行的程序(最简单的就是 loop 指令)。然后在每次收到数据并处理成 `event` 之后，一定要调用 `queue << event` 语句。一个输入流程就算是完成了。

而如果是过滤器插件，对应修改成：

```ruby
require 'logstash/filters/base'
class LogStash::Filters::MyPlugin < LogStash::Filters::Base
  public def filter(event)
  end
end
```

输出插件则是：

```ruby
require 'logstash/outputs/base'
class LogStash::Outputs::MyPlugin < LogStash::Outputs::Base
  public def receive(event)
  end
end
```

另外，为了在终止进程的时候不遗失数据，建议都实现如下这个方法，只要实现了，logstash 在 shutdown 的时候就会自动调用：

```ruby
public def teardown
end
```

## 推荐阅读

- [Extending logstash](http://logstash.net/docs/1.4.2/extending/)
- [Plugin Milestones](http://logstash.net/docs/1.4.2/plugin-milestones)

# 为什么用 JRuby？能用 MRI 运行么？

对日志处理框架有一些了解的都知道，大多数框架都是用 Java 写的，毕竟做大规模系统 Java 有天生优势。而另一个新生代 fluentd 则是标准的 Ruby 产品(即 Matz's Ruby Interpreter)。logstash 选用 JRuby 来实现，似乎有点两头不讨好啊？

乔丹西塞曾经多次著文聊过这个问题。为了避凑字数的嫌，这里罗列他的 gist 地址：

- [Time sucks](https://gist.github.com/jordansissel/2929216) 一文是关于 Time 对象的性能测试，最快的生成方法是 `sprintf` 方法，MRI 性能为 82600 call/sec，JRuby1.6.7 为 131000 call/sec，而 JRuby1.7.0 为 215000 call/sec。
- [Comparing egexp patterns speeds](https://gist.github.com/jordansissel/1491302) 一文是关于正则表达式的性能测试，使用的正则统一为 `(?-mix:('(?:[^\\']+|(?:\\.)+)*'))`，结果 MRI1.9.2 为 530000 matches/sec，而 JRuby1.6.5 为 690000 matches/sec。
- [Logstash performance under ruby](https://gist.github.com/jordansissel/4171039)一文是关于 logstash 本身数据流转性能的测试，使用 *inputs/generator* 插件生成数据，*outputs/stdout* 到 pv 工具记点统计。结果 MRI1.9.3 为 4000 events/sec，而 JRuby1.7.0 为 25000 events/sec。

可能你已经运行着 logstash 并发现自己的线上数据远超过这个测试——这是因为乔丹西塞在2013年之前，一直是业余时间开发 logstash，而且从未用在自己线上过。所以当时的很多测试是在他自己电脑上完成的。

在 logstash 得到大家强烈关注后，作者发表了《[logstash needs full time love](https://gist.github.com/jordansissel/3088552)》，表明了这点并求一份可以让自己全职开发 logstash 的工作，同时列出了1.1.0 版本以后的 roadmap。（不过事实证明当时作者列出来的这些需求其实不紧急，因为大多数，或者说除了 kibana 以外，至今依然没有==!）

时间轴继续向前推，到 2011 年，你会发现 logstash 原先其实也是用 MRI1.8.7 写的！在 [grok 模块从 C 扩展改写成 FFI 扩展后](https://code.google.com/p/logstash/issues/detail?id=37)，才正式改用 JRuby。

切换语言的当时，乔丹西塞发表了《[logstash, why jruby?](https://gist.github.com/jordansissel/978956)》大家可以一读。

事实上，时至今日，多种 Ruby 实现的痕迹(到处都有 RUBY_ENGINE 变量判断)依然遍布 logstash 代码各处，作者也力图保证尽可能多的代码能在 MRI 上运行。

作为简单的指示，在和插件无关的核心代码中，只有 LogStash::Event 里生成 `@timestamp`字段时用了 Java 的 joda 库为 JRuby 仅有的。稍微修改成 Ruby 自带的 Time 库，即可在 MRI 上运行起来。而主要插件中，也只有 filters/date 和 outputs/elasticsearch 是 Java 相关的。