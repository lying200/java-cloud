# Cloud Common 模块设计文档

## 1. 模块概述

`cloud-common` 模块是整个系统的基础支撑模块，提供各个微服务共用的工具类、配置类、基础设施代码等。该模块不包含业务逻辑，专注于提供技术性的支持。

## 2. 核心功能设计

### 2.1 统一响应处理
```java
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    private long timestamp;
}
```

#### 2.1.1 响应码设计
- 2xx：成功响应
- 4xx：客户端错误
- 5xx：服务端错误

### 2.2 全局异常处理
- 基础异常类：`BaseException`
- 业务异常：`BusinessException`
- 验证异常：`ValidationException`
- 权限异常：`AuthenticationException`

### 2.3 通用工具类库

#### 2.3.1 日期时间工具
- 日期格式化
- 时区处理
- 日期计算

#### 2.3.2 字符串工具
- 字符串处理
- 模板渲染
- 正则表达式

#### 2.3.3 加密解密
- AES加密
- RSA加密
- MD5/SHA256哈希

### 2.4 分布式组件

#### 2.4.1 分布式锁
- Redis分布式锁
- Zookeeper分布式锁
- 注解式分布式锁

#### 2.4.2 分布式缓存
- Redis缓存抽象
- 多级缓存
- 缓存注解

#### 2.4.3 分布式ID生成
- 雪花算法
- UUID生成
- 自定义ID生成

### 2.5 数据库基础设施

#### 2.5.1 基础实体类
```java
public class BaseEntity {
    private Long id;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private String createBy;
    private String updateBy;
    private Integer version;
    private Boolean deleted;
}
```

#### 2.5.2 通用Mapper
- 基础CRUD操作
- 乐观锁支持
- 软删除支持

### 2.6 安全组件

#### 2.6.1 密码处理
- 密码加密
- 密码验证
- 密码策略

#### 2.6.2 数据脱敏
- 手机号脱敏
- 身份证脱敏
- 银行卡脱敏

### 2.7 验证工具

#### 2.7.1 参数验证
- JSR-303支持
- 自定义验证注解
- 验证组支持

#### 2.7.2 业务验证
- 业务规则验证
- 数据一致性验证

## 3. 技术选型

### 3.1 核心依赖
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- Project Reactor
- Jackson 2.x
- Hibernate Validator
- Apache Commons
- Guava

### 3.2 存储相关
- Spring Data JPA
- Spring Data Redis
- PostgreSQL Driver

### 3.3 安全相关
- Spring Security Crypto
- Bouncy Castle
- JWT

## 4. 关键设计决策

### 4.1 响应式支持
- 全面支持响应式编程
- 提供阻塞和非阻塞API
- 响应式工具类

### 4.2 线程安全
- 不可变对象设计
- 线程安全集合
- 原子操作支持

### 4.3 扩展性
- 接口优先
- 插件化设计
- SPI机制支持

## 5. 代码结构

```
com.cloudmall.common
├── annotation    // 注解
├── config       // 配置类
├── constant     // 常量定义
├── exception    // 异常类
├── model        // 模型类
│   ├── base     // 基础模型
│   └── dto      // 数据传输对象
├── util         // 工具类
├── validation   // 验证相关
└── web          // Web相关
```

## 6. 使用示例

### 6.1 统一响应
```java
@RestController
public class DemoController {
    @GetMapping("/demo")
    public Result<String> demo() {
        return Result.success("Hello World");
    }
}
```

### 6.2 分布式锁
```java
@DistributedLock(key = "#orderId")
public void processOrder(String orderId) {
    // 处理订单
}
```

### 6.3 参数验证
```java
public class UserDTO {
    @NotBlank(message = "用户名不能为空")
    private String username;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String mobile;
}
```

## 7. 注意事项

### 7.1 性能考虑
- 避免重复创建对象
- 使用线程池
- 合理使用缓存

### 7.2 安全考虑
- 密码等敏感信息加密
- 输入数据验证
- 防止SQL注入

### 7.3 可维护性
- 统一的编码规范
- 完善的注释
- 单元测试覆盖

## 8. 测试策略

### 8.1 单元测试
- 工具类测试
- 验证规则测试
- 异常处理测试

### 8.2 集成测试
- 缓存测试
- 分布式锁测试
- 数据库操作测试
