# Netty入门

## Netty的基本介绍

由JBOSS提供的一个java开源框架，业界流行的NIO框架，整合多种协议

+ 灵活,Api使用简单
+ 成熟、稳定
+ 社区活跃：有很多NIO框架 如： mina
+ 经过大规模验证（互联网、大数据、网络游戏、电信行业）

## 实战环境

+ IDEA旗舰版

## 使用Jdk自带的Bio编写统一时间服务

```java
ServerSocket soc = null;
try {
    soc = new ServerSocket(PORT);
    System.out.println("socket connect to "+ PORT +"success");
    Socket res = null;
    while(true){
        //等待监听
        res = soc.accept();
        new Thread(new Client(res)).start();
    }
}catch (Exception e){
    e.printStackTrace();
}finally {
    if(soc != null){
        System.out.println("socket is close");
        soc.close();
    }
}
```

## 使用Bio编写BIOClient 客户端

## Bio 编写client 通信的缺陷

### 为什么不能在高并发的情况下保持高性能

#### 优点：

+ 模型简单

+ 编码简单

#### 缺点

+ 性能瓶颈：请求数和线程数 N : N 关系
+ 高并发情况下上下文切换性能消耗大

#### 案例：

web 服务器Tomcat7 之前， 都是使用BIO，7之后使用NIO



#### 改进：

使用伪NIO进行

## 网络编程的物种I/O模型

1. 阻塞式I/O
2. 非阻塞式I/O
3. **I/O复用 （select , poll, epoll ）**
   1. I/O多路复用是阻塞在select, epoll 这样的系统调用
4. 信号驱动式I/O（基本用不到）
5. 异步I/O （POSTIX的aio_ 系列函数） Future-Listener机制

## IO多路复用技术 select 、poll

### 什么是多路复用？

IO指的是网络I/O，多路指的是多个TCP连接

简而言之：使用一个或者多个线程处理多个TCP连接

最大优势是减少系统开销，不必创建多的线程，也不必去维护

### Select：

​	基本原理：

​		监视文件的3类描述符：writeds, readfds，exceptfds

​		调用后select函数会阻塞主，**等有 数据、可读、可写、出异常、超时就会返回**

​		正常返回之后，遍历fdset整个数据才能那些句柄发现了事件，来找到对银行的fd描述符然后进行io操作

缺点：

​	1）select 使用轮询进行全文扫描，fd数据增多后性能下降

​	2）每次调用select(),需要把fd集合从用户态拷贝到内核态，并进行遍历

​	3）最大缺陷就是**单个进程打开fd有限制**，默认为 **1024**

### poll

基本流程：

​	select() 和 poll() 系统调用大体一样，处理多个描述符也是使用轮询的方式，根据描述符状态进行处理一样需要把fd集合从用户态拷贝到内核态，并进行遍历

**最大区别：poll没有最大文件描述符限制（使用链表方式存储fd）**

### epoll：

基本原理：

在2.6内核当中提出的，对比select和poll, epoll更加灵活，没有描述符限制,用户拷贝到内核态只需要一次事件通知，通过epoll_ct注册fd，一旦该fd就绪，内核就会采用callback的回调机制来激活对应的fd

#### 优点：

+ 没fd限制，所支持的fd上限是操作系统的最大文件句柄数，1G内存大概支持10万个句柄
+ 效率提高，使用回调不使用轮询，不会随着fd数目增加而效率下降
+ 通过callback机制通知，内核和用户空间mmap同一款内存实现



#### linux内核核心函数

+ epoll_create()：在linux内核里面申请一个文件系统 B+树，返回epoll对象，也是一个fd
+ epoll_ctl()：操作epoll对象，在这个对象里面修改添加删除对应的链接fd，绑定callback函数
+ epoll_wait

## JAVA I/O的演进历史

1. jdk1.4 之前采用的是同步阻塞模型，也就是bio
   1. 大型服务一般用c或者c++,因为可以直接操作系统异步IO, AIO
2. jdk1.4 推出了 NIO, jdk 1.7 升级，退出 NIO2.0 , 提供AIO功能，支持文件和网络套接字的异步IO

## Netty 线程模型和Reactor 模式 （反应器设计模式）



## Echo服务

什么是Echo服务：就是一个应答服务（回显服务器），客户端发送什么数据，服务器就应答对应的数据



## 编写Echo客户端



## 深入剖析EventLopp和EvenetLoopGroup的线程模型

简介： EvenetLoop和EventGroup模块

1. 高性能RPC框架的三个要素：IO模型、数据协议、线程模型
2. EventLoop 好比一个线程， 一个 EL 可以服务多个Channel

## 数据协议Nett Encoder

对应的是：ChannelOutboundHandler, 消息对象转为字节数组

Netty 本身未提供和解码一样的编码器，因为场景不同，两者不对等

+ MessageTobyteEncoder 
  + 消息转为字节数组，**会先判断当前解码器是否支持需要发送的消息类型，如果不支持，则透传**
+ MessageToMessageEncoder
  + 用于从一种消息编码转为另一种消息

## Codec

组合解码器和编码器，以提供对于字节和消息都相同的操作

优点：成对出现，编码器和解码器都在一个类里面

缺点：耦合到一起，拓展不佳



+ ByteToMessageCodec
+ MessageToMessageCode

# Tcp粘包和拆包

TCP拆包： 一个完整的包被TCP分为多个包进行发送

TCP粘包：把多个小包组装成一个大包

## 发送方和接收方都可能出现的原因

发送方原因：TCP默认使用Nagle 算法

接收方原因：TCP接收方数据放置到缓存当中，应用程序从缓存中获取



## TCP半包读写常见解决方案

​	发送方： 可以关闭Nagle算法

​	接收方： TCP是无界的数据流，并没有处理粘包现象的机制

​	而且协议本身无法避免粘包，半包读写的发生需要在应用层进行处理

### 解决办法：

1. 设置定长消息
2. 设置消息边界
3. 使用带有消息头的协议，消息头存储消息的开始标识和长度

## 半包读写的Netty解决方案

## LineBaseFrameDecoder 和 StringDecoder 解析

　**LineBasedFrameDecoder**的工作原理是它依次遍历ByteBuf中的可读字节，判断看是否有"\n"或者“\r\n”,如果有，就以此位置为结束位置，从可读索引到结束位置区间的字节就组成了一行。它是以换行符为结束标志的解码器，支持携带结束符或者不携带结束符两种解码方式。同时支持配置单行的最大长度。如果连续读取到的最大长度后仍没有发现换行符，就会抛出异常，同时忽略掉之前督导的异常码流。



**StringDecoder**的功能非常简单，就是将收到到的对象转换成字符串，然后继续调用后面的handler。LineBasedFrameDecoder+StringDecoder组合就是按行切换的文本解码器，它被设计用来支持TCP的粘包和拆包。



## Netty自定义分隔符解决读写问题

### 使用DelimiterBasedFrameDecoder

#### maxlength: 表示一行的最大长度，如果超过没有检测出自定义分隔符，就会报<font color='red'>TooLongFrameException</font>异常



## LengthFieldBaseFrameDecoder 自定义长度



