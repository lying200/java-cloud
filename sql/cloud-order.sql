-- 订单服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_order;

-- 切换到订单数据库
\c cloud_order;

-- 购物车表
CREATE TABLE shopping_carts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    sku_id BIGINT NOT NULL COMMENT 'SKU ID',
    quantity INTEGER NOT NULL DEFAULT 1 COMMENT '数量',
    checked BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否选中',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(user_id, sku_id)
);

COMMENT ON TABLE shopping_carts IS '购物车表';

-- 订单表
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    pay_amount DECIMAL(10,2) NOT NULL COMMENT '实付金额',
    freight_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '运费金额',
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额',
    coupon_id BIGINT COMMENT '优惠券ID',
    pay_type SMALLINT COMMENT '支付方式：1-支付宝，2-微信',
    source SMALLINT NOT NULL DEFAULT 1 COMMENT '订单来源：1-APP，2-PC，3-小程序',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '订单状态：1-待付款，2-待发货，3-待收货，4-已完成，5-已关闭',
    payment_time TIMESTAMP WITH TIME ZONE COMMENT '支付时间',
    delivery_time TIMESTAMP WITH TIME ZONE COMMENT '发货时间',
    receive_time TIMESTAMP WITH TIME ZONE COMMENT '收货时间',
    comment_time TIMESTAMP WITH TIME ZONE COMMENT '评价时间',
    receiver_name VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    receiver_phone VARCHAR(20) NOT NULL COMMENT '收货人手机号',
    receiver_province VARCHAR(50) NOT NULL COMMENT '省份',
    receiver_city VARCHAR(50) NOT NULL COMMENT '城市',
    receiver_district VARCHAR(50) NOT NULL COMMENT '区县',
    receiver_address VARCHAR(200) NOT NULL COMMENT '详细地址',
    note VARCHAR(500) COMMENT '订单备注',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(order_no)
);

COMMENT ON TABLE orders IS '订单表';
COMMENT ON COLUMN orders.pay_type IS '支付方式：1-支付宝，2-微信';
COMMENT ON COLUMN orders.source IS '订单来源：1-APP，2-PC，3-小程序';
COMMENT ON COLUMN orders.status IS '订单状态：1-待付款，2-待发货，3-待收货，4-已完成，5-已关闭';

-- 订单项表
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    sku_id BIGINT NOT NULL COMMENT 'SKU ID',
    product_name VARCHAR(200) NOT NULL COMMENT '商品名称',
    sku_code VARCHAR(100) NOT NULL COMMENT 'SKU编码',
    product_image VARCHAR(255) COMMENT '商品图片',
    purchase_price DECIMAL(10,2) NOT NULL COMMENT '销售价格',
    quantity INTEGER NOT NULL COMMENT '购买数量',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '商品总金额',
    real_amount DECIMAL(10,2) NOT NULL COMMENT '实付金额',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE order_items IS '订单项表';

-- 订单支付表
CREATE TABLE order_payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    payment_no VARCHAR(32) NOT NULL COMMENT '支付流水号',
    payment_method SMALLINT NOT NULL COMMENT '支付方式：1-支付宝，2-微信',
    payment_amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    payment_time TIMESTAMP WITH TIME ZONE COMMENT '支付时间',
    payment_status SMALLINT NOT NULL DEFAULT 1 COMMENT '支付状态：1-待支付，2-支付中，3-支付成功，4-支付失败',
    callback_content TEXT COMMENT '回调内容',
    callback_time TIMESTAMP WITH TIME ZONE COMMENT '回调时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(payment_no),
    UNIQUE(order_no)
);

COMMENT ON TABLE order_payments IS '订单支付表';
COMMENT ON COLUMN order_payments.payment_method IS '支付方式：1-支付宝，2-微信';
COMMENT ON COLUMN order_payments.payment_status IS '支付状态：1-待支付，2-支付中，3-支付成功，4-支付失败';

-- 订单配送表
CREATE TABLE order_deliveries (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    delivery_no VARCHAR(32) NOT NULL COMMENT '物流单号',
    delivery_company VARCHAR(50) NOT NULL COMMENT '物流公司',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '配送状态：1-待发货，2-已发货，3-已签收',
    receiver_name VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    receiver_phone VARCHAR(20) NOT NULL COMMENT '收货人手机号',
    receiver_province VARCHAR(50) NOT NULL COMMENT '省份',
    receiver_city VARCHAR(50) NOT NULL COMMENT '城市',
    receiver_district VARCHAR(50) NOT NULL COMMENT '区县',
    receiver_address VARCHAR(200) NOT NULL COMMENT '详细地址',
    delivery_time TIMESTAMP WITH TIME ZONE COMMENT '发货时间',
    receive_time TIMESTAMP WITH TIME ZONE COMMENT '签收时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(delivery_no),
    UNIQUE(order_no)
);

COMMENT ON TABLE order_deliveries IS '订单配送表';
COMMENT ON COLUMN order_deliveries.status IS '配送状态：1-待发货，2-已发货，3-已签收';

-- 订单退货表
CREATE TABLE order_returns (
    id BIGSERIAL PRIMARY KEY,
    return_no VARCHAR(32) NOT NULL COMMENT '退货单号',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    return_amount DECIMAL(10,2) NOT NULL COMMENT '退款金额',
    return_type SMALLINT NOT NULL COMMENT '退货类型：1-仅退款，2-退货退款',
    return_reason VARCHAR(500) NOT NULL COMMENT '退货原因',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '退货状态：1-待处理，2-已同意，3-已拒绝，4-已完成',
    refuse_reason VARCHAR(500) COMMENT '拒绝原因',
    logistics_no VARCHAR(32) COMMENT '退货物流单号',
    logistics_company VARCHAR(50) COMMENT '物流公司',
    return_time TIMESTAMP WITH TIME ZONE COMMENT '退货时间',
    complete_time TIMESTAMP WITH TIME ZONE COMMENT '完成时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(return_no),
    UNIQUE(order_no)
);

COMMENT ON TABLE order_returns IS '订单退货表';
COMMENT ON COLUMN order_returns.return_type IS '退货类型：1-仅退款，2-退货退款';
COMMENT ON COLUMN order_returns.status IS '退货状态：1-待处理，2-已同意，3-已拒绝，4-已完成';

-- 订单操作历史表
CREATE TABLE order_histories (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    operator_id BIGINT NOT NULL COMMENT '操作人ID',
    operator_type SMALLINT NOT NULL COMMENT '操作人类型：1-用户，2-系统，3-后台管理员',
    order_status SMALLINT NOT NULL COMMENT '订单状态',
    action VARCHAR(100) NOT NULL COMMENT '操作行为',
    note VARCHAR(500) COMMENT '操作备注',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE order_histories IS '订单操作历史表';
COMMENT ON COLUMN order_histories.operator_type IS '操作人类型：1-用户，2-系统，3-后台管理员';
COMMENT ON COLUMN order_histories.order_status IS '订单状态：1-待付款，2-待发货，3-待收货，4-已完成，5-已关闭';

-- 创建索引
CREATE INDEX idx_carts_user_id ON shopping_carts(user_id);
CREATE INDEX idx_carts_sku_id ON shopping_carts(sku_id);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_create_time ON orders(create_time);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_order_no ON order_items(order_no);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_sku_id ON order_items(sku_id);

CREATE INDEX idx_payments_user_id ON order_payments(user_id);
CREATE INDEX idx_payments_status ON order_payments(payment_status);
CREATE INDEX idx_payments_create_time ON order_payments(create_time);

CREATE INDEX idx_deliveries_order_id ON order_deliveries(order_id);
CREATE INDEX idx_deliveries_status ON order_deliveries(status);

CREATE INDEX idx_returns_user_id ON order_returns(user_id);
CREATE INDEX idx_returns_status ON order_returns(status);
CREATE INDEX idx_returns_create_time ON order_returns(create_time);

CREATE INDEX idx_histories_order_id ON order_histories(order_id);
CREATE INDEX idx_histories_operator_id ON order_histories(operator_id);
CREATE INDEX idx_histories_create_time ON order_histories(create_time);
