# Cloud Promotion 模块设计文档

## 1. 模块概述

`cloud-promotion` 模块是营销中心服务，负责各类促销活动管理、优惠券管理、秒杀活动、积分商城等营销功能。采用领域驱动设计，实现营销领域的完整业务能力。

## 2. 核心功能设计

### 2.1 优惠券管理

#### 2.1.1 优惠券模型
```java
public class Coupon {
    private Long id;
    private String name;
    private String code;
    private Integer type;
    private BigDecimal amount;
    private BigDecimal minAmount;
    private Integer quantity;
    private Integer usedQuantity;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String description;
    private Integer status;
}
```

#### 2.1.2 用户优惠券
```java
public class UserCoupon {
    private Long id;
    private Long userId;
    private Long couponId;
    private Integer status;
    private LocalDateTime useTime;
    private String orderNo;
    private LocalDateTime obtainTime;
}
```

### 2.2 促销活动

#### 2.2.1 活动模型
```java
public class Promotion {
    private Long id;
    private String name;
    private Integer type;
    private String rules;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String description;
    private Integer status;
    private Integer priority;
}
```

#### 2.2.2 活动规则
- 满减活动
- 折扣活动
- 特价活动
- N元N件
- 组合优惠

### 2.3 秒杀活动

#### 2.3.1 秒杀模型
```java
public class Seckill {
    private Long id;
    private Long productId;
    private Long skuId;
    private BigDecimal seckillPrice;
    private Integer stockCount;
    private Integer limitCount;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer status;
}
```

#### 2.3.2 秒杀功能
- 商品管理
- 库存管理
- 订单处理
- 防刷限制
- 性能优化

### 2.4 积分商城

#### 2.4.1 积分商品
```java
public class PointsProduct {
    private Long id;
    private String name;
    private String description;
    private Integer points;
    private Integer stock;
    private String image;
    private Integer status;
    private LocalDateTime createTime;
}
```

#### 2.4.2 积分记录
```java
public class PointsRecord {
    private Long id;
    private Long userId;
    private Integer points;
    private String type;
    private String description;
    private LocalDateTime createTime;
}
```

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- Spring Data JPA
- Spring Data Redis

### 3.2 存储方案
- PostgreSQL（基础数据）
- Redis（缓存、秒杀）
- RabbitMQ（异步消息）

### 3.3 分布式锁
- Redisson
- 分布式锁注解

## 4. 数据模型

### 4.1 优惠券表
```sql
CREATE TABLE coupons (
    id bigserial PRIMARY KEY,
    name varchar(100) NOT NULL,
    code varchar(32) NOT NULL UNIQUE,
    type smallint NOT NULL,
    amount decimal(10,2) NOT NULL,
    min_amount decimal(10,2) NOT NULL,
    quantity integer NOT NULL,
    used_quantity integer NOT NULL DEFAULT 0,
    start_time timestamp NOT NULL,
    end_time timestamp NOT NULL,
    description text,
    status smallint NOT NULL DEFAULT 1,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

### 4.2 促销活动表
```sql
CREATE TABLE promotions (
    id bigserial PRIMARY KEY,
    name varchar(100) NOT NULL,
    type smallint NOT NULL,
    rules jsonb NOT NULL,
    start_time timestamp NOT NULL,
    end_time timestamp NOT NULL,
    description text,
    status smallint NOT NULL DEFAULT 1,
    priority integer NOT NULL DEFAULT 0,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

### 4.3 秒杀活动表
```sql
CREATE TABLE seckills (
    id bigserial PRIMARY KEY,
    product_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    seckill_price decimal(10,2) NOT NULL,
    stock_count integer NOT NULL,
    limit_count integer NOT NULL DEFAULT 1,
    start_time timestamp NOT NULL,
    end_time timestamp NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

## 5. 接口设计

### 5.1 优惠券接口
```java
@RestController
@RequestMapping("/api/v1/coupons")
public class CouponController {
    @PostMapping
    public CouponVO createCoupon(@Valid @RequestBody CouponCreateDTO request);
    
    @PostMapping("/{id}/receive")
    public UserCouponVO receiveCoupon(@PathVariable Long id);
    
    @GetMapping("/user")
    public List<UserCouponVO> getUserCoupons(@RequestParam Integer status);
    
    @PostMapping("/verify")
    public CouponVerifyVO verifyCoupon(@Valid @RequestBody CouponVerifyDTO request);
}
```

### 5.2 秒杀接口
```java
@RestController
@RequestMapping("/api/v1/seckills")
public class SeckillController {
    @PostMapping("/{id}/order")
    public OrderVO createSeckillOrder(@PathVariable Long id, @Valid @RequestBody SeckillOrderDTO request);
    
    @GetMapping("/current")
    public List<SeckillVO> getCurrentSeckills();
    
    @GetMapping("/{id}/stock")
    public Integer getSeckillStock(@PathVariable Long id);
}
```

## 6. 缓存设计

### 6.1 优惠券缓存
```java
@Cacheable(value = "coupon", key = "#id")
public CouponVO getCouponById(Long id) {
    // 获取优惠券信息
}

@CacheEvict(value = "coupon", key = "#id")
public void updateCoupon(Long id, CouponUpdateDTO request) {
    // 更新优惠券信息
}
```

### 6.2 秒杀缓存
```java
@Cacheable(value = "seckill_stock", key = "#id")
public Integer getSeckillStock(Long id) {
    // 获取秒杀库存
}
```

## 7. 秒杀设计

### 7.1 秒杀预热
```java
@Scheduled(cron = "0 0/5 * * * ?")
public void prewarmSeckill() {
    // 1. 查询即将开始的秒杀活动
    // 2. 加载商品数据到缓存
    // 3. 准备库存数据
}
```

### 7.2 库存扣减
```java
@Transactional
public boolean deductStock(Long seckillId, Integer quantity) {
    String lockKey = "seckill:stock:" + seckillId;
    return redissonClient.getLock(lockKey).tryLock(() -> {
        // 扣减库存
    });
}
```

## 8. 消息事件

### 8.1 优惠券事件
```java
public class CouponReceiveEvent {
    private Long couponId;
    private Long userId;
    private LocalDateTime receiveTime;
}
```

### 8.2 秒杀事件
```java
public class SeckillOrderEvent {
    private Long seckillId;
    private Long userId;
    private String orderNo;
    private LocalDateTime createTime;
}
```

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-promotion
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: cloud-promotion
          image: cloud-promotion:latest
          ports:
            - containerPort: 8080
```

### 9.2 资源配置
```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

## 10. 监控指标

### 10.1 业务指标
- 优惠券领取量
- 优惠券使用率
- 秒杀成功率
- 活动转化率

### 10.2 性能指标
- 秒杀QPS
- 库存更新延迟
- 缓存命中率

## 11. 测试策略

### 11.1 单元测试
- 优惠券规则测试
- 秒杀流程测试
- 库存操作测试

### 11.2 性能测试
- 秒杀并发测试
- 优惠券并发测试
- 缓存性能测试

## 12. 注意事项

### 12.1 秒杀设计
- 防止超卖
- 限制重复购买
- 防止机器人

### 12.2 优惠券设计
- 防止重复领取
- 使用规则校验
- 并发控制

### 12.3 活动设计
- 活动规则灵活性
- 优惠叠加规则
- 活动优先级
