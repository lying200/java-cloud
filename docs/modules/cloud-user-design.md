# Cloud User 模块设计文档

## 1. 模块概述

`cloud-user` 模块是用户中心服务，负责用户信息管理、账户管理、地址管理等核心功能。采用DDD领域驱动设计思想，实现用户领域的完整业务能力。

## 2. 核心功能设计

### 2.1 用户管理

#### 2.1.1 用户模型
```java
public class User {
    private Long id;
    private String username;
    private String mobile;
    private String email;
    private String nickname;
    private String avatar;
    private Integer status;
    private UserLevel level;
    private Integer points;
    private LocalDateTime registerTime;
}
```

#### 2.1.2 用户注册流程
1. 验证用户信息
2. 创建用户账号
3. 发送欢迎消息
4. 初始化用户数据

### 2.2 账户管理

#### 2.2.1 账户安全
- 密码管理
- 安全问题
- 登录历史
- 账户锁定

#### 2.2.2 账户绑定
- 手机绑定
- 邮箱绑定
- 社交账号绑定

### 2.3 收货地址

#### 2.3.1 地址模型
```java
public class Address {
    private Long id;
    private Long userId;
    private String receiver;
    private String mobile;
    private String province;
    private String city;
    private String district;
    private String detail;
    private Boolean isDefault;
    private String postcode;
}
```

#### 2.3.2 地址管理
- 新增地址
- 修改地址
- 删除地址
- 设置默认地址

### 2.4 会员体系

#### 2.4.1 会员等级
```java
public enum UserLevel {
    BRONZE(1, "青铜会员"),
    SILVER(2, "白银会员"),
    GOLD(3, "黄金会员"),
    PLATINUM(4, "铂金会员"),
    DIAMOND(5, "钻石会员");
}
```

#### 2.4.2 积分系统
- 积分获取
- 积分消费
- 积分明细
- 积分规则

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- Spring Data JPA
- Spring Security

### 3.2 存储方案
- PostgreSQL（用户数据）
- Redis（缓存）
- Elasticsearch（用户搜索）

### 3.3 消息队列
- RabbitMQ（异步通知）

## 4. 数据模型

### 4.1 用户表
```sql
CREATE TABLE users (
    id bigserial PRIMARY KEY,
    username varchar(100) NOT NULL UNIQUE,
    password varchar(100) NOT NULL,
    mobile varchar(20) UNIQUE,
    email varchar(100) UNIQUE,
    nickname varchar(100),
    avatar varchar(255),
    status smallint NOT NULL DEFAULT 1,
    level smallint NOT NULL DEFAULT 1,
    points integer NOT NULL DEFAULT 0,
    register_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0,
    deleted boolean NOT NULL DEFAULT false
);
```

### 4.2 地址表
```sql
CREATE TABLE user_addresses (
    id bigserial PRIMARY KEY,
    user_id bigint NOT NULL,
    receiver varchar(50) NOT NULL,
    mobile varchar(20) NOT NULL,
    province varchar(50) NOT NULL,
    city varchar(50) NOT NULL,
    district varchar(50) NOT NULL,
    detail varchar(200) NOT NULL,
    postcode varchar(10),
    is_default boolean NOT NULL DEFAULT false,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0,
    deleted boolean NOT NULL DEFAULT false,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 5. 接口设计

### 5.1 用户接口
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    @PostMapping
    public UserVO register(@Valid @RequestBody UserRegisterDTO request);
    
    @PutMapping("/{id}")
    public UserVO updateUser(@PathVariable Long id, @Valid @RequestBody UserUpdateDTO request);
    
    @GetMapping("/{id}")
    public UserVO getUserById(@PathVariable Long id);
    
    @GetMapping("/search")
    public Page<UserVO> searchUsers(UserQueryDTO query, Pageable pageable);
}
```

### 5.2 地址接口
```java
@RestController
@RequestMapping("/api/v1/addresses")
public class AddressController {
    @PostMapping
    public AddressVO createAddress(@Valid @RequestBody AddressCreateDTO request);
    
    @PutMapping("/{id}")
    public AddressVO updateAddress(@PathVariable Long id, @Valid @RequestBody AddressUpdateDTO request);
    
    @DeleteMapping("/{id}")
    public void deleteAddress(@PathVariable Long id);
    
    @GetMapping("/user/{userId}")
    public List<AddressVO> getUserAddresses(@PathVariable Long userId);
}
```

## 6. 缓存设计

### 6.1 缓存策略
```java
@Cacheable(value = "user", key = "#id")
public UserVO getUserById(Long id) {
    // 获取用户信息
}

@CacheEvict(value = "user", key = "#id")
public void updateUser(Long id, UserUpdateDTO request) {
    // 更新用户信息
}
```

### 6.2 缓存配置
```yaml
spring:
  cache:
    type: redis
    redis:
      time-to-live: 1h
      cache-null-values: true
```

## 7. 消息事件

### 7.1 用户注册事件
```java
public class UserRegisteredEvent {
    private Long userId;
    private String username;
    private String mobile;
    private LocalDateTime registerTime;
}
```

### 7.2 会员升级事件
```java
public class UserLevelUpgradedEvent {
    private Long userId;
    private UserLevel oldLevel;
    private UserLevel newLevel;
    private LocalDateTime upgradeTime;
}
```

## 8. 安全设计

### 8.1 密码加密
```java
@Configuration
public class SecurityConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
```

### 8.2 数据脱敏
```java
public class UserVO {
    private String mobile;
    
    public void setMobile(String mobile) {
        this.mobile = MaskUtil.maskMobile(mobile);
    }
}
```

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-user
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: cloud-user
          image: cloud-user:latest
          ports:
            - containerPort: 8080
```

### 9.2 资源配置
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 10. 监控指标

### 10.1 业务指标
- 注册用户数
- 活跃用户数
- 会员等级分布

### 10.2 性能指标
- 接口响应时间
- 缓存命中率
- 数据库连接数

## 11. 测试策略

### 11.1 单元测试
- 业务逻辑测试
- 数据验证测试
- 缓存测试

### 11.2 集成测试
- API接口测试
- 数据库操作测试
- 消息发送测试

## 12. 注意事项

### 12.1 性能优化
- 合理使用缓存
- 索引优化
- 分页查询

### 12.2 安全考虑
- 敏感数据加密
- 接口权限控制
- 防止用户信息泄露

### 12.3 可用性
- 数据备份
- 故障恢复
- 限流保护
