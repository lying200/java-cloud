-- 任务调度服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_job;

-- 切换到任务调度数据库
\c cloud_job;

-- 任务信息表
CREATE TABLE jobs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '任务名称',
    job_group VARCHAR(50) NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
    job_class VARCHAR(255) NOT NULL COMMENT '任务类名',
    description VARCHAR(500) COMMENT '任务描述',
    cron_expression VARCHAR(100) COMMENT 'cron表达式',
    concurrent BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否并发执行',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-暂停',
    params JSONB COMMENT '任务参数',
    retry_count INTEGER NOT NULL DEFAULT 0 COMMENT '重试次数',
    retry_interval INTEGER NOT NULL DEFAULT 0 COMMENT '重试间隔（秒）',
    notify_type SMALLINT[] COMMENT '通知类型：1-邮件，2-短信，3-站内信',
    notify_receivers TEXT[] COMMENT '通知接收人',
    timeout INTEGER NOT NULL DEFAULT 0 COMMENT '超时时间（秒），0表示永不超时',
    last_execute_time TIMESTAMP COMMENT '上次执行时间',
    next_execute_time TIMESTAMP COMMENT '下次执行时间',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

-- 任务日志表
CREATE TABLE job_logs (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL,
    job_name VARCHAR(100) NOT NULL,
    job_group VARCHAR(50) NOT NULL,
    job_class VARCHAR(255) NOT NULL,
    params JSONB COMMENT '执行参数',
    status SMALLINT NOT NULL COMMENT '状态：1-执行中，2-执行成功，3-执行失败',
    error_msg TEXT COMMENT '失败信息',
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    duration INTEGER COMMENT '执行时长（毫秒）',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id)
);

-- 定时任务锁表
CREATE TABLE job_locks (
    id BIGSERIAL PRIMARY KEY,
    lock_name VARCHAR(100) NOT NULL UNIQUE,
    lock_owner VARCHAR(100) NOT NULL COMMENT '锁持有者',
    lock_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expire_time TIMESTAMP NOT NULL COMMENT '锁过期时间'
);

-- 创建索引
CREATE INDEX idx_jobs_name ON jobs(name);
CREATE INDEX idx_jobs_group ON jobs(job_group);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_job_logs_job_id ON job_logs(job_id);
CREATE INDEX idx_job_logs_status ON job_logs(status);
CREATE INDEX idx_job_logs_start_time ON job_logs(start_time);

-- 插入默认任务
INSERT INTO jobs (
    name,
    job_class,
    description,
    cron_expression,
    concurrent,
    status,
    notify_type,
    notify_receivers
) VALUES (
    '订单自动关闭任务',
    'com.example.job.OrderCloseJob',
    '定时关闭超时未支付订单',
    '0 0/30 * * * ?',
    false,
    1,
    ARRAY[3],
    ARRAY['admin']
),
(
    '订单自动确认任务',
    'com.example.job.OrderConfirmJob',
    '定时确认已发货超过N天的订单',
    '0 0 1 * * ?',
    false,
    1,
    ARRAY[3],
    ARRAY['admin']
),
(
    '优惠券过期处理任务',
    'com.example.job.CouponExpireJob',
    '处理已过期优惠券',
    '0 0 1 * * ?',
    false,
    1,
    ARRAY[3],
    ARRAY['admin']
);
