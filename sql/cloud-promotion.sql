-- 促销服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_promotion;

-- 切换到促销数据库
\c cloud_promotion;

-- 优惠券表
CREATE TABLE coupons (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    type SMALLINT NOT NULL COMMENT '优惠券类型：1-满减券，2-折扣券，3-无门槛券',
    amount DECIMAL(10,2) NOT NULL COMMENT '金额，type=1,3时必填',
    min_point DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '使用门槛，0表示无门槛',
    start_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '结束时间',
    total INTEGER NOT NULL DEFAULT 0 COMMENT '发行数量',
    used INTEGER NOT NULL DEFAULT 0 COMMENT '已使用数量',
    per_limit INTEGER NOT NULL DEFAULT 1 COMMENT '每人限领数量',
    use_type SMALLINT NOT NULL DEFAULT 1 COMMENT '使用类型：1-全场通用，2-指定分类，3-指定商品',
    platform SMALLINT NOT NULL DEFAULT 0 COMMENT '使用平台：0-全平台，1-移动端，2-PC端',
    note VARCHAR(500) COMMENT '备注',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-已过期，3-已关闭',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 优惠券分类关系表
CREATE TABLE coupon_categories (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL COMMENT '优惠券ID',
    category_id BIGINT NOT NULL COMMENT '分类ID',
    category_name VARCHAR(100) NOT NULL COMMENT '分类名称',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(coupon_id, category_id)
);

-- 优惠券商品关系表
CREATE TABLE coupon_products (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL COMMENT '优惠券ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    product_name VARCHAR(200) NOT NULL COMMENT '商品名称',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(coupon_id, product_id)
);

-- 用户优惠券表
CREATE TABLE user_coupons (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL COMMENT '优惠券ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    order_id BIGINT COMMENT '订单ID',
    order_no VARCHAR(32) COMMENT '订单编号',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-未使用，2-已使用，3-已过期',
    use_time TIMESTAMP WITH TIME ZONE COMMENT '使用时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(coupon_id, user_id)
);

-- 促销活动表
CREATE TABLE promotions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '活动名称',
    type SMALLINT NOT NULL COMMENT '促销类型：1-满减，2-折扣，3-秒杀，4-特价，5-赠品',
    start_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '结束时间',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-未开始，2-进行中，3-已结束，4-已关闭',
    rules JSONB NOT NULL COMMENT '促销规则，JSON格式',
    description TEXT COMMENT '活动描述',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 秒杀活动商品表
CREATE TABLE seckill_products (
    id BIGSERIAL PRIMARY KEY,
    promotion_id BIGINT NOT NULL COMMENT '促销活动ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    sku_id BIGINT NOT NULL COMMENT 'SKU ID',
    seckill_price DECIMAL(10,2) NOT NULL COMMENT '秒杀价格',
    seckill_stock INTEGER NOT NULL COMMENT '秒杀库存',
    seckill_limit INTEGER NOT NULL DEFAULT 1 COMMENT '每人限购数量',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-未开始，2-进行中，3-已结束，4-已关闭',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(promotion_id, product_id, sku_id)
);

-- 创建索引
CREATE INDEX idx_coupons_type ON coupons(type);
CREATE INDEX idx_coupons_status ON coupons(status);
CREATE INDEX idx_coupons_start_time ON coupons(start_time);
CREATE INDEX idx_coupons_end_time ON coupons(end_time);

CREATE INDEX idx_coupon_categories_coupon_id ON coupon_categories(coupon_id);
CREATE INDEX idx_coupon_categories_category_id ON coupon_categories(category_id);

CREATE INDEX idx_coupon_products_coupon_id ON coupon_products(coupon_id);
CREATE INDEX idx_coupon_products_product_id ON coupon_products(product_id);

CREATE INDEX idx_user_coupons_coupon_id ON user_coupons(coupon_id);
CREATE INDEX idx_user_coupons_user_id ON user_coupons(user_id);
CREATE INDEX idx_user_coupons_status ON user_coupons(status);

CREATE INDEX idx_promotions_type ON promotions(type);
CREATE INDEX idx_promotions_status ON promotions(status);
CREATE INDEX idx_promotions_start_time ON promotions(start_time);
CREATE INDEX idx_promotions_end_time ON promotions(end_time);

CREATE INDEX idx_seckill_products_promotion_id ON seckill_products(promotion_id);
CREATE INDEX idx_seckill_products_product_id ON seckill_products(product_id);
CREATE INDEX idx_seckill_products_sku_id ON seckill_products(sku_id);
CREATE INDEX idx_seckill_products_status ON seckill_products(status);
