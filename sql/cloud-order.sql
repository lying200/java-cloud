-- 订单服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_order;

-- 切换到订单数据库
\c cloud_order;

-- 购物车表
CREATE TABLE shopping_carts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    sku_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    checked BOOLEAN NOT NULL DEFAULT TRUE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE (user_id, sku_id)
);

-- 订单表
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_no VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    pay_amount DECIMAL(10,2) NOT NULL COMMENT '实付金额',
    freight_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '运费',
    promotion_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '促销优惠金额',
    coupon_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠券抵扣金额',
    point_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '积分抵扣金额',
    pay_type SMALLINT COMMENT '支付方式：1-支付宝，2-微信，3-银联',
    source SMALLINT NOT NULL DEFAULT 1 COMMENT '订单来源：1-PC，2-APP，3-小程序',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '订单状态：1-待付款，2-待发货，3-待收货，4-已完成，5-已关闭',
    pay_time TIMESTAMP COMMENT '支付时间',
    delivery_time TIMESTAMP COMMENT '发货时间',
    receive_time TIMESTAMP COMMENT '收货时间',
    comment_time TIMESTAMP COMMENT '评价时间',
    receiver_name VARCHAR(50) NOT NULL,
    receiver_mobile VARCHAR(20) NOT NULL,
    receiver_province VARCHAR(50) NOT NULL,
    receiver_city VARCHAR(50) NOT NULL,
    receiver_district VARCHAR(50) NOT NULL,
    receiver_address VARCHAR(200) NOT NULL,
    note VARCHAR(500) COMMENT '订单备注',
    confirm_status SMALLINT NOT NULL DEFAULT 0 COMMENT '确认收货状态：0-未确认，1-已确认',
    delete_status SMALLINT NOT NULL DEFAULT 0 COMMENT '删除状态：0-未删除，1-已删除',
    payment_sn VARCHAR(50) COMMENT '支付流水号',
    delivery_company VARCHAR(50) COMMENT '物流公司',
    delivery_sn VARCHAR(50) COMMENT '物流单号',
    auto_confirm_day INTEGER NOT NULL DEFAULT 7 COMMENT '自动确认收货天数',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 订单商品表
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    order_no VARCHAR(50) NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    sku_id BIGINT NOT NULL,
    sku_code VARCHAR(50) NOT NULL,
    sku_name VARCHAR(200) NOT NULL,
    product_image VARCHAR(255),
    purchase_price DECIMAL(10,2) NOT NULL COMMENT '购买价格',
    purchase_quantity INTEGER NOT NULL DEFAULT 1 COMMENT '购买数量',
    promotion_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '商品促销分解金额',
    coupon_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠券优惠分解金额',
    point_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '积分优惠分解金额',
    real_amount DECIMAL(10,2) NOT NULL COMMENT '该商品经过优惠后的分解金额',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 订单操作历史表
CREATE TABLE order_histories (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    order_no VARCHAR(50) NOT NULL,
    operator_type SMALLINT NOT NULL COMMENT '操作人类型：1-用户，2-系统，3-后台管理员',
    operator_id BIGINT COMMENT '操作人ID',
    operator_name VARCHAR(50) COMMENT '操作人名称',
    order_status SMALLINT NOT NULL COMMENT '订单状态：1-待付款，2-待发货，3-待收货，4-已完成，5-已关闭',
    note VARCHAR(500) COMMENT '操作备注',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 订单支付记录表
CREATE TABLE order_payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    order_no VARCHAR(50) NOT NULL,
    payment_sn VARCHAR(50) NOT NULL COMMENT '支付流水号',
    pay_amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    pay_type SMALLINT NOT NULL COMMENT '支付方式：1-支付宝，2-微信，3-银联',
    pay_status SMALLINT NOT NULL DEFAULT 1 COMMENT '支付状态：1-待支付，2-支付成功，3-支付失败',
    callback_content TEXT COMMENT '回调内容',
    callback_time TIMESTAMP COMMENT '回调时间',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 订单退货申请表
CREATE TABLE order_returns (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    order_no VARCHAR(50) NOT NULL,
    sku_id BIGINT NOT NULL,
    return_quantity INTEGER NOT NULL DEFAULT 1 COMMENT '退货数量',
    return_name VARCHAR(50) NOT NULL COMMENT '退货人姓名',
    return_mobile VARCHAR(20) NOT NULL COMMENT '退货人电话',
    return_reason VARCHAR(200) NOT NULL COMMENT '退货原因',
    description TEXT COMMENT '问题描述',
    proof_images TEXT[] COMMENT '凭证图片，JSON数组',
    handle_time TIMESTAMP COMMENT '处理时间',
    handle_note VARCHAR(500) COMMENT '处理备注',
    handle_man VARCHAR(50) COMMENT '处理人员',
    receive_man VARCHAR(50) COMMENT '收货人员',
    receive_time TIMESTAMP COMMENT '收货时间',
    receive_note VARCHAR(500) COMMENT '收货备注',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '申请状态：1-待处理，2-已同意，3-已拒绝，4-已完成',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 创建索引
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_order_no ON orders(order_no);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_sku_id ON order_items(sku_id);
CREATE INDEX idx_order_histories_order_id ON order_histories(order_id);
CREATE INDEX idx_order_payments_order_id ON order_payments(order_id);
CREATE INDEX idx_order_returns_order_id ON order_returns(order_id);
