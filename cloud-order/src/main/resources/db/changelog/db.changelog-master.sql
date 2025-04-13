-- 订单服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 购物车表
CREATE TABLE shopping_carts (
                                id BIGSERIAL PRIMARY KEY,
                                user_id BIGINT NOT NULL,
                                product_id BIGINT NOT NULL,
                                sku_id BIGINT NOT NULL,
                                quantity INTEGER NOT NULL DEFAULT 1,
                                checked BOOLEAN NOT NULL DEFAULT TRUE,
                                create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                version INTEGER NOT NULL DEFAULT 0,
                                UNIQUE(user_id, sku_id)
);

COMMENT ON TABLE shopping_carts IS '购物车表';
COMMENT ON COLUMN shopping_carts.user_id IS '用户ID';
COMMENT ON COLUMN shopping_carts.product_id IS '商品ID';
COMMENT ON COLUMN shopping_carts.sku_id IS 'SKU ID';
COMMENT ON COLUMN shopping_carts.quantity IS '数量';
COMMENT ON COLUMN shopping_carts.checked IS '是否选中';
COMMENT ON COLUMN shopping_carts.create_time IS '创建时间';
COMMENT ON COLUMN shopping_carts.update_time IS '更新时间';
COMMENT ON COLUMN shopping_carts.version IS '版本号';

-- 订单表
CREATE TABLE orders (
                        id BIGSERIAL PRIMARY KEY,
                        order_no VARCHAR(32) NOT NULL,
                        user_id BIGINT NOT NULL,
                        total_amount DECIMAL(10,2) NOT NULL,
                        pay_amount DECIMAL(10,2) NOT NULL,
                        freight_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
                        discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
                        coupon_id BIGINT,
                        pay_type SMALLINT,
                        source SMALLINT NOT NULL DEFAULT 1,
                        status SMALLINT NOT NULL DEFAULT 1,
                        payment_time TIMESTAMP WITH TIME ZONE,
                        delivery_time TIMESTAMP WITH TIME ZONE,
                        receive_time TIMESTAMP WITH TIME ZONE,
                        comment_time TIMESTAMP WITH TIME ZONE,
                        receiver_name VARCHAR(50) NOT NULL,
                        receiver_phone VARCHAR(20) NOT NULL,
                        receiver_province VARCHAR(50) NOT NULL,
                        receiver_city VARCHAR(50) NOT NULL,
                        receiver_district VARCHAR(50) NOT NULL,
                        receiver_address VARCHAR(200) NOT NULL,
                        note VARCHAR(500),
                        deleted BOOLEAN NOT NULL DEFAULT FALSE,
                        create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        version INTEGER NOT NULL DEFAULT 0,
                        UNIQUE(order_no)
);

COMMENT ON TABLE orders IS '订单表';
COMMENT ON COLUMN orders.order_no IS '订单编号';
COMMENT ON COLUMN orders.user_id IS '用户ID';
COMMENT ON COLUMN orders.total_amount IS '订单总金额';
COMMENT ON COLUMN orders.pay_amount IS '实付金额';
COMMENT ON COLUMN orders.freight_amount IS '运费金额';
COMMENT ON COLUMN orders.discount_amount IS '优惠金额';
COMMENT ON COLUMN orders.coupon_id IS '优惠券ID';
COMMENT ON COLUMN orders.pay_type IS '支付方式：1-支付宝，2-微信';
COMMENT ON COLUMN orders.source IS '订单来源：1-APP，2-PC，3-小程序';
COMMENT ON COLUMN orders.status IS '订单状态：1-待付款，2-待发货，3-待收货，4-已完成，5-已关闭';
COMMENT ON COLUMN orders.payment_time IS '支付时间';
COMMENT ON COLUMN orders.delivery_time IS '发货时间';
COMMENT ON COLUMN orders.receive_time IS '收货时间';
COMMENT ON COLUMN orders.comment_time IS '评价时间';
COMMENT ON COLUMN orders.receiver_name IS '收货人姓名';
COMMENT ON COLUMN orders.receiver_phone IS '收货人手机号';
COMMENT ON COLUMN orders.receiver_province IS '省份';
COMMENT ON COLUMN orders.receiver_city IS '城市';
COMMENT ON COLUMN orders.receiver_district IS '区县';
COMMENT ON COLUMN orders.receiver_address IS '详细地址';
COMMENT ON COLUMN orders.note IS '订单备注';
COMMENT ON COLUMN orders.deleted IS '是否删除';
COMMENT ON COLUMN orders.create_time IS '创建时间';
COMMENT ON COLUMN orders.update_time IS '更新时间';
COMMENT ON COLUMN orders.version IS '版本号';

-- 订单项表
CREATE TABLE order_items (
                             id BIGSERIAL PRIMARY KEY,
                             order_id BIGINT NOT NULL,
                             order_no VARCHAR(32) NOT NULL,
                             product_id BIGINT NOT NULL,
                             sku_id BIGINT NOT NULL,
                             product_name VARCHAR(200) NOT NULL,
                             sku_code VARCHAR(100) NOT NULL,
                             product_image VARCHAR(255),
                             purchase_price DECIMAL(10,2) NOT NULL,
                             quantity INTEGER NOT NULL,
                             total_amount DECIMAL(10,2) NOT NULL,
                             real_amount DECIMAL(10,2) NOT NULL,
                             create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE order_items IS '订单项表';
COMMENT ON COLUMN order_items.order_id IS '订单ID';
COMMENT ON COLUMN order_items.order_no IS '订单编号';
COMMENT ON COLUMN order_items.product_id IS '商品ID';
COMMENT ON COLUMN order_items.sku_id IS 'SKU ID';
COMMENT ON COLUMN order_items.product_name IS '商品名称';
COMMENT ON COLUMN order_items.sku_code IS 'SKU编码';
COMMENT ON COLUMN order_items.product_image IS '商品图片';
COMMENT ON COLUMN order_items.purchase_price IS '销售价格';
COMMENT ON COLUMN order_items.quantity IS '购买数量';
COMMENT ON COLUMN order_items.total_amount IS '商品总金额';
COMMENT ON COLUMN order_items.real_amount IS '实付金额';
COMMENT ON COLUMN order_items.create_time IS '创建时间';

-- 订单支付表
CREATE TABLE order_payments (
                                id BIGSERIAL PRIMARY KEY,
                                order_id BIGINT NOT NULL,
                                order_no VARCHAR(32) NOT NULL,
                                user_id BIGINT NOT NULL,
                                payment_no VARCHAR(32) NOT NULL,
                                payment_method SMALLINT NOT NULL,
                                payment_amount DECIMAL(10,2) NOT NULL,
                                payment_time TIMESTAMP WITH TIME ZONE,
                                payment_status SMALLINT NOT NULL DEFAULT 1,
                                callback_content TEXT,
                                callback_time TIMESTAMP WITH TIME ZONE,
                                create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                UNIQUE(payment_no),
                                UNIQUE(order_no)
);

COMMENT ON TABLE order_payments IS '订单支付表';
COMMENT ON COLUMN order_payments.order_id IS '订单ID';
COMMENT ON COLUMN order_payments.order_no IS '订单编号';
COMMENT ON COLUMN order_payments.user_id IS '用户ID';
COMMENT ON COLUMN order_payments.payment_no IS '支付流水号';
COMMENT ON COLUMN order_payments.payment_method IS '支付方式：1-支付宝，2-微信';
COMMENT ON COLUMN order_payments.payment_amount IS '支付金额';
COMMENT ON COLUMN order_payments.payment_time IS '支付时间';
COMMENT ON COLUMN order_payments.payment_status IS '支付状态：1-待支付，2-支付中，3-支付成功，4-支付失败';
COMMENT ON COLUMN order_payments.callback_content IS '回调内容';
COMMENT ON COLUMN order_payments.callback_time IS '回调时间';
COMMENT ON COLUMN order_payments.create_time IS '创建时间';
COMMENT ON COLUMN order_payments.update_time IS '更新时间';

-- 订单配送表
CREATE TABLE order_deliveries (
                                  id BIGSERIAL PRIMARY KEY,
                                  order_id BIGINT NOT NULL,
                                  order_no VARCHAR(32) NOT NULL,
                                  delivery_no VARCHAR(32) NOT NULL,
                                  delivery_company VARCHAR(50) NOT NULL,
                                  status SMALLINT NOT NULL DEFAULT 1,
                                  receiver_name VARCHAR(50) NOT NULL,
                                  receiver_phone VARCHAR(20) NOT NULL,
                                  receiver_province VARCHAR(50) NOT NULL,
                                  receiver_city VARCHAR(50) NOT NULL,
                                  receiver_district VARCHAR(50) NOT NULL,
                                  receiver_address VARCHAR(200) NOT NULL,
                                  delivery_time TIMESTAMP WITH TIME ZONE,
                                  receive_time TIMESTAMP WITH TIME ZONE,
                                  create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  UNIQUE(delivery_no),
                                  UNIQUE(order_no)
);

COMMENT ON TABLE order_deliveries IS '订单配送表';
COMMENT ON COLUMN order_deliveries.order_id IS '订单ID';
COMMENT ON COLUMN order_deliveries.order_no IS '订单编号';
COMMENT ON COLUMN order_deliveries.delivery_no IS '物流单号';
COMMENT ON COLUMN order_deliveries.delivery_company IS '物流公司';
COMMENT ON COLUMN order_deliveries.status IS '配送状态：1-待发货，2-已发货，3-已签收';
COMMENT ON COLUMN order_deliveries.receiver_name IS '收货人姓名';
COMMENT ON COLUMN order_deliveries.receiver_phone IS '收货人手机号';
COMMENT ON COLUMN order_deliveries.receiver_province IS '省份';
COMMENT ON COLUMN order_deliveries.receiver_city IS '城市';
COMMENT ON COLUMN order_deliveries.receiver_district IS '区县';
COMMENT ON COLUMN order_deliveries.receiver_address IS '详细地址';
COMMENT ON COLUMN order_deliveries.delivery_time IS '发货时间';
COMMENT ON COLUMN order_deliveries.receive_time IS '签收时间';
COMMENT ON COLUMN order_deliveries.create_time IS '创建时间';
COMMENT ON COLUMN order_deliveries.update_time IS '更新时间';

-- 订单退货表
CREATE TABLE order_returns (
                               id BIGSERIAL PRIMARY KEY,
                               return_no VARCHAR(32) NOT NULL,
                               order_id BIGINT NOT NULL,
                               order_no VARCHAR(32) NOT NULL,
                               user_id BIGINT NOT NULL,
                               return_amount DECIMAL(10,2) NOT NULL,
                               return_type SMALLINT NOT NULL,
                               return_reason VARCHAR(500) NOT NULL,
                               status SMALLINT NOT NULL DEFAULT 1,
                               refuse_reason VARCHAR(500),
                               logistics_no VARCHAR(32),
                               logistics_company VARCHAR(50),
                               return_time TIMESTAMP WITH TIME ZONE,
                               complete_time TIMESTAMP WITH TIME ZONE,
                               create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               UNIQUE(return_no),
                               UNIQUE(order_no)
);

COMMENT ON TABLE order_returns IS '订单退货表';
COMMENT ON COLUMN order_returns.return_no IS '退货单号';
COMMENT ON COLUMN order_returns.order_id IS '订单ID';
COMMENT ON COLUMN order_returns.order_no IS '订单编号';
COMMENT ON COLUMN order_returns.user_id IS '用户ID';
COMMENT ON COLUMN order_returns.return_amount IS '退款金额';
COMMENT ON COLUMN order_returns.return_type IS '退货类型：1-仅退款，2-退货退款';
COMMENT ON COLUMN order_returns.return_reason IS '退货原因';
COMMENT ON COLUMN order_returns.status IS '退货状态：1-待处理，2-已同意，3-已拒绝，4-已完成';
COMMENT ON COLUMN order_returns.refuse_reason IS '拒绝原因';
COMMENT ON COLUMN order_returns.logistics_no IS '退货物流单号';
COMMENT ON COLUMN order_returns.logistics_company IS '物流公司';
COMMENT ON COLUMN order_returns.return_time IS '退货时间';
COMMENT ON COLUMN order_returns.complete_time IS '完成时间';
COMMENT ON COLUMN order_returns.create_time IS '创建时间';
COMMENT ON COLUMN order_returns.update_time IS '更新时间';

-- 订单操作历史表
CREATE TABLE order_histories (
                                 id BIGSERIAL PRIMARY KEY,
                                 order_id BIGINT NOT NULL,
                                 order_no VARCHAR(32) NOT NULL,
                                 operator_id BIGINT NOT NULL,
                                 operator_type SMALLINT NOT NULL,
                                 order_status SMALLINT NOT NULL,
                                 action VARCHAR(100) NOT NULL,
                                 note VARCHAR(500),
                                 create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE order_histories IS '订单操作历史表';
COMMENT ON COLUMN order_histories.order_id IS '订单ID';
COMMENT ON COLUMN order_histories.order_no IS '订单编号';
COMMENT ON COLUMN order_histories.operator_id IS '操作人ID';
COMMENT ON COLUMN order_histories.operator_type IS '操作人类型：1-用户，2-系统，3-后台管理员';
COMMENT ON COLUMN order_histories.order_status IS '订单状态';
COMMENT ON COLUMN order_histories.action IS '操作行为';
COMMENT ON COLUMN order_histories.note IS '操作备注';
COMMENT ON COLUMN order_histories.create_time IS '创建时间';

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
