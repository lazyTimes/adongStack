
<map>
  <node ID="root" TEXT="重学mysql">
    <node TEXT="重新认识mysql" ID="6pytefxP97" _mubu_text="%3Cspan%3E%E9%87%8D%E6%96%B0%E8%AE%A4%E8%AF%86mysql%3C/span%3E" STYLE="bubble" POSITION="right">
      <node TEXT="什么是客户端和服务端" ID="3S44jcG4AB" _mubu_text="%3Cspan%3E%E4%BB%80%E4%B9%88%E6%98%AF%E5%AE%A2%E6%88%B7%E7%AB%AF%E5%92%8C%E6%9C%8D%E5%8A%A1%E7%AB%AF%3C/span%3E" STYLE="fork">
        <node TEXT="客户端：连接的一方，主要为发送请求，也被称之为发送方" ID="BlLL1N9epE" _mubu_text="%3Cspan%3E%E5%AE%A2%E6%88%B7%E7%AB%AF%EF%BC%9A%E8%BF%9E%E6%8E%A5%E7%9A%84%E4%B8%80%E6%96%B9%EF%BC%8C%E4%B8%BB%E8%A6%81%E4%B8%BA%E5%8F%91%E9%80%81%E8%AF%B7%E6%B1%82%EF%BC%8C%E4%B9%9F%E8%A2%AB%E7%A7%B0%E4%B9%8B%E4%B8%BA%E5%8F%91%E9%80%81%E6%96%B9%3C/span%3E" STYLE="fork"/>
        <node TEXT="服务端：接受请求的一方，负责接受请求转化命令查询数据返回给客户端，也被称之为接收方" ID="nUplY9dLT3" _mubu_text="%3Cspan%3E%E6%9C%8D%E5%8A%A1%E7%AB%AF%EF%BC%9A%E6%8E%A5%E5%8F%97%E8%AF%B7%E6%B1%82%E7%9A%84%E4%B8%80%E6%96%B9%EF%BC%8C%E8%B4%9F%E8%B4%A3%E6%8E%A5%E5%8F%97%E8%AF%B7%E6%B1%82%E8%BD%AC%E5%8C%96%E5%91%BD%E4%BB%A4%E6%9F%A5%E8%AF%A2%E6%95%B0%E6%8D%AE%E8%BF%94%E5%9B%9E%E7%BB%99%E5%AE%A2%E6%88%B7%E7%AB%AF%EF%BC%8C%E4%B9%9F%E8%A2%AB%E7%A7%B0%E4%B9%8B%E4%B8%BA%E6%8E%A5%E6%94%B6%E6%96%B9%3C/span%3E" STYLE="fork"/>
      </node>
      <node TEXT="mysql基本任务" ID="yjPkOwlLWd" _mubu_text="%3Cspan%3Emysql%E5%9F%BA%E6%9C%AC%E4%BB%BB%E5%8A%A1%3C/span%3E" STYLE="fork">
        <node TEXT="连接数据库。" ID="wJQuy8XrGZ" _mubu_text="%3Cspan%3E%E8%BF%9E%E6%8E%A5%E6%95%B0%E6%8D%AE%E5%BA%93%E3%80%82%3C/span%3E" STYLE="fork"/>
        <node TEXT="查询数据库的数据，客户端发送请求给服务端，服务端根据命令找到数据回送给客户端。" ID="EqkcId0Nq7" _mubu_text="%3Cspan%3E%E6%9F%A5%E8%AF%A2%E6%95%B0%E6%8D%AE%E5%BA%93%E7%9A%84%E6%95%B0%E6%8D%AE%EF%BC%8C%E5%AE%A2%E6%88%B7%E7%AB%AF%E5%8F%91%E9%80%81%E8%AF%B7%E6%B1%82%E7%BB%99%E6%9C%8D%E5%8A%A1%E7%AB%AF%EF%BC%8C%E6%9C%8D%E5%8A%A1%E7%AB%AF%E6%A0%B9%E6%8D%AE%E5%91%BD%E4%BB%A4%E6%89%BE%E5%88%B0%E6%95%B0%E6%8D%AE%E5%9B%9E%E9%80%81%E7%BB%99%E5%AE%A2%E6%88%B7%E7%AB%AF%E3%80%82%3C/span%3E" STYLE="fork"/>
        <node TEXT="和数据库断开连接。" ID="azWWFl3uib" _mubu_text="%3Cspan%3E%E5%92%8C%E6%95%B0%E6%8D%AE%E5%BA%93%E6%96%AD%E5%BC%80%E8%BF%9E%E6%8E%A5%E3%80%82%3C/span%3E" STYLE="fork"/>
      </node>
      <node TEXT="mysql实例" ID="fmm7s64FF1" _mubu_text="%3Cspan%3Emysql%E5%AE%9E%E4%BE%8B%3C/span%3E" STYLE="fork">
        <node TEXT="进程" ID="ZqQwNqpJ0g" _mubu_text="%3Cspan%3E%E8%BF%9B%E7%A8%8B%3C/span%3E" STYLE="fork">
          <node TEXT="处理器/内存/IO设备的统称，主要被操作系统进行抽象和掩藏底层细节" ID="IjxaunT6oK" _mubu_text="%3Cspan%3E%E5%A4%84%E7%90%86%E5%99%A8/%E5%86%85%E5%AD%98/IO%E8%AE%BE%E5%A4%87%E7%9A%84%E7%BB%9F%E7%A7%B0%EF%BC%8C%E4%B8%BB%E8%A6%81%E8%A2%AB%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E8%BF%9B%E8%A1%8C%E6%8A%BD%E8%B1%A1%E5%92%8C%E6%8E%A9%E8%97%8F%E5%BA%95%E5%B1%82%E7%BB%86%E8%8A%82%3C/span%3E" STYLE="fork"/>
        </node>
        <node TEXT="端口" ID="OYJcEuwnxB" _mubu_text="%3Cspan%3E%E7%AB%AF%E5%8F%A3%3C/span%3E" STYLE="fork">
          <node TEXT="默认3306" ID="zNImA1HHQN" _mubu_text="%3Cspan%3E%E9%BB%98%E8%AE%A43306%3C/span%3E" STYLE="fork"/>
        </node>
        <node TEXT="实例名称" ID="Ub8OksdvMu" _mubu_text="%3Cspan%3E%E5%AE%9E%E4%BE%8B%E5%90%8D%E7%A7%B0%3C/span%3E" STYLE="fork">
          <node TEXT="服务端" ID="ekGbVyjYm1" _mubu_text="%3Cspan%3E%E6%9C%8D%E5%8A%A1%E7%AB%AF%3C/span%3E" STYLE="fork"/>
        </node>
      </node>
      <node TEXT="安装Mysql的注意事项" ID="xhzRjZHJyA" _mubu_text="%3Cspan%3E%E5%AE%89%E8%A3%85Mysql%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9%3C/span%3E" STYLE="fork">
        <node TEXT="安装目录位置的区别" ID="qw875tQoKs" _mubu_text="%3Cspan%3E%E5%AE%89%E8%A3%85%E7%9B%AE%E5%BD%95%E4%BD%8D%E7%BD%AE%E7%9A%84%E5%8C%BA%E5%88%AB%3C/span%3E" STYLE="fork">
          <node TEXT="macOS 操作系统上的安装目录：" ID="8xGLRZDJKC" _mubu_text="%3Cspan%3EmacOS%20%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E4%B8%8A%E7%9A%84%E5%AE%89%E8%A3%85%E7%9B%AE%E5%BD%95%EF%BC%9A%3C/span%3E" STYLE="fork">
            <node TEXT="/usr/local/mysql/" ID="kE11h8n3uW" _mubu_text="%3Cspan%3E/usr/local/mysql/%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="Windows 操作系统上的安装目录：" ID="sZF7IDyd1H" _mubu_text="%3Cspan%3EWindows%20%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E4%B8%8A%E7%9A%84%E5%AE%89%E8%A3%85%E7%9B%AE%E5%BD%95%EF%BC%9A%3C/span%3E" STYLE="fork">
            <node TEXT="C:\Program Files\MySQL\MySQL Server 5.7" ID="Ul0iQNnBP9" _mubu_text="%3Cspan%3EC:%5CProgram%20Files%5CMySQL%5CMySQL%20Server%205.7%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="注意事项" ID="nGnS9S2fie" _mubu_text="%3Cspan%3E%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9%3C/span%3E" STYLE="fork">
          <node TEXT="1. 尽可能使用源代码操作并且在linux系统实验" ID="IauZ74IjIw" _mubu_text="%3Cspan%3E1.%20%E5%B0%BD%E5%8F%AF%E8%83%BD%E4%BD%BF%E7%94%A8%E6%BA%90%E4%BB%A3%E7%A0%81%E6%93%8D%E4%BD%9C%E5%B9%B6%E4%B8%94%E5%9C%A8linux%E7%B3%BB%E7%BB%9F%E5%AE%9E%E9%AA%8C%3C/span%3E" STYLE="fork"/>
          <node TEXT="2. Linux下使用RPM包会有单独的服务器和客户端RPM包，需要分别安装" ID="FqNqAM6G8I" _mubu_text="%3Cspan%3E2.%20%3C/span%3E%3Cspan%20class=%22bold%22%3ELinux%E4%B8%8B%E4%BD%BF%E7%94%A8RPM%E5%8C%85%E4%BC%9A%E6%9C%89%E5%8D%95%E7%8B%AC%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%92%8C%E5%AE%A2%E6%88%B7%E7%AB%AFRPM%E5%8C%85%EF%BC%8C%E9%9C%80%E8%A6%81%E5%88%86%E5%88%AB%E5%AE%89%E8%A3%85%3C/span%3E" STYLE="fork"/>
        </node>
      </node>
      <node TEXT="Mysql安装" ID="gY614AGC2E" _mubu_text="%3Cspan%3EMysql%E5%AE%89%E8%A3%85%3C/span%3E" STYLE="fork">
        <node TEXT="windwos安装有可能存在找不到命令的情况，这时候建议查看一下服务是否存在并且启动并配置环境变量" ID="I82wqGDAcX" _mubu_text="%3Cspan%3Ewindwos%E5%AE%89%E8%A3%85%E6%9C%89%E5%8F%AF%E8%83%BD%E5%AD%98%E5%9C%A8%E6%89%BE%E4%B8%8D%E5%88%B0%E5%91%BD%E4%BB%A4%E7%9A%84%E6%83%85%E5%86%B5%EF%BC%8C%E8%BF%99%E6%97%B6%E5%80%99%E5%BB%BA%E8%AE%AE%E6%9F%A5%E7%9C%8B%E4%B8%80%E4%B8%8B%E6%9C%8D%E5%8A%A1%E6%98%AF%E5%90%A6%E5%AD%98%E5%9C%A8%E5%B9%B6%E4%B8%94%E5%90%AF%E5%8A%A8%E5%B9%B6%E9%85%8D%E7%BD%AE%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork"/>
        <node TEXT="macos个人使用m1芯片，直接使用brew install mysql即可" ID="YatEvtX1Eb" _mubu_text="%3Cspan%3Emacos%E4%B8%AA%E4%BA%BA%E4%BD%BF%E7%94%A8m1%E8%8A%AF%E7%89%87%EF%BC%8C%E7%9B%B4%E6%8E%A5%E4%BD%BF%E7%94%A8brew%20install%20mysql%E5%8D%B3%E5%8F%AF%3C/span%3E" STYLE="fork">
          <node TEXT="参考帖子：https://www.cnblogs.com/nickchen121/p/11145123.html" ID="C3YHnzIt7W" _mubu_text="%3Cspan%3E%E5%8F%82%E8%80%83%E5%B8%96%E5%AD%90%EF%BC%9A%3C/span%3E%3Ca%20class=%22content-link%22%20target=%22_blank%22%20spellcheck=%22false%22%20rel=%22noreferrer%22%20href=%22https://www.cnblogs.com/nickchen121/p/11145123.html%22%3E%3Cspan%20class=%22content-link-text%22%3Ehttps://www.cnblogs.com/nickchen121/p/11145123.html%3C/span%3E%3C/a%3E" STYLE="fork"/>
        </node>
        <node TEXT="linux安装如果使用rpm安装方式可以参考此链接" ID="RDoJSb7cvd" _mubu_text="%3Cspan%3Elinux%E5%AE%89%E8%A3%85%E5%A6%82%E6%9E%9C%E4%BD%BF%E7%94%A8rpm%E5%AE%89%E8%A3%85%E6%96%B9%E5%BC%8F%E5%8F%AF%E4%BB%A5%E5%8F%82%E8%80%83%E6%AD%A4%E9%93%BE%E6%8E%A5%3C/span%3E" STYLE="fork">
          <node TEXT="阿里云centeros7使用rpm" ID="w6jtxUx5Fo" _mubu_text="%3Cspan%3E%E9%98%BF%E9%87%8C%E4%BA%91centeros7%E4%BD%BF%E7%94%A8rpm%3C/span%3E" STYLE="fork">
            <node TEXT="https://juejin.cn/post/6895255541544255496" ID="UdLVBx1dTl" _mubu_text="%3Ca%20class=%22content-link%22%20target=%22_blank%22%20spellcheck=%22false%22%20rel=%22noreferrer%22%20href=%22https://juejin.cn/post/6895255541544255496%22%3E%3Cspan%20class=%22content-link-text%22%3Ehttps://juejin.cn/post/6895255541544255496%3C/span%3E%3C/a%3E" STYLE="fork"/>
          </node>
        </node>
      </node>
      <node TEXT="Mysql启动" ID="Mr65jJjEY0" _mubu_text="%3Cspan%3EMysql%E5%90%AF%E5%8A%A8%3C/span%3E" STYLE="fork">
        <node TEXT="mysqld" ID="xD753EOPVR" _mubu_text="%3Cspan%3Emysqld%3C/span%3E" STYLE="fork">
          <node TEXT="代表的是mysql的服务器程序，运行就可以启动一个服务器的进程，但是不常用。" ID="fXt6MsAqhT" _mubu_text="%3Cspan%3E%E4%BB%A3%E8%A1%A8%E7%9A%84%E6%98%AFmysql%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%A8%8B%E5%BA%8F%EF%BC%8C%E8%BF%90%E8%A1%8C%E5%B0%B1%E5%8F%AF%E4%BB%A5%E5%90%AF%E5%8A%A8%E4%B8%80%E4%B8%AA%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E8%BF%9B%E7%A8%8B%EF%BC%8C%E4%BD%86%E6%98%AF%3C/span%3E%3Cspan%20class=%22bold%22%3E%E4%B8%8D%E5%B8%B8%E7%94%A8%3C/span%3E%3Cspan%3E%E3%80%82%3C/span%3E" STYLE="fork"/>
        </node>
        <node TEXT="mysqld_safe" ID="c0VjIVq9D8" _mubu_text="%3Cspan%3Emysqld_safe%3C/span%3E" STYLE="fork">
          <node TEXT="mysqld_safe 是一个启动脚本，在间接的调用mysqld ，同时监控进程，使用 mysqld_safe 启动服务器程序时，会通过监控把出错的内容和出错的信息重定向到一某个文件里面产生出错日志，这样可以方便我们找出发生错误的原因。" ID="SBTLKPm9ZC" _mubu_text="%3Cspan%20class=%22bold%22%3Emysqld_safe%3C/span%3E%3Cspan%3E%20%E6%98%AF%E4%B8%80%E4%B8%AA%E5%90%AF%E5%8A%A8%E8%84%9A%E6%9C%AC%EF%BC%8C%E5%9C%A8%E9%97%B4%E6%8E%A5%E7%9A%84%E8%B0%83%E7%94%A8%3C/span%3E%3Cspan%20class=%22bold%22%3Emysqld%3C/span%3E%3Cspan%3E%20%EF%BC%8C%E5%90%8C%E6%97%B6%3C/span%3E%3Cspan%20class=%22bold%22%3E%E7%9B%91%E6%8E%A7%E8%BF%9B%E7%A8%8B%3C/span%3E%3Cspan%3E%EF%BC%8C%E4%BD%BF%E7%94%A8%20mysqld_safe%20%E5%90%AF%E5%8A%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%A8%8B%E5%BA%8F%E6%97%B6%EF%BC%8C%E4%BC%9A%E9%80%9A%E8%BF%87%E7%9B%91%E6%8E%A7%E6%8A%8A%E5%87%BA%E9%94%99%E7%9A%84%E5%86%85%E5%AE%B9%E5%92%8C%E5%87%BA%E9%94%99%E7%9A%84%E4%BF%A1%E6%81%AF%E9%87%8D%E5%AE%9A%E5%90%91%E5%88%B0%E4%B8%80%E6%9F%90%E4%B8%AA%E6%96%87%E4%BB%B6%E9%87%8C%E9%9D%A2%E4%BA%A7%E7%94%9F%E5%87%BA%E9%94%99%E6%97%A5%E5%BF%97%EF%BC%8C%E8%BF%99%E6%A0%B7%E5%8F%AF%E4%BB%A5%E6%96%B9%E4%BE%BF%E6%88%91%E4%BB%AC%E6%89%BE%E5%87%BA%E5%8F%91%E7%94%9F%E9%94%99%E8%AF%AF%E7%9A%84%E5%8E%9F%E5%9B%A0%E3%80%82%3C/span%3E" STYLE="fork"/>
        </node>
        <node TEXT="mysql.server" ID="BZUm6EoHJO" _mubu_text="%3Cspan%3Emysql.server%3C/span%3E" STYLE="fork">
          <node TEXT="实际上这个命令可以看做是一个链接，也就是一个“快捷方式”，实际指向的路径为： ../support-files/mysql.server，另外这个命令会间接的调用mysqld_safe" ID="sXSrp8bROH" _mubu_text="%3Cspan%3E%E5%AE%9E%E9%99%85%E4%B8%8A%E8%BF%99%E4%B8%AA%E5%91%BD%E4%BB%A4%E5%8F%AF%E4%BB%A5%E7%9C%8B%E5%81%9A%E6%98%AF%E4%B8%80%E4%B8%AA%E9%93%BE%E6%8E%A5%EF%BC%8C%E4%B9%9F%E5%B0%B1%E6%98%AF%E4%B8%80%E4%B8%AA%E2%80%9C%E5%BF%AB%E6%8D%B7%E6%96%B9%E5%BC%8F%E2%80%9D%EF%BC%8C%E5%AE%9E%E9%99%85%E6%8C%87%E5%90%91%E7%9A%84%E8%B7%AF%E5%BE%84%E4%B8%BA%EF%BC%9A%20../support-files/mysql.server%EF%BC%8C%E5%8F%A6%E5%A4%96%E8%BF%99%E4%B8%AA%3C/span%3E%3Cspan%20class=%22bold%22%3E%E5%91%BD%E4%BB%A4%E4%BC%9A%E9%97%B4%E6%8E%A5%E7%9A%84%E8%B0%83%E7%94%A8mysqld_safe%3C/span%3E" STYLE="fork"/>
        </node>
        <node TEXT="mysqld_multi" ID="Qu5cWPXnl2" _mubu_text="%3Cspan%3Emysqld_multi%3C/span%3E" STYLE="fork">
          <node TEXT="这个命令的作用是对于每一个服务器进程进行启动或者停止监控，但是由于这个命令较为复杂" ID="1pDMV9zW7a" _mubu_text="%3Cspan%3E%E8%BF%99%E4%B8%AA%E5%91%BD%E4%BB%A4%E7%9A%84%E4%BD%9C%E7%94%A8%E6%98%AF%E5%AF%B9%E4%BA%8E%E6%AF%8F%E4%B8%80%E4%B8%AA%E6%9C%8D%E5%8A%A1%E5%99%A8%E8%BF%9B%E7%A8%8B%E8%BF%9B%E8%A1%8C%E5%90%AF%E5%8A%A8%E6%88%96%E8%80%85%E5%81%9C%E6%AD%A2%E7%9B%91%E6%8E%A7%EF%BC%8C%E4%BD%86%E6%98%AF%E7%94%B1%E4%BA%8E%E8%BF%99%E4%B8%AA%E5%91%BD%E4%BB%A4%E8%BE%83%E4%B8%BA%E5%A4%8D%E6%9D%82%3C/span%3E" STYLE="fork"/>
        </node>
        <node TEXT="注意事项" ID="CQKKAVw3k4" _mubu_text="%3Cspan%3E%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9%3C/span%3E" STYLE="fork">
          <node TEXT="1. mysql.server在部分操作系统并不会直接生成，需要进行手动的生成操作" ID="qZEkd4jlNj" _mubu_text="%3Cspan%3E1.%20mysql.server%E5%9C%A8%E9%83%A8%E5%88%86%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E5%B9%B6%E4%B8%8D%E4%BC%9A%E7%9B%B4%E6%8E%A5%E7%94%9F%E6%88%90%EF%BC%8C%E9%9C%80%E8%A6%81%E8%BF%9B%E8%A1%8C%E6%89%8B%E5%8A%A8%E7%9A%84%E7%94%9F%E6%88%90%E6%93%8D%E4%BD%9C%3C/span%3E" STYLE="fork"/>
          <node TEXT="2. mysqld_multi 更加建议参考官方文档" ID="HxO4EQ3Q7a" _mubu_text="%3Cspan%3E2.%20mysqld_multi%20%E6%9B%B4%E5%8A%A0%E5%BB%BA%E8%AE%AE%E5%8F%82%E8%80%83%E5%AE%98%E6%96%B9%E6%96%87%E6%A1%A3%3C/span%3E" STYLE="fork"/>
        </node>
      </node>
      <node TEXT="Mysql连接" ID="5QNRAonrNh" _mubu_text="%3Cspan%3EMysql%E8%BF%9E%E6%8E%A5%3C/span%3E" STYLE="fork">
        <node TEXT="连接方式" ID="relzL2Sc9g" _mubu_text="%3Cspan%3E%E8%BF%9E%E6%8E%A5%E6%96%B9%E5%BC%8F%3C/span%3E" STYLE="fork">
          <node TEXT="TCP/IP" ID="RSZJArjuuX" _mubu_text="%3Cspan%3ETCP/IP%3C/span%3E" STYLE="fork">
            <node TEXT="IP地址" ID="KcMLYmirrm" _mubu_text="%3Cspan%3EIP%E5%9C%B0%E5%9D%80%3C/span%3E" STYLE="fork">
              <node TEXT="例如：127.0.0.1" ID="qqKXWKsYJt" _mubu_text="%3Cspan%3E%E4%BE%8B%E5%A6%82%EF%BC%9A127.0.0.1%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="端口号" ID="NJrcwK11yY" _mubu_text="%3Cspan%3E%E7%AB%AF%E5%8F%A3%E5%8F%B7%3C/span%3E" STYLE="fork">
              <node TEXT="默认：3306" ID="p6lO14m1vx" _mubu_text="%3Cspan%3E%E9%BB%98%E8%AE%A4%EF%BC%9A3306%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="命名管道和共享内存（忘记）" ID="ovNRTuUte7" _mubu_text="%3Cspan%3E%E5%91%BD%E5%90%8D%E7%AE%A1%E9%81%93%E5%92%8C%E5%85%B1%E4%BA%AB%E5%86%85%E5%AD%98%EF%BC%88%E5%BF%98%E8%AE%B0%EF%BC%89%3C/span%3E" STYLE="fork">
            <node TEXT="针对Windows用户的特殊方式" ID="FsdLIhTRCP" _mubu_text="%3Cspan%3E%E9%92%88%E5%AF%B9Windows%E7%94%A8%E6%88%B7%E7%9A%84%E7%89%B9%E6%AE%8A%E6%96%B9%E5%BC%8F%3C/span%3E" STYLE="fork"/>
            <node TEXT="可以完全忘记" ID="YrhF8OXPfm" _mubu_text="%3Cspan%3E%E5%8F%AF%E4%BB%A5%E5%AE%8C%E5%85%A8%E5%BF%98%E8%AE%B0%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="Unix套接字" ID="nb3pyCZsyS" _mubu_text="%3Cspan%3EUnix%E5%A5%97%E6%8E%A5%E5%AD%97%3C/span%3E" STYLE="fork">
            <node TEXT="服务端修改监听文件客户端访问需要使用--socket进行切换" ID="5C6EyVCqyG" _mubu_text="%3Cspan%3E%E6%9C%8D%E5%8A%A1%E7%AB%AF%E4%BF%AE%E6%94%B9%E7%9B%91%E5%90%AC%E6%96%87%E4%BB%B6%E5%AE%A2%E6%88%B7%E7%AB%AF%E8%AE%BF%E9%97%AE%E9%9C%80%E8%A6%81%E4%BD%BF%E7%94%A8--socket%E8%BF%9B%E8%A1%8C%E5%88%87%E6%8D%A2%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="连接过程" ID="W17E03CEev" _mubu_text="%3Cspan%3E%E8%BF%9E%E6%8E%A5%E8%BF%87%E7%A8%8B%3C/span%3E" STYLE="fork">
          <node TEXT="1. 连接管理" ID="k8BAJyLq43" _mubu_text="%3Cspan%3E1.%20%E8%BF%9E%E6%8E%A5%E7%AE%A1%E7%90%86%3C/span%3E" STYLE="fork">
            <node TEXT="负责管理和客户端的交互" ID="2efIu0ljiF" _mubu_text="%3Cspan%3E%E8%B4%9F%E8%B4%A3%E7%AE%A1%E7%90%86%E5%92%8C%E5%AE%A2%E6%88%B7%E7%AB%AF%E7%9A%84%E4%BA%A4%E4%BA%92%3C/span%3E" STYLE="fork"/>
            <node TEXT="通常为线程池，连接过多会造成数据库压力巨大" ID="Dw7So1lbtG" _mubu_text="%3Cspan%3E%E9%80%9A%E5%B8%B8%E4%B8%BA%E7%BA%BF%E7%A8%8B%E6%B1%A0%EF%BC%8C%E8%BF%9E%E6%8E%A5%E8%BF%87%E5%A4%9A%E4%BC%9A%E9%80%A0%E6%88%90%E6%95%B0%E6%8D%AE%E5%BA%93%E5%8E%8B%E5%8A%9B%E5%B7%A8%E5%A4%A7%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="2. 查询优化" ID="BVEYl8BUe5" _mubu_text="%3Cspan%3E2.%20%E6%9F%A5%E8%AF%A2%E4%BC%98%E5%8C%96%3C/span%3E" STYLE="fork">
            <node TEXT="查询缓存" ID="tMCIfG63fS" _mubu_text="%3Cspan%3E%E6%9F%A5%E8%AF%A2%E7%BC%93%E5%AD%98%3C/span%3E" STYLE="fork">
              <node TEXT="缓存失效规则" ID="yTYaHUhZy7" _mubu_text="%3Cspan%3E%E7%BC%93%E5%AD%98%E5%A4%B1%E6%95%88%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork">
                <node TEXT="1. 如果两个查询请求在任何字符上的不同(例如:空格、注释、大小写)，都 会导致缓存不会命中。" ID="pdxfs2cvFO" _mubu_text="%3Cspan%20class=%22bold%22%3E1.%20%E5%A6%82%E6%9E%9C%E4%B8%A4%E4%B8%AA%E6%9F%A5%E8%AF%A2%E8%AF%B7%E6%B1%82%E5%9C%A8%E4%BB%BB%E4%BD%95%E5%AD%97%E7%AC%A6%E4%B8%8A%E7%9A%84%E4%B8%8D%E5%90%8C(%E4%BE%8B%E5%A6%82:%E7%A9%BA%E6%A0%BC%E3%80%81%E6%B3%A8%E9%87%8A%E3%80%81%E5%A4%A7%E5%B0%8F%E5%86%99)%EF%BC%8C%E9%83%BD%20%E4%BC%9A%E5%AF%BC%E8%87%B4%E7%BC%93%E5%AD%98%E4%B8%8D%E4%BC%9A%E5%91%BD%E4%B8%AD%3C/span%3E%3Cspan%3E%E3%80%82%3C/span%3E" STYLE="fork"/>
                <node TEXT="2.  如果使用了部分系统函数，比如now()，sum()等或者使用mysql 、information_schema、 performance_schema等系统表的时候，即使语句和结果一摸一样，也是不走缓存的。" ID="bX8yXdE1hF" _mubu_text="%3Cspan%20class=%22bold%22%3E2.%20%3C/span%3E%3Cspan%3E%20%3C/span%3E%3Cspan%20class=%22bold%22%3E%E5%A6%82%E6%9E%9C%E4%BD%BF%E7%94%A8%E4%BA%86%E9%83%A8%E5%88%86%E7%B3%BB%E7%BB%9F%E5%87%BD%E6%95%B0%EF%BC%8C%E6%AF%94%E5%A6%82now()%EF%BC%8Csum()%E7%AD%89%E6%88%96%E8%80%85%E4%BD%BF%E7%94%A8mysql%20%E3%80%81information_schema%E3%80%81%20performance_schema%E7%AD%89%E7%B3%BB%E7%BB%9F%E8%A1%A8%E7%9A%84%E6%97%B6%E5%80%99%EF%BC%8C%E5%8D%B3%E4%BD%BF%E8%AF%AD%E5%8F%A5%E5%92%8C%E7%BB%93%E6%9E%9C%E4%B8%80%E6%91%B8%E4%B8%80%E6%A0%B7%EF%BC%8C%E4%B9%9F%E6%98%AF%E4%B8%8D%E8%B5%B0%E7%BC%93%E5%AD%98%E7%9A%84%3C/span%3E%3Cspan%3E%E3%80%82%3C/span%3E" STYLE="fork"/>
                <node TEXT="3. 如果对于数据表进行过CRUD的操作，那么所有的缓存必须全部失效，并且将缓存立即从高速缓存中删除" ID="y2it5UT2Bo" _mubu_text="%3Cspan%20class=%22bold%22%3E3.%20%E5%A6%82%E6%9E%9C%E5%AF%B9%E4%BA%8E%E6%95%B0%E6%8D%AE%E8%A1%A8%E8%BF%9B%E8%A1%8C%E8%BF%87CRUD%E7%9A%84%E6%93%8D%E4%BD%9C%EF%BC%8C%E9%82%A3%E4%B9%88%E6%89%80%E6%9C%89%E7%9A%84%E7%BC%93%E5%AD%98%E5%BF%85%E9%A1%BB%E5%85%A8%E9%83%A8%E5%A4%B1%E6%95%88%EF%BC%8C%E5%B9%B6%E4%B8%94%E5%B0%86%E7%BC%93%E5%AD%98%E7%AB%8B%E5%8D%B3%E4%BB%8E%E9%AB%98%E9%80%9F%E7%BC%93%E5%AD%98%E4%B8%AD%E5%88%A0%E9%99%A4%3C/span%3E" STYLE="fork"/>
              </node>
              <node TEXT="重要调整" ID="axtwhpfP2m" _mubu_text="%3Cspan%3E%E9%87%8D%E8%A6%81%E8%B0%83%E6%95%B4%3C/span%3E" STYLE="fork">
                <node TEXT="5.7不推荐使用" ID="U6IcVgbmJ6" _mubu_text="%3Cspan%3E5.7%E4%B8%8D%E6%8E%A8%E8%8D%90%E4%BD%BF%E7%94%A8%3C/span%3E" STYLE="fork"/>
                <node TEXT="8.0删除" ID="pehoCQqPdL" _mubu_text="%3Cspan%3E8.0%E5%88%A0%E9%99%A4%3C/span%3E" STYLE="fork"/>
              </node>
            </node>
            <node TEXT="词法解析" ID="t5Xpci62OT" _mubu_text="%3Cspan%3E%E8%AF%8D%E6%B3%95%E8%A7%A3%E6%9E%90%3C/span%3E" STYLE="fork">
              <node TEXT="mysql服务器的语法翻译工作" ID="u6ldU2jAOC" _mubu_text="%3Cspan%3Emysql%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E8%AF%AD%E6%B3%95%E7%BF%BB%E8%AF%91%E5%B7%A5%E4%BD%9C%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="查询优化" ID="vvWaNIqMmr" _mubu_text="%3Cspan%3E%E6%9F%A5%E8%AF%A2%E4%BC%98%E5%8C%96%3C/span%3E" STYLE="fork">
              <node TEXT="调整发送过来的命令，优化语句的结构" ID="Zh7QUeagIg" _mubu_text="%3Cspan%3E%E8%B0%83%E6%95%B4%E5%8F%91%E9%80%81%E8%BF%87%E6%9D%A5%E7%9A%84%E5%91%BD%E4%BB%A4%EF%BC%8C%E4%BC%98%E5%8C%96%E8%AF%AD%E5%8F%A5%E7%9A%84%E7%BB%93%E6%9E%84%3C/span%3E" STYLE="fork"/>
              <node TEXT="有时候优化会帮倒忙" ID="Lj1xt2YhKF" _mubu_text="%3Cspan%3E%E6%9C%89%E6%97%B6%E5%80%99%E4%BC%98%E5%8C%96%E4%BC%9A%E5%B8%AE%E5%80%92%E5%BF%99%3C/span%3E" STYLE="fork"/>
              <node TEXT="查询优化的规则比较重要" ID="MGx6TXWlGL" _mubu_text="%3Cspan%3E%E6%9F%A5%E8%AF%A2%E4%BC%98%E5%8C%96%E7%9A%84%E8%A7%84%E5%88%99%E6%AF%94%E8%BE%83%E9%87%8D%E8%A6%81%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="3. 存储引擎" ID="lWTeFb5YJ7" _mubu_text="%3Cspan%3E3.%20%E5%AD%98%E5%82%A8%E5%BC%95%E6%93%8E%3C/span%3E" STYLE="fork">
            <node TEXT="实际的数据管理者，通过对外提供的API接口接受请求获取进行数据操作" ID="E77LpUcQz9" _mubu_text="%3Cspan%3E%E5%AE%9E%E9%99%85%E7%9A%84%E6%95%B0%E6%8D%AE%E7%AE%A1%E7%90%86%E8%80%85%EF%BC%8C%E9%80%9A%E8%BF%87%E5%AF%B9%E5%A4%96%E6%8F%90%E4%BE%9B%E7%9A%84API%E6%8E%A5%E5%8F%A3%E6%8E%A5%E5%8F%97%E8%AF%B7%E6%B1%82%E8%8E%B7%E5%8F%96%E8%BF%9B%E8%A1%8C%E6%95%B0%E6%8D%AE%E6%93%8D%E4%BD%9C%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="存储引擎介绍" ID="nzWPO1Pk4F" _mubu_text="%3Cspan%3E%E5%AD%98%E5%82%A8%E5%BC%95%E6%93%8E%E4%BB%8B%E7%BB%8D%3C/span%3E" STYLE="fork">
          <node TEXT="常见存储引擎" ID="VTSHcTgsSE" _mubu_text="%3Cspan%3E%E5%B8%B8%E8%A7%81%E5%AD%98%E5%82%A8%E5%BC%95%E6%93%8E%3C/span%3E" STYLE="fork">
            <node TEXT="InnoDB" ID="s74mqwyfwR" _mubu_text="%3Cspan%3EInnoDB%3C/span%3E" STYLE="fork">
              <node TEXT="并不是mysql开发的，最初为插件" ID="jcYYmSkKCy" _mubu_text="%3Cspan%3E%E5%B9%B6%E4%B8%8D%E6%98%AFmysql%E5%BC%80%E5%8F%91%E7%9A%84%EF%BC%8C%E6%9C%80%E5%88%9D%E4%B8%BA%E6%8F%92%E4%BB%B6%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="MyiSAM" ID="CZizmMvhjW" _mubu_text="%3Cspan%3EMyiSAM%3C/span%3E" STYLE="fork">
              <node TEXT="mysql5.1版本之前的默认存储引擎，由Mysql官方实现" ID="vGrXedeBcJ" _mubu_text="%3Cspan%3Emysql5.1%E7%89%88%E6%9C%AC%E4%B9%8B%E5%89%8D%E7%9A%84%E9%BB%98%E8%AE%A4%E5%AD%98%E5%82%A8%E5%BC%95%E6%93%8E%EF%BC%8C%E7%94%B1Mysql%E5%AE%98%E6%96%B9%E5%AE%9E%E7%8E%B0%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="Memory" ID="dkKggoGS42" _mubu_text="%3Cspan%3EMemory%3C/span%3E" STYLE="fork">
              <node TEXT="临时表在处理较大的查询存在" ID="n9rMYZBoMM" _mubu_text="%3Cspan%3E%E4%B8%B4%E6%97%B6%E8%A1%A8%E5%9C%A8%E5%A4%84%E7%90%86%E8%BE%83%E5%A4%A7%E7%9A%84%E6%9F%A5%E8%AF%A2%E5%AD%98%E5%9C%A8%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
        </node>
      </node>
      <node TEXT="命令行命令格式" ID="m8PyIVMtdq" _mubu_text="%3Cspan%3E%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%91%BD%E4%BB%A4%E6%A0%BC%E5%BC%8F%3C/span%3E" STYLE="fork">
        <node TEXT="单划线和双划线" ID="ZZyvkGWmTW" _mubu_text="%3Cspan%3E%E5%8D%95%E5%88%92%E7%BA%BF%E5%92%8C%E5%8F%8C%E5%88%92%E7%BA%BF%3C/span%3E" STYLE="fork">
          <node TEXT="单划线" ID="nUZ6IvOjmX" _mubu_text="%3Cspan%3E%E5%8D%95%E5%88%92%E7%BA%BF%3C/span%3E" STYLE="fork">
            <node TEXT="适合简称命令，比如-h，-p" ID="kPJommSzbZ" _mubu_text="%3Cspan%3E%E9%80%82%E5%90%88%E7%AE%80%E7%A7%B0%E5%91%BD%E4%BB%A4%EF%BC%8C%E6%AF%94%E5%A6%82-h%EF%BC%8C-p%3C/span%3E" STYLE="fork"/>
            <node TEXT="较为常用的命令格式" ID="4aafj37UQb" _mubu_text="%3Cspan%3E%E8%BE%83%E4%B8%BA%E5%B8%B8%E7%94%A8%E7%9A%84%E5%91%BD%E4%BB%A4%E6%A0%BC%E5%BC%8F%3C/span%3E" STYLE="fork"/>
            <node TEXT="在等式的两边不能有任何空格，否则会报错" ID="0oSaLPmuYN" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%9C%A8%E7%AD%89%E5%BC%8F%E7%9A%84%E4%B8%A4%E8%BE%B9%E4%B8%8D%E8%83%BD%E6%9C%89%E4%BB%BB%E4%BD%95%E7%A9%BA%E6%A0%BC%EF%BC%8C%E5%90%A6%E5%88%99%E4%BC%9A%E6%8A%A5%E9%94%99%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="双划线" ID="4RKedrAvq9" _mubu_text="%3Cspan%3E%E5%8F%8C%E5%88%92%E7%BA%BF%3C/span%3E" STYLE="fork">
            <node TEXT="通常为全称命令，比如--host，--port" ID="tlPlNlepJC" _mubu_text="%3Cspan%3E%E9%80%9A%E5%B8%B8%E4%B8%BA%E5%85%A8%E7%A7%B0%E5%91%BD%E4%BB%A4%EF%BC%8C%E6%AF%94%E5%A6%82--host%EF%BC%8C--port%3C/span%3E" STYLE="fork"/>
            <node TEXT="某些命令只有全称，比如--skip-networking" ID="LRelzaHuCK" _mubu_text="%3Cspan%3E%E6%9F%90%E4%BA%9B%E5%91%BD%E4%BB%A4%E5%8F%AA%E6%9C%89%E5%85%A8%E7%A7%B0%EF%BC%8C%E6%AF%94%E5%A6%82--skip-networking%3C/span%3E" STYLE="fork"/>
            <node TEXT="允许多个单词使用中划线或者下划线替代" ID="qjGxf9pKsH" _mubu_text="%3Cspan%3E%E5%85%81%E8%AE%B8%E5%A4%9A%E4%B8%AA%E5%8D%95%E8%AF%8D%E4%BD%BF%E7%94%A8%E4%B8%AD%E5%88%92%E7%BA%BF%E6%88%96%E8%80%85%E4%B8%8B%E5%88%92%E7%BA%BF%E6%9B%BF%E4%BB%A3%3C/span%3E" STYLE="fork">
              <node TEXT="--skip_networing和--skip-networing的效果等同" ID="Mv5glt6RyY" _mubu_text="%3Cspan%3E--skip_networing%E5%92%8C--skip-networing%E7%9A%84%E6%95%88%E6%9E%9C%E7%AD%89%E5%90%8C%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="在等式的两边不能有任何空格，否则会报错" ID="PADEpCr9Ep" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%9C%A8%E7%AD%89%E5%BC%8F%E7%9A%84%E4%B8%A4%E8%BE%B9%E4%B8%8D%E8%83%BD%E6%9C%89%E4%BB%BB%E4%BD%95%E7%A9%BA%E6%A0%BC%EF%BC%8C%E5%90%A6%E5%88%99%E4%BC%9A%E6%8A%A5%E9%94%99%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
      </node>
      <node TEXT="配置文件" ID="z7nmW8gtBV" _mubu_text="%3Cspan%3E%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%3C/span%3E" STYLE="fork">
        <node TEXT="配置读取顺序" ID="UiF7kGvua8" _mubu_text="%3Cspan%3E%E9%85%8D%E7%BD%AE%E8%AF%BB%E5%8F%96%E9%A1%BA%E5%BA%8F%3C/span%3E" STYLE="fork">
          <node TEXT="Windows" ID="XfP9OiHqup" _mubu_text="%3Cspan%3EWindows%3C/span%3E" STYLE="fork">
            <node TEXT="1. %WINDIR%\my.ini %windir\my.cnf% （echo %WINDIR%获取）" ID="YXE2lrrKh5" _mubu_text="%3Cspan%3E1.%20%25WINDIR%25%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3Emy.ini%20%25windir%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3Emy.cnf%25%20%EF%BC%88echo%20%25WINDIR%25%E8%8E%B7%E5%8F%96%EF%BC%89%3C/span%3E" STYLE="fork"/>
            <node TEXT="2. C:\my.ini C:\my.cnf" ID="v5q3cH946o" _mubu_text="%3Cspan%3E2.%20C:%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3Emy.ini%20C:%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3Emy.cnf%3C/span%3E" STYLE="fork"/>
            <node TEXT="3. Basdir\my.ini basdir\my.cnf（based it指的是默认的安装路径）" ID="914fnbb4I6" _mubu_text="%3Cspan%3E3.%20Basdir%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3Emy.ini%20basdir%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3Emy.cnf%EF%BC%88based%20it%E6%8C%87%E7%9A%84%E6%98%AF%E9%BB%98%E8%AE%A4%E7%9A%84%E5%AE%89%E8%A3%85%E8%B7%AF%E5%BE%84%EF%BC%89%3C/span%3E" STYLE="fork"/>
            <node TEXT="4. Defaults-extra-file 命令行制定的额外配置文件路径" ID="g138Zpasjh" _mubu_text="%3Cspan%3E4.%20Defaults-extra-file%20%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%88%B6%E5%AE%9A%E7%9A%84%E9%A2%9D%E5%A4%96%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E8%B7%AF%E5%BE%84%3C/span%3E" STYLE="fork">
              <node TEXT="利用的是命令行的参数形式进行指定配置文件读取" ID="yhpUZpP0gj" _mubu_text="%3Cspan%3E%E5%88%A9%E7%94%A8%E7%9A%84%E6%98%AF%E5%91%BD%E4%BB%A4%E8%A1%8C%E7%9A%84%E5%8F%82%E6%95%B0%E5%BD%A2%E5%BC%8F%E8%BF%9B%E8%A1%8C%E6%8C%87%E5%AE%9A%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E8%AF%BB%E5%8F%96%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="5. %appdata%\MySQL\ .mylogin.cnf 登陆路径选项（客户端指定，通过echo %APPDATA%可以获取）" ID="06yf6RhZKA" _mubu_text="%3Cspan%3E5.%20%25appdata%25%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3EMySQL%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3E%20.mylogin.cnf%20%E7%99%BB%E9%99%86%E8%B7%AF%E5%BE%84%E9%80%89%E9%A1%B9%EF%BC%88%E5%AE%A2%E6%88%B7%E7%AB%AF%E6%8C%87%E5%AE%9A%EF%BC%8C%E9%80%9A%E8%BF%87echo%20%25APPDATA%25%E5%8F%AF%E4%BB%A5%E8%8E%B7%E5%8F%96%EF%BC%89%3C/span%3E" STYLE="fork">
              <node TEXT=".mylogin.cnf 是使用mysql_config_editor编写的一种由mysql进行专有g规则操作的特殊配置文件，支持的配置选项并不是很多" ID="5iCa7AGQmi" _mubu_text="%3Cspan%3E.mylogin.cnf%20%E6%98%AF%E4%BD%BF%E7%94%A8mysql_config_editor%E7%BC%96%E5%86%99%E7%9A%84%E4%B8%80%E7%A7%8D%E7%94%B1mysql%E8%BF%9B%E8%A1%8C%E4%B8%93%E6%9C%89g%E8%A7%84%E5%88%99%E6%93%8D%E4%BD%9C%E7%9A%84%E7%89%B9%E6%AE%8A%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%EF%BC%8C%E6%94%AF%E6%8C%81%E7%9A%84%E9%85%8D%E7%BD%AE%E9%80%89%E9%A1%B9%E5%B9%B6%E4%B8%8D%E6%98%AF%E5%BE%88%E5%A4%9A%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="类unix" ID="LWdZlMOXPS" _mubu_text="%3Cspan%3E%E7%B1%BBunix%3C/span%3E" STYLE="fork">
            <node TEXT="1. /etc/MySQL/my.inf" ID="9oyp3n275X" _mubu_text="%3Cspan%3E1.%20/etc/MySQL/my.inf%3C/span%3E" STYLE="fork"/>
            <node TEXT="2. SYSCONFIGDIR/my.cnf （MySQL的系统安装目录）" ID="JnOq0afRD1" _mubu_text="%3Cspan%3E2.%20SYSCONFIGDIR/my.cnf%20%EF%BC%88MySQL%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%AE%89%E8%A3%85%E7%9B%AE%E5%BD%95%EF%BC%89%3C/span%3E" STYLE="fork">
              <node TEXT="通常为CMake 构建 MySQL 时使用SYSCONFDIR 选项指定的目录" ID="DMFsqMlAEB" _mubu_text="%3Cspan%3E%E9%80%9A%E5%B8%B8%E4%B8%BACMake%20%E6%9E%84%E5%BB%BA%20MySQL%20%E6%97%B6%E4%BD%BF%E7%94%A8SYSCONFDIR%20%E9%80%89%E9%A1%B9%E6%8C%87%E5%AE%9A%E7%9A%84%E7%9B%AE%E5%BD%95%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="3. %MYSQL_HOME%/my.cnf 仅限服务器的选项" ID="MYAibiuqVE" _mubu_text="%3Cspan%3E3.%20%25MYSQL_HOME%25/my.cnf%20%E4%BB%85%E9%99%90%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E9%80%89%E9%A1%B9%3C/span%3E" STYLE="fork">
              <node TEXT="" ID="coZQrwc9lZ" _mubu_text="" STYLE="fork"/>
            </node>
            <node TEXT="4. Defaults_extra-file 同样为命令行指定读取" ID="r0FA7l20XQ" _mubu_text="%3Cspan%3E4.%20Defaults_extra-file%20%E5%90%8C%E6%A0%B7%E4%B8%BA%E5%91%BD%E4%BB%A4%E8%A1%8C%E6%8C%87%E5%AE%9A%E8%AF%BB%E5%8F%96%3C/span%3E" STYLE="fork">
              <node TEXT="和windows一样，使用命令行指定配置文件的读取路径" ID="YVbnwcbgkz" _mubu_text="%3Cspan%3E%E5%92%8Cwindows%E4%B8%80%E6%A0%B7%EF%BC%8C%E4%BD%BF%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E6%8C%87%E5%AE%9A%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E7%9A%84%E8%AF%BB%E5%8F%96%E8%B7%AF%E5%BE%84%3C/span%3E" STYLE="fork"/>
              <node TEXT="unix系统通常/为根目录" ID="vReC1r2W7z" _mubu_text="%3Cspan%3Eunix%E7%B3%BB%E7%BB%9F%E9%80%9A%E5%B8%B8/%E4%B8%BA%E6%A0%B9%E7%9B%AE%E5%BD%95%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="5. ~/.my.cnf （注意前面的逗号）" ID="M1nGKRQ992" _mubu_text="%3Cspan%3E5.%20~/.my.cnf%20%EF%BC%88%E6%B3%A8%E6%84%8F%E5%89%8D%E9%9D%A2%E7%9A%84%E9%80%97%E5%8F%B7%EF%BC%89%3C/span%3E" STYLE="fork">
              <node TEXT="根据当前的登陆用户的家目录判断" ID="NXHS3mQl5v" _mubu_text="%3Cspan%3E%E6%A0%B9%E6%8D%AE%E5%BD%93%E5%89%8D%E7%9A%84%E7%99%BB%E9%99%86%E7%94%A8%E6%88%B7%E7%9A%84%E5%AE%B6%E7%9B%AE%E5%BD%95%E5%88%A4%E6%96%AD%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="6. ~/.mylogin.cnf 需要mysql_config_editor 的支持并不是纯文本文件" ID="xTCSOdemwW" _mubu_text="%3Cspan%3E6.%20~/.mylogin.cnf%20%E9%9C%80%E8%A6%81%3C/span%3E%3Cspan%20class=%22bold%22%3Emysql_config_editor%3C/span%3E%3Cspan%3E%20%E7%9A%84%E6%94%AF%E6%8C%81%E5%B9%B6%E4%B8%8D%E6%98%AF%E7%BA%AF%E6%96%87%E6%9C%AC%E6%96%87%E4%BB%B6%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="mac" ID="4OFUvRfIVx" _mubu_text="%3Cspan%3Emac%3C/span%3E" STYLE="fork">
            <node TEXT="可以使用：mysql -verbose --help | grep my.cnf获取读取配置文件的顺序" ID="tdn3ea0asc" _mubu_text="%3Cspan%3E%E5%8F%AF%E4%BB%A5%E4%BD%BF%E7%94%A8%EF%BC%9A%3C/span%3E%3Cspan%20class=%22bold%22%3Emysql%20-verbose%20--help%20%7C%20grep%20my.cnf%E8%8E%B7%E5%8F%96%E8%AF%BB%E5%8F%96%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E7%9A%84%E9%A1%BA%E5%BA%8F%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
      </node>
      <node TEXT="配置文件内容" ID="a1DJEujLyD" _mubu_text="%3Cspan%3E%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%86%85%E5%AE%B9%3C/span%3E" STYLE="fork">
        <node TEXT="文件配置模板" ID="VxvvpzBrxE" _mubu_text="%3Cspan%3E%E6%96%87%E4%BB%B6%E9%85%8D%E7%BD%AE%E6%A8%A1%E6%9D%BF%3C/span%3E" STYLE="fork">
          <node TEXT="配置分组" ID="WNBFzvB10Z" _mubu_text="%3Cspan%3E%E9%85%8D%E7%BD%AE%E5%88%86%E7%BB%84%3C/span%3E" STYLE="fork">
            <node TEXT="[server] (具体的启动选项...)" ID="i4epBX7QA7" _mubu_text="%3Cspan%3E%5Bserver%5D%20(%E5%85%B7%E4%BD%93%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9...)%3C/span%3E" STYLE="fork">
              <node TEXT="[server] 组下边的启动选项将作用于所有的服务器程序。" ID="Ps56qmfaa3" _mubu_text="%3Cspan%3E%5Bserver%5D%20%E7%BB%84%E4%B8%8B%E8%BE%B9%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%E5%B0%86%E4%BD%9C%E7%94%A8%E4%BA%8E%E6%89%80%E6%9C%89%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%A8%8B%E5%BA%8F%E3%80%82%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="[mysqld] (具体的启动选项...)" ID="VVAKVc54ds" _mubu_text="%3Cspan%3E%5Bmysqld%5D%20(%E5%85%B7%E4%BD%93%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9...)%3C/span%3E" STYLE="fork"/>
            <node TEXT="[mysqld_safe] (具体的启动选项...)" ID="pb13CmgM0h" _mubu_text="%3Cspan%3E%5Bmysqld_safe%5D%20(%E5%85%B7%E4%BD%93%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9...)%3C/span%3E" STYLE="fork"/>
            <node TEXT="[client] (具体的启动选项...)" ID="F01twUiSnr" _mubu_text="%3Cspan%3E%5Bclient%5D%20(%E5%85%B7%E4%BD%93%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9...)%3C/span%3E" STYLE="fork">
              <node TEXT="[client] 组下边的启动选项将作用于所有的客户端程序" ID="heoajqQnCd" _mubu_text="%3Cspan%3E%5Bclient%5D%20%E7%BB%84%E4%B8%8B%E8%BE%B9%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%E5%B0%86%E4%BD%9C%E7%94%A8%E4%BA%8E%E6%89%80%E6%9C%89%E7%9A%84%E5%AE%A2%E6%88%B7%E7%AB%AF%E7%A8%8B%E5%BA%8F%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="[mysql] (具体的启动选项...)" ID="YBbrpqYjCA" _mubu_text="%3Cspan%3E%5Bmysql%5D%20(%E5%85%B7%E4%BD%93%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9...)%3C/span%3E" STYLE="fork"/>
            <node TEXT="[mysqladmin] (具体的启动选项...)" ID="uMU7Kz4ZhL" _mubu_text="%3Cspan%3E%5Bmysqladmin%5D%20(%E5%85%B7%E4%BD%93%E7%9A%84%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9...)%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="配置内容" ID="0E3sHhjBsg" _mubu_text="%3Cspan%3E%E9%85%8D%E7%BD%AE%E5%86%85%E5%AE%B9%3C/span%3E" STYLE="fork">
            <node TEXT="只支持长形式配置，不能使用短形式" ID="MnQaIQL9wG" _mubu_text="%3Cspan%3E%E5%8F%AA%E6%94%AF%E6%8C%81%E9%95%BF%E5%BD%A2%E5%BC%8F%E9%85%8D%E7%BD%AE%EF%BC%8C%E4%B8%8D%E8%83%BD%E4%BD%BF%E7%94%A8%E7%9F%AD%E5%BD%A2%E5%BC%8F%3C/span%3E" STYLE="fork"/>
            <node TEXT="等式的左右两边可以随意配置空格，不影响" ID="eeKdvxspvY" _mubu_text="%3Cspan%20class=%22bold%22%3E%E7%AD%89%E5%BC%8F%E7%9A%84%E5%B7%A6%E5%8F%B3%E4%B8%A4%E8%BE%B9%E5%8F%AF%E4%BB%A5%E9%9A%8F%E6%84%8F%E9%85%8D%E7%BD%AE%E7%A9%BA%E6%A0%BC%EF%BC%8C%E4%B8%8D%E5%BD%B1%E5%93%8D%3C/span%3E" STYLE="fork">
              <node TEXT="但是命令行影响，不能这么干哟，注意" ID="ep6iqGPCYo" _mubu_text="%3Cspan%3E%E4%BD%86%E6%98%AF%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%BD%B1%E5%93%8D%EF%BC%8C%E4%B8%8D%E8%83%BD%E8%BF%99%E4%B9%88%E5%B9%B2%E5%93%9F%EF%BC%8C%E6%B3%A8%E6%84%8F%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="使用\#号进行配置文件的注释" ID="dFzLx310Gd" _mubu_text="%3Cspan%3E%E4%BD%BF%E7%94%A8%3C/span%3E%3Cspan%20class=%22escaped%22%3E%5C%3C/span%3E%3Cspan%3E#%E5%8F%B7%E8%BF%9B%E8%A1%8C%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E7%9A%84%E6%B3%A8%E9%87%8A%3C/span%3E" STYLE="fork"/>
            <node TEXT="选项值：--option和--option=optionvalue" ID="NlTppVQz2H" _mubu_text="%3Cspan%3E%E9%80%89%E9%A1%B9%E5%80%BC%EF%BC%9A--option%E5%92%8C--option=optionvalue%3C/span%3E" STYLE="fork"/>
            <node TEXT="根据分组服务端的启动命令会有不同的读取范围" ID="MR2M7KmNLK" _mubu_text="%3Cspan%3E%E6%A0%B9%E6%8D%AE%E5%88%86%E7%BB%84%E6%9C%8D%E5%8A%A1%E7%AB%AF%E7%9A%84%E5%90%AF%E5%8A%A8%E5%91%BD%E4%BB%A4%E4%BC%9A%E6%9C%89%E4%B8%8D%E5%90%8C%E7%9A%84%E8%AF%BB%E5%8F%96%E8%8C%83%E5%9B%B4%3C/span%3E" STYLE="fork">
              <node TEXT="比如mysqld_safe命令可以读取mysqld、server、mysqld_safe三个分组的内容" ID="SIujhz8WTD" _mubu_text="%3Cspan%3E%E6%AF%94%E5%A6%82mysqld_safe%E5%91%BD%E4%BB%A4%E5%8F%AF%E4%BB%A5%E8%AF%BB%E5%8F%96mysqld%E3%80%81server%E3%80%81mysqld_safe%E4%B8%89%E4%B8%AA%E5%88%86%E7%BB%84%E7%9A%84%E5%86%85%E5%AE%B9%3C/span%3E" STYLE="fork"/>
              <node TEXT="Mysql.server 命令本身就是设计为针对配置文件使用，所以他最终支持的命令行的命令仅仅为 start和stop" ID="vLx0uKOUUp" _mubu_text="%3Cspan%3EMysql.server%20%E5%91%BD%E4%BB%A4%E6%9C%AC%E8%BA%AB%E5%B0%B1%E6%98%AF%E8%AE%BE%E8%AE%A1%E4%B8%BA%E9%92%88%E5%AF%B9%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E4%BD%BF%E7%94%A8%EF%BC%8C%E6%89%80%E4%BB%A5%E4%BB%96%E6%9C%80%E7%BB%88%E6%94%AF%E6%8C%81%E7%9A%84%E5%91%BD%E4%BB%A4%E8%A1%8C%E7%9A%84%E5%91%BD%E4%BB%A4%E4%BB%85%E4%BB%85%E4%B8%BA%20start%E5%92%8Cstop%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="版本配置" ID="d0l6EasHC8" _mubu_text="%3Cspan%3E%E7%89%88%E6%9C%AC%E9%85%8D%E7%BD%AE%3C/span%3E" STYLE="fork">
            <node TEXT="8.0我们可以配置[mysqld-8.0]" ID="jceYbjFc3U" _mubu_text="%3Cspan%3E8.0%E6%88%91%E4%BB%AC%E5%8F%AF%E4%BB%A5%E9%85%8D%E7%BD%AE%3C/span%3E%3Cspan%20class=%22bold%22%3E%5Bmysqld-8.0%5D%3C/span%3E" STYLE="fork"/>
            <node TEXT="5.7我们就可以使用[mysqld-5.7]" ID="9lSqrvtF2P" _mubu_text="%3Cspan%3E5.7%E6%88%91%E4%BB%AC%E5%B0%B1%E5%8F%AF%E4%BB%A5%E4%BD%BF%E7%94%A8%3C/span%3E%3Cspan%20class=%22bold%22%3E%5Bmysqld-5.7%5D%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="优先级" ID="RiEwxSKv7U" _mubu_text="%3Cspan%3E%E4%BC%98%E5%85%88%E7%BA%A7%3C/span%3E" STYLE="fork">
            <node TEXT="多配置文件" ID="gNnDgVSeXI" _mubu_text="%3Cspan%3E%E5%A4%9A%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%3C/span%3E" STYLE="fork">
              <node TEXT="多个文件以文件的读取顺序中最后的读取的为最终结果" ID="97cbBbTmos" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%A4%9A%E4%B8%AA%E6%96%87%E4%BB%B6%E4%BB%A5%E6%96%87%E4%BB%B6%E7%9A%84%E8%AF%BB%E5%8F%96%E9%A1%BA%E5%BA%8F%E4%B8%AD%E6%9C%80%E5%90%8E%E7%9A%84%E8%AF%BB%E5%8F%96%E7%9A%84%E4%B8%BA%E6%9C%80%E7%BB%88%E7%BB%93%E6%9E%9C%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="单文件重复" ID="CdsEhNye7P" _mubu_text="%3Cspan%3E%E5%8D%95%E6%96%87%E4%BB%B6%E9%87%8D%E5%A4%8D%3C/span%3E" STYLE="fork">
              <node TEXT="单文件重复分组按照最后一个组中出现的配置为主" ID="gNGDSYZ586" _mubu_text="%3Cspan%3E%E5%8D%95%E6%96%87%E4%BB%B6%E9%87%8D%E5%A4%8D%E5%88%86%E7%BB%84%E6%8C%89%E7%85%A7%E6%9C%80%E5%90%8E%E4%B8%80%E4%B8%AA%E7%BB%84%E4%B8%AD%E5%87%BA%E7%8E%B0%E7%9A%84%E9%85%8D%E7%BD%AE%E4%B8%BA%E4%B8%BB%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
        </node>
        <node TEXT="自定义指定配置" ID="UXPKFvj7DM" _mubu_text="%3Cspan%3E%E8%87%AA%E5%AE%9A%E4%B9%89%E6%8C%87%E5%AE%9A%E9%85%8D%E7%BD%AE%3C/span%3E" STYLE="fork">
          <node TEXT="mysqld --defaults-file=/tmp/myconfig.txt" ID="YEmJRjya7W" _mubu_text="%3Cspan%3Emysqld%20--defaults-file=/tmp/myconfig.txt%3C/span%3E" STYLE="fork"/>
          <node TEXT="--defaults-file和defaults-extra-file 区别" ID="eAdG08sHtd" _mubu_text="%3Cspan%3E--defaults-file%E5%92%8Cdefaults-extra-file%20%E5%8C%BA%E5%88%AB%3C/span%3E" STYLE="fork">
            <node TEXT="defaults-extra-file可以指定额外的路径" ID="seUj0wAUuP" _mubu_text="%3Cspan%3Edefaults-extra-file%E5%8F%AF%E4%BB%A5%E6%8C%87%E5%AE%9A%E9%A2%9D%E5%A4%96%E7%9A%84%E8%B7%AF%E5%BE%84%3C/span%3E" STYLE="fork"/>
            <node TEXT="--defaults-file 只能指定一个配置路径" ID="zreJy86FMT" _mubu_text="%3Cspan%3E--defaults-file%20%E5%8F%AA%E8%83%BD%E6%8C%87%E5%AE%9A%E4%B8%80%E4%B8%AA%E9%85%8D%E7%BD%AE%E8%B7%AF%E5%BE%84%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="系统变量的配置" ID="ZbXoPSpTxX" _mubu_text="%3Cspan%3E%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E7%9A%84%E9%85%8D%E7%BD%AE%3C/span%3E" STYLE="fork">
          <node TEXT="如何查看？" ID="oOy0bJxDBf" _mubu_text="%3Cspan%3E%E5%A6%82%E4%BD%95%E6%9F%A5%E7%9C%8B%EF%BC%9F%3C/span%3E" STYLE="fork">
            <node TEXT="SHOW VARIABLES [LIKE 匹配的模式];" ID="pbIoU5W6rE" _mubu_text="%3Cspan%3ESHOW%20VARIABLES%20%5BLIKE%20%E5%8C%B9%E9%85%8D%E7%9A%84%E6%A8%A1%E5%BC%8F%5D;%3C/span%3E" STYLE="fork">
              <node TEXT="案例" ID="VnYW0b0Kxq" _mubu_text="%3Cspan%3E%E6%A1%88%E4%BE%8B%3C/span%3E" STYLE="fork">
                <node TEXT="SHOW VARIABLES LIKE &apos;default_storage_engine&apos;;" ID="OlUWlKnZpu" _mubu_text="%3Cspan%3ESHOW%20VARIABLES%20LIKE%20&apos;default_storage_engine&apos;;%3C/span%3E" STYLE="fork"/>
                <node TEXT="show variables like &apos;mysql%&apos;;" ID="3gEaGiQvY4" _mubu_text="%3Cspan%3Eshow%20variables%20like%20&apos;mysql%25&apos;;%3C/span%3E" STYLE="fork"/>
              </node>
            </node>
          </node>
          <node TEXT="设置系统变量" ID="g2Zuz6gmz5" _mubu_text="%3Cspan%3E%E8%AE%BE%E7%BD%AE%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork">
            <node TEXT="通过命令行启动选项" ID="M2l3n2cnV4" _mubu_text="%3Cspan%3E%E9%80%9A%E8%BF%87%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%3C/span%3E" STYLE="fork">
              <node TEXT="--default-file=xxx" ID="oFlBDDKv8I" _mubu_text="%3Cspan%3E--default-file=xxx%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="通过配置文件启动选项" ID="N2gawAHoRf" _mubu_text="%3Cspan%3E%E9%80%9A%E8%BF%87%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="运行时的系统变量" ID="wqr60Ru8x3" _mubu_text="%3Cspan%3E%E8%BF%90%E8%A1%8C%E6%97%B6%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork">
            <node TEXT="系统变量特性" ID="ESwrSYRxUH" _mubu_text="%3Cspan%3E%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E7%89%B9%E6%80%A7%3C/span%3E" STYLE="fork">
              <node TEXT="对于多数的系统变量都是可以在服务器程序运行的时候动态修改" ID="cmjRauAUB9" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%AF%B9%E4%BA%8E%E5%A4%9A%E6%95%B0%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E9%83%BD%E6%98%AF%E5%8F%AF%E4%BB%A5%E5%9C%A8%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%A8%8B%E5%BA%8F%E8%BF%90%E8%A1%8C%E7%9A%84%E6%97%B6%E5%80%99%E5%8A%A8%E6%80%81%E4%BF%AE%E6%94%B9%3C/span%3E" STYLE="fork"/>
              <node TEXT="默认查看的是 SESSION 作用范围的系统变量" ID="u4DVwx9A1m" _mubu_text="%3Cspan%20class=%22bold%22%3E%E9%BB%98%E8%AE%A4%E6%9F%A5%E7%9C%8B%E7%9A%84%E6%98%AF%20SESSION%20%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="运行时参数的问题" ID="iYI6W6wSRv" _mubu_text="%3Cspan%3E%E8%BF%90%E8%A1%8C%E6%97%B6%E5%8F%82%E6%95%B0%E7%9A%84%E9%97%AE%E9%A2%98%3C/span%3E" STYLE="fork">
              <node TEXT="连接时的系统变量配置" ID="MGlu8FbBjT" _mubu_text="%3Cspan%3E%E8%BF%9E%E6%8E%A5%E6%97%B6%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E9%85%8D%E7%BD%AE%3C/span%3E" STYLE="fork"/>
              <node TEXT="公有参数的私有化问题" ID="btYXmM13rn" _mubu_text="%3Cspan%3E%E5%85%AC%E6%9C%89%E5%8F%82%E6%95%B0%E7%9A%84%E7%A7%81%E6%9C%89%E5%8C%96%E9%97%AE%E9%A2%98%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="作用范围" ID="0I657zYOW4" _mubu_text="%3Cspan%3E%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%3C/span%3E" STYLE="fork">
              <node TEXT="GLOBAL :全局变量，影响服务器的整体操作。" ID="0YZGi4KkfF" _mubu_text="%3Cspan%3EGLOBAL%20:%E5%85%A8%E5%B1%80%E5%8F%98%E9%87%8F%EF%BC%8C%E5%BD%B1%E5%93%8D%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E6%95%B4%E4%BD%93%E6%93%8D%E4%BD%9C%E3%80%82%3C/span%3E" STYLE="fork"/>
              <node TEXT="SESSION :会话变量，影响某个客户端连接的操作" ID="c8Obm3cM03" _mubu_text="%3Cspan%3ESESSION%20:%E4%BC%9A%E8%AF%9D%E5%8F%98%E9%87%8F%EF%BC%8C%E5%BD%B1%E5%93%8D%3C/span%3E%3Cspan%20class=%22bold%22%3E%E6%9F%90%E4%B8%AA%E5%AE%A2%E6%88%B7%E7%AB%AF%E8%BF%9E%E6%8E%A5%3C/span%3E%3Cspan%3E%E7%9A%84%E6%93%8D%E4%BD%9C%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="灵活记忆" ID="ZISAJNM10B" _mubu_text="%3Cspan%20class=%22bold%22%3E%E7%81%B5%E6%B4%BB%E8%AE%B0%E5%BF%86%3C/span%3E" STYLE="fork">
              <node TEXT="Mysqld：服务端启动的相关配置都是全局的变量" ID="FSwA4XcJtL" _mubu_text="%3Cspan%3EMysqld%EF%BC%9A%E6%9C%8D%E5%8A%A1%E7%AB%AF%E5%90%AF%E5%8A%A8%E7%9A%84%E7%9B%B8%E5%85%B3%E9%85%8D%E7%BD%AE%E9%83%BD%E6%98%AF%E5%85%A8%E5%B1%80%E7%9A%84%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork"/>
              <node TEXT="Mysql：客户端连接的命令产生的配置，连接前的命令行使用会话变量，在连接时可以进行相关命令操作把全局变量变为临时变量。" ID="ZoK19OVhDw" _mubu_text="%3Cspan%3EMysql%EF%BC%9A%E5%AE%A2%E6%88%B7%E7%AB%AF%E8%BF%9E%E6%8E%A5%E7%9A%84%E5%91%BD%E4%BB%A4%E4%BA%A7%E7%94%9F%E7%9A%84%E9%85%8D%E7%BD%AE%EF%BC%8C%E8%BF%9E%E6%8E%A5%E5%89%8D%E7%9A%84%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%BD%BF%E7%94%A8%E4%BC%9A%E8%AF%9D%E5%8F%98%E9%87%8F%EF%BC%8C%E5%9C%A8%E8%BF%9E%E6%8E%A5%E6%97%B6%E5%8F%AF%E4%BB%A5%E8%BF%9B%E8%A1%8C%E7%9B%B8%E5%85%B3%E5%91%BD%E4%BB%A4%E6%93%8D%E4%BD%9C%E6%8A%8A%E5%85%A8%E5%B1%80%E5%8F%98%E9%87%8F%E5%8F%98%E4%B8%BA%E4%B8%B4%E6%97%B6%E5%8F%98%E9%87%8F%E3%80%82%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="全局变量和会话变量的设置" ID="sYsNjIuo9E" _mubu_text="%3Cspan%3E%E5%85%A8%E5%B1%80%E5%8F%98%E9%87%8F%E5%92%8C%E4%BC%9A%E8%AF%9D%E5%8F%98%E9%87%8F%E7%9A%84%E8%AE%BE%E7%BD%AE%3C/span%3E" STYLE="fork">
            <node TEXT="SET [GLOBAL|SESSION] 系统变量名 = 值;" ID="0Ot3CzFKi5" _mubu_text="%3Cspan%3ESET%20%5BGLOBAL%7CSESSION%5D%20%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E5%90%8D%20=%20%E5%80%BC;%3C/span%3E" STYLE="fork">
              <node TEXT="SET GLOBAL default_storage_engine = MyISAM;" ID="nagfnccCMV" _mubu_text="%3Cspan%3ESET%20GLOBAL%20default_storage_engine%20=%20MyISAM;%3C/span%3E" STYLE="fork"/>
              <node TEXT="SET @@GLOBAL.default_storage_engine = MyISAM;" ID="LDELngA4B3" _mubu_text="%3Cspan%3ESET%20@@GLOBAL.default_storage_engine%20=%20MyISAM;%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="SET [@@(GLOBAL|SESSION).]var_name = XXX;" ID="1hCphTEjfp" _mubu_text="%3Cspan%3ESET%20%5B@@(GLOBAL%7CSESSION).%5Dvar_name%20=%20XXX;%3C/span%3E" STYLE="fork">
              <node TEXT="SET SESSION default_storage_engine = MyISAM;" ID="NMlx44GL7R" _mubu_text="%3Cspan%3ESET%20SESSION%20default_storage_engine%20=%20MyISAM;%3C/span%3E" STYLE="fork"/>
              <node TEXT="SET @@SESSION.default_storage_engine = MyISAM;" ID="Y196qELiG2" _mubu_text="%3Cspan%3ESET%20@@SESSION.default_storage_engine%20=%20MyISAM;%3C/span%3E" STYLE="fork"/>
              <node TEXT="SET default_storage_engine = MyISAM;" ID="xOjAkPZila" _mubu_text="%3Cspan%3ESET%20default_storage_engine%20=%20MyISAM;%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="查看系统变量的作用范围" ID="5uUtSsteLb" _mubu_text="%3Cspan%3E%E6%9F%A5%E7%9C%8B%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E7%9A%84%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%3C/span%3E" STYLE="fork">
            <node TEXT="SHOW [GLOBAL|SESSION] VARIABLES [LIKE 匹配的模式];" ID="yEBnS3xoDU" _mubu_text="%3Cspan%3ESHOW%20%5BGLOBAL%7CSESSION%5D%20VARIABLES%20%5BLIKE%20%E5%8C%B9%E9%85%8D%E7%9A%84%E6%A8%A1%E5%BC%8F%5D;%3C/span%3E" STYLE="fork">
              <node TEXT="SHOW SESSION VARIABLES LIKE &apos;default_storage_engine&apos;;" ID="XUeLjlkNSr" _mubu_text="%3Cspan%3ESHOW%20SESSION%20VARIABLES%20LIKE%20&apos;default_storage_engine&apos;;%3C/span%3E" STYLE="fork"/>
              <node TEXT="SHOW GLOBAL VARIABLES LIKE &apos;default_storage_engine&apos;;" ID="3R5S94KgYp" _mubu_text="%3Cspan%3ESHOW%20GLOBAL%20VARIABLES%20LIKE%20&apos;default_storage_engine&apos;;%3C/span%3E" STYLE="fork"/>
              <node TEXT="SET SESSION default_storage_engine = MyISAM;" ID="R0QvN8QLvc" _mubu_text="%3Cspan%3ESET%20SESSION%20default_storage_engine%20=%20MyISAM;%3C/span%3E" STYLE="fork"/>
              <node TEXT="SHOW SESSION VARIABLES LIKE &apos;default_storage_engine&apos;;" ID="NSwfAncqsk" _mubu_text="%3Cspan%3ESHOW%20SESSION%20VARIABLES%20LIKE%20&apos;default_storage_engine&apos;;%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="系统变量注意事项" ID="imxZ8jDqk1" _mubu_text="%3Cspan%3E%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9%3C/span%3E" STYLE="fork">
            <node TEXT="不是所有系统变量都具有 GLOBAL 和 SESSION 的作用范围。" ID="Qbsxdyhvre" _mubu_text="%3Cspan%3E%E4%B8%8D%E6%98%AF%E6%89%80%E6%9C%89%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E9%83%BD%E5%85%B7%E6%9C%89%20GLOBAL%20%E5%92%8C%20SESSION%20%E7%9A%84%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%E3%80%82%3C/span%3E" STYLE="fork">
              <node TEXT="有一些系统变量只具有 GLOBAL 作用范围，比方说 max_connections" ID="pKSnjRszH1" _mubu_text="%3Cspan%3E%E6%9C%89%E4%B8%80%E4%BA%9B%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E5%8F%AA%E5%85%B7%E6%9C%89%20GLOBAL%20%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%EF%BC%8C%E6%AF%94%E6%96%B9%E8%AF%B4%20max_connections%3C/span%3E" STYLE="fork"/>
              <node TEXT="有一些系统变量只具有 SESSION 作用范围，比如 insert_id。" ID="i3SBC1FW2J" _mubu_text="%3Cspan%3E%E6%9C%89%E4%B8%80%E4%BA%9B%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E5%8F%AA%E5%85%B7%E6%9C%89%20SESSION%20%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%EF%BC%8C%E6%AF%94%E5%A6%82%20insert_id%E3%80%82%3C/span%3E" STYLE="fork"/>
              <node TEXT="有一些系统变量的值既具有 GLOBAL 作用范围，也具有 SESSION 作用范围，比如我们前边用到的 default_storage_engine。" ID="xNNyxM9vVz" _mubu_text="%3Cspan%3E%E6%9C%89%E4%B8%80%E4%BA%9B%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E7%9A%84%E5%80%BC%E6%97%A2%E5%85%B7%E6%9C%89%20GLOBAL%20%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%EF%BC%8C%E4%B9%9F%E5%85%B7%E6%9C%89%20SESSION%20%E4%BD%9C%E7%94%A8%E8%8C%83%E5%9B%B4%EF%BC%8C%E6%AF%94%E5%A6%82%E6%88%91%E4%BB%AC%E5%89%8D%E8%BE%B9%E7%94%A8%E5%88%B0%E7%9A%84%20default_storage_engine%E3%80%82%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="有些系统变量是只读的，并不能设置值。" ID="mejDnFMCPp" _mubu_text="%3Cspan%3E%E6%9C%89%E4%BA%9B%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E6%98%AF%E5%8F%AA%E8%AF%BB%E7%9A%84%EF%BC%8C%E5%B9%B6%E4%B8%8D%E8%83%BD%E8%AE%BE%E7%BD%AE%E5%80%BC%E3%80%82%3C/span%3E" STYLE="fork">
              <node TEXT="比方说 version ，表示当前 MySQL 的版本。修改即没有意义，也不能修改。" ID="tdKnXT5jIs" _mubu_text="%3Cspan%3E%E6%AF%94%E6%96%B9%E8%AF%B4%20version%20%EF%BC%8C%3C/span%3E%3Cspan%20class=%22bold%22%3E%E8%A1%A8%E7%A4%BA%E5%BD%93%E5%89%8D%20MySQL%20%E7%9A%84%E7%89%88%E6%9C%AC%3C/span%3E%3Cspan%3E%E3%80%82%E4%BF%AE%E6%94%B9%E5%8D%B3%E6%B2%A1%E6%9C%89%E6%84%8F%E4%B9%89%EF%BC%8C%E4%B9%9F%E4%B8%8D%E8%83%BD%E4%BF%AE%E6%94%B9%E3%80%82%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="启动选项和系统变量的区别" ID="wKnt0vrDsy" _mubu_text="%3Cspan%3E%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%E5%92%8C%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E7%9A%84%E5%8C%BA%E5%88%AB%3C/span%3E" STYLE="fork">
            <node TEXT="大部分系统变量可以使用启动选项的方式设置" ID="e0xrIVlW5s" _mubu_text="%3Cspan%3E%E5%A4%A7%E9%83%A8%E5%88%86%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E5%8F%AF%E4%BB%A5%E4%BD%BF%E7%94%A8%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%E7%9A%84%E6%96%B9%E5%BC%8F%E8%AE%BE%E7%BD%AE%3C/span%3E" STYLE="fork"/>
            <node TEXT="部分系统变量是启动启动的时候生成，无法作为启动选项（比如：character_set_client）" ID="rLrMvwYZQh" _mubu_text="%3Cspan%3E%E9%83%A8%E5%88%86%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E6%98%AF%E5%90%AF%E5%8A%A8%E5%90%AF%E5%8A%A8%E7%9A%84%E6%97%B6%E5%80%99%E7%94%9F%E6%88%90%EF%BC%8C%E6%97%A0%E6%B3%95%E4%BD%9C%E4%B8%BA%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%EF%BC%88%E6%AF%94%E5%A6%82%EF%BC%9Acharacter_set_client%EF%BC%89%3C/span%3E" STYLE="fork"/>
            <node TEXT="有些启动选项也不是系统变量，比如 defaults-file" ID="uGllSuIrus" _mubu_text="%3Cspan%3E%E6%9C%89%E4%BA%9B%E5%90%AF%E5%8A%A8%E9%80%89%E9%A1%B9%E4%B9%9F%E4%B8%8D%E6%98%AF%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%EF%BC%8C%E6%AF%94%E5%A6%82%20defaults-file%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="状态变量" ID="OlAWx26NQm" _mubu_text="%3Cspan%3E%E7%8A%B6%E6%80%81%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork">
          <node TEXT="特点" ID="atXAMHiE0T" _mubu_text="%3Cspan%3E%E7%89%B9%E7%82%B9%3C/span%3E" STYLE="fork">
            <node TEXT="由于这些参数反应的是服务器自身的运行情况，所以不能由程序员设置，而是需要依靠应用程序设置" ID="U6PsJnpIaY" _mubu_text="%3Cspan%20class=%22bold%22%3E%E7%94%B1%E4%BA%8E%E8%BF%99%E4%BA%9B%E5%8F%82%E6%95%B0%E5%8F%8D%E5%BA%94%E7%9A%84%E6%98%AF%E6%9C%8D%E5%8A%A1%E5%99%A8%E8%87%AA%E8%BA%AB%E7%9A%84%E8%BF%90%E8%A1%8C%E6%83%85%E5%86%B5%EF%BC%8C%E6%89%80%E4%BB%A5%E4%B8%8D%E8%83%BD%E7%94%B1%E7%A8%8B%E5%BA%8F%E5%91%98%E8%AE%BE%E7%BD%AE%EF%BC%8C%E8%80%8C%E6%98%AF%E9%9C%80%E8%A6%81%E4%BE%9D%E9%9D%A0%E5%BA%94%E7%94%A8%E7%A8%8B%E5%BA%8F%E8%AE%BE%E7%BD%AE%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="查看状态变量" ID="r5NKZQrl9Z" _mubu_text="%3Cspan%3E%E6%9F%A5%E7%9C%8B%E7%8A%B6%E6%80%81%E5%8F%98%E9%87%8F%3C/span%3E" STYLE="fork">
            <node TEXT="SHOW [GLOBAL|SESSION] STATUS [LIKE 匹配的模式];" ID="aN6pX7s8ly" _mubu_text="%3Cspan%3ESHOW%20%5BGLOBAL%7CSESSION%5D%20STATUS%20%5BLIKE%20%E5%8C%B9%E9%85%8D%E7%9A%84%E6%A8%A1%E5%BC%8F%5D;%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
      </node>
      <node TEXT="字符集和编码" ID="issI135neP" _mubu_text="%3Cspan%3E%E5%AD%97%E7%AC%A6%E9%9B%86%E5%92%8C%E7%BC%96%E7%A0%81%3C/span%3E" STYLE="fork">
        <node TEXT="编码和解码" ID="955FF3sX09" _mubu_text="%3Cspan%3E%E7%BC%96%E7%A0%81%E5%92%8C%E8%A7%A3%E7%A0%81%3C/span%3E" STYLE="fork">
          <node TEXT="编码需要解决的问题" ID="yX1G45pJGZ" _mubu_text="%3Cspan%3E%E7%BC%96%E7%A0%81%E9%9C%80%E8%A6%81%E8%A7%A3%E5%86%B3%E7%9A%84%E9%97%AE%E9%A2%98%3C/span%3E" STYLE="fork">
            <node TEXT="字符是如何映射成为二进制数据的" ID="DfS1TUTT9G" _mubu_text="%3Cspan%3E%E5%AD%97%E7%AC%A6%E6%98%AF%E5%A6%82%E4%BD%95%E6%98%A0%E5%B0%84%E6%88%90%E4%B8%BA%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%95%B0%E6%8D%AE%E7%9A%84%3C/span%3E" STYLE="fork"/>
            <node TEXT="那些字符需要映射二进制的数据" ID="QoDXHbTMMY" _mubu_text="%3Cspan%3E%E9%82%A3%E4%BA%9B%E5%AD%97%E7%AC%A6%E9%9C%80%E8%A6%81%E6%98%A0%E5%B0%84%E4%BA%8C%E8%BF%9B%E5%88%B6%E7%9A%84%E6%95%B0%E6%8D%AE%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="编码和解码的本质" ID="YlRgOMa0s6" _mubu_text="%3Cspan%3E%E7%BC%96%E7%A0%81%E5%92%8C%E8%A7%A3%E7%A0%81%E7%9A%84%E6%9C%AC%E8%B4%A8%3C/span%3E" STYLE="fork">
            <node TEXT="数据的转换和读取" ID="pr2UEDyj75" _mubu_text="%3Cspan%3E%E6%95%B0%E6%8D%AE%E7%9A%84%E8%BD%AC%E6%8D%A2%E5%92%8C%E8%AF%BB%E5%8F%96%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="如何比较大小" ID="WYXnjFuVg5" _mubu_text="%3Cspan%3E%E5%A6%82%E4%BD%95%E6%AF%94%E8%BE%83%E5%A4%A7%E5%B0%8F%3C/span%3E" STYLE="fork">
            <node TEXT="将字符统一转为大写或者小写再进行二进制的比较" ID="siAR4QXXlR" _mubu_text="%3Cspan%3E%E5%B0%86%E5%AD%97%E7%AC%A6%E7%BB%9F%E4%B8%80%E8%BD%AC%E4%B8%BA%E5%A4%A7%E5%86%99%E6%88%96%E8%80%85%E5%B0%8F%E5%86%99%E5%86%8D%E8%BF%9B%E8%A1%8C%E4%BA%8C%E8%BF%9B%E5%88%B6%E7%9A%84%E6%AF%94%E8%BE%83%3C/span%3E" STYLE="fork"/>
            <node TEXT="大小写进行不同大小的编码规则编码" ID="g1bOchzc2D" _mubu_text="%3Cspan%3E%E5%A4%A7%E5%B0%8F%E5%86%99%E8%BF%9B%E8%A1%8C%E4%B8%8D%E5%90%8C%E5%A4%A7%E5%B0%8F%E7%9A%84%E7%BC%96%E7%A0%81%E8%A7%84%E5%88%99%E7%BC%96%E7%A0%81%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="字符集" ID="TiTPhNTfGR" _mubu_text="%3Cspan%3E%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork">
          <node TEXT="如何查看字符集" ID="fWEqlVIbXB" _mubu_text="%3Cspan%3E%E5%A6%82%E4%BD%95%E6%9F%A5%E7%9C%8B%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork">
            <node TEXT="基础命令" ID="OuQwKHbhef" _mubu_text="%3Cspan%3E%E5%9F%BA%E7%A1%80%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
              <node TEXT="show (character set|charset) [like 匹配模式]" ID="AhI2CFSSMK" _mubu_text="%3Cspan%20class=%22bold%22%3Eshow%20(character%20set%7Ccharset)%20%5Blike%20%E5%8C%B9%E9%85%8D%E6%A8%A1%E5%BC%8F%5D%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="案例" ID="say5zlOQ6v" _mubu_text="%3Cspan%3E%E6%A1%88%E4%BE%8B%3C/span%3E" STYLE="fork">
              <node TEXT="show charset like &apos;big%&apos;;" ID="XyY4EdH0y4" _mubu_text="%3Cspan%3Eshow%20charset%20like%20&apos;big%25&apos;;%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="常见字符集" ID="aakENwWUAk" _mubu_text="%3Cspan%3E%E5%B8%B8%E8%A7%81%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork">
            <node TEXT="ASCII 字符集" ID="ZY7Vnjr9k9" _mubu_text="%3Cspan%20class=%22bold%22%3EASCII%20%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork">
              <node TEXT="共收录128个字符，包括空格、标点符号、数字、大小写字母和一些不可见字符，一共也就128个字符，所以可以直接用一个字节表示" ID="fcUQXWIA6b" _mubu_text="%3Cspan%3E%E5%85%B1%E6%94%B6%E5%BD%95128%E4%B8%AA%E5%AD%97%E7%AC%A6%EF%BC%8C%E5%8C%85%E6%8B%AC%E7%A9%BA%E6%A0%BC%E3%80%81%E6%A0%87%E7%82%B9%E7%AC%A6%E5%8F%B7%E3%80%81%E6%95%B0%E5%AD%97%E3%80%81%E5%A4%A7%E5%B0%8F%E5%86%99%E5%AD%97%E6%AF%8D%E5%92%8C%E4%B8%80%E4%BA%9B%E4%B8%8D%E5%8F%AF%E8%A7%81%E5%AD%97%E7%AC%A6%EF%BC%8C%E4%B8%80%E5%85%B1%E4%B9%9F%E5%B0%B1128%E4%B8%AA%E5%AD%97%E7%AC%A6%EF%BC%8C%E6%89%80%E4%BB%A5%E5%8F%AF%E4%BB%A5%E7%9B%B4%E6%8E%A5%E7%94%A8%3C/span%3E%3Cspan%20class=%22bold%22%3E%E4%B8%80%E4%B8%AA%E5%AD%97%E8%8A%82%E8%A1%A8%E7%A4%BA%3C/span%3E" STYLE="fork">
                <node TEXT="&apos;L&apos; -&gt; 01001100(十六进制:0x4C，十进制:76)" ID="EHVhTUM9Rr" _mubu_text="%3Cspan%3E&apos;L&apos;%20-&amp;gt;%2001001100(%E5%8D%81%E5%85%AD%E8%BF%9B%E5%88%B6:0x4C%EF%BC%8C%E5%8D%81%E8%BF%9B%E5%88%B6:76)%3C/span%3E" STYLE="fork"/>
                <node TEXT="&apos;M&apos; -&gt; 01001101(十六进制:0x4D，十进制:77)" ID="aBKi0rYqwW" _mubu_text="%3Cspan%3E&apos;M&apos;%20-&amp;gt;%2001001101(%E5%8D%81%E5%85%AD%E8%BF%9B%E5%88%B6:0x4D%EF%BC%8C%E5%8D%81%E8%BF%9B%E5%88%B6:77)%3C/span%3E" STYLE="fork"/>
              </node>
            </node>
            <node TEXT="ISO 8859-1 字符集" ID="s1B5YpW8q2" _mubu_text="%3Cspan%20class=%22bold%22%3EISO%208859-1%20%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork">
              <node TEXT="一共是256个字符，主要是在ASCII 字符集字符集的基础上扩展了128个字符，这个字符集也被称为：latin1" ID="0STuqqG6Mx" _mubu_text="%3Cspan%3E%E4%B8%80%E5%85%B1%E6%98%AF256%E4%B8%AA%E5%AD%97%E7%AC%A6%EF%BC%8C%E4%B8%BB%E8%A6%81%E6%98%AF%E5%9C%A8ASCII%20%E5%AD%97%E7%AC%A6%E9%9B%86%E5%AD%97%E7%AC%A6%E9%9B%86%E7%9A%84%E5%9F%BA%E7%A1%80%E4%B8%8A%E6%89%A9%E5%B1%95%E4%BA%86128%E4%B8%AA%E5%AD%97%E7%AC%A6%EF%BC%8C%E8%BF%99%E4%B8%AA%E5%AD%97%E7%AC%A6%E9%9B%86%E4%B9%9F%E8%A2%AB%E7%A7%B0%E4%B8%BA%EF%BC%9Alatin1%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="GB2312" ID="cvj1ez7iga" _mubu_text="%3Cspan%20class=%22bold%22%3EGB2312%3C/span%3E" STYLE="fork">
              <node TEXT="收录了汉字以及拉丁字母、希腊字母、日文平假名及片假名字母、俄语西里尔字母等多个语言" ID="aC6qrb8spv" _mubu_text="%3Cspan%3E%E6%94%B6%E5%BD%95%E4%BA%86%E6%B1%89%E5%AD%97%E4%BB%A5%E5%8F%8A%E6%8B%89%E4%B8%81%E5%AD%97%E6%AF%8D%E3%80%81%E5%B8%8C%E8%85%8A%E5%AD%97%E6%AF%8D%E3%80%81%E6%97%A5%E6%96%87%E5%B9%B3%E5%81%87%E5%90%8D%E5%8F%8A%E7%89%87%E5%81%87%E5%90%8D%E5%AD%97%E6%AF%8D%E3%80%81%E4%BF%84%E8%AF%AD%E8%A5%BF%E9%87%8C%E5%B0%94%E5%AD%97%E6%AF%8D%E7%AD%89%E5%A4%9A%E4%B8%AA%E8%AF%AD%E8%A8%80%3C/span%3E" STYLE="fork">
                <node TEXT="收录汉字6763个， 其他文字符号682个，同时这种字符集又兼容 ASCII 字符集" ID="4Myxx1TpYd" _mubu_text="%3Cspan%3E%E6%94%B6%E5%BD%95%E6%B1%89%E5%AD%976763%E4%B8%AA%EF%BC%8C%20%E5%85%B6%E4%BB%96%E6%96%87%E5%AD%97%E7%AC%A6%E5%8F%B7682%E4%B8%AA%EF%BC%8C%E5%90%8C%E6%97%B6%E8%BF%99%E7%A7%8D%E5%AD%97%E7%AC%A6%E9%9B%86%E5%8F%88%E5%85%BC%E5%AE%B9%20ASCII%20%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork"/>
                <node TEXT="特殊的编码方式" ID="yu86aMQ3nR" _mubu_text="%3Cspan%3E%E7%89%B9%E6%AE%8A%E7%9A%84%E7%BC%96%E7%A0%81%E6%96%B9%E5%BC%8F%3C/span%3E" STYLE="fork">
                  <node TEXT="ASCII 字符集：按照ASCII 字符集的规则使用一个字节" ID="oEkioxc5DU" _mubu_text="%3Cspan%20class=%22bold%22%3EASCII%20%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E%3Cspan%3E%EF%BC%9A%E6%8C%89%E7%85%A7ASCII%20%E5%AD%97%E7%AC%A6%E9%9B%86%E7%9A%84%E8%A7%84%E5%88%99%E4%BD%BF%E7%94%A8%E4%B8%80%E4%B8%AA%E5%AD%97%E8%8A%82%3C/span%3E" STYLE="fork"/>
                  <node TEXT="其他的GB2312支持的字符集：使用两个字节进行编码" ID="YUTkZmG8yU" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%85%B6%E4%BB%96%E7%9A%84GB2312%E6%94%AF%E6%8C%81%E7%9A%84%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E%3Cspan%3E%EF%BC%9A%E4%BD%BF%E7%94%A8%E4%B8%A4%E4%B8%AA%E5%AD%97%E8%8A%82%E8%BF%9B%E8%A1%8C%E7%BC%96%E7%A0%81%3C/span%3E" STYLE="fork"/>
                  <node TEXT="出现ASCII和其他字符集混用：变长编码方式" ID="gJAShfc9ZQ" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%87%BA%E7%8E%B0ASCII%E5%92%8C%E5%85%B6%E4%BB%96%E5%AD%97%E7%AC%A6%E9%9B%86%E6%B7%B7%E7%94%A8%EF%BC%9A%E5%8F%98%E9%95%BF%E7%BC%96%E7%A0%81%E6%96%B9%E5%BC%8F%3C/span%3E" STYLE="fork"/>
                </node>
              </node>
            </node>
            <node TEXT="GBK 字符集：" ID="eDG2YvsWhh" _mubu_text="%3Cspan%20class=%22bold%22%3EGBK%20%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E%3Cspan%3E%EF%BC%9A%3C/span%3E" STYLE="fork">
              <node TEXT="对于GB2312进行字符集的扩展" ID="xpRKIWyc1H" _mubu_text="%3Cspan%3E%E5%AF%B9%E4%BA%8EGB2312%E8%BF%9B%E8%A1%8C%E5%AD%97%E7%AC%A6%E9%9B%86%E7%9A%84%E6%89%A9%E5%B1%95%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="UTF8 字符集" ID="hLAWdKWtFQ" _mubu_text="%3Cspan%20class=%22bold%22%3EUTF8%20%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork">
              <node TEXT="UTF-8规定按照1-4个字节的变长编码方式进行编码，UTF8同样也兼容了ASCII的字符集" ID="5ActHwajSR" _mubu_text="%3Cspan%3EUTF-8%E8%A7%84%E5%AE%9A%E6%8C%89%E7%85%A71-4%E4%B8%AA%E5%AD%97%E8%8A%82%E7%9A%84%3C/span%3E%3Cspan%20class=%22bold%22%3E%E5%8F%98%E9%95%BF%E7%BC%96%E7%A0%81%E6%96%B9%E5%BC%8F%3C/span%3E%3Cspan%3E%E8%BF%9B%E8%A1%8C%E7%BC%96%E7%A0%81%EF%BC%8CUTF8%E5%90%8C%E6%A0%B7%E4%B9%9F%E5%85%BC%E5%AE%B9%E4%BA%86ASCII%E7%9A%84%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
        </node>
        <node TEXT="比较规则" ID="DXHFeL5mP9" _mubu_text="%3Cspan%3E%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork">
          <node TEXT="比较规则的规律" ID="uNj4yQVW5b" _mubu_text="%3Cspan%3E%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E7%9A%84%E8%A7%84%E5%BE%8B%3C/span%3E" STYLE="fork">
            <node TEXT="前缀匹配" ID="2eZY3F3oCi" _mubu_text="%3Cspan%3E%E5%89%8D%E7%BC%80%E5%8C%B9%E9%85%8D%3C/span%3E" STYLE="fork">
              <node TEXT="比如以utf-8开头" ID="QmjSF9x6YW" _mubu_text="%3Cspan%3E%E6%AF%94%E5%A6%82%E4%BB%A5utf-8%E5%BC%80%E5%A4%B4%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="后缀匹配" ID="JK940mfvUz" _mubu_text="%3Cspan%3E%E5%90%8E%E7%BC%80%E5%8C%B9%E9%85%8D%3C/span%3E" STYLE="fork">
              <node TEXT="和不同国家的语言有关，比如utf_polish_ci是波兰语" ID="PRl8RjNRjn" _mubu_text="%3Cspan%3E%E5%92%8C%E4%B8%8D%E5%90%8C%E5%9B%BD%E5%AE%B6%E7%9A%84%E8%AF%AD%E8%A8%80%E6%9C%89%E5%85%B3%EF%BC%8C%E6%AF%94%E5%A6%82utf_polish_ci%E6%98%AF%E6%B3%A2%E5%85%B0%E8%AF%AD%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="名称后缀" ID="s1tbsQfmnD" _mubu_text="%3Cspan%3E%E5%90%8D%E7%A7%B0%E5%90%8E%E7%BC%80%3C/span%3E" STYLE="fork">
              <node TEXT="名称后缀意味着该比较规则是否区分语言中的重音、大小写啥，比如ci代表的是不区分大小写" ID="SdAhLXCery" _mubu_text="%3Cspan%3E%E5%90%8D%E7%A7%B0%E5%90%8E%E7%BC%80%E6%84%8F%E5%91%B3%E7%9D%80%E8%AF%A5%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E6%98%AF%E5%90%A6%E5%8C%BA%E5%88%86%E8%AF%AD%E8%A8%80%E4%B8%AD%E7%9A%84%E9%87%8D%E9%9F%B3%E3%80%81%E5%A4%A7%E5%B0%8F%E5%86%99%E5%95%A5%EF%BC%8C%E6%AF%94%E5%A6%82ci%E4%BB%A3%E8%A1%A8%E7%9A%84%E6%98%AF%E4%B8%8D%E5%8C%BA%E5%88%86%E5%A4%A7%E5%B0%8F%E5%86%99%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="比较规则查看" ID="mKflpy5Wlm" _mubu_text="%3Cspan%3E%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E6%9F%A5%E7%9C%8B%3C/span%3E" STYLE="fork">
            <node TEXT="基础命令" ID="ip8lto4rct" _mubu_text="%3Cspan%3E%E5%9F%BA%E7%A1%80%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
              <node TEXT="show collation [like 匹配模式]" ID="0PyUo1htld" _mubu_text="%3Cspan%20class=%22bold%22%3Eshow%20collation%20%5Blike%20%E5%8C%B9%E9%85%8D%E6%A8%A1%E5%BC%8F%5D%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="案例" ID="MmVXUrD0ys" _mubu_text="%3Cspan%3E%E6%A1%88%E4%BE%8B%3C/span%3E" STYLE="fork">
              <node TEXT="show collation like &apos;utf_%&apos;;" ID="j0zWbQ8H2h" _mubu_text="%3Cspan%20class=%22bold%22%3Eshow%20collation%20like%20&apos;utf_%25&apos;;%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
          <node TEXT="特点" ID="M4XMaoHHfx" _mubu_text="%3Cspan%3E%E7%89%B9%E7%82%B9%3C/span%3E" STYLE="fork">
            <node TEXT="每种字符集对应若干种比较规则，每种字符集都有一种默认的比较规则" ID="Ipxu966jRK" _mubu_text="%3Cspan%20class=%22bold%22%3E%E6%AF%8F%E7%A7%8D%E5%AD%97%E7%AC%A6%E9%9B%86%E5%AF%B9%E5%BA%94%E8%8B%A5%E5%B9%B2%E7%A7%8D%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%EF%BC%8C%E6%AF%8F%E7%A7%8D%E5%AD%97%E7%AC%A6%E9%9B%86%E9%83%BD%E6%9C%89%E4%B8%80%E7%A7%8D%E9%BB%98%E8%AE%A4%E7%9A%84%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork"/>
          </node>
        </node>
        <node TEXT="字符集和比较规则级别介绍" ID="sPNTGFYgsa" _mubu_text="%3Cspan%3E%E5%AD%97%E7%AC%A6%E9%9B%86%E5%92%8C%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E7%BA%A7%E5%88%AB%E4%BB%8B%E7%BB%8D%3C/span%3E" STYLE="fork">
          <node TEXT="简单介绍" ID="KASth3W18c" _mubu_text="%3Cspan%3E%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D%3C/span%3E" STYLE="fork">
            <node TEXT="服务器级别：启动的时候根据配置或者数据库默认规则生成字符集和比较规则" ID="Rrw2uqleF9" _mubu_text="%3Cspan%20class=%22bold%22%3E%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BA%A7%E5%88%AB%3C/span%3E%3Cspan%3E%EF%BC%9A%E5%90%AF%E5%8A%A8%E7%9A%84%E6%97%B6%E5%80%99%E6%A0%B9%E6%8D%AE%E9%85%8D%E7%BD%AE%E6%88%96%E8%80%85%E6%95%B0%E6%8D%AE%E5%BA%93%E9%BB%98%E8%AE%A4%E8%A7%84%E5%88%99%E7%94%9F%E6%88%90%E5%AD%97%E7%AC%A6%E9%9B%86%E5%92%8C%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork"/>
            <node TEXT="数据库级别：数据库的系统变量为只读，修改数据库字符集和比较规则需要保证数据兼容。" ID="LA20wSavf5" _mubu_text="%3Cspan%20class=%22bold%22%3E%E6%95%B0%E6%8D%AE%E5%BA%93%E7%BA%A7%E5%88%AB%3C/span%3E%3Cspan%3E%EF%BC%9A%E6%95%B0%E6%8D%AE%E5%BA%93%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%8F%98%E9%87%8F%E4%B8%BA%E5%8F%AA%E8%AF%BB%EF%BC%8C%E4%BF%AE%E6%94%B9%E6%95%B0%E6%8D%AE%E5%BA%93%E5%AD%97%E7%AC%A6%E9%9B%86%E5%92%8C%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E9%9C%80%E8%A6%81%E4%BF%9D%E8%AF%81%E6%95%B0%E6%8D%AE%E5%85%BC%E5%AE%B9%E3%80%82%3C/span%3E" STYLE="fork"/>
            <node TEXT="表级别：表级别比较规则默认跟随数据库，修改字符集同样需要保证数据兼容，否则会报错。" ID="n1reNYGb5R" _mubu_text="%3Cspan%20class=%22bold%22%3E%E8%A1%A8%E7%BA%A7%E5%88%AB%3C/span%3E%3Cspan%3E%EF%BC%9A%E8%A1%A8%E7%BA%A7%E5%88%AB%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E9%BB%98%E8%AE%A4%E8%B7%9F%E9%9A%8F%E6%95%B0%E6%8D%AE%E5%BA%93%EF%BC%8C%E4%BF%AE%E6%94%B9%E5%AD%97%E7%AC%A6%E9%9B%86%E5%90%8C%E6%A0%B7%E9%9C%80%E8%A6%81%E4%BF%9D%E8%AF%81%E6%95%B0%E6%8D%AE%E5%85%BC%E5%AE%B9%EF%BC%8C%E5%90%A6%E5%88%99%E4%BC%9A%E6%8A%A5%E9%94%99%E3%80%82%3C/span%3E" STYLE="fork"/>
            <node TEXT="列级别：不建议关注，只需了解即可，通常没有人会去单独改某一列的字符集" ID="Qpkryf0GL7" _mubu_text="%3Cspan%20class=%22bold%22%3E%E5%88%97%E7%BA%A7%E5%88%AB%3C/span%3E%3Cspan%3E%EF%BC%9A%E4%B8%8D%E5%BB%BA%E8%AE%AE%E5%85%B3%E6%B3%A8%EF%BC%8C%E5%8F%AA%E9%9C%80%E4%BA%86%E8%A7%A3%E5%8D%B3%E5%8F%AF%EF%BC%8C%E9%80%9A%E5%B8%B8%E6%B2%A1%E6%9C%89%E4%BA%BA%E4%BC%9A%E5%8E%BB%E5%8D%95%E7%8B%AC%E6%94%B9%E6%9F%90%E4%B8%80%E5%88%97%E7%9A%84%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork"/>
          </node>
          <node TEXT="比较级别" ID="QlXhYqVbuN" _mubu_text="%3Cspan%3E%E6%AF%94%E8%BE%83%E7%BA%A7%E5%88%AB%3C/span%3E" STYLE="fork">
            <node TEXT="服务器级别规则" ID="4AWw4csRLw" _mubu_text="%3Cspan%3E%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BA%A7%E5%88%AB%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork">
              <node TEXT="Character_set_server：服务器级别的字符集" ID="LVfDmy08Eu" _mubu_text="%3Cspan%3ECharacter_set_server%EF%BC%9A%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BA%A7%E5%88%AB%E7%9A%84%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork"/>
              <node TEXT="Collation_server：服务器级别的比较规则" ID="e4iAkjyVs1" _mubu_text="%3Cspan%3ECollation_server%EF%BC%9A%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BA%A7%E5%88%AB%E7%9A%84%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork"/>
              <node TEXT="命令" ID="KkHbQM34VV" _mubu_text="%3Cspan%3E%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
                <node TEXT="show variables like &apos;character_set_server&apos;;" ID="flApOkhyOL" _mubu_text="%3Cspan%3Eshow%20variables%20like%20&apos;character_set_server&apos;;%3C/span%3E" STYLE="fork"/>
                <node TEXT="SHOW VARIABLES LIKE &apos;collation_server&apos;;" ID="06RaeWcFlg" _mubu_text="%3Cspan%3ESHOW%20VARIABLES%20LIKE%20&apos;collation_server&apos;;%3C/span%3E" STYLE="fork"/>
              </node>
              <node TEXT="改动方式" ID="Ck3FFFSnXN" _mubu_text="%3Cspan%3E%E6%94%B9%E5%8A%A8%E6%96%B9%E5%BC%8F%3C/span%3E" STYLE="fork">
                <node TEXT="修改配置文件：" ID="sG76Lf5uNj" _mubu_text="%3Cspan%3E%E4%BF%AE%E6%94%B9%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%EF%BC%9A%3C/span%3E" STYLE="fork"/>
              </node>
            </node>
            <node TEXT="数据库级别规则" ID="vEStAwAxZ8" _mubu_text="%3Cspan%3E%E6%95%B0%E6%8D%AE%E5%BA%93%E7%BA%A7%E5%88%AB%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork">
              <node TEXT="创建命令" ID="4P6Ppu0ow3" _mubu_text="%3Cspan%3E%E5%88%9B%E5%BB%BA%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
                <node TEXT="create database 数据库名称" ID="xcOzCbArNJ" _mubu_text="%3Cspan%3Ecreate%20database%20%E6%95%B0%E6%8D%AE%E5%BA%93%E5%90%8D%E7%A7%B0%3C/span%3E" STYLE="fork">
                  <node TEXT="[[DEFAULT] CHARACTER SET 字符集名称]" ID="Kto3w5IMr4" _mubu_text="%3Cspan%3E%5B%5BDEFAULT%5D%20CHARACTER%20SET%20%E5%AD%97%E7%AC%A6%E9%9B%86%E5%90%8D%E7%A7%B0%5D%3C/span%3E" STYLE="fork"/>
                  <node TEXT="[[DEFAULT] COLLATE 比较规则名称];" ID="iGicpPGRFN" _mubu_text="%3Cspan%3E%5B%5BDEFAULT%5D%20COLLATE%20%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E5%90%8D%E7%A7%B0%5D;%3C/span%3E" STYLE="fork"/>
                </node>
                <node TEXT="alter database 数据库名" ID="Kxla4UMqrh" _mubu_text="%3Cspan%3Ealter%20database%20%E6%95%B0%E6%8D%AE%E5%BA%93%E5%90%8D%3C/span%3E" STYLE="fork">
                  <node TEXT="[[DEFAULT] CHARACTER SET 字符集名称]" ID="dgLN7tDN5I" _mubu_text="%3Cspan%3E%5B%5BDEFAULT%5D%20CHARACTER%20SET%20%E5%AD%97%E7%AC%A6%E9%9B%86%E5%90%8D%E7%A7%B0%5D%3C/span%3E" STYLE="fork"/>
                  <node TEXT="[[DEFAULT] COLLATE 比较规则名称];" ID="HJ7EVoQm5t" _mubu_text="%3Cspan%3E%5B%5BDEFAULT%5D%20COLLATE%20%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E5%90%8D%E7%A7%B0%5D;%3C/span%3E" STYLE="fork"/>
                </node>
              </node>
              <node TEXT="查看命令" ID="n4AyjOQCXc" _mubu_text="%3Cspan%3E%E6%9F%A5%E7%9C%8B%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
                <node TEXT="show variables like &apos;character_set_database&apos;;" ID="RtK8R3yqBw" _mubu_text="%3Cspan%3Eshow%20variables%20like%20&apos;character_set_database&apos;;%3C/span%3E" STYLE="fork"/>
                <node TEXT="show variables LIKE &apos;collation_database&apos;;" ID="Q0eGHCpXgr" _mubu_text="%3Cspan%3Eshow%20variables%20LIKE%20&apos;collation_database&apos;;%3C/span%3E" STYLE="fork"/>
              </node>
              <node TEXT="character_set_database：当前数据库字符集" ID="eDfuMMCnc3" _mubu_text="%3Cspan%3Echaracter_set_database%EF%BC%9A%3C/span%3E%3Cspan%20class=%22bold%22%3E%E5%BD%93%E5%89%8D%E6%95%B0%E6%8D%AE%E5%BA%93%3C/span%3E%3Cspan%3E%E5%AD%97%E7%AC%A6%E9%9B%86%3C/span%3E" STYLE="fork"/>
              <node TEXT="Collation_database：当前数据库比较规则" ID="DAHD4zSFRc" _mubu_text="%3Cspan%3ECollation_database%EF%BC%9A%3C/span%3E%3Cspan%20class=%22bold%22%3E%E5%BD%93%E5%89%8D%E6%95%B0%E6%8D%AE%E5%BA%93%3C/span%3E%3Cspan%3E%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork"/>
            </node>
            <node TEXT="表级别规则" ID="v8YFnRfsgk" _mubu_text="%3Cspan%3E%E8%A1%A8%E7%BA%A7%E5%88%AB%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork">
              <node TEXT="CREATE TABLE 表名 (列的信息) [[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称]]" ID="j5m1bMQNO0" _mubu_text="%3Cspan%3ECREATE%20TABLE%20%E8%A1%A8%E5%90%8D%20(%E5%88%97%E7%9A%84%E4%BF%A1%E6%81%AF)%20%5B%5BDEFAULT%5D%20CHARACTER%20SET%20%E5%AD%97%E7%AC%A6%E9%9B%86%E5%90%8D%E7%A7%B0%5D%20%5BCOLLATE%20%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E5%90%8D%E7%A7%B0%5D%5D%3C/span%3E" STYLE="fork"/>
              <node TEXT="ALTER TABLE 表名 [[DEFAULT] CHARACTER SET 字符集名称] [COLLATE 比较规则名称]" ID="3Ay2GecPg0" _mubu_text="%3Cspan%3EALTER%20TABLE%20%E8%A1%A8%E5%90%8D%20%5B%5BDEFAULT%5D%20CHARACTER%20SET%20%E5%AD%97%E7%AC%A6%E9%9B%86%E5%90%8D%E7%A7%B0%5D%20%5BCOLLATE%20%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E5%90%8D%E7%A7%B0%5D%3C/span%3E" STYLE="fork"/>
              <node TEXT="查看命令" ID="bJTigdrlVS" _mubu_text="%3Cspan%3E%E6%9F%A5%E7%9C%8B%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
                <node TEXT="show table status from &apos;数据库名称&apos; like &apos;数据表名称&apos;" ID="3WYlTpqBpU" _mubu_text="%3Cspan%3Eshow%20table%20status%20from%20&apos;%E6%95%B0%E6%8D%AE%E5%BA%93%E5%90%8D%E7%A7%B0&apos;%20like%20&apos;%E6%95%B0%E6%8D%AE%E8%A1%A8%E5%90%8D%E7%A7%B0&apos;%3C/span%3E" STYLE="fork"/>
                <node TEXT="SELECT TABLE_SCHEMA, TABLE_NAME,TABLE_COLLATION FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = &apos;数据表名称&apos;" ID="nAbqOgwreg" _mubu_text="%3Cspan%3ESELECT%20TABLE_SCHEMA,%20TABLE_NAME,TABLE_COLLATION%20FROM%20INFORMATION_SCHEMA.TABLES%20where%20TABLE_NAME%20=%20&apos;%E6%95%B0%E6%8D%AE%E8%A1%A8%E5%90%8D%E7%A7%B0&apos;%3C/span%3E" STYLE="fork"/>
              </node>
            </node>
            <node TEXT="列级别规则" ID="5vb7QP6Rhs" _mubu_text="%3Cspan%3E%E5%88%97%E7%BA%A7%E5%88%AB%E8%A7%84%E5%88%99%3C/span%3E" STYLE="fork">
              <node TEXT="创建命令" ID="brzThzyuQ4" _mubu_text="%3Cspan%3E%E5%88%9B%E5%BB%BA%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork">
                <node TEXT="" ID="85tMCLQ7gg" _mubu_text="" STYLE="fork">
                  <node TEXT="CREATE TABLE 表名(列名 字符串类型 [CHARACTER SET 字符集名称] [COLLATE 比较规则名称], 其他列...);" ID="129DvZghDK" _mubu_text="%3Cspan%3ECREATE%20TABLE%20%E8%A1%A8%E5%90%8D(%E5%88%97%E5%90%8D%20%E5%AD%97%E7%AC%A6%E4%B8%B2%E7%B1%BB%E5%9E%8B%20%5BCHARACTER%20SET%20%E5%AD%97%E7%AC%A6%E9%9B%86%E5%90%8D%E7%A7%B0%5D%20%5BCOLLATE%20%E6%AF%94%E8%BE%83%E8%A7%84%E5%88%99%E5%90%8D%E7%A7%B0%5D,%20%E5%85%B6%E4%BB%96%E5%88%97...);%3C/span%3E" STYLE="fork"/>
                  <node TEXT="" ID="oqvqoAXLUT" _mubu_text="" STYLE="fork"/>
                </node>
              </node>
              <node TEXT="查看命令" ID="UHIOWqi4a8" _mubu_text="%3Cspan%3E%E6%9F%A5%E7%9C%8B%E5%91%BD%E4%BB%A4%3C/span%3E" STYLE="fork"/>
            </node>
          </node>
        </node>
      </node>
    </node>
  </node>
</map>