-- 消息服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_message;

-- 切换到消息数据库
\c cloud_message;

-- 消息模板表
CREATE TABLE message_templates (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL COMMENT '模板编码',
    name VARCHAR(100) NOT NULL COMMENT '模板名称',
    type SMALLINT NOT NULL COMMENT '模板类型：1-站内信，2-短信，3-邮件，4-微信',
    title_template TEXT NOT NULL COMMENT '标题模板',
    content_template TEXT NOT NULL COMMENT '内容模板',
    params JSONB COMMENT '参数说明',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(code) WHERE deleted = FALSE
);

COMMENT ON TABLE message_templates IS '消息模板表';

-- 消息记录表
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT NOT NULL COMMENT '模板ID',
    template_code VARCHAR(100) NOT NULL COMMENT '模板编码',
    type SMALLINT NOT NULL COMMENT '消息类型：1-站内信，2-短信，3-邮件，4-微信',
    title VARCHAR(200) NOT NULL COMMENT '消息标题',
    content TEXT NOT NULL COMMENT '消息内容',
    sender VARCHAR(100) NOT NULL DEFAULT 'system' COMMENT '发送者',
    receiver VARCHAR(100) NOT NULL COMMENT '接收者',
    params JSONB COMMENT '参数内容',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-待发送，2-发送中，3-发送成功，4-发送失败',
    send_time TIMESTAMP WITH TIME ZONE COMMENT '发送时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE messages IS '消息记录表';

-- 站内信表
CREATE TABLE internal_messages (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL COMMENT '消息ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(200) NOT NULL COMMENT '消息标题',
    content TEXT NOT NULL COMMENT '消息内容',
    is_read BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否已读',
    read_time TIMESTAMP WITH TIME ZONE COMMENT '阅读时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);

COMMENT ON TABLE internal_messages IS '站内信表';

-- 消息配置表
CREATE TABLE message_configs (
    id BIGSERIAL PRIMARY KEY,
    type SMALLINT NOT NULL COMMENT '配置类型：1-短信，2-邮件，3-微信',
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    config JSONB NOT NULL COMMENT '配置内容',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(type, name)
);

COMMENT ON TABLE message_configs IS '消息配置表';

-- 创建索引
CREATE INDEX idx_templates_type ON message_templates(type);
CREATE INDEX idx_templates_status ON message_templates(status);

CREATE INDEX idx_messages_template_id ON messages(template_id);
CREATE INDEX idx_messages_template_code ON messages(template_code);
CREATE INDEX idx_messages_type ON messages(type);
CREATE INDEX idx_messages_status ON messages(status);
CREATE INDEX idx_messages_send_time ON messages(send_time);

CREATE INDEX idx_internal_messages_message_id ON internal_messages(message_id);
CREATE INDEX idx_internal_messages_user_id ON internal_messages(user_id);
CREATE INDEX idx_internal_messages_is_read ON internal_messages(is_read);

CREATE INDEX idx_configs_status ON message_configs(status);
