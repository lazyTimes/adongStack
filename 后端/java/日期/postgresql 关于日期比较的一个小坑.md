# postgresql 关于日期比较的一个小坑

关于日期方面的比较方面，由于多年JAVA写法的固定观念，导致卡了一点时间排查这个问题。

按照正常的逻辑，一般情况下我们都会想到 `yyyy-MM-dd HH:mm:ss`，这样写通常没有什么问题，但是在postgre当中是存在问题的。因为 `HH`默认是**12小时制**！！！这个坑会导致查找数据出现下面莫名其妙的问题：

首先按照下面的sql进行查询：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210331183239.png)

得到查询结果如下：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210331190301.png)

这个结果是出乎预料的，因为正常来说应该查出来是0点的数据：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210331190422.png)

将上面的`00:59:59` 时间点改为`01:59:59`，结果查出来是第一条居然是13点的数据：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210331190640.png)

于是我停了下来，我套入各种数据不断尝试，猜想这个1点和13点都代表1点，或许使用了12小时制，果不其然，正确的写法应该如下：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210331190839.png)

这一下结果就正确了

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210331190856.png)

总结：

​	这周问题是习惯性思维的问题，但是个人想要吐槽一下这个设计有点点坑人=-=