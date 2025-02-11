-- 商品服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_product;

-- 切换到商品数据库
\c cloud_product;

-- 商品分类表
CREATE TABLE product_categories (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(255),
    sort_order INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 品牌表
CREATE TABLE brands (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    logo VARCHAR(255),
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 商品SPU表（Standard Product Unit）
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    brand_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    subtitle VARCHAR(200),
    main_image VARCHAR(255),
    sub_images TEXT[] COMMENT '商品图片，JSON数组',
    detail TEXT,
    price_range VARCHAR(50) COMMENT '价格范围，例如：99-199',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-上架，2-下架',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);

-- 商品属性表
CREATE TABLE product_attributes (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    input_type SMALLINT NOT NULL DEFAULT 1 COMMENT '输入类型：1-手动输入，2-单选，3-多选',
    values TEXT[] COMMENT '可选值，JSON数组',
    sort_order INTEGER NOT NULL DEFAULT 0,
    search_type SMALLINT NOT NULL DEFAULT 1 COMMENT '检索类型：1-普通，2-关键字，3-范围',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES product_categories(id)
);

-- 商品SKU表（Stock Keeping Unit）
CREATE TABLE product_skus (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    sku_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    main_image VARCHAR(255),
    spec_values JSONB NOT NULL COMMENT '规格值，JSON对象',
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    low_stock INTEGER NOT NULL DEFAULT 0 COMMENT '库存预警值',
    sale INTEGER NOT NULL DEFAULT 0 COMMENT '销量',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 商品规格表
CREATE TABLE product_specs (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    values TEXT[] NOT NULL COMMENT '规格值，JSON数组',
    sort_order INTEGER NOT NULL DEFAULT 0,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 商品评价表
CREATE TABLE product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    sku_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    star INTEGER NOT NULL DEFAULT 5 COMMENT '评分：1-5星',
    content TEXT,
    images TEXT[] COMMENT '评价图片，JSON数组',
    reply TEXT COMMENT '商家回复',
    reply_time TIMESTAMP,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-显示，2-隐藏',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (sku_id) REFERENCES product_skus(id)
);

-- 创建索引
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_product_skus_product_id ON product_skus(product_id);
CREATE INDEX idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_product_reviews_sku_id ON product_reviews(sku_id);
CREATE INDEX idx_product_reviews_user_id ON product_reviews(user_id);
