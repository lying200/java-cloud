-- 促销服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_promotion;

-- 切换到促销数据库
\c cloud_promotion;

-- 优惠券表
CREATE TABLE coupons (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL COMMENT '优惠券类型：1-满减券，2-折扣券，3-立减券',
    amount DECIMAL(10,2) COMMENT '金额，type=1,3时必填',
    discount DECIMAL(4,2) COMMENT '折扣，type=2时必填',
    min_point DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '使用门槛，0表示无门槛',
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    total INTEGER NOT NULL DEFAULT -1 COMMENT '发行数量，-1表示不限制',
    used INTEGER NOT NULL DEFAULT 0 COMMENT '已使用数量',
    per_limit INTEGER NOT NULL DEFAULT 1 COMMENT '每人限领数量',
    use_type SMALLINT NOT NULL DEFAULT 1 COMMENT '使用类型：1-全场通用，2-指定分类，3-指定商品',
    note VARCHAR(200) COMMENT '备注',
    publish_count INTEGER NOT NULL DEFAULT 0 COMMENT '发行数量',
    use_count INTEGER NOT NULL DEFAULT 0 COMMENT '已使用数量',
    receive_count INTEGER NOT NULL DEFAULT 0 COMMENT '领取数量',
    enable_time TIMESTAMP COMMENT '可以领取的日期',
    code VARCHAR(50) COMMENT '优惠码',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-已关闭',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 优惠券分类关系表
CREATE TABLE coupon_categories (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    category_name VARCHAR(100) COMMENT '分类名称',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

-- 优惠券商品关系表
CREATE TABLE coupon_products (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200) COMMENT '商品名称',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

-- 用户优惠券表
CREATE TABLE user_coupons (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT COMMENT '订单ID',
    order_no VARCHAR(50) COMMENT '订单编号',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-未使用，2-已使用，3-已过期',
    use_time TIMESTAMP COMMENT '使用时间',
    get_type SMALLINT NOT NULL DEFAULT 1 COMMENT '获取类型：1-主动领取，2-后台发放，3-活动赠送',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

-- 促销活动表
CREATE TABLE promotions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL COMMENT '促销类型：1-满减，2-折扣，3-秒杀，4-特价，5-赠品',
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-未开始，2-进行中，3-已结束，4-已关闭',
    description TEXT,
    rules JSONB NOT NULL COMMENT '促销规则，JSON对象',
    priority INTEGER NOT NULL DEFAULT 0 COMMENT '优先级：越大优先级越高',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 促销商品关系表
CREATE TABLE promotion_products (
    id BIGSERIAL PRIMARY KEY,
    promotion_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200) COMMENT '商品名称',
    promotion_price DECIMAL(10,2) COMMENT '促销价格',
    promotion_stock INTEGER COMMENT '促销库存',
    promotion_limit INTEGER DEFAULT -1 COMMENT '每人限购数量，-1表示不限购',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id)
);

-- 秒杀场次表
CREATE TABLE seckill_sessions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 秒杀商品表
CREATE TABLE seckill_products (
    id BIGSERIAL PRIMARY KEY,
    promotion_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    seckill_price DECIMAL(10,2) NOT NULL,
    seckill_stock INTEGER NOT NULL,
    seckill_limit INTEGER NOT NULL DEFAULT 1,
    seckill_sort INTEGER NOT NULL DEFAULT 0,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id),
    FOREIGN KEY (session_id) REFERENCES seckill_sessions(id)
);

-- 创建索引
CREATE INDEX idx_coupons_status ON coupons(status);
CREATE INDEX idx_user_coupons_user_id ON user_coupons(user_id);
CREATE INDEX idx_user_coupons_coupon_id ON user_coupons(coupon_id);
CREATE INDEX idx_promotions_status ON promotions(status);
CREATE INDEX idx_promotion_products_promotion_id ON promotion_products(promotion_id);
CREATE INDEX idx_seckill_products_session_id ON seckill_products(session_id);
