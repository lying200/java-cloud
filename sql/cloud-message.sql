-- 消息服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 消息模板表
CREATE TABLE message_templates (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL,
    title_template TEXT NOT NULL,
    content_template TEXT NOT NULL,
    params JSONB,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_message_templates_code ON message_templates (code) WHERE NOT deleted;

COMMENT ON TABLE message_templates IS '消息模板表';
COMMENT ON COLUMN message_templates.code IS '模板编码';
COMMENT ON COLUMN message_templates.name IS '模板名称';
COMMENT ON COLUMN message_templates.type IS '模板类型：1-站内信，2-短信，3-邮件，4-微信';
COMMENT ON COLUMN message_templates.title_template IS '标题模板';
COMMENT ON COLUMN message_templates.content_template IS '内容模板';
COMMENT ON COLUMN message_templates.params IS '参数说明';
COMMENT ON COLUMN message_templates.status IS '状态：1-启用，2-禁用';
COMMENT ON COLUMN message_templates.deleted IS '是否删除';
COMMENT ON COLUMN message_templates.create_time IS '创建时间';
COMMENT ON COLUMN message_templates.update_time IS '更新时间';
COMMENT ON COLUMN message_templates.version IS '版本号';

-- 消息记录表
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT NOT NULL,
    template_code VARCHAR(100) NOT NULL,
    type SMALLINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    sender VARCHAR(100) NOT NULL DEFAULT 'system',
    receiver VARCHAR(100) NOT NULL,
    params JSONB,
    status SMALLINT NOT NULL DEFAULT 1,
    send_time TIMESTAMP WITH TIME ZONE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE messages IS '消息记录表';
COMMENT ON COLUMN messages.template_id IS '模板ID';
COMMENT ON COLUMN messages.template_code IS '模板编码';
COMMENT ON COLUMN messages.type IS '消息类型：1-站内信，2-短信，3-邮件，4-微信';
COMMENT ON COLUMN messages.title IS '消息标题';
COMMENT ON COLUMN messages.content IS '消息内容';
COMMENT ON COLUMN messages.sender IS '发送者';
COMMENT ON COLUMN messages.receiver IS '接收者';
COMMENT ON COLUMN messages.params IS '参数内容';
COMMENT ON COLUMN messages.status IS '状态：1-待发送，2-发送中，3-发送成功，4-发送失败';
COMMENT ON COLUMN messages.send_time IS '发送时间';
COMMENT ON COLUMN messages.create_time IS '创建时间';
COMMENT ON COLUMN messages.update_time IS '更新时间';

-- 站内信表
CREATE TABLE internal_messages (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_time TIMESTAMP WITH TIME ZONE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE internal_messages IS '站内信表';
COMMENT ON COLUMN internal_messages.message_id IS '消息ID';
COMMENT ON COLUMN internal_messages.user_id IS '用户ID';
COMMENT ON COLUMN internal_messages.title IS '消息标题';
COMMENT ON COLUMN internal_messages.content IS '消息内容';
COMMENT ON COLUMN internal_messages.is_read IS '是否已读';
COMMENT ON COLUMN internal_messages.read_time IS '阅读时间';
COMMENT ON COLUMN internal_messages.create_time IS '创建时间';

-- 消息配置表
CREATE TABLE message_configs (
    id BIGSERIAL PRIMARY KEY,
    type SMALLINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    config JSONB NOT NULL,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(type, name)
);

COMMENT ON TABLE message_configs IS '消息配置表';
COMMENT ON COLUMN message_configs.type IS '配置类型：1-短信，2-邮件，3-微信';
COMMENT ON COLUMN message_configs.name IS '配置名称';
COMMENT ON COLUMN message_configs.config IS '配置内容';
COMMENT ON COLUMN message_configs.status IS '状态：1-启用，2-禁用';
COMMENT ON COLUMN message_configs.create_time IS '创建时间';
COMMENT ON COLUMN message_configs.update_time IS '更新时间';
COMMENT ON COLUMN message_configs.version IS '版本号';

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
