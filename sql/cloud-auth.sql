-- 认证服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_auth;

-- 切换到认证数据库
\c cloud_auth;

-- OAuth2 客户端表
CREATE TABLE oauth2_clients (
    id BIGSERIAL PRIMARY KEY,
    client_id VARCHAR(100) NOT NULL UNIQUE,
    client_secret VARCHAR(255) NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    grant_types VARCHAR[] NOT NULL COMMENT '授权类型：password,authorization_code,refresh_token,client_credentials',
    scope VARCHAR[] NOT NULL COMMENT '权限范围',
    redirect_uris TEXT[] COMMENT '重定向URI，authorization_code时必填',
    access_token_validity INTEGER NOT NULL DEFAULT 7200 COMMENT 'access token有效期，单位秒',
    refresh_token_validity INTEGER NOT NULL DEFAULT 604800 COMMENT 'refresh token有效期，单位秒',
    additional_information JSONB COMMENT '附加信息',
    auto_approve BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否自动授权',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- OAuth2 授权码表
CREATE TABLE oauth2_authorization_codes (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(255) NOT NULL UNIQUE,
    client_id VARCHAR(100) NOT NULL,
    user_id BIGINT NOT NULL,
    scope VARCHAR[] NOT NULL,
    redirect_uri TEXT NOT NULL,
    expires_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- OAuth2 访问令牌表
CREATE TABLE oauth2_access_tokens (
    id BIGSERIAL PRIMARY KEY,
    access_token VARCHAR(255) NOT NULL UNIQUE,
    client_id VARCHAR(100) NOT NULL,
    user_id BIGINT,
    scope VARCHAR[] NOT NULL,
    expires_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- OAuth2 刷新令牌表
CREATE TABLE oauth2_refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    refresh_token VARCHAR(255) NOT NULL UNIQUE,
    client_id VARCHAR(100) NOT NULL,
    user_id BIGINT,
    scope VARCHAR[] NOT NULL,
    expires_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 登录日志表
CREATE TABLE login_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    username VARCHAR(50) NOT NULL,
    ip VARCHAR(50) NOT NULL,
    device VARCHAR(200) COMMENT '设备信息',
    browser VARCHAR(100) COMMENT '浏览器信息',
    os VARCHAR(100) COMMENT '操作系统信息',
    status SMALLINT NOT NULL COMMENT '状态：1-成功，2-失败',
    msg VARCHAR(500) COMMENT '失败信息',
    login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_oauth2_clients_client_id ON oauth2_clients(client_id);
CREATE INDEX idx_oauth2_authorization_codes_code ON oauth2_authorization_codes(code);
CREATE INDEX idx_oauth2_access_tokens_token ON oauth2_access_tokens(access_token);
CREATE INDEX idx_oauth2_refresh_tokens_token ON oauth2_refresh_tokens(refresh_token);
CREATE INDEX idx_login_logs_user_id ON login_logs(user_id);
CREATE INDEX idx_login_logs_username ON login_logs(username);

-- 插入默认客户端
INSERT INTO oauth2_clients (
    client_id, 
    client_secret, 
    client_name, 
    grant_types, 
    scope, 
    redirect_uris,
    access_token_validity,
    refresh_token_validity,
    auto_approve
) VALUES (
    'web_app',
    '$2a$10$8/0KhpCXqC0RhF0LGJQvk.uHXVqOHhYhHO/WPwTIDwB5DGvGGYQYi', -- 密码：123456
    'Web应用',
    ARRAY['password', 'authorization_code', 'refresh_token'],
    ARRAY['all'],
    ARRAY['http://localhost:8080/login/oauth2/code/web_app'],
    7200,
    604800,
    true
);
