# Cloud Order 模块设计文档

## 1. 模块概述

`cloud-order` 模块是订单中心服务，负责订单全生命周期管理、购物车管理、支付集成和物流集成等核心功能。采用DDD领域驱动设计，实现订单领域的完整业务能力。

## 2. 核心功能设计

### 2.1 订单管理

#### 2.1.1 订单模型
```java
public class Order {
    private Long id;
    private String orderNo;
    private Long userId;
    private BigDecimal totalAmount;
    private BigDecimal payAmount;
    private BigDecimal freightAmount;
    private Integer status;
    private String paymentType;
    private LocalDateTime payTime;
    private LocalDateTime deliveryTime;
    private LocalDateTime receiveTime;
    private LocalDateTime createTime;
    private String remark;
}
```

#### 2.1.2 订单项模型
```java
public class OrderItem {
    private Long id;
    private Long orderId;
    private Long productId;
    private Long skuId;
    private String productName;
    private String skuCode;
    private String productImage;
    private BigDecimal price;
    private Integer quantity;
    private BigDecimal totalAmount;
}
```

### 2.2 购物车管理

#### 2.2.1 购物车模型
```java
public class CartItem {
    private Long id;
    private Long userId;
    private Long productId;
    private Long skuId;
    private Integer quantity;
    private Boolean selected;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
```

#### 2.2.2 购物车功能
- 添加商品
- 修改数量
- 选择商品
- 清空购物车
- 价格计算

### 2.3 支付管理

#### 2.3.1 支付模型
```java
public class Payment {
    private Long id;
    private String paymentNo;
    private String orderNo;
    private Long userId;
    private BigDecimal amount;
    private String paymentMethod;
    private String paymentChannel;
    private Integer status;
    private String transactionId;
    private LocalDateTime payTime;
}
```

#### 2.3.2 支付集成
- 支付宝支付
- 微信支付
- 银行卡支付
- 支付结果回调
- 退款处理

### 2.4 物流管理

#### 2.4.1 物流模型
```java
public class Logistics {
    private Long id;
    private String orderNo;
    private String logisticsNo;
    private String logisticsCompany;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private Integer status;
    private List<LogisticsTrace> traces;
}
```

#### 2.4.2 物流功能
- 物流信息查询
- 物流轨迹更新
- 签收确认
- 物流商对接

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- Spring Data JPA
- Spring Data Redis

### 3.2 存储方案
- PostgreSQL（订单数据）
- Redis（购物车、缓存）
- RabbitMQ（异步消息）
- Seata（分布式事务）

### 3.3 三方集成
- 支付宝SDK
- 微信支付SDK
- 物流查询API

## 4. 数据模型

### 4.1 订单表
```sql
CREATE TABLE orders (
    id bigserial PRIMARY KEY,
    order_no varchar(32) NOT NULL UNIQUE,
    user_id bigint NOT NULL,
    total_amount decimal(10,2) NOT NULL,
    pay_amount decimal(10,2) NOT NULL,
    freight_amount decimal(10,2) NOT NULL,
    status smallint NOT NULL,
    payment_type varchar(20),
    pay_time timestamp,
    delivery_time timestamp,
    receive_time timestamp,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark text,
    version integer NOT NULL DEFAULT 0,
    deleted boolean NOT NULL DEFAULT false
);
```

### 4.2 订单项表
```sql
CREATE TABLE order_items (
    id bigserial PRIMARY KEY,
    order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    product_name varchar(200) NOT NULL,
    sku_code varchar(100) NOT NULL,
    product_image varchar(255),
    price decimal(10,2) NOT NULL,
    quantity integer NOT NULL,
    total_amount decimal(10,2) NOT NULL,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
```

### 4.3 支付表
```sql
CREATE TABLE payments (
    id bigserial PRIMARY KEY,
    payment_no varchar(32) NOT NULL UNIQUE,
    order_no varchar(32) NOT NULL,
    user_id bigint NOT NULL,
    amount decimal(10,2) NOT NULL,
    payment_method varchar(20) NOT NULL,
    payment_channel varchar(20) NOT NULL,
    status smallint NOT NULL,
    transaction_id varchar(64),
    pay_time timestamp,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

## 5. 接口设计

### 5.1 订单接口
```java
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
    @PostMapping
    public OrderVO createOrder(@Valid @RequestBody OrderCreateDTO request);
    
    @GetMapping("/{id}")
    public OrderVO getOrderById(@PathVariable Long id);
    
    @PostMapping("/{id}/pay")
    public PaymentVO payOrder(@PathVariable Long id, @Valid @RequestBody PaymentCreateDTO request);
    
    @PostMapping("/{id}/cancel")
    public OrderVO cancelOrder(@PathVariable Long id);
}
```

### 5.2 购物车接口
```java
@RestController
@RequestMapping("/api/v1/cart")
public class CartController {
    @PostMapping("/items")
    public CartItemVO addToCart(@Valid @RequestBody CartItemAddDTO request);
    
    @PutMapping("/items/{id}")
    public CartItemVO updateCartItem(@PathVariable Long id, @Valid @RequestBody CartItemUpdateDTO request);
    
    @DeleteMapping("/items/{id}")
    public void removeFromCart(@PathVariable Long id);
    
    @GetMapping
    public List<CartItemVO> getCurrentCart();
}
```

## 6. 状态机设计

### 6.1 订单状态
```java
public enum OrderStatus {
    CREATED(1, "已创建"),
    PAID(2, "已支付"),
    DELIVERING(3, "配送中"),
    RECEIVED(4, "已收货"),
    FINISHED(5, "已完成"),
    CANCELLED(6, "已取消");
}
```

### 6.2 状态流转
```java
@StateMachine
public class OrderStateMachine {
    @Transition(from = "CREATED", to = "PAID")
    public void pay(Order order) {
        // 支付处理
    }
    
    @Transition(from = "PAID", to = "DELIVERING")
    public void deliver(Order order) {
        // 发货处理
    }
}
```

## 7. 分布式事务

### 7.1 Seata配置
```yaml
seata:
  tx-service-group: order_tx_group
  service:
    vgroup-mapping:
      order_tx_group: default
  registry:
    type: nacos
    nacos:
      server-addr: nacos:8848
```

### 7.2 事务示例
```java
@GlobalTransactional
public OrderVO createOrder(OrderCreateDTO request) {
    // 1. 创建订单
    // 2. 扣减库存
    // 3. 清空购物车
    // 4. 计算积分
}
```

## 8. 消息事件

### 8.1 订单创建事件
```java
public class OrderCreatedEvent {
    private String orderNo;
    private Long userId;
    private BigDecimal amount;
    private LocalDateTime createTime;
}
```

### 8.2 支付完成事件
```java
public class PaymentCompletedEvent {
    private String orderNo;
    private String paymentNo;
    private BigDecimal amount;
    private LocalDateTime payTime;
}
```

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-order
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: cloud-order
          image: cloud-order:latest
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
- 订单量
- 支付转化率
- 订单金额
- 退款率

### 10.2 性能指标
- 下单响应时间
- 支付响应时间
- 订单查询TPS

## 11. 测试策略

### 11.1 单元测试
- 订单流程测试
- 支付流程测试
- 状态机测试

### 11.2 集成测试
- 支付接口测试
- 物流接口测试
- 分布式事务测试

## 12. 注意事项

### 12.1 订单设计
- 订单号生成规则
- 价格精度处理
- 订单拆分策略

### 12.2 支付安全
- 支付信息加密
- 签名验证
- 防重复支付

### 12.3 高并发处理
- 订单峰值应对
- 库存超卖防护
- 支付并发控制
