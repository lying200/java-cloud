-- 促销服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 优惠券表
CREATE TABLE coupons (
                         id BIGSERIAL PRIMARY KEY,
                         name VARCHAR(100) NOT NULL,
                         type SMALLINT NOT NULL,
                         amount DECIMAL(10,2),
                         min_point DECIMAL(10,2),
                         start_time TIMESTAMP WITH TIME ZONE NOT NULL,
                         end_time TIMESTAMP WITH TIME ZONE NOT NULL,
                         total INTEGER NOT NULL,
                         used INTEGER NOT NULL DEFAULT 0,
                         per_limit INTEGER NOT NULL DEFAULT 1,
                         use_type SMALLINT NOT NULL,
                         platform_type SMALLINT NOT NULL DEFAULT 0,
                         product_category_ids VARCHAR(500),
                         product_ids VARCHAR(500),
                         code VARCHAR(50),
                         status SMALLINT NOT NULL DEFAULT 1,
                         deleted BOOLEAN NOT NULL DEFAULT FALSE,
                         create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_coupons_code ON coupons (code) WHERE NOT deleted;

COMMENT ON TABLE coupons IS '优惠券表';
COMMENT ON COLUMN coupons.name IS '优惠券名称';
COMMENT ON COLUMN coupons.type IS '优惠券类型：1-满减券，2-折扣券，3-立减券';
COMMENT ON COLUMN coupons.amount IS '金额/折扣';
COMMENT ON COLUMN coupons.min_point IS '使用门槛：0表示无门槛';
COMMENT ON COLUMN coupons.start_time IS '开始时间';
COMMENT ON COLUMN coupons.end_time IS '结束时间';
COMMENT ON COLUMN coupons.total IS '发行总量';
COMMENT ON COLUMN coupons.used IS '已使用数量';
COMMENT ON COLUMN coupons.per_limit IS '每人限领张数';
COMMENT ON COLUMN coupons.use_type IS '使用类型：0-全场通用，1-指定分类，2-指定商品';
COMMENT ON COLUMN coupons.platform_type IS '使用平台：0-全平台，1-移动端，2-PC端';
COMMENT ON COLUMN coupons.product_category_ids IS '产品分类ID，多个用逗号分隔';
COMMENT ON COLUMN coupons.product_ids IS '产品ID，多个用逗号分隔';
COMMENT ON COLUMN coupons.code IS '优惠码';
COMMENT ON COLUMN coupons.status IS '状态：1-未开始，2-进行中，3-已结束，4-已关闭';
COMMENT ON COLUMN coupons.deleted IS '是否删除';
COMMENT ON COLUMN coupons.create_time IS '创建时间';
COMMENT ON COLUMN coupons.update_time IS '更新时间';
COMMENT ON COLUMN coupons.version IS '版本号';

-- 用户优惠券表
CREATE TABLE user_coupons (
                              id BIGSERIAL PRIMARY KEY,
                              user_id BIGINT NOT NULL,
                              coupon_id BIGINT NOT NULL,
                              order_id BIGINT,
                              order_no VARCHAR(32),
                              status SMALLINT NOT NULL DEFAULT 1,
                              get_type SMALLINT NOT NULL DEFAULT 1,
                              get_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              use_time TIMESTAMP WITH TIME ZONE,
                              create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE user_coupons IS '用户优惠券表';
COMMENT ON COLUMN user_coupons.user_id IS '用户ID';
COMMENT ON COLUMN user_coupons.coupon_id IS '优惠券ID';
COMMENT ON COLUMN user_coupons.order_id IS '订单ID';
COMMENT ON COLUMN user_coupons.order_no IS '订单编号';
COMMENT ON COLUMN user_coupons.status IS '状态：1-未使用，2-已使用，3-已过期';
COMMENT ON COLUMN user_coupons.get_type IS '获取类型：1-主动领取，2-后台发放';
COMMENT ON COLUMN user_coupons.get_time IS '领取时间';
COMMENT ON COLUMN user_coupons.use_time IS '使用时间';
COMMENT ON COLUMN user_coupons.create_time IS '创建时间';
COMMENT ON COLUMN user_coupons.update_time IS '更新时间';
COMMENT ON COLUMN user_coupons.version IS '版本号';

-- 优惠券领取历史表
CREATE TABLE coupon_history (
                                id BIGSERIAL PRIMARY KEY,
                                coupon_id BIGINT NOT NULL,
                                user_id BIGINT NOT NULL,
                                get_type SMALLINT NOT NULL DEFAULT 1,
                                create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE coupon_history IS '优惠券领取历史表';
COMMENT ON COLUMN coupon_history.coupon_id IS '优惠券ID';
COMMENT ON COLUMN coupon_history.user_id IS '用户ID';
COMMENT ON COLUMN coupon_history.get_type IS '获取类型：1-主动领取，2-后台发放';
COMMENT ON COLUMN coupon_history.create_time IS '创建时间';

-- 创建索引
CREATE INDEX idx_coupons_status ON coupons(status);
CREATE INDEX idx_coupons_type ON coupons(type);

CREATE INDEX idx_user_coupons_user_id ON user_coupons(user_id);
CREATE INDEX idx_user_coupons_coupon_id ON user_coupons(coupon_id);
CREATE INDEX idx_user_coupons_status ON user_coupons(status);

CREATE INDEX idx_coupon_history_coupon_id ON coupon_history(coupon_id);
CREATE INDEX idx_coupon_history_user_id ON coupon_history(user_id);
