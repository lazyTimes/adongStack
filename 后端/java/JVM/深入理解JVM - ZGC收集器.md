# 深入理解JVM - ZGC收集器

# 前言

​	上文讲到了Shenadoah收集器，这一节我们来讲一下ZGC收集器，ZGC收集器是JDK11之后由Oracle官方开发的一款低延迟垃圾收集器。另外这里吐槽一句ZGC的内容非常复杂并且知识点巨多，所以建议泡杯茶边喝边看。

​	在正式的介绍之前，先看下ZGC支持的内容：

> 关于ZGC的关键字如下：
>
> + Concurrent（并发）
> + Region-based（region）
> + Compacting（压缩-整理算法）
> + NUMA-aware（NUMA支持）
> + Using colored pointers（染色指针）
> + Using load barriers（读屏障）



# 概述

1. 介绍ZGC收集器，以及ZGC收集器的特点（重点：染色指针）
2. 了解ZGC的基本工作原理，以及工作流程和步骤
3. ZGC的深入学习方式了解（文末）



# ZGC兼容性

# Supported Platforms

| Platform      | Supported | Since  | Comment                                                      |
| :------------ | :-------- | :----- | :----------------------------------------------------------- |
| Linux/x64     | YES       | JDK 11 |                                                              |
| Linux/AArch64 | YES       | JDK 13 |                                                              |
| macOS         | YES       | JDK 14 |                                                              |
| Windows       | YES       | JDK 14 | Requires Windows version 1803 (Windows 10 or Windows Server 2019) or later. |



# ZGC收集器

## 介绍

​	ZGC收集器从名称上来看是一个缩写，然而实际上他是`Z Garbage Collector`的缩写，ZGC和Shenadoah垃圾收集器类似，都是面对低延迟为设计目标的垃圾收集器，并且都希望垃圾收集器的收集时间控制在10ms以内。

> 可以说Shenandoah是对G1垃圾收集器的扩展和升级。而ZGC更像是对于PGC垃圾收集器和C4垃圾收集器的结合。
>
> 至于PGC和C4是个啥东西，这里简单理解为一款 **实现了标记和整理阶段都全程与用户线程并发运行 的垃圾收集**，但是只能在Azul VM的虚拟机上运行（2005年就实现了，有点牛）

​	如果一定要用一段简单的话介绍的话：ZGC收集器是一个**基于Region**内存布局的，（暂时**）不设置分代**，同时使用了**读屏障**（注意没有使用写屏障），使用了**染色指针**和**内存多重映射**等技术，并且是基于 **标记-整理**算法的，以低延迟为核心的垃圾收集器。

​	

# ZGC的特点与特性：

​	下面来说说ZGC的垃圾收集器的特点，ZGC的特性十分复杂，也是本文最为重点的内容：

## 压缩-整理算法

​	ZGC使用的是**压缩整理+复制算法**进行处理，复制算法用于将存活对象复制到空闲的region。标记整理用于保证收集之后不会出现内存碎片。

## **Region**

​	和Shenandoah收集器一样，ZGC使用了region作为堆内存的布局但是ZGC的region具备大中小三个容量的region：

+ 小型：固定为**2MB**，放置小于256Kb的小对象
+ 中型：固定为**32MB**，放置大于256Kb以及小于4Mb的对象
+ 大型：**容量不固定**，可以动态的扩展，但是必须为2MB的整数倍，放置4MB以上的对象，每个大region只会存放一个对象，虽然称作大对象，但是明显可以存放4MB的对象，并且大对象有个比较严重的问题是不能进行重分配（ZGC的处理动作，在工作流程会提到），复制一个大对象的代价十分高昂，所以zgc禁止了这一个操作。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210813223734.png)

## **并发整理算法**

​	ZGC使用的也是是**并发整理**的垃圾回收算法，但是ZGC并发整理是通过**读屏障和转发指针**实现的，和shenandoah的实现方式完全不同。下面我们先来了解一下什么是染色指针。

## **染色指针**：

​	首先，ZGC使用的转发指针被称为 **染色指针**。染色指针是最纯粹的标记记录存在的方法，它**直接将少量额外的信息存储在指针上**，ZGC盯上的是寻址空间被操作系统占用之后剩下的46位空间的物理地址空间，**将高4位提取出来存储4个标志信息**，虚拟机可以直接通过这几个信息指针看到引用的三色标记状态，是否重分配（移动过），是否只能通过finalize()才能访问到，（64位的linux高18位是占用的）当然只有46位的地址空间也直接导致ZGC能够管理的内存**不可以超过4TB**，使用物理地址空间意味着**不能使用指针压缩技术**。

​	为了更好的理解，我们来看一下官方源代码中给出的图，说白了染色指针就是用了一部分地址空间来存放一些对象的标记信息，同时在对象移动之后也能保证对象引用的同步移动，0-41 这 42 位就是正常的地址，所以说 ZGC 最大支持 4TB (理论上可以16TB)的内存，因为就只用了42 位用来表示地址，这也决定了他不能进行指针压缩和不支持32位的操作系统，42-45位表示的是标志位，他们就是用来记录对象引用的，同时会指向同一个对象。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210813230712.png)

​	这里有一点需要注意的是这几个变量：M0、M1、Remapped、Finalizable。其中，[0~4TB) 对应Java堆，[4TB ~ 8TB) 称为M0地址空间，[8TB ~ 12TB) 称为M1地址空间，[16TB ~ 20TB) 称为Remapped空间。这里有个问题就是**[12TB ~ 16TB)** 这一段空间是没有使用的，**其实染色指针是可以实现到16TB，并且在JDK13中已经实现了**，为什么JDK11没有做呢？就是在这里进行了预留，在JDK13已经将这个预留空间进行的填充，让ZGC支持16G的内存。

​	ZGC将对象存活信息存储在42~45位中，这与传统的垃圾回收并将对象存活信息放在对象头中完全不同。

> 对象引用移动在以前是如何实现的？
>
> ​	在以前的实现中，如果想在对象存储额外的信息比如想要收集垃圾收集器的信息，就需要在对象头额外的扩展字段，比如对象头和对象年龄以及对象的锁状态等信息，这些信息在通常情况下是十分流畅好用的，但是一旦对象移动，事情就变得十分复杂了，这些信息究竟和谁产生关联？注意这里有个误区，认为这些数据和对象本身有关，然而实际上，它和**对象的引用存在关系**，胃泌素会这样，试想一下假设只存在对象但是本身没有对象的引用，这种对象有价值么？显然这种对象是垃圾对象。所以对象的引用才是和这些数据存在关联的。
>
> ​	而为了实现对象的引用记住这一点，在Hotspot的设计方案中，出现过把标记标记在对象头（Serial），把标记记录放置到独立的数据结构（G1，Shenadoah ）Bitmap。

​		

**染色指针是如何工作的？**

​	介绍完染色指针的实现，我们来看下染色指针是如何工作的：**染色指针**可以使得一旦某个Region的存活对象被移走之后，这个Region立即就能够被释放和重用掉，而不必等待整个堆中所有指向该Region的引用都被修正后才能清理。意味着只要有空闲的region，ZGC就可以完成回收的操作。

> Shenandoah的问题就在于此，转发指针的方式毫无疑问需要对于引用的指向进行修复（CAS锁），意味着会出现所有的region都会存活的极端情况，这时候如果需要复制的话会需要一个**至少有一半空闲空间Region来完成回收的操作。**

​	为什么染色指针可以做到这种事情，这又和染色指针的自愈特性有关系了。

### 指针自愈

​	简单概括来说就是在访问到重分配的对象会被内存屏障捕获之后通过转发指针记录表将指向旧对象的引用修复到指向新引用，这个过程就是指针自愈。

​	什么是染色指针的指针自愈呢？这里牵扯到 “**并发重分配**”的过程，为了加深指针的概念这里放到一起讲解，我们跳过**并发重分配**的处理过程，实现这一步的关键就是染色指针，在ZGC中可以根据染色指针知道对象的引用是否在一个重分配集当中，如果用户线程访问了重分配集中的对象，这一个操作就会被预先放置的内存屏障截获，然而**立即根据region的转发表记录将访问转发到新复制的对象，同时修正引用的值**，然后让引用指向新对象。

> ​	注意这个过程看起来和shenandoah的转发指针没两样，但是要注意的是shenadoah用的是读写屏障+带CAS锁操作的转发指针实现的。而ZGC直接通过染色指针加上转发指针记录表记录以及写屏障直接实现了这一个操作。两者存在本质的差别。



### 虚拟内存映射技术

​	注意这个技术是为了实现染色指针使用的，它的作用是**多个虚拟地址指向同一个物理地址**，经过多重映射转换之后，就可以实现染色指针的正常访问和寻址了。



## 读屏障

​	G1需要通过写屏障来维护记忆集，才能处理跨代指针，得以实现Region的增量回收，Shenadoah之前文章也说过只用转发指针（brooks pointer）+读写屏障完成对象新旧引用的修复动作。而**ZGC没有用写屏障**，而是只是用**读屏障**实现了并发垃圾回收的动作，具体如何应用

> ​	读屏障是JVM向应用代码插入一小段代码的技术。当应用线程从堆中读取对象引用时，就会执行这段代码。需要注意的是，仅“**从堆中读取对象引用**”才会触发这段代码。

读屏障示例：

```Java
Object o = obj.FieldA   // 从堆中读取引用，需要加入屏障
<Load barrier>
Object p = o  // 无需加入屏障，因为不是从堆中读取引用
o.dosomething() // 无需加入屏障，因为不是从堆中读取引用
int i =  obj.FieldB  //无需加入屏障，因为不是对象引用
```



## **NUMA 支持**（JDK15）

​	下面是NUMA的官方wik介绍，注意在jdk15的版本才支持，JDK11是没有进行支持的，另外g1收集器在jdk14版本中也完成了支持。ZGC实现NUMA的方式如下：

​	当Java线程分配一个对象时对象将最终位于正在执行的Java线程CPU的本地内存中，如果本地内存不足则从远程内存分配，zgc收集器会优先尝试在请求线程当前处理器多本地内存上分配对象，

> ​	ZGC具有NUMA 支持，这意味着它会尽量将 Java 堆分配定向到 NUMA 本地内存。 默认情况下启用此功能。 但是如果 JVM 检测到它绑定到系统中的 CPU子集它将自动禁用。 也就是说我们通常基本不需要管这个参数，但是可以使用 `-XX:+UseNUMA` 或 `-XX:-UseNUMA` 选项来进行控制。
>
> ​	在 NUMA 机器（例如多路 x86 机器）上运行时，启用 NUMA 支持通常会显着提升性能。



​	在介绍什么是NUMA之前，先了解什么是SMP：

> 对称多处理器结构（Symmetric Multi-Processor，**SMP**）
>
> ​	对称多处理系统内有许多紧耦合多处理器，在这样的系统中，所有的CPU共享全部资源，如总线，内存和I/O系统等，简单来说就是这种结构中所有的CPU共享一个资源，最大的特点也是计算机共享一个内存资源，这种结构在早期的南北桥的CPU结构上非常常见，结构图如下：
>
> ![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210814103420.png)
>
> ​	从图中可以看到，由于所有的CPU访问到的内存内容都是一致的（访问速度也是一致的），所以 SMP 也被称为一致存储器访问结构 (**UMA** ： Uniform Memory Access)

​	

​	随着现代处理器的不断进步，SMP架构让内存跟不上CPU的处理速度，导致大量的内存被“浪费”，所以后来人们改进出了NUMA的架构：

> 非一致内存访问 （Non-Uniform Memory Access，**NUMA**）
>
> wik地址：https://en.wikipedia.org/wiki/Non-uniform_memory_access
>
> ​	由于 SMP 在扩展能力上的限制，人们开始探究如何进行有效地扩展从而构建大型系统的技术， NUMA 就是这种努力下的结果之一。NUMA实现的就是把内容和CPU集成到一个单元上，同时由于这种CPU和内存并到一起的结构，会出现内存的访问“不一致”的特性，所以这也是被称为非一致性内存访问的原因
>
> ![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210814104852.png)
>
> ​	从上图可以看到NUMA 尝试为每个处理器提供单独的内存来解决这个问题，避免在多个处理器尝试寻址同一内存时性能下降。

​		最后，在ZGC之前的收集器就只有针对吞吐量设计的**Parallel Scavenge**支持NUMA内存分配，在JDK14G1完成了支持，JDK15中ZGC也完成了支持。



## **仅支持64位系统**	

​	ZGC仅支持64位系统，它把64位虚拟地址空间划分为多个子空间，原因是使用了**染色指针**。



# ZGC的工作流程

​	这篇文章只能大致提一下大致的工作流程，如果要完全了解细节，需要看看 **《新一代垃圾回收器ZGC设计与实现》**这本书。

​	ZGC的运作过程大致可划分为以下四个大的阶 段。全部四个阶段都是可以并发执行的，仅是两个阶段中间会存在短暂的停顿小阶段：比如初始标记初始化 GC ROOT，和Shenandoah的初始标记一致。

​	这里书中介绍了4个比较重要的步骤：**并发标记、并发预备重分配、并发重分配、并发重映射**。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210814155951.png)

​	

## 初始标记

​	所有的垃圾收集器都有这一步，注意这个阶段是JVM的一个痛点，即使到了**ZGC也会出现STW**，并且标记出所有的GC ROOT对象，并且记录到标记栈当中。



## 并发标记

​	根据GC ROOT的标记遍历对象图，同样也要经过类似G1和Shenadoah的初始标记，最终标记等步骤的短暂停顿，注意ZGC的标记是在指针而不是在对象上，标记阶段会更新M1、M2的标志位。（标记为1）



## 并发预备重分配

​	这个阶段需要用特定查询条件统计得出收集过程要清理哪些Region，将这些Region组成重分配集，重分配集和G1收集器的回收集有区别，ZGC的垃圾回收不是计算最有价值回收的REGION，而是扫描所有的Region，用范围更大的扫描省去记忆集的维护操作。

​	所以重分配**只是决定了哪些存活对象会被複製到其他Region**，标记的过程是针对全堆的，JDK12支持的类卸载和弱引用的处理也是根据这个阶段处理的。



## 并发重分配

​	核心阶段。这个过程把重分配存活对象复制到新Region，并发重分配需要为每一个Region维护一个转发表，记录从旧对象到新对象的转向关系，至于如何实现的，之前说过了指针自愈的特点，这里也不再进行赘述。



## 并发重映射

​	重映射的工作就是修正堆中指向重分配集中旧对象的所有引用，也可以直接认为就是真正进行对象引用修复的一个步骤，从这一点来看shenandoah的并发引用更新阶段是一样的，但是ZGC并不需要马上完成这个操作（因为有指针自愈的特性），ZGC把并发重映射阶段要做的工作巧妙的合并到**下一次垃圾收集循环**中的并发标记阶段中去完成，这样做的好处是节省遍历对象图的开销。

​	一旦所有指针修复，新旧对象的引用关系**转发表**就可以释放了。

> 最后提一下：《深入理解JVM虚拟机》关于工作流程这一阶段介绍的细节有点少，如果要了解每一步细节，请看推荐阅读和相关的书籍内容。



# ZGC的缺点

​	ZGC最大的缺点是 **不分代**，为什么这时候不分代反而成为缺点了呢，使用Region不是挺好的么，其实是因为分代比较难实现，并且文章开头就说过Azul在0几年就实现了并发的垃圾回收和对象分配，并且是基于分代的，当然他是针对特定的虚拟机来实现的，而JDK要考虑不同操作系统兼容，要考量的事情很多，比如下面的内容：

- 如果大量小对象分配，zgc会因为并发收集跟不上对象建立的速度，而不断堆积浮动垃圾
- 因为没有分代，所以并不能十分高速并且精准回收，需要复杂的算法进行控制



# 官方FAQ

## 为什么叫做ZGC？

​	它不代表任何东西，ZGC 只是一个名称。 它最初受到 **ZFS（**文件系统）的启发或致敬，ZFS（文件系统）首次出现时在许多方面都是革命性的。 最初，ZFS 是“Zettabyte File System”的首字母缩写，但是这个意思被放弃了，后来被说不代表任何东西。 这只是一个名字。 有关更多详细信息，请参阅 Jeff Bonwick 的博客。

## 升级日志：

​	如果不知道哪个版本加了什么新特性，可以直接从官网的wiki查到：[Main-ChangeLog](https://wiki.openjdk.java.net/display/zgc#Main-ChangeLog)

```java
JDK 16
Concurrent Thread Stack Scanning (JEP 376)
Support for in-place relocation
Performance improvements (allocation/initialization of forwarding tables, etc)
    
JDK 15
Production ready (JEP 377)
Improved NUMA awareness
Improved allocation concurrency
Support for Class Data Sharing (CDS)
Support for placing the heap on NVRAM
Support for compressed class pointers
Support for incremental uncommit
Fixed support for transparent huge pages
Additional JFR events
    
JDK 14
macOS support (JEP 364)
Windows support (JEP 365)
Support for tiny/small heaps (down to 8M)
Support for JFR leak profiler
Support for limited and discontiguous address space
Parallel pre-touch (when using -XX:+AlwaysPreTouch)
Performance improvements (clone intrinsic, etc)
Stability improvements
    
JDK 13
Increased max heap size from 4TB to 16TB
Support for uncommitting unused memory (JEP 351)
Support for -XX:SoftMaxHeapSIze
Support for the Linux/AArch64 platform
Reduced Time-To-Safepoint
    
JDK 12
Support for concurrent class unloading
Further pause time reductions
    
JDK 11
Initial version of ZGC
Does not support class unloading (using -XX:+ClassUnloading has no effect)
```

# 推荐阅读：

​	这里搜集了几篇大牛的文章，个人的文章也有参考和借鉴：

+ [新一代垃圾回收器ZGC的探索与实践](https://tech.meituan.com/2020/08/06/new-zgc-practice-in-meituan.html)

+ [美团面试官问我： ZGC 的 Z 是什么意思](https://www.cnblogs.com/yescode/p/13997822.html)
+ [R大的JVM学习进程 - **从表到里学习JVM实现**](https://www.douban.com/doulist/2545443/)
+ [R大博客](https://www.iteye.com/blog/rednaxelafx-1886170)



# 总结

​	可以看到ZGC的比Shenandoah复杂了不止一丁半点，内容比较多，需要花不少的时间来消化理解，但是如果不深入源代码这些原理都是比较好理解的，当然这里包含了不少操作系统的知识，如果觉得阅读困难有必要补补CSAPP的基础。

​	这里也不要犯难，如果把ZGC原理和实现方式弄熟，在面试官面前吹水基本是没问题的，因为能和你探讨JVM源码级别的实现的人这时候你也不是一般人了。所以不要有犯难的心理。

​	这里很多地方都参考了博客，有些内容直接搬过来了，所以多看看别人的文章看看别人如何理解然后自己再去看一遍书又会有不一样的理解，学习基本都是这么过来的，不断的借鉴和思考就是成长的过程。



# 写在最后

​	又是一篇大长文，不知道有多少人可以看完。

​	因为工作流程这一块个人学习之后觉得有点粗糙，后续会根据个人学习ZGC的内容再次进行总结。