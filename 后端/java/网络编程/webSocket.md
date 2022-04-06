# WebSocket使用
[TOC]

## websocket介绍：

​			WebSocket协议是基于TCP的一种新的网络协议。它实现了浏览器与服务器全双工(full-duplex)通信——允许服务器主动发送信息给客户端



Websocket 使用 ws 或 wss 的统一资源标志符，类似于 HTTPS，其中 wss 表示在 TLS 之上的 Websocket。如：

```
ws://example.com/wsapi
wss://secure.example.com/
```

Websocket 使用和 HTTP 相同的 TCP 端口，可以绕过大多数防火墙的限制。默认情况下，Websocket 协议使用 80 端口；运行在 TLS 之上时，默认使用 443 端口。

**一个典型的Websocket握手请求如下：**

客户端请求

```
GET / HTTP/1.1
Upgrade: websocket
Connection: Upgrade
Host: example.com
Origin: http://example.com
Sec-WebSocket-Key: sN9cRrP/n9NdMgdcy2VJFQ==
Sec-WebSocket-Version: 13
```

服务器回应

```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: fFBooB7FAkLlXgRSz0BT3v4hq5s=
Sec-WebSocket-Location: ws://example.com/
```

-  Connection 必须设置 Upgrade，表示客户端希望连接升级。
-  Upgrade 字段必须设置 Websocket，表示希望升级到 Websocket 协议。
-  Sec-WebSocket-Key 是随机的字符串，服务器端会用这些数据来构造出一个 SHA-1 的信息摘要。把 “Sec-WebSocket-Key” 加上一个特殊字符串 “258EAFA5-E914-47DA-95CA-C5AB0DC85B11”，然后计算 SHA-1 摘要，之后进行 BASE-64 编码，将结果做为 “Sec-WebSocket-Accept” 头的值，返回给客户端。如此操作，可以尽量避免普通 HTTP 请求被误认为 Websocket 协议。
-  Sec-WebSocket-Version 表示支持的 Websocket 版本。RFC6455 要求使用的版本是 13，之前草案的版本均应当弃用。
-  Origin 字段是可选的，通常用来表示在浏览器中发起此 Websocket 连接所在的页面，类似于 Referer。但是，与 Referer 不同的是，Origin 只包含了协议和主机名称。
-  其他一些定义在 HTTP 协议中的字段，如 Cookie 等，也可以在 Websocket 中使用。

在服务器方面，网上都有不同对websocket支持的服务器：

- php - <http://code.google.com/p/phpwebsocket/>
- jetty - [http://jetty.codehaus.org/jetty/（版本7开始支持websocket）](http://jetty.codehaus.org/jetty/%EF%BC%88%E7%89%88%E6%9C%AC7%E5%BC%80%E5%A7%8B%E6%94%AF%E6%8C%81websocket%EF%BC%89)
- netty - <http://www.jboss.org/netty>
- ruby - <http://github.com/gimite/web-socket-ruby>
- Kaazing - <https://web.archive.org/web/20100923224709/http://www.kaazing.org/confluence/display/KAAZING/Home>
- Tomcat - [http://tomcat.apache.org/（7.0.27支持websocket，建议用tomcat8，7.0.27中的接口已经过时）](http://tomcat.apache.org/)
- WebLogic - [http://www.oracle.com/us/products/middleware/cloud-app-foundation/weblogic/overview/index.html（12.1.2開始支持）](http://www.oracle.com/us/products/middleware/cloud-app-foundation/weblogic/overview/index.html)
- node.js - <https://github.com/Worlize/WebSocket-Node>
- node.js - [http://socket.io](http://socket.io/)
- nginx - <http://nginx.com/>
- mojolicious - <http://mojolicio.us/>
- python - <https://github.com/abourget/gevent-socketio>
- Django - <https://github.com/stephenmcd/django-socketio>
- erlang - <https://github.com/ninenines/cowboy.git>



## websocket使用场景分享

​	如弹幕，网页聊天系统，实时监控，股票行情推送等

## 学习课程需要什么基础:

​		javaweb基础, html, js, http协议

# 简单介绍什么是springboot、socketjs、stompjs，及解决使用浏览器兼容问题

## 技术框架基本介绍

### springboot：

```
是什么：
    1、简化新Spring应用的初始搭建以及开发过程
    2、嵌入的Tomcat，无需部署WAR文件
    3、简化Maven配置, 自动配置Spring

学习资料：
	1、官网 https://projects.spring.io/spring-boot
	2、springboot整合websocket资料: https://spring.io/guides/gs/messaging-stomp-websocket/
```

### socketjs：

```
是什么：
    1、是一个浏览器JavaScript库，提供了一个类似WebSocket的对象。
    2、提供了一个连贯的跨浏览器的JavaScriptAPI，在浏览器和Web服务器之间创建了一个低延迟，全双工，跨域的通信通道
    3、在底层SockJS首先尝试使用本地WebSocket。如果失败了，它可以使用各种浏览器特定的传输协议，并通过类似WebSocket的抽象方式呈现它们
    4、SockJS旨在适用于所有现代浏览器和不支持WebSocket协议的环境。
					
学习资料：
	1、git地址：https://github.com/sockjs/sockjs-client
```

### stompjs：

```
是什么：
	1、STOMP Simple (or Streaming) Text Orientated Messaging Protocol
它定义了可互操作的连线格式，以便任何可用的STOMP客户端都可以与任何STOMP消息代理进行通信，以在语言和平台之间提供简单而广泛的消息互操作性（归纳一句话：是一个简单的面向文本的消息传递协议。）
	学习资料:
		https://stomp-js.github.io/stomp-websocket/codo/class/Client.html#connect-dynamic

```



# 广播、单播、组播

## 单播(Unicast):

### 	点对点，私信私聊

## 广播(Broadcast)(所有人):

### 	游戏公告，发布订阅

## 多播，也叫组播(Multicast)（特地人群）:

## 	多人聊天，发布订阅

# springboot简介

springboot框架搭建和maven依赖
​		资料地址:https://spring.io/guides/gs/messaging-stomp-websocket/

# webjars		

1、方便统一管理

2、主要解决前端框架版本不一致，文件混乱等问题

3、把前端资源，打包成jar包，借助maven工具进行管理

# websocket 流程图解

![画板](D:\java\自学笔记\websocket\websocket资料\笔记源码\07.第七节课资料\画板.jpeg)



# websocket推送两种推送方法的区别

1、SendTo 不通用，固定发送给指定的订阅者

2、SimpMessagingTemplate 灵活，支持多种发送方式

## 示例代码







# Springboot针对websocket 4类的监听器

## 注意点：

1、需要监听器类需要实现接口ApplicationListener<T> T表示事件类型，下列几种都是对应的websocket事件类型

2、在监听器类上注解 @Component，spring会把改类纳入管理

	websocket模块监听器类型：
	    SessionSubscribeEvent 	订阅事件
	    SessionUnsubscribeEvent	取消订阅事件
	    SessionDisconnectEvent 	断开连接事件
	    SessionDisconnectEvent 	建立连接事件
