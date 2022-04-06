# 前言

  关于jvm的大部分内容系列文章都已经讨论过了，这个系列也将近尾声，本文将会讲述关于jvm是如何实现重载和重写的，以及栈桢的内部存放的内容，这部分内容是非常重要的，也是面试有可能问到的一些高频面试点。
![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210821200358.png)


# 概述

1. 了解栈桢的内部结构，以及每一个部分组件的工作和负责的内容

2. 了解分派关键的命令：invokeVirtual命令的执行过程

3. 了解什么是方法分派，为什么Java使用的是静态多分派和动态单分派

4. 了解重载和重写是如何在jvm当中实现的



# 栈桢的内部结构

​	我们说下栈桢的内部结构，栈桢是存在于虚拟机栈的基本组成单元，也可以认为是调用方法的本质，而栈桢中则存放了虚拟机的字节码指令需要用到的数据，下面我们先来看下栈桢里面都包含哪些内容：

- 局部变量表  
- 操作数栈  
- 动态链接  
- 方法返回地址  
- 附加信息

​	可以看到一个栈桢的内容还是不少的，这里我们按照顺序来讲述每一个“变量”的内容：



## 局部变量表

  局部变量表可以简单理解为我们定义方法的方法参数，但是他不仅仅包含这些内容，还包含了方法中局部变量的参数，总的来说局部变量表存放和方法有关的一切参数。

  需要注意之前的文章讲述了在属性表存在一个叫做Code属性，这个属性就是用来存放用户代码的实际“容器”，局部变量表的长度在这个“容器”中有一个叫做 **max_locals **的字段来确定方法参数的实际长度，

  局部变量表这个“容器”的容量使用叫做“变量槽”作为基本单位的，为了保证32位和64位的操作系统兼容，这个变量槽会根据实际的操作系统执行“对齐补白”的操作，但是这也引发了一个问题，就是空间的浪费，所以为了解决这个对齐补白的问题，Java后续推出了“压缩指针”的技术来解决.....

​	下面是关于局部变量表变量槽的一些特点：

- 使用索引定位的方式，32位使用单独n指向 ，对于64位，使用n和n+1的相邻地位的方式处理  
- 方法调用使用变量槽0存储this引用位传递方法，也可以说变量槽是从1开始而不是从0开始。
- 局部变量表和类变量不同，不能不初始化就使用
- 变量作用范围中会重用重用已使用的变量槽
- 变量槽不可以不初始化就直接使用。

​	对于第四点有一个副作用：影响垃圾收集行为。由于局部变量表未发生读写重用，有可能导致大对象无法回收。比如如下代码在作用域结束之后，会发现由placeholder还存在于作用域当中，不会出现 回收的行为。

```Java
public static void main(String[] args)() {
  byte[] placeholder = new byte[64 * 1024 * 1024]; 
  System.gc();
}
```

​	既然如此有时候使用读写重用局部变量表操作数据使用obj = null 的方式对对象提前进行销毁，是否可以使用这种方式帮助虚拟机更快的把对象识别为垃圾？**大错特错**，这种方式可能给你感觉上更快的回收内存，实际上是毫无意义的。有时候甚至会影响虚拟机的自身优化



## 操作数栈

​	操作数栈是一个后入后出的栈结构，主要的作用和名字一样是用于方法中的数值运算的，通过推栈和出栈的方式计算变量的结果，操作数栈和局部变量表一样，根据不同的位数占用的大小不一样。

## 动态链接

  动态链接表示的是栈帧保持指向运行常量栈帧所属方法引用 ，他的存在意义是**支持动态连接的方法调用过程** ，这里可能不太理解，其实动态链接主要干的事情是下面两件：  

1. class常量池当中存在方法指令的符号引用  

2. 方法调用以常量池引用为参数

## 方法返回地址 

​	方法返回地址和方法的返回指令return有关，而方法返回的两种方式：  

1. 返回字节码指令（注意void方法自动在末尾添加）  

2. 异常中断调用异常退出返回值 ，同时返回地址由异处理器处理  

​	而关于退出则有下面可能的操作（这个操作实际上还是由虚拟机决定，不同的虚拟机实现不一样）：

1. 恢复上层方法局部变量与操作栈  

2. 返回值压入栈中

​	最后还包含一些额外信息，但是这部分内容并不重要这里也就直接跳过了。



# 方法解析：

  这里我们再次回到类加载的“解析”步骤，来讲解一些特殊的指令是如何实现的。调用程序编译时候已经生成的代码被称之为解析，而下面五条指令则是负责把符号引用转变为直接引用的。

- invokestatic：用于调用静态方法。  

- invokespecial：用于调用实例构造器<init>()方法、私有方法和父类中的方法。 ·invokevirt ual。用于调用所有的虚方法。  

- invokeinterface：用于调用接口方法，会在运行时再确定一个实现该接口的对象。

- invokedynamic：先在运行时动态解析出调用点限定符所引用的方法，然后再执行该方法。前面4 条调用指令，分派逻辑都固化在Java虚拟机内部，而invokedy namic指令的分派逻辑是由用户设定的引 导方法来决定的。

了解完解析的相关指令之后，我们来看下什么是虚方法，什么是非虚方法？



## 虚方法和非虚方法

  虚方法指的是在解析阶段就可以直接将符号引用解析为直接引用的方法，它包含了invokestatic和invokesp ecial指令调用的方法，它一共包含了五种：静态方法、私有方法、实例构造器、父类方法以及final 修饰的方法这五种。

  非虚的方法就是上面提到的指令之外调用生成的指令或者方法。

  方法调用除了这两种方式之外，还有一种方式叫做分派，而分配包含了动态分派和静态分派，而动态分配和静态分配又分为单分派和多分派，所以最后有下面这几种：

  - 静态多分派  

  - 静态单分派  

  - 动态多分派  

  - 动态单分派

  

## 分派

  下面是分派的方式，分配动态分派和静态分派，同时根据静态的分派和动态的分派又分为多分派和单分配，下面根据上面所属的四个分类进行解释：



### 静态分派

  为了解释静态分派，书中给出了下面的代码：

```Java
/**
* 方法静态分派演示 * @author zzm */
public class StaticDispatch {
  static abstract class Human { }
  static class Man extends Human { }
  static class Woman extends Human { }
  
  public void sayHello(Human guy) { 
    System.out.println("hello,guy!");
  }
  
  public void sayHello(Man guy) { 
    System.out.println("hello,gentleman!");
  }
  
  public void sayHello(Woman guy) { 
    System.out.println("hello,lady!");
  }
  
  public static void main(String[] args) { 
    Human man = new Man();
    Human woman = new Woman();
    StaticDispatch sr = new StaticDispatch(); 
    sr.sayHello(man);
    sr.sayHello(woman); 
  }

 } 
```

​	这里的运行结果是两个hello,guy! 因为在调用的时候，传入的对象引用在编译时期是可以确定的，所以可以认为是一种静态的分配方式，而静态的分配方式意味着方法在运行直接确定。**所以依赖静态类型的分派方式都可以称之为静态分派。**这也说明了方法的静态分派是在编译时期完成的，并且并不是通过虚拟机执行，因为在运行之前已经确定了静态类型，最后静态分配也是重载实现的关键。

​	后面还有一个关于重载顺序的讲解，当然除了面试之外这种代码是毫无意义的：

```java
package org.fenixsoft.polymorphic; 
public class Overload {
  public static void sayHello(Object arg) { System.out.println("hello Object");
  }
  public static void sayHello(int arg) { System.out.println("hello int");
  }
  public static void sayHello(long arg) { System.out.println("hello long");
  }
  public static void sayHello(Character arg) { System.out.println("hello Character");
  }
  public static void sayHello(char arg) { System.out.println("hello char");
  }
  public static void sayHello(char... arg) { System.out.println("hello char ...");
  }
  public static void sayHello(Serializable arg) { System.out.println("hello Serializable");
  }
  public static void main(String[] args) { sayHello('a');
  } 
}

```

### 动态分派

  动态分派涉及一个重要的操作：重写，有关重写的案例我们根据静态分派的案例进行改写，下面是具体的代码：

```java
 public class Dynamic{
  static abstract class Human {
    protected abstract void sayHello();
  }
  static class Man extends Human { 
    @Override
    protected void sayHello() { 
      System.out.println("man say hello");
    } 
  }
  static class Woman extends Human { 
    @Override
    protected void sayHello() { 
      System.out.println("woman say hello");
    } 
  }
  public static void main(String[] args) { 
  Human man = new Man();
    Human woman = new Woman(); man.sayHello();
    woman.sayHello(); 
    man = new Woman(); 
    man.sayHello();
  }

} 
```

  这段代码的运行结果相信都能答上来。从这一段代码中可以看到，由于多态的特性，方法的实现不可能再是在编译器可以知道的，因为这里如果按照静态编译的话一个子类会出现两个相同的方法，这时候就是动态分派起作用的时候，至于为什么jvm可以知道运行的时候到底执行哪一个方法，这又和上文提到的指令有关了，我们看下invokevirtual这个指令的执行步骤：

  ## invokevirtual指令执行过程

  invokevirtual指令的运行时解析过程大致分为以下几步:

  1)找到操作数栈顶的第一个元素所指向的对象的实际类型，记作C。

  2)如果在类型C中找到与常量中的描述符和简单名称都相符的方法，则进行访问权限校验，如果 通过则返回这个方法的直接引用，查找过程结束;不通过则返回java.lang.IllegalAccessError异常。

  3)否则，按照继承关系从下往上依次对C的各个父类进行第二步的搜索和验证过程。

  4)如果始终没有找到合适的方法，则抛出java.lang.AbstractMethodError异常。

  动态分派不仅仅需要找到方法，并且在第一步的时候就会检查对象的实际类型，而不是简单的把符号引用替换为动态引用。**运行期根据实 际类型确定方法执行版本的分派过程称为动态分派。**

  上面的执行过程可以证明这一句话：**invokevirtual 可以实现java多态的根本原因，也是字段不参与多态的原因**。



## 单分派和多分派

  这里同样还是使用原书中的代码进行解释：

```java
/**
     * 单分派、多分派演示 * @author zzm
     */
    public class Dispatch {
        static class QQ {
        }

        static class _360 {
        }

        public static class Father {
            public void hardChoice(QQ arg) {
                System.out.println("father choose qq");
            }

            public void hardChoice(_360 arg) {
                System.out.println("father choose 360");
            }
        }

        public static class Son extends Father {
            public void hardChoice(QQ arg) {
                System.out.println("son choose qq");
            }

            public void hardChoice(_360 arg) {
                System.out.println("son choose 360");
            }
        }

        public static void main(String[] args) {
            Father father = new Father();
            Father son = new Son();
            father.hardChoice(new _360());
            son.hardChoice(new QQ());
        }
```

​	我们先看看多分派，可以看到由于这里定义了QQ和360两个对象，这两个对象又在父类和子类里面作为参数进行分派动作，之前我们说过，由于静态分派是在编译时期就已经完成了，所以在进行方法和类型判断的时候会判断是调用子类还是父类，然后判断调用的哪一个具体的所属对象参数方法，这个过程通过指令**invokevir**完成并且可以判断出多个选择（选择类型和方法参数的类型），所以这种分派方式成为多分派的方式，同时在静态的情况下进行分派的，所以Java的静态分派是多分派的。

​	我们在看看单分派，既然静态是多分派的，那么动态肯定是单分派的，为什么？因为方法运行的时候总是需要确定一个具体的方法的入口的，而经过重写之后，子类不关心的参数类型是什么，他只关心执行的哪一个对象的具体方法，唯一可以决定方法的调用者，也可以说是方法的接受者是父类对象还是子类对象。所以决定了java的动态分派是单分派的，因为最终只会有一个实际类型的接受者。

​	这里可能会比较难以理解，如果要简化理解的话可以简单理解为静态多分派是根据编译器的参数以及类型多个选择判断方法调用的实际入口，此时的实际类型可以在编译时期可以直接确定，而动态单分派则是根据运行时实际调用的是哪一个调用方来确定实际调用的是那个调用者的方法，这时候实际类型是在运行的时候才可以确定的。

​	更简单的话来说就是**静态多分派在编译时期确定入口，而动态单分派在运行期确定调用者**。



## 虚拟机的动态分派

  虚拟机的动态分派实现其实可以直接按照上面的描述简单理解即可。

  在JVM当中虚方法表中存放着各个方法的实际入口地址。如果某个方法在子类中没有被重写，那子类的虚方 法表中的地址入口和父类相同方法的地址入口是一致的，都指向父类的实现入口。如果子类中重写了 这个方法，子类虚方法表中的地址也会被替换为指向子类实现版本的入口地址。



# 总结

  本文我们讲述了栈桢的结构，同时讲述分派的细节，动态分派和静态分派，以及根据单分派和多分派讲述java是如何实现重载和重写的，理解invokeVirtual的指令对于理解重载以及重写是非常重要的，因为无论是动态单分派还是静态多分派，本质上都是用到了invokeVirtual的指令判断。

  

# 写在最后

  通过本节的讲述，我们对于分派以及栈桢的理解更上了一个层次，下一篇将会讲述关于jvm如何实现动态语言的，也是十分重要的内容。