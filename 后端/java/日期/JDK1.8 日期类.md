# [参考博客](https://lw900925.github.io/java/java8-newtime-api.html)

# 获取指定时间的上一个工作日和下一个工作日（无判断节假日，调休）

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



# LocalDate、LocalTime、LocalDateTime 三者区别 

`LocalDate`：类表示一个具体的日期，但==不包含==具体时间，也==不包含时区信息==。可以通过`LocalDate`的静态方法`of()`创建一个实例，`LocalDate`也包含一些方法用来获取年份，月份，天，星期几等

`LocalTime`：和`LocalDate`类似，区别在于包含==具体时间==

`LocalDateTime`：`LocalDateTime`类是`LocalDate`和`LocalTime`的==结合体==，可以通过`of()`方法直接创建，也可以调用`LocalDate`的`atTime()`方法或`LocalTime`的`atDate()`方法将`LocalDate`或`LocalTime`合并成一个`LocalDateTime`：

```java
LocalDateTime ldt1 = LocalDateTime.of(2017, Month.JANUARY, 4, 17, 23, 52);

LocalDate localDate = LocalDate.of(2017, Month.JANUARY, 4);
LocalTime localTime = LocalTime.of(17, 23, 52);
LocalDateTime ldt2 = localDate.atTime(localTime);
```

## 时间戳

### `Instant`

`Instant`用于表示一个时间戳，它与我们常使用的`System.currentTimeMillis()`有些类似，不过`Instant`可以精确到纳秒（Nano-Second）

> 注意： 内部使用了两个常量，`seconds`表示从1970-01-01 00:00:00开始到现在的秒数，`nanos`表示纳秒部分（`nanos`的值不会超过`999,999,999`）

### `Duration`

`Duration`的内部实现与`Instant`类似，也是包含两部分：`seconds`表示秒，`nanos`表示纳秒。两者的区别是`Instant`用于表示一个==时间戳==（或者说是一个时间点），而`Duration`表示一个==时间段==

### `Period`

`Period`在概念上和`Duration`类似，区别在于`Period`是以年月日来衡量一个时间段，比如2年3个月6天：

# 问题1：错误

报错
```
Text '2020-09-01' could not be parsed: Unable to obtain LocalDateTime from TemporalAccessor: {},ISO resolved to 2020-09-01 of type java.time.format.Parsed
```
##　解决办法
```
https://blog.csdn.net/qq_28988969/article/details/90610580
```

# 问题2： 学习jdk1.8 的时间
https://www.jianshu.com/p/f4abe1e38e09


# 问题3: 关于js端口的时间格式化问题
问题： new Date() 方法如何当前设备的时间是错的会出现问题

# 问题4： 时间比较的问题
比较的常用方法
```javascript
//格式化日期
var format = function (time, format) {
    var t = new Date(time);
    var tf = function (i) {
        return (i < 10 ? '0' : '') + i
    };
    return format.replace(/yyyy|MM|dd|HH|mm|ss/g, function (a) {
        switch (a) {
            case 'yyyy':
                return tf(t.getFullYear());
                break;
            case 'MM':
                return tf(t.getMonth() + 1);
                break;
            case 'mm':
                return tf(t.getMinutes());
                break;
            case 'dd':
                return tf(t.getDate());
                break;
            case 'HH':
                return tf(t.getHours());
                break;
            case 'ss':
                return tf(t.getSeconds());
                break;
        }
        ;
    });
};
```
# 问题5：调用format出现`Text '2020-06-02 15:22:22' could not be parsed, unparsed text found at index 10`
问题原因：使用错误的格式去格式字符串，比如`yyyy-MM-dd` 格式化 `2020-05-12 12:15:33` 这种格式就会出现溢出
解决办法：使用正确的格式即可

学习参考

https://lw900925.github.io/java/java8-newtime-api.html

关于格式化的问题

1. 对于上面几个问题的根本解决办法
原因：因为localdatetime 在进行格式化的时候如何case没有找到对应的格式，那么就会出现类似`unsupport`方法

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

2. 

# 问题6：关于DateTimeParseException

参考了下面到异常日志，根本的原因是`DateTimeFormatter`格式化没有`HH`选项，需要根据==问题5==的解决方式进行处理

```java
java.time.format.DateTimeParseException: Text '2017-02-02 08:59:12' could not be parsed: Unable to obtain LocalDateTime from TemporalAccessor: {MinuteOfHour=59, NanoOfSecond=0, SecondOfMinute=12, MicroOfSecond=0, MilliOfSecond=0, HourOfAmPm=8},ISO resolved to 2017-02-02 of type java.time.format.Parsed
```

StackFlow地址：[DateTimeParseException: Text could not be parsed: Unable to obtain LocalDateTime from TemporalAccessor](https://stackoverflow.com/questions/43732751/datetimeparseexception-text-could-not-be-parsed-unable-to-obtain-localdatetime)

StackFlow地址：[StackFlow无法解析文本：无法从TemporalAccessor获取LocalDateTime](https://stackoverflow.com/questions/43732751/datetimeparseexception-text-could-not-be-parsed-unable-to-obtain-localdatetime?rq=1)

StackFlow地址：[解析LocalDateTime（Java 8）时，无法从TemporalAccessor获取LocalDateTime](https://stackoverflow.com/questions/27454025/unable-to-obtain-localdatetime-from-temporalaccessor-when-parsing-localdatetime)

# 其他问题收集

## 关于LocalDate.class的一个坑

[关于LocalDate一些源码分析](https://stackoverflow.com/questions/23069370/format-a-date-using-the-new-date-time-api/23069408)

直接上源代码

1. `LocalDate`仅代表一个日期，而不代表DateTime。因此，在格式化时，“ HH：mm：ss”是毫无意义的

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

## 格式化问题:

调用DateFomatter 有可能的报错，基本是由于使用错误到格式或者使用错误的时间类

[Error java.time.format.DateTimeParseException: could not be parsed, unparsed text found at index 10](https://stackoverflow.com/questions/39033525/error-java-time-format-datetimeparseexception-could-not-be-parsed-unparsed-tex)

# 侠说java8-LocalDateTime等时间使用手册（全）
侠说java8-LocalDateTime等时间使用手册（全），先mark后看
学习分享Java容器服务器：
https://aijishu.com/a/1060000000087793


# 源码个人解读

## TemporalAccessor 

`java.time.temporal.TemporalAccessor`

翻译:

> 框架级别的接口定义对时间对象（例如日期，时间，偏移量或这些的某种组合）的只读访问。
> 这是日期，时间和偏移对象的基本接口类型。它由可以提供信息作为字段或查询的那些类实现。
> 大多数日期和时间信息可以表示为数字。使用TemporalField对它们进行建模，并使用长号保留数字以处理较大的值。年，月和月日是字段的简单示例，但它们还包括即时数和偏移量。有关标准字段集，请参见ChronoField。
> 日期/时间信息不能用数字表示两个日期/时间信息。可以使用TemporalQuery上定义的静态方法通过查询来访问它们。
> 子接口Temporal将这个定义扩展到一个还支持对更完整的临时对象进行调整和操纵的定义。
> 该接口是框架级别的接口，不应在应用程序代码中广泛使用。相反，应用程序应创建并传递具体类型的实例，例如LocalDate。造成这种情况的原因很多，部分原因是该接口的实现可能在ISO以外的日历系统中。请参阅java.time.chrono.ChronoLocalDate以获得有关该问题的更完整讨论。

### 接口方法：isSupported()

方法签名：`boolean isSupported(TemporalField field);`

> 检查是否支持指定的字段。
> 这检查是否可以查询指定字段的日期时间。 如果为false，则调用range和get方法将引发异常。
>
> 参数：
> field –要检查的字段，null返回false
> 返回值：
> 如果可以查询该日期时间，则为true，否则为false
> implSpec：
> 实现必须检查并处理ChronoField中定义的所有字段。 如果支持该字段，则必须返回true，否则必须返回false。
> 如果该字段不是ChronoField，则通过调用TemporalField.isSupportedBy（TemporalAccessor）并将其作为参数来获取此方法的结果。
> 实现必须确保在调用此只读方法时，不会更改任何可观察的状态。

### 接口方法：range(TemporalField field)

方法签名：`ValueRange range(TemporalField field)`

> 获取指定字段的有效值范围。
> 所有字段都可以表示为长整数。此方法返回一个对象，该对象描述该值的有效范围。该时间对象的值用于增强返回范围的准确性。如果日期时间不能返回范围，则由于该字段不受支持或出于其他原因，将引发异常。
> 请注意，结果仅描述了最小和最大有效值，重要的是不要过多地阅读这些值。例如，在该范围内可能存在对该字段无效的值。
>
> 参数：
> field –查询范围的字段，不为null
> 返回值：
> 该字段的有效值范围，不为null
> 抛出：
> DateTimeException-如果无法获取该字段的范围
> UnsupportedTemporalTypeException-如果不支持该字段
> implSpec：
> 实现必须检查并处理ChronoField中定义的所有字段。如果支持该字段，则必须返回该字段的范围。如果不受支持，则必须引发UnsupportedTemporalTypeException。
> 如果该字段不是ChronoField，则通过调用TemporalField.rangeRefinedBy（TemporalAccessorl）并将其作为参数来获取此方法的结果。
> 实现必须确保在调用此只读方法时，不会更改任何可观察的状态。
> 默认实现必须与以下代码等效：
>    if（ChronoField的instance字段）{if（isSupported（field））{return field.range（）; }抛出新的UnsupportedTemporalTypeException（“不支持的字段：” +字段）； } return field.rangeRefinedBy（this）;

### 接口方法：int get(TemporalField field)

> 以int形式获取指定字段的值。
> 这将查询日期时间以获取指定字段的值。返回的值将始终在该字段的值的有效范围内。如果日期时间由于该字段不受支持或出于某些其他原因而无法返回该值，则将引发异常。
>
> 参数：
> field-要获取的字段，不为null
> 返回值：
> 有效值范围内的字段值
> 抛出：
> DateTimeException-如果无法获取该字段的值或该值超出该字段的有效值范围
> UnsupportedTemporalTypeException-如果不支持该字段或值的范围超出int
> ArithmeticException-如果发生数字溢出
> implSpec：
> 实现必须检查并处理ChronoField中定义的所有字段。如果该字段受支持并且具有int范围，则必须返回该字段的值。如果不受支持，则必须引发UnsupportedTemporalTypeException。
> 如果该字段不是ChronoField，则通过调用TemporalField.getFrom（TemporalAccessor）并将其作为参数来获取此方法的结果。
> 实现必须确保在调用此只读方法时，不会更改任何可观察的状态。
> 默认实现必须与以下代码等效：
>    if（range（field）.isIntValue（））{返回range（field）.checkValidIntValue（getLong（field），field）; }抛出新的UnsupportedTemporalTypeException（“无效字段” +字段+“ +对于get（）方法，请使用getLong（）代替”）；

### 接口方法：default <R> R query(TemporalQuery<R> query)