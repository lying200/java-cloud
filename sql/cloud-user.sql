-- 用户服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 用户表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    nickname VARCHAR(50),
    avatar VARCHAR(255),
    mobile VARCHAR(20),
    email VARCHAR(100),
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_time TIMESTAMP WITH TIME ZONE,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_users_username ON users (username) WHERE NOT deleted;
CREATE UNIQUE INDEX idx_users_mobile ON users (mobile) WHERE NOT deleted;
CREATE UNIQUE INDEX idx_users_email ON users (email) WHERE NOT deleted;

COMMENT ON TABLE users IS '用户表';
COMMENT ON COLUMN users.username IS '用户名';
COMMENT ON COLUMN users.password IS '密码';
COMMENT ON COLUMN users.nickname IS '昵称';
COMMENT ON COLUMN users.avatar IS '头像';
COMMENT ON COLUMN users.mobile IS '手机号';
COMMENT ON COLUMN users.email IS '邮箱';
COMMENT ON COLUMN users.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN users.deleted IS '是否删除';
COMMENT ON COLUMN users.create_time IS '创建时间';
COMMENT ON COLUMN users.update_time IS '更新时间';
COMMENT ON COLUMN users.last_login_time IS '最后登录时间';
COMMENT ON COLUMN users.version IS '版本号';

-- 用户角色表
CREATE TABLE user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_code VARCHAR(50) NOT NULL,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(user_id, role_code)
);

COMMENT ON TABLE user_roles IS '用户角色关联表';
COMMENT ON COLUMN user_roles.user_id IS '用户ID';
COMMENT ON COLUMN user_roles.role_code IS '角色编码';
COMMENT ON COLUMN user_roles.create_time IS '创建时间';
COMMENT ON COLUMN user_roles.update_time IS '更新时间';
COMMENT ON COLUMN user_roles.version IS '版本号';

-- 角色表
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_roles_role_code ON roles (role_code) WHERE NOT deleted;

COMMENT ON TABLE roles IS '角色表';
COMMENT ON COLUMN roles.role_code IS '角色编码';
COMMENT ON COLUMN roles.role_name IS '角色名称';
COMMENT ON COLUMN roles.description IS '角色描述';
COMMENT ON COLUMN roles.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN roles.deleted IS '是否删除';
COMMENT ON COLUMN roles.create_time IS '创建时间';
COMMENT ON COLUMN roles.update_time IS '更新时间';
COMMENT ON COLUMN roles.version IS '版本号';

-- 角色权限表
CREATE TABLE role_permissions (
    id BIGSERIAL PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL,
    permission_code VARCHAR(100) NOT NULL,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(role_code, permission_code)
);

COMMENT ON TABLE role_permissions IS '角色权限关联表';
COMMENT ON COLUMN role_permissions.role_code IS '角色编码';
COMMENT ON COLUMN role_permissions.permission_code IS '权限编码';
COMMENT ON COLUMN role_permissions.create_time IS '创建时间';
COMMENT ON COLUMN role_permissions.update_time IS '更新时间';
COMMENT ON COLUMN role_permissions.version IS '版本号';

-- 权限表
CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    permission_code VARCHAR(100) NOT NULL,
    permission_name VARCHAR(100) NOT NULL,
    permission_type VARCHAR(50) NOT NULL,
    parent_id BIGINT,
    path VARCHAR(200),
    component VARCHAR(255),
    redirect VARCHAR(255),
    icon VARCHAR(100),
    sort_order INTEGER NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_permissions_permission_code ON permissions (permission_code) WHERE NOT deleted;

COMMENT ON TABLE permissions IS '权限表';
COMMENT ON COLUMN permissions.permission_code IS '权限编码';
COMMENT ON COLUMN permissions.permission_name IS '权限名称';
COMMENT ON COLUMN permissions.permission_type IS '权限类型：menu-菜单，button-按钮';
COMMENT ON COLUMN permissions.parent_id IS '父级ID';
COMMENT ON COLUMN permissions.path IS '路径';
COMMENT ON COLUMN permissions.component IS '前端组件';
COMMENT ON COLUMN permissions.redirect IS '重定向';
COMMENT ON COLUMN permissions.icon IS '图标';
COMMENT ON COLUMN permissions.sort_order IS '排序';
COMMENT ON COLUMN permissions.status IS '状态：1-正常，2-禁用';
COMMENT ON COLUMN permissions.deleted IS '是否删除';
COMMENT ON COLUMN permissions.create_time IS '创建时间';
COMMENT ON COLUMN permissions.update_time IS '更新时间';
COMMENT ON COLUMN permissions.version IS '版本号';

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
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE user_addresses IS '用户地址表';
COMMENT ON COLUMN user_addresses.user_id IS '用户ID';
COMMENT ON COLUMN user_addresses.receiver_name IS '收货人';
COMMENT ON COLUMN user_addresses.receiver_mobile IS '手机号';
COMMENT ON COLUMN user_addresses.province IS '省份';
COMMENT ON COLUMN user_addresses.city IS '城市';
COMMENT ON COLUMN user_addresses.district IS '区县';
COMMENT ON COLUMN user_addresses.detail_address IS '详细地址';
COMMENT ON COLUMN user_addresses.is_default IS '是否默认';
COMMENT ON COLUMN user_addresses.deleted IS '是否删除';
COMMENT ON COLUMN user_addresses.create_time IS '创建时间';
COMMENT ON COLUMN user_addresses.update_time IS '更新时间';
COMMENT ON COLUMN user_addresses.version IS '版本号';

-- 用户积分表
CREATE TABLE user_points (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    points INTEGER NOT NULL DEFAULT 0,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE user_points IS '用户积分表';
COMMENT ON COLUMN user_points.user_id IS '用户ID';
COMMENT ON COLUMN user_points.points IS '积分';
COMMENT ON COLUMN user_points.create_time IS '创建时间';
COMMENT ON COLUMN user_points.update_time IS '更新时间';
COMMENT ON COLUMN user_points.version IS '版本号';

-- 积分历史表
CREATE TABLE point_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    points INTEGER NOT NULL,
    type SMALLINT NOT NULL,
    description VARCHAR(500),
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE point_history IS '积分历史表';
COMMENT ON COLUMN point_history.user_id IS '用户ID';
COMMENT ON COLUMN point_history.points IS '积分';
COMMENT ON COLUMN point_history.type IS '类型：1-增加，2-减少';
COMMENT ON COLUMN point_history.description IS '描述';
COMMENT ON COLUMN point_history.create_time IS '创建时间';

-- 创建索引
CREATE INDEX idx_users_status ON users(status);
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
