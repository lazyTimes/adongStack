# JAVA8实战 - 日期API

# 前言

​	这一节我们来讲讲JAVA8的日期类，源代码的作者其实就是Joda-Time，所以可以看到很多代码的API和Joda类比较像。日期类一直是一个比较难用的东西，但是JAVA8给日期类提供了一套新的API让日期类更加好用。

​	本文代码较多，建议亲自运行代码理解。
（微信公众号建议阅读原文）


# 思维导图：

地址：https://www.mubucm.com/doc/ck5ZCrgHkB

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210808200827.png)



# 内容概述：

1. 关于JDK8日期的三个核心类：LocalDate、LocalTime、LocalDateTime的相关介绍
2. 机器时间和日期格式`Instant`等关于细粒度的时间操作介绍
3. TemporalAdjusters 用于更加复杂的日期计算，比如计算下一个工作日的时候这个类提供了一些实现
4. DateTimeFormatter 格式化器，非常的灵活多变，属于`SimpleDateFormat`的替代品。
5. 日期API的一些个人工具封装举例，以及在使用JDK8的时候一些个人的踩坑

​	最后希望通过本文能帮你摆脱`new Date()`



# 什么是ISO-8601？

​	日期离不开ISO-8601，下面对ISO-8601简单描述一下，参考自百度百科：

1. ISO-8601: 国际标准化组织制定的日期和时间的表示方法，全称为《数据存储和交换形式·信息交换·日期和时间的表示方法》，简称为ISO-8601。
2. 日的表示：小时、分和秒都用2位数表示，对UTC时间最后加一个大写字母Z，其他时区用实际时间加时差表示。如UTC时间下午2点30分5秒表示为14:30:05Z或143005Z，当时的北京时间表示为22:30:05+08:00或223005+0800，也可以简化成223005+08。
3. 日期和时间的组合表示：合并表示时，要在时间前面加一大写字母T，如要表示北京时间2004年5月3日下午5点30分8秒，可以写成2004-05-03T17:30:08+08:00或20040503T173008+08。



# LocalDate、LocalTime、LocalDateTime

​	JDK8把时间拆分成了三个大部分，一个是时间，代表了年月日的信息，一个是日期，代表了时分秒的部分，最后是这两个对象总和具体的时间。

## LocalDate

​	`LocalDate`：类表示一个具体的日期，但不包含具体时间，也不包含时区信息。可以通过`LocalDate`的静态方法`of()`创建一个实例，`LocalDate`也包含一些方法用来获取年份，月份，天，星期几等，下面是`LocalDate`的常见使用方式：

```java

    @Test
    public void localDateTest() throws Exception {
        // 创建一个LocalDate:
        LocalDate of = LocalDate.of(2021, 8, 9);
        // 获取当前时间
        LocalDate now = LocalDate.now();
        // 格式化
        LocalDate parse1 = LocalDate.parse("2021-05-11");
        // 指定日期格式化
        LocalDate parse2 = LocalDate.parse("2021-05-11", DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        // 下面的代码会出现格式化异常
        // java.time.format.DateTimeParseException: Text '2021-05-11 11:53:53' could not be parsed, unparsed text found at index 10
//        LocalDate parse3 = LocalDate.parse("2021-05-11 11:53:53", DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        // 正确的格式化方法
        LocalDate parse3 = LocalDate.parse("2021-05-11 11:53:53", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        // 当前时间
        System.out.println("now() => "+ now);
        // 获取月份
        int dayOfMonth = parse1.getDayOfMonth();
        System.out.println("dayOfMonth => " + dayOfMonth);
        // 获取年份
        int dayOfYear = parse1.getDayOfYear();
        System.out.println("getDayOfYear => " + dayOfYear);
        // 获取那一周，注意这里获取的是对象
        DayOfWeek dayOfWeek = parse1.getDayOfWeek();
        System.out.println("getDayOfWeek => " + dayOfWeek);
        // 获取月份数据
        int monthValue = parse3.getMonthValue();
        System.out.println("getMonthValue => " + monthValue);
        // 获取年份
        int year = parse3.getYear();
        System.out.println("getYear => " + year);
        // getChronology 获取的是当前时间的排序，这里输出结果是 ISO
        System.out.println("getChronology => " + parse3.getChronology());
        System.out.println("getEra => " + parse3.getEra());


        // 使用timeField获取值：TemporalField 是一个接口，定义了如何访问 TemporalField 的值，ChronnoField 实现了这个接口
        /*
        LocalDate 支持的格式如下：
         case DAY_OF_WEEK: return getDayOfWeek().getValue();
        case ALIGNED_DAY_OF_WEEK_IN_MONTH: return ((day - 1) % 7) + 1;
        case ALIGNED_DAY_OF_WEEK_IN_YEAR: return ((getDayOfYear() - 1) % 7) + 1;
        case DAY_OF_MONTH: return day;
        case DAY_OF_YEAR: return getDayOfYear();
        case EPOCH_DAY: throw new UnsupportedTemporalTypeException("Invalid field 'EpochDay' for get() method, use getLong() instead");
        case ALIGNED_WEEK_OF_MONTH: return ((day - 1) / 7) + 1;
        case ALIGNED_WEEK_OF_YEAR: return ((getDayOfYear() - 1) / 7) + 1;
        case MONTH_OF_YEAR: return month;
        case PROLEPTIC_MONTH: throw new UnsupportedTemporalTypeException("Invalid field 'ProlepticMonth' for get() method, use getLong() instead");
        case YEAR_OF_ERA: return (year >= 1 ? year : 1 - year);
        case YEAR: return year;
        case ERA: return (year >= 1 ? 1 : 0);
        * */
        // Unsupported field: HourOfDay
//        System.out.println("ChronoField.HOUR_OF_DAY => " + parse1.get(ChronoField.HOUR_OF_DAY));
        // Unsupported field: MinuteOfHour
//        System.out.println("ChronoField.MINUTE_OF_HOUR => " + parse1.get(ChronoField.MINUTE_OF_HOUR));
        // Unsupported field: MinuteOfHour
//        System.out.println("ChronoField.SECOND_OF_MINUTE => " + parse1.get(ChronoField.SECOND_OF_MINUTE));
        System.out.println("ChronoField.YEAR => " + parse1.get(ChronoField.YEAR));
        // Unsupported field: MinuteOfHour
//        System.out.println("ChronoField.INSTANT_SECONDS => " + parse1.get(ChronoField.INSTANT_SECONDS));

    }/*运行结果：
    now() => 2021-08-08
    dayOfMonth => 11
    getDayOfYear => 131
    getDayOfWeek => TUESDAY
    getMonthValue => 5
    getYear => 2021
    getChronology => ISO
    getEra => CE
    ChronoField.YEAR => 2021
    */
```

> **TemporalField** 是一个接口，定义了如何访问 TemporalField 的值，**ChronnoField** 实现了这个接口

## LocalTime

​	`LocalTime`：和`LocalDate`类似，区别在于包含具体时间，同时拥有更多操作具体时间时间的方法，下面是对应的方法以及测试：

```java
 @Test
    public void localTimeTest() throws Exception {
        LocalTime now = LocalTime.now();
        System.out.println("LocalTime.now() => "+  now);
        System.out.println("getHour => "+ now.getHour());
        System.out.println("getMinute => "+ now.getMinute());
        System.out.println("getNano => "+ now.getNano());
        System.out.println("getSecond => "+ now.getSecond());

        LocalTime systemDefault = LocalTime.now(Clock.systemDefaultZone());
        // ZoneName => java.time.format.ZoneName.zidMap 从这个map里面进行获取
        LocalTime japan = LocalTime.now(Clock.system(ZoneId.of("Japan")));
        // 或者直接更换时区
        LocalTime japan2 = LocalTime.now(ZoneId.of("Japan"));
        // 格式化时间
        LocalTime localTime = LocalTime.of(15, 22);
        // from 从另一个时间进行转化，只要他们接口兼容
        LocalTime from = LocalTime.from(LocalDateTime.now());
        // 范湖纳秒值
        LocalTime localTime1 = LocalTime.ofNanoOfDay(1);
        LocalTime localTime2 = LocalTime.ofSecondOfDay(1);
        // 越界异常 Invalid value for MinuteOfHour (valid values 0 - 59): 77
//        LocalTime.of(15, 77);
        // 获取本地的默认时间
        System.out.println("LocalTime.now(Clock.systemDefaultZone()) => "+ systemDefault);
        // 获取日本时区的时间
        System.out.println("LocalTime.now(Clock.system(ZoneId.of(\"Japan\"))) => "+ japan);
        System.out.println("LocalTime.now(ZoneId.of(\"Japan\")) => "+ japan2);
        System.out.println("LocalTime.of(15, 22) => "+ localTime);
        System.out.println("LocalTime.from(LocalDateTime.now()) => "+ from);
        System.out.println("LocalTime.ofNanoOfDay(1) => "+ localTime1);
        System.out.println("LocalTime.ofSecondOfDay(1) => "+ localTime2);
    }/*运行结果：
    LocalTime.now() => 12:58:13.553
    getHour => 12
    getMinute => 58
    getNano => 553000000
    getSecond => 13
    LocalTime.now(Clock.systemDefaultZone()) => 12:58:13.553
    LocalTime.now(Clock.system(ZoneId.of("Japan"))) => 13:58:13.553
    LocalTime.now(ZoneId.of("Japan")) => 13:58:13.553
    LocalTime.of(15, 22) => 15:22
    LocalTime.from(LocalDateTime.now()) => 12:58:13.553
    LocalTime.ofNanoOfDay(1) => 00:00:00.000000001
    LocalTime.ofSecondOfDay(1) => 00:00:01
    */
```

## LocalDateTime	

​	`LocalDateTime`：`LocalDateTime`类是`LocalDate`和`LocalTime`的**结合体**，可以通过`of()`方法直接创建，也可以调用`LocalDate`的`atTime()`方法或`LocalTime`的`atDate()`方法将`LocalDate`或`LocalTime`合并成一个`LocalDateTime`，下面是一些简单的方法测试，由于篇幅有限，后续会结合这些内容编写一个工具类的代码。

```java
	@Test
    public void localDateTimeTest() throws Exception {
        //Text '2021-11-11 15:30:11' could not be parsed at index 10
//        LocalDateTime parse = LocalDateTime.parse("2021-11-11 15:30:11");
        // 默认使用的是ISO的时间格式
        LocalDateTime parse1 = LocalDateTime.parse("2011-12-03T10:15:30");
        // 如果要自己的格式，需要手动格式化
        LocalDateTime parse = LocalDateTime.parse("2021-11-11 15:30:11", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        System.out.println("LocalDateTime.parse(....) => "+ parse1);
        System.out.println("LocalDateTime.parse(....) => "+ parse);

        LocalDateTime of = LocalDateTime.of(LocalDate.now(), LocalTime.now());
        LocalDateTime japan = LocalDateTime.now(ZoneId.of("Japan"));
        System.out.println("LocalDateTime.of(LocalDate.now(), LocalTime.now()) => "+ of);
        System.out.println("LocalDateTime.now(ZoneId.of(\"Japan\")) => "+ japan);
    }/*运行结果：
    LocalDateTime.parse(....) => 2011-12-03T10:15:30
    LocalDateTime.parse(....) => 2021-11-11T15:30:11
    LocalDateTime.of(LocalDate.now(), LocalTime.now()) => 2021-08-08T13:22:59.697
    LocalDateTime.now(ZoneId.of("Japan")) => 2021-08-08T14:22:59.697
    */
```



# 细粒度机器时间操作

​	JDK8还对机器的时间进行了分类，比如像下面这样

## `Instant`

​	`Instant`用于表示一个时间戳，它与我们常使用的`System.currentTimeMillis()`有些类似，不过`Instant`可以精确到纳秒（Nano-Second）

> 注意： 内部使用了两个常量，`seconds`表示从1970-01-01 00:00:00开始到现在的秒数，`nanos`表示纳秒部分（`nanos`的值不会超过`999,999,999`）

​	下面是一些具体的测试用例：

```java
@Test
    public void instantTest() throws Exception {
        Instant now = Instant.now();
        // Unable to obtain Instant from TemporalAccessor: 2021-08-08T13:37:34.403 of type java.time.LocalDateTime
//        Instant from = Instant.from(LocalDateTime.now());
        Instant instant = Instant.ofEpochSecond(3, 0);
        Instant instant1 = Instant.ofEpochSecond(5, 1_000_000_000);
        System.out.println("Instant.now() => "+ now);
//        System.out.println("Instant.from(LocalDateTime.now()) => "+ from);
        System.out.println("Instant.ofEpochSecond => "+ instant);
        System.out.println("Instant.ofEpochSecond => "+ instant1);
        System.out.println("Instant.get(ChronoField.NANO_OF_SECOND) => "+ now.get(ChronoField.NANO_OF_SECOND));
    }/*运行结果：
    Instant.now() => 2021-08-08T05:42:42.465Z
    Instant.ofEpochSecond => 1970-01-01T00:00:03Z
    Instant.ofEpochSecond => 1970-01-01T00:00:06Z
    Instant.get(ChronoField.NANO_OF_SECOND) => 465000000

    */
```



## `Duration`

​	`Duration`的内部实现与`Instant`类似，也是包含两部分：`seconds`表示秒，`nanos`表示纳秒。两者的区别是`Instant`用于表示一个时间戳（或者说是一个时间点），而`Duration`表示一个时间段，比如想要获取两个时间的差值：

```java
	@Test
    public void durationTest() throws Exception {
        // Text '201-08-08T10:15:30' could not be parsed at index 0
        Duration between = Duration.between(LocalDateTime.parse("2011-12-03T10:15:30"), LocalDateTime.parse("2021-08-08T10:15:30"));
        System.out.println("Duration.between(LocalDateTime.parse(\"2011-12-03T10:15:30\"), LocalDateTime.parse(\"2021-08-08T10:15:30\")) => "+ between);

        Duration duration = Duration.ofDays(7);
        System.out.println("Duration.ofDays(7) => "+ duration);
    }
```



## `Period`

​	`Period`在概念上和`Duration`类似，区别在于`Period`是以**年月日**来衡量一个时间段（比如2年3个月6天），下面是对应单元测试以及相关的代码：

```java
@Test
    public void periodTest() throws Exception {
        Period between = Period.between(LocalDate.parse("2011-12-03"), LocalDate.parse("2021-08-08"));
        Period period = Period.ofWeeks(53);
        Period period1 = Period.ofWeeks(22);
        System.out.println("Period.between(LocalDate.parse(\"2011-12-03\"), LocalDate.parse(\"2021-08-08\")) => "+ between);
        System.out.println("Period.ofWeeks(53) => "+ period);
        System.out.println("Period.ofWeeks(53) getDays => "+ period.getDays());
        // 注意，这里如果没有对应值，会出现 0
        System.out.println("Period.ofWeeks(53) getMonths => "+ period.getMonths());
        System.out.println("Period.ofWeeks(22) getMonths => "+ period1.getMonths());
        System.out.println("Period.ofWeeks(22) getYears => "+ period1.getYears());
    }/*运行结果：
    Period.between(LocalDate.parse("2011-12-03"), LocalDate.parse("2021-08-08")) => P9Y8M5D
    Period.ofWeeks(53) => P371D
    Period.ofWeeks(53) getDays => 371
    Period.ofWeeks(53) getMonths => 0
    Period.ofWeeks(22) getMonths => 0
    Period.ofWeeks(22) getYears => 0
    */
```



# TemporalAdjusters 复杂日期操作

​	这个类可以对于时间进行各种更加复杂的操作，比如下一个工作日，本月的最后一天，这时候我们可以借助`with`这个方法进行获取：

```java
@Test
public void testTemporalAdjusters(){
    LocalDate of = LocalDate.of(2021, 8, 1);
    // 获取当前年份的第一天
    LocalDate with = of.with(TemporalAdjusters.firstDayOfYear());
    System.out.println(" TemporalAdjusters.firstDayOfYear => "+ with);
    // 获取指定日期的下一个周六
    LocalDate with1 = of.with(TemporalAdjusters.next(DayOfWeek.SATURDAY));
    System.out.println(" TemporalAdjusters.next(DayOfWeek.SATURDAY) => "+ with1);
    // 获取当月的最后一天
    LocalDate with2 = of.with(TemporalAdjusters.lastDayOfMonth());
    System.out.println("TemporalAdjusters.lastDayOfMonth() => "+ with2);

}
```

下面从网络找到一份表，对应所有的方法作用

| 方法名                        | 描述                                                        |
| :---------------------------- | :---------------------------------------------------------- |
| `dayOfWeekInMonth`            | 返回同一个月中每周的第几天                                  |
| `firstDayOfMonth`             | 返回当月的第一天                                            |
| `firstDayOfNextMonth`         | 返回下月的第一天                                            |
| `firstDayOfNextYear`          | 返回下一年的第一天                                          |
| `firstDayOfYear`              | 返回本年的第一天                                            |
| `firstInMonth`                | 返回同一个月中第一个星期几                                  |
| `lastDayOfMonth`              | 返回当月的最后一天                                          |
| `lastDayOfNextMonth`          | 返回下月的最后一天                                          |
| `lastDayOfNextYear`           | 返回下一年的最后一天                                        |
| `lastDayOfYear`               | 返回本年的最后一天                                          |
| `lastInMonth`                 | 返回同一个月中最后一个星期几                                |
| `next / previous`             | 返回后一个/前一个给定的星期几                               |
| `nextOrSame / previousOrSame` | 返回后一个/前一个给定的星期几，如果这个值满足条件，直接返回 |



# DateTimeFormatter 格式化器

​	这个类可以认为是用来替代`SimpleDateFormat`这个类，他拥有更加强大的定制化操作，同时他是线程安全的类，不用担心多线程访问会出现问题。

​	下面是根据DateTimeFormatter 构建一个本土化的格式化器，代码也十分的简单易懂：

```java
private static DateTimeFormatter generateDefualtPattern(String timeFormat) {
    return new DateTimeFormatterBuilder().appendPattern(timeFormat)
        .parseDefaulting(ChronoField.HOUR_OF_DAY, 0)
        .parseDefaulting(ChronoField.MINUTE_OF_HOUR, 0)
        .parseDefaulting(ChronoField.SECOND_OF_MINUTE, 0)
        .toFormatter(Locale.CHINA);
}
```



# 时区信息

​	时区信息一般用的比较少，在做和国际化相关的操作时候有可能会用到，比如最近个人从苹果买了一个东西，虽然我下单是在6号，但是电话说订单时间却是5号下单的，这里个人认为苹果的确切下单时间是按照美国时间算的。

​	JDK8日期类关于时区的强相关类（注意是JDK8才出现的类，不要误认为是对之前类的兼容），在之前的单元测试其实已经用到了相关时区的方法，在JDK8中使用了 `ZoneId`这个类来表示，但是我们有时候不知道怎么获取地区，可以参考下面的内容：

![](https://gitee.com/lazyTimes/imageReposity/raw/master/img/20210808154131.png)

```java
// ZoneName => java.time.format.ZoneName.zidMap 从这个map里面进行获取
LocalTime japan = LocalTime.now(Clock.system(ZoneId.of("Japan")));
```



# 实战 - 封装日期工具类

​	当然更加建议读者自己多动手实验，最好的办法就是多给几个需求给自己，强制自己用JDK8的方法去实现，你会发现你掌握这些API会特别快。

## 注意事项：

​	所有的工具代码都使用了同一个本地格式化器构建方法：`generateDefualtPattern()`：

```java
/**
     * 生成默认的格式器
     *
     * @param timeFormat 指定格式
     * @return 默认时间格式器
     */
    private static DateTimeFormatter generateDefualtPattern(String timeFormat) {
        return new DateTimeFormatterBuilder().appendPattern(timeFormat)
                .parseDefaulting(ChronoField.HOUR_OF_DAY, 0)
                .parseDefaulting(ChronoField.MINUTE_OF_HOUR, 0)
                .parseDefaulting(ChronoField.SECOND_OF_MINUTE, 0)
                .toFormatter(Locale.CHINA);
    }

```



## 获取指定时间的上一个工作日和下一个工作日

​	注意这个版本是不会判断节假日这些内容的，当然这里是手动实现的版本。

```java
/**
     * 获取指定时间的上一个工作日
     *
     * @param time           指定时间
     * @param formattPattern 格式化参数
     * @return
     */
    public static String getPreWorkDay(String time, String formattPattern) {
        DateTimeFormatter dateTimeFormatter = generateDefualtPattern(formattPattern);
        LocalDateTime compareTime1 = LocalDateTime.parse(time, dateTimeFormatter);
        compareTime1 = compareTime1.with(temporal -> {
            // 当前日期
            DayOfWeek dayOfWeek = DayOfWeek.of(temporal.get(ChronoField.DAY_OF_WEEK));
            // 正常情况下，每次减去一天
            int dayToMinu = 1;
            // 如果是周日，减去2天
            if (dayOfWeek == DayOfWeek.SUNDAY) {
                dayToMinu = 2;
            }
            // 如果是周六，减去一天
            if (dayOfWeek == DayOfWeek.SATURDAY) {
                dayToMinu = 1;
            }
            return temporal.minus(dayToMinu, ChronoUnit.DAYS);
        });
        return compareTime1.format(dateTimeFormatter);
    }


    /**
     * 获取指定时间的下一个工作日
     *
     * @param time           指定时间
     * @param formattPattern 格式参数
     * @return
     */
    public static String getNextWorkDay(String time, String formattPattern) {
        DateTimeFormatter dateTimeFormatter = generateDefualtPattern(formattPattern);
        LocalDateTime compareTime1 = LocalDateTime.parse(time, dateTimeFormatter);
        compareTime1 = compareTime1.with(temporal -> {
            // 当前日期
            DayOfWeek dayOfWeek = DayOfWeek.of(temporal.get(ChronoField.DAY_OF_WEEK));
            // 正常情况下，每次增加一天
            int dayToAdd = 1;
            // 如果是星期五，增加三天
            if (dayOfWeek == DayOfWeek.FRIDAY) {
                dayToAdd = 3;
            }
            // 如果是星期六，增加两天
            if (dayOfWeek == DayOfWeek.SATURDAY) {
                dayToAdd = 2;
            }
            return temporal.plus(dayToAdd, ChronoUnit.DAYS);
        });
        return compareTime1.format(dateTimeFormatter);
    }
```

## 判断当前时间是否小于目标时间

​	判断当前时间是否小于目标时间，这里结合了之前我们学到的一些方法，注意这里的时区使用的是当前系统的时区，如果你切换别的时区，可以看到不同的效果。另外这里使用的是`LocalDateTime`不要混淆了。

```java
/**
     * 使用jdk 1.8 的日期类进行比较时间
     * 判断当前时间是否小于目标时间
     *
     * @param time   时间字符串
     * @param format 指定格式
     * @return 判断当前时间是否小于目标时间
     */
    public static boolean isBefore(String time, String format) {
        DateTimeFormatter dateTimeFormatter = generateDefualtPattern(format);
        LocalDateTime compareTime = LocalDateTime.parse(time, dateTimeFormatter);
        // getNowByNew 封装了 now()方法
        LocalDateTime current = LocalDateTime.parse(getNowByNew(format), dateTimeFormatter);
        long compare = Instant.from(compareTime.atZone(ZoneId.systemDefault())).toEpochMilli();
        long currentTimeMillis = Instant.from(current.atZone(ZoneId.systemDefault())).toEpochMilli();
        return currentTimeMillis < compare;
    }
```

## 获取指定时间属于星期几

​	属于对JDK8自身的方法进行二次封装。

```java
/**
     * 获取指定时间属于星期几
     * 返回枚举对象
     *
     * @param date           日期
     * @param formattPattern 格式
     * @return
     */
public static DayOfWeek getDayOfWeek(String date, String formattPattern) {
    DateTimeFormatter dateTimeFormatter = generateDefualtPattern(formattPattern);
    return LocalDate.parse(date, dateTimeFormatter).getDayOfWeek();
}
```

## 获取开始日期和结束日期之间的日期

​	这里需要注意不是十分的严谨，最好是在执行之前日期的判断

```java
public static final String yyyyMMdd = "yyyy-MM-dd";

/**
     * 获取开始日期和结束日期之间的日期（返回List<String>）
     *
     * @param startTime 开始日期
     * @param endTime   结束日期
     * @return 开始与结束之间的所以日期，包括起止
     */
public static List<String> getMiddleDateToString(String startTime, String endTime) {
    LocalDate begin = LocalDate.parse(startTime, DateTimeFormatter.ofPattern(yyyyMMdd));
    LocalDate end = LocalDate.parse(endTime, DateTimeFormatter.ofPattern(yyyyMMdd));
    List<LocalDate> localDateList = new ArrayList<>();
    long length = end.toEpochDay() - begin.toEpochDay();
    // 收集相差的天数
    for (long i = length; i >= 0; i--) {
        localDateList.add(end.minusDays(i));
    }
    List<String> resultList = new ArrayList<>();
    for (LocalDate temp : localDateList) {
        resultList.add(temp.toString());
    }
    return resultList;
}
```

​	

# 日期API常见的坑：

## `LocalDateTime` 的格式化`yyyy-MM-dd`报错：

​	第一次使用，最容易出现问题的diamante如下的形式所示，比如我们

```java
LocalDateTime parse2 = LocalDateTime.parse("2021-11-11", DateTimeFormatter.ofPattern("yyyy-MM-dd"));
```

​	在运行的时候，会抛出如下的异常：

```java
java.time.format.DateTimeParseException: Text '2021-11-11' could not be parsed: Unable to obtain LocalDateTime from TemporalAccessor: {},ISO resolved to 2021-11-11 of type java.time.format.Parsed
```

​	下面来说一下解决办法：

​	第一种解决办法比较蛋疼，但是确实是一种非常稳妥的解决方法。

```java
try {
    LocalDate localDate = LocalDate.parse("2019-05-27", DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    LocalDateTime localDateTime = localDate.atStartOfDay();
    System.out.println(localDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
} catch (Exception ex) {
    ex.printStackTrace();
}
```

​	另外，还有一种方法是使用下面的方法，构建一个"中国化"的日期格式器：

```java
/**
     * 生成默认的格式器
     *
     * @param timeFormat 指定格式
     * @return 默认时间格式器
     */
private static DateTimeFormatter generateDefualtPattern(String timeFormat) {
    return new DateTimeFormatterBuilder().appendPattern(timeFormat)
        .parseDefaulting(ChronoField.HOUR_OF_DAY, 0)
        .parseDefaulting(ChronoField.MINUTE_OF_HOUR, 0)
        .parseDefaulting(ChronoField.SECOND_OF_MINUTE, 0)
        .toFormatter(Locale.CHINA);
}
```



## 调用format出现`xx not be parsed, unparsed text found at index 10`

​	问题原因：使用错误的格式去格式字符串，比如`yyyy-MM-dd` 格式化 `2020-05-12 12:15:33` 这种格式就会出现溢出，解决办法：使用正确的格式即可

​	对于上面几个问题的根本解决办法
​	原因：因为localdatetime 在进行格式化的时候如何case没有找到对应的格式，那么就会出现类似`unsupport`方法

```java
/**
     * 生成默认的格式器
     *
     * @param timeFormat 指定格式
     * @return
     */
    private static DateTimeFormatter generateDefualtPattern(String timeFormat) {
        return new DateTimeFormatterBuilder().appendPattern(timeFormat)
                .parseDefaulting(ChronoField.HOUR_OF_DAY, 1)
                .parseDefaulting(ChronoField.MINUTE_OF_HOUR, 1)
                .parseDefaulting(ChronoField.SECOND_OF_MINUTE, 0)
                .toFormatter(Locale.CHINA);
    }
```

> 下面是其他的问题回答：
>
> StackFlow地址：[DateTimeParseException: Text could not be parsed: Unable to obtain LocalDateTime from TemporalAccessor](https://stackoverflow.com/questions/43732751/datetimeparseexception-text-could-not-be-parsed-unable-to-obtain-localdatetime)
>
> StackFlow地址：[StackFlow无法解析文本：无法从TemporalAccessor获取LocalDateTime](https://stackoverflow.com/questions/43732751/datetimeparseexception-text-could-not-be-parsed-unable-to-obtain-localdatetime?rq=1)
>
> StackFlow地址：[解析LocalDateTime（Java 8）时，无法从TemporalAccessor获取LocalDateTime](https://stackoverflow.com/questions/27454025/unable-to-obtain-localdatetime-from-temporalaccessor-when-parsing-localdatetime)
>



## DateTimeParseException一些小坑

​	参考了下面的异常日志，根本的原因是`DateTimeFormatter`格式化没有`HH`选项，这也是比较坑的地方

```java
java.time.format.DateTimeParseException: Text '2017-02-02 08:59:12' could not be parsed: Unable to obtain LocalDateTime from TemporalAccessor: {MinuteOfHour=59, NanoOfSecond=0, SecondOfMinute=12, MicroOfSecond=0, MilliOfSecond=0, HourOfAmPm=8},ISO resolved to 2017-02-02 of type java.time.format.Parsed
```



# 总结：

​	在个人编写工具类的过程中，发现确实比之前的`Date`和`Calendar`这两个类用起来好很多，同时JDK8的日期类都是**线程安全**的。当然JDK8对于国内使用不是十分友好，这也没有办法毕竟是老外的东西，不过解决办法也有不少，习惯了将解决套路之后也可以接受。最后，有条件最好使用谷歌的搜索引擎，不仅可以帮你把坑跨过去，老外很多大神还会给你讲讲原理，十分受用。



# 写在最后

​	写稿不易，求赞，求收藏。

​	最后推荐一下个人的微信公众号：**“懒时小窝**”。有什么问题可以通过公众号私信和我交流，当然评论的问题看到的也会第一时间解答。





# 其他问题

1. 关于LocalDate的一个坑

​	[关于LocalDate一些源码分析](https://stackoverflow.com/questions/23069370/format-a-date-using-the-new-date-time-api/23069408)

直接上源代码，`LocalDate`仅代表一个日期，而不代表DateTime。因此在格式化时“ **HH：mm：ss**”是毫无意义的，如果我们的格式化参数不符合下面的规则，此方法会抛出异常并且说明不支持对应的格式化操作。

```java
private int get0(TemporalField field) {
        switch ((ChronoField) field) {
            case DAY_OF_WEEK: return getDayOfWeek().getValue();
            case ALIGNED_DAY_OF_WEEK_IN_MONTH: return ((day - 1) % 7) + 1;
            case ALIGNED_DAY_OF_WEEK_IN_YEAR: return ((getDayOfYear() - 1) % 7) + 1;
            case DAY_OF_MONTH: return day;
            case DAY_OF_YEAR: return getDayOfYear();
            case EPOCH_DAY: throw new UnsupportedTemporalTypeException("Invalid field 'EpochDay' for get() method, use getLong() instead");
            case ALIGNED_WEEK_OF_MONTH: return ((day - 1) / 7) + 1;
            case ALIGNED_WEEK_OF_YEAR: return ((getDayOfYear() - 1) / 7) + 1;
            case MONTH_OF_YEAR: return month;
            case PROLEPTIC_MONTH: throw new UnsupportedTemporalTypeException("Invalid field 'ProlepticMonth' for get() method, use getLong() instead");
            case YEAR_OF_ERA: return (year >= 1 ? year : 1 - year);
            case YEAR: return year;
            case ERA: return (year >= 1 ? 1 : 0);
        }
        throw new UnsupportedTemporalTypeException("Unsupported field: " + field);
    }
```

2. 格式化问题:

   调用DateFomatter 有可能的报错，基本是由于使用错误到格式或者使用错误的时间类

   [Error java.time.format.DateTimeParseException: could not be parsed, unparsed text found at index 10](https://stackoverflow.com/questions/39033525/error-java-time-format-datetimeparseexception-could-not-be-parsed-unparsed-tex)





# 参考资料

> [侠说java8-LocalDateTime](https://aijishu.com/a/1060000000087793)