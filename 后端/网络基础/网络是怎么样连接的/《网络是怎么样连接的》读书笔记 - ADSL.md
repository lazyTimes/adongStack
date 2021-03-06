# 《网络是怎么样连接的》读书笔记 - ADSL

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202206200652535.png)

# 简介

整个互联网的体系架构看起来复杂，实际上基本的工作方式单调而乏味，就是从一个路由器到下一个路由器。

这一部分介绍有关ADSL的接入方式，如果是90后基本都很熟悉以前通过拨号上网的方式接入互联网，对于用户来说是打个电话就可以上网，但是内部的工作流程其实还是比较复杂的。

# 术语介绍

ADSL： `Asymmetric Digital Subscriber Line`，不对称数字用户线。它是一种 利用架设在电线杆上的金属电话线来进行高速通信的技术，它的上行方向 （用户到互联网）和下行方向（互联网到用户）的通信速率是不对称的。

# 传输过程图

ADSL传输可以总结下面的简化图，说实话第一眼看过去确实很复杂，所以接下来的传输部分将会按照步骤进行拆解。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202206200653033.png)


# 传输过程

从全局来看，整个过程是用户发出网络包通过用户端的电话局，然后到达网络运营商（ISP，互联网服务提供商），最后通过接通路由器上网。

下面

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202206200653490.png)

**接通路由器**

第一步是接通路由器，这一步的主要操作是根据包 IP 头部中的接收方 IP 地址在路由表的目标地址中进行匹配，找到相应的路由记录后将包转发到这条路由的目标网关。

> 整个流程图在书中已经画的十分清晰了，如果无法理解这些设备干啥的，只要模糊理解大概做了什么事情在那个位置即可。

虽然整个工作流程和以太网以及路由器的工作方式类似，但是实际上还是有一些区别的，主要区别是在头部的网络包的头部部分会额外添加一些东西，**MAC 头部、PPPoE 头部、PPP 头 部** 总共3种头部。

**ADSL Modem**

完成互联网接入路由器操作之后，接着请求发送给`ADSL Modem`，这里可以看到数据被拆分为一个个的小格子，这些小格子被称为**信元**。

信元同样包含头部和数据部分，整个拆分过程类似TCP/IP 把数据拆包，拆分完成之后信元需要应用于一种叫做**ATM**的通信技术完成通信。

> ATM采用面向连接的传输方式，将[数据分割](https://baike.baidu.com/item/%E6%95%B0%E6%8D%AE%E5%88%86%E5%89%B2/4395664)成固定长度的信元，通过虚连接进行交换。ATM集交换、复用、传输为一体，在复用上采用的是[异步时分复用](https://baike.baidu.com/item/%E5%BC%82%E6%AD%A5%E6%97%B6%E5%88%86%E5%A4%8D%E7%94%A8/666141)方式，通过信息的首部或标头来区分不同信道。

转化为信元之后`ADSL Modem` 会把数据转为圆滑波形的信号表示0和1 ，这种技术被称为调制，`ADSL Modem`为**振幅调制（ASK）**和**相位调制（PSK）**相结合的正交振幅调 制（QAM） A方式。

如果不太清楚这两个是啥也不重要，其实主要是电子信号波的不同处理方式罢了。

-   **振幅调变**（**Amplitude Modulation**，**AM**），也可简称为**调幅**，是在电子通信中使用的一种[调变](https://zh.wikipedia.org/wiki/%E8%AA%BF%E8%AE%8A)方法，最常用于[无线电](https://zh.wikipedia.org/wiki/%E6%97%A0%E7%BA%BF%E7%94%B5)[载波](https://zh.wikipedia.org/wiki/%E8%BD%BD%E6%B3%A2)传输信息。

	振幅调变简单的把高振幅为1，低振幅为0，由于调幅是最早期的调变方式，他的优点是容易恢复讯号，但是因为信号终究会随着距离衰减，所以调幅需要控制传输的级别，级别过多容易出错。
	
-   **相位调制**，这是一种根据信号的相位来对应 0 和 1 的方式，`Modem` 会产生一个一定周期振动的波，一个周期是360度，可以看作是一个完整的圆被划分为两个部分，相位调制和调幅类似，也可以通过变化周期也就是角度来控制频率。


> 为什么不像互联网一样使用使用方波信号的0和1 表示？
> 1.  方波传输容易失真，距离延长错误率会提高。
> 2. 方波是宽频频段，如果频率过宽会产生难以控制的噪声

正交振幅调制实际上就是把上面两种调制方式融合在一起，最后就成为了`ADSL Modem`的调制方式，最后形成下面这张图：

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202206202117172.png)


通过这样灵活的波段方式，ADSL通过给噪声大的波段更少的Bit和噪声小的波段更多的比特进行灵活控制。

**分离器**

信元数据转为电信号之后是把数据发给**分离器**，分离器看起来像是出网的时候进行分离，实际上工作是在**入网**的时候。

因为电信号和电话的信号一起传输给另一端的，如果不分离两种信号那么电话听到的将会全是噪音，十分影响用户体验。

分离器的工作原理非常简单，简单来讲就是屏蔽`ADSL`所使用的高频信号而已，电话信号将会传到电话机，而ADSL的信号传给另一端的`ADSL Modem`。

从另一个角度来说分离器另一个作用是防止电话信号传到`ADSL Modem`那边，之所以要这样做是拿起话筒和放下话筒的时候电话信号的传输路径会出现调整，线路状态转变容易导致ADSL通信发生重连的问题。

**DSLAM和BAS**

信号通过配线盘接收到信号之后毫无疑问是把信号翻译回信元，翻译工作交给 DSLAM 设备完成。

DSLAM 设备相当于多个**ADSL Modem**捆到一起的设备，获取到信元之后数据进入到BAS包转发设备，BAS这个暂时抽象看作路由器即可，他和DSLAM 具备兼容的ATM 接口，主要的工作是负责把信元翻译成原始包。

这里可能会有疑问为什么不让 DSLAM 自己直接干这件事？这是因为DSLAM为了接受信元就需要做十分大量的工作，如果再让他负责翻译很容易造成职责捆绑过多出现问题，通用面对复杂的互联网更要小心职权划分。

数据进入倒BAS之后，接下来的工作是把原始数据一步步“解套”，比如把头部的MAC和PPPPoe头部丢弃，只保留PPP部分和后面的真实包（IP和数据包），因为他们工作已经完成了。

接下来BAS会找这个包所属的隧道并给这个包打上头部标记送走，隧道的出口就是隧道专用的路由器，送达之后同样是丢弃头部取出最终的IP模块信息。

> 在这之后就是传统的接入互联网的部分了，不得不说以前上网是非常麻烦的并且价格昂贵，个人小时候也只在亲戚家看过这种拨号上网的方式（自己家里的网络是接其他家路由器蹭的）。

**以太网传输PPP消息**

ADSL 和 [FTTH](https://www.wolai.com/lazytime/t3zkmB1u6Zvo3L5CH9L7ob#8hA6Ctzk2Woc2tvy1w1aBw) 接入方式需要为计算机分配公有地址才能上网。

PPP大部分情况其实用到的功能很少，它的主要作用是方便运营商进行快速切换，但是PPP又无法直接用于ADSL和FTTH，所以这里绕弯的方式进行了处理。

由于PPP本身不符合以太网的传输协议，通常需要另一种协议进行适配，这种协议叫做**HDLC协议**，但是PPP如果使用HDLC协议，又会导致ADSL和FTTH无法接入。

所以要找别的方式对于以太网进行包装，另外需要注意以太网的设计和HDLC协议是不互通的，一番波折之后以太网找到了**PPPoE**互通。

这一部分理解可能会比较复杂，实际上按照设计模式的理解就是桥接和适配的过程，总之互联网的难题总是可以尝试加一层去解决，这里的方案也是类似的。

通过PPPoE互通之后，ADSL和FTTH就实现了拨号上网的方式。这里需要记住**PPPoE 是将 PPP 消息装入以太网包进行传输的方式**，换种方式说可以称PPPoe作为以太网上的PPP协议。

**补充**

**HDLC（High-Level Data Link Control，高级数据链路控制）**，是[链路层](https://baike.baidu.com/item/%E9%93%BE%E8%B7%AF%E5%B1%82/10624635)协议的一项国际标准，用以实现远程用户间资源共享以及信息交互。HDLC协议用以保证传送到下一层的数据在传输过程中能够准确地被接收，也就是差错释放中没有任何损失，并且序列正确。HDLC协议的另一个重要功能是流量控制，即一旦接收端收到数据，便能立即进行传输。

HDLC协议由ISO/IEC13239定义，于2002年修订，2007年再次讨论后定稿。在通信领域中，HDLC协议应用非常广泛，其工作方式可以支持[半双工](https://baike.baidu.com/item/%E5%8D%8A%E5%8F%8C%E5%B7%A5)、[全双工](https://baike.baidu.com/item/%E5%85%A8%E5%8F%8C%E5%B7%A5)传送，支持点到点、多点结构，支持交换型、非交换型[信道](https://baike.baidu.com/item/%E4%BF%A1%E9%81%93)。 [1]

**PPPoE**（英语：**P**oint-to-**P**oint **P**rotocol **o**ver **E**thernet），[以太网](https://zh.m.wikipedia.org/wiki/%E4%BB%A5%E5%A4%AA%E7%BD%91)上的点对点协议，是将[点对点协议](https://zh.m.wikipedia.org/wiki/%E7%82%B9%E5%AF%B9%E7%82%B9%E5%8D%8F%E8%AE%AE)（PPP）封装在[以太网](https://zh.m.wikipedia.org/wiki/%E4%BB%A5%E5%A4%AA%E7%BD%91)（Ethernet）框架中的一种网络隧道协议。由于协议中集成PPP协议，所以实现出传统[以太网](https://zh.m.wikipedia.org/wiki/%E4%BB%A5%E5%A4%AA%E7%BD%91)不能提供的[身份验证](https://zh.m.wikipedia.org/wiki/%E8%BA%AB%E4%BB%BD%E9%AA%8C%E8%AF%81)、[加密](https://zh.m.wikipedia.org/wiki/%E5%8A%A0%E5%AF%86)以及[压缩](https://zh.m.wikipedia.org/wiki/%E6%95%B0%E6%8D%AE%E5%8E%8B%E7%BC%A9)等功能，也可用于[缆线数据机](https://zh.m.wikipedia.org/wiki/%E7%BA%9C%E7%B7%9A%E6%95%B8%E6%93%9A%E6%A9%9F)（cable modem）和[数位用户线路](https://zh.m.wikipedia.org/wiki/%E6%95%B8%E4%BD%8D%E7%94%A8%E6%88%B6%E7%B7%9A%E8%B7%AF)（DSL）等以[以太网](https://zh.m.wikipedia.org/wiki/%E4%BB%A5%E5%A4%AA%E7%BD%91)协议向用户提供[接入服务](https://zh.m.wikipedia.org/wiki/%E7%B6%B2%E8%B7%AF%E5%AD%98%E5%8F%96)的协议体系。 本质上，它是一个允许在以太网[广播域](https://zh.m.wikipedia.org/wiki/%E5%B9%BF%E6%92%AD%E5%9F%9F)中的两个以太网接口间建立点对点隧道的协议。

**PPPoE的特点**

PPPoE具有以下特点：

功能上：

1.  PPPoE由于集成了PPP协议，实现了传统以太网不能提供的身份验证、加密以及压缩等功能。
2.  PPPoE通过唯一的Session ID可以很好的保障用户的安全性。

应用上：

1.  PPPoE拨号上网作为一种最常见的方式让终端设备能够连接ISP从而实现宽带接入。
2.  PPPoE可用于缆线调制解调器（Cable Modem）和数字用户线路（DSL）等以太网线，通过以太网协议向用户提供接入服务的协议体系。

总而言之，PPPoE技术将以太网技术的经济性与PPP协议的可管理控制性结合在一起，提供接入互联网的功能。对于运营商来说，它能够最大限度地利用电信接入网现有的体系结构，利用现有的拨号网络资源，运营和管理的模式也不需要很大的改变；对于用户来说，使用感与原来的拨号上网没有太大区别，较容易接受。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/20220621100135.png)


**隧道接通运营商**

BAS 除了作为用户认证的窗口之外，还可以使用隧道方式来传输网络包，所谓的隧道就像是TCP的连接一样，数据从一方可以直接发往另一方，在互联网传输则是用户端直接接入到运营商。

实现隧道的方式比较多，比较常见的方式有下面几种：

-   使用TCP的方式，需要依赖两端的隧道路由器进行TCP连接操作，然后网络包数据传输就变为TCP连接传输数据一样简单。
-   还有一种常见的方式是把包含头部在内的整个网络报包装到另一个包里面，其实说白了还是再包一层。
![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/20220621100242.png)


**接入网的工作流程**

ADSL接入网的工作重点包含下面几个部分：

-   互联网接入路由器通过 PPPoE 的发现机制查询 BAS 的 MAC 地址。
-   BAS 下发的 TCP/IP 参数会被配置到互联网接入路由器的 BAS端的端口上，这样路由器就完成接入互联网的准备了。

	 用户认证和配置下发，这两个重点第一点是保证用户路由器安全连接互联网，另一点是让BAS端可以认识用户，同时需要给路由器分配公网地址和默认网关：
    -   CHAP：对于密码进行加密，相对安全。
    -   PAP：不加密裸连方式，在ASDL的连接方式中容易被窃取，光纤传输就没这个问题。但是不推荐这样的加密方式
-   路由器会选择默认路由，按照默认路由的网关地址转发，BAS告诉请求方路由器的这个地址怎么来的，注意这里包转发规则按照 **PPPoE** 规则转发。
-   BAS 在收到用户路由器发送的网络包之后，会去掉 MAC 头部和PPPoE 头部，然后用隧道机制将包发送给网络运营商的路由器。然后用隧道机制将包发送给网络运营商的路由器

**一对一连接**

互联网接入过程不一定需要头部，如果可以确定是两个路由器点对点一对一的连接，为了保证公网IP的可用性，BAS可以不分配IP地址链接给路由器，这种方式被叫做无编号。

看起来不分配IP的方式挺玄乎，实际上它只是不使用自己的IP而是“借用”另一端口的IP为自己所用。同时这种连接方式是有限制的。使用无端口的模式限制如下：
-   接口必须点对点连接
-   串口两端借出的局域网接口满足下面条件：
    -   相同主网的不同子网掩码必须相同
    -   不同主网缺省掩码

**私有地址转公有地址**

之前说过路由器和BAS的连接必须要由BAS提供公网IP，但是实际上路由器在转发网络包的时候其实还需要做一步地址转化的操作。

如果把公有地址分配给路由器，那么计算机应用程序发送请求就必须把私有的地址转为公有地址传给BAS，这样BAS才能识别请求。

那么公网地址和IP可以分配给路由器，自然也可以分配给计算机，所以如果使用原始的上网方式不使用路由器上网则计算机直接获得IP。

**PPPoA**

PPPoA和PPPo E的主要区别在发送网络包的头部处理的时候，**PPPoA ** 不需要添加MAC头部和PPPoE 头部，而是直接把包装入信元当中。但是因为PPPoA 的限制，使得计算机和路由器必须要和`ADSL Modem`一体，这里就涉及一体化的操作，具体的一体化方式有下面两种：

-   第一种是`ADSL Modem`和USB接口连接起来，但是最终没有普及
-   第二种方式是`ADSL Modem` 和路由器整合为一台设备，实际上就是PPPoE 直接使用路由器上网。所以第二种方式获得广泛普及。

PPPoA和PPPoE的其他区别体现在MTU的大小上，因为PPPoE多出了PPPoE和PPP头部，这样传输数据的实际网络包的部分就是缩小，而PPPoA就没有这个问题。

但是可以看到无论是**PPPoA**还是**PPPoE**，多少都有这样那样的限制，所以有一些运营商使用DHCP的方式通过BAS向用户下发TCP/IP 信息。

**DHCP**的连接方式非常简单粗暴，不需要PPP繁琐的验证或者添加头部的操作等，所以MTU的不需要额外的头部占用空间。

> **DHCP是什么？**
> **动态主机设置协议**（英语：**D**ynamic **H**ost **C**onfiguration **P**rotocol，缩写：**DHCP**），又称**动态主机组态协定**，是一个用于[IP](https://zh.wikipedia.org/wiki/%E7%BD%91%E9%99%85%E5%8D%8F%E8%AE%AE "网际协议")网络的[网络协议](https://zh.wikipedia.org/wiki/%E7%BD%91%E7%BB%9C%E5%8D%8F%E8%AE%AE "网络协议")，位于[OSI模型](https://zh.wikipedia.org/wiki/OSI%E6%A8%A1%E5%9E%8B "OSI模型")的[应用层](https://zh.wikipedia.org/wiki/%E5%BA%94%E7%94%A8%E5%B1%82 "应用层")，使用[UDP](https://zh.wikipedia.org/wiki/%E7%94%A8%E6%88%B7%E6%95%B0%E6%8D%AE%E6%8A%A5%E5%8D%8F%E8%AE%AE "用户数据报协议")协议工作，主要有两个用途：

-   用于内部网或网络服务供应商自动分配[IP地址](https://zh.wikipedia.org/wiki/IP%E5%9C%B0%E5%9D%80 "IP地址")给用户
-   用于内部网管理员对所有电脑作中央管理

注意这个协议不要和[HDCP](https://zh.wikipedia.org/wiki/HDCP "HDCP") 弄混了。

> 注意：PPPoA 不能用于 FTTH，因为 FTTH 不使用 ATM 信元。

# 网络运营商内部处理

通过FTTH和ADSL接入网之后，用户就与签约的运营商连接上了，这时候互联网的入口被称作**POP**。那么网络运营商是如何组织的？在国内毫无疑问就是三大家移联电三家三分天下，但是在国外情况不太一样，运营商之间是互相连接并且运营商是非常多的。

POP接入的方式在上面的传输过程图中基本上介绍的差不多了，这里进行总结一下，主要有四种：

-   专线接入：指的是路由器具备通信线路端口的一般路由器。
-   拨号连接：使用路由器为RSA，因为需要对用户拨电话进行应答，而RSA刚好有这样的功能。
-   PPPoE接入：身份认证和配置下发需要BAS负责，运营商只做转发包的操作。
-   PPPoA接入：DSLAM 通过 ATM 交换机 B与 ADSL 的运营商的 BAS 相 连， 然后再连接到运营商的路由器。

![](https://adong-picture.oss-cn-shenzhen.aliyuncs.com/adong/202206202200528.png)

但是众多的POP要如何和运营商进行交互呢？这里就需要提到NOC的概念。

**NOC**： Network Operation Center，网络运行中心。NOC是网络运营商的核心，可以抽象的看作一个非常高性能的支持非常非常多用户连接的高吞吐路由器，可以看作一个超大号的接入网。

在POP接入NOC之后，NOC之间通常也有线路连接，用户的网络请求会转发到距离目的地最近的运营商，找到对应的NOC之后再进行输出。

**运营商之间连接**

如果接入方和目的地属于相同的网络运营商，那么POP 路由器的路由表中应该有相应的转发目标，直接转发到对应的WEB服务器所在的POP路由器即可。

但是更多情况是跨运营商之间的访问，实际上同样可以通过路由表查到，只不过路由的路径要比同一个运营商要久一些，通过路由的转发，网络包就可以送往地球的任何一个地方。

运营商之间同样需要路由表的交换，互联网内部使用 **BGP 机制**在运营商之间交换路由信息，路由信息的传输有三种形式，分别是对等，转接和直连，对等是直接的物理连接，但是需要两个运营商之间接一根线，转接需要把全部路由信息给对方。

转接类似使用代理，委托第三方的运营商和对方进行互连，而直连方式就很简单了，就是直接在双方搭一根专线，只有这根线的两端可以互相通信，外部运营商不可借用和看到。

# 小结

本部分更建议加深对鱼 **传输过程图**的印象，里面把整个ADSL上网通信流程描绘的非常细致，在细节上有较多的网络硬件的知识，对于个人这种学软件的人来说比较难啃，这里就当留个印象以后有机会深入的时候在学习吧。（当然几乎用不着）

整个ADSL的接入大致内容介绍完成，当然这里讨论的只是整体的部分，深入各个部分的细节内容会越发的复杂，这部分不是个人学习重点不做过多探究，感兴趣的读者可以根据步骤翻阅相关资料深入了解。