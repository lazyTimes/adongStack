# 深入理解JVM虚拟机 - 自我编译JDK

《深入理解JVM虚拟机》看过了好几遍了，对于编译一个JDK源码有很强的冲动。这里主要实战使用<font color='red'>**阿里云**</font>进行编译实战

+ 为什么使用阿里云？
  + 个人电脑奋斗四年了，装虚拟机莫名其妙的死机
  + 阿里云带宽1M，只能用来干些LInux学习的工作

+ 参考博客：https://juejin.im/post/5c6b9a476fb9a049c30bcebd

## JDK源码下载 - openJDK7u75

+ 地址：https://download.java.net/openjdk/jdk7u75/ri/openjdk-7u75-src-b13-18_dec_2014.zip

## Bootstrap JDK 

+ 编译OpenJDK7需要 Bootstrap JDK U14 之后的版本
+ 地址：https://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html
  + 下载 `linux.tag.gz包`
+ 有条件尽量科学上网下载比较慢



## Apach Ant 1.7.1版本

+ 地址：https://ant.apache.org/bindownload.cgi

+ 还需要一个apach ant 1.7.1 版本
+ 这里选择了: 1.9.14版本



## 前置依赖：

+ OpenJDK要用到很多的gcc，java，c的库函数，需要进行前置准备

```shell
yum -y install build-essential gawk m4 openjdk6-jdk libasound2-print-dev binutils libmotif3 libmotif-dev ant
```

```shell
yum install libX* #有可能会缺失的库，先提前安装
```





## 首次编译

```shell
# 进入到openjdk的目录
cd openjdk所在目录
# 解压
unzip openjdk
# 编译
cd open jdk
# 第一次编译，输出到对应文件
make sanity > error.txt


```

+ 不出所料，编译失败了，我们可以根据错误日志来进行调整

+ 根据错误，整理一下错误点
+ 下面参考书籍的内容进行设置

## 设置环境变量

+ gcc 4.3 版本以上

+ 必须设置两个

  + LANG：编译语言
  + ALT_BOOTDIR：Bootstrap JDK 1.7 的版本

+ 设置环境变量

  ```shell
  export LANG=C
  export ALT_BOOTDIR=/usr/local/software/openjdk/jdk1.7.0_80
  ```

+ 去掉原本的JDK环境变量

  ```shell
  unset JAVA_HOME
  unset CLASSPATH
  ```

  

## OpenJDK 错误处理

### 错误1： 缺少打印 Cups 依赖

错误信息

```shell
ERROR: You do not have access to valid Cups header files. 
       Please check your access to 
           /usr/include/cups/cups.h 
       and/or check your value of ALT_CUPS_HEADERS_PATH, 
       CUPS is frequently pre-installed on many systems, 
       or may be downloaded from http://www.cups.org
```

处理方式：

缺少`cups`打印框架，解决：

1. 可以根据如下命令查找

`yum search cups` 查找对应依赖

```
=========================================== N/S matched: cups ============================================
apcupsd-cgi.x86_64 : Web interface for apcupsd
apcupsd-gui.x86_64 : GUI interface for apcupsd
bluez-cups.x86_64 : CUPS printer backend for Bluetooth printers
cups.x86_64 : CUPS printing system
cups-bjnp.x86_64 : CUPS backend for the Canon BJNP network printers
cups-client.x86_64 : CUPS printing system - client programs
cups-devel.i686 : CUPS printing system - development environment
cups-devel.x86_64 : CUPS printing system - development environment
cups-filesystem.noarch : CUPS printing system - directory layout
cups-filters.x86_64 : OpenPrinting CUPS filters and backends
cups-filters-devel.i686 : OpenPrinting CUPS filters and backends - development environment
cups-filters-devel.x86_64 : OpenPrinting CUPS filters and backends - development environment
cups-filters-libs.i686 : OpenPrinting CUPS filters and backends - cupsfilters and fontembed libraries
cups-filters-libs.x86_64 : OpenPrinting CUPS filters and backends - cupsfilters and fontembed libraries
cups-ipptool.x86_64 : CUPS printing system - tool for performing IPP requests
cups-libs.x86_64 : CUPS printing system - libraries
cups-libs.i686 : CUPS printing system - libraries
cups-lpd.x86_64 : CUPS printing system - lpd emulation
cups-pdf.x86_64 : Extension for creating pdf-Files with CUPS
cups-x2go.noarch : CUPS backend for printing from X2Go
dymo-cups-drivers.x86_64 : DYMO LabelWriter Drivers for CUPS
ghostscript-cups.x86_64 : CUPS filter for interpreting PostScript and PDF
gutenprint-cups.x86_64 : CUPS drivers for Canon, Epson, HP and compatible printers
perl-Net-CUPS.x86_64 : Perl bindings to the CUPS C API Interface
python-cups.x86_64 : Python bindings for CUPS
python-cups-doc.x86_64 : Documentation for python-cups
python3-cups-doc.x86_64 : Documentation for python-cups
python34-cups.x86_64 : Python 3 bindings for CUPS API, known as pycups
python36-cups.x86_64 : Python 3 bindings for CUPS API, known as pycups
apcupsd.x86_64 : APC UPS Power Control Daemon
cups-pk-helper.x86_64 : A helper that makes system-config-printer use PolicyKit
foomatic-filters.x86_64 : CUPS print filters for the foomatic package
samba-krb5-printing.x86_64 : Samba CUPS backend for printing with Kerberos

  Name and summary matches only, use "search all" for everything.
```

2. 安装Cups

`yum install cups-devel.x86_64`



### 错误2： 缺少 Freetype 依赖

报错情况：

```
ERROR: FreeType version  2.3.0  or higher is required. 
 make[2]: 进入目录“/usr/local/software/openjdk/jdk/make/tools/freetypecheck”
/bin/mkdir -p /usr/local/software/openjdk/build/linux-amd64/btbins
rm -f /usr/local/software/openjdk/build/linux-amd64/btbins/freetype_versioncheck
make[2]: 离开目录“/usr/local/software/openjdk/jdk/make/tools/freetypecheck”
Failed to build freetypecheck.  
```

处理方式：

1. `yum search freetype`

```
========================================= N/S matched: freetype ==========================================
freetype-demos.x86_64 : A collection of FreeType demos
freetype-devel.i686 : FreeType development libraries and header files
freetype-devel.x86_64 : FreeType development libraries and header files
mingw32-freetype-static.noarch : Static version of the MinGW Windows Freetype library
mingw64-freetype-static.noarch : Static version of the MinGW Windows Freetype library
python-freetype.noarch : Freetype python bindings
freetype.x86_64 : A free and portable font rendering engine
freetype.i686 : A free and portable font rendering engine
ftgl.x86_64 : OpenGL frontend to Freetype 2
mingw32-freetype.noarch : Free and portable font rendering engine
mingw64-freetype.noarch : Free and portable font rendering engine

```

2. 执行命令`yum install freetype-devel.x86_64 -y`

### 错误3：缺少声卡Alsa依赖，需要安装

错误信息

```
ERROR: You seem to not have installed ALSA 0.9.1 or higher. 
       Please install ALSA (drivers and lib). You can download the 
       source distribution from http://www.alsa-project.org or go to 
       http://www.freshrpms.net/docs/alsa/ for precompiled RPM packages. 
```

处理方式：

1. `yum search alsa`

```

 * updates: mirrors.aliyun.com
======================================== N/S matched: alsa ========================================
alsa-firmware.noarch : Firmware for several ALSA-supported sound cards
alsa-lib.x86_64 : The Advanced Linux Sound Architecture (ALSA) library
alsa-lib.i686 : The Advanced Linux Sound Architecture (ALSA) library
alsa-lib-devel.i686 : Development files from the ALSA library
alsa-lib-devel.x86_64 : Development files from the ALSA library
alsa-plugins-arcamav.i686 : Arcam AV amplifier plugin for ALSA
alsa-plugins-arcamav.x86_64 : Arcam AV amplifier plugin for ALSA
alsa-plugins-maemo.i686 : Maemo plugin for ALSA
alsa-plugins-maemo.x86_64 : Maemo plugin for ALSA
alsa-plugins-oss.i686 : Oss PCM output plugin for ALSA
alsa-plugins-oss.x86_64 : Oss PCM output plugin for ALSA
alsa-plugins-pulseaudio.i686 : Alsa to PulseAudio backend
alsa-plugins-pulseaudio.x86_64 : Alsa to PulseAudio backend
alsa-plugins-samplerate.i686 : External rate converter plugin for ALSA
alsa-plugins-samplerate.x86_64 : External rate converter plugin for ALSA
alsa-plugins-upmix.i686 : Upmixer channel expander plugin for ALSA
alsa-plugins-upmix.x86_64 : Upmixer channel expander plugin for ALSA
alsa-plugins-usbstream.i686 : USB stream plugin for ALSA
alsa-plugins-usbstream.x86_64 : USB stream plugin for ALSA
alsa-plugins-vdownmix.i686 : Downmixer to stereo plugin for ALSA
alsa-plugins-vdownmix.x86_64 : Downmixer to stereo plugin for ALSA
alsa-tools.x86_64 : Specialist tools for ALSA
alsa-tools-firmware.x86_64 : ALSA tools for uploading firmware to some soundcards
alsa-utils.x86_64 : Advanced Linux Sound Architecture (ALSA) utilities
alsa-plugins-speex.i686 : Rate Converter Plugin Using Speex Resampler
alsa-plugins-speex.x86_64 : Rate Converter Plugin Using Speex Resampler

```

2. 安装依赖：`yum -y install alsa-lib* alsa-util*`

### 错误4：缺少Ant依赖

```
ERROR: The version of ant being used is older than 
       the required version of '1.7.1'. 
       The version of ant found was ''. 
```

处理方式：

`yum install ant -y`

### 错误5：缺少C语言环境变量

错误信息

```
WARNING: LANG has been set to zh_CN.UTF-8, this can cause build failures. 
         Try setting LANG to 'C'.
```

处理方式：

1. `export LANG=C`设置C语言环境



## 第二次编译

需要再次输入命令`make santify` ，知道看到如下信息

```
Sanity check passed.
```

## 编写启动脚本

+ 经过上面的测试，再根据JVM虚拟机的内容，编写了下面一个通用的命令脚本

```shell
#!/bin/bash
# 语言选项，必须设置，否者编译之后会出现一个HashTable槽的错误的NPE的错
export LANG=C
# Bootstrap JDK 的安装路径
export ALT_BOOTDIR=/usr/local/software/openjdk/jdk1.7.0_80
# 允许自动下载数据
export ALLOW_DOWNLOADS=true
#并行编译的线程数，设置为和CPU内核数量一致即可

export HOTSPOT_BUILD_JOBS=6

export ALT_PARALLEL_COMPILE_JOBS=6

#比较本次build出来的映像与先前版本的差异。这对我们来说没有意义，

#必须设置为false，否则sanity检查会报缺少先前版本JDK的映像的错误提示。

#如果已经设置dev或者DEV_ONLY=true，这个不显式设置也行

export SKIP_COMPARE_IMAGES=true

#使用预编译头文件，不加这个编译会更慢一些

export USE_PRECOMPILED_HEADER=true

#要编译的内容

export BUILD_LANGTOOLS=true

#export BUILD_JAXP=false

#export BUILD_JAXWS=false

#export BUILD_CORBA=false

export BUILD_HOTSPOT=true

export BUILD_JDK=true

#要编译的版本

#export SKIP_DEBUG_BUILD=false

#export SKIP_FASTDEBUG_BUILD=true

#export DEBUG_NAME=debug

#把它设置为false可以避开javaws和浏览器Java插件之类的部分的build

BUILD_DEPLOY=false

#把它设置为false就不会build出安装包。因为安装包里有些奇怪的依赖，

#但即便不build出它也已经能得到完整的JDK映像，所以还是别build它好了

BUILD_INSTALL=false

#编译结果所存放的路径

export ALT_OUTPUTDIR=/Users/IcyFenix/Develop/JVM/jdkBuild/openjdk_7u4/build

#这两个环境变量必须去掉，不然会有很诡异的事情发生（我没有具体查过这些"诡异的
#事情"，Makefile脚本检查到有这2个变量就会提示警告）

unset JAVA_HOME

unset CLASSPATH

make 2＞＆1|tee $ALT_OUTPUTDIR/build.log

```

### 启动脚本参考：

```shell
#语言选项，这个必须设置，否则编译好后会出现一个HashTable的NPE错
export LANG=C

#Bootstrap JDK的安装路径。必须设置。 
export ALT_BOOTDIR=/usr/local/java/jdk1.7.0_04

#允许自动下载依赖
export ALLOW_DOWNLOADS=true

#并行编译的线程数，设置为和CPU内核数量一致即可
export HOTSPOT_BUILD_JOBS=4
export ALT_PARALLEL_COMPILE_JOBS=4

#比较本次build出来的映像与先前版本的差异。这个对我们来说没有意义，必须设置为false，否则sanity检查会报缺少先前版本JDK的映像。如果有设置dev或者DEV_ONLY=true的话这个不显式设置也行。 
export SKIP_COMPARE_IMAGES=true

#使用预编译头文件，不加这个编译会更慢一些
export USE_PRECOMPILED_HEADER=true

#要编译的内容
export BUILD_LANGTOOLS=true 
#export BUILD_JAXP=false
#export BUILD_JAXWS=false 
#export BUILD_CORBA=false
export BUILD_HOTSPOT=true 
export BUILD_JDK=true

#要编译的版本
#export SKIP_DEBUG_BUILD=false
#export SKIP_FASTDEBUG_BUILD=true
#export DEBUG_NAME=debug

#把它设置为false可以避开javaws和浏览器Java插件之类的部分的build。 
BUILD_DEPLOY=false

#把它设置为false就不会build出安装包。因为安装包里有些奇怪的依赖，但即便不build出它也已经能得到完整的JDK映像，所以还是别build它好了。
BUILD_INSTALL=false

#这两个环境变量必须去掉，不然会有很诡异的事情发生（我没有具体查过这些“”诡异的事情”，Makefile脚本检查到有这2个变量就会提示警告“）
unset JAVA_HOME
unset CLASSPATH

make 2>&1 | tee $ALT_OUTPUTDIR/build.log

```

### 个人版本:

```shell

export LANG=C
export ALT_BOOTDIR=/usr/local/software/jdk1.7
export ALLOW_DOWNLOADS=true
export HOTSPOT_BUILD_JOBDS=1
export ALT_PARALLEL_COMPILE_JOBS=1
export SKIP_COMPARE_IMAGES=true
export USE_PRECOMPLIED_HEADER=true
export BUILD_LANGTOOLS=true
export BUILD_JAXP=false
export BUILD_JAXWS=false
export BUILD_CORBA=false
export BUILD_HOTSPOT=true
export BUILD_JDK=true

export SKIP_DEBUG_BUILD=false
export SKIP_FASTDEBUG_BUILD=true
export DEBUG_NAME=debug

BUILD_DEPLOY=false
BUILD_INSTALL=false

unset JAVA_HOME
unset CLASSPATH

make 2>&1 | tee /usr/local/software/build.log

```



## 开始编译

+ 使用上一节写好的脚本
+ 运行下面的命令
  + `chmod +x run.sh`
  + `./run.sh`

+ 经过多次尝试，现在出现如下报错：

  `g++: internal compiler error: Killed (program cc1plus)`

+ 处理方式
  + 内存不足，需要扩充内存

## 问题收集：

### 1. 编译过程突然报错，报错信息如下

```shell
g++: internal compiler error: Killed (program cc1plus)
Please submit a full bug report,
with preprocessed source if appropriate.
See <http://bugzilla.redhat.com/bugzilla> for instructions.
make[7]: *** [ad_x86_64.o] Error 4
make[7]: Leaving directory `/usr/local/software/openjdk/build/linux-amd64-debug/hotspot/outputdir/linux_amd64_compiler2/jvmg'
make[6]: *** [the_vm] Error 2
make[6]: Leaving directory `/usr/local/software/openjdk/build/linux-amd64-debug/hotspot/outputdir/linux_amd64_compiler2/jvmg'
make[5]: *** [jvmg] Error 2
make[5]: Leaving directory `/usr/local/software/openjdk/build/linux-amd64-debug/hotspot/outputdir'
make[4]: *** [generic_build2] Error 2
make[4]: Leaving directory `/usr/local/software/openjdk/hotspot/make'
make[3]: *** [jvmg] Error 2
make[3]: Leaving directory `/usr/local/software/openjdk/hotspot/make'
make[2]: *** [hotspot-build] Error 2
make[2]: Leaving directory `/usr/local/software/openjdk'
make[1]: *** [generic_debug_build] Error 2
make[1]: Leaving directory `/usr/local/software/openjdk'
make: *** [build_debug_image] Error 2


```

> 分析原因：
>
> 1. 可能是阿里云买的最低配，导致编译的时候内存爆了
> 2. Bootstrap JDK版本和书本的不一致，尝试按照书本一模一样的方式处理
> 3. 脚本建议手敲，复制黏贴容易错误

## 参考资料：

https://blog.csdn.net/zitong_ccnu/article/details/50149757 CenterOS7 编译OpenJDK7

https://www.bbsmax.com/A/GBJrKLa50e/ 案例2

https://hllvm-group.iteye.com/group/topic/35803 JVM的一些讨论，值得看看

# 处理问题的几个套路

## 套路一：缺少依赖，却不知道安装的具体内容

当提示缺少依赖，而你不知道要`yum install`什么时，你可以根据提示关键字搜一下`yum search`，然后在搜出的结果列表中，对有着相同前缀的依赖使用后缀通配符一键下载

