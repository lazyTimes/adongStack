# 输入两个时间参数，遍历中间的所有日期：
```java
public static List<String> getBetweenDate(String start, String end){
        List<String> list = new ArrayList<>();
        LocalDate startDate = LocalDate.parse(start);
        LocalDate endDate = LocalDate.parse(end);

        long distance = ChronoUnit.DAYS.between(startDate, endDate);
        if (distance < 1) {
            return list;
        }
        Stream.iterate(startDate, d -> {
            return d.plusDays(1);
        }).limit(distance + 1).forEach(f -> {
            list.add(f.toString());
        });
        return list;
    }
```


# Date to LocalDateTime
```java
Date todayDate = new Date();

LocalDateTime ldt = todayDate.toInstant()
        .atZone( ZoneId.systemDefault() )
        .toLocalDateTime();

System.out.println(ldt);
//2019-05-16T19:22:12.773
```