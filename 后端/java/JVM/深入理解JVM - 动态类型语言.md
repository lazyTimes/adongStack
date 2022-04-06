# 前言

  上一节讲述了栈桢和分派的细节，这一节我们来讲讲自java语言诞生新增加的新语言特性：动态类型语言支持，这一节将会根据动态语言的特性以及相关的介绍同时讲述jvm一个重要的指令：**invoke dynamic指令**。但是需要注意的是：**invokedy namic指令面向 的主要服务对象并非Java语言，而是其他Java虚拟机之上的其他动态类型语言**

# 概述

  1. 介绍什么是动态类型语言，以及java为什么是静态语言的讲解。

  2. 介绍invokeDynamic指令在实际案例中的运用

  3. 介绍java实现动态语言调用的一些曲线救国的手段。

  

# 动态类型语言

## 什么是动态类型语言

  动态类型语言的关键特征是它的类型检查的主体过程是在运行期而不是编译期。而java就是典型的静态类型语言，需要在编码的过程中确定的，静态的语言也意味着所有的类型在编译器必须确定。

## 为什么java是静态类型？

  这里牵扯到一个问题就是为什么java是静态类型呢？我们可以看一下invokeVitual命令，这个命令根据如下的内容，确定一个属性的全类名，以及类型，在符号引用的阶段可以看到基本的内容：

  > invokevirtual #4; //Method java/io/PrintStream.println:(Ljava/lang/String;)V

  这些符号引用在翻译为直接引用是需要确切的类型的，所以在早期的java天生缺乏动态语言的支持。

  

## 动态语言类型支持

  java在jdk7之后加入了动态语言支持，关于加入动态语言类型的支持核心是使用**invoke dynamic**命令， 这种方式使用了类似曲线救国的方式，也是为兼容考虑不得不做的一种妥协，比如最常见的类型数组，在java中我们必须声明确数组存放的类型，而jdk引入了invokeDynamic这个指令之后，就可以完成对于一个方法参数的动态调用。

  > 动态类型语言是可以让对象的类型可以在运行时候再确定，比如JS和Python的var。

## invokedynamic指令

  下面来说下invoke这个指令是如何实现动态类型语言的，在java中是无法把一个函数作为参数传递的，更多的方式使用类似实现接口的方式进行处理，而新的指令在某种程度上是使用类似MethodHandle的方式进行处理的，MethodHandle是对通过字节码的方法指令调用的模拟，但和反射不同的是反射是基于Java语言服务的，而MethodHandler则是服务于所有虚拟机上的一种语言。

  每一处含有invokedynamic指令的位置都被称作“动态调用点(Dynamically-Computed Call Site)”， 这条指令的第一个参数不再是代表方法符号引用的CONSTANT_Methodref_info常量，而是变为JDK 7 时新加入的CONSTANT_InvokeDynamic_info常量，从这个新常量中可以得到3项信息:**引导方法 (Bootstrap Method，该方法存放在新增的BootstrapMethods属性中)、方法类型(MethodType)和 名称**。

  为了更好的理解这个命令，下面我们来看下实际运行过程当中的应用，比如在jdk8中引入的lambada表达式和默认方法就是通过invokedynamic命令实现的，但是使用jdk8的实现看起来比较难以理解，下面来看一下书中给的一段案例代码：

```Java
Constant pool:
#121 = NameAndType #33:#30 // testMethod:(Ljava/lang/String;)V #123 = InvokeDynamic #0:#121 // #0:testMethod:(Ljava/lang/String;)V
public static void main(java.lang.String[]) throws java.lang.Throwable; Code:
stack=2, locals=1, args_size=1
0: ldc #23 // String abc
2: invokedynamic #123, 0 // InvokeDynamic #0:testMethod: (Ljava/lang/String;)V 7: nop
8: return
public static java.lang.invoke.CallSite BootstrapMethod(java.lang.invoke.Method Handles$Lookup, java.lang.Strin Code:
    stack=6, locals=3, args_size=3
0: new
3: dup
4: aload_0
5: ldc
7: aload_1
8: aload_2
9: invokevirtual #65
12: invokespecial #71 15: areturn
#63
#1
// class java/lang/invoke/ConstantCallSite
// class org/fenixsoft/InvokeDynamicTest
// Method java/lang/invoke/MethodHandles$ Lookup.findStatic:(Ljava/lang/Cl // Method java/lang/invoke/ConstantCallSite. "<init>":(Ljava/lang/invoke/M
 
```

从上面的方法调用可以看到，使用的是invokeDynamic的调用指令以及参数为第123项的常量，比如如下的内容：

> 2: invokedynamic #123, 0 // InvokeDynamic #0:testMethod:(Ljava/lang/String;)V

而BootstrapMethod()方法中指令将会产生testMethod()方法，当然这个方法在java源码中是看不见的，而是由invokeDynamic动态生成的一个方法，当指令完成对应的方法调用之后，这个指令的调用过程也宣告结束了。

## 总结

  本文的内容比较啊间断，主要针对动态类型语言做了一个补充，内容比较剪短，至此，jvm的内容大致以及全部讲述完毕，而关于书中的最后一节并发编程的描述，个人将会放到《并发编程实战》中进行总结（又得回去看一遍）。

  

# 写在最后

  invokeDynamic主要服务的是其他语言的接入，但是从实际效果来看不是十分的理想。

  