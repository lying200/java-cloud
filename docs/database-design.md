# 微服务数据库设计文档

本文档描述了微服务架构中各个服务的数据库表结构设计及其关系。

## 目录
- [认证服务(cloud-auth)](#认证服务)
- [用户服务(cloud-user)](#用户服务)
- [订单服务(cloud-order)](#订单服务)
- [商品服务(cloud-product)](#商品服务)
- [促销服务(cloud-promotion)](#促销服务)
- [消息服务(cloud-message)](#消息服务)
- [任务调度服务(cloud-job)](#任务调度服务)

## 认证服务

认证服务负责处理系统的认证和授权功能，实现了 OAuth2 协议。

```mermaid
erDiagram
    oauth2_clients ||--o{ oauth2_authorization_codes : "generates"
    oauth2_clients ||--o{ oauth2_access_tokens : "has"
    oauth2_clients ||--o{ oauth2_refresh_tokens : "has"
    oauth2_authorization_codes ||--o{ oauth2_access_tokens : "generates"
    oauth2_access_tokens ||--o{ oauth2_refresh_tokens : "has"

    oauth2_clients {
        bigint id PK
        varchar client_id UK
        varchar client_secret
        varchar client_name
        varchar redirect_uri
        varchar scopes
        smallint grant_types
        boolean enabled
    }

    oauth2_authorization_codes {
        bigint id PK
        varchar code UK
        bigint client_id FK
        bigint user_id
        varchar scopes
        timestamp expire_time
    }

    oauth2_access_tokens {
        bigint id PK
        varchar token_id UK
        bigint client_id FK
        bigint user_id
        varchar scopes
        timestamp expire_time
    }

    oauth2_refresh_tokens {
        bigint id PK
        varchar token_id UK
        bigint client_id FK
        bigint user_id
        varchar scopes
        timestamp expire_time
    }
```

## 用户服务

用户服务管理系统用户、角色和权限信息。

```mermaid
erDiagram
    users ||--o{ user_roles : "has"
    roles ||--o{ user_roles : "assigned to"
    roles ||--o{ role_permissions : "has"
    permissions ||--o{ role_permissions : "assigned to"
    users ||--o{ user_addresses : "has"

    users {
        bigint id PK
        varchar username UK
        varchar password
        varchar mobile UK
        varchar email UK
        varchar nickname
        varchar avatar
        smallint status
        boolean deleted
    }

    roles {
        bigint id PK
        varchar code UK
        varchar name
        smallint status
        boolean deleted
    }

    permissions {
        bigint id PK
        varchar code UK
        varchar name
        varchar url
        smallint type
        boolean deleted
    }

    user_roles {
        bigint user_id FK
        bigint role_id FK
    }

    role_permissions {
        bigint role_id FK
        bigint permission_id FK
    }

    user_addresses {
        bigint id PK
        bigint user_id FK
        varchar name
        varchar phone
        varchar province
        varchar city
        varchar district
        varchar address
        boolean default_status
    }
```

## 订单服务

订单服务处理购物车、订单、支付和物流等功能。

```mermaid
erDiagram
    orders ||--o{ order_items : "contains"
    orders ||--|| payments : "has"
    orders ||--|| deliveries : "has"
    orders ||--o{ returns : "may have"
    orders ||--o{ order_histories : "has"

    shopping_carts {
        bigint id PK
        bigint user_id FK
        bigint product_id FK
        bigint sku_id FK
        int quantity
        boolean checked
    }

    orders {
        bigint id PK
        varchar order_no UK
        bigint user_id FK
        decimal total_amount
        decimal pay_amount
        decimal freight_amount
        decimal discount_amount
        bigint coupon_id FK
        smallint status
        timestamp payment_time
        timestamp delivery_time
        timestamp receive_time
    }

    order_items {
        bigint id PK
        bigint order_id FK
        varchar order_no
        bigint product_id FK
        bigint sku_id FK
        varchar product_name
        decimal price
        int quantity
    }

    payments {
        bigint id PK
        varchar pay_no UK
        bigint order_id FK
        varchar order_no UK
        decimal pay_amount
        smallint pay_type
        smallint pay_status
    }

    deliveries {
        bigint id PK
        bigint order_id FK
        varchar order_no UK
        varchar delivery_no UK
        varchar company
        smallint status
    }

    returns {
        bigint id PK
        varchar return_no UK
        bigint order_id FK
        varchar order_no UK
        decimal return_amount
        smallint return_type
        smallint status
    }
```

## 商品服务

商品服务管理商品分类、品牌、商品和 SKU 信息。

```mermaid
erDiagram
    product_categories ||--o{ products : "contains"
    product_brands ||--o{ products : "has"
    products ||--o{ product_attributes : "has"
    products ||--o{ product_skus : "has"
    products ||--o{ product_reviews : "has"

    product_categories {
        bigint id PK
        bigint parent_id FK
        varchar name UK
        integer level
        integer sort
        varchar icon
        smallint status
        boolean deleted
    }

    product_brands {
        bigint id PK
        varchar name UK
        varchar logo
        text description
        integer sort
        smallint status
        boolean deleted
    }

    product_attributes {
        bigint id PK
        bigint category_id FK
        varchar name
        smallint type
        smallint input_type
        varchar input_list
        integer sort
        boolean filter
        boolean search
        smallint status
        boolean deleted
    }

    products {
        bigint id PK
        bigint category_id FK
        bigint brand_id FK
        varchar name UK
        varchar subtitle
        text description
        decimal price
        decimal original_price
        varchar pic_url
        text album_pics
        text detail_html
        varchar unit
        decimal weight
        varchar service_ids
        varchar keywords
        varchar note
        smallint publish_status
        smallint recommend_status
        smallint verify_status
        integer sort
        integer sale
        boolean deleted
    }

    product_skus {
        bigint id PK
        bigint product_id FK
        varchar sku_code UK
        varchar name
        jsonb spec_data
        decimal price
        decimal original_price
        integer stock
        integer low_stock
        varchar pic_url
        smallint status
        boolean deleted
    }

    product_reviews {
        bigint id PK
        bigint product_id FK
        bigint sku_id FK
        bigint order_id FK
        bigint user_id FK
        smallint star
        text content
        text pics
        varchar video_url
        smallint status
        boolean deleted
    }
```

## 促销服务

促销服务管理优惠券、促销活动等营销功能。

```mermaid
erDiagram
    promotions ||--o{ promotion_products : "applies to"
    promotions ||--o{ promotion_rules : "has"
    coupons ||--o{ coupon_records : "generates"

    promotions {
        bigint id PK
        varchar name
        varchar description
        smallint type
        timestamp start_time
        timestamp end_time
        smallint status
    }

    promotion_rules {
        bigint id PK
        bigint promotion_id FK
        smallint type
        decimal threshold
        decimal benefit
    }

    coupons {
        bigint id PK
        varchar name
        varchar code UK
        smallint type
        decimal threshold
        decimal amount
        int quantity
        timestamp start_time
        timestamp end_time
    }

    coupon_records {
        bigint id PK
        bigint coupon_id FK
        bigint user_id
        smallint status
        timestamp use_time
    }
```

## 消息服务

消息服务处理系统通知、短信、邮件等消息发送功能。

```mermaid
erDiagram
    message_templates ||--o{ messages : "generates"
    messages ||--o{ internal_messages : "has"

    message_templates {
        bigint id PK
        varchar code UK
        varchar name
        smallint type
        text title_template
        text content_template
        jsonb params
        smallint status
        boolean deleted
    }

    messages {
        bigint id PK
        bigint template_id FK
        varchar template_code
        smallint type
        varchar title
        text content
        varchar sender
        varchar receiver
        jsonb params
        smallint status
        timestamp send_time
    }

    internal_messages {
        bigint id PK
        bigint message_id FK
        bigint user_id
        varchar title
        text content
        boolean is_read
        timestamp read_time
    }

    message_configs {
        bigint id PK
        smallint type
        varchar name
        jsonb config
        smallint status
    }
```

## 任务调度服务

任务调度服务管理系统中的定时任务和批处理作业。

```mermaid
erDiagram
    jobs ||--o{ job_logs : "generates"
    jobs ||--o{ job_locks : "uses"

    jobs {
        bigint id PK
        varchar name UK
        varchar job_group
        varchar invoke_target
        varchar cron_expression
        smallint misfire_policy
        boolean concurrent
        smallint status
        varchar remark
        smallint notify_channel
        varchar notify_emails
        boolean deleted
    }

    job_logs {
        bigint id PK
        bigint job_id FK
        varchar name
        varchar job_group
        varchar invoke_target
        varchar job_message
        smallint status
        text exception_info
        timestamp start_time
        timestamp end_time
    }

    job_locks {
        bigint id PK
        varchar lock_name UK
        varchar lock_key
        varchar node_id
        timestamp lock_time
        timestamp expire_time
    }
```

## 设计说明

1. **主键设计**
   - 所有表使用 BIGSERIAL 类型的自增主键
   - 主键名统一为 id

2. **时间字段设计**
   - 使用 TIMESTAMP WITH TIME ZONE 类型存储时间
   - 创建时间字段名为 create_time
   - 更新时间字段名为 update_time

3. **软删除设计**
   - 使用 deleted 布尔字段标记删除状态
   - 默认值为 FALSE

4. **乐观锁设计**
   - 使用 version 整型字段实现乐观锁
   - 默认值为 0

5. **唯一约束设计**
   - 业务唯一字段都添加了唯一约束
   - 支持软删除的表的唯一约束会包含 WHERE deleted = FALSE 条件

6. **索引设计**
   - 对常用查询字段创建了索引
   - 创建索引时考虑了查询效率和维护成本的平衡

7. **字段注释**
   - 所有字段都添加了中文注释
   - 对于枚举值的字段，在注释中说明了每个值的含义

8. **微服务解耦**
   - 各个服务都使用独立的数据库
   - 服务间通过 ID 引用，不使用外键约束
   - 保持数据一致性通过应用层实现
