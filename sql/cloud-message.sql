-- 消息服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_message;

-- 切换到消息数据库
\c cloud_message;

-- 消息模板表
CREATE TABLE message_templates (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '模板编码',
    name VARCHAR(100) NOT NULL COMMENT '模板名称',
    type SMALLINT NOT NULL COMMENT '消息类型：1-站内信，2-短信，3-邮件，4-微信',
    title_template TEXT COMMENT '标题模板',
    content_template TEXT NOT NULL COMMENT '内容模板',
    params JSONB COMMENT '参数说明',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 消息记录表
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT NOT NULL,
    template_code VARCHAR(50) NOT NULL,
    type SMALLINT NOT NULL COMMENT '消息类型：1-站内信，2-短信，3-邮件，4-微信',
    title VARCHAR(200) COMMENT '消息标题',
    content TEXT NOT NULL COMMENT '消息内容',
    sender VARCHAR(50) NOT NULL DEFAULT 'system' COMMENT '发送者',
    receiver VARCHAR(50) NOT NULL COMMENT '接收者',
    params JSONB COMMENT '参数内容',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-待发送，2-发送中，3-发送成功，4-发送失败',
    send_time TIMESTAMP COMMENT '发送时间',
    retry_count INTEGER NOT NULL DEFAULT 0 COMMENT '重试次数',
    next_retry_time TIMESTAMP COMMENT '下次重试时间',
    error_msg TEXT COMMENT '失败原因',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (template_id) REFERENCES message_templates(id)
);

-- 站内信表
CREATE TABLE internal_messages (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_time TIMESTAMP,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (message_id) REFERENCES messages(id)
);

-- 消息发送记录表
CREATE TABLE message_send_logs (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL,
    type SMALLINT NOT NULL COMMENT '消息类型：1-站内信，2-短信，3-邮件，4-微信',
    receiver VARCHAR(50) NOT NULL,
    send_content TEXT NOT NULL COMMENT '发送内容',
    send_status SMALLINT NOT NULL COMMENT '发送状态：1-成功，2-失败',
    error_msg TEXT COMMENT '失败原因',
    send_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (message_id) REFERENCES messages(id)
);

-- 短信配置表
CREATE TABLE sms_configs (
    id BIGSERIAL PRIMARY KEY,
    platform VARCHAR(50) NOT NULL COMMENT '平台：aliyun, tencent, etc',
    access_key VARCHAR(100) NOT NULL,
    secret_key VARCHAR(100) NOT NULL,
    sign_name VARCHAR(50) COMMENT '短信签名',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 邮件配置表
CREATE TABLE email_configs (
    id BIGSERIAL PRIMARY KEY,
    host VARCHAR(100) NOT NULL,
    port INTEGER NOT NULL,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    from_address VARCHAR(100) NOT NULL,
    from_name VARCHAR(50),
    ssl_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 创建索引
CREATE INDEX idx_message_templates_code ON message_templates(code);
CREATE INDEX idx_messages_template_code ON messages(template_code);
CREATE INDEX idx_messages_status ON messages(status);
CREATE INDEX idx_internal_messages_user_id ON internal_messages(user_id);
CREATE INDEX idx_message_send_logs_message_id ON message_send_logs(message_id);

-- 插入默认消息模板
INSERT INTO message_templates (
    code,
    name,
    type,
    title_template,
    content_template,
    params
) VALUES (
    'USER_REGISTER',
    '用户注册验证码',
    2,
    NULL,
    '您的验证码是：${code}，有效期5分钟，请勿泄露给他人。',
    '{"code": "验证码"}'
);
