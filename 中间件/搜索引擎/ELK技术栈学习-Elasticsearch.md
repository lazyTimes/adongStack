ElasticSearch

## 参考链接：https://fuxiaopang.gitbooks.io/learnelasticsearch/

### 安装Elastic(参考过去笔记)

### 安装 Sense

```
Sense 是一个 Kibana 程序，它的交互式控制台可以帮助你直接通过浏览器向 Elasticsearch
提交请求。 在本书的在线版中，众多的代码示例都包含了 View in Sense 链接。当你点击之
后，它将自动在 Sense 控制台中运行这段代码。你并不是一定要安装 Sense，但那将失去很
多与本书的互动以及直接在你本地的集群中的实验代码的乐趣。
```

### 在 Kibana 的目录中运行以下命令以下载并安装 Sense 程序:（5.0之后使用devtool进行支持）

### 使用命令进行写入

#### GET方式

```
curl -XGET 'http://localhost:9200/_count?pretty' -d '
{ 
    "query": {
    "match_all": {}
    }
}
'
```

1. 相应的 HTTP 请求方法 或者 变量 :  GET  ,  POST  ,  PUT  ,  HEAD  或者  DELETE  。
2. 集群中任意一个节点的访问协议、主机名以及端口。
3. 请求的路径。
4. 任意一个查询后再加上  ?pretty  就可以生成 更加美观 的JSON反馈，以增强可读性。
5. 一个 JSON 编码的请求主体（如果需要的话）。

##### 响应内容

```
{
    "count" : 0,
    "_shards" : {
        "total" : 5,
        "successful" : 5,
        "failed" : 0
	}
}
```

## 建立一个员工名单

想象我们正在为一个名叫 megacorp 的公司的 HR 部门制作一个新的员工名单系统，这些名
单应该可以满足实时协同工作，所以它应该可以满足以下要求：

+ 数据可以包含多个值的标签、数字以及纯文本内容，
+ 可以检索任何职员的所有数据。
+ 允许结构化搜索。例如，查找30岁以上的员工。
+ 允许简单的全文搜索以及相对复杂的短语搜索。
+ 在返回的匹配文档中高亮关键字。
+ 拥有数据统计与管理的后台。

```
关系数据库 ⇒ 数据库 ⇒ 表 ⇒ 行 ⇒ 列(Columns)
Elasticsearch ⇒ 索引 ⇒ 类型 ⇒ 文档 ⇒ 字段(Fields)
```





## 所以为了创建员工名单，我们需要进行如下操作：

+ 为每一个员工的 文档 创建索引，每个 文档 都包含了一个员工的所有信息
+ 每个文档都会被标记为  employee  类型。
+ 这种类型将存活在  megacorp  这个 索引 中。
+ 这个索引将会存储在 Elasticsearch 的集群中

### 添加一个索引库

```
curl -XPUT 'http://localhost:9200/megacorp/employee/1?pretty' -d '
{
	"first_name" : "John",
	"last_name" : "Smith",
	"age" : 25,
	"about" : "I love to go rock climbing",
	"interests": [ "sports", "music" ]
}'

curl -XPUT 'http://localhost:9200/megacorp/employee/2?pretty' -d '
{
    "first_name" : "Jane",
    "last_name" : "Smith",
    "age" : 32,
    "about" : "I like to collect rock albums",
    "interests": [ "music" ]
}
'

curl -XPUT 'http://localhost:9200/megacorp/employee/3?pretty' -d '
{
    "first_name" : "Douglas",
    "last_name" : "Fir",
    "age" : 35,
    "about": "I like to build cabinets",
    "interests": [ "forestry" ]
}
'
```



```
{
  "_index" : "megacorp",
  "_type" : "employee",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "created" : true
}

megacorp 索引的名字
employee 类型的名字
1 当前员工的ID
```

## 检索文档

```
curl -XGET 'localhost:9200/megacorp/employee/1?pretty'
```

返回的内容包含了这个文档的元数据信息，而 John Smith 的原始 JSON 文档也在  _source
字段中出现了：

```
{
    "_index" : "megacorp",
    "_type" : "employee",
    "_id" : "1",
    "_version" : 1,
    "found" : true,
    "_source" : {
        "first_name" : "John",
        "last_name" : "Smith",
        "age" : 25,
        "about" : "I love to go rock climbing",
        "interests": [ "sports", "music" ]
    }
}
```

> 我们通过将HTTP后的请求方式由  PUT  改变为  GET  来获取文档，同理，我们也可以将其更
> 换为  DELETE  来删除这个文档， HEAD  是用来查询这个文档是否存在的。如果你想替换一个
> 已经存在的文档，你只需要使用  PUT  再次发出请求即可。

## 简易搜索

### 搜索全部员工：

```
curl -XGET 'localhost:9200/megacorp/employee/_search?pretty'
```

### 响应数据

```
{
  "took" : 9,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 3,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Jane",
          "last_name" : "Smith",
          "age" : 32,
          "about" : "I like to collect rock albums",
          "interests" : [
            "music"
          ]
        }
      },
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        }
      },
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "3",
        "_score" : 1.0,
        "_source" : {
          "first_name" : "Douglas",
          "last_name" : "Fir",
          "age" : 35,
          "about" : "I like to build cabinets",
          "interests" : [
            "forestry"
          ]
        }
      }
    ]
  }
}
```

## 查询字符串(query string) 搜索

#### 简写：

```
GET /megacorp/employee/_search?q=last_name:Smith
```



### 非简写：

```
curl -XGET 'localhost:9200/megacorp/employee/_search?q=last_name:Fir&pretty'  （查找last_name=Far的员工）
```



## 使用Query DSL搜索

查询字符串是通过命令语句完成 点对点(ad hoc) 的搜索，但是这也有它的局限性（可参阅

《搜索局限性》章节）。Elasticsearch 提供了更加丰富灵活的查询语言，它被称作 Query

DSL，通过它你可以完成更加复杂、强大的搜索任务。



### 查询语句

```
curl -XGET '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "query" : {
        "match" : {
        	"last_name" : "Smith"
        }
	}
}
'
```



### 查询结果

```
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "2",
        "_score" : 0.2876821,
        "_source" : {
          "first_name" : "Jane",
          "last_name" : "Smith",
          "age" : 32,
          "about" : "I like to collect rock albums",
          "interests" : [
            "music"
          ]
        }
      },
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        }
      }
    ]
  }
}
```



## 更加复杂的搜索

接下来，我们再提高一点儿搜索的难度。我们依旧要寻找出姓 Smith 的员工，但是我们还将
添加一个年龄大于30岁的限定条件。我们的查询语句将会有一些细微的调整来以识别结构化
搜索的限定条件 filter（过滤器）:

```json
curl -XGET 'localhost:9200/megacorp/employee/_search?pretty' -d '
{
    "query" : {
        "filtered":{
            "filter":{
                "range":{
                    "age":{"gt": "30"}
                }
            },
            "query":{
                "match":{
                    "last_name":"Smith"
                }
            }
        }
    }
    
}
'


```

> 这一部分的语句是  range  filter ，它可以查询所有超过30岁的数据 --  gt  代表 greater
> than （大于）

> no [query] registered for [filtered]**
>
> 解决办法: 过滤查询已被**弃用**，并在**ES 5.0**中删除。现在应该使用bool / must / filter查询。

```
curl -XPOST '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
  "query": {
    "bool": {
      "filter": {
        "range": {
          "age": {
            "gt": 20
          }
        }
      },
      "must": {
        "match": {
          "last_name": "Smith"
        }
      }
    }
  }
}
'
```

#### 结果

```
{
  "took" : 9,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "2",
        "_score" : 0.2876821,
        "_source" : {
          "first_name" : "Jane",
          "last_name" : "Smith",
          "age" : 32,
          "about" : "I like to collect rock albums",
          "interests" : [
            "music"
          ]
        }
      },
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        }
      }
    ]
  }
}
```



## 全文搜索

```
curl -XPOST '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "query" : {
        "match" : {
        	"about" : "rock climbing"
        }
    }
}
'
```

#### 结果

```
{
  "took" : 25,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.53484553,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 0.53484553,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        }
      },
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "2",
        "_score" : 0.26742277,
        "_source" : {
          "first_name" : "Jane",
          "last_name" : "Smith",
          "age" : 32,
          "about" : "I like to collect rock albums",
          "interests" : [
            "music"
          ]
        }
      }
    ]
  }
}
```



> 你会发现我们同样使用了  match  查询来搜索  about  字段中的 rock climbing。我们会得到
> 两个匹配的文档：
>
> 通常情况下，Elasticsearch 会通过相关性来排列顺序，第一个结果中，John Smith 的  about
> 字段中明确地写到 rock climbing。而在 Jane Smith 的  about  字段中，提及到了 rock，但
> 是并没有提及到 climbing，所以后者的  _score  就要比前者的低。

## 段落搜索

```
curl -XPOST '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "query" : {
        "match_phrase" : {
        	"about" : "rock climbing"
        }
    }
}
'
```

#### 结果

```
{
  "took" : 23,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 0.53484553,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 0.53484553,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        }
      }
    ]
  }
}
```

## 高亮我们的搜索

```
curl -XPOST '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "query" : {
        "match_phrase" : {
        	"about" : "rock climbing"
        }
    },
    "highlight": {
        "fields" : {
        	"about" : {}
        }
    }
}
'
```

#### 结果

```
{
  "took" : 7,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 0.53484553,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 0.53484553,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        },
        "highlight" : {
          "about" : [
            "I love to go <em>rock</em> <em>climbing</em>"
          ]
        }
      }
    ]
  }
}
```

## 统计

最后，我们还有一个需求需要完成：可以让老板在职工目录中进行统计。Elasticsearch 把这
项功能称作 汇总 (aggregations)，通过这个功能，我们可以针对你的数据进行复杂的统计。
这个功能有些类似于 SQL 中的  GROUP BY  ，但是要比它更加强大。



例如，让我们找一下员工中最受欢迎的兴趣是什么：

```
curl -XPOST '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "aggs": {
    	"all_interests": {
    		"terms": { "field": "interests" }
    	}
    }
}
'
```

> Fielddata is disabled on text fields by default. Set fielddata=true on [interests] in order to load fielddata in memory by uninverting the inverted index. Note that this can however use significant memory. Alternatively use a keyword field instead
>
> 默认情况下，在文本字段上禁用Fielddata。 在[的兴趣]上设置fielddata = true，以便通过反转索引来加载内存中的fielddata。 请注意，这可能会占用大量内存。 或者，也可以使用关键字字段
>
> （fielddata会消耗大量的栈内存，尤其在进行加载文本的时候，所以一单fielddata完成了加载，就会一直存在。）

```
curl -XPOST '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "aggs": {
    	"all_interests": {
    		"terms": { "field": "interests.keyword" }
    	}
    }
}
'
```

#### 结果（截取部分）

```
"aggregations" : {
    "all_interests" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 0,
      "buckets" : [
        {
          "key" : "music",
          "doc_count" : 2
        },
        {
          "key" : "forestry",
          "doc_count" : 1
        },
        {
          "key" : "sports",
          "doc_count" : 1
        }
      ]
    }
  }
```

### 查询汇总

```
curl -XGET '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "query": {
        "match": {
        	"last_name": "Smith"
            }
    	},
        "aggs": {
            "all_interests": {
                "terms": {
                    "field": "interests.keyword"
                }
        }
    }
}
'
```

#### 结果

```
{
  "took" : 11,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "2",
        "_score" : 0.2876821,
        "_source" : {
          "first_name" : "Jane",
          "last_name" : "Smith",
          "age" : 32,
          "about" : "I like to collect rock albums",
          "interests" : [
            "music"
          ]
        }
      },
      {
        "_index" : "megacorp",
        "_type" : "employee",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "first_name" : "John",
          "last_name" : "Smith",
          "age" : 25,
          "about" : "I love to go rock climbing",
          "interests" : [
            "sports",
            "music"
          ]
        }
      }
    ]
  },
  "aggregations" : {
    "all_interests" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 0,
      "buckets" : [
        {
          "key" : "music",
          "doc_count" : 2
        },
        {
          "key" : "sports",
          "doc_count" : 1
        }
      ]
    }
  }
}
```

## 汇总还允许多个层面的统计。比如我们还可以统计每一个兴趣下的平均年龄：

```
curl -XGET '172.18.118.222:9200/megacorp/employee/_search?pretty' -d '
{
    "aggs" : {
        "all_interests" : {
        	"terms" : { "field" : "interests.keyword" },
            "aggs" : {
                "avg_age" : {
                	"avg" : { "field" : "age" }
            	}
    		}
    	}
    }
}
'
```

#### 结果

```
 "aggregations" : {
    "all_interests" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 0,
      "buckets" : [
        {
          "key" : "music",
          "doc_count" : 2,
          "avg_age" : {
            "value" : 28.5
          }
        },
        {
          "key" : "forestry",
          "doc_count" : 1,
          "avg_age" : {
            "value" : 35.0
          }
        },
        {
          "key" : "sports",
          "doc_count" : 1,
          "avg_age" : {
            "value" : 25.0
          }
        }
      ]
    }
  }
```

## ElasticSearch 分布式特性

Elasticsearch 很努力地在避免复杂的分布式系统，很多操作都是自动完成的：

+ 可以将你的文档分区到不同容器或者 分片 中，这些文档可能被存在一个节点或者多个节
  点。
+ 跨节点平衡集群中节点间的索引与搜索负载。
+ 自动复制你的数据以提供冗余副本，防止硬件错误导致数据丢失。
+ 自动在节点之间路由，以帮助你找到你想要的数据。
  无缝扩展或者恢复你的集群

## 空集群

+ 节点 是 Elasticsearch 运行中的实例，而 集群 则包含一个或多个具有相同  cluster.name  的
  节点，它们协同工作，共享数据，并共同分担工作负荷。由于节点是从属集群的，集群会自
  我重组来均匀地分发数据。
+ 集群中的一个节点会被选为 master 节点，它将负责管理集群范畴的变更，例如创建或删除索
  引，添加节点到集群或从集群删除节点。**master 节点无需参与文档层面的变更和搜索**，这意
  味着仅有一个 master 节点并不会因流量增长而成为瓶颈。任意一个节点都可以成为 master
  节点。我们例举的集群只有一个节点，因此它会扮演 master 节点的角色。
+ 作为用户，我们可以访问包括 master 节点在内的集群中的任一节点。每个节点都知道各个文
  档的位置，并能够将我们的请求直接转发到拥有我们想要的数据的节点。无论我们访问的是
  哪个节点，它都会控制从拥有数据的节点收集响应的过程，并返回给客户端最终的结果。这
  一切都是由 Elasticsearch 透明管理的。

## 集群健康

在 Elasticsearch 集群中可以监控统计很多信息，其中最重要的就是：集群健康(cluster
health)。它的  status  有  green  、 yellow  、 red  三种；

```
GET /_cluster/health
```

```
{
    "cluster_name": "elasticsearch",
    "status": "green", <1>
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 0,
    "active_shards": 0,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 0
}
```

### status  是我们最应该关注的字段。

|  状态  |                 意义                 |
| :----: | :----------------------------------: |
| green  |       所有主分片和从分片都可用       |
| yellow | 所有主分片可用，但存在不可用的从分片 |
|  red   |         存在不可用的主要分片         |

## 添加索引（重点）

```
PUT /blogs
{
    "settings" : {
        "number_of_shards" : 3,
        "number_of_replicas" : 1
    }
}
```



## 增加故障转移

（了解）



## 索引一个文档

文档通过 索引  API被索引——存储并使其可搜索。但是最开始我们需要决定我们将文档存储
在哪里。正如之前提到的，一篇文档通过 _index  ,  _type  以及 _id  来确定它的唯一性。我们
可以自己提供一个 _id  ，或者也使用 index  API 帮我们生成一个。

### 使用自己的ID

如果你的文档拥有天然的标示符（例如 user_account  字段或者文档中其他的标识值），这时
你就可以提供你自己的 _id  ，这样使用 index  API：

```
PUT /{index}/{type}/{id}
{
    "field": "value",
    ...
}

PUT /website/blog/123
{
"title": "My first blog entry",
"text": "Just trying this out...",
"date": "2014/01/01"
}
```

### 自增ID

如果我们的数据中没有天然的标示符，我们可以让Elasticsearch为我们自动生成一个。请求
的结构发生了变化：我们把 PUT  ——“把文档存储在这个地址中”变量变成了 POST  ——“把文
档存储在这个地址下”。

```
POST /website/blog/
{
"title": "My second blog entry",
"text": "Still trying this out...",
"date": "2014/01/01"
}
```

> **自生成ID是由22个字母组成的，安全 universally unique identifiers 或者被称为UUIDs。**

### 文档是什么？

在很多程序中，大部分实体或者对象都被序列化为包含键和值的JSON对象。键是一个字段或
者属性的名字，值可以是一个字符串、数字、布尔值、对象、数组或者是其他的特殊类型，
比如代表日期的字符串或者代表地理位置的对象：

### 文档元数据

一个文档不只包含了数据。它还包含了元数据(metadata) —— 关于文档的信息。有三个元数
据元素是必须存在的，它们是：

|  名字  |        说明        |
| :----: | :----------------: |
| _index |   文档存储的地方   |
| _type  | 文档代表的对象种类 |
|  _id   |   文档的唯一编号   |

#### _index

**索引** 类似于传统数据库中的"数据库"——也就是我们存储并且索引相关数据的地方。

> TIP：
>
> 在Elasticsearch中，我们的数据都在分片中被存储以及索引，索引只是一个逻辑命名空间，
> 它可以将一个或多个分片组合在一起。然而，这只是一个内部的运作原理——我们的程序可
> 以根本不用关心分片。对于我们的程序来说，我们的文档存储在索引中。剩下的交给
> Elasticsearch就可以了。

**_type**

每一个类型都拥有自己的映射(mapping)或者结构定义，它们定义了当前类型下的数据结构，
类似于数据库表中的列。所有类型下的文档会被存储在同一个索引下，但是映射会告诉
Elasticsearch不同的数据应该如何被索引。

**_id**

id是一个字符串，当它与 _index  以及 _type  组合时，就可以来代表Elasticsearch中一个特定
的文档。我们创建了一个新的文档时，你可以自己提供一个 _id  ，或者也可以让
Elasticsearch帮你生成一个。

### 搜索文档

要从Elasticsearch中获取文档，我们需要使用同样的 _index  ， _type  以及  _id  但是不同的
HTTP变量 GET  ：

```json
{
    "_index" : "website",
    "_type" : "blog",
    "_id" : "123",
    "_version" : 1,
    "found" : true,
    "_source" : {
    "title": "My first blog entry",
    "text": "Just trying this out..."
    "date": "2014/01/01"
}
```

> pretty
> 美化打印数据
>
> _source  字段不会执行优美打印，它的样子取决于我们录入
> 的样子

GET请求的返回结果中包含 {"found": true}  。这意味着这篇文档确实被找到了。如果我们请
求了一个不存在的文档，我们依然会得到JSON反馈，只是 found  的值会变为 false  。

```json
HTTP/1.1 404 Not Found
Content-Type: application/json; charset=UTF-8
Content-Length: 83
{
    "_index" : "website",
    "_type" : "blog",
    "_id" : "124",
    "found" : false
}
```

### 检索文档中的一部分

通常， GET  请求会将整个文档放入 _source  字段中一并返回。但是可能你只需要 title  字
段。你可以使用 _source  得到指定字段。如果需要多个字段你可以使用**逗号**分隔：

```
GET /website/blog/123?_source=title,text
```

#### 现在 _source  字段中就只会显示你指定的字段：

```json
{
    "_index" : "website",
    "_type" : "blog",
    "_id" : "123",
    "_version" : 1,
    "exists" : true,
    "_source" : {
    	"title": "My first blog entry" ,
    	"text": "Just trying this out..."
    }
}
```

或者你只想得到 _source  字段而不要其他的元数据，你可以这样请求：

```
GET /website/blog/123/_source
```

## 检查文档是否存在

如果确实想检查一下文档是否存在，你可以试用 HEAD  来替代 GET  方法，这样就是会返回
HTTP头文件：

```
curl -i -XHEAD /website/blog/123
```

### 如果文档存在，Elasticsearch将会返回 200 OK  的状态码：

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Content-Length: 0
```

如果不存在将会返回 404 Not Found  状态码：

```
curl -i -XHEAD /website/blog/124
```

```
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=UTF-8
Content-Length: 0
```

## 更新整个文档

在Documents中的文档是不可改变的。所以如果我们需要改变已经存在的文档，我们可以使
用《索引》中提到的 index  API来重新索引或者替换掉它：

```
PUT /website/blog/123
{
"title": "My first blog entry",
"text": "I am starting to get the hang of this...",
"date": "2014/01/02"
}
```

在反馈中，我们可以发现Elasticsearch已经将 _version  数值增加了：

```
{
    "_index" : "website",
    "_type" : "blog",
    "_id" : "123",
    "_version" : 2,
    "created": false 
}
```

### created  被标记为  false  是因为在同索引、同类型下已经存在同ID的文档

在内部，Elasticsearch已经将旧文档标记为删除并且添加了新的文档。旧的文档并**不会立即**
**消失**，但是你也**无法访问**他。Elasticsearch会在你继续添加更多数据的时候在**后台清理**已经
删除的文件。

1. 从旧的文档中检索JSON
2. 修改它
3. 删除修的文档
4. 索引一个新的文档

### 唯一不同的是，使用了 update  API你就不需要使用 get  然后再操作 index  请求了。

## <font color='red'>创建一个文档</font>

请牢记 **_index  , _type  以及 _id**  组成了唯一的文档标记，所以为了确定我们创建的是全新的
内容，最简单的方法就是使用 POST  方法，让Elasticsearch自动创建不同的 _id  ：

> POST /website/blog/
> { ... }



然而，我们可能已经决定好了 _id  ，所以需要告诉Elasticsearch只有当 **_index  ， _type  以**
**及 _id**  这3个属性**全部相同的文档不存在**时才接受我们的请求。实现这个目的有两种方法，他
们实质上是一样的，你可以选择你认为方便的那种：

### 第一种是在查询中添加 op_type  参数：

```
PUT /website/blog/123?op_type=create
{ ... }
```

### 或者在请求最后添加  /_create  :

```
PUT /website/blog/123/_create
{ ... }
```

#### 1. 创建成功，Elasticsearch将会返回常见的元数据以及 201 Created  的HTTP反馈码。

#### 2. 存在同名文件 ，Elasticsearch将会返回一个 409 Conflict  的HTTP反馈码，以及如下方的错误信息：

> {
> ​	"error" : "DocumentAlreadyExistsException[[website][4] [blog][123]:
> ​	document already exists]",
> ​	"status" : 409
> }

## 删除一个文档

```
DELETE /website/blog/123
```

如果文档存在，那么Elasticsearch就会返回一个 200 OK  的HTTP响应码

```
{
    "found" : true,
    "_index" : "website",
    "_type" : "blog",
    "_id" : "123",
    "_version" : 3
}
```

如果文档不存在，那么我们就会得到一个 404 Not Found  的响应码，返回的内容就会是这样
的：

```
{
    "found" : false,
    "_index" : "website",
    "_type" : "blog",
    "_id" : "123",
    "_version" : 4
}
```

注意：尽管文档并不存在（ "found"  值为 false  ），**但是 _version  的数值仍然增加了**。这个就是内
部管理的一部分，它保证了我们在多个节点间的**不同操作的顺序**都被正确标记了。

> 正如我在《更新》一章中提到的，删除一个文档也不会立即生效，它只是被标记成已删除。
> Elasticsearch将会在你之后添加更多索引的时候才会在后台进行删除内容的清理。

## <font color='red'>处理冲突</font>

当你使用 索引  API来更新一个文档时，我们先看到了原始文档，然后修改它，最后一次性地
将整个新文档进行再次索引处理。Elasticsearch会根据请求发出的顺序来选择出最新的一个
文档进行保存。但是，如果在你修改文档的同时其他人也发出了指令，那么他们的修改将会
丢失。

### 并发处理

以下是两种能避免在并发更新时丢失数据的方法：

1. 悲观并发控制（PCC）

   这一点在**关系数据库**中被广泛使用。假设这种情况很容易发生，我们就可以阻止对这一资源
   的访问。典型的例子就是当我们在读取一个数据前先锁定这一行，然后确保只有读取到数据
   的这个线程可以修改这一行数据。

2. 乐观并发控制（OCC）

   Elasticsearch所使用的。假设这种情况并不会经常发生，也不会去阻止某一数据的访问。然
   而，如果基础数据在我们读取和写入的间隔中发生了变化，更新就会失败。这时候就由程序
   来决定如何处理这个冲突。例如，它可以重新读取新数据来进行更新，又或者它可以将这一
   情况直接反馈给用户。



---------------

## 乐观并发控制

Elasticsearch是分布式的。当文档被创建、更新或者删除时，新版本的文档就会被复制到集
群中的其他节点上。Elasticsearch即是同步的又是异步的，也就是说复制的请求被平行发送
出去，然后可能会混乱地到达目的地。这就需要一种方法能够保证新的数据不会被旧数据所
覆盖。

我们在上文提到每当有 索引  、 put  和 删除  的操作时，无论文档有没有变化，它
的 _version  都会增加。**Elasticsearch使用 _version  来确保所有的改变操作都被正确排序**。如
果一个旧的版本出现在新版本之后，它就会被忽略掉。

我们可以利用 _version  的优点来确保我们程序修改的数据冲突不会造成数据丢失。我们可以
按照我们的想法来指定 _version  的数字。如果数字错误，请求就是失败。

### 下面是一个示例

1. 创建一个新的博文

```
PUT /website/blog/1/_create
{
    "title": "My first blog entry",
    "text": "Just trying this out..."
}
```

2. 首先我们先要得到文档：

```
{
    "_index" : "website",
    "_type" : "blog",
    "_id" : "1",
    "_version" : 1,
    "found" : true,
    "_source" : {
        "title": "My first blog entry",
        "text": "Just trying this out..."
    }
}

```

返回结果显示 _version  为 1  ：

3. 现在，我们试着重新索引文档以保存变化，我们这样指定了 version  的数字：

```
PUT /website/blog/1?version=1
{
"title": "My first blog entry",
"text": "Starting to get the hang of this..."
}
```

4. 我们只希望当索引中文档的 _version  是 1  时，更新才生效。请求成功相应，返回内容告诉我们 _version  已经变成了 2  ：

```
{
    "_index": "website",
    "_type": "blog",
    "_id": "1",
    "_version": 2
    "created": false
}
```

5. 然而，当我们再执行同样的索引请求，并依旧指定 version=1  时，Elasticsearch就会返回一
   个 409 Conflict  的响应码，返回内容如下：

```
{
    "error" : "VersionConflictEngineException[[website][2] [blog][1]:
    version conflict, current [2], provided [1]]",
    "status" : 409
}
```

6. 所有的有关于更新或者删除文档的API都支持 version  这个参数，有了它你就通过修改你的程
   序来使用乐观并发控制。

## 使用外部系统的版本

还有一种常见的情况就是我们还是使用其他的数据库来存储数据，而Elasticsearch只是帮我

们检索数据。这也就意味着主数据库只要发生的变更，就需要将其拷贝到Elasticsearch中。

如果多个进程同时发生，就会产生上文提到的那些并发问题。



如果你的数据库已经存在了版本号码，或者也可以代表版本的 时间戳  。这是你就可以在

Elasticsearch的查询字符串后面添加 version_type=external  来使用这些号码。**版本号码必须**

**要是大于零小于 9.2e+18  （Java中long的最大正值）的整数**。



Elasticsearch在处理外部版本号时会与对内部版本号的处理有些不同。它不再是检

查 _version  是否与请求中指定的数值相同,而是**检查当前的 _version  是否比指定的数值小**。

如果请求成功，那么外部的版本号就会被存储到文档中的 _version  中。

### 例如，创建一篇使用外部版本号为 5  的博文，我们可以这样操作：

```json
PUT /website/blog/2?version=5&version_type=external
{
    "title": "My first external blog entry",
    "text": "Starting to get the hang of this..."
}
```

## 更新文档中的一部分 

**文档不能被修改，它们只能被替换掉**。 更新  API也必须遵循这一法则。从
**表面**看来，貌似是文档**被替换**了。**对内而言，它必须按照找回-修改-索引的流程来进行操作与**
**管理**。不同之处在于这个流程是在一个片(shard) 中完成的，因此可以节省多个请求所带来的
网络开销。除了节省了步骤，同时我们也能减少多个进程造成冲突的可能性。

使用 更新  请求最简单的一种用途就是添加新数据。新的数据会被合并到现有数据中，而如果
存在相同的字段，就会被新的数据所替换。例如我们可以为我们的博客添加 tags  和 views  字
段：

```json
POST /website/blog/1/_update
{
    "doc" : {
        "tags" : [ "testing" ],
        "views": 0
    }
}
```

### 如果请求成功，我们就会收到一个类似于 索引  时返回的内容:

```
{
    "_index" : "website",
    "_id" : "1",
    "_type" : "blog",
    "_version" : 3
}
```

### 再次取回数据，你可以在 _source  中看到更新的结果：

```
{
    "_index": "website",
    "_type": "blog",
    "_id": "1",
    "_version": 3,
    "found": true,
    "_source": {
        "title": "My first blog entry",
        "text": "Starting to get the hang of this...",
        "tags": [ "testing" ], 
        "views": 0 
    }
}
```

> **MVEL是一个简单高效的JAVA基础动态脚本语言**，它的语法类似于Javascript。你可以
> 在**Elasticsearch scripting docs** 以及 **MVEL website**了解更多关于MVEL的信息。



### 脚本语言可以在 更新  API中被用来修改 _source  中的内容，而它在脚本中被称为 ctx._source  。例如，我们可以使用脚本来增加博文中 views  的数字：

```
POST /website/blog/1/_update
{
    "script" : "ctx._source.views+=1"
}
```



这样Elasticsearch就可以重新使用这个脚本进行tag的添加，而不用再次重新编写脚本了：

```
POST /website/blog/1/_update
{
    "script" : "ctx._source.tags+=new_tag",
    "params" : {
   	 	"new_tag" : "search"
    }
}
```

#### 结果

```
{
    "_index": "website",
    "_type": "blog",
    "_id": "1",
    "_version": 5,
    "found": true,
    "_source": {
        "title": "My first blog entry",
        "text": "Starting to get the hang of this...",
        "tags": ["testing", "search"], <1>
        "views": 1 <2>
     }
}
```

1.  tags  数组中出现了 search  。
2.  views  字段增加了。



使用 ctx.op  来根据内容选择是否删除一个文档：

```
POST /website/blog/1/_update
{
    "script" : "ctx.op = ctx._source.views == count ? 'delete' : 'none'",
    "params" : {
   	 	"count": 1
    }
}
```

## 更新一篇可能不存在的文档

我们可以使用 upsert  参数来设定文档不存在时，它应该被创建：

```
POST /website/pageviews/1/_update
{
    "script" : "ctx._source.views+=1",
    "upsert": {
        "views": 1
    }
}
```

首次运行这个请求时， upsert  的内容会被索引成新的文档，它将 views  字段初始化为 1  。当之后再请求时，文档已经存在，所以 脚本  更新就会被执行， views  计数器就会增加。

## 更新和冲突

你可以通过设定 retry_on_conflict  参数来设置自动完成这项请求的次数，它的默认值是 0  。

```
POST /website/pageviews/1/_update?retry_on_conflict=5 <1>
{
    "script" : "ctx._source.views+=1",
    "upsert": {
    	"views": 0
    }
}
```

### 失败前重新尝试5次

这个参数非常适用于类似于增加计数器这种无关顺序的请求，但是还有些情况的顺序就是很
重要的。例如上一节提到的情况，你可以参考乐观并发控制以及悲观并发控制来设定文档的
版本号。

## 获取多个文档

如果你需要从Elasticsearch中获取多个文档，你可以使用multi-get 或者
mget  API来取代一篇又一篇文档的获取。

mget  API需要一个 **docs  数组**，每一个元素包含你想要的文档的 **_index  ,  _type  以及 _id**  。
你也可以指定 _source  参数来设定你所需要的字段：

```
GET /_mget
{
    "docs" : [
        {
            "_index" : "website",
            "_type" : "blog",
            "_id" : 2
        },
        {
            "_index" : "website",
            "_type" : "pageviews",
            "_id" : 1,
            "_source": "views"
        }
    ]
}
```

返回值包含了一个 docs  数组，这个数组以请求中指定的顺序每个文档包含一个响应。每一个
响应都和独立的 get  请求返回的响应相同：

```
{
    "docs" : [
        {
            "_index" : "website",
            "_id" : "2",
            "_type" : "blog",
            "found" : true,
            "_source" : {
                "text" : "This is a piece of cake...",
                "title" : "My first external blog entry"
            },
            "_version" : 10
        },
        {
            "_index" : "website",
            "_id" : "1",
            "_type" : "pageviews",
            "found" : true,
            "_version" : 2,
            "_source" : {
                "views" : 2
            }
        }
    ]
}
```

如果你所需要的文档都在同一个 _index  或者同一个 _type  中，你就可以在URL中指定一个默
认的 /_index  或是 /_index/_type  。

```
GET /website/blog/_mget
{
    "docs" : [
        { "_id" : 2 },
        { "_type" : "pageviews", "_id" : 1 }
    ]
}
```

事实上，如果所有的文档拥有相同的 _index  以及  _type  ，直接在请求中添加 ids  的数组即
可：

```
GET /website/blog/_mget
{
	"ids" : [ "2", "1" ]
}
```

**请注意，我们所请求的第二篇文档不存在，这是就会返回如下内容：**

```
{
    "docs" : [
        {
            "_index" : "website",
            "_type" : "blog",
            "_id" : "2",
            "_version" : 10,
            "found" : true,
            "_source" : {
                "title": "My first external blog entry",
                "text": "This is a piece of cake..."
            }
        },
        {
            "_index" : "website",
            "_type" : "blog",
            "_id" : "1",
            "found" : false <1>
        }
    ]
}
```

### 要确定独立的文档是否被成功找到，你需要检查 found  标识。



## 批量更高效

与 mget  能同时允许帮助我们获取多个文档相同， **bulk  API可以帮助我们同时完成执行多个**
**请求**，比如： create  ， index  ,  update  以及 delete  。当你在处理类似于log等海量数据的时
候，你就可以一下处理成百上千的请求，这个操作将会极大提高效率。

### bulk  的请求主体的格式稍微有些不同：

```
{ action: { metadata }}\n
{ request body }\n
{ action: { metadata }}\n
{ request body }\n
...
```

#### 这种格式就类似于一个用 "\n"  字符来连接的单行json一样。下面是两点注意事项：

1. 每一行都结尾处都必须有换行字符 "\n"  ，最后一行也要有。这些标记可以有效地分隔每

   行。

2. 这些行里不能包含非转义字符，以免干扰数据的分析 — — 这也意味着JSON不能是
   pretty-printed样式。

### action/metadata 行指定了将要在哪个文档中执行什么操作。

其中action必须是 index  ,  create  ,  update  或者 delete  。metadata 需要指明需要被操作文
档的 _index  ,  _type  以及 _id  ，例如删除命令就可以这样填写：

#### 示例

```
{ "delete": { "_index": "website", "_type": "blog", "_id": "123" }}
```

在你进行 index  以及 create  操作时，request body 行必须要包含文档的 _source  数据——也
就是文档的所有内容。
同样，在执行 update  API:  doc  ,  upsert  , script  的时候，也需要包含相关数据。而在删除
的时候就不需要request body行。

```
{ "create": { "_index": "website", "_type": "blog", "_id": "123" }}
{ "title": "My first blog post" }
```

如果没有指定 _id  ，那么系统就会自动生成一个ID：

```
{ "index": { "_index": "website", "_type": "blog" }}
{ "title": "My second blog post" }
```

### 完成以上所有请求的 bulk  如下：

```
POST /_bulk
{ "delete": { "_index": "website", "_type": "blog", "_id": "123" }} <1>
{ "create": { "_index": "website", "_type": "blog", "_id": "123" }}
{ "title": "My first blog post" }
{ "index": { "_index": "website", "_type": "blog" }}
{ "title": "My second blog post" }
{ "update": { "_index": "website", "_type": "blog", "_id": "123", "_retry_on_conflict"
: 3} }
{ "doc" : {"title" : "My updated blog post"} } <2>
```

1. 注意 delete  操作是如何处理request body的,你可以在它之后直接执行新的操作。
2. 请记住最后有换行符

#### Elasticsearch会返回含有 items  的列表、它的顺序和我们请求的顺序是相同的：

```json
{
    "took": 4,
    "errors": false, <1>
    "items": [
        { "delete": {
            "_index": "website",
            "_type": "blog",
            "_id": "123",
            "_version": 2,
            "status": 200,
            "found": true
        }},
        { "create": {
            "_index": "website",
            "_type": "blog",
            "_id": "123",
            "_version": 3,
        	"status": 201
        }},
        { "create": {
            "_index": "website",
            "_type": "blog",
            "_id": "EiwfApScQiiy7TIKFxRCTw",
            "_version": 1,
            "status": 201
        }},
        { "update": {
            "_index": "website",
            "_type": "blog",
            "_id": "123",
            "_version": 4,
            "status": 200
        }}
    ]
}}
```

所有的请求都被**成功**执行。

每一个子请求都会被单独执行，所以一旦有一个子请求失败了，**并不会影响到其他请求的成**
**功执行**。如果一旦**出现失败的请求**， **error  就会变为 true**  ，详细的错误信息也会出现在返回
内容的下方：

```
POST /_bulk
{ "create": { "_index": "website", "_type": "blog", "_id": "123" }}
{ "title": "Cannot create - it already exists" }
{ "index": { "_index": "website", "_type": "blog", "_id": "123" }}
{ "title": "But we can update it" }
```

#### 失败结果：

```json
{
    "took": 3,
    "errors": true, <1>
    "items": [
        { "create": {
            "_index": "website",
            "_type": "blog",
            "_id": "123",
            "status": 409, <2>
            "error": "DocumentAlreadyExistsException <3>
                    [[website][4] [blog][123]:
                    document already exists]"
        }},
        { "index": {
            "_index": "website",
            "_type": "blog",
            "_id": "123",
            "_version": 5,
            "status": 200 <4>
        }}
    ]
}
```

1. 至少有一个请求错误发生。
2. 这条请求的状态码为 409 CONFLICT  。
3. 错误信息解释了导致错误的原因。
4. 第二条请求的状态码为 200 OK  。

### 能省就省

或许你在批量导入大量的数据到相同的 index  以及 type  中。每次都去指定每个文档的
metadata是完全没有必要的。在 mget  API中， bulk  请求可以在URL中声明 /_index  或
者 /_index/_type  ：

```
POST /website/_bulk
{ "index": { "_type": "log" }}
{ "event": "User logged in" }
```

你依旧可以在metadata行中使用 _index  以及 _type  来重写数据，未声明的将会使用URL中的
配置作为默认值：

```
POST /website/log/_bulk
{ "index": {}}
{ "event": "User logged in" }
{ "index": { "_type": "blog" }}
{ "title": "Overriding the default type" }
```

### 最大有多大？

试着去批量索引越来越多的文档。当性能开始下降的时候，就说明你的数据量太大了。一般
比较好初始数量级是1000到5000个文档，或者你的文档很大，你就可以试着减小队列。 有的
时候看看批量请求的物理大小是很有帮助的。1000个1KB的文档和1000个1MB的文档的差距
将会是天差地别的。比较好的初始批量容量是5-15MB。



# 分布式文档存储

## 将文档路由到从库中

```
分片 = hash(routing) % 主分片数量
```

routing  值可以是任何的字符串， 默认是文档的  _id  ，但也可以设置成一个自定义的值。
routing  字符串被传递到一个哈希函数以生成一个数字，然后除以索引的主分片的数量 得到
余数 remainder. 余数将总是在  0  到  主分片数量 - 1  之间, 它告诉了我们用以存放 一个特定
文档的分片编号。

**解释了为什么主分片的数量只能在索引创建时设置、而且不能修改。 如果主分片的数量一**
**旦在日后进行了修改，所有之前的路由值都会无效，文档再也无法被找到。**

### 所有文档 APIs ( get  ,  index  ,  delete  ,  bulk  ,  update  和  mget  ) 都可以接受  routing  参数

## 主从库之间是如何通信的

为了便于说明，假设我们有由3个节点的集群。 它
包含一个名为blogs的索引，它有两个主分片。 每个主要分片都有
两个副本。 永远不会将同一分片的副本分配给同一节点，因此我们的群集也是如此
看起来像<>。

> **[[img-distrib]] .A cluster with three nodes and one index image::images/04-01_index.png["A**
> **cluster with three nodes and one index"]**

我们可以将请求发送到集群中的任何节点。 每个节点都完全有能力服务任何要求。 每个节点都知道集群中每个文档的位置，因此也可以将请求直接转发到所需节点。 在下面的例子中，我们将发送所有的对节点1的请求，我们将其称为请求节点。

> 提示：发送请求时，最好通过**循环遍历所有节点集群**，以分散负载。

### 创建，索引和删除请求是写操作，必须成功

下面我们列出了成功创建，索引或删除a所需的步骤顺序
主要和任何副本分片上的文档，如<>中所述：

1. 客户端向Node_1发送创建，索引或删除请求。
2. 节点使用文档的_id来确定文档属于分片
   0。它将请求转发到节点3，其中当前是碎片0的主副本
   分配。
3. 节点3在主分片上执行请求。如果成功，它会转发
   并行请求节点1和节点2上的副本分片。一旦所有的复制品
   分片报告成功，节点3向报告的请求节点报告成功
   对客户的成功。

注意：

1. 复制的默认值是sync。 这会导致主分片等待在返回之前来自副本分片的成功响应。
2. 如果将复制设置为异步，则会立即将成功返回给客户端
3. 请求已在主分片上执行。 它仍然会将请求转发给复制品，但你不知道复制品是否成功。
4. 建议使用默认的同步复制，因为可以重载Elasticsearch通过发送太多请求而不等待他们的

默认情况下，主分片需要法定数量或大多数分片副本（分片所在的位置）复制可以是主要或副本碎片）甚至在尝试写入之前可用操作。这是为了防止将数据写入网络分区的“错误一侧”。一个
仲裁定义为：

```
int( (primary + number_of_replicas) / 2 ) + 1
```

允许的一致性值是一个（只是主要分片），所有（主要的）和所有副本）或默认仲裁或大多数碎片副本。请注意，number_of_replicas是索引设置中指定的副本数，不是当前活动的副本数量。如果您指定了索引应该有3个副本，然后是法定人数：

```
int( (primary + 3 replicas) / 2 ) + 1 = 3
```

默认情况下，新索引具有1个分片，这意味着应该有两个活动分片副本为了满足法定人数的需要而需要。 但是，这些默认设置会阻止我们对单节点集群做任何有用的事情。 为了避免这个问题，要求

### **a quorum is only enforced when number_of_replicas  is greater than  1  .**

**仅当number_of_replicas大于1时才会强制执行仲裁**

## 获取一个文档

下面我们列出从主服务器或副本服务器检索文档的步骤顺序
碎片，如<>所示：

1. 客户端向节点1发送get请求。
2. 节点使用文档的_id来确定文档属于分片0。所有三个节点上都存在shard 0的副本。在这个场合，它转发了请求节点2。
3. 节点2将文档返回到节点1，节点1将文档返回给客户端。

对于读取请求，请求节点将在每个请求上选择不同的分片副本为了平衡负载 - 它循环遍历所有碎片副本。

文档可能已在主分片上编入索引但尚未编入索引复制到副本分片。在这种情况下，副本可能会报告文档没有存在，而主要成功返回文档。

## 更新文档中的一部分

下面我们列出用于对文档执行部分更新的步骤序列，如
在<>中描述：

1.客户端向Node_1发送更新请求。

2.它将请求转发到节点3，在节点3中分配主分片。

3.节点3从主分片中检索文档，更改中的JSON_source字段，并尝试在主分片上重新索引文档。如果是文件已被另一个进程更改，它重试第3步放弃之前retry_on_conflict次。

4.如果节点3已成功更新文档，则转发新文档与节点1和节点2上的副本分片并行的文档版本重建索引。一旦所有副本分片报告成功，节点3就会报告成功请求节点，向客户端报告成功。更新API还接受路由，复制，一致性和超时
<>中解释的参数

> NOTE
>
> **当主分片将更改转发到其副本分片时，它不会转发更新请求。 相反，它转发整个文档的新版本。 请记住这些更改将异步转发到副本分片，并且无法保证他们将按照他们发送的顺序到达。 如果Elasticsearch只转发了更改，可能会以错误的顺序应用更改，从而导致损坏文献。**

## 多文档模式

mget和批量API的模式与单个文档的模式类似。不同之处在于请求节点知道每个文档在哪个分片中存在。它将多文档请求分解为每个分片的多文档请求，以及将这些并行转发到每个参与节点。

一旦它从每个节点接收到答案，它就会将他们的响应整理成一个响应，它返回给客户端。

[[img-distrib-mget]] .Retrieving multiple documents with  mget  image::images/04-
05_mget.png["Retrieving multiple documents with mget"]

### 下面我们列出了使用单个文档检索多个文档所需的步骤顺序

mget请求，如<>所示：

1.客户端向Node_1发送mget请求。

2.节点1为每个分片构建一个多重获取请求，并将这些请求并行转发托管每个所需主要或副本分片的节点。一旦所有回复都是收到后，节点1构建响应并将其返回给客户端。可以为docs数组中的每个文档和首选项设置路由参数可以为顶级mget请求设置参数。

下面我们列出执行多个create，index所需的步骤序列，

#### 在单个批量请求中删除和更新请求，如<>中所述：

1.客户端向Node_1发送批量请求。

2.节点1为每个分片构建一个批量请求，并将这些请求并行转发给托管每个节点的节点都涉及主分片。

3.主分片一个接一个地连续执行每个动作。作为每个动作成功后，主要将新文档（或删除）转发到其副本分片中并行，然后继续下一个动作。一旦所有副本分片报告所有人都成功动作，节点向请求节点报告成功，该节点整理响应并将它们返回给客户端。批量API还接受顶级的复制和一致性参数

#### 对于整个批量请求，以及每个请求的元数据中的路由参数。

## Why the funny format?

### 当我们在<>之前了解批量请求时，您可能会问自己：<font color='red'>为什么批量API是否需要带有换行符的有趣格式</font>，而不仅仅是发送包含在JSON数组中的请求，比如mget` API？''

要回答这个问题，我们需要解释一下背景：

批量请求中引用的每个文档可以属于不同的主分片,其中的一部分可以分配给集群中的任何节点。这意味着每一个动作,批量请求内部需要转发到正确节点上的正确分片。如果单个请求被包装在JSON数组中，那就意味着我们会这样做

需要：

1. 将JSON解析为数组（包括文档数据，可能非常大）
2. 查看每个请求以确定它应该去哪个分片
3. 为每个分片创建一组请求
4. 将这些数组序列化为内部传输格式
5. 将请求发送到每个分片

它可以工作，但需要大量的RAM来保存基本相同数据的副本，并且会创建更多的数据结构，JVM必须花费时间垃圾
收集。

相反，Elasticsearch会进入原始请求所在的网络缓冲区已收到并直接读取数据。它使用换行符来识别和只解析小动作/元数据行，以决定哪个分片应该处理每个分片请求。

这些原始请求将直接转发到正确的分片。没有多余的复制数据，没有浪费的数据结构。整个请求过程在中处理最小的内存量。



# 搜索

+ 类似于 年龄  、 性别  、 加入日期  等结构化数据，类似于在SQL中进行查询。
+ 全文搜索，查找整个文档中匹配关键字的内容，并根据相关性
+ 或者结合两者。

虽然很多搜索操作是安装好Elasticsearch就可以用的，但是想发挥它的潜力，你需要明白以
下内容：

|       名字       |                说明                 |
| :--------------: | :---------------------------------: |
|  映射 (Mapping)  |     每个字段中的数据如何被解释      |
| 统计 (Analysis)  |     可搜索的全文是如何被处理的      |
| 查询 (Query DSL) | Elasticsearch使用的灵活强的查询语言 |

## 空白搜索

搜索API最常用的一种形式就是空白搜索，也就是不加任何查询条件的，只是返回集群中所有
文档的搜索。

```
GET /_search
```

返回内容如下（有删减）：

```
{
    "hits" : {
    "total" : 14,
    "hits" : [
        {
            "_index": "us",
            "_type": "tweet",
            "_id": "7",
            "_score": 1,
            "_source": {
                "date": "2014-09-17",
                "name": "John Smith",
                "tweet": "The Query DSL is really powerful and flexible",
                "user_id": 2
        	}
        },
        ... 9 个结果被隐藏 ...
        ],
        "max_score" : 1
        },
            "took" : 4,
            "_shards" : {
                "failed" : 0,
                "successful" : 10,
                "total" : 10
        },
        "timed_out" : false
}
```

### hits

返回内容中最重要的内容就是 hits  ，它指明了匹配查询的文档的 **总数**  ， hits  数组里则会包
含前十个匹配文档——也就是搜索结果。



hits  数组中的每一条结果都包含了文档的 _index  ,  _type  以及 _id  信息，以及 _source  字
段。这也就意味着你可以直接从搜索结果中获取到整个文档的内容。这与其他搜索引擎只返
回给你文档编号，还需要自己去获取文档是截然不同的。

每一个元素还拥有一个 **_score  字段**。这个是**相关性评分**，这个数值表示当前文档与查询的匹
配程度。通常来说，搜索结果会先返回最匹配的文档，也就是说它们会**按照 _score  由高至低**
**进行排列**。在这个例子中，我们并没有声明任何查询，因此 _score  就都会返回 1

**max_score  数值会显示所有匹配文档中的 _score  的最大值。**

### took

took  数值告诉我们执行这次搜索请求所耗费的时间有多少毫秒。

### shards

**_shards  告诉了我们参与查询分片的总数**，以及有多少 **successful**  和 **failed**  。通常情况下
我们是不会得到失败的反馈，但是有的时候它会发生。如果我们的服务器突然出现了重大事
故，然后我们丢失了同一个分片中主从两个版本的数据。在查询请求中，无法提供可用的备
份。这种情况下，Elasticsearch就会返回`failed提示，但是它还会继续返回剩下的内容。

### timeout

timed_out  数值告诉了我们查询是否超时。通常，搜索请求不会超时。如果相比完整的结果
你更需要的是快速的响应时间，这是你可以指定 timeout  值，例如 10  、 "10ms"  （10毫秒）
或者 "1s"  （1秒钟）：

```
GET /_search?timeout=10ms
```

Elasticsearch会尽可能地返回你指定时间内它所查到的内容

> **Timeout并不是终止者**
>
> 这里应该强调一下 timeout  并不会终止查询，它只是会在你指定的时间内返回当时已经查询
> 到的数据，然后关闭连接。在后台，其他的查询可能会依旧继续，尽管查询结果已经被返回
> 了。
> 使用超时是因为你要保障你的品质，并不是因为你需要终止你的查询。



## 多索引，多类型

当我们没有特别指定一个索引或者类型的时候，我们将会搜索整个集群中的所有文档。
Elasticsearch会把搜索请求转发给集群中的每一个主从分片，然后按照结果的相关性得到前
十名，并将它们返回给我们。

| URL                       | 说明                                                         |
| :------------------------ | :----------------------------------------------------------- |
| /_search                  | 搜索所有的索引和类型                                         |
| /gb/_search               | 搜索索引 gb  中的所有类型                                    |
| /gb,us/_search            | 搜索索引 gb  以及 us  中的所有类型                           |
| /g*,u*/_search            | 搜索所有以 g  或 u  开头的索引中的所有类型                   |
| /gb/user/_search          | 搜索索引 gb  中类型 user  内的所有文档                       |
| /gb,us/user,tweet/_search | 搜索索引 gb  和 索引 us  中类型 user  以及类型 tweet  内的所有文档 |
| /_all/user,tweet/_search  | 搜索所有索引中类型为 user  以及 tweet  内的所有文档          |

搜索一个拥有五个主分片的索引与搜索五个都只拥有一个主分片是完全一样的。



## 分页

与SQL使用 LIMIT  来控制单“页”数量类似，Elasticsearch使用的是 from  以及 size  两个参
数：

| 参数 | 说明                            |
| ---- | ------------------------------- |
| size | 每次返回多少个结果，默认值为 10 |
| from | 忽略最初的几条结果，默认值为 0  |

假设每页显示5条结果，那么1至3页的请求就是：

```
GET /_search?size=5
GET /_search?size=5&from=5
GET /_search?size=5&from=10
```

当心不要一次请求过多或者页码过大的结果。它们会在返回前排序。一个请求会经过多个分
片。每个分片都会生成自己的排序结果。然后再进行集中整理，以确保最终结果的正确性。

> **分布式系统中的大页码页面**
> 为了说明白为什么页码过大的请求会产生问题，我们就先预想一下我们在搜索一个拥有5个主
> 分片的索引。当我们请求第一页搜索的时候，每个分片产生自己前十名，然后将它们返回给
> 请求节点，然后这个节点会将50条结果重新排序以产生最终的前十名。
> 现在想想一下我们想获得第1,000页，也就是第10,001到第10,010条结果，与之前同理，每一
> 个分片都会先产生自己的前10,010名，然后请求节点统一处理这50,050条结果，然后再丢弃
> 掉其中的50,040条！
>
> 现在你应该明白了，在分布式系统中，大页码请求所消耗的系统资源是呈指数式增长的。这
> 也是为什么网络搜索引擎不会提供超过1,000条搜索结果的原因。

## 精简 搜索

搜索的API分为两种：其一是通过参数来传递查询的“精简版”查询语句（query string），还有
一种是通过JSON来传达丰富的查询的完整版请求体（request body），这种搜索语言被称为
查询DSL。

查询语句在行命令中运行点对点查询的时候非常实用。比如我想要查询所有 tweet  类型中，
所有 tweet  字段为 "elasticsearch"  的文档：

```
GET /_all/tweet/_search?q=tweet:elasticsearch
```

下一个查询是想要寻找 name  字段为 "john"  且 tweet  字段为 "mary"  的文档，实际的查询就
是：

```
+name:john +tweet:mary
```

但是经过百分号编码（percent encoding）处理后，会让它看起来稍显神秘:

```
GET /_search?q=%2Bname%3Ajohn+%2Btweet%3Amary
```

前缀 "+"  表示必须要满足我们的查询匹配条件，而前缀 "-"  则表示绝对不能匹配条件。没
有 +  或者 -  的表示可选条件。匹配的越多，文档的相关性就越大。

### 字段 _all

下面这条简单的搜索将会返回所有包含 "mary"  字符的文档：

```
GET /_search?q=mary
```

在之前的例子中，我们搜索 tweet  或者 name  中的文字。然而，搜索的结果显示 "mary"  在三
个不同的字段中：

+ 用户的名字为"Mary"

+ 6个"Mary"发送的推文

+ 1个"@mary“

那么Elasticsearch是如何找到三个不同字段中的内容呢？

当我们在索引一个文档的时候，**Elasticsearch会将所有字段的数值都汇总到一个大的字符串**
**中**，并将它索引成一个特殊的字段 _all  ：

```
{
    "tweet": "However did I manage before Elasticsearch?",
    "date": "2014-09-14",
    "name": "Mary Jones",
    "user_id": 1
}
```

就好像我们已经添加了一个叫做 _all  的字段：

```
"However did I manage before Elasticsearch? 2014-09-14 Mary Jones 1"
```

除非**指定了字段名**，不然**查询语句就会搜索字段 _all**  。

> TIP: 在你刚开始创建程序的时候你可能会经常使用 _all  这个字段。但是慢慢的，你可能就会
> 在请求中指定字段。当字段 _all  已经没有使用价值的时候，那就可以将它关掉。之后的《字
> 段all》一节中将会有介绍



## 更加复杂的查询

再实现一个查询：

+ 字段 name  包含 "mary"  或 "john"
+ date  大于 2014-09-10
+ _all  字段中包含 "aggregations"  或 "geo"

```
+name:(mary john) +date:>2014-09-10 +(aggregations geo)
```

最终处理完的语句可读性可能很差：

```
?q=%2Bname%3A(mary+john)+%2Bdate%3A%3E2014-09-10+%2B(aggregations+geo)
```

**<font color='red'>最后要提一句，任何用户都可以通过查询语句来访问臃肿的查询，或许会得到一些私人的信息，或许会通过大量的运算将你的集群压垮！</font>**

> TIP
> 出于以上原因，我们不建议你将查询语句直接暴露给用户，除非是你信任的可以访问数据与
> 集群的权限用户。

# 映射与统计

当我们在进行搜索的事情，我们会发现有一些奇怪的事情。比如有一些内容似乎是被打破
了：在我们的索引中有12条推文，中有一个包含了 2014-09-15  这个日期，但是看看下面的查
询结果中的总数量：

```
GET /_search?q=2014 # 12 results
GET /_search?q=2014-09-15 # 12 results !
GET /_search?q=date:2014-09-15 # 1 result
GET /_search?q=date:2014 # 0 results !
```

为什么我们使用字段 _all  搜索全年就会返回所有推文，而使用字段 date  搜索年份却没有结
果呢？为什么使用两者所得到的结果是不同的？



推测大概是因为我们的数据在 _all  和 date  在索引时没有被相同处理。我们来看看
Elasticsearch是如何处理我们的文档结构的。我们可以对 gb  的 tweet  使用mapping请求：

```
GET /gb/_mapping/tweet
```

```
{
    "gb": {
        "mappings": {
            "tweet": {
                "properties": {
                    "date": {
                    	"type": "date",
                    	"format": "dateOptionalTime"
                    },
                    "name": {
                    	"type": "string"
                    },
                    "tweet": {
                    	"type": "string"
                    },
                    "user_id": {
                    	"type": "long"
                    }
                }
            }
        }
    }
}
```

Elasticsearch会根据系统自动判断字段类型并生成一个映射。返回结果告诉我们 date  字段被
识别成了 date  类型。 _all  没有出现是因为他是默认字段，但是我们知道字段 _all  实际上
是 string  类型的。

### 所以类型为 date  的字段和类型为 string  的字段的索引方式是不同的。