---
# 主题列表：juejin, github, smartblue, cyanosis, channing-cyan, fancy, hydrogen, condensed-night-purple, greenwillow, v-green, vue-pro, healer-readable, mk-cute, jzman, geek-black
# 贡献主题：https://github.com/xitu/juejin-markdown-themes
theme: smartblue
highlight:
---

# redis学习 - sds字符串

[Redis 设计与实现](http://redisbook.com/index.html)：如果想要知道redis底层，这本书可以给予不少的帮助，非常推荐每一位学习redis的同学去翻一翻。

sds字符串建议多看看源代码的实现，这篇文章基本是个人看了好几篇文章之后的笔记。

源代码文件分别是：`sds.c`，`sds.h`



## redis的string API使用

首先看下API的简单应用，设置str1变量为helloworld，然后我们使用`debug object +变量名`的方式看下，注意编码为**embstr**。

```shell
127.0.0.1:17100> set str1 helloworld
-> Redirected to slot [5416] located at 127.0.0.1:17300
OK
127.0.0.1:17300> debug object str1
Value at:0x7f2821c0e340 refcount:1 encoding:embstr serializedlength:11 lru:14294151 lru_seconds_idle:8

```

如果我们将str2设置为`helloworldhelloworldhelloworldhelloworldhell`，字符长度为44，再使用下`debug object+变量名`的方式看下，注意编码为**embstr**。

```shell
127.0.0.1:17300> set str2 helloworldhelloworldhelloworldhelloworldhell
-> Redirected to slot [9547] located at 127.0.0.1:17100
OK
127.0.0.1:17100> get str2
"helloworldhelloworldhelloworldhelloworldhell"
127.0.0.1:17100> debug object str2
Value at:0x7fd75e422c80 refcount:1 encoding:embstr serializedlength:21 lru:14294260 lru_seconds_idle:6
```

但是当我们把设置为`helloworldhelloworldhelloworldhelloworldhello`，字符长度为45，再使用`debug object+变量名`的方式看下，注意编码改变了，变为**raw**。

```shell
127.0.0.1:17100> set str2 helloworldhelloworldhelloworldhelloworldhello
OK
127.0.0.1:17100> debug object str2
Value at:0x7fd75e430c60 refcount:1 encoding:raw serializedlength:21 lru:14294358 lru_seconds_idle:9

```

最后我们将其设置为整数100，再使用`debug object+变量名`的方式看下，编码的格式变为了int。

```shell
127.0.0.1:17100> set str2 11
OK
127.0.0.1:17100> get str2
"11"
127.0.0.1:17100> debug object str2
Value at:0x7fd75e44d370 refcount:2147483647 encoding:int serializedlength:2 lru:14294440 lru_seconds_idle:9

```

所以Redis的string类型一共有三种存储方式：

1. 当字符串长度小于等于44，底层采用**embstr**；
2. 当字符串长度大于44，底层采用**raw**；
3. 当设置是**整数**，底层则采用**int**。

至于这三者有什么区别，可以直接看书：

http://redisbook.com/preview/object/string.html

主要区别是内存分配的时候是否存在区别，raw会有两次内存分配函数操作

为什么是44个字节？

  因为Redis中内存是统一控制分配的，通常是是2、4、8、16、32、64等；`64-19-1=44`就是原因。

## 为什么redis string 要使用sds字符串？

1. **O(1)获取长度**，c语言的字符串本身不记录长度，而是通过末尾的`\0`作为结束标志，而sds本身记录了字符串的长度所以获取直接变为O(1)的时间复杂度、同时，长度的维护操作由sds的本身api实现
2. **防止缓冲区溢出bufferoverflow**：由于c不记录字符串长度，相邻字符串容易发生缓存溢出。sds在进行添加之前会检查长度是否足够，并且不足够会自动根据api扩容
3. **减少字符串修改的内存分配次数**：使用动态扩容的机制，根据字符串的大小选择合适的header类型存储并且根据实际情况动态扩展。
4. 使用**空间预分配和惰性空间释放**，其实就是在扩容的时候，根据大小额外扩容2倍或者1M的空间，方面字符串修改的时候进行伸缩
5. 使用**二进制保护**，数据的读写不受特殊的限制，写入的时候什么样读取就是什么样
6. 支持**兼容部分**的c字符串函数，可以减少部分API的开发



## SDS字符串和C语言字符串库有什么区别

摘自黄健宏大神的一张表

| C 字符串                                             | SDS                                                  |
| :--------------------------------------------------- | :--------------------------------------------------- |
| 获取字符串长度的复杂度为 O(N) 。                     | 获取字符串长度的复杂度为 O(1) 。                     |
| API 是不安全的，可能会造成缓冲区溢出。               | API 是安全的，不会造成缓冲区溢出。                   |
| 修改字符串长度 `N` 次必然需要执行 `N` 次内存重分配。 | 修改字符串长度 `N` 次最多需要执行 `N` 次内存重分配。 |
| 只能保存文本数据。                                   | 可以保存文本或者二进制数据。                         |
| 可以使用所有 `<string.h>` 库中的函数。               | 可以使用一部分 `<string.h>` 库中的函数。             |

## redis的sds是如何实现的

由于c语言的string是以`\0`结尾的Redis单独封装了SDS简单动态字符串结构，如果在字符串变量十分多的情况下，会浪费十分多的内存空间，同时为了减少malloc操作，redis封装了自己的sds字符串。

下面是网上查找的一个sds字符串实现的数据结构设计图：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46b159febe6d4e039b5503e04c0f0616~tplv-k3u1fbpfcp-zoom-1.image)

s1,s2分别指向真实数据区域的头部，而要确定一个sds字符串的类型，则需要通过 s[-1] 来获取对应的flags，根据flags辨别出对应的Header类型，获取到Header类型之后，根据最低三位获取header的类型（这也是使用`__attribute__ ((__packed__))`关键字的原因下文会说明）：

- 由于s1[-1] == 0x01 == SDS_TYPE_8，因此s1的header类型是sdshdr8。
- 由于s2[-1] == 0x02 == SDS_TYPE_16，因此s2的header类型是sdshdr16。

下面的部分是sds的实现源代码：

sds一共有5种类型的header。之所以有5种，是为了能让不同长度的字符串可以使用不同大小的header。这样，短字符串就能使用较小的header，从而节省内存。

```c
typedef char *sds;
 
// 这个比较特殊，基本上用不到
struct __attribute__ ((__packed__)) sdshdr5 {
    usigned char flags;
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr8 {
    uint8_t len;
    uint8_t alloc;
    unsigned char flags;
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr16 {
    uint16_t len;
    uint16_t alloc;
    unsigned char flags;
    char buf[];
};
//string_size < 1ll<<32
struct __attribute__ ((__packed__)) sdshdr32 {
    uint32_t len;
    uint32_t alloc;
    unsigned char flags;
    char buf[];
};
//string_size < 1ll<<32
struct __attribute__ ((__packed__)) sdshdr64 {
    uint64_t len;
    uint64_t alloc;
    unsigned char flags;
    char buf[];
};
// 定义了五种header类型，用于表示不同长度的string 
#define SDS_TYPE_5 0
#define SDS_TYPE_8 1
#define SDS_TYPE_16 2
#define SDS_TYPE_32 3
#define SDS_TYPE_64 4

#define SDS_TYPE_MASK 7 // 类型掩码
#define SDS_TYPE_BITS 3 // 
#define SDS_HDR_VAR(T,s) struct sdshdr##T *sh = (void*)((s)-(sizeof(struct sdshdr##T))); // 获取header头指针
#define SDS_HDR(T,s) ((struct sdshdr##T *)((s)-(sizeof(struct sdshdr##T)))) // 获取header头指针
#define SDS_TYPE_5_LEN(f) ((f)>>SDS_TYPE_BITS)
```

上面的代码需要注意以下两个点：

+ `__attribute__ ((__packed__))` 这是C语言的一种关键字,这将使这个结构体在内存中不再遵守字符串对齐规则，而是以内存紧凑的方式排列。目的时在指针寻址的时候，可以直接通过sds[-1]找到对应flags，有了flags就可以知道头部的类型，进而获取到对应的len，alloc信息，而不使用内存对齐，CPU寻址就会变慢，同时如果不对齐会造成CPU进行优化导致空白位不补0使得header和data不连续，最终无法通过flags获取低3位的header类型。

+ `SDS_HDR_VAR`函数则通过结构体类型与字符串开始字节，获取到动态字符串头部的开始位置，并赋值给sh指针。`SDS_HDR`函数则通过类型与字符串开始字节，返回动态字符串头部的指针。

- 在各个header的定义中最后有一个char buf[]。我们注意到这是一个没有指明长度的字符数组，这是C语言中定义字符数组的一种特殊写法，称为柔性数组（[flexible array member](https://en.wikipedia.org/wiki/Flexible_array_member)），只能定义在一个结构体的最后一个字段上。它在这里只是起到一个标记的作用，表示在flags字段后面就是一个字符数组，或者说，它指明了紧跟在flags字段后面的这个字符数组在结构体中的偏移位置。而程序在为header分配的内存的时候，它并不占用内存空间。如果计算sizeof(struct sdshdr16)的值，那么结果是5个字节，其中没有buf字段。

> 关于柔性数组的介绍：
>
> [深入浅出C语言中的柔性数组](https://blog.csdn.net/ce123_zhouwei/article/details/8973073)

- **sdshdr5**与其它几个header结构不同，它不包含alloc字段，而长度使用flags的**高5位**来存储。因此，它不能为字符串分配空余空间。如果字符串需要动态增长，那么它就必然要重新分配内存才行。所以说，这种类型的sds字符串更适合存储静态的短字符串（长度小于32）。



同时根据上面的结构可以看到，SDS结构分为两个部分：

+ **len、alloc、flags**。只是`sdshdr5`有所不同，
  + len: 表示字符串的真正长度（不包含NULL结束符在内）。
  + alloc: 表示字符串的最大容量（不包含最后多余的那个字节）。
  + flags: 总是占用一个字节。其中的最低3个bit用来表示header的类型。header的类型共有5种，在sds.h中有常量定义。

```c
#define SDS_TYPE_5  0
#define SDS_TYPE_8  1
#define SDS_TYPE_16 2
#define SDS_TYPE_32 3
#define SDS_TYPE_64 4
```

+ **buf[]**：柔性数组，之前有提到过，其实就是具体的数据存储区域，注意这里实际存储的数据的时候末尾存在`NULL`

> 小贴士：
>
> \#define SDS_HDR(T,s) ((struct sdshdr##T *)((s)-(sizeof(struct sdshdr##T))))
>
> \#号有什么作用？
>
> 这个的含义是让"#"后面的变量按照**普通字符串**来处理
>
> 双\#又有什么用处呢？
>
> 双“#”号可以理解为，在单“#”号的基础上，增加了连接功能



## sds的创建和销毁

```c
sds sdsnewlen(const void *init, size_t initlen) {
    void *sh;
    sds s;
    
    char type = sdsReqType(initlen);
    /* Empty strings are usually created in order to append. Use type 8
     * since type 5 is not good at this. */
    if (type == SDS_TYPE_5 && initlen == 0) type = SDS_TYPE_8;
    int hdrlen = sdsHdrSize(type);
    unsigned char *fp; /* flags pointer. */

    sh = s_malloc(hdrlen+initlen+1);
    if (!init)
        memset(sh, 0, hdrlen+initlen+1);
    if (sh == NULL) return NULL;
    s = (char*)sh+hdrlen;
    fp = ((unsigned char*)s)-1;
    switch(type) {
        case SDS_TYPE_5: {
            *fp = type | (initlen << SDS_TYPE_BITS);
            break;
        }
        case SDS_TYPE_8: {
            SDS_HDR_VAR(8,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_16: {
            SDS_HDR_VAR(16,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_32: {
            SDS_HDR_VAR(32,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_64: {
            SDS_HDR_VAR(64,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
    }
    if (initlen && init)
        memcpy(s, init, initlen);
    s[initlen] = '\0';
    return s;
}

sds sdsempty(void) {
    return sdsnewlen("",0);
}

sds sdsnew(const char *init) {
    // 如果initlen 为NULL,使用0作为初始化数据
    size_t initlen = (init == NULL) ? 0 : strlen(init);
    return sdsnewlen(init, initlen);
}

void sdsfree(sds s) {
    if (s == NULL) return;
    s_free((char*)s-sdsHdrSize(s[-1]));
}
```

上面的源代码需要注意如下几个点：

1. **SDS_TYPE_5**由于设计之初按照常量对待，实际情况大多数为append操作扩容，而**SDS_TYPE_5**扩容会造成内存的分配，所以使用**SDS_TYPE_8** 进行判定
2. SDS字符串的长度为：`hdrlen+initlen+1` -> `sds_header`的长度 + 初始化长度 + 1 (末尾占位符`NULL`判定字符串结尾)
3. `s[initlen] = '\0';` 字符串末尾会使用`\0`进行结束标志：代表为`NULL`
4. sdsfree释放sds字符串需要计算出Header的起始位置，具体为`s_malloc`指针所指向的位置



知道了sds如何创建之后，我们可以了解一下里面调用的具体函数。比如**sdsReqType**，**sdsReqType**方法定义了获取类型的方法，首先根据操作系统的位数根据判别 `LLONG_MAX`是否等于`LONG_MAX`，根据机器确定为32位的情况下分配sds32，同时在64位的操作系统上根据判断小于2^32分配sds32，否则分配sds64。

这里值得注意的是：`string_size < 1ll<<32`这段代码在**redis3.2**中才进行了bug修复，在早期版本当中这里存在分配类型的`Bug`

[commit](https://github.com/antirez/redis/commit/603234076f4e59967f331bc97de3c0db9947c8ef)

```c
static inline char sdsReqType(size_t string_size) {
    if (string_size < 1<<5)
        return SDS_TYPE_5;
    if (string_size < 1<<8)
        return SDS_TYPE_8;
    if (string_size < 1<<16)
        return SDS_TYPE_16;
// 在一些稍微久远一点的文章上面没有这一串代码 #
#if (LONG_MAX == LLONG_MAX)
    if (string_size < 1ll<<32)
        return SDS_TYPE_32;
    return SDS_TYPE_64;
#else
    return SDS_TYPE_32;
#endif
}
```

再来看下`sdslen`方法，**s[-1]**用于向低位地址偏移一个字节，和`SDS_TYPE_MASK`按位与的操作，获得Header类型，

```c
static inline size_t sdslen(const sds s) {
    unsigned char flags = s[-1];
    // SDS_TYPE_MASK == 7
    switch(flags&SDS_TYPE_MASK) {
        case SDS_TYPE_5:
            return SDS_TYPE_5_LEN(flags);
        case SDS_TYPE_8:
            return SDS_HDR(8,s)->len;
        case SDS_TYPE_16:
            return SDS_HDR(16,s)->len;
        case SDS_TYPE_32:
            return SDS_HDR(32,s)->len;
        case SDS_TYPE_64:
            return SDS_HDR(64,s)->len;
    }
    return 0;
}
```





## sds的连接（追加）操作

```c
/* Append the specified binary-safe string pointed by 't' of 'len' bytes to the
 * end of the specified sds string 's'.
 *
 * After the call, the passed sds string is no longer valid and all the
 * references must be substituted with the new pointer returned by the call. */

sds sdscatlen(sds s, const void *t, size_t len) {
    size_t curlen = sdslen(s);

    s = sdsMakeRoomFor(s,len);
    if (s == NULL) return NULL;
    memcpy(s+curlen, t, len);
    sdssetlen(s, curlen+len);
    // 注意末尾需要设置占位符\0代表结束标志
    s[curlen+len] = '\0';
    return s;
}

sds sdscat(sds s, const char *t) {
    return sdscatlen(s, t, strlen(t));
}

sds sdscatsds(sds s, const sds t) {
    return sdscatlen(s, t, sdslen(t));
}

// sds实现的一个核心代码，用于判别是否可以追加以及是否有足够的空间
sds sdsMakeRoomFor(sds s, size_t addlen) {
    void *sh, *newsh;
    size_t avail = sdsavail(s);
    size_t len, newlen;
    char type, oldtype = s[-1] & SDS_TYPE_MASK;
    int hdrlen;

    /* Return ASAP if there is enough space left. */
    // 如果原来的空间大于增加后的空间，直接返回
    if (avail >= addlen) return s;

    len = sdslen(s);
    sh = (char*)s-sdsHdrSize(oldtype);
    newlen = (len+addlen);
    // 如果小于 1M，则分配他的两倍大小，否则分配 +1M
    if (newlen < SDS_MAX_PREALLOC)
        newlen *= 2;
    else
        newlen += SDS_MAX_PREALLOC;

    type = sdsReqType(newlen);

    /* Don't use type 5: the user is appending to the string and type 5 is
     * not able to remember empty space, so sdsMakeRoomFor() must be called
     * at every appending operation. */
    // sdsheader5 会造成内存的重新分配，使用header8替代
    if (type == SDS_TYPE_5) type = SDS_TYPE_8;

    hdrlen = sdsHdrSize(type);
    // 如果不需要重新分配header，那么试着在原来的alloc空间分配内存
    if (oldtype==type) {
        newsh = s_realloc(sh, hdrlen+newlen+1);
        if (newsh == NULL) return NULL;
        s = (char*)newsh+hdrlen;
    } else {
        /* Since the header size changes, need to move the string forward,
         * and can't use realloc */
        // 如果需要更换Header，则需要进行数据的搬迁
        newsh = s_malloc(hdrlen+newlen+1);
        if (newsh == NULL) return NULL;
        memcpy((char*)newsh+hdrlen, s, len+1);
        s_free(sh);
        s = (char*)newsh+hdrlen;
        s[-1] = type;
        sdssetlen(s, len);
    }
    sdssetalloc(s, newlen);
    return s;
}
```

通过上面的函数可以了解到每次传入的都是一个旧变量，但是在返回的时候，都是**新的sds变量**，redis多数的数据结构都采用这种方式处理。

同时我们可以确认一下几个点：

+ **append**操作的实现函数为`sdscatlen`函数
+ `getrange`这种截取一段字符串内容的方式可以直接操作字符数组，对于部分内容操作看起来比较容易，效率也比较高。



## sds字符串 的空间扩容策略：

1. 如果sds字符串修改之后，空间小于1M，扩容和len等长的未分配空间。比如修改之后为13个字节，那么程序也会分配 `13` 字节的未使用空间
2. 如果修改之后大于等于1M，则分配1M的内存空间，比如修改之后为30M,则buf的实际长度为：30M+1M+1Byte

简单来说就是：

+ 小于1M，扩容修改后长度2倍
+ 大于1M，扩容1M



## 字符串命令的实现

| 命令        | `int` 编码的实现方法                                         | `embstr` 编码的实现方法                                      | `raw` 编码的实现方法                                         |
| :---------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| SET         | 使用 `int` 编码保存值。                                      | 使用 `embstr` 编码保存值。                                   | 使用 `raw` 编码保存值。                                      |
| GET         | 拷贝对象所保存的整数值， 将这个拷贝转换成字符串值， 然后向客户端返回这个字符串值。 | 直接向客户端返回字符串值。                                   | 直接向客户端返回字符串值。                                   |
| APPEND      | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此操作。 | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此操作。 | 调用 `sdscatlen` 函数， 将给定字符串追加到现有字符串的末尾。 |
| INCRBYFLOAT | 取出整数值并将其转换成 `long double` 类型的浮点数， 对这个浮点数进行加法计算， 然后将得出的浮点数结果保存起来。 | 取出字符串值并尝试将其转换成 `long double` 类型的浮点数， 对这个浮点数进行加法计算， 然后将得出的浮点数结果保存起来。 如果字符串值不能被转换成浮点数， 那么向客户端返回一个错误。 | 取出字符串值并尝试将其转换成 `long double` 类型的浮点数， 对这个浮点数进行加法计算， 然后将得出的浮点数结果保存起来。 如果字符串值不能被转换成浮点数， 那么向客户端返回一个错误。 |
| INCRBY      | 对整数值进行加法计算， 得出的计算结果会作为整数被保存起来。  | `embstr` 编码不能执行此命令， 向客户端返回一个错误。         | `raw` 编码不能执行此命令， 向客户端返回一个错误。            |
| DECRBY      | 对整数值进行减法计算， 得出的计算结果会作为整数被保存起来。  | `embstr` 编码不能执行此命令， 向客户端返回一个错误。         | `raw` 编码不能执行此命令， 向客户端返回一个错误。            |
| STRLEN      | 拷贝对象所保存的整数值， 将这个拷贝转换成字符串值， 计算并返回这个字符串值的长度。 | 调用 `sdslen` 函数， 返回字符串的长度。                      | 调用 `sdslen` 函数， 返回字符串的长度。                      |
| SETRANGE    | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此命令。 | 将对象转换成 `raw` 编码， 然后按 `raw` 编码的方式执行此命令。 | 将字符串特定索引上的值设置为给定的字符。                     |
| GETRANGE    | 拷贝对象所保存的整数值， 将这个拷贝转换成字符串值， 然后取出并返回字符串指定索引上的字符。 | 直接取出并返回字符串指定索引上的字符。                       | 直接取出并返回字符串指定索引上的字符。                       |





## 结尾：

多多翻翻资料，其实很多东西不需要去钻研细节，有很多优秀的人为我们答疑解惑，所以最重要的是理解作者为什么要这样设计，学习任何东西都要学习思想，思想层面的东西才是最有价值的。

sds已经被许多大佬文章进行过说明，这篇文章只是简单的归纳了一下自己看的内容，**如果有错误的地方还望指正**，谢谢







# 参考资料：

下面是个人学习sds的参考资料：

Redis内部数据结构详解(2)——sds

http://zhangtielei.com/posts/blog-redis-sds.html

解析redis的字符串sds数据结构：

https://blog.csdn.net/wuxing26jiayou/article/details/79644309

SDS 与 C 字符串的区别

http://redisbook.com/preview/sds/different_between_sds_and_c_string.html

Redis源码剖析--动态字符串SDS

https://zhuanlan.zhihu.com/p/24202316

C基础 带你手写 redis sds

https://www.lagou.com/lgeduarticle/77101.html

redis源码分析系列文章

http://www.soolco.com/post/73204_1_1.html

**Redis SDS (简单动态字符串) 源码阅读**

https://chenjiayang.me/2018/04/08/redis-sds-source-code/