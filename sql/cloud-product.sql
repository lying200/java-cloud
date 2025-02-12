-- 商品服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_product;

-- 切换到商品数据库
\c cloud_product;

-- 商品分类表
CREATE TABLE product_categories (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT NOT NULL DEFAULT 0,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(255),
    sort_order INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE product_categories IS '商品分类表';
COMMENT ON COLUMN product_categories.status IS '状态：1-正常，2-禁用';

-- 品牌表
CREATE TABLE brands (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    logo VARCHAR(255),
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE brands IS '品牌表';
COMMENT ON COLUMN brands.status IS '状态：1-正常，2-禁用';

-- 商品表
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    brand_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    subtitle VARCHAR(200),
    main_image VARCHAR(255),
    sub_images TEXT[],
    detail TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE products IS '商品表';
COMMENT ON COLUMN products.status IS '状态：1-在售，2-下架，3-删除';

-- 商品属性表
CREATE TABLE product_attributes (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value VARCHAR(255) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE product_attributes IS '商品属性表';

-- 商品SKU表
CREATE TABLE product_skus (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    sku_code VARCHAR(100) NOT NULL,
    attributes JSONB NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE product_skus IS '商品SKU表';
COMMENT ON COLUMN product_skus.status IS '状态：1-正常，2-禁用';

-- 商品评价表
CREATE TABLE product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    rating SMALLINT NOT NULL,
    content TEXT,
    images TEXT[],
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE product_reviews IS '商品评价表';
COMMENT ON COLUMN product_reviews.rating IS '评分：1-5星';
COMMENT ON COLUMN product_reviews.status IS '状态：1-显示，2-隐藏';

-- 创建索引
CREATE INDEX idx_categories_parent_id ON product_categories(parent_id);
CREATE INDEX idx_categories_status ON product_categories(status);

CREATE UNIQUE INDEX idx_brands_name ON brands(name) WHERE deleted = FALSE;
CREATE INDEX idx_brands_status ON brands(status);

CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_name ON products(name);

CREATE INDEX idx_attributes_product_id ON product_attributes(product_id);

CREATE UNIQUE INDEX idx_skus_code ON product_skus(sku_code);
CREATE INDEX idx_skus_product_id ON product_skus(product_id);
CREATE INDEX idx_skus_status ON product_skus(status);

CREATE INDEX idx_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_reviews_user_id ON product_reviews(user_id);
CREATE INDEX idx_reviews_order_id ON product_reviews(order_id);
CREATE INDEX idx_reviews_rating ON product_reviews(rating);
CREATE INDEX idx_reviews_status ON product_reviews(status);
