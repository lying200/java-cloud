-- 任务调度服务数据库初始化脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS cloud_job;

-- 切换到任务调度数据库
\c cloud_job;

-- 任务信息表
CREATE TABLE jobs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '任务名称',
    job_group VARCHAR(50) NOT NULL COMMENT '任务分组',
    invoke_target VARCHAR(500) NOT NULL COMMENT '调用目标字符串',
    cron_expression VARCHAR(255) NOT NULL COMMENT 'cron执行表达式',
    misfire_policy SMALLINT NOT NULL DEFAULT 1 COMMENT '计划执行错误策略：1-立即执行，2-执行一次，3-放弃执行',
    concurrent BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否并发执行',
    status SMALLINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，2-暂停',
    remark VARCHAR(500) COMMENT '备注信息',
    notify_channel SMALLINT COMMENT '通知渠道：1-邮件，2-短信，3-钉钉，4-飞书',
    notify_emails VARCHAR(255) COMMENT '通知邮件地址，多个用逗号分隔',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0,
    UNIQUE(name, job_group) WHERE deleted = FALSE
);

-- 任务日志表
CREATE TABLE job_logs (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL COMMENT '任务ID',
    name VARCHAR(100) NOT NULL COMMENT '任务名称',
    job_group VARCHAR(50) NOT NULL COMMENT '任务分组',
    invoke_target VARCHAR(500) NOT NULL COMMENT '调用目标字符串',
    job_message VARCHAR(500) COMMENT '日志信息',
    status SMALLINT NOT NULL COMMENT '执行状态：1-成功，2-失败',
    exception_info TEXT COMMENT '异常信息',
    start_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP WITH TIME ZONE COMMENT '结束时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 任务锁表
CREATE TABLE job_locks (
    id BIGSERIAL PRIMARY KEY,
    lock_name VARCHAR(100) NOT NULL COMMENT '锁名称',
    lock_key VARCHAR(100) NOT NULL COMMENT '锁键值',
    node_id VARCHAR(100) NOT NULL COMMENT '节点标识',
    lock_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '上锁时间',
    expire_time TIMESTAMP WITH TIME ZONE NOT NULL COMMENT '过期时间',
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(lock_name, lock_key)
);

-- 创建索引
CREATE INDEX idx_jobs_name ON jobs(name);
CREATE INDEX idx_jobs_job_group ON jobs(job_group);
CREATE INDEX idx_jobs_status ON jobs(status);

CREATE INDEX idx_logs_job_id ON job_logs(job_id);
CREATE INDEX idx_logs_name ON job_logs(name);
CREATE INDEX idx_logs_job_group ON job_logs(job_group);
CREATE INDEX idx_logs_status ON job_logs(status);
CREATE INDEX idx_logs_start_time ON job_logs(start_time);

CREATE INDEX idx_locks_node_id ON job_locks(node_id);
CREATE INDEX idx_locks_expire_time ON job_locks(expire_time);
