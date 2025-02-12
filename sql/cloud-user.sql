-- 用户服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_user;

-- 切换到用户数据库
\c cloud_user;

-- 用户表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar VARCHAR(255) COMMENT '头像',
    mobile VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_time TIMESTAMP WITH TIME ZONE,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(username) WHERE deleted = FALSE,
    UNIQUE(mobile) WHERE mobile IS NOT NULL AND deleted = FALSE,
    UNIQUE(email) WHERE email IS NOT NULL AND deleted = FALSE
);

COMMENT ON TABLE users IS '用户表';
COMMENT ON COLUMN users.status IS '状态：1-正常，2-禁用';

-- 用户角色表
CREATE TABLE user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_code VARCHAR(50) NOT NULL COMMENT '角色编码',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(user_id, role_code)
);

COMMENT ON TABLE user_roles IS '用户角色关联表';

-- 角色表
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL COMMENT '角色编码',
    role_name VARCHAR(100) NOT NULL COMMENT '角色名称',
    description VARCHAR(500) COMMENT '角色描述',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(role_code) WHERE deleted = FALSE
);

COMMENT ON TABLE roles IS '角色表';
COMMENT ON COLUMN roles.status IS '状态：1-正常，2-禁用';

-- 角色权限表
CREATE TABLE role_permissions (
    id BIGSERIAL PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL COMMENT '角色编码',
    permission_code VARCHAR(100) NOT NULL COMMENT '权限编码',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(role_code, permission_code)
);

COMMENT ON TABLE role_permissions IS '角色权限关联表';

-- 权限表
CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    permission_code VARCHAR(100) NOT NULL COMMENT '权限编码',
    permission_name VARCHAR(100) NOT NULL COMMENT '权限名称',
    permission_type VARCHAR(50) NOT NULL COMMENT '权限类型：menu-菜单，button-按钮',
    parent_id BIGINT COMMENT '父级ID',
    path VARCHAR(200) COMMENT '路径',
    component VARCHAR(255) COMMENT '前端组件',
    redirect VARCHAR(255) COMMENT '重定向',
    icon VARCHAR(100) COMMENT '图标',
    sort_order INTEGER NOT NULL DEFAULT 0 COMMENT '排序',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-禁用',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(permission_code) WHERE deleted = FALSE
);

COMMENT ON TABLE permissions IS '权限表';
COMMENT ON COLUMN permissions.permission_type IS '权限类型：menu-菜单，button-按钮';
COMMENT ON COLUMN permissions.status IS '状态：1-正常，2-禁用';

-- 用户地址表
CREATE TABLE user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    receiver_name VARCHAR(50) NOT NULL COMMENT '收货人',
    receiver_mobile VARCHAR(20) NOT NULL COMMENT '手机号',
    province VARCHAR(50) NOT NULL COMMENT '省份',
    city VARCHAR(50) NOT NULL COMMENT '城市',
    district VARCHAR(50) NOT NULL COMMENT '区县',
    detail_address VARCHAR(200) NOT NULL COMMENT '详细地址',
    is_default BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否默认',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE user_addresses IS '用户地址表';

-- 用户积分表
CREATE TABLE user_points (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    points INTEGER NOT NULL DEFAULT 0,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE user_points IS '用户积分表';

-- 积分历史表
CREATE TABLE point_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    points INTEGER NOT NULL,
    type SMALLINT NOT NULL COMMENT '类型：1-增加，2-减少',
    description VARCHAR(500),
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE point_history IS '积分历史表';

-- 创建索引
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_mobile ON users(mobile);
CREATE INDEX idx_users_email ON users(email);

CREATE INDEX idx_roles_status ON roles(status);

CREATE INDEX idx_permissions_parent_id ON permissions(parent_id);
CREATE INDEX idx_permissions_type ON permissions(permission_type);
CREATE INDEX idx_permissions_status ON permissions(status);
CREATE INDEX idx_permissions_sort ON permissions(sort_order);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_code ON user_roles(role_code);

CREATE INDEX idx_role_permissions_role_code ON role_permissions(role_code);
CREATE INDEX idx_role_permissions_permission_code ON role_permissions(permission_code);

CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_user_points_user_id ON user_points(user_id);
CREATE INDEX idx_point_history_user_id ON point_history(user_id);
CREATE INDEX idx_point_history_create_time ON point_history(create_time);
