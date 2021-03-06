# 深入理解JVM - 对象分配内存

# 前言

​	这一节我们来讨论对象分配内存的细节，这一块的内容相对比较简单，但是也是比较重要的内容，最后会总结书里面的OOM的溢出案例，在过去的文章已经讲到过不少类似的情况。



# 思维导图：

地址：https://www.mubucm.com/doc/6nFUcbEn-3B

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210811220025.png)

# 概述

1. 讲述对象分配内存的方式：“指针碰撞”和“空闲列表”的实现方式
2. 对象分配中使用了哪些方法，当出现并发分配使用什么方式进行处理的。
3. 对象的访问方式有哪些，访问的过程的优劣对比
4. 对象在内存当中的布局，分为三个大类，需要重点掌握对象头的部分
5. 实战OOM的内容，这部分适合实战的时候再看。





# 对象的创建

​	对象什么时候会创建的，虽然很多情况下我们会声明比如`public static final`然而实际上这些公开常量不使用的时候其实并不会占用内存，只有在 **真正被使用的情况下才会通过类加载器加载进内存空间**。这里需要注意一个非常重要的点就是，对象一旦被创建就可以**确定对象占用的内存大小**，这一步在类加载器的阶段会完成，至于类加载器的具体细节，将会在后续的文章进行讲述。

​	对象创建的过程可以简述为：检查是否在常量池当中找到引用，如果没有引用，执行类加载的过程。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210623223612.png)

## 分配方式

​	既然知道了对象的创建，那么此时我们需要了解对象是如何分配的，一般情况下有两种主流的方案：“指针碰撞”和“空闲列表”。

​	指针碰撞：假设堆内存是绝对的规整的（前提），把所有使用过的内存放到一遍，把没有使用过多内存放在另一边，中间放着一个指针作为指示器，如果出现内存分配，则将分界线往空闲的那一边挪动即可。简单的画图理解如下：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210811070946.png)



​	空闲列表：如果内存不是规整而是交错的情况下使用这一种算法，如果内存不是规整的这时候虚拟机需要维护一个空闲列表记录那些空间是可用的，在对象分配的时候需要找到一块足够大的空间进行使用，然而如果没有足够大的空间，这时候就需要使用垃圾收集器进行收集之后，在根据内存的实际情况采用指针碰撞还是空闲列表。



### 如何判断用哪种算法？

​	这两个对象分配的算法由堆决定是否规整决定是否使用，但是堆是否规则又和**垃圾收集器**有关，如果垃圾收集器没有使用标记整理这种算法，通常情况下使用空闲列表，而如果使用了，毫无疑问此时的内存空间是十分规整的，从而会使用指针碰撞的算法。

​	另外，指针碰撞的效率明显是要比空闲列表的算法要高不少。



### 并发分配的处理办法

​	这里还有一个问题，如果此时出现两个对象并发进行创建的时候，出现的使用同一块内存进行分配的情况，这种情况下JVM又有两种处理方式： **分配内存空间的动作进行同步处理**（意思就是说吧整个分配过程同步），改进的方式是使用**CAS加上失败重试的机制保证更新操作的原子性**。

​	除此之外，还有一种方法是在分配对象是在不同的线程空间中进行的，每一个线程在JAVA堆当中分配一小块内存（可以理解为线程的专属空间），这一块内存也叫做“**本地线程缓冲**”，那个线程需要内存就分配到哪一个线程缓冲**（TLAB）**，只有本地线程缓冲用完了，才需要使用同步锁锁住。

> 提示：JVM通过使用 **-XX:+/-UseTLAB** 决定是否开启

​	毫无疑问，JVM同时使用了这两种方式，大致的方式是在本地线程缓冲池足够的时候，会使用第二种方式，但是一旦TLAB用完，就会采用CAS锁失败重试锁进行对象的分配，这样可以最大限度的减少线程停顿和等待的时间。



## 访问方式

​	了解了对象是如何分配的，这里肯定也会想知道**栈是如何访问堆上的内存**的，最简单的理解是在栈上分配一个引用，这个引用本质上是一个 **指针**，在JAVA当中叫做使用**栈上的reference 操作堆上的数据**，这个指针指向堆空间对象引用的地址，这样我们可以操作栈上的引用就可以操作堆内存的空间。最后，**对象的访问方式由虚拟机决定**。



### 访问方式的实现

​	访问方式的实现由两种方式：**句柄访问和直接访问**。下面来分别访问一下这两种方式的差别。

​	句柄访问：句柄访问的方式会在堆中划分一块内存作为句柄池，引用中存储的是句柄的地址，句柄中包含了对象的实例数据和类型数据等等具体信息的**地址**。注意这里是实例数据的地址而不是实例数据哦，用画图表示如下：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210811073323.png)

​	直接指针：更为简单好理解，栈上引用指向的就是对象实例数据的地址，访问对象不需要一次间接访问的开销。

​	![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210811073640.png)

### 优劣对比

​	句柄：

+ 垃圾清理之后，只需要改变实例指针的数据不需要改变reference。

​	直接指针：

+ 必须考虑对象实例数据的存放问题（设计）

+ 可以减少一次指针访问的内存开销同时减少指针定位的开销



​	我们知道了对象是如何访问的，现在我们再来看下，对象创建之后的内部结构如何。



# 对象在内存当中布局

​	对象的存储布局可以分为三个部分：对象头、实例数据、对齐填充。

​	

## 对象头：

​	对象头分为两类：第一类是存储自身的运行时候的数据（MarkWord），第二类是类型指针，下面来分贝说明：

​	第一类存储的是对象运行时候的数据，包含内容有 哈希码、GC分代年龄、锁状态标志，线程持有锁等等内容，这一块内存在设计上根据不同虚拟机的位数分别占用32位和64位的空间大小，官方称这一块空间为“MarkWord”。注意Markword使用的是动态定义的数据结构，方便在极小的空间存储尽可能多的内容。

### Markword的分布内容：

​	假设在32位的虚拟机当中，**对象未被同步锁定的状态**下，他的结构如下，这里需要注意的是对象分代年龄这一个面试考点：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210811075032.png)

​	第二类则是**类型指针**，通过类型指针类确定他的实例数据是哪一个类的实例，如果是数组的结构，还需要额外维护一块内容来标记数组的长度。到了这里我们暂停一下，在之前文章当中他提到过，我们分配字节数组的大小实际上JVM会耗费更多的内存空间进行存储，这里的的对象头就是消耗了一部分。

​	

## 实例数据

​	第二部分是实例数据的部分，这个部分才是真正的存储数据的地方，保存了我们在程序代码里面定义的各种字段内容。

​	另外，虚拟机的默认分配顺序为：

+ 基础类型：longs/double 向下分配
+ **对象最后分配**



## 对象补齐

​	最后一部分是对象填充的内容，基本没有多少含义，仅仅作为补齐占位符使用，同时为了保证对象的对齐标准，**对象必须是8的整数倍**。

> 提示：这里有个问题，为什么Hotspot的虚拟机起始字节是8的整数倍？
>
> 因为对象头被设计为刚好是8个倍数，这样就不需要对齐补齐，但是一旦不够会根据8的次方进行补齐的操作。

# 实战OOM

​	其实这部分已经在之前的文章已经提到过了，这些内容适合自己解决JVM问题的时候翻一翻，简单做一下笔记即可。

```
1. java堆溢出
    实例参数
        -Xmas 20m
        -xmx 20m
        -xx+HeapDumpOnOutOfMemoryError
    异常
        java heap dump
    处理方式
        如果是内存泄漏，gcroot，引用链上看对应gc的异常链信息
        检查（-xmx 与 -xmx）设置
            看参数设置
            对象生命周期过长，持有状态过长
    排查工具
        eclipse：eclipse memory analyze
2. 本地方法栈溢出
    ⚠️hotspot 本质上不区分虚拟机栈与本地方法栈。同时hotspot 不支持动态扩展。
    问题
        本地方法栈不支持动态扩展出现oom
        如何确定栈的最小值
            操作系统的内存分页大小决定
    异常
        无法容纳新的栈帧。导致soe异常
    如何验证
        使用-Xss 减少栈内存空间
        定义大量本地变量。增大方法帧中的变量表长度
        some个人实验
            stack length 981
            定义大量的栈帧（变量）
    结论
        无论是栈帧太大还是虚拟机太小，新的栈帧内存无法分配时候，soe异常
        java堆与方法区最大值计算
            单进程最大内存限制位2gb
                最大堆容量
                方法区容量
                程序计数器
                虚拟机消耗
                直接内存
            栈帧空间越大，越容易耗尽内存

3. 方法区和运行时常量池溢出
    发展历史
        Jdk6
            -xx:perm size 和 -xx:bumper size 限制永久代大小
                溢出结果：Permgen space
        Jdk7
            由于永久代放到堆上，所以出现引用一致
        jdk8
            和jdk7一致
            jdk8防止创建新类型做一些预防
                -xx: maxMetaSpaceSize: 元空间最大值默认为-1
                -xx: metaspacesize: 元空间初始大小
                -xx minMetaSpaceFreeRatio：垃圾收集后最小元空间乘百分比
    案例
        为什么java会出现两个false
            a这个字符在intern当中并不是首次遇到

        如何让方法区溢出
            Jdk8元空间与堆共享方法区，不再那么容易溢出
            jdk7可以用大量代理对象出现方法区溢出

4. 本地直接内存溢出
     异常情况
        Oom异常：和普通的oom情况不一样
            如果dump出来的文件很小，程序间接或者直接使用nio可以考虑直接内存原因
    默认是Ljava 堆最大值[ -xmx 一致]
        用-xx: maxDirectMemorySize 指定直接内存如何溢出
            使用unsafe.allocateMemory 不断申请内存

```

# 总结

​	通过对象的创建，我们了解了对象的两种分配方式，指针碰撞和空闲列表，同时我们了解了他们在不同的垃圾收集器下使用的分配方式不同，另外我们了解了并发创建对象的问题，使用CAS以及TLAB本地缓存的方式进行处理。

​	接着我们了解了对象的访问方式，拥有句柄和直接访问两种方式，接着我们对比了这两者的差别，最后我们了解了对象的具体结构。



# 写在最后

​	对象分配内存这一块内容比较简单，只要掌握对象创建内容以及相关的布局重点即可。

