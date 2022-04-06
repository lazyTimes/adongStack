# springboot 日期配置

```application.properties
#指定日期
#spring.jackson.date-format=yyyy-MM-dd HH:mm:ss
#spring.jackson.time-zone=GMT+8
```

### 注册日期格式化

```java
package com.springboot.filter.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.format.FormatterRegistry;
import org.springframework.format.datetime.DateFormatter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class DafaFormartConfig implements WebMvcConfigurer{
    @Override
    public void addFormatters(FormatterRegistry registry) {

        registry.addFormatter(new DateFormatter("yyyy-MM-dd HH:mm:ss"));
        WebMvcConfigurer.super.addFormatters(registry);
    }
}
```

### 字段上添加

```java
@DateTimeFormat(pattern="yyyy-MM-dd")
```

