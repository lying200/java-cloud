-- 用户服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_user;

-- 切换到用户数据库
\c cloud_user;

-- 用户表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    nickname VARCHAR(50),
    avatar VARCHAR(255),
    mobile VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_time TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 用户角色表
CREATE TABLE user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE (user_id, role_id)
);

-- 角色表
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 权限表
CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    type SMALLINT NOT NULL COMMENT '类型：1-菜单，2-按钮，3-接口',
    parent_id BIGINT,
    path VARCHAR(200),
    component VARCHAR(100),
    icon VARCHAR(100),
    sort_order INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 角色权限关联表
CREATE TABLE role_permissions (
    id BIGSERIAL PRIMARY KEY,
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id),
    UNIQUE (role_id, permission_id)
);

-- 用户地址表
CREATE TABLE user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    receiver_name VARCHAR(50) NOT NULL,
    receiver_mobile VARCHAR(20) NOT NULL,
    province VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL,
    detail_address VARCHAR(200) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 用户积分表
CREATE TABLE user_points (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    points INTEGER NOT NULL DEFAULT 0,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 积分历史记录表
CREATE TABLE point_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    points INTEGER NOT NULL,
    type SMALLINT NOT NULL COMMENT '类型：1-增加，2-减少',
    source VARCHAR(50) NOT NULL COMMENT '来源：register-注册，order-订单，admin-管理员',
    description VARCHAR(200),
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_mobile ON users(mobile);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_permissions_parent_id ON permissions(parent_id);
CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_point_records_user_id ON point_records(user_id);

-- 插入初始数据
INSERT INTO roles (name, code, description) VALUES 
('超级管理员', 'ROLE_ADMIN', '系统超级管理员'),
('普通用户', 'ROLE_USER', '普通注册用户');

INSERT INTO permissions (name, code, type, path, component, icon, sort_order) VALUES 
('系统管理', 'system', 1, '/system', 'Layout', 'system', 1),
('用户管理', 'system:user', 1, '/system/user', 'system/user/index', 'user', 1),
('角色管理', 'system:role', 1, '/system/role', 'system/role/index', 'role', 2),
('权限管理', 'system:permission', 1, '/system/permission', 'system/permission/index', 'permission', 3);
