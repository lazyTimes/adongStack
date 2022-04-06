# 十分钟快速入门

## 前置条件

1) 安装elasticSearch

2) 下载好kibana对应的包

3) 

## 导入数据

```
curl -XPUT http://172.18.118.222:9200/shakespeare -d '
{
"mappings" : {
"_default_" : {
"properties" : {
"speaker" : {"type": "string", "index" : "not_analyzed" },
"play_name" : {"type": "string", "index" : "not_analyzed" },
"line_id" : { "type" : "integer" },
"speech_number" : { "type" : "integer" }
}
}
}
}
'
```

用如下命令导入数据到你本地的 elasticsearch 进程中。这可能需要一点时间，莎士比亚可是著作等身的大文豪！

```
curl -XPUT 172.18.118.222:9200/_bulk --data-binary @shakespeare.json
```

## 安排、配置和运行

1. 从浏览器访问 Kibana 界面。也就是说访问比如  localhost:5601  或者
   http://YOURDOMAIN.com:5601  。
2. 指定一个可以匹配一个或者多个 Elasticsearch 索引的 index pattern 。**默认情**
   **况下，Kibana 认为你要访问的是通过 Logstash 导入 Elasticsearch 的数据**。
   这时候你可以用默认的  logstash-*  作为你的 index pattern。通配符(*) 匹配
   索引名中零到多个字符。如果你的 Elasticsearch 索引有其他命名约定，输入
   合适的 pattern。pattern 也开始是最简单的单个索引的名字。
3. 选择一个包含了时间戳的索引字段，可以用来做基于时间的处理。Kibana 会读
   取索引的映射，然后列出所有包含了时间戳的字段(译者注：实际是字段类型为
   date 的字段，而不是“看起来像时间戳”的字段)。如果你的索引没有基于时间的
   数据，关闭  Index contains time-based events  参数。
4. 如果一个新索引是定期生成，而且索引名中带有时间戳，选择  Use event
   times to create index names  选项，然后再选择  Index pattern
   interval  。这可以提高搜索性能，Kibana 会至搜索你指定的时间范围内的索
   引。在你用 Logstash 输出数据给 Elasticsearch 的情况下尤其有效。

5. 点击  Create  添加 index pattern。第一个被添加的 pattern 会自动被设置为
  默认值。如果你有多个 index pattern 的时候，你可以在  Settings >
  Indices  里设置具体哪个是默认值。

+ 在 Discover 页搜索和浏览你的数据。
+ 在 Visualize 页转换数据成图表。
+ 在 Dashboard 页创建定制自己的仪表板。

### Nginx 代理配置

因为 Kibana5 不再是 Kibana3 那种纯静态文件的单页应用，所以其服务器端是需
要消耗计算资源的。因此，如果用户较多，Kibana5 确实有可能需要进行多点部
署，这时候，就需要用 Nginx 做一层代理了。

和 Kibana3 相比，Kibana5 的 Nginx 代理配置倒是简单许多，因为所有流量都是统
一配置的。下面是一段包含入口流量加密、简单权限控制的 Kibana5 代理配置：



```
upstream kibana5 {
	server 127.0.0.1:5601 fail_timeout=0;
}
server {
    listen *:80;
    server_name kibana_server;
    access_log /var/log/nginx/kibana.srv-log-dev.log;
    error_log /var/log/nginx/kibana.srv-log-dev.error.log;
    
    ssl on;
    ssl_certificate /etc/nginx/ssl/all.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    location / {
        root /var/www/kibana;
        index index.html index.htm;
    }
    location ~ ^/kibana5/.* {
        proxy_pass http://kibana5;
        rewrite ^/kibana5/(.*) /$1 break;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwar
        ded_for;
        proxy_set_header Host $host;
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/conf.d/kibana.myhost.org
        .htpasswd;
    }
}
```

### 网络配置

Kibana 5.5 版后，已不支持认证功能，也就是说，直接打开页面就能管理，想想都不安全，不过官方提供了 X-Pack 认证，但有时间限制。毕竟X-Pack是商业版。

**安装Apache Httpd 密码生成工具**

```
$ yum install httpd-tools -y
```

**生成Kibana认证密码**

```
$ mkdir -p /usr/local/nginx/conf/passwd
$ htpasswd -c -b /usr/local/nginx/conf/passwd/kibana.passwd Userrenwolecom GN5SKorJ
Adding password for user Userrenwolecom
```

**配置Nginx反向代理**

在Nginx配置文件中添加如下内容（或新建配置文件包含）：

```
$ vim /usr/local/nginx/conf/nginx.conf

server {
    listen 10.28.204.65:5601;
    auth_basic "Restricted Access";
    auth_basic_user_file /usr/local/nginx/conf/passwd/kibana.passwd;
    location / {
    proxy_pass http://10.28.204.65:5601;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade; 
}
}
```

```
upstream kibana_server {
        server  172.18.118.222:5601 weight=1 max_fails=3  fail_timeout=60;
}

server {
        listen 80;
        server_name 172.18.118.222;
        auth_basic "Restricted Access";      # 验证
        auth_basic_user_file /usr/local/nginx/conf/passwd/kibana.passwd;             # 验证文件
        location / {
        proxy_pass http://kibana_server;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        }
}
```



**配置Kibana**

取消下面注释：

```
$ vim /usr/local/kibana/config/kibana.yml

server.host: "10.28.204.65"
```

**重启 Kibana 及 Nginx 服务使配置生效**

```
$ systemctl restart kibana.service
$ systemctl restart nginx.service
```

接下来浏览器访问 http://103.28.204.65:5601/ 会提示验证弹窗，输入以上生成的用户密码登录即可。

> 本文地址：<https://www.linuxprobe.com/nginx-proxy-kibana.html>



```
server {
    listen 10.28.204.65:5601;
    auth_basic "Restricted Access";
    auth_basic_user_file /usr/local/nginx/conf/passwd/kibana.passwd;
    location / {
        proxy_pass http://10.28.204.65:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade; 
    }
}
```

#### 正确并且可行配置

```
server {

   listen 80;

   server_name 119.23.219.183;       #主机名

   auth_basic "Restricted Access";

   auth_basic_user_file /usr/local/nginx/html/.htpasswd;      #登录验证

   location / {

       proxy_pass http://172.18.118.222:5601;       #转发到kibana，kibana ip配置成内网

       proxy_http_version 1.1;

       proxy_set_header Upgrade $http_upgrade;

       proxy_set_header Connection 'upgrade';

       proxy_set_header Host $host;

       proxy_cache_bypass $http_upgrade;

   }

}
```



### Nginx安装

。。。。。。



## 设置时间过滤器

时间过滤器(Time Filter)限制搜索结果在一个特定的时间周期内。如果你的索引包含
的是时序诗句，而且你为所选的索引模式配置了时间字段，那么就就可以设置时间
过滤器。
默认的时间过滤器设置为最近 15 分钟。你可以用页面顶部的时间选择器(Time
Picker)来修改时间过滤器，或者选择一个特定的时间间隔，或者直方图的时间范
围。
要用时间选择器来修改时间过滤器：

1. 点击菜单栏右上角显示的 Time Filter 打开时间选择器。
2. 快速过滤，直接选择一个短链接即可。
3. 要指定相对时间过滤，点击 Relative 然后输入一个相对的开始时间。可以是任
  意数字的秒、分、小时、天、月甚至年之前。
4. 要指定绝对时间过滤，点击 Absolute 然后在 From 框内输入开始日期，To 框
  内输入结束日期。
5. 点击时间选择器底部的箭头隐藏选择器。
  要从柱状图上设置时间过滤器，有以下几种方式：
  想要放大那个时间间隔，点击对应的柱体。
  单击并拖拽一个时间区域。注意需要等到光标变成加号，才意味着这是一个有
  效的起始点。
  你可以用浏览器的后退键来回退你的操作。

# 搜索数据

在 Discover 页提交一个搜索，你就可以搜索匹配当前索引模式的索引数据了。你
可以直接输入简单的请求字符串，也就是用 Lucene query syntax，也可以用完整
的基于 JSON 的 Elasticsearch Query DSL。
当你提交搜索的时候，直方图，文档表格，字段列表，都会自动反映成搜索的结
果。hits(匹配的文档)总数会在直方图的右上角显示。文档表格显示前 500 个匹配
文档。默认的，文档倒序排列，最新的文档最先显示。你可以通过点击时间列的头
部来反转排序。事实上，所有建了索引的字段，都可以用来排序，稍后会详细说
明。
要搜索你的数据：

1. 在搜索框内输入请求字符串：
  简单的文本搜索，直接输入文本字符串。比如，如果你在搜索网站服务器
  日志，你可以输入  safari  来搜索各字段中的  safari  单词。
  要搜索特定字段中的值，则在值前加上字段名。比如，你可以输入
  status:200  来限制搜索结果都是在  status  字段里有  200  内容。
  要搜索一个值的范围，你可以用范围查询语法， [START_VALUE TO
  END_VALUE]  。比如，要查找 4xx 的状态码，你可以输入  status:[400
  TO 499]  。
  要指定更复杂的搜索标准，你可以用布尔操作符  AND  ,  OR  , 和  NOT  。
  比如，要查找 4xx 的状态码，还是  php  或  html  结尾的数据，你可以
  输入  status:[400 TO 499] AND (extension:php OR
  extension:html)  。
  这些例子都用了 Lucene query syntax。你也可以提交 Elasticsearch Query
  DSL 式的请求。更多示例，参见之前 Elasticsearch 章节。
2. 点击回车键，或者点击  Search  按钮提交你的搜索请求。

## 开始一个新的搜索

要清除当前搜索或开始一个新搜索，点击 Discover 工具栏的 New Search 按钮。

## 保存搜索

discover功能

你可以在 Discover 页加载已保存的搜索，也可以用作 visualizations 的基础。保存
一个搜索，意味着同时保存下了搜索请求字符串和当前选择的索引模式。
要保存当前搜索：

1. 点击 Discover 工具栏的  Save Search  按钮。
2. 输入一个名称，点击  Save  。
  加载一个已存搜索
  要加载一个已保存的搜索：
3. 点击 Discover 工具栏的  Load Search  按钮。
4. 选择你要加载的搜索。
  如果已保存的搜索关联到跟你当前选择的索引模式不一样的其他索引上，加载这个
  搜索也会切换当前的已选索引模式。
  改变你搜索的索引
  当你提交一个搜索请求，匹配当前的已选索引模式的索引都会被搜索。当前模式模
  式会显示在搜索栏下方。要改变搜索的索引，需要选择另外的模式模式。
  要选择另外的索引模式：
5. 点击 Discover 工具栏的  Settings  按钮。
6. 从索引模式列表中选取你打算采用的模式。
  关于索引模式的更多细节，请阅读稍后 Setting 功能小节。

## 自动刷新页面

亦可以配置一个刷新间隔来自动刷新 Discover 页面的最新索引数据。这会定期重
新提交一次搜索请求。
设置刷新间隔后，会显示在菜单栏时间过滤器的左边。
要设置刷新间隔：

1. 点击菜单栏右上角的  Time Picker   。
   discover功能
   497
2. 点击  Auto refresh  标签。
3. 从列表中选择一个刷新间隔。
   开启自动刷新后，Kibana 的顶部栏会出现一个暂停按钮和自动刷新的间隔，点击
   Pause 按钮可以暂停自动刷新。

## 按字段过滤

你可以过滤搜索结果，只显示在某字段中包含了特定值的文档。也可以创建反向过
滤器，排除掉包含特定字段值的文档。

你可以从字段列表或者文档表格里添加过滤器。当你添加好一个过滤器后，它会显
示在搜索请求下方的过滤栏里。从过滤栏里你可以编辑或者关闭一个过滤器，转换
过滤器(从正向改成反向，反之亦然)，切换过滤器开关，或者完全移除掉它。

要从字段列表添加过滤器：

1. 点击你想要过滤的字段名。会显示这个字段的前 5 名数据。每个数据的右侧，
   有两个小按钮 —— 一个用来添加常规(正向)过滤器，一个用来添加反向过滤
   器。
2. 要添加正向过滤器，点击  Positive Filter  按钮  。这个会过滤掉在本字
   段不包含这个数据的文档。
3. 要添加反向过滤器，点击  Negative Filter  按钮  。这个会过滤掉在本字
   段包含这个数据的文档。
   要从文档表格添加过滤器：
4. 点击表格第一列(通常都是时间)文档内容左侧的  Expand  按钮  展开文档
   表格中的文档。每个字段名的右侧，有两个小按钮 —— 一个用来添加常规(正
   向)过滤器，一个用来添加反向过滤器。
5. 要添加正向过滤器，点击  Positive Filter  按钮  。这个会过滤掉在本字
   段不包含这个数据的文档。
6. 要添加反向过滤器，点击  Negative Filter  按钮  。这个会过滤掉在本字
   discover功能
   段包含这个数据的文档。

## 过滤器(Filter)的协同工作方式

在 Kibana 的任意页面创建过滤器后，就会在搜索输入框的下方，出现椭圆形的过
滤条件。

鼠标移动到过滤条件上，会显示下面几个图标：
过滤器开关  点击这个图标，可以在不移除过滤器的情况下关闭过滤条件。
再次点击则重新打开。被禁用的过滤器是条纹状的灰色，要求包含(相当于
Kibana3 里的 must)的过滤条件显示为绿色，要求排除(相当于 Kibana3 里的
mustNot)的过滤条件显示为红色。

过滤器图钉  点击这个图标钉住过滤器。被钉住的过滤器，可以横贯 Kibana
各个标签生效。比如在 Visualize 标签页钉住一个过滤器，然后切换到
Discover 或者 Dashboard 标签页，过滤器依然还在。注意：如果你钉住了过
滤器，然后发现检索结果为空，注意查看当前标签页的索引模式是不是跟过滤
器匹配。

过滤器反转  点击这个图标反转过滤器。默认情况下，过滤器都是包含型，
显示为绿色，只有匹配过滤条件的结果才会显示。反转成排除型过滤器后，显
示的是不匹配过滤器的检索项，显示为红色。
移除过滤器  点击这个图标删除过滤器。

自定义过滤器  点击这个图标会打开一个文本编辑框。编辑框内可以修改
JSON 形式的过滤器内容，并起一个 alias 别名：  JSON 中可以灵活应用
bool query 组合各种  should  、 must  、 must_not  条件。一个用
should  表达的 OR 关系过滤如下:

```
{
    "bool": {
        "should": [
            {
                "term": {
                    "geoip.country_name.raw": "Canada"
                }
            },
            {
                "term": {
                    "geoip.country_name.raw": "China"
                }
            }
        ]
    }
}
```

## 查看文档数据

当你提交一个搜索请求，最近的 500 个搜索结果会显示在文档表格里。你可以在
Advanced Settings 里通过  discover:sampleSize  属性配置表格里具体的文档
数量。默认的，表格会显示当前选择的索引模式中定义的时间字段内容(转换成本地
时区)以及  _source  文档。你可以从字段列表添加字段到文档表格。还可以用表
格里包含的任意已建索引的字段来排序列出的文档。

要查看一个文档的字段数据，点击表格第一列(通常都是时间)文档内容左侧的
Expand  按钮  。Kibana 从 Elasticsearch 读取数据然后在表格中显示文档字
段。这个表格每行是一个字段的名字、过滤器按钮和字段的值。



1. 要查看原始 JSON 文档(格式美化过的)，点击 JSON 标签。
2. 要在单独的页面上查看文档内容，点击链接。你可以添加书签或者分享这个链
  接，以直接访问这条特定文档。
3. 收回文档细节，点击 Collapse 按钮  。
4. To toggle a particular field’s column in the Documents table, click the
  Toggle column in table button.

## 文档列表排序

你可以用任意已建索引的字段排序文档表格中的数据。如果当前索引模式配置了时
间字段，默认会使用该字段倒序排列文档。
要改变排序方式：
点击想要用来排序的字段名。能用来排序的字段在字段名右侧都有一个排序按
钮。再次点击字段名，就会反向调整排序方式。



# 各 Visualize 功能

Visualize 标签页用来设计可视化。你可以保存可视化，以后再用，或者加载合并到
dashboard 里。一个可视化可以基于以下几种数据源类型：

+ 新的交互式搜索
+ 一个已保存的搜索
+ 一个已保存的可视化

可视化是基于 Elasticsearch 1.0 引入的聚合(aggregation) 特性。

## 创建一个新可视化

要开始一个 Create New Visualization 向导，点击页面左侧边栏的 Visualize 标
签。如果你已经在浏览一个可视化了，你可以在顶部菜单栏里点击 New 选项 ! 向
导会引导你继续以下几步：

### 第 1 步: 选择可视化类型

在 New Visualization 向导起始页可以选择以下一个可视化类型：
类型 用途

|       类型        | 用途                                                         |
| :---------------: | ------------------------------------------------------------ |
|    Area chart     | 用区块图来可视化多个不同序列的总体贡献。                     |
|    Data table     | 用数据表来显示聚合的原始数据。其他可视化可以通过点击底部的方式显示数据表。 |
|    Line chart     | 用折线图来比较不同序列。                                     |
|  Markdown
widget   | 用 Markdown 显示自定义格式的信息或和你仪表盘有关的用法
说明。 |
|      Metric       | 用指标可视化在你仪表盘上显示单个数字。                       |
|     Pie chart     | 用饼图来显示每个来源对总体的贡献。                           |
|     Tile map      | 用瓦片地图将聚合结果和经纬度联系起来。                       |
|    Timeseries     | 计算和展示多个时间序列数据。                                 |
| Vertical bar
chart | 用垂直条形图作为一个通用图形。                               |

## 第 2 步: 选择数据源

你可以选择新建或者读取一个已保存的搜索，作为你可视化的数据源。搜索是和一
个或者一系列索引相关联的。如果你选择了在一个配置了多个索引的系统上开始你
的新搜索，从可视化编辑器的下拉菜单里选择一个索引模式。
当你从一个已保存的搜索开始创建并保存好了可视化，这个搜索就绑定在这个可视
化上。如果你修改了搜索，对应的可视化也会自动更新。



## 第 3 步: 可视化编辑器

可视化编辑器用来配置编辑可视化。它有下面几个主要元素：

1. 工具栏(Toolbar)
2. 聚合构建器(Aggregation Builder)
3. 预览画布(Preview Canvas)