-- 认证服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_auth;

-- 切换到认证数据库
\c cloud_auth;

-- OAuth2客户端表
CREATE TABLE oauth2_clients (
    id BIGSERIAL PRIMARY KEY,
    client_id VARCHAR(100) NOT NULL COMMENT '客户端ID',
    client_secret VARCHAR(100) NOT NULL COMMENT '客户端密钥',
    resource_ids VARCHAR(256) COMMENT '资源ID集合',
    scope VARCHAR(256) NOT NULL COMMENT '授权范围',
    authorized_grant_types VARCHAR(256) NOT NULL COMMENT '授权类型',
    web_server_redirect_uri VARCHAR(256) COMMENT '重定向URI',
    authorities VARCHAR(256) COMMENT '权限集合',
    access_token_validity INTEGER NOT NULL DEFAULT 7200 COMMENT '访问令牌有效期',
    refresh_token_validity INTEGER NOT NULL DEFAULT 86400 COMMENT '刷新令牌有效期',
    additional_information VARCHAR(4096) COMMENT '附加信息',
    auto_approve BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否自动授权',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(client_id) WHERE deleted = FALSE
);

-- OAuth2授权码表
CREATE TABLE oauth2_authorization_codes (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(256) NOT NULL COMMENT '授权码',
    client_id VARCHAR(100) NOT NULL COMMENT '客户端ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    scope VARCHAR(256) NOT NULL COMMENT '授权范围',
    redirect_uri VARCHAR(256) NOT NULL COMMENT '重定向URI',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '过期时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(code)
);

-- OAuth2访问令牌表
CREATE TABLE oauth2_access_tokens (
    id BIGSERIAL PRIMARY KEY,
    token_id VARCHAR(256) NOT NULL COMMENT '令牌ID',
    token TEXT NOT NULL COMMENT '令牌内容',
    authentication_id VARCHAR(256) NOT NULL COMMENT '身份认证ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    client_id VARCHAR(100) NOT NULL COMMENT '客户端ID',
    token_type VARCHAR(50) NOT NULL COMMENT '令牌类型',
    scope VARCHAR(256) COMMENT '授权范围',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '过期时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(token_id),
    UNIQUE(authentication_id)
);

-- OAuth2刷新令牌表
CREATE TABLE oauth2_refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    token_id VARCHAR(256) NOT NULL COMMENT '令牌ID',
    token TEXT NOT NULL COMMENT '令牌内容',
    authentication TEXT NOT NULL COMMENT '身份认证内容',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    client_id VARCHAR(100) NOT NULL COMMENT '客户端ID',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '过期时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(token_id)
);

-- 登录日志表
CREATE TABLE login_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    login_ip VARCHAR(50) NOT NULL COMMENT '登录IP',
    login_location VARCHAR(100) COMMENT '登录地点',
    browser VARCHAR(50) COMMENT '浏览器',
    os VARCHAR(50) COMMENT '操作系统',
    status SMALLINT NOT NULL COMMENT '状态：1-成功，2-失败',
    msg VARCHAR(500) COMMENT '提示信息',
    login_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_clients_status ON oauth2_clients(status);

CREATE INDEX idx_auth_codes_client_id ON oauth2_authorization_codes(client_id);
CREATE INDEX idx_auth_codes_user_id ON oauth2_authorization_codes(user_id);
CREATE INDEX idx_auth_codes_expires_at ON oauth2_authorization_codes(expires_at);

CREATE INDEX idx_access_tokens_user_id ON oauth2_access_tokens(user_id);
CREATE INDEX idx_access_tokens_client_id ON oauth2_access_tokens(client_id);
CREATE INDEX idx_access_tokens_expires_at ON oauth2_access_tokens(expires_at);

CREATE INDEX idx_refresh_tokens_user_id ON oauth2_refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_client_id ON oauth2_refresh_tokens(client_id);
CREATE INDEX idx_refresh_tokens_expires_at ON oauth2_refresh_tokens(expires_at);

CREATE INDEX idx_login_logs_user_id ON login_logs(user_id);
CREATE INDEX idx_login_logs_username ON login_logs(username);
CREATE INDEX idx_login_logs_status ON login_logs(status);
CREATE INDEX idx_login_logs_login_time ON login_logs(login_time);
