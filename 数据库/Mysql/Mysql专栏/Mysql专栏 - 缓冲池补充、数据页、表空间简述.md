# Mysql专栏 - 缓冲池补充、数据页、表空间简述

# 前言

​		这一节我们来继续讲述关于缓冲池的内容，以及关于数据页和表空间的内容，当然内容页比较基础和简单，理解相关概念即可。

# 概述

1. 补充缓冲池的内容，关于后台刷新线程，以及多线程访问buffer pool的锁模式等
2. 数据行和数据页的结构，简要的了解简单的内部细节。
3. 表空间以及数据区，以及整个mysql表的逻辑结构



# 缓冲池补充

​	在介绍具体的内容之前，这里先补充关于缓冲池的一些细节。



## 后台线程定时刷新冷数据

​	上一节提到了冷热数据分离，其实冷数据不可能是在缓冲池满的时候才会进行刷新的，而是会在LRU冷数据的尾部随机找几个缓存页刷入磁盘，他会有一个定时任务，每隔一段时间就进行刷新的操作，同时将刷新到磁盘之后的数据页加入到free链表当中。所以LRU的链表会定期把数据刷入到磁盘当中进行处理，并且在缓存没有用完的时候会清空一些无用的缓存页。



## flush链表的数据定期刷入缓存

​	flush的链表存放的是脏页数据，当然它也有一个定时任务，会定期把flash链表的数据刷入到缓冲池当中，并且我们也可以大致认为整个LRU是不断的移动的，flush链表的缓存页页在不断的减少，free list的内容在不断变多。



## 多线程并发访问是否会加锁

​	多线程访问的时候会进行加锁，因为读取一个缓冲页涉及 free list, flush list, lru list三个链表的操作，并且还需要对于数据页进行哈希函数的查找操作，所以整个操作过程是肯定要加锁的，虽然看似操作的链表有三个，但是实际上耗费不了多少的性能，因为链表的操作都是一些指针的操作查找操作，所以基本都是一些常数的时间和空间消耗，即使是排队来一个个处理，也是没有多大的影响的。



## 多个buffer pool并行优化

​	当mysql的buffer pool大于1g的 时候其实可以配置多个缓冲池，MySQL默认的规则是：**如果你给Buffer Pool分配的内存小于1GB，那么最多就只会给你一个Buffer Pool**。比如在下面的案例当中如果是一个8G的Mysql服务器，可以做如下的配置：

```mysql
[server]
innodb_buffer_pool_size = 8589934592
innodb_buffer_pool_instances = 4
```

​	这样就可以设置4个buffer pool，每一个占用2g大小。实际生产环境使用buffer pool进行调优是十分重要的。

 

## 运行过程中可以调整buffer pool大小么？

​	就目前讲解来看，是无法实现动态的运行时期调整大小的。为什么？因为如果要调整的话需要把整个缓冲区的大小拷贝到新的内存，这个速度实在是太慢了。所以针对这一个问题，mysql引入了chunk的概念。

### mysql的chunk机制把buffer pool 拆小

​	为了实现动态的buffer pool扩展，buffer pool是由很多chunk组成的，他的大小是**innodb_buffer_pool_chunk_size**参数控制的，默认值就是128MB，也就是说一个chunk就是一个默认的缓冲池的大小，同时缓存页和描述信息也是按照chunk进行分块的，假设有一个2G 的chunk的，它的每一个块是128M，也就是大概有16个chunk进行切割。

​	有了chunk之后，申请新的内存空间的时候，我们要把之前的缓存复制到新的空间就好办了，直接生成新的到chunk即可。然后把数据搬移到新的chunk即可。





## 生产环境给多少buffer pool合适？

​	如果32g的mysql机器要给30g的buffer pool，想想也没有道理！crud的操作基本都是内存的操作，所以性能十分高，对于32g的内存，你的机器起码就得用好几个g的处理，所以首先我们可以分配一半的内存给mysql.或者给个60%左右的内容即可。

 	`innodb_buffer_pool_size`默认的情况下为128M，最大值取决于CPU的架构。在32-bit平台上，最大值为`(2^32 -1)`,在64-bit平台上最大值为`(2^64-1)`。当**缓冲池大小大于1G时**，将`innodb_buffer_pool_instances`设置大于1的值可以提高服务器的可扩展性。最后大的缓冲池可以减小多次磁盘I/O访问相同的表数据，如果数据库配置在专门的服务器当中，可以将缓冲池大小设置为服务器物理内存的60 - 80%，也就是说32g的内容给24g - 26g都是比较好的选择，当然 。

### buffer pool分配公式：

​	关于buffer pool，这里有一个关键的公式：**buffer pool总大小=(chunk大小 * buffer pool实例数量)的倍数**，默认的chunk大小是128M, 要给20G的buffer pool ，然后按照公式套入就是：`Buffer pool = 128 * 16 * 10`，也就是每一个chunk大小是128，再次强调一遍`buffer pool总大小=(chunk大小 * buffer pool数量)的倍数`

> 缓冲池的配置有如下的规定：
>
> + 缓冲池大小必须始终等于或者是`innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances`的倍数（innodb_buffer_pool_instances 指的就是实例的数量）。
> + 如果将缓冲池大小更改为不等于或等于`innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances`的倍数的值，则缓冲池大小将自动调整为等于或者是`innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances`的倍数的值。

### 查看线上情况

​	当你的数据库启动之后，执行`SHOW ENGINE INNODB STATUS`就可以了。此时你可能会看到如下一系列的东西:

```mysql
Total memory allocated xxxx; Dictionary memory allocated xxx Buffer pool size xxxx Free buffers xxx
Database pages xxx
Old database pages xxxx
Modified db pages xx
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young xxxx, not young xxx
xx youngs/s, xx non-youngs/s
Pages read xxxx, created xxx, written xxx
xx reads/s, xx creates/s, 1xx writes/s
Buffer pool hit rate xxx / 1000, young-making rate xxx / 1000 not xx / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s LRU len: xxxx, unzip_LRU len: xxx
I/O sum[xxx]:cur[xx], unzip sum[16xx:cur[0]
```

​	下面我们给大家解释一下这里的东西，主要讲解这里跟buffer pool相关的一些东西。

​	相关解释：

```mysql
(1)Total memory allocated，这就是说buffer pool最终的总大小是多少
(2)Buffer pool size，这就是说buffer pool一共能容纳多少个缓存页
(3)Free buffers，这就是说free链表中一共有多少个空闲的缓存页是可用的
(4)Database pages和Old database pages，就是说LRU链表中一共有多少个缓存页，以及冷数据区域里的缓存页 数量
(5)Modified db pages，这就是flush链表中的缓存页数量
(6)Pending reads和Pending writes，等待从磁盘上加载进缓存页的数量，还有就是即将从LRU链表中刷入磁盘的数 量、即将从flush链表中刷入磁盘的数量
(7)Pages made young和not young，这就是说已经LRU冷数据区域里访问之后转移到热数据区域的缓存页的数 量，以及在LRU冷数据区域里1s内被访问了没进入热数据区域的缓存页的数量
(8)youngs/s和not youngs/s，这就是说每秒从冷数据区域进入热数据区域的缓存页的数量，以及每秒在冷数据区 域里被访问了但是不能进入热数据区域的缓存页的数量
(9)Pages read xxxx, created xxx, written xxx，xx reads/s, xx creates/s, 1xx writes/s，这里就是说已经读取、 创建和写入了多少个缓存页，以及每秒钟读取、创建和写入的缓存页数量
(10)Buffer pool hit rate xxx / 1000，这就是说每1000次访问，有多少次是直接命中了buffer pool里的缓存的 (11)young-making rate xxx / 1000 not xx / 1000，每1000次访问，有多少次访问让缓存页从冷数据区域移动到 了热数据区域，以及没移动的缓存页数量
(12)LRU len:这就是LRU链表里的缓存页的数量 (13)I/O sum:最近50s读取磁盘页的总数 (14)I/O cur:现在正在读取磁盘页的数量
```



# 数据行和数据页的结构

​	在了解这些概念之前，我们需要先了解下面这些问题：

**为什么mysql不能直接更新磁盘?**

​	因为一个请求直接对于磁盘文件读写，虽然技术上没问题，但是性能会极差。磁盘的读写性能非常的差，所以不可能更新磁盘文件读取磁盘的。

**为什么要引入数据页的概念?**

​	一个数据肯定不是加载一条就读取一次磁盘文件的，就好比你烧柴不可能每次只拿一根，烧完再去拿一根，一般都是直接拿一捆柴拿然后拿到了一个个丢进去，这样就快了，数据页也是如此，之前说过一个数据页占16kb，所以肯定是加载很多行到数据页的内部。



## 数据行

 **数据行在磁盘里面怎么放?**

​	之前都是讨论数据怎么在缓存页放，现在我们回过头来看下数据行在数据页里面要怎么放。这里其实涉及一个叫做**行格式**的概念**，**一个表可以指定一个行是以什么样的格式进行存储，比如下面的方式指定行格式：

```mysql
CREATE TABLE customer (
name VARCHAR(10) NOT NULL, address VARCHAR(20),
gender CHAR(1),
job VARCHAR(30),
school VARCHAR(50)
) ROW_FORMAT=COMPACT;
```

​	对于行的存储格式，在mysql当中是如下存储的：

> 变长字段的长度列表，null值列表，数据头，column01的值，column02的值，column0n的值......

​		 ![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210904191126.png)

**变长数据是如何存放的？**

​	根据上面的行格式定义，相信也可以猜出来一部分，假设我们有一个字段是varchar（5）内容是abcd, 有一个字段是varchar(10)内容是 bcd，实际上存储则是按照下面这种格式存储，但是如果你是char(1)则不需要额外的一个变长字段长度的参数，直接放到对应的字段里面即可：

| Ox03 | ox04 | null | 数据头 | abc  | Bcd  |
| ---- | ---- | ---- | ------ | ---- | ---- |

​	需要注意的是这里的变长长度参数是逆序存储的，是**逆序存储**的。

**为什么一行数据的null不能直接存储？**

​	null值是以二进制的方式进行存储的，并且变长参数的字段实际上只存储有值的数据，如果数据是没有值为一个null也不需要存储变长字段的长度参数。null值按照bit位存储的，并且在对应的null "坑位"放一个1 或者 0，**1表示是null， 0表示不是null**。

​	举个例子，4个字段里面2个为null，2个不是则是**1010** ，但是实际存储的时候也是**逆序的**，也是逆序的是 0101

​	另外存储的时候不是4个bit位置，而是使用8个bit的倍数（8的倍数，有点像java的对象头的补充数据位的操作.），如果不足8个则需要补0，所以最后的结果如下：

> 0x09 0x04 00000101 头信息 column1=value1 column2=value2 ... columnN=valueN，

**那要如何存储？**

​	其实就按照紧凑的方式存储成为一行的数据，这样紧凑的方式不仅可以节省空间，并且可以使得操作内存成为一种类似数组的顺序访问的操作。



**40个bit位的数据头：(索引的时候才解读，伞兵，掠过)**

​	在上面的结构图中，每一行数据的存储还需要一个40位的bit数据头，并且用来描述这个数据，这里我们先简单了解数据头的结构，在后续的内容会再次进行解释：

+ 首先1和2都是预留，第一个bit位和第二个都是预留的位置，没有任何的含义。

+ 用一个bit位的**delete_mask**来标记这个行是否已经被删除了(第三位)。所以其实不管你怎么设计其实mysql内部的删除都是一个假删除

+ 下一个bit位置使用1位**min_rec_mask**(第四位)，b+树当中的每一层的非叶子节点的最小值的标记

+ 下一个bit位置为 4个**bitn_owned**（第五位），具体的作用暂时不进行介绍。

+ 下一个为13个bit位的**heap_no**，记录在堆里的位置，关于堆也会放到索引里面介绍。

+ 下一个是3bit的**record_type** 行数据类型：0普通类型，1b+树的叶子节点，2最小值数据，3最大值数据

+ 最后是16个bit的**next_record**，这个是指向下一条数据的指针

 

每一行数据真实的物理存储结构：

​	在真实的磁盘文件中，存储的内容还有不同，那就是关于数据的内容，上面我们介绍了如何存储一行数据。

>  0x09 0x04 00000101 0000000000000000000010000000000000011001 jack m xx_school

​	然而实际上略微有些差别，在实际的磁盘存储的过程是按照 **字符集编码**进行存储的，一行数据实际上下面这样滴：

>  0x09 0x04 00000101 0000000000000000000010000000000000011001 616161 636320 6262626262

 	这种存储结构其实也可以说不论你的字段类型如何定义，到最后都是字符串。



数据库真实存储的隐藏字段

​	mysql在数据行里面增加了一些隐藏的字段，一方面是为了实现MVCC，另一方面是为了实现事务的需要。

+ DB_ROW_ID：行唯一标识，不是主键id的字段，如果没有制定主键和unique key，就会内部加入一个ROW_ID

+ DB_TRX_ID：和事务有关的一个，那个事务更新这是事务的ID

+ DB_ROLL_PTR：这是一个回滚指针，进行事务回滚的



行溢出了怎么办?

​	有时候我们定义的数据行数据量过大的时候，会出现一个数据页无法存储数据行的情况，mysql这里又使用了链表的的方式把多个数据页串联在一起，他个结构图如下所示：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210904202851.png)

​	从图中可以看出当数据溢出的时候，一个数据页会通过一个类似链表指针的方式指向下一个数据页的节点，通过链表的形式把许多个数据页串联在一起。

​	至此我们可以做一点总结，当我们在数据库里插入一行数据的时候，实际上是在内存里插入一个有复杂存储结构的一行数据，然后随着一些条件的发生，这行数据会被刷到磁盘文件里去。



## 数据页

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210904213013.png)

**最小单位是数据页**

​	数据库的最小单位是数据页，但是数据页里不都是一行一行的数据么，其实一个数据页包含了下面的部分：**文件头，数据页头，最大最小记录，多个数据行和空闲区域，最后是数据页目录和文件尾部**，这里为了更好的观察结构，我把图横过来了：



**大小占比**

​	文件头38个字节，数据页头站了56个字节，最大和最小记录占了26个字节，数据行区域和空闲区域的大小是不固定的，数据页的目录也是不固定的，文件结尾占8位。（我擦，怎么多出这么多概念，这是啥东西，其实就是mysql设计的一种特殊的存储格式，理解即可）

​	通过这种方式存放数据页，每一个数据页包含了很多数据行，每一个数据行就是用上面提到的方式进行存储的，数据页最开始的时候是空的。

> 当出现很多个数据页的时候，可以看到如下的内容，更新缓存页的时候，LRU链表会不断的交替移动冷数据和热数据，通过LRU和flush把脏页刷到磁盘。



# 表空间和数据区的概念

​	其实我们平时创建的表是存在**表空间和数据区**的概念的

表空间

​	从 InnoDB 逻辑存储结构来看，所有的数据都被逻辑的存放在一个空间中，这个空间就叫做表空间（tablespace）。表空间由 段（segment）、区（extent）、页（page）组成。

​	当我们创建一个表之后，在磁盘上会有对应的表名称`.ibd`的磁盘文件。表空间的磁盘文件里面有很多的数据页，一个数据页最多16kb，因为不可能一个数据页一个磁盘文件，所以数据区的概念引入了。

​	一个数据区对应64个数据页，就是16kb，一个数据区是1mb，256个数据区被划分为一组，对于表空间而言，他的第一组数据区的第一个数据区的前3个数据页，都是固定的，里面存放了一些描述性的数据。比 如FSP_HDR这个数据页，他里面就存放了表空间和这一组数据区的一些属性。IBUF_BITMAP 数据页，存放的就是insert buffer的信息，INODE 数据页存放的也是特殊信息。

 	再次强调一遍：我们平时创建的那些表都是有对 应的表空间的，每个表空间就是对应了磁盘上的数据文件，在表空间里有很多组数据区，一组数据区是256个数据区， 每个数据区包含了64个数据页，是1mb	

**段（segment）**

​	段(Segment)分为索引段，数据段，回滚段等。其中索引段就是非叶子结点部分，而数据段就是叶子结点部分，回滚段用于数据的回滚和多版本控制。一个段包含256个区(256M大小)。 

​	一个段包含多少区：**256个区**

**区（extent）**

​	区是页的集合，一个区包含64个连续的页，默认大小为 1MB (64*16K)。

**页（page）**

​	页是 InnoDB 管理的最小单位，常见的有 FSP_HDR，INODE, INDEX 等类型。所有页的结构都是一样的，分为文件头(前38字节)，页数据和文件尾(后8字节)。页数据根据页的类型不同而不一样。

​	每个空间都分为多个页，通常每页16 KiB。空间中的每个页面都分配有一个32位整数页码，通常称为“偏移量”（offset），它实际上只是页面与空间开头的偏移量（对于多文件空间，不一定是文件的偏移量）。因此，页面0位于文件偏移量0，页面1位于文件偏移量16384，依此类推。 （InnoDB 的数据限制为64TiB，这实际上是每个空间的限制，这主要是由于页码是32位整数与默认页大小的组合

最后可以用下面的图来表示具体内容**：**

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210905111438.png)

# 总结

​	本节我们继续补充了buffer pool的细节，同时了解了额数据行和数据页在磁盘上的存储结构，最后我们简单了解了一个表的逻辑存储接结构，主要的内容是表空间，数据区和数据页。至此，相信大家对于整个mysql的基础物理和逻辑结构有了一个大致的了解。



# 写在最后

​	本文篇幅稍长，感谢耐心观看，个人水平有限，如果有错误或者意见欢迎指点。



# 思考题：

## 为什么mysql要这样存放数据，为什么要让他们紧紧的挨在一起进行存储？

 	其实仔细想想不难给出答案，主要包含下面几个原因：

1. 尽可能存储更多的内容：紧凑意味着着可以存储更多的数据和内容，也可以保证缓冲池的空间利用率
2. 便于顺序读写：磁盘的顺序读写的速度在某种程度上可以匹敌内存，所以用这种格式存储是有利于io操作的



## 为什么null列表要按照bit位的操作进行存储？

最后的数据样子如下：

> 0x09 0x04 00000101 0000000000000000000010000000000000011001 00000000094C(DB_ROW_ID) 00000000032D(DB_TRX_ID) EA000010078E(DB_ROL_PTR) 616161 636320 6262626262

​	如果你在执行CRUD的时候要从磁盘加载数据页到Buffer Pool的缓存 页的时候，一旦此时没有空闲的缓存页，就必须从LRU链表的冷数据区域的尾部把一个缓存页刷入磁盘，然后腾出来 一个空闲的缓存页，接着你才能基于缓存数据来执行这个CRUD的操作。但是如果频繁的出现这样的一个情况，那你的很多CRUD执行的时候，难道都要先刷一个缓存页到磁盘上去? 然后再从 磁盘上读取一个数据页到空闲的缓存页里来?这样岂不是每次CRUD操作都要执行两次磁盘IO?那么性能岂不是会极差?

​	所以我们来思考一个问题:你的MySQL的内核参数，应该如何优化，优化哪些地方的行为，才能够尽可能的避免在执 行CRUD的时候，经常要先刷一个缓存页到磁盘上去，才能读取一个磁盘上的数据页到空闲缓存页里来?

>  其实结合我们了解到的buffer pool的运行原理就可以知道，如果要避免上述问题，说白了就是避免缓存页频繁的被使用完毕。那么我们知道实际上你在使用缓存页的过程中，有一个后台线程会定时把LRU链表冷数据区域的一些缓存页 刷入磁盘中。所以本质上缓存页一边会被你使用，一边会被后台线程定时的释放掉一批。

## 如何读取一个数据页的？

​	读取一个数据页的伪代码如下：

```mysql
dataFile.setStartPosition(25347) 
dataFile.setEndPosition(28890) 
dataFile.write(cachePage)
```

​	在伪代码里面读取一个数据页首先需要的是开始和结束的时间位，通过表空间找到对应的段，然后找到对应的数据区，根据分区找到对应的数据页，然后页的内部数据行如下的方式进行展示：

​	因为一个数据页的大小其实是固定的，所以一个数据页固定就是可能在一个磁盘文件里占据了某个开始位置到结束位置的一段数据，此时你写回去的时候也是一样的，选择好固定的一段位置的数据，直接把缓存页的数据写回去，就覆盖掉了原来的那个数据页了，就如上面的伪代码示意

 