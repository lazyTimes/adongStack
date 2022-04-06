# 《深入理解JVM虚拟机》解读

# 深入理解JVM虚拟机 - 虚拟机的发展历史

​	内容基本来自《深入理解JVM虚拟机》。算是对于发展历史的一点个人总结。

# 概述：

1. JVM的发展历史以及历史进程
2. Hotspot为什么可以称霸武林
3. Hotspot和JRocket 合并，结果喜忧参半
4. jvm面临的挑战以及未来的发展前瞻

# 思维导图：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210607172330.png)

## 虚拟机发展历史

### classic VM - 第一台正式商用JAVA虚拟机

​	于1996年1月23日Sun发布jdk1.0诞生，是JAVA真正意义上第一台JVM虚拟机

#### 特点：

+ 只支持**纯解释器**运行
+ 条件编译智能用外挂（Sun wjit）。解释器和编译器**不能配合工作**。
+ 内部工作原理十分简单

#### 意义：

+ jdk1.2之前唯一指定虚拟机
+ jdk1.2 存在hotspot和exact vm 混合的情况

### 媲美hotspot的虚拟机：Exact Vm

#### 特点：

+ 准确的内存管理（可以知道那一块内存的精确数据类型）。抛弃基于句柄的对象查找方式
+ 热点探测，两级即时编译，编译和解释混合

#### 意义：

+ 由于更优秀的HotSpot虚拟机出现，没有被正式商用，存在时间十分短暂
+ jdk1.2时，sun提供了此虚拟机配合classic使用

### 武林霸主：hotspot Vm

#### 特点：

+ 具备exact vm虚拟机的所有特性
+ 支持热点代码探索
+ 精确的内存管理
+ 高频代码的标准即使编译和栈上替换（重要）

#### 意义：

+ HotRocket：jdk8的Hotspot和JRocket进行合并
+ 实际效果并不好，JRocket的很多特性没有发挥出来。

### 手机端虚拟机：Embeded vm

​	专门为了移动智能手机设计的一款jvm，但是最终失败。被Andriod直接取代。

### 天下第二：JRocket 和 IBM J9VM

#### JRocket：

##### 特点：

+ 2008年JRockit随着BEA被Oracle收购，现已不再 继续发展，永远停留在**R28版本**，这是JDK 6版JRockit的代号。
+ JRockit内部不包含解释器实现，全部代 码都靠即时编译器编译后执行
+ 专门为服务器硬件和服务端应用场景高度优化的虚拟机

##### 意义：

+ 在JDK1.8当中oracle整合JRockit到HotSpot虚拟机上，但是由于两者的特性差异较大，只整合了部分特性，结果并不是十分理想
+ 作为一款优秀的JVM实现曾经领先JVM前列
+ 同时伴随着优秀的组件Java Mission Control故障处理套件诞生。



#### IBM J9VM

##### 特点：

+ 原名叫做：IT4J，由于名字不好记J9更为广泛认知
+ 由k8扩展而来，名字来源于一个8bit的错误问题
+ 号称是世界上最快的Java虚拟机（官方定义）
+ 在商用虚拟机的领域极具影响力

##### 意义：

+ `2017年左右，IBM发布了开源J9 VM`，命名为openJ9，交给Eclipse基金会管理，也称为**Ecilpse openJ9**

### 需要特殊平台运行：Bea liquid / Azulejo VM (专用虚拟机) 

#### Bea liquid：

##### 特点：

+ 本身实现一个专门操作系统。运行在自家Hypervisor系统上
+ 由于JRocket的开发而终止。

##### 意义：

+ 随着JRockit虚拟机终止开发，Liquid VM项目也停止了。

#### Azule VM：

##### 特点：

+ 对于HotSpot进行大量的改进，运行与Azul System专有系统上面的Java虚拟机
+ 提供巨大的内存范围的停顿时间和垃圾收集时间：pic收集器c4收集器

##### 意义：

+ 最终产线投入到Zing VM虚拟机
  + 低延迟
  + 快速预热
  + 易于监控

### 挑战：Apache Harmony / google android dalvik vm

#### Apache Harmony：

##### 特点：

+ 对于HotSpot进行大量的改进，运行与Azul System专有系统上面的Java虚拟机
+ 提供巨大的内存范围的停顿时间和垃圾收集时间：pic收集器c4收集器

##### 意义：

+ 曾经因为提交TCK和SUN矛盾而愤然退出JCP组织
+ 由于Open Jdk 的出现悄然退出市场。但是内部许多的代码吸收进ibm open jdk7的实现

#### google android dalvik vm

##### 特点：

+ andriod 4之前是主流的虚拟机平台，5之后被支持提前编译ART虚拟机替代
+ 曾经非常强力的一个虚拟机
+ **不能直接运行class，但是和JAVA有着很密切的关系**。
  + DEX文件可以通过Class文件进行转化

##### 意义：

+ andriod 5之后被支持提前编译ART虚拟机替代



## 其他JVM虚拟机

​	这里介绍一些书中没有提到的非重点的JVM虚拟机

+ Micronsoft JVM：曾经作为Window平台性能最好的虚拟机。被Sun公司进行侵权制裁之后，微软转而与JAVA为敌，开发后续的.net语言对抗JAVA生态。
+ KVM：强调轻量，简单，高度可移植。运行速度比较慢。在IOS和Android出现之前受到欢迎
+ JAVA Card VM：JAVA虚拟机的一个子集，负责Applet解释和执行
+ Squarewk VM：由Sun公司开发，运行于Sun SPot，也曾经用于java card。是一款JAVA比重十分高的虚拟机。
+ JavaInJava：Sun公司在97 - 98年开发一款实验性质的虚拟机，必须运行在一个宿主的JVM上面。价值在于自证元循环，具备一定的研究价值
+ Maxine VM: 和javainjava非常相似，几乎全部以JVM作为运行环境，Graal编辑器让他有了更进一步的发展，同时Graal也是作为graal编辑器的良好辅助虚拟机
+ Jikes RVM: ibm开发的专门研究JAVA虚拟机技术的项目。也是一个元循环虚拟机
+ IKVM.NET：基于.NET 框架的java虚拟机，借助MONO得到一定的跨平台能力



# 深入理解JVM虚拟机 - jvm的对象分配策略

## 概述：

1. 书中对象优先在eden区分配实验与实际结果不符？关于实际运行结果的对比和解读
2. JVM大对象的分配细节概述，补充动态年龄判断当中书中遗漏的存活率参数。
3. 了解空间分配担保的机制，为什么会出现该机制。以及JDK版本变化的改动细节
4. 总结个人经验与教训



## 前言

​	JVM的对象分配策略是面试的中经常会碰到的点，也是学习和了解虚拟机必须迈过的一个坎。本文并不是单纯的总结书中的内容，在个人针对书中的案例进行实验的时候，发现结果居然和书中的结果**不匹配**，所以抽了不少时间专门研究了一下这一块，下面根据个人的学习和总结来描述一下个人对于JVM对象分配策略的解读。

> 注意：本部分内容不建议手机上观看，建议PC端观看，另外强烈建议有条件的同学去翻一翻《深入理解JVM虚拟机》第三版，看一下关于对象优先在eden区域分配相关的部分内容，对于理解下文所说的差异更有帮助。

## 问题：对象优先在eden区分配实验与实际结果不符？

​	下面这段代码，只要随便百度一下eden区域分配的相关博客内容，基本可以翻到一大堆的类似内容，这段代码的出处就是《深入理解JVM虚拟机》。下面我们来看看这一部分代码实际运行情况和书中的出入对比结果。

​	按照书中的描述，正确结果应该是Minor gc之后对象在eden区域分配最后的4M对象，而a1和a2以及a3因为survivor区域无法容纳则进入了老年代占用了6M的老年代内存，然而实际的结果却大相径庭。

​	先说下结论：要符合书中的情况，需要使用**serial 垃圾收集器 + jdk1.7** 的版本，才会出现书中对应的效果。其他情况下会发现各种莫名其妙的情况。

问题代码：

```java
public class MinorGcTest {
    private static final int _1MB = 1024 * 1024;

    public static void main(String[] args) {
        testAllocation();
    }

    public static void testAllocation() {
        byte[] allocation1, allocation2, allocation3, allocation4, allocation5;
        allocation1 = new byte[_1MB * 2];
        allocation2 = new byte[_1MB * 2];
        allocation3 = new byte[_1MB * 2];
        allocation4 = new byte[_1MB * 4];

    }/*jdk 1.8.0-221 运行结果：
        下面为  parallel 收集器 的运行结果:
    -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8
    eden区域存活6M对象，而老年代分配最后的4M对象
                                                        (可用空间eden 8194+1个survivor区大小1024)
    [GC (Allocation Failure) [PSYoungGen: 7925K->1006K(9216K)] 7925K->5394K(19456K), 0.0045482 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
    Heap
     PSYoungGen      total 9216K, used 7637K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
      eden space 8192K, 80% used [0x00000000ff600000,0x00000000ffc79b40,0x00000000ffe00000)
      from space 1024K, 98% used [0x00000000ffe00000,0x00000000ffefbbb0,0x00000000fff00000)
      to   space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
     ParOldGen       total 10240K, used 4387K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
      object space 10240K, 42% used [0x00000000fec00000,0x00000000ff048d18,0x00000000ff600000)
     Metaspace       used 3302K, capacity 4496K, committed 4864K, reserved 1056768K
      class space    used 355K, capacity 388K, committed 512K, reserved 1048576K

	jdk 1.8.0-221 运行结果：
    下面为 serrial 收集器的运行结果
    -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGcDetail -XX:SurvivorRatio=8 -XX:+UseSerialGC
    eden区域存活6M对象，而老年代分配最后的4M对象
    [GC (Allocation Failure) [DefNew: 7925K->1023K(9216K), 0.0063912 secs] 7925K->5300K(19456K), 0.0064606 secs] [Times: user=0.00 sys=0.02, real=0.01 secs]
    Heap
     def new generation   total 9216K, used 7654K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
      eden space 8192K,  80% used [0x00000000fec00000, 0x00000000ff279b70, 0x00000000ff400000)
      from space 1024K,  99% used [0x00000000ff500000, 0x00000000ff5ffff8, 0x00000000ff600000)
      to   space 1024K,   0% used [0x00000000ff400000, 0x00000000ff400000, 0x00000000ff500000)
     tenured generation   total 10240K, used 4276K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
       the space 10240K,  41% used [0x00000000ff600000, 0x00000000ffa2d020, 0x00000000ffa2d200, 0x0000000100000000)
     Metaspace       used 3271K, capacity 4496K, committed 4864K, reserved 1056768K
      class space    used 355K, capacity 388K, committed 512K, reserved 1048576K
    */

    /*JDK 1.7.0_51 运行结果：
    -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8
    下面为  parallel 收集器收集方案:
    eden区域存活6M对象，而老年代分配最后的4M对象
    Heap
     PSYoungGen      total 9216K, used 7669K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
      eden space 8192K, 93% used [0x00000000ff600000,0x00000000ffd7d448,0x00000000ffe00000)
      from space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
      to   space 1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)
     ParOldGen       total 10240K, used 4096K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
      object space 10240K, 40% used [0x00000000fec00000,0x00000000ff000010,0x00000000ff600000)
     PSPermGen       total 21504K, used 3019K [0x00000000f9a00000, 0x00000000faf00000, 0x00000000fec00000)
      object space 21504K, 14% used [0x00000000f9a00000,0x00000000f9cf2c78,0x00000000faf00000)

	JDK 1.7.0_51 运行结果：
    下面为 serrial 收集器的运行结果
    eden区域存活4M最后分配的对象，而老年代存活先前6M的对象
    -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGcDetail -XX:SurvivorRatio=8 -XX:+UseSerialGC
    [GC[DefNew: 7505K->533K(9216K), 0.0066009 secs] 7505K->6677K(19456K), 0.0066489 secs] [Times: user=0.03 sys=0.02, real=0.01 secs]
    Heap
     def new generation   total 9216K, used 5123K [0x00000000f9a00000, 0x00000000fa400000, 0x00000000fa400000)
      eden space 8192K,  56% used [0x00000000f9a00000, 0x00000000f9e7b6a0, 0x00000000fa200000)
      from space 1024K,  52% used [0x00000000fa300000, 0x00000000fa385660, 0x00000000fa400000)
      to   space 1024K,   0% used [0x00000000fa200000, 0x00000000fa200000, 0x00000000fa300000)
     tenured generation   total 10240K, used 6144K [0x00000000fa400000, 0x00000000fae00000, 0x00000000fae00000)
       the space 10240K,  60% used [0x00000000fa400000, 0x00000000faa00030, 0x00000000faa00200, 0x00000000fae00000)
     compacting perm gen  total 21248K, used 2923K [0x00000000fae00000, 0x00000000fc2c0000, 0x0000000100000000)
       the space 21248K,  13% used [0x00000000fae00000, 0x00000000fb0dada0, 0x00000000fb0dae00, 0x00000000fc2c0000)
    No shared spaces configured.
    */


}
```

​	个人起初刚看的时候感觉书在骗我，于是网上搜集各种资料发现大多似乎都是“抄书”（深入理解JVM虚拟机说的是什么结论就是什么），即使说的方向正确的也**没根据jdk版本进行比对过**。所以这里个人直接通过**两个jdk版本对应两个不同收集器**对比得出了如上的结果。

> ​	其实周大神并没有骗我们，因为在书本的最开头作者就说了自己的环境是基于**JDK7**的，同时在介绍本部分内容说了也是使用了 **serial 收集器**，但是 **JDK默认运行情况下不再使用Serial收集器而是Parallel收集器**。所以导致运行结果和书里面看到的完全不同。另外**JVM本身也是需要占用一定的内存**的，在垃圾收集里面会 “多出”很多不知道哪里来的内存，这一点会在下面的内容介绍。
>
> ​	不过这一部分重读一遍之后发现确实不是特别的严谨，容易导致误解也是很正常的事情。



**下面是JDK1.7和1.8比对【parallel收集器】收集器的结果截图**：

+ 从打印结果来看**jdk7的版本当中没有触发GC**，但是在jdk8版本触发了gc。
+ 在jdk1.8当中一个survivor塞满了数据，而jdk7将所有的对象内容分配到了 eden区域。
+ jdk1.8使用了元空间（废弃永久代），而jdk7 虽然存在永久代，但是可以看到常量池其实已经移到了堆当中，所以他的**总大小为堆空间的大小**。

![JDK1.7和1.8比对【parallel收集器】](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210603172915.png)



**下面是JDK1.7和1.8比对【Serial收集器】收集器的结果截图**：

+ jdk8 在老年代分配了**4M**的空间，而jdk7分配了**6M**的空间。
+ jdk7当中使用了survivor区域的一半大小空间存储，而eden区的数据为5M左右。jdk8直接为使用了7M的eden区域+1M的survivor区域，剩下对象直接分配到老年代
+ jdk1.8使用了元空间（废弃永久代），而jdk7 虽然存在永久代，但是可以看到常量池其实已经移到了堆当中，所以他的**总大小为堆空间的大小**。

![JDK1.7和1.8比对【Serial收集器】](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210603175827.png)

总结：

+ **JDK7** 当中 **PS收集器没有GC**，4M的对象直接分配在了**老年代**。如果将对象大小改为3M或2M，将触发GC。
+ **Serial收集器**下，给4M的对象分配内存时触发了一次GC。GC产生的结果：先前分配的6M的对象进入了老年代，后面分配的4M的对象分配在了新生代。
+ **Serial收集器**下增加 **-XX:PretenureSizeThreshold=3145728**可产生PS收集器相同的结果。



<font color='red'>从上面的内容可以看到，对于jdk1.7和1.8不同的收集器效果居然完全不同。</font>**究竟是什么原因导致的呢？**

​	这个问题其实很好解答：我们先对比一下在不执行任何代码的情况下两个版本对应同一个垃圾收集器使用的空间大小：从个人电脑的运行结果结果来看，**serial 收集器** 在 jdk7 中只会消耗**1M**左右的内容，而到了jdk8却需要消耗接近**4M**的内存大小。所以结论也很明显了，JVM为了保证程序运行自己需要生成一定的对象，导致对于测试结果进行“污染”，我们在进行试验的时候需要考虑到这部分内容。

> 这和所有的测试工具的思想类似：测试工具本身运行需要占用一定的内存：

```java
Heap
 def new generation   total 9216K, used 3993K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
  eden space 8192K,  48% used [0x00000000fec00000, 0x00000000fefe6540, 0x00000000ff400000)
  from space 1024K,   0% used [0x00000000ff400000, 0x00000000ff400000, 0x00000000ff500000)
  to   space 1024K,   0% used [0x00000000ff500000, 0x00000000ff500000, 0x00000000ff600000)
 tenured generation   total 10240K, used 0K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
   the space 10240K,   0% used [0x00000000ff600000, 0x00000000ff600000, 0x00000000ff600200, 0x0000000100000000)
 Metaspace       used 3258K, capacity 4496K, committed 4864K, reserved 1056768K
  class space    used 354K, capacity 388K, committed 512K, reserved 1048576K
--------------------------
Heap
 def new generation   total 9216K, used 1525K [0x00000000f9a00000, 0x00000000fa400000, 0x00000000fa400000)
  eden space 8192K,  18% used [0x00000000f9a00000, 0x00000000f9b7d418, 0x00000000fa200000)
  from space 1024K,   0% used [0x00000000fa200000, 0x00000000fa200000, 0x00000000fa300000)
  to   space 1024K,   0% used [0x00000000fa300000, 0x00000000fa300000, 0x00000000fa400000)
 tenured generation   total 10240K, used 0K [0x00000000fa400000, 0x00000000fae00000, 0x00000000fae00000)
   the space 10240K,   0% used [0x00000000fa400000, 0x00000000fa400000, 0x00000000fa400200, 0x00000000fae00000)
 compacting perm gen  total 21248K, used 2871K [0x00000000fae00000, 0x00000000fc2c0000, 0x0000000100000000)
   the space 21248K,  13% used [0x00000000fae00000, 0x00000000fb0cdff0, 0x00000000fb0ce000, 0x00000000fc2c0000)
No shared spaces configured.
```



> **关于JVM自身对象对于大对象分配的一些影响**
>
> ​	既然我们不跑任何程序都会产生一些对象，那么这些对象就肯定会影响到程序的验证结果，不妨验证一下注释掉后面一个2M空间对象以及一个4M对象分配，仅仅分配两个2M的byte数组会产生什么结果，如下面的结果显示会发现在eden区占了**8M**的空间。很明显jvm本身使用了部分数据（4M），直接分配到了eden的区域当中，而4M字节数组内存对象同样分配到eden内。
>
> ```java
> Heap
> PSYoungGen      total 9216K, used 8089K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
> eden space 8192K, 98% used [0x00000000ff600000,0x00000000ffde6560,0x00000000ffe00000)
> from space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
> to   space 1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)
> ParOldGen       total 10240K, used 0K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
> object space 10240K, 0% used [0x00000000fec00000,0x00000000fec00000,0x00000000ff600000)
> Metaspace       used 3261K, capacity 4496K, committed 4864K, reserved 1056768K
> class space    used 355K, capacity 388K, committed 512K, reserved 1048576K
> ```
>
> ​	那么如果分配6M的空间呢？这里可以看到 allocation1**（还是使用开头的代码）**和allocation2分配了4M空间，而JVM本身要占用将近4M的空间，此时eden区域已经使用了8M总空间，Eden区域已经满了，所以当allocation3进来的时候，发现eden区域分配不下，所以触发了minor gc，清理之后，发现allocation1和allocation2还是处于存活的状态，JVM依然使用了4M的空间，eden区域还是满的，survivor区域又无法装下a1或者a2，所以这时候 a1和a2直接晋升老年代，a3进入到新生代分配。
>
> ​	有读者可能会好奇， **survivor1 区域将近1M的对象存放的又是什么呢？**可以看到GC日志当中：`8089K->1016K` minor gc进行垃圾收集之后留下了1M左右的存活对象，这部分对象自然要复制到from区域（survivor），同时分代年龄+1。
>
> ```java
> [GC (Allocation Failure) [PSYoungGen: (*)=> 8089K->1016K(9216K) <=(*)] 8089K->5428K(19456K), 0.0038596 secs] [Times: user=0.19 sys=0.02, real=0.00 secs] 
> Heap
> PSYoungGen      total 9216K, used 3119K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
> eden space 8192K, 25% used [0x00000000ff600000,0x00000000ff80dbf8,0x00000000ffe00000)
> from space 1024K, 99% used [0x00000000ffe00000,0x00000000ffefe010,0x00000000fff00000)
> to   space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
> ParOldGen       total 10240K, used 4412K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
> object space 10240K, 43% used [0x00000000fec00000,0x00000000ff04f298,0x00000000ff600000)
> Metaspace       used 3348K, capacity 4496K, committed 4864K, reserved 1056768K
> class space    used 361K, capacity 388K, committed 512K, reserved 1048576K
> ```
>
> ​	如果看了上面描述的内容依然觉得云里雾里，可以开启jvm选项：<font color='red'>**-XX:+PrintHeapAtGC**</font> 。这个选项的作用是打印堆空间的变动细节，帮助你看到垃圾收集前后的堆空间变化的细节，对于垃圾收集的调试以及理解非常有帮助。
>
> 最终参数结果：`-verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:+PrintHeapAtGC`
>
> 下面是个人的打印结果：
>
> ```java
> {Heap before GC invocations=1 (full 0):
>  PSYoungGen      total 9216K, used 7925K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
>   eden space 8192K, 96% used [0x00000000ff600000,0x00000000ffdbd490,0x00000000ffe00000)
>   from space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
>   to   space 1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)
>  ParOldGen       total 10240K, used 0K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
>   object space 10240K, 0% used [0x00000000fec00000,0x00000000fec00000,0x00000000ff600000)
>  Metaspace       used 3252K, capacity 4496K, committed 4864K, reserved 1056768K
>   class space    used 353K, capacity 388K, committed 512K, reserved 1048576K
> [GC (Allocation Failure) [PSYoungGen: 7925K->1006K(9216K)] 7925K->5413K(19456K), 0.0040614 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
> Heap after GC invocations=1 (full 0):
>  PSYoungGen      total 9216K, used 1006K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
>   eden space 8192K, 0% used [0x00000000ff600000,0x00000000ff600000,0x00000000ffe00000)
>   from space 1024K, 98% used [0x00000000ffe00000,0x00000000ffefbbb0,0x00000000fff00000)
>   to   space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
>  ParOldGen       total 10240K, used 4406K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
>   object space 10240K, 43% used [0x00000000fec00000,0x00000000ff04daf8,0x00000000ff600000)
>  Metaspace       used 3252K, capacity 4496K, committed 4864K, reserved 1056768K
>   class space    used 353K, capacity 388K, committed 512K, reserved 1048576K
> }
> Heap
>  PSYoungGen      total 9216K, used 3220K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
>   eden space 8192K, 27% used [0x00000000ff600000,0x00000000ff829810,0x00000000ffe00000)
>   from space 1024K, 98% used [0x00000000ffe00000,0x00000000ffefbbb0,0x00000000fff00000)
>   to   space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
>  ParOldGen       total 10240K, used 4406K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
>   object space 10240K, 43% used [0x00000000fec00000,0x00000000ff04daf8,0x00000000ff600000)
>  Metaspace       used 3261K, capacity 4496K, committed 4864K, reserved 1056768K
>   class space    used 355K, capacity 388K, committed 512K, reserved 1048576K
> ```





## 大对象分配策略：

### 对象直接进入老年代

​	前文介绍了，对于不同的收集器，在不同的JDK版本的收集情况也存在差异，所以为了避免下面的内容造成误解，个人将按照**jdk8版本** + **手动选择使用serial收集器**进行结果的验证。

​	那么什么是大对象呢？大对象通常指的是占用大量连续内存空间的对象，比如byte数组和大字符串，更糟糕的是生成大量“朝生夕灭”的大对象会直接导致垃圾收集器的频繁启动。

​	Java中避免大对象的原因是即使eden区域本来还有非常多的内存空间，根据分代理论对象优先在eden分配的原则，由于大对象超过eden区域容量无法在此区域进行分配，就只能够被迫让垃圾收集提前执行，将存活对象搬移到survivor区域，但是最为严重的情况是垃圾收集完成之后所有的新生代对象全部存活，导致依然无法分配到eden区，这种时候大对象明显只能丢到老年代进行存放（serial和paralle收集器结果并不一致），所以**大对象意味着高额的内存复制开销**。

​	hotspot提供了：**-XX: PretenureSizeThreshold** 参数，大于该值设置的对象**直接会在老年代分配**。目的是防止eden 和 survivor 区域进行反复的复制。

> 注意：**-XX: PretenureSizeThreshold**参数只有在**serial** 和 **ParNew** 收集器中有效。如果要使用其他新生代的收集器，其他可以考虑的方案是 **ParNew  + CMS **收集器。 
>
> \* jdk7和 Jdk8 默认使用的垃圾收集器**Parallel**。

下面的代码将会验证上面的说法是否正确，实例代码如下：

```java
public class Object2Old {

    /**
     * JVM 参数：
     * -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:PretenureSizeThreshold=3145728
     * -XX:PretenureSizeThreshold=3145728 (相当于3M)
     * @param args
     */
    public static void main(String[] args) {
        byte[] allocation1;
        allocation1 = new byte[1024 * 1024 * 3];
        // allocation1 = new byte[1024 * 1024 * 3];
    }
}
```

代码结果如下：

​	由于 **没有使用-XX:+UseSerialGC参数**，默认使用的是**Parallel**收集器，所以`-XX:PretenureSizeThreshold=3145728`这个参数很明显是没有生效的。

```java
Heap
 PSYoungGen      total 9216K, used 8089K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
  eden space 8192K, 98% used [0x00000000ff600000,0x00000000ffde6550,0x00000000ffe00000)
  from space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
  to   space 1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)
 ParOldGen       total 10240K, used 0K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
  object space 10240K, 0% used [0x00000000fec00000,0x00000000fec00000,0x00000000ff600000)
 Metaspace       used 3258K, capacity 4496K, committed 4864K, reserved 1056768K
  class space    used 354K, capacity 388K, committed 512K, reserved 1048576K
```

​	现在我们开启 **-XX:+UseSerialGC** 再走一遍。运行结果如下，如果也在预料之内，4M的大对象直接分配到老年代进行存储：

```java
Heap
 def new generation   total 9216K, used 3993K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
  eden space 8192K,  48% used [0x00000000fec00000, 0x00000000fefe6540, 0x00000000ff400000)
  from space 1024K,   0% used [0x00000000ff400000, 0x00000000ff400000, 0x00000000ff500000)
  to   space 1024K,   0% used [0x00000000ff500000, 0x00000000ff500000, 0x00000000ff600000)
 tenured generation   total 10240K, used 4096K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
   the space 10240K,  40% used [0x00000000ff600000, 0x00000000ffa00010, 0x00000000ffa00200, 0x0000000100000000)
 Metaspace       used 3258K, capacity 4496K, committed 4864K, reserved 1056768K
  class space    used 354K, capacity 388K, committed 512K, reserved 1048576K

```



### 长期存活对象进入老年代

​	Hotspot多数垃圾收集器都存在分代的概念，在jdk8以前还存在永久代的概念，永久代属于方法区的范畴，这里不做过多介绍，并且jdk8之后永久代也已经从jvm中移除，所以我们重点关注新生代和老年代，新生代又由 **eden区 + 2个Survivor区**组成，默认情况下是 `8:1:1` 的比例分配，而老年代则是除开新生代的所有空间，占有着一块较大的内存，通常情况下新生代需要保证一个survivor区域为空作为备份切换。

​	JVM对象存活的流程如下：对象优先在eden区域分配，当遇到垃圾收集的时候，使用根节点枚举查找对象是否存活，如果当前对象**可以被survivor容纳**，则将存活的对象从eden区域拷贝到survivor区，同时将其对象的年龄设置为1，在survivor中的对象每熬过一次垃圾收集，对应对象的年龄就**+1**，当对象年龄到达了15，就会直接晋升到老年代。                                               

​	如果要改变这个设置，可以通过：**-XX: MaxTenuringThreshold**进行配置，默认为15， 注意区间范围：15<m<1 。    

​	这里的示例代码通过分配一个4M的对象和一个1M对象，如果设置为15，**对象年龄为15的情况下按照默认的规则进行分配（为什么老年代会出现4M的对象，这个在动态对象年龄判断进行说明）**。而如果设置为1，会发现触发了Minor GC，这里回收之后剩下1M存活对象进入S1区域，而先分配的4M数组对象则因为年龄满足为1的条件被进入S1区域，又因为S1存放不下的原因直接进入了老年代，所以后分配的1M对象在EDEN区域，而之前分配的4M对象在老年代，S1存放垃圾回收之后的对象。

```java
public class ObjectAge {
    /**
     * JVM 参数：
     * -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=1(/15)
     * -XX: MaxTenuringThreshold=15
     * -XX: MaxTenuringThreshold=1
     * @param args
     */
    public static void main(String[] args) {
        byte[] allocation1 = new byte[1024 * 1024 * 4];
        byte[] allocation2 = new byte[1024 * 1024 * 1];

    }/*
    长期存活对象进入老年代：
    注意：JVM默认需要使用4M的内存
    ---------------------------------|  15 岁年龄情况 |------------------------------------------
    Heap
     PSYoungGen      total 9216K, used 5327K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
      eden space 8192K, 65% used [0x00000000ff600000,0x00000000ffb33fb0,0x00000000ffe00000)
      from space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
      to   space 1024K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000fff00000)
     ParOldGen       total 10240K, used 4096K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
      object space 10240K, 40% used [0x00000000fec00000,0x00000000ff000010,0x00000000ff600000)
     Metaspace       used 3433K, capacity 4496K, committed 4864K, reserved 1056768K
      class space    used 369K, capacity 388K, committed 512K, reserved 1048576K
      
    ---------------------------------| 1 岁年龄情况 |------------------------------------------
    [GC (Allocation Failure) [PSYoungGen: 8192K->1008K(9216K)] 8192K->5606K(19456K), 0.0023319 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
    Heap
     PSYoungGen      total 9216K, used 2170K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
      eden space 8192K, 14% used [0x00000000ff600000,0x00000000ff722a70,0x00000000ffe00000)
      from space 1024K, 98% used [0x00000000ffe00000,0x00000000ffefc020,0x00000000fff00000)
      to   space 1024K, 0% used [0x00000000fff00000,0x00000000fff00000,0x0000000100000000)
     ParOldGen       total 10240K, used 4598K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
      object space 10240K, 44% used [0x00000000fec00000,0x00000000ff07dae0,0x00000000ff600000)
     Metaspace       used 3328K, capacity 4496K, committed 4864K, reserved 1056768K
      class space    used 361K, capacity 388K, committed 512K, reserved 1048576K
    */
}
```

### 对象动态年龄判断

​	接着上一节留下的一个问题：为什么老年代会出现4M的对象？

​	HotSpot虚拟机并不是总是根据**-XX: MaxTenuringThreshold**参数作为对象进入老年代的指标。这里存在一个更加重要的规则：<font color='red'>如果在Survivor空间当中**相同年龄**的所有对象大小总和**大于**survivor空间的一半，年龄大于等于该年龄的对象就可以直接进入老年代。</font>

​	这个要如何进行理解呢？还是直接上实际案例。

```java
public class DynamicAge {

    private static final int _1MB = 1024 * 1024;

    /**
     * JVM 参数：
     * -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:+UseSerialGC
     * -XX: MaxTenuringThreshold=15
     * -XX: MaxTenuringThreshold=1
     *
     * @param args
     */
    public static void main(String[] args) {
        // allocation1 + allocation2 的大小大于 survivor空间的1/2
        System.out.println(_1MB / 4);
        byte[] allocation1 = new byte[_1MB / 4];
        byte[] allocation2 = new byte[_1MB / 4];
        byte[] allocation3 = new byte[_1MB * 4];
//        byte[] allocation4 = new byte[_1MB * 4];
//        allocation4 = null;
//        allocation4 = new byte[_1MB * 4];

    }/*运行结果：
    JVM程序默认使用：4303K 的内存
    代码来源于深入理解JVM虚拟机，注意要使用serial收集器，个人测试版本为JDK8
    [GC (Allocation Failure) [DefNew: 4651K->1023K(9216K), 0.0021389 secs] 4651K->1867K(19456K), 0.0021767 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
    Heap
     def new generation   total 9216K, used 5174K [0x00000000fec00000, 0x00000000ff600000, 0x00000000ff600000)
      eden space 8192K,  50% used [0x00000000fec00000, 0x00000000ff00dbf8, 0x00000000ff400000)
      from space 1024K,  99% used [0x00000000ff500000, 0x00000000ff5ffff8, 0x00000000ff600000)
      to   space 1024K,   0% used [0x00000000ff400000, 0x00000000ff400000, 0x00000000ff500000)
     tenured generation   total 10240K, used 843K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
       the space 10240K,   8% used [0x00000000ff600000, 0x00000000ff6d2cd8, 0x00000000ff6d2e00, 0x0000000100000000)
     Metaspace       used 3435K, capacity 4496K, committed 4864K, reserved 1056768K
      class space    used 369K, capacity 388K, committed 512K, reserved 1048576K
    */
}
```

​	如注释说明所示，代码是从书本里面搬来的，不过个人运行的时候注释掉了后面的部分，因为jvm本身会占用一定的内存空间，从运行结果来看a1和a2两个对象在经过了判断之后，发现占用的内存大于survivor区域的一半大小，所以根据前面介绍的动态对象年龄的判断直接进入老年代，注意这里并不是512K，还包括了JVM本身存在的小对象。

​	这里其实有个漏洞，就行如果不同年龄的对象**均等分配**要如何处理？比如对象年龄为2的为30%，对象年龄为3的占30%，对象年龄为4的占30%。针对这种情况下jvm提供了参数：`-XX:TargetSurvivorRatio `参数，设定survivor区的目标使用率。默认50代表survivor区对象目标使用率为50%为限制。这个参数的意思是假设survivor对象中按照年龄排序如果**某一年龄对象累加的总和大于目标存活率**，则大于改年龄的所有对象会直接进行老年代，意味着如果年龄为4，5的对象总和大于survivor区域的50%，则会直接进入老年代，这种情况也被成为**提前进入老年代**。 

> 由于JVM本身对象占用一定内存的影响，上述-XX:TargetSurvivorRatio参数这种情况个人目前没有找到具体的代码可以确切的模拟......
>
> 另外，需要知道survivor空间的变化，可以使用参数：**-XX:+PrintTenuringDistribution**

### 空间分配担保

​	在进行Minor Gc之前，JVM会首先检查老年代的**最大可用连续空间是否大于新生代所有对象总空间**。如果此条件成立，则会查看一个叫做：`-XX:HandlePromotionFailure`参数设置是否允许分配担保失败。

​	如果允许分配担保失败：会检查最大连续内存是否大于历次晋升到老年代的内存对象平均大小，尝试**Minor GC**

​	如果不允许分配担保失败：或者不满足上述的所有条件进行**FULL GC**。

​	对于上面的内容，在书中介绍中被称之为：冒险。为什么说是冒险呢，因为新生代使用的是复制的算法，直接提到会使用eden+2个survivor区域进行存活对象的复制，S2通常是必须保证为空作为轮换备份使用。最极端的情况下如果Minor gc之后所有对象都存活，需要使用老年代进行担保，保证对象能够正常分配运行。但是如果连老年代都没有足够的连续内存容纳对象，那么此时必然需要`stop the world`进行一次full gc进行深度的垃圾清理。老年代如何知道自己的空间不足呢？老年代显然并不知道新生代会过来多少存活对象，所以只能根据 **之前每一次新生代晋升到老年代对象的平均大小** 作为经验值进行判断，决定是否进行full gc。

![空间分配担保](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210606110631.png)

> 注意：<font color='red'>**-XX:HandlePromotionFailure 在 JDK6update24之前此参数设置有效**</font>
>
> 在此版本之后，只要老年代的连续空间大于新生代总大小或者历次晋升的平均大小，就会进行minorgc。（也就是说少了前面的判断步骤）

​	由于现在基本都是JDK1.8开发，所以个人没有像书中一样测试该选项在jdk6update24之前的效果，所以我们忽略这个参数看下hotspot源码内部是如何判断的：

```java
bool TenuredGeneration::promotion_attempt_is_safe(size_t 
max_promotion_in_bytes) const { 
    // 老年代最大可用的连续空间 
    size_t available = max_contiguous_available(); 
    // 每次晋升到老年代的平均大小 
    size_t av_promo  = (size_t)gc_stats()->avg_promoted()->padded_average(); 
    // 老年代可用空间是否大于平均晋升大小，或者老年代可用空间是否大于当此GC时新生代所有对象容量 
    bool   res = (available >= av_promo) || (available >= 
max_promotion_in_bytes); 
    return res; 
} 
```

> 这段代码在哪可以看到呢？
>
> [如何下载jdk源码、hotspot源码](https://blog.csdn.net/u012534326/article/details/85457119)
>
> 文件位置：hotspot-0c94c41dcd70\src\share\vm\memory\TenuredGeneration.cpp
>
> ```java
> bool TenuredGeneration::promotion_attempt_is_safe(size_t max_promotion_in_bytes) const {
>   size_t available = max_contiguous_available();
>   size_t av_promo  = (size_t)gc_stats()->avg_promoted()->padded_average();
>   bool   res = (available >= av_promo) || (available >= max_promotion_in_bytes);
>   if (PrintGC && Verbose) {
>     gclog_or_tty->print_cr(
>       "Tenured: promo attempt is%s safe: available("SIZE_FORMAT") %s av_promo("SIZE_FORMAT"),"
>       "max_promo("SIZE_FORMAT")",
>       res? "":" not", available, res? ">=":"<",
>       av_promo, max_promotion_in_bytes);
>   }
>   return res;
> }
> ```
>
> 

## 总结：

​	jvm对象分配这一块基本内容在《深入理解JVM虚拟机》中有非常详细的解释，但是从实际的实验来看，我们不能完全当做八股文来背诵，比如动态年龄判断当中有存活率的参数作为衡量对象晋升老年代的评价指标。同样在不同JDK版本中的不同垃圾收集器对于回收的细节也可以看到明显和书里面的介绍不同，更为“痛苦”的是JVM自身需要维持程序运行的对象也干涉到了垃圾收集的结果，我们需要十分小心的判断并且排除“副作用”之后才能得到书中正确的结果。

​	从本次的实验对于个人而言也不小的收获，就是对于所以的资料都要进行质疑和实际验证，不然很容易导致误人子弟，个人最近查找这部分资料的时候发现很多就是照着书“抄上去”，既没有说明版本也没有说明是使用的哪一种垃圾收集器，令人摸不着头脑。

​	最后，感谢您的耐心阅读，如果觉得有用不妨点赞支持一下？



## 其他：

### JVM的分代年龄为什么是15？

> 答案内容来自：https://segmentfault.com/a/1190000020512977

​	接下来我们来回答JVM的分代年龄为什么是15？而不是16,20之类的呢？

​	真的不是为什么不能是其它数（除了15），着实是臣妾做不到啊！

​	事情是这样的，HotSpot虚拟机的对象头其中一部分用于存储对象自身的运行时数据，如哈希码（HashCode）、GC分代年龄、锁状态标志、线程持有的锁、偏向线程ID、偏向时间戳等，这部分数据的长度在32位和64位的虚拟机（未开启压缩指针）中分别为32bit和64bit，官方称它为“Mark word”。

​	例如，在32位的HotSpot虚拟机中，如果对象处于未被锁定的状态下，那么Mark Word的32bit空间中25bit用于存储对象哈希码，4bit用于存储对象分代年龄，2bit用于存储锁标志位，1bit固定为0 。

​	明白是什么原因了吗？对象的分代年龄占4位，也就是0000，**最大值为1111也就是最大为15**，而不可能为16，20之类的了。



## 参考资料：

> 【面试必备】小伙伴栽在了JVM的内存分配策略。。。
> https://segmentfault.com/a/1190000020512977
>
> JVM（九）内存分配策略：
>
> https://blog.csdn.net/liupeifeng3514/article/details/79183734
> 深入JVM八：JVM内存分配机制
> https://blog.csdn.net/pang5356/article/details/108492493?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-1&spm=1001.2101.3001.4242







# 深入理解JVM虚拟机 - JVM的初步了解

## 概述：

1. JVM的基础了解：了解什么是JVM，JVM到底是什么
2. JVM的大致分区：侧重了解内存分区在类进行工作时候充当的角色。
3. 类加载的大致流程
4. 串联整个JVM，JAVA加载到JVM内部的工作流程【重点】

## 前言：

​	这是一篇JVM的基础篇章，大致内容为讲解JVM的入门以及初级知识，重点在于关注JVM在日常运行中充当的角色以及如何加载一个Java程序直到程序结束的整个流程梳理。

​	下面直接进入主题

## JVM是什么

​	首先来看下JVM的定义是什么：用于执行编译后的JAVA程序的虚拟容器。具备独立的**执行引擎**。为了不受到操作系统的影响，JVM支持跨平台使用，JVM是JRE的一部分，从整体上来看，JVM的内部体系结构分为三部分，分别是：**类装载器（ClassLoader）子系统**，**运行时数据区**，和**执行引擎**。

​	这里要注意我们安装的JDK是自带了JRE的，而JVM又存在于JRE当中，所以我们安装JDK的同时也安装了JVM。



## 一个JAVA程序是如何运行的？

​	在了解JVM之前，我们需要知道，一个JAVA程序是如何运行的，在JAVA SE的基础上，我们都知道一个**JAVA**文件是**不能直接运行在JVM上的**。他需要我们编译为以**.class**为后缀的结尾**字节码文件**才能运行。所以一个JAVA程序的运行流程大致如下：

1. 需要一份写好的JAVA代码，存在**主类**以及对应入口的**main()**方法

2. 将程序进行打包或者通过`javac`命令将文件编译成为.class**字节码**文件。

3. 通过 `java -jar` 命令或者容器(比如Tomcat)，启动文件。将程序载入到JVM

4. JVM执行步骤
   1. 类加载器负责加载写好的**.class**文件到JVM当中
   2. 基于JVM的**字节码执行引擎**，执行加载到内存里写好的类。
   3. 翻译**.class**文件内容为字节码指令执行。

5. 程序结束，JVM进程停止。

> 注意：加载的细节在文章的后续章节进行解释。

下面为画图理解一下这个过程：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210623223612.png)

​	上面就是一个类加载到JVM的整体流程，看起来似乎很简单，我们只需要写好程序，编译然后直接调用命令就可以让程序跑起来。然而实际上内部的细节非常的复杂，下面我们先从和日常工作较为密切的类加载器开始介绍，看看**类加载器**到底是个什么玩意儿。



## 类加载器的基础概念

​	定义：在JVM基础上用于将CLASS文件**加载**到虚拟机内存的一个组件，这个组件负责加载程序中的类型（类和接口）并赋予唯一的名字。每一个Java虚拟机都有一个执行引擎（execution engine）负责执行被加载类中包含的指令。

​	可以简单将类加载器理解为一个黑盒，当编译好的**.class**文件经过这个黑盒之后，被翻译为一条条的字节码指令（对应机器指令）。

​	类加载器在设计上使用了双亲委派机制，分为：**启动类加载器**，**扩展类加载器**（JDK9被替换为平台加载器）**应用程序加载器**。注意只有**启动类加载器**由`C++`实现，而其他所有类加载器，统一由`JAVA`实现，下面就来看看类加载器的细节。



### 类加载的细节

​	我们先看看类加载器的大致工作流程：

​	双亲委派机制的工作模式：优先向上寻找**上层**类加载器，如果上层加载器直到顶层都无法找到对应的.class字节码文件，则从顶层向下寻找。

​	简单理解：**先委托给父类加载器加载，然后向下找到子加载器直到自定义加载器**。

​	这里可能会问，**为什么不从顶层往下找呢？**

​	首先，如果从顶层往下找，可能会出现以下的问题：由于Object总是在启动类加载器被找到，而如果此时底层定义了Object，在自上而下的加载机制中，当我们加载自己的`java.lang.Object`的时候，整个JVM系统就会因为不知道加载哪一个Object陷入混乱，同时也会干扰到子类的继承操作，所以**从下至上可以保证类永远只会被加载一次**并且可以保证程序的稳定运行。

​	其次，类加载引擎的设计本身就是子父类的设计，这在底层结构上就已经注定了他只能是这种行为模式。

 

### 预定义类加载器

​	我们再扩展一下上面提到的双亲委派机制，他的三个核心加载器加载的具体扫描内容如下：

+ **启动类加载器（Bootstrap ClassLoader）**：主要为加载jdk目录当中的Lib目录的所有内容。
+ **扩展类加载器（Extendtion ClassLoader）**：加载/ext/lib当中的所有内容

+ **应用程序加载器（Application ClassLoader）**：加载classpath所指定的类。（其实就是个人写好的类）

![类加载器结构图](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210624142625.png)

## 类加载器的过程

​	接下来介绍类加载的关键步骤，他的整体过程如下整体过程：**加载** **->** **验证** **->** **准备** **->** **解析** **->** **初始化** **->** **使用** **->** **卸载**。

​	下面来看下这些步骤都干了啥：

1. 加载：当我们想要使用某一个对象的时候，就需要通过classpath找到对应的class文件，这时候会用到前面说的双亲委派机制进行查找，保证**每一个类只会加载一次**。

   加载意味着从.class字节码文件翻译到jvm虚拟机这一个过程，但是此时还不能**直接使用此对象**

2. **验证、准备、初始化**（连接步骤）

- **验证**：将CLASS字节码加载到JVM虚拟机内存之后，验证CLASS文件的的格式是否正确，正确之后才能交给jvm虚拟机进行运行。

  > 这一步很好理解，目的是防止有人通过技术手段篡改.class文件，保证jvm的安全性，首先需要对于**.class**的格式进行验证，如果格式不符合要求，则JVM会拒绝运行class文件


- 准备**（重点）**：验证通过之后，会执行准备操作，准备会为加载到虚拟机内存的.class对象**预分配内存**，并且将对象根据具体结构进行遍历的默认值赋值。

  **准备总结：分配内存空间，对象默认值赋值**

  > ​	这里需要注意的是关于变量是否添加**final**的影响，下面的代码如果加入了final会在 **准备阶段**初始化，否则会在 **初始化阶段**才完成初始化动作，关于这一块完整细节在《深入理解JVM虚拟机》当中有多次提到，也是Java代码优化的一种比较常见的手段。
  >
  > ```java
  > // 此变量“准备”阶段进行初始化
  > private static final int KEY_PRIVATE = 0;
  > // 此变量在“初始化”阶段进行完整初始化
  > private static int KEY_PUBLIC = 0;
  > ```

- **解析：**解析的内容是将**符号引用替换为直接引用**

3. **初始化：（重点）**注意准备阶段的默认值和内存空间只是给实例变量开辟了内存空间和默认值赋值，此时对象**并没有真正拥有这一块内存**。比如`static`阶段会把静态的对象赋值到成员对象
4. 使用
5. 卸载：卸载并且销毁.class类，类生命结束。



## 类初始化的规则

​	初始化的规则也比较复杂， 作为简单理解，这里列出了几种最为简单的情况：

1. 当进行实例化对象的时候，会立即执行类加载的初始化过程。
2. 包含main方法的主类
3. **当父类未进行初始化的时候，会优先进行父类的初始化步骤**



## 类加载工作流程图

​	至此，一个类加载的大致步骤就已经了解了，我们通过画图来整理一下整个过程：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210624141505.png)

​	

>  **Tomcat也是通过类加载器的形式将java web 程序的war包加载到jvm当中，那么tomcat是如何实现类加载机制的？**
>
>  结论：Tomcat是破坏了双亲委派机制，他为每一个组件对应设置自己的类加载器，比如jsp有JSP的类加载器，webapp对应有自己的类加载器。同时tomcat是依照Common作为类加载器的主类。
>
>  1. 每一个应用程序有一个自己的webapp加载器
>  2. 统一依照Common作为公共资源的类类加载器
>  3. 这里可以明显看到jsp的加载依靠Jsp加载器，并且向上委托给webapp加载
>
>  ![Tomcat类加载器结构](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210624225244.png)
>
>  关于tomcat的部分，可以看下面的链接，个人了解不够深入，所以找了两篇资料：
>
>  Tomcat源码分析 -- Tomcat类加载器： https://www.jianshu.com/p/69c4526b843d
>
>  死磕Tomcat系列(4)——Tomcat中的类加载器：http://modouxiansheng.top/2019/07/05/%E4%B8%8D%E5%AD%A6%E6%97%A0%E6%95%B0-%E6%AD%BB%E7%A3%95Tomcat%E7%B3%BB%E5%88%97(4)-Tomcat%E4%B8%AD%E7%9A%84%E7%B1%BB%E5%8A%A0%E8%BD%BD%E5%99%A8-2019/



下面是一些简单的思考：

> **思考如何防止用户获取.class 反编译获得字节码文件的内容?**
>
> 1. 编写自定义的类加载器，对于.class文件字节码进行加密，
> 2. 通过自定义的类加载器进行解码的动作。但是自定义类加载的源码也许要保密
> 3. 核心思想是 **自定义类加载器。**重点了解即可



## 内存分区以及执行引擎

​	在了解内存的分区之前，我们先来回顾一下类加载的过程：将`.java`文件编译为`.class`文件之后，通过执行引擎将类加载到JVM系统当中完成类的加载以及初始化操作。.class类被加载进内存之后翻译为一条条的字节码指令进行运行，那么执行引擎又是如何为我们工作的呢？Jvm又要如何存放运行时产生的对象以及局部变量，JVM又是如何识别并且运行方法的？类字节码指令执行的过程中是如何运作的......这是除开类加载之外的另外一个重点JVM分区，

​	我们先重新解释一下什么是字节码指令，什么是字节码执行引擎：

​	什么是字节码指令？

​	当java文件编译生成**.class**文件之后，.class文件的内部存储的就是字节码指令。对应了一条条的机器指令。这个字节码指令将会被jvm加载之后进行翻译变为机器代码让计算机识别并且运行。

​	什么是字节码执行引擎：

​	**.class**文件里面会存在对应的字节码，而负责把字节码翻译为机器代码执行的装置就叫做字节码执行引擎。会逐条执行翻译出来的字节码指令。

​	清楚上面的类加载机制之后，我们接下来将要讲解内存分区的事情：



### 内存分区入门

​	Jvm为了更好的管理内存，会在运行时候的内存分区划分不同的区域。比如对象的方法和类加载信息放到方法区，对象实例放到堆，对象的引用到栈等。jvm将内存进行分区管理以及维护。

​	那么初级阶段需要了解什么呢？

1. 程序计数器：

   程序计数器主要保存的**下一条**字节码指令的**地址。**因为每一个线程都是独立的，所以每一个线程都有一个**单独**的程序计数器。

   程序计数器本质为一个指针，在32位系统占4个字节，在64位系统占8个字节。

2. 方法区：

   jdk1.8之前代表jvm当中的一块区域，主要是存放`.class`对象加载过来的类以及一些常量池的内容。

   Jdk1.8之后被改为Metaspace区域，除了常量池被移动到堆之外，存储的内容还是各自的**.class类**的相关信息，和之前区别不是十分大。

3. 虚拟机栈：

   当程序运行的时候，程序计数器保存为某一条指令的地址。每一条指令执行过程中方法存在局部变量，局部变量就存储在虚拟机栈内部。

   **每个线程都有自己的虚拟机栈。每一个方法对应一个栈帧。**

   当线程执行到一个方法的时候，会加载虚拟机栈对应的**栈帧**

   栈帧存储了局部变量表，操作数栈，动态链接和方法出口等内容。

   所以方法的执行就是栈帧不断进栈和出栈（虚拟机栈）的过程。

4. 堆：

   堆存储的是对象的实例对象，拥有jvm最大的一块内存分区，也就是我们new对象存储的地点。

   **所以当栈中的对象实例创建到堆时候，虚拟机栈中的局部变量表变量指向了堆内存的对象**



### 内存分区讲述初始化的过程

​	依照一个main方法的执行过程解释：程序运行的时候首先会加载并且初始化当前的主类并且将当前`main()`方法的栈帧压入当前的线程的虚拟机栈，此时栈帧会存储方法的局部变量等信息，当加载到一个new 对象方法等时候，会先判断当前的被加载的.class是否初始化，如果没有初始化则进行初始化，初始化完成之后，会在对应的堆内存空先开辟一块内存空间，并且在main方法栈帧的的局部变量表内创建一个对象的引用，而对象的引用指向刚刚分配的堆内存空间,。

​	当执行新对象的方法时候，同样会进行加载和初始化等工作，创建方法对应的栈桢，栈桢内部存储着局部变量表，如果此时方法还存在变量，则按照同样的方式把变量存储当当前栈桢对应的局部变量表。

​	为了更方便理解，我们再画一个图来理解一下：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210627182642.png)



## 程序运行的整体工作流程（重点）

​	下面我们将所有的内容串联起来，根据一段程序来讲述一个程序运行的大致流程，注意这里依然是大致流程，深究到细节还需要后续的补充：

```java
public class OneWeek {

    public static void main(String[] args) throws IOException {
        Properties properties = new Properties();
        InputStream resourceAsStream = OneWeek.class.getClassLoader().getResourceAsStream("app.properties");
        properties.load(resourceAsStream);
        System.out.println("load properties user.name = " + properties.getProperty("user.name"));
    }/*运行结果：
    load properties user.name = 123

    #app.properties:
    user.name=123
    */

}

```

​	上面的代码是简单的读取项目根路径的一个配置文件，并且读取指定的内容进行展示，非常简单的一个程序，下面就来看看他做了什么，为了减少文字说明，这里的所有运行流程会根据一个流程图来进行展示，下面请根据以下问题带入到流程图进行梳理和理解：

- 执行多个方法的调用时，如何把方法的栈帧压入线程的Java虚拟机栈？
- 栈帧里如何放局部变量？
- 如何在Java堆里创建实例对象？
- 如何让局部变量引用那个实例对象？
- 方法运行完之后如何出栈？
- 垃圾回收是如何运行的？

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210627224055.png)

​	根据上面的图标，回答如下的问题：

**执行多个方法的调用时，如何把方法的栈帧压入线程的Java虚拟机栈？**

​	回答：从图中可以看到，最终通过程序计数器以及执行引擎的配合，通过字节码指令找到的对应的.CLASS对象以及对象的方法出入口，之后压如到虚拟机栈并且创建对象以及局部变量表。

**栈帧里如何放局部变量？**

​	回答：通过局部变量表以及操作数栈的配合进处理，操作数栈进行变量的运算操作（此篇未涉及），局部变量表存储当前栈帧方法的对象引用。

> 注意局部变量表即使没有任何对象引用也是1，具体原因可以自行查找资料

**如何在Java堆里创建实例对象？**

​	回答：首先，当局部变量表碰到类似new操作的时候，会在堆内存开辟一块内存空间存放实例对象，并且在当前局部变量表创建一个引用指向堆内存的地址（此处不关注访问方式）。

**方法运行完之后如何出栈？**

​	回答：方法执行完成之后，会将当前栈帧弹出当前虚拟机栈，并且如果存在对象的引用，会将指向堆内存的变量引用进行销毁

**垃圾回收是如何运行的？**

​	当方法出栈的时候，垃圾回收线程会时刻监控堆内存的变化，如果发现没有任何引用执行实例对象，则根据根对象枚举判定此对象真的“毫无卵用”，则在满足条件之后开启垃圾回收进行清理操作，整个过程是客户端几乎无法感知的。(现代垃圾回收器基本实现和用户线程并行)



## 总结：

​	以一个程序最简单的运行流程为开始，我们介绍了什么是类加载器，并且了解了JVM预定义的类加载器机制：**双亲委派机制**，依据双亲委派机制，我们了类加载器的大致步骤，其中准备和初始化是最为关键和核心的部分，也是类加载器的过程。

​	介绍完类加载器之后，我们了解了JVM的大致内存分区，介绍了几个重要的分区：程序计数器，方法区，虚拟机栈和堆，在初步了解此阶段即可。

​	以上便是这篇文章的全部内容，类加载器当中有一个比较重要的点：Tomcat是如何打破双亲委派机制的，以及Tomcat的基本工作和加载原理。



## 写在最后：

​	这是深入理解虚拟机的开篇，希望这个系列能完结吧。。。。。



# 问题汇总

1. 不要在for循环当中不断的创建对象

2. 入栈就是为当前执行的方法创建一个栈桢入栈，出栈就是方法执行完毕之后销毁

3. 加载父类不一定要加载子类，如果单纯调用父类是不需要调用子类的，但是要注意加载子类也不一定要加载完所有的父类，这都是根据当前栈桢的方法执行了哪些内容。

4. 凡是用到某个类但是没有加载，都需要先加载类。

5. 对象头和类指针占用8个字节，同时加上字段的大小，但是jvm必须为8的倍数分配内存所以向上取整。（查阅相关资料）

   https://www.cnblogs.com/ma13461749958/p/14235421.html

6. 为什么不从顶层开始找对象？因为类加载器本身就是子父类模型。

7. 类的初始化阶段，仅仅是初始化类而已，跟对象无关，用new关键字才会构建一个对象出来。

8. 实例变量得在你创建实例对象的时候才会初始化。

这是什么意思？虽然类的实例变量在代码层面看上去已经提前分配好了，但是只有当类真正加载并且初始化之后才会进行初始化的动作。

9. jvm会保证永远只有一个main方法被加载，同时jar包需要指定main()方法的入口类
10. 为什么静态类需要加载？因为静态常量的内容通常要存放在方法区，所以一个静态常量是必要的。

> 如何自定义一个类加载器？
>
> 需要继承classLoader方法，同时重写类加载的方法，然后用自己的类加载器加载某个路径下吗的类到内存中

11. `:+TraceClasssLoading` 可以看到那些类，动手实验一下，ra.jar被全部加载
12. Tomcat加载机制的处理：

下面的类加载机制貌似很合理，但是实际上**完全是错的****❌**

真正正确的类加载方法是先加载应用程序加载器，直到加载到启动类加载器，然后再执行tomcat类加载器向下开始加载。

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210624233719.png)

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210624233727.png)

# 深入理解JVM虚拟机 - 分代与性能瓶颈

## 概述：

1. 大致了解JVM的分代的理念，建立基础的JVM分代模型
2. jvm内存的核心参数解释以及参数对于JVM性能的影响
3. 了解JVM的参数对于性能的瓶颈以及影响，如何调整参数来提升JVM的性能（重点）

## 前言

​	这一章节了解一下JVM的分代性能

