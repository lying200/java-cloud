-- 商品服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 商品分类表
CREATE TABLE product_categories (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT,
    name VARCHAR(100) NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    sort INTEGER NOT NULL DEFAULT 0,
    icon VARCHAR(200),
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_product_categories_name ON product_categories (name) WHERE NOT deleted;

COMMENT ON TABLE product_categories IS '商品分类表';
COMMENT ON COLUMN product_categories.parent_id IS '父级ID';
COMMENT ON COLUMN product_categories.name IS '分类名称';
COMMENT ON COLUMN product_categories.level IS '层级：1-一级，2-二级，3-三级';
COMMENT ON COLUMN product_categories.sort IS '排序';
COMMENT ON COLUMN product_categories.icon IS '图标URL';
COMMENT ON COLUMN product_categories.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN product_categories.deleted IS '是否删除';
COMMENT ON COLUMN product_categories.create_time IS '创建时间';
COMMENT ON COLUMN product_categories.update_time IS '更新时间';
COMMENT ON COLUMN product_categories.version IS '版本号';

-- 商品品牌表
CREATE TABLE product_brands (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    logo VARCHAR(200),
    description TEXT,
    sort INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_product_brands_name ON product_brands (name) WHERE NOT deleted;

COMMENT ON TABLE product_brands IS '商品品牌表';
COMMENT ON COLUMN product_brands.name IS '品牌名称';
COMMENT ON COLUMN product_brands.logo IS '品牌LOGO';
COMMENT ON COLUMN product_brands.description IS '品牌描述';
COMMENT ON COLUMN product_brands.sort IS '排序';
COMMENT ON COLUMN product_brands.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN product_brands.deleted IS '是否删除';
COMMENT ON COLUMN product_brands.create_time IS '创建时间';
COMMENT ON COLUMN product_brands.update_time IS '更新时间';
COMMENT ON COLUMN product_brands.version IS '版本号';

-- 商品属性表
CREATE TABLE product_attributes (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL DEFAULT 1,
    input_type SMALLINT NOT NULL DEFAULT 1,
    input_list VARCHAR(500),
    sort INTEGER NOT NULL DEFAULT 0,
    filter BOOLEAN NOT NULL DEFAULT FALSE,
    search BOOLEAN NOT NULL DEFAULT FALSE,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE product_attributes IS '商品属性表';
COMMENT ON COLUMN product_attributes.category_id IS '分类ID';
COMMENT ON COLUMN product_attributes.name IS '属性名称';
COMMENT ON COLUMN product_attributes.type IS '属性类型：1-规格，2-参数';
COMMENT ON COLUMN product_attributes.input_type IS '录入方式：1-手工录入，2-从列表中选取';
COMMENT ON COLUMN product_attributes.input_list IS '可选值列表，用逗号分隔';
COMMENT ON COLUMN product_attributes.sort IS '排序';
COMMENT ON COLUMN product_attributes.filter IS '是否支持筛选';
COMMENT ON COLUMN product_attributes.search IS '是否支持搜索';
COMMENT ON COLUMN product_attributes.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN product_attributes.deleted IS '是否删除';
COMMENT ON COLUMN product_attributes.create_time IS '创建时间';
COMMENT ON COLUMN product_attributes.update_time IS '更新时间';
COMMENT ON COLUMN product_attributes.version IS '版本号';

-- 商品表
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    brand_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    subtitle VARCHAR(200),
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    pic_url VARCHAR(200),
    album_pics TEXT,
    detail_html TEXT,
    unit VARCHAR(20),
    weight DECIMAL(10,2),
    service_ids VARCHAR(100),
    keywords VARCHAR(200),
    note VARCHAR(500),
    publish_status SMALLINT NOT NULL DEFAULT 1,
    recommend_status SMALLINT NOT NULL DEFAULT 0,
    verify_status SMALLINT NOT NULL DEFAULT 1,
    sort INTEGER NOT NULL DEFAULT 0,
    sale INTEGER NOT NULL DEFAULT 0,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_products_name ON products (name) WHERE NOT deleted;

COMMENT ON TABLE products IS '商品表';
COMMENT ON COLUMN products.category_id IS '分类ID';
COMMENT ON COLUMN products.brand_id IS '品牌ID';
COMMENT ON COLUMN products.name IS '商品名称';
COMMENT ON COLUMN products.subtitle IS '副标题';
COMMENT ON COLUMN products.description IS '商品描述';
COMMENT ON COLUMN products.price IS '销售价格';
COMMENT ON COLUMN products.original_price IS '市场价格';
COMMENT ON COLUMN products.pic_url IS '商品主图';
COMMENT ON COLUMN products.album_pics IS '商品图册，多个图片用逗号分隔';
COMMENT ON COLUMN products.detail_html IS '商品详情';
COMMENT ON COLUMN products.unit IS '商品单位';
COMMENT ON COLUMN products.weight IS '商品重量，单位：克';
COMMENT ON COLUMN products.service_ids IS '服务保证，多个用逗号分隔';
COMMENT ON COLUMN products.keywords IS '关键字';
COMMENT ON COLUMN products.note IS '备注';
COMMENT ON COLUMN products.publish_status IS '上架状态：1-上架，2-下架';
COMMENT ON COLUMN products.recommend_status IS '推荐状态：0-不推荐，1-推荐';
COMMENT ON COLUMN products.verify_status IS '审核状态：1-未审核，2-审核通过，3-审核不通过';
COMMENT ON COLUMN products.sort IS '排序';
COMMENT ON COLUMN products.sale IS '销量';
COMMENT ON COLUMN products.deleted IS '是否删除';
COMMENT ON COLUMN products.create_time IS '创建时间';
COMMENT ON COLUMN products.update_time IS '更新时间';
COMMENT ON COLUMN products.version IS '版本号';

-- 商品SKU表
CREATE TABLE product_skus (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    sku_code VARCHAR(100) NOT NULL,
    name VARCHAR(200) NOT NULL,
    spec_data JSONB NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    stock INTEGER NOT NULL DEFAULT 0,
    low_stock INTEGER NOT NULL DEFAULT 0,
    pic_url VARCHAR(200),
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_product_skus_sku_code ON product_skus (sku_code) WHERE NOT deleted;

COMMENT ON TABLE product_skus IS '商品SKU表';
COMMENT ON COLUMN product_skus.product_id IS '商品ID';
COMMENT ON COLUMN product_skus.sku_code IS 'SKU编码';
COMMENT ON COLUMN product_skus.name IS 'SKU名称';
COMMENT ON COLUMN product_skus.spec_data IS '规格数据，JSON格式';
COMMENT ON COLUMN product_skus.price IS '销售价格';
COMMENT ON COLUMN product_skus.original_price IS '市场价格';
COMMENT ON COLUMN product_skus.stock IS '库存';
COMMENT ON COLUMN product_skus.low_stock IS '预警库存';
COMMENT ON COLUMN product_skus.pic_url IS 'SKU主图';
COMMENT ON COLUMN product_skus.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN product_skus.deleted IS '是否删除';
COMMENT ON COLUMN product_skus.create_time IS '创建时间';
COMMENT ON COLUMN product_skus.update_time IS '更新时间';
COMMENT ON COLUMN product_skus.version IS '版本号';

-- 商品评价表
CREATE TABLE product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    sku_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    star SMALLINT NOT NULL DEFAULT 5,
    content TEXT,
    pics TEXT,
    video_url VARCHAR(200),
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE product_reviews IS '商品评价表';
COMMENT ON COLUMN product_reviews.product_id IS '商品ID';
COMMENT ON COLUMN product_reviews.sku_id IS 'SKU ID';
COMMENT ON COLUMN product_reviews.order_id IS '订单ID';
COMMENT ON COLUMN product_reviews.user_id IS '用户ID';
COMMENT ON COLUMN product_reviews.star IS '评分：1-5星';
COMMENT ON COLUMN product_reviews.content IS '评价内容';
COMMENT ON COLUMN product_reviews.pics IS '评价图片，多个图片用逗号分隔';
COMMENT ON COLUMN product_reviews.video_url IS '评价视频';
COMMENT ON COLUMN product_reviews.status IS '状态：1-待审核，2-已审核，3-已拒绝';
COMMENT ON COLUMN product_reviews.deleted IS '是否删除';
COMMENT ON COLUMN product_reviews.create_time IS '创建时间';
COMMENT ON COLUMN product_reviews.update_time IS '更新时间';
COMMENT ON COLUMN product_reviews.version IS '版本号';

-- 创建索引
CREATE INDEX idx_categories_parent_id ON product_categories(parent_id);
CREATE INDEX idx_categories_level ON product_categories(level);
CREATE INDEX idx_categories_status ON product_categories(status);

CREATE INDEX idx_brands_status ON product_brands(status);

CREATE INDEX idx_attributes_category_id ON product_attributes(category_id);
CREATE INDEX idx_attributes_type ON product_attributes(type);
CREATE INDEX idx_attributes_status ON product_attributes(status);

CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_products_publish_status ON products(publish_status);
CREATE INDEX idx_products_verify_status ON products(verify_status);
CREATE INDEX idx_products_recommend_status ON products(recommend_status);

CREATE INDEX idx_skus_product_id ON product_skus(product_id);
CREATE INDEX idx_skus_sku_code ON product_skus(sku_code);
CREATE INDEX idx_skus_status ON product_skus(status);

CREATE INDEX idx_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_reviews_sku_id ON product_reviews(sku_id);
CREATE INDEX idx_reviews_order_id ON product_reviews(order_id);
CREATE INDEX idx_reviews_user_id ON product_reviews(user_id);
CREATE INDEX idx_reviews_status ON product_reviews(status);
