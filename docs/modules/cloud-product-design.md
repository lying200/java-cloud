# Cloud Product 模块设计文档

## 1. 模块概述

`cloud-product` 模块是商品中心服务，负责商品信息管理、分类管理、库存管理、商品搜索等核心功能。采用CQRS模式，实现商品数据的读写分离，提供高性能的商品搜索服务。

## 2. 核心功能设计

### 2.1 商品管理

#### 2.1.1 商品模型
```java
public class Product {
    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private Long categoryId;
    private Long brandId;
    private String mainImage;
    private List<String> subImages;
    private Integer status;
    private Integer stock;
    private String unit;
    private Double weight;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
```

#### 2.1.2 SKU模型
```java
public class Sku {
    private Long id;
    private Long productId;
    private String skuCode;
    private String specifications;
    private BigDecimal price;
    private Integer stock;
    private String image;
}
```

### 2.2 分类管理

#### 2.2.1 分类模型
```java
public class Category {
    private Long id;
    private String name;
    private Long parentId;
    private Integer level;
    private Integer sort;
    private String icon;
    private Boolean isLeaf;
    private String path;
}
```

#### 2.2.2 分类树
- 多级分类
- 动态扩展
- 排序支持
- 完整路径

### 2.3 库存管理

#### 2.3.1 库存模型
```java
public class Stock {
    private Long id;
    private Long productId;
    private Long skuId;
    private Integer available;
    private Integer locked;
    private Integer total;
    private String warehouseCode;
}
```

#### 2.3.2 库存操作
- 库存查询
- 库存锁定
- 库存释放
- 库存预警

### 2.4 商品搜索

#### 2.4.1 搜索模型
```java
public class ProductSearchDTO {
    private String keyword;
    private Long categoryId;
    private Long brandId;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private List<String> tags;
    private String sort;
    private Integer page;
    private Integer size;
}
```

#### 2.4.2 搜索功能
- 全文搜索
- 分面搜索
- 价格区间
- 排序过滤
- 高亮显示

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- Spring Data JPA
- Spring Data Elasticsearch

### 3.2 存储方案
- PostgreSQL（商品基础数据）
- Elasticsearch（商品搜索）
- Redis（缓存）
- MinIO（图片存储）

### 3.3 消息队列
- RabbitMQ（库存变更）

## 4. 数据模型

### 4.1 商品表
```sql
CREATE TABLE products (
    id bigserial PRIMARY KEY,
    name varchar(200) NOT NULL,
    description text,
    price decimal(10,2) NOT NULL,
    category_id bigint NOT NULL,
    brand_id bigint NOT NULL,
    main_image varchar(255) NOT NULL,
    sub_images jsonb,
    status smallint NOT NULL DEFAULT 1,
    unit varchar(20),
    weight decimal(10,2),
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0,
    deleted boolean NOT NULL DEFAULT false
);
```

### 4.2 SKU表
```sql
CREATE TABLE product_skus (
    id bigserial PRIMARY KEY,
    product_id bigint NOT NULL,
    sku_code varchar(100) NOT NULL UNIQUE,
    specifications jsonb NOT NULL,
    price decimal(10,2) NOT NULL,
    stock integer NOT NULL DEFAULT 0,
    image varchar(255),
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0,
    deleted boolean NOT NULL DEFAULT false,
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### 4.3 库存表
```sql
CREATE TABLE product_stocks (
    id bigserial PRIMARY KEY,
    product_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    available integer NOT NULL DEFAULT 0,
    locked integer NOT NULL DEFAULT 0,
    warehouse_code varchar(50) NOT NULL,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (sku_id) REFERENCES product_skus(id)
);
```

## 5. 接口设计

### 5.1 商品接口
```java
@RestController
@RequestMapping("/api/v1/products")
public class ProductController {
    @PostMapping
    public ProductVO createProduct(@Valid @RequestBody ProductCreateDTO request);
    
    @PutMapping("/{id}")
    public ProductVO updateProduct(@PathVariable Long id, @Valid @RequestBody ProductUpdateDTO request);
    
    @GetMapping("/{id}")
    public ProductVO getProductById(@PathVariable Long id);
    
    @GetMapping("/search")
    public Page<ProductVO> searchProducts(ProductSearchDTO query, Pageable pageable);
}
```

### 5.2 库存接口
```java
@RestController
@RequestMapping("/api/v1/stocks")
public class StockController {
    @PostMapping("/lock")
    public Boolean lockStock(@Valid @RequestBody StockLockDTO request);
    
    @PostMapping("/release")
    public Boolean releaseStock(@Valid @RequestBody StockReleaseDTO request);
    
    @GetMapping("/{productId}")
    public StockVO getProductStock(@PathVariable Long productId);
}
```

## 6. 搜索设计

### 6.1 索引映射
```json
{
  "mappings": {
    "properties": {
      "id": { "type": "long" },
      "name": { 
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart"
      },
      "description": {
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart"
      },
      "price": { "type": "double" },
      "categoryId": { "type": "long" },
      "brandId": { "type": "long" },
      "tags": { "type": "keyword" }
    }
  }
}
```

### 6.2 搜索实现
```java
@Service
public class ProductSearchService {
    @Autowired
    private ElasticsearchRestTemplate elasticsearchTemplate;
    
    public SearchPage<ProductDoc> search(ProductSearchDTO query) {
        NativeSearchQuery searchQuery = buildSearchQuery(query);
        return elasticsearchTemplate.search(searchQuery, ProductDoc.class);
    }
}
```

## 7. 缓存设计

### 7.1 缓存策略
```java
@Cacheable(value = "product", key = "#id")
public ProductVO getProductById(Long id) {
    // 获取商品信息
}

@CacheEvict(value = "product", key = "#id")
public void updateProduct(Long id, ProductUpdateDTO request) {
    // 更新商品信息
}
```

### 7.2 库存缓存
```java
@Cacheable(value = "stock", key = "#productId")
public StockVO getProductStock(Long productId) {
    // 获取库存信息
}
```

## 8. 消息事件

### 8.1 库存变更事件
```java
public class StockChangeEvent {
    private Long productId;
    private Long skuId;
    private Integer quantity;
    private StockOperationType operationType;
    private String orderId;
    private LocalDateTime occurTime;
}
```

### 8.2 商品更新事件
```java
public class ProductUpdateEvent {
    private Long productId;
    private String name;
    private BigDecimal price;
    private LocalDateTime updateTime;
}
```

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-product
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: cloud-product
          image: cloud-product:latest
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
- 商品总数
- SKU总数
- 库存预警数
- 搜索次数

### 10.2 性能指标
- 搜索响应时间
- 缓存命中率
- 库存操作TPS

## 11. 测试策略

### 11.1 单元测试
- 业务逻辑测试
- 库存操作测试
- 搜索功能测试

### 11.2 性能测试
- 搜索性能测试
- 库存并发测试
- 缓存性能测试

## 12. 注意事项

### 12.1 性能优化
- 搜索优化
- 缓存策略
- 库存并发控制

### 12.2 数据一致性
- 库存一致性
- 缓存一致性
- 搜索数据同步

### 12.3 高可用设计
- 服务容错
- 数据备份
- 限流降级
