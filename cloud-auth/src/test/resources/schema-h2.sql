-- 认证服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 认证用户表
CREATE TABLE auth_users (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,  -- 关联cloud-user模块中的用户ID
    username VARCHAR(100) NOT NULL,
    password VARCHAR(200) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'USER',
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_auth_users_username ON auth_users (username);
CREATE INDEX idx_auth_users_user_id ON auth_users (user_id);

COMMENT ON TABLE auth_users IS '认证用户表';
COMMENT ON COLUMN auth_users.user_id IS '关联的用户ID';
COMMENT ON COLUMN auth_users.username IS '用户名';
COMMENT ON COLUMN auth_users.password IS '密码';
COMMENT ON COLUMN auth_users.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN auth_users.deleted IS '是否删除';
COMMENT ON COLUMN auth_users.create_time IS '创建时间';
COMMENT ON COLUMN auth_users.update_time IS '更新时间';
COMMENT ON COLUMN auth_users.version IS '版本号';

-- OAuth2客户端表
CREATE TABLE oauth2_clients (
    id BIGSERIAL PRIMARY KEY,
    client_id VARCHAR(100) NOT NULL,
    client_secret VARCHAR(200) NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    redirect_uri TEXT NOT NULL,
    scopes VARCHAR(200),
    authorized_grant_types VARCHAR(200) NOT NULL,
    access_token_validity INTEGER NOT NULL DEFAULT 3600,
    refresh_token_validity INTEGER NOT NULL DEFAULT 7200,
    additional_information TEXT,
    auto_approve BOOLEAN NOT NULL DEFAULT FALSE,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_oauth2_clients_client_id ON oauth2_clients (client_id);

COMMENT ON TABLE oauth2_clients IS 'OAuth2客户端表';
COMMENT ON COLUMN oauth2_clients.client_id IS '客户端ID';
COMMENT ON COLUMN oauth2_clients.client_secret IS '客户端密钥';
COMMENT ON COLUMN oauth2_clients.client_name IS '客户端名称';
COMMENT ON COLUMN oauth2_clients.redirect_uri IS '重定向URI';
COMMENT ON COLUMN oauth2_clients.scopes IS '授权范围';
COMMENT ON COLUMN oauth2_clients.authorized_grant_types IS '授权类型';
COMMENT ON COLUMN oauth2_clients.access_token_validity IS '访问令牌有效期';
COMMENT ON COLUMN oauth2_clients.refresh_token_validity IS '刷新令牌有效期';
COMMENT ON COLUMN oauth2_clients.additional_information IS '附加信息';
COMMENT ON COLUMN oauth2_clients.auto_approve IS '自动批准';
COMMENT ON COLUMN oauth2_clients.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN oauth2_clients.deleted IS '是否删除';
COMMENT ON COLUMN oauth2_clients.create_time IS '创建时间';
COMMENT ON COLUMN oauth2_clients.update_time IS '更新时间';
COMMENT ON COLUMN oauth2_clients.version IS '版本号';

-- OAuth2授权码表
CREATE TABLE oauth2_authorization_codes (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(200) NOT NULL,
    client_id VARCHAR(100) NOT NULL,
    user_id BIGINT NOT NULL,
    scopes VARCHAR(200),
    redirect_uri TEXT NOT NULL,
    expire_time TIMESTAMP WITH TIME ZONE NOT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_oauth2_authorization_codes_code ON oauth2_authorization_codes (code);

COMMENT ON TABLE oauth2_authorization_codes IS 'OAuth2授权码表';
COMMENT ON COLUMN oauth2_authorization_codes.code IS '授权码';
COMMENT ON COLUMN oauth2_authorization_codes.client_id IS '客户端ID';
COMMENT ON COLUMN oauth2_authorization_codes.user_id IS '用户ID';
COMMENT ON COLUMN oauth2_authorization_codes.scopes IS '授权范围';
COMMENT ON COLUMN oauth2_authorization_codes.redirect_uri IS '重定向URI';
COMMENT ON COLUMN oauth2_authorization_codes.expire_time IS '过期时间';
COMMENT ON COLUMN oauth2_authorization_codes.deleted IS '是否删除';
COMMENT ON COLUMN oauth2_authorization_codes.create_time IS '创建时间';
COMMENT ON COLUMN oauth2_authorization_codes.update_time IS '更新时间';
COMMENT ON COLUMN oauth2_authorization_codes.version IS '版本号';

-- OAuth2访问令牌表
CREATE TABLE oauth2_access_tokens (
    id BIGSERIAL PRIMARY KEY,
    token_id VARCHAR(200) NOT NULL,
    token TEXT NOT NULL,
    authentication_id VARCHAR(200) NOT NULL,
    client_id VARCHAR(100) NOT NULL,
    user_id BIGINT,
    user_name VARCHAR(100),
    scopes VARCHAR(200),
    expire_time TIMESTAMP WITH TIME ZONE NOT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_oauth2_access_tokens_token_id ON oauth2_access_tokens (token_id);
CREATE UNIQUE INDEX idx_oauth2_access_tokens_authentication_id ON oauth2_access_tokens (authentication_id);

COMMENT ON TABLE oauth2_access_tokens IS 'OAuth2访问令牌表';
COMMENT ON COLUMN oauth2_access_tokens.token_id IS '令牌ID';
COMMENT ON COLUMN oauth2_access_tokens.token IS '令牌内容';
COMMENT ON COLUMN oauth2_access_tokens.authentication_id IS '授权ID';
COMMENT ON COLUMN oauth2_access_tokens.client_id IS '客户端ID';
COMMENT ON COLUMN oauth2_access_tokens.user_id IS '用户ID';
COMMENT ON COLUMN oauth2_access_tokens.user_name IS '用户名';
COMMENT ON COLUMN oauth2_access_tokens.scopes IS '授权范围';
COMMENT ON COLUMN oauth2_access_tokens.expire_time IS '过期时间';
COMMENT ON COLUMN oauth2_access_tokens.deleted IS '是否删除';
COMMENT ON COLUMN oauth2_access_tokens.create_time IS '创建时间';
COMMENT ON COLUMN oauth2_access_tokens.update_time IS '更新时间';
COMMENT ON COLUMN oauth2_access_tokens.version IS '版本号';

-- OAuth2刷新令牌表
CREATE TABLE oauth2_refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    token_id VARCHAR(200) NOT NULL,
    token TEXT NOT NULL,
    authentication TEXT NOT NULL,
    client_id VARCHAR(100) NOT NULL,
    user_id BIGINT,
    user_name VARCHAR(100),
    scopes VARCHAR(200),
    expire_time TIMESTAMP WITH TIME ZONE NOT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_oauth2_refresh_tokens_token_id ON oauth2_refresh_tokens (token_id);

COMMENT ON TABLE oauth2_refresh_tokens IS 'OAuth2刷新令牌表';
COMMENT ON COLUMN oauth2_refresh_tokens.token_id IS '令牌ID';
COMMENT ON COLUMN oauth2_refresh_tokens.token IS '令牌内容';
COMMENT ON COLUMN oauth2_refresh_tokens.authentication IS '授权信息';
COMMENT ON COLUMN oauth2_refresh_tokens.client_id IS '客户端ID';
COMMENT ON COLUMN oauth2_refresh_tokens.user_id IS '用户ID';
COMMENT ON COLUMN oauth2_refresh_tokens.user_name IS '用户名';
COMMENT ON COLUMN oauth2_refresh_tokens.scopes IS '授权范围';
COMMENT ON COLUMN oauth2_refresh_tokens.expire_time IS '过期时间';
COMMENT ON COLUMN oauth2_refresh_tokens.deleted IS '是否删除';
COMMENT ON COLUMN oauth2_refresh_tokens.create_time IS '创建时间';
COMMENT ON COLUMN oauth2_refresh_tokens.update_time IS '更新时间';
COMMENT ON COLUMN oauth2_refresh_tokens.version IS '版本号';

-- 登录日志表
CREATE TABLE login_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    login_ip VARCHAR(50) NOT NULL,
    login_location VARCHAR(255),
    browser VARCHAR(50),
    os VARCHAR(50),
    status SMALLINT NOT NULL DEFAULT 1,
    msg VARCHAR(255),
    login_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE login_logs IS '登录日志表';
COMMENT ON COLUMN login_logs.user_id IS '用户ID';
COMMENT ON COLUMN login_logs.user_name IS '用户名';
COMMENT ON COLUMN login_logs.login_ip IS '登录IP';
COMMENT ON COLUMN login_logs.login_location IS '登录地点';
COMMENT ON COLUMN login_logs.browser IS '浏览器类型';
COMMENT ON COLUMN login_logs.os IS '操作系统';
COMMENT ON COLUMN login_logs.status IS '登录状态：1-成功，2-失败';
COMMENT ON COLUMN login_logs.msg IS '提示消息';
COMMENT ON COLUMN login_logs.login_time IS '登录时间';
COMMENT ON COLUMN login_logs.deleted IS '是否删除';
COMMENT ON COLUMN login_logs.create_time IS '创建时间';
COMMENT ON COLUMN login_logs.update_time IS '更新时间';
COMMENT ON COLUMN login_logs.version IS '版本号';

-- 创建索引
CREATE INDEX idx_oauth2_clients_status ON oauth2_clients(status);

CREATE INDEX idx_oauth2_authorization_codes_client_id ON oauth2_authorization_codes(client_id);
CREATE INDEX idx_oauth2_authorization_codes_user_id ON oauth2_authorization_codes(user_id);
CREATE INDEX idx_oauth2_authorization_codes_expire_time ON oauth2_authorization_codes(expire_time);

CREATE INDEX idx_oauth2_access_tokens_client_id ON oauth2_access_tokens(client_id);
CREATE INDEX idx_oauth2_access_tokens_user_id ON oauth2_access_tokens(user_id);
CREATE INDEX idx_oauth2_access_tokens_expire_time ON oauth2_access_tokens(expire_time);

CREATE INDEX idx_oauth2_refresh_tokens_client_id ON oauth2_refresh_tokens(client_id);
CREATE INDEX idx_oauth2_refresh_tokens_user_id ON oauth2_refresh_tokens(user_id);
CREATE INDEX idx_oauth2_refresh_tokens_expire_time ON oauth2_refresh_tokens(expire_time);

CREATE INDEX idx_login_logs_user_id ON login_logs(user_id);
CREATE INDEX idx_login_logs_status ON login_logs(status);
CREATE INDEX idx_login_logs_login_time ON login_logs(login_time);
