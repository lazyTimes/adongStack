# 从零开始学Mysql - 字符集和编码（上）
[[从零开始学Mysql - 字符集和编码（下）]]
# 前言

​	上一节我们系统的阐述了关于系统配置的相关细节内容，而这一节我们需要了解关于字符集和编码的内容，字符集和编码的规则其实也算是入门mysql经常遇到的一个坑，基本每个人学习过程必定会遇到数据库存储中文但是读出来是：“???”的这种问题，好了废话不多说，我们来看下mysql的字符集和编码的规则。

# 编码

## 简单介绍

​	关于编码和解码，简单来讲编码就是把字符转变为二进制数据，解码就是把二进制的数据按照一定的规则翻译成字符，关于编解码的定义只需要了解两个重点：

1. 字符是如何映射成为二进制数据的
2. 那些字符需要映射二进制的数据

​	比如我们把abcd拆分成四种自定义的编码格式，使用十六进制表示，a占一位，b占两位，c占3位，d占四位，我们可以使用含有abcd的字符进行不同的组合编码，但是不能对于ef，或者zh等等字符进行编码，因为我们设计的规则不认识这些字符，编码之后的数据按照自己设计的编码解码翻译回原来的数据，这就是最简单的编码和解码规则。



## 如何比较大小

​	我们知道了如何对于字符进行编码，那么我们如何对于字符进行比较呢？我们最可能想到的规则是按照26个字母的顺序进行比较排序大小，其实二进制的比较规则是非常简单的，但是我们会发现有时候会出现特殊的情况，比如英文有大小写之分，而中文又有同音字的等等，这时候就不能简单二进制比较了，我们需要做如下的调整：

- 将字符统一转为大写或者小写再进行二进制的比较
- 或者大小写进行不同大小的编码规则编码

​	所以其实我们可以发现一个字符可能会存在**多个比较方式**，最终意味着字符集会出现多种的比较规则形式。



# 字符集介绍

## 常见字符集

​	经过上面的编码介绍之后，下面我们来介绍关于字符集的内容，全世界的字符集怎么也得又个成百上千种，这还不包含各种自创的字符集，但是实际上主流的也就那么几种，比如：**GBK2312，UTF-8，UTF-16**等等，所以这里只简单列举几个常见的字符集：

- **ASCII 字符集**：共收录128个字符，包括空格、标点符号、数字、大小写字母和一些不可见字符，一共也就128个字符，所以可以直接用一个字节表示，比如下面的内容：
  - 'L' -> 01001100(十六进制:0x4C，十进制:76)
  
  - 'M' -> 01001101(十六进制:0x4D，十进制:77)
  
- **ISO 8859-1 字符集**：欧洲的通用编码，一共是256个字符，主要是在ASCII 字符集字符集的基础上扩展了128个字符，这个字符集也被称为：latin1（拉丁1，有点好奇为什么叫这个名）

- **GB2312**：这个编码其实误导性挺强的，因为基本都知道这是给国人用的，**可能会认为只有汉字的编码**，其实它收录了汉字以及拉丁字母、希腊字母、日文平假名及片假名字母、俄语西里尔字母等多个语言。其中收录汉字6763个， 其他文字符号682个，同时这种字符集又兼容 ASCII 字符集，所以编码方式比较特殊：
  - **ASCII 字符集**：按照ASCII 字符集的规则使用一个字节
  - **其他的GB2312支持的字符集**：使用两个字节进行编码（汉字实在是多，这种编码收录的也是覆盖了最为常用和经常出现的）
  - 如果**出现ASCII和其他字符集混用**，字符需要的字节数可能不同的编码方式称为 **变长编码方式**，比如'啊A'的中文字符需要两个字节编码，但是A需要一个字节的编码，最后再把 **“两个字符”**进行二进制编码的拼凑。

> ​	这些数字不是敏感词，不需要记住数量，只要注意gb2312并不只是只有中文。
>
> ​	补充：这里可能有小伙伴好奇GB2312是怎么认识不同的字符集的，其实很简单，ASCII只有128个，所以只要是在这个范围的，基本可以断定就是ASCII的字符集，所以使用一个字符即可，如果不在这个范围，直接使用两个字节翻译即可。

- **GBK 字符集**：对于GB2312进行字符集的扩展，其他无变化
- **UTF8 字符集**：用苹果的广告词来说就是强者的强的一个字符集，包含了地球上的所有字符，而且因为不同字符集编码的字节数不同，所以UTF-8规定按照1-4个字节的**变长编码方式**进行编码，最后UTF8和gbk一样也兼容了ASCII的字符集。

> 补充：既然提到了UTF-8，那么这里就来说一下Unicode编码的事情，其实**准确来说utf8只是Unicode字符集的其中一种编码方案**，Unicode字符集可以采用utf8、utf16、utf32这几种编码方案，utf8使用1~4个字节编码一个字符，utf16使用2个或4个字节编码一个 字符，utf32使用4个字节编码一个字符。
>
> 另外，Mysql早期的utf8并不是真正意义上的utf8这个后续会进行补充

​	最后我们可以发现，对于同一个字符在不同的字符集会有不同的编码方式，对于一个汉字来说，ASCII字符集没有收录，下面我们比较utf-8和gbk是如何收录的，比如一个字符的'我'汉字假设是如下的编码方式：

+ utf8编码:111001101000100010010001 (3个字节，十六进制表示是:0xE68891) 
+ gb2312编码:1100111011010010 (2个字节，十六进制表示是:0xCED2)

## 如何查看字符集

​	查看字符集的命令十分简单：`show (character set|charset) [like 匹配模式]`，括号内表示可以任选其中一个，比如选择`character set`，当然比较难打，所以`charset`更常用一些，记住这一个即可。

​	下面是具体的案例，可以看到目前mysql支持41种字符集：

```	mysql
> show charset;

armscii8	ARMSCII-8 Armenian	armscii8_general_ci	1
ascii	US ASCII	ascii_general_ci	1
big5	Big5 Traditional Chinese	big5_chinese_ci	2
binary	Binary pseudo charset	binary	1
cp1250	Windows Central European	cp1250_general_ci	1
cp1251	Windows Cyrillic	cp1251_general_ci	1
cp1256	Windows Arabic	cp1256_general_ci	1
cp1257	Windows Baltic	cp1257_general_ci	1
cp850	DOS West European	cp850_general_ci	1
cp852	DOS Central European	cp852_general_ci	1
cp866	DOS Russian	cp866_general_ci	1

> show charset like 'big%';
big5	Big5 Traditional Chinese	big5_chinese_ci	2
```

​	下面是需要记忆的几个字符集，也是最常用的字符集：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211125213721.png)

## 比较规则查看

​	之前介绍过字符集是有比较规则，mysql把比较规则设置为一个命令，查看mysql的比较规则如下：

​	`show collation [like 匹配模式]`

​	下面是比较规则的相关案例，可以看到光是utf开头的比较规则就有150多种：

```mysql
mysql> show collation like 'utf_%';
```

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211125214118.png)

### 比较规则的规律

+ 比较规则和前缀进行匹配，比如utf_8的字符集都是按照utf8开头的。
+ 前缀为字符集的匹配，那么后缀就是和语言有关了，比如utf8_polish_ci按照波兰语匹配，utf8_spanish_ci 是以西班牙语的规则比较，通用匹配规则为: **utf8_general_ci**。
+ 名称后缀意味着该比较规则是否区分语言中的重音、大小写啥，比如ci代表的是不区分大小写。

```
|后缀|英文释义|描述| |:--:|:--:|:--:| | _ai | accent insensitive |不区分重音| | _as | accent sensitive |区分重 音| | _ci | case insensitive |不区分大小写| | _cs | case sensitive |区分大小写| | _bin | binary |以二进制 方式比较|
```

​	**每种字符集对应若干种比较规则，每种字符集都有一种默认的比较规则**，我们可以看到上面的截图中有一个`Default`的列就是当前字符集的默认比较规则。比方说 utf8 字符集默认的比较规则就是` utf8_general_ci `

## 字符集和比较规则级别介绍

​	下面到了本文的重点，MySQL 有4个级别的字符集和比较规则，分别是:

+ **服务器级别**：启动的时候根据配置或者数据库默认规则生成字符集和比较规则
+ **数据库级别**：数据库的系统变量为只读，修改数据库字符集和比较规则需要保证数据兼容。
+ **表级别**：表级别比较规则默认跟随数据库，修改字符集同样需要保证数据兼容，否则会报错。
+ **列级别**：不建议关注，只需了解即可，通常没有人会去单独改某一列的字符集

​	当然这些特点只是简单列举，下面会按照实际的案例进行一一阐述。

### 服务器级别规则

​	MySQL 提供了两个系统变量来表示服务器级别的字符集和比较规则：

+ Character_set_server：服务器级别的字符集
+ Collation_server：服务器级别的比较规则

​	下面是具体的案例：

```
mysql> show variables like 'character_set_server';
character_set_server	utf8mb4

mysql> SHOW VARIABLES LIKE 'collation_server';
collation_server	utf8mb4_0900_ai_ci
```

​	可以看到这里是标记为utf8mb4，但是如果这里显示是utf8，**其实本质上是utf8mb3**。最后可以看到上面服务器级别的字符集为utfmb4，而服务器级别的比较规则为：`utf8mb4_0900_ai_ci`，不过有些人可能是输出：`utf8_general_ci`

设置字符集和比较规则：

​	如果想要设置服务器级别的字符集和比较规则，可以使用如下的方式，上一节关于mysql的系统配置中说过可以设置配置文件的内容如下，注意需要分配到`[server]`的组下面：

```
[server]
 character_set_server=gbk
 collation_server=gbk_chinese_ci
```

### 数据库级别规则

​	我们在创建数据库的时候更多的时候使用`create database 数据名`，但是使用这种语法创建的数据库使用为配置文件配置的字符集和比较规则，下面我们来了解一下如何创建自定义的比较规则和字符集的数据库。

自定义创建数据库字符集和比较规则：

​	下面是创建自定义数据库级别的字符集和比较规则的语法，当然如果不小心建错了字符集，可以使用`alter database`来进行修改

```sql
create database 数据库名称
	[[DEFAULT] CHARACTER SET 字符集名称]
	[[DEFAULT] COLLATE 比较规则名称];
	
alter database 数据库名
	[[DEFAULT] CHARACTER SET 字符集名称]
	[[DEFAULT] COLLATE 比较规则名称];
	
```

​	下面为实际的操作案例以及具体的操作效果：

```
CREATE DATABASE charset_demo_db
         CHARACTER SET gb2312
        COLLATE gb2312_chinese_ci;
```

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211125221118.png)

​	关于上面的参数`[DEFAULT]`可以进行忽略，如果我们想要查看当前的数据库比较规则，可以使用下面两个 **系统变量**进行查看：**(前提是使用 USE 语句选择当前默认数据库，如果没有默认数据库，则变量与相应的服务器级别的系统变量具有相同的值)**

+ character_set_database：**当前数据库**字符集
+ Collation_database：**当前数据库**比较规则

​	下面为具体的案例：

```sql
> 如果没有use database，则会显示下面的内容（个人测试）
character_set_database	utf8mb3
> use charset_demo_db;
> show variables like 'character_set_database';
character_set_database	gb2312
> show variables LIKE 'collation_database';
collation_database	gb2312_chinese_ci
```

​	可以看到`charset_demo_db`使用的还是创建的时候默认的字符集和比较规则，这里有一个需要注意的点是**数据库级别的系统变量是只读的**，也就意味着`character_set_database`和`collation_database`是只读的，不能修改这两个参数修改字符集和比较规则。但是我们可以使用`alter database`命令修改数据库的级别。

​	最后，如果不指定字符集和比较规则，**这样的话将使用服务器级别的字符集和比较规则作为数据库的字符集和比较规则。**	

### 表级别规则

​	下面我们来看下表级别的规则，表级别顾名思义就是在创建表的时候我们可以追定字符集和字符的比较规则，具体的命令记忆也就是把数据库换成表而已，这里有读者可能注意到的是不能使用`charset`替代，只有`character set`这一个写法：

```mysql
CREATE TABLE 表名 (列的信息)
[[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称]]

ALTER TABLE 表名
[[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称]
```

​	下面我们来看下具体的案例：

```mysql
create table test(
	id int auto_increment primary key
) character set utf8mb4 
COLLATE utf8mb4_0900_ai_ci
```

​	之前说过，如果你在创建表的时候没有制定字符集和比较规则，**默认会使用所在数据库的字符集和比较规则**，这个规则比较好理解，因为你在哪个地盘构建表用哪个地盘的配置也合情合理。

​	下面是关于数据表的字符集查看规则的语法：

​	查看数据表的字符集：`show table status from '数据库名称' like '数据表名称';`

​	除此之外，还有一种方法：`SELECT TABLE_SCHEMA, TABLE_NAME,TABLE_COLLATION FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = '数据表名称'`，通过这样的sql也可以推断出具体的字符集。

```mysql
> show table status from bank like 'admin';
admin	InnoDB	10	Dynamic	0	0	16384	0	0	0	1	2021-11-21 09:23:52			utf8_general_ci		

> use bank;
> SELECT TABLE_SCHEMA, TABLE_NAME,TABLE_COLLATION FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'status';
TABLE_SCHEMA 	TABLE_NAME 		TABLE_COLLATION
bank	 				status				utf8_general_ci
```

​	这里将数据库bank里面的admin表拿出来看了一下，可以看到具体的比较规则是utf8_general_ci，所以可以肯定字符集是utf8。（注意不是utf8mb4）

​	

### 列级别规则

​	列级别规则我相信也没有多少人会去关注，**在同一个表中其实是可以存在多个字符集和比较规则的**，如果我们想要在列中指定字符集，可以使用如下的语法：

```mysql
CREATE TABLE 表名(
	列名 字符串类型 [CHARACTER SET 字符集名称] [COLLATE 比较规则名称], 其他列...
);
```

​	如果想要修改某一个列的字符集或者比较规则，使用如下的语法：

```mysql
ALTER TABLE 表名 MODIFY 列名 字符串类型 [CHARACTER SET 字符集名称] [COLLATE 比较规则名称];
```

​	下面是一个案例：

```mysql
ALTER TABLE t MODIFY col VARCHAR(10) CHARACTER SET gbk COLLATE gbk_chinese_ci;
```

​	最后提醒一遍，**尽量保持一张表使用同一个字符集**，不然很有可能出现各种莫名其妙的问题，比如你如果不小心把汉字存放在不支持的字符集，就会出现乱码的情况。另外，如果**列没有指定字符集**，毫无疑问会使用**表所在的字符集和比较规则**。

> 补充：在转换列的字符集时需要注意，如果转换前列中存储的数据不能用转换后的字符集进行表示会发生错误，就好比上面说的汉字存储在不兼容的字符集的时候就会出现报错。

​	最后是查看列的字符集：

​	`show full columns from '表名称' like '列名';`



## 字符集和比较规则的联动

​	我们在使用navicat创建字符集的时候，会有一种切换的效果，就是我们选择某一个字符集之后就会出现对应的比较规则，但是如果我们选择比较规则再选字符集，**这么做是行不通滴**，为了验证我们来看下面对应的截图内容：

选择比较规则再选字符集：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211128215812.png)

选择字符集再选择比较规则：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20211128215738.png)

​	所以，关于字符集和比较规则的变更规则如下（**适用于所有级别的字符集和比较规则**）：

+ 只修改字符集，比较规则会变更为变更之后的字符集默认的比较规则
+ 只修改比较规则，字符集变为修改比较规则之后的字符集

## 各级别字符集和比较规则小结

​	下面我们来看下从启动服务器开始我们创建字符集和比较规则的默认规则是什么，注意这里前提是 **创建的时候没有显式指定字符集和比较规则**：

+ 列默认会使用表的字符集和比较规则。
+ 表默认使用数据库的字符集和比较规则。
+ 数据库默认使用当前启动服务器指定的字符集和比较规则。

​	通过这样的规则，我们很容易推测出一个某一个列中的字段数据占多少节。

​	最后，介绍这些规则并不是说需要记忆，因为多数情况你会使用服务器甚至数据库的规则代替一切的默认规则。





# 总结

​	为了更好的了解这一篇文章关于四个级别的总结，我做了下面的一个表来帮助自己复习和回顾：

| 数据库级别 | 查看字符集                                            | 查看比较规则                                                 | 系统变量                                                     | 修改/创建方式                                                | 案例                                                         |
| ---------- | ----------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 服务器级别 | show variables like 'character_set_server';           | SHOW VARIABLES LIKE 'collation_server'                       | character_set_server<br />：当前服务器比较规则collation_server：当前服务器比较规则 | 修改配置文件<br />[server]<br/> character_set_server=gbk<br/>collation_server=gbk_chinese_ci | CREATE DATABASE charset_demo_db<br/>         CHARACTER SET gb2312<br/>        COLLATE gb2312_chinese_ci; |
| 数据库级别 | show variables like 'character_set_database';         | show variables LIKE 'collation_database';                    | character_set_database：**当前数据库**字符集 Collation_database：**当前数据库**比较规则 | alter database 数据库名<br/>	[[DEFAULT] CHARACTER SET 字符集名称]<br/>	[[DEFAULT] COLLATE 比较规则名称]; | CREATE DATABASE charset_demo_db<br/>         CHARACTER SET gb2312<br/>        COLLATE gb2312_chinese_ci; |
| 表级别     | show table status from '数据库名称' like '数据表名称' | SELECT TABLE_SCHEMA, TABLE_NAME,TABLE_COLLATION FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = '数据表名称' | 未设置情况下默认参考数据库的级别设置                         | CREATE TABLE 表名 (列的信息)<br/>[[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称]]<br/><br/>ALTER TABLE 表名<br/>[[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称] | create table test(<br/>	id int auto_increment primary key<br/>) character set utf8mb4 <br/>COLLATE utf8mb4_0900_ai_ci |
| 列级别     | show full columns from admin like 'username';         | show full columns from admin like 'username';                | 未设置情况下默认参考数据表的级别设置                         | CREATE TABLE 表名(<br/>	列名 字符串类型 [CHARACTER SET 字符集名称] [COLLATE 比较规则名称], 其他列...<br/>);<br />ALTER TABLE t MODIFY col VARCHAR(10) CHARACTER SET gbk COLLATE gbk_chinese_ci; |                                                              |



# 问答题

## 为什么mysql的utfmb3和utf8mb4两个编码？

​	在非常早期的时候，Unicode 只用到了 0~0xFFFF 范围的数字编码，这就是 BMP 字符集。所以，最初MySQL在设计之初，也就只涉及了包含BMP 字符集的utfmb3(utf-8)，但是随着文字越来越多，3个字节肯定无法全部表示，于是Unicode支持的字符就更多了。所以在最后我们可以对于mysql的unicode做如下区分：

+ utf8mb3 :阉割过的 utf8 字符集，只使用1~3个字节表示字符。
+ utf8mb4 :正宗的 utf8 字符集，使用1~4个字节表示字符



​	

# 写在最后

​	如果对于内容有疑问或者有错误欢迎指出，个人也将会不断的吸取教训并改进。

