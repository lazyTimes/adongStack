# 深入理解JVM - 实战JVM工具（下）

# 前言

​	接着上篇继续讲述，上一篇模拟了两个还算比较熟悉的场景，分析了之前老年代优化是如何处理的，以及使用jstat分析工具如何分析出JVM的问题，这一节会继续扩展，将会列举更多的案例来分析线上的JVM问题。

# 前文回顾

​	上一节通过一个APP的JVM内存分析解释了一些比较特殊的参数如何影响JVM，以及分析了之前老年代优化的文章中关于jstat如何进行分析和优化。



# 概述：

1. 介绍三个JVM调优的案例，一步一步分析问题和解决办法。
2. 总结分析思路和解决流程，自我思考和反思。
3. 总结和个人感想。



# 案例实战

## 案例1：方法区不断崩溃如何排查？

### 业务场景：

​	之前的案例基本都是和堆扯上关系，这个案例比较特殊是由 **JVM参数设置错误**引起的频繁的卡顿问题，简单来说就是设置了参数之后就出现访问系统卡顿并且线上不断的进行**FULL GC**的报警，这里先不说明改了哪一个参数，而是先来分析一下：

+ 发现系统在十分钟内进行了3次FULL GC，这个频繁十分高
+ 通过线上的JSTAT排查发现出现了报错`Methoddata GC Threashold` 等字样

​	根据第二点我们初步断定是JVM的方法区溢出了，**为什么JVM的方法区溢出会触发FULL GC？**事实上确实如此，因为通常情况下FULL GC也会带动方法区的回收。这一块的资料网上可以搜到一大堆，这里不再具体的介绍。



### 问题分析：

#### 加入验证参数分析：

​	既然是方法区的问题，为了进一步的排查这个方法区溢出的问题，这里需要加入下面的两个参数：

+ `-XX:TraceClassLoading`
+ `-XX:TraceClassUnloading`

​	这两个参数的作用是追踪**类加载**和**类卸载**的情况，在加上这两个参数之后继续分析，之后发现在日志的文件当中发现了下面的内容：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210731144850.png)

​	明显可以看到JVM不断的加载了一个叫做`GeneratedSerializationCOnstructorAccessor`的类，就是这个类不断的加载导致了`metaspace`区域占满，这也导致了**metaspace的对象太多触发FULL GC**，所以罪魁祸首就是这个奇怪的类`GeneratedSerializationCOnstructorAccessor`。

#### 为什么会出现奇怪的类？

​	这里使用google搜索看看这个类是什么，查询结果发现这是JDK内置类，通过查阅资料我们可以知道这是由**反射**生成的类。

​	反射的知识点也不再补充，可以理解为一种通过JVM的类加载器结合JVM的工具包生成建立对象的一种方式，也是许多框架的灵魂ss。

​	其实通过资料查阅我们还可以发现 **反射需要JVM动态的生产一些上面所说的奇怪的类到MetaSpace区域**，比如要生成动态类`ProxyClass@Proxy123123`等等类似这种对象（反射生产的类标识比较特殊），JDK都需要上面的辅助对象进行操作。

​	这里我们还需要在了解一个概念，就是**反射生成的类都是使用的软引用！**至于这个软引用在这里产生了什么影响，这里也先卖个关子，到下文结合把系统搞崩溃的参数一起进行分析。

> **什么是软引用？**在内存空间不足的时候被强制回收，不管是否存在局部变量引用。

​	接着分析关于软引用的存活时间，jvm使用了下面的公式来计算这个软引用的生命周期：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210731151311.png)

​	这个公式的含义：**表示一个软引用有多久没有被访问过了，`freespace`代表了当前的JVM中的空闲内存，`softref `代表每一个MB的空间内存空间可以允许`SoftReference` 存活多久。**

​	估算值：假设现在空间有3000M的对象，`softrefLRUpolicyMSPerMB`的值为1000毫秒，意味着这些对象会存活 3000秒 也就是50分钟左右。

​	以上就是奇怪的类出现的原因，是因为反射惹的祸。



### 排查结果：

#### 到底设置了什么参数？

​	这里讲一下到底设置了参数，让反射不断生成对象把方法区占满了，这里设置的参数如下：

​	`-XX:SoftRefLRUPolicyMSPerMB=0`这个参数。结果JVM就翻车了。

​	

#### 为什么出现奇怪的对象越来越多？

​	我们再看一下上面的公式：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210731151311.png)

​	**假设我们不小心把这个值设置为0有什么后果呢？**

​	当然是会导致上面clock公式的计算结果为0的，结果就是JVM发现每次反射分配的对象马上就会被回收掉，然后接着又会通过代理生成代理对象，简单来说这个参数**导致每次soft软引用的对象一旦分配就会马上被回收**.

​	再次强调一下**反射机制导致动态代理类不断的被新增，但是这部分对象又被马上回收掉，导致方法区的垃圾对象越来越多**这就是为什么奇怪的对象越来越多的原因。



#### 为什么会想着设置这个参数？

​	设置这个参数的原因也很天真：为了让反射生成的代理对象可以尽快被垃圾回收，如果设置为为0，当方法区的内存占用可以小一些，并且也可以及时回收，然后结果就是**好心办坏事**。



### 解决办法：

​	这里解决办法很简单，就是设置一个大于0的值并且最好是1000、2000、5000这一类数字，就是不能设置的过小或者设置为0，否则会导致方法区不断的占用结果方法去溢出最终又导致**FULL GC**。



### 总结：

​	这个案例可能看上面的说明很简单就解决了，然而实际上真正碰到类似问题，肯定会出现各种摸不着头脑的情况，希望这篇案例可以让读者设置JVM参数的时候都要验证一下这个参数的影响以及一定要确认他的参数和实际效果是一致的！

​	这个问题也完全是人的问题，加入没有好奇去想当然的设置一个奇怪的参数，也不至于造成各种奇怪的问题。

​	最后，只有多学习实际案例，平时多看看别人是如何排查问题的，这对自己的提升也有很大帮助。



## 案例2：每天数十次GC的线上系统怎么处理？

### 业务场景：

​	这个案例和上一个一样是一个实际的案例，话不多说，直接得出当时没优化过的系统的JVM性能表现大致如下：

- 机器配置：2核4G
- JVM堆内存大小：2G
- 系统运行时间：6天
- 系统运行6天内发生的Full GC次数和耗时：250次，70多秒
- 系统运行6天内发生的Young GC次数和耗时：2.6万次，1400秒

​	在使用的时候会发现问题如下：

+ 每天会发生40多次Full GC，平均每小时2次，每次`Full GC`在300毫秒左右
+ 每天会发生4000多次YGC，每分钟3次，每次YGC在50秒左右。

​	介绍到这里也可以发现这个系统的性能相当之差，每2小时就会Full GC。这是必须要进行优化的。

#### 优化前JVM参数：

​	下面是系统优化之前设置的参数：

```
-Xms1536M -Xmx1536M -Xmn512M -Xss256K -XX:SurvivorRatio=5 -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=68 -XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC
```

 我们先不观察其他内容，单从参数本身看下可能会让GC频繁的点：

1. 可以看到小机器给JVM的堆内存没有多少空间，线程和方法去要分出去一点，JVM的资源十分吃紧。
2. 新生代明显太小了，而且ratio设置为5，导致最后EDEN区只有可怜的300M左右的空间
3. 68%的CMS老年代回收阈值似乎有点小，完全可以改为92%才执行回收，老年代的空间比较大
4. `-XX:+CMSParallelRemarkEnabled`和`-XX:+UseCMSInitiatingOccupancyOnly`这两个参数的作用请自行百度。



### 问题分析

1. 在后续的排查发现每隔十几分钟就会出现大量的 **大对象**直接进入老年代，大对象的产生原因是由于开发人员使用的“**全表查询**”导致了几十万的数据被查出来，这里可以使用jmap的工具进行排查发现生成一个很大的ArrayList，并且内部都是同一个对象。
2. 虽然新生代回收之后对象很少的对象进入老年代，几十M，但是可以发现动态规则的判断之后，survior还是有几十M的对象进入到了老年代的空间。
3. 新生代的空间很容易饱满，老年代预留空间较大。
4. CMS的阈值设置为68，则达到老年代的68就开始回收，有点过于保守

 

### 解决办法：

1. 如果有条件还是需要加机器，因为机器的性能确实受限。（2G我开IDEA都够呛）
2. 新生代明显太小了，所以扩大到1G的空间很有必要，同时还是按照**5:1:1**的分配方案，给survior区域足够的空间和大小。
3. CMS的回收阈值设置到92%。不需要太过保守。
4. 方法区指定一个**256M**的大小，如果不设置任何参数**默认的方法区大小只有64M左右的空间**。

####  优化之后的参数：

​	下面是系统优化之后的参数：

```
-Xms1536M -Xmx1536M -Xmn1024M -Xss256K -XX:SurvivorRatio=5 -XX:PermSize=256M -XX:MaxPermSize=256M  -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=92 -XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC
```

> 这里再次强调一下上文提到说需要百度的参数：
>
> **-XX:+UseCMSInitiatingOccupancyOnly** **-XX:+CMSParallelRemarkEnabled** 这两个参数，这些参数有什么用？
>
> 第一个参数：表示每次都在CMS达到设置目标的情况下进行垃圾回收，不会因为JVM动态的判断导致提前进行FULL GC
>
> （这个参数有必要说明一下，因为之前的文章提到过JDK6之后CMS的默认92% 的配比，其实这个配比在实际运行的时候 **会根据CMS老年代的回收情况提前或者延迟回收**，只能说JVM细节实在是有点多，只要记住开启这个参数之后，**CMS会固定真的到达到92%这个比例才进行Full GC垃圾回收的动作**）
>
> 第二个参数：表示进行 **并发标记** 的步骤之前，先进行一次YGC，其实理论上来说通常都应该进行一次，但是实际上如果不配置JVM会根据实际情况决定是否进行YGC，原因也比较复杂，有兴趣可以把参数复制之后百度补一下课。



## 案例3：严重的FULL GC导致卡死？

​	最后介绍一个简单的案例，真的十分简单，3分钟就可以看完：

### 业务场景：

1. **一秒一次FULL GC，每次都需要几百毫秒**
2. 平时流量访问不大的时候新生代对象增长不快，老年代占用不到10%，方法区也就20%使用。但是一旦到了高峰时期就是频繁的FULL GC

### 分析：

​	在频繁**FULL GC**的时间点进行GC日志分析，同时使用JMAP分析发现在高峰时期出现大批次操作的对象，这个对象基于一个报表的批量处理的操作，会产生大量的对象并且马上出发回收，结果发现JVM内存放不下导致频繁的FULL GC。

​	这就很奇怪了我们都知道即使是在平时情况下即使很大数据的批量处理多数情况下并没有离谱到一秒一次FULL GC，那么出现这个问题毫无疑问就是代码的问题了。

​	经过排查发现，居然有开发人员手动调用垃圾回收也就是`System.gc()`。这是一个臭名昭著的方法，具体的解释可以看看**《Effective Java》**中的**第八条**：**避免使用终结方法和清除方法**.

### 解决办法：

​	为了防止`System.gc()` 生效，这里使用下面的参数禁止掉：

​	`-XX:+DisableExplictGC`

### 总结：

​	不要写`System.gc()`，最好是完全不要知道有这个方法。去探究原因其实也是比较浪费时间的事情。



# 写在最后

​	JVM的工具实战的上下两篇文章到这里就结束了，后续的文章依然会是实战的部分，从这几个案例可以看到更多的情况下并不是JVM的问题，而是人的问题。

​	所以 **写出优质好理解的代码是本分，写出性能好的代码是水平的体现**。先写出好代码才能避免线上出现各种莫名其妙的问题难以排查，而掌握线上的排查和思考手段，可以让个人的能力得到有效的锻炼，所以多多实验和尝试是这篇文章的意义





# 参考资料：

## `GeneratedSerializationConstructorAccessor` 的资料

资料1：[How the sun.reflect.GeneratedSerializationConstructorAccessor class generated](https://stackoverflow.com/questions/16708894/how-the-sun-reflect-generatedserializationconstructoraccessor-class-generated) 具备特殊上网姿势的建议阅读

> 答案来自 https://stackoverflow.com/questions/16708894/how-the-sun-reflect-generatedserializationconstructoraccessor-class-generated

 	下面摘自答案的机翻：

 **第一个回答：**

​	这是因为（可能是您在应用程序中使用反射）堆空间不足，GC 试图通过卸载未使用的对象来释放一些内存，这就是为什么您会看到 `Unloading class `

​	`sun.reflect.GeneratedSerializationConstructorAccessor`

**第二个回答**

​	方法访问器和构造器访问器要么是本机的，要么是生成的。这意味着我们对方法使用 `NativeMethodAccessorImpl` 或 `GeneratedMethodAccessor`，对构造函数使用 `NativeConstructorAccessorImpl` 和 `GeneratedConstructorAccessor`。访问器可以是原生的或生成的，并由两个系统属性控制和决定：

 ```java
 sun.reflect.noInflation = false（默认值为 false）
 sun.reflect.inflationThreshold = 15（默认值为 15）
 ```

​	当 `sun.reflect.noInflation` 设置为 **true** 时，将始终生成所使用的访问器，系统属性 `sun.reflect.inflationThreshold` 没有任何意义。当 `sun.reflect.noInflation` 为 **false** 并且 `sun.reflect.inflationThreshold` 设置为 **15** 时（如果未指定，这是默认行为）那么这意味着对于构造函数（或方法）的前 15 次访问，**本机生成器将被使用**，此后将提供一个生成的访问器（来自 ReflectionFactory）以供使用。

​	Native 访问器使用本地调用来访问信息，而生成的访问器都是字节码，因此速度非常快。另一方面，生成的访问器需要时间来实例化和加载（基本上是膨胀，因此控制它的系统属性的名称包括“膨胀”一词）。

​	更多细节可以在原始博客中找到.....

