# 前言

  上一节我们简单了解了jvm类加载器的步骤并详细分析了jvm类加载步骤的详细细节，本节将会接着讲述关于双亲委派机制的细节。双亲委派机制是jvm一个类加载的重要加载机制，它是jvm的类继承结构的底层设计也是jvm类加载的核心步骤，我们通常使用的tomcat对于双亲委派机制进行了破坏这也是需要了解的内容。

# 概述

  下面是书中jvm虚拟机执行引擎的内容概括：

```Bash
虚拟机和类加载机制概述
    掌握双亲委派模型
        三层模型
            启动加载器
            扩展类加载器
                破坏：在jdk9中转化为平台加载器
            应用程序类加载器
        Osgi模型
    什么是类加载器
        了解类加载器的作用
        关于类加载器的实际应用
    java模块化对双亲委派模型的影响
    类加载的六个步骤
        加载
        连接
            验证
            准备
            解析
        初始化
        使用
        卸载

```

# 本文内容

1. 讲述双亲委派机制的基本原理
2. 模块化对于类加载器的影响



## 思维导图

​	下面是对应的幕布思维导图地址：https://www.mubucm.com/doc/6v9RE2ggCkB

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210820093118.png)

# 类和类加载器

  在本系列的第一篇我们讲述了类加载器是加载类的核心，当我们写好的java文件被jvm虚拟机编译为.class文件并且加载到jvm虚拟机当中转为字节码指令，通过执行字节码指令完成我们编写的程序。一个类要被加载首先需要被jvm认识才行，而认识它就是靠的类加载器，类加载器毫无疑问就是来加载类的。

### 自定义类加载器

  书中给了一个自定义类加载器的案例，这里直接贴过来了。这个类加载器所做的事情就是简单的构建一个类加载，但是在最后进行instanceof的操作的时候，发现结果是false，这是因为类加载器加载的类是自定义的，而不是jvm程序生成的类。

  > 这里也可以认为如果有自定义加载器，则在进行类加载器判断的时候，需要进行“加载”的操作。因为在这里它存在 **两个**加载器。

```Java
public class ClassLoaderTest {

    public static void main(String[] args) throws ClassNotFoundException, InstantiationException, IllegalAccessException {
        ClassLoader myLoader = new ClassLoader() { @Override
        public Class<?> loadClass(String name) throws ClassNotFoundException { try {
            String fileName = name.substring(name.lastIndexOf(".") + 1)+".class"; InputStream is = getClass().getResourceAsStream(fileName);
            if (is == null) {
                return super.loadClass(name); }
            byte[] b = new byte[is.available()]; is.read(b);
            return defineClass(name, b, 0, b.length);
        } catch (IOException e) {
            throw new ClassNotFoundException(name);
        } }
        };
        Object obj = myLoader.loadClass("com.headfirst.classloader.ClassLoaderTest").newInstance();
        System.out.println(obj.getClass());
        System.out.println(obj instanceof com.headfirst.classloader.ClassLoaderTest);
    }/*运行结果：
    class com.headfirst.classloader.ClassLoaderTest
    false
   */
}
```

# 什么是双亲委派机制？

  双亲委派机制指的是jvm的一种类加载机制，jvm的类加载结构如下图：

  

  ![类加载器结构图](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210624142625.png)

  结构图如上所示，将分为三层结构，分别是启动类加载器，扩展类加载器和应用程序加载器，这三个加载器首先通过应用程序加载，如果发现无法加载类，则向上委托给父类的扩展类加载器进行加载 ，如果同样加载则继续网上进行请求加载，最后如果顶层启动类也无法加载，这时候又回从顶层向下进行加载，直到自定义加载器可以加载，最后如果都无法加载，则抛出相关的异常。

  > 关于启动类加载器等等具体的工作流程由于系列早期的文章已经讲述过这里直接给出链接：

  

  ## 关于IBM的OSGI

  osgi是当初ibm公司为了jdk模块化规范做的一个努力，当然现在早已经被jdk9的模块化取代，当然这也可以说是商业竞争下的一种妥协，最后的结果就是java的模块化和预期效果存在一定的差距，并且虽然还是破坏了双亲委派的机制，但是在整体上依旧能保持基本的类加载器的结构设计。

> 这让我想到了Jrocket和HotSpot的合并，其实效果远不如官方设计的完美效果，总是要差那么一点。

  下面是osgi的运行流程，简单了解即可：

  1. Java.* 开头，父类加载器加载  

  2. 委派名单列表，父类加载器加载  

  3. import列表委派给export bundle类加载器加载  

  4. 查找Bundler的class path，自己类加载器  

  5. 查找自己的Fragmet Bundle  

  6. 委派Bundle的类加载加载  

  7. 类查找失败



  ## Java双亲委派模型的挑战

  双亲委派机制受到过三次挑战（也可以说是四次），由于双亲委派机制是jdk1.2才加入的，为了向前兼容在当时的为了妥协选择了一个不太好的实现就是使用`findClass()`的方法进行了重写，但是这个方法在后续的兼容过程中很快就出了问题，如果有基础类型要回调下层的类比如典型的JNDI服务就是如此，这时候为了兼容又只能不太好的设计就是新增一个**线程上下文类加载器**，这个加载器可以理解为在启动类加载器做了一个插件，如果用户自己实现了这个插件，就会调用客户的代码，否则就会从父类的加载器中进行继承。

  > 这个**线程上下文加载器就是tomcat实现破坏双亲委派机制的核心**。当然不止tomcat，很多框架也有用到这个线程上下文加载器，在类的加载的阶段“做手脚”。

  接着关于程序热替换的挑战了，简单来说就是程序的模块化，关于模块化的内容，在《Java8实战》的书籍里面有简单的理论基础讨论，但是如果要深入模块化，内容有一本书可以来讲，这里也不再赘述关于OSGI和Jisaw的历史了，关于他所做的事情可以看上一个小节。

  最后就是Jdk9实现模块化之后的平台类加载器了，这个类加载器基本上算是破坏了JDK的规则，下文会有详细的介绍，如果简单理解这个类加载器就是把之前一直不太优雅的线程上下文加载器通过底层实现了， 也就是说平台类加载器将可以根据模块定义的类加载器进行自定义的加载操作。

  最后简单总结上面的内容如下：

```
1. Jdk1.2之前旧代码兼容，使用findClass避免对loadClass() 重写
2. JNDI 在Thread.setContextClassLoader() 进行设置
    jdk6对serialLoader取代结果
3. 程序动态性与模块化问题
4. 平台加载器破坏原有类加载规则，线程上下文类加载器的底层兼容实现

```





  ## 模块化之后双亲委派模型变动  

  撇去模块化对于类加载的其他细节，我们这里直接讲述模块化之后最大的变动：**扩展类加载器（Ext）替换为 平台加载器（plaform）**，主要变化是平台加载器和应用程序加载器不再派生自`URLClassLoader `，由于存在`BootClassLoader`为了兼容旧版的加载器返回null使用上层引导器这一条件，结果不会返回出来。

  JDK 9中虽然仍然维持着三层类加载器和双亲委派的架构，但类加载的委派关系也发生了 变动。当平台及应用程序类加载器收到类加载请求，在委派给父加载器加载前，要先判断该类是否能 够归属到某一个系统模块中，如果可以找到这样的归属关系，就要**优先委派给负责那个模块的加载器 **完成加载，也许这可以算是对双亲委派的第四次破坏？其实从个人看来更像是改变设计不太优雅的“线程上下文加载器”。

  

  

  # 总结

本文的内容也比较简单，同样了解即可。重点在于记住双亲委派机制的步骤以及他的工作原理。



  # 写在最后

下篇文章将会针对分派的内容进行讲解，也是jvm非常重要的一部分，通过分派的学习可以对重载、多态、重写有更多的了解。

  